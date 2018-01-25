goto weiter

felderListe:
!Form öffnen
!    CALL StartNewForm(DateSize,bcSOUNDOFF$,FrmScale,MsgBoxFontSize,bcLBLUE)
    CALL StartNewForm(DateSize,bcSOUNDOFF$,FrmScale,MsgBoxFontSize,bcLBLUE)
    LET form$ = "felderListe"
!Überschrift
    ueberschrift = AddControl(bcFRMDISPLAY, "", bcRED, bcLBLUE, bcWHITE, bcBLUE, ~
            0, 0, 0, 1000, 100, 80, bcDATBOLD$+bcALIGNDATCENTRE$)
    rc = SetCtrlData(ueberschrift, "LASKmobile")
!Felderliste mitte
    felderListe = AddControl(bcFRMLISTBOX,"", bcWHITE,bcLBLUE,bcBLACK,bcWHITE, ~
                220, 10, 0, 980, hoehe-340, 60, bcDATBOLD$+bcNOHEADBOX$+bcLISTVIEW$)
    rc = SetCtrlCap(felderListe, ""+bcCOLBREAK$ ~
                +"Id"+bcFLDBREAK$+"0"+bcFLDBREAK$+"1"+bcCOLBREAK$ ~
                +"Feld"+bcFLDBREAK$+"650"+bcFLDBREAK$+"1"+bcCOLBREAK$ ~
                +"Größe"+bcFLDBREAK$+"329"+bcFLDBREAK$+"1"+bcRECBREAK$+" ")
!Filterleiste oben
    feldFilter = AddControl(bcFRMSELECT,"Select", bcWHITE,bcGRAY, bcBLACK,bcWHITE, ~
            110,10,0,980,100,80, bcCAPITALIC$+bcDATBOLD$+bcALIGNRIGHT$)
    rc = SetCtrlCap(feldFilter, "Select"+bcRECBREAK$+"Alle"+bcRECBREAK$+"Felder"+bcRECBREAK$+"Grünland")
    rc = SetCtrlData(feldFilter, "Alle")

!Aktion hinzufügen unten
    aktionHinzu = AddControl(bcFRMCOMBOBOX,"",bcWHITE,bcGRAY,bcBLACK,bcWHITE, ~
            hoehe - 110, 10, 0, 980, 100, 80, bcALIGNRIGHT$)
    rc = SetCtrlCap(aktionHinzu,""+bcRECBREAK$+"Aktion hinzufügen"+ ~
            bcRECBREAK$+"Saat"+ ~
            bcRECBREAK$+"Bodenbearbeitung"+ ~
            bcRECBREAK$+"Pflanzenschutz"+ ~
            bcRECBREAK$+"organische Düngung"+ ~
            bcRECBREAK$+"mineralische Düngung"+ ~
            bcRECBREAK$+"Ernte")
    rc = SetCtrlData(aktionHinzu, "Aktion hinzufügen")
!Menü Knopf oben links
    menuKnopf=AddControl(bcFRMBUTTON,"="+bcRECBREAK$+ ~
            "Erntejahr"+bcRECBREAK$+ ~
            "Einstellungen"+bcRECBREAK$+ ~
            "Beenden"+bcRECBREAK$, ~
            bcBLACK,bcLGRAY,bcBLACK,bcCYAN, 0,0,500,100,100,50, bcCAPBOLD$+BS$+bcMENULIST$)
!Auswahlfenster Erntejahr
	jahrWahl=AddControl(bcFRMFRAME,"Erntejahr",bcWHITE,bcBLUE,0,bcLGRAY,~
				200,200,100,600,600,80,bcDATBOLD$+bcHIDE$+bcFADEBACK$+bcALIGNCENTRE$)
    jahrWahlCombo = AddControl(bcFRMCOMBOBOX,"",bcWHITE,bcGRAY,bcBLACK,bcWHITE, ~
				400, 300, 0, 400, 100, 80, bcALIGNLEFT$)
    ARRAY.length jahreZahl, jahre[]
    CtrlCap$ = ""
    for i3 = 1 to jahreZahl
            if (jahre[i3] > 1000) then
				CtrlCap$ = CtrlCap$ + bcRECBREAK$ + int$(jahre[i3])
			endif
    next i3
    
    rc = SetCtrlCap(jahrWahlCombo,CtrlCap$)
    rc = SetCtrlData(jahrWahlCombo,int$(ernteJahr))
	jahrWahlOk=AddControl(bcFRMButton,"OK",bcWHITE,bcGRAY,bcBLACK,bcWHITE,~
				600,300,0,400,100,100, bcDATBOLD$+bcFlat$)
	
	
    CALL DrawForm("",picPath$)
    ModCtrlCap(felderListe, laskDb_felderLaden$(), 1)

!MainLoop
    twx = 0
    vorher$ = ""
    vorher = -1

    WHILE twx = 0
        selCtrl=TouchCheck(0,0,0)
        SW.BEGIN selCtrl
        SW.CASE feldFilter
            filter$ = GetCtrlData$(feldFilter)
!            ModCtrlCap(felderListe, laskDb_felderLaden$(), 1)
           SW.BREAK
        SW.CASE felderListe
            SPLIT feld$[], GetCtrlData$(felderListe), bcCOLBREAK$
			laskDb_feldInfo(feld$[1])
            if (feld$[2] = vorher$) then
                if(vorher = selCtrl) then
                    goto aktionenListe
                endif
           endif
            vorher$ = feld$[2]
            SW.BREAK
        SW.CASE aktionHinzu
            aktion$ = GetCtrlData$(aktionHinzu)
            rc = SetCtrlData(aktionHinzu, "Aktion hinzufügen")
            ModCtrlData(aktionHinzu, "Aktion hinzufügen", 1)
			gosub aktionBauen
			aktionInfo$[2] = feld$[1]
            aktionInfo$[17] = feldInfo$[5]
            if (aktion$ = "Saat") then
				aktionInfo$[3] = "Saat"
				goto aktionInfo_saat
            elseif (aktion$ = "Bodenbearbeitung") then
				aktionInfo$[3] = "Bodenbearbeitung"
				goto aktionInfo_bodenbearbeitung
            elseif (aktion$ = "Pflanzenschutz") then
				aktionInfo$[3] = "Pflanzenschutz"
				goto aktionInfo_psm
            elseif (aktion$ = "organische Düngung") then
				aktionInfo$[3] = "Organische Düngung"
				goto aktionInfo_duengung
            elseif (aktion$ = "mineralische Düngung") then
				aktionInfo$[3] = "Mineralische Düngung"
				goto aktionInfo_duengung
            elseif (aktion$ = "Ernte") then
				aktionInfo$[3] = "Ernte"
				goto aktionInfo_ernte
            endif
            popup aktion$
        SW.CASE menuKnopf
            menu$ = GetCtrlData$(menuKnopf)
            if (menu$ = "Beenden") then
                EXIT
            else if (menu$ = "Erntejahr") then
				ShowCtrl(jahrWahl, 1)	
            endif
            SW.BREAK
        SW.CASE jahrWahlOk
			if (GetCtrlData$(jahrWahlCombo) <> "") then
				HideCtrl(jahrWahl, 1)
				erntejahr = val(GetCtrlData$(jahrWahlCombo))
				goto felderListe
			endif
			SW.BREAK
        SW.END
        vorher = selCtrl
    REPEAT
return
weiter:
