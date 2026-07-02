<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%Option Explicit%>
<%
' ============================================================
' core/config.asp
' 应用程序配置
' ============================================================

' 数据库类型: "access" 或 "sqlsvr"
Const DB_TYPE   = "access"

' Access 数据库相对路径（相对于 default.asp）
Const DB_SOURCE = "data/DB.mdb"

' Access 数据库密码（空则留空）
Const DB_PWD    = "915321x"

' SQL Server 配置（预留）
Const DB_SERVER = "(local)"
Const DB_USER   = "sa"
Const DB_PASS   = ""
Const DB_NAME   = ""
%>
