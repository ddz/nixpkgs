{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage {
  pname = "gridlock";
  version = "unstable-2023-08-29";

  outputs = [
    "out"
    "nyarr"
  ];

  src = fetchFromGitHub {
    owner = "lf-";
    repo = "gridlock";
    rev = "a98abfa554e5f8e2b7242662c0c714b7f1d7ec29";
    hash = "sha256-I4NGfgNX79ZhWXDeUDJyDzP2GxcNhHhazVmmmPlz5js=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-CflDi1sjPBX+FOj74DWYKcg0O8Q7bnCFhzEnCrRi0g8=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.Security
    ];

  postInstall = ''
    moveToOutput bin/nyarr $nyarr
  '';

  meta = with lib; {
    description = "Nix compatible lockfile manager, without Nix";
    homepage = "https://github.com/lf-/gridlock";
    license = licenses.mit;
    maintainers = with maintainers; [ figsoda ];
  };
}
