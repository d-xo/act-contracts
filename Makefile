.PHONY: all test clean prove

specs=$(wildcard src/*.act.md)

build :; dapp build
prove :  $(specs:=.prove)
clean :
	dapp clean
	rm -rf .make

src/%.prove:
	@mkdir -p .make
	@sed -n '/^```act/,/^```/ p' < "src/$*" | sed '/^```act/ d' | sed '/^```/ d' > .make/$*.act
	act prove --file .make/$*.act
	act hevm  --spec .make/$*.act --soljson out/dapp.sol.json

