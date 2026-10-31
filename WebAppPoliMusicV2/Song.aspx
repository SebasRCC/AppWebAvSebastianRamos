<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html lang="es">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic &middot; Song list</title>
    <link rel="stylesheet" href="Content/Song.css" />
</head>
<body>
    <form id="formSong" runat="server">

        <!-- ================= Barra superior ================= -->
        <header class="topbar">
            <div class="brand">
                <span class="brand-mark" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke-width="1.6" stroke-linecap="round">
                        <circle cx="12" cy="12" r="8.4" />
                        <path d="M12 7.2v5.1l3.2 1.9" />
                    </svg>
                </span>
                <span class="brand-text">
                    <span class="brand-name">PoliMusic</span>
                    <span class="brand-sub">TVA Sound Archive</span>
                </span>
            </div>

            <div class="user-block">
                <span class="welcome">
                    <span class="welcome-label">Welcome</span>
                    <span class="user-name">
                        <asp:Label ID="lblUserName" runat="server"></asp:Label>
                    </span>
                </span>

                <asp:Image ID="imgUserPhoto" runat="server" CssClass="avatar" AlternateText="User photo" />

                <a class="logout" href="<%= ResolveUrl("~/Logout.aspx") %>" title="Cerrar sesi&oacute;n">
                    <svg viewBox="0 0 24 24" fill="none" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                        <path d="M15 17l5-5-5-5" />
                        <path d="M20 12H9.5" />
                        <path d="M12 19H6a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h6" />
                    </svg>
                    <span>Logout</span>
                </a>
            </div>
        </header>

        <!-- ================= Contenido ================= -->
        <main class="shell">
            <section class="panel">

                <div class="panel-head">
                    <div>
                        <p class="kicker">Archivo temporal &middot; expediente 001</p>
                        <h1>Song list</h1>
                    </div>
                    <div class="panel-meta">
                        <span class="chip chip-accent">
                            <asp:Label ID="lblSongCount" runat="server"></asp:Label>
                        </span>
                        <span class="chip">TBL_SONG</span>
                    </div>
                </div>

                <asp:Panel ID="pnlList" runat="server" CssClass="table-wrap">
                    <table class="songs">
                        <thead>
                            <tr>
                                <th class="col-id">ID Canci&oacute;n</th>
                                <th class="col-name">Nombre</th>
                                <th class="col-path">Ruta</th>
                                <th class="col-plays">Reproducciones</th>
                                <th class="col-play">Reproducir</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptSongs" runat="server">
                                <ItemTemplate>
                                    <tr class="song-row">
                                        <td class="col-id">
                                            <span class="song-id"><span class="hash">#</span><%# H(Eval("ID_SONG")) %></span>
                                        </td>
                                        <td class="col-name">
                                            <span class="song-name"><%# H(Eval("SONG_NAME")) %><span class="eq" aria-hidden="true"><i></i><i></i><i></i></span></span>
                                            <span class="song-sub">MP3 &middot; TVA archive</span>
                                        </td>
                                        <td class="col-path">
                                            <code class="song-path" title='<%# H(Eval("SONG_PATH")) %>'><%# H(Eval("SONG_PATH")) %></code>
                                        </td>
                                        <td class="col-plays">
                                            <span class="plays-pill">
                                                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.5v13l11-6.5z" /></svg>
                                                <span class="plays-num"><%# H(Eval("PLAYS")) %></span>
                                            </span>
                                        </td>
                                        <td class="col-play">
                                            <div class="player" data-id='<%# H(Eval("ID_SONG")) %>'>
                                                <button type="button" class="pp" aria-label='Reproducir <%# H(Eval("SONG_NAME")) %>'>
                                                    <svg class="ico-play" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.5v13l11-6.5z" /></svg>
                                                    <svg class="ico-pause" viewBox="0 0 24 24" aria-hidden="true"><path d="M7 5h3.2v14H7zM13.8 5H17v14h-3.2z" /></svg>
                                                </button>

                                                <span class="time">
                                                    <span class="cur">0:00</span><span class="sep">/</span><span class="dur">0:00</span>
                                                </span>

                                                <div class="seek" aria-hidden="true">
                                                    <span class="seek-track"></span>
                                                    <span class="seek-fill"></span>
                                                    <span class="seek-knob"></span>
                                                </div>

                                                <button type="button" class="vol" aria-label="Silenciar">
                                                    <svg class="ico-on" viewBox="0 0 24 24" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                                        <path d="M4 9.4h3.3L12 5.6v12.8l-4.7-3.8H4z" />
                                                        <path d="M16.2 9.2a3.9 3.9 0 0 1 0 5.6" />
                                                    </svg>
                                                    <svg class="ico-mute" viewBox="0 0 24 24" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                                        <path d="M4 9.4h3.3L12 5.6v12.8l-4.7-3.8H4z" />
                                                        <path d="M16.4 9.6l4.2 4.8M20.6 9.6l-4.2 4.8" />
                                                    </svg>
                                                </button>

                                                <input type="range" class="vol-range" min="0" max="100" value="80" aria-label="Volumen" />

                                                <audio preload="metadata" src='<%# ResolveUrl(Eval("SONG_PATH").ToString()) %>'></audio>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </asp:Panel>

                <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                    <span class="empty-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M9 18V6.4l9-2v11.2" />
                            <circle cx="6.6" cy="18" r="2.4" />
                            <circle cx="15.6" cy="15.6" r="2.4" />
                        </svg>
                    </span>
                    <h3>El archivo est&aacute; vac&iacute;o</h3>
                    <p>No hay canciones registradas en <strong>TBL_SONG</strong> todav&iacute;a.</p>
                </asp:Panel>

            </section>

            <p class="foot">TVA &middot; Time Variance Authority &mdash; sound archive</p>
        </main>

    </form>

    <script>
        (function () {
            "use strict";

            var counterUrl = "<%= ResolveClientUrl("~/Song.aspx") %>";
            var players = Array.prototype.slice.call(document.querySelectorAll(".player"));
            var activePlayer = null;

            function fmt(seconds) {
                if (!isFinite(seconds) || seconds < 0) { seconds = 0; }
                var m = Math.floor(seconds / 60);
                var s = Math.floor(seconds % 60);
                return m + ":" + (s < 10 ? "0" + s : s);
            }

            players.forEach(function (root) {
                var audio = root.querySelector("audio");
                var button = root.querySelector(".pp");
                var seek = root.querySelector(".seek");
                var fill = root.querySelector(".seek-fill");
                var knob = root.querySelector(".seek-knob");
                var cur = root.querySelector(".cur");
                var dur = root.querySelector(".dur");
                var volButton = root.querySelector(".vol");
                var volRange = root.querySelector(".vol-range");
                var row = root.closest("tr");
                var songId = root.getAttribute("data-id");
                var counted = false;

                function paint() {
                    var ratio = audio.duration ? (audio.currentTime / audio.duration) * 100 : 0;
                    fill.style.width = ratio + "%";
                    knob.style.left = ratio + "%";
                    cur.textContent = fmt(audio.currentTime);
                }

                function clearState() {
                    root.classList.remove("is-playing");
                    if (row) { row.classList.remove("is-current"); }
                }

                function bumpPlays() {
                    var url = counterUrl + (counterUrl.indexOf("?") === -1 ? "?" : "&") + "play=" + encodeURIComponent(songId);
                    fetch(url, { credentials: "same-origin", headers: { "X-Requested-With": "XMLHttpRequest" } })
                        .then(function (response) { return response.ok ? response.json() : null; })
                        .then(function (data) {
                            if (!data || typeof data.plays === "undefined") { return; }
                            var pill = row ? row.querySelector(".plays-pill") : null;
                            if (!pill) { return; }
                            pill.querySelector(".plays-num").textContent = data.plays;
                            pill.classList.add("is-bump");
                            window.setTimeout(function () { pill.classList.remove("is-bump"); }, 620);
                        })
                        .catch(function () { /* el contador no debe romper la reproduccion */ });
                }

                audio.addEventListener("loadedmetadata", function () { dur.textContent = fmt(audio.duration); });
                audio.addEventListener("timeupdate", paint);

                audio.addEventListener("play", function () {
                    if (activePlayer && activePlayer !== root) {
                        var otherAudio = activePlayer.querySelector("audio");
                        if (otherAudio) { otherAudio.pause(); }
                        activePlayer.classList.remove("is-playing");
                        var otherRow = activePlayer.closest("tr");
                        if (otherRow) { otherRow.classList.remove("is-current"); }
                    }
                    activePlayer = root;
                    root.classList.add("is-playing");
                    if (row) { row.classList.add("is-current"); }
                    if (!counted) { counted = true; bumpPlays(); }
                });

                audio.addEventListener("pause", clearState);

                audio.addEventListener("ended", function () {
                    clearState();
                    audio.currentTime = 0;
                    paint();
                });

                button.addEventListener("click", function () {
                    if (audio.paused) {
                        audio.play();
                    } else {
                        audio.pause();
                    }
                });

                function seekTo(clientX) {
                    var box = seek.getBoundingClientRect();
                    var ratio = (clientX - box.left) / box.width;
                    ratio = Math.min(1, Math.max(0, ratio));
                    if (audio.duration) {
                        audio.currentTime = ratio * audio.duration;
                        paint();
                    }
                }

                var dragging = false;
                seek.addEventListener("pointerdown", function (event) {
                    dragging = true;
                    if (seek.setPointerCapture) { seek.setPointerCapture(event.pointerId); }
                    seekTo(event.clientX);
                });
                seek.addEventListener("pointermove", function (event) {
                    if (dragging) { seekTo(event.clientX); }
                });
                seek.addEventListener("pointerup", function () { dragging = false; });
                seek.addEventListener("pointercancel", function () { dragging = false; });

                audio.volume = 0.8;
                volRange.addEventListener("input", function () {
                    audio.volume = volRange.value / 100;
                    if (audio.volume > 0 && audio.muted) { audio.muted = false; }
                    root.classList.toggle("is-muted", audio.muted || audio.volume === 0);
                });
                volButton.addEventListener("click", function () {
                    audio.muted = !audio.muted;
                    root.classList.toggle("is-muted", audio.muted);
                });
            });
        })();
    </script>
</body>
</html>
