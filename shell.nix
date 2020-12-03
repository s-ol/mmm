{ pkgs ? import <nixpkgs> {}
}:

let
  # see https://github.com/mpx/lua-cjson/issues/56
  cjson = pkgs.lua53Packages.buildLuarocksPackage rec {
    pname = "lua-cjson";
    version = "2.1.0-1";

    src = pkgs.fetchurl {
      url    = "mirror://luarocks//lua-cjson-2.1.0-1.src.rock";
      sha256 = "23r4ScVV0aR09yn+Sla1Uw6b57JHSet6fEdKfHIHuXI=";
    };
    propagatedBuildInputs = [ pkgs.lua5_3 ];

    meta = with pkgs.stdenv.lib; {
      homepage = "https://www.kyne.com.au/~mark/software/lua-cjson.php";
      description = "A fast JSON encoding/parsing module";
      license.fullName = "MIT";
    };
  };

  discount = pkgs.lua53Packages.buildLuarocksPackage {
    pname = "discount";
    version = "0.4-1";

    knownRockspec = (pkgs.fetchurl {
      url    = https://luarocks.org/discount-0.4-1.rockspec;
      sha256 = "0mc2mwkprf8li2v91vga77rwi0xhv989nxshi66z2d45lbl1dcpd";
    }).outPath;

    src = pkgs.fetchurl {
      url    = https://craigbarnes.gitlab.io/dist/lua-discount/lua-discount-0.4.tar.gz;
      sha256 = "1bfyrxjr26gbahawdynlbp48ma01gyd3b6xbljvxb2aavvfywc9m";
    };

    buildInputs = [ pkgs.discount ];
    propagatedBuildInputs = [ pkgs.lua5_3 ];

    meta = with pkgs.stdenv.lib; {
      homepage = "https://github.com/craigbarnes/lua-discount";
      description = "Lua bindings for the Discount Markdown library";
      license.fullName = "ISC";
    };
  };

in pkgs.mkShell {
  name = "mmm-env";
  buildInputs = with pkgs; [
    tup sassc entr
    (lua5_3.withPackages (p: with p; [ moonscript http cjson discount busted ]))
  ];
  shellHook = ''
    runServer () {
      find build mmm -name '*.moon' | entr -dr moon build/server.moon "$@"
    }
    echo -e "\e[90m# run hot-reload server: \e[31mrunServer …\e[0m"
  '';
  LUA_PATH = "?.lua;?/init.lua";
}
