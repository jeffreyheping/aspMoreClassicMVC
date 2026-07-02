<%
' ============================================================
' views/user/edit.asp  —— 对应 UserController.Edit
' ViewBag: user (UserInfo)
' ============================================================
Dim editUser
Set editUser = Bag("user")
%>
<!-- #include file="../shared/_layout_top.asp" -->

<form method="post" action="?controller=User&action=Update">
  <input type="hidden" name="id" value="<%=editUser.UserId%>" />
  <table>
    <tr>
      <td>姓名:</td>
      <td><input type="text" name="name" value="<%=Server.HTMLEncode(editUser.UserName)%>" /></td>
    </tr>
    <tr>
      <td>年龄:</td>
      <td><input type="text" name="age" value="<%=editUser.UserAge%>" /></td>
    </tr>
    <tr>
      <td></td>
      <td><input type="submit" value="更新" />
        <a href="?controller=User&action=Index">返回</a></td>
    </tr>
  </table>
</form>

<!-- #include file="../shared/_layout_bottom.asp" -->