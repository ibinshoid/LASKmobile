Device.Locale locale$
FILE.TYPE fi$, "../data/"+LEFT$(locale$, 2)+".po"
if (fi$ = "f") then
	TEXT.OPEN r, enpo, LEFT$(locale$, 2)+".po"
	DO
		TEXT.READLN enpo, line1$
		if (WORD$(line1$, 1, " \"") = "msgid") then
			TEXT.READLN enpo, line2$
			BUNDLE.PUT i18n, LEFT$(WORD$(line1$, 2, " \""), -1), LEFT$(WORD$(line2$, 2, " \""), -1) 
		endif
	UNTIL line1$ = "EOF"
	TEXT.CLOSE enpo
endif

FN.DEF _$(tr$)
	FN.IMPORT i18n
	ntr$ = tr$
	
	BUNDLE.CONTAIN i18n, tr$, isin
	if (isin <> 0) then
		BUNDLE.GET i18n, tr$, ntr$
	endif
	FN.RTN ntr$
FN.END


