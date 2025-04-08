sudo cp initrd.img-6.5.12-x64v3-xanmod1 /boot/efi/EFI/initrd.img
sudo cp vmlinuz-6.5.12-x64v3-xanmod1 /boot/efi/EFI/vmlinuz
label='PaxxerDeb (EFI stub)'
loader='\EFI\vmlinuz' # Use single \'s !
initrd='\EFI\initrd.img' # Use single \'s !
# Compose default kernel arguments for an EFI-boot
printf -v largs "%s " \
        "root=UUID=$(findmnt -kno UUID /) ro" \
        "rootfstype=$(findmnt -kno FSTYPE /)" \
        "initrd=${initrd}"
# Grab extra kernel arguments from grub2 config.
grub_cmdline=''
if test -f /etc/default/grub; then
        grub_cmdline="$(sed -nE '/^GRUB_CMDLINE_LINUX_DEFAULT=\"/ {s#GRUB_CMDLINE_LINUX_DEFAULT=\"##; s#\"$##; p}' </etc/default/grub)"
fi
# Append extra kernel arguments
if test -n "${grub_cmdline}"; then
        printf -v largs "%s " \
                "${largs%* }" \
                "${grub_cmdline}"
else
        printf -v largs "%s " \
                "${largs%* }" \
                "quiet splash" \
                "add_efi_memmap" \
                "intel_iommu=on" \
                "nvidia-drm.modeset=1"
fi
# echo "${largs%* }"; exit
# Then create the EFI entry:
efibootmgr -c -L "${label}" -l "${loader}" -u "${largs%* }"
