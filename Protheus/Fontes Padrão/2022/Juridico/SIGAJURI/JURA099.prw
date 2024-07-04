#INCLUDE "JURA099.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------
/*/{Protheus.doc} JURA099
Despesa / Custas

@author Raphael Zei Cartaxo Silva
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA099( cProcesso, lChgAll, cBrwFilial )

Local cHabPesqD := SuperGetMV("MV_JHBPESD",, '2') //“Habilita a tela de pesquisa de Despesas e Custas (1=Sim;2=Não) (Valor Padrão 2)"
Local oBrowse   := Nil
Local aArea     := GetArea()
Local aAreaNSZ  := NSZ->( GetArea() )

Default cProcesso  := ""
Default lChgAll    := .T.
Default cBrwFilial := xFilial("NT3")

//Ponto de entrada para processo auxiliar antes de abrir a despesa
If ExistBlock("JA99INI")
	Execblock("JA99INI", .F., .F., {cBrwFilial, cProcesso})
EndIf

If cHabPesqD == '1' .AND. !(IsInCallStack( 'JURA095' ) .Or. IsInCallStack( 'JURA162' ) .Or. IsInCallStack('JURA219'))
	MsgRun(STR0025,STR0026, {||JURA162("5",STR0007,"JURA099")}) //"Carregando..." # "Aguarde..."
Else

	dbSelectArea("NT3")

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )
	oBrowse:SetAlias( "NT3" )
	oBrowse:SetLocate()
	oBrowse:SetChgAll( lChgAll )
	If !Empty( cProcesso )
		oBrowse:SetFilterDefault(  " NT3_FILIAL == '"+cBrwFilial +"' .AND. NT3_CAJURI == '" + cProcesso + "'" )
	EndIf
	oBrowse:SetMenuDef( 'JURA099' )
	JurSetBSize( oBrowse, '50,50,50' )
	JurSetLeg( oBrowse, "NT3"  )
	oBrowse:Activate()
EndIf

RestArea( aAreaNSZ )
RestArea( aArea )
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

@author Raphael Zei Cartaxo Silva
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local aAux    := {}
Local nAux    := 0

	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0010, "JurAnexos('NT3', NT3->NT3_CAJURI+NT3->NT3_COD, 1)", 0, 1, 0, .T. } ) // "Anexos"

	If JA162AcRst('08',2)
		aAdd( aRotina, { STR0002, "VIEWDEF.JURA099", 0, 2, 0, NIL } ) // "Visualizar"
	EndIf

	If JA162AcRst('08',3)
		aAdd( aRotina, { STR0003, "VIEWDEF.JURA099", 0, 3, 0, NIL } ) // "Incluir"
	EndIf
	If JA162AcRst('08',4)
		aAdd( aRotina, { STR0004, "VIEWDEF.JURA099", 0, 4, 0, NIL } ) // "Alterar"
	EndIf
	If JA162AcRst('08',5)
		aAdd( aRotina, { STR0005, "VIEWDEF.JURA099", 0, 5, 0, NIL } ) // "Excluir"
	EndIf
	If JA162AcRst('13')
		aAdd( aRotina, { STR0029, "RelDesp()", 0, 6, 0, NIL } ) // "Relatorio"
	EndIf

	If JA162AcRst('08') .AND. (SuperGetMV('MV_JINTVAL',, '2') == '1')
		aAdd( aRotina, { STR0013, "JurTitPag('NT3',NT3->NT3_CAJURI,NT3->NT3_COD,,NT3->NT3_FILDES)" , 0, 2, 0, NIL } ) 	// "Títulos"
		If (SuperGetMV('MV_JALCADA',, '2') == '1')
			aAdd( aRotina, { STR0019, "JurLibDoc('NT3','3',NT3->NT3_CAJURI,NT3->NT3_COD,NT3->NT3_FILDES)" , 0, 2, 0, NIL } )//"Liberação de Dctos"
		EndIf
	EndIf

	//Ponto de entrada para adicionar outras ações
	If ExistBlock("JA99MDEF")
		aAux := Execblock("JA99MDEF", .F., .F.)
		If ValType(aAux) == "A"
			For nAux := 1 To Len(aAux)
				Aadd(aRotina, aAux[nAux])
			Next nAux
		EndIf
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} JA099Opc
Efetuar pré-validações antes de abrir a rotina para manutenção.

@author  Rafael Tenorio da Costa
@since   07/02/18
@version 1.0
@author  nishizaka.cristiane
@since   12/02/2019
@version 2.0
/*/
//-------------------------------------------------------------------
Function JA099Opc()

	Local lRet := .T.
	
	//Verifica se integração financeira esta ativa
	If SuperGetMV("MV_JINTVAL", , "2") == "1" .And. JurGetDados("NSR", 1, xFilial("NSR") + NT3->NT3_CTPDES, "NSR_INTCTB") == "1"
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Despesa / Custas

@author Raphael Zei Cartaxo Silva
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel   := FWLoadModel( "JURA099" )
Local oStruct  := FWFormStruct( 2, "NT3" )
Local aBotoes  := {}

JurSetAgrp( 'NT3',, oStruct )

// Se o parametro de "Integração de valores com Financeiro e Contabilidade" estiver como falso,
// o campo de NT2_INTFIN (Garantia integra financeiro) deverá se retirado da view
Do Case
	Case (SuperGetMV('MV_JINTVAL',, '2') == '2')
		oStruct:RemoveField( "NT3_PRODUT" )
		oStruct:RemoveField( "NT3_CONDPG" )
		oStruct:RemoveField( "NT3_NOMEFT" )
		oStruct:RemoveField( "NT3_CTIPOT" )
		oStruct:RemoveField( "NT3_CFORNT" )
		oStruct:RemoveField( "NT3_LFORNT" )
		oStruct:RemoveField( "NT3_NOMEFT" )
		oStruct:RemoveField( "NT3_CNATUT" )
		oStruct:RemoveField( "NT3_PREFIX" )
		oStruct:RemoveField( "NT3_DTFIN"  )
		oStruct:RemoveField( "NT3_FILDES" )
		oStruct:RemoveField( "NT3_CRATEI" )
		oStruct:RemoveField( "NT3_DRATEI" )
End Case

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA099_VIEW", oStruct, "NT3MASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA099_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Despesa / Custas"
oView:EnableControlBar( .T. )

If Existblock( 'JA99RETBOT' )
	aBotoes := Execblock('JA99RETBOT', .F., .F.)
EndIf

If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT01"} ) <= 0 ) ) .And. JA162AcRst('03')
	oView:AddUserButton( STR0010, "CLIPS", {| oView | IIF( J95AcesBtn(), JurAnexos("NT3", NT3->NT3_CAJURI+NT3->NT3_COD, 1), FWModelActive()) } )
EndIf

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Despesa / Custas

@author Raphael Zei Cartaxo Silva
@since 27/05/09
@version 1.0

@obs NT3MASTER - Dados do Despesa / Custas

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NT3" )
Local lWSTLegal  := JModRst()

If lWSTLegal // Se a chamada estiver vindo do TOTVS Legal
	//Campo que indica se o registro posicionado possui anexo - criado para o TOTVS Legal
	oStruct:AddField( ;
		""                                                 , ; // [01] Titulo do campo
		""		                                           , ; // [02] ToolTip do campo
		"NT3__TEMANX"                                      , ; // [03] Id do Field
		"C"                                                , ; // [04] Tipo do campo
		2                                                  , ; // [05] Tamanho do campo
		0                                                  , ; // [06] Decimal do campo
		,                                                    ; // [07] Bloco de código de validação do campo
		,                                                    ; // [08] Bloco de código de validação when do campo
		,                                                    ; // [09] Lista de valores permitido do campo
		,                                                    ; // [10] Indica se o campo tem preenchimento obrigatório
		{|| JTemAnexo("NT3",NT3->NT3_CAJURI,NT3->NT3_COD)} , ; // [11] Bloco de código de inicialização do campo
		,                                                    ; // [12] Indica se trata-se de um campo chave
		,                                                    ; // [13] Indica se o campo não pode receber valor em uma operação de update
		.T.                                                  ; // [14] Indica se o campo é virtual
		,                                                    ; // [15] Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
	)
Endif

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA099", /*Pre-Validacao*/, {|oModel| JURA099TOK(oModel)}/*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
oModel:AddFields( "NT3MASTER", NIL, oStruct, /*Pre-Validacao*/,/*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Despesa / Custas"
oModel:GetModel( "NT3MASTER" ):SetDescription( STR0009 ) // "Dados de Despesa / Custas"

JurSetRules( oModel, 'NT3MASTER',, 'NT3' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA099TOK
Verifica se os 3 campos de data, moeda e valor foram preenchidos

@param 	oModel  	Model a ser verificado
@Return lTudoOk	    Valor lógico de retorno

@sample
{|oModel| JURA099TOK(oModel)}

@author Raphael Zei
@since 09/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA099TOK( oModel )
Local lTudoOk   := .T.
Local nOpc      := oModel:GetOperation()
Local lJxIntval := .T.
Local lWSTLegal := JModRst()
Local cTipot    := AllTrim(oModel:GetValue("NT3MASTER","NT3_CTIPOT"))

PRIVATE cBancoAdt   := CriaVar("A6_COD")
PRIVATE cAgenciaAdt := CriaVar("A6_AGENCIA")
PRIVATE cNumCon     := CriaVar("A6_NUMCON")
PRIVATE nMoedAdt    := CriaVar("A6_MOEDA")
PRIVATE cChequeAdt  := CriaVar("EF_NUM")
PRIVATE cHistor     := CriaVar("EF_HIST")
PRIVATE cBenef      := CriaVar("EF_BENEF")
PRIVATE cPictHist   := Nil

If !JurAuto() .And. !lWSTLegal
	//-- Se o tipo de título é PA, abre a tela para preencher as informações bancárias.
	If cTipot == 'PA'
		lTudoOk  := J99BcoPA()
	EndIf 
EndIf

If nOpc > 2
	lTudoOk := JURSITPROC(oModel:GetValue("NT3MASTER","NT3_CAJURI"), 'MV_JTVENDP')

	If lTudoOk
		If nOpc == 5
			//Excluir os documentos anexados ao excluir
			lTudoOk := TJurDelAnx(oModel:GetValue("NT3MASTER","NT3_CAJURI"),'NT3',oModel:GetValue("NT3MASTER","NT3_COD"))
		EndIf
	EndIf

	If lTudoOk .And. (nOpc == 3 .Or. nOpc == 4)
		//Valida se a data é superior a atual ou inferior a data de distribuição
		lTudoOk := JurVDtDist("NT3_CAJURI","NT3_DATA")
	EndIf

 	If lTudoOk
		If (SuperGetMV('MV_JINTVAL',, '2') == '1') .And. JurGetDados("NSR",1,XFILIAL("NSR")+oModel:GetValue("NT3MASTER","NT3_CTPDES"), "NSR_INTCTB") == '1'
			If !Empty(FwFldGet("NT3_CTIPOT")) .AND. !Empty(FwFldGet("NT3_CFORNT")) .AND. !Empty(FwFldGet("NT3_LFORNT")) .AND. !Empty(FwFldGet("NT3_CNATUT"))
	 			If (SuperGetMV('MV_JALCADA',, '2') == '1') .And. (Empty(FwFldGet("NT3_CONDPG")) .Or. Empty(FwFldGet("NT3_PRODUT")))
					JurMsgErro(STR0021)//Controle de alçada habilitado. Preencher Cond. Pagto e Produto
					lTudoOk := .F.
				ElseIf (SuperGetMV('MV_JALCADA',, '2') == '2') .And. Empty(FwFldGet("NT3_PREFIX"))
					JurMsgErro(STR0022)//Preencha o Prefixo para geração do título
					lTudoOk := .F.
				EndIf

	 			If lTudoOk
	 				//Ponto de Entrada para inibir ou interar com a integração automática.
					If Existblock("J99XINTVAL")
						lJxintval := Execblock("J99XINTVAL", .F., .F., {oModel})
					EndIf

					If lJxintval
						lTudoOk := JurHisCont(FwFldGet("NT3_CAJURI"),FwFldGet("NT3_COD"),FwFldGet("NT3_DATA"),FwFldGet("NT3_VALOR"),'1','3','NT3', nOpc)
					EndIf


					If !lTudoOk .And. nOpc == 3
						DbSelectArea("NV3")
						NV3->( DbSetOrder(2) )
						If NV3->( DbSeek(xFilial("NV3") + FwFldGet("NT3_CAJURI") + FwFldGet("NT3_COD") + "3") )
							Reclock("NV3", .F.)
							DbDelete()
							NV3->( MsUnlock() )
						EndIf
					EndIf
				EndIf
			Else
				JurMsgErro(STR0014)//'Integração Ativa. Preencher Natureza, Tipo, Fornecedor, Cond. Pagto e Produto'
				lTudoOk := .F.
			EndIf

			If lTudoOk
				If JurGetDados("NSR",1,xFilial("NSR")+FwFldGet("NT3_CTPDES"), 'NSR_ATPROV') == '1'
					MsgAlert(STR0015 + FwFldGet("NT3_CAJURI") + '.',STR0016)// "Atualizar o valor de provisão do processo: " e "Conferir"
				EndIf
			EndIf
		Endif
	Endif
EndIf

If lTudoOk .And. SuperGetMV('MV_JINTJUR',, '2') == '1'
	JurIntJuri(oModel:GetValue("NT3MASTER","NT3_COD"),oModel:GetValue("NT3MASTER","NT3_CAJURI"), "5", Str(nOpc))
Endif

Return lTudoOk

//-------------------------------------------------------------------
/*/{Protheus.doc} JA099CAJUR
Verifica o preenchimento do campo de código de assunto jurídico

@Return cRet	 	Código do assunto jurídico

@author Juliana Iwayama Velho
@since 24/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA099CAJUR()
Local cRet := ''

If IsInCallStack('JURA162') .And. !Empty(M->NSZ_COD)
	cRet := M->NSZ_COD
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA099HABCJ
Verifica se a tela não está sendo chamada a partir de Assunto Jurídico
e se a operação é de inclusão, para habilitar o campo de
Código de Assunto Jurídico para preenchimento pelo usuário

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 24/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA099HABCJ()
Local lRet  := .T.

If IsInCallStack('JURA162') .And. !Empty(M->NSZ_COD)
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA99SB1
Monta a query de Produto apartir de parâmetro de filial destino
Uso no cadastro de Despesas.

@Return cFildest  Campo de filial de destino
@Return cQuery	 	Query montada

@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA99SB1(cFilDest)
Local aArea    := GetArea()
Local cQuery   := ""
Local cTabela  := "SB1"
Local lFilial  := FWModeAccess(SUBSTRING(cTabela,1,3),1) == "E" .OR. FWModeAccess(SUBSTRING(cTabela,1,3),2) == "E" .OR. FWModeAccess(SUBSTRING(cTabela,1,3),3) == "E"


	cQuery += " SELECT B1_FILIAL, B1_COD, B1_DESC, R_E_C_N_O_ SB1RECNO "
	cQuery += "   FROM "+RetSqlName("SB1")+" SB1 "
	cQuery += "  WHERE SB1.D_E_L_E_T_ = ' '"

Do Case
	Case Empty(cFilDest)
		 	cQuery += " AND B1_FILIAL = '"+xFilial('SB1')+"'"
	Case !Empty(cFilDest) .And. lFilial
			cQuery += " AND B1_FILIAL = '"+FwxFilial('SB1',cFilDest)+"'"
EndCase

RestArea( aArea )

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J99F3SB1
Customiza a consulta padrão de produto conforme a filial destino
Uso no cadastro de Despesas.

@param 	cMaster  	NT3DETAIL  - Dados da Garantia
@Return cCampo	    NT3_PRODUT - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J99F3SB1(cMaster, cCampo)
Local lRet   := .F.
Local aArea  := GetArea()
Local oModel
Local cQuery
Local aPesq  := {"B1_COD", "B1_DESC"}

Default cMaster := ''
Default cCampo 	:= ''

	If IsPesquisa()
		cQuery   := JURA99SB1(FWxFilial("SC7",(FwFldGet('NT3_FILDES'))))
	Else
		oModel   := FWModelActive()
		cQuery   := JURA99SB1(oModel:GetValue(cMaster,cCampo))
	EndIF

	cQuery := ChangeQuery(cQuery, .F.)
	uRetorno := ''
	RestArea( aArea )

	If JurF3Qry( cQuery, 'JURA99F3', 'SB1RECNO', @uRetorno, , aPesq,,,,,'SB1' )
		SB1->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J99PROVAL
Função para validar as inforamções do produto

@param 	cMaster  	NT2DETAIL  - Dados da Garantia
@Return cCampo	    NT2_FILDES - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J99PROVAL(cTabela)
Local lRet     := .F.
Local aArea    := GetArea()
Local aAreaSB1 := SB1->( GetArea() )
Local oModel   := FWModelActive()
Local cFilDest := ""
Local cProdut  := ""
Local lFilial  := ""

Default cTabela := "NT3"

lFilial := FWModeAccess(SUBSTRING('SB1',1,3),1) == "E" .OR. FWModeAccess(SUBSTRING('SB1',1,3),2) == "E" .OR. FWModeAccess(SUBSTRING('SB1',1,3),3) == "E"

cFilDest := oModel:GetValue(cTabela+"MASTER",cTabela+"_FILDES")
cProdut  := oModel:GetValue(cTabela+"MASTER",cTabela+"_PRODUT")

	SB1->( dbSetOrder( 1 ) )

	If !Empty(cFilDest) .And. lFilial
		if SB1->( dbSeek( FwxFilial( 'SB1' ,cFilDest) + cProdut )	)
		  lRet := .T.
		Endif
	Else
		if SB1->( dbSeek( FwxFilial( 'SB1' ) + cProdut ) )
			lRet := .T.
		Endif
	EndIf

	If !lRet
		JurMsgErro(STR0023) //"Não existe registro relacionado a este código"
	EndIf

	RestArea( aAreaSB1 )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA99SE4
Monta a query de Condição de Pagamento apartir de parâmetro de filial destino
Uso no cadastro de Despesas.

@Return cFildest  Campo de filial de destino
@Return cQuery	 	Query montada
@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA99SE4(cFilDest)
Local aArea    := GetArea()
Local cQuery   := ""
Local cTabela  := "SE4"
Local lFilial  := FWModeAccess(SUBSTRING(cTabela,1,3),1) == "E" .And. FWModeAccess(SUBSTRING(cTabela,1,3),2) == "E" .And. FWModeAccess(SUBSTRING(cTabela,1,3),3) == "E"

	cQuery += " SELECT E4_FILIAL, E4_CODIGO, E4_DESCRI, E4_TIPO, R_E_C_N_O_ SE4RECNO "
	cQuery += "   FROM "+RetSqlName("SE4")+" SE4 "
	cQuery += "  WHERE SE4.D_E_L_E_T_ = ' '"

	If !Empty(cFilDest) .And. lFilial
		cQuery += " AND E4_FILIAL = '"+cFilDest+"'"
	Else
		cQuery += " AND E4_FILIAL = '"+FwxFilial('SE4')+"'"
	EndIf

RestArea( aArea )

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J99F3SE4
Customiza a consulta padrão de produto conforme a filial destino
Uso no cadastro de Despesas.

@param 	cMaster  	NT3DETAIL  - Dados da Garantia
@Return cCampo	    NT3_FILDES - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J99F3SE4(cMaster, cCampo)
Local cTab       := "SE4"
Local aCampos    := {"E4_FILIAL", "E4_CODIGO", "E4_DESCRI", "E4_TIPO"}
Local lVisualiza := .T.
Local lInclui    := .F.
Local cFonte     := ""
Local nResult    := 0
Local lResult    := .F.
Local cQuery     := ""

Default cMaster := ''
Default cCampo  := '' 

	If IsPesquisa()
		cQuery   := JURA99SE4(M->&cCampo)
	Else
		oModel   := FWModelActive()
		cQuery   := JURA99SE4(oModel:GetValue(cMaster,cCampo))
	EndIF

	nResult := JurF3SXB(cTab, aCampos, "", lVisualiza, lInclui, cFonte, cQuery)
	lResult := nResult > 0

	If lResult
		DbSelectArea(cTab)
		&(cTab)->(dbgoTo(nResult))
	EndIf


Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} J98COPVAL
Função para validar as inforamções do produto
@param 	cMaster  	NT3DETAIL  - Dados da Garantia
@Return cCampo	    NT3_FILDES - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98COPVAL(cTabela)
Local lRet     := .F.
Local aArea    := GetArea()
Local aAreaSE4 := SE4->( GetArea() )
Local oModel   := FWModelActive()
Local cFilDest := ""
Local cCondPg  := ""
Local lFilial  := ""

Default cTabela := "NT3"

lFilial := FWModeAccess(SUBSTRING("SE4",1,3),1) == "E" .OR. FWModeAccess(SUBSTRING("SE4",1,3),2) == "E" .OR. FWModeAccess(SUBSTRING("SE4",1,3),3) == "E"

cFilDest := oModel:GetValue(cTabela+"MASTER",cTabela+"_FILDES")
cCondPg  := oModel:GetValue(cTabela+"MASTER",cTabela+"_CONDPG")

	SE4->( dbSetOrder( 1 ) )

	If !Empty(cFilDest) .And. lFilial
		if SE4->( dbSeek( FwxFilial( 'SE4', cFilDest ) + cCondPg )	)
		  lRet := .T.
		Endif
	Else
		if SE4->( dbSeek( FwxFilial( 'SE4' ) + cCondPg ) )
			lRet := .T.
		Endif
	EndIf

	If !lRet
		JurMsgErro(STR0023) //"Não existe registro relacionado a este código"
		lRet := .F.
	EndIf

	RestArea( aAreaSE4 )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J99BcoPA()
Abre tela para digitação dos dados bancários para geracao do PA

@Return lRet	 

@author nishizaka.cristiane/ daniel.frodrigues
@since 28/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Function J99BcoPA()

Local lRet   := .T.
Local oModel := FWModelActive()
Local cTipot := ""
Local cMoeda := oModel:GetValue("NT3MASTER","NT3_CMOEDA")

	pergunte("FIN050",.F.)
	Fa050DigPa(,cMoeda)
	
	If mv_par05 == 1 .And. Empty(cChequeAdt)
		Help(,,"VLDBANCO",,STR0031,1,0) //"Informe o número de cheque."  
		lRet := .F.
	EndIf 

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} RelDesp()
Modelo de dados de Despesas

@author Clóvis Eduardo Teixeira
@since 24/06/10
@version 1.0

/*/
//-------------------------------------------------------------------
Function RelDesp(cCodJur, cFilpro)

// SuperGetMV("MV_JHBPESA",, 1) == '2'
// “Habilita a tela de pesquisa de andamentos"
// Solicitacao do relatorio diretamente pela JURA100
Default cCodJur := NT3_CAJURI
Default cFilpro := NT3_FILIAL

If Existblock( 'JURR099' )
	U_JURR099(cCodJur, cFilpro) //Chamada da função que define as regras do relatório e faz a impressão usando a ferramenta TMSPrinter
Else
	JURR099(cCodJur, cFilpro) //Chamada da função que define as regras do relatório e faz a impressão usando a ferramenta TMSPrinter
EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA099IniPad
Função inicializador padrão do campo de natureza financeira

@return  código da natureza financeira

@author  nishizaka.cristiane
@since   12/06/2020
/*/
//-------------------------------------------------------------------
Function JA099NatuTit()
Local cRet      := ""

	// Proteção da tabela de campos contabeis complementares 
	If FWAliasIndic("O11")
		cRet := Posicione("O11",1,xFilial("O11")+M->NT3_CAJURI,"O11_CNATUT")
	EndIf

	If Empty(cRet)
		cRet := GetMv("MV_JNATDES")
	EndIf

Return cRet