.PHONY: all test clean prove

specs=$(wildcard src/*.act.md)

all   :; dapp build
test  :; dapp test
prove :  $(specs:=.prove)
clean :
	dapp clean
	rm -rf .make
src/%.prove:
	@mkdir -p .make
	@sed -n '/^```act/,/^```/ p' < "src/$*" | sed '/^```act/ d' | sed '/^```/ d' > .make/$*.act
	act prove --file .make/$*.act

