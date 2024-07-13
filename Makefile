install:
	for file in `ls install-scripts`; do \
		bash install-scripts/$$file; \
	done

.PHONY: install