<%@ Page Title="Canciones" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV3.Song" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

<style type="text/css">
    /* ============================================================
       TVA / LOKI THEME  ·  Time Variance Authority Archive
       Paleta: madera oscura, mostaza, ambar y crema burocratica.
       ============================================================ */
    :root {
        --tva-void:   #0d0907;
        --tva-deep:   #150f0a;
        --tva-panel:  #1d1610;
        --tva-panel2: #241a13;
        --tva-line:   #4a3524;
        --tva-amber:  #e9a13b;
        --tva-orange: #d2601a;
        --tva-cream:  #f4e9d4;
        --tva-muted:  #a68e6c;
        --font-display: "Bahnschrift Condensed", "Arial Narrow", "Haettenschweiler", Impact, sans-serif;
        --font-mono:    Consolas, "Courier New", monospace;
        --font-ui:      "Segoe UI", system-ui, -apple-system, Arial, sans-serif;
    }

    /* --- lienzo general ------------------------------------- */
    body {
        background:
            radial-gradient(1200px 620px at 50% -12%, #2c1e13 0%, #150f0a 52%, #0b0806 100%) fixed;
        color: var(--tva-cream);
        font-family: var(--font-ui);
        -webkit-font-smoothing: antialiased;
    }
    /* scanlines de monitor CRT */
    body::after {
        content: "";
        position: fixed;
        inset: 0;
        pointer-events: none;
        z-index: 9998;
        background: repeating-linear-gradient(to bottom,
            rgba(0, 0, 0, .20) 0px, rgba(0, 0, 0, .20) 1px,
            rgba(0, 0, 0, 0) 1px, rgba(0, 0, 0, 0) 3px);
        opacity: .42;
    }
    /* vineta */
    body::before {
        content: "";
        position: fixed;
        inset: 0;
        pointer-events: none;
        z-index: 9997;
        background: radial-gradient(ellipse at center, rgba(0,0,0,0) 42%, rgba(0,0,0,.62) 100%);
    }

    .body-content { padding: 0; max-width: 100%; }
    .body-content hr { border-top-color: rgba(74, 53, 36, .7); margin-top: 34px; }
    .body-content footer p {
        font-family: var(--font-mono);
        font-size: 11px;
        letter-spacing: .16em;
        text-transform: uppercase;
        color: #6f5d45;
    }

    .tva {
        max-width: 1160px;
        margin: 0 auto;
        padding: 38px 20px 8px;
        position: relative;
        z-index: 1;
        box-sizing: border-box;
    }
    .tva *, .tva *::before, .tva *::after { box-sizing: border-box; }
    .tva h1, .tva h2, .tva p { margin: 0; }

    /* --- cabecera ------------------------------------------- */
    .tva-head {
        display: flex;
        align-items: flex-end;
        justify-content: space-between;
        gap: 26px;
        padding-bottom: 16px;
        border-bottom: 3px solid var(--tva-amber);
        position: relative;
    }
    .tva-head::after {
        content: "";
        position: absolute;
        left: 0; right: 0; bottom: -8px;
        height: 1px;
        background: rgba(233, 161, 59, .35);
    }
    .tva-brand { display: flex; align-items: center; gap: 18px; }

    .tva-seal {
        width: 78px; height: 78px;
        flex: 0 0 auto;
        border-radius: 50%;
        border: 2px solid var(--tva-amber);
        display: grid;
        place-items: center;
        position: relative;
        background: radial-gradient(circle at 50% 40%, rgba(233,161,59,.18), rgba(233,161,59,0) 70%);
        box-shadow: 0 0 0 4px rgba(233, 161, 59, .10), inset 0 0 22px rgba(233, 161, 59, .28);
    }
    .tva-seal::before {
        content: "";
        position: absolute; inset: 7px;
        border-radius: 50%;
        border: 1px dashed rgba(233, 161, 59, .55);
    }
    .tva-seal span {
        font-family: var(--font-display);
        font-size: 23px;
        letter-spacing: .08em;
        color: var(--tva-amber);
        text-shadow: 0 0 14px rgba(233, 161, 59, .55);
    }

    .tva-eyebrow {
        font-family: var(--font-mono);
        font-size: 10.5px;
        letter-spacing: .42em;
        text-transform: uppercase;
        color: #c08f4a;
    }
    .tva-title {
        font-family: var(--font-display);
        font-size: clamp(26px, 3.3vw, 42px);
        line-height: .98;
        letter-spacing: .045em;
        text-transform: uppercase;
        color: var(--tva-cream);
        margin: 6px 0 7px;
        font-weight: 600;
    }
    .tva-sub {
        font-family: var(--font-mono);
        font-size: 11px;
        letter-spacing: .13em;
        color: var(--tva-muted);
        text-transform: uppercase;
    }

    .tva-case { text-align: right; flex: 0 0 auto; }
    .tva-case-lbl {
        display: block;
        font-family: var(--font-mono);
        font-size: 9.5px;
        letter-spacing: .34em;
        text-transform: uppercase;
        color: #8a7455;
    }
    .tva-case-no {
        display: block;
        font-family: var(--font-mono);
        font-size: 15px;
        letter-spacing: .16em;
        color: var(--tva-amber);
        margin: 5px 0 9px;
    }
    .tva-barcode {
        height: 26px; width: 168px;
        margin-left: auto;
        background: repeating-linear-gradient(to right,
            #c9a06a 0px, #c9a06a 2px, transparent 2px, transparent 4px,
            #c9a06a 4px, #c9a06a 5px, transparent 5px, transparent 8px,
            #c9a06a 8px, #c9a06a 11px, transparent 11px, transparent 13px);
        opacity: .62;
    }

    /* --- barra de identificacion ---------------------------- */
    .tva-idbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 18px;
        margin: 26px 0 20px;
        padding: 13px 20px;
        background: linear-gradient(180deg, var(--tva-panel2), #1a130e);
        border: 1px solid var(--tva-line);
        border-left: 4px solid var(--tva-orange);
    }
    .tva-id-left { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; }
    .tva-tag {
        font-family: var(--font-mono);
        font-size: 9.5px;
        letter-spacing: .3em;
        text-transform: uppercase;
        color: #1a1208;
        background: var(--tva-amber);
        padding: 3px 8px 2px;
    }
    .tva-welcome {
        font-family: var(--font-mono);
        font-size: 14px;
        letter-spacing: .04em;
        color: var(--tva-cream);
    }
    .tva-user {
        display: inline-block;
        margin-left: 4px;
        padding: 2px 10px;
        border: 1px dashed var(--tva-amber);
        background: rgba(233, 161, 59, .10);
        color: #ffd694;
        letter-spacing: .03em;
    }
    .tva-logout {
        font-family: var(--font-mono);
        font-size: 11px;
        letter-spacing: .22em;
        text-transform: uppercase;
        text-decoration: none;
        color: #d9b47a;
        border: 1px solid var(--tva-line);
        padding: 7px 14px;
        transition: all .18s ease;
        white-space: nowrap;
    }
    .tva-logout:hover {
        color: #1a1208;
        background: var(--tva-amber);
        border-color: var(--tva-amber);
        text-decoration: none;
    }

    /* --- panel principal ------------------------------------ */
    .tva-panel {
        background: linear-gradient(180deg, var(--tva-panel), #161009);
        border: 1px solid var(--tva-line);
        box-shadow: 0 34px 70px -34px #000, inset 0 1px 0 rgba(255, 255, 255, .035);
        position: relative;
    }
    .tva-panel::before {
        content: "";
        position: absolute;
        top: 0; left: 0;
        width: 26px; height: 26px;
        border-top: 2px solid var(--tva-amber);
        border-left: 2px solid var(--tva-amber);
        opacity: .55;
        pointer-events: none;
    }

    .tva-panel-head {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        padding: 12px 20px;
        background: linear-gradient(180deg, #e2ab45, #cd8b2a);
        border-bottom: 1px solid #8d5c14;
    }
    .tva-panel-title {
        font-family: var(--font-display);
        font-size: 16px;
        letter-spacing: .2em;
        text-transform: uppercase;
        color: #21150a;
        font-weight: 600;
    }
    .tva-panel-meta { display: flex; align-items: center; gap: 14px; }
    .tva-pill {
        font-family: var(--font-mono);
        font-size: 10.5px;
        letter-spacing: .16em;
        text-transform: uppercase;
        color: #21150a;
        border: 1px solid rgba(33, 21, 10, .45);
        padding: 3px 9px;
        background: rgba(255, 244, 214, .28);
        white-space: nowrap;
    }
    .tva-now {
        font-family: var(--font-mono);
        font-size: 10.5px;
        letter-spacing: .14em;
        text-transform: uppercase;
        color: #3a2409;
        max-width: 320px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
    .tva-now::before {
        content: "";
        display: inline-block;
        width: 7px; height: 7px;
        margin-right: 8px;
        border-radius: 50%;
        background: #4a2c06;
        vertical-align: 1px;
    }
    .tva-now.is-live::before { background: #7d1a05; animation: tva-blink 1s steps(2, start) infinite; }
    @keyframes tva-blink { to { visibility: hidden; } }

    /* --- tabla ---------------------------------------------- */
    .tva-scroll { overflow-x: auto; }
    .tva-table {
        width: 100%;
        min-width: 880px;
        border-collapse: collapse;
        font-size: 14px;
        margin: 0;
        background: transparent;
    }
    .tva-table thead th {
        font-family: var(--font-mono);
        font-size: 10.5px;
        font-weight: 600;
        letter-spacing: .18em;
        text-transform: uppercase;
        color: #cba877;
        background: #20180f;
        border-bottom: 1px solid var(--tva-line);
        padding: 12px 16px;
        text-align: left;
        white-space: nowrap;
    }
    .tva-table tbody td {
        padding: 12px 16px;
        border-bottom: 1px solid rgba(74, 53, 36, .55);
        color: var(--tva-cream);
        vertical-align: middle;
        background: transparent;
    }
    .tva-table tbody tr { transition: background .18s ease; }
    .tva-table tbody tr:hover { background: rgba(233, 161, 59, .055); }
    .tva-table tbody tr.is-active { background: rgba(210, 96, 26, .10); }
    .tva-table tbody tr.is-active td:first-child { box-shadow: inset 3px 0 0 var(--tva-orange); }
    .tva-table tbody tr:last-child td { border-bottom: 0; }

    .c-id    { width: 104px; }
    .c-plays { width: 148px; }
    .c-play  { width: 306px; }

    .tva-num {
        font-family: var(--font-mono);
        font-size: 15px;
        color: var(--tva-amber);
        letter-spacing: .07em;
    }
    .tva-song {
        font-size: 15px;
        font-weight: 600;
        letter-spacing: .015em;
        color: #fdf4e2;
    }
    .tva-path {
        display: inline-block;
        max-width: 260px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        vertical-align: middle;
        font-family: var(--font-mono);
        font-size: 12px;
        color: #9c8464;
    }
    .plays-num {
        display: inline-block;
        min-width: 2ch;
        font-family: var(--font-mono);
        font-size: 15px;
        color: #f0c987;
        transition: color .3s ease, text-shadow .3s ease;
    }
    .plays-num.bump { color: #ffd88a; text-shadow: 0 0 16px rgba(233, 161, 59, .9); }

    /* ecualizador junto al nombre */
    .tva-eq {
        display: none;
        height: 14px;
        margin-left: 9px;
        vertical-align: -2px;
    }
    .tva-eq i {
        display: inline-block;
        width: 2px;
        margin-right: 2px;
        background: var(--tva-amber);
        height: 5px;
        animation: tva-eq .9s ease-in-out infinite;
    }
    .tva-eq i:nth-child(2) { animation-delay: .18s; }
    .tva-eq i:nth-child(3) { animation-delay: .36s; }
    tr.is-active .tva-eq { display: inline-block; }
    @keyframes tva-eq {
        0%, 100% { height: 4px; }
        50%      { height: 14px; }
    }

    /* --- reproductor ---------------------------------------- */
    .tva-player { display: flex; align-items: center; gap: 12px; }

    .pp {
        width: 38px; height: 38px;
        flex: 0 0 auto;
        border-radius: 50%;
        border: 1px solid rgba(233, 161, 59, .55);
        background: radial-gradient(circle at 32% 26%, #2f2216, #191109);
        color: var(--tva-amber);
        display: grid;
        place-items: center;
        cursor: pointer;
        padding: 0;
        transition: all .18s ease;
    }
    .pp:hover {
        border-color: var(--tva-amber);
        box-shadow: 0 0 16px rgba(233, 161, 59, .38);
        transform: translateY(-1px);
    }
    .pp:focus-visible { outline: 2px solid #ffd08a; outline-offset: 3px; }
    .pp.is-playing {
        background: linear-gradient(180deg, #efb255, #cf7f1f);
        border-color: #f6cd92;
        color: #1a1108;
        box-shadow: 0 0 20px rgba(233, 161, 59, .5);
    }
    .pp-ico {
        width: 0; height: 0;
        border-left: 9px solid currentColor;
        border-top: 6px solid transparent;
        border-bottom: 6px solid transparent;
        margin-left: 3px;
    }
    .pp.is-playing .pp-ico {
        width: 9px; height: 12px;
        border: 0;
        margin-left: 0;
        background: linear-gradient(to right,
            currentColor 0 3px, transparent 3px 6px, currentColor 6px 9px);
    }

    .track { flex: 1 1 auto; min-width: 0; display: flex; flex-direction: column; gap: 6px; }
    .bar {
        position: relative;
        height: 6px;
        background: rgba(255, 255, 255, .07);
        border: 1px solid rgba(74, 53, 36, .95);
        cursor: pointer;
        overflow: hidden;
    }
    .bar:hover { border-color: rgba(233, 161, 59, .6); }
    .fill {
        display: block;
        height: 100%;
        width: 0;
        background: linear-gradient(90deg, var(--tva-orange), var(--tva-amber));
        transition: width .1s linear;
    }
    .meta {
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-family: var(--font-mono);
        font-size: 10.5px;
        letter-spacing: .1em;
        color: #a68e6c;
    }
    .t-dur::before { content: "/ "; opacity: .55; }

    /* --- vacio / pie ---------------------------------------- */
    .tva-empty {
        padding: 30px 20px;
        text-align: center;
        font-family: var(--font-mono);
        font-size: 12.5px;
        letter-spacing: .1em;
        text-transform: uppercase;
        color: var(--tva-muted);
    }
    .tva-empty strong { color: var(--tva-amber); }

    .tva p.tva-foot {
        display: flex;
        align-items: center;
        gap: 16px;
        margin: 32px 0 6px;
        font-family: var(--font-mono);
        font-size: 10.5px;
        letter-spacing: .42em;
        text-transform: uppercase;
        color: #b39a76;
        white-space: nowrap;
    }
    .tva-foot::before, .tva-foot::after {
        content: "";
        height: 1px;
        flex: 1 1 auto;
        background: linear-gradient(to right, rgba(74,53,36,0), rgba(74,53,36,.9), rgba(74,53,36,0));
    }

    @media (max-width: 760px) {
        .tva { padding: 24px 12px 6px; }
        .tva-head { flex-direction: column; align-items: flex-start; gap: 16px; }
        .tva-case { text-align: left; }
        .tva-barcode { margin-left: 0; width: 130px; }
        .tva-idbar { flex-direction: column; align-items: flex-start; }
        .tva-now { display: none; }
        .tva p.tva-foot { letter-spacing: .18em; font-size: 9px; }
    }
</style>

<div class="tva">

    <header class="tva-head">
        <div class="tva-brand">
            <div class="tva-seal" aria-hidden="true"><span>TVA</span></div>
            <div>
                <p class="tva-eyebrow">Time Variance Authority</p>
                <h1 class="tva-title">Archivo Sagrado de Audio</h1>
                <p class="tva-sub">Departamento de Registros Sonoros &middot; Nivel 7 &middot; Sector 19</p>
            </div>
        </div>
        <div class="tva-case">
            <span class="tva-case-lbl">Expediente</span>
            <span class="tva-case-no">SONG / 0774-A</span>
            <div class="tva-barcode" aria-hidden="true"></div>
        </div>
    </header>

    <section class="tva-idbar">
        <div class="tva-id-left">
            <span class="tva-tag">Agente</span>
            <p class="tva-welcome">
                Welcome,<span class="tva-user"><asp:Label ID="lblUserName" runat="server" Text="nombre.apellido" /></span>
            </p>
        </div>
        <a class="tva-logout" runat="server" href="~/Logout">Logout</a>
    </section>

    <section class="tva-panel">
        <div class="tva-panel-head">
            <h2 class="tva-panel-title">Song list</h2>
            <div class="tva-panel-meta">
                <span class="tva-now" id="nowPlaying" aria-live="polite">sin reproduccion</span>
                <span class="tva-pill"><asp:Label ID="lblSongCount" runat="server" Text="0" /> registros</span>
            </div>
        </div>

        <div class="tva-scroll">
            <table class="tva-table">
                <thead>
                    <tr>
                        <th class="c-id" scope="col">ID Canci&oacute;n</th>
                        <th class="c-name" scope="col">Nombre</th>
                        <th class="c-path" scope="col">Ruta</th>
                        <th class="c-plays" scope="col">Reproducciones</th>
                        <th class="c-play" scope="col">Reproducir</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptSongs" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td class="c-id"><span class="tva-num"><%# Eval("ID_SONG") %></span></td>
                                <td class="c-name">
                                    <span class="tva-song"><%# H(Eval("SONG_NAME")) %></span><span class="tva-eq" aria-hidden="true"><i></i><i></i><i></i></span>
                                </td>
                                <td class="c-path">
                                    <span class="tva-path" title="<%# H(Eval("SONG_PATH")) %>"><%# H(Eval("SONG_PATH")) %></span>
                                </td>
                                <td class="c-plays"><span class="plays-num"><%# Eval("PLAYS") %></span></td>
                                <td class="c-play">
                                    <div class="tva-player" data-id="<%# Eval("ID_SONG") %>" data-src="<%# SongUrl(Eval("SONG_PATH")) %>">
                                        <button type="button" class="pp" aria-label="Reproducir"><span class="pp-ico"></span></button>
                                        <div class="track">
                                            <div class="bar" role="slider" tabindex="0" aria-label="Progreso de la cancion" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><span class="fill"></span></div>
                                            <div class="meta"><span class="t-time">0:00</span><span class="t-dur">--:--</span></div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="tva-empty">
            <p><strong>Sin registros.</strong> La l&iacute;nea temporal no contiene canciones en TBL_SONG.</p>
        </asp:Panel>
    </section>

    <p class="tva-foot">For all time &middot; Always</p>

</div>

<script type="text/javascript">
    (function () {
        "use strict";

        var audio = new Audio();
        var currentPlayer = null;
        var logged = {};
        var endpoint = "<%= ResolveUrl("~/Song.aspx") %>/RegisterPlay";
        var nowLabel = document.getElementById("nowPlaying");

        audio.preload = "metadata";

        function fmt(sec) {
            if (!isFinite(sec) || sec < 0) { sec = 0; }
            var m = Math.floor(sec / 60);
            var s = Math.floor(sec % 60);
            return m + ":" + (s < 10 ? "0" + s : s);
        }

        function rowOf(player) { return player.parentNode.parentNode; }

        function setPlaying(player, playing) {
            var btn = player.querySelector(".pp");
            btn.classList.toggle("is-playing", playing);
            btn.setAttribute("aria-label", playing ? "Pausar" : "Reproducir");
            rowOf(player).classList.toggle("is-active", playing);
        }

        function reset(player) {
            if (!player) { return; }
            setPlaying(player, false);
            player.querySelector(".fill").style.width = "0%";
            player.querySelector(".t-time").textContent = "0:00";
            player.querySelector(".bar").setAttribute("aria-valuenow", "0");
        }

        function announce(name) {
            if (!nowLabel) { return; }
            if (name) {
                nowLabel.textContent = name;
                nowLabel.classList.add("is-live");
            } else {
                nowLabel.textContent = "sin reproduccion";
                nowLabel.classList.remove("is-live");
            }
        }

        /* Registra la reproduccion en la base de datos (Code Behind: [WebMethod]). */
        function logPlay(id, playsEl) {
            if (!id || logged[id]) { return; }
            logged[id] = true;
            try {
                fetch(endpoint, {
                    method: "POST",
                    headers: { "Content-Type": "application/json; charset=utf-8" },
                    body: JSON.stringify({ idSong: parseInt(id, 10) })
                }).then(function (r) { return r.json(); }).then(function (res) {
                    if (res && typeof res.d !== "undefined" && playsEl) {
                        playsEl.textContent = res.d;
                        playsEl.classList.add("bump");
                        window.setTimeout(function () { playsEl.classList.remove("bump"); }, 800);
                    }
                }).catch(function () { /* contador no critico */ });
            } catch (e) { /* navegador sin fetch */ }
        }

        function play(player) {
            var src = player.getAttribute("data-src");
            var name = rowOf(player).querySelector(".tva-song").textContent;
            var playsEl = rowOf(player).querySelector(".plays-num");

            if (currentPlayer && currentPlayer !== player) { reset(currentPlayer); }

            currentPlayer = player;
            audio.src = src;
            audio.load();

            var promise = audio.play();
            if (promise && promise.catch) {
                promise.catch(function () {
                    setPlaying(player, false);
                    announce(null);
                });
            }
            setPlaying(player, true);
            announce(name);
            logPlay(player.getAttribute("data-id"), playsEl);
        }

        document.addEventListener("click", function (ev) {
            var target = ev.target;

            var btn = target.closest ? target.closest(".pp") : null;
            if (btn) {
                var player = btn.closest(".tva-player");
                if (currentPlayer === player && !audio.paused) {
                    audio.pause();
                    setPlaying(player, false);
                    announce(null);
                } else {
                    play(player);
                }
                return;
            }

            var bar = target.closest ? target.closest(".bar") : null;
            if (bar) {
                var owner = bar.closest(".tva-player");
                if (owner === currentPlayer && audio.duration) {
                    var rect = bar.getBoundingClientRect();
                    var ratio = (ev.clientX - rect.left) / rect.width;
                    if (ratio < 0) { ratio = 0; }
                    if (ratio > 1) { ratio = 1; }
                    audio.currentTime = ratio * audio.duration;
                }
            }
        });

        document.addEventListener("keydown", function (ev) {
            if (ev.key !== "Enter" && ev.key !== " ") { return; }
            var bar = ev.target.classList && ev.target.classList.contains("bar") ? ev.target : null;
            if (!bar) { return; }
            ev.preventDefault();
            var owner = bar.closest(".tva-player");
            if (owner === currentPlayer && audio.duration) {
                audio.currentTime = (audio.currentTime + 5) % audio.duration;
            }
        });

        audio.addEventListener("loadedmetadata", function () {
            if (!currentPlayer) { return; }
            var dur = isFinite(audio.duration) ? fmt(audio.duration) : "--:--";
            currentPlayer.querySelector(".t-dur").textContent = dur;
        });

        audio.addEventListener("timeupdate", function () {
            if (!currentPlayer || !audio.duration) { return; }
            var ratio = audio.currentTime / audio.duration;
            currentPlayer.querySelector(".fill").style.width = (ratio * 100) + "%";
            currentPlayer.querySelector(".t-time").textContent = fmt(audio.currentTime);
            currentPlayer.querySelector(".bar").setAttribute("aria-valuenow", Math.round(ratio * 100));
        });

        audio.addEventListener("ended", function () {
            if (currentPlayer) { reset(currentPlayer); }
            currentPlayer = null;
            announce(null);
        });
    })();
</script>

</asp:Content>
