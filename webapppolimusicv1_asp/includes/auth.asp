<%
' ============================================================
'  PoliMusic · Autenticacion y control de roles
'  USER_TYPE 0 = Usuario normal   |   USER_TYPE 1 = Administrador
' ============================================================
Function IsLoggedIn()
    IsLoggedIn = (Len(Session("UserID") & "") > 0)
End Function

Function IsAdmin()
    IsAdmin = (CStr(Session("UserType") & "") = "1")
End Function

Function CurrentUserName()
    If IsNull(Session("UserName")) Then CurrentUserName = "" Else CurrentUserName = CStr(Session("UserName"))
End Function

Function CurrentUserPhoto()
    CurrentUserPhoto = UserPhotoUrl(Session("UserPhoto"))
End Function

Function RoleLabel()
    If IsAdmin() Then RoleLabel = "Administrador" Else RoleLabel = "Oyente"
End Function

Function RoleClass()
    If IsAdmin() Then RoleClass = "badge badge-admin" Else RoleClass = "badge badge-user"
End Function

Function Greeting()
    Dim hrNow
    hrNow = Hour(Now)
    If hrNow < 12 Then
        Greeting = "Buenos dias"
    ElseIf hrNow < 19 Then
        Greeting = "Buenas tardes"
    Else
        Greeting = "Buenas noches"
    End If
End Function

Sub RequireLogin()
    If Not IsLoggedIn() Then
        Response.Redirect BaseUrl & "login.asp?msg=auth"
        Response.End
    End If
End Sub

Sub RequireAdmin()
    RequireLogin
    If Not IsAdmin() Then
        Response.Redirect BaseUrl & "default.asp?msg=denied"
        Response.End
    End If
End Sub

Sub StartUserSession(id, uname, utype, photo, email)
    Session("UserID")   = id
    Session("UserName") = uname
    Session("UserType") = utype
    Session("UserPhoto") = photo
    Session("UserEmail") = email
    Session("StartedAt") = Now
End Sub

Sub EndUserSession()
    Session.Contents.RemoveAll()
    Session.Abandon()
End Sub
%>
