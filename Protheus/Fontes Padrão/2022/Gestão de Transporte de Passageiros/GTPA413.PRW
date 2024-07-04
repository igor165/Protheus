#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA413.CH"
#INCLUDE "APWEBSRV.CH"

#DEFINE WS_COLS 02	//Quantidade de colunas da WorkSheet
#DEFINE WS_ROWS 10	//Quantidade de linhas da WorkSheet

Static oWkSheet	:= nil	//Objeto da Planilha de Cálculo
Static _XmlPlan:= ""
//------------------------------------------------------------------------------  
/*/{Protheus.doc} GTPA413  
  
Cadastro de F¢rmulas de ComissÆo  
  
@sample 	 GTPA413()  
  
@return	 Nil  
@author	 Wanderley Monteiro da Silva  
@since	 03/07/2015  
@version	 P12  
@comments  
/*/  
//------------------------------------------------------------------------------
Function GTPA413()

	Local oBrowse := nil

		 oBrowse := FWMBrowse():New()
		 oBrowse:SetAlias('GQ5')
		 oBrowse:SetDescription(STR0001)//"Fórmulas de Comissão"
		
		 oBrowse:Activate()

 Return oBrowse
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@sample		ModelDef()

@return		oModel 		Objeto do Model

@author		Wanderley Monteiro da Silva 
@since		 03/07/2015  
@version	P12

/*/
//-------------------------------------------------------------------
 Static Function ModelDef()

	Local oStruGQ5	:= FWFormStruct(1, 'GQ5')
	Local bCommit	:= {|| CommitModel(oModel)}
	Local bPos413	:= { |oModel| VldTudoK(oModel) }
	Local oModel	:=  MPFormModel():New('GTPA413',/*bPreVld*/, bPos413, bCommit)	

		oModel:AddFields( 'GQ5MASTER', /*cOwner*/, oStruGQ5 )
		oStruGQ5:SetProperty("GQ5_CODIGO",MODEL_FIELD_WHEN,{|| INCLUI})
		oStruGQ5:SetProperty("GQ5_DESCRI",MODEL_FIELD_WHEN,{|| INCLUI})
		oStruGQ5:SetProperty("GQ5_XML", MODEL_FIELD_OBRIGAT, .F.)
		
		oModel:SetPrimaryKey({ 'GQ5_FILIAL', 'GQ5_CODIGO'})
		oModel:SetDescription(STR0001) //"Fórmulas de Comissão"
		
		oModel:SetActivate( {|oModel| TP413SetXml( oModel ) } )
		
		oModel:DeActivate({|| TP413ClearObj(oWkSheet) })

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface 

@sample		ViewDef()

@return		oView		Retorna objeto da interface

@author	 Wanderley Monteiro da Silva  
@since	 03/07/2015 
@version	P12

/*/
//------------------------------------------------------------------- 
 Static Function ViewDef()

	Local oModel		:= FWLoadModel('GTPA413')
	Local oStruct		:= FWFormStruct(2, 'GQ5')
	Local oView			:= nil
	Local oPanel		:= nil
		
		oStruct:RemoveField("GQ5_XML")
		
		oView := FWFormView():New()
		oView:SetModel(oModel)
		oView:AddField('VIEW_GQ5', oStruct, 'GQ5MASTER')
		oView:AddOtherObject('OTHER_PANEL1', {|oPanel| TP413Plani(oPanel)})
		
		oView:CreateHorizontalBox('TELAU', 30)
		oView:CreateHorizontalBox('TELAD', 70)
		
		oView:SetOwnerView('VIEW_GQ5', 'TELAU')
		oView:SetOwnerView('OTHER_PANEL1', 'TELAD')
		
		oView:SetContinuousForm(.T.) //Exibe a tela como se fosse uma página web com barra de rolagem
		
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu

@sample		MenuDef()

@return		aRotina   Array contendo as opções do Menu                                                                                                                           

@author	 Wanderley Monteiro da Silva  
@since	 03/07/2015 
@version	P12

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina	:= {}

		ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.GTPA413' OPERATION 2 ACCESS 0//'Visualizar'
		ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA413' OPERATION 3 ACCESS 0//'Incluir'
		ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA413' OPERATION 4 ACCESS 0//'Alterar'
		ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA413' OPERATION 5 ACCESS 0//'Excluir'
		ADD OPTION aRotina TITLE STR0007    ACTION 'VIEWDEF.GTPA413' OPERATION 8 ACCESS 0//'Imprimir'

Return aRotina
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP413SetXml()
Alimenta variavel static _XmlPlan - (Formula de Calculo)
 
@sample		TP413SetXml() 
@return		oModel  Modelo de Dados
@author		Inovação
@since		20/05/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP413SetXml( oModel )

	Local oField := oModel:GetModel("GQ5MASTER")
	
		//-- Reinicia var
		_XmlPlan := ""

		If ( oModel:Getoperation() != MODEL_OPERATION_INSERT ) 
		
			If Empty(_XmlPlan)
				_XmlPlan := oField:GetValue('GQ5_XML')
			EndIf
		EndIf

Return(.T.)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CommitModel()
Faz a gravação do modelo de dados. O commit foi persolanizado para permitir a gravação da
Planilha de cálculo usada para personalizar o cálculo do custo.
 
@sample		CommitModel(oModel)

@param		oModel	Objeto com o modelo de dados.
@return		lRet	Booleano indicando se a gravação foi bem sucedida.
@author		Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function CommitModel(oModel)

	Local lRet 			:= .F.
	Local nOperation	:= oModel:GetOperation()
	
		If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
			SaveWorkSheet(oModel)
		EndIf
	
		If ( lRet := FwFormCommit(oModel) )
			_XmlPlan := ""
		EndIf

Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP413Plani
Função que mostra a planilha para definir formula 

@sample 	TP413Plani(oPanel,oModel) 
@since		25/10/2014 
@version 	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TP413Plani(oPanel)

	Local oModel			:= FwModelActive()
	Local oView				:= FwViewActive()
	Local oFWLayer			:= nil
	Local oWinPlanilha		:= nil
	Local bPosChange		:= {|| PosChangeWorkSheet(oWkSheet,oModel, oView)}//Função acionada após a alteração da planilha
	Local nOperation		:= oModel:GetOperation()//Operação que está sendo realizada
	Local aCelulasBlock		:= {}

		oFWLayer := FWLayer():New()
		oFWLayer:Init( oPanel, .F.)
		oFWLayer:AddCollumn( "A1", 100, .T. )
		oFWLayer:AddLine( "B10", 100)
		oFWLayer:addWindow( "A1", "B10", "Planilha de Cálculo", 100,.F., .F., {|| Nil } )//
		
		oWinPlanilha 	:= oFWLayer:getWinPanel( "A1", "B10" )
		oWkSheet 		:= FWUIWorkSheet():New(oWinPlanilha,iif(nOperation == 3,.T.,.F. ), WS_ROWS, WS_COLS)
		
		oWkSheet:SetbPosChange(bPosChange)
		
		If (nOperation == MODEL_OPERATION_INSERT)
		
			//Monta cabeçalho da planilha
			oWkSheet:SetCellValue('A1',STR0011) //"% COMISSÃO" 	 
			oWkSheet:SetCellValue('A2',STR0012)//'% IMPOSTOS' 
			oWkSheet:SetCellValue('A3',STR0013) //'TOTAL VENDA'
			oWkSheet:SetCellValue('A4',STR0014)//'CANC./DEVOL.' 
			oWkSheet:SetCellValue('A5',STR0015)//'DESPESAS' 
			oWkSheet:SetCellValue('A6',STR0016)//'OUTROS'	 
			oWkSheet:SetCellValue('B7',STR0002) //'TOTAL'
			oWkSheet:SetCellValue('A8',STR0008) //'VALOR IMPOSTO'
			oWkSheet:SetCellValue('A9',STR0009) //'VALOR BASE'
			oWkSheet:SetCellValue('A10',STR0010) //'COMISSÃO A PAGAR'

			oWkSheet:SetCellValue('B1',0,'@E 999,999,999.99') //"% COMISSÃO" 	 
			oWkSheet:SetCellValue('B2',0,'@E 999,999,999.99')//'% IMPOSTOS' 
			oWkSheet:SetCellValue('B3',0,'@E 999,999,999.99') //'TOTAL VENDA'
			oWkSheet:SetCellValue('B4',0,'@E 999,999,999.99')//'CANC./DEVOL.' 
			oWkSheet:SetCellValue('B5',0,'@E 999,999,999.99')//'DESPESAS' 
			oWkSheet:SetCellValue('B6',0,'@E 999,999,999.99')//'OUTROS'	 
			oWkSheet:SetCellValue('A7',0,'@E 999,999,999.99') //'TOTAL'
			oWkSheet:SetCellValue('B8',0,'@E 999,999,999.99') //'VALOR IMPOSTO'
			oWkSheet:SetCellValue('B9',0,'@E 999,999,999.99') //'VALOR BASE'
			oWkSheet:SetCellValue('B10',0,'@E 999,999,999.99') //'COMISSÃO A PAGAR'
		
		EndIf	
		
		aCelulasBlock:={'A1','A2','A3','A4','A5','A6','B7','A8','A9','A10'}
		oWkSheet:SetCellsBlock(aCelulasBlock, .F.)
		
		//-- Carrega planilha de calculo
		If !Empty(_XmlPlan) 
			
			oWkSheet:lShow := .T.
			oWkSheet:LoadXmlModel(_XmlPlan)				
		
		EndIf

		oWkSheet:SetFocus(1,1)
		oWkSheet:Refresh()
		
Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP413ClearObj()
Destroi/Limpa  objeto (Planilha)
@sample		TP140ClearObj(oWkSheet)
@param		oWkSheet	Objeto FwUIWorksheet - (Planilha)
@return			
@author		Inovação
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function TP413ClearObj(oWkSheet)

	If ValType(oFWUIWorkSheet) == "O"
		
		oFWUIWorkSheet:Close()
		oFWUIWorkSheet:Destroy()
		FreeObj(oFWUIWorkSheet)
		
	EndIf 
	
	_XmlPlan := ""

Return(.T.)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosChangeWorkSheet()
Função executada após uma alteração na planilha de cálculo.
@sample	PosChangeWorkSheet(oModel, oView)
@param		oModel	Objeto com o modelo de dados.
@param		oView	Objeto com a interface.
@author	Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function PosChangeWorkSheet(oWkSheet,oModel, oView)

	Local nOperation 	:= oModel:GetOperation()
	
		//Seta as propriedades do model e da view para o status de alterada quando a planilha 
		//sofrer uma modificação, forçando a obrigatoriedade de salvar os dados.
		oView:SetModified()
		oWkSheet:OOWNER:LMODIFIED := .T.
		oModel:lModify := .T.

Return(.T.)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveWorkSheet()
Função para salvar os dados da planilha de cálculo em formato XML em um campo
da tabela do modelo de dados.
@sample	SaveWorkSheet(oModel, cCampo)
@param		oModel	Objeto com o modelo de dados para salvar a planilha de cálculo.
@author	Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function SaveWorkSheet(oModel)

	Local cXML 		:= ""
	Local oMdlGQ5	:= oModel:GetModel("GQ5MASTER")
	
		cXML := oWkSheet:GetXmlModel()
	
		oMdlGQ5:SetValue("GQ5_XML", cXML)
		
Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldTudoK
(long_description)
@type function
@author 
@since 19/10/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function VldTudoK(oModel)

	Local lValido	:= .T.
	Local oMdlGQ5	:= oModel:GetModel("GQ5MASTER")
	
		//Se for exclusão valida se o mesmo esta associado a algum calculo
		if oMdlGQ5:GetOperation() == 5 
		
			//Incluir as tabelas que são associadas a este cadastro.
			
		EndIf
		
Return lValido
//-------------------------------------------------------------------
/*/{Protheus.doc} TP413XmlArray
Retorna um array contendo as celulas da formula
@type function
@author crisf
@since 26/11/2017
@version 1.0
@param cCodForm, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Function TP413XmlArray(cFormula, aFormula)

	Local aAreaGQ5	:= GQ5->(GetArea())
	Local aItens	:= {}	
	Local oXml
	Local cerrorxml	:= ''
	Local cWarning	:= ''
	Local aColA		:= {}
	Local nItens	:= 0
	Local nRef		:= 0
	
		dbSelectArea("GQ5")
		GQ5->(dbSetOrder(1))
		if GQ5->(dbSeek(xFilial("GQ5")+cFormula))

			//1- Transformo a variavel caracter em um objeto
			oXml:= xmlparser(GQ5->GQ5_XML,"_", @cerrorxml, @cWarning)
			
			//Caso não tenha qualquer erro ou alerta na transformação
			If Empty( cerrorxml ) .And. Empty( cWarning )
			
				//2- acho o no dos itens e envio para transformar o Nó em Array 
				XmlNode2Arr(oXml:_FWMODELSHEET:_Model_Sheet:_MODEL_CELLS:_items, "_items")
			
				if Valtype(oXml:_FWMODELSHEET:_Model_Sheet:_MODEL_CELLS:_items) == "A"
				
				 aItens	:= oXml:_FWMODELSHEET:_Model_Sheet:_MODEL_CELLS:_items[1]:_ITEM
					
					For nItens	:= 1  to len(aItens)
					
						if Valtype(xmlchildex(aItens[nItens],"_NAME")) == 'O' .AND. Valtype(xmlchildex(aItens[nItens],"_VALUE")) == 'O'
						
							if 'A' $ aItens[nItens]:_NAme:Text
							
								aAdd(aColA,{ aItens[nItens]:_NAme:Text, aItens[nItens]:_VAlue:Text, ""})
								
							Elseif  'B' $ aItens[nItens]:_NAme:Text
							
								if 'B7' == aItens[nItens]:_NAme:Text
								
									aAdd(aColA,{'A7',"","TOTAL"})
									
								EndIf
							
								if ( nRef := aScan( aColA,{|x,y| substring(x[1],2,2) == substring(aItens[nItens]:_NAme:Text,2,2) })) > 0
								
									aColA[nRef][3]	:= aItens[nItens]:_VAlue:Text
									
								
								EndIF
								
							EndIf
					
						EndIf
						
					Next nItens
					
				EndIf
			
			EndIf
			
		EndIf
		
		aFormula	:= aColA
		
		RestArea(aAreaGQ5)
	
Return