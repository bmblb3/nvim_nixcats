{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixCats,
      ...
    }@inputs:
    let
      inherit (nixCats) utils;
      luaPath = ./.;
      forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
      extra_pkg_config = { };
      dependencyOverlays = [ (utils.standardPluginOverlay inputs) ];
      categoryDefinitions =
        {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        }:
        {
          lspsAndRuntimeDeps = {
            general = with pkgs; [
              universal-ctags
              ripgrep
              fd
              bash-language-server
              docker-language-server
              jinja-lsp
              lua-language-server
              nil
              superhtml
              tailwindcss-language-server
              typescript-language-server
              yaml-language-server
              stylua
              prettierd
              djlint
              shfmt
              shellharden
              google-java-format
              nixfmt-rfc-style
              typstyle
            ];
          };
          startupPlugins = {
            general = with pkgs.vimPlugins; [
              which-key-nvim
              lualine-nvim
              nvim-treesitter.withAllGrammars
              nvim-web-devicons
              mini-icons
              snacks-nvim
              nvim-lspconfig
              persistence-nvim
              copilot-lua
              blink-cmp
              blink-copilot
              blink-ripgrep-nvim
              CopilotChat-nvim
              conform-nvim
              flash-nvim
              gitsigns-nvim
            ];
          };
          # optionalPlugins = { };
          # sharedLibraries = { };
          # environmentVariables = { };
          # extraWrapperArgs = { };
          # python3.libraries = { };
          # extraLuaPackages = { };
        };
      packageDefinitions = {
        nvim =
          { pkgs, name, ... }:
          {
            settings = {
              suffix-path = true;
              suffix-LD = true;
              aliases = [
                "vi"
                "vim"
              ];
              wrapRc = true;
              # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
            };
            categories = {
              general = true;
            };
          };
      };
      defaultPackageName = "nvim";
    in
    forEachSystem (
      system:
      let
        nixCatsBuilder = utils.baseBuilder luaPath {
          inherit
            nixpkgs
            system
            dependencyOverlays
            extra_pkg_config
            ;
        } categoryDefinitions packageDefinitions;
        defaultPackage = nixCatsBuilder defaultPackageName;
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = utils.mkAllWithDefault defaultPackage;
        devShells = {
          default = pkgs.mkShell {
            name = defaultPackageName;
            packages = [ defaultPackage ];
            inputsFrom = [ ];
            shellHook = "";
          };
        };
      }
    )
    // (
      let
        nixosModule = utils.mkNixosModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
        homeModule = utils.mkHomeModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
      in
      {
        overlays = utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        } categoryDefinitions packageDefinitions defaultPackageName;
        nixosModules.default = nixosModule;
        homeModules.default = homeModule;
        inherit utils nixosModule homeModule;
        inherit (utils) templates;
      }
    );
}
