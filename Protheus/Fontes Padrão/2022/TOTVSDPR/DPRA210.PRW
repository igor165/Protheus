#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWADAPTEREAI.CH' 
#INCLUDE 'DPRA210.CH'

//------------------------------------------------------------------
/*/{Protheus.doc} DPRA210
Ficha técnica desenvolvedor de produto

@author Samantha Preima
@since 24/09/2013
@version P12

/*/
//------------------------------------------------------------------
Function DPRA210()
	Local oBrowse
	Private aTemplates := {}
	Private lEnd := .f.
	Private lEntrou := .f.
	Private nVlIniFx, nVlFinFx, nVlFaixa
	Private cDGNCDACDV, cDGNCDMQ, cDGNCDMD
	Private cAbreTela := 'S'
	Private cExecVald := 'S'
	Private cFormNova   := ""
	//Verifica se o DPR esta integrado 
	If SuperGetMv("MV_INTDPR",.f.,"") <> 1
		Help( ,, 'Help',,STR0022, 1, 0 ) //"O parâmetro 'MV_INTDPR' deverá ser igual a 1!"
		Return Nil
	EndIf
	If !SuperGetMv("MV_DPRFICH",.f.,"")
		Help( ,, 'Help',,STR0023, 1, 0 ) //"O parâmetro 'MV_DPRFICH' deverá ser igual a '.t.'!"
		Return Nil
	EndIf
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DGN')
	oBrowse:SetMenuDef("DPRA210") // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription( STR0001 ) //"Ficha Técnica"
	If FunName() == 'DPRA100'
	     oBrowse:SetFilterDefault( "DGN_CDACDV == '" + DG3->DG3_CDACDV + "' .AND. Empty(DGN->DGN_NRVRAC)" )
	ElseIf FunName() == 'DPRA300'
	     oBrowse:SetFilterDefault( "DGN_CDACDV == '" + DG0->DG0_CDACDV + "' .AND. (DGN->DGN_NRVRAC == '" + DG0->DG0_NRVRAC + "' .OR. Empty(DGN->DGN_NRVRAC))")
	EndIf
	oBrowse:Activate()
Return NIL

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de Operações MVC

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRA210' OPERATION 2 ACCESS 0  //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.DPRA210' OPERATION 3 ACCESS 0  //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.DPRA210' OPERATION 4 ACCESS 0  //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.DPRA210' OPERATION 5 ACCESS 0  //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.DPRA210' OPERATION 8 ACCESS 0  //"Imprimir"
	//ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.DPRA210' OPERATION 9 ACCESS 0  //"Copiar"
	//ADD OPTION aRotina TITLE 'Tornar Padrão'     ACTION 'DPRA210PAD' OPERATION 9 ACCESS 0  // 'Copiar'
	ADD OPTION aRotina TITLE STR0018 ACTION 'PCPA101' OPERATION 9 ACCESS 0  //"Atributo"
	ADD OPTION aRotina TITLE STR0019 ACTION 'PCPA102' OPERATION 9 ACCESS 0  //"Template"
	ADD OPTION aRotina TITLE STR0020 ACTION 'PCPA103' OPERATION 9 ACCESS 0  //"Alocação Template"
	ADD OPTION aRotina TITLE STR0021 ACTION 'PCPA104' OPERATION 9 ACCESS 0  //"Ficha Família Técnica"
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructDGN := FWFormStruct( 1, 'DGN', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStructDGO := FWFormStruct( 1, 'DGO', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel := MPFormModel():New('DPRA210', /*bPreValidacao*/, {|oModel| VldOk210(oModel) }, /*bCommit*/, /*bCancel*/ )
	//Adiciona a validação ao campo VLCH
	oStructDGO:SetProperty('DGO_VLCH',MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "DPRA210VCH()"))

	//Ao alterar o produto desenvolvido, limpa o campo de versão
	oStructDGN:AddTrigger( ;
		"DGN_CDACDV",	;
		"DGN_NRVRAC",	;
		{ || .T. },	;
		{ || "" };
	)
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'DGNMASTER', /*cOwner*/, oStructDGN, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	oModel:SetPrimaryKey({ "DGN_FILIAL", "DGN_CDACDV", "DGN_NRVRAC", "DGN_CDMQ", "DGN_CDMD" })
	//DGN_FILIAL+DGN_CDACDV+DGN_NRVRAC+DGN_CDMQ+DGN_CDMD
	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'DGODETAIL', 'DGNMASTER', oStructDGO, , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'DGODETAIL', { { 'DGO_FILIAL', 'xFilial( "DGO" )' }, { 'DGO_CDMQ', 'DGN_CDMQ' }, { 'DGO_CDACDV', 'DGN_CDACDV' },{ 'DGO_NRVRAC', 'DGN_NRVRAC' },{ 'DGO_CDMD', 'DGN_CDMD' } }, DGO->( IndexKey(1)) )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'DGODETAIL' ):SetUniqueLine( { 'DGO_CDAB'  } )

	oModel:GetModel( 'DGNMASTER' ):SetDescription( STR0009 ) //"Dados da ficha técnica"
	oModel:GetModel( 'DGODETAIL' ):SetDescription( STR0010 ) //"Dados dos atributos"

	// Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'DGODETAIL' ):SetOptional(.T.)

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0001 ) //"Ficha Técnica"

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'DGNMASTER' ):SetDescription( STR0001 ) //"Ficha Técnica"

	// Valida se a hora estará disponível para alteração
	oModel:SetVldActivate( { |oModel|  AbreTela( oModel ) } )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel     := FWLoadModel( 'DPRA210' )
	// Cria a estrutura a ser usada na View
	Local oStructDGN := FWFormStruct( 2, 'DGN' )
	Local oStructDGO := FWFormStruct( 2, 'DGO' )

	lEntrou := .f.

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_DGN', oStructDGN, 'DGNMASTER' )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_DGO', oStructDGO, 'DGODETAIL' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 30 )
	oView:CreateHorizontalBox( 'INFERIOR', 70 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_DGN', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_DGO', 'INFERIOR' )

	oStructDGO:RemoveField("DGO_CDMQ")
	oStructDGO:RemoveField("DGO_CDACDV")
	oStructDGO:RemoveField("DGO_NRVRAC")
	oStructDGO:RemoveField("DGO_CDMD")

	oModel:GetModel('DGODETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('DGODETAIL'):SetNoDeleteLine(.T.)

	oView:SetFieldAction( 'DGN_CDMD', { |oView, cIDView, cField, xValue| flAction( oView, cIDView, cField, xValue ) } )

Return oView

Static Function flAction(oView, cIDView, cField, xValue)
	cAbreTela := 'S'
	cExecVald := 'S'
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210TEM
Função que carrega os atributos referentes ao Template selecionado.

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210TEM()
	Local cQuery		:= ""
	Local aArea		:= GetArea()
	Local cAlias		:= GetNextAlias()
	Local cTemplate	:= M->DGN_CDMD
	Local nI			:= 1
	Local kI			:= 1
	Local jI			:= 1
	Local cDTpAtrib	:= ""
	Local oModel		:= FWModelActive()
	Local oModelDGO	:= oModel:GetModel('DGODETAIL')
	Local iTam			:= ""
	Local iTamHeader	:= ""
	Local cValorPadrao:=""
	Local cAtributo	:= ""
	Local cValor		:= ""
	Local lRet			:= .T.

	cAbreTela := "N"
	cExecVald := 'N'
	oModel	       := FWModelActive()
	oModel:GetModel('DGODETAIL'):SetNoInsertLine(.F.)
	oModel:GetModel('DGODETAIL'):SetNoDeletetLine(.F.)

	iTam          := LEN(oModel:GetModel('DGODETAIL'):ADATAMODEL)
	iTamHeader    := LEN(oModel:GetModel('DGODETAIL'):AHEADER)

	//Limpar a linha do grid
	If iTam > 0
		For kI := 1 To iTam
			If kI > 1  //apaga a partir da segunda linha
				oModel:GetModel('DGODETAIL'):GoLine( kI )
				oModel:GetModel('DGODETAIL'):DeleteLine()
			Else
				For jI := 1 To iTamHeader   // limpa a primeira linha do grid
					oModel:GetModel('DGODETAIL'):GoLine(kI)
					oModel:ClearField('DGODETAIL',oModel:GetModel('DGODETAIL'):AHEADER[jI][2])
				Next jI
			EndIf
		Next kI
	EndIf

	oModel:GetModel('DGODETAIL'):GoLine(1)

	cQuery := " SELECT CZE.CZE_CDAB, CZE.CZE_LGOB, CZB.CZB_DSAB, CZB.CZB_TPAB, CZB.CZB_VLPAAB, CZB.CZB_NMAB, CZB.CZB_TPTB "

	cQuery += " FROM " + RetSqlName('CZE') + " CZE "
	cQuery += " LEFT JOIN " + RetSqlName( "CZB" ) + " CZB ON ( CZB.CZB_FILIAL = '" + xFilial( "CZB" ) + "' AND CZB.CZB_CDAB = CZE.CZE_CDAB AND CZB.D_E_L_E_T_ = '' ) "

	cQuery += " WHERE CZE.CZE_CDMD= '" + cTemplate + "' "
	cQuery += " AND CZE.CZE_FILIAL = '" + xFilial("CZE") + "' "
	cQuery += " AND CZE.D_E_L_E_T_ = '' "

	cQuery += " ORDER BY 1"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
	DbSelectArea( cAlias )

	While ((cAlias)->(!Eof() ))

		If nI != 1
			While ((iTam > 1) .And. (nI <= iTam))
				If oModel:GetModel('DGODETAIL'):IsDeleted(nI)
				 nI++
				EndIf
			EndDo
			oModel:GetModel('DGODETAIL'):AddLine()
			oModel:GetModel('DGODETAIL'):GoLine( nI )
		EndIf

		oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_CDAB', MODEL_FIELD_WHEN, { || .t. } )
		oModel:GetModel('DGODETAIL'):SetValue('DGO_CDAB' ,(cAlias)->(CZE_CDAB))
		oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_CDAB', MODEL_FIELD_WHEN, { || .f. } )

		oModel:GetModel('DGODETAIL'):SetValue('DGO_NMAB' ,(cAlias)->(CZB_NMAB))

		oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_LGOB', MODEL_FIELD_WHEN, { || .T. } )
		oModel:GetModel('DGODETAIL'):SetValue('DGO_LGOB' ,(cAlias)->(CZE_LGOB))
		oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_LGOB', MODEL_FIELD_WHEN, { || .F. } )
		cTpAtrib := (cAlias)->(CZB_TPAB)
		cValorPadrao := ""

		//oModel:GetModel('DGODETAIL'):SetValue('DGO_TPAB' ,cTpAtrib)

		If cTpAtrib != "F"
			oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLFG', MODEL_FIELD_WHEN, { || .t. } )
			oModel:GetModel('DGODETAIL'):SetValue('DGO_VLFG', '0')
			oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLFG', MODEL_FIELD_WHEN, { || DPRA210WHN('F') } )
		EndIf

		Do Case
			Case cTpAtrib == "F"
				If (AllTrim((cAlias)->(CZB_VLPAAB)) == '1')
					oModel:GetModel('DGODETAIL'):SetValue('DGO_VLFG', '1')
				Else
					oModel:GetModel('DGODETAIL'):SetValue('DGO_VLFG', '0')
				EndIf

			Case cTpAtrib == "C"
				oModel:GetModel('DGODETAIL'):SetValue('DGO_VLCH', (cAlias)->(CZB_VLPAAB))

			Case cTpAtrib == "N"
				oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || .t. } )
				oModel:GetModel('DGODETAIL'):SetValue('DGO_VLNR', val(strtran((cAlias)->(CZB_VLPAAB), ",", ".")) )
				oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || DPRA210WHN('N') } )

			Case cTpAtrib == "D"
			    cValorPadrao := StoD(Right( AllTrim((cAlias)->(CZB_VLPAAB)) , 4 ) + SubStr( AllTrim((cAlias)->(CZB_VLPAAB)) , 4, 2 ) + Left( AllTrim((cAlias)->(CZB_VLPAAB)) , 2 ))
	 			 oModel:GetModel('DGODETAIL'):SetValue('DGO_VLDT', cValorPadrao)

			Case cTpAtrib == "L"
 				oModel:GetModel('DGODETAIL'):SetValue('DGO_VLTB', SubStr((cAlias)->(CZB_VLPAAB),1,20))
				If ((cAlias)->(CZB_TPTB) == '2') //lista composta
		     		cValorPadrao	:= AllTrim((cAlias)->(CZB_VLPAAB))
		     		cAtributo		:= AllTrim((cAlias)->(CZE_CDAB))
					aArea			:= GetArea()
					DbSelectArea("CZC")
					CZC->(dbSetOrder(2))
					CZC->(dbSeek(xFilial("CZC") +  cAtributo +  cValorPadrao))
			    	oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || .t. } )
			    	//Somente seta o valor se o valor padrão for informado
					If AllTrim(cValorPadrao) != ""
						oModel:GetModel('DGODETAIL'):LoadValue('DGO_VLNR', val(strtran(CZC->CZC_VLTB, ",", ".")) )
					EndIf
					oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || DPRA210WHN('N') } )
					RestArea(aArea)
				EndIf

	 		Case cTpAtrib == "A"
		   		oModel:GetModel('DGODETAIL'):SetValue('DGO_VLFX', val(strtran(CZB_VLPAAB, ",", ".")) )

			Case cTpAtrib == "M"
				oModel:GetModel('DGODETAIL'):SetValue('DGO_VLNV', (cAlias)->(CZB_VLPAAB))

			Case cTpAtrib == "R"
				oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLFO', MODEL_FIELD_WHEN, { || .t. } )
				oModel:GetModel('DGODETAIL'):SetValue('DGO_VLFO', (cAlias)->(CZB_VLPAAB) )
				oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLFO', MODEL_FIELD_WHEN, { || .f. } )
				cValorPadrao := validForm((cAlias)->(CZB_VLPAAB))
				cValorPadrao := StrTran(cValorPadrao,",", ".")
				oModel:GetModel('DGODETAIL'):GoLine( nI )
				oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || .t. } )
		  		oModel:GetModel('DGODETAIL'):SetValue('DGO_VLNR', &(cValorPadrao))
 			    oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || DPRA210WHN('N') } )
	         	cFormNova := ""

			Case cTpAtrib == "O"
				oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || .t. } )
				oModel:GetModel('DGODETAIL'):SetValue('DGO_VLNR', val(strtran((cAlias)->(CZB_VLPAAB), ",", ".")) )
				oModel:GetModel('DGODETAIL'):GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || DPRA210WHN('N') } )
		EndCase

		nI++
		(cAlias)->(DbSkip())

	End

	oModel:GetModel('DGODETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('DGODETAIL'):SetNoDeletetLine(.T.)
	oModel:GetModel('DGODETAIL'):GoLine(1)
Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210VTP
Função chamada no X3_VALID do campo de Template

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210VTP()
	Local lRet := .t.
	Local aOldArea := GetArea()

	If !ExistCpo('CZD',M->DGN_CDMD)
		lRet := .f.
	Else
		If !PCPA104FIL(.f.)
			Help( ,, 'Help',,STR0024, 1, 0 ) //"O Template selecionado é inválido!"
			lRet := .f.
		Else
			If !VldAprvLib()
				lRet := .f.
			Else
				If !DPRA210CLT()
					lRet := .f.
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aOldArea)

	If lRet
		cDGNCDMD := M->DGN_CDMD
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210CLT
Verifica se algum campo da chave do template foi alterado

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210CLT()
	Local lRet       := .t.
	Local lCheckGetD := .f.
	Local oModel     := FWModelActive()
	Local oModelDGO  := oModel:GetModel("DGODETAIL")
	Local oModelDGN  := oModel:GetModel("DGNMASTER")

	If cDGNCDACDV <> M->DGN_CDACDV
		lCheckGetD := .t.
	ElseIf cDGNCDMQ <> M->DGN_CDMQ
		lCheckGetD := .t.
	ElseIf cDGNCDMD <> M->DGN_CDMD
		lCheckGetD := .t.
	EndIf

	If lCheckGetD
		If (oModelDGO:GetQtdLine() = 1 .And. Empty(oModelDGO:GetValue('DGO_CDAB')) .And. ReadVar() == 'M->DGN_CDMD' )
			DPRA210TEM()
		Else
			If ReadVar() <> 'M->DGN_CDMD'
				oModelDGN:SetValue('DGN_CDMD',Space(Len(DGN->DGN_CDMD)))
			EndIf
			If !Empty(oModelDGN:GetValue('DGN_CDMD')) .AND. ((oModelDGO:GetQtdLine() > 1) .Or. (oModelDGO:GetQtdLine() = 1 .And. !Empty(oModelDGO:GetValue('DGO_CDAB'))))
				If !MsgYesNo(STR0041,STR0042) //"Ao alterar esse conteúdo todos os atributos que já foram preenchidos serão perdidos. Deseja prosseguir?"##"Atenção"
					lRet := .f.
				Else
					DPRA210TEM()
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		cDGNCDACDV := M->DGN_CDACDV
		cDGNCDMQ   := M->DGN_CDMQ
		cDGNCDMD   := M->DGN_CDMD
	EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210WHN
Função chamada no X3_WHEN dos campos de valores

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210WHN(lTpCampo)
	Local lRet			:= .T.
	Local cTpAtrib		:= ''
	Local aOldArea		:= GetArea()
	Local oModel		:= FWModelActive()
	Local oModelDGO	:= oModel:GetModel('DGODETAIL')

	oModelDGO:GoLine(oModelDGO:GetLine())
	dbSelectArea("CZB")
	CZB->(dbSetOrder(1))
	If CZB->(dbSeek(xFilial("CZB") + (AllTrim(oModelDGO:GetValue('DGO_CDAB')))))
		cTpAtrib := CZB->CZB_TPAB
	EndIf

	If lTpCampo == 'N'
		If cTpAtrib <> 'N' .AND. cTpAtrib <> 'O' //.AND. cTpAtrib <> 'R' //.AND. cTpAtrib <> 'L'
			lRet := .F.
		EndIf
	Else
		If lTpCampo <> cTpAtrib
			lRet := .F.
		ElseIf cTpAtrib == 'A' .And. !lEnd
			If !lEntrou
	   			If IsInCallStack('DPRA210') .AND. cAbreTela == "S"
	   				TelaFaixa()
	   			EndIf
	   			lEntrou := .T.
		   	Else
		   		lEntrou := .F.
		   	EndIf
			lEnd := .F.
		EndIf
	EndIf
	RestArea(aOldArea)
Return lRet
//-------------------------------------------------------------------
Static Function ValidTemp(cProduto,cVersao,cRecurso)
	Local lRet := .T.
	If !Empty(cRecurso)
		lRet := .F.
		dbSelectArea("DG9")
		If DG9->(dbSeek(xFilial("DG9")+cProduto+cVersao))
			While !DG9->(Eof()) .And. xFilial("DG9")+cProduto+cVersao == DG9->(DG9_FILIAL+DG9_CDACDV+DG9_NRVRAC)
				If AllTrim(cRecurso) == AllTrim(DG9->DG9_CDMQ)
					Return .T.
				EndIf
				DG9->(dbSkip())
			End
		EndIf
	EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} VldOk210
Validação do botão Confirmar

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldOk210(oModel)
	Local nI, nX
	Local oModelDGN	:= oModel:GetModel('DGNMASTER')
	Local oModelDGO	:= oModel:GetModel('DGODETAIL')
	Local aColsDGO	:= {}
	
	If Empty(oModelDGN:GetValue("DGN_NRVRAC")) .And. !Empty(oModelDGN:GetValue("DGN_CDMQ"))
		Help( ,, 'DPRA210',,STR0048, 1, 0 ) //"É necessário selecionar uma versão do produto."
		Return .F.
	ElseIf !ValidTemp(oModelDGN:GetValue("DGN_CDACDV"),oModelDGN:GetValue("DGN_NRVRAC"),oModelDGN:GetValue("DGN_CDMQ"))
		Help( ,, 'DPRA210',,STR0049, 1, 0 ) //"O recurso selecionado precisa estar alocado em alguma das operações da versão do produto."
		Return .F.
	EndIf

	If oModel:GetOperation() == 3 .AND. !EXISTCHAV("DGN",M->DGN_CDACDV+M->DGN_NRVRAC+M->DGN_CDMQ+M->DGN_CDMD)
		Return .f.
	EndIf

	If !VldAprvLib()
		Return .f.
	EndIf

	Aadd(aColsDGO,{'F',{'DGO_VLFG'}})
	Aadd(aColsDGO,{'N',{'DGO_VLNR'}})
	Aadd(aColsDGO,{'O',{'DGO_VLNR'}})
	Aadd(aColsDGO,{'D',{'DGO_VLDT'}})
	Aadd(aColsDGO,{'L',{'DGO_VLTB'}})
	Aadd(aColsDGO,{'A',{'DGO_VLFX'}})
	Aadd(aColsDGO,{'T',{'DGO_VLTBSI'}})
	Aadd(aColsDGO,{'I',{'DGO_BITMAP'}})
	Aadd(aColsDGO,{'C',{'DGO_VLCH'}})
	Aadd(aColsDGO,{'R',{'DGO_VLFO'}})
	Aadd(aColsDGO,{'M',{'DGO_VLNV'}})

	For nI := 1 to oModelDGO:GetQtdLine()

		oModelDGO:GoLine(nI)
		If !Empty(oModelDGO:GetValue("DGO_CDAB")) .AND. !oModelDGO:IsDeleted()

			If oModelDGO:GetValue('DGO_LGOB') == '1' //Se for obrigatorio verifica se o campo referente esta preenchido

				DbSelectArea("CZB")
				CZB->(dbSetOrder(1))
				CZB->(dbSeek(xFilial("CZB") + (AllTrim(oModelDGO:GetValue('DGO_CDAB')))))
				nScan := aSCAN(aColsDGO, {|x| AllTrim(Upper(x[1])) == CZB->CZB_TPAB })

				For nX := 1 to Len(aColsDGO[nScan][2])
					If Empty(oModelDGO:GetValue(aColsDGO[nScan][2][nX]))
						Help( ,, 'Help',,STR0025+AllTrim(oModelDGO:GetValue('DGO_NMAB'))+STR0026, 1, 0 ) //"O atributo "###" deverá ser preenchido!"
						oModelDGO:GoLine(nI)
						Return .f.
					EndIf
				Next
			EndIf
		EndIf
	Next
Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldAprvLib
Verifica se o Produto/Versão já foi aprovado ou liberado.

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldAprvLib()
Local oModel		:= FWModelActive()
Local nOperation	:= oModel:GetOperation()

If FunName() <> "DPRA342"
	If nOperation == 3
		dbSelectArea("DG0")
		DG0->(dbSetOrder(1))
		If DG0->(dbSeek(xFilial('DG0')+M->DGN_CDACDV+M->DGN_NRVRAC)) .AND. Val(DG0->DG0_TPST) >= 3
			Help( ,, 'Help',,STR0039, 1, 0 ) //"O registro não pode ser incluído para o produto/versão pois já foi aprovado ou liberado!"
			Return .f.
		EndIf
	EndIf
EndIf

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210REL
Função chamada no X3_RELACAO do campo DGO_LGOB

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210REL()
Local aOldArea := GetArea()
Local cConteudo := ' '

dbSelectArea('CZE')
CZE->(dbSetOrder(1))
If CZE->(dbSeek(xFilial('CZE')+DGO->DGO_CDMD+DGO->DGO_CDAB))
	cConteudo := CZE->CZE_LGOB
EndIf

RestArea(aOldArea)

Return cConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} AbreTela
Função disparada antes de abrir a tela.

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AbreTela(oModel)
Local lRet := .t.
Local nOperation := oModel:GetOperation()

If nOperation == 4 .Or. nOperation == 5
	If !IsInCallStack('DPRA342')
		dbSelectArea("DG0")
		DG0->(dbSetOrder(1))
		If DG0->(dbSeek(xFilial('DG0')+DGN->DGN_CDACDV+DGN->DGN_NRVRAC)) .AND. Val(DG0->DG0_TPST) >= 3
			Help( ,, 'Help',,STR0040, 1, 0 ) //"O registro não pode ser alterado/excluído para o produto/versão pois já foi aprovado ou liberado!"
			lRet := .F.
		EndIf
	EndIf
ElseIf nOperation == 3
	cDGNCDACDV := Space(Len(DGN->DGN_CDACDV))
	cDGNCDMQ   := Space(Len(DGN->DGN_CDMQ))
	cDGNCDMD   := Space(Len(DGN->DGN_CDMD))
EndIf

If lRet
	DPRA210LOA(.f.)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210LOA
Carrega o array [aTemplates] que irá conter todos os Templates que poderão ser selecionados.

@param lSx3 Indica se a função é chamada pelo dicionário (.T) ou programa (.F.)

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210LOA(lSx3)
Local lTipo, lGrupo
Local aOldArea := GetArea()
Default lSx3 := .t.

Store '' to lTipo,lGrupo

If lSx3
	If !DPRA210CLT()
		Return .f.
	EndIf
	lDGNCDACDV := M->DGN_CDACDV
	lDGNCDMQ   := M->DGN_CDMQ
Else
	lDGNCDACDV := DGN->DGN_CDACDV
	lDGNCDMQ   := DGN->DGN_CDMQ
EndIf

If lSx3
	cDGNCDACDV := lDGNCDACDV
	cDGNCDMQ   := lDGNCDMQ
EndIf

dbSelectArea('DG3')
DG3->(dbSetOrder(1))
If DG3->(dbSeek(xFilial('DG3')+lDGNCDACDV))
	lTipo  := SubStr(AllTrim(DG3->DG3_CDFA),1,2)
	lGrupo := DG3->DG3_CDGE
EndIf

aTemplates := PCPA104CTP(lTipo,lGrupo,lDGNCDMQ)

RestArea(aOldArea)

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} TelaFaixa
Tela para cadastrar o valor da faixa

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TelaFaixa()
Local oModel	   := FWModelActive()
Local oModelDGO := oModel:GetModel('DGODETAIL')
Local oDlg                  	//Objeto Janela
Default lAutomacao := .F.

Store 0 to nVlIniFx, nVlFinFx, nVlFaixa

DbSelectArea("CZB")
CZB->(dbSetOrder(1))
If CZB->(dbSeek(xFilial("CZB") + (AllTrim(oModelDGO:GetValue('DGO_CDAB')))))
	nVlIniFx := CZB->CZB_VLBGFX
	nVlFinFx := CZB->CZB_VLEDFX
EndIf
nVlFaixa := oModelDGO:GetValue('DGO_VLFX')

If !lAutomacao
	DEFINE MSDIALOG oDlg TITLE STR0030 FROM 0,0 TO 200,460 PIXEL //"Informe a Faixa"

	@ 010,010 SAY STR0027 SIZE 60, 7 OF oDlg PIXEL  //"Limite Faixa Inferior"
	@ 010,130 MSGET nVlIniFx SIZE 50,11 OF oDlg PIXEL WHEN .F.
	@ 030,010 SAY STR0028 SIZE 60, 7 OF oDlg PIXEL  //"Valor da Faixa"
	@ 030,130 MSGET nVlFaixa SIZE 50,08 OF oDlg PIXEL Valid ValidValor(nVlIniFx, nVlFinFx, nVlFaixa,oModelDGO:GetValue('DGO_CDAB')) Picture '@E 999,999,999.9999' HASBUTTON
	@ 050,010 SAY STR0029 SIZE 60, 7 OF oDlg PIXEL  //"Limite Faixa Superior"
	@ 050,130 MSGET nVlFinFx SIZE 50,11 OF oDlg PIXEL WHEN .F.

	DEFINE SBUTTON FROM 72,153 TYPE 1 ACTION ( eventBtn(@oDlg,@oModelDGO)) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} eventBtn
Funcao de Evento do Botao da Faixa

@param oDlg Indica o objeto Dialog no qual foi criada a tela.
@param oModelDGO Indica o Model no qual está inserida a grid.

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function eventBtn(oDlg,oModelDGO)
Local oView
Local oModel

lEnd := oDlg:End()
oView := FWViewActive()
oModel := FwModelActive()
//oModelDGO:LoadValue('DGO_VLFX',nVlFaixa)
oModel:GetModel('DGODETAIL'):LoadValue('DGO_VLFX',nVlFaixa)
M->DGO_VLFX := nVlFaixa
oView:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaValor
Funcao de validacao do valor

@param nVlIniFx Valor inicial da Faixa.
@param nVlFinFx Valor final da Faixa.
@param nVlFaixa Valor informado pelo usuário.

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidValor(nVlIniFx, nVlFinFx, nVlFaixa, cCDAB)

If empty(nVlIniFx) .OR. empty(nVlFinFx)
	DbSelectArea("CZB")
	CZB->(dbSetOrder(1))
	If CZB->(dbSeek(xFilial("CZB") + ( AllTrim( cCDAB ) )))
		nVlIniFx := CZB->CZB_VLBGFX
		nVlFinFx := CZB->CZB_VLEDFX
	EndIf
EndIf
If !empty(nVlFaixa)
	If (nVlFaixa < nVlIniFx)
		Alert(STR0031)//"Valor deve ser maior ou igual o valor inicial da faixa."
		Return .F.
	EndIf

	If (nVlFaixa > nVlFinFx)
		Alert(STR0032)//"Valor deve ser menor ou igual o valor final da faixa."
		Return .F.
	EndIf
EndIf
Return  .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210VLL
Consulta padrão específica - valor e conteudo da lista

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210VLL()
Local oMdl      := FWModelActive()
Local oModelDGO := oMdl:GetModel('DGODETAIL')
Local aCpos     := {}      	//Array com os dados
Local aRet      := {}       	//Array do retorno da opcao selecionada
Local oDlg                  	//Objeto Janela
Local oLbx                  	//Objeto List box
Local cNoCpos 	:= ""
Local lRet    	:= .F.
Local nI		:= 0
Local aDadosCZC := {}
Local cConteudo := ""
Local cValor    := ""
Local oView := NIL

//=====================================================
// Carrega o vetor com as opções cadastradas
//=====================================================
DbSelectArea("CZC")
CZC->(dbSetOrder(1))
CZC->(dbSeek(xFilial("CZC") + (AllTrim(oModelDGO:GetValue('DGO_CDAB')))))
While ((!CZC->(Eof())) .And. (CZC->CZC_CDAB == AllTrim(oModelDGO:GetValue('DGO_CDAB'))))
	aAdd( aCpos, { CZC->CZC_NMTB, CZC->CZC_VLTB } )
	CZC->(DbSkip())
EndDo

If Len( aCpos ) > 0

    DEFINE MSDIALOG oDlg TITLE STR0033 FROM 0,0 TO 240,500 PIXEL //"Tabela"

       @ 10,10 LISTBOX oLbx FIELDS HEADER STR0034,STR0035 SIZE 230,95 OF oDlg PIXEL //"Conteúdo"##"Valor"

       oLbx:SetArray( aCpos )
       oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
       oLbx:bLDblClick := {|| {oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

    DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
    ACTIVATE MSDIALOG oDlg CENTER

    If Len(aRet) > 0
        lRet 		:= .T.
        cConteudo  := aRet[1]
        cValor     := aRet[2]
        oView      := FWViewActive()
        oModelDGO:GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || .t. } )
        oModelDGO:SetValue('DGO_VLTB',cConteudo)
        oModelDGO:LoadValue('DGO_VLNR', val(cValor))
        oModelDGO:GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || DPRA210WHN('N') } )
        oview:Refresh("VIEW_DGO")
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210TAB
Consulta padrão específica - tabelas do sistema (SX2)

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210TAB()
Local lRet
Local oModel     := FWModelActive()
Local oModelDGO  := oModel:GetModel('DGODETAIL')
Local cVLTB    := oModelDGO:GetValue('DGO_VLTBSI')
Local aRet := {}

aRet  := DPRA210CTA()
lRet  := aRet[1]
cVLTB := aRet[2]

If lRet
	oModel     := FWModelActive()
	oModelDGO  := oModel:GetModel('DGODETAIL')
	oModelDGO:SetValue('DGO_VLTBSI',AllTrim(cVLTB))
EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210CTA
Consulta padrão específica - tabelas do sistema (SX2)

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210CTA()
Local oMdl   	:= FWModelActive()
Local oModelDGO 	:= oMdl:GetModel('DGODETAIL')
Local aCpos   	:= {}      		//Array com os dados
Local aRet    	:= {}       	//Array do retorno da opcao selecionada
Local oDlg                  	//Objeto Janela
Local oLbx                  	//Objeto List box
Local cNoCpos 	:= ""
Local lRet    	:= .F.
Local cVlAtr   := ""
Local cCampo   := ""
Local cDescricao := ""
Local cVlTb := ""
Default lAutomacao := .F.
//=======================
// Procurar campo na CDB
//=======================
DbSelectArea("CZB")
CZB->(dbSetOrder(1))
CZB->(dbSeek(xFilial("CZB") + (AllTrim(oModelDGO:GetValue('DGO_CDAB')))))

cVlAtr 	  := AllTrim(CZB->CZB_VLPAAB)
cCampo 	  := AllTrim(CZB->CZB_IDCDG)
cDescricao := AllTrim(CZB->CZB_IDDS)

If !lAutomacao
	dbSelectArea(cVlAtr)
	dbSetOrder(1)
	&(cVlAtr)->(dbGoTop())

	//=====================================================
	// Carrega o vetor com as tabelas do sistema
	//=====================================================
	While !&(cVlAtr)->(Eof())
	aAdd( aCpos, { &(cVlAtr+'->'+cCampo), &(cVlAtr+'->'+cDescricao) } )
		&(cVlAtr)->(DbSkip())
	Enddo
EndIf

If Len( aCpos ) > 0

	DEFINE MSDIALOG oDlg TITLE STR0033 FROM 0,0 TO 240,500 PIXEL //"Tabela"
	@ 10,10 LISTBOX oLbx FIELDS HEADER STR0036, STR0037 SIZE 230,95 OF oDlg PIXEL //"Código"##"Descrição"

	oLbx:SetArray( aCpos )
	oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
	oLbx:bLDblClick := {|| {oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER

	If Len(aRet) > 0
		lRet := .T.
		cVlTb := AllTrim(aret[1])
	EndIf
Else
	Help( ,, 'Help',,STR0043+ cVlAtr, 1, 0 ) //"Não existem dados na tabela "
EndIf

Return {lRet,cVlTb}

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210VNU
Função de validação do campo Caracter

@param
@return

@author  Ezequiel Marques Ramos
@since   28/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210VCH()
	Local aOldArea		:= GetArea()
	Local lRet			:= .T.
	Local oMdl			:= FWModelActive()
	Local oModelDGO	:= oMdl:GetModel('DGODETAIL')

	DbSelectArea( "CZB" )
	CZB->(dbSetOrder(1))
	CZB->(dbSeek(xFilial("CZB") + oModelDGO:GetValue('DGO_CDAB')))

	If (Len(AllTrim(oModelDGO:GetValue('DGO_VLCH'))) > CZB->CZB_TMAB)
		Help( ,, 'Help',, STR0046, 1, 0 ) //"Tamanho não compatível com tamanho informado para atributo."
		lRet := .F.
	Endif

	RestArea(aOldArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210VNU
Função de validação do campo Valor Numerico

@param
@return

@author  Lucas Konrad França
@since   02/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210VNU()
	Local oModel		:= FwModelActive()
	Local oModelDet	:= oModel:GetModel('DGODETAIL')
	Local nResult		:= 0
	Local aOldArea		:= GetArea()
	Local oView		:= FwViewActive()
	Local nLinha		:= oModelDet:GetLine()
	Local nPonto		:= 0
	Local cFormato		:= " ( "
	Local aAreaCZB		:= {}
	Local cValPad
	Local nI
	Local cValorInt
	Local cValorDec
	Default lAutomacao := .F.

	DbSelectArea( "CZB" )
	CZB->(dbSetOrder(1))
	CZB->(dbSeek(xFilial("CZB") + oModelDet:GetValue('DGO_CDAB')))
	aAreaCZB := CZB->(GetArea())

	If cExecVald = 'N'
		Return .T.
	EndIf
	If (CZB->CZB_TPAB == 'R' .Or. ;
	    CZB->CZB_TPAB == 'L' .Or. ;
	    CZB->CZB_TPAB == 'A')
		Return .T.
	EndIf
	For nI := 1 To oModelDet:GetQtdLine()
		oModelDet:GoLine(nI)
		CZB->(dbSeek(xFilial("CZB") + oModelDet:GetValue('DGO_CDAB')))
		If AllTrim(CZB->CZB_TPAB) == 'R'
			cValPad := validForm(oModelDet:GetValue('DGO_VLFO'))
			cValPad := StrTran(cValPad,",", ".")
			//Se não houver nenhum valor recebe 0
			If AllTrim(cValPad) == ""
				cValPad := 0
			EndIf
			oModelDet:GoLine(nI)
			nResult := &(cValPad)
			oModelDet:GoLine(nI)
			oModelDet:GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || .t. } )
			oModelDet:LoadValue('DGO_VLNR', nResult)
			oModelDet:GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || DPRA210WHN('N') } )
			cFormNova := ""
		EndIf
	Next
	oModelDet:GoLine(nLinha)
	CZB->(RestArea(aAreaCZB))

	cValor := cValtoChar(M->DGO_VLNR)

	For nI := 1 To Len(cValor)
		If Substr(cValor,nI,1) == "."
			nPonto := nI
		EndIf
	Next

	If nPonto != 0
		cValorInt := SubStr(cValtoChar(M->DGO_VLNR),1,(nPonto-1))
		cValorDec := SubStr(cValtoChar(M->DGO_VLNR),(nPonto+1))

		If cValorInt == "0"
			cValorInt := ""
		EndIf

	Else
		cValorInt := cValtoChar(M->DGO_VLNR)
		cValorDec := ""
	EndIf
	//Verifica se possuirá valor decimal
	If CZB->CZB_VLPRC == 0
		If ((Len(cValorInt) > CZB->CZB_TMAB) .OR. (Len(cValorDec) > CZB->CZB_VLPRC))
			//Monta string com o formato necessário
			For nI := 1 To CZB->CZB_TMAB
				cFormato += "9"
			Next
			//Finaliza com um parenteses
			cFormato += " )"
			Help( ,, 'Help',, STR0046+cFormato, 1, 0 ) //"Tamanho não compatível com tamanho informado para atributo."
			lRet := .F.
			Return lRet
		Endif
	Else
		//Monta string com o formato necessário, se não houver números inteiros insere um zero
		If (CZB->CZB_TMAB - CZB->CZB_VLPRC - 1) != 0
			For nI := 1 To (CZB->CZB_TMAB - CZB->CZB_VLPRC - 1)
				cFormato += "9"
			Next
		EndIf
		//Coloca uma virgula
		cFormato += ","
		//Insere os decimais
		For nI := 1 To CZB->CZB_VLPRC
			cFormato += "9"
		Next
		//Finaliza com um parenteses
		cFormato += " )"
		If ((Len(cValorInt) > CZB->CZB_TMAB - CZB->CZB_VLPRC - 1) .OR. (Len(cValorDec) > CZB->CZB_VLPRC))
			Help( ,, 'Help',, STR0046+cFormato, 1, 0 ) //"Tamanho não compatível com tamanho informado para atributo."
			lRet := .F.
			Return lRet
		Endif
	EndIf


RestArea(aOldArea)

If !lAutomacao
	oView:Refresh()
EndIf

Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} DPRA210VLD
Validações dos campos da GetDados

@param cCampoDGO Campo que será validado.

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function DPRA210VLD(cCampoDGO)
Local lRet := .t.
Local cTab := '   ',cTabAux,cCampo := ''
Local aOldArea := GetArea()
Local oModel    := FWModelActive()
Local oModelDGO := oModel:GetModel('DGODETAIL')

If cCampoDGO == 'DGO_VLTB'
	If !ExistCpo('CZC',oModelDGO:GetValue("DGO_CDAB")+oModelDGO:GetValue("DGO_VLTB"),2)
		lRet := .f.
	Else
		DbSelectArea('CZC')
		CZC->(dbSetOrder(2))
		CZC->(dbSeek(xFilial('CZC') + oModelDGO:GetValue("DGO_CDAB")+oModelDGO:GetValue("DGO_VLTB")))

		oModelDGO:GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || .t. } )
		oModelDGO:LoadValue('DGO_VLNR',Val(CZC->CZC_VLTB))
		oModelDGO:GetStruct():SetProperty('DGO_VLNR', MODEL_FIELD_WHEN, { || DPRA210WHN('N') } )
	EndIf
ElseIf cCampoDGO == 'DGO_VLTBSI'

	DbSelectArea("CZB")
	CZB->(dbSetOrder(1))
	If CZB->(dbSeek(xFilial("CZB") + oModelDGO:GetValue("DGO_CDAB")))

		cTab   := AllTrim(CZB->CZB_VLPAAB)
		cCampo := AllTrim(CZB->CZB_IDCDG)

		If At('_',cCampo) == 3
			cTabAux := SubStr(cTab,2,2)
		Else
			cTabAux := cTab
		EndIf

		cAliasQry := GetNextAlias()
		cQuery := " SELECT 1 "
		cQuery += " FROM " + RetSQLName( cTab )
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += "   AND "+cTabAux+"_FILIAL = '"+xFilial(cTab)+"'"
		cQuery += "   AND "+cCampo+" = '"+M->DGO_VLTBSI+"'"
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )
		dbSelectArea(cAliasQry)
		dbGoTop()
		If (cAliasQry)->(Eof())
			lRet := .f.
		End
		(cAliasQry)->(dbCloseArea())
	Else
		lRet := .f.
	EndIf
	If !lRet
		Help( ,, 'Help',,STR0038, 1, 0 ) //"O conteúdo informado é inválido!"
	EndIf
ElseIf cCampoDGO == 'DGO_VLFX'
	lRet := ValidValor(nVlIniFx, nVlFinFx, oModelDGO:GetValue("DGO_VLFX"),oModelDGO:GetValue('DGO_CDAB'))
EndIf

RestArea(aOldArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validacao e resolucao da Formula

@param
@return

@author  Lucas Konrad França
@since   02/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidForm(cFormula)
Local nJ
Local nK
Local nI
Local cAtributo
Local nCount := 0
Local oModel    := FwModelActive()
Local lPassou

cFormula := AllTrim(cFormula)
lPassou := .F.

For nJ := 1 To Len(cFormula)
	If IsAlpha(SubStr(cFormula,nJ))
		nCount := 0
		For nK := nJ To Len(cFormula)
			If SubStr(cFormula, nK+1,1) == "("
				Help( ,, 'Help',, STR0044 , 1, 0 ) // Parênteses aberto sem estar com um operador válido. Favor, verificar
				Return .F.
			EndIf
			nCount++
			If SubStr(cFormula, nK+1,1) $ "/*+.=^-()"
				Exit
			EndIf
		Next
		cAtributo := SubStr(cFormula, nJ, nCount)
		lPassou := .F.

		DbSelectArea( "CZB" )
		CZB->(dbSetOrder(1))

		For nI := 1 To oModel:GetModel('DGODETAIL'):GetQtdLine()
			oModel:GetModel('DGODETAIL'):GoLine(nI)
			CZB->(dbSeek(xFilial("CZB") + oModel:GetModel('DGODETAIL'):GetValue('DGO_CDAB')))

			If AllTrim(CZB->CZB_TPAB) == 'N' .AND. ;
				AllTrim(oModel:GetModel('DGODETAIL'):GetValue('DGO_NMAB')) == AllTrim(cAtributo)
				cFormNova := cFormNova + CValToChar(oModel:GetModel('DGODETAIL'):GetValue('DGO_VLNR'))
				lPassou := .T.
				Exit
			EndIf
		Next

		If !lPassou
			cFormNova := "0"
			Return cFormNova
		EndIf

		nJ := nK

 	Else
 	   If IsDigit(SubStr(cFormula,nJ))
			nCount := 0
			For nK := nJ To Len(cFormula)
				If SubStr(cFormula, nK+1,1) == "("
					Help( ,, 'Help',, STR0044 , 1, 0 ) // Parênteses aberto sem estar com um operador válido. Favor, verificar
					Return .F.
				EndIf
				nCount++
				If SubStr(cFormula, nK+1,1) $ "/*+.=^-()"
					Exit
				EndIf
			Next
			cFormNova := cFormNova + SubStr(cFormula, nJ, nCount)
			nJ := nK
		Else
			If (SubStr(cFormula,nJ,1) $ '()')
			cFormNova := cFormNova + SubStr(cFormula,nJ,1)
			Else
		  		If SubStr(cFormula, nJ,1) $ "/*+.=^-"
					cFormNova := cFormNova + SubStr(cFormula, nJ,1)
		  		EndIf
		  	EndIf
		EndIf
	EndIf
Next


If SubStr(cFormula,Len(cFormula),1) $ "/*+.=^-("
	Help( ,, 'Help',, STR0045, 1, 0 ) // Fórmula incorreta, favor verificar
	Return .F.
EndIf

Return cFormNova

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA210VVR
Função de validação do campo Versão produto

@param
@return

@author  Lucas Konrad França
@since   02/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRA210VVR()
	Local lRet := .T.

	IF !IsInCallStack('DPRA342')
		If !Empty(M->DGN_CDACDV) .AND. !Empty(M->DGN_NRVRAC)
			If ExistCpo('DG0',M->DGN_CDACDV+M->DGN_NRVRAC)
				dbSelectArea("DG0")
				DG0->(dbSetOrder(1))
				If (DG0->(dbSeek(xFilial("DG0")+M->DGN_CDACDV+M->DGN_NRVRAC)))
					If Val(DG0->DG0_TPST) >= 3
						Help( ,, 'Help',, STR0047, 1, 0 ) //"Versão de produto já liberada, não é possível utilizá-la."
						lRet := .F.
					EndIf
				EndIf
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet