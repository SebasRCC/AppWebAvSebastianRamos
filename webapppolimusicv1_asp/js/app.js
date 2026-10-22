/* ==========================================================================
   PoliMusic · Reproductor y microinteracciones
   ========================================================================== */
(function () {
  "use strict";

  var CFG = window.POLIMUSIC || { tracks: [], playUrl: "api_play.asp" };
  var tracks = Array.isArray(CFG.tracks) ? CFG.tracks : [];

  var audio = document.getElementById("audio");
  var player = document.getElementById("player");
  if (!audio || !player) return;

  var el = {
    cover: document.getElementById("pCover"),
    title: document.getElementById("pTitle"),
    artist: document.getElementById("pArtist"),
    cur: document.getElementById("pCur"),
    dur: document.getElementById("pDur"),
    seek: document.getElementById("seek"),
    vol: document.getElementById("vol"),
    btnPlay: document.getElementById("btnPlay"),
    btnPrev: document.getElementById("btnPrev"),
    btnNext: document.getElementById("btnNext"),
    btnShuffle: document.getElementById("btnShuffle"),
    btnRepeat: document.getElementById("btnRepeat"),
    btnMute: document.getElementById("btnMute"),
    playIcon: document.getElementById("playIcon")
  };

  var ICON_PLAY = '<svg class="ico" width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M8 5.5v13l11-6.5z" fill="currentColor"/></svg>';
  var ICON_PAUSE = '<svg class="ico" width="22" height="22" viewBox="0 0 24 24" fill="none" aria-hidden="true"><rect x="7" y="5" width="3.4" height="14" rx="1" fill="currentColor"/><rect x="13.6" y="5" width="3.4" height="14" rx="1" fill="currentColor"/></svg>';
  var ICON_PLAY_SM = '<svg class="ico" width="14" height="14" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M8 5.5v13l11-6.5z" fill="currentColor"/></svg>';
  var ICON_PAUSE_SM = '<svg class="ico" width="14" height="14" viewBox="0 0 24 24" fill="none" aria-hidden="true"><rect x="7" y="5" width="3.4" height="14" rx="1" fill="currentColor"/><rect x="13.6" y="5" width="3.4" height="14" rx="1" fill="currentColor"/></svg>';

  var state = {
    index: -1,
    shuffle: false,
    repeat: 0,           /* 0 = off, 1 = toda la lista, 2 = una cancion */
    lastVolume: 0.78,
    counting: false
  };

  /* ---------- utilidades ---------- */
  function fmt(sec) {
    if (!isFinite(sec) || sec < 0) sec = 0;
    var m = Math.floor(sec / 60);
    var s = Math.floor(sec % 60);
    return m + ":" + (s < 10 ? "0" + s : s);
  }

  function paintRange(input, pct) {
    if (!input) return;
    input.style.setProperty("--p", Math.max(0, Math.min(100, pct)) + "%");
  }

  function rows() {
    return Array.prototype.slice.call(document.querySelectorAll(".song-row[data-index]"));
  }

  function markRows() {
    rows().forEach(function (row) {
      var i = parseInt(row.getAttribute("data-index"), 10);
      var active = (i === state.index);
      row.classList.toggle("is-playing", active);
      var eq = row.querySelector(".eq");
      if (eq) eq.setAttribute("aria-hidden", active ? "false" : "true");
      var mini = row.querySelector(".play-mini");
      if (mini) {
        var paused = active ? audio.paused : true;
        mini.innerHTML = paused ? ICON_PLAY_SM : ICON_PAUSE_SM;
        mini.setAttribute("aria-label", paused ? "Reproducir" : "Pausar");
      }
    });
  }

  /* ---------- reproduccion ---------- */
  function playAt(i) {
    if (!tracks.length) return;
    if (i < 0 || i >= tracks.length) return;
    state.index = i;
    var t = tracks[i];

    audio.src = t.src;
    audio.load();

    var p = audio.play();
    if (p && p.catch) {
      p.catch(function () {
        el.artist.textContent = "No se pudo reproducir el archivo de audio";
        player.classList.remove("is-playing");
        el.playIcon.innerHTML = ICON_PLAY;
      });
    }

    el.title.textContent = t.title;
    el.artist.textContent = (t.artist || "Artista desconocido") + (t.album ? " · " + t.album : "");
    if (el.cover && t.cover) el.cover.src = t.cover;
    document.title = t.title + " · PoliMusic";

    markRows();
    countPlay(t.id);
  }

  function countPlay(id) {
    if (!id || !CFG.playUrl) return;
    try {
      fetch(CFG.playUrl, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
        body: "id=" + encodeURIComponent(id),
        credentials: "same-origin"
      }).then(function (r) { return r.json(); }).then(function (data) {
        if (!data || !data.ok) return;
        var row = document.querySelector('.song-row[data-song="' + id + '"]');
        if (row) {
          var cell = row.querySelector(".plays-count");
          if (cell) cell.textContent = data.plays;
        }
      }).catch(function () { /* silencioso */ });
    } catch (e) { /* navegadores sin fetch */ }
  }

  function toggle() {
    if (state.index < 0) {
      if (tracks.length) playAt(0);
      return;
    }
    if (audio.paused) {
      audio.play().catch(function () {});
    } else {
      audio.pause();
    }
  }

  function next(auto) {
    if (!tracks.length) return;
    if (state.shuffle && tracks.length > 1) {
      var n = state.index;
      while (n === state.index) n = Math.floor(Math.random() * tracks.length);
      playAt(n);
      return;
    }
    var i = state.index + 1;
    if (i >= tracks.length) {
      if (state.repeat === 1) i = 0;
      else if (auto) { audio.pause(); return; }
      else i = 0;
    }
    playAt(i);
  }

  function prev() {
    if (!tracks.length) return;
    if (audio.currentTime > 3) { audio.currentTime = 0; return; }
    var i = state.index - 1;
    if (i < 0) i = state.repeat === 1 ? tracks.length - 1 : 0;
    playAt(i);
  }

  /* ---------- eventos de audio ---------- */
  audio.addEventListener("play", function () {
    player.classList.add("is-playing");
    el.playIcon.innerHTML = ICON_PAUSE;
    el.btnPlay.setAttribute("aria-label", "Pausar");
    markRows();
  });

  audio.addEventListener("pause", function () {
    player.classList.remove("is-playing");
    el.playIcon.innerHTML = ICON_PLAY;
    el.btnPlay.setAttribute("aria-label", "Reproducir");
    markRows();
  });

  audio.addEventListener("loadedmetadata", function () {
    el.dur.textContent = fmt(audio.duration);
  });

  audio.addEventListener("timeupdate", function () {
    var d = audio.duration || 0;
    el.cur.textContent = fmt(audio.currentTime);
    if (d > 0) {
      var pct = (audio.currentTime / d) * 100;
      el.seek.value = Math.round((audio.currentTime / d) * 1000);
      paintRange(el.seek, pct);
    }
  });

  audio.addEventListener("ended", function () {
    if (state.repeat === 2) {
      audio.currentTime = 0;
      audio.play().catch(function () {});
      return;
    }
    next(true);
  });

  /* ---------- controles ---------- */
  el.btnPlay.addEventListener("click", toggle);
  el.btnNext.addEventListener("click", function () { next(false); });
  el.btnPrev.addEventListener("click", prev);

  el.seek.addEventListener("input", function () {
    var d = audio.duration || 0;
    if (d > 0) audio.currentTime = (this.value / 1000) * d;
    paintRange(this, (this.value / 1000) * 100);
  });

  el.vol.addEventListener("input", function () {
    var v = this.value / 100;
    audio.volume = v;
    state.lastVolume = v;
    paintRange(this, this.value);
    el.btnMute.classList.toggle("is-on", v === 0);
  });

  el.btnMute.addEventListener("click", function () {
    if (audio.volume > 0) {
      state.lastVolume = audio.volume;
      audio.volume = 0;
      el.vol.value = 0;
      paintRange(el.vol, 0);
      this.classList.add("is-on");
    } else {
      audio.volume = state.lastVolume || 0.78;
      el.vol.value = Math.round(audio.volume * 100);
      paintRange(el.vol, audio.volume * 100);
      this.classList.remove("is-on");
    }
  });

  el.btnShuffle.addEventListener("click", function () {
    state.shuffle = !state.shuffle;
    this.classList.toggle("is-on", state.shuffle);
    this.setAttribute("aria-pressed", state.shuffle ? "true" : "false");
  });

  el.btnRepeat.addEventListener("click", function () {
    state.repeat = (state.repeat + 1) % 3;
    this.classList.toggle("is-on", state.repeat !== 0);
    this.setAttribute("aria-pressed", state.repeat !== 0 ? "true" : "false");
    this.title = state.repeat === 0 ? "Repetir" : (state.repeat === 1 ? "Repetir lista" : "Repetir cancion");
  });

  /* ---------- filas de la lista ---------- */
  document.addEventListener("click", function (ev) {
    var playBtn = ev.target.closest("[data-play]");
    if (playBtn) {
      ev.preventDefault();
      var i = parseInt(playBtn.getAttribute("data-play"), 10);
      if (i === state.index && !audio.paused) { audio.pause(); return; }
      if (i === state.index && audio.paused) { audio.play().catch(function () {}); return; }
      playAt(i);
      return;
    }

    var row = ev.target.closest(".song-row[data-index]");
    if (row && !ev.target.closest("a, .add-pop, .act-admin")) {
      var idx = parseInt(row.getAttribute("data-index"), 10);
      if (idx === state.index) { toggle(); } else { playAt(idx); }
    }
  });

  /* ---------- popover agregar a playlist ---------- */
  document.addEventListener("click", function (ev) {
    var trigger = ev.target.closest(".add-pop-trigger");
    var open = document.querySelector(".add-pop.is-open");

    if (trigger) {
      ev.preventDefault();
      var pop = trigger.closest(".add-pop");
      if (open && open !== pop) open.classList.remove("is-open");
      pop.classList.toggle("is-open");
      return;
    }
    if (open && !ev.target.closest(".add-pop-panel")) open.classList.remove("is-open");
  });

  document.addEventListener("keydown", function (ev) {
    if (ev.key === "Escape") {
      var open = document.querySelector(".add-pop.is-open");
      if (open) open.classList.remove("is-open");
    }
    var tag = (ev.target.tagName || "").toLowerCase();
    if (ev.code === "Space" && tag !== "input" && tag !== "textarea" && tag !== "select" && tag !== "button") {
      ev.preventDefault();
      toggle();
    }
  });

  /* ---------- duracion real de cada pista (metadata) ---------- */
  function loadDurations() {
    if (!tracks.length) return;
    tracks.forEach(function (t, i) {
      var cell = document.querySelector('.dur[data-dur="' + i + '"]');
      if (!cell) return;
      var probe = new Audio();
      probe.preload = "metadata";
      probe.addEventListener("loadedmetadata", function () {
        cell.textContent = fmt(probe.duration);
        probe.removeAttribute("src");
      });
      probe.addEventListener("error", function () { cell.textContent = "--:--"; });
      probe.src = t.src;
    });
  }
  loadDurations();

  /* ---------- estado inicial ---------- */
  audio.volume = 0.78;
  paintRange(el.vol, 78);
  paintRange(el.seek, 0);
  if (!tracks.length) {
    el.title.textContent = "Selecciona una cancion";
    el.artist.textContent = "Song List de PoliMusic";
  }

  /* resaltar fila activa si el navegador restaura el audio */
  markRows();
})();
