<%
' ============================================================
' views/user/index.asp  —— 对应 UserController.Index
' ViewBag: users (Dictionary), message (String)
' ============================================================
%>
<!-- #include file="../shared/_layout_top.asp" -->

<% If Bag("message") <> "" Then %>
<p class="msg"><%=Server.HTMLEncode(Bag("message"))%></p>
<% End If %>

<form method="post" action="?action=Create">
    姓名: <input type="text" name="name" />
    年龄: <input type="text" name="age" />
    <input type="submit" value="添加" />
</form>

<br />
<table width="500">
    <tr>
        <th>UserId</th>
        <th>UserName</th>
        <th>UserAge</th>
        <th>操作</th>
    </tr>
    <%
    Dim u
    For Each u In Bag("users").Items
    %>
    <tr>
        <td><%=u.UserId%></td>
        <td><%=Server.HTMLEncode(u.UserName)%></td>
        <td><%=u.UserAge%></td>
        <td>
            <a href="?action=Edit&id=<%=u.UserId%>">编辑</a>
            <a href="?action=Delete&id=<%=u.UserId%>" onclick="return confirm('确定删除吗？')">删除</a>
        </td>
    </tr>
    <%
    Next
    If Bag("users").Count = 0 Then
    %>
    <tr><td colspan="4" align="center">暂无数据</td></tr>
    <% End If %>
</table>

<!-- #include file="../shared/_layout_bottom.asp" -->
