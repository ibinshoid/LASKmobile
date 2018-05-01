goto weiter4
aktionInfo_saat:
gosub aktionInfoTmp

!Fruchtart
    frucht = AddControl(bcFRMCOMBOBOX, _$("Fruchtart:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            300,20,300,950,100,50, bcDATBOLD$ + bcALLOWNEW$)
    CtrlCap$ = _$("Fruchtart:")
    for i2 = 1 to length
        if (mittel$[i2, 4] = "0") then
            if (Is_In(mittel$[i2, 6], CtrlCap$) = 0) then
                CtrlCap$ = CtrlCap$ + bcRECBREAK$ + mittel$[i2, 6]
            endif
        endif
    next i2
    rc = SetCtrlCap(frucht, CtrlCap$)
    rc = SetCtrlData(frucht, aktionInfo$[7])
!Sorte
    sorte = AddControl(bcFRMCOMBOBOX, _$("Sorte:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            420,20,300,950,100,50, bcDATBOLD$ + bcALLOWNEW$)
    CtrlCap$ = _$("Sorte:")
    for i2 = 1 to length
        if (mittel$[i2, 4] = "0") then
            if (Is_In(mittel$[i2, 5], CtrlCap$) = 0) then
                if (mittel$[i2, 6] = GetCtrlData$(frucht)) then
                    CtrlCap$ = CtrlCap$ + bcRECBREAK$ + mittel$[i2, 5]
                endif
            endif
        endif
    next i2
    rc = SetCtrlCap(sorte, CtrlCap$)
    rc = SetCtrlData(sorte, aktionInfo$[6])
!Saatmenge
    menge = AddControl(bcFRMDisplay, _$("Saatmenge:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            540,20,300,530,100,50, bcDATBOLD$+bcAlignDatRight$)
!Saateinheit
     einheit= AddControl(bcFRMCOMBOBOX, "",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            540,550,0,420,100,50, bcDATBOLD$)
     SetCtrlCap(einheit,""+bcRECBREAK$+"kg/ha"+bcRECBREAK$+_$("Kö/m²"))
     if (val(aktionInfo$[8]) < 0) then
        rc = SetCtrlData(menge, right$(aktionInfo$[8], -1))
        rc = SetCtrlData(einheit, "kg/ha")
     else
        rc = SetCtrlData(menge, aktionInfo$[8])
        rc = SetCtrlData(einheit, _$("Kö/m²"))
     endif
!Hauptfrucht?
    hauptFrucht = AddControl(bcFRMCHECKBOX, _$("Hauptfrucht:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            660,20,300,500,100,50, bcDATBOLD$)
    if(aktionInfo$[9] = "1") then
        rc=SetCtrlData(hauptFrucht,"Y")
    endif

    CALL DrawForm("","")

!MainLoop
    twx = 0
    WHILE twx = 0
        selCtrl=TouchCheck(0,0,0)
        SW.BEGIN selCtrl
        SW.CASE zurKnopf
            goto aktionenListe
        SW.CASE frucht
            CtrlCap$ = _$("Sorte:")
            for i2 = 1 to length
                if (mittel$[i2, 4] = "0") then
                    if (Is_In(mittel$[i2, 5], CtrlCap$) = 0) then
                        if (mittel$[i2, 6] = GetCtrlData$(frucht)) then
                            CtrlCap$ = CtrlCap$ + bcRECBREAK$ + mittel$[i2, 5]
                        endif
                    endif
                endif
            next i2
            ModCtrlCap(sorte, CtrlCap$, 1)
            W_R.continue
        SW.CASE menge
            ModCtrlZahl(menge, 0, 1)
            W_R.continue
        SW.CASE speichernKnopf
            Array.Copy aktionInfo$[], aktAktion$[]
            aktAktion$[4] = GetCtrlData$(datum)
            aktAktion$[6] = GetCtrlData$(sorte)
            aktAktion$[7] = GetCtrlData$(frucht)
            if (GetCtrlData$(einheit) = "kg/ha") then
                aktAktion$[8] = STR$(0-VAL(GetCtrlData$(menge)))
            else
                aktAktion$[8] = GetCtrlData$(menge)
            endif
            if (GetCtrlData$(hauptFrucht) = "Y") then
                aktAktion$[9] = "1"
            else
                aktAktion$[9] = "0"
            endif
            aktAktion$[17] = GetCtrlData$(flaeche)
            aktAktion$[18] = GetCtrlData$(kommentar)
            aktAktion$[19] = GetCtrlData$(anwender)
            if (aktAktion$[1] = "-1") then
				laskDb_aktionAnlegen(aktAktion$[])
				goto aktionenListe
			else
				laskDb_aktionAendern(aktAktion$[])
				laskDb_aktionInfo(aktionInfo$[1])
				goto aktionInfo_saat
			endif
        SW.CASE kosten
			ModCtrlData(zahl1, "Saatgut", 0)
            ModCtrlKosten(kosten, 0, 1)
            W_R.continue
        SW.CASE flaeche
            ModCtrlZahl(flaeche, 0, 1)
	        if (val(GetCtrlData$(flaeche)) > val(feldInfo$[5])) then
				ModCtrlData(flaeche, feldInfo$[5], 1)
	        endif
            SW.BREAK
        SW.CASE kommentar
            TEXT.Input text$, GetCtrlData$(kommentar), _$("Kommentar:")
            ModCtrlData(kommentar, text$, 1)
            W_R.continue
        SW.CASE datum
            ModCtrlData(datum2, MID$(GetCtrlData$(datum), 9, 2)+"."+MID$(GetCtrlData$(datum), 6, 2)+"."+MID$(GetCtrlData$(datum), 1, 4), 1)
            W_R.continue
        SW.END
    REPEAT


weiter4:
