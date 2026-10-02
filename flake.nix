{
  description = "Unity Asset Bundle Extractor Avalonia (UABEA)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            permittedInsecurePackages = [
              "dotnet-runtime-6.0.36"
            ];
          };
        };

        dotnetRuntime = pkgs.dotnetCorePackages.runtime_6_0;

        runlib = with pkgs; [
          stdenv.cc.cc.lib
          zlib
          openssl
          icu
          libx11
          libxcursor
          libxext
          libxrandr
          libxi
          libice
          libsm
          fontconfig
          freetype
          glib
          libGL
        ];

        desktopItem = pkgs.makeDesktopItem {
          name = "Uabea";
          exec = "UABEAvalonia";
          icon = "uabea";
          comment = "Unity Asset Bundle Extractor Avalonia";
          desktopName = "UABEA";
          genericName = "Unity Asset Bundle Editor";
          categories = [ "Development" "Utility" ];
        };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "uabea-bin";
          version = "8";

          src = pkgs.fetchurl {
            url = "https://github.com/nesrak1/UABEA/releases/download/v${version}/uabea-ubuntu.zip";
            hash = "sha256-xULdO1sJGzRkXuHHGA33E4+fP+UlMiLxUdcYXlQkArI=";
          };

          nativeBuildInputs = with pkgs; [
            unzip
            autoPatchelfHook
            makeWrapper
            copyDesktopItems
          ];

          buildInputs = runlib ++ [ dotnetRuntime ];

          desktopItems = [ desktopItem ];

          sourceRoot = ".";

          installPhase = ''
            runHook preInstall

            mkdir -p $out/share/uabea $out/bin
            cp -r * $out/share/uabea/

            makeWrapper ${dotnetRuntime}/bin/dotnet $out/bin/UABEAvalonia \
              --add-flags "$out/share/uabea/UABEAvalonia.dll" \
              --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath runlib}"

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Unity Asset Bundle and Serialized File Editor";
            homepage = "https://github.com/nesrak1/UABEA";
            license = licenses.mit;
            platforms = [ "x86_64-linux" ];
            mainProgram = "UABEAvalonia";
          };
        };
      }
    );
}