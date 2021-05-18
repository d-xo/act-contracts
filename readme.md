# act-contracts

This repo contains some simple solidity contracts along with formal specifications written in
[`act`](https://github.com/ethereum/act) for each of these contracts. Many of the act specs
represent "concept art" for future language features, and so may not be provable using the current
version of the act tool.

## Development

To enter a shell with all required dependencies [install nix](https://nixos.org/guides/install-nix.html) and then run `nix-shell` from the repo root.

```sh
make build # build smart contracts
make prove # verify the spec against itself (invariants/postconditions) and against the contract
make clean # clean build output
```
