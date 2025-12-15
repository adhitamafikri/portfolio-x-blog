.PHONY: dev
dev:
	hugo server -D

.PHONY: build
build:
	chmod a+x ./scripts/build.sh && ./scripts/build.sh

.PHONY: deploy
deploy:
	npx wrangler deploy
