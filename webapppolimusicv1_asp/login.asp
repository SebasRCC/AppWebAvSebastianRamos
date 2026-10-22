<%@ LANGUAGE="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' ============================================================
'  login.asp · Autenticacion y creacion de la sesion
'  Soporta contrasenas en texto plano y hasheadas con SHA1
'  (el script BDD_PoliMusic.sql contiene ambos formatos)
' ============================================================
If IsLoggedIn() Then
    Response.Redirect BaseUrl & "default.asp"
    Response.End
End If

Dim errMsg, fUser, authNote, byeNote
errMsg = ""
fUser = ""
authNote = ""
byeNote = ""

If LCase(Txt(Request.QueryString("msg"))) = "auth" Then
    authNote = "Tu sesion no esta activa. Inicia sesion para entrar al catalogo."
End If

If LCase(Txt(Request.QueryString("msg"))) = "bye" Then
    byeNote = "Sesion cerrada correctamente. Vuelve cuando quieras."
End If

If UCase(Request.ServerVariables("REQUEST_METHOD")) = "POST" Then
    Dim fPass, rsUser
    fUser = Trim(Txt(Request.Form("username")))
    fPass = Txt(Request.Form("password"))

    If Len(fUser) = 0 Or Len(fPass) = 0 Then
        errMsg = "Ingresa tu usuario y tu contrasena."
    Else
        Set rsUser = DbRun( _
            "SELECT TOP 1 ID_USER, USERNAME, USER_TYPE, USER_PHOTO, EMAIL " & _
            "FROM TBL_USER " & _
            "WHERE USERNAME = ? AND (PASSWORD = ? OR UPPER(PASSWORD) = UPPER(CONVERT(varchar(40), HASHBYTES('SHA1', ?), 2)))", _
            Array(Array("@u", adVarChar, 50, fUser), _
                  Array("@p", adVarChar, 50, fPass), _
                  Array("@ph", adVarChar, 50, fPass)))

        If Not rsUser.EOF Then
            StartUserSession rsUser("ID_USER"), rsUser("USERNAME"), rsUser("USER_TYPE"), rsUser("USER_PHOTO"), rsUser("EMAIL")
            rsUser.Close
            Set rsUser = Nothing
            Response.Redirect BaseUrl & "default.asp"
            Response.End
        Else
            rsUser.Close
            Set rsUser = Nothing
            errMsg = "Usuario o contrasena incorrectos. Verifica tus credenciales."
        End If
    End If
End If

DbClose()
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Iniciar sesion · <%=APP_NAME%></title>
<link rel="stylesheet" href="<%=BaseUrl%>css/app.css">
<link rel="icon" href="<%=BaseUrl%>assets/img/favicon.svg" type="image/svg+xml">
</head>
<body class="auth-page">
<div class="auth-shell">

  <section class="auth-visual">
    <div class="auth-sun" aria-hidden="true"></div>
    <div class="auth-waves" aria-hidden="true"></div>

    <div class="auth-brand">
      <span class="brand-mark">
        <svg width="34" height="34" viewBox="0 0 40 40" aria-hidden="true">
          <circle cx="20" cy="20" r="18" fill="none" stroke="currentColor" stroke-width="1.2" opacity=".45"/>
          <circle cx="20" cy="20" r="11" fill="none" stroke="currentColor" stroke-width="1.2" opacity=".7"/>
          <circle cx="20" cy="20" r="5.4" fill="#F2B705"/>
          <path d="M20 2.5v5M20 32.5v5M2.5 20h5M32.5 20h5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
        </svg>
      </span>
      <div>
        <strong>PoliMusic</strong>
        <em><%=APP_TAGLINE%></em>
      </div>
    </div>

    <div class="auth-hero">
      <h1>Tu biblioteca <em>suena</em> a mar Egeo.</h1>
      <p>Un catalogo musical academico construido sobre SQL Server 2025 y Classic ASP.
         Gestiona canciones, artistas, albumes y playlists desde un solo lugar.</p>
    </div>

    <div class="auth-foot">PoliMusic · Escuela Politecnica Nacional · Proyecto de Aplicaciones Web</div>
  </section>

  <section class="auth-form-wrap">
    <div class="auth-card rise">
      <h2>Bienvenido de vuelta</h2>
      <p class="auth-sub">Ingresa tus credenciales para abrir tu biblioteca musical.</p>

      <% If Len(authNote) > 0 Then %>
      <div class="flash flash-warn" style="margin-top:18px" role="status">
        <span class="flash-dot"></span><span><%=H(authNote)%></span>
      </div>
      <% End If %>

      <% If Len(byeNote) > 0 Then %>
      <div class="flash flash-ok" style="margin-top:18px" role="status">
        <span class="flash-dot"></span><span><%=H(byeNote)%></span>
      </div>
      <% End If %>

      <% If Len(errMsg) > 0 Then %>
      <div class="flash flash-err" style="margin-top:18px" role="alert">
        <span class="flash-dot"></span><span><%=H(errMsg)%></span>
      </div>
      <% End If %>

      <form class="auth-form" method="post" action="<%=BaseUrl%>login.asp" autocomplete="off">
        <div class="field">
          <label for="username">Usuario</label>
          <input type="text" id="username" name="username" value="<%=H(fUser)%>" placeholder="userAdmin" required maxlength="50" autofocus>
        </div>
        <div class="field">
          <label for="password">Contrasena</label>
          <input type="password" id="password" name="password" placeholder="********" required maxlength="50">
        </div>
        <button type="submit" class="btn btn-gold btn-block">
          <%=Ico("headphones", 17)%> Entrar a PoliMusic
        </button>
      </form>

      <div class="demo-box">
        <p>Cuentas de prueba del script</p>
        <div class="demo-list">
          <button type="button" class="demo-btn" data-user="userAdmin" data-pass="12345678">
            <b>userAdmin</b> / 12345678 <span class="badge badge-admin">Admin</span>
          </button>
          <button type="button" class="demo-btn" data-user="userNormal" data-pass="12345678">
            <b>userNormal</b> / 12345678 <span class="badge badge-user">Usuario</span>
          </button>
          <button type="button" class="demo-btn" data-user="username1" data-pass="12345678">
            <b>username1</b> / 12345678 <span class="badge badge-user">SHA1</span>
          </button>
        </div>
      </div>
    </div>
  </section>
</div>

<script>
document.querySelectorAll(".demo-btn").forEach(function (btn) {
  btn.addEventListener("click", function () {
    document.getElementById("username").value = btn.getAttribute("data-user");
    document.getElementById("password").value = btn.getAttribute("data-pass");
    document.getElementById("password").focus();
  });
});
</script>
</body>
</html>
