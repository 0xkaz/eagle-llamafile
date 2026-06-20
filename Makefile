.PHONY: help lint test convert clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

lint: ## Lint shell scripts with shellcheck (falls back to bash -n)
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck scripts/convert.sh; \
	else \
		echo "shellcheck not found; running bash -n syntax check"; \
		bash -n scripts/convert.sh; \
	fi

test: lint ## Run all repository validation tests
	@bash tests/test_all.sh

convert: ## Build a llamafile (pass ARGS="<hf_model_id> <output_name> [quant]")
	@./scripts/convert.sh $(ARGS)

clean: ## Remove temporary work directory
	@rm -rf work/
