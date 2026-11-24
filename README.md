# g83-11gen-hackintosh-tahoe-efi

> **本机的黑苹果方案被 B 站 UP 主「老张是大佬」点名**（见下图，字幕里的群友五菱宏光s 就是我），在此存个纪念：一个垃圾佬 DIY 的完整成果。
>
> ![老张点名的五菱宏光s](docs/laozhang-mention.jpeg)

东芝 dynabook G83/HS（11 代 Tiger Lake）黑苹果 EFI，支持 macOS Sequoia（15.8.x）与 macOS Tahoe（26.7+）。基于 OpenCore 1.0.8 RELEASE。

**1.4.9 组件与核显配套更新**：升级 Dynabook WhateverXe 0.8.5，配套 Graphics 0.4.5，并切换到 AMFIAnchor + Injector。更新睡眠、有线网卡、Tahoe 音频恢复组件，启用读卡器系统信息识别；沿用 1.4.8 的睡眠与电源键唤醒配置。详见 [1.4.9 更新说明](docs/releases/1.4.9.md)。

## 1. 最低系统要求

本 EFI 同时支持两个系统版本（网卡驱动 SimpleHDA / AirportItlwm 已按内核版本自动分流加载）：

| 系统 | 版本 |
|------|------|
| macOS Sequoia | 15.8.x |
| macOS Tahoe | 26.7 或更新 |

- Tahoe：上游 WhateverXe 对 Tahoe 的门槛即 26.7+（本机 26.7.2 实测通过）
- Sequoia：macOS 15.8.x 实测通过
- OpenCore 1.0.8 RELEASE 或等价版本

## 2. 机型信息

| 项目 | 值 |
|------|-----|
| 机器 | Toshiba dynabook G83/HS（Tiger Lake U 笔记本） |
| CPU | Intel Core i5-1135G7 |
| 核显 | Iris Xe 80EU（`0x9A49`），WhateverXe + Lilu 注入驱动 |
| 网卡 | Intel Wi-Fi 6 + 蓝牙 + 有线 |
| 声卡 | Realtek ALC257 |
| SMBIOS | MacBookPro16,2 |
| 系统 | macOS Sequoia 15.8.x / Tahoe 26.x |

不适配其他机型的部分（SSDT / USB 定制表 / WEX 参数）请按需自行调整。

## 3. 正常功能

| 功能 | 状态 | 说明 |
|------|------|------|
| Wi-Fi | ✅ | AirportItlwm（Intel 无线网卡） |
| 蓝牙 | ✅ | IntelBluetoothFirmware + BlueToolFixup |
| 有线网卡 | ✅ | IntelMausi |
| USB | ✅ | USBToolBox + UTBMap 定制端口表 |
| TF（microSD）卡槽 | ✅ | Realtek RTS522A（`10ec:522a`），1.4.8 更新为 `RealtekCardReader.kext` 0.9.8，以改善睡眠期间的稳定性。1.4.9 启用 RealtekCardReaderFriend 1.0.5，让“系统信息”正常显示内置读卡器。旧版已实测插卡识别与挂载，本次未单独复测读写。 |
| 内屏（息屏）唤醒 | ✅ | 熄屏后可正常恢复 |
| 睡眠唤醒 | ✅ | 1.4.8 改善异常循环唤醒；本机 Sequoia 15.8.2 已实测菜单睡眠、合盖睡眠、电源键及开盖唤醒。长时间待机耗电仍需验证。 |
| 内屏亮度 | ✅ | 已修复开局亮度偏低 |
| `Fn` 亮度快捷键 | ✅ | BrightnessKeys |
| 声卡（扬声器 / 耳机） | ✅ | ALC257 |
| 电池状态 | ✅ | SMCBatteryManager |
| GPU 加速（Metal） | ✅ | WhateverXe 注入驱动 |
| H.264 / HEVC 硬解 | ✅ | 核显媒体引擎 |
| 外接 HDMI 4K@60Hz | ✅ | 稳定无黑闪 |
| 摄像头 | ✅ | 内置摄像头 |
| 内置麦克风 | ✅ | TGLDmic，系统显示为 Internal Microphone (TGLDmic) |
| 外接 Type-C 扩展坞视频输出 | ✅ | 实测 4K@30Hz |

## 4. 已知问题

| 问题 | 现状 / 处理 |
|------|------------|
| 浏览器播放部分在线视频偶尔导致 GPU 卡死 | 1.4.0 已大幅降低发生频率，本机实测 App Store 未再卡死，腾讯会议摄像头正常。 |
| 长时间睡眠耗电 | 1.4.8 短时实测未再出现高频循环唤醒，但睡眠深度仍有波动，整夜耗电尚未验证。 |
| 扩展设备唤醒 | 为减少异常自动唤醒，部分扩展设备的唤醒能力受到限制；建议优先使用电源键唤醒。 |

## 5. WEX（WhateverXe）改进点

本版基于 [WhateverXe 0.8.5](https://github.com/b00t0x/WhateverXe/releases/tag/0.8.5)。下表列出 Dynabook G83 的显示修正，详见 [wex-modified-edition 0.8.5](https://github.com/xiananliu/wex-modified-edition/releases/tag/0.8.5)。

| 解决的问题 | 启动参数 |
|-----------|---------|
| 原生 HDMI 的 4K@60Hz 模式无法选择，或输出时周期性黑闪 | `-wex-hdmi-clock600` 和 `-wex-hdmi-scdc-write`，一起启用 |
| 驱动接管时因异常显示时钟导致内屏黑屏 | `-wex-cdclk-sanitize` |
| 开机亮度偏低 | `-wex-blfix` |
| 长时间熄屏后内屏无法恢复 | `-wex-dcoff`，默认不启用，遇到此问题可单独测试 |

1.4.0 已移除上一版自行实现的 GPU 修复和实验性 eDP 训练补丁。后续 GPU 稳定性修复将随 WhateverXe 上游版本同步。

## 6. 使用说明

1. 用磁盘工具（或 `diskutil mount diskXs1`）挂载 EFI 分区，把本仓库的 `EFI` 覆盖过去（机器自带的 Windows 引导目录可保留不动）。
2. BIOS 设置：关闭 **Secure Boot**即可启动（其他项保持默认）。
3. **三码替换（必做一次）**：`config.plist` 的 `PlatformInfo→Generic` 中 `SystemSerialNumber / MLB / SystemUUID / ROM` 均为空——请用 [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) 选择 `MacBookPro16,2` 生成后再填入；`ROM` 填 12 位随机 MAC，或从另一台真 Mac 抓取（iMessage 更容易通）。**请勿直接使用网络/他人已发布的 serial**。
4. **安装核显运行组件（必装）**：进入 macOS 后，安装与本 EFI 配套的 [WhateverXe-Graphics-0.4.5.pkg](https://github.com/b00t0x/WhateverXe-Graphics/releases/download/v0.4.5/WhateverXe-Graphics-0.4.5.pkg)，然后重启。已安装 0.4.4 的用户需更新到 0.4.5；已经安装 0.4.5 的用户无需重复安装。EFI 已包含 AMFIAnchor 和 Injector，从旧版合并配置时请移除旧 AMFIPass Mod 的加载项，保持新组件启用。
5. **安装内置麦克风组件（必装）**：进入 macOS 后，下载并安装 [`TGLDmic-HAL-startup-fix.pkg`](https://github.com/xiananliu/TGLDmic-HAL-Fix/releases/download/hal-startup-fix-1/TGLDmic-HAL-startup-fix.pkg)。修正版会等内核驱动就绪后再向 Core Audio 注册麦克风，针对开机后输入设备偶尔不出现的问题。如果之前装过原版，直接安装修正版即可替换。安装后重启，在“系统设置 → 声音 → 输入”选择 **Internal Microphone (TGLDmic)**。若 macOS 阻止打开安装包，请在“隐私与安全性”中允许，或在 Finder 中右键选择“打开”。
6. **恢复旧版关闭的睡眠**。更新 EFI 并重启后，如果之前按旧版说明关闭过睡眠，请在终端按需恢复。
   - `sudo pmset -a disablesleep 0` 解除系统睡眠禁用，恢复苹果菜单手动睡眠和合盖睡眠。
   - 旧版的 `sleep 0` 关闭了空闲自动睡眠。若也想恢复自动睡眠，可执行 `sudo pmset -a sleep 1`，为电池和接电模式启用空闲睡眠计时。也可以用 `-b`（电池）或 `-c`（接电）单独设置。
   - `hibernatemode` 保持为 `0` 即可，旧版已设过的用户无需重复执行。这个值关闭写盘休眠，Deep Idle 仍可用。

   1.4.8 已改善此前的高频循环唤醒。更新后先保存工作，在电池供电下做短时睡眠测试，并优先使用电源键唤醒；确认正常后再观察较长时间的待机耗电。使用本次修复需同步更新完整 EFI 配置，不能仅替换一个驱动；升级前请保留自己的机器标识信息。硬件 `SLP_S0` 驻留计数仍为 0，不能仅凭这一项判断整机待机功耗。

## 7. 关联项目

| 项目 | 说明 |
|------|------|
| [OpenCore](https://github.com/acidanthera/OpenCorePkg) | 引导程序（本仓库用 1.0.8 RELEASE） |
| [Lilu](https://github.com/acidanthera/Lilu) | 内核补丁框架 |
| [AMFIAnchor](https://github.com/b00t0x/AMFIAnchor) | 核显组件签名信任（0.1.2 + Injector 1.0.0；许可见 [LICENSE](docs/AMFIAnchor/LICENSE.txt)） |
| [WhateverXe](https://github.com/b00t0x/WhateverXe) | 本机核显驱动的上游（BSD-3-Clause，本仓库 LICENSE 继承其许可体系） |
| [WhateverXe Graphics](https://github.com/b00t0x/WhateverXe-Graphics) | 核显运行组件（首次进系统必装，见使用说明第 4 条） |
| [wex-modified-edition](https://github.com/xiananliu/wex-modified-edition) | 本机使用的 WhateverXe 下游修改版（驱动改进细节见其 README） |
| [VirtualSMC](https://github.com/acidanthera/VirtualSMC) | SMC 模拟（含电池/传感器插件） |
| [S0ixStandby](https://github.com/labrouss/S0ixStandby) | Deep Idle 睡眠与唤醒（v0.5.9，上游预发布版，BSD-3-Clause，许可见 [LICENSE](EFI/OC/Kexts/S0ixStandby.kext/Contents/Resources/LICENSE)） |
| [AppleALC](https://github.com/acidanthera/AppleALC) | 声卡驱动 |
| [SimpleHDA](https://github.com/laobamac/SimpleHDA) | macOS Tahoe 原版 AppleHDA 恢复插件（1.0.2，仅在对应系统加载） |
| [TGLDmic](https://github.com/labrouss/TGLDmic) | Tiger Lake 数字麦克风驱动（BSD-3-Clause；版权归 labrouss 与 TGLDmic contributors；EFI 内含 kext，系统内需安装 HAL pkg） |
| [AirportItlwm](https://github.com/OpenIntelWireless/itlwm) | Intel Wi-Fi 驱动 |
| [IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware) | Intel 蓝牙驱动 |
| [IntelMausi](https://github.com/acidanthera/IntelMausi) | Intel 有线网卡驱动 |
| [VoodooI2C](https://github.com/VoodooI2C/VoodooI2C) / [VoodooRMI](https://github.com/1Revenger1/VoodooRMI) / [VoodooPS2Controller](https://github.com/acidanthera/VoodooPS2) | 触摸板 / 键盘输入栈 |
| [USBToolBox](https://github.com/USBToolBox/kext) | USB 端口定制 |
| [BrightnessKeys](https://github.com/acidanthera/BrightnessKeys) | 亮度快捷键 |
| [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) | 三码生成工具（使用说明第 3 条用到） |

本仓库许可见 [LICENSE](LICENSE)（BSD-3-Clause）；仓库内 OpenCore / kext 等二进制组件版权仍归各自上游。TGLDmic 内嵌 SOF 固件另适用 Intel 许可，见 [LICENCE.Intel](docs/TGLDmic/LICENCE.Intel)。

## 8. 版本与更新

EFI 目录每次更新会自动打 tag 并发布到 [Releases](https://github.com/xiananliu/g83-11gen-hackintosh-tahoe-efi/releases)（附打包好的 EFI zip 与校验文件），变更见各 release 说明与提交记录。
