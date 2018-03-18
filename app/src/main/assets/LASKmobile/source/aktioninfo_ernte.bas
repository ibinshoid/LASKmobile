goto weiter5
aktionInfo_ernte:
gosub aktionInfoTmp

!Ertrag
    ertrag = AddControl(bcFRMDisplay, _$("Ertrag dt/ha:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            300,20,300,450,100,50, bcDATBOLD$)
    rc = SetCtrlData(ertrag, aktionInfo$[8])
!Feuchte
    feuchte = AddControl(bcFRMDisplay, _$("Feuchte %:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            300,500,300,450,100,50, bcDATBOLD$)
    rc = SetCtrlData(feuchte, aktionInfo$[10])
!Erlös
    erloes = AddControl(bcFRMDisplay, _$("Erlös €/dt:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            420,20,300,450,100,50, bcDATBOLD$)
    rc = SetCtrlData(erloes, aktionInfo$[9])
    CALL DrawForm("","")

!MainLoop
    twx = 0
    WHILE twx = 0
        selCtrl=TouchCheck(0,0,0)
        SW.BEGIN selCtrl
        SW.CASE speichernKnopf
            Array.Copy aktionInfo$[], aktAktion$[]
            aktAktion$[4] = GetCtrlData$(datum)
            aktAktion$[8] = GetCtrlData$(ertrag)
            aktAktion$[9] = GetCtrlData$(erloes)
            aktAktion$[10] = GetCtrlData$(feuchte)
            aktAktion$[17] = GetCtrlData$(flaeche)
            aktAktion$[18] = GetCtrlData$(kommentar)
            aktAktion$[19] = GetCtrlData$(anwender)
            if (aktAktion$[1] = "-1") then
				laskDb_aktionAnlegen(aktAktion$[])
				goto aktionenListe
			else
				laskDb_aktionAendern(aktAktion$[])
				laskDb_aktionInfo(aktionInfo$[1])
				goto aktionInfo_ernte
			endif
        SW.CASE ertrag
            ModCtrlZahl(ertrag, 0, 1)
            SW.BREAK
        SW.CASE feuchte
            ModCtrlZahl(feuchte, 0, 1)
            SW.BREAK
        SW.CASE erloes
            ModCtrlZahl(erloes, 0, 1)
            SW.BREAK
        SW.CASE zurKnopf
            goto aktionenListe
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


weiter5:
