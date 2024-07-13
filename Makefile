install:
	for file in `ls install-scripts`; do \
		./install-scripts/$$file; \
	done

.PHONY: install