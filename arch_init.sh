#!/bin/bash
set -x

umount /mnt
fdisk --wipe always --wipe-partitions always /dev/vda <<EOF
o

n
p
1

+256M

t
1
82

n
p
2


a
2

p
w
q
EOF

mkfs.xfs -L root /dev/vda2
mount /dev/vda2 /mnt

echo 'Server = http://daemons.colfax.radious.co:7878/$repo/os/$arch' > /etc/pacman.d/mirrorlist
pacstrap /mnt base linux linux-firmware grub xfsprogs bash-completion vim tmux htop git sudo openssh networkmanager

genfstab -U /mnt | tee /mnt/etc/fstab
echo "en_US.UTF-8 UTF-8" | tee /mnt/etc/locale.gen
echo "archlinux-$RANDOM" | tee /mnt/etc/hostname
echo "%sudo ALL=(ALL) NOPASSWD: ALL" | tee /mnt/etc/sudoers

arch-chroot /mnt mkinitcpio -P linux
arch-chroot /mnt mkdir -p /boot/grub
arch-chroot /mnt sed -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT.*$/GRUB_CMDLINE_LINUX_DEFAULT="net.ifnames=0 panic=10"/g' /etc/default/grub
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt grub-install /dev/vda

arch-chroot /mnt locale-gen
arch-chroot /mnt timedatectl set-timezone America/Los_Angeles
arch-chroot /mnt systemctl enable --now sshd
arch-chroot /mnt systemctl enable --now NetworkManager

arch-chroot /mnt groupadd sudo
arch-chroot /mnt groupadd wheel
arch-chroot /mnt useradd -m ryan
arch-chroot /mnt passwd -d ryan
arch-chroot /mnt usermod -a -G sudo,wheel,adm ryan

arch-chroot /mnt sudo -u ryan bash -xc 'cd /home/ryan; git clone https://github.com/ryanmjacobs/rd .rd; cd .rd; ./basic'
