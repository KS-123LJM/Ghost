# NOTICE

本项目基于开源软件进行二次开发，以下为第三方资源的许可证声明。

## Ghost 核心系统

- **项目**: Ghost - The professional publishing platform
- **来源**: https://github.com/TryGhost/Ghost
- **许可证**: MIT License
- **版权**: Copyright (c) 2013-2026 Ghost Foundation
- **使用范围**: 作为本项目的核心运行平台，未修改核心代码

## Casper 主题

- **项目**: Casper - A clean, minimal default theme for Ghost
- **来源**: https://github.com/TryGhost/Casper
- **许可证**: MIT License
- **版权**: Copyright (c) 2013-2026 Ghost Foundation
- **使用范围**: 作为自定义主题(oss-blog-theme)的基础，进行了以下修改：
  - 导航栏增加"关于"和"归档"链接
  - 文章卡片增加阅读时长和评论数显示
  - 文章详情页日期格式化为中文格式
  - 增加基于标签的相关文章推荐功能
  - 自定义404错误页面
  - 增加自定义样式(assets/css/oss-blog.css)
  - 界面文字中文化（登录、注册、订阅等）

## jQuery

- **项目**: jQuery JavaScript Library
- **来源**: https://jquery.com/
- **许可证**: MIT License
- **使用方式**: 通过CDN引入，用于移动端菜单和响应式视频

## 图标

- 本主题使用内联SVG图标，基于Feather Icons设计风格
- **Feather Icons**: MIT License, https://feathericons.com/

## 本人开发内容

以下内容为本项目原创开发，采用MIT许可证：
- 相关文章推荐功能实现（post.hbs中的get助手调用）
- 自定义样式扩展（assets/css/oss-blog.css）
- 自定义404页面（error-404.hbs）
- 实验文档（docs/目录下所有文件）
- 测试用例（tests/目录下所有文件）

## 许可证兼容性

本项目所有第三方组件均采用MIT许可证，与项目整体MIT许可证兼容。
网络部署版本保留许可证与源码提供义务。
