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
- Node.js 22 LTS
- Git 2.40+
- pnpm（核心开发）或 Ghost CLI（主题安装）

### 主题安装
1. 将 `theme/oss-blog-theme/` 打包为zip
2. 在Ghost管理端 → Settings → Design → Change theme → Upload theme
3. 激活 oss-blog-theme 主题

### 主题开发
```bash
cd theme/oss-blog-theme
npm install
npm run dev    # 开发模式
npm run zip    # 打包为可安装zip
npm test       # gscan兼容性检查
```

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
