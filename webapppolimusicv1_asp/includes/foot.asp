<%
If IsEmpty(TrackJson) Then TrackJson = ""
If IsEmpty(PlayerNote) Then PlayerNote = ""
%>
    </main>

    <footer class="page-foot">
      <span><%=APP_NAME%> · Sistema de streaming academico</span>
      <span>SQL Server 2025 · Classic ASP</span>
    </footer>
  </div>
</div>

<!-- ===================== Reproductor ===================== -->
<section class="player" id="player" aria-label="Reproductor de musica">
  <div class="player-track">
    <div class="player-art">
      <img id="pCover" src="<%=BaseUrl%>assets/albumImages/default.png" alt="">
      <span class="player-art-ring" aria-hidden="true"></span>
    </div>
    <div class="player-meta">
      <strong id="pTitle">Selecciona una cancion</strong>
      <span id="pArtist">Song List de PoliMusic</span>
    </div>
  </div>

  <div class="player-center">
    <div class="player-controls">
      <button type="button" class="ctrl ctrl-sm" id="btnShuffle" title="Aleatorio" aria-label="Aleatorio" aria-pressed="false"><%=Ico("shuffle", 17)%></button>
      <button type="button" class="ctrl" id="btnPrev" title="Anterior" aria-label="Anterior"><%=Ico("prev", 19)%></button>
      <button type="button" class="ctrl ctrl-main" id="btnPlay" title="Reproducir" aria-label="Reproducir"><span id="playIcon"><%=Ico("play", 22)%></span></button>
      <button type="button" class="ctrl" id="btnNext" title="Siguiente" aria-label="Siguiente"><%=Ico("next", 19)%></button>
      <button type="button" class="ctrl ctrl-sm" id="btnRepeat" title="Repetir" aria-label="Repetir" aria-pressed="false"><%=Ico("repeat", 17)%></button>
    </div>
    <div class="player-seek">
      <span class="time" id="pCur">0:00</span>
      <input type="range" id="seek" min="0" max="1000" value="0" step="1" aria-label="Progreso de la cancion">
      <span class="time" id="pDur">0:00</span>
    </div>
  </div>

  <div class="player-right">
    <span class="eq" id="pEq" aria-hidden="true"><i></i><i></i><i></i><i></i></span>
    <button type="button" class="ctrl ctrl-sm" id="btnMute" title="Silenciar" aria-label="Silenciar"><%=Ico("volume", 18)%></button>
    <input type="range" id="vol" min="0" max="100" value="78" step="1" aria-label="Volumen">
  </div>

  <audio id="audio" preload="metadata"></audio>
</section>

<script>
window.POLIMUSIC = {
  tracks: [<%=TrackJson%>],
  playUrl: "<%=BaseUrl%>api_play.asp",
  logged: <%=IIf(IsLoggedIn(), "true", "false")%>
};
</script>
<script src="<%=BaseUrl%>js/app.js"></script>
</body>
</html>
<%
DbClose()
%>
