# ============================================
# Ghost 演示数据初始化脚本
# 用法：.\scripts\init-demo.ps1
# 功能：安装自定义主题、创建标签/文章/会员、启用评论
# ============================================

$ErrorActionPreference = "Stop"
$BaseUrl = "http://localhost:2368"
$ThemeDir = Join-Path $PSScriptRoot "..\theme\oss-blog-theme"
$TempZip = Join-Path $env:TEMP "oss-blog-theme.zip"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 演示数据初始化" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. 登录
Write-Host "`n[1/7] 管理员登录..." -ForegroundColor Yellow
$loginBody = @{
    username = "admin@oss-blog.local"
    password = "Admin@2026Lab"
} | ConvertTo-Json
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$response = Invoke-WebRequest -Uri "$BaseUrl/ghost/api/admin/session/" -Method POST -Body $loginBody -ContentType "application/json" -WebSession $session -UseBasicParsing
Write-Host "  登录成功" -ForegroundColor Green

# 2. 打包并安装自定义主题
Write-Host "`n[2/7] 打包并安装自定义主题..." -ForegroundColor Yellow
if (Test-Path $TempZip) { Remove-Item $TempZip -Force }
Compress-Archive -Path (Join-Path $ThemeDir "*") -DestinationPath $TempZip -Force

$fileBytes = [System.IO.File]::ReadAllBytes($TempZip)
$fileContent = [System.Text.Encoding]::GetEncoding("iso-8859-1").GetString($fileBytes)
$boundary = [System.Guid]::NewGuid().ToString()
$bodyLines = @(
    "--$boundary",
    "Content-Disposition: form-data; name=`"file`"; filename=`"oss-blog-theme.zip`"",
    "Content-Type: application/zip",
    "",
    $fileContent,
    "--$boundary--",
    ""
)
$body = $bodyLines -join "`r`n"
$response = Invoke-WebRequest -Uri "$BaseUrl/ghost/api/admin/themes/upload/" -Method POST -Body $body -ContentType "multipart/form-data; boundary=`"$boundary`"" -WebSession $session -UseBasicParsing
$themeData = $response.Content | ConvertFrom-Json
Write-Host "  主题上传成功: $($themeData.themes[0].name)" -ForegroundColor Green

# 激活主题
$activateBody = @{ themes = @(@{ name = "oss-blog-theme" }) } | ConvertTo-Json -Depth 5
$response = Invoke-WebRequest -Uri "$BaseUrl/ghost/api/admin/themes/oss-blog-theme/activate/" -Method PUT -Body $activateBody -ContentType "application/json" -WebSession $session -UseBasicParsing
Write-Host "  主题已激活" -ForegroundColor Green

# 3. 创建标签
Write-Host "`n[3/7] 创建标签..." -ForegroundColor Yellow
$tags = @(
    @{ name = "技术分享"; slug = "tech"; description = "软件开发、编程技巧和技术架构分享" },
    @{ name = "生活随笔"; slug = "life"; description = "日常生活、学习感悟和随想" },
    @{ name = "开源项目"; slug = "opensource"; description = "开源软件使用、二次开发和贡献记录" }
)
$tagIds = @{}
foreach ($tag in $tags) {
    $tagBody = @{ tags = @($tag) } | ConvertTo-Json -Depth 5
    $response = Invoke-WebRequest -Uri "$BaseUrl/ghost/api/admin/tags/" -Method POST -Body $tagBody -ContentType "application/json" -WebSession $session -UseBasicParsing
    $createdTag = ($response.Content | ConvertFrom-Json).tags[0]
    $tagIds[$tag.slug] = $createdTag.id
    Write-Host "  标签创建: $($tag.name)" -ForegroundColor Green
}

# 4. 创建会员账号
Write-Host "`n[4/7] 创建会员账号..." -ForegroundColor Yellow
$members = @(
    @{ name = "张三"; email = "zhangsan@oss-blog.local"; note = "演示会员账号1" },
    @{ name = "李四"; email = "lisi@oss-blog.local"; note = "演示会员账号2" }
)
foreach ($member in $members) {
    $memberBody = @{ members = @($member) } | ConvertTo-Json -Depth 5
    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl/ghost/api/admin/members/" -Method POST -Body $memberBody -ContentType "application/json" -WebSession $session -UseBasicParsing
        Write-Host "  会员创建: $($member.name) ($($member.email))" -ForegroundColor Green
    } catch {
        Write-Host "  会员已存在或创建失败: $($member.email)" -ForegroundColor Yellow
    }
}

# 5. 创建演示文章
Write-Host "`n[5/7] 创建演示文章（8篇）..." -ForegroundColor Yellow
$articles = @(
    @{
        title = "Ghost开源博客系统二次开发指南"
        slug = "ghost-customization-guide"
        tags = @(@{ id = $tagIds["opensource"] }, @{ id = $tagIds["tech"] })
        excerpt = "本文详细介绍如何基于Ghost开源博客系统进行二次开发，包括主题定制、功能扩展和API集成。"
        html = "<h2>一、为什么选择Ghost</h2><p>Ghost是一个成熟的开源博客平台，具备完善的编辑器、标签、会员和评论功能。通过二次开发，我们可以在不重写基础能力的前提下，构建符合个人需求的博客系统。</p><h2>二、主题开发</h2><p>Ghost主题基于Handlebars模板引擎，通过修改主题文件可以实现界面定制。主要修改包括导航栏、文章卡片和详情页组件。</p><h2>三、功能扩展</h2><p>利用Ghost Content API的{{#get}}助手，可以在主题中实现相关文章推荐、热门文章等功能，无需修改核心代码。</p><h2>四、总结</h2><p>Ghost的模块化架构使得二次开发变得简单高效，开发者可以专注于业务功能而非基础架构。</p>"
        featured = $true
    },
    @{
        title = "SpringBoot + Vue全栈开发实战笔记"
        slug = "springboot-vue-notes"
        tags = @(@{ id = $tagIds["tech"] })
        excerpt = "记录SpringBoot后端与Vue前端全栈开发过程中的常见问题、解决方案和最佳实践。"
        html = "<h2>项目架构</h2><p>采用前后端分离架构，后端使用SpringBoot + MyBatis-Plus + MySQL，前端使用Vue3 + Element Plus + Axios。</p><h2>常见问题</h2><h3>1. 跨域问题</h3><p>通过CorsConfig配置跨域，或使用Nginx反向代理解决。</p><h3>2. 统一返回格式</h3><p>定义Result类封装返回数据，包含code、message、data字段。</p><h3>3. 全局异常处理</h3><p>使用@ControllerAdvice + @ExceptionHandler实现全局异常捕获。</p><h2>部署方案</h2><p>使用Docker Compose编排应用、数据库和Redis服务，实现一键部署。</p>"
    },
    @{
        title = "数据结构与算法学习心得：栈与队列"
        slug = "data-structure-stack-queue"
        tags = @(@{ id = $tagIds["tech"] })
        excerpt = "深入理解栈和队列的底层实现、应用场景以及在实际编程中的使用技巧。"
        html = "<h2>栈（Stack）</h2><p>栈是一种后进先出（LIFO）的线性表，只允许在表尾进行插入和删除操作。</p><h3>常见应用</h3><ul><li>函数调用栈</li><li>表达式求值</li><li>括号匹配</li><li>浏览器前进后退</li></ul><h2>队列（Queue）</h2><p>队列是一种先进先出（FIFO）的线性表，只允许在表尾插入、表头删除。</p><h3>常见应用</h3><ul><li>任务调度</li><li>消息队列</li><li>广度优先搜索（BFS）</li></ul><h2>Java实现</h2><p>Java中Stack类继承自Vector，推荐使用Deque接口的实现类如ArrayDeque。队列使用Queue接口，实现类有LinkedList、ArrayDeque等。</p>"
    },
    @{
        title = "操作系统内存管理：分页与分段"
        slug = "os-memory-management"
        tags = @(@{ id = $tagIds["tech"] })
        excerpt = "解析操作系统内存管理中的分页机制、分段机制以及段页式存储管理的原理和区别。"
        html = "<h2>内存管理概述</h2><p>操作系统内存管理的主要目标是提高内存利用率、方便用户使用、提供内存保护和共享。</p><h2>分页存储管理</h2><p>将进程地址空间划分为固定大小的页，将物理内存划分为相同大小的页框，通过页表实现地址映射。</p><h3>地址转换</h3><p>逻辑地址 = 页号 + 页内偏移<br>物理地址 = 页框号 × 页面大小 + 页内偏移</p><h2>分段存储管理</h2><p>将程序按逻辑模块划分为段（如代码段、数据段、栈段），每段有独立的地址空间。</p><h2>段页式存储管理</h2><p>结合分段和分页的优点：先将程序分段，每段再分页。通过段表和页表两级映射完成地址转换。</p>"
    },
    @{
        title = "我的2026年学习计划与反思"
        slug = "2026-learning-plan"
        tags = @(@{ id = $tagIds["life"] })
        excerpt = "回顾上半年的学习历程，制定下半年的学习目标，包括技术提升、项目实践和个人成长。"
        html = "<h2>上半年回顾</h2><p>2026年上半年，我完成了移动应用开发课程实训，深入学习了Android开发基础，包括Activity、Fragment、RecyclerView等核心组件。同时参与了图书管理系统项目开发，实践了SpringBoot + Vue的全栈开发流程。</p><h2>下半年目标</h2><h3>技术提升</h3><ul><li>深入学习Java并发编程和JVM调优</li><li>掌握Redis高级特性和应用场景</li><li>学习Docker和Kubernetes容器化部署</li></ul><h3>项目实践</h3><ul><li>完成开源个人博客系统二次开发</li><li>参与一个开源项目的贡献</li><li>搭建个人技术博客并持续更新</li></ul><h3>个人成长</h3><ul><li>坚持每周阅读技术书籍</li><li>每月撰写一篇技术总结</li><li>保持规律的作息和运动</li></ul><h2>结语</h2><p>学习是一个持续的过程，保持好奇心和行动力，才能不断进步。</p>"
    },
    @{
        title = "如何高效阅读开源项目源码"
        slug = "read-open-source-code"
        tags = @(@{ id = $tagIds["opensource"] }, @{ id = $tagIds["tech"] })
        excerpt = "分享阅读大型开源项目源码的方法论和实用技巧，帮助开发者快速理解项目架构和核心逻辑。"
        html = "<h2>阅读前的准备</h2><h3>1. 了解项目背景</h3><p>阅读项目的README、官方文档和架构设计文档，了解项目解决什么问题、核心特性是什么。</p><h3>2. 搭建运行环境</h3><p>将项目在本地运行起来，通过实际操作感受项目功能，这是理解代码的基础。</p><h2>阅读方法</h2><h3>1. 从入口开始</h3><p>找到程序的入口文件（如main函数、启动类），沿着调用链逐步深入。</p><h3>2. 关注目录结构</h3><p>理解项目的模块划分和分层架构，先建立整体认知再深入细节。</p><h3>3. 使用调试工具</h3><p>通过断点调试观察代码执行流程和变量变化，比单纯阅读更高效。</p><h3>4. 绘制架构图</h3><p>边阅读边绘制模块关系图、时序图，帮助梳理思路。</p><h2>推荐工具</h2><ul><li>VS Code + 各种插件</li><li>Sourcegraph - 代码搜索和导航</li><li>draw.io - 绘制架构图</li><li>GitLens - 查看代码历史</li></ul>"
    },
    @{
        title = "SQLite数据库在轻量级应用中的实践"
        slug = "sqlite-lightweight-app"
        tags = @(@{ id = $tagIds["tech"] })
        excerpt = "介绍SQLite数据库的特点、适用场景以及在个人博客和移动应用中的实际使用经验。"
        html = "<h2>SQLite简介</h2><p>SQLite是一个轻量级的关系型数据库，它是一个零配置、无服务器的事务性SQL数据库引擎。SQLite的代码库处于公有领域，因此可以自由用于任何目的。</p><h2>核心特点</h2><ul><li><strong>零配置</strong>：无需安装和配置，直接使用</li><li><strong>无服务器</strong>：数据库就是一个文件，无需独立服务进程</li><li><strong>事务支持</strong>：支持ACID事务，保证数据一致性</li><li><strong>跨平台</strong>：支持Windows、Linux、macOS、Android、iOS等</li><li><strong>轻量级</strong>：库文件只有几百KB，适合嵌入式和移动应用</li></ul><h2>适用场景</h2><ul><li>个人博客和小型网站</li><li>移动应用本地存储</li><li>桌面应用数据存储</li><li>原型开发和测试环境</li><li>物联网设备</li></ul><h2>在Ghost中的应用</h2><p>Ghost本地开发环境默认使用SQLite作为数据库，数据存储在content/data/ghost-development.db文件中。对于个人博客和中小流量站点，SQLite完全可以满足需求。</p><h2>最佳实践</h2><ul><li>定期备份数据库文件</li><li>使用WAL模式提升并发性能</li><li>为常用查询字段创建索引</li><li>避免在高并发写入场景使用</li></ul>"
    },
    @{
        title = "开源软件许可证入门：MIT、Apache、GPL的区别"
        slug = "open-source-licenses"
        tags = @(@{ id = $tagIds["opensource"] })
        excerpt = "详解常见开源许可证的特点和使用限制，帮助开发者正确选择和使用开源软件。"
        html = "<h2>为什么需要许可证</h2><p>开源软件虽然可以免费获取和使用，但并不意味着没有任何限制。开源许可证明确了使用者的权利和义务，保护原作者的知识产权，同时促进软件的自由传播和改进。</p><h2>常见许可证对比</h2><h3>MIT许可证</h3><p>最宽松的许可证之一，允许任何人使用、复制、修改、合并、发布、分发、再许可和销售软件，只需保留版权声明和许可证声明。</p><p><strong>代表项目</strong>：Ghost、Vue.js、React、Node.js</p><h3>Apache 2.0许可证</h3><p>与MIT类似，但额外包含专利授权条款，明确禁止专利侵权诉讼。要求声明对原始文件的修改。</p><p><strong>代表项目</strong>：Apache软件基金会项目、Kubernetes、Android</p><h3>GPL许可证</h3><p>具有传染性（Copyleft）：如果你的项目使用了GPL许可证的代码，你的整个项目也必须以GPL许可证开源。</p><p><strong>代表项目</strong>：Linux内核、Git、WordPress</p><h3>LGPL许可证</h3><p>GPL的弱传染性版本：允许以库的形式被非开源软件引用，但对库本身的修改仍需开源。</p><h2>选择建议</h2><ul><li>希望最大程度推广：MIT或Apache 2.0</li><li>希望保持开源生态：GPL</li><li>作为库被广泛使用：LGPL或MIT</li></ul><h2>注意事项</h2><ul><li>使用开源软件时必须遵守其许可证条款</li><li>保留原始版权声明和许可证文件</li><li>商业产品中使用GPL代码需特别注意传染性</li><li>多许可证兼容性问题需仔细评估</li></ul>"
    }
)

foreach ($article in $articles) {
    $articleBody = @{ posts = @($article) } | ConvertTo-Json -Depth 10
    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl/ghost/api/admin/posts/?source=html" -Method POST -Body $articleBody -ContentType "application/json" -WebSession $session -UseBasicParsing
        $createdPost = ($response.Content | ConvertFrom-Json).posts[0]
        Write-Host "  文章创建: $($article.title)" -ForegroundColor Green
    } catch {
        Write-Host "  文章创建失败: $($article.title) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 6. 启用会员和评论设置
Write-Host "`n[6/7] 配置会员和评论设置..." -ForegroundColor Yellow
$settingsBody = @{
    settings = @(
        @{ key = "members_signup_access"; value = "all" },
        @{ key = "comments_enabled"; value = "all" },
        @{ key = "title"; value = "开源个人博客" },
        @{ key = "description"; value = "基于Ghost二次开发的个人博客系统，记录技术分享、生活随笔和开源项目实践" },
        @{ key = "locale"; value = "zh-CN" },
        @{ key = "timezone"; value = "Asia/Shanghai" }
    )
} | ConvertTo-Json -Depth 5
$response = Invoke-WebRequest -Uri "$BaseUrl/ghost/api/admin/settings/" -Method PUT -Body $settingsBody -ContentType "application/json" -WebSession $session -UseBasicParsing
Write-Host "  设置已更新" -ForegroundColor Green

# 7. 验证
Write-Host "`n[7/7] 验证初始化结果..." -ForegroundColor Yellow
$response = Invoke-WebRequest -Uri "$BaseUrl/ghost/api/admin/posts/?limit=all" -WebSession $session -UseBasicParsing
$postCount = ($response.Content | ConvertFrom-Json).posts.Count
$response = Invoke-WebRequest -Uri "$BaseUrl/ghost/api/admin/tags/?limit=all" -WebSession $session -UseBasicParsing
$tagCount = ($response.Content | ConvertFrom-Json).tags.Count
$response = Invoke-WebRequest -Uri "$BaseUrl/ghost/api/admin/members/?limit=all" -WebSession $session -UseBasicParsing
$memberCount = ($response.Content | ConvertFrom-Json).members.Count

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  初始化完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "文章数量: $postCount 篇" -ForegroundColor White
Write-Host "标签数量: $tagCount 个" -ForegroundColor White
Write-Host "会员数量: $memberCount 个" -ForegroundColor White
Write-Host "前台地址: $BaseUrl/" -ForegroundColor White
Write-Host "管理后台: $BaseUrl/ghost" -ForegroundColor White
Write-Host "管理员账号: admin@oss-blog.local / Admin@2026Lab" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Green
