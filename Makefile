# Build through the devcontainer image, so no local TeX Live is needed.
IMAGE ?= travelbook-latex
DOC   ?= example

.PHONY: pdf image clean

pdf: image
	docker run --rm -v "$(CURDIR)":/work $(IMAGE) latexmk -g $(DOC).tex

image:
	@docker image inspect $(IMAGE) >/dev/null 2>&1 || docker build -t $(IMAGE) .devcontainer

clean:
	docker run --rm -v "$(CURDIR)":/work $(IMAGE) latexmk -C $(DOC).tex
