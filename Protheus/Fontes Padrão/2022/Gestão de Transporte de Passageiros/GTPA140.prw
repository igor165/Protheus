#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA140.CH"

#DEFINE WS_COLS 05	//Quantidade de colunas da WorkSheet
#DEFINE WS_ROWS 10	//Quantidade de linhas da WorkSheet

Static oWorkSheet	:= nil	//Objeto da Planilha de Cálculo
Static __cXmlPlanilha:= ""


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA140()
Rotina responsável por cadastrar os custos de uma viagem especial. 
@sample		GTPA140() 
@return		oBrowse  Retorna o Cadastro de Custos de Viagens
@author		Inovação
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA140()

Local oBrowse := nil

 DbSelectArea("GIM")

 oBrowse := FWMBrowse():New()
 oBrowse:SetAlias('GIM')
 oBrowse:SetDescription(STR0001)//"Custo de Viagem"

 oBrowse:Activate()

 Return oBrowse


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do Modelo de Dados
@sample		ModelDef() 
@return		oModel	Objeto do Modelo de Dados
@author		Inovação

@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= nil
Local oStruct	:= FWFormStruct(1, 'GIM')

oModel := MPFormModel():New('GTPA140',/*bPreVld*/, {|| GA140PosVld(oModel)})

oModel:AddFields( 'GIMMASTER', /*cOwner*/, oStruct )
oModel:SetPrimaryKey({ 'GIM_FILIAL', 'GIM_COD'})
oModel:SetDescription(STR0001)		//""Custo de Viagem"


oStruct:SetProperty('*' ,MODEL_FIELD_WHEN   , {||  !FWIsInCallStack("GTPA140ExVw")  } )

oModel:SetActivate( {|oModel| TP140SetXml( oModel ) } )

oModel:DeActivate({|| TP140ClearObj(oWorkSheet) })

Return oModel


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface 
 
@sample		ViewDef() 
@return		oView  Retorna a View
 
@author		Inovação

@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= FWLoadModel('GTPA140')
Local oStruct		:= FWFormStruct(2, 'GIM')
Local oView			:= nil
Local oPanel		:= nil

oStruct:RemoveField("GIM_PLAN")

oStruct:SetProperty("GIM_COD"  		,MVC_VIEW_ORDEM,"01")
oStruct:SetProperty("GIM_DESCRI"  	,MVC_VIEW_ORDEM,"02")

If GIM->(FieldPos('GIM_UTILIZ')) > 0
	oStruct:SetProperty("GIM_UTILIZ"  	,MVC_VIEW_ORDEM,"03")
Endif

oStruct:SetProperty("GIM_UM"  		,MVC_VIEW_ORDEM,"04")
oStruct:SetProperty("GIM_DESUM"  	,MVC_VIEW_ORDEM,"05")
oStruct:SetProperty("GIM_PRODUT"  	,MVC_VIEW_ORDEM,"06")
oStruct:SetProperty("GIM_DESPRO"  	,MVC_VIEW_ORDEM,"07")
//oStruct:SetProperty("GIM_TPCUST"  	,MVC_VIEW_ORDEM,"07")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('CABECALHO', oStruct, 'GIMMASTER')
oView:AddOtherObject('PLANILHA', {|oPanel| TP140CreatePlan(oPanel)})

oView:CreateHorizontalBox('MAIN', 30)
oView:CreateHorizontalBox('BODY', 70)

oView:SetOwnerView('CABECALHO', 'MAIN')
oView:SetOwnerView('PLANILHA', 'BODY')

oView:SetContinuousForm(.T.) //Exibe a tela como se fosse uma página web com barra de rolagem
	
Return oView


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample		MenuDef() 
@return		aRotina  Retorna as opções do Menu
@author		Inovação
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina	:= {}

	ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.GTPA140' OPERATION 2 ACCESS 0 // #Visualizar
	ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.GTPA140' OPERATION 3 ACCESS 0 // #Incluir
	ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.GTPA140' OPERATION 4 ACCESS 0 // #Alterar
	ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.GTPA140' OPERATION 5 ACCESS 0 // #Excluir
	ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.GTPA140' OPERATION 8 ACCESS 0 // #Imprimir
	ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.GTPA140' OPERATION 9 ACCESS 0 // #Copiar

Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP140SetXml()
Alimenta variavel static __cXmlPlanilha - (Formula de Calculo)
 
@sample		TP140SetXml() 
@return		oModel  Modelo de Dados
@author		Inovação
@since		20/05/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP140SetXml( oModel )

Local oField := oModel:GetModel("GIMMASTER")

//-- Reinicia var
__cXmlPlanilha := ""


//-- Se a inclusão vier de uma cópia alimenta campo da planilha da calculo.
If oModel:Getoperation() == MODEL_OPERATION_INSERT .And. oModel:IsCopy() .And. !Empty(GIM->GIM_PLAN)
	oField:LoadValue("GIM_PLAN",GIM->GIM_PLAN)
	__cXmlPlanilha := GIM->GIM_PLAN
EndIf

If ( oModel:Getoperation() != MODEL_OPERATION_INSERT )
	If Empty(__cXmlPlanilha)
		__cXmlPlanilha := oField:GetValue('GIM_PLAN')
	EndIf
EndIf


Return(.T.)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA140PosVld()
Faz a gravação do modelo de dados. O commit foi persolanizado para permitir a gravação da
Planilha de cálculo usada para personalizar o cálculo do custo.
 
@sample		GA140PosVld(oModel)

@param		oModel	Objeto com o modelo de dados.
@return		lRet	Booleano indicando se a gravação foi bem sucedida.
@author		Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA140PosVld(oModel)
Local lRet 			:= .T.
Local nOperation	:= oModel:GetOperation()
Local cUtiliz		:= ''

If GIM->(FieldPos('GIM_UTILIZ')) > 0
	cUtiliz := oModel:GetModel('GIMMASTER'):GetValue('GIM_UTILIZ')
Endif

If ValidWorkSheet(cUtiliz)	//Valida os dados da planilha de cálculo
	If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
		SaveWorkSheet(oModel)
	EndIf
Else
    lRet := .F. 
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP140CreatePlan()
Cria a planilha de cálculo para uso no custo.
 
@sample	TP140CreatePlan() 
@param	oPanel	Painel onde será criado o objeto FWUIWorkSheet.
@author	Inovação
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function TP140CreatePlan(oPanel)

Local oModel			:= FwModelActive()
Local oView				:= FwViewActive()
Local oFWLayer			:= nil
Local oWinPlanilha		:= nil
Local bPosChange		:= {|| PosChangeWorkSheet(oWorkSheet,oModel, oView)}		//Função acionada após a alteração da planilha
Local nOperation		:= oModel:GetOperation()		//Opearação que está sendo realizada
Local n1				:= 0
Local cCellValue		:= ""


oFWLayer := FWLayer():New()
oFWLayer:Init( oPanel, .F.)
oFWLayer:AddCollumn( "C1", 100, .T. )
oFWLayer:AddLine( "L1", 100)
oFWLayer:addWindow( "C1", "W2", STR0015, 100,.F., .F., {|| Nil } )//"Planilha de Cálculo"

//---------------------------------------
// PLANILHA de Cálculo
//---------------------------------------
oWinPlanilha 	:= oFWLayer:getWinPanel( "C1", "W2" )
oWorkSheet 		:= FWUIWorkSheet():New(oWinPlanilha,iif(nOperation == 3 .And. !oModel:IsCopy(),.T.,.F. ), WS_ROWS, WS_COLS)

oWorkSheet:SetbPosChange(bPosChange)

If (nOperation == MODEL_OPERATION_INSERT .And. !oModel:IsCopy() )
	//Monta cabeçalho da planilha
	oWorkSheet:SetCellValue("A1", STR0010) 	//"Campo Referencia"
	oWorkSheet:SetCellValue("B1", STR0011)	//"Descrição"
	oWorkSheet:SetCellValue("C1", STR0012)	//"VALOR"	
	oWorkSheet:SetCellValue("D1", STR0013)	//"FORMULA"	

EndIf	

//-- Carrega planilha de calculo
If !Empty(__cXmlPlanilha) 
	oWorkSheet:lShow := .T.
	oWorkSheet:LoadXmlModel(__cXmlPlanilha)
EndIf

	
Return

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
Static Function PosChangeWorkSheet(oWorkSheet,oModel, oView)

Local nOperation 	:= oModel:GetOperation()
Local cColuna		:= SubStr(oWorkSheet:cCellSelec,1,1)
Local xValueCel		:= Nil
Local cCelAtiva		:= ""
Local nValor		:= 0

//Seta as propriedades do model e da view para o status de alterada quando a planilha 
//sofrer uma modificação, forçando a obrigatoriedade de salvar os dados.
If (nOperation == MODEL_OPERATION_UPDATE .Or. (nOperation == MODEL_OPERATION_INSERT .And. oModel:IsCopy()) )
	oView:SetModified()
	oWorkSheet:OOWNER:LMODIFIED := .T.
	oModel:lModify := .T.
EndIf

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
Local nValue	:= 0
Local oModelGIM	:= oModel:GetModel("GIMMASTER")

	cXML := oWorkSheet:GetXmlModel()
	
	oModelGIM:SetValue("GIM_PLAN", cXML)
	
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidWorkSheet(cUtiliz)
Função para validar os dados da planilha de cálculo.
@sample	ValidWorkSheet()
@return	lRet	Valor lógico indicando se os dados da planilha são válidos.
@author	Inovação
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ValidWorkSheet(cUtiliz)

	Local lRet			:= .T.
	Local nLinha		:= 0
	Local nColuna		:= 0
	Local cCampo		:= ''
	Local cMsg			:= ''
	Local aColValid		:= {'A'}	//Colunas que devem ser validadas com relação a seu conteúdo.
	Local aTitulo		:= {STR0010,STR0011,STR0012, STR0013}	//'Campo Referência'| 'Descrição' | 'Valor' | 'Formula'

	For nLinha := 2 To oWorkSheet:NTOTALLINES

		For nColuna := 1 To Len(aColValid)
	
			//Valida se o valor preenchido na célula é válido.
			cColuna := aColValid[nColuna] + AllTrim(Str(nLinha))
			
			If (oWorkSheet:CellExists(cColuna))
				cCampo := oWorkSheet:GetCellValue(cColuna)
			
				If (!Empty(cCampo))
				
					If (ValType(cCampo) != 'C')
						lRet := .F.
						cMsg := STR0016 + cColuna + STR0017	//#O valor informado na célula + cColuna + #  deve ser um nome de campo ou um valor precedido de "#".
						Exit
					Else
						If (SubStr(cCampo, 1, 1) != "'")
						
							If (!ExistCampo(cCampo, cUtiliz))
								lRet := .F.
								cMsg := STR0018 + cColuna + STR0019 + aTitulo[nColuna] + STR0020	//'O nome do campo informado na célula "' | '" como "' | '" não é válido.'
								Exit
							EndIf
						
						EndIf
					EndIf
				EndIf
			EndIf
		
		Next
	
		If (!lRet)
			Exit
		EndIf
	Next

	If (!lRet)
		Alert(cMsg)
	EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExistCampo()
Função para validar se o campo utilizado na planilha de cálculo existe no dicionário.
@sample		ExistCampo(cCampo)
@param		cCampo	Nome do campo que que deve ser validado.
@return		lRet	Valor booleano indicando se o campo foi encontrado ou não.
@author		Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ExistCampo(cCampo, cUtiliz)

Local aArea	:= GetArea()
Local lRet		:= .F.
Local cTables := ''

If cUtiliz == '2'
	cTables := "GY0|GQJ|GYD|GQI|GYX|GQZ|"
Else
	cTables := "ADZ|ADY|GIN|GIP|GIO|G6R|"
Endif

DbSelectArea("SX3")		//Tabela de Campos do Dicionário
SX3->(DbSetOrder(2))	//X3_CAMPO


If SubStr(cCampo,1,3) $ cTables .And. (SX3->(DbSeek(cCampo)))
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP140ClearObj()
Destroi/Limpa  objeto (Planilha)
@sample		TP140ClearObj(oWorkSheet)
@param		oWorkSheet	Objeto FwUIWorksheet - (Planilha)
@return			
@author		Inovação
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function TP140ClearObj(oWorkSheet)

If ValType(oWorkSheet) == "O"
	oWorkSheet:Close()
	oWorkSheet:Destroy()
	FreeObj(oWorkSheet)
EndIf 

__cXmlPlanilha := ""

Return(.T.)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP140CusTot()
Calcula o valor total de um custo.
 
@sample		TP140CusTot()

@return		nCusto	Valor Total do Custo.
 
@author		Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function TP140CusTot()

Local nCusto	:= 0
Local nQuant	:= FwFldGet('GIO_QUANT')
Local nCusUni	:= FwFldGet('GIO_CUSUNI')

If (!Empty(nQuant)) .And. (!Empty(nCusUni))
	nCusto := nQuant * nCusUni
EndIf

Return nCusto
