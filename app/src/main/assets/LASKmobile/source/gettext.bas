TEXT.OPEN r, enpo, "en.po"
DO
	TEXT.READLN enpo, line1$
	if (WORD$(line1$, 1, " \"") = "msgid") then
		TEXT.READLN enpo, line2$
		BUNDLE.PUT i18n, LEFT$(WORD$(line1$, 2, " \""), -1), LEFT$(WORD$(line2$, 2, " \""), -1) 
	endif
UNTIL line1$ = "EOF"
TEXT.CLOSE enpo


