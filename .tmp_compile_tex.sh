#!/usr/bin/env bash
set -euo pipefail
# Install TeXlive (minimal recommended packages)
apt-get update
apt-get install -y --no-install-recommends texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended
# Compile twice to resolve references
pdflatex -interaction=nonstopmode -halt-on-error informe_matematico.tex
pdflatex -interaction=nonstopmode -halt-on-error informe_matematico.tex
ls -la informe_matematico.pdf
