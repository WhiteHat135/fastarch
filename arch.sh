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
sed -i 's/^HOOKS=(.*)/HOOKS=(base udev net encrypt filesystems)/' /etc/mkinitcpio.conf
touch /boot/loade
wget -P /boot/loader/ http://82.146.57.149:4000/loader.conf