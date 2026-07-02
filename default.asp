<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%Option Explicit%>
<!-- #include file="controllers/user_controller.asp" -->
<%
' ============================================================
' default.asp —— 前端控制器 / 路由配置
' 路由格式: ?controller=User&action=Index&id=123
' ============================================================

' 获取路由参数
Dim controller, action, viewName
controller = Request.QueryString("controller")
action     = Request.QueryString("action")
If controller = "" Then controller = "User"
If action = ""     Then action = "Index"

' ---- 外层：按 controller 分发 ----
Select Case controller

    Case "User"
        Dim Ctrl
        Set Ctrl = New UserController

        ' ---- 内层：按 action 分发 ----
        Select Case action
            Case "Index"
                viewName = Ctrl.Index()
            Case "Create"
                viewName = Ctrl.Create()
            Case "Edit"
                viewName = Ctrl.Edit()
            Case "Update"
                viewName = Ctrl.Update()
            Case "Delete"
                viewName = Ctrl.Delete()
            Case Else
                Response.Status = "404 Not Found"
                Response.Write "页面不存在"
                Response.End
        End Select

        ' ---- 将 ViewBag 注入全局作用域，供视图访问 ----
        Dim Bag
        Set Bag = Ctrl.GetBag()

    Case Else
        Response.Status = "404 Not Found"
        Response.Write "Controller 不存在"
        Response.End

End Select
%>
<% If viewName = "index" Then %>
<!-- #include file="views/user/index.asp" -->
<% End If %>
<% If viewName = "edit"   Then %>
<!-- #include file="views/user/edit.asp"   -->
<% End If %>
