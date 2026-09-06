# 实验基线记录

## 项目信息
- **项目名称**: oss-blog（基于Ghost的开源个人博客系统二次开发）
- **上游项目**: TryGhost/Ghost
- **上游仓库**: https://github.com/TryGhost/Ghost
- **个人仓库**: https://github.com/KS-123LJM/Ghost.git
- **固定上游Commit**: 26746d30ce (Added codebase direction guide #30523)
- **实验日期**: 2026-09-06

## 环境版本
| 工具 | 版本 | 安装方式 |
|------|------|----------|
| 操作系统 | Windows 11 家庭版 中文版 v10.0.26200 | 原生 |
| Node.js | v22.23.2 | 官方安装包 |
| npm | 10.9.8 | 随Node安装 |
| Git | 2.54.0.windows.1 | 官方安装包 |
| Ghost CLI | 1.32.3 | npm install -g ghost-cli |
| Ghost（本地运行实例） | v6.59.0 | ghost install local |
| Ghost（源码monorepo） | main分支 (26746d30ce) | git clone |
| 数据库 | SQLite 3（随Ghost安装） | 内置 |

## 本地运行实例
- **安装目录**: `runtime/`（已加入.gitignore，不纳入版本管理）
- **配置文件**: `runtime/config.development.json`
- **数据库文件**: `runtime/content/data/ghost-development.db`
- **服务端口**: 2368
- **前台地址**: http://localhost:2368/
- **管理后台**: http://localhost:2368/ghost/
- **启动命令**: `cd runtime && ghost start --development`
- **停止命令**: `cd runtime && ghost stop`

## 上游基线验证
- [x] 仓库克隆完成，origin指向个人fork
- [x] upstream配置为 https://github.com/TryGhost/Ghost.git
- [x] 当前分支: main
- [x] 工作区干净，未修改上游代码
- [x] LICENSE为MIT许可证
- [x] .gitignore已配置，排除node_modules、运行数据等

## 基线功能清单（上游原生能力）
1. 会员注册/登录
2. 文章发布与编辑（Koenig编辑器）
3. 标签管理
4. 评论系统
5. 原生搜索（sodo-search）
6. 主题切换
7. 内容导入/导出
8. SQLite/MySQL数据存储

## 本人二次开发范围
- 自定义主题：基于Casper修改，放在 theme/oss-blog-theme/
- 自主功能：基于标签的相关文章推荐（在主题层通过get助手实现）
- 不修改 ghost/core/ 下的任何核心代码

## 风险记录与解决方案
1. Ghost monorepo完整构建需要pnpm和Docker，本地环境可能不满足
   - **解决方案**：使用Ghost CLI安装独立运行实例，主题开发不依赖核心构建
2. 主题开发不依赖核心构建，可独立进行
3. 运行时验证需通过Ghost CLI安装独立实例，或使用Docker开发环境
4. **Windows路径兼容性问题**（已解决）：
   - **问题**：express-hbs的restrictLayoutsTo路径检查在Windows下失败，前台返回500
   - **原因**：路径分隔符不一致（/ vs \）、相对路径vs绝对路径比较
   - **解决方案**：修改express-hbs的cacheLayout函数，统一路径分隔符并增强匹配逻辑
   - **详细说明**：见 `docs/windows-compatibility.md`
5. **Windows主题符号链接问题**（已解决）：
   - **问题**：Ghost使用Junction链接内置主题，可能导致路径解析问题
   - **解决方案**：将符号链接替换为实际文件复制
