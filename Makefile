# VARIABLES
TOOLS_BIN := tools/vendor/bin

# TARGETS
.PHONY: help test ecs-dry ecs-fix init install-tools vendor

.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test: ## runs phpunit
	composer dump-autoload
	php -d pcov.enabled=1 -d pcov.directory=./src ../../../vendor/bin/phpunit \
       --configuration phpunit.xml.dist \
       --coverage-clover build/artifacts/phpunit.clover.xml \
       --coverage-html build/artifacts/phpunit-coverage-html

ecs-dry: | install-tools vendor  ## runs easy coding standard in dry mode
	$(TOOLS_BIN)/ecs check .

ecs-fix: | install-tools vendor  ## runs easy coding standard and fixes issues
	$(TOOLS_BIN)/ecs check . --fix

init: ## activates the plugin and dumps test-db
	- cd ../../../ \
		&& ./psh.phar init \
		&& php bin/console plugin:install --activate PlanetExpress \
		&& ./psh.phar init-test-databases \
		&& ./psh.phar e2e:dump-db \
		&& ./psh.phar cache

install-tools: | $(TOOLS_BIN) ## Installs connect dev tooling

$(TOOLS_BIN):
	composer install -d tools

vendor:
	composer install --no-interaction --optimize-autoloader --no-suggest --no-scripts --no-progress
