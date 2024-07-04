#INCLUDE "TMSA440.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

Static lTM440GRV := ExistBlock("TM440GRV")
Static lIntTPR   := SuperGetMV("MV_ROTAINT",,.F.)  .And. AliasInDic("DMS") //Integração TPR	

//-----------------------------------------------------------------------------------------------------------
/* Browse da rotina de Cadastro de Solicitante
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	16/11/2013
@return 	*/
//-----------------------------------------------------------------------------------------------------------

Function TMSA440(xAutoCab, xAutoItens,nOpcAuto)

Local oMBrowse		:= Nil
Local aAutoCab   := {}  // Cabecalho do Solicitante (Rotina Automatica)
Local aAutoItens := {}  // Itens do Solicitante (Rotina Automatica)

Local l440Auto   := xAutoCab <> NIL  .And. xAutoItens <> NIL
Local cRoteiri   := ""

Private aRotina	:= MenuDef()

Default xAutoCab   := {}
Default xAutoItens := {}
Default nOpcAuto   := 0

If lIntTPR .And. FindFunction('TMSROTEIRI')
	cRoteiri:= TMSROTEIRI() 
	lIntTPR:= cRoteiri == '2'   //1-Maplink, 2-TPR
EndIf

If l440Auto
	aAutoCab   := Aclone( xAutoCab )
	aAutoItens	:= Aclone( xAutoItens )
	
	FwMvcRotAuto( ModelDef(), "DUE", nOpcAuto, { { "MdFieldDUE", aAutoCab }, { "MdGridDVJ", aAutoItens }  } )  //Chamada da rotina automatica através do MVC
Else
//===========================================================================================================
// Funcao de BROWSE
//===========================================================================================================

	oMBrowse:= FWMBrowse():New()
	oMBrowse:SetAlias("DUE")
	oMBrowse:SetDescription( OemToAnsi( STR0001 ) )
	oMBrowse:Activate()

EndIf

Return

//===========================================================================================================
/* Retorna o modelo de Dados da rotina Cadastro de Solicitante
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	16/11/2013
@return 	oModel - Modelo de Dados */
//===========================================================================================================
Static Function ModelDef()

Local oModel		:= Nil
Local oStruDUE		:= FwFormStruct( 1, "DUE" )
Local oStruDVJ		:= FwFormStruct( 1, "DVJ" )	
Local lPrdDiv		:= GetMV("MV_PRDDIV",,.F.) // Verifica se permitira a inclusao de um ou mais produtos

oModel	:= MpFormModel():New( "TMSA440", /*bPre*/, { |oModel| PosVldMdl( oModel ) },  { |oModel| CommitMdl( oModel ) }, /*bCancel*/ )

oModel:SetDescription( OemToAnsi(STR0001) )	 

oModel:AddFields( "MdFieldDUE", Nil, oStruDUE )

oModel:SetPrimaryKey( { "DUE_FILIAL", "DUE_CODSOL" } )

oModel:AddGrid( "MdGridDVJ", "MdFieldDUE", oStruDVJ )

oModel:SetRelation( "MdGridDVJ", { { "DVJ_FILIAL", "xFilial( 'DVJ' )" }, { "DVJ_CODSOL", "DUE_CODSOL" } }, DVJ->( IndexKey( 1 ) ) )

oModel:GetModel( "MdGridDVJ" ):SetUniqueLine( { "DVJ_CODPRO" } )

If !lPrdDiv
	oModel:GetModel( "MdGridDVJ" ):SetMaxLine( 1 )
EndIf

oModel:SetVldActivate( { |oModel| VldActdMdl( oModel ) } )

Return( oModel )

//===========================================================================================================
/* Retorna a View (tela) da rotina Cadastro de Solicitante
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	16/11/2013
@return 	oView -  */
//===========================================================================================================
Static Function ViewDef()

Local oModel		:= FwLoadModel( "TMSA440" )
Local oView		:= Nil
Local oStruDUE		:= FwFormStruct( 2, "DUE" )
Local oStruDVJ		:= FwFormStruct( 2, "DVJ" )

oStruDVJ:RemoveField( "DVJ_DDD" )
oStruDVJ:RemoveField( "DVJ_TEL" )
oStruDVJ:RemoveField( "DVJ_CODSOL" )

oView := FwFormView():New()

oView:SetModel( oModel )

oView:CreateHorizontalBox( "Field"	, 060 )
oView:CreateHorizontalBox( "Grid"	, 040 )

oView:AddField( "VwFieldDUE", oStruDUE, "MdFieldDUE"	)

oView:AddGrid( "VwGridDVJ", oStruDVJ, "MdGridDVJ" )
	
oView:SetOwnerView( "VwFieldDUE"	, "Field"	)
oView:SetOwnerView( "VwGridDVJ"		, "Grid"	)
	
oView:EnableTitleView( "VwGridDVJ" ) 
	
Return( oView )

//===========================================================================================================
/* Pré validacao do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		7.00.111010P
@since 	16/11/2013
@return 	lRet */                                                                                                         
//===========================================================================================================
Static Function VldActdMdl( oMdl )

Local aArea		:= GetArea()
Local lRet			:= .T.
Local lTM440MNT   := ExistBlock("TM440MNT")

If lTM440MNT .And. lRet
	lRet:= ExecBlock("TM440MNT",.F.,.F.,{nOpcx})
	If ValType(lRet) == "L" .And. !lRet
		lRet := .F.
	EndIf
EndIf

RestArea( aArea )

Return( lRet )

//===========================================================================================================
/* PÓS validacao do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	16/11/2013
@return 	lRet */
//===========================================================================================================
Static Function PosVldMdl( oMdl )

Local lRet		    := .T.
Local aArea		:= GetArea()
Local nOpcx		:= oMdl:GetOperation()
Local cAliasTop	:= ""
Local cQuery		:= ""

If lRet .And. M->DUE_TIPCOL == '2'  .And. Empty(M->DUE_CEP)
	Help('',1,"OBRIGAT2",,RetTitle('DUE_CEP'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
	lRet := .F.
EndIf

If nOpcx == MODEL_OPERATION_DELETE

	If lRet	
		cAliasTop := GetNextAlias()
		cQuery := " SELECT DT5_CODSOL"
		cQuery += " FROM "
		cQuery += " "+RetSqlName('DT5')+" DT5 "
		cQuery += " WHERE DT5.DT5_FILIAL = '"+xFilial("DT5")+"'"
		cQuery += " AND DT5.DT5_CODSOL = '"+DUE->DUE_CODSOL+"'"
		cQuery += " AND DT5.DT5_STATUS <> '"+StrZero(9,Len(DT5->DT5_STATUS))+"'"
		cQuery += " AND DT5.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
		If !Eof()
			Help(1,'','TMSA44001') // Existe Solicitacao de Coleta utilizando este solicitante ...
			dbCloseArea()
			lRet := .F.
		EndIf
		dbCloseArea()	
	EndIf

	If lRet
		cAliasTop := GetNextAlias()
		cQuery := " SELECT DT4_CODSOL"
		cQuery += " FROM "
		cQuery += " "+RetSqlName('DT4')+" DT4 "
		cQuery += " WHERE DT4.DT4_FILIAL  = '"+xFilial("DT4")+"'"
		cQuery += " AND DT4.DT4_CODSOL = '"+DUE->DUE_CODSOL+"'"
		cQuery += " AND DT4.DT4_STATUS <> '"+StrZero(9,Len(DT4->DT4_STATUS))+"'"
		cQuery += " AND DT4.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
		If !Eof()
			Help(1,'','TMSA44002') // Existe Cotacao de Frete utilizando este solicitante ...
			dbCloseArea()
			lRet := .F.
		EndIf
		dbCloseArea()
	EndIf
	
	//-- Carga Fechada
	
	If TMSCFec() .And. lRet
		cAliasTop := GetNextAlias()
		cQuery := " SELECT DF0_CODSOL"
		cQuery += " FROM "
		cQuery += " "+RetSqlName('DF0')+" DF0 "
		cQuery += " WHERE DF0.DF0_FILIAL  = '"+xFilial("DF0")+"'"
		cQuery += "		AND DF0.DF0_CODSOL = '"+DUE->DUE_CODSOL+"'"
		cQuery += " 	AND DF0.DF0_STATUS  <> '"+StrZero(9,Len(DF0->DF0_STATUS))+"'"
		cQuery += " 	AND DF0.D_E_L_E_T_  = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
		If !Eof()
			Help(1,'','TMSA44003') //"Existe Agendamento utilizando este solicitante"
			dbCloseArea()
			lRet := .F.
		EndIf
		dbCloseArea()
	EndIf

EndIf 

RestArea( aArea )

Return( lRet )

//===========================================================================================================
/* Gravação do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	16/11/2013
@return 	lRet */
//===========================================================================================================
Static Function CommitMdl( oMdl )

Local lRet	   := .T.
Local nOpcx	   := oMdl:GetOperation()
Local aArea	   := DUE->( GetArea() )
Local oMdlDAR  := Nil

//-- Atualizacao do movimento de viagem
If nOpcx == MODEL_OPERATION_UPDATE 
	Begin Transaction
		If M->DUE_CEP <> DUE->DUE_CEP
			MsgRun(STR0002,,{|| TmsCEPDUD(M->DUE_CEP,,,DUE->DUE_CODSOL) })  // "Aguarde, Atualizando movimento de viagem." 
		EndIf
	End Transaction

ElseIf nOpcx == MODEL_OPERATION_DELETE
	If lIntTPR   //Integração TPR
		DbSelectArea("DAR")
		DAR->(dbSetOrder(1))
		If DAR->(MsSeek(xFilial("DAR")+DUE->DUE_FILIAL+"DUE"+DUE->DUE_CODSOL))
			oMdlDAR := FWLoadModel( 'TMSAO15' )
			oMdlDAR :SetOperation( MODEL_OPERATION_DELETE )
			oMdlDAR :Activate()
			lRet := oMdlDAR:VldData()
			
			If lRet
				lRet := oMdlDAR:CommitData()
			EndIf
		
			oMdlDAR:DeActivate()
		EndIf
	EndIf	
EndIf

lRet := FwFormCommit( oMdl )

If lRet .And. nOpcx == MODEL_OPERATION_UPDATE .Or. nOpcx == MODEL_OPERATION_INSERT
	If lIntTPR .And. ExistFunc("TMSIntRot")  //Integração Rota Inteligente, Integração TPR
		TMSIntRot("DUE",DUE->(Recno()))
	EndIf	
EndIf

If	lTM440GRV .And. lRet
	ExecBlock('TM440GRV',.F.,.F.,{ nOpcx, M->DUE_CODSOL  })
EndIf

RestArea( aArea )

Return( lRet )

//===========================================================================================================
/* Retorna as operações disponiveis para o Cadastro de Solicitante
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	16/11/2013
@return 	aRotina - Array com as opçoes de Menu */
//===========================================================================================================
Static Function MenuDef()

Private aRotina:=		{{ STR0003		,"AxPesqui"				,0 , 1,,.F. },;  	//"Pesquisar"
						{ STR0004		,"VIEWDEF.TMSA440"		,0 , 2 },;  		//"Visualizar"
						{ STR0005		,"VIEWDEF.TMSA440"		,0 , 3 },;  		//"Incluir"
						{ STR0006		,"VIEWDEF.TMSA440"		,0 , 4 },;  		//"Alterar"
						{ STR0007		,"VIEWDEF.TMSA440"		,0 , 5 }}    		//"Excluir"


If ExistBlock("TM440MNU")
	ExecBlock("TM440MNU",.F.,.F.)
EndIf

Return(aRotina)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA440Vld³ Autor ³ Eduardo de Souza      ³ Data ³ 13/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao dos campos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA440Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA440                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA440Vld()

Local cCampo := ReadVar()
Local lRet   := .T.

If cCampo $ "M->DUE_CODCLI;M->DUE_LOJCLI"
	If ( lRet := ExistCpo("SA1",M->DUE_CODCLI+AllTrim(M->DUE_LOJCLI)) )
		If !Empty(M->DUE_CODCLI) .And. !Empty(M->DUE_LOJCLI)
			M->DUE_EST    := SA1->A1_EST
			M->DUE_CDRSOL := SA1->A1_CDRDES
			M->DUE_MUN    := Padr(Posicione("DUY",1,xFilial("DUY")+M->DUE_CDRSOL,"DUY_DESCRI"),Len(DUE->DUE_MUN))
			M->DUE_DDD	  := SA1->A1_DDD
			M->DUE_TEL	  := SA1->A1_TEL
		EndIf
	EndIf
ElseIf cCampo == "M->DUE_CDRSOL"
	If AllTrim(Posicione("DUY",1,xFilial("DUY")+M->DUE_CDRSOL,"DUY_EST")) <> AllTrim(M->DUE_EST)
		Help(" ",1,"TMSA44004") // "O estado regiao informada esta diferente do estado do solicitante."
		lRet := .F.
	Else
		M->DUE_MUN := DUY->DUY_DESCRI
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA440Whn³ Autor ³ Eduardo de Souza      ³ Data ³ 13/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao dos campos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA440Whn()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA440                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA440Whn()

Local cCampo := ReadVar()
Local lRet   := .T.

If cCampo == "M->DUE_EST"
	If Type("M->DUE_CODCLI")=="C" .And. Type("M->DUE_LOJCLI")=="C"
		lRet := Empty(M->DUE_CODCLI) .Or. Empty(M->DUE_LOJCLI)
	EndIf
EndIf

Return lRet