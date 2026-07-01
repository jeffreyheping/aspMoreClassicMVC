<!-- #include file="config.asp" -->
<%
' ============================================================
' core/db.asp
' 数据库访问层 —— 轻量级 ADODB 封装
' ============================================================

Class DbHelper

    Private conn

    ' ---- 构造 ----
    Private Sub Class_Initialize
        Dim connStr
        If DB_TYPE = "access" Then
            connStr = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source="
            connStr = connStr & Server.MapPath(DB_SOURCE)
            If DB_PWD <> "" Then
                connStr = connStr & "; Jet OLEDB:Database Password=" & DB_PWD
            End If
        ElseIf DB_TYPE = "sqlsvr" Then
            connStr = "Provider=SQLOLEDB; Server=" & DB_SERVER
            connStr = connStr & "; Database=" & DB_NAME
            connStr = connStr & "; UID=" & DB_USER
            connStr = connStr & "; PWD=" & DB_PASS & ";"
        End If
        Set conn = Server.CreateObject("ADODB.Connection")
        conn.Open connStr
    End Sub

    ' ---- 析构 ----
    Private Sub Class_Terminate
        If IsObject(conn) Then
            If conn.State <> 0 Then conn.Close
            Set conn = Nothing
        End If
    End Sub

    ' ---- 查询：返回 Recordset ----
    Public Function Query(sql)
        Dim rs
        Set rs = Server.CreateObject("ADODB.Recordset")
        rs.Open sql, conn, 1, 1
        Set Query = rs
    End Function

    ' ---- 执行：INSERT / UPDATE / DELETE ----
    Public Sub Execute(sql)
        conn.Execute sql
    End Sub

End Class
%>
