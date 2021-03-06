{ lib, mkDerivation, fetchgit, qtbase, cmake, asciidoc, docbook_xsl, json_c, mesa_glu, freeglut, trace-cmd, pkg-config }:
mkDerivation rec {
  pname = "kernelshark";
  version = "1.2";

  src = fetchgit {
    url    = "git://git.kernel.org/pub/scm/utils/trace-cmd/trace-cmd.git/";
    rev    = "kernelshark-v${version}";
    sha256 = "0wzzm2imk9n94v96v6sbvbff6j47lz4qj0snhiyv3nj3slg0anvh";
  };

  patches = [ ./fix-Makefiles.patch ];

  outputs = [ "out" "doc" ];

  preConfigure = "pushd kernel-shark";

  nativeBuildInputs = [ pkg-config cmake asciidoc ];

  buildInputs = [ qtbase json_c mesa_glu freeglut ];

  cmakeFlags = [
    "-D_INSTALL_PREFIX=${placeholder "out"}"
    "-DTRACECMD_BIN_DIR=${trace-cmd}/bin"
    "-DTRACECMD_INCLUDE_DIR=${trace-cmd.dev}/include"
    "-DTRACECMD_LIBRARY=${trace-cmd.lib}/lib/trace-cmd/libtracecmd.a"
    "-DTRACEEVENT_LIBRARY=${trace-cmd.lib}/lib/traceevent/libtraceevent.a"
    "-DTRACEFS_LIBRARY=${trace-cmd.lib}/lib/tracefs/libtracefs.a"
  ];

  preInstall = ''
    popd
    make install_doc_gui prefix=$doc \
      FIND_MANPAGE_DOCBOOK_XSL=${docbook_xsl}/share/xml/docbook-xsl-nons/manpages/docbook.xsl
    pushd kernel-shark/build
  '';

  meta = with lib; {
    description = "GUI for trace-cmd which is an interface for the Linux kernel ftrace subsystem";
    homepage    = "https://kernelshark.org/";
    license     = licenses.gpl2;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ basvandijk ];
  };
}
