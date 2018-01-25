goto weiter6
aktionInfoTmp:
!Form öffnen
    CALL StartNewForm(DateSize,bcSOUNDOFF$,FrmScale,MsgBoxFontSize,bcLGRAY)
    LET form$ = "aktionInfo"
!Überschrift
    fraTemp = AddControl(bcFRMFRAME, feld$[2] + "->" + aktionInfo$[3], bcWHITE, bcBLUE, bcRED, bcLBLUE, ~
            0,0,0,1000,1000/width*height,70, bcCTRLCENTRE$+bcCAPBOLD$+bcALIGNCENTRE$)
!Zurück Knopf oben links
    zurKnopf = AddControl(bcFRMBUTTON, "GC-Back.png",bcBLACK,bcLGRAY,0,0, ~
            0,0,0,100,100,50, bcGRAPHIC$)
!Datum
    datum = AddControl(bcFRMDATE, "Datum:",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            120,20,300,450,100,50, bcDATBOLD$)
    datum2 = AddControl(bcFRMDisplay, "",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            120,320,0,350,100,50, bcDATBOLD$)
    rc = SetCtrlData(datum, aktionInfo$[4])
    rc = SetCtrlData(datum2, MID$(GetCtrlData$(datum), 9, 2)+"."+MID$(GetCtrlData$(datum), 6, 2)+"."+MID$(GetCtrlData$(datum), 1, 4))
!Kosten
    kosten = AddControl(bcFRMDISPLAY, "Kosten:",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            hoehe - 480,20,300,500,100,50, bcDATBOLD$)
    SPLIT kosten$[], REPLACE$(aktionInfo$[5], ",", "."), ";"
    rc = SetCtrlData(kosten, STR$(VAL(kosten$[1]) + VAL(kosten$[2]) + VAL(kosten$[3])) + " €")
!Teilfläche
    flaeche = AddControl(bcFRMDISPLAY, "Fläche(ha):",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            hoehe - 480,550,250,420,100,50, bcDATBOLD$)
    rc = SetCtrlData(flaeche, aktionInfo$[17])
!Kommentar
    kommentar = AddControl(bcFRMDisplay, "Kommentar:",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            hoehe - 360,20,300,950,100,50, bcDATBOLD$)
    rc = SetCtrlData(kommentar, aktionInfo$[18])
    text$ = aktionInfo$[18]
!Anwender
    anwender = AddControl(bcFRMCOMBOBOX, "Anwender:", bcBLACK, bcLGRAY, bcBLACK, bcWHITE, ~
            hoehe-240, 20, 300, 950, 100, 50, bcDATBOLD$ + bcALLOWNEW$)
    CtrlCap$ = "Anwender:"
    for i2 = 1 to length
        if (mittel$[i2, 4] = "5") then
            CtrlCap$ = CtrlCap$ + bcRECBREAK$ + mittel$[i2, 5]
        endif
    next i2
    rc = SetCtrlCap(anwender, CtrlCap$)
    rc = SetCtrlData(anwender, aktionInfo$[19])
!Aktion speichern unten
    speichernKnopf = AddControl(bcFRMBUTTON, "Speichern",bcBLACK,bcLGRAY,0,0, ~
            hoehe - 120,20,0,400,100,80, bcALIGNRIGHT$)
!Zahlen eingeben Frame
	zahlenInput=AddControl(bcFRMFRAME,"",bcWHITE,bcBLACK,0,bcLGRAY,~
				hoehe-600,0,0,1000,600,50,bcDATBOLD$+bcHIDE$+bcFADEBACK$)
		zahl=AddControl(bcFRMSTRING,"",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-600,20,0,960,100,100, bcDATBOLD$+bcDISABLED$+bcAlignDatRight$)
		taste1=AddControl(bcFRMButton,"1",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-480,20,0,220,100,100, bcDATBOLD$+bcFlat$)
		taste2=AddControl(bcFRMButton,"2",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-480,260,0,220,100,100, bcDATBOLD$+bcFlat$)
		taste3=AddControl(bcFRMButton,"3",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-480,500,0,220,100,100, bcDATBOLD$+bcFlat$)
		tasteBack=AddControl(bcFRMButton,"<-",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-480,740,0,240,100,100, bcDATBOLD$+bcFlat$)
		taste4=AddControl(bcFRMButton,"4",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-360,20,0,220,100,100, bcDATBOLD$+bcFlat$)
		taste5=AddControl(bcFRMButton,"5",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-360,260,0,220,100,100, bcDATBOLD$+bcFlat$)
		taste6=AddControl(bcFRMButton,"6",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-360,500,0,220,100,100, bcDATBOLD$+bcFlat$)
		tasteAbbr=AddControl(bcFRMButton,"Esc",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-360,740,0,240,100,100, bcDATBOLD$+bcFlat$)
		taste7=AddControl(bcFRMButton,"7",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-240,20,0,220,100,100, bcDATBOLD$+bcFlat$)
		taste8=AddControl(bcFRMButton,"8",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-240,260,0,220,100,100, bcDATBOLD$+bcFlat$)
		taste9=AddControl(bcFRMButton,"9",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-240,500,0,220,100,100, bcDATBOLD$+bcFlat$)
		tasteKomma=AddControl(bcFRMButton,",",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-120,20,0,220,100,100, bcDATBOLD$+bcFlat$)
		taste0=AddControl(bcFRMButton,"0",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-120,260,0,220,100,100, bcDATBOLD$+bcFlat$)
		tasteMinus=AddControl(bcFRMButton,"+/-",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-120,500,0,220,100,100, bcDATBOLD$+bcFlat$)
		tasteOk=AddControl(bcFRMButton,"OK",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-240,740,0,240,220,100, bcDATBOLD$+bcFlat$)
return

weiter6:

FN.DEF ModCtrlZahl(form, pm, km)
	FN.IMPORT zahlenInput, zahl, taste1, taste2, taste3, taste4, taste5, taste6, taste7, taste8, taste9, taste0, tasteKomma, tasteBack, tasteMinus, tasteAbbr, tasteOk 
	tmpZahl$ = ""
	ShowCtrl(zahlenInput, 1)
    ModCtrlData(zahl, REPLACE$(GetCtrlData$(form), ",", "."), 1)
	
    WHILE 0 = 0
        selCtrl=TouchCheck(0, taste1, tasteOk)
        SW.BEGIN selCtrl
        SW.CASE taste1
			ModCtrlData(zahl, GetCtrlData$(zahl) + "1", 0)
            SW.BREAK
        SW.CASE taste2
			ModCtrlData(zahl, GetCtrlData$(zahl) + "2", 0)
            SW.BREAK
        SW.CASE taste3
			ModCtrlData(zahl, GetCtrlData$(zahl) + "3", 0)
            SW.BREAK
        SW.CASE taste4
			ModCtrlData(zahl, GetCtrlData$(zahl) + "4", 0)
            SW.BREAK
        SW.CASE taste5
			ModCtrlData(zahl, GetCtrlData$(zahl) + "5", 0)
            SW.BREAK
        SW.CASE taste6
			ModCtrlData(zahl, GetCtrlData$(zahl) + "6", 0)
            SW.BREAK
        SW.CASE taste7
			ModCtrlData(zahl, GetCtrlData$(zahl) + "7", 0)
            SW.BREAK
        SW.CASE taste8
			ModCtrlData(zahl, GetCtrlData$(zahl) + "8", 0)
            SW.BREAK
        SW.CASE taste9
			ModCtrlData(zahl, GetCtrlData$(zahl) + "9", 0)
            SW.BREAK
        SW.CASE taste0
			ModCtrlData(zahl, GetCtrlData$(zahl) + "0", 0)
            SW.BREAK
        SW.CASE tasteMinus
			if (LEFT$(GetCtrlData$(zahl), 1) = "-") then
				ModCtrlData(zahl, RIGHT$(GetCtrlData$(zahl), -1), 0)
			else
				ModCtrlData(zahl, "-" + GetCtrlData$(zahl), 0)
			endif
            SW.BREAK
        SW.CASE tasteKomma
			if (is_in(".", GetCtrlData$(zahl)) = 0) then
				ModCtrlData(zahl, GetCtrlData$(zahl) + ".", 0)
			endif
            SW.BREAK
        SW.CASE tasteBack
			if (GetCtrlData$(zahl) <> "-") then
				ModCtrlData(zahl, LEFT$(GetCtrlData$(zahl), -1), 0)
			endif
            SW.BREAK
        SW.CASE tasteOk
			ModCtrlData(form, GetCtrlData$(zahl), 0)
            W_R.break
        SW.CASE tasteAbbr
            W_R.break
        SW.END

		!Zahl schöner machen
		tmpZahl$ = LTRIM$(GetCtrlData$(zahl), "0")
		if (tmpZahl$ = "")
			ModCtrlData(zahl, "0", 1)
		elseif (tmpZahl$ = ".")
			ModCtrlData(zahl, "0.", 1)
		elseif(left$(tmpZahl$, 1) = ".") then
			ModCtrlData(zahl, "0" + tmpZahl$, 1)
		elseif(tmpZahl$ = "-") then
			ModCtrlData(zahl, "-0", 1)
		elseif(left$(tmpZahl$, 2) = "-.") then
			ModCtrlData(zahl, "-0," + tmpZahl$, 1)
        else
			ModCtrlData(zahl, tmpZahl$, 1)
        endif
        !Darf negativ sein?
        if (pm = 0) then
			ModCtrlData(zahl, REPLACE$(GetCtrlData$(zahl), "-", ""),1)
        endif
        !Darf Komma haben?
        if (km = 0) then
			ModCtrlData(zahl, WORD$(GetCtrlData$(zahl), 1, "."),1)
        endif
    REPEAT
	HideCtrl(zahlenInput, 1)
FN.END

