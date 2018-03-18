goto weiter9
aktionInfo_psm:
gosub aktionInfoTmp

!Mittel Liste laden
    CtrlCap$ = ""
    for i2 = 1 to length
        if (mittel$[i2, 4] = "1") then
            CtrlCap$ = CtrlCap$ + bcRECBREAK$ + mittel$[i2, 5]
        endif
    next i2
!Aktion laden
    DIM PSM$[5]
    SPLIT PSM2$[], REPLACE$(aktionInfo$[7], "||", "~"), ";"
    Array.copy PSM2$[], PSM$[]
!Mittel1
    mittel1 = AddControl(bcFRMCOMBOBOX, "",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            300,20,0,550,100,50, bcDATBOLD$ + bcALLOWNEW$)
    rc = SetCtrlCap(mittel1, CtrlCap$)
    rc = SetCtrlData(mittel1, WORD$(PSM$[1],1, "~"))
!Menge1
    menge1 = AddControl(bcFRMDisplay, _$("Liter:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            300,600,150,370,100,50, bcDATBOLD$)
    rc = SetCtrlData(menge1,  WORD$(PSM$[1],2, "~"))

!Mittel2
    mittel2 = AddControl(bcFRMCOMBOBOX, "",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            420,20,0,550,100,50, bcDATBOLD$ + bcALLOWNEW$)
    rc = SetCtrlCap(mittel2, CtrlCap$)
    rc = SetCtrlData(mittel2, WORD$(PSM$[2],1, "~"))
!Menge2
    menge2 = AddControl(bcFRMDisplay, _$("Liter:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            420,600,150,370,100,50, bcDATBOLD$)
    rc = SetCtrlData(menge2,  WORD$(PSM$[2],2, "~"))

!Mittel3
    mittel3 = AddControl(bcFRMCOMBOBOX, "",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            540,20,0,550,100,50, bcDATBOLD$ + bcALLOWNEW$)
    rc = SetCtrlCap(mittel3, CtrlCap$)
    rc = SetCtrlData(mittel3, WORD$(PSM$[3],1, "~"))
!Menge3
    menge3 = AddControl(bcFRMDisplay, _$("Liter:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            540,600,150,370,100,50, bcDATBOLD$)
    rc = SetCtrlData(menge3,  WORD$(PSM$[3],2, "~"))

!Mittel4
    mittel4 = AddControl(bcFRMCOMBOBOX, "",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            660,20,0,550,100,50, bcDATBOLD$ + bcALLOWNEW$)
    rc = SetCtrlCap(mittel4, CtrlCap$)
    rc = SetCtrlData(mittel4, WORD$(PSM$[4],1, "~"))
!Menge4
    menge4 = AddControl(bcFRMDisplay, _$("Liter:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            660,600,150,370,100,50, bcDATBOLD$)
    rc = SetCtrlData(menge4,  WORD$(PSM$[4],2, "~"))

!Mittel5
    mittel5 = AddControl(bcFRMCOMBOBOX, "",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            780,20,0,550,100,50, bcDATBOLD$ + bcALLOWNEW$)
    rc = SetCtrlCap(mittel5, CtrlCap$)
    rc = SetCtrlData(mittel5, WORD$(PSM$[5],1, "~"))
!Menge5
    menge5 = AddControl(bcFRMDisplay, _$("Liter:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            780,600,150,370,100,50, bcDATBOLD$)
    rc = SetCtrlData(menge5,  WORD$(PSM$[5],2, "~"))

    CALL DrawForm("","")

!MainLoop
    twx = 0
    WHILE twx = 0
        selCtrl=TouchCheck(0,0,0)
        SW.BEGIN selCtrl
        SW.CASE speichernKnopf
            if (GetCtrlData$(mittel1) <> "") then
				psm$ = psm$ + GetCtrlData$(mittel1) + "||" + GetCtrlData$(menge1) + ";"
            endif 
            if (GetCtrlData$(mittel2) <> "") then
				psm$ = psm$ + GetCtrlData$(mittel2) + "||" + GetCtrlData$(menge2) + ";"
            endif 
            if (GetCtrlData$(mittel3) <> "") then
				psm$ = psm$ + GetCtrlData$(mittel3) + "||" + GetCtrlData$(menge3) + ";"
            endif 
            if (GetCtrlData$(mittel4) <> "") then
				psm$ = psm$ + GetCtrlData$(mittel4) + "||" + GetCtrlData$(menge4) + ";"
            endif 
            if (GetCtrlData$(mittel5) <> "") then
				psm$ = psm$ + GetCtrlData$(mittel5) + "||" + GetCtrlData$(menge5) + ";"
            endif
            psm$ = left$(psm$, -1) 
            Array.Copy aktionInfo$[], aktAktion$[]
            aktAktion$[4] = GetCtrlData$(datum)
            aktAktion$[7] = psm$
            aktAktion$[17] = GetCtrlData$(flaeche)
            aktAktion$[18] = GetCtrlData$(kommentar)
            aktAktion$[19] = GetCtrlData$(anwender)
            if (aktAktion$[1] = "-1") then
				laskDb_aktionAnlegen(aktAktion$[])
				goto aktionenListe
			else
				laskDb_aktionAendern(aktAktion$[])
				laskDb_aktionInfo(aktionInfo$[1])
				goto aktionInfo_psm
			endif
        SW.CASE menge1
            ModCtrlZahl(menge1, 0, 1)
            SW.BREAK
        SW.CASE menge2
            ModCtrlZahl(menge2, 0, 1)
            SW.BREAK
        SW.CASE menge3
            ModCtrlZahl(menge3, 0, 1)
            SW.BREAK
        SW.CASE menge4
            ModCtrlZahl(menge4, 0, 1)
            SW.BREAK
        SW.CASE menge5
            ModCtrlZahl(menge5, 0, 1)
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


weiter9:
