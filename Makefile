build:
	docker build . -t ghcr.io/bryopsida/mattermost:local
run:
	docker run ghcr.io/bryopsida/mattermost:local
shell:
	docker run -it ghcr.io/bryopsida/mattermost:local /bin/sh