goto weiter6

aktionInfoTmp:
!Form öffnen
    CALL StartNewForm(DateSize,bcSOUNDOFF$,FrmScale,MsgBoxFontSize,bcLBLUE)
    LET form$ = "aktionInfo"
!Überschrift
    fraTemp = AddControl(bcFRMFRAME, betriebName$ + " -> " + int$(ernteJahr) + " -> " +feld$[2] + " -> " + aktionInfo$[3] + "   ", bcWHITE, bcBLUE, bcRED, bcLBLUE, ~
            0, 0, 0, 1000, 100, 80, bcCAPBOLD$+bcALIGNRIGHT$)
!Zurück Knopf oben links
    zurKnopf = AddControl(bcFRMBUTTON, "GC-Back.png",bcBLACK,bcLGRAY,0,0, ~
            0,0,0,100,100,50, bcGRAPHIC$)
!Datum
    datum = AddControl(bcFRMDATE, _$("Datum:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            120,20,300,450,100,50, bcDATBOLD$)
    datum2 = AddControl(bcFRMDisplay, "",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            120,320,0,350,100,50, bcDATBOLD$)
    rc = SetCtrlData(datum, aktionInfo$[4])
    rc = SetCtrlData(datum2, MID$(GetCtrlData$(datum), 9, 2)+"."+MID$(GetCtrlData$(datum), 6, 2)+"."+MID$(GetCtrlData$(datum), 1, 4))
!Kosten
    kosten = AddControl(bcFRMDISPLAY, _$("Kosten:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            hoehe - 480,20,300,500,100,50, bcDATBOLD$)
    SPLIT kosten$[], REPLACE$(aktionInfo$[5], ",", "."), ";"
    rc = SetCtrlData(kosten, STR$(VAL(kosten$[1]) + VAL(kosten$[2]) + VAL(kosten$[3])) + " €")
!Teilfläche
    flaeche = AddControl(bcFRMDISPLAY, _$("Fläche(ha):"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            hoehe - 480,550,250,420,100,50, bcDATBOLD$)
    rc = SetCtrlData(flaeche, aktionInfo$[17])
!Kommentar
    kommentar = AddControl(bcFRMDisplay, _$("Kommentar:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            hoehe - 360,20,300,950,100,50, bcDATBOLD$)
    rc = SetCtrlData(kommentar, aktionInfo$[18])
    text$ = aktionInfo$[18]
!Anwender
    anwender = AddControl(bcFRMCOMBOBOX, _$("Anwender:"), bcBLACK, bcLGRAY, bcBLACK, bcWHITE, ~
            hoehe-240, 20, 300, 950, 100, 50, bcDATBOLD$ + bcALLOWNEW$)
    CtrlCap$ = _$("Anwender:")
    for i2 = 1 to length
        if (mittel$[i2, 4] = "5") then
            CtrlCap$ = CtrlCap$ + bcRECBREAK$ + mittel$[i2, 5]
        endif
    next i2
    rc = SetCtrlCap(anwender, CtrlCap$)
    rc = SetCtrlData(anwender, aktionInfo$[19])
!Aktion speichern unten
    speichernKnopf = AddControl(bcFRMBUTTON, _$("Speichern"),bcBLACK,bcLGRAY,0,0, ~
            hoehe - 120,20,0,400,100,80, bcALIGNRIGHT$)
!Zahlen eingeben Frame2
		zahlenFeld=AddControl(bcFRMFRAME,"Zahl eingeben",bcWHITE,bcBLUE,0,bcLGRAY,~
				200,100,0,800,600,70,bcDATBOLD$+bcHIDE$)
		zahl=AddControl(bcFRMSTRING,"",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				400,150,0,540,125,125, bcDATBOLD$+bcDISABLED$+bcAlignDatRight$)
		tasteBack=AddControl(bcFRMButton,"<-",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				400,700,0,150,125,125, bcDATBOLD$+bcFlat$)
		tasteAbbr=AddControl(bcFRMButton,"Abbr.",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				600,150,0,340,125,125, bcDATBOLD$+bcFlat$)
		tasteOk=AddControl(bcFRMButton,"OK",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				600,560,0,290,125,125, bcDATBOLD$+bcFlat$)
!Zahlen eingeben Frame
	zahlenInput=AddControl(bcFRMFRAME,"",bcWHITE,bcBLACK,0,bcLGRAY,~
				hoehe-600,0,0,1000,600,50,bcDATBOLD$+bcHIDE$+bcFADEBACK$)
		taste1=AddControl(bcFRMButton,"1",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-580,20,0,300,125,125, bcDATBOLD$+bcFlat$)
		taste2=AddControl(bcFRMButton,"2",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-580,340,0,300,125,125, bcDATBOLD$+bcFlat$)
		taste3=AddControl(bcFRMButton,"3",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-580,680,0,300,125,125, bcDATBOLD$+bcFlat$)
		taste4=AddControl(bcFRMButton,"4",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-435,20,0,300,125,125, bcDATBOLD$+bcFlat$)
		taste5=AddControl(bcFRMButton,"5",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-435,340,0,300,125,125, bcDATBOLD$+bcFlat$)
		taste6=AddControl(bcFRMButton,"6",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-435,680,0,300,125,125, bcDATBOLD$+bcFlat$)
		taste7=AddControl(bcFRMButton,"7",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-290,20,0,300,125,125, bcDATBOLD$+bcFlat$)
		taste8=AddControl(bcFRMButton,"8",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-290,340,0,300,125,125, bcDATBOLD$+bcFlat$)
		taste9=AddControl(bcFRMButton,"9",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-290,680,0,300,125,125, bcDATBOLD$+bcFlat$)
		tasteKomma=AddControl(bcFRMButton,"∙",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-145,340,0,300,125,125, bcDATBOLD$+bcFlat$)
		taste0=AddControl(bcFRMButton,"0",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-145,20,0,300,125,125, bcDATBOLD$+bcFlat$)
		tasteMinus=AddControl(bcFRMButton,"+/-",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				hoehe-145,680,0,300,125,125, bcDATBOLD$+bcFlat$)
!Kosten eingeben Frame3
		zahlenKosten=AddControl(bcFRMFRAME,"Kosten eingeben",bcWHITE,bcBLUE,0,bcLGRAY,~
				200,50,0,900,800,70,bcDATBOLD$+bcHIDE$)
		name1=AddControl(bcFRMDISPLAY,"Saatgut:",bcBlack, bcLGRAY,bcBLACK,bcWHITE,~
				340,100,300,300,70,70, bcDATBOLD$+bcAlignDatRight$+bcNOBORDER$)
		name12=AddControl(bcFRMDISPLAY,"(€/kg)",bcBlack, bcLGRAY,bcBLACK,bcWHITE,~
				420,100,300,300,50,50, bcDATBOLD$+bcAlignDatRight$+bcNOBORDER$)
		zahl1=AddControl(bcFRMDISPLAY,"",bcBlack,bcLGRAY,bcBLACK,bcWHITE,~
				350,400,0,400,125,100, bcDATBOLD$+bcAlignDatRight$)
		name2=AddControl(bcFRMDISPLAY,"Arbeit:",bcBlack,bcLGRAY,bcBLACK,bcWHITE,~
				490,100,300,300,70,70, bcDATBOLD$+bcAlignDatRight$+bcNOBORDER$)
		name22=AddControl(bcFRMDISPLAY,"(€/ha)",bcBlack,bcLGRAY,bcBLACK,bcWHITE,~
				570,100,300,300,50,50, bcDATBOLD$+bcAlignDatRight$+bcNOBORDER$)
		zahl2=AddControl(bcFRMDISPLAY,"",bcLGRAY,bcWHITE,bcBLACK,bcWHITE,~
				500,400,0,400,125,100, bcDATBOLD$+bcAlignDatRight$)
		name3=AddControl(bcFRMDISPLAY,"Festk.:",bcBlack,bcLGRAY,bcBLACK,bcWHITE,~
				640,100,300,300,70,70, bcDATBOLD$+bcAlignDatRight$+bcNOBORDER$)
		name32=AddControl(bcFRMDISPLAY,"(€)",bcBlack,bcLGRAY,bcBLACK,bcWHITE,~
				720,100,300,300,50,50, bcDATBOLD$+bcAlignDatRight$+bcNOBORDER$)
		zahl3=AddControl(bcFRMDISPLAY,"",bcLGRAY,bcWHITE,bcBLACK,bcWHITE,~
				650,400,0,400,125,100, bcDATBOLD$+bcAlignDatRight$)
		tasteBack1=AddControl(bcFRMButton,"<-",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				350,810,0,130,125,100, bcDATBOLD$+bcFlat$)
		tasteBack2=AddControl(bcFRMButton,"<-",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				500,810,0,130,125,100, bcDATBOLD$+bcFlat$+bcHIDE$)
		tasteBack3=AddControl(bcFRMButton,"<-",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				650,810,0,130,125,100, bcDATBOLD$+bcFlat$+bcHIDE$)
		tasteAbbr2=AddControl(bcFRMButton,"Abbr.",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				800,150,0,340,125,125, bcDATBOLD$+bcFlat$)
		tasteOk2=AddControl(bcFRMButton,"OK",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				800,560,0,290,125,125, bcDATBOLD$+bcFlat$)
return

weiter6:


FN.DEF ModCtrlKosten(form, pm, km)
	FN.IMPORT aktionInfo$[], kosten$[], zahlenInput, zahlenKosten, zahl1, zahl2, zahl3, taste1, taste2, taste3, taste4, taste5, taste6, taste7, taste8, taste9, taste0, tasteKomma, tasteBack1, tasteBack2, tasteBack3, tasteMinus, tasteAbbr2, tasteOk2 
	tmpZahl$ = ""
	ShowCtrl(zahlenInput, 1)
	ShowCtrl(zahlenKosten, 1)
    ModCtrlData(zahl1, kosten$[1], 1)
    ModCtrlData(zahl2, kosten$[2], 1)
    ModCtrlData(zahl3, kosten$[3], 1)
	!Erstes Eingabefeld aktivieren und Kurser malen
	tmpZ = zahl1
	ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + "|", 1)
	
    WHILE 0 = 0
        selCtrl=TouchCheck(0, taste1, tasteOk2)
		!Kurser zur Verarbeitung wegmalen
		ModCtrlData(tmpZ, LEFT$(GetCtrlData$(tmpZ), -1), 0)
        SW.BEGIN selCtrl
        SW.CASE zahl1
            tmpZ = selCtrl
            ctrlVisible(tasteBack1,1,1)
            ctrlVisible(tasteBack2,0,1)
            ctrlVisible(tasteBack3,0,1)
            SW.BREAK
        SW.CASE zahl2
            tmpZ = selCtrl
            ctrlVisible(tasteBack1,0,1)
            ctrlVisible(tasteBack2,1,1)
            ctrlVisible(tasteBack3,0,1)
            SW.BREAK
        SW.CASE zahl3
            tmpZ = selCtrl
            ctrlVisible(tasteBack1,0,1)
            ctrlVisible(tasteBack2,0,1)
            ctrlVisible(tasteBack3,1,1)
            SW.BREAK
        SW.CASE taste1
			ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + "1", 0)
            SW.BREAK
        SW.CASE taste2
			ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + "2", 0)
            SW.BREAK
        SW.CASE taste3
			ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + "3", 0)
            SW.BREAK
        SW.CASE taste4
			ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + "4", 0)
            SW.BREAK
        SW.CASE taste5
			ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + "5", 0)
            SW.BREAK
        SW.CASE taste6
			ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + "6", 0)
            SW.BREAK
        SW.CASE taste7
			ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + "7", 0)
            SW.BREAK
        SW.CASE taste8
			ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + "8", 0)
            SW.BREAK
        SW.CASE taste9
			ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + "9", 0)
            SW.BREAK
        SW.CASE taste0
			ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + "0", 0)
            SW.BREAK
        SW.CASE tasteKomma
			if (is_in(".", GetCtrlData$(tmpZ)) = 0) then
				ModCtrlData(tmpZ, GetCtrlData$(tmpZ) + ".", 0)
			endif
            SW.BREAK
        SW.CASE tasteBack1
			ModCtrlData(zahl1, LEFT$(GetCtrlData$(zahl1), -1), 0)
            SW.BREAK
        SW.CASE tasteBack2
			ModCtrlData(zahl2, LEFT$(GetCtrlData$(zahl2), -1), 0)
            SW.BREAK
        SW.CASE tasteBack3
			ModCtrlData(zahl3, LEFT$(GetCtrlData$(zahl3), -1), 0)
            SW.BREAK
        SW.CASE tasteOk2
			kosten$[1]= GetCtrlData$(zahl1)
			kosten$[2]= GetCtrlData$(zahl2)
			kosten$[3]= GetCtrlData$(zahl3)
			aktionInfo$[5] = kosten$[1]+";"+kosten$[2]+";"+kosten$[3]
			ModCtrlData(form, STR$(VAL(kosten$[1]) + VAL(kosten$[2]) + VAL(kosten$[3])) + " €", 1)
            W_R.break
        SW.CASE tasteAbbr2
            tmpZ = zahl1
            ctrlVisible(tasteBack1,1,1)
            ctrlVisible(tasteBack2,0,1)
            ctrlVisible(tasteBack3,0,1)
            W_R.break
        SW.END

		!Zahl schöner machen
		tmpZahl$ = LTRIM$(GetCtrlData$(tmpZ), "0")
		if (tmpZahl$ = "")
			ModCtrlData(tmpZ, "0|", 1)
		elseif (tmpZahl$ = ".")
			ModCtrlData(tmpZ, "0.|", 1)
		elseif(left$(tmpZahl$, 1) = ".") then
			ModCtrlData(tmpZ, "0" + tmpZahl$ + "|", 1)
		elseif(tmpZahl$ = "-") then
			ModCtrlData(tmpZ, "-0|", 1)
		elseif(left$(tmpZahl$, 2) = "-.") then
			ModCtrlData(tmpZ, "-0," + tmpZahl$ + "|", 1)
        else
			ModCtrlData(tmpZ, tmpZahl$ + "|", 1)
        endif
    REPEAT
	HideCtrl(zahlenInput, 1)
	HideCtrl(zahlenKosten, 1)
FN.END

FN.DEF ModCtrlZahl(form, pm, km)
	FN.IMPORT zahlenInput, zahlenFeld, zahl, taste1, taste2, taste3, taste4, taste5, taste6, taste7, taste8, taste9, taste0, tasteKomma, tasteBack, tasteMinus, tasteAbbr, tasteOk 
	tmpZahl$ = ""
	ShowCtrl(zahlenInput, 1)
	ShowCtrl(zahlenFeld, 1)
    ModCtrlData(zahl, REPLACE$(GetCtrlData$(form), ",", ".") + "|", 1)
	
    WHILE 0 = 0
        selCtrl=TouchCheck(0, zahl, tasteMinus)
		!Kurser zur Verarbeitung wegmalen
		ModCtrlData(zahl, LEFT$(GetCtrlData$(zahl), -1), 0)
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
			ModCtrlData(zahl, "0|", 1)
		elseif (tmpZahl$ = ".")
			ModCtrlData(zahl, "0.|", 1)
		elseif(left$(tmpZahl$, 1) = ".") then
			ModCtrlData(zahl, "0" + tmpZahl$ + "|", 1)
		elseif(tmpZahl$ = "-") then
			ModCtrlData(zahl, "-0|", 1)
		elseif(left$(tmpZahl$, 2) = "-.") then
			ModCtrlData(zahl, "-0," + tmpZahl$ + "|", 1)
        else
			ModCtrlData(zahl, tmpZahl$ + "|", 1)
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
	HideCtrl(zahlenFeld, 1)
FN.END

