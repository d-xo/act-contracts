let
  sources = import ./nix/sources.nix;
  dapptools = import (sources.dapptools) {};
  act = import (sources.act) {};
in dapptools.mkShell {
  buildInputs = [
    dapptools.dapp
    act.act
    dapptools.solc-static-versions.solc_0_8_3
  ];
  DAPP_SOLC="solc-0.8.3";
}
