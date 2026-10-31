<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic · Song list</title>
    <style type="text/css">
        :root {
            --bg: #0a0a0b;
            --panel: #121214;
            --row: #17171b;
            --row-hi: #212127;
            --line: rgba(237, 230, 214, 0.09);
            --line-hi: rgba(237, 230, 214, 0.20);
            --text: #f3efe6;
            --text-2: #b8b1a5;
            --muted: #8a8378;
            --amber: #f0a13c;
            --amber-2: #e07b2a;
            --amber-soft: rgba(240, 161, 60, 0.14);
            --cream: #efe8d8;
            --teal: #2f5d55;
            --font: "Segoe UI", system-ui, -apple-system, "Helvetica Neue", Arial, sans-serif;
            --mono: "Cascadia Mono", Consolas, "SF Mono", ui-monospace, monospace;
        }

        * { box-sizing: border-box; }

        html, body {
            margin: 0;
            padding: 0;
        }

        body {
            min-height: 100vh;
            font-family: var(--font);
            color: var(--text);
            background:
                radial-gradient(1100px 460px at 8% -12%, rgba(240, 161, 60, 0.16), transparent 62%),
                radial-gradient(900px 420px at 100% -6%, rgba(47, 93, 85, 0.22), transparent 58%),
                var(--bg);
            background-attachment: fixed;
            -webkit-font-smoothing: antialiased;
        }

        /* ---------- Top bar ---------- */
        .topbar {
            position: sticky;
            top: 0;
            z-index: 20;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            height: 78px;
            padding: 0 34px;
            background: rgba(10, 10, 11, 0.82);
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            border-bottom: 1px solid var(--line);
        }

        .topbar::after {
            content: "";
            position: absolute;
            left: 0;
            right: 0;
            bottom: -1px;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(240, 161, 60, 0.55), transparent);
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 14px;
            min-width: 0;
        }

        .seal {
            flex: 0 0 auto;
            display: grid;
            place-items: center;
            width: 42px;
            height: 42px;
            border-radius: 50%;
            border: 1px solid rgba(240, 161, 60, 0.55);
            box-shadow: 0 0 0 3px rgba(240, 161, 60, 0.08), inset 0 0 18px rgba(240, 161, 60, 0.14);
            font-family: var(--mono);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.12em;
            color: var(--amber);
            text-indent: 0.12em;
        }

        .brand-text { min-width: 0; }

        .wordmark {
            font-size: 17px;
            font-weight: 700;
            letter-spacing: 0.03em;
            color: var(--cream);
            line-height: 1.1;
        }

        .tagline {
            margin-top: 3px;
            font-family: var(--mono);
            font-size: 9.5px;
            letter-spacing: 0.22em;
            text-transform: uppercase;
            color: var(--muted);
            white-space: nowrap;
        }

        .user-area {
            display: flex;
            align-items: center;
            gap: 14px;
            min-width: 0;
        }

        .user-chip {
            display: flex;
            align-items: center;
            gap: 11px;
            min-width: 0;
        }

        .avatar {
            position: relative;
            flex: 0 0 auto;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            overflow: hidden;
            background: linear-gradient(145deg, #3a2a18, #1a1512);
            box-shadow: 0 0 0 1px rgba(240, 161, 60, 0.55), 0 0 0 4px rgba(240, 161, 60, 0.10);
        }

        .avatar-initials {
            position: absolute;
            inset: 0;
            display: grid;
            place-items: center;
            font-family: var(--mono);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.06em;
            color: var(--amber);
        }

        .avatar-img {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .user-text { min-width: 0; }

        .welcome {
            display: block;
            font-family: var(--mono);
            font-size: 9.5px;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            color: var(--muted);
        }

        .user-name {
            display: block;
            max-width: 32vw;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            font-size: 14px;
            font-weight: 600;
            color: var(--cream);
            line-height: 1.35;
        }

        .logout {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            height: 36px;
            padding: 0 16px;
            border-radius: 999px;
            border: 1px solid var(--line-hi);
            color: var(--text-2);
            font-size: 12.5px;
            font-weight: 600;
            letter-spacing: 0.02em;
            text-decoration: none;
            transition: all 0.18s ease;
        }

        .logout:hover {
            border-color: rgba(240, 161, 60, 0.75);
            color: var(--amber);
            background: var(--amber-soft);
        }

        .logout svg {
            width: 14px;
            height: 14px;
            fill: currentColor;
        }

        /* ---------- Layout ---------- */
        .shell {
            max-width: 1240px;
            margin: 0 auto;
            padding: 42px 34px 70px;
        }

        .page-head {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 22px;
        }

        .eyebrow {
            font-family: var(--mono);
            font-size: 10px;
            letter-spacing: 0.26em;
            text-transform: uppercase;
            color: var(--amber);
            margin: 0 0 8px;
        }

        h1 {
            margin: 0;
            font-size: 30px;
            line-height: 1.15;
            font-weight: 700;
            letter-spacing: -0.01em;
            color: var(--cream);
        }

        .count-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            height: 30px;
            padding: 0 14px;
            border-radius: 999px;
            border: 1px solid var(--line-hi);
            background: rgba(237, 230, 214, 0.04);
            font-family: var(--mono);
            font-size: 11px;
            letter-spacing: 0.08em;
            color: var(--text-2);
            white-space: nowrap;
        }

        .count-pill b {
            color: var(--amber);
            font-weight: 700;
        }

        .panel {
            position: relative;
            border: 1px solid var(--line);
            border-radius: 18px;
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.035), rgba(255, 255, 255, 0.008));
            box-shadow: 0 24px 60px -32px rgba(0, 0, 0, 0.95);
            overflow: hidden;
        }

        /* ---------- Table ---------- */
        .song-table {
            width: calc(100% - 20px);
            margin: 0 10px 10px;
            border-collapse: separate;
            border-spacing: 0 5px;
        }

        .song-table thead th {
            padding: 14px 14px 10px;
            text-align: left;
            font-family: var(--mono);
            font-size: 9.5px;
            font-weight: 600;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            color: var(--muted);
            white-space: nowrap;
            border-bottom: 1px solid var(--line);
        }

        .song-table thead th.c-id,
        .song-table thead th.c-plays { text-align: center; }

        .song-row td {
            padding: 13px 14px;
            background: var(--row);
            border-top: 1px solid transparent;
            border-bottom: 1px solid transparent;
            vertical-align: middle;
            transition: background 0.16s ease;
        }

        .song-row td:first-child {
            border-radius: 12px 0 0 12px;
            border-left: 1px solid transparent;
        }

        .song-row td:last-child {
            border-radius: 0 12px 12px 0;
            border-right: 1px solid transparent;
        }

        .song-row:hover td {
            background: var(--row-hi);
            border-color: rgba(237, 230, 214, 0.07);
        }

        .song-row.is-playing td {
            background: #1d1c20;
            border-color: rgba(240, 161, 60, 0.22);
        }

        .song-row.is-playing td:first-child {
            box-shadow: inset 3px 0 0 var(--amber);
        }

        .c-id { width: 92px; text-align: center; }

        .idx {
            display: inline-block;
            min-width: 26px;
            font-family: var(--mono);
            font-size: 12.5px;
            color: var(--muted);
            transition: color 0.16s ease;
        }

        .song-row:hover .idx { color: var(--amber); }

        .c-name { width: 24%; min-width: 150px; }

        .song-name {
            display: block;
            font-size: 14.5px;
            font-weight: 600;
            color: var(--cream);
            letter-spacing: 0.005em;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .song-sub {
            display: block;
            margin-top: 3px;
            font-family: var(--mono);
            font-size: 10px;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            color: var(--muted);
        }

        .c-path { width: auto; }

        .path {
            display: block;
            max-width: 330px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            font-family: var(--mono);
            font-size: 11.5px;
            color: var(--text-2);
            opacity: 0.85;
        }

        .c-plays { width: 132px; text-align: center; }

        .plays {
            display: inline-block;
            min-width: 38px;
            padding: 4px 11px;
            border-radius: 999px;
            background: var(--amber-soft);
            border: 1px solid rgba(240, 161, 60, 0.28);
            font-family: var(--mono);
            font-size: 11.5px;
            font-weight: 700;
            color: var(--amber);
            font-variant-numeric: tabular-nums;
        }

        .c-player { width: 392px; }

        /* ---------- Player ---------- */
        .player {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .play-btn {
            flex: 0 0 auto;
            display: grid;
            place-items: center;
            width: 40px;
            height: 40px;
            padding: 0;
            border-radius: 50%;
            border: 1px solid var(--line-hi);
            background: rgba(239, 232, 216, 0.07);
            color: var(--cream);
            cursor: pointer;
            transition: transform 0.15s ease, background 0.15s ease, color 0.15s ease, border-color 0.15s ease;
        }

        .play-btn:hover {
            background: var(--amber);
            border-color: var(--amber);
            color: #150f07;
            transform: scale(1.06);
        }

        .play-btn:active { transform: scale(0.96); }

        .play-btn svg {
            width: 17px;
            height: 17px;
            fill: currentColor;
            display: block;
        }

        .play-btn .ic-play { margin-left: 2px; }
        .play-btn .ic-pause { display: none; }

        .song-row.is-playing .play-btn {
            background: var(--amber);
            border-color: var(--amber);
            color: #150f07;
            box-shadow: 0 0 22px -4px rgba(240, 161, 60, 0.6);
        }

        .song-row.is-playing .ic-play { display: none; }
        .song-row.is-playing .ic-pause { display: block; }

        .p-main {
            flex: 1 1 auto;
            min-width: 0;
        }

        .p-track {
            position: relative;
            height: 16px;
            display: flex;
            align-items: center;
            cursor: pointer;
        }

        .p-track::before {
            content: "";
            position: absolute;
            left: 0;
            right: 0;
            height: 4px;
            border-radius: 999px;
            background: rgba(239, 232, 216, 0.16);
        }

        .p-fill {
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            height: 4px;
            width: 0;
            border-radius: 999px;
            background: linear-gradient(90deg, var(--amber-2), var(--amber));
            pointer-events: none;
        }

        .p-handle {
            position: absolute;
            right: -5px;
            top: 50%;
            width: 10px;
            height: 10px;
            margin-top: -5px;
            border-radius: 50%;
            background: var(--cream);
            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.6);
            opacity: 0;
            transition: opacity 0.15s ease;
        }

        .song-row:hover .p-handle,
        .song-row.is-playing .p-handle { opacity: 1; }

        .p-time {
            margin-top: 5px;
            font-family: var(--mono);
            font-size: 10.5px;
            color: var(--muted);
            font-variant-numeric: tabular-nums;
            white-space: nowrap;
        }

        .p-time .p-cur { color: var(--text-2); }
        .song-row.is-playing .p-time .p-cur { color: var(--amber); }

        .vol {
            flex: 0 0 auto;
            display: flex;
            align-items: center;
            gap: 7px;
            padding-right: 4px;
        }

        .vol svg {
            width: 15px;
            height: 15px;
            fill: var(--muted);
            display: block;
        }

        .vol-range {
            -webkit-appearance: none;
            appearance: none;
            width: 62px;
            height: 4px;
            border-radius: 999px;
            background: rgba(239, 232, 216, 0.18);
            outline: none;
            cursor: pointer;
            accent-color: var(--amber);
        }

        .vol-range::-webkit-slider-thumb {
            -webkit-appearance: none;
            appearance: none;
            width: 11px;
            height: 11px;
            border-radius: 50%;
            background: var(--cream);
            border: none;
            cursor: pointer;
        }

        .vol-range::-moz-range-thumb {
            width: 11px;
            height: 11px;
            border: none;
            border-radius: 50%;
            background: var(--cream);
            cursor: pointer;
        }

        .more-btn {
            flex: 0 0 auto;
            display: grid;
            place-items: center;
            width: 28px;
            height: 28px;
            padding: 0;
            border: none;
            border-radius: 50%;
            background: transparent;
            color: var(--muted);
            cursor: pointer;
            transition: color 0.15s ease, background 0.15s ease;
        }

        .more-btn:hover {
            color: var(--cream);
            background: rgba(239, 232, 216, 0.09);
        }

        .more-btn svg {
            width: 16px;
            height: 16px;
            fill: currentColor;
        }

        /* ---------- Empty / error ---------- */
        .empty {
            display: block;
            padding: 34px 26px 40px;
            text-align: center;
            font-size: 13.5px;
            color: var(--text-2);
        }

        .footer {
            margin-top: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-family: var(--mono);
            font-size: 10px;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            color: rgba(138, 131, 120, 0.75);
        }

        .footer .dot {
            width: 5px;
            height: 5px;
            border-radius: 50%;
            background: var(--amber);
            box-shadow: 0 0 10px rgba(240, 161, 60, 0.9);
        }

        /* ---------- Responsive ---------- */
        @media (max-width: 1080px) {
            .c-path, .song-table thead th.c-path { display: none; }
            .c-player { width: 340px; }
        }

        @media (max-width: 820px) {
            .topbar { height: auto; padding: 14px 18px; flex-wrap: wrap; gap: 12px; }
            .shell { padding: 28px 18px 60px; }
            h1 { font-size: 24px; }
            .vol { display: none; }
            .c-player { width: 240px; }
            .c-plays { width: 92px; }
            .c-id { width: 62px; }
            .user-name { max-width: 44vw; }
        }

        @media (max-width: 560px) {
            .song-table { border-spacing: 0 6px; }
            .song-table thead { display: none; }
            .song-row td { padding: 12px 10px; }
            .c-player { width: auto; }
            .c-plays, .c-id { display: none; }
            .tagline { display: none; }
        }

        @media (prefers-reduced-motion: reduce) {
            * { transition: none !important; }
        }
    </style>
</head>
<body>
    <form id="formSong" runat="server">
        <header class="topbar">
            <div class="brand">
                <div class="seal">TVA</div>
                <div class="brand-text">
                    <div class="wordmark">PoliMusic</div>
                    <div class="tagline">Temporal Song Archive</div>
                </div>
            </div>
            <div class="user-area">
                <div class="user-chip">
                    <div class="avatar">
                        <span class="avatar-initials"><asp:Label ID="lblUserInitials" runat="server" /></span>
                        <asp:Image ID="imgUserPhoto" runat="server" CssClass="avatar-img" />
                    </div>
                    <div class="user-text">
                        <span class="welcome">Welcome</span>
                        <asp:Label ID="lblUserName" runat="server" CssClass="user-name" />
                    </div>
                </div>
                <a class="logout" href="Logout.aspx" title="Close session">
                    <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M10 3H5a2 2 0 00-2 2v14a2 2 0 002 2h5v-2H5V5h5V3zm7.6 4.4L20.2 10H12v4h8.2l-2.6 2.6L19 18l5-5-5-5-1.4 1.4z" /></svg>
                    Logout
                </a>
            </div>
        </header>

        <main class="shell">
            <div class="page-head">
                <div>
                    <p class="eyebrow">Archive · Branch 2026</p>
                    <h1>Song list</h1>
                </div>
                <span class="count-pill"><b><asp:Label ID="lblSongCount" runat="server" Text="0" /></b> songs</span>
            </div>

            <section class="panel">
                <table class="song-table">
                    <thead>
                        <tr>
                            <th class="c-id" scope="col">ID Canción</th>
                            <th class="c-name" scope="col">Nombre</th>
                            <th class="c-path" scope="col">Ruta</th>
                            <th class="c-plays" scope="col">Reproducciones</th>
                            <th class="c-player" scope="col">Reproducir</th>
                        </tr>
                    </thead>
                    <asp:Repeater ID="rptSongs" runat="server">
                        <ItemTemplate>
                            <tr class="song-row" data-id='<%# Eval("ID") %>'>
                                <td class="c-id"><span class="idx"><%# Eval("ID") %></span></td>
                                <td class="c-name">
                                    <span class="song-name"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></span>
                                    <span class="song-sub">Track <%# Eval("ID") %></span>
                                </td>
                                <td class="c-path">
                                    <span class="path" title='<%# Server.HtmlEncode(Convert.ToString(Eval("Path"))) %>'><%# Server.HtmlEncode(Convert.ToString(Eval("Path"))) %></span>
                                </td>
                                <td class="c-plays"><span class="plays"><%# Eval("Plays") %></span></td>
                                <td class="c-player">
                                    <div class="player">
                                        <button type="button" class="play-btn" aria-label="Play">
                                            <svg class="ic-play" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5v14l11-7z" /></svg>
                                            <svg class="ic-pause" viewBox="0 0 24 24" aria-hidden="true"><path d="M7 5h4v14H7zm6 0h4v14h-4z" /></svg>
                                        </button>
                                        <div class="p-main">
                                            <div class="p-track" role="slider" tabindex="0" aria-label="Seek">
                                                <div class="p-fill"><span class="p-handle"></span></div>
                                            </div>
                                            <div class="p-time"><span class="p-cur">0:00</span> / <span class="p-dur">0:00</span></div>
                                        </div>
                                        <div class="vol">
                                            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 9v6h4l5 4V5L7 9H3zm12.5 3a4.5 4.5 0 00-2.5-4v8a4.5 4.5 0 002.5-4zM13 2.2v2.1a7.8 7.8 0 010 15.4v2.1a9.9 9.9 0 000-19.6z" /></svg>
                                            <input type="range" class="vol-range" min="0" max="100" value="80" aria-label="Volume" />
                                        </div>
                                        <button type="button" class="more-btn" aria-label="More options">
                                            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 8a2 2 0 110-4 2 2 0 010 4zm0 6a2 2 0 110-4 2 2 0 010 4zm0 6a2 2 0 110-4 2 2 0 010 4z" /></svg>
                                        </button>
                                        <audio preload="metadata" src='<%# ResolveSongPath(Eval("Path")) %>'></audio>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </table>
                <asp:Label ID="lblMessage" runat="server" CssClass="empty" Visible="false" />
            </section>

            <div class="footer">
                <span class="dot"></span>
                <span>PoliMusic · Song module</span>
            </div>
        </main>
    </form>

    <script type="text/javascript">
        (function () {
            "use strict";

            var rows = document.querySelectorAll(".song-row");
            var audios = [];

            function fmt(seconds) {
                if (!isFinite(seconds) || seconds < 0) { seconds = 0; }
                var m = Math.floor(seconds / 60);
                var s = Math.floor(seconds % 60);
                return m + ":" + (s < 10 ? "0" : "") + s;
            }

            function pauseOthers(current) {
                for (var i = 0; i < audios.length; i++) {
                    if (audios[i] !== current && !audios[i].paused) {
                        audios[i].pause();
                    }
                }
            }

            function registerPlay(idSong, playsEl) {
                var url = "PlayCounter.ashx?id=" + encodeURIComponent(idSong) + "&t=" + new Date().getTime();
                var xhr = new XMLHttpRequest();
                xhr.open("GET", url, true);
                xhr.onreadystatechange = function () {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        try {
                            var data = JSON.parse(xhr.responseText);
                            if (data && typeof data.plays === "number") {
                                playsEl.textContent = data.plays;
                            }
                        } catch (err) { }
                    }
                };
                xhr.send(null);
            }

            for (var i = 0; i < rows.length; i++) {
                (function (row) {
                    var audio = row.querySelector("audio");
                    if (!audio) { return; }

                    audios.push(audio);

                    var btn = row.querySelector(".play-btn");
                    var track = row.querySelector(".p-track");
                    var fill = row.querySelector(".p-fill");
                    var cur = row.querySelector(".p-cur");
                    var dur = row.querySelector(".p-dur");
                    var vol = row.querySelector(".vol-range");
                    var playsEl = row.querySelector(".plays");
                    var idSong = row.getAttribute("data-id");
                    var counted = false;

                    audio.volume = 0.8;

                    function setPlaying(isPlaying) {
                        if (isPlaying) {
                            row.classList.add("is-playing");
                        } else {
                            row.classList.remove("is-playing");
                        }
                        btn.setAttribute("aria-label", isPlaying ? "Pause" : "Play");
                    }

                    btn.addEventListener("click", function () {
                        if (audio.paused) {
                            pauseOthers(audio);
                            var promise = audio.play();
                            if (promise && typeof promise.catch === "function") {
                                promise.catch(function () { setPlaying(false); });
                            }
                        } else {
                            audio.pause();
                        }
                    });

                    audio.addEventListener("play", function () {
                        pauseOthers(audio);
                        setPlaying(true);
                        if (!counted) {
                            counted = true;
                            if (playsEl) { registerPlay(idSong, playsEl); }
                        }
                    });

                    audio.addEventListener("pause", function () { setPlaying(false); });

                    audio.addEventListener("ended", function () {
                        setPlaying(false);
                        fill.style.width = "0%";
                        cur.textContent = "0:00";
                    });

                    audio.addEventListener("loadedmetadata", function () {
                        dur.textContent = fmt(audio.duration);
                    });

                    audio.addEventListener("timeupdate", function () {
                        var total = audio.duration;
                        if (total && isFinite(total) && total > 0) {
                            fill.style.width = ((audio.currentTime / total) * 100) + "%";
                        }
                        cur.textContent = fmt(audio.currentTime);
                    });

                    track.addEventListener("click", function (e) {
                        if (!audio.duration || !isFinite(audio.duration)) { return; }
                        var rect = track.getBoundingClientRect();
                        var ratio = (e.clientX - rect.left) / rect.width;
                        if (ratio < 0) { ratio = 0; }
                        if (ratio > 1) { ratio = 1; }
                        audio.currentTime = ratio * audio.duration;
                    });

                    track.addEventListener("keydown", function (e) {
                        if (e.keyCode === 39) { audio.currentTime = Math.min(audio.currentTime + 5, audio.duration || 0); }
                        if (e.keyCode === 37) { audio.currentTime = Math.max(audio.currentTime - 5, 0); }
                    });

                    vol.addEventListener("input", function () {
                        audio.volume = vol.value / 100;
                    });
                })(rows[i]);
            }
        })();
    </script>
</body>
</html>
