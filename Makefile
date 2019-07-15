PROJECT = curator-lambda-aws-es
VIRTUAL_ENV = venv
FUNCTION_NAME = curator
AWS_REGION = eu-west-2
FUNCTION_HANDLER = lambda_handler
LAMBDA_ROLE = <your lambda arn role>
LAMBDA_RUNTIME = python3.7
LAMBDA_TIMEOUT = 60
LAMBDA_MEMORY_SIZE = 128

# Default commands
install: clean_package build_package_tmp copy_lambda docker_install_libs zip
deploy: lambda_update

docker_install_libs:
	pip install --no-cache-dir --target ./package/tmp/ -r requirements.txt

clean_package:
	rm -rf ./package/*

build_package_tmp:
	mkdir -p ./package/tmp/lib

copy_lambda:
	cp -a ./function/*.py ./package/tmp

zip:
	cd ./package/tmp && zip -r ../../$(PROJECT).zip .

lambda_delete:
	aws lambda delete-function \
		--function_name $(FUNCTION_NAME)

lambda_update:
	aws lambda update-function-code \
		--region $(AWS_REGION) \
		--function-name $(FUNCTION_NAME) \
		--zip-file fileb://$(PROJECT).zip \
		--publish

lambda_update_dry:
	aws lambda update-function-code \
		--region $(AWS_REGION) \
		--function-name $(FUNCTION_NAME) \
		--zip-file fileb://$(PROJECT).zip \
		--dry-run

lambda_create:
	aws lambda create-function \
		--region $(AWS_REGION) \
		--function-name $(FUNCTION_NAME) \
		--zip-file fileb://$(PROJECT).zip \
		--role $(LAMBDA_ROLE) \
		--handler $(PROJECT).$(FUNCTION_HANDLER) \
		--runtime $(LAMBDA_RUNTIME) \
		--timeout $(LAMBDA_TIMEOUT) \
		--memory-size $(LAMBDA_MEMORY_SIZE)