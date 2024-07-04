#include "protheus.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} AGRA910
Rotina de cadastramento de tipo de avalição para classificação  do produto(soja), 
onde informação o tipo de classificação e sua variaveis

@param.: 	Nil
@author: 	Maicol
@since.: 	09/12/2012
@Uso...:	SIGAARM - Unidade de beneficiamento de Soja
*/
Function AGRA910()
	Local oMBrowse	:= Nil
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias('NPT') // Define a Tabela que vai ser utilizada pelo browser
	//oMBrowse:SetMenuDef( "AGRA910" )
	oMBrowse:SetDescription("Cadastro de tipo de Análise")
	//oMBrowse:DisableDetails()
	oMBrowse:Activate()// Ativa a Class
Return (Nil)

/** {Protheus.doc} AGRA910
//Definição do menu

@param.: 	Nil
@author: 	Maicol
@since.: 	09/12/2012
@Uso...:	SIGAARM - Unidade de beneficiamento de Soja
*/
Static Function MenuDef()
	//declara array onde vai ser add as opções
	Local aRotina := {}
	
	aAdd( aRotina, { "Pesquisar" , "PesqBrw"        			, 0, 1, 0, .T. } )
	aAdd( aRotina, { "Visualizar", "ViewDef.AGRA910"			, 0, 2, 0, Nil } )
	aAdd( aRotina, { "Incluir"   , "ViewDef.AGRA910"			, 0, 3, 0, Nil } )
	aAdd( aRotina, { "Alterar"   , "ViewDef.AGRA910"			, 0, 4, 0, Nil } )
	aAdd( aRotina, { "Excluir"   , "ViewDef.AGRA910"			, 0, 5, 0, Nil } )
	aAdd( aRotina, { "Imprimir"  , "ViewDef.AGRA910"			, 0, 8, 0, Nil } )
	aAdd( aRotina, { "Copiar"    , "ViewDef.AGRA910"			, 0, 9, 0, Nil } )
Return( aRotina )

/** {Protheus.doc} AGRA910
//Definição do Model

@param.: 	Nil
@author: 	Maicol
@since.: 	09/12/2012
@Uso...:	SIGAARM - Unidade de beneficiamento de Soja
*/
Static Function ModelDef()
	// = 1 por que é model, Nome da tabela
	Local oStruNPT := FWFormStruct(1,"NPT")
	Local oStruNPU := FWFormStruct(1,"NPU")

	// Classe utilizada para criar um model = MPFormModel()
	Local oModel := MPFormModel():New("AGRA910")

	oStruNPU := FWFormStruct(1,"NPU")

	oStruNPU:SetProperty("NPU_CODVA",MODEL_OPERATION_VIEW,.T.)

	//NPTMASTER é o identificador (ID) dado ao componente.
	oModel:AddFields("NPTMASTER",Nil,oStruNPT)

	oStruNPU:RemoveField( "NPU_CODTA" )

	//Adicionamos a descrição do modelo de dados
	oModel:SetDescription( 'Cadastro de tipo de Análise' )

	//Adicionamos a descrição dos componentes do modelo de dados: NPTMASTER
	oModel:GetModel('NPTMASTER'):SetDescription('Dados do tipo de Análise')

	//Create the grid with the sub item
	oModel:AddGrid( "NPUGRID", "NPTMASTER", oStruNPU )
	oModel:GetModel('NPUGRID'):SetDescription('Variávies de tipo de Análise')

	//Set the relationship between  to both
	oModel:SetRelation( 'NPUGRID', { { 'NPU_FILIAL', 'xFilial( "NPU" )' }, { 'NPU_CODTA', 'NPT_CODTA' } }, NPU->( IndexKey( 1 ) ) )
Return (oModel)

/** {Protheus.doc} AGRA910

@param.: 	Nil
@author: 	Maicol
@since.: 	09/12/2012
@Uso...:	SIGAARM - Unidade de beneficiamento de Soja
*/
Function AGR910SEQ()
	Local oModel	:= FwModelActive()
	Local oStruNPU 	:= oModel:GetModel("NPUGRID")
	Local nLinSG1 	:= oStruNPU:nLine
	oStruNPU:GoLine(nLinSG1)
	oStruNPU:SetValue('NPU_SEQVAR',SUBSTR(oStruNPU:GetValue("NPU_CODVA"),5,6))
Return .T.

/** {Protheus.doc} AGRA910
//View é responsavel por mostrar os dados para o cliente, linkada ao model(modelo)

@param.: 	Nil
@author: 	Maicol
@since.: 	09/12/2012
@Uso...:	SIGAARM - Unidade de beneficiamento de Soja
*/
Static Function ViewDef()
	//função para capturar o modelo que esta sendo utilizado e vai  distribuir os dados
	local oModel   := FWLoadModel("AGRA910")
	Local oStruNPT := FWFormStruct( 2, 'NPT' )
	Local oStruNPU := FWFormStruct( 2, 'NPU' )

	oView := FWFormView():New()

	oView:SetModel(oModel)// Atribui o modelo que vai ser utilizado na view

	oView:AddField("AGRA910_V",oStruNPT,"NPTMASTER")
	oView:AddGrid( "VIEW_NPU", oStruNPU, "NPUGRID" )


	oStruNPU:RemoveField( "NPU_CODTA" )
	oStruNPU:RemoveField( "NPU_CODVA" )

	oView:CreateHorizontalBox( "SUPERIOR" , 50)
	oView:CreateHorizontalBox( "INFERIOR" , 50)

	oView:SetOwnerView( "AGRA910_V", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NPU", "INFERIOR" )

	oView:EnableTitleView( "AGRA910_V" )
	oView:EnableTitleView( "VIEW_NPU" )
Return (oView)

/** {Protheus.doc} AGRA910
//Tratamento para WHEN 

@param.: 	lRet 
@author: 	Ana Laura Olegini
@since.: 	17/03/2015
@Uso...:	SIGAARM - Unidade de beneficiamento de Soja
*/
Function AGRA910When()
	Local lRet 		:= .T.
	Local oModel	:= FwModelActive()
	Local oStruNPT 	:= oModel:GetModel("NPTMASTER")
	Local oStruNPU 	:= oModel:GetModel("NPUGRID")
	
	//Se analise oficial for "NAO"  			  //Se o Tipo for "TEXTO"
	If oStruNPT:GetValue("NPT_ANAOFI") = '1' .OR. oStruNPU:GetValue("NPU_TIPOVA") = '2'
		//TRAVA
		lRet := .F.
	EndIf
Return lRet