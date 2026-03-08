#!/bin/bash
set -x

if [[ $RUNNER_OS != 'Linux' ]]; then
    brew update --verbose
    # brew update > brew-update.log 2>&1
    # fix an issue with libtool on travis by reinstalling it
    brew uninstall libtool;
    brew install automake libtool dejagnu gcc@15;

    # Download and extract the rlgl client
    wget -qO - https://github.com/bobo215/red-light-green-light/releases/download/v0.1.0/rlgl-darwin-amd64.tgz | \
	      tar --strip-components=1 -xvzf - ./rlgl;

else
    # Determine the rlgl archive for this architecture
    case $(uname -m) in
        x86_64)  RLGL_ARCH=linux-amd64 ;;
        aarch64) RLGL_ARCH=linux-arm ;;
        ppc64le) RLGL_ARCH=linux-ppc64le ;;
        s390x)   RLGL_ARCH=linux-s390x ;;
        *)       RLGL_ARCH=linux-amd64 ;;
    esac

    # Download and extract the rlgl client
    wget -qO - https://github.com/bobo215/red-light-green-light/releases/download/v0.1.0/rlgl-${RLGL_ARCH}.tgz | \
	      tar --strip-components=1 -xvzf - ./rlgl;

    sudo apt-get clean # clear the cache
    sudo apt-get update
    sudo apt install libltdl-dev zip

    case $HOST in
	      mips64el-linux-gnu | sparc64-linux-gnu)
        ;;
	      alpha-linux-gnu | arm32v7-linux-gnu | m68k-linux-gnu | sh4-linux-gnu)
	          sudo apt-get install qemu-user-static
	          ;;
	      hppa-linux-gnu )
	          sudo apt-get install -y qemu-user-static g++-5-hppa-linux-gnu
	          ;;
	      i386-pc-linux-gnu)
	          sudo apt-get install gcc-multilib g++-multilib;
	          ;;
	      moxie-elf)
	          echo 'deb [trusted=yes] https://repos.moxielogic.org:7114/MoxieLogic moxiedev main' | sudo tee -a /etc/apt/sources.list
	          sudo apt-get clean # clear the cache
	          sudo apt-get update ## -qq
	          sudo apt-get update
	          sudo apt-get install -y --allow-unauthenticated moxielogic-moxie-elf-gcc moxielogic-moxie-elf-gcc-c++ moxielogic-moxie-elf-gcc-libstdc++ moxielogic-moxie-elf-gdb-sim texinfo sharutils texlive dejagnu
	          ;;
	      x86_64-w64-mingw32)
	          sudo apt-get install gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 wine;
	          ;;
	      i686-w32-mingw32)
	          sudo apt-get install gcc-mingw-w64-i686 g++-mingw-w64-i686 wine;
	          ;;
    esac
    case $HOST in
	      arm32v7-linux-gnu)
        # don't install host tools
        ;;
	      *)
	          sudo apt-get install dejagnu texinfo sharutils
	          ;;
    esac
fi
