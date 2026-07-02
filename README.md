# aspMoreClassicMVC

**ASP Classic MVC** —— 用经典 ASP (VBScript) 实现的 MVC 脚手架项目，参照 ASP.NET MVC 规范组织代码结构。

**ASP Classic MVC** — A scaffolded MVC project written in classic ASP (VBScript), organized following ASP.NET MVC conventions.

---

## 项目简介 / Introduction

本项目演示了如何在 ASP Classic 的限制下，实现接近 ASP.NET MVC 的开发体验：

This project demonstrates how to achieve an ASP.NET MVC-like development experience within the constraints of ASP Classic:

- **MVC 分层** — Controllers / Models / Views 各司其职
- **MVC separation** — Controllers, Models, and Views each with clear responsibilities
- **约定优于配置** — 目录结构和命名遵循 ASP.NET MVC 脚手架规范
- **Convention over Configuration** — Directory structure and naming follow ASP.NET MVC scaffolding conventions
- **前端控制器 + 双层路由** — `default.asp` 按 `controller` / `action` 两层分发
- **Front Controller + Two-level Routing** — `default.asp` dispatches by `controller` then `action`
- **ViewBag 传值** — Controller 通过 `Bag` 字典向 View 传递数据
- **ViewBag data passing** — Controller passes data to Views via a `Bag` dictionary
- **TempData / Flash Message** — 用 Session 实现一次性消息，对应 ASP.NET MVC 的 `TempData`
- **TempData / Flash Message** — One-time messages via Session, equivalent to ASP.NET MVC's `TempData`
- **依赖注入** — `DbHelper` 由 Controller 创建后注入 `UserModel`，对应构造函数注入
- **Dependency Injection** — `DbHelper` created by Controller and injected into `UserModel` via `SetDb`

---

## 目录结构 / Project Structure

```
aspMoreClassicMVC/
├── default.asp                        ← 入口 / 路由 (Route Config)
├── content/
│   └── site.css                       ← 全局样式 (≈ Content/Site.css)
├── controllers/
│   └── user_controller.asp            ← UserController 类
├── core/
│   ├── config.asp                     ← 应用配置 (≈ Web.config)
│   └── db.asp                         ← 数据库上下文 (≈ DbContext)
├── models/
│   └── user.asp                       ← UserInfo 实体 + UserModel 数据访问
├── views/
│   ├── shared/
│   │   ├── _layout_top.asp            ← 共享布局头部 (≈ _Layout.cshtml)
│   │   └── _layout_bottom.asp         ← 共享布局尾部
│   └── user/
│       ├── index.asp                  ← 用户列表 (≈ Index.cshtml)
│       └── edit.asp                   ← 编辑表单 (≈ Edit.cshtml)
└── data/
    └── DB.mdb                         ← Access 数据库
```

---

## 命名规范 / Naming Conventions

| 类别 / Category | 规范 / Convention | 示例 / Example |
|---|---|---|
| 控制器文件 / Controller file | `实体名_controller.asp` | `user_controller.asp` |
| 控制器类名 / Controller class | `实体名Controller` | `UserController` |
| Action 方法 / Action methods | PascalCase 动词 / PascalCase verbs | `Index`, `Create`, `Edit`, `Update`, `Delete` |
| 视图目录 / View directory | `views/实体名/` | `views/user/` |
| 视图文件 / View file | 与 Action 同名 / Same as action name | `index.asp`, `edit.asp` |
| 共享视图 / Shared views | `views/shared/_前缀` | `_layout_top.asp` |
| 静态资源 / Static assets | `content/` | `site.css` |

---

## 请求流程 / Request Flow

```
浏览器请求 Browser Request
    │  ?controller=User&action=Edit&id=5
    ▼
default.asp (路由分发 / Route Dispatch)
    │  Select Case controller → Select Case action
    ▼
UserController.Edit() (控制器 / Controller)
    │  调用 Model，设置 ViewBag
    │  Calls Model, sets ViewBag
    ▼
views/user/edit.asp (视图渲染 / View Rendering)
    │  #include _layout_top / _layout_bottom
    ▼
HTML 响应 / HTML Response
```

**Action 方法遵循 GET/POST 分离：**

**Action methods follow GET/POST separation:**

| Action | HTTP 方法 / Method | 说明 / Description |
|--------|---------|------|
| `Index` | GET | 用户列表 / User list |
| `Create` | POST | 新增用户，重定向到 Index / Create user, redirect to Index |
| `Edit` | GET | 编辑表单 / Edit form |
| `Update` | POST | 保存编辑，重定向到 Index / Save edit, redirect to Index |
| `Delete` | POST | 删除用户，重定向到 Index / Delete user, redirect to Index |

---

## 核心机制 / Key Mechanisms

### ViewBag 数据传递 / ViewBag Data Passing

Controller 通过 `Bag` (Scripting.Dictionary) 向 View 传递数据：

Controller passes data to Views via `Bag` (Scripting.Dictionary):

```vbscript
' Controller 中设置 / Setting in Controller
SetBag "users", Model.GetAll()
SetBag "title", "用户管理"

' View 中读取 / Reading in View
<%=Bag("title")%>
<% For Each u In Bag("users").Items %>
```

### 条件 Include 渲染 / Conditional Include Rendering

由于 ASP Classic 不支持 `Server.Execute` 在类方法中传递变量，本项目采用编译期 `#include` + 运行期 `If/Then` 的方式加载视图：

Since ASP Classic's `Server.Execute` cannot pass variables from class methods, this project uses compile-time `#include` with runtime `If/Then` to load views:

```asp
<% If viewName = "index" Then %><!-- #include file="views/user/index.asp" --><% End If %>
<% If viewName = "edit"   Then %><!-- #include file="views/user/edit.asp"   --><% End If %>
```

所有视图文件在编译期被包含，但只有匹配的视图在运行期实际输出 HTML。

All view files are included at compile time, but only the matching view outputs HTML at runtime.

---

### TempData / Flash Message

Controller 写入 Session，Index Action 读取后立即清除，等同 ASP.NET MVC 的 `TempData`：

Controller writes to Session; the Index action reads and immediately removes it, equivalent to ASP.NET MVC's `TempData`:

```vbscript
' Controller 写入 / Writing in Controller
Session("_flash") = "添加成功"
Response.Redirect "default.asp?controller=User&action=Index"

' Index Action 读取并清除 / Reading and clearing in Index
flash = Session("_flash") & ""
Session.Remove "_flash"
```

---

### 依赖注入 / Dependency Injection

`DbHelper` 由 Controller 创建并通过 `SetDb` 注入 `UserModel`，对应 ASP.NET MVC 中通过构造函数注入 `DbContext`：

`DbHelper` is created by the Controller and injected into `UserModel` via `SetDb`, equivalent to injecting `DbContext` via constructor in ASP.NET MVC:

```vbscript
' controllers/user_controller.asp
Set Db    = New DbHelper
Set Model = New UserModel
Model.SetDb Db

' models/user.asp
Public Sub SetDb(dbInstance)
    Set db = dbInstance
End Sub
```

---

### 数据库异常处理 / Database Error Handling

连接失败时显示友好提示而非 IIS 500 错误页：

Displays a friendly message on connection failure instead of an IIS 500 error page:

```vbscript
On Error Resume Next
conn.Open connStr
If Err.Number <> 0 Then
    Response.Write "数据库连接失败，请联系管理员。"
    Response.End
End If
On Error GoTo 0
```

---

## 运行环境 / Requirements

- **Windows** + **IIS** (启用经典 ASP / Classic ASP enabled)
- **Microsoft Access** (Jet 4.0 引擎 / Jet 4.0 engine)
- 虚拟目录指向项目根目录 / Virtual directory pointing to project root

---

## 数据库 / Database

Access 数据库 `data/DB.mdb`，包含 `Users` 表：

Access database `data/DB.mdb` with a `Users` table:

| 字段 / Column | 类型 / Type | 说明 / Description |
|------|------|------|
| UserId | AutoNumber | 主键 / Primary key |
| UserName | Text | 姓名 / Name |
| UserAge | Number | 年龄 / Age |

数据库连接配置在 `core/config.asp` 中修改。

Database connection settings can be modified in `core/config.asp`.

---

## 编码规范 / Code Style

- 不使用 `_` 续行符，长字符串用 `str = str & xxx` 逐行拼接
- No `_` line continuations; long strings concatenated line by line with `str = str & xxx`
- 不使用 `:` 将多条语句合并到一行
- No `:` statement separators (each statement on its own line)
- 统一使用 `Function` 定义过程和函数
- `Function` used uniformly for both procedures and functions
- SQL 参数使用 `Replace(s, "'", "''")` 防注入
- SQL parameters sanitized with `Replace(s, "'", "''")` to prevent injection

---

## License

MIT
