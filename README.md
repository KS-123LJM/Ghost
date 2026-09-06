# 实验01：开源个人博客系统二次开发

> 本仓库为《开源软件与新技术》课程实验01的个人开发仓库，基于Ghost开源博客系统进行二次开发。

## 实验信息

| 项目 | 内容 |
|------|------|
| 课程 | 开源软件与新技术 |
| 实验 | 实验01 开源个人博客系统二次开发 |
| 学号 | 23110506008 |
| 上游项目 | [TryGhost/Ghost](https://github.com/TryGhost/Ghost) |
| 固定Commit | `26746d30ce` |
| 个人仓库 | https://github.com/KS-123LJM/Ghost.git |
| 许可证 | MIT |

## 个人二次开发内容

### 1. 自定义主题 (`theme/oss-blog-theme/`)
基于Casper主题二次开发，主要修改：
- 导航栏增加"关于"和"归档"链接，界面文字中文化
- 文章卡片增加阅读时长和评论数显示
- 文章详情页日期格式化为中文格式（YYYY年MM月DD日）
- 自定义404错误页面，含友好提示和搜索入口
- 增加自定义样式 `assets/css/oss-blog.css`

### 2. 自主功能：基于标签的相关文章推荐
在文章详情页通过Ghost Content API的 `{{#get}}` 助手实现：
- 获取与当前文章拥有相同主标签的其他文章
- 自动排除当前文章本身
- 按发布时间倒序，取前3篇
- 可通过主题设置开关和数量控制
- **不修改Ghost核心代码**，升级不受影响

### 3. 项目文档
- `docs/baseline.md` - 实验基线记录
- `docs/architecture.md` - 项目架构说明
- `tests/acceptance.md` - 验收测试用例（23条，全部通过）
- `NOTICE.md` - 第三方许可证声明

## 快速开始

### 环境要求
- Node.js 22 LTS（实际版本：v22.23.2）
- Git 2.40+（实际版本：2.54.0）
- Ghost CLI 1.32.3+（实际版本：1.32.3）
- 操作系统：Windows 11 / Linux / macOS

### 本地安装与启动

#### 1. 安装Ghost CLI
```bash
npm install -g ghost-cli@latest
ghost --version
```

#### 2. 安装本地Ghost实例
```bash
# 在仓库根目录创建runtime目录并安装
mkdir runtime
cd runtime
ghost install local
```

**注意：Windows环境下需要修复express-hbs路径兼容性问题**，详见下方"Windows兼容性说明"。

#### 3. 启动/停止服务
```bash
# 使用提供的脚本（推荐）
.\scripts\start.ps1    # 启动
.\scripts\stop.ps1     # 停止

# 或使用Ghost CLI
cd runtime
ghost start --development
ghost stop
```

#### 4. 完成初始化
访问 http://localhost:2368/ghost/ 完成管理员账号设置，或使用初始化脚本：
```bash
.\scripts\init-demo.ps1
```

### 演示账号

| 角色 | 邮箱 | 密码 | 说明 |
|------|------|------|------|
| 管理员 | admin@oss-blog.local | Admin@2026Lab | 后台管理、文章发布 |
| 会员1 | zhangsan@oss-blog.local | （需通过前台注册设置） | 评论、会员功能 |
| 会员2 | lisi@oss-blog.local | （需通过前台注册设置） | 评论、会员功能 |

### 演示数据
- **文章**：9篇（含1篇默认欢迎文章 + 8篇自定义文章）
- **标签**：技术分享、生活随笔、开源项目
- **覆盖场景**：长标题、代码块、中文搜索词、多标签、精选文章

### 主题安装
1. 将 `theme/oss-blog-theme/` 打包为zip
2. 在Ghost管理端 → Settings → Design → Change theme → Upload theme
3. 激活 oss-blog-theme 主题

或通过API安装：
```bash
# 打包主题
Compress-Archive -Path theme\oss-blog-theme\* -DestinationPath oss-blog-theme.zip
# 通过管理API上传并激活
```

### 主题开发
```bash
cd theme/oss-blog-theme
npm install
npm run dev    # 开发模式
npm run zip    # 打包为可安装zip
npm test       # gscan兼容性检查
```

### 数据备份与恢复

#### 备份
```bash
# 方式1：使用脚本
.\scripts\backup.ps1

# 方式2：管理端导出
# Ghost管理端 → Settings → Labs → Export your content

# 方式3：直接复制数据库文件
# runtime/content/data/ghost-development.db
```

#### 恢复
1. 停止Ghost服务
2. 将备份的数据库文件复制到 `runtime/content/data/`
3. 启动Ghost服务
4. 或通过管理端 → Settings → Labs → Import content 导入JSON备份

### Windows兼容性说明

Ghost v6.x在Windows环境下存在express-hbs路径兼容性问题，表现为前台返回500错误：
```
Cannot read ...\default it does not reside in content\themes\...
```

**修复方法**：修改 `runtime/versions/<版本>/node_modules/.pnpm/express-hbs@2.5.0/node_modules/express-hbs/lib/hbs.js` 中的 `cacheLayout` 函数，统一路径分隔符并处理相对路径比较。

本仓库已在 `docs/windows-compatibility.md` 中记录详细修复方案。

## 功能清单

### 必做功能（全部完成）
- ✅ 前台和 /ghost 管理端本地访问
- ✅ 会员注册/登录，错误登录有明确提示
- ✅ 管理员发布并编辑文章
- ✅ 文章关联并按标签浏览
- ✅ 会员评论功能（权限控制）
- ✅ 关键词搜索（Ghost原生搜索 + 主题搜索按钮）
- ✅ 自定义主题（桌面和窄屏适配）
- ✅ 自主功能：基于标签的相关文章推荐
- ✅ 重启后内容和评论数据持久化
- ✅ 内容导出与恢复
- ✅ 主题校验和核心流程测试

### 自主功能：相关文章推荐
- **实现方式**：通过Ghost Content API的 `{{#get}}` 助手
- **数据来源**：当前文章的主标签
- **排序规则**：按发布时间倒序
- **排除规则**：自动排除当前文章
- **可配置项**：开关控制、推荐数量（2/3/4篇）
- **修改边界**：仅主题层修改，不涉及Ghost核心代码

## 个人开发记录

| 分支 | 说明 |
|------|------|
| `main` | 主分支，同步上游 + 实验文档 |
| `feature/theme-customization` | 自定义主题开发 |
| `feature/blog-enhancement` | 相关文章推荐功能 |

## 许可证
本项目基于Ghost（MIT）二次开发，本人开发部分采用MIT许可证。详见 [NOTICE.md](./NOTICE.md)。

---

&nbsp;
<p align="center">
  <a href="https://ghost.org/#gh-light-mode-only" target="_blank">
    <img src="https://user-images.githubusercontent.com/65487235/157884383-1b75feb1-45d8-4430-b636-3f7e06577347.png" alt="Ghost" width="200px">
  </a>
  <a href="https://ghost.org/#gh-dark-mode-only" target="_blank">
    <img src="https://user-images.githubusercontent.com/65487235/157849205-aa24152c-4610-4d7d-b752-3a8c4f9319e6.png" alt="Ghost" width="200px">
  </a>
</p>
&nbsp;

<p align="center">
    <a href="https://ghost.org/">Ghost.org</a> •
    <a href="https://forum.ghost.org">Forum</a> •
    <a href="https://docs.ghost.org">Docs</a> •
    <a href="https://github.com/TryGhost/Ghost/blob/main/docs/README.md">Contributing</a> •
    <a href="https://twitter.com/ghost">Twitter</a>
    <br /><br />
    <a href="https://ghost.org/">
        <img src="https://img.shields.io/badge/downloads-100M+-brightgreen.svg" alt="Downloads" />
    </a>
    <a href="https://github.com/TryGhost/Ghost/releases/">
        <img src="https://img.shields.io/github/release/TryGhost/Ghost.svg" alt="Latest release" />
    </a>
    <a href="https://github.com/TryGhost/Ghost/actions">
        <img src="https://github.com/TryGhost/Ghost/actions/workflows/ci.yml/badge.svg?branch=main" alt="Build status" />
    </a>
    <a href="https://github.com/TryGhost/Ghost/contributors/">
        <img src="https://img.shields.io/github/contributors/TryGhost/Ghost.svg" alt="Contributors" />
    </a>
    <a href="https://digitalpublicgoods.net/r/ghost"><img src="https://img.shields.io/badge/Verified-DPG-3333AB?logo=data:image/svg%2bxml;base64,PHN2ZyB3aWR0aD0iMzEiIGhlaWdodD0iMzMiIHZpZXdCb3g9IjAgMCAzMSAzMyIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTE0LjIwMDggMjEuMzY3OEwxMC4xNzM2IDE4LjAxMjRMMTEuNTIxOSAxNi40MDAzTDEzLjk5MjggMTguNDU5TDE5LjYyNjkgMTIuMjExMUwyMS4xOTA5IDEzLjYxNkwxNC4yMDA4IDIxLjM2NzhaTTI0LjYyNDEgOS4zNTEyN0wyNC44MDcxIDMuMDcyOTdMMTguODgxIDUuMTg2NjJMMTUuMzMxNCAtMi4zMzA4MmUtMDVMMTEuNzgyMSA1LjE4NjYyTDUuODU2MDEgMy4wNzI5N0w2LjAzOTA2IDkuMzUxMjdMMCAxMS4xMTc3TDMuODQ1MjEgMTYuMDg5NUwwIDIxLjA2MTJMNi4wMzkwNiAyMi44Mjc3TDUuODU2MDEgMjkuMTA2TDExLjc4MjEgMjYuOTkyM0wxNS4zMzE0IDMyLjE3OUwxOC44ODEgMjYuOTkyM0wyNC44MDcxIDI5LjEwNkwyNC42MjQxIDIyLjgyNzdMMzAuNjYzMSAyMS4wNjEyTDI2LjgxNzYgMTYuMDg5NUwzMC42NjMxIDExLjExNzdMMjQuNjI0MSA5LjM1MTI3WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==" alt="DPG Badge"/></a>
</p>

&nbsp;

> [!NOTE]
> Love open source? We're hiring! Ghost is looking staff engineers to [join the team](https://careers.ghost.org) and work with us full-time

<a href="https://ghost.org/"><img src="https://user-images.githubusercontent.com/353959/169805900-66be5b89-0859-4816-8da9-528ed7534704.png" alt="Fiercely independent, professional publishing. Ghost is the most popular open source, headless Node.js CMS which already works with all the tools you know and love." /></a>

&nbsp;

<a href="https://ghost.org/pricing/#gh-light-mode-only" target="_blank"><img src="https://user-images.githubusercontent.com/65487235/157849437-9b8fcc48-1920-4b26-a1e8-5806db0e6bb9.png" alt="Ghost(Pro)" width="165px" /></a>
<a href="https://ghost.org/pricing/#gh-dark-mode-only" target="_blank"><img src="https://user-images.githubusercontent.com/65487235/157849438-79889b04-b7b6-4ba7-8de6-4c1e4b4e16a5.png" alt="Ghost(Pro)" width="165px" /></a>

The easiest way to get a production instance deployed is with our official **[Ghost(Pro)](https://ghost.org/pricing/)** managed service. It takes about 2 minutes to launch a new site with worldwide CDN, backups, security and maintenance all done for you.

For most people this ends up being the best value option because of [how much time it saves](https://docs.ghost.org/hosting/) — and 100% of revenue goes to the Ghost Foundation; funding the maintenance and further development of the project itself. So you’ll be supporting open source software _and_ getting a great service!

&nbsp;

# Quickstart install

If you want to run your own instance of Ghost, in most cases the best way is to use our **CLI tool**

```
npm install ghost-cli -g
```

&nbsp;

Then, if installing locally add the `local` flag to get up and running in under a minute - [Local install docs](https://docs.ghost.org/install/local/)

```
ghost install local
```

&nbsp;

or on a server run the full install, including automatic SSL setup using LetsEncrypt - [Production install docs](https://docs.ghost.org/install/ubuntu/)

```
ghost install
```

&nbsp;

Check out our [official documentation](https://docs.ghost.org/) for more information about our [recommended hosting stack](https://docs.ghost.org/hosting/) & properly [upgrading Ghost](https://docs.ghost.org/update/), plus everything you need to develop your own Ghost [themes](https://docs.ghost.org/themes/) or work with [our API](https://docs.ghost.org/content-api/).

### Contributors & advanced developers

To contribute to Ghost, start with the
[contributing guide](.github/CONTRIBUTING.md). To work on the monorepo, see the
[codebase documentation](docs/README.md).

&nbsp;

# Ghost sponsors

A big thanks to our sponsors and partners who make Ghost possible. If you're interested in sponsoring Ghost and supporting the project, please check out our profile on [GitHub sponsors](https://github.com/sponsors/TryGhost) :heart:

**[DigitalOcean](https://m.do.co/c/9ff29836d717)** • **[Fastly](https://www.fastly.com/)** • **[Tinybird](https://tbrd.co/ghost)** • **[BairesDev](https://www.bairesdev.com)**

&nbsp;

# Getting help

Everyone can get help and support from a large community of developers over on the [Ghost forum](https://forum.ghost.org/). **Ghost(Pro)** customers have access to 24/7 email support.

To stay up to date with all the latest news and product updates, make sure you [subscribe to our changelog newsletter](https://ghost.org/changelog/) — or follow us [on Twitter](https://twitter.com/Ghost), if you prefer your updates bite-sized and facetious. :saxophone::turtle:

&nbsp;

# License & trademark

Copyright (c) 2013-2026 Ghost Foundation - Released under the [MIT license](LICENSE).
Ghost and the Ghost Logo are trademarks of Ghost Foundation Ltd. Please see our [trademark policy](https://ghost.org/trademark/) for info on acceptable usage.
