<%
Dim appRoot
appRoot = Left(Request.ServerVariables("SCRIPT_NAME"), InStrRev(Request.ServerVariables("SCRIPT_NAME"), "/"))
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title><%=Bag("title")%></title>
<link rel="stylesheet" href="<%=appRoot%>content/site.css" />
</head>
<body>
