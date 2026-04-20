DRONES_DIR = $(shell git config "borg.drones-directory" || echo "lib")

-include $(DRONES_DIR)/borg/borg.mk

bootstrap-borg:
	@git submodule--helper clone --name borg --path $(DRONES_DIR)/borg --url git@github.com:emacscollective/borg.git
	@cd $(DRONES_DIR)/borg; git symbolic-ref HEAD refs/heads/main
	@cd $(DRONES_DIR)/borg; git reset --hard HEAD

## Fast (rebuild only drones whose submodule hash changed)

HASH_FILE := var/borg-build-hashes

.PHONY: fast fast-native

fast:        FAST_TARGET := build
fast-native: FAST_TARGET := native

fast fast-native:
	@mkdir -p $(dir $(HASH_FILE)) && touch $(HASH_FILE)
	@git submodule status | sed 's/^[-+U ]//' | awk '{print $$1"\t"$$2}' > $(HASH_FILE).new
	@if [ ! -s $(HASH_FILE) ]; then \
	  changed=$$(awk '{print $$2}' $(HASH_FILE).new); \
	else \
	  changed=$$(awk 'NR==FNR {old[$$2]=$$1; next} old[$$2]!=$$1 {print $$2}' \
	                $(HASH_FILE) $(HASH_FILE).new); \
	fi; \
	if [ -z "$$changed" ]; then \
	  printf "No drones changed.\n"; \
	  rm -f $(HASH_FILE).new; \
	  exit 0; \
	fi; \
	printf "Changed drones:\n"; \
	for p in $$changed; do printf "  - %s\n" "$$(basename $$p)"; done; \
	for p in $$changed; do \
	  $(MAKE) $(FAST_TARGET)/$$(basename $$p) || { rm -f $(HASH_FILE).new; exit 1; }; \
	done; \
	mv $(HASH_FILE).new $(HASH_FILE)
