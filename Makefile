# Extracts from the artwork, and their renderings.
#
#   make           -- (re)generate extracts (*_tuned/*.svg) as instructed by
#                     the *.svgtune files
#   make pdfs      -- also render the extracts into .pdf's
#   make pngs      -- also render the extracts into .png's
#   make FILE.pdf, FILE.png, FILE_sw.png, FILE_30dpi.png, ...
#                  -- render a particular FILE.svg
#
# svgtune (https://github.com/yarikoptic/svgtune) is provided as a git
# submodule: run "git submodule update --init tools/svgtune" (or
# "datalad get -n tools/svgtune") to get it.  Otherwise the one found in
# the PATH is used.

SVGTUNE ?= $(firstword $(wildcard tools/svgtune/svgtune) svgtune)
INKSCAPE ?= inkscape

all:: extracts

SVGTUNES := $(wildcard *.svgtune)
TUNED := $(SVGTUNES:.svgtune=_tuned)

extracts: $(TUNED)

# Extracts are known only after they are generated, hence the sub-make
pdfs pngs: extracts
	@$(MAKE) --no-print-directory \
		$$(ls $(addsuffix /*.svg,$(TUNED)) | sed -e 's/\.svg$$/.$(@:s=)/')

clean::
	rm -f $(foreach d,$(TUNED),$(d)/*.pdf $(d)/*.png $(d)/*.eps)

.PHONY: all extracts pdfs pngs clean

#
# SVGTune
#
%_tuned: %.svgtune %.svg $(wildcard tools/svgtune/svgtune)
	@echo "Tuning $*.svg using $<"
# On failure, make the directory look outdated so it is redone next time
	@$(SVGTUNE) $< || { touch -d @0 "$@"; exit 1; }
# Touch it to adjust the timestamp so make does not think that we are
# out of date later on
	@touch "$@"

#
# Inkscape rendered figures
#
%.pdf: %.svg
	@echo "Rendering $@"
	@$(INKSCAPE) --export-type=pdf --export-filename="$@" "$<"

%.eps: %.svg
	@echo "Rendering $@"
	@$(INKSCAPE) --export-type=eps --export-text-to-path --export-filename="$@" "$<"

%.png: %.svg
	@echo "Rendering $@"
	@$(INKSCAPE) --export-type=png --export-dpi=150 --export-filename="$@" "$<"

# PNG at slide width
SLIDE_WIDTH=1024
%_sw.png: %.svg
	@echo "Rendering $@ at slide width of $(SLIDE_WIDTH)"
	@$(INKSCAPE) --export-type=png --export-width=$(SLIDE_WIDTH) --export-filename="$@" "$<"

%_15dpi.png: %.svg
	@echo "Rendering $@"
	@$(INKSCAPE) --export-type=png --export-dpi=15 --export-filename="$@" "$<"

%_30dpi.png: %.svg
	@echo "Rendering $@"
	@$(INKSCAPE) --export-type=png --export-dpi=30 --export-filename="$@" "$<"

%_75dpi.png: %.svg
	@echo "Rendering $@"
	@$(INKSCAPE) --export-type=png --export-dpi=75 --export-filename="$@" "$<"

%_600dpi.png: %.svg
	@echo "Rendering $@"
	@$(INKSCAPE) --export-type=png --export-dpi=600 --export-filename="$@" "$<"
