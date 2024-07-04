#INCLUDE "CTBA800.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'DBTREE.CH'

#Define BMPINCLUIR  	"BMPINCLUIR.PNG"
#Define BMPALTERAR 		"NOTE.PNG"
#Define BMPEXCLUIR 		"EXCLUIR.PNG"
#Define BMPCONFIRMAR 	"OK.PNG"
#Define BMPCANCELAR 	"CANCEL.PNG"
#Define BMPCOPIAR 		"S4WB005N.PNG"
#Define BMPCOLAR 		"S4WB007N.PNG"
#Define BMPPESQUISA  	"PESQUISA.PNG"
#Define BMPFILTRO	  	"FILTRO.PNG"
#Define BMPCAMPO	  	"BMPCPO.PNG"
#Define BMPSAIR	  		"FINAL.PNG"

#Define X_ALIAS Left( oTree:GetCargo(), 3)
#Define X_RECNO CtbRecnCT0( Right(oTree:GetCargo(),2) )
Static __aLstBox
Static __aViewBox
Static __aRecnoBox

// Verifica se existem as fun็๕es e se o ATFA051 estแ configurado no Adapter do Scheduler no Configurador
Static __lEAI800A 	:= FWHasEAI("CTBA800A",.T.,,.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA800   บAutor  ณMicrosiga           บ Data ณ  03/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria็ใo e edi็ใo das entidades                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBA800(aRotAuto,nOpcAuto)
Local oFont
Local oSize 		:= Nil
Local nX
Local nRecCT0
Local cAlias
Local cCpoSup
Local cCpoChv
Local cCpoDsc
Local cEntida
Local lCV0

Local cNumPlano 	:= "" //Variavel utilizada na montagem da แrvore armazenando o n๚mero do plano


Local bPosiciona 	:= {|| 	dbSelectArea(X_ALIAS), ;
							nRecCT0 := X_RECNO, ;
							If(nRecCT0>0, ;
								dbGoto(nRecCT0), ;
								NIL ;
							  ) ;
						}

Local bReg_Memory 	:= {|cAlias, lGet_Incl | 	lGet_Incl := If(lGet_Incl == NIL,  .F., lGet_Incl), ;
												dbSelectArea(cAlias), ;
												RegToMemory(cAlias,lGet_Incl) }

Local  bAtlz_Ench 	:= { |oEnch, cAlias, lGet_Incl | 	Eval(bReg_Memory,cAlias,lGet_Incl), ;
														oEnch:EnchRefreshAll() }

Local bEnchCT0 		:= {|| Eval(bAtlz_Ench, oGetCT0, "CT0"), cPlano := CT0->CT0_ENTIDA }
Local bDescCT0 		:= {|| Alltrim(CT0->CT0_ID)+ " - " + Alltrim(CT0->CT0_DESC) }

Local abDescrEnt	:= {}
Local abSeekEnt		:= {}
Local abWhileEnt	:= {}
Local abTree		:= {}

//Bot๕es da oWin01
Local bAlterar 		:= {|| 	If( Left(oTree:GetCargo(),3) != "{|}", ;
									(;
										Eval(bReg_Memory,"CT0",.F.),  ;
										oBarEntid3:Show(), ;
										Inclui := .F. ,;
										Altera := .T. ,;
										Exclui := .F. ,;
										CtbDestroyGet(oGetCT0), ;
										oWin01:disable(),;
										oGetCT0 := CtbCreateGet("CT0", 4, 4, oWin02 ), ;
									    oGetCT0:oBox:Align := CONTROL_ALIGN_ALLCLIENT, ;
								    ), ;
								    (;
										MsgInfo(STR0012,STR0013) ; //"Selecione uma entidade"###"Aten็ใo!"
									);
							);
						}

Local bSair    		:= {|| 	oDlg:End() }

Local bIncluir 		:= {||}

//Bot๕es da oWin03 - Arvore configura็ใo
Local nValCT0Id
Local nRecnoEnt
Local cAliasEnt
Local nOpcEnt := 0
Local bVisuEntid 	:= {|| 	nOpcEnt := 2 ,;
							A800VerRec(oTree, @nRecnoEnt, @nValCT0Id, aTreeEnt),;
							cAliasEnt := CT0->CT0_ALIAS, ;
							If( nRecnoEnt > 0, ;  //Valida็ใo para exibir os dados somente quando uma configura็ใo for selecionada
								( ;
									oBtEntV:Disable(), ;
									oBtEntI:Disable(), ;
									oBtEntA:Disable(), ;
									oBtEntE:Disable(), ;
									dbSelectArea(cAliasEnt), ;
									dbGoto(nRecnoEnt), ;
									Eval(bReg_Memory,cAliasEnt,.F.), ;
									oWin01:disable(),;
									oGetEnt := CtbCreateGet(cAliasEnt, 2, 2, oWin04, , CT0->CT0_CPOSUP), ; // Cria a Enchoice
									oBarEntid2:Show(), ;
									oGetEnt:oBox:Align := CONTROL_ALIGN_ALLCLIENT, ;
									oFWLayer:WinChgState("Col02", "Win03"), ;        //Minimiza a arvore de configura็ใo da entidade
									Eval(bAtlz_Ench, oGetCT0, "CT0") ;
								),; //Atualiza a win04 para preecher todo quadro.
								(;
									MsgInfo(STR0012,STR0013) ;  //"Selecione uma entidade"###"Aten็ใo!"
								);
							);
						}

Local bInclEntid 	:= {|| 	nOpcEnt := 3 ,;
							A800VerRec(oTree, @nRecnoEnt, @nValCT0Id, aTreeEnt),;
							cAliasEnt := CT0->CT0_ALIAS, ;
							If( cAliasEnt == "CV0", ;
								(;
									If (!Empty(CT0->CT0_ENTIDA), ;  //Valida็ใo para exibir os dados somente quando uma configura็ใo for selecionada
										( ;
											Inclui	:=	.T. ,;
											Altera	:=	.F. ,;
											Exclui	:=	.F. ,;
											oBtEntV:Disable(), ;
											oBtEntI:Disable(), ;
											oBtEntA:Disable(), ;
											oBtEntE:Disable(), ;
											cPlano := CT0->CT0_ENTIDA, ;
											dbSelectArea(cAliasEnt), ;
											dbGoto(nRecnoEnt), ;
											dbSetOrder( aIndexes[nValCT0Id][1] ), ;
											If( cAliasEnt="CV0" .And. CV0->CV0_CLASSE=='2', ( dbSeek(xFilial("CV0")+CV0->CV0_PLANO+CV0->CV0_ENTSUP), If(Valtype(aTreeEnt[nValCT0Id])=="O",aTreeEnt[nValCT0Id]:TreeSeek("CV0ZZ"+StrZero(CV0->(Recno()),6)),Nil) ) , nil ), ;
											If( cAliasEnt<>"CV0", ( dbGoBottom(), dbskip(), If(Valtype(aTreeEnt[nValCT0Id])=="O",aTreeEnt[nValCT0Id]:TreeSeek(cAliasEnt+"ZZ"+"000000"),NIL) ) , nil ), ;
											Eval(bReg_Memory,cAliasEnt,.T.), ;
											oWin01:disable(),;
											oGetEnt := CtbCreateGet(cAliasEnt,3, 3, oWin04, , /*CT0->CT0_CPOSUP*/), ; // Cria a Enchoice
											oBarEntid2:Show(), ;
											oGetEnt:oBox:Align := CONTROL_ALIGN_ALLCLIENT, ;
											If( cAliasEnt="CV0", M->CV0_PLANO  := CT0->CT0_ENTIDA , nil), ;
											If( cAliasEnt="CV0", M->CV0_ITEM   := CtbCV0Item(CT0->CT0_ENTIDA) , nil), ;
											If( cAliasEnt="CV0", M->CV0_ENTSUP := CV0->CV0_CODIGO , IIf(empty(CT0->CT0_CPOSUP), nil, &("M->"+CT0->CT0_CPOSUP+" := "+cAliasEnt+"->"+CT0->CT0_CPOCHV)) ), ;  //Preenche automaticamente o campo CV0_ENTSUP caso seja seleciona uma configura็ใo
											aEntArea := GetArea(),;
											aEntCT0 := CT0->(GetArea()),;
											oFWLayer:WinChgState("Col02", "Win03"), ;        //Minimiza a arvore de configura็ใo da entidade
											Eval(bAtlz_Ench, oGetCT0, "CT0") ;
										),; //Atualiza a win04 para preecher todo quadro.
										(;
											MsgInfo(STR0025,STR0013) ;//"Plano nใo preenchido. Verifique!"###"Aten็ใo!"
										);
									);
								),;
								(;
									MsgInfo(STR0014,STR0013) ;//"Utilize o cadastro padrใo desta entidade"###"Aten็ใo!"
								);
							);
						}

Local bAltEntid  	:= {|| 	nOpcEnt := 4 ,;
							A800VerRec(oTree, @nRecnoEnt, @nValCT0Id, aTreeEnt),;
							cAliasEnt := CT0->CT0_ALIAS, ;
							If( A800_Excl(),nRecnoEnt := 0,NIL),;
							If( cAliasEnt == "CV0", ;
								(;
									If( nRecnoEnt > 0 , ;  //Valida็ใo para exibir os dados somente quando uma configura็ใo for selecionada
										( ;
											Altera := .T. ,;
											Inclui := .F. ,;
											Exclui := .F. ,;
											oBtEntV:Disable(), ;
											oBtEntI:Disable(), ;
											oBtEntA:Disable(), ;
											oBtEntE:Disable(), ;
											dbSelectArea(cAliasEnt), ;
											dbGoto(nRecnoEnt), ;
											Eval(bReg_Memory,cAliasEnt,.F.), ;
											cPlnAtu := IIf(cAliasEnt="CV0", CV0->CV0_PLANO, ''), ;
											cCodAtu := IIf(cAliasEnt="CV0", CV0->CV0_CODIGO, &(cAliasEnt+"->"+CT0->CT0_CPOCHV)), ;
											oWin01:disable(),;
											oGetEnt := CtbCreateGet(cAliasEnt,4, 4, oWin04, , CT0->CT0_CPOSUP), ; // Cria a Enchoice
											oBarEntid2:Show(), ;
											oGetEnt:oBox:Align := CONTROL_ALIGN_ALLCLIENT, ;
											aEntArea := GetArea(),;
											aEntCT0 := CT0->(GetArea()),;
											oFWLayer:WinChgState("Col02", "Win03"), ;        //Minimiza a arvore de configura็ใo da entidade
											Eval(bAtlz_Ench, oGetCT0, "CT0") ;
										),; //Atualiza a win04 para preecher todo quadro.
										(;
											MsgInfo(STR0012,STR0013) ;  //"Selecione uma entidade"###"Aten็ใo!"
										);
									);
								),;
								(;
									MsgInfo(STR0014,STR0013) ;//"Utilize o cadastro padrใo desta entidade"###"Aten็ใo!"
								);
							);
						}


Local bExclEntid 	:= {|| 	nOpcEnt := 5 ,;
							A800VerRec(oTree, @nRecnoEnt, @nValCT0Id, aTreeEnt),;
							cAliasEnt := CT0->CT0_ALIAS, ;
							If( A800_Excl(),nRecnoEnt := 0,NIL),;
							If( cAliasEnt == "CV0" , ;
								(;
									If( nRecnoEnt > 0 , ;  //Valida็ใo para exibir os dados somente quando uma configura็ใo for selecionada
										( ;
											Altera := .F. ,;
											Inclui := .F. ,;
											Exclui := .T. ,;
											oBtEntV:Disable(), ;
											oBtEntI:Disable(), ;
											oBtEntA:Disable(), ;
											oBtEntE:Disable(), ;
											dbSelectArea(cAliasEnt), ;
											dbGoto(nRecnoEnt), ;
											Eval(bReg_Memory,"CV0",.F.), ;
											oWin01:disable(),;
											oGetEnt := CtbCreateGet(cAliasEnt,5, 5, oWin04, , CT0->CT0_CPOSUP), ; // Cria a Enchoice
											oBarEntid2:Show(), ;
											oGetEnt:oBox:Align := CONTROL_ALIGN_ALLCLIENT, ;
											aEntArea := GetArea(),;
											aEntCT0 := CT0->(GetArea()),;
											oFWLayer:WinChgState("Col02", "Win03"), ;        //Minimiza a arvore de configura็ใo da entidade
											Eval(bAtlz_Ench, oGetCT0, "CT0") ;
										),; //Atualiza a win04 para preecher todo quadro.
										(;
											MsgInfo(STR0012,STR0013) ;  //"Selecione uma entidade"###"Aten็ใo!"
										);
									);
								),;
								(;
									MsgInfo(STR0014,STR0013) ;//"Utilize o cadastro padrใo desta entidade"###"Aten็ใo!"
								);
							);
						}


//Bot๕es da oWin04 - Enchoice configura็ใo
Local bCanEntid 	:= {|| 	CtbDestroyGet(oGetEnt),;			//Destroi o objeto
							oBtEntV:Enable(), ;
							oBtEntI:Enable(), ;
							oBtEntA:Enable(), ;
							oBtEntE:Enable(), ;
							oWin01:enable(),;
					   		oFWLayer:WinChgState("Col02", "Win03")} //Exibe a แrvore de configura็ใo da entidade

Local bOKEntid  	:= {|| 	A800VerRec(oTree, @nRecnoEnt, @nValCT0Id, aTreeEnt),;
							If(Len(aEntArea)==3,RestArea(aEntArea),NIL),;
							If(Len(aEntCT0)==3,RestArea(aEntCT0),NIL),;
							cAliasEnt := CT0->CT0_ALIAS, ;
							dbSelectArea(cAliasEnt), ;
							dbGoto(nRecnoEnt), ;
							If( nOpcEnt > 2,(If( CtbConfEnt(nOpcEnt,oGetEnt,cAliasEnt,nValCT0Id,CT0->CT0_CPOCHV,CT0->CT0_CPOSUP), Eval(bOkEnchEnt), NIL)),	(NIL))}

//Bot๕es da oWin04 - Enchoice Entidade
Local bCanAltEnt 	:= {||	oBarEntid3:Hide(),;
							CtbDestroyGet(oGetCT0),;		//Destroi o objeto
							oGetCT0 := CtbCreateGet("CT0",2, 2,oWin02), ;
							oGetCT0:EnchRefreshAll(),;
							oWin01:enable() }

Local bOKAltEnt  	:= {||	 If( Obrigatorio(oGetCT0:aGets,oGetCT0:aTela) .And. CtbVldCpo() , ;
									( 	oBarEntid3:Hide(), ;
										cPlanoAnt := CT0->CT0_ENTIDA, ;
										CtbSaveReg("CT0", .F.), ;
										oTree:ChangePrompt(Eval(bDescCT0),oTree:GetCargo()), ;
										CtbDestroyGet(oGetCT0),;		//Destroi o objeto
										oGetCT0 := CtbCreateGet("CT0",2, 2,oWin02), ;
										oGetCT0:EnchRefreshAll(), ;
										oWin01:enable(),;
										If( ! CtbExistCV0(), CtbPlano(M->CT0_ENTIDA), nil), ;
										If( cPlanoAnt != M->CT0_ENTIDA, ( cNumPlano := M->CT0_ENTIDA, CtbEntTree(aTreeEnt[Val(M->CT0_ID)],oTree:GetPrompt(),"",abSeekEnt[Val(M->CT0_ID)],abWhileEnt[Val(M->CT0_ID)],abDescrEnt[Val(M->CT0_ID)],bEnchCT0,M->CT0_ALIAS,M->CT0_ID,M->CT0_CPOCHV)), nIL),;
									) ;
									, NIL ;
								) }  							//Executa a valida็ใo dos dados

Local bOkEnchEnt	:= {||CtbAtlzTree(nOpcEnt, aTreeEnt[nValCT0Id], abDescrEnt[nValCT0Id], bEnchCT0, cAliasEnt, M->CT0_CPOSUP),;
							CtbDestroyGet(oGetEnt),; //Destroi o objeto
							oWin01:enable(),;
							oBtEntV:Enable(), ;
							oBtEntI:Enable(), ;
							oBtEntA:Enable(), ;
							oBtEntE:Enable(), ;
							oFWLayer:WinChgState("Col02", "Win03")} //Exibe a แrvore de configura็ใo da entidade

Local aPanel 		:= {}
Local oPanelBar

Local bAction  		:= 	{|| 	oWin02:Show(),;
								oWin03:Show(),;
								oWin04:Show(),;
								Eval(bPosiciona), ;
	 							Eval(bAtlz_Ench, oGetCT0, "CT0"),;
	 							PanelShow(aPanel, Val(CT0->CT0_ID)) }

Local oRegCT0
Local oGetCT0
Local oGetEnt
Local aEntArea	:= {}
Local aEntCT0	:= {}

Local oFWLayer, oDlg, oWin01, oWin02, oWin03, oWin04
Local oBar
Local oBarEntid  //Botใo alterar da entidade
Local oBarEntid2 //Bot๕es ok e cancel das opera็๕es (vis, inc, exc ou alt) das configura็๕es
Local oBarEntid3 //Bot๕es ok e cancel da opera็ใo de altera็ใo da entidade

Local aButtons 		:= {}
Local aButtEnt 		:= {}
Local aButtEnt2	    := {}
Local aButtEnt3	    := {}

Local aTreeEnt := {}
Local oTree
Local cOrd1
Local cOrd2
Local cInd1
Local cInd2
Local nOrd1
Local nOrd2
Local cAux
Local cIdEnt
Local cPrefix := ""
Local oContent := Nil
Local aPHelpPor := {}
Local nY

//necessario para chamar os cadastros
Private cCadastro := ""
Private	aTela := {}
Private	aGets := {}
//necessario para consulta padrao da CV0
Private cPlano := ""
Private cCodigo := ""

//necessario para compatibilizacao com a rotina CTBA050
Private cPlanoCV0

Private INCLUI := .F.
Private ALTERA := .F.
Private EXCLUI := .F.

Private cPlnAtu
Private cCodAtu

Private aIndexes := CTBEntGtIn()

If !CtbVerSX2("CT0", .T.)
	Return
EndIf

If aRotAuto <> Nil .And. ValType(aRotAuto) == "A"
	Ctb800Auto(nOpcAuto,aRotAuto)
	Return Nil
EndIf

//--------------------------------------------------------------------------//
oRegCT0 := Adm_List_Records():New()
oRegCT0:SetAlias("CT0")  //alias
oRegCT0:SetOrder(1)		 //ordem do indice
oRegCT0:Fill_Records()   //preenche os registros

For nX := 1 TO oRegCT0:CountRecords()
	oRegCT0:SetPosition(nX)
	oRegCT0:SetRecord()

	If Alltrim(CT0->CT0_ALIAS)=="CV0" .And. Empty(CT0->CT0_CPOSUP)
		RecLock("CT0", .F.)
		CT0->CT0_CPOSUP := "CV0_ENTSUP"
		CT0->(dbCommit())
		CT0->(MsUnLock())
	EndIf

	cAlias  := Alltrim(CT0->CT0_ALIAS)
	lCV0	:= cAlias=="CV0"
	cCpoSup := CT0->CT0_CPOSUP
	cCpoChv := CT0->CT0_CPOCHV
	cCpoDsc := CT0->CT0_CPODSC
	cEntida := IIf(lCV0,CT0->CT0_ENTIDA,"")
	cIdEnt	:= CT0->CT0_ID
	cPrefix := PrefixoCpo(cAlias)

	AADD( abDescrEnt, &("{|| Alltrim("+cAlias+"->"+cCpoChv+")+'-'+Alltrim("+cAlias+"->"+cCpoDsc+" ) }") )
	AADD( abSeekEnt , &("{|| xFilial('"+cAlias+"')" + IIf(Empty(cEntida),"","+'"+cEntida+"'") + IIf(empty(cCpoSup),'',"+PadR(cEntSup,Len("+cAlias+"->"+cCpoSup+"))") + " }") )
	AADD( abWhileEnt, &("{|| "+If(lCV0,'cNumPlano := CT0->CT0_ENTIDA,','')+cAlias+"->( "+cPrefix+"_FILIAL"+IIf(lCV0,"+CV0_PLANO","") + IIf(empty(cCpoSup),'',"+"+cCpoSup) + "==xFilial('"+cAlias+"')"+IIf(lCV0,"+cNumPlano","") + IIf(empty(cCpoSup),'',"+PadR(cEntSup,Len("+cCpoSup+"))") + " ) }") )
	AADD( abTree    , &("{|oTreeEnt| CtbEntidTree(oTreeEnt,'"+cAlias+"',aIndexes["+cIdEnt+"][2],'"+cCpoChv+"'	,Eval(bDescCT0),'', abSeekEnt["+cIdEnt+"], abWhileEnt["+cIdEnt+"], abDescrEnt["+cIdEnt+"], bEnchCT0, '"+cCpoSup+"') }") )

Next

__aLstBox 	:= Array( oRegCT0:CountRecords() )  //contera os objetos list box
__aViewBox 	:= Array( oRegCT0:CountRecords() )  //conteudo do list box
__aRecnoBox := Array( oRegCT0:CountRecords() )  //conteudo acao list box alias-Recno

aAdd(aButtons, { BMPALTERAR    ,BMPALTERAR   ,"" , bAlterar  ,STR0001}) //"Alterar"###"Alterar"
aAdd(aButtons, { BMPSAIR       ,BMPSAIR      ,"" , bSair     ,STR0021 }) //"Sair"###"Sair"

aAdd(aButtEnt, { BMPPESQUISA   ,BMPPESQUISA	 ,"" , bVisuEntid ,STR0002})  //"Visualizar"###"Visualizar"                          //"Visualizar"
aAdd(aButtEnt, { BMPINCLUIR    ,BMPINCLUIR	 ,"" , bInclEntid ,STR0003 }) //"Incluir"###"Incluir"
aAdd(aButtEnt, { BMPALTERAR    ,BMPALTERAR	 ,"" , bAltEntid  ,STR0001 }) //"Alterar"###"Alterar"
aAdd(aButtEnt, { BMPEXCLUIR    ,BMPEXCLUIR	 ,"" , bExclEntid ,STR0004 }) //"Excluir"###"Excluir"

aAdd(aButtEnt2, { BMPCONFIRMAR ,BMPCONFIRMAR ,"" , bOKEntid   ,STR0005 }) //"OK"###"OK"
aAdd(aButtEnt2, { BMPCANCELAR  ,BMPCANCELAR	 ,"" , bCanEntid  ,STR0006 }) //"Cancel"###"Cancel"

aAdd(aButtEnt3, { BMPCONFIRMAR ,BMPCONFIRMAR ,"" , bOKAltEnt  ,STR0005 }) //"OK"###"OK"
aAdd(aButtEnt3, { BMPCANCELAR  ,BMPCANCELAR	 ,"" , bCanAltEnt ,STR0006 }) //"Cancel"###"Cancel"

aPanel 		:= Array( oRegCT0:CountRecords() )
aTreeEnt 	:= Array( oRegCT0:CountRecords() )

//-----------------------------------------
// Cria็ใo de classe para defini็ใo da propor็ใo da interface
//-----------------------------------------
oSize := FWDefSize():New(.T., , nOr(WS_VISIBLE,WS_POPUP) )
oSize:AddObject("TOP", 100, 100, .T., .T.)
oSize:aMargins := {0,0,0,0}
oSize:Process()

DEFINE DIALOG oDlg TITLE STR0007 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP) //"Entidades Contabeis"

@ 	oSize:GetDimension("TOP", "LININI"),;
	oSize:GetDimension("TOP", "COLINI") BITMAP oContent RESOURCE "x.png" SIZE;
	oSize:GetDimension("TOP", "XSIZE"),;
	oSize:GetDimension("TOP", "YSIZE") ADJUST NO BORDER OF oDlg PIXEL

// Cria instancia do fwlayer
oFWLayer 	:= FWLayer():New()

oFWLayer:init( oContent ) // Inicializa componente passa a Dialog criada, o segundo parametro ้ para cria็ใo de um botao de fechar utilizado para Dlg sem cabe็alho


oFWLayer:addCollumn( "Col01", 30, .T. ) // Adiciona coluna passando nome, porcentagem da largura, e se ela ้ redimensionada ou nใo
// Cria windows passando, nome da coluna onde sera criada, nome da window,  titulo da window, a porcentagem da altura da janela, se esta habilitada para click,
// se ้ redimensionada em caso de minimizar outras janelas e a a็ใo no click do split
oFWLayer:addWindow( "Col01", "Win01", STR0008, 99.9, .F., .T., {|| },,) //"Entidade"
oWin01 		:= oFWLayer:getWinPanel('Col01','Win01')

oFWLayer:addCollumn( "Col02", 70, .F. )
oFWLayer:addWindow( "Col02", "Win02", STR0009, 35.9, .T., .T., {||},,) //"Detalhes"
oWin02 		:= oFWLayer:getWinPanel('Col02','Win02')

oFWLayer:addWindow( "Col02", "Win03", STR0010, 64, .T., .F., {||/*CtbDestroyGet(oGetEnt),CtbDestroyGet(oGetCT0),oBarEntid2:Hide(),oBarEntid3:Hide()*/},,)
oWin03 		:= oFWLayer:getWinPanel('Col02','Win03')

oFWLayer:addWindow("Col02", "Win04", STR0011, 0.1, .F., .F.,{||},,) //"Cadastro"
oWin04 		:= oFWLayer:getWinPanel('Col02','Win04')
oWin04:Align:= CONTROL_ALIGN_ALLCLIENT

//definicoes dos botoes da Window Win01
DEFINE BUTTONBAR oBar SIZE 30,30 3D BOTTOM OF oWin01
oButton 		:= TBtnBmp():NewBar( aButtons[1,1],aButtons[1,2],,,aButtons[1,3], aButtons[1,4],.T.,oBar,,,aButtons[1,5])
oButton:cTitle 	:= aButtons[1,3]
oButton 		:= TBtnBmp():NewBar( aButtons[2,1],aButtons[2,2],,,aButtons[2,3], aButtons[2,4],.T.,oBar,,,aButtons[2,5])
oButton:cTitle 	:= aButtons[2,3]
oButton:Align 	:= CONTROL_ALIGN_RIGHT

//definicoes dos botoes da Window Win03
DEFINE BUTTONBAR oBarEntid SIZE 30,30 3D BOTTOM OF oWin03
oBtEntV 		:= TBtnBmp():NewBar( aButtEnt[1,1],aButtEnt[1,2],,,aButtEnt[1,3], aButtEnt[1,4],.T.,oBarEntid,,,aButtEnt[1,5])
oBtEntV:cTitle	:= aButtEnt[1,3]
oBtEntI 		:= TBtnBmp():NewBar( aButtEnt[2,1],aButtEnt[2,2],,,aButtEnt[2,3], aButtEnt[2,4],.T.,oBarEntid,,,aButtEnt[2,5])
oBtEntI:cTitle	:= aButtEnt[2,3]
oBtEntA 		:= TBtnBmp():NewBar( aButtEnt[3,1],aButtEnt[3,2],,,aButtEnt[3,3], aButtEnt[3,4],.T.,oBarEntid,,,aButtEnt[3,5])
oBtEntA:cTitle	:= aButtEnt[3,3]
oBtEntE 		:= TBtnBmp():NewBar( aButtEnt[4,1],aButtEnt[4,2],,,aButtEnt[4,3], aButtEnt[4,4],.T.,oBarEntid,,,aButtEnt[4,5])
oBtEntE:cTitle	:= aButtEnt[4,3]

aAdd(aButtEnt, { BMPPESQUISA   ,BMPPESQUISA	 ,"" , bVisuEntid ,STR0002})  //"Visualizar"###"Visualizar"                          //"Visualizar"
aAdd(aButtEnt, { BMPINCLUIR    ,BMPINCLUIR	 ,"" , bInclEntid ,STR0003 }) //"Incluir"###"Incluir"
aAdd(aButtEnt, { BMPALTERAR    ,BMPALTERAR	 ,"" , bAltEntid  ,STR0001 }) //"Alterar"###"Alterar"
aAdd(aButtEnt, { BMPEXCLUIR    ,BMPEXCLUIR	 ,"" , bExclEntid ,STR0004 }) //"Excluir"###"Excluir"

//definicoes dos botoes da Window Win04
DEFINE BUTTONBAR oBarEntid2 SIZE 30,30 3D BOTTOM OF oWin04
oButtEnt2 		:= TBtnBmp():NewBar( aButtEnt2[1,1],aButtEnt2[1,2],,,aButtEnt2[1,3], aButtEnt2[1,4],.T.,oBarEntid2,,,aButtEnt2[1,5])
oButtEnt2:cTitle:= aButtEnt2[1,3]
oButtEnt2 		:= TBtnBmp():NewBar( aButtEnt2[2,1],aButtEnt2[2,2],,,aButtEnt2[2,3], aButtEnt2[2,4],.T.,oBarEntid2,,,aButtEnt2[2,5])
oButtEnt2:cTitle:= aButtEnt2[2,3]

//definicoes dos botoes da Window Win04
DEFINE BUTTONBAR oBarEntid3 SIZE 30,30 3D BOTTOM OF oWin02
oButtEnt3 		:= TBtnBmp():NewBar( aButtEnt3[1,1],aButtEnt3[1,2],,,aButtEnt3[1,3], aButtEnt3[1,4],.T.,oBarEntid3,,,aButtEnt3[1,5])
oButtEnt3:cTitle:= aButtEnt3[1,3]
oButtEnt3 		:= TBtnBmp():NewBar( aButtEnt3[2,1],aButtEnt3[2,2],,,aButtEnt3[2,3], aButtEnt3[2,4],.T.,oBarEntid3,,,aButtEnt3[2,5])
oButtEnt3:cTitle:= aButtEnt3[2,3]
oBarEntid3:Hide()

//------------------------------------------------------------------------------------------//
//CRIACAO DA ARVORE
//------------------------------------------------------------------------------------------//
oTree:= Xtree():New(oWin01:nLeft+2,oWin01:nTop+2,oWin01:oWnd:nHeight-420,oWin01:oWnd:nWidth*.35-225, oWin01)
oTree:bLostFocus := {|| IIf(empty(oTree:CurrentNodeID), (oTree:TreeSeek("{|}ZZ000000"),oWin02:Hide(),oWin03:Hide(),oWin04:Hide(),oTree:SetFocus()), nil)}

oTree:AddTree	( STR0007,; //descricao do node###"Entidades Contabeis"
					"IndicatorCheckBox", ; //bitmap fechado
					"IndicatorCheckBoxOver",; //bitmap aberto
					"{|}ZZ000000", ;  //cargo (id)
					{|| oWin02:Hide(), oWin03:Hide(),oWin04:Hide() } ; //bAction - bloco de codigo para exibir
				)

For nX := 1 TO oRegCT0:CountRecords()

	oRegCT0:SetPosition(nX)
	oRegCT0:SetRecord()

	cNumPlano := CT0->CT0_ENTIDA

	oTree:AddTree ( Eval(bDescCT0),; //descricao do node //
					  	"IndicatorCheckBox", ; //bitmap fechado
						"IndicatorCheckBoxOver",; //bitmap aberto
						"CT0"+If(Empty(CT0->CT0_ENTIDA),"ZZ",CT0->CT0_ENTIDA)+PadL(CT0->CT0_ID,6,"0"),;  //StrZero(CT0->(Recno()),6),;//cargo (id)
						bAction,; //bAction - bloco de codigo para exibir
					  )

	oTree:EndTree()

	aPanel[nX] := TScrollBox():New( oWin03, 0, 0,oWin03:nClientHeight/2-25, oWin03:nClientWidth/2-1)

	aPanel[nX]:Align := CONTROL_ALIGN_CENTER

	If A800MtaArvore()
		//monta arvore
		aTreeEnt[nX] := Xtree():New(0,0,aPanel[nX]:nHeight-175,aPanel[nX]:nWidth-475, aPanel[nX])

		Eval(abTree[nX], aTreeEnt[nX])

		aPanel[nX]:Hide()

	Else
		//monta ListBox quando nao posuir hierarquia e o volume de nos ultrapassa limite do xtree
		__aLstBox[ Val(CT0->CT0_ID)]				:= A800LBox( __aViewBox[Val(CT0->CT0_ID)], { CT0->CT0_DESC }, aPanel[nX] )
		If Val(CT0->CT0_ID)  == 1
			__aLstBox[ 1 ]:bLine 			:= { || { __aViewBox[ 1 ,__aLstBox[ 1 ]:nAT ] } }
			__aLstBox[ 1 ]:bLDblClick   	:= {|| cAliasRec := __aRecnoBox[ 1 ,__aLstBox[ 1 ]:nAT, 1], nRecAux := __aRecnoBox[ 1 ,__aLstBox[ 1 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }
			__aLstBox[ 1 ]:bChange	   		:= {|| cAliasRec := __aRecnoBox[ 1 ,__aLstBox[ 1 ]:nAT, 1], nRecAux := __aRecnoBox[ 1 ,__aLstBox[ 1 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }

		ElseIf Val(CT0->CT0_ID)  == 2
			__aLstBox[ 2 ]:bLine 			:= { || { __aViewBox[ 2 ,__aLstBox[ 2 ]:nAT ] } }
			__aLstBox[ 2 ]:bLDblClick   	:= {|| cAliasRec := __aRecnoBox[ 2 ,__aLstBox[ 2 ]:nAT, 1], nRecAux := __aRecnoBox[ 2 ,__aLstBox[ 2 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }
			__aLstBox[ 2 ]:bChange	   		:= {|| cAliasRec := __aRecnoBox[ 2 ,__aLstBox[ 2 ]:nAT, 1], nRecAux := __aRecnoBox[ 2 ,__aLstBox[ 2 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }

		ElseIf Val(CT0->CT0_ID)  == 3
			__aLstBox[ 3 ]:bLine 			:= { ||  { __aViewBox[ 3 ,__aLstBox[ 3 ]:nAT ] } }
			__aLstBox[ 3 ]:bLDblClick   	:= {|| cAliasRec := __aRecnoBox[ 3 ,__aLstBox[ 3 ]:nAT, 1], nRecAux := __aRecnoBox[ 3 ,__aLstBox[ 3 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }
			__aLstBox[ 3 ]:bChange	   		:= {|| cAliasRec := __aRecnoBox[ 3 ,__aLstBox[ 3 ]:nAT, 1], nRecAux := __aRecnoBox[ 3 ,__aLstBox[ 3 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }
		ElseIf Val(CT0->CT0_ID)  == 4
			__aLstBox[ 4 ]:bLine 			:= { || { __aViewBox[ 4 ,__aLstBox[ 4 ]:nAT ] } }
			__aLstBox[ 4 ]:bLDblClick   	:= {|| cAliasRec := __aRecnoBox[ 4 ,__aLstBox[ 4 ]:nAT, 1], nRecAux := __aRecnoBox[ 4 ,__aLstBox[ 4 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }
			__aLstBox[ 4 ]:bChange	   		:= {|| cAliasRec := __aRecnoBox[ 4 ,__aLstBox[ 4 ]:nAT, 1], nRecAux := __aRecnoBox[ 4 ,__aLstBox[ 4 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }

		ElseIf Val(CT0->CT0_ID)  == 5
			__aLstBox[ 5 ]:bLine 			:= { || { __aViewBox[ 5 ,__aLstBox[ 5 ]:nAT ] } }
			__aLstBox[ 5 ]:bLDblClick   	:= {|| cAliasRec := __aRecnoBox[ 5 ,__aLstBox[ 5 ]:nAT, 1], nRecAux := __aRecnoBox[ 5 ,__aLstBox[ 5 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }
			__aLstBox[ 5 ]:bChange	   		:= {|| cAliasRec := __aRecnoBox[ 5 ,__aLstBox[ 5 ]:nAT, 1], nRecAux := __aRecnoBox[ 5 ,__aLstBox[ 5 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }

		ElseIf Val(CT0->CT0_ID)  == 6
			__aLstBox[ 6 ]:bLine 			:= { || { __aViewBox[ 6 ,__aLstBox[ 6 ]:nAT ] } }
			__aLstBox[ 6 ]:bLDblClick   	:= {|| cAliasRec := __aRecnoBox[ 6 ,__aLstBox[ 6 ]:nAT, 1], nRecAux := __aRecnoBox[ 6 ,__aLstBox[ 6 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }
			__aLstBox[ 6 ]:bChange	   		:= {|| cAliasRec := __aRecnoBox[ 6 ,__aLstBox[ 6 ]:nAT, 1], nRecAux := __aRecnoBox[ 6 ,__aLstBox[ 6 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }

		ElseIf Val(CT0->CT0_ID)  == 7
			__aLstBox[ 7 ]:bLine 			:= { || { __aViewBox[ 7 ,__aLstBox[ 7 ]:nAT ] } }
			__aLstBox[ 7 ]:bLDblClick   	:= {|| cAliasRec := __aRecnoBox[ 7 ,__aLstBox[ 7 ]:nAT, 1], nRecAux := __aRecnoBox[ 7 ,__aLstBox[ 7 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }
			__aLstBox[ 7 ]:bChange	   		:= {|| cAliasRec := __aRecnoBox[ 7 ,__aLstBox[ 7 ]:nAT, 1], nRecAux := __aRecnoBox[ 7 ,__aLstBox[ 7 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }

		ElseIf Val(CT0->CT0_ID)  == 8
			__aLstBox[ 8 ]:bLine 			:= { || { __aViewBox[ 8 ,__aLstBox[ 8 ]:nAT ] } }
			__aLstBox[ 8 ]:bLDblClick   	:= {|| cAliasRec := __aRecnoBox[ 8 ,__aLstBox[ 8 ]:nAT, 1], nRecAux := __aRecnoBox[ 8 ,__aLstBox[ 8 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }
			__aLstBox[ 8 ]:bChange	   		:= {|| cAliasRec := __aRecnoBox[ 8 ,__aLstBox[ 8 ]:nAT, 1], nRecAux := __aRecnoBox[ 8 ,__aLstBox[ 8 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }

		ElseIf Val(CT0->CT0_ID)  == 9
			__aLstBox[ 9 ]:bLine 			:= { || { __aViewBox[ 9 ,__aLstBox[ 9 ]:nAT ] } }
			__aLstBox[ 9 ]:bLDblClick   	:= {|| cAliasRec := __aRecnoBox[ 9 ,__aLstBox[ 3 ]:nAT, 1], nRecAux := __aRecnoBox[ 9 ,__aLstBox[ 9 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }
			__aLstBox[ 9 ]:bChange	   		:= {|| cAliasRec := __aRecnoBox[ 9 ,__aLstBox[ 3 ]:nAT, 1], nRecAux := __aRecnoBox[ 9 ,__aLstBox[ 9 ]:nAT, 2] , (cAliasRec)->( dbGoto(nRecAux) ) }

		EndIf
	EndIf

Next

oTree:EndTree()

oTree:Align := CONTROL_ALIGN_ALLCLIENT

//Cria a Enchoice CT0
Eval(bReg_Memory,"CT0",.T.)
oGetCT0 := CtbCreateGet("CT0",2, 2, oWin02)
oGetCT0:EnchRefreshAll()

//Cria a Enchoice CV0
Eval(bReg_Memory,"CV0",.T.)
oGetEnt := CtbCreateGet("CV0",2, 2,oWin04, , CT0->CT0_CPOSUP)
oGetEnt:EnchRefreshAll()

Eval({|| oWin02:Hide(), oWin03:Hide(),oWin04:Hide()}) //Para nใo exibir dados enquanto nใo houver sele็ใo

ACTIVATE DIALOG oDlg CENTERED

//limpar da memoria
For nX := 1 TO Len(__aViewBox)
	If __aViewBox[nX] != NIL
		For nY := 1 TO Len(__aViewBox[nX])
			aDel(__aViewBox[nX], 1)
		Next
		aSize(__aViewBox[nX], 0)
	EndIf
	aDel(__aViewBox, 1)
Next
aSize(__aViewBox, 0)

__aLstBox := NIL
__aViewBox := NIL

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCreateGet บAutor  ณMicrosiga        บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbCreateGet(cAlias, nOpcx, nOpcao2, oWindow, lOneColumn, cCpoSup)

Local oGet
Local aCpos	:= {}
Local nX
Local cFld
Local aPos := {0,0,70,60}

Private aTELA[0][0]
Private aGETS[0]

DEFAULT lOneColumn := .F.
DEFAULT cCpoSup := ''

dbSelectArea(cAlias)
aCpos := {}
For nX:= 1 to FCount()
	cFld := Alltrim(FieldName(nX))
	If cFld <> Alltrim(cCpoSup)
		AADD(aCpos,cFld)
	EndIf

Next
//      MsMGet():New(cAlias,nReg               ,nOpc ,aCRA,cLetra,cTexto,aAcho,aPos,aCpos,nModelo,nColMens,cMensagem,cTudoOk,oWnd   ,lF3,lMemoria, lColumn  , caTela, lNoFolder, lProperty)
oGet := MsMGet():New(cAlias,(cAlias)->(RecNo()),nOpcx,    ,      ,      ,     ,aPos,aCpos,nOpcao2,        ,         ,       ,oWindow,   ,        ,lOneColumn,       , .T.)
oGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

Return(oGet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbDestroyGet บAutor  ณMicrosiga       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDestroi objeto                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbDestroyGet(oGet)

If Valtype(oGet) == "O"
	oGet:oBox:FreeChildren()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbEntidTree  บAutor  ณMicrosiga       บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMontagem da arvore                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbEntidTree(oTree, cAlias, nOrder, cCampo, cTitEntidade, cEntSup, bSeek, bWhile, bDescNode, bAction, cCpoSup)

dbSelectArea(cAlias)
dbSetOrder(nOrder)

oTree:AddTree	( cTitEntidade,; //descricao do node //
					"IndicatorCheckBox", ; //bitmap fechado
					"IndicatorCheckBoxOver",; //bitmap aberto
					cAlias+"ZZ"+"000000", ;  //cargo (id)
					bAction; //bAction - bloco de codigo para exibir
				)

CtbTreeRec(oTree, cAlias, cCampo, cEntSup, bSeek, bWhile, bDescNode, bAction, cCpoSup)

oTree:EndTree()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbTreeRecบAutor  ณMicrosiga           บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMontagem da arvore de modo recursivo.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbTreeRec(oTree, cAlias, cCampo, cEntSup, bSeek, bWhile, bDescNode, bAction, cCpoSup)
Local aArea := GetArea()
Local aAreaAux := (cAlias)->( GetArea() )
Local cEntAux  := ""
Local lEntAux2  := .T.
Local nCountNodes := 0

//Default bAction := {||}
bAction := {||CtbAddTree(oTree, cAlias, cCampo, cEntSup, bSeek, bWhile, bDescNode, bAction, cCpoSup)}
dbSeek(Eval(bSeek))

While (cAlias)->(!Eof() .And. Eval(bWhile))

	If cAlias == "CV0" //Identifica se ้ o registro de inclusใo do plano
		lEntAux2 := !Empty((cAlias)->(FieldGet(FieldPos("CV0_ITEM"))))
	EndIf

	If lEntAux2	//Valida็ใo para nใo incluir o registro de inclusใo do plano na arvore
		oTree:AddTree	( Eval(bDescNode),; //descricao do node //
						"IndicatorCheckBox", ; //bitmap fechado
						"IndicatorCheckBoxOver",; //bitmap aberto
						cAlias+"ZZ"+StrZero((cAlias)->(Recno()),6), ;  //cargo (id)
						,;
						,;
						bAction ; //bAction - bloco de codigo para exibir
					)
		cEntAux := (cAlias)->(FieldGet(FieldPos(cCampo)))

 		oTree:EndTree()
	EndIf

	dbSkip()

	nCountNodes:= nCountNodes+1

	If nCountNodes > 5000
	    oTree:TreeSeek(cAlias+"ZZ"+"000000")
		oTree:AddTree	( STR0032,; //descricao do node //"Continua็ใo (Duplo Clique)..."
						"IndicatorCheckBox", ; //bitmap fechado
						"IndicatorCheckBoxOver",; //bitmap aberto
						cAlias+"YY"+StrZero((cAlias)->(Recno()),6), ;  //cargo (id)
						, ; //bAction - bloco de codigo para exibir
						, ;
						bAction ;//DUPLO CLIQUE
					)
		cEntAux := (cAlias)->(FieldGet(FieldPos(cCampo)))

 		oTree:EndTree()
		Exit
	EndIf

EndDo

RestArea( aAreaAux )
RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPanelShow บAutor  ณMicrosiga           บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PanelShow(aPanel, nPanel)
Local nZ

Default nPanel := 1
For nZ := 1 TO Len(aPanel)
	aPanel[nZ]:Hide()
Next

If nPanel > 0
	aPanel[nPanel]:Show()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBConfEntบAutor  ณMicrosiga           บ Data ณ  03/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de valida็ใo da opera็ใo (inclusใo, altera็ใo e ex- บฑฑ
ฑฑบ          ณ clusใo.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbConfEnt(nOpcEnt,oGetEnt,cAliasEnt,nEntID,cCpoChv,cCpoSup)

Local lRet       := .F.
Local aEaiRet    := {}

DbSelectArea(cAliasEnt)
DbSetOrder(aIndexes[nEntID][1])

If nOpcEnt == 3 //Inclusใo
	If ( lRet := CtbValidEnt(nOpcEnt,oGetEnt,cAliasEnt,nEntID,cCpoChv,cCpoSup) )
		lRet := CtbSaveReg(cAliasEnt,.T.,nEntID)	//Fun็ใo de inclusใo do registro
	EndIf
ElseIf nOpcEnt == 4 //Altera็ใo
	If ( lRet := CtbValidEnt(nOpcEnt,oGetEnt,cAliasEnt,nEntID,cCpoChv,cCpoSup) )
		lRet := CtbSaveReg(cAliasEnt,.F.,nEntID)	//Fun็ใo de grava็ใo do registro
	EndIf
ElseIf nOpcEnt == 5 //Exclusใo
	If ( lRet := CtbValidEnt(nOpcEnt,oGetEnt,cAliasEnt,nEntID,cCpoChv,cCpoSup) )

		Begin Transaction

		RecLock(cAliasEnt, .F.)
		DbDelete()
		MsUnLock()

		If __lEAI800A
			If !empty(CV0->CV0_CODIGO)
				aEaiRet := CTBA800A()

				If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
					aEaiRet := {.F., ""}
				Endif
				If !aEaiRet[1]
					Help(,, "CTBA080INTEGERRO",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Verifique se a integra็ใo estแ configurada corretamente."
					DisarmTransaction()
					lRet := .F.
				EndIf
			EndIf
		EndIf

		End Transaction
	EndIf
EndIf

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbValidEnt บAutor  ณMicrosiga         บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao dos processos de inclusao, alteracao e exclusao   บฑฑ
ฑฑบ          ณdas entidades adicionais.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbValidEnt(nOpcEnt,oGetEnt,cAliasEnt,nEntID,cCpoChv,cCpoSup)

Local lRet			:= .T.
Local aArea		:= GetArea()
Local aSaveEnt	:= (cAliasEnt)->(GetArea())
Local cPlano
Local cCpoEnt	:= ""
Local cCpoEntSup:= ""


If cAliasEnt=="CV0"
	cPlano := M->CV0_PLANO
Else
	cPlano := ''
EndIf


If oGetEnt != Nil
	aGets := oGetEnt:aGets
	aTela := oGetEnt:aTela
Else //Rotina Automatica
	If cAliasEnt == "CV0"
		nEntID := Val(cPlano)
		cCpoChv:= "CV0_CODIGO"
		cCpoSup:= "CV0_ENTSUP"
	EndIf
	DbSelectArea(cAliasEnt)
	DbSetOrder(aIndexes[nEntID][1])
	DbSeek(xFilial(cAliasEnt)+cPlano+&("M->"+cCpoChv))
EndIf

//ฺฤฤฤฤฤฤฤฤฟ
//ณINCLUSAOณ
//ภฤฤฤฤฤฤฤฤู
If nOpcEnt == 3

	If Type("M->"+cCpoChv) != "U"
		cCpoEnt := &("M->"+cCpoChv)
	Else
		cCpoEnt := &(cAliasEnt+"->"+cCpoChv)
	EndIf

	If Type("M->"+cCpoSup) != "U"
		cCpoEntSup := &("M->"+cCpoSup)
	Else
		cCpoEntSup := &(cAliasEnt+"->"+cCpoSup)
	EndIf

	If oGetEnt != Nil .And. !Obrigatorio(oGetEnt:aGets,oGetEnt:aTela)
		lRet := .F.
	EndIf

	If DbSeek(xFilial(cAliasEnt)+cPlano+cCpoEnt)
		lRet := .F.
		Help('',1,'CTBA800',,STR0015,1) //"C๓digo jแ cadastrado."
	EndIf
	If !empty(cCpoSup) .And. Alltrim(cCpoEntSup) == Alltrim(cCpoEnt) .AND. !VAZIO(cCpoEntSup)
		lRet := .F.
		Help('',1,'CTBA800',,STR0017,1) //"Entidade superior invแlida."
	EndIf
	If !empty(cCpoSup) .And. !Empty(cCpoEntSup) .And. !dbSeek(xFilial(cAliasEnt)+cPlano+cCpoEntSup) //Localiza a conta superior
		lRet := .F.
		Help('',1,'CTBA800',,STR0017,1) //"Entidade superior invแlida."
	EndIf
	If cAliasEnt=="CV0" .And. !Empty(cCpoEntSup) .And. dbSeek(xFilial(cAliasEnt)+cPlano+&("M->"+cCpoSup)) .And. CV0->CV0_CLASSE == "2"
		lRet := .F.
		Help('',1,'CTBA800',,STR0018,1) //"Classe invแlida."
	EndIf
	If cAliasEnt=="CV0" .And. M->CV0_DTIBLQ > M->CV0_DTFBLQ .And. !Empty(M->CV0_DTFBLQ)
		lRet := .F.
		Help('',1,'CTBA800',,STR0027,1) //"Data final do bloqueio menor que a data inicial"
	EndIf
	If cAliasEnt=="CV0" .And. M->CV0_DTIEXI > M->CV0_DTFEXI .And. !Empty(M->CV0_DTFEXI)
		lRet := .F.
		Help('',1,'CTBA800',,STR0028,1) //"Data final de existencia menor que a data inicial"

	EndIf

	If cAliasEnt == "CV0" .AND. lRet
		lRet := CTB105EntC(,M->CV0_LUCPER,,M->CV0_PLANO)

		If lRet
			lRet := CTB105EntC(,M->CV0_PONTE,,M->CV0_PLANO)
		EndIf
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฟ
	//ณALTERACAOณ
	//ภฤฤฤฤฤฤฤฤฤู
ElseIf nOpcEnt == 4

	If oGetEnt != Nil .And. !Obrigatorio(oGetEnt:aGets,oGetEnt:aTela)
		lRet := .F.
		//Help('',1,'CTBA800',,STR0016,1) //"Preencha os campos obrigat๓rios."
	EndIf
	If !isBlind() .And. cPlano+&("M->"+cCpoChv) != cPlnAtu+cCodAtu
		lRet := .F.
		Help('',1,'CTBA800',,STR0019,1) //'Nใo ้ possivel alterar o campo "C๓digo"/"Plano".
	EndIf
	If !empty(cCpoSup) .And. !Empty(&("M->"+cCpoSup)) .And. &("M->"+cCpoSup) == &("M->"+cCpoChv)
		lRet := .F.
		Help('',1,'CTBA800',,STR0017,1) //"Entidade superior invแlida."
	EndIf
	If !empty(cCpoSup) .And. !Empty(&("M->"+cCpoSup)) .And. !dbSeek(xFilial(cAliasEnt)+cPlano+&("M->"+cCpoSup)) //Localiza a conta superior
		lRet := .F.
		Help('',1,'CTBA800',,STR0017,1) //"Entidade superior invแlida."
	EndIf
	If cAliasEnt=="CV0" .And. M->CV0_CLASSE == "2" .And. CTBConEInf(cPlano,&("M->"+cCpoChv),cAliasEnt,nEntID)	//Se a classe for alterada para analitica
		lRet := .F.														//consulta se ha conta inferior
		Help('',1,'CTBA800',,STR0018,1) //"Classe invแlida."
	EndIf
	If cAliasEnt=="CV0" .And. M->CV0_DTIBLQ > M->CV0_DTFBLQ .And. !Empty(M->CV0_DTFBLQ)
		lRet := .F.
		Help('',1,'CTBA800',,STR0027,1) //"Data final do bloqueio menor que a data inicial"
	EndIf
	If cAliasEnt=="CV0" .And. M->CV0_DTIEXI > M->CV0_DTFEXI .And. !Empty(M->CV0_DTFEXI)
		lRet := .F.
		Help('',1,'CTBA800',,STR0028,1) //"Data final de existencia menor que a data inicial"
	EndIf

	If cAliasEnt == "CV0" .AND. lRet
		lRet := CTB105EntC(,M->CV0_LUCPER,,M->CV0_PLANO)

		If lRet
			lRet := CTB105EntC(,M->CV0_PONTE,,M->CV0_PLANO)
		EndIf
	EndIf
	//ฺฤฤฤฤฤฤฤฤฟ
	//ณEXCLUSAOณ
	//ภฤฤฤฤฤฤฤฤู
ElseIf nOpcEnt == 5 //Exclusao

	DbSelectArea(cAliasEnt)
	DbSetOrder(aIndexes[nEntID][2])
	If cAliasEnt=="CV0"
		cPlano := CV0->CV0_PLANO
	Else
		cPlano := ""
	EndIf
	If DbSeek(xFilial(cAliasEnt)+cPlano+(cAliasEnt)->CV0_CODIGO)
		lRet := .F.
		Help('',1,'CTB800CTASS',,,1) //"Nใo ้ possํvel excluir. Registro com associa็ใo."
	EndIf
	
	//Valida็ใo com PCO - verificando se cont้m lan็amentos(PCOA050) com essa entidade
	If lRet
		lRet = VldEntPCO(cAliasEnt,M->CV0_CODIGO,cPlano)
	Endif
EndIf

RestArea(aSaveEnt)
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbAtlzTree บAutor  ณMicrosiga         บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza a arvore nos processos de inclusao alteracao e     บฑฑ
ฑฑบ          ณexclusao.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbAtlzTree(nOpcEnt, oTree, bDescriEnt, bAtua_Enchoice, cAliasEnt, cCpoSup)
Local cCpoEntSup := ""

If nOpcEnt == 3

	If Type("M->"+cCpoSup) != "U"
		cCpoEntSup := &("M->"+cCpoSup)
	Else
		cCpoEntSup := &(cAliasEnt+"->"+cCpoSup)
	EndIf

	If Empty(cCpoSup) .Or. Empty(cCpoEntSup)
		If ValType(oTree) == "O"  //arvore
			oTree:TreeSeek(cAliasEnt+"ZZ000000")
		EndIf
	EndIf

	If INCLUI .AND. CT0->CT0_ALIAS == "CV0"
		bDescriEnt := &("{|| Alltrim(M->"+CT0->CT0_CPOCHV+")+'-'+Alltrim(M->"+CT0->CT0_CPODSC+" ) }")
	EndIf
	If ValType(oTree) == "O"  //arvore
	   	oTree:AddItem( Eval(bDescriEnt),;  //descricao
						cAliasEnt+"ZZ"+StrZero((cAliasEnt)->(Recno()),6),;  //cargo
						"IndicatorCheckBox",; //bitmap fechado
						"IndicatorCheckBoxOver",;  //bitmap aberto
						2,;                        //tipo 1 = pai 2= filho
						bAtua_Enchoice)  //bAction
	Else	//list box
		aAdd(__aViewBox[Val(CT0->CT0_ID)], Eval(bDescriEnt) )
		aAdd( __aRecnoBox[ Val(CT0->CT0_ID) ], {Alias(), Recno() } )
		__aLstBox[Val(CT0->CT0_ID)]:refresh()
		__aLstBox[Val(CT0->CT0_ID)]:DrawSelect()
		__aLstBox[Val(CT0->CT0_ID)]:SetFocus()
	EndIf

ElseIf nOpcEnt == 4

	If ValType(oTree) == "O"  //arvore
		oTree:ChangePrompt(Eval(bDescriEnt), oTree:GetCargo())
	Else   //list box
		__aViewBox[Val(CT0->CT0_ID)][__aLstBox[Val(CT0->CT0_ID)]:nAt] := Eval(bDescriEnt)
		__aLstBox[Val(CT0->CT0_ID)]:DrawSelect()
		__aLstBox[Val(CT0->CT0_ID)]:SetFocus()
	EndIf

ElseIf nOpcEnt == 5

	If ValType(oTree) == "O"  //arvore
		oTree:DelItem() //Remove a configura็ใo da แrvore
	Else   //list box
		__aViewBox[Val(CT0->CT0_ID)][__aLstBox[Val(CT0->CT0_ID)]:nAt] := Replicate("*******",5)
		__aLstBox[Val(CT0->CT0_ID)]:DrawSelect()
		__aLstBox[Val(CT0->CT0_ID)]:SetFocus()
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbSaveReg  บAutor  ณMicrosiga         บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os dados                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbSaveReg(cAlias,lInclui,nEntID)

Local lRet      := .T.
Local nX        := 0
Local cAuxMem   := ""
Local aEaiRet   := {}
Private bCampo := { |nField| FieldName(nField) }

Begin Transaction

dbSelectArea(cAlias)
(cAlias)->(DbSetOrder(1))
(cAlias)->(RecLock(cAlias,lInclui)) //Se lInclui == .F. Altera o registro
For nX := 1 TO FCount()
	cAuxMem := Alltrim("M->"+FieldName(nX))
	If Type(cAuxMem) != "U"  .AND. ValType(&(cAuxMem)) != "U"
		If "FILIAL" $ cAuxMem
			FieldPut(nX, xFilial(cAlias))
		ElseIf ValType(&cAuxMem)<> 'U'
			FieldPut(nX, &(cAuxMem))
		Endif
	EndIf
Next nX
(cAlias)->(MsUnlock())

If __lEAI800A
	If !empty(CV0->CV0_CODIGO)
		aEaiRet := CTBA800A()

		If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
			aEaiRet := {.F., ""}
		Endif
		If !aEaiRet[1]
			Help(,, "CTBA080INTEGERRO",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Verifique se a integra็ใo estแ configurada corretamente."
			DisarmTransaction()
			lRet := .F.
		EndIf
	EndIf
EndIf

End Transaction

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCV0Item  บAutor  ณMicrosiga         บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPr๓ximo numero de item da entidade                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbCV0Item(cPlanEnt,cCOD,nOpc)

Local cItem	   := "0"
Local cRet			:= ""
Local cQuery	:= ''
Local cAliasCv0:= ""
Local aArea	 := GetArea()

Default cCOD := ""
Default nOpc := 3

If nOpc == 3
	//Realiza a query para descobrir o maior valor de CVO_ITEM cadastrado
	cQuery := "SELECT  max(CV0_ITEM) as CV0_ITEM"
	cQuery += "FROM "+  RetSqlName('CV0')
	cQuery += "Where CV0_FILIAL = '" + xFilial("CV0") + "'"
	cQuery += " and CV0_PLANO = '" + cPlanEnt + "'"
	cQuery += " and D_E_L_E_T_ = ' ' "
	cQuery 		:= ChangeQuery( cQuery )
	cAliasCv0 	:= GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCv0 )
	If (cAliasCv0)->(!Eof()) // Caso exista um maior item atribui a variavel o maximo valor
		cItem:= (cAliasCv0)->CV0_ITEM
	Endif
	(cAliasCv0)->(dbCloseArea())
	RestArea(aArea)
	cItem := Soma1(cItem) // Soma um valor ao Ultimo Item (independente se for alfa ou numerico)
	cRet := PadL(cItem,Len(CV0->CV0_ITEM),'0') //Adiciona o zero a esquerda quando o valor for unitแrio
Else
	DbSelectArea("CV0")
	DbSetOrder(1) //CV0_FILIAL+CV0_PLANO+CV0_CODIGO
	dbSeek(xFilial("CV0")+cPlanEnt+cCOD)
	cRet := CV0->CV0_ITEM
EndIf

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbVldCpo   บAutor  ณMicrosiga         บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da existencia de campos no SX3                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbVldCpo()
Local lRet := .T.
Do Case
   	Case !ValidX3Cpo(M->CT0_CPOCHV)
		lRet := .F.
   	Case !ValidX3Cpo(M->CT0_CPODSC)
		lRet := .F.
	Case !CtbCT0Plano(M->CT0_ENTIDA, .T.)
		lRet := .F.
EndCase

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbExistCV0 บAutor  ณMicrosiga         บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosicionamento na tabela CV0                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbExistCV0()
dbSelectArea("CV0")
dbSetOrder(1)
Return( DbSeek(xFilial("CV0")+M->CT0_ENTIDA))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbEntTree บAutor  ณMicrosiga          บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMontagem da arvore CV0                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbEntTree(oTree,cTitle,cEntSup,bSeek,bWhile,bDesc,bAction,cAliasEnt,nEntID,cCampo)

oTree:Reset()

dbSelectArea(cAliasEnt)
dbSetOrder(aIndexes[nEntID][2])

oTree:AddItem( cTitle, cAliasEnt+"ZZ000000", "IndicatorCheckBox", "IndicatorCheckBoxOver", 1, bAction, /*bRClick*/, /*bDblClick*/ )
oTree:TreeSeek(cAliasEnt+"ZZ000000")

CtbEntSup(oTree, cEntSup, bSeek, bWhile, bDesc, bAction, cAliasEnt, nEntID, cCampo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbEntSup บAutor  ณMicrosiga           บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbEntSup(oTree, cEntSup, bSeek, bWhile, bDesc, bAction, cAliasEnt, nEntID, cCampo)
Local aArea 	:= GetArea()
Local cEntAux  	:= ""
Local lEntAux2	:= .T.
Default bAction	:= {||}

dbSeek(Eval(bSeek))

Do While (cAliasEnt)->(!Eof() .And. Eval(bWhile))

    If cAliasEnt == "CV0"
		lEntAux2 := !Empty(CV0->(FieldGet(FieldPos("CV0_ITEM"))))
	Else
		lEntAux2 := .T.
	EndIf

	If lEntAux2	//Valida็ใo para nใo incluir o registro de inclusใo do plano na arvore

		oTree:AddItem( Eval(bDesc), cAliasEnt+StrZero( (cAliasEnt)->(Recno()),6 ), "IndicatorCheckBox", "IndicatorCheckBoxOver", 2, bAction, /*bRClick*/, /*bDblClick*/ )
		oTree:TreeSeek(cAliasEnt+StrZero((cAliasEnt)->(Recno()),6))

		cEntAux := (cAliasEnt)->(FieldGet(FieldPos(cCampo)))

		If !Empty(cEntAux)
			CtbEntSup(oTree, cEntAux, bSeek, bWhile, bDesc, bAction, cAliasEnt, nEntID, cCampo)
			oTree:TreeSeek(cAliasEnt+"ZZ000000")
	    EndIf

	EndIf

	(cAliasEnt)->( dbSkip() )

EndDo


RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbPlano  บAutor  ณMicrosiga           บ Data ณ  25/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe tela para criar o relacionamento do plano com a enti-บฑฑ
ฑฑบ          ณ dade na primeira inclusใo.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CtbPlano                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbPlano(cPlanoCT0)

Local aParametros := {}
Local cTitle      := STR0011 //"Cadastro"
Local aRet        := {}
Local lRet        := .F.
Local bOk         := {|| ExistChav("CV0",aRet[1],1)}

DEFAULT cPlanoCT0 := Replicate(" ",LEN(CV0->CV0_PLANO))

If !Empty(cPlanoCT0)

	aParametros := {{ 1 ,STR0022	,cPlanoCT0                          	,"@E 99" ,"" ,"" ,"" ,2 ,.T. },; //"Plano"
					{ 1 ,STR0023	,Replicate(" ",LEN(CV0->CV0_DESC))  	,"@!"    ,"" ,"" ,"" ,65,.T. }}  //"Descri็ใo"

	If ParamBox(aParametros,cTitle,@aRet,bOk,,,,,,,.F.,.F.)

		aRet[1] := PadL(AllTrim(aRet[1]),2,"0")
		If CtbCT0Plano( aRet[1] )  //verifica na CT0 se o plano nao foi utilizado ainda
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGrava o plano no campo CT0_ENTIDA para relacionamento com a tabela CV0ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			CtbAltPlano(aRet[1])
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGera o primeiro registro relacionado a entidade na tabela CV0ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			CtbGrvCV0(aRet)
		EndIf

	EndIF
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCT0Plano บAutor  ณMicrosiga         บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao de existencia do plano.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbCT0Plano(cCodPlano,lAlt)
Local lRet := .T.
Local nRecCT0 := CT0->( Recno() )

DEFAULT lAlt := .F.

If !Empty(cCodPlano)
	DbSelectArea("CT0")
	dbSeek(xFilial("CT0"))

	While CT0->(!Eof() .And. CT0_FILIAL == xFilial("CT0") )

		If  CT0->(Recno()) != nRecCT0 .And. CT0->CT0_ENTIDA == cCodPlano
			lRet := .F.
			If lAlt
				MsgInfo(STR0029,STR0013) //"Plano em uso. Selecione outro plano."###"Aten็ใo!"
			Else
				MsgInfo(STR0024,STR0013) //"C๓digo do plano jแ cadastrado"###"Aten็ใo!"
			EndIf
			Exit
		EndIf

		CT0->(DbSkip())

	EndDo

	DbSelectArea("CT0")
	dbGoto(nRecCT0)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbGrvCV0 บAutor  ณMicrosiga           บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao do registro do plano.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbGrvCV0(aRet)
dbSelectArea("CV0")
dbSetOrder(1)

If ! dbSeek(xFilial("CV0")+aRet[1])
	RecLock("CV0", .T.)
	CV0->CV0_FILIAL := xFilial("CV0")
	CV0->CV0_PLANO  := aRet[1]
	CV0->CV0_DESC 	:= aRet[2]
	CV0->CV0_DTIBLQ := Ctod("")
	CV0->CV0_DTFBLQ := dDatabase
	CV0->CV0_DTIEXI := Ctod("")
	CV0->CV0_DTFEXI := Ctod("")
	MsUnlock("CV0")
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbAltPlano บAutor  ณMicrosiga         บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao do plano na tabela CT0                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbAltPlano(cCodPlano)
dbSelectArea("CT0")
//recno ja esta posicionado
Reclock("CT0",.F.)
REPLACE CT0_ENTIDA With cCodPlano
MsUnLock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbRecnCT0 บAutor  ณMicrosiga          บ Data ณ  07/05/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o recno do registro da tabela CT0                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbRecnCT0(cIdEntid)

Local nRet := 0

DbSelectArea("CT0")
DbSetOrder(1)
If DbSeek( xFilial("CT0")+ cIdEntid )
	nRet := CT0->(Recno())
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtb800Auto บAutor  ณMarcos R. Pires    บ Data ณ  07/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina automatica de inclusao de contas das entidades adi- บฑฑ
ฑฑบ          ณ cionais.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTB800Auto(nOpcAuto,aRotAuto)
Local nOpca := 0
Local nRecnoCV0
Local nPosPlano := Ascan(aRotAuto,{|x| x[1] =='CV0_PLANO'})
Local nPosItem	:= Ascan(aRotAuto,{|x| x[1] =='CV0_ITEM'})
Local nPosCod		:= Ascan(aRotAuto,{|x| x[1] =='CV0_ITEM'})

If (nOpcAuto == 3) .And. (nPosPlano > 0) .And. (nPosItem > 0)
	aRotAuto[nPosItem][2] := CtbCV0Item(aRotAuto[nPosPlano][2])
EndIf

RegToMemory("CV0",If(nOpcAuto == 3,.T.,.F.),.F.)

If EnchAuto("CV0",aRotAuto,"CtbValidEnt("+Alltrim(Str(nOpcAuto))+",Nil,'CV0')",nOpcAuto)
	DbSelectArea("CV0")
	DbSetOrder(1)
	If DbSeek(xFilial("CV0")+M->CV0_PLANO+M->CV0_CODIGO)
		nRecnoCV0 := CV0->(Recno())
	Else
		nRecnoCV0 := 0
	EndIf

	If nOpcAuto == 3 //Inclusao
		nOpca := AxIncluiAuto("CV0",/*cTudoOk*/,/*cTransact*/,nOpcAuto,/*nlinha*/)
	ElseIf nOpcAuto == 4 //Alteracao
		nOpca := AxIncluiAuto("CV0",/*cTudoOk*/,/*cTransact*/,nOpcAuto,nRecnoCV0)
	ElseIf nOpcAuto == 5 //Exclusao
		If !Empty(nRecnoCV0)
			CV0->(DbGoTo(nRecnoCV0))
			RecLock("CV0",.F.)
			CV0->(DbDelete())
			CV0->(MsUnLock())
		EndIf
    EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBConEInfบAutor  ณMarcos R. Pires     บ Data ณ  18/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta a existencia de entidade inferior                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTBConEInf(_cPlanEnt,_cCodEnt,cAliasEnt,nEntID)
Local lRet
Local aSaveArea := GetArea()
Local aSaveEnt	:= (cAliasEnt)->(GetArea())

If cAliasEnt<>"CV0"
	_cPlanEnt := ''
EndIf
DbSelectArea(cAliasEnt)
DbSetOrder(aIndexes[nEntID][2])
lRet := DbSeek(xFilial(cAliasEnt)+_cPlanEnt+_cCodEnt) //Se houver conta inferior nao permite que

RestArea(aSaveEnt)
RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBEntGtInบAutor  ณMarcelo Akama       บ Data ณ  14/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna os indices das entidades							  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBEntGtIn()
Local aArea		:= GetArea()
Local aAreaCT0	:= CT0->(GetArea())
Local aAreaSIX	:= SIX->(GetArea())
Local aAreaSX3	:= SX3->(GetArea())
Local aRet		:= {}
Local nId
Local cAlias
Local cCpoSup
Local cCpoChv
Local cCpoDsc

dbSelectArea("CT0")
dbSetOrder(1)
dbSeek(xFilial("CT0"))

Do While !CT0->(Eof()) .And. CT0->CT0_FILIAL==xFilial("CT0")

	nId := Val(CT0->CT0_ID)

	If Alltrim(CT0->CT0_ALIAS)=="CV0" .And. Empty(CT0->CT0_CPOSUP)
		RecLock("CT0", .F.)
		CT0->CT0_CPOSUP := "CV0_ENTSUP"
		CT0->(dbCommit())
		CT0->(MsUnLock())
	EndIf

	cAlias  := Alltrim(CT0->CT0_ALIAS)
	cCpoSup := CT0->CT0_CPOSUP
	cCpoChv := CT0->CT0_CPOCHV
	cCpoDsc := CT0->CT0_CPODSC

	If nId<=4
		AADD( aRet, {1, 5} )
	ElseIf cAlias=="CV0"
		AADD( aRet, {1, 3} )
	EndIf

	CT0->(dbSkip())
EndDo

RestArea(aAreaSIX)
RestArea(aAreaSX3)
RestArea(aAreaCT0)
RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTB800WHENบAutor  ณ Acacio Egas        บ Data ณ  11/24/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Condi็ใo de altera็ใo do campo.                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTB800WHEN()
Local lRet		:= .T.
Local cFuncAux	:= FUNNAME()

If cFuncAux == "CTBA050" .Or. cFuncAux == "CTBA800" .Or. cFuncAux == "CTBA005"
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbAddTreeบAutor  ณMicrosiga           บ Data ณ  10/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carregar os nos do proximo nivel do plano de entidades     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbAddTree(oTree, cAlias, cCampo, cEntSup, bSeek, bWhile, bDescNode, bAction, cCpoSup)
Local aArea := GetArea()
Local aAreaAux := (cAlias)->( GetArea() )
Local cEntAux  := ""
Local lEntAux2  := .T.
Local cAliasAux
Local mRecAux
Local cCargoAnt := oTree:GetCargo()
Local nCountNodes := 0

Default bAction := {||}

cAliasAux := Left(oTree:GetCargo(),3)
nRecAux := Val(Right(oTree:GetCargo(),6))

dbSelectArea(cAliasAux)
dbGoto(nRecAux)
If Subs(oTree:GetCargo(),4,2) != "YY"
	cEntSup := &cCampo
	RestArea(aAreaAux)
Else
	cEntSup := &cCpoSup  //"YY"=continuacao
EndIf

If Subs(oTree:GetCargo(),4,2) != "YY"
	dbSeek(Eval(bSeek))
EndIf

While (cAlias)->(!Eof() .And. Eval(bWhile))

	If cAlias == "CV0" //Identifica se ้ o registro de inclusใo do plano
		lEntAux2 := !Empty((cAlias)->(FieldGet(FieldPos("CV0_ITEM"))))
	EndIf

	If lEntAux2	//Valida็ใo para nใo incluir o registro de inclusใo do plano na arvore

		cEntAux := (cAlias)->(FieldGet(FieldPos(cCampo)))
		If !oTree:TreeSeek(cAlias+"ZZ"+StrZero((cAlias)->(Recno()),6))
			oTree:TreeSeek(cCargoAnt)
		   	oTree:AddItem( Eval(bDescNode),;  //descricao
						cAlias+"ZZ"+StrZero((cAlias)->(Recno()),6),;  //cargo
						"IndicatorCheckBox",; //bitmap fechado
						"IndicatorCheckBoxOver",;  //bitmap aberto
						2,;                        //tipo 1 = pai 2= filho
						,;
						,;
						bAction)  //bAction
			nCountNodes:= nCountNodes+1
		EndIf

	EndIf

	dbSkip()

	If nCountNodes > 300
		If !oTree:TreeSeek(cAlias+"ZZ"+StrZero((cAlias)->(Recno()),6))
			oTree:TreeSeek(cCargoAnt)
		   	oTree:AddItem( STR0032,;  //descricao  "Continua็ใo (Duplo Clique)..."
						cAlias+"YY"+StrZero((cAlias)->(Recno()),6),;  //cargo
						"IndicatorCheckBox",; //bitmap fechado
						"IndicatorCheckBoxOver",;  //bitmap aberto
						2,;                        //tipo 1 = pai 2= filho
						, ; //bAction - bloco de codigo para exibir
						, ;
						bAction ;//DUPLO CLIQUE
						)
			Exit
		EndIf
	EndIf

EndDo


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA800LBox  บAutor  ณMicrosiga           บ Data ณ  24/04/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna objeto list box a ser utilizado nos casos em que    บฑฑ
ฑฑบ          ณo xtree nao comporta por limitacao da quantidade de nos por บฑฑ
ฑฑบ          ณobjeto                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A800LBox(aView,aTitle,oDlg)
Local oFont
Local oLstBox

oLstBox	:= TWBrowse():New( 0,0,0,0,,aTitle,,oDlg,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,,)

oLstBox:Align := CONTROL_ALIGN_ALLCLIENT
oLstBox:SetArray(aView)

Return(oLstBox)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA800MtaArvore บAutorณMicrosiga         บ Data ณ  24/04/2014 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAvalia se pode montar arvore por nivel e retorna false qdo  บฑฑ
ฑฑบ          ณpossuir nos com mais de 5000 itens pendurados alem de       บฑฑ
ฑฑบ          ณretornar false tambe alimenta o array static que serแ utili-บฑฑ
ฑฑบ          ณzado no list-box                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A800MtaArvore()
Local cQuery 	:= ""
Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local cAlias
Local cCodPlano
Local cCpoSup
Local cCpoChv
Local cCpoDesc
Local cAliasQry := GetNextAlias()

//considera que CT0 esta posicionada
If CT0->( ! Eof() )

	cAlias := CT0->CT0_ALIAS
	If cAlias == "CV0"
		cCodPlano := CT0->CT0_ENTIDA
	EndIf
	cCpoSup := CT0->CT0_CPOSUP
	cCpoChv := CT0->CT0_CPOCHV
	cCpoDesc := CT0->CT0_CPODSC

	cQuery += " SELECT "+cCpoSup+", COUNT(*) NCOUNT FROM "+RetSqlName(cAlias)
	cQuery += " WHERE "
	cQuery += " "+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' "
	If cAlias == "CV0"
		cQuery += " AND CV0_PLANO = '"+cCodPlano+"' "
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY "+cCpoSup

	If ( Select ( cAliasQry ) <> 0 )
		dbSelectArea ( cAliasQry )
		dbCloseArea ()
	Endif

  	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)

	dbSelectArea ( cAliasQry )
	While ! Eof()
		If (cAliasQry)->NCOUNT > 5000
			lRet := .F.
			Exit
		EndIf
		(cAliasQry)->( dbSkip() )
	EndDo


	If ! lRet //se encontrou registros sem hierarquia - conta superior
		//fecha o alias da query count(*) e reabre query com campos para list box
		dbSelectArea ( cAliasQry )
		dbCloseArea ()

		cQuery := " SELECT "+cCpoChv+", "+cCpoDesc+", R_E_C_N_O_ REGAUX FROM "+RetSqlName(cAlias)
		cQuery += " WHERE "
		cQuery += " "+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' "
		If cAlias == "CV0"
			cQuery += " AND CV0_PLANO = '"+cCodPlano+"' "
		EndIf
		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY "+cCpoChv

	  	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)

		dbSelectArea ( cAliasQry )
		__aViewBox[ Val(CT0->CT0_ID) ] := {}
		__aRecnoBox[ Val(CT0->CT0_ID) ] := {}

		//carrega array static que vai ser utilizado na list box
		While (cAliasQry)->( ! Eof() )

			aAdd( __aViewBox[ Val(CT0->CT0_ID) ], AllTrim(&(cCpoChv))+"-"+Alltrim(&(cCpoDesc)))
			aAdd( __aRecnoBox[ Val(CT0->CT0_ID) ], {cAlias, (cAliasQry)->REGAUX } )
			(cAliasQry)->( dbSkip() )

		EndDo

	EndIf

	dbSelectArea ( cAliasQry )
	dbCloseArea ()

	RestArea(aArea)

Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA800VerRecบAutor  ณMicrosiga           บ Data ณ  24/04/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna nRecnoEnt, nValCT0Id e no caso de list box posicionaบฑฑ
ฑฑบ          ณno alias da entidade                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A800VerRec(oTree, nRecnoEnt, nValCT0Id, aTreeEnt)
Local cAliasRec

If ValType(oTree:GetCargo())<>'C'

	nRecnoEnt := 0

Else

	nValCT0Id := Val(Right(oTree:GetCargo(),2))

	If ValType(aTreeEnt[nValCT0Id]) == "O"  //arvore

		If ValType(aTreeEnt[nValCT0Id]:GetCargo())<>'C'

			nRecnoEnt := 0

		Else

			nRecnoEnt := Val(Right(aTreeEnt[nValCT0Id]:GetCargo(),6))

		EndIf

	Else                              //list box

		cAliasRec := __aRecnoBox[ nValCT0Id, __aLstBox[ nValCT0Id ]:nAT , 1]
		dbSelectArea(cAliasRec)
		nRecnoEnt := __aRecnoBox[ nValCT0Id, __aLstBox[ nValCT0Id ]:nAT , 2]

	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtb800Sup บAutor  ณMicrosiga              บ Data ณ  24/04/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna se objeto e arvore e nao permite digitar ent. superior บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctb800Sup()
Local lRet := .F.
//CT0 tem que estar posicionada
If ValType("__aLstBox") !="A"
	lRet := .T.
Else
	If ValType(__aLstBox[Val(CT0->CT0_ID)]) != "O"  //list box
 		lRet := .T.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA800_Excl บAutor  ณMicrosiga           บ Data ณ  24/04/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInforma que registro esta excluido e nใo permite edi็ใo ou  บฑฑ
ฑฑบ          ณexclusใo                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A800_Excl()
Local lRet := .F.
If ValType(__aLstBox[Val(CT0->CT0_ID)]) == "O"  //list box
	If __aViewBox[Val(CT0->CT0_ID)][__aLstBox[Val(CT0->CT0_ID)]:nAt] == Replicate("*******",5)
		Alert(STR0033) //"Registro Excluido"
		lRet := .T.
	EndIf
EndIf
Return(lRet)
