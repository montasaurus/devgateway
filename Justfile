install:
	

build:
	docker build -t montasaurus/devgateway:latest .

services-up:
	

services-down:
	

[confirm("Are you sure you want to delete all runtime data in var?")]
clean:
	git clean var -X --force
