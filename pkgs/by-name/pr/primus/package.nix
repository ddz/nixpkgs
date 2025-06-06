# For a 64bit + 32bit system the LD_LIBRARY_PATH must contain both the 32bit and 64bit primus
# libraries. Providing a different primusrun for each architecture will not work as expected. EG:
# Using steam under wine can involve both 32bit and 64bit process. All of which inherit the
# same LD_LIBRARY_PATH.
# Other distributions do the same.
{
  stdenv,
  pkgsi686Linux,
  lib,
  primusLib,
  writeScriptBin,
  runtimeShell,
  primusLib_i686 ?
    if stdenv.hostPlatform.system == "x86_64-linux" then pkgsi686Linux.primusLib else null,
  useNvidia ? true,
}:

let
  # We override stdenv in case we need different ABI for libGL
  primusLib_ = primusLib.override { inherit stdenv; };
  primusLib_i686_ = primusLib_i686.override { stdenv = pkgsi686Linux.stdenv; };

  primus = if useNvidia then primusLib_ else primusLib_.override { nvidia_x11 = null; };
  primus_i686 =
    if useNvidia then primusLib_i686_ else primusLib_i686_.override { nvidia_x11 = null; };
  ldPath = lib.makeLibraryPath (
    lib.filter (x: x != null) (
      [
        primus
        primus.glvnd
      ]
      ++ lib.optionals (primusLib_i686 != null) [
        primus_i686
        primus_i686.glvnd
      ]
    )
  );

in
writeScriptBin "primusrun" ''
  #!${runtimeShell}
  export LD_LIBRARY_PATH=${ldPath}''${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH
  # https://bugs.launchpad.net/ubuntu/+source/bumblebee/+bug/1758243
  export __GLVND_DISALLOW_PATCHING=1
  exec "$@"
''
