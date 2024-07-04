#Include "PCOXGER.CH"
#Define BMP_ON  "LBOK"
#Define BMP_OFF "LBNO"

#INCLUDE "PROTHEUS.CH"


STATIC oPCO_COG
STATIC oPMSUSER
STATIC cEofF3AKO  := ''
STATIC cBofF3AKO  := ''
STATIC aColsVisCopy  := {}

Static _oPCOXGER1

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOAKNPLAN³ Autor ³ Paulo Carnelossi      ³ Data ³ 18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de montagem da tela de Visao Gerencial orcamentaria ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PCOAKNPLAN(cTitle,aCampos,cArquivo,lConfirma,aMenu,oDlg,bChange,lUser,lVisual,cFiltro)

Local nx
Local nNivelMax
Local nTop      := oMainWnd:nTop+35
Local nLeft     := oMainWnd:nLeft+10
Local nBottom   := oMainWnd:nBottom-12
Local nRight    := oMainWnd:nRight-10

Local aAKKLoad		:= {}
Local aExpand		:= {}
Local aFolder		:= {STR0001} //"Itens"
Local aSVAlias		:= {}
Local aEnch[3]
Local nOldEnch	:= 1
Local aButtons := {}

Local oBrowse
Local oAll		:= 	LoadBitmap( GetResources(), "PMSEXPALL" )
Local oCmp		:= 	LoadBitmap( GetResources(), "PMSEXPCMP" )
Local oMenos	:= 	LoadBitmap( GetResources(), "PMSMENOS" )
Local oMais		:=	LoadBitmap( GetResources(), "PMSMAIS" )
Local lEdit := .F.
Local cPicture, nTamanho, nDecimal, cTipo, aTiposCp := {"C","N","L","D"}
Local cBox	   := ""
Local cValid   := ""

DEFAULT aCampos	:= {{"AKO_DESCRI","AKO_DESCRI",55,,,.F.,"",220},{"AKO_CO","AKO_CO",55,,,.F.,"",50}}
DEFAULT bChange := {|| Nil }
DEFAULT lUser	:= .F.
DEFAULT lVisual	:= .F.

PRIVATE lCanFocus	:= .T.
PRIVATE bRefresh	:= {|| ( PCOGerAtuPlan( cArquivo, If( lUser, 12000, If( AKN->AKN_NMAX > 0, AKN->AKN_NMAX, 1 ) ), aExpand,, lUser, cFiltro ), Eval( oBrowse:bChange ), oBrowse:Refresh() ) }
PRIVATE bRefreshAll	:= {|| (PCOGerAtuPlan(cArquivo,If(lUser,12000,If(AKN->AKN_NMAX>0,AKN->AKN_NMAX,1)),,,lUser,cFiltro),oBrowse:Refresh()) }
PRIVATE aStru		:= {}
PRIVATE aAuxCps		:= aClone(aCampos)
PRIVATE aHeaderAKP	:= {}
PRIVATE aColsAKP	:= {}
PRIVATE oGD
PRIVATE oFolder
PRIVATE oCopia, oCola, oEdit, oWrite, oCancel
PRIVATE cArquivx := cArquivo
PRIVATE nRecEdic := 0
PRIVATE nRecPos	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AKP                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AKP")
//campos normais da tabela AKP
While !EOF() .And. (x3_arquivo == "AKP")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .AND. SX3->X3_CAMPO <> "AKP_FILTCL"
		AADD(aHeaderAKP,{ 	TRIM(x3titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							IIF( cPaisLoc == "RUS", TRIM(X3Cbox()), SX3->X3_CBOX),;
							SX3->X3_RELACAO,;
							SX3->X3_WHEN})

	Endif
	dbSkip()
End

//campos VIRTUAIS de acordo com configuracao da visao na grade da tabela AKP
dbSelectArea("SX3")
dbSetOrder(2)

dbSelectArea("AKM")
dbSetOrder(1)
dbSeek(xFilial("AKM")+AKN->AKN_CONFIG)
//campos normais da tabela AKP
While AKM->(!EOF() .And. AKM_FILIAL + AKM_CONFIG == xFilial("AKM")+AKN->AKN_CONFIG)	
	If AllTrim(AKM->AKM_ENTSIS) == "A1H" //Tratamento para tabela Classificadores Receita/Despesa
		For nX := 1 To 3
			If nX == 1
				cPicture := PesqPict("AKM", "AKM_CODTAB")
				nTamanho := TamSx3("AKM_CODTAB")[1]
				nDecimal := TamSx3("AKM_CODTAB")[2]
				cTipo 	 := TamSx3("AKM_CODTAB")[3]
				cBox	 := ""
			ElseIf nX == 2
				cPicture := PesqPict("AKM", "AKM_RADCHV")
				nTamanho := TamSx3("AKM_RADCHV")[1]
				nDecimal := TamSx3("AKM_RADCHV")[2]
				cTipo 	 := TamSx3("AKM_RADCHV")[3]
				cBox	 := ""
			Else
				cPicture := PesqPict("AKP", "AKP_FILTCL")
				nTamanho := TamSx3("AKP_FILTCL")[1]
				nDecimal := TamSx3("AKP_FILTCL")[2]
				cTipo 	 := TamSx3("AKP_FILTCL")[3]
				cBox     := X3CBox()
				cValid	 := "Pertence('1|2')"
			EndIf

			//Adiciona Tabela, Radical e Filtro no Header
			AADD(aHeaderAKP,{ If(nX==1,STR0025, If(nX==2, STR0026, STR0027)) /*"Tabela", "Radical",  "Apl Filt"*/,;
					"AKP_CRF"+AKM->AKM_ITEM+Str(nX,1)/*SX3->X3_CAMPO*/,;
					cPicture/*SX3->X3_PICTURE*/,;
					nTamanho/*SX3->X3_TAMANHO*/,;
					nDecimal/*SX3->X3_DECIMAL*/,;
					cValid/*SX3->X3_VALID*/,;
					""/*SX3->X3_USADO*/,;
					cTipo/*SX3->X3_TIPO*/,;
					If(nX!=3,AKM->AKM_CONPAD,"")/*SX3->X3_F3*/,;
					"V"/*SX3->X3_CONTEXT*/,;
					cBox/*SX3->X3_CBOX*/,;
					If(nX==1, '"'+AKM->AKM_CODTAB+'"', If(nx==2, '"'+AKM->AKM_RADCHV+'"', '"'+"2"+'"'))/*SX3->X3_RELACAO*/,;
					If(nx==3, ".T.", ".F.")/*SX3->X3_WHEN*/,;
					AllTrim(AKM->AKM_ENTSIS)})
		Next nX
	EndIf
		
	If SX3->(!dbSeek(TRIM(AKM->AKM_CPOREF)))
		cPicture := AKM->AKM_PICTUR
		nTamanho := AKM->AKM_TAMANH
		nDecimal := AKM->AKM_DECIMA
		cTipo	 := aTiposCp[Val(AKM->AKM_TIPOCP)]
	Else
		cPicture := SX3->X3_PICTURE
		nTamanho := SX3->X3_TAMANHO
		nDecimal := SX3->X3_DECIMAL
		cTipo    := SX3->X3_TIPO
		If TRIM(AKM->AKM_CPOREF) == "AKE_ORCAME"
			If SX3->(dbSeek("AKE_REVISA"))
				nTamanho += SX3->X3_TAMANHO
			EndIf
		EndIf
	EndIf

	If AKM->AKM_TIPO == "1"
		AADD(aHeaderAKP,{ 	TRIM(AKM->AKM_TITULO),;
						"AKP_CRF"+AKM->AKM_ITEM/*SX3->X3_CAMPO*/,;
						cPicture/*SX3->X3_PICTURE*/,;
						nTamanho/*SX3->X3_TAMANHO*/,;
						nDecimal/*SX3->X3_DECIMAL*/,;
						If(AKM->AKM_CPOREF=="AK1_CODIGO","(M->AKR_ORCAME:=PadR(M->"+"AKP_CRF"+AKM->AKM_ITEM+",Len(AKE->AKE_ORCAME)), .T.)","")/*SX3->X3_VALID*/,;
						""/*SX3->X3_USADO*/,;
						cTipo/*SX3->X3_TIPO*/,;
						AKM->AKM_CONPAD/*SX3->X3_F3*/,;
						"V"/*SX3->X3_CONTEXT*/,;
						""/*SX3->X3_CBOX*/,;
						If(lVisual, "", AKM->AKM_VALINI)/*SX3->X3_RELACAO*/,;
						""/*SX3->X3_WHEN*/})
	Else						
		For nX := 1 TO 2			
			AADD(aHeaderAKP,{ 	TRIM(AKM->AKM_TITULO)+If(nX==1,STR0002, STR0003),; //" De"###" Ate"
							"AKP_CRF"+AKM->AKM_ITEM+Str(nX,1)/*SX3->X3_CAMPO*/,;
							cPicture/*SX3->X3_PICTURE*/,;
							nTamanho/*SX3->X3_TAMANHO*/,;
							nDecimal/*SX3->X3_DECIMAL*/,;
							""/*SX3->X3_VALID*/,;
							""/*SX3->X3_USADO*/,;
							cTipo/*SX3->X3_TIPO*/,;
							AKM->AKM_CONPAD/*SX3->X3_F3*/,;
							"V"/*SX3->X3_CONTEXT*/,;
							""/*SX3->X3_CBOX*/,;
							If(lVisual, "", If(nX==1, AKM->AKM_VALINI, AKM->AKM_VALFIM))/*SX3->X3_RELACAO*/,;
							""/*SX3->X3_WHEN*/})
		Next
	EndIf
	AKM->(dbSkip())
End

//montagem do acols
Preenche_Acols(aColsAKP, aHeaderAKP)

//criacao da estrutura e arquivo temporario
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
aAdd(aStru,{"ALIAS","C",3,0})
aAdd(aStru,{"RECNO","N",14,0})
aAdd(aStru,{"FLAG","L",1,0})

If _oPCOXGER1 <> Nil
	_oPCOXGER1:Delete()
	_oPCOXGER1:= Nil
Endif

//cArquivo		:= GetNextAlias()

_oPCOXGER1 := FWTemporaryTable():New(cArquivo)
_oPCOXGER1:SetFields( aStru )
	
_oPCOXGER1:AddIndex("1", {"L_I_XO"})
_oPCOXGER1:Create()

nNivelMax := PCOGerAtuPlan(cArquivo,If(lUser,12000,If(AKN->AKN_NMAX>0,AKN->AKN_NMAX,1)),aExpand,,lUser,cFiltro)

DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
DEFINE MSDIALOG oDlg TITLE cTitle OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight 
oDlg:lMaximized := .T.

For nx := 1 to Len(aMenu)  
	aAdd( aButtons , aMenu[nX] )	
Next

oPanel3 := TPanel():New(14,182,'',oDlg, oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-212,((oDLg:nBottom-oDLg:nTop)/2)-120,.T.,.T. )
oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
lOneColumn := If((nRight-nLeft)/2-178>312,.F.,.T.)

aAdd(aSVAlias,"AKO")
aEnch[1]:= MsMGet():New("AKO",AKO->(RecNo()),2,,,,,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},,3,,,,oPanel3,,,lOneColumn)
aEnch[1]:oBox:Align := CONTROL_ALIGN_ALLCLIENT

aAdd(aSVAlias,"AKN")
aEnch[2]:= MsMGet():New("AKN",AKN->(RecNo()),2,,,,,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},,3,,,,oPanel3,,,lOneColumn)
aEnch[2]:oBox:Align := CONTROL_ALIGN_ALLCLIENT

dbSelectArea(cArquivo)
dbGotop()
nAlias	:= Select()
oBrowse := TcBrowse():New( 23, 1,200, 120, , , , oDlg,,,,,{|| If(!Empty((cArquivo)->CTRLNIV),(PcoGerPlnExp(cArquivo,aExpand,@nNivelMax),PCOGerAtuPlan(cArquivo,@nNivelMax,aExpand,,lUser,cFiltro),oBrowse:Refresh()),NIL) },,oFont,,,,, .F.,cArquivo, .T., {|| lCanFocus} , .F., , ,.f. )

oBrowse:bChange := {|| If(lUser,Nil,;
						If(PcoVer_Grava(cArquivo, oGD, oBrowse),;
							(AKO->(MsUnlockAll()),PcoGerChgFld(oFolder:nOption,oFolder:nOption,oFolder,aAKKLoad),(PcoGerPlanIt(cArquivo,oGD)),oGD:lInsert := .F.,oGD:lUpdate := .F.,oGD:lDelete := .F.,oWrite:bWhen := {|| .F. },oCancel:bWhen := {|| .F. },PcoDlgView(cArquivo,@aSVAlias,@aEnch,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},@nOldEnch,@oPanel3), Eval(bChange),If(lUser,NIL,Lib_Botao_Edicao(cArquivo,oGD)));
							,NIL);
							)}

oBrowse:bLostFocus := {||If(lUser,NIL,(oCopia:bWhen := {||.F.}, oCola:bWhen := {||.F.}, oEdit:bWhen := {||.F.},Lib_Botao_Edicao(cArquivo,oGD)))}
oBrowse:Align := CONTROL_ALIGN_LEFT
oBrowse:AddColumn( TCColumn():New( "",{ || If((cArquivo)->CTRLNIV=="-",oMenos,If((cArquivo)->CTRLNIV=="+",oMais,If((cArquivo)->CTRLNIV=="*",oAll,If((cArquivo)->CTRLNIV=="!",oCmp,Nil) )))},,,,"LEFT" , 15, .T., .F.,,,, .F., ))
oBrowse:AddColumn( TCColumn():New( "",{ || PcoGerRetRes((cArquivo)->ALIAS,(cArquivo)->RECNO ) },,,, "LEFT", 15, .T., .F.,,,, .T., ))

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
	oFolder := TFolder():New(121,2,aFolder,{},oDlg,,,, .T., .T.,390,110)
	oFolder:bSetOption := {|nDst| PcoGerChgFld(nDst,oFolder:nOption,oFolder,aAKKLoad)}
	oFolder:Align := CONTROL_ALIGN_BOTTOM
	
	oFolder:aDialogs[1]:oFont := oDlg:oFont
	oPanel := TPanel():New(1,1,'',oFolder:aDialogs[1],oDlg:oFont, .T., .T.,, ,20,20,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP
	If lVisual
		oPanel:Hide()
	EndIf
	
	@ 6,005 BUTTON oCopia  Prompt STR0006 SIZE 35 ,9  FONT oDlg:oFont ACTION {|| PcoCopy_aCols(oGd, aColsVisCopy,,.T.) } OF oPanel PIXEL //WHEN .F. //"Copiar"
	@ 6,045 BUTTON oCola   Prompt STR0007 SIZE 35 ,9  FONT oDlg:oFont ACTION {|| nRecEdic := (cArquivo)->(Recno()), PcoVisColar_aCols(oGd, aColsVisCopy)} OF oPanel PIXEL //WHEN .F. //"Colar"
	@ 6,085 BUTTON oEdit   Prompt STR0008 SIZE 35 ,9  FONT oDlg:oFont ACTION {|| (lEdit := It_OrcGer_Lock(cArquivo,oGD)), If(lEdit, (lCanFocus := .F.,oGD:lInsert := .T.,oGD:lUpdate := .T.,oGD:lDelete := .T.,oGD:oBrowse:SetFocus(),oWrite:bWhen := {|| .T. },oCancel:bWhen := {|| .T. },nRecEdic := (cArquivo)->RECNO,AKO->( DBGOTO( nRecEdic ) ), oEdit:bWhen := {||.F.}), .F. )}OF oPanel PIXEL WHEN .F. //"Editar"
	@ 6,125 BUTTON oWrite  Prompt STR0009 SIZE 35 ,9  FONT oDlg:oFont ACTION {|| If(oGD:TudoOk(),(lCanFocus := .T.,PcoGerWriteIt(cArquivo,oGD),oGD:lInsert := .F.,oGD:lUpdate := .F.,oGD:lDelete := .F.,oWrite:bWhen := {|| .F. },oCancel:bWhen := {|| .F. }, oEdit:bWhen := {|| .T. }),Nil) }  OF oPanel PIXEL When .F. //"Gravar"
	@ 6,165 BUTTON oCancel Prompt STR0020 SIZE 35 ,9  FONT oDlg:oFont ACTION {|| lCanFocus := PcoVer_Grava(cArquivo, oGD, oBrowse) }  OF oPanel PIXEL When .F. //"Cancela"
		
	oGD	:= MsNewGetDados():New(2,2,2,2,,"PcoxGDLinOK","PcoxGDTudOK","+AKP_ITEM",/*aalter*/,2,999,/*fieldok*/,/*superdel*/,/*delok*/,oFolder:aDialogs[1],aHeaderAKP,aColsAKP)
	oGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
EndIf

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(lConfirma:=.T.,oDlg:End())},{|| lConfirma:=.F.,AKO->(MsUnlockAll()), oDlg:End() },,aButtons)	

dbSelectArea(cArquivo)
dbCloseArea()

If _oPCOXGER1 <> Nil
	_oPCOXGER1:Delete()
	_oPCOXGER1:= Nil
Endif

Return lConfirma

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoGerPlnExp³ Autor ³ Paulo Carnelossi    ³ Data ³ 18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Expansao/Compressao Planilha Visao Ger.orcamentaria ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoGerPlnExp(cArquivo,aExpand,nNivelMax)
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
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoGerRetRes³ Autor ³ Paulo Carnelossi    ³ Data ³ 18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de retorno do bitmap da planilha Visao Ger.orcamentaria³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoGerRetRes(cAlias,nRecNo,lString)
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

If oPCO_COG==Nil
	oPCO_COG := LoadBitmap( GetResources(), "MDIVISIO" )
EndIf

//dbSelectArea(cAlias)
//dbGoto(nRecNo)
If lString
	Do Case
		Case cAlias $ "AKO/AKN"
			oRet := "PCO_CO"
	EndCase
Else
	Do Case
		Case cAlias $ "AKO/AKN"
			oRet := oPCO_COG
	EndCase
EndIf

Return oRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoGerAtuPlan³ Autor ³ Paulo Carnelossi   ³ Data ³ 16/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao do arquivo de trabalho.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoGerAtuPlan(cArquivo,nNivelMax,aExpand,lZap,lUser,cFiltro)

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
(cArquivo)->XKO_CO := AKN->AKN_CODIGO
(cArquivo)->XKO_DESCRI := AKN->AKN_DESCRI
(cArquivo)->RECNO := AKN->(RecNo())
(cArquivo)->ALIAS := "AKN"
AKO->(dbSetOrder(3))
If AKO->(MsSeek(xFilial()+AKN->AKN_CODIGO+"001"))
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
MsSeek(xFilial()+AKN->AKN_CODIGO+"001")
While !Eof() .And. 	AKO_FILIAL+AKO_CODIGO+AKO_NIVEL==;
					xFilial("AKO")+AKN->AKN_CODIGO+"001"
	PcoGerAddPlan(AKO_CODIGO,AKO_CO,cArquivo,@nNivelAtu,@nNivelMax,@aExpand,lUser,cFiltro)
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
±±³Fun‡…o    ³PcoGerAddPlan³ Autor ³ Paulo Carnelossi   ³ Data ³ 16/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a atualizacao do arquivo de trabalho.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoGerAddPlan(cVisaoGer,cCOG,cArquivo,nNivelAtu,nNivelMax,aExpand,lUser,cFiltro)

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
	If lUser
		dbSelectArea("AKG")
		dbSetOrder(1)
		MsSeek(xFilial()+cVisaoGer+cCOG)
		While !Eof() .And. AKG->AKG_FILIAL+AKG->AKG_CODIGO+AKG->AKG_CO==xFilial("AKG")+cVisaoGer+cCOG
			RecLock(cArquivo,.T.)
			(cArquivo)->RECNO := AKG->(RecNo())
			(cArquivo)->ALIAS := "AKG"
			For nx := 1 to Len(aAuxCps)
				If aAuxCps[nx][1]=="AKO_DESCRI"
					FieldPut(FieldPos("X"+Substr(aAuxCps[nx][1],2,Len(aAuxCps[nx][1])-1)),SPACE((VAL(AKO->AKO_NIVEL)-1)*5)+UsrRetName(AKG->AKG_USER))
				EndIf
			Next
			MsUnlock()
			dbSelectArea("AKG")
			dbSkip()
		End	
	EndIf
	RestArea(aRecPai)
EndIf

aRecPai := (cArquivo)->(GetArea())	
dbSelectArea("AKO")
dbSetOrder(2)
MsSeek(xFilial()+cVisaoGer+cCOG)
While !Eof() .And. AKO->AKO_FILIAL+AKO->AKO_CODIGO+AKO->AKO_COPAI==xFilial("AKO")+cVisaoGer+cCOG
	lHaveStr := .T.
	If nNivelMax >= Val(AKO->AKO_NIVEL)
		If aExpand == Nil .Or.Empty(aExpand).Or.(nPosS:=aScan(aExpand,{|x| x[1]==(cArquivo)->ALIAS+cCOG} )>0 .And. aExpand[aScan(aExpand,{|x| x[1]==(cArquivo)->ALIAS+cCOG} )][2]).Or.(nPosS:=aScan(aExpand,{|x| x[1]==(cArquivo)->ALIAS+cCOG} )<=0).Or.nNivelMax<10000
			lFilho := .T.
			PcoGerAddPlan(AKO->AKO_CODIGO,AKO->AKO_CO,cArquivo,@nNivelAtu,@nNivelMax,aExpand,lUser,cFiltro)
		EndIf
	Else
		Exit
	EndIf
	dbSelectArea("AKO")
	dbSkip()
End	
If lHaveStr 
	RestArea(aRecPai)
	If (cArquivo)->ALIAS <>"AKN"
		RecLock(cArquivo,.F.)
		(cArquivo)->CTRLNIV	:= "+"
		MsUnlock()
	EndIf
EndIf
If lFilho
	RestArea(aRecPai)
	If (cArquivo)->ALIAS <>"AKN"
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
±±³Fun‡…o    ³PcoGerPlanIt³ Autor ³ Paulo Carnelossi    ³ Data ³ 18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem dos itens planilha Visao Ger.orcamentaria  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoGerPlanIt(cArquivo,oGD)

Local ny
Local aArea		:= GetArea()
Local nHeadItem	:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AKP_ITEM"})
Local aAreaAKO := AKO->(GetArea())
dbSelectArea("AKO")
dbGoto((cArquivo)->RECNO)

oGD:aCols	:= {}

dbSelectArea("AKP")
dbSetOrder(1)
If dbSeek(xFilial("AKP") + AKN->AKN_CODIGO + (cArquivo)->XKO_CO ) 
	While !Eof() .And. AKP->AKP_FILIAL + AKP->AKP_CODIGO + AKP->AKP_CO  == ;
						xFilial("AKP") + AKN->AKN_CODIGO + (cArquivo)->XKO_CO
						
		nPosIt	:= aScan(oGD:aCols,{|x| x[nHeadItem] == AKP->AKP_ITEM})

		If nPosIt > 0
			For ny := 1 to Len(oGD:aHeader)
				Do Case
					Case Left(AllTrim(oGD:aHeader[ny][2]),7)=="AKP_CRF"					    
						If Left(AllTrim(oGD:aHeader[ny][2]),9)=="AKP_CRF"+AKP->AKP_ITECFG														
							If AllTrim(oGD:aHeader[ny][14]) == "A1H" //Tratamento para Classificadores Receita/Despesa 
								If AllTrim(oGD:aHeader[ny][1]) == STR0027 //"Apl Filt" //Filtro adiciona do campo AKP_FILTCL
									oGD:aCols[Len(oGD:aCols)][nY] := String_To_QQTipo(AKP->AKP_FILTCL, oGD:aHeader[ny][8])
								Else
									oGD:aCols[Len(oGD:aCols)][nY] := String_To_QQTipo(&(oGd:aHeader[nY][12]), oGD:aHeader[ny][8])
								EndIf
							Else
								If AKP->AKP_TIPO=="1".OR.;
									Subs(AllTrim(oGD:aHeader[ny][2]),10,1)=="1"
									oGD:aCols[nPosIt][nY] := String_To_QQTipo(AKP->AKP_VALINI, oGD:aHeader[ny][8])
								EndIf
								If AKP->AKP_TIPO=="2".And.;
									Subs(AllTrim(oGD:aHeader[ny][2]),10,1)=="2"
									oGD:aCols[nPosIt][nY] := String_To_QQTipo(AKP->AKP_VALFIM, oGD:aHeader[ny][8])
								EndIf
							EndIf	
						EndIf						
					OtherWise
						If ( oGD:aHeader[ny][10] != "V") 
						oGD:aCols[nPosIt][ny] := FieldGet(FieldPos(oGD:aHeader[ny][2]))
						EndIf   						
				EndCase
			Next
		Else
			aADD(oGD:aCols,Array(Len(oGD:aHeader)+1))
			oGD:aCols[Len(oGD:aCols)][Len(oGD:aHeader)+1] := .F.
			For ny := 1 to Len(oGD:aHeader)
				Do Case
					Case Left(AllTrim(oGD:aHeader[ny][2]),7)=="AKP_CRF"												
						If Left(AllTrim(oGD:aHeader[ny][2]),9)=="AKP_CRF"+AKP->AKP_ITECFG														
							If AllTrim(oGD:aHeader[ny][14]) == "A1H"
								If AllTrim(oGD:aHeader[ny][1]) == STR0027 //"Apl Filt"
									oGD:aCols[Len(oGD:aCols)][nY] := String_To_QQTipo(AKP->AKP_FILTCL, oGD:aHeader[ny][8])
								Else
									oGD:aCols[Len(oGD:aCols)][nY] := String_To_QQTipo(&(oGd:aHeader[nY][12]), oGD:aHeader[ny][8])
								EndIf
							Else
								If AKP->AKP_TIPO=="1".OR.;
									Subs(AllTrim(oGD:aHeader[ny][2]),10,1)=="1"
									oGD:aCols[Len(oGD:aCols)][nY] := String_To_QQTipo(AKP->AKP_VALINI, oGD:aHeader[ny][8])
								EndIf
								If AKP->AKP_TIPO=="2".And.;
									Subs(AllTrim(oGD:aHeader[ny][2]),10,1)=="2"
									oGD:aCols[Len(oGD:aCols)][nY] := String_To_QQTipo(AKP->AKP_VALFIM, oGD:aHeader[ny][8])
								EndIf
							EndIf
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
EndIf

If Empty(oGD:aCols)
	Preenche_Acols(oGD:aCols, oGD:aHeader)
EndIf
oGD:oBrowse:Refresh()

RestArea(aAreaAKO)	
RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³PcoAvalAKN³ AUTOR ³ Paulo Carnelossi      ³ DATA ³ 18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Funcao de gravacao das tabelas auxiliares da planilha Visao  ³±±
±±³          ³ Gerencial Orcamentaria.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOAVALAKN                                                   ³±±
±±³_DESCRI_  ³ Funcao de gravacao das tabelas auxiliares da planilha Visao  ³±±
±±³_DESCRI_  ³ Gerencial Orcamentaria.                                      ³±±
±±³_FUNC_    ³ Esta funcao devera ser utilizada apos a gravacao da tabela   ³±±
±±³          ³ AKN com a opcao selecionada de acordo com o evento :         ³±±
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
/*/
Function PcoAvalAKN(cAlias,nEvento,lCriaAKO)
Local aArea 	:= GetArea()
Local aAreaAKN  := AKN->(GetArea())

DEFAULT lCriaAKO := .T.

Do Case
	Case nEvento == 1
		If lCriaAKO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o arquivo de Estrutura CO  com o nivel 001        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AKO",.T.)
			AKO->AKO_FILIAL	:= xFilial("AKO")
			AKO->AKO_CODIGO	:= AKN->AKN_CODIGO
			AKO->AKO_DESCRI	:= AKN->AKN_DESCRI
			AKO->AKO_CO		:= AKN->AKN_CODIGO
			AKO->AKO_NIVEL	:= "001"
			MsUnlock()
		EndIf
EndCase
RestArea(aAreaAKN)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoAKOBOF³ Autor ³ Edson Maricate         ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada na consulta F3 do arquivo AKO.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO, SXB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAKOBOF(lFilial)

DEFAULT lFilial := .T.

Return If(lFilial,xFilial("AKO")+cBofF3AKO,cBofF3AKO)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoAKOEOF³ Autor ³ Edson Maricate         ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada na consulta F3 do arquivo AKO.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO, SXB                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAKOEOF(lFilial)

DEFAULT lFilial := .T.

Return If(lFilial,xFilial("AKO")+cEofF3AKO,cEofF3AKO)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoGerSetF3³ Autor ³ Paulo Carnelossi     ³ Data ³ 18/11/2004 ³±±
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
Function PcoGerSetF3(cSXB,nOpcao)
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
±±³Fun‡…o    ³PcoGerWriteIt³ Autor ³Paulo Carnelossi    ³ Data ³ 18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de gravacao dos itens planilha visao ger. orcamentaria ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoGerWriteIt(cArquivo, oGD)

Local aArea		:= GetArea()
Local nHeadItem	:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AKP_ITEM"})
Local aRecAKP	:= {}
Local lExistAKP 
Local nTotRec
Local nCntFor3
Local nCntFor2
Local nCntFor
Local nX, nPosAKP, nPosFilt := 0
Local cAKPId   := Space(Len(AKP->AKP_ITEM))
Local cItemAKP := Space(Len(AKP->AKP_ITEM))

dbSelectArea("AKP")
For nCntFor := 1 to Len(oGD:aCols)
    //se estiver deletado no acols ja deleta da base
	If oGD:aCols[nCntFor][Len(oGD:aCols[nCntFor])]

		For nCntFor2 := 1 to Len(oGD:aHeader)
			If Left(AllTrim(oGD:aHeader[nCntFor2][2]),7) == "AKP_CRF"
				//primeiro vou procurar e ver se existe o registro no AKP para deletar
				lExistAKP := dbSeek(xFilial("AKP") + AKN->AKN_CODIGO + (cArquivo)->XKO_CO + oGD:aCols[nCntFor][nHeadItem] + AKN->AKN_CONFIG + Subs(oGD:aHeader[nCntFor2][2],8,2) )
				If lExistAKP
					//deleta o existente
					RecLock("AKP",.F.,.T.)
					dbDelete()
					MsUnlock()
		        EndIf
		   EndIf
		Next // nCntFor2
		   
	EndIf
Next  nCntFor

//popular array aRecAKP com a seguinte estrutura sub-array com os registros restantes
// 1-posicao = AKP_ITEM
// 2-posicao = Array contendo os recnos referente ao item gravado na base
// 3-posicao = Array de controle aproveitamento recnos --> 0 se nao utilizou o recno
//                                                        -1 se ja utilizado
dbSelectArea("AKP")
dbSetOrder(1)
dbSeek(xFilial("AKP") + AKN->AKN_CODIGO + (cArquivo)->XKO_CO )
While !Eof() .And. AKP->AKP_FILIAL + AKP->AKP_CODIGO + AKP->AKP_CO  == ;
					xFilial("AKP") + AKN->AKN_CODIGO + (cArquivo)->XKO_CO
	If ( nPos := Ascan(aRecAKP,{|aVal| aVal[1] == AKP->AKP_ITEM}) ) == 0
		aAdd(aRecAKP, { AKP->AKP_ITEM, {}, {} } )
		aAdd(aRecAKP[Len(aRecAKP), 2], AKP->(Recno()) )
		aAdd(aRecAKP[Len(aRecAKP), 3], 0 )
	Else
		aAdd(aRecAKP[nPos, 2], AKP->(Recno()) )
		aAdd(aRecAKP[nPos, 3], 0 )
	EndIf	
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo AKP (Itens)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AKP")
cAKPId := "00"

For nCntFor := 1 to Len(oGD:aCols)

	If !oGD:aCols[nCntFor][Len(oGD:aCols[nCntFor])]
	    
	    //bloco para renumerar AKP_ITEM
		cItemAKP := oGD:aCols[nCntFor][nHeadItem]
		nPosAKP := Ascan(aRecAKP,{|aVal| aVal[1] == cItemAKP })
		
		cAKPId := StrZero(Val(cAKPId)+1, Len(AKP->AKP_ITEM))
		oGD:aCols[nCntFor][nHeadItem] := cAKPId
		//fim do bloco para renumerar
		
		nTotRec := 0
		
		For nCntFor2 := 1 to Len(oGD:aHeader)
			If Left(AllTrim(oGD:aHeader[nCntFor2][2]),7) == "AKP_CRF" 			    																
				If AllTrim(oGD:aHeader[nCntFor2][14]) == "A1H" //Tratamento para Classificadores Receita/Despesa 
					If AllTrim(oGD:aHeader[nCntFor2][1]) == STR0027 //"Apl Filt"
						nPosFilt := nCntFor2 //Posiç?o do campo Filtro no Header						
					EndIf
				Else
					If Empty(Subs(oGD:aHeader[nCntFor2][2],10,1)) .OR. ;
						Subs(oGD:aHeader[nCntFor2][2],10,1) == "1"
						nTotRec++
						//primeiro vou procurar e ver se ja existe o registro no AKP
						If nPosAKP > 0 .And. nTotRec <= Len(aRecAKP[nPosAKP, 2])
							// vou aproveitar os recnos 
							AKP->(dbGoto(aRecAKP[nPosAKP, 2, nTotRec]))
							aRecAKP[nPosAKP, 3, nTotRec] := -1
							RecLock("AKP",.F.)
						Else
							RecLock("AKP",.T.)							
						EndIf
						For nCntFor3 := 1 To Len(oGD:aHeader)
							If ( oGD:aHeader[nCntFor3][10] != "V" ) .And. Left(AllTrim(oGD:aHeader[nCntFor3][2]),7) != "AKP_CRF"
								AKP->(FieldPut(FieldPos(oGD:aHeader[nCntFor3][2]),oGD:aCols[nCntFor][nCntFor3]))
							EndIf
						Next nCntFor3
						AKP->AKP_FILIAL	:= xFilial("AKP")
						AKP->AKP_CODIGO	:= AKN->AKN_CODIGO
						AKP->AKP_CO		:= (cArquivo)->XKO_CO
						AKP->AKP_CONFIG := AKN->AKN_CONFIG
						AKP->AKP_ITECFG := Subs(oGD:aHeader[nCntFor2][2],8,2)
						AKP->AKP_TIPO   := If(Empty(Subs(oGD:aHeader[nCntFor2][2],10,1)),"1","2")
						MsUnlock()
					EndIf
				
					RecLock("AKP",.F.)				
					If Empty(Subs(oGD:aHeader[nCntFor2][2],10,1)) .OR. ;
						Subs(oGD:aHeader[nCntFor2][2],10,1) == "1"				
						AKP->AKP_VALINI := QQTipo_To_String(oGD:aCols[nCntFor][nCntFor2], oGD:aHeader[nCntFor2][8])
					Else
						AKP->AKP_VALFIM := QQTipo_To_String(oGD:aCols[nCntFor][nCntFor2], oGD:aHeader[nCntFor2][8])																							
					EndIf

					If nPosFilt > 0 //Grava valor do filtro 
						AKP->AKP_FILTCL := QQTipo_To_String(oGD:aCols[nCntFor][nPosFilt], oGD:aHeader[nPosFilt][8])
						nPosFilt := 0							
					EndIf					
					MsUnlock()
				EndIf								
			EndIf
		Next nCntFor2

	EndIf
	
Next  nCntFor

//rotina de contingencia pois os itens podem ter ficado
//fora da sequencia natural e nao foram aproveitados
For nCntFor := 1 to Len(aRecAKP)

	For nX := 1 TO Len(aRecAKP[nCntFor, 2])
	
		If aRecAKP[nCntFor, 3, nX] == 0
			//se registro nao foi utilizado - nao deve existir + na base
			AKP->(dbGoto(aRecAKP[nCntFor, 2, nX]))
			RecLock("AKP",.F.,.T.)
			dbDelete()
			MsUnlock()
		EndIf
		
	Next //nX
			
Next

AKO->(MsUnlockAll())  //libera registro travado com softlock para garantir integridade

//ler os registros novamente para provocar refresh da getdados
PcoGerPlanIt(cArquivo,oGD)
oGD:oBrowse:SetFocus()

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoxGDLinOK ³ Autor ³ Edson Maricate      ³ Data ³ 17-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da LinOK da Getdados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXGER                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoxGDLinOK()
Local lRet			:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	lRet := MaCheckCols(oGD:aHeader,oGD:aCols,oGD:oBrowse:nAT) 
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoxGDTudoK ³ Autor ³ Edson Maricate      ³ Data ³ 17-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PCOXGER                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoxGDTudoK()

Local nx
Local lRet			:= .T.
Local nSavN			:= n

For nx := 1 to Len(oGD:aCols)
	n	:= nx
	If !(oGD:aCols[n][Len(oGD:aHeader)+1])
		If !PcoxGDLinOK()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

n	:= nSavN

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoDlgView³ Autor ³ Paulo Carnelossi      ³ Data ³ 18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de visualizacao da enchoice da estrutura selecionada.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXGER                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoDlgView(cArquivo,aSVAlias,aEnch,aPos,nOldEnch,oPanel)

Local aArea		:= GetArea()
Local cAlias	:= (cArquivo)->ALIAS
Local nRecView	:= (cArquivo)->RECNO
Local nPosAlias	:= aScan(aSVAlias,cAlias)

If nRecView <> 0
	aEnch[nOldEnch]:Hide()
	dbSelectArea(cAlias)
	MsGoto(nRecView)
	RegToMemory(cAlias,.F.)
	If nPosAlias > 0
		Do Case
			Case cAlias == "AKO"
				aEnch[1]:EnchRefreshAll()
				aEnch[1]:Show()
				nOldEnch:=1
			Case cAlias == "AKN"
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
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoAKNFil³ Autor ³ Paulo Carnelossi       ³ Data ³ 18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem do filtro da estrutura do AKN.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXGER                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAKNFil(cFiltro)

cFiltro := BuildExpr("AKO")

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoAKNPesq³ Autor ³ Paulo Carnelossi      ³ Data ³ 18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de pesquisa na estrutura da planilha Visao Ger.Orc.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXGER                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAKNPesq(cArquivo)

Local aAuxArea	:= (cArquivo)->(GetArea())
Local aParam	:= {}

If ParamBox( { { 1 ,STR0012 ,SPACE(200),"@" 	 ,""  ,""    ,"" ,50 ,.F. },;   //"Pesquisar"
				{5,STR0010,.F.,90,,.F.},; //"Utilizar Pesquisa Exata"
				{5,STR0011,.F.,90,,.F.} }, STR0012 ,aParam ) //"Pesquisar Proxima Ocorrencia"###"Pesquisar"
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
Else
   //aqui colocar comando para montar os itens
EndIf

Return	


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoGerRetCO³ Autor ³ Paulo Carnelossi     ³ Data ³ 18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o codigo do CO aplicando-se a configuração de mascara ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoGerRetCO(cCOG,cCodMasc)
Local aArea		:= GetArea()
Local cCodRet	:= cCOG
Local cSeparador:= ""
Local cMascara	:= ""

If !Empty(cCodMasc)
	cMascara:= RetMasCtb(cCodMasc,@cSeparador)
	cCodRet	:= MascaraCTB(cCOG,cMascara,,cSeparador)
EndIf
	
RestArea(aArea)
Return cCodRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoGerChgFld ³ Autor ³ Paulo Carnelossi   ³ Data ³ 18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoGerChgFld(nFldDst,nFldAtu,oFolder,aAKKLoad)
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
EndIf

RestArea(aAreaAKO)
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoGerRetFilhosºAutor ³Paulo Carnelossi º Data ³ 19/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna array com recnos das contas orc ger abaixo da COG   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoGerRetFilhos(cVisaoGer,cCOG,aRet)
Local aArea	:= GetArea()
Local aAreaAKO	:= AKO->(GetArea())
DEFAULT aRet := {}

If aRet == Nil .And. !Empty(aRet)
	aRet := {}	
	dbSelectArea("AKO")
	dbSetOrder(1)
	MsSeek(xFilial()+cVisaoGer+cCOG)
	aAdd(aRet,AKO->(RecNo()))
EndIf

dbSelectArea("AKO")
dbSetOrder(2)
MsSeek(xFilial()+cVisaoGer+cCOG)
While !Eof() .And. AKO->AKO_FILIAL+AKO->AKO_CODIGO+AKO->AKO_COPAI==xFilial("AKO")+cVisaoGer+cCOG
	aAdd(aRet,AKO->(RecNo()))
	PcoGerRetFilhos(AKO->AKO_CODIGO,AKO->AKO_CO,aRet)	
	dbSelectArea("AKO")
	dbSkip()
End

RestArea(aAreaAKO)
RestArea(aArea)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³It_OrcGer_Lock ºAutor ³Paulo Carnelossi º Data ³ 19/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lockar a conta orc ger quando for editar os itens           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function It_OrcGer_Lock(cArquivo,oGD)
Local lRet := .F.

If SoftLock("AKO")
	PcoGerPlanIt(cArquivo,oGD)
	lRet := .T.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Preenche_Acols ºAutor ³Paulo Carnelossi º Data ³ 19/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Preenchimento do acols para edicao da getdados              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Preenche_Acols(aColsAKP, aHeaderAKP)
Local nY

aadd(aColsAKP,Array(Len(aHeaderAKP)+1))
For ny := 1 to Len(aHeaderAKP)
	If AllTrim(aHeaderAKP[ny][2])=="AKP_ITEM"
		aColsAKP[Len(aColsAKP)][ny] := StrZero(Len(aColsAKP),LEN(AKP->AKP_ITEM))
	Else
	
	    If Left(aHeaderAKP[ny][2], 7) == "AKP_CRF"
	       	If aHeaderAKP[ny][8]=="C"   //tipo do campo
				If Empty(aHeaderAKP[ny][12])
					aColsAKP[Len(aColsAKP)][ny] := Space(aHeaderAKP[ny][4])
		       	Else
		       		aColsAKP[Len(aColsAKP)][ny] := PadR(&(aHeaderAKP[ny][12]),aHeaderAKP[ny][4])  //inic.Padrao
		       	EndIf
		       			
	       ElseIf aHeaderAKP[ny][8]=="D"   //tipo do campo
				If Empty(aHeaderAKP[ny][12])
			       aColsAKP[Len(aColsAKP)][ny] := CtoD(Space(8))
		       	Else
		       		aColsAKP[Len(aColsAKP)][ny] :=CtoD(&(aHeaderAKP[ny][12])) //inic.Padrao
		       	EndIf		

	       ElseIf aHeaderAKP[ny][8]=="N"   //tipo do campo
				If Empty(aHeaderAKP[ny][12])
		       		aColsAKP[Len(aColsAKP)][ny] := 0
		       	Else
		       		aColsAKP[Len(aColsAKP)][ny] := Val(&(aHeaderAKP[ny][12]))  //inic.Padrao
		       	EndIf
	
	       ElseIf aHeaderAKP[ny][8]=="L"   //tipo do campo
	       		If Empty(aHeaderAKP[ny][12])
			       	aColsAKP[Len(aColsAKP)][ny] := .T.
			    Else
		       		aColsAKP[Len(aColsAKP)][ny] := If(aHeaderAKP[ny][12]$"T|t|.T.|.t.", .T., .F.)  //inic.Padrao
		       	EndIf
			       	
	       Else

		       aColsAKP[Len(aColsAKP)][ny] := Space(aHeaderAKP[ny][4])

	       EndIf
	    Else
			aColsAKP[Len(aColsAKP)][ny] := CriaVar(aHeaderAKP[ny][2])
		EndIf	
	EndIf
Next ny

aColsAKP[Len(aColsAKP)][Len(aHeaderAKP)+1] := .F.

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lib_Botao_Edicao ºAutor ³Paulo Carnelossi º Data ³19/11/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Libera botao editar itens da conta orc gerencial            º±±
±±º          ³somente a primeira COG (raiz) nao libera                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lib_Botao_Edicao(cArquivo, oGetDados)
LOCAL aArea := GetArea()
Local cAlias := Alias()
Local aAreaAKO
Local lRet := .F.
    
If (cArquivo)->ALIAS == "AKO" 
	aAreaAKO  := AKO->(GetArea())
	dbSelectArea((cArquivo)->ALIAS)
	dbGoto((cArquivo)->RECNO)
    If Alltrim(AKO_CODIGO) == AllTrim(AKO_CO)   // no' principal nao aceita itens
		lRet := .F.
    Else
		lRet := .T.
	EndIf	
	RestArea(aAreaAKO)
EndIf

If lRet
	oCopia:bWhen:= {|| .T. }    
	oCola:bWhen	:= {|| .T. }    
	oEdit:bWhen := {|| .T. }
Else
	oCopia:bWhen:= {|| .F. }    
	oCola:bWhen	:= {|| .F. }    
	oEdit:bWhen := {|| .F. }
EndIf

oCopia:refresh()
oCola:refresh()
oEdit:refresh()

RestArea(aArea)
dbSelectArea(cAlias)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QQTipo_To_String ºAutor ³Paulo Carnelossi º Data ³19/11/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Converte o valor informado no parametro 1 para o tipo Stringº±±
±±º          ³Utilizado para gravar conteudo da getdados no arquivo AKP   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QQTipo_To_String(xVal, cTipo)
Local cString := ""

If 		cTipo == "C"
	cString := xVal
	
ElseIf 	cTipo == "N"
	cString := Str(xVal,15,4) 

ElseIf 	cTipo == "D"
	cString := DTOC(xVal)
	
ElseIf 	cTipo == "L"  .And. ValType(xVal) == "L"
	cString := If(xVal, ".T.", ".F.")
	
EndIf

Return(cString)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³String_To_QQTipo ºAutor ³Paulo Carnelossi º Data ³19/11/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Converte a string valor informado no parametro 1 para o tipoº±±
±±º          ³informado no parametro 2                                    º±±
±±º          ³Utilizado para editar campos da getdados no arquivo AKP     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function String_To_QQTipo(cString, cTipo)
Local xVal

If 		cTipo == "C"
	xVal := cString
	
ElseIf 	cTipo == "N"
	xVal := Val(cString) 

ElseIf 	cTipo == "D"
	xVal := CTOD(cString)
	
ElseIf 	cTipo == "L"
	xVal := If(Left(cString,3)==".T.", .T., .F.)
	
EndIf

Return(xVal)


Static Function PcoVisColar_aCols(oGd, aColsCopy)
Local lContinua := .T., lColaLinha := .T., lRet := .T.
Local lLinhaVazia, nItem, nValor, nPosItem, nPosOperac, nX
Local MyaCols, MyaHeader, nLinAt, nPosIt, nY, nOpca

nPosOperac := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AKP_OPERAC"})    

If Empty(aColsCopy) .OR. ;
    Empty(aColsCopy[1][1][nPosOperac])  //verifica se 1a. linha do acols nao esta vazio
	Aviso(STR0013,STR0014,{STR0015},2)//"Atencao"###"Nao sera possivel colar pois  os valores da grade do item orcamentario nao foram copiados!"###"Fechar"
	lContinua := .F.
	lRet := .F.
Else
	MyaCols := aClone(aColsCopy[1])
	MyaHeader := aClone(aColsCopy[2])
	nLinAt := aColsCopy[3]

	If (nOpca := Aviso(STR0016,STR0017,{STR0018, STR0019, STR0020},1)) == 3//"Linha ou Grade"###"Voce deseja colar ?"###"Linha"###"Grade"###"Abandonar"
		lContinua := .F.
		lRet := .F.
	ElseIf nOpca == 2
		lColaLinha := .F.
	EndIf	
EndIf

If lContinua   
	lLinhaVazia := .F.
	nItem := 0
	nValor := 0
	nPosItem := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AKP_ITEM"})
	
    If nPosItem == 0 .OR. nPosOperac == 0
    	lContinua := .F.
    EndIf
    
    If lContinua
			//verifica se a ultima linha esta vazia
			nItem := Val(oGd:aCols[Len(oGd:aCols)][nPosItem])
        
        If nItem == 0
            lLinhaVazia := .T.
        	   nItem--
        EndIf
        
        If nItem <= 0
        	nItem := 1
        Else
            nItem++
        EndIf

        //renumera os itens orcamentarios e cola 
        If nOpca == 2  //grade
        	For nX := 1 TO Len(MyaCols)
            	MyaCols[nX][nPosItem] := StrZero(nItem, MyaHeader[nPosItem][4])
	            nItem++
    	    Next
    	    
    	    //acrescenta ao acols existente
        	For nX := 1 TO Len(MyaCols)
	        	If aScan(oGD:aCols,{|x| x[nPosItem] == MyaCols[nX][nPosItem]}) == 0
	            	//acrescentar a linha
	            	aADD(oGD:aCols,Array(Len(oGD:aHeader)+1))
					oGD:aCols[Len(oGD:aCols)][Len(oGD:aHeader)+1] := .F.
	            EndIf
	            
	            For nY := 1 TO Len(MyaCols[nX])
	            	oGd:aCols[Len(oGd:aCols)][nY] := MyaCols[nX][nY]
	            Next
	            
        	Next

        Else  //linha
        
            MyaCols[nLinAt][nPosItem] := StrZero(nItem, MyaHeader[nPosItem][4])

            If ! lLinhaVazia
            	aADD(oGD:aCols,Array(Len(oGD:aHeader)+1))
				oGD:aCols[Len(oGD:aCols)][Len(oGD:aHeader)+1] := .F.
			EndIf	
            
            For nY := 1 TO Len(MyaCols[nLinAt])
            	oGd:aCols[Len(oGd:aCols)][nY] := MyaCols[nLinAt][nY]
            Next
            
        EndIf
        
    EndIf    

EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoAbandVis ºAutor  ³ Acacio Egas      º Data ³  06/27/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função utilizada ao abandonar a Visão Gerencial.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAbandVis()

Local lRet := .T.

If Eval(oWrite:bWhen)
	If Aviso(STR0021, STR0022, {STR0023,STR0024}, 2) == 2 //"Atencao"###"Nao foi gravado as alteracoes apos edicao. Abandona sem gravar ? "###"Sim"###"Nao"
		lRet := .F.
	Else
		lRet := .T.
	EndIf
EndIf

Return lRet
