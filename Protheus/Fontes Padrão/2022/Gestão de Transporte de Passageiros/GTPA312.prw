#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH" 
#Include "GTPA312.ch"
//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA312
Cadastro de Esquema de Escalas
 
@sample		GTPA312()
@return		Objeto oBrowse  
@author		Lucas.Brustolin
@since		03/08/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Function GTPA312()

Local oBrowse := FWMBrowse():New()

//-- Define a tabela  
oBrowse:SetAlias("GY8")
oBrowse:SetDescription(STR0001) //-- 'Esquema de Escalas'
oBrowse:SetMenuDef('GTPA312')
oBrowse:SetFilterDefault("UniqueKey({'GY8_FILIAL','GY8_CODIGO'})")
// Ativação da Classe
oBrowse:Activate()


Return (oBrowse)


//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Cadastro de Esquema de Escalas

@Return 	aRotina - Vetor com os menus
@author 	Lucas.Brustolin
@since 		03/08/2017
@version	P12
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "AxPesqui" 			    OPERATION 1	ACCESS 0 	// STR0002//"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.GTPA312"		OPERATION 2 ACCESS 0 	// STR0003//"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.GTPA312" 	    OPERATION 3	ACCESS 0 	// STR0004//"Incluir"
ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.GTPA312"		OPERATION 4	ACCESS 0 	// STR0005//"Alterar"
ADD OPTION aRotina TITLE STR0006	ACTION "VIEWDEF.GTPA312"		OPERATION 5	ACCESS 0 	// STR0006//"Excluir"

Return(aRotina)


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel - Objeto do Model
 
@author 	Lucas.Brustolin
@since 		03/08/2017
@version	P12
/*/ 
//--------------------------------------------------------------------------------------------------------

Static Function ModelDef()

// Cria as estruturas a serem usadas no Modelo de Dados
Local oCabec	:= FWFormStruct( 1, 'GY8', { |cCampo| Alltrim(cCampo) $ "GY8_CODIGO#GY8_DESESQ#GY8_SETOR#GY8_DSCSET" } )
Local oItem	:= FWFormStruct( 1, 'GY8')
// Cria objeto Model
Local oModel	:= MPFormModel():New('GTPA312',/*BPRE*/,{|oModel|TP312TudOK(oModel)},/*bCommit*/ )

//Adicionando gatilho 
oCabec:AddTrigger( ;
	'GY8_SETOR'  , ;     // [01] Id do campo de origem
	'GY8_DSCSET'  , ;     // [02] Id do campo de destino
	 { || .T. } , ; 		// [03] Bloco de codigo de validação da execução do gatilho
	 { || POSICIONE("GI1",1,XFILIAL("GI1")+ POSICIONE("GYT",1,XFILIAL("GYT")+FWFLDGET('GY8_SETOR'),"GYT_LOCALI") ,"GI1_DESCRI") } ) 	


oItem:AddTrigger( ;
	'GY8_TPDIA'  , ;     // [01] Id do campo de origem
	'GY8_TPDIA'  , ;     // [02] Id do campo de destino
	 { || .T. } , ; 		// [03] Bloco de codigo de validação da execução do gatilho
	 { |oSubMdl| TP312Vld(oSubMdl)  } ) 	
	 
//Retira a obrigatoriedade da descrição do esquema
oItem:SetProperty("GY8_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
oItem:SetProperty("GY8_DESESQ", MODEL_FIELD_OBRIGAT, .F.)
oItem:SetProperty("GY8_SETOR" , MODEL_FIELD_OBRIGAT, .F.)
oItem:SetProperty("GY8_DSCSET", MODEL_FIELD_OBRIGAT, .F.)

// ----------------------------------------+
// Adiciona componentes no Modelo de Dados |
// ----------------------------------------+
oModel:AddFields('GY8MASTER', /*cOwner*/, oCabec ) //-- Cabelho
oModel:AddGrid('GY8DETAIL', 'GY8MASTER', oItem ,{|oMdl,nLine,cAction,cField|GA312PreLn(oMdl,nLine,cAction,cField)})   //-- Item


oModel:SetRelation( 'GY8DETAIL', {{ 'GY8_FILIAL', 'xFilial( "GY8" )'}, { 'GY8_CODIGO', 'GY8_CODIGO'},{ 'GY8_DESESQ', 'GY8_DESESQ'},{ 'GY8_SETOR', 'GY8_SETOR'} },GY8->( IndexKey(1) ))


// ----------------------------------------+
//  Adiciona descrição do Modelo de Dados  |
// ----------------------------------------+
oModel:SetDescription( STR0001 ) //-- 'Esquema de Escalas'

// ----------------------------------------+
//  Não permite linhas duplicadas          |
// ----------------------------------------+
oModel:GetModel( 'GY8DETAIL' ):SetUniqueLine({"GY8_CODIGO","GY8_SEQ"})

// ----------------------------------------+
//  Define a Chave Primaria do Modelo      |
// ----------------------------------------+
oModel:SetPrimaryKey({"GY8_FILIAL","GY8_CODIGO","GY8_SEQ"})


Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da  View Interface 

@sample  	ViewDef()

@return  	oView - Objeto do View

@author 	Lucas.Brustolin
@since 		03/08/2017
@version	P12
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

// Cria as estruturas a serem usadas na visualização
Local oCabec	:= FWFormStruct( 2, 'GY8', { |cCampo| Alltrim(cCampo) $ "GY8_CODIGO#GY8_DESESQ#GY8_SETOR#GY8_DSCSET" } )
Local oItem	    := FWFormStruct( 2, 'GY8', { |cCampo| !Alltrim(cCampo) $ "GY8_CODIGO#GY8_DESESQ#GY8_SETOR#GY8_DSCSET" } )
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'GTPA312' )
//-- Cria objeto View
Local oView	:= FWFormView():New()

// -----------------------------------------------------+
// Define qual Modelo de dados será utilizado				|
// -----------------------------------------------------+
oView:SetModel( oModel )

oItem:SetProperty( 'GY8_ESCALA' , MVC_VIEW_LOOKUP,'GYOFIL')

// -----------------------------------------------------+
// Adiciona componentes a serem visualiados na tela     |
// -----------------------------------------------------+
oView:AddField('VIEW_CABEC', oCabec,'GY8MASTER') //-- Cabelho
oView:AddGrid('VIEW_ITEM' , oItem,'GY8DETAIL')   //-- Item

// -----------------------------------------------------+
// Define a divisão da tela para inserir os componentes |
// -----------------------------------------------------+
oView:CreateHorizontalBox('SUPERIOR', 20)
oView:CreateHorizontalBox('INFERIOR', 80)

oView:SetOwnerView('VIEW_CABEC','SUPERIOR')
oView:SetOwnerView('VIEW_ITEM' ,'INFERIOR')

oView:AddIncrementField('VIEW_ITEM','GY8_SEQ')


Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} TP312TudOK()
Rotina responsavel em validar o formulario (Modelo de dados).
Tudo OK.

@sample  	TP312TudOK()

@return  	oModel - Objeto do Modelo de dados

@author 	Lucas.Brustolin
@since 		07/08/2017
@version	P12
/*/
//-------------------------------------------------------------------
Function TP312TudOK(oModel)

Local nOperation    := oModel:GetOperation()
Local oItem         := oModel:GetModel("GY8DETAIL")
Local n1            := 1
Local lRet          := .T.


//---------------------------------------------------------------------+
// Valida se foi preenchido o código da escala ao informar tipo dia trabalhado;
//---------------------------------------------------------------------+
    If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE 

        For n1 := 1 To oItem:Length()
            oItem:Goline(n1)

            If !oItem:IsDeleted() .And. oItem:GetValue("GY8_TPDIA") == "1" .And. Empty(oItem:GetValue("GY8_ESCALA"))
                Help(,,'TP312TudOK01',, STR0007, 1,0)//"Para o tipo de dia Trabalhado é obrigatório o preenchimento do campo Escala."
                lRet := .F.
                Exit
            EndIf 
        Next 


    EndIf     

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TP312Vld()
Rotina responsavel para quando tipo dia for alterado para não trabalhado
limpar o campo da escala e descrição da escala 

@sample  	TP312Vld()

@return  	oSubMdl - Objeto do Modelo de dados

@author 	Yuki Shiroma
@since 		28/09/2017
@version	P12
/*/
//-------------------------------------------------------------------

Function TP312Vld(oSubMdl)

Local cValue := oSubMdl:GetValue("GY8_TPDIA")
//Verifica se diferente de dia trabalhada
If cValue != "1"
	//Limpando escala e descrição da escala	
	oSubMdl:ClearField('GY8_ESCALA')
	oSubMdl:ClearField('GY8_ESCDES')

EndIf

Return(cValue)

//-------------------------------------------------------------------
/*/{Protheus.doc} Gtpa312vld()
 

@sample  	Gtpa312Vld()

@return  	lRet

@author 	Jacomo Fernandes
@since 		28/09/2017
@version	P12
/*/
//-------------------------------------------------------------------

Function Gtpa312Vld()
Local lRet := .T.
If Posicione('GYO',1,XFILIAL('GYO')+FWFLDGET('GY8_ESCALA'),'GYO_SETOR') <> FwFldGet('GY8_SETOR')
	lRet := .F.
	Help( ,1, "Gtpa312Vld",, "Escala informada não confere com o setor selecionado", 1, 0 )
Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Gtpa312vld()
 

@sample  	Gtpa312Vld()

@return  	lRet

@author 	Jacomo Fernandes
@since 		28/09/2017
@version	P12
/*/
//-------------------------------------------------------------------

Static Function GA312PreLn(oMdl,nLine,cAction,cField)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
If oMdl:GetId() == 'GY8DETAIL' .and. cAction == 'CANSETVALUE'
	If Empty(FwFldGet('GY8_SETOR')) 
		lRet := .F.
		//Help("",1, "GA312PreLn",, "O campo Setor não foi informado, favor selecione antes de criar o esquema de escala", 1, 0 )
		oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,'GA312PreLn',"O campo Setor não foi informado, favor selecione antes de criar o esquema de escala")
	Endif
Endif
Return lRet
