{ config, pkgs, ...}:

{

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  virtualisation.docker.enable = true;

  users.users.simaolavos.extraGroups = [ "docker" ];


  programs.firefox.enable = true;



  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu = {
        runAsRoot = false;
      };
    };
  };

  programs.nix-ld.enable = true;


  environment.systemPackages = with pkgs; [
    fastfetch
    tmux
    wakeonlan
    spotify
    neovim
    alacritty
    tealdeer
    dropbox
    docker
    virt-manager
    cargo
    steam
    claude-code
    vscode
  ];
}
