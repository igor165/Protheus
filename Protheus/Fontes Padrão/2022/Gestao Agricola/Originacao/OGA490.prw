#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OGA490.CH"

Static __oBrowCom 	:= Nil		//Other Browser - Tabela Temporária
Static __lBrowAct	:= .F.		//Auxiliar Other Browser
Static __cTabPen	:= ''		//Tabela Temporária
Static __aCpsBrow	:= {}		//Array criar campos Other Browser

/*{Protheus.doc} OGA490
Cadastro de Fórmula para Cálculo de Componentes

@author 	ana.olegini
@since 		13/03/2017
@version 	1.0
*/
Function OGA490()
	Local oMBrowse := Nil

	//-- Proteção de Código
	If .Not. TableInDic('N74') .OR. .Not. TableInDic('N75')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N74" )
	oMBrowse:SetDescription( STR0001 )	//'Cadastro de Fórmula para Cálculo de Componentes'
	oMBrowse:DisableDetails()
	oMBrowse:SetMenuDef('OGA490')
	oMBrowse:Activate()
Return()

/*{Protheus.doc} MenuDef
Define as operações quer serão realizadas pela aplicação

@author 	ana.olegini
@since 		13/03/2017
@version 	1.0
@return 	aRotina , array contendo as operações
*/
Static Function MenuDef()
	Local aRotina 	:= {}

	aAdd( aRotina, { STR0002 	, "PesqBrw"        	, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003	, "ViewDef.OGA490"	, 0, 2, 0, .T. } ) //"Visualizar"
	aAdd( aRotina, { STR0004	, "ViewDef.OGA490"	, 0, 3, 0, .T. } ) //"Incluir"
	aAdd( aRotina, { STR0005	, "ViewDef.OGA490"	, 0, 4, 0, .T. } ) //"Alterar"
	aAdd( aRotina, { STR0006	, "ViewDef.OGA490"	, 0, 5, 0, .T. } ) //"Excluir"
Return( aRotina )

/*{Protheus.doc} ModelDef
Define a regra de negócios

@author 	ana.olegini
@since 		13/03/2017
@version 	1.0
@return 	oModel , objeto do modelo com regras
*/
Static Function ModelDef()
	Local oStruN74 		:= FWFormStruct( 1, "N74" )
	Local oStruN75 		:= FWFormStruct( 1, "N75" )
	Local oModel 		:= MPFormModel():New( "OGA490", /*<bPre >*/, {| oModel | PosModelo( oModel ) }, /*<bGrava >*/, /*<bCancel >*/ )

	//*Remove Campos do Modelo
	oStruN75:RemoveField( "N75_CODCOM" )

	oModel:SetDescription( STR0007 )	//"Dados Componente Resultado"
	oModel:AddFields( 'OGA490_N74', Nil, oStruN74,/*<bPre >*/,/*< bPost >*/,/*< bLoad >*/)
	oModel:GetModel( 'OGA490_N74' ):SetDescription( STR0007 )	//"Dados Componente Resultado"
	oModel:SetPrimaryKey( {"N74_FILIAL", "N74_CODCOM"} )

	oModel:AddGrid( "OGA490_N75", "OGA490_N74", oStruN75)
	oModel:GetModel( "OGA490_N75" ):SetDescription( STR0008 )	//"Componentes para Cálculo"
	oModel:GetModel( "OGA490_N75" ):SetOptional( .t. )
	oModel:GetModel( "OGA490_N75" ):SetUniqueLine({"N75_CODCOP"})

	oModel:SetRelation( "OGA490_N75", { { "N75_FILIAL", "xFilial( 'N75' )" }, { "N75_CODCOM", "N74_CODCOM" } }, N75->( IndexKey( 1 ) ) )

Return oModel

/*{Protheus.doc} ViewDef
Define como o será a interface e portanto como o usuário interage com o modelo de dados

@author 	ana.olegini
@since 		13/03/2017
@version 	1.0
@return 	oView , objeto da interface
*/
Static Function ViewDef()
	Local oStruN74	:= FWFormStruct( 2, 'N74' )
	Local oStruN75	:= FWFormStruct( 2, 'N75' )
	Local oModel  	:= FWLoadModel( 'OGA490' )
	Local oView   	:= FWFormView():New()

	//*Remove Campos da Tela
	oStruN75:RemoveField( "N75_CODCOM" )

	// Define qual Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Declarando Objetos da Parte Superior
	oView:AddField( 'OGA490_N74', oStruN74, 'OGA490_N74' )
	oView:AddGrid(  'OGA490_N75', oStruN75, 'OGA490_N75' , /*uParam4 */, /*< bGotFocus >*/)

	oView:AddIncrementField( "OGA490_N75", "N75_ITEM" )

	// Criar um box horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 25 )
	oView:CreateHorizontalBox( 'INFERIOR', 75 )

	// Dividir o box inferior em outros 2 verticais
	oView:CreateVerticalBox( 'INFERIORD', 100, 'INFERIOR'  )

	// Dividir o box da esquerda em outros 2 horizontais
	oView:CreateHorizontalBox( 'LADO_DINF', 85, 'INFERIORD' )	//Direito Inferior

	oView:SetOwnerView( "OGA490_N74" , "SUPERIOR" )
	oView:SetOwnerView( "OGA490_N75" , "LADO_DINF" )

	oView:EnableTitleView( "OGA490_N74" )
	oView:EnableTitleView( "OGA490_N75" )

	oView:SetCloseOnOk( {||.t.} )
Return oView

/*{Protheus.doc} OGA490TAB
Função para realizar a criação da tabela temporária

@author 	ana.olegini
@since 		16/08/2016
@version 	1.0
@return 	cTabela 	- Caracter	- Retorna a tabela criada
*/
Function OGA490TAB()
    Local nCont 	:= 0
    Local cTabela	:= ''
	Local aStrTab 	:= {}	//Estrutura da tabela
	Local oArqTemp	:= Nil	//Objeto retorno da tabela

    //-- Busca no __aCpsBrow as propriedades para criar as colunas
    For nCont := 1 to Len(__aCpsBrow)
        aADD(aStrTab,{__aCpsBrow[nCont][2], __aCpsBrow[nCont][3], __aCpsBrow[nCont][4], __aCpsBrow[nCont][5] })
    Next nCont
   	//-- Tabela temporaria de pendencias
   	cTabela  := GetNextAlias()
   	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas
    oArqTemp := AGRCRTPTB(cTabela, {aStrTab, {{"","ITEM","COMPONENTE"}}})
Return cTabela

/*{Protheus.doc} OGA490REG
Função para realizar a busca de informações para a tabela temporaria

@author 	ana.olegini
@since 		16/08/2016
@version 	1.0
@return 	lRetorno 	- logico	- Retorna verdadeiro .T. ou falso .F.
*/
Function OGA490REG()
	Local lRetorno 	:= .T.
	Local oModel	:= FwModelActive()
	Local nOperation:= oModel:GetOperation()

	// 1 Se operação for diferente de INSERÇÂO
	If  nOperation <> MODEL_OPERATION_INSERT
		DbSelectArea("N75")
		DbSetOrder(1)
		// 2 Se existir na tabela N75
		If DbSeek(xFilial('N75')+N74->N74_CODCOM)
			// Enquanto Filial e Código de Componente for igual.
			While .NOT. N75->(Eof()) .AND. N75->N75_FILIAL == xFilial('N75') .AND. N75->N75_CODCOM == N74->N74_CODCOM
				//Busca descrição para montar estrutura da formula
				cDescr := Posicione("NK7",1,xFilial("NK7")+N75->N75_CODCOP,"NK7_DESCRI")
				If N75->N75_OPERAC == '1'
					cSimb:= " + "
				ElseIf N75->N75_OPERAC == '2'
					cSimb:= " - "
				ElseIf N75->N75_OPERAC == '3'
					cSimb:= " / "
				ElseIf N75->N75_OPERAC == '4'
					cSimb:= " * "
				EndIf
				// Grava na tabela temporaria
				RecLock((__cTabPen),.T.)
					(__cTabPen)->ITEM		:= N75->N75_ITEM
					(__cTabPen)->COMPONENTE	:= N75->N75_CODCOP
					(__cTabPen)->OPERACAO	:= N75->N75_OPERAC
					(__cTabPen)->ESTRUTURA	:= Alltrim(cDescr)+" ("+cSimb+")"
				MsUnlock()
				//Pula registro
				N75->(dbSkip())
			EndDo
		EndIf	//Fim - 2
	EndIf	//Fim - 1
Return(lRetorno)

/*{Protheus.doc} OGA490VLD
Função para realizar a validação de componentes tipo resultado.
Validação nos CAMPOS N74_CODCOM e N75_CODCOP [X3_VALID]

@author 	ana.olegini
@since 		16/08/2016
@version 	1.0
@param 		nOp			- numerico	- Informa qual o tipo de operação 1=CAMPO N74_CODCOM e 2=CAMPO=N75_CODCOP
@return 	lRetorno 	- logico	- Retorna verdadeiro .T. ou falso .F.
*/
Function OGA490VLD(nOp)
	Local lRetorno	:= .T.
	Local oModel	:= FwModelActive()
	Local oModelN74	:= oModel:GetModel("OGA490_N74")
	Local oModelN75	:= oModel:GetModel("OGA490_N75")

	// Se opção for 1=CAMPO N74_CODCOM
	If nOp == 1
		// Verifica se o campo de calculo é diferente de Resultado
		If Posicione("NK7",1,xFilial("NK7")+oModelN74:GetValue("N74_CODCOM"),"NK7_CALCUL") <> "R"
			If (Posicione("NK7",1,xFilial("NK7")+oModelN74:GetValue("N74_CODCOM"),"NK7_CALCUL") == "T") .And. (Posicione("NK7",1,xFilial("NK7")+oModelN74:GetValue("N74_CODCOM"),"NK7_PLVEND") == "3")
				If Posicione("NK7",1,xFilial("NK7")+oModelN74:GetValue("N74_CODCOM"),"NK7_ATIVO") == "N"
					lRetorno := .F.
					oModel:GetModel():SetErrorMessage(oModelN74:GetId(), , oModelN74:GetId(), "", "", STR0017, STR0018, "", "") //#"O componente informado está inativo."#"Informe um componente ativo."
				else	
					lRetorno := .T.
				EndIf
			Else
				lRetorno := .F.
				oModel:GetModel():SetErrorMessage(oModelN74:GetId(), , oModelN74:GetId(), "", "", STR0010, STR0011, "", "")	//"Componente informado deve ser do Tipo de Cálculo Resultado ou Tributo (desde que o Tributo seja de uso Exclusivo do Planejamento de Vendas).""Favor informar um componente do Tipo de Cálculo Resultado ou Tributo (somente são aceitos Tributos que sejam de uso Exclusivo do Planejamento de Vendas)."
			EndIf	
		ElseIf Posicione("NK7",1,xFilial("NK7")+oModelN74:GetValue("N74_CODCOM"),"NK7_ATIVO") == "N"
			lRetorno := .F.
			oModel:GetModel():SetErrorMessage(oModelN74:GetId(), , oModelN74:GetId(), "", "", STR0017, STR0018, "", "") //#"O componente informado está inativo."#"Informe um componente ativo."
		Else	
			lRetorno := .T.
		EndIf
	ElseIf nOp == 2
		// Verifica se o campo de calculo é igual de Resultado
		If Posicione("NK7",1,xFilial("NK7")+oModelN75:GetValue("N75_CODCOP"),"NK7_CALCUL") == "R"
			lRetorno := .F.
			oModel:GetModel():SetErrorMessage(oModelN75:GetId(), , oModelN75:GetId(), "", "", STR0012, STR0013, "", "")	//"Componente informado é do tipo de cálculo Resultado.""Favor informar um componente diferente do tipo de cálculo Resultado."
		Elseif Posicione("NK7",1,xFilial("NK7")+oModelN75:GetValue("N75_CODCOP"),"NK7_ATIVO") == "N"
			lRetorno := .F.
			oModel:GetModel():SetErrorMessage(oModelN75:GetId(), , oModelN75:GetId(), "", "", STR0017, STR0018, "", "") //#"O componente informado está inativo."#"Informe um componente ativo."	
		Else
			lRetorno := .T.
		EndIf
	EndIf
Return lRetorno

Static Function PosModelo( oModel )
	Local lContinua     := .T.
	Local oModelN74     := oModel:GetModel( "OGA490_N74" )
	Local oModelN75     := oModel:GetModel( "OGA490_N75" )
	Local aSaveLines  	:= FWSaveRows()
	
	If !empty(oModelN74:GetValue("N74_CODAJU")) .and. !oModelN75:SeekLine( { {"N75_CODCOP", oModelN74:GetValue("N74_CODAJU")  } } ) //posiciona no componente// Verifica se o campo de alteração está na composicao da formula
		Help( , , STR0014, , STR0015, 1, 0,,,,,,{STR0016} ) //#Ajuda#Componente de Ajuste Inválido.#O componente de ajuste deve estar presente na fórmula do cálculo. 
		lContinua := .F.
	EndIf
	
	FWRestRows(aSaveLines)	
	
return lContinua	