.PHONY: clean

default: calc

clean: clean-agda clean-typescript

clean-agda:
	rm -rfv agda/MAlonzo/
	rm -v agda/Calc

clean-typescript:
	rm -rfv typescript/node_modules
	rm -rfv typescript/out

build-agda:
	agda -c Calc.agda

build-typescript:
	( \
		cd typescript; \
		$$(npm bin)/tsc \
	)

Calc: build-agda

typescript/out/index.js: build-typescript