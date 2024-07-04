#INCLUDE "pcoxgex.ch"
#Define BMP_ON  "LBOK"
#Define BMP_OFF "LBNO"

#INCLUDE "PROTHEUS.CH"


STATIC oPCO_CO
STATIC cEofF3AKO  := ''
STATIC cBofF3AKO  := ''

STATIC  _oPCOXGEX1

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOAKZPLAN³ Autor ³ Edson Maricate        ³ Data ³ 28-11-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de montagem da tela de planilha orcamentaria        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PCOAKZPLAN(cTitle,aCampos,cArquivo,lConfirma,aMenu,oDlg,bChange,lUser,lVisual,cFiltro, aPeriodo)

Local nx
Local nNivelMax
Local nTop      := oMainWnd:nTop+35
Local nLeft     := oMainWnd:nLeft+10
Local nBottom   := oMainWnd:nBottom-12
Local nRight    := oMainWnd:nRight-10

Local aAKQLoad		:= {}
Local aExpand		:= {}
Local aFolder		:= {STR0001} //"Itens"
Local aSVAlias		:= {}
Local aEnch[3]
Local nOldEnch	:= 1

Local oBrowse
Local oAll		:= 	LoadBitmap( GetResources(), "PMSEXPALL" )
Local oCmp		:= 	LoadBitmap( GetResources(), "PMSEXPCMP" )
Local oMenos	:= 	LoadBitmap( GetResources(), "PMSMENOS" )
Local oMais		:=	LoadBitmap( GetResources(), "PMSMAIS" )
Local ny
Local aRecNoVisible := {}
Local lEdit := .F.  
Local aButtons := {}

Local oBar	

DEFAULT aCampos	:= {{"AKO_DESCRI","AKO_DESCRI",55,,,.F.,"",220},{"AKO_CO","AKO_CO",55,,,.F.,"",50}}
DEFAULT bChange := {|| Nil }
DEFAULT lUser	:= .F.
DEFAULT lVisual	:= .F.

PRIVATE bRefresh	:= {|| (PCOVisAtuPlan(cArquivo,If(lUser,12000,If(TMPAK1->AK1_NMAX>0,TMPAK1->AK1_NMAX,1)),aExpand,,lUser,cFiltro),oBrowse:Refresh()) }
PRIVATE bRefreshAll	:= {|| (PCOVisAtuPlan(cArquivo,If(lUser,12000,If(TMPAK1->AK1_NMAX>0,TMPAK1->AK1_NMAX,1)),,,lUser,cFiltro),oBrowse:Refresh()) }
PRIVATE aStru		:= {}
PRIVATE aAuxCps		:= aClone(aCampos)
PRIVATE aHeaderAK2	:= {}
PRIVATE aCamposAK2	:= {}
PRIVATE aHeaderPer	:= {}
PRIVATE aColsAK2	:= {}
PRIVATE oGD[2]
PRIVATE oFolder
PRIVATE oEdit
PRIVATE cArquivx := cArquivo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AK2                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AK2")
While !EOF() .And. (x3_arquivo == "AK2")
	IF (X3USO(x3_usado) .AND. cNivel >= x3_nivel) .Or. (X3_CAMPO$"AK2_ORCAME|AK2_VERSAO|AK2_CO    ")
	If AllTrim(X3_CAMPO) = "AK2_CHAVE" 
		AADD(aHeaderAK2,{ 	"",;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							0,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							SX3->X3_CBOX,;
							SX3->X3_RELACAO,;
							SX3->X3_WHEN})
	Else
		AADD(aHeaderAK2,{ 	TRIM(x3titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							SX3->X3_CBOX,;
							SX3->X3_RELACAO,;
							SX3->X3_WHEN})
		AADD(aCamposAK2, aHeaderAK2[Len(aHeaderAK2)][2])							
	EndIf

	Endif
	dbSkip()
End

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("AK2_VAL")
Do Case 
	Case TMPAK1->AK1_TPPERI == "1"
		dIni := TMPAK1->AK1_INIPER
		If DOW(TMPAK1->AK1_INIPER)<>1
			dIni -= DOW(TMPAK1->AK1_INIPER)-1
		EndIf
	Case TMPAK1->AK1_TPPERI == "2"
		If DAY(TMPAK1->AK1_INIPER) <= 15
			dIni := FirstDay(TMPAK1->AK1_INIPER)
		Else
			dDataIni := CTOD("16/"+Str(Month(TMPAK1->AK1_INIPER),2,0)+"/"+Str(Year(TMPAK1->AK1_INIPER),4,0))
		EndIf
	Case TMPAK1->AK1_TPPERI == "4"
		dIni := CTOD("01/"+Str((Round(MONTH(TMPAK1->AK1_INIPER)/2,0)*2)-1,2,0)+"/"+Str(Year(TMPAK1->AK1_INIPER),4,0))
	Case TMPAK1->AK1_TPPERI == "5"
		dIni := CTOD("01/"+Str((Round(MONTH(TMPAK1->AK1_INIPER)/6,0)*6)-5,2,0)+"/"+Str(Year(TMPAK1->AK1_INIPER),4,0))
	Case TMPAK1->AK1_TPPERI == "6"
		dIni := CTOD("01/01/"+Str(Year(TMPAK1->AK1_INIPER),4,0))	
	OtherWise
		dIni	:= CTOD("01/"+StrZero(MONTH(TMPAK1->AK1_INIPER),2,0)+"/"+StrZero(YEAR(TMPAK1->AK1_INIPER),4,0))
EndCase
dx := dIni
While dx < TMPAK1->AK1_FIMPER
	AADD(aHeaderAK2,{ DTOC(dx),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_F3,;
						SX3->X3_CONTEXT,;
						SX3->X3_CBOX,;
						SX3->X3_RELACAO,;
						SX3->X3_WHEN})
	aAdd(aHeaderPer, aClone(aHeaderAK2[Len(aHeaderAK2)]))						
	Do Case 
		Case TMPAK1->AK1_TPPERI == "1"
			dx += 7
		Case TMPAK1->AK1_TPPERI == "2"
			If DAY(dx) == 01
				dx	:= CTOD("15/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			Else
				dx += 35
				dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			EndIf
		Case TMPAK1->AK1_TPPERI == "3"
			dx += 35
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		Case TMPAK1->AK1_TPPERI == "4"
			dx += 62
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		Case TMPAK1->AK1_TPPERI == "5"
			dx += 185
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		Case TMPAK1->AK1_TPPERI == "6"
			dx += 370
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
	EndCase
	aHeaderAK2[Len(aHeaderAK2)][1] += "  -  "+DTOC(dx-1)
	aHeaderPer[Len(aHeaderPer)][1] += "  -  "+DTOC(dx-1)

End


aadd(aColsAK2,Array(Len(aHeaderAK2)+1))
For ny := 1 to Len(aHeaderAK2)
	If AllTrim(aHeaderAK2[ny][2])=="AK2_ID"
		aColsAK2[1][ny] := StrZero(1,LEN(TMPAK2->AK2_ID))
	Else
		aColsAK2[1][ny] := CriaVar(aHeaderAK2[ny][2])
	EndIf
Next ny
aColsAK2[1][Len(aHeaderAK2)+1] := .F.

For nx := 1 to Len(aCampos)
	dbSelectArea("SX3")
	dbSetOrder(2)
	If MsSeek(aCampos[nx][1])
		aAdd(aStru,{"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)),X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		If aCampos[nx][6]
			aAdd(aAlter,"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)))
		EndIf		
	ElseIf Substr(aCampos[nx][1],1,1) == "$"
		aAdd(aStru,aClone(&(Substr(aCampos[nx][1],2,Len(aCampos[nx][1])-1)+"(1)")))
	ElseIf Substr(aCampos[nx][1],1,1) == "%"
		aAdd(aStru,{"FORM"+StrZero(nx,2,0),Substr(aCampos[nx][1],15,1),Val(Substr(aCampos[nx][1],17,2)),Val(Substr(aCampos[nx][1],20,2))})
	EndIf
Next
aAdd(aStru,{"CTRLNIV","C",1,0})
aAdd(aStru,{"L_I_XO","C",1,0})
aAdd(aStru,{"ALIAS","C",6,0})
aAdd(aStru,{"RECNO","N",14,0})
aAdd(aStru,{"FLAG","L",1,0})

If _oPCOXGEX1 <> Nil
	_oPCOXGEX1:Delete()
	_oPCOXGEX1:= Nil
Endif

If Empty(cArquivo)
	cArquivo := CriaTrab(.F.,Nil)
EndIf

_oPCOXGEX1 := FWTemporaryTable():New(cArquivo)
_oPCOXGEX1:SetFields( aStru )

_oPCOXGEX1:AddIndex("1", {"RECNO"})	
_oPCOXGEX1:Create()

nNivelMax := PCOVisAtuPlan(cArquivo,If(lUser,12000,If(TMPAK1->AK1_NMAX>0,TMPAK1->AK1_NMAX,1)),aExpand,,lUser,cFiltro)

DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
DEFINE MSDIALOG oDlg TITLE cTitle OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight 
oDlg:lMaximized := .T.

For nx := 1 to Len(aMenu)
	oBtn := TBtnBmp():NewBar( aMenu[nx][3],aMenu[nx][3],,,aMenu[nx][1], aMenu[nx][2],.T.,oBar,,,aMenu[nx][1])
	oBtn:cTitle := aMenu[nx][4]
Next

oPanel3 := TPanel():New(14,182,'',oDlg, oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-212,((oDLg:nBottom-oDLg:nTop)/2)-120,.T.,.T. )
oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
lOneColumn := If((nRight-nLeft)/2-178>312,.F.,.T.)

aAdd(aSVAlias,"AKO"+Space(3))
aEnch[1]:= MsMGet():New("AKO",AKO->(RecNo()),2,,,,,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},,3,,,,oPanel3,,,lOneColumn)
aEnch[1]:oBox:Align := CONTROL_ALIGN_ALLCLIENT

aAdd(aSVAlias,"TMPAK1")
//para carregar as variaveis de memoria para ser utilizada a MSMGET AK1
For nX := 1 TO AK1->(FCOUNT())
	cAux := AK1->(FieldName(nX))
	&("M->"+cAux) := TMPAK1->(FieldGet(nX))
Next
//foi utilizado msmget AK1 pois depende do dicionario
aEnch[2]:= MsMGet():New("AK1",AK1->(RecNo()),2,,,,,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},,3,,,,oPanel3,,.T.,lOneColumn)
aEnch[2]:oBox:Align := CONTROL_ALIGN_ALLCLIENT

dbSelectArea(cArquivo)
dbGotop()
nAlias	:= Select()
oBrowse := TcBrowse():New( 23, 1,200, 120, , , , oDlg,,,,,{|| If(!Empty((cArquivo)->CTRLNIV),(PcoVisPlnExp(cArquivo,aExpand,@nNivelMax),PCOVisAtuPlan(cArquivo,@nNivelMax,aExpand,,lUser,cFiltro),oBrowse:Refresh()),NIL) },,oFont,,,,, .F.,cArquivo, .T.,, .F., , ,.f. )
oBrowse:bChange := {|| oBrowse:nColPos := 1, If(lUser,Nil,(AKO->(MsUnlockAll()),PcoVisChgFld(oFolder:nOption,oFolder:nOption,oFolder,aAKQLoad,cArquivo),(aRecNoVisible:={},VisPlanIt(cArquivo,oGD,aRecNoVisible)),oGD:lInsert := .F.,oGD:lUpdate := .F.,oGD:lDelete := .F.)),PcoDlgView(cArquivo,@aSVAlias,@aEnch,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},@nOldEnch,@oPanel3),Eval(bChange)}
oBrowse:bLostFocus := {||If(lUser,NIL,(oEdit:bWhen := {||.F.}))}

oBrowse:Align := CONTROL_ALIGN_LEFT
oBrowse:AddColumn( TCColumn():New( "",{ || If((cArquivo)->CTRLNIV=="-",oMenos,If((cArquivo)->CTRLNIV=="+",oMais,If((cArquivo)->CTRLNIV=="*",oAll,If((cArquivo)->CTRLNIV=="!",oCmp,Nil) )))},,,,"LEFT" , 15, .T., .F.,,,, .F., ))
oBrowse:AddColumn( TCColumn():New( "",{ || PcoVisRes((cArquivo)->ALIAS,(cArquivo)->RECNO ) },,,, "LEFT", 15, .T., .F.,,,, .T., ))

For nx := 1 to Len(aCampos)
	If Substr(aCampos[nx][1],1,1)=="$"
		aAuxRet := &(Substr(aCampos[nx][1],2,Len(aCampos[nx][1])-1)+"(2)")
		oBrowse:AddColumn( TCColumn():New( aAuxRet[1], FieldWBlock( aAuxRet[2] , nAlias ),AllTrim(aAuxRet[3]),,, if(aAuxRet[5]=="N","RIGHT","LEFT"), If(aCampos[nx][8]!=Nil,aCampos[nx][8],If(aAuxRet[4]>Len(aAuxRet[1]),(aAuxRet[4]*3),(LEN(aAuxRet[1])*3))), .F., .F.,,,, .F., ) )
	ElseIf Substr(aCampos[nx][1],1,1)=="%"
		oBrowse:AddColumn( TCColumn():New( Trim(Substr(aCampos[nx][1],2,12)), FieldWBlock( "FORM"+StrZero(nx,2,0) , nAlias ) ,Substr(aCampos[nx][1],22,35),,, if(Substr(aCampos[nx][1],15,1)=="N","RIGHT","LEFT"), If(Val(Substr(aCampos[nx][1],17,2))>Len(AllTrim(Substr(aCampos[nx][1],2,12))),(Val(Substr(aCampos[nx][1],17,2))*3),(Len(AllTrim(Substr(aCampos[nx][1],2,12)))*3)), .F., .F.,,,, .F., ) )
	Else
		dbSelectArea("SX3")
		dbSetOrder(2)
		If MsSeek(aCampos[nx][1])
			oBrowse:AddColumn( TCColumn():New( Trim(x3titulo()), FieldWBlock( "X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)), nAlias ),AllTrim(X3_PICTURE),,, if(X3_TIPO=="N","RIGHT","LEFT"), If(aCampos[nx][8]!=Nil,aCampos[nx][8],If(X3_TAMANHO>Len(X3_TITULO),(X3_TAMANHO*3),(LEN(X3_TITULO)*3))), .F., .F.,,,, .F., ) )
		EndIf
	EndIf
Next
oBrowse:AddColumn( TCColumn():New( "",{|| " " },,,, "LEFT", 5, .T., .F.,,,, .T., ))
dbSelectArea(cArquivo)
oBrowse:Refresh()

If !lUser
	dbSelecTArea("AKQ")
	dbSeek(xFilial())
	While !Eof() .And. AKQ_FILIAL==xFilial("AKQ")
		aAdd(aFolder,AllTrim(AKQ_DESCRI))
		aAdd(aAKQLoad,AKQ->(RecNo()))
		dbSkip()
	End
	
	oFolder := TFolder():New(121,2,aFolder,{},oDlg,,,, .T., .T.,390,110)
	oFolder:bSetOption := {|nDst| PcoVisChgFld(nDst,oFolder:nOption,oFolder,aAKQLoad,cArquivo)}
	oFolder:Align := CONTROL_ALIGN_BOTTOM
	
	oFolder:aDialogs[1]:oFont := oDlg:oFont
	oPanel := TPanel():New(1,1,'',oFolder:aDialogs[1],oDlg:oFont, .T., .T.,, ,20,20,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP
	If lVisual
		oPanel:Hide()
	EndIf
	@ 6,00 BUTTON oEdit Prompt STR0004 SIZE 35 ,9  FONT oDlg:oFont ACTION (VisEdItem(cArquivo, aHeaderPer, oGd, @lConfirma),; //"Editar"
										If(ValType(lConfirma)=="L" .And. lConfirma .And. ;
											(Aviso(STR0005, STR0006, {STR0007,STR0008}, 2) == 1),; //"Atencao"###"Foram efetuadas alteracoes nos itens orcamentarios que nao estao contemplados nesta visao. Atualizar ?"###"Sim"###"Nao"
											oDlg:End(),;
											NIL)) OF oPanel PIXEL WHEN .F.
	
	oGD:= MsNewGetDados():New(2,2,2,2,,"VisxGD1LinOK","VisxGD1TudOK","+AK2_ID",/*aalter*/,2,400,/*fieldok*/,/*superdel*/,/*delok*/,oFolder:aDialogs[1],aHeaderAK2,aColsAK2)
	oGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGD:oBrowse:bGotFocus := {|| oEdit:bWhen := {||.T.}	}
	
EndIf

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(lConfirma:=.T.,oDlg:End())},{|| lConfirma:=.F.,AKO->(MsUnlockAll()),oDlg:End() },,aMenu)	

dbSelectArea(cArquivo)
dbCloseArea()

If _oPCOXGEX1 <> Nil
	_oPCOXGEX1:Delete()
	_oPCOXGEX1:= Nil
Endif

Return lConfirma

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoVisPlnExp³ Autor ³ Edson Maricate      ³ Data ³ 05-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Expansao/Compressao da planilha orcamentaria        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVisPlnExp(cArquivo,aExpand,nNivelMax)
Local nPos

If !Empty(aExpand).And. (nPos:=aScan(aExpand,{|x|x[1]==(cArquivo)->ALIAS+(cArquivo)->XKO_CO})) >0
	If (cArquivo)->CTRLNIV == "-"
		aExpand[nPos][2] := .F.
	ElseIf (cArquivo)->CTRLNIV == "+"
		aExpand[nPos][2] := .T.
	ElseIf (cArquivo)->CTRLNIV == "*"
		nNivelMax := 2000
		aExpand := {}
		dbSelectArea(cArquivo)
		dbGotop()
		Zap
		Pack
	ElseIf (cArquivo)->CTRLNIV == "!"
		nNivelMax := 1
		aExpand := {}
		dbSelectArea(cArquivo)
		dbGotop()
		Zap
		Pack
	EndIf
Else
	If (cArquivo)->CTRLNIV == "-"
		aAdd(aExpand,{(cArquivo)->ALIAS+(cArquivo)->XKO_CO,.F.})
	ElseIf (cArquivo)->CTRLNIV == "+"
		aAdd(aExpand,{(cArquivo)->ALIAS+(cArquivo)->XKO_CO,.T.})	
	ElseIf (cArquivo)->CTRLNIV == "*"
		nNivelMax := 2000
		aExpand := {}		
		dbSelectArea(cArquivo)
		dbGotop()
		Zap
		Pack
	ElseIf (cArquivo)->CTRLNIV == "!"
		nNivelMax := 1
		aExpand := {}
		dbSelectArea(cArquivo)
		dbGotop()
		Zap
		Pack
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoVisRes³ Autor ³ Edson Maricate         ³ Data ³ 05-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de retorno do bitmap da planilha orcamentaria          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVisRes(cAlias,nRecNo,lString)
Local oRet

DEFAULT lString := .F.

// corrige o erro quando
// a linha do projeto esta
// selecionada e foi selecionada
// a impressao
//
// correcao temporaria, necessario
// descobrir a origem do problema
If AllTrim(cAlias)==""
	Return
EndIf

If oPCO_CO==Nil
	oPCO_CO := LoadBitmap( GetResources(), "MDIVISIO" )
EndIf

dbSelectArea(cAlias)
dbGoto(nRecNo)
If lString
	Do Case
		Case Trim(cAlias) $ "AKO/TMPAK1"
			oRet := "PCO_CO"
	EndCase
Else
	Do Case
		Case Trim(cAlias) $ "AKO/TMPAK1"
			oRet := oPCO_CO
	EndCase
EndIf

Return oRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoVisAtuPlan³ Autor ³ Edson Maricate     ³ Data ³ 05-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao do arquivo de trabalho.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVisAtuPlan(cArquivo,nNivelMax,aExpand,lZap,lUser,cFiltro)

Local nNivelAtu := 1
Local aArea		:= GetArea()
Local aAreaTmp
Local aProcForm
Local nCount
Local nx
Local ny

DEFAULT nNivelMax	:= 10000
DEFAULT lZap		:= .T.

                      
dbSelectArea(cArquivo)
aAreaTmp	:= GetArea()
If LastRec() > 0 
	nNivelMax := 10000
EndIf
dbGotop()
If lZap
	Zap
	Pack
EndIf

RecLock(cArquivo,.T.)
(cArquivo)->XKO_CO := TMPAK1->AK1_CODIGO
(cArquivo)->XKO_DESCRI := TMPAK1->AK1_DESCRI
(cArquivo)->RECNO := TMPAK1->(RecNo())
(cArquivo)->ALIAS := "TMPAK1"
AKO->(dbSetOrder(3))
If AKO->(MsSeek(xFilial()+PadR(TMPAK1->AK1_CODIGO,Len(AKN->AKN_CODIGO))+"001"))
	aProcForm	:= {}
	For nx := 1 to Len(aAuxCps)
		If aAuxCps[nx][1]=="AKO_DESCRI"
			FieldPut(FieldPos("X"+Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),SPACE((VAL(AKO->AKO_NIVEL)-1)*5)+AKO->(FieldGet(FieldPos(aAuxCps[nx][2]))))
		ElseIf Substr(aAuxCps[nx][1],1,1)=="%"
			aAdd(aProcForm,nx)
		Else
			If Substr(aAuxCps[nx][1],1,1)=="$"
				FieldPut(FieldPos(Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),&(Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)+"(3,'AKO',AKO->(RecNo()))"))
			Else
				If Substr(aAuxCps[nx][1],1,1)!="|"
					If AKO->(FieldPos(aAuxCps[nx][2])) > 0
						FieldPut(FieldPos("X"+Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),AKO->(FieldGet(FieldPos(aAuxCps[nx][2]))))
					Endif
				EndIf
			Endif
		EndIf
	Next

	For nx := 1 to Len(aProcForm)
		nCntLet := 0
		nCount := 0
			
		For ny := 1 to Len(aAuxCps)
			If Substr(aAuxCps[ny][1], 1, 1) # "|"
				nCntLet++
				If nCntLet > 26
					nCntLet	:= 1
					nCount++
				EndIf
				If nCount > 0
					If Upper(AllTrim((cArquivo)->(FieldName(1))))=="CTRLNIV"
						&(Chr(64+nCntLet)+Chr(48+nCount)) := (cArquivo)->(FieldGet(ny+1))
					Else
						&(Chr(64+nCntLet)+Chr(48+nCount)) := (cArquivo)->(FieldGet(ny))
					EndIf
				Else
					If Upper(AllTrim((cArquivo)->(FieldName(1))))=="CTRLNIV"
						&(Chr(64+nCntLet)) := (cArquivo)->(FieldGet(ny+1))
					Else
						&(Chr(64+nCntLet)) := (cArquivo)->(FieldGet(ny))
					EndIf
				EndIf
			EndIf
		Next
		
		If RepVar(@cBlock, Substr(aAuxCps[aProcForm[nx]][1],58,60))==-1
			HELP("  ",1,"PCOERROCPO",,Substr(aAuxCps[aProcForm[nx]][1],2,12)+"="+cBlock)
			MsUnlock()
			Return			
		EndIf

		Begin Sequence
			FieldPut(FieldPos("FORM"+StrZero(aProcForm[nx],2,0)), &(cBlock))

			// recalcula as formulas anteriores (somente as formulas)
			// este recalculo e necessario para formulas que utilizam
			// formulas ainda nao calculadas

			// o recalculo deve ser feito apos o calculo da formula atual
			cBlock := ""
			nCntLet := 0
			nCount := 0
	
			For ny := 1 to Len(aAuxCps)
				If Substr(aAuxCps[ny][1], 1, 1) # "|"
					nCntLet++
					If nCntLet > 26
						nCntLet	:= 1
						nCount++
					EndIf
          
					If Substr(aAuxCps[ny][1],1,1)=="%"
						If RepVar(@cBlock, Substr(aAuxCps[ny][1],58,60))==-1
							HELP("  ",1,"PCOERROCPO",,Substr(aAuxCps[ny][1],2,12)+"="+cBlock)
							MsUnlock()
							Return			
						EndIf
					Else
						Loop
					EndIf								

					If nCount > 0
						&(Chr(64+nCntLet)+Chr(48+nCount)) := &(cBlock)
					Else
						&(Chr(64+nCntLet)) := &(cBlock)
					EndIf
						
					FieldPut(FieldPos("FORM"+StrZero(ny,2,0)), &(cBlock))
				EndIf
			Next		
		Recover
			MsUnlock()
			ErrorBlock(bBlock)
			Return
		End Sequence
	Next
EndIf
If nNivelMax <> 2000
	(cArquivo)->CTRLNIV	:= "*"
Else
	(cArquivo)->CTRLNIV	:= "!"
EndIf
MsUnlock()

If aExpand != Nil
	aAdd(aExpand,{(cArquivo)->ALIAS+(cArquivo)->XKO_CO,.T.})	
EndIf

dbSelectArea("AKO")
dbSetOrder(3)
MsSeek(xFilial()+PadR(TMPAK1->AK1_CODIGO,Len(AKN->AKN_CODIGO))+"001")
While !Eof() .And. 	AKO_FILIAL+AKO_CODIGO+AKO_NIVEL==;
					xFilial("AKO")+PadR(TMPAK1->AK1_CODIGO,Len(AKN->AKN_CODIGO))+"001"
	PcoVisAddPlan(AKO_CODIGO,AKO_CO,cArquivo,@nNivelAtu,@nNivelMax,@aExpand,lUser,cFiltro)
	dbSelectArea("AKO")
	dbSkip()
End


RestArea(aAreaTmp)
RestArea(aArea)

Return nNivelAtu

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoVisAddPlan³ Autor ³ Edson Maricate     ³ Data ³ 05-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao do arquivo de trabalho.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVisAddPlan(cOrcame,cCO,cArquivo,nNivelAtu,nNivelMax,aExpand,lUser,cFiltro)

Local aArea		:= GetArea()
Local aAreaAKO	:= AKO->(GetArea())
Local bBlock	:= ErrorBlock()
Local aProcForm	:= {}, cBlock := ""
Local nx
Local ny
Local lFilho	:= .F.
Local lHaveStr	:= .F.
Local aRecPai	
	
If nNivelMax >= Val(AKO->AKO_NIVEL) .And. AKO->(&(cFiltro))
	If Val(AKO->AKO_NIVEL)+1 > nNivelAtu
		nNivelAtu := Val(AKO->AKO_NIVEL)+1
	EndIf
	RecLock(cArquivo,.T.)
	aProcForm	:= {}	
	For nx := 1 to Len(aAuxCps)
		If aAuxCps[nx][1]=="AKO_DESCRI"
			If AKO->(FieldPos(aAuxCps[nx][2])) > 0
				FieldPut(FieldPos("X"+Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),SPACE((VAL(AKO->AKO_NIVEL)-1)*5)+AKO->(FieldGet(FieldPos(aAuxCps[nx][2]))))
			Endif
		ElseIf Substr(aAuxCps[nx][1],1,1)=="%"
			aAdd(aProcForm,nx)
		Else
			If Substr(aAuxCps[nx][1],1,1)=="$"
				FieldPut(FieldPos(Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),&(Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)+"(3,'AKO',AKO->(RecNo()))"))
			Else
				If Substr(aAuxCps[nx][1],1,1)!="|"
					If AKO->(FieldPos(aAuxCps[nx][2])) > 0
						FieldPut(FieldPos("X"+Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),AKO->(FieldGet(FieldPos(aAuxCps[nx][2]))))
					Endif
				Endif
			EndIf
		EndIf
	Next

	bErro := ErrorBlock({|e| ChecErro(e)})
	For nx := 1 to Len(aProcForm)
		nCntLet := 0
		nCount := 0				
			
		For ny := 1 to Len(aAuxCps)
			If Substr(aAuxCps[ny][1], 1, 1) # "|"
				nCntLet++
				If nCntLet > 26
					nCntLet	:= 1
					nCount++
				EndIf
				If nCount > 0
					If Upper(AllTrim((cArquivo)->(FieldName(1))))=="CTRLNIV"
						&(Chr(64+nCntLet)+Chr(48+nCount)) := (cArquivo)->(FieldGet(ny+1))
					Else
						&(Chr(64+nCntLet)+Chr(48+nCount)) := (cArquivo)->(FieldGet(ny))
					EndIf
				Else
					If Upper(AllTrim((cArquivo)->(FieldName(1))))=="CTRLNIV"
						&(Chr(64+nCntLet)) := (cArquivo)->(FieldGet(ny+1))
					Else
						&(Chr(64+nCntLet)) := (cArquivo)->(FieldGet(ny))
					EndIf								
				EndIf                                                 
							
			EndIf
		Next

		If RepVar(@cBlock, Substr(aAuxCps[aProcForm[nx]][1],58,60))==-1
			HELP("  ",1,"PCOERROCPO",,Substr(aAuxCps[aProcForm[nx]][1],2,12)+"="+cBlock)
		EndIf

		Begin Sequence
			FieldPut(FieldPos("FORM"+StrZero(aProcForm[nx],2,0)), &(cBlock))
						
			// recalcula as formulas anteriores (somente as formulas)
			// este recalculo e necessario para formulas que utilizam
			// formulas ainda nao calculadas
			// o recalculo deve ser feito apos o calculo da formula atual
			cBlock := ""
			nCntLet := 0
			nCount := 0
				
			For ny := 1 to Len(aAuxCps)
				If Substr(aAuxCps[ny][1], 1, 1) # "|"
					nCntLet++
					If nCntLet > 26
						nCntLet	:= 1
						nCount++
					EndIf
          
					If Substr(aAuxCps[ny][1],1,1)=="%"
						If RepVar(@cBlock, Substr(aAuxCps[ny][1],58,60))==-1
							HELP("  ",1,"PCOERROCPO",,Substr(aAuxCps[ny][1],2,12)+"="+cBlock)
							MsUnlock()
							Return			
						EndIf
					Else
						Loop
					EndIf								
					If nCount > 0
						&(Chr(64+nCntLet)+Chr(48+nCount)) := &(cBlock)
					Else
						&(Chr(64+nCntLet)) := &(cBlock)
					EndIf
						
					FieldPut(FieldPos("FORM"+StrZero(ny,2,0)), &(cBlock))
				EndIf
			Next		
			Recover
			MsUnlock()
			ErrorBlock(bBlock)
			Return
		End Sequence
					//FieldPut(FieldPos("FORM"+StrZero(aProcForm[nx],2,0)),&(cBlock))
	Next
	ErrorBlock(bBlock)
	(cArquivo)->RECNO := AKO->(RecNo())
	(cArquivo)->ALIAS := "AKO"
	MsUnlock()	
	aRecPai := (cArquivo)->(GetArea())	
	RestArea(aRecPai)
EndIf

aRecPai := (cArquivo)->(GetArea())	
dbSelectArea("AKO")
dbSetOrder(2)
MsSeek(xFilial()+cOrcame+cCO)
While !Eof() .And. AKO->AKO_FILIAL+AKO->AKO_CODIGO+AKO->AKO_COPAI==xFilial("AKO")+cOrcame+cCO
	lHaveStr := .T.
	If nNivelMax >= Val(AKO->AKO_NIVEL)
		If aExpand == Nil .Or.Empty(aExpand).Or.(nPosS:=aScan(aExpand,{|x| x[1]==(cArquivo)->ALIAS+cCO} )>0 .And. aExpand[aScan(aExpand,{|x| x[1]==(cArquivo)->ALIAS+cCO} )][2]).Or.(nPosS:=aScan(aExpand,{|x| x[1]==(cArquivo)->ALIAS+cCO} )<=0).Or.nNivelMax<10000
			lFilho := .T.
			PcoVisAddPlan(AKO->AKO_CODIGO,AKO->AKO_CO,cArquivo,@nNivelAtu,@nNivelMax,aExpand,lUser,cFiltro)
		EndIf
	Else
		Exit
	EndIf
	dbSelectArea("AKO")
	dbSkip()
End	
If lHaveStr 
	RestArea(aRecPai)
	If (cArquivo)->ALIAS <>"TMPAK1"
		RecLock(cArquivo,.F.)
		(cArquivo)->CTRLNIV	:= "+"
		MsUnlock()
	EndIf
EndIf
If lFilho
	RestArea(aRecPai)
	If (cArquivo)->ALIAS <>"TMPAK1"
		RecLock(cArquivo,.F.)
		(cArquivo)->CTRLNIV	:= "-"
		MsUnlock()
	EndIf
	If aExpand != Nil
		aAdd(aExpand,{(cArquivo)->ALIAS+(cArquivo)->XKO_CO,.T.})
	EndIf
EndIf

RestArea(aAreaAKO)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VisPlanCl³ Autor ³ Edson Maricate      ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem das celulas da planilha Orcamentaria       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VisPlanCl(cAlias)
Local ny
Default cAlias := "AK2"
For ny := 1 to Len(oGd:aHeader)
	If AllTrim(oGd:aHeader[ny][2])== cAlias + "_VAL"

		aCols[n][ny] := PcoPlanVisCel(0,&("M->" + cAlias + "_CLASSE") )
	EndIf
Next ny


Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPlanVisCel³ Autor ³ Edson Maricate     ³ Data ³ 23-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o conteudo caracter de acordo com as configuracoes    ³±±
±±³          ³de exibicao da classe.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoPlanVisCel(nVal,cClasse,nTamanho,cPicture)
Local cTexto	:= ""
Local aArea		:= GetArea()
Local aAreaAK6	:= AK6->(GetArea())

DEFAULT nVal    := 0
DEFAULT cClasse := "|"
DEFAULT nTamanho:= 30

dbSelectARea("AK6")
dbSetOrder(1)
dbSeek(xFilial()+cClasse)
If AK6->AK6_FORMAT $ "1/3"
	@cPicture := "@E 999999999999"
Else
	@cPicture := "@E 999,999,999,999"
EndIf

If AK6->AK6_DECIMA>0
	@cPicture += "."+Replicate("9",AK6->AK6_DECIMA)
EndIf
cTexto	:= Transform(nVal,cPicture)
If AK6->AK6_FORMAT $ "3/4" .And. nVal < 0
	cTexto := "("+AllTrim(StrTran(cTexto,"-",""))+")"
EndIf
If !Empty(AK6->AK6_SYMBOL)
	cTexto := AK6->AK6_SYMBOL+cTexto
EndIf


RestArea(aAreaAK6)
RestArea(aArea)
Return PadL(cTexto,nTamanho)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VisPlanEdt³ Autor ³ Edson Maricate     ³ Data ³23.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria um Get para edicao da celula da planilha de itens      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VisPlanEdt(oGD)

Local oDlg
Local oRect
Local oGet1
Local oBtn
Local cMacro := ''
Local cPict	:= ''
Local nRow   := oGD:oBrowse:nAt
Local oOwner := oGD:oBrowse:oWnd
Local cValid := 'Eval(bChange)'
Local cClasse, nValor

cClasse	:= M->AK2_CLASSE

If Empty(cClasse)
   Return(.F.)
EndIf   
      
nValor	:= PCOPlanVal(oGD:aCols[n][oGD:oBrowse:nColPos],cClasse)

bChange := { ||  nValor := &cMacro }
oRect := tRect():New(0,0,0,0)            // obtem as coordenadas da celula (lugar onde
oGD:oBrowse:GetCellRect(oGD:oBrowse:nColPos,,oRect)   // a janela de edicao deve ficar)
aDim  := {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

DEFINE MSDIALOG oDlg OF oOwner  FROM 0, 0 TO 0, 0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL

PcoPlanVisCel(0,cClasse,,@cPict)
cMacro := "M->CELL"
&cMacro:= nValor

@ 0,0 MSGET oGet1 VAR &(cMacro) SIZE 0,0 OF oDlg FONT oOwner:oFont PICTURE cPict PIXEL HASBUTTON VALID &cValid
oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) + 4, aDim[ 3 ] - aDim[ 1 ] + 4 )

@ 0,0 BUTTON oBtn PROMPT "ze" SIZE 0,0 OF oDlg
oBtn:bGotFocus := {|| oDlg:nLastKey := VK_RETURN, oDlg:End(0)}

oGet1:cReadVar  := cMacro

ACTIVATE MSDIALOG oDlg ON INIT oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

oGD:aCols[n][oGD:oBrowse:nColPos]	:= PcoPlanVisCel(nValor,cClasse)
oGD:oBrowse:nAt := nRow
SetFocus(oGD:oBrowse:hWnd)
oGD:oBrowse:Refresh()

Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VisPlanIt³ Autor ³ Edson Maricate      ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem dos itens da planilha orcamentaria         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VisPlanIt(cArquivo,oGD,aRecNoVisible)

Local ny
Local aAuxArea	:= {}
Local aArea		:= GetArea()
Local nHeadItem	:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_ID"})
Local aAreaAKO := AKO->(GetArea())
dbSelectArea("AKO")
dbGoto((cArquivo)->RECNO)

oGD:aCols	:= {}

dbSelectArea("TMPAK2")
dbSetOrder(1)
If dbSeek(xFilial("AK2") + TMPAK1->AK1_CODIGO + (cArquivo)->XKO_CO ) 
	While !Eof() .And. TMPAK2->AK2_FILIAL + TMPAK2->AK2_ORCAME + TMPAK2->AK2_CO  == ;
						xFilial("AK2") + TMPAK1->AK1_CODIGO + (cArquivo)->XKO_CO
		nPosIt	:= aScan(oGD:aCols,{|x| x[nHeadItem] == TMPAK2->AK2_ID})
		If nPosIt > 0
			nPosHead := aScan(oGD:aHeader,{|x| CTOD(Substr(x[1],1,10))==TMPAK2->AK2_PERIOD})
			If nPosHead > 0
				oGD:aCols[nPosIt][nPosHead] := PcoPlanVisCel(TMPAK2->AK2_VALOR,TMPAK2->AK2_CLASSE)
			EndIf
		Else
			aADD(oGD:aCols,Array(Len(oGD:aHeader)+1))
			oGD:aCols[Len(oGD:aCols)][Len(oGD:aHeader)+1] := .F.		
			For ny := 1 to Len(oGD:aHeader)
				Do Case
					Case AllTrim(oGD:aHeader[ny][2])=="AK2_VAL"
						nPosHead := aScan(oGD:aHeader,{|x| CTOD(Substr(x[1],1,10))==TMPAK2->AK2_PERIOD})
						If nPosHead > 0
							oGD:aCols[Len(oGD:aCols)][nPosHead] := PcoPlanVisCel(TMPAK2->AK2_VALOR,TMPAK2->AK2_CLASSE)
						EndIf
					Case AllTrim(oGD:aHeader[ny][2])=="AK2_ORCAME" 
						oGD:aCols[Len(oGD:aCols)][ny] := TMPAK2->AK2_ORCORI
					Case AllTrim(oGD:aHeader[ny][2])=="AK2_CO" 
						oGD:aCols[Len(oGD:aCols)][ny] := TMPAK2->AK2_CO_ORI
					Case AllTrim(oGD:aHeader[ny][2])=="AK2_IDENT" 
						If !Empty(TMPAK2->AK2_CHAVE)
							aAuxArea := GetArea()
							AK6->(dbSetOrder(1))
							AK6->(dbSeek(xFilial()+TMPAK2->AK2_CLASSE))
							If !Empty(AK6->AK6_VISUAL)
								dbSelectArea(Substr(TMPAK2->AK2_CHAVE,1,3))
								dbSetOrder(Val(Substr(TMPAK2->AK2_CHAVE,4,2)))
								dbSeek(Substr(TMPAK2->AK2_CHAVE,6,Len(TMPAK2->AK2_CHAVE)))
								oGD:aCols[Len(oGD:aCols)][ny] := &(AK6->AK6_VISUAL)
							EndIf
							RestArea(aAuxArea)
						EndIf
					Case AllTrim(oGD:aHeader[ny][2])=="AK2_DESCLA" 
						aAuxArea := GetArea()
						AK6->(dbSetOrder(1))
						If AK6->(dbSeek(xFilial()+TMPAK2->AK2_CLASSE))
							oGD:aCols[Len(oGD:aCols)][ny] := AK6->AK6_DESCRI
						EndIf	
						RestArea(aAuxArea)
					Case AllTrim(oGD:aHeader[ny][2])=="AK2_UM"
						AK6->(dbSetOrder(1))
						AK6->(dbSeek(xFilial()+TMPAK2->AK2_CLASSE))
						aAuxArea := GetArea()
						If !Empty(AK6->AK6_UM)
							If !Empty(TMPAK2->AK2_CHAVE)
								dbSelectArea(Substr(TMPAK2->AK2_CHAVE,1,3))
								dbSetOrder(Val(Substr(TMPAK2->AK2_CHAVE,4,2)))
								dbSeek(Substr(TMPAK2->AK2_CHAVE,6,Len(TMPAK2->AK2_CHAVE)))
							EndIf
							oGD:aCols[Len(oGD:aCols)][ny] := &(AK6->AK6_UM)
						EndIf
						RestArea(aAuxArea)						
					OtherWise
						If ( oGD:aHeader[ny][10] != "V") 
							oGD:aCols[Len(oGD:aCols)][ny] := FieldGet(FieldPos(oGD:aHeader[ny][2]))
						EndIf   						
				EndCase
			Next
		EndIf
		dbSkip()
	End
EndIf

If Empty(oGD:aCols)
	aadd(oGD:aCols,Array(Len(oGD:aHeader)+1))
	For ny := 1 to Len(oGD:aHeader)
		If AllTrim(oGD:aHeader[ny][2])=="AK2_ID"
			oGD:aCols[1][ny] := StrZero(1,LEN(TMPAK2->AK2_ID))
		Else
			oGD:aCols[1][ny] := CriaVar(oGD:aHeader[ny][2])
		EndIf
	Next ny
	oGD:aCols[1][Len(oGD:aHeader)+1] := .F.
EndIf
oGD:oBrowse:Refresh()

RestArea(aAreaAKO)	
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VisPlanTot³ Autor ³ Edson Maricate     ³ Data ³ 02-09-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem dos totais por clase do CO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VisPlanTot(cArquivo,oGD)

Local ny
Local aAuxArea	:= {}
Local aArea		:= GetArea()
Local nHeadItem	:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_CLASSE"})

oGD:aCols	:= {}

dbSelectArea("TMPAK2")
dbSetOrder(1)
If dbSeek(xFilial("AK2") + TMPAK1->AK1_CODIGO + (cArquivo)->XKO_CO ) 
	While !Eof() .And. TMPAK2->AK2_FILIAL + TMPAK2->AK2_ORCAME + TMPAK2->AK2_CO  == ;
						xFilial("AK2") + TMPAK1->AK1_CODIGO + (cArquivo)->XKO_CO
		nPosIt	:= aScan(oGD:aCols,{|x| x[nHeadItem] == TMPAK2->AK2_CLASSE})
		If nPosIt > 0
			nPosHead := aScan(oGD:aHeader,{|x| CTOD(Substr(x[1],1,10))==TMPAK2->AK2_PERIOD})
			If nPosHead > 0
				If oGD:aCols[nPosIt][nPosHead]<> Nil
					oGD:aCols[nPosIt][nPosHead] := PcoPlanVisCel(TMPAK2->AK2_VALOR+Val(oGD:aCols[nPosIt][nPosHead]),TMPAK2->AK2_CLASSE)
				Else
					oGD:aCols[nPosIt][nPosHead] := PcoPlanVisCel(TMPAK2->AK2_VALOR,TMPAK2->AK2_CLASSE)
				EndIf
			EndIf
		Else
			aADD(oGD:aCols,Array(Len(oGD:aHeader)+1))
			oGD:aCols[Len(oGD:aCols)][Len(oGD:aHeader)+1] := .F.		
			For ny := 1 to Len(oGD:aHeader)
				Do Case
					Case AllTrim(oGD:aHeader[ny][2])=="AK2_VAL"
						nPosHead := aScan(oGD:aHeader,{|x| CTOD(Substr(x[1],1,10))==TMPAK2->AK2_PERIOD})
						If nPosHead > 0
							oGD:aCols[Len(oGD:aCols)][nPosHead] := PcoPlanVisCel(TMPAK2->AK2_VALOR,TMPAK2->AK2_CLASSE)
						EndIf
					OtherWise
						If ( oGD:aHeader[ny][10] != "V") 
							oGD:aCols[Len(oGD:aCols)][ny] := FieldGet(FieldPos(oGD:aHeader[ny][2]))
						EndIf   						
				EndCase
			Next
		EndIf
		dbSkip()
	End
Else
	aadd(oGD:aCols,Array(Len(oGD:aHeader)+1))
	For ny := 1 to Len(oGD:aHeader)
		If AllTrim(oGD:aHeader[ny][2])=="AK2_ID"
			oGD:aCols[1][ny] := StrZero(1,LEN(TMPAK2->AK2_ID))
		Else
			oGD:aCols[1][ny] := CriaVar(oGD:aHeader[ny][2])
		EndIf
	Next ny
	oGD:aCols[1][Len(oGD:aHeader)+1] := .F.
EndIf
oGD:oBrowse:Refresh()
	
RestArea(aArea)
Return


/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³PcoVisAvalAK1³ AUTOR ³ Edson Maricate     ³ DATA ³ 05-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Funcao de gravacao das tabelas auxiliares da planilha orcame-³±±
±±³          ³ taria.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOAVALAK1                                                   ³±±
±±³_DESCRI_  ³ Funcao de gravacao das tabelas auxiliares da planilha orcamen³±±
±±³_DESCRI_  ³ taria.                                                       ³±±
±±³_FUNC_    ³ Esta funcao devera ser utilizada apos a gravacao da tabela   ³±±
±±³          ³ AK1 com a opcao selecionada de acordo com o evento :         ³±±
±±³          ³ [1] :  Inclusao de uma planilha                              ³±±
±±³          ³ [2] :  Estorno  de uma planilha                              ³±±
±±³          ³ [3] :  Exclusao de uma planilha                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpC1 : Alias da tabela de planilhas orcamentarias           ³±±
±±³_PARAMETR_³ ExpN2 : Codigo do evento                                     ³±±
±±³_PARAMETR_³ ExpN2 : Codigo do evento                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVisAvalAK1(cAlias,nEvento,lCriaAKO)
Local aArea 	:= GetArea()
Local aAreaAK1  := TMPAK1->(GetArea())

DEFAULT lCriaAKO := .T.

Do Case
	Case nEvento == 1
		If lCriaAKO
		EndIf
EndCase
RestArea(aAreaAK1)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoVisSetF3³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Configura os parametros de Filtro das consultas F3 para a     ³±±
±±³          ³rotina utilizada.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Codigo da Consulta                                    ³±±
±±³          ³ExpN2 : Opcao                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS, SXB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVisSetF3(cSXB,nOpcao)
Local lRet		:= .T.

Do Case
	Case cSXB == "AKO" .And. nOpcao == 1
		cEofF3AKO := M->AKO_CODIGO
		cBofF3AKO := cEofF3AKO
EndCase

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoVisIdentF3³ Autor ³ Edson Maricate     ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de exibicao da consulta padrao referente ao Alias      ³±±
±±³          ³selecionado da classe orcamentaria.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVisIdentF3(cAlias)

Local aArea	:= GetArea()
Local aAreaAK6	:= AK6->(GetArea())

Local nPosClasse
Local nPosIdent
Local nPosChave

Default cAlias := "AK2"

nPosClasse  := aScan(aHeader,{|x|AllTrim(x[2])== cAlias + "_CLASSE"})
nPosIdent   := aScan(aHeader,{|x|AllTrim(x[2])== cAlias + "_IDENT"})
If cAlias == "AKD"
	nPosChave   := aScan(aHeader,{|x|AllTrim(x[2])== cAlias + "_IDREF"})
Else
	nPosChave   := aScan(aHeader,{|x|AllTrim(x[2])== cAlias + "_CHAVE"})
EndIf

If !Empty(aCols[n][nPosClasse])
	AK6->(dbSetOrder(1))
	If AK6->(dbSeek(xFilial()+aCols[n][nPosClasse])) .And. !Empty(AK6->AK6_ENTIDA)
		If ConPad1( , , , AK6->AK6_ENTIDA , , , .F. )
			aCols[n][nPosIdent] := &(AK6->AK6_VISUAL)
            dbSelectArea(AK6->AK6_ENTIDA)
			dbSetOrder(AK6->AK6_INDICE)
			aCols[n][nPosChave] := AK6->AK6_ENTIDA+Str(AK6->AK6_INDICE,2,0)+&(IndexKey())
		Else
			aCols[n][nPosIdent] := SPACE(LEN(aCols[n][nPosIdent]))
			aCols[n][nPosChave] := SPACE(LEN(aCols[n][nPosChave]))
		EndIf
	EndIf
EndIf


RestArea(aAreaAK6)
RestArea(aArea)
Return .F.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoDlgView³ Autor ³ Edson Maricate        ³ Data ³ 23-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de visualizacao da enchoice da estrutura selecionada.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoDlgView(cArquivo,aSVAlias,aEnch,aPos,nOldEnch,oPanel)

Local aArea		:= GetArea()
Local cAlias	:= (cArquivo)->ALIAS
Local nRecView	:= (cArquivo)->RECNO
Local nPosAlias	:= aScan(aSVAlias,cAlias)
Local lOneColumn:= If(aPos[4]-aPos[2]>312,.F.,.T.)
Local nX, cAux

If nRecView <> 0
	aEnch[nOldEnch]:Hide()
	dbSelectArea(cAlias)
	MsGoto(nRecView)
	If cAlias == "TMPAK1"
	   For nX := 1 TO AK1->(FCOUNT())
	   		cAux := AK1->(FieldName(nX))
	   		&("M->"+cAux) := TMPAK1->(FieldGet(nX))
	   Next
	Else
		RegToMemory(cAlias,.F.)
	EndIf	
	If nPosAlias > 0
		Do Case
			Case cAlias == "AKO"+Space(3)
				aEnch[1]:EnchRefreshAll()
				aEnch[1]:Show()
				nOldEnch:=1
			Case cAlias == "TMPAK1"
				aEnch[2]:EnchRefreshAll()
				aEnch[2]:Show()
				nOldEnch:=2
		EndCase
	EndIf
EndIf
			
RestArea(aArea)
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoAKZFil   ³ Autor ³ Edson Maricate      ³ Data ³ 05-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem do filtro da estrutura do AK1.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAKZFil(cFiltro)

cFiltro := BuildExpr("AKO")

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoAKZPesq   ³ Autor ³ Edson Maricate     ³ Data ³ 05-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de pesquisa na estrutura do orcamento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAKZPesq(cArquivo)

Local aAuxArea	:= (cArquivo)->(GetArea())
Local aParam	:= {}

If ParamBox( { { 1 ,STR0009 ,SPACE(200),"@" 	 ,""  ,""    ,"" ,50 ,.F. },;  //"Pesquisar
				{5,STR0010,.F.,90,,.F.},; //"Utilizar Pesquisa Exata"
				{5,STR0011,.F.,90,,.F.} }, STR0009 ,aParam ) //"Pesquisar Proxima Ocorrencia"###"Pesquisar"
	dbSelectArea(cArquivo)
	If aParam[2]
		If aParam[3]
			dbSkip()
			LOCATE REST FOR ( AllTrim(aParam[1])==XKO_DESCRI) .Or. (AllTrim(aParam[1])==XKO_CO)
		Else
			LOCATE FOR ( AllTrim(aParam[1])==XKO_DESCRI) .Or. (AllTrim(aParam[1])==XKO_CO)
		EndIf
	Else
		If aParam[3]
			dbSkip()
			LOCATE REST FOR ( AllTrim(aParam[1])$XKO_DESCRI) .Or. (AllTrim(aParam[1])$XKO_CO) 
		Else
			LOCATE FOR ( AllTrim(aParam[1])$XKO_DESCRI) .Or. (AllTrim(aParam[1])$XKO_CO) 
		EndIf
	EndIf
EndIf

If !Found()
	RestArea(aAuxArea)
EndIf
Return	


Function PcoVisChgFld(nFldDst,nFldAtu,oFolder,aAKQLoad,cArquivo)
//Local oPanel
Local aArea	:= GetArea()
Local aAreaAKO	:= AKO->(GetArea())
Private oObj
Private aRet
Private nCols	:= 2
Private aCols	:= {}
Private nStyle	:= 1
Private cDescri	:= ""
Private cClrLegend
Private cClrData

If nFldDst > 1
	oObj	:= oFolder:aDialogs[nFldDst]
	MsFreeObj(oFolder:aDialogs[nFldDst],.T.)
	If (cArquivo)->ALIAS=="TMPAK1"
		AKO->(dbSetOrder(1))
		AKO->(dbSeek(xFilial("AKO")+PadR(TMPAK1->AK1_CODIGO, Len(AKO->AKO_CODIGO))+PadR(TMPAK1->AK1_CODIGO, Len(AKO->AKO_CODIGO))))
	EndIf
	AKQ->(dbGoto(aAKQLoad[nFldDst-1]))
	If !Empty(AKQ->AKQ_BLOCK)
		Processa( { || PCOExecForm(AKQ->AKQ_BLOCK) }, STR0005, STR0014 + AllTrim(AKQ->AKQ_DESCRI) )	// Atencao ### Calculando 
		PcoDispBox(aRet,nCols,"",aCols,,nStyle,cClrLegend,cClrData,oFolder:aDialogs[nFldDst],1,1,.T.,cDescri)
	EndIf
EndIf

RestArea(aAreaAKO)
RestArea(aArea)
Return

Function VisRetPer()
Local aRetPer	:= {}
Local dIni
Local dx

Do Case 
	Case TMPAK1->AK1_TPPERI == "1"
		dIni := TMPAK1->AK1_INIPER
		If DOW(TMPAK1->AK1_INIPER)<>1
			dIni -= DOW(TMPAK1->AK1_INIPER)-1
		EndIf
	Case TMPAK1->AK1_TPPERI == "2"
		If DAY(TMPAK1->AK1_INIPER) <= 15
			dIni := FirstDay(TMPAK1->AK1_INIPER)
		Else
			dIni := CTOD("16/"+Str(Month(TMPAK1->AK1_INIPER),2,0)+"/"+Str(Year(TMPAK1->AK1_INIPER),4,0))
		EndIf
	Case TMPAK1->AK1_TPPERI == "4"
		dIni := CTOD("01/"+Str((Round(MONTH(TMPAK1->AK1_INIPER)/2,0)*2)-1,2,0)+"/"+Str(Year(TMPAK1->AK1_INIPER),4,0))
	Case TMPAK1->AK1_TPPERI == "5"
		dIni := CTOD("01/"+Str((Round(MONTH(TMPAK1->AK1_INIPER)/6,0)*6)-5,2,0)+"/"+Str(Year(TMPAK1->AK1_INIPER),4,0))
	Case TMPAK1->AK1_TPPERI == "6"
		dIni := CTOD("01/01/"+Str(Year(TMPAK1->AK1_INIPER),4,0))	
	OtherWise
		dIni	:= CTOD("01/"+StrZero(MONTH(TMPAK1->AK1_INIPER),2,0)+"/"+StrZero(YEAR(TMPAK1->AK1_INIPER),4,0))
EndCase
dx := dIni
While dx < TMPAK1->AK1_FIMPER
	aAdd(aRetPer,DTOC(dx))
	Do Case 
		Case TMPAK1->AK1_TPPERI == "1"
			dx += 7
		Case TMPAK1->AK1_TPPERI == "2"
			If DAY(dx) == 01
				dx	:= CTOD("15/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			Else
				dx += 35
				dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			EndIf
		Case TMPAK1->AK1_TPPERI == "3"
			dx += 35
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		Case TMPAK1->AK1_TPPERI == "4"
			dx += 62
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		Case TMPAK1->AK1_TPPERI == "5"
			dx += 185
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		Case TMPAK1->AK1_TPPERI == "6"
			dx += 370
			dx	:= CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
	EndCase
	aRetPer[Len(aRetPer)] += "  -  "+DTOC(dx-1)
End

Return aRetPer

Static Function VisEdItem(cArquivo, aHeader, oGd, lConfirma)
Local oEnch, oDlg, oBar, oBtn, nOpca := 0, oFolder, oPanel

Local aObjects := {}
Local aPosObj  := {}
Local aSize    := MsAdvSize(.T.)

Local aCols := { ARRAY(Len(aHeaderPer)+1) }
Local lContinua := .T., nX, nY, nZ, cAliasAnt := ALIAS()

Local nHeadItem	:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_ID"})
Local nHeadConta:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_CO"})
Local nHeadPlanilha:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_ORCAME"})
Local nHeadCC	:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_CC"})
Local nHeadItCtb:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_ITCTB"})
Local nHeadClVlr:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_CLVLR"})  
Local nHeadUniOr:= 	0 
Local aNHeadEnts := {}  
Local nQtd 

Local aArea		:= GetArea()
Local aAreaAKO := AKO->(GetArea())
Local aAreaTAK2 := TMPAK2->(GetArea())
Local aAreaAK2 := AK2->(GetArea())
Local aAreaAK3 := AK3->(GetArea())

Local cVerAtu 
Local nPeriodo
Local aAuxArea
Local aRecAK2
Local nPos
Local cPlanilha
Local aCEntids := {}
Local nIndex
Private o_GetDados  
Static nQtdEntid  

// Verifica a existencia da Unidade Orcamentaria
If(AK2->(FieldPos("AK2_UNIORC")) >  0)
	nHeadUniOr := aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_UNIORC"})
EndIf

// Verifica a quantidade de entidades contabeis
If nQtdEntid == NIL
	nQtdEntid := If(FindFunction("CtbQtdEntd"),Iif(cPaisLoc$"RUS",PCOQtdEntd(),CtbQtdEntd()),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

//Se houver novas entidades, inicializa o vetor de entidades
If nQtdEntid > 4
	aNHeadEnts := Array(nQtdEntid)

	for nQtd := 5 To nQtdEntid
		aNHeadEnts[nQtd] := aScan(oGD:aHeader,{|x| AllTrim(x[2])== "AK2_ENT"+STRZERO(nQtd,2)})
	next
EndIf

AADD(aObjects,{100,020,.T.,.F.,.F.})
AADD(aObjects,{100,100,.T.,.T.,.F.})

aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 } 
aPosObj:= MsObjSize( aInfo, aObjects, .T.,.F. )  

dbSelectArea("AKO")
dbGoto((cArquivo)->RECNO)
lContinua := SoftLock("AKO")
cCentroCusto := oGd:aCols[oGd:nAt][nHeadCC]
cItemContabil := oGd:aCols[oGd:nAt][nHeadItCtb]
cClasseValor := oGd:aCols[oGd:nAt][nHeadClVlr]
cPlanilha := oGd:aCols[oGd:nAt][nHeadPlanilha]
cVerAtu	  := PcoVerAtu(cPlanilha)

//Unidade Orcamentaria
If(AK2->(FieldPos("AK2_UNIORC")) >  0)
	cUnidOrc := oGd:aCols[oGd:nAt][nHeadUniOr]
EndIf
	
// Se tiver novas entidades
If nQtdEntid > 4 
	aCEntids := Array(nQtdEntid)
		
	For nQtd := 5 To nQtdEntid
		If cPaisLoc == "RUS"
			nIndex := aNHeadEnts[nQtd]
			If  nIndex >=1
				aCEntids[nQtd] := oGd:aCols[oGd:nAt][nIndex]  
			EndIf
		Else
			aCEntids[nQtd] := oGd:aCols[oGd:nAt][aNHeadEnts[nQtd]]  
		EndIf
	Next
EndIf

For nX := 1 TO Len(aHeader)
	aHeader[nX][13] := "VisPlanEdt(o_GetDados)"  //WHEN DA GETDADOS
Next

If ExistBlock("PCOX1806")
	If lContinua
	    ExecBlock( "PCOX1806", .F., .F. )
	EndIf    
Else
	If lContinua
		dbSelectArea("AK3")
		dbSetOrder(1)
		
		lContinua := dbSeek(xFilial("AK3")+cPlanilha+cVerAtu+oGd:aCols[oGd:nAt][nHeadConta])
	EndIf
		
	dbSelectArea("TMPAK2")
	dbSetOrder(2)
	
	If lContinua .And. dbSeek(xFilial("AK2") + TMPAK1->AK1_CODIGO + (cArquivo)->XKO_CO+oGd:aCols[oGd:nAt][nHeadItem] )
   		If PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,1,"ESTRUT",AK3->AK3_VERSAO) .And. ;
			PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,3,"ITENS",AK3->AK3_VERSAO) .And. ;
			PcoCC_User(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"CCUSTO",cVerAtu,cCentroCusto) .And. ;
			PcoIC_User(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"ITMCTB",cVerAtu,cItemContabil) .And. ;
			PcoCV_User(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"CLAVLR",cVerAtu,cClasseValor) .And. ;
			PcoUserEnts(cUnidOrc, aCEntids)
	
			For nX := 1 TO TMPAK2->(FCOUNT())
				cAux := TMPAK2->(FieldName(nX))
				&("M->"+cAux) := TMPAK2->(FieldGet(nX))
			Next
			//Inverte campos com os de origem da tabela AK2+COG
			M->AK2_ORCAME := TMPAK2->AK2_ORCORI
			M->AK2_CO := TMPAK2->AK2_CO_ORI
			M->AK2_ID := TMPAK2->AK2_ID_ORI
			//inicializa os campos AK2_IDENT / AK2_DESCLA / AK2_UM
			For ny := 1 TO Len(oGd:aHeader)
				Do Case
					Case AllTrim(oGD:aHeader[ny][2])=="AK2_IDENT" 
					M->AK2_IDENT := oGd:aCols[oGd:nAt][ny]
					Case AllTrim(oGD:aHeader[ny][2])=="AK2_DESCLA" 
					M->AK2_DESCLA := oGd:aCols[oGd:nAt][ny]
					Case AllTrim(oGD:aHeader[ny][2])=="AK2_UM"
					M->AK2_UM := oGd:aCols[oGd:nAt][ny]
				EndCase
		    Next
		    //inicializa acols com valor 0 para todos os periodos
		    For nX := 1 TO Len(aHeader)
		    	aCols[Len(aCols)][nX] := PcoPlanVisCel(0,TMPAK2->AK2_CLASSE)
		    Next	
		    //ultimo elemento indica se acols esta deletado
		    aCols[Len(aCols)][Len(aHeader)+1] := .F.
		    aRecAk2 := {}
			While !Eof() .And. TMPAK2->AK2_FILIAL + TMPAK2->AK2_ORCAME + TMPAK2->AK2_CO + TMPAK2->AK2_ID  == ;
							xFilial("AK2") + TMPAK1->AK1_CODIGO + (cArquivo)->XKO_CO+oGd:aCols[oGd:nAt][nHeadItem]
		        //carrega valor original para edicao no acols (no periodo)
		        nPeriodo :=  aScan(aHeader,{|x| CTOD(Substr(x[1],1,10))==TMPAK2->AK2_PERIOD})
		        If nPeriodo > 0
					aCols[Len(aCols)][nPeriodo] := PcoPlanVisCel(TMPAK2->AK2_VLRORI,TMPAK2->AK2_CLASSE)
					aAdd(aRecAK2, {StrZero(nPeriodo,5), TMPAK2->AK2_RECNO})
				EndIf	
	    	dbSkip()
			End
		Else
			HELP("  ",1,"PCONOITEM")
			lContinua := .F.
		EndIf

	Else
		HELP("  ",1,"PCOITEMINV")
		lContinua := .F.
	EndIf
	
	If lContinua	
		DEFINE MSDIALOG oDlg TITLE STR0012 OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5] //"Edicao do Item Orcamentario"
	
		oPanel := TScrollBox():new(oDlg,20,02, 90,200,.T.,.T.,.T.)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
		oEnch := MsMGet():New("AK2",AK2->(RecNo()),2,,,,aCamposAK2,{aSize[1],aSize[2],aSize[3],aSize[4]},,3,,,,oPanel,,.T.,)
		oEnch:oBox:Align := CONTROL_ALIGN_TOP
		
		oFolder := TFolder():New(((oEnch:oBox:nTop+oEnch:oBox:nHeight)/2)+40,2,{STR0013},{},oDlg,,,, .T., .T.,390,080) //"Periodos - Editar"
		oFolder:Align := CONTROL_ALIGN_BOTTOM
		oFolder:aDialogs[1]:oFont := oDlg:oFont
		
		o_GetDados := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],,/*"VisxGD1LinOK"*/,/*"VisxGD1TudOK"*/,/*"+AK2_ID"*/,/*aalter*/,4,400,/*fieldok*/,/*superdel*/,/*delok*/,oFolder:aDialogs[1],aHeaderPer,aCols)
		o_GetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		o_GetDados:lInsert := .F.
		o_GetDados:lUpDate := .T.
		
		ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()},,)
		
		If nOpca == 1
			//inicia lancamento
			PcoIniLan("000252")
			dbSelectArea("AK2")
			For nX := 1 TO Len(o_GetDados:aCols)
				For nY := 1 TO Len(o_GetDados:aCols[nX])-1
					lConfirma := .T.
					If (nPos := Ascan(aRecAK2, {|aVal| aVal[1] == StrZero(nY, 5)})) > 0
						//SOMENTE ALTERACAO DO VALOR DATA TABELA AK2
						dbGoto(aRecAK2[nPos][2])
						PcoDetLan("000252","02","PCOA100")
						RecLock("AK2", .F.)
						AK2->AK2_VALOR	:= PcoPlanVal(o_GetDados:aCols[nX][nY],M->AK2_CLASSE)
						MsUnLock()
						PcoDetLan("000252","01","PCOA100")
					Else
						//INCLUSAO NOVO PERIODO NA TABELA AK2
						RecLock("AK2", .T.)
						For nZ := 1 TO Len(aCamposAK2)
							cCpoAK2 := aCamposAK2[nZ]
							AK2->(&cCpoAK2) := M->(&cCpoAK2)
						Next
						AK2->AK2_FILIAL	:= xFilial("AK2")
						AK2->AK2_PERIOD	:= CTOD(Substr(aHeader[nY][1],1,10))
						AK2->AK2_VALOR	:= PcoPlanVal(o_GetDados:aCols[nX][nY],M->AK2_CLASSE)
						AK2->AK2_DATAI	:= CTOD(Substr(aHeader[nY][1],1,10))
						AK2->AK2_DATAF	:= CTOD(Substr(aHeader[nY][1],14,16))
						MsUnLock()
						PcoDetLan("000252","01","PCOA100")
					EndIf
				Next
			Next
			//finaliza lancamento
			PcoFinLan("000252")
		EndIf
	EndIf
EndIf
		
dbSelectArea("AKO")
AKO->(MsUnlockAll())

RestArea(aAreaAK3)
RestArea(aAreaAK2)
RestArea(aAreaTAK2)
RestArea(aAreaAKO)
RestArea(aArea)
dbSelectArea(cAliasAnt)

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoUserEntºAutor  ³Bruna Paola		 º Data ³  17/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se usuario tem acesso a Unidade Orcamentaria e as  º±±
±±º          ³ novas entidades.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoUserEnts(cUnidOrc, aCEntids)
Local lRet := .T. 
Local nQt 
Local aAreaAK2 := GetArea() 
Static nQtdEntid

/*
 PcoDirEnt_User retorna
0        - sem direito de acesso
1,2 ou 3 - com direito de acesso 
1 - Visualizar
2 - Alterar
3 - Controle Total
*/  


// Verifica a Unidade Orcamentaria se = 0 nao tem acesso
If(AK2->(FieldPos("AK2_UNIORC")) >  0) .And. PcoDirEnt_User("AMF", cUnidOrc, __cUserID, .F.) == 0 
  	lRet := .F.
EndIf

// Verifica a quantidade de entidades contabeis
If nQtdEntid == NIL
	nQtdEntid := If(FindFunction("CtbQtdEntd"),Iif(cPaisLoc$"RUS",PCOQtdEntd(),CtbQtdEntd()),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
EndIf 

// Verificar as novas entidades 
If nQtdEntid > 4 .And. lRet == .T.   

	For nQt := 5 To nQtdEntid 

		dbSelectArea("CT0")
		dbSetOrder(1)
		
		dbSeek(xFilial("CT0")+STRZERO(nQt,2))    
		
		If PcoDirEnt_User(CT0->CT0_ALIAS, aCEntids[nQt], __cUserID, .F., CT0->CT0_ENTIDA) == 0
		   	lRet := .F.
		EndIf
	Next  
EndIf
  
RestArea(aAreaAK2)
Return (lRet)

