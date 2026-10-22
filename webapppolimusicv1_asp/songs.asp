<%@ LANGUAGE="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' ============================================================
'  songs.asp · CRUD de canciones (solo administrador)
' ============================================================
RequireAdmin

PageTitle  = "Canciones"
PageKicker = "Catalogo · administracion"
ActiveNav  = "songs"

Dim op, editId, showForm, errMsg
Dim fName, fPath, fPlays, selArtists, selAlbums
Dim rsList, rsArt, rsAlb, rsOne, rsSel, rowIdx, trackJsonParts
Dim audioFiles

showForm = False
errMsg = ""
editId = Num(Request.QueryString("edit"), 0)
If LCase(Txt(Request.QueryString("action"))) = "new" Then
    editId = 0
    showForm = True
End If

fName = ""
fPath = ""
fPlays = 0
selArtists = ",,"
selAlbums = ",,"

If UCase(Request.ServerVariables("REQUEST_METHOD")) = "POST" Then
    op = LCase(Txt(Request.Form("op")))

    If op = "save" Then
        editId = Num(Request.Form("id"), 0)
        fName = Trim(Txt(Request.Form("song_name")))
        fPath = Trim(Txt(Request.Form("song_path")))
        fPlays = Num(Request.Form("plays"), 0)
        selArtists = "," & Txt(Request.Form("artists")) & ","
        selAlbums = "," & Txt(Request.Form("albums")) & ","
        showForm = True

        If Len(fName) = 0 Then
            errMsg = "El nombre de la cancion es obligatorio."
        ElseIf Len(fName) > 50 Then
            errMsg = "El nombre no puede superar los 50 caracteres."
        ElseIf Len(fPath) = 0 Then
            errMsg = "Debes indicar la ruta del archivo de audio."
        ElseIf Len(fPath) > 255 Then
            errMsg = "La ruta del archivo no puede superar los 255 caracteres."
        End If

        If Len(errMsg) = 0 Then
            Dim newId, ids, k
            If editId > 0 Then
                DbRun "UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ?, PLAYS = ? WHERE ID_SONG = ?", _
                      Array(Array("@n", adVarChar, 50, fName), Array("@p", adVarChar, 255, fPath), _
                            Array("@pl", adInteger, 4, fPlays), Array("@id", adInteger, 4, editId))
                newId = editId
            Else
                Set rsOne = DbRun("SET NOCOUNT ON; INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (?, ?, ?); " & _
                                  "SELECT CAST(SCOPE_IDENTITY() AS int);", _
                                  Array(Array("@n", adVarChar, 50, fName), Array("@p", adVarChar, 255, fPath), _
                                        Array("@pl", adInteger, 4, fPlays)))
                newId = Num(rsOne.Fields(0).Value, 0)
                rsOne.Close
                Set rsOne = Nothing
            End If

            ' Sincronizar artistas (TBL_PLAYER)
            DbRun "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", Array(Array("@s", adInteger, 4, newId))
            ids = Split(selArtists, ",")
            For k = 0 To UBound(ids)
                If IsNumeric(Trim(ids(k))) And Len(Trim(ids(k))) > 0 Then
                    DbRun "INSERT INTO TBL_PLAYER (ID_SONG, ID_ARTIST) VALUES (?, ?)", _
                          Array(Array("@s", adInteger, 4, newId), Array("@a", adInteger, 4, CLng(Trim(ids(k)))))
                End If
            Next

            ' Sincronizar albumes (TBL_TRACKLIST)
            DbRun "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(Array("@s", adInteger, 4, newId))
            ids = Split(selAlbums, ",")
            For k = 0 To UBound(ids)
                If IsNumeric(Trim(ids(k))) And Len(Trim(ids(k))) > 0 Then
                    DbRun "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (?, ?)", _
                          Array(Array("@al", adInteger, 4, CLng(Trim(ids(k)))), Array("@s", adInteger, 4, newId))
                End If
            Next

            DbClose
            If editId > 0 Then
                Response.Redirect BaseUrl & "songs.asp?msg=saved"
            Else
                Response.Redirect BaseUrl & "songs.asp?msg=created"
            End If
            Response.End
        End If

    ElseIf op = "delete" Then
        Dim delId
        delId = Num(Request.Form("id"), 0)
        If delId > 0 Then
            DbRun "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", Array(Array("@s", adInteger, 4, delId))
            DbRun "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(Array("@s", adInteger, 4, delId))
            DbRun "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?", Array(Array("@s", adInteger, 4, delId))
            DbRun "DELETE FROM TBL_SONG WHERE ID_SONG = ?", Array(Array("@s", adInteger, 4, delId))
        End If
        DbClose
        Response.Redirect BaseUrl & "songs.asp?msg=deleted"
        Response.End
    End If
End If

' Cargar valores para edicion
If editId > 0 And Len(errMsg) = 0 Then
    Set rsOne = DbRun("SELECT SONG_NAME, SONG_PATH, ISNULL(PLAYS, 0) AS PLAYS FROM TBL_SONG WHERE ID_SONG = ?", _
                      Array(Array("@id", adInteger, 4, editId)))
    If Not rsOne.EOF Then
        fName = Txt(rsOne("SONG_NAME"))
        fPath = Txt(rsOne("SONG_PATH"))
        fPlays = Num(rsOne("PLAYS"), 0)
        showForm = True

        selArtists = ",,"
        Set rsSel = DbRun("SELECT ID_ARTIST FROM TBL_PLAYER WHERE ID_SONG = ?", Array(Array("@s", adInteger, 4, editId)))
        Do While Not rsSel.EOF
            selArtists = selArtists & rsSel("ID_ARTIST") & ","
            rsSel.MoveNext
        Loop
        rsSel.Close
        Set rsSel = Nothing

        selAlbums = ",,"
        Set rsSel = DbRun("SELECT ID_ALBUM FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(Array("@s", adInteger, 4, editId)))
        Do While Not rsSel.EOF
            selAlbums = selAlbums & rsSel("ID_ALBUM") & ","
            rsSel.MoveNext
        Loop
        rsSel.Close
        Set rsSel = Nothing
    Else
        Response.Redirect BaseUrl & "songs.asp?msg=notfound"
        Response.End
    End If
    rsOne.Close
    Set rsOne = Nothing
End If

PageActions = "<a class=""btn btn-gold btn-sm"" href=""" & BaseUrl & "songs.asp?action=new"">" & Ico("plus", 16) & " Nueva cancion</a>"
%>
<!--#include file="includes/head.asp"-->

<%=FlashBlock()%>

<% If showForm Then %>
<section class="panel panel-form rise">
  <div class="panel-head">
    <div>
      <h2><%=IIf(editId > 0, "Editar cancion", "Registrar nueva cancion")%></h2>
      <p>Los cambios se guardan en <strong>TBL_SONG</strong>, <strong>TBL_PLAYER</strong> y <strong>TBL_TRACKLIST</strong>.</p>
    </div>
    <a class="btn btn-ghost btn-sm" href="<%=BaseUrl%>songs.asp"><%=Ico("close", 15)%> Cancelar</a>
  </div>

  <% If Len(errMsg) > 0 Then %>
  <div class="flash flash-err" style="margin-bottom:16px" role="alert">
    <span class="flash-dot"></span><span><%=H(errMsg)%></span>
  </div>
  <% End If %>

  <form method="post" action="<%=BaseUrl%>songs.asp">
    <input type="hidden" name="op" value="save">
    <input type="hidden" name="id" value="<%=editId%>">

    <div class="form-grid">
      <div class="field">
        <label for="song_name">Nombre de la cancion</label>
        <input type="text" id="song_name" name="song_name" maxlength="50" value="<%=H(fName)%>" placeholder="Adventure" required>
      </div>

      <div class="field">
        <label for="plays">Reproducciones iniciales</label>
        <input type="number" id="plays" name="plays" min="0" value="<%=fPlays%>">
      </div>

      <div class="field span-2">
        <label for="song_path">Ruta del archivo de audio</label>
        <input type="text" id="song_path" name="song_path" list="audio-files" maxlength="255" value="<%=H(fPath)%>" placeholder="~/songFiles/bensound-adventure.mp3" required>
        <datalist id="audio-files">
          <%
          On Error Resume Next
          Dim fld, fItem
          Set fld = Fso.GetFolder(Server.MapPath(BaseUrl & "assets/songFiles"))
          For Each fItem In fld.Files
              Response.Write "<option value=""~/songFiles/" & H(fItem.Name) & """></option>"
          Next
          On Error GoTo 0
          %>
        </datalist>
        <span class="hint">Usa el prefijo <code>~/songFiles/</code>. Los archivos disponibles aparecen como sugerencia.</span>
      </div>

      <div class="field">
        <label class="field-label">Artistas interpretes</label>
        <div class="check-grid">
          <%
          Set rsArt = DbRun("SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME FROM TBL_ARTIST ORDER BY ARTIST_NAME", Empty)
          If rsArt.EOF Then Response.Write "<p class=""hint"">No hay artistas registrados.</p>"
          Do While Not rsArt.EOF
          %>
          <label class="check-chip">
            <input type="checkbox" name="artists" value="<%=rsArt("ID_ARTIST")%>" <%=IIf(InStr(selArtists, "," & rsArt("ID_ARTIST") & ",") > 0, "checked", "")%>>
            <span><%=H(Trim(rsArt("ARTIST_NAME") & " " & rsArt("ARTIST_LASTNAME") & ""))%></span>
          </label>
          <%
              rsArt.MoveNext
          Loop
          rsArt.Close
          Set rsArt = Nothing
          %>
        </div>
      </div>

      <div class="field">
        <label class="field-label">Albumes que incluyen la pista</label>
        <div class="check-grid">
          <%
          Set rsAlb = DbRun("SELECT ID_ALBUM, TITLE_ALBUM, RELEASE_YEAR FROM TBL_ALBUM ORDER BY TITLE_ALBUM", Empty)
          If rsAlb.EOF Then Response.Write "<p class=""hint"">No hay albumes registrados.</p>"
          Do While Not rsAlb.EOF
          %>
          <label class="check-chip">
            <input type="checkbox" name="albums" value="<%=rsAlb("ID_ALBUM")%>" <%=IIf(InStr(selAlbums, "," & rsAlb("ID_ALBUM") & ",") > 0, "checked", "")%>>
            <span><%=H(rsAlb("TITLE_ALBUM"))%> <em style="color:var(--ink-3);font-style:normal">(<%=Num(rsAlb("RELEASE_YEAR"), 0)%>)</em></span>
          </label>
          <%
              rsAlb.MoveNext
          Loop
          rsAlb.Close
          Set rsAlb = Nothing
          %>
        </div>
      </div>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary"><%=Ico("edit", 16)%> <%=IIf(editId > 0, "Guardar cambios", "Crear cancion")%></button>
      <a class="btn btn-ghost" href="<%=BaseUrl%>songs.asp">Descartar</a>
    </div>
  </form>
</section>
<% End If %>

<section>
  <div class="section-head">
    <div>
      <h2>Listado de canciones</h2>
      <p>Gestion completa del catalogo: crear, editar y eliminar pistas.</p>
    </div>
    <div class="section-actions">
      <a class="btn btn-ghost btn-sm" href="<%=BaseUrl%>default.asp#songlist">Ver Song List publico</a>
    </div>
  </div>

  <div class="songlist" style="margin-top:14px">
    <div class="song-head" aria-hidden="true">
      <span>#</span>
      <span>Cancion</span>
      <span class="col-album">Album</span>
      <span class="col-plays">Reproducciones</span>
      <span class="col-dur">Duracion</span>
      <span style="text-align:right">Acciones</span>
    </div>

    <%
    Set rsList = DbRun( _
        "SELECT S.ID_SONG, S.SONG_NAME, S.SONG_PATH, ISNULL(S.PLAYS, 0) AS PLAYS, " & _
        "  ISNULL((SELECT STRING_AGG(A.ARTIST_NAME + ' ' + ISNULL(A.ARTIST_LASTNAME, ''), ', ') " & _
        "          FROM TBL_PLAYER P INNER JOIN TBL_ARTIST A ON A.ID_ARTIST = P.ID_ARTIST " & _
        "          WHERE P.ID_SONG = S.ID_SONG), '') AS ARTISTS, " & _
        "  ISNULL((SELECT TOP 1 AL.TITLE_ALBUM FROM TBL_TRACKLIST T INNER JOIN TBL_ALBUM AL ON AL.ID_ALBUM = T.ID_ALBUM " & _
        "          WHERE T.ID_SONG = S.ID_SONG ORDER BY AL.RELEASE_YEAR DESC), '') AS ALBUM, " & _
        "  (SELECT TOP 1 AL.ALBUM_IMAGE_PATH FROM TBL_TRACKLIST T INNER JOIN TBL_ALBUM AL ON AL.ID_ALBUM = T.ID_ALBUM " & _
        "   WHERE T.ID_SONG = S.ID_SONG ORDER BY AL.RELEASE_YEAR DESC) AS COVER " & _
        "FROM TBL_SONG S ORDER BY S.ID_SONG", Empty)

    trackJsonParts = ""
    rowIdx = 0
    If rsList.EOF Then
        Response.Write "<div class=""empty"" style=""border:0"">" & Ico("music", 26) & _
                       "<h3>El catalogo esta vacio</h3><p>Crea la primera cancion con el boton «Nueva cancion».</p></div>"
    End If
    Do While Not rsList.EOF
        Dim rName, rArtists, rAlbum, rCover, rPlays, rId, rPath
        rId = rsList("ID_SONG")
        rName = Txt(rsList("SONG_NAME"))
        rPath = Txt(rsList("SONG_PATH"))
        rArtists = Txt(rsList("ARTISTS"))
        rAlbum = Txt(rsList("ALBUM"))
        rCover = AssetUrl(rsList("COVER"), "album")
        rPlays = Num(rsList("PLAYS"), 0)
        If Len(rArtists) = 0 Then rArtists = "Sin artista asignado"
        If Len(rAlbum) = 0 Then rAlbum = "Sin album"

        If Len(trackJsonParts) > 0 Then trackJsonParts = trackJsonParts & ","
        trackJsonParts = trackJsonParts & JsonSong(rId, rName, rArtists, rAlbum, AssetUrl(rPath, "song"), rCover, rPlays)
    %>
    <article class="song-row" data-index="<%=rowIdx%>" data-song="<%=rId%>">
      <div class="song-index">
        <span class="num"><%=Right("0" & (rowIdx + 1), 2)%></span>
        <button type="button" class="play-mini" data-play="<%=rowIdx%>" aria-label="Reproducir <%=H(rName)%>"><%=Ico("play", 14)%></button>
      </div>
      <div class="song-main">
        <img class="song-cover" src="<%=rCover%>" alt="" loading="lazy">
        <div class="song-text">
          <span class="song-title"><%=H(rName)%></span>
          <span class="song-sub"><%=H(rArtists)%></span>
        </div>
      </div>
      <div class="song-cell col-album truncate"><%=H(rAlbum)%></div>
      <div class="song-cell col-plays">
        <span class="song-plays"><%=Ico("clock", 13)%> <span class="plays-count"><%=rPlays%></span></span>
      </div>
      <div class="song-cell col-dur"><span class="dur" data-dur="<%=rowIdx%>">--:--</span></div>
      <div class="song-actions">
        <span class="eq" aria-hidden="true"><i></i><i></i><i></i><i></i></span>
        <a class="icon-btn" href="<%=BaseUrl%>songs.asp?edit=<%=rId%>" title="Editar"><%=Ico("edit", 16)%></a>
        <form method="post" action="<%=BaseUrl%>songs.asp" style="display:inline" onsubmit="return confirm('Eliminar la cancion «<%=H(Replace(rName, "'", ""))%>»? Tambien se quitara de albumes y playlists.');">
          <input type="hidden" name="op" value="delete">
          <input type="hidden" name="id" value="<%=rId%>">
          <button type="submit" class="icon-btn is-danger" title="Eliminar"><%=Ico("trash", 16)%></button>
        </form>
      </div>
    </article>
    <%
        rowIdx = rowIdx + 1
        rsList.MoveNext
    Loop
    rsList.Close
    Set rsList = Nothing
    TrackJson = trackJsonParts
    %>
  </div>
</section>

<!--#include file="includes/foot.asp"-->
