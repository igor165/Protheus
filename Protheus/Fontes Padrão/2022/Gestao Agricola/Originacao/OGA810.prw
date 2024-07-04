#INCLUDE "OGA810.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} OGA810()
Rotina para cadastro de DCO PEPRO
@type  Function
@author tamyris ganzenmueller
@since 04/06/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function OGA810( pcNumAvi, pcNumDco )
	Local oMBrowse
	Local cFiltroDef 	:= iIf( !Empty( pcNumAvi ), "N9U_NUMAVI='"+pcNumAvi+"'", "" )
	Private __cNumAvi	:= pcNumAvi

	If Empty(pcNumAvi)
		cFiltroDef += iIf( !Empty( pcNumDco ), "N9U_NUMDCO='"+pcNumDco+"'", "" )
	Else
		cFiltroDef += iIf( !Empty( pcNumDco ), " .AND. N9U_NUMDCO='"+pcNumDco+"'", "" )
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N9U" )
	oMBrowse:SetDescription( STR0001 ) //"DCO PEPRO"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:SetMenuDef( "OGA810" )

	oMBrowse:AddLegend( "N9U_STATUS=='1'", "YELLOW"	   , X3CboxDesc( "N9U_STATUS", "1" ) ) //"Pendente"
	oMBrowse:AddLegend( "N9U_STATUS=='2'", "ORANGE"	   , X3CboxDesc( "N9U_STATUS", "2" ) ) //"Em Processo"
	oMBrowse:AddLegend( "N9U_STATUS=='3'", "GREEN"	   , X3CboxDesc( "N9U_STATUS", "3" ) ) //"Encerrado"
	oMBrowse:AddLegend( "N9U_STATUS=='4'", "RED"	   , X3CboxDesc( "N9U_STATUS", "4" ) ) //"Não Comprov"
	oMBrowse:AddLegend( "N9U_STATUS=='5'", "BR_CANCEL" , X3CboxDesc( "N9U_STATUS", "5" ) ) //"Cancelado"

	oMBrowse:aColumns[1]:cTitle := RetTitle("N9U_STATUS") // "Status DCO"

	oMBrowse:AddStatusColumns( {||OGA810Est(N9U->( N9U_STAFIN ))}, {||OGA810Leg()})
	oMBrowse:aColumns[2]:cTitle := RetTitle("N9U_STAFIN") //"Sts.Prev.Fin"

	oMBrowse:SetAttach( .T. ) //Visualização
	oMBrowse:Activate()

	Return()

	/*/{Protheus.doc} MenuDef()
	Função que retorna os itens para construção do menu da rotina
	@type  Function
	@author tamyris ganzenmueller
	@since 04/06/2018
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0003, 'PesqBrw'                                                     , 0, 1,  0, .T. } ) //'Pesquisar'
	aAdd( aRotina, { STR0004, 'ViewDef.OGA810'                                              , 0, 2,  0, Nil } ) //'Visualizar'
	aAdd( aRotina, { STR0005, 'ViewDef.OGA810'                                              , 0, 3,  0, Nil } ) //'Incluir'
	aAdd( aRotina, { STR0006, 'ViewDef.OGA810'                                              , 0, 4,  0, Nil } ) //'Alterar'
	aAdd( aRotina, { STR0007, 'ViewDef.OGA810'                                              , 0, 5,  0, Nil } ) //'Excluir'
	aAdd( aRotina, { STR0008, 'ViewDef.OGA810'                                              , 0, 8,  0, Nil } ) //'Imprimir'
	aAdd( aRotina, { STR0012, 'OGA810PPF(N9U->N9U_FILIAL, N9U->N9U_NUMAVI, N9U->N9U_NUMDCO)', 0, 9,  0, Nil } ) //'Gerar/Atualizar Título(s) a Receber'
	aAdd( aRotina, { STR0024, 'OGA810DPF(N9U->N9U_FILIAL, N9U->N9U_NUMAVI, N9U->N9U_NUMDCO)', 0, 10, 0, Nil } ) //'Excluir Título(s) a Receber'
	aAdd( aRotina, { "Atu. Vl. Prev", 'OGA810AVLP(N9U->N9U_FILIAL, N9U->N9U_NUMAVI, N9U->N9U_NUMDCO)', 0, 10, 0, Nil } ) //'Excluir Título(s) a Receber'

	Return aRotina

	/*/{Protheus.doc} ModelDef()
	Função que retorna o modelo padrao para a rotina
	@type  Function
	@author tamyris ganzenmueller
	@since 04/06/2018
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function ModelDef()
	Local oStruN9U := FWFormStruct( 1, "N9U" )
	Local oStruN9W := FWFormStruct( 1, "N9W" )
	Local oStruN9X := FWFormStruct( 1, "N9X" )
	Local oModel   := MPFormModel():New( "OGA810", , {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) })
	Default __cNumAvi := ''
	
	If ! Empty( __cNumAvi )
		oStruN9U:SetProperty( "N9U_NUMAVI" , MODEL_FIELD_INIT , { | | __cNumAvi } ) 
		oStruN9U:SetProperty( "N9U_NUMAVI" , MODEL_FIELD_WHEN , { | | .F. } )
	EndIf

	oStruN9X:AddField(RetTitle("N9X_STAFIN"), RetTitle("N9X_STAFIN"), 'N9X_STATFI', 'BT' , 1 , 0, {|| OGA810Leg()} , NIL , NIL, NIL, {||OGA810Est(N9X->N9X_STAFIN)}, NIL, .F., .F.)

	oStruN9U:AddTrigger( "N9U_VLUNCO" , "N9U_VLPRCO"       , { || .T. }, { | x | fTrgN9UVPC() } )
	oStruN9U:AddTrigger( "N9U_UMVLCR" , "N9U_VLPRCO"       , { || .T. }, { | x | fTrgN9UVPC() } )
	oStruN9U:AddTrigger( "N9U_QUANT"  , "N9U_VLPRCO"       , { || .T. }, { | x | fTrgN9UVPC() } )
	oStruN9U:AddTrigger( "N9U_FILORI" , "N9U_CODREG"       , { || .T. }, { | x | fTrgN9UINI() } )
	oStruN9W:AddTrigger( "N9W_QUANT"  , "N9W_QTDSDO"       , { || .T. }, { | x | fTrgN9WSDO() } )	
	oStruN9W:AddTrigger( "N9W_EST"    , "N9W_QUANT"        , { || .T. }, { | x | fTrgN9WQTD() } )
	oStruN9W:SetProperty( "N9W_VLMAX" , MODEL_FIELD_INIT   , {| | OG810WHVMP() } )
	
	oStruN9U:SetProperty( "N9U_NUMAVI", MODEL_FIELD_VALID  , { | | fGetUniAvi() })	
	oStruN9W:SetProperty( "N9W_VLPREV",  MODEL_FIELD_VALID , { | | fAddN9X() })	

	oModel:AddFields( 'N9UUNICO', Nil, oStruN9U )
	oModel:SetDescription( STR0001 ) //"DCO PEPRO"
	oModel:GetModel( 'N9UUNICO' ):SetDescription( STR0002 ) //"Dados do DCO PEPRO"

	oModel:AddGrid( "N9WUNICO", "N9UUNICO", oStruN9W, , , , , )
	oModel:GetModel( "N9WUNICO" ):SetDescription( STR0009 ) //"Comprovação DCO"
	oModel:GetModel( "N9WUNICO" ):SetUniqueLine( { "N9W_EST" } )
	oModel:GetModel( "N9WUNICO" ):SetOptional( .t. )
	oModel:SetRelation( "N9WUNICO", { { "N9W_FILIAL", "xFilial( 'N9W' )" }, { "N9W_NUMAVI", "N9U_NUMAVI" }, { "N9W_NUMDCO", "N9U_NUMDCO" } }, N9W->( IndexKey( 1 ) ) )	

	oModel:AddGrid( "N9XUNICO", "N9UUNICO", oStruN9X, , , , , )
	oModel:GetModel( "N9XUNICO" ):SetDescription( STR0010 ) //"Previsão Financeira"
	oModel:GetModel( "N9XUNICO" ):SetUniqueLine( { "N9X_SEQUEN" } )
	oModel:GetModel( "N9XUNICO" ):SetOptional( .t. )
	oModel:GetModel( "N9XUNICO" ):SetNoInsertLine( .t. )
	oModel:GetModel( "N9XUNICO" ):SetNoDeleteLine( .t. )
	oModel:SetRelation( "N9XUNICO", { { "N9X_FILIAL", "xFilial( 'N9X' )" }, { "N9X_NUMAVI", "N9U_NUMAVI" }, { "N9X_NUMDCO", "N9U_NUMDCO" } }, N9X->( IndexKey( 1 ) ) )


	Return oModel

	/*/{Protheus.doc} ViewDef()
	Função que retorna a view para o modelo padrao da rotina
	@type  Function
	@author tamyris ganzenmueller
	@since 04/06/2018
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function ViewDef()
	Local oStruN9U := FWFormStruct( 2, 'N9U' )
	Local oStruN9W := FWFormStruct( 2, "N9W" )
	Local oStruN9X := FWFormStruct( 2, "N9X" )
	Local oModel   := FWLoadModel( 'OGA810' )
	Local oView    := FWFormView():New()

	oStruN9W:RemoveField( "N9W_NUMAVI" )
	oStruN9W:RemoveField( "N9W_NUMDCO" )
	oStruN9X:RemoveField( "N9X_NUMAVI" )
	oStruN9X:RemoveField( "N9X_NUMDCO" )
	oStruN9X:RemoveField( "N9X_SEQSE1" )
	oStruN9X:RemoveField( "N9X_PARSE1" )
	oStruN9X:RemoveField( "N9X_STAFIN" )

	oStruN9X:AddField( "N9X_STATFI" ,'01' , RetTitle("N9X_STAFIN"), RetTitle("N9X_STAFIN"), {} , 'BT' ,'@BMP',NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. ) //Status

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_N9U', oStruN9U, 'N9UUNICO' )
	oView:AddGrid(  'VIEW_N9W', oStruN9W, 'N9WUNICO' )
	oView:AddGrid(  'VIEW_N9X', oStruN9X, 'N9XUNICO' )

	oView:AddIncrementField( "VIEW_N9W", "N9W_SEQEST" )
	oView:AddIncrementField( "VIEW_N9X", "N9X_SEQUEN" )
	oView:AddIncrementField( "VIEW_N9X", "N9X_PARSE1" )

	oView:CreateHorizontalBox( "SUPERIOR" , 40 )
	oView:CreateHorizontalBox( "INFERIOR" , 60 )

	oView:CreateFolder( "GRADES", "INFERIOR")
	oView:AddSheet( "GRADES", "PASTA01", OemToAnsi( STR0009 ) ) //"Comprovação DCO"
	oView:AddSheet( "GRADES", "PASTA02", OemToAnsi( STR0010 ) ) //"Previsão Financeira"

	oView:CreateHorizontalBox( "PASTA_N9W", 100, , , "GRADES", "PASTA01" )
	oView:CreateHorizontalBox( "PASTA_N9X", 100, , , "GRADES", "PASTA02" )

	oView:SetOwnerView( "VIEW_N9U", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_N9W", "PASTA_N9W" )
	oView:SetOwnerView( "VIEW_N9X", "PASTA_N9X" )

	oView:EnableTitleView( "VIEW_N9U" )
	oView:EnableTitleView( "VIEW_N9W" )
	oView:EnableTitleView( "VIEW_N9X" )

	oView:AddUserButton(STR0013, '', {|oView, oButton| OGA810VPF(oView, oButton)}) //"Título a Pagar"

	oView:SetCloseOnOk( {||.t.} )

	Return oView

	/*/{Protheus.doc} OG810QUANT()
	Função para validar a quantidade do DCO
	@type  Function
	@author tamyris.g
	@since 04/06/2018
	@version version
	@param param, param_type, param_descr
	@return return, logical, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OG810QUANT()
	Local oModel    := FwModelActive()
	Local oModelN9U := oModel:GetModel("N9UUNICO")
	Local nQtAviso  := Posicione("N9N", 1, xFilial("N9N") + oModelN9U:GetValue("N9U_NUMAVI"), "N9N_QUANTI")
	Local nQtOutros := 0
	Local nX		:= 0

	Local aArea := GetArea()

	/*Validar quantidade para outros DCOs*/
	DbSelectArea("N9U")
	N9U->(DbSetOrder(1)) 
	If DbSeek(xFilial("N9U")+oModelN9U:GetValue("N9U_NUMAVI"))
		While !N9U->(Eof()) .AND. N9U->N9U_FILIAL+N9U->N9U_NUMAVI == xFilial("N9U")+oModelN9U:GetValue("N9U_NUMAVI")

			If N9U->N9U_NUMDCO <> oModelN9U:GetValue("N9U_NUMDCO")
				nQtOutros += N9U->N9U_QUANT
			EndIf
			N9U->(DbSkip())
		EndDo
	EndIf	
	N9U->(DbCloseArea())	

	RestArea(aArea)

	If (oModelN9U:GetValue("N9U_QUANT") + nQtOutros) > nQtAviso 

		Help(" ", 1, ".OGA810000001.") //##Problema: Quantidade inválida
		Return .F.                     //##Solução: Quantidade do DCO deve ser menor que a quantidade do Aviso
	
	Else
	
		aQDCO := QtdVincDCO(xFilial("N9U"), oModelN9U:GetValue("N9U_NUMAVI"), oModelN9U:GetValue("N9U_NUMDCO"))
		
		lQDCO := .T.
					
		For nX := 1 to Len(aQDCO)
			
			If aQDCO[nX][2] > oModelN9U:GetValue("N9U_QUANT")				
				Help(, , , ,'Quantidade menor que a quantidade vinculada',1,0,,,,,, {'Desvincule o DCO nos contratos / IEs antes de alterar a quantidade'})
				lQDCO := .F.
				EXIT				
			EndIf
			
		Next nX
		
		If !lQDCO
			Return .F.
		EndIf 
			
	EndIf

Return .T.

/*/{Protheus.doc} OG810FIL()
Função para validar a Filial do DCO
@type  Function
@author tamyris.g
@since 04/06/2018
@version version
@param param, param_type, param_descr
@return return, logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OG810FIL()
	Local lRet      := .T.
	Local oModel    := FwModelActive()
	Local oModelN9U := oModel:GetModel("N9UUNICO")
	Local cUFSM0    := POSICIONE("SM0",1,cEmpAnt+oModelN9U:GetValue("N9U_FILORI"),"M0_ESTENT")    
	Local cCISM0    := SubStr(POSICIONE("SM0",1,cEmpAnt+oModelN9U:GetValue("N9U_FILORI"),"M0_CODMUN"), 3, TamSx3('CC2_CODMUN')[1])   
	Local cRegPrMi  := ''
	Local cEstPrMi  := ''
	Local cRegPrem  := ''
	Local cEstPrem  := ''
	Local aInfInd   := {}
	Local cCodReg   := ''
	Local cQuery	:= ""
	Local cAliasReg := ""
	
	// Validar se a UF da filial de origem está dentro das regras do Aviso PEPRO
	If !OGX810VUF(oModelN9U:GetValue("N9U_NUMAVI"), cUFSM0, cCISM0, "1")
		HELP(' ',1,STR0033 ,,STR0034,2,0,,,,,, {STR0035})
		//"Regras Origem Aviso" ###"Pelas condições estabelecidas no Aviso, a cidade da filial informada não pode ser vinculada a um DCO deste Aviso."###"Modifique as condições na aba Regras Origem no Aviso para conseguir informar esta filial."
		Return .F.
	EndIf

	//Validar integridade do aviso consolidando informaçoes estado e regiao da filial, preço minimo e premio 
	DbSelectArea("N9N")
	N9N->(DbSetOrder(1)) // N9N_FILIAL+N9N_NUMERO
	If  N9N->(DbSeek(xFilial("N9N")+oModelN9U:GetValue("N9U_NUMAVI")))	

		//Buscar regiao com estado e cidade da filial do aviso
		cCodReg := ""	
		
		cAliasReg := GetNextAlias()
		cQuery := "SELECT DISTINCT NBR.NBR_CODREG "
		cQuery += "  FROM " + RetSqlName("NBR") + " NBR "
		cQuery += " INNER JOIN " + RetSqlName("N9Q") + " N9Q ON N9Q.N9Q_CODREG = NBR.NBR_CODREG AND N9Q.D_E_L_E_T_ = '' "
		cQuery += " WHERE N9Q.N9Q_FILIAL = '" + FWxFilial("N9Q") + "' "
		cQuery += "   AND N9Q.N9Q_TIPLOC = '1' "
		cQuery += "   AND N9Q.N9Q_NUMERO = '" + oModelN9U:GetValue("N9U_NUMAVI") + "' "
		cQuery += "   AND NBR.D_E_L_E_T_ = '' "
		cQuery += "   AND NBR.NBR_ESTADO = '" + cUFSM0 + "' "
		cQuery += "   AND (NBR.NBR_CODMUN = '" + cCISM0 + "' OR NBR.NBR_CODMUN = '') "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasReg,.F.,.T.)
	
		DbSelectArea(cAliasReg)
		(cAliasReg)->(DbGoTop())
		If (cAliasReg)->(!Eof())	
			cCodReg := (cAliasReg)->NBR_CODREG	
		EndIf		
		(cAliasReg)->(DbcloseArea())

		//buscar estado e regiao do indice do preco minimo 
		If  NK0->(DbSeek(xFilial("NK0")+N9N->N9N_INDICE))
			aInfInd := AgrGetInd(NK0->NK0_INDICE, NK0->NK0_TPCOTA, dDataBase, N9N->N9N_CODPRO, '', N9N->N9N_SAFRA, cUFSM0, '', '1', cCodReg)
			IF !Empty(aInfInd)			   
				cRegPrMi := aInfInd[1] 
				cEstPrMi := aInfInd[2]		    				    	     					     				    			
			EndIF			    	     					     				    			
		EndIf	

		//buscar estado e regiao do indice do premio
		If  NK0->(DbSeek(xFilial("NK0")+N9N->N9N_INDPRE))
			aInfInd := AgrGetInd(NK0->NK0_INDICE, NK0->NK0_TPCOTA, dDataBase, N9N->N9N_CODPRO, '', N9N->N9N_SAFRA, cUFSM0, '', '1', cCodReg)
			IF !Empty(aInfInd)		   
				cRegPrem := aInfInd[1] 
				cEstPrem := aInfInd[2]
			EndIF			    	     					     				    			
		EndIf				
	EndIF

	//Validar integridade do aviso consolidando informaçoes estado e regiao da filial e preço minimo 
	If  Empty(cRegPrMi)
		If  !Empty(cEstPrMi) .and. cEstPrMi <> cUFSM0  	
			lRet := .F.			
		EndIF
	Else
		If cCodReg <> cRegPrMi .and. !Empty(cRegPrMi)
			lRet := .F.
		EndIF 	
	EndIF

	//Validar integridade do aviso consolidando informaçoes estado e regiao da filial e premio
	If  Empty(cRegPrem)
		If  !Empty(cEstPrem) .and. cEstPrem <> cUFSM0  	
			lRet := .F.			
		EndIF
	Else	   
		If cCodReg <> cRegPrem .and. !Empty(cRegPrem)
			lRet := .F.
		EndIF 	
	EndIF			

Return lRet

/*/{Protheus.doc} OG810VALUF()
Função para validar a UF relacionada ao DCO
@type  Function
@author tamyris.g
@since 05/06/2018
@version version
@param param, param_type, param_descr
@return return, logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OG810VALUF()
	Local lRet   := .T.
	Local oModel    := FwModelActive()
	Local oModelN9U := oModel:GetModel("N9UUNICO")
	Local oModelN9W := oModel:GetModel("N9WUNICO")
	
	// Valida se a UF informada está dentro das regras do Aviso do PEPRO
	If !OGX810VUF(oModelN9U:GetValue("N9U_NUMAVI"), oModelN9W:GetValue("N9W_EST"), "", "2")
		lRet := .F.
	EndIf

	If !lRet
		Help(" ", 1, ".OGA810000003.") //##Problema: UF Inválida! ##Solução: A UF informada não pode ter restrição no Aviso Pepro
	EndIf

Return lRet

/*/{Protheus.doc} OG810VAFIN()
Função para validar a finalidade relacionada ao DCO
@type  Function
@author tamyris.g
@since 05/06/2018
@version 1.1
@param param, param_type, param_descr
@return return, logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OG810VAFIN()
	Local lRet      := .T.
	Local oModel    := FwModelActive()
	Local oModelN9U := oModel:GetModel("N9UUNICO")
	Local oModelN9W := oModel:GetModel("N9WUNICO")
	Local cAliasN9V := GetNextAlias()	
	Local cQryN9V   := ''

	cQryN9V := " SELECT N9V.N9V_FINALI "
	cQryN9V += "   FROM " + RetSqlName("N9V") + " N9V "
	cQryN9V += "  WHERE N9V.N9V_FILIAL = '" + xFilial("N9V") + "' "
	cQryN9V += "    AND N9V.N9V_NUMERO = '" + oModelN9U:GetValue("N9U_NUMAVI") + "' "
	cQryN9V += "    AND N9V.N9V_FINALI = '" + oModelN9W:GetValue("N9W_CODFIN") + "' "
	cQryN9V += "    AND N9V.D_E_L_E_T_ = '' "
	cQryN9V := ChangeQuery(cQryN9V)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryN9V), cAliasN9V, .F., .T.)

	If (cAliasN9V)->(EoF())
		lRet := .F.
	EndIf

	/*A finalidade que for informada, prevista ter no aviso (relação dos documentos para comprovação)*/
	If !lRet
		Help(" ", 1, ".OGA810000004.") //##Problema: Finalidade Inválida! ##Solução: Filial informada deve pertencer à uma das UFs de Origem informadas no aviso
	EndIf

	Return lRet

	/*/{Protheus.doc} OG810VAQTD()
	Função para validar a quantidade da comprovação do DCO
	@type  Function
	@author tamyris.g
	@since 04/06/2018
	@version version
	@param param, param_type, param_descr
	@return return, logical, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OG810VAQTD()
	Local oModel    := FwModelActive()
	Local oModelN9U := oModel:GetModel("N9UUNICO")
	Local oModelN9W := oModel:GetModel("N9WUNICO")
	Local aArea := GetArea()

	If oModelN9W:GetValue("N9W_QUANT") > oModelN9U:GetValue("N9U_QUANT") 

		Help(" ", 1, ".OGA810000005.") //##Problema: Quantidade inválida
		Return .F.                     //##Solução: Quantidade deve ser menor que a quantidade do DCO

	EndIf

	RestArea(aArea)

	Return .T.

	/*/{Protheus.doc} OG810WHVMP()
	Função para trazer o valor max prêmio conforme aviso
	@type  Function
	@author tamyris.g
	@since 06/06/2018
	@version version
	@param param, param_type, param_descr
	@return return, logical, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OG810WHVMP()
	Local oModel    := FwModelActive()
	Local oModelN9U := oModel:GetModel("N9UUNICO")
	Local cAliasN9N := GetNextAlias()	
	Local cQryN9N   := ''
	Local nRetorno  := 0

	Local aArea := GetArea()

	cQryN9N := " SELECT N9N_VLMAXP "
	cQryN9N += "   FROM " + RetSqlName("N9N") + " N9N "
	cQryN9N += "  WHERE N9N.N9N_FILIAL = '" + xFilial("N9N") + "' "
	cQryN9N += "    AND N9N.N9N_NUMERO = '" + oModelN9U:GetValue("N9U_NUMAVI") + "' "
	cQryN9N += "    AND N9N.D_E_L_E_T_ = '' "
	cQryN9N := ChangeQuery(cQryN9N)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryN9N), cAliasN9N, .F., .T.)

	If (cAliasN9N)->(!EoF())
		nRetorno := (cAliasN9N)->N9N_VLMAXP
	EndIf

	RestArea(aArea)

Return nRetorno


/*/{Protheus.doc} OG810AQVMP
//TODO Descrição auto-gerada.
@author vanilda.moggio
@since 22/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cCampoR, characters, descricao
@type function
/*/
Function OG810AQVMP(cCampoR)
	Local oModel    := FwModelActive()
	Local oModelN9U := oModel:GetModel("N9UUNICO")
	Local cAliasN9N := GetNextAlias()	
	Local cQryN9N   := ''
	Local nRetorno  := 0
	Local nVlMaxP   := 0

	Local aArea := GetArea()

	cQryN9N := " SELECT N9N_VLMAXP, N9N_UNMEPR, N9N_CODPRO"
	cQryN9N += "   FROM " + RetSqlName("N9N") + " N9N "
	cQryN9N += "  WHERE N9N.N9N_FILIAL = '" + xFilial("N9N") + "' "
	cQryN9N += "    AND N9N.N9N_NUMERO = '" + oModelN9U:GetValue("N9U_NUMAVI") + "' "
	cQryN9N += "    AND N9N.D_E_L_E_T_ = '' "
	cQryN9N := ChangeQuery(cQryN9N)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryN9N), cAliasN9N, .F., .T.)

	If (cAliasN9N)->(!EoF())
		cUMDest  := (cAliasN9N)->N9N_UNMEPR
		cProduto := (cAliasN9N)->N9N_CODPRO
		nVlMaxP  := (cAliasN9N)->N9N_VLMAXP

		If 	cCampoR = '1'
			nRetorno := AGRX001(M->N9U_UMDQTD, cUMDest, M->N9W_QUANT , cProduto) * nVlMaxP
		Else
			nRetorno := nVlMaxP
		EndIF    
	EndIf

	RestArea(aArea)

	Return nRetorno

	/*/{Protheus.doc} OG810VAQTD()
	Função para validar a quantidade da previsão do DCO
	@type  Function
	@author tamyris.g
	@since 04/06/2018
	@version version
	@param param, param_type, param_descr
	@return return, logical, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OG810VQPRV()
	Local lRet   := .T.
	Local oModel    := FwModelActive()
	Local oModelN9W := oModel:GetModel("N9WUNICO")
	Local oModelN9X := oModel:GetModel("N9XUNICO")
	Local n0        := 0
	Local nSomaN9W  := 0
	Local nSomaN9X  := 0
	Local nLinha    := 0

	For n0 := 1 to oModelN9W:Length()
		oModelN9W:GoLine( n0 )

		if !oModelN9W:IsDeleted() .And. oModelN9W:GetValue("N9W_STATUS") <> '4' //Não utilizado
			nSomaN9W += oModelN9W:GetValue("N9W_VLPREV")
		endif
	Next n0

	nLinha := oModelN9X:GetLine( n0 ) 
	For n0 := 1 to oModelN9X:Length()
		oModelN9X:GoLine( n0 )

		if !oModelN9X:IsDeleted()
			nSomaN9X += oModelN9X:GetValue("N9X_VALOR")
		endif
	Next n0
	oModelN9X:GoLine( nLinha )

	IF nSomaN9X > nSomaN9W
		lRet := .F.
		//##Problema: Quantidade inválida # O valor das Previsões Financeiras não pode ser maior que o Valores Previstos do Prêmio do DCO
		Help(" ", 1, ".OGA810000006.") 
	EndIF

Return lRet


/*/{Protheus.doc} fTrgN9UVPC
//TODO Gatilho para calcular e preencher o campo N9U_VLPRCO
@author claudineia.reinert
@since 22/06/2018
@version 1.1

@type function
/*/
Static Function fTrgN9UVPC() 
	Local oModel	 := FwModelActive()
	Local oModelN9U  := oModel:GetModel( "N9UUNICO" )
	Local nValor	 := 0
	Local nVlrIndice := 0
	Local cUMOrig    := ""
	Local cUMDest    := ""
	Local cProduto   := ""
	Local nVlUnCo    := 0

	nVlrIndice := oModelN9U:GetValue("N9U_QUANT")  //Quantidade
	cUMOrig    := oModelN9U:GetValue("N9U_UMDQTD") //Unid. Medida Origem(Un. Med. Quantidade)
	cUMDest    := oModelN9U:GetValue("N9U_UMVLCR") //Unid. Medida Destino(Un.Med.Vl.Unit.Corretor)
	cProduto   := N9N->N9N_CODPRO                  //Cód. do Produto
	nVlUnCo    := oModelN9U:GetValue("N9U_VLUNCO") //Valor Unitário Corretor(Vl Unit Pag Corretor)

	nValor := AGRX001(cUMOrig, cUMDest, nVlrIndice, cProduto) * nVlUnCo

Return nValor


/*/{Protheus.doc} fTrgN9WSDO
//TODO Gatilho para calcular e preencher o campo N9W_QTDSDO 
@author claudineia.reinert
@since 22/06/2018
@version undefined

@type function
/*/
Static Function fTrgN9WSDO() 
	Local oModel	:= FwModelActive()
	Local oModelN9W      := oModel:GetModel( "N9WUNICO" )
	Local nSaldo	:= 0

	nSaldo := oModelN9W:GetValue("N9W_QUANT") - oModelN9W:GetValue("N9W_QTDVIN")

Return nSaldo

/*{Protheus.doc} fTrgN9UINI
Função para buscar de acordo com a filial informada N9U_FILORI o municipio
@author thiago.rover
@since 26/07/2018
@version undefined

@type function*/
Static Function fTrgN9UINI()

	Local cEstado  := ""
	Local cCidade  := ""	
	Local oModel    := FwModelActive()
	Local oModelN9U := oModel:GetModel( "N9UUNICO" ) 
	Local cCodReg   := ""
	
	cEstado := UPPER(POSICIONE("SM0",1,cEmpAnt+oModelN9U:GetValue("N9U_FILORI"),"M0_ESTENT"))   
	cCidade := SubStr(POSICIONE("SM0",1,cEmpAnt+oModelN9U:GetValue("N9U_FILORI"),"M0_CODMUN"), 3, TamSx3('CC2_CODMUN')[1])
	
	cCodReg := OGX810REG(oModelN9U:GetValue("N9U_NUMAVI"), cEstado, cCidade)

Return cCodReg

	/*/{Protheus.doc} fTrgN9WQTD()
	Gatilho para sugerir a quantidade do DCO na quantidade da comprovação quando inserir linha.
	@type Static Function
	@author rafael.kleestadt
	@since 01/08/2018
	@version 1.0
	@param param, param_type, param_descr
	@return nRetorno, numeric, quantidade do DCO(N9U_QUANT)
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=364926992
	/*/
Static Function fTrgN9WQTD()
	Local oModel    := FwModelActive()
	Local oModelN9U := oModel:GetModel("N9UUNICO")
	Local oModelN9W := oModel:GetModel("N9WUNICO")
	Local nRetorno  := oModelN9W:GetValue("N9W_QUANT")

	If Empty(oModelN9W:GetValue("N9W_QUANT"))
		nRetorno := oModelN9U:GetValue("N9U_QUANT")
	EndIf

	Return nRetorno

	/*/{Protheus.doc} PosModelo( oModel )
	Pós validação da tela, verifioca se informou pelo menos uma linha com valor total do DCo nas comprovações DCO
	@type  Static Function
	@author rafel.kleestadt
	@since 01/08/2018
	@version 1.0
	@param oModel, object, modelo de dados da tela
	@return lRet, Logycal, True or False
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=364926992
	/*/
Static Function PosModelo( oModel )
	Local oModelN9U := oModel:GetModel("N9UUNICO")
	Local oModelN9W := oModel:GetModel("N9WUNICO")
	Local oModelN9X := oModel:GetModel("N9XUNICO")
	Local nX        := 0
	Local lRet      := .F.
	Local nParc     := 1
	Local nOperation := oModel:GetOperation()
	Local cAliasN9N := GetNextAlias()	
	Local cQryN9N   := ''
	Local nVlMaxP   := 0
	Local n0        := 0
	Local cUMDest    := ""
	Local cProduto   := ""
	
	If nOperation <> MODEL_OPERATION_DELETE .AND. oModelN9W:Length() == 1
		oModelN9W:GoLine(1)
			
		If .Not. oModelN9W:IsDeleted() .AND. oModelN9W:GetValue("N9W_QUANT") <> M->N9U_QUANT			
			oModelN9W:LoadValue("N9W_QUANT", M->N9U_QUANT)	
			oModelN9W:LoadValue("N9W_QTDSDO", oModelN9W:GetValue("N9W_QUANT") - oModelN9W:GetValue("N9W_QTDVIN"))		
		EndIf
			
	EndIf

	For nX := 1 To oModelN9W:Length()
		oModelN9W:GoLine(nX)
		If .Not. oModelN9W:IsDeleted()
			If oModelN9W:GetValue("N9W_QUANT", nX) == oModelN9U:GetValue("N9U_QUANT")
				lRet := .T.
			EndIf
		EndIf
	Next nX

	If .Not. lRet
		Help(" ", 1, ".OGA810000007.") //##Problema: Comprovação DCO Inválida.
		Return .F.                     //##Solução: Informe a quantidade total do DCO em pelo menos um registro da Comprovação DCO.
	EndIf

	If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE
		lRetFil:= OG810FIL()
		If !lRetFil
			Help(, , "Filial inválida", ,"Filial informada deve pertencer à uma UF\Região de Origem informadas no aviso (Indice Preço mínimo e Prêmio)", 1, 0 ) //Filial inválida
		Else
			cQryN9N := " SELECT N9N_VLMAXP, N9N_UNMEPR, N9N_CODPRO"
			cQryN9N += "   FROM " + RetSqlName("N9N") + " N9N "
			cQryN9N += "  WHERE N9N.N9N_FILIAL = '" + xFilial("N9N") + "' "
			cQryN9N += "    AND N9N.N9N_NUMERO = '" + oModelN9U:GetValue("N9U_NUMAVI") + "' "
			cQryN9N += "    AND N9N.D_E_L_E_T_ = '' "
			cQryN9N := ChangeQuery(cQryN9N)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryN9N), cAliasN9N, .F., .T.)

			If (cAliasN9N)->(!EoF())
				cUMDest  := (cAliasN9N)->N9N_UNMEPR
				cProduto := (cAliasN9N)->N9N_CODPRO
				nVlMaxP  := (cAliasN9N)->N9N_VLMAXP				
			EndIf

			For n0 := 1 to oModelN9W:Length()
				oModelN9W:GoLine( n0 )

				if !oModelN9W:IsDeleted()
					oModelN9W:SetValue("N9W_VLMAX" ,nVlMaxP)					 
					oModelN9W:SetValue("N9W_VLPREV",AGRX001(oModelN9U:GetValue("N9U_UMDQTD"),cUMDest, oModelN9W:GetValue("N9W_QUANT") , cProduto) * nVlMaxP  )
				endif
			Next n0
		EndIf
	EndIF

	//Realiza a inclusão da parcela no modelo
	If nOperation == MODEL_OPERATION_INSERT

		For nX := 1 To oModelN9X:Length()
			oModelN9X:GoLine(nX)
			If .Not. oModelN9X:IsDeleted()
				If nParc < 10
					oModelN9X:SetValue("N9X_PARSE1", STRZERO(nParc, 2))
				Else
					oModelN9X:SetValue("N9X_PARSE1", cValToChar(nParc))
				EndIf
				nParc ++
			EndIf
		Next nX

	ElseIf nOperation == MODEL_OPERATION_UPDATE

		For nX := 1 To oModelN9X:Length()
			oModelN9X:GoLine(nX)
			If Empty(oModelN9X:GetValue("N9X_PARSE1", nX))
				If nX < 10
					oModelN9X:SetValue("N9X_PARSE1", STRZERO(nX, 2))
				Else
					oModelN9X:SetValue("N9X_PARSE1", cValToChar(nX))
				EndIf
			EndIf
		Next nX

	EndIf

Return lRet

	/*/{Protheus.doc} OGA810PPF()
	Função responsavel pela chamada da fGerPrvFin() e mostrar o erro caso ocorra no execAuto do Fina040
	@type  Function
	@author rafael.kleestadt
	@since 22/09/2018
	@version 1.1
	@param cFilN9U, caractere, filial do dco posicionado
	@param cNumAvi, caractere, número do aviso do dco posicionado
	@param cNumDco, caractere, número do dco posicionado
	@return .T., Logycal, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OGA810PPF(cFilN9U, cNumAvi, cNumDco)
	Local lRet := .T.
	Private lMsErroAuto := .F.

	DbSelectArea("N9U")
	DbSetOrder(1) //N9U_FILIAL+N9U_NUMAVI+N9U_NUMDCO
	If N9U->(DbSeek(cFilN9U + cNumAvi + cNumDco))
		If fValVlCRec()
			BEGIN TRANSACTION
				Processa({|| fGerPrvFin() }, STR0014) //Processando. "Gerando/Atualizando Título(s) a Receber do DCO..."

				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
					lRet := .F.
				Else
					//Atualiza o campo N9U_STAFIN e N9X_STAFIN
					AtuLegN9U()
				EndIf
			END TRANSACTION
		EndIf	
	EndIf
	N9U->(DbCloseArea())

Return lRet

	/*/{Protheus.doc} fGerPrvFin()
	Função que monta o array e executa o execAuto do Fina040 para criar/atualizar os titulos a receber das previsóes de recebimento do DCO.
	@type  Static Function
	@author rafael.kleestadt
	@since 22/09/2018
	@version 1.0
	@param param, param_type, param_descr
	@return .T., Logycal, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fGerPrvFin()
	Local aFiliais   := FwLoadSM0()
	Local aFina040   := {}
	Local aVncCRec   := {}
	Local aLinvncAux := {}
	Local nOperation := 3
	Local nX         := 0
	Local lContinua  := .F.
	Local dData      := dDataBase
	Local aArea      := GetArea()
	Local cSafra     := ""
	Local cCodPro    := ""
	Local cFilOri	:= cFilAnt	//--SALVA A FILIAL LOGADA ANTES DE REALIZAR A TROCA DA FILIAL DO DCO

	// Salvando Infs. sobre o Modulo Atual
	Local cModAtu := cModulo
	Local nModAtu := nModulo

	//--ALTERA A FILIAL CORRENTE PARA A FILIAL Do DCO
	cFilAnt := N9U->N9U_FILORI 	

	//Exclui os títulos a receber e os vinculos N8L
	fDelPrvFin()

	For nX := 1 To Len(aFiliais)
		If aFiliais[nX][2] == N9U->(N9U_FILORI)
			cCliente := Posicione("SA1", 3, FwxFilial("SA1") + aFiliais[nX][18], "A1_COD")
			cLojCli  := Posicione("SA1", 3, FwxFilial("SA1") + aFiliais[nX][18], "A1_LOJA")
			EXIT
		EndIf

	Next nX

	DbSelectArea("N9X")
	DbSetOrder(1)
	If N9X->(DbSeek(N9U->(N9U_FILIAL+N9U_NUMAVI+N9U_NUMDCO)))
		While N9X->(!EOF()) .AND.  N9X->(N9X_FILIAL+N9X_NUMAVI+N9X_NUMDCO) == N9U->(N9U_FILIAL+N9U_NUMAVI+N9U_NUMDCO)

			If N9X->N9X_VALOR == 0
				N9X->(DbSkip())
				LOOP
			EndIf

			cSafra  := Posicione("N9N", 1, N9X->(N9X_FILIAL+N9X_NUMAVI), "N9N_SAFRA")
			cCodPro := Posicione("N9N", 1, N9X->(N9X_FILIAL+N9X_NUMAVI), "N9N_CODPRO")

			aFina040 := {}

			aAdd( aFina040, { "E1_PREFIXO" , "DCO"           , Nil } )
			aAdd( aFina040, { "E1_NUM"     , N9X->N9X_SEQSE1 , Nil } )
			aAdd( aFina040, { "E1_PARCELA" , N9X->N9X_PARSE1 , Nil } )
			aAdd( aFina040, { "E1_TIPO"    , "PR "           , Nil } )
			aAdd( aFina040, { "E1_CLIENTE" , cCliente        , Nil } )
			aAdd( aFina040, { "E1_LOJA"    , cLojCli         , Nil } )
			aAdd( aFina040, { "E1_EMISSAO" , dData           , Nil } )
			aAdd( aFina040, { "E1_VENCTO"  , N9X->N9X_DTPREV , Nil } )
			aAdd( aFina040, { "E1_VALOR"   , N9X->N9X_VALOR  , Nil } )
			aAdd( aFina040, { "E1_MOEDA"   , 1          	 , Nil } )
			aAdd( aFina040, { "E1_VLCRUZ"  , N9X->N9X_VALOR  , Nil } )
			aAdd( aFina040, { "E1_HIST"    , STR0011         , Nil } ) //"Tit. Prov. DCO Prev. Fin."
			aAdd( aFina040, { "E1_ORIGEM"  , "OGA810"        , Nil } )
			aAdd( aFina040, { "E1_FILORIG" , N9U->N9U_FILORI , Nil } ) //filial de origem do DCO
			aAdd( aFina040, { "E1_CODSAF"  , cSafra          , Nil } ) //Safra do Aviso PEPRO
			aAdd(aFina040,  { "E1_CLVLCR"  , N9X->N9X_CLVL   , Nil } ) // classe de valor
			aAdd( aFina040, { "E1_NATUREZ" , N9X->N9X_NATFIN , Nil } ) //Natureza Financeira

			//ponto de entrada para adicionar a 5ª entidade na criação de título a receber - http://tdn.totvs.com/x/z4XlG
			If ExistBlock("OGX81SE1")
				aRetPeSE1 := ExecBlock("OGX81SE1",.F.,.F.,{aFina040, cCodPro})
				If ValType( aRetPeSE1 ) == "A"
					aFina040 := aClone(aRetPeSE1)
				EndIf	
			EndIf

			//Criando Vinculo com SE1
			aLinVncAux := {}

			aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('SE1') 	               } )
			aadd( aLinVncAux, { "N8L_FILORI"    	, N9U->N9U_FILORI				   } )
			aadd( aLinVncAux, { "N8L_PREFIX"    	, 'DCO'				               } )
			aadd( aLinVncAux, { "N8L_NUM"    		, N9X->N9X_SEQSE1 	               } )
			aadd( aLinVncAux, { "N8L_PARCEL"    	, N9X->N9X_PARSE1		           } )
			aadd( aLinVncAux, { "N8L_TIPO"    		, "PR "				               } )
			aadd( aLinVncAux, { "N8L_CODCTR"    	, ''             	               } )
			aadd( aLinVncAux, { "N8L_SAFRA"	    	, ''             	               } )
			aadd( aLinVncAux, { "N8L_CODROM"    	, ''				               } )
			aadd( aLinVncAux, { "N8L_ITEROM"   		, ''				               } )
			aadd( aLinVncAux, { "N8L_CODFIX"   		, ''				               } )
			aadd( aLinVncAux, { "N8L_CODOTR"    	, ''				               } )
			aadd( aLinVncAux, { "N8L_ORPGRC"   		, ''				               } )	
			aadd( aLinVncAux, { "N8L_ORIGEM"    	, 'OGA810'		 	               } )
			aadd( aLinVncAux, { "N8L_NUMAVI"    	, N9X->N9X_NUMAVI 	               } )
			aadd( aLinVncAux, { "N8L_NUMDCO"    	, N9X->N9X_NUMDCO	               } )
			aadd( aLinVncAux, { "N8L_SEQN9X"    	, N9X->N9X_SEQUEN	               } )
			aAdd( aLinVncAux, { "N8L_HISTOR"    	, FWI18NLang("OGA810",STR0031,175) } )  //"Título a Receber, Previsão de Recebimento do DCO."

			aAdd(aVncCRec,aLinVncAux)

			lMsErroAuto := .F.

			// Mudando o Modulo pois na Fina040 possui Validação AMI
			cModulo	:= 'FIN'
			nModulo := 6

			MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, nOperation )

			//Retornando Infs. Sobre o Modulo que se encontrava Logado
			cModulo	:= cModAtu
			nModulo := nModAtu

			If !lMsErroAuto
				If RecLock( "N9X", .F. )
					N9X->N9X_STAFIN := "2" //Aberto
					N9X->(MsUnlock())
				EndIf
			EndIf

			N9X->(DbSkip())
		EndDo

		IF !lMsErroAuto .and. Len( aVncCRec ) > 0

			lContinua := fAgrVncRec(aVncCRec, 3 )  //Incluir

		EndIf

	EndIf
	N9X->(DbCloseArea())	 

	//--RETORNA COM A FILIAL DE ORIGEM 
	cFilAnt := cFilOri

	RestArea(aArea)

	Return .T.

	/*/{Protheus.doc} OGA810VPF(oView, oButton)
	Função responsavel pela chamada da FA280Visua para visualizar o Título a receber da Previsão de Recebimento posicionada.
	@type  Function
	@author rafael.kleestadt
	@since 22/09/2018
	@version 1.0
	@param oView, object, Objeto da view
	@param oButton, object, Objeto do botão clicado
	@return .T., Logycal, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OGA810VPF(oView, oButton)
	Local oModelN9X  := oView:GetModel("N9XUNICO")
	Local oModelN9U  := oView:GetModel("N9UUNICO")
	Local cAviDCOSeq := AllTrim(oModelN9U:GetValue("N9U_NUMAVI")) + STR0015 + AllTrim(oModelN9U:GetValue("N9U_NUMDCO")) + STR0016 + AllTrim(oModelN9X:GetValue("N9X_SEQUEN")) //" , DCO" ### ", Sequencial " ###
	Local cFilOri	:= cFilAnt	//--SALVA A FILIAL LOGADA ANTES DE REALIZAR A TROCA DA FILIAL DO DCO

	Private cCadastro := STR0017 + cAviDCOSeq  + "." //"Título a Receber do Aviso "

	//--ALTERA A FILIAL CORRENTE PARA A FILIAL Do DCO
	cFilAnt := oModelN9U:GetValue("N9U_FILORI") 

	If !Empty(Posicione("SE1", 1,FwxFilial("SE1")+"DCO"+oModelN9X:GetValue("N9X_SEQSE1")+oModelN9X:GetValue("N9X_PARSE1"), "E1_NUM"))
		FA280Visua("SE1",SE1->(RECNO()),2, @cCadastro)
	Else
		HELP(' ',1,STR0018 ,,STR0019 + cAviDCOSeq +STR0020,2,0,,,,,, {STR0021})
		//"Título a Receber"###"O Aviso "###", não possuí título a receber gerado."###"Utilize a opção Gerar Título a Receber, ou escolha outro registro."
		Return .T.
	EndIf

	//--RETORNA COM A FILIAL DE ORIGEM 
	cFilAnt := cFilOri

Return .T.

/*/{Protheus.doc} fValVlCRec
Verifica se todas as Previsões de Recebimento do DCO possuem valor informado
@type  Static Function
@author rafael.kleestadt
@since 22/09/2018
@version 1.0
@param param, param_type, param_descr
@return .F., Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function fValVlCRec()

	DbSelectArea("N9X")
	DbSetOrder(1)
	If N9X->(DbSeek(N9U->(N9U_FILIAL+N9U_NUMAVI+N9U_NUMDCO)))
		While N9X->(!EOF()) .AND.  N9X->(N9X_FILIAL+N9X_NUMAVI+N9X_NUMDCO) == N9U->(N9U_FILIAL+N9U_NUMAVI+N9U_NUMDCO)

			If N9X->N9X_VALOR <> 0
				Return .T.
			Else
				N9X->(DbSkip())
				LOOP
			EndIf

		EndDo
	EndIf
	N9X->(DbCloseArea())

	If .Not. IsInCallStack('OGAA920')
		HELP(' ',1,AllTrim(RetTitle("N9X_VALOR")),,AllTrim(RetTitle("N9X_VALOR")) + STR0022,2,0,,,,,, {STR0023})
		//Valor###Valor###" não informado para a(s) previsão(ões) de recebimento do DCO."###"Informe o valor da(s) previsão(ões) de recebimento do DCO para prosseguir com esta ação."
	EndIf
	Return .F.

	/*/{Protheus.doc} OGA810DPF()
	Função que chama a fDelPrvFin e mostra o erro caso ocorra na deleção do título a receber
	@type  Function
	@author rafael.kleestadt
	@since 22/09/2028
	@version 1.1
	@param cFilN9U, caractere, filial do dco posicionado
	@param cNumAvi, caractere, número do aviso do dco posicionado
	@param cNumDco, caractere, número do dco posicionado
	@return .T., Logycal, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OGA810DPF(cFilN9U, cNumAvi, cNumDco)

	Local cFilOri	:= cFilAnt	//--SALVA A FILIAL LOGADA ANTES DE REALIZAR A TROCA DA FILIAL DO DCO
	Private lMsErroAuto := .F.

	DbSelectArea("N9U")
	DbSetOrder(1) //N9U_FILIAL+N9U_NUMAVI+N9U_NUMDCO
	If N9U->(DbSeek(cFilN9U + cNumAvi + cNumDco))

		//--ALTERA A FILIAL CORRENTE PARA A FILIAL Do DCO
		cFilAnt := N9U->N9U_FILORI 

		If fValDelRec()
			BEGIN TRANSACTION
				Processa({|| fDelPrvFin() }, STR0025) //Processando. "Excluindo Título(s) a Receber..."

				If lMsErroAuto
					DisarmTransaction() 
					MostraErro()
				Else
					//Atualiza o campo N9U_STAFIN e N9X_STAFIN
					AtuLegN9U()
				EndIf
			END TRANSACTION
		EndIf

		//--RETORNA COM A FILIAL DE ORIGEM 
		cFilAnt := cFilOri

	EndIf
	N9U->(DbCloseArea())

	Return .T.

	/*/{Protheus.doc} fDelPrvFin()
	Monta os arrays e chama as funções de exclusão da tabela de titulos a receber e vinculo N8L
	@type  Static Function
	@author rafael.kleestadt
	@since 22/09/2018
	@version 1.0
	@param param, param_type, param_descr
	@return .T., Logycal, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fDelPrvFin()
	Local aArea := GetArea()

	DbSelectArea("N8L")
	DbSetOrder(9) //N8L_FILIAL+N8L_PREFIX+N8L_NUMAVI+N8L_NUMDCO+N8L_SEQN9X
	If N8L->(DbSeek(FwxFilial("N8L")+N9U->("DCO"+N9U_NUMAVI+N9U_NUMDCO)))
		While N8L->(!EOF()) .AND.  N8L->(N8L_FILIAL+"DCO"+N8L_NUMAVI+N8L_NUMDCO) == FwxFilial("N8L")+N9U->("DCO"+N9U_NUMAVI+N9U_NUMDCO)

			fDItemSE1(N8L->N8L_NUM, N8L->N8L_PARCEL, N8L->N8L_NUMAVI, N8L->N8L_NUMDCO, N8L->N8L_SEQN9X)

			N8L->(DbSkip())
		EndDo
	EndIf
	N8L->(DbCloseArea())

	RestArea(aArea)

	Return .T.

	/*/{Protheus.doc} fValDelRec()
	Valida se o DCO possuí pelo menos um titulo gerado
	@type  Static Function
	@author rafael.kleestadt
	@since 22/09/2018
	@version 1.0
	@param param, param_type, param_descr
	@return .T., Logycal, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fValDelRec()

	DbSelectArea("N9X")
	DbSetOrder(1)
	If N9X->(DbSeek(N9U->(N9U_FILIAL+N9U_NUMAVI+N9U_NUMDCO)))
		While N9X->(!EOF()) .AND.  N9X->(N9X_FILIAL+N9X_NUMAVI+N9X_NUMDCO) == N9U->(N9U_FILIAL+N9U_NUMAVI+N9U_NUMDCO)

			DbSelectArea("SE1")
			DbSetOrder(1)
			If SE1->(DbSeek(FwxFilial("SE1")+"DCO"+N9X->N9X_SEQSE1+N9X->N9X_PARSE1+"PR "))
				Return .T.
			Else
				N9X->(DbSkip())
				LOOP
			EndIf
			SE1->(DbCloseArea())

			N9X->(DbSkip())
		EndDo
	EndIf
	N9X->(DbCloseArea())

	HELP(' ',1,STR0018,,STR0026+ AllTrim(N9U->N9U_NUMDCO) + STR0027+ AllTrim(N9U->N9U_NUMAVI) + STR0028,2,0,,,,,, {STR0029+ STR0012 + STR0030})
	//"Título a Receber"###"O DCO "###" ", do Aviso "### " não possuí títulos a receber gerados."###"Utilize a opção "### " para prosseguir com esta ação."
	Return .F.

	/*/{Protheus.doc} OGA810Est(cStatus)
	Define a cor do farol da Legenda	
	@author rafael.kleestadt
	@since 24/09/2018
	@version 1.0
	@param cStatus, caractere, Conteudo do campo N9U_STAFIN posicionado
	@return cStatus, caractere, nome do icone de legenda  ser exibido.
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OGA810Est(cStatus)

	Do Case
		Case cStatus == "1"
		cStatus := "BR_AZUL" //Pendente 
		Case cStatus == "2"
		cStatus := "BR_AMARELO" //Aberto
		Case cStatus == "3"
		cStatus := "BR_VERDE" //Finalizado
	EndCase

	Return cStatus 

	/*/{Protheus.doc} OGA810Leg()
	Exibe a Legenda	
	@author rafael.kleestadt
	@since 24/09/2018
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OGA810Leg()

	Local oLegenda := FWLegend():New() // Objeto FwLegend.

	oLegenda:Add("","BR_AZUL" 	 , X3CboxDesc("N9U_STAFIN",'1')) // "Pendente"
	oLegenda:Add("","BR_AMARELO" , X3CboxDesc("N9U_STAFIN",'2')) // "Aberto"
	oLegenda:Add("","BR_VERDE"   , X3CboxDesc("N9U_STAFIN",'3')) // "Finalizado"

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

	Return .T.

	/*/{Protheus.doc} AtuLegN9U()
	Atualiza o campo N9U_STAFIN conforme o saldo da SE1
	@type  Static Function
	@author rafael.kleestadt
	@since 24/09/2018
	@version 1.0
	@param param, param_type, param_descr
	@return .T., Logycal, True or False
	@example
	1.Pendente = Não gerou previsão pra todas as N9X
	2.Aberto = Gerou pra todas as N9X mas ainda possuí a pagar
	3.Finalizado = Gerou pra todas as N9X e estão todas pagas
	@see (links_or_references)
	/*/
Static Function AtuLegN9U()
	Local cStatus   := '1'
	Local lApagar   := .F.
	Local aArea     := GetArea()
	Local cAliasN8L := GetNextAlias()
	Local cQueryN8L := ""

	cQueryN8L := "   SELECT * "
	cQueryN8L += "     FROM " + RetSqlName('N8L') + " N8L "
	cQueryN8L += "    WHERE N8L.N8L_FILORI = '" + N9U->N9U_FILORI + "'"
	cQueryN8L += "      AND N8L.N8L_PREFIX = 'DCO'"
	cQueryN8L += "      AND N8L.N8L_NUMAVI = '" + N9U->N9U_NUMAVI + "'"
	cQueryN8L += "      AND N8L.N8L_NUMDCO = '" + N9U->N9U_NUMDCO + "'"
	cQueryN8L += "      AND N8L.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryN8L), cAliasN8L, .F., .T.)

	DbSelectArea(cAliasN8L)
	If (cAliasN8L)->(!EoF())
		While (cAliasN8L)->(!EoF())

			aFina040 := {}

			DbSelectArea("SE1")
			DbSetOrder(1)
			If SE1->(DbSeek((cAliasN8L)->(N8L_FILIAL)+"DCO"+(cAliasN8L)->(N8L_NUM+N8L_PARCEL)+"PR "))
				If ROUND(E1_SALDO,2) = 0 //Finalizado
					cStatus := '3'
				Else
					cStatus := '2' //Aberto
					lApagar := .T.
				EndIf
			Else
				cStatus := '1' //Pendente
				EXIT
			EndIf
			SE1->(DbCloseArea())

			DbSelectArea("N9X")
			DbSetOrder(1)
			If N9X->(DbSeek(FwxFilial("N9X")+(cAliasN8L)->(N8L_NUMAVI+N8L_NUMDCO+N8L_SEQN9X)))

				If RecLock( "N9X", .F. )
					N9X->N9X_STAFIN := cStatus
					N9X->(MsUnlock())
				EndIf

			EndIf
			N9X->(DbCloseArea())

			(cAliasN8L)->(dbSkip())
		EndDo

		If lApagar .And. cStatus <> '1'
			cStatus := '2'
		EndIf

	EndIf

	(cAliasN8L)->(DbCloseArea())

	If RecLock( "N9U", .F. )
		N9U->N9U_STAFIN := cStatus
		N9U->(MsUnlock())
	EndIf

	RestArea(aArea)

	Return .T.

/*/{Protheus.doc} GrvModelo(oModel)
Função de Gravação do Modelo
@type  Static Function
@author rafael.kleestadt
@since 24/09/2018
@version 1.0
@param oModel, Object, Objeto do modelo principal
@return lRet, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvModelo(oModel)
	Local oModelN9U  := oModel:GetModel("N9UUNICO")
	Local nOperation := oModel:GetOperation()
	Local lRet       := FWFormCommit( oModel )

	If lRet

		//Atualiza o campo N9U_STAFIN e N9X_STAFIN
		AtuLegN9U()

	EndIf

	//Atualiza a previsão de recebimento
	If nOperation <> MODEL_OPERATION_DELETE .And. lRet
		Processa({|| OGA810AVLP(oModelN9U:GetValue("N9U_FILIAL"), oModelN9U:GetValue("N9U_NUMAVI"), oModelN9U:GetValue("N9U_NUMDCO"))}, STR0032) //"Aguarde. Atualizando previsão de recebimento..."
	EndIf

Return lRet

	/*/{Protheus.doc} fDItemSE1()
	Exclui o título a receber e o vinculo com o Agro N8L
	@type  Static Function
	@author rafael.kleestadt
	@since 26/09/2018
	@version 1.0
	@param cNum, caractere, número do título
	@param cParcel, caractere, parcela do título
	@param cNumAvi, caractere, número do aviso pepro
	@param cNumDco, caractere, número do DCO do aviso pepro
	@param cSeqN9X, caractere, sequencial da previsão de recebimento do DCO do aviso pepro
	@return .T., Logycal, True or False
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fDItemSE1(cNum, cParcel, cNumAvi, cNumDco, cSeqN9X)
	Local aFiliais   := FwLoadSM0()
	Local aFina040   := {}
	Local aVncCRec   := {}
	Local aLinvncAux := {}
	Local nX         := 0
	Local aArea      := GetArea()

	// Salvando Infs. sobre o Modulo Atual
	Local cModAtu := cModulo
	Local nModAtu := nModulo

	For nX := 1 To Len(aFiliais)

		If aFiliais[nX][2] == N9U->(N9U_FILORI)
			cCliente := Posicione("SA1", 3, FwxFilial("SA1") + aFiliais[nX][18], "A1_COD")
			cLojCli  := Posicione("SA1", 3, FwxFilial("SA1") + aFiliais[nX][18], "A1_LOJA")
			EXIT
		EndIf

	Next nX

	aFina040 := {}

	DbSelectArea("SE1")
	DbSetOrder(1)
	If SE1->(DbSeek(FwxFilial("SE1")+"DCO"+cNum+cParcel+"PR "))

		aAdd( aFina040, { "E1_PREFIXO" , "DCO"    , Nil } )
		aAdd( aFina040, { "E1_NUM"     , cNum     , Nil } )
		aAdd( aFina040, { "E1_PARCELA" , cParcel  , Nil } )
		aAdd( aFina040, { "E1_TIPO"    , "PR "    , Nil } )
		aAdd( aFina040, { "E1_CLIENTE" , cCliente , Nil } )
		aAdd( aFina040, { "E1_LOJA"    , cLojCli  , Nil } )

		//Removento o vinculo da SE1 
		aLinVncAux := {}
		aadd( aLinVncAux, { "N8L_FILIAL" , FwXfilial('N8L') } )
		aadd( aLinVncAux, { "N8L_PREFIX" , "DCO"      	    } )
		aadd( aLinVncAux, { "N8L_NUM"    , cNum             } )
		aadd( aLinVncAux, { "N8L_PARCEL" , cParcel          } )
		aadd( aLinVncAux, { "N8L_TIPO"   , "PR "		    } )

		aAdd(aVncCRec, aLinvncAux)

		// Mudando o Modulo pois na Fina040 possui Validação AMI
		cModulo	:= 'FIN'
		nModulo := 6

		MsExecAuto( { |x,y| Fina040( x, y ) }, aFina040, 5 )

		//Retornando Infs. Sobre o Modulo que se encontrava Logado
		cModulo	:= cModAtu
		nModulo := nModAtu

		If !lMsErroAuto
			DbSelectArea("N9X")
			DbSetOrder(1)
			If N9X->(DbSeek(FwxFilial("N9X")+cNumAvi+cNumDco+cSeqN9X))

				If RecLock( "N9X", .F. )
					N9X->N9X_STAFIN := "1" //Pendente
					N9X->(MsUnlock())
				EndIf

			EndIf
			N9X->(DbCloseArea())
		EndIf

	EndIf
	SE1->(DbCloseArea())

	IF !lMsErroAuto .and.  len( aVncCRec ) > 0

		lContinua:= fAgrVncRec(aVncCRec, 5 ) //Excluir

	EndIf

	RestArea(aArea)

Return .T.


/*/{Protheus.doc} fGetUniAvi
Função responsavel por gatilhar os campos de unidade.
@type  Static Function
@author Christopher.miranda
@since 24/10/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function fGetUniAvi()
	Local oModel  := FwModelActive()
	Local oView   := FWViewActive()
	Local oMdlN9U := oModel:GetModel("N9UUNICO")
	Local oGrdN9W := oModel:GetModel("N9WUNICO")
	Local nX      := 0
	Local cNumAvi := oMdlN9U:GetValue( "N9U_NUMAVI" )
	Local cUniMed := ''
	Local cUnMePr := ''
	Local aArea   := GetArea()

	If ExistCpo('N9N',cNumAvi)

		cUniMed := Posicione("N9N",1,xFilial("N9N")+cNumAvi,'N9N_UNIMED')
		cUnMePr := Posicione("N9N",1,xFilial("N9N")+cNumAvi,'N9N_UNMEPR')

		For nX := 1 to oGrdN9W:Length()

			oGrdN9W:GoLine( nX )

			If .Not. oGrdN9W:IsDeleted()

				oGrdN9W:LoadValue( "N9W_UMAVI", cUniMed )
				oGrdN9W:LoadValue( "N9W_UMPRE", cUnMePr )

			EndIf

		Next nX

	Else

		Return .F.

	endif

	If !IsBlind()
		oView:Refresh()
	EndIf

	RestArea(aArea)

	Return .T.

	/*/{Protheus.doc} fAddN9X()
	Função que somente na inclusão, cria uma linha na grid de Previsão Recebimento(N9X) com base na linha com valor total da Comprovação DCO(N9W)
	@type  Static Function
	@author rafael.kleestadt
	@since 05/11/2018
	@version 1.0
	@param param, param_type, param_descr
	@return true, logycal, true or false
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fAddN9X()
	Local oModel     := FwModelActive()
	Local oView      := FwViewActive()
	Local oModelN9X  := oModel:GetModel("N9XUNICO")
	Local oModelN9W  := oModel:GetModel("N9WUNICO")
	Local oModelN9U  := oModel:GetModel("N9UUNICO")
	Local nOperation := oModel:GetOperation()
	Local nX         := 0

	//Somente na Inclusão ou Alteração
	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

		For nX := 1 to oModelN9W:Length()
			oModelN9W:GoLine( nX )

			if !oModelN9W:IsDeleted()

				If oModelN9W:GetValue("N9W_QUANT") == oModelN9U:GetValue("N9U_QUANT")

					oModelN9X:GoLine( 1 )

					oModelN9X:SetValue("N9X_PARSE1", "01")
					oModelN9X:SetValue("N9X_STAFIN", "1")
					oModelN9X:SetValue("N9X_VALOR", oModelN9W:GetValue("N9W_VLPREV"))

					If Empty(oModelN9X:GetValue("N9X_SEQSE1"))
						oModelN9X:SetValue("N9X_SEQSE1", GetSXENum('N9X','N9X_SEQSE1'))
					EndIf
					If !IsBlind()
						oView:Refresh()
					EndIf

					EXIT

				EndIf

			EndIf

		Next nX

	EndIf

Return .T.

/*/{Protheus.doc} nomeFunction
(long_description)
@type  Function
@author user
@since date
@version version
@param cFilN9U, caractere, filial do DCO
@param cNumAvi, caractere, código do aviso pepro do DCO
@param cNumDco, caractere, código do DCO do aviso pepro 
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function OGA810AVLP(cFilN9U, cNumAvi, cNumDco, cTipAvi)
	Local nQtdN9U    := Posicione("N9U", 1, cFilN9U+cNumAvi+cNumDco, "N9U_QUANT" )
	Local nVlRecPre  := 0
	Local cUfDest    := ''	
	Local cTpReg     := Posicione("N9N", 1, cFilN9U+cNumAvi, "N9N_TIPREG")
	Local cFilOriN9U := Posicione("N9U", 1, cFilN9U+cNumAvi+cNumDco, "N9U_FILORI")
	Local cUfOrig    := POSICIONE("SM0", 1, cEmpAnt+cFilOriN9U,"M0_ESTENT")
	Local cCodReg    := fGetCdReg(cFilOriN9U, cTpReg) 
	Local cCodPro    := ''
	Local cUMDes     := ''
	Local cUMOri     := ''
	Local nVlrPre    := 0 
	Local nPrMiDco   := fGetPMDCO(cNumAvi, dDataBase, cTipAvi, cUfOrig, cUfDest, cCodReg)	
	Local cPrevOK    := POSICIONE("N9X", 1, cFilN9U+cNumAvi+cNumDco,"N9X_STAFIN")
	Local aVlTotNf   := {}
	Local cQuery     := ""
	Local cAliasIE   := ""
	Local aDCOVinc   := {}
	Local nPos       := 0
	Local cAliasCtr  := ""
	Local nQtd       := 0
	Local nX		 := 0
	
	// verificar se a previsao esta aberta ou pendente
	IF cPrevOK = "3"	
		Return .T.
	EndIf

	// valor inicial da revisao do premio que esta na um do aviso  N9N->N9N_UNIMED
	DbSelectArea("N9N")
	N9N->(dbSetOrder(1))
	If  N9N->(dbSeek(xFilial("N9N")+cNumAvi))
		cCodPro  := N9N->N9N_CODPRO
		cUMDes   := N9N->N9N_UNIMED
	EndIf

	//Busca todas as NFs com o Aviso/DCO/SeqDco vinculado
	aVlTotNf := fVlNfDco(cFilN9U, cNumAvi, cNumDco, cFilOriN9U, cUfOrig, cUfDest, cCodReg, cUMDes, cCodPro)
	
	// Busca os valores do PEPRO vinculados a IE
	cQuery := " SELECT SUM(NLN.NLN_PRECO * (NLN.NLN_QTDVIN - NLN.NLN_QTDFAT)) AS VLVINC, "
	cQuery += "        SUM(NLN.NLN_QTDVIN - NLN.NLN_QTDFAT) AS QTVINC, "
	cQuery += "        NLN.NLN_CODCTR, NLN.NLN_ITEMPE, NLN.NLN_ITEMRF, NLN.NLN_SEQDCO "
	cQuery += "   FROM " + RetSQLName("NLN") + " NLN "
	cQuery += "  WHERE NLN.NLN_FILIAL = '" + cFilN9U + "' "
	cQuery += "    AND NLN.NLN_NUMAVI = '" + cNumAvi + "' "
	cQuery += "    AND NLN.NLN_NUMDCO = '" + cNumDco + "' "
	cQuery += "    AND NLN.NLN_CODINE != ' ' "
	cQuery += "    AND NLN.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY NLN_CODCTR, NLN_ITEMPE, NLN_ITEMRF, NLN_SEQDCO "
	
	cQuery := ChangeQuery(cQuery)
   
	cAliasIE := GetNextAlias()			
	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliasIE, .F., .T.)
   
	DbselectArea(cAliasIE)
	(cAliasIE)->(DbGoTop())
   
	If !(cAliasIE)->(Eof())
   		
		While !(cAliasIE)->(Eof())
		
			nPos := AScan(aDCOVinc, {|x| AllTrim(x[1]) == AllTrim((cAliasIE)->NLN_CODCTR+(cAliasIE)->NLN_ITEMPE+(cAliasIE)->NLN_ITEMRF+(cAliasIE)->NLN_SEQDCO)})
			
			cUMOri := Posicione("NJR",1, cFilN9U + (cAliasIE)->NLN_CODCTR, "NJR_UM1PRO")
			nQtd   := OGX700UMVL((cAliasIE)->QTVINC, cUMOri, cUMDes, cCodPro)
			nValV  := ((cAliasIE)->QTVINC * nPrMiDco) - (cAliasIE)->VLVINC
			
			If nPos > 0				
				aDCOVinc[nPos][2] += IIf(nValV > 0, nValV, 0)
				aDCOVinc[nPos][3] += nQtd			
			Else				
				Aadd(aDCOVinc, {(cAliasIE)->NLN_CODCTR+(cAliasIE)->NLN_ITEMPE+(cAliasIE)->NLN_ITEMRF+(cAliasIE)->NLN_SEQDCO,; 
				    			IIf(nValV > 0, nValV, 0),;
					    		nQtd})				
			EndIf
			
			(cAliasIE)->(DbSkip())
		EndDo		
	EndIf
	(cAliasIE)->(DbCloseArea())
	
	// Busca os valores do PEPRO vinculados a Contrato
	cQuery := " SELECT SUM(NLN.NLN_PRECO * (NLN.NLN_QTDVIN - NLN.NLN_QTDFAT)) AS VLVINC, "
	cQuery += "        SUM(NLN.NLN_QTDVIN - NLN.NLN_QTDFAT) AS QTVINC, "
	cQuery += "        NLN.NLN_CODCTR, NLN.NLN_ITEMPE, NLN.NLN_ITEMRF, NLN.NLN_SEQDCO "
	cQuery += "   FROM " + RetSQLName("NLN") + " NLN "
	cQuery += "  WHERE NLN.NLN_FILIAL = '" + cFilN9U + "' "
	cQuery += "    AND NLN.NLN_NUMAVI = '" + cNumAvi + "' "
	cQuery += "    AND NLN.NLN_NUMDCO = '" + cNumDco + "' "
	cQuery += "    AND NLN.NLN_CODINE = ' ' "
	cQuery += "    AND NLN.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY NLN_CODCTR, NLN_ITEMPE, NLN_ITEMRF, NLN_SEQDCO "
	
	cQuery := ChangeQuery(cQuery)
   
	cAliasCtr := GetNextAlias()			
	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliasCtr, .F., .T.)
   
	DbselectArea(cAliasCtr)
	(cAliasCtr)->(DbGoTop())
   
	If !(cAliasCtr)->(Eof())
   		
		While !(cAliasCtr)->(Eof())
		
			nPos := AScan(aDCOVinc, {|x| AllTrim(x[1]) == AllTrim((cAliasCtr)->NLN_CODCTR+(cAliasCtr)->NLN_ITEMPE+(cAliasCtr)->NLN_ITEMRF+(cAliasCtr)->NLN_SEQDCO)})
			
			cUMOri := Posicione("NJR",1, cFilN9U + (cAliasCtr)->NLN_CODCTR, "NJR_UM1PRO")
			nQtd   := OGX700UMVL((cAliasCtr)->QTVINC, cUMOri, cUMDes, cCodPro)
			nValV  :=  ((cAliasCtr)->QTVINC * nPrMiDco) - (cAliasCtr)->VLVINC
			
			If nPos > 0			
				If nQtd > aDCOVinc[nPos][3] 					
					aDCOVinc[nPos][2] := IIf(nValV > 0, nValV, 0)
					aDCOVinc[nPos][3] := nQtd
				EndIf
			Else				
				Aadd(aDCOVinc, {(cAliasCtr)->NLN_CODCTR+(cAliasCtr)->NLN_ITEMPE+(cAliasCtr)->NLN_ITEMRF+(cAliasCtr)->NLN_SEQDCO,; 
				    			IIf(nValV > 0, nValV, 0),;
					    		nQtd})				
			EndIf
			
			(cAliasCtr)->(DbSkip())
		EndDo		
	EndIf
	(cAliasCtr)->(DbCloseArea())
	
	// Soma o valor e a quantidade de DCO vinculados no contrato/Ie (Não considera o faturado) 
	nVDCOV := 0
	nQDCOV := 0
	
	For nX := 1 to Len(aDCOVinc)
		
		nVDCOV += aDCOVinc[nX][2]
		nQDCOV += aDCOVinc[nX][3]
		
	Next nX
	
	// Previsao do premio recebe o saldo do DCO
	// nVlrPre  - encontrar premio unitario de venda conforme indice par aa moeda do preco minimo
	nVlrPre := AgrGetInd(N9N->N9N_INDPRE ,'T', dDataBase, N9N->N9N_CODPRO, '', N9N->N9N_SAFRA, cUfOrig, cUfDest, '', cCodReg, cUMDes)							

	nVlRecPre :=  IIf((nQtdN9U - nQDCOV) > 0,  (nQtdN9U - nQDCOV) * nVlrPre , 0)
	nVlRecPre += nVDCOV + aVlTotNf[1]

	// Atualiza N9x e Financeiro
	Oga810AN9X(nVlRecPre, aVlTotNf[2], aVlTotNf[1], nQDCOV, nVDCOV, cUMDes, nPrMiDco, nVlrPre, IIf((nQtdN9U - nQDCOV) > 0, (nQtdN9U - nQDCOV), 0))
		
Return .T.


/*/{Protheus.doc} fGetPMDCO
Função que busca o preço mínimo
@type  Static Function
@author rafael.kleestadt
@since 08/11/2018
@version 1.0
@param cAviso, caractere, numero do aviso Pepro
@param dDtEmiNf, date, data de emissão da nota fiscal
@param cTpAvis, caractere, tipo de algodão do seq do dco do aviso pepro
@param cUfOrig, caractere, estado de origem do seq do dco do aviso pepro
@param cUfDest, caractere, estado de origem do seq do dco do aviso pepro
@param cCodReg, caractere, região de origem do seq do dco do aviso pepro
@return nPrMiDco, numeric, preço minimo para o estado de orig. região
@example
(examples)
@see (links_or_references)
/*/
Static Function fGetPMDCO(cAviso, dDtEmiNf, cTpAvis, cUfOrig, cUfDest, cCodReg)
	Local nPrMiDco := 0

	dbSelectArea("N9N")
	N9N->(dbSetOrder(1))
	If  N9N->(dbSeek(xFilial("N9N")+cAviso))
    	// nPrMiDco  - encontrar preço minimo do estado/regiao do DCO
		nPrMiDco := AgrGetInd( N9N->N9N_INDICE, "T", dDtEmiNf, N9N->N9N_CODPRO, cTpAvis, N9N->N9N_SAFRA, cUfOrig, cUfDest, '', cCodReg, N9N->N9N_UNIMED)												    
	EndIF
	N9N->(DbCloseArea())

Return nPrMiDco


/*/{Protheus.doc} fGetCdReg
Função que retorna o código da região com base na filial de origem do DCO do Aviso Pepro e tipo da região
@type  Static Function
@author rafael.kleestadt
@since 08/11/2018
@version 1.0
@param cFilOriN9U, caractere, filial de origem do dco do aviso pepro
@param cTpReg, caractere, tipo de região do aviso pepro
@return cCodReg, caractere, código da região com base na filial de origem do DCO do Aviso Pepro e tipo da região
@example
(examples)
@see (links_or_references)
/*/
Static Function fGetCdReg(cFilOriN9U, cTpReg)

	Local cUFSM0     := POSICIONE("SM0",1,cEmpAnt+cFilOriN9U,"M0_ESTENT")    
	Local cCISM0     := SubStr(POSICIONE("SM0",1,cEmpAnt+cFilOriN9U,"M0_CODMUN"), 3, TamSx3('CC2_CODMUN')[1])
	Local cCodReg    := ""
	Local cQuery     := ""
	Local cAliasQry  := GetNextAlias()

	//buscar região com estado e cidade da filial do aviso
	cQuery := "     SELECT NBR.NBR_CODREG FROM " + RetSqlName("NBR") + " NBR "
	cQuery += " INNER JOIN " + RetSqlName("NBQ") + " NBQ  "
	cQuery += "         ON NBQ_CODREG = NBR_CODREG and NBQ.D_E_L_E_T_ = ''"
	cQuery += "      WHERE NBQ_TIPREG = '"+ cTpReg + "'"
	cQuery += "        AND NBR_ESTADO = '"+ cUFSM0 + "'"
	cQuery += "        AND NBR_CODMUN = '"+ cCISM0 + "'"
	cQuery += "        AND NBR.D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof() )
		cCodReg   := (cAliasQry)->NBR_CODREG	
	EndIf
	(cAliasQry)->(DbcloseArea())

Return cCodReg



/*{Protheus.doc} Oga810AN9X
@author vanilda.moggio
@since 13/11/2018
@version 1.0
@return ${return}, ${return_description}
@param nVlTPrev, numeric, descricao
@type function */
Function Oga810AN9X(nVlTPrev,nQTDNFS,nVlRNFS,nQTDVIN,nVLRVIN,nUNIMED,nVLUNMI,nVLUNPR,nQTDPR)
	Local lRet := .T.
	Private lMsErroAuto := .F.

	If  nVlTPrev > 0 
		BEGIN TRANSACTION
			
			DbSelectArea("N9X")
			DbSetOrder(1)
			If  N9X->(DbSeek(N9U->(N9U_FILIAL+N9U_NUMAVI+N9U_NUMDCO))) 
				While N9X->(!EOF()) .AND.  N9X->(N9X_FILIAL+N9X_NUMAVI+N9X_NUMDCO) == N9U->(N9U_FILIAL+N9U_NUMAVI+N9U_NUMDCO)
					If  RecLock( "N9X", .F. )
						N9X->N9X_UNIMED:= nUNIMED // unidade de medida da previsao semre igual a UM aviso
						N9X->N9X_VALOR := nVlTPrev // valor total da previsao (saldo do dco + saldo vinculado + faturado)
						N9X->N9X_VLUNPR:= nVLUNPR //valor unitario do premio que será multiplicado pela qtd saldo dco
				        N9X->N9X_QTSDCO:= nQTDPR // saldo do DCO em quantidade
				        N9X->N9X_VlSDCO:= nQTDPR * nVLUNPR // saldo do DCO em valor 
						N9X->N9X_QTDNFS:= nQTDNFS
						N9X->N9X_VlRNFS:= nVlRNFS  
						N9X->N9X_QTDVIN:= nQTDVIN
						N9X->N9X_VLRVIN:= nVLRVIN
						N9X->N9X_VLUNMI:= nVLUNMI
						
						N9X->(MsUnlock())

					EndIf
					N9X->(DbSkip())
				EndDo		
			EndIf
			N9X->(DbCloseArea())

			Processa({|| fGerPrvFin() }, STR0014) //Processando. "Gerando/Atualizando Título(s) a Receber do DCO..."

			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				lRet := .F.
			Else
				//Atualiza o campo N9U_STAFIN e N9X_STAFIN
				AtuLegN9U()
			EndIf
		END TRANSACTION
	EndIf		

Return lRet

/*/{Protheus.doc} fVlNfDco
Retorna o valor a receber comprovado em Nfs
@type  Static Function
@author rafael.kleestadt
@since 09/11/2018
@version 1.0
@param cFilN9U, caractere, filial do DCO
@param cNumAvi, caractere, código do aviso pepro do DCO
@param cNumDco, caractere, código do DCO do aviso pepro
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fVlNfDco(cFilN9U, cNumAvi, cNumDco, cFilOriN9U, cUfOrig, cUfDest, cCodReg, cUMDes, cCodPro)
	Local cQry       := ""
	Local cAliasQry  := GetNextAlias()
	Local nPrMiNf    := 0
	Local nVlTotNf   := 0
	Local nQtTOTNf   := 0

	//Busca todas as NFs com o Aviso/DCO/SeqDco vinculado
	cQry := "      SELECT SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_EMISSAO, N8K.N8K_TPAVIS, N8K.N8K_SEQDCO, N8K.N8K_CODCTR, SD2.D2_UM "
	cQry += "        FROM " + RetSqlName("N8K") + " N8K "
	cQry += "  INNER JOIN " + RetSqlName("SF2") + " SF2 ON SF2.F2_FILIAL = N8K.N8K_FILIAL AND F2_DOC = N8K_DOC and F2_SERIE = N8K_SERIE and SF2.D_E_L_E_T_ = ''
	cQry += "  INNER JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL AND D2_DOC = F2_DOC and D2_SERIE = F2_SERIE and SD2.D_E_L_E_T_ = ''

	cQry += "  LEFT OUTER JOIN (SELECT D1_FILIAL,D1_NFORI,D1_SERIORI,D1_ITEMORI,D1_QUANT AS QTDDEV " 
	cQry += "   	           FROM " + RetSqlName("SD1") + " SD1X "
	cQry += "   	           INNER JOIN " + RetSqlName("NJM") + " NJM ON NJM.D_E_L_E_T_ = '' AND NJM.NJM_CODROM = D1_CODROM "
	cQry += "   	           AND NJM.NJM_ITEROM = D1_ITEROM AND NJM.NJM_CONDCO = '1' " //NJM.NJM_CONDCO = '1' = Considera DCO na Devolução
	cQry += "   	           WHERE SD1X.D_E_L_E_T_ = '' ) "
	cQry += "    SD1 ON SD1.D1_FILIAL = N8K.N8K_FILIAL AND D1_NFORI = N8K.N8K_DOC "
	cQry += "    AND D1_SERIORI = N8K.N8K_SERIE AND D1_ITEMORI = N8K.N8K_ITEDOC

	cQry += "       WHERE N8K.N8K_FILIAL = '"+ cFilOriN9U + "'"
	cQry += "         AND N8K.N8K_NUMAVI = '"+ cNumAvi    + "'"
	cQry += "         AND N8K.N8K_NUMDCO = '"+ cNumDco    + "'"
	cQry += "         AND N8K.D_E_L_E_T_ = ''
	cQry += "    GROUP BY SD2.D2_PRCVEN, SD2.D2_QUANT, SD2.D2_EMISSAO, N8K.N8K_TPAVIS, N8K.N8K_SEQDCO, N8K.N8K_CODCTR, SD2.D2_UM 
	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry), cAliasQry, .F., .T.)

	If (cAliasQry)->(!EoF())
		While (cAliasQry)->(!EoF())					
			//Obtém o preço mínimo 
			cUfDest := POSICIONE("N9W", 1, cFilN9U+cNumAvi+cNumDco+(cAliasQry)->N8K_SEQDCO,"N9W_EST")
			nPrMiNf := fGetPMDCO(cNumAvi, StoD((cAliasQry)->D2_EMISSAO), (cAliasQry)->N8K_TPAVIS, cUfOrig, cUfDest, cCodReg )

			//premio real conforme NF e U.M aviso
			nVlNf    := OGX700UMVL(((cAliasQry)->D2_QUANT * (cAliasQry)->D2_PRCVEN), (cAliasQry)->D2_UM, cUMDes, cCodPro)	
			nVlTotNf += ((cAliasQry)->D2_QUANT * nPrMiNf) - nVlNf 
			nQtTOTNf += (cAliasQry)->D2_QUANT
			(cAliasQry)->(dbSkip())
		End
	EndIf
	(cAliasQry)->(dbCloseArea())

Return {nVlTotNf, nQtTOTNf}

/*{Protheus.doc} QtdVincDCO
Retorna o array com as versões do DCO e as quantidades vinculadas

@type  Static Function
@author francisco.nunes
@since 16/04/2019
@version 1.0
@param cFilAvi, caractere, Filial do Aviso PEPRO
@param cNumAvi, caractere, código do aviso pepro
@param cNumDco, caractere, código do DCO do aviso pepro
@return aQDCO, array, Sequencial do DCO + Quantidades 
*/
Static Function QtdVincDCO(cFilAvi, cNumAvi, cNumDco)

	Local cQuery    := ""
	Local cAliasIE  := ""
	Local cAliasCtr := ""
	Local aDCOVinc  := {}
	Local cUMOri    := ""
	Local nQtd      := 0
	Local aQDCO     := {}
	Local nX        := 0
	
	// valor inicial da revisao do premio que esta na um do aviso  N9N->N9N_UNIMED
	DbSelectArea("N9N")
	N9N->(dbSetOrder(1))
	If  N9N->(dbSeek(cFilAvi+cNumAvi))
		cCodPro  := N9N->N9N_CODPRO
		cUMDes   := N9N->N9N_UNIMED
	EndIf

	// Busca os valores do PEPRO vinculados a IE
	cQuery := " SELECT SUM(NLN.NLN_QTDVIN) AS QTVINC, "
	cQuery += "        NLN.NLN_CODCTR, NLN.NLN_ITEMPE, NLN.NLN_ITEMRF, NLN.NLN_SEQDCO "
	cQuery += "   FROM " + RetSQLName("NLN") + " NLN "
	cQuery += "  WHERE NLN.NLN_FILIAL = '" + cFilAvi + "' "
	cQuery += "    AND NLN.NLN_NUMAVI = '" + cNumAvi + "' "
	cQuery += "    AND NLN.NLN_NUMDCO = '" + cNumDco + "' "
	cQuery += "    AND NLN.NLN_CODINE != ' ' "
	cQuery += "    AND NLN.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY NLN_CODCTR, NLN_ITEMPE, NLN_ITEMRF, NLN_SEQDCO "
	
	cQuery := ChangeQuery(cQuery)
   
	cAliasIE := GetNextAlias()			
	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliasIE, .F., .T.)
   
	DbselectArea(cAliasIE)
	(cAliasIE)->(DbGoTop())
   
	If !(cAliasIE)->(Eof())
   		
		While !(cAliasIE)->(Eof())
		
			nPos := AScan(aDCOVinc, {|x| AllTrim(x[1]) == AllTrim((cAliasIE)->NLN_CODCTR+(cAliasIE)->NLN_ITEMPE+(cAliasIE)->NLN_ITEMRF+(cAliasIE)->NLN_SEQDCO)})
			
			cUMOri := Posicione("NJR",1, cFilAvi + (cAliasIE)->NLN_CODCTR, "NJR_UM1PRO")
			nQtd   := OGX700UMVL((cAliasIE)->QTVINC, cUMOri, cUMDes, cCodPro)
						
			If nPos > 0				
				aDCOVinc[nPos][2] += nQtd			
			Else				
				Aadd(aDCOVinc, {(cAliasIE)->NLN_CODCTR+(cAliasIE)->NLN_ITEMPE+(cAliasIE)->NLN_ITEMRF+(cAliasIE)->NLN_SEQDCO, nQtd, (cAliasIE)->NLN_SEQDCO})				
			EndIf
			
			(cAliasIE)->(DbSkip())
		EndDo		
	EndIf
	(cAliasIE)->(DbCloseArea())
	
	// Busca os valores do PEPRO vinculados a Contrato
	cQuery := " SELECT SUM(NLN.NLN_QTDVIN) AS QTVINC, "
	cQuery += "        NLN.NLN_CODCTR, NLN.NLN_ITEMPE, NLN.NLN_ITEMRF, NLN.NLN_SEQDCO "
	cQuery += "   FROM " + RetSQLName("NLN") + " NLN "
	cQuery += "  WHERE NLN.NLN_FILIAL = '" + cFilAvi + "' "
	cQuery += "    AND NLN.NLN_NUMAVI = '" + cNumAvi + "' "
	cQuery += "    AND NLN.NLN_NUMDCO = '" + cNumDco + "' "
	cQuery += "    AND NLN.NLN_CODINE = ' ' "
	cQuery += "    AND NLN.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY NLN_CODCTR, NLN_ITEMPE, NLN_ITEMRF, NLN_SEQDCO "
	
	cQuery := ChangeQuery(cQuery)
   
	cAliasCtr := GetNextAlias()			
	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliasCtr, .F., .T.)
   
	DbselectArea(cAliasCtr)
	(cAliasCtr)->(DbGoTop())
   
	If !(cAliasCtr)->(Eof())
   		
		While !(cAliasCtr)->(Eof())
		
			nPos := AScan(aDCOVinc, {|x| AllTrim(x[1]) == AllTrim((cAliasCtr)->NLN_CODCTR+(cAliasCtr)->NLN_ITEMPE+(cAliasCtr)->NLN_ITEMRF+(cAliasCtr)->NLN_SEQDCO)})
			
			cUMOri := Posicione("NJR",1, cFilAvi + (cAliasCtr)->NLN_CODCTR, "NJR_UM1PRO")
			nQtd   := OGX700UMVL((cAliasCtr)->QTVINC, cUMOri, cUMDes, cCodPro)
			
			If nPos > 0			
				If nQtd > aDCOVinc[nPos][2] 					
					aDCOVinc[nPos][2] := nQtd
				EndIf
			Else				
				Aadd(aDCOVinc, {(cAliasCtr)->NLN_CODCTR+(cAliasCtr)->NLN_ITEMPE+(cAliasCtr)->NLN_ITEMRF+(cAliasCtr)->NLN_SEQDCO, nQtd, (cAliasCtr)->NLN_SEQDCO})				
			EndIf
			
			(cAliasCtr)->(DbSkip())
		EndDo		
	EndIf
	(cAliasCtr)->(DbCloseArea())
		
	For nX := 1 to Len(aDCOVinc)
	
		nPos := AScan(aQDCO, {|x| AllTrim(x[1]) == aDCOVinc[nX][3]})
		
		If nPos > 0
			aQDCO[nPos][2] += aDCOVinc[nX][2]
		Else
			Aadd(aQDCO, {aDCOVinc[nX][3], aDCOVinc[nX][2]})
		EndIf			
		
	Next nX
		
Return aQDCO
