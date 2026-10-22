<%@ LANGUAGE="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' ============================================================
'  playlists.asp · CRUD de playlists (usuario normal y admin)
'  El usuario normal solo administra sus propias playlists.
' ============================================================
RequireLogin

PageTitle  = "Playlists"
PageKicker = IIf(IsAdmin(), "Colecciones · administracion", "Mi musica")
ActiveNav  = "playlists"

Dim op, editId, showForm, errMsg, fTitle, fType, fPhoto, fDate, rsList, rsOne, ownerCheck

showForm = False
errMsg = ""
editId = Num(Request.QueryString("edit"), 0)
If LCase(Txt(Request.QueryString("action"))) = "new" Then
    editId = 0
    showForm = True
End If

fTitle = ""
fType = 0
fPhoto = "~/playlistImages/default.jpg"
fDate = Date()

' Solo el dueno o un admin puede editar/eliminar
If editId > 0 Then
    Dim ownerId
    ownerId = Num(DbScalar("SELECT ID_USER FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", _
                 Array(Array("@p", adInteger, 4, editId))), 0)
    If ownerId = 0 Then
        DbClose
        Response.Redirect BaseUrl & "playlists.asp?msg=notfound"
        Response.End
    End If
    If Not IsAdmin() Then
        If ownerId <> CLng(Session("UserID")) Then
            DbClose
            Response.Redirect BaseUrl & "playlists.asp?msg=denied"
            Response.End
        End If
    End If
End If

If UCase(Request.ServerVariables("REQUEST_METHOD")) = "POST" Then
    op = LCase(Txt(Request.Form("op")))

    If op = "save" Then
        editId = Num(Request.Form("id"), 0)
        fTitle = Trim(Txt(Request.Form("title")))
        fType = Num(Request.Form("pl_type"), 0)
        fPhoto = Trim(Txt(Request.Form("photo")))
        fDate = Txt(Request.Form("creation_date"))
        showForm = True

        If Len(fTitle) = 0 Then
            errMsg = "El titulo de la playlist es obligatorio."
        ElseIf Len(fTitle) > 50 Then
            errMsg = "El titulo no puede superar los 50 caracteres."
        ElseIf Len(fPhoto) > 255 Then
            errMsg = "La ruta de la imagen no puede superar los 255 caracteres."
        ElseIf Not IsDate(fDate) Then
            errMsg = "La fecha de creacion no es valida."
        End If

        ' Verificar propiedad en edicion
        If editId > 0 And Len(errMsg) = 0 Then
            Dim ownerNow
            ownerNow = Num(DbScalar("SELECT ID_USER FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", _
                       Array(Array("@p", adInteger, 4, editId))), 0)
            If ownerNow = 0 Then
                errMsg = "La playlist indicada no existe."
            ElseIf Not IsAdmin() Then
                If ownerNow <> CLng(Session("UserID")) Then errMsg = "No puedes editar playlists de otro usuario."
            End If
        End If

        If Len(errMsg) = 0 Then
            If editId > 0 Then
                DbRun "UPDATE TBL_PLAYLIST SET TITLE = ?, [TYPE] = ?, PHOTO = ?, CREATION_DATE = ? WHERE ID_PLAYLIST = ?", _
                      Array(Array("@t", adVarChar, 50, fTitle), Array("@ty", adInteger, 4, fType), _
                            Array("@ph", adVarChar, 255, fPhoto), Array("@d", adDBTimeStamp, 8, CDate(fDate)), _
                            Array("@id", adInteger, 4, editId))
            Else
                DbRun "INSERT INTO TBL_PLAYLIST (ID_USER, TITLE, CREATION_DATE, [TYPE], PHOTO) VALUES (?, ?, ?, ?, ?)", _
                      Array(Array("@u", adInteger, 4, Session("UserID")), Array("@t", adVarChar, 50, fTitle), _
                            Array("@d", adDBTimeStamp, 8, CDate(fDate)), Array("@ty", adInteger, 4, fType), _
                            Array("@ph", adVarChar, 255, fPhoto))
            End If
            DbClose
            If editId > 0 Then
                Response.Redirect BaseUrl & "playlists.asp?msg=saved"
            Else
                Response.Redirect BaseUrl & "playlists.asp?msg=created"
            End If
            Response.End
        End If

    ElseIf op = "delete" Then
        Dim delId, delOwner
        delId = Num(Request.Form("id"), 0)
        If delId > 0 Then
            delOwner = Num(DbScalar("SELECT ID_USER FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", _
                       Array(Array("@p", adInteger, 4, delId))), 0)
            If delOwner > 0 And (IsAdmin() Or delOwner = CLng(Session("UserID"))) Then
                DbRun "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ?", Array(Array("@p", adInteger, 4, delId))
                DbRun "DELETE FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(Array("@p", adInteger, 4, delId))
            End If
        End If
        DbClose
        Response.Redirect BaseUrl & "playlists.asp?msg=deleted"
        Response.End
    End If
End If

If editId > 0 And Len(errMsg) = 0 Then
    Set rsOne = DbRun("SELECT TITLE, [TYPE], PHOTO, CREATION_DATE FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", _
                      Array(Array("@p", adInteger, 4, editId)))
    If Not rsOne.EOF Then
        fTitle = Txt(rsOne("TITLE"))
        fType = Num(rsOne("TYPE"), 0)
        fPhoto = Txt(rsOne("PHOTO"))
        fDate = rsOne("CREATION_DATE")
        showForm = True
    Else
        Response.Redirect BaseUrl & "playlists.asp?msg=notfound"
        Response.End
    End If
    rsOne.Close
    Set rsOne = Nothing
End If

PageActions = "<a class=""btn btn-gold btn-sm"" href=""" & BaseUrl & "playlists.asp?action=new"">" & Ico("plus", 16) & " Nueva playlist</a>"
%>
<!--#include file="includes/head.asp"-->

<%=FlashBlock()%>

<% If showForm Then %>
<section class="panel panel-form rise">
  <div class="panel-head">
    <div>
      <h2><%=IIf(editId > 0, "Editar playlist", "Crear nueva playlist")%></h2>
      <p>El tipo (publica o privada) se toma del catalogo <strong>TBL_CATALOG</strong>.</p>
    </div>
    <a class="btn btn-ghost btn-sm" href="<%=BaseUrl%>playlists.asp"><%=Ico("close", 15)%> Cancelar</a>
  </div>

  <% If Len(errMsg) > 0 Then %>
  <div class="flash flash-err" style="margin-bottom:16px" role="alert">
    <span class="flash-dot"></span><span><%=H(errMsg)%></span>
  </div>
  <% End If %>

  <form method="post" action="<%=BaseUrl%>playlists.asp">
    <input type="hidden" name="op" value="save">
    <input type="hidden" name="id" value="<%=editId%>">

    <div class="form-grid">
      <div class="field">
        <label for="title">Titulo de la playlist</label>
        <input type="text" id="title" name="title" maxlength="50" value="<%=H(fTitle)%>" placeholder="Mis favoritas de otono" required>
      </div>
      <div class="field">
        <label for="pl_type">Visibilidad</label>
        <select id="pl_type" name="pl_type">
          <option value="0" <%=IIf(fType = 0, "selected", "")%>>Publica · visible para la comunidad</option>
          <option value="1" <%=IIf(fType = 1, "selected", "")%>>Privada · solo para mi</option>
        </select>
      </div>
      <div class="field">
        <label for="creation_date">Fecha de creacion</label>
        <input type="date" id="creation_date" name="creation_date" value="<%=IsoDate(fDate)%>" required>
      </div>
      <div class="field">
        <label for="photo">Portada</label>
        <input type="text" id="photo" name="photo" list="playlist-images" maxlength="255" value="<%=H(fPhoto)%>" placeholder="~/playlistImages/playlist1.png">
        <datalist id="playlist-images">
          <%
          On Error Resume Next
          Dim fldP, fP
          Set fldP = Fso.GetFolder(Server.MapPath(BaseUrl & "assets/playlistImages"))
          For Each fP In fldP.Files
              Response.Write "<option value=""~/playlistImages/" & H(fP.Name) & """></option>"
          Next
          On Error GoTo 0
          %>
        </datalist>
      </div>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary"><%=Ico("edit", 16)%> <%=IIf(editId > 0, "Guardar cambios", "Crear playlist")%></button>
      <a class="btn btn-ghost" href="<%=BaseUrl%>playlists.asp">Descartar</a>
    </div>
  </form>
</section>
<% End If %>

<section>
  <div class="section-head">
    <div>
      <h2><%=IIf(IsAdmin(), "Todas las playlists", "Mis playlists")%></h2>
      <p><%=IIf(IsAdmin(), "Como administrador puedes revisar y depurar las colecciones de todos los usuarios.", "Crea, edita y elimina tus propias colecciones de musica.")%></p>
    </div>
  </div>

  <%
  If IsAdmin() Then
      Set rsList = DbRun( _
          "SELECT P.ID_PLAYLIST, P.TITLE, P.[TYPE], P.PHOTO, P.CREATION_DATE, U.USERNAME, " & _
          "  (SELECT COUNT(*) FROM TBL_PLAYLIST_SONG PS WHERE PS.ID_PLAYLIST = P.ID_PLAYLIST) AS TRACKS " & _
          "FROM TBL_PLAYLIST P INNER JOIN TBL_USER U ON U.ID_USER = P.ID_USER " & _
          "ORDER BY P.ID_PLAYLIST DESC", Empty)
  Else
      Set rsList = DbRun( _
          "SELECT P.ID_PLAYLIST, P.TITLE, P.[TYPE], P.PHOTO, P.CREATION_DATE, U.USERNAME, " & _
          "  (SELECT COUNT(*) FROM TBL_PLAYLIST_SONG PS WHERE PS.ID_PLAYLIST = P.ID_PLAYLIST) AS TRACKS " & _
          "FROM TBL_PLAYLIST P INNER JOIN TBL_USER U ON U.ID_USER = P.ID_USER " & _
          "WHERE P.ID_USER = ? ORDER BY P.ID_PLAYLIST DESC", _
          Array(Array("@u", adInteger, 4, Session("UserID"))))
  End If

  If rsList.EOF Then
      Response.Write "<div class=""empty"" style=""margin-top:14px"">" & Ico("list", 26) & _
                     "<h3>Aun no tienes playlists</h3><p>Crea tu primera coleccion y agrega canciones desde el Song List.</p>" & _
                     "<a class=""btn btn-gold btn-sm"" href=""" & BaseUrl & "playlists.asp?action=new"">Crear mi primera playlist</a></div>"
  Else
  %>
  <div class="card-grid" style="margin-top:14px">
    <%
    Do While Not rsList.EOF
        Dim pId, pTitle, pType, pPhoto, pTracks, pOwner, pPriv
        pId = rsList("ID_PLAYLIST")
        pTitle = Txt(rsList("TITLE"))
        pType = Num(rsList("TYPE"), 0)
        pPhoto = AssetUrl(rsList("PHOTO"), "playlist")
        pTracks = Num(rsList("TRACKS"), 0)
        pOwner = Txt(rsList("USERNAME"))
        pPriv = (pType = 1)
    %>
    <article class="media-card">
      <a class="media-figure" href="<%=BaseUrl%>playlist.asp?id=<%=pId%>">
        <img src="<%=pPhoto%>" alt="Portada de <%=H(pTitle)%>" loading="lazy">
        <span class="media-badge <%=IIf(pPriv, "is-private", "")%>"><%=IIf(pPriv, "Privada", "Publica")%></span>
        <span class="media-play" aria-hidden="true"><%=Ico("chevron", 20)%></span>
      </a>
      <div class="media-body">
        <h3><a href="<%=BaseUrl%>playlist.asp?id=<%=pId%>"><%=H(pTitle)%></a></h3>
        <p><%=pTracks%> canciones · de <%=H(pOwner)%></p>
        <div class="media-actions">
          <a class="btn btn-ghost btn-sm" href="<%=BaseUrl%>playlist.asp?id=<%=pId%>">Abrir</a>
          <a class="btn btn-ghost btn-sm" href="<%=BaseUrl%>playlists.asp?edit=<%=pId%>" title="Editar"><%=Ico("edit", 14)%></a>
          <span class="spacer"></span>
          <form method="post" action="<%=BaseUrl%>playlists.asp" style="display:inline" onsubmit="return confirm('Eliminar la playlist «<%=H(Replace(pTitle, "'", ""))%>»? Sus canciones no se borran del catalogo.');">
            <input type="hidden" name="op" value="delete">
            <input type="hidden" name="id" value="<%=pId%>">
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
