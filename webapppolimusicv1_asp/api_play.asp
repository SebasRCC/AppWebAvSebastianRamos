<%@ LANGUAGE="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' ============================================================
'  api_play.asp · Incrementa el contador de reproducciones
'  Responde JSON: { "ok": true, "plays": 12 }
' ============================================================
Response.ContentType = "application/json"
Response.CharSet = "UTF-8"
Response.CodePage = 65001

Dim songId, plays

songId = Num(Request.Form("id"), 0)
If songId <= 0 Then songId = Num(Request.QueryString("id"), 0)

If Not IsLoggedIn() Or songId <= 0 Then
    Response.Write "{""ok"":false,""error"":""unauthorized""}"
    DbClose
    Response.End
End If

DbRun "UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS, 0) + 1 WHERE ID_SONG = ?", _
      Array(Array("@s", adInteger, 4, songId))

plays = Num(DbScalar("SELECT ISNULL(PLAYS, 0) FROM TBL_SONG WHERE ID_SONG = ?", _
        Array(Array("@s", adInteger, 4, songId))), 0)

DbClose
Response.Write "{""ok"":true,""plays"":" & plays & "}"
Response.End
%>
