/* SPDX-License-Identifier: GPL-2.0-only */
/* reboot-bootloader: initramfs helper that restarts the device into the
 * bootloader so a failed boot stays recoverable. Issues RESTART2 with the
 * "bootloader" argument, which the Qualcomm reboot-mode mapping in the
 * device tree delivers to ABL. Falls back to a forced restart if the
 * bootloader argument is refused: a wrong-but-restarted phone beats a
 * black screen. The initramfs calls this only on the fatal path.
 */
#include <linux/reboot.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <stdio.h>

int main(void)
{
	sync();
	syscall(SYS_reboot, LINUX_REBOOT_MAGIC1, LINUX_REBOOT_MAGIC2,
		LINUX_REBOOT_MAGIC2A, LINUX_REBOOT_MAGIC2B, LINUX_REBOOT_MAGIC2C,
		LINUX_REBOOT_CMD_RESTART2, "bootloader");
	/* RESTART2 refused (older kernel or missing reboot-mode mapping). */
	syscall(SYS_reboot, LINUX_REBOOT_MAGIC1, LINUX_REBOOT_MAGIC2,
		LINUX_REBOOT_MAGIC2A, LINUX_REBOOT_MAGIC2B, LINUX_REBOOT_MAGIC2C,
		LINUX_REBOOT_CMD_RESTART, 0);
	perror("reboot");
	return 1;
}
