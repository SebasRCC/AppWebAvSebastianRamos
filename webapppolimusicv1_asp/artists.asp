<%@ LANGUAGE="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' ============================================================
'  artists.asp · CRUD de artistas (solo administrador)
' ============================================================
RequireAdmin

PageTitle  = "Artistas"
PageKicker = "Catalogo · administracion"
ActiveNav  = "artists"

Dim op, editId, showForm, errMsg, fName, fLast, fImage, rsList, rsOne, totalArtists

showForm = False
errMsg = ""
editId = Num(Request.QueryString("edit"), 0)
If LCase(Txt(Request.QueryString("action"))) = "new" Then
    editId = 0
    showForm = True
End If

fName = ""
fLast = ""
fImage = ""

If UCase(Request.ServerVariables("REQUEST_METHOD")) = "POST" Then
    op = LCase(Txt(Request.Form("op")))

    If op = "save" Then
        editId = Num(Request.Form("id"), 0)
        fName = Trim(Txt(Request.Form("artist_name")))
        fLast = Trim(Txt(Request.Form("artist_lastname")))
        fImage = Trim(Txt(Request.Form("artist_image")))
        showForm = True

        If Len(fName) = 0 Then
            errMsg = "El nombre del artista es obligatorio."
        ElseIf Len(fName) > 100 Then
            errMsg = "El nombre no puede superar los 100 caracteres."
        ElseIf Len(fLast) > 100 Then
            errMsg = "El apellido no puede superar los 100 caracteres."
        ElseIf Len(fImage) > 255 Then
            errMsg = "La ruta de la imagen no puede superar los 255 caracteres."
        End If

        If Len(errMsg) = 0 Then
            If editId > 0 Then
                DbRun "UPDATE TBL_ARTIST SET ARTIST_NAME = ?, ARTIST_LASTNAME = ?, ARTIST_IMAGE = ? WHERE ID_ARTIST = ?", _
                      Array(Array("@n", adVarChar, 100, fName), Array("@l", adVarChar, 100, fLast), _
                            Array("@i", adVarChar, 255, fImage), Array("@id", adInteger, 4, editId))
            Else
                DbRun "INSERT INTO TBL_ARTIST (ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE) VALUES (?, ?, ?)", _
                      Array(Array("@n", adVarChar, 100, fName), Array("@l", adVarChar, 100, fLast), _
                            Array("@i", adVarChar, 255, fImage))
            End If
            DbClose
            If editId > 0 Then
                Response.Redirect BaseUrl & "artists.asp?msg=saved"
            Else
                Response.Redirect BaseUrl & "artists.asp?msg=created"
            End If
            Response.End
        End If

    ElseIf op = "delete" Then
        Dim delId
        delId = Num(Request.Form("id"), 0)
        If delId > 0 Then
            DbRun "DELETE FROM TBL_PLAYER WHERE ID_ARTIST = ?", Array(Array("@a", adInteger, 4, delId))
            DbRun "DELETE FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(Array("@a", adInteger, 4, delId))
        End If
        DbClose
        Response.Redirect BaseUrl & "artists.asp?msg=deleted"
        Response.End
    End If
End If

If editId > 0 And Len(errMsg) = 0 Then
    Set rsOne = DbRun("SELECT ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE FROM TBL_ARTIST WHERE ID_ARTIST = ?", _
                      Array(Array("@id", adInteger, 4, editId)))
    If Not rsOne.EOF Then
        fName = Txt(rsOne("ARTIST_NAME"))
        fLast = Txt(rsOne("ARTIST_LASTNAME"))
        fImage = Txt(rsOne("ARTIST_IMAGE"))
        showForm = True
    Else
        Response.Redirect BaseUrl & "artists.asp?msg=notfound"
        Response.End
    End If
    rsOne.Close
    Set rsOne = Nothing
End If

PageActions = "<a class=""btn btn-gold btn-sm"" href=""" & BaseUrl & "artists.asp?action=new"">" & Ico("plus", 16) & " Nuevo artista</a>"
%>
<!--#include file="includes/head.asp"-->

<%=FlashBlock()%>

<% If showForm Then %>
<section class="panel panel-form rise">
  <div class="panel-head">
    <div>
      <h2><%=IIf(editId > 0, "Editar artista", "Registrar nuevo artista")%></h2>
      <p>Los artistas se relacionan con las canciones a traves de <strong>TBL_PLAYER</strong>.</p>
    </div>
    <a class="btn btn-ghost btn-sm" href="<%=BaseUrl%>artists.asp"><%=Ico("close", 15)%> Cancelar</a>
  </div>

  <% If Len(errMsg) > 0 Then %>
  <div class="flash flash-err" style="margin-bottom:16px" role="alert">
    <span class="flash-dot"></span><span><%=H(errMsg)%></span>
  </div>
  <% End If %>

  <form method="post" action="<%=BaseUrl%>artists.asp">
    <input type="hidden" name="op" value="save">
    <input type="hidden" name="id" value="<%=editId%>">

    <div class="form-grid">
      <div class="field">
        <label for="artist_name">Nombre</label>
        <input type="text" id="artist_name" name="artist_name" maxlength="100" value="<%=H(fName)%>" placeholder="Juan" required>
      </div>
      <div class="field">
        <label for="artist_lastname">Apellido</label>
        <input type="text" id="artist_lastname" name="artist_lastname" maxlength="100" value="<%=H(fLast)%>" placeholder="Gabriel">
      </div>
      <div class="field span-2">
        <label for="artist_image">Imagen del artista</label>
        <input type="text" id="artist_image" name="artist_image" list="artist-images" maxlength="255" value="<%=H(fImage)%>" placeholder="~/ArtistImages/artist1.jpg">
        <datalist id="artist-images">
          <%
          On Error Resume Next
          Dim fldA, fA
          Set fldA = Fso.GetFolder(Server.MapPath(BaseUrl & "assets/artistImages"))
          For Each fA In fldA.Files
              Response.Write "<option value=""~/ArtistImages/" & H(fA.Name) & """></option>"
          Next
          On Error GoTo 0
          %>
        </datalist>
        <span class="hint">Si la ruta no existe se mostrara la imagen por defecto.</span>
      </div>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary"><%=Ico("edit", 16)%> <%=IIf(editId > 0, "Guardar cambios", "Crear artista")%></button>
      <a class="btn btn-ghost" href="<%=BaseUrl%>artists.asp">Descartar</a>
    </div>
  </form>
</section>
<% End If %>

<section>
  <div class="section-head">
    <div>
      <h2>Artistas del catalogo</h2>
      <p>Cada artista puede interpretar varias canciones y participar en varios albumes.</p>
    </div>
  </div>

  <%
  Set rsList = DbRun( _
      "SELECT A.ID_ARTIST, A.ARTIST_NAME, A.ARTIST_LASTNAME, A.ARTIST_IMAGE, " & _
      "  (SELECT COUNT(*) FROM TBL_PLAYER P WHERE P.ID_ARTIST = A.ID_ARTIST) AS SONGS " & _
      "FROM TBL_ARTIST A ORDER BY A.ARTIST_NAME", Empty)

  If rsList.EOF Then
      Response.Write "<div class=""empty"" style=""margin-top:14px"">" & Ico("mic", 26) & _
                     "<h3>Sin artistas registrados</h3><p>Agrega el primer artista del catalogo.</p></div>"
  Else
  %>
  <div class="card-grid" style="margin-top:14px">
    <%
    Do While Not rsList.EOF
        Dim aId, aFull, aImg, aSongs
        aId = rsList("ID_ARTIST")
        aFull = Trim(rsList("ARTIST_NAME") & " " & rsList("ARTIST_LASTNAME") & "")
        aImg = AssetUrl(rsList("ARTIST_IMAGE"), "artist")
        aSongs = Num(rsList("SONGS"), 0)
    %>
    <article class="media-card">
      <div class="media-figure">
        <img src="<%=aImg%>" alt="Retrato de <%=H(aFull)%>" loading="lazy">
        <span class="media-badge"><%=aSongs%> canciones</span>
      </div>
      <div class="media-body">
        <h3><%=H(aFull)%></h3>
        <p><%=IIf(aSongs = 0, "Sin participaciones", "Interprete del catalogo")%></p>
        <div class="media-actions">
          <a class="btn btn-ghost btn-sm" href="<%=BaseUrl%>artists.asp?edit=<%=aId%>"><%=Ico("edit", 14)%> Editar</a>
          <span class="spacer"></span>
          <form method="post" action="<%=BaseUrl%>artists.asp" style="display:inline" onsubmit="return confirm('Eliminar a «<%=H(Replace(aFull, "'", ""))%>»? Se quitaran sus participaciones en canciones.');">
            <input type="hidden" name="op" value="delete">
            <input type="hidden" name="id" value="<%=aId%>">
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
