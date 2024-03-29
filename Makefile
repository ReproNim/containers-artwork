all:: pics

# Optionally some PICS could be ignored. By default XXX ones.
# PICS_IGNORE must contain a rule for grep
PICS_IGNORE ?= "XXX"

# For every .svg we must have a pdf
PICS=$(shell find . -iname \*svg \
	| sed -e 's/svg/pdf/g' -e 's/\([^\]\)\([ \t:]\)/\1\\\\\2/g' \
	| grep -v -e $(PICS_IGNORE) )
# For history figure we need pngs due to crippled transparency support
# in poppler, so for now would rely on PNGs
PICS+=$(shell [ -d neuropy_history_tuned ] && \
	find neuropy_history_tuned/ -iname \*svg \
	| sed -e 's/.svg/_sw.png/g' -e 's/\([^\]\)\([ \t:]\)/\1\\\\\2/g' \
	| grep -v -e $(PICS_IGNORE))
# Converted
PICS_CONVERTED=
#PICS+=$(PICS_CONVERTED)
SVGIS=$(shell  find . -iname \*.svgtune | sed -e 's/.svgtune/_tuned/g')

FMAKE := $(MAKE) -s -f $(lastword $(MAKEFILE_LIST))

pics: $(SVGIS) $(PICS)

pics_debug:
	echo $(SVGIS) $(PICS) | tr ' ' '\n' | sort | uniq -c | sort -n

clean::
	rm $(PICS_CONVERTED) pymvpa_code_V.svg
	for p in *.svg; do rm -f $${p%*.svg}.{pdf,eps,png}; done
	rm -fr *_tuned

.PHONY: ignore-%
ignore-%:
	#@grep -q "^$*$$" .gitignore || { \
	#  echo "$*" >> .gitignore; echo "Ignore $@"; }


#
# SVGTune
#
%_tuned: %.svgtune %.svg
	@echo "Splitting SVG using $<"
# Use gqview to preview svgs -- quite nice
	@../tools/svgtune/svgtune $<
# Touch it to adjust the timestamp so make does not think that we are
# out of date later on
	@touch "$@"
# And assure that we have ignore ... cannot be in deps since would cause
# regeneration over and over again
	@$(MAKE) ignore-$@

# Custom version of pymvpa_code, without code, thus only V, and
# width changed accordingly
pymvpa_code_V.svg: pymvpa_code.svg
	sed -e 's,width="729.[0-9]*",width="353.88333",g' $< >| $@

#
# Inkscape rendered figures
#
%.pdf: %.svg ignore-%.pdf
	@echo "Rendering $@"
	@inkscape -z -f "$<" -A "$@"

%.eps: %.svg ignore-%.eps
	@echo "Rendering $@"
	@inkscape -z -T -f "$<" -E "$@"

%.png: %.svg ignore-%.png
	@echo "Rendering $@"
	@inkscape -z -f "$<" -e "$@" -d 150


# Pygmentize rendered code
%.svg: %.py ignore-%.svg
	@echo "Pygmentizing $@"
	@pygmentize -f svg -l python -O style=emacs -o "$@" "$<"

#
# Rare xfig plots
#
%.pdf: %.fig ignore-%.pdf
	@echo "Rendering $@"
	@fig2dev -L pdf "$<" "$@"


# PNG at slide width
SLIDE_WIDTH=1024
SLIDE_HEIGHT=768
%_sw.png: %.svg ignore-%_sw.png
	@echo "Rendering $@ at slide width of $(SLIDE_WIDTH)"
	@inkscape -z -f "$<" -e "$@" --export-width=$(SLIDE_WIDTH)

# Following two rules will try imagemagick's to convert an image to
# the corresponding size...
# TODO: figure out how to make them match for both jpg and png
#       files as sources
%_sw.png: %.jpg ignore-%_sw.png
	@echo "Converting $@ at slide width of $(SLIDE_WIDTH)"
	@convert -geometry $(SLIDE_WIDTH) "$<" "$@"

%_sh.png: %.jpg ignore-%_sh.png
	@echo "Converting $@ at slide height of $(SLIDE_HEIGHT)"
	@convert -geometry x$(SLIDE_HEIGHT) "$<" "$@"

%_15dpi.png: %.svg ignore-%_15dpi.png
	@echo "Rendering $@"
	@inkscape -z -f "$<" -e "$@" -d 15

%_30dpi.png: %.svg ignore-%_30dpi.png
	@echo "Rendering $@"
	@inkscape -z -f "$<" -e "$@" -d 30

%_75dpi.png: %.svg ignore-%_75dpi.png
	@echo "Rendering $@"
	@inkscape -z -f "$<" -e "$@" -d 75

%_600dpi.png: %.svg ignore-%_600dpi.png
	@echo "Rendering $@"
	@inkscape -z -f "$<" -e "$@" -d 600


#
# Dia rendered figures (mostly for historic/)
#
%.pdf: %.dia ignore-%.pdf
	dia -e $@ $<
%_w800.png: %.dia ignore-%_w800.png
	dia -s 800 -e $@ $<

# Some additional PICS to render not worth adding find command ;)
all:: historic/pymvpa_design_v1_20080314.pdf \
	borrowed/fred-commands.pdf

.PHONY: all pics
