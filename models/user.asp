<%
' ============================================================
' models/user.asp
' User 实体类 + UserModel 数据访问类
' ============================================================
%>
<!-- #include file="../core/db.asp" -->
<%

' ---- 实体：UserInfo ----------------------------------------

Class UserInfo

    Private m_id, m_name, m_age

    Public Property Get UserId()
        UserId = m_id
    End Property
    Public Property Let UserId(v)
        m_id = CLng(v)
    End Property

    Public Property Get UserName()
        UserName = m_name
    End Property
    Public Property Let UserName(v)
        m_name = CStr(v)
    End Property

    Public Property Get UserAge()
        UserAge = m_age
    End Property
    Public Property Let UserAge(v)
        m_age = CLng(v)
    End Property

End Class


' ---- 数据访问：UserModel ------------------------------------

Class UserModel

    Private db

    Private Sub Class_Initialize
        Set db = New DbHelper
    End Sub

    Private Sub Class_Terminate
        Set db = Nothing
    End Sub

    ' -- 验证 --
    Public Function Validate(name, age)
        Dim errs
        Set errs = Server.CreateObject("Scripting.Dictionary")

        name = Trim(name)
        If name = "" Then errs.Add "name", "姓名不能为空"

        age = Trim(age)
        If age = "" Then
            errs.Add "age", "年龄不能为空"
        ElseIf Not IsNumeric(age) Then
            errs.Add "age", "年龄必须是数字"
        ElseIf CLng(age) < 0 Or CLng(age) > 200 Then
            errs.Add "age", "年龄范围 0-200"
        End If

        Set Validate = errs
    End Function

    ' -- 查询全部 --
    Public Function GetAll()
        Dim rs, dict, u
        Set rs   = db.Query("SELECT * FROM Users ORDER BY UserName")
        Set dict = Server.CreateObject("Scripting.Dictionary")

        While Not rs.EOF
            Set u = New UserInfo
            u.UserId   = rs("UserId")
            u.UserName = rs("UserName")
            u.UserAge  = rs("UserAge")
            dict.Add u.UserId, u
            rs.MoveNext
        Wend
        rs.Close
        Set rs = Nothing
        
        Set GetAll = dict
    End Function

    ' -- 按 ID 查询 --
    Public Function GetById(id)
        Dim rs, u
        Set rs = db.Query("SELECT * FROM Users WHERE UserId=" & CLng(id))
        If rs.EOF Then
            Set GetById = Nothing
        Else
            Set u = New UserInfo
            u.UserId   = rs("UserId")
            u.UserName = rs("UserName")
            u.UserAge  = rs("UserAge")
            Set GetById = u
        End If
        rs.Close
        Set rs = Nothing
    End Function

    ' -- 插入 --
    Public Sub Insert(name, age)
        Dim sql
        sql = "INSERT INTO Users (UserName,UserAge) VALUES ('"
        sql = sql & Replace(name, "'", "''") & "',"
        sql = sql & CLng(age) & ")"
        db.Execute sql
    End Sub

    ' -- 更新 --
    Public Sub Update(id, name, age)
        Dim sql
        sql = "UPDATE Users SET UserName='"
        sql = sql & Replace(name, "'", "''") & "',"
        sql = sql & "UserAge=" & CLng(age)
        sql = sql & " WHERE UserId=" & CLng(id)
        db.Execute sql
    End Sub

    ' -- 删除 --
    Public Sub Delete(id)
        db.Execute "DELETE FROM Users WHERE UserId=" & CLng(id)
    End Sub

End Class
%>
