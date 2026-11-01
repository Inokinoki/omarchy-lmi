# Omarchy LMI — 把 omarchy-lmi 移植到 POCO F2 Pro（lmi）

## Context

omarchy-lmi 是 Mi 10T Pro（`lmi`）的 Omarchy 移植。目标设备 POCO F2 Pro（`lmi`）同属 SM8250/kona 平台：SoC、启动、UFS、USB、PMIC/RTC、Adreno 650、QCA6390 Wi-Fi/BT、WCD9380、SSC 传感器组共享；设备差异项 = 面板+触摸（LCD/Novatek → AMOLED/FocalTech）、功放、指纹（屏下 FOD）、主摄（IMX686）、弹出电机、IR。内核基座选用 **yuweiyuan8/linux v6.19**（含现成 lmi DTS + 面板/触摸驱动）。新建仓库 `omarchy-lmi`，提交身份用仓库局部 config `Inoki <veyx.shaw@gmail.com>`。

## 实施步骤

1. **建仓**：`/Users/inoki/Builds/srcs/omarchy-lmi`，`git init` + 局部 `user.name=Inoki` / `user.email=veyx.shaw@gmail.com`。
2. **复制 A 层**：platform/、lock/、config/、patches/、tests/、packaging/（除 libcamera-lmi）、CONTRIBUTING/SECURITY/LICENSE/根 PKGBUILD、docs（部分）。
3. **改名映射**：文件名与内容统一 `lmi → lmi`（包名、路径、D-Bus、env、插件 id、账号、slot 标记、DT token `xiaomi,lmi`、平台 `aarch64-lmi`）。
4. **重写 patch 0001** 身份判定块（`xiaomi,lmi` / `aarch64-lmi` / `omarchy-hw-aarch64-lmi`），其余 6 个补丁仅改名。
5. **实质修改**：display 刷新率白名单 → 60 Hz；wireplumber 相机 conf 与 check_camera_streams.py 留桩（相机 M3）；firmware.PKGBUILD + files.txt 按 lmi 固件清单重写（zap/adsp/cdsp/slpi，sha512 待真机提取后 pin）；install-persistent 机型断言改 POCO F2 Pro。
6. **新建 hardware/lmi-base**：linux-lmi/build-kernel.sh（yuweiyuan8 v6.19 源 + DTB `sm8250-xiaomi-lmi`，条件补丁框架零补丁起步）；Qualcomm 用户态包改名复制（qcom-core、pd-mapper、libssc、iio-sensor-proxy、modemmanager、bootmac、location、video、dsp、modem）；system/（USB gadget、persistent 安装）；docs/STATUS.md 现状矩阵。
7. **新文档**：README（三态状态表：继承已验证 / lmi 社区已验证 / pending 上机）、PROVENANCE.md、architecture.md、roadmap.md（M1 上机点亮 → M2 音频传感器 → M3 相机）；evidence 留空目录。
8. **验证**：check_sources.py（重新生成 SOURCE-SHA256.json）、对上游 omarchy@717175d4 干跑 7 个补丁、grep 审计残留 lmi、首次提交（仅本地）。

**本次不做**：内核交叉编译、boot image、固件提取、刷机（写入 STATUS.md 的 M1 清单，你已解锁真机可直接执行）。