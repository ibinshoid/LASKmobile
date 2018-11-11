SQL.OPEN db, "lask.db"

!Protokoll Tabelle anlegen
	SQL.exec db, "CREATE TABLE IF NOT EXISTS 'protokoll' (id INTEGER PRIMARY KEY AUTOINCREMENT," ~
														+"jahr INTEGER," ~
														+"feldid INTEGER," ~
														+"feldname TEXT," ~
														+"aktionid INTEGER," ~
														+"aktionname TEXT," ~
														+"was INTEGER," ~
														+"kommentar TEXT," ~
														+"anwender TEXT)"
                                                    
!Betriebsdaten laden
    SQL.Raw_query dbQuery, db, "select * from 'feldjahr' where jahr = '0';"
    SQL.Next last, dbQuery, columns$[]
	betriebName$ = columns$[3]
	betriebAdresse$ = columns$[4]
	betriebNummer$ = "0" + columns$[5]
                                                    

!Mittel in Arrays schreiben
    i = 0
    length = 0

    SQL.Raw_query dbQuery, db, "SELECT * FROM 'mittel';"
    Sql.Query.Length length, dbQuery
    dim mittel$[length, 12]
    WHILE last = 0
        SQL.Next last, dbQuery, columns$[]
        !Verhindert dass letzter Eintrag doppelt ist
        if (last = 0) then
            !Mittel in array kopieren
            i = i + 1
            Array.Length length2, columns$[]
            for i2 = 1 to length2
                mittel$[i, i2] = columns$[i2]
            next i2
            !Masseinheit schätzen, wenn nicht da
            if (mittel$[i, 4] = "2") then
                if (mittel$[i, 6] = "") then
                    mittel$[i, 6] = "m³"
                endif
            elseif (mittel$[i, 4] = "3") then
                if (mittel$[i, 6] = "") then
                    mittel$[i, 6] = "kg"
                endif
            endif
        endif
    REPEAT

!Erntejahre in Array schreiben
    i = 0
    length2 = 0
    last = 0
    SQL.Raw_query dbQuery, db, "SELECT name FROM sqlite_master WHERE type='table' and name like '2___' ORDER BY name;"
    Sql.Query.Length length2, dbQuery
    dim jahre[length2]
    WHILE last = 0
        SQL.Next last, dbQuery, columns$[]
        !Verhindert dass letzter Eintrag doppelt ist
        if (last = 0) then
			if (is_number(columns$[1])) then
				i = i + 1
				jahre[i] = val(columns$[1])
				ernteJahr = val(columns$[1])
			endif
		endif
    REPEAT

FN.DEF laskDb_felderLaden$(was$)
!Felder aus Datenbank laden
    fn.import db, ernteJahr, bcRECBREAK$, bcCOLBREAK$, bcFLDBREAK$
    felder$ = "" +bcCOLBREAK$ ~
            +"Id"+bcFLDBREAK$+"0"+bcFLDBREAK$+"1"+bcCOLBREAK$ ~
            +_$("Feld")+bcFLDBREAK$+"700"+bcFLDBREAK$+"1"+bcCOLBREAK$ ~
            +_$("Größe")+bcFLDBREAK$+"299"+bcFLDBREAK$+"1"
    undim columns$[]
    last = 0

    SQL.Raw_query dbQuery, db, "select * from 'feldjahr' where jahr = '"+ int$(ernteJahr) +"';"
    WHILE last = 0
        SQL.Next last, dbQuery, columns$[]
        ARRAY.COPY columns$[], feldInfo$[]
        !Verhindert dass letzter Eintrag doppelt ist
        if (last = 0) then
			if ((was$ = _$("Alle")) | (was$ = WORD$(columns$[4], 1, ";")))
				felder$ = felder$ + bcRECBREAK$ + columns$[1] + bcCOLBREAK$ +  columns$[3] + bcCOLBREAK$ +  FORMAT$("#%.##", VAL(columns$[5])) + " ha"
			endif
        endif
    REPEAT
    FN.RTN felder$
FN.END

FN.DEF laskDb_aktionenLaden$(feld$)
!Aktionen aus Datenbank laden
    fn.import db, ernteJahr, bcRECBREAK$, bcCOLBREAK$, bcFLDBREAK$

    aktionen$ ="Feld: "+ feld$ +bcCOLBREAK$ ~
            +"Id"+bcFLDBREAK$+"0"+bcFLDBREAK$+"1"+bcCOLBREAK$ ~
            +_$("Datum")+bcFLDBREAK$+"340"+bcFLDBREAK$+"2"+bcCOLBREAK$ ~
            +_$("Aktion")+bcFLDBREAK$+"659"+bcFLDBREAK$+"1"
    undim columns$[]
    last = 0
    datum$ = ""
    !Alle Aktionen zum Feld in aktionen$ schreiben
    SQL.Raw_query dbQuery, db, "select * from '" + int$(ernteJahr) + "' where feld = '" + feld$ + "' order by datum;"
    WHILE last = 0
        SQL.Next last, dbQuery, columns$[]
        !Verhindert dass letzter Eintrag doppelt ist
        if (last = 0) then
            !Datum formatieren
            columns$[4] = MID$(columns$[4], 9, 2) + "." + MID$(columns$[4], 6, 2) + "." + MID$(columns$[4], 1, 4)
            if (columns$[3] = "Saat") then
				aktionen$ = aktionen$ + bcRECBREAK$ + columns$[1] + bcCOLBREAK$ +  columns$[4] + bcCOLBREAK$ + columns$[3]+" ("+columns$[7]+")"
			elseif (columns$[3] = "Bodenbearbeitung") then
				aktionen$ = aktionen$ + bcRECBREAK$ + columns$[1] + bcCOLBREAK$ +  columns$[4] + bcCOLBREAK$ + columns$[3]+" ("+columns$[6]+")"
			else
				aktionen$ = aktionen$ + bcRECBREAK$ + columns$[1] + bcCOLBREAK$ +  columns$[4] + bcCOLBREAK$ + columns$[3]
			endif
        endif
    REPEAT
    FN.RTN aktionen$
FN.END

FN.DEF laskDb_feldInfo(feld$)
!Array feldInfo$[] mit aktuellem Feld füllen
    fn.import db, ernteJahr, feldInfo$[], bcRECBREAK$, bcCOLBREAK$, bcFLDBREAK$
    undim columns$[]
    last = 0

    SQL.Raw_query dbQuery, db, "select * from 'feldjahr' where id = '" + feld$ + "';"
    WHILE last = 0
        SQL.Next last, dbQuery, columns$[]
        !Verhindert dass letzter Eintrag doppelt ist
        if (last = 0) then
			ARRAY.COPY columns$[], feldInfo$[]
        endif
    REPEAT
FN.END

FN.DEF laskDb_aktionInfo(aktion$)
!Aktion laden
    fn.import db, ernteJahr, aktionInfo$[], bcRECBREAK$, bcCOLBREAK$, bcFLDBREAK$
    last = 0
    UNDIM columns$[]

    SQL.Raw_query dbQuery, db, "select * from '" + int$(ernteJahr) + "' where id = '" + aktion$ + "';"
    WHILE last = 0
        SQL.Next last, dbQuery, columns$[]
        ARRAY.COPY columns$[], aktionInfo$[]
        !Datum formatieren
        aktionInfo$[4] = MID$(aktionInfo$[4], 1, 4) + "-" + MID$(aktionInfo$[4], 6, 2) + "-" + MID$(aktionInfo$[4], 9, 2)
    REPEAT
FN.END

FN.DEF laskDb_aktionEntfernen(aktionId$)
!Aktion löschen
    fn.import db, ernteJahr, aktionInfo$[], feldInfo$[]
!    SQL.DELETE db, "'" + int$(ernteJahr) + "'", ~
!					"id = '" + aktionId$ + "'"
    SQL.UPDATE db, "'" + int$(ernteJahr) + "'", ~
                    "feld", "0": ~
                    "id = '" + aktionId$ + "'"
    SQL.INSERT db, "protokoll", ~
                    "jahr", int$(ernteJahr), ~
                    "feldid", feldInfo$[1], ~
                    "feldname", feldInfo$[3], ~
                    "aktionid", aktionInfo$[1], ~
                    "aktionname", aktionInfo$[3], ~
                    "was", "3", ~
                    "kommentar", "", ~
                    "anwender", ""
    popup "Aktion " + aktionId$ + " wurde gelöscht!"
FN.END

FN.DEF laskDb_aktionAendern(aktAktion$[])
!Aktion Ändern
    fn.import db, ernteJahr, aktionInfo$[], feldInfo$[]
    SQL.UPDATE db, "'" + int$(ernteJahr) + "'", ~
                    "datum", aktAktion$[4], ~
                    "kosten", aktAktion$[5], ~
                    "par1", aktAktion$[6], ~
                    "par2", aktAktion$[7], ~
                    "par3", aktAktion$[8], ~
                    "par4", aktAktion$[9], ~
                    "par5", aktAktion$[10], ~
                    "par6", aktAktion$[11], ~
                    "par7", aktAktion$[12], ~
                    "par8", aktAktion$[13], ~
                    "par9", aktAktion$[14], ~
                    "bbch", aktAktion$[15], ~
                    "schalter", aktAktion$[16], ~
                    "flaeche", aktAktion$[17], ~
                    "kommentar", aktAktion$[18], ~
                    "anwender", aktAktion$[19]: ~
                    "id = '" + aktAktion$[1] + "'"
    SQL.INSERT db, "protokoll", ~
                    "jahr", int$(ernteJahr), ~
                    "feldid", feldInfo$[1], ~
                    "feldname", feldInfo$[3], ~
                    "aktionid", aktAktion$[1], ~
                    "aktionname", aktAktion$[3], ~
                    "was", "2", ~
                    "kommentar", "", ~
                    "anwender", ""
    popup "Aktion " + aktAktion$[1] + " wurde geändert!"
FN.END

FN.DEF laskDb_aktionAnlegen(aktAktion$[])
!Aktion Anlegen
    fn.import db, ernteJahr, aktionInfo$[], feldInfo$[]
    SQL.EXEC db, "INSERT INTO '" + int$(ernteJahr) + "' VALUES (" ~  
                    + "(SELECT 1 + max(id) FROM '" + int$(ernteJahr) +"'),'" ~
                    + aktAktion$[2] + "','" ~
                    + aktAktion$[3] + "','" ~
                    + aktAktion$[4] + "','" ~
                    + aktAktion$[5] + "','" ~
                    + aktAktion$[6] + "','" ~
                    + aktAktion$[7] + "','" ~
                    + aktAktion$[8] + "','" ~
                    + aktAktion$[9] + "','" ~
                    + aktAktion$[10] + "','" ~
                    + aktAktion$[11] + "','" ~
                    + aktAktion$[12] + "','" ~
                    + aktAktion$[13] + "','" ~
                    + aktAktion$[14] + "','" ~
                    + aktAktion$[15] + "','" ~
                    + aktAktion$[16] + "','" ~
                    + aktAktion$[17] + "','" ~
                    + aktAktion$[18] + "','" ~
                    + aktAktion$[19] + "')"

    SQL.EXEC db, "INSERT INTO 'protokoll' VALUES (" ~
                    + "(SELECT 1 + max(id) FROM 'protokoll'),'" ~
                    + int$(ernteJahr) + "','" ~
                    + feldInfo$[1] + "','" ~
                    + feldInfo$[3] + "'," ~
                    + "(SELECT max(id) FROM '" + int$(ernteJahr) + "'),'" ~
                    + aktAktion$[3] + "','" ~
                    + "1" + "','" ~
                    + " " + "','" ~
                    + " " + "')"

    popup _$("Aktion ") + aktAktion$[3] + _$(" wurde hinzugefügt!")
FN.END
