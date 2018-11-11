FILE.exists fi, "../databases/lask.db"
if (fi = 0) then
	byte.open r, fid, "../data/lask.tmp"
	byte.copy fid, "../databases/lask.db"
endif

    ernteJahr = 0
	picPath$ = "../data/"
DIM aktionInfo$[20]
DIM feldInfo$[20]
DIM aktAktion$[20]
BUNDLE.CREATE i18n


INCLUDE gettext.bas
INCLUDE GraphicConstants.bas
INCLUDE GraphicControls.bas
INCLUDE laskdb.bas
INCLUDE felderliste.bas
INCLUDE aktionenliste.bas
INCLUDE aktioninfo.bas
INCLUDE aktioninfo_saat.bas
INCLUDE aktioninfo_ernte.bas
INCLUDE aktioninfo_duengung.bas
INCLUDE aktioninfo_bodenbearbeitung.bas
INCLUDE aktioninfo_psm.bas

goto weiter10
aktionBauen:
	dim aktionInfo$[20]
	dim dateTime$[3]
	
	time dateTime$[1], dateTime$[2], dateTime$[3],,,,,
	aktionInfo$[1] = "-1"
	aktionInfo$[2] = ""
	aktionInfo$[3] = ""
	join dateTime$[], aktionInfo$[4], "-" 
	aktionInfo$[5] = "0,0;0,0;0,0"
	aktionInfo$[8] = "0.0"
	aktionInfo$[9] = "0.0"
	aktionInfo$[10] = "0.0"
	aktionInfo$[11] = "0.0"
	aktionInfo$[12] = "0.0"
	aktionInfo$[13] = "0.0"
	aktionInfo$[14] = "0.0"
	aktionInfo$[15] = "0.0"
	aktionInfo$[16] = "0.0"
	aktionInfo$[17] = "0.0"
return
weiter10:
!Grafikmodus starten
    CALL InitGraphics(bcOPAQUE,bcLGRAY,bcPORTRAIT,bcHIDESTATUSBAR,"")
    gr.screen width, height
    hoehe = 1000/width * height
    CALL SetScalingFactor(1000,1000/width*height,&DateSize,&FrmScale,&MsgBoxFontSize)
	SetCalColours(bcCYAN,bcLBLUE,bcWHITE,bcBLACK,bcLGRAY,bcBLACK,bcWHITE, ~
		bcWHITE,bcLGRAY,bcBLACK,bcYELLOW,bcBLACK,bcLGRAY)
!felderListe starten
    GOTO felderListe
!Tasten abfangen
    OnBackKey:
    Back.resume
GR.CLOSE
Sql.Close db
END ""

