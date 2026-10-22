<%@ LANGUAGE="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' ============================================================
'  playlist.asp · Detalle de una playlist + gestion de canciones
' ============================================================
RequireLogin

Dim plId, addTo, addSong, backTo, isOwner, rsPl, rsSongs, rsAvail
Dim plTitle, plType, plPhoto, plDate, plOwner, plOwnerId, trackJsonParts, rowIdx, songCount

plId = Num(Request.QueryString("id"), 0)
addTo = Num(Request.QueryString("addto"), 0)
addSong = Num(Request.QueryString("song"), 0)
backTo = LCase(Txt(Request.QueryString("back")))

' --- Accion rapida desde el Song List: agregar cancion a una playlist ---
If addTo > 0 And addSong > 0 Then
    Dim ownA, dup
    ownA = Num(DbScalar("SELECT ID_USER FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", _
           Array(Array("@p", adInteger, 4, addTo))), 0)
    If ownA = 0 Then
        DbClose
        Response.Redirect BaseUrl & "playlists.asp?msg=notfound"
        Response.End
    End If
    If Not IsAdmin() Then
        If ownA <> CLng(Session("UserID")) Then
            DbClose
            Response.Redirect BaseUrl & "playlists.asp?msg=denied"
            Response.End
        End If
    End If
    dup = Num(DbScalar("SELECT COUNT(*) FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?", _
           Array(Array("@p", adInteger, 4, addTo), Array("@s", adInteger, 4, addSong))), 0)
    If dup = 0 Then
        DbRun "INSERT INTO TBL_PLAYLIST_SONG (ID_PLAYLIST, ID_SONG) VALUES (?, ?)", _
              Array(Array("@p", adInteger, 4, addTo), Array("@s", adInteger, 4, addSong))
    End If
    DbClose
    If backTo = "home" Then
        Response.Redirect BaseUrl & "default.asp?msg=" & IIf(dup = 0, "added", "invalid") & "#songlist"
    Else
        Response.Redirect BaseUrl & "playlist.asp?id=" & addTo & "&msg=" & IIf(dup = 0, "added", "invalid")
    End If
    Response.End
End If

If plId = 0 Then
    DbClose
    Response.Redirect BaseUrl & "playlists.asp"
    Response.End
End If

' --- Cargar playlist ---
Set rsPl = DbRun("SELECT P.ID_PLAYLIST, P.TITLE, P.[TYPE], P.PHOTO, P.CREATION_DATE, P.ID_USER, U.USERNAME " & _
                 "FROM TBL_PLAYLIST P INNER JOIN TBL_USER U ON U.ID_USER = P.ID_USER WHERE P.ID_PLAYLIST = ?", _
                 Array(Array("@p", adInteger, 4, plId)))
If rsPl.EOF Then
    rsPl.Close
    Set rsPl = Nothing
    DbClose
    Response.Redirect BaseUrl & "playlists.asp?msg=notfound"
    Response.End
End If

plTitle = Txt(rsPl("TITLE"))
plType = Num(rsPl("TYPE"), 0)
plPhoto = AssetUrl(rsPl("PHOTO"), "playlist")
plDate = rsPl("CREATION_DATE")
plOwner = Txt(rsPl("USERNAME"))
plOwnerId = Num(rsPl("ID_USER"), 0)
rsPl.Close
Set rsPl = Nothing

isOwner = (plOwnerId = CLng(Session("UserID")))
If Not isOwner And Not IsAdmin() Then
    DbClose
    Response.Redirect BaseUrl & "playlists.asp?msg=denied"
    Response.End
End If

' --- Acciones POST: agregar / quitar cancion ---
If UCase(Request.ServerVariables("REQUEST_METHOD")) = "POST" Then
    Dim opP, songP, dupP
    opP = LCase(Txt(Request.Form("op")))

    If opP = "add" Then
        songP = Num(Request.Form("song_id"), 0)
        If songP > 0 Then
            dupP = Num(DbScalar("SELECT COUNT(*) FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?", _
                   Array(Array("@p", adInteger, 4, plId), Array("@s", adInteger, 4, songP))), 0)
            If dupP = 0 Then
                DbRun "INSERT INTO TBL_PLAYLIST_SONG (ID_PLAYLIST, ID_SONG) VALUES (?, ?)", _
                      Array(Array("@p", adInteger, 4, plId), Array("@s", adInteger, 4, songP))
                DbClose
                Response.Redirect BaseUrl & "playlist.asp?id=" & plId & "&msg=added"
                Response.End
            Else
                DbClose
                Response.Redirect BaseUrl & "playlist.asp?id=" & plId & "&msg=invalid"
                Response.End
            End If
        End If

    ElseIf opP = "remove" Then
        songP = Num(Request.Form("song_id"), 0)
        If songP > 0 Then
            DbRun "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?", _
                  Array(Array("@p", adInteger, 4, plId), Array("@s", adInteger, 4, songP))
        End If
        DbClose
        Response.Redirect BaseUrl & "playlist.asp?id=" & plId & "&msg=removed"
        Response.End
    End If
End If

songCount = Num(DbScalar("SELECT COUNT(*) FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ?", _
            Array(Array("@p", adInteger, 4, plId))), 0)

PageTitle  = plTitle
PageKicker = "Playlist · " & IIf(plType = 1, "privada", "publica")
ActiveNav  = "playlists"

PageActions = "<a class=""btn btn-ghost btn-sm"" href=""" & BaseUrl & "playlists.asp"">" & Ico("arrow-left", 15) & " Volver</a>" & _
              "<a class=""btn btn-ghost btn-sm"" href=""" & BaseUrl & "playlists.asp?edit=" & plId & """>" & Ico("edit", 15) & " Editar datos</a>"
%>
<!--#include file="includes/head.asp"-->

<%=FlashBlock()%>

<section class="detail-hero rise">
  <img class="detail-cover" src="<%=plPhoto%>" alt="Portada de <%=H(plTitle)%>">
  <div class="detail-meta">
    <span class="welcome-kicker"><%=Ico("list", 12)%> Coleccion musical</span>
    <h2><%=H(plTitle)%></h2>
    <p><%=songCount%> canciones · creada el <%=FormatDateTime(plDate, 2)%></p>
    <div class="detail-tags">
      <span class="chip <%=IIf(plType = 1, "", "chip-gold")%>"><%=IIf(plType = 1, "Privada", "Publica")%></span>
      <span class="chip"><%=Ico("user", 12)%> <%=H(plOwner)%></span>
      <span class="chip"><%=Ico("music", 12)%> <%=songCount%> pistas</span>
    </div>
    <div class="detail-actions">
      <% If songCount > 0 Then %>
      <button type="button" class="btn btn-gold" data-play="0"><%=Ico("play", 16)%> Reproducir playlist</button>
      <% End If %>
      <a class="btn btn-ghost" href="<%=BaseUrl%>default.asp#songlist"><%=Ico("music", 16)%> Buscar mas canciones</a>
    </div>
  </div>
</section>

<section class="panel" style="padding:18px 22px">
  <div class="panel-head" style="margin-bottom:14px">
    <div>
      <h2 style="font-size:17px">Agregar cancion a esta playlist</h2>
      <p>Se inserta en <strong>TBL_PLAYLIST_SONG</strong> sin duplicados.</p>
    </div>
  </div>
  <form method="post" action="<%=BaseUrl%>playlist.asp?id=<%=plId%>" style="display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end">
    <input type="hidden" name="op" value="add">
    <div class="field" style="flex:1;min-width:240px">
      <label for="song_id">Cancion disponible</label>
      <select id="song_id" name="song_id" required>
        <option value="">Selecciona una cancion...</option>
        <%
        Set rsAvail = DbRun("SELECT S.ID_SONG, S.SONG_NAME FROM TBL_SONG S " & _
                            "WHERE NOT EXISTS (SELECT 1 FROM TBL_PLAYLIST_SONG PS WHERE PS.ID_PLAYLIST = ? AND PS.ID_SONG = S.ID_SONG) " & _
                            "ORDER BY S.SONG_NAME", Array(Array("@p", adInteger, 4, plId)))
        If rsAvail.EOF Then Response.Write "<option value="""" disabled>Todas las canciones ya estan en la playlist</option>"
        Do While Not rsAvail.EOF
            Response.Write "<option value=""" & rsAvail("ID_SONG") & """>" & H(rsAvail("SONG_NAME")) & "</option>"
            rsAvail.MoveNext
        Loop
        rsAvail.Close
        Set rsAvail = Nothing
        %>
      </select>
    </div>
    <button type="submit" class="btn btn-primary"><%=Ico("plus", 16)%> Agregar</button>
  </form>
</section>

<section>
  <div class="section-head">
    <div>
      <h2>Canciones de la playlist</h2>
      <p>Quita pistas con el boton de la papelera; la cancion permanece en el catalogo.</p>
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
    Set rsSongs = DbRun( _
        "SELECT S.ID_SONG, S.SONG_NAME, S.SONG_PATH, ISNULL(S.PLAYS, 0) AS PLAYS, " & _
        "  ISNULL((SELECT STRING_AGG(A.ARTIST_NAME + ' ' + ISNULL(A.ARTIST_LASTNAME, ''), ', ') " & _
        "          FROM TBL_PLAYER P INNER JOIN TBL_ARTIST A ON A.ID_ARTIST = P.ID_ARTIST " & _
        "          WHERE P.ID_SONG = S.ID_SONG), '') AS ARTISTS, " & _
        "  ISNULL((SELECT TOP 1 AL.TITLE_ALBUM FROM TBL_TRACKLIST T INNER JOIN TBL_ALBUM AL ON AL.ID_ALBUM = T.ID_ALBUM " & _
        "          WHERE T.ID_SONG = S.ID_SONG ORDER BY AL.RELEASE_YEAR DESC), '') AS ALBUM, " & _
        "  (SELECT TOP 1 AL.ALBUM_IMAGE_PATH FROM TBL_TRACKLIST T INNER JOIN TBL_ALBUM AL ON AL.ID_ALBUM = T.ID_ALBUM " & _
        "   WHERE T.ID_SONG = S.ID_SONG ORDER BY AL.RELEASE_YEAR DESC) AS COVER " & _
        "FROM TBL_PLAYLIST_SONG PS INNER JOIN TBL_SONG S ON S.ID_SONG = PS.ID_SONG " & _
        "WHERE PS.ID_PLAYLIST = ? ORDER BY S.SONG_NAME", Array(Array("@p", adInteger, 4, plId)))

    trackJsonParts = ""
    rowIdx = 0
    If rsSongs.EOF Then
        Response.Write "<div class=""empty"" style=""border:0"">" & Ico("music", 26) & _
                       "<h3>Esta playlist esta vacia</h3><p>Agrega canciones con el selector de arriba o desde el Song List.</p></div>"
    End If
    Do While Not rsSongs.EOF
        Dim qId, qName, qPath, qArtists, qAlbum, qCover, qPlays
        qId = rsSongs("ID_SONG")
        qName = Txt(rsSongs("SONG_NAME"))
        qPath = Txt(rsSongs("SONG_PATH"))
        qArtists = Txt(rsSongs("ARTISTS"))
        qAlbum = Txt(rsSongs("ALBUM"))
        qCover = AssetUrl(rsSongs("COVER"), "album")
        qPlays = Num(rsSongs("PLAYS"), 0)
        If Len(qArtists) = 0 Then qArtists = "Artista desconocido"
        If Len(qAlbum) = 0 Then qAlbum = "Sin album"

        If Len(trackJsonParts) > 0 Then trackJsonParts = trackJsonParts & ","
        trackJsonParts = trackJsonParts & JsonSong(qId, qName, qArtists, qAlbum, AssetUrl(qPath, "song"), qCover, qPlays)
    %>
    <article class="song-row" data-index="<%=rowIdx%>" data-song="<%=qId%>">
      <div class="song-index">
        <span class="num"><%=Right("0" & (rowIdx + 1), 2)%></span>
        <button type="button" class="play-mini" data-play="<%=rowIdx%>" aria-label="Reproducir <%=H(qName)%>"><%=Ico("play", 14)%></button>
      </div>
      <div class="song-main">
        <img class="song-cover" src="<%=qCover%>" alt="" loading="lazy">
        <div class="song-text">
          <span class="song-title"><%=H(qName)%></span>
          <span class="song-sub"><%=H(qArtists)%></span>
        </div>
      </div>
      <div class="song-cell col-album truncate"><%=H(qAlbum)%></div>
      <div class="song-cell col-plays">
        <span class="song-plays"><%=Ico("clock", 13)%> <span class="plays-count"><%=qPlays%></span></span>
      </div>
      <div class="song-cell col-dur"><span class="dur" data-dur="<%=rowIdx%>">--:--</span></div>
      <div class="song-actions">
        <span class="eq" aria-hidden="true"><i></i><i></i><i></i><i></i></span>
        <form method="post" action="<%=BaseUrl%>playlist.asp?id=<%=plId%>" style="display:inline" onsubmit="return confirm('Quitar «<%=H(Replace(qName, "'", ""))%>» de esta playlist?');">
          <input type="hidden" name="op" value="remove">
          <input type="hidden" name="song_id" value="<%=qId%>">
          <button type="submit" class="icon-btn is-danger" title="Quitar de la playlist"><%=Ico("trash", 16)%></button>
        </form>
      </div>
    </article>
    <%
        rowIdx = rowIdx + 1
        rsSongs.MoveNext
    Loop
    rsSongs.Close
    Set rsSongs = Nothing
    TrackJson = trackJsonParts
    %>
  </div>
</section>

<!--#include file="includes/foot.asp"-->
