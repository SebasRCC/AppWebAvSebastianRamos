<%@ LANGUAGE="VBScript" CodePage="65001" %>
<!--#include file="includes/init.asp"-->
<%
If IsLoggedIn() Then
    Response.Redirect BaseUrl & "default.asp"
Else
    Response.Redirect BaseUrl & "login.asp"
End If
Response.End
%>
