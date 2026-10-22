<%
' ============================================================
'  PoliMusic · Capa de datos (ADODB con parametros)
' ============================================================
Const adCmdText    = 1
Const adParamInput = 1
Const adInteger    = 3
Const adBigInt     = 20
Const adDouble     = 5
Const adVarChar    = 200
Const adVarWChar   = 202
Const adDBTimeStamp = 135

Dim Conn
Set Conn = OpenConnection()

' Ejecuta una sentencia con parametros opcionales.
' prms = Array(Array("@nombre", tipo, tamano, valor), ...)
Function DbRun(sql, prms)
    Dim cmd, i, p
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = Conn
    cmd.CommandType = adCmdText
    cmd.CommandText = sql
    cmd.CommandTimeout = 20
    If IsArray(prms) Then
        For i = 0 To UBound(prms)
            p = prms(i)
            cmd.Parameters.Append cmd.CreateParameter(p(0), p(1), adParamInput, p(2), p(3))
        Next
    End If
    Set DbRun = cmd.Execute
End Function

Function DbScalar(sql, prms)
    Dim rs, v
    Set rs = DbRun(sql, prms)
    v = Null
    If Not rs.EOF Then v = rs.Fields(0).Value
    rs.Close
    Set rs = Nothing
    DbScalar = v
End Function

Sub DbClose()
    If IsObject(Conn) Then
        If Conn.State = 1 Then Conn.Close
        Set Conn = Nothing
    End If
End Sub

' ------------------------------------------------------------
'  Catalogos (TBL_CATALOG): tipos de usuario y de playlist
' ------------------------------------------------------------
Function CatalogLabel(code, parent)
    Dim v, rs
    v = Null
    Set rs = DbRun("SELECT TOP 1 [VALUE] FROM TBL_CATALOG WHERE COD_CATALOG_PARENT = ? AND COD_CATALOG = ?", _
                   Array(Array("@p", adVarChar, 8, CStr(parent)), Array("@c", adVarChar, 8, CStr(code))))
    If Not rs.EOF Then v = rs.Fields(0).Value
    rs.Close
    Set rs = Nothing
    If IsNull(v) Then CatalogLabel = "" Else CatalogLabel = CStr(v)
End Function

' ------------------------------------------------------------
'  Helpers de dominio
' ------------------------------------------------------------
Function SongArtistNames(idSong)
    Dim rs, s
    s = ""
    Set rs = DbRun("SELECT A.ARTIST_NAME, A.ARTIST_LASTNAME FROM TBL_PLAYER P " & _
                   "INNER JOIN TBL_ARTIST A ON A.ID_ARTIST = P.ID_ARTIST " & _
                   "WHERE P.ID_SONG = ? ORDER BY A.ARTIST_NAME", Array(Array("@s", adInteger, 4, idSong)))
    Do While Not rs.EOF
        If Len(s) > 0 Then s = s & ", "
        s = s & Trim(rs("ARTIST_NAME") & " " & rs("ARTIST_LASTNAME") & "")
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing
    If Len(s) = 0 Then s = "Artista desconocido"
    SongArtistNames = s
End Function

Function SongAlbumTitle(idSong)
    Dim rs, s
    Set rs = DbRun("SELECT TOP 1 AL.TITLE_ALBUM FROM TBL_TRACKLIST T " & _
                   "INNER JOIN TBL_ALBUM AL ON AL.ID_ALBUM = T.ID_ALBUM " & _
                   "WHERE T.ID_SONG = ? ORDER BY AL.RELEASE_YEAR DESC", Array(Array("@s", adInteger, 4, idSong)))
    s = ""
    If Not rs.EOF Then s = Trim(rs.Fields(0).Value & "")
    rs.Close
    Set rs = Nothing
    SongAlbumTitle = s
End Function

Function SongAlbumCover(idSong)
    Dim rs, s
    Set rs = DbRun("SELECT TOP 1 AL.ALBUM_IMAGE_PATH FROM TBL_TRACKLIST T " & _
                   "INNER JOIN TBL_ALBUM AL ON AL.ID_ALBUM = T.ID_ALBUM " & _
                   "WHERE T.ID_SONG = ? ORDER BY AL.RELEASE_YEAR DESC", Array(Array("@s", adInteger, 4, idSong)))
    s = Null
    If Not rs.EOF Then s = rs.Fields(0).Value
    rs.Close
    Set rs = Nothing
    SongAlbumCover = s
End Function

Function FormatDuration(seconds)
    Dim m, s
    If seconds < 0 Then seconds = 0
    m = Int(seconds / 60)
    s = seconds Mod 60
    FormatDuration = m & ":" & Right("0" & s, 2)
End Function

' Mensajes flash por querystring
Function FlashBlock()
    Dim m, cls, msgTxt
    m = LCase(Txt(Request.QueryString("msg")))
    cls = "flash"
    Select Case m
        Case "saved"   : cls = "flash flash-ok"   : msgTxt = "Los cambios se guardaron correctamente."
        Case "created" : cls = "flash flash-ok"   : msgTxt = "El registro se creo correctamente."
        Case "deleted" : cls = "flash flash-warn" : msgTxt = "El registro se elimino."
        Case "added"   : cls = "flash flash-ok"   : msgTxt = "Cancion agregada a la playlist."
        Case "removed" : cls = "flash flash-warn" : msgTxt = "Cancion quitada de la playlist."
        Case "denied"  : cls = "flash flash-err"  : msgTxt = "No tienes permisos para acceder a esa seccion."
        Case "auth"    : cls = "flash flash-err"  : msgTxt = "Inicia sesion para continuar."
        Case "notfound": cls = "flash flash-err"  : msgTxt = "El registro solicitado no existe."
        Case "invalid" : cls = "flash flash-err"  : msgTxt = "Revisa los datos ingresados e intentalo de nuevo."
        Case "fk"      : cls = "flash flash-err"  : msgTxt = "No se puede eliminar: el registro tiene elementos asociados."
        Case "bye"     : cls = "flash flash-ok"   : msgTxt = "Sesion cerrada. Que vuelvas pronto."
        Case Else      : FlashBlock = "" : Exit Function
    End Select
    FlashBlock = "<div class=""" & cls & """ role=""status"">" & _
                 "<span class=""flash-dot""></span><span>" & msgTxt & "</span></div>"
End Function

' ------------------------------------------------------------
'  Utilidades JSON para el reproductor
' ------------------------------------------------------------
Function JsonStr(v)
    Dim s
    If IsNull(v) Then
        JsonStr = """"""
        Exit Function
    End If
    s = CStr(v)
    s = Replace(s, "\", "\\")
    s = Replace(s, """", "\""")
    s = Replace(s, vbCrLf, " ")
    s = Replace(s, vbCr, " ")
    s = Replace(s, vbLf, " ")
    s = Replace(s, vbTab, " ")
    JsonStr = """" & s & """"
End Function

Function JsonSong(id, title, artist, album, src, cover, plays)
    JsonSong = "{""id"":" & id & ",""title"":" & JsonStr(title) & _
               ",""artist"":" & JsonStr(artist) & ",""album"":" & JsonStr(album) & _
               ",""src"":" & JsonStr(src) & ",""cover"":" & JsonStr(cover) & _
               ",""plays"":" & plays & "}"
End Function
%>
