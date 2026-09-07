# 知微公开下载

本仓库仅发布“知微 · 智能需求分析助手”的可执行安装包与 SHA-256 校验文件。

## 当前版本

当前版本：`1.1.7`

- [下载通用安装包](https://github.com/Archytao/zhiwei-releases/releases/download/v1.1.7/zhiwei-requirement-assistant-1.1.7.zip)
- [查看 SHA-256](https://github.com/Archytao/zhiwei-releases/releases/download/v1.1.7/zhiwei-requirement-assistant-1.1.7.zip.sha256)

同一个通用包同时用于首次安装和版本更新。

## 下载规则

- 首次安装和已安装用户统一使用当前版本的 `zhiwei-requirement-assistant-<version>.zip`。
- 安装器会核对文件大小和 SHA-256；校验失败必须停止。
- 历史版本保留在对应 GitHub Release，不覆盖同名资产。

## 安全边界

- 安装包不包含成员凭证、API Key、SSH Token、私钥或密码。
- 成员凭证由管理员通过独立渠道提供。
- 仅从本仓库的 GitHub Release 下载，不接受第三方镜像。
- 版本发布记录与安装包 SHA-256 同时保留，便于审计。

正式项目材料保存在私有仓库 `Archytao/zhiwei`。
