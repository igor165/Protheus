#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA993.CH'

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW   2 

Static __cXml993   := ""
//-------------------------------------------------------------------
/*/{Protheus.doc} FINA993
Cadastro de rateio por CPF do IR Progressivo

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FINA993(nOpc020)
	Local nOpc 			 := MODEL_OPERATION_INSERT
	Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
	Local oModel
	Local lRet 			 := .t.

	Private N // para nao gerar erro com tela com grid
	Default nOpc020 := 3

	If cPaisLoc != "BRA"
		MsgStop(STR0012,STR0011) // "Rotina somente para o país Brasil." "Atenção"
		lRet := .F.
	EndIf

	If lRet
		If AliasInDic("FKJ")
			DbSelectArea("FKJ")	
			If nOpc020 <> 3
				FKJ->(DBSetOrder(1))
				If FKJ->(DBSeek(xFilial("FKJ") + SA2->A2_COD + SA2->A2_LOJA ))
					If nOpc020 == 4
						nOpc := MODEL_OPERATION_UPDATE
					Else
						nOpc := MODEL_OPERATION_VIEW
					EndIf
				EndIf		 
			EndIf	

			If Valtype(__cXml993) == "C"  .and. !Empty(__cXml993)
				oModel := FwLoadModel("FINA993")
				oModel:LoadXMLData(__cXml993)
				//Chama a view da tela 
				FWExecView( STR0001,"FINA993", nOpc,/**/,{||.T.}/*bCloseOnOk*/,/*{||Fakeok()}*/,,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/, oModel ) //'Cadastro de rateio por CPF do IR Progressivo'
				oModel:Deactivate()
				oModel:Destroy()
				oModel:= Nil
			Else
				FWExecView( STR0001,"FINA993", nOpc,/**/,{||.T.}/*bCloseOnOk*/,/*{||Fakeok()}*/,,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/) //'Cadastro de rateio por CPF do IR Progressivo'	
			Endif
			
			If nOpc == 4 .or. (nOpc020 == 4 .and. nOpc == 3)
				Fa993grava(1)
			EndIF

		Else
			lRet := .F.
			Help(STR0002)//"Tabela FKJ não existe. Necessário rodar o U_UPDFIN2!"
		EndIf
	EndIf	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo do Cadastro de rateio por CPF do IR Progressivo

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oMaster  := FWFormModelStruct():New()
	Local oStruFKJ := FWFormStruct( 1, 'FKJ', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel
	Local aAuxFKJ	:= {}

	//Criado master falso para a alimentação do detail.
	oMaster:AddTable('MASTER',,'MASTER')
	F993Scruct(oMaster,TYPE_MODEL)

	oStruFKJ:SetProperty( 'FKJ_COD'         , MODEL_FIELD_OBRIGAT, .F.)
	oStruFKJ:SetProperty( 'FKJ_LOJA'         , MODEL_FIELD_OBRIGAT, .F.)

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('FINA993', /*bPreValidacao*/, {|oModel| Fa993Pos(oModel) } /*bPosValidacao*/, {|oModel|Fa993Conf( oModel )} /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields('MASTER', /*cOwner*/, oMaster ,/*bPreVld*/,/*bPostVld*/, {|oModel| Fa993Load()} /*bLoadVld*/)
	oModel:AddGrid('FKJDETAIL'	,'MASTER'	,oStruFKJ	)

	oModel:SetPrimaryKey({'FORNECE','LOJA'})

	aAdd( aAuxFKJ, {"FKJ_FILIAL","xFilial('FKJ')"} )
	aAdd( aAuxFKJ, {"FKJ_COD","FORNECE"})
	aAdd( aAuxFKJ, {"FKJ_LOJA","LOJA"})
	oModel:SetRelation("FKJDETAIL", aAuxFKJ , FKJ->(IndexKey(1) ) ) 

	//Configura as propriedades do modelo de dados
	oModel:GetModel('MASTER'):SetOnlyQuery( .T. )

	oModel:GetModel( 'FKJDETAIL' ):SetUniqueLine( { 'FKJ_CPF' } )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0003 ) //'Cadastro CPF do IR Progressivo'
	oModel:GetModel( 'MASTER' ):SetDescriptadion( STR0004 ) //'Fornecedor'
	oModel:GetModel( 'FKJDETAIL' ):SetDescription( STR0005 )//'Números de CPF'

	oModel:SetActivate({|oModel|Fa993PRE( oModel )})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view do Cadastro de rateio por CPF do IR Progressivo

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria a estrutura a ser usada na View
	Local oMaster  := FWFormViewStruct():New()
	Local oStruFKJ := FWFormStruct( 2, 'FKJ' ,{ |x| !ALLTRIM(x) $ "FKJ_COD|FKJ_LOJA"})
	Local oModel   := FWLoadModel( 'FINA993' )
	Local oView

	F993Scruct(oMaster,TYPE_VIEW)

	// Cria o objeto de View
	oView := FWFormView():New()

	//Valida se pode entrar na tela
	oView:SetViewCanActivate({|| CanView993() } )

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_SA2', oMaster, 'MASTER' )
	oView:AddGrid("VIEW_FKJ",oStruFKJ,"FKJDETAIL")

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELAPAI' , 20 )
	oView:CreateHorizontalBox( 'TELAFIL' , 80 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SA2', 'TELAPAI' )
	oView:SetOwnerView( 'VIEW_FKJ', 'TELAFIL' )

	oView:EnableTitleView('VIEW_SA2','CPFs')

	//Desabilita os botoes das acoes relacionadas
	oView:EnableControlBar(.F.)
	
	oView:showInsertMsg(.F.)
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa993PRE
Função chamada antes da abertura da tela, com o model ja ativo.
Deixa os campos pre-preenchidos com os valores da tela de fornecedores

@param omodel, model ativo

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function  Fa993PRE(oModel)
	Local oSubFKJ := oModel:GetModel("FKJDETAIL")

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oModel:LoadValue("MASTER","FORNECE",M->A2_COD)
		oModel:LoadValue("MASTER","LOJA",M->A2_LOJA)
		
		oSubFKJ:GoLine(1)
		If Empty(oSubFKJ:GetValue("FKJ_CPF")) .and. M->A2_TIPO == 'J'
			oSubFKJ:SetValue("FKJ_CPF", If(Type("M->A2_CPFIRP") == "C",NOMASK(M->A2_CPFIRP),NOMASK(SA2->A2_CPFIRP)))
		EndIF	
	Endif	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CanView993
Pre-Validação para permitir acessar a tela.

@return lRet , true se pode acessar a tela

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function CanView993()
	Local lIRProg := SA2->(FieldPos("A2_IRPROG"))> 0
	Local lRet := .T.

	If M->A2_TIPO == 'J' .and. !lIRProg
		Help( ,,"F993IRPROG",,STR0006, 1, 0 ) //"Opção disponível somente para ambiente com a melhoria do IR Progressivo."
		lRet := .F.
	EndIf

	If lRet .and. Empty(M->A2_COD) .and. Empty(M->A2_LOJA) 
		Help( ,,"F993CODVAZIO",,STR0007, 1, 0 ) //"Necessário preencher os dados do código e loja do fornecedor"
		lRet := .F.
	EndIf

	If lRet .and. M->A2_TIPO == 'J' .and. (M->A2_IRPROG != "1" .or. Empty(M->A2_CPFIRP))
		Help( ,,"F993CPFVAZIO",,STR0008, 1, 0 ) //"Necessário definir IRRF Progressivo e CPF do IR Progressivo."
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa993Pos
Validação TudoOK para verificar se a somatoria do percentual bate 100%

@param oModel , model ativo
@return lRet , true se tudo ok 

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Static function Fa993Pos(oModel)
	Local oSubFKJ:= oModel:GetModel("FKJDETAIL")
	Local nI := 1
	Local nSoma := 0
	Local lRet := .T.
	Local lAchouCPF := .F.
	Local lTipoJ    := .F.

	lTipoJ := If(Type("M->A2_TIPO") == "C",(M->A2_TIPO == 'J'),(SA2->A2_TIPO == 'J'))

	For nI := 1 To oSubFKJ:Length()
		oSubFKJ:GoLine(nI)
		If !oSubFKJ:IsDeleted( nI )
			nSoma += oSubFKJ:GetValue("FKJ_PERCEN")	
			If NoMask(oSubFKJ:GetValue("FKJ_CPF")) == If(Type("M->A2_CPFIRP") == "C",NOMASK(M->A2_CPFIRP),NOMASK(SA2->A2_CPFIRP))
				lAchouCPF := .T.
			EndIf
		EndIf	
	Next ni

	If nSoma != 100
		lRet := .F.
		Help( ,,"F993PERCENT",,STR0009, 1, 0 ) //"A somatória do percentual deve ser 100%."
	EndIf

	If lTipoJ .and. lRet .and. !lAchouCPF
		lRet := .F.
		Help( ,,"F993CPF",,STR0010, 1, 0 ) //"É necessário cadastrar CPF IR Prog cadastrado no fornecedor."
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa993Conf
Ação do botão confirmação, grava o XML na variavel estatica, para posterior gravação

@param oModel , model ativo

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function Fa993Conf(oModel)	
	__cXml993 := oModel:GetXMLData()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaVar
Limpa a variavel estatica ao fim do processo de gravação

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function limpaVar()
	__cXml993   := ""
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa993grava
Função de gravação do model, chamada apos a gravacao do fornecedor

@param nOpca, 1 - se foi confirmada a gravação do fornecedor, 0 se foi cancelada a gravacao
@return lRet,  true se gravação do model for ok

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Function Fa993grava(nOpca)
	Local lRet := .T.
	Local oModel
	Local nI
	Local oSubFKJ
	Local cLog := ""

	Private N // para nao gerar erro com tela com grid
	Default nOpca := 1

	If nOpca == 1 .and. Valtype(__cXml993) == "C"  .and. !Empty(__cXml993)
		
		oModel := FwLoadModel("FINA993")
		oModel:LoadXMLData(__cXml993)

		oSubFKJ:= oModel:GetModel("FKJDETAIL")

		For nI := 1 To oSubFKJ:Length()
			oSubFKJ:GoLine(nI)
			If !oSubFKJ:IsDeleted( nI ) .and. (oSubFKJ:IsUpdated() .or.  (oSubFKJ:IsInserted() .and. !Empty(oSubFKJ:GetValue("FKJ_CPF")) ))
				oSubFKJ:SetValue("FKJ_COD",SA2->A2_COD)
				oSubFKJ:SetValue("FKJ_LOJA",SA2->A2_LOJA)
			EndIf
		Next nI

		If oModel:VldData()
			lRet	 := .T.
			FwFormCommit(oModel)
		Else
			lRet := .F.
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[6])        	
			Help( ,,"FINA993GRV",,cLog, 1, 0 )
		Endif
		
		oModel:Deactivate()
		oModel:Destroy()
		oModel:= Nil
		oSubFKJ := nil
		
	EndIf

	LimpaVar()

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Fa993excl
Função de exclusao do model, chamada apos a exclusao do fornecedor

@param nOpca, 1 - se foi confirmada a gravação do fornecedor, 0 se foi cancelada a gravacao
@param cCodigo - Codigo do fornecedor
@param cLoja - Loja do fornecedor
@return lRet,  true se gravação do model for ok

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Function Fa993excl(nOpca,cCodigo,cLoja)
	Local lRet := .T.

	Default nOpca := 2
	Default cCodigo := ""
	Default cLoja := ""

	FKJ->(DBSetOrder(1))
	If nOpca == 2 .and. FKJ->(DBSeek(xFilial("FKJ") + cCodigo +  cLoja ))
		While FKJ->(!Eof()) .and. FKJ->(FKJ_FILIAL + FKJ_COD + FKJ_LOJA) == xFilial("FKJ") + cCodigo +  cLoja 
			Reclock("FKJ",.F.)
			FKJ->(DBDelete())
			FKJ->(MSUnlock())
			FKJ->(DBSkip())
		EndDo

	EndIf

	limpaVar()

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} NoMask
Limpa a mascara do campo CPF

@param cString,caracter - CPF/CGC com mascara 
@return cRet,caracter - CPF/CGC sem mascara 

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function NoMask(cString)
	Local cValidos := '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	Local cRet := ''
	Local nI
	For nI := 1 to len(cString)
		IF substr(cString,nI,1) $ cValidos
			cRet += substr(cString,nI,1)
		Endif
	Next

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F993Scruct
Monta a estrutura da MASTER fake na view e no model

@param oStruct, Objeto do modelo/view 
@return nType, Tipo de criação dos fields (1 - Model, 2 - View) 

@author Vitor Duca
@since 22/10/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function F993Scruct(oStruct As Object, nType As Numeric)

	If nType == TYPE_MODEL
		//----------------Estrutura para criação do campo-----------------------------
		// [01] C Titulo do campo
		// [02] C ToolTip do campo
		// [03] C identificador (ID) do Field
		// [04] C Tipo do campo
		// [05] N Tamanho do campo
		// [06] N Decimal do campo
		// [07] B Code-block de validação do campo
		// [08] B Code-block de validação When do campo
		// [09] A Lista de valores permitido do campo
		// [10] L Indica se o campo tem preenchimento obrigatório
		// [11] B Code-block de inicializacao do campo
		// [12] L Indica se trata de um campo chave
		// [13] L Indica se o campo pode receber valor em uma operação de update.
		// [14] L Indica se o campo é virtual

		oStruct:AddField("FORNECE","","FORNECE","C",TAMSX3("A2_COD")[1],0,/*bValid*/,{||.F.},/*aValues*/,.T.,/*bInit*/,/*Key*/,/*lAlter*/,.T.)
		oStruct:AddField("LOJA","","LOJA","C",TAMSX3("A2_LOJA")[1],0,/*bValid*/,{||.F.},/*aValues*/,.T.,/*bInit*/,/*Key*/,/*lAlter*/,.T.)

	Elseif nType == TYPE_VIEW
		//----------------Estrutura para criação do campo-----------------------------
		// [01] C Nome do Campo
		// [02] C Ordem
		// [03] C Titulo do campo
		// [04] C Descrição do campo
		// [05] A Array com Help
		// [06] C Tipo do campo
		// [07] C Picture
		// [08] B Bloco de Picture Var
		// [09] C Consulta F3
		// [10] L Indica se o campo é evitável
		// [11] C Pasta do campo
		// [12] C Agrupamento do campo
		// [13] A Lista de valores permitido do campo (Combo)
		// [14] N Tamanho Maximo da maior opção do combo
		// [15] C Inicializador de Browse
		// [16] L Indica se o campo é virtual
		// [17] C Picture Variável

		oStruct:AddField("FORNECE","01","Fornecedor","Codigo do Fornecedor",,"C","@!",Nil,Nil,.F.,Nil,,,,,.T.)
		oStruct:AddField("LOJA","02","Loja","Loja do Fornecedor",,"C","@!" ,Nil,Nil,.F.,Nil,,,,,.T.)

	Endif	

Return

//----------------------------------------------------
/*/{Protheus.doc} Fa993Load
Efetua o carregamento dos campos da MASTER fake, para
que ocorra o correto relacionamento com a FKJ

@author Vitor Duca
@since 23/10/2019
@version P12
/*/
//---------------------------------------------------
Static Function Fa993Load() As Array
	Local aReturn As Array

	aReturn := {}
	aAdd(aReturn, M->A2_COD)
	aAdd(aReturn, M->A2_LOJA)

Return aReturn
