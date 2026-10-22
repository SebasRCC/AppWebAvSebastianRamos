<%@ LANGUAGE="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
' ============================================================
'  logout.asp · Cierre de sesion
' ============================================================
EndUserSession
DbClose
Response.Redirect BaseUrl & "login.asp?msg=bye"
Response.End
%>
