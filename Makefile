.PHONY: clean

default: calc

clean:
	rm -rfv MAlonzo/
	rm -v Calc

calc:
	agda -c Calc.agda

Calc: calc