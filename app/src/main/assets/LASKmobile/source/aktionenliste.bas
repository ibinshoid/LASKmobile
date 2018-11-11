goto weiter2

aktionenListe:
!Form öffnen
    CALL StartNewForm(DateSize,bcSOUNDOFF$,FrmScale,MsgBoxFontSize,bcLBLUE)
    LET form$ = "aktionenListe"
!Überschrift
    ueberschrift = AddControl(bcFRMFRAME, betriebName$ + " -> " + int$(ernteJahr) + " -> " +feld$[2] + "   ", bcWHITE, bcBLUE, bcRED, bcLBLUE, ~
            0, 0, 0, 1000, 100, 80, bcCAPBOLD$+bcALIGNRIGHT$)
!Aktionenliste mitte
    aktionenListe = AddControl(bcFRMLISTBOX,"",bcWHITE,bcLBLUE,bcBLACK,bcWHITE, ~
                110, 10, 0, 980, hoehe-230, 60, bcDATBOLD$+bcNOHEADBOX$+bcLISTVIEW$)
    rc = SetCtrlCap(aktionenListe, ""+bcCOLBREAK$ ~
                +"Id"+bcFLDBREAK$+"0"+bcFLDBREAK$+"1"+bcCOLBREAK$ ~
                +_$("Datum")+bcFLDBREAK$+"340"+bcFLDBREAK$+"2"+bcCOLBREAK$ ~
                +_$("Aktion")+bcFLDBREAK$+"639"+bcFLDBREAK$+"1"+bcRECBREAK$+" ")
!Aktion hinzufügen unten rechts
    aktionHinzu = AddControl(bcFRMCOMBOBOX,"",bcGRAY,bcGRAY,bcBLACK,bcWHITE, ~
            hoehe - 110, 320, 0, 670, 100, 80, bcALIGNRIGHT$)
    rc = SetCtrlCap(aktionHinzu,""+ ~
            bcRECBREAK$+_$("Saat")+ ~
            bcRECBREAK$+_$("Bodenbearbeitung")+ ~
            bcRECBREAK$+_$("Pflanzenschutz")+ ~
            bcRECBREAK$+_$("organische Düngung")+ ~
            bcRECBREAK$+_$("mineralische Düngung")+ ~
            bcRECBREAK$+_$("Ernte"))
    rc = SetCtrlData(aktionHinzu, _$("     Hinzufügen"))
!Aktion löschen unten links
    entfKnopf = AddControl(bcFRMBUTTON, _$("Entfernen"),bcBLACK,bcLGRAY,0,0, ~
            hoehe-110, 10, 0, 400, 100, 80, bcALIGNRIGHT$)
!Zurück Knopf oben links
    zurKnopf = AddControl(bcFRMBUTTON, "GC-Back.png",bcBLACK,bcLGRAY,0,0, ~
            0,0,0,100,100,50, bcGRAPHIC$)
    CALL DrawForm("","../data/")
    ModCtrlCap(aktionenListe, laskDb_aktionenLaden$(feld$[1]), 1)

!MainLoop
    twx = 0
    vorher$ = ""
    vorher = -1
    WHILE twx = 0
        selCtrl=TouchCheck(0,0,0)
        SW.BEGIN selCtrl
        SW.CASE aktionenListe
            SPLIT aktion$[], GetCtrlData$(aktionenListe), bcCOLBREAK$
            laskDb_aktionInfo(aktion$[1])
            if (aktion$[1] = vorher$) then
                if(vorher = selCtrl) then
                    if (aktionInfo$[3] = "Saat") then
                        goto aktionInfo_saat
                    elseif (aktionInfo$[3] = "Ernte") then
                        goto aktionInfo_ernte
                    elseif (aktionInfo$[3] = "Organische Düngung") then
                        goto aktionInfo_duengung
                    elseif (aktionInfo$[3] = "Mineralische Düngung") then
                        goto aktionInfo_duengung
                    elseif (aktionInfo$[3] = "Bodenbearbeitung") then
                        goto aktionInfo_bodenbearbeitung
                    elseif (aktionInfo$[3] = "Pflanzenschutz") then
                        goto aktionInfo_psm
                    endif
                endif
            endif
            vorher$ = aktion$[1]
            SW.BREAK
        SW.CASE aktionHinzu
            aktion$ = GetCtrlData$(aktionHinzu)
            rc = SetCtrlData(aktionHinzu, _$("     Hinzufügen"))
			gosub aktionBauen
			aktionInfo$[2] = feld$[1]
            aktionInfo$[17] = feldInfo$[5]
            if (aktion$ = _$("Saat")) then
				aktionInfo$[3] = "Saat"
				goto aktionInfo_saat
            elseif (aktion$ = _$("Bodenbearbeitung")) then
				aktionInfo$[3] = "Bodenbearbeitung"
				goto aktionInfo_bodenbearbeitung
            elseif (aktion$ = _$("Pflanzenschutz")) then
				aktionInfo$[3] = "Pflanzenschutz"
				goto aktionInfo_psm
            elseif (aktion$ = _$("organische Düngung")) then
				aktionInfo$[3] = "Organische Düngung"
				goto aktionInfo_duengung
            elseif (aktion$ = _$("mineralische Düngung")) then
				aktionInfo$[3] = "Mineralische Düngung"
				goto aktionInfo_duengung
            elseif (aktion$ = _$("Ernte")) then
				aktionInfo$[3] = "Ernte"
				goto aktionInfo_ernte
            endif
            popup aktion$
            ModCtrlData(aktionHinzu, _$("     Hinzufügen"), 1)
        SW.CASE zurKnopf
            goto felderListe
        SW.CASE entfKnopf
            Dialog.Message _$("Frage"), _$("Aktion '") + aktionInfo$[3] +_$("' wirklich löschen?\n Alle Daten gehen verloren"), button, _$("Abbrechen"), _$("OK")
            if (button = 2) then
                laskDb_aktionEntfernen(aktionInfo$[1])
                button = -1
                goto aktionenListe
            endif
        SW.END
        vorher = selCtrl
   REPEAT


weiter2:
