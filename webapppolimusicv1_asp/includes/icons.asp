<%
' ============================================================
'  PoliMusic · Set de iconos SVG (trazo, sin emojis)
'  Uso:  Ico("play", 20)
' ============================================================
Function Ico(name, sz)
    Dim o, p
    o = "<svg class=""ico"" width=""" & sz & """ height=""" & sz & """ viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""1.7"" stroke-linecap=""round"" stroke-linejoin=""round"" aria-hidden=""true"">"
    Select Case name
        Case "home"     : p = "<path d=""M3 10.5 12 3l9 7.5""/><path d=""M5 9.5V21h14V9.5""/><path d=""M9.5 21v-6h5v6""/>"
        Case "music"    : p = "<circle cx=""7"" cy=""18"" r=""3""/><circle cx=""18"" cy=""15"" r=""3""/><path d=""M10 18V7l11-3v11""/>"
        Case "mic"      : p = "<rect x=""9"" y=""2.5"" width=""6"" height=""11"" rx=""3""/><path d=""M5.5 11a6.5 6.5 0 0 0 13 0""/><path d=""M12 17.5V21""/>"
        Case "disc"     : p = "<circle cx=""12"" cy=""12"" r=""9""/><circle cx=""12"" cy=""12"" r=""2.6""/><path d=""M12 3a9 9 0 0 1 9 9""/>"
        Case "list"     : p = "<path d=""M4 7h11""/><path d=""M4 12h11""/><path d=""M4 17h7""/><path d=""M19 13v6""/><circle cx=""19"" cy=""10"" r=""1.6""/>"
        Case "logout"   : p = "<path d=""M15 4h3.5A1.5 1.5 0 0 1 20 5.5v13A1.5 1.5 0 0 1 18.5 20H15""/><path d=""M10 8l-4 4 4 4""/><path d=""M6 12h9""/>"
        Case "play"     : p = "<path d=""M8 5.5v13l11-6.5z"" fill=""currentColor"" stroke=""none""/>"
        Case "pause"    : p = "<rect x=""7"" y=""5"" width=""3.4"" height=""14"" rx=""1"" fill=""currentColor"" stroke=""none""/><rect x=""13.6"" y=""5"" width=""3.4"" height=""14"" rx=""1"" fill=""currentColor"" stroke=""none""/>"
        Case "prev"     : p = "<path d=""M18 6v12L9 12z"" fill=""currentColor"" stroke=""none""/><rect x=""5"" y=""6"" width=""2.2"" height=""12"" rx=""1"" fill=""currentColor"" stroke=""none""/>"
        Case "next"     : p = "<path d=""M6 6v12l9-6z"" fill=""currentColor"" stroke=""none""/><rect x=""16.8"" y=""6"" width=""2.2"" height=""12"" rx=""1"" fill=""currentColor"" stroke=""none""/>"
        Case "shuffle"  : p = "<path d=""M17 3.5 20.5 7 17 10.5""/><path d=""M3.5 7h3.2c2 0 3.4 1.1 4.6 2.8l2.4 3.4c1.2 1.7 2.6 2.8 4.6 2.8h2.2""/><path d=""M17 13.5 20.5 17 17 20.5""/><path d=""M3.5 17h3.2c2 0 3.4-1.1 4.6-2.8""/>"
        Case "repeat"   : p = "<path d=""M17 2.5 20.5 6 17 9.5""/><path d=""M20.5 6H7.5A3.5 3.5 0 0 0 4 9.5v1""/><path d=""M7 21.5 3.5 18 7 14.5""/><path d=""M3.5 18h13a3.5 3.5 0 0 0 3.5-3.5v-1""/>"
        Case "volume"   : p = "<path d=""M4 9.5h3.5L12 5.5v13L7.5 14.5H4z""/><path d=""M16 9a4.2 4.2 0 0 1 0 6""/><path d=""M18.6 6.5a8 8 0 0 1 0 11""/>"
        Case "plus"     : p = "<path d=""M12 5v14""/><path d=""M5 12h14""/>"
        Case "edit"     : p = "<path d=""M4 20h4l10-10-4-4L4 16z""/><path d=""M14.5 5.5 18.5 9.5""/>"
        Case "trash"    : p = "<path d=""M4 7h16""/><path d=""M9.5 7V4.8h5V7""/><path d=""M6.5 7l1 13h9l1-13""/>"
        Case "search"   : p = "<circle cx=""11"" cy=""11"" r=""6.5""/><path d=""M16 16l4 4""/>"
        Case "close"    : p = "<path d=""M6 6l12 12""/><path d=""M18 6 6 18""/>"
        Case "clock"    : p = "<circle cx=""12"" cy=""12"" r=""9""/><path d=""M12 7.5V12l3.5 2""/>"
        Case "headphones": p = "<path d=""M4 14v-2a8 8 0 0 1 16 0v2""/><rect x=""2.8"" y=""13.5"" width=""4"" height=""7"" rx=""2""/><rect x=""17.2"" y=""13.5"" width=""4"" height=""7"" rx=""2""/>"
        Case "user"     : p = "<circle cx=""12"" cy=""8.5"" r=""3.8""/><path d=""M4.5 20.5c1.4-3.6 4.2-5.3 7.5-5.3s6.1 1.7 7.5 5.3""/>"
        Case "shield"   : p = "<path d=""M12 3 5 6v5.5c0 4.2 2.9 7.6 7 9.5 4.1-1.9 7-5.3 7-9.5V6z""/><path d=""M9.2 12.2 11.4 14.4 15.2 10""/>"
        Case "sun"      : p = "<circle cx=""12"" cy=""12"" r=""4.6""/><path d=""M12 2.6v2.4""/><path d=""M12 19v2.4""/><path d=""M2.6 12H5""/><path d=""M19 12h2.4""/><path d=""M5.4 5.4 7.1 7.1""/><path d=""M16.9 16.9l1.7 1.7""/><path d=""M18.6 5.4 16.9 7.1""/><path d=""M7.1 16.9 5.4 18.6""/>"
        Case "chevron"  : p = "<path d=""M9 5l7 7-7 7""/>"
        Case "grid"     : p = "<rect x=""4"" y=""4"" width=""6.5"" height=""6.5"" rx=""1.6""/><rect x=""13.5"" y=""4"" width=""6.5"" height=""6.5"" rx=""1.6""/><rect x=""4"" y=""13.5"" width=""6.5"" height=""6.5"" rx=""1.6""/><rect x=""13.5"" y=""13.5"" width=""6.5"" height=""6.5"" rx=""1.6""/>"
        Case "arrow-left": p = "<path d=""M10 6 4 12l6 6""/><path d=""M4 12h16""/>"
        Case Else       : p = "<circle cx=""12"" cy=""12"" r=""9""/>"
    End Select
    Ico = o & p & "</svg>"
End Function
%>
