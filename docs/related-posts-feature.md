# 自主功能：基于标签的相关文章推荐

## Issue
- **编号**: #3
- **标题**: 实现基于标签的相关文章推荐功能
- **状态**: 已完成

## 用户故事
作为博客读者，我希望在阅读一篇文章时看到与当前文章主题相关的其他文章推荐，以便发现更多感兴趣的内容，延长阅读时间。

## 非目标
- 不实现基于阅读时长的个性化推荐
- 不实现基于用户行为的协同过滤推荐
- 不修改Ghost核心代码
- 不引入额外的后端服务

## 技术方案

### 实现位置
主题层 `post.hbs`，通过Ghost Content API的 `{{#get}}` 助手实现。

### 核心代码
```handlebars
{{#get "posts"
    filter="tags:[{{primary_tag.slug}}]+id:-{{id}}"
    limit="{{@custom.related_posts_count}}"
    include="tags"
    order="published_at desc"
    as |related_posts|}}

    {{#if related_posts}}
        <aside class="related-posts-wrap outer">
            <!-- 推荐文章卡片列表 -->
        </aside>
    {{/if}}
{{/get}}
```

### 过滤逻辑
1. `tags:[{{primary_tag.slug}}]` - 筛选与当前文章主标签相同的文章
2. `id:-{{id}}` - 排除当前文章本身
3. `order="published_at desc"` - 按发布时间倒序
4. `limit` - 可配置数量（默认3篇）

## 为什么放在主题层而不是修改Ghost核心？

| 维度 | 主题层实现 | 修改核心代码 |
|------|-----------|-------------|
| 升级兼容性 | Ghost升级不受影响 | 每次升级需合并冲突 |
| 风险控制 | 可随时切换回默认主题 | 可能引入核心Bug |
| 维护成本 | 低，仅维护主题文件 | 高，需跟踪上游变更 |
| 可复用性 | 可在任何Ghost站点使用 | 绑定特定分支 |
| 开源贡献 | 可独立发布主题 | 需提交PR到上游 |

## 验收条件
- [x] 文章详情页底部显示"相关推荐"区域
- [x] 推荐文章与当前文章有相同主标签
- [x] 当前文章不出现在推荐列表中
- [x] 最多显示3篇（可配置）
- [x] 无相关文章时不显示空区域
- [x] 推荐文章可点击跳转
- [x] 响应式布局，窄屏正常显示
- [x] 不修改Ghost核心代码

## 主题设置项
- `show_related_posts`: 布尔值，默认true，控制是否显示推荐
- `related_posts_count`: 选择2/3/4，默认3，控制推荐数量

## 测试覆盖
详见 `tests/acceptance.md` 中 RF-01 至 RF-05 测试用例。
