## macOS quick-and-dirty builds

**Attention!**

This are just some quick lines of code slapped together to build gimp-2.10.12 while waiting for official DMGs from core GIMP team.
I do not have extensive knowledge about the code and (unfortunately) am not affiliated with GIMP or GNOME projects in any way.
Use the scripts at your own risk and so on; I've tried to make them usable by someone except myself, though not very hard.

**Thanks for attention**

### Prerequisites

* Bash 4.* (macOS proudly features shell which, clocking at over a decade, won't run the scripts).
* Homebrew.
* Courage & stupidity (optional).

### Building

In theory, `./build/macos/prepare.sh && ./build/macos/build.sh` should happily generate a working `~/GIMP.app`, simple as that.
In practice… I didn't even try to perform clean build, but have a strong prerequisite #3. :-)
If you have some problems using the scripts, try googling the latest error message, they all are presented to the user unmodified.
For more serious problems you may try contacting me, though I promise nothing.

### Features

* Branched from tag [GIMP_2_10_12](https://github.com/GNOME/gimp/releases/tag/GIMP_2_10_12).
* Built binaries should theoretically run slightly faster than official ones. Buzzwords: `-march=native`, `-flto`.
* On the other hand, I've forced app to build & run using latest BABL available on Homebrew, not the one suggested by `configure.ac` and `app/sanity.c` (`0.1.64` vs `0.1.66`).
  I genuinely don't know what kind of problems this decision would cause; no obvious crashes or other unexpected behavior is observed though.
* The build is most certainly non-portable, so no DMGs here. Only Gentoo-style, only Scott Manley mode! :-)
