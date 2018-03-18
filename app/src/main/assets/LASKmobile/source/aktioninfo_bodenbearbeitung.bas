goto weiter8
aktionInfo_bodenbearbeitung:
gosub aktionInfoTmp

!Gerät
    geraet = AddControl(bcFRMCOMBOBOX, _$("Gerät:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            300,20,300,950,100,50, bcDATBOLD$ + bcALLOWNEW$)
    CtrlCap$ = _$("Gerät:")
    for i2 = 1 to length
        if (mittel$[i2, 4] = "4") then
             CtrlCap$ = CtrlCap$ + bcRECBREAK$ + mittel$[i2, 5]
        endif
    next i2
    rc = SetCtrlCap(geraet, CtrlCap$)
    rc = SetCtrlData(geraet, aktionInfo$[6])

    CALL DrawForm("","")

!MainLoop
    twx = 0
    WHILE twx = 0
        selCtrl=TouchCheck(0,0,0)
        SW.BEGIN selCtrl
        SW.CASE zurKnopf
            goto aktionenListe
        SW.CASE speichernKnopf
            Array.Copy aktionInfo$[], aktAktion$[]
            aktAktion$[4] = GetCtrlData$(datum)
            aktAktion$[6] = GetCtrlData$(geraet)
            aktAktion$[17] = GetCtrlData$(flaeche)
            aktAktion$[18] = GetCtrlData$(kommentar)
            aktAktion$[19] = GetCtrlData$(anwender)
            if (aktAktion$[1] = "-1") then
				laskDb_aktionAnlegen(aktAktion$[])
				goto aktionenListe
			else
				laskDb_aktionAendern(aktAktion$[])
				laskDb_aktionInfo(aktionInfo$[1])
				goto aktionInfo_bodenbearbeitung
			endif
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

weiter8:
