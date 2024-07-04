#INCLUDE "OGA860.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} OGA860()
Rotina para cadastro de Itens do Plano de Vendas
@type  Function
@author tamyris ganzenmueller
@since 28/06/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function OGA860()
	
	FWExecView("Alterar", 'VIEWDEF.OGA860', MODEL_OPERATION_UPDATE, , {|| .T. })

Return()


/*/{Protheus.doc} ModelDef()
Função que retorna o modelo padrao para a rotina
@type  Function
@author tamyris ganzenmueller
@since 28/06/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
	
	Local oStruN8Y  := FWFormStruct( 1, "N8Y")
	Local oStruNCX  := FWFormStruct( 1, "NCX")
	Local oStruN8Z  := FWFormStruct( 1, "N8Z")
	Local oModel   := MPFormModel():New( "OGA860")
	
	oStruNCX:AddField(STR0004, STR0004, 'NCX_STSLEG',      'BT' , 1 , 0, {|| OGA860Leg()} , NIL , NIL, NIL, {||RetLegNCX(NCX->NCX_GRPROD,NCX->NCX_CODPRO,NCX->NCX_TIPMER,NCX->NCX_MOEDA )}, NIL, .F., .F.)
         
    oStruN8Z:AddField('BTN BAIXO', "UP3" ,  'N8Z_MOVUP' , 'BT' , 1 , 0, {|| OGA860MOV(1)} , NIL , NIL, NIL, {||"UP3"}, NIL, .F., .T.)
	oStruN8Z:AddField('BTN CIMA',  "DOWN3", 'N8Z_MOVDW' , 'BT' , 1 , 0, {|| OGA860MOV(2)} , NIL , NIL, NIL, {||"DOWN3"}, NIL, .F., .T.)

	oStruN8Z:SetProperty( "N8Z_ORDEM"  , MODEL_FIELD_INIT  , {| x | x := fAutoIncre("N8Z_ORDEM") } ) 
	oStruN8Z:SetProperty( "N8Z_CODCOM" , MODEL_FIELD_VALID , {|oField| OGA860VCOM(oField) } )
	
	oStruN8Z:SetProperty( "N8Z_VALFIX"  , MODEL_FIELD_WHEN  , {|| .F. } )

	oStruN8Z:AddTrigger( "N8Z_CODCOM", "N8Z_UNIMED", { || .T. }, { | x | fTrgN8ZIND( "N8Z_UNIMED" ) } ) 
	oStruN8Z:AddTrigger( "N8Z_CODCOM", "N8Z_MOEDA2", { || .T. }, { | x | fTrgN8ZIND( "N8Z_MOEDA" ) } )
	oStruN8Z:AddTrigger( "N8Z_MOEDA2", "N8Z_DESMO2", { || .T. }, { |   | fTrgN8ZMoe() } )
	  
    oModel:AddFields("N8YVISUL", Nil, oStruN8Y )
	//inibe a gravação dos modelos abaixo
	oModel:SetOnlyQuery("N8YVISUL")
	
	//Itens do plano de vendas
	oModel:AddGrid( "NCXUNICO", "N8YVISUL", oStruNCX) 
	oModel:GetModel( "NCXUNICO" ):SetOptional( .T. )
	oModel:GetModel( "NCXUNICO" ):SetDescription( STR0021 ) //"Itens do Plano"
	oModel:GetModel( "NCXUNICO" ):SetNoUpdateLine(.T.)
	oModel:GetModel( "NCXUNICO" ):SetNoInsertLine(.T.)
	oModel:GetModel( 'NCXUNICO' ):SetNoDeleteLine(.T.)
	oModel:SetRelation( "NCXUNICO", { { "NCX_FILIAL", 'xFilial("NCX")'}, { "NCX_SAFRA", 'N8Y_SAFRA'}, { "NCX_GRPROD", 'N8Y_GRPROD'}, { "NCX_CODPRO", 'N8Y_CODPRO'} }, NCX->( IndexKey( 1 ) ) )
	oModel:SetOnlyQuery("NCXUNICO")
	oModel:GetModel( 'NCXUNICO' ):SetLoadFilter( , OGA860Filt() ) //Expressão SQL

	//Componentes de Preço
	oModel:AddGrid( "N8ZUNICO", "NCXUNICO", oStruN8Z, , {|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|PREVLINN8Z(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)})
	oModel:GetModel( "N8ZUNICO" ):SetOptional( .T. )
	oModel:GetModel( "N8ZUNICO" ):SetDescription( STR0003 )  
	oModel:GetModel( "N8ZUNICO" ):SetUniqueLine( { "N8Z_CODCOM" } )
	oModel:SetRelation( "N8ZUNICO", { { "N8Z_FILIAL", 'xFilial("N8Z")'}, { "N8Z_SAFRA", 'N8Y_SAFRA'}, { "N8Z_GRPROD", 'N8Y_GRPROD'}, { "N8Z_CODPRO", 'N8Y_CODPRO'}, { "N8Z_TIPMER", 'NCX_TIPMER'}, { "N8Z_MOEDA", 'NCX_MOEDA'} }, N8Z->( IndexKey( 2 ) ) )
		
Return oModel

/*/{Protheus.doc} ViewDef()
Função que retorna a view para o modelo padrao da rotina
@type  Function
@author tamyris ganzenmueller
@since 28/06/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
	Local oStruNCX := FWFormStruct( 2, "NCX", { |x| !ALLTRIM(x)  $ 'NCX_SAFRA, NCX_GRPROD, NCX_DGRPRO, NCX_CODPRO, NCX_DESPRO'})
	Local oStruN8Z := FWFormStruct( 2, "N8Z", { |x| ALLTRIM(x)  $ 'N8Z_CODCOM, N8Z_DESCOM, N8Z_UNIMED, N8Z_CALCUL, N8Z_TIPPRC, N8Z_PERAPL, N8Z_TIPVAL, N8Z_MOEDA2, N8Z_DESMO2'})
	Local oModel   := FWLoadModel( "OGA860" )
	Local oView    := FWFormView():New()
	
	oStruN8Z:RemoveField( "N8Z_MOEDA" )

	oView:SetModel( oModel )
           
    oStruNCX:AddField( "NCX_STSLEG" ,'01' , STR0004, STR0004, {} , 'BT' ,'@BMP',NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. ) //Status
    
    oStruN8Z:AddField( "N8Z_MOVUP"  ,'01' , "+ ", "UP3"    , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. )
	oStruN8Z:AddField( "N8Z_MOVDW"  ,'02' , "- ", "DOWN3"  , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. )
	
    oView:AddGrid(  "VIEW_NCX", oStruNCX, "NCXUNICO" )
	oView:AddGrid(  "VIEW_N8Z", oStruN8Z, "N8ZUNICO" )
    
	oView:CreateHorizontalBox( 'SUP', 50 )
	oView:CreateHorizontalBox( 'INF', 50 )
		
	oView:SetOwnerView( "VIEW_NCX", "SUP" )
	oView:SetOwnerView( "VIEW_N8Z", "INF" )
		
	oView:EnableTitleView( "VIEW_NCX" )
	oView:EnableTitleView( "VIEW_N8Z" )
	
	oView:SetViewProperty("VIEW_N8Z", "GRIDNOORDER")
	//oView:SetViewProperty("VIEW_NCX", "GRIDFILTER", {.T.}) 
	
	oView:SetCloseOnOk( {||.t.} )
	
	oView:SetAfterViewActivate({|| .T. })
	
Return oView

/*/{Protheus.doc} fAutoIncre()
Função para incrementar o campo N8Z_ORDEM
@type  Static Function
@author rafael.kleestadt
@since 17/07/2018
@version 1.0
@param cCampo, caractere, Campo a ser incrementado
@return cSeq, caractere, valor a ser atribuido ao campo
@example
(examples)
@see (links_or_references)
/*/
Static function fAutoIncre(cCampo)
	Local oModel	 := FwModelActive()
	Local cSeq       := PADL("1",  TamSX3( cCampo )[1], "0") //sem modelo
	Local aSaveLines := nil
	Local nX         := 0
	
	If ValType(oModel) == 'O' .and. oModel:GetId() == "OGA860"
					
		aSaveLines := FWSaveRows()
		
		for nX:=1 to oModel:GetModel("N8ZUNICO"):Length()
			oModel:GetModel("N8ZUNICO"):GoLine(nX)
			
			//joga para a uiltima linha
			if oModel:GetModel("N8ZUNICO"):GetValue(cCampo) > cSeq
			   cSeq := oModel:GetModel("N8ZUNICO"):GetValue(cCampo)
			endif   
			
		Next nX
		
		//soma sequencia
		cSeq := Soma1(cSeq)
		
		//reset rows
		FWRestRows(aSaveLines)	
		
	endif	
return cSeq


/*{Protheus.doc} OGA860MOV
Controle de ordenação de campos.
@author tamyris.g
@since 20/07/2018
@version 1.0
@return ${return}, ${return_description}
@param nTipo, numeric, descricao
@type function
*/
Static Function OGA860MOV(nTipo)
	Local oView     	 := FWViewActive() // View que se encontra Ativa
	Local oModel    	 := FWModelActive() // Model que se encontra Ativo
	Local oModelN8Z	     := oModel:GetModel('N8ZUNICO') // Submodelo da Grid
	Local nLinhaOld 	 := oView:GetLine('N8ZUNICO') // Linha atualmente posicionada
	Local cLinAtu	  	 := oModelN8Z:GetValue("N8Z_ORDEM", nLinhaOld) // Pega o valor da Ordem na linha atual

	If nTipo == 1 // Para cima

		If nLinhaOld != 1

			oModelN8Z:LoadValue("N8Z_ORDEM", oModelN8Z:GetValue("N8Z_ORDEM", nLinhaOld - 1)) // Seta o valor da linha de cima para atual
			oModelN8Z:GoLine(nLinhaOld - 1) // Move o posicionamento para a linha de cima
			oModelN8Z:LoadValue("N8Z_ORDEM", cLinAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
			oView:LineShift('N8ZUNICO',nLinhaOld ,nLinhaOld - 1) // Realiza a troca de linhas
			oModelN8Z:GoLine(nLinhaOld - 1)

		EndIf

	Else // Para baixo

		If nLinhaOld < oView:Length('N8ZUNICO')

			oModelN8Z:LoadValue("N8Z_ORDEM", oModelN8Z:GetValue("N8Z_ORDEM", nLinhaOld + 1)) // Seta o valor da linha de baixo para atual
			oModelN8Z:GoLine(nLinhaOld + 1) // Move o posicionamento para a linha de baixo
			oModelN8Z:LoadValue("N8Z_ORDEM", cLinAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
			oModelN8Z:GoLine(nLinhaOld)
			oView:LineShift('N8ZUNICO',nLinhaOld,nLinhaOld + 1) // Realiza a troca de linhas
			oModelN8Z:GoLine(nLinhaOld)

		EndIf

	EndIf

	oView:Refresh('N8ZUNICO') // Atualiza a SubView da Grid

	If nTipo == 1
		oModelN8Z:GoLine(nLinhaOld - 1)
	Else
		If nLinhaOld == oView:Length('N8ZUNICO')
			nLinhaOld := nLinhaOld - 1
		EndIf
		oModelN8Z:GoLine(nLinhaOld + 1)
	Endif

Return .T.

/*/{Protheus.doc} OGA860VCOM(oField)
Validação do campo de componente.
@type  Static Function
@author rafael.kleestadt
@since 20/07/2018
@version 1.1
@param oField, object, objeto da field a ser validada
@return lRet, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function OGA860VCOM(oField)
	Local oView      := FwViewActive()
	Local oModel     := oView:GetModel()
	Local oModelNCX  := oModel:GetModel( "NCXUNICO" )
	Local oModelN8Z  := oModel:GetModel( "N8ZUNICO" )
	Local cAliasQry  := ""
	Local cQuery     := ""
	Local lProdCom   := .F.
	Local cDesComp   := ""
	Local cDesProd   := ""
	
	//Permite somente componente com plano de vendas 2-Utilizado ou 3-Exclusivo
	If !Posicione("NK7",1, FwxFilial("NK7")+oField:GetValue("N8Z_CODCOM"), "NK7_PLVEND" ) $ "23"
		Help(" ", 1, ".OGA860000001.") //"Problema: Componente de Preço inválido."
		Return .F.                     //"Solução: Informe um Componente de Preço com Plano de Venda 2-Utilizado ou 3-Exclusivo."
	EndIf

	//Permite somente componente que possua a moeda do plano e vendas.
	cAliasQry := GetNextAlias()
	cQuery := " SELECT NK8_MOEDA "
	cQuery += "   FROM " + RetSqlName("NK8") + " NK8 "
	cQuery += "  WHERE NK8.NK8_FILIAL = '" + FwxFilial("NK8") + "' "
	cQuery += "    AND NK8.NK8_CODCOM = '" + oField:GetValue("N8Z_CODCOM") + "' "
	cQuery += "    AND NK8.NK8_MOEDA  =  " + cValToChar(oModelNCX:GetValue("NCX_MOEDA")) "
	cQuery += "    AND NK8.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	
	//Permite somente componente que possua o mesmo produto do plano e vendas.
	cDesComp := Posicione("NK7", 1, FwxFilial("NK7") + oModelN8Z:GetValue("N8Z_CODCOM"), "NK7_DESCRI")
	cDesProd := Posicione("SB1", 1, FwxFilial("SB1") + oModelNCX:GetValue("NCX_CODPRO"), "B1_DESC")
	
	DbSelectArea("NK8")
	NK8->(DbSetOrder(1))
	If NK8->(DbSeek(FwxFilial("NK8") + oModelN8Z:GetValue("N8Z_CODCOM")))
		While NK8->(!Eof()) .And. NK8->NK8_FILIAL == FwxFilial("NK8") .And. NK8->NK8_CODCOM == oModelN8Z:GetValue("N8Z_CODCOM")
			If Empty(NK8->NK8_CODPRO) .And. Empty(NK8->NK8_GRPPRO)
				lProdCom := .T. 
				Exit
			Else
				If NK8->NK8_GRPPRO == oModelNCX:GetValue("NCX_GRPROD") .And. ( NK8->NK8_CODPRO == oModelNCX:GetValue("NCX_CODPRO") .Or. Empty(oModelNCX:GetValue("NCX_CODPRO"))) 
					lProdCom := .T.
					Exit
				Else
					lProdCom := .F.
					NK8->(DbSkip())
				EndIf
			EndIf
		EndDo
	EndIf
	NK8->(DbCloseArea())
	
	If .Not. lProdCom
		If ! IsInCallStack( "OGA860CPY" )
			MsgAlert( STR0015 + CHR(13)+ CHR(10) +; //"Componente de Preço inválido!"
					STR0016 + cDesComp + STR0017 + cDesProd + STR0018 )//"Componente de Preço: " ##" não possui o produto: " ## " cadastrado!"
		EndIf
		Return .F.
	EndIf

	

Return .T.

/*/{Protheus.doc} fTrgN8ZIND()
Função para carregar a unidade de medida e a moeda conforme o componente de preço e indice.
No OGA410 ao cadastrar o componente podem ser vinculados os Produtos x Componentes de Preço,
a função busca a unidade de medida e moeda por indice, produto e grupo de produto, se não encontrar pelos tres, 
busca por produto e grupo de produto, se não encontrar busca por produto, e se ainda assim não encontrar busca pelo codigo do indice.
@type  Static Function
@author rafael.kleestadt
@since 20/07/2018
@version 1.0
@param cCampo, caractere, campo a ser preenchido com o retorno:  N8Z_UNIMED ou N8Z_MOEDA
@return xValor, return_type, Valor para preencher o campo
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrgN8ZIND(cCampo)
	Local oModel    := FwModelActive()
	Local oModelN8Z := oModel:GetModel( "N8ZUNICO" )
	Local oModelNCX := oModel:GetModel( "NCXUNICO" )
	Local xValor    := Nil
	Local cUnidade  := ""
	local nMoeda    := 0
	Local cAliasQry := ""
	Local cQuery    := ""

If !Empty(oModelN8Z:GetValue("N8Z_CODCOM"))

	cAliasQry  := GetNextAlias()

	cQuery := " SELECT NK8_CODIDX, NK8_CODPRO, NK8_GRPPRO, NK8_UM1PRO, NK8_MOEDA "
	cQuery += "   FROM " + RetSqlName("NK8") + " NK8 "
	cQuery += "  WHERE NK8.NK8_FILIAL = '" + FwxFilial("NK8") + "' "
	cQuery += "    AND NK8.NK8_CODCOM = '" + oModelN8Z:GetValue("N8Z_CODCOM") + "' "

	If !Empty(oModelNCX:GetValue("NCX_CODPRO"))
		cQuery += "    AND NK8.NK8_CODPRO = '" + oModelNCX:GetValue("NCX_CODPRO") + "' "
	EndIf

	If !Empty(oModelNCX:GetValue("NCX_GRPROD"))
		cQuery += "    AND NK8.NK8_GRPPRO = '" + oModelNCX:GetValue("NCX_GRPROD") + "' "
	EndIf

	cQuery += "    AND NK8.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!Eof() )

		If (cAliasQry)->NK8_CODPRO == oModelNCX:GetValue("NCX_CODPRO") .AND.;
		   (cAliasQry)->NK8_GRPPRO == oModelNCX:GetValue("NCX_GRPROD")

			cUnidade := (cAliasQry)->NK8_UM1PRO
			nMoeda   := (cAliasQry)->NK8_MOEDA
			EXIT

		ElseIf (cAliasQry)->NK8_CODPRO == oModelNCX:GetValue("NCX_CODPRO") .AND.;
		       (cAliasQry)->NK8_GRPPRO == oModelNCX:GetValue("NCX_GRPROD")

			cUnidade := (cAliasQry)->NK8_UM1PRO
			nMoeda   := (cAliasQry)->NK8_MOEDA
			(cAliasQry)->(DbSkip())

		ElseIf (cAliasQry)->NK8_GRPPRO == oModelNCX:GetValue("NCX_GRPROD")

			cUnidade := (cAliasQry)->NK8_UM1PRO
			nMoeda   := (cAliasQry)->NK8_MOEDA
			(cAliasQry)->(DbSkip())

		EndIf

		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

EndIf

If cCampo == "N8Z_UNIMED"
	xValor := cUnidade
Else
	xValor := nMoeda
EndIf

Return xValor

/*/{Protheus.doc} OGA860()
Gatilho para dscrição da moeda
@type  Function
@author tamyris ganzenmueller
@since 05/03/2019
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrgN8ZMoe()
	Local oModel    := FwModelActive()
	Local oModelN8Z := oModel:GetModel( "N8ZUNICO" )
	Local cReturn    := ""
	
	cReturn := AGRMVMOEDA(oModelN8Z:GetValue("N8Z_MOEDA2"))    

Return cReturn

/*/{Protheus.doc} OGA860Leg()
Função para mostrar a legenda
@type  Function
@author rafael.kleestadt
@since 17/07/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OGA860Leg()
	Local oLegenda := FWLegend():New() // Objeto FwLegend.
		
	oLegenda:Add( "NCX_STSLEG=='0'", "GREEN" , STR0005 ) //"Com Preço Demonstr. e Preço Acerto Cliente"
	oLegenda:Add( "NCX_STSLEG=='1'", "YELLOW", STR0006 ) //"Com Componente, mas sem Demonstr. e/ou Preço Acerto Cliente"
	oLegenda:Add( "NCX_STSLEG=='2'", "RED"   , STR0007 ) //"Sem Componente"

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
	
Return(.T.)

/*/{Protheus.doc} RetLegNCX()
Função para mostrar a legenda
@type  Function
@author rafael.kleestadt
@since 17/07/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function RetLegNCX(cGrProd, cCodPro, cTipMer, cMoeda )
	Local lTemComp := .F.
	Local lTemNeg  := .F.
	Local lTemDem  := .F.
	Local cCor     := "BR_VERMELHO" 
 		
	cAliasQry  := GetNextAlias()
	cQuery := "     SELECT NK7_TIPPRC FROM " + RetSqlName("NCX") + " NCX "
	cQuery += " INNER JOIN " + RetSqlName("N8Z") + " N8Z ON N8Z_FILIAL = '" + xFilial("N8Z") + "' AND N8Z_SAFRA = NCX_SAFRA AND N8Z_GRPROD = NCX_GRPROD AND N8Z_CODPRO = NCX_CODPRO AND N8Z_TIPMER = NCX_TIPMER AND N8Z_MOEDA = NCX_MOEDA AND N8Z.D_E_L_E_T_ = ' '"
	cQuery += "	INNER JOIN " + RetSqlName("NK7") + " NK7 ON NK7_FILIAL = '" + xFilial("NK7") + "' AND NK7_CODCOM = N8Z_CODCOM AND NK7.D_E_L_E_T_ = ' ' "
	cQuery += "      WHERE NCX.NCX_FILIAL = '" + xFilial("NCX") + " '"
	cQuery += "        AND NCX.NCX_SAFRA  = '" + N8Y->N8Y_SAFRA + "' "
	cQuery += "        AND NCX.NCX_GRPROD = '" + cGrProd + "' "
	cQuery += "        AND NCX.NCX_CODPRO = '" + cCodPro + "' "
	cQuery += "        AND NCX.NCX_TIPMER = '" + cTipMer + "' "
	cQuery += "        AND NCX.NCX_MOEDA  = '" + AllTrim(Str(cMoeda)) + "' "
	cQuery += "        AND NCX.D_E_L_E_T_ = ' ' "
	cQuery += "	  GROUP BY NK7_TIPPRC "
	cQuery := ChangeQuery(cQuery)
	 
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof() )
	
		lTemComp := .t.
		
		While ( cAliasQry )->( !Eof() )
		
			If (cAliasQry)->NK7_TIPPRC == '2' //Negociado
				lTemNeg := .T.
			ElseIF (cAliasQry)->NK7_TIPPRC == '3' //Demonstrativo
				lTemDem := .T.
			EndIf
			
			If lTemNeg .And. lTemDem
				Exit
			EndIf
			
			(cAliasQry)->( DbSkip() )
		EndDo
	EndIf
	(cAliasQry)->(DbcloseArea())
	
	If lTemNeg .And. lTemDem /*Já tem componente de preço demonstr. e preço acerto cliente (negociado)*/
		cCor := "BR_VERDE"
	ElseIF lTemComp /*Já tem componente, mas não tem demonstr. e/ou preço acerto cliente (negociado) */
		cCor := "BR_AMARELO"
	Else
		cCor := "BR_VERMELHO" /* Não tem Componente */
	EndIF
 	
Return cCor


/** {Protheus.doc} PREVLINN8Z
Função de pré validação de linha do grid N8Z

@param: 	oGride - Gride do modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	05/07/2018
@Uso: 		OGA820
*/
Static Function PREVLINN8Z( oStrN8Z, nLine, cAction, cField,xVrNovo,xVrAnt  )
	Local oModel   := oStrN8Z:GetModel()
	Local oStrNCX   := oModel:GetModel("NCXUNICO")
	Local oView    := FwViewActive()
	Local nX       := 0
	Local lTemComp := .F.
	Local lTemNeg  := .F.
	Local lTemDem  := .F.
	Local cCor     := "BR_VERMELHO" //Não tem componente
	
	For nX := 1 to oStrN8Z:Length()
		oStrN8Z:GoLine( nX )
		If (!oStrN8Z:IsDeleted() .Or. (nLine == nX .And. cAction == 'UNDELETE') ) .And. !(nLine == nX .And. cAction == 'DELETE') 
			lTemComp := .T.
			
			If cField == "N8Z_CODCOM" .And. !Empty(xVrNovo) .And. nLine == nX
				lTpPrc := Posicione("NK7", 1, xFilial("NK7") + xVrNovo, "NK7_TIPPRC")
			Else
				lTpPrc := Posicione("NK7", 1, xFilial("NK7") + oStrN8Z:GetValue('N8Z_CODCOM'), "NK7_TIPPRC")
			EndIF
			
			If lTpPrc== '2' //Negociado
				lTemNeg := .T.
			ElseIF lTpPrc == '3' //Demonstrativo
				lTemDem := .T.
			EndIf
			
			If lTemNeg .And. lTemDem
				Exit
			EndIf
			
		EndIF
	Next nX
	oStrN8Z:GoLine( nLine )
	
	If lTemNeg .And. lTemDem /*Já tem componente de preço demonstr. e preço acerto cliente*/
		cCor := "BR_VERDE"
	ElseIF lTemComp /*Já tem componente, mas não tem demonstr. e/ou preço acerto cliente */
		cCor := "BR_AMARELO"
	EndIf
	
	oStrNCX:SetNoUpdateLine(.F.)//habilita a edição da grid 
	oStrNCX:LoadValue( "NCX_STSLEG", cCor)
	oStrNCX:SetNoUpdateLine(.T.) //bloqueia novamente a edição da grid
	
	oView:Refresh("VIEW_NCX")

Return .t.

/*/{Protheus.doc} OGA860Filt
Filtra os dados exibidos na grid de itens do plano na pasta Gestão de Preço
@type  Function
@author rafael.kleestadt
@since 26/03/2019
@version 1.0
@param param, param_type, param_descr
@return cFiltro, caracter, Instruções SQL no formato string com os filtros a serem realizados no browse de itens do plano da pasta Gestão de Preço
@example
(examples)
@see (links_or_references)
/*/
Function OGA860Filt()
	Local aMerMoe := {}
	Local nX      := 0
	Local nPos    := 0
	Local cFiltro := ""

	oModelN8Y := FWLoadModel( 'OGA830' )
	oModelN8W := oModelN8Y:GetModel("N8WUNICO")
	oModelN8Y:SetOperation( MODEL_OPERATION_VIEW )

	If oModelN8Y:Activate()
		For nX := 1 To oModelN8W:Length()
			oModelN8W:GoLine( nX )
			If !oModelN8W:IsDeleted()

				nPos := aScan( aMerMoe, { |x| AllTrim( x[1] ) == AllTrim(oModelN8W:GetValue("N8W_TIPMER")+cValToChar(oModelN8W:GetValue("N8W_MOEDA"))) } )
				If nPos == 0
					AADD(aMerMoe, {AllTrim(oModelN8W:GetValue("N8W_TIPMER")+cValToChar(oModelN8W:GetValue("N8W_MOEDA"))), oModelN8W:GetValue("N8W_TIPMER"), oModelN8W:GetValue("N8W_MOEDA")})
					If !Empty(cFiltro)
						cFiltro += "  OR  "
					EndIf
					cFiltro += "(NCX_TIPMER = '"+oModelN8W:GetValue("N8W_TIPMER")+ "' AND " + "NCX_MOEDA = "+cValToChar(oModelN8W:GetValue("N8W_MOEDA"))+")"
				EndIF

			EndIf
		Next nX
		
	EndIf

	oModelN8Y:DeActivate() // Desativamos o Model
	oModelN8Y:Destroy()    // Destroi o objeto do model

Return cFiltro
