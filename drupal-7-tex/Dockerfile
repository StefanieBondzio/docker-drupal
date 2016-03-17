FROM elcom:drupal:7
MAINTAINER LWB

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
    imagemagick texinfo dvi2ps ghostscript texlive-generic-recommended texlive-lang-german texlive-latex-recommended texlive-latex-extra texlive-fonts-extra texlive-fonts-recommended texlive-math-extra gnuhtml2latex && \
    rm -rf /var/lib/apt/lists