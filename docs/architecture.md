# 项目总体架构

## 请求处理路径
```
浏览器请求 → Ghost核心服务(ghost/core) → 路由匹配 → 主题模板渲染 → HTML响应
                                    ↓
                              Content API（内容数据）
                                    ↓
                              SQLite/MySQL数据库
```

## 架构层次

| 层次 | 组件 | 职责 | 修改权限 |
|------|------|------|----------|
| 表现层 | 自定义主题(theme/oss-blog-theme) | 页面渲染、导航、文章卡片、详情页、相关推荐 | ✅ 本人开发 |
| 接口层 | Ghost Content API | 向前台主题提供文章、标签、作者等内容数据 | ❌ 不修改 |
| 服务层 | Ghost内容与会员服务 | 文章管理、标签管理、会员认证、评论管理、搜索 | ❌ 不修改 |
| 管理层 | Ghost Admin (apps/admin) | 文章编辑、标签管理、会员设置、评论审核、主题切换 | ❌ 不修改 |
| 数据层 | SQLite内容库 | 存储文章、标签、会员、评论等业务数据 | ⚠️ 本地操作，不提交Git |
| 扩展层 | 搜索/自主扩展模块 | 相关文章推荐、搜索触发器等 | ✅ 本人开发 |

## 关键目录说明

### 允许修改的目录
- `theme/oss-blog-theme/` - 自定义主题源码
- `docs/` - 项目文档
- `tests/` - 测试用例与记录
- `NOTICE.md` - 第三方许可证声明

### 禁止修改的目录（上游核心）
- `ghost/core/` - Ghost核心服务代码
- `apps/` - 前端应用（admin、portal、comments-ui等）
- `packages/` - 内部npm包
- `koenig/` - 编辑器相关包
- `ghost/core/content/data/` - 运行时数据库（不提交Git）
- `ghost/core/content/logs/` - 运行日志（不提交Git）

## 自主功能实现路径
相关文章推荐功能在主题层实现：
1. 文章详情页(post.hbs)使用 `{{#get "posts"}}` 助手调用Content API
2. 过滤条件：同标签 + 排除当前文章
3. 排序：发布时间倒序，取前3篇
4. 渲染为"相关推荐"卡片列表

## 数据流向
```
文章发布 → 写入SQLite → Content API可读 → 主题get助手获取 → 前台渲染
会员注册 → 写入SQLite → 会员服务验证 → 评论权限控制
评论提交 → 写入SQLite → 管理员审核 → 前台显示
```
