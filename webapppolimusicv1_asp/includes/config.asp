<%
' ============================================================
'  PoliMusic · Configuracion central
'  Credenciales tomadas de BDD_PoliMusic.sql (SQL Server 2025)
' ============================================================
Response.CodePage = 65001
Response.CharSet = "UTF-8"
Session.CodePage = 65001
Session.LCID = 1033

Const APP_NAME     = "PoliMusic"
Const APP_TAGLINE  = "Agora Sonora"

Const DB_SERVER    = "localhost"
Const DB_NAME      = "BDD_PoliMusic"
Const DB_USER      = "usr_polimusic"
Const DB_PASS      = "Politecnica1"

Dim BaseUrl, AppPath, Fso

Function AppBase()
    Dim u, i
    u = Request.ServerVariables("URL")
    i = InStrRev(u, "/")
    If i > 0 Then
        AppBase = Left(u, i)
    Else
        AppBase = "/"
    End If
End Function

BaseUrl = AppBase()
AppPath = Server.MapPath(BaseUrl)
Set Fso = Server.CreateObject("Scripting.FileSystemObject")

' ------------------------------------------------------------
'  Conexion ADO con cadena de proveedores en cascada
' ------------------------------------------------------------
Function OpenConnection()
    Dim providers, i, cs, c, ok
    providers = Array("MSOLEDBSQL", "MSOLEDBSQL19", "SQLOLEDB", "SQLNCLI11")

    For i = 0 To UBound(providers)
        Set c = Server.CreateObject("ADODB.Connection")
        cs = "Provider=" & providers(i) & ";Server=" & DB_SERVER & _
             ";Database=" & DB_NAME & ";UID=" & DB_USER & ";PWD=" & DB_PASS & _
             ";TrustServerCertificate=Yes;Encrypt=Optional;"
        On Error Resume Next
        c.Open cs
        ok = (Err.Number = 0)
        If Not ok Then Err.Clear
        On Error GoTo 0
        If ok Then
            Set OpenConnection = c
            Exit Function
        End If
        Set c = Nothing
    Next

    Response.Write "<div style=""font-family:Segoe UI,sans-serif;padding:40px;color:#12263C"">"
    Response.Write "<h2>No se pudo conectar a SQL Server</h2>"
    Response.Write "<p>Verifica que el servicio de SQL Server este activo y que la base <strong>" & DB_NAME & "</strong> exista.</p>"
    Response.Write "<p>Servidor: <strong>" & DB_SERVER & "</strong> · Usuario: <strong>" & DB_USER & "</strong></p>"
    Response.Write "<p>Ejecuta primero el script <strong>BDD_PoliMusic.sql</strong> en SQL Server.</p></div>"
    Response.End
End Function

' ------------------------------------------------------------
'  Utilidades de presentacion
' ------------------------------------------------------------
Function H(v)
    Dim s
    If IsNull(v) Then
        H = ""
        Exit Function
    End If
    s = CStr(v)
    s = Replace(s, "&", "&amp;")
    s = Replace(s, "<", "&lt;")
    s = Replace(s, ">", "&gt;")
    s = Replace(s, """", "&quot;")
    s = Replace(s, "'", "&#39;")
    H = s
End Function

Function Num(v, def)
    If IsNull(v) Then
        Num = def
    ElseIf IsNumeric(v) Then
        Num = CLng(v)
    Else
        Num = def
    End If
End Function

Function Txt(v)
    If IsNull(v) Then Txt = "" Else Txt = Trim(CStr(v))
End Function

Function Truncate(s, n)
    If Len(s) > n Then Truncate = Left(s, n - 1) & "..." Else Truncate = s
End Function

Function IIf(cond, a, b)
    If cond Then IIf = a Else IIf = b
End Function

Function IsoDate(d)
    If IsNull(d) Then
        IsoDate = ""
        Exit Function
    End If
    If Not IsDate(d) Then
        IsoDate = ""
        Exit Function
    End If
    IsoDate = Year(d) & "-" & Right("0" & Month(d), 2) & "-" & Right("0" & Day(d), 2)
End Function

' ------------------------------------------------------------
'  Resolucion de rutas de assets:  ~/songFiles/x.mp3 -> assets/songFiles/x.mp3
' ------------------------------------------------------------
Function FolderMap(f)
    Select Case LCase(f)
        Case "songfiles"     : FolderMap = "songFiles"
        Case "albumimages"   : FolderMap = "albumImages"
        Case "artistimages"  : FolderMap = "artistImages"
        Case "playlistimages": FolderMap = "playlistImages"
        Case "userimages"    : FolderMap = "userImages"
        Case Else            : FolderMap = f
    End Select
End Function

Function AssetUrl(p, kind)
    Dim s, i, folder, file, dir, fallback, rel, sep

    Select Case kind
        Case "album"    : dir = "albumImages"    : fallback = "default.png"
        Case "artist"   : dir = "artistImages"   : fallback = "default.png"
        Case "playlist" : dir = "playlistImages" : fallback = "default.jpg"
        Case "user"     : dir = "userImages"     : fallback = "default.jpg"
        Case Else       : dir = "songFiles"      : fallback = ""
    End Select

    file = ""
    If Not IsNull(p) Then
        s = Replace(Trim(CStr(p)), "\", "/")
        Do While Len(s) > 0 And (Left(s, 1) = "~" Or Left(s, 1) = "/")
            s = Mid(s, 2)
        Loop
        i = InStr(s, "/")
        If i > 0 Then
            folder = Left(s, i - 1)
            file = Mid(s, i + 1)
        Else
            file = s
        End If
        If Len(folder) > 0 Then dir = FolderMap(folder)
    End If

    rel = "assets/" & dir & "/" & file
    If Len(file) > 0 Then
        If Fso.FileExists(Server.MapPath(BaseUrl & rel)) Then
            AssetUrl = BaseUrl & rel
            Exit Function
        End If
    End If

    If Len(fallback) = 0 Then
        AssetUrl = ""
    Else
        AssetUrl = BaseUrl & "assets/" & dir & "/" & fallback
    End If
End Function

Function UserPhotoUrl(p)
    UserPhotoUrl = AssetUrl(p, "user")
End Function
%>
