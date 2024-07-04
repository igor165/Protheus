#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA940.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA940
Rotina para Cadastro de Regras. 

@author     Valdiney V GOMES
@version    12
@since      09/06/2015
/*/
//------------------------------------------------------------------------------
Function CRMA940()
	Local oBrowse := FWMBrowse():New()
	oBrowse:SetCanSaveArea(.T.) 
	oBrowse:SetAlias("AZ8")
	oBrowse:SetDescription( STR0001 ) //"Cadastro de Regras"
	oBrowse:DisableDetails()
	oBrowse:Activate()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define as opções disponíveis no menu da sequência de Regras por Filas.

@return aRotina Rotinas que serão exibidas no menu. 

@author     Valdiney V GOMES
@version    12
@since      09/06/2015
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CRMA940" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CRMA940" OPERATION 3 ACCESS 0 //"Incluir" 
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CRMA940" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CRMA940" OPERATION 5 ACCESS 0 //"Excluir"
Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo de dados da sequência de Regras por Filas.

@return oModel Modelo de dados da sequência de Regras por Filas.

@author     Valdiney V GOMES
@version    12
@since      09/06/2015
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel		:= Nil
	Local oAZ8Struct	:= FWFormStruct( 1, "AZ8" )
	Local oAZ9Struct	:= FWFormStruct( 1, "AZ9" )

	//-------------------------------------------------------------------
	// Define os gatilhos.  
	//-------------------------------------------------------------------
	oAZ9Struct:AddTrigger( "AZ9_CODAGR", "AZ9_DSCAGR",, {| oModel, cField, cValue | CRM940Trigger( oModel, cField, cValue ) } )
	oAZ9Struct:AddTrigger( "AZ9_CODNIV", "AZ9_DSCNIV",, {| oModel, cField, cValue | CRM940Trigger( oModel, cField, cValue, "AZ9_DSCNIV" ) } )
	oAZ9Struct:AddTrigger( "AZ9_CODNIV", "AZ9_IDINT",, {| oModel, cField, cValue | CRM940Trigger( oModel, cField, cValue, "AZ9_IDINT" ) } )
	
    //-------------------------------------------------------------------
	// Define a estrutura do modelo de dados. 
	//-------------------------------------------------------------------
	oModel	:= MPFormModel():New("CRMA940")
	oModel:AddFields("AZ8MASTER",, oAZ8Struct )
	oModel:AddGrid( "AZ9DETAIL", "AZ8MASTER", oAZ9Struct )	
	oModel:SetRelation("AZ9DETAIL", { { "AZ9_FILIAL", "xFilial('AZ8')" }, {"AZ9_CODCON", "AZ8_CODCON"}}, AZ9->( IndexKey( 1 ) ) )
	oModel:SetPrimaryeKey( { "AZ8_FILIAL", "AZ8_CODCON" } )
	oModel:GetModel("AZ9DETAIL"):SetUniqueLine( { "AZ9_CODAGR","AZ9_CODNIV" } )	
	
	//-------------------------------------------------------------------
	// Define a descrição do modelo de dados. 
	//-------------------------------------------------------------------	
	oModel:SetDescription( STR0001 ) //"Cadastro de Regras"
	oModel:GetModel("AZ8MASTER"):SetDescription( STR0006 ) //"Regra" 
	oModel:GetModel("AZ9DETAIL"):SetDescription( STR0007 ) //"Agrupadores e níveis" 
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Camada de visualização da sequência de Regras por Filas.

@return oView Camada de visualização da sequência de Regras por Filas. 

@author     Valdiney V GOMES
@version    12
@since      09/06/2015
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView			:= FWFormView():New()
	Local oModel 		:= FWLoadModel( "CRMA940" )
	Local oAZ8Struct	:= FWFormStruct( 2, "AZ8")
	Local oAZ9Struct	:= FWFormStruct( 2, "AZ9")

	//-------------------------------------------------------------------
	// Remove campos da camada de visualização.  
	//-------------------------------------------------------------------
	oAZ9Struct:RemoveField( "AZ9_CODCON" )
	oAZ9Struct:RemoveField( "AZ9_IDINT" )

	//-------------------------------------------------------------------
	// Define o modelo utilizado pela camada de visualização. 
	//-------------------------------------------------------------------	
	oView:SetModel( oModel )  

	//-------------------------------------------------------------------
	// Define a estrutura da dcamada de visualização. 
	//-------------------------------------------------------------------
	oView:AddField( "VIEW_AZ8", oAZ8Struct	, "AZ8MASTER" )
	oView:AddGrid( "VIEW_AZ9",	oAZ9Struct	, "AZ9DETAIL" )
	
	oView:CreateHorizontalBox("TOP"		,55)
	oView:CreateHorizontalBox("BOTTOM"	,45)
	
	oView:SetOwnerView( "VIEW_AZ8",	"TOP" )
	oView:SetOwnerView( "VIEW_AZ9", "BOTTOM" )
	
	oView:EnableTitleView("VIEW_AZ8" )
	oView:EnableTitleView("VIEW_AZ9" )
Return oView     

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM940Trigger
Trigger dos campos AZ9_CODAGR e AZ9_CODNIV. 

@param oModel, objeto, Modelo de dados. 
@param cField, caracter, Campo a ser pesquisado. 
@param cValue, caracter, Conteúdo do campo a ser pesquisado. 
@param cTarget, caracter, Campo destino.  
@return cReturn, caracter, Descrição do campo. 

@author     Valdiney V GOMES
@version    12
@since      10/06/2015
/*/
//------------------------------------------------------------------------------
Static Function CRM940Trigger( oModel, cField, cValue, cTarget )
	Local cReturn 	:= ""

	Default oModel		:= Nil 
	Default cField		:= ""
	Default cValue		:= ""
	Default cTarget		:= ""
	
	If ( cField == "AZ9_CODAGR" )	
		//-------------------------------------------------------------------
		// Recupera a descrição do agrupador. 
		//-------------------------------------------------------------------
		cReturn := Posicione( "AOL", 1, xFilial("AOL") + cValue, "AOL_RESUMO" )	
	ElseIf ( cField == "AZ9_CODNIV" )		
		If ( cTarget == "AZ9_DSCNIV")
			//-------------------------------------------------------------------
			// Recupera a descrição do nível do agrupador. 
			//-------------------------------------------------------------------
			cReturn := Posicione( "AOM", 1, xFilial("AOM") + oModel:GetValue("AZ9_CODAGR") + cValue, "AOM_DESCRI" )
		ElseIf ( cTarget == "AZ9_IDINT")
			//-------------------------------------------------------------------
			// Recupera o ID inteligente do nível do agrupador. 
			//-------------------------------------------------------------------
			cReturn := Posicione( "AOM", 1, xFilial("AOM") + oModel:GetValue("AZ9_CODAGR") + cValue, "AOM_IDINT" )	
		EndIf
	EndIf 
	
	//-------------------------------------------------------------------
	// Reseta o nível do agrupador.
	//-------------------------------------------------------------------
	If ( cField == "AZ9_CODAGR" )
		oModel:SetValue( "AZ9_CODNIV", "" )	
	EndIf
Return cReturn   

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM940Init
Inicializado padrão para os campos AZ9_DSCAGR e AZ9_DSCNIV. 

@param cField, caracter, Nome do campo. 
@return cReturn, caracter, Descrição do campo. 

@author     Valdiney V GOMES
@version    12
@since      10/06/2015
/*/
//------------------------------------------------------------------------------
Function CRM940Init( cField )
	Local cReturn 	:= ""

	Default cField	:= ""
	
	If ! ( INCLUI )
		If ( cField == "AZ9_DSCAGR" )	
			//-------------------------------------------------------------------
			// Recupera a descrição do agrupador. 
			//-------------------------------------------------------------------
			cReturn := Posicione( "AOL", 1, xFilial("AOL") + AZ9->AZ9_CODAGR, "AOL_RESUMO" )	
		ElseIf ( cField == "AZ9_DSCNIV" )
			//-------------------------------------------------------------------
			// Recupera a descrição do nível do agrupador. 
			//-------------------------------------------------------------------
			cReturn := Posicione( "AOM", 1, xFilial("AOM") + AZ9->AZ9_CODAGR + AZ9->AZ9_CODNIV, "AOM_DESCRI" )
		EndIf 
	EndIf
Return cReturn                                                       