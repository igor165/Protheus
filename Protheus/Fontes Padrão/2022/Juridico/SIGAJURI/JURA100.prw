#INCLUDE "JURA100.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

Static xVarCodAnd  := ''   // Variavel Static do Código do Andamento para passagem de valores entre funções
Static __lFirstUse := .T.
Static oModel095   := nil  // Ira transportar o oModel do JURA095 para a ExecView.
Static aModel095   := {}   // Retorna os Modelos utilizados no JURA095.
Static lIniJ95     := .T.  // Inicializa os campos da Liminar no processo quando chamado pela primeira vez.
Static lVisualiza  := .F.
Static cFlxMJson   := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100
Andamentos.

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100
Filtra os andamentos do assunto jurídico
Uso no cadastro de Andamentos.

@param 	cProcesso 	Código do Assunto Jurídico \r\n
@param  lPesq   	  .T. - Indica que a rotina foi chamada pela tela de
										Pesquisa(JURA100) ou
										.F. - Indica que a rotina foi chamada por dentro
										do Processo(JURA095) via ações relacionadas


@author Juliana Iwayama Velho
@since 23/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100(cProcesso, lChgAll, oXModel095, aXModel095, cFilFiltro, cFiltroAux)

Local cHabPesqA	:= SuperGetMV("MV_JHBPESA",, '1') //“Habilita a tela de pesquisa de andamentos (1=Sim;2=Não)"
Local oBrowse
Local aArea     := GetArea()
Local aAreaNSZ  := NSZ->( GetArea() )
Local cGrpRest  := JurGrpRest()
Local cFiltro   := ""

Default cProcesso  := ''
Default lChgAll	   := .T.
Default oXModel095 := nil
Default aXModel095 := {}
Default cFilFiltro := xFilial("NT4")
Default cFiltroAux := ""

oModel095 := oXModel095 //Passa o Model para a variavel Static.
aModel095 := aXModel095 //Passa os Modelos utilizados no JURA095 para a variavel Static.

lIniJ95   := .T. //Ao chamar a tela de processo pela primeira vez, inicializa os campos da Liminar.

If cHabPesqA == '1' .AND. !(IsInCallStack('JURA095') .Or. IsInCallStack('JURA162') .Or. IsInCallStack('JURA219'))
	MsgRun(STR0032,STR0043, {||JURA162("4",STR0007,"JURA100")}) //"Carregando..." # "Aguarde..."
Else

	dbSelectArea("NT4")

	oBrowse := FWMBrowse():New()
	oBrowse:SetChgAll( lChgAll )
	oBrowse:SetDescription( STR0007 )
	oBrowse:SetAlias( "NT4" )
	oBrowse:SetLocate()

	If !Empty( cProcesso )
		cFiltro := "NT4_FILIAL == '" + cFilFiltro + "' .AND. NT4_CAJURI == '" + cProcesso + "'"
  	EndIf

  	//Verifica se o usuario logado é cliente ou correspondente para filtrar apenas o andamento que ele tem acesso
	If "CLIENTES" $ cGrpRest .Or. "CORRESPONDENTES" $ cGrpRest
		cFiltro += IIF( !Empty(cFiltro), " .AND. ", "")
		cFiltro += "NT4_PCLIEN == '1'"
	EndIf

	If !Empty(cFiltroAux)
		cFiltro += IIF( !Empty(cFiltro), " .AND. ", "") + cFiltroAux
	EndIf

  	oBrowse:SetFilterDefault(cFiltro)
	oBrowse:SetMenuDef( 'JURA100' )

	JurSetBSize( oBrowse, '50,50,50' )
	JurSetLeg( oBrowse, "NT4"  )
	//Ordenação do grid de andamentos de forma decrescente
	NT4->(dbSetOrder(6))

	oBrowse:Activate()

	RestArea( aAreaNSZ )
	RestArea( aArea )
EndIf

oXModel095 := oModel095 //Passa o Model da variavel Static alterada para o oModel referenciado do JURA095.

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0016, "JurAnexos('NT4', NT4->NT4_COD, 1)", 0, 1, 0, .T. } ) // "Anexos"

	If JA162AcRst('04')
		aAdd( aRotina, { STR0002, "VIEWDEF.JURA100", 0, 2, 0, NIL } ) // "Visualizar"
	EndIf

	//Verifica se não é Histórico do Fluig
	If !IsInCallStack("J95HisFlu")

		If JA162AcRst('04',3)
			aAdd( aRotina, { STR0003, "VIEWDEF.JURA100", 0, 3, 0, NIL } ) // "Incluir"
		EndIf

		If JA162AcRst('04',4)
			aAdd( aRotina, { STR0004, "J100Manut(4, '" + STR0004 + "')", 0, 4, 0, NIL } ) // "Alterar"
		EndIf

		If JA162AcRst('04',5)
			aAdd( aRotina, { STR0005, "J100Manut(5, '" + STR0005 + "')", 0, 5, 0, NIL } ) // "Excluir"
		EndIf
	EndIf

	If JA162AcRst('13')
		aAdd( aRotina, { STR0019, "RelatAnd()", 0, 1, 0, NIL } ) // "Relatório"
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} J100Manut
Efetua pré validações antes das operações de alteração e exclusão

@author  Rafael Tenorio da Costa
@since   27/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J100Manut(nOpc, cTitTela)

	Local aArea := GetArea()
	Local cAto	:= SuperGetMv("MV_JATOHIF", , "")

	//Verifica se é um andamento com ato de historico fluig
	If ( nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_DELETE ) .And. !Empty(cAto) .And. cAto == NT4->NT4_CATO
		JurMsgErro(STR0053) //"Andamento de Histórico do Fluig, registro não pode ser modificado."
	Else
		FWExecView(cTitTela, "JURA100", nOpc, , {|| .T.})
	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Andamentos

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA100" )
Local oStruct    := Nil
Local cTipoAs    := ""
Local cTipoAsP   := ""
Local cCajuri    := JA100CAJUR() //Pega o cajuri usando a função usada no inicializador padrão

If Empty(AllTrim(cCajuri)) // Caso seja visualização a função JA100CAJUR() retornará vazio e a variável deverá ser preenchida com o conteúdo gravado na tabela.
	cCajuri := NT4->NT4_CAJURI
EndIf

If Type("cTipoAj") == 'U'
	cTipoAJ := 'CFG' //Indica que se trata da configuração de papeis de trabalho feitos pelo SIGACFG
	cTipoAs := cTipoAj
ElseIf !Empty(AllTrim(cTipoAj)) //Private vinda da JURA162
	If cTipoAj == JurGetDados("NSZ",1,XFILIAL("NSZ")+cCajuri, "NSZ_TIPOAS")
		cTipoAs := JurGetDados("NSZ",1,XFILIAL("NSZ")+cCajuri, "NSZ_TIPOAS")
	Else
		cTipoAs := cTipoAj
	EndIf
Else
	cTipoAs := JurGetDados("NSZ",1,XFILIAL("NSZ")+cCajuri, "NSZ_TIPOAS")
Endif

cTipoAsP  := cTipoAs

If cTipoAsP > '050' .And. cTipoAsP != 'CFG'
	cTipoASP := JurGetDados('NYB', 1, xFilial('NYB') + cTipoAS, 'NYB_CORIG')
EndIf

If cTipoAJ != 'CFG'
	oStruct := FWFormStruct( 2, "NT4", { | cCampo | JURCPO(cCampo, xFilial('NT4'), cCajuri, cTipoAs) } )
	JGetNmFld(oStruct, cTipoAs, cTipoAsP)
Else
	oStruct    := FWFormStruct( 2, "NT4" )
EndIf

JurSetAgrp( 'NT4',, oStruct )

oStruct:RemoveField( "NT4_DTDESC" )

If (oStruct:HasField( "NT4_DTPREV" ))
	oStruct:RemoveField( "NT4_DTPREV" )
EndIf

If (oStruct:HasField( "NT4_CODREL" ))
	oStruct:setProperty("NT4_CODREL",  MVC_VIEW_CANCHANGE, .F.)
EndIf

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA100_VIEW" , oStruct , "NT4MASTER"  )
oView:createHorizontalBox("FORMFIELD", 100)
oView:SetOwnerView( "JURA100_VIEW","FORMFIELD" )
oView:SetDescription( STR0007 ) // "Andamentos"
oView:EnableControlBar( .T. )

If JA162AcRst('03')
	oView:AddUserButton( STR0016, "CLIPS", {| oView | IIF( J95AcesBtn(), JurAnexos("NT4", NT4->NT4_COD, 1), FWModelActive() ) } )
EndIf
oView:setUseCursor(.F.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Andamentos

@author Juliana Iwayama Velho
@since 27/05/09
@version 1.0

@obs NT4MASTER - Dados do Andamentos

/*/
//-------------------------------------------------------------------
Static Function Modeldef()

Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NT4" )
Local lNZLInDic  := FWAliasInDic("NZL") //Verifica se existe a tabela NZL no Dicionário (Proteção)
Local lWSTLegal  := JModRst()
Local oStructNZL

If lWSTLegal // Se a chamada estiver vindo do TOTVS Legal
	//Campo que indica se o registro posicionado possui anexo - criado para o TOTVS Legal
	oStruct:AddField( ;
		""                                                 , ; // [01] Titulo do campo
		""		                                           , ; // [02] ToolTip do campo
		"NT4__TEMANX"                                      , ; // [03] Id do Field
		"C"                                                , ; // [04] Tipo do campo
		2                                                  , ; // [05] Tamanho do campo
		0                                                  , ; // [06] Decimal do campo
		,                                                    ; // [07] Bloco de código de validação do campo
		,                                                    ; // [08] Bloco de código de validação when do campo
		,                                                    ; // [09] Lista de valores permitido do campo
		,                                                    ; // [10] Indica se o campo tem preenchimento obrigatório
		{|| JTemAnexo("NT4",NT4->NT4_CAJURI,NT4->NT4_COD)} , ; // [11] Bloco de código de inicialização do campo
		,                                                    ; // [12] Indica se trata-se de um campo chave
		,                                                    ; // [13] Indica se o campo não pode receber valor em uma operação de update
		.T.                                                  ; // [14] Indica se o campo é virtual
		,                                                    ; // [15] Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
	)

	//Campo com o objeto Json dos fluxos com intervenção manual para a geração automatica de fups/ andamentos - criado para o TOTVS Legal
	oStruct:AddField( ;
		""                                                 , ; // [01] Titulo do campo
		""		                                           , ; // [02] ToolTip do campo
		"NT4__FLXMAN"                                      , ; // [03] Id do Field
		"M"                                                , ; // [04] Tipo do campo
		10                                                  , ; // [05] Tamanho do campo
		0                                                  , ; // [06] Decimal do campo
		,                                                    ; // [07] Bloco de código de validação do campo
		,                                                    ; // [08] Bloco de código de validação when do campo
		,                                                    ; // [09] Lista de valores permitido do campo
		.F.,                                                 ; // [10] Indica se o campo tem preenchimento obrigatório
	)
Endif

//Força o inicializador padrão
oStruct:SetProperty("NT4_DTDESC", MODEL_FIELD_INIT, {|| cValToChar(99999999 - Val( DtoS(M->NT4_DTANDA) ))}) 

If lNZLInDic
	oStructNZL := FWFormStruct( 1, "NZL" )
	oStructNZL:RemoveField( "NZL_CANDAM" )
EndIf

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA100", /*Pre-Validacao*/, {|oX| JURA100TOK(oX)}/*Pos-Validacao*/, {|oX| JURA100COM(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NT4MASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Andamentos"
oModel:GetModel( "NT4MASTER" ):SetDescription( STR0009 ) // "Dados de Andamentos"

If lNZLInDic
	oModel:AddGrid( "NZLDETAIL", "NT4MASTER" /*cOwner*/, oStructNZL, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:GetModel( "NZLDETAIL" ):SetDescription( STR0045 ) //"Retorno Andamento Fluig"
	oModel:GetModel( "NZLDETAIL" ):SetUniqueLine( { "NZL_CODWF" } )

	oModel:SetRelation( "NZLDETAIL", { { "NZL_FILIAL", "XFILIAL('NZL')" }, { "NZL_CANDAM", "NT4_COD" } }, NZL->( IndexKey( 1 ) ) )

	oModel:GetModel( "NZLDETAIL" ):SetDelAllLine( .F. )
	oModel:GetModel( "NZLDETAIL" ):SetUseOldGrid( .F. )

	oModel:SetOptional( "NZLDETAIL" , .T. )

	JurSetRules( oModel, "NZLDETAIL",, "NZL" )
EndIf
oModel:SetVldActivate ( { |oX| JURA100VAL( oX ) } )

JurSetRules( oModel, "NT4MASTER",, "NT4" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100Fase
Retorna a fase processual de maior prioridade dos andamentos
Uso no cadastro de Andamentos.

@param 	cAssJur  	Código do Assunto Jurídico
@Return cDescItem	Descrição da fase
@sample

@author Juliana Iwayama Velho
@since 03/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100Fase(cAssJur,cFilOri,lCodigo)
Local cQueryNumP := ""
Local cDescItem  := ""
Local cCodItem   := ""
Local aArea      := GetArea()
Local cNumPrior  := GetNextAlias()
Local oModel     := FWModelActive()
Local cRet       := ""

Default cAssJur	 := ""
Default cFilOri	 := xFilial("NT4")
Default lCodigo	 := .F.

	If Empty(cAssJur) //Verifica se esta sendo utilizado na exportação personalizada como formula
		If oModel:GetId() == "JURA219"
			If oModel:GetModel('NT4MASTER'):Length() > 0
				cAssJur := oModel:GetValue('NT4MASTER','NT4_CAJURI')
			EndIf
		Elseif oModel:GetId() == "JURA095"
			cAssJur := oModel:GetValue('NSZMASTER','NSZ_COD')
		Else
			cAssJur := oModel:GetValue('NT4MASTER','NT4_CAJURI')
		EndIf

		If cAssJur == Nil
			cAssJur := ""
		EndIf
	Endif

	cQueryNumP := "SELECT NQG_PRIORI, NQG_DESC, NQG_COD"
	cQueryNumP += " FROM " + RetSqlName("NQG") + " NQG INNER JOIN " + RetSqlName("NT4") + " NT4"
	cQueryNumP += 	" ON NT4_CFASE = NQG_COD"
	cQueryNumP += " WHERE NQG_FILIAL = '" + xFilial("NQG") + "'"
	cQueryNumP +=   " AND NT4_FILIAL = '" + cFilOri + "'"
	cQueryNumP +=   " AND NT4_CAJURI = '" + cAssJur + "'"
	cQueryNumP +=   " AND NT4.D_E_L_E_T_ = ' '"
	cQueryNumP +=   " AND NQG.D_E_L_E_T_ = ' '"
	cQueryNumP += " ORDER BY NQG_PRIORI DESC, NT4_DTANDA DESC "

	cQueryNumP := ChangeQuery(cQueryNumP)
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQueryNumP), cNumPrior, .T., .T.)

	if !(cNumPrior)->( Eof() )
		cDescItem := (cNumPrior)->NQG_DESC
		cCodItem  := (cNumPrior)->NQG_COD
	endif

	(cNumPrior)->( dbCloseArea() )
	RestArea(aArea)

	if (lCodigo) //valida se deve ser retornado o códugo ou a descrição
		cRet := cCodItem
	Else
		cRet := cDescItem
	Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100GFw
Verifica se o ato processual está configurado para sugestão de follow-up
Uso no cadastro de Andamentos.

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 03/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100GFw(oModel)

Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaNRO   := NRO->( GetArea() )
Local aAreaNRT   := NRT->( GetArea() )
Local cAto       := oModel:GetValue("NT4MASTER","NT4_CATO")
Local lVincFwp   := SuperGetMV('MV_JVINCAF',, '2') == '1'
Local cCodAnd    := oModel:GetValue('NT4MASTER','NT4_COD')
Local cAssJur    := oModel:GetValue('NT4MASTER','NT4_CAJURI')
Local dDtFw      := oModel:GetValue('NT4MASTER','NT4_DTANDA')
Local cCodFup    := oModel:GetValue('NT4MASTER','NT4_CFWLP')
Local cDesc      := oModel:GetValue('NT4MASTER','NT4_DESC')
Local dDtPrEv    := oModel:GetValue('NT4MASTER','NT4_DTPREV')
Local lDtProxEv  := .F.
Local lWSTLegal  := JModRst()

Default cFlxMJson := ''

	If lWSTLegal .And. Empty(cFlxMJson)
		cFlxMJson := oModel:GetValue('NT4MASTER','NT4__FLXMAN')
	EndIf

	If !Empty(dDtPrEv)
		dDtFw     := dDtPrEv
		lDtProxEv := .T.
	EndIf

	NRO->( dbSetOrder( 1 ) )
	If NRO->( dbSeek( xFilial( 'NRO' ) + cAto ) )
		If !Empty(NRO->NRO_CFWPAD)
			NRT->( dbSetOrder( 1 ) )
			If NRT->( dbSeek( xFilial( 'NRT' ) + NRO->NRO_CFWPAD ) )
				lRet := JA106TIPOP( NRT->NRT_CTIPOF )
				If lRet
					If !(IsInCallStack( 'JURA020' ) .Or. IsInCallStack( 'TombAutom' )) .And. NRT->NRT_TIPOGF == '2'
						If !lWSTLegal
							If ApMsgYesNo(STR0010)

								oModelJ106 := FWLoadModel("JURA106")
								oModelJ106:SetOperation(MODEL_OPERATION_INSERT)
								oModelJ106:Activate()
								
								oModelJ106:SetValue("NTAMASTER","NTA_CANDAM",NT4->NT4_COD)

								lRet := ( FWExecView(STR0003, "JURA106", 3, , {||.T.}, , , , , , , oModelJ106) == 0 )	//"Incluir"

							EndIf
						Else
							lRet := J100IUJson(,,NT4->NT4_COD)
						EndIf

						//Vínculo de andamento e follow-up
						If lRet .And. lVincFwp
							JA106SetCf('')
						EndIf
					ElseIf NRT->NRT_TIPOGF == '1'
						lRet := JA100GFWAT(cAssJur, dDtFw, NRT->NRT_CTIPOF, cCodAnd, cCodFup, cDesc, lDtProxEv )
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aAreaNRT )
	RestArea( aAreaNRO )
	RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100GFWAT
Rotina para inclusão de follow-ups automático pelo andamento

@param cAssJur   - Código do assunto jurídico
@param dDtFw     - Data do andamento
@param cTipoFw   - Tipo de follow-up a partir do ato processual
@param lDtProxEv - Se a data vem do campo prox evento, se sim, não calcula as datas 

@author Juliana Iwayama Velho
@since 26/03/10
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA100GFWAT(cAssJur, dDtFw , cTipoFw, cCodAnd, cFupPai, cDesc, lDtProxEv)
Local aArea := GetArea()
Local lRet  := .T.

Default lDtProxEv := .F.

	lRet := J106GFWAUT(cAssJur, '', dDtFw, cTipoFw, cCodAnd, cFupPai, cDesc,, lDtProxEv)

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100CAN
Verifica se o processo está cancelado e o parametro de configuração. Se sim, só é possível
visualizar o andamento

@param 	cAssJur  	Código do assunto jurídico
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 03/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100CAN(cAssJur)
Local lRet       := .T.
Local cCancelado := ''
If !Empty(cAssJur)
	cCancelado := Posicione('NSZ', 1 , xFilial('NSZ') + cAssJur, 'NSZ_CANCEL')

	If (GetMV('MV_JANDCAN',, '2') == '1') .And. (cCancelado == '1')
		JurMsgErro(STR0011)
		lRet := .F.
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100VAL
Verifica situação do processo e se o mesmo está cancelado, para permitir ou não operações
de andamento

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 03/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100VAL(oModel)
Local lRet    := .T.
Local cAssJur := ''
Local nOpc    := oModel:GetOperation()

If IsInCallStack('JURA106COM') .And. (nOpc > 2 .Or. nOpc > 3)
	cAssJur := NTA->NTA_CAJURI
ElseIf (  IsInCallStack( 'JURA095' ) .Or. IsInCallStack( 'JURA162' )  .And. nOpc > 2 ) .Or. ;
   ( !IsInCallStack( 'JURA095' ) .And. !IsInCallStack( 'JURA162' ) .And. nOpc > 3 )
	cAssJur := If(Empty(NT4->NT4_CAJURI),M->NT4_CAJURI,NT4->NT4_CAJURI)
EndIf

If !Empty(cAssJur)
	lRet := JURA100CAN(cAssJur)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100DTD
Verifica se a data do andamento é menor que a data de distribuição do processo
ou maior que a data atual, conforme configuração de parametro
Uso no cadastro de Andamentos.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 03/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100DTD(oModel)
Local lRet      := .T.
Local dDistrib
//Local oModel    := FWModelActive()
Local cAssJur   := oModel:GetValue("NT4MASTER","NT4_CAJURI")
Local dAndam    := oModel:GetValue("NT4MASTER","NT4_DTANDA")

dDistrib := Posicione('NUQ', 2 , xFilial('NUQ') + cAssJur, 'NUQ_DTDIST')

if GetMV('MV_JTRVADT',, '2') == '1'
	If !Empty(dDistrib) .And. ((dAndam < dDistrib).Or.(dAndam > Date()))
		//"A data do andamento não pode ser superior à data atual (data base) e inferior à data de distribuição da instância atual."
		JurMsgErro(STR0012)
		lRet := .F.
	EndIf
endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100TOK
Valida as informações de andamento
Uso no cadastro de Andamentos.

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 05/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100TOK(oModel)
Local lRet        := .T.
Local aArea       := GetArea()
Local aAreaNT4    := NT4->( GetArea() )
Local aAreaNRO    := NRO->( GetArea() )
Local aAreaNSZ    := NSZ->( GetArea() )
Local nOpc        := oModel:GetOperation()
Local cAndPrinc   := ''
Local cFwpPrinc   := ''
Local aSaveLines  := FWSaveRows()

	If nOpc == 3 .Or. nOpc == 4

		If nOpc == 3
			If ( !IsInCallStack( 'JURA095' ) .And. !IsInCallStack( 'JURA162' ) )
				lRet := JURA100CAN(oModel:GetValue("NT4MASTER","NT4_CAJURI"))
			EndIf

			If lRet .And. SuperGetMV('MV_JVINCAF',, '2') == '1' //.And. IsInCallStack( 'JURA106COM')
				JA100SetCa( oModel:GetValue("NT4MASTER","NT4_COD") )
			EndIf
		EndIf

		If lRet
			lRet := JURA100DTD(oModel)
		EndIf

		If lRet
			If nOpc == 4
				oModel:SetValue("NT4MASTER",'NT4_DTALTE' ,DATE())
				oModel:LoadValue("NT4MASTER",'NT4_USUALT',PadR( PswChave(__CUSERID), TamSX3('NT4_USUALT')[1] ) )
			EndIf
		EndIf

		//Validações da Liminar e Sentença
		If lRet
			lRet := VldLimSen(oModel)
		EndIf
	EndIf

	If nOpc > 2 .And. lRet

		lRet := JURSITPROC(oModel:GetValue("NT4MASTER","NT4_CAJURI"), 'MV_JTVENAN')

		If lRet .And. nOpc == 5

			lRet := JurExcAnex ('NT4',oModel:GetValue("NT4MASTER","NT4_COD"))

			If lRet .And. SuperGetMV('MV_JVINCAF',, '2') == '1'
				cAndPrinc := NT4->NT4_COD
				cFwpPrinc := NT4->NT4_CFWLP

				JA100SetCa(cAndPrinc)

				lRet := JA100VincF(1,cAndPrinc,cFwpPrinc)

				If lRet
					lRet := JA100VincF(2,cAndPrinc,cFwpPrinc)
				EndIf

			EndIf

		EndIf

	EndIf

	If lRet .And. SuperGetMV('MV_JINTJUR',, '2') == '1'
		JurIntJuri(oModel:GetValue("NT4MASTER","NT4_COD"),oModel:GetValue("NT4MASTER","NT4_CAJURI"), "2", Str(nOpc))
	EndIf

	If lRet
		JA100SetCa('')
	EndIf

	FWRestRows( aSaveLines )

	RestArea(aAreaNSZ)
	RestArea(aAreaNRO)
	RestArea(aAreaNT4)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100RET
Processa o retorno da execview do JURA095 verificando se ocorreu alguma alteração no dados.
@param oView         View a ser verificado
@param cAcao         1 - Confirmação, 2 - Fechar
@param nAtualiza     Se > 0 indica que o registro será atualizado
@param oView         View a ser verificado

@author Antonio Carlos Ferreira
@since 24/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100RET(oView, cAcao, nAtualiza, lLiminar)
Local oModelATU   := FWModelActive()
Local lAtualizou  := oModelATU:lModify //Indica se o modelo foi atualizado

Default lLiminar := .F.

If nAtualiza == 2
	//Se nAtualiza == 2 indica que já passou por essa função e entrou nas condições
	//necessárias, porém o modelo da JURA095 não validou e ao confirmar novamente
	//ou fechar a JURA095 ele irá passar aqui novamente e precisa ter o valor = 0
	//para indicar valor = 2 somente se entrar nas condições dessa função
	nAtualiza := 0
EndIf

If lLiminar

	If oModelATU:GetModel("NSZMASTER"):HasField("NSZ_CSITUL") .And. ;
	   oModelATU:GetModel("NSZMASTER"):HasField("NSZ_DTINLI") .And. ;
	   oModelATU:GetModel("NSZMASTER"):HasField("NSZ_DTFILI")

		If oModelATU:IsFieldUpdated("NSZMASTER","NSZ_CSITUL") .Or. ;
		   oModelATU:IsFieldUpdated("NSZMASTER","NSZ_DTINLI") .Or. ;
		   oModelATU:IsFieldUpdated("NSZMASTER","NSZ_DTFILI")
			lAtualizou := .T.
		Else
			If cAcao == "1"
				lAtualizou := .F. //Não atualizou os campos necessários
			ElseIf cAcao == "2"
				lAtualizou := .T. //Já foram editados automáticamente os campos de Status e Obs Vigor
			EndIf
		EndIf

	EndIf
Else//Caso não seja liminar, será decisão
	If oModelATU:GetModel("NSZMASTER"):HasField("NSZ_DTCAUS") .And. ;
	   oModelATU:GetModel("NSZMASTER"):HasField("NSZ_CMOCAU") .And. ;
	   oModelATU:GetModel("NSZMASTER"):HasField("NSZ_VLCAUS")

		If oModelATU:IsFieldUpdated("NSZMASTER","NSZ_DTCAUS") .Or. ;
		   oModelATU:IsFieldUpdated("NSZMASTER","NSZ_CMOCAU") .Or. ;
		   oModelATU:IsFieldUpdated("NSZMASTER","NSZ_VLCAUS")
			lAtualizou := .T.
		Else
			If cAcao == "1"
				lAtualizou := .F. //Não atualizou os campos necessários
			ElseIf cAcao == "2"
				lAtualizou := .T.
			EndIf
		EndIf
	EndIf
EndIf

If ((cAcao == "1"/*Confirma*/) .And. lAtualizou)
	nAtualiza := 2  //Alterou e esta tentando salvar.
ElseIf (cAcao == "2"/*Fechar*/) .And. !(lAtualizou)
	nAtualiza := 2  //Esta fechando a tela apos a gravacao.
EndIf

If (nAtualiza == 2) .And. (oModel095 != nil)
	//Copia do Atual para o Anterior passando as alteracoes do usuario em tela.
	J95COPYMOD(@oModelATU, @oModel095, "NSZMASTER", aModel095)
	lIniJ95 := .F. //Caso volte ao processo não precisa inicializar os campos de Liminar.
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100COM
Salvar as informações de andamento e verifica a sugestão de follow-up
@param 	oModel  	Model a ser verificado
@author Juliana Iwayama Velho
@since 31/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100COM(oModel)
Local nOpc       := oModel:GetOperation()
Local aArea      := GetArea()
Local lNZLInDic  := FWAliasInDic("NZL") //Verifica se existe a tabela NZL no Dicionário (Proteção)
Local lRet       := .T.
Local cDtProxEv  := ""


If lNZLInDic .And. (nOpc == 3) .And. (GetMV('MV_JFLUIGAP',,'2') == '1')
	JA100ConfNZL(oModel)
EndIf

	//Seta a data do prox evento
	cDtProxEv := JA100PrEve()
	If !Empty(cDtProxEv)
		oModel:SetValue("NT4MASTER",'NT4_DTPREV', cDtProxEv)
	EndIf

	FWFormCommit(oModel)

	If nOpc == 3

		lRet := JURA100GFw(oModel)

		//Verifica as informacoes de prazo estimativa para calculo do termino do processo.
		JURESTNT4(oModel)

	ElseIf nOpc == 4 .OR. nOpc == 5

		//Recalculo da estimativa de prazo quando for alteração e exclusão
		J100EstRcc(oModel)
	EndIf

	//Gravar os campos de Decisao na instancia vinculada
	If !( Empty(oModel:GetValue("NT4MASTER","NT4_CATO")) ) .And. !( Empty(oModel:GetValue("NT4MASTER","NT4_CINSTA")) )
		If (Posicione("NRO",1,xFilial("NRO")+oModel:GetValue("NT4MASTER","NT4_CATO"),"NRO_TIPO") == '1') //tipo de Ato Processual = Decisao = Andamento tipo sentenca.
			If !( Empty(Posicione("NUQ",5,xFilial("NUQ")+oModel:GetValue("NT4MASTER","NT4_CAJURI")+oModel:GetValue("NT4MASTER","NT4_CINSTA"),"NT4_COD")) )

				If NUQ->( DbRLock(Recno()) )
					NUQ->NUQ_CCLASS := NRO->NRO_CCLASS
					NUQ->NUQ_CDECIS := NRO->NRO_CDECIS
					NUQ->NUQ_DTDECI := oModel:GetValue("NT4MASTER","NT4_DTANDA")

					If Empty(NUQ->NUQ_OBSERV)
						NUQ->NUQ_OBSERV := oModel:GetValue("NT4MASTER","NT4_DESC")
					EndIf

					NUQ->( MsUnLock() )
				EndIf

				//Se o modelo não foi alterado, atualiza as informações da tela.
				If !Empty(oModel095)
					If !oModel095:lModify
						oModel095:DeActivate()
						oModel095:Activate()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//Ordenação do grid de andamentos de forma decrescente
	NT4->(dbSetOrder(6))

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100ConfNZL
Confirma o valor conforme o status do follow-up
Uso no cadastro de Follow-ups.

@param 	oModelNZK  Modelo da NZK
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio C Ferreira
@since 16/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
STATIC Function JA100ConfNZL(oModel)

Local aArea       := GetArea()
Local nA          := 0
Local nB          := 0
Local lRet        := .T.
Local xRet        := ''
Local cStatus     := ''
Local oModelNT4   := oModel:GetModel('NT4MASTER')
Local oModelNZL   := oModel:GetModel('NZLDETAIL')
Local cUsuario    := GetMV('MV_ECMUSER',,'')
Local cSenha      := GetMV('MV_ECMPSW',,'')
Local cEmpresa    := GetMV('MV_ECMEMP',,'0')
Local cMensagem   := ''
Local aValores    := {}
Local aCardData   := {}
Local aSubs       := {}
Local oXml        := nil
Local cRetorno    := ''
Local cErro       := ''
Local cAviso      := ''
Local cTag        := ''

Begin Sequence

  //Retirado o elemento da tag devido o obj nao suportar
    aadd( aSubs, {'"', "'"})
    aadd( aSubs, {" xmlns='http://ws.workflow.ecm.technology.totvs.com/'", ""})
    aadd( aSubs, {"<item />", ""})

    For nA := 1 to oModelNZL:Length()

        If  oModelNZL:isEmpty()
            Exit
        Endif

        oModelNZL:GoLine( nA )

        cStatus := oModelNZL:GetValue('NZL_STATUS')
        If  (cStatus == '1') .Or. oModelNZL:IsDeleted() .Or. Empty(oModelNZL:GetValue('NZL_CODWF'))  //1-Concluido / 2-Pendente
            Loop
        EndIf

        //pega as informações do executor caso tenha que ser movimentado o workflow.
        cSolicitId := JA106GCard(oModelNZL:GetValue('NZL_CODWF'),"sExecutorFluig")

        If  Empty( cSolicitId )
	        cMensagem := STR0046 //"Problema para obter o id do solicitante!"
	        Exit
	    EndIf

//--------------------------------- Obter os dados do formulario ja existente no Fluig --------------------------

        aadd(aValores, {"username"          , cUsuario                        })
        aadd(aValores, {"password"          , cSenha                          })
        aadd(aValores, {"companyId"         , cEmpresa                        })
        aadd(aValores, {"processInstanceId" , oModelNZL:GetValue('NZL_CODWF') })
        aadd(aValores, {"userId"            , cSolicitId                      })

        If  !( JA106TWSDL("ECMWorkflowEngineService", "getInstanceCardData", aValores, aCardData, aSubs, @xRet, @cMensagem) )
            Break
        EndIf

      //Obtem somente a Tag do XML de retorno
        cTag := '</CardData>'
        nB   := At(StrTran(cTag,"/",""),xRet)
        xRet := SubStr(xRet, nB, Len(xRet))
        nB   := At(cTag,xRet) + Len(cTag) - 1
        xRet := Left(xRet, nB)

      //Gera o objeto do Result Tag
        oXml := XmlParser( xRet, "_", @cErro, @cAviso )

        If Empty(oXml) .Or. (ValType(oXml:_CardData:_Item) != 'A')
            cMensagem := JMsgErrFlg(oXML)
            Break
        EndIf

      //Preenche com os dados existentes do formulario Fluig
        For nB := 1 to Len(oXML:_CardData:_Item)
            //Responsável pela execução da tarefa no FLUIG.
            If (AllTrim(oXML:_CardData:_Item[nB]:_Item[1]:Text) == "sExecutorFluig") .And. !( Empty(AllTrim(oXML:_CardData:_Item[nB]:_Item[2]:Text)) )
            	    cSolicitId := AllTrim(oXML:_CardData:_Item[nB]:_Item[2]:Text)
            	    //limpa o valor do responsável
            	    //oXML:_CardData:_Item[nB]:_Item[2]:Text := ""
            Endif

            If  !( Empty(AllTrim(oXML:_CardData:_Item[nB]:_Item[2]:Text)) )
                aAdd(aCardData, {AllTrim(oXML:_CardData:_Item[nB]:_Item[1]:Text), JurEncUTF8(AllTrim(oXML:_CardData:_Item[nB]:_Item[2]:Text)) })  //Campo a ser atualizado no Fluig
            EndIf
        Next nA

//--------------------------------- Gravar os dados novos com os antigos -------------------------------------

        aAdd(aCardData, {AllTrim(oModelNZL:GetValue('NZL_DCAMPO')), JurEncUTF8(AllTrim(oModelNT4:GetValue('NT4_DESC'))) })  //Campo a ser atualizado no Fluig
        aAdd(aCardData, {'sOrigem'                                , 'SIGAJURI'                                          })  //Informa ao Fluig a origem dos dados

        aadd(aValores, {"username"          , cUsuario                        })
        aadd(aValores, {"password"          , cSenha                          })
        aadd(aValores, {"companyId"         , cEmpresa                        })
        aadd(aValores, {"processInstanceId" , oModelNZL:GetValue('NZL_CODWF') })
        aadd(aValores, {"choosedState"      , oModelNZL:GetValue('NZL_CSTEP') })
        aadd(aValores, {"userId"            , cSolicitId                      })
        aadd(aValores, {"completeTask"      , "true"                          })
        aadd(aValores, {"managerMode"       , "false"                         })
        aadd(aValores, {"comments"          , JurEncUTF8(AllTrim(oModelNT4:GetValue("NT4_DESC")))  }) //"WF alterado pelo SIGAJURI"
        aadd(aValores, {"threadSequence"    , "0"                             })

        If  !( JA106TWSDL("ECMWorkflowEngineService", "saveAndSendTaskClassic", aValores, aCardData, aSubs, @xRet, @cMensagem) )
            Break
        EndIf

      //Obtem somente a Tag do XML de retorno
        cTag := '</result>'
        nB   := At(StrTran(cTag,"/",""),xRet)
        xRet := SubStr(xRet, nB, Len(xRet))
        nB   := At(cTag,xRet) + Len(cTag) - 1
        xRet := Left(xRet, nB)

      //Gera o objeto do Result Tag
        oXml := XmlParser( xRet, "_", @cErro, @cAviso )

        If  Empty(oXml) .Or. (ValType(oXml:_Result:_Item) != 'A')
            cMensagem := JMsgErrFlg(oXML)
            Break
        EndIf

        cRetorno := ''

      //Obtem o codigo do WorkFlow gerado no Fluig
        For nB := 1 to Len(oXml:_Result:_Item)
            If  (Upper(oXml:_Result:_Item[nB]:_Key:TEXT) != 'ITASK')
                Loop
            EndIf

            cRetorno := oXml:_Result:_Item[nB]:_Value:TEXT
            Exit
        Next nB

        If  Empty(cRetorno)
            cMensagem := STR0048  //"Status do workflow do Fluig nao retornado!"
            Break
        EndIf

        oModelNZL:SetValue('NZL_STATUS', '1')

    Next nA

End Sequence

If  !( Empty(cMensagem) )
    ConOut('JA100ConfNZL: ' + STR0049 + cMensagem)  //"Erro: "
    lRet := .F.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100MP
Verifica se o ato processual é utilizado pelo Ministério Público
Uso no cadastro de Andamentos.

@param 	cAto  	Código do ato processual
@Return lRet	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 14/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100MP(cAto)
Local lRet      := .F.
Local aArea     := GetArea()
Local aAreaNRO  := NRO->( GetArea() )

If !Empty(cAto)

	NRO->( dbSetOrder( 1 ) )
	If NRO->( dbSeek( xFilial( 'NRO' ) + cAto ) )
		lRet := (NRO->NRO_MINPUB == '1')
	EndIf

EndIf

RestArea(aArea)
RestArea(aAreaNRO)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100JZ
Verifica se o ato processual é utilizado pelo Ministério Público e
do tipo Decisão ou Liminar, para habilitar campos de juiz
Uso no cadastro de Andamentos.

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 14/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100JZ()
Local lRet      := .F.
Local oModel    := FWModelActive()
Local cAto      := oModel:GetValue("NT4MASTER","NT4_CATO")
Local aArea     := GetArea()
Local cTipo     := ''

If !Empty(oModel:GetValue("NT4MASTER","NT4_CAJURI"))

	If (JURA100MP(cAto))

		cTipo := Posicione('NRO', 1 , xFilial('NRO') + cAto, 'NRO_TIPO')
		lRet := cTipo == '1' .Or. cTipo == '2'

	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100WHJZ
Verifica se o campo de juiz deve ser habilitado conforme informações da
instância atual

@param 	cCampo  	Nome do campo
@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 13/08/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100WHJZ(cCampo)
Local lRet      := .F.
Local cInstan   := ''
Local cQuery    := ''
Local cAlias    := GetNextAlias()
Local aArea     := GetArea()

cQuery := "SELECT NUQ_INSTAN INSTANCIA"
cQuery += " FROM "+RetSqlName("NUQ")+" NUQ "
cQuery += " WHERE NUQ_FILIAL = '"+xFilial("NUQ")+"'"
cQuery += "   AND NUQ_INSATU = '1'"
cQuery += "   AND NUQ_CAJURI = '"+FwFldGet("NT4_CAJURI")+"'"
cQuery += "   AND NUQ.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

If !(cAlias)->( EOF() )
	cInstan := (cAlias)->INSTANCIA
EndIf

(cAlias)->( dbcloseArea() )

If !Empty(cInstan)

	Do Case
		Case "NT4_CJZREL" $ cCampo
			lRet := cInstan == '1'
		Case "NT4_CJZREV" $ cCampo
			lRet := cInstan == '2'
		Case "NT4_CJZVOG" $ cCampo
			lRet := cInstan == '3'
	End Case

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100SGDES
Função para sugerir o preenchimento do campo de descrição do andamento
quando a inclusão do mesmo é a partir da inclusão de um follow-up
Uso no cadastro de Andamentos.

@Return cRet	   	Descrição do andamento

@author Juliana Iwayama Velho
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100SGDES()
Local cRet := ''

If IsInCallStack('JURA106COM')

	aVar := JA106GETXV()

	If aVar <> NIL
		If !Empty( aVar[4] ) .And. ( aVar[4] <> '  :  ' .Or. aVar[4] <> '00:00' )

			If !Empty ( AllTrim (aVar[1] ) )
				//sugestão de descricao do andamento a partir do tipo de follow-up / data - hora
				cRet := AllTrim( aVar[5] ) + ' ' + AllTrim( aVar[1] ) + ' ' +  DTOC( aVar[3] ) + ' - ' + aVar[4]
			Else
				//descricao do follow-up / data - hora
				cRet := AllTrim( aVar[5] ) + ' ' + DTOC( aVar[3] ) + ' - ' + aVar[4]
			EndIf

		Else

			If !Empty ( AllTrim( aVar[1] ) )
				//sugestão de descricao do andamento a partir do tipo de follow-up / data
				cRet := AllTrim( aVar[5] ) + ' ' + AllTrim( aVar[1] ) + ' ' +  DTOC( aVar[3] )
			Else
				//descricao do follow-up / data
				cRet := AllTrim( aVar[5] ) + ' ' + DTOC( aVar[3] )
			EndIf

		EndIf
	EndIf

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100SGATO
Função para sugerir o preenchimento do campo de ato processual
quando a inclusão do andamento é a partir da inclusão de um follow-up
Uso no cadastro de Andamentos.

@Return cRet	   	Código do ato processual

@author Juliana Iwayama Velho
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100SGATO()
Local cRet:= ''

If IsInCallStack('JURA106COM')

	aVar := JA106GETXV()

	If aVar <> NIL
		cRet := aVar[2]
	EndIf

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100SGFAS
Função para sugerir o preenchimento do campo de fase
quando a inclusão do andamento é a partir da inclusão de um follow-up
Uso no cadastro de Andamentos.

@Return cRet	   	Código da Fase

@author Andre Lago
@since 29/07/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100SGFAS()
Local cRet:= ''

If IsInCallStack('JURA106COM')

	aVar := JA106GETXV()

	If aVar <> NIL
		cRet := aVar[8]
	EndIf

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100CAJUR
Verifica o preenchimento do campo de código de assunto jurídico
Uso no cadastro de Andamentos.

@Return cRet	 	Código do assunto jurídico

@author Juliana Iwayama Velho
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100CAJUR()
Local cRet := ''
Local aVar := {}

If IsInCallStack('JURA106COM')
	aVar := JA106GETXV()
	If aVar <> NIL
		cRet:= aVar[6]
	EndIf
ElseIf IsInCallStack('JURA162') .And. !Empty(M->NSZ_COD)
	cRet := M->NSZ_COD
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J100HABCAJ
Verifica se a tela de andamento não está sendo chamada a partir de Assunto Jurídico
nem Follow-up e se a operação é de inclusão, para habilitar o campo de
Código de Assunto Jurídico para preenchimento pelo usuário

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function J100HABCAJ()
Local lRet  := .T.

If IsInCallStack( 'JURA106COM' ) .And. !Empty(M->NT4_CAJURI) .And. INCLUI
	lRet := .F.
ElseiF (IsInCallStack('JURA162') .And. !INCLUI) .Or. !Empty(M->NSZ_COD)
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100QYNQH
Monta a query de juizes para trazer conforme a instância atual do
processo

@param  cAssJur	 	Código do assunto jurídico
@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 27/04/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100QYNQH(cAssJur)
Local cQuery   := ""

If !Empty(cAssJur)

	cQuery += "SELECT DISTINCT NQH_COD, NQH_NOME, NQH.R_E_C_N_O_ NQHRECNO "
	cQuery += " FROM "+RetSqlName("NQH")+" NQH, "+RetSqlName("NTD")+" NTD, "+RetSqlName("NUQ")+" NUQ "
	cQuery += " WHERE NUQ.D_E_L_E_T_ = ' '"
	cQuery += "   AND NQH.D_E_L_E_T_ = ' '"
	cQuery += "   AND NTD.D_E_L_E_T_ = ' '"
	cQuery += "   AND NUQ_FILIAL = '"+xFilial("NUQ")+"'"
	cQuery += "   AND NQH_FILIAL = '"+xFilial("NQH")+"'"
	cQuery += "   AND NTD_FILIAL = '"+xFilial("NTD")+"'"
	cQuery += "   AND NUQ_INSATU = '1'"
	cQuery += "   AND NUQ_CAJURI = '"+cAssJur+"'"
	cQuery += "   AND NQH_COD    = NTD_CODJUI"
	cQuery += "   AND NQH_TIPO   = NUQ_INSTAN"
	cQuery += "   AND NTD_CCOMAR = NUQ_CCOMAR"
	cQuery += "   AND NTD_CFORO  = NUQ_CLOC2N"
	cQuery += "   AND NTD_CVARA  = NUQ_CLOC3N"

Else

	cQuery += "SELECT DISTINCT NQH_COD, NQH_NOME, NQH.R_E_C_N_O_ NQHRECNO "
	cQuery += " FROM "+RetSqlName("NQH")+" NQH "
	cQuery += " WHERE NQH.D_E_L_E_T_ = ' '"
	cQuery += "   AND NQH_FILIAL = '"+xFilial("NQH")+"'"

EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100F3NQH
Customiza a consulta padrão de juiz conforme a instância atual

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 27/04/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100F3NQH(lInclui)
Local lRet   := .F.
Local aArea  := GetArea()
Local cQuery := ''
Local oModel
Local aPesq  := {"NQH_COD","NQH_NOME"}
Local nResult := 0

Default lInclui := .T.

	If isPesquisa()
		cQuery := JA100QYNQH('')
	Else
		If JURA100JZ()
			oModel := FWModelActive()
			cQuery := JA100QYNQH(FWFldGet('NT4_CAJURI'))
		EndIf
	EndIf

	If Len(ALLTRIM(cQuery)) > 0
		cQuery := ChangeQuery(cQuery, .F.)
		RestArea( aArea )

		nResult := JurF3SXB("NQH", aPesq,, .F., lInclui,, cQuery)
		lRet := nResult > 0

		If lRet
			DbSelectArea("NQH")
			NQH->(dbgoTo(nResult))
		EndIf
	Else
	 	lRet   := .F.
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100VLNQH
Verifica se o valor do campo de juiz é válido

@Return cCampo	    Campo de juiz a ser validado
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 27/04/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100VLNQH(cCampo)
Local lRet     := .F.
Local aArea    := GetArea()
Local oModel   := FWModelActive()
Local cQuery   := JA100QYNQH(oModel:GetValue('NT4MASTER','NT4_CAJURI'))
Local cAlias   := GetNextAlias()

If JURA100JZ()

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	(cAlias)->( dbSelectArea( cAlias ) )
	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )
		If (cAlias)->NQH_COD == oModel:GetValue('NT4MASTER',cCampo)
			lRet := .T.
			Exit
		EndIf
		(cAlias)->( dbSkip() )
	End

	If !lRet
		JurMsgErro(STR0013)
	EndIf

	(cAlias)->( dbcloseArea() )

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RelatAnd()
Modelo de dados de Andamentos

@author Clóvis Eduardo Teixeira
@since 24/06/10
@version 1.0

/*/
//-------------------------------------------------------------------
Function RelatAnd(cCodJur, cFilAnt)

// SuperGetMV("MV_JHBPESA",, 1) == '2'
// “Habilita a tela de pesquisa de andamentos"
// Solicitacao do relatorio diretamente pela JURA100
Default cCodJur := NT4->NT4_CAJURI
Default cFilAnt := NT4->NT4_FILIAL

If Existblock( 'JURR100' )
	U_JURR100(cCodJur) //Chamada da função que define as regras do relatório e faz a impressão usando a ferramenta TMSPrinter
Else
	JURR100(cCodJur) //Chamada da função que define as regras do relatório e faz a impressão usando a ferramenta TMSPrinter
EndIf
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} JA100SetCa
Guarda o valor do código do andamento inserido pela sugestão de follow-up
Uso Follow-up.

@Param xConteudo	 	Código do andamento

@author Juliana Iwayama Velho
@since 05/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100SetCa( xConteudo )
	xVarCodAnd := xConteudo
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100GetCa
Retorna o valor guardado na variável
Uso Geral.

@Return xVarCodAnd	 	Código do andamento

@author Juliana Iwayama Velho
@since 05/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100GetCa()
Return xVarCodAnd

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100VincF
Verifica o vínculo de follow-up ao andamento

@param 	cCodFw  	Código do follow-up
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 22/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100VincF(nVez,cCod,cCodPai,dData,cAto)
Local lRet      := .T.
Local dDtFw     := ctod('')
Local cHrsFw    := ''
Local cTipoFw   := ''
Local cDesTipo  := ''
Local cCodFw    := ''
Local dDtAnd    := ctod('')
Local cCodAto   := ''
Local cDesAto   := ''
Local lMsg      := .T.
Local cCodProx  := ''
Local lApaga    := .F.

Default dData    := ctod('')
Default cAto     := ''

If !Empty(cCod)
	cCodFw := Posicione('NTA', 5 , xFilial('NTA') + cCod, 'NTA_COD')
EndIf

If nVez = 2
    cCodFw := Posicione('NT4', 1 , xFilial('NT4') + cCod, 'NT4_CFWLP')
	If Empty(cCodFw)
		cCodFw := cCodPai
	EndIf
ElseIf cCodFw == JA106GetCf()
	cCodFw := ''
EndIf

If !Empty(cCodFw)
	DbSelectArea("NTA")
	NTA->( dbSetOrder( 1 ) )
	If NTA->( dbSeek( xFilial( 'NTA' ) + cCodFw ) )
		dDtFw    := Posicione('NTA', 1 , xFilial('NTA') + cCodFw, 'NTA_DTFLWP'        )
		cHrsFw   := Posicione('NTA', 1 , xFilial('NTA') + cCodFw, 'NTA_HORA'          )
		cTipoFw  := Posicione('NTA', 1 , xFilial('NTA') + cCodFw, 'NTA_CTIPO'         )
		cDesTipo := AllTrim(Posicione('NQS', 1 , xFilial('NQS') + cTipoFw, 'NQS_DESC'))

		If Empty(cCod)
			cCod := Posicione('NT4', 5 , xFilial('NT4') + cCodFw, 'NT4_COD')
		EndIf

		dDtAnd:= Posicione('NT4', 1 , xFilial('NT4') + cCod, 'NT4_DTANDA')
		If Empty(dDtAnd)
			dDtAnd := dData
		EndIf

		cCodAto:= Posicione('NT4', 1 , xFilial('NT4') + cCod, 'NT4_CATO')
		If Empty(cCodAto)
			cCodAto:= cAto
		EndIf

		cDesAto:= AllTrim(Posicione('NRO', 1 , xFilial('NRO') + cCodAto, 'NRO_DESC'))

		If lMsg
			If !Empty(NTA->NTA_CANDAM)
				cCodProx:= NTA->NTA_CANDAM
			Else
				cCodProx := cCod
			EndIf

			If nVez == 1
				If Empty(Posicione('NT4', 5 , xFilial('NT4') + cCodFw, 'NT4_COD'))
					lApaga  := .T.
				EndIf
			Else
				If Empty(Posicione('NTA', 5 , xFilial('NTA') + cCodProx,'NTA_COD'))
					lApaga  := .T.
				EndIf
			EndIf

			If !(JA106EXCL(cCodFw))

				If nVez == 1
					If Empty(Posicione('NT4', 5 , xFilial('NT4') + cCodFw, 'NT4_COD'))
						lApaga  := .T.
					EndIf
				Else
					If Empty(Posicione('NTA', 5 , xFilial('NTA') + cCodProx,'NTA_COD'))
						lApaga  := .T.
					EndIf

					If cCod == JA100GetCa() .And. !Empty(NT4->NT4_CFWLP)
						Reclock( 'NT4', .F. )
						NT4->NT4_CFWLP := ''
						MsUnlock()
					EndIf

				EndIf
				If !Empty(cCodFw)
					DbSelectArea("NTA")
					NTA->( dbSetOrder( 1 ) )
					If NTA->( dbSeek( xFilial( 'NTA' ) + cCodFw ) )
						Reclock( 'NTA', .F. )
						NTA->NTA_CANDAM := ''
						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet
			If lApaga
				cCodAnd := ''
				cCodProx:= ''
			EndIf

			If cCodProx == JA100GetCa()
				cCodProx := ''
			EndIf
			lRet := JA106VincA(nVez,cCodFw,cCodProx,dDtFw,cHrsFw,cTipoFw)
		EndIf
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JA100SGPRE
Função para sugerir o preenchimento dos campos do andamento
quando a inclusão do mesmo é feita a partir de inclusao de outra rotina.
Uso no X3_RELACAO cadastro de Andamentos.

@Return cRet	   	Descrição do andamento

@author Rafael Tenorio da Costa
@since 26/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100SGPRE( cCampo )

Local xRetorno	:= ''

	If cCampo == "NT4_AUTPGO"

		//Default do campo
		xRetorno := ''

		//Verifica se foi chamado do follow-up
		If IsInCallStack('JURA106COM')
			xRetorno := JA106GETAP()
		EndIf
	EndIf

Return xRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} JA100PrEve
Função para sugerir preenchimendo do campo de data do próximo evento
quando a inclusão do andamento é a partir da inclusão de um follow-up.

Esse campo será usado quando o ato indicado no follow-up que gerou o
andamento é de prazo fixo. Essa data será gravada no andamento
para ser repassada para o follow-up que será gerado através do
andamento.

Uso no cadastro de Andamentos.

@Return cRet	   	Data do Próximo Evento

@author Jorge Luis Branco Martins Junior
@since 07/07/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100PrEve()
Local cRet   := ''
Local aVar   := Nil

	If IsInCallStack('JURA106COM')

		aVar := JA106GETXV()
		
		If aVar <> NIL
			cRet := aVar[7]
		EndIf

	EndIf

Return cRet

//------------------------------------------------------------------
/*/{Protheus.doc} Ja100NTAFil
Filtro da consulta padrão do codigo de follow-up NT4_CFWLP.

@return cFiltro - Retorna o filtro
@author Rafael Tenorio da Costa
@since 13/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja100NTAFil()

	Local aArea		:= GetArea()
	Local cFiltro	:= "@#"
	Local oModel    := FWModelActive()
	Local cCajuri	:= ""
	Local cTabela	:= ""
	Local cQuery	:= ""
	Local cFollows	:= ""

	If oModel <> Nil .And. oModel:IsActive() .And. oModel:GetId() == "JURA100"

		cCajuri := oModel:GetValue("NT4MASTER", "NT4_CAJURI")
		cFiltro	+= "NTA->NTA_CAJURI == '" +cCajuri+ "' .And. !Empty(NTA->NTA_CCORRE) .And. NTA->NTA_ACEITO == '1'"
		cTabela	:= GetNextAlias()

		//Busca apenas os follow-up concluidos que já não tenham sido utilizados pelos andamentos
		cQuery	:= " SELECT NTA_COD " + CRLF
		cQuery	+= " FROM " +RetSqlName("NTA")+ " NTA INNER JOIN " +RetSqlName("NQN")+ " NQN " + CRLF
		cQuery	+= "  ON NQN_FILIAL = '" +xFilial("NQN")+ "' AND NTA_CRESUL = NQN_COD " + CRLF
		cQuery	+= " WHERE	  NTA_FILIAL = '" +xFilial("NTA")+ "' " + CRLF
		cQuery	+= 		" AND NTA_CAJURI = '" +cCajuri+ "' " + CRLF
		cQuery	+= 		" AND NTA_CCORRE <> ' ' " + CRLF
		cQuery	+= 		" AND NQN_TIPO = '2' " + CRLF		//Concluido
		cQuery	+= 		" AND NTA_COD NOT IN ( SELECT NT4_CFWLP FROM " +RetSqlName("NT4")+ " NT4 " + CRLF
		cQuery	+= 							 " WHERE  NT4_FILIAL = '" +xFilial("NT4")+ "' " + CRLF
		cQuery	+= 							 	" AND NT4_CAJURI = '" +cCajuri+ "' " + CRLF
		cQuery	+= 							 	" AND NT4.D_E_L_E_T_ = ' ' ) " + CRLF
		cQuery	+= 		" AND NTA.D_E_L_E_T_ = ' ' " + CRLF
		cQuery	+= 		" AND NQN.D_E_L_E_T_ = ' ' "

		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)

		If !(cTabela)->( Eof() )

			While !(cTabela)->( Eof() )

				cFollows += (cTabela)->NTA_COD + "|"

				(cTabela)->( DbSkip() )
			EndDo

			If !Empty( cFollows )
				cFiltro	+= " .And. NTA->NTA_COD $ '" +cFollows+ "'"
			EndIf

		Else
			//Nao existe follow-up concluido que nao foram utilizados por outros andamentos
			cFiltro	+= " .And. Empty(NTA->NTA_COD)"
		EndIf
		(cTabela)->( DbCloseArea() )

	EndIf

	cFiltro += "@#"
	RestArea( aArea )

Return cFiltro

//------------------------------------------------------------------
/*/{Protheus.doc} Ja100NTAVld
Valida o codigo do follow-up digitado no campo NT4_CFWLP.

@return lRetorno - Codigo valido
@author Rafael Tenorio da Costa
@since 13/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja100NTAVld( cFollow )

	Local aArea 	:= GetArea()
	Local aAreaNTA 	:= NTA->( GetArea() )
	Local aAreaNT4 	:= NT4->( GetArea() )
	Local lRetorno 	:= .T.

	If !Empty(cFollow)

		NTA->( DbSetOrder(1) )	//NTA_FILIAL+NTA_COD
		If NTA->( DbSeek(xFilial("NTA") + cFollow) )

			//Valida se o follow-up pertence ao assunto juridico
			If lRetorno .And. NTA->NTA_CAJURI <> FwFldGet("NT4_CAJURI")
				lRetorno := .F.
			EndIf

			//Valida se o resultado do follow-up foi concluido
			If lRetorno .And. JurGetDados("NQN", 1, xFilial("NQN") + NTA->NTA_CRESUL, "NQN_TIPO") <> "2"
				lRetorno := .F.
			EndIf

			//Valida se o follow-up tem correspondente
			If  lRetorno .And. Empty(NTA->NTA_CCORRE)
				lRetorno := .F.
			EndIf

			//Valida se o correspondente aceitou a atividade
			If  lRetorno .And. NTA->NTA_ACEITO <> "1"
				lRetorno := .F.
			EndIf
		Else

			lRetorno := .F.
		EndIf

		If lRetorno

			//Verifica se o follow-up ja esta sendo utilizado
			NT4->( DbSetOrder(5) )	//NT4_FILIAL+NT4_CFWLP
			If NT4->( DbSeek(xFilial("NT4") + cFollow) )
				lRetorno := .F.
			EndIf
		EndIf

		If !lRetorno
			JurMsgErro(STR0044)	//"Código de follow-up inválido."
		EndIf
	EndIf

	RestArea( aAreaNT4 )
	RestArea( aAreaNTA )
	RestArea( aArea )

Return lRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} Ja100NTAWhe
Define se o campo NT4_CFWLP será editavel.
Uso NZ3_WHEN

@return lRetorno - Codigo valido
@author Rafael Tenorio da Costa
@since 13/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja100NTAWhe()

	Local lRetorno := .F.

	If !IsInCallStack("JA106IncAn") .And. SuperGetMv("MV_JFLXCOR",,1) == 1
		lRetorno := .T.
	EndIf

Return lRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} JA100UlFas
Retorna ultima fase processual relacionada ao Ato, ordenada por data decrescente.

@param   cAssunto  - Codigo do assunto juridico
@return  cDescFase - Descrição da fase processual
@author  Rafael Tenorio da Costa
@since 	 05/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA100UlFas(cAssunto)

	Local cQuery    := ""
	Local cDescFase := ""
	Local aRetorno	:= {}

	Default cAssunto := ""

	cQuery += " SELECT NRO_DFASE"
	cQuery += " FROM " + RetSqlName("NT4") + " NT4 LEFT JOIN " + RetSqlName("NRO") + " NRO"
	cQuery += " ON NT4_CATO = NRO_COD"
	cQuery += " WHERE NT4_FILIAL = '" + xFilial("NT4") + "'"
	cQuery += " AND NRO_FILIAL = '" + xFilial("NRO") + "'"
	cQuery += " AND NT4_CAJURI = '" + cAssunto + "'"
	cQuery += " AND NT4.D_E_L_E_T_ = ' '"
	cQuery += " AND NRO.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY NT4_DTANDA DESC, NT4_COD DESC"

	aRetorno := JurSql(cQuery, {"NRO_DFASE"})

	If Len(aRetorno) > 0
		cDescFase := AllTrim(aRetorno[1][1])
	EndIf

Return cDescFase

//------------------------------------------------------------------
/*/{Protheus.doc} JURNQLNT4
Consulta padrão de Especialista (perito e assistente)

@return lResult - Indica se foi indicado algum código
@author Jorge Luis Branco Martins Junior
@since 02/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNQLNT4()
Local cSQL       := ""
Local cTab       := "NQL"
Local aCampos    := {{"NQL","NQL_COD"}, {"NQL","NQL_NOME"}, {"NQB","NQB_DESC"}}
Local lVisualiza := .F.
Local lInclui    := .F.
Local cFonte     := "JURA015"
Local nResult    := 0
Local lResult    := .F.

cSQL := " SELECT NQL.NQL_COD, NQL.NQL_NOME, COALESCE(NQB.NQB_DESC,'') NQB_DESC, NQL.R_E_C_N_O_ recno "
cSQL +=   " FROM " + RetSqlName("NQL") + " NQL "
cSQL += " LEFT JOIN " + RetSqlName("NQB") + " NQB ON ( "
cSQL +=     " NQB.NQB_COD = NQL.NQL_CESPEC AND "
cSQL +=     " NQB_FILIAL = '" + xFilial("NQB") + "' AND "
cSQL +=     " NQB.D_E_L_E_T_ = ' ' ) "
cSQL += " WHERE "
cSQL +=     " NQL.NQL_FILIAL = '" + xFilial("NQL") + "' AND "
cSQL +=     " NQL.D_E_L_E_T_ = ' ' "

nResult := JurF3SXB(cTab, aCampos, "", lVisualiza, lInclui, cFonte, cSQL)
lResult := nResult > 0

If lResult
	DbSelectArea(cTab)
	&(cTab)->(dbgoTo(nResult))
EndIf

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA100DPD
Valida se o tipo de ato processual está configurado para sugerir a descrição
Uso no cadastro de Andamento (gatilho no campo de Ato).

@param 	cTipo  		Tipo a ser verificado
@Return cDescPad	Descrição padrão

@author Andreia Lima
@since 08/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA100DPD(cTipo)
Local cDescPad := ""
Local oModel   := FWModelActive()
Local nOpc     := oModel:GetOperation()
Local aArea    := GetArea()

cDescPad := oModel:GetValue('NT4MASTER','NT4_DESC')

If nOpc == 3

	If Posicione('NRO', 1 , xFilial('NRO') + cTipo , 'NRO_SUGDES') == '1'
		cDescPad := Posicione('NRO', 1 , xFilial('NRO') + cTipo , 'NRO_DESPAD')
	EndIf

EndIf

RestArea( aArea )

Return cDescPad

//------------------------------------------------------------------
/*/{Protheus.doc} JURESTNT4
Verifica as informacoes de prazo estimativa para calculo do termino do processo.

@return lResult - Indica se foi indicado algum código
@author leandro.silva
@since 17/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURESTNT4(oModel)

	Local cQuery   := ""
	Local aRetorno := {}
	Local aDados   := {}
	Local aArea    := GetArea()
	Local dData	   := CtoD("")

	//Verifica se exite a tabela de prazo estimativa
	If FwAliasInDic("O0D")

		aDados := JurGetDados("NSZ", 1, xFilial("NSZ") + oModel:GetValue("NT4MASTER", "NT4_CAJURI"), {"NSZ_TIPOAS","NSZ_CAREAJ","NSZ_COBJET","NSZ_ESTTER"})
		If Len(aDados) == 4
			cQuery := " SELECT "

			cQuery += " 	O0D_PRAZO, O0D_DTDIST, "
			cQuery += " 	(CASE WHEN O0D_TIPOAS	= ' ' THEN 0 ELSE 1 END) + "
			cQuery += " 	(CASE WHEN O0D_CAREAJ	= ' ' THEN 0 ELSE 1 END) + "
			cQuery += " 	(CASE WHEN O0D_COBJET	= ' ' THEN 0 ELSE 1 END) ORDEM "
			cQuery += " FROM " +RetSqlName("O0D")
			cQuery += " WHERE	O0D_FILIAL  = '" +xFilial("O0D")+ "' "
			cQuery += " 	AND O0D_CATO	= '" +oModel:GetValue("NT4MASTER","NT4_CATO")+ "' "
			cQuery += " 	AND (O0D_TIPOAS IN('   ','" +aDados[1]+ "'))"
			cQuery += " 	AND (O0D_CAREAJ	IN('     ','" +aDados[2]+ "'))"
			cQuery += " 	AND	(O0D_COBJET IN('   ','" +aDados[3]+ "'))"
			cQuery += " 	AND D_E_L_E_T_ 	= ' ' "

			cQuery += " ORDER BY ORDEM DESC"

			aRetorno := JurSql(cQuery, {"O0D_PRAZO", "O0D_DTDIST"})

			If Len(aRetorno) > 0

				//Verifica data utilizada para calculo do prazo
				If aRetorno[1][2] == "1"    	// 1 - Data andamento
					dData := oModel:GetValue("NT4MASTER","NT4_DTANDA")
				Else							// 2 - Data distribuição
					if !EMPTY(oModel:GetValue("NT4MASTER","NT4_CINSTA"))
						dData := JurGetDados("NUQ",5,xFilial("NUQ")+oModel:GetValue("NT4MASTER","NT4_CAJURI")+oModel:GetValue("NT4MASTER","NT4_CINSTA"),"NUQ_DTDIST")		//NUQ_FILIAL+NUQ_CAJURI+NUQ_CINSTA
					Else
						dData := JurGetDados("NUQ",2,xFilial("NUQ")+oModel:GetValue("NT4MASTER","NT4_CAJURI")+"1","NUQ_DTDIST")		//NUQ_FILIAL+NUQ_CAJURI+NUQ_INSATU
					EndIf
				EndIf

				dData := MsSomaMes(dData, aRetorno[1][1],.T.)

				If Empty(aDados[4]) .OR. aDados[4] > dData

					DbSelectArea("NSZ")
					NSZ->(DbSetOrder(1))
					If NSZ->(dbSeek(xFilial('NSZ')+oModel:GetValue("NT4MASTER","NT4_CAJURI")))
						Reclock( "NSZ", .F. )
							NSZ->NSZ_ESTTER := dData					//Data de estimativa de termino no encerramento
							If NSZ->( ColumnPos("NSZ_TRITER") ) > 0
								NSZ->NSZ_TRITER := RetTriAno(dData)		//Trimestre de estimativa de termino no encerramento
							EndIf
						NSZ->(MsUnLock())
					EndIf

					If oModel095 != nil .And. oModel095:GetId() == "JURA095"
						If oModel095:GetModel("NSZMASTER"):HasField("NSZ_ESTTER")
							oModel095:LoadValue("NSZMASTER", "NSZ_ESTTER", NSZ->NSZ_ESTTER)
						EndIf
						If oModel095:GetModel("NSZMASTER"):HasField("NSZ_TRITER")
							oModel095:LoadValue("NSZMASTER", "NSZ_TRITER", NSZ->NSZ_TRITER)
						EndIf
					Endif

				EndIf

			EndIf
		EndIf
		
	EndIf

	RestArea(aArea)

Return NIL

//------------------------------------------------------------------
/*/{Protheus.doc} J100EstRcc
Recalculo da estimativa de prazo quando for alteração e exclusão

@author Willian.Kazahaya
@since 26/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J100EstRcc(oModel)

	Local cQuery     := ""
	Local aRetorno   := {}
	Local aDados     := {}
	Local aArea      := GetArea()
	Local dData	     := CtoD('')
	Local cTrimestre := ''

	//Verifica se exite a tabela de prazo estimativa
	If FwAliasInDic("O0D")

		aDados := JurGetDados("NSZ", 1, xFilial("NSZ") + oModel:GetValue("NT4MASTER", "NT4_CAJURI"), {"NSZ_COD","NSZ_TIPOAS","NSZ_CAREAJ","NSZ_COBJET","NSZ_ESTTER"})

		cQuery += " SELECT O0D.O0D_PRAZO, "
		cQuery +=        " O0D.O0D_DTDIST, "
		cQuery +=  		 " NT4.NT4_DTANDA, "
		cQuery +=        " NT4.NT4_CINSTA, "
		cQuery +=        " (CASE WHEN O0D_TIPOAS	= ' ' THEN 0 ELSE 1 END) + "
		cQuery +=  		 " (CASE WHEN O0D_CAREAJ	= ' ' THEN 0 ELSE 1 END) + "
		cQuery +=  		 " (CASE WHEN O0D_COBJET	= ' ' THEN 0 ELSE 1 END) ORDEM "
		cQuery += " FROM "+ RetSqlName("NT4") + " NT4 INNER JOIN "+ RetSqlName("O0D") + " O0D ON (O0D.O0D_CATO = NT4.NT4_CATO)"
		cQuery += 																		   " AND (O0D_TIPOAS IN('   ','" +aDados[2]+ "')) "
		cQuery += 																		   " AND (O0D_CAREAJ IN('     ','" +aDados[3]+ "')) "
		cQuery += 																		   " AND (O0D_COBJET IN('   ','" +aDados[4]+ "')) "
		cQuery += 																		   " AND (O0D.D_E_L_E_T_ 	= ' ') "
		cQuery += " WHERE NT4.NT4_CAJURI = '" + aDados[1] + "'"
		cQuery += "  AND NT4.D_E_L_E_T_ = ''"
		cQuery += " ORDER BY O0D.O0D_PRAZO"
		cQuery += "       , ORDEM DESC"

		aRetorno := JurSql(cQuery, {"O0D_PRAZO", "O0D_DTDIST", "NT4_DTANDA", "NT4_CINSTA"})

		If Len(aRetorno) > 0

			//Verifica data utilizada para calculo do prazo
			If aRetorno[1][2] == "1"    	// 1 - Data andamento
				dData := aRetorno[1][3]
			Else							// 2 - Data distribuição
				if !EMPTY(aRetorno[1][4])
					dData := JurGetDados("NUQ",5,xFilial("NUQ")+aDados[1]+aRetorno[1][4],"NUQ_DTDIST") //NUQ_FILIAL+NUQ_CAJURI+NUQ_CINSTA
				Else
					dData := JurGetDados("NUQ",2,xFilial("NUQ")+aDados[1]+"1","NUQ_DTDIST")		       //NUQ_FILIAL+NUQ_CAJURI+NUQ_INSATU
				EndIf
			EndIf

			dData := MsSomaMes(dData, aRetorno[1][1],.T.)

			If Empty(aDados[5]) .OR. aDados[5] > dData
				cTrimestre := RetTriAno(dData)
			ElseIf !Empty(aDados[5])
				cTrimestre := RetTriAno(aDados[5])
			EndIf

			// Inclui o valor do trimestre
			If !Empty(cTrimestre)
				DbSelectArea("NSZ")
				NSZ->(DbSetOrder(1))
				If NSZ->(dbSeek(xFilial('NSZ')+aDados[1]))
					Reclock( "NSZ", .F. )
						NSZ->NSZ_ESTTER := dData					//Data de estimativa de termino no encerramento
						If NSZ->( ColumnPos("NSZ_TRITER") ) > 0
							NSZ->NSZ_TRITER := RetTriAno(dData)		//Trimestre de estimativa de termino no encerramento
						EndIf
					NSZ->(MsUnLock())
				EndIf
			EndIf
		Else
			DbSelectArea("NSZ")
			NSZ->(DbSetOrder(1))
			If NSZ->(dbSeek(xFilial('NSZ')+aDados[1]))
				Reclock( "NSZ", .F. )
					NSZ->NSZ_ESTTER := CToD(" ")
					If NSZ->( ColumnPos("NSZ_TRITER") ) > 0
						NSZ->NSZ_TRITER := ""
					EndIf
				NSZ->(MsUnLock())
			EndIf

		EndIf

		If oModel095 != nil .And. oModel095:GetId() == "JURA095"
			If oModel095:GetModel("NSZMASTER"):HasField("NSZ_ESTTER")
				oModel095:LoadValue("NSZMASTER", "NSZ_ESTTER", NSZ->NSZ_ESTTER)
			EndIf
			If oModel095:GetModel("NSZMASTER"):HasField("NSZ_TRITER")
				oModel095:LoadValue("NSZMASTER", "NSZ_TRITER", NSZ->NSZ_TRITER)
			EndIf
		Endif
	EndIf

	RestArea(aArea)

Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} VldLimSen()
Validações da Liminar e Sentença

@author  Rafael Tenorio da Costa
@since 	 26/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldLimSen(oModel)
Local lRet       := .T.
Local cTipoAto   := ""
Local cStsAto    := ""
Local nAtualiza  := 0    //1=Alterou o processo e esta tentando salvar / 2=esta fechando a tela apos ter gravado dos dados.
Local lAtualizar := .F.  //Define se atualiza os valores do processo
Local lJustifica := .F.
Local cMensJust  := ""
Local aShow      := { {.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar"},{.T.,"Fechar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil} }
Local aSaveLines := FWSaveRows()
Local oModelOld  := oModel
Local lSentenca  := ( AllTrim( SuperGetMV("MV_JTVRSEN", , "1") ) == "1" )	//O sistema exibe a mensagem de confirmação para atualização de valores ao cadastrar um Andamento com Sentença? 1=Sim; 2= Não.
Local lMultiLim  := SuperGetMv("MV_JMULLIM", , .F.)							//Define se esta ativa a rotina de multi liminares
Local cFilAnd    := xFilial("NT4")
Local cCajuri    := oModel:GetValue("NT4MASTER", "NT4_CAJURI")
Local dDataAnd   := oModel:GetValue("NT4MASTER", "NT4_DTANDA")
Local cDescricao := oModel:GetValue("NT4MASTER", "NT4_DESC")
Local aAux       := {}
Local oModel260  := Nil
Local nRet       := 0
Local oModelNUV  := Nil
Local lWSTLegal  := JModRst()

Private cTipoAsJ := ""

	If lRet .And. !Empty(cCajuri)

		//Obtem o tipo de assunto juridico pai
		cTipoAsJ  := J162PaiAJur( JurGetDados("NSZ", 1, xFilial("NSZ") + cCajuri, "NSZ_TIPOAS") )

		//Obtém dados do Ato
		aAux := JurGetDados("NRO", 1, xFilial("NRO") + oModel:GetValue("NT4MASTER", "NT4_CATO"), {"NRO_TIPO", "NRO_CSTATL"})
		If Len(aAux) > 0
			cTipoAto  := aAux[1]	//Tipo do Ato
			cStsAto   := aAux[2]	//Status da Liminar
		EndIf

	    //Tipo do ato 1=Decisao - Andamento tipo sentenca.
		If cTipoAto == '1' .And. lSentenca

			Do Case
				// Tombamento Automático
				Case  IsInCallStack( 'TombAutom' )
					lAtualizar := .F.

				//Contencioso / Criminal / Administrativo / CADE
				Case cTipoAsJ $ '001|002|003|004'
					lAtualizar := .T.

					If Empty(oModel:GetValue("NT4MASTER","NT4_CINSTA")) .And. !IsInCallStack('JURA020')
						JurMsgErro(STR0027)		//"Campo Código Instância deve ser preenchido quando o andamento for uma sentença!"
						lRet := .F.
					EndIf

				//Contrato
				Case cTipoAsJ == '006'
					lAtualizar := .F.

					If  lRet .And. Empty(oModel:GetValue("NT4MASTER","NT4_CADITI"))
						JurMsgErro(STR0028)		//"Campo Código Aditivo deve ser preenchido quando o andamento for uma sentença!"
						lRet := .F.
					EndIf

				//Societario
				Case cTipoAsJ == '008'
					lAtualizar := .F.

					If  lRet .And. Empty(oModel:GetValue("NT4MASTER", "NT4_CUNIDA")) .And. Empty(oModel:GetValue("NT4MASTER", "NT4_CCONCE"))
						JurMsgErro(STR0029)		//"Um dos campos deve ser preenchido quando o andamento for uma sentença: Código Unidade ou Código Concessão!"
						lRet := .F.
					EndIf

					If  lRet .And. !Empty(oModel:GetValue("NT4MASTER", "NT4_CUNIDA")) .And. !Empty(oModel:GetValue("NT4MASTER", "NT4_CCONCE"))
						JurMsgErro(STR0030)		//"Não permitido o preenchimento de ambos os campos juntos: Código Unidade e Código Concessão, quando o andamento for uma sentença!"
						lRet := .F.
					EndIf

			End Case

			//Atualiza valores
			If lRet .And. lAtualizar

				If oModel:GetValue("NT4MASTER","NT4_IMPXML") == "1"			.Or.;	//Caso tenha sido importado
				   oModel:GetModel("NT4MASTER"):IsFieldUpdated("NT4_CATO")	.Or.;	//Caso o código do ato tenha sido alterado
				   oModel:GetModel("NT4MASTER"):IsFieldUpdated("NT4_CINSTA")	 	//Caso o código da instância tenha sido alterado

					If !lWSTLegal
						//"Deseja atualizar os valores da sentença?"
						If !IsInCallStack( 'TombAutom' ) .And. ApMsgYesNo(STR0031)
							Do Case
								//Valores do cadastro de liminares
								Case lMultiLim

									//Seta o modelo do JURA095 para atualizações no JURA260
									J260Set095(oModel095)

									If JURA260(cFilAnd, cCajuri, .F.)
										nAtualiza := 2
									EndIf

								//Valores do processo
								Case AllTrim( SuperGetMv("MV_JTLATVR", , "1") ) == "1"
									INCLUI := .F.
									ALTERA := .T.

									If !Empty(oModel095)
										//Ao entrar no JURA095 ira, ao iniciar, obter o oModel anterior ativo antes de iniciar um novo
										FwModelActive(oModel095)
									EndIf

									//Tela Valores do Processo - Validacao "1" qdo o usuario confirma a gravacao / Validacao "2" qdo o usuario clica no botao fechar.
									MsgRun(STR0032,STR0033,{|| FWExecView(STR0004,"JURA095", 4,,{|| .T. },{|oV| JURA100RET(oV,"1",@nAtualiza,) },,aShow,{|oV| JURA100RET(oV,"2",@nAtualiza,) },,, )}) //"Carregando..." , "Pesquisa de Processos" , "Alterar"

								//Valores do Objeto
								OTherWise
									JCall094(cCajuri, oModel095, @nAtualiza, /*nOpc*/, /*lChgAll*/, cFilAnd)
							End Case
						EndIf

						//Caso nao tenha atualizado os valores deve justificar.
						lJustifica := (nAtualiza < 2)
						If lJustifica
							Aviso(STR0004, STR0035, {"Ok"}) //"Alterar"	//"Valores da sentença não atualizados, favor preencher as informações de justificativa!"
							Set020lMsg(.F.)
							cMensJust := STR0034 			//"Valores da sentença devem ser atualizados ou preencher as informações de justificativa!"
						EndIf
					EndIf
				EndIf
			EndIf

		//Tipo do ato 2=Liminar - Andamento tipo Liminar
		ElseIf cTipoAto == '2'

			//Contencioso
			If cTipoAsJ == '001'
				lAtualizar := .T.
			EndIf

			//Exibe mensagem para confirmar a atualização dos campos, ao cadastrar um andamento como liminar? 1-Sim; 2-Não
			If lRet .And. lAtualizar .And. AllTrim( SuperGetMv("MV_JATLIMI", , "1") ) == "1"

				If oModel:GetValue("NT4MASTER", "NT4_IMPXML") == "1"	   .Or.; 	//Caso tenha sido importado ou
				   oModel:GetModel("NT4MASTER"):IsFieldUpdated("NT4_CATO") 			//Caso o código do ato tenha sido alterado

				   	//"Deseja incluir uma Liminar?"	//"Deseja atualizar os campos da liminar?"
					If ApMsgYesNo( IIF(lMultiLim, STR0051, STR0036) )

						//Abre liminar para inclusão
						If lMultiLim

							//Seta o modelo do JURA095 para atualizações no JURA260
							J260Set095(oModel095)

							oModel260 := FWLoadModel("JURA260")
							oModel260:SetOperation(MODEL_OPERATION_INSERT)
							oModel260:Activate()

							oModel260:LoadValue("O0SMASTER", "O0S_CAJURI", cCajuri	 )
							oModel260:LoadValue("O0SMASTER", "O0S_DTRECE", dDataAnd	 )
							oModel260:LoadValue("O0SMASTER", "O0S_STATUS", cStsAto	 )
							oModel260:LoadValue("O0SMASTER", "O0S_OBSERV", cDescricao)

							nRet := FWExecView(STR0003, "JURA260", MODEL_OPERATION_INSERT, /*oDlg*/, /*bCloseOnOk*/, {||.T.}, /*nPercReducao*/, /*aEnableButtons*/, {|| .T.}, /*cOperatId*/,  /*cToolBar*/, oModel260)	//"Incluir"
							If nRet == 0
								nAtualiza := 2
							EndIf

							oModel260:Deactivate()
							oModel260:Destroy()

						//Abre assunto juridico para atualizar campos da liminar
						Else

							INCLUI := .F.
							ALTERA := .T.

							If !Empty(oModel095)
								//Ao entrar no JURA095 ira, ao iniciar, obter o oModel anterior ativo antes de iniciar um novo.
								FwModelActive(oModel095)
							EndIf

							If lIniJ95 .And. cStsAto $ "123"
								//Inicializa as variaveis staticas da liminar para passagem dos valores para os campos de liminar.
								J95IniVar1(.T./*lLiminar*/, cStsAto, cDescricao)
							EndIf

							//Tela Valores do Processo - Validacao "1" quando o usuario confirma a gravacao / Validacao "2" quando o usuario clica no botao fechar.
							MsgRun(STR0032,STR0033,{|| FWExecView(STR0004,"JURA095", 4,,{|| .T. },{|oV| JURA100RET(oV,"1",@nAtualiza,.T.) },,aShow,{|oV| JURA100RET(oV,"2",@nAtualiza,.T.) },,, )}) //"Carregando..." , "Pesquisa de Processos" , "Alterar"
						EndIf
					EndIf

					//Caso nao tenha atualizado os valores deve justificar
					lJustifica := (nAtualiza < 2)
					If lJustifica
						Aviso(STR0004, STR0037, {"Ok"}) //"Alterar"##"Campos da liminar não atualizados, favor preencher as informações de justificativa!"
						cMensJust := STR0038 			//"Campos da liminar devem ser atualizados ou preencher as informações de justificativa!"
					EndIf
				EndIf
			EndIf

		EndIf

		//Justificativa
		If lRet .And. lJustifica

			oModelNUV := FWLoadModel("JURA166")
			oModelNUV:SetOperation(3)
			oModelNUV:Activate()

 			If oModelNUV:GetModel("NUVMASTER"):HasField("NUV_CLMTAL")
				oModelNUV:LoadValue("NUVMASTER", "NUV_CLMTAL", "2")	//2=Valores
			EndIf

			lRet := ( FWExecView(STR0003, 'JURA166', 3, , {||.T.},,,,,,, oModelNUV) == 0 )	//"Incluir"

			If !lRet
				JurMsgErro(cMensJust)
			EndIf

			oModelNUV:DeActivate()
			oModelNUV:Destroy()
		EndIf

		//Voltar ao modelo do JURA100
		FwModelActive(oModelOld)
		oModelOld:Activate()
	EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} RetTriAno()
Retorna o trimestre e o ano, referente a data passada

@param	 dData 		- Data base
@return  cTrimestre - Trimestre e ano
@author  Rafael Tenorio da Costa
@since 	 22/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetTriAno(dData)

	Local cTrimestre := ""
	Local nMes 		 := Month(dData)

	Do Case
		Case nMes >= 1 .And. nMes <= 3
			cTrimestre := I18n(STR0052, {"1º"})	//"#1 Trimestre"
		Case nMes >= 4 .And. nMes <= 6
			cTrimestre := I18n(STR0052, {"2º"})	//"#1 Trimestre"
		Case nMes >= 7 .And. nMes <= 9
			cTrimestre := I18n(STR0052, {"3º"})	//"#1 Trimestre"
		Case nMes >= 10 .And. nMes <= 12
			cTrimestre := I18n(STR0052, {"4º"})	//"#1 Trimestre"
	EndCase

	If !Empty(cTrimestre)
		cTrimestre := cTrimestre + "\" + cValToChar( Year(dData) )
	EndIf

Return cTrimestre

//-------------------------------------------------------------------
/*/{Protheus.doc} J100GrvAnd
Rotina que grava Andamento de forma automatica

@param   aAnds	  - Andamentos que serão gravados (Campo, Conteudo)
@return  lRetorno - Indica se foi gerado corretamente os andamentos

@author  Rafael Tenorio da Costa
@since 	 27/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J100GrvAnd(aAnds)

	Local aArea      := GetArea()
	Local aAreaNT4   := NT4->( GetArea() )
	Local oModelAct	:= FwModelActive()
	Local aCampos    := {}
	Local nCampo     := 0
	Local cCampo     := ""
	Local lAlt       := .F.
	Local xConteudo  := ""
	Local nAnd	     := 0
	Local lRetorno   := .T.
	Local oModelNT4  := Nil

	oModelNT4 := FWLoadModel("JURA100")
	oModelNT4:SetOperation(MODEL_OPERATION_INSERT)

	For nAnd:=1 To Len(aAnds)

		aCampos := aAnds[nAnd]

		oModelNT4:Activate()

		//Processa os campos
		For nCampo:=1 to Len(aCampos)

			lAlt   	  := .T.
			cCampo 	  := AllTrim( aCampos[nCampo][1] )
			xConteudo := aCampos[nCampo][2]

			//Campos que não serão alterados
			If cCampo $ "NT4_COD"
				lAlt := .F.
			EndIf

			//Verifica se campo pode ser alterado
			If lAlt
				If cCampo $ "NT4_CAJURI"
					lRetorno := oModelNT4:LoadValue("NT4MASTER", cCampo, xConteudo)
				Else
				  	lRetorno := oModelNT4:SetValue("NT4MASTER", cCampo, xConteudo)
				EndIf

				If !lRetorno
					Exit
				EndIf
			Endif
		Next nCampo

		//Valida e grava andamento
		If lRetorno
			If !oModelNT4:VldData() .Or. !oModelNT4:CommitData()
				lRetorno := .F.
			EndIf
		EndIf

		If lRetorno

			//Confirma andamentos que foram incluidos
			If __lSX8
				ConfirmSX8()
			EndIf
		Else

			//Volta numeracao do andamento
			If __lSX8
				RollBackSX8()
			EndIf

			JurMsgErro(STR0054) //"Não foi possível incluir o andamento."
			Exit
		EndIf

		oModelNT4:DeActivate()
	Next nAnd

	oModelNT4:Destroy()

	If oModelAct <> Nil
		FwModelActive(oModelAct)
		//oModelAct:Activate()
	EndIf

	RestArea(aAreaNT4)
	RestArea(aArea)

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} J100IUJson
Função para gerar fups e andamentos com intervenção de usuários. 
Os dados para a geração são obtidos a partir do campo NT4__FLXMAN/ cFlxMJson (static JURA100) 
que contém o objeto JSON preenchido na requisição do Totvslegal.

@param dNvDtFw    Data do follow-up
@param cCodFw     Código do follow-up pai
@param cCodAnd    Código do andamento pai

@Return lRet      Resultado do commit JURA100/ JURA106

@since 20/11/2020
/*/
//-------------------------------------------------------------------
Function J100IUJson(dNvDtFw, cCodFw, cCodAnd)
Local lRet       := .T.
Local oModelJ106 := FWLoadModel("JURA106")
Local oModelJ100 := FWLoadModel("JURA100")
Local oJson      := JSonObject():New()
Local nX         := 1

Default dNvDtFw   := ""
Default cFlxMJson := ""
Default cCodFw    := ""
Default cCodAnd   := ""

	oJson:fromJson(cFlxMJson)

	If ValType(oJson["fluxoManual"]) == "A"
		For nX := 1 To Len(oJson["fluxoManual"])
			If !oJson["fluxoManual"][nX]["used"]
				If oJson["fluxoManual"][nX]["canceled"]
					UpdJsonFlx(nX)
				Else
					If oJson["fluxoManual"][nX]["type"] == "2" //FUP
						oModelJ106:SetOperation(MODEL_OPERATION_INSERT)
						oModelJ106:Activate()

						If Empty(cCodFw)
							oModelJ106:SetValue("NTAMASTER","NTA_CANDAM",cCodAnd )
						Else
							oModelJ106:SetValue("NTAMASTER","NTA_CFLWPP",cCodFw )
						EndIf
						oModelJ106:LoadValue("NTAMASTER","NTA_CAJURI", oJson["fluxoManual"][nX]["NTA_CAJURI"])
						oModelJ106:LoadValue("NTAMASTER","NTA_DTFLWP", SToD(STRTRAN(oJson["fluxoManual"][nX]["NTA_DTFLWP"],'-','')))
						oModelJ106:SetValue("NTAMASTER" ,"NTA_HORA"  , oJson["fluxoManual"][nX]["NTA_HORA"  ])
						oModelJ106:SetValue("NTAMASTER" ,"NTA_CTIPO" , oJson["fluxoManual"][nX]["NTA_CTIPO" ])
						oModelJ106:SetValue("NTAMASTER" ,"NTA_CRESUL", oJson["fluxoManual"][nX]["NTA_CRESUL"])
						oModelJ106:SetValue("NTAMASTER" ,"NTA_CPREPO", oJson["fluxoManual"][nX]["NTA_CPREPO"])
						oModelJ106:SetValue("NTAMASTER" ,"NTA_DESC"  , oJson["fluxoManual"][nX]["NTA_DESC"  ])
	
						oModelJ106:SetValue("NTEDETAIL" ,"NTE_SIGLA" , oJson["fluxoManual"][nX]["NTE_SIGLA" ])

						If ( lRet := oModelJ106:VldData() )
							UpdJsonFlx(nX)
							lRet := oModelJ106:CommitData()
						EndIf
					Else
						
						oModelJ100:SetOperation(MODEL_OPERATION_INSERT)
						oModelJ100:Activate()

						oModelJ100:LoadValue("NT4MASTER","NT4_CAJURI", oJson["fluxoManual"][nX]["NT4_CAJURI"])
						oModelJ100:SetValue("NT4MASTER","NT4_DESC"   , oJson["fluxoManual"][nX]["NT4_DESC"  ])
						oModelJ100:SetValue("NT4MASTER","NT4_DTANDA" , STOD(STRTRAN(oJson["fluxoManual"][nX]["NT4_DTANDA"],'-','')))
						oModelJ100:SetValue("NT4MASTER","NT4_CATO"   , oJson["fluxoManual"][nX]["NT4_CATO"  ])
						oModelJ100:SetValue("NT4MASTER","NT4_CFASE"  , oJson["fluxoManual"][nX]["NT4_CFASE" ])
						oModelJ100:SetValue("NT4MASTER","NT4_DTALTE" , STOD(STRTRAN(oJson["fluxoManual"][nX]["NT4_DTALTE"],'-','')))
						oModelJ100:SetValue("NT4MASTER","NT4_USUALT" , oJson["fluxoManual"][nX]["NT4_USUALT"])
						oModelJ100:SetValue("NT4MASTER","NT4_CINSTA" , oJson["fluxoManual"][nX]["NT4_CINSTA"])
						oModelJ100:LoadValue("NT4MASTER","NT4_CFWLP"  , cCodFw)

						If ( lRet := oModelJ100:VldData() )
							UpdJsonFlx(nX)
							lRet := oModelJ100:CommitData()
						EndIf
					EndIf
				EndIf

				Exit

			EndIf
		Next nX
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdJsonFlx
Função para marcar como "usado" os registros do objeto JSON que já foram criados.

@param nOrder     Número da posição do array a ser alterada

@Return .T. 

@since 20/11/2020
/*/
//-------------------------------------------------------------------
Static Function UpdJsonFlx(nOrder)
Local oJson      := JSonObject():New()
Local nX         := 1

	oJson:fromJson(cFlxMJson)

	For nX := 1 To Len(oJson["fluxoManual"])
		If oJson["fluxoManual"][nX]["order"] == nOrder
			oJson["fluxoManual"][nX]["used"] := .T.
			If Len(oJson["fluxoManual"]) == nOrder
				cFlxMJson := ''
			Else 
				cFlxMJson := FWJsonSerialize(oJson, .F., .F., .T.)
			EndIf
			
			Exit
		EndIf
	Next nX


Return .T.
