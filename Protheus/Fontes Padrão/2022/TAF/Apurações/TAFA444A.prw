#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA444DEF.CH"
#INCLUDE "TAFA444.CH"

/*/{Protheus.doc} TAF444Comp
Realiza as compensações automaticas da apuração
@author david.costa
@since 04/12/2017
@version 1.0
@return ${Nil}, ${Nulo}
/*/Function TAF444Comp( aParametro, oModelPeri, oModelEven, cLogAvisos, aGrupo, lRural, aParametr2, lSimula )

Local nLimiteGrp	as numeric
Local nVlrACompe	as numeric
Local cFormaTrib	as character
Local cIdEvento		as character
Local cCampoId		as character

nLimiteGrp	:= 0
nVlrACompe	:= 0
cCampoId	:= iif( lRural, 'T0N_IDEVEN', 'T0N_ID' )
cIdEvento	:= oModelEven:GetValue( "MODEL_T0N", cCampoId )
cFormaTrib 	:= XFUNID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K" , 1 )

If VlrLRAntes( aParametro ) > 0
	
	If VlrLRApoPj( aParametro, aParametr2 ) > 0
		nLimiteGrp := GetLimite( oModelEven:GetModel( "MODEL_T0O_" + aGrupo[ PARAM_GRUPO_NOME ] ), aParametro )
		nVlrACompe := Round( nLimiteGrp - aParametro[GRUPO_COMPENSACAO_PREJUIZO], 2 )
	Else
		nVlrACompe := VlrLRApoPj( aParametro, aParametr2 )
	EndIf
	
	If nVlrACompe > 0
		//Criar lançamentos de compensação
		Compensar( nVlrACompe, oModelPeri, @cLogAvisos, aGrupo, @aParametro, cIdEvento, lRural, lSimula )
	//Redução de Lucro
	ElseIf cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
		//Criar lançamentos de Débito
		RevertComp( nVlrACompe, oModelPeri, @cLogAvisos, aGrupo, @aParametro, cIdEvento, lRural, lSimula, .f. )
	EndIf

//Prejuízo	
ElseIf cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
	//Criar lançamentos de Débito
	RevertComp( 0, oModelPeri, @cLogAvisos, aGrupo, @aParametro, cIdEvento, lRural, lSimula, .t. )
EndIf

Return()

/*/{Protheus.doc} Compensar
Realiza uma compensação de credito
@author david.costa
@since 04/12/2017
@version 1.0
@return ${Nil}, ${Nulo}
/*/Static Function Compensar( nVlrACompe, oModelPeri, cLogAvisos, aGrupo, aParametro, cIdEvento, lRural, lSimula )

Local cAliasQry	as character
Local cTipoLan	as character

cAliasQry	:= ""
cTipoLan	:= ""
cTipoLan := TIPO_LANC_CREDITO
		
//Seleciona as contas para compensar
cAliasQry := SelectCont( oModelPeri, cIdEvento )

CriarLancB( cAliasQry, nVlrACompe, cTipoLan, @aParametro, @oModelPeri, aGrupo, lRural, @cLogAvisos, lSimula )

Return()

/*/{Protheus.doc} GetVlrComp
Define o valor do lançamento que será gerado
@author david.costa
@since 04/12/2017
@version 1.0
@return ${Nil}, ${Nulo}
/*/Static Function GetVlrComp( nVlrLanTot, oModelParB, cAliasQry, cTipoLan, aParametro, lPrejuizo, lRural)

Local nVlrParteB	as numeric
Local nVlrDebito	as numeric
Local nVlrCredit	as numeric
Local nSaldo		as numeric
Local oModelTrib	as object

nVlrParteB	:= 0
nVlrDebito	:= 0
nVlrCredit	:= 0
nSaldo		:= 0
oModelTrib	:= Nil
 
If cTipoLan == TIPO_LANC_CREDITO
	oModelTrib := oModelParB:GetModel( "MODEL_LE9" )
	oModelTrib:SeekLine( { { "LE9_IDCODT", ( cAliasQry )->CWV_IDTRIB } } )
	nSaldo := oModelTrib:GetValue( "LE9_VLSDAT" )
//So podem ser considerados o saldos de lançamentos automaticos criados no período
ElseIf cTipoLan == TIPO_LANC_DEBITO
	nVlrDebito := GetTotLanc( TIPO_LANC_DEBITO, aParametro[ INICIO_PERIODO ], ( cAliasQry )->C1E_FILTAF, ( cAliasQry )->T0O_IDPARB, lRural )
	nVlrCredit := GetTotLanc( TIPO_LANC_CREDITO, aParametro[ INICIO_PERIODO ], ( cAliasQry )->C1E_FILTAF, ( cAliasQry )->T0O_IDPARB, lRural )
	nSaldo := nVlrCredit - nVlrDebito
EndIf

If lPrejuizo 
	nVlrParteB := nSaldo
ElseIf nSaldo >= nVlrLanTot 
	nVlrParteB := nVlrLanTot
ElseIf nSaldo > 0
	nVlrParteB := nSaldo
Else 
	nVlrParteB := 0
EndIf

Return( nVlrParteB )

/*/{Protheus.doc} RevertComp
Realiza uma compensação de débito
@author david.costa
@since 04/12/2017
@version 1.0
@return ${Nil}, ${Nulo}
/*/Static Function RevertComp( nVlrACompe, oModelPeri, cLogAvisos, aGrupo, aParametro, cIdEvento, lRural, lSimula, lPrezuijo )

Local cAliasQry	as character
Local cTipoLan	as character
Local cOrderBy	as character

cAliasQry	:= ""
cOrderBy	:= "T0S.T0S_DTFINA  DESC"
cTipoLan	:= TIPO_LANC_DEBITO
nVlrACompe	:= abs( nVlrACompe )

//Seleciona as contas para compensar
cAliasQry := SelectCont( oModelPeri, cIdEvento, cOrderBy )

CriarLancB( cAliasQry, nVlrACompe, cTipoLan, @aParametro, @oModelPeri, aGrupo, lRural, @cLogAvisos, lSimula, lPrezuijo )

Return()

/*/{Protheus.doc} SelectCont
Seleciona as contas para criação dos lançamentos
@author david.costa
@since 04/12/2017
@version 1.0
@return ${cAliasQry}, ${Contas selecionadas}
/*/Static Function SelectCont( oModelPeri, cIdEvento, cOrderBy )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character

Default cOrderBy	:= "T0S.T0S_DTFINA"

cAliasQry	:= GetNextAlias()
cSelect	:= ""
cFrom		:= ""
cWhere		:= ""

cSelect	:= " T0O.T0O_IDPARB, CWV.CWV_IDTRIB, C1E.C1E_FILTAF, CWV.CWV_ID, T0O.T0O_IDLAL, T0O.T0O_IDECF, T0O.T0O_SEQITE "
cFrom		:= RetSqlName( "CWV" ) + " CWV "
cFrom		+= " JOIN " + RetSqlName( "T0O" ) + " T0O "
cFrom		+= " 	ON T0O.D_E_L_E_T_ = '' AND T0O.T0O_FILIAL = CWV.CWV_FILIAL AND T0O.T0O_ID = '" + cIdEvento + "' "
cFrom		+= " JOIN " + RetSqlName( "C1E" ) + " C1E "
cFrom		+= " 	ON C1E.D_E_L_E_T_ = '' AND C1E.C1E_CODFIL = T0O.T0O_FILITE "
cFrom		+= " JOIN " + RetSqlName( "T0S" ) + " T0S "
cFrom		+= "	ON T0S.D_E_L_E_T_ = '' AND T0S.T0S_FILIAL = C1E.C1E_FILTAF AND T0S.T0S_ID = T0O.T0O_IDPARB
cWhere		:= " CWV.D_E_L_E_T_ = '' "
cWhere		+= " AND CWV.CWV_FILIAL = '" + xFilial( "CWV" ) + "' "
cWhere		+= " AND CWV.CWV_ID = '" + oModelPeri:GetValue( "MODEL_CWV", "CWV_ID" ) + "' "
cWhere		+= " AND T0O.T0O_IDPARB <> '' "
cWhere		+= " AND T0O.T0O_IDGRUP = 13 "		//Somente Grupo de compensação do prejuízo
cWhere		+= " AND T0O.T0O_EFEITO = '4' "		//Geração de Lançamento Automático

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere 	:= "%" + cWhere  	+ "%"
cOrderBy 	:= "%" + cOrderBy	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%
EndSql

Return( cAliasQry )

/*/{Protheus.doc} GetTotLanc
Busca o total de lançamentos de creditos ou debitos para uma determinada atividade em uma determinada conta
@author david.costa
@since 04/12/2017
@version 1.0
@return ${nValorLan}, ${Valor para o lançamento}
/*/Static Function GetTotLanc( cTipoLan, dInicial, cCodFilial, cIdConta, lRural )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local nValorLan	as numeric

cAliasQry	:= GetNextAlias()
cSelect	:= ""
cFrom		:= ""
cWhere		:= ""
nValorLan	:= 0

cSelect	:= " SUM( T0T.T0T_VLLANC ) VALORLAN "
cFrom		:= RetSqlName( "T0T" ) + " T0T "
cWhere		:= " T0T.D_E_L_E_T_ = '' "
cWhere		+= " AND T0T.T0T_FILIAL = '" + cCodFilial + "' "
cWhere		+= " AND T0T.T0T_ID = '" + cIdConta + "' "
cWhere		+= " AND T0T.T0T_ORIGEM = '2' "
cWhere		+= " AND T0T.T0T_IDDETA <> '' "
cWhere		+= " AND T0T.T0T_DTLANC >= '" + dTos( dInicial ) + "' "
cWhere		+= " AND T0T.T0T_TPLANC = '" + cTipoLan + "'  "

If lRural
	cWhere		+= " AND T0T_RURAL = '1' "
Else
	cWhere		+= " AND ( T0T_RURAL = '0' OR T0T_RURAL = '' ) "
EndIf

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere 	:= "%" + cWhere  	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

nValorLan := ( cAliasQry )->( VALORLAN )

Return( nValorLan )

/*/{Protheus.doc} CriarLancB
Cria o lançamento na conta e atualiza os valores na apuração
@author david.costa
@since 04/12/2017
@version 1.0
@return ${Nil}, ${Nulo}
/*/Static Function CriarLancB( cAliasQry, nVlrACompe, cTipoLan, aParametro, oModelPeri, aGrupo, lRural, cLogAvisos, lSimula, lPrejuizo )

Local cOrigem		as character
Local oModelParB	as object
Local nVlrParteB	as numeric
Local nSeqDetalh	as numeric
Local cChave		as character
Local dDtLan 		as date
Local cIdTrib		as character
Local cPerApu		as character

Default lPrejuizo	:= .f.

cOrigem	:= ""
oModelParB	:= Nil
nVlrParteB	:= 0
nSeqDetalh	:= 0 
cChave		:= ""

cIdTrib := oModelPeri:GetValue( 'MODEL_CWV', 'CWV_IDTRIB' )
dDtLan	:= oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" )
cOrigem	:= ORIGEM_LALUR_PARTE_B
cPerApu := GetAdvFVal('T0J','T0J_PERAPU',xFilial('T0J')+cIdTrib,1)


While( cAliasQry )->( !Eof() ) .and. ( nVlrACompe > 0 .or. lPrejuizo )
	//Carregar conta
	If LoadContaB( ( cAliasQry )->T0O_IDPARB, @oModelParB, ( cAliasQry )->C1E_FILTAF )
		//Define o valor do lançaento que será criado
		nVlrParteB := GetVlrComp( nVlrACompe, oModelParB, cAliasQry, cTipoLan, aParametro, lPrejuizo, lRural)
		
		If cTipoLan == TIPO_LANC_DEBITO 
			//No caso do débito o valor deve ser negativo para desfazer as compensações anteriores
			nVlrParteB := (nVlrParteB * -1) 
		endif
				
		If !lPrejuizo 
			//Adiciona o valor na apuração			
			nSeqDetalh := AddDetalhe( @oModelPeri, cOrigem, aGrupo[ PARAM_GRUPO_ID ], nVlrParteB, ( cAliasQry )->T0O_IDLAL, ( cAliasQry )->T0O_IDECF, ( cAliasQry )->T0O_SEQITE,, lRural )
			
			//Atualiza o valor do Grupo
			aParametro[ GRUPO_COMPENSACAO_PREJUIZO ] += nVlrParteB
		EndIf
		
		//Chave do lançamento da parte B
		cChave := ( cAliasQry )->CWV_ID + StrZero( nSeqDetalh, 6 )
		
		nVlrParteB := Abs( nVlrParteB )
		
		//Gera o Lançamento de compensação
		AddLanParB( @oModelParB, nVlrParteB, aGrupo, @cLogAvisos, cChave, dDtLan, EFEITO_INCLUIR_LANC_AUTOMATICO,, ( cAliasQry )->CWV_IDTRIB, cTipoLan, lRural )
		
		//Atualiza o total a compensar
		nVlrACompe := nVlrACompe - Abs( nVlrParteB ) 
		
		//Não deverá salvar quando for simulação
		If !lSimula
			FWFormCommit( oModelParB )
		EndIf
		
	EndIf
	( cAliasQry )->( DbSkip() )
EndDo

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA444Add
Função para incluir Períodos de Apuração em lote

@Return Nil 

@Author David Costa
@Since 13/12/2017
@Version 1.0
/*/
//------------------------------------------------------------------------------------------------
Function TAFA444Add( )

Processa( { || IncluirLte() } )

//Limpando a memória
DelClassIntf()

Return( )

/*/{Protheus.doc} SetParams
Solicita os parametros para execução do processo de inclusão dos períodos em lote
@author david.costa
@since 15/12/2017
@version 1.0
@return ${lRet}, ${retorna true se os parametros foram informados corretamente}
/*/Static Function SetParams( aParams, cBotaoOK, cCaption )

Local cDescricao	as character
Local nTop			as numeric
Local dDataIni	as date
Local dDataFim	as date
Local oFont		as object
Local lRet			as logical

Private oDlgParam	:= Nil

cDescricao	:= ""
nTop		:= 0
dDataIni	:= Nil
dDataFim	:= Nil
oFont		:= Nil
lRet		:= .F.

MV_PAR01	:= MV_PAR02 := "" 
MV_PAR01	:= PadR( MV_PAR01, TamSx3( "T0J_CODIGO" )[1])
MV_PAR02	:= PadR( MV_PAR02, TamSx3( "T0J_DESCRI" )[1])
cDescricao	:= PadR( MV_PAR02, TamSx3( "CWV_DESCRI" )[1])
dDataIni	:= FirstYDate( Date() )
dDataFim	:= LastYDate( Date() )

oFont := TFont():New( "Arial",, -11 )

oDlgParam := MSDialog():New( 50,50,310,590, Upper( cCaption ),,,.F.,,,,,,.T.,,,.T. )

nTop := 10

//Cód. Trib
TGet():New( nTop, 10, { |x| If( PCount() == 0, MV_PAR01, MV_PAR01 := x ) }, oDlgParam, 65, 10, "@!", { || VldPerg444( 1, .F. ) },,,,,, .T.,,,,,,,,, "T0J",,,,,,,, Upper( STR0002 ), 1, oFont ) //"Tributo"
TGet():New( nTop, 90, { |x| If( PCount() == 0, MV_PAR02, MV_PAR02 := x ) }, oDlgParam, 152, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, Upper( STR0082 ), 1, oFont ) //"Descrição"

nTop += 30

//Data Inicio
TGet():New( nTop,10, { |x| If( PCount() == 0, dDataIni, dDataIni := x ) }, oDlgParam, 65, 10, "@!", { || .T. },,,,,, .T.,,,,,,,,,,,,,,,,, Upper( STR0175 ), 1, oFont ) //Data Início

//Data Fim
TGet():New( nTop, 90, { |x| If( PCount() == 0, dDataFim, dDataFim := x ) }, oDlgParam, 65, 10, "@!", { || .T. },,,,,, .T.,,,,,,,,,,,,,,,,, Upper( STR0176 ), 1, oFont ) //Data Fim
nTop += 30

If Upper( cBotaoOK ) $ "INCLUIR"
	//Descrição
	TGet():New( nTop, 10, { |x| If( PCount() == 0, cDescricao, cDescricao := x ) }, oDlgParam, 152, 10, "@!",,,,,,, .T.,,, { || .T. },,,,,,,,,,,,,, Upper( STR0082 ), 1, oFont ) //"Descrição"
	nTop += 30
EndIf

//Cancelar
TButton():New( nTop, 10, Upper( STR0177 ), oDlgParam, { || lRet := .F., oDlgParam:End() }, 55,20,,,.F.,.T.,.F.,,.F.,,,.F. )//"Cancelar"

//Botão Confirmar
TButton():New( nTop, 90, Upper( cBotaoOK ), oDlgParam, { || lRet := VldParam() }, 55,20,,,.F.,.T.,.F.,,.F.,,,.F. )

oDlgParam:lCentered := .T.
oDlgParam:Activate()

aParams := { MV_PAR01, cDescricao, dDataIni, dDataFim }

Return( lRet )

/*/{Protheus.doc} VldParam
Valida os parametros da tela
@author david.costa
@since 15/12/2017
@version 1.0
/*/Static Function VldParam()

Local lOk as logical

lOk := .F.

lOk := VldPerg444( 1, .T. )

If lOk
	oDlgParam:End()
EndIf

Return( lOk )

/*/{Protheus.doc} VldPerg444
valida parametros de tela inseridos pelo usuário
@author david.costa
@since 15/12/2017
@version 1.0
@param nOpc, numérico, opção de campo a ser testado
@param lVldVazio, ${param_type}, informa se o campo deve ser validado vazio
/*/Static Function VldPerg444( nOpc, lVldVazio )

Local lRet	as logical

lRet	:=	.T.

If nOpc == 1

	If !Empty( MV_PAR01 )
		If T0J->( DBSetOrder( 2 ), T0J->( MsSeek( xFilial( "T0J" ) + MV_PAR01 ) ) )
			MV_PAR02 := AllTrim( T0J->T0J_DESCRI )
		Else
			MsgInfo( STR0173 ) //"Tributo inválido"
			lRet := .F.
		EndIf
	ElseIf lVldVazio
		MsgInfo( STR0174 ) //"Tributo não informado"
		lRet := .F.
	Else
		MV_PAR02 := ""
		MV_PAR02 := PadR( MV_PAR02, TamSx3( "T0J_DESCRI" )[1])
	EndIf
EndIf

Return( lRet )

/*/{Protheus.doc} IncluirLte
Incluir período em lote
@author david.costa
@since 15/12/2017
@version 1.0
/*/Static Function IncluirLte()

Local aParams		as array
Local cLogErros	as character
Local cPeriodic	as character
Local dDataInici	as date
Local dDataFim	as date

aParams	:= {}
cLogErros	:= ""
cPeriodic	:= ""
dDataInici	:= Nil
dDataFim	:= Nil

If SetParams( @aParams, STR0178, STR0170 ) //"Incluir"
	cPeriodic := Posicione( "T0J", 2, xFilial( "T0J" ) + aParams[ PARAM_LOTE_COD_TRIBUTO ], "AllTrim( T0J_PERAPU )" )
	
	While dDataFim == Nil .or. dDataFim < aParams[ PARAM_LOTE_DATA_FIM ]
		
		SetDataIni( aParams, @dDataInici, cPeriodic )
		SetDataFim( aParams, @dDataFim, cPeriodic )
		AddPeriodo( aParams[ PARAM_LOTE_DESC_PERIODO ], dDataFim, dDataInici, aParams[ PARAM_LOTE_COD_TRIBUTO ], @cLogErros )
		
	EndDo
EndIf

If !Empty( cLogErros )
	ShowLog( STR0015, cLogErros )//"Atenção"
EndIf

Return()

/*/{Protheus.doc} AddPeriodo
Cria um cadastro de período
@author david.costa
@since 15/12/2017
@version 1.0
@param cDescricao, character, Descrição do Cadastro
@param dDataFim, data, Data de término do período
@param dDataInici, data, Data de inicio do período
@param cCodTribut, character, Código do tributo inserido
@param cLogErros, character, Log de erros do processo
/*/Static Function AddPeriodo( cDescricao, dDataFim, dDataInici, cCodTribut, cLogErros )

Local oModelPeri	as object
Local lSucesso	as logical

oModelPeri	:= Nil
lSucesso	:= .T.

oModelPeri := FWLoadModel( 'TAFA444' )
oModelPeri:SetOperation( MODEL_OPERATION_INSERT )
oModelPeri:Activate()

T0J->( DBSetOrder( 2 ), T0J->( MsSeek( xFilial( "T0J" ) + cCodTribut ) ) )

lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_IDTRIB", T0J->T0J_ID )
lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_ALIQAP", T0J->T0J_VLALIQ )
lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_ALIQAD", T0J->T0J_ALADIR )
lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_VLISEN", T0J->T0J_PARCIS )
lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_PERADI", T0J->T0J_PERCAD )
lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_ALIQU1", T0J->T0J_ALIQL1 )
lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_ALIQU2", T0J->T0J_ALIQL2 )
lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_ALIQU3", T0J->T0J_ALIQL3 )
lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_ALIQU4", T0J->T0J_ALIQL4 )
lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_INIPER", dDataInici )
lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_FIMPER", dDataFim )
lSucesso := lSucesso .and. oModelPeri:SetValue( "MODEL_CWV", "CWV_DESCRI", cDescricao )
oModelPeri:lValid := lSucesso

If oModelPeri:VldData()
	If TAF444VldMdl( oModelPeri, .T., @cLogErros )
		FWFormCommit( oModelPeri )
	Else
		AddLogErro( STR0163, @cLogErros ) //"Não foi possível salvar o cadastro"
	EndIf
ElseIf !Empty( oModelPeri:GetErrorMessagem()[6] )
	AddLogErro( STR0163, @cLogErros ) //"Não foi possível salvar o cadastro"
	AddLogErro( STR0165, @cLogErros, { oModelPeri:GetErrorMessagem()[4], ENTER,; //"Campo: @1 @2Detalhes: @3, @2 @4"
			 oModelPeri:GetErrorMessagem()[6], oModelPeri:GetErrorMessagem()[7] } )
EndIf

oModelPeri:Destroy()

Return( lSucesso )

/*/{Protheus.doc} SetDataFim
Defini a data fim do perído conforme as configurações do tributo
@author david.costa
@since 15/12/2017
@version 1.0
@param aParams, array, Parametro do processo
@param dDataFim, data, Data fim atual
@param cPeriodic, character, Periodicidade do tributo
/*/Static Function SetDataFim( aParams, dDataFim, cPeriodic )

If cPeriodic == TRIBUTO_ANUAL
	If dDataFim == Nil
		dDataFim := LastYDate( aParams[ PARAM_LOTE_DATA_INICIO ] )
	Else
		dDataFim := YearSum( dDataFim, 1 )
	EndIf
Else
	If dDataFim == Nil
		dDataFim := LastDate( aParams[ PARAM_LOTE_DATA_INICIO ] )
		If cPeriodic == TRIBUTO_TRIMESTRAL
			While ! ( StrZero( Month( dDataFim ), 2 ) $ "03|06|09|12" )
				dDataFim := LastDate( MonthSum( dDataFim, 1 ) )
			EndDo
		EndIf
	ElseIf cPeriodic == TRIBUTO_MENSAL
		dDataFim := LastDate( MonthSum( dDataFim, 1 ) )
	ElseIf cPeriodic == TRIBUTO_TRIMESTRAL
		dDataFim := LastDate( MonthSum( dDataFim, 3 ) )
	EndIf
EndIf
	
Return()

/*/{Protheus.doc} SetDataIni
Defini a data de início do perído conforme as configurações do tributo
@author david.costa
@since 15/12/2017
@version 1.0
@param aParams, array, Parametro do processo
@param dDataInici, data, Data de início do processo
@param cPeriodic, character, Periodicidade do tributo
/*/Static Function SetDataIni( aParams, dDataInici, cPeriodic )

If cPeriodic == TRIBUTO_ANUAL
	If dDataInici == Nil
		dDataInici := FirstYDate( aParams[ PARAM_LOTE_DATA_INICIO ] )
	Else
		dDataInici := YearSum( dDataInici, 1 )
	EndIf
Else
	If dDataInici == Nil
		dDataInici := FirstDate( aParams[ PARAM_LOTE_DATA_INICIO ] )
		If cPeriodic == TRIBUTO_TRIMESTRAL
			While ! ( StrZero( Month( dDataInici ), 2 ) $ "01|04|07|10" )
				dDataInici := MonthSub( dDataInici, 1 )
			EndDo
		EndIf
	ElseIf cPeriodic == TRIBUTO_MENSAL
		dDataInici := MonthSum( dDataInici, 1 )
	ElseIf cPeriodic == TRIBUTO_TRIMESTRAL
		dDataInici := MonthSum( dDataInici, 3 )
	EndIf
EndIf
	
Return()

/*/{Protheus.doc} TAF444ELTE
Encerramento de período em lote
@author david.costa
@since 18/12/2017
@version 1.0
/*/Function TAF444ELTE(lAutomato)

Local cNomWiz    as character 
Local lEnd       as logical
Local aParams		as array
Local cLogProces	as character
Local cAliasQry	as character
Local lRetorno	as logical

Private oProcess := Nil

Default lAutomato := .F.

cNomWiz   	:= STR0021 //Encerrando Período 
lEnd      	:= .F.
aParams	:= {}
cLogProces	:= ''
cAliasQry	:= ''

If !lAutomato
	lRetorno := SetParams( @aParams, STR0023, STR0171 ) // "Encerrar"; "Encerrar Período em Lote"
Else
	aParams := {cCodigo, ' ', STOD(cIniPer), STOD(cFimPer)}
	lRetorno := .T.
EndIf

If lRetorno

	cAliasQry := SelecIdPer( aParams )
	
	While ( cAliasQry )->( !Eof() )
		
		If !lAutomato
			oProcess := Nil
			oProcess := TAFProgress():New( { |lEnd| EncerraLte( @cLogProces, ( cAliasQry )->( CWV_ID ) ) }, STR0021 ) //Encerrando Período 
			oProcess:Activate()
		Else
			EncerraLte( @cLogProces, ( cAliasQry )->( CWV_ID ), lAutomato )
		EndIf

		DelClassIntf()
		( cAliasQry )->( DbSkip() )
	EndDo
EndIf

If !Empty( cLogProces ) .And. !lAutomato
	ShowLog( STR0015, cLogProces )//"Atenção"
EndIf

Return( )

/*/{Protheus.doc} EncerraLte
Controla as chamadas de encerramento dos períodos
@author david.costa
@since 18/12/2017
@version 1.0
/*/Static Function EncerraLte( cLogProces, cIdPer, lAutomato )

Local oModelPeri	as object
Local cLogErrTmp	as character
Local cLogAviTmp	as character

Default lAutomato := .F.

oModelPeri	:= Nil
cLogErrTmp	:= ''
cLogAviTmp	:= ''

If LoadPeriod( @oModelPeri, cIdPer )
	
	cLogProces += ENTER + STR0081 + " " + dToc( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) + " à " + " " + dToc( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) )//"Período"
	Taf444Encerrar( @oModelPeri, @cLogErrTmp, @cLogAviTmp, lAutomato )
		
	If !Empty( cLogErrTmp )
		cLogProces += ENTER + cLogErrTmp
		cLogErrTmp := ''
	EndIf
	
	If !Empty( cLogAviTmp )
		cLogProces += ENTER +  cLogAviTmp
		cLogAviTmp := ''
	EndIf

	oModelPeri:DeActivate()
	FreeObj( oModelPeri )
EndIf

If !lAutomato
	oProcess:Destroy()
Endif

Return()

/*/{Protheus.doc} SelecIdPer
Seleciona os períodos que serão processados da execução em lote
@author david.costa
@since 18/12/2017
@version 1.0
@param aParams, array, Paramentros do processo
@param lOrdemInve, logical, informa se os perídos devem ser selecionados pela ordem inversa
/*/Static Function SelecIdPer( aParams, lOrdemInve )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cOrderBy	as character

Default lOrdemInver := .F.

cAliasQry	:= ""
cSelect		:= ""
cFrom		:= ""
cWhere		:= ""
cOrderBy	:= ""

cAliasQry := GetNextAlias()

cSelect	:= " CWV_ID "
cFrom		:= RetSqlName( "CWV" ) + " CWV "
cWhere		:= " CWV.D_E_L_E_T_ = '' "
cWhere		+= " AND CWV_FILIAL = '" + xFilial( "CWV" ) + "' "
cWhere		+= " AND CWV_INIPER >= '" + DTOS( aParams[ PARAM_LOTE_DATA_INICIO ] ) + "' "
cWhere		+= " AND CWV_FIMPER <= '" + DTOS( aParams[ PARAM_LOTE_DATA_FIM ] ) + "' "
cWhere		+= " AND CWV_IDTRIB = '" + Posicione( "T0J", 2, xFilial( "T0J" ) + aParams[ PARAM_LOTE_COD_TRIBUTO ], "T0J_ID" ) + "' "
cOrderBy	:= " CWV_FIMPER, CWV_ANUAL "

If lOrdemInver
	cOrderBy	:= " CWV_FIMPER DESC , CWV_ANUAL DESC "
EndIf

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere 	:= "%" + cWhere  	+ "%"
cOrderBy 	:= "%" + cOrderBy	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%
EndSql

Return( cAliasQry )

/*/{Protheus.doc} LoadPeriod
Carrega o Model do Período
@author david.costa
@since 15/12/2017
@version 1.0
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param cIdPeriodo, character, Identificador do período
@return ${lRet}, ${verdadeiro se o model for carregado}
@example
LoadPeriod( @oModelPeri, cIdPeriodo )
/*/Static Function LoadPeriod( oModelPeri, cIdPeriodo )

Local lRet		as logical

lRet	:= .F.

DbSelectArea( "CWV" )
CWV->( DbSetOrder( 1 ) )

If CWV->( MsSeek( xFilial( "CWV" ) + cIdPeriodo ) )
	oModelPeri := FWLoadModel( 'TAFA444' )
	oModelPeri:SetOperation( MODEL_OPERATION_UPDATE )
	oModelPeri:Activate()
	lRet := .T.
EndIf

Return( lRet )
/*/{Protheus.doc} TAF444ELTE
Reabertura de período em lote
@author david.costa
@since 18/12/2017
@version 1.0
/*/Function TAFA444ALTE( lAutomato )

Local cNomWiz	as character
Local lEnd		as logical

Private oProcess := Nil

Default lAutomato := .F.

cNomWiz    := STR0078 //"Processando" 
lEnd       := .T.

//Cria objeto de controle do processamento
If !lAutomato
	oProcess := TAFProgress():New( { |lEnd| ReabrirLte( ) }, cNomWiz )
	oProcess:Activate()
Else
	ReabrirLte( lAutomato )
EndIf
//Limpando a memória
DelClassIntf()

Return( )

/*/{Protheus.doc} ReabrirLte
Controla as chamadas de reabertura dos períodos
@author david.costa
@since 18/12/2017
@version 1.0
/*/Static Function ReabrirLte( lAutomato )

Local aParams		as array
Local cLogProces	as character
Local cLogProTmp	as character
Local cAliasQry	as character
Local oModelPeri	as object
Local lRetorno	as logical

Default lAutomato := .F.

aParams	:= {}
cLogProces	:= ''
cLogProTmp	:= ''
cAliasQry	:= ''
oModelPeri	:= Nil

If !lAutomato
	lRetorno := SetParams( @aParams, STR0179, STR0172 ) // "Reabrir", "Reabrir Período em Lote"
Else
	aParams := {cCodigo, ' ', STOD(cIniPer), STOD(cFimPer)}
	lRetorno := .T.
EndIf

If lRetorno

	cAliasQry := SelecIdPer( aParams, .T. )
	
	While ( cAliasQry )->( !Eof() )
		
		If LoadPeriod( @oModelPeri, ( cAliasQry )->( CWV_ID ) )
			
			cLogProTmp := STR0081 + " " + dToc( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) + " à " + " " + dToc( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) + ENTER //"Período"
			Taf444Reabrir( @oModelPeri, @cLogProTmp, lAutomato )
			cLogProces += ENTER + cLogProTmp
			cLogProTmp := ''

			oModelPeri:DeActivate()
		EndIf

		( cAliasQry )->( DbSkip() )
	EndDo
EndIf

If oModelPeri != Nil
	FreeObj( oModelPeri )
EndIf

If !Empty( cLogProces ) .And. !lAutomato
	ShowLog( STR0015, cLogProces)//"Atenção"
EndIf

If !lAutomato
	oProcess:Set1Progress( 1 )
	oProcess:Set2Progress( 1 )
	oProcess:Inc1Progress( STR0179 ) // "Reabrir"
	oProcess:Inc2Progress( STR0034 ) //"Clique em finalizar"

	oProcess:Destroy()
Endif

Return()

/*/{Protheus.doc} GetLimite
Retorna o limite de compensação para que seja criado o lançamento automatico
@author david.costa
@since 08/01/2018
@version 1.0
/*/Static Function GetLimite( oModelGrup, aParametro )

Local nVlrLimite	as numeric
Local nBaseLimit	as numeric
Local nPerDedCom	as numeric
Local cTpDedComp	as character

nVlrLimite	:= 0
nBaseLimit	:= 0
nPerDedCom	:=	Iif( oModelGrup:GetValue( "T0O_PERDED" ) == 0, 1, oModelGrup:GetValue( "T0O_PERDED" ) / 100 )
cTpDedComp	:=	xFunID2Cd( oModelGrup:GetValue( "T0O_IDLIDC" ), "T0L", 1 )

Do Case
	Case cTpDedComp == APL_RESULTADO_OPERACIONAL
		nBaseLimit := aParametro[ GRUPO_RESULTADO_OPERACIONAL ]
	Case cTpDedComp == APL_RESULTADO_NAO_OPERACIONAL
		nBaseLimit := aParametro[ GRUPO_RESULTADO_NAO_OPERACIONAL ]
	Case cTpDedComp == APL_RESULTADO_EXERCICIO
		nBaseLimit := VlrResCont( aParametro )
	Case cTpDedComp == APL_LUCRO_REAL_ANTES_COMP_PREJ
		nBaseLimit := VlrLRAntes( aParametro )
	Case cTpDedComp == APL_LUCRO_REAL
		nBaseLimit := VlrLucReal( aParametro )
	Case cTpDedComp == APL_BASE_X_ALIQUOTA
		nBaseLimit := VlrBCxAliq( aParametro )
EndCase

nVlrLimite := nBaseLimit * nPerDedCom

Return( nVlrLimite )

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowLog

Exibe a mensagem de log de ocorrências.

@Param		cTitle	- Título da interface
			cBody	- Corpo da mensagem

@Author		Felipe C. Seolin
@Since		26/12/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ShowLog( cTitle, cBody )

Local oModal	as object

oModal	:=	FWDialogModal():New()

oModal:SetTitle( cTitle )
oModal:SetFreeArea( 250, 150 )
oModal:SetEscClose( .T. )
oModal:SetBackground( .T. )
oModal:CreateDialog()
oModal:AddCloseButton()

TMultiGet():New( 030, 020, { || cBody }, oModal:GetPanelMain(), 210, 100,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )

oModal:Activate()

Return()
