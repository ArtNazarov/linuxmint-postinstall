 echo "Linux Mint 22 post install script"
 echo "author: programmist.nazarov@gmail.com, 2024"
 
 
# ---------- KEYS  -----------

#!/bin/bash

echo "INSTALL KEYS (NEED AWAIT LONG TIME)? [Y/N]?"
echo "Confirm [Y/n]"
read input

if [[ $input == "Y" || $input == "y" ]]; then
    # Update the package list
    sudo apt update

    # List expired keys and update them
    expired_keys=$(sudo apt-key list | grep "expired: " | sed -ne 's|pub .*/\([^ ]*\) .*|\1|gp')

    if [ -n "$expired_keys" ]; then
        for key in $expired_keys; do
            echo "Updating key: $key"
            sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$key"
            # Optionally, add the key to the keyring
            sudo gpg --export "$key" | sudo tee /usr/share/keyrings/"$key.gpg" > /dev/null
        done
    else
        echo "No expired keys found."
    fi
else
    echo "Skipped keys update."
fi


# ---------- MIRRORS CHANGE -----------
 
echo "Change Linux Mint mirrors? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
# Update the mirror list
sudo apt update

# Install the netselect tool
wget http://ftp.us.debian.org/debian/pool/main/n/netselect/netselect_0.3.ds1-29_amd64.deb
sudo dpkg -i netselect_0.3.ds1-29_amd64.deb

# Find the fastest Linux Mint mirror
mirror=$(sudo netselect -s 20 -t 40 $(wget -qO - https://www.linuxmint.com/mirrors.php | grep -o -E 'https?://[^ ]+packages/' | sort -u) | awk 'NR==2{print $2}')

# Update the sources.list with the fastest mirror
sudo sed -i "s|http://packages.linuxmint.com/|$mirror|g" /etc/apt/sources.list.d/official-package-repositories.list

# Update the package lists
sudo apt update

else
echo "Skipped mirrors setup"
fi


# ---------- MAKE TOOLS  -----------

echo "INSTALL MAKE TOOLS (RECOMMENDED)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	sudo apt-get install autoconf gcc automake build-essential git llvm-17 clang-17 lld-17
else
        echo "skipped make tools install"
fi


# ---------- SYSTEM TOOLS  -----------

echo "INSTALL SYSTEM TOOLS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	sudo apt install gvfs-fuse
	sudo apt install ccache
	sudo add-apt-repository ppa:danielrichter2007/grub-customizer
	sudo apt update
	sudo apt install grub-customizer
	sudo apt install mc
else
        echo "skipped SYSTEM TOOLS install"
fi
 

# -------------NETWORK -------------

echo "INSTALL NETWORKING TOOLS (RECOMMENDED)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		sudo apt install wpa_supplicant
		sudo apt install isc-dhcp-server
		# sudo systemctl mask NetworkManager-wait-online.service		
else
        echo "skipped networking install"
fi

# ---------- proc frequency ----------
cd ~
echo "INSTALL PROC FREQ TOOLS (RECOMMENDED)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

		sudo apt-get update                     
		sudo apt-get install cpupower-gui
		sudo apt-get install linux-tools-common linux-tools-generic linux-tools-`uname -r`

		# wget https://github.com/vagnum08/cpupower-gui/releases/latest/download/cpupower-gui_1.0.0-1_all.deb
		 
		# sudo apt install ./cpupower-gui_1.0.0-1_all.deb		
else
        echo "skipped PROC FREQ install"
fi
cd -


# ---------- proc frequency ----------
cd ~
echo "INSTALL AUTO FREQ TOOLS ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		sudo apt-get install git
		git clone https://github.com/AdnanHodzic/auto-cpufreq.git
		cd auto-cpufreq   
		sudo ./auto-cpufreq-installer                                      
		 cd -
else
        echo "skipped AUTO FREQ install"
fi
cd -

# ------------ INSTALL ZEN KERNEL ------


cd ~
echo "INSTALL ZEN KERNEL ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

	# Step 1: Prepare your environment
	sudo apt update
	sudo apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev

	# Step 2: Download the sources
	cd /usr/src
	sudo git clone git://git.zen-sources.org/zen/zen.git linux-2.6-zen
	sudo ln -s linux-2.6-zen linux
	cd linux

	# Step 3: Configure the kernel
	sudo make menuconfig

	# Step 4: Build the kernel
	sudo make -j$(nproc)

	# Step 5: Install the kernel
	sudo make modules_install
	sudo make install

	# Step 6: Update ZEN-Sources
	sudo update-initramfs -c -k all
	sudo update-grub

	# Step 7: Removing ZEN-Sources
	cd /usr/src
	sudo rm -rf linux-2.6-zen

	echo "Zen kernel installation completed. Please reboot your system to use the new kernel."


else
        echo "skipped ZEN KERNEL install"
fi


# ------------ INSTALL XAN MOD KERNEL FOR AMD ------


cd ~
echo "INSTALL XANMOD KERNEL ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

	
	# Update system packages
	sudo apt update -y && sudo apt upgrade -y

	# Add XanMod repository
	echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list

	# Import GPG keys
	wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -

	# Install XanMod Kernel
	sudo apt update && sudo apt install linux-xanmod -y

	# Reboot system
	# sudo reboot

else
        echo "skipped XANMOD install"
fi

# ------------ INSTALL TKG KERNEL FOR AMD ------


cd ~
echo "INSTALL LINUX TKG KERNEL ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

	
	# Install git
	sudo apt install git

	# Clone the Github repository
	git clone https://github.com/Frogging-Family/linux-tkg.git

	# Change directory to the cloned repository
	cd linux-tkg

	# Optional: edit the "customization.cfg" file to enable/disable patches

	# Execute the install script
	./install.sh install

	# Reboot the system
	# sudo reboot

else
        echo "skipped LINUX TKG install"
fi


# ------------ update grub ------


cd ~
echo "Update grub (Y if install kernel) [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

	sudo update-grub 

else
        echo "skipped grub update"
fi


# ---------- VULKAN -----------

echo "INSTALL VULKAN? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	       
	# Add Mesa PPA
	sudo add-apt-repository ppa:kisak/kisak-mesa

	# Add Vulkan PPA
	sudo add-apt-repository ppa:oibaf/graphics-drivers

	# Update package list
	sudo apt update

	# Install Mesa and lib32-mesa
	sudo apt install mesa lib32-mesa

	# Install Vulkan packages
	sudo apt install vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader 
	sudo apt install libvulkan1 mesa-vulkan-drivers vulkan-utils
	


else
        echo "skipped vulkan installation"
fi

# -------------------------- 

# ---------- PORTPROTON -----------

echo "INSTALL AMD DRIVERS FOR GAMING AND PORTPROTON? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin pre installation"
	 	sudo dpkg --add-architecture i386
		sudo add-apt-repository multiverse
		sudo apt update
		sudo apt install curl file libc6 libnss3 policykit-1 xz-utils bubblewrap mesa-utils icoutils tar libvulkan1 libvulkan1:i386 zstd cabextract xdg-utils openssl libgl1 libgl1:i386

       wget -c "https://github.com/Castro-Fidel/PortWINE/raw/master/portwine_install_script/PortProton_1.0" && sh PortProton_1.0 -rus

else
        echo "skipped amd graphics and portproton installation"
fi

# --------------------------


# ---------- DBUS BROKER FOR VIDEO -----------
cd ~
echo "ENABLE DBUS BROKER ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then


	sudo apt update
	sudo apt install dbus-broker
	sudo systemctl enable dbus-broker.service
	sudo systemctl start dbus-broker.service

else
        echo "skipped dbus broker install"
fi
cd -
# --------------------------



# ---------- CLEAR FONT CACHE -----------

echo "CLEAR FONT CACHE? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "clear font cache"
		sudo apt update
		sudo apt install fontconfig
        sudo rm -rf /var/cache/fontconfig/*
		sudo fc-cache -f -v

else
        echo "skipped clearing font cache"
fi

# --------------------------


# ---------- remove prev google  -----------

echo "REMOVE PREVIOUS GOOGLE CHROME INSTALLATION? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "clear prev. google chrome installation"
        cd ~/.config
		rm -rf google-chrome
else
        echo "skipped clearing google chrome"
fi

# --------------------------




# ---------- SECURITY  -----------

echo "INSTALL SECURITY TOOLS (APPARMOR, FIREJAIL)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	# Update package lists to ensure you have the latest information
	sudo apt update

	# Install AppArmor and AppArmor utilities, including additional profiles for better security
	sudo apt install apparmor apparmor-utils apparmor-profiles -y

	# Verify that AppArmor is active
	sudo systemctl status apparmor

	# If AppArmor is not active, enable and start the service
	sudo systemctl enable apparmor
	sudo systemctl start apparmor

	# Add AppArmor parameters to kernel parameters for enhanced security
	sudo sed -i 's/quiet splash/apparmor=1 security=apparmor quiet splash/g' /etc/default/grub
	sudo update-grub

	# Install Firejail for application sandboxing
	sudo apt install firejail -y

	# Install Firetools (optional) for easier management of Firejail profiles
	sudo apt install firetools -y

        
else
        echo "skipped security install"
fi

# --------------------------



# ---------- BLUETOOTH TOOLS  -----------

echo "INSTALL BLUETOOTH TOOLS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        
		echo "begin install bluetooth"
        
		sudo apt install bluez

		sudo apt install bluez-utils
		
		sudo apt install blueman
		
		sudo systemctl enable bluetooth.service
		
		sudo systemctl start bluetooth.service
		
		sudo dpkg --configure -a


else
        echo "skipped bluetooth install"
fi

# --------------------------



# ---------- SOUND  -----------

echo "INSTALL SOUND TOOLS(PULSEAUDIO)? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
        echo "begin install sound"
		 # Update package list
		sudo apt update

		# Install PulseAudio
		sudo apt install pulseaudio

		# Install PulseAudio Bluetooth support
		sudo apt install pulseaudio-module-bluetooth

		# Install JACK audio connection kit and its D-Bus support
		sudo apt install jack2 jack2-dbus

		# Install PulseAudio ALSA and JACK integration
		sudo apt install pulseaudio-alsa pulseaudio-module-jack

		# Install PulseAudio Volume Control
		sudo apt install pavucontrol

		# Restart PulseAudio to apply changes
		pulseaudio -k
		pulseaudio --start

		# Set ownership of PulseAudio configuration directory
		sudo chown $USER:$USER ~/.config/pulse

else
        echo "skipped sound install"
fi

# --------------------------


# ---------- PIPEWIRE SOUND  -----------

echo "INSTALL PIPEWIRE SOUND ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

		echo "begin pipewire sound"

		# Update the package list
		sudo apt update

		# Install client libraries
		sudo apt install -y pipewire-audio-client-libraries libspa-0.2-bluetooth libspa-0.2-jack

		# Install pipewire-alsa
		sudo apt install -y pipewire-alsa

		# Install pipewire-jack
		sudo apt install -y pipewire-jack

		# Install pavucontrol
		sudo apt install -y pavucontrol

		# Disable pipewire-pulse.service and pipewire-pulse.socket
		sudo systemctl --global --now disable pipewire-pulse.service pipewire-pulse.socket

		# Copy configuration files
		sudo cp /usr/share/doc/pipewire/examples/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/

		# Restart PipeWire services to apply changes
		systemctl --user restart pipewire pipewire-pulse

		# Check if PipeWire is running
		pactl info


else
        echo "skipped pipewire sound install"
fi

# --------------------------

# ---------- ALSA SOUND  -----------

echo "INSTALL ALSA SOUND ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	echo "begin ALSA sound"

	# Update the apt package database
	sudo apt-get update

	# Install alsa-tools (optional, for additional ALSA utilities)
	sudo apt-get install -y alsa-tools

	# Install alsa-base (core ALSA components)
	sudo apt-get install -y alsa-base

	# Optionally, install aptitude (a more powerful package manager)
	sudo apt-get install -y aptitude

	# Update the apt database using aptitude (optional, since we already updated with apt-get)
	sudo aptitude update

	# Install alsa-base using aptitude (optional, since we already installed it with apt-get)
	sudo aptitude install -y alsa-base

else
        echo "skipped ALSA sound install"
fi

# --------------------------





# ---------- AUDIO PLAYER  -----------

echo "INSTALL AUDIO PLAYERS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	echo "begin install audio players"

	# Update package list
	sudo apt-get update

	# Install python-pip
	sudo apt-get install -y python3-pip

	# Install httpx library
	pip3 install httpx

	# Install foobnix
	sudo apt-get install -y foobnix

	# Install clementine
	sudo apt-get install -y clementine

	# Install Audacious
	sudo apt-get install -y audacious

	# Install Strawberry Music Player
	sudo apt-get install -y strawberry

	# Install VLC Media Player
	sudo apt-get install -y vlc

	# Install MPV
	sudo apt-get install -y mpv

	# Install Quod Libet
	sudo apt-get install -y quodlibet

	echo "Audio players installation completed."


else
        echo "skipped audio players install"
fi

# --------------------------



# ---------- INTERNET TOOLS  -----------

echo "INSTALL INTERNET TOOLS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	echo "begin install internet tools"

	# Install qBittorrent
	sudo apt-get install qbittorrent -y

	# Add uGet PPA and install uGet
	sudo add-apt-repository ppa:uget-team/ppa -y
	sudo apt-get update
	sudo apt-get install uget -y

	# Install uGet Integrator
	sudo apt-get install uget-integrator -y

	# Install FileZilla
	sudo apt-get install filezilla -y

	# Install PuTTY
	sudo apt-get install putty -y

	# Install Transmission (BitTorrent client)
	sudo apt-get install transmission -y

	# Install MEGAsync (cloud storage client)
	sudo apt-get install megasync -y

	# Install Warpinator (local file sharing)
	sudo apt-get install warpinator -y

	# Install OpenSSH Client (SSH client)
	sudo apt-get install openssh-client -y

	# Install Remmina (remote desktop client, supports SSH)
	sudo apt-get install remmina -y

	# Install Terminator (advanced terminal emulator, useful for SSH)
	sudo apt-get install terminator -y

	echo "Installation of internet tools completed."


else
        echo "skipped internet tools install"
fi

# --------------------------
 

# ---------- SCREENCAST TOOLS  -----------

echo "INSTALL SCREENCAST TOOLS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	echo "begin install SCREENCAST tools"

	# Add Vokoscreen repository
	sudo add-apt-repository -y ppa:ubuntuhandbook1/apps

	# Add OBS Studio repository
	sudo add-apt-repository -y ppa:obsproject/obs-studio

	# Add SimpleScreenRecorder repository
	sudo add-apt-repository -y ppa:maarten-baert/simplescreenrecorder

	# Update package list
	sudo apt update

	# Install Vokoscreen
	sudo apt install -y vokoscreen

	# Install OBS Studio
	sudo apt install -y obs-studio

	# Install Kazam
	sudo apt install -y kazam

	# Install SimpleScreenRecorder
	sudo apt install -y simplescreenrecorder

	# Install screenshot tools
	sudo apt install -y flameshot shutter

	echo "Installation of SCREENCAST and screenshot tools completed."

else
        echo "skipped SCREENCAST tools install"
fi

# --------------------------




# ---------- DEVELOPER TOOLS  -----------

echo "INSTALL DEVELOPER TOOLS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
       echo "begin install developer tools" 
       sudo apt install default-jdk
       sudo apt install netbeans
       sudo apt-get install -f 
       sudo apt install software-properties-common apt-transport-https wget
       wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
       sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
       sudo apt-get install -f 
       sudo add-apt-repository ppa:notepadqq-team/notepadqq
	sudo apt-get update
	sudo apt-get install notepadqq sudo add-apt-repository ppa:ubuntu-lazarus/ppa
	sudo apt-get update
	sudo apt-get install -y lazarus-ide-qt5 sudo apt install software-properties-common
	sudo add-apt-repository ppa:beineri/opt-qt-5.15.2-jammy
	sudo add-apt-repository ppa:beineri/opt-qt-5.15.2-focal
	sudo apt-get update
	sudo apt-get install qtcreator sudo add-apt-repository multiverse && sudo apt-get update
	sudo apt-get install virtualbox
	sudo apt-get install dkms
	wget -qO - https://packagecloud.io/shiftkey/desktop/gpgkey | sudo apt-key add -
	sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/shiftkey/desktop/any/ any main" > /etc/apt/sources.list.d/packagecloud-shiftkey-desktop.list'
	sudo apt update
	sudo apt install github-desktop
	sudo snap install android-studio --classic
	sudo apt install docker.io
	sudo systemctl start docker
	sudo systemctl enable docker
	sudo apt install docker-desktop
	sudo snap install kotlin --classic
	sudo snap install dart --classic
	sudo snap install flutter --classic
	echo 'export PATH="$PATH:[FLUTTER_GIT_DIRECTORY]/bin"' >> ~/.bashrc
	source ~/.bashrc
	flutter doctor
	


	
	
else
        echo "skipped developer tools install"
fi

# --------------------------

 # ---------- FLATPAK SYSTEM  -----------

echo "INSTALL FLATPAK? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	echo "Beginning installation of developer tools..."

	# Add the Flatpak PPA
	sudo add-apt-repository -y ppa:flatpak/stable

	# Update the package list
	sudo apt update

	# Install Flatpak
	sudo apt install -y flatpak

	# Add Flathub repository if it doesn't exist
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	# Update Flatpak packages
	flatpak update -y

	# Add KDE applications repository if it doesn't exist
	flatpak remote-add --if-not-exists kdeapps https://distribute.kde.org/kdeapps.flatpakrepo

	# Update Flatpak packages again
	flatpak update -y

	echo "Flatpak installation and setup complete."

else
        echo "skipped flatpak install"
fi

# --------------------------



 
# ---------- FLATPAK SOFT  -----------

echo "INSTALL SOFT FROM FLATPAK? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		flatpak install fsearch
		flatpak install --user org.apache.netbeans
else
        echo "skipped flatpak soft install"
fi
# --------------------------


 ------------------------
 

# ---------- SNAP -----------

echo "INSTALL SNAPD ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		
		 
		
		
		# Check if the script is run as root
		
		if [ "$EUID" -ne 0 ]; then
		    echo "Please run as root or use sudo"
		    exit 1
		fi

		# Update package list
		echo "Updating package list..."
		sudo apt update

		# Install snapd
		echo "Installing snapd..."
		sudo apt install -y snapd

		# Start and enable snapd.socket
		echo "Starting and enabling snapd.socket..."
		sudo systemctl start snapd.socket
		sudo systemctl enable snapd.socket

		# Install core and snap-store
		echo "Installing core and snap-store..."
		sudo snap install core
		sudo snap install snap-store

		echo "Snap installation completed successfully!"



else
        echo "skipped snap install"
fi
# --------------------------
 

# ---------- VIDEO  -----------

	echo "INSTALL VIDEO PLAYER ? [Y/N]?"
	echo "Confirm [Y,n]"
	read input
	if [[ $input == "Y" || $input == "y" ]]; then
			
		 # Update package list
		sudo apt update

		# Install VLC Media Player
		sudo add-apt-repository ppa:savoury1/vlc3 -y
		sudo apt update
		sudo apt install vlc -y

		# Install Haruna Video Player (via Flatpak)
		sudo apt install flatpak -y
		flatpak install flathub org.kde.haruna -y

		# Install GNOME Videos (Totem)
		sudo apt install totem -y

		# Install MPV (and Celluloid as a front-end)
		sudo apt install mpv celluloid -y

		# Install SMPlayer
		sudo add-apt-repository ppa:rvm/smplayer -y
		sudo apt update
		sudo apt install smplayer -y

		# Install Dragon Player
		sudo apt install dragonplayer -y

		# Clean up
		sudo apt autoremove -y

		echo "All selected video players have been installed successfully!"


else
        echo "skipped video player install"
fi
# --------------------------
 


# ---------- PASSWORD TOOL  -----------

echo "INSTALL PASSWORD TOOL ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		

		# Update package cache
		sudo apt update

		# Install KeePassXC
		sudo add-apt-repository -y ppa:phoerious/keepassxc
		sudo apt update
		sudo apt install -y keepassxc

		# Install Bitwarden (using Snap)
		sudo snap install bitwarden

		# Install 1Password (using Snap)
		sudo snap install 1password

		echo "Installation completed!"

else
        echo "skipped password tool install"
fi
# --------------------------

 






 
# ---------- WINE  -----------

echo "INSTALL WINE ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		

		 echo "Installing wine"

		sudo apt-get install -y cabextract

		sudo apt -y install wine

		wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
		chmod +x winetricks

		wineboot -u
		wget https://dl.winehq.org/wine/wine-mono/7.0.0/wine-mono-7.0.0-x86.tar.xz
		tar xvf wine-mono-7.0.0-x86.tar.xz

		wget https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86.msi
		wine msiexec /i wine-gecko-2.47.1-x86.msi
		./winetricks

		 chown -R $USER:$USER /home/$USER/.wine

		export WINEARCH=win32
		export WINEDEBUG=-all
		export WINEPREFIX=/home/$USER/.wine

		./wt-install-all.sh

else
        echo "skipped wine install"
fi
# --------------------------


# ---------- DE ---------


echo "INSTALL DE additional software ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

		 # Update package list
		sudo apt update

		# Install ffmpegthumbs for video thumbnail generation
		sudo apt install -y ffmpegthumbs

		# Install two popular file managers
		sudo apt install -y nemo thunar

		# Install clipboard manager
		sudo apt install -y clipman

		# Install file roller for compression and decompression
		sudo apt install -y file-roller

		# Install VeraCrypt for file encryption
		sudo apt install -y veracrypt

		# Install PeaZip for additional file compression needs
		sudo apt install -y peazip

		# Confirm installation
		echo "Installation of tools completed."

else
        echo "skipped DE addons install"
fi



# ---------- MESSENGERS -----------

echo "INSTALL MESSENGERS? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
	echo "begin install MESSENGERS"

	# Install Telegram-Desktop
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 94558F59
	sudo add-apt-repository ppa:atareao/telegram
	sudo apt-get update
	sudo apt-get install telegram-desktop -y

	# Install Viber
	wget https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb
	sudo dpkg -i viber.deb
	sudo apt-get install -f -y

	# Install WhatsApp for Linux
	sudo apt install -y git
	git clone https://github.com/adiwajshing/Baileys.git
	cd Baileys
	npm install
	npm start

	# Install Element Desktop
	sudo apt install -y wget apt-transport-https
	wget -qO - https://packages.riot.im/debian/element.asc | sudo apt-key add -
	echo 'deb https://packages.riot.im/debian/ default main' | sudo tee /etc/apt/sources.list.d/element.list
	sudo apt update
	sudo apt install element-desktop -y

	# Install Discord
	wget -O discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
	sudo dpkg -i discord.deb
	sudo apt-get install -f -y

	echo "end install MESSENGERS"

else
        echo "skipped MESSENGERS install"
fi

# --------------------------


# OPTIMIZATIONS


# ---------- ANANICY  -----------
cd ~
echo "INSTALL ANANICY ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		

	echo "Installing ananicy"
	git clone https://github.com/Nefelim4ag/Ananicy.git /tmp/ananicy
	cd /tmp/ananicy
	sudo make install
	sudo systemctl enable ananicy
	sudo systemctl start ananicy

else
        echo "skipped ananicy install"
fi
cd -


# ----------- RNG ---------------



cd ~
echo "ENABLE RNG (CHOOSE N IF INSTALL ANANICY) ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then
		

		echo "Installing RNG"
		sudo apt update
		sudo apt install rng-tools
		sudo systemctl start rngd
		sudo systemctl enable rngd


               



else
        echo "skipped RNG install"
fi
cd -


# ---------- HAVEGED  -----------
cd ~
echo "INSTALL HAVEGED ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

		sudo apt update
		sudo apt-get install haveged                          
		sudo systemctl start haved
		sudo systemctl enable haved


else
        echo "skipped wine install"
fi
cd -
# --------------------------


# ---------- TRIM FOR SSD -----------
cd ~
echo "ENABLE TRIM FOR SSD ? [Y/N]?"
echo "Confirm [Y,n]"
read input
if [[ $input == "Y" || $input == "y" ]]; then

	# Check if SSD supports TRIM
	sudo hdparm -I /dev/sda | grep "TRIM supported"

	# Install fstrim
	sudo apt install util-linux

	# Enable fstrim.timer service
	sudo systemctl enable fstrim.timer
	sudo systemctl start fstrim.timer


	# Verify timer is enabled
	sudo systemctl list-timers --all

	sudo systemctl enable fstrim.timer                 
	sudo fstrim -v /                                    
	sudo fstrim -va  / 

else
        echo "skipped trim switching"
fi
cd -
# -----------------------

	# keyboard switch
 

	# Set the X11 keymap for switching between US and Russian layouts
	localectl set-x11-keymap --no-convert us,ru pc105 "" grp:alt_shift_toggle

	# Set GNOME keybindings for switching input sources
	gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L']"
	gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Alt>Shift_L']"

	# Optional: Print a message indicating the script has completed
	echo "Keyboard layout and keybindings have been set successfully."
	
	
	sudo apt install onboard
	sudo apt install florence
