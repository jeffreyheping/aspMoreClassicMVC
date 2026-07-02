<!-- #include file="../models/user.asp" -->
<%
' ============================================================
' controllers/user_controller.asp
' UserController —— 参照 ASP.NET MVC 脚手架规范
' ============================================================

Class UserController

    Private Model
    Private Bag
    Private Db

    Private Sub Class_Initialize
        Set Db    = New DbHelper
        Set Model = New UserModel
        Model.SetDb Db
        Set Bag   = Server.CreateObject("Scripting.Dictionary")
    End Sub

    Private Sub Class_Terminate
        Set Model = Nothing
        Set Db    = Nothing
        Set Bag   = Nothing
    End Sub

    ' ========================================================
    ' 私有工具方法
    ' ========================================================

    ' 返回视图名（类似 ASP.NET MVC 的 View()）
    Private Function View(viewName)
        View = viewName
    End Function

    ' 重定向到 Index（类似 ASP.NET MVC 的 RedirectToAction + TempData）
    Private Function RedirectToIndex(msg)
        Session("_flash") = msg
        Response.Redirect "default.asp?controller=User&action=Index"
        RedirectToIndex = ""
    End Function

    ' 设置 ViewBag
    Private Sub SetBag(key, value)
        If Bag.Exists(key) Then
            Bag(key) = value
        Else
            Bag.Add key, value
        End If
    End Sub

    ' 拼接验证错误
    Private Function ErrorSummary(errs)
        Dim r, k
        r = ""
        For Each k In errs.Keys
            If r <> "" Then r = r & vbCrLf
            r = r & errs(k)
        Next
        ErrorSummary = r
    End Function

    ' ========================================================
    ' GET /User/Index —— 用户列表
    ' ========================================================
    Public Function Index()
        Dim flash
        flash = Session("_flash") & ""
        Session.Remove "_flash"
        SetBag "users",   Model.GetAll()
        SetBag "message", flash
        SetBag "title",   "用户管理"
        Index = View("index")
    End Function

    ' ========================================================
    ' POST /User/Create —— 新增用户
    ' ========================================================
    Public Function Create()
        Dim name, age, errs
        name = Trim(Request.Form("name"))
        age  = Trim(Request.Form("age"))

        Set errs = Model.Validate(name, age)
        If errs.Count > 0 Then
            Create = RedirectToIndex(ErrorSummary(errs))
            Exit Function
        End If

        Model.Insert name, age
        Create = RedirectToIndex("添加成功")
    End Function

    ' ========================================================
    ' GET /User/Edit?id=5 —— 编辑表单
    ' ========================================================
    Public Function Edit()
        Dim userId, u
        userId = Request.QueryString("id")
        Set u  = Model.GetById(userId)

        If u Is Nothing Then
            Edit = RedirectToIndex("用户不存在")
            Exit Function
        End If

        SetBag "user",  u
        SetBag "title", "编辑用户"
        Edit = View("edit")
    End Function

    ' ========================================================
    ' POST /User/Update —— 保存编辑
    ' ========================================================
    Public Function Update()
        Dim userId, name, age, errs
        userId = Request.Form("id")
        name   = Trim(Request.Form("name"))
        age    = Trim(Request.Form("age"))

        Set errs = Model.Validate(name, age)
        If errs.Count > 0 Then
            Update = RedirectToIndex(ErrorSummary(errs))
            Exit Function
        End If

        Model.Update userId, name, age
        Update = RedirectToIndex("更新成功")
    End Function

    ' ========================================================
    ' GET /User/Delete?id=5 —— 删除用户
    ' ========================================================
    Public Function Delete()
        Dim userId
        userId = Request.Form("id")
        If IsNumeric(userId) Then Model.Delete userId
        Delete = RedirectToIndex("删除成功")
    End Function

    ' ========================================================
    ' 供 default.asp 调用的访问器
    ' ========================================================

    ' 获取 ViewBag
    Public Function GetBag()
        Set GetBag = Bag
    End Function

End Class
%>
