goto weiter2

aktionenListe:
!Form öffnen
    CALL StartNewForm(DateSize,bcSOUNDOFF$,FrmScale,MsgBoxFontSize,bcLBLUE)
    LET form$ = "aktionenListe"
!Überschrift
    ueberschrift = AddControl(bcFRMDISPLAY, "", bcRED, bcLBLUE, bcWHITE, bcBLUE, ~
            0, 0, 0, 1000, 100, 80, bcDATBOLD$+bcALIGNDATCENTRE$)
    rc = SetCtrlData(ueberschrift, "Feld: " + feld$[2])
!Aktionenliste mitte
    aktionenListe = AddControl(bcFRMLISTBOX,"",bcWHITE,bcLBLUE,bcBLACK,bcWHITE, ~
                110, 10, 0, 980, hoehe-230, 60, bcDATBOLD$+bcNOHEADBOX$+bcLISTVIEW$)
    rc = SetCtrlCap(aktionenListe, ""+bcCOLBREAK$ ~
                +"Id"+bcFLDBREAK$+"0"+bcFLDBREAK$+"1"+bcCOLBREAK$ ~
                +"Datum"+bcFLDBREAK$+"340"+bcFLDBREAK$+"2"+bcCOLBREAK$ ~
                +"Aktion"+bcFLDBREAK$+"639"+bcFLDBREAK$+"1"+bcRECBREAK$+" ")
!Aktion löschen unten links
    entfKnopf = AddControl(bcFRMBUTTON, "Entfernen",bcBLACK,bcLGRAY,0,0, ~
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
        SW.CASE zurKnopf
            goto felderListe
        SW.CASE entfKnopf
            Dialog.Message "Frage", "Aktion '" + aktionInfo$[3] +"' wirklich löschen?\n Alle Daten gehen verloren", button, "Abbrechen", "OK"
            if (button = 2) then
                laskDb_aktionEntfernen(aktionInfo$[1])
                button = -1
                goto aktionenListe
            endif
        SW.END
        vorher = selCtrl
   REPEAT


weiter2:
