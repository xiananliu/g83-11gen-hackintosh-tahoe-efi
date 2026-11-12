# OpenCore 1.0.8 配置校验

公共 `EFI/OC/config.plist` 在 OpenCore 1.0.8 的 `ocvalidate` 中原有
27 项问题：9 项 schema 错误、6 项 ACPI 注释字符问题、12 项 Kernel
注释字符问题。本次修订后，同版本校验结果为 `No issues found`。

修订内容：

- 从 `ACPI/Add` 的亮度 SSDT 项删除不属于该结构的 `Arch`、`MinKernel`、
  `MaxKernel`。
- 为两个 ACPI patch 补齐缺失的 `Base`、`BaseSkip`、`Mask` 默认值。
- 从 `Kernel/Add` 的 GPIO 和 I2CServices 项删除多余的 `Path`，保留原有
  `BundlePath`。
- 将校验器拒绝的非 ASCII `Comment` 改为 ASCII，说明保留在本文。
- 增加 CI，使用与 EFI 匹配的官方 1.0.8 校验器，并验证下载包 SHA-256。

这些 schema 修订不更换驱动、不改变启用状态、补丁查找/替换字节、
内核范围、启动参数、USB 表或机器身份。注释中的 Sequoia 范围按照
实际 `24.2.0`–`24.99.99` 描述。

`ocvalidate` 只验证配置结构及部分一致性；它不验证 ACPI 是否适合本机、
GPU 稳定性、USB 实际接口、功耗或睡眠唤醒。通过校验不等于功能验收。

## 后续独立审查

`VoodooI2C.kext` 的 `OSBundleLibraries` 声明了 GPIO 和 I2CServices
依赖，依赖应排列在消费者之前；这与上述 schema 修订独立记录。

主 XHCI 的 UTBMap 目前有 16 个逻辑端口；一台 i7-1165G7 实机只创建了
15 个，末项 SS04 未出现。需要对每个物理口的 USB2/USB3、Type-C 正反插、
内置蓝牙和摄像头分别确认，再发布机型匹配的端口表。不能凭一次未连接
设备就删除对应端口。

仓库禁用系统睡眠，是对无法唤醒的已知问题的规避。显示器熄屏恢复、
系统睡眠恢复和休眠是不同的验收项。不能为了测试校验修订就直接开启
自动睡眠，也不能把禁用睡眠称作已修复唤醒。
