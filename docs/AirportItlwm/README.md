# Tahoe 企业 Wi-Fi 认证修复

## 问题与结果

原 Tahoe 驱动 `2.4.0_7204c69` 在本次 AX201 测试中可以连接个人热点，却无法完成 WPA2-Enterprise / 802.1X 认证：收到 EAP Request Identity 后，认证客户端报 `Transmit: unknown BSSID, not sending`、`EAPOLSocketTransmit failed`，随后 `State=No Authenticator`。换用同提交的官方 DEBUG 构建后仍能复现，未进入服务器证书交换。

将 Tahoe 驱动换为 `4240f66` 构建并重启后，同一企业网络出现以下结果，取得 DHCP 租约并可通过 Wi-Fi 访问外网：

```text
Receive Packet ... EAP Success (3)
en1 EAP-PEAP: successfully authenticated
State=Authenticated Status=OK (0)
```

连接初期仍出现过一次 `EAPOLSocketTransmit failed`，随后认证成功。因此验收应看最终认证状态与实际联网结果，不能只判断日志里是否出现过瞬时错误。

## 修复来源

修复来自 [wfx1024/itlwm 的 fix/enterprise-eapol 分支](https://github.com/wfx1024/itlwm/tree/4240f66185acdd5d26b99a61ae5c1f33dc9e3b8c)，对应 [laobamac/itlwm PR #35](https://github.com/laobamac/itlwm/pull/35)。截至 2026-11-12，该 PR 已关闭且未合并；此构建不是 laobamac 的正式修复发布。本仓库收录并验证现有修复，作者归属仍为原项目及补丁贡献者。

该提交基于 `7204c69`，改动集中在四个源码文件：

- Skywalk 接口及 ioctl 的 `getBSSID()` 从 `S_ASSOC` 起、在 `ic_bss` 有效时返回 BSSID。
- WCL 的 `enqueuePacket()` 放宽预认证阶段的状态限制。
- `ieee80211_newstate()` 对 802.1X AKM 在关联时提升链路状态，让用户空间认证客户端能够开始交换 EAPOL。

源码差异见 [enterprise-eapol-8021x.patch](enterprise-eapol-8021x.patch)。完整对应源码及原构建工程在 [itlwm-4240f66-source.zip](itlwm-4240f66-source.zip)，解包后的 `.github/workflows/main.yml` 保留构建流程。本次使用现有构建，未在测试机重新编译。

| 项目 | 值 |
|---|---|
| 源码提交 | `4240f66185acdd5d26b99a61ae5c1f33dc9e3b8c` |
| 构建 | [GitHub Actions run 41782505063](https://github.com/wfx1024/itlwm/actions/runs/41782505063)，artifact `AirportItlwm-Tahoe-Release` |
| 下载途径 | [nightly.link 的公开 Actions 产物入口](https://nightly.link/wfx1024/itlwm/actions/runs/41782505063/AirportItlwm-Tahoe-Release.zip) |
| 内层包 | `AirportItlwm-Tahoe-v2.4.0-RELEASE-alpha-4240f66.zip` |
| 驱动 SHA-256 | `beccc746aff1f5da5e21095e8c5134fd223ed17b73a3c571f065db38a8254f0d` |
| Mach-O UUID | `753318A3-7D10-34F5-B187-FAD3AC25D69B` |
| Info.plist | 与原 Tahoe RELEASE 构建相同，bundle version 仍为 `2.4.0` |

驱动、源码归档及补丁校验值见 [SHA256SUMS](SHA256SUMS)，可从仓库根目录运行 `shasum -a 256 -c docs/AirportItlwm/SHA256SUMS`。本次驱动哈希也与 [另一位 Tahoe 测试者公布的结果](https://github.com/WilliamAlexanda/macOS-for-RedmiBook-Pro-15-2021/blob/dabdc0b9e466a55f1a91fb4c35f07c0f016d95a2/docs/wifi-8021x.md) 一致。Actions 产物可能过期；本仓库保留所用二进制与对应源码。

## 本次验证范围

2026-11-12，i7-1165G7 / Intel AX201（PCI `8086:A0F0`，subsystem `8086:0074`），macOS 26.7.3（25G342，Darwin 25.6.0），OpenCore 1.0.8。

| 检查 | 结果 |
|---|---|
| 重启后加载修复构建 | `kmutil showloaded --list-only` 的 UUID 与上表一致 |
| WPA2-Enterprise / PEAP | 同一网络由认证超时变为 `Authenticated` |
| DHCP 与实际联网 | 获得公司网段租约，默认路由经过 Wi-Fi，外部 HTTPS 请求成功 |
| 配置兼容性 | 修复仅替换 Tahoe kext 可执行文件；无需改名或修改 Kernel.Add；本机用于启动测试的修订配置通过 OpenCore 1.0.8 的 ocvalidate |

本次是一个企业网络的连接验证。修复构建的热点回归、长时间运行、重复重启重连、漫游、睡眠恢复及其他 EAP 方法尚未在本机完成验证；也没有据此扩展 WPA3-only、mandatory PMF 或其他 macOS 版本的支持承诺。Sequoia 的驱动与验证范围保持原状。

**吞吐尚待验收**：用户反馈连接后速度偏慢。本机显示 5GHz / 40MHz、802.11ac、400 Mbps 协商速率，RSSI -57 dBm。公网测试同时存在 Clash Verge TUN 路由变量：一次 5 MB 下载经过 TUN 约 2.2 Mbps，指定真实服务器地址并绑定 Wi-Fi 接口直连约 6.1 Mbps；系统短时测速约 15.2 Mbps。测试期间接口收发错误计数未增加，但这些公网测量不足以判定无线驱动吞吐，也不足以排除无线重传、AP 策略或公司出口限制。尚无同位置 iPhone 对照或局域网吞吐测试，速度问题未解决。

仓库原有 `config.plist` 与本机实际使用的修订配置不同。本次不修改仓库配置；原配置在 ocvalidate 1.0.8 中已有 27 项 schema / 注释问题，修改前后配置逐字节一致，检查结果也相同。上述本机配置检查通过不代表仓库原配置已通过完整校验。

公开记录仅保留硬件、构建信息和上述匿名日志摘录。

## 使用与回退

1. 将已有可启动 EFI 完整备份到操作系统之外也能访问的位置。升级本仓库时保留自己的身份信息。
2. 本次变化仅为 `EFI/OC/Kexts/AirportItlwm-Tahoe.kext/Contents/MacOS/AirportItlwm`，重启后才生效。通过固件版本后缀 `_4240f66` 或上表 UUID 核对实际加载构建。
3. 使用公司规定的 EAP 方法和账号格式。若出现证书提示，按公司 IT 提供的信息核对服务器身份与证书。
4. 需要回退时，将备份中的原 Tahoe kext 恢复到相同位置再重启。本仓库变更前提交为 `112eca2dc2600dfacec427f91ac2648cf0025457`，原可执行文件 SHA-256 为 `34e757cd087673e341f070a7af801db947d8607269b2862f5933bbf81836b06c`。

驱动及其源码沿用 [GPL-2.0 许可](LICENSE)；内嵌 Intel 固件另见 [iwlwifi-firmware-license](iwlwifi-firmware-license)。源码中其他文件的版权及许可声明一并保留。
