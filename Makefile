.PHONY: clean

default: calc

clean:
	rm -rfv MAlonzo/
	rm -v calc

calc:
	agda -c Calc.agda