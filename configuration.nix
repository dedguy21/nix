## Air's NixOs config for Dell G5 SE (All AMD Laptop)

{ config, pkgs, ... }:

# Inlcude the results of the hardware scan
{
  imports =
    [
      ./hardware-configuration.nix
    ];

## This section covers boot and console configs
## Boot with Linux-Zen instead of default did work during install uncomment after install 
   boot.kernelPackages = pkgs.linuxPackages_zen;

## boot amd gpu early
   boot.initrd.kernelModules = [ "amdgpu" ]; 

#nix flakes enabled
  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };


## make sure these modules are included during boot times
   boot.extraModulePackages = with config.boot.kernelPackages; [
#      zenpower ## to accurately AMD's znver(2) cpu
#     perf
#     evdi
#     virtualbox
      acpi_call
#     exfat-nofuse	
   ];

## Use the grub EFI boot loader.
  boot.loader = {
	efi = {
		canTouchEfiVariables = true;
		efiSysMountPoint = "/boot/efi";
		};
	grub = {
		enable = true;
		version = 2;
		efiSupport = true;
		device = "nodev";
		configurationLimit = 15;
		};
	timeout = 0;
	};
	 
  
## pass kernel parameters
    boot.kernelParams = ["rootflags=rw,ssd,space_cache=v2,autodefrag,noatime,nodiratime,commit=120,compress=zstd:1,subvol=nixos/@" "fsck.mode=skip" "quiet" "splash" "vga=current" "vt.global_cursor_default=0" "loglevel=1" "rd.systemd.show_status=false" "rd.udev.log-priority=1" "udev.log_priority=3" "sysrq_always_enabled=1" "cryptomgr.notests" "initcall_debug" "no_timer_check" "noreplace-smp" "page_alloc.shuffle=1" "rcupdate.rcu_expedited=1" "rootfstype=btrfs" "tsc=reliable" "nowatchdog" "nmi_watchdog=0" "acpi_backlight=vendor" "acpi_osi=Linux" "amdgup.runpm=0" "video=DP-4:1920x1080@120" ];

## silent boot paramenter
   boot.consoleLogLevel = 0;
   boot.initrd.verbose = false;
     
# Fonts
  fonts.fonts = with pkgs; [
  	nerdfonts
##	google-fonts
	font-awesome
##	hermit
	vistafonts
	courier-prime
	#console font below
	terminus_font
	cascadia-code
	tamsyn
	gohufont
	dina-font
	cozette
	spleen
	unifont
	unifont_upper	
	];

## Select internationalisation properties for console font.
   i18n.defaultLocale = "en_US.UTF-8";
   console = {
     earlySetup = true;
     font = "${pkgs.terminus_font}/share/consolefonts/ter-v28b.psf.gz";
     packages = with pkgs; [ terminus_font ];
     keyMap = "us";
     colors = [ 
"151515" # i have to comment the colors and base16 number (0-15)
"ea8ec0" # i have to comment the colors and base16 number (0-15)
"9bb156" # i have to comment the colors and base16 number (0-15)
"cca15e" # i have to comment the colors and base16 number (0-15)
"5eb1de" # i have to comment the colors and base16 number (0-15)
"d092dd" # i have to comment the colors and base16 number (0-15)
"01beb0" # i have to comment the colors and base16 number (0-15)
"d0d0d0" # i have to comment the colors and base16 number (0-15)
"505050" # i have to comment the colors and base16 number (0-15)
"fb9fb1" # i have to comment the colors and base16 number (0-15)
"acc267" # i have to comment the colors and base16 number (0-15)
"ddb26f" # i have to comment the colors and base16 number (0-15)
"6fc2ef" # i have to comment the colors and base16 number (0-15)
"e1a3ee" # i have to comment the colors and base16 number (0-15)
"12cfc0" # i have to comment the colors and base16 number (0-15)
"f5f5f5" # i have to comment the colors and base16 number (0-15)
	];
   };

## network name 
   networking.hostName = "dedman"; # Define your hostname.
   networking.networkmanager.enable = true;

## Set your time zone.
   time.timeZone = "America/Los_Angeles";

## I think all the below processes occur after boot

## Enable CUPS to print documents.
   services.printing.enable = true;
## Enable bluetooth
   hardware.bluetooth.enable = true;
   services.blueman.enable = true;

## Enable sound.
   sound.enable = true;
  #hardware.pulseaudio = {
  #	enable = true;
  #	extraModules = [ pkgs.pulseaudio-modules-bt];
  #	package = pkgs.pulseaudioFull;
  #};

## Enable AMD Hardware Accel
	hardware.opengl.extraPackages = with pkgs; [
  	rocm-opencl-icd
   	rocm-opencl-runtime
	pkgs.amdvlk
	];
	environment.variables.AMD_VULKAN_ICD = "RADV";
	hardware.opengl.driSupport = true;
	# For 32 bit applications use below
	hardware.opengl.driSupport32Bit = true;

## Enable touchpad support (enabled default in most desktopManager).
   services.xserver.libinput.enable = true;

## Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.air = {
     isNormalUser = true;
     initialPassword = "start123";
     extraGroups = [ "wheel" "networkmanager" "video" "autologin" ]; 
   };

## This is to have user autologin
   services.getty.autologinUser = "air";


## List packages installed in system profile. To search, run:
## $ nix search wget

## Allow unfree (non-gnu) packages to be installed   
   nixpkgs.config.allowUnfree = true;

## allow access to nix NUR - nix user repos globally, user still needs .config file to add

  nixpkgs.config.packageOverrides = pkgs: {
   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

## Below are packages from the nix repos that should be used globaly   
   environment.systemPackages = with pkgs; [ 
## below start with rust program I know I use
   lsd exa fd bat skim sd starship procs ripgrep coreutils tealdeer
 # cli monitoring and other tools
   ranger neofetch btop glances radeontop
 # git stuff
   git curl wget
 # completions
   bash-completion nix-bash-completions
 # other stuff I need to place into categories but right now, ehh
   icdiff dateutils hstr snapper efibootmgr efivar fzf fasd vivid blueman brightnessctl btrfs-progs catimg cpio crda shellharden rsync plocate pigz pavucontrol
   	];


## tmux stuff
programs.tmux = {
  enable = true;
  clock24 = true;
#extraTmuxConf = ''#tmuxPlugins.power-theme tmuxPlugins.onedark-theme tmuxPlugins.dracula 
};

#neovim as the default editor
environment.variables.EDITOR = "nvim";
## neovim config
 programs.neovim = {
    enable = true;
    viAlias = true;
    package = pkgs.neovim-unwrapped;
    # package = pkgs.neovim.overrideAttrs (oa: {
    #   buildInputs = oa.buildInputs ++ ([
    #     pkgs.unstable.tree-sitter
    #   ]);
    # });
    # package = pkgs.neovim-nightly.overrideAttrs (oa: {
    #   buildInputs = oa.buildInputs ++ ([
    #     pkgs.unstable.tree-sitter
    #   ]);
    # });
    defaultEditor = true;
    withRuby = true;
    #configure = (import ./customization.nix { pkgs = pkgs; lib = lib; inputs = inputs; });
  };

## Install sway as a globally used gui
  programs.sway = {
  enable = true;
  wrapperFeatures.gtk = true; # so that gtk works properly
  extraPackages = with pkgs; [
	swaylock-effects
	swayidle
	swaybg
	sway-contrib.grimshot
	wl-clipboard
	wf-recorder
	imv
	lxsession
	lxappearance
# 	cinnamon.nemo
	pcmanfm
	mate.engrampa
	oguri
	nur.repos.willpower3309.swayblur # have to add this after inital install
	kanshi
	firefox-wayland
	hunspell
	font-manager
	xwayland
	wlsunset
	waybar
	meld
	pavucontrol
	mako # notification daemon
	autotiling #autotiling
	kitty # kitty instead of alacritty
	rofi-wayland # wofi is wayland naitive, my Arch Config uses rofi for wayland
	yt-dlp
	oneko # cat chasing mouse cursor for cute effect
## first add gsettings
  	gsettings-desktop-schemas
	gtk-engine-murrine
	gtk-engine-bluecurve
	gtk_engines
	webkitgtk
## gtk themes
	materia-theme
	ayu-theme-gtk
	pop-gtk-theme
	spacx-gtk-theme
	paper-gtk-theme
	numix-gtk-theme
	layan-gtk-theme
	sierra-gtk-theme
	mojave-gtk-theme
	qogir-theme
	gruvbox-dark-gtk
	juno-theme
	arc-theme
	yaru-remix-theme
	orchis-theme
	whitesur-gtk-theme
	zuki-themes
## icons
	zafiro-icons
	gruvbox-dark-icons-gtk
	nixos-icons
	luna-icons
	material-icons
	material-design-icons
	whitesur-icon-theme
	papirus-icon-theme
	qogir-icon-theme
	kora-icon-theme
	la-capitaine-icon-theme
## cursors
	numix-cursor-theme
	quintom-cursor-theme
	capitaine-cursors
	xcb-util-cursor
	bibata-extra-cursors
	bibata-cursors
	xorg.xcursorthemes
	  ];
}; 
	xdg.portal.wlr.enable = true;
	services.pipewire.enable = true;
	services.gvfs.enable=true;

## Some programs need SUID wrappers, can be configured further or are
## started in user sessions.
   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

## List services that you want to enable:
## Enable the OpenSSH daemon.
   services.openssh.enable = true;
## version of NixOs  
system.stateVersion = "22.05"; # Did you read the comment?
}
