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
- **与现代 MVC 的差异对照** — 明确列出 VBScript / ASP Classic 限制下无法实现、不得不妥协的部分
- **Gap analysis vs modern MVC** — Explicitly lists what cannot be implemented under VBScript / ASP Classic constraints and where compromises are made

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

---

## 与现代 MVC 的差异对照 / Gaps vs Modern MVC

本项目已经尽可能贴近 ASP.NET MVC 的脚手架风格，但 **VBScript 语言和 ASP Classic 运行时** 本身的缺失，仍导致了一些「别扭」或「不地道」的妥协。下列每一项都标注了在现代 MVC（如 ASP.NET MVC）中的对等机制，便于读者理解差异来源。

This project is already as close to the ASP.NET MVC scaffolding style as possible, but gaps in **VBScript as a language and the ASP Classic runtime** still force some awkward or non-idiomatic compromises. Each item below is annotated with its modern MVC counterpart (e.g. ASP.NET MVC), so readers can trace where the gap comes from.

### 1. 无 OOP 继承 → 无 BaseController

VBScript 的 `Class` 不支持继承，无法抽出公共基类（`BaseController`）来存放 `View()`、`RedirectToAction()`、`SetBag()`、`ErrorSummary()` 等方法。每个 Controller 都必须 **复制** 一份完全相同的辅助代码。

ASP.NET MVC 中所有 Controller 继承自 `Controller` 基类，公共方法只写一次。

**VBScript `Class` has no inheritance**, so there's no way to extract a `BaseController` to host `View()`, `RedirectToAction()`, `SetBag()`, `ErrorSummary()`. Every Controller must **copy** identical helper code.

In ASP.NET MVC, all controllers inherit from `Controller`, writing the shared helpers once.

### 2. 无属性（Attribute）装饰 → 验证只能硬编码

没有 `[Required]`、`[Range]`、`[StringLength]` 之类的声明式验证。所有校验逻辑必须写在 `Model.Validate()` 里，无法直接贴在实体字段上。

No `[Required]`, `[Range]`, `[StringLength]` or similar declarative attributes. All validation has to live inside `Model.Validate()`, instead of being attached directly to entity fields.

### 3. 无 Model Binding → 手动读 Request.Form / QueryString

现代 MVC 会将请求数据自动绑定到强类型 Model：`public ActionResult Create(User u)`。本项目只能逐字段读取：`name = Request.Form("name")`。

Modern MVC binds request data automatically to a strongly-typed Model: `public ActionResult Create(User u)`. This project has to read each field manually: `name = Request.Form("name")`.

### 4. 无 Attribute Routing → 硬编码路由

现代框架支持 `[Route("users/{id}")]` 或路由表配置。ASP Classic 的 `#include` 是编译期处理，无法动态加载，只能用 `default.asp` 里的双层 `Select Case` 分发。**每新增一个 Action 都要手动在 `default.asp` 里加一行 `Case`**。

Modern frameworks offer `[Route("users/{id}")]` or route table configuration. ASP Classic's `#include` is resolved at compile time, so routing is a hardcoded two-level `Select Case` in `default.asp`. **Every new Action requires manually adding a `Case` line**.

### 5. 无 Razor 模板引擎 → 条件 `#include` 渲染视图

ASP.NET MVC 使用 Razor (`return View("Edit", model)`) 按需加载视图。本项目在编译期就把 **所有视图** `#include` 进来，再用运行期的 `If viewName = "xxx" Then` 决定输出哪一段（参见 `View()` 方法的实现）。

ASP.NET MVC uses Razor (`return View("Edit", model)`) to load views on demand. This project `#include`s **every view** at compile time, and decides at runtime which block to output via `If viewName = "xxx" Then` (see `View()` implementation).

### 6. 无强类型 ViewBag → 字符串键 + Variant 值

Razor 的 `ViewBag` 是 `dynamic`，IDE 有智能提示。本项目的 `Bag` 是 `Scripting.Dictionary`，键为字符串、值为 `Variant`，键名拼错或值类型用错只能运行时才发现。

Razor's `ViewBag` is `dynamic` with IntelliSense. Here `Bag` is a `Scripting.Dictionary` with string keys and `Variant` values — typos in keys or wrong value types only surface at runtime.

### 7. 无 Layout Section → 只有「头 + 尾」两段布局

Razor 的 `_Layout.cshtml` 支持 `@RenderBody()`、`@RenderSection("scripts")` 等多段占位。本项目只能把布局切为 `_layout_top.asp` 和 `_layout_bottom.asp`，视图夹在中间，无法再定义额外的 section（如 page-specific CSS/JS）。

Razor's `_Layout.cshtml` supports `@RenderBody()`, `@RenderSection("scripts")` and multiple placeholders. Here the layout is only split into `_layout_top.asp` and `_layout_bottom.asp` with the view sandwiched in between — no way to define extra sections (e.g. page-specific CSS/JS).

### 8. 无 HtmlHelper / TagHelper → 手写 HTML 表单

没有 `@Html.TextBoxFor(m => m.Name)`、`@Html.ValidationMessageFor(...)`。表单控件、`validation-summary`、字段回填都得手写，验证失败时也无法自动保留用户已填的值（除非自己用 Session 暂存）。

No `@Html.TextBoxFor(m => m.Name)` or `@Html.ValidationMessageFor(...)`. Form controls, validation summaries and field repopulation are all hand-written, and failed validation cannot automatically preserve the user's input (unless Session is used manually).

### 9. 无 AntiForgeryToken → CSRF 防御缺失

ASP.NET MVC 有 `[ValidateAntiForgeryToken]` + `@Html.AntiForgeryToken()`。本项目没有任何 CSRF 令牌，所有 POST 请求依赖浏览器的同源行为保护。

ASP.NET MVC provides `[ValidateAntiForgeryToken]` + `@Html.AntiForgeryToken()`. This project has no CSRF tokens at all — all POST requests rely on the browser's same-origin behavior.

### 10. 无 DI 容器 → 手工注入

没有 IoC 容器（Autofac、内置 DI），Controller 无法通过构造函数声明依赖、由框架自动解析。`DbHelper` 必须在 Controller 内手工 `New` 出来并传给 Model（`Model.SetDb Db`）。

No IoC container (Autofac, built-in DI), so Controllers cannot declare dependencies for the framework to resolve. `DbHelper` must be `New`ed inside the Controller and passed to the Model manually (`Model.SetDb Db`).

### 11. 无 Action Filter → AOP 能力缺失

无法声明 `[Authorize]`、`[OutputCache]`、`[HandleError]`。权限检查、缓存、异常处理必须在每个 Action 开头手写，没有统一切面。

No `[Authorize]`, `[OutputCache]`, `[HandleError]`. Authentication, caching and error handling must be written at the start of every Action — no unified cross-cutting.

### 12. 无 ORM → 手写 SQL + 手工转义

没有 Entity Framework / Dapper 之类的 ORM。CRUD 是手写 SQL，参数化要么用 `ADODB.Command`，要么像本项目一样用 `Replace(s, "'", "''")` + `CLng()` 手工转义（功能上可行，但不如真正的参数化优雅）。

No ORM like Entity Framework / Dapper. CRUD is hand-written SQL; parameters are either done via `ADODB.Command`, or, as in this project, with `Replace(s, "'", "''")` + `CLng()` (functional, but less elegant than true parameterization).

### 13. 无 TempData API → 手工 Session 管理

ASP.NET MVC 的 `TempData` 有 `Keep()` / `Peek()` 语义。本项目只能用 `Session("_flash")` 手工写、读、清，没有保留或偷看的机制。

ASP.NET MVC's `TempData` has `Keep()` / `Peek()` semantics. This project manually writes, reads and clears `Session("_flash")`, without keep or peek equivalents.

### 14. 无异步 / 无 Task → 所有 I/O 阻塞

VBScript 没有 `async/await`、没有 `Task`。数据库查询、文件读写全部同步阻塞，无法释放线程给其他请求。

VBScript has no `async/await` or `Task`. DB queries and file I/O are all synchronous and blocking, with no way to yield the thread to other requests.

### 15. `<%@LANGUAGE%>` 只能作用于入口页

`<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>` 只对浏览器直接请求的入口页面（`default.asp`）第一行有效，对 `#include` 引入的文件无效。因此 **不能** 把语言/编码声明放到 `config.asp` 或 `_layout_top.asp` 里统一管理。

`<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>` only takes effect on line 1 of the page the browser requests directly (`default.asp`), not on `#include`d files. So the language/encoding declaration **cannot** be centralized into `config.asp` or `_layout_top.asp`.

---

> **小结 / Summary**：
> 上面 15 条全部来自 **VBScript 语言或 ASP Classic 运行时** 的能力边界，不是设计上的取舍。在同等时间成本下，现代 MVC 框架能免费获得的能力，本项目都需要手工实现或直接放弃。这份清单既是本项目的自白，也是「为什么值得升级到现代框架」的参考依据。
>
> **Summary**: All 15 gaps above come from the **capability boundaries of VBScript as a language and ASP Classic as a runtime** — they are not deliberate design trade-offs. For the same engineering effort, capabilities a modern MVC framework gives for free must either be hand-rolled or dropped in this project. This list is both a self-disclosure and a reference for "why upgrading to a modern framework is worthwhile".
