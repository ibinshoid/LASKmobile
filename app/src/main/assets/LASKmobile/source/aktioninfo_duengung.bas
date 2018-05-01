goto weiter7
aktionInfo_duengung:
gosub aktionInfoTmp

!Dünger
    duenger = AddControl(bcFRMCombobox, _$("Dünger:"),bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            300,20,400,950,100,50, bcDATBOLD$)
    CtrlCap$ = _$("Dünger:")
    for i2 = 1 to length
        if (aktionInfo$[3] = "Organische Düngung") then
            if (mittel$[i2, 4] = "2") then
                CtrlCap$ = CtrlCap$ + bcRECBREAK$ + mittel$[i2, 5]
            endif
        elseif (aktionInfo$[3] = "Mineralische Düngung") then
            if (mittel$[i2, 4] = "3") then
                CtrlCap$ = CtrlCap$ + bcRECBREAK$ + mittel$[i2, 5]
            endif
        endif
    next i2
    rc = SetCtrlCap(duenger, CtrlCap$)
    rc = SetCtrlData(duenger, aktionInfo$[6])
!Menge
    menge = AddControl(bcFRMDisplay, _$("Menge:") + aktionInfo$[7] + "/ha",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            420,20,400,950,100,50, bcDATBOLD$)
    rc = SetCtrlData(menge, aktionInfo$[14])
!DungN
    dungN = AddControl(bcFRMDisplay, "N %:",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            540,20,250,450,100,50, bcDATBOLD$)
    rc = SetCtrlData(dungN, aktionInfo$[8])
!DungM
    dungM = AddControl(bcFRMDisplay, "M %:",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            540,500,250,470,100,50, bcDATBOLD$)
    rc = SetCtrlData(dungM, aktionInfo$[11])
!DungP
    dungP = AddControl(bcFRMDisplay, "P %:",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            660,20,250,450,100,50, bcDATBOLD$)
    rc = SetCtrlData(dungP, aktionInfo$[9])
!DungS
    dungS = AddControl(bcFRMDisplay, "S %:",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            660,500,250,470,100,50, bcDATBOLD$)
    rc = SetCtrlData(dungS, aktionInfo$[12])
!DungK
    dungK = AddControl(bcFRMDisplay, "K %:",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            780,20,250,450,100,50, bcDATBOLD$)
    rc = SetCtrlData(dungK, aktionInfo$[10])
!DungC
    dungC = AddControl(bcFRMDisplay, "C %:",bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
            780,500,250,470,100,50, bcDATBOLD$)
    rc = SetCtrlData(dungC, aktionInfo$[13])

    CALL DrawForm("","")

!MainLoop
    twx = 0
    WHILE twx = 0
        selCtrl=TouchCheck(0,0,0)
        SW.BEGIN selCtrl
        SW.CASE speichernKnopf
            Array.Copy aktionInfo$[], aktAktion$[]
            aktAktion$[4] = GetCtrlData$(datum)
            aktAktion$[6] = GetCtrlData$(duenger)
            aktAktion$[8] = GetCtrlData$(dungN)
            aktAktion$[9] = GetCtrlData$(dungP)
            aktAktion$[10] = GetCtrlData$(dungK)
            aktAktion$[11] = GetCtrlData$(dungM)
            aktAktion$[12] = GetCtrlData$(dungS)
            aktAktion$[13] = GetCtrlData$(dungC)
            aktAktion$[14] = GetCtrlData$(menge)
            aktAktion$[17] = GetCtrlData$(flaeche)
            aktAktion$[18] = GetCtrlData$(kommentar)
            aktAktion$[19] = GetCtrlData$(anwender)
            if (aktAktion$[1] = "-1") then
				laskDb_aktionAnlegen(aktAktion$[])
				goto aktionenListe
			else
				laskDb_aktionAendern(aktAktion$[])
				laskDb_aktionInfo(aktionInfo$[1])
				goto aktionInfo_duengung
			endif
         SW.CASE zurKnopf
            goto aktionenListe
        SW.CASE duenger
            for i2 = 1 to length
                if (mittel$[i2, 5] = GetCtrlData$(duenger)) then
                    aktionInfo$[7] = mittel$[i2, 6]
                endif
            next i2
            ModCtrlCap(menge, _$("Menge:") + aktionInfo$[7] + "/ha", 1)
            W_R.continue
        SW.CASE menge
            ModCtrlZahl(menge, 0, 1)
            SW.BREAK
        SW.CASE dungN
            ModCtrlZahl(dungN, 0, 0)
            SW.BREAK
        SW.CASE dungP
            ModCtrlZahl(dungP, 0, 0)
            SW.BREAK
        SW.CASE dungK
            ModCtrlZahl(dungK, 0, 0)
            SW.BREAK
        SW.CASE dungM
            ModCtrlZahl(dungM, 0, 0)
            SW.BREAK
        SW.CASE dungS
            ModCtrlZahl(dungS, 0, 0)
            SW.BREAK
        SW.CASE dungC
            ModCtrlZahl(dungC, 0, 0)
            SW.BREAK
        SW.CASE kosten
			ModCtrlCap(zahl1, "Dünger", 0)
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


weiter7:
