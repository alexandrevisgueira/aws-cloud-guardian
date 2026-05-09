# Makefile de Elite - Build & Deploy
.PHONY: build deploy clean

build:
	python3 scripts/package.py

deploy: build
	terraform -chdir=infrastructure plan
	terraform -chdir=infrastructure apply -auto-approve

clean:
	rm -rf infrastructure/lambda_function.zip infrastructure/.terraform