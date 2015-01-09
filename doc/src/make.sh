#!/bin/sh
# Make the basics.do.txt and bumpy.do.txt documents in various formats

set -x  # show all commands in output

function system {
  "$@"
  if [ $? -ne 0 ]; then
    echo "make.sh: unsuccessful command $@"
    echo "abort!"
    exit 1
  fi
}

names="basics bumpy"
#names="basics"
for name in $names; do

system doconce format pdflatex $name --device=paper --minted_latex_style=trac
system doconce ptex2tex $name envir=minted
pdflatex -shell-escape $name
makeindex $name
pdflatex -shell-escape $name
pdflatex -shell-escape $name

# Plain HTML
system doconce format html $name --html_style=bootstrap
if [ $? -ne 0 ]; then echo "doconce could not compile document"; exit; fi
system doconce split_html $name.html --pagination

# Sphinx
system doconce format sphinx $name  # always generate new
system doconce sphinx_dir theme=cbc author="H. P. Langtangen" $name
system python automake_sphinx.py

# Publish
dest=../pub
rm -rf $dest/sphinx-${name}
cp -r sphinx-rootdir/_build/html $dest/sphinx-${name}
cp -r fig-bumpy $name.html ._${name}*.html ${name}.pdf $dest/
done
