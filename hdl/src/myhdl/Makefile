COMPONENS = $(wildcard test_*.py)
PYTHON = python

test_%.vcd: test_%.py component_%.py
	$(PYTHON) $<
	rm $@.*.*

