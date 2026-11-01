# Local firmware inputs

A clean image installs the model's GPU, remote-processor and accelerator firmware as a separate tracked package, following the `qcom/sm8250/xiaomi/lmi` layout used by the community mainline firmware repository.

The checksum-pinned input archive is extracted from an unlocked POCO F2 Pro by the owner (the M1 checklist in docs/status.md). It must be supplied privately in the build staging directory's `private-inputs/` folder. This repository contains the recipe and the file list, not the proprietary archive or resulting firmware package. Until the extraction has happened, the recipe's sha512 pin is an explicit `SKIP` pending marker.

GPU GMU/SQE, Wi-Fi (ath11k QCA6390) and Bluetooth firmware come from the generic `linux-firmware` packages and are deliberately not packaged here. The device-extracted `a650_zap.mbn` is installed under `firmware/updates/`, which the kernel searches before the generic directory, so the tested variant wins over any generic copy. See the kernel's [firmware search-path documentation](https://docs.kernel.org/driver-api/firmware/fw_search_path.html).

Device-specific modem NV, IMEI and radio identity are not package inputs. The separate modem service obtains its required device data privately at runtime. Do not publish device partitions, calibration dumps, firmware packages or personalized installation images with the source repository.
