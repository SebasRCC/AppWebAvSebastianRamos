<%@ LANGUAGE="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' ============================================================
'  default.asp · Pantalla principal (bienvenida + Song List)
' ============================================================
RequireLogin

PageTitle  = "Inicio"
PageKicker = "Biblioteca musical"
ActiveNav  = "home"

Dim totalSongs, totalArtists, totalAlbums, totalPlaylists, myPlaylists
Dim rsSongs, rsMyPl, rsStats
Dim trackJsonParts, rowIdx, songId, songName, songPath, songPlays, songArtists, songAlbum, songCover
Dim playlistsHtml

totalSongs = Num(DbScalar("SELECT COUNT(*) FROM TBL_SONG", Empty), 0)
totalArtists = Num(DbScalar("SELECT COUNT(*) FROM TBL_ARTIST", Empty), 0)
totalAlbums = Num(DbScalar("SELECT COUNT(*) FROM TBL_ALBUM", Empty), 0)
myPlaylists = Num(DbScalar("SELECT COUNT(*) FROM TBL_PLAYLIST WHERE ID_USER = ?", _
                Array(Array("@u", adInteger, 4, Session("UserID")))), 0)

Set rsSongs = DbRun( _
    "SELECT S.ID_SONG, S.SONG_NAME, S.SONG_PATH, ISNULL(S.PLAYS, 0) AS PLAYS, " & _
    "  ISNULL((SELECT STRING_AGG(A.ARTIST_NAME + ' ' + ISNULL(A.ARTIST_LASTNAME, ''), ', ') " & _
    "          FROM TBL_PLAYER P INNER JOIN TBL_ARTIST A ON A.ID_ARTIST = P.ID_ARTIST " & _
    "          WHERE P.ID_SONG = S.ID_SONG), '') AS ARTISTS, " & _
    "  ISNULL((SELECT TOP 1 AL.TITLE_ALBUM FROM TBL_TRACKLIST T INNER JOIN TBL_ALBUM AL ON AL.ID_ALBUM = T.ID_ALBUM " & _
    "          WHERE T.ID_SONG = S.ID_SONG ORDER BY AL.RELEASE_YEAR DESC), '') AS ALBUM, " & _
    "  (SELECT TOP 1 AL.ALBUM_IMAGE_PATH FROM TBL_TRACKLIST T INNER JOIN TBL_ALBUM AL ON AL.ID_ALBUM = T.ID_ALBUM " & _
    "   WHERE T.ID_SONG = S.ID_SONG ORDER BY AL.RELEASE_YEAR DESC) AS COVER " & _
    "FROM TBL_SONG S ORDER BY S.SONG_NAME", Empty)

' Playlists del usuario para el menu "agregar a playlist"
playlistsHtml = ""
Set rsMyPl = DbRun("SELECT ID_PLAYLIST, TITLE FROM TBL_PLAYLIST WHERE ID_USER = ? ORDER BY TITLE", _
                   Array(Array("@u", adInteger, 4, Session("UserID"))))
If rsMyPl.EOF Then
    playlistsHtml = "<p class=""add-pop-empty"">Aun no tienes playlists.</p>"
Else
    Do While Not rsMyPl.EOF
        playlistsHtml = playlistsHtml & "<a class=""add-pop-item"" href=""" & BaseUrl & "playlist.asp?addto=" & _
                        rsMyPl("ID_PLAYLIST") & "&amp;song=__SONG__&amp;back=home"">" & _
                        Ico("list", 15) & "<span>" & H(rsMyPl("TITLE")) & "</span></a>"
        rsMyPl.MoveNext
    Loop
End If
rsMyPl.Close
Set rsMyPl = Nothing

PageActions = "<a class=""btn btn-ghost btn-sm"" href=""" & BaseUrl & "playlists.asp"">" & Ico("list", 16) & " Mis playlists</a>" & _
              "<a class=""btn btn-primary btn-sm"" href=""#songlist"">" & Ico("music", 16) & " Ir al Song List</a>"
%>
<!--#include file="includes/head.asp"-->

<section class="welcome rise">
  <div class="welcome-copy">
    <span class="welcome-kicker"><%=Ico("sun", 13)%> <%=Greeting()%>, tu musica te espera</span>
    <h2>Bienvenido, <span class="name"><%=H(CurrentUserName())%></span></h2>
    <p class="lead">
      Esta es tu biblioteca en PoliMusic. Desde aqui puedes recorrer el catalogo completo,
      reproducir cada pista y organizar tu musica en playlists privadas o publicas.
    </p>
    <div class="welcome-meta">
      <span class="chip chip-gold"><%=Ico("shield", 13)%> <%=RoleLabel()%></span>
      <span class="chip"><%=Ico("user", 13)%> <%=H(Txt(Session("UserEmail")))%></span>
      <span class="chip"><%=Ico("list", 13)%> <%=myPlaylists%> playlists propias</span>
      <% If IsAdmin() Then %>
      <span class="chip"><%=Ico("disc", 13)%> Acceso total al catalogo</span>
      <% Else %>
      <span class="chip"><%=Ico("headphones", 13)%> Modo oyente</span>
      <% End If %>
    </div>
  </div>
  <div class="welcome-art" aria-hidden="true">
    <div class="welcome-rings"></div>
    <div class="disc"></div>
  </div>
</section>

<section class="stats">
  <div class="stat"><b><%=totalSongs%></b><span>Canciones</span></div>
  <div class="stat"><b><%=totalArtists%></b><span>Artistas</span></div>
  <div class="stat"><b><%=totalAlbums%></b><span>Albumes</span></div>
  <div class="stat"><b><%=myPlaylists%></b><span>Mis playlists</span></div>
</section>

<div class="notice" role="note">
  <%=Ico("music", 18)%>
  <div>
    <strong>A continuacion se presenta el listado de canciones (Song List)</strong>
    con todas las pistas disponibles en la biblioteca. Pulsa una fila o el boton de
    reproduccion para escucharla; la barra inferior mantiene la musica sonando mientras navegas.
  </div>
</div>

<section id="songlist">
  <div class="section-head">
    <div>
      <h2>Song List</h2>
      <p><%=totalSongs%> pistas en el catalogo · ordenadas por titulo</p>
    </div>
    <% If IsAdmin() Then %>
    <div class="section-actions">
      <a class="btn btn-ghost btn-sm" href="<%=BaseUrl%>songs.asp"><%=Ico("edit", 15)%> Administrar canciones</a>
    </div>
    <% End If %>
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
    trackJsonParts = ""
    rowIdx = 0
    If rsSongs.EOF Then
        Response.Write "<div class=""empty"" style=""border:0"">" & Ico("music", 26) & _
                       "<h3>Sin canciones todavia</h3><p>El catalogo esta vacio.</p></div>"
    End If
    Do While Not rsSongs.EOF
        songId = rsSongs("ID_SONG")
        songName = Txt(rsSongs("SONG_NAME"))
        songPath = rsSongs("SONG_PATH")
        songPlays = Num(rsSongs("PLAYS"), 0)
        songArtists = Txt(rsSongs("ARTISTS"))
        songAlbum = Txt(rsSongs("ALBUM"))
        songCover = AssetUrl(rsSongs("COVER"), "album")
        If Len(songArtists) = 0 Then songArtists = "Artista desconocido"
        If Len(songAlbum) = 0 Then songAlbum = "Sin album"

        If Len(trackJsonParts) > 0 Then trackJsonParts = trackJsonParts & ","
        trackJsonParts = trackJsonParts & JsonSong(songId, songName, songArtists, songAlbum, _
                         AssetUrl(songPath, "song"), songCover, songPlays)
        %>
    <article class="song-row" data-index="<%=rowIdx%>" data-song="<%=songId%>">
      <div class="song-index">
        <span class="num"><%=Right("0" & (rowIdx + 1), 2)%></span>
        <button type="button" class="play-mini" data-play="<%=rowIdx%>" aria-label="Reproducir <%=H(songName)%>">
          <%=Ico("play", 14)%>
        </button>
      </div>
      <div class="song-main">
        <img class="song-cover" src="<%=songCover%>" alt="Portada de <%=H(songName)%>" loading="lazy">
        <div class="song-text">
          <span class="song-title"><%=H(songName)%></span>
          <span class="song-sub"><%=H(songArtists)%></span>
        </div>
      </div>
      <div class="song-cell col-album truncate"><%=H(songAlbum)%></div>
      <div class="song-cell col-plays">
        <span class="song-plays"><%=Ico("clock", 13)%> <span class="plays-count"><%=songPlays%></span></span>
      </div>
      <div class="song-cell col-dur"><span class="dur" data-dur="<%=rowIdx%>">--:--</span></div>
      <div class="song-actions">
        <span class="eq" aria-hidden="true"><i></i><i></i><i></i><i></i></span>
        <% If IsAdmin() Then %>
        <a class="icon-btn act-admin" href="<%=BaseUrl%>songs.asp?edit=<%=songId%>" title="Editar cancion"><%=Ico("edit", 16)%></a>
        <% End If %>
        <div class="add-pop">
          <button type="button" class="icon-btn add-pop-trigger" title="Agregar a playlist" aria-label="Agregar <%=H(songName)%> a una playlist"><%=Ico("plus", 16)%></button>
          <div class="add-pop-panel">
            <p class="add-pop-title">Agregar a playlist</p>
            <%=Replace(playlistsHtml, "__SONG__", songId)%>
          </div>
        </div>
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

<%
Dim rsRecent
Set rsRecent = DbRun("SELECT TOP 4 ID_PLAYLIST, TITLE, TYPE, PHOTO, CREATION_DATE FROM TBL_PLAYLIST WHERE ID_USER = ? ORDER BY ID_PLAYLIST DESC", _
                     Array(Array("@u", adInteger, 4, Session("UserID"))))
If Not rsRecent.EOF Then
%>
<section>
  <div class="section-head">
    <div>
      <h2>Tus playlists</h2>
      <p>Colecciones que has creado en esta cuenta</p>
    </div>
    <div class="section-actions">
      <a class="btn btn-ghost btn-sm" href="<%=BaseUrl%>playlists.asp">Ver todas <%=Ico("chevron", 14)%></a>
    </div>
  </div>
  <div class="card-grid" style="margin-top:14px">
    <%
    Do While Not rsRecent.EOF
        Dim plType, plIsPrivate
        plType = Num(rsRecent("TYPE"), 0)
        plIsPrivate = (plType = 1)
    %>
    <a class="media-card" href="<%=BaseUrl%>playlist.asp?id=<%=rsRecent("ID_PLAYLIST")%>">
      <div class="media-figure">
        <img src="<%=AssetUrl(rsRecent("PHOTO"), "playlist")%>" alt="Portada de <%=H(rsRecent("TITLE"))%>" loading="lazy">
        <span class="media-badge <%=IIf(plIsPrivate, "is-private", "")%>"><%=IIf(plIsPrivate, "Privada", "Publica")%></span>
      </div>
      <div class="media-body">
        <h3><%=H(rsRecent("TITLE"))%></h3>
        <p><%=FormatDateTime(rsRecent("CREATION_DATE"), 2)%></p>
      </div>
    </a>
    <%
        rsRecent.MoveNext
    Loop
    rsRecent.Close
    Set rsRecent = Nothing
    %>
  </div>
</section>
<%
Else
    rsRecent.Close
    Set rsRecent = Nothing
End If
%>

<!--#include file="includes/foot.asp"-->
