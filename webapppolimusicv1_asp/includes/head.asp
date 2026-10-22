<%
' ============================================================
'  PoliMusic · Layout superior (se incluye despues de init.asp)
' ============================================================
If IsEmpty(PageTitle)   Then PageTitle = APP_NAME
If IsEmpty(PageKicker)  Then PageKicker = ""
If IsEmpty(ActiveNav)   Then ActiveNav = ""
If IsEmpty(PageActions) Then PageActions = ""
If IsEmpty(BodyClass)   Then BodyClass = ""

Function NavItem(url, icon, label, key)
    Dim cls
    If LCase(ActiveNav) = LCase(key) Then cls = "nav-link is-active" Else cls = "nav-link"
    NavItem = "<a class=""" & cls & """ href=""" & url & """>" & Ico(icon, 19) & "<span>" & label & "</span></a>"
End Function
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%=H(PageTitle)%> · <%=APP_NAME%></title>
<link rel="stylesheet" href="<%=BaseUrl%>css/app.css">
<link rel="icon" href="<%=BaseUrl%>assets/img/favicon.svg" type="image/svg+xml">
</head>
<body class="<%=H(BodyClass)%>">
<div class="app">

  <aside class="sidebar">
    <a class="brand" href="<%=BaseUrl%>default.asp">
      <span class="brand-mark">
        <svg width="30" height="30" viewBox="0 0 40 40" aria-hidden="true">
          <circle cx="20" cy="20" r="18" fill="none" stroke="currentColor" stroke-width="1.2" opacity=".45"/>
          <circle cx="20" cy="20" r="11" fill="none" stroke="currentColor" stroke-width="1.2" opacity=".7"/>
          <circle cx="20" cy="20" r="5.4" fill="#F2B705"/>
          <path d="M20 2.5v5M20 32.5v5M2.5 20h5M32.5 20h5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
        </svg>
      </span>
      <span class="brand-text">
        <strong>PoliMusic</strong>
        <em><%=APP_TAGLINE%></em>
      </span>
    </a>

    <div class="meander-rule" aria-hidden="true"></div>

    <nav class="nav" aria-label="Navegacion principal">
      <p class="nav-title">Explorar</p>
      <%=NavItem(BaseUrl & "default.asp", "home", "Inicio", "home")%>
      <%=NavItem(BaseUrl & "default.asp#songlist", "music", "Song List", "songs-list")%>

      <% If IsAdmin() Then %>
      <p class="nav-title">Catalogo</p>
      <%=NavItem(BaseUrl & "songs.asp", "disc", "Canciones", "songs")%>
      <%=NavItem(BaseUrl & "artists.asp", "mic", "Artistas", "artists")%>
      <%=NavItem(BaseUrl & "albums.asp", "grid", "Albumes", "albums")%>
      <% End If %>

      <p class="nav-title">Mi musica</p>
      <%=NavItem(BaseUrl & "playlists.asp", "list", "Playlists", "playlists")%>
    </nav>

    <div class="sidebar-foot">
      <div class="meander-rule meander-rule--soft" aria-hidden="true"></div>
      <div class="user-chip">
        <img class="user-chip-avatar" src="<%=CurrentUserPhoto()%>" alt="">
        <div class="user-chip-meta">
          <strong><%=H(CurrentUserName())%></strong>
          <span class="<%=RoleClass()%>"><%=RoleLabel()%></span>
        </div>
        <a class="logout-btn" href="<%=BaseUrl%>logout.asp" title="Cerrar sesion" aria-label="Cerrar sesion"><%=Ico("logout", 18)%></a>
      </div>
    </div>
  </aside>

  <div class="main">
    <header class="topbar">
      <div class="topbar-head">
        <% If Len(PageKicker) > 0 Then %><p class="kicker"><%=H(PageKicker)%></p><% End If %>
        <h1><%=H(PageTitle)%></h1>
      </div>
      <div class="topbar-actions"><%=PageActions%></div>
    </header>

    <main class="content">
