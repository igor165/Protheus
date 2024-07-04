#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "QDOC040.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QDOC040   ³ Autor ³Eduardo de Souza         ³ Data ³ 30/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Visualiza Lista Mestra em HTML                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QDOC040()                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³Programador³Alteracao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³02/04/02³ META ³Eduardo S. ³ Alterado devido novo conceito de utilizacao ³±±
±±³        ³      ³           ³ dos arquivos de Usuarios.                   ³±±
±±³22/08/02³ ---- ³Eduardo S. ³ Alterado para apresentar somente os usuarios³±±
±±³        ³      ³           ³ da filial selecionada.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOC040()

Local aQPath   := QDOPATH()
Local nMyWidth := oMainWnd:nClientWidth - 16 
Local nMyHeight:= oMainWnd:nClientHeight- 30 
Local nOrdQDH  := 0

Private nHandle  := 0
Private cQPath   := aQPath[1]
Private cQPathTrm:= aQPath[3]
Private cFilMat  := xFilial("QAA") // Utilizada na SXB
Private nQaConpad:= 1
Private cNomeHTML := CriaTrab(,.F.)
Private oWebChannel
Private lBuild := GetBuild(.T.) >= "7.00.170117A" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecao da Ordem na Lista Mestra							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !QD40DlgOrd(@nOrdQDH)
	Return .F.
EndIf

If(nHandle:= FCREATE(cQPathTrm+"MESTRA.HTM",FC_NORMAL)) == -1
	If (nHandle := MakeDir(cQPathTrm)) <> 0
		MsgStop(OemToAnsi(STR0001)) // "Impossivel Criar Diretorio"
		Return .F.
	Else
		nHandle := FCREATE(cQPathTrm +"MESTRA.HTM",FC_NORMAL)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega Listra Mestra em Html            					       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun(OemToAnsi(STR0002),OemToAnsi(STR0003),{|| QD40ListHtm(nOrdQDH)}) // "Carregando Lista Mestra..." ### "Aguarde..."	

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0004) FROM 005,005 TO nMyHeight,nMyWidth OF oMainWnd PIXEL // "Lista Mestra Completa de Documentos"

If lBuild
  	oWebChannel := TWebChannel():New() // Prepara o conector WebSocket
	
	nPort := oWebChannel::connect()
	
	oWebEngine := TWebEngine():New(oDlg, 35, 0, (nMyWidth-2)/2,((nMyHeight-2)/2)-15,, nPort)
	oWebEngine:navigate(cQPathTrm +"MESTRA.HTM")
	oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
Else
	oNet := tIBrowser():New(35,0,(nMyWidth-2)/2,((nMyHeight-2)/2)-15,"",oDlg) 
    oNet:Navigate(cQPathTrm +"MESTRA.HTM")
Endif

aButtons := { 	{"BMPPOST", {|| QDC040Email()}	, OemToAnsi(STR0015), OemToAnsi(STR0019) } } //"Lista Mestra por e-mail" //"e-mail"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ ||oDlg:End() },{ ||oDlg:End() },,aButtons) CENTERED

CursorWait()
If File(cQPathTrm+"MESTRA.HTM")
	FErase(cQPathTrm+"MESTRA.HTM")
Endif

If File(cQPath+"MESTRA.HTM")
	FErase(cQPath+"MESTRA.HTM")
Endif
CursorArrow()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD40ListHtm³ Autor ³Eduardo de Souza        ³ Data ³ 30/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Carrega Lista Mestra em Html                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD40ListHtm()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	    ³ QDOC040                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD40ListHtm(nOrdQDH)

Local cFiltro:= " "
Local cDocto := " "
Local cRv    := " "
Local cHtmlI := " "
Local cHtmlF := " "
Local cHtml  := " "
Local cOldAut:= " "
Local cQuery := ""
Local dDataV := ""
Local nCt:=0,nCt1:=0
Local cCampos := ""
Local aInd   := {}

Private Inclui:= .F.

DbSelectArea("QDH")
DbSetOrder(nOrdQDH)

cQuery := "SELECT DISTINCT QDH.*,"
cQuery += "QD0.QD0_FILIAL,QD0.QD0_DOCTO,QD0.QD0_RV,QD0.QD0_AUT,QD0.QD0_FILMAT,QD0.QD0_MAT,QD0.QD0_ORDEM,"
cQuery += "QAA.QAA_FILIAL,QAA.QAA_APELID "
cQuery += " FROM "
cQuery += RetSqlName("QDH")+" QDH,"
cQuery += RetSqlName("QD0")+" QD0,"
cQuery += RetSqlName("QAA")+" QAA "	
cQuery += "WHERE QDH.QDH_FILIAL = '"+xFilial("QDH")+"' AND QDH.QDH_CANCEL = 'N' AND QDH.QDH_OBSOL ='N' AND QDH.QDH_STATUS = 'L  ' AND "
cQuery += "QD0.QD0_FILIAL = QDH.QDH_FILIAL AND QD0.QD0_DOCTO = QDH.QDH_DOCTO AND QD0.QD0_RV = QDH.QDH_RV AND "
cQuery += "QAA.QAA_FILIAL = QD0.QD0_FILMAT AND QAA.QAA_MAT = QD0.QD0_MAT AND "
cQuery += "QAA.D_E_L_E_T_ <> '*' AND "	
cQuery += "QDH.D_E_L_E_T_ <> '*' AND "
cQuery += "QD0.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY "+SqlOrder(QDH->(IndexKey())+"+QD0_AUT+QD0_ORDEM")
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQD",.T.,.T.)
TcSetField("TMPQD","QDH_DTVIG","D")

cHtmlI:= '<html><title>'+OemToAnsi(STR0004)+'</title><body>' // "Lista Mestra Completa de Documentos"
cHtmlI+= '  <table bordercolor=#0099cc height=15 cellspacing=1 width=1100 bordercolorlight=#0099cc border=1>'
cHtmlI+= '    <tr><td bordercolor=#0099cc bordercolorlight=#0099cc align=left width=1100 bgcolor=#0099cc bordercolordark=#0099cc height=1>'
cHtmlI+= '      <p align=center><font face="courier new" color=#ffffff size=4>'
cHtmlI+= '      <b>'+OemToAnsi(Upper(STR0004))+'</b></font></p></td></tr>' // LISTA MESTRA COMPLETA DE DOCUMENTOS
cHtmlI+= '  </table><br>'

cHtmlI+= '  <table bordercolor=#0099cc height=15 cellspacing=1 width=1100 bordercolorlight=#0099cc  border=1>'
cHtmlI+= '    <tr><td align=center width=110 height=15><font face="Arial Black" size=1><b>'+OemToAnsi(STR0005)+'</b></font></td>' // "Documentos"
cHtmlI+= '      <td align=center width=025 height=15><font face="Arial Black" size=1><b>'+OemToAnsi(STR0006)+'</b></font></td>' // "Revisao"
cHtmlI+= '      <td align=center width=405 height=15><font face="Arial Black" size=1><b>'+OemToAnsi(STR0007)+'</b></font></td>' // "Titulo"
cHtmlI+= '      <td align=center width=110 height=15><font face="Arial Black" size=1><b>'+OemToAnsi(STR0008)+'</b></font></td>' // "Elaboradores"
cHtmlI+= '      <td align=center width=110 height=15><font face="Arial Black" size=1><b>'+OemToAnsi(STR0009)+'</b></font></td>' // "Revisores"
cHtmlI+= '      <td align=center width=110 height=15><font face="Arial Black" size=1><b>'+OemToAnsi(STR0010)+'</b></font></td>' // "Aprovadores"
cHtmlI+= '      <td align=center width=120 height=15><font face="Arial Black" size=1><b>'+OemToAnsi(STR0011)+'</b></font></td>' // "Homologadores"
cHtmlI+= '      <td align=center width=100 height=15><font face="Arial Black" size=1><b>'+OemToAnsi(STR0014)+'</b></font></td></tr>' // "Dt Vigencia"
FWRITE( nHandle, cHtmlI )

While TMPQD->(!Eof())
	cFilQDH:=TMPQD->QDH_FILIAL
	cDocto:= TMPQD->QDH_DOCTO
	cRv   := TMPQD->QDH_RV
            dDataV:= TMPQD->QDH_DTVIG
	cHtml:= '   <tr><td valign=botton width=110 height=15><font face="Arial" size=1>'+AllTrim(TMPQD->QDH_DOCTO)+'</font></td>'
	cHtml+= '      <td valign=botton width=025 height=15><font face="Arial" size=1>'+AllTrim(TMPQD->QDH_RV)+'</font></td>'
	cHtml+= '      <td valign=botton width=405 height=15><font face="Arial" size=1>'+AllTrim(TMPQD->QDH_TITULO)+'</font></td>'
	cOldAut:= " "			
	aResp :={}
	While TMPQD->(!Eof()) .And. TMPQD->QDH_FILIAL+TMPQD->QDH_DOCTO+TMPQD->QDH_RV == cFilQDH+cDocto+cRv
		aAdd(aResp,{TMPQD->QD0_AUT,Alltrim(TMPQD->QAA_APELID)})
		TMPQD->(DbSkip())
	EndDo

	If (nCt1:= aScan(aResp,{|x| x[1] == "E"})) > 0
		For nCt:=nCt1 to Len(aresp)
			If aresp[nCt,1]="E"
				If cOldAut <> aresp[nCt,1]
					cHtml+= '<td align=center width=110 height=15><font face="Arial" size=1>'+aresp[nCt,2] // "Elaboradores"
					cOldAut:= aresp[nCt,1]
				Else
					cHtml+= '<br>'+aresp[nCt,2]
				EndIf
			Else
				Exit
			Endif			
		Next
	Else
		cHtml+= '<td align=center width=110 height=15><font face="Arial" size=1>-'
	Endif
	
	If (nCt1:= aScan(aResp,{|x| x[1] == "R"})) > 0
		For nCt:=nCt1 to Len(aresp)
			If aresp[nCt,1]="R"
				If cOldAut <> aresp[nCt,1]
					cHtml+= '<td align=center width=110 height=15><font face="Arial" size=1>'+aresp[nCt,2] // "Elaboradores"
					cOldAut:= aresp[nCt,1]
				Else
					cHtml+= '<br>'+aresp[nCt,2]
				EndIf
			Else
				Exit
			Endif			
		Next
	Else
		cHtml+= '<td align=center width=110 height=15><font face="Arial" size=1>-'
	Endif

	If (nCt1:= aScan(aResp,{|x| x[1] == "A"})) > 0
		For nCt:=nCt1 to Len(aresp)
			If aresp[nCt,1]="A"
				If cOldAut <> aresp[nCt,1]
					cHtml+= '<td align=center width=110 height=15><font face="Arial" size=1>'+aresp[nCt,2] // "Elaboradores"
					cOldAut:= aresp[nCt,1]
				Else
					cHtml+= '<br>'+aresp[nCt,2]
				EndIf
			Else
				Exit
			Endif			
		Next
	Else
		cHtml+= '<td align=center width=110 height=15><font face="Arial" size=1>-'
	Endif

	If (nCt1:= aScan(aResp,{|x| x[1] == "H"})) > 0
		For nCt:=nCt1 to Len(aresp)
			If aresp[nCt,1]="H"
				If cOldAut <> aresp[nCt,1]
					cHtml+= '<td align=center width=110 height=15><font face="Arial" size=1>'+aresp[nCt,2] // "Elaboradores"
					cOldAut:= aresp[nCt,1]
				Else
					cHtml+= '<br>'+aresp[nCt,2]
				EndIf
			Else
				Exit
			Endif			
		Next
	Else
		cHtml+= '<td align=center width=110 height=15><font face="Arial" size=1>-'
	Endif

	cHtml+= '<td align=center width=100 height=15><font face="Arial" size=1>'+DTOC(dDataV)+'</font></td>'
	cHtml+= '</tr>'
	FWRITE( nHandle, cHtml )
EndDo

TMPQD->(dbCloseArea())
DbSelectArea("QDH")

cHtmlF+= '  </table>'
cHtmlF+= '</body></html>'

FWRITE( nHandle, cHtmlF )
FWRITE( nHandle, chr(13)+chr(10))
FCLOSE( nHandle )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD40DlgOrd³ Autor ³Eduardo de Souza        ³ Data ³ 31/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tela Ordem da Lista Mestra                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD40DlgOrd()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	    ³ QDOC040                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD40DlgOrd(nOrdQDH)

Local oDlg
Local oBtn1
Local oBtn2
Local oCombOrd
Local aCombOrd:= {}
Local cCombOrd:= ""
Local cTexto  := ""
Local lRet    := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega array aCombOrd com a Ordem que eh utilizado no ComboBox³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SIX")
DbSeek("QDH")
While SIX->(!Eof()) .And. INDICE == "QDH"
	cTexto := Capital(SixDescricao())
	AADD(aCombOrd," "+cTexto)
	SIX->(DbSkip())
Enddo

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0012) FROM 005,005 TO 110,400 PIXEL // "Ordem da Lista"

@ 005,005 TO 035,194 LABEL OemToAnsi(STR0013) OF oDlg PIXEL // Ordem
@ 015,010 COMBOBOX oCombOrd VAR cCombOrd ITEMS aCombOrd SIZE 180,008 PIXEL OF oDlg

DEFINE SBUTTON oBtn1 FROM 038, 134 TYPE 1 ENABLE OF oDlg;
       ACTION (lRet:= .T.,nOrdQDH:= oCombOrd:nAt,oDlg:End())

DEFINE SBUTTON oBtn2 FROM 038, 166 TYPE 2 ENABLE OF oDlg;
       ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDC040Email³ Autor ³ Eduardo de Souza      ³ Data ³ 31/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia email com Listra Mestra anexo               		 		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ QDC040Email()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC040                                 		               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDC040Email()

Local oDlgMail
Local oFil
Local oMat
Local oApel
Local oEmail
Local oBtnOk
Local oBtnCancel
Local cMat		:= Space(TamSx3("QAA_MAT")[1])
Local cApel   	:= Space(TamSx3("QAA_APELID")[1])
Local cEmail  	:= ""
Local lRet    	:= .f.

Private cFil040	:= xFilial("QAA")

DEFINE MSDIALOG oDlgMail TITLE OemToAnsi(STR0015) FROM 000,000 TO 125,425 PIXEL // "Lista Mestra por e-mail"

@ 006,003 SAY OemToAnsi(STR0016) SIZE 040,010 OF oDlgMail PIXEL //"Usuario"
@ 005,032 MSGET oFil VAR cFil040 F3 "SM0" SIZE 010,005 OF oDlgMail PIXEL;
			VALID QA_CHKFIL(cFil040,@cFilMat)
@ 005,054 MSGET oMat VAR cMat F3 "QDE" SIZE 040,005 OF oDlgMail PIXEL;
			VALID QC040AtuVar(cFil040,cMat,@cApel,@cEmail,@oApel,@oEmail)

@ 020,003 SAY OemToAnsi(STR0019) SIZE 040,010 OF oDlgMail PIXEL //"Email"
@ 020,032 GET oEmail VAR cEmail MEMO NO VSCROLL SIZE 165,020 OF oDlgMail PIXEL

@ 006,101 SAY OemToAnsi(STR0017) SIZE 040,010 OF oDlgMail PIXEL //"Apelido"
@ 005,143 MSGET oApel VAR cApel SIZE 055,010 OF oDlgMail PIXEL
oApel:lReadOnly:= .t.

DEFINE SBUTTON oBtnOk FROM 043,139 TYPE 1 ENABLE OF oDlgMail;
       ACTION If(QDC040TMail(cApel,cEmail),oDlgMail:End(),"")

DEFINE SBUTTON oBtnCancel FROM 043,169 TYPE 2 ENABLE OF oDlgMail;
       ACTION  oDlgMail:End() 

ACTIVATE MSDIALOG oDlgMail CENTERED

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³QC040AtuVar³ Autor ³ Eduardo de Souza     ³ Data ³ 31/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Atualiza Variaveis da tela de email              		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ QC040AtuVar(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Filial do Usuario                                  ³±±
±±³           ³ ExpC2 - Matricula do Usuario                               ³±±
±±³           ³ ExpC3 - Apelido do Usuario                                 ³±±
±±³           ³ ExpC4 - Recebe Email S/N                                   ³±±
±±³           ³ ExpC5 - Email do Usuario                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOC040                               		               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QC040AtuVar(cFil,cMat,cApel,cEmail,oApel,oEmail)

Local nOrdQAA:= QAA->(IndexOrd())
Local nPosQAA:= QAA->(RecNo())
Local lRet   := .T.

DbSelectArea("QAA")
DbSetOrder(1)
If !Empty(cMat)
	If QAA->(DbSeek(cFil+cMat))
		cApel:= QAA->QAA_APELID
		If !Empty(QAA->QAA_EMAIL)
			If Empty(cEmail)
				cEmail:= Alltrim(QAA->QAA_EMAIL)
			Else
				cEmail+= ";"+Alltrim(QAA->QAA_EMAIL)
			EndIf
			oEmail:Refresh()
		Else
			cApel:= " "
			Help(" ",1,"QDC20USR") // "Usuario nao possui e-mail cadastrado"
			lRet:= .F.
		EndIf
	Else
		cApel:= " "
		Help(" ",1,"QD050FNE") // "Funcionario nao existe"
		lRet:= .F.
	EndIf
Else
	cApel:= " "
EndIf

oApel:Refresh()

QAA->(DbSetOrder(nOrdQAA))
QAA->(DbGoto(nPosQAA))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³QDC040TMail³ Autor ³ Eduardo de Souza     ³ Data ³ 31/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Envia email com Lista Mestra                     		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ QDC040TMail(ExpC1,ExpC2,ExpC3)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ ExpC1 - Apelido do Usuario                                 ³±±
±±³           ³ ExpC2 - Email do Usuario                                   ³±±
±±³           ³ ExpC3 - Recebe Email S/N                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOC040                              			           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDC040TMail(cApelido,cEmail)  

Local cSubject:= ""
Local cMsg    := ""
Local cAttach := ""
Local aMsg    := {}
Local aUsrMail:= {}
Local aUsrMat := QA_USUARIO()
Local cMatFil := aUsrMat[2]
Local cMatCod := aUsrMat[3]
Local cMatDep := aUsrMat[4]
Local lRet    := .T.

Private Inclui:= .F.

If !Empty(cEMail)
	If File(cQPathTrm+"MESTRA.HTM")
		CpyT2S(cQPathTrm+"MESTRA.HTM",cQPath,.T.)
		cAttach:= cQPath+"MESTRA.HTM"
		cSubject := OemToAnsi(STR0004)+" - "+DTOC(dDataBase) // "Lista Mestra Completa de Documentos"
		cMsg:= OemToAnsi(STR0020)+" "+OemToAnsi(STR0004) // "Segue Anexo" ### "Lista Mestra Completa de Documentos"
		cMsg+= CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cMsg+= OemToAnsi(STR0024)+CHR(13)+CHR(10) //"Atenciosamente"
		cMsg+= Alltrim(QA_NUSR(cMatFil,cMatCod))+CHR(13)+CHR(10)
		cMsg+= Alltrim(QA_NDEPT(cMatDep))+CHR(13)+CHR(10)
		aMsg:= {{cSubject,cMsg,cAttach}}
		AADD(aUsrMail,{ AllTrim(cApelido),Trim(cEmail),aMsg })
		QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
	Else
		Help(" ",1,"QC40Attach") // "Lista Mestra nao encontrada no Diretorio especificado no parameteroe MV_QPATHWT"
	EndIf
Else
	Help(" ",1,"QDC40Mail") // "E-Mail preenchimento Obrigatorio"
	lRet:= .F.
EndIf

Return lRet
