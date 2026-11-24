# Sources and licenses

Original AMFIAnchor source and tools are licensed under BSD-3-Clause, as set out
in [LICENSE.txt](LICENSE.txt). This license does not relicense upstream projects
or proprietary platform components.

## Build dependencies

Dependencies are not vendored. Use the canonical repositories below; the local
directory names are the build script's defaults.

| Dependency | Tested revision | Local directory | License |
| --- | --- | --- | --- |
| [Lilu](https://github.com/acidanthera/Lilu) | `e4748cc081bf060302c7d3c44a643ce1d11b7e1d` (1.7.2) | `Lilu/` | BSD-3-Clause, [notice](LICENSES/Lilu.txt) |
| [MacKernelSDK](https://github.com/acidanthera/MacKernelSDK) | `05094e5e88cec7caedbfb35e8449ed0db94bf95b` | `MacKernelSDK/` | APSL-2.0 root license, [copy](LICENSES/MacKernelSDK.txt); individual files retain their own notices |

The resulting kext includes code from the SDK's `libkmod.a` and Lilu's
`Library/plugin_start.cpp`, and uses Lilu's headers and runtime API.
Retain the applicable dependency notices when redistributing binaries.
Consult the SDK's per-file notices as well as its root
license; this table is not a claim that every SDK file has one license.

## Compatibility research

- [AMFIPass 1.4.1 / OCLP](https://github.com/dortania/OpenCore-Legacy-Patcher):
  binary compatibility analysis informed the CoreTrust hook targets, certificate
  layout, and policy value. AMFIPass is not included or relicensed. See
  [Dortania's license page](https://dortania.github.io/OpenCore-Legacy-Patcher/LICENSE.html).
- [CoreTrustDemo research notes](https://github.com/zhuowei/CoreTrustDemo/blob/main/littlemis.txt)
  helped identify the CoreTrust root-selection mechanism. No source from that
  project was copied into this implementation.
- [Acidanthera style references](Docs/CodingStyle.md) informed naming, layout,
  and hook terminology. AMFIAnchor's additional auditability rules are its own.

`Injectors/AMFIAnchorInjector.kext` contains the public SPKI and SKID for the
signing CA used by WEX. The repository contains no Apple or AMFIPass originals,
decompiler output, deployment certificates, or signing private keys.
