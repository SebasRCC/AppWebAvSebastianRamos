<%@ LANGUAGE="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' ============================================================
'  albums.asp · CRUD de albumes + tracklist (solo administrador)
' ============================================================
RequireAdmin

PageTitle  = "Albumes"
PageKicker = "Catalogo · administracion"
ActiveNav  = "albums"

Dim op, editId, showForm, errMsg, fTitle, fYear, fImage, selSongs, rsList, rsOne, rsSel, rsSongs

showForm = False
errMsg = ""
editId = Num(Request.QueryString("edit"), 0)
If LCase(Txt(Request.QueryString("action"))) = "new" Then
    editId = 0
    showForm = True
End If

fTitle = ""
fYear = Year(Date)
fImage = ""
selSongs = ",,"

If UCase(Request.ServerVariables("REQUEST_METHOD")) = "POST" Then
    op = LCase(Txt(Request.Form("op")))

    If op = "save" Then
        editId = Num(Request.Form("id"), 0)
        fTitle = Trim(Txt(Request.Form("title_album")))
        fYear = Num(Request.Form("release_year"), 0)
        fImage = Trim(Txt(Request.Form("album_image")))
        selSongs = "," & Txt(Request.Form("songs")) & ","
        showForm = True

        If Len(fTitle) = 0 Then
            errMsg = "El titulo del album es obligatorio."
        ElseIf Len(fTitle) > 50 Then
            errMsg = "El titulo no puede superar los 50 caracteres."
        ElseIf fYear < 1900 Or fYear > 2100 Then
            errMsg = "El ano de lanzamiento debe estar entre 1900 y 2100."
        ElseIf Len(fImage) > 255 Then
            errMsg = "La ruta de la imagen no puede superar los 255 caracteres."
        End If

        If Len(errMsg) = 0 Then
            Dim newId, ids, k
            If editId > 0 Then
                DbRun "UPDATE TBL_ALBUM SET TITLE_ALBUM = ?, RELEASE_YEAR = ?, ALBUM_IMAGE_PATH = ? WHERE ID_ALBUM = ?", _
                      Array(Array("@t", adVarChar, 50, fTitle), Array("@y", adInteger, 4, fYear), _
                            Array("@i", adVarChar, 255, fImage), Array("@id", adInteger, 4, editId))
                newId = editId
            Else
                Set rsOne = DbRun("SET NOCOUNT ON; INSERT INTO TBL_ALBUM (TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH) VALUES (?, ?, ?); " & _
                                  "SELECT CAST(SCOPE_IDENTITY() AS int);", _
                                  Array(Array("@t", adVarChar, 50, fTitle), Array("@y", adInteger, 4, fYear), _
                                        Array("@i", adVarChar, 255, fImage)))
                newId = Num(rsOne.Fields(0).Value, 0)
                rsOne.Close
                Set rsOne = Nothing
            End If

            DbRun "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", Array(Array("@a", adInteger, 4, newId))
            ids = Split(selSongs, ",")
            For k = 0 To UBound(ids)
                If IsNumeric(Trim(ids(k))) And Len(Trim(ids(k))) > 0 Then
                    DbRun "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (?, ?)", _
                          Array(Array("@a", adInteger, 4, newId), Array("@s", adInteger, 4, CLng(Trim(ids(k)))))
                End If
            Next

            DbClose
            If editId > 0 Then
                Response.Redirect BaseUrl & "albums.asp?msg=saved"
            Else
                Response.Redirect BaseUrl & "albums.asp?msg=created"
            End If
            Response.End
        End If

    ElseIf op = "delete" Then
        Dim delId
        delId = Num(Request.Form("id"), 0)
        If delId > 0 Then
            DbRun "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", Array(Array("@a", adInteger, 4, delId))
            DbRun "DELETE FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(Array("@a", adInteger, 4, delId))
        End If
        DbClose
        Response.Redirect BaseUrl & "albums.asp?msg=deleted"
        Response.End
    End If
End If

If editId > 0 And Len(errMsg) = 0 Then
    Set rsOne = DbRun("SELECT TITLE_ALBUM, ISNULL(RELEASE_YEAR, 0) AS RELEASE_YEAR, ALBUM_IMAGE_PATH FROM TBL_ALBUM WHERE ID_ALBUM = ?", _
                      Array(Array("@id", adInteger, 4, editId)))
    If Not rsOne.EOF Then
        fTitle = Txt(rsOne("TITLE_ALBUM"))
        fYear = Num(rsOne("RELEASE_YEAR"), Year(Date))
        fImage = Txt(rsOne("ALBUM_IMAGE_PATH"))
        showForm = True

        selSongs = ",,"
        Set rsSel = DbRun("SELECT ID_SONG FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", Array(Array("@a", adInteger, 4, editId)))
        Do While Not rsSel.EOF
            selSongs = selSongs & rsSel("ID_SONG") & ","
            rsSel.MoveNext
        Loop
        rsSel.Close
        Set rsSel = Nothing
    Else
        Response.Redirect BaseUrl & "albums.asp?msg=notfound"
        Response.End
    End If
    rsOne.Close
    Set rsOne = Nothing
End If

PageActions = "<a class=""btn btn-gold btn-sm"" href=""" & BaseUrl & "albums.asp?action=new"">" & Ico("plus", 16) & " Nuevo album</a>"
%>
<!--#include file="includes/head.asp"-->

<%=FlashBlock()%>

<% If showForm Then %>
<section class="panel panel-form rise">
  <div class="panel-head">
    <div>
      <h2><%=IIf(editId > 0, "Editar album", "Registrar nuevo album")%></h2>
      <p>El tracklist se almacena en <strong>TBL_TRACKLIST</strong> (relacion album · cancion).</p>
    </div>
    <a class="btn btn-ghost btn-sm" href="<%=BaseUrl%>albums.asp"><%=Ico("close", 15)%> Cancelar</a>
  </div>

  <% If Len(errMsg) > 0 Then %>
  <div class="flash flash-err" style="margin-bottom:16px" role="alert">
    <span class="flash-dot"></span><span><%=H(errMsg)%></span>
  </div>
  <% End If %>

  <form method="post" action="<%=BaseUrl%>albums.asp">
    <input type="hidden" name="op" value="save">
    <input type="hidden" name="id" value="<%=editId%>">

    <div class="form-grid">
      <div class="field">
        <label for="title_album">Titulo del album</label>
        <input type="text" id="title_album" name="title_album" maxlength="50" value="<%=H(fTitle)%>" placeholder="Rock Album" required>
      </div>
      <div class="field">
        <label for="release_year">Ano de lanzamiento</label>
        <input type="number" id="release_year" name="release_year" min="1900" max="2100" value="<%=fYear%>">
      </div>
      <div class="field span-2">
        <label for="album_image">Portada del album</label>
        <input type="text" id="album_image" name="album_image" list="album-images" maxlength="255" value="<%=H(fImage)%>" placeholder="~/albumImages/album1.png">
        <datalist id="album-images">
          <%
          On Error Resume Next
          Dim fldAl, fAl
          Set fldAl = Fso.GetFolder(Server.MapPath(BaseUrl & "assets/albumImages"))
          For Each fAl In fldAl.Files
              Response.Write "<option value=""~/albumImages/" & H(fAl.Name) & """></option>"
          Next
          On Error GoTo 0
          %>
        </datalist>
        <span class="hint">Si la ruta no existe se mostrara la portada por defecto.</span>
      </div>

      <div class="field span-2">
        <label class="field-label">Tracklist · canciones incluidas</label>
        <div class="check-grid">
          <%
          Set rsSongs = DbRun("SELECT ID_SONG, SONG_NAME FROM TBL_SONG ORDER BY SONG_NAME", Empty)
          If rsSongs.EOF Then Response.Write "<p class=""hint"">No hay canciones registradas.</p>"
          Do While Not rsSongs.EOF
          %>
          <label class="check-chip">
            <input type="checkbox" name="songs" value="<%=rsSongs("ID_SONG")%>" <%=IIf(InStr(selSongs, "," & rsSongs("ID_SONG") & ",") > 0, "checked", "")%>>
            <span><%=H(rsSongs("SONG_NAME"))%></span>
          </label>
          <%
              rsSongs.MoveNext
          Loop
          rsSongs.Close
          Set rsSongs = Nothing
          %>
        </div>
      </div>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary"><%=Ico("edit", 16)%> <%=IIf(editId > 0, "Guardar cambios", "Crear album")%></button>
      <a class="btn btn-ghost" href="<%=BaseUrl%>albums.asp">Descartar</a>
    </div>
  </form>
</section>
<% End If %>

<section>
  <div class="section-head">
    <div>
      <h2>Albumes del catalogo</h2>
      <p>Cada album agrupa canciones mediante su tracklist.</p>
    </div>
  </div>

  <%
  Set rsList = DbRun( _
      "SELECT AL.ID_ALBUM, AL.TITLE_ALBUM, AL.RELEASE_YEAR, AL.ALBUM_IMAGE_PATH, " & _
      "  (SELECT COUNT(*) FROM TBL_TRACKLIST T WHERE T.ID_ALBUM = AL.ID_ALBUM) AS TRACKS " & _
      "FROM TBL_ALBUM AL ORDER BY AL.RELEASE_YEAR DESC, AL.TITLE_ALBUM", Empty)

  If rsList.EOF Then
      Response.Write "<div class=""empty"" style=""margin-top:14px"">" & Ico("grid", 26) & _
                     "<h3>Sin albumes registrados</h3><p>Crea el primer album del catalogo.</p></div>"
  Else
  %>
  <div class="card-grid" style="margin-top:14px">
    <%
    Do While Not rsList.EOF
        Dim bId, bTitle, bYear, bImg, bTracks
        bId = rsList("ID_ALBUM")
        bTitle = Txt(rsList("TITLE_ALBUM"))
        bYear = Num(rsList("RELEASE_YEAR"), 0)
        bImg = AssetUrl(rsList("ALBUM_IMAGE_PATH"), "album")
        bTracks = Num(rsList("TRACKS"), 0)
    %>
    <article class="media-card">
      <div class="media-figure">
        <img src="<%=bImg%>" alt="Portada de <%=H(bTitle)%>" loading="lazy">
        <span class="media-badge"><%=bTracks%> pistas</span>
      </div>
      <div class="media-body">
        <h3><%=H(bTitle)%></h3>
        <p><%=IIf(bYear > 0, "Lanzado en " & bYear, "Ano no registrado")%></p>
        <div class="media-actions">
          <a class="btn btn-ghost btn-sm" href="<%=BaseUrl%>albums.asp?edit=<%=bId%>"><%=Ico("edit", 14)%> Editar</a>
          <span class="spacer"></span>
          <form method="post" action="<%=BaseUrl%>albums.asp" style="display:inline" onsubmit="return confirm('Eliminar el album «<%=H(Replace(bTitle, "'", ""))%>»? Su tracklist tambien se eliminara.');">
            <input type="hidden" name="op" value="delete">
            <input type="hidden" name="id" value="<%=bId%>">
            <button type="submit" class="icon-btn is-danger" title="Eliminar"><%=Ico("trash", 16)%></button>
          </form>
        </div>
      </div>
    </article>
    <%
        rsList.MoveNext
    Loop
    %>
  </div>
  <%
  End If
  rsList.Close
  Set rsList = Nothing
  %>
</section>

<!--#include file="includes/foot.asp"-->
