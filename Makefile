
SOURCE = report

.PHONY: all figures bib clean deep-clean dvi

all: update report

update: deep-clean show

preview:
	TEXINPUTS="./styles:" latexmk \
		  -dvi -pvc -silent $(SOURCE).tex

figures:
	@cd eps && \
	for f in *.pdf; do \
		FN=$${f%.pdf}; \
		[ $${FN}.pdf -ot $${FN}.eps ] && continue; \
		echo "##### Converting [$${FN}]..."; \
		pdf2ps -f $${FN}.pdf; \
		ps2eps -f $${FN}.ps; \
		rm $${FN}.ps; \
	done

dvi: $(SOURCE).dvi $(SOURCE).bbl figures
$(SOURCE).dvi: $(SOURCE).tex $(SOURCE).bbl
	TEXINPUTS="./styles:" latex $<
	TEXINPUTS="./styles:" latex $<

ps: $(SOURCE).ps
$(SOURCE).ps: $(SOURCE).dvi
	dvips -Ppdf -G0 -tletter -o $@ $<

pdf: $(SOURCE).pdf
$(SOURCE).pdf: $(SOURCE).ps
	ps2pdf -dSubsetFonts=true -dMaxSubsetPct=100 \
		-dEmbedAllFonts=true -dUseFlateCompression=true \
		-dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress \
		$< $@

bib: $(SOURCE).bbl
$(SOURCE).bbl : $(SOURCE).bib
	TEXINPUTS="./styles:" latex $(SOURCE).tex
	BSTINPUTS="./styles:" bibtex $(SOURCE)

report: $(SOURCE).pdf
	pdffonts $< > fonts.log
	cat fonts.log

show: pdf
	kill -9 `ps aux | grep $(SOURCE).pdf | grep -v grep | awk '{print $2}'` >/dev/null 2>&1 || true
	gnome-open $(SOURCE).pdf

clean:
	rm -f *.bbl *.blg *.out *.aux \
	  *.dvi *.log *.ps *.bak *~ \
	  *latexmk

deep-clean: clean
	rm -rf *.pdf

