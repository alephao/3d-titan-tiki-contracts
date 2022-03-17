SHELL := /bin/bash

.PHONY: snapshot
snapshot:
	forge snapshot --force --optimize --match-contract "BenchmarkTest$$"

.PHONY: 
test:
	forge t --force --optimize --match-contract "UnitTest$$|E2ETest$$"

.PHONY: codegen
codegen:
	python scripts/errorsig.py ./src/TitanTiki3D.sol
	python scripts/solcery/main.py errgen ./src/test/utils/Errors.sol ./src/TitanTiki3D.sol

.PHONY: slither
slither:
	slither src/TitanTiki3D.sol --config-file slither.config.json

.PHONY: deploy
deploy:
	npm run deploy

.PHONY: lint
lint:
	npm run prettier:check && npm run solhint:check

.PHONY: format
format:
	npm run prettier