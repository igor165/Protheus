#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TMSA151.CH"
#INCLUDE "RWMAKE.CH"

Static cAliasMrk := "" // Alias Do Arquivo Temporário Da FWMarkBrowse
Static cAliasMbw := "" // Alias Do Arquivo Temporário da FWMBrowse

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA151
@autor		: Eduardo Alberti
@descricao	: Fornecedores Adicionais Da Viagem
@since		: Jan./2017
@using		: Rotina De Cadastramento/Manutencao Dos Fornecedores Adicionais Da Viagem (DJM)
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA151()

	Local oMBrowse	:= Nil
	Local aArea		:= GetArea()

	Private aRotina	:= MenuDef()

	//-- Proteção De Erro Da Rotina Caso o Dicionário Da Rotina Não Exista
	If !(AliasInDic("DJM"))
		//-- Mensagem genérica solicitando a atualização do sistema.
		MsgNextRel()
		Return()
	EndIf	

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias('DJM')
	oMBrowse:SetDescription( STR0001 ) // "Fornecedores Adicionais Da Viagem"
	oMBrowse:DisableDetails()

	oMBrowse:Activate()

	RestArea(aArea)

Return NIL
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@autor		: Eduardo Alberti
@descricao	: Modelo de Dados
@since		: Jan./2017
@using		: Fornecedores Adicionais Da Viagem
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local aArea       := GetArea()
	Local oStructCab  := Nil
	Local oStructGr1  := Nil
	Local oModel      := Nil
	Local bLinePre    := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| fGrdLinePre(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}

	//-----------------------------------------
	//--Monta a estrutura do formulário com base no dicionário de dados
	//-----------------------------------------
	oStructCab := FWFormStruct(1,"DJM",{ |cCampo|   AllTrim( cCampo ) + "|" $ "DJM_VIAGEM|DJM_FILORI|"  } )
	oStructGr1 := FWFormStruct(1,"DJM",{ |cCampo| !(AllTrim( cCampo ) + "|" $ "DJM_FILIAL|DJM_FILORI|DJM_VIAGEM|") } )

	//-----------------------------------------
	//--Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New("MSTMSA151", { |oMdl| DJMPreVl( oMdl ) } /*Pré-Validação*/, { |oMdl| DJMPosVl( oMdl ) } /*Pos-Validacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields("TMSA151_CAB",/*cOwner*/, oStructCab)

	oModel:SetPrimaryKey({"DJM_FILIAL","DJM_FILORI","DJM_VIAGEM","DJM_CODFOR","DJM_LOJFOR"})

	oModel:GetModel("TMSA151_CAB"):SetDescription( STR0002 ) // "Viagem"

	oModel:AddGrid("TMSA151_IT1", "TMSA151_CAB", oStructGr1, bLinePre , { |oMdlG,nLine| fGrdLinePos( oMdlG, nLine) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	oModel:GetModel("TMSA151_IT1"):SetDescription( STR0003 ) // "Fornecedores"

	oModel:SetRelation("TMSA151_IT1",{	{"DJM_FILIAL","xFilial('DJM')"} ,;
											{"DJM_FILORI","DJM_FILORI"} ,;
											{"DJM_VIAGEM","DJM_VIAGEM"}},;
											"DJM_FILIAL+DJM_FILORI+DJM_VIAGEM" ) //DJM_FILIAL+DJM_FILORI+DJM_VIAGEM+DJM_CODFOR+DJM_LOJFOR

	oModel:GetModel( "TMSA151_IT1" ):SetUniqueLine( { "DJM_CODFOR","DJM_LOJFOR" } ) //-- "DJM_CODFOR","DJM_LOJFOR"

	RestArea(aArea)

Return(oModel)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@autor		: Eduardo Alberti
@descricao	: Retorna a View (tela) da rotina
@since		: Jan./2017
@using		: Fornecedores Adicionais Da Viagem
@review     :
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local aArea       := GetArea()
	Local oView       := Nil
	Local oStructCAB  := Nil
	Local oStructGr1  := Nil
	Local oModel      := FWLoadModel("TMSA151")

	oStructCab := FwFormStruct( 2,"DJM", { |cCampo|  AllTrim( cCampo ) + "|" $ "DJM_VIAGEM|DJM_FILORI|" } )
	oStructGr1 := FwFormStruct( 2,"DJM", { |cCampo| !AllTrim( cCampo ) + "|" $ "DJM_FILIAL|DJM_FILORI|DJM_VIAGEM|" } )
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)

	oView:AddField( "TMSA151_CAB",oStructCab)
	oView:CreateHorizontalBox("CABEC",15)
	oView:SetOwnerView( "TMSA151_CAB","CABEC")

	oView:AddGrid("TMSA151_IT1",oStructGr1)
	oView:CreateHorizontalBox("GRID1",85)
	oView:SetOwnerView( "TMSA151_IT1","GRID1")


	RestArea(aArea)

Return oView

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@autor		: Eduardo Alberti
@descricao	: Funcao Para Montagem Do Menu Funcional Padrao Protheus
@since		: Jan./2017
@using		: Fornecedores Adicionais Da Viagem
@review	    :
/*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef(cTipo)

	Local aArea      := GetArea()
	Local aRotina    := {}

	Default cTipo  := "P"

	ADD OPTION aRotina TITLE STR0004 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 DISABLE MENU // Pesquisar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMSA151' OPERATION 2 ACCESS 0 DISABLE MENU // Visualizar
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TMSA151' OPERATION 3 ACCESS 0				// Incluir
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.TMSA151' OPERATION 4 ACCESS 0 DISABLE MENU	// Alterar
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.TMSA151' OPERATION 5 ACCESS 0 DISABLE MENU	// Excluir //-- 'VIEWDEF.TMSA151' //-- 'Tmsa151Opr("E")'
	ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.TMSA151' OPERATION 9 ACCESS 0 DISABLE MENU	// Copiar

	RestArea(aArea)

Return aRotina

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DJMPosVl
@autor		: Eduardo Alberti
@descricao	: Validação
@since		: Jan./2017
@using		: Fornecedores Adicionais Da Viagem
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function DJMPosVl(oModel)

	Local lRet       	:= .T.
	Local aArea	 	    := GetArea()
	Local nOperation 	:= 0 //oModel:GetOperation()

	Default oModel	    := FWModelActive()

	nOperation 		    := oModel:GetOperation()


	RestArea(aArea)

Return lRet
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA151
@autor		: Eduardo Alberti
@descricao	: Funcao Para Pre Validação Da Linha Do Grid
@since		: Jan./2017
@using		: Fornecedores Adicionais Da Viagem
@review	:
/*/
//------------------------------------------------------------------------------------------------
Static Function fGrdLinePre(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)

	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModel     := FWModelActive()
	Local cQuery     := ""
	Local nTotReg    := 0
	Local cAliasT    := GetNextAlias()
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	
	If cAction == "DELETE" .Or. ( cAction == "CANSETVALUE" .And. cIdField $ "DJM_CODFOR|DJM_LOJFOR" )

		cQuery += " SELECT      DUA.R_E_C_N_O_ "
		cQuery += " FROM        " + RetSqlName("DUA") + " DUA "
		cQuery += " WHERE       DUA.DUA_FILIAL  =  '" + FWxFilial("DUA") + "' "
		cQuery += " AND         DUA.DUA_FILORI  =  '" + oModel:GetValue( 'TMSA151_CAB', 'DJM_FILORI') + "' "
		cQuery += " AND         DUA.DUA_VIAGEM  =  '" + oModel:GetValue( 'TMSA151_CAB', 'DJM_VIAGEM') + "' "
		cQuery += " AND         DUA.DUA_CODFOR  =  '" + oModel:GetValue( 'TMSA151_IT1', 'DJM_CODFOR') + "' "		
		cQuery += " AND         DUA.DUA_LOJFOR  =  '" + oModel:GetValue( 'TMSA151_IT1', 'DJM_LOJFOR') + "' "
		cQuery += " AND         DUA.DUA_CODFOR  <> '" + Space(TamSX3("DJM_CODFOR")[1]) + "' "
		cQuery += " AND         DUA.D_E_L_E_T_  =  '  ' "
		
		cQuery := ChangeQuery(cQuery)

		//-- Executa Query
		Eval(bQuery)
		
		If nTotReg > 0 
			Help("",1,"TMSA15102",,) //-- Existe registro de ocorrência para a viagem referente ao fornecedor vinculado. 
			lRet := .f.
		EndIf
	EndIf

	//-- Fecha Arquivos Temporários
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf	

	RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA151
@autor		: Eduardo Alberti
@descricao	: Funcao Para Validação Da Linha Do Grid Apos Digitacao
@since		: Jan./2017
@using		: Fornecedores Adicionais Da Viagem
@review	:
/*/
//------------------------------------------------------------------------------------------------
Static Function fGrdLinePos( oModelDJM, nLinha)

	Local lRet        := .T.


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsVlDJM
Validacoes Da Tabela DJM
@author Eduardo Alberti
@since 25/11/2014
@version P11
/*/
//-------------------------------------------------------------------
Function TmsVlDJM(cCampo,cTipo,cParam,nLinha)

xRet       := .t.


Return(xRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa151Whe
@autor		: Eduardo Alberti
@descricao	: Define Se Campos Estão Editáveis
@since		: Jan./2017
@using		: Rotina De Cadastramento/Manutencao Dos Fornecedores Adicionais Da Viagem (DJM)
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa151Whe()

	Local aArea       := GetArea()
	Local lRet        := .t.
	Local oModel      := FWModelActive()
	Local nOperation  := oModel:GetOperation()
	Local cCampo      := ReadVar()
	Local cViagem     := ""  
	
	If cCampo == "M->DJM_VIAGEM"

		//-- Não Permite Alterar Viagem Na Alteração Do Cadastro
		If nOperation == 4 .Or. !Empty(oModel:GetValue( 'TMSA151_CAB', 'DJM_VIAGEM'))
			lRet := .f.
		EndIf
	EndIf
	
	RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa151Val
@autor		: Eduardo Alberti
@descricao	: Valida Digitação Dos Campos
@since		: Jan./2017
@using		: Rotina De Cadastramento/Manutencao Dos Fornecedores Adicionais Da Viagem (DJM)
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa151Val()

	Local aArea       := {DJM->(GetArea()),DTQ->(GetArea()),SA2->(GetArea()),GetArea()}
	Local aArSM0      := SM0->(GetArea()) //-- Não Alterar
	Local nX          := 0
	Local lRet        := .t.
	Local oModel      := FWModelActive()
	Local oView       := FWViewActive()
	Local nOperation  := oModel:GetOperation()
	Local cCampo      := ReadVar()
	Local cViagem     := ""
	Local cForn       := ""
	Local cLoja       := ""

	If cCampo == "M->DJM_VIAGEM"

		//-- Não Permite Alterar Viagem Na Alteração Do Cadastro
		If nOperation == 3
		
			cViagem     := oModel:GetValue( 'TMSA151_CAB', 'DJM_VIAGEM')
			
			//-- Verifica Se Já Existe No DJM
			DbSelectArea("DJM")
			DbSetOrder(1)
			If MsSeek( FWxFilial("DJM") + cFilAnt + cViagem , .f. )
				Help("",1,"JAGRAVADO") //-- Ja existe registro com esta informacao.
				lRet := .f.
			EndIf
		
			//-- Posiciona Na Viagem
			DbSelectArea("DTQ")
			DbSetOrder(2) //-- DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
			If !MsSeek( FWxFilial("DTQ") + cFilAnt + cViagem ) .Or. Empty(cViagem)
				Help("",1,"REGNOIS") //-- Nao existe registro relacionado a este codigo"
				lRet := .f.
			EndIf
		EndIf

	ElseIf cCampo == "M->DJM_CODFOR" .Or. cCampo == "M->DJM_LOJFOR"
	
		//-- Atualiza Loja Pelo Posicionamento SA2
		If cCampo == "M->DJM_CODFOR"
			oModel:LoadValue( 'TMSA151_IT1', 'DJM_LOJFOR', SA2->A2_LOJA )
			//--oView:Refresh('TMSA151_IT1')
		EndIf
		
		cForn := oModel:GetValue( 'TMSA151_IT1', 'DJM_CODFOR')
		cLoja := oModel:GetValue( 'TMSA151_IT1', 'DJM_LOJFOR')
		
		//-- Fornecedores
		DbSelectArea("SA2")
		DbSetOrder(1)
		If !(MsSeek( FWxFilial("SA2") + cForn + cLoja , .f. )) .Or. Empty(cForn)
			lRet := .f.
		Else
		
			//-- Verifica Se CNPJ é Diferente Das Empresas Do Grupo
			DbSelectArea("SM0")
			SM0->(DbGoTop())
			While SM0->(!Eof())
			
				If Alltrim(SM0->M0_CGC) == Alltrim(SA2->A2_CGC)
					Help("",1,"TMSA15101",,SM0->M0_NOMECOM) //-- CGC do Fornecedor inválido! Existe uma empresa Protheus com o mesmo CGC. Empresa:
					lRet := .f.
					Exit //-- Sai Do Loop
				EndIf
			
				SM0->(DbSkip())
			EndDo
			
			//-- Reposiciona SM0 (Não Remover!)
			RestArea(aArSM0)
		
			//-- Gatilha Automáticamente o Nome Do Fornecedor
			If lRet
				oModel:LoadValue( 'TMSA151_IT1', 'DJM_DESCFO', SA2->A2_NOME )
			Else
				oModel:LoadValue( 'TMSA151_IT1', 'DJM_DESCFO', Space(Len(SA2->A2_NOME)))
			EndIf	
			//--oView:Refresh('TMSA151_IT1')
		EndIf
	EndIf

	//-- Reposiciona Arquivos
	For nX := 1 To Len(aArea)
		RestArea(aArea[nX])
	Next nX
	
Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DJMPreVl
@autor		: Eduardo Alberti
@descricao	: Pre validação Da Tela (Para Validar Exclusão)
@since		: Jan./2017
@using		: Rotina De Cadastramento/Manutencao Dos Fornecedores Adicionais Da Viagem (DJM)
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function DJMPreVl( oModel )

	Local aArea      := {GetArea()}
	Local nX         := 0
	Local nOperation := oModel:GetOperation()
	Local lRet       := .t.
	Local cQuery     := ""
	Local nTotReg    := 0
	Local cAliasT    := GetNextAlias()
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	
	//-- Verifica Se é Exclusão
	If nOperation == MODEL_OPERATION_DELETE
	
		cQuery += " SELECT      DUA.R_E_C_N_O_ "
		cQuery += " FROM        " + RetSqlName("DUA") + " DUA "
		cQuery += " WHERE       DUA.DUA_FILIAL  =  '" + FWxFilial("DUA") + "' "
		cQuery += " AND         DUA.DUA_FILORI  =  '" + oModel:GetValue( 'TMSA151_CAB', 'DJM_FILORI') + "' "
		cQuery += " AND         DUA.DUA_VIAGEM  =  '" + oModel:GetValue( 'TMSA151_CAB', 'DJM_VIAGEM') + "' "
		cQuery += " AND         DUA.D_E_L_E_T_  =  '  ' "
		cQuery += " AND  EXISTS (   SELECT 0 "
		cQuery += "                 FROM    " + RetSqlName("DJM") + " DJM "
		cQuery += "                 WHERE   DJM.DJM_FILIAL  =  '" + FWxFilial("DJM") + "' "
		cQuery += "                 AND     DJM.DJM_FILORI  =  DUA.DUA_FILORI "
		cQuery += "                 AND     DJM.DJM_VIAGEM  =  DUA.DUA_VIAGEM "
		cQuery += "                 AND     DJM.DJM_CODFOR  =  DUA.DUA_CODFOR "
		cQuery += "                 AND     DJM.DJM_LOJFOR  =  DUA.DUA_LOJFOR "
		cQuery += "                 AND     DJM.D_E_L_E_T_  =  '  ' ) "
		
		cQuery := ChangeQuery(cQuery)

		//-- Executa Query
		Eval(bQuery)
		
		If nTotReg > 0 
			Help("",1,"TMSA15102",,) //-- Existe registro de ocorrência para a viagem referente ao fornecedor vinculado. 
			lRet := .f.
		EndIf
	EndIf

	//-- Fecha Arquivos Temporários
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf	

	//-- Reposiciona Arquivos
	For nX := 1 To Len(aArea)
		RestArea(aArea[nX])
	Next nX
	
Return(lRet)
