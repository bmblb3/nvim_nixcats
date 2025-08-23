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
              basedpyright
              bash-language-server
              clippy
              djlint
              docker-language-server
              fd
              google-java-format
              jinja-lsp
              lua-language-server
              nil
              nixfmt-rfc-style
              postgres-lsp
              prettierd
              ripgrep
              ruff
              rust-analyzer
              rustfmt
              shellcheck
              shellharden
              shfmt
              stylua
              superhtml
              tailwindcss-language-server
              typescript-language-server
              typstyle
              universal-ctags
              yaml-language-server
            ];
          };
          startupPlugins = {
            general = with pkgs.vimPlugins; [
              CopilotChat-nvim
              blink-cmp
              blink-copilot
              blink-ripgrep-nvim
              conform-nvim
              copilot-lua
              dial-nvim
              flash-nvim
              gitsigns-nvim
              hardtime-nvim
              lualine-nvim
              mini-icons
              mini-hipatterns
              nvim-lspconfig
              nvim-treesitter.withAllGrammars
              nvim-web-devicons
              persistence-nvim
              snacks-nvim
              vim-dirdiff
              vim-monokai-tasty
              which-key-nvim
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
              wrapRc = false;
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
