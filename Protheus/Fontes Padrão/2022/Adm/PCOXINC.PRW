#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCOXINC.CH"
#INCLUDE "DBTREE.CH"

#Define BMP_ON     "LBOK"
#Define BMP_OFF    "LBNO"
#Define BMP_CHK    "NOTE_PQ"
#Define BMP_INCL   "PCOBRANCO"
#Define BMP_BRANCO "PCOBCOBD"
#Define BMP_COPY   "S4WB005N_PQ"
#Define BMP_COLA   "S4WB007N_PQ"

#Define COL_MARK aScan(aAuxHeader,{|x| AllTrim(x[2])=="AK2_MARK"})
#Define COL_COPY aScan(aAuxHeader,{|x| AllTrim(x[2])=="AK2_COPIA"})
#Define COL_COLA aScan(aAuxHeader,{|x| AllTrim(x[2])=="AK2_COLA"})
#Define COL_EDIT aScan(aAuxHeader,{|x| AllTrim(x[2])=="AK2_ALTER"})

#DEFINE MAX_COL_AK2 Min(9999,37**TamSX3("AK2_ID")[1])

// Definicoes e variaveis para a rotina automatica
#define GETD_OBRIGAT 1
#define GETD_VISUAL 2
#define GETD_TITULO 3

STATIC aColsCopy 	:= {}
STATIC aFormCopy 	:= {}
Static cLastAK3Read
Static aClassesSt 	:= {}
Static aLocksAK2	:=	{}
Static aLineNew		:=	{}
Static __lBlind		:= IsBlind()
Static nQtdEntid

//Static lAutoMode := .F.
Static lAutoVldUser

Static aGetDCache := {}
Static aGetDInfo := {}

Static nLenX3VALID
Static nLenX3VLDUSER
Static nLenX3TRIGGER
Static nLenX3TITULO
Static nLenX3RELACAO
Static nLenX3ARQUIVO

STATIC  _oPCOXINC1
Static _lProcCCUs := NIL
Static _cNomProc1 := NIL

Static _lProcICUs := NIL
Static _cNomProc2 := NIL
Static _nPQrySize := NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOAK1PLAN³ Autor ³ Edson Maricate        ³ Data ³ 28-11-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de montagem da tela de planilha orcamentaria        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOAK1PLAN(cTitle,aCampos,cArquivo,lConfirma,aMenu,oDlg,bChange,lUser,lVisual, cFiltro, cCOInic,lDetalheCO)

Local nx
Local nNivelMax
Local nTop      := oMainWnd:nTop+35
Local nLeft     := oMainWnd:nLeft+10
Local nBottom   := oMainWnd:nBottom-12
Local nRight    := oMainWnd:nRight-10

Local aAKKLoad		:= {}
Local aExpand		:= {}
Local aFolder		:= {"Itens"}
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

Local oForm_Get  //get para edicao da formula
Local cFormula, cFormAnt, cCpoForm, cFormValid, cFormWhen, cFormPict
Local cBlkGet, cBlkWhen
Local oFont, oFontBt, cCpo
Local aPeriodos
Local aButtons	:= {}
//Proteção campo AK1_FASE
Local cAK1Fase	:= IIF( AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "" )
Local cValid	:= ""
Local lAMX		:= .T.
Local lRet		:= .T.,aAreaAKK // usado no Ponto de Entrada PCOAKKLST
Local lPCOInfTree := ExistBlock("PCOInfTree")
Local lValid:= .T.

Local cFiller := Space( 1 )    // TGXEBL
Local cRet

DEFAULT bChange := {|| Nil }
DEFAULT lUser	:= .F.
DEFAULT lVisual	:= .F.
DEFAULT lDetalheCO	:=	.T.

DEFAULT aCampos	:= {{"AK3_DESCRI","AK3_DESCRI",55,,,.F.,"",Iif(lDetalheCO,300,600),Max(TamSx3("AK3_DESCRI")[1]+Iif(lDetalheCO,25,100),255)},{"AK3_CO","AK3_CO",55,,,.F.,"",50,TamSx3("AK3_CO")[1]}}

PRIVATE oBrowse
PRIVATE oFormula

PRIVATE nColGd := 0
PRIVATE aFormula := {}
PRIVATE oFormZe, oFormZe1

PRIVATE bRefresh	:= {|cFiltro| (PCOAtuPlan(cRevisa,cArquivo,If(lUser,12000,If(AK1->AK1_NMAX>0,AK1->AK1_NMAX,1)),aExpand,,lUser,cFiltro,cCOInic),oBrowse:Refresh(),PcoDlgView(cArquivo,@aSVAlias,@aEnch,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},@nOldEnch,@oPanel3,.T.)),Eval(bBrwChange) }
PRIVATE bRefreshAll	:= {|cFiltro| (PCOAtuPlan(cRevisa,cArquivo,If(lUser,12000,If(AK1->AK1_NMAX>0,AK1->AK1_NMAX,1)),,,lUser,cFiltro,cCOInic),oBrowse:Refresh(),PcoDlgView(cArquivo,@aSVAlias,@aEnch,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},@nOldEnch,@oPanel3,.T.)) }
PRIVATE bBrwChange	:= {|| Eval(oBrowse:bChange) }
PRIVATE aStru		:= {}
PRIVATE aAuxCps		:= aClone(aCampos)
PRIVATE aHeaderAK2	:= {}
PRIVATE aColsAK2	:= {}
PRIVATE oGD[1]
PRIVATE oFolder
PRIVATE oCopia, oCola, oEdit, oWrite, oCancel
PRIVATE cArquivx := cArquivo
PRIVATE nRecEdic := 0
PRIVATE nRecPos	:= 0
PRIVATE aColsAux := {}
PRIVATE oFormAply := Nil
PRIVATE oFormAband := Nil

//jogar em variaveis de memoria tab itens (ak2) para utilizacao nas formulas
For nX := 1 TO AK2->(FCOUNT())
	cCpo := ("AK2->"+Trim(AK2->(FieldName(nX))))
	_SetOwnerPrvt(Trim(AK2->(FieldName(nX))), &cCpo)
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AK2                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AK2")
While !EOF() .And. (x3_arquivo == "AK2")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		! ( AllTrim(X3_CAMPO) $ "AK2_MARK|AK2_ALTER|AK2_COPIA|AK2_COLA|AK2_FANTS|AK2_DESCCO|AK2_DESCIT|AK2_DESCCL") ;
		.And. AllTrim(X3_TIPO) != "M"
		
		If AllTrim(X3_CAMPO) = "AK2_CHAVE"
			AADD(aHeaderAK2,{ 	TRIM(x3titulo()),;
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
							"PCOChk_Acesso(cArquivx, oGD[1], oGD[1]:nAt)"+If(!Empty(SX3->X3_VALID),".And.("+SX3->X3_VALID+")",""),;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							SX3->X3_CBOX,;
							SX3->X3_RELACAO,;
							"PCOChk_Acesso(cArquivx, oGD[1], oGD[1]:nAt)"+If(!Empty(SX3->X3_WHEN),".And.("+SX3->X3_WHEN+")","")})
		
			//AK2_CLASSE com inicializador padrÃ£o
			If AllTrim(X3_CAMPO) == "AK2_CLASSE"
				If ! Empty(SX3->X3_RELACAO)
					cValid := Upper(Alltrim(SX3->X3_VALID))
				
					//retira existcpo
					If 'EXISTCPO("AK6")' $ cValid
						cValid := StrTran(cValid,'EXISTCPO("AK6")','')
					EndIf			
				
					//retira .and.  e acrescenta a execuÃ§Ã£o dos gatilhos do campo AK2_CLASSE
					If !Empty(cValid) .And. (nX := Ascan(aHeaderAK2,{|a|Alltrim(a[2]) == 'AK2_CC'}))>0 			
						If Left(cValid,5)=='.AND.'
							cValid := SubStr(cValid,6) +' .And. IIf(ExistTrigger("AK2_CLASSE"),Eval({|| RunTrigger( 2, oGD[1]:nAt,, "AK2_CLASSE" ),.T.}),.T.)'
						EndIf
						//remove espaÃ§os duplicados
						While AT('  ',aHeaderAK2[nX,6]) > 0
							aHeaderAK2[nX,6] := StrTran(aHeaderAK2[nX,6],'  ',' ')
						Enddo
						aHeaderAK2[nX,6]:=Alltrim(aHeaderAK2[nX,6])+" .And. "+cValid
					EndIf
				EndIf  					
			EndIf
		EndIf
	Endif

	SX3->( dbSkip() )

End

If ExistBlock("PCOAK2HED")
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para alterar o aHeader da planilha de       ³
	//P_E³ orcamento.                                                             ³
	//P_E³ Parametros : aHeader (Padrão)                                          ³
	//P_E³ Retorno    : aHeader (Alterado)                                        ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeaderAK2 := ExecBlock("PCOAK2HED",.F.,.F.,aHeaderAK2)
EndIf

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("AK2_VAL")
aPeriodos	:=	PcoRetPer()
For nX :=1 To Len(aPeriodos)

	If !Empty(cAK1Fase)
		cValid := "PCOBlqRMes(oGD[1],'"+cRevisa+"') .And. PCOChk_Acesso(cArquivx, oGD[1], oGD[1]:nAt).And. PcoVldFase('AMR',AK1->AK1_FASE,'0014',.T.)"+If(!Empty(SX3->X3_WHEN),".And.("+SX3->X3_WHEN+")","")
	Else
		cValid := "PCOBlqRMes(oGD[1],'"+cRevisa+"') .And. PCOChk_Acesso(cArquivx, oGD[1], oGD[1]:nAt) "+If(!Empty(SX3->X3_WHEN),".And.("+SX3->X3_WHEN+")","")
	EndIF

	AADD(aHeaderAK2,{ aPeriodos[nX],;
						SX3->X3_CAMPO,;
						cFiller,;  // SX3->X3_PICTURE,; - TGXEBL
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						"PCOChk_Acesso(cArquivx, oGD[1], oGD[1]:nAt)"+If(!Empty(SX3->X3_VALID),".And.("+SX3->X3_VALID+")",""),;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_F3,;
						SX3->X3_CONTEXT,;
						SX3->X3_CBOX,;
						SX3->X3_RELACAO,;
						cValid })
Next

aadd(aColsAK2,Array(Len(aHeaderAK2)+1))
For ny := 1 to Len(aHeaderAK2)
	If AllTrim(aHeaderAK2[ny][2])=="AK2_ID"
		aColsAK2[1][ny] := Padr("*", Len(AK2->AK2_ID))//StrZero(1,LEN(AK2->AK2_ID))
	ElseIf AllTrim(aHeaderAK2[ny][2])=="AK2_VAL"
		//inicializa todos os periodos orcamentarios com CriaVar()
		aColsAK2[1][nY] := PcoPlanCel(CriaVar(aHeaderAK2[ny][2]))
	Else
		aColsAK2[1][ny] := CriaVar(aHeaderAK2[ny][2])
	EndIf
Next ny
aColsAK2[1][Len(aHeaderAK2)+1] := .F.

For nx := 1 to Len(aCampos)
	dbSelectArea("SX3")
	dbSetOrder(2)
	If MsSeek(aCampos[nx][1])
		If Len(aCampos[nX]) >= 9 //Tamanho definido
			aAdd(aStru,{"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)),X3_TIPO,aCampos[nX,9],X3_DECIMAL})
		Else
			aAdd(aStru,{"X"+Substr(X3_CAMPO,2,Len(X3_CAMPO)),X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		Endif
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

If _oPCOXINC1 <> Nil
	_oPCOXINC1:Delete()
	_oPCOXINC1:= Nil
Endif

_oPCOXINC1 := FWTemporaryTable():New(cArquivo)
_oPCOXINC1:SetFields( aStru )

_oPCOXINC1:AddIndex("1", {"L_I_XO"})	//Somente para uso do Temporarytable, pois é obrigatório o uso de índice.
_oPCOXINC1:Create()

nNivelMax := PCOAtuPlan(cRevisa,cArquivo,If(lUser,12000,If(AK1->AK1_NMAX>0,AK1->AK1_NMAX,1)),aExpand,,lUser,cFiltro,cCOInic)

If lPCOInfTree
	ExecBlock("PCOInfTree",.F.,.F., cArquivo)
Endif
DEFINE FONT oFontBt NAME "Arial" SIZE 0, -8 BOLD
DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
DEFINE MSDIALOG oDlg TITLE cTitle OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight
oDlg:lMaximized := .T.

For nx := 1 to Len(aMenu)
	aAdd( aButtons , aMenu[nX] )
Next

oPanel3 := TPanel():New(14,182,'',oDlg, oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-212,((oDLg:nBottom-oDLg:nTop)/2)-120,.T.,.T. )
oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
lOneColumn := If((nRight-nLeft)/2-178>312,.F.,.T.)

aAdd(aSVAlias,"AK3")
aEnch[1]:= MsMGet():New("AK3",AK3->(RecNo()),2,,,,,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},,3,,,,oPanel3,,,lOneColumn)
aEnch[1]:oBox:Align := CONTROL_ALIGN_ALLCLIENT

aAdd(aSVAlias,"AK1")
aEnch[2]:= MsMGet():New("AK1",AK1->(RecNo()),2,,,,,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},,3,,,,oPanel3,,,lOneColumn)
aEnch[2]:oBox:Align := CONTROL_ALIGN_ALLCLIENT

dbSelectArea(cArquivo)
dbGotop()
nAlias	:= Select()
oBrowse := TcBrowse():New( 23, 1,200, 120, , , , oDlg,,,,,{|| If(!Empty((cArquivo)->CTRLNIV),(PcoPlnExp(cArquivo,aExpand,@nNivelMax),PCOAtuPlan(cRevisa,cArquivo,@nNivelMax,aExpand,,lUser,cFiltro,cCOInic),oBrowse:Refresh()),NIL)},,oFont,,,,, .F.,cArquivo, .T.,, .F., , ,.f. )

oBrowse:bChange := {|| If(lUser,Nil,;
							If(PcoVer_Grava(cArquivo, oGD[1], oBrowse),;
								(aLineNew := {},AK3->(MsUnlockAll()), PcoChgFld(oFolder:nOption,oFolder:nOption,oFolder,aAKKLoad,cArquivo), Processa({ || aRecNoVisible:={}, PcoPlanIt(cArquivo,cRevisa,oGD[1],aRecNoVisible,.T.)},,STR0078), oGD[1]:lInsert := .F., oGD[1]:lUpdate := .F., oGD[1]:lDelete := .F., oWrite:bWhen := {|| .F. }, Eval(bChange), If(lUser,NIL,AnalPerm_Usuar(cArquivo,oGD[1],"ITENS")), oGD[1]:oBrowse:SetFocus(), oBrowse:SetFocus());//"Carregando itens..."
							,NIL);
						), PcoDlgView(cArquivo,@aSVAlias,@aEnch,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},@nOldEnch,@oPanel3) }
oBrowse:bLostFocus := {||If(lUser,NIL,(oCopia:bWhen := {||.F.}, oCola:bWhen := {||.F.}, oEdit:bWhen := {||.F.},If(!Eval(oWrite:bWhen),AnalPerm_Usuar(cArquivo,oGD[1],"ITENS"),NIL)))}
If lDetalheCO
	oBrowse:Align := CONTROL_ALIGN_LEFT
Else
	oPanel3:Hide()
	oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif
oBrowse:AddColumn( TCColumn():New( "",{ || If((cArquivo)->CTRLNIV=="-",oMenos,If((cArquivo)->CTRLNIV=="+",oMais,If((cArquivo)->CTRLNIV=="*",oAll,If((cArquivo)->CTRLNIV=="!",oCmp,Nil) )))},,,,"LEFT" , 15, .T., .F.,,,, .F., ))
oBrowse:AddColumn( TCColumn():New( "",{ || PcoRetRes((cArquivo)->ALIAS ) },,,, "LEFT", 15, .T., .F.,,,, .T., ))

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

If !lUser
	If !lRevisao
		dbSelecTArea("AKK")
		dbSeek(xFilial())
		While !Eof() .And. AKK_FILIAL==xFilial("AKK")

			If ExistBlock("PCOAKKLST")
				//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//P_E³ Ponto de entrada utilizado para valir se o totalizador deve ser        ³
				//P_E³ apresentado.                                                           ³
				//P_E³ Parametros : nil                                                       ³
				//P_E³ Retorno    : lRet (.T. = Apresentado, .F. = Não será apresentado)      ³
				//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAreaAKK := AKK->(GetArea())
				lRet := ExecBlock("PCOAKKLST",.F.,.F.)
				RestArea(aAreaAKK)
			EndIf
			If ValType(lRet)<>"L" .or. lRet
				aAdd(aFolder,AllTrim(AKK_DESCRI))
				aAdd(aAKKLoad,AKK->(RecNo()))
			Endif
			dbSkip()
		EndDo

	EndIf
	oFolder := TFolder():New(121,2,aFolder,{},oDlg,,,, .T., .T.,390,110)
	oFolder:bSetOption := {|nDst| PcoChgFld(nDst,oFolder:nOption,oFolder,aAKKLoad,cArquivo)}
	oFolder:Align := CONTROL_ALIGN_BOTTOM
	oFolder:bLostFocus := {||If(oFolder:nOption>1, (oObj	:= oFolder:aDialogs[oFolder:nOption],MsFreeObj(oFolder:aDialogs[oFolder:nOption],.T.)),NIL)}

	oFolder:aDialogs[1]:oFont := oDlg:oFont
	oPanel := TPanel():New(1,1,'',oFolder:aDialogs[1],oDlg:oFont, .T., .T.,, ,20,26,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	@ 9,005 BUTTON oCopia Prompt STR0002 SIZE 35 ,9  FONT oDlg:oFont ACTION {|| (lEdit := PcoVldFase("AMR",cAK1Fase,"0008",.T.)) , If(lEdit,PcoCopy_aCols(oGd[1], aColsCopy, aClone(aFormula)),NIL) } OF oPanel PIXEL WHEN .F. //"Copiar"
	@ 9,045 BUTTON oCola  Prompt STR0003 SIZE 35 ,9  FONT oDlg:oFont ACTION {|| (lEdit := It_Orc_Lock(cArquivo,cRevisa,oGD[1],aRecNoVisible)) , (lEdit := PcoVldFase("AMR",cAK1Fase,"0008",.T.)) , If(lEdit,(oWrite:bWhen := {|| .T. },nRecEdic := (cArquivo)->(Recno()),If(PcoColar_aCols(oGd[1], aColsCopy, aFormCopy),(oCopia:bWhen := {||.F.},oCola:bWhen := {||.F.},oEdit:bWhen := {||.F.},oWrite:bWhen := {||.T.}),NIL),oGD[1]:oBrowse:SetFocus()),NIL) } OF oPanel PIXEL WHEN .F. //"Colar"
	@ 9,085 BUTTON oEdit  Prompt STR0004 SIZE 35 ,9  FONT oDlg:oFont ACTION {|| (lEdit := PcoVldFase("AMR",cAK1Fase,"0008",.T.)) , If(lEdit, (oGD[1]:lInsert := .T.,oGD[1]:lUpdate := .T.,oGD[1]:lDelete := .T.,oGD[1]:oBrowse:SetFocus(),oWrite:bWhen := {|| .T. },oFormula:bWhen := {|| .T. },nRecEdic := (cArquivo)->(Recno())), .F. )}OF oPanel PIXEL WHEN .F. //"Editar"
	@ 9,125 BUTTON oWrite Prompt STR0005 SIZE 35 ,9  FONT oDlg:oFont ACTION {|| If(oGD[1]:TudoOk() .AND. PcoVldLim(oGD[1],AK3->AK3_CO,AK1->AK1_CODIGO),(PcoIniLan("000252"),Processa({||PcoWriteIt(cArquivo,cRevisa,oGD[1],aRecNoVisible)},,STR0081),PcoFinLan("000252"),oGD[1]:lInsert := .F.,oGD[1]:lUpdate := .F.,oGD[1]:lDelete := .F.,oWrite:bWhen := {|| .F. },oFormula:bWhen := {|| .F. }, Eval(oBrowse:bChange)),Nil) }  OF oPanel PIXEL When .F. //"Gravar" ### "Atualizando itens do orçamento..."

	If lVisual
		oPanel:Hide()
	EndIf

	oGrpForm := TGroup():New(1, 170, 22, 445, STR0006, oPanel,,, .T.) //"Formula"

	@ 9,175 BUTTON oFormula Prompt If(lVisual, STR0007, STR0004) SIZE 35 ,9  FONT oDlg:oFont ACTION {|| Digit_Form(oGd[1], oForm_Get, lVisual, nColGd, oFormAband, oFormAply ) }  OF oPanel PIXEL WHEN If(lVisual, .T., Eval(oWrite:bWhen)) //"Visualizar"###"Editar"
	oFormula:bGotFocus := {||nColGd := oGd[1]:oBrowse:nColPos,;
								cFormAnt:=cFormula:=PadR(Ret_Formula(oGd[1], oGd[1]:oBrowse:nColPos), Len(AK2->AK2_FORMUL))/*,		If(lVisual, NIL, (oFormAband:Show(),oFormAply:Show()))*/ }
	cFormula := Space(LEN(AK2->AK2_FORMUL))
	cCpoForm := "cFormula"
	cBlkGet := "{ | u | If( PCount() == 0, "+cCpoForm+","+cCpoForm+":= u ) }"
	cFormValid := ".T."//Form_Valid(cFormula,lVisual, oGd[1], nColGd) .AND. PCOValidF(cFormula)"
	cFormWhen := ".T."
	cBlKVld := "{|| "+cFormValid+"}"
	cBlKWhen := "{|| "+cFormWhen+"}"
	cFormPict := "@!"

	oForm_Get := TGet():New( 8, 215,&cBlKGet,oPanel,150,10,cFormPict, &(cBlkVld),,,, .F.,, .T.,, .F., &(cBlkWhen), .F., .F.,, .F., .F. ,/*cF3*/,cFormula/*(cCpoForm)*/)
	oForm_Get:Hide()

	If !lVisual
		@ 9,368 BUTTON oFormAply Prompt STR0008 SIZE 35, 9  FONT oDlg:oFont ACTION {|| If(lEdit,Form_Aplicar(cFormula,lVisual, oGd[1], nColGd),NIL) }  OF oPanel PIXEL  //"Aplicar"
		@ 9,405 BUTTON oFormAband Prompt STR0009 SIZE 35, 9 FONT oDlg:oFont ACTION {|| If(lEdit,Form_RetAnt(cFormAnt, lVisual, oGd[1], nColGd),NIL) }  OF oPanel PIXEL //"Abandonar"
    EndIf

    //os botoes abaixo sao para desvio de foco
	@ 9,3575 BUTTON oFormZe Prompt "" SIZE 35 ,9  FONT oDlg:oFont ACTION {|| .T. }  OF oPanel PIXEL
	@ 9,3575 BUTTON oFormZe1 Prompt "" SIZE 35 ,9  FONT oDlg:oFont ACTION {|| .T. }  OF oPanel3 PIXEL

	oGD[1]	:= MsNewGetDados():New(2,2,2,2,,"PcoxGD1LinOK","PcoxGD1TudOK",/*"+AK2_ID"*/,/*aalter*/,2,MAX_COL_AK2,/*fieldok*/,/*superdel*/,"PcoDelGdOK"/*delok*/,oFolder:aDialogs[1],aHeaderAK2,aColsAK2)
	oGD[1]:AddAction("AK2_VAL",{||PcoPlanEdt()})
	oGD[1]:AddAction("AK2_IDENT",{||PcoIdentF3()})
	oGD[1]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGD[1]:oBrowse:bGotFocus := {||oForm_Get:Hide(),If(lVisual, (oCopia:bWhen:={||.F.},oCola:bWhen:={||.F.},oEdit:bWhen:={||.F.},oWrite:bWhen:={||.F.}), (oFormAband:Hide(),oFormAply:Hide()))}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³bAdd usado para fase 0007 - inclusao de item na planilha     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGD[1]:oBrowse:bAdd:={|| PCOVldFLin()}

	dbSelectArea("AKE")
	dbSetOrder(1)
	If dbSeek(xFilial("AKE")+AK1->AK1_CODIGO+cRevisa) .And. ;
		AKE->AKE_TIPO=="2"   //simulacao
		TSay():New( 1, (oPanel3:nWidth/2)-35, MontaBlock("{||'"+STR0010+cRevisa+"'}"), oPanel3 , ,,,,,.T.,CLR_HRED,,,,,,,,)//"Simulacao - "
    EndIf
	oBrowse:Refresh()
	oBrowse:SetFocus()

EndIf

If ExistBlock("PcoValid")
	lValid:=ExecBlock("PcoValid",.F.,.F.,cArquivo)
EndIf

If lValid
	IF cPaisLoc == "RUS"
		ACTIVATE MSDIALOG oDlg ON INIT (oBrowse:Refresh(), EnchoiceBar(oDlg,{||(If(!lUser .And. PcoAbandEdt(oGd, .T./*lFullPlan*/, lVisual,cRevisa),(lConfirma:=.T.,oDlg:End()),oDlg:End()))},;
		{|| If(lUser,  oDlg:End(), If(PcoAbandEdt(oGd, .T./*lFullPlan*/, lVisual,cRevisa),(AK3->(MsUnlockAll()), oDlg:End()), NIL)) },, aButtons,,,,.F. ))
	Else
	ACTIVATE MSDIALOG oDlg ON INIT (oBrowse:Refresh(), EnchoiceBar(oDlg,{||(If(!lUser .And. PcoAbandEdt(oGd, .T./*lFullPlan*/, lVisual,cRevisa),(lConfirma:=.T.,oDlg:End()),))},;
	{|| If(lUser,  oDlg:End(), If(PcoAbandEdt(oGd, .T./*lFullPlan*/, lVisual,cRevisa),(AK3->(MsUnlockAll()), oDlg:End()), NIL)) },, aButtons,,,,.F. ))
	EndIF
Endif

dbSelectArea(cArquivo)
dbCloseArea()

If _oPCOXINC1 <> Nil
	_oPCOXINC1:Delete()
	_oPCOXINC1:= Nil
Endif

If _cNomProc1 != NIL .And. TCSPExist( _cNomProc1+"_"+cEmpAnt )
	cRet := TcSqlExec("Drop procedure "+_cNomProc1+"_"+cEmpAnt)
	If cRet <> 0
		MsgAlert("Error in drop procedure: "+_cNomProc1 +". Manually delete from the database.")
	Endif
EndIf

If _cNomProc2 != NIL .And. TCSPExist( _cNomProc2+"_"+cEmpAnt )
	cRet := TcSqlExec("Drop procedure "+_cNomProc2+"_"+cEmpAnt)
	If cRet <> 0
		MsgAlert("Error in drop procedure: "+_cNomProc2 +". Manually delete from the database.")
	Endif
EndIf

_lProcCCUs := NIL
_cNomProc1 := NIL
_lProcICUs := NIL
_cNomProc2 := NIL

Return lConfirma

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPlanCl³ Autor ³ Edson Maricate         ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem das celulas da planilha Orcamentaria       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoPlanCl(cAlias)
Local ny
Local na
Default cAlias := "AK2"

//Se ak2_classe estiver em branco ou não foi alterado, não excluir valores orçados
For na := 1 to Len(aCols)
	If (AllTrim(aCols[na][5])) == &("M->AK2_CLASSE") 
		Return .T.
	EndIf 
Next na

For ny := 1 to Len(aHeader)
	If AllTrim(aHeader[ny][2])== cAlias + "_VAL"
		aCols[n][ny] := PcoPlanCel(0,&("M->" + cAlias + "_CLASSE") )
	EndIf
Next ny

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPln_Cl³ Autor ³                        ³ Data ³ 22-10-2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem das celulas da planilha Orcamentaria       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoPln_Cl(cAlias)
Local ny
Default cAlias := "AK2"
For ny := 1 to Len(oGD[1]:aHeader)
	If AllTrim(oGD[1]:aHeader[ny][2])== cAlias + "_VAL"
		oGD[1]:aCols[n][ny] := PcoPlanCel(0,&("M->" + cAlias + "_CLASSE") )
	EndIf
Next ny

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPlanVal³ Autor ³ Edson Maricate        ³ Data ³ 23-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o conteudo numerico da string do campo                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoPlanVal(cTexto,cClasse)
Local nRet		:= 0
Local aArea		:= GetArea()
Local aAreaAK6	:= AK6->(GetArea())
Local cPicture	:= ""
Local nX

Local cSepMilhar
Local cSepDecimal
Local cMileUm

If Valtype( cTexto ) == "N"
	cTexto := Str(cTexto)
EndIf

//------------------------------------------------------------------------------------
//este trecho de codigo eh somente para descobrir qual o separador decimal e de Milhar
cMileUm := Alltrim(Transform(1000.01, "@E 999,999.99"))
cSepDecimal := PadR(Right(cMileUm,3),1)
cSepMilhar  := PadR(Right(cMileUm,7),1)
//------------------------------------------------------------------------------------
dbSelectARea("AK6")
dbSetOrder(1)
dbSeek(xFilial()+cClasse)
If !Empty(AK6->AK6_SYMBOL)
	cTexto := StrTran(cTexto,Alltrim(AK6->AK6_SYMBOL),"")
EndIf

If AK6->AK6_FORMAT $ "1/3"

	If AK6->AK6_DECIMA > 0
		@cPicture := "@E " + Replicate("9",TamSx3("AKD_VALOR1")[1] - (AK6->AK6_DECIMA + 1) )
		@cPicture += "."+Replicate("9",AK6->AK6_DECIMA)
	Else
		@cPicture := "@E " + Replicate("9",TamSx3("AKD_VALOR1")[1] )
	EndIf

Else

	nX := tamSx3("AKD_VALOR1")[1]
	If AK6->AK6_DECIMA > 0
		@cPicture := "."+Replicate("9",AK6->AK6_DECIMA)
		nX -= (AK6->AK6_DECIMA + 1 )
	EndIf
	//********************************
	// Monta Picture de acordo com o *
	// campo AKD_VALOR1.			 *
	//********************************
	While nX>0
		If nX>=4
			@cPicture := "999" + cPicture
			nX -= 3
			If nX > 1
				@cPicture := "," + cPicture
				nX -= 1
			Else
				nX := 0
			EndIf
		Else
			@cPicture := Replicate("9",nX) + cPicture
			nX := 0
		EndIf
	EndDo
	@cPicture := "@E " + cPicture

EndIf

If "@E" $ cPicture
    //primeiro transforma os "." em ""   --> Separador de Milhar
	cTexto := StrTran(cTexto, cSepMilhar, "")
	//depois transforma as "," em "."    ---> Separador Decimal (somente um)
	cTexto := StrTran(cTexto, cSepDecimal, ".")
EndIf

If "("$cTexto
	cTexto := StrTran(cTexto,"(","")
	cTexto := StrTran(cTexto,")","")
	nRet := -Val(cTexto)
Else
	nRet := Val(cTexto)
EndIf

If nRet < 0 .And. Isincallstack("MSEXECAUTO") .And. Isincallstack("PCOAOOLIT") .And. Isincallstack("PCOA100") .And. IsBlind()
	nRet := nRet * -1
EndIf



RestArea(aAreaAK6)
RestArea(aArea)
Return nRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PcoPlanEdt³ Autor ³ Edson Maricate        ³ Data ³23.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria um Get para edicao da celula da planilha de itens      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PcoPlanEdt()

Local oDlg
Local oRect
Local oGet1
Local oBtn
Local cMacro := ''
Local cPict	:= ''
Local nRow   := oGD[1]:oBrowse:nAt
Local oOwner := oGD[1]:oBrowse:oWnd
//Local cValid := IIf(cValidCpo==Nil,'.T.',cValidCpo)+'.And.Eval(bChange)'
Local cValid := 'Eval(bChange)'
Local cClasse, nValor
Local cVlrFinal := ""
Local nPosClasse := aScan(oGD[1]:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})
Local cFormula	:= Ret_Formula(oGd[1],  oGD[1]:oBrowse:nColPos, n)
Local lContinua	:= .T.
Local nPosForm, nX, nPosHead, aCelAlt
Local nVlrFinal := 0

//variaveis para carregar os valores armazenados na planilha excel
Private nValueExcel := 0
Private cFormAK2    := cFormula
Private aFormExcel  := {}

If !Empty(cFormula) .And. "PCOSETLINK"$AllTrim(Upper(cFormula))
	If Aviso(STR0033,STR0011+; //'Integracao Excel - Planilha Orçamentária'###"Este periodo esta vinculado a uma planilha em formato Excel ( XLS ). Voce deseja abrir aplanilha em modo edição ou alterar o conteudo manualmente ? ( Alterar o valor manualmente não garante a atualização da planilha Excel )"
									CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0012,{"Excel",STR0013},3,STR0014,,"MDIEXCEL")==1 //"Obs.: O modo edição requer o Microsoft Excel instalado."###"Manual"###"Planilhas Excel (XLS) "
		nPosIni := AT("PCOSETLINK(",cFormula)+12
		nPosFim := AT(",",Substr(cFormula,nPosIni))-2
		cObjeto := Substr(cFormula,nPosIni,nPosFim)

        //arquivo para controle da planilha e versao
        dbSelectArea("AKE")
		dbSetOrder(1)
		dbSeek(xFilial()+AK1->AK1_CODIGO+cRevisa)

		dbSelectArea("ACB")
		dbSetOrder(2)
		If At("][", cObjeto) == 0 .And. dbSeek(xFilial()+"["+Alltrim(AK1->AK1_CODIGO)+"]["+cRevisa+"]"+cObjeto)
           cObjeto := Alltrim(ACB->ACB_OBJETO)
			PcoXlsOpen(,,cObjeto,.T.)
		ElseIf dbSeek(xFilial()+cObjeto)
			PcoXlsOpen(,,cObjeto,.T.)
		Else
			Aviso(STR0033,STR0015,{STR0001},2,STR0016,,"MDIEXCEL")  //'Integracao Excel - Planilha Orçamentária'###"O nome da planilha especificado na formula está invalido ou inexistente. Verifique a formula digitada para este periodo."###"Fechar"###"Formula invalida"
			lContinua := .F.
		EndIf

        If lContinua
			//atualizar as colunas afetadas pela mudanca da planilha
			//array aFormExcel contem as celulas alteradas
			// este array e atualizado ao sincronizar a base AK2 com o Excel
			// funcao PcoExcFin()
			// 1 - Celula
			// 2 - Formula
			// 3 - Inicio do Periodo (data - q gravou em AK2_PERIOD)
			// 4 - Classe
			// 5 - Valor ja alterado ( q gravou em AK2_VALOR

			//carrega as alteracoes
			//o array a aCelAlt tera os seguintes elementos
			//1 - Linha do Acols
			//2 - cabecalho do periodo
			//3 - classe orcamentaria
			//4 - valor atualizado no excel
			aCelAlt := {}
			For nX := 1 TO Len(aFormExcel)
                nPosForm := ASCAN(aFormula, {|aVal| Upper(Alltrim(aVal[3])) == Upper(Alltrim(aFormExcel[nX][2]))})
                If nPosForm > 0
			       aAdd(aCelAlt, {aFormula[nPosForm][1], aFormula[nPosForm][2], aFormExcel[nX][4], aFormExcel[nX][5]})
			    EndIf
			Next

			//atualiza a grade (acols)
			For nX := 1 TO Len(aCelAlt)
				nPosHead := aScan(oGD[1]:aHeader,{|x| AllTrim(x[1]) == aCelAlt[nX][2]})
				If nPosHead > 0
					oGd[1]:Acols[aCelAlt[nX][1]][nPosHead] := PcoPlanCel(aCelAlt[nX][4],aCelAlt[nX][3])
				EndIf
			Next

			//atualizar celula atual em edicao
			If nMvPar != 4 .Or. nPosClasse > 0
				cClasse	:= oGD[1]:aCols[n][nPosClasse]
			Else
				cClasse := M->AK2_CLASSE
			EndIf

            If !Empty(cClasse)
				cVlrFinal := PcoPlanCel(nValueExcel,cClasse)
				oGD[1]:aCols[n][oGD[1]:oBrowse:nColPos]	:= cVlrFinal
				oGD[1]:oBrowse:nAt := nRow

				SetFocus(oGD[1]:oBrowse:hWnd)
				oGD[1]:oBrowse:Refresh()
			EndIf
		EndIf
		lContinua	:= .F.
	Else
		lContinua	:= .T.
	EndIf
EndIf

If lContinua
	If nMvPar != 4 .Or. nPosClasse > 0
		cClasse	:= oGD[1]:aCols[n][nPosClasse]
	Else
		cClasse := M->AK2_CLASSE
	EndIf

	If Empty(cClasse)
	   Return(cVlrFinal)
	EndIf

	nValor	:= PcoPlanVal(oGD[1]:aCols[n][oGD[1]:oBrowse:nColPos], cClasse)

	bChange := { ||  nValor := &cMacro }
	oRect := tRect():New(0,0,0,0)            // obtem as coordenadas da celula (lugar onde
	oGD[1]:oBrowse:GetCellRect(oGD[1]:oBrowse:nColPos,,oRect)   // a janela de edicao deve ficar)
	aDim  := {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

	DEFINE MSDIALOG oDlg OF oOwner  FROM 0, 0 TO 0, 0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL

	PcoPlanCel(0,cClasse,,@cPict)
	cMacro := "M->CELL"
	&cMacro:= nValor

	@ 0,0 MSGET oGet1 VAR &(cMacro) SIZE 0,0 OF oDlg FONT oOwner:oFont PICTURE cPict PIXEL HASBUTTON VALID &cValid
	oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) + 4, aDim[ 3 ] - aDim[ 1 ] + 4 )

	@ 0,0 BUTTON oBtn PROMPT "" SIZE 0,0 OF oDlg
	oBtn:bGotFocus := {|| oDlg:nLastKey := VK_RETURN, oDlg:End(0)}

	oGet1:cReadVar  := cMacro

	ACTIVATE MSDIALOG oDlg ON INIT oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

	cVlrFinal := PcoPlanCel(nValor,cClasse)
	//Não se deve incluir valores negativos na planilha orçamentária
	nVlrFinal := Val(cVlrFinal)

	If !Positivo(nVlrFinal)
		nVlrFinal := Abs(nVlrFinal)
		cVlrFinal := PcoPlanCel(nVlrFinal,cClasse)
		cVlrFinal := Str(nVlrFinal)
	EndIf

	oGD[1]:aCols[n][oGD[1]:oBrowse:nColPos]	:= cVlrFinal
	oGD[1]:oBrowse:nAt := nRow

	SetFocus(oGD[1]:oBrowse:hWnd)
	oGD[1]:oBrowse:Refresh()
EndIf

Return(cVlrFinal)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPlanIt³ Autor ³ Edson Maricate         ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem dos itens da planilha orcamentaria         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoPlanIt(cArquivo,cVersao,oGD,aRecNoVisible,lProcessa)
Local ny            := 0
Local nZ            := 0
Local aAuxArea		:= {}
Local aArea			:= GetArea()
Local nHeadItem		:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_ID"})
Local nPos			:= 0
Local aAreaAK3 		:= AK3->(GetArea())
Local lContinua		:=	.T.
Local cQuery		:=	''
Local lQuery		:=	.F.
Local aCCNO			:=	{}
Local aITNO			:=	{}
Local aCLNO	  		:=	{}
Local cIdAnt		:=	""
Local nPosClasse	:=	aScan( oGD:aHeader, {|x|AllTrim(x[2])=="AK2_CLASSE"})	// Posicao da Classe Orcamentaria no aCols
Local cAliasAK2	:=	"AK2"
Local aPeriodos	:=	PcoRetPer()
Local lEntidades	:=	.T.
Local nConta		:=	0
Local lQueryAK2		:=	.F.
Local aContas, cContaIn, nX
Local cCenCus, nPosCC := aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_CC"})

DEFAULT lProcessa	:=	.F.

If _nPQrySize == Nil
	//Valor 32768 DEFAULT definido de acordo com a documentação:
	//https://tdn.totvs.com/pages/viewpage.action?pageId=372543595
	_nPQrySize := GetPvProfileInt("GENERAL","MAXQUERYSIZE",32768,GetSrvIniName())
EndIf

If (cArquivo)->ALIAS == "AK3"
	dbSelectArea("AK3")
	dbGoto((cArquivo)->RECNO)
	If AK3->( FieldPos("AK3_LOGLCK")) > 0
		cLastAK3Read	:=	AK3->AK3_LOGLCK
	Endif
Else
	lContinua	:=	.F.
EndIf

oGD:aCols	:= {}
aFormula := {}

If lContinua
	If  ! PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"ITENS",cVersao)
		lContinua	:=	.F.
	Endif
	If  lRevisao .And. ! PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"REVISA",cVersao)
		lContinua	:=	.F.
	EndIf
	If AK3->AK3_TIPO <> "2"
		lContinua	:=	.F.
	Endif
EndIf

If lContinua

	If TcSrvType()<> "AS/400" .and. TCGetDB()!="SYBASE"

		lQuery	:=	.T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificar se existem restricoes por CC, se nao existir, nao consulta as restricoes CC a CC³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//procurar todas as contas superiores
   		aContas := {}
	   	cContaIn := ""
   		Pco_Sup_Cta( (cArquivo)->XK3_CO, aContas, cVersao)
   		For nX := 1 TO Len(aContas)
	   		cContaIn +=  "'"+aContas[nX]+If(nX!=Len(aContas), "',", "'")
	   	Next

        If Empty(cContaIn)  //isto somente vai ocorrer quando usuario excluir a
        					//conta orcamentaria em outra sessao
        	RestArea(aAreaAK3)
        	Aviso(STR0022, STR0083, {"Ok"})  //STR0022##"Conta Orcamentaria nao encontrada. Verifique!!"
        	lContinua := .F.
        EndIf

		If lContinua
	   		cQuery	:=	" SELECT COUNT(*) CONTA FROM "+RetSqlName('AKG')+" AKG "
	   		cQuery	+=	" WHERE AKG_FILIAL='"+xFilial('AKG')+"' AND AKG_ORCAME='"+AK1->AK1_CODIGO+"' "
	   		cQuery	+=	" AND AKG_CO IN("+cContaIn+") "
	   		cQuery	+=	"AND AKG_CCUSTO = '1' " //tem restricao por centro de custo
	   		cQuery	+=	" AND D_E_L_E_T_= ' ' "
	   		cQuery	:=	ChangeQuery(cQuery)
  			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
			nConta	:=	QRYTRB->CONTA
			DbCloseArea()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Agrupa os CCs e verifica as restricoes so uma vez por cada CC³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  nConta > 0
		   		cQuery	:=	" SELECT AK2_CC FROM "+RetSqlName('AK2')+" AK2 "
		   		cQuery	+=	" WHERE AK2_FILIAL='"+xFilial('AK2')+"' AND AK2_ORCAME='"+AK1->AK1_CODIGO+"' "
	   			cQuery	+=	" AND AK2_VERSAO='"+ cVersao +"' AND AK2_CO='"+ (cArquivo)->XK3_CO +"' AND AK2_CC <> '' "
		   		cQuery	+=	" AND D_E_L_E_T_= ' ' GROUP BY AK2_CC "
		   		cQuery	:=	ChangeQuery(cQuery)
	  			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
	    	     While !Eof()
					If ! PcoCC_User(AK1->AK1_CODIGO,(cArquivo)->XK3_CO,AK3->AK3_PAI,2,"CCUSTO",cVersao,QRYTRB->AK2_CC)
						AAdd(aCCNO,QRYTRB->AK2_CC)
					Endif
					DbSkip()
	         	Enddo
	         	DbCloseArea()
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificar se existem restricoes por Item contabil , se nao existir, nao consulta as       ³
			//³ restricoes Item a Item                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		cQuery	:=	" SELECT COUNT(*) CONTA FROM "+RetSqlName('AKG')+" AKG "
   			cQuery	+=	" WHERE AKG_FILIAL='"+xFilial('AKG')+"' AND AKG_ORCAME='"+AK1->AK1_CODIGO+"' "
	   		cQuery	+=	" AND AKG_CO IN("+cContaIn+") "
   			cQuery	+=	" AND AKG_ITMCTB = '1' "
	   		cQuery	+=	" AND D_E_L_E_T_= ' ' "
   			cQuery	:=	ChangeQuery(cQuery)
  			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
			nConta	:=	QRYTRB->CONTA
        	DbCloseArea()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Agrupa os Itens e verifica as restricoes so uma vez por cada Item³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  nConta > 0
		   		cQuery	:=	" SELECT AK2_ITCTB FROM "+RetSqlName('AK2')+" AK2 "
		   		cQuery	+=	" WHERE AK2_FILIAL='"+xFilial('AK2')+"' AND AK2_ORCAME='"+AK1->AK1_CODIGO+"' "
	   			cQuery	+=	" AND AK2_VERSAO='"+ cVersao +"' AND AK2_CO='"+ (cArquivo)->XK3_CO +"' AND AK2_ITCTB<>''"
	   			cQuery	+=	" AND D_E_L_E_T_= ' ' GROUP BY AK2_ITCTB "
		   		cQuery	:=	ChangeQuery(cQuery)
	  			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
    	        While !Eof()
					If !PcoIC_User(AK1->AK1_CODIGO,(cArquivo)->XK3_CO,AK3->AK3_PAI,2,"ITMCTB",cVersao,QRYTRB->AK2_ITCTB)
						AAdd(aITNO,QRYTRB->AK2_ITCTB)
					Endif
					DbSkip()
   	      		Enddo
     			DbCloseArea()
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificar se existem restricoes por Classe de valor, se nao existir, nao consulta as      ³
			//³ restricoes Classe a Classe                                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		cQuery	:=	" SELECT COUNT(*) CONTA FROM "+RetSqlName('AKG')+" AKG "
   			cQuery	+=	" WHERE AKG_FILIAL='"+xFilial('AKG')+"' AND AKG_ORCAME='"+AK1->AK1_CODIGO+"' "
	   		cQuery	+=	" AND AKG_CO IN("+cContaIn+") "
   			cQuery	+=	" AND AKG_CLAVLR = '1' "
	   		cQuery	+=	" AND D_E_L_E_T_= ' ' "
   			cQuery	:=	ChangeQuery(cQuery)
  			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
			nConta	:=	QRYTRB->CONTA
			DbCloseArea()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Agrupa as Classes e verifica as restricoes so uma vez por cada Classe³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  nConta > 0
		   		cQuery	:=	" SELECT AK2_CLVLR FROM "+RetSqlName('AK2')+" AK2 "
		   		cQuery	+=	" WHERE AK2_FILIAL='"+xFilial('AK2')+"' AND AK2_ORCAME='"+AK1->AK1_CODIGO+"' "
	   			cQuery	+=	" AND AK2_VERSAO='"+ cVersao +"' AND AK2_CO='"+ (cArquivo)->XK3_CO +"' AND AK2_CLVLR <> '' "
	   			cQuery	+=	" AND D_E_L_E_T_= ' ' GROUP BY AK2_CLVLR "
		   		cQuery	:=	ChangeQuery(cQuery)
	  			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
		        While !Eof()
				  	If ! PcoCV_User(AK1->AK1_CODIGO,(cArquivo)->XK3_CO,AK3->AK3_PAI,2,"CLAVLR",cVersao,QRYTRB->AK2_CLVLR)
						AAdd(aCLNO,QRYTRB->AK2_CLVLR)
					Endif
					DbSkip()
	        	 Enddo
		         DbCloseArea()
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificar se existem restricoes por Entidades, se nao existir, seta a variavel lEntidades ³
			//³ com FALSO para que nao seja verificado o acesso entidade por entidade                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		cQuery	:=	" SELECT COUNT(*) CONTA FROM "+RetSqlName('AKG')+" AKG "
   			cQuery	+=	" WHERE AKG_FILIAL='"+xFilial('AKG')+"' AND AKG_ORCAME='"+AK1->AK1_CODIGO+"' "
	 		cQuery	+=	" AND AKG_CO IN("+cContaIn+") "
	   		cQuery	+=	" AND AKG_ENTIDA = '1' "
   			cQuery	+=	" AND D_E_L_E_T_= ' ' "
   			cQuery	:=	ChangeQuery(cQuery)
  			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
			lEntidades	:=	( QRYTRB->CONTA > 0)
	         DbCloseArea()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a query do AK2, agrupando todos os itens, e trazendo encolumnados os valores dos    ³
			//³periodos, a estrutura do resultado eh a seguinte :                                        ³
			//³ID    CLASSE VALOR  ITEM  CC  (ETC)  (ETC)  PER001 PER002 PER003 .... PERNNN              ³
			//³0001  xxxxxxxxxx    xxxx  xx  xxxx   xxxx   valor1 valor2 valor3 .... valorN              ³
			//³0002  xxxxxxxxxx    xxxx  xx  xxxx   xxxx   valor1 valor2 valor3 .... valorN              ³
			//³A estrutura anterior era :                                                                ³
			//³ID    CLASSE VALOR  ITEM  CC  (ETC)  (ETC)  PERIODO       VALOR                           ³
			//³0001  xxxxxxxxxx    xxxx  xx  xxxx   xxxx   01/01/2006    valor1                          ³
			//³0001  xxxxxxxxxx    xxxx  xx  xxxx   xxxx   01/02/2006    valor2                          ³
			//³................................................................                          ³
			//³0001  xxxxxxxxxx    xxxx  xx  xxxx   xxxx   01/12/2006    valor12                         ³
			//³0002  xxxxxxxxxx    xxxx  xx  xxxx   xxxx   01/01/2006    valor1                          ³
			//³0002  xxxxxxxxxx    xxxx  xx  xxxx   xxxx   01/02/2006    valor2                          ³
			//³................................................................                          ³
			//³0002  xxxxxxxxxx    xxxx  xx  xxxx   xxxx   01/12/2006    valor12                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Alltrim(Upper(TcGetDB())) == "INFORMIX"
				cQuery	:=	""
			Else
				cQuery	:=	MontaQryAK2(cVersao,(cArquivo)->XK3_CO )
			EndIf

			If Len(cQuery) > _nPQrySize
				cQuery := ""
			EndIf

			If !Empty(cQuery)
	  	        lQueryAK2	:=	.T.
	  			cAliasAK2	:=	"QRYAK2"
  				dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYAK2", .F., .F. )

  				cAliasAK2	:=	"QRYAK2"
  				aStrAK2	:=	AK2->(DbStruct())
				For ny := 1 to Len(aStrAK2)
					If aStrAK2[nY,2] <> "C"
						TcSetField("QRYAK2",aStrAK2[nY,1],aStrAK2[nY,2] ,aStrAK2[nY,3] ,aStrAK2[nY,4] )
					Endif
				Next
			Else
				cAliasAK2	:=	"AK2"
			Endif
		Endif
	  EndIf

	If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definir a regua    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lProcessa
		dbSelectArea("AK2")
		dbSetOrder(5)
		dbSeek(xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO+'zzzz',.T. )
		DbSkip(-1)
		If AK2->AK2_FILIAL + AK2->AK2_ORCAME + AK2->AK2_VERSAO + AK2->AK2_CO  == ;
				xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO
	    	ProcRegua(Val(AK2->AK2_ID))
		Endif
	Endif
	dbSelectArea(cAliasAK2)
	If !lQueryAK2
		dbSetOrder(5)
		MsSeek(xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO )
	Endif
	While !Eof() .And. (lQueryAK2 .Or. (cAliasAK2)->AK2_FILIAL + (cAliasAK2)->AK2_ORCAME + (cAliasAK2)->AK2_VERSAO + (cAliasAK2)->AK2_CO  == ;
							xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO )

		If lProcessa .And. (cAliasAK2)->AK2_ID <> cIDAnt
			IncProc()
	    	cIDAnt	:=	(cAliasAK2)->AK2_ID
		Endif

		If lEntidades	.And. !Pco_ChkEntd(AK1->AK1_CODIGO,cVersao,(cArquivo)->XK3_CO,AK3->AK3_PAI,2,(cArquivo)->RECNO,If(!lQueryAK2,"AK2",cAliasAK2))
			If !lQueryAK2
				aAdd(aRecNoVisible, AK2->(RECNO()))
			Else
				AK2->(DbSetOrder(5))
				AK2->(MsSeek(xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO + (cAliasAK2)->AK2_ID) )
				While !AK2->(Eof()) .And. (cAliasAK2)->AK2_FILIAL + (cAliasAK2)->AK2_ORCAME + (cAliasAK2)->AK2_VERSAO + (cAliasAK2)->AK2_CO +(cAliasAK2)->AK2_ID == ;
						AK2->AK2_FILIAL + AK2->AK2_ORCAME + AK2->AK2_VERSAO + AK2->AK2_CO +AK2->AK2_ID
					aAdd(aRecNoVisible, AK2->(RECNO()))
					AK2->(DbSkip())
					Loop
				Enddo
			Endif
			If lQueryAK2
				(cAliasAK2)->(dbSkip())
				Loop
			EndIf
		Endif
		If lQuery
			If (Ascan(aCCNO,	(cAliasAK2)->AK2_CC) > 0 .Or. Ascan(aITNO,	(cAliasAK2)->AK2_ITCTB) > 0 .Or. Ascan(aCLNO,	(cAliasAK2)->AK2_CLVLR) > 0 )
				If !lQueryAK2
					aAdd(aRecNoVisible, AK2->(RECNO()))
				Else
					AK2->(DbSetOrder(5))
					AK2->(MsSeek(xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO + (cAliasAK2)->AK2_ID) )
					While !AK2->(Eof()) .And. (cAliasAK2)->AK2_FILIAL + (cAliasAK2)->AK2_ORCAME + (cAliasAK2)->AK2_VERSAO + (cAliasAK2)->AK2_CO +(cAliasAK2)->AK2_ID == ;
							AK2->AK2_FILIAL + AK2->AK2_ORCAME + AK2->AK2_VERSAO + AK2->AK2_CO +AK2->AK2_ID
						aAdd(aRecNoVisible, AK2->(RECNO()))
						AK2->(DbSkip())
						Loop
					Enddo
				Endif
				(cAliasAK2)->(dbSkip())
				Loop
			Endif
		Else
			If ! PcoCC_User(AK1->AK1_CODIGO,(cArquivo)->XK3_CO,AK3->AK3_PAI,2,"CCUSTO",cVersao,	(cAliasAK2)->AK2_CC) .OR. ;
				! PcoIC_User(AK1->AK1_CODIGO,(cArquivo)->XK3_CO,AK3->AK3_PAI,2,"ITMCTB",cVersao,	(cAliasAK2)->AK2_ITCTB) .OR. ;
			  	! PcoCV_User(AK1->AK1_CODIGO,(cArquivo)->XK3_CO,AK3->AK3_PAI,2,"CLAVLR",cVersao,	(cAliasAK2)->AK2_CLVLR)
			   aAdd(aRecNoVisible, AK2->(Recno()))
			   AK2->(dbSkip())
			   Loop
			EndIf
		Endif
		nPosIt	:= aScan(oGD:aCols,{|x| x[nHeadItem] == (cAliasAK2)->AK2_ID})
		//Isto so acontecera em ambiente sem Query, por isso nao é neessaria a validacao
		If nPosIt > 0
			nPosHead := aScan(oGD:aHeader,{|x| CTOD(Substr(x[1],1,10))==(cAliasAK2)->AK2_PERIOD})
			If nPosHead > 0
				oGD:aCols[nPosIt,nPosHead] := PcoPlanCel((cAliasAK2)->AK2_VALOR,(cAliasAK2)->AK2_CLASSE)
				If (nPos := Ascan(aFormula, {|aVal|aVal[1]==nPosIt .And. ;
									aVal[2]==Alltrim(oGD:aHeader[nPosHead,1])})) == 0
			   		aAdd(aFormula, {nPosIt, Alltrim(oGd:aHeader[nPosHead,1]), (cAliasAK2)->AK2_FORMUL})
			    EndIf
			EndIf
		Else
			aADD(oGD:aCols,Array(Len(oGD:aHeader)+1))
			oGD:aCols[Len(oGD:aCols),Len(oGD:aHeader)+1] := .F.
			For ny := 1 to Len(oGD:aHeader)
				Do Case
					Case AllTrim(oGD:aHeader[ny,2])=="AK2_VAL"
						If lQueryAK2
							nPosHead := aScan(oGD:aHeader,{|x| CTOD(Substr(x[1],1,10))==(cAliasAK2)->AK2_PERIOD})
							For nZ	:=	1	To Len(aPeriodos)
								nPosHead := aScan(oGD:aHeader,{|x| x[1]==aPeriodos[nZ]})
								If nPosHead > 0
									oGD:aCols[Len(oGD:aCols),nPosHead] := PcoPlanCel(&("P"+StrZero(nZ,2)),	(cAliasAK2)->AK2_CLASSE)
								EndIf
							Next
						Else
							nPosHead := aScan(oGD:aHeader,{|x| CTOD(Substr(x[1],1,10))==	(cAliasAK2)->AK2_PERIOD})
							If nPosHead > 0
								oGD:aCols[Len(oGD:aCols),nPosHead] := PcoPlanCel(	(cAliasAK2)->AK2_VALOR,	(cAliasAK2)->AK2_CLASSE)
								If (nPos := Ascan(aFormula, {|aVal|aVal[1]==Len(oGD:aCols) .And. ;
																	aVal[2]==Alltrim(oGD:aHeader[nPosHead,1])})) == 0
									aAdd(aFormula, {Len(oGD:aCols), Alltrim(oGd:aHeader[nPosHead,1]), 	(cAliasAK2)->AK2_FORMUL})
							    EndIf
							EndIf
						Endif
						//inicializa todos os periodos orcamentarios com CriaVar()
						//caso esteja preenchida, passa classe como parametro para montar o formato dos valores
						If oGD:aCols[Len(oGD:aCols),nY] == Nil
							If Empty( oGD:aCols[Len(oGD:aCols),nPosClasse] )
								oGD:aCols[Len(oGD:aCols),nY] := PcoPlanCel(CriaVar(oGD:aHeader[ny,2]))
							Else
								oGD:aCols[Len(oGD:aCols),nY] := PcoPlanCel(CriaVar(oGD:aHeader[ny,2]),oGD:aCols[Len(oGD:aCols),nPosClasse])
							EndIf
						Endif
					Case AllTrim(oGD:aHeader[ny,2])=="AK2_IDENT"
						If !Empty(	(cAliasAK2)->AK2_CHAVE )
							aAuxArea := GetArea()
							PcoPosAK6((cAliasAK2)->AK2_CLASSE)
							If !Empty(AK6->AK6_VISUAL)
								dbSelectArea(Substr(	(cAliasAK2)->AK2_CHAVE,1,3))
								dbSetOrder(If(!Empty(Substr(	(cAliasAK2)->AK2_CHAVE,4,2)), Val(Substr(	(cAliasAK2)->AK2_CHAVE,4,2)), 1))
								dbSeek(Substr(	(cAliasAK2)->AK2_CHAVE,6,Len(	(cAliasAK2)->AK2_CHAVE)))
								oGD:aCols[Len(oGD:aCols),ny] := &(AK6->AK6_VISUAL)
							EndIf
							RestArea(aAuxArea)
						EndIf
					Case AllTrim(oGD:aHeader[ny,2])=="AK2_DESCLA"
						aAuxArea := GetArea()
						If PcoPosAK6((cAliasAK2)->AK2_CLASSE )
							oGD:aCols[Len(oGD:aCols),ny] := AK6->AK6_DESCRI
						EndIf
						RestArea(aAuxArea)
						Case AllTrim(oGD:aHeader[ny,2])=="AK2_DESCCC"
							aAuxArea := GetArea()
							cCenCus := oGD:aCols[Len(oGD:aCols),nPosCC]
							Posicione("CTT", 1, xFilial("CTT")+cCenCus, "CTT_DESC01")
							oGD:aCols[Len(oGD:aCols),ny] := CTT->CTT_DESC01
							RestArea(aAuxArea)
					Case AllTrim(oGD:aHeader[ny,2])=="AK2_UM"
						aAuxArea := GetArea()
						PcoPosAK6((cAliasAK2)->AK2_CLASSE)
						If !Empty(AK6->AK6_UM)
							If !Empty(	(cAliasAK2)->AK2_CHAVE)
								dbSelectArea(Substr(	(cAliasAK2)->AK2_CHAVE,1,3))
								dbSetOrder(Val(Substr(	(cAliasAK2)->AK2_CHAVE,4,2)))
								MsSeek(Substr(	(cAliasAK2)->AK2_CHAVE,6,Len(	(cAliasAK2)->AK2_CHAVE)))
							EndIf
							oGD:aCols[Len(oGD:aCols),ny] := &(AK6->AK6_UM)
						EndIf
						RestArea(aAuxArea)
					OtherWise
						If ( oGD:aHeader[ny,10] != "V")
							oGD:aCols[Len(oGD:aCols),ny] := FieldGet(FieldPos(oGD:aHeader[ny,2]))
						EndIf
				EndCase
			Next
			//Carregar as formulas
			If lQueryAK2
		   		cQuery	:=	" SELECT AK2_FORMUL, AK2_PERIOD FROM "+RetSqlName('AK2')+" AK2 "
		   		cQuery	+=	" WHERE AK2_FILIAL='"+xFilial('AK2')+"' AND AK2_ORCAME='"+(cAliasAK2)->AK2_ORCAME+"' "
		   		cQuery	+=	" AND AK2_VERSAO='"+ (cAliasAK2)->AK2_VERSAO +"' AND AK2_CO='"+ (cAliasAK2)->AK2_CO +"' AND AK2_ID = '"+(cAliasAK2)->AK2_ID+"' "
		   		cQuery	+=	" AND AK2_FORMUL <> '"+Space(Len(AK2->AK2_FORMUL))+"'  "
		   		cQuery	+=	" AND D_E_L_E_T_= ' ' "
   				cQuery	:=	ChangeQuery(cQuery)
  				dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
				While !EOF()
					nPosHead := aScan(oGD:aHeader,{|x| Dtos(CTOD(Substr(x[1],1,10)))==QRYTRB->AK2_PERIOD})
					If nPosHead	>	0
						If (nPos := Ascan(aFormula, {|aVal| aVal[1] == Len(oGD:aCols) .And. ;
																aVal[2]==Alltrim(oGD:aHeader[nPosHead,1])})) == 0
							aAdd(aFormula, {Len(oGD:aCols), Alltrim(oGd:aHeader[nPosHead,1]), 	QRYTRB->AK2_FORMUL})
						Endif
					EndIf
					DbSkip()
				Enddo
				DbCloseArea()
			Endif
		EndIf
		DbSelectArea(cAliasAK2)
		dbSkip()
	End
  Endif
Endif

If Empty(oGD:aCols)
	aadd(oGD:aCols,Array(Len(oGD:aHeader)+1))
	For ny := 1 to Len(oGD:aHeader)
		If AllTrim(oGD:aHeader[ny,2])=="AK2_ID"
			oGD:aCols[1,ny] := Padr("*", Len(AK2->AK2_ID))//StrZero(1,LEN(AK2->AK2_ID))
		ElseIf AllTrim(oGD:aHeader[ny,2])=="AK2_VAL"
			//inicializa todos os periodos orcamentarios com CriaVar()
			oGD:aCols[1,nY] := PcoPlanCel(CriaVar(oGD:aHeader[ny,2]))
		Else
			oGD:aCols[1,ny] := CriaVar(oGD:aHeader[ny,2])
		EndIf
	Next ny
	oGD:aCols[1,Len(oGD:aHeader)+1] := .F.
EndIf
If lQueryAK2
	dbSelectArea(cAliasAK2)
	DbCloseArea()
Endif

//***********************************************
// Ordenacao dos itens da planilha orçamentaria *
//  FNC:00000018910/2009                        *
//***********************************************
If TYPE("nOrdAK2")!="U" .And. VALTYPE(nOrdAK2)=="N"
	Pco100Ord( nOrdAK2, @oGD)
EndIf
aColsAux := oGD:aCols
oGD:oBrowse:Refresh()
RestArea(aAreaAK3)
RestArea(aArea)
Return

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³PcoAvalAK1³ AUTOR ³ Edson Maricate        ³ DATA ³ 05-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
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
Function PcoAvalAK1(cAlias,nEvento,lCriaAK3)
Local aArea 	:= GetArea()
Local aAreaAK1  := AK1->(GetArea())

DEFAULT lCriaAK3 := .T.

Do Case
	Case nEvento == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o arquivo de revisoes com o historico inicial.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("AKE",.T.)
		AKE->AKE_FILIAL := xFilial("AKE")
		AKE->AKE_ORCAME	:= AK1->AK1_CODIGO
		AKE->AKE_REVISA := AK1->AK1_VERSAO
		AKE->AKE_DATAI	:= MsDate()
		AKE->AKE_HORAI  := Time()
		AKE->AKE_DATAF  := MsDate()
		AKE->AKE_HORAF	:= Time()
		AKE->AKE_USERI  := __cUserId
		AKE->AKE_USERF  := __cUserId
		AKE->AKE_MEMO	:= STR0017 //"Evento : Inclusao da planilha orcamentaria"
		MsUnlock()
		If lCriaAK3
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o arquivo de Estrutura CO  com o nivel 001        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("AK3",.T.)
			AK3->AK3_FILIAL	:= xFilial("AK3")
			AK3->AK3_ORCAME	:= AK1->AK1_CODIGO
			AK3->AK3_DESCRI	:= AK1->AK1_DESCRI
			AK3->AK3_VERSAO	:= AK1->AK1_VERSAO
			AK3->AK3_CO		:= AK1->AK1_CODIGO
			AK3->AK3_NIVEL	:= "001"
			MsUnlock()
		EndIf
EndCase
RestArea(aAreaAK1)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoWriteIt³ Autor ³ Edson Maricate        ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de gravacao dos itens da planilha orcamentaria         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoWriteIt(cArquivo, cVersao, oGD, aRecNoVisible)

Local aArea				:= GetArea()
Local nHeadItem			:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_ID"})
Local aRecAK2			:= {}
Local nCntFor3			:= 0
Local nCntFor2			:= 0
Local nCntFor			:= 0
Local aItensOrcNoVisible:= {}, nX, aItensNew := {}, nPosAK2 := 0
Local cAK2Id   			:= Space(Len(AK2->AK2_ID))
Local cItemAK2 			:= Space(Len(AK2->AK2_ID))
Local nPos 				:= 0
Local aRecProc			:=	{}
Local nLenCols			:= Len(oGD:aCols)
Local nLenHeader		:= Len(oGD:aHeader)
Local nPosClasse		:= aScan(oGD:aHeader,{|x|AllTrim(x[2])=="AK2_CLASSE"})
Local lChanged			:=	.F.
Local lMudou			:=	.F.
Local lNewRec			:=	.F.
Local cContaIn 			:= ""
Local nLastNoVisID		:= ""
Local nLastAColsID		:= ""
Local nLastID			:= ""
Local aContas 			:= {}
Local aItensCols		:= {}
Local nN_			    := 0
Local aStruct 			:= {}
Local lRetPe            := .F.

Local lQryAK2 := ( TcGetDb() # "AS/400" .and. TCGetDB()!="SYBASE" )

//posiciona em AK3
AK3->(DbSetorder(1))
AK3->(DbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cVersao+(cArquivo)->XK3_CO))

//bloqueia a conta orcamentaria
Do While !LockByName(xFilial("AK3")+AK1->AK1_CODIGO+cVersao+(cArquivo)->XK3_CO,.T.,.T.,.T.)
	AvisoTimer(STR0021,	STR0091 +;	// "Aguardando o término da gravação dos itens da conta "
						RTrim((cArquivo)->XK3_CO) + STR0092,{"Ok"},,;	// " por outro usuário."
						STR0093,,"PCOLOCK",5000)	//"Conta Orçamentária em uso"
EndDo

cContaIn := ""
Pco_Sup_Cta( (cArquivo)->XK3_CO, aContas, cVersao)
For nX := 1 TO Len(aContas)
	cContaIn +=  "'"+aContas[nX]+If(nX!=Len(aContas), "',", "'")
Next

If Empty(cContaIn)  //isto somente vai ocorrer quando usuario excluir a
        					//conta orcamentaria em outra sessao
   	Aviso(STR0022, STR0084, {"Ok"})  //"Atencao"##"Conta Orcamentaria nao encontrada, portanto as alteracoes nao foram gravadas. Verifique!!"
   	Return  // lContinua := .F.
EndIf

If Len(aRecNoVisible) > 998 //Tratamento p/ evitar erro abaixo, No Oracle o maximo de elementos para IN é 1000.
                            //: Error : 1795 - ORA-01795: maximum number of expressions in a list is 1000
	If TCCanOpen("AK2TMP")
		TCDelFile("AK2TMP")
	EndIf

	AAdd(aStruct, {"RECNO_","N",10,0})

		DbCreate("AK2TMP",aStruct,"TOPCONN")
		DbUseArea(.T., "TOPCONN", "AK2TMP", "AK2TMP", .T.,.F.)
		DbSelectArea("AK2TMP")


	For nN_ := 1 TO Len(aRecNoVisible)
		Reclock("AK2TMP",.T.)
		RECNO_ := aRecNoVisible[nN_]
		MsUnlock("AK2TMP")
	Next

	AK2TMP->(DbGoTop())

EndIf

dbSelectArea("AK2")
For nX := 1 TO Len(aRecNoVisible)
    MsGoto(aRecNoVisible[nX])
    If Ascan(aItensOrcNoVisible, AK2->AK2_ID)==0
    	aAdd(aItensOrcNoVisible, AK2->AK2_ID)
    EndIf
Next

If lQryAK2
	cQuery	:=	" SELECT R_E_C_N_O_ RECNO,Max(AK2_ID) AK2_ID FROM "+RetSqlName('AK2')+" AK2 "
	cQuery	+=	" WHERE AK2_FILIAL='"+xFilial('AK2')+"' AND AK2_ORCAME='"+AK1->AK1_CODIGO+"' "
	cQuery	+=	" AND AK2_VERSAO='"+ cVersao +"' AND AK2_CO='"+ (cArquivo)->XK3_CO +"' "
	If Len(aRecNoVisible) > 998
		cQuery	+=	" AND R_E_C_N_O_ NOT IN (SELECT RECNO_ FROM AK2TMP)"
 	ElseIf Len(aRecNoVisible) > 0
		cQuery	+=	" AND R_E_C_N_O_ NOT IN ("
		For nX := 1 TO Len(aRecNoVisible)
			cQuery	+=	Alltrim(STR(aRecNoVisible[nX]))+","
		Next nX
		cQuery	:=	Substr(cQuery,1,Len(cQuery)-1)+")"
	Endif
	cQuery	+=	" AND D_E_L_E_T_= ' ' GROUP BY R_E_C_N_O_"
	cQuery	+=	" ORDER BY AK2_ID"
	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
	cAK2Id := QRYTRB->AK2_ID
	While !Eof()
		aAdd(aRecAK2,QRYTRB->RECNO)
		cAK2Id := QRYTRB->AK2_ID
		DbSkip()
	Enddo
	DbCloseArea()
    If Len(aRecNoVisible) > 998
    	AK2TMP->(DbClosearea())
		If TCCanOpen("AK2TMP")
			TCDelFile("AK2TMP")
		EndIf
    EndIf
Else
	dbSelectArea("AK2")
	dbSetOrder(5)
	dbSeek(xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO )
	While !Eof() .And. AK2->AK2_FILIAL + AK2->AK2_ORCAME + AK2->AK2_VERSAO + AK2->AK2_CO  == ;
						xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO
		If Ascan(aRecNoVisible, AK2->(RecNo()))==0
			aAdd(aRecAK2,AK2->(RecNo()))
		EndIf
		cAK2Id := AK2->AK2_ID
		dbSkip()
	End
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo AK2 (Itens)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AK2")

//ACHAR AS COLUNAS DE VALOR
aHeadVal	:=	{}
For nX := 1 To Len(oGD:aHeader)
	If AllTrim(oGD:aHeader[nX,2]) == "AK2_VAL"
		AADD(aHeadVal,{nX,		DTOS(CTOD(Substr(oGD:aHeader[nX][1],1,10)))})
	Endif
Next
nLenHeadVal	:=	Len(aHeadVal)
ProcRegua((nLenCols*nLenHeadVal)+Len(aRecAK2))

Begin Transaction
nTimeVer := 0
nSeek2	:=	0
aRecProc	:=	{}

For nCntFor := 1 to nLenCols

	If !oGD:aCols[nCntFor][Len(oGD:aCols[nCntFor])]

		cItemAK2 := Padr(oGD:aCols[nCntFor][nHeadItem],Len(AK2->AK2_ID))

		//tem que estar posicionado em AK3 (cChvIt)- se o item do orcamento nao for inclusao e
		//nao estiver lockado logicamente com lockbyname
		//avancar para o proximo item
		cChvIt := AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+oGD:aCols[nCntFor, nHeadItem]
		If cItemAK2 != PadR("*", Len(AK2->AK2_ID)) .And. ;
			Ascan(aLocksAK2,{|x| x ==cChvIt }) == 0
			dbSelectArea("AK2")
			dbSetOrder(5)
			For nCntFor2 := 1 to nLenHeadVal
				If MsSeek(xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO +cItemAK2+aHeadVal[nCntFor2,2])
					Aadd(aRecProc, AK2->(Recno()))
				EndIf
			Next
			Loop
		EndIf

		// Bloco para renumerar AK2_ID se existir em registros nao visiveis
		If cItemAK2 != PadR("*", Len(AK2->AK2_ID)) .And. ;
			Ascan(aItensOrcNoVisible, cItemAK2) > 0
			If (nPosAK2 := Ascan(aItensNew, {|aVal|aVal[1]==cItemAK2})) == 0
				cAk2Id := StrZero(Val(cAk2Id)+1, Len(AK2->AK2_ID))
			 	aAdd(aItensNew, {cItemAK2, cAk2Id})
			   cItemAK2 := cAk2Id
			Else
			   cItemAK2 := aItensNew[nPosAK2][2]
			EndIf
			oGD:aCols[nCntFor][nHeadItem] := cItemAK2
		Else
			If cItemAK2 == PadR("*", Len(AK2->AK2_ID)) .And. ;
				(nPosAK2 := Ascan(aItensNew, {|aVal|aVal[2]==cItemAK2})) == 0
				If Len(aRecNoVisible) > 0
					aItensCols := {}
					For nPos := 1 To nLenCols
						AAdd(aItensCols, oGD:aCols[nPos,1])
					Next nPos

					// Encontra ID maximo entre itens nao visiveis em outro usuario com restricao de
					// acesso e itens jah carregados no aCols
					nLastNoVisID := Val(aSort( aItensOrcNoVisible,,, {|x,y| x > y } )[1])
					nLastAColsID := Val(aSort( aItensCols,,, {|x,y| x > y } )[1])
					nLastID	:= Max( Max( nLastNoVisID, nLastAColsID ), Val(cAk2Id ) )
					// Incrementa cAk2ID a partir do maximo ID encontrado
					cAk2Id := StrZero(nLastID+1, Len(AK2->AK2_ID))
				Else
					cAk2Id := StrZero(Val(cAk2Id)+1, Len(AK2->AK2_ID))
				EndIf
			   aAdd(aItensNew, {cItemAK2, cAk2Id})
			   cItemAK2 := cAk2Id
		    EndIf
		    oGD:aCols[nCntFor][nHeadItem] := cItemAK2
		EndIf

		// Fim do bloco para renumerar


		AK2->(DbSetOrder(1))
		dbSelectArea("AK2")
		dbSetOrder(5)

		For nCntFor2 := 1 to nLenHeadVal
			IncProc()
			lChanged	:=	.F.
			nPosVal	:=	aHeadVal[nCntFor2,1]

			AK2->(DbSetOrder(1))
			dbSelectArea("AK2")
			dbSetOrder(5)
			If MsSeek(xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO +cItemAK2+aHeadVal[nCntFor2,2])
				Aadd(aRecProc, AK2->(Recno()))
				//Verificar se mudou o valor antes de  continuar.
				If PcoPlanVal(oGD:aCols[nCntFor,nPosVal],AK2->AK2_CLASSE) <> AK2->AK2_VALOR
					lChanged := .T.
				Endif
				//Verificar se mudou algum campo antes de continuar.
				//Se nao mudou nao sera refeito o lancamento
				If !lChanged
					For nCntFor3 := 1 To nLenHeader
						If ( oGD:aHeader[nCntFor3,10] != "V" ) .And. AllTrim(oGD:aHeader[nCntFor3,2]) != "AK2_VAL"
							If AK2->(FieldGet(FieldPos(oGD:aHeader[nCntFor3,2]) )) <> oGD:aCols[nCntFor,nCntFor3]
								lChanged	:=	.T.
								Exit
							Endif
						ElseIf AllTrim(oGD:aHeader[nCntFor3,2]) == "AK2_VAL"
							If (nPos := Ascan(aFormula, {|aVal|aVal[1]==nCntFor .And. ;
								aVal[2]==Alltrim(oGD:aHeader[nCntFor3][1])})) >  0 .And. Alltrim(AK2->AK2_FORMUL) <> Alltrim(aFormula[nPos][3])
								lChanged	:=	.T.
								Exit
							Endif
						EndIf
					Next nCntFor3
				Endif

				If ExistBlock("PCOGRVITPL")
					lRetPe := ExecBlock("PCOGRVITPL",.F.,.F.)
				EndIf


				If !lChanged .and. !lRetPe
				 	Loop
				Endif

				RecLock("AK2",.F.)
				lNewRec	:=	.F.
			Else
				//So criar um registro novo se o valor e diferente de zero  ou se tiver formula para a coluna
				If PcoPlanVal(oGD:aCols[nCntFor][nPosVal],oGD:aCols[nCntFor,nPosClasse]) <> 0 .Or.;
					! MsSeek( xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO +cItemAK2 ) .Or. ;
					 (nPos := Ascan(aFormula, {|aVal|aVal[1]==nCntFor .And. ;
						aVal[2]==Alltrim(oGD:aHeader[nPosVal][1])})) >  0 .And. !Empty(Alltrim(aFormula[nPos][3]))
					RecLock("AK2",.T.)
					lNewRec	:=	.T.
				Else
					Loop
				Endif
			EndIf


			lMudou	:=	.F.

			For nCntFor3 := 1 To nLenHeader
				If ( oGD:aHeader[nCntFor3][10] != "V" ) .And. AllTrim(oGD:aHeader[nCntFor3][2]) != "AK2_VAL"
					If !lNewRec .And. !lMudou .And. AK2->(FieldGet(FieldPos(oGD:aHeader[nCntFor3][2])) <> oGD:aCols[nCntFor][nCntFor3])
						lMudou	:=	.T.
					Endif
					AK2->(FieldPut(FieldPos(oGD:aHeader[nCntFor3][2]),oGD:aCols[nCntFor][nCntFor3]))
				EndIf
			Next nCntFor3

			If !lNewRec .And. !lMudou .And. AK2->AK2_VALOR		<> PcoPlanVal(oGD:aCols[nCntFor][nPosVal],AK2->AK2_CLASSE)
				lMudou	:=	.T.
			Endif

			AK2->AK2_FILIAL	:= xFilial("AK2")
			AK2->AK2_ORCAME	:= AK1->AK1_CODIGO
			AK2->AK2_VERSAO	:= cVersao
			AK2->AK2_CO			:= (cArquivo)->XK3_CO
			AK2->AK2_VALOR		:= PcoPlanVal(oGD:aCols[nCntFor][nPosVal],AK2->AK2_CLASSE)
			AK2->AK2_PERIOD	:= CTOD(Substr(oGD:aHeader[nPosVal][1],1,10))
			AK2->AK2_DATAI		:= CTOD(Substr(oGD:aHeader[nPosVal][1],1,10))
			AK2->AK2_DATAF		:= CTOD(Substr(oGD:aHeader[nPosVal][1],14,16))
			If (nPos := Ascan(aFormula, {|aVal|aVal[1]==nCntFor .And. ;
								aVal[2]==Alltrim(oGD:aHeader[nPosVal][1])})) >  0
				AK2->AK2_FORMUL := aFormula[nPos][3]
			EndIf
			MsUnlock()

			If ExistBlock("PCOAK2GRV")
		   		ExecBlock("PCOAK2GRV",.F.,.F.)
   			EndIf

			AK3->(DbSetorder(1))
			AK3->(DbSeek(xFilial()+AK2->(AK2_ORCAME+AK2_VERSAO+AK2_CO)))

			PcoUnLockAK2(AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+AK2->AK2_ID )

			//Condicoes para fazer lancamento:
				//-Lancar quando algum campo mudou (com execao da formula) e nao um registro novo
			   //-Se e um novo registro, que o valor seja <> de 0
			If (lMudou .And. !lNewRec) .Or. (lNewRec .And. AK2->AK2_VALOR <> 0 )
				If lSimulac
					PcoDetLan("000252","03","PCOA100")
				ElseIf lRevisao
					PcoDetLan("000252","02","PCOA100")
				Else
					PcoDetLan("000252","01","PCOA100")
				EndIf
			Endif
		Next nCntFor2
	EndIf
Next  nCntFor

If Len(aRecProc) < Len(aRecAK2)
	For nCntFor := 1 to Len(aRecAK2)
		IncProc()

		If Ascan(aRecProc,aRecAK2[nCntFor]) == 0
			// Se eh um item jah gravado e incluso por outro usuario (nao estah na aCols), entao nao deve excluir.
			AK2->( dbGoto(aRecAK2[nCntFor] ) )
			nPos := aScan( oGD:aCols, { |x| x[nHeadItem] == AK2->AK2_ID } )

			If (nPos <> 0)
				If lSimulac
					PcoDetLan("000252","03","PCOA100",.T.)
				ElseIf lRevisao
					PcoDetLan("000252","02","PCOA100",.T.)
				Else
					PcoDetLan("000252","01","PCOA100",.T.)
				EndIf

				If ExistBlock("PCODelItm")
					 ExecBlock("PCODelItm",.F.,.F.)
   				EndIf

				RecLock("AK2",.F.,.T.)
				dbDelete()
				MsUnlock()

			EndIf
		Endif

	Next
EndIf

End Transaction

// Libera conta orcamentaria
UnLockByName(xFilial("AK3")+AK1->AK1_CODIGO+cVersao+(cArquivo)->XK3_CO,.T.,.T.,.T.)

AK3->(MsUnlockAll())  //libera registro travado com softlock para garantir integridade

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoxGD1LinOK³ Autor ³ Edson Maricate      ³ Data ³ 17-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da LinOK da Getdados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoxGD1LinOK()
Local lRet			:= .T.
Local nPosOper		:= aScan(oGD[1]:aHeader,{|x|AllTrim(x[2])=="AK2_OPER"})
Local nPosClasse	:= aScan(oGD[1]:aHeader,{|x|AllTrim(x[2])=="AK2_CLASSE"})
Local nPosChave	:= aScan(oGD[1]:aHeader,{|x|AllTrim(x[2])=="AK2_CHAVE"})
Local cClasse
Local cOper

If nMvPar != 4 .Or. nPosClasse > 0
	cClasse := oGD[1]:aCols[n][nPosClasse]
Else
	cClasse := M->AK2_CLASSE
EndIf

If nMvPar != 4 .Or. nPosOper > 0
	cOper := oGD[1]:aCols[n][nPosOper]
Else
	cOper := M->AK2_OPER
EndIf

dbSelectArea("AK6")
dbSetOrder(1)
PcoPosAK6(cClasse)
//dbSeek(xFilial()+cClasse)

If AK6->AK6_OBRIGA=="1" .And. Empty(oGD[1]:aCols[n][nPosChave])
	HELP("  ",1,"PCONOCHAVE")
	lRet	:= .F.
EndIf

If lRet .And. AK6->AK6_OPER=="1" .And. Empty(cOper)
	HELP("  ",1,"PCONOOPER")
	lRet	:= .F.
EndIf

If lRet
	If nMvPar != 4
		If ! Pco_ChkUsu(oGD[1], oGD[1]:nAt,(cArquivx)->RECNO)
			Aviso(STR0022,STR0077,{"Ok"})//"Atencao"###"Usuario sem acesso as entidades com restricao."
			lRet	:= .F.
		EndIf
	Else
		If ! Pco_ChkUsu(oGD[1], oGD[1]:nAt,AK3->(Recno()), aClone(aFixos))
			Aviso(STR0022,STR0077,{"Ok"})//"Atencao"###"Usuario sem acesso as entidades com restricao."
			lRet	:= .F.
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	lRet := MaCheckCols(oGD[1]:aHeader,oGD[1]:aCols,oGD[1]:oBrowse:nAT)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa ponto de entrada para validacoes adicionais na linha da planilha editada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If ExistBlock("PCOAK2LOK")
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para validacao da linha de digitacao do     ³
		//P_E³ orcamento                                                              ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : .F. - Deve bloquear a linha de digitacao                  ³
		//P_E³              .T. - Liberar a linha digitada                            ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := ExecBlock("PCOAK2LOK",.F.,.F.)
	EndIf
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoxGD1TudoK³ Autor ³ Edson Maricate      ³ Data ³ 17-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PCOXFUN                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoxGD1TudoK()

Local nx
Local lRet			:= .T.
Local nPosClasse	:= aScan(oGD[1]:aHeader,{|x|AllTrim(x[2])=="AK2_CLASSE"})
Local nSavN			:= n
Local cClasse

For nx := 1 to Len(oGD[1]:aCols)
	n	:= nx
	If nMvPar != 4 .Or. nPosClasse > 0
		cClasse := oGD[1]:aCols[n][nPosClasse]
	Else
		cClasse := M->AK2_CLASSE
	EndIf
Next nx

n	:= nSavN

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoIdentF3³ Autor ³ Edson Maricate        ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
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
Function PcoIdentF3(cAlias, nMvPar)

Local aArea	:= GetArea()
Local aAreaAK6	:= AK6->(GetArea())

Local nPosClasse
Local nPosIdent
Local nPosChave
Local nPosUnMed
Local nTamIdent, nTamChave
Local cClasse := Space(Len(AK2->AK2_CLASSE))
Local cConPad := ""

Default cAlias := "AK2"
Default nMvPar := 1

nPosClasse  := aScan(aHeader,{|x|AllTrim(x[2])== cAlias + "_CLASSE"})
nPosIdent   := aScan(aHeader,{|x|AllTrim(x[2])== cAlias + "_IDENT"})
If cAlias == "AKD" .Or. cAlias == "ALB"
	nPosChave   := aScan(aHeader,{|x|AllTrim(x[2])== cAlias + "_IDREF"})
	nTamIdent 	:= aHeader[nPosIdent][4]
	nTamChave   := aHeader[nPosChave][4]
	nPosUnMed   := aScan(aHeader,{|x|AllTrim(x[2])== cAlias + "_UM"})
Else
	nPosChave   := aScan(aHeader,{|x|AllTrim(x[2])== cAlias + "_CHAVE"})
	nTamIdent 	:= aHeader[nPosIdent][4]
	nTamChave   := aHeader[nPosChave][4]
	nPosUnMed   := aScan(aHeader,{|x|AllTrim(x[2])== cAlias + "_UM"})
EndIf

If nMvPar != 4 .Or. nPosClasse > 0
	cClasse := aCols[n][nPosClasse]
Else
	cClasse := M->AK2_CLASSE
EndIf

If !Empty(cClasse)//aCols[n][nPosClasse])
	AK6->(dbSetOrder(1))

	If AK6->(dbSeek(xFilial()+cClasse)) .And. !Empty(AK6->AK6_ENTIDA)
		cConPad := AK6->AK6_ENTIDA
        //esta posicionado em AK6
		If ExistBlock( "PCOIDENTF3" )
			cConPad := ExecBlock( "PCOIDENTF3", .F., .F., { cConPad } )
		EndIf
        //invoca a consulta padrao
		If ConPad1( , , , cConPad , , , .F. )
			aCols[n][nPosIdent] := &(AK6->AK6_VISUAL)
            dbSelectArea(AK6->AK6_ENTIDA)
            If !Empty(AK6->AK6_INDICE)
				dbSetOrder(AK6->AK6_INDICE)
			Else
				dbSetOrder(1)
			EndIf
			aCols[n][nPosChave] := AK6->AK6_ENTIDA+If(!Empty(AK6->AK6_INDICE), Str(AK6->AK6_INDICE,2,0), Str(IndexOrd(),2,0))+&(IndexKey())
			aCols[n][nPosUnMed] := &(AK6->AK6_UM)
		Else
			aCols[n][nPosIdent] := SPACE(nTamIdent)
			aCols[n][nPosChave] := SPACE(nTamChave)
		EndIf
	EndIf
Else
	aCols[n][nPosIdent] := SPACE(nTamIdent)
	aCols[n][nPosChave] := SPACE(nTamChave)
EndIf

RestArea(aAreaAK6)
RestArea(aArea)
Return(SPACE(nTamIdent))// .F.

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
Static Function PcoDlgView(cArquivo,aSVAlias,aEnch,aPos,nOldEnch,oPanel,lFiltro)

Local aArea		:= GetArea()
Local cAlias	:= (cArquivo)->ALIAS
Local nRecView	:= (cArquivo)->RECNO
Local nPosAlias	:= aScan(aSVAlias,cAlias)
Local lOneColumn:= If(aPos[4]-aPos[2]>312,.F.,.T.)
Local nOldIndex
Default lFiltro	:= .F.

If nRecView <> 0
	aEnch[nOldEnch]:Hide()
	dbSelectArea(cAlias)
	MsGoto(nRecView)
	RegToMemory(cAlias,.F.)

	If nPosAlias > 0
		Do Case
			Case cAlias == "AK3"
				aEnch[1]:EnchRefreshAll()
				aEnch[1]:Show()
				nOldEnch:=1
			Case cAlias == "AK1"
				aEnch[2]:EnchRefreshAll()
				aEnch[2]:Show()
				nOldEnch:=2
			Case cAlias == "AKG"
				aEnch[3]:EnchRefreshAll()
				aEnch[3]:Show()
				nOldEnch:=3
		EndCase
	Else
		Do Case
			Case cAlias == "AKG"
				//sempre posicionar tambem AK3 correspondente a conta orcamentaria atual
				dbSelectArea("AK3")
				nOldIndex := AK3->(IndexOrd())
				dbSetOrder(1)
				dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+M->AKG_CO)
				dbSetOrder(nOldIndex)
				//volta para alias AKG
				dbSelectArea(cAlias)
				aAdd(aSVAlias,"AKG")
				oPanel:Hide()
				aEnch[3]:= MsMGet():New("AKG",AKG->(RecNo()),2,,,,,aPos,,3,,,,oPanel,,,lOneColumn)
				aEnch[3]:oBox:Align := CONTROL_ALIGN_ALLCLIENT
				oPanel:Show()
				aEnch[3]:EnchRefreshAll()
				nOldEnch:=3
		EndCase
	EndIf
EndIf

If !lFiltro .And. aArea[1] != cAlias
	RestArea(aArea)
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoAK1Fil³ Autor ³ Edson Maricate         ³ Data ³ 05-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem do filtro da estrutura do AK1.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAK1Fil(cFiltro)

cFiltro := BuildExpr("AK3")

If Empty(cFiltro)
	cFiltro := ".T."
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoAK1Pesq³ Autor ³ Edson Maricate        ³ Data ³ 05-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de pesquisa na estrutura do orcamento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAK1Pesq(cArquivo)

Local aAuxArea	:= (cArquivo)->(GetArea())
Local aParam	:= {}
Local cBkpCad	:= cCadastro

cCadastro := PadR(cCadastro,21)

If ParamBox( { { 1 ,STR0018 ,SPACE(30),"@" 	 ,""  ,""    ,"" ,30 ,.F. },;  //"Pesquisar"### // SPACE(200)
				{5,STR0019,.F.,90,,.F.},; //"Utilizar Pesquisa Exata" // 90
				{5,STR0020,.F.,90,,.F.} }, STR0018 ,aParam ) //"Pesquisar Proxima Ocorrencia"###"Pesquisar" // 90
	dbSelectArea(cArquivo)
	If aParam[2]
		If aParam[3]
			dbSkip()
			LOCATE REST FOR ( AllTrim(aParam[1])==Alltrim(XK3_DESCRI)) .Or. (AllTrim(aParam[1])==Alltrim(XK3_CO))
		Else
			LOCATE FOR ( AllTrim(aParam[1])==Alltrim(XK3_DESCRI)) .Or. (AllTrim(aParam[1])==Alltrim(XK3_CO))
		EndIf
	Else
		If aParam[3]
			dbSkip()
			LOCATE REST FOR ( AllTrim(aParam[1])$XK3_DESCRI) .Or. (AllTrim(aParam[1])$XK3_CO)
		Else
			LOCATE FOR ( AllTrim(aParam[1])$XK3_DESCRI) .Or. (AllTrim(aParam[1])$XK3_CO)
		EndIf
	EndIf
EndIf

If !Found()
	Aviso(STR0022, STR0080, {"Ok"} )	// Atencao ### O item pesquisado não foi encontrado. Expandir a planilha e pesquisar novamente.
	RestArea(aAuxArea)
EndIf

cCadastro := cBkpCad

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoChkUser³ Autor ³ Edson Maricate        ³ Data ³ 26-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que verifica os direitos do Usuario.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoChkUser(cOrcame,cCO,cCOPai,nCheck,cCampo,cRevisa,nDirUsr)
Local lRet	:= .F.
Local aArea	:= GetArea()
Local aAreaAK3	:= AK3->(GetArea())
Local aAreaAK1	:= AK1->(GetArea())

DEFAULT cRevisa	:= ""
DEFAULT nDirUsr := 0

AK1->(dbSetOrder(1))
AK1->(MsSeek(xFilial()+cOrcame))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe o controle de usuarios esta habilitado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AK1->AK1_CTRUSR == "2"  //se nao tem retorna sempre .t.
	RestArea(aAreaAK1)
	RestArea(aAreaAK3)
	RestArea(aArea)
	nDirUsr := 9
	Return(.T.)
EndIf

If __cUserID=="000000"
	lRet := .T.
	nDirUsr := 9
Else
	dbSelectArea("AKG")
	dbSetOrder(1)

	If MsSeek(xFilial()+cOrcame+cCO+__cUserID)
		//**************************************************
		// Caso encontre nivel não localiza nivel superior *
		//**************************************************
		If Val(AKG->(FieldGet(FieldPos("AKG_"+cCampo)))) >=nCheck
			nDirUsr := Val(AKG->(FieldGet(FieldPos("AKG_"+cCampo))))
			lRet := .T.
		Else
			nDirUsr := Val(AKG->(FieldGet(FieldPos("AKG_"+cCampo))))
			lRet := .F.
		EndIf
	Else
		AK3->(dbSetOrder(1))
		If AK3->(MsSeek(xFilial()+cOrcame+If(Empty(cRevisa),AK1->AK1_VERSAO,cRevisa)+cCOPai))
			lRet := PcoChkUser(cOrcame,AK3->AK3_CO,AK3->AK3_PAI,nCheck,cCampo,cRevisa, @nDirUsr)
		EndIf
	EndIf
EndIf

RestArea(aAreaAK1)
RestArea(aAreaAK3)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoChgFld(nFldDst,nFldAtu,oFolder,aAKKLoad,cArquivo)
Local oSay, cTextSay
Local aArea	:= GetArea()
Local aAreaAK3	:= AK3->(GetArea())
Private oObj
Private aRet
Private nCols	:= 2
Private aCols	:= {}
Private nStyle	:= 1
Private cDescri	:= ""
Private cClrLegend
Private cClrData

If nFldDst > 1
	dbSelectArea("AK3")
	dbGoto((cArquivo)->RECNO)
	AKK->(dbGoto(aAKKLoad[nFldDst-1]))
	If !Empty(AKK->AKK_BLOCK)
		Processa( { || PCOExecForm(AKK->AKK_BLOCK) }, STR0073, STR0079 + AllTrim( AKK->AKK_DESCRI ) )	// Aguarde... ### Calculando
		If Len(aRet) > 100 //nao passa folder para criar nova dialog em virtude de limitacao
							// de componentes tsay por janela
		    cTextSay := "{||' Painel exibido em outra janela.  '}"
			oSay := TSay():New( 2,10, MontaBlock(cTextSay) , oFolder:aDialogs[nFldDst], ,oFolder:aDialogs[nFldDst]:oFont,,,,.T.,/*cColorSay*/,,200,15,,,,)
			PcoDispBox(aRet,nCols,"",aCols,,nStyle,cClrLegend,cClrData,,1,1,.T.,cDescri)
		Else
			PcoDispBox(aRet,nCols,"",aCols,,nStyle,cClrLegend,cClrData,oFolder:aDialogs[nFldDst],1,1,.T.,cDescri)
		EndIf
	EndIf
EndIf

RestArea(aAreaAK3)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoRetPer ºAutor  ³Microsiga           º Data ³  11/30/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que retorna array contendo os periodos a serem or-  º±±
±±º          ³ çados na planilha orçamentaria, baseado no campo AK1_TPPERIº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoRetPer(dIniPer, dFimPer, cTipoPer, lAcumul, aPerAux)
Local aRetPer   := {}
Local dIni
Local dx
Local nx
Local bWhile

Default cTipoPer	:= AK1->AK1_TPPERI
Default dIniPer 	:= AK1->AK1_INIPER
Default dFimPer 	:= AK1->AK1_FIMPER
Default lAcumul 	:= .F.
Default aPerAux     := {}

If ! ( cTipoPer $ "1|2|3|4|5|6|7|8" )
	Alert("Error: Period Type invalid, Please check.")
	Return(aRetPer)
EndIf

If cTipoPer == "7"
	bWhile := {|| dx <= dFimPer }
Else
	bWhile := {|| dx < dFimPer }
EndIf

Do Case
	Case cTipoPer == "1"  //SEMANAL
		dIni := dIniPer
		If DOW(dIniPer)<>1
			dIni -= DOW(dIniPer)-1
		EndIf
	Case cTipoPer == "2"  //QUIZENAL
		If DAY(dIniPer) <= 15
			dIni := FirstDay(dIniPer)
		Else
			dIni := CTOD("16/"+Str(Month(dIniPer),2,0)+"/"+Str(Year(dIniPer),4,0))
		EndIf
	Case cTipoPer == "4"		//BIMESTRAL
		dIni := CTOD("01/"+Str((Round(MONTH(dIniPer)/2,0)*2)-1,2,0)+"/"+Str(Year(dIniPer),4,0))
	Case cTipoPer == "5"   //SEMESTRAL
		dIni := CTOD("01/"+IIf(MONTH(dIniPer)<=6,'01','07')+"/"+Str(Year(dIniPer),4,0))
	Case cTipoPer == "6"   //ANUAL
		dIni := CTOD("01/01/"+Str(Year(dIniPer),4,0))
	Case cTipoPer == "7"   //PERIODO (DT INICIAL A DT FINAL)
		dIni := dIniPer
	Case cTipoPer == "8"   //TRIMESTRAL
		dIni := CTOD("01/"+StrZero(MONTH(dIniPer),2,0)+"/"+StrZero(YEAR(dIniPer),4,0))
	OtherWise
		dIni := CTOD("01/"+StrZero(MONTH(dIniPer),2,0)+"/"+StrZero(YEAR(dIniPer),4,0))
EndCase

dx := dIni

While Eval(bWhile)
	aAdd(aRetPer,Padr(DTOC(dx),10))
	aAdd(aPerAux,{ DTOS(dx), NIL })
	Do Case
		Case cTipoPer == "1"
			dx += 7
		Case cTipoPer == "2"
			If DAY(dx) == 01
				dx        := CTOD("16/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			Else
				dx += 35
				dx        := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
			EndIf
		Case cTipoPer == "3"
			dx += 35
			dx        := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		Case cTipoPer == "4"
			dx += 62
			dx        := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		Case cTipoPer == "5"
			dx += 185
			dx        := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		Case cTipoPer == "6"
			dx += 370
			dx        := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
		Case cTipoPer == "7"
			dx += 1
		Case cTipoPer == "8"
			dx += 93
			dx        := CTOD("01/"+StrZero(MONTH(dx),2,0)+"/"+StrZero(YEAR(dx),4,0))
	EndCase
	aRetPer[Len(aRetPer)] += " - "+Padr(DTOC(dx-1),10)
	aPerAux[Len(aRetPer), 2] := DTOS(dx-1)
End

If lAcumul
	dIniPer := Subs(aRetPer[1], 1, 8)
	For nx := 1 to Len(aRetPer)
		aRetPer[nx] := dIniPer + Subs(aRetPer[nx], 9)
		aPerAux[nx] := { aPerAux[1, 1], aPerAux[nx, 2]}
	Next
EndIf

Return aRetPer

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AnalPerm_UsuarºAutor ³Paulo Carnelossi  º Data ³ 25/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Analisa permissao do usuario qto ao item orcamentario e faz º±±
±±º          ³o controle dos botoes de edicao                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AnalPerm_Usuar(cArquivo, oGetDados, cCampo)
LOCAL aArea    := GetArea()
Local cAlias   := Alias()
Local aAreaAK3 := {}
Local lRet 	   := .F.
Local nLenAux  := 0


If (cArquivo)->ALIAS == "AK3" .AND. !IsInCallStack("Pco120VHst")
	aAreaAK3  := AK3->(GetArea())
	dbSelectArea((cArquivo)->ALIAS)
	dbGoto((cArquivo)->RECNO)
	If cCampo == "ITENS"

		nLenAux := TamSX3("AK3_CO")[1]
		If nLenAux > TamSX3("AK3_ORCAME")[1]
			nLenAux := TamSX3("AK3_ORCAME")[1]
		EndIf

	    If AllTrim(Left(AK3_ORCAME,nLenAux)) == AllTrim(Left(AK3_CO,nLenAux)) .Or. (AK3_TIPO == "1")
	       lRet := .F.
	    Else
			lRet := PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,3,cCampo,AK3->AK3_VERSAO)
			If lRet .And. lRevisao
				lRet := PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"REVISA",AK3->AK3_VERSAO)
			EndIf
		EndIf
	EndIf
	RestArea(aAreaAK3)
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoCC_User³ Autor ³ Paulo Carnelossi      ³ Data ³ 22/10/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que verifica os direitos do Usuario x Centro Custo.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoCC_User(cOrcame,cCO,cCOPai,nCheck,cCampo,cRevisa,cCentroCusto,nDireito)
Local lRet	:= .F.
Local aArea
Local aAreaAK1
Local aAreaAKG
Local aAreaAKX
Local aAreaAK3
Local cQuery
Local aResult

DEFAULT nDireito := 1

If __cUserID=="000000"
	lRet := .T.
ElseIf Empty(cCentroCusto)
	lRet := .T.
Else

	aArea	:= GetArea()
	aAreaAK1	:= AK1->(GetArea())

	AK1->(dbSetOrder(1))
	If AK1->(MsSeek(xFilial()+cOrcame))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe o controle de usuarios esta habilitado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AK1->AK1_CTRUSR == "2"  //se nao tem controle por usuario retorna sempre .t.

			lRet := .T.

		Else

			If _lProcCCUs  == NIL
				_lProcCCUs := Alltrim( TcGetDb() ) $ "MSSQL/MSSQL7/ORACLE/DB2/INFORMIX/POSTGRES"
			EndIf

			If _lProcCCUs

				//cria a procedure
				//parametros de entrada da procedure
				//Filial AKG
				//Filial AKX
				//Codigo do orcamento
				//Conta Orcamentaria
                //Centro de Custo
				//Id Usuario
				//nDireito
				//saida da Procedure
				//OUT_RESULT = 1 SE EXECUTOU PROCEDURE
				//OUT_RESULT1 = 1 SE ENCONTROU REGISTROS AKG / AKX   0 SE NAO ENCONTROU

				If _cNomProc1  == NIL
					//atribui nome da procedure com criatrab
					_cNomProc1 := CriaTrab( , .F. )

					//script da procedure
					cQuery := " Create Procedure  "+_cNomProc1+"_"+cEmpAnt + " ( "
					cQuery+="   @IN_FILAKG  Char("+Alltrim(Str(Len(AKG->AKG_FILIAL)))+" ), "+CRLF
					cQuery+="   @IN_FILAKX  Char("+Alltrim(Str(Len(AKX->AKX_FILIAL)))+" ), "+CRLF
					cQuery+="   @IN_CODORC  Char("+Alltrim(Str(Len(AK1->AK1_CODIGO)))+" ), "+CRLF
					cQuery+="   @IN_CTAORC  Char("+Alltrim(Str(Len(AK3->AK3_CO)))+" ), "+CRLF
					cQuery+="   @IN_CCUSTO  Char("+Alltrim(Str(Len(AK2->AK2_CC)))+" ), "+CRLF
					cQuery+="   @IN_IDUSER  Char( 06 ), "+CRLF
					cQuery+="   @IN_DIREITO Char( 01 ), "+CRLF

					cQuery+="   @OUT_RESULT Char( 01 ) OutPut,"+CRLF
					cQuery+="   @OUT_RESULT1 Char( 01 ) OutPut"+CRLF
					cQuery+=")"+CRLF

					cQuery+="as"+CRLF
					cQuery+="declare @iRecno     integer"+CRLF
					cQuery+="declare @IND_CCUSTO Char( "+Alltrim(Str(Len(AK3->AK3_CO)))+" ) "+CRLF

					cQuery+="begin"+CRLF
					cQuery+="   Select @OUT_RESULT = '0'"+CRLF
					cQuery+="   Select @OUT_RESULT1 = '0'"+CRLF
					cQuery+="   Select @iRecno  = 0"+CRLF

					cQuery += " SELECT @iRecno = ISNULL(R_E_C_N_O_,0), @IND_CCUSTO = AKG_CCUSTO " +CRLF
					cQuery += "  FROM " + RetSqlName("AKG") + " AKG " +CRLF
					cQuery += " WHERE "
					cQuery += "       AKG_FILIAL = @IN_FILAKG " +CRLF
					cQuery += "   AND AKG_ORCAME = @IN_CODORC " +CRLF
					cQuery += "   AND AKG_CO     = @IN_CTAORC " +CRLF
					cQuery += "   AND AKG_USER   = @IN_IDUSER " +CRLF
					cQuery += "   AND D_E_L_E_T_ = ' ' " +CRLF

					cQuery += " If @iRecno > 0 begin " + CRLF
					cQuery += "    select @OUT_RESULT = '1' "+CRLF
					cQuery += "    If @IND_CCUSTO > '1' begin " + CRLF
					cQuery += "    		select @OUT_RESULT1 = '1' "+CRLF
					cQuery += "    end else begin "+CRLF

					cQuery+="         Select @iRecno  = 0"+CRLF
					cQuery += "       SELECT @iRecno = ISNULL(R_E_C_N_O_,0) " +CRLF
					cQuery += "       FROM " + RetSqlName("AKX") + " AKX " +CRLF
					cQuery += "       WHERE "
					cQuery += "             AKX_FILIAL = @IN_FILAKX " +CRLF
					cQuery += "         AND AKX_USER   = @IN_IDUSER " +CRLF
					cQuery += "         AND AKX_DIREIT >= @IN_DIREITO " +CRLF
					cQuery += "         AND (@IN_CCUSTO BETWEEN AKX_CC_INI AND AKX_CC_FIN)" +CRLF
					cQuery += "         AND D_E_L_E_T_ = ' ' " +CRLF
					cQuery += "       If @iRecno > 0 begin " + CRLF
					cQuery += "         select @OUT_RESULT = '1' "+CRLF
					cQuery += "    	    select @OUT_RESULT1 = '1' "+CRLF
					cQuery += "      end else begin "+CRLF
					cQuery += "         select @OUT_RESULT = '1' "+CRLF
					cQuery += "         select @OUT_RESULT1 = '0' "+CRLF
					cQuery += "      end "+CRLF
					cQuery += "   end "+CRLF

					cQuery += " end else begin "+CRLF
					cQuery += "    select @OUT_RESULT = '1' "+CRLF
					cQuery += "    select @OUT_RESULT1 = '0' "+CRLF
					cQuery += " end "+CRLF

					cQuery += "End " + CRLF

					cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
					cQuery := CtbAjustaP(.F., cQuery, 0)

					If Empty( cQuery )
						MsgAlert(MsParseError(),"Error in Parse : " + _cNomProc1 )
						_lProcCCUs := .F.
					Else
						If !TCSPExist( _cNomProc1+"_"+cEmpAnt )
							nRet := TcSqlExec(cQuery)
							If nRet <> 0
								If !IsBlind()
									MsgAlert(TcSqlError(), "Error in Create Procedure "+_cNomProc1)
									_lProcCCUs := .F.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				//executa a procedure
				aResult	:= TCSPEXEC( 	xProcedures( _cNomProc1 ),;
								xFilial("AKG"),;				//xFilial AKG
								xFilial("AKX"),;				//xFilial AKG
								cOrcame,;						//cOrcame
	 							cCO,;					        //Conta Orcamentaria
	 							cCentroCusto,;					//Centro de Custo
	 							__cUserID,;						//Id User
	 							Alltrim(Str(nDireito)) )					    //direito

				If Empty( aResult )

					If !__lBlind
						MsgAlert( "Error in exec stored procedure " + " " + _cNomProc1 + ": " + TCSqlError() ) // "Erro executando a Stored Procedure"
					EndIf
					_lProcCCUs := .F.

				Else

					If aResult[1] == '1'  //1o. elemento de aReturn informa se executou a procedure sem erros

						If aResult[2] == '1'
							lRet := .T.
						Else

							aAreaAK3	:= AK3->(GetArea())
							//Analisa as permisoes a CC da conta PAI
							AK3->(dbSetOrder(1))

							If AK3->(MsSeek(xFilial()+cOrcame+If(Empty(cRevisa),AK1->AK1_VERSAO,cRevisa)+cCOPai))
							  	lRet	:=	PcoCC_User(cOrcame, AK3->AK3_CO,AK3->AK3_PAI  ,nCheck,cCampo,cRevisa,cCentroCusto,nDireito)
							EndIf

							RestArea(aAreaAK3)

						EndIf

					EndIf

				EndIf

			EndIf

			If !_lProcCCUs

				aAreaAKG	:= AKG->(GetArea())
				dbSelectArea("AKG")
				dbSetOrder(1)
				If MsSeek(xFilial()+cOrcame+cCO+__cUserID)
					//Se tem acesso total por CC, libera
					If Val(AKG->AKG_CCUSTO) > 1
						lRet := .T.
					Else

						//Avalia o acesso a CC
						aAreaAKX	:= AKX->(GetArea())
			        	AKX->(dbSetOrder(1))
						If AKX->(MsSeek(xFilial()+__cUserID))
							While AKX->(!Eof() .And. AKX_FILIAL == xFilial("AKX") .And. AKX_USER == __cUserID)
								If PadL(Alltrim(cCentroCusto),Len(AKX->AKX_CC_INI)) >= PadL(AllTrim(AKX->AKX_CC_INI),Len(AKX->AKX_CC_INI)) .And. ;
									PadL(Alltrim(cCentroCusto),Len(AKX->AKX_CC_INI)) <= PadL(AllTrim(AKX->AKX_CC_FIN),Len(AKX->AKX_CC_INI)) .And. ;
									Val(AKX->(FieldGet(FieldPos("AKX_DIREIT")))) >= nDireito
									lRet := .T.
									EXIT
								EndIf
								AKX->(dbSkip())
							EndDO
						EndIf
						RestArea(aAreaAKX)

					Endif
				Else

					aAreaAK3	:= AK3->(GetArea())
					//Analisa as permisoes a CC da conta PAI
					AK3->(dbSetOrder(1))

					If AK3->(MsSeek(xFilial()+cOrcame+If(Empty(cRevisa),AK1->AK1_VERSAO,cRevisa)+cCOPai))
					  	lRet	:=	PcoCC_User(cOrcame, AK3->AK3_CO,AK3->AK3_PAI  ,nCheck,cCampo,cRevisa,cCentroCusto,nDireito)
					EndIf

					RestArea(aAreaAK3)

				EndIf

				RestArea(aAreaAKG)

			EndIf

		EndIf

	EndIf

	RestArea(aAreaAK1)
	RestArea(aArea)

EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoIC_User³ Autor ³ Paulo Carnelossi      ³ Data ³ 26/10/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que verifica os direitos do Usuario x Item Contabil.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoIC_User(cOrcame,cCO,cCOPai,nCheck,cCampo,cRevisa,cItemCtb,nDireito)
Local lRet	:= .F.
Local aArea
Local aAreaAK1
Local aAreaAKG
Local aAreaAKY
Local aAreaAK3
Local cQuery
Local aResult

DEFAULT nDireito := 1

If __cUserID=="000000"
	lRet := .T.

ElseIf Empty(cItemCtb)
	lRet := .T.

Else

	aArea	:= GetArea()
	aAreaAK1	:= AK1->(GetArea())

	AK1->(dbSetOrder(1))
	If AK1->(MsSeek(xFilial()+cOrcame))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe o controle de usuarios esta habilitado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AK1->AK1_CTRUSR == "2"  //se nao tem controle por usuario retorna sempre .t.

			lRet := .T.

		Else

			If _lProcICUs  == NIL
				_lProcICUs := Alltrim( TcGetDb() ) $ "MSSQL/MSSQL7/ORACLE/DB2/INFORMIX/POSTGRES"
			EndIf

			If _lProcICUs

				//cria a procedure
				//parametros de entrada da procedure
				//Filial AKG
				//Filial AKY
				//Codigo do orcamento
				//Conta Orcamentaria
                //Item Contabil
				//Id Usuario
				//nDireito
				//saida da Procedure
				//OUT_RESULT = 1 SE EXECUTOU PROCEDURE
				//OUT_RESULT1 = 1 SE ENCONTROU REGISTROS AKG / AKY   0 SE NAO ENCONTROU

				If _cNomProc2  == NIL
					//atribui nome da procedure com criatrab
					_cNomProc2 := CriaTrab( , .F. )

					//script da procedure
					cQuery := " Create Procedure  "+_cNomProc2+"_"+cEmpAnt+ " ( "
					cQuery+="   @IN_FILAKG  Char("+Alltrim(Str(Len(AKG->AKG_FILIAL)))+" ), "+CRLF
					cQuery+="   @IN_FILAKY  Char("+Alltrim(Str(Len(AKY->AKY_FILIAL)))+" ), "+CRLF
					cQuery+="   @IN_CODORC  Char("+Alltrim(Str(Len(AK1->AK1_CODIGO)))+" ), "+CRLF
					cQuery+="   @IN_CTAORC  Char("+Alltrim(Str(Len(AK3->AK3_CO)))+" ), "+CRLF
					cQuery+="   @IN_ITMCTB  Char("+Alltrim(Str(Len(AK2->AK2_ITCTB)))+" ), "+CRLF
					cQuery+="   @IN_IDUSER  Char( 06 ), "+CRLF
					cQuery+="   @IN_DIREITO Char( 01 ), "+CRLF

					cQuery+="   @OUT_RESULT Char( 01 ) OutPut,"+CRLF
					cQuery+="   @OUT_RESULT1 Char( 01 ) OutPut"+CRLF
					cQuery+=")"+CRLF

					cQuery+="as"+CRLF
					cQuery+="declare @iRecno     integer"+CRLF
					cQuery+="declare @IND_ITMCTB Char( "+Alltrim(Str(Len(AK2->AK2_ITCTB)))+" ) "+CRLF

					cQuery+="begin"+CRLF
					cQuery+="   Select @OUT_RESULT = '0'"+CRLF
					cQuery+="   Select @OUT_RESULT1 = '0'"+CRLF
					cQuery+="   Select @iRecno  = 0"+CRLF

					cQuery += " SELECT @iRecno = ISNULL(R_E_C_N_O_,0), @IND_ITMCTB = AKG_ITMCTB " +CRLF
					cQuery += "  FROM " + RetSqlName("AKG") + " AKG " +CRLF
					cQuery += " WHERE "
					cQuery += "       AKG_FILIAL = @IN_FILAKG " +CRLF
					cQuery += "   AND AKG_ORCAME = @IN_CODORC " +CRLF
					cQuery += "   AND AKG_CO     = @IN_CTAORC " +CRLF
					cQuery += "   AND AKG_USER   = @IN_IDUSER " +CRLF
					cQuery += "   AND D_E_L_E_T_ = ' ' " +CRLF

					cQuery += " If @iRecno > 0 begin " + CRLF
					cQuery += "    select @OUT_RESULT = '1' "+CRLF
					cQuery += "    If @IND_ITMCTB > '1' begin " + CRLF
					cQuery += "    		select @OUT_RESULT1 = '1' "+CRLF
					cQuery += "    end else begin "+CRLF

					cQuery+="         Select @iRecno  = 0"+CRLF
					cQuery += "       SELECT @iRecno = ISNULL(R_E_C_N_O_,0) " +CRLF
					cQuery += "       FROM " + RetSqlName("AKY") + " AKY " +CRLF
					cQuery += "       WHERE "
					cQuery += "             AKY_FILIAL = @IN_FILAKY " +CRLF
					cQuery += "         AND AKY_USER   = @IN_IDUSER " +CRLF
					cQuery += "         AND AKY_DIREIT >= @IN_DIREITO " +CRLF
					cQuery += "         AND AKY_IC_INI >= @IN_ITMCTB " +CRLF
					cQuery += "         AND AKY_IC_FIN <= @IN_ITMCTB " +CRLF
					cQuery += "         AND D_E_L_E_T_ = ' ' " +CRLF
					cQuery += "       If @iRecno > 0 begin " + CRLF
					cQuery += "         select @OUT_RESULT = '1' "+CRLF
					cQuery += "    	    select @OUT_RESULT1 = '1' "+CRLF
					cQuery += "      end else begin "+CRLF
					cQuery += "         select @OUT_RESULT = '1' "+CRLF
					cQuery += "         select @OUT_RESULT1 = '0' "+CRLF
					cQuery += "      end "+CRLF
					cQuery += "   end "+CRLF

					cQuery += " end else begin "+CRLF
					cQuery += "    select @OUT_RESULT = '1' "+CRLF
					cQuery += "    select @OUT_RESULT1 = '0' "+CRLF
					cQuery += " end "+CRLF

					cQuery += "End " + CRLF

					cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
					cQuery := CtbAjustaP(.F., cQuery, 0)

					If Empty( cQuery )
						MsgAlert(MsParseError(),"Error in Parse : " + _cNomProc2 )
						_lProcICUs := .F.
					Else
						If !TCSPExist( _cNomProc2+"_"+cEmpAnt )
							nRet := TcSqlExec(cQuery)
							If nRet <> 0
								If !IsBlind()
									MsgAlert(TcSqlError(), "Error in Create Procedure "+_cNomProc2)
									_lProcICUs := .F.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				//executa a procedure
				aResult	:= TCSPEXEC( 	xProcedures( _cNomProc2 ),;
								xFilial("AKG"),;				//xFilial AKG
								xFilial("AKY"),;				//xFilial AKG
								cOrcame,;						//cOrcame
	 							cCO,;					        //Conta Orcamentaria
	 							cItemCtb,;					    //Item Contabil
	 							__cUserID,;						//Id User
	 							Alltrim(Str(nDireito)) )					    //direito

				If Empty( aResult )

					If !__lBlind
						MsgAlert( "Error in exec stored procedure " + " " + _cNomProc2 + ": " + TCSqlError() ) // "Erro executando a Stored Procedure"
					EndIf
					_lProcICUs := .F.

				Else

					If aResult[1] == '1'  //1o. elemento de aReturn informa se executou a procedure sem erros

						If aResult[2] == '1'
							lRet := .T.
						Else

							aAreaAK3	:= AK3->(GetArea())
							//Analisa as permisoes a CC da conta PAI
							AK3->(dbSetOrder(1))

							If AK3->(MsSeek(xFilial()+cOrcame+If(Empty(cRevisa),AK1->AK1_VERSAO,cRevisa)+cCOPai))
								lRet 	:=	PcoIC_User(cOrcame,AK3->AK3_CO,AK3->AK3_PAI,nCheck,cCampo,cRevisa,cItemCtb,nDireito)
							EndIf
							RestArea(aAreaAK3)

						EndIf

					EndIf

				EndIf

			EndIf

			If ! _lProcICUs
				aAreaAKG	:= AKG->(GetArea())

				dbSelectArea("AKG")
				dbSetOrder(1)
				If MsSeek(xFilial()+cOrcame+cCO+__cUserID)
					//Se tem acesso total retorna TRUE
					If Val(AKG->AKG_ITMCTB) > 1
						lRet := .T.
					Else
						//Avalia o acesso por ITEM CONTABIL
						aAreaAKY	:= AKY->(GetArea())

			        	AKY->(dbSetOrder(1))
						If AKY->(MsSeek(xFilial()+__cUserID))
							While AKY->(!Eof() .And. AKY_FILIAL == xFilial("AKY") .And. AKY_USER == __cUserID)
								If PadL(Alltrim(cItemCtb),Len(AKY->AKY_IC_INI)) >= PadL(AllTrim(AKY->AKY_IC_INI),Len(AKY->AKY_IC_INI)) .And. ;
										PadL(Alltrim(cItemCtb),Len(AKY->AKY_IC_INI)) <= PadL(AllTrim(AKY->AKY_IC_FIN),Len(AKY->AKY_IC_INI)) .And. ;
									Val(AKY->(FieldGet(FieldPos("AKY_DIREIT")))) >= nDireito
									lRet := .T.
									EXIT
								EndIf
								AKY->(dbSkip())
							End
						EndIf

						RestArea(aAreaAKY)

					Endif
				Else
					//Avalia para a conta PAI
					aAreaAK3	:= AK3->(GetArea())

					AK3->(dbSetOrder(1))
					If AK3->(MsSeek(xFilial()+cOrcame+If(Empty(cRevisa),AK1->AK1_VERSAO,cRevisa)+cCOPai))
						lRet 	:=	PcoIC_User(cOrcame,AK3->AK3_CO,AK3->AK3_PAI,nCheck,cCampo,cRevisa,cItemCtb,nDireito)
					EndIf

					RestArea(aAreaAK3)

				EndIf

				RestArea(aAreaAKG)

			EndIf
		EndIf
	EndIf

	RestArea(aAreaAK1)
	RestArea(aArea)

EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoCV_User³ Autor ³ Paulo Carnelossi      ³ Data ³ 26/10/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que verifica os direitos do Usuario x Classe Valor.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoCV_User(cOrcame,cCO,cCOPai,nCheck,cCampo,cRevisa,cClasseValor,nDireito)
Local lRet	:= .F.
Local aArea	:= GetArea()
Local aAreaAK2	:= AK2->(GetArea())
Local aAreaAK1	:= AK1->(GetArea())
Local aAreaAKG	:= AKG->(GetArea())
Local aAreaAKV	:= AKV->(GetArea())
Local aAreaAK3	:= AK3->(GetArea())

DEFAULT nDireito := 1

AK1->(dbSetOrder(1))
AK1->(MsSeek(xFilial()+cOrcame))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe o controle de usuarios esta habilitado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cClasseValor) .OR. AK1->AK1_CTRUSR == "2"  //se nao tem retorna sempre .t.
	RestArea(aAreaAK1)
	RestArea(aAreaAK2)
	RestArea(aArea)
	Return(.T.)
EndIf

If __cUserID=="000000"
	lRet := .T.
Else
	dbSelectArea("AKG")
	dbSetOrder(1)
	If MsSeek(xFilial()+cOrcame+cCO+__cUserID)
		//Se tem acesso total retorna TRUE
		If Val(AKG->AKG_CLAVLR) > 1
			lRet := .T.
		Else
		//Avalia o controle por CV
			AKV->(dbSetOrder(1))
			If AKV->(MsSeek(xFilial()+__cUserID))
				While AKV->(!Eof() .And. AKV_FILIAL == xFilial("AKV") .And. AKV_USER == __cUserID)
					If PadL(Alltrim(cClasseValor),Len(AKV->AKV_CV_INI)) >= PadL(AllTrim(AKV->AKV_CV_INI),Len(AKV->AKV_CV_INI)) .And. ;
							PadL(Alltrim(cClasseValor),Len(AKV->AKV_CV_INI)) <= PadL(AllTrim(AKV->AKV_CV_FIN),Len(AKV->AKV_CV_INI)) .And. ;
						Val(AKV->(FieldGet(FieldPos("AKV_DIREIT")))) >= nDireito
						lRet := .T.
						EXIT
					EndIf
					AKV->(dbSkip())
				Enddo
			EndIf
		Endif
	Else
		AK3->(dbSetOrder(1))
		If AK3->(MsSeek(xFilial()+cOrcame+If(Empty(cRevisa),AK1->AK1_VERSAO,cRevisa)+cCOPai))
			lRet	:=	PcoCV_User(cOrcame,AK3->AK3_CO,AK3->AK3_PAI,nCheck,cCampo,cRevisa,cClasseValor,nDireito)
		EndIf
	EndIf
EndIf

RestArea(aAreaAK1)
RestArea(aAreaAK2)
RestArea(aAreaAKG)
RestArea(aAreaAKV)
RestArea(aAreaAK3)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function It_Orc_Lock(cArquivo,cRevisa,oGD,aRecNoVisible)
Local lRet := .F.

If SoftLock("AK3")
	If AK3->( FieldPos("AK3_LOGLCK"))  == 0
		aRecNoVisible := {}
		Processa({ || PcoPlanIt(cArquivo,cRevisa,oGD,aRecNoVisible,.T.)},,STR0078)
	Else
		//Forcar releitura do banco
		AK3->(DbSkip())
		AK3->(DbSkip(-1))
	 	If AK3->AK3_LOGLCK > cLastAK3Read
			aRecNoVisible := {}
			Processa({ || PcoPlanIt(cArquivo,cRevisa,oGD,aRecNoVisible,.T.)},,STR0078)
		Endif
	//	RecLock('AK3',.F.)
		AK3->AK3_LOGLCK	:=	Dtos(MSDate())+Alltrim(Str(Seconds()))
	//	MsUnLock()
	Endif
	oCopia:bWhen:= {|| .F. }
	oCola:bWhen	:= {|| .F. }
	oEdit:bWhen := {|| .F. }
	oFormZe1:SetFocus()
	lRet := .T.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍADMIÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoVer_Grava(cArquivo, oGetDados, oBrowse)
Local lRet		:= .T.
Local nX
Local nPosId	:=	0

If ValType(oGetDados)<>"U"
	nPosId := aScan( oGetDados:aHeader, {|x|AllTrim(x[2])=="AK2_ID"})	// Posicao da Classe Orcamentaria no aCols

	If !Eval(oWrite:bWhen)
		nRecPos := (cArquivo)->(RECNO)
	Endif
	If Eval(oWrite:bWhen)
		If nRecPos > 0 .And. Aviso(STR0022, STR0023, {STR0024,STR0025}, 2) == 2 //"Atencao"###"Nao foi gravado as alteracoes apos edicao. Abandona sem gravar ? "###"Sim"###"Nao"
			(cArquivo)->(dbGoto(DBLocate(nRecPos)))
			AKO->( DBGOTO( nRecEdic ) )

			oBrowse:Refresh()
			oGetDados:oBrowse:SetFocus()

			lRet := .F.
		Else
			nRecEdic := 0
			oEdit:bWhen		:= {||.T.}
			oWrite:bWhen	:= {||.F.}
			If ( Type('oCancel') <> "U" ) .and. ( ValType(oCancel) == "O" ) .and. ( ValType(oCancel:bWhen) == "B" )
				oCancel:bWhen := {||.F.}
			EndIf
			oGetDados:oBrowse:SetFocus()
			oBrowse:Refresh()

			AK3->(dbGoto((cArquivo)->RECNO))
			For nX:=1 To Len(aLocksAK2)
				UnLockbyName(aLocksAK2[nX])
			Next
			aLocksAK2	:=	{}
		EndIf
	EndIf

	If !(ValType(oBrowse) == "U")
		oBrowse:Refresh()
	EndIf
	If !(ValType(oGetDados) == "U")
		oGetDados:oBrowse:SetFocus()
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoCopy_aCols(oGd, aColsCopy, aForm, lVisao)
Local lContinua 	:= .T.
Local nPosClasse 	:= aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})
Local nX
DEFAULT lVisao 		:= .F.


If !Empty(aColsCopy)
	If Aviso(STR0022,STR0027,{STR0024, STR0025},2) == 2 //"Atencao"###"Os valores da grade o item orcamentario ja foi copiado! Sobrepor os valores ?"###"Sim"###"Nao"
		lContinua := .F.
	EndIf
EndIf

If lContinua
	aFormCopy := aClone(aForm)
	aColsCopy := { {} , aClone(oGd:aHeader) , oGd:nAt }
	// Monta copia somente de linhas com Classe Orçamentaria
	For nX := 1 To Len(oGd:aCols)
		If lVisao .Or. !Empty(oGd:aCols[nX,nPosClasse])
			aAdd(aColsCopy[1], oGd:aCols[nX] )
		EndIf
	Next
EndIf

// Limpa o aColsCopy caso não tenha itens a serem copiados.
If Len(aColsCopy[1])=0
	aColsCopy := {}
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PcoColar_aCols(oGd, aColsCopy, aForm)
Local lContinua := .T., lColaLinha := .T., lRet := .T.
Local lLinhaVazia, nItem, nValor, nPosItem, nPosValor, nPosClasse, nX
Local MyaCols, MyaHeader, nLinAt, nPosIt, nY, nOpca
Local nW

nPosClasse := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})

If Empty(aColsCopy) .OR. ;
    Empty(aColsCopy[1][1][nPosClasse])  //verifica se 1a. linha do acols nao esta vazio
	Aviso(STR0022,STR0028,{STR0001},2) //"Atencao"###"Nao sera possivel colar pois  os valores da grade do item orcamentario nao foram copiados!"###"Fechar"
	lContinua := .F.
	lRet := .F.
Else
	MyaCols := aClone(aColsCopy[1])
	MyaHeader := aClone(aColsCopy[2])
	nLinAt := aColsCopy[3]

	If (nOpca := Aviso(STR0029,STR0030,{STR0031, STR0032, STR0009},1)) == 3 //"Linha ou Grade"###"Voce deseja colar ?"###"Linha"###"Grade"###"Abandonar"
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
	nPosItem := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_ID"})
	nPosValor := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_VAL"})

    If nPosItem == 0 .OR. nPosValor == 0 .OR. nPosClasse == 0
    	lContinua := .F.
    EndIf

    If lContinua
    	//verifica se a ultima linha esta vazia
    	nItem := Val(oGd:aCols[Len(oGd:aCols)][nPosItem])
    	For nX := nPosValor TO Len(oGd:aCols[Len(oGd:aCols)])-1
        	If !Empty(oGD:aCols[oGD:nAt,nPosClasse])
				nValor += PcoPlanVal(oGd:Acols[Len(oGd:aCols)][nX], oGd:Acols[Len(oGd:aCols)][nPosClasse])
			EndIf
        Next

        If nValor == 0
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

	        	   //primeiro copiar as formulas se existir
					For nW := 1 TO Len(aForm)
						If aForm[nW][1] == nX /*nX eh a linha do acols*/
							aAdd(aFormula, { nItem, aForm[nW][2], aForm[nW][3]})
						EndIf
					Next


	            	MyaCols[nX][nPosItem] := PadR("*", Len(AK2->AK2_ID)) //StrZero(nItem, MyaHeader[nPosItem][4])
		        	nItem++
	    	    Next

	    	    //acrescenta ao acols existente
	        	For nX := 1 TO Len(MyaCols)

		        	If !Empty(oGD:aCols[oGD:nAt,nPosClasse])
		            	//acrescentar a linha
		         		aADD(oGD:aCols,Array(Len(oGD:aHeader)+1))
						oGD:aCols[Len(oGD:aCols)][Len(oGD:aHeader)+1] := .F.
		         	EndIf

		          	For nY := 1 TO Len(MyaCols[nX])
		            	oGd:aCols[Len(oGd:aCols)][nY] := MyaCols[nX][nY]
		         	Next
	        	Next

        Else  //linha

              MyaCols[nLinAt][nPosItem] := PadR("*", Len(AK2->AK2_ID)) // StrZero(nItem, MyaHeader[nPosItem][4])

				If ! lLinhaVazia
            		aADD(oGD:aCols,Array(Len(oGD:aHeader)+1))
					oGD:aCols[Len(oGD:aCols)][Len(oGD:aHeader)+1] := .F.
				EndIf
	        	//primeiro copiar as formulas se existir
	       	For nW := 1 TO Len(aForm)
	        		If aForm[nW][1] == nLinAt /*nLinAt eh a linha do acols*/
	        			aAdd(aFormula, { Len(oGd:aCols), aForm[nW][2], aForm[nW][3]})
	        		EndIf
	       	Next

           	For nY := 1 TO Len(MyaCols[nLinAt])
            		oGd:aCols[Len(oGd:aCols)][nY] := MyaCols[nLinAt][nY]
           	Next

        EndIf

    EndIf

EndIf
oGd:ForceRefresh()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Digit_Form(oGd, oForm_Get, lVisual, nColGd, oFormAband, oFormAply)
Local nPosClasse
Local cClasse
Local cAK1Fase 	:= IIF(AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "")

nPosClasse := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})

If nMvPar != 4 .Or. nPosClasse > 0
	cClasse := oGd:aCols[oGd:nAt][nPosClasse]
Else
	cClasse := M->AK2_CLASSE
EndIf

If Alltrim(oGD:aHeader[nColGd][2]) != "AK2_VAL" .Or. Empty(cClasse)
	Return(.F.)
EndIf

If !lVisual .And. !PcoVldFase("AMR",cAK1Fase,"0015",.T.)
	lVisual := .T. //Habilita só visualização quando Fase inválida
EndIf

oForm_Get:Show()

If oFormAply != Nil
	oFormAply:Show()
EndIf

If oFormAband != Nil
	oFormAband:Show()
EndIf

If lVisual
	oFormZe:SetFocus()
	oForm_Get:bWhen := {||.F.}
	If oFormAply != Nil
		oFormAply:bWhen := {||.F.}
	EndIf
	If oFormAband != Nil
		oFormAband:bWhen:= {||.F.}
	EndIf
Else
	oForm_Get:SetFocus()
	oForm_Get:bWhen := {||.T.}
	If oFormAply != Nil
		oFormAply:bWhen := {||.T.}
	EndIf
	If oFormAband != Nil
		oFormAband:bWhen:= {||.T.}
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Form_Valid(cFormula, lVisual, oGd, nColGd)
Local nLin := oGd:nAt
Local cClasse, nValor := 0
Local nPosClasse

nPosClasse := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})

If nMvPar != 4 .Or. nPosClasse > 0
	cClasse	:= oGD:aCols[nLin][nPosClasse]
Else
	cClasse  := M->AK2_CLASSE
EndIf

If lVisual .Or. Empty(cClasse)
   Return(.F.)
EndIf

cFormula := Alltrim(cFormula)
If !Empty(cFormula) .And. !lVisual .And. nColGd > 0
	If PcoTstForm('M->AK2_VALOR := '+cFormula)
        If (nPos := aScan(aFormula,{|x| AllTrim(x[2]) == Alltrim(oGD:aHeader[nColGd][1]) .And. ;
        									x[1] == nLin }))==0
           aAdd(aFormula, {nLin, Alltrim(oGD:aHeader[nColGd][1]), cFormula})
        Else
          	aFormula[nPos][3] := cFormula
        EndIf
    EndIf
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Form_Aplicar(cFormula, lVisual, oGd, nColGd)
Local nLin := oGd:nAt
Local cClasse, nValor := 0, nZ
Local nPosClasse
Local lContinua := .T.
Local nPosForm, nX, nPosHead, aCelAlt
Local nLinAt := oGD:oBrowse:nAt
Local cChvLck
Local nOpcAviso
Local nPosId	:=	aScan( oGD:aHeader, {|x|AllTrim(x[2])=="AK2_ID"})
Private dIniPer
Private dFimPer
//variaveis para carregar os valores armazenados na planilha excel
Private nValueExcel := 0
Private cFormAK2    := cFormula
Private aFormExcel  := {}

If nColGd > 0 .And. Form_Valid(cFormula,lVisual, oGd, nColGd) .AND. PCOValidF(cFormula)

	While .T.

		cChvLck := AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+oGD:aCols[nLin][nPosID]

		If PCOLockAK2(cChvLck,.F.)
			Exit
		Else
			nOpcAviso	:=	1
			nOpcAviso	:=	Aviso(STR0022,STR0095+oGD:aCols[nLin][nPosID]+STR0096+AK3->AK3_CO+STR0097,{STR0098, STR0066}) //"Atencao"##"O item "##" da conta "##" esta em uso e nao pode ser alterado."##"Repetir"##"Cancelar"
			If nOpcAviso == 1
				Loop
			Else
				Return
			EndIf
		EndIf

    EndDo

	nPosClasse := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})

	dIniPer	:=	Ctod(SubStr(oGd:aHeader[nColGd][1],01,10))
	dFimPer	:=	Ctod(SubStr(oGd:aHeader[nColGd][1],14,10))

	If nMvPar != 4 .OR. nPosClasse > 0
		cClasse	:= oGD:aCols[nLin][nPosClasse]
	Else
		cClasse  := M->AK2_CLASSE
	EndIf

	If lVisual .Or. Empty(cClasse)
	   Return
	EndIf

	cFormula := Alltrim(cFormula)
	If !Empty(cFormula) .And. !lVisual .And. nColGd > 0
		If PcoTstForm('M->AK2_VALOR := '+cFormula)
			 //jogar todas as coluna em variaveis de memoria M-> para uso em formulas
		    For nZ := 1 TO Len(oGd:aHeader)
	    		If Alltrim(oGD:aHeader[nZ][2]) != "AK2_VAL"
					_SetOwnerPrvt(Trim(oGd:aHeader[nZ][2]), oGd:Acols[nLin][nZ])
		    	EndIf
	    	Next
	    	//jogar para variavel de memoria para uso em formula
	    	_SetOwnerPrvt("AK2_VALOR", PcoPlanVal(oGd:Acols[nLin][nColGd], cClasse))
		    nValor := &(cFormula)
	    	_SetOwnerPrvt("AK2_FORMUL", cFormula)
	    	_SetOwnerPrvt("AK2_PERIOD", CTOD(Subs(oGd:aHeader[nColGd][1],1,10)))
			oGd:aCols[nLin][nColGd] := PcoPlanCel(nValor, cClasse)
			If nMvPar == 4 .And. ;
				!Empty(oGd:aCols[nLin][COL_EDIT]) .And. ;
				oGd:aCols[nLin][COL_EDIT] == BMP_BRANCO
				oGd:aCols[nLin][COL_EDIT] := BMP_CHK
			EndIf
			oGD:oBrowse:Refresh()
			oGD:oBrowse:SetFocus()
	    EndIf
		If "PCOSETLINK"$AllTrim(Upper(cFormula))
			If Aviso(STR0033,STR0011+; //'Integracao Excel - Planilha Orçamentária'###"Este periodo esta vinculado a uma planilha em formato Excel ( XLS ). Voce deseja abrir aplanilha em modo edição ou alterar o conteudo manualmente ? ( Alterar o valor manualmente não garante a atualização da planilha Excel )"
											CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0012,{"Excel",STR0013},3,STR0014,,"MDIEXCEL")==1 //"Obs.: O modo edição requer o Microsoft Excel instalado."###"Manual"###"Planilhas Excel (XLS) "
				nPosIni := AT("PCOSETLINK(",cFormula)+12
				nPosFim := AT(",",Substr(cFormula,nPosIni))-2
				cObjeto := Substr(cFormula,nPosIni,nPosFim)
				dbSelectArea("AKE")
				dbSetOrder(1)
				dbSeek(xFilial()+AK1->AK1_CODIGO+cRevisa)
				dbSelectArea("ACB")
				dbSetOrder(2)
				If At("][", cObjeto) == 0 .And. dbSeek(xFilial()+"["+Alltrim(AK1->AK1_CODIGO)+"]["+cRevisa+"]"+cObjeto)
	    	       cObjeto := Alltrim(ACB->ACB_OBJETO)
	   				If Aviso(STR0022, STR0099,{STR0100, "> "+DTOC(M->AK2_PERIOD)+" < "})==1  //"Todos"##"As alteracoes efetuadas na planilha deverão ser aplicadas a todos os periodos ou apenas ao posicionado ?"##"Atencao"
						PcoXlsOpen(,,cObjeto,.T.,.T.)
					Else
						PcoXlsOpen(,,cObjeto,.T.,.F.)
					EndIf
				ElseIf dbSeek(xFilial()+cObjeto)
	   				If Aviso(STR0022, STR0099,{STR0100, "> "+DTOC(M->AK2_PERIOD)+" <"})==1  //"Todos"##"As alteracoes efetuadas na planilha deverão ser aplicadas a todos os periodos ou apenas ao posicionado ?"##"Atencao"
						PcoXlsOpen(,,cObjeto,.T.,.T.)
					Else
						PcoXlsOpen(,,cObjeto,.T.,.F.)
					EndIf
				Else
					Aviso(STR0033,STR0015,{STR0001},2,STR0016,,"MDIEXCEL")  //'Integracao Excel - Planilha Orçamentária'###"O nome da planilha especificado na formula está invalido ou inexistente. Verifique a formula digitada para este periodo."###"Fechar"###"Formula invalida"
					lContinua := .F.
				EndIf
				If lContinua
					//atualizar as colunas afetadas pela mudanca da planilha
					//array aFormExcel contem as celulas alteradas
					// este array e atualizado ao sincronizar a base AK2 com o Excel
					// funcao PcoExcFin()
					// 1 - Celula
					// 2 - Formula
					// 3 - Inicio do Periodo (data - q gravou em AK2_PERIOD)
					// 4 - Classe
					// 5 - Valor ja alterado ( q gravou em AK2_VALOR

					//carrega as alteracoes
					//o array a aCelAlt tera os seguintes elementos
					//1 - Linha do Acols
					//2 - cabecalho do periodo
					//3 - classe orcamentaria
					//4 - valor atualizado no excel
					aCelAlt := {}
					For nX := 1 TO Len(aFormExcel)
		                nPosForm := ASCAN(aFormula, {|aVal| Upper(Alltrim(aVal[3])) == Upper(Alltrim(aFormExcel[nX][2]))})
		                If nPosForm > 0
					       aAdd(aCelAlt, {aFormula[nPosForm][1], aFormula[nPosForm][2], aFormExcel[nX][4], aFormExcel[nX][5]})
					    EndIf
					Next

					//atualiza a grade (acols)
					For nX := 1 TO Len(aCelAlt)
						nPosHead := aScan(oGD:aHeader,{|x| AllTrim(x[1]) == aCelAlt[nX][2]})
						If nPosHead > 0
							oGd:Acols[aCelAlt[nX][1]][nPosHead] := PcoPlanCel(aCelAlt[nX][4],aCelAlt[nX][3])
						EndIf
					Next

					//atualizar celula atual em edicao
		            If !Empty(cClasse)
						cVlrFinal := PcoPlanCel(nValueExcel,cClasse)
						oGD:aCols[nLinAt][oGD:oBrowse:nColPos]	:= cVlrFinal
						oGD:oBrowse:nAt := nLinAt

						SetFocus(oGD:oBrowse:hWnd)
						oGD:oBrowse:Refresh()
					EndIf

				EndIf
			EndIf
		EndIf
	Else
    	_SetOwnerPrvt("AK2_FORMUL", cFormula)
    	_SetOwnerPrvt("AK2_PERIOD", CTOD(Subs(oGd:aHeader[nColGd][1],1,10)))
		nValor := 0
		oGd:aCols[nLin][nColGd] := PcoPlanCel(nValor, cClasse)

		nPosHead := aScan(oGD:aHeader,{|x| CTOD(Substr(x[1],1,10))==CTOD(Subs(oGd:aHeader[nColGd][1],1,10))})
		If (nPosForm := Ascan(aFormula, {|aVal|aVal[1]==nLin .And. ;
				aVal[2]==Alltrim(oGD:aHeader[nPosHead][1])})) >  0
			aFormula[nPosForm][3] := cFormula
		Else
			aAdd(aFormula, {nLin, Alltrim(oGd:aHeader[nPosHead,1]), cFormula})
		EndIf
	EndIf
EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Form_RetAnt(cFormAnt, lVisual, oGd, nColGd)
Local nLin := oGd:nAt
Local cClasse, nValor := 0
Local nPosClasse

nPosClasse := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})

If nMvPar != 4 .OR. nPosClasse > 0
	cClasse	:= oGD:aCols[nLin][nPosClasse]
Else
	cClasse  := M->AK2_CLASSE
EndIf

If lVisual .Or. Empty(cClasse)
	Return
EndIf

cFormAnt := Alltrim(cFormAnt)
If !lVisual .And. nColGd > 0
	If PcoTstForm('M->AK2_VALOR := '+cFormAnt)
        If (nPos := aScan(aFormula,{|x| AllTrim(x[2]) == Alltrim(oGD:aHeader[nColGd][1]) .And. ;
        									x[1] == nLin })) > 0
          	aFormula[nPos][3] := cFormAnt

        EndIf
    EndIf
EndIf

oGD:oBrowse:SetFocus()


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Ret_Formula(oGd, nColGd, nLin)
Local cExpr_Form := ""
Local nPos := 0

DEFAULT nLin := oGd:nAt

If Alltrim(oGD:aHeader[nColGd][2]) != "AK2_VAL"
	MsgStop(STR0034) //"Formula inexistente - Posicione no periodo correspondente."
Else
	If (nPos := aScan(aFormula,{|x| AllTrim(x[2]) == Alltrim(oGD:aHeader[nColGd][1]) .And. ;
										x[1] = nLin }))>0
		cExpr_Form := aFormula[nPos][3]
	EndIf
EndIf

Return(cExpr_Form)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOAK2PLAN³ Autor ³ Paulo Carnelossi      ³ Data ³ 31/05/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de montagem da tela de planilha orcamentaria        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOAK2PLAN(cTitle, cArquivo, lConfirma, aMenu, oDlg, cFiltro, cCOInic, aHeaderFil, aHeaderAK2, aPeriodo, aCpoAK2, aCampos, aCpoSel, lEdtPar, lVisual)

Local nx
Local nTop      := oMainWnd:nTop+35
Local nLeft     := oMainWnd:nLeft+10
Local nBottom   := oMainWnd:nBottom-12
Local nRight    := oMainWnd:nRight-10

Local aAKKLoad	:= {}
Local aFolder1  := {STR0035} //"Filtro - Parametros"
Local aFolder	:= {STR0036} //"Itens Orcamentarios"
Local aSVAlias	:= {}
Local aButtons	:= {}

Local ny
Local aRecNoVisible := {}
Local lEdit := .F.
Local lAtlz_Bot	:= .T.

Local oPanel
Local cFormAnt, cFormValid, cFormWhen, cFormPict
Local cBlkGet, cBlkWhen
Local oFont, oFontBt, cCpo

Local oBtnPar
Local oFntVerdana
Local oFolder1
Local lAMX	:= .T.
Local nPosId := 0

Private oFormula //botoes
Private oForm_Get  //get para edicao da formula
Private cFormula
PRIVATE oFx
PRIVATE nColGd := 0
PRIVATE aFormula := {}
PRIVATE oFormZe, oFormZe1
PRIVATE aRecAK2

PRIVATE aColsAK2	:= {}
PRIVATE aColsFil	:= {}
PRIVATE oGD[2]
PRIVATE oFolder
PRIVATE oCopia, oCola, oEdit, oWrite, oMarca, oAtua_Acols, oCancela
PRIVATE nRecEdic := 0
PRIVATE cChvPes := ""
PRIVATE aCtaPlan
PRIVATE aFixos := {}
PRIVATE cArquivx := cArquivo
PRIVATE aAuxHeader

MSUnlockAll()

//jogar em variaveis de memoria tab itens (ak2) para utilizacao nas formulas
For nX := 1 TO AK2->(FCOUNT())
	cCpo := ("AK2->"+Trim(AK2->(FieldName(nX))))
	_SetOwnerPrvt(Trim(AK2->(FieldName(nX))), &cCpo)
Next

PcoAtlz_FilaCols(aColsFil, aHeaderFil)

PcoAtlz_AK2aCols(aColsAK2, aHeaderAK2)

If ( nPosId := aScan( aHeaderAK2, {|x|AllTrim(x[2])=="AK2_ID"}) ) > 0
	aHeaderAK2[nPosId][12] := PadR("*", Len(AK2->AK2_ID))
EndIf

DEFINE FONT oFntVerdana NAME "Verdana" SIZE 0, -10 BOLD
DEFINE FONT oFontBt NAME "Arial" SIZE 0, -8 BOLD
DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
DEFINE MSDIALOG oDlg TITLE cTitle OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight
oDlg:lMaximized := .T.

For nx := 1 to Len(aMenu)
	aAdd( aButtons , aMenu[nX] )
Next

/*
For nx := 1 to Len(aMenu)
	oBtn := TBtnBmp():NewBar( aMenu[nx][3],aMenu[nx][3],,,aMenu[nx][1], aMenu[nx][2],.T.,oBar,,,aMenu[nx][1])
	oBtn:cTitle := aMenu[nx][4]
Next
*/

oPanel3 := TPanel():New(14,182,'',oDlg, oDlg:oFont, .T., .T.,,,(nRight-nLeft)/2-212,((oDLg:nBottom-oDLg:nTop)/2)-120,.T.,.T. )
oPanel3:Align := CONTROL_ALIGN_ALLCLIENT

oFolder1 := TPanel():New	(0,0,'',oDlg, oDlg:oFont, .T., .F.,,,290,52,.T.,.F. )
oFolder1:Align := CONTROL_ALIGN_TOP

oFolder := TFolder():New(121,2,aFolder,{},oDlg,,,, .T., .T.,390,110)
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

@ 3,3 SAY STR0037 of oFolder1 SIZE 120,9 PIXEL FONT oFont COLOR RGB(80,80,80) //"Selecione o Filtro"
@ 3,1 BITMAP oBar RESNAME "MYBAR" Of oFolder1 SIZE BrwSize(oFolder1),8 NOBORDER When .F. PIXEL ADJUST

oGD[2]	:= MsNewGetDados():New(00,1,030,BrwSize(oFolder1),,"PcoxGD2LinOK","PcoxGD2TudOK","",/*aalter*/,0,MAX_COL_AK2,/*fieldok*/,/*superdel*/,/*delok*/,oFolder1, aHeaderFil, aColsFil)
oGD[2]:oBrowse:bGotFocus := {||Eval(oCancela:bAction)}
//oGD[2]:oBrowse:lvScroll := .F.
oGD[2]:oBrowse:lhScroll := .F.
oGD[2]:oBrowse:oFont := oFont

@ 34,3 BUTTON oAtua_Acols PROMPT ">" SIZE 25, 7 ;
	ACTION {||If(! AcessAK2_CC_CV_IC(lVisual), oGD[2]:oBrowse:SetFocus(),;
			(aLineNew := {},lAtlz_Bot := PcoAtlz_Botao(oGd, oFolder:aDialogs[1], lVisual, aPeriodo, aHeaderFil, aHeaderAK2, aCpoAK2, aFixos),;
			oCancela:bWhen := {||lAtlz_Bot}))} OF oFolder1 PIXEL
@ 34,35 SAY STR0038 SIZE 90,7 Of oFOlder1 FONT oFntVerdana COLOR RGB(80,80,80) PIXEL //"Executar filtro"
oAtua_Acols:cToolTip := STR0039 //"Clique aqui para executar o filtro selecionado"

@ 45,3 BUTTON oButton PROMPT "+" SIZE 25, 7   ACTION {|| Aviso(STR0040, STR0041,{"Ok"},2),lEdtPar := .T., oDlg:End() } OF oFolder1 PIXEL //"Configuração hablitada"###"A configuração da planilha poderá ser alterada na próxima edição."
@ 45,35 SAY STR0042 SIZE 90,7 Of oFOlder1 FONT oFntVerdana COLOR RGB(80,80,80) PIXEL //"Configurações das colunas do filtro"
oButton:cToolTip := STR0043 //"Clique aqui para altarar configurar as colunas de filtro da planilha"


If aScan(oGD[2]:aHeader,{|x| AllTrim(x[2])=="XK2_CO"}) > 0
	oGD[2]:AddAction("XK2_CO",{||PcoDig_CO(oGd, .F., lVisual)})
EndIf

oGd[2]:nMax := 1
oGD[2]:lInsert := .T.
oGD[2]:lUpdate := .T.
oGD[2]:lDelete := .F.


oFolder:aDialogs[1]:oFont := oDlg:oFont

PcoGetDados(oGd, oFolder:aDialogs[1], lVisual, aHeaderAK2, aColsAK2)

oPanel := TPanel():New(1,1,'',oFolder:aDialogs[1],oDlg:oFont, .T., .T., , ,20,28,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_BOTTOM

@ 15,4   BUTTON oCopia Prompt STR0044   SIZE 45 ,10 FONT oDlg:oFont ACTION {|| PcoCopAcols(oGd[1], aColsCopy, aClone(aFormula))} OF oPanel PIXEL When .F. //"&Copiar"
@ 15,51  BUTTON oCola  Prompt STR0045   SIZE 45 ,10 FONT oDlg:oFont ACTION {|| PcoColaACols(oGd[1], aColsCopy, aFormCopy)} OF oPanel PIXEL When .F. //"Co&lar"
@ 15,98  BUTTON oMarca Prompt STR0046   SIZE 45 ,10 FONT oDlg:oFont ACTION {|| (aAuxHeader:=aClone(oGd[1]:aHeader), PcoAK2BMP(oGd[1], COL_MARK))} OF oPanel PIXEL When .F. //"&Marcar"
@ 15,145 BUTTON oEdit  Prompt STR0047   SIZE 45 ,10 FONT oDlg:oFont ACTION {|| (aAuxHeader:=aClone(oGd[1]:aHeader), PcoAK2Edit(oGd[1], COL_EDIT))} OF oPanel PIXEL When .F. //"&Editar"
@ 15,192 BUTTON oWrite Prompt STR0048   SIZE 45 ,10 FONT oDlg:oFont ACTION {|| If( oGD[1]:TudoOk() .AND. PcoVldLim(oGD[1],AK3->AK3_CO,AK1->AK1_CODIGO) ,(PcoIniLan("000252"),Processa({||PcoGrvItem(cRevisa, oGD[1], aFixos)},,STR0081),PcoFinLan("000252"), PcoHabFiltro(oGd) ), Nil) } OF oPanel PIXEL When .F. //"&Gravar" ### "Atualizando itens do orçamento..."
@ 15,239 BUTTON oCancela Prompt STR0049 SIZE 45 ,10 FONT oDlg:oFont ACTION {|| PcoAbandEdt(oGd,,lVisual,cRevisa) } OF oPanel PIXEL When .F. //"Cancela&r"

@ 3,51 BITMAP oFx RESNAME "RPMFUNC" Of oPanel SIZE 17,17 NOBORDER When .F. PIXEL
@ 3,4  BUTTON oFormula Prompt STR0050 SIZE 45 ,10  FONT oDlg:oFont ACTION {|| If(lVisual.OR.Form_Edit(oGd), Digit_Form(oGd[1], oForm_Get, lVisual, nColGd), NIL) }	OF oPanel PIXEL WHEN (aAuxHeader:=aClone(oGd[1]:aHeader), If(lVisual, .T., oGd[1]:aCols[oGd[1]:nAt][COL_EDIT]==BMP_CHK)) //"&Formula"
oFormula:bGotFocus := {||nColGd := oGd[1]:oBrowse:nColPos,;
										cFormAnt:=cFormula:=PadR(Ret_Formula(oGd[1], oGd[1]:oBrowse:nColPos), Len(AK2->AK2_FORMUL)),;
										If(lVisual, NIL, Nil) }

cFormula := Space(LEN(AK2->AK2_FORMUL))
cBlkGet := "{ | u | If( PCount() == 0, cFormula, cFormula:= u ) }"
cFormValid := "Form_Valid(cFormula,lVisual, oGd[1], nColGd)"
cFormWhen := ".T."
cBlKVld := "{|| "+cFormValid+"}"
cBlKWhen := "{|| "+cFormWhen+"}"
cFormPict := "@"

oForm_Get := TGet():New( 2, 82,&cBlKGet,oPanel,(BrwSize(@oDlg)/2)-55,9,cFormPict, &(cBlkVld),,,, .F.,, .T.,, .F., &(cBlkWhen), .F., .F.,, .F., .F. ,/*cF3*/,cFormula)
oForm_Get:Hide()


@ 7,120 BTNBMP oFormAply 	RESOURCE "OK" 		SIZE 17,17 	ACTION (Form_Aplicar(cFormula,lVisual, oGd[1], nColGd), cFormula := Space(Len(AK2->AK2_FORMUL)), oForm_Get:refresh(), oForm_Get:Hide()) Of oPanel PIXEL WHEN oForm_Get:lVisible
@ 7,140 BTNBMP oFormAband 	RESOURCE "CANCEL" 	SIZE 17,17 	ACTION (Form_RetAnt(cFormAnt, lVisual, oGd[1], nColGd), cFormula := Space(Len(AK2->AK2_FORMUL)), oForm_Get:refresh(), oForm_Get:Hide()) OF oPanel PIXEL WHEN oForm_Get:lVisible
    //os botoes abaixo sao para desvio de foco
@ 6,5075 BUTTON oFormZe 	Prompt "" 	SIZE 35 ,9  	FONT oDlg:oFont 	ACTION {|| .T. }  	OF oPanel PIXEL
@ 6,5075 BUTTON oFormZe1 	Prompt "" 	SIZE 35 ,9  	FONT oDlg:oFont 	ACTION {|| .T. }  	OF oPanel3 PIXEL

dbSelectArea("AKE")
dbSetOrder(1)
If dbSeek(xFilial("AKE")+AK1->AK1_CODIGO+cRevisa) .And. ;
	AKE->AKE_TIPO=="2"   //simulacao
	TSay():New( 1, 150, MontaBlock("{||'"+STR0051+" - "+cRevisa+"'}"), oPanel3 , ,,,,,.T.,CLR_HRED,,,,,,,,)//"Simulacao"
EndIf

// Quando nao for MDI chama centralizada.
If SetMDIChild()
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||Iif(PcoAbandEdt(oGd,,lVisual,cRevisa),(lConfirma:=.T.,oDlg:End()),)},{|| Iif(PcoAbandEdt(oGd,,lVisual,cRevisa), oDlg:End(), NIL)},, aButtons ))

	//ACTIVATE MSDIALOG oDlg
Else
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{||Iif(PcoAbandEdt(oGd,,lVisual,cRevisa),(lConfirma:=.T.,oDlg:End()),)},{|| Iif(PcoAbandEdt(oGd,,lVisual,cRevisa), oDlg:End(), NIL)},, aButtons ))
	//ACTIVATE MSDIALOG oDlg CENTERED
EndIf

Return lConfirma

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PcoAtlz_Botao(oGd, oFolder, lVisual, aPeriodo, aHeaderFil, aHeaderAK2, aCpoAK2)
Local ny
Local aCposVazio := {}
Local lRet := .F.
Local aCampos := aClone(aCpoAK2)
Local cCpo
Local nPos
Local lValidUsr	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para permitir customizar a validacao ao confirmar o botao "Executar Filtro" ³
//³ na edicao da planilha em modo "especificar campos"                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PCOVLDFLT" )
	lValidUsr := ExecBlock( "PCOVLDFLT", .F., .F., { oGD[2]:aHeader, oGD[2]:aCols } )
	If !lValidUsr
		oGD[2]:oBrowse:SetFocus()
	EndIf
EndIf

If lValidUsr
	For ny := 1 TO Len(aHeaderFil)
		If Empty(oGd[2]:aCols[1,ny])
			aAdd(aCposVazio, aHeaderFil[ny,2])
		EndIf
	Next

	For ny := 1 TO Len(aCampos)
		cCpo := ("AK2->"+Trim(aCampos[ny]))
		If	cCpo == "AK2->AK2_DESCLA"
			M->AK2_DESCLA := Space(60)
		ElseIf cCpo == "AK2->AK2_DESCCO"
			M->AK2_DESCCO := Space(60)
		ElseIf cCpo == "AK2->AK2_DESCCC"
			M->AK2_DESCCC := Space(60)
		ElseIf cCpo == "AK2->AK2_DESCIT"
			M->AK2_DESCIT := Space(60)
		ElseIf cCpo == "AK2->AK2_DESCCL"
			M->AK2_DESCCL := Space(60)
		Else
			_SetOwnerPrvt(Trim(aCampos[ny]), &cCpo)
		EndIf
	Next

	//criar variaveis de memoria com conteudo da grade de selecao
	For ny := 1 TO Len(aHeaderFil)
		&("M->"+StrTran(aHeaderFil[ny][2], "XK2_", "AK2_")):= oGd[2]:aCols[1][ny]
	Next

	aFilHead := aClone(aHeaderFil)

	For ny := 1 TO Len(aCposVazio)
		nPos := Ascan(aFilHead, {|aVal| Alltrim(aVal[2]) == aCposVazio[ny]})
		If nPos > 0
			ADEL(aFilHead, nPos)
		EndIf
	Next
	aSize(aFilHead, Len(aHeaderFil)-Len(aCposVazio))

	If !Empty(aFilHead)
	   //carregar acols de acordo com selecao acima
	   lRet := .T.

	   For ny := 1 TO Len(aFilHead)
			nPos := Ascan(aCampos, StrTran(aFilHead[ny][2],"XK2_","AK2_"))
			If nPos > 0
				ADEL(aCampos, nPos)
			EndIf
	   Next
	   aSize(aCampos, Len(aCampos)-Len(aFilHead))

		aFixos := {}
		For ny := 1 TO Len(aFilHead)
			cCpo := "M->"+StrTran(aFilHead[ny][2], "XK2_", "AK2_")
			aAdd(aFixos, {Subs(cCpo,4), &(cCpo)})
	   	Next

	   	aHeaderAK2:={}
		PcoAK2MontHead(aPeriodo, aHeaderAK2, aFilHead, aCampos)

		aColsAK2 := {}
		PcoGetDados(oGd, oFolder, lVisual, aHeaderAK2, aColsAK2)
	   	Processa({|| PcoCar_AcolsAK2(oGd, aHeaderAK2, aColsAK2, aFilHead, aHeaderFil, oGd[2]:aCols)},'Carregando dados')
	Else
		//colocar os campos na grade dos itens orcamentarios
		If Aviso(STR0022, STR0052, {STR0024, STR0025}, 2)==1 //"Atencao"###"Nao digitado nenhum campo para selecao - Entrar em modo de <Inclusao> ?"###"Sim"###"Nao"
			lRet := .T.
			aHeaderAK2:={}
			PcoAK2MontHead(aPeriodo, aHeaderAK2, aFilHead, aCampos)
			aColsAK2 := {}
			PcoAtlz_AK2aCols(aColsAK2, aHeaderAK2)
			PcoGetDados(oGd, oFolder, lVisual, aHeaderAK2, aColsAK2)
			If aScan(oGD[1]:aHeader,{|x| AllTrim(x[2])=="AK2_CO"}) > 0
				//somente podera digitar a conta orcamentaria se for inclusao de itens
				oGD[1]:AddAction("AK2_CO",{||Iif( Empty(aRecAK2) .Or. oGD[1]:nAt > Len(aRecAK2), PcoDig_CO(oGd, .T., lVisual),(Aviso(STR0022,STR0082,{"Ok"}),M->AK2_CO))})  //"Conta Orcamentaria nao pode ser alterada, em virtude de itens vinculados a conta."
			EndIf
		EndIf
	EndIf

	If lRet

		//nao deixa editar mais a grade de selecao apos fixar
		oGD[2]:lInsert := .F.
		oGD[2]:lUpdate := .F.
		oGD[2]:lDelete := .F.

		oCopia:bWhen := {||.T.}
		oCola:bWhen := {||.T.}
		If lVisual
			oMarca:bWhen := {||.F.}
		Else
			oMarca:bWhen := {||.T.}
		EndIf
		oEdit:bWhen := {||.T.}
		oWrite:bWhen := {||.F.}
		//oFormula:bWhen := {||.T.}
		oFormula:refresh()

		//desabilita o proprio botao ao ser pressionado
		oAtua_Acols:bWhen := {|| .F. }

		//joga foco para outro objeto para provocar refresh de tela
		oFormZe1:SetFocus()
		oGd[1]:oBrowse:refresh()
		oGd[1]:oBrowse:SetFocus()


	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoAtlz_FilaCols(aColsFil, aHeaderFil)
Local ny

aadd(aColsFil,Array(Len(aHeaderFil)+1))
For ny := 1 to Len(aHeaderFil)
	aColsFil[1][ny] := aHeaderFil[ny][12]  //X3_RELACAO
Next ny
aColsFil[1][Len(aHeaderFil)+1] := .F.

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoAtlz_AK2aCols(aColsAK2, aHeaderAK2)
Local ny
Local aAuxHeader

aadd(aColsAK2,Array(Len(aHeaderAK2)+1))
For ny := 1 to Len(aHeaderAK2)
	If AllTrim(aHeaderAK2[ny][2])=="AK2_ID"
		aColsAK2[1][ny] := PadR("*", Len(AK2->AK2_ID)) //StrZero(1,LEN(AK2->AK2_ID))
	ElseIf AllTrim(aHeaderAK2[ny][2])=="AK2_VAL"
		//inicializa todos os periodos orcamentarios com CriaVar()
		aColsAK2[1][nY] := PcoPlanCel(CriaVar(aHeaderAK2[ny][2]))
	Else
		aColsAK2[1][ny] := CriaVar(aHeaderAK2[ny][2])
	EndIf
Next ny

aAuxHeader := aClone(aHeaderAK2)
aColsAK2[1][COL_MARK] := BMP_OFF
aColsAK2[1][COL_EDIT] := BMP_INCL
aColsAK2[1][COL_COPY] := BMP_OFF
aColsAK2[1][COL_COLA] := BMP_OFF
aColsAK2[1][Len(aHeaderAK2)+1] := .F.

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAK2MontHead(aPeriodo, aHeaderAK2, aHeaderFil, aCposFixos)
Local nX
Local aTitCpo, aCpoVirt
Local aVirtCpo:={ 	PadR("AK2_MARK"	, Len(SX3->X3_CAMPO)), ;
					PadR("AK2_ALTER", Len(SX3->X3_CAMPO)), ;
					PadR("AK2_COPIA", Len(SX3->X3_CAMPO)), ;
					PadR("AK2_COLA"	, Len(SX3->X3_CAMPO)), ;
					PadR("AK2_FANTS", Len(SX3->X3_CAMPO))}

Local cFiller := Space( 1 )    // TGXEBL
Local nPosCO  := 0

DEFAULT aHeaderFil := {}
DEFAULT aCposFixos := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader do AK2                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(2)
	aTitCpo := {"",""}
	aCpoVirt:={"AK2_MARK","AK2_ALTER"}

	For nX := 1 TO Len(aCpoVirt)
		dbSeek(aCpoVirt[nX])
		AADD(aHeaderAK2,{ aTitCpo[nX],;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							""/*SX3->X3_VALID*/,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							SX3->X3_CBOX,;
							SX3->X3_RELACAO,;
							""/*SX3->X3_WHEN*/})
	Next

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AK2")

	//Verificar se a conta orçamentária foi inserida no filtro
	nPosCO := AScan(aHeaderFil, {|aVal| aVal[2] == "XK2_CO"} ) 

	While !EOF() .And. (x3_arquivo == "AK2")

		nPos := Ascan(aHeaderFil, {|aVal| Alltrim(aVal[2]) == StrTran(Alltrim(SX3->X3_CAMPO), "AK2_", "XK2_")})

      	If X3Uso(x3_usado) .And. Alltrim(X3_TIPO) != "M" .And. Ascan(aVirtCpo, SX3->X3_CAMPO )==0 ;
		  	.Or. (nPosCO == 0 .And. AllTrim(X3_CAMPO) == "AK2_CO") // Inserir a conta orçamentária na grid caso não seja preenchido no filtro
			IF (cNivel >= x3_nivel .And. nPos == 0) .OR. Ascan(aCposFixos, Alltrim(SX3->X3_CAMPO)) > 0 
				If AllTrim(X3_CAMPO) = "AK2_CHAVE"
					AADD(aHeaderAK2,{ 	TRIM(x3titulo()),;
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
										"PCOChk_NewAcesso(oGD, oGD[1]:nAt, '"+SX3->X3_CAMPO+"','"+cRevisa+"',.T.)"+If(!Empty(SX3->X3_VALID),".And.("+SX3->X3_VALID+")",""),;
										SX3->X3_USADO,;
										SX3->X3_TIPO,;
										SX3->X3_F3,;
										SX3->X3_CONTEXT,;
										SX3->X3_CBOX,;
										SX3->X3_RELACAO,;
										If(Alltrim(SX3->X3_CAMPO) != "AK2_CO", "PCOChk_NewAcesso(oGD, oGD[1]:nAt, '"+SX3->X3_CAMPO+"','"+cRevisa+"',.F.)"+If(!Empty(SX3->X3_WHEN),".And.("+SX3->X3_WHEN+")",""), SX3->X3_WHEN)})
				EndIf
			Endif
		EndIf
		dbSkip()

	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader do AK2                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("AK2_VAL")

	For nX := 1 TO Len(aPeriodo)
		AADD(aHeaderAK2,{ aPeriodo[nX],;
							SX3->X3_CAMPO,;
							cFiller,;  // SX3->X3_PICTURE,; - TGXEBL
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							"PCOChk_NewAcesso(oGD, oGD[1]:nAt, '"+SX3->X3_CAMPO+"','"+cRevisa+"',.T.)"+If(!Empty(SX3->X3_VALID),".And.("+SX3->X3_VALID+")",""),;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							SX3->X3_CBOX,;
							SX3->X3_RELACAO,;
							"PCOBlqRMes(oGD[1],'"+cRevisa+"').And.PCOChk_NewAcesso(oGD, oGD[1]:nAt, '"+SX3->X3_CAMPO+"','"+cRevisa+"',.F.)"+If(!Empty(SX3->X3_WHEN),".And.("+SX3->X3_WHEN+")","")})
	Next

	aTitCpo := {"","",""}
	aCpoVirt:={"AK2_COPIA","AK2_COLA", "AK2_FANTS"}
	For nX := 1 TO Len(aCpoVirt)
		dbSeek(aCpoVirt[nX])
		AADD(aHeaderAK2,{ aTitCpo[nX],;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							""/*SX3->X3_VALID*/,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							SX3->X3_CBOX,;
							SX3->X3_RELACAO,;
							If(nX!=3,"",.F.)/*SX3->X3_WHEN*/})
	Next

	/* If SX3->(dbSeek("AK2_CO"))
		AADD(aHeaderAK2,{ "C.O.",;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							"",;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							SX3->X3_CBOX,;
							SX3->X3_RELACAO,;
							""/})
	EndIf */

	dbSelectArea("SX3")
	dbSetOrder(1)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoGetDados(oGd, oFolder, lVisual, aHeaderAK2, aColsAK2)
Local aArea := GetArea()

oGD[1]:=MsNewGetDados():New(2,2,2,2,,"PcoxGD1LinOK","PcoxGD1TudOK",/*"+AK2_ID"*/,/*aalter*/,2,400,/*fieldok*/,/*superdel*/,"PcoxGD1DelOK",oFolder,aHeaderAK2,aColsAK2)
oGD[1]:AddAction("AK2_VAL",{||PcoPlanEdt()})
oGD[1]:AddAction("AK2_IDENT",{||PcoIdentF3("AK2", nMvPar)})
oGD[1]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGD[1]:oBrowse:bGotFocus := {||Eval(oGD[1]:oBrowse:bChange),oForm_Get:Hide(),If(lVisual, (oCopia:bWhen:={||.F.},oCola:bWhen:={||.F.},oEdit:bWhen:={||.F.},oWrite:bWhen:={||.F.}), Nil)}
oGD[1]:oBrowse:bChange:= {|| PcoPosicAK3(oGd, "AK2_CO"), /*oFormula:bWhen := {||.F.}, */PcoEditCell(.F.)}
oGd[1]:oBrowse:blDblClick:={|| If(Eval(oMarca:bWhen), If(oGd[1]:oBrowse:nColPos == 1, Eval(oMarca:bAction), PcoEditCell(.T.)), Nil) }

If aScan(oGD[1]:aHeader,{|x| AllTrim(x[2])=="AK2_CO"}) > 0
	//somente podera digitar a conta orcamentaria se for inclusao de itens
	oGD[1]:AddAction("AK2_CO",{||If( Empty(aRecAK2) .Or. oGD[1]:nAt > Len(aRecAK2), PcoDig_CO(oGd, .T., lVisual), (Aviso(STR0022,STR0082,{"Ok"}),M->AK2_CO))})  //"Conta Orcamentaria nao pode ser alterada, em virtude de itens vinculados a conta."
EndIf

If ! lVisual
	oGD[1]:lInsert := .T.
EndIf

RestArea(aArea)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoCar_AcolsAK2(oGd, aHeaderAK2, aColsAK2, aFilHead, aHeaderFil, aColsFil)
Local nY,nX,nZ
Local aAuxArea	:= {}
Local aArea		:= GetArea()
Local nHeadItem	:= aScan(oGD[1]:aHeader,{|x| AllTrim(x[2])=="AK2_ID"})
Local nHeadCtaOrc	:= aScan(oGD[1]:aHeader,{|x| AllTrim(x[2])=="AK2_CO"})
Local aAreaAK3 := AK3->(GetArea())
Local nOrdem, bSeek, bWhile, bFiltro
Local nPosCO, nPosClasse, nPosOper, nPosCC, nPosItCtb, nPosClVlr

Local lContinua := .F.
Local aPeriodos	:=	PcoRetPer()
Local aAuxHeader := aClone(oGd[1]:aHeader)
Local aAc		:=	{{},{},{},{},{},{}}
Local nAcessos	:=0
Local nPosAc	:=0
Local cGroup 	:=""
Local cCoCabec 	:= ""

Local nPosUniOrc
Local aNPosEnts := {}
Local nQtd
Local lAK2Found := .T.

aRecAK2 		:= {}

oGD[1]:aCols 	:= {}
aFormula 		:= {}

// Verifica a quantidade de entidades contabeis
If nQtdEntid == NIL
	If cPaisLoc == "RUS"
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
	nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf
EndIf

cWhere := ""

For nX:= 1 To Len(aHeaderFil)
	If !Empty(aColsFil[1,nX])
		Do Case
			Case aHeaderFild[nX,2] == "XK2_CO" .And. !Empty(aColsFil[1,nX])
				cWhere	+=	" AND AK2_CO = '"+aColsFil[1,nX]+"' "
				cCOCabec := aColsFil[1,nX]
			Case aHeaderFild[nX,2] == "XK2_CLASSE" .And. !Empty(aColsFil[1,nX])
				cWhere	+=	" AND AK2_CLASSE = '"+aColsFil[1,nX]+"' "
			Case aHeaderFild[nX,2] == "XK2_OPER" .And. !Empty(aColsFil[1,nX])
				cWhere	+=	" AND AK2_OPER = '"+aColsFil[1,nX]+"' "
			Case aHeaderFild[nX,2] == "XK2_CC" .And. !Empty(aColsFil[1,nX])
				cWhere	+=	" AND AK2_CC = '"+aColsFil[1,nX]+"' "
			Case aHeaderFild[nX,2] == "XK2_ITCTB" .And. !Empty(aColsFil[1,nX])
				cWhere	+=	" AND AK2_ITCTB = '"+aColsFil[1,nX]+"' "
			Case aHeaderFild[nX,2] == "XK2_CLVLR" .And. !Empty(aColsFil[1,nX])
				cWhere	+=	" AND AK2_CLVLR = '"+aColsFil[1,nX]+"' "
			// Verifica Unidade Orcamentaria
			Case AK2->(FieldPos("AK2_UNIORC")) >  0 .And. aHeaderFild[nX,2] == "XK2_UNIORC" .And. !Empty(aColsFil[1,nX])
				cWhere	+=	" AND AK2_UNIORC = '"+aColsFil[1,nX]+"' "
			// Verifica as novas entidades
			Case nQtdEntid > 4 .And. !Empty(aColsFil[1,nX])
				For nQtd := 5 To nQtdEntid
					If (aHeaderFild[nX,2] == "XK2_ENT"+STRZERO(nQtd,2))
						cWhere	+=	" AND AK2_ENT"+STRZERO(nQtd,2)+" = '"+aColsFil[1,nX]+"' "
					EndIf
				Next
		EndCase
	Endif
Next

cGroup	:=	'SQ.AK2_CO,SQ.AK2_ID '
dbSelectArea("AK3")
dbSetOrder(1)

dbSelectArea("AK2")
//dbSetOrder(nOrdem)
If !Empty(cCoCabec)
	cOrder	:=	"AK2_ID "
Else
	cOrder	:=	"AK2_CO,AK2_ID,AK2_CLASSE,AK2_OPER,AK2_CC,AK2_ITCTB,AK2_CLVLR "
Endif
If Alltrim(Upper(TcGetDB())) == "INFORMIX"
	cQuery	:=	""
Else
	cQuery	:=	MontaQryAK2(cRevisa,  ,cWhere,cGroup, cOrder)
EndIf
If !Empty(cQuery)
	lQueryAK2	:=	.T.
	If Select("QRYAK2") > 0
		DbSelectArea("QRYAK2")
		DbCloseArea()
		DbSelectArea("AK2")
	Endif
	PmsIncProc(.T.)
	cAliasAK2	:=	"QRYAK2"
  	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYAK2", .F., .F. )
	PmsIncProc(.T.)

  	aStrAK2	:=	AK2->(DbStruct())
	For ny := 1 to Len(aStrAK2)
		If aStrAK2[nY,2] <> "C"
			TcSetField("QRYAK2",aStrAK2[nY,1],aStrAK2[nY,2] ,aStrAK2[nY,3] ,aStrAK2[nY,4] )
		Endif
	Next

	QRYAK2->(DbGoTop())
	While QRYAK2->(!Eof())

		PmsIncProc(.T.)
		lContinua := .T.
		//posicionar em AK3
		AK3->(dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+QRYAK2->AK2_CO))
		nPosAc := 0
		lContinua := .T.
		For nAcessos := 1 To 5
			If lContinua
				Do Case
				Case nAcessos == 1
					nPosAc:= Ascan(aAc[1],{|x| QRYAK2->AK2_CO == x[1]})
				Case nAcessos == 2
					nPosAc:= Ascan(aAc[2],{|x| QRYAK2->AK2_CO+QRYAK2->AK2_CC == x[1]})
				Case nAcessos == 3
					nPosAc:= Ascan(aAc[3],{|x| QRYAK2->AK2_CO+QRYAK2->AK2_ITCTB == x[1]})
				Case nAcessos == 4
					nPosAc:= Ascan(aAc[4],{|x| QRYAK2->AK2_CO+QRYAK2->AK2_CLVLR == x[1]})
				Case nAcessos == 5
					nPosAc:= Ascan(aAc[5],{|x| AK3->(Recno()) == x[1]})
				Case nAcessos == 6
					nPosAc:= Ascan(aAc[6],{|x| AK3->(Recno()) == x[1]})
				EndCase
				//Verifica se tem acesso aos itens da conta
				If nPosAc > 0
					If !aAc[nAcessos,nPosAc,2]
						/*
						DbSelectArea(cAliasAK2)
						dbSkip()
						Loop
						*/
						lContinua := .F.
						Exit
					Endif
				Else
					Do Case
					Case nAcessos == 1
						lContinua	:=	PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"ITENS",cRevisa)
						aadd(aAc[1],{QRYAK2->AK2_CO,lContinua})
					Case nAcessos == 2
						lContinua	:=	PcoCC_User(AK1->AK1_CODIGO,QRYAK2->AK2_CO,AK3->AK3_PAI,2,"CCUSTO",cRevisa,QRYAK2->AK2_CC)
						aadd(aAc[2],{QRYAK2->AK2_CO+QRYAK2->AK2_CC,lContinua})
					Case nAcessos == 3
						lContinua	:=	PcoIC_User(AK1->AK1_CODIGO,QRYAK2->AK2_CO,AK3->AK3_PAI,2,"ITMCTB",cRevisa,QRYAK2->AK2_ITCTB)
						aadd(aAc[3],{QRYAK2->AK2_CO+QRYAK2->AK2_ITCTB,lContinua})
					Case nAcessos == 4
						lContinua	:=	PcoCV_User(AK1->AK1_CODIGO,QRYAK2->AK2_CO,AK3->AK3_PAI,2,"CLAVLR",cRevisa,QRYAK2->AK2_CLVLR)
						aadd(aAc[4],{QRYAK2->AK2_CO+QRYAK2->AK2_CLVLR,lContinua})
					Case nAcessos == 5
						lContinua	:=	Pco_ChkEntd(AK1->AK1_CODIGO,cRevisa,QRYAK2->AK2_CO,AK3->AK3_PAI,2,AK3->(Recno()))
						aadd(aAc[5],{AK3->(Recno()),lContinua})
					Case nAcessos == 6 .And. lRevisao
						lContinua	:=	PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"REVISA",cVersao)
						aadd(aAc[6],{AK3->(Recno()),lContinua})
					EndCase
				Endif
		   EndIf
		Next
		If lContinua
			nPosIt	:= 0 //aScan(oGD[1]:aCols,{|x| x[nHeadItem] == (cAliasAK2)->AK2_ID})
			//Isto so acontecera em ambiente sem Query, por isso nao é neessaria a validacao
			If nPosIt > 0
				nPosHead := aScan(oGD[1]:aHeader,{|x| CTOD(Substr(x[1],1,10))==(cAliasAK2)->AK2_PERIOD})
				If nPosHead > 0
					oGD[1]:aCols[nPosIt,nPosHead] := PcoPlanCel((cAliasAK2)->AK2_VALOR,(cAliasAK2)->AK2_CLASSE)
					If (nPos := Ascan(aFormula, {|aVal|aVal[1]==nPosIt .And. ;
										aVal[2]==Alltrim(oGD[1]:aHeader[nPosHead,1])})) == 0
				   		aAdd(aFormula, {nPosIt, Alltrim(oGD[1]:aHeader[nPosHead,1]), (cAliasAK2)->AK2_FORMUL})
				    EndIf
				EndIf
			Else
				aADD(oGD[1]:aCols,Array(Len(oGD[1]:aHeader)+1))
				oGD[1]:aCols[Len(oGD[1]:aCols),Len(oGD[1]:aHeader)+1] := .F.
				For ny := 1 to Len(oGD[1]:aHeader)
					Do Case
						Case AllTrim(oGD[1]:aHeader[ny,2])=="AK2_VAL"
							If lQueryAK2
								nPosHead := aScan(oGD[1]:aHeader,{|x| CTOD(Substr(x[1],1,10))==(cAliasAK2)->AK2_PERIOD})
								For nZ	:=	1	To Len(aPeriodos)
									nPosHead := aScan(oGD[1]:aHeader,{|x| x[1]==aPeriodos[nZ]})
									If nPosHead > 0
										oGD[1]:aCols[Len(oGD[1]:aCols),nPosHead] := PcoPlanCel(&("P"+StrZero(nZ,2)),	(cAliasAK2)->AK2_CLASSE)
									EndIf
								Next
							Else
								nPosHead := aScan(oGD[1]:aHeader,{|x| CTOD(Substr(x[1],1,10))==	(cAliasAK2)->AK2_PERIOD})
								If nPosHead > 0
									oGD[1]:aCols[Len(oGD[1]:aCols),nPosHead] := PcoPlanCel(	(cAliasAK2)->AK2_VALOR,	(cAliasAK2)->AK2_CLASSE)
									If (nPos := Ascan(aFormula, {|aVal|aVal[1]==Len(oGD[1]:aCols) .And. ;
																		aVal[2]==Alltrim(oGD[1]:aHeader[nPosHead,1])})) == 0
										aAdd(aFormula, {Len(oGD[1]:aCols), Alltrim(oGD[1]:aHeader[nPosHead,1]), 	(cAliasAK2)->AK2_FORMUL})
								    EndIf
								EndIf
							Endif
							//inicializa todos os periodos orcamentarios com CriaVar()
							//caso esteja preenchida, passa classe como parametro para montar o formato dos valores
							If oGD[1]:aCols[Len(oGD[1]:aCols),nY] == Nil
								If Empty( oGD[1]:aCols[Len(oGD[1]:aCols),nPosClasse] )
									oGD[1]:aCols[Len(oGD[1]:aCols),nY] := PcoPlanCel(CriaVar(oGD[1]:aHeader[ny,2]))
								Else
									oGD[1]:aCols[Len(oGD[1]:aCols),nY] := PcoPlanCel(CriaVar(oGD[1]:aHeader[ny,2]),oGD[1]:aCols[Len(oGD[1]:aCols),nPosClasse])
								EndIf
							Endif
						Case AllTrim(oGD[1]:aHeader[ny,2])=="AK2_IDENT"
							If !Empty(	(cAliasAK2)->AK2_CHAVE )
								aAuxArea := GetArea()
								PcoPosAK6((cAliasAK2)->AK2_CLASSE)
								If !Empty(AK6->AK6_VISUAL)
									dbSelectArea(Substr(	(cAliasAK2)->AK2_CHAVE,1,3))
									dbSetOrder(If(!Empty(Substr(	(cAliasAK2)->AK2_CHAVE,4,2)), Val(Substr(	(cAliasAK2)->AK2_CHAVE,4,2)), 1))
									dbSeek(Substr(	(cAliasAK2)->AK2_CHAVE,6,Len(	(cAliasAK2)->AK2_CHAVE)))
									oGD[1]:aCols[Len(oGD[1]:aCols),ny] := &(AK6->AK6_VISUAL)
								EndIf
								RestArea(aAuxArea)
							EndIf
						Case AllTrim(oGD[1]:aHeader[ny,2])=="AK2_DESCLA"
							aAuxArea := GetArea()
							If PcoPosAK6((cAliasAK2)->AK2_CLASSE )
								oGD[1]:aCols[Len(oGD[1]:aCols),ny] := AK6->AK6_DESCRI
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(oGD[1]:aHeader[ny,2])=="AK2_UM"
							aAuxArea := GetArea()
							PcoPosAK6((cAliasAK2)->AK2_CLASSE)
							If !Empty(AK6->AK6_UM)
								If !Empty(	(cAliasAK2)->AK2_CHAVE)
									dbSelectArea(Substr(	(cAliasAK2)->AK2_CHAVE,1,3))
									dbSetOrder(Val(Substr(	(cAliasAK2)->AK2_CHAVE,4,2)))
									MsSeek(Substr(	(cAliasAK2)->AK2_CHAVE,6,Len(	(cAliasAK2)->AK2_CHAVE)))
								EndIf
								oGD[1]:aCols[Len(oGD[1]:aCols),ny] := &(AK6->AK6_UM)
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_DESCCO"
							AK5->(dbSetOrder(1))
							If AK5->(dbSeek(xFilial()+(cAliasAK2)->AK2_CO))
								oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := AK5->AK5_DESCRI
							EndIf
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_DESCCC"
							CTT->(dbSetOrder(1))
							If CTT->(dbSeek(xFilial()+(cAliasAK2)->AK2_CC))
								oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := CTT->CTT_DESC01
							EndIf
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_DESCIT"
							CTD->(dbSetOrder(1))
							If CTD->(dbSeek(xFilial()+(cAliasAK2)->AK2_ITCTB))
								oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := CTD->CTD_DESC01
							EndIf
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_DESCCL"
							CTH->(dbSetOrder(1))
							If CTH->(dbSeek(xFilial()+(cAliasAK2)->AK2_CLVLR))
								oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := CTH->CTH_DESC01
							EndIf
						OtherWise
							If ( oGD[1]:aHeader[ny,10] != "V")
								oGD[1]:aCols[Len(oGD[1]:aCols),ny] := (cAliasAK2)->(&(oGD[1]:aHeader[ny,2]))
							EndIf
					EndCase
				Next
				//Carregar as formulas
				If lQueryAK2
		   			cQuery	:=	" SELECT AK2_FORMUL, AK2_PERIOD FROM "+RetSqlName('AK2')+" AK2 "
			   		cQuery	+=	" WHERE AK2_FILIAL='"+xFilial('AK2')+"' AND AK2_ORCAME='"+QRYAK2->AK2_ORCAME+"' "
			   		cQuery	+=	" AND AK2_VERSAO='"+ QRYAK2->AK2_VERSAO +"' AND AK2_CO='"+ QRYAK2->AK2_CO +"' AND AK2_ID = '"+QRYAK2->AK2_ID+"' "
			   		cQuery	+=	" AND AK2_FORMUL <> '"+Space(Len(AK2->AK2_FORMUL))+"'  "
		   			cQuery	+=	" AND D_E_L_E_T_= ' ' "
   					cQuery	:=	ChangeQuery(cQuery)
	  				dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
					While !EOF()
						nPosHead := aScan(oGD[1]:aHeader,{|x| Dtos(CTOD(Substr(x[1],1,10)))==QRYTRB->AK2_PERIOD})
						If nPosHead	>	0
							If (nPos := Ascan(aFormula, {|aVal| aVal[1] == Len(oGD[1]:aCols) .And. ;
																aVal[2]==Alltrim(oGD[1]:aHeader[nPosHead,1])})) == 0
								aAdd(aFormula, {Len(oGD[1]:aCols), Alltrim(oGd[1]:aHeader[nPosHead,1]), 	QRYTRB->AK2_FORMUL})
							Endif
						EndIf
						DbSkip()
					Enddo
					DbCloseArea()
				Endif
				oGD[1]:aCols[Len(oGD[1]:aCols)][COL_MARK] := BMP_OFF//"LBNO"
				oGD[1]:aCols[Len(oGD[1]:aCols)][COL_EDIT] := BMP_BRANCO//"LBNO"
				oGD[1]:aCols[Len(oGD[1]:aCols)][COL_COPY] := BMP_OFF//"LBNO"
				oGD[1]:aCols[Len(oGD[1]:aCols)][COL_COLA] := BMP_OFF//"LBNO"
				aAdd(aRecAK2, { Len(oGD[1]:aCols), {}, QRYAK2->(AK2_CO+AK2_ID) } )
			EndIf
		Endif
		DbSelectArea(cAliasAK2)
		dbSkip()
	Enddo
Else
	lQueryAK2	:=	.F.
	//Monta Ordem, Seek, While, Filtro
	If aFilHead[1][2] == "XK2_CO"
	   nPosCO := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_CO"})
		nOrdem := 5
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosCO]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_CO", aFilHead, aHeaderFil, aColsFil)

	ElseIf aFilHead[1][2] == "XK2_CLASSE"
	   nPosClasse := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_CLASSE"})
		nOrdem := 6
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosClasse]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CLASSE == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_CLASSE", aFilHead, aHeaderFil, aColsFil)

	ElseIf aFilHead[1][2] == "XK2_OPER"
	   nPosOper := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_OPER"})
		nOrdem := 7
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosOper]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_OPER == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_OPER", aFilHead, aHeaderFil, aColsFil)

	ElseIf aFilHead[1][2] == "XK2_CC"
	   nPosCC := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_CC"})
		nOrdem := 8
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosCC]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CC == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_CC", aFilHead, aHeaderFil, aColsFil)

	ElseIf aFilHead[1][2] == "XK2_ITCTB"
	   nPosItCtb := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_ITCTB"})
		nOrdem := 9
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosItCtb]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_ITCTB == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_ITCTB", aFilHead, aHeaderFil, aColsFil)

	ElseIf aFilHead[1][2] == "XK2_CLVLR"
	   nPosClVlr := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_CLVLR"})
		nOrdem := 10
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosClVlr]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CLVLR == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_CLVLR", aFilHead, aHeaderFil, aColsFil)
	EndIf

	//Monta Ordem, Seek, While, Filtro
	If aFilHead[1][2] == "XK2_CO"
	   nPosCO := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_CO"})
		nOrdem := 5
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosCO]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_CO", aFilHead, aHeaderFil, aColsFil)

	ElseIf aFilHead[1][2] == "XK2_CLASSE"
	   nPosClasse := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_CLASSE"})
		nOrdem := 6
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosClasse]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CLASSE == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_CLASSE", aFilHead, aHeaderFil, aColsFil)

	ElseIf aFilHead[1][2] == "XK2_OPER"
	   nPosOper := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_OPER"})
		nOrdem := 7
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosOper]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_OPER == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_OPER", aFilHead, aHeaderFil, aColsFil)

	ElseIf aFilHead[1][2] == "XK2_CC"
	   nPosCC := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_CC"})
		nOrdem := 8
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosCC]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CC == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_CC", aFilHead, aHeaderFil, aColsFil)

	ElseIf aFilHead[1][2] == "XK2_ITCTB"
	   nPosItCtb := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_ITCTB"})
		nOrdem := 9
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosItCtb]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_ITCTB == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_ITCTB", aFilHead, aHeaderFil, aColsFil)

	ElseIf aFilHead[1][2] == "XK2_CLVLR"
	   nPosClVlr := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_CLVLR"})
		nOrdem := 10
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosClVlr]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CLVLR == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_CLVLR", aFilHead, aHeaderFil, aColsFil)

	ElseIf AK2->(FieldPos("AK2_UNIORC")) >  0 .And. aFilHead[1][2] == "XK2_UNIORC"   // Verifica Unidade Orcamentaria
	   nPosUniOrc := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_UNIORC"})
		nOrdem := 11
		bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][nPosUniOrc]}
		bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_UNIORC == ;
							Eval(bSeek))}
		bFiltro := PcoMontaFiltro("XK2_UNIORC", aFilHead, aHeaderFil, aColsFil)

	ElseIf nQtdEntid > 4  // Verifica novas entidades contabeis
		nOrdem := 12
		aNPosEnts := Array(nQtdEntid)
		For nQtd := 5 To nQtdEntid
			If aFilHead[1][2] == "XK2_ENT"+STRZERO(nQtd,2)
				aNPosEnts[nQtd] := aScan(aHeaderFil,{|x| AllTrim(x[2])=="XK2_ENT"+STRZERO(nQtd,2)})

				bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+oGd[2]:aCols[1][aNPosEnts[nQtd]]}
				bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+FieldGet(AK2->(FieldPos("XK2_ENT"+STRZERO(nQtd,2)))) == ;
									Eval(bSeek))}
				bFiltro := PcoMontaFiltro("XK2_ENT"+STRZERO(nQtd,2), aFilHead, aHeaderFil, aColsFil)
			EndIf
			nOrdem++
		Next

	EndIf

	dbSelectArea("AK3")
	dbSetOrder(1)

	dbSelectArea("AK2")
	dbSetOrder(nOrdem)
	If dbSeek(Eval(bSeek))
		While AK2->(!Eof() .And. Eval(bWhile))
			lContinua := Eval(bFiltro)
			If lContinua
				//posicionar em AK3
				AK3->(dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+AK2->AK2_CO))

				If 	! PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"ITENS",cRevisa) .OR. ;
					! PcoCC_User(AK1->AK1_CODIGO,AK2->AK2_CO,AK3->AK3_PAI,2,"CCUSTO",cRevisa,AK2->AK2_CC) .OR. ;
					! PcoIC_User(AK1->AK1_CODIGO,AK2->AK2_CO,AK3->AK3_PAI,2,"ITMCTB",cRevisa,AK2->AK2_ITCTB) .OR. ;
					! PcoCV_User(AK1->AK1_CODIGO,AK2->AK2_CO,AK3->AK3_PAI,2,"CLAVLR",cRevisa,AK2->AK2_CLVLR) .OR. ;
					! Pco_ChkEntd(AK1->AK1_CODIGO,cRevisa,AK2->AK2_CO,AK3->AK3_PAI,2,AK3->(Recno()))  .Or. ;
					! PcoUserEnts()
					lContinua := .F.
				EndIf

		   EndIf
		   If ! lContinua
			   AK2->(dbSkip())
			   Loop
			EndIf
			If nHeadCtaOrc > 0
				nPosIt	:= aScan(oGD[1]:aCols,{|x| x[nHeadItem]+x[nHeadCtaOrc] == AK2->AK2_ID+AK2->AK2_CO})
			Else
				nPosIt	:= aScan(oGD[1]:aCols,{|x| x[nHeadItem] == AK2->AK2_ID})
			EndIf
			If nPosIt > 0
				nPosHead := aScan(oGD[1]:aHeader,{|x| CTOD(Substr(x[1],1,10))==AK2->AK2_PERIOD})
				If nPosHead > 0
					oGD[1]:aCols[nPosIt][nPosHead] := PcoPlanCel(AK2->AK2_VALOR,AK2->AK2_CLASSE)
					If (nPos := Ascan(aFormula, {|aVal|aVal[1]==nPosIt .And. ;
										aVal[2]==Alltrim(oGD[1]:aHeader[nPosHead][1])})) == 0
				   		aAdd(aFormula, {nPosIt, Alltrim(oGd[1]:aHeader[nPosHead][1]), AK2->AK2_FORMUL})
				    EndIf
				EndIf
				aAdd(aRecAK2[nPosIt, 2], AK2->(Recno()))
			Else
				aADD(oGD[1]:aCols,Array(Len(oGD[1]:aHeader)+1))
				oGD[1]:aCols[Len(oGD[1]:aCols)][Len(oGD[1]:aHeader)+1] := .F.

				For ny := 1 to Len(oGD[1]:aHeader)
					Do Case
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_VAL"
							//inicializa todos os periodos orcamentarios com CriaVar()
							oGD[1]:aCols[Len(oGD[1]:aCols)][nY] := PcoPlanCel(CriaVar(oGD[1]:aHeader[ny][2]))
	                        //depois atribue o valor que estiver na base de dados
							nPosHead := aScan(oGD[1]:aHeader,{|x| CTOD(Substr(x[1],1,10))==AK2->AK2_PERIOD})
							If nPosHead > 0
								oGD[1]:aCols[Len(oGD[1]:aCols)][nPosHead] := PcoPlanCel(AK2->AK2_VALOR,AK2->AK2_CLASSE)
								If (nPos := Ascan(aFormula, {|aVal|aVal[1]==Len(oGD[1]:aCols) .And. ;
																	aVal[2]==Alltrim(oGD[1]:aHeader[nPosHead][1])})) == 0
									aAdd(aFormula, {Len(oGD[1]:aCols), Alltrim(oGd[1]:aHeader[nPosHead][1]), AK2->AK2_FORMUL})
							    EndIf
							EndIf
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_IDENT"
							If !Empty(AK2->AK2_CHAVE)
								aAuxArea := GetArea()
								AK6->(dbSetOrder(1))
								AK6->(dbSeek(xFilial()+AK2->AK2_CLASSE))
								If !Empty(AK6->AK6_VISUAL)
									dbSelectArea(Substr(AK2->AK2_CHAVE,1,3))
									dbSetOrder(If(!Empty(Substr(AK2->AK2_CHAVE,4,2)), Val(Substr(AK2->AK2_CHAVE,4,2)), 1))
									dbSeek(Substr(AK2->AK2_CHAVE,6,Len(AK2->AK2_CHAVE)))
									oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := &(AK6->AK6_VISUAL)
								EndIf
								RestArea(aAuxArea)
							EndIf
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_DESCLA"
							aAuxArea := GetArea()
							AK6->(dbSetOrder(1))
							If AK6->(dbSeek(xFilial()+AK2->AK2_CLASSE))
								oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := AK6->AK6_DESCRI
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_UM"
							AK6->(dbSetOrder(1))
							AK6->(dbSeek(xFilial()+AK2->AK2_CLASSE))
							aAuxArea := GetArea()
							If !Empty(AK6->AK6_UM)
								If !Empty(AK2->AK2_CHAVE)
									dbSelectArea(Substr(AK2->AK2_CHAVE,1,3))
									dbSetOrder(Val(Substr(AK2->AK2_CHAVE,4,2)))
									dbSeek(Substr(AK2->AK2_CHAVE,6,Len(AK2->AK2_CHAVE)))
								EndIf
								oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := &(AK6->AK6_UM)
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_DESCCO"
							aAuxArea := GetArea()
							AK5->(dbSetOrder(1))
							If AK5->(dbSeek(xFilial()+AK2->AK2_CO))
								oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := AK5->AK5_DESCRI
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_DESCCC"
							aAuxArea := GetArea()
							CTT->(dbSetOrder(1))
							If CTT->(dbSeek(xFilial()+AK2->AK2_CC))
								oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := CTT->CTT_DESC01
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_DESCIT"
							aAuxArea := GetArea()
							CTD->(dbSetOrder(1))
							If CTD->(dbSeek(xFilial()+AK2->AK2_ITCTB))
								oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := CTD->CTD_DESC01
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(oGD[1]:aHeader[ny][2])=="AK2_DESCCL"
							aAuxArea := GetArea()
							CTH->(dbSetOrder(1))
							If CTH->(dbSeek(xFilial()+AK2->AK2_CLVLR))
								oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := CTH->CTH_DESC01
							EndIf
							RestArea(aAuxArea)
						OtherWise
							If ( oGD[1]:aHeader[ny][10] != "V")
								oGD[1]:aCols[Len(oGD[1]:aCols)][ny] := FieldGet(FieldPos(oGD[1]:aHeader[ny][2]))
							EndIf
					EndCase
				Next
				oGD[1]:aCols[Len(oGD[1]:aCols)][COL_MARK] := BMP_OFF//"LBNO"
				oGD[1]:aCols[Len(oGD[1]:aCols)][COL_EDIT] := BMP_BRANCO//"LBNO"
				oGD[1]:aCols[Len(oGD[1]:aCols)][COL_COPY] := BMP_OFF//"LBNO"
				oGD[1]:aCols[Len(oGD[1]:aCols)][COL_COLA] := BMP_OFF//"LBNO"
				aAdd(aRecAK2, { Len(oGD[1]:aCols), {AK2->(Recno())} } )
			EndIf
			dbSkip()
		End
	EndIf
Endif

If Empty(oGD[1]:aCols)
	lAK2Found := .F.
	aadd(oGD[1]:aCols,Array(Len(oGD[1]:aHeader)+1))
	For ny := 1 to Len(oGD[1]:aHeader)
		If AllTrim(oGD[1]:aHeader[ny][2])=="AK2_ID"
			oGD[1]:aCols[1][ny] := Padr("*", Len(AK2->AK2_ID))
		ElseIf AllTrim(oGD[1]:aHeader[ny][2])=="AK2_VAL"
			//inicializa todos os periodos orcamentarios com CriaVar()
			oGD[1]:aCols[1][nY] := PcoPlanCel(CriaVar(oGD[1]:aHeader[ny][2]))
		Else
			oGD[1]:aCols[1][ny] := CriaVar(oGD[1]:aHeader[ny][2])
		EndIf
	Next ny
	oGD[1]:aCols[1][COL_MARK] := BMP_OFF
	oGD[1]:aCols[1][COL_EDIT] := BMP_INCL
	oGD[1]:aCols[1][COL_COPY] := BMP_OFF
	oGD[1]:aCols[1][COL_COLA] := BMP_OFF
	oGD[1]:aCols[1][Len(oGD[1]:aHeader)+1] := .F.
	Eval(oEdit:bAction)
EndIf
If lAK2Found
	oGD[1]:oBrowse:GoTop()  //Danilo
	oGD[1]:oBrowse:Refresh()
Else
	//TODO ESSE TRECHO DO IF eh para conseguir dar refresh
	If oGD[1]:AddLine(.T.,.T.)
		oGD[1]:DelLine()
		aSize(oGD[1]:aCols, 1)
		oGD[1]:GoTo(1)
	EndIf
EndIf
If lQueryAK2
	DbSelectArea("QRYAK2")
	DbCloseArea()
EndIf
DbSelectArea("AK2")

RestArea(aAreaAK3)
RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoMontaFiltro(cCpoChv, aFilHead, aHeaderFil, aColsFil)
Local bFilter := {||.T.}
Local nX, nY
Local cFiltro := ""
Local nPos
Local cCampo := ""

For nX := 2 TO Len(aFilHead)

		nPos := Ascan(aHeaderFil, {|aVal| Alltrim(aVal[2]) == aFilHead[nX][2]})
		cCampo := "AK2->"+StrTran(Alltrim(aFilHead[nX][2]), "XK2_", "AK2_")

		If	Alltrim(cCampo) == "AK2->AK2_DESCLA" .Or. AllTrim(cCampo) == "AK2->AK2_DESCCO" .Or.;
			Alltrim(cCampo) == "AK2->AK2_DESCCC" .Or. Alltrim(cCampo) == "AK2->AK2_DESCIT" .Or.;
			Alltrim(cCampo) == "AK2->AK2_DESCCL"
			Loop
		EndIf

		cFiltro += cCampo
		cFiltro += " == "
	   cFiltro += "PadR('"+AcolsFil[1][nPos]+"', Len("+cCampo+"))"

		If nX < Len(aFilHead)
			cFiltro += " .And. "
		EndIf

Next

If Right(cFiltro, 7)== " .And. "
	cFiltro := Subs(cFiltro, 1, Len(cFiltro)-7)
EndIf

//monta o bloco para filtro
If ! Empty(cFiltro)
	bFilter := MontaBlock("{|| "+cFiltro+"  }")
EndIf

Return(bFilter)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoxGD2LinOK()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoxGD2TudOK()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoPosicAK3(oGd, cCampAK2)
Local nPosCO

//posicionar em AK3 a cada mudanca da linha de grade
If (nPosCO:=aScan(oGd[1]:aHeader,{|x| AllTrim(x[2])=="AK2_CO"})) > 0
	dbSelectArea("AK3")
	dbSetOrder(1)
	If dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+oGd[1]:aCols[oGd[1]:nAt][nPosCO])
		M->AK2_CO := AK3_CO
	Else
		M->AK2_CO := Space(Len(AK2->AK2_CO))
	EndIf
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoDig_CO(oGd, lChkAcess, lVisualiza)
Local cContaOrc := Space(Len(AK2->AK2_CO)), lRet := .T.
Local aArea := GetArea()
Local aAreaAK5 := AK5->(GetArea())
Local aAreaAK3 := AK3->(GetArea())

Local nPosCC := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_CC"})
Local nPosIC := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_ITCTB"})
Local nPosCV := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_CLVLR"})
Local nPosDescCO := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_DESCCO"})
Local nPosId := aScan(oGd[1]:aHeader,{|x| AllTrim(x[2])=="AK2_ID"})
Local cCCusto := Space(Len(AK2->AK2_CC))
Local cItCtb := Space(Len(AK2->AK2_ITCTB))
Local cClVlr := Space(Len(AK2->AK2_CLVLR))
Local lMore
Local lSintetica := .F.
Local nPosUni
Local cUniOrc, cEnt
Local aNPosEnts := {}, aCEnts := {}
Local nQtd

If(AK2->(FieldPos("AK2_UNIORC")) >  0)
	nPosUni := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_UNIORC"})
	cUniOrc := Space(Len(AK2->AK2_UNIORC))
EndIf

// Verifica a quantidade de entidades contabeis
If nQtdEntid == NIL
	If cPaisLoc == "RUS"
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
	nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf
EndIf

If nQtdEntid > 4
	aNPosEnts := Array(nQtdEntid)
	aCEnts		:= Array(nQtdEntid)

	For nQtd := 5 To nQtdEntid
		cEnt := "AK2->AK2_ENT"+STRZERO(nQtd,2)

		aNPosEnts[nQtd] := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])== "XK2_ENT"+STRZERO(nQtd,2)})
		aCEnts[nQtd] := Space(Len(&cEnt))
	Next
EndIf

If ConPad1( , , , "AK5" , , , .F. )
	cContaOrc := AK5->AK5_CODIGO
	lSintetica := (AK5->AK5_TIPO == "1")
	lRet := !lSintetica

	//Valid especiico para a conta Orçamentária - X3_VLDUSER - PCOA100

	If lRet .And. type('cVldUsrCO') == 'C' .And. !Empty(cVldUsrCO)
	   lRet := &cVldUsrCO
	Endif

	If lRet
		//verifica se a conta orcamentaria existe na planilha e direito do usuario
		dbSelectArea("AK3")
		dbSetOrder(1)
		If dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+cContaOrc)  //se existe
			M->AK2_CO := AK3->AK3_CO
			//verifica direito do usuario na conta orcamentaria
			If PcoChkUser(AK1->AK1_CODIGO, cContaOrc, AK3->AK3_PAI, 1, "ESTRUT", AK3->AK3_VERSAO)
				//verifica direito do usuario nos itens da conta orcamentaria
				If !PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,3,"ITENS",AK3->AK3_VERSAO)
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
		Else
			M->AK2_CO := cContaOrc
			//verifica direito do usuario na conta orcamentaria
		      lRet := PcoAssistCtaOrc(cContaOrc)
		      If lRet
					If dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+cContaOrc)  //se existe
						M->AK2_CO := AK3->AK3_CO
		         Else
		         	lRet := .F.
		         EndIf
		      EndIf
		EndIf
		If lRet
			// Atualiza descricao da conta orcamentaria na GetDados de filtro
			If nPosDescCO > 0
				AK5->(dbSetOrder(1))
				AK5->(dbSeek(xFilial()+cContaOrc))
				oGd[2]:aCols[oGd[2]:nAt][nPosDescCO] := AK5->AK5_DESCRI
				oGd[2]:refresh()
			EndIf
		EndIf
	EndIf
Else
	If nPosDescCO > 0
		oGd[2]:aCols[oGd[2]:nAt][nPosDescCO] := Space(oGD[2]:aHeader[nPosDescCO,4])
	EndIf
EndIf

If !lRet
	If lSintetica
		Aviso(STR0053, STR0090, {STR0001},2)	// "Atenção"###"Não é permitido informar conta orçamentária sintética. Por favor, verifique o código de CO digitado."###"Fechar"
	Else
		Aviso(STR0053, STR0054, {STR0001},2) //"Atenção"###"Conta não selecionada ou usuario sem direitos de utilizar a esta conta orcamentaria selecionada nesta planilha."###"Fechar"
	EndIf
	cContaOrc := Space(Len(AK2->AK2_CO))
	M->AK2_CO := Space(Len(AK2->AK2_CO))
	oGd[1]:Acols[oGd[1]:nAt][oGd[1]:oBrowse:nColPos] := Space(Len(AK2->AK2_CO))
	oGd[1]:oBrowse:nColPos := nPosID
	oGd[1]:oBrowse:Refresh()
	RestArea(aAreaAK3)
Else
	If lChkAcess
		//verifica direitos usuario se este digitou Centro de Custo
		//Item Contabil e Classe de Valor na grade de filtro
		If nPosCC > 0
			cCCusto := oGd[2]:aCols[1, nPosCC]
		EndIf

		If nPosIC > 0
			cItCtb := oGd[2]:aCols[1, nPosIC]
		EndIf

		If nPosCV > 0
			cClVlr := oGd[2]:aCols[1, nPosCV]
		EndIf

		lMore := .T.
		While lMore
		    // verifica centro de custo
			lRet := !Empty(cCCusto)
			If lRet
				lRet := PcoCC_User(AK1->AK1_CODIGO,AK3->AK3_CO,AK3->AK3_PAI,2,"CCUSTO",cRevisa,cCCusto,If(lVisualiza, 1, 2) )
				If ! lRet
		    	   Exit
		        EndIf
			EndIf
			//verifica item contabil
			lRet := !Empty(cItCtb)
			If lRet
				lRet := PcoIC_User(AK1->AK1_CODIGO,AK3->AK3_CO,AK3->AK3_PAI,2,"ITMCTB",cRevisa,cItCtb,If(lVisualiza, 1, 2) )
				If ! lRet
		    	   Exit
			    EndIf
			EndIf
		    //verifica classe de valor
		    lRet := !Empty(cClVlr)
			If lRet
				lRet := PcoCV_User(AK1->AK1_CODIGO,AK3->AK3_CO,AK3->AK3_PAI,2,"CLAVLR",cRevisa,cClVlr,If(lVisualiza, 1, 2) )
				If 	! lRet
		    	   Exit
			    EndIf
			EndIf

			//verifica Unidade Orcamentaria
			If !Empty(cUniOrc) .Or. !Empty(aCEnts)
				lRet := PcoUserEtd(cUniOrc,aCEnts)
				If !lRet
					Exit
				EndIf
			EndIf
			//Se nao sair em nenhum if encerra o laco e retorna .T.
			lRet  := .T.
			lMore := .F.
		End
		If lRet .And. oGd[1]:lNewLine
		   oGd[1]:Acols[oGd[1]:nAt, nPosId] := PadR("*", Len(AK2->AK2_ID))
		EndIf
	EndIf
EndIf
RestArea(aArea)
RestArea(aAreaAK5)

Return(cContaOrc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAssistCtaOrc(cContaOrc, lPlanNormal)
Local lRet := .F.
Local aArea := GetArea()
Default lPlanNormal := .F.

lRet := PcoAuxCtaOrc(cContaOrc, lPlanNormal)

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoAuxCtaOrcºAutor  ³Paulo Carnelossi   º Data ³ 16/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para exibir as contas orcamentaria a serem inseridas º±±
±±º          ³na planilha atual   (funcao auxiliar)                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoAuxCtaOrc(cCtaOrc, lPlanNormal)
Local oDlg, oFont, oPanelCta
Local aButtons := {}

Local aArea:=GetArea()
Local aAreaAK5:=AK5->(GetArea())
Local oPanFix
Local oTree
Local lRet := .F.
Local oSay

DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
DEFINE MSDIALOG oDlg TITLE cCadastro +STR0055 OF oMainWnd PIXEL FROM 0,0 TO 450,450  //" - Inclusao de contas"

oPanFix := TPanel():New(10,10,'',oDlg,oDlg:oFont, .T., .T., CLR_BLACK, RGB(245, 245, 240), 048, 030,.T.,.T. )
oPanFix:Align := CONTROL_ALIGN_TOP

oSay := TSay():New( 3, 2, {||STR0056} , oPanFix, ,oFont,,,,.T.,CLR_BLUE,,400,15,,,,) //"Atenção! Esta conta orçamentária nunca foi utilizada nesta planilha."
oSay := TSay():New( 15, 2, {||STR0057} , oPanFix, ,oFont,,,,.T.,CLR_BLUE,,400,15,,,,) //"Confirma inclusão da conta selecionada ? "

// Informacoes para montagem do Tree
oTree:= dbTree():New( 3, 3, 100, 100, oDlg ,,, .T.)
oTree:Align := CONTROL_ALIGN_ALLCLIENT
oTree:BeginUpdate()
oTree:Reset()
oTree:EndUpdate()

oTree:BeginUpdate()
aCtaPlan := {}
nNivAtu:=1
oTree:AddTree( Alltrim(AK1->AK1_CODIGO) + "- " + AK1->AK1_DESCRI, .F., "PMSEXPALL","PMSEXPCMP",,, "AK1"+AK1->AK1_CODIGO,,,nNivAtu)
aAdd(aCtaPlan, {"AK1"+AK1->AK1_CODIGO, 1})
nNivAtu++

PcoCtaAddPlan(cCtaOrc, oTree, AK5->AK5_COSUP, @nNivAtu)

oTree:AddTree( Alltrim(AK5->AK5_CODIGO) + " - " + AK5->AK5_DESCRI, .F., "", "",,, "AK5"+AK5->AK5_CODIGO,,,nNivAtu)

aAdd(aCtaPlan, {"AK5"+AK5->AK5_CODIGO, nNivAtu})

oTree:TreeSeek("AK5"+AK5->AK5_CODIGO)

dbEndTree oTree
oTree:EndUpdate()
oTree:Refresh()

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lRet := PCOChkDir(aCtaPlan),oDlg:End()},{||oDlg:End()},, aButtons )

RestArea(aAreaAK5)
RestArea(aArea)

If ! lPlanNormal
	If lRet
		If ! Empty(M->AK2_CLASSE)
			PcoPlanCl()
		EndIf
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoCtaAddPlan(cCtaOrc, oTree, cCtaSup, nNivAtu)
Local aAreaAK5 := AK5->(GetArea())
Local cCtaTree := ""
Local lAdItem := .F.
dbSelectArea("AK5")
dbSetOrder(1)
MsSeek(xFilial()+cCtaSup)

While !Eof() .And. AK5->AK5_FILIAL+AK5->AK5_CODIGO==xFilial("AK5")+cCtaSup

	lAdItem := .T.
	cCtaTree := AK5->AK5_CODIGO

	If !Empty(AK5->AK5_COSUP) .And. cCtaSup == AK5->AK5_CODIGO //nNivelMax >= Val(AK3->AK3_NIVEL)
		PcoCtaAddPlan(AK5->AK5_CODIGO, oTree, AK5->AK5_COSUP, @nNivAtu)
		oTree:AddTree( Alltrim(AK5->AK5_CODIGO) + " - " + AK5->AK5_DESCRI, .F., "MDIVISIO_PQ", "MDIVISIO_PQ",,, "AK5"+AK5->AK5_CODIGO,,,nNivAtu)
	Else
		oTree:AddTree( Alltrim(AK5->AK5_CODIGO) + " - " + AK5->AK5_DESCRI, .F., "MDIVISIO_PQ", "MDIVISIO_PQ",,, "AK5"+AK5->AK5_CODIGO,,,nNivAtu)
		Exit
	EndIf

	dbSelectArea("AK5")
	dbSkip()
End

If lAdItem
	aAdd(aCtaPlan, {"AK5"+cCtaTree, nNivAtu})
	nNivAtu++
EndIf

RestArea(aAreaAK5)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PCOChkDir(aCtaPlan)
Local nX
Local lRet	:= .T.
aPlanCta := aClone(aCtaPlan)

ASORT(aCtaPlan,,, { |x, y| y[2] < x[2] })

For nX := 2 TO Len(aCtaPlan)-1
	lRet := PcoChkUser(AK1->AK1_CODIGO, Subs(aCtaPlan[nX][1],4), Subs(aCtaPlan[nX+1][1],4)/*AK3->AK3_PAI*/, 2, "ESTRUT", cRevisa/*AK3->AK3_VERSAO*/)
	If lRet
		Exit
	EndIf
Next

If !lRet
	Aviso(STR0058,STR0059,{STR0001},2) //"Sem Permissão"###"Usuário sem permissao para inclusao de contas orcamentarias."###"Fechar"
Else
	If (lRet := Aviso(STR0060,STR0061,{STR0024, STR0025},2) == 1) //"Confirma inclusão ?"###"Confirma a inclusao da conta selecionada na planilha orçamentaria ?"###"Sim"###"Nao"
		ASORT(aPlanCta,,, { |x, y| x[2] < y[2]  })
		dbSelectArea("AK3")
		dbSetOrder(1)
		For nX := 2 TO Len(aPlanCta)
			If !dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+Subs(aPlanCta[nX][1],4))
				RecLock("AK3", .T.)
				AK3_FILIAL := xFilial("AK3")
				AK3_ORCAME := AK1->AK1_CODIGO
				AK3_VERSAO := cRevisa
				AK3_CO := Subs(aPlanCta[nX][1],4)
				AK3_PAI := Subs(aPlanCta[nX-1][1],4)
		  		AK5->(dbSeek(xFilial("AK5")+Subs(aPlanCta[nX][1],4)))
				AK3_TIPO := AK5->AK5_TIPO
				AK3_NIVEL := StrZero(aPlanCta[nX][2], Len(AK3->AK3_NIVEL))
				AK3_DESCRI := AK5->AK5_DESCRI
				MsUnLock()
			EndIf
		Next
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoAK2BMP ºAutor  ³Guilherme C. Leal   º Data ³  22/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera bitmap de uso do lancamento.                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoAK2BMP(oGd,nPosAtivo)
If !oGd:aCols[oGd:nAt][Len(oGd:aHeader)+1]
	If Alltrim(oGd:aCols[oGd:nAt][nPosAtivo]) == BMP_ON
		oGd:aCols[oGd:nAt][nPosAtivo]:= BMP_OFF
	Else
		oGd:aCols[oGd:nAt][nPosAtivo]:= BMP_ON
	EndIf
EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoAK2EditºAutor  ³Guilherme C. Leal   º Data ³  22/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera bitmap de uso do lancamento.                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoAK2Edit(oGd,nPosAtivo, nLinha)
Local lIncl := .F.
DEFAULT nLinha := oGd:nAt

If !oGd:aCols[nLinha][Len(oGd:aHeader)+1]
	If Alltrim(oGd:aCols[nLinha][nPosAtivo]) == BMP_BRANCO .OR. ;
		(lIncl := (Alltrim(oGd:aCols[nLinha][nPosAtivo]) == BMP_INCL))
		oGd:aCols[nLinha][nPosAtivo]:= If(lIncl, BMP_INCL, BMP_CHK)
		oGd:oBrowse:SetFocus()
		oGD:lInsert := .T.
		oGD:lUpdate := .T.
		oGD:lDelete := .T.
		oWrite:bWhen := {||.T.}
		oFormula:bWhen := {||.T.}
		oFormZe:SetFocus()
		oFormula:refresh()
		oGd:oBrowse:SetFocus()

	EndIf
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoAK2CopyºAutor  ³Guilherme C. Leal   º Data ³  22/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera bitmap de uso do lancamento.                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoAK2Copy(oGd,nPosAtivo, nLinha)

DEFAULT nLinha := oGd:nAt

If !oGd:aCols[nLinha][Len(oGd:aHeader)+1]
	If Alltrim(oGd:aCols[nLinha][nPosAtivo]) == BMP_OFF
		oGd:aCols[nLinha][nPosAtivo]:= BMP_COPY
	EndIf
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoAK2ColaºAutor  ³Guilherme C. Leal   º Data ³  22/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera bitmap de uso do lancamento.                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoAK2Cola(oGd,nPosAtivo,nLinha)

DEFAULT nLinha := oGd:nAt

If !oGd:aCols[nLinha, Len(oGd:aHeader)+1]
	If Alltrim(oGd:aCols[nLinha, nPosAtivo]) == BMP_OFF
		oGd:aCols[nLinha, nPosAtivo]:= BMP_COLA
//		oGd:aCols[nLinha, COL_EDIT ]:= "PCO_ITINC"
		oWrite:bWhen := {||.T.}
		oFormZe:SetFocus()
		oGd:oBrowse:SetFocus()
	EndIf
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoCopAcols(oGd, aColsCopy, aForm)
Local lContinua := .T.
Local nOpcCopy, nX
Local aAuxCopy
Local aAuxHeader := aClone(oGD:aHeader)

If !Empty(aColsCopy)
	If Aviso(STR0022,STR0027,{STR0024, STR0025},2) == 2 //"Atencao"###"Os valores da grade o item orcamentario ja foi copiado! Sobrepor os valores ?"###"Sim"###"Nao"
		lContinua := .F.
	EndIf
EndIf

If lContinua
	If (nOpcCopy := Aviso(STR0022,STR0062,{STR0063, STR0064, STR0065, STR0066},2)) == 4 //"Atencao"###"Copiar somente ?"###"Linha "###"Planilha "###"Marcadas"###"Cancelar"
		lContinua := .F.
	EndIf
	If lContinua
		aFormCopy := aClone(aForm)
		If nOpcCopy == 2 // Planilha Inteira
			aColsCopy := {aClone(oGd:aCols), aClone(oGd:aHeader), oGd:nAt, {}}
			For nX := 1 TO Len(oGd:aCols)
				PcoAK2Copy(oGd,COL_COPY, nX)
				aAdd(aColsCopy[4], nX)
				aColsCopy[1][nX][COL_MARK] := BMP_OFF
				aColsCopy[1][nX][COL_EDIT] := BMP_INCL
				aColsCopy[1][nX][COL_COPY] := BMP_OFF
				aColsCopy[1][nX][COL_COLA] := BMP_OFF
			Next

		ElseIf nOpcCopy == 1 // Linha Posicionada
		   aAuxCopy := {}
		   aAdd(aAuxCopy, Array(Len(oGD:aHeader)+1))
		   For nX := 1 TO Len(oGd:aCols[oGd:nAt])
		   	aAuxCopy[Len(aAuxCopy)][nX] := oGd:aCols[oGd:nAt][nX]
		   Next
		   aAuxCopy[Len(aAuxCopy)][COL_MARK] := BMP_OFF
			aAuxCopy[Len(aAuxCopy)][COL_EDIT] := BMP_INCL
			aAuxCopy[Len(aAuxCopy)][COL_COPY] := BMP_OFF
			aAuxCopy[Len(aAuxCopy)][COL_MARK] := BMP_OFF
			aColsCopy := { aClone(aAuxCopy), aClone(oGd:aHeader), oGd:nAt, {oGd:nAt} }
			PcoAK2Copy(oGd,COL_COPY)

		ElseIf nOpcCopy == 3 // Linhas Marcadas
			aColsMark := {}
			aColsNumber := {}
			For nX := 1 TO Len(oGd:aCols)
				If oGd:Acols[nX][1] == "LBOK"
					//sinaliza como copiado
					PcoAK2Copy(oGd,COL_COPY, nX)
					//limpa campos Marca/Alter/Cola
					aAdd(aColsMark, aClone(oGd:Acols[nX]))
					aAdd(aColsNumber, nX)
					aColsMark[Len(aColsMark)][COL_MARK] := BMP_OFF
					aColsMark[Len(aColsMark)][COL_EDIT] := BMP_INCL
					aColsMark[Len(aColsMark)][COL_COPY] := BMP_OFF
					aColsMark[Len(aColsMark)][COL_COLA] := BMP_OFF
				EndIf
			Next
			aColsCopy := { aClone(aColsMark), aClone(oGd:aHeader), oGd:nAt, aColsNumber}
		EndIf
	EndIf
EndIf

oGd:oBrowse:SetFocus()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoColaACols(oGd, aColsCopy, aForm)
Local lContinua := .T.
Local nPosClasse, nX, nW
Local MyaCols, MyaHeader, nLinAt
Local aAuxHeader := aClone(oGd:aHeader)
Local nPosId, nPosCO

nPosClasse := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})
nPosId 		:= aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_ID"})
nPosCO 		:= aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CO"})

If Empty(aColsCopy)
	Aviso(STR0022,STR0028,{STR0001},2) //"Atencao"###"Nao sera possivel colar pois  os valores da grade do item orcamentario nao foram copiados!"###"Fechar"
	lContinua := .F.
Else
	MyaCols := aClone(aColsCopy[1])
	MyaHeader := aClone(aColsCopy[2])
	MyNumAcols := aClone(aColsCopy[4])
	nLinAt := aColsCopy[3]
EndIf

If lContinua

	For nX := 1 TO Len(MyaCols)

		//acrescentar a linha
		aADD(oGD:aCols,Array(Len(oGD:aHeader)+1))
		oGD:aCols[Len(oGD:aCols)][Len(oGD:aHeader)+1] := .F.

		//primeiro copiar as formulas se existir
		For nW := 1 TO Len(aForm)
			If aForm[nW][1] == MyNumAcols[nX] /*nX eh a linha do acols*/
        		aAdd(aFormula, { Len(oGD:aCols), aForm[nW][2], aForm[nW][3]})
   			EndIf
   		Next

	   	//copiar as linhas
		For nW := 1 TO Len(MyaCols[nX])
			oGD:aCols[Len(oGD:aCols)][nW] := MyaCols[nX][nW]
   		Next

        //coloca como inclusao de uma nova linha
		oGD:aCols[Len(oGD:aCols), nPosId] := PadR("*", Len(AK2->AK2_ID))
		oGD:aCols[Len(oGD:aCols),COL_EDIT] := BMP_INCL

		aAdd(aLineNew, AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+PadR("*", Len(AK2->AK2_ID)) )

	   	PcoAK2Cola(oGd, COL_COLA, Len(oGD:aCols))

	Next

	oWrite:bWhen := {||.T.}
	oFormZe:SetFocus()

EndIf

oGd:oBrowse:SetFocus()

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoGrvItem³ Autor ³ Edson Maricate        ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de gravacao dos itens da planilha orcamentaria         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoGrvItem(cVersao, oGD, aFixos)

Local aArea		:= GetArea()
Local nHeadItem	:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_ID"})
Local nCpoMore
Local nColuna
Local nLine
Local nX, nY
Local cItemAK2  := Space(Len(AK2->AK2_ID))
Local nPos 			:= 0
Local nPosForm 		:= 0
Local aFormIncl 	:= {}
Local aAuxHeader 	:= aClone(oGd:aHeader)
Local nLenCols		:= Len(oGD:aCols)
Local nLenHeader	:= Len(oGD:aHeader)
Local nHeadCtaOrc	:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_CO"})
Local nColClasse 	:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_CLASSE"})
Local cCo	:=	''
Local cCoAtu:=	''
Local cClasse := ''
Local cClasseAtu := ''
Local cQryRecAK2
Local nPosInc, nPosFix
Local lContinua 	:= .T.

If nHeadCtaOrc == 0
	nHeadCtaOrc	:= aScan(aFixos,{|x| AllTrim(x[1])=="AK2_CO"})
	If nHeadCtaOrc > 0
		cCo	:=	aFixos[nHeadCtaOrc][2]
	Else
		MsgStop("Erro na Gravacao.")
		Return
	EndIf
Endif

If nColClasse == 0
	nColClasse	:= aScan(aFixos,{|x| AllTrim(x[1])=="AK2_CLASSE"})
	If nColClasse > 0
		cClasse := aFixos[nColClasse][2]
	Else
		MsgStop("Erro na Gravacao.")
		Return
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo AK2 (Itens)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AK2")

ProcRegua(nLenCols+2)

Begin Transaction

//primeiro gravar as alteracoes e incluir as inclusoes em array
aLinIncl := {}
aLinRecn := {}

For nLine := 1 to nLenCols
	IncProc()
	If !Empty(cCo)
		cCoAtu := cCo
	Else
		cCoAtu := oGD:aCols[nLine][nHeadCtaOrc]
	Endif

	If !Empty(cClasse)
		cClasseAtu := cClasse
	Else
		cClasseAtu := oGD:aCols[nLine][nColClasse]
	Endif

	cId	:= oGD:aCols[nLine][nHeadItem]

	nPosInc := Ascan(aLineNew, xFilial("AK3")+AK1->AK1_CODIGO+cVersao+cCoAtu+cId)

	If nPosInc == 0 .And. Alltrim(oGD:aCols[nLine][COL_EDIT]) <> BMP_INCL .And. cId <> Padr("*", Len(AK2->AK2_ID))
		If !oGD:aCols[nLine][Len(oGD:aCols[nLine])]   // se nao excluido
			If Alltrim(oGD:aCols[nLine][COL_EDIT]) == BMP_CHK

				For nColuna := 1 to nLenHeader

					If AllTrim(oGD:aHeader[nColuna][2]) == "AK2_VAL"
						AK2->(DbSetorder(1))//AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+DTOS(AK2_PERIOD)+AK2_ID
						If AK2->(DbSeek(xFilial('AK2')+AK1->AK1_CODIGO+cVersao+cCoAtu+ DTOS(Ctod(Substr(oGD:aHeader[nColuna][1],1,10)))+cId))
							RecLock("AK2",.F.)
							lContinua := .T.
						Else
							If PcoPlanVal(oGD:aCols[nLine][nColuna],cClasseAtu) > 0
								lContinua := .T.
								RecLock("AK2",.T.)
							Else
								lContinua := .F.
							EndIf
						EndIf

						If lContinua
							//imprime os campos de acordo aheader da getdados
							For nCpoMore := 1 To nLenHeader
								If ( oGD:aHeader[nCpoMore][10] != "V" ) .And. AllTrim(oGD:aHeader[nCpoMore][2]) != "AK2_VAL" .And. AllTrim(oGD:aHeader[nCpoMore][2]) != "AK2_DESCLA"
									AK2->(FieldPut(FieldPos(oGD:aHeader[nCpoMore][2]),oGD:aCols[nLine][nCpoMore]))
								EndIf
							Next nCpoMore

							//campos fixos
							For nX := 1 TO Len(aFixos)
								If ! (Alltrim(aFixos[nX,1]) $ "AK2_DESCLA|AK2_DESCCO|AK2_DESCCC|AK2_DESCIT|AK2_DESCCL"	)
									AK2->(FieldPut(FieldPos(aFixos[nX][1]),aFixos[nX][2]))
								EndIf
							Next

							//campos ref. planilha/valor/periodo
							AK2->AK2_FILIAL	:= xFilial("AK2")
							AK2->AK2_ORCAME	:= AK1->AK1_CODIGO
							AK2->AK2_VERSAO	:= cVersao
							AK2->AK2_PERIOD	:= CTOD(Substr(oGD:aHeader[nColuna][1],1,10))
							AK2->AK2_VALOR		:= PcoPlanVal(oGD:aCols[nLine][nColuna],AK2->AK2_CLASSE)
							AK2->AK2_DATAI		:= CTOD(Substr(oGD:aHeader[nColuna][1],1,10))
							AK2->AK2_DATAF		:= CTOD(Substr(oGD:aHeader[nColuna][1],14,16))
							//campo de formula para o periodo
							If (nPosForm := Ascan(aFormula, {|aVal|aVal[1]==nLine .And. ;
									aVal[2]==Alltrim(oGD:aHeader[nColuna][1])})) >  0
								AK2->AK2_FORMUL := aFormula[nPosForm][3]
							EndIf

							MsUnlock()
							AK3->(DbSetorder(1))
							AK3->(MsSeek(xFilial()+AK2->(AK2_ORCAME+AK2_VERSAO+AK2_CO)))
							PcoUnLockAK2(AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+AK2->AK2_ID )

							If lSimulac
								PcoDetLan("000252","03","PCOA100")
							ElseIf lRevisao
								PcoDetLan("000252","02","PCOA100")
							Else
								PcoDetLan("000252","01","PCOA100")
							EndIf
						EndIf
					EndIf

				Next nColuna

			EndIf

		Else // se excluido linha

			If !Empty(aRecAK2) .And. Len(aRecAK2[1]) > 2
				nPos := ASCAN(aRecAK2, {|x| x[3] == cCoAtu+cId })
				If nPos > 0
					If Empty(aRecAK2[nPos, 2])
						//entao faz query para descobrir os recnos do AK2
						//e coloca na posicao 2 do array para utilizar
						//no for...next abaixo que deleta os registros
						cQryRecAK2 := ""
						cQryRecAK2 += " SELECT R_E_C_N_O_ FROM "
						cQryRecAK2 += RetSqlName("AK2")
						cQryRecAK2 += " WHERE "
						cQryRecAK2 += " AK2_FILIAL  = '"+xFilial("AK2")+"'"
						cQryRecAK2 += " AND AK2_ORCAME  = '"+AK1->AK1_CODIGO+"'"
						cQryRecAK2 += " AND AK2_VERSAO  = '"+cVersao+"'"
						cQryRecAK2 += " AND AK2_CO = '"+PadR(cCoAtu, Len(AK2->AK2_CO))+"'"
						cQryRecAK2 += " AND AK2_ID = '"+PadR(cId, Len(AK2->AK2_ID))+"'"
						cQryRecAK2 += " AND D_E_L_E_T_ = ' ' "
						cQryRecAK2	:= ChangeQuery(cQryRecAK2)

						dbUseArea( .T., "TOPCONN", TcGenQry(,,cQryRecAK2), "QRYAUX", .T., .T. )

						dbSelectArea("QRYAUX")
						dbGoTop()
						While ! Eof()
							aAdd(aRecAK2[nPos, 2], QRYAUX->R_E_C_N_O_)
							dbSkip()
						EndDO
						dbSelectArea("QRYAUX")
						dbCloseArea()
	                EndIf
				EndIf
            EndIf

			For nX := 1 TO Len(aRecAK2[nPos][2])
				AK2->(dbGoto(aRecAK2[nPos][2][nX]))
				If lSimulac
					PcoDetLan("000252","03","PCOA100",.T.)
				ElseIf lRevisao
					PcoDetLan("000252","02","PCOA100",.T.)
				Else
					PcoDetLan("000252","01","PCOA100",.T.)
				EndIf
				RecLock("AK2",.F.,.T.)
				dbDelete()
				MsUnlock()
				UnLockbyName(AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+AK2->AK2_ID)
				If (nPosLock := Ascan(aLocksAK2,{|x| x==AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+AK2->AK2_ID })) > 0
					aDel(aLocksAK2,nPosLock)
					aSize(aLocksAK2,Len(aLocksAK2)-1)
				Endif
			Next

		EndIf

	Else
		If !oGD:aCols[nLine][Len(oGD:aCols[nLine])] // Não gravar linha deletada
			aAdd(aLinIncl, aClone(oGD:aCols[nLine]))
			aAdd(aLinRecn, StrZero(nLine, 5))
			For nColuna := 1 TO nLenHeader
			//campo de formula para o periodo
				If (nPosForm := Ascan(aFormula, {|aVal|aVal[1]==nLine .And. ;
								aVal[2]==Alltrim(oGD:aHeader[nColuna][1])})) >  0
					aAdd(aFormIncl, { Len(aLinIncl), oGD:aHeader[nColuna][1], aFormula[nPosForm][3]})
				EndIf
			Next // nColuna --- inclusao de novos registros
		EndIF
	EndIf

Next  nLine

//grava as inclusoes de itens orcamentarios
For nLine := 1 TO Len(oGD:aCols)
    cItemAK2 := ""
	cId	:= oGD:aCols[nLine][nHeadItem]
	
	If !oGD:aCols[nLine][Len(oGD:aCols[nLine])] .And. ; // se nao excluido 
		cId == Padr("*", Len(AK2->AK2_ID))

		If ( nLineAux := aScan(aLinRecn, StrZero(nLine, 5)) ) > 0

			For nColuna := 1 to nLenHeader
				If AllTrim(oGD:aHeader[nColuna][2]) == "AK2_VAL"

					RecLock("AK2",.T.)

					//imprime os campos de acordo aheader da getdados
					For nCpoMore := 1 To nLenHeader
						If ( oGD:aHeader[nCpoMore][10] != "V" ) .And. AllTrim(oGD:aHeader[nCpoMore][2]) != "AK2_VAL"
							AK2->(FieldPut(FieldPos(oGD:aHeader[nCpoMore][2]),aLinIncl[nLineAux][nCpoMore]))
						EndIf
					Next nCpoMore

					//campos fixos
					For nY := 1 TO Len(aFixos)
						If (nPosFix := FieldPos(aFixos[nY][1])) > 0
							AK2->(FieldPut(nPosFix,aFixos[nY][2]))
						EndIf
					Next

					//campos ref. planilha/valor/periodo
					AK2->AK2_FILIAL	:= xFilial("AK2")
					AK2->AK2_ORCAME	:= AK1->AK1_CODIGO
					AK2->AK2_VERSAO	:= cVersao
					AK2->AK2_ID       := If(Empty(cItemAK2), (cItemAK2 := PcoAK2NextID()), cItemAK2)
					AK2->AK2_PERIOD	:= CTOD(Substr(oGD:aHeader[nColuna][1],1,10))
					AK2->AK2_VALOR		:= PcoPlanVal(aLinIncl[nLineAux][nColuna],AK2->AK2_CLASSE)
					AK2->AK2_DATAI		:= CTOD(Substr(oGD:aHeader[nColuna][1],1,10))
					AK2->AK2_DATAF		:= CTOD(Substr(oGD:aHeader[nColuna][1],14,16))

					//campo de formula para o periodo
					If (nPosForm := Ascan(aFormIncl, {|aVal|aVal[1]==nLineAux .And. ;
							aVal[2]==Alltrim(oGD:aHeader[nColuna][1])})) >  0
						AK2->AK2_FORMUL := aFormIncl[nPosForm][3]
					EndIf

					MsUnlock()

					If lSimulac
						PcoDetLan("000252","03","PCOA100")
					ElseIf lRevisao
						PcoDetLan("000252","02","PCOA100")
					Else
						PcoDetLan("000252","01","PCOA100")
					EndIf

				EndIf

			Next nColuna
		EndIf
    EndIf

Next

End Transaction

//desabilitar botoes e grade de edicao
IncProc()
PcoDesabBtn(oGd)

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Form_Edit(oGd)
Local lEdtForm := .F.
Local aAuxHeader := aClone(oGd[1]:aHeader)
lEdtForm:=oGd[1]:aCols[oGd[1]:nAt][COL_EDIT]==BMP_CHK
If !lEdtForm
	lEdtForm:=oGd[1]:aCols[oGd[1]:nAt][COL_EDIT]==BMP_INCL
	If !lEdtForm
		lEdtForm:=oGd[1]:aCols[oGd[1]:nAt][COL_EDIT]==BMP_BRANCO
	EndIf
EndIf
Return(lEdtForm)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoAK2NextID()
Local nItAK2 := 0
Local cItAK2
Local aArea := AK2->(GetArea())
Local aAreaAK3 := AK3->(GetArea())
Local nRecAK2 := AK2->(Recno())

dbSelectArea("AK3")
dbSetOrder(1)
dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+AK2->AK2_CO)

dbSelectArea("AK2")
dbSetOrder(5)
If dbSeek(xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+AK3->AK3_CO)
	While AK2->(!Eof().And.AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO == ;
					xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+AK3->AK3_CO)
		If nRecAK2 != AK2->(Recno())
			nItAK2 := VAL(AK2->AK2_ID)
		EndIf
		AK2->(dbSkip())
	End
EndIf

nItAK2++
cItAK2 := StrZero(nItAK2, Len(AK2->AK2_ID))

RestArea(aAreaAK3)
RestArea(aArea)
dbSelectArea("AK2")

Return(cItAK2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoDesabBtn(oGd)

oGD:lInsert := .F.
oGD:lUpdate := .F.
oGD:lDelete := .F.
oCopia:bWhen := {||.F.}
oCola:bWhen := {||.F.}
oMarca:bWhen := {||.F.}
oEdit:bWhen := {||.F.}
oWrite:bWhen := {||.F.}
oFormula:bWhen := {||.F.}
oFormZe:SetFocus()
oFormula:refresh()
oGd:oBrowse:refresh()
oGd:oBrowse:SetFocus()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoHabFiltro(oGd)
Local nPosDescCO := aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_DESCCO"})
Local nPosCO 		:= aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_CO"})

oCancela:bWhen := {||.F.}
oAtua_Acols:bWhen := {||.T.}
//joga foco para outro objeto para provocar refresh de tela
oFormZe1:SetFocus()
oGd[2]:lUpdate := .T.
oGd[2]:Show()
oGd[2]:oBrowse:SetFocus()

If nPosDescCO > 0
	oGd[2]:aCols[oGd[2]:nAt][nPosDescCO] := Space(oGD[2]:aHeader[nPosDescCO,4])
EndIf

If nPosCO > 0
	oGd[2]:aCols[oGd[2]:nAt][nPosCO] := Space(oGD[2]:aHeader[nPosCO,4])
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAbandEdt(oGd, lFullPlan, lVisual,cRevisa)
Local lRet := .T.
Local nPosId		:=	0
Local nHeadCtaOrc	:= 0
Local nX
Local cCo	:=	''
Local cCoAtu:=	''
DEFAULT lFullPlan := .F.
DEFAULT lVisual   := .F.

If !lFullPlan
	If Eval(oCancela:bWhen)
	 	If Aviso(STR0022, STR0067+If(lVisual, STR0068, STR0069)+STR0070, {STR0024,STR0025},2)==1 //"Atencao"###"Abandonar "###"visualizacao"###"edicao"###" dos itens orcamentarios da grade ?"###"Sim"###"Nao"
			//nao tirar desta posicao por causa do bgotfocus()
			oCancela:bWhen := {||.F.}
			oCancela:refresh()
			PcoDesabBtn(oGd[1])
			PcoHabFiltro(oGd)
			AK3->(DbSetOrder(1))
			nPosId		:=	 aScan( oGD[1]:aHeader, {|x|AllTrim(x[2])=="AK2_ID"})	// Posicao da Classe Orcamentaria no aCols
			nHeadCtaOrc	:= aScan(  oGD[1]:aHeader,{|x| AllTrim(x[2])=="AK2_CO"})
			If nHeadCtaOrc == 0
				nHeadCtaOrc	:= aScan(oGd[2]:aHeader,{|x| AllTrim(x[2])=="XK2_CO"})
				cCo	:=	oGD[2]:Acols[1, nHeadCtaOrc]  //acols da grade de filtro soh tem 1 linha
				If ! Empty(cCo)
					AK3->(MsSeek(xFilial()+AK1->AK1_CODIGO+cRevisa+cCo))
				Else
					lRet := .F.
				EndIf
			Endif
			If lRet
				For nX:=1 To Len(oGD[1]:aCols)
					If Empty(cCo)
						cCoAtu := oGD[1]:aCols[nX][nHeadCtaOrc]
						AK3->(MsSeek(xFilial()+AK1->AK1_CODIGO+cRevisa+cCoAtu))
					Endif
					PcoUnLockAK2(AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+oGD[1]:aCols[nX][nPosID]  )
				Next
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
Else
	If Eval(oWrite:bWhen)
		If Aviso(STR0022, STR0023, {STR0024,STR0025}, 2) == 2 //"Atencao"###"Nao foi gravado as alteracoes apos edicao. Abandona sem gravar ? "###"Sim"###"Nao"
			lRet := .F.
		Else
			AK3->(DbSetOrder(1))
			AK3->(MsSeek(xFilial()+AK1->AK1_CODIGO+cRevisa+cCo))
			For nX:=1 To Len(aLocksAK2)
				UnLockbyName(aLocksAK2[nX])
			Next
			aLocksAK2	:=	{}
		EndIf
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoEditCell(lEditCol)
Local cClasse
Local nPosClasse := aScan(oGD[1]:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})
Local nPosId 		:= aScan(oGD[1]:aHeader,{|x| AllTrim(x[2]) == "AK2_ID"})
Local cId 			:= ""

aHeader := oGD[1]:aHeader
aCols := oGD[1]:aCols
n := oGD[1]:nAt

cId := oGD[1]:aCols[n, nPosId]

If nMvPar != 4 .Or. nPosClasse > 0
	cClasse	:= oGD[1]:aCols[oGD[1]:nAt][nPosClasse]
Else
	cClasse := M->AK2_CLASSE
EndIf

If oGD[1]:lNewLine .And. Empty(cId) .And. ! Empty(cClasse)
	PcoPlanCl()
EndIf

If lEditCol
	oGd[1]:EditCell()
	If !oGD[1]:lNewLine .And. !Empty(cId) .And. Alltrim(oGD[1]:aCols[n][COL_EDIT]) == BMP_CHK
		oGD[1]:aCols[n][nPosId] := cId  //forca gravar o item qdo altera - qdo alterava algum campo ele colocava * no item 
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoDetalhes(cError,cTitle)
Local oFont
Local oDlg
Local cMask    := STR0071 //"Arquivos Texto (*.TXT) |*.txt|"

DEFAULT cTitle := STR0072 //" - Detalhes"

DEFINE FONT oFont NAME "Verdana" SIZE 0, -11
//DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15
DEFINE MSDIALOG oDlg TITLE cCadastro + cTitle From 3,0 to 340,417 PIXEL
@ 5,5 GET oMemo  VAR cError MEMO SIZE 200,145 OF oDlg PIXEL
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont

DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cError))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."

ACTIVATE MSDIALOG oDlg CENTER


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoDispBox ³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra conteudo de aInfo em tabela html                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoDispBox(aInfo,nCols,cText,aCols,cBackColor,nStyle,cClrLegend,cClrData,oDlg,nColIni,nLinIni,lAllClient,cDescri,cTextSay)

Local cColorSay     := CLR_BLACK
Local lCriaDlg		:= (oDlg==Nil)
Local nDlgX			:= 4
Local aArea			:= GetArea()
Local nDlgY         := If(Len(aInfo)>2,(Len(aInfo)*12)+6,45)
Local nX            := 0
Local nY            := 0
Local oSay, cSay, oPanel
Local aColorSay, aBackColor, aClrLegend, aClrData, nLinSay
Local nPixelsW	:= 0
Local aoSay := {}

DEFAULT cBackColor	:= CLR_WHITE
DEFAULT nStyle		:= 1
DEFAULT cClrLegend	:= RGB(190,190,200)
DEFAULT cClrData	:= RGB(200,200,200)
DEFAULT nColIni		:= 0
DEFAULT nLinIni		:= 0
DEFAULT lAllClient	:= .F.
DEFAULT cDescri		:= ""

aBackColor := ConvRGB(cBackColor)
cBackColor := ""
aEval(aBackColor, {|x|cBackColor+=Dec2Hex(x)})

aClrLegend := ConvRGB(cClrLegend)
cClrLegend := ""
aEval(aClrLegend, {|x|cClrLegend+=Dec2Hex(x)})

aClrData := ConvRGB(cClrData)
cClrData := ""
aEval(aClrData, {|x|cClrData+=Dec2Hex(x)})

For nx := 1 to Len(aCols)
	nDlgX += aCols[nx]
Next

If lCriaDlg
	DEFINE MSDIALOG oDlg TITLE cText OF oMainWnd PIXEL FROM 0,0 TO MAX(MIN(nDlgY*2,460),130),MIN(nDlgX*2,670) //STYLE nOR(WS_VISIBLE,WS_POPUP)
EndIf

DEFINE FONT oFont NAME "Arial" SIZE 0, -10

oPanel := TScrollBox():New( oDlg, nColIni,nLinIni,MIN(nDlgY,230),MIN(nDlgX+2,338))
If lAllClient
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
EndIf
nLin := 5
nCol := 3
If !Empty(cDescri)
    cTextSay := "{||' "+STRTRAN(cDescri,"'",'"')+" '}"
	oSay := TSay():New( 2,nCol, MontaBlock(cTextSay) , oPanel, ,oFont,,,,.T.,cColorSay,,400,15,,,,)
	nLin += 15
EndIf
nLinSay := nLin

aColorSay := ConvRGB(cColorSay)
cColorSay := ""
aEval(aColorSay, {|x|cColorSay+=Dec2Hex(x)})

For nx := 1 to Len(aInfo)

    aAdd(aoSay, TSay():New())

	cSay:='<table cellpadding="2" bgcolor="#'+cClrData+'" cellspacing="1" border="0">'
	cSay += CRLF

	If nX == 1
		cColor := cClrLegend
		cSay+='<tr bgcolor="#'+cColor+'"  ALIGN="center" >'
	Else
		cColor := cClrLegend//cClrData
  		cSay+='<tr  ALIGN="right" >'
 	EndIf

	For ny := 1 to nCols
		Do Case
			Case nStyle == 1
				If ny == 1
					cColor := cClrLegend
				Else
					cColor := cClrData
				EndIf
			Case nStyle == 2
				If nx == 1
					cColor := cClrLegend
				Else
					cColor := cClrData
				EndIf
			Case nStyle == 3
				If nx == 1 .Or. ny == 1
					cColor := cClrLegend
				Else
					cColor := cClrData
				EndIf
		EndCase
		If ValType(aInfo[nx][ny])=="C"
         cTextSay := STRTRAN(aInfo[nx][ny],"'",'"')
			cColorSay := CLR_BLACK
			aColorSay := ConvRGB(cColorSay)
			cColorSay := "" ; aEval(aColorSay, {|x|cColorSay+=Dec2Hex(x)})
		Else
         cTextSay := STRTRAN(aInfo[nx][ny][1],"'",'"')
			cColorSay := aInfo[nx][ny][2]
			aColorSay := ConvRGB(cColorSay)
			cColorSay := "" ; aEval(aColorSay, {|x|cColorSay+=Dec2Hex(x)})
		EndIf
		cTextSay := PadR(Alltrim(cTextSay),Int(aCols[ny]/3))
		If nX == 1
			cSay+='<th valign="top" Width="'+If(nY==1, "250","130")+'">'+StrTran(cTextSay,Space(1),'&nbsp;')+'</TH>'
			nPixelsW	+=	Len(cTextSay)*8
        Else
      	    If nY == 1
				cSay+='<td ALIGN="left" bgcolor="#'+cColor+'" Width="'+If(nY==1, "250","130")+'">'+cTextSay+"</TD>"
			Else
				cSay+='<td Width="130">'+Alltrim(cTextSay)+"</TD>"
			EndIf
        EndIf
		nCol += aCols[ny]
	next ny
	cSay += CRLF
	nLin += 9
	nCol := 3
	cSay+='</table>'

	@ nLin,1 SAY aoSay[nX] VAR "" OF oPanel FONT oFont PIXEL SIZE nPixelsW,2300 HTML
	aoSay[nX]:cCaption := cSay
	aoSay[nX]:cTitle := cSay

Next

If lCriaDlg
	nLin += 20
	@ nLin,20 			BUTTON STR0001 SIZE 35 ,10  ACTION {||oDlg:End()}  OF oPanel PIXEL  //"Fechar"
	@ nLin,(nDlgX)-80 	BUTTON STR0001 SIZE 35 ,10  ACTION {||oDlg:End()}  OF oPanel PIXEL  //"Fechar"
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoDirEnt_User ³ Autor ³ Paulo Carnelossi  ³Data ³ 26/08/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna o direito do Usuario na Entidade do Sistema³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoDirEnt_User(cEntidade, cChave, cUser, lMsgHelp, cPlano, lVerSoDir)
Local nDireito := 0
Local cAlias := Alias()
Local aArea := GetArea()
Local aAreaAL7 := AL7->(GetArea())
Local aAreaAL6 := AL6->(GetArea())
Local nTamanho
Local lFound
Local lExistAL6Plan := .F.
Local cPlanAux := ''

default cPlano := ""
DEFAULT cUser := __cUserID
DEFAULT lMsgHelp := .F.
DEFAULT lVerSoDir := .F.

cEntidade := PADR(Alltrim(cEntidade),LEN(AL7->AL7_ENTIDA))

dbSelectArea("AL6")
dbSetOrder(1)

If FieldPos("AL6_PLANO") > 0
	lExistAL6Plan := .T.
	lFound := MsSeek(xFilial("AL6")+cEntidade)
	cPlanAux := AL6->AL6_PLANO
else
	lFound := MsSeek(xFilial("AL6")+cEntidade)
	cPlanAux := ''
EndIf

If AL6->(!lFound .Or. (lFound .And. AL6_ATIVO == "2" .And.  ;
        (!lExistAL6Plan .or. (lExistAL6Plan .and. (cPlano == '' .or. cPlano == cPlanAux ) ) )   ))
	If lMsgHelp
		Aviso(STR0022, STR0074+cEntidade+STR0076,{"Ok"})//"Entidade - "###" - sem restricao de acesso por usuario."
	EndIf
	nDireito := 3

ElseIf lVerSoDir  // Utilizado para verificar se usuario pode incluir entidade em questao (tratamento especifico)
	dbSelectArea("AL7")
	dbSetOrder(1)
	If cUser=="000000"
  	   	nDireito := 3
	ElseIf MsSeek(xFilial("AL7")+cEntidade+cUser)
		While AL7->(!Eof() .And. AL7_FILIAL+AL7_ENTIDA+AL7_USER==xFilial("AL7")+cEntidade+cUser)
			If Val(AL7->AL7_DIREIT) > nDireito  //retorna o maior direito independente da faixa de..ate
				nDireito := Val(AL7->AL7_DIREIT)
			EndIf
			AL7->(dbSkip())
		EndDo
	EndIf
	
Else
	dbSelectArea("AL7")
	dbSetOrder(1)
	If Empty(cChave)
		If lMsgHelp
			Aviso(STR0022, STR0074+cEntidade+STR0075,{"Ok"})//"Entidade - "###" - Chave de pesquisa não informado."
		EndIf
 	ElseIf cUser=="000000"
  	   	nDireito := 3
	ElseIf MsSeek(xFilial("AL7")+cEntidade+cUser)

		if cPlano != '' .and. cPlano != cPlanAux
			//Fomos informados de que não haverá o vinculo de mais de um plano por AL6_ENTIDA. Entao fixamos!
			//Caso o plano não é o mesmo especificado no cadastro, não temos por que varrer AL7!
		Else

			nTamanho := AL7->AL7_TAMANH
			While AL7->(!Eof() .And. AL7_FILIAL+AL7_ENTIDA+AL7_USER==xFilial("AL7")+cEntidade+cUser)
				If PadL(Alltrim(cChave),nTamanho) >= PadL(AllTrim(AL7->AL7_FX_INI),nTamanho) .And. ;
					PadL(Alltrim(cChave),nTamanho) <= PadL(AllTrim(AL7->AL7_FX_FIN),nTamanho)
					nDireito := Val(AL7->AL7_DIREIT)
 					EXIT
				EndIf
				AL7->(dbSkip())
			End

		EndIf

	EndIf
EndIf

RestArea(aAreaAL6)
RestArea(aAreaAL7)
RestArea(aArea)

If !Empty(cAlias)
	dbSelectArea(cAlias)
Endif

Return(nDireito)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco_ChkEntd(cOrcame,cRevisa,cCO,cCOPai,nCheck, nRecAK3,cAliasAK2)
Local cChvEntida
Local lRet := .F.
Local aRet := {}, lContinua := .T., nY
Local aArea := GetArea()
Local aAreaAK3 := AK3->(GetArea())
Local aAreaAL6
Local aAreaSX2 := SX2->(GetArea())
Local nCpoAux

Default cAliasAK2 := "AK2"

dbSelectArea("SX2")
If !dbSeek("AL6")
	RestArea(aAreaSX2)
	RestArea(aArea)
	Return .T.
EndIf
RestArea(aArea)

aAreaAL6 := AL6->(GetArea())

dbSelectArea("AK3")
dbGoto(nRecAK3)

dbSelectArea("AL6")
dbSetOrder(1)
lRet := ! dbSeek(xFilial("AL6"))  //se nao estiver populado nem entra na validacao

While AL6->(!Eof() .And. AL6_FILIAL == xFilial("AL6"))
	cCpoEntidade := Alltrim(AL6->AL6_CPOITE)
	nCpoAux := (cAliasAK2)->(FieldPos(cCpoEntidade))

	If AL6->AL6_ATIVO=="1" .And. nCpoAux > 0  // Se campo ESTIVER EM USO VALIDA DIR USUARIO

		cChvEntida := (cAliasAK2)->(FieldGet(nCpoAux))

		lRet := PcoEntd__User(cOrcame,cCO,cCOPai,nCheck,cRevisa,AL6->AL6_ENTIDA,cChvEntida,2/*nDireito*/)

		If !lRet
			lContinua := .F.
			Exit
		EndIf
	Else
		lRet := .T. //se campo == NAO USADO
	EndIf
	aAdd(aRet, lRet)

	dbSelectArea("AL6")
	dbSkip()

End

If lContinua .And. !Empty(aRet)
	For nY := 1 TO Len(aRet)
	    If ! aRet[nY]
	    	 lRet := .F.
	    	 Exit
	    Else
			lRet := aRet[nY]
	    EndIf
	Next
EndIf

RestArea(aAreaAL6)
RestArea(aAreaAK3)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaQryAK2 ºAutor  ³Bruno Sobieski    º Data ³  18/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Query para carregar itens orcamentarios                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaQryAK2(cRevisa,cCO,cWhere,cGroupBy,cOrder)
Local cQuery	:=	" SELECT MIN(AK2_ID) AK2_ID "
Local nX			:=	1
Local nY			:=	1
Local aPeriodos	:=	PcoRetPer()
Local aStruct	:=	AK2->(DbStruct())
Local cQryAux   := " SELECT AK2_ID AS AK2_ID "
DEFAULT cGroupBy := "SQ.AK2_ID"
DEFAULT cOrder := "SQ.AK2_ID"

cCmpAK2Min	:=	""
For nX := 1 To Len(aStruct)
	If Alltrim(aStruct[nX,2]) <> "M" .And. Alltrim(aStruct[nX,1]) <> "AK2_ID" .And. Alltrim(aStruct[nX,1]) <> "AK2_FORMUL"
		cCmpAK2Min	+=	" , MIN("+Alltrim(aStruct[nX,1])+") AS "+Alltrim(aStruct[nX,1])
		cQryAux += " , "+Alltrim(aStruct[nX,1])+" AS "+Alltrim(aStruct[nX,1])
	Endif
Next

cQuery	+=	cCmpAK2Min

For nX :=1 To Len(aPeriodos)
	cQuery	+=	",SUM(P"+StrZero(nX,2)+") AS P"+StrZero(nX,2)
Next
cQuery		+=	" FROM ("
For nX :=1 To Len(aPeriodos)
	cQuery	+= cQryAux + " , "          // "(SELECT AK2.*,"
	For nY:=1 To nX-1
		cQuery	+=	"0 AS P"+StrZero(nY,2)+","
	Next
	cQuery	+=	"AK2_VALOR AS P"+StrZero(nX,2)+Iif(nX==Len(aPeriodos),"",",")
	For nY:=nX+1 To Len(aPeriodos)
		cQuery	+=	"0 AS P"+StrZero(nY,2)+Iif(nY==Len(aPeriodos),"",",")
	Next
	cQuery	+=	" FROM "+RetSqlName("AK2") + " AK2"
	cQuery	+=	" WHERE AK2_FILIAL='"+xFilial('AK2')+"' AND AK2_ORCAME='"+AK1->AK1_CODIGO+"'"
	cQuery	+=	" AND AK2_VERSAO='"+ cRevisa +"' "
	If !Empty(cCo)
		cQuery	+=	" AND AK2_CO='"+ cCo +"'"
	ElseIf !Empty(cWhere)
		cQuery	+=	 cWhere
	Endif
	cQuery	+=	" AND AK2_PERIOD='"+ DTOS(CTOD(Substr(aPeriodos[nX],1,10))) +"'"
	cQuery	+=	" AND D_E_L_E_T_=' '"
	cQuery	+=	" UNION "+CRLF
Next
cQuery	:=	Substr(cQuery,1,Len(cQuery)-Len(" UNION "+CRLF))
cQuery	+=	") SQ GROUP BY "+cGroupBy
If cOrder <> Nil
	cQuery	+=	" ORDER BY "+cOrder
Endif

Return cQuery

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoPosAK6(cClasse)
Local lRet	:=	.T.
Local nPos
If AK6->AK6_CODIGO <> cClasse
	If (nPos	:=	Ascan(aClassesSt,{|x| x[1] ==cClasse })) > 0
		AK6->(MsGoTo(aClassesSt[nPos,2]))
	Else
		AK6->(DbSetOrder(1))
		lRet	:=	AK6->(MsSeek(xFilial()+cClasse))
		If lRet
			AAdd(aClassesSt,{cClasse,AK6->(Recno())})
		Endif
	Endif
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pco_Sup_CtaºAutor  ³Paulo Carnelossi    º Data ³ 18/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega no Array aCtas as contas orcamentarias a partir da º±±
±±º          ³ e suas contas superiores na planilha                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco_Sup_Cta(cConta, aCtas, cRevisa)
Local aArea := GetArea()
Local aAreaAK3 := AK3->(GetArea())
DEFAULT aCtas := {}

If !Empty(cConta)
	dbSelectArea("AK3")
	dbSetOrder(1)
	//Tem que estar posicionada na tabela AK1 - Orcamento
	If dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+PadR(cConta, Len(AK3->AK3_CO)))
		aAdd(aCtas, AK3->AK3_CO)
		Pco_Sup_Cta(AK3->AK3_PAI, aCtas, cRevisa)
	EndIf
EndIf

RestArea(aAreaAK3)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOLockAK2 ºAutor  ³Bruno Sobieski      º Data ³  18/09/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para bloquear logicamente item orcamentario a ser    º±±
±±º          ³alterado                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOLockAK2(cChave,lAviso,lViewModify)
Local lRet	:=	.T.
Default lAviso	:=	.T.

If Right(Alltrim(cChave),1) != "*" .And. Ascan(aLocksAK2,{|x| x ==cChave }) == 0
	If !LockByName( cChave, .T.  )
		If lAviso
			Aviso(STR0085, STR0086+CRLF+STR0087, {"Ok"})  //"Registro em uso"###"O registro esta em uso e nao pode ser alterado."###"Tente novamente em alguns instantes."
		Endif
		lRet	:=	.F.
	Else
		aadd(aLocksAK2,cChave)
		lViewModify := .T.
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOUnLockAK2 ºAutor  ³Bruno Sobieski   º Data ³  18/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para tirar o lock logico do item orcamentario        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOUnLockAK2(cChave)
Local nPosLock	:=	0

If (nPosLock := Ascan(aLocksAK2,{|x| x==cChave } )) > 0
	UnLockbyName(cChave)
	aDel(aLocksAK2,nPosLock)
	aSize(aLocksAK2,Len(aLocksAK2)-1)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoModifyAK2 ºAutor ³Paulo Carnelossi  º Data ³  08/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se ocorrerarm alteracoes na linha em edicao por    º±±
±±º          ³outra sessao                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoModifyAK2(cChvLck, oGetDados, nPosId, aColAlt, aColEsp)
Local aArea := GetArea()
Local aHeader := oGetDados:aHeader
Local aColLin := oGetDados:aCols[oGetDados:nAt]
Local cQuery, cFilAK2, cOrcame, cRevisa, cCo, cIdAK2
Local nPosVal, aTabAK2 := {}
Local lMudouaCols := .F.
Local nX, nPosCol, cColGrd,cPeriodo

DEFAULT aColEsp := {}

cFilAK2 := Left(cChvLck,2)
cOrcame := Subs(cChvLck,Len(AK2->(AK2_FILIAL))+1, Len(AK2->AK2_ORCAME))
cRevisa := Subs(cChvLck, Len(AK2->(AK2_FILIAL+AK2_ORCAME))+1, Len(AK2->AK2_VERSAO))
cCo 	:= Subs(cChvLck, Len(AK2->(AK2_FILIAL+AK2_ORCAME+AK2_VERSAO))+1, Len(AK2->AK2_CO))
cIdAK2 	:= Subs(cChvLck, Len(AK2->(AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO))+1, Len(AK2->AK2_ID))

cQuery	:=	" SELECT * FROM "+RetSqlName('AK2')+" AK2 "
cQuery	+=	" WHERE AK2_FILIAL='"+cFilAK2+"' AND AK2_ORCAME='"+cOrcame+"' "
cQuery	+=	" AND AK2_VERSAO='"+ cRevisa +"' AND AK2_CO='"+ cCo +"' "
cQuery	+=	" AND AK2_ID='"+ cIdAK2+"' "
cQuery	+=	" AND D_E_L_E_T_= ' ' "
cQuery	+=	" ORDER BY AK2_PERIOD "
cQuery	:=	ChangeQuery(cQuery)
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRY_AK2", .F., .F. )

While QRY_AK2->(! Eof())

    For nX := 1 TO FCOUNT()
    	If FieldName(nX) == "AK2_VALOR"
    		aAdd( aTabAK2, { AK2_PERIOD, AK2_VALOR })
    	ElseIf Ascan( aTabAK2, { | x | x[1] == FieldName(nX)} ) == 0
    		aAdd( aTabAK2, { FieldName(nX), FieldGet(nX) } )
        EndIf
    Next

	QRY_AK2->(dbSkip())

EndDo

QRY_AK2->(dbCloseArea())

If nMvPar == 4
	If ( nPosCol := Ascan(aColEsp, { |x| AllTrim(x[1]) == "AK2_CLASSE"}) ) > 0
	   	cClasse := aColEsp[nPosCol, 2]
	EndIf
EndIf

lMudouaCols := .F.
For nX := 1 TO Len(aColLin) - 1  //- 1 pq ultima coluna indica se deletado apenas validando todas as colunas da linha atual

	cColGrd := AllTrim(aHeader[nX,2])

    If cColGrd == "AK2_CLASSE"
    	cClasse := aColLin[nX]
    EndIf

	If nX != nPosId
		If cColGrd == "AK2_VAL"
			cPeriodo := DTOS(CTOD(Left(aHeader[nX,1],10)))
			If ( nPosCol := Ascan(aTabAK2, { |x| AllTrim(x[1]) == cPeriodo}) ) > 0
				If aTabAK2[nPosCol,2] != PcoPlanVal(aColLin[nX], cClasse)
					lMudouaCols := .T.
				EndIf
			EndIf
		Else
			If ( nPosCol := Ascan(aTabAK2, { |x| Alltrim(x[1]) == cColGrd}) ) > 0
				If aTabAK2[nPosCol,2] != aColLin[nX]
					lMudouaCols := .T.
				EndIf
			EndIf
		EndIf
    EndIf

Next

If lMudouaCols
	aColAlt := aClone(aTabAK2)
EndIf

RestArea(aArea)

Return(lMudouaCols)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pco_Alt_Lin_GetDadosºAutor³Paulo Carnelossi º Data ³08/10/07º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega linha da getdados com conteudo do array aColAlt     º±±
±±º          ³qdo ha mudanca dos dados em outra sessao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Pco_Alt_Lin_GetDados(oGetDados,nPosId,aColAlt,aColEsp)
Local aArea := GetArea()
Local aHeader := oGetDados:aHeader
Local nX
Local nLinAt  := oGetDados:nAt
Local aColLin := oGetDados:aCols[nLinAt]
Local cColGrd
Local nPosCol
Local cPeriodo
Local aAuxArea
Local cClasse, nPosClasse
Local cChaveIdent, nPosChaveIdent

DEFAULT aColEsp := {}

If nMvPar != 4

	nPosClasse := aScan(aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})

	If ( nPosCol := Ascan(aColAlt, { |x| Alltrim(x[1]) == "AK2_CLASSE"}) ) > 0
		If aColAlt[nPosCol,2] != aColLin[nPosClasse]
			cClasse := aColAlt[nPosCol,2]
		Else
			cClasse := aColLin[nPosClasse]
		EndIf
	Else
		Alert(STR0088)  //"Codigo da Classe Orcamentaria nao encontrada. Verifique!"
		Return
	EndIf

Else

	nPosClasse := aScan(aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})

	If nPosClasse >  0

		If ( nPosCol := Ascan(aColAlt, { |x| Alltrim(x[1]) == "AK2_CLASSE"}) ) > 0
			If aColAlt[nPosCol,2] != aColLin[nPosClasse]
				cClasse := aColAlt[nPosCol,2]
			Else
				cClasse := aColLin[nPosClasse]
			EndIf
		Else
			Alert(STR0088) //"Codigo da Classe Orcamentaria nao encontrada. Verifique!"
			Return
		EndIf

	Else

		If ( nPosCol := Ascan(aColEsp, { |x| AllTrim(x[1]) == "AK2_CLASSE"}) ) > 0
		   	cClasse := aColEsp[nPosCol, 2]
		EndIf

	EndIf

EndIf

nPosChaveIdent := aScan(aHeader,{|x| AllTrim(x[2]) == "AK2_CHAVE"})

If ( nPosCol := Ascan(aColAlt, { |x| Alltrim(x[1]) == "AK2_CHAVE"}) ) > 0
	If aColAlt[nPosCol,2] != aColLin[nPosChaveIdent]
		cChaveIdent := aColAlt[nPosCol,2]
	Else
		cChaveIdent := aColLin[nPosChaveIdent]
	EndIf
Else
	Alert(STR0089)  //"Chave da entidade referenciada na Classe Orcamentaria nao encontrada. Verifique!"
	Return
EndIf

For nX := 1 TO Len(aHeader)

	cColGrd := Alltrim(aHeader[nX, 2])

	If cColGrd == "AK2_ID"
		Loop
	EndIf

	If 		cColGrd == "AK2_CLASSE"
		oGetDados:aCols[nLinAt, nX] := cClasse

	ElseIf 	cColGrd == "AK2_VAL"
		cPeriodo := DTOS(CTOD(Left(aHeader[nX,1],10)))
		If ( nPosCol := Ascan(aColAlt, { |x| AllTrim(x[1]) == cPeriodo}) ) > 0
			If aColAlt[nPosCol,2] != PcoPlanVal(aColLin[nX], cClasse)
				oGetDados:aCols[nLinAt, nX] := PcoPlanCel(aColAlt[nPosCol,2], cClasse)
			EndIf
		EndIf

	ElseIf 	cColGrd == "AK2_IDENT"
		If !Empty(	cChaveIdent )
			aAuxArea := GetArea()
			PcoPosAK6( cClasse )
			If !Empty(AK6->AK6_VISUAL)
				dbSelectArea(Substr(cChaveIdent,1,3))
				dbSetOrder(If(!Empty(Substr(cChaveIdent,4,2)), Val(Substr(	cChaveIdent,4,2)), 1))
				dbSeek(Substr(cChaveIdent,6,Len(AK2->AK2_CHAVE)))
				oGetDados:aCols[nLinAt,nX] := &(AK6->AK6_VISUAL)
			EndIf
			RestArea(aAuxArea)
		EndIf

	ElseIf 	cColGrd == "AK2_DESCLA"
		aAuxArea := GetArea()
		If PcoPosAK6( cClasse )
			oGetDados:aCols[nLinAt,nX] := AK6->AK6_DESCRI
		EndIf
		RestArea(aAuxArea)

	ElseIf 	cColGrd == "AK2_UM"
		aAuxArea := GetArea()
		PcoPosAK6( cClasse)
		If !Empty(AK6->AK6_UM)
			If !Empty(	cChaveIdent )
				dbSelectArea(Substr(cChaveIdent,1,3))
				dbSetOrder(Val(Substr(cChaveIdent,4,2)))
				MsSeek(Substr(cChaveIdent,6,Len(AK2->AK2_CHAVE)))
			EndIf
			oGetDados:aCols[nLinAt,nX] := &(AK6->AK6_UM)
		EndIf
		RestArea(aAuxArea)

	Else
		If ( nPosCol := Ascan(aColAlt, { |x| AllTrim(x[1]) == cColGrd}) ) > 0
			If aColAlt[nPosCol,2] != aColLin[nX]
				oGetDados:aCols[nLinAt, nX] := aColAlt[nPosCol,2]
			EndIf
		EndIf

	EndIf

Next

oGetDados:oBrowse:refresh()
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoCposEspºAutor  ³Paulo Carnelossi    º Data ³  08/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega array aColEsp com os campos digitados no filtro     º±±
±±º          ³na interface tipo 4-Espec.Campos                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoCposEsp(aColEsp, oGetDados)
Local nX
Local nPosCol
Local aHeader := oGetDados:aHeader
Local aCampos := {}
Local nQtd

aCampos := {	"XK2_CO", ;
				"XK2_CLASSE", ;
				"XK2_OPER", ;
				"XK2_CC", ;
				"XK2_ITCTB", ;
				"XK2_CLVLR", ;
				"XK2_UNIORC" }

// Verifica a quantidade de entidades contabeis
If nQtdEntid == NIL
	If cPaisLoc == "RUS"
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
	Else
	nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf

//Se houver novas entidades
If nQtdEntid > 4
	For nQtd := 5 To nQtdEntid
		cEnt := "XK2_ENT"+STRZERO(nQtd,2)

		aAdd(aCampos, cEnt)
	Next
EndIf

For nX := 1 TO Len(aCampos)
	If ( nPosCol := Ascan(aHeader, { |x| AllTrim(x[2]) == aCampos[nX]}) ) > 0 .And. ;
		! Empty( oGetDados:aCols[1, nPosCol ] )
		aAdd(aColEsp, { StrTran(aCampos[nX], "XK2_", "AK2_"), oGetDados:aCols[1, nPosCol ] } )
	EndIf
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCOBlqRMes ºAutor ³ Gustavo Henrique  º Data ³  08/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se deve bloquear a revisao do orcamento do mes    º±±
±±º          ³ posicionado na planilha.                                   º±±
±±º          ³ Caso seja permitido revisar, o sistema apresenta uma       º±±
±±º          ³ mensagem de aviso.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPO1 - Objeto da MSGetDados utilizado para revisao dos    º±±
±±º          ³         itens da C.O. posicionada.                         º±±
±±º          ³ EXPC2 - Codigo da versao da planilha orcamentaria atual.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Planejamento e Controle Orcamentario                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOBlqRMes( oGD, cRevisa )

Local aAreaAKE	:= AKE->(GetArea())
Local lRet		:= .T.
Local cBlqRMes  := SuperGetMV( "MV_PCOBLRM", .F., "0" )
Local cDataPos	:= ""

If lRevisao
	If cBlqRMes == "1"	// Bloqueia revisao de orcamento anterior ao mes de inicio da revisao
		AKE->( dbSetOrder(1) )
		AKE->( MsSeek( xFilial("AKE") + AK1->AK1_CODIGO + cRevisa ) )
		cDataPos := DtoS(CtoD(SubStr(oGD:aHeader[oGD:oBrowse:nColPos,1],1,10)))
		lRet := Left(cDataPos,6) >= Left(DtoS(AKE->AKE_DATAI),6)
		If !lRet
			// Atenção ### Período inválido. É permitido revisar apenas os períodos subsequentes à data de início da revisão.
			Aviso( STR0026, STR0094,{"Ok"})
		EndIf
	EndIf
EndIf

RestArea( aAreaAKE )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoGeraSup  ºAutor  ³Paulo Carnelossi    º Data ³ 13/06/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que popula tabela temporaria no banco com conteudo   º±±
±±º          ³CAMPOS - ANALITICA || SUPERIOR                              º±±
±±º          ³Padrao para as entidades 	AK5-Contas Orcamentarias          º±±
±±º          ³							CTT - Centros de Custos           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA300                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoGeraSup(cCodCubo, aTmpDim)
Local aArea := GetArea()
Local aAreaAKW := AKW->(GetArea())
Local aArqTrb := {}
Local cArqTrb
Local nPosVet
Local cNomeProc
Local cPlano
Local nPos := 0
DEFAULT cCodCubo := AL1->AL1_CONFIG
DEFAULT aTmpDim  := {}

dbSelectArea("AKW")
dbSetOrder(1)

If dbSeek(xFilial("AKW")+cCodCubo)
	While AKW->(! Eof() .And. AKW_COD == cCodCubo)

		If ! Empty(AKW->AKW_ATUSIN)
			If Alltrim(AKW->AKW_ALIAS) != 'CV0'  // AK5, CTT. CTD, CTH
				If (nPosVet := Ascan(aTmpDim, {|x| x[1] == Alltrim(AKW->AKW_ALIAS)})) == 0
					cArqTrb := _Pco_AK5PopSup(@cNomeProc, Alltrim(AKW->AKW_ALIAS), cPlano)
					aAdd(aArqTrb, { Alltrim(AKW->AKW_ALIAS), cArqTrb, cNomeProc, AKW->AKW_NIVEL  })
					aAdd(aTmpDim, { Alltrim(AKW->AKW_ALIAS), cArqTrb, cNomeProc, AKW->AKW_NIVEL  })
				Else
					aAdd(aArqTrb, { aTmpDim[nPosVet, 1], aTmpDim[nPosVet, 2], aTmpDim[nPosVet, 3], AKW->AKW_NIVEL })
				EndIf
			Else    // ENT05, ENT06, ENT07, ENT08,ENT09
				//POSICIONAR NA CTO NA ENTIDADE QUE VAI GERAR SUPERIOR
				nPos := AT("AKD_ENT",AKW->AKW_CHAVER)  //AKW->AKW_CHAVER -> AKD->AKD_ENT06
				cPlano := Substring(AKW->AKW_CHAVER, nPos + 7, 2 )  // 06
				cEnt   := "E"+cPlano  //E06
				If (nPosVet := Ascan(aTmpDim, {|x| x[1] == cEnt})) == 0
					cArqTrb := _Pco_AK5PopSup(@cNomeProc, Alltrim(AKW->AKW_ALIAS), cPlano)
					aAdd(aArqTrb, { cEnt, cArqTrb, cNomeProc, AKW->AKW_NIVEL })
					aAdd(aTmpDim, { cEnt, cArqTrb, cNomeProc, AKW->AKW_NIVEL })
				Else
					aAdd(aArqTrb, { aTmpDim[nPosVet, 1], aTmpDim[nPosVet, 2], aTmpDim[nPosVet, 3], AKW->AKW_NIVEL })
				EndIf
			EndIf
		EndIf
		AKW->(dbSkip())
	EndDo
EndIf

//aqui pode ser colocado um ponto de entrada para usuario colocar tabelas de usuarios com hierarquia
RestArea(aArea)
RestArea(aAreaAKW)

Return(aArqTrb)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pco_AK5PopSup ºAutor  ³Paulo Carnelossi  º Data ³ 13/06/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que popula tabela temporaria no banco com conteudo   º±±
±±º          ³CAMPOS - ANALITICA || SUPERIOR                              º±±
±±º          ³Padrao para as entidades 	AK5 - Contas Orcamentarias      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA300                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _Pco_AK5PopSup(cNomeProc, cAliasAKW, cPlano)
Local nOrdem
Local bSeek
Local bWhile
Local bAtual
Local bSuperior
Local bCondRecursiv
Local bLeftWhile
Local bCond
Local bExecute 		:= {|x,y| Pco_InsereTabela(x,y) }
Local lProc         := .T.
Local aResult 		:= {}
Local aStruct 		:= {}
Local cIndTmp 		:= "ANALITICA+SUPERIOR"
Local aSup          := {}

Private cArquivo

If cAliasAKW == "AK5"
	nOrdem        := 1
	bSeek         := {|| dbSeek(xFilial()) }
	bWhile        := {|| AK5_FILIAL == xFilial() }
	bAtual        := {|| AK5_CODIGO }
	bSuperior     := {|| AK5_COSUP }
	bCondRecursiv := {|| ! Empty(AK5_COSUP) }
	bLeftWhile    := {|| AK5_FILIAL+AK5_CODIGO }
	bCond         := {|| AK5_TIPO == "2" }
ElseIf cAliasAKW == "CTT"
	nOrdem 		  := 1
	bSeek 		  := {|| dbSeek(xFilial()) }
	bWhile        := {|| CTT_FILIAL == xFilial() }
	bAtual 		  := {|| CTT_CUSTO }
	bSuperior 	  := {|| CTT_CCSUP }
	bCondRecursiv := {|| ! Empty(CTT_CCSUP) }
	bLeftWhile 	  := {|| CTT_FILIAL+CTT_CUSTO }
	bCond 		  := {|| CTT_CLASSE == "2" }
ElseIf cAliasAKW == "CTD"
	nOrdem 		  := 1
	bSeek 		  := {|| dbSeek(xFilial()) }
	bWhile        := {|| CTD_FILIAL == xFilial() }
	bAtual 		  := {|| CTD_ITEM }
	bSuperior 	  := {|| CTD_ITSUP }
	bCondRecursiv := {|| ! Empty(CTD_ITSUP) }
	bLeftWhile 	  := {|| CTD_FILIAL+CTD_ITEM }
	bCond 		  := {|| CTD_CLASSE == "2" }
ElseIf cAliasAKW == "CTH"
	nOrdem 		  := 1
	bSeek 		  := {|| dbSeek(xFilial()) }
	bWhile        := {|| CTH_FILIAL == xFilial() }
	bAtual 		  := {|| CTH_CLVL }
	bSuperior 	  := {|| CTH_CLSUP }
	bCondRecursiv := {|| ! Empty(CTH_CLSUP) }
	bLeftWhile 	  := {|| CTH_FILIAL+CTH_CLVL }
	bCond 		  := {|| CTH_CLASSE == "2" }
ElseIf cAliasAKW == "CV0"
	//POSICIONAR NA CTO NA ENTIDADE QUE VAI GERAR SUPERIOR
	dbSelectArea("CT0")
	dbSetOrder(1)
	dbSeek(xFilial()+cPlano)
	nOrdem := 1
	bSeek := {|| dbSeek(xFilial()+CT0->CT0_ENTIDA) }
	bWhile := {|| CV0_FILIAL == xFilial() .And. CV0_PLANO == CT0->CT0_ENTIDA }
	bAtual := {|| CV0_CODIGO }
	bSuperior := {|| CV0_ENTSUP }
	bCondRecursiv := {|| ! Empty(CV0_ENTSUP) }
	bLeftWhile := {|| CV0_FILIAL+CV0_PLANO+CV0_CODIGO }
	bCond := {|| CV0_CLASSE == "2" }
EndIf
//acaba definicao da estrutura do temporario
aAdd(aStruct,{"ANALITICA"	,	"C", Len( (cAliasAKW)->(Eval(bAtual)) ), 00})
aAdd(aStruct,{"SUPERIOR"	,	"C", Len( (cAliasAKW)->(Eval(bSuperior)) ), 00})
// Cria a tabela temporia direto no banco de dados
cArquivo := CriaTrab( , .F.)
MsErase(cArquivo)
MsCreate(cArquivo,aStruct, "TOPCONN")
Sleep(500)

dbUseArea(.T., "TOPCONN",cArquivo,cArquivo/*cAlias*/,.T.,.F.)
// Cria o indice temporario
IndRegua(cArquivo/*cAlias*/,cArquivo,cIndTmp,,)
If lProc
	/* -------------------------------------------------------------------------
	  Cria e instala as procedures dinâmicas para gerar niveis superiores
	   para as entidades utilizadas CT1, CTT, CTD, CTH, ENT05, ENT06,..,ENT09
	   ------------------------------------------------------------------------- */
	aSup := GeraSupProc( cArquivo, cAliasAKW, cPlano )
	If aSup[1]  // Se procedure criada com sucesso
		cNomeProc:= aSup[2]
        //executar a procedure
		aResult := TCSPExec( xProcedures(StrTran(cNomeProc, "_"+cEmpAnt,"" )), xFilial(cAliasAKW))
		If Empty(aResult) .Or. Empty(aResult[1]) .Or. aResult[1] = "0"
			MsgAlert(STR0106)  //"Erro na Execucao da Procedure."
			lProc := .f.
		EndIf
	Else
		lProc := .f.
   	Endif
EndIf
If !lProc
	Pco_PrimSup(cAliasAKW, nOrdem, bSeek, bWhile, bCond, bAtual, bSuperior, bLeftWhile, bCondRecursiv, bExecute, cPlano )
EndIf

dbSelectArea(cArquivo)
dbCloseArea()
Return(cArquivo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pco_InsereTabela ºAutor ³Paulo Carnelossi º Data ³ 13/06/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que popula tabela temporaria no banco com conteudo   º±±
±±º          ³CAMPOS - ANALITICA || SUPERIOR                              º±±
±±º          ³Padrao para as entidades                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA300                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±5±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco_InsereTabela(cAtual, cSuperior)
Local aArea := GetArea()

dbSelectArea(cArquivo)

RecLock(cArquivo, .T.)
(cArquivo)->ANALITICA := cAtual
(cArquivo)->SUPERIOR := cSuperior
MsUnLock()

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pco_PrimSup  ºAutor  ³Paulo Carnelossi   º Data ³ 13/06/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que popula tabela temporaria no banco com conteudo   º±±
±±º          ³CAMPOS - ANALITICA || SUPERIOR                              º±±
±±º          ³Padrao para as entidades   ROTINA INICIAL                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA300                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco_PrimSup(cAlias, nOrdem, bSeek, bWhile, bCond, bAtual, bSuperior, bLeftWhile, bCondRecursiv, bExecute, cPlano )

dbSelectArea(cAlias)
dbSetOrder(nOrdem)

Eval(bSeek)

While (cAlias)->( ! Eof() .And. Eval(bWhile) )

	If (cAlias)->(Eval(bCond))
		Pco_Superiores( cAlias, nOrdem, Eval(bAtual), Eval(bSuperior), bSuperior, bLeftWhile, bCondRecursiv, bExecute, cPlano)
	EndIf

	dbSelectArea(cAlias)
	dbSkip()
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pco_PrimSup  ºAutor  ³Paulo Carnelossi   º Data ³ 13/06/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que popula tabela temporaria no banco com conteudo   º±±
±±º          ³CAMPOS - ANALITICA || SUPERIOR                              º±±
±±º          ³Padrao para as entidades                                    º±±
±±º          ³Recursiva para chegar ao topo da entidade superior          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA300                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco_Superiores( cAlias, nOrdem, cAtual, cSuperior, bSuperior, bLeftWhile, bCondRecursiv, bExecute, cPlano)
Local aArea := GetArea()

dbSelectArea(cAlias)
dbSetOrder(nOrdem)

If cAlias == 'CV0'
	MsSeek(xFilial()+cPlano+cSuperior)
	While (cAlias)->( ! Eof() .And. Alltrim(Eval(bLeftWhile)) == Alltrim(xFilial()+cPlano+cSuperior) )

		Eval(bExecute, cAtual, cSuperior)

		If Eval(bCondRecursiv)
			Pco_Superiores( cAlias, nOrdem, cAtual, Eval(bSuperior), bSuperior, bLeftWhile, bCondRecursiv, bExecute, cPlano)
		Else
			Exit  //chegou ao topo
		EndIf

		dbSelectArea(cAlias)
		dbSkip()

	EndDo
Else
	MsSeek(xFilial()+cSuperior)

	While (cAlias)->( ! Eof() .And. Eval(bLeftWhile) == xFilial()+cSuperior )

		Eval(bExecute, cAtual, cSuperior)

		If Eval(bCondRecursiv)
			Pco_Superiores( cAlias, nOrdem, cAtual, Eval(bSuperior), bSuperior, bLeftWhile, bCondRecursiv, bExecute)
		Else
			Exit  //chegou ao topo
		EndIf

		dbSelectArea(cAlias)
		dbSkip()

	EndDo
EndIf
RestArea(aArea)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PCOSPAK5sup³ Autor ³ Alice Yaeko Yamamoto  ³ Data ³02.07.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as procedures para popular a tabela de superiores       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOA300Sup( cTrb )                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpC1 = cTrb - nome da Tabela a popular                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PcoSPAK5Sup( cTrb)
Local cQuery  := ""
Local aCampos := AK5->(DbStruct())
Local nPos    := 0
Local cTipo   := ""
Local cProc   := CriaTrab(,.F.)+"SUPAK5_"+cEmpAnt
Local lRet := .T.

cQuery:="Create Procedure "+cProc+" ("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AK5_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIAL  "+cTipo+CRLF
cQuery+="   @OUT_RESULT Char( 01 ) OutPut"+CRLF
cQuery+=")"+CRLF

cQuery+="as"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "AK5_CODIGO" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="declare @cCodigo    "+cTipo+CRLF
cQuery+="declare @cCodAux    "+cTipo+CRLF
cQuery+="declare @cSup       "+cTipo+CRLF
cQuery+="declare @cSupAux    "+cTipo+CRLF
cQuery+="declare @iRecno     integer"+CRLF
cQuery+="Declare @iTranCount integer"+CRLF
cQuery+="Declare @iRegs      integer"+CRLF
cQuery+="Declare @iRecnoAux  integer"+CRLF

cQuery+="begin"+CRLF
cQuery+="   Select @OUT_RESULT = '0'"+CRLF
cQuery+="   Select @cCodigo = ''"+CRLF
cQuery+="   Select @cSup    = ''"+CRLF
cQuery+="   Select @cCodAux = ''"+CRLF
cQuery+="   Select @cSupAux = ''"+CRLF
cQuery+="   Select @iRecno  = 0"+CRLF
cQuery+="   Select @iRegs      = 0"+CRLF

cQuery+="   Declare AK5Sup cursor for"+CRLF
cQuery+="   Select AK5_CODIGO, AK5_COSUP"+CRLF
cQuery+="     From "+RetSqlName("AK5")+CRLF
cQuery+="    where AK5_FILIAL = @IN_FILIAL"+CRLF
cQuery+="      AND AK5_TIPO   = '2'"+CRLF
cQuery+="      AND D_E_L_E_T_ = ' '"+CRLF
cQuery+="   Group by AK5_CODIGO, AK5_COSUP"+CRLF
cQuery+="   for read only"+CRLF

cQuery+="   Open AK5Sup"+CRLF
cQuery+="   Fetch AK5Sup into @cCodigo, @cSup"+CRLF

cQuery+="   While @@fetch_status = 0  begin"+CRLF
cQuery+="      Select @iRecno = IsNull(Max( R_E_C_N_O_), 0 ) from "+cTrb+CRLF
cQuery+="      Select @iRecno = @iRecno + 1"+CRLF

cQuery+="      If @cSup != ' ' begin"+CRLF
cQuery+="         Select @iRegs = @iRegs+1"+CRLF
cQuery+="         If @iRegs = 1 begin"+CRLF
cQuery+="            begin tran"+CRLF
cQuery+="            select @iRegs = @iRegs"+CRLF
cQuery+="         End"+CRLF
cQuery+="         Insert into "+cTrb+" ( ANALITICA , SUPERIOR, R_E_C_N_O_ )"+CRLF
cQuery+="                        Values( @cCodigo,   @cSup,    @iRecno    )"+CRLF
cQuery+="         If @iRegs > 10000 begin"+CRLF
cQuery+="            commit tran"+CRLF
cQuery+="            select @iRegs = 0"+CRLF
cQuery+="         end"+CRLF
cQuery+="      End"+CRLF
      /* -------------------------------
          Ir subindo ate o ultimo nivel
         ------------------------------- */
cQuery+="      select @cCodAux = @cSup"+CRLF
cQuery+="      select @cSupAux = @cSup"+CRLF
cQuery+="      While @cCodAux != ' ' begin"+CRLF

cQuery+="         Select @iRecnoAux = null"+CRLF
cQuery+="         Select @iRecnoAux = R_E_C_N_O_"+CRLF
cQuery+="           From "+RetSqlName("AK5")+CRLF
cQuery+="          Where AK5_FILIAL = @IN_FILIAL"+CRLF
cQuery+="            and AK5_CODIGO = @cSupAux"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF

cQuery+="         If @iRecnoAux is not null begin"+CRLF
cQuery+="            Select @cCodAux = AK5_COSUP"+CRLF
cQuery+="              From "+RetSqlName("AK5")+CRLF
cQuery+="             Where AK5_FILIAL = @IN_FILIAL"+CRLF
cQuery+="               and AK5_CODIGO = @cSupAux"+CRLF
cQuery+="               and D_E_L_E_T_ = ' '"+CRLF

cQuery+="            If @cCodAux != ' ' begin"+CRLF
cQuery+="               select @iRegs = @iRegs + 1"+CRLF

cQuery+="               Select @iRecno = IsNull(Max( R_E_C_N_O_), 0 ) from "+cTrb+CRLF
cQuery+="   		   	Select @iRecno = @iRecno + 1"+CRLF

cQuery+="               If @iRegs = 1 begin"+CRLF
cQuery+="                  begin tran"+CRLF
cQuery+="                  select @iRegs = @iRegs"+CRLF
cQuery+="               End"+CRLF
cQuery+="               Insert into "+cTrb+" ( ANALITICA , SUPERIOR, R_E_C_N_O_ )"+CRLF
cQuery+="                              Values( @cCodigo,   @cCodAux,    @iRecno    )"+CRLF
cQuery+="               If @iRegs > 10000 begin"+CRLF
cQuery+="                  commit tran"+CRLF
cQuery+="                  Select @iRegs = 0"+CRLF
cQuery+="               End"+CRLF
cQuery+="            End"+CRLF
cQuery+="            select @cSupAux = @cCodAux"+CRLF
cQuery+="         End else begin"+CRLF
cQuery+="            select @cCodAux = ' '"+CRLF
cQuery+="         End"+CRLF
cQuery+="      End"+CRLF

cQuery+="      Fetch AK5Sup into @cCodigo, @cSup"+CRLF
cQuery+="   End"+CRLF
cQuery+="   close AK5Sup"+CRLF
cQuery+="   deallocate AK5Sup"+CRLF
cQuery+="   If @iRegs > 0 begin"+CRLF
cQuery+="      Commit tran"+CRLF
cQuery+="      select @iTranCount = 0"+CRLF
cQuery+="   End"+CRLF
cQuery+="   Select @OUT_RESULT = '1'"+CRLF
cQuery+="end"+CRLF

cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.f., cQuery, 0)

If Empty( cQuery )
	MsgAlert(STR0107+cProc)  //'A query de geracao de Contas de niveis superiores nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0108+cProc)  //'Erro na criacao da procedure de geracaode superiores'
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return({lRet, cProc})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PcoSPCTTSup³ Autor ³ Alice Yaeko Yamamoto  ³ Data ³02.07.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as procedures para popular a tabela de superiores       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOA300Sup( cTrb )                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpC1 = cTrb - nome da Tabela a popular                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PcoSPCTTSup( cTrb )
Local cQuery  := ""
Local aCampos := CTT->(DbStruct())
Local nPos    := 0
Local cTipo   := ""
Local cProc   := CriaTrab(,.F.)+"SUPCTT_"+cEmpAnt
Local lRet := .T.

cQuery:="Create Procedure "+cProc+"( "+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTT_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIAL  "+cTipo+CRLF
cQuery+="   @OUT_RESULT Char( 01 ) OutPut"+CRLF
cQuery+=")"+CRLF

cQuery+="as"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTT_CUSTO" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="declare @cCodigo    "+cTipo+CRLF
cQuery+="declare @cCodAux    "+cTipo+CRLF
cQuery+="declare @cSup       "+cTipo+CRLF
cQuery+="declare @cSupAux    "+cTipo+CRLF
cQuery+="declare @iRecno     integer"+CRLF
cQuery+="Declare @iTranCount integer"+CRLF
cQuery+="Declare @iRegs      integer  "+CRLF
cQuery+="Declare @iRecnoAux  integer  "+CRLF
cQuery+=CRLF
cQuery+="begin"+CRLF
cQuery+="   "+CRLF
cQuery+="   Select @cCodigo = ''"+CRLF
cQuery+="   Select @cSup    = ''"+CRLF
cQuery+="   Select @cCodAux = ''"+CRLF
cQuery+="   Select @cSupAux = ''"+CRLF
cQuery+="   Select @iRecno  = 0"+CRLF
cQuery+="   Select @iRegs      = 0"+CRLF

cQuery+="   Declare CTTSup cursor for"+CRLF
cQuery+="   Select CTT_CUSTO, CTT_CCSUP"+CRLF
cQuery+="     From "+RetSqlName("CTT")+CRLF
cQuery+="    where CTT_FILIAL = @IN_FILIAL"+CRLF
cQuery+="      AND CTT_CLASSE = '2'"+CRLF
cQuery+="      AND D_E_L_E_T_ = ' '"+CRLF
cQuery+="   Group by CTT_CUSTO, CTT_CCSUP"+CRLF
cQuery+="   for read only"+CRLF

cQuery+="   Open CTTSup"+CRLF
cQuery+="   Fetch CTTSup into @cCodigo, @cSup"+CRLF

cQuery+="   While @@fetch_status = 0  begin"+CRLF

cQuery+="      Select @iRecno = IsNull(Max( R_E_C_N_O_), 0 ) from "+cTrb+CRLF
cQuery+="      Select @iRecno = @iRecno + 1"+CRLF

cQuery+="      If @cSup != ' ' begin"+CRLF
cQuery+="         Select @iRegs = @iRegs+1"+CRLF
cQuery+="         If @iRegs = 1 begin"+CRLF
cQuery+="            begin tran"+CRLF
cQuery+="            select @iRegs = @iRegs"+CRLF
cQuery+="         End"+CRLF
cQuery+="         Insert into "+cTrb+" ( ANALITICA , SUPERIOR, R_E_C_N_O_ )"+CRLF
cQuery+="                        Values( @cCodigo,   @cSup,    @iRecno    )"+CRLF
cQuery+="         If @iRegs > 10000 begin"+CRLF
cQuery+="            commit tran"+CRLF
cQuery+="            select @iRegs = 0"+CRLF
cQuery+="         end"+CRLF
cQuery+="      End"+CRLF
      /* -------------------------------
          Ir subindo ate o ultimo nivel
         ------------------------------- */
cQuery+="      select @cCodAux = @cSup"+CRLF
cQuery+="      select @cSupAux = @cSup"+CRLF
cQuery+="      While @cCodAux != ' ' begin"+CRLF

cQuery+="         Select @iRecnoAux = NULL"+CRLF
cQuery+="         Select @iRecnoAux = R_E_C_N_O_"+CRLF
cQuery+="           From "+RetSqlName("CTT")+CRLF
cQuery+="          Where CTT_FILIAL = @IN_FILIAL"+CRLF
cQuery+="            and CTT_CUSTO  = @cSupAux"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF

cQuery+="         If @iRecnoAux is not null begin "+CRLF
cQuery+="            Select @cCodAux = CTT_CCSUP"+CRLF
cQuery+="              From "+RetSqlName("CTT")+CRLF
cQuery+="             Where CTT_FILIAL = @IN_FILIAL"+CRLF
cQuery+="               and CTT_CUSTO  = @cSupAux"+CRLF
cQuery+="               and D_E_L_E_T_ = ' '"+CRLF

cQuery+="            If @cCodAux != ' ' begin"+CRLF
cQuery+="               select @iRegs = @iRegs + 1"+CRLF

cQuery+="               Select @iRecno = IsNull(Max( R_E_C_N_O_), 0 ) from "+cTrb+CRLF
cQuery+="               Select @iRecno = @iRecno + 1"+CRLF

cQuery+="               If @iRegs = 1 begin"+CRLF
cQuery+="                  begin tran"+CRLF
cQuery+="                  select @iRegs = @iRegs"+CRLF
cQuery+="               End"+CRLF
cQuery+="               Insert into "+cTrb+"( ANALITICA , SUPERIOR, R_E_C_N_O_ )"+CRLF
cQuery+="                              Values( @cCodigo,   @cCodAux,    @iRecno    )"+CRLF
cQuery+="               If @iRegs > 10000 begin"+CRLF
cQuery+="                  commit tran"+CRLF
cQuery+="                  Select @iRegs = 0"+CRLF
cQuery+="               End"+CRLF
cQuery+="            End"+CRLF
cQuery+="            select @cSupAux = @cCodAux"+CRLF
cQuery+="         end else begin"+CRLF
cQuery+="            select @cCodAux = ' '"+CRLF
cQuery+="         End"+CRLF
cQuery+="      End"+CRLF
cQuery+="      Fetch CTTSup into @cCodigo, @cSup"+CRLF
cQuery+="   End"+CRLF
cQuery+="   close CTTSup"+CRLF
cQuery+="   deallocate CTTSup"+CRLF

cQuery+="   If @iRegs > 0 begin"+CRLF
cQuery+="      Commit tran"+CRLF
cQuery+="      select @iTranCount = 0"+CRLF
cQuery+="   End"+CRLF
cQuery+="   Select @OUT_RESULT = '1'"+CRLF

cQuery+="end"+CRLF

cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(STR0109+cProc)//'A query de geracao de C Custos de niveis superiores nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0108+cProc) //'Erro na criacao da procedure de geracao de níveis superiores'
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return({lRet, cProc})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOvldFase³ Autor ³ Luiz Enrique	        ³ Data ³ 02-08-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao das Fases do Planejamento/Orcamento/      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PcoVldFase(cAlias,cCodFase,cCodAcao,lmsg,cCpoVld)

Local cMensagem:= ""
Local lRet		:= .T.
Local aAre		:= {}
Local aAreAlias := {}

Default lmsg    := .T.
Default cCpoVld := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Protecao do campo AK1_FASE, se nao existir na base, nao valida e retorna true  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AK1->(FieldPos("AK1_FASE")) == 0
	Return(.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  MV_PCOEXFS | Tipo: C-Caracter | Valor padrao - 2                  ³
//³  Conteudo: Se "1", usa o controle de fases                         ³
//³            Se "2", nao usa o controle de fases                     ³
//³  Parametro para verificar se o SIGAPCO vai utilizar o controle de  ³
//³  fases, independente se for do Orcamento ou do Planejamento.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMv("MV_PCOEXFS",,"2") == "2"

	lRet := .T.

Else

	aAre	  := GetArea()
	aAreAlias := (cAlias)->(GetArea())

	cCodFase:=Padr(cCodFase,3)
	cCodAcao:=Padr(cCodAcao,4)

	Do Case
		Case cAlias=="AMH"	// Tratamento do Retorno da Funcao para o Modulo de Planejamento

		//Posiciona na Tabela De Eventos AMG
		AMG->(dbSetOrder(1))
		If !AMG->(DbSeek(xFilial()+ cCodFase))
			cMensagem:= STR0104 // "Operação Inválida. Fase não Cadastrada."
		  	lRet:= .F.
		Endif

		If lRet
			AMH->(dbSetOrder(1)) // Verifica se existe a Fase X Acao Cadastrado
			If AMH->(DbSeek(xFilial()+ cCodFase + cCodAcao))
				If AMH->AMH_PERMIT == "2" //Nao Permite
				   lRet:= .F.
					If !Empty(AMH->AMH_MSG)
						cMensagem:= MSMM(AMH->AMH_CODMEM)
					Else
						If !Empty(AMG->AMG_MSG)
							cMensagem:= MSMM(AMG->AMG_CODMEM)
						Else
							cMensagem:= STR0105 // "Operacao não Permitida."
						Endif
					Endif
		   		Endif
			Else
				If !Empty(AMG->AMG_MSG)
					cMensagem:= MSMM(AMG->AMG_CODMEM)
				Else
					cMensagem:= STR0105	 // "Operacao não Permitida."
				Endif
				lRet:= .F.
			Endif
		EndIf

		Case cAlias=="AMR"	// Tratamento do Retorno da Funcao para o Modulo de Orcamento.

		//Posiciona na Tabela De Eventos AMO
		AMO->(dbSetOrder(1))
		If !AMO->(DbSeek(xFilial()+ cCodFase))
			cMensagem:= STR0104 // "Operação Inválida. Fase não Cadastrada."
		  	lRet:= .F.
		Endif

		If lRet
			AMR->(DbSetOrder(1))
			If AMR->( DbSeek( xFilial("AMR") + cCodFase + cCodAcao ) )
				If AMR->AMR_PERMIT == "2"
					If !Empty(cCpoVld) .And. !Empty(&cCpoVld) // Se for validacao em campo - AK2_
						lRet := .F.
						If !Empty(AMR->AMR_MSG)
							cMensagem := AMR->AMR_MSG
						Else
							If !Empty(AMO->AMO_MSG)
								cMensagem := AMO->AMO_MSG
							Else
								cMensagem := STR0105 // "Operacao não Permitida."
							Endif
						EndIf
					Else
						lRet := .F.
						If !Empty(AMR->AMR_MSG)
 							cMensagem := AMR->AMR_MSG
						Else
							If !Empty(AMO->AMO_MSG)
								cMensagem := AMO->AMO_MSG
							Else
								cMensagem := STR0105 // "Operacao não Permitida."
							Endif
						EndIf
					EndIf
				EndIf
			Else
				If !Empty(AMO->AMO_MSG)
					cMensagem:= AMO->AMO_MSG
				Else
					cMensagem:= STR0105 // "Operacao não Permitida."
				Endif
				lRet:= .F.
			EndIf
		EndIf

	EndCase

	If !Empty(cMensagem) .And. lmsg
		Help(" ",1,"PCOXFASEORC",,cMensagem,1,0)
	Endif

	RestArea(aAreAlias)
	RestArea(aAre)

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOVldFLinºAutor  ³Jair Ribeiro        º Data ³  11/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida inclusão de uma nova linha na acols de acordo com   º±±
±±º          ³ validacao de fases                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PCOVldFLin()
Local cAK1Fase 	:= IIF(AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "")
Local lNewLine 	:= .F.

If PcoVldFase("AMR",cAK1Fase,"0007",.T.)
	lNewLine := oGD[1]:ADDLINE()

	If !IsInCallStack("PCOAK1PLAN") .or. lNewLine 
		n := oGD[1]:nAt
		aHeader := aClone( oGD[1]:aHeader )
		aCols := aClone( oGD[1]:aCols )
		PCOPLANCL()
		PCOPLN_CL()
	EndIf
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoDelGdOKºAutor  ³Jair RIbeiro        º Data ³  11/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação para deletar linha acols de acordo com as fases  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoDelGdOK
Local llRet := .T.
Local cAK1Fase 	:= IIF(AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "")
Local lPCODLIN := ExistBlock("PCODLIN")

If AllTrim(aCols[oGd[1]:nAt,GDFieldPos("AK2_ID")]) != '*' .and. !Empty(AllTrim(aCols[oGd[1]:nAt,GDFieldPos("AK2_ID")]))
	llRet:= PcoVldFase("AMR",cAK1Fase,"0009",.T.)
EndIf

If llRet == .T. .and. lPCODLIN
	llRet := ExecBlock ("PCODLIN",.F.,.F.)
EndIF

Return llRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOVLDLIM ºAutor	³ Abel Ribeiro    	 º Data ³  18/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida Limite das Contas Orcamentarias                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOVLDLIM(oGD,cCodConta,cCodPlan,nValTot,lAtu)
	Local cQuery 		:= ""
	Local nvalor 		:= 0
	Local lRet   		:= .T.
	Local nValDig    	:= 0
	Local cAliasTRB  	:= "TRB"
	Local Area			:= AMX->(GetArea())
	Local nXy,Nx,nCntFor2

	Default nValTot := 0
    Default lAtu := .T.

    DbSelectArea("AMX")
    AMX->(DbSetOrder(2))

	If AMX->(DbSeek(xFilial("AMX")+cCodPlan))

		DbSelectArea("AMV")
		AMV->(DbSetOrder(1))
		If AMV->(DbSeek(xFilial("AMV")+AMX->AMX_CODIGO+cCodConta))
			//Soma os Valores do Acols
			//ACHAR AS COLUNAS DE VALOR
			aHeadVal := {}
			For nX := 1 To Len(oGD:aHeader)
			    If AllTrim(oGD:aHeader[nX,2]) == "AK2_VAL"
				   AADD(aHeadVal,{nX,DTOS(CTOD(Substr(oGD:aHeader[nX][1],1,10)))})
			    Endif
		    Next nX

			For nXy := 1 To Len(oGD:aCols)
				For nCntFor2 := 1 to LEN(aHeadVal)
					nPosVal	:=	aHeadVal[nCntFor2,1]
				   	nValDIG += PcoPlanVal(oGD:aCols[nXy][nPosVal],oGD:aCols[nXy,5]) //VAL(oGD:aCols[nXy][nPosVal])
			    Next nCntFor2
			Next nXy

			cQuery := "SELECT SUM(AMV_LIMITE) AS LIMITE
			cQuery += " FROM " + RetSqlName("AMV")+" AMV"
			cQuery += " LEFT JOIN " + RetSqlName("AMX")+" AMX"
			cQuery += " ON(
			cQuery += " AMV.AMV_PROJOR = AMX.AMX_CODIGO"
			cQuery += " AND AMX.D_E_L_E_T_ = ' '"
			cQuery += " AND AMX.AMX_FILIAL = '"+xFilial("AMX")+"'"
			cQuery += " )"
			cQuery += " WHERE AMV.AMV_FILIAL='"+xFilial("AMV")+"'"
			cQuery += " AND AMV_CODCON='"+cCodConta+ "'"
			cQuery += " AND AMX_PLNORC='"+cCodPlan +"'"
			cQuery += " AND AMV.D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAliasTRB,.F.,.T. )

		    IF (cAliasTRB)->( !EOF() )
		       nValor := (cAliasTRB)->LIMITE
		    ENDIF

		    (cAliasTRB)->(dbCloseArea())

		    IF nValDig > nvalor
				AVISO( STR0026 , STR0101 + CRLF +; // "Atenção!"  ### "O Soma dos valores para esta Conta Orçamentária excedeu o valor limite do Projeto"
				STR0102 + Transform(nValDig,"@E 999,999,999.99") +CRLF+; // "Valor do Período:"
				STR0103 + Transform(nvalor,"@E 999,999,999.99") , {"OK"}) // "Valor Limite:"
				lRet := .F.

				oCopia:bWhen:= {|| .T. }
				oCola:bWhen	:= {|| .T. }
				oEdit:bWhen := {|| .T. }
				oWrite:bWhen := {||.F.}
				oCopia:refresh()
				oCola:refresh()
				oEdit:refresh()
				oWrite:refresh()
				If lAtu
					oGD:aCols:=aClone(aColsAux)
					oGD:oBrowse:Refresh()
				Endif
				lContinua:=.T.
			EndIf
  		Endif
	EndIf
	RestArea(Area)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  05/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DBLocate( nSearch )
Local aArea				:= GetArea()
Local nRecno			:= 0
Local bBlock			:= {|| nRecno := (ALIAS())->(RECNO()) }
Local bForCondition		:= {|| nSearch == (ALIAS())->RECNO }
Local bWhileCondition	:= nil
Local nNextRecords		:= nil
Local nRecord			:= nil
Local lRest				:= nil

(ALIAS())->(DBGOTOP())
DBEVAL( bBlock , bForCondition, bWhileCondition, nNextRecords, nRecord, lRest )

RestArea( aArea )
Return ( nRecno )

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
Static Function PcoUserEnts()
Local lRet := .T.
Local nQt
Local aAreaAK2 := GetArea()

/*
 PcoDirEnt_User retorna
0        - sem direito de acesso
1,2 ou 3 - com direito de acesso
1 - Visualizar
2 - Alterar
3 - Controle Total
*/


// Verifica a Unidade Orcamentaria se = 0 nao tem acesso
If(AK2->(FieldPos("AK2_UNIORC")) >  0) .And. PcoDirEnt_User("AMF", AK2->AK2_UNIORC, __cUserID, .F.) == 0
  	lRet := .F.
EndIf

// Verifica a quantidade de entidades contabeis
If nQtdEntid == NIL
	If cPaisLoc == "RUS"
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf

// Verificar as novas entidades
If nQtdEntid > 4 .And. lRet == .T.

	For nQt := 5 To nQtdEntid

		dbSelectArea("CT0")
		dbSetOrder(1)

		dbSeek(xFilial("CT0")+STRZERO(nQt,2))

		If PcoDirEnt_User(CT0->CT0_ALIAS, FieldGet(AK2->(FieldPos("AK2_ENT"+STRZERO(nQt,2)))), __cUserID, .F., CT0->CT0_ENTIDA) == 0
		   	lRet := .F.
		EndIf
	Next
EndIf

RestArea(aAreaAK2)
Return (lRet)

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
Function PcoUserEtd(cUnidOrc, aCEntids)
Local lRet := .T.
Local nQt
Local aAreaAK2 := GetArea()

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
	If cPaisLoc == "RUS"
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PcoSPCTDSup³ Autor ³ Alice                  ³ Data ³03.05.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as procedures para popular a tabela de superiores - CTD ³±±
±±³          CTD- Item Contábil                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOA300Sup( cTrb )                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpC1 = cTrb - nome da Tabela a popular                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PcoSPCTDSup( cTrb )
Local cQuery  := ""
Local aCampos := CTD->(DbStruct())
Local nPos    := 0
Local cTipo   := ""
Local cProc   := CriaTrab(,.F.)+"SUPCTD_"+cEmpAnt
Local lRet := .T.

cQuery:="Create Procedure "+cProc+"( "+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTD_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIAL  "+cTipo+CRLF
cQuery+="   @OUT_RESULT Char( 01 ) OutPut"+CRLF
cQuery+=")"+CRLF

cQuery+="as"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTD_ITEM" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="declare @cCodigo    "+cTipo+CRLF
cQuery+="declare @cCodAux    "+cTipo+CRLF
cQuery+="declare @cSup       "+cTipo+CRLF
cQuery+="declare @cSupAux    "+cTipo+CRLF
cQuery+="declare @iRecno     integer"+CRLF
cQuery+="Declare @iTranCount integer"+CRLF
cQuery+="Declare @iRegs      integer  "+CRLF
cQuery+="Declare @iRecnoAux  integer  "+CRLF
cQuery+=CRLF
cQuery+="begin"+CRLF
cQuery+="   "+CRLF
cQuery+="   Select @cCodigo = ''"+CRLF
cQuery+="   Select @cSup    = ''"+CRLF
cQuery+="   Select @cCodAux = ''"+CRLF
cQuery+="   Select @cSupAux = ''"+CRLF
cQuery+="   Select @iRecno  = 0"+CRLF
cQuery+="   Select @iRegs      = 0"+CRLF

cQuery+="   Declare CTDSup cursor for"+CRLF
cQuery+="   Select CTD_ITEM, CTD_ITSUP"+CRLF
cQuery+="     From "+RetSqlName("CTD")+CRLF
cQuery+="    where CTD_FILIAL = @IN_FILIAL"+CRLF
cQuery+="      AND CTD_CLASSE = '2'"+CRLF
cQuery+="      AND D_E_L_E_T_ = ' '"+CRLF
cQuery+="   Group by CTD_ITEM, CTD_ITSUP"+CRLF
cQuery+="   for read only"+CRLF

cQuery+="   Open CTDSup"+CRLF
cQuery+="   Fetch CTDSup into @cCodigo, @cSup"+CRLF

cQuery+="   While @@fetch_status = 0  begin"+CRLF

cQuery+="      Select @iRecno = IsNull(Max( R_E_C_N_O_), 0 ) from "+cTrb+CRLF
cQuery+="      Select @iRecno = @iRecno + 1"+CRLF

cQuery+="      If @cSup != ' ' begin"+CRLF
cQuery+="         Select @iRegs = @iRegs+1"+CRLF
cQuery+="         If @iRegs = 1 begin"+CRLF
cQuery+="            begin tran"+CRLF
cQuery+="            select @iRegs = @iRegs"+CRLF
cQuery+="         End"+CRLF
cQuery+="         Insert into "+cTrb+" ( ANALITICA , SUPERIOR, R_E_C_N_O_ )"+CRLF
cQuery+="                        Values( @cCodigo,   @cSup,    @iRecno    )"+CRLF
cQuery+="         If @iRegs > 10000 begin"+CRLF
cQuery+="            commit tran"+CRLF
cQuery+="            select @iRegs = 0"+CRLF
cQuery+="         end"+CRLF
cQuery+="      End"+CRLF
      /* -------------------------------
          Ir subindo ate o ultimo nivel
         ------------------------------- */
cQuery+="      select @cCodAux = @cSup"+CRLF
cQuery+="      select @cSupAux = @cSup"+CRLF
cQuery+="      While @cCodAux != ' ' begin"+CRLF

cQuery+="         Select @iRecnoAux = NULL"+CRLF
cQuery+="         Select @iRecnoAux = R_E_C_N_O_"+CRLF
cQuery+="           From "+RetSqlName("CTD")+CRLF
cQuery+="          Where CTD_FILIAL = @IN_FILIAL"+CRLF
cQuery+="            and CTD_ITEM  = @cSupAux"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF

cQuery+="         If @iRecnoAux is not null begin "+CRLF
cQuery+="            Select @cCodAux = CTD_ITSUP"+CRLF
cQuery+="              From "+RetSqlName("CTD")+CRLF
cQuery+="             Where CTD_FILIAL = @IN_FILIAL"+CRLF
cQuery+="               and CTD_ITEM   = @cSupAux"+CRLF
cQuery+="               and D_E_L_E_T_ = ' '"+CRLF

cQuery+="            If @cCodAux != ' ' begin"+CRLF
cQuery+="               select @iRegs = @iRegs + 1"+CRLF

cQuery+="               Select @iRecno = IsNull(Max( R_E_C_N_O_), 0 ) from "+cTrb+CRLF
cQuery+="               Select @iRecno = @iRecno + 1"+CRLF

cQuery+="               If @iRegs = 1 begin"+CRLF
cQuery+="                  begin tran"+CRLF
cQuery+="                  select @iRegs = @iRegs"+CRLF
cQuery+="               End"+CRLF
cQuery+="               Insert into "+cTrb+"( ANALITICA , SUPERIOR, R_E_C_N_O_ )"+CRLF
cQuery+="                              Values( @cCodigo,   @cCodAux,    @iRecno    )"+CRLF
cQuery+="               If @iRegs > 10000 begin"+CRLF
cQuery+="                  commit tran"+CRLF
cQuery+="                  Select @iRegs = 0"+CRLF
cQuery+="               End"+CRLF
cQuery+="            End"+CRLF
cQuery+="            select @cSupAux = @cCodAux"+CRLF
cQuery+="         end else begin"+CRLF
cQuery+="            select @cCodAux = ' '"+CRLF
cQuery+="         End"+CRLF
cQuery+="      End"+CRLF
cQuery+="      Fetch CTDSup into @cCodigo, @cSup"+CRLF
cQuery+="   End"+CRLF
cQuery+="   close CTDSup"+CRLF
cQuery+="   deallocate CTDSup"+CRLF

cQuery+="   If @iRegs > 0 begin"+CRLF
cQuery+="      Commit tran"+CRLF
cQuery+="      select @iTranCount = 0"+CRLF
cQuery+="   End"+CRLF
cQuery+="   Select @OUT_RESULT = '1'"+CRLF

cQuery+="end"+CRLF

cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(STR0110+cProc) //'A query de geracao de Item de niveis superiores nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0108+cProc)  //'Erro na criacao da procedure de geracao de níveis superiores'
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return({lRet, cProc})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PcoSPCTHSup³ Autor ³ Alice                  ³ Data ³03.05.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as procedures para popular a tabela de superiores - CTH ³±±
±±³          CTH- Classe de Valor                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOA300Sup( cTrb )                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpC1 = cTrb - nome da Tabela a popular                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PcoSPCTHSup( cTrb )
Local cQuery  := ""
Local aCampos := CTH->(DbStruct())
Local nPos    := 0
Local cTipo   := ""
Local cProc   := CriaTrab(,.F.)+"SUPCTH_"+cEmpAnt
Local lRet := .T.

cQuery:="Create Procedure "+cProc+"( "+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTH_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIAL  "+cTipo+CRLF
cQuery+="   @OUT_RESULT Char( 01 ) OutPut"+CRLF
cQuery+=")"+CRLF

cQuery+="as"+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CTH_CLVL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="declare @cCodigo    "+cTipo+CRLF
cQuery+="declare @cCodAux    "+cTipo+CRLF
cQuery+="declare @cSup       "+cTipo+CRLF
cQuery+="declare @cSupAux    "+cTipo+CRLF
cQuery+="declare @iRecno     integer"+CRLF
cQuery+="Declare @iTranCount integer"+CRLF
cQuery+="Declare @iRegs      integer  "+CRLF
cQuery+="Declare @iRecnoAux  integer  "+CRLF
cQuery+=CRLF
cQuery+="begin"+CRLF
cQuery+="   "+CRLF
cQuery+="   Select @cCodigo = ''"+CRLF
cQuery+="   Select @cSup    = ''"+CRLF
cQuery+="   Select @cCodAux = ''"+CRLF
cQuery+="   Select @cSupAux = ''"+CRLF
cQuery+="   Select @iRecno  = 0"+CRLF
cQuery+="   Select @iRegs      = 0"+CRLF

cQuery+="   Declare CTHSup cursor for"+CRLF
cQuery+="   Select CTH_CLVL, CTH_CLSUP"+CRLF
cQuery+="     From "+RetSqlName("CTH")+CRLF
cQuery+="    where CTH_FILIAL = @IN_FILIAL"+CRLF
cQuery+="      AND CTH_CLASSE = '2'"+CRLF
cQuery+="      AND D_E_L_E_T_ = ' '"+CRLF
cQuery+="   Group by CTH_CLVL, CTH_CLSUP"+CRLF
cQuery+="   for read only"+CRLF

cQuery+="   Open CTHSup"+CRLF
cQuery+="   Fetch CTHSup into @cCodigo, @cSup"+CRLF

cQuery+="   While @@fetch_status = 0  begin"+CRLF

cQuery+="      Select @iRecno = IsNull(Max( R_E_C_N_O_), 0 ) from "+cTrb+CRLF
cQuery+="      Select @iRecno = @iRecno + 1"+CRLF
cQuery+="      If @cSup != ' ' begin"+CRLF
cQuery+="         Select @iRegs = @iRegs+1"+CRLF
cQuery+="         If @iRegs = 1 begin"+CRLF
cQuery+="            begin tran"+CRLF
cQuery+="            select @iRegs = @iRegs"+CRLF
cQuery+="         End"+CRLF
cQuery+="         Insert into "+cTrb+" ( ANALITICA , SUPERIOR, R_E_C_N_O_ )"+CRLF
cQuery+="                        Values( @cCodigo,   @cSup,    @iRecno    )"+CRLF
cQuery+="         If @iRegs > 10000 begin"+CRLF
cQuery+="            commit tran"+CRLF
cQuery+="            select @iRegs = 0"+CRLF
cQuery+="         end"+CRLF
cQuery+="      End"+CRLF
      /* -------------------------------
          Ir subindo ate o ultimo nivel
         ------------------------------- */
cQuery+="      select @cCodAux = @cSup"+CRLF
cQuery+="      select @cSupAux = @cSup"+CRLF
cQuery+="      While @cCodAux != ' ' begin"+CRLF

cQuery+="         Select @iRecnoAux = NULL"+CRLF
cQuery+="         Select @iRecnoAux = R_E_C_N_O_"+CRLF
cQuery+="           From "+RetSqlName("CTH")+CRLF
cQuery+="          Where CTH_FILIAL = @IN_FILIAL"+CRLF
cQuery+="            and CTH_CLVL  = @cSupAux"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF

cQuery+="         If @iRecnoAux is not null begin "+CRLF
cQuery+="            Select @cCodAux = CTH_CLSUP"+CRLF
cQuery+="              From "+RetSqlName("CTH")+CRLF
cQuery+="             Where CTH_FILIAL = @IN_FILIAL"+CRLF
cQuery+="               and CTH_CLVL   = @cSupAux"+CRLF
cQuery+="               and D_E_L_E_T_ = ' '"+CRLF

cQuery+="            If @cCodAux != ' ' begin"+CRLF
cQuery+="               select @iRegs = @iRegs + 1"+CRLF

cQuery+="               Select @iRecno = IsNull(Max( R_E_C_N_O_), 0 ) from "+cTrb+CRLF
cQuery+="               Select @iRecno = @iRecno + 1"+CRLF

cQuery+="               If @iRegs = 1 begin"+CRLF
cQuery+="                  begin tran"+CRLF
cQuery+="                  select @iRegs = @iRegs"+CRLF
cQuery+="               End"+CRLF
cQuery+="               Insert into "+cTrb+"( ANALITICA , SUPERIOR, R_E_C_N_O_ )"+CRLF
cQuery+="                              Values( @cCodigo,   @cCodAux,    @iRecno    )"+CRLF
cQuery+="               If @iRegs > 10000 begin"+CRLF
cQuery+="                  commit tran"+CRLF
cQuery+="                  Select @iRegs = 0"+CRLF
cQuery+="               End"+CRLF
cQuery+="            End"+CRLF
cQuery+="            select @cSupAux = @cCodAux"+CRLF
cQuery+="         end else begin"+CRLF
cQuery+="            select @cCodAux = ' '"+CRLF
cQuery+="         End"+CRLF
cQuery+="      End"+CRLF
cQuery+="      Fetch CTHSup into @cCodigo, @cSup"+CRLF
cQuery+="   End"+CRLF
cQuery+="   close CTHSup"+CRLF
cQuery+="   deallocate CTHSup"+CRLF

cQuery+="   If @iRegs > 0 begin"+CRLF
cQuery+="      Commit tran"+CRLF
cQuery+="      select @iTranCount = 0"+CRLF
cQuery+="   End"+CRLF
cQuery+="   Select @OUT_RESULT = '1'"+CRLF

cQuery+="end"+CRLF

cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(STR0111+cProc) //'A query de geracao de Classe de valor de niveis superiores nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0108+cProc)  //'Erro na criacao da procedure de geracao de níveis superiores'
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return({lRet, cProc})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PCOSPCV0sup³ Autor ³ Alice                 ³ Data ³03.05.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as procedures para popular a tabela de superiores - CV0 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOA300Sup( cTrb, cAliasAKW, cPlano )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = cTrb - nome da Tabela a popular                     ³±±
±±             ExpC2 = cAliasAKW - Alias para o qual a tabela sera populada³±±
±±             ExpC1 = cPlano - codigo do Plano -> '05', '06',             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PcoSPCV0Sup( cTrb, cAliasAKW, cPlano )
Local cQuery  := ""
Local aCampos := &(cAliasAKW)->(DbStruct())
Local nPos    := 0
Local cTipo   := ""
Local cProc   := CriaTrab(,.F.)+"SUPE"+cPlano+"_"+cEmpAnt
Local lRet := .T.

cQuery:="Create Procedure "+cProc+" ("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == cAliasAKW+"_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIAL  "+cTipo+CRLF
cQuery+="   @OUT_RESULT Char( 01 ) OutPut"+CRLF
cQuery+=")"+CRLF

cQuery+="as"+CRLF

nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == cAliasAKW+"_CODIGO" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="declare @cCodigo    "+cTipo+CRLF
cQuery+="declare @cCodAux    "+cTipo+CRLF
cQuery+="declare @cSup       "+cTipo+CRLF
cQuery+="declare @cSupAux    "+cTipo+CRLF
cQuery+="declare @iRecno     integer"+CRLF
cQuery+="Declare @iTranCount integer"+CRLF
cQuery+="Declare @iRegs      integer"+CRLF
cQuery+="Declare @iRecnoAux  integer"+CRLF

cQuery+="begin"+CRLF
cQuery+="   Select @OUT_RESULT = '0'"+CRLF
cQuery+="   Select @cCodigo = ''"+CRLF
cQuery+="   Select @cSup    = ''"+CRLF
cQuery+="   Select @cCodAux = ''"+CRLF
cQuery+="   Select @cSupAux = ''"+CRLF
cQuery+="   Select @iRecno  = 0"+CRLF
cQuery+="   Select @iRegs      = 0"+CRLF

cQuery+="   Declare ENT"+cPlano+"Sup cursor for"+CRLF
cQuery+="   Select CV0_CODIGO, CV0_ENTSUP"+CRLF
cQuery+="     From "+RetSqlName("CV0")+CRLF
cQuery+="    where CV0_FILIAL = @IN_FILIAL"+CRLF
cQuery+="      AND CV0_PLANO = '"+cPlano+"'"+CRLF
cQuery+="      AND CV0_CLASSE = '2'"+CRLF
cQuery+="      AND D_E_L_E_T_ = ' '"+CRLF
cQuery+="   Group by CV0_CODIGO, CV0_ENTSUP"+CRLF
cQuery+="   for read only"+CRLF

cQuery+="   Open ENT"+cPlano+"Sup"+CRLF
cQuery+="   Fetch ENT"+cPlano+"Sup into @cCodigo, @cSup"+CRLF

cQuery+="   While @@fetch_status = 0  begin"+CRLF
cQuery+="      Select @iRecno = IsNull(Max( R_E_C_N_O_), 0 ) from "+cTrb+CRLF
cQuery+="      Select @iRecno = @iRecno + 1"+CRLF

cQuery+="      If @cSup != ' ' begin"+CRLF
cQuery+="         Select @iRegs = @iRegs+1"+CRLF
cQuery+="         If @iRegs = 1 begin"+CRLF
cQuery+="            begin tran"+CRLF
cQuery+="            select @iRegs = @iRegs"+CRLF
cQuery+="         End"+CRLF
cQuery+="         Insert into "+cTrb+" ( ANALITICA , SUPERIOR, R_E_C_N_O_ )"+CRLF
cQuery+="                        Values( @cCodigo,   @cSup,    @iRecno    )"+CRLF
cQuery+="         If @iRegs > 10000 begin"+CRLF
cQuery+="            commit tran"+CRLF
cQuery+="            select @iRegs = 0"+CRLF
cQuery+="         end"+CRLF
cQuery+="      End"+CRLF
      /* -------------------------------
          Ir subindo ate o ultimo nivel
         ------------------------------- */
cQuery+="      select @cCodAux = @cSup"+CRLF
cQuery+="      select @cSupAux = @cSup"+CRLF
cQuery+="      While @cCodAux != ' ' begin"+CRLF

cQuery+="         Select @iRecnoAux = null"+CRLF
cQuery+="         Select @iRecnoAux = R_E_C_N_O_"+CRLF
cQuery+="           From "+RetSqlName("CV0")+CRLF
cQuery+="          Where CV0_FILIAL = @IN_FILIAL"+CRLF
cQuery+="            and CV0_CODIGO = @cSupAux"+CRLF
cQuery+="            and CV0_PLANO  = '"+cPlano+"'"+CRLF
cQuery+="            and D_E_L_E_T_ = ' '"+CRLF

cQuery+="         If @iRecnoAux is not null begin"+CRLF
cQuery+="            Select @cCodAux = CV0_ENTSUP"+CRLF
cQuery+="              From "+RetSqlName("CV0")+CRLF
cQuery+="             Where CV0_FILIAL = @IN_FILIAL"+CRLF
cQuery+="               and CV0_CODIGO = @cSupAux"+CRLF
cQuery+="               and CV0_PLANO = '"+cPlano+"'"+CRLF
cQuery+="               and D_E_L_E_T_ = ' '"+CRLF

cQuery+="            If @cCodAux != ' ' begin"+CRLF
cQuery+="               select @iRegs = @iRegs + 1"+CRLF

cQuery+="               Select @iRecno = IsNull(Max( R_E_C_N_O_), 0 ) from "+cTrb+CRLF
cQuery+="   		   	Select @iRecno = @iRecno + 1"+CRLF

cQuery+="               If @iRegs = 1 begin"+CRLF
cQuery+="                  begin tran"+CRLF
cQuery+="                  select @iRegs = @iRegs"+CRLF
cQuery+="               End"+CRLF
cQuery+="               Insert into "+cTrb+" ( ANALITICA , SUPERIOR, R_E_C_N_O_ )"+CRLF
cQuery+="                              Values( @cCodigo,   @cCodAux,    @iRecno    )"+CRLF
cQuery+="               If @iRegs > 10000 begin"+CRLF
cQuery+="                  commit tran"+CRLF
cQuery+="                  Select @iRegs = 0"+CRLF
cQuery+="               End"+CRLF
cQuery+="            End"+CRLF
cQuery+="            select @cSupAux = @cCodAux"+CRLF
cQuery+="         End else begin"+CRLF
cQuery+="            select @cCodAux = ' '"+CRLF
cQuery+="         End"+CRLF
cQuery+="      End"+CRLF

cQuery+="      Fetch ENT"+cPlano+"Sup into @cCodigo, @cSup"+CRLF
cQuery+="   End"+CRLF
cQuery+="   close ENT"+cPlano+"Sup"+CRLF
cQuery+="   deallocate ENT"+cPlano+"Sup"+CRLF
cQuery+="   If @iRegs > 0 begin"+CRLF
cQuery+="      Commit tran"+CRLF
cQuery+="      select @iTranCount = 0"+CRLF
cQuery+="   End"+CRLF
cQuery+="   Select @OUT_RESULT = '1'"+CRLF
cQuery+="end"+CRLF

cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.f., cQuery, 0)

If Empty( cQuery )
	MsgAlert(STR0112+cProc)  //'A query de geracao de Entidades de niveis superiores nao passou pelo Parse '
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert(STR0108+cProc)//'Erro na criacao da procedure de geracao de níveis superiores'
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return({lRet, cProc})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraSupProc³ Autor ³ Alice                 ³ Data ³03.05.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama as funções q fazem a criação e instalação de procedures ±±
±±³        que geram osníveis superiores p as entidades                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOA300Sup( cArquivo, cAliasAKW, cPlano )                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = cArquivo  - nome da Tabela a popular                ³±±
±±             ExpC2 = cAliasAKW - Alias para o qual a tabela sera populada³±±
±±             ExpC3 = cPlano - codigo do Plano -> '05', '06' somente para ³±±
±±                     as novas entidades - Entidades que estão no CV0     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraSupProc( cArquivo, cAliasAKW, cPlano )
Local aRetorno := {}

If cAliasAKW == 'AK5'
	aRetorno := PcoSPAK5Sup( cArquivo )
ElseIf cAliasAKW == 'CTT'
	aRetorno := PcoSPCTTSup( cArquivo )
ElseIf cAliasAKW == 'CTD'
	aRetorno := PcoSPCTDSup( cArquivo )
ElseIf cAliasAKW == 'CTH'
	aRetorno := PcoSPCTHSup( cArquivo )
Else      //cAliasAKW == 'CV0'
	aRetorno := PcoSPCV0Sup( cArquivo, cAliasAKW, cPlano )
EndIf

Return(aRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOAK1AUT ³ Autor ³ Alexandre Circenis    ³ Data ³ 08/04/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de montagem da tela de planilha orcamentaria        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOAK1Aut(cTitle,aCampos,cArquivo,lConfirma,aMenu,oDlg,bChange,lUser,lVisual, cFiltro, cCOInic,lDetalheCO, nOpc)

Local nx
Local nTop      := 0
Local nLeft     := 0
Local nBottom   := 0
Local nRight    := 0

Local aExpand		:= {}
Local aSVAlias		:= {}
Local aEnch[3]
Local nOldEnch	:= 1

Local aRecNoVisible := {}

Local aPeriodos
//Proteção campo AK1_FASE
Local cAK1Fase	:= IIF( AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "" )
Local cValid	:= ""
//Proteção da tabela AMX
Local lAMX		:= AliasInDic("AMX")
Local lValid:= .T.

Local cFiller := Space( 1 )    // TGXEBL

DEFAULT bChange := {|| Nil }
DEFAULT lUser	:= .F.
DEFAULT lVisual	:= .F.
DEFAULT lDetalheCO	:=	.T.

DEFAULT aCampos	:= {{"AK3_DESCRI","AK3_DESCRI",55,,,.F.,"",Iif(lDetalheCO,300,600),Max(TamSx3("AK3_DESCRI")[1]+Iif(lDetalheCO,25,100),255)},{"AK3_CO","AK3_CO",55,,,.F.,"",50,TamSx3("AK3_CO")[1]}}

PRIVATE oBrowse
PRIVATE oFormula

PRIVATE nColGd := 0
PRIVATE aFormula := {}
PRIVATE oFormZe, oFormZe1

PRIVATE bRefresh	:= {|cFiltro| (PCOAtuPlan(cRevisa,cArquivo,If(lUser,12000,If(AK1->AK1_NMAX>0,AK1->AK1_NMAX,1)),aExpand,,lUser,cFiltro,cCOInic),oBrowse:Refresh(),PcoDlgView(cArquivo,@aSVAlias,@aEnch,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},@nOldEnch,@oPanel3,.T.)),Eval(bBrwChange) }
PRIVATE bRefreshAll	:= {|cFiltro| (PCOAtuPlan(cRevisa,cArquivo,If(lUser,12000,If(AK1->AK1_NMAX>0,AK1->AK1_NMAX,1)),,,lUser,cFiltro,cCOInic),oBrowse:Refresh(),PcoDlgView(cArquivo,@aSVAlias,@aEnch,{0,0,((oDLg:nBottom-oDLg:nTop)/2)-39,(nRight-nLeft)/2-152},@nOldEnch,@oPanel3,.T.)) }
PRIVATE bBrwChange	:= {|| Eval(oBrowse:bChange) }
PRIVATE aStru		:= {}
PRIVATE aAuxCps		:= aClone(aCampos)
PRIVATE aHeaderAK2	:= {}
PRIVATE aColsAK2	:= {}
PRIVATE oGD[1]
PRIVATE oFolder
PRIVATE oCopia, oCola, oEdit, oWrite, oCancel
PRIVATE cArquivx := cArquivo
PRIVATE nRecEdic := 0
PRIVATE nRecPos	:= 0

PRIVATE aColsAux := {}
cRevisa := AK1->AK1_VERSAO

If !IsBlind()
	nTop      := oMainWnd:nTop+35
	nLeft     := oMainWnd:nLeft+10
	nBottom   := oMainWnd:nBottom-12
	nRight    := oMainWnd:nRight-10
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AK2                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AK2")
While !EOF() .And. (x3_arquivo == "AK2")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ;
		! ( AllTrim(X3_CAMPO) $ "AK2_MARK|AK2_ALTER|AK2_COPIA|AK2_COLA|AK2_FANTS|AK2_DESCCO|AK2_DESCIT|AK2_DESCCL") ;
		.And. AllTrim(X3_TIPO) != "M"
	If AllTrim(X3_CAMPO) = "AK2_CHAVE"
		AADD(aHeaderAK2,{ 	TRIM(x3titulo()),;
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
	EndIf

	Endif
	dbSkip()
End

If ExistBlock("PCOAK2HED")
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para alterar o aHeader da planilha de       ³
	//P_E³ orcamento.                                                             ³
	//P_E³ Parametros : aHeader (Padrão)                                          ³
	//P_E³ Retorno    : aHeader (Alterado)                                        ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeaderAK2 := ExecBlock("PCOAK2HED",.F.,.F.,aHeaderAK2)
EndIf

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("AK2_VAL")
aPeriodos	:=	PcoRetPer()
For nX :=1 To Len(aPeriodos)

	If !Empty(cAK1Fase)
		cValid := "PCOBlqRMes(oGD[1],'"+cRevisa+"') .And. PCOChk_Acesso(cArquivx, oGD[1], oGD[1]:nAt).And. PcoVldFase('AMR',AK1->AK1_FASE,'0014',.T.)"+If(!Empty(SX3->X3_WHEN),".And.("+SX3->X3_WHEN+")","")
	Else
		cValid := "PCOBlqRMes(oGD[1],'"+cRevisa+"') .And. PCOChk_Acesso(cArquivx, oGD[1], oGD[1]:nAt) "+If(!Empty(SX3->X3_WHEN),".And.("+SX3->X3_WHEN+")","")
	EndIF

	AADD(aHeaderAK2,{ aPeriodos[nX],;
						SX3->X3_CAMPO,;
						cFiller,;  // SX3->X3_PICTURE,; - TGXEBL
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
Next


PcoRetAcolsAK2(aHeaderAK2, aColsAK2, .T.)  // Chamado da Rotina automatica

aCols := aColsAK2
aHeader := aHeaderAK2

if PCOGetDAut ( aAutoItens, "PcoxAK2LinOK", "PcoxAK2TudOK", , nOpc , .F.)

	if lAMX
		lValid := PCOLIMAUTO(aHeaderAK2, AcolsAK2,AK3->AK3_CO,AK1->AK1_CODIGO)
    endif
    if lValid
		PcoIniLan("000252")
		PcoAoolIt(AK1->AK1_VERSAO, aCols, aRecNoVisible)
		PcoFinLan("000252")
    endif
endif

Return lValid

//--------------------------------------------------------
//simula MSGETDADOS p/ ambiente automatico no ambiente PCO
//--------------------------------------------------------

Static Function PCOGetDAut(aField,uLinhaOk,uTudoOk,aEnchAuto,nOpc,lClear)
Local lRet := .T.
Local lSet := HelpInDark(.T.)
Local lDeleted

Local ni
Local nj
Local nPos
Local nLin
Local nLenCols := Len(aCols)
Local nLenHeader := Len(aHeader)

Local cVar
Local cTipo
Local cValid
Local cMsg := ""
Local cSvAlias := Alias()
Local cClasse := ''
Local nLinClas := 0

Local bLinhaOk
Local bBloco

Local aCache
Local aSeek
Local aVar


//+-----------------------------------------------------------+
//¦ Parametro utilizado para validar campos obrigatorios      ¦
//+-----------------------------------------------------------+
Local lVldObrig := SuperGetMv("MV_VLDOBRI",.F.,.F.)
Local nCnt2

Local nx
Local cVisual
Local cTitulo

Private cCampo := ""

Public n := 1	//variavel n declarada como na MSGETDADOS

DEFAULT nOpc := 3
DEFAULT lClear := .T.

If Ascan(aField,{|x| Ascan(x,{|x| Upper(Alltrim(x[1])) == "LINPOS"}) > 0}) > 0
	lClear := .F.
EndIf

//prepara o bloco do LINHAOK
If Empty(uLinhaOk)
	bLinhaOk := {|| .T.}

ElseIf ValType(uLinhaOk) == "C"
	If !("(" $ uLinhaOk)
		uLinhaOk += "()"
	EndIf
	bLinhaOk := {|| &uLinhaOk}

ElseIf ValType(uTudoOk) == "B"
	bLinhaOk := {|| Eval(uLinhaOk)}
EndIf

For ni := 1 To Len(aField)

	nLinPos := Ascan(aField[ni],{|x| Upper(Alltrim(x[1])) == "LINPOS"})
	nLinClas := Ascan(aField[ni],{|x| Upper(Alltrim(x[1])) == "AK2_CLASSE"})
	If nLinPos > 0
		If "+"$aField[ni][nLinPos][2]	//posicionamento por chave composta
			bBloco := "{|x| "
			aVar := {}
			aSeek := StrTokArr(aField[ni][nLinPos][2],"+")
			For nj := 1 To Len(aSeek)
				nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == aSeek[nj]})
				If nPos > 0
					bBloco += "x["+Str(nPos)+"] == aVar["+Str(nj)+"]"
					Aadd(aVar,aField[ni][nLinPos][2+nj])

					If nj <> Len(aSeek)
						bBloco += " .and. "
					EndIf
				Else
					MsLogGetD(aField[ni],aEnchAuto,nLinPos,"LINPOS - Parametro #2 invalido",0)
					lRet := .F.
					Exit
				EndIf
			Next

			If lRet
				bBloco += "}"
				bBloco := &bBloco
				n := Ascan(aCols,bBloco)
				If n == 0
					MsLogGetD(aField[ni],aEnchAuto,nLinPos,"LINPOS - Parametro #3 invalido",0)
					lRet := .F.
					Exit
				EndIf
			Else
				Exit
			EndIf
		Else
			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == aField[ni][nLinPos][2]})
			If nPos > 0
				n := Ascan(aCols,{|x| x[nPos] == aField[ni][nLinPos][3]})
				If n == 0
					MsLogGetD(aField[ni],aEnchAuto,nLinPos,"LINPOS - Parametro #3 invalido",0)
					lRet := .F.
					Exit
				EndIf
			Else
				MsLogGetD(aField[ni],aEnchAuto,nLinPos,"LINPOS - Parametro #2 invalido",0)
				lRet := .F.
				Exit
			EndIf
		EndIf
	Else
		//monta a linha do ACOLS
		Aadd(aCols,Array(nLenHeader + 1))
		n := ++nLenCols
		For nj := 1 To nLenHeader
			cVar := Upper(AllTrim(aHeader[nj][2]))
			aCache := GetFldValue(cVar)

			//inicializador padrao
			If !Empty(aCache[4])
				aCols[n][nj] := InitPad(aCache[4])

			Else

				cTipo := aHeader[nj][8]
				If cTipo $ "CM"
					aCols[n][nj] := Space(aHeader[nj][4])

				ElseIf cTipo == "N"
					aCols[n][nj] := 0

				ElseIf cTipo == "D"
					aCols[n][nj] := dDataBase

				ElseIf cTipo == "L"
					aCols[n][nj] := .F.
				EndIf
			EndIf
		Next
		aCols[n][nj] := .F.
	EndIf

	If (nPos := Ascan(aField[ni],{|x| Upper(Alltrim(x[1])) == "AUTDELETA"})) > 0
		aCols[n][nLenHeader + 1] := (Upper(aField[ni][nPos][2]) == "S")
	EndIf

	lDeleted := (nOpc == 5 .or. aCols[n][nLenHeader + 1])

	For nj := 1 To Len(aField[ni])

		cVar := Upper(AllTrim(aField[ni][nj][1]))
		if Left(cVar,1) = "P" .and. Val(Right(cVar,2))> 0
			nLin:=Ascan(aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})//classe
			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == "AK2_VAL"})
			nPos += Val(Right(cVar,2)) - 1
		else
			nPos := Ascan(aHeader,{|x| AllTrim(x[2]) == cVar})
		endif


		If nPos > 0
			cCampo := aField[ni][nj][2]
			If aHeader[nPos][8] == "C"
				cCampo := Padr(cCampo,aHeader[nPos][4])
			EndIf

			__READVAR := "M->" + cVar
			&(__READVAR) := cCampo

			aCache := GetFldValue(cVar)

			//validacao do campo (se nao for exclusao)
			If !lDeleted .and. !Empty(aCache[1]) .and. (nLinPos == 0 .or. cCampo <> if(aHeader[nPos][2]="AK2_VAL",Val(aCols[n][nPos]),aCols[n][nPos]))
				If Upper(AllTrim(aCache[1])) <> ".F."
					If aField[ni][nj][3] == NIL
						cValid := aCache[1]
					Else
						cValid := If(Empty(aField[ni][nj][3]),".T.",aField[ni][nj][3])
					EndIf

					If !(lRet := EvalValid(cValid,@cMsg,.F.))
						If !Empty(cSvAlias)
							DbSelectArea(cSvAlias)
						EndIf
						//grava log
						MsLogGetD(aField[ni],aEnchAuto,nJ,cMsg,n)
						Exit
					EndIf
				EndIf
			EndIf


			//atualiza ACOLS
			if Left(cVar,1) = "P" .and. Val(Right(cVar,2))> 0
				cClasse:= aCols[n][nLin]
				aCols[n][nPos] := PcoPlanCel(&(__READVAR), cClasse)
			else
				aCols[n][nPos] := &(__READVAR)
			endif

			//executa gatilhos (se nao for exclusao)
			If !lDeleted .and. aCache[2] == "S"
				RunTrigger(2,n,,,Padr(cVar,10))
			EndIf
		EndIf
	Next

	SX3->(DbSetOrder(2))
	for nj:=1 to Len(aHeader)
		AutoReadVar := "M->" + Upper( aHeader[nj][2] )
		&(AutoReadVar) := aCols[n][nJ]
		__ReadVar	:= AutoReadVar

		cVar := cEmpAnt+Upper(AllTrim(aHeader[nj][2]))
		If (nx := Ascan(aGetDCache,cVar)) == 0
			SX3->(DbSeek(aHeader[nj][2]))
			lObrigat := x3uso(SX3->X3_USADO) .and. ((X3Obrigat(SX3->X3_CAMPO)) .or. VerByte(SX3->X3_RESERV,7))
			cVisual := SX3->X3_VISUAL

			Aadd(aGetDCache,cVar)
			Aadd(aGetDInfo,{lObrigat,cVisual,X3TITULO()})
		Else
			lObrigat := aGetDInfo[nx][GETD_OBRIGAT]
			cVisual := aGetDInfo[nx][GETD_VISUAL]
		EndIf

		//SX3->(DbSeek(aHeader[nj][2]))
		//lObrigat := x3uso(SX3->X3_USADO) .and. ((SubStr(BIN2STR(SX3->X3_OBRIGAT),1,1) == "x") .or. VerByte(SX3->X3_RESERV,7))
		If cVisual # "V" //SX3->X3_VISUAL # "V"
			uVar := aCols[n][nJ]
			If 	 (ValType(uVar) == "C")
				cConteudo := uVar
			ElseIf (ValType(uVar) == "N")
				cConteudo := Str(uVar)
			ElseIf (ValType(uVar) == "D")
				cConteudo := DtoC(uVar)
			ElseIf (ValType(uVar) == "L")
				cConteudo := If(uVar,"True","False")
			ElseIf (ValType(uVar) == "M")
				cConteudo := "Memo"
			ElseIf (ValType(uVar) == "U")
				cConteudo := "Nil"
			EndIf

			If lVldObrig .And. (lObrigat .And. Empty(cConteudo))
				AutoGRLog("Tabela "+aHeader[nj][9]+" "+Dtoc(MsDate())+' '+Time() )
				For nCnt2 := 1 To Len(aHeader)
					cVar := cEmpAnt+Upper(AllTrim(aHeader[nCnt2][2]))
					If (nx := Ascan(aGetDCache,cVar)) == 0
						SX3->(DbSeek(aHeader[nCnt2][2]))
						cTitulo := X3TITULO()

						Aadd(aGetDCache,cVar)
						Aadd(aGetDInfo,{x3uso(SX3->X3_USADO) .and. ((X3Obrigat(SX3->X3_OBRIGAT)) .or. VerByte(SX3->X3_RESERV,7)),SX3->X3_VISUAL,cTitulo})
					Else
						cTitulo := aGetDInfo[nx][GETD_TITULO]
					EndIf

					nPos := Ascan(aField[1], {|x| AllTrim(x[1]) == AllTrim(aHeader[nCnt2][2])})
					If nPos > 0
						uVar := afield[1][nPos][2]
						If 	 (ValType(uVar) == "C")
							cConteudo := uVar
						ElseIf (ValType(uVar) == "N")
							cConteudo := Str(uVar)
						ElseIf (ValType(uVar) == "D")
							cConteudo := DtoC(uVar)
						ElseIf (ValType(uVar) == "L")
							cConteudo := If(uVar,"True","False")
						ElseIf (ValType(uVar) == "M")
							cConteudo := "Memo"
						ElseIf (ValType(uVar) == "U")
							cConteudo := "Nil"
						EndIf
					else
						cConteudo := ""
					EndIf

					If (Padr(aHeader[nCnt2][2],12) == Padr(Subs(AutoReadVar,4),12))
						cErro := " < -- Invalido"
					Else
						cErro := ""
					EndIf
					//AutoGRLog(Padr(X3TITULO(),20)+'- '+Padr(SX3->X3_CAMPO,12)+":="+cConteudo+cErro)
					AutoGRLog(Padr(cTitulo,20)+'- '+Padr(aHeader[nCnt2][2],12)+":="+cConteudo+cErro)
				Next
				AutoGRLog(Repl("-",80))
				lMsHelpAuto := .F.
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
	//saida por erro na validacao de campo
	If !lRet
		Exit
	EndIf

	//valida LINHAOK (se nao for exclusao)
	If !lDeleted
		If !(lRet := Eval(bLinhaOk))
			If !Empty(cSvAlias)
				DbSelectArea(cSvAlias)
			EndIf
			//grava log
			MsLogGetD(aField[ni],aEnchAuto,,"Inconsistencia na Linha de Itens",n)
			Exit
		EndIf
	EndIf
Next

//valida TUDOOK (se nao for exclusao)
If lRet .and. nOpc <> 5 .and. !Empty(uTudoOk)
	If ValType(uTudoOk) == "C"
		If !("(" $ uTudoOk)
			uTudoOk += "()"
		EndIf
		lRet := &uTudoOk
	ElseIf ValType(uTudoOk) == "B"
		lRet := Eval(uTudoOk)
	EndIf

	If !lRet
		If !Empty(cSvAlias)
			DbSelectArea(cSvAlias)
		EndIf
		//grava log
		AutoGRLog("Tabela " + Alias() + " " + Dtoc(MsDate()) + " " + Time())
		AutoGRLog("Inconsistencia nos Itens")
		AutoGRLog(Repl("-",80))
	EndIf
EndIf

HelpInDark(lSet)

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoRetAcolºAutor  ³Alexandre Circenis  º Data ³  09/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna AK2 preenchido para execauto                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoRetAcolsAK2(aHeaderAK2, aColsAK2, lAuto)
Local nY,nX,nZ
Local aAuxArea	:= {}
Local aArea		:= GetArea()
Local nHeadItem	:= aScan(aHeaderAK2,{|x| AllTrim(x[2])=="AK2_ID"})
Local nHeadCtaOrc	:= aScan(aHeaderAK2,{|x| AllTrim(x[2])=="AK2_CO"})
Local aAreaAK3 := AK3->(GetArea())
Local nOrdem, bSeek, bWhile, bFiltro
Local nPosCO, nPosClasse, nPosOper, nPosCC, nPosItCtb, nPosClVlr

Local lContinua := .F.
Local aPeriodos	:=	PcoRetPer()
Local nPosAc	:=0
Local cGroup 	:=""
Local cCoCabec 	:= ""

Local lQueryAK2 := .F.

DEFAULT lAuto := .F.

aRecAK2 		:= {}

aColsAK2 	:= {}
aFormula 		:= {}

// Verifica a quantidade de entidades contabeis
If nQtdEntid == NIL
	nQtdEntid := If(FindFunction("CtbQtdEntd"),Iif(cPaisLoc$"RUS",PCOQtdEntd(),CtbQtdEntd()),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

cWhere := ""

cGroup	:=	'SQ.AK2_CO,SQ.AK2_ID '
dbSelectArea("AK3")
dbSetOrder(1)

dbSelectArea("AK2")
//dbSetOrder(nOrdem)
If !Empty(cCoCabec)
	cOrder	:=	"AK2_ID "
Else
	cOrder	:=	"AK2_CO,AK2_ID,AK2_CLASSE,AK2_OPER,AK2_CC,AK2_ITCTB,AK2_CLVLR "
Endif
If Alltrim(Upper(TcGetDB())) == "INFORMIX" .OR. lAuto
	cQuery	:=	""
Else
	cQuery	:=	MontaQryAK2(cRevisa,  ,cWhere,cGroup, cOrder)
EndIf
If !Empty(cQuery)
	lQueryAK2	:=	.T.
	If Select("QRYAK2") > 0
		DbSelectArea("QRYAK2")
		DbCloseArea()
		DbSelectArea("AK2")
	Endif
	PmsIncProc(.T.)
	cAliasAK2	:=	"QRYAK2"
  	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYAK2", .F., .F. )
	PmsIncProc(.T.)

  	aStrAK2	:=	AK2->(DbStruct())
	For ny := 1 to Len(aStrAK2)
		If aStrAK2[nY,2] <> "C"
			TcSetField("QRYAK2",aStrAK2[nY,1],aStrAK2[nY,2] ,aStrAK2[nY,3] ,aStrAK2[nY,4] )
		Endif
	Next

	QRYAK2->(DbGoTop())
	While QRYAK2->(!Eof())

		PmsIncProc(.T.)
		lContinua := .T.
		//posicionar em AK3
		AK3->(dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cRevisa+QRYAK2->AK2_CO))
		nPosAc := 0
		lContinua := .T.
		If lContinua
			nPosIt	:= 0 //aScan(aColsAK2,{|x| x[nHeadItem] == (cAliasAK2)->AK2_ID})
			//Isto so acontecera em ambiente sem Query, por isso nao é neessaria a validacao
			If nPosIt > 0
				nPosHead := aScan(aHeaderAK2,{|x| CTOD(Substr(x[1],1,10))==(cAliasAK2)->AK2_PERIOD})
				If nPosHead > 0
					aColsAK2[nPosIt,nPosHead] := PcoPlanCel((cAliasAK2)->AK2_VALOR,(cAliasAK2)->AK2_CLASSE)
					If (nPos := Ascan(aFormula, {|aVal|aVal[1]==nPosIt .And. ;
										aVal[2]==Alltrim(aHeaderAk2[nPosHead,1])})) == 0
				   		aAdd(aFormula, {nPosIt, Alltrim(aHeaderAk2[nPosHead,1]), (cAliasAK2)->AK2_FORMUL})
				    EndIf
				EndIf
			Else
				aADD(aColsAK2,Array(Len(aHeaderAk2)+1))
				aColsAK2[Len(aColsAK2),Len(aHeaderAk2)+1] := .F.
				For ny := 1 to Len(aHeaderAk2)
					Do Case
						Case AllTrim(aHeaderAk2[ny,2])=="AK2_VAL"
							If lQueryAK2
								nPosHead := aScan(aHeaderAk2,{|x| CTOD(Substr(x[1],1,10))==(cAliasAK2)->AK2_PERIOD})
								For nZ	:=	1	To Len(aPeriodos)
									nPosHead := aScan(aHeaderAk2,{|x| x[1]==aPeriodos[nZ]})
									If nPosHead > 0
										aColsAK2[Len(aColsAK2),nPosHead] := PcoPlanCel(&("P"+StrZero(nZ,2)),	(cAliasAK2)->AK2_CLASSE)
									EndIf
								Next
							Else
								nPosHead := aScan(aHeaderAk2,{|x| CTOD(Substr(x[1],1,10))==	(cAliasAK2)->AK2_PERIOD})
								If nPosHead > 0
									aColsAK2[Len(aColsAK2),nPosHead] := PcoPlanCel(	(cAliasAK2)->AK2_VALOR,	(cAliasAK2)->AK2_CLASSE)
									If (nPos := Ascan(aFormula, {|aVal|aVal[1]==Len(aColsAK2) .And. ;
																		aVal[2]==Alltrim(aHeaderAk2[nPosHead,1])})) == 0
										aAdd(aFormula, {Len(aColsAK2), Alltrim(aHeaderAk2[nPosHead,1]), 	(cAliasAK2)->AK2_FORMUL})
								    EndIf
								EndIf
							Endif
							//inicializa todos os periodos orcamentarios com CriaVar()
							//caso esteja preenchida, passa classe como parametro para montar o formato dos valores
							If aColsAK2[Len(aColsAK2),nY] == Nil
								If Empty( aColsAK2[Len(aColsAK2),nPosClasse] )
									aColsAK2[Len(aColsAK2),nY] := PcoPlanCel(CriaVar(aHeaderAk2[ny,2]))
								Else
									aColsAK2[Len(aColsAK2),nY] := PcoPlanCel(CriaVar(aHeaderAk2[ny,2]),aColsAK2[Len(aColsAK2),nPosClasse])
								EndIf
							Endif
						Case AllTrim(aHeaderAk2[ny,2])=="AK2_IDENT"
							If !Empty(	(cAliasAK2)->AK2_CHAVE )
								aAuxArea := GetArea()
								PcoPosAK6((cAliasAK2)->AK2_CLASSE)
								If !Empty(AK6->AK6_VISUAL)
									dbSelectArea(Substr(	(cAliasAK2)->AK2_CHAVE,1,3))
									dbSetOrder(If(!Empty(Substr(	(cAliasAK2)->AK2_CHAVE,4,2)), Val(Substr(	(cAliasAK2)->AK2_CHAVE,4,2)), 1))
									dbSeek(Substr(	(cAliasAK2)->AK2_CHAVE,6,Len(	(cAliasAK2)->AK2_CHAVE)))
									aColsAK2[Len(aColsAK2),ny] := &(AK6->AK6_VISUAL)
								EndIf
								RestArea(aAuxArea)
							EndIf
						Case AllTrim(aHeaderAk2[ny,2])=="AK2_DESCLA"
							aAuxArea := GetArea()
							If PcoPosAK6((cAliasAK2)->AK2_CLASSE )
								aColsAK2[Len(aColsAK2),ny] := AK6->AK6_DESCRI
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(aHeaderAk2[ny,2])=="AK2_UM"
							aAuxArea := GetArea()
							PcoPosAK6((cAliasAK2)->AK2_CLASSE)
							If !Empty(AK6->AK6_UM)
								If !Empty(	(cAliasAK2)->AK2_CHAVE)
									dbSelectArea(Substr(	(cAliasAK2)->AK2_CHAVE,1,3))
									dbSetOrder(Val(Substr(	(cAliasAK2)->AK2_CHAVE,4,2)))
									MsSeek(Substr(	(cAliasAK2)->AK2_CHAVE,6,Len(	(cAliasAK2)->AK2_CHAVE)))
								EndIf
								aColsAK2[Len(aColsAK2),ny] := &(AK6->AK6_UM)
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_DESCCO"
							AK5->(dbSetOrder(1))
							If AK5->(dbSeek(xFilial()+(cAliasAK2)->AK2_CO))
								aColsAK2[Len(aColsAK2)][ny] := AK5->AK5_DESCRI
							EndIf
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_DESCCC"
							CTT->(dbSetOrder(1))
							If CTT->(dbSeek(xFilial()+(cAliasAK2)->AK2_CC))
								aColsAK2[Len(aColsAK2)][ny] := CTT->CTT_DESC01
							EndIf
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_DESCIT"
							CTD->(dbSetOrder(1))
							If CTD->(dbSeek(xFilial()+(cAliasAK2)->AK2_ITCTB))
								aColsAK2[Len(aColsAK2)][ny] := CTD->CTD_DESC01
							EndIf
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_DESCCL"
							CTH->(dbSetOrder(1))
							If CTH->(dbSeek(xFilial()+(cAliasAK2)->AK2_CLVLR))
								aColsAK2[Len(aColsAK2)][ny] := CTH->CTH_DESC01
							EndIf
						OtherWise
							If ( aHeaderAk2[ny,10] != "V")
								aColsAK2[Len(aColsAK2),ny] := (cAliasAK2)->(&(aHeaderAk2[ny,2]))
							EndIf
					EndCase
				Next
				//Carregar as formulas
				If lQueryAK2
		   			cQuery	:=	" SELECT AK2_FORMUL, AK2_PERIOD FROM "+RetSqlName('AK2')+" AK2 "
			   		cQuery	+=	" WHERE AK2_FILIAL='"+xFilial('AK2')+"' AND AK2_ORCAME='"+QRYAK2->AK2_ORCAME+"' "
			   		cQuery	+=	" AND AK2_VERSAO='"+ QRYAK2->AK2_VERSAO +"' AND AK2_CO='"+ QRYAK2->AK2_CO +"' AND AK2_ID = '"+QRYAK2->AK2_ID+"' "
			   		cQuery	+=	" AND AK2_FORMUL <> '"+Space(Len(AK2->AK2_FORMUL))+"'  "
		   			cQuery	+=	" AND D_E_L_E_T_= ' ' "
   					cQuery	:=	ChangeQuery(cQuery)
	  				dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
					While !EOF()
						nPosHead := aScan(aHeaderAk2,{|x| Dtos(CTOD(Substr(x[1],1,10)))==QRYTRB->AK2_PERIOD})
						If nPosHead	>	0
							If (nPos := Ascan(aFormula, {|aVal| aVal[1] == Len(aColsAK2) .And. ;
																aVal[2]==Alltrim(aHeaderAk2[nPosHead,1])})) == 0
								aAdd(aFormula, {Len(aColsAK2), Alltrim(aHeaderAk2[nPosHead,1]), 	QRYTRB->AK2_FORMUL})
							Endif
						EndIf
						DbSkip()
					Enddo
					DbCloseArea()
				Endif
				aAdd(aRecAK2, { Len(aColsAK2), {}, QRYAK2->(AK2_CO+AK2_ID) } )
			EndIf
		Endif
		DbSelectArea(cAliasAK2)
		dbSkip()
	Enddo
Else
	//Monta Ordem, Seek, While, Filtro
	nOrdem := 5
	bSeek := {||xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+AK3->AK3_CO}
	bWhile := {||AK2->(!Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO == Eval(bSeek))}
	bFiltro := {||.T.}

	dbSelectArea("AK3")
	dbSetOrder(1)

	dbSelectArea("AK2")
	dbSetOrder(nOrdem)
	If dbSeek(Eval(bSeek))
		While AK2->(!Eof() .And. Eval(bWhile))
			lContinua := Eval(bFiltro)
		   If ! lContinua
			   AK2->(dbSkip())
			   Loop
			EndIf

			If nHeadCtaOrc > 0
				nPosIt	:= aScan(aColsAK2,{|x| x[nHeadItem]+x[nHeadCtaOrc] == AK2->AK2_ID+AK2->AK2_CO})
			Else
				nPosIt	:= aScan(aColsAK2,{|x| x[nHeadItem] == AK2->AK2_ID})
			EndIf
			If nPosIt > 0
				nPosHead := aScan(aHeaderAk2,{|x| CTOD(Substr(x[1],1,10))==AK2->AK2_PERIOD})
				If nPosHead > 0
					aColsAK2[nPosIt][nPosHead] := PcoPlanCel(AK2->AK2_VALOR,AK2->AK2_CLASSE)
					If (nPos := Ascan(aFormula, {|aVal|aVal[1]==nPosIt .And. ;
										aVal[2]==Alltrim(aHeaderAk2[nPosHead][1])})) == 0
				   		aAdd(aFormula, {nPosIt, Alltrim(aHeaderAk2[nPosHead][1]), AK2->AK2_FORMUL})
				    EndIf
				EndIf
				aAdd(aRecAK2[nPosIt, 2], AK2->(Recno()))
			Else
				aADD(aColsAK2,Array(Len(aHeaderAk2)+1))
				aColsAK2[Len(aColsAK2)][Len(aHeaderAk2)+1] := .F.

				For ny := 1 to Len(aHeaderAk2)
					Do Case
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_VAL"
							//inicializa todos os periodos orcamentarios com CriaVar()
							aColsAK2[Len(aColsAK2)][nY] := PcoPlanCel(CriaVar(aHeaderAk2[ny][2]))
	                        //depois atribue o valor que estiver na base de dados
							nPosHead := aScan(aHeaderAk2,{|x| CTOD(Substr(x[1],1,10))==AK2->AK2_PERIOD})
							If nPosHead > 0
								aColsAK2[Len(aColsAK2)][nPosHead] := PcoPlanCel(AK2->AK2_VALOR,AK2->AK2_CLASSE)
								If (nPos := Ascan(aFormula, {|aVal|aVal[1]==Len(aColsAK2) .And. ;
																	aVal[2]==Alltrim(aHeaderAk2[nPosHead][1])})) == 0
									aAdd(aFormula, {Len(aColsAK2), Alltrim(aHeaderAk2[nPosHead][1]), AK2->AK2_FORMUL})
							    EndIf
							EndIf
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_IDENT"
							If !Empty(AK2->AK2_CHAVE)
								aAuxArea := GetArea()
								AK6->(dbSetOrder(1))
								AK6->(dbSeek(xFilial()+AK2->AK2_CLASSE))
								If !Empty(AK6->AK6_VISUAL)
									dbSelectArea(Substr(AK2->AK2_CHAVE,1,3))
									dbSetOrder(If(!Empty(Substr(AK2->AK2_CHAVE,4,2)), Val(Substr(AK2->AK2_CHAVE,4,2)), 1))
									dbSeek(Substr(AK2->AK2_CHAVE,6,Len(AK2->AK2_CHAVE)))
									aColsAK2[Len(aColsAK2)][ny] := &(AK6->AK6_VISUAL)
								EndIf
								RestArea(aAuxArea)
							EndIf
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_DESCLA"
							aAuxArea := GetArea()
							AK6->(dbSetOrder(1))
							If AK6->(dbSeek(xFilial()+AK2->AK2_CLASSE))
								aColsAK2[Len(aColsAK2)][ny] := AK6->AK6_DESCRI
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_UM"
							AK6->(dbSetOrder(1))
							AK6->(dbSeek(xFilial()+AK2->AK2_CLASSE))
							aAuxArea := GetArea()
							If !Empty(AK6->AK6_UM)
								If !Empty(AK2->AK2_CHAVE)
									dbSelectArea(Substr(AK2->AK2_CHAVE,1,3))
									dbSetOrder(Val(Substr(AK2->AK2_CHAVE,4,2)))
									dbSeek(Substr(AK2->AK2_CHAVE,6,Len(AK2->AK2_CHAVE)))
								EndIf
								aColsAK2[Len(aColsAK2)][ny] := &(AK6->AK6_UM)
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_DESCCO"
							aAuxArea := GetArea()
							AK5->(dbSetOrder(1))
							If AK5->(dbSeek(xFilial()+AK2->AK2_CO))
								aColsAK2[Len(aColsAK2)][ny] := AK5->AK5_DESCRI
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_DESCCC"
							aAuxArea := GetArea()
							CTT->(dbSetOrder(1))
							If CTT->(dbSeek(xFilial()+AK2->AK2_CC))
								aColsAK2[Len(aColsAK2)][ny] := CTT->CTT_DESC01
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_DESCIT"
							aAuxArea := GetArea()
							CTD->(dbSetOrder(1))
							If CTD->(dbSeek(xFilial()+AK2->AK2_ITCTB))
								aColsAK2[Len(aColsAK2)][ny] := CTD->CTD_DESC01
							EndIf
							RestArea(aAuxArea)
						Case AllTrim(aHeaderAk2[ny][2])=="AK2_DESCCL"
							aAuxArea := GetArea()
							CTH->(dbSetOrder(1))
							If CTH->(dbSeek(xFilial()+AK2->AK2_CLVLR))
								aColsAK2[Len(aColsAK2)][ny] := CTH->CTH_DESC01
							EndIf
							RestArea(aAuxArea)
						OtherWise
							If ( aHeaderAk2[ny][10] != "V")
								aColsAK2[Len(aColsAK2)][ny] := FieldGet(FieldPos(aHeaderAk2[ny][2]))
							EndIf
					EndCase
				Next
				aAdd(aRecAK2, { Len(aColsAK2), {AK2->(Recno())} } )
			EndIf
			dbSkip()
		End
	EndIf
Endif

If Empty(aColsAK2) .and. !lAuto
	aadd(aColsAK2,Array(Len(aHeaderAk2)+1))
	For ny := 1 to Len(aHeaderAk2)
		If AllTrim(aHeaderAk2[ny][2])=="AK2_ID"
			aColsAK2[1][ny] := Padr("*", Len(AK2->AK2_ID))
		ElseIf AllTrim(aHeaderAk2[ny][2])=="AK2_VAL"
			//inicializa todos os periodos orcamentarios com CriaVar()
			aColsAK2[1][nY] := PcoPlanCel(CriaVar(aHeaderAk2[ny][2]))
		Else
			aColsAK2[1][ny] := CriaVar(aHeaderAk2[ny][2])
		EndIf
	Next ny
EndIf

If lQueryAK2
	DbSelectArea("QRYAK2")
	DbCloseArea()
EndIf
DbSelectArea("AK2")

RestArea(aAreaAK3)
RestArea(aArea)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoxAK2LinOK³ Autor ³ Edson Maricate      ³ Data ³ 17-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da LinOK da Getdados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoxAK2LinOK()
Local lRet			:= .T.
Local nPosOper		:= aScan(aHeaderAK2,{|x|AllTrim(x[2])=="AK2_OPER"})
Local nPosClasse	:= aScan(aHeaderAK2,{|x|AllTrim(x[2])=="AK2_CLASSE"})
Local nPosChave	:= aScan(aHeaderAK2,{|x|AllTrim(x[2])=="AK2_CHAVE"})
Local cClasse
Local cOper

If nMvPar != 4 .Or. nPosClasse > 0
	cClasse := aColsAk2[n][nPosClasse]
Else
	cClasse := M->AK2_CLASSE
EndIf

If nMvPar != 4 .Or. nPosOper > 0
	cOper := aColsAk2[n][nPosOper]
Else
	cOper := M->AK2_OPER
EndIf

dbSelectArea("AK6")
dbSetOrder(1)
PcoPosAK6(cClasse)
//dbSeek(xFilial()+cClasse)

If AK6->AK6_OBRIGA=="1" .And. Empty(aColsAk2[n][nPosChave])
	HELP("  ",1,"PCONOCHAVE")
	lRet	:= .F.
EndIf

If lRet .And. AK6->AK6_OPER=="1" .And. Empty(cOper)
	HELP("  ",1,"PCONOOPER")
	lRet	:= .F.
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos obrigatorios do SX3.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	lRet := MaCheckCols(aHeaderAK2,aColsAk2,n)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa ponto de entrada para validacoes adicionais na linha da planilha editada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If ExistBlock("PCOAK2LOK")
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para validacao da linha de digitacao do     ³
		//P_E³ orcamento                                                              ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : .F. - Deve bloquear a linha de digitacao                  ³
		//P_E³              .T. - Liberar a linha digitada                            ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := ExecBlock("PCOAK2LOK",.F.,.F.)
	EndIf
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoxAK2TudoK³ Autor ³ Alexandre Circenis  ³ Data ³ 09/04/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados Automatica                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PCOXFUN                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoxAK2TudoK()

Local lRet			:= .T.
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOVLDLIM ºAutor	³ Abel Ribeiro    	 º Data ³  18/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida Limite das Contas Orcamentarias                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOLIMAUTO(aHeader, Acols,cCodConta,cCodPlan,nValTot,lAtu)

	Local cQuery 		:= ""
	Local nvalor 		:= 0
	Local lRet   		:= .T.
	Local nValDig    	:= 0
	Local cAliasTRB  	:= "TRB"
	LOcal aArea         := GetArea()
	Local aAreaAMX  	:= AMX->(GetArea())
	Local nXy,Nx,nCntFor2

	Default nValTot := 0
    Default lAtu := .T.

    DbSelectArea("AMX")
    AMX->(DbSetOrder(2))

	If AMX->(DbSeek(xFilial("AMX")+cCodPlan))

		DbSelectArea("AMV")
		AMV->(DbSetOrder(1))
		If AMV->(DbSeek(xFilial("AMV")+AMX->AMX_CODIGO+cCodConta))
			//Soma os Valores do Acols
			//ACHAR AS COLUNAS DE VALOR
			aHeadVal := {}
			For nX := 1 To Len(aHeader)
			    If AllTrim(aHeader[nX,2]) == "AK2_VAL"
				   AADD(aHeadVal,{nX,DTOS(CTOD(Substr(aHeader[nX][1],1,10)))})
			    Endif
		    Next nX

			For nXy := 1 To Len(oGD:aCols)
				For nCntFor2 := 1 to LEN(aHeadVal)
					nPosVal	:=	aHeadVal[nCntFor2,1]
				   	nValDIG += PcoPlanVal(aCols[nXy][nPosVal],aCols[nXy,5]) //VAL(oGD:aCols[nXy][nPosVal])
			    Next nCntFor2
			Next nXy

			cQuery := "SELECT SUM(AMV_LIMITE) AS LIMITE
			cQuery += " FROM " + RetSqlName("AMV")+" AMV"
			cQuery += " LEFT JOIN " + RetSqlName("AMX")+" AMX"
			cQuery += " ON(
			cQuery += " AMV.AMV_PROJOR = AMX.AMX_CODIGO"
			cQuery += " AND AMX.D_E_L_E_T_ = ' '"
			cQuery += " AND AMX.AMX_FILIAL = '"+xFilial("AMX")+"'"
			cQuery += " )"
			cQuery += " WHERE AMV.AMV_FILIAL='"+xFilial("AMV")+"'"
			cQuery += " AND AMV_CODCON='"+cCodConta+ "'"
			cQuery += " AND AMX_PLNORC='"+cCodPlan +"'"
			cQuery += " AND AMV.D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAliasTRB,.F.,.T. )

		    IF (cAliasTRB)->( !EOF() )
		       nValor := (cAliasTRB)->LIMITE
		    ENDIF

		    (cAliasTRB)->(dbCloseArea())

		    IF nValDig > nvalor
		    HELP("   ",1,"PCOLIM",, STR0101 + CRLF +; // ### "O Soma dos valores para esta Conta Orçamentária excedeu o valor limite do Projeto"
				STR0102 + Transform(nValDig,"@E 999,999,999.99") +CRLF+; // "Valor do Período:"
				STR0103 + Transform(nvalor,"@E 999,999,999.99") ,3,0) // "Valor Limite:"
				lRet := .F.

			EndIf
  		Endif
	EndIf
	RestArea(aAreaAMX)
	RestArea(aArea)
Return(lRet)

Static Function GetFldValue(cField)
Local cVarName := cEmpAnt + "__GLB" + cField
Local cCache := GetGlbValue(cVarName)
Local aRet := {"","","","",""}
Local cVldUser

/*
procura no AP6SRV.INI chave para desabilitar validacao do usuario
[AUTOVLDUSER]
enable=0
*/

If lAutoVldUser == NIL
	lAutoVldUser := (GetPvProfString("AUTOVLDUSER","ENABLE","1",GetADV97()) == "1")
EndIf

If nLenX3VALID == NIL
	nLenX3VALID	:= Len(SX3->X3_VALID)
	nLenX3VLDUSER	:= Len(SX3->X3_VLDUSER)
	nLenX3TRIGGER	:= Len(SX3->X3_TRIGGER)
	nLenX3TITULO	:= Len(X3Titulo())
	nLenX3RELACAO	:= Len(SX3->X3_RELACAO)
	nLenX3ARQUIVO := Len(SX3->X3_ARQUIVO)
EndIf

If Empty(cCache)
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek(cField)

	cCache := SX3->X3_VALID + SX3->X3_VLDUSER + SX3->X3_TRIGGER + X3Titulo() + SX3->X3_RELACAO + SX3->X3_ARQUIVO
	PutGlbValue(cVarName,cCache)
EndIf

cVldUser := Subs(cCache,1 + nLenX3VALID,nLenX3VLDUSER)

aRet[1] := Subs(cCache,1,nLenX3VALID)
aRet[1] := If(Empty(aRet[1]),".T.",aRet[1])
aRet[1] += If(!lAutoVldUser .or. Empty(cVldUser),""," .and. " + cVldUser)
aRet[2] := Subs(cCache,1 + nLenX3VALID + nLenX3VLDUSER,nLenX3TRIGGER)
aRet[3] := Subs(cCache,1 + nLenX3VALID + nLenX3VLDUSER + nLenX3TRIGGER,nLenX3TITULO)
aRet[4] := Subs(cCache,1 + nLenX3VALID + nLenX3VLDUSER + nLenX3TRIGGER + nLenX3TITULO,nLenX3RELACAO)
aRet[5] := Subs(cCache,1 + nLenX3VALID + nLenX3VLDUSER + nLenX3TRIGGER + nLenX3TITULO + nLenX3RELACAO,nLenX3ARQUIVO)
Return aRet

Static Function EvalValid(cValid,cMsg,lEnchAuto)
Local lRet := .T.
Local lErro := .F.
Local bErro := ErrorBlock({|e| lErro := .T.,cMsg := ErrMessage(e)})

Default cMsg := ""

BEGIN SEQUENCE
lRet := &(cValid)
END SEQUENCE

ErrorBlock(bErro)

If lErro
	lRet := .F.
ElseIf ValType(lRet) <> "L"

	//SE O RETORNO NAO FOR LOGICO A VALIDACAO RETORNARA
	//VERDADEIRO POR COMPATIBILIDADE COM A ENCHOICE PADRAO
	If lEnchAuto
		lRet := .T.
	Else
		lRet := .F.		
		cMsg := "Retorno invalido da validacao. "
	EndIf
EndIf
Return lRet

Static Function ErrMessage(e)
Local cErrMessage := "Ocorreu um erro durante a validacao:" + CRLF

cErrMessage += e:Description + " on " + ProcName(2) + " line : " + AllTrim(Str(ProcLine(2))) + CRLF
i := 3
While !Empty(ProcName(i))
	cErrMessage += "Called from " + ProcName(i) + " line : " + AllTrim(Str(ProcLine(i))) + CRLF
	i++
End
Return cErrMessage

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoAoolIt ³ Autor ³ Edson Maricate        ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de gravacao dos itens da planilha orcamentaria         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoAoolIt(cVersao, aCols, aRecNoVisible)

Local aArea				:= GetArea()
Local nHeadItem			:= aScan(aHeader,{|x| AllTrim(x[2])=="AK2_ID"})
Local aRecAK2			:= {}
Local nCntFor3			:= 0
Local nCntFor2			:= 0
Local nCntFor			:= 0
Local aItensOrcNoVisible:= {}, nX, aItensNew := {}, nPosAK2 := 0
Local cAK2Id   			:= Space(Len(AK2->AK2_ID))
Local cItemAK2 			:= Space(Len(AK2->AK2_ID))
Local nPos 				:= 0
Local aRecProc			:=	{}
Local nLenCols			:= Len(aCols)
Local nLenHeader		:= Len(aHeader)
Local nPosClasse		:= aScan(aHeader,{|x|AllTrim(x[2])=="AK2_CLASSE"})
Local lChanged			:=	.F.
Local lMudou			:=	.F.
Local lNewRec			:=	.F.
Local cContaIn 			:= ""
Local nLastNoVisID		:= ""
Local nLastAColsID		:= ""
Local nLastID			:= ""
Local aContas 			:= {}
Local aItensCols		:= {}
Local nN_			    := 0
Local aStruct 			:= {}
Local lRetPe            := .F.
Local cChvLck			:= ""

Local lQryAK2 := ( TcGetDb() # "AS/400" .and. TCGetDB()!="SYBASE" )

//posiciona em AK3
//AK3->(DbSetorder(1))
//AK3->(DbSeek(xFilial("AK3")+AK1->AK1_CODIGO+cVersao+(cArquivo)->XK3_CO))

//bloqueia a conta orcamentaria
Do While !LockByName(xFilial("AK3")+AK1->AK1_CODIGO+cVersao+AK3->AK3_CO,.T.,.T.,.T.)
//	AvisoTimer(STR0021,	STR0091 +;	// "Aguardando o término da gravação dos itens da conta "
//						RTrim((cArquivo)->XK3_CO) + STR0092,{"Ok"},,;	// " por outro usuário."
//						STR0093,,"PCOLOCK",5000)	//"Conta Orçamentária em uso"

EndDo

cContaIn := ""
Pco_Sup_Cta( AK3->AK3_CO, aContas, cVersao)
For nX := 1 TO Len(aContas)
	cContaIn +=  "'"+aContas[nX]+If(nX!=Len(aContas), "',", "'")
Next

If Empty(cContaIn)  //isto somente vai ocorrer quando usuario excluir a
        					//conta orcamentaria em outra sessao
   	Aviso(STR0022, STR0084, {"Ok"})  //"Atencao"##"Conta Orcamentaria nao encontrada, portanto as alteracoes nao foram gravadas. Verifique!!"
   	Return  // lContinua := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo AK2 (Itens)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AK2")

//ACHAR AS COLUNAS DE VALOR
aHeadVal	:=	{}
For nX := 1 To Len(aHeader)
	If AllTrim(aHeader[nX,2]) == "AK2_VAL"
		AADD(aHeadVal,{nX,		DTOS(CTOD(Substr(aHeader[nX][1],1,10)))})
	Endif
Next
nLenHeadVal	:=	Len(aHeadVal)

//ProcRegua((nLenCols*nLenHeadVal)+Len(aRecAK2))
If Len(aRecNoVisible) > 998 //Tratamento p/ evitar erro abaixo, No Oracle o maximo de elementos para IN é 1000.
                            //: Error : 1795 - ORA-01795: maximum number of expressions in a list is 1000
	If TCCanOpen("AK2TMP")
		TCDelFile("AK2TMP")
	EndIf

	AAdd(aStruct, {"RECNO_","N",10,0})

		DbCreate("AK2TMP",aStruct,"TOPCONN")
		DbUseArea(.T., "TOPCONN", "AK2TMP", "AK2TMP", .T.,.F.)
		DbSelectArea("AK2TMP")


	For nN_ := 1 TO Len(aRecNoVisible)
		Reclock("AK2TMP",.T.)
		RECNO_ := aRecNoVisible[nN_]
		MsUnlock("AK2TMP")
	Next

	AK2TMP->(DbGoTop())

EndIf

dbSelectArea("AK2")
For nX := 1 TO Len(aRecNoVisible)
    MsGoto(aRecNoVisible[nX])
    If Ascan(aItensOrcNoVisible, AK2->AK2_ID)==0
    	aAdd(aItensOrcNoVisible, AK2->AK2_ID)
    EndIf
Next

If lQryAK2
	cQuery	:=	" SELECT R_E_C_N_O_ RECNO,Max(AK2_ID) AK2_ID FROM "+RetSqlName('AK2')+" AK2 "
	cQuery	+=	" WHERE AK2_FILIAL='"+xFilial('AK2')+"' AND AK2_ORCAME='"+AK1->AK1_CODIGO+"' "
	cQuery	+=	" AND AK2_VERSAO='"+ cVersao +"' AND AK2_CO='"+ AK3->AK3_CO +"' "
	If Len(aRecNoVisible) > 998
		cQuery	+=	" AND R_E_C_N_O_ NOT IN (SELECT RECNO_ FROM AK2TMP)"
 	ElseIf Len(aRecNoVisible) > 0
		cQuery	+=	" AND R_E_C_N_O_ NOT IN ("
		For nX := 1 TO Len(aRecNoVisible)
			cQuery	+=	Alltrim(STR(aRecNoVisible[nX]))+","
		Next nX
		cQuery	:=	Substr(cQuery,1,Len(cQuery)-1)+")"
	Endif
	cQuery	+=	" AND D_E_L_E_T_= ' ' GROUP BY R_E_C_N_O_"
	cQuery	+=	" ORDER BY AK2_ID"
	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
	cAK2Id := QRYTRB->AK2_ID
	While !Eof()
		aAdd(aRecAK2,QRYTRB->RECNO)
		cAK2Id := QRYTRB->AK2_ID
		DbSkip()
	Enddo
	DbCloseArea()
    If Len(aRecNoVisible) > 998
    	AK2TMP->(DbClosearea())
		If TCCanOpen("AK2TMP")
			TCDelFile("AK2TMP")
		EndIf
    EndIf
Else
	dbSelectArea("AK2")
	dbSetOrder(5)
	dbSeek(xFilial("AK2") + AK1->AK1_CODIGO + cVersao + AK3->AK3_CO )
	While !Eof() .And. AK2->AK2_FILIAL + AK2->AK2_ORCAME + AK2->AK2_VERSAO + AK2->AK2_CO  == ;
						xFilial("AK2") + AK1->AK1_CODIGO + cVersao + AK3->AK3_CO
		If Ascan(aRecNoVisible, AK2->(RecNo()))==0
			aAdd(aRecAK2,AK2->(RecNo()))
		EndIf
		cAK2Id := AK2->AK2_ID
		dbSkip()
	End
EndIf

Begin Transaction
nTimeVer := 0
nSeek2	:=	0
aRecProc	:=	{}

For nCntFor := 1 to nLenCols

	If !aCols[nCntFor][Len(aCols[nCntFor])]

		cItemAK2 := Padr(aCols[nCntFor][nHeadItem],Len(AK2->AK2_ID))
	    //somente entra quando em alteracao da linha
		cChvLck := AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+cItemAK2

		IF	!PcoLockAK2(cChvLck,.F.,)
			HELP("   ",1,"LOCKAK2",,STR0086+CRLF+STR0087,3,0)
        endif

		//tem que estar posicionado em AK3 (cChvIt)- se o item do orcamento nao for inclusao e
		//nao estiver lockado logicamente com lockbyname
		//avancar para o proximo item
		cChvIt := AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+aCols[nCntFor, nHeadItem]
		If cItemAK2 != PadR("*", Len(AK2->AK2_ID)) .And. ;
			Ascan(aLocksAK2,{|x| x ==cChvIt }) == 0
			dbSelectArea("AK2")
			dbSetOrder(5)
			For nCntFor2 := 1 to nLenHeadVal
				If MsSeek(xFilial("AK2") + AK1->AK1_CODIGO + cVersao + AK3->AK3_CO +cItemAK2+aHeadVal[nCntFor2,2])
					Aadd(aRecProc, AK2->(Recno()))
				EndIf
			Next
			Loop
		EndIf

		// Bloco para renumerar AK2_ID se existir em registros nao visiveis

		If cItemAK2 != PadR("*", Len(AK2->AK2_ID)) .And. ;
			Ascan(aItensOrcNoVisible, cItemAK2) > 0
			If (nPosAK2 := Ascan(aItensNew, {|aVal|aVal[1]==cItemAK2})) == 0
				cAk2Id := StrZero(Val(cAk2Id)+1, Len(AK2->AK2_ID))
			 	aAdd(aItensNew, {cItemAK2, cAk2Id})
			   cItemAK2 := cAk2Id
			Else
			   cItemAK2 := aItensNew[nPosAK2][2]
			EndIf

			aCols[nCntFor][nHeadItem] := cItemAK2
		Else
			If cItemAK2 == PadR("*", Len(AK2->AK2_ID)) .And. ;
				(nPosAK2 := Ascan(aItensNew, {|aVal|aVal[2]==cItemAK2})) == 0
				If Len(aRecNoVisible) > 0
					aItensCols := {}
					For nPos := 1 To nLenCols
						AAdd(aItensCols, aCols[nPos,1])
					Next nPos

					// Encontra ID maximo entre itens nao visiveis em outro usuario com restricao de
					// acesso e itens jah carregados no aCols
					nLastNoVisID := Val(aSort( aItensOrcNoVisible,,, {|x,y| x > y } )[1])
					nLastAColsID := Val(aSort( aItensCols,,, {|x,y| x > y } )[1])
					nLastID	:= Max( Max( nLastNoVisID, nLastAColsID ), Val(cAk2Id ) )
					// Incrementa cAk2ID a partir do maximo ID encontrado
					cAk2Id := StrZero(nLastID+1, Len(AK2->AK2_ID))
				Else
					cAk2Id := StrZero(Val(cAk2Id)+1, Len(AK2->AK2_ID))
				EndIf
			   aAdd(aItensNew, {cItemAK2, cAk2Id})
			   cItemAK2 := cAk2Id

			    While aScan(aCols,{|x| x[nHeadItem] = cItemAK2 }) <> 0
			    	cItemAK2 := Soma1(cItemAK2)
			    EndDo

		    EndIf

		    aCols[nCntFor][nHeadItem] := cItemAK2
		EndIf

		// Fim do bloco para renumerar
		AK2->(DbSetOrder(1))
		dbSelectArea("AK2")
		dbSetOrder(5)

		For nCntFor2 := 1 to nLenHeadVal
			IncProc()
			lChanged	:=	.F.
			nPosVal	:=	aHeadVal[nCntFor2,1]

			AK2->(DbSetOrder(1))
			dbSelectArea("AK2")
			dbSetOrder(5)
			If MsSeek(xFilial("AK2") + AK1->AK1_CODIGO + cVersao + AK3->AK3_CO +cItemAK2+aHeadVal[nCntFor2,2])
				Aadd(aRecProc, AK2->(Recno()))
				//Verificar se mudou o valor antes de  continuar.
				If PcoPlanVal(aCols[nCntFor,nPosVal],AK2->AK2_CLASSE) <> AK2->AK2_VALOR
					lChanged := .T.
				Endif
				//Verificar se mudou algum campo antes de continuar.
				//Se nao mudou nao sera refeito o lancamento
				If !lChanged
					For nCntFor3 := 1 To nLenHeader
						If ( aHeader[nCntFor3,10] != "V" ) .And. AllTrim(aHeader[nCntFor3,2]) != "AK2_VAL"
							If AK2->(FieldGet(FieldPos(aHeader[nCntFor3,2]) )) <> aCols[nCntFor,nCntFor3]
								lChanged	:=	.T.
								Exit
							Endif
						ElseIf AllTrim(aHeader[nCntFor3,2]) == "AK2_VAL"
							If (nPos := Ascan(aFormula, {|aVal|aVal[1]==nCntFor .And. ;
								aVal[2]==Alltrim(aHeader[nCntFor3][1])})) >  0 .And. Alltrim(AK2->AK2_FORMUL) <> Alltrim(aFormula[nPos][3])
								lChanged	:=	.T.
								Exit
							Endif
						EndIf
					Next nCntFor3
				Endif

				If ExistBlock("PCOGRVITPL")
					lRetPe := ExecBlock("PCOGRVITPL",.F.,.F.)
				EndIf


				If !lChanged .and. !lRetPe
				 	Loop
				Endif

				RecLock("AK2",.F.)
				lNewRec	:=	.F.
			Else
				//So criar um registro novo se o valor e diferente de zero  ou se tiver formula para a coluna
				If PcoPlanVal(aCols[nCntFor][nPosVal],aCols[nCntFor,nPosClasse]) <> 0 .Or.;
					! MsSeek( xFilial("AK2") + AK1->AK1_CODIGO + cVersao + AK3->AK3_CO +cItemAK2 ) .Or. ;
					 (nPos := Ascan(aFormula, {|aVal|aVal[1]==nCntFor .And. ;
						aVal[2]==Alltrim(aHeader[nPosVal][1])})) >  0 .And. !Empty(Alltrim(aFormula[nPos][3]))
					RecLock("AK2",.T.)
					lNewRec	:=	.T.
				Else
					Loop
				Endif
			EndIf


			lMudou	:=	.F.

			For nCntFor3 := 1 To nLenHeader
				If ( aHeader[nCntFor3][10] != "V" ) .And. AllTrim(aHeader[nCntFor3][2]) != "AK2_VAL"
					If !lNewRec .And. !lMudou .And. AK2->(FieldGet(FieldPos(aHeader[nCntFor3][2])) <> aCols[nCntFor][nCntFor3])
						lMudou	:=	.T.
					Endif
					AK2->(FieldPut(FieldPos(aHeader[nCntFor3][2]),aCols[nCntFor][nCntFor3]))
				EndIf
			Next nCntFor3

			If !lNewRec .And. !lMudou .And. AK2->AK2_VALOR		<> PcoPlanVal(aCols[nCntFor][nPosVal],AK2->AK2_CLASSE)
				lMudou	:=	.T.
			Endif

			AK2->AK2_FILIAL	:= xFilial("AK2")
			AK2->AK2_ORCAME	:= AK1->AK1_CODIGO
			AK2->AK2_VERSAO	:= cVersao
			AK2->AK2_CO			:= AK3->AK3_CO
			AK2->AK2_VALOR		:= PcoPlanVal(aCols[nCntFor][nPosVal],AK2->AK2_CLASSE)
			AK2->AK2_PERIOD	:= CTOD(Substr(aHeader[nPosVal][1],1,10))
			AK2->AK2_DATAI		:= CTOD(Substr(aHeader[nPosVal][1],1,10))
			AK2->AK2_DATAF		:= CTOD(Substr(aHeader[nPosVal][1],14,16))
			If (nPos := Ascan(aFormula, {|aVal|aVal[1]==nCntFor .And. ;
								aVal[2]==Alltrim(aHeader[nPosVal][1])})) >  0
				AK2->AK2_FORMUL := aFormula[nPos][3]
			EndIf
			MsUnlock()

			If ExistBlock("PCOAK2GRV")
		   		ExecBlock("PCOAK2GRV",.F.,.F.)
   			EndIf

			AK3->(DbSetorder(1))
			AK3->(DbSeek(xFilial()+AK2->(AK2_ORCAME+AK2_VERSAO+AK2_CO)))

			PcoUnLockAK2(AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+AK2->AK2_ID )

			//Condicoes para fazer lancamento:
				//-Lancar quando algum campo mudou (com execao da formula) e nao um registro novo
			   //-Se e um novo registro, que o valor seja <> de 0
			If (lMudou .And. !lNewRec) .Or. (lNewRec .And. AK2->AK2_VALOR <> 0 )
				If lSimulac
					PcoDetLan("000252","03","PCOA100")
				ElseIf lRevisao
					PcoDetLan("000252","02","PCOA100")
				Else
					PcoDetLan("000252","01","PCOA100")
				EndIf
			Endif
		Next nCntFor2
	EndIf
Next  nCntFor

If Len(aRecProc) < Len(aRecAK2)
	For nCntFor := 1 to Len(aRecAK2)
		IncProc()

		If Ascan(aRecProc,aRecAK2[nCntFor]) == 0
			// Se eh um item jah gravado e incluso por outro usuario (nao estah na aCols), entao nao deve excluir.
			AK2->( dbGoto(aRecAK2[nCntFor] ) )
			nPos := aScan( aCols, { |x| x[nHeadItem] == AK2->AK2_ID } )

			If (nPos <> 0)
				If lSimulac
					PcoDetLan("000252","03","PCOA100",.T.)
				ElseIf lRevisao
					PcoDetLan("000252","02","PCOA100",.T.)
				Else
					PcoDetLan("000252","01","PCOA100",.T.)
				EndIf

				If ExistBlock("PCODelItm")
					 ExecBlock("PCODelItm",.F.,.F.)
   				EndIf

				RecLock("AK2",.F.,.T.)
				dbDelete()
				MsUnlock()

			EndIf
		Endif

	Next
EndIf

End Transaction

// Libera conta orcamentaria
UnLockByName(xFilial("AK3")+AK1->AK1_CODIGO+cVersao+AK3->AK3_CO,.T.,.T.,.T.)

AK3->(MsUnlockAll())  //libera registro travado com softlock para garantir integridade

RestArea(aArea)
Return

//-------------------------------------
/*/{Protheus.doc}PCOValidF
Função de validação para a fórmula executada.
@author William Matos Gundim Junior
@since  30/07/2014
@version P12
/*/
Function PCOValidF(cFormula)
Local xResult,cForm,cStrForm, cAlias, aAlias := {}
Local bBlock:=ErrorBlock(),bErro := ErrorBlock( { |e| ChecErro(e) } )
Local i, cSavAlias := Alias()
Local cNomeRot := ''
Local lRet := .T.
Default cFormula := ""

cForm:=cFormula
cStrForm := UPPER(cForm)
For i:= 1 to Len(cStrForm)
	nPos := At("_",cStrForm)
	If nPos == 0
		Exit
	EndIf
	If Substr(cStrForm,nPos-3,1)$(">()-+*/[]{}'"+'"')
		cAlias := "S"+Subs(cStrForm,nPos-2,2)
	Else
		cAlias := Subs(cStrForm,nPos-3,2)
	EndIf
	If Select(cAlias) == 0 .and. ASCAN(aAlias,cAlias) == 0
		AADD(aAlias,cAlias)
	EndIf
	cStrForm := Substr(cStrForm,nPos+1,Len(cStrForm))
Next

BEGIN SEQUENCE

	xResult := &cForm

	For i:= 1 to Len(aAlias)
		If Select(aAlias[i]) > 0
			DbSelectArea(aAlias[i])
			DbCloseArea()
		EndIf
	Next
RECOVER

	lRet := .F.

END SEQUENCE


DbSelectArea(cSavAlias)
ErrorBlock(bBlock)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  02/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BrwSize(oObj,nBorder)
Local nRet

DEFAULT nBorder	:= 70

oObj:CoorsUpdate()
nRet := (oObj:nRight-oObj:nLeft)-nBorder


Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOXFUN   ºAutor  ³Microsiga           º Data ³  21/08/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoxGD1DelOK()
Local lEdit := .T.

lEdit := PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,3,"ITENS",cRevisa)

Return lEdit
