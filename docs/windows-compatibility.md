# Windows环境兼容性修复说明

## 问题描述

Ghost v6.x在Windows环境下运行时，前台页面返回500内部服务器错误，日志显示：

```
ERROR "GET /" 500
MESSAGE: Cannot read C:\...\content\themes\<theme-name>\default it does not reside in content\themes\<theme-name>
Error: Cannot read ... it does not reside in ...
    at ExpressHbs.cacheLayout (.../express-hbs/lib/hbs.js:104:17)
```

## 问题原因

express-hbs库的`cacheLayout`函数中存在路径检查逻辑：

```javascript
if (this.restrictLayoutsTo) {
    if (!layoutFile.startsWith(this.restrictLayoutsTo)) {
        var err = new Error('Cannot read ' + layoutFile + ' it does not reside in ' + this.restrictLayoutsTo);
        return cb(err, null);
    }
}
```

在Windows环境下存在两个兼容性问题：

1. **路径分隔符不一致**：`restrictLayoutsTo`可能使用反斜杠`\`，而`layoutFile`可能使用正斜杠`/`，导致`startsWith`比较失败。

2. **相对路径vs绝对路径**：Ghost设置`restrictLayoutsTo`时使用相对路径（如`content\themes\casper`），而`layoutFile`是绝对路径（如`C:\...\content\themes\casper\default`），绝对路径不会以相对路径开头。

## 修复方案

修改express-hbs库的`cacheLayout`函数，添加Windows路径兼容性处理：

### 修改文件路径
```
runtime/versions/<ghost-version>/node_modules/.pnpm/express-hbs@2.5.0/node_modules/express-hbs/lib/hbs.js
```

### 修改内容（约第102-107行）

**原代码：**
```javascript
if (this.restrictLayoutsTo) {
    if (!layoutFile.startsWith(this.restrictLayoutsTo)) {
        var err = new Error('Cannot read ' + layoutFile + ' it does not reside in ' + this.restrictLayoutsTo);
        return cb(err, null);
    }
}
```

**修复后代码：**
```javascript
if (this.restrictLayoutsTo) {
    // Windows路径兼容性：统一路径分隔符并忽略大小写
    // 同时处理相对路径vs绝对路径的问题
    var normalizedLayoutFile = layoutFile.replace(/\\/g, '/').toLowerCase();
    var normalizedRestrict = this.restrictLayoutsTo.replace(/\\/g, '/').toLowerCase();
    // 如果restrict是相对路径，检查layout是否包含该路径
    var pathMatches = normalizedLayoutFile.startsWith(normalizedRestrict) ||
                      normalizedLayoutFile.indexOf('/' + normalizedRestrict) !== -1 ||
                      normalizedLayoutFile.indexOf(normalizedRestrict + '/') !== -1;
    if (!pathMatches) {
        var err = new Error('Cannot read ' + layoutFile + ' it does not reside in ' + this.restrictLayoutsTo);
        return cb(err, null);
    }
}
```

### 修复逻辑说明

1. **统一路径分隔符**：将反斜杠`\`全部替换为正斜杠`/`
2. **忽略大小写**：Windows文件系统不区分大小写，统一转为小写比较
3. **多重路径匹配**：
   - `startsWith`：绝对路径以restrict开头（Linux/macOS正常情况）
   - `indexOf('/' + restrict)`：绝对路径中包含相对路径（前面有路径分隔符）
   - `indexOf(restrict + '/')`：绝对路径中包含相对路径（后面有路径分隔符）

## 额外修复：主题符号链接问题

Ghost在Windows上使用Junction（连接点）链接内置主题（casper、source），这也可能导致路径解析问题。

### 修复方法
将符号链接替换为实际文件复制：

```powershell
$themesDir = "runtime\content\themes"
$currentThemesDir = "runtime\current\content\themes"

# 删除casper符号链接，替换为实际复制
Remove-Item "$themesDir\casper" -Recurse -Force
Copy-Item "$currentThemesDir\casper" "$themesDir\casper" -Recurse -Force

# 删除source符号链接，替换为实际复制
Remove-Item "$themesDir\source" -Recurse -Force
Copy-Item "$currentThemesDir\source" "$themesDir\source" -Recurse -Force
```

## 验证修复

修复完成后，重启Ghost服务：

```bash
cd runtime
ghost stop
ghost start --development
```

验证前台页面：
- 访问 http://localhost:2368/ 应返回200
- 访问文章详情页应返回200
- 访问标签页应返回200
- Ghost日志中不再出现路径相关错误

## 影响范围

- 此修复仅影响Windows开发环境
- Linux和macOS环境不受此问题影响
- 修复不改变express-hbs的核心功能，仅增强路径检查的兼容性
- 重新安装Ghost后需要重新应用此修复

## 相关Issue

- Ghost GitHub Issue: Windows path compatibility with express-hbs
- express-hbs GitHub: restrictLayoutsTo path comparison on Windows
