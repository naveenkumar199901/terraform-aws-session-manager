# https://github.com/tmknom/template-terraform-module
TERRAFORM_VERSION := 0.11.14
-include .Makefile.terraform

.Makefile.terraform:
	curl -sSL https://raw.githubusercontent.com/tmknom/template-terraform-module/master/Makefile.terraform -o .Makefile.terraform

MINIMAL_DIR := ./examples/minimal
COMPLETE_DIR := ./examples/complete

define start_session_to_example
	query='Reservations[0].Instances[0].InstanceId' && \
	filters='Name=tag:Name,Values=example,Name=instance-state-name,Values=running' && \
	document_name='SSM-SessionManagerRunShell-for-example' && \
	target=$$(aws ec2 describe-instances --output text --query $${query} --filters $${filters}) && \
	exec aws ssm start-session --target $${target} --document-name $${document_name}
endef

start-session: ## Start session to example
	$(call start_session_to_example)

terraform-plan-minimal: ## Run terraform plan examples/minimal
	$(call terraform,${MINIMAL_DIR},init)
	$(call terraform,${MINIMAL_DIR},plan) | tee -a /dev/stderr | docker run --rm -i tmknom/terraform-landscape

terraform-apply-minimal: ## Run terraform apply examples/minimal
	$(call terraform,${MINIMAL_DIR},apply)

terraform-destroy-minimal: ## Run terraform destroy examples/minimal
	$(call terraform,${MINIMAL_DIR},destroy)

terraform-plan-complete: ## Run terraform plan examples/complete
	$(call terraform,${COMPLETE_DIR},init)
	$(call terraform,${COMPLETE_DIR},plan) | tee -a /dev/stderr | docker run --rm -i tmknom/terraform-landscape

terraform-apply-complete: ## Run terraform apply examples/complete
	$(call terraform,${COMPLETE_DIR},apply)

terraform-destroy-complete: ## Run terraform destroy examples/complete
	$(call terraform,${COMPLETE_DIR},destroy)
