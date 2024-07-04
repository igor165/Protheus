#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA580.CH"

STATIC lLegend := .T.
STATIC oMdlEsc

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA580()
Cadastro de Escalas

@Return 	nil
@author	Serviços
@since 		16/05/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA580()
Local oBrowse
Local aLCfg := {}

oBrowse := FwMBrowse():New()

oBrowse:SetAlias("TDW")

oBrowse:SetDescription(STR0001) // Cadastro de Escalas
oBrowse:DisableDetails()

// Legendas
oBrowse:AddLegend( "TDW_STATUS=='1'", "BR_VERDE"   , STR0002 ) // Escala Ativa
oBrowse:AddLegend( "TDW_STATUS=='2'", "BR_VERMELHO", STR0003 ) // Escala Inativa

aLCfg := {"",{|| At580LCFBr() },"C","@BMP",0,1,0,.F.,{||.T.},.T.,{|| At580LCfg() },,,,.F.}
oBrowse:AddColumn(aLCfg)

oBrowse:Activate()

Return(Nil)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Cadastro de Escalas

@Return	MenuDef
@author 	Serviços
@since 		16/05/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0004 	ACTION "PesqBrw" 										OPERATION 1	ACCESS 0	// "Pesquisar"
ADD OPTION aRotina TITLE STR0005 	ACTION "TEC580Ope(1)"							OPERATION 2 ACCESS 0	// "Visualizar"
ADD OPTION aRotina TITLE STR0006 	ACTION "TEC580Ope(3)" 	    					OPERATION 3	ACCESS 0 	// "Incluir"
ADD OPTION aRotina TITLE STR0007	ACTION "TEC580Ope(4)"							OPERATION 4	ACCESS 0 	// "Alterar"
ADD OPTION aRotina TITLE STR0078 	ACTION 'AT580ImpEs()' 			                        OPERATION 3 ACCESS 0 	//"Geração de Escala"

Return(aRotina)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Cadastro de Escalas

@Return 	model
@author 	Serviços
@since 		16/05/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruTDW 	:= FWFormStruct(1,"TDW")
Local oStruTDX 	:= FWFormStruct(1,"TDX")
Local oStruTGX 	:= FWFormStruct(1,"TGX")
Local oStrSTDY 	:= FWFormStruct(1,"TDY")
Local oStrFTDY 	:= FWFormStruct(1,"TDY")
Local oStruTGW 	:= FWFormStruct(1,"TGW")
Local bLinePost	:= { |oMdlG,nLine,cAcao,cCampo| PosLinTDX(oMdlG, nLine, cAcao, cCampo) }
Local bLinePre   	:= { |oMdlG,nLine,cAcao,cCampo| PreLinTGW(oMdlG, nLine, cAcao, cCampo) }
Local bTDYPos		:= { |oMdlG,nLine,cAcao,cCampo| PoslinTDY(oMdlG, nLine, cAcao, cCampo) }
Local aAux			:= {}
Local aLoadFilter	:= {}
Local bCommit		:= { |oModel| At580Cmt(oModel) }
Local lRplFer 		:= TDW->( ColumnPos('TDW_RPLFER')) > 0
Local bPosVld		:= { |oMdlG,nLine,cAcao,cCampo| At580PosVl(oMdlG, nLine, cAcao, cCampo, lRplFer) }   

lLegend := .T.

aAux := FwStruTrigger("TDX_TURNO","TDX_DESTUR","Posicione('SR6',1,xFilial('SR6')+FwFldGet('TDX_TURNO'),'R6_DESC')",.F.,Nil,Nil,Nil)
oStruTDX:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TGW_COBTDX","TGW_COBTIP","At580CobTip(FwFldGet('TGW_COBTDX'),.F.)",.F.,Nil,Nil,Nil)
oStruTGW:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

If lRplFer
	aAux := FwStruTrigger("TDW_RPLFER","TDW_RPLFER","At580GatRp(FwFldGet('TDW_RPLFER'))",.F.,Nil,Nil,Nil)
	oStruTDW:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
	oStruTDW:SetProperty( "TDW_RPLFER", MODEL_FIELD_VALID, {||At580VldRp() } )
Endif

// Legenda do Efetivo
oStruTDX:AddField(STR0008,STR0008,"TDX_SIT","BT",1,0,{||At580GetLE()}/*bValid*/,/*bWhen*/, /*aValues*/,.F.,{||At580LgEfe()},/*lKey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/) //"Status"

oStruTDX:SetProperty( "TDX_CODTDW", MODEL_FIELD_OBRIGAT, .F. )
oStruTDX:SetProperty( "TDX_QUANT" , MODEL_FIELD_OBRIGAT, .F. )
oStruTGX:SetProperty( "TGX_CODTDW", MODEL_FIELD_OBRIGAT, .F. )
oStruTGX:SetProperty( "TGX_QUANT" , MODEL_FIELD_OBRIGAT, .F. )
oStrSTDY:SetProperty( "TDY_CODTDX", MODEL_FIELD_OBRIGAT, .F. )
oStrFTDY:SetProperty( "TDY_CODTDX", MODEL_FIELD_OBRIGAT, .F. )
oStruTGW:SetProperty( "TGW_EFETDX", MODEL_FIELD_OBRIGAT, .F. )

oStruTDX:SetProperty( "TDX_TURNO", MODEL_FIELD_VALID, { || At580SeqVld( FwFldGet("TDX_TURNO"), FwFldGet("TDX_SEQTUR"), .T. ) } )
oStruTDX:SetProperty( "TDX_SEQTUR", MODEL_FIELD_VALID, { || At580SeqVld( FwFldGet("TDX_TURNO"), FwFldGet("TDX_SEQTUR") ) } )
oStruTGW:SetProperty( "TGW_COBTDX", MODEL_FIELD_VALID, { || At580CobTip( FwFldGet("TGW_COBTDX"), .T. ) } )

oModel := MPFormModel():New( "TECA580", /*bPreValidacao*/, bPosVld, bCommit, /*bCancel*/ )

oModel:AddFields( "TDWMASTER", /*cOwner*/, oStruTDW, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Grid de Efetivos
oModel:AddGrid("TDXDETAIL","TDWMASTER",oStruTDX,/*bLinePre*/, bLinePost, /*bPreVal*/, /*bPosVal*/)
oModel:SetRelation("TDXDETAIL",{{"TDX_FILIAL","xFilial('TDX')"},{"TDX_CODTDW","TDW_COD"}},TDX->(IndexKey(2)))

// Grid de Cobertura
oModel:AddGrid("TGXDETAIL","TDWMASTER",oStruTGX,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/)
oModel:SetRelation("TGXDETAIL",{{"TGX_FILIAL","xFilial('TGX')"},{"TGX_CODTDW","TDW_COD"}},TGX->(IndexKey(2)))

// Grid de Configuração
oModel:AddGrid("TGWDETAIL","TDXDETAIL",oStruTGW, bLinePre, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/)
oModel:SetRelation("TGWDETAIL",{{"TGW_FILIAL","xFilial('TGW')"},{"TGW_EFETDX","TDX_COD"}},TGW->(IndexKey(1)))

// Grid de Exceções
oModel:AddGrid("STDYDETAIL","TDXDETAIL",oStrSTDY,/*bLinePre*/,bTDYPos /*bLinePost*/, /*bPreVal*/, /*bPosVal*/)
oModel:SetRelation("STDYDETAIL",{{"TDY_FILIAL","xFilial('TDY')"},{"TDY_CODTDX","TDX_COD"}},TDY->(IndexKey(2)))

// Grid de Exceções de Feriados
oModel:AddGrid("FTDYDETAIL","TDXDETAIL",oStrFTDY,/*bLinePre*/, bTDYPos /*bLinePost*/, /*bPreVal*/, /*bPosVal*/)
oModel:SetRelation("FTDYDETAIL",{{"TDY_FILIAL","xFilial('TDY')"},{"TDY_CODTDX","TDX_COD"}},TDY->(IndexKey(2)))

oModel:SetDescription( STR0001 ) // "Cadastro de Escalas"

/* --------------- FILTROS -------------------- */

// Grid somente dos dias normais
aLoadFilter := { { "TDY_FERIAD", "'2'", MVC_LOADFILTER_EQUAL } }
oModel:GetModel("STDYDETAIL"):SetLoadFilter( aLoadFilter, /*cLoadFilter*/ )

// Grid somente dos feriados
aLoadFilter := { { "TDY_FERIAD", "'1'", MVC_LOADFILTER_EQUAL } }
oModel:GetModel("FTDYDETAIL"):SetLoadFilter( aLoadFilter, /*cLoadFilter*/ )

/* -------------------------------------------- */

oModel:GetModel("TGXDETAIL"):SetOptional(.T.)
oModel:GetModel("STDYDETAIL"):SetOptional(.T.)
oModel:GetModel("FTDYDETAIL"):SetOptional(.T.)
oModel:GetModel("TGWDETAIL"):SetOptional(.T.)

// Para não repetir linhas nos grids de exceção
oModel:GetModel("STDYDETAIL"):SetUniqueLine( { "TDY_DIASEM" } )
oModel:GetModel("FTDYDETAIL"):SetUniqueLine( { "TDY_DIASEM" } )

Return(oModel)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Log de Eventos dos alertas

@Return 	view
@author 	Serviços
@since 		20/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local lGSxInt	:= SuperGetMV("MV_GSXINT",,"2") == "2"
Local oView
Local oModel   := FWLoadModel("TECA580")
Local oStruTDW := FWFormStruct( 2, "TDW", {|cCpo| !( Alltrim(cCpo)$"TDW_STACFG" ) } )
Local oStruTGW := FWFormStruct( 2, "TGW", {|cCpo| !( Alltrim(cCpo)$"TGW_COD#TGW_EFETDX" ) } )
Local oStruTDX := FWFormStruct( 2, "TDX", {|cCpo| !( Alltrim(cCpo)$"TDX_COD#TDX_CODTDW#TDX_TIPO#TDX_STATUS#TDX_QUANT" ) } )
Local oStruTGX := FWFormStruct( 2, "TGX", {|cCpo| !( Alltrim(cCpo)$"TGX_COD#TGX_CODTDW#TGX_QUANT" ) } )
Local oStrSTDY := FWFormStruct( 2, "TDY", {|cCpo| !( Alltrim(cCpo)$"TDY_COD#TDY_CODTDX#TDY_FERIAD#TDY_TROSEQ" ) } )
Local oStrFTDY := FWFormStruct( 2, "TDY", {|cCpo| !( Alltrim(cCpo)$"TDY_COD#TDY_CODTDX#TDY_FERIAD" ) } )

oView := FWFormView():New()
oView:SetModel(oModel)

If lGSxInt
	If TDX->( ColumnPos('TDX_INIHOR') ) > 0 
		oStruTDX:RemoveField( "TDX_INIHOR" )
	EndIf

	If TDW->( ColumnPos('TDW_CODHOR') ) > 0
		oStruTDW:RemoveField( "TDW_CODHOR" )
	EndIf
EndIf

//Campo virtual que indicará se o apontamento do material de consumo foi ou não apurado.
oStruTDX:AddField("TDX_SIT","01",STR0008,STR0008,{},"BT","",Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil) // "Status"

// Ordena a visualização correta do grid de efetivos
oStruTDX:SetProperty( "TDX_TURNO"	, MVC_VIEW_ORDEM, "02" )
oStruTDX:SetProperty( "TDX_DESTUR"	, MVC_VIEW_ORDEM, "03" )
oStruTDX:SetProperty( "TDX_SEQTUR"	, MVC_VIEW_ORDEM, "04" )

// Ordena a visualização correta do grid de cobertura
oStruTGX:SetProperty( "TGX_ITEM"	, MVC_VIEW_ORDEM, "01" )
oStruTGX:SetProperty( "TGX_TIPO"	, MVC_VIEW_ORDEM, "02" )

oView:AddField("VIEW_TDW" , oStruTDW, "TDWMASTER"  )
oView:AddGrid( "VIEW_TDX", oStruTDX, "TDXDETAIL" )
oView:AddGrid( "VIEW_TGX", oStruTGX, "TGXDETAIL" )
oView:AddGrid( "VIEW_STDY", oStrSTDY, "STDYDETAIL" )
oView:AddGrid( "VIEW_FTDY", oStrFTDY, "FTDYDETAIL" )
oView:AddGrid( "VIEW_TGW" , oStruTGW, "TGWDETAIL"  )

oView:AddIncrementField( "VIEW_TGX", "TGX_ITEM" )		// Item Incremental do Grid

// Area tela principal
oView:CreateHorizontalBox("SUPERIOR" , 17 )
oView:CreateHorizontalBox("GRID_TDX" , 30 )
oView:CreateHorizontalBox("INFERIOR" , 53 )

// Area do grid de configuração
oView:CreateVerticalBox( "EFETIVOS" , 046, "GRID_TDX" )
oView:CreateVerticalBox( "ESPACO"   , 001, "GRID_TDX" )
oView:CreateVerticalBox( "COBERTURA", 053, "GRID_TDX" )

// Area do Grid de Efetivos
oView:CreateHorizontalBox( "EFEGRID" , 088, "EFETIVOS" )
oView:CreateHorizontalBox( "ESPGRID" , 002, "EFETIVOS" )
oView:CreateHorizontalBox( "BTNGRID" , 010, "EFETIVOS" )

// Criação das abas
oView:CreateFolder( "ABAS", "INFERIOR" )
oView:AddSheet( "ABAS", "ABA01", STR0009 )  // "Configuração"
oView:AddSheet( "ABAS", "ABA02", STR0010 )  // "Exceções"

// Area das abas
oView:CreateHorizontalBox( "ID_ABA01" , 100,,, "ABAS", "ABA01" ) // Define a área da configuração
oView:CreateHorizontalBox( "ID_ABA02" , 050,,, "ABAS", "ABA02" ) // Define a área de exceções
oView:CreateHorizontalBox( "ID_ABA03" , 050,,, "ABAS", "ABA02" ) // Define a área de exceções de feriados

// Botão de Configuração do Turno
oView:AddOtherObject("BTN_ETDX", {|oPanel| At580BtnCfg(oPanel)	})

oView:SetOwnerView( "VIEW_TDW", "SUPERIOR" )
oView:SetOwnerView( "VIEW_TDX", "EFEGRID" )
oView:SetOwnerView( "BTN_ETDX", "BTNGRID" )
oView:SetOwnerView( "VIEW_TGX", "COBERTURA" )
oView:SetOwnerView( "VIEW_TGW" , "ID_ABA01" )
oView:SetOwnerView( "VIEW_STDY", "ID_ABA02" )
oView:SetOwnerView( "VIEW_FTDY", "ID_ABA03" )

oView:EnableTitleView( "VIEW_TDX" , STR0011 )		// "Efetivos"
oView:EnableTitleView( "VIEW_TGX" , STR0012 ) 	// "Cobertura"
oView:EnableTitleView( "VIEW_STDY", STR0013 )		// "Gerais"
oView:EnableTitleView( "VIEW_FTDY", STR0014 ) 	// "Feriados"

oView:AddUserButton(STR0015,"",{|| At580Turno()},,,) // "Inc. Turno Comp."
oView:AddUserButton(STR0016,"",{|| At580VisTur()},,,) // "Visualizar Turno"
oView:AddUserButton(STR0017,"",{|| At580VisEsc()},,,) // "Visualizar Escala"

IF TableInDic("TXH") .AND. TYPE("INCLUI") == "L" .AND. !INCLUI 
	oView:AddUserButton(STR0079,"",{|| At580MnPl()},,,) // "Manutenções Planejadas"
	oView:AddUserButton(STR0089,"",{|| At580MPlRo()},,,) // "Manutenções Planejadas Rota"
EndIf

If ((TYPE("INCLUI") == "L" .AND. INCLUI) .OR. ((TYPE("ALTERA") == "L" .AND. ALTERA .OR. oView:GetOperation() == 1) .And. TDW->TDW_INTRA != "1"))  
	oStruTDW:RemoveField("TDW_INTRA")
EndIf

oView:SetCloseOnOK( {|| .T. } )

Return(oView)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580Turno()
Inclusão completa de todas as sequencias do turno

@Return 	Nil
@author 	Serviços
@since 		16/05/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580Turno()

Local oModel 	  := FwModelActive()
Local oMdlGes	  := oModel:GetModel("TDXDETAIL")
Local oMdlTDW	  := oModel:GetModel("TDWMASTER")
Local aArea	  := GetArea()
Local cAliasSPJ := GetNextAlias()
Local cTurno	  := ""
Local lRet		  := !Empty(oMdlTDW:GetValue("TDW_DESC")) .And. !Empty(oMdlTDW:GetValue("TDW_STATUS"))
Local aSeqs	  := {}

Local nI

If lRet

	lRet := ConPad1( Nil, Nil, Nil, "SR6", Nil, Nil, .F. ) // Abre a consulta padrão de turno e retorna o turno selecionado

	If lRet

		cTurno := SR6->R6_TURNO

		If MsgYesNo( STR0018 ) // "Deseja realmente incluir o turno com todas as suas sequências ?"

			aSeqs := At580GtSeq(cTurno)

			For nI:=1 To LEn(aSeqs)
				If ! oMdlGes:SeekLine({{"TDX_TURNO",aSeqs[nI][1]},{"TDX_SEQTUR",aSeqs[nI][2]}})

					If	oMdlGes:Length() > 1 .Or. ! Empty(oMdlGes:GetValue("TDX_TURNO"))
						oMdlGes:AddLine()
					EndIf

					oMdlGes:SetValue( "TDX_TURNO" , aSeqs[nI][1]  )
					oMdlGes:SetValue( "TDX_SEQTUR", aSeqs[nI][2] )
					oMdlGes:SetValue( "TDX_QUANT" , 1   )
					oMdlGes:SetValue( "TDX_TIPO"  , "1" )
					oMdlGes:SetValue( "TDX_DESTUR", aSeqs[nI][3] )

				EndIf
			Next nI

		EndIf

	EndIf

Else

	Help( " ", 1, STR0019, Nil, STR0020, 1 )  //"Atenção"#"Descrição/Status da Escala não preenchido. Preencha os campos obrigatorios!"

EndIf

RestArea( aArea )

Return(Nil)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580Init()

Inicializa a descrição do turno

@author 	Serviços
@since		19/05/2014
@return 	cDescricao, CHARACTER, conteúdo da descrição
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580Init(cTurno)
	cRet := ALLTRIM(POSICIONE("SR6",1,XFILIAL("SR6") + cTurno,"R6_DESC"))
Return(cRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580SeqVld()

Valida a sequencia do turno informada

@author 	Serviços
@since		19/05/2014
@return 	lRet, Retorna se é uma sequencia valida.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580SeqVld( cTurno, cSequencia, lTurno )

Local oModel    := FwModelActive()
Local oModelTDX := oModel:GetModel("TDXDETAIL")
Local nLinha    := oModelTDX:Getline()
Local aSaveLine := FwSaveRows()
Local cFilTurno := xFilial( "SPJ")
Local lRet		  := .T.

Local nI
Local oView := NIL

Default lTurno := .F.

If !Empty(cTurno) .And. !Empty(cSequencia)

	dbSelectArea("SPJ")
	SPJ->(dbSetOrder(1))

	lRet := SPJ->( dbSeek( cFilTurno + cTurno + cSequencia ) )

	If lRet

		For nI:=1 To oModelTDX:Length()

			oModelTDX:GoLine(nI)

			If nI <> nLinha .And. !oModelTDX:IsDeleted()
				If oModelTDX:GetValue( "TDX_TURNO" ) == cTurno .And. ;
				   oModelTDX:GetValue( "TDX_SEQTUR" ) == cSequencia
				   lRet := .F.
				   Exit
				EndIf
			EndIf

		Next nI

		If !lRet
			Help( ' ' , 1 , STR0019, , STR0021, 1 , 0 ) // "Sequencia ja cadastrada para a escala!"
		EndIf

	Else

		Help( ' ' , 1 , 'SEQTURNINV' , , STR0022 , 1 , 0 ) // "Sequencia nao cadastrada para o turno"

	EndIf

EndIf

FWRestRows( aSaveLine )

// Valida a obrigatoriedade do turno
If lRet .And. lTurno
	If !Empty( cTurno )
		lRet := ExistCpo( "SR6", cTurno )
	EndIf
EndIf

// Valida a obrigatoriedade da sequencia do turno
If lRet .And. !lTurno
	If oModelTDX:GetValue( "TDX_TIPO" ) == "1"
		lRet := !Empty( cSequencia )
	Else
		lRet := Empty( cSequencia ) .Or. !Empty( cTurno )
	EndIf
EndIf

If lRet .And. !Empty(cTurno) .And. !Empty(cSequencia)

	lLegend := .F.

	oModelTDX:SetValue("TDX_STATUS", "3")
	oModelTDX:SetValue("TDX_SIT", At580LgEfe())

	If !IsBlind()
		oView := FwViewActive()
	EndIf
	If oView <> Nil .And. oView:GetModel():GetId()=="TECA580" .AND. !IsInCallStack("AT580ImpE")
		oView:Refresh("VIEW_TDX")
	EndIf

	lLegend := .T.

EndIf

Return( lRet )


//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTDX
	 Valida a obrigatoriedade do turno e sequencia

@sample	PosLinTDX()

@since		20/05/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Static Function PosLinTDX(oMdlG, nLine, cAcao, cCampo)

Local lRet      := .T.
Local oMdlFull  := FwModelActive()
Local cMsgVld	  := ""

If oMdlFull <> Nil .And. oMdlFull:GetId()=='TECA580'

	If !cAcao == "DELETE"

		If oMdlG:GetValue( "TDX_TIPO" ) == "1"

			lRet := !Empty( oMdlG:GetValue( "TDX_TURNO" ) ) .And. ;
					 !Empty( oMdlG:GetValue( "TDX_SEQTUR" ) )

			cMsgVld := STR0023	//"Turno e sequência obrigatorios para o tipo de escala efetivo!"

		Else

			lRet := Empty( oMdlG:GetValue( "TDX_SEQTUR" ) ) .Or. ;
					 !Empty( oMdlG:GetValue( "TDX_TURNO" ) )

			cMsgVld := STR0024 	//"Sequência informada sem turno!"

		EndIf

	EndIf

EndIf

If !lRet
	Help(,,"AT580OK",,cMsgVld,1,0) // "Turno e sequência obrigatorios para o tipo de escala efetivo!"
EndIf

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTGW
	 Valida a edição das linhas do grid

@sample	PosLinTDX()

@since		23/06/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function PreLinTGW(oMdlG, nLine, cAcao, cCampo)

Local lRet     := .T.
Local oMdlFull := FwModelActive()

If oMdlFull <> Nil .And. oMdlFull:GetId()=="TECA580"
	If !IsInCallStack("At580CfgEfe")
		If cAcao == "DELETE" .Or. cAcao == "UNDELETE" .Or. cAcao == "SETVALUE"
			If !oMdlG:IsInserted()
				lRet := oMdlG:GetValue("TGW_STATUS") <> "1"
			EndIf
		EndIf
	EndIf
EndIf

If !lRet
	Help(,,"AT580OK",,STR0025,1,0) // "Não é possivel editar/deletar esse tipo de periodo!"
EndIf

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580Cmt
	 Realiza a gravação do dados

@sample	At580Cmt(oModel)
@param 		oModel - Model a ser utilizado para a gravação dos dados

@since		21/05/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function At580Cmt(oModel)

Local lRet    := .T.
Local oMdlTDW := oModel:GetModel("TDWMASTER")
Local oMdlEFE := oModel:GetModel("TDXDETAIL")
Local oMdlTGX := oModel:GetModel("TGXDETAIL")
Local oMdlSEM := oModel:GetModel("STDYDETAIL")
Local oMdlFER := oModel:GetModel("FTDYDETAIL")

Local nI, nJ, lOk

lOk := .T.

For nI:=1 To oMdlEFE:Length()

	oMdlEFE:GoLine(nI)

	// Atualiza os campos dos dias normais
	For nJ:=1 To oMdlSEM:Length()

		oMdlSEM:GoLine(nJ)

		If	Empty(oMdlSEM:GetValue("TDY_DIASEM"))
			Loop
		EndIf

		oMdlSEM:SetValue("TDY_FERIAD", "2" )

	Next nJ

	// Atualiza os campos dos feriados
	For nJ:=1 To oMdlFER:Length()

		oMdlFER:GoLine(nJ)

		If	Empty(oMdlFER:GetValue("TDY_DIASEM"))
			Loop
		EndIf

		oMdlFER:SetValue("TDY_FERIAD", "1" )

	Next nJ

	oMdlEFE:SetValue("TDX_TIPO" , "1" )
	oMdlEFE:SetValue("TDX_QUANT", 1   )

	If Empty(oMdlEFE:GetValue("TDX_STATUS")) .Or. ;
		oMdlEFE:GetValue("TDX_STATUS") == "2" .Or. ;
		oMdlEFE:GetValue("TDX_STATUS") == "3"
		lOk := .F.
	EndIf

Next nI

// Grid de cobertura
For nI:=1 To oMdlTGX:Length()
	oMdlTGX:GoLine(nI)
	oMdlTGX:SetValue("TGX_QUANT",1)
Next nI

lLegend := .F.

If lOk
	oMdlTDW:SetValue("TDW_STACFG", "1")
Else
	oMdlTDW:SetValue("TDW_STACFG", "2")
EndIf

lRet 	 := FwFormCommit( oModel )
lLegend := .T.

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580VisTur
	 Visualização do horario padrao do turno para a configuração selecionada


@sample	At580VisTur()

@since		23/05/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function At580VisTur()

Local aArea := GetArea()
Local lRet  := .T.
Local nReg

Private aDias :=	{ ;
						{ STR0026, "S", "1", "5", "2" },;	// "Segunda"
						{ STR0027, "S", "1", "5", "3" },;	// "Terca"
						{ STR0028, "S", "1", "5", "4" },;	// "Quarta"
						{ STR0029, "S", "1", "5", "5" },;	// "Quinta"
						{ STR0030, "S", "1", "5", "6" },;	// "Sexta"
						{ STR0031, "C", "3", "7", "7" },;	// "Sabado"
						{ STR0032, "D", "2", "6", "1" } ;	// "Domingo"
					}

Private nLenaDias    := Len( aDias )
Private cSemana		:= Space( GetSx3Cache( "PJ_SEMANA" , "X3_TAMANHO" ) )
Private cLstSemana	:= cSemana
Private cCalc			:= "SPJ"
Private aRotina 	    := { { STR0004, "PesqBrw"   , 0 , 1,,.F.},;  // "Pesquisar"
	                       { STR0005, "Pona080Vis", 0 , 2 } }  // "Visualizar"

dbSelectArea("SR6")
SR6->(dbSetOrder(1))

lRet := SR6->( dbSeek( xFilial("SR6") + FwFldGet("TDX_TURNO") ) )

If lRet
	nReg := SR6->(Recno())
	Pona080Vis( "SR6", nReg , 2 )
Else
	Help(,,STR0019,,STR0033,1,0) // "Atenção"#"Turno invalido para a consulta!"
EndIf

RestArea( aArea )

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580GtSeq
	 Retorna a sequencia correta do turno


@sample	At580VisEsc()

@since		13/06/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function At580GtSeq(cTurno)

Local cAliasSPJ := GetNextAlias()
Local aSeq		  := {}

BeginSql Alias cAliasSPJ

	SELECT
		SPJ.PJ_TURNO, SPJ.PJ_SEMANA, SR6.R6_DESC
	FROM
		%Table:SPJ% SPJ
	LEFT JOIN %Table:SR6% SR6 ON
		SR6.R6_FILIAL = %xFilial:SR6% AND
		SR6.R6_TURNO = SPJ.PJ_TURNO AND
		SR6.%NotDel%
	WHERE
		SPJ.PJ_FILIAL = %xFilial:SPJ% AND
		SPJ.PJ_TURNO = %Exp:cTurno% AND
		SPJ.%NotDel%
	GROUP BY
		SPJ.PJ_TURNO, SPJ.PJ_SEMANA, SR6.R6_DESC

EndSql

While (cAliasSPJ)->(!Eof())

	aAdd(aSeq, {(cAliasSPJ)->PJ_TURNO,(cAliasSPJ)->PJ_SEMANA, (cAliasSPJ)->R6_DESC })

	(cAliasSPJ)->(dbSkip())

EndDo

(cAliasSPJ)->(dbCloseArea())

Return(aSeq)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580VisEsc
	 Visualização da escala para simulação


@sample	At580VisEsc()

@since		09/06/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function At580VisEsc()

Local aArea := GetArea()
Local aButtons := {	{.F.,Nil},;			// 1 - Copiar
					  	{.F.,Nil},;			// 2 - Recortar
					  	{.F.,Nil},;			// 3 - Colar
					  	{.F.,Nil},;			// 4 - Calculadora
					  	{.F.,Nil},;			// 5 - Spool
					  	{.F.,Nil},;			// 6 - Imprimir
					  	{.F.,STR0034},;		// 7 - Confirmar # Salvar
					  	{.T.,STR0035},;		// 8 - Cancelar	# Fechar
					  	{.F.,Nil},;			// 9 - WalkTrhough
					  	{.F.,Nil},;			// 10 - Ambiente
					  	{.F.,Nil},;			// 11 - Mashup
					  	{.F.,Nil},;			// 12 - Help
					  	{.F.,Nil},;			// 13 - Formulário HTML
					  	{.F.,Nil} }			// 14 - ECM

Local lConfirm

If Pergunte("TECA580", .T.)

	oMdlEsc := FwModelActive()

	dbSelectArea("TDW")
	TDW->(dbSetOrder(1)) //TDW_FILIAL+TDW_COD

	If TDW->(dbSeek(xFilial("TDW")+FwFldGet("TDW_COD")))
		lConfirm := ( FWExecView( STR0036,"VIEWDEF.TECA580A", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  //  "Visualização da Escala"
									{||.T.}/*bOk*/,/*nReducao*/, aButtons, {||.T.}/*bCancel*/ ) == 0 )
	Else
		Help( " ", 1, STR0019, Nil, STR0037, 1 )	// "Atenção" | "Escala não cadastrada, salve a escala para simular a visualização!"
	EndIf

EndIf

RestArea(aArea)

Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580GetMdl
	 Retorna o objeto com o model da escala


@sample	At580GetMdl()

@since		10/06/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function At580GetMdl()
Return(oMdlEsc)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580CfgEfe()
	 Carrega as configurações do Efetivo para a lista de cobertura

@sample	At580CfgEfe()

@since		20/06/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function At580CfgEfe(lAutomato)

Local oModel	  := FwModelActive()
Local oMdlTDX   := oModel:GetModel("TDXDETAIL")
Local oMdlTGW   := oModel:GetModel("TGWDETAIL")
Local nOper     := oModel:GetOperation()
Local lGeraTudo	:= .F.
Local nX


DEFAULT lAutomato := .F.

If !lAutomato
	lGeraTudo	:= MSgYesNo(STR0066, STR0067) // "Deseja gerar a confirguração para todos ?" | "Gerar Configuração"
EndIf

If lGeraTudo

	For nX := 1 To oMdlTDX:Length()
		oMdlTDX:GoLine(nX)
		GerarConfig(  oModel, oMdlTDX, oMdlTGW, nOper, @lAutomato )
	Next nX

Else
	GerarConfig( oModel, oMdlTDX, oMdlTGW, nOper, @lAutomato )
EndIf

Return lAutomato


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580HorTur()
	 Retorna todos os periodos e intervalos da tabela de horario padrao


@sample	At580HorTur( cTurno, cSequencia )

@param  	cTurno, String, turno qual devera ser localizado a tabela
@param  	cSequencia, String, sequencia do turno que devera ser localizado a tabela

@since		16/06/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function At580HorTur( cTurno, cSequencia )

Local aRet      := {}
Local aDomingo  := {}
Local aArea  	  := GetArea()

Local nI

dbSelectArea("SPJ")
SPJ->(dbSetOrder(1)) // PJ_FILIAL+PJ_TURNO+PJ_SEMANA

If SPJ->(dbSeek(xFilial("SPJ")+cTurno+cSequencia))

	While SPJ->(!Eof()) .And. SPJ->PJ_TURNO == cTurno .And. ;
			SPJ->PJ_SEMANA == cSequencia

		If (SPJ->PJ_ENTRA1+SPJ->PJ_SAIDA1+;
			SPJ->PJ_ENTRA2+SPJ->PJ_SAIDA2+;
			SPJ->PJ_ENTRA3+SPJ->PJ_SAIDA3+;
			SPJ->PJ_ENTRA4+SPJ->PJ_SAIDA4) > 0

			If SPJ->PJ_DIA == "1" // Domingo
				aAdd( aDomingo, SPJ->(Recno()) )
				SPJ->(dbSkip())
				Loop
			EndIf

			At580IntHor( @aRet )

		EndIf

		SPJ->(dbSkip())

	EndDo

EndIf

// Adiciona o domingo na ultima posição
If Len(aDomingo) > 0
	For nI:=1 To Len(aDomingo)
		SPJ->(dbGoTo(aDomingo[nI]))
		At580IntHor( @aRet )
	Next nI
EndIf

RestArea( aArea )

Return(aRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580IntHor()
	 Adiciona os intervalos da tabela de horario padrao do registro posicionado
	 da tabela SPJ.


@sample	At580IntHor( @aHorario )

@param  	aHorario, Array, Array qual deseja alimentar com os periodos da tabela
								de horario padrao

@since		18/06/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function At580IntHor( aHorario )

Local nHorInt := 0

// Primeiro periodo
If	(SPJ->PJ_ENTRA1 + SPJ->PJ_SAIDA1) > 0

	aAdd( aHorario, { SPJ->PJ_DIA, SPJ->PJ_ENTRA1, SPJ->PJ_SAIDA1,;
				  	If( SPJ->PJ_TPDIA == "S", "1", "2" ) } )

	// Segundo periodo
	If	(SPJ->PJ_ENTRA2 + SPJ->PJ_SAIDA2) > 0

		nHorInt := At580Intervalo( SPJ->PJ_ENTRA1, SPJ->PJ_SAIDA1,;
										 SPJ->PJ_ENTRA2, SPJ->PJ_SAIDA2 )

		// Intervalo
		If nHorInt > 0
			//nHorIni := If( SPJ->PJ_SAIDA1 == 0, SPJ->PJ_ENTRA1, SPJ->PJ_SAIDA1 )
			//nHorFim := If( SPJ->PJ_ENTRA2 == 0, SPJ->PJ_SAIDA2, SPJ->PJ_ENTRA2 )
			aAdd( aHorario, { SPJ->PJ_DIA, SPJ->PJ_SAIDA1, SPJ->PJ_ENTRA2, "3" } )
		EndIf

		aAdd( aHorario, { SPJ->PJ_DIA, SPJ->PJ_ENTRA2, SPJ->PJ_SAIDA2,;
				  		If( SPJ->PJ_TPDIA == "S", "1", "2" ) } )

		// Terceiro periodo
		If	(SPJ->PJ_ENTRA3 + SPJ->PJ_SAIDA3) > 0

			nHorInt := At580Intervalo( SPJ->PJ_ENTRA2, SPJ->PJ_SAIDA2,;
											 SPJ->PJ_ENTRA3, SPJ->PJ_SAIDA3 )

			// Intervalo
			If nHorInt > 0
				aAdd( aHorario, { SPJ->PJ_DIA, SPJ->PJ_SAIDA2, SPJ->PJ_ENTRA3, "3" } )
			EndIf

			aAdd( aHorario, { SPJ->PJ_DIA, SPJ->PJ_ENTRA3, SPJ->PJ_SAIDA3,;
				  			If( SPJ->PJ_TPDIA == "S", "1", "2" ) } )

			// Quarto periodo
			If	(SPJ->PJ_ENTRA4 + SPJ->PJ_SAIDA4) > 0

				nHorInt := At580Intervalo( SPJ->PJ_ENTRA3, SPJ->PJ_SAIDA3,;
												 SPJ->PJ_ENTRA4, SPJ->PJ_SAIDA4 )

				// Intervalo
				If nHorInt > 0
					aAdd( aHorario, { SPJ->PJ_DIA, SPJ->PJ_SAIDA3, SPJ->PJ_ENTRA4, "3" } )
				EndIf

				aAdd( aHorario, { SPJ->PJ_DIA, SPJ->PJ_ENTRA4, SPJ->PJ_SAIDA4,;
				  				If( SPJ->PJ_TPDIA == "S", "1", "2" ) } )

			EndIf

		EndIf

	EndIf

Else

	// Adiciona itens não configurados
	aAdd( aHorario, { SPJ->PJ_DIA, SPJ->PJ_ENTRA1, SPJ->PJ_SAIDA1,;
				  	If( SPJ->PJ_TPDIA == "S", "1", "2" ) } )

EndIf

Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580Intervalo()
	 Retorna o intervalo entre periodos da tabela de horario padrao


@sample	At580Intervalo( nEnt1, nSaida1, nEnt2, nSaida2 )

@param  	nEnt1, Double, Horario da primeira entrada
@param  	nSaida1, Double, Horario da primeira saida
@param  	nEnt2, Double, Horario da segunda entrada
@param  	nSaida2, Double, Horario da segunda saida
@param  	aHorario, Array, Array qual deseja alimentar com os periodos da tabela
								de horario padrao

@since		18/06/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function At580Intervalo( nEnt1, nSaida1, nEnt2, nSaida2, aHorario )

Local nHoras 	  := 0
Local nHorasNot := 0
Local nHorIni   := 0
Local nHorFim   := 0
Local nRet      := 0
Local dDataHI   := Date()

Local dDataHF

//nHorIni := If( nSaida1 == 0, nEnt1  , nSaida1 )
//nHorFim := If( nEnt2 == 0  , nSaida2, nEnt2   )

nHorIni := nSaida1
nHorFim := nEnt2

dDataHF := If( nHorFim < nHorIni, Date()+1, Date() )

nRet := fCalHoras(dDataHI	,;	//01 -> Data 1
					nHorIni	,;	//02 -> Hora 1
					dDataHF	,;	//03 -> Data 2
					nHorFim	,;	//04 -> Hora 2
					@nHoras	,;	//05 -> <@>Horas Normais Apontadas
					@nHorasNot	,;	//06 -> <@>Horas Noturnas Apontadas
					.F. )			//07 -> Apontar Horas Noturnas

Return(nRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580LCfg()
	 Legenda da Configuração da Escala (Interface).

@sample	At580LCfg()

@since		20/06/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function At580LCfg()

Local oLegenda := FWLegend():New()

oLegenda:Add( "", "BR_VERDE"   , STR0040 ) 		// Escala configurada
oLegenda:Add( "", "BR_VERMELHO", STR0041 ) 		// Escala inconsistente

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return(Nil)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580LCFBr()
	 Legenda da Configuração da Escala no Browse.

@sample	At580LCFBr()

@return	ExpC - Legenda da Configuração da Escala

@since		20/06/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function At580LCFBr()

Local cLegenda := "BR_VERDE"			// Cor da legenda

If TDW->TDW_STACFG == "2"
	cLegenda := "BR_VERMELHO"
EndIf

Return(cLegenda)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At580GetLE
Cria as informações referentes a legenda do grid de efetivos.

@author  	Serviços
@since 	  	20/06/2014
@version 	P12

@return 	lRet: Retorna .T. quando a criação foi bem sucedida.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580GetLE()

Local	oLegenda := FwLegend():New()

If	lLegend .and. !IsBlind()
	oLegenda:Add( "", "BR_VERDE"   , STR0042 )		//"Configurado"
	oLegenda:Add( "", "BR_AMARELO" , STR0043 )		//"Não Configurado"
	oLegenda:Add( "", "BR_VERMELHO", STR0044	)		//"Configuração Inconsistente"
	oLegenda:View()
	DelClassIntf()
EndIf

Return(.T.)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At580LgEfe
Atribui a cor na legenda dos efetivos, conforme a necessidade.

@author  	Serviços
@since 	  	20/06/2014
@version	P12

@return 	cRet: Cor da legenda conforme a configuração do efetivo
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580LgEfe()

Local oModel	:= FWModelActive()
Local cStatus := ""

Local cRet
Local oMdlEFE

If oModel:GetId()== "TECA580"

	oMdlEFE := oModel:GetModel("TDXDETAIL")

	If oMdlEFE:GetLine() == 0
		cStatus := TDX->TDX_STATUS
	Else
		cStatus := oMdlEFE:GetValue("TDX_STATUS")
	EndIf
	If cStatus == "1" // Configurado
		cRet := "BR_VERDE"
	ElseIf cStatus == "3" // Configuração Inconsistente
		cRet := "BR_VERMELHO"
	Else 	// Nao Configurado
		cRet := "BR_AMARELO"
	EndIf

EndIf

Return(cRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580BtnCfg

Criação do botão para a configuração do efetivo referente ao turno

@sample 	At580BtnCfg(oPanel)

@param		oPanel - Painel onde deverá ser criado e exibido o botão

@return	Nil
@author	Serviços
@since		20/06/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function At580BtnCfg( oPanel )

Local oButton

// Ancoramos os objetos no oPanel passado
@ 000, 000 Button oButton Prompt STR0045 Of oPanel Size 065, 012 Pixel //Gerar Configuração
oButton:Align := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel
oButton:bAction := { || At580CfgEfe() }

Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At580CobEfe

Consulta padrão para selecionar a cobertura disponivel para o efetivo

@sample 	At580CobEfe()

@return	Nil
@author	Serviços
@since		23/06/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function At580CobEfe()

Local lRet := .F.

oMdlEsc := FwModelActive()

lRet := ( FWExecView( STR0046,"VIEWDEF.TECA580F", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  //  "Cobertura do efetivo"
						{||.T.}/*bOk*/,60,/*aButtons*/, {||.T.}/*bCancel*/ ) == 0 )

Return(lRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580CobEfe

Consulta padrão para selecionar a cobertura disponivel para o efetivo

@sample 	At580CobEfe()

@return	Nil
@author	Serviços
@since		23/06/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function At580RetCob()
Local cRet := At580FGetCob()
Return(cRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580CobTip
	Retorna o tipo da cobertura selecionada

@sample 	At580CobTip(cCobertura)

@param		cCobertura, String, Item da cobertura
@return	cRet, String, Tipo da cobrança

@author	Serviços
@since		23/06/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function At580CobTip(cCobertura, lValid)

Local xRet

Local aArea   := GetArea()
Local oModel  := FwModelActive()
Local oMdlTGX := oModel:GetModel("TGXDETAIL")
Local oMdlTGW := oModel:GetModel("TGWDETAIL")

If lValid

	If !Empty(cCobertura)

		xRet := oMdlTGX:SeekLine({{"TGX_ITEM", cCobertura}})

		If xRet
			If oMdlTGW:GetValue("TGW_STATUS") == "2" // Folga
				xRet := (oMdlTGX:GetValue("TGX_TIPO") == "1" .Or. oMdlTGX:GetValue("TGX_TIPO") == "4")
			ElseIf oMdlTGW:GetValue("TGW_STATUS") == "3" // Intervalo
				xRet := (oMdlTGX:GetValue("TGX_TIPO") == "2" .Or. oMdlTGX:GetValue("TGX_TIPO") == "3")
			EndIf
		EndIf

		If !xRet
			Help( " ", 1, STR0019, Nil, STR0047, 1 )  //"Atenção"#"Tipo de cobertura invalida para a configuração do efetivo!"
		EndIf

	Else
		xRet := .T.
	EndIf

Else
	If	oMdlTGX:SeekLine({{"TGX_ITEM", cCobertura}})
		xRet := oMdlTGX:GetValue("TGX_TIPO")
	EndIf
EndIf

RestArea(aArea)

Return(xRet)


//------------------------------------------------------------------------------
/*/{Protheus.doc} PoslinTDY
	Valida a troca de linha no grid da TDY (exceções)

@sample 	PoslinTDY()
@return	lRet, Lógico
@author	Diego Bezerra
@since		29/03/2019
@version	P12
/*/
//------------------------------------------------------------------------------
Function PoslinTDY(oMdlG, nLine, cAcao, cCampo)

Local lRet 	 := .T.
Local lOrdem := .T. 		// Utilizada para verificar se as Entradas/Saídas estão cadastradas na ordem correta
Local cSoluc := ""

If lRet
	If oMdlG:GetValue("TDY_ENTRA3") == 0 .AND. oMdlG:GetValue("TDY_SAIDA3") == 0
		If oMdlG:GetValue("TDY_ENTRA4") <> 0 .OR. oMdlG:GetValue("TDY_SAIDA4") <> 0
			lOrdem  := .F.
			lRet 	:= .F.
			cSoluc  := STR0053 //"Favor preencher a 3a Entrada e 3a Saída."
		EndIf
	EndIf
EndIf

If lRet
	If oMdlG:GetValue("TDY_ENTRA2") == 0 .AND. oMdlG:GetValue("TDY_SAIDA2") == 0
		If oMdlG:GetValue("TDY_ENTRA3") <> 0 .OR. oMdlG:GetValue("TDY_SAIDA3") <> 0
			lRet	:= .F.
			lOrdem  := .F.
			cSoluc  := STR0058// "Favor preencher a 2a Entrada e 2a Saída."
		EndIf
	EndIf
EndIf

If lRet
	If oMdlG:GetValue("TDY_ENTRA1") == 0 .AND. oMdlG:GetValue("TDY_SAIDA1") == 0
		If oMdlG:GetValue("TDY_ENTRA2") <> 0 .OR. oMdlG:GetValue("TDY_SAIDA2") <> 0
			lRet 	:= .F.
			lOrdem  := .F.
			cSoluc  := STR0059 //"Favor preencher a 1a Entrada e 1a Saída."
		EndIf
	EndIf
EndIf

If !lRet
	Help(NIL, NIL, "POSLINTDY", NIL, STR0064, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSoluc}) //"Inconsistência nos cadastros de exceções."
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GerarConfig
	Função para gerar configuração, para todos ou individualmente

@sample GerarConfig( oModel, oMdlTDX, oMdlTGW, nOper, lAutomato )
@author	Augusto.Albuquerque
@since		09/04/2019
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function GerarConfig( oModel, oMdlTDX, oMdlTGW, nOper, lAutomato )

Local aArea 	  := GetArea()
Local aHorario  := {}
Local oView := NIL
Local nI
Local nX
Local lSubstituir	:= .T.


Default lAutomato	:= .F.

If ((nOper <> MODEL_OPERATION_VIEW .AND. lAutomato) .OR. nOper <> MODEL_OPERATION_VIEW) .AND. !oMdlTDX:IsDeleted()

	aHorario := At580HorTur( oMdlTDX:GetValue("TDX_TURNO"), oMdlTDX:GetValue("TDX_SEQTUR") )

	If Len(aHorario) > 0

		If !oMdlTGW:Length() == 1 .OR. !oMdlTGW:GetValue("TGW_HORINI") == 0 .OR.;
		 !oMdlTGW:GetValue("TGW_HORFIM") == 0
			lSubstituir	:= MsgYesNo(STR0038 + CRLF; // "Deseja realmente gerar/substituir as configurações do efetivo ?"
			 + STR0068 + oMdlTDX:GetValue("TDX_TURNO") + CRLF;// "Turno: "
			 + STR0069 + oMdlTDX:GetValue("TDX_DESTUR") + CRLF;// "Descrição: "
			 + STR0070 + oMdlTDX:GetValue("TDX_SEQTUR")) // "Sequência Turno: "
		EndIf

		If lAutomato .OR. lSubstituir

			If oMdlTGW:Length() > 1 .Or. ;
			   ( oMdlTGW:GetValue("TGW_HORINI") + oMdlTGW:GetValue("TGW_HORFIM") ) > 0

				For nI:=1 To oMdlTGW:Length()
					oMdlTGW:GoLine(nI)
					oMdlTGW:DeleteLine()
				Next nI

			EndIf

			For nI:=1 To Len(aHorario)

				If oMdlTGW:Length() > 1 .Or. ;
			   	   ( oMdlTGW:GetValue("TGW_HORINI") + oMdlTGW:GetValue("TGW_HORFIM") ) > 0
					oMdlTGW:AddLine()
				EndIf

				oMdlTGW:SetValue("TGW_DIASEM", aHorario[nI,1] )
				oMdlTGW:SetValue("TGW_HORINI", aHorario[nI,2] )
				oMdlTGW:SetValue("TGW_HORFIM", aHorario[nI,3] )
				oMdlTGW:SetValue("TGW_STATUS", aHorario[nI,4] )

			Next nI

			lLegend := .F.

			oMdlTDX:SetValue("TDX_STATUS", "1")
			oMdlTDX:SetValue("TDX_SIT", At580LgEfe())

			// Atualiza o grid com as informações adicionadas
			oMdlTGW:GoLine(1)
			If !IsBlind()
				oView := FwViewActive()
			EndIf
			
			If oView <> Nil .And. oView:GetModel():GetId()=="TECA580" .AND. !IsInCallStack("AT580ImpE")
				oView:Refresh("VIEW_TGW")
				oView:Refresh("VIEW_TDX")
	       EndIf

	       lLegend := .T.
      EndIf

	Else
		lAutomato := .F.
		Help( " ", 1, STR0019, Nil, STR0039, 1 )	// "Atenção" | "Não existem horarios cadastrados para esse turno e sequência, na tabela de horarios padrão!"
	EndIf
Else
	lAutomato := .F.
	Help( " ", 1, STR0019, Nil, STR0048, 1 )	// "Atenção" | "Processo invalido para essa operação!"
EndIf	
RestArea( aArea )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} GerarConfig
	Função para gerar configuração, para todos ou individualmente

@sample GerarConfig( oModel, oMdlTDX, oMdlTGW, nOper, lAutomato )
@author	Augusto.Albuquerque
@since		09/04/2019
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT580ImpEs()

Local aStruct		:= {}
Local aSeek			:= {}
Local aIdx			:= {}
Local aTabelaHP		:= {}
Local aHoraP		:= {}
Local aColumns		:= {}
Local nStepCmmIns	:= 900
Local nX	
Local nY
Local oMrkBrowse	:= FWMarkBrowse():New()
Local oGSTmpTb		:= Nil

aTabelaHP := AT580ImTab()
If Len(aTabelaHP) > 0
	Aadd(aStruct, {"OK"        	, "C", 1 						, 0						})
	Aadd(aStruct, {"R6_FILIAL"	, "C", TamSX3("R6_FILIAL")[1]	, TamSX3("R6_FILIAL")[2]	})
	Aadd(aStruct, {"R6_TURNO"	, "C", TamSX3("R6_TURNO")[1]	, TamSX3("R6_TURNO")[2]	})
	Aadd(aStruct, {"R6_DESC"	, "C", TamSX3("R6_DESC")[1]		, TamSX3("R6_DESC")[2]	})

	//Cria indices para a tabela temporária 
	Aadd(aIdx, {"I1",{ 'R6_TURNO'	}})
	Aadd(aIdx, {"I2",{ 'R6_DESC'	}})

	//Cria array da busca de acordo com os indices da tabela temporária
	aAdd(aSeek, {TxDadosCpo('R6_TURNO')[1]	,{{'','C',TamSX3('R6_TURNO')[1],TamSX3('R6_TURNO')[2],TxDadosCpo('R6_TURNO')[1],PesqPict('SR6','R6_TURNO'),NIL}},1})
	aAdd(aSeek, {TxDadosCpo('R6_DESC')[1]	,{{'','C',TamSX3('R6_DESC')[1],TamSX3('R6_DESC')[2],TxDadosCpo('R6_DESC')[1],PesqPict('SR6','R6_DESC'),NIL}},2})

	//Instancia o método NEW para criação da tabela temporária
	oGSTmpTb := GSTmpTable():New('RESSR6',aStruct, aIdx, {}, nStepCmmIns )
	cRetTab  := 'RESSR6'

	//Validação para a criação da tabela temporária
	If oGSTmpTb:CreateTMPTable()
		//Preenche Tabela temporária com as informações filtradas
		For nX := 1 To Len(aTabelaHP)
			aInsertTmp :={}
			Aadd(aInsertTmp, {'R6_FILIAL'		,aTabelaHP[nX][1]})
			Aadd(aInsertTmp, {'R6_TURNO'		,aTabelaHP[nX][2]})
			Aadd(aInsertTmp, {'R6_DESC'			,aTabelaHP[nX][3]})
				
			If oGSTmpTb:Insert(aInsertTmp)
				lOk := oGSTmpTb:Commit()
			Else
				lOk := .F.
				Exit
			EndIf
		Next nX
	Else
		oGSTmpTb:ShowErro()
	EndIf

	//MarkBrowse
	For nY := 1 To Len(aStruct)
		If aStruct[nY][1] <> "OK"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nY][1]+"}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nY][1]))
			aColumns[Len(aColumns)]:SetSize(aStruct[nY][3])
			aColumns[Len(aColumns)]:SetDecimal(aStruct[nY][4])
			aColumns[Len(aColumns)]:SetPicture(PesqPict(cRetTab,aStruct[nY][1]))
		EndIf
	Next nY

	DEFINE MSDIALOG oDlg TITLE STR0071 From 300,0 To 700,1000 PIXEL // "Escalas disponeiveis para geração automatica"
	oMrkBrowse:SetOwner(oDlg)
	oMrkBrowse:DisableFilter()

	oMrkBrowse:SetDescription(STR0078) // "Geração de Escala"
	oMrkBrowse:SetTemporary(.T.)     	
	oMrkBrowse:AddButton(STR0072,{|| AT580ImpE(aHoraP),oDlg:End(), oMrkBrowse:Refresh(.T.) },,3,)		// "Importa"
	oMrkBrowse:AddButton(STR0073, {|| AT580ImpE(aTabelaHP ),oDlg:End(), oMrkBrowse:Refresh(.T.)},,3,) 	// "Importa Todos"
	oMrkBrowse:SetFieldMark("OK")
	oMrkBrowse:SetAlias(cRetTab) // Seta o arquivo temporario para exibir a seleção dos dados
	oMrkBrowse:SetSeek(.T., aSeek) 
	oMrkBrowse:SetAllMark( { || oMrkBrowse:AllMark() } )
	oMrkBrowse:bMark := {||At580Mark(oMrkBrowse,cRetTab, @aHoraP)}	        
	oMrkBrowse:SetColumns(aColumns)
	oMrkBrowse:DisableReport()
	oMrkBrowse:SetMenuDef("")
	oMrkBrowse:DisableDetails()
	oMrkBrowse:Activate(oDlg)
	ACTIVATE MSDIALOG oDlg CENTERED	

	oGSTmpTb:Close()
	TecDestroy(oGSTmpTb)	
Else
	Help( ' ' , 1 , STR0074, , STR0075, 1 , 0 )	// "AT580ImpEs" ## "Não foi possivel localizar nenhuma escala para importação. Verifique se elas já foram geradas."
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT580ImTab()
Função para retorno dos os turnos disponiveis na base que não foram cadastrados em nenhuma

@sample AT580ImTab()
@author	Augusto.Albuquerque
@since		09/04/2019
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT580ImTab()
Local aArea		:= GetArea()
Local aFunc		:= {}
Local cQuery	:= ""
Local cAliasSR6	:= GetNextAlias()

cQuery	:= 	" SELECT SR6.R6_FILIAL, SR6.R6_TURNO, SR6.R6_DESC "
cQuery	+= 	" FROM " + RetSqlName("SR6") + " SR6 "
cQuery	+=  " INNER JOIN " + RetSqlName("SPJ") + " SPJ ON "
cQuery 	+= 	" SPJ.D_E_L_E_T_ = ' ' AND SPJ.PJ_FILIAL = '" + xFilial("SPJ") + "' "
cQuery	+=	" WHERE SR6.R6_FILIAL = '" + xFilial("SR6") + "' AND "
cQuery	+=	" SR6.D_E_L_E_T_  = ' ' AND "
cQuery	+=	" SPJ.PJ_TURNO = SR6.R6_TURNO AND" 
cQuery	+=	" NOT EXISTS ( SELECT TDX.TDX_TURNO FROM " + RetSqlName("TDX") 
cQuery	+=	" TDX WHERE TDX.TDX_TURNO = SR6.R6_TURNO AND TDX.D_E_L_E_T_ = ' ' AND TDX.TDX_FILIAL = '" + xFilial("TDX") + "' )"
cQuery	+=  " GROUP BY SR6.R6_FILIAL, SR6.R6_TURNO, SR6.R6_DESC"
 
cQuery := ChangeQuery(cQuery)	
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasSR6, .T., .T. )
//	Preenche o array com as informações de funcionários que não são atendentes.

While (cAliasSR6)->(! Eof())
	aAdd(aFunc,{ (cAliasSR6)->R6_FILIAL,; 
				 (cAliasSR6)->R6_TURNO,;
	             (cAliasSR6)->R6_DESC})
	(cAliasSR6)->(DbSkip())
EndDo
(cAliasSR6)->(DbCloseArea())

RestArea(aArea)
Return (aFunc)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At580Mark
Função para retornar os turnos selecionados.

@sample At580Mark( oMrkBrowse,cRetTab,aHoraP )
@author	Augusto.Albuquerque
@since		09/04/2019
@version	P12
/*/
//------------------------------------------------------------------------------
Function At580Mark(oMrkBrowse,cRetTab,aHoraP)
Local aArea		:= GetArea()
Local aAux		:= {}
Local cMarca	:= ""
Local cCodigo	:= (cRetTab)->R6_TURNO
Local nX

DbSelectArea(cRetTab)
  
cMarca := oMrkBrowse:Mark() 
	RecLock(cRetTab, .F.)
		
If (cRetTab)->OK <> cMarca
	(cRetTab)->OK := ' '
	For nX := 1 To Len(aHoraP)
		If aHoraP[nX][2] <> cCodigo
			AADD(aAux, aHoraP[nX])
		EndIF
	Next nX
	aHoraP	:= ACLONE(aAux)
Else
	(cRetTab)->OK := cMarca
	AADD(aHoraP, {(cRetTab)->R6_FILIAL, (cRetTab)->R6_TURNO, (cRetTab)->R6_DESC}  )
EndIf
MsUnlock()
(cRetTab)->(DbSkip())

RestArea(aArea)

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT580ImpE
	Função para gerar configuração a escala

@sample AT580ImpE( aHoraP )
@author	Augusto.Albuquerque
@since		09/04/2019
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT580ImpE(aHoraP)

Local cMsg		:= ""
Local lRet		:= .T.
Local nX
Local nY
Local nSeq 		:= 0	
Local oModel	:= FwLoadModel("TECA580")
Local oMdlTDX	:= Nil
Local oMdlTDW	:= Nil
Local oMdlTGW	:= Nil

Begin Transaction
	For nX := 1 To Len(aHoraP)

		lRet := .T.
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		oMdlTGW	:= oModel:GetModel("TGWDETAIL")
		oMdlTDW := oModel:GetModel("TDWMASTER")
		oMdlTDX := oModel:GetModel("TDXDETAIL")

		lRet := lRet .AND. oMdlTDW:SetValue("TDW_DESC", aHoraP[nX][3] )
		lRet := lRet .AND. oMdlTDW:SetValue("TDW_STATUS", "1")
		nSeq := Val(QryMax(aHoraP[nX][2]))
		If nSeq <> 0
			For nY := 1 To nSeq
				lRet := lRet .AND. oMdlTDX:SetValue("TDX_TURNO", aHoraP[nX][2])
				lRet := lRet .AND. oMdlTDX:SetValue("TDX_SEQTUR",  "0"+ cValToChar(nY))
				If lRet .AND. (nY + 1) <= nSeq
					oMdlTDX:AddLine()
				EndIf
			Next nY		
		Else
			lRet := .F.
		EndIf
		If lRet .AND. nSeq <> 0
			For nY := 1 To oMdlTDX:Length()
				oMdlTDX:GoLine(nY)
				GerarConfig(  oModel, oMdlTDX, oMdlTGW, oModel:GetOperation(), .T. )
			Next nY
		Else
			cMsg += STR0076 + aHoraP[nX][3] + CRLF // "Erro ao cadastrar a escala: "
		EndIf
			
		lRet := lRet .AND. (oModel:VldData() .AND. oModel:CommitData())

		oModel:deActivate()
	Next nX
End Transaction
If !Empty(cMsg)
	If !IsBlind()	
		AtShowLog(cMsg,STR0077,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) // "Geração automatica da Escala"
	EndIF
EndIf
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} QryMax
	Função para gerar retornar o total da sequencia de turno

@sample QryMax( cTurno )
@author	Augusto.Albuquerque
@since		09/04/2019
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function QryMax(cTurno)
Local cQuery	:= ""
Local cAliasSPJ	:= GetNextAlias()
Local nRet		:= 01

cQuery	:= 	" SELECT MAX(SPJ.PJ_SEMANA) DTMAX"
cQuery	+= 	" FROM " + RetSqlName("SPJ") + " SPJ "
cQuery	+=	" WHERE SPJ.PJ_FILIAL = '" + xFilial("SPJ") + "' AND "
cQuery	+=	" SPJ.D_E_L_E_T_ = ' ' AND "
cQuery	+=	" SPJ.PJ_TURNO =  '" +  cTurno + "' "

cQuery := ChangeQuery(cQuery)	
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasSPJ, .T., .T. )

nRet := (cAliasSPJ)->(DTMAX)

(cAliasSPJ)->(DbCloseArea())

Return nRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} At580MnPl
	Executa a rotina de manutenções planejadas

@author		Mateus Boiani
@since		26/11/2019
@version	P12
/*/
//------------------------------------------------------------------------------
Function At580MnPl()
Local oModel := FwModelActive()
Local oMdlTDX := oModel:GetModel("TDXDETAIL")
Local aArea := GetArea()

DbSelectArea("TDX")
DbSetOrder(1)

If DbSeek(xFilial("TDX")+oMdlTDX:GetValue("TDX_COD"))
	FWExecView("","VIEWDEF.TECA580G", oModel:GetOperation(),,,,,)
EndIf

FwModelActive(oModel)
RestArea(aArea)
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} At580GatRp
	Gatilho de réplica de feriados

@author		Kaique Schiller
@since		05/08/2020
@version	P12
/*/
//------------------------------------------------------------------------------
Function At580GatRp()
Local oModel   := FwModelActive()
Local oMdlTDW  := oModel:GetModel("TDWMASTER")
Local oMdlTDX  := oModel:GetModel("TDXDETAIL")
Local oMdlFTDY := oModel:GetModel("FTDYDETAIL")
Local nX 	   := 0
Local nZ 	   := 0
Local nY	   := 0
Local nK	   := 0
Local oStrFeri := Nil
Local aCampos  := {}
Local nLineTDX := 0
Local oView	   := Nil
Local aReplic  := {}

If oMdlTDW:GetValue("TDW_RPLFER") == "1"
	If !isBlind()
		oView := FwViewActive()
	Endif
	oStrFeri := oMdlFTDY:GetStruct()
	aCampos  := oStrFeri:GetFields()
	If !oMdlTDX:IsDeleted() .And. !Empty(oMdlTDX:GetValue("TDX_TURNO"))
		nLineTDX := oMdlTDX:GetLine()
		For nZ := 1 To oMdlFTDY:Length()
			oMdlFTDY:GoLine(nZ)
			If !oMdlFTDY:IsDeleted() .And. !Empty(oMdlFTDY:GetValue("TDY_DIASEM"))
				nK++	
				aAdd(aReplic,{})
				For nX := 1 To Len(aCampos)
					If !(aCampos[nX][MODEL_FIELD_IDFIELD] $ "TDY_FILIAL|TDY_COD|TDY_CODTDX")
						aAdd(aReplic[nK],{aCampos[nX][MODEL_FIELD_IDFIELD],oMdlFTDY:GetValue(aCampos[nX][MODEL_FIELD_IDFIELD])})
					Endif
				Next nX
			Endif
		Next nZ
	Endif

	For nX := 1 To oMdlTDX:Length()
		oMdlTDX:GoLine(nX)
		If !oMdlTDX:IsDeleted() .And. !Empty(oMdlTDX:GetValue("TDX_TURNO"))
			For nZ := 1 To oMdlFTDY:Length()
				oMdlFTDY:GoLine(nZ)
				oMdlFTDY:DeleteLine()
			Next nZ
		Endif
	Next nX

	For nX := 1 To oMdlTDX:Length()
		oMdlTDX:GoLine(nX)
		If !oMdlTDX:IsDeleted() .And. !Empty(oMdlTDX:GetValue("TDX_TURNO"))
			For nZ := 1 To Len(aReplic)
				oMdlFTDY:AddLine()
				For nY := 1 To Len(aReplic[nZ])
 					oMdlFTDY:SetValue(aReplic[nZ,nY,1],aReplic[nZ,nY,2])
				Next nY
			Next nZ
		Endif
	Next nX

	If !isBlind()
		oView:Refresh("VIEW_FTDY")
	Endif
	oMdlTDX:GoLine(nLineTDX)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At580VldRp
	Validação de réplica de feriados

@author		Kaique Schiller
@since		05/08/2020
@version	P12
/*/
//------------------------------------------------------------------------------
Function At580VldRp()
Local lRet 		:= .T.
Local oModel    := FwModelActive()
Local oView     := Nil 
Local oMdlTDW   := oModel:GetModel("TDWMASTER")
Local oMdlTDX   := oModel:GetModel("TDXDETAIL")
Local oMdlFTDY  := oModel:GetModel("FTDYDETAIL")
Local nX 	    := 0

If oMdlTDW:GetValue("TDW_RPLFER") == "1"
	If !IsBlind()
		oView := FwViewActive()
	Endif
	If !oMdlTDX:IsDeleted() .And. !Empty(oMdlTDX:GetValue("TDX_TURNO"))
		If (lRet := MsgYesNo(STR0080+oMdlTDX:GetValue("TDX_TURNO")+STR0081+oMdlTDX:GetValue("TDX_SEQTUR")+STR0082,STR0088)) //"Os feriados serão replicados conforme o turno "#" e a sequência "#, gostaria de continuar?"#"Réplica de Feriados."
			For nX := 1 to oMdlFTDY:Length()
				oMdlFTDY:Goline(nX)
				lRet := .F.
				If !Empty(oMdlFTDY:GetValue("TDY_DIASEM")) .And. !oMdlFTDY:IsDeleted()
					lRet := .T.
					Exit
				Endif
			Next nX
			If !lRet
				Help(Nil, Nil, "At580VldRp", Nil, STR0083, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0084}) //"Não existe linhas para realizar a cópia dos feridos."#"Posicione em um turno que é válido."
			Endif
		Endif
	Else
		Help(Nil, Nil, "At580VldRp", Nil, STR0085, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0084}) //"Não existe turnos e sequências cadastradas ou o item foi deletado."#"Posicione em um turno que é válido."
		lRet := .F.
	Endif
	If !lRet
		oMdlTDW:LoadValue("TDW_RPLFER","2")
		If !IsBlind()
			oView:Refresh("VIEW_TDW")
		Endif
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At580PosVl
	Pós validação do modelo

@author		Kaique Schiller
@since		10/08/2020
@version	P12
/*/
//------------------------------------------------------------------------------
Function At580PosVl(oMdlG,nLine,cAcao,cCampo,lRplFer)
Local lRet 		:= .T.
Local oMdlTDW 	:= Nil
Local oMdlTDX 	:= Nil 
Local oMdlFTDY 	:= Nil 
Local nX	  	:= 0
Local nZ	  	:= 0
Local nY	  	:= 0
Local nK		:= 0
Local nLineTDX	:= 0
Local nLineFER	:= 0 
Local aVlRpl  	:= {}
Local oStrFeri 	:= Nil
Local aCampos  	:= {}
Local oView     := Nil 

If lRplFer
	oMdlTDW := oMdlG:GetModel("TDWMASTER")
	oMdlTDX := oMdlG:GetModel("TDXDETAIL")
	oMdlFTDY := oMdlG:GetModel("FTDYDETAIL")
	If oMdlTDW:GetValue("TDW_RPLFER") == "1"
		If !IsBlind()
			oView := FwViewActive()
		EndIf
		oStrFeri := oMdlFTDY:GetStruct()
		aCampos  := oStrFeri:GetFields()
		nLineTDX := oMdlTDX:GetLine()
		nLineFER := oMdlFTDY:GetLine()
		For nX := 1 To oMdlTDX:Length()
			oMdlTDX:GoLine(nX)
			If !oMdlTDX:IsDeleted() .And. !Empty(oMdlTDX:GetValue("TDX_TURNO"))
				If Empty(aVlRpl)
					For nZ := 1 To oMdlFTDY:Length()
						oMdlFTDY:GoLine(nZ)
						If !oMdlFTDY:IsDeleted() .And. !Empty(oMdlFTDY:GetValue("TDY_DIASEM"))
							nK++
							aAdd(aVlRpl,{})
							For nY := 1 To Len(aCampos)
								If !(aCampos[nY,MODEL_FIELD_IDFIELD] $ "TDY_FILIAL|TDY_COD|TDY_CODTDX")
									aAdd(aVlRpl[nK],{aCampos[nY,MODEL_FIELD_IDFIELD],oMdlFTDY:GetValue(aCampos[nY,MODEL_FIELD_IDFIELD])})
								Endif
							Next nY
						Endif
					Next nZ
					If lRet .And. Empty(aVlRpl)
						Help(Nil, Nil, "At580PosVl", Nil, STR0087, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0088}) //'Erro na gravação da escala, registros divergentes na réplica de feriados. O campo "Réplica Fer." será alterado para "Não"'.#"Realize a réplica novamente."
						lRet := .F.
						Exit
					Endif
				Else
					nK := 0
					For nZ := 1 To oMdlFTDY:Length()
						oMdlFTDY:GoLine(nZ)
						If !oMdlFTDY:IsDeleted() .And. !Empty(oMdlFTDY:GetValue("TDY_DIASEM"))
							If nK < Len(aVlRpl)
								nK++
							Endif
							For nY := 1 To Len(aVlRpl[nK])
								If lRet .And. oMdlFTDY:GetValue(aVlRpl[nK,nY,1]) <> aVlRpl[nK,nY,2]
									Help(Nil, Nil, "At580PosVl", Nil, STR0087, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0088}) //'Erro na gravação da escala, registros divergentes na réplica de feriados. O campo "Réplica Fer." será alterado para "Não"'.#"Realize a réplica novamente."
									lRet := .F.
									Exit
								Endif
							Next nY
						Endif
					Next nZ
					If lRet .And. nK < Len(aVlRpl)
						Help(Nil, Nil, "At580PosVl", Nil, STR0087, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0088}) //'Erro na gravação da escala, registros divergentes na réplica de feriados. O campo "Réplica Fer." será alterado para "Não"'.#"Realize a réplica novamente."
						lRet := .F.
						Exit
					Endif
				Endif
			Endif
		Next nX
		oMdlTDX:Goline(nLineTDX)
		oMdlFTDY:Goline(nLineFER)
		If !lRet
			oMdlTDW:LoadValue("TDW_RPLFER","2")
			If !IsBlind()
				oView:Refresh("VIEW_TDW")
			Endif
		Endif
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At580MPlRo
	Executa a rotina de manutenções planejadas para a rota

@author		Augusto Albuquerque
@since		27/01/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Function At580MPlRo()
Return At580MnPl()

//------------------------------------------------------------------------------
/*/{Protheus.doc} TEC580Ope
	Execução da ViewDef de acordo com a operação.

@author		Junior.Santos
@since		10/03/2021
@version	P12
/*/
//------------------------------------------------------------------------------

Function TEC580Ope(nOpc)

Local cTitulo := ""

If nOpc == 1 	
	cTitulo := STR0005 //Visualização
ElseIf nOpc == 3
	cTitulo := STR0006 //Inclusão
ElseIf nOpc == 4
	cTitulo := STR0007 //Alteração
EndIf		

Return FwExecView(cTitulo,"VIEWDEF.TECA580",nOpc)

