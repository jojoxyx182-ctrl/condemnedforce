#!/bin/sh

ROOTFS_DIR=$(pwd)
export PATH=$PATH:~/.local/usr/bin
max_retries=50
timeout=1
ARCH=$(uname -m)

# SET AUTO YES AGAR TIDAK PERLU KETIK MANUAL
install_ubuntu="yes"

if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
else
  printf "Unsupported CPU architecture: ${ARCH}"
  exit 1
fi

if [ ! -e $ROOTFS_DIR/.installed ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                           UBUNTU 22.04 (JAMMY) INSTALLER"
  echo "#                   Bot WA + Minecraft + Tools + Sudo + All Apt"
  echo "#"
  echo "#######################################################################################"
fi

case $install_ubuntu in
  [yY][eE][sS])
    echo "Downloading Ubuntu 22.04 Rootfs (Latest LTS)..."
    # Menggunakan link Ubuntu Base 22.04
    wget --tries=$max_retries --timeout=$timeout --no-hsts -O /tmp/rootfs.tar.gz \
      "http://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.5-base-${ARCH_ALT}.tar.gz"
    echo "Extracting..."
    tar -xf /tmp/rootfs.tar.gz -C $ROOTFS_DIR
    ;;
  *)
    echo "Skipping Ubuntu installation."
    ;;
esac

if [ ! -e $ROOTFS_DIR/.installed ]; then
  mkdir $ROOTFS_DIR/usr/local/bin -p
  echo "Downloading Proot..."
  wget --tries=$max_retries --timeout=$timeout --no-hsts -O $ROOTFS_DIR/usr/local/bin/proot "https://raw.githubusercontent.com/foxytouxxx/freeroot/main/proot-${ARCH}"

  while [ ! -s "$ROOTFS_DIR/usr/local/bin/proot" ]; do
    rm $ROOTFS_DIR/usr/local/bin/proot -rf
    wget --tries=$max_retries --timeout=$timeout --no-hsts -O $ROOTFS_DIR/usr/local/bin/proot "https://raw.githubusercontent.com/foxytouxxx/freeroot/main/proot-${ARCH}"
    if [ -s "$ROOTFS_DIR/usr/local/bin/proot" ]; then
      chmod 755 $ROOTTS_DIR/usr/local/bin/proot
      break
    fi
    chmod 755 $ROOTFS_DIR/usr/local/bin/proot
    sleep 1
  done
  chmod 755 $ROOTFS_DIR/usr/local/bin/proot
fi

if [ ! -e $ROOTFS_DIR/.installed ]; then
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > ${ROOTFS_DIR}/etc/resolv.conf
  
  # SCRIPT INSTALASI FULL UNTUK UBUNTU 22.04
  cat > $ROOTFS_DIR/root/full_install.sh << 'EOF'
#!/bin/sh
export DEBIAN_FRONTEND=noninteractive

echo "-------------------------------------------------------"
echo "[1/5] SYSTEM UPDATE (Ubuntu 22.04)..."
echo "-------------------------------------------------------"
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y

echo "-------------------------------------------------------"
echo "[2/5] INSTALL SUDO & BASICS..."
echo "-------------------------------------------------------"
apt-get install -y sudo wget curl git unzip zip tar nano vim python3 python3-pip python2 build-essential software-properties-common lsb-release

echo "-------------------------------------------------------"
echo "[3/5] INSTALL NODEJS (Latest LTS)..."
echo "-------------------------------------------------------"
# Menggunakan setup_18.x untuk kompatibilitas bot WA yang maksimal
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

echo "-------------------------------------------------------"
echo "[4/5] INSTALL JAVA (Minecraft)..."
echo "-------------------------------------------------------"
# Ubuntu 22.04 biasanya punya OpenJDK 17 atau 19, kita pakai 17 untuk stabilnya MC
apt-get install -y openjdk-17-jre-headless openjdk-17-jdk

echo "-------------------------------------------------------"
echo "[5/5] MASS INSTALL ALL DEPENDENCIES..."
echo "-------------------------------------------------------"
# Install semua yang dibutuhkan bot, mc, dan tools
apt-get install -y \
  ffmpeg imagemagick screen tmux htop neofetch \
  net-tools dnsutils iputils-ping nmap telnet openssl \
  libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libasound2 \
  ca-certificates gnupg apt-transport-https

echo "-------------------------------------------------------"
echo "Installing PM2 Global..."
echo "-------------------------------------------------------"
npm install -g pm2 yarn

echo "-------------------------------------------------------"
echo "Cleaning up..."
echo "-------------------------------------------------------"
apt-get clean
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*

# Hapus script agar tidak jalan ulang
rm -f /root/full_install.sh
echo ">>> UBUNTU 22.04 READY <<<"
EOF

  chmod +x $ROOTFS_DIR/root/full_install.sh
  touch $ROOTFS_DIR/.installed
fi

CYAN='\e[0;36m'
WHITE='\e[0;37m'
RESET_COLOR='\e[0m'

display_gg() {
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
  echo -e ""
  echo -e "           ${CYAN}-----> MISSION COMPLETED ! <----${RESET_COLOR}"
  echo -e "${CYAN}  Ubuntu 22.04 LTS + NodeJS + Java + All Tools${RESET_COLOR}"
}

clear
display_gg

# JALANKAN PROOT DAN MASUK KE SCRIPT FULL INSTALL
 $ROOTFS_DIR/usr/local/bin/proot \
  --rootfs="${ROOTFS_DIR}" \
  -0 -w "/root" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit \
  /bin/sh -c "/root/full_install.sh; /bin/bash"
