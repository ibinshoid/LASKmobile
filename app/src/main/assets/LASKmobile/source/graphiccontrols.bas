!=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
!#~~~~Start_GraphicControls.bas~~~~=
!=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
GCVer$="v1.17"
!!
* Bug Fixed - bcCHECKRIGHT$ - databorder drawn incorrectly.
* Bug Fixed - bcPICCROP$ draw position not scaled.
* Added new function "SetCtrlFontSize(pctrlno,pval)".
* Frame controls and combobox controls dropdown lists now automatically
  have their z-order changed whenever they are made visible so they 
  appear (with their contents) as the top most graphic. 
* Added 4 new functions - "setctrlcaptxtclr(pctrlno,pcolour)",
  "setctrlcapbakclr(pctrlno,pcolour)","setctrldattxtclr(pctrlno,pcolour)"
  and "setctrldatbakclr(pctrlno,pcolour)". Used to alter a controls
  colours the next time it is drawn/rendered.
* Added new Shape option - "rndrect" - draws a Rectangle with rounded
  corners.
* Added Quickmove Menu to Listbox control - click the three virtical
  dots above scroll bar to access a dropdown menu to jump to first, last, 
  etc., list entry. 
* Added new Button control style bcROUND$. Causes button to be drawn with
  a semi-circle at each end. If control width set correctly it can result
  in a round button being drawn. It works with the existing styles like 
  bcFLAT$, bcNOBORDER$, etc. if required.
* The style "bcMENULIST$" can now be applied to Buttons (results in a 
  dropdown list being shown when button clicked) and ComboBox controls.
  In both cases the dropdown list can now be customised at the time the
  control is touched (see below).
* Added new Constants:
  Control ID:
  LET bcMSGMENUCTRL=1082   - Either a physical Menu key or a Button control
                             with style bcMENUBTN$ pressed.
  Message IDs:
  LET bcMSGMENUSET=1582    - Sent by Graphic Controls routine
                             allowing Menu droplist list contents to be
                             reset via a SetCtrlCap() command before the
                             touch processing is actioned.
                             Previous value was 2082. New value assigned
                             to avoid possible duplicate message IDs when
                             bcMSGSETLIST used in conjuction with a Button
                             or Combobox control.                                  
  LET bcMSGSETLIST=2000    - Same processing as bcMSGMENUSET but for Button
                             or Combobox controls with style bcMENULIST$. 
  LET bcMSGMULTIUPDT=3000  - Sent when a multi-line listbox has been updated
                             by Graphic Controls processing.
  LET bcMSGCHECKCLICK=4000 - Sent when a Listbox "Listview" Check box has
                             been clicked.
  LET bcMSGCOLSORT=5000    - Sent when a Listbox "Listview" has been sorted
  LET bcMSGPICSCROLL=6000  - Sent when a Picture control has been scrolled.
  Usage Example:
     SW.CASE cmdNamesButton
          -----            - Normal button Processing. If style bcMENULIST$
          -----              applied retrieve selected value via CtrlGetData$
          -----              call.
          SW.BREAK
     SW.CASE cmdNamesButton+bcMSGSETLIST
          -----            - The dropdown list contents can be reset if
          -----              required via SetCtrlCap() call.
          SW.BREAK
  Note: The "cmdNamesButton+bcMSGSETLIST" code is optional. If dropdown list
        content is not required to change then there is no need to process
        or code for this message.
!!

!#@#@#@#_core_components

GOTO @CreateStorage
!
@getcontroldata:
!==============
BUNDLE.GET 1,"ctrldata",ctrldata
BUNDLE.GET ctrldata,"CP"+STR$(ctrlID),ptrctrl
BUNDLE.GET ptrctrl,"type",ctrltype
BUNDLE.GET ptrctrl,"origcap",ctrlorigcap$
BUNDLE.GET ptrctrl,"sizecap",ctrlsizecap$
BUNDLE.GET ptrctrl,"datalst",ctrldatalst
BUNDLE.GET ptrctrl,"captxtclr",ctrlcaptxtclr
BUNDLE.GET ptrctrl,"capbakclr",ctrlcapbakclr
BUNDLE.GET ptrctrl,"dattxtclr",ctrldattxtclr
BUNDLE.GET ptrctrl,"datbakclr",ctrldatbakclr
BUNDLE.GET ptrctrl,"top",ctrltop
BUNDLE.GET ptrctrl,"left",ctrlleft
BUNDLE.GET ptrctrl,"middle",ctrlmiddle
BUNDLE.GET ptrctrl,"width",ctrlwidth
BUNDLE.GET ptrctrl,"height",ctrlheight
BUNDLE.GET ptrctrl,"font",ctrlfont
BUNDLE.GET ptrctrl,"style",ctrlstyle$
BUNDLE.GET ptrctrl,"captxtobj",ctrlcaptxtobj
BUNDLE.GET ptrctrl,"capbakobj",ctrlcapbakobj
BUNDLE.GET ptrctrl,"data",ctrldata$
BUNDLE.GET ptrctrl,"dattxtobj",ctrldattxtobj
BUNDLE.GET ptrctrl,"datbakobj",ctrldatbakobj
BUNDLE.GET ptrctrl,"state",ctrlstate$
BUNDLE.GET ptrctrl,"frame",ctrlframe
BUNDLE.GET ptrctrl,"firstgrptr",ctrlfirstgrptr
BUNDLE.GET ptrctrl,"lastgrptr",ctrllastgrptr
RETURN
!
@getcontrolcoords:
!================
BUNDLE.GET 1,"ctrldata",ctrldata
BUNDLE.GET ctrldata,"CP"+STR$(ctrlID),ptrctrl
BUNDLE.GET ptrctrl,"type",ctrltype
BUNDLE.GET ptrctrl,"top",ctrltop
BUNDLE.GET ptrctrl,"left",ctrlleft
BUNDLE.GET ptrctrl,"width",ctrlwidth
BUNDLE.GET ptrctrl,"height",ctrlheight
BUNDLE.GET ptrctrl,"style",ctrlstyle$
BUNDLE.GET ptrctrl,"state",ctrlstate$
RETURN
!
@DrawColumns:
!===========
FOR cn=2 TO lbcolcnt
 UNDIM  hwa$[]
 SPLIT.ALL hwa$[],cd$[cn],bcFLDBREAK$
 LET w=VAL(hwa$[2])
 IF lx+w<ctrlleft+ctrlwidth | lx>ctrlleft+ctrlwidth THEN
  GR.CLIP gonum,lx,ly,lx+w-3,ly+rowheight,2
  IF lx>ctrlleft+ctrlwidth THEN LET clipoff=1000
 ELSE
  GR.CLIP gonum,lx,ly,ctrlleft+ctrlwidth-3,y+rowheight,2
 ENDIF
 LET a=VAL(hwa$[3])
 IF rn=0 THEN
  LET h$=hwa$[1]
  LET textcolor=ctrlcapbakclr
 ELSE
  LET h$=""
  LET textcolor=ctrldattxtclr
 ENDIF
 IF a=2 THEN
  GR.TEXT.ALIGN 2
  LET cx=lx+(w/2)
 ELSEIF a=3 THEN
  LET cx=lx+w-xo
  GR.TEXT.ALIGN 3
 ELSE
  LET cx=lx+xo
  GR.TEXT.ALIGN 1
 ENDIF
 GR.COLOR bcOPAQUE,BCMP[textcolor],GCMP[textcolor],RCMP[textcolor],bcFILL
 GR.TEXT.DRAW gonum,cx+clipoff,ly+fo,h$
 IF rn>0 & cn=2 THEN
  LIST.ADD lbtxtobj,gonum
 ENDIF
 LET lx=lx+w
NEXT cn
GR.CLIP gonum,ctrlleft,ctrltop,cright,cbottom,2
IF rn=0 THEN
 GR.TEXT.ALIGN 1
 GR.COLOR bcOPAQUE,BCMP[ctrlcapbakclr],GCMP[ctrlcapbakclr],RCMP[ctrlcapbakclr],bcFILL
 GR.GET.TEXTBOUNDS "^", l, t, r, b
 GR.ROTATE.START 0,cright+100,ly-t/2,gonum1
 GR.TEXT.DRAW gonum,cright+100,ly-t+3,"^"
 GR.ROTATE.END
 BUNDLE.PUT ptrctrl,"lbhdrmark",gonum1
 BUNDLE.PUT ptrctrl,"lbhdrord",180
ENDIF
RETURN
!
@LoadRGBData:
!===========
BUNDLE.GET 1,"RCMP",lrcmp
BUNDLE.GET 1,"GCMP",lgcmp
BUNDLE.GET 1,"BCMP",lbcmp
UNDIM RCMP[]
UNDIM GCMP[]
UNDIM BCMP[]
LIST.TOARRAY lrcmp,RCMP[]
LIST.TOARRAY lgcmp,GCMP[]
LIST.TOARRAY lbcmp,BCMP[]
RETURN
!
@AdjFntSize:
!==========
LET fs=ctrlfont
LET fw=cright-cmiddle-(fs/2)
LET bfits=0
DO
 GR.TEXT.SIZE fs
 GR.TEXT.WIDTH tw,stext$
 IF tw<fw THEN
  D_U.BREAK
 ELSE
  IF fs<7 THEN
   D_U.BREAK
  ELSE
   LET fs=fs-1
  ENDIF
 ENDIF
UNTIL bfits=1
RETURN
!
@UpdtVScrollBar:
!===============
LET bcOPAQUE=255
LET bcTRANSPARENT=0
IF lbdatacnt>rowcount THEN
 BUNDLE.GET ptrctrl,"vscrstop",scrolltop
 BUNDLE.GET ptrctrl,"vscrsbot",scrollheight
 BUNDLE.GET ptrctrl,"vscrslidebak",slidebakptr
 LET scrollrange=lbdatacnt-rowcount-1
 IF scrollrange=0 THEN LET scrollrange=1
 LET slideheight=(scrollheight*rowcount)/(lbdatacnt-1)
 IF slideheight<12 THEN LET slideheight=12
 LET slidemove=scrollheight-slideheight
 LET slidetop=scrolltop+((slidemove*(curstart-2))/(scrollrange))
 LET lalpha=bcOPAQUE
 GR.MODIFY slidebakptr,"top",slidetop,"bottom",slidetop+slideheight
 GR.MODIFY slidebakptr+1,"top",slidetop+5,"bottom",slidetop+slideheight-5
 IF IS_IN(bcNOBORDER$,ctrlstyle$)=0 THEN
  BUNDLE.GET ptrctrl,"vscrslidebdr",slidebdrptr
  GR.MODIFY slidebdrptr,"top",slidetop,"bottom",slidetop+slideheight
  GR.MODIFY slidebdrptr+1,"top",slidetop+5,"bottom",slidetop+slideheight-5
 ENDIF
 BUNDLE.PUT ptrctrl,"lbprevcap",ctrlsize$
ELSE
 LET lalpha=bcTRANSPARENT
ENDIF
BUNDLE.GET ptrctrl,"vscrfirstobj",firstscrollobj
BUNDLE.GET ptrctrl,"vscrlastobj",lastscrollobj
FOR i=firstscrollobj TO lastscrollobj
 GR.MODIFY i,"alpha",lalpha
NEXT i
RETURN
!
@SBR_GetColClicked:
!=================
BUNDLE.GET ptrctrl,"sizecap",cdata$
UNDIM cval$[]
SPLIT.ALL cval$[],cdata$,bcCOLBREAK$
ARRAY.LENGTH ccnt,cval$[]
LET hdrX=pctrlleft
IF IS_IN(bcCHECKBOX$,pctrlstyle$)<>0 THEN LET hdrX=hdrX+rowheight
IF IS_IN(bcFILEDIALOG$,pctrlstyle$)<>0 THEN LET hdrX=hdrX+rowheight
LET pcolclicked=0
FOR a=2 TO ccnt
 SPLIT.ALL cdtl$[],cval$[a],bcFLDBREAK$
 LET hdrX=hdrX+VAL(cdtl$[2])
 IF px<hdrX | a=ccnt+1 THEN
  LET pcolclicked=a-1
  F_N.BREAK
 ENDIF
 UNDIM cdtl$[]
NEXT a
RETURN
!
@SBR_DrawBinocs:
!==============
dy=ctrlfont
ARRAY.LOAD paQ[],4,0, 8,0, 8,4, 4,4, 4,0, 4,4, 0,dy-4, 0,dy, 12,dy, 12,dy-4 ,0,dy-4 ,12, dy-4, 8,4
LIST.CREATE n,qptr
LIST.ADD.ARRAY qptr,paQ[]
GR.COLOR lAlph,BCMP[bcol],GCMP[bcol],RCMP[bcol],bcNOFILL
GR.POLY gonum,qptr,qx,qy
GR.POLY gonum,qptr,qx+16,qy
dy=ctrlfont/3
GR.RECT gonum4,qx+6,qy+dy,qx+22,qy+dy+dy
RETURN
!
@SetPicMarkCoords:
!================
IF ps=1 THEN 
 px=-40:py=cheight+20
ELSEIF ps=2 THEN 
 px=(cwidth/2)-10:py=cheight+20
ELSEIF ps=3 THEN 
 px=cwidth+20:py=cheight+20
ELSEIF ps=4 THEN 
 px=-40:py=(cheight/2)-10
ELSEIF ps=5 THEN 
 px=cwidth+20:py=(cheight/2)-10
ELSEIF ps=6 THEN 
 px=-40:py=-40
ELSEIF ps=7 THEN 
 px=(cwidth/2)-10:py=-40
ELSE
 px=cwidth+20:py=-40
ENDIF
ml=cLeft+u+px:mt=cTop+v+py:mr=cLeft+u+px+20:mb=cTop+v+py+20
pl=cLeft+u:pt=cTop+v:pr=cLeft+cWidth+u:pb=cTop+cHeight+v
RETURN
!
KeyRoutine:
!=========
bcBLANK$="--Blank--"
IF inptext$=bcBLANK$ THEN
 LET inptext$=""
 bl=1
ELSE
 bl=0
ENDIF
Input inpheader$,inptext$,inptext$,cn
IF cn<>0 THEN
 LET inptext$=bcCOLBREAK$
ELSEIF inptext$="" & bl=1 THEN
 LET inptext$=bcBLANK$
ENDIF
RETURN
!
@CreateStorage:
!-------------
BUNDLE.CREATE ptrbase
BUNDLE.PUT 1,"GraphicsOpen",0
BUNDLE.PUT 1,"DateSize",datesize
BUNDLE.CREATE ctrldata
BUNDLE.PUT 1,"ctrldata",ctrldata
BUNDLE.PUT 1,"vkeyb",0
BUNDLE.PUT 1,"GCVer",GCVer$
LIST.CREATE N,LstRCMP
LIST.CREATE N,LstGCMP
LIST.CREATE N,LstBCMP
FOR i=1 TO 19
 LIST.ADD LstRCMP,FLOOR(bcRGBCOLOR[i]/65536)
 LET lTemp=MOD(bcRGBCOLOR[i],65536)
 LIST.ADD LstGCMP,FLOOR(ltemp/256)
 LIST.ADD LstBCMP,MOD(ltemp,256)
NEXT i
BUNDLE.PUT 1,"RCMP",LstRCMP
BUNDLE.PUT 1,"GCMP",LstGCMP
BUNDLE.PUT 1,"BCMP",LstBCMP
!BUNDLE.PUT 1,"scrollbar",400
BUNDLE.PUT 1,"scrollbar",Scrollbar
!
!  I N I T _ G R A P H I C S
!
FN.DEF initgraphics(palpha,pcolor,porientation,pstatusbar,pSoundFile$)
 LET bcBLACK=1
 LET bcBLUE=2
 LET bcCYAN=4
 LET bcMAGENTA=6
 LET bcYELLOW=7
 LET bcLGRAY=9
 LET bcLBLUE=10
 LET bcLGREEN=11
 LET bcLCYAN=12
 LET bcLMAGENTA=14
 LET bcWHITE=16
 GOSUB @LoadRGBData
 BUNDLE.GET 1,"GraphicsOpen",bgraphicsopen
 IF bgraphicsopen=0 THEN
  GR.OPEN palpha,BCMP[pcolor],GCMP[pcolor],RCMP[pcolor],pstatusbar,porientation
  LET bgraphicsopen=1
  GR.SCREEN swidth,sheight
  BUNDLE.PUT 1,"GraphicsOpen",1
  BUNDLE.PUT 1,"swidth",swidth
  BUNDLE.PUT 1,"sheight",sheight
  BUNDLE.PUT 1,"frmscale",1
  BUNDLE.CREATE bmpobjlist
  BUNDLE.PUT 1,"bmpobjlist",bmpobjlist
  BUNDLE.PUT 1,"frmscale",1
  BUNDLE.PUT 1,"dwidth",swidth
  BUNDLE.PUT 1,"dheight",sheight
  BUNDLE.PUT 1,"hourglass","Y"
  BUNDLE.PUT 1,"hourglassdrawn",0
  BUNDLE.PUT 1,"calendardrawn",0
  BUNDLE.PUT 1,"kbdlang","US"
  LIST.CREATE S,fpc
  LIST.ADD fpc,"1","2","3","4","&","[","{",":",","
  BUNDLE.PUT 1,"capfonts",fpc
  LIST.CREATE S,fpd
  LIST.ADD fpd,"5","6","7","8","!","]","}",";","."
  BUNDLE.PUT 1,"datfonts",fpd
  LIST.CREATE N,fp
  LIST.ADD fp,1,2,3,4,1,1,1,1,1
  BUNDLE.PUT 1,"fontptrs",fp
  BUNDLE.PUT 1,"fontcnt",4
  LET SndPtr=0
  IF pSoundFile$<>"" THEN
   FILE.EXISTS i,pSoundFile$
   IF i<>0 THEN
    AUDIO.LOAD SndPtr,pSoundFile$
   ENDIF
  ENDIF
  BUNDLE.PUT 1,"sndptr",sndptr
  BUNDLE.PUT 1,"comstyles",""
  CALL setmsgboxcolours(bcBLUE,bcWHITE,bcLBLUE,bcLGRAY,bcWHITE,bcBLACK,bcBLACK)
  CALL setcalcolours(bcCYAN,bcLBLUE,bcWHITE,bcBLACK,bcLMAGENTA,bcMAGENTA,bcLGREEN, ~
     bcWHITE,bcCYAN,bcBLACK,bcYELLOW,bcBLACK,bcLBLUE)
  BUNDLE.PUT 1,"whitespace", ~
     " !"+bcPOUNDSIGN$+"$%^&*()_-+={[}]:;@'~#,./<>?|"+bcDBLQUOTE$+bcBACKSLASH$+bcNOTSIGN$
 ENDIF
 FN.RTN 0
FN.END
!
!  S E T _ S C A L I N G _ F A C T O R
!
FN.DEF setscalingfactor(dwidth,dheight,datesize,frmscale,msgboxfontsize)
 BUNDLE.GET 1,"swidth",swidth
 BUNDLE.GET 1,"sheight",sheight
 IF dwidth>dheight THEN
  LET frmscale=dwidth/swidth
  LET lheight=dheight/frmscale
  WHILE lheight>sheight
   LET frmscale=frmscale+0.01
   LET lheight=dheight/frmscale
  REPEAT
 ELSE
  LET frmscale=dheight/sheight
  LET lwidth=dwidth/frmscale
  WHILE lwidth>swidth
   LET frmscale=frmscale+0.01
   LET lwidth=dwidth/frmscale
  REPEAT
 ENDIF
 BUNDLE.PUT 1,"frmscale",frmscale
 BUNDLE.PUT 1,"dwidth",dwidth
 BUNDLE.PUT 1,"dheight",dheight
 LET datesize=swidth/8
 IF datesize>60 THEN LET datesize=60
 LET msgboxfontsize=18/frmscale
 BUNDLE.GET 1,"scrollbar",i
 BUNDLE.PUT 1,"sbwidth",i/frmscale
 FN.RTN 0
FN.END
!
!  S T A R T _ N E W _ F O R M
!
FN.DEF startnewform(pdatesize,psound$,pfrmscale,pmsgboxfontsize,pfrmcolour)
 CALL deletebitmaps()
 BUNDLE.PUT 1,"ctrlcount",0
 BUNDLE.PUT 1,"DateSize",pdatesize
 BUNDLE.PUT 1,"lastframe",0
 BUNDLE.PUT 1,"FrmObjCnt",1
 BUNDLE.PUT 1,"lastdrawn",0
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.CLEAR ctrldata
 BUNDLE.CREATE ctrldata
 BUNDLE.PUT 1,"ctrldata",ctrldata
 BUNDLE.PUT 1,"calendardrawn",0
 BUNDLE.PUT 1,"msgboxdrawn",0
 BUNDLE.PUT 1,"hourglassdrawn",0
 BUNDLE.PUT 1,"inpdrawn",0
 BUNDLE.PUT 1,"sound",LEFT$(psound$,1)
 BUNDLE.PUT 1,"frmscale",pfrmscale
 BUNDLE.PUT 1,"msgboxfont",pmsgboxfontsize
 BUNDLE.PUT 1,"frmcolour",pfrmcolour
 BUNDLE.PUT 1,"frmmenu",0
 BUNDLE.PUT 1,"picpath",""
 BUNDLE.PUT 1,"tchcnt",0
 FN.RTN 0
FN.END
!
!  A D D T O _ B M P _ L I S T
!
FN.DEF @AddToBmpList(pType$,pCtrlPtr,pBmpPtr)
 LET key$=pType$+"-"+INT$(pCtrlPtr)
 BUNDLE.GET 1,"bmpobjlist",bmpobjlist
 BUNDLE.CONTAIN bmpobjlist,key$,i
 IF i<>0 THEN
  BUNDLE.GET bmpobjlist,key$,j
  IF j<>-1 THEN GR.BITMAP.DELETE j
 ENDIF
 BUNDLE.PUT bmpobjlist,key$,pBmpPtr
 FN.RTN 0
FN.END
!
!  D E L E T E _ B I T M A P S
!
FN.DEF deletebitmaps()
 BUNDLE.GET 1,"bmpobjlist",bmpobjlist
 BUNDLE.KEYS bmpobjlist,keylist
 LIST.SIZE keylist,size
 IF size>0 THEN
  FOR i=1 TO size
   LIST.GET keylist,i,key$
   BUNDLE.GET bmpobjlist,key$,bmpptr
   IF bmpptr<>-1 THEN GR.BITMAP.DELETE bmpptr
  NEXT i
  BUNDLE.CLEAR bmpobjlist
 ENDIF
 FN.RTN 0
FN.END
!
!  S E T _ C O M M O N _ S T Y L E S
!
FN.DEF SetCommonStyles(pStyles$)
 BUNDLE.PUT 1,"comstyles",pStyles$
 FN.RTN 0
FN.END
!
!  A D D _ C O N T R O L
!
FN.DEF addcontrol(ptype,pcaption$,pcaptxtcol,pcapbakcol,pdattxtcol,pdatbakcol,ptop,pleft, ~
       pmiddle,pwidth,pheight,pfont,pstyle$)
 LET bcFRMBUTTON=6
 LET bcFRMPICTURE=7
 LET bcFRMLISTBOX=9
 LET bcFRMCHECKBOX=10
 LET bcFRMFRAME=13
 LET bcFRMSHAPE=14
 LET bcFRMCOMBOBOX=15
 LET bcFRMTIME=16
 LET bcLISTVIEW$="v"
 LET bcCTRLLEFT$="m"
 LET bcCTRLCENTRE$="d"
 LET bcCTRLRIGHT$="s"
 LET bcHHMMONLY$="h"
 LET bcNOBORDER$="-"
 LET bcHIDEGRID$="g"
 LET bcMULTILINE$="="
 LET bcMENUBTN$="W"
 LET bcMENULIST$="w"
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 BUNDLE.GET 1,"dwidth",dwidth
 BUNDLE.GET 1,"frmscale",frmscale
 BUNDLE.GET 1,"comstyles",comstyles$
 LET ltop=ptop
 LET lleft=pleft
 LET lwidth=pwidth
 LET lheight=pheight
 IF IS_IN(bcCTRLCENTRE$,pstyle$)<>0 THEN
  LET lleft=(dwidth-lwidth)/2
 ELSEIF IS_IN(bcCTRLLEFT$,pstyle$)<>0 THEN
  LET lleft=dwidth/2-lleft-lwidth
 ELSEIF IS_IN(bcCTRLRIGHT$,pstyle$)<>0 THEN
  LET lleft=dwidth/2+lleft
 ENDIF
 IF ptype=bcFRMTIME THEN
  IF IS_IN(bcHHMMONLY$,pstyle$)<>0 THEN
   LET i=6
   LET dv$="12:00"
  ELSE
   LET i=7
   LET dv$="12:00:00"
  ENDIF
  LET lwidth=(pmiddle+(i*pheight))
 ELSEIF ptype=bcFRMCHECKBOX THEN
  LET dv$="N"
 ELSE
  LET dv$=""
 ENDIF
 LET menuCtrl=0
 IF IS_IN(bcMENULIST$,pstyle$)<>0 THEN
  IF ptype=bcFRMCOMBOBOX | ptype=bcFRMBUTTON THEN
   IF IS_IN(bcMENUBTN$,pstyle$)<>0 THEN LET menuCtrl=1
  ELSE
   LET pStyle$=REPLACE$(pStyle$,bcMENULIST$,"")
  ENDIF
 ENDIF
 BUNDLE.CREATE ptrctrl
 BUNDLE.PUT ptrctrl,"type",ptype
 BUNDLE.PUT ptrctrl,"captxtclr",pcaptxtcol
 BUNDLE.PUT ptrctrl,"capbakclr",pcapbakcol
 BUNDLE.PUT ptrctrl,"dattxtclr",pdattxtcol
 BUNDLE.PUT ptrctrl,"datbakclr",pdatbakcol
 BUNDLE.PUT ptrctrl,"top",ltop/frmscale
 BUNDLE.PUT ptrctrl,"left",lleft/frmscale
 BUNDLE.PUT ptrctrl,"width",lwidth/frmscale
 BUNDLE.PUT ptrctrl,"height",lheight/frmscale
 IF ptype=bcFRMSHAPE THEN LET fs=pfont ELSE LET fs=pfont/frmscale
 BUNDLE.PUT ptrctrl,"style",pstyle$+comstyles$
 BUNDLE.PUT ptrctrl,"captxtobj",0
 BUNDLE.PUT ptrctrl,"capbakobj",0
 BUNDLE.PUT ptrctrl,"data",dv$
 BUNDLE.PUT ptrctrl,"dattxtobj",0
 BUNDLE.PUT ptrctrl,"datbakobj",0
 BUNDLE.PUT ptrctrl,"state","x"
 BUNDLE.PUT ptrctrl,"frame",0
 BUNDLE.PUT ptrctrl,"firstgrptr",0
 BUNDLE.PUT ptrctrl,"lastgrptr",0
 BUNDLE.PUT ptrctrl,"pressx",0
 BUNDLE.PUT ptrctrl,"pressy",0
 BUNDLE.PUT ptrctrl,"qndrawn",0
 BUNDLE.GET 1,"ctrlcount",ctrlcount
 LET ctrlcount=ctrlcount+1
 BUNDLE.PUT 1,"ctrlcount",ctrlcount
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.PUT ctrldata,"CP"+STR$(ctrlcount),ptrctrl
 LIST.CREATE s,datalst
 LIST.ADD datalst,""
 BUNDLE.PUT ptrctrl,"datalst",datalst
 IF ptype=bcFRMLISTBOX THEN
  IF pmiddle=0 THEN LET pmiddle=pfont+(pfont/2)
  BUNDLE.PUT ptrctrl,"lbhdrcol",1
  LIST.CREATE s,lbbmpname
  LIST.ADD lbbmpname,"Name1"
  BUNDLE.PUT ptrctrl,"lbbmpname",lbbmpname
  LIST.CREATE s,lbchecked
  LIST.ADD lbchecked,"[_]"
  BUNDLE.PUT ptrctrl,"lbchecked",lbchecked
  BUNDLE.PUT ptrctrl,"rowcount",0
 ENDIF
 IF ptype=bcFRMPICTURE | ptype=bcFRMLISTBOX THEN
  BUNDLE.PUT ptrctrl,"picvscr",0
  BUNDLE.PUT ptrctrl,"pichscr",0
  IF ptype=bcFRMPICTURE THEN
   BUNDLE.PUT ptrctrl,"picsbwx",0
   BUNDLE.PUT ptrctrl,"picsbwy",0
   BUNDLE.PUT ptrctrl,"picxoff",0
   BUNDLE.PUT ptrctrl,"picyoff",0
   BUNDLE.PUT ptrctrl,"picangle",0
   BUNDLE.PUT ptrctrl,"picmark",0
   IF pmiddle=0 THEN LET pmiddle=1
   IF pfont=0 THEN LET pfont=20
  ENDIF
 ENDIF
 IF ptype=bcFRMFRAME THEN
  IF pmiddle=0 THEN LET pmiddle=pfont+(pfont/2)
  BUNDLE.PUT 1,"lastframe",ctrlcount
  BUNDLE.PUT 1,"frametop",ltop
  BUNDLE.PUT 1,"frameleft",lleft
  BUNDLE.PUT 1,"framewidth",lwidth
  BUNDLE.PUT 1,"frameheight",lheight
 ELSE
  BUNDLE.GET 1,"lastframe",ctrlID
  IF ctrlID>0 THEN
   BUNDLE.GET 1,"frametop",ftop
   BUNDLE.GET 1,"frameleft",fleft
   BUNDLE.GET 1,"framewidth",fwidth
   BUNDLE.GET 1,"frameheight",fheight
   IF ltop>=ftop & lleft>=fleft & lleft+lwidth<=fleft+fwidth & ltop+lheight<=ftop+fheight THEN
    BUNDLE.PUT ptrctrl,"frame",ctrlID
    BUNDLE.GET ctrldata,"CP"+STR$(ctrlID),fractrl
    BUNDLE.PUT fractrl,"fralastctrl",ctrlcount
   ENDIF
  ENDIF
 ENDIF
 BUNDLE.PUT ptrctrl,"middle",pmiddle/frmscale
 BUNDLE.PUT ptrctrl,"font",pfont/frmscale
 CALL setctrlcap(ctrlcount,pcaption$)
 IF menuCtrl=1 THEN
  BUNDLE.PUT 1,"frmmenu",ctrlcount
 ENDIF
 FN.RTN ctrlcount
FN.END
!
! @ C A L C _ C O L _ W I D T H S
!
FN.DEF @CalcColWidths(pcap$,pfrmscale)
 LET bcCOLBREAK$=CHR$(169)
 LET bcFLDBREAK$=CHR$(183)
 IF IS_IN(bcCOLBREAK$,pcap$)>0 THEN
  SPLIT cd$[],pcap$,bcCOLBREAK$
  ARRAY.LENGTH ccnt,cd$[]
  FOR j=2 TO ccnt
   SPLIT d$[],cd$[j],bcFLDBREAK$
   LET d$[2]=STR$(VAL(d$[2])/pfrmscale)
   LET cd$[j]=join$(d$[],bcFLDBREAK$)
   UNDIM d$[]
  NEXT j
  LET pcap$=join$(cd$[],bcCOLBREAK$)
 ENDIF
 FN.RTN 0
FN.END
!
!  D R A W _ F O R M
!
FN.DEF drawform(ploadmsg$,pPicPath$)
 LET bcFRMDISPLAY=1
 LET bcFRMSTRING=2
 LET bcFRMTEXT=3
 LET bcFRMSELECT=4
 LET bcFRMDATE=5
 LET bcFRMBUTTON=6
 LET bcFRMPICTURE=7
 LET bcFRMLABEL=8
 LET bcFRMLISTBOX=9
 LET bcFRMCHECKBOX=10
 LET bcFRMOPTBUTTON=11
 LET bcFRMSPINBUTTON=12
 LET bcFRMFRAME=13
 LET bcFRMSHAPE=14
 LET bcFRMCOMBOBOX=15
 LET bcFRMTIME=16
 LET bcFRMCHKBUTTON=17
 LET bcOPAQUE=255
 LET bcSEMIOPAQUE=128
 LET bcTRANSPARENT=0
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcBLACK=1
 LET bcBLUE=2
 LET bcCYAN=4
 LET bcLBLUE=10
 LET bcLGREEN=11
 LET bcLCYAN=12
 LET bcWHITE=16
 LET bcALIGNCENTRE$="C"
 LET bcALIGNRIGHT$="R"
 LET bcALIGNDATCENTRE$="c"
 LET bcALIGNDATRIGHT$="r"
 LET bcFILEDIALOG$="F"
 LET bcCHECKBOX$="X"
 LET bcLISTBOXRIGHT$="x"
 LET bcLISTVIEW$="v"
 LET bcHIDEGRID$="g"
 LET bcNOBORDER$="-"
 LET bcDATABORDER$=">"
 LET bcNOTITLEEDIT$="t"
 LET bcHIDE$="H"
 LET bcDISABLED$="D"
 LET bcFADEBACK$="+"
 LET bcBLAKBACK$="#"
 LET bcOUTLINE$="o"
 LET bcCHECKRIGHT$="p"
 LET bcPICSCROLL$="S"
 LET bcMENUBTN$="W"
 LET bcMENULIST$="w"
 LET bcALLOWNEW$="N"
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET bcFLDBREAK$=CHR$(183)
 GOSUB @LoadRGBData
 LET textptr=0
 LET backptr=0
 DIM optval$[1]
 DIM optctrl$[1]
 DIM optcoords$[1]
 DIM stemp$[1]
 LET fip=0
 IF ploadmsg$<>"" & ploadmsg$<>"HG" THEN POPUP ploadmsg$,0,0,0
 BUNDLE.GET 1,"ctrlcount",ctrlcount
 BUNDLE.GET 1,"FrmObjCnt",FrmObjCnt
 BUNDLE.GET 1,"lastdrawn",firstctrl
 BUNDLE.PUT 1,"lastdrawn",ctrlcount
 BUNDLE.GET 1,"swidth",swidth
 BUNDLE.GET 1,"sheight",sheight
 BUNDLE.GET 1,"frmscale",frmscale
 IF pPicPath$<>"-" THEN
  BUNDLE.GET 1,"picpath",curPath$
  BUNDLE.PUT 1,"picpath",pPicPath$
 ENDIF
 DIM showobj[ctrlcount]
 DIM hide$[ctrlcount]
 DIM cbobj[ctrlcount]
 IF firstctrl=0 THEN
  GR.CLS
  BUNDLE.GET 1,"frmcolour",frmcolour
  GR.COLOR bcOPAQUE,BCMP[frmcolour],GCMP[frmcolour],RCMP[frmcolour],bcFILL
  GR.RECT gonum,0,0,swidth,sheight
  LIST.CREATE N,frmobjlst
  UNDIM frmobj[]
  DIM frmobj[1]
  LET frmobj[1]=gonum
  LET frstfrmobj=2
  BUNDLE.PUT 1,"frmpath",pPicPath$
 ELSE
  BUNDLE.GET 1,"frmobjlst",frmobjlst
  UNDIM frmobj[]
  LIST.TOARRAY frmobjlst,frmobj[]
  LET frstfrmobj=FrmObjCnt+1
 ENDIF
 BUNDLE.GET 1,"hourglass",hg$
 IF ploadmsg$="HG" & hg$="Y" THEN
  CALL hourglass_show(2,0)
 ENDIF
 BUNDLE.GET 1,"ctrldata",ctrldata
 FOR ctrlID=firstctrl+1 TO ctrlcount
  GOSUB @getcontroldata
  BUNDLE.PUT ptrctrl,"state",""
  IF ctrltype=bcFRMFRAME THEN
   IF ctrlID=firstctrl+1 & pPicPath$<>"-" THEN
    BUNDLE.PUT ptrctrl,"frappath",curPath$
    BUNDLE.PUT ptrctrl,"frapath",pPicPath$
    IF IS_IN(bcHIDE$,ctrlstyle$)>0 | IS_IN(bcDISABLED$,ctrlstyle$)>0 THEN
     BUNDLE.PUT 1,"picpath",curPath$
    ENDIF
   ELSE
    BUNDLE.PUT ptrctrl,"frappath",""
    BUNDLE.PUT ptrctrl,"frapath",""
   ENDIF
  ENDIF
  LET ctrlfirstgrptr=FrmObjCnt+1
  LET cright=ctrlleft+ctrlwidth
  LET cbottom=ctrltop+ctrlheight
  LET cmiddle=ctrlleft+ctrlmiddle
  LET adjtop=0
  LET cboff=0
  IF ctrltype<>bcFRMSHAPE THEN
   IF ctrltype=bcFRMCHECKBOX & IS_IN(bcCHECKRIGHT$,ctrlstyle$)>0 THEN
    LET i=ctrlcapbakclr
    LET ctrlcapbakclr=ctrldatbakclr
    LET ctrldatbakclr=i
    LET cboff=ctrlmiddle
    IF IS_IN(bcALIGNCENTRE$,ctrlstyle$)>0 THEN
     LET txtx=cmiddle+(cright-cmiddle)/2
    ELSEIF IS_IN(bcALIGNRIGHT$,ctrlstyle$)>0 THEN
     LET txtx=cright-xo
    ELSE
     LET txtx=cmiddle+xo
    ENDIF
   ENDIF
   LET xo=ctrlfont/4
   IF ctrltype<>bcFRMLABEL & ctrltype<>bcFRMPICTURE THEN
    IF ctrltype=bcFRMLISTBOX THEN
     IF IS_IN(bcLISTVIEW$,ctrlstyle$)>0 & IS_IN(bcCOLBREAK$,ctrlsizecap$)=0 THEN
      POPUP "Error: No Columns Defined for Listview!",0,0,1
      LET ctrlorigcap$=i$+bcCOLBREAK$+"Dummy Column"+bcFLDBREAK$+STR$(ctrlwidth-ctrlheight) ~
          +bcFLDBREAK$+"1"
      LET ctrlsizecap$=ctrlorigcap$
      BUNDLE.PUT ptrctrl,"origcap",ctrlorigcap$
      BUNDLE.PUT ptrctrl,"sizecap",ctrlsizecap$
     ENDIF
     LET gonum=@drawlistbox(ctrlID,ptrctrl,ctrltype,ctrlsizecap$,ctrlcapbakclr,ctrlcaptxtclr, ~
         ctrldatbakclr,ctrldattxtclr,ctrltop,ctrlleft,ctrlmiddle,ctrlwidth,ctrlheight,cright, ~
         cbottom,ctrlfont,ctrlstyle$,&adjtop,xo,swidth,sheight,&ctrlcapbakobj,&ctrldatbakobj)
     GR.CLIP gonum,0,0,swidth,sheight,2
    ELSE
     IF ctrltype=bcFRMBUTTON THEN
      gonum=@drawbutton("B"+INT$(ptrctrl),ctrlcaptxtclr,ctrlcapbakclr,ctrlleft,ctrltop, ~
        ctrlwidth,ctrlheight,ctrlfont/3,ctrlstyle$,ctrlfont,ctrlsizecap$,bcOPAQUE, ~
        &ctrlcaptxtobj,&ctrlcapbakobj)
      IF IS_IN(bcMENULIST$,ctrlstyle$)<>0 THEN
       LET cbobj[ctrlID]=ptrctrl
      ENDIF
     ELSE
      LET rx=0
      IF ctrltype=bcFRMFRAME THEN
       LET adjleft=ctrlleft
       IF ctrlsizecap$="" THEN
        LET adjtop=ctrltop
       ELSE
        LET adjtop=ctrltop+(ctrlfont*1.5)
       ENDIF
       IF IS_IN(bcFADEBACK$,ctrlstyle$)>0 | IS_IN(bcBLAKBACK$,ctrlstyle$)>0 THEN
        IF IS_IN(bcBLAKBACK$,ctrlstyle$)>0 THEN LET i=bcOPAQUE ELSE LET i=bcSEMIOPAQUE
        GR.COLOR i,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcFILL
        GR.RECT gonum,0,0,swidth,sheight
        BUNDLE.PUT ptrctrl,"frabckobj",gonum
       ENDIF
       GR.COLOR bcOPAQUE,BCMP[ctrlcapbakclr],GCMP[ctrlcapbakclr],RCMP[ctrlcapbakclr],bcFILL
       GR.RECT gonum,adjleft,ctrltop,cright,cbottom
      ELSE
       IF ctrlmiddle=0 THEN
        LET adjleft=ctrlleft
       ELSE
        LET adjleft=cmiddle
        GR.COLOR bcOPAQUE,BCMP[ctrlcapbakclr],GCMP[ctrlcapbakclr],RCMP[ctrlcapbakclr],bcFILL
       ENDIF
       GR.RECT gonum,ctrlleft,ctrltop,adjleft,cbottom
       LET ctrlcapbakobj=gonum
       IF ctrlmiddle<>ctrlwidth THEN
        GR.COLOR bcOPAQUE,BCMP[ctrldatbakclr],GCMP[ctrldatbakclr],RCMP[ctrldatbakclr],bcFILL
       ENDIF
       GR.RECT gonum,adjleft,ctrltop,cright,cbottom
      ENDIF
      IF ctrltype=bcFRMFRAME THEN
       LET ctrlcapbakobj=gonum
       GR.COLOR bcOPAQUE,BCMP[ctrldatbakclr],GCMP[ctrldatbakclr],RCMP[ctrldatbakclr],bcFILL
       GR.RECT gonum,adjleft,adjtop,cright,cbottom
      ENDIF
      LET ctrldatbakobj=gonum
      IF ctrltype=bcFRMCOMBOBOX THEN
       LET rx=ctrlheight
       IF IS_IN(bcALLOWNEW$,ctrlstyle$)<>0 THEN LET i=bcLGREEN ELSE LET i=bcWHITE
       LET lastgonum=@drawbutton("CBdn"+INT$(ptrctrl),bcLBLUE,i,cright-ctrlheight,ctrltop, ~
           ctrlheight,ctrlheight,ctrlfont/4,ctrlstyle$,0,"v",bcOPAQUE,textptr,&backptr)
       BUNDLE.PUT ptrctrl,"combobtnbak",backptr
      ENDIF
     ENDIF
    ENDIF
    IF IS_IN(bcNOBORDER$,ctrlstyle$)=0 & ctrltype<>bcFRMBUTTON THEN
     LET i=ctrlleft
     LET j=cright
     IF ctrltype=bcFRMFRAME | ctrltype=bcFRMLISTBOX THEN
      IF IS_IN(bcDATABORDER$,ctrlstyle$)=0 THEN
       CALL @drawborder(ctrlstyle$,bcOPAQUE,ctrlleft,ctrltop,cright,cbottom,gonum,gonum)
      ENDIF
     ELSE
      LET adjtop=ctrltop
      IF IS_IN(bcDATABORDER$,ctrlstyle$)<>0 THEN
       IF IS_IN(bcCHECKRIGHT$,ctrlstyle$)<>0 & ctrltype=bcFRMCHECKBOX THEN
        LET j=i+ctrlmiddle
       ELSE
        LET i=i+ctrlmiddle
       ENDIF
      ENDIF
     ENDIF
     CALL @drawborder(ctrlstyle$,bcOPAQUE,i,adjtop,j,cbottom,gonum,gonum)
    ENDIF
   ENDIF
   IF ctrltype=bcFRMPICTURE THEN
    IF IS_IN(bcPICSCROLL$,ctrlstyle$)<>0 THEN
     CALL @DrawHScroll(ptrctrl,ctrlleft,cbottom,ctrlwidth,bcTRANSPARENT,ctrlstyle$,ctrlwidth*1.5)
     CALL @DrawVScroll(ptrctrl,cright,ctrltop,ctrlheight,bcTRANSPARENT,ctrlstyle$,ctrlheight*1.5)
    ENDIF
   ELSEIF ctrltype<>bcFRMBUTTON THEN
    GR.TEXT.SIZE ctrlfont
    IF ctrltype=bcFRMLISTBOX | ctrltype=bcFRMFRAME THEN
     LET fo=@getfontyoffset(ctrlmiddle,ctrlfont)
    ELSE
     IF ctrltype=bcFRMOPTBUTTON | ctrltype=bcFRMCHKBUTTON THEN
      LET omargin=ctrlfont/2
      LET fo=@getfontyoffset(ctrlfont+2*omargin,ctrlfont)
     ELSE
      LET fo=@getfontyoffset(cbottom-ctrltop,ctrlfont)
     ENDIF
    ENDIF
    IF ctrlmiddle<>0 | ctrltype=bcFRMLABEL THEN
     GR.COLOR bcOPAQUE,BCMP[ctrlcaptxtclr],GCMP[ctrlcaptxtclr],RCMP[ctrlcaptxtclr],bcFILL
    ENDIF
    IF ctrltype=bcFRMLABEL | ctrltype=bcFRMFRAME | ctrltype=bcFRMLISTBOX THEN
     LET stext$=ctrlsizecap$
     IF ctrltype=bcFRMLISTBOX THEN
      LET i=IS_IN(bcCOLBREAK$,stext$)
      IF i<>0 THEN
       LET stext$=LEFT$(stext$,i-1)
      ENDIF
     ENDIF
     CALL @setstyle(ctrltype,ctrlstyle$,"c")
     IF IS_IN(bcALIGNCENTRE$,ctrlstyle$)>0 THEN
      LET x=ctrlleft+(cright-ctrlleft)/2
     ELSEIF IS_IN(bcALIGNRIGHT$,ctrlstyle$)>0 THEN
      LET x=cright-xo-4
     ELSE
      LET x=ctrlleft+xo
     ENDIF
     GR.TEXT.DRAW gonum,x,ctrltop+fo,stext$
     LET ctrlcaptxtobj=gonum
     IF ctrltype=bcFRMLABEL THEN
      IF IS_IN(bcOUTLINE$,ctrlstyle$)>0 THEN
       GR.COLOR bcOPAQUE,BCMP[1],GCMP[1],RCMP[1],bcNOFILL
       GR.TEXT.DRAW gonum,x,ctrltop+fo,stext$
      ENDIF
      LET ctrlcaptxtX=x-ctrlleft
      LET ctrlcaptxtY=fo
     ENDIF
    ELSE
     IF ctrltype=bcFRMSELECT | ctrltype=bcFRMSPINBUTTON | ctrltype=bcFRMOPTBUTTON ~
      | ctrltype=bcFRMCHKBUTTON | ctrltype=bcFRMCOMBOBOX THEN
      UNDIM  stemp$[]
      SPLIT.ALL stemp$[],ctrlsizecap$,bcRECBREAK$
      LET stemp$=stemp$[1]
     ELSE
      LET stemp$=ctrlsizecap$
     ENDIF
     CALL @setstyle(ctrltype,ctrlstyle$,"c")
     IF cboff=0 THEN
      IF IS_IN(bcALIGNCENTRE$,ctrlstyle$)>0 THEN
       LET txtx=ctrlleft+(cmiddle-ctrlleft)/2
      ELSEIF IS_IN(bcALIGNRIGHT$,ctrlstyle$)>0 THEN
       LET txtx=cmiddle-xo-4
      ELSE
       LET txtx=ctrlleft+xo
      ENDIF
     ENDIF
     GR.TEXT.DRAW gonum,txtx,ctrltop+fo,stemp$
     LET ctrlcaptxtobj=gonum
    ENDIF
   ENDIF
   IF ctrltype=bcFRMSELECT | ctrltype=bcFRMSPINBUTTON | ctrltype=bcFRMTIME THEN
    LET gonum=@drawselectspintime(ptrctrl,ctrltype,ctrltop,cmiddle,cright,cbottom,ctrlfont,ctrlstyle$)
   ENDIF
   IF ctrltype=bcFRMCHECKBOX THEN
    LET gonum=@drawcheckbox(ctrltop,ctrlleft,cbottom,ctrldata$,ctrlfont,&ctrldattxtobj,adjleft-cboff)
   ENDIF
   IF ctrltype=bcFRMOPTBUTTON | ctrltype=bcFRMCHKBUTTON THEN
    LET gonum=@drawoptbutton(ptrctrl,ctrltype,ctrldatalst,ctrltop,ctrlheight,ctrlfont,ctrlstyle$, ~
        ctrldata$,adjleft,omargin,fo)
   ENDIF
  ELSE
   LET gonum=@drawshape(ptrctrl,ctrlsizecap$,ctrlcaptxtclr,ctrlcapbakclr,ctrltop,ctrlleft,ctrlwidth, ~
         ctrlheight,cright,cbottom,ctrlfont,ctrlstyle$,&ctrlcaptxtobj,&ctrlcapbakobj)
  ENDIF
  !
  !#__draw_data_(text)
  !
  CALL @setstyle(ctrltype,ctrlstyle$,"d")
  IF (ctrltype<>bcFRMBUTTON) & (ctrltype<>bcFRMLISTBOX) & (ctrltype<>bcFRMCHECKBOX) ~
   & (ctrltype<>bcFRMOPTBUTTON) & (ctrltype<>bcFRMCHKBUTTON) & (ctrltype<>bcFRMSHAPE) ~
   & (ctrltype<>bcFRMLABEL) & (ctrltype<>bcFRMFRAME) THEN
   IF ctrltype=bcFRMPICTURE THEN
    LET gonum=@drawpicturertn(ptrctrl,ctrlID,0,ctrldata$,ctrltop,ctrlleft,ctrlwidth,ctrlheight, ~
              ctrlmiddle,ctrlcaptxtclr,ctrlcapbakclr,&ctrlcaptxtobj,&ctrlcapbakobj)
   ELSEIF ctrltype=bcFRMTIME THEN
    LET gonum=@drawtimevalue(ptrctrl,ctrldattxtclr,ctrltop,ctrlheight,ctrlfont,ctrldata$, ~
          ctrlstyle$,cmiddle,cbottom,fo)
   ELSE
    IF ctrlmiddle<>ctrlwidth THEN
     GR.COLOR bcOPAQUE,BCMP[ctrldattxtclr],GCMP[ctrldattxtclr],RCMP[ctrldattxtclr],bcFILL
    ENDIF
    LET stext$=ctrldata$
    IF ctrltype<>bcFRMTEXT THEN GOSUB @AdjFntSize
    LET fo=@getfontyoffset(cbottom-ctrltop,ctrlfont)
    IF ctrltype=bcFRMSELECT THEN
     LET loffset=cbottom-ctrltop
     LET lfpt=cmiddle+(cright-cmiddle)/2
    ELSEIF ctrltype=bcFRMSPINBUTTON THEN
     LET loffset=(cbottom-ctrltop)*2
     LET lfpt=cmiddle+(cright-cmiddle)/2
    ELSE
     LET loffset=0
     LET lfpt=cmiddle+xo+loffset
     IF ctrltype=bcFRMDISPLAY | ctrltype=bcFRMSTRING | ctrltype=bcFRMTEXT THEN
      IF IS_IN(bcALIGNDATCENTRE$,ctrlstyle$)>0 THEN
       LET lfpt=cmiddle+(cright-cmiddle-rx)/2
      ELSEIF IS_IN(bcALIGNDATRIGHT$,ctrlstyle$)>0 THEN
       LET lfpt=cright-xo-rx
      ENDIF
     ENDIF
    ENDIF
    LET x=cmiddle
    LET dx=cright-3
    IF ctrltype=bcFRMSELECT | ctrltype=bcFRMCOMBOBOX THEN
     LET dx=dx-ctrlheight
     IF ctrltype=bcFRMSELECT THEN LET x=x+ctrlheight
    ELSEIF ctrltype=bcFRMSPINBUTTON
     LET x=x+(2*ctrlheight)
     LET dx=dx-(2*ctrlheight)
    ENDIF
    GR.CLIP gonum,x,ctrltop,dx,cbottom,2
    GR.TEXT.DRAW gonum,lfpt,ctrltop+fo,stext$
    LET ctrldattxtobj=gonum
    GR.CLIP gonum,0,0,swidth,sheight,2
   ENDIF
  ENDIF
  IF IS_IN(bcHIDE$,ctrlstyle$)>0 THEN
   LET hide$[ctrlID]="h"
  ELSEIF IS_IN(bcDISABLED$,ctrlstyle$)>0 THEN
   LET hide$[ctrlID]="d"
  ELSE
   LET hide$[ctrlID]="n"
  ENDIF
  IF cboff<>0 THEN
   LET i=ctrlcapbakobj
   LET ctrlcapbakobj=ctrldatbakobj
   LET ctrldatbakobj=i
  ENDIF
  BUNDLE.PUT ptrctrl,"captxtobj",ctrlcaptxtobj
  BUNDLE.PUT ptrctrl,"capbakobj",ctrlcapbakobj
  BUNDLE.PUT ptrctrl,"data",ctrldata$
  BUNDLE.PUT ptrctrl,"dattxtobj",ctrldattxtobj
  BUNDLE.PUT ptrctrl,"datbakobj",ctrldatbakobj
  BUNDLE.PUT ptrctrl,"firstgrptr",ctrlfirstgrptr
  BUNDLE.PUT ptrctrl,"captxtxoff",ctrlcaptxtX
  BUNDLE.PUT ptrctrl,"captxtyoff",ctrlcaptxtY
  BUNDLE.GET ptrctrl,"frame",i
  IF i<>0 THEN
   BUNDLE.GET ctrldata,"CP"+STR$(i),j
   BUNDLE.PUT j,"fralastptr",gonum
  ENDIF
  IF ctrltype=bcFRMLISTBOX THEN CALL @RedrawListBoxRows(ctrlID,0)
  IF ctrltype=bcFRMCOMBOBOX THEN LET cbobj[ctrlID]=ptrctrl
  LET FrmObjCnt=gonum
  BUNDLE.PUT ptrctrl,"lastgrptr",FrmObjCnt
 NEXT ctrlID
 FOR ctrlID=1 TO ctrlcount
  IF cbobj[ctrlID]<>0 THEN
   LET gonum=@drawcomboboxlist(ctrlID,cbobj[ctrlID],swidth,sheight)
   BUNDLE.GET ctrldata,"CP"+STR$(ctrlID),i
   BUNDLE.GET i,"frame",j
   IF j<>0 THEN
    BUNDLE.GET ctrldata,"CP"+STR$(j),i
    BUNDLE.PUT i,"fralastptr",gonum
   ENDIF
  ENDIF
 NEXT ctrlID
 LIST.CLEAR frmobjlst
 UNDIM t[]
 GR.GETDL t[],1
 LIST.ADD.ARRAY frmobjlst,t[]
 BUNDLE.PUT 1,"frmobjlst",frmobjlst
 ARRAY.LENGTH i,t[]
 BUNDLE.PUT 1,"FrmObjCnt",i
 FOR ctrlID=1 TO ctrlcount
  IF hide$[ctrlID]="d" THEN CALL disablectrl(ctrlID,0)
 NEXT ctrlID
 FOR ctrlID=1 TO ctrlcount
  IF hide$[ctrlID]="h" THEN CALL hidectrl(ctrlID,0)
 NEXT ctrlID
 IF ploadmsg$="HG" & hg$="Y" THEN
  CALL hourglass_hide(0)
 ELSE
  GR.RENDER
 ENDIF
 FN.RTN 0
FN.END
!
!  T O U C H _ C H E C K
!
FN.DEF touchcheck(pperiod,pfirstctrl,plastctrl)
 LET bcOPAQUE=255
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcSEMIOPAQUE=128
 LET bcBLACK=1
 LET bcBLUE=2
 LET bcCYAN=4
 LET bcLBLUE=10
 LET bcLCYAN=12
 LET bcWHITE=16
 LET bcFRMDISPLAY=1
 LET bcFRMSTRING=2
 LET bcFRMTEXT=3
 LET bcFRMSELECT=4
 LET bcFRMDATE=5
 LET bcFRMBUTTON=6
 LET bcFRMPICTURE=7
 LET bcFRMLABEL=8
 LET bcFRMLISTBOX=9
 LET bcFRMCHECKBOX=10
 LET bcFRMOPTBUTTON=11
 LET bcFRMSPINBUTTON=12
 LET bcFRMFRAME=13
 LET bcFRMSHAPE=14
 LET bcFRMCOMBOBOX=15
 LET bcFRMTIME=16
 LET bcFRMCHKBUTTON=17
 LET bcNOTITLEEDIT$="t"
 LET bcNOTCLICKABLE$="k"
 LET bcLISTVIEW$="v"
 LET bcMENUBTN$="W"
 LET bcMENULIST$="w"
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET bcMSGMENUCTRL=1082
 LET bcMSGMENUSET=1582
 LET bcMSGSETLIST=2000
 LET bcMSGMULTIUPDT=3000
 LET bcMSGCHECKCLICK=4000
 LET bcMSGCOLSORT=5000
 LET bcMSGPICSCROLL=6000
 IF pperiod<>0 THEN LET leavetime=CLOCK()+pperiod
 IF pfirstctrl=0 THEN
  LET lfirstctrl=1
  BUNDLE.GET 1,"ctrlcount",llastctrl
 ELSE
  LET lfirstctrl=pfirstctrl
  LET llastctrl=plastctrl
 ENDIF
DO
 LET tch=0
 LET bpressed=0
 GR.TOUCH tch,dx,dy
 IF tch<>0 THEN
  FOR ctrlID=llastctrl TO lfirstctrl STEP-1
   BUNDLE.GET 1,"ctrldata",ctrldata
   BUNDLE.GET ctrldata,"CP"+STR$(ctrlID),ptrctrl
   BUNDLE.GET ptrctrl,"type",ctrltype
   BUNDLE.GET ptrctrl,"style",ctrlstyle$
   BUNDLE.GET ptrctrl,"state",ctrlstate$
   IF ctrltype=bcFRMLABEL | ctrltype=bcFRMFRAME | ctrlstate$<>"" ~
   | IS_IN(bcNOTCLICKABLE$,ctrlstyle$)>0 THEN
   ELSE
    BUNDLE.GET ptrctrl,"top",ctrltop
    BUNDLE.GET ptrctrl,"left",ctrlleft
    BUNDLE.GET ptrctrl,"width",ctrlwidth
    BUNDLE.GET ptrctrl,"height",ctrlheight
    LET cright=ctrlleft+ctrlwidth
    LET cbottom=ctrltop+ctrlheight
    GR.BOUNDED.TOUCH tch,ctrlleft,ctrltop,cright,cbottom
    IF tch=1 THEN
     GOSUB @getcontroldata
     LET selctrl=ctrlID
     BUNDLE.PUT ptrctrl,"pressx",dx-ctrlleft
     BUNDLE.PUT ptrctrl,"pressy",dy-ctrltop
     IF ctrltype<>bcFRMPICTURE THEN
      GR.MODIFY ctrlcaptxtobj,"alpha",bcSEMIOPAQUE
     ENDIF
     GR.MODIFY ctrlcapbakobj,"alpha",bcSEMIOPAQUE
     GR.RENDER
     LET bpressed=1
     LET dwntime=CLOCK()
     DO
      GR.TOUCH tuch,ux,uy
      IF tuch<>0 THEN
       IF CLOCK()-dwntime>500 THEN
        LET tuch=-1
       ENDIF
      ENDIF
     UNTIL tuch<1
     IF ctrltype<>bcFRMPICTURE THEN
      GR.MODIFY ctrlcaptxtobj,"alpha",bcOPAQUE
     ENDIF
     GR.MODIFY ctrlcapbakobj,"alpha",bcOPAQUE
     GR.RENDER
     F_N.BREAK
    ENDIF
   ENDIF
  NEXT ctrlID
  IF IS_IN(bcMENULIST$,ctrlstyle$)<>0 THEN
   LET rw=ctrlleft+ctrlwidth-ctrlheight 
   IF !(ctrltype=bcFRMCOMBOBOX & dx>rw) THEN
    BUNDLE.GET 1,"tchcnt",i
    IF i=0 THEN
     BUNDLE.PUT 1,"tchcnt",selctrl
     IF IS_IN(bcMENUBTN$,ctrlstyle$)<>0 THEN LET selctrl=bcMSGMENUSET ELSE LET selctrl=selctrl+bcMSGSETLIST
     LET bpressed=2
    ENDIF
   ENDIF
  ENDIF
  IF tuch=-1 THEN
   IF ctrltype=bcFRMSTRING | ctrltype=bcFRMTEXT | ctrltype=bcFRMSELECT | ctrltype=bcFRMCOMBOBOX THEN
    LET cap$=ctrldata$
    POPUP cap$,0,0,1
    DO
     GR.TOUCH tuch,ux,uy
    UNTIL tuch=0
    LET bpressed=0
   ENDIF
  ENDIF
  IF bpressed=1 THEN
   CALL @soundrtn()
   IF ctrltype=bcFRMSTRING THEN
    LET rc=@clickstring(ctrlsizecap$,&ctrldata$,ctrldattxtobj)
    IF rc=1 THEN
     BUNDLE.PUT ptrctrl,"data",ctrldata$
    ENDIF
   ELSEIF ctrltype=bcFRMTEXT THEN
    LET rc=@clicktext(dx,ctrlsizecap$,&ctrldata$,ctrldattxtobj,ctrlleft,ctrlwidth,ctrlheight, ~
           ctrlstyle$)
    IF rc=1 THEN
     BUNDLE.PUT ptrctrl,"data",ctrldata$
    ENDIF
   ELSEIF ctrltype=bcFRMSELECT THEN
    LET rc=@clickselect(dx,ctrlsizecap$,ctrldatalst,&ctrldata$,ctrldattxtobj,ctrlleft,ctrlheight, ~
        ctrlmiddle,ctrlwidth,ctrlstyle$)
    BUNDLE.PUT ptrctrl,"data",ctrldata$
   ELSEIF ctrltype=bcFRMSPINBUTTON THEN
    LET rc=@clickspinbutton(dx,ctrldatalst,&ctrldata$,ctrldattxtobj,ctrlleft,ctrlmiddle,ctrlheight, ~
        ctrlwidth,ctrlstyle$)
    BUNDLE.PUT ptrctrl,"data",ctrldata$
   ELSEIF ctrltype=bcFRMTIME THEN
    LET rc=@clicktimebutton(dx,&ctrldata$,ptrctrl)
    BUNDLE.PUT ptrctrl,"data",ctrldata$
   ELSEIF ctrltype=bcFRMDATE THEN
    LET rc=@clickdate(ctrldattxtobj,&ctrldata$,ctrlstyle$)
    BUNDLE.PUT ptrctrl,"data",ctrldata$
   ELSEIF ctrltype=bcFRMLISTBOX THEN
    BUNDLE.GET ptrctrl,"lbprevstart",prevstart
    BUNDLE.GET ptrctrl,"vscrstop",pscrolltop
    BUNDLE.GET ptrctrl,"vscrsmid",pscrollmid
    LET colclicked=0
    LET rc=@clicklistbox(dx,dy,ctrlorigcap$,&ctrldata$,ctrltop,ctrlleft,ctrlmiddle,cright,cbottom, ~
        ctrlfont,ctrlstyle$,&prevstart,pscrolltop,pscrollmid,&colclicked,ptrctrl,selctrl)
    BUNDLE.PUT ptrctrl,"data",ctrldata$
    BUNDLE.PUT ptrctrl,"lbcolclicked",colclicked
    BUNDLE.PUT ptrctrl,"lbprevstart",prevstart
    LET rc1=@RedrawListBoxRows(selctrl,0)
    IF rc<0 THEN
     IF rc=-2 THEN
      LET selctrl=selctrl+bcMSGMULTIUPDT
      LET rc=1
     ELSEIF rc=-3 THEN
      LET selctrl=selctrl+bcMSGCHECKCLICK
      LET rc=1
     ELSEIF rc=-4 THEN
      LET selctrl=selctrl+bcMSGCOLSORT
      LET rc=1
     ENDIF
     IF rc=-1 THEN LET rc=0 ELSE LET rc=1
    ENDIF
    GR.RENDER
   ELSEIF ctrltype=bcFRMCHECKBOX THEN
    LET rc=@clickcheckbox(&ctrldata$,ctrldattxtobj)
    BUNDLE.PUT ptrctrl,"data",ctrldata$
   ELSEIF ctrltype=bcFRMOPTBUTTON | ctrltype=bcFRMCHKBUTTON THEN
    BUNDLE.GET ptrctrl,"optmarkobj",optmarkobj$
    BUNDLE.GET ptrctrl,"optcoord",optcoord$
    LET rc=@clickoptionbutton(dx,dy,ctrldatalst,&ctrldata$,optmarkobj$,optcoord$,1, ~
        ctrltype,ctrlstate$)
    BUNDLE.PUT ptrctrl,"data",ctrldata$
   ELSEIF ctrltype=bcFRMCOMBOBOX THEN
    LET rw=ctrlleft+ctrlwidth-ctrlheight
    IF dx>rw THEN
     LET rc=@clickcombobox(ctrlsizecap$,ctrldatalst,&ctrldata$,ctrldattxtobj,ptrctrl, ~
         ctrltop,ctrlleft,ctrlheight,ctrlmiddle,ctrlwidth,ctrlfont)
    ELSE
     LET rc=@addcomboboxentry(ctrlsizecap$,ctrldatalst,&ctrldata$,ctrlstyle$,ctrldattxtobj, ~
            selctrl,ptrctrl)
    ENDIF
    BUNDLE.PUT ptrctrl,"data",ctrldata$
   ELSEIF ctrltype=bcFRMBUTTON THEN
    LET rc=1
    IF IS_IN(bcMENUBTN$,ctrlstyle$)<>0 THEN
     LET selctrl=bcMSGMENUCTRL
    ENDIF
   ELSEIF ctrltype=bcFRMPICTURE THEN
    LET rc=@clickpicture(ptrctrl,ctrlstyle$,dx,dy,cright,cbottom)
    IF rc=2 THEN
     LET selctrl=selctrl+bcMSGPICSCROLL
     LET rc=1
    ENDIF
   ELSEIF ctrltype=bcFRMDISPLAY | ctrltype=bcFRMSHAPE THEN
    LET rc=1
   ENDIF
   IF rc=0 THEN LET bpressed=0
  ENDIF
 ELSE
  BUNDLE.GET 1,"tchcnt",ctrlID
  IF ctrlID<>0 THEN
   BUNDLE.PUT 1,"tchcnt",0
   GOSUB @getcontrolcoords
   BUNDLE.GET ptrctrl,"sizecap",ctrlsizecap$
   BUNDLE.GET ptrctrl,"datalst",ctrldatalst
   BUNDLE.GET ptrctrl,"data",ctrldata$
   BUNDLE.GET ptrctrl,"dattxtobj",ctrldattxtobj
   BUNDLE.GET ptrctrl,"middle",ctrlmiddle
   BUNDLE.GET ptrctrl,"font",ctrlfont
   BUNDLE.GET ptrctrl,"style",ctrlstyle$
   IF ctrltype=bcFRMCOMBOBOX THEN
    LET rw=ctrlleft+ctrlwidth-ctrlheight
    IF dx>rw THEN
     LET rc=@clickcombobox(ctrlsizecap$,ctrldatalst,&ctrldata$,ctrldattxtobj,ptrctrl, ~
         ctrltop,ctrlleft,ctrlheight,ctrlmiddle,ctrlwidth,ctrlfont)
    ELSE
     LET rc=@addcomboboxentry(ctrlsizecap$,ctrldatalst,&ctrldata$,ctrlstyle$,ctrldattxtobj, ~
            selctrl,ptrctrl)
    ENDIF
   ELSE
    LET rc=@clickcombobox(ctrlsizecap$,ctrldatalst,&ctrldata$,ctrldattxtobj,ptrctrl,ctrltop, ~
       ctrlleft,ctrlheight,ctrlmiddle,ctrlwidth,ctrlfont)
   ENDIF
   IF rc=1 THEN
    BUNDLE.PUT ptrctrl,"data",ctrldata$
    IF IS_IN(bcMENUBTN$,ctrlstyle$)<>0 THEN LET selctrl=bcMSGMENUCTRL ELSE LET selctrl=ctrlID
    LET bpressed=1
   ENDIF
  ELSE
   INKEY$ i1$
   IF LEFT$(i1$,3)="key" THEN
    LET i1$=RIGHT$(i1$,2)
    IF i1$="82" | i1$="84" | i1$="24" | i1$="25" THEN
     LET selctrl=VAL(i1$)+1000
     IF selctrl=bcMSGMENUCTRL THEN %Menu Key
      BUNDLE.GET 1,"frmmenu",ctrlno
      IF ctrlID<>0 THEN
       GOSUB @getcontroldata
       CALL @clickcombobox(ctrlsizecap$,ctrldatalst,&ctrldata$,ctrldattxtobj,ptrctrl,ctrltop, ~
            ctrlleft,ctrlheight,ctrlmiddle,ctrlwidth,ctrlfont)
       BUNDLE.PUT ptrctrl,"data",ctrldata$
      ENDIF
     ENDIF
     LET bpressed=1
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF bpressed=0 THEN
  IF pperiod<>0 THEN
   IF CLOCK()>leavetime THEN
    LET selctrl=0
    LET dx=0
    LET dy=0
    LET bpressed=1
   ENDIF
  ENDIF
 ENDIF
 PAUSE 50
UNTIL bpressed<>0
 DO
  GR.TOUCH tuch,ux,uy
 UNTIL tuch=0
 FN.RTN selctrl
FN.END
!
!  @ D R A W _ B O R D E R
!
FN.DEF @drawborder(pstyle$,popaque,px,py,pcx,pcy,gonum1,gonum2)
 LET bcNOFILL=0
 LET bcBLACK=1
 LET bcWHITE=16
 LET bcNOBORDER$="-"
 LET bc3DBORDER$="9"
 GOSUB @LoadRGBData
 IF IS_IN(bcNOBORDER$,pstyle$)=0 THEN
  GR.COLOR popaque,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
  IF pstyle$="99" THEN
   LET s1=6
   LET s2=3
   LET x1=3
   LET x2=4
   LET x3=2
  ELSE
   LET s1=4
   LET s2=2
   LET x1=2
   LET x2=3
   LET x3=1
   GR.RECT gonum1,px,py,pcx,pcy
  ENDIF
  IF IS_IN(bc3DBORDER$,pstyle$)<>0 | pstyle$="99" THEN
   GR.SET.STROKE s1
   GR.RECT gonum1,px-x1,py-x1,pcx+x1,pcy+x1
   GR.SET.STROKE s2
   GR.COLOR popaque,BCMP[bcWHITE],GCMP[bcWHITE],RCMP[bcWHITE],bcNOFILL
   GR.RECT gonum2,px-x2,py-x2,pcx+x3,pcy+x3
   GR.SET.STROKE 0
  ENDIF
 ENDIF
 FN.RTN 0
FN.END
!
!  @ D R A W _ B U T T O N
!
FN.DEF @drawbutton(pKey$,ptextcolor,pbackcolor,px,py,pdx,pdy,pHite,pstyle$,pfont,pmark$,palpha, ~
       ptextptr,pbackptr)
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcBLACK=1
 LET bcGRAY=8
 LET bcLGRAY=9
 LET bcWHITE=16
 LET bcFRMBUTTON=6
 LET bcNOBORDER$="-"
 LET bcGRAPHIC$="G"
 LET bcMENUBTN$="W"
 LET bcFLAT$="a"
 LET bcBEVEL$="("
 LET bcROUND$=")"
 GOSUB @LoadRGBData
 IF pHite>5 THEN
  LET pHite=5
 ELSEIF pHite=0 THEN
  LET pHite=4
 ENDIF
 LET h2=pHite+pHite
 LET h5=pHite/2
 IF IS_IN(bcROUND$,pstyle$)<>0 THEN
  LET pr=px+pdx
  LET pb=py+pdy
  LET pcr=pdy/2
  LET plc=px+pcr
  LET prc=px+pdx-pcr
  IF IS_IN(bcFLAT$,pstyle$)<>0 | IS_IN(bcNOBORDER$,pstyle$)<>0 THEN
   LET sc=pbackcolor
   LET hc=pbackcolor
   IF IS_IN(bcNOBORDER$,pstyle$)=0 THEN LET bc=bcBLACK ELSE LET bc=pbackcolor
  ELSE 
   LET sc=bcGRAY
   LET hc=bcWHITE
   LET bc=bcBLACK
  ENDIF
  GR.SET.STROKE 6
  GR.COLOR palpha,BCMP[sc],GCMP[sc],RCMP[sc],bcNOFILL
  GR.ARC gonum,px+2,py+2,px+pdy-2,pb-2,88,47,BCNOFILL
  GR.ARC gonum,pr-pdy,py+2,pr-2,pb-2,315,137,BCNOFILL
  GR.COLOR palpha,BCMP[hc],GCMP[hc],RCMP[hc],bcNOFILL
  GR.ARC gonum,px+2,py+2,px+pdy-2,pb-2,135,137, BCNOFILL
  GR.ARC gonum,pr-pdy,py+2,pr-2,pb-2,268,47, BCNOFILL
  IF IS_IN(bcNOBORDER$,pstyle$)=0 THEN
   GR.SET.STROKE 2
   GR.COLOR palpha,BCMP[bc],GCMP[bc],RCMP[bc],bcNOFILL
   GR.ARC gonum,px,py,px+pdy,pb,90,180,BCNOFILL
   GR.ARC gonum,pr-pdy,py,pr,pb,270,180,BCNOFILL
   GR.COLOR palpha,BCMP[bc],GCMP[bc],RCMP[bc],bcNOFILL
   IF IS_IN(bcFLAT$,pstyle$)=0 THEN
   GR.ARC gonum,px+phite,py+phite,px+pdy-phite,pb-phite,90,180,BCNOFILL
   GR.ARC gonum,pr-pdy+phite,py+phite,pr-phite,pb-phite,270,180,BCNOFILL
   ENDIF
  ENDIF
  GR.SET.STROKE 0
  GR.COLOR palpha,BCMP[hc],GCMP[hc],RCMP[hc],bcFILL
  GR.RECT gonum,plc,py-1,prc,py+phite
  GR.COLOR palpha,BCMP[sc],GCMP[sc],RCMP[sc],bcFILL
  GR.RECT gonum,plc,pb-phite,prc,pb+1
  GR.COLOR palpha,BCMP[pbackcolor],GCMP[pbackcolor],RCMP[pbackcolor],bcFILL
  GR.RECT gonum,plc-1,py+phite,prc+1,pb-phite
  GR.ARC gonum,px+phite,py+phite,px+pdy-phite,pb-phite,90,180,BCFILL
  GR.ARC gonum,pr-pdy+phite,py+phite,pr-phite,pb-phite,270,180,BCFILL
  IF IS_IN(bcNOBORDER$,pstyle$)=0 THEN
   GR.SET.STROKE 2
   GR.COLOR palpha,BCMP[bc],GCMP[bc],RCMP[bc],bcNOFILL
   GR.LINE gonum,plc,py,prc,py
   GR.LINE gonum,plc,pb,prc,pb
   GR.SET.STROKE 0
   IF IS_IN(bcFLAT$,pstyle$)=0 THEN
    GR.LINE gonum,plc,py+phite-1,prc,py+phite-1
    GR.LINE gonum,plc,pb-phite+1,prc,pb-phite+1
   ENDIF
  ENDIF
 ELSE
  IF IS_IN(bcFLAT$,pstyle$)<>0 THEN
   IF IS_IN(bcBEVEL$,pstyle$)<>0 THEN
    ARRAY.LOAD paBord[],px+h2,py,px+pdx-h2,py,px+pdx,py+h2,px+pdx,py+pdy-h2,px+pdx-h2,py+pdy~
               px+h2,py+pdy,px,py+pdy-h2,px,py+h2
   ELSE
    ARRAY.LOAD paBord[],px,py,px+pdx,py,px+pdx,py+pdy,px,py+pdy
   ENDIF
   LIST.CREATE n,bptr
   LIST.ADD.ARRAY bptr,paBord[]
   GR.COLOR palpha,BCMP[pbackcolor],GCMP[pbackcolor],RCMP[pbackcolor],bcFILL
   GR.POLY pbackptr,bptr
   IF IS_IN(bcNOBORDER$,pstyle$)=0 THEN
    GR.COLOR palpha,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
    GR.POLY gonum,bptr
   ENDIF
  ELSE
   IF IS_IN(bcBEVEL$,pstyle$)=0 THEN
    ARRAY.LOAD paLite[],px,py,px+pdx,py,px+pdx-pHite,py+pHite,px+pHite,py+pHite,px+pHite~
               py+pdy-pHite,px,py+pdy
    ARRAY.LOAD paDark[],px,py+pdy,px+pdx,py+pdy,px+pdx,py,px+pdx-pHite,py+pHite,px+pdx-pHite~
               py+pdy-pHite,px+pHite,py+pdy-pHite
   ELSE
    ARRAY.LOAD paLite[],px+h2+h5,py+pdy-pHite,px+h2,py+pdy,px,py+pdy-h2,px,py+h2,px+h2,py~
               px+pdx-h2,py,px+pdx,py+h2,px+pdx-pHite,py+h2+h5,px+pdx-h2-h5,py+pHite,px+h2+h5~
               py+pHite,px+pHite,py+h2+h5,px+pHite,py+pdy-h2-h5
    ARRAY.LOAD paDark[],px+h2+h5,py+pdy-pHite,px+pdx-h2-h5,py+pdy-pHite,px+pdx-pHite~
               py+pdy-h2-h5,px+pdx-pHite,py+h2+h5,px+pdx,py+h2,px+pdx,py+pdy-h2,px+pdx-h2~
               py+pdy,px+h2,py+pdy
   ENDIF
   LIST.CREATE n,lptr
   LIST.ADD.ARRAY lptr,paLite[]
   LIST.CREATE n,bptr
   LIST.ADD.ARRAY bptr,paDark[]
   GR.COLOR palpha,BCMP[pbackcolor],GCMP[pbackcolor],RCMP[pbackcolor],bcFILL
   GR.RECT pbackptr,px+pHite,py+pHite,px+pdx-pHite,py+pdy-pHite
   GR.COLOR palpha,BCMP[bcWHITE],GCMP[bcWHITE],RCMP[bcWHITE],bcFILL
   GR.POLY gonum,lptr
   GR.COLOR palpha,BCMP[bcGRAY],GCMP[bcGRAY],RCMP[bcGRAY],bcFILL
   GR.POLY gonum,bptr
   IF IS_IN(bcNOBORDER$,pstyle$)=0 THEN
    IF IS_IN(bcBEVEL$,pstyle$)=0 THEN
     GR.COLOR palpha,BCMP[bcGRAY],GCMP[bcGRAY],RCMP[bcGRAY],bcNOFILL
     GR.LINE gonum,px,py,px+pHite,py+pHite
     GR.COLOR palpha,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
     GR.LINE gonum,px+pdx-pHite,py+pdy-pHite,px+pdx,py+pdy
    ELSE
     GR.COLOR palpha,BCMP[bcGRAY],GCMP[bcGRAY],RCMP[bcGRAY],bcNOFILL
     FOR i=5 TO 24
      LET paLite[i]=paLite[i]+1
     NEXT i
     GR.LINE gonum,paLite[5],paLite[6],paLite[23],paLite[24]
     GR.LINE gonum,paLite[7],paLite[8],paLite[21],paLite[22]
     GR.LINE gonum,paLite[9],paLite[10],paLite[19],paLite[20]
     GR.LINE gonum,paLite[11],paLite[12],paLite[17],paLite[18]
     GR.COLOR palpha,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
     GR.LINE gonum,paDark[3],paDark[4],paDark[13],paDark[14]
     GR.LINE gonum,paDark[5],paDark[6],paDark[11],paDark[12]
    ENDIF
    GR.COLOR palpha,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
    GR.POLY gonum,lptr
    GR.POLY gonum,bptr
   ENDIF
  ENDIF
 ENDIF
 GR.COLOR palpha,BCMP[ptextcolor],GCMP[ptextcolor],RCMP[ptextcolor],bcFILL
 IF IS_IN(bcGRAPHIC$,pstyle$)<>0 THEN
  IF pdx>pdy THEN
   LET ics=pdy-pHite*2-8
  ELSE
   LET ics=pdx-pHite*2-8
  ENDIF
  GR.BITMAP.LOAD pbmobj,pmark$
  GR.BITMAP.SIZE pbmobj,pw,pHite
  IF pw>=pHite THEN
   LET pHite=(ics*pHite)/pw
   LET pw=ics
  ELSE
   LET pw=(ics*pw)/pHite
   LET pHite=ics
  ENDIF
  GR.BITMAP.SCALE scobj,pbmobj,pw,pHite
  CALL @AddToBmpList(pKey$,1,scobj)
  GR.BITMAP.DRAW gonum,scobj,px+(pdx/2)-(ics/2),py+(pdy/2)-(ics/2)
  LET ptextptr=gonum
  GR.BITMAP.DELETE pbmobj
 ELSEIF IS_IN(bcMENUBTN$,pstyle$)<>0 THEN
  BUNDLE.GET 1,"frmscale",frmscale
  GR.BITMAP.CREATE membmp,40,40
  GR.BITMAP.DRAW INTO.START membmp
  GR.COLOR palpha,BCMP[pbackcolor],GCMP[pbackcolor],RCMP[pbackcolor],bcFILL
  GR.RECT pbackptr,0,0,40,40
  GR.COLOR palpha,BCMP[ptextcolor],GCMP[ptextcolor],RCMP[ptextcolor],bcFILL
  GR.RECT gonum,13,3,25,11
  GR.RECT gonum,13,15,25,23
  GR.RECT gonum,13,27,25,35
  GR.BITMAP.DRAW into.end
  GR.BITMAP.SCALE bmnuobj,membmp,pdx,pdy
  GR.BITMAP.DELETE membmp
  GR.BITMAP.DRAW gonum,bmnuobj,px,py
  CALL @AddToBmpList(pKey$,2,bmnuobj)
  LET ptextptr=gonum
 ELSE
  IF pfont=0 THEN
   IF LEFT$(pmark$,1)="<" | LEFT$(pmark$,1)=">" THEN
    LET h=(pdy-4*pHite)/2
    LET w=h
    LET y1=py+(pdy/2)
    LET y2=y1-h
    LET y3=y1+h
    UNDIM  paDark[]
    IF pmark$="<" THEN
     LET x1=px+(pdx/2)-(w/2)
     LET x2=x1+w
     LET x3=x2
    ELSEIF pmark$=">" THEN
     LET x1=px+(pdx/2)+(w/2)
     LET x2=x1-w
     LET x3=x2
    ELSEIF pmark$="<<" THEN
     LET x1=px+(pdx/2)-w
     LET x2=x1+w
     LET x3=x2
    ELSEIF pmark$=">>" THEN
     LET x1=px+(pdx/2)+w
     LET x2=x1-w
     LET x3=x2
    ENDIF
   ELSE
    LET h=pdy-4*pHite
    LET w=h/2
    LET x1=px+(pdx/2)
    LET x2=x1+w
    LET x3=x1-w
    UNDIM  paDark[]
    IF pmark$="^" THEN
     LET y1=py+(pdy/2)-(h/2)
     LET y2=y1+h
     LET y3=y2
    ELSEIF pmark$="v" THEN
     LET y1=py+(pdy/2)+(h/2)
     LET y2=y1-h
     LET y3=y2
    ELSEIF pmark$="^^" THEN
     LET y1=py+(pdy/2)-(h/2)
     LET y2=y1+h/2
     LET y3=y2
    ELSEIF pmark$="vv" THEN
     LET y1=py+(pdy/2)+(h/2)
     LET y2=y1-h/2
     LET y3=y2
    ENDIF
   ENDIF
   ARRAY.LOAD paDark[],x1,y1,x2,y2,x3,y3
   LIST.CREATE n,mptr
   LIST.ADD.ARRAY mptr,paDark[]
   GR.POLY gonum,mptr
   LET ptextptr=gonum
   IF pmark$="<<" THEN
    GR.POLY gonum,mptr,w,0
   ELSEIF pmark$=">>" THEN
    GR.POLY gonum,mptr,-w,0
   ELSEIF pmark$="^^" THEN
    GR.POLY gonum,mptr,0,h/2
   ELSEIF pmark$="vv" THEN
    GR.POLY gonum,mptr,0,-h/2
   ENDIF
  ELSE
   GR.TEXT.SIZE pfont
   CALL @setstyle(bcFRMBUTTON,pstyle$,"c")
   LET fo=@getfontyoffset(pdy,pfont)
   GR.TEXT.DRAW gonum,px+(pdx/2),py+fo,pmark$
   LET ptextptr=gonum
  ENDIF
 ENDIF
 FN.RTN gonum
FN.END
!
!  @ D R A W _ V S C R O L L
!
FN.DEF @DrawVScroll(ptrctrl,px,py,ph,palpha,pstyle$,pich)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcBLACK=1
 LET bcCYAN=4
 LET bcLBLUE=10
 LET bcLMAGENTA=14
 LET bcWHITE=16
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcNOBORDER$="-"
 GOSUB @LoadRGBData
 BUNDLE.GET ptrctrl,"pichscr",i
 IF i=1 THEN
  BUNDLE.GET ptrctrl,"hscrfirstobj",fobj
  BUNDLE.GET ptrctrl,"hscrlastobj",lobj
  FOR i=fobj TO lobj
   GR.MODIFY i,"alpha",bcTRANSPARENT
  NEXT i
 ENDIF
 BUNDLE.GET 1,"sbwidth",SBW
 LET px=px-SBW
 LET vtop=py+SBW
 LET vmid=py+(ph/2)
 LET vlth=(ph*(ph-SBW-SBW))/pich
 LET vmov=ph-SBW-SBW-vlth
 LET vpos=vmid-(vlth/2)
 LET vptop=py+ph-pich
 LET vpmov=pich-ph
 BUNDLE.PUT ptrctrl,"vscrslth",vlth
 BUNDLE.PUT ptrctrl,"vscrsmov",vmov
 BUNDLE.PUT ptrctrl,"vscrspos",vpos
 BUNDLE.PUT ptrctrl,"vscrptop",vptop
 BUNDLE.PUT ptrctrl,"vscrpmov",vpmov
 BUNDLE.GET ptrctrl,"picvscr",i
 BUNDLE.PUT ptrctrl,"scrstyp","V"
 IF i=1 THEN
  BUNDLE.GET ptrctrl,"vscrfirstobj",fobj
  BUNDLE.GET ptrctrl,"vscrlastobj",lobj
  FOR i= fobj TO lobj
   GR.MODIFY i,"alpha",palpha
  NEXT i
  CALL @UpdateVSlide(ptrctrl,vpos,vlth,pstyle$)
 ELSE
  BUNDLE.PUT ptrctrl,"picvscr",1
  BUNDLE.PUT ptrctrl,"scrssiz",SBW
  BUNDLE.PUT ptrctrl,"vscrstop",vtop
  BUNDLE.PUT ptrctrl,"vscrsmid",vmid
  BUNDLE.PUT ptrctrl,"vscrsbot",ph-SBW-SBW
  GR.COLOR palpha,BCMP[bcWHITE],GCMP[bcWHITE],RCMP[bcWHITE],bcFILL
  GR.RECT gonum,px,py+SBW,px+SBW,py+ph-SBW
  BUNDLE.PUT ptrctrl,"vscrfirstobj",gonum
  GR.COLOR palpha,BCMP[bcCYAN],GCMP[bcCYAN],RCMP[bcCYAN],bcFILL
  GR.RECT gonum,px,vpos,px+SBW,vpos+vlth
  BUNDLE.PUT ptrctrl,"vscrslidebak",gonum
  GR.COLOR palpha,BCMP[bcLMAGENTA],GCMP[bcLMAGENTA],RCMP[bcLMAGENTA],bcFILL
  GR.RECT gonum,px+5,vpos+5,px+SBW-5,vpos+vlth-5
  IF IS_IN(bcNOBORDER$,pstyle$)=0 THEN
   GR.COLOR a,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
   GR.RECT gonum,px,py,px+SBW,py+ph
   GR.RECT gonum,px,py+SBW,px+SBW,py+ph-SBW
   GR.RECT gonum,px,vpos,px+SBW,vpos+vlth
   BUNDLE.PUT ptrctrl,"vscrslidebdr",gonum
   GR.RECT gonum,px+5,vpos+5,px+SBW-5,vpos+vlth-5
  ENDIF
  LET gonum=@drawbutton("VSUp"+INT$(ptrctrl),bcLBLUE,bcWHITE,px,py,SBW,SBW,7,pstyle$,0,"^", ~
            palpha,textptr,backptr)
  LET gonum=@drawbutton("VSDn"+INT$(ptrctrl),bcLBLUE,bcWHITE,px,py+ph-SBW,SBW,SBW,7,pstyle$,0,"v", ~
            palpha,textptr,backptr)
  BUNDLE.PUT ptrctrl,"vscrlastobj",gonum
 ENDIF
 FN.RTN 0
FN.END
!
!  @ U P D A T E _ V S L I D E
!
FN.DEF @UpdateVSlide(ptrctrl,vpos,vlth,pstyle$)
 LET bcNOBORDER$="-"
 BUNDLE.GET ptrctrl,"vscrslidebak",slidebakptr
 GR.MODIFY slidebakptr,"top",vpos,"bottom",vpos+vlth
 GR.MODIFY slidebakptr+1,"top",vpos+5,"bottom",vpos+vlth-5
 IF IS_IN(bcNOBORDER$,pstyle$)=0 THEN
  BUNDLE.GET ptrctrl,"vscrslidebdr",slidebdrptr
  GR.MODIFY slidebdrptr,"top",vpos,"bottom",vpos+vlth
  GR.MODIFY slidebdrptr+1,"top",vpos+5,"bottom",vpos+vlth-5
 ENDIF
 BUNDLE.PUT ptrctrl,"vscrspos",vpos
 FN.RTN 0
FN.END
!
!  @ S E T _ S T Y L E
!
FN.DEF @setstyle(pctrltype,pstyle$,smode$)
 LET bcFRMDISPLAY=1
 LET bcFRMSTRING=2
 LET bcFRMTEXT=3
 LET bcFRMSELECT=4
 LET bcFRMBUTTON=6
 LET bcFRMLABEL=8
 LET bcFRMLISTBOX=9
 LET bcFRMSPINBUTTON=12
 LET bcFRMFRAME=13
 LET bcALIGNCENTRE$="C"
 LET bcALIGNRIGHT$="R"
 LET bcALIGNDATCENTRE$="c"
 LET bcALIGNDATRIGHT$="r"
 LET bcCAPBOLD$="b"
 LET bcCAPITALIC$="i"
 LET bcCAPUNDERLINE$="u"
 LET bcDATBOLD$="B"
 LET bcDATITALIC$="I"
 LET bcDATUNDERLINE$="U"
 LET bcLISTBOXRIGHT$="x"
 BUNDLE.GET 1,"fontptrs",fontptr
 BUNDLE.GET 1,"fontcnt",fontcnt
 IF smode$="c" THEN
  IF pctrltype=bcFRMBUTTON THEN
   GR.TEXT.ALIGN 2
  ELSE
   IF IS_IN(bcALIGNCENTRE$,pstyle$)>0 THEN
    GR.TEXT.ALIGN 2
   ELSEIF IS_IN(bcALIGNRIGHT$,pstyle$)>0 THEN
    GR.TEXT.ALIGN 3
   ELSE
    GR.TEXT.ALIGN 1
   ENDIF
  ENDIF
  BUNDLE.GET 1,"capfonts",capfonts
  LET j=1
  LET k=1
  FOR i=1 TO fontcnt
   LIST.GET capfonts,i,k$
   IF IS_IN(k$,pstyle$)>0 THEN
    LIST.GET fontptr,i,j
    LET k=i
    F_N.BREAK
   ENDIF
  NEXT i
  IF k<5 THEN GR.TEXT.TYPEFACE j ELSE GR.TEXT.SETFONT j
  LET sbold$=bcCAPBOLD$
  LET sital$=bcCAPITALIC$
  LET sundr$=bcCAPUNDERLINE$
 ELSE
  IF pctrltype=bcFRMSELECT | pctrltype=bcFRMSPINBUTTON THEN
   GR.TEXT.ALIGN 2
  ELSE
   IF pctrltype=bcFRMLISTBOX & IS_IN(bcLISTBOXRIGHT$,pstyle$)>0 THEN
    GR.TEXT.ALIGN 3
   ELSEIF pctrltype=bcFRMDISPLAY | pctrltype=bcFRMSTRING | pctrltype=bcFRMTEXT THEN
    IF IS_IN(bcALIGNDATCENTRE$,pstyle$)>0 THEN
     GR.TEXT.ALIGN 2
    ELSEIF IS_IN(bcALIGNDATRIGHT$,pstyle$)>0 THEN
     GR.TEXT.ALIGN 3
    ELSE
     GR.TEXT.ALIGN 1
    ENDIF
   ELSE
    GR.TEXT.ALIGN 1
   ENDIF
  ENDIF
  BUNDLE.GET 1,"datfonts",datfonts
  LET j=1
  LET k=1
  FOR i=1 TO fontcnt
   LIST.GET datfonts,i,k$
   IF IS_IN(k$,pstyle$)>0 THEN
    LIST.GET fontptr,i,j
    LET k=i
    F_N.BREAK
   ENDIF
  NEXT i
  IF k<5 THEN GR.TEXT.TYPEFACE j ELSE GR.TEXT.SETFONT j
  LET sbold$=bcDATBOLD$
  LET sital$=bcDATITALIC$
  LET sundr$=bcDATUNDERLINE$
 ENDIF
 IF IS_IN(sbold$,pstyle$)>0 THEN GR.TEXT.BOLD 1 ELSE GR.TEXT.BOLD 0
 IF IS_IN(sital$,pstyle$)>0 THEN GR.TEXT.SKEW-0.25 ELSE GR.TEXT.SKEW 0
 IF IS_IN(sundr$,pstyle$)>0 THEN
  GR.TEXT.UNDERLINE 1
 ELSE
  GR.TEXT.UNDERLINE 0
 ENDIF
 FN.RTN 0
FN.END
!
!  L O A D _ U S E R _ F O N T
!
FN.DEF LoadUserFont(pfname$,pcapkey$,pdatkey$)
 BUNDLE.GET 1,"fontcnt",fontcnt
 IF fontcnt<9 THEN
  BUNDLE.GET 1,"fontptrs",fontptr
  BUNDLE.GET 1,"capfonts",capfonts
  BUNDLE.GET 1,"datfonts",datfonts
  FONT.LOAD fpn,pfname$
  fontcnt=fontcnt+1
  BUNDLE.PUT 1,"fontcnt",fontcnt
  LIST.REPLACE fontptr,fontcnt,fpn
  LIST.GET capfonts,fontcnt,pcapkey$
  LIST.GET datfonts,fontcnt,pdatkey$
 ELSE
  pcapkey$="1"
  pdatkey$="1"
 ENDIF
 FN.RTN 0
FN.END
!
!  L O A D _ U S E R _ F O N T
!
FN.DEF ClearUserFonts()
 FONT.CLEAR
 BUNDLE.PUT 1,"fontcnt",4
 FN.RTN 0
FN.END
!
!  @ G E T _ F O N T _ Y _ O F F S E T
!
FN.DEF @getfontyoffset(prowsize,pfont)
 GR.TEXT.HEIGHT h,u,d
 LET fo=((prowsize-pfont)/2)-u
 FN.RTN fo
FN.END
!
!  @ S O U N D _ R T N
!
FN.DEF @soundrtn()
 LET bcSOUNDOFF$="N"
 BUNDLE.GET 1,"sound",bsound$
 IF bsound$<>bcSOUNDOFF$ THEN
  BUNDLE.GET 1,"sndptr",sndptr
  IF sndptr<>0 THEN
   AUDIO.STOP
   AUDIO.PLAY sndPtr
  ELSE
   TONE 10000,200
  ENDIF
 ENDIF
 FN.RTN 0
FN.END
!
!  @ C H E C K _ F O R _ A L L O W _ N E W
!
FN.DEF @CheckForAllowNew(pCtrl,pStyle$,pMode$)
 LET bcFILL=1
 LET bcOPAQUE=255
 LET bcFRMCOMBOBOX=15
 LET bcLGREEN=11
 LET bcWHITE=16
 LET bcALLOWNEW$="N"
 IF pStyle$=bcALLOWNEW$ THEN
  BUNDLE.GET pctrl,"type",ctype
  IF ctype=bcFRMCOMBOBOX THEN
   GOSUB @LoadRGBData
   BUNDLE.GET pctrl,"combobtnbak",btnbak
   IF pMode$="A" THEN LET i=bcLGREEN ELSE LET i=bcWHITE
   GR.COLOR bcOPAQUE,BCMP[i],GCMP[i],RCMP[i],bcFILL
   GR.PAINT.GET pptr
   GR.MODIFY btnbak,"paint",pptr
  ENDIF
 ENDIF
 FN.RTN 0
FN.END
!
!  S E T _ C O L O R
!
FN.DEF setcolor(palpha,pcolor,pfill)
 LET lred=FLOOR(pcolor/65536)
 LET ltemp=MOD(pcolor,65536)
 LET lgreen=FLOOR(ltemp/256)
 LET lblue=MOD(ltemp,256)
 GR.COLOR palpha,lblue,lgreen,lred,pfill
 FN.RTN 0
FN.END
!
!  S E T _ S O U N D
!
FN.DEF setsound(psound$)
 BUNDLE.PUT 1,"sound",LEFT$(psound$,1)
 FN.RTN 0
FN.END
!
!  S E T _ H O U R G L A SS
!
FN.DEF sethourglass(phg$)
 BUNDLE.PUT 1,"hourglass",LEFT$(phg$,1)
 FN.RTN 0
FN.END
!
!  J O I N $
!
FN.DEF join$(parray$[],pbreak$)
 ARRAY.LENGTH j,parray$[]
 LET js$=parray$[1]
 FOR i=2 TO j
  LET js$=js$+pbreak$+parray$[i]
 NEXT i
 FN.RTN js$
FN.END
!
!  N U M _ TO _ S T R $
!
FN.DEF NumToStr$(pn,s,d,o)
 LET n=ABS(pn)
 IF o>0 THEN
  IF o>3 THEN
   LET o=o+1
  ENDIF
  IF o>7 THEN
   LET o=o+1
  ENDIF
  LET f$=RIGHT$("%%%,%%%,%%%",o)
 ELSE
  LET f$="###,###,##%"
 ENDIF
 IF d>0 THEN
  LET f$=f$+LEFT$(".######",d+1)
 ENDIF
 IF s=0 THEN LET f$=REPLACE$(f$,",","")
 LET s$=REPLACE$(FORMAT$(f$,n)," ","")
 IF n<>pn THEN LET s$="-"+s$
 FN.RTN s$
FN.END
!
!  C H E C K _ V A L I D _ N A M E
!
FN.DEF CheckValidName(pName$)
 LET bcEXCLAMATION$="e"
 LET bcDBLQUOTE$=CHR$(34)
 LET bcBACKSLASH$=CHR$(92)
 LET bcRECBREAK$=CHR$(174)
 ARRAY.LOAD c$[],bcBACKSLASH$,"/",":","*","?",bcDBLQUOTE$,"<",">","|"
 LET rc=0
 FOR i=1 TO 9
  IF IS_IN(c$[i],pName$)<>0 THEN
   LET i$=JOIN$(c$[],"  ")
   LET rc$=MsgBox$("Invalid Character ('"+c$[i]+"') in file name."+bcRECBREAK$+bcRECBREAK$ ~
           +"A file name can't contain any of the following characters"+bcRECBREAK$+"    "+i$, ~
           bcEXCLAMATION$+bcOKONLY$,"Invalid File Name")
   LET rc=1
   F_N.BREAK
  ENDIF
 NEXT i
 FN.RTN rc
FN.END
!
!  S T R I N G $
!
FN.DEF string$(pcnt,pchar$)
 LET s$=""
 FOR i=1 TO pcnt
  LET s$=s$+pchar$
 NEXT i
 FN.RTN s$
FN.END
!
! G E T _ G C _ V E R S
!
FN.DEF getGCVer$()
 BUNDLE.GET 1,"GCVer",GCVer$
 FN.RTN GCVer$
FN.END
!
!  A D D _ C T R L _ S T Y L E
!
FN.DEF AddCtrlStyle(pCtrlNo,pStyle$)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlNo),ptrCtrl
 BUNDLE.GET ptrCtrl,"style",i$
 LET i$=i$+pStyle$
 BUNDLE.PUT ptrCtrl,"style",i$
 CALL @CheckForAllowNew(ptrCtrl,pStyle$,"A")
 FN.RTN 0
FN.END
!
!  R E M O V E _ C T R L _ S T Y L E
!
FN.DEF RemoveCtrlStyle(pCtrlNo,pStyle$)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlNo),ptrCtrl
 BUNDLE.GET ptrCtrl,"style",i$
 FOR i=1 TO LEN(pStyle$)
  LET i$=REPLACE$(i$,MID$(pStyle$,i,1),"")
 NEXT i
 BUNDLE.PUT ptrCtrl,"style",i$
 CALL @CheckForAllowNew(ptrCtrl,pStyle$,"R")
 FN.RTN 0
FN.END
!
!  G E T _ C T R L _ S I Z E
!
FN.DEF GetCtrlSize(pCtrlNo,pX,pY,pW,pH)
 LET bcFRMPICTURE=7
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlNo),ptrCtrl
 BUNDLE.GET ptrctrl,"top",pY
 BUNDLE.GET ptrctrl,"left",pX
 BUNDLE.GET ptrctrl,"width",pW
 BUNDLE.GET ptrctrl,"height",pH
 BUNDLE.GET ptrctrl,"type",ctype
 IF ctype=bcFRMPICTURE THEN
  BUNDLE.GET ptrctrl,"picsbwx",PicSBWX
  BUNDLE.GET ptrctrl,"picsbwy",PicSBWY
  pW=pW-picSBWY
  pH=pH-picSBWX
 ENDIF
 FN.RTN 0
FN.END
!
!  M O V E _ C T R L
!
FN.DEF MoveCtrl(pCtrlNo,pType$,pX,pY,pW,pH,pRend)
 LET bcFRMLABEL=8
 LET bcFRMPICTURE=7
 LET bcFRMSHAPE=14
 LET bcSHAPEFILL$="f"
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlNo),ptrCtrl
 BUNDLE.GET ptrctrl,"type",ctype
 IF ctype=bcFRMLABEL | ctype=bcFRMSHAPE | ctype=bcFRMPICTURE THEN
  IF UPPER$(pType$)="R" THEN
   BUNDLE.GET ptrctrl,"left",x
   BUNDLE.GET ptrctrl,"top",y
   LET pX=x+pX
   LET pY=y+pY
  ENDIF
  BUNDLE.GET ptrctrl,"captxtobj",ctobj
  IF ctype=bcFRMLABEL THEN
   BUNDLE.GET ptrCtrl,"style",s$
   BUNDLE.GET ptrctrl,"font",fs
   GR.TEXT.SIZE fs
   IF IS_IN(bcALIGNCENTRE$,i$)<>0 | IS_IN(bcALIGNRIGHT$,i$)<>0 THEN
    BUNDLE.PUT ptrctrl,"origcap",c$
    GR.GET.TEXTBOUNDS c$,x,y,cx,cy
    IF IS_IN(bcALIGNCENTRE$,i$)<>0 THEN Xoff=(pW/2)-(cx/2) ELSE Xoff=pW
   ELSE
    BUNDLE.GET ptrctrl,"captxtxoff",Xoff
   ENDIF
   BUNDLE.GET ptrctrl,"captxtyoff",Yoff
   GR.TEXT.HEIGHT h,u,d
   GR.PAINT.GET pfs
   GR.MODIFY ctobj,"paint",pfs,"x",pX+Xoff,"y",pY+((pH-d+u)/2)-u
  ELSEIF ctype=bcFRMPICTURE THEN
   BUNDLE.GET ptrctrl,"picclip",ctobj
   GR.MODIFY ctobj,"left",pX,"top",pY,"right",pX+pW,"bottom",pY+pH
   BUNDLE.PUT ptrctrl,"top",pY
   BUNDLE.PUT ptrctrl,"left",pX
   BUNDLE.PUT ptrctrl,"width",pW
   BUNDLE.PUT ptrctrl,"height",pH
   BUNDLE.GET ptrctrl,"data",value$
   CALL modctrldata(pctrlno,value$,pRend)
  ELSEIF ctype=bcFRMSHAPE THEN
   BUNDLE.GET ptrctrl,"sizecap",cap$
   LET cap$=LOWER$(cap$)
   IF cap$="rndrect" THEN
    BUNDLE.GET ptrctrl,"firstgrptr",gonum
    IF pW>=pH THEN LET i=pH ELSE i=pW 
    IF i<43 THEN LET cr=(i-2)/2 ELSE LET cr=20 
    cd=2*cr
    hz=pW-cd
    vt=pH-cd
    GR.MODIFY gonum,"left",pX+cr,"top",pY,"right",pX+cr+hz,"bottom",pY+pH
    GR.MODIFY gonum+1,"left",pX,"top",pY+cr,"right",pX+cr,"bottom",pY+cr+vt
    GR.MODIFY gonum+2,"left",pX+pW-cr,"top",pY+cr,"right",pX+pW,"bottom",pY+cr+vt
    GR.MODIFY gonum+3,"left",pX,"top",pY,"right",pX+cd,"bottom",pY+cd
    GR.MODIFY gonum+4,"left",pX+hz,"top",pY,"right",pX+pW,"bottom",pY+cd
    GR.MODIFY gonum+5,"left",pX,"top", pY+vt,"right",pX+cd,"bottom",pY+pH
    GR.MODIFY gonum+6,"left",pX+hz,"top",pY+vt,"right",pX+hz+cd,"bottom",pY+pH
    GR.MODIFY gonum+7,"x1",pX+cr,"y1",pY,"x2",pX+cr+hz,"y2",pY
    GR.MODIFY gonum+8,"x1",pX+cr,"y1",pY+pH,"x2",pX+cr+hz,"y2",pY+pH
    GR.MODIFY gonum+9,"x1",pX,"y1",pY+cr,"x2",pX,"y2",pY+cr+vt
    GR.MODIFY gonum+10,"x1",pX+pW,"y1",pY+cr,"x2",pX+pW,"y2",pY+cr+vt
    GR.MODIFY gonum+11,"left",pX,"top",pY,"right",pX+cd,"bottom",pY+cd
    GR.MODIFY gonum+12,"left",pX+hz,"top",pY,"right",pX+pW,"bottom",pY+cd
    GR.MODIFY gonum+13,"left",pX,"top",pY+vt,"right",pX+cd,"bottom",pY+pH
    GR.MODIFY gonum+14,"left",pX+hz,"top",pY+vt,"right",pX+hz+cd,"bottom",pY+pH
   ELSE
    IF cap$="circle" THEN
     LET tx$="x"
     LET ty$="y"
     LET tr$=""
     GR.MODIFY ctobj,"radius",pW
    ELSEIF cap$="line" THEN
     LET tx$="x1"
     LET ty$="y1"
     LET tr$="x2"
     LET tb$="y2"
    ELSE
     LET tx$="left"
     LET ty$="top"
     LET tr$="right"
     LET tb$="bottom"
    ENDIF
    GR.MODIFY ctobj,tx$,pX,ty$,pY
    IF tr$<>"" THEN
     GR.MODIFY ctobj,tr$,pX+pW,tb$,pY+pH
    ENDIF
    BUNDLE.GET ptrCtrl,"style",i$
    IF IS_IN(bcSHAPEFILL$,i$)<>0 THEN
     BUNDLE.GET ptrctrl,"capbakobj",cbobj
     GR.MODIFY cbobj,tx$,pX,ty$,pY
     IF tr$<>"" THEN
      GR.MODIFY cbobj,tr$,pX+pW,tb$,pY+pH
     ELSE
      IF cap$="circle" THEN GR.MODIFY cbobj,"radius",pW
     ENDIF
    ENDIF
   ENDIF
   BUNDLE.PUT ptrctrl,"top",pY
   BUNDLE.PUT ptrctrl,"left",pX
   BUNDLE.PUT ptrctrl,"width",pW
   BUNDLE.PUT ptrctrl,"height",pH
   IF pRend=1 THEN
    GR.RENDER
   ENDIF
  ENDIF
 ENDIF
 FN.RTN 0
FN.END
!
!  S E T _ M B _ T Y P E _ C L R S
!
FN.DEF setMBTypeClrs(pType$)
 LET bcBLACK=1
 LET bcBLUE=2
 LET bcGREEN=3
 LET bcRED=5
 LET bcMAGENTA=6
 LET bcYELLOW=7
 LET bcLGRAY=9
 LET bcLBLUE=10
 LET bcLGREEN=11
 LET bcLRED=13
 LET bcLMAGENTA=14
 LET bcLYELLOW=15
 LET bcWHITE=16
 IF pType$="I" THEN CALL setmsgboxcolours(bcGREEN,bcWHITE,bcLGREEN,bcLGRAY,bcWHITE,bcBLACK,bcBLACK)
 IF pType$="Q" THEN CALL setmsgboxcolours(bcBLUE,bcWHITE,bcLBLUE,bcLGRAY,bcWHITE,bcBLACK,bcBLACK)
 IF pType$="E" THEN CALL setmsgboxcolours(bcYELLOW,bcWHITE,bcYELLOW,bcLYELLOW,bcBLACK,bcBLACK,bcBLACK)
 IF pType$="C" THEN CALL setmsgboxcolours(bcRED,bcWHITE,bcLRED,bcLRED,bcLYELLOW,bcBLACK,bcRED)
 FN.RTN 0
FN.END
!
!  S E T _ M S G B O X _ C O L O U R S
!
FN.DEF setmsgboxcolours(phedclr,pbdyclr,pbtnbdrclr,pbtnbdyclr,phedtxtclr,pbdytxtclr,pbtntxtclr)
 BUNDLE.PUT 1,"msghedclr",phedclr
 BUNDLE.PUT 1,"msgbdyclr",pbdyclr
 BUNDLE.PUT 1,"msgbtnbdrclr",pbtnbdrclr
 BUNDLE.PUT 1,"msgbtnbdyclr",pbtnbdyclr
 BUNDLE.PUT 1,"msghedtxtclr",phedtxtclr
 BUNDLE.PUT 1,"msgbdytxtclr",pbdytxtclr
 BUNDLE.PUT 1,"msgbtntxtclr",pbtntxtclr
 FN.RTN 0
FN.END
!
!  S E T _ C A L _ C O L O U R S
!
FN.DEF setcalcolours(calbak,mybuttext,mybutface,ymtext,dayheadbak,dayheadtxt,ssbak,mtwtfbak, ~
       gridcol,daynotxt,seldaybak,scbuttext,scbutface)
 BUNDLE.PUT 1,"calbak",calbak
 BUNDLE.PUT 1,"mybuttext",mybuttext
 BUNDLE.PUT 1,"mybutface",mybutface
 BUNDLE.PUT 1,"ymtext",ymtext
 BUNDLE.PUT 1,"dayheadbak",dayheadbak
 BUNDLE.PUT 1,"dayheadtxt",dayheadtxt
 BUNDLE.PUT 1,"ssbak",ssbak
 BUNDLE.PUT 1,"mtwtfbak",mtwtfbak
 BUNDLE.PUT 1,"gridcol",gridcol
 BUNDLE.PUT 1,"daynotxt",daynotxt
 BUNDLE.PUT 1,"seldaybak",seldaybak
 BUNDLE.PUT 1,"scbuttext",scbuttext
 BUNDLE.PUT 1,"scbutface",scbutface
 FN.RTN 0
FN.END

!#@#@#@#_picture_control

!
!  @ D R A W _ P I C T U R E
!
FN.DEF @drawpicturertn(ptrctrl,ctrlno,pmode,ppicname$,cTop,cLeft,pWidth,pHeight,pMiddle, ~
       pctrlcaptxtclr,pctrlcapbakclr,pctrlcaptxtobj,pctrlcapbakobj)
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcBLACK=1
 LET bcPICSIZE$="P"
 LET bcPICCROP$="q"
 LET bcPICSCROLL$="S"
 LET bcNOBORDER$="-"
 LET bcPICROTATE$="@"
 GOSUB @LoadRGBData
 BUNDLE.GET 1,"picpath",PicPath$
 BUNDLE.GET ptrctrl,"style",ctrlstyle$
 IF pctrlcaptxtobj<>0 THEN
  CALL @AddToBmpList("P",ptrctrl,-1)
 ENDIF
 LET cWidth=pWidth
 LET cHeight=pHeight
 IF ppicname$="" | RIGHT$(ppicname$,4)="<na>" THEN
  LET stemp$=""
 ELSE
  LET stemp$=ppicname$
  IF IS_IN("/",ppicname$)=0 THEN
   LET stemp$=PicPath$+stemp$
  ENDIF
  FILE.EXISTS i,stemp$
  IF i=0 THEN
   LET stemp$="Warning: Picture File '"+stemp$+"' does not exist!"
   POPUP stemp$,0,0,1
   LET stemp$=""
  ENDIF
 ENDIF
 LET sb=IS_IN(bcPICSCROLL$,ctrlstyle$)
 LET si=IS_IN(bcPICSIZE$,ctrlstyle$)
 LET sc=IS_IN(bcPICCROP$,ctrlstyle$)
 LET sbt=0
 LET dWidth=cWidth
 LET dHeight=cHeight
 LET PicSBWX=0
 LET PicSBWY=0
 IF stemp$="" THEN
  LET picwidth=cWidth
  LET picheight=cHeight
  GR.COLOR bcOPAQUE,BCMP[pctrlcapbakclr],GCMP[pctrlcapbakclr],RCMP[pctrlcapbakclr],bcFILL
  GR.BITMAP.CREATE pctrlcaptxtobj,dWidth,dHeight
  GR.BITMAP.DRAW INTO.START pctrlcaptxtobj
  GR.RECT gonum,1,1,dWidth-1,dHeight-1
  GR.BITMAP.DRAW INTO.END
 ELSE
  GR.BITMAP.LOAD pbmobj,stemp$
  GR.BITMAP.SIZE pbmobj,picwidth,picheight
  IF picwidth<>cWidth | picheight<>cHeight THEN
   IF si<>0 THEN
    IF picwidth>=picheight THEN
     LET dWidth=(cHeight*picwidth)/picheight
     LET dHeight=cHeight
    ELSEIF picwidth<picheight THEN
     LET dHeight=(cWidth*picheight)/picwidth
     LET dWidth=cWidth
    ELSE
     LET dHeight=cHeight
     LET dWidth=cWidth
    ENDIF
    IF sb<>0 THEN
     BUNDLE.GET 1,"sbwidth",SBW
     IF picwidth>picheight THEN
      LET dHeight=dHeight-SBW
      LET i=dHeight/cHeight
      LET dWidth=dWidth*i
      CALL @DrawHScroll(ptrctrl,cLeft,cTop+cHeight,cWidth,bcOPAQUE,ctrlstyle$,dwidth)
      PicSBWX=SBW
     ELSEIF picwidth<picheight THEN
      LET dWidth=dWidth-SBW
      LET i=dWidth/cWidth
      LET dHeight=dHeight*i
      CALL @DrawVScroll(ptrctrl,cLeft+cWidth,cTop,cHeight,bcOPAQUE,ctrlstyle$,dheight)
      PicSBWY=SBW
     ENDIF
    ENDIF
   ELSE
    IF sc=0 THEN
     IF picwidth>=picheight THEN
      IF picwidth>cWidth THEN
       LET dHeight=(cWidth/picwidth)*picheight
       LET dWidth=cWidth
      ELSE
       LET dWidth=(cHeight/picheight)*picwidth
       LET dHeight=cHeight
      ENDIF
     ELSE
      IF picHeight>=cHeight THEN
       LET dWidth=(cHeight/picheight)*picwidth
       LET dHeight=cHeight
      ELSE
       LET dHeight=(cWidth/picwidth)*picheight
       LET dWidth=cWidth
      ENDIF
     ENDIF
    ELSE
     IF picwidth>picheight THEN LET s=dWidth/picwidth ELSE LET s=dheight/picheight
     LET dWidth=picWidth*s
     LET dHeight=picHeight*s
     LET cWidth=dWidth
     LET cHeight=dHeight
    ENDIF
   ENDIF
   GR.BITMAP.SCALE pctrlcaptxtobj,pbmobj,dWidth,dHeight
   GR.BITMAP.DELETE pbmobj
  ELSE
   LET dWidth=cWidth
   LET dHeight=cHeight
   LET pctrlcaptxtobj=pbmobj
  ENDIF
 ENDIF
 CALL @AddToBmpList("P",ptrctrl,pctrlcaptxtobj)
 IF si=0 THEN
  IF cWidth>dWidth THEN LET w=(cWidth-dWidth)/2 ELSE LET w=(dWidth-cWidth)/2
  IF cHeight>dHeight THEN LET h=(cHeight-dHeight)/2 ELSE LET h=(dHeight-cHeight)/2
 ELSE
  IF dWidth>cWidth THEN LET w=-(dWidth-cWidth)/2 ELSE LET w=0
  IF dHeight>=cHeight THEN LET h=-(dHeight-cHeight)/2 ELSE LET h=0
 ENDIF
 IF si=1 | sc=0 THEN
  LET u=0
  LET v=0
 ELSE
  LET cwidth=dwidth
  LET cheight=dheight
  IF sc=0 THEN
   LET u=w
   LET v=h
  ENDIF
 ENDIF  
 LET i=dWidth/picwidth
 BUNDLE.PUT ptrctrl,"picscale",i
 BUNDLE.PUT ptrctrl,"picwidth",picwidth
 BUNDLE.PUT ptrctrl,"picheight",picheight
 BUNDLE.PUT ptrctrl,"picxoff",-w
 BUNDLE.PUT ptrctrl,"picyoff",-h
 BUNDLE.PUT ptrctrl,"picsbwx",PicSBWX
 BUNDLE.PUT ptrctrl,"picsbwy",PicSBWY
 IF pmiddle=0 THEN LET lalpha=bcTRANSPARENT ELSE LET lalpha=bcOPAQUE
 IF pmode=0 THEN
  IF IS_IN(bcPICROTATE$,ctrlstyle$)<>0 THEN
   BUNDLE.GET ptrctrl,"picangle",i
   GR.ROTATE.START i,cLeft+pwidth/2,cTop+pheight/2,gonum
   BUNDLE.PUT ptrctrl,"picrotate",gonum
  ENDIF
  BUNDLE.GET ptrctrl,"picmark",ps
  IF ps=0 THEN
   LET lalp=bcTRANSPARENT
  ELSE
   GOSUB @SetPicMarkCoords
   LET lalp=bcOPAQUE
  ENDIF
  GR.COLOR lalpha,BCMP[pctrlcapbakclr],GCMP[pctrlcapbakclr],RCMP[pctrlcapbakclr],bcNOFILL
  GR.SET.STROKE 3
  GR.RECT gonum,ml,mt,mr,mb
  BUNDLE.PUT ptrctrl,"picmobj",gonum
  GR.SET.STROKE 1
  GR.LINE gonum,ml,mt,pl,pt
  GR.LINE gonum,mr,mt,pr,pt
  GR.LINE gonum,ml,mb,pl,pb
  GR.LINE gonum,mr,mb,pr,pb
  GR.SET.STROKE 0
  BUNDLE.GET ptrctrl,"origcap",i$
  IF i$="" THEN LET lalp=bcTRANSPARENT ELSE LET lalp=bcOPAQUE
  GR.COLOR lalp,BCMP[pctrlcaptxtclr],GCMP[pctrlcaptxtclr],RCMP[pctrlcaptxtclr],bcFILL
  BUNDLE.GET 1,"frmscale",frmscale
  BUNDLE.GET ptrctrl,"font",ch
  GR.TEXT.SIZE ch
  GR.TEXT.ALIGN 2
  LET cx=cleft+u+(cWidth/2)
  LET cy=ctop+v+cheight+(4/frmscale)
  GR.TEXT.WIDTH cw,i$
  GR.TEXT.HEIGHT hv,uv,dv
  LET cw=cw+(8/frmscale)
  LET ch=dv-uv+(8/frmscale)
  GR.COLOR lalp,BCMP[pctrlcapbakclr],GCMP[pctrlcapbakclr],RCMP[pctrlcapbakclr],bcFILL
  GR.ARC gonum,cx-cw/2-ch/2,cy,cx-cw/2+ch/2,cy+ch,80,200,1
  BUNDLE.PUT ptrctrl,"picbak",gonum
  GR.ARC gonum,cx+cw/2-ch/2,cy,cx+cw/2+ch/2,cy+ch,260,200,1
  GR.RECT gonum,cx-cw/2-1,cy,cx-cw/2+cw,cy+ch
  GR.COLOR lalp,BCMP[pctrlcaptxtclr],GCMP[pctrlcaptxtclr],RCMP[pctrlcaptxtclr],bcFILL
  GR.TEXT.DRAW gonum,cx,cy-uv+4/frmscale,i$
  BUNDLE.PUT ptrctrl,"piccap",gonum
  IF IS_IN(bcNOBORDER$,ctrlstyle$)=0 THEN
   GR.SET.STROKE pmiddle
   GR.COLOR lalpha,BCMP[pctrlcaptxtclr],GCMP[pctrlcaptxtclr],RCMP[pctrlcaptxtclr],bcNOFILL
   GR.RECT gonum,cLeft-1+u,cTop-1+v,cLeft+cWidth+1+u,cTop+cHeight+1+v
   BUNDLE.PUT ptrctrl,"picborder",gonum
   GR.SET.STROKE 0
  ENDIF
  GR.CLIP gonum,cLeft+u,cTop+v,cLeft+cWidth+u,cTop+cHeight+v,2
  BUNDLE.PUT ptrctrl,"picclip",gonum
  GR.BITMAP.DRAW gonum,pctrlcaptxtobj,cLeft+w,cTop+h
  GR.MODIFY gonum,"alpha",bcOPAQUE
  LET pctrlcapbakobj=gonum
  IF IS_IN(bcPICROTATE$,ctrlstyle$)<>0 THEN
   GR.ROTATE.END
  ENDIF
  BUNDLE.GET 1,"swidth",swidth
  BUNDLE.GET 1,"sheight",sheight
  GR.CLIP gonum,0,0,swidth,sheight,2
 ELSE
  IF IS_IN(bcPICROTATE$,ctrlstyle$)<>0 THEN
   BUNDLE.GET ptrctrl,"picrotate",i
   BUNDLE.GET ptrctrl,"picangle",j
   GR.MODIFY i,"x",cLeft+pwidth/2,"y",cTop+pheight/2,"angle",j
  ENDIF
  GR.COLOR lalpha,BCMP[pctrlcaptxtclr],GCMP[pctrlcaptxtclr],RCMP[pctrlcaptxtclr],bcNOFILL
  IF IS_IN(bcNOBORDER$,ctrlstyle$)=0 THEN
   BUNDLE.GET ptrctrl,"picborder",gonum
   GR.SET.STROKE pmiddle
   GR.PAINT.GET pset
   GR.MODIFY gonum,"left",cLeft-1+u,"top",cTop-1+v,"right",cLeft+cWidth+1+u,"bottom", ~
      cTop+cHeight+1+v,"alpha",lalpha,"paint",pset
   GR.SET.STROKE 0
  ENDIF
  BUNDLE.GET ptrctrl,"picmark",ps
  BUNDLE.GET ptrctrl,"picmobj",gonum
  IF ps=0 THEN
   LET lalpha=bcTRANSPARENT
  ELSE
   GOSUB @SetPicMarkCoords
   LET lalpha=bcOPAQUE
   GR.SET.STROKE 3
  ENDIF
  GR.COLOR lalpha,BCMP[pctrlcapbakclr],GCMP[pctrlcapbakclr],RCMP[pctrlcapbakclr],bcFILL
  GR.PAINT.GET psetb
  GR.COLOR lalpha,BCMP[pctrlcaptxtclr],GCMP[pctrlcaptxtclr],RCMP[pctrlcaptxtclr],bcFILL
  GR.PAINT.GET pset
  BUNDLE.GET 1,"frmscale",frmscale
  BUNDLE.GET ptrctrl,"font",ch
  GR.TEXT.SIZE ch
  GR.TEXT.ALIGN 2
  GR.PAINT.RESET pset
  GR.MODIFY gonum,"left",ml,"top",mt,"right",mr,"bottom",mb,"paint",pset
  GR.SET.STROKE 1
  GR.PAINT.GET pset
  GR.MODIFY gonum+1,"x1",ml,"y1",mt,"x2",pl,"y2",pt,"paint",pset
  GR.MODIFY gonum+2,"x1",mr,"y1",mt,"x2",pr,"y2",pt,"paint",pset
  GR.MODIFY gonum+3,"x1",ml,"y1",mb,"x2",pl,"y2",pb,"paint",pset
  GR.MODIFY gonum+4,"x1",mr,"y1",mb,"x2",pr,"y2",pb,"paint",pset
  GR.SET.STROKE 0
  BUNDLE.GET ptrctrl,"piccap",gonum
  BUNDLE.GET ptrctrl,"picbak",gonumb
  BUNDLE.GET ptrctrl,"origcap",i$
  IF i$<>"" THEN
   BUNDLE.GET 1,"frmscale",frmscale
   LET cx=cleft+u+(cWidth/2)
   LET cy=ctop+v+cheight+(4/frmscale)
   GR.TEXT.WIDTH cw,i$
   GR.TEXT.HEIGHT hv,uv,dv
   LET cw=cw+(8/frmscale)
   LET ch=dv-uv+(8/frmscale)
   GR.MODIFY gonumb,"left",cx-cw/2-ch/2,"top",cy,"right",cx-cw/2+ch/2,"bottom",cy+ch, ~
             "paint",psetb,"alpha", bcOPAQUE
   GR.MODIFY gonumb+1,"left",cx+cw/2-ch/2,"top",cy,"right",cx+cw/2+ch/2,"bottom",cy+ch, ~
             "paint",psetb,"alpha", bcOPAQUE
   GR.MODIFY gonumb+2,"left",cx-cw/2-1,"top",cy,"right",cx+cw/2,"bottom",cy+ch,"paint",psetb, ~
             "alpha", bcOPAQUE
   GR.MODIFY gonum,"paint",pset,"x",cLeft+u+cWidth/2,"y",cy-uv+4/frmscale,"text",i$,"alpha",bcOPAQUE
   GR.SHOW gonum 
   GR.SHOW gonumb
   GR.SHOW gonumb+1
   GR.SHOW gonumb+2
  ELSE
   GR.HIDE gonum 
   GR.HIDE gonumb
   GR.HIDE gonumb+1
   GR.HIDE gonumb+2
  ENDIF
  BUNDLE.GET ptrctrl,"picclip",gonum
  GR.MODIFY gonum,"left",cLeft+u,"top",cTop+v,"right",cLeft+cWidth+u,"bottom",cTop+cHeight+v
  GR.MODIFY pctrlcapbakobj,"x",cLeft+w,"y",cTop+h,"bitmap",pctrlcaptxtobj
 ENDIF
 FN.RTN gonum
FN.END
!
!  @ C L I C K _ P I C T U R E
!
FN.DEF @clickpicture(ptrctrl,pstyle$,pdx,pdy,pright,pbottom)
 LET bcPICSCROLL$="S"
 LET rc=1
 IF IS_IN(bcPICSCROLL$,pstyle$)<>0 THEN
  BUNDLE.GET ptrctrl,"scrstyp",styp$
  BUNDLE.GET ptrctrl,"scrssiz",ssiz
  IF styp$="H" THEN
   IF pdy>=pbottom-ssiz THEN
    BUNDLE.GET ptrctrl,"hscrslft",slft
    BUNDLE.GET ptrctrl,"hscrslth",slth
    BUNDLE.GET ptrctrl,"hscrsmov",smov
    BUNDLE.GET ptrctrl,"hscrsmid",smid
    BUNDLE.GET ptrctrl,"hscrspos",opos
    BUNDLE.GET ptrctrl,"hscrplft",plft
    BUNDLE.GET ptrctrl,"hscrpmov",pmov
    IF pdx<smid THEN
     IF pdx<=slft THEN LET inc=-10 ELSE LET inc=-100
    ELSE
     IF pdx>=pright-ssiz THEN LET inc=10 ELSE LET inc=100
    ENDIF
    LET spos=opos+inc
    IF spos<slft THEN LET spos=slft
    IF spos>slft+smov THEN LET spos=slft+smov
    IF spos<>opos THEN
     CALL @UpdateHSlide(ptrctrl,spos,slth,pstyle$)
     LET i=plft+pmov-(pmov/smov)*(spos-slft)
     BUNDLE.PUT ptrctrl,"picxoff",-i
     BUNDLE.GET ptrctrl,"capbakobj",gonum
     GR.MODIFY gonum,"x",i
     GR.RENDER
     LET rc=2
    ELSE
     LET rc=0
    ENDIF
   ENDIF
  ELSE
   IF pdx>=pright-ssiz THEN
    BUNDLE.GET ptrctrl,"vscrstop",stop
    BUNDLE.GET ptrctrl,"vscrslth",slth
    BUNDLE.GET ptrctrl,"vscrsmov",smov
    BUNDLE.GET ptrctrl,"vscrsmid",smid
    BUNDLE.GET ptrctrl,"vscrspos",opos
    BUNDLE.GET ptrctrl,"vscrptop",ptop
    BUNDLE.GET ptrctrl,"vscrpmov",pmov
    IF pdy<smid THEN
     IF pdy<=stop THEN LET inc=-10 ELSE LET inc=-100
    ELSE
     IF pdy>=pbottom-ssiz THEN LET inc=10 ELSE LET inc=100
    ENDIF
    LET spos=opos+inc
    IF spos<stop THEN LET spos=stop
    IF spos>stop+smov THEN LET spos=stop+smov
    IF spos<>opos THEN
     CALL @UpdateVSlide(ptrctrl,spos,slth,pstyle$)
     LET i=ptop+pmov-(pmov/smov)*(spos-stop)
     BUNDLE.PUT ptrctrl,"picyoff",-i
     BUNDLE.GET ptrctrl,"capbakobj",gonum
     GR.MODIFY gonum,"y",i
     GR.RENDER
     LET rc=2
    ELSE
     LET rc=0
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 FN.RTN rc
FN.END
!
!  S E T _ P I C _ M A R K _ P O S
!
FN.DEF SetPicMarkPos(pCtrlNo,pPos)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlNo),ptrCtrl
 BUNDLE.PUT ptrCtrl,"picmark",pPos
 FN.RTN 0
FN.END
!
!  S E T _ P I C _ R O T A T E
!
FN.DEF SetPicRotate(pCtrlNo,pAngle)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlNo),ptrCtrl
 BUNDLE.PUT ptrctrl,"picangle",pAngle
 FN.RTN ptrctrl
FN.END
!
!  M O D _ P I C _ R O T A T E
!
FN.DEF ModPicRotate(pCtrlNo,pAngle,pRend)
 LET ptrctrl=SetPicRotate(pCtrlNo,pAngle) 
 BUNDLE.GET ptrctrl,"picrotate",i
 GR.MODIFY i,"angle",pAngle
 IF pRend=1 THEN GR.RENDER
 FN.RTN 0
FN.END
!
!  S E T _ P I C _ B D R _ W I D T H
!
FN.DEF SetPicBdrWidth(pCtrlNo,pWidth)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlNo),ptrCtrl
 BUNDLE.PUT ptrctrl,"middle",pWidth
 FN.RTN ptrctrl
FN.END
!
!  M O D _ P I C _ B D R _ W I D T H
!
FN.DEF ModPicBdrWidth(pCtrlNo,pWidth,pRend)
 LET ptrctrl=SetPicBdrWidth(pCtrlNo,pWidth) 
 BUNDLE.GET ptrctrl,"data",data$
 CALL ModCtrlData(pCtrlNo,data$,pRend)
 FN.RTN 0
FN.END
!
!  V S C R O L L _ P I C T U R E
!
FN.DEF VScrollPicture(pCtrlNo,pPos,pRend)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlNo),ptrCtrl
 BUNDLE.GET ptrctrl,"scrstyp",styp$
 IF styp$="V" THEN
  BUNDLE.GET ptrctrl,"vscrstop",stop
  BUNDLE.GET ptrctrl,"vscrslth",slth
  BUNDLE.GET ptrctrl,"vscrsmov",smov
  BUNDLE.GET ptrctrl,"vscrspos",opos
  BUNDLE.GET ptrctrl,"vscrptop",ptop
  BUNDLE.GET ptrctrl,"vscrpmov",pmov
  IF pPos<stop THEN LET pPos=stop
  IF pPos>stop+smov THEN LET pPos=stop+smov
  IF pPos<>opos THEN
   CALL @UpdateVSlide(ptrctrl,pPos,slth,pstyle$)
   LET i=ptop+pmov-(pmov/smov)*(pPos-stop)
   BUNDLE.PUT ptrctrl,"picyoff",-i
   BUNDLE.GET ptrctrl,"capbakobj",gonum
   GR.MODIFY gonum,"y",i
   IF pRend=1 THEN GR.RENDER
  ENDIF
 ENDIF
 FN.RTN pPos
FN.END
!
!  @ D R A W _ H S C R O L L
!
FN.DEF @DrawHScroll(ptrctrl,px,py,pw,palpha,pstyle$,picw)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcBLACK=1
 LET bcCYAN=4
 LET bcLBLUE=10
 LET bcLMAGENTA=14
 LET bcWHITE=16
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcNOBORDER$="-"
 GOSUB @LoadRGBData
 BUNDLE.GET ptrctrl,"picvscr",i
 IF i=1 THEN
  BUNDLE.GET ptrctrl,"vscrfirstobj",fobj
  BUNDLE.GET ptrctrl,"vscrlastobj",lobj
  FOR i= fobj TO lobj
   GR.MODIFY i,"alpha",bcTRANSPARENT
  NEXT i
 ENDIF
 BUNDLE.GET 1,"sbwidth",SBH
 LET py=py-SBH
 LET slft=px+SBH
 LET slth=(pw*(pw-SBH-SBH))/picw
 LET smov=pw-SBH-SBH-slth
 LET smid=px+(pw/2)
 LET spos=smid-(slth/2)
 LET plft=px+pw-picw
 LET pmov=picw-pw
 BUNDLE.PUT ptrctrl,"hscrslth",slth
 BUNDLE.PUT ptrctrl,"hscrsmov",smov
 BUNDLE.PUT ptrctrl,"hscrspos",spos
 BUNDLE.PUT ptrctrl,"hscrplft",plft
 BUNDLE.PUT ptrctrl,"hscrpmov",pmov
 BUNDLE.PUT ptrctrl,"scrstyp","H"
 BUNDLE.GET ptrctrl,"pichscr",i
 IF i=1 THEN
  BUNDLE.GET ptrctrl,"hscrfirstobj",fobj
  BUNDLE.GET ptrctrl,"hscrlastobj",lobj
  FOR i=fobj TO lobj
   GR.MODIFY i,"alpha",bcOPAQUE
  NEXT i
  CALL @UpdateHSlide(ptrctrl,spos,slth,pstyle$)
 ELSE
  BUNDLE.PUT ptrctrl,"pichscr",1
  BUNDLE.PUT ptrctrl,"scrssiz",SBH
  BUNDLE.PUT ptrctrl,"hscrslft",slft
  BUNDLE.PUT ptrctrl,"hscrsmid",smid
  GR.COLOR palpha,BCMP[bcWHITE],GCMP[bcWHITE],RCMP[bcWHITE],bcFILL
  GR.RECT gonum,px+SBH,py,px+pw-SBH,py+SBH
  BUNDLE.PUT ptrctrl,"hscrfirstobj",gonum
  GR.COLOR palpha,BCMP[bcCYAN],GCMP[bcCYAN],RCMP[bcCYAN],bcFILL
  GR.RECT gonum,spos,py,spos+slth,py+SBH
  BUNDLE.PUT ptrctrl,"hscrslidebak",gonum
  GR.COLOR palpha,BCMP[bcLMAGENTA],GCMP[bcLMAGENTA],RCMP[bcLMAGENTA],bcFILL
  GR.RECT gonum,spos+5,py+5,spos+slth-5,py+SBH-5
  IF IS_IN(bcNOBORDER$,pstyle$)=0 THEN
   GR.COLOR palpha,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
   GR.RECT gonum,px,py,px+pw,py+SBH
   GR.RECT gonum,px+SBH,py,px+pw-SBH,py+SBH
   GR.RECT gonum,spos,py,spos+slth,py+SBH
   BUNDLE.PUT ptrctrl,"hscrslidebdr",gonum
   GR.RECT gonum,spos+5,py+5,spos+slth-5,py+SBH-5
  ENDIF
  LET gonum=@drawbutton("HSL"+INT$(ptrctrl),bcLBLUE,bcWHITE,px,py,SBH,SBH,7,pstyle$,0,"<", ~
            palpha,textptr,backptr)
  LET gonum=@drawbutton("HSR"+INT$(ptrctrl),bcLBLUE,bcWHITE,px+pw-SBH,py,SBH,SBH,7,pstyle$,0,">", ~
           palpha,textptr,backptr)
  BUNDLE.PUT ptrctrl,"hscrlastobj",gonum
 ENDIF
 FN.RTN 0
FN.END
!
!  @ U P D A T E _ H S L I D E
!
FN.DEF @UpdateHSlide(ptrctrl,spos,slth,pstyle$)
 LET bcNOBORDER$="-"
 BUNDLE.GET ptrctrl,"hscrslidebak",slidebakptr
 GR.MODIFY slidebakptr,"left",spos,"right",spos+slth
 GR.MODIFY slidebakptr+1,"left",spos+5,"right",spos+slth-5
 IF IS_IN(bcNOBORDER$,pstyle$)=0  THEN
  BUNDLE.GET ptrctrl,"hscrslidebdr",slidebdrptr
  GR.MODIFY slidebdrptr,"left",spos,"right",spos+slth
  GR.MODIFY slidebdrptr+1,"left",spos+5,"right",spos+slth-5
 ENDIF
 BUNDLE.PUT ptrctrl,"hscrspos",spos
 FN.RTN 0
FN.END
!
!  G E T _ B I T M A P _ O B J
!
FN.DEF GetCtrlBitmapObj(pCtrlNo)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlNo),ptrCtrl
 BUNDLE.GET ptrCtrl,"captxtobj",BMObj
 FN.RTN BMObj
FN.END
!
!  G E T _ P I C T U R E _ S I Z E
!
FN.DEF GetPictureSize(pCtrlNo,pW,pH)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlNo),ptrCtrl
 BUNDLE.GET ptrctrl,"picscale",pS
 BUNDLE.GET ptrctrl,"picwidth",pW
 BUNDLE.GET ptrctrl,"picheight",pH
 FN.RTN pS
FN.END
!
!  S E T _ C T R L _ B I T M A P _ O B J
!
FN.DEF SetCtrlBitmapObj(pCtrlNo,pBMObj)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlno),ptrCtrl
 BUNDLE.PUT ptrCtrl,"captxtobj",pBMObj
 FN.RTN 0
FN.END
!
!  M O D _ C T R L _ D R A W N _ B I T M A P
!
FN.DEF ModCtrlDrawnBitmap(pCtrlNo,pBMObj,pRend)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pCtrlNo),ptrCtrl
 BUNDLE.GET ptrCtrl,"capbakobj",CapBakObj
 BUNDLE.GET ptrctrl,"state",state$
 IF state$<>"x" THEN
  GR.MODIFY CapBakObj,"bitmap",pBMObj
  IF pRend=1 THEN
   GR.RENDER
  ENDIF
 ENDIF
 FN.RTN 0
FN.END
!
!  G E T _ C T R L _ C L I C K _ X Y
!
FN.DEF GetCtrlClickXY(pctrlno,pdspobj,pbmpobj,px,py)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"captxtobj",pbmpobj
 BUNDLE.GET ptrctrl,"capbakobj",pdspobj
 BUNDLE.GET ptrctrl,"pressx",px
 BUNDLE.GET ptrctrl,"pressy",py
 FN.RTN 0
FN.END
!
!  G E T _ C T R L _ B M P _ O F F S
!
FN.DEF GetCtrlBmpOffs(pctrlno,px,py)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"picxoff",px
 BUNDLE.GET ptrctrl,"picyoff",py
 FN.RTN 0
FN.END

!#@#@#@#_shape_control
!
!  @ D R A W _ S H A P E
!
FN.DEF @drawshape(ptrctrl,ctrlsizecap$,ctrlcaptxtclr,ctrlcapbakclr,ctrltop,ctrlleft,ctrlwidth, ~
       ctrlheight,cright,cbottom,ctrlfont,ctrlstyle$,ctrlcaptxtobj,ctrlcapbakobj)
 LET bcOPAQUE=255
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcSHAPEFILL$="f"
 LET bcNOBORDER$="-"
 GOSUB @LoadRGBData
 LET stemp$=LOWER$(ctrlsizecap$)
 IF ctrlfont>0 THEN LET thick=ctrlfont ELSE LET thick=1
 LET i=IS_IN(bcSHAPEFILL$,ctrlstyle$)
 IF stemp$="line" THEN
  IF i>0 THEN
   GR.COLOR bcOPAQUE,BCMP[ctrlcapbakclr],GCMP[ctrlbakbakcol],RCMP[ctrlcapbakclr],bcFILL
   GR.LINE gonum,ctrlleft,ctrltop,cright,cbottom
   LET ctrlcapbakobj=gonum
  ENDIF
  IF IS_IN(bcNOBORDER$,ctrlstyle$)=0 THEN
   GR.SET.STROKE thick
   GR.COLOR bcOPAQUE,BCMP[ctrlcaptxtclr],GCMP[ctrlcaptxtclr],RCMP[ctrlcaptxtclr],bcNOFILL
   GR.LINE gonum,ctrlleft,ctrltop,cright,cbottom
   GR.SET.STROKE 0
  ENDIF
  LET ctrlcaptxtobj=gonum
 ELSEIF stemp$="rect" THEN
  IF i>0 THEN
   GR.COLOR bcOPAQUE,BCMP[ctrlcapbakclr],GCMP[ctrlcapbakclr],RCMP[ctrlcapbakclr],bcFILL
   GR.RECT gonum,ctrlleft,ctrltop,cright,cbottom
   LET ctrlcapbakobj=gonum
  ENDIF
  IF IS_IN(bcNOBORDER$,ctrlstyle$)=0 THEN
   GR.SET.STROKE thick
   GR.COLOR bcOPAQUE,BCMP[ctrlcaptxtclr],GCMP[ctrlcaptxtclr],RCMP[ctrlcaptxtclr],bcNOFILL
   GR.RECT gonum,ctrlleft,ctrltop,cright,cbottom
   GR.SET.STROKE 0
  ENDIF
  LET ctrlcaptxtobj=gonum
 ELSEIF stemp$="oval" THEN
  IF i>0 THEN
   GR.COLOR bcOPAQUE,BCMP[ctrlcapbakclr],GCMP[ctrlcapbakclr],RCMP[ctrlcapbakclr],bcFILL
   GR.OVAL gonum,ctrlleft,ctrltop,cright,cbottom
   LET ctrlcapbakobj=gonum
  ENDIF
  IF IS_IN(bcNOBORDER$,ctrlstyle$)=0 THEN
   GR.SET.STROKE thick
   GR.COLOR bcOPAQUE,BCMP[ctrlcaptxtclr],GCMP[ctrlcaptxtclr],RCMP[ctrlcaptxtclr],bcNOFILL
   GR.OVAL gonum,ctrlleft,ctrltop,cright,cbottom
   GR.SET.STROKE 0
  ENDIF
  LET ctrlcaptxtobj=gonum
 ELSEIF stemp$="circle" THEN
  IF ctrlwidth<ctrlheight THEN LET r=ctrlwidth/2 ELSE LET r=ctrlheight/2
  LET x=ctrlleft+(ctrlwidth/2)
  LET y=ctrltop+(ctrlheight/2)
  IF i>0 THEN
   GR.COLOR bcOPAQUE,BCMP[ctrlcapbakclr],GCMP[ctrlcapbakclr],RCMP[ctrlcapbakclr],bcFILL
   GR.CIRCLE gonum,x,y,r
   LET ctrlcapbakobj=gonum
  ENDIF
  IF IS_IN(bcNOBORDER$,ctrlstyle$)=0 THEN
   GR.SET.STROKE thick
   GR.COLOR bcOPAQUE,BCMP[ctrlcaptxtclr],GCMP[ctrlcaptxtclr],RCMP[ctrlcaptxtclr],bcNOFILL
   GR.CIRCLE gonum,x,y,r
   GR.SET.STROKE 0
  ENDIF
  LET ctrlcaptxtobj=gonum
 ELSEIF stemp$="rndrect" THEN
  IF i=0 THEN a=0 ELSE a=255
  GR.COLOR a,BCMP[ctrlcapbakclr],GCMP[ctrlcapbakclr],RCMP[ctrlcapbakclr],i
  IF ctrlwidth>=ctrlheight THEN LET k=ctrlheight ELSE k=ctrlwidth 
  IF k<43 THEN LET cr=(i-2)/2 ELSE LET cr=20 
  cd=2*cr
  hz=ctrlwidth-cd
  vt=ctrlheight-cd
  GR.SET.STROKE 1
  GR.RECT gonum,ctrlleft+cr,ctrltop,ctrlleft+cr+hz,ctrltop+ctrlheight
  LET ctrlcapbakobj=gonum
  GR.RECT gonum,ctrlleft,ctrltop+cr,ctrlleft+cr,ctrltop+cr+vt
  GR.RECT gonum,ctrlleft+ctrlwidth-cr,ctrltop+cr,ctrlleft+ctrlwidth,ctrltop+cr+vt
  GR.ARC gonum,ctrlleft,ctrltop,ctrlleft+cd,ctrltop+cd,180,90,1
  GR.ARC gonum,ctrlleft+hz,ctrltop,ctrlleft+ctrlwidth,ctrltop+cd,270,90,1
  GR.ARC gonum,ctrlleft,ctrltop+vt,ctrlleft+cd,ctrltop+ctrlheight,90,90,1
  GR.ARC gonum,ctrlleft+hz,ctrltop+vt,ctrlleft+hz+cd,ctrltop+ctrlheight,0,90,1
  IF IS_IN(bcNOBORDER$,ctrlstyle$)>0 THEN a=0 ELSE a=255
  GR.SET.STROKE thick
  GR.COLOR a,BCMP[ctrlcaptxtclr],GCMP[ctrlcaptxtclr],RCMP[ctrlcaptxtclr],bcNOFILL
  GR.LINE gonum,ctrlleft+cr,ctrltop,ctrlleft+cr+hz,ctrltop
  GR.LINE gonum,ctrlleft+cr,ctrltop+ctrlheight,ctrlleft+cr+hz,ctrltop+ctrlheight
  GR.LINE gonum,ctrlleft,ctrltop+cr,ctrlleft,ctrltop+cr+vt
  GR.LINE gonum,ctrlleft+ctrlwidth,ctrltop+cr,ctrlleft+ctrlwidth,ctrltop+cr+vt
  GR.ARC gonum,ctrlleft,ctrltop,ctrlleft+cd,ctrltop+cd,180,90,0
  GR.ARC gonum,ctrlleft+hz,ctrltop,ctrlleft+ctrlwidth,ctrltop+cd,270,90,0
  GR.ARC gonum,ctrlleft,ctrltop+vt,ctrlleft+cd,ctrltop+ctrlheight,90,90,0
  GR.ARC gonum,ctrlleft+hz,ctrltop+vt,ctrlleft+hz+cd,ctrltop+ctrlheight,0,90,0
  LET ctrlcaptxtobj=gonum
  GR.SET.STROKE 0
 ENDIF
 FN.RTN gonum
FN.END

!#@#@#@#_listbox_control

!
!  @ D R A W _ L I S T _ B O X
!
FN.DEF @drawlistbox(pctrlno,ptrctrl,ctrltype,ctrlsizecap$,ctrlcapbakclr,ctrlcaptxtclr, ~
       ctrldatbakclr,ctrldattxtclr,ctrltop,ctrlleft,ctrlmiddle,ctrlwidth,ctrlheight,cright, ~
       cbottom,ctrlfont,ctrlstyle$,adjtop,xo,swidth,sheight,ctrlcapbakobj,ctrldatbakobj)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcBLACK=1
 LET bcBLUE=2
 LET bcCYAN=4
 LET bcLBLUE=10
 LET bcLCYAN=12
 LET bcLMAGENTA=14
 LET bcLYELLOW=15
 LET bcWHITE=16
 LET bcSYST1=17
 LET bcSYST2=18
 LET bcCHECKBOX$="X"
 LET bcFILEDIALOG$="F"
 LET bcLISTVIEW$="v"
 LET bcICON$="*"
 LET bcLISTBOXRIGHT$="x"
 LET bcHIDEGRID$="g"
 LET bcMULTILINE$="="
 LET bcQUICKNAV$="Q"
 LET bcNOBACK$="K"
 LET bcNOSCROLL$="V"
 LET bcNOBORDER$="-"
 LET bcNOHEADBOX$="T"
 LET bcBANDING$="J"
 LET bcCOLSORT$="j"
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET bcFLDBREAK$=CHR$(183)
 GOSUB @LoadRGBData
 LET rowheight=ctrlmiddle
 LET rowcount=FLOOR((ctrlheight/rowheight)+0.1)
 BUNDLE.GET ptrctrl,"datalst",datalst
 LIST.SIZE datalst,lbdatacnt
 BUNDLE.GET 1,"frmscale",frmscale
 BUNDLE.GET 1,"sbwidth",SBW
 IF IS_IN(bcNOHEADBOX$,ctrlstyle$)<>0 THEN
  LET ctrltop=ctrltop-rowheight
  LET rowcount=rowcount+1
  w=swidth
  LET ctrlheight=ctrlheight+rowheight
 ELSE
  LET w=0
 ENDIF
 LET Band=IS_IN(bcBANDING$,ctrlstyle$)
 IF IS_IN(bcNOBACK$,ctrlstyle$)<>0 THEN LET k=bcTRANSPARENT ELSE LET k=bcOPAQUE
 IF Band=0 THEN
  GR.COLOR k,BCMP[ctrldatbakclr],GCMP[ctrldatbakclr],RCMP[ctrldatbakclr],bcFILL
 ELSE
  GR.COLOR k,BCMP[bcSYST1],GCMP[bcSYST1],RCMP[bcSYST1],bcFILL
 ENDIF
 GR.RECT gonum,ctrlleft,ctrltop+rowheight,cright,cbottom
 LET ctrldatbakobj=gonum
 GR.COLOR bcOPAQUE,BCMP[ctrlcapbakclr],GCMP[ctrlcapbakclr],RCMP[ctrlcapbakclr],bcFILL
 GR.RECT gonum,ctrlleft+w,ctrltop,cright,ctrltop+rowheight
 LET ctrlcapbakobj=gonum

 LET lv=IS_IN(bcLISTVIEW$,ctrlstyle$)
 GR.TEXT.SIZE ctrlfont
 LET fo=@getfontyoffset(rowheight,ctrlfont)
 qx=cright
 qy=ctrltop+((rowheight-ctrlfont)/2)
 IF w=0 THEN
  IF IS_IN(bcQUICKNAV$,ctrlstyle$)<>0 THEN
   IF lv=0 THEN LET qx=qx-(2*SBW) ELSE LET qx=qx-SBW 
   lAlph=bcOPAQUE
   bcol=ctrldattxtclr
   GOSUB @SBR_DrawBinocs
  ENDIF
  IF IS_IN(bcCOLSORT$,ctrlstyle$)<>0 THEN
   qx=qx-SBW
   dy=ctrlfont/2
   ARRAY.LOAD paSort[],qx+10,qy,qx+20,qy+dy,qx+10,qy+ctrlfont,qx,qy+dy,qx+20,qy+dy,qx,qy+dy,qx+10,qy
   LIST.CREATE n,sptr
   LIST.ADD.ARRAY sptr,paSort[]
   GR.COLOR bcOPAQUE,BCMP[ctrldattxtclr],GCMP[ctrldattxtclr],RCMP[ctrldattxtclr],bcNOFILL
   GR.POLY psortptr,sptr
  ENDIF
 ENDIF
 IF IS_IN(bcHIDEGRID$,ctrlstyle$)=0 THEN
  GR.CLIP gonum,ctrlleft,ctrltop,cright,cbottom,2
  IF Band=0 THEN
   GR.COLOR bcOPAQUE,BCMP[ctrlcapbakclr],GCMP[ctrlcapbakclr],RCMP[ctrlcapbakclr],bcFILL
   LET k=0
   LET s=1
  ELSE
   LET ctrlcaptxtclr=ctrldatbakclr
   LET ctrlcapbakclr=ctrldattxtclr
   LET ctrldattxtclr=bcBLACK
   GR.COLOR bcOPAQUE,BCMP[bcWHITE],GCMP[bcWHITE],RCMP[bcWHITE],bcFILL
   LET k=rowheight
   LET s=2
  ENDIF
  LET j=ctrltop+2*rowheight
  FOR rn=1 TO rowcount+1 STEP s
   IF Band=0 THEN
    GR.LINE gonum,ctrlleft,j,cright,j
   ELSE
    GR.RECT gonum,ctrlleft,j,cright,j+rowheight
   ENDIF
   LET j=j+rowheight+k
  NEXT rn
 ENDIF
 IF lv<>0 THEN
  GR.COLOR bcOPAQUE,BCMP[ctrlcaptxtclr],GCMP[ctrlcaptxtclr],RCMP[ctrlcaptxtclr],bcFILL
  GR.RECT gonum,ctrlleft,ctrltop+rowheight,cright,ctrltop+(2*rowheight)
  LET rowcount=rowcount-2
  LET firstline=2
 ELSE
  LET rowcount=rowcount-1
  LET firstline=1
 ENDIF
 LIST.CREATE n,lbbakobj
 LIST.CREATE n,lbtxtobj
 LIST.CREATE n,lbchkobj
 LIST.CREATE n,lbicnobj
 BUNDLE.GET ptrctrl,"lbchecked",lbchecked
 BUNDLE.GET ptrctrl,"lbbmpname",lbbmpname
 LET k=ctrlmiddle/8
 LET kx=k*8
 IF IS_IN(bcCHECKBOX$,ctrlstyle$)<>0 THEN
  LET txtoffset=kx
 ELSE
  LET txtoffset=0
 ENDIF
 IF IS_IN(bcFILEDIALOG$,ctrlstyle$)<>0 THEN
  UNDIM fia[]
  ARRAY.LOAD fia[],ctrlleft+k,2*k,ctrlleft+5*k-2,2*k,ctrlleft+5*k+2,k,ctrlleft+rowheight-k,k~
             ctrlleft+rowheight-k,rowheight-k,ctrlleft+k,rowheight-k
  LIST.CREATE n,fip
  LIST.ADD.ARRAY fip,fia[]
  LET txtoffset=txtoffset+kx+4
 ELSEIF IS_IN(bcICON$,ctrlstyle$)<>0 THEN
  LET txtoffset=txtoffset+kx
 ENDIF
 IF IS_IN(bcMULTILINE$,ctrlstyle$)<>0 THEN
  LET i=ctrldatbakclr
 ELSE
  LET i=bcLBLUE
 ENDIF
 GR.COLOR bcTRANSPARENT,BCMP[i],GCMP[i],RCMP[i],bcFILL
 LET j=ctrltop+firstline*rowheight
 FOR i=1 TO rowcount
  GR.RECT gonum,ctrlleft+2,j+2,cright-2,j+rowheight-2
  LIST.ADD lbbakobj,gonum
  LET j=j+rowheight
 NEXT i
 LET ly=ctrltop+(firstline-1)*rowheight
 IF IS_IN(bcLISTVIEW$,ctrlstyle$)<>0 THEN
  CALL @setstyle(ctrltype,ctrlstyle$,"c")
  LET coldata$=ctrlsizecap$
  SPLIT.ALL cd$[],coldata$,bcCOLBREAK$
  ARRAY.LENGTH lbcolcnt,cd$[]
  LET lx=ctrlleft+txtoffset
  LET clipoff=0
  LET rn=0
  GOSUB @DrawColumns
 ELSE
  GR.CLIP gonum,ctrlleft,ctrltop,cright,cbottom,2
 ENDIF
 FOR rn=1 TO rowcount
  CALL @setstyle(ctrltype,ctrlstyle$,"d")
  LET ly=ly+rowheight
  IF IS_IN(bcLISTVIEW$,ctrlstyle$)<>0 THEN
   LET lx=ctrlleft+txtoffset
   LET clipoff=0
   GOSUB @DrawColumns
  ELSE
   GR.COLOR bcOPAQUE,BCMP[ctrldattxtclr],GCMP[ctrldattxtclr],RCMP[ctrldattxtclr],bcFILL
   IF IS_IN(bcLISTBOXRIGHT$,ctrlstyle$)>0 THEN
    LET k=cright-SBW-xo
   ELSE
    LET k=ctrlleft+txtoffset+xo
   ENDIF
   GR.TEXT.DRAW gonum,k,ly+fo,""
   LIST.ADD lbtxtobj,gonum
  ENDIF
  IF IS_IN(bcCHECKBOX$,ctrlstyle$)<>0 THEN
   LET k=(rowheight/10)*3
   LET m=ly+k
   LET n=ly+rowheight-k
   GR.SET.STROKE 2
   GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
   GR.RECT gonum,ctrlleft+k,m,ctrlleft+rowheight-k,n
   LIST.ADD lbchkobj,gonum
   GR.LINE gonum,ctrlleft+k,m,ctrlleft+rowheight-k,n
   GR.LINE gonum,ctrlleft+rowheight-k,m,ctrlleft+k,n
   GR.SET.STROKE 0
   LET io=rowheight
  ELSE
   LET io=0
  ENDIF
  IF IS_IN(bcICON$,ctrlstyle$)<>0 THEN
   LET k=6
   LET m=rowheight-12
   GR.BITMAP.CREATE bmpobj,m,m
   LET m=ly+k
   GR.RECT gonum,0,0,ctrlfont,ctrlfont
   GR.BITMAP.DRAW gonum,bmpobj,ctrlleft+io+k,m
   CALL @AddToBmpList("I"+INT$(rn),pctrlno,bmpobj)
   LIST.ADD lbicnobj,gonum
   GR.MODIFY gonum,"alpha",bcTRANSPARENT
  ELSEIF IS_IN(bcFILEDIALOG$,ctrlstyle$)<>0 THEN
   LET k=ctrlfont/4
   LET m=ly+k
   LET n=ly+rowheight-k
   GR.COLOR bcTRANSPARENT,BCMP[bcLYELLOW],GCMP[bcLYELLOW],RCMP[bcLYELLOW],bcFILL
   GR.POLY gonum,fip,io,ly
   LIST.ADD lbicnobj,gonum
   GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
   GR.POLY gonum,fip,io,ly
   GR.COLOR bcTRANSPARENT,BCMP[bcLBLUE],GCMP[bcLBLUE],RCMP[bcBLACK],bcFILL
   GR.RECT gonum,ctrlleft+io+k,m,ctrlleft+io+rowheight-k,m+k
   GR.COLOR bcTRANSPARENT,BCMP[bcWHITE],GCMP[bcWHITE],RCMP[bcWHITE],bcFILL
   GR.RECT gonum,ctrlleft+io+k,m+k,ctrlleft+io+rowheight-k,n
   GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
   GR.RECT gonum,ctrlleft+io+k,m,ctrlleft+io+rowheight-k,m+k
   GR.RECT gonum,ctrlleft+io+k,m+k,ctrlleft+io+rowheight-k,n
  ENDIF
  LET j=j+rowheight
 NEXT rn
 GR.CLIP gonum,0,0,swidth,sheight,2
 IF IS_IN(bcNOSCROLL$,ctrlstyle$)=0 THEN
  IF lbdatacnt>rowcount THEN LET lalpha=bcOPAQUE ELSE LET lalpha=bcTRANSPARENT
  LET i=firstline*rowheight
  CALL @DrawVScroll(ptrctrl,ctrlleft+ctrlwidth,ctrltop+i,ctrlheight-i,lalpha,ctrlstyle$, ~
       ctrlheight-i)
 ENDIF
 IF IS_IN(bcHIDEGRID$,ctrlstyle$)=0 THEN
  IF IS_IN(bcLISTVIEW$,ctrlstyle$)<>0 THEN
   IF Band=0 THEN
    GR.COLOR bcOPAQUE,BCMP[ctrlcapbakclr],GCMP[ctrlcapbakclr],RCMP[ctrlcapbakclr],bcFILL
   ELSE
    GR.COLOR bcOPAQUE,BCMP[bcSYST2],GCMP[bcSYST2],RCMP[bcSYST2],bcFILL
   ENDIF
   LET lx=ctrlleft+txtoffset
   FOR cn=2 TO lbcolcnt
    UNDIM  hwa$[]
    SPLIT.ALL hwa$[],cd$[cn],bcFLDBREAK$
    LET w=VAL(hwa$[2])
    GR.LINE gonum,lx+w,ctrltop+rowheight,lx+w,cbottom
    LET lx=lx+w
   NEXT cn
  ENDIF
 ENDIF
 IF IS_IN(bcNOHEADBOX$,ctrlstyle$)=0 THEN
  IF lv<>0 THEN LET qt=ctrltop+rowheight ELSE LET qt=ctrltop
  LET gonum=@DrawMenuBars(cright,qt,rowheight,6,SBW,ctrlcapbakclr)
  CALL @drawqm(ptrctrl,cright,qt,rowheight,ctrlfont)
 ENDIF
 BUNDLE.PUT ptrctrl,"lbbakobj",lbbakobj
 BUNDLE.PUT ptrctrl,"lbtxtobj",lbtxtobj
 BUNDLE.PUT ptrctrl,"lbchkobj",lbchkobj
 BUNDLE.PUT ptrctrl,"lbicnobj",lbicnobj
 BUNDLE.PUT ptrctrl,"lbprevcap",""
 BUNDLE.PUT ptrctrl,"lbprevstart",0
 BUNDLE.PUT ptrctrl,"lbCurDspIdx",0
 BUNDLE.PUT ptrctrl,"lbcolclicked",0
 BUNDLE.PUT ptrctrl,"lbcolcnt",lbcolcnt-1
 BUNDLE.PUT ptrctrl,"lbchecked",lbchecked
 BUNDLE.PUT ptrctrl,"lbbmpname",lbbmpname
 BUNDLE.PUT ptrctrl,"lbrowcount",rowcount
 BUNDLE.PUT ptrctrl,"FirstDspIdx",1
 BUNDLE.PUT ptrctrl,"LastDspIdx",rowcount+1
 LET adjtop=ctrltop+rowheight
 FN.RTN gonum
FN.END
!
!  @ D R A W _ M E N U _ B A R S
!
FN.DEF @DrawMenuBars(r,t,h,w,sbw,c)
 LET bcOPAQUE=255
 LET bcFILL=1
 GOSUB @LoadRGBData
 p=int(h/7)
 mt=t+((h-(5*p))/2)
 mr=r-SBW/2-w/2
 GR.COLOR bcOPAQUE,BCMP[c],GCMP[c],RCMP[c],bcFILL
 FOR i=1 TO 3
  GR.RECT gonum,mr,mt,mr+w,mt+p
  mt=mt+(2*p)
 NEXT i
 FN.RTN gonum
FN.END
!
!  @ D R A W _ Q M
!
FN.DEF @drawqm(ptrctrl,right,top,rh,font)
 LET bcTRANSPARENT=0
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcBLACK=1
 LET bcWHITE=16
 GOSUB @LoadRGBData
 BUNDLE.GET 1,"swidth",swidth
 BUNDLE.GET 1,"sheight",sheight
 GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcFILL
 GR.RECT gonum1,0,0,swidth,sheight
 BUNDLE.PUT ptrctrl,"qmf",gonum1
 GR.TEXT.SIZE font
 GR.TEXT.ALIGN 1
 BUNDLE.GET 1,"frmscale",frmscale
 ARRAY.LOAD j$[],"First Row",CHR$(188)+" way down List",CHR$(189)+" way down List", ~
   CHR$(190)+" way down List","Last Row"
 Gr.text.width cx,"Go "+j$[2]
 cx=cx+30
 x=right-cx
 y=top+rh
 cy=y
 LET fo=@getfontyoffset(rh,font)
 FOR i=1 TO 5
  GR.COLOR bcTRANSPARENT,BCMP[bcWHITE],GCMP[bcWHITE],RCMP[bcWHITE],bcFILL
  GR.RECT gonum,x,cy,x+cx,cy+rh
  GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
  GR.RECT gonum,x,cy,x+cx,cy+rh
  GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcFILL
  GR.TEXT.DRAW gonum,x+10,cy+fo,"Go "+j$[i]
  cy=cy+rh
 NEXT i
 BUNDLE.PUT ptrctrl,"qml",gonum
 BUNDLE.PUT ptrctrl,"qmx",x
 BUNDLE.PUT ptrctrl,"qmy",y
 BUNDLE.PUT ptrctrl,"qmr",x+cx
 BUNDLE.PUT ptrctrl,"qmb",y+(5*rh)
 FN.RTN 0
FN.END
!
!  @ C L I C K _ Q M
!
FN.DEF @clickqm(ptrctrl)
 LET bcOPAQUE=255
 LET bcSEMIOPAQUE=128
 LET bcTRANSPARENT=0
 BUNDLE.GET ptrctrl,"qmf",gonumf
 BUNDLE.GET ptrctrl,"qml",gonuml
 BUNDLE.GET ptrctrl,"qmx",x
 BUNDLE.GET ptrctrl,"qmy",y
 BUNDLE.GET ptrctrl,"qmr",r
 BUNDLE.GET ptrctrl,"qmb",b
 BUNDLE.GET ptrctrl,"middle",rh
 BUNDLE.GET ptrctrl,"datalst",lbdata
 BUNDLE.GET 1,"FrmObjCnt",FrmObjCnt
 CALL @BringToFront(gonumf,gonuml,0)
 LIST.SIZE lbdata,lbdatacnt
 GR.MODIFY gonumf,"alpha",bcSEMIOPAQUE
 FOR i=gonumf+1 TO gonuml
  GR.MODIFY i,"alpha",bcOPAQUE
 NEXT i
 GR.RENDER
 DO
  LET tch=0
  GR.TOUCH tch,tx,ty
  IF tch=1 THEN
   GR.BOUNDED.TOUCH tch,x,y,r,b
   IF tch<>0 THEN
    rs=INT((ty-y)/rh)+1
    IF rs=1 THEN
     rs=1
    ELSEIF rs=2 THEN
     rs=lbdatacnt/4
    ELSEIF rs=3 THEN
     rs=lbdatacnt/2
    ELSEIF rs=4 THEN
     rs=(lbdatacnt/4)*3
    ELSE
     rs=lbdatacnt-1
    ENDIF
   ELSE
    rs=0
   ENDIF
   DO
    GR.TOUCH tuch,ux,uy
   UNTIL tuch=0
   D_U.BREAK
  ELSE
   PAUSE 100
  ENDIF
 UNTIL 1=0
 FOR i=gonumf TO gonuml
  GR.MODIFY i,"alpha",bcTRANSPARENT
 NEXT i
 GR.RENDER
 FN.RTN INT(rs)
FN.END
!
!  @ R E D R A W _ L I S T B O X _ R O W S
!
FN.DEF @RedrawListBoxRows(pctrlno,presetstart)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcFILL=1
 LET bcBLACK=1
 LET bcBLUE=2
 LET bcGREEN=3
 LET bcRED=5
 LET bcMAGENTA=6
 LET bcGRAY=8
 LET bcLCYAN=12
 LET bcLYELLOW=15
 LET bcWHITE=16
 LET bcCHECKBOX$="X"
 LET bcFILEDIALOG$="F"
 LET bcLISTBOXLAST$="z"
 LET bcLISTVIEW$="v"
 LET bcICON$="*"
 LET bcNOBORDER$="-"
 LET bcMULTILINE$="="
 LET bcNOSCROLL$="V"
 LET bcNOHEADBOX$="T"
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET bcFLDBREAK$=CHR$(183)
 GOSUB @LoadRGBData
 BUNDLE.GET 1,"ctrldata",ctrlstor
 BUNDLE.GET ctrlstor,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"sizecap",ctrlsizecap$
 BUNDLE.GET ptrctrl,"captxtobj",ctrlcaptxtobj
 BUNDLE.GET ptrctrl,"data",ctrldata$
 BUNDLE.GET ptrctrl,"top",ctrltop
 BUNDLE.GET ptrctrl,"height",ctrlheight
 BUNDLE.GET ptrctrl,"font",ctrlfont
 BUNDLE.GET ptrctrl,"style",ctrlstyle$
 BUNDLE.GET ptrctrl,"lbprevstart",prevstart
 IF presetstart=1 THEN
  LET prevstart=0
  BUNDLE.PUT ptrctrl,"lbcolclicked",0
 ENDIF
 BUNDLE.GET ptrctrl,"lbbakobj",lbbakobj
 BUNDLE.GET ptrctrl,"lbtxtobj",lbtxtobj
 BUNDLE.GET ptrctrl,"lbchkobj",lbchkobj
 BUNDLE.GET ptrctrl,"lbicnobj",lbicnobj
 BUNDLE.GET ptrctrl,"lbprevcap",sprevcap$
 BUNDLE.GET ptrctrl,"datalst",lbdata
 LIST.SIZE lbdata,lbdatacnt
 BUNDLE.GET ptrctrl,"lbcolcnt",lbcolcnt
 BUNDLE.GET ptrctrl,"lbchecked",lbchecked
 BUNDLE.GET ptrctrl,"lbbmpname",lbbmpname
 BUNDLE.GET ptrctrl,"lbrowcount",rowcount
 BUNDLE.GET ptrctrl,"middle",rowheight
 IF IS_IN(bcMULTILINE$,ctrlstyle$)<>0 THEN
  BUNDLE.GET ptrctrl,"dattxtclr",tcol
  BUNDLE.GET ptrctrl,"left",lleft
  BUNDLE.GET ptrctrl,"width",lwidth
  BUNDLE.GET 1,"sbwidth",SBW
  BUNDLE.GET 1,"fontptrs",fontptr
  LET xo=ctrlfont/4
  LET w=lwidth
  IF IS_IN(bcNOSCROLL$,ctrlstyle$)=0 THEN LET w=w-SBW
  LET x1=lleft+xo
  LET x2=lleft+(w/2)
  LET x3=lleft+w-xo
  ARRAY.LOAD tca[],tcol,bcBLACK,bcBLUE,bcGREEN,bcLCYAN,bcRED,bcMAGENTA,bcLYELLOW,bcGRAY,bcWHITE
 ENDIF
 IF IS_IN(bcLISTVIEW$,ctrlstyle$)<>0 THEN
  LET i$=bcCOLBREAK$
 ELSE
  LET i$=bcRECBREAK$
 ENDIF
 LET cap$=ctrlsizecap$
 LET lselidx=0
 IF sprevcap$<>ctrlsizecap$ & IS_IN(bcLISTBOXLAST$,ctrlstyle$)>0 THEN
  LET lstart=lbdatacnt
 ELSE
  IF prevstart<>0 THEN
   LET lstart=prevstart
  ELSE
   LET lstart=2
  ENDIF
 ENDIF
 IF ctrldata$<>"" THEN
  LIST.SEARCH lbdata,ctrldata$,lselidx
  IF lselidx=0 THEN
   LET lselidx=2
   LET ctrldata$=""
   BUNDLE.PUT ptrctrl,"lbCurDspIdx",0
  ELSE
   BUNDLE.PUT ptrctrl,"lbCurDspIdx",lselidx
  ENDIF
  IF prevstart=0 THEN LET lstart=lselidx
 ENDIF
 IF lstart+rowcount-1>lbdatacnt THEN
  LET lstart=lbdatacnt-rowcount+1
  IF lstart<2 THEN LET lstart=2
 ENDIF
 LET prevstart=lstart
 LET curstart=lstart
 BUNDLE.GET 1,"picpath",PicPath$
 LET FirstDspIdx=lstart-1
 LET LastDspIdx=FirstDspIdx+rowcount-1
 FOR rn=1 TO rowcount
  IF lstart<=lbdatacnt THEN
   LIST.GET lbdata,lstart,rowdata$
   LIST.GET lbbakobj,rn,gonum
   IF lstart=lselidx THEN
    GR.MODIFY gonum,"alpha",bcOPAQUE
   ELSE
    GR.MODIFY gonum,"alpha",bcTRANSPARENT
   ENDIF
   IF IS_IN(bcCHECKBOX$,ctrlstyle$)<>0 THEN
    IF !(IS_IN(bcFILEDIALOG$,ctrlstyle$)<>0 & MID$(rowdata$,4,2)="..") THEN
     LIST.GET lbchkobj,rn,gonum
     GR.MODIFY gonum,"alpha",bcOPAQUE
     LIST.GET lbchecked,lstart,temp$
     IF temp$="[X]" THEN
      LET alpha=bcOPAQUE
     ELSE
      LET alpha=bcTRANSPARENT
     ENDIF
     GR.MODIFY gonum+1,"alpha",alpha
     GR.MODIFY gonum+2,"alpha",alpha
    ENDIF
   ENDIF
   IF IS_IN(bcICON$,ctrlstyle$)<>0  THEN
    LIST.GET lbbmpname,lstart,bmpname$
    LET i$=PicPath$+bmpname$
    FILE.EXISTS i,i$
    IF i=0 THEN
     LET i$="GC-Information.png"
    ENDIF
    LET j=rowheight-12
    GR.BITMAP.LOAD bmpsrc,i$
    GR.BITMAP.SCALE bmpobj,bmpsrc,j,j
    CALL @AddToBmpList("I"+INT$(rn),ptrctrl,bmpobj)
    GR.BITMAP.DELETE bmpsrc
    LIST.GET lbicnobj,rn,gonum
    GR.MODIFY gonum,"bitmap",bmpobj,"alpha",bcOPAQUE
   ELSEIF IS_IN(bcFILEDIALOG$,ctrlstyle$)<>0 THEN
    IF LEFT$(rowdata$,2)=".." THEN
     LET j=bcTRANSPARENT
     LET n=bcTRANSPARENT
    ELSE
     IF RIGHT$(rowdata$,3)="(d)" THEN
      LET rowdata$=LEFT$(rowdata$,LEN(rowdata$)-3)
      LET j=bcOPAQUE
      LET n=bcTRANSPARENT
     ELSE
      LET j=bcTRANSPARENT
      LET n=bcOPAQUE
     ENDIF
    ENDIF
    LIST.GET lbicnobj,rn,gonum
    FOR i=0 TO 1
     GR.MODIFY gonum+i,"alpha",j
    NEXT i
    FOR i=2 TO 5
     GR.MODIFY gonum+i,"alpha",n
    NEXT i
   ENDIF
   LIST.GET lbtxtobj,rn,gonum
   IF IS_IN(bcLISTVIEW$,ctrlstyle$)<>0 THEN
    SPLIT.ALL coldata$[],rowdata$,bcCOLBREAK$
    ARRAY.LENGTH actcols,coldata$[]
    LET j=0
    FOR cn=1 TO lbcolcnt
     IF cn>actcols THEN
      GR.MODIFY gonum+j,"text",""
     ELSE
      GR.MODIFY gonum+j,"text",coldata$[cn]
     ENDIF
     LET j=j+2
    NEXT cn
    UNDIM coldata$[]
   ELSE
    IF IS_IN(bcMULTILINE$,ctrlstyle$)<>0 THEN
     LET a$=LEFT$(rowdata$,7)
     LET rowdata$=MID$(rowdata$,8)
     LET tn=VAL(MID$(a$,7,1))
     LIST.GET fontptr,tn,tf
     IF tn<5 THEN
      GR.TEXT.TYPEFACE tf
     ELSE
      GR.TEXT.SETFONT tf
     ENDIF
     LET ta=VAL(MID$(a$,4,1))
     IF ta=1 THEN
      LET tx=x1
     ELSE
      IF ta=2 THEN LET tx=x2 ELSE LET tx=x3
     ENDIF
     GR.MODIFY gonum,"x",tx
     LET i=ASCII(MID$(a$,5,1))-48
     GR.COLOR bcOPAQUE,BCMP[tca[i]],GCMP[tca[i]],RCMP[tca[i]],bcFILL
     GR.TEXT.ALIGN ta
     LET ts=ctrlfont+((VAL(MID$(a$,6,1))-4)*3)
     GR.TEXT.SIZE ts
     GR.TEXT.BOLD VAL(MID$(a$,1,1))
     IF MID$(a$,3,1)="1" THEN LET ti=-0.25 ELSE LET ti=0
     GR.TEXT.SKEW ti
     GR.TEXT.UNDERLINE VAL(MID$(a$,2,1))
     GR.PAINT.GET pptr
     GR.MODIFY gonum,"paint",pptr
    ENDIF
    GR.MODIFY gonum,"text",rowdata$
   ENDIF
  ELSE
   IF lstart<LastDspIdx THEN LET LastDspIdx=lstart
   LIST.GET lbbakobj,rn,gonum
   GR.MODIFY gonum,"alpha",bcTRANSPARENT
   IF IS_IN(bcCHECKBOX$,ctrlstyle$)<>0 THEN
    LIST.GET lbchkobj,rn,gonum
    FOR n=0 TO 2
     GR.MODIFY gonum+n,"alpha",bcTRANSPARENT
    NEXT n
   ENDIF
   IF IS_IN(bcFILEDIALOG$,ctrlstyle$)<>0 THEN
    LIST.GET lbicnobj,rn,gonum
    FOR n=0 TO 5
     GR.MODIFY gonum+n,"alpha",bcTRANSPARENT
    NEXT n
   ENDIF
   IF IS_IN(bcICON$,ctrlstyle$)<>0 THEN
    LIST.GET lbicnobj,rn,gonum
    GR.MODIFY gonum,"alpha",bcTRANSPARENT
   ENDIF
   LIST.GET lbtxtobj,rn,gonum
   IF IS_IN(bcLISTVIEW$,ctrlstyle$)<>0 THEN
    LET j=0
    FOR cn=1 TO lbcolcnt
     GR.MODIFY gonum+j,"text",""
     LET j=j+2
    NEXT cn
   ELSE
    GR.MODIFY gonum,"text",""
   ENDIF
  ENDIF
  LET lstart=lstart+1
 NEXT rn
 IF IS_IN(bcNOSCROLL$,ctrlstyle$)=0 THEN GOSUB @UpdtVScrollBar
 IF IS_IN(bcNOHEADBOX$,ctrlstyle$)=0 THEN
  BUNDLE.GET ptrctrl,"qmf",gonumf
  BUNDLE.GET ptrctrl,"qml",gonuml
  FOR i=gonumf TO gonuml
   GR.MODIFY i,"alpha",bcTRANSPARENT
  NEXT i
 ENDIF
 BUNDLE.PUT ptrctrl,"data",ctrldata$
 BUNDLE.PUT ptrctrl,"lbprevstart",prevstart
 BUNDLE.PUT ptrctrl,"FirstDspIdx",FirstDspIdx
 BUNDLE.PUT ptrctrl,"LastDspIdx",LastDspIdx
 FN.RTN 0
FN.END
!
!  @ C L I C K _ L I S T B O X
!
FN.DEF @clicklistbox(px,py,pctrlorigcap$,pctrldata$,pctrltop,pctrlleft,pctrlmiddle,pright,pbottom, ~
       pctrlfont,pctrlstyle$,pprevstart,pscrolltop,pscrollmid,pcolclicked,ptrctrl,selctrl)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcCHECKBOX$="X"
 LET bcICON$="*"
 LET bcFILEDIALOG$="F"
 LET bcLISTVIEW$="v"
 LET bcMULTSEL$="M"
 LET bcMULTILINE$="="
 LET bcNOSCROLL$="V"
 LET bcEDITABLE$="E"
 LET bcQUICKNAV$="Q"
 LET bcCOLSORT$="j"
 LET bcNOHEADBOX$="T"
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET bcFLDBREAK$=CHR$(183)
 LET bcCRLF$=CHR$(13)+CHR$(10)
 LET bcLF$=CHR$(10)
 LET bcSTRCRLF$="^^"
 LET rowheight=pctrlmiddle
 BUNDLE.GET ptrctrl,"datalst",lbdata
 LIST.SIZE lbdata,lbdatacnt
 BUNDLE.GET ptrctrl,"lbchecked",lbchecked
 BUNDLE.GET ptrctrl,"lbbmpname",lbbmpname
 BUNDLE.GET ptrctrl,"lbcolcnt",lbcolcnt
 BUNDLE.GET ptrctrl,"lbbakobj",lbbakobj
 BUNDLE.GET ptrctrl,"lbchkobj",lbchkobj
 BUNDLE.GET ptrctrl,"lbrowcount",rowcount
 qnb=0
 qmb=0
 IF IS_IN(bcNOHEADBOX$,pctrlstyle$)=0 & lbdatacnt>rowcount THEN
  IF IS_IN(bcLISTVIEW$,pctrlstyle$)<>0 THEN
   IF py<pctrltop+rowheight THEN
    qnb=1 
   ELSEIF py<pctrltop+(2*rowheight) & px>pright-rowheight THEN
    qmb=1
   ENDIF
  ELSE 
   IF py<pctrltop+rowheight & px>pright-rowheight THEN
    qmb=1
   ENDIF
  ENDIF
 ENDIF
 IF qnb=1 THEN 
  LET selrow=0
  BUNDLE.GET ptrctrl,"lbCurDspIdx",currow
  IF IS_IN(bcQUICKNAV$,pctrlstyle$)<>0 & lbdatacnt>rowcount THEN
   s$=""
   t$=""
   b$=""
   LET i$=@quicknav$(ptrctrl,&s$,&t$,&b$)
   IF i$<>bcCOLBREAK$ THEN
    BUNDLE.GET ptrctrl,"lbhdrcol",hdrcol
    IF b$="F" THEN
     LET sp=2
    ELSE
     BUNDLE.GET ptrctrl,"lbCurDspIdx",sp
     IF sp>0 THEN LET sp=sp+1 ELSE LET sp=2
    ENDIF
    FOR rc=sp TO lbdatacnt
     LIST.GET lbdata,rc,j$
     IF s$="R" THEN
      IF t$="A" THEN
       IF IS_IN(i$,UPPER$(j$))<>0 THEN
        F_N.BREAK
       ENDIF
      ELSE
       IF LEFT$(UPPER$(j$),LEN(i$))=i$ THEN
        F_N.BREAK
       ENDIF
      ENDIF
     ELSE
      UNDIM f$[]
      SPLIT f$[],j$,bcCOLBREAK$
      IF t$="A" THEN
       IF IS_IN(i$,UPPER$(f$[hdrcol]))<>0 THEN
        F_N.BREAK
       ENDIF
      ELSE
       IF LEFT$(UPPER$(f$[hdrcol]),LEN(i$))=i$ THEN
        F_N.BREAK
       ENDIF
      ENDIF
     ENDIF
    NEXT i
    IF rc>lbdatacnt THEN
     LET rc=lbdatacnt
    ELSE
     LET pctrldata$=j$
     LET pprevstart=rc
    ENDIF
   ENDIF
  ENDIF
 ELSEIF qmb=1 THEN
  LET selrow=0
  LET rc=@clickqm(ptrctrl)
  IF rc<>0 THEN
   LIST.GET lbdata,rc+1,pctrldata$
   LET pprevstart=rc+1
  ENDIF
 ELSEIF lbdatacnt>rowcount & px>pright-rowheight & IS_IN(bcNOSCROLL$,pctrlstyle$)=0 THEN
  BUNDLE.GET 1,"sbwidth",SBW
  LET ny=py-(pscrolltop-SBW)
  LET inc=1
  IF ny>0 & ny<SBW THEN
   IF pprevstart-inc>=2 THEN LET pprevstart=pprevstart-inc
  ELSE
   LET ny=py-pbottom+SBW
   IF ny>0 & ny<SBW THEN
    IF pprevstart+rowcount+inc-1<=lbdatacnt THEN
     LET pprevstart=pprevstart+inc
    ENDIF
   ELSE
    LET inc=rowcount-2
    IF py<pscrollmid THEN
     IF pprevstart-inc>=2 THEN
      LET pprevstart=pprevstart-inc
     ELSE
      LET pprevstart=2
     ENDIF
    ELSE
     IF pprevstart+rowcount+inc-1<=lbdatacnt THEN
      LET pprevstart=pprevstart+inc
     ELSE
      LET pprevstart=lbdatacnt-rowcount+1
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  LET selrow=-1
 ELSEIF py>pctrltop+rowheight & py<pctrltop+rowheight+rowheight & IS_IN(bcCOLSORT$,pctrlstyle$)<>0 THEN
  IF IS_IN(bcLISTVIEW$,pctrlstyle$)<>0 THEN
   BUNDLE.GET ptrctrl,"lbhdrcol",prevcol
   GOSUB @SBR_GetColClicked
   BUNDLE.PUT ptrctrl,"lbhdrcol",pcolclicked
   BUNDLE.GET ptrctrl,"lbhdrmark",gonum
   BUNDLE.GET ptrctrl,"lbhdrord",ang
   IF prevcol<>pcolclicked THEN LET ang=180
   IF ang=0 THEN LET ang=180 ELSE LET ang=0
   BUNDLE.PUT ptrctrl,"lbhdrord",ang
   GR.TEXT.WIDTH i,"^"
   GR.MODIFY gonum,"x",hdrX-14+i/2,"angle",ang
   GR.MODIFY gonum+1,"x",hdrX-14,"text","^"
   SPLIT cd$[],pctrlorigcap$,bcCOLBREAK$
   SPLIT d$[],cd$[pcolclicked+1],bcFLDBREAK$
   fc=IS_IN(bcCHECKBOX$,pctrlstyle$)
   fb=IS_IN(bcICON$,pctrlstyle$)
   FOR a=2 TO lbdatacnt
    LIST.GET lbdata,a,i$
    IF fc=0 THEN LET c$="" ELSE LIST.GET lbchecked,a,c$
    IF fb=0 THEN LET b$="" ELSE LIST.GET lbbmpname,a,b$
    UNDIM g$[]
    SPLIT.ALL g$[],i$,bcCOLBREAK$
    IF d$[3]="3" THEN
     i=VAL(REPLACE$(g$[pcolclicked],",",""))
     j$=RIGHT$("000000000000"+STR$(i),12)     
    ELSE
     j$=UPPER$(g$[pcolclicked])
    ENDIF
    LIST.REPLACE lbdata,a,j$+bcRECBREAK$+i$+bcRECBREAK$+c$+bcRECBREAK$+b$
   NEXT a
   UNDIM g$[]
   LIST.TOARRAY lbdata,g$[]
   IF ang=180 THEN ARRAY.REVERSE g$[2] ELSE ARRAY.SORT g$[2]
   FOR a=2 TO lbdatacnt
    UNDIM d$[]
    SPLIT.ALL d$[],g$[a],bcRECBREAK$
    LIST.REPLACE lbdata,a,d$[2]
    IF fc<>0 THEN LIST.REPLACE lbchecked,a,d$[3]
    IF fb<>0 THEN LIST.REPLACE lbbmpname,a,d$[4]
    g$[a]=d$[3]+d$[2]
   NEXT a
   CALL ModCtrlCap(selctrl,pctrlorigcap$+JOIN$(g$[],bcRECBREAK$),1)
   LET selrow=-4
  ENDIF
 ELSE
  BUNDLE.GET 1,"sbwidth",SBW
  LET dsprow=1+FLOOR((py-(pscrolltop-SBW))/rowheight)
  IF dsprow>=1 & dsprow<=rowcount THEN
   IF IS_IN(bcMULTILINE$,pctrlstyle$)<>0 & IS_IN(bcEDITABLE$,pctrlstyle$)<>0 THEN
    BUNDLE.GET ptrctrl,"multisrc",i$
    TEXT.INPUT j$,REPLACE$(i$,bcSTRCRLF$,bcLF$)
    LET j$=REPLACE$(j$,bcLF$,bcSTRCRLF$)
    IF j$<>i$ THEN
     CALL @setlistboxcap(ptrctrl,pctrlorigcap$+bcRECBREAK$+j$)
     LET pprevstart=2
     LET selrow=-2
    ELSE
     LET selrow=0
    ENDIF
    GOTO clikLBX
   ENDIF
   LET selrow=pprevstart+dsprow -1
   IF selrow<=lbdatacnt & selrow>0 THEN
    LET rc=0
    IF IS_IN(bcLISTVIEW$,pctrlstyle$)<>0 THEN
     GOSUB @SBR_GetColClicked
    ENDIF
    IF IS_IN(bcCHECKBOX$,pctrlstyle$)<>0 THEN
     IF px<pctrlleft+rowheight THEN
      LIST.GET lbchecked,selrow,chkbox$
      IF chkbox$="[_]" THEN
       IF IS_IN(bcMULTSEL$,pctrlstyle$)=0 THEN
        FOR i=2 TO lbdatacnt
         LIST.GET lbchecked,i,temp$
         IF temp$="[X]" THEN
          LIST.REPLACE lbchecked,i,"[_]"
         ENDIF
        NEXT i
       ENDIF
       LET i$="[X]"
       LET j=bcOPAQUE
      ELSE
       LET i$="[_]"
       LET j=bcTRANSPARENT
      ENDIF
      LIST.REPLACE lbchecked,selrow,i$
      LET rc=1
     ENDIF
    ENDIF
    LIST.GET lbdata,selrow,pctrldata$
    BUNDLE.PUT ptrctrl,"lbCurDspIdx",selrow
    IF rc=1 THEN LET selrow=-3
   ELSE
    LET selrow=0
   ENDIF
  ELSE
   LET selrow=0
  ENDIF
 ENDIF
!________
ClikLBX:
 FN.RTN selrow
FN.END
!
!  @ F O R M A T _ M U L T I L I N E S $
!
FN.DEF @FormatMultiLines$(pptrCtrl,pdata$,pMiddle,pWidth,pFont)
 LET bcCRLF$=CHR$(13)+CHR$(10)
 LET bcLF$=CHR$(10)
 LET bcSTRCRLF$="^^"
 LET bcNOSCROLL$="V"
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET bcFLDBREAK$=CHR$(183)
 BUNDLE.GET 1,"whitespace",WhiteSpace$
 BUNDLE.GET 1,"fontptrs",fontptr
 LET t$=pdata$
 LET t$=REPLACE$(t$,bcRECBREAK$,bcSTRCRLF$)
 LET t$=REPLACE$(t$,bcCRLF$,bcSTRCRLF$)
 LET t$=REPLACE$(t$,bcLF$,bcSTRCRLF$)
 LET pdata$=t$
 LET rx=pWidth-2
 IF IS_IN(bcNOSCROLL$,ctrlstyle$)=0 THEN
  BUNDLE.GET 1,"sbwidth",SBW
  LET rx=rx-SBW 
 ENDIF
 GR.TEXT.SIZE pFont
 GR.TEXT.ALIGN 1
 GR.GET.TEXTBOUNDS "abc   123",x,y,cx,cy
 LET CCnt=1+(rx/(cx/9))
 UNDIM bf[]
 UNDIM bc$[]
 UNDIM bw$[]
 UNDIM bs$[]
 UNDIM ln[]
 DIM bf[4]
 DIM bc$[3]
 DIM bw$[4]
 DIM bs$[4]
 DIM ln[4]
 LET nl=1
 LET bf[1]=0
 LET bs$[1]=""
 LET bc$[1]="*"
 LET bc$[2]=CHR$(175)
 LET bc$[3]=CHR$(164)
 LET bn=0
 LET rc$=""
 LET tb$="0"
 LET tu$="0"
 LET ti$="0"
 LET ta$="1"
 LET tc$="1"
 LET ts$="4"
 LET tf$="1"
 DO
  LET exCod=0
  IF LEN(t$)>2 THEN
   LET i=1
   WHILE i<>0
    IF MID$(t$,i,1)="<" THEN
     IF MID$(t$,i+2,1)=">" THEN
      LET a$=MID$(t$,i+1,1)
      LET t$=LEFT$(t$,i-1)+MID$(t$,i+3)
      IF a$>="0" & a$<="9" THEN
       ts$=a$
      ELSE
       SW.BEGIN a$
        SW.CASE "n"
         LET tb$="0"
         LET ti$="0"
         LET tu$="0"
         SW.BREAK
        SW.CASE "N"
         LET tb$="0"
         LET ti$="0"
         LET tu$="0"
         LET ta$="1"
         LET tc$="1"
         LET ts$="5"
         LET tf$="1"
         SW.BREAK
        SW.CASE "O"
         LET tf$="2"
         SW.BREAK
        SW.CASE "A"
         LET tf$="3"
         SW.BREAK
        SW.CASE "E"
         LET tf$="4"
         SW.BREAK
        SW.CASE "F"
         LET tf$="1"
         SW.BREAK
        SW.CASE "T"
         LET tf$="5"
         SW.BREAK
        SW.CASE "u"
         LET tf$="6"
         SW.BREAK
        SW.CASE "V"
         LET tf$="7"
         SW.BREAK
        SW.CASE "W"
         LET tf$="8"
         SW.BREAK
        SW.CASE "X"
         LET tf$="9"
         SW.BREAK
        SW.CASE "B"
         LET tb$="1"
         SW.BREAK
        SW.CASE "I"
         LET ti$="1"
         SW.BREAK
        SW.CASE "U"
         LET tu$="1"
         SW.BREAK
        SW.CASE "L"
         LET ta$="1"
         SW.BREAK
        SW.CASE "C"
         LET ta$="2"
         SW.BREAK
        SW.CASE "R"
         LET ta$="3"
         SW.BREAK
        SW.CASE "t"
         LET tc$="1" % text color
         SW.BREAK
        SW.CASE "d"
         LET tc$="2" % bcBLACK
         SW.BREAK
        SW.CASE "b"
         LET tc$="3" % bcBLUE
         SW.BREAK
        SW.CASE "g"
         LET tc$="4" % bcGREEN
         SW.BREAK
        SW.CASE "c"
         LET tc$="5" % bcLCYAN
         SW.BREAK
        SW.CASE "r"
         LET tc$="6" % bcRED
         SW.BREAK
        SW.CASE "m"
         LET tc$="7" % bcMAGENTA
         SW.BREAK
        SW.CASE "y"
         LET tc$="8" % bcLYELLOW
         SW.BREAK
        SW.CASE "a"
         LET tc$="9" % bcGRAY
         SW.BREAK
        SW.CASE "w"
         LET tc$=":" % bcWHITE
         SW.BREAK
        SW.CASE "-"
         LET ta$="2"
         LET t$=string$(CCnt,"-")+t$
         LET i=CCnt
         LET j=1
         LET exCod=1
         SW.BREAK
        SW.DEFAULT
         LET t$="****Unknown Tag Value: '"+a$+"'**** "+t$
        SW.BREAK
       SW.END
       IF exCod=1 THEN W_R.BREAK
      ENDIF
     ELSE
      IF MID$(t$,i+3,1)=">" THEN LET i=i+4 ELSE LET i=0
     ENDIF
    ELSE
     LET i=0
    ENDIF
   REPEAT
   IF exCod=1 THEN GOTO AdRow
   IF LEFT$(t$,1)="<" & MID$(t$,4,1)=">" THEN
    LET a$=MID$(t$,2,2)
    IF MID$(t$,5,2)=bcSTRCRLF$ THEN LET t$=MID$(t$,7) ELSE LET t$=MID$(t$,5)
    IF a$="BS" THEN
     LET nl=nl+1
     LET bn=bn+1
     LET bs$[nl]=bs$[nl-1]+"       "
     LET bw$[nl]=bs$[nl-1]+"   "+bc$[bn]+"  "
     LET bf[nl]=1
    ELSEIF a$="BE" THEN
     LET nl=nl-1
     LET bn=bn-1
    ELSEIF a$="NS" THEN
     LET nl=nl+1
     LET ln[nl]=0
     LET bs$[nl]=bs$[nl-1]+"       "
     LET bf[nl]=2
    ELSEIF a$="NE" THEN
     LET nl=nl-1
    ELSE
     IF bf[nl]>0 THEN
      IF a$="BL" THEN
       LET t$=bw$[nl]+t$
      ELSEIF a$="NL" THEN
       LET ln[nl]=ln[nl]+1
       LET i$=NumToStr$(ln[nl],0,0,0)
       LET nw$=RIGHT$("   "+i$,3)+": "
       LET t$=bs$[nl-1]+nw$+t$
      ELSE
       LET t$="*****Bad Bullet Code '"+a$+"'***** "+t$
      ENDIF
     ELSE
      LET t$="*****Bullet but No List Started '"+a$+"'***** "+t$
     ENDIF
     GOTO EdtLin
    ENDIF
    GOTO NxtLin
   ENDIF
  ENDIF
  IF bf[nl]>0 THEN LET t$=bs$[nl]+t$
!_______
EdtLin:
  LET j=pfont+((VAL(ts$)-4)*3)
  GR.TEXT.SIZE j
  tn=VAL(tf$)
  LIST.GET fontptr,tn,tf
  IF tn<5 THEN
   GR.TEXT.TYPEFACE tf
  ELSE
   GR.TEXT.SETFONT tf
  ENDIF
  GR.TEXT.ALIGN 1
  GR.GET.TEXTBOUNDS "abc   123",x,y,cx,cy
  LET CCnt=1+(rx/(cx/9))
  IF CCnt<LEN(t$) THEN LET i=CCnt ELSE LET i=LEN(t$)
  LET j=1
  LET s=i
  WHILE s>1
   GR.GET.TEXTBOUNDS LEFT$(t$,s),x,y,dx,dy
   IF dx<rx THEN
    LET i=s
    W_R.BREAK
   ENDIF
   LET s=s-1
  REPEAT
  j=1
  p=IS_IN(bcSTRCRLF$,LEFT$(t$,i))
  IF p<>0 THEN
   i=p-1
   j=3
  ELSE
   IF i<LEN(t$) THEN
    LET s=i
    WHILE s>1
     IF MID$(t$,s,1)=" " THEN
      LET i=s-1
      LET j=2
      W_R.BREAK
     ENDIF
     s=s-1
    REPEAT
   ENDIF
  ENDIF
!______
AdRow:
  LET a$=tb$+tu$+ti$+ta$+tc$+ts$+tf$
  LET rc$=rc$+bcRECBREAK$+a$+LEFT$(t$,i)
  LET t$=MID$(t$,i+j)
!_______
NxtLin:
 UNTIL t$=""
 FN.RTN rc$
FN.END
!
!  @ S E T _ L I S T B O X _ C A P
!
FN.DEF @setlistboxcap(ptrctrl,pvalue$)
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET bcLISTVIEW$="v"
 LET bcCHECKBOX$="X"
 LET bcMULTILINE$="="
 LET bcICON$="*"
 BUNDLE.GET ptrctrl,"style",ctrlstyle$
 LET i=IS_IN(bcRECBREAK$,pvalue$)
 IF i=0 THEN
  LET c$="Heading"
  LET d$="Row1"
 ELSE
  LET c$=LEFT$(pvalue$,i-1)
  LET d$=bcRECBREAK$+MID$(pvalue$,i+1)
 ENDIF
 BUNDLE.PUT ptrctrl,"origcap",c$
 IF IS_IN(bcLISTVIEW$,ctrlstyle$)<>0 THEN
  BUNDLE.GET 1,"frmscale",frmscale
  CALL @CalcColWidths(&c$,frmscale)
 ELSE
  IF IS_IN(bcMULTILINE$,ctrlstyle$)<>0 THEN
   BUNDLE.GET ptrctrl,"middle",middle
   BUNDLE.GET ptrctrl,"width",width
   BUNDLE.GET ptrctrl,"font",font
   LET multisrc$=MID$(d$,2)
   LET d$=@FormatMultiLines$(ptrctrl,&multisrc$,middle,width,font)
   BUNDLE.PUT ptrctrl,"multisrc",multisrc$
  ENDIF
 ENDIF
 BUNDLE.PUT ptrctrl,"sizecap",c$
 BUNDLE.GET ptrctrl,"datalst",datalst
 LIST.CLEAR datalst
 SPLIT f$[],d$,bcRECBREAK$
 ARRAY.LENGTH k,f$[]
 IF IS_IN(bcCHECKBOX$,ctrlstyle$)<>0 THEN
  BUNDLE.GET ptrctrl,"lbchecked",lbchecked
  LIST.CLEAR lbchecked
  FOR i=1 TO k
   IF LEFT$(f$[i],3)="[_]" | LEFT$(f$[i],3)="[x]" | LEFT$(f$[i],3)="[X]" THEN
    LET i$=LEFT$(f$[i],3)
    f$[i]=MID$(f$[i],4)
   ELSE
    LET i$="[_]"
   ENDIF
   LIST.ADD lbchecked,i$
  NEXT i
 ENDIF
 LIST.ADD.ARRAY datalst,f$[]
 LIST.SIZE datalst,datalstcnt
 BUNDLE.GET ptrctrl,"captxtobj",gonum
 IF gonum<>0 THEN
  LET i$=c$
  LET i=IS_IN(bcCOLBREAK$,i$)
  IF i<>0 THEN LET i$=LEFT$(i$,i-1)
  GR.MODIFY gonum,"text",i$
 ENDIF
 IF IS_IN(bcICON$,ctrlstyle$)<>0 THEN
  BUNDLE.GET ptrctrl,"lbbmpname",lbbmpname
  LIST.CLEAR lbbmpname
  FOR i=1 TO datalstcnt
   IF i=1 THEN
    LIST.ADD lbbmpname,""
   ELSE
    LIST.GET datalst,i,rowdata$
    LET j=IS_IN(bcCOLBREAK$,rowdata$)
    LIST.ADD lbbmpname,LEFT$(rowdata$,j-1)
    LIST.REPLACE datalst,i,MID$(rowdata$,j+1)
   ENDIF
  NEXT i
 ENDIF
 FN.RTN 0
FN.END
!
!  @ D I S A B L E _ L I S T B O X
!
FN.DEF @disablelistbox(ptrctrl,palpha)
 LET bcSEMIOPAQUE=128
 LET bcTRANSPARENT=0
 LET bcFILEDIALOG$="F"
 LET bcCHECKBOX$="X"
 LET bcLISTVIEW$="v"
 LET bcNOSCROLL$="V"
 LET bcNOHEADBOX$="T"
 LET bcRECBREAK$=CHR$(174)
 BUNDLE.GET ptrctrl,"style",ctrlstyle$
 BUNDLE.GET ptrctrl,"lbbakobj",lbbakobj
 BUNDLE.GET ptrctrl,"lbtxtobj",lbtxtobj
 BUNDLE.GET ptrctrl,"lbchkobj",lbchkobj
 BUNDLE.GET ptrctrl,"lbicnobj",lbicnobj
 BUNDLE.GET ptrctrl,"lbrowcount",rowcount
 BUNDLE.GET ptrctrl,"lbchecked",lbchecked
 BUNDLE.GET ptrctrl,"datalst",datalst
 LIST.SIZE datalst,datalstcnt
 FOR i=1 TO rowcount
  LIST.GET lbbakobj,i,gonum
  GR.MODIFY gonum,"alpha",bcTRANSPARENT
  IF IS_IN(bcLISTVIEW$,ctrlstyle$)=0 THEN
   LIST.GET lbtxtobj,i,gonum
   GR.MODIFY gonum,"alpha",palpha
  ENDIF
  IF IS_IN(bcCHECKBOX$,ctrlstyle$)<>0 THEN
   LET k1=bcTRANSPARENT
   LET k2=bcTRANSPARENT
   LIST.GET lbchkobj,i,gonum
   GR.MODIFY gonum,"alpha",k1
   GR.MODIFY gonum+1,"alpha",k2
   GR.MODIFY gonum+2,"alpha",k2
  ENDIF
  IF IS_IN(bcFILEDIALOG$,ctrlstyle$)<>0 THEN
   LIST.GET lbicnobj,i,gonum
   FOR j=0 TO 5
    GR.MODIFY gonum+j,"alpha",bcTRANSPARENT
   NEXT j
  ENDIF
 NEXT i
 IF IS_IN(bcNOSCROLL$,ctrlstyle$)=0 THEN
  BUNDLE.GET ptrctrl,"vscrfirstobj",firstscrollobj
  BUNDLE.GET ptrctrl,"vscrlastobj",lastscrollobj
  FOR i=firstscrollobj TO lastscrollobj
   GR.MODIFY i,"alpha",palpha
  NEXT i
 ENDIF
 IF IS_IN(bcNOHEADBOX$,ctrlstyle$)=0 THEN
  BUNDLE.GET ptrctrl,"qmf",gonumf
  BUNDLE.GET ptrctrl,"qml",gonuml
  FOR i=gonumf TO gonuml
   GR.MODIFY i,"alpha",bcTRANSPARENT
  NEXT i
 ENDIF
 FN.RTN 0
FN.END

!#@#@#@#_quick_nav

!
!  @drawquicknav
!
FN.DEF @drawquicknav(ptrctrl)
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcOPAQUE=0
 LET bcTRANSPARENT=255
 LET bcBLACK=1
 LET bcGREEN=3
 LET bcGRAY=8
 LET bcLGRAY=9
 LET bcLGREEN=11
 LET bcLRED=13
 LET bcLCYAN=12
 LET bcWHITE=16
 LET bcSYST2=18
 LET bcSYST3=19
 LET bcFRMDISPLAY=1
 LET bcFRMSELECT=4
 LET bcFRMBUTTON=6
 LET bcFRMPICTURE=7
 LET bcFRMLISTBOX=9
 LET bcFRMOPTBUTTON=11
 LET bcFRMFRAME=13
 LET bc3DBORDER$="9"
 LET bcALIGNCENTRE$="C"
 LET bcALIGNRIGHT$="R"
 LET bcROUND$=")"
 LET bcCAPBOLD$="b"  
 LET bcCAPITALIC$="i"
 LET bcDATABORDER$=">"
 LET bcDATBOLD$="B"
 LET bcFADEBACK$="+"
 LET bcHIDE$="H"
 LET bcSHAPEFILL$="f"
 LET bcRECBREAK$=CHR$(174)
 GOSUB @LoadRGBData
 BUNDLE.GET 1,"dwidth",dwidth
 BUNDLE.GET 1,"dheight",dheight
 BUNDLE.GET 1,"frmscale",frmscale
 BUNDLE.GET ptrctrl,"type",ltype
 BUNDLE.GET ptrctrl,"left",lleft
 BUNDLE.GET ptrctrl,"top",ltop
 BUNDLE.GET ptrctrl,"width",lwidth
 BUNDLE.GET ptrctrl,"height",lheight
 BUNDLE.GET ptrCtrl,"middle",lmiddle
 BUNDLE.GET ptrctrl,"font",font
 IF ltype=bcFRMLISTBOX THEN
  LET qnh=590
  qnt=20
  qnb=455
 ELSE
  LET qnh=520
  BUNDLE.GET 1,"swidth",swidth
  qnt=swidth+10
  qnb=385
 ENDIF
 LET qnw=540
 LET qnx=(dwidth-qnw)/2
 LET qny=(dheight-qnh)/2
 fraQNFrame=AddControl(bcFRMFRAME,"QuickNav", ~
   bcBLACK,bcGRAY,bcBLACK,bcSYST3, ~
   qny,qnx,30,qnw,qnh,20, ~
   bcHIDE$+bcCAPBOLD$+bcALIGNCENTRE$+bc3DBORDER$+bcFADEBACK$+bcCAPITALIC$)
 dspQNTxt=AddControl(bcFRMDISPLAY,"Search String", ~
   bcGREEN,bcSYST3,bcBLACK,bcSYST2, ~
   qny+45,qnx+20,140,qnw-170,50,20, ~
   bcDATABORDER$+bcCAPITALIC$+bcALIGNRIGHT$)
 cmdQNBS=AddControl(bcFRMBUTTON,"Backspace", ~
   bcBLACK,bcLGRAY,0,0, ~
   qny+45,qnx+qnw-140,0,120,50,20,bcDATBOLD$+bcROUND$)
 shpQNKeys=AddControl(bcFRMPICTURE,"", ~
   bcBLACK,bcSYST2,0,0, ~
   qny+115,qnx+20,0,qnw-40,250,1,bcSHAPEFILL$)
 cmdQNSpChr=AddControl(bcFRMBUTTON,"Sp.Char", ~
   bcGREEN,bcLGRAY,0,0, ~
   qny+315,qnx+qnw-255,0,100,50,20,bcDATBOLD$)
 selQNSpChr=AddControl(bcFRMSELECT,"", ~
   bcGREEN,bcSYST3,bcGREEN,bcLCYAN, ~
   qny+315,qnx+qnw-150,0,130,50,20, ~
   bcDATBOLD$+bcALIGNRIGHT$+bcCAPITALIC$)
 optQNScope=AddControl(bcFRMOPTBUTTON, ~
   "Search Target"+bcRECBREAK$+"Sorted Column"+bcRECBREAK$+"Row", ~
   bcGREEN,bcSYST3,bcBLACK,bcSYST2, ~
   qny+385,qnx+qnt,140,qnw-40,50,20, ~
   bcDATABORDER$+bcCAPITALIC$+bcALIGNRIGHT$)
 optQNType=AddControl(bcFRMOPTBUTTON, ~
   "Search Type"+bcRECBREAK$+"Starts With"+bcRECBREAK$+"Anywhere", ~
   bcGREEN,bcSYST3,bcBLACK,bcSYST2, ~
   qny+qnb,qnx+20,140,qnw-40,50,20, ~
   bcDATABORDER$+bcCAPITALIC$+bcALIGNRIGHT$)
 cmdQNFirst=AddControl(bcFRMBUTTON,"Find First", ~
   bcBLACK,bcLGREEN,0,0, ~
   qny+qnb+70,qnx+20,0,140,50,24,bcCAPBOLD$+bcROUND$)
 cmdQNNext=AddControl(bcFRMBUTTON,"Find Next",bcBLACK,bcLGREEN,0,0, ~
   qny+qnb+70,qnx+175,0,140,50,24, ~
   bcCAPBOLD$+bcROUND$)
 cmdQNCancel=AddControl(bcFRMBUTTON,"Cancel",bcBLACK,bcLRED,0,0, ~
   qny+qnb+70,qnx+340,0,140,50,24, ~
   bcCAPBOLD$+bcROUND$)
 CALL SetCtrlData(selQNSpChr,",")
 CALL SetCtrlCap(selQNSpChr," "+bcRECBREAK$+","+bcRECBREAK$+"."+bcRECBREAK$+";"+bcRECBREAK$ ~
   +":"+bcRECBREAK$+"'"+bcRECBREAK$+"#"+bcRECBREAK$+"-"+bcRECBREAK$+"="+bcRECBREAK$+"!"+bcRECBREAK$ ~ 
   +CHR$(34)+bcRECBREAK$+"£"+bcRECBREAK$+"$"+bcRECBREAK$+"%"+bcRECBREAK$+"^"+bcRECBREAK$ ~
   +"&"+bcRECBREAK$+"*"+bcRECBREAK$+"+"+bcRECBREAK$+"@"+bcRECBREAK$+"/"+bcRECBREAK$+"_"+bcRECBREAK$ ~
   +"("+bcRECBREAK$+")"+bcRECBREAK$+"["+bcRECBREAK$+"]"+bcRECBREAK$+"{"+bcRECBREAK$+"}"+bcRECBREAK$ ~
   +"~"+bcRECBREAK$+"<"+bcRECBREAK$+">"+bcRECBREAK$+"?")
 CALL SetCtrlData(dspQNTxt,"_")
 CALL DrawForm("","")
 GR.TEXT.ALIGN 2
 GR.TEXT.BOLD 1
 GR.TEXT.SIZE 20/frmscale
 LET kv$="1234567890QWERTYUIOPASDFGHJKLZXCVBNM "
 BUNDLE.PUT ptrctrl,"qnkvals",kv$
 LET x=0
 LET y=0
 LET dx=0
 LET dy=0
 CALL GetCtrlSize(shpQNKeys,&x,&y,&dx,&dy)
 ks=dx/10
 ARRAY.LOAD paK[],0,ks,ks,0,ks,ks
 LIST.CREATE n,kptr
 LIST.ADD.ARRAY kptr,paK[]
 ARRAY.LOAD paS[],200,0,190,10,10,ks-10,0,ks,200,ks
 LIST.CREATE n,sptr
 LIST.ADD.ARRAY sptr,paS[]
 LIST.CREATE n,qnbf
 LET n=y
 LET p=1
 LET c=bcWHITE
 LET k=10
 LET q=ks
 LET o=0
 FOR i=1 TO 5
  LET m=x+o
  FOR j=1 TO k
   IF i=5 THEN
    LET q=200
    LET km$="Space"
   ELSE
    LET km$=MID$(kv$,p,1)
   ENDIF
   GR.COLOR bcTRANSPARENT,BCMP[c],GCMP[c],RCMP[c],bcFILL
   GR.RECT gonum,m,n,m+q,n+ks
   IF p=1 THEN LET qnkbs=gonum
   LIST.ADD qnbf,gonum
   GR.COLOR bcTRANSPARENT,BCMP[bcGRAY],GCMP[bcGRAY],RCMP[bcGRAY],bcFILL
   IF q=ks THEN GR.POLY gonum,kptr,qx+m,qy+n ELSE GR.POLY gonum,sptr,qx+m,qy+n
   GR.LINE gonum,m,n,m+5,n+5
   GR.COLOR bcTRANSPARENT,BCMP[bcLGRAY],GCMP[bcLGRAY],RCMP[bcLGRAY],bcFILL
   GR.RECT gonum,m+5,n+5,m+q-5,n+ks-5
   GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
   GR.RECT gonum,m,n,m+q,n+ks
   GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcFILL
   GR.TEXT.DRAW gonum,m+(q/2),n+34,km$
   IF i=5 THEN F_N.BREAK
   LET p=p+1
   LET m=m+ks
  NEXT j
  IF i=1 THEN 
   LET n=n+ks
  ELSE
   LET n=n+ks
   IF i=2 THEN
    LET k=9
    LET o=ks/2
   ELSEIF i=3 THEN
    LET k=7
    LET o=ks
   ENDIF
  ENDIF
 NEXT i
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.PUT ptrctrl,"qnframe",fraQNFrame
 BUNDLE.GET ctrldata,"CP"+STR$(fraQNFrame),fractrl
 BUNDLE.PUT fractrl,"fralastptr",gonum
 BUNDLE.PUT ptrctrl,"qnkbs",qnkbs
 BUNDLE.PUT ptrctrl,"qnkbf",gonum
 BUNDLE.PUT ptrctrl,"qnbface",qnbf
 BUNDLE.PUT ptrctrl,"qnbs",cmdQNBS
 BUNDLE.PUT ptrctrl,"qnscope","Sorted Column"
 BUNDLE.PUT ptrctrl,"qntype","Starts With"
 BUNDLE.PUT ptrctrl,"qndrawn",1
 BUNDLE.PUT 1,"FrmObjCnt",gonum
 FN.RTN 0
FN.END
!
!  @ Q U I C K _ N A V
!
FN.DEF @quicknav$(ptrctrl,scope$,type$,start$)
 LET bcOPAQUE=255
 LET bcSEMIOPAQUE=128
 LET bcTRANSPARENT=0
 LET bcCOLBREAK$=CHR$(169)
 BUNDLE.GET ptrctrl,"qndrawn",i
 IF i=0 THEN CALL @drawquicknav(ptrctrl)
 BUNDLE.GET ptrctrl,"qnframe",fraQNFrame
 CALL ShowCtrl(fraQNFrame,1)
 BUNDLE.GET ptrctrl,"qnkbs",qnkbs
 BUNDLE.GET ptrctrl,"qnkbf",qnkbf
 FOR i=qnkbs TO qnkbf
  GR.MODIFY i,"alpha",bcOPAQUE
 NEXT i 
 BUNDLE.GET ptrctrl,"qnbs",cmdQNBS
 BUNDLE.GET ptrctrl,"qnbface",qnbf
 BUNDLE.GET ptrctrl,"qnkvals",kv$
 BUNDLE.GET ptrctrl,"qnscope",s$
 BUNDLE.GET ptrctrl,"qntype",t$
 LIST.TOARRAY qnbf,bfgo[]
 CALL ModCtrlData(cmdQNBS+4,s$,0)
 CALL ModCtrlData(cmdQNBS+5,t$,0)
 GR.RENDER
 LET nqx=0
 WHILE nqx=0
  LET selCtrl=TouchCheck(Period,cmdQNBS,cmdQNBS+8)
  SW.BEGIN selCtrl
   SW.CASE cmdQNBS
    LET i$=GetCtrlData$(cmdQNBS-1)
    LET i$=LEFT$(i$,LEN(i$)-1)    
    IF i$<>"" THEN
     LET i$=LEFT$(i$,LEN(i$)-1)+"_"    
     CALL ModCtrlData(cmdQNBS-1,i$,1)
    ENDIF
    SW.BREAK
   SW.CASE cmdQNBS+1 % Keys
    LET x=0
    LET y=0
    LET dx=0
    LET dy=0
    CALL GetCtrlClickXY(cmdQNBS+1,DispObj,BmpObj,&x,&y)
    CALL GetCtrlSize(cmdQNBS+1,x,y,&dx,&dy)
    ks=dx/10
    LET b=0
    LET r=1+int(y/ks)
    IF r=2 THEN
     LET b=10
    ELSEIF r=3 THEN
     LET b=20
     LET x=x-(ks/2)
    ELSEIF r>3 THEN
     LET x=x-ks
     IF r=4 THEN
      LET b=29
     ELSE
      IF x<4*ks THEN
       LET b=36
       LET x=30
      ELSE
       LET b=-1
      ENDIF
     ENDIF
    ENDIF
    IF b>=0 THEN
     LET b=b+1+int(x/ks)
     GR.MODIFY bfgo[b],"alpha",bcSEMIOPAQUE
     GR.RENDER
     PAUSE 250
     GR.MODIFY bfgo[b],"alpha",bcOPAQUE
     LET i$=GetCtrlData$(cmdQNBS-1)
     LET i$=LEFT$(i$,LEN(i$)-1)    
     LET i$=i$+MID$(kv$,b,1)+"_"    
     CALL ModCtrlData(cmdQNBS-1,i$,1)
    ENDIF
    SW.BREAK
   SW.CASE cmdQNBS+2 % Sp.Chr btn
    LET j$=GetCtrlData$(cmdQNBS+3)
    LET i$=GetCtrlData$(cmdQNBS-1)
    LET i$=LEFT$(i$,LEN(i$)-1)    
    LET i$=i$+j$+"_"
    CALL ModCtrlData(cmdQNBS-1,i$,1)
    SW.BREAK
   SW.CASE cmdQNBS+6 % First
   SW.CASE cmdQNBS+7 % Next
    LET rc$=UPPER$(GetCtrlData$(cmdQNBS-1))
    LET rc$=LEFT$(i$,LEN(rc$)-1)    
    LET i$=GetCtrlData$(cmdQNBS+4)
    BUNDLE.PUT ptrctrl,"qnscope",i$
    LET scope$=LEFT$(i$,1)
    LET i$=GetCtrlData$(cmdQNBS+5)
    BUNDLE.PUT ptrctrl,"qntype",i$
    LET type$=LEFT$(i$,1)
    IF selCtrl=cmdQNBS+6 THEN LET start$="F" ELSE LET start$="N"
    LET nqx=1
    SW.BREAK
   SW.CASE cmdQNBS+8 % Cancel
    LET rc$=bcCOLBREAK$
    LET nqx=1
    SW.BREAK
  SW.END
 REPEAT
 CALL hidectrl(fraQNFrame,1)
 FN.RTN rc$
FN.END
!
!  G E T _ S E L E C T E D _ I D X
!
FN.DEF getSelectedIdx(pctrlno)
 LET bcFRMLISTBOX=9
 LET bcLISTVIEW$="v"
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"type",ctrltype
 BUNDLE.GET ptrctrl,"style",style$
 IF ctrltype=bcFRMLISTBOX THEN
  BUNDLE.GET ptrctrl,"lbCurDspIdx",rc
  IF rc>0 THEN LET rc=rc-1
 ELSE
  LET rc=0
 ENDIF
 FN.RTN rc
FN.END
!
!  G E T _ R O W _ C O U N T
!
FN.DEF GetRowCount(pctrlno)
 LET bcRECBREAK$=CHR$(174)
 LET bcFRMLISTBOX=9
 LET bcFRMCOMBOBOX=15
 BUNDLE.GET 1,"ctrldata",ctrlstor
 BUNDLE.GET ctrlstor,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"type",ctrltype
 IF ctrltype=bcFRMLISTBOX | ctrltype=bcFRMCOMBOBOX THEN
  BUNDLE.GET ptrctrl,"datalst",datalst
  LIST.SIZE datalst,rc
  LET rc=rc-1
 ELSE
  LET rc=0
 ENDIF
 FN.RTN rc
FN.END
!
!  G E T _ R O W _ D A T A $
!
FN.DEF getrowdata$(pCtrlNo,pIdx)
 LET bcFRMLISTBOX=9
 LET pIdx=pIdx+1
 BUNDLE.GET 1,"ctrldata",ctrlstor
 BUNDLE.GET ctrlstor,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"type",ctrltype
 IF ctrltype=bcFRMLISTBOX THEN
  BUNDLE.GET ptrctrl,"datalst",datalst
  LIST.GET datalst,pIdx,rc$
 ELSE
  LET rc$=""
 ENDIF
 FN.RTN rc$
FN.END
!
!  G E T _ C O L _ C L I C K E D
!
FN.DEF getcolclicked(pctrlno)
 LET bcFRMLISTBOX=9
 LET bcLISTVIEW$="v"
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"type",ctrltype
 BUNDLE.GET ptrctrl,"style",style$
 IF ctrltype=bcFRMLISTBOX & IS_IN(bcLISTVIEW$,style$)<>0 THEN
  BUNDLE.GET ptrctrl,"lbcolclicked",rc
 ELSE
  LET rc=0
 ENDIF
 FN.RTN rc
FN.END
!
!  G E T _ C H E C K E D _ S T A T E
!
FN.DEF getcheckedstate(pctrlno,pIdx)
 LET bcFRMLISTBOX=9
 LET bcCHECKBOX$="X"
 LET pIdx=pIdx+1
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"type",ctrltype
 BUNDLE.GET ptrctrl,"style",style$
 LET rc=0
 IF ctrltype=bcFRMLISTBOX & IS_IN(bcCHECKBOX$,style$)<>0 THEN
  BUNDLE.GET ptrctrl,"lbchecked",lbchecked
  LIST.GET lbchecked,pIdx,i$
  IF i$="[X]" THEN LET rc=1
 ENDIF
 FN.RTN rc
FN.END
!
!  G E T _ C H E C K E D _ C O U N T
!
FN.DEF getcheckedcount(pctrlno)
 LET bcFRMLISTBOX=9
 LET bcCHECKBOX$="X"
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"type",ctrltype
 BUNDLE.GET ptrctrl,"style",style$
 LET rc=0
 IF ctrltype=bcFRMLISTBOX & IS_IN(bcCHECKBOX$,style$)<>0 THEN
  BUNDLE.GET ptrctrl,"lbchecked",lbchecked
  LIST.SIZE lbchecked,j
  FOR i=1 TO j
   LIST.GET lbchecked,i,i$
   IF i$="[X]" THEN LET rc=rc+1
  NEXT i
 ENDIF
 FN.RTN rc
FN.END
!
!  S E T _ L V W _ S O R T _ C O L
!
FN.DEF SetLVWSortCol(pctrlno,pcolno)
 BUNDLE.GET 1,"ctrldata",ctrlstor
 BUNDLE.GET ctrlstor,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.PUT ptrctrl,"lbhdrcol",pcolno
 FN.RTN 0
FN.END
!
!  S E T _ C L R _ C H E C K B O X
!
FN.DEF setclrcheckbox(pctrlno,pIdx,pchecked,pRend)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcFRMLISTBOX=9
 LET bcCHECKBOX$="X"
 LET pIdx=pIdx+1
 BUNDLE.GET 1,"ctrldata",ctrlstor
 BUNDLE.GET ctrlstor,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"type",ctrltype
 BUNDLE.GET ptrctrl,"style",ctrlstyle$
 IF ctrltype=bcFRMLISTBOX & IS_IN(bcCHECKBOX$,ctrlstyle$)<>0 THEN
  BUNDLE.GET ptrctrl,"lbchecked",lbchecked
  IF pchecked=0 THEN
   LET i$="[_]"
   LET j=bcTRANSPARENT
  ELSE
   LET i$="[X]"
   LET j=bcOPAQUE
  ENDIF
  LIST.REPLACE lbchecked,pIdx,i$
  BUNDLE.PUT ptrctrl,"lbchecked",lbchecked
  BUNDLE.GET ptrctrl,"FirstDspIdx",FirstDspIdx
  BUNDLE.GET ptrctrl,"LastDspIdx",LastDspIdx
  IF pIdx-1>=FirstDspIdx & pIdx-1<=LastDspIdx THEN
   BUNDLE.GET ptrctrl,"lbchkobj",lbchkobj
   LIST.GET lbchkobj,pIdx-FirstDspIdx,gonum
   FOR n=1 TO 2
    GR.MODIFY gonum+n,"alpha",j
   NEXT n
   IF pRend=1 THEN
    GR.RENDER
   ENDIF
  ENDIF
 ENDIF
 FN.RTN 0
FN.END
!
!  A D D _ L I S T _ R O W
!
FN.DEF addlistrow(pctrlno,pIdx,prowdata$,pRend)
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET bcCHECKBOX$="X"
 LET bcICON$="*"
 LET pIdx=pIdx+1
 BUNDLE.GET 1,"ctrldata",ctrlstor
 BUNDLE.GET ctrlstor,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"style",ctrlstyle$
 BUNDLE.GET ptrctrl,"datalst",datalst
 LIST.SIZE datalst,datalstcnt
 IF pIdx>datalstcnt THEN LET pIdx=1
 IF pIdx=1 THEN
  LIST.ADD datalst,pRowData$
  LET dIdx=datalstcnt
 ELSE
  LIST.INSERT datalst,pIdx,pRowData$
  LET dIdx=pIdx
 ENDIF
 UNDIM i$[]
 LIST.TOARRAY datalst,i$[]
 IF IS_IN(bcCHECKBOX$,ctrlstyle$)<>0 THEN
  BUNDLE.GET ptrctrl,"lbchecked",lbchecked
  IF pIdx=1 THEN
   LIST.ADD lbchecked,"[_]"
  ELSE
   LIST.INSERT lbchecked,pIdx,"[_]"
  ENDIF
 ENDIF
 IF IS_IN(bcICON$,ctrlstyle$)<>0 THEN
  BUNDLE.GET ptrctrl,"lbbmpname",lbbmpname
  LET j=IS_IN(bcCOLBREAK$,pRowData$)
  IF pIdx=1 THEN
   LIST.ADD lbbmpname,LEFT$(pRowData$,j-1)
  ELSE
   LIST.INSERT lbbmpname,pIdx,LEFT$(pRowData$,j-1)
  ENDIF
  LIST.REPLACE datalst,dIdx,MID$(pRowData$,j+1)
 ENDIF
 BUNDLE.PUT ptrctrl,"lbCurDspIdx",0
 BUNDLE.GET ptrctrl,"FirstDspIdx",FirstDspIdx
 BUNDLE.GET ptrctrl,"LastDspIdx",LastDspIdx
 IF dIdx>=FirstDspIdx & dIdx<=LastDspIdx THEN
  rc=@RedrawListBoxRows(pctrlno,0)
 ELSE
  BUNDLE.GET ptrctrl,"lbrowcount",rowcount
  BUNDLE.GET ptrctrl,"middle",rowheight
  BUNDLE.GET ptrctrl,"lbprevstart",curstart
  GOSUB @UpdtVScrollBar
 ENDIF
 IF pRend=1 THEN GR.RENDER
 FN.RTN 0
FN.END
!
!  D E L E T E _ L I S T _ R O W
!
FN.DEF deletelistrow(pctrlno,pIdx,pRend)
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET bcCHECKBOX$="X"
 LET bcICON$="*"
 LET pIdx=pIdx+1
 BUNDLE.GET 1,"ctrldata",ctrlstor
 BUNDLE.GET ctrlstor,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"style",ctrlstyle$
 BUNDLE.GET ptrctrl,"datalst",datalst
 LIST.SIZE datalst,datalstcnt
 LIST.REMOVE datalst,pIdx
 LET dIdx=pIdx
 IF IS_IN(bcCHECKBOX$,ctrlstyle$)<>0 THEN
  BUNDLE.GET ptrctrl,"lbchecked",lbchecked
  LIST.REMOVE lbchecked,pIdx
 ENDIF
 IF IS_IN(bcICON$,ctrlstyle$)<>0 THEN
  BUNDLE.GET ptrctrl,"lbbmpname",lbbmpname
  LIST.REMOVE lbmpname,pIdx
 ENDIF
 UNDIM i$[]
 BUNDLE.PUT ptrctrl,"lbCurDspIdx",0
 BUNDLE.PUT ptrctrl,"data",""
 BUNDLE.GET ptrctrl,"FirstDspIdx",FirstDspIdx
 BUNDLE.GET ptrctrl,"LastDspIdx",LastDspIdx
 IF pIdx>=FirstDspIdx & pIdx<=LastDspIdx THEN
  CALL @RedrawListBoxRows(pctrlno,0)
 ELSE
  BUNDLE.GET ptrctrl,"lbrowcount",rowcount
  BUNDLE.GET ptrctrl,"middle",rowheight
  BUNDLE.GET ptrctrl,"lbprevstart",curstart
  GOSUB @UpdtVScrollBar
 ENDIF
 IF pRend=1 THEN GR.RENDER
 FN.RTN 0
FN.END
!
!  U P D A T E _ L I S T _ R O W
!
FN.DEF updatelistrow(pCtrlNo,pIdx,pRowData$,pRend)
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET bcCHECKBOX$="X"
 LET bcICON$="*"
 LET pIdx=pIdx+1
 BUNDLE.GET 1,"ctrldata",ctrlstor
 BUNDLE.GET ctrlstor,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"style",ctrlstyle$
 BUNDLE.GET ptrctrl,"datalst",datalst
 LIST.SIZE datalst,datalstcnt
 LIST.REPLACE datalst,pIdx,pRowData$
 IF IS_IN(bcICON$,ctrlstyle$)<>0 THEN
  BUNDLE.GET ptrctrl,"lbbmpname",lbbmpname
  LET j=IS_IN(bcCOLBREAK$,pRowData$)
  LIST.REPLACE lbbmpname,pIdx,LEFT$(pRowData$,j-1)
  LIST.REPLACE datalst,pIdx,MID$(pRowData$,j+1)
 ENDIF
 BUNDLE.PUT ptrctrl,"data",pRowData$
 BUNDLE.GET ptrctrl,"FirstDspIdx",FirstDspIdx
 BUNDLE.GET ptrctrl,"LastDspIdx",LastDspIdx
 IF pIdx-1>=FirstDspIdx & pIdx-1<=LastDspIdx THEN
  CALL @RedrawListBoxRows(pctrlno,0)
  IF pRend=1 THEN GR.RENDER
 ENDIF
 FN.RTN 0
FN.END

!#@#@#@#_calendar_control

!
!  @ D R A W _ C A L E N D A R
!
FN.DEF @drawcalendar(pstyle$)
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcBLACK=1
 LET bcTRANSPARENT=0
 LET bcSEMIOPAQUE=128
 LET bcOPAQUE=255
 LET bcALIGNCENTRE$="C"
 LET bcCAPBOLD$="b"
 LET bcNOBORDER$="-"
 GOSUB @LoadRGBData
 BUNDLE.GET 1,"DateSize",datesize
 BUNDLE.GET 1,"swidth",swidth
 BUNDLE.GET 1,"sheight",sheight
 BUNDLE.GET 1,"FrmObjCnt",FrmObjCnt
 BUNDLE.GET 1,"calbak",calbak
 BUNDLE.GET 1,"mybuttext",mybuttext
 BUNDLE.GET 1,"mybutface",mybutface
 BUNDLE.GET 1,"ymtext",ymtext
 BUNDLE.GET 1,"dayheadbak",dayheadbak
 BUNDLE.GET 1,"dayheadtxt",dayheadtxt
 BUNDLE.GET 1,"ssbak",ssbak
 BUNDLE.GET 1,"mtwtfbak",mtwtfbak
 BUNDLE.GET 1,"gridcol",gridcol
 BUNDLE.GET 1,"daynotxt",daynotxt
 BUNDLE.GET 1,"seldaybak",seldaybak
 BUNDLE.GET 1,"scbuttext",scbuttext
 BUNDLE.GET 1,"scbutface",scbutface
 ARRAY.LOAD DOW$[],"Sun","Mon","Tue","Wed","Thu","Fri","Sat"
 GR.COLOR bcSEMIOPAQUE,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcFILL
 GR.RECT gonum,0,0,swidth,sheight
 LET calfirstgrptr=gonum
 LET u=datesize
 LET x=(swidth-7*u)/2
 LET y=(sheight-9*u)/2
 LET calmid=x+(7*u)/2
 GR.COLOR bcOPAQUE,BCMP[calbak],GCMP[calbak],RCMP[calbak],bcFILL
 GR.RECT gonum,x+(2*u),y,x+(5*u),y+u
 GR.RECT gonum,x+(2*u),y+u,x+(5*u),y+(2*u)
 GR.COLOR bcOPAQUE,BCMP[dayheadbak],GCMP[dayheadbak],RCMP[dayheadbak],bcFILL
 GR.RECT gonum,x,y+(2*u),x+(7*u),y+(3*u)
 GR.COLOR bcOPAQUE,BCMP[mtwtfbak],GCMP[mtwtfbak],RCMP[mtwtfbak],bcFILL
 GR.RECT gonum,x,y+(3*u),x+(7*u),y+(10*u)
 GR.COLOR bcOPAQUE,BCMP[ssbak],GCMP[ssbak],RCMP[ssbak],bcFILL
 GR.RECT gonum,x,y+(3*u),x+u,y+(9*u)
 GR.RECT gonum,x+(6*u),y+(3*u),x+(7*u),y+(9*u)
 GR.COLOR bcOPAQUE,BCMP[gridcol],GCMP[gridcol],RCMP[gridcol],bcNOFILL
 FOR i=4 TO 8
  GR.LINE gonum,x,y+(i*u),x+(7*u),y+(i*u)
 NEXT i
 FOR i=1 TO 6
  GR.LINE gonum,x+(i*u),y+(2*u),x+(i*u),y+(9*u)
 NEXT i
 GR.LINE gonum,x,y+u,x+(7*u),y+u
 GR.LINE gonum,x,y+(2*u),x+(7*u),y+(2*u)
 GR.LINE gonum,x,y+(3*u),x+(7*u),y+(3*u)
 GR.LINE gonum,x,y+(9*u),x+(7*u),y+(9*u)
 LET gobord1=0
 LET gobord2=0
 IF IS_IN(bcNOBORDER$,pstyle$)<>0 THEN LET i=bcTRANSPARENT ELSE LET i=bcOPAQUE
 CALL @drawborder("99",i,x,y,x+(7*u),y+(10*u),&gobord1,&gobord2)
 LET fs=u/2
 LET bdr=fs/4
 CALL @drawbutton("Cal1",mybuttext,mybutface,x,y,u,u,bdr,pstyle$,0,"<<",bcOPAQUE, ~
      textptr,backptr)
 CALL @drawbutton("Cal2",mybuttext,mybutface,x+u,y,u,u,bdr,pstyle$,0,"<",bcOPAQUE, ~
      textptr,backptr)
 CALL @drawbutton("Cal3",mybuttext,mybutface,x+5*u,y,u,u,bdr,pstyle$,0,">",bcOPAQUE, ~
      textptr,backptr)
 CALL @drawbutton("Cal4",mybuttext,mybutface,x+6*u,y,u,u,bdr,pstyle$,0,">>",bcOPAQUE, ~
      textptr,backptr)
 CALL @drawbutton("Cal5",mybuttext,mybutface,x,y+u,u,u,bdr,pstyle$,0,"<<",bcOPAQUE, ~
      textptr,backptr)
 CALL @drawbutton("Cal6",mybuttext,mybutface,x+u,y+u,u,u,bdr,pstyle$,0,"<",bcOPAQUE, ~
      textptr,backptr)
 CALL @drawbutton("Cal7",mybuttext,mybutface,x+5*u,y+u,u,u,bdr,pstyle$,0,">",bcOPAQUE, ~
      textptr,backptr)
 CALL @drawbutton("Cal8",mybuttext,mybutface,x+6*u,y+u,u,u,bdr,pstyle$,0,">>",bcOPAQUE, ~
      textptr,backptr)
 LET calselecttxtobj=gonum
 LET calcanceltxtobj=gonum
 CALL @drawbutton("Cal9",scbuttext,scbutface,calmid,y+(9*u),calmid-x,u,bdr,pstyle$+bcCAPBOLD$,u/2, ~
     "Abbrechen",bcOPAQUE,&calselecttxtobj,backptr)
 CALL @drawbutton("CalA",scbuttext,scbutface,x,y+(9*u),calmid-x,u,bdr, ~
      pstyle$+bcCAPBOLD$,u/2,"Ok",bcOPAQUE,&calcanceltxtobj,backptr)
 LET fo=@getfontyoffset(u,fs)
 GR.TEXT.SIZE fs
 GR.COLOR bcOPAQUE,BCMP[dayheadtxt],GCMP[dayheadtxt],RCMP[dayheadtxt],bcFILL
 FOR i=1 TO 7
  GR.TEXT.DRAW gonum,x+(i*u)-(u/2),y+(2*u)+fo,LEFT$(dow$[i],1)
 NEXT i
 GR.COLOR bcOPAQUE,BCMP[ymtext],GCMP[ymtext],RCMP[ymtext],bcFILL
 GR.TEXT.BOLD 1
 GR.TEXT.DRAW gonum,calmid,y+fo,""
 LET calyeartxtobj=gonum
 GR.TEXT.DRAW gonum,calmid,y+u+fo,""
 LET calmonthtxtobj=gonum
 GR.COLOR bcOPAQUE,BCMP[seldaybak],GCMP[seldaybak],RCMP[seldaybak],bcFILL
 LET xx=x+1
 LET yy=y+(3*u)+1
 GR.RECT gonum,xx,yy,xx+u-2,yy+u-2
 LET calseldayobj=gonum
 GR.COLOR bcOPAQUE,BCMP[daynotxt],GCMP[daynotxt],RCMP[daynotxt],bcFILL
 LET fs=u/2
 LET fo=@getfontyoffset(u,fs)
 GR.TEXT.SIZE fs
 LET j=1
 LET k=3
 caldaytxtobj=gonum+1
 FOR i=1 TO 42
  GR.TEXT.DRAW gonum,x+(j*u)-(u/2),y+(k*u)+fo,""
  LET j=j+1
  IF j>7 THEN
   LET j=1
   LET k=k+1
  ENDIF
 NEXT i
 BUNDLE.PUT 1,"calendardrawn",1
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.PUT ctrldata,"calfirstgrptr",calfirstgrptr
 BUNDLE.PUT ctrldata,"callastgrptr",gonum
 BUNDLE.PUT 1,"FrmObjCnt",gonum
 BUNDLE.PUT ctrldata,"calyeartxtobj",calyeartxtobj
 BUNDLE.PUT ctrldata,"calmonthtxtobj",calmonthtxtobj
 BUNDLE.PUT ctrldata,"caldaytxtobj",caldaytxtobj
 BUNDLE.PUT ctrldata,"calseldayobj",calseldayobj
 BUNDLE.PUT ctrldata,"calselecttxtobj",calselecttxtobj
 BUNDLE.PUT ctrldata,"calcanceltxtobj",calcanceltxtobj
 BUNDLE.PUT ctrldata,"calborder1",gobord1
 BUNDLE.PUT ctrldata,"calborder2",gobord2
 FN.RTN 0
FN.END
!
!  B R I N G _ T O _ F R O N T
!
FN.DEF @BringToFront(firstptr,lastptr,bSrc)
 GR.GETDL OLst[],1
 ARRAY.LENGTH dlc,OLst[]
 DIM DLst[dlc]
 LET j=1
 IF bSrc=0 THEN
  FOR i=1 TO dlc
   IF i<firstptr | i>lastptr THEN
    LET DLst[j]=i
    LET j=j+1
   ENDIF
  NEXT i
 ELSE
  FOR i=1 TO dlc
   IF i<firstptr | i>lastptr THEN
    LET DLst[j]=OLst[i]
    LET j=j+1
   ENDIF
  NEXT i
 ENDIF
 LET k=0
 FOR i=firstptr TO lastptr
  LET DLst[j]=firstptr+k
  LET j=j+1
  LET k=k+1
 NEXT i
 GR.NEWDL DLst[]
 FN.RTN 0
FN.END
!
!  @ C L I C K _ D A T E
!
FN.DEF @clickdate(pctrldattxtobj,pctrldata$,pctrlstyle$)
 LET bcOPAQUE=255
 LET bcSEMIOPAQUE=128
 LET bcTRANSPARENT=0
 LET bcNOBORDER$="-"
 ARRAY.LOAD month$[],"Januar","Februar","März","April","Mai","Juni","Juli","August"~
            "September","Oktober","November","Dezember"
 DIM dc[42]
 BUNDLE.GET 1,"calendardrawn",rc
 IF rc=0 THEN CALL @drawcalendar(pctrlstyle$)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"calfirstgrptr",calfirstgrptr
 BUNDLE.GET ctrldata,"callastgrptr",callastgrptr
 BUNDLE.GET ctrldata,"calyeartxtobj",calyeartxtobj
 BUNDLE.GET ctrldata,"calmonthtxtobj",calmonthtxtobj
 BUNDLE.GET ctrldata,"caldaytxtobj",caldaytxtobj
 BUNDLE.GET ctrldata,"calseldayobj",calseldayobj
 BUNDLE.GET ctrldata,"calselecttxtobj",calselecttxtobj
 BUNDLE.GET ctrldata,"calcanceltxtobj",calcanceltxtobj
 BUNDLE.GET ctrldata,"calborder1",gobord1
 BUNDLE.GET ctrldata,"calborder2",gobord2
 CALL @BringToFront(calfirstgrptr,callastgrptr,0)
 FOR i=calfirstgrptr TO callastgrptr
  GR.SHOW i
 NEXT i
 LET caldate$=LEFT$(pctrldata$,10)
 IF caldate$<>"" THEN
  LET yr$=LEFT$(caldate$,4)
  LET mth$=MID$(caldate$,6,2)
  LET dy$=MID$(caldate$,9,2)
 ELSE
  TIME yr$,mth$,dy$,hr$,min$,sec$
 ENDIF
 LET yn=VAL(yr$)
 LET mn=VAL(mth$)
 LET dn=VAL(dy$)
 BUNDLE.GET 1,"DateSize",datesize
 BUNDLE.GET 1,"swidth",swidth
 BUNDLE.GET 1,"sheight",sheight
 LET u=datesize
 LET x=(swidth-7*u)/2
 LET y=(sheight-9*u)/2
 LET calmid=x+(7*u)/2
 LET pbutton$=""
 LET bobj=0
 DO
  LET caldate$=NumToStr$(yn,0,0,4)+"-"+NumToStr$(mn,0,0,2)+"-"+NumToStr$(dn,0,0,2)
  GR.MODIFY calyeartxtobj,"text",LEFT$(caldate$,4)
  GR.MODIFY calmonthtxtobj,"text",month$[mn]
  LET i$=""
  LET dw=getdow(LEFT$(caldate$,8)+"01",&i$)
  LET ml=daysinmonth(caldate$)
  LET o=caldaytxtobj
  FOR i=1 TO 42
   LET dc[i]=0
  NEXT i
  LET j=dw
  FOR i=1 TO ml
   LET dc[j]=i
   LET j=j+1
  NEXT i
  LET j=1
  LET k=3
  FOR i=1 TO 42
   IF dc[i]<>0 THEN
    IF dn=dc[i] THEN
     LET xx=x+((j-1)*u)+1
     LET yy=y+(k*u)+1
     GR.MODIFY calseldayobj,"left",xx,"top",yy,"right",xx+u-2,"bottom",yy+u-2,"alpha",bcOPAQUE
    ENDIF
    GR.MODIFY o,"text",NumToStr$(dc[i],0,0,0)
   ELSE
    GR.MODIFY o,"text",""
   ENDIF
   LET j=j+1
   IF j>7 THEN
    LET j=1
    LET k=k+1
   ENDIF
   LET o=o+1
  NEXT i
  GR.RENDER
  LET bpressed=0
  DO
   LET tch=0
   GR.TOUCH tch,tx,ty
   IF tch=1 THEN
    GR.BOUNDED.TOUCH tch,x,y,x+(7*u),y+(10*u)
    IF tch=1 THEN
     LET ox=FLOOR((tx-x)/u)
     LET oy=FLOOR((ty-y)/u)
     IF oy=9 THEN
      IF tx<calmid THEN
       LET pbutton$="Ok"
       LET bobj=calcanceltxtobj
      ELSE
       LET pbutton$="Abbrechen"
       LET bobj=calselecttxtobj
      ENDIF
     ENDIF
     IF bobj<>0 THEN
!      GR.MODIFY bobj,"text","Ok"
!      GR.RENDER
     ENDIF
     DO
      GR.TOUCH tuch,ux,uy
     UNTIL tuch=0
     IF bobj<>0 THEN
      GR.MODIFY bobj,"text",pbutton$
      GR.RENDER
     ENDIF
     LET bpressed=1
    ENDIF
   ENDIF
  UNTIL bpressed=1
  CALL @soundrtn()
  IF oy=0 THEN
   IF ox=0 THEN
    LET yn=yn-10
   ELSEIF ox=1 THEN
    LET yn=yn-1
   ELSEIF ox=5 THEN
    LET yn=yn+1
   ELSEIF ox=6 THEN
    LET yn=yn+10
   ENDIF
  ENDIF
  IF oy=1 THEN
   IF ox=0 THEN
    LET mn=mn-4
   ELSEIF ox=1 THEN
    LET mn=mn-1
   ELSEIF ox=5 THEN
    LET mn=mn+1
   ELSEIF ox=6 THEN
    LET mn=mn+4
   ENDIF
   IF mn<1 THEN
    LET mn=1
   ELSEIF mn>12 THEN
    LET mn=12
   ENDIF
  ENDIF
  IF oy>2 & oy<9 THEN
   LET i=ox+((oy-3)*7)+1
   IF dc[i]<>0 THEN LET dn=dc[i]
  ENDIF
  IF oy=9 THEN
   IF tx<calmid THEN
    LET dw=getdow(caldate$,&i$)
    LET caldate$=caldate$+"-"+i$
   ELSE
    LET caldate$=pctrldata$
   ENDIF
  ENDIF
 UNTIL pbutton$<>""
 UNDIM  dc[]
 IF pctrldata$<>caldate$ THEN
  LET pctrldata$=caldate$
  GR.MODIFY pctrldattxtobj,"text",pctrldata$
  LET rc=1
 ELSE
  LET rc=0
 ENDIF
 FOR i=calfirstgrptr TO callastgrptr
  GR.HIDE i
 NEXT i
 GR.RENDER
 FN.RTN rc
FN.END
!
!  G E T _ D O W
!
FN.DEF getdow(pdate$,pDayName$)
 ARRAY.LOAD DOW$[],"Sun","Mon","Tue","Wed","Thu","Fri","Sat"
 LET yyyy=VAL(MID$(pdate$,1,4))
 LET mm=VAL(MID$(pdate$,6,2))
 LET dd=VAL(MID$(pdate$,9,2))
 LET a=FLOOR((14-mm)/12)
 LET y=yyyy-a
 LET m=mm+(12*a)-2
 LET d=dd+y+FLOOR(y/4)-FLOOR(y/100)+FLOOR(y/400)+FLOOR((31*m)/12)
 LET i=MOD(d,7)+1
 LET pDayName$=DOW$[i]
 FN.RTN i
FN.END
!
!  D A Y S _ I N _ M O N T H
!
FN.DEF daysinmonth(pdate$)
 ARRAY.LOAD dyinmth[],31,28,31,30,31,30,31,31,30,31,30,31
 LET yyyy=VAL(MID$(pdate$,1,4))
 LET mm=VAL(MID$(pdate$,6,2))
 LET md=dyinmth[mm]
 IF mm=2 THEN
  LET ly=((MOD(yyyy,4)=0) & (MOD(yyyy,100)>0)) | (MOD(yyyy,400)=0)
  IF ly=1 THEN LET md=29
 ENDIF
 FN.RTN md
FN.END

!#@#@#@#_msgbox_control

!
!  @ D R A W _ M S G B O X
!
FN.DEF @drawmsgbox()
 LET bcOPAQUE=255
 LET bcSEMIOPAQUE=128
 LET bcTRANSPARENT=0
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcBLACK=1
 LET bcYESNO$="y"
 LET bcYESNOCANCEL$="n"
 LET bcINFORMATION$="i"
 LET bcQUESTION$="q"
 LET bcEXCLAMATION$="e"
 LET bcCRITICAL$="c"
 GOSUB @LoadRGBData
 BUNDLE.GET 1,"msgboxfont",msgboxfont
 BUNDLE.GET 1,"swidth",swidth
 BUNDLE.GET 1,"sheight",sheight
 BUNDLE.GET 1,"msghedclr",msghedclr
 BUNDLE.GET 1,"msgbdyclr",msgbdyclr
 BUNDLE.GET 1,"msgbtnbdrclr",msgbtnbdrclr
 BUNDLE.GET 1,"msgbtnbdyclr",msgbtnbdyclr
 BUNDLE.GET 1,"msghedtxtclr",msghedtxtclr
 BUNDLE.GET 1,"msgbdytxtclr",msgbdytxtclr
 BUNDLE.GET 1,"msgbtntxtclr",msgbtntxtclr
 LET u=msgboxfont*2
 LET v=(u*0.6)
 LET s=u/3
 LET h=(2*u)+v+(3*s)
 LET x=(swidth-11*u)/2
 LET y=(sheight-h)/2
 LET b=y+h
 LET bt=b-s-u
 LET bb=bt+u
 LET msgmid=x+(11*u)/2
 DIM grobj[33]
 GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcFILL
 GR.RECT grobj[1],0,0,swidth,sheight
 GR.COLOR bcTRANSPARENT,BCMP[msghedclr],GCMP[msghedclr],RCMP[msghedclr],bcFILL
 GR.RECT grobj[2],x,y,x+(11*u),y+u
 GR.COLOR bcTRANSPARENT,BCMP[msgbdyclr],GCMP[msgbdyclr],RCMP[msgbdyclr],bcFILL
 GR.RECT grobj[3],x,y+u,x+(11*u),b
 GR.COLOR bcTRANSPARENT,BCMP[msgbtnbdrclr],GCMP[msgbtnbdrclr],RCMP[msgbtnbdrclr],bcFILL
 GR.RECT grobj[18],x+s,bt,x+s+(3*u),bb
 GR.RECT grobj[23],x+(4*u),bt,x+(7*u),bb
 GR.RECT grobj[28],x+(7*u)+2*s,bt,x+(10*u)+2*s,bb
 GR.COLOR bcTRANSPARENT,BCMP[msgbtnbdyclr],GCMP[msgbtnbdyclr],RCMP[msgbtnbdyclr],bcFILL
 GR.RECT grobj[19],x+s+3,bt+3,x+s+(3*u)-3,bb-3
 GR.RECT grobj[24],x+(4*u)+3,bt+3,x+(7*u)-3,bb-3
 GR.RECT grobj[29],x+(7*u)+2*s+3,bt+3,x+(10*u)+2*s-3,bb-3
 LET obj1=0
 LET obj2=0
 CALL @drawborder("99",bcTRANSPARENT,x,y,x+(11*u),b,&obj1,&obj2)
 LET grobj[4]=obj1
 LET grobj[5]=obj2
 GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
 GR.LINE grobj[6],x,y+u,x+(11*u),y+u
 GR.RECT grobj[20],x+s,bt,x+s+(3*u),bb
 GR.RECT grobj[25],x+(4*u),bt,x+(7*u),bb
 GR.RECT grobj[30],x+(7*u)+2*s,bt,x+(10*u)+2*s,bb
 GR.RECT grobj[21],x+s+3,bt+3,x+s+(3*u)-3,bb-3
 GR.RECT grobj[26],x+(4*u)+3,bt+3,x+(7*u)-3,bb-3
 GR.RECT grobj[31],x+(7*u)+2*s+3,bt+3,x+(10*u)+2*s-3,bb-3
 GR.TEXT.ALIGN 2
 GR.COLOR bcTRANSPARENT,BCMP[msghedtxtclr],GCMP[msghedtxtclr],RCMP[msghedtxtclr],bcFILL
 LET fs=msgboxfont
 LET fo=@getfontyoffset(u,fs)
 GR.TEXT.SIZE fs
 GR.TEXT.DRAW grobj[7],msgmid,y+fo,""
 GR.TEXT.ALIGN 1
 LET fot=@getfontyoffset(v,fs)
 GR.COLOR bcTRANSPARENT,BCMP[msgbdytxtclr],GCMP[msgbdytxtclr],RCMP[msgbdytxtclr],bcFILL
 FOR i=8 TO 17
  GR.TEXT.DRAW grobj[i],msgmid,y+u+s+((i-7)*v)+fot,""
 NEXT i
 GR.TEXT.ALIGN 2
 GR.COLOR bcTRANSPARENT,BCMP[msgbtntxtclr],GCMP[msgbtntxtclr],RCMP[msgbtntxtclr],bcFILL
 GR.TEXT.DRAW grobj[22],x+s+((3*u)/2),bt+fo,"Yes"
 GR.TEXT.DRAW grobj[27],x+(4*u)+((3*u)/2),bt+fo,"No"
 GR.TEXT.DRAW grobj[32],x+(7*u)+2*s+((3*u)/2),bt+fo,"Cancel"
 LET ps=2*(u*0.9)
 GR.BITMAP.LOAD pbmobj,"GC-Information.png"
 GR.BITMAP.SCALE msgiconscaled,pbmobj,ps+100,ps+100
 CALL @AddToBmpList("Msg",1,msgiconscaled)
 GR.BITMAP.DELETE pbmobj
 GR.BITMAP.DRAW gonum,msgiconscaled,x,y+u+s
 GR.MODIFY gonum,"alpha",bcTRANSPARENT
 LET grobj[33]=gonum
 BUNDLE.PUT 1,"FrmObjCnt",gonum
 LIST.CREATE n,msgobjs
 LIST.ADD.ARRAY msgobjs,grobj[]
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.PUT ctrldata,"msgobjlist",msgobjs
 BUNDLE.PUT 1,"msgboxdrawn",1
 FN.RTN 0
FN.END
!
!  M S G B O X $
!
FN.DEF msgbox$(pmsg$,pbuttons$,ptitle$)
 LET bcOPAQUE=255
 LET bcSEMIOPAQUE=128
 LET bcTRANSPARENT=0
 LET bcNOFILL=0
 LET bcFILL=1
 LET bcYESNO$="y"
 LET bcYESNOCANCEL$="n"
 LET bcCUSTOM$="m"
 LET bcINFORMATION$="i"
 LET bcQUESTION$="q"
 LET bcEXCLAMATION$="e"
 LET bcCRITICAL$="c"
 LET bcCLRINFO$="I"
 LET bcCLRQUEST$="Q"
 LET bcCLRERR$="E"
 LET bcCLRCRIT$="C"
 LET bcALIGNCENTRE$="C"
 LET bcNOBORDER$="-"
 LET bcRECBREAK$=CHR$(174)
 GOSUB @LoadRGBData
 BUNDLE.GET 1,"msgboxdrawn",rc
 IF rc=0 THEN CALL @drawmsgbox()
 IF IS_IN(bcCLRINFO$,pbuttons$)<>0 THEN
  setMBTypeClrs("I")
 ELSEIF IS_IN(bcCLRQUEST$,pbuttons$)<>0 THEN
  setMBTypeClrs("Q")
 ELSEIF IS_IN(bcCLRERR$,pbuttons$)<>0 THEN
  setMBTypeClrs("E")
 ELSEIF IS_IN(bcCLRCRIT$,pbuttons$)<>0 THEN
  setMBTypeClrs("C")
 ENDIF
 BUNDLE.GET 1,"msgboxfont",msgboxfont
 BUNDLE.GET 1,"swidth",swidth
 BUNDLE.GET 1,"sheight",sheight
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"msgobjlist",grobjlist
 LIST.TOARRAYgrobjlist,grobj[]
 BUNDLE.GET 1,"FrmObjCnt",FrmObjCnt
 BUNDLE.GET 1,"msghedclr",msghedclr
 BUNDLE.GET 1,"msgbdyclr",msgbdyclr
 BUNDLE.GET 1,"msgbtnbdrclr",msgbtnbdrclr
 BUNDLE.GET 1,"msgbtnbdyclr",msgbtnbdyclr
 BUNDLE.GET 1,"msghedtxtclr",msghedtxtclr
 BUNDLE.GET 1,"msgbdytxtclr",msgbdytxtclr
 BUNDLE.GET 1,"msgbtntxtclr",msgbtntxtclr
 GR.TEXT.SIZE msgboxfont
 GR.MODIFY grobj[1],"alpha",bcSEMIOPAQUE
 CALL @setstyle(99,bcALIGNCENTRE$,"c")
 GR.COLOR bcTRANSPARENT,BCMP[msghedclr],GCMP[msghedclr],RCMP[msghedclr],bcFILL
 GR.PAINT.GET pptr
 GR.MODIFY grobj[2],"paint",pptr
 GR.COLOR bcTRANSPARENT,BCMP[msgbdyclr],GCMP[msgbdyclr],RCMP[msgbdyclr],bcFILL
 GR.PAINT.GET pptr
 GR.MODIFY grobj[3],"paint",pptr
 GR.COLOR bcTRANSPARENT,BCMP[msgbtnbdrclr],GCMP[msgbtnbdrclr],RCMP[msgbtnbdrclr],bcFILL
 GR.PAINT.GET pptr
 GR.MODIFY grobj[18],"paint",pptr
 GR.MODIFY grobj[23],"paint",pptr
 GR.MODIFY grobj[28],"paint",pptr
 GR.COLOR bcTRANSPARENT,BCMP[msgbtnbdyclr],GCMP[msgbtnbdyclr],RCMP[msgbtnbdyclr],bcFILL
 GR.PAINT.GET pptr
 GR.MODIFY grobj[19],"paint",pptr
 GR.MODIFY grobj[24],"paint",pptr
 GR.MODIFY grobj[29],"paint",pptr
 GR.COLOR bcTRANSPARENT,BCMP[msghedtxtclr],GCMP[msghedtxtclr],RCMP[msghedtxtclr],bcFILL
 GR.PAINT.GET pptr
 GR.MODIFY grobj[7],"paint",pptr
 GR.TEXT.ALIGN 1
 GR.COLOR bcTRANSPARENT,BCMP[msgbdytxtclr],GCMP[msgbdytxtclr],RCMP[msgbdytxtclr],bcFILL
 GR.PAINT.GET pptr
 FOR i=8 TO 17
  GR.MODIFY grobj[i],"paint",pptr
 NEXT i
 GR.TEXT.ALIGN 2
 GR.COLOR bcTRANSPARENT,BCMP[msgbtntxtclr],GCMP[msgbtntxtclr],RCMP[msgbtntxtclr],bcFILL
 GR.PAINT.GET pptr
 GR.MODIFY grobj[22],"paint",pptr
 GR.MODIFY grobj[27],"paint",pptr
 GR.MODIFY grobj[32],"paint",pptr
 CALL @BringToFront(grobj[1],grobj[33],0)
 FOR i=2 TO 8
  GR.MODIFY grobj[i],"alpha",bcOPAQUE
 NEXT i
 GR.TEXT.SIZE msgboxfont
 LET i$=pmsg$
 LET j$=""
 WHILE i$<>""
  LET j=1
  LET p=IS_IN(bcRECBREAK$,i$)
  IF p=0 THEN
   GR.TEXT.WIDTH nw,i$
   IF nw>500 THEN
    LET p=LEN(i$)
    DO
     LET p=p-1
     GR.TEXT.WIDTH nw,LEFT$(i$,p)
    UNTIL nw<500
    LET i=p
    WHILE MID$(i$,p,1)<>" "
     LET p=p-1
     IF p=1 THEN
      LET p=i
      LET j=0
      W_R.BREAK$
     ENDIF
    REPEAT
   ELSE
    LET p=LEN(i$)+1
    LET j=0
   ENDIF
  ENDIF
  IF j$<>"" THEN LET j$=j$+bcRECBREAK$
  LET j$=j$+LEFT$(i$,p-1)
  LET i$=MID$(i$,p+j)
 REPEAT
 SPLIT.ALL mln$[],j$,bcRECBREAK$
 ARRAY.LENGTH tlines,mln$[]
 IF tlines>10 THEN
  LET tlines=10
  LET mln$[10]=mln$[10]+" ..."
 ENDIF
 DIM xln$[10]
 IF IS_IN(bcINFORMATION$,pbuttons$)<>0 THEN
  LET sicon$="GC-Information.png"
 ELSEIF IS_IN(bcQUESTION$,pbuttons$)<>0 THEN
  LET sicon$="GC-Question.png"
 ELSEIF IS_IN(bcEXCLAMATION$,pbuttons$)<>0 THEN
  LET sicon$="GC-Exclamation.png"
 ELSEIF IS_IN(bcCRITICAL$,pbuttons$)<>0 THEN
  LET sicon$="GC-Critical.png"
 ELSE
  LET sicon$=""
 ENDIF
 LET buttonl$=""
 LET buttonc$="Ok"
 LET buttonr$=""
 LET butcnt=1
 LET atitle$=ptitle$
 IF IS_IN(bcCUSTOM$,pbuttons$)<>0 THEN
  LET i=IS_IN(bcRECBREAK$,ptitle$)
  IF i<>0 THEN
   SPLIT.ALL buttxt$[],ptitle$,bcRECBREAK$
   ARRAY.LENGTH msglines,buttxt$[]
   LET atitle$=buttxt$[1]
   LET butcnt=msglines-1
   IF butcnt=1 THEN
    LET buttonc$=buttxt$[2]
   ELSEIF butcnt=2 THEN
    LET buttonl$=buttxt$[2]
    LET buttonc$=""
    LET buttonr$=buttxt$[3]
   ELSE
    LET buttonl$=buttxt$[2]
    LET buttonc$=buttxt$[3]
    LET buttonr$=buttxt$[4]
   ENDIF
  ENDIF
 ELSEIF IS_IN(bcYESNOCANCEL$,pbuttons$)<>0 THEN
  LET buttonl$="Yes"
  LET buttonc$="No"
  LET buttonr$="Cancel"
  LET butcnt=3
 ELSEIF IS_IN(bcYESNO$,pbuttons$)<>0 THEN
  LET buttonl$="Yes"
  LET buttonc$=""
  LET buttonr$="No"
  LET butcnt=2
 ENDIF
 LET u=msgboxfont*2
 LET s=u/3
 IF sicon$<>"" THEN
  LET ps=2*(u*0.9)+1
  LET dx=ps+s
 ELSE
  LET dx=0
 ENDIF
 LET j=1
 LET k=tlines
 IF dx<>0 THEN
  IF tlines=1 THEN
   LET j=2
   LET k=3
  ELSEIF tlines=2 THEN
   LET k=3
  ENDIF
 ENDIF
 FOR i=1 TO tlines
  LET xln$[j]=mln$[i]
  LET j=j+1
 NEXT i
 LET tlines=k
 LET fs=msgboxfont
 GR.TEXT.SIZE fs
 LET v=u*0.6
 LET h=(2*u)+(tlines*v)+4*s
 LET y=(sheight-h)/2
 LET b=y+h
 LET bt=b-s-u
 LET bb=bt+u
 LET fot=@getfontyoffset(v,fs)
 LET mw=0
 FOR i=1 TO tlines
  GR.TEXT.WIDTH nw,xln$[i]
  IF mw<nw THEN LET mw=nw
 NEXT i
 LET fo=@getfontyoffset(u,fs)
 GR.TEXT.WIDTH tw,atitle$
 IF tw>mw THEN LET mw=tw
 IF mw+dx>11*u THEN LET mw=(mw+dx+u)/2 ELSE LET mw=(12*u)/2
 LET bx=(swidth-11*u)/2
 LET x=(swidth-mw)/2
 LET smid=swidth/2
 IF sicon$<>"" THEN
  LET msgobj=grobj[33]
  GR.BITMAP.LOAD bmpobj,sicon$
  GR.BITMAP.SCALE sizobj,bmpobj,ps,ps
  CALL @AddToBmpList("Msg",1,sizobj)
  GR.BITMAP.DELETE bmpobj
  GR.MODIFY msgobj,"bitmap",sizobj,"alpha",bcOPAQUE,"x",smid-mw+s,"y",y+u+s+(s/2)
 ENDIF
 FOR i=2 TO 5
  GR.MODIFY grobj[i],"left",smid-mw,"top",y,"right",smid+mw,"bottom",b
  IF i=2 THEN
   GR.MODIFY grobj[i],"bottom",y+u
  ELSEIF i=3 THEN
   GR.MODIFY grobj[i],"top",y+u
  ELSEIF i=4 THEN
   GR.MODIFY grobj[i],"left",smid-mw-2,"top",y-2,"right",smid+mw+2,"bottom",b+2
  ELSEIF i=5 THEN
   GR.MODIFY grobj[i],"left",smid-mw-3,"top",y-3,"right",smid+mw+1,"bottom",b+1
  ENDIF
 NEXT i
 GR.MODIFY grobj[6],"x1",smid-mw,"x2",smid+mw,"y1",y+u,"y2",y+u
 IF IS_IN(bcNOBORDER$,pbuttons$)<>0 THEN
  GR.MODIFY grobj[4],"alpha",bcTRANSPARENT
  GR.MODIFY grobj[5],"alpha",bcTRANSPARENT
  GR.MODIFY grobj[6],"alpha",bcTRANSPARENT
 ENDIF
 GR.MODIFY grobj[7],"y",y+fo,"text",atitle$
 FOR i=8 TO 17
  IF i-7<=tlines THEN
   GR.MODIFY grobj[i],"x",smid-mw+(u/2)+dx,"y",y+u+s*2+((i-8)*v)+fot,"text",xln$[i-7],"alpha",bcOPAQUE
  ENDIF
 NEXT i
 FOR i=18 TO 32
  IF i=22 | i=27 | i=32 THEN
   GR.MODIFY grobj[i],"y",bt+fo
  ELSEIF i=21 | i=26 | i=31 | i=19 | i=24 | i=29 THEN
   GR.MODIFY grobj[i],"top",bt+3,"bottom",bb-3
  ELSE
   GR.MODIFY grobj[i],"top",bt,"bottom",bb
  ENDIF
  GR.MODIFY grobj[i],"alpha",bcTRANSPARENT
 NEXT i
 GR.MODIFY grobj[22],"text",buttonl$
 GR.MODIFY grobj[27],"text",buttonc$
 GR.MODIFY grobj[32],"text",buttonr$
 IF butcnt=1 THEN
  FOR i=23 TO 27
   GR.MODIFY grobj[i],"alpha",bcOPAQUE
  NEXT i
 ELSEIF butcnt=2 THEN
  FOR i=18 TO 22
   GR.MODIFY grobj[i],"alpha",bcOPAQUE
  NEXT i
  FOR i=28 TO 32
   GR.MODIFY grobj[i],"alpha",bcOPAQUE
  NEXT i
 ELSE
  FOR i=18 TO 32
   GR.MODIFY grobj[i],"alpha",bcOPAQUE
  NEXT i
 ENDIF
 GR.RENDER
 LET bobj=0
 LET bpressed=0
 DO
  GR.TOUCH tch,dx,dy
  IF tch=1 THEN
   GR.BOUNDED.TOUCH tch,bx+s,bt,bx+s+(3*u),bb
   IF tch=1 THEN
    IF buttonl$<>"" THEN
     LET pbutton$=buttonl$
     LET bobj=22
    ENDIF
   ELSE
    GR.BOUNDED.TOUCH tch,bx+(4*u),bt,bx+(7*u),bb
    IF tch=1 THEN
     IF buttonc$<>"" THEN
      LET pbutton$=buttonc$
      LET bobj=27
     ENDIF
    ELSE
     GR.BOUNDED.TOUCH tch,bx+(7*u)+s,bt,bx+(10*u)+s,bb
     IF tch=1 THEN
      IF buttonr$<>"" THEN
       LET pbutton$=buttonr$
       LET bobj=32
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF bobj<>0 THEN
    GR.MODIFY grobj[bobj-3],"alpha",bcSEMIOPAQUE
    GR.MODIFY grobj[bobj],"text","Selected"
    GR.RENDER
    DO
     GR.TOUCH tuch,ux,uy
    UNTIL tuch=0
    GR.MODIFY grobj[bobj-3],"alpha",bcOPAQUE
    GR.MODIFY grobj[bobj],"text",pbutton$
    GR.RENDER
    LET bpressed=1
   ENDIF
  ENDIF
 UNTIL bpressed=1
 CALL @soundrtn()
 FOR i=1 TO 33
  GR.MODIFY grobj[i],"alpha",bcTRANSPARENT
 NEXT i
 GR.RENDER
 FN.RTN pbutton$
FN.END

!#@#@#@#_hourglass_routines

!
!  @ D R A W _ H O U R G L A S S
!
FN.DEF @drawhourglass()
 LET bcTRANSPARENT=0
 BUNDLE.GET 1,"DateSize",datesize
 BUNDLE.GET 1,"swidth",swidth
 BUNDLE.GET 1,"sheight",sheight
 LET x=swidth/2
 LET y=sheight/2
 LET ps=datesize
 GR.BITMAP.LOAD loadicon,"GC-Hourglass2.png"
 GR.BITMAP.SCALE hgscaledptr,loadicon,2*ps,2*ps
 CALL @AddToBmpList("Hg",1,hgscaledptr)
 GR.BITMAP.DRAW gonum,hgscaledptr,x-ps,y-ps
 GR.MODIFY gonum,"alpha",bcTRANSPARENT
 BUNDLE.PUT 1,"hgdrawnptr",gonum
 BUNDLE.PUT 1,"FrmObjCnt",gonum
 BUNDLE.PUT 1,"hourglassdrawn",1
 GR.BITMAP.DELETE loadicon
 GR.RENDER
 FN.RTN 0
FN.END
!
!  H O U R G L A S S _ S H O W
!
FN.DEF hourglass_show(pstyle,pdisable)
 LET bcOPAQUE=255
 BUNDLE.GET 1,"hourglassdrawn",rc
 IF rc=0 THEN CALL @drawhourglass()
 BUNDLE.GET 1,"DateSize",datesize
 BUNDLE.GET 1,"swidth",swidth
 BUNDLE.GET 1,"sheight",sheight
 BUNDLE.GET 1,"hgdrawnptr",hgdrawnptr
 CALL @BringToFront(hgdrawnptr,hgdrawnptr,0)
 LET x=swidth/2
 LET y=sheight/2
 LET ps=datesize
 IF pstyle=1 THEN
  LET sfn$="GC-Hourglass1.png"
 ELSEIF pstyle=3 THEN
  LET sfn$="GC-Hourglass3.png"
 ELSE
  LET sfn$="GC-Hourglass2.png"
 ENDIF
 GR.BITMAP.LOAD loadicon,sfn$
 GR.BITMAP.SCALE hgscaledptr,loadicon,ps,ps
 CALL @AddToBmpList("Hg",1,hgscaledptr)
 GR.MODIFY hgdrawnptr,"bitmap",hgscaledptr
 GR.BITMAP.DELETE loadicon
 GR.MODIFY hgdrawnptr,"alpha",bcOPAQUE
 IF pdisable=1 THEN
  BUNDLE.GET 1,"ctrlcount",ctrlcount
  BUNDLE.GET 1,"ctrldata",ctrldata
  FOR i=1 TO ctrlcount
   BUNDLE.GET ctrldata,"CP"+STR$(i),ptrctrl
   BUNDLE.GET ptrctrl,"state",ctrlstate$
   IF ctrlstate$="" THEN
    BUNDLE.PUT ptrctrl,"state","G"
    CALL disablectrl(i,0)
   ENDIF
  NEXT i
 ENDIF
 GR.RENDER
 FN.RTN 0
FN.END
!
!  H O U R G L A S S _ H I D E
!
FN.DEF hourglass_hide(penable)
 LET bcTRANSPARENT=0
 BUNDLE.GET 1,"hourglassdrawn",rc
 IF rc=1 THEN
  IF penable=1 THEN
   BUNDLE.GET 1,"ctrlcount",ctrlcount
   BUNDLE.GET 1,"ctrldata",ctrldata
   FOR i=1 TO ctrlcount
    BUNDLE.GET ctrldata,"CP"+STR$(i),ptrctrl
    BUNDLE.GET ptrctrl,"state",ctrlstate$
    IF IS_IN("G",ctrlstate$)<>0 THEN
     BUNDLE.PUT ptrctrl,"state","D"
     CALL enablectrl(i,0)
    ENDIF
   NEXT i
  ENDIF
  BUNDLE.GET 1,"hgdrawnptr",hgdrawnptr
  GR.MODIFY hgdrawnptr,"alpha",bcTRANSPARENT
  GR.RENDER
 ENDIF
 FN.RTN 0
FN.END

!#@#@#@#_string_ & _text_controls

!
!  C L I C K _ S T R I N G
!
FN.DEF @clickstring(pctrlsizecap$,pctrldata$,pctrldattextobj)
 LET bcLF$=CHR$(10)
 LET bcSTRCRLF$="^^"
 LET bcCOLBREAK$=CHR$(169)
 LET retc=0
 LET inpheader$=pctrlsizecap$
 LET inptext$=REPLACE$(pctrldata$,bcSTRCRLF$,bcLF$)
 GOSUB KeyRoutine
 IF inptext$<>bcCOLBREAK$ THEN
  LET pctrldata$=REPLACE$(inptext$,bcLF$,bcSTRCRLF$)
  GR.MODIFY pctrldattextobj,"text",pctrldata$
  LET retc=1
 ENDIF
 GR.RENDER
 FN.RTN retc
FN.END
!
!  @ C L I C K _ T E X T
!
FN.DEF @clicktext(pdx,pctrlsizecap$,pctrldata$,pctrldattextobj,pctrlleft,pctrlwidth, ~
       pctrlheight,pctrlstyle$)
 LET bcNOTITLEEDIT$="t"
 LET bcCOLBREAK$=CHR$(169)
 LET bcFLDBREAK$=CHR$(183)
 LET bcCRLF$=CHR$(13)+CHR$(10)
 LET bcLF$=CHR$(10)
 LET bcSTRCRLF$="^^"
 LET retc=0
 LET scurtext$=pctrldata$
 TEXT.INPUT snewtext$,REPLACE$(scurtext$,bcSTRCRLF$,bcLF$)
 LET snewtext$=REPLACE$(snewtext$,bcLF$,bcSTRCRLF$)
 LET pctrldata$=snewtext$
 LET retc=1
 FN.RTN retc
FN.END

!#@#@#@#_select,_spin,_time_controls

!
!  @ D R A W _ S E L E C T _ S P I N _ T I M E
!
FN.DEF @drawselectspintime(ptrctrl,ctrltype,ctrltop,cmiddle,cright,cbottom,ctrlfont,ctrlstyle$)
 LET bcOPAQUE=255
 LET bcFILL=1
 LET bcBLUE=2
 LET bcLBLUE=10
 LET bcLGREEN=11
 LET bcWHITE=16
 LET bcFRMSELECT=4
 LET bcSPINLR$="A"
 LET bcSPINDN$="Y"
 LET bcALLOWNEW$="N"
 GOSUB @LoadRGBData
 LET lsize=cbottom-ctrltop
 LET bcol=bcWHITE
 IF ctrltype=bcFRMSELECT THEN
  LET cap1$="<"
  LET cap2$=">"
  IF IS_IN(bcALLOWNEW$,ctrlstyle$)>0 THEN
   LET bcol=bcLGREEN
  ENDIF
 ELSE
  IF IS_IN(bcSPINLR$,ctrlstyle$)>0 THEN
   LET cap1$="<<"
   LET cap2$=">>"
   LET cap3$="<"
   LET cap4$=">"
  ELSEIF IS_IN(bcSPINDN$,ctrlstyle$)>0 THEN
   LET cap1$="vv"
   LET cap2$="vv"
   LET cap3$="v"
   LET cap4$="v"
  ELSE
   LET cap1$="vv"
   LET cap2$="^^"
   LET cap3$="v"
   LET cap4$="^"
  ENDIF
  gonum=@drawbutton("Spn1"+INT$(ptrctrl),bcLBLUE,bcWHITE,cmiddle+lsize,ctrltop,lsize, ~
        lsize,ctrlfont/4,ctrlstyle$,0,cap3$,bcOPAQUE,textptr,backptr)
  gonum=@drawbutton("Spn2"+INT$(ptrctrl),bcLBLUE,bcWHITE,cright-2*lsize,ctrltop, ~
        lsize,lsize,ctrlfont/4,ctrlstyle$,0,cap4$,bcOPAQUE,textptr,backptr)
 ENDIF
 gonum=@drawbutton("Spn3"+INT$(ptrctrl),bcLBLUE,bcol,cmiddle,ctrltop,lsize,lsize,ctrlfont/4, ~
       ctrlstyle$,0,cap1$,bcOPAQUE,textptr,backptr)
 gonum=@drawbutton("Spn4"+INT$(ptrctrl),bcLBLUE,bcol,cright-lsize,ctrltop,lsize,lsize,ctrlfont/4, ~
       ctrlstyle$,0,cap2$,bcOPAQUE,textptr,backptr)
 FN.RTN gonum
FN.END
!
!  @ C L I C K _ S E L E C T
!
FN.DEF @clickselect(px,pctrlsizecap$,datalst,pctrldata$,pctrldattxtobj,pctrlleft,pctrlheight, ~
       pctrlmiddle,pctrlwidth,pctrlstyle$)
 LET bcALLOWNEW$="N"
 LET bcNOSORT$="n"
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LIST.SEARCH datalst,pctrldata$,lindex
 IF lindex=0 THEN
  LET lindex=1
  LIST.GET datalst,lindex,i$
  POPUP "Warning: Value '"+pctrldata$+"' not found in list. Value changed to '"+i$+"'.",0,0,1
  LET pctrldata$=listval$[lindex]
 ENDIF
 IF px<=pctrlleft+pctrlmiddle+pctrlheight THEN
  IF lindex>1 THEN
   LIST.GET datalst,lindex-1,pctrldata$
   GR.MODIFY pctrldattxtobj,"text",pctrldata$
   GR.RENDER
   LET rc=1
  ENDIF
 ELSEIF px>=pctrlleft+pctrlwidth-pctrlheight THEN
  LIST.SIZE datalst,datalstcnt
  IF lindex<datalstcnt THEN
   LIST.GET datalst,lindex+1,pctrldata$
   GR.MODIFY pctrldattxtobj,"text",pctrldata$
   GR.RENDER
   LET rc=1
  ENDIF
 ELSE
  IF IS_IN(bcALLOWNEW$,pctrlstyle$)>0 THEN
   LET inpheader$=pctrlsizecap$
   LET inptext$=""
   GOSUB KeyRoutine
   IF inptext$<>"" & inptext$<>bcCOLBREAK$ THEN
    LIST.SEARCH datalst,inptext$,i
    IF i=0 THEN
     POPUP "Error: Value '"+inptext$+"' already exists.",0,0,1
    ELSE
     LIST.ADD datalst,inptext$
     IF IS_IN(bcNOSORT$,pctrlstyle$)=0 THEN
      LIST.TOARRAY datalst,f$[]
      LIST.CLEAR
      ARRAY.SORT f$[]
      LIST.ADD.ARRAY datalst,f$[]
     ENDIF
     LET pctrldata$=inptext$
     GR.MODIFY pctrldattxtobj,"text",pctrldata$
     GR.RENDER
     LET rc=2
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 FN.RTN rc
FN.END
!
!  @ C L I C K _ S P I N _ B U T T O N
!
FN.DEF @clickspinbutton(px,datalst,pctrldata$,pctrldattxtobj,pctrlleft,pctrlmiddle,pctrlheight, ~
   pctrlwidth,pctrlstyle$)
 LET bcSPINREV$="y"
 LET bcRECBREAK$=CHR$(174)
 IF pctrldata$<>"" THEN
  LET curval=VAL(pctrldata$)
 ELSE
  LIST.GET datalst,3,i$
  LET curval=VAL(i$)
 ENDIF
 LIST.GET datalst,1,i$
 LET si=VAL(i$)
 LIST.GET datalst,2,i$
 LET li=VAL(i$)
 LIST.GET datalst,3,i$
 LET mn=VAL(i$)
 LIST.GET datalst,4,i$
 LET mx=VAL(i$)
 IF px<=pctrlleft+pctrlmiddle+pctrlheight THEN
  LET i=-li
 ELSEIF px<=pctrlleft+pctrlmiddle+(2*pctrlheight) THEN
  LET i=-si
 ELSEIF px>=pctrlleft+pctrlwidth-pctrlheight THEN
  LET i=li
 ELSEIF px>=pctrlleft+pctrlwidth-(2*pctrlheight) THEN
  LET i=si
 ELSE
  LET i=0
 ENDIF
 IF IS_IN(bcSPINREV$,pctrlstyle$)=0 THEN LET curval=curval+i ELSE LET curval=curval-i
 IF curval<mn THEN
  LET curval=mn
 ELSEIF curval>mx THEN
  LET curval=mx
 ENDIF
 LET stemp$=STR$(curval)
 LET i=IS_IN(".",stemp$)
 LET pctrldata$=LEFT$(stemp$,i-1)
 GR.MODIFY pctrldattxtobj,"text",pctrldata$
 GR.RENDER
 FN.RTN 1
FN.END
!
!  @ D R A W _ T I M E _ V A L U E
!
FN.DEF @drawtimevalue(ptrctrl,pctrldattxtclr,pctrltop,pctrlheight,pctrlfont,pctrldata$,pctrlstyle$, ~
       pmiddle,pbottom,pfo)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcFILL=1
 LET bcLYELLOW=15
 LET bcHHMMONLY$="h"
 GOSUB @LoadRGBData
 IF IS_IN(bcHHMMONLY$,pctrlstyle$)<>0 THEN LET bcnt=1 ELSE LET bcnt=2
 LET x=pmiddle+(2*pctrlheight)
 LET xo=(pctrlheight-pctrlfont)/2
 GR.COLOR bcOPAQUE,BCMP[bcLYELLOW],GCMP[bcLYELLOW],RCMP[bcLYELLOW],bcFILL
 LET j=x
 FOR i=0 TO bcnt
  GR.RECT gonum,j+3,pctrltop+3,j+pctrlheight-3,pbottom-3
  IF i=0 THEN
   BUNDLE.PUT ptrctrl,"timbakobj",gonum
   GR.COLOR bcTRANSPARENT,BCMP[bcLYELLOW],GCMP[bcLYELLOW],RCMP[bcLYELLOW],bcFILL
  ENDIF
  LET j=j+pctrlheight
 NEXT i
 GR.COLOR bcOPAQUE,BCMP[pctrldattxtclr],GCMP[pctrldattxtclr],RCMP[pctrldattxtclr],bcFILL
 GR.TEXT.DRAW gonum,x+pctrlheight,pctrltop+pfo,":"
 IF bcnt=2 THEN GR.TEXT.DRAW gonum,x+(2*pctrlheight),pctrltop+pfo,":"
 FOR i=0 TO bcnt
  LET v$=MID$(pctrldata$,1+(i*3),2)
  GR.TEXT.DRAW gonum,x+xo,pctrltop+pfo,v$
  IF i=0 THEN BUNDLE.PUT ptrctrl,"timdatobj",gonum
  LET x=x+pctrlheight
 NEXT i
 BUNDLE.PUT ptrctrl,"timselobj",0
 FN.RTN gonum
FN.END
!
!  @ C L I C K _ T I M E _ B U T T O N
!
FN.DEF @clicktimebutton(px,pctrldata$,ptrctrl)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcHHMMONLY$="h"
 BUNDLE.GET ptrctrl,"style",sstyle$
 BUNDLE.GET ptrctrl,"left",lleft
 BUNDLE.GET ptrctrl,"middle",lmiddle
 BUNDLE.GET ptrctrl,"height",lheight
 BUNDLE.GET ptrctrl,"timbakobj",timbakobj
 BUNDLE.GET ptrctrl,"timdatobj",timdatobj
 BUNDLE.GET ptrctrl,"timselobj",timselobj
 IF IS_IN(bcHHMMONLY$,sstyle$)<>0 THEN LET bcnt=1 ELSE LET bcnt=2
 SPLIT.ALL timval$[],pctrldata$,":"
 LET selval=VAL(timval$[timselobj+1])
 LET bp=FLOOR((px-(lleft+lmiddle))/lheight)
 LET rc=0
 IF (bp>1 & bp<bcnt+3) | bp<0 THEN
  IF bp>1 THEN LET timselobj=bp-2
  FOR i=0 TO bcnt
   IF i=timselobj THEN
    GR.MODIFY timbakobj+i,"alpha",bcOPAQUE
   ELSE
    GR.MODIFY timbakobj+i,"alpha",bcTRANSPARENT
   ENDIF
  NEXT i
  BUNDLE.PUT ptrctrl,"timselobj",timselobj
  IF bp<0 THEN
   GR.MODIFY timdatobj,"text",LEFT$(pctrldata$,2)
   GR.MODIFY timdatobj+1,"text",MID$(pctrldata$,4,2)
   IF bcnt=2 THEN
    GR.MODIFY timdatobj+2,"text",MID$(pctrldata$,7,2)
   ENDIF
  ENDIF
 ELSE
  IF timselobj=0 THEN
   LET inc=8
   LET max=23
  ELSE
   LET inc=10
   LET max=59
  ENDIF
  IF bp=0 THEN
   LET nv=selval-inc
  ELSEIF bp=1 THEN
   LET nv=selval-1
  ELSEIF bp=bcnt+3 THEN
   LET nv=selval+1
  ELSE
   LET nv=selval+inc
  ENDIF
  IF nv<0 THEN
   LET nv=0
  ELSEIF nv>max THEN
   LET nv=max
  ENDIF
  IF nv<>selval THEN
   LET nv$=NumToStr$(nv,0,0,2)
   GR.MODIFY timdatobj+timselobj,"text",nv$
   IF timselobj=0 THEN
    LET pctrldata$=nv$+MID$(pctrldata$,3)
   ELSEIF timselobj=1 THEN
    LET pctrldata$=LEFT$(pctrldata$,3)+nv$+MID$(pctrldata$,6)
   ELSE
    LET pctrldata$=LEFT$(pctrldata$,6)+nv$
   ENDIF
   LET rc=1
  ENDIF
 ENDIF
 GR.RENDER
 FN.RTN rc
FN.END

!#@#@#@#_combobox_control

!
!  @ D R A W _ C O M B O B O X _ L I S T
!
FN.DEF @drawcomboboxlist(ctrlID,ptrctrl,swidth,sheight)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcBLACK=1
 LET bcBLUE=2
 LET bcCYAN=4
 LET bcGRAY=8
 LET bcLGRAY=9
 LET bcLBLUE=10
 LET bcLCYAN=12
 LET bcLGREEN=11
 LET bcLMAGENTA=14
 LET bcWHITE=16
 LET bcNOBORDER$="-"
 LET bcALLOWNEW$="N"
 LET bcMENUBTN$="W"
 LET bcMENULIST$="w"
 LET bcROUND$=")"
 LET bcFRMBUTTON=6
 LET bcRECBREAK$=CHR$(174)
 GOSUB @LoadRGBData
 GOSUB @getcontroldata
 GR.TEXT.SIZE ctrlfont
 GR.TEXT.ALIGN 1
 BUNDLE.GET 1,"frmscale",frmscale
 BUNDLE.GET ptrctrl,"type",ctrltype
 LET rh=ctrlheight
 LET fo=@getfontyoffset(rh,ctrlfont)
 LET xo=ctrlfont/4
 BUNDLE.PUT ptrctrl,"cbrowh",rh
 IF IS_IN(bcMENULIST$,ctrlstyle$)<>0 THEN
  LET cbl=ctrlleft
  IF cbl+ctrlmiddle>swidth THEN LET cbl=ctrlleft+ctrlwidth-ctrlmiddle
  LET cbr=cbl+ctrlmiddle
  IF IS_IN(bcMENUBTN$,ctrlstyle$)<>0 THEN
   LET cb=bcBLACK
   LIST.SIZE ctrldatalst,cborc
  ELSE
   LET cb=bcWHITE
   LET cborc=10
  ENDIF
  LET y=ctrltop+ctrlheight+2
 ELSE
  LET cbl=ctrlleft+ctrlmiddle
  LET cbr=cbl+ctrlwidth-ctrlmiddle
  LET cborc=10
  LET cb=bcWHITE
 ENDIF
 IF IS_IN(bcMENUBTN$,ctrlstyle$)=0 THEN
  LET dr=FLOOR((sheight-ctrltop-ctrlheight-2)/rh)
  LET ur=FLOOR((ctrltop-2)/rh)
  IF dr+1>=ur THEN
   LET cborc=dr
   LET j=0
  ELSE
   LET cborc=ur
   LET j=1
  ENDIF
  IF cborc>10 THEN LET cborc=10
  IF j=0 THEN LET y=ctrltop+ctrlheight+2 ELSE LET y=ctrltop-cborc*rh-2
 ENDIF
 LET cblisttop=y
 LET cblistbox$=""
 GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcFILL
 GR.RECT gonum,0,0,swidth,sheight
 BUNDLE.PUT ptrctrl,"cbbdr",gonum
 FOR i=0 TO cborc-1
  GR.COLOR bcTRANSPARENT,BCMP[cb],GCMP[cb],RCMP[cb],bcFILL
  GR.RECT gonum,cbl,y+(i*rh),cbr,y+(i*rh)+rh
  cblistbox$=cblistbox$+bcRECBREAK$+STR$(gonum)
  GR.COLOR bcTRANSPARENT,BCMP[ctrlcapbakclr],GCMP[ctrlcapbakclr],RCMP[ctrlcapbakclr],bcNOFILL
  GR.RECT gonum,cbl,y+(i*rh),cbr,y+(i*rh)+rh
  GR.COLOR bcTRANSPARENT,BCMP[bcLBLUE],GCMP[bcLBLUE],RCMP[bcLBLUE],bcFILL
  GR.RECT gonum,cbl+3,y+(i*rh)+3,cbr-3,y+((i+1)*rh)-3
  GR.COLOR bcTRANSPARENT,BCMP[ctrldattxtclr],GCMP[ctrldattxtclr],RCMP[ctrldattxtclr],bcFILL
  GR.CLIP gonum,cbl,y+i*rh,cbr,y+i*rh+rh,2
  GR.TEXT.DRAW gonum,cbl+xo,y+fo+(i*rh),""
  GR.CLIP gonum,0,0,swidth,sheight,2
  IF i<cborc-1 THEN
   GR.COLOR bcTRANSPARENT,BCMP[ctrlcaptxtclr],GCMP[ctrlcaptxtclr],RCMP[ctrlcaptxtclr],bcNOFILL
   GR.SET.STROKE 5
   GR.LINE gonum3,cbl,y+(i*rh)+rh,cbr,y+(i*rh)+rh
   GR.SET.STROKE 0
  ELSE
   LET gonum3=gonum
  ENDIF
 NEXT i
 LET cblistbox$=MID$(cblistbox$,2)
 BUNDLE.PUT ptrctrl,"cblistbox",cblistbox$
 IF IS_IN(bcMENUBTN$,ctrlstyle$)=0 THEN
  BUNDLE.GET 1,"sbwidth",SBW
  LET rw=cbr-SBW
  GR.BITMAP.CREATE scrollbmp,SBW,cborc*rh
  BUNDLE.PUT ptrctrl,"cbsliderbm",scrollbmp
  GR.BITMAP.DRAW into.startscrollbmp
  GR.COLOR bcOPAQUE,BCMP[bcWHITE],GCMP[bcWHITE],RCMP[bcWHITE],bcFILL
  GR.RECT gonum,0,SBW,SBW,(cborc*rh)-SBW
  IF IS_IN(bcNOBORDER$,ctrlstyle$)=0 THEN
   GR.COLOR bcOPAQUE,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
   GR.RECT gonum,0,SBW,SBW,(cborc*rh)-SBW
  ENDIF
  LET s$=REPLACE$(ctrlstyle$,bcROUND$,"")
  LET gonum=@drawbutton("CBVu"+INT$(ptrctrl),bcLBLUE,bcWHITE,0,0,SBW,SBW,ctrlfont/4, ~
            s$,0,"^",bcOPAQUE,gonum,gonum)
  LET gonum=@drawbutton("CBVd"+INT$(ptrctrl),bcLBLUE,bcWHITE,0,(cborc*rh)-SBW,SBW,SBW,ctrlfont/4, ~
            s$,0,"v",bcOPAQUE,gonum,gonum)
  GR.BITMAP.DRAW into.end
  CALL @AddToBmpList("CBV",ptrctrl,scrollbmp)
  GR.BITMAP.DRAW gonum,scrollbmp,rw,y
  BUNDLE.PUT ptrctrl,"cbsliderobj",gonum
  GR.MODIFY gonum,"alpha",bcTRANSPARENT
  LET i=(cborc*rh)-SBW-SBW
  LET sh=(i*cborc)/(cborc+1)
  IF sh>i THEN LET sh=i
  LET sy=y+(cborc*rh)-SBW
  BUNDLE.PUT ptrctrl,"cbslidem",i-sh
  BUNDLE.PUT ptrctrl,"cbslideh",sh
  GR.COLOR bcTRANSPARENT,BCMP[bcGRAY],GCMP[bcGRAY],RCMP[bcGRAY],bcFILL
  GR.RECT gonum,rw,sy,rw+SBW,sy+sh
  BUNDLE.PUT ptrctrl,"cbslidebak",gonum
  GR.COLOR bcTRANSPARENT,BCMP[bcLMAGENTA],GCMP[bcLMAGENTA],RCMP[bcLMAGENTA],bcFILL
  GR.RECT gonum3,rw+5,sy+5,rw+SBW-5,sy+sh-5
  IF IS_IN(bcNOBORDER$,ctrlstyle$)=0 THEN
   GR.COLOR bcTRANSPARENT,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
   GR.RECT gonum3,rw,sy,rw+SBW,sy+sh
   GR.RECT gonum3,rw+5,sy+5,rw+SBW-5,sy+sh-4
  ENDIF
  lAlph=bcTRANSPARENT
  IF IS_IN(bcALLOWNEW$,ctrlstyle$)<>0 THEN LET i=bcLGREEN ELSE LET i=bcLGRAY
  IF ctrlType=bcFRMBUTTON THEN
   qx=ctrlleft
   qy=ctrltop
   qw=ctrlwidth
   qh=ctrlheight
  ELSE
   qx=ctrlleft+ctrlwidth-rh
   qy=ctrltop
   qw=rh
   qh=rh
  ENDIF
  GR.COLOR lAlph,BCMP[bcGRAY],GCMP[bcGRAY],RCMP[bcGRAY],bcFILL
  GR.RECT gonum1,qx,qy,qx+qw,qy+qh
  GR.COLOR lAlph,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
  GR.RECT gonum2,qx,qy,qx+qw,qy+qh
  GR.COLOR lAlph,BCMP[bcLCYAN],GCMP[bcLCYAN],RCMP[bcLCYAN],bcFILL
  GR.RECT gonum2,qx+4,qy+4,qx+qw-4,qy+qh-4
  GR.COLOR lAlph,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
  GR.RECT gonum2,qx+4,qy+4,qx+qw-4,qy+qh-4
  qx=qx+(qw-28)/2
  qy=qy+((qh-ctrlfont)/2)
  bcol=bcBLACK
  GOSUB @SBR_DrawBinocs
  BUNDLE.PUT ptrctrl,"comboqn1",gonum1
  BUNDLE.PUT ptrctrl,"comboqn4",gonum4
 ENDIF
 BUNDLE.PUT ptrctrl,"cbcbl",cbl
 BUNDLE.PUT ptrctrl,"cbcbr",cbr
 BUNDLE.PUT ptrctrl,"cblastobj",gonum3
 BUNDLE.PUT ptrctrl,"cbrowcnt",cborc
 BUNDLE.PUT ptrctrl,"cblisttop",cblisttop
 BUNDLE.PUT ptrctrl,"cbolastidx",0
 FN.RTN gonum4
FN.END
!
!  @ C L I C K _ C O M B O B O X
!
FN.DEF @clickcombobox(pctrlcapsize$,pctrldatalst,pctrldata$,pctrldattxtobj,ptrctrl,ctrltop, ~
       ctrlleft,ctrlheight,ctrlmiddle,ctrlwidth,ctrlfont)
 LET bcOPAQUE=255
 LET bcSEMIOPAQUE=128
 LET bcTRANSPARENT=0
 LET bcQUICKNAV$="Q"
 LET bcMENUBTN$="W"
 LET bcMENULIST$="w"
 LET bcNOBORDER$="-"
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET bcNOTSIGN$=CHR$(172)
 BUNDLE.GET 1,"sheight",sheight
 BUNDLE.GET ptrctrl,"style",style$
 BUNDLE.GET ptrctrl,"cbrowh",rh
 BUNDLE.GET ptrctrl,"cblistbox",cblbox$
 BUNDLE.GET ptrctrl,"cblastobj",lastobj
 BUNDLE.GET ptrctrl,"cbrowcnt",cborc
 BUNDLE.GET ptrctrl,"cblisttop",cbt
 BUNDLE.GET ptrctrl,"cbcbl",cbl
 BUNDLE.GET ptrctrl,"cbcbr",cbr
 BUNDLE.GET 1,"sbwidth",SBW
 BUNDLE.GET ptrctrl,"cbbdr",bdrobj
 SPLIT.ALL cblistbox$[],cblbox$,bcRECBREAK$
 CALL @BringToFront(VAL(cblistbox$[1]),lastobj,0)
 IF IS_IN(bcQUICKNAV$,style$)<>0 THEN
  BUNDLE.GET ptrctrl,"comboqn1",comboqn1
  BUNDLE.GET ptrctrl,"comboqn4",comboqn4
  CALL @BringToFront(comboqn1,comboqn4,1)
 ENDIF
 LIST.TOARRAY pctrldatalst,tdata$[]
 LIST.SIZE pctrldatalst,lcnt
 DIM sdata$[lcnt]
 DIM bLine[lcnt]
 LET j=0
 LET k=0
 FOR i=1 TO lcnt
  LET i$=REPLACE$(tdata$[i],bcNOTSIGN$,"")
  LET p=IS_IN(bcCOLBREAK$,i$)
  IF p<>0 THEN LET sdata$[i]=LEFT$(i$,p-1) ELSE LET sdata$[i]=i$
  IF sdata$[i]="-" THEN
   LET bLine[j]=1
   LET k=k+1
  ELSE
   LET j=j+1
   LET sdata$[j]=sdata$[i]
   LET tdata$[j]=tdata$[i]
   LET bLine[j]=0
  ENDIF
 NEXT i
 LET lcnt=lcnt-k
 IF lcnt>0 THEN
  LET rcnt=lcnt
  LET rw=cbr
  IF rcnt>cborc THEN
   LET rcnt=cborc
   BUNDLE.GET ptrctrl,"cbsliderobj",sliderobj
   BUNDLE.GET ptrctrl,"cbslidem",sm
   BUNDLE.GET ptrctrl,"cbslideh",sh
   BUNDLE.GET ptrctrl,"cbslidebak",slidebak
   GR.MODIFY sliderobj,"alpha",bcOPAQUE
   GR.MODIFY slidebak,"alpha",bcOPAQUE
   GR.MODIFY slidebak+1,"alpha",bcOPAQUE
   IF IS_IN(bcNOBORDER$,style$)=0 THEN
    GR.MODIFY slidebak+2,"alpha",bcOPAQUE
    GR.MODIFY slidebak+3,"alpha",bcOPAQUE
   ENDIF
   LET rw=rw-SBW
  ENDIF
  IF IS_IN(bcQUICKNAV$,style$)<>0 THEN
   FOR i=comboqn1 TO comboqn4
    GR.MODIFY i,"alpha",bcOPAQUE
   NEXT i
  ENDIF
  IF cbt<ctrltop THEN
   IF lcnt<cborc THEN LET ro=cborc-lcnt ELSE LET ro=0
  ELSE
   LET ro=0
  ENDIF
  LET fo=@getfontyoffset(rh,ctrlfont)
  LET cbb=cbt+rcnt*rh
  IF IS_IN(bcMENULIST$,style$)<>0 THEN LET ft=0 ELSE LET ft=1
  LET rc=0
  LET fe=0
!_________
UpdateCBO:
  LET ce=1
  LET ft=ft+1
  IF pctrldata$<>"" THEN
   LET i=IS_IN(bcCOLBREAK$,pctrldata$)
   IF i=0 THEN LET i$=pctrldata$ ELSE LET i$=LEFT$(pctrldata$,i-1)
   FOR i=1 TO lcnt
    IF sdata$[i]=i$ THEN
     LET ce=i
     F_N.BREAK
    ENDIF
   NEXT i
  ENDIF
  IF fe=0 THEN
   IF lcnt>rcnt THEN
    IF ce+rcnt>lcnt THEN LET fe=lcnt-rcnt ELSE LET fe=ce
   ELSE
    LET fe=1
   ENDIF
  ENDIF
  LET j=fe
  FOR i=0+ro TO rcnt+ro-1
   LET lbobj=VAL(cblistbox$[i+1])
   GR.MODIFY lbobj,"alpha",bcOPAQUE,"top",cbt+(i*rh),"bottom",cbt+(i*rh)+rh
   GR.MODIFY lbobj+1,"alpha",bcSEMIOPAQUE,"top",cbt+(i*rh),"bottom",cbt+(i*rh)+rh
   GR.MODIFY lbobj+2,"top",cbt+(i*rh)+3,"bottom",cbt+(i*rh)+rh-3
   IF ce=j & ft>1 THEN
    GR.MODIFY lbobj+2,"alpha",bcOPAQUE
   ELSE
    GR.MODIFY lbobj+2,"alpha",bcTRANSPARENT
   ENDIF
   GR.MODIFY lbobj+3,"top",cbt+i*rh,"bottom",cbt+i*rh+rh
   IF LEFT$(tdata$[j],1)=bcNOTSIGN$ THEN LET a=bcSEMIOPAQUE ELSE LET a=bcOPAQUE
   GR.MODIFY lbobj+4,"alpha",a,"y",cbt+fo+(i*rh),"text",sdata$[j]
   IF bLine[j]=1 THEN
    GR.MODIFY lbobj+6,"alpha",bcOPAQUE
   ENDIF
   LET j=j+1
  NEXT i
  IF IS_IN(bcMENUBTN$,style$)=0 THEN
   IF lcnt>cborc THEN
    LET i=(cborc*rh)-SBW-SBW
    LET sh=(i*cborc)/(lcnt)
    IF sh>i THEN LET sh=i
    LET sm=i-sh
    LET sy=cbb-SBW-sh
    LET sdy=sy-sm+k+(sm/(lcnt-rcnt))*(fe-1)
    GR.MODIFY slidebak,"top",sdy,"bottom",sdy+sh
    GR.MODIFY slidebak+1,"top",sdy+5,"bottom",sdy+sh-5
    IF IS_IN(bcNOBORDER$,style$)=0 THEN
     GR.MODIFY slidebak+2,"top",sdy,"bottom",sdy+sh
     GR.MODIFY slidebak+3,"top",sdy+5,"bottom",sdy+sh-5
    ENDIF
   ENDIF
  ENDIF
  LET tmpt=cbt+ro*rh
  LET tmpb=cbb+ro*rh
  GR.MODIFY bdrobj,"alpha",bcSEMIOPAQUE
  GR.RENDER
  IF rc=1 THEN
   PAUSE 500
   GOTO CloseLst
  ENDIF
!___________
GetCBOTouch:
  LET bpressed=0
  LET exCod=0
  DO
   LET tch=0
   GR.TOUCH tch,tx,ty
   IF tch=1 THEN
    GR.BOUNDED.TOUCH tch,cbl,tmpt,cbr,tmpb
    IF tch=0 THEN
     IF tx>ctrlleft & tx<cbr & ty>ctrltop & ty<ctrltop+ctrlheight THEN
      IF IS_IN(bcQUICKNAV$,style$)<>0 & lcnt>cborc THEN
       LET nfe=fe
       s$=""
       t$=""
       b$=""
       LET qp$=@quicknav$(ptrctrl,&s$,&t$,&b$)
       IF qp$<>bcCOLBREAK$ THEN
        IF b$="F" THEN
         LET sp=1
        ELSE
         BUNDLE.GET ptrctrl,"cbolastidx",sp
         IF sp=0 THEN LET sp=1
        ENDIF
        FOR nfe=sp TO lcnt
         IF t$="A" THEN
          IF IS_IN(qp$,UPPER$(sdata$[nfe])<>0 THEN
           BUNDLE.PUT ptrctrl,"cbolastidx",nfe
           F_N.BREAK
          ENDIF
         ELSE
          IF LEFT$(UPPER$(sdata$[nfe]),LEN(qp$))=qp$ THEN
           BUNDLE.PUT ptrctrl,"cbolastidx",nfe
           F_N.BREAK
          ENDIF
         ENDIF
        NEXT nfe
        IF nfe>lcnt THEN
         LET nfe=2
        ENDIF
       ENDIF
       LET exCod=1
       D_U.BREAK
      ENDIF
     ENDIF
     IF tx<cbl-rh | tx>cbr+rh | ty<tmpt-rh | ty>tmpb+rh THEN LET tch=2
    ENDIF
    DO
     GR.TOUCH tuch,ux,uy
    UNTIL tuch=0
    LET bpressed=1
   ENDIF
  UNTIL bpressed=1
  IF exCod=1 THEN GOTO ChekNFE
  CALL @soundrtn()
  IF tch=1 THEN
   IF tx>rw THEN
    IF ty<tmpt+SBW THEN
     LET nfe=fe-1
    ELSEIF ty>tmpb-SBW THEN
     LET nfe=fe+1
    ELSEIF ty>tmpt+((tmpb-tmpt)/2)
     LET nfe=fe+rcnt-1
    ELSE
     LET nfe=fe-rcnt+1
    ENDIF
!_______
ChekNFE:
    IF nfe<1 THEN
     LET nfe=1
    ELSEIF nfe+rcnt-1>lcnt THEN
     LET nfe=lcnt-rcnt+1
    ENDIF
    IF fe<>nfe THEN
     LET fe=nfe
     GOTO UpdateCBO
    ELSE
     GOTO GetCBOTouch
    ENDIF
   ELSE
    LET rc=FLOOR((ty-tmpt)/rh)+fe
    IF rc<1 THEN GOTO CloseLst
    LET pctrldata$=tdata$[rc]
    IF IS_IN(bcMENULIST$,style$)=0 THEN
     GR.MODIFY pctrldattxtobj,"text",sdata$[rc]
    ENDIF
    IF LEFT$(tdata$[rc],1)<>bcNOTSIGN$ THEN LET rc=1 ELSE LET ft=0
    GOTO UpdateCBO
   ENDIF
  ELSEIF tch=2 THEN
   LET rc=0  
   GOTO CloseLst
  ELSE
   GOTO GetCBOTouch
  ENDIF
!________
CloseLst:
  FOR i=VAL(cblistbox$[1]) TO lastobj
   GR.MODIFY i,"alpha",bcTRANSPARENT
  NEXT i
  GR.MODIFY bdrobj,"alpha",bcTRANSPARENT
  IF IS_IN(bcQUICKNAV$,style$)<>0 THEN
   FOR i=comboqn1 TO comboqn4
    GR.MODIFY i,"alpha",bcTRANSPARENT
   NEXT i
  ENDIF
  GR.RENDER
 ENDIF
 FN.RTN rc
FN.END
!
!  @ A D D _ C O M B O B O X _ E N T R Y
!
FN.DEF @addcomboboxentry(pctrlsizecap$,pctrldatalst,pctrldata$,pctrlstyle$,pctrldattxtobj, ~
       pfld,ptrctrl)
 LET bcALLOWNEW$="N"
 LET bcNOSORT$="n"
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 LET rc=0
 IF IS_IN(bcALLOWNEW$,pctrlstyle$)>0 THEN
  LET inpheader$=pctrlsizecap$
  LET inptext$=pctrldata$
  GOSUB KeyRoutine
  IF inptext$<>"" & inptext$<>bcCOLBREAK$ THEN
   LIST.SEARCH pctrldatalst,inptext$,i,2
   IF i<>0 THEN
    POPUP "Error: Value '"+inptext$+"' already exists.",0,0,1
   ELSE
    LIST.ADD pctrldatalst,inptext$
    IF IS_IN(bcNOSORT$,pctrlstyle$)=0 THEN
     LIST.TOARRAY pctrldatalst,f$[]
     LET f$[1]=CHR$(10)+f$[1]
     LIST.CLEAR pctrldatalst
     ARRAY.SORT f$[]
     LET f$[1]=MID$(f$[1],2)
     LIST.ADD.ARRAY pctrldatalst,f$[]
    ENDIF
    LET pctrldata$=inptext$
    GR.MODIFY pctrldattxtobj,"text",pctrldata$
    GR.RENDER
    LET rc=1
   ENDIF
  ENDIF
 ENDIF
 FN.RTN rc
FN.END

!#@#@#@#_checkbox_ & _optionbutton_controls

!
!  @ D R A W _ C H E C K B O X
!
FN.DEF @drawcheckbox(ctrltop,ctrlleft,cbottom,ctrldata$,ctrlfont,ctrldattxtobj,adjleft)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcBLACK=1
 LET bcBLUE=2
 GOSUB @LoadRGBData
 IF ctrldata$="Y" THEN LET j=bcOPAQUE ELSE LET j=bcTRANSPARENT
 GR.COLOR j,BCMP[bcBLUE],GCMP[bcBLUE],RCMP[bcBLUE],bcFILL
 LET i=(cbottom-ctrltop-ctrlfont)/2
 GR.RECT gonum,adjleft+i,ctrltop+i,adjleft+i+ctrlfont,cbottom-i
 LET ctrldattxtobj=gonum
 GR.COLOR bcOPAQUE,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
 GR.RECT gonum,adjleft+i,ctrltop+i,adjleft+i+ctrlfont,cbottom-i
 FN.RTN gonum
FN.END
!
!  @ C L I C K _ C H E C K B O X
!
FN.DEF @clickcheckbox(pctrldata$,pctrldattxtobj)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 IF pctrldata$="Y" THEN
  LET pctrldata$="N"
  LET i=bcTRANSPARENT
 ELSE
  LET pctrldata$="Y"
  LET i=bcOPAQUE
 ENDIF
 GR.MODIFY pctrldattxtobj,"alpha",i
 GR.RENDER
 FN.RTN 1
FN.END
!
!  @ D R A W _ O P T _ B U T T O N
!
FN.DEF @drawoptbutton(ptrctrl,ctrltype,ctrldatalst,ctrltop,ctrlheight,ctrlfont,ctrlstyle$, ~
       ctrldata$,adjleft,omargin,fo)
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcBLACK=1
 LET bcBLUE=2
 LET bcFRMOPTBUTTON=11
 LET bcRECBREAK$=CHR$(174)
 GOSUB @LoadRGBData
 UNDIM  stemp$[]
 LIST.SIZE ctrldatalst,datalstcnt
 UNDIM  optmarkobj$[]
 DIM optmarkobj$[datalstcnt]
 UNDIM  opttextobj$[]
 DIM opttextobj$[datalstcnt]
 UNDIM  optcoord$[]
 DIM optcoord$[datalstcnt*4]
 LET opty=0
 LET maxwidth=0
 CALL @setstyle(ctrltype,ctrlstyle$,"d")
 FOR i=1 TO datalstcnt
  LIST.GET ctrldatalst,i,stemp$
  IF IS_IN(stemp$,ctrldata$)<>0 THEN LET j=bcOPAQUE ELSE LET j=bcTRANSPARENT
  GR.COLOR j,BCMP[bcBLUE],GCMP[bcBLUE],RCMP[bcBLUE],bcFILL
  IF ctrlfont<24 THEN LET j=24 ELSE LET j=ctrlfont
  LET x=adjleft+omargin
  LET y=ctrltop+omargin
  IF ctrltype=bcFRMOPTBUTTON THEN
   GR.CIRCLE gonum,x+(j/2),y+(j/2)+opty,(j/2)-2
  ELSE
   GR.RECT gonum,x+2,y+2+opty,x+j-2,y+j-2+opty
  ENDIF
  LET optmarkobj$[i]=STR$(gonum)
  GR.COLOR bcOPAQUE,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcNOFILL
  IF ctrltype=bcFRMOPTBUTTON THEN
   GR.CIRCLE gonum,x+(j/2),y+(j/2)+opty,j/2
  ELSE
   GR.RECT gonum,x,y+opty,x+j,y+j+opty
  ENDIF
  GR.COLOR bcOPAQUE,BCMP[bcBLACK],GCMP[bcBLACK],RCMP[bcBLACK],bcFILL
  GR.TEXT.DRAW gonum,adjleft+(2*omargin)+ctrlfont,ctrltop+fo+opty,stemp$
  LET opttextobj$[i]=STR$(gonum)
  GR.TEXT.WIDTH txtwidth,stemp$
  IF txtwidth>maxwidth THEN LET maxwidth=txtwidth
  LET lindex=(i-1)*4
  LET optcoord$[lindex+1]=STR$(adjleft)
  LET optcoord$[lindex+2]=STR$(ctrltop+opty)
  LET optcoord$[lindex+3]=STR$(adjleft+(2*omargin)+ctrlfont+maxwidth)
  LET opty=opty+j+omargin
  LET optcoord$[lindex+4]=STR$(ctrltop+opty)
  IF fo+opty>ctrlheight THEN
   LET adjleft=adjleft+(3*omargin)+ctrlfont+maxwidth
   LET opty=0
   LET maxwidth=0
  ENDIF
 NEXT i
 BUNDLE.PUT ptrctrl,"optmarkobj",join$(optmarkobj$[],bcRECBREAK$)
 BUNDLE.PUT ptrctrl,"opttextobj",join$(opttextobj$[],bcRECBREAK$)
 BUNDLE.PUT ptrctrl,"optcoord",join$(optcoord$[],bcRECBREAK$)
 FN.RTN gonum
FN.END
!
!  @ C L I C K _ O P T I O N _ B U T T O N
!
FN.DEF @clickoptionbutton(px,py,pctrldatalst,pctrldata$,poptmarkobj$,poptcoord$,pRend, ~
   pctrltype,pctrlstate$)
 LET bcOPAQUE=255
 LET bcSEMIOPAQUE=128
 LET bcTRANSPARENT=0
 LET bcFRMOPTBUTTON=11
 LET bcRECBREAK$=CHR$(174)
 SPLIT optmarkobj$[],poptmarkobj$,bcRECBREAK$
 ARRAY.LENGTH oc,optmarkobj$[]
 SPLIT optcoord$[],poptcoord$,bcRECBREAK$
 IF IS_IN("H",pctrlstate$)<>0 THEN
  LET lAlpha=bcTRANSPARENT
 ELSE
  IF IS_IN("D",pctrlstate$)<>0 THEN LET lAlpha=bcSEMIOPAQUE ELSE LET lAlpha=bcOPAQUE
 ENDIF
 LET selopt=0
 LET bclick=1
 FOR i=1 TO oc
  LET ps=(i-1)*4
  IF px>=VAL(optcoord$[ps+1]) & px<=VAL(optcoord$[ps+3]) ~
  & py>=VAL(optcoord$[ps+2]) & py<=VAL(optcoord$[ps+4]) THEN
   LET selopt=i
   F_N.BREAK
  ENDIF
 NEXT i
 IF pctrltype=bcFRMOPTBUTTON THEN
  FOR i=1 TO oc
   GR.MODIFY VAL(optmarkobj$[i]),"alpha",bcTRANSPARENT
  NEXT i
 ENDIF
 LIST.TOARRAY pctrldatalst,stemp$[]
 IF selopt=0 THEN
  ARRAY.LENGTH optcount,stemp$[]
  FOR i=1 TO optcount
   IF pctrltype=bcFRMOPTBUTTON THEN
    IF pctrldata$=stemp$[i] THEN
     LET selopt=i
     F_N.BREAK
    ENDIF
   ELSE
    IF IS_IN(stemp$[i],pctrldata$)=0 THEN LET j=bcTRANSPARENT ELSE LET j=lAlpha
    GR.MODIFY VAL(optmarkobj$[i]),"alpha",j
   ENDIF
  NEXT i
  LET bclick=0
 ENDIF
 IF selopt<>0 THEN
  IF pctrltype=bcFRMOPTBUTTON THEN
   LET pctrldata$=stemp$[selopt]
   LET i=lAlpha
  ELSE
   IF IS_IN(stemp$[selopt],pctrldata$)=0 THEN
    IF pctrldata$<>"" THEN LET pctrldata$=pctrldata$+bcRECBREAK$
    LET pctrldata$=pctrldata$+stemp$[selopt]
    LET i=lAlpha
   ELSE
    LET pctrldata$=REPLACE$(pctrldata$,stemp$[selopt],"")
    LET pctrldata$=REPLACE$(pctrldata$,bcRECBREAK$+bcRECBREAK$,bcRECBREAK$)
    IF LEFT$(pctrldata$,1)=bcRECBREAK$ THEN LET pctrldata$=MID$(pctrldata$,2)
    IF RIGHT$(pctrldata$,1)=bcRECBREAK$ THEN LET pctrldata$=LEFT$(pctrldata$,LEN(pctrldata$)-1)
    LET i=bcTRANSPARENT
   ENDIF
  ENDIF
  GR.MODIFY VAL(optmarkobj$[selopt]),"alpha",i
 ENDIF
 IF pRend=1 THEN GR.RENDER
 IF bclick=0 THEN LET selopt=0
 FN.RTN selopt
FN.END

!#@#@#@#_set_ & _get_routines

!
!  S E T _ C T R L _ C A P
!
FN.DEF setctrlcap(pctrlno,pvalue$)
 LET bcFRMLISTBOX=9
 LET bcRECBREAK$=CHR$(174)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"type",ctrltype
 IF ctrltype=bcFRMLISTBOX THEN
  CALL @setlistboxcap(ptrctrl,pvalue$)
 ELSE
  BUNDLE.GET ptrctrl,"datalst",datalst
  LET i=IS_IN(bcRECBREAK$,pvalue$)
  IF i=0 THEN
   LET c$=pvalue$
   LIST.CLEAR datalst
   LIST.ADD datalst,""
  ELSE
   LET c$=LEFT$(pvalue$,i-1)
   LET d$=MID$(pvalue$,i+1)
   SPLIT f$[],d$,bcRECBREAK$
   LIST.CLEAR datalst
   LIST.ADD.ARRAY datalst,f$[]
  ENDIF
  BUNDLE.PUT ptrctrl,"origcap",c$
  BUNDLE.PUT ptrctrl,"sizecap",c$
 ENDIF
 FN.RTN 0
FN.END
!
!  S E T _ C T R L _ F O N T _ S I Z E
!
FN.DEF SetCtrlFontSize(pctrlno,pval)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.PUT ptrctrl,"font",pval
 FN.RTN 0
FN.END
!
!  S E T _ C T R L _ D A T A
!
FN.DEF setctrldata(pctrlno,pvalue$)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.PUT ptrctrl,"data",pvalue$
 FN.RTN 0
FN.END
!
!  G E T _ C T R L _ C A P $
!
FN.DEF getctrlcap$(pctrlno)
 LET bcFRMLISTBOX=9
 LET bcLISTVIEW$="v"
 LET bcMULTILINE$="="
 LET bcEDITABLE$="E"
 LET bcCHECKBOX$="X"
 LET bcRECBREAK$=CHR$(174)
 LET bcCRLF$=CHR$(13)+CHR$(10)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"type",ctrltype
 BUNDLE.GET ptrctrl,"origcap",cap$
 BUNDLE.GET ptrctrl,"style",style$
 IF IS_IN(bcMULTILINE$,style$)<>0 THEN
  BUNDLE.GET ptrctrl,"multisrc",d$
  LET cap$=cap$+bcRECBREAK$+d$
 ELSE
  BUNDLE.GET ptrctrl,"datalst",datalst
  LIST.SIZE datalst,datalstcnt
  IF datalstcnt>1 THEN 
   LIST.TOARRAY datalst,f$[]
   IF ctrltype=bcFRMLISTBOX THEN
    IF IS_IN(bcCHECKBOX$,style$)<>0 THEN
     BUNDLE.GET ptrctrl,"lbchecked",lbchecked
     FOR i=2 TO datalstcnt
      LIST.GET lbchecked,i,c$
      LET f$[i]=c$+f$[i]
     NEXT i
    ENDIF
    LET d$=MID$(JOIN$(f$[],bcRECBREAK$),2)
   ELSE
    LET d$=JOIN$(f$[],bcRECBREAK$)
   ENDIF
   LET cap$=cap$+bcRECBREAK$+d$
  ELSE
   IF ctrltype=bcFRMLISTBOX THEN LET cap$=cap$+bcRECBREAK$
  ENDIF
 ENDIF
 FN.RTN cap$
FN.END
!
!  G E T _ C T R L _ D A T A $
!
FN.DEF getctrldata$(pctrlno)
 LET bcFRMLISTBOX=9
 LET bcLISTVIEW$="v"
 LET bcCHECKBOX$="X"
 LET bcRECBREAK$=CHR$(174)
 LET bcCOLBREAK$=CHR$(169)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"data",data$
 FN.RTN data$
FN.END

!#@#@#@#_mod_routines

!
!  M O D _ C T R L _ C A P
!
FN.DEF modctrlcap(pctrlno,pvalue$,pRend)
 LET bcTRANSPARENT=0
 LET bcFRMSELECT=4
 LET bcFRMLABEL=8
 LET bcFRMLISTBOX=9
 LET bcFRMOPTBUTTON=11
 LET bcFRMSPINBUTTON=12
 LET bcFRMCOMBOBOX=15
 LET bcFRMCHKBUTTON=17
 LET bcOUTLINE$="o"
 LET bcRECBREAK$=CHR$(174)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"state",state$
 CALL setctrlcap(pctrlno,pvalue$)
 IF state$<>"x" THEN
  BUNDLE.GET ptrctrl,"captxtobj",captxtobj
  BUNDLE.GET ptrctrl,"type",ctrltype
  BUNDLE.GET ptrctrl,"sizecap",sizecap$
  BUNDLE.GET ptrctrl,"datalst",datalst
  IF ctrltype=bcFRMOPTBUTTON | ctrltype=bcFRMCHKBUTTON THEN
   GR.MODIFY captxtobj,"text",sizecap$
   BUNDLE.GET ptrctrl,"optmarkobj",optmarkobj$
   BUNDLE.GET ptrctrl,"opttextobj",opttextobj$
   SPLIT ctrlmarkobj$[],optmarkobj$,bcRECBREAK$
   SPLIT ctrltextobj$[],opttextobj$,bcRECBREAK$
   LIST.SIZE datalst,datalstcnt
   FOR i=1 TO datalstcnt
    LIST.GET datalst,i,cap$
    GR.MODIFY VAL(ctrlmarkobj$[i]),"alpha",bcTRANSPARENT
    GR.MODIFY VAL(ctrltextobj$[i]),"text",cap$
   NEXT i
  ELSEIF ctrltype=bcFRMCOMBOBOX THEN
   GR.MODIFY captxtobj,"text",sizecap$
  ELSEIF ctrltype=bcFRMSELECT THEN
   GR.MODIFY captxtobj,"text",sizecap$
   BUNDLE.GET ptrctrl,"dattxtobj",dattxtobj
   LIST.GET datalst,1,cap$
   GR.MODIFY dattxtobj,"text",cap$
  ELSEIF ctrltype=bcFRMSPINBUTTON THEN
   GR.MODIFY captxtobj,"text",sizecap$
   BUNDLE.GET ptrctrl,"dattxtobj",dattxtobj
   LIST.GET datalst,3,cap$
   GR.MODIFY dattxtobj,"text",cap$
  ELSEIF ctrltype=bcFRMLISTBOX THEN
   CALL @RedrawListBoxRows(pctrlno,1)
  ELSE
   GR.MODIFY captxtobj,"text",sizecap$
   IF ctrltype=bcFRMLABEL THEN
    BUNDLE.GET ptrctrl,"style",style$
    IF IS_IN(bcOUTLINE$,style$)<>0 THEN
     GR.MODIFY captxtobj+1,"text",sizecap$
    ENDIF
   ENDIF
  ENDIF
  IF pRend=1 THEN
   GR.RENDER
  ENDIF
 ENDIF
 FN.RTN 0
FN.END
!
!  M O D _ C T R L _ D A T A
!
FN.DEF modctrldata(pctrlno,pvalue$,pRend)
 LET bcFRMTEXT=3
 LET bcFRMSELECT=4
 LET bcFRMPICTURE=7
 LET bcFRMLISTBOX=9
 LET bcFRMCHECKBOX=10
 LET bcFRMOPTBUTTON=11
 LET bcFRMSPINBUTTON=12
 LET bcFRMTIME=16
 LET bcFRMCHKBUTTON=17
 LET bcFLDBREAK$=CHR$(183)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 CALL setctrldata(pctrlno,pvalue$)
 BUNDLE.GET ptrctrl,"state",state$
 IF state$<>"x" THEN
  BUNDLE.GET ptrctrl,"dattxtobj",dattxtobj
  BUNDLE.GET ptrctrl,"type",ctrltype
  BUNDLE.PUT ptrctrl,"data",pvalue$
  IF ctrltype=bcFRMPICTURE THEN
   BUNDLE.GET ptrctrl,"top",top
   BUNDLE.GET ptrctrl,"left",left
   BUNDLE.GET ptrctrl,"width",width
   BUNDLE.GET ptrctrl,"height",height
   BUNDLE.GET ptrctrl,"middle",middle
   BUNDLE.GET ptrctrl,"capbakclr",capbakcol
   BUNDLE.GET ptrctrl,"captxtclr",captxtcol
   BUNDLE.GET ptrctrl,"captxtobj",captxtobj
   BUNDLE.GET ptrctrl,"capbakobj",capbakobj
   CALL @drawpicturertn(ptrctrl,pctrlno,1,pvalue$,top,left,width,height,middle,captxtcol, ~
        capbakcol,&captxtobj,&capbakobj)
   BUNDLE.PUT ptrctrl,"captxtobj",captxtobj
   BUNDLE.PUT ptrctrl,"capbakobj",capbakobj
  ELSE
   IF ctrltype=bcFRMLISTBOX | ctrltype=bcFRMCHECKBOX | ctrltype=bcFRMOPTBUTTON ~
   | ctrltype=bcFRMCHKBUTTON | ctrltype=bcFRMTIME THEN
    CALL @enablespecial(pctrlno,ptrctrl,1)
   ELSE
    GR.MODIFY dattxtobj,"text",pvalue$
   ENDIF
  ENDIF
  IF pRend=1 THEN GR.RENDER
 ENDIF
 FN.RTN 0
FN.END
!
!  S E T _ C T R L _ C A P _ T X T _ C L R
!
FN.DEF setctrlcaptxtclr(pctrlno,pcolour)
 CALL @setctrlcolor(pctrlno,pcolour,"captxtclr")
 FN.RTN 0
FN.END
!
!  S E T _ C T R L _ C A P _ B A K _ C L R
!
FN.DEF setctrlcapbakclr(pctrlno,pcolour)
 CALL @setctrlcolor(pctrlno,pcolour,"capbakclr")
 FN.RTN 0
FN.END
!
!  S E T _ C T R L _ D A T _ T X T _ C L R
!
FN.DEF setctrldattxtclr(pctrlno,pcolour)
 CALL @setctrlcolor(pctrlno,pcolour,"dattxtclr")
 FN.RTN 0
FN.END
!
!  S E T _ C T R L _ D A T _ B A K _ C L R
!
FN.DEF setctrldatbakclr(pctrlno,pcolour)
 CALL @setctrlcolor(pctrlno,pcolour,"datbakclr")
 FN.RTN 0
FN.END
!
!  S E T _ C T R L _ C O L O R
!
FN.DEF @setctrlcolor(pctrlno,pcolour,pcolname$)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.PUT ptrctrl,pcolname$,pcolour
 FN.RTN 0
FN.END
!
!  M O D _ C T R L _ C A P _ T X T _ C L R
!
FN.DEF modctrlcaptxtclr(pctrlno,pcolour,pRend)
 CALL @modctrlcolor(pctrlno,pcolour,"captxtobj","captxtclr","c",pRend)
 FN.RTN 0
FN.END
!
!  M O D _ C T R L _ C A P _ B A K _ C L R
!
FN.DEF modctrlcapbakclr(pctrlno,pcolour,pRend)
 CALL @modctrlcolor(pctrlno,pcolour,"capbakobj","capbakclr","c",pRend)
 FN.RTN 0
FN.END
!
!  M O D _ C T R L _ D A T _ T X T _ C L R
!
FN.DEF modctrldattxtclr(pctrlno,pcolour,pRend)
 CALL @modctrlcolor(pctrlno,pcolour,"dattxtobj","dattxtclr","d",pRend)
 FN.RTN 0
FN.END
!
!  M O D _ C T R L _ D A T _ B A K _ C L R
!
FN.DEF modctrldatbakclr(pctrlno,pcolour,pRend)
 CALL @modctrlcolor(pctrlno,pcolour,"datbakobj","datbakclr","d",pRend)
 FN.RTN 0
FN.END
!
!  M O D _ C T R L _ C O L O R
!
FN.DEF @modctrlcolor(pctrlno,pcolour,pobjname$,pcolname$,parea$,pRend)
 LET bcFILL=1
 LET bcNOFILL=0
 LET bcOPAQUE=255
 LET bcTRANSPARENT=0
 LET bcFRMCHECKBOX=10
 LET bcFRMSHAPE=14
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.PUT ptrctrl,pcolname$,pcolour
 BUNDLE.GET ptrctrl,"state",state$
 IF state$<>"x" THEN
  GOSUB @LoadRGBData
  BUNDLE.GET ptrctrl,"type",type
  BUNDLE.GET ptrctrl,"font",font
  BUNDLE.GET ptrctrl,"style",style$
  BUNDLE.GET ptrctrl,pobjname$,objpaint
  CALL @setstyle(type,style$,parea$)
  IF type=bcFRMSHAPE & pobjname$="captxtobj" THEN
   LET i=bcNOFILL
  ELSE
   LET i=bcFILL
  ENDIF
  GR.COLOR bcOPAQUE,BCMP[pcolour],GCMP[pcolour],RCMP[pcolour],i
  IF type=bcFRMSHAPE THEN
   IF font>0 THEN LET i=font ELSE LET i=1
   GR.SET.STROKE i
  ELSE
   GR.TEXT.SIZE font
  ENDIF
  GR.PAINT.GET pptr
  BUNDLE.GET ptrctrl,"sizecap",cap$
  IF type=bcFRMSHAPE & cap$="rndrect" THEN
   BUNDLE.GET ptrctrl,"firstgrptr",fp
   IF pobjname$="captxtobj" THEN
    j=7
    k=14
   ELSEIF pobjname$="capbakobj" THEN
    j=0
    k=6
   ELSE
    j=1
    k=0
   ENDIF
   FOR cc=fp+j TO fp+k
    GR.MODIFY cc,"paint",pptr
   NEXT cc
  ELSE
   GR.MODIFY objpaint,"paint",pptr
  ENDIF
  GR.SET.STROKE 0
  IF pRend=1 THEN GR.RENDER
 ENDIF
 FN.RTN 0
FN.END
!
!  M O D _ C A P _ T X T _ O B J
!
FN.DEF ModCapTxtObj(pCtrlNo,pTag$,pValue,pRend)
 CALL @ModCtrlObj(pCtrlNo,"captxtobj",pTag$,pValue,pRend)
 FN.RTN 0
FN.END
!
!  M O D _ C A P _ B A K _ O B J
!
FN.DEF ModCapBakObj(pCtrlNo,pTag$,pValue,pRend)
 CALL @ModCtrlObj(pCtrlNo,"capbakobj",pTag$,pValue,pRend)
 FN.RTN 0
FN.END
!
!  M O D _ D A T _ T X T _ O B J
!
FN.DEF ModDatTxtObj(pCtrlNo,pTag$,pValue,pRend)
 CALL @ModCtrlObj(pCtrlNo,"dattxtobj",pTag$,pValue,pRend)
 FN.RTN 0
FN.END
!
!  M O D _ D A T _ B A K _ O B J
!
FN.DEF ModDatBakObj(pCtrlNo,pTag$,pValue,pRend)
 CALL @ModCtrlObj(pCtrlNo,"datbakobj",pTag$,pValue,pRend)
 FN.RTN 0
FN.END
!
!  M O D _ C T R L _ O B J
!
FN.DEF @ModCtrlObj(pCtrlNo,pKey$,pTag$,pValue,pRend)
 bcFRMSHAPE=14
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"state",state$
 IF state$<>"x" THEN
  BUNDLE.GET ptrctrl,"type",ctrltype
  BUNDLE.GET ptrctrl,"sizecap",cap$
  IF ctrltype=bcFRMSHAPE & cap$="rndrect" THEN
   BUNDLE.GET ptrctrl,"firstgrptr",fp
   IF pKey$="captxtobj" THEN
    j=7
    k=14
   ELSEIF pKey$="capbakobj" THEN
    j=0
    k=6
   ELSE
    j=1
    k=0
   ENDIF
   FOR cc=fp+j TO fp+k
    GR.MODIFY cc,pTag$,pValue
   NEXT cc
  ELSE
   BUNDLE.GET ptrctrl,pKey$,gonum
   GR.MODIFY gonum,pTag$,pValue
  ENDIF
  IF pRend=1 THEN GR.RENDER
 ENDIF
 FN.RTN colour
FN.END
!
!  G E T _ C T R L _ C A P _ T X T _ C L R
!
FN.DEF getctrlcaptxtclr(pctrlno)
 LET colour=@getctrlcolour(pctrlno,"captxtclr")
 FN.RTN colour
FN.END
!
!  G E T _ C T R L _ C A P _ B A K _ C L R
!
FN.DEF getctrlcapbakclr(pctrlno)
 LET colour=@getctrlcolour(pctrlno,"capbakclr")
 FN.RTN colour
FN.END
!
!  G E T _ C T R L _ D A T _ T X T _ C L R
!
FN.DEF getctrldattxtclr(pctrlno)
 LET colour=@getctrlcolour(pctrlno,"dattxtclr")
 FN.RTN colour
FN.END
!
!  G E T _ C T R L _ D A T _ B A K _ C L R
!
FN.DEF getctrldatbakclr(pctrlno)
 LET colour=@getctrlcolour(pctrlno,"datbakclr")
 FN.RTN colour
FN.END
!
!  G E T _ C T R L _ C O L O U R
!
FN.DEF @getctrlcolour(pctrlno,pcolname$)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,pcolname$,colour
 FN.RTN colour
FN.END

!#@#@#@#_show,_hide,_enable_ & _disable_routines

!
!  C T R L _ V I S I B L E
!
FN.DEF CtrlVisible(pctrlno,pv,pRend)
 IF pv=1 THEN
  CALL showctrl(pctrlno,pRend)
 ELSE
  CALL hidectrl(pctrlno,pRend)
 ENDIF
 FN.RTN 0
FN.END
!
!  C T R L _ E N A B L E
!
FN.DEF CtrlEnable(pctrlno,pe,pRend)
 IF pe=1 THEN
  CALL enablectrl(pctrlno,pRend)
 ELSE
  CALL disablectrl(pctrlno,pRend)
 ENDIF
 FN.RTN 0
FN.END
!
!  H I D E _ C T R L
!
FN.DEF hidectrl(pctrlno,pRend)
 LET bcTRANSPARENT=0
 CALL @hidedisablertn(pctrlno,pRend,"H",bcTRANSPARENT)
 FN.RTN 0
FN.END
!
!  D I S A B L E _ C T R L
!
FN.DEF disablectrl(pctrlno,pRend)
 LET bcSEMIOPAQUE=128
 CALL @hidedisablertn(pctrlno,pRend,"D",bcSEMIOPAQUE)
 FN.RTN 0
FN.END
!
!  @ H I D E _ D I S A B L E _ R T N
!
FN.DEF @hidedisablertn(pctrlno,pRend,paction$,palpha)
 LET bcSEMIOPAQUE=128
 LET bcTRANSPARENT=0
 LET bcFRMLISTBOX=9
 LET bcFRMCHECKBOX=10
 LET bcFRMOPTBUTTON=11
 LET bcFRMFRAME=13
 LET bcFRMTIME=16
 LET bcFRMCHKBUTTON=17
 LET bcRECBREAK$=CHR$(174)
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"state",ctrlstate$
 IF IS_IN(paction$,ctrlstate$)=0 THEN
  LET newstate$=ctrlstate$+paction$
  BUNDLE.PUT ptrctrl,"state",newstate$
 ENDIF
 IF IS_IN("F",ctrlstate$)=0 THEN
  BUNDLE.GET ptrctrl,"type",ctrltype
  BUNDLE.GET ptrctrl,"firstgrptr",ctrlfirstgrptr
  BUNDLE.GET ptrctrl,"lastgrptr",ctrllastgrptr
  IF ctrltype=bcFRMFRAME THEN
   BUNDLE.GET ptrctrl,"fralastptr",ctrllastgrptr
  ENDIF
  FOR ctrlcount=ctrlfirstgrptr TO ctrllastgrptr
   GR.MODIFY ctrlcount,"alpha",palpha
  NEXT ctrlcount
  IF ctrltype=bcFRMLISTBOX THEN
   CALL @disablelistbox(ptrctrl,palpha)
  ELSEIF ctrltype=bcFRMOPTBUTTON | ctrltype=bcFRMCHKBUTTON THEN
   BUNDLE.GET ptrctrl,"optmarkobj",optmkobj$
   SPLIT optmarkobj$[],optmkobj$,bcRECBREAK$
   ARRAY.LENGTH oc,optmarkobj$[]
   FOR i=1 TO oc
    GR.MODIFY VAL(optmarkobj$[i]),"alpha",bcTRANSPARENT
   NEXT i
  ELSEIF ctrltype=bcFRMCHECKBOX THEN
   BUNDLE.GET ptrctrl,"dattxtobj",ctrldattxtobj
   GR.MODIFY ctrldattxtobj,"alpha",bcTRANSPARENT
  ELSEIF ctrltype=bcFRMTIME THEN
   BUNDLE.GET ptrctrl,"timbakobj",timbakobj
   FOR i=0 TO 2
    GR.MODIFY timbakobj+i,"alpha",bcTRANSPARENT
   NEXT i
  ENDIF
  IF ctrltype=bcFRMFRAME THEN
   BUNDLE.GET ptrctrl,"frappath",i$
   IF i$<>"" THEN
    BUNDLE.PUT 1,"picpath",i$
   ENDIF
   BUNDLE.GET 1,"ctrlcount",ctrlcount
   FOR i=1 TO ctrlcount
    BUNDLE.GET ctrldata,"CP"+STR$(i),childptr
    BUNDLE.GET childptr,"frame",childframe
    IF childframe=pctrlno THEN
     BUNDLE.GET childptr,"state",childstate$
     IF IS_IN("F",childstate$)=0 THEN
      BUNDLE.PUT childptr,"state","F"+childstate$
     ENDIF
     IF IS_IN("H",childstate$)=0 THEN
      BUNDLE.GET childptr,"firstgrptr",childfirstgrptr
      BUNDLE.GET childptr,"lastgrptr",childlastgrptr
      FOR j=childfirstgrptr TO childlastgrptr
       GR.MODIFY j,"alpha",palpha
      NEXT j
     ENDIF
     IF paction$="D" THEN
      BUNDLE.GET childptr,"type",childtype
      IF childtype=bcFRMLISTBOX THEN
       CALL @disablelistbox(childptr,palpha)
      ELSEIF childtype=bcFRMOPTBUTTON | childtype=bcFRMCHKBUTTON THEN
       BUNDLE.GET childptr,"optmarkobj",optmkobj$
       UNDIM  optmarkobj$[]
       SPLIT.ALL optmarkobj$[],optmkobj$,bcRECBREAK$
       ARRAY.LENGTH oc,optmarkobj$[]
       FOR j=1 TO oc
        GR.MODIFY VAL(optmarkobj$[j]),"alpha",bcTRANSPARENT
       NEXT j
      ELSEIF childtype=bcFRMCHECKBOX THEN
       BUNDLE.GET childptr,"dattxtobj",ctrldattxtobj
       GR.MODIFY ctrldattxtobj,"alpha",bcTRANSPARENT
      ELSEIF childtype=bcFRMTIME THEN
       BUNDLE.GET childptr,"timbakobj",timbakobj
       FOR j=0 TO 2
        GR.MODIFY timbakobj+j,"alpha",bcTRANSPARENT
       NEXT j
      ENDIF
     ENDIF
    ENDIF
   NEXT i
  ENDIF
 ENDIF
 IF pRend<>0 THEN GR.RENDER
 FN.RTN 0
FN.END
!
!  S H O W _ C T R L
!
FN.DEF showctrl(pctrlno,pRend)
 CALL @showenablectrl(pctrlno,pRend,"H")
 FN.RTN 0
FN.END
!
!  E N A B L E _ C T R L
!
FN.DEF enablectrl(pctrlno,pRend)
 CALL @showenablectrl(pctrlno,pRend,"D")
 FN.RTN 0
FN.END
!
!  @ S H O W _ E N A B L E _ C T R L
!
FN.DEF @showenablectrl(pctrlno,pRend,paction$)
 LET bcOPAQUE=255
 LET bcSEMIOPAQUE=128
 LET bcTRANSPARENT=0
 LET bcFRMLISTBOX=9
 LET bcFRMCHECKBOX=10
 LET bcFRMOPTBUTTON=11
 LET bcFRMFRAME=13
 LET bcFRMTIME=16
 LET bcFRMCHKBUTTON=17
 LET bcFADEBACK$="+"
 LET bcBLAKBACK$="#"
 BUNDLE.GET 1,"ctrldata",ctrldata
 BUNDLE.GET ctrldata,"CP"+STR$(pctrlno),ptrctrl
 BUNDLE.GET ptrctrl,"type",ctrltype
 BUNDLE.GET ptrctrl,"state",ctrlstate$
 LET newstate$=REPLACE$(ctrlstate$,paction$,"")
 IF newstate$<>ctrlstate$ THEN
  BUNDLE.PUT ptrctrl,"state",newstate$
  IF IS_IN("F",ctrlstate$)=0 THEN
   IF IS_IN("H",newstate$)=0 THEN
    IF paction$="H" THEN
     IF IS_IN("D",ctrlstate$)=0 THEN
      LET alpha=bcOPAQUE
     ELSE
      LET alpha=bcSEMIOPAQUE
     ENDIF
    ELSE
     LET alpha=bcOPAQUE
    ENDIF
    BUNDLE.GET ptrctrl,"firstgrptr",ctrlfirstgrptr
    BUNDLE.GET ptrctrl,"lastgrptr",ctrllastgrptr
    BUNDLE.GET ptrctrl,"type",ctrltype
    IF ctrltype=bcFRMFRAME THEN
     BUNDLE.GET ptrctrl,"fralastptr",fralastptr
     CALL @BringToFront(ctrlfirstgrptr,fralastptr,0)
    ENDIF
    FOR i=ctrlfirstgrptr TO ctrllastgrptr
     GR.MODIFY i,"alpha",alpha
    NEXT i
    IF ctrltype=bcFRMLISTBOX | ctrltype=bcFRMOPTBUTTON | ctrltype=bcFRMCHKBUTTON ~
     | ctrltype=bcFRMCHECKBOX | ctrltype=bcFRMTIME THEN
     CALL @enablespecial(pctrlno,ptrctrl,0)
    ENDIF
    IF ctrltype=bcFRMFRAME THEN
     BUNDLE.GET ptrctrl,"frapath",i$
     IF i$<>"" THEN BUNDLE.PUT 1,"picpath",i$
     IF alpha=bcOPAQUE THEN
      BUNDLE.GET ptrctrl,"style",style$
      IF IS_IN(bcFADEBACK$,style$)>0 | IS_IN(bcBLAKBACK$,style$)>0 THEN
       IF IS_IN(bcBLAKBACK$,style$)>0 THEN LET i=bcOPAQUE ELSE LET i=bcSEMIOPAQUE
       BUNDLE.GET ptrctrl,"frabckobj",gonum
       GR.MODIFY gonum,"alpha",i
      ENDIF
     ENDIF
     BUNDLE.GET 1,"ctrlcount",ctrlcount
     FOR i=1 TO ctrlcount
      BUNDLE.GET ctrldata,"CP"+STR$(i),childptr
      BUNDLE.GET childptr,"frame",childframe
      IF childframe=pctrlno THEN
       BUNDLE.GET childptr,"state",childstate$
       BUNDLE.PUT childptr,"state",REPLACE$(childstate$,"F","")
       IF IS_IN("H",childstate$)=0 THEN
        IF IS_IN("D",newstate$)<>0 | IS_IN("D",childstate$)<>0 THEN
         CALL disablectrl(i,0)
        ELSE
         BUNDLE.GET childptr,"firstgrptr",childfirstgrptr
         BUNDLE.GET childptr,"lastgrptr",childlastgrptr
         FOR j=childfirstgrptr TO childlastgrptr
          GR.MODIFY j,"alpha",bcOPAQUE
         NEXT j
         BUNDLE.GET childptr,"type",ctype
         IF ctype=bcFRMLISTBOX | ctype=bcFRMOPTBUTTON | ctype=bcFRMCHKBUTTON | ctype=bcFRMCHECKBOX ~
          | ctype=bcFRMTIME THEN
          CALL @enablespecial(i,childptr,0)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     NEXT i
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF pRend<>0 THEN GR.RENDER
 FN.RTN 0
FN.END
!
!  @ E N A B L E _ S P E C I A L
!
FN.DEF @enablespecial(pctrlno,ptrctrl,preset)
 LET bcFRMLISTBOX=9
 LET bcFRMCHECKBOX=10
 LET bcFRMTIME=16
 BUNDLE.GET ptrctrl,"type",ctrltype
 BUNDLE.GET ptrctrl,"sizecap",ctrlsizecap$
 BUNDLE.GET ptrctrl,"data",ctrldata$
 IF ctrltype=bcFRMLISTBOX THEN
  CALL @RedrawListBoxRows(pctrlno,preset)
 ELSEIF ctrltype=bcFRMCHECKBOX THEN
  IF ctrldata$="N" THEN LET ctrldata$="Y" ELSE LET ctrldata$="N"
  BUNDLE.GET ptrctrl,"dattxtobj",ctrldattxtobj
  CALL @clickcheckbox(ctrldata$,ctrldattxtobj)
 ELSEIF ctrltype=bcFRMTIME THEN
  IF ctrldata$="" THEN LET ctrldata$="12:00"
  CALL @clicktimebutton(0,ctrldata$,ptrctrl)
 ELSE
  BUNDLE.GET ptrctrl,"datalst",datalst
  BUNDLE.GET ptrctrl,"optmarkobj",optmarkobj$
  BUNDLE.GET ptrctrl,"optcoord",optcoord$
  BUNDLE.GET ptrctrl,"state",state$
  CALL @clickoptionbutton(0,0,datalst,ctrldata$,optmarkobj$,optcoord$,0,ctrltype,state$)
 ENDIF
 FN.RTN 0
FN.END
!=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
!=~~~~End_GraphicControls.bas~~~~=
!=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
