#!/bin/bash
loadkeys ru
setfont cyr-sun16
echo 'Разметка диска'
{
    echo o;

    echo n;
    echo;
    echo;
    echo +512MB;
    echo ef00;

    echo n;
    echo;
    echo;
    echo +8192;

    echo n;
    echo;
    echo;
    echo;
    
    echo w;
} | gdisk /dev/sda

echo "Создание зашифрованого раздела"
crypsetup -y luksFormat /dev/sda3

crypsetup open /dev/sda3 cryptroot

echo "Форматирование разделов"
mkfs.ext4 /dev/mapper/cryptroot
cd
mount /dev/mapper/cryptroot /mnt
cd /mnt
mkdir boot
mkfs.vfat /dev/sda1
mount /dev/sda1 /mnt/boot
mkswap /dev/sda2
swapon /dev/sda2

echo "Выбор зеркала"
echo "Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch" > /etc/pacman.d/mirrorlist

echo "Установка пакетов"
pacstrap /mnt

echo "Настройка"
arch-chroot /mnt
cd  
bootctl install
sed -i 's/^HOOKS=(.*)/HOOKS=(encrypt keymap base udev autodetect modconf block filesystems keyboard fsck)/' /etc/mkinitcpio.conf
touch /boot/loade
wget -P /boot/loader/ https://raw.githubusercontent.com/WhiteHat135/fastarch/master/etc/loader.conf
wget -P /boot/loader/entries https://raw.githubusercontent.com/WhiteHat135/fastarch/master/etc/arch.conf
mkinitcpio -p linux

echo "Установка пакетов"
pacman -S xorg-server
echo;
echo y;
pacman -S i3
echo 1;
echo y;
wget https://raw.githubusercontent.com/WhiteHat135/fastarch/master/etc/.xinitrc

useradd -m -g users -G audio,lp,optical,power,scanner,storage,video,wheel -s /bin/bash dm
passwd dm

pacman -S sudo
echo y;

wget -P /etc/ https://raw.githubusercontent.com/WhiteHat135/fastarch/master/etc/sudoers

pacman -S xorg-xinint
echo y;

exit 

reboot