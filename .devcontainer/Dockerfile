# TeX Live per compilare il libro con LuaLaTeX e latexmk.
# Ubuntu LTS e pacchetti apt: niente da installare sul Mac.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
       git procps make \
       texlive-latex-base \
       texlive-latex-recommended \
       texlive-latex-extra \
       texlive-pictures \
       texlive-fonts-extra \
       texlive-luatex \
       texlive-lang-italian \
       latexmk chktex poppler-utils \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=dialog \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8
WORKDIR /work
