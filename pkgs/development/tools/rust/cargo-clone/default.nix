{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  zlib,
  stdenv,
  CoreServices,
  Security,
  SystemConfiguration,
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-clone";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "janlikar";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-kK0J1Vfx1T17CgZ3DV9kQbAUxk4lEfje5p6QvdBS5VQ=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-IbNwlVKGsi70G+ATimRZbHbW91vFddQl//dfAM6JO8I=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    [
      openssl
      zlib
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      CoreServices
      Security
      SystemConfiguration
    ];

  # requires internet access
  doCheck = false;

  meta = with lib; {
    description = "Cargo subcommand to fetch the source code of a Rust crate";
    mainProgram = "cargo-clone";
    homepage = "https://github.com/janlikar/cargo-clone";
    changelog = "https://github.com/janlikar/cargo-clone/blob/v${version}/CHANGELOG.md";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [
      figsoda
      matthiasbeyer
      janlikar
    ];
  };
}
