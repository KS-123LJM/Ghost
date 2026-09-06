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
| 操作系统 | Windows 11 23H2 | 原生 |
| Node.js | v22.23.2 | 官方安装包 |
| npm | 10.9.8 | 随Node安装 |
| Git | 2.54.0.windows.1 | 官方安装包 |
| Ghost | 5.x（源码monorepo） | git clone |

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

## 风险记录
1. Ghost monorepo完整构建需要pnpm和Docker，本地环境可能不满足
2. 主题开发不依赖核心构建，可独立进行
3. 运行时验证需通过Ghost CLI安装独立实例，或使用Docker开发环境
