#INCLUDE "FWMVCDEF.CH"                 
#Include "PROTHEUS.ch"
#Include "TMSA010.ch"

#DEFINE TABFRE "NTCL"
#DEFINE TIPTAB "01"
#DEFINE CATTAB "1"

/*/{Protheus.doc} TMSMWZE017
	
@author Daniel
@since 22/11/2013
@version 1.0		

@description
Modelo de dados para importação/exportação de tabela de preços específica pelo Mile

/*/
Function TMSMWZE017()
Local aArea	:= GetArea()
Local oBrowse	:= Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DT0")
oBrowse:SetDescription(STR0001) //-- "Tabela de Frete"
oBrowse:SetFilterDefault( "DT0_TABFRE == '"+TABFRE+"' .And. DT0_TIPTAB == '"+TIPTAB+"' ") 

oBrowse:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente
oBrowse:Activate()

RestArea(aArea)
Return Nil
	
/*/{Protheus.doc} ModelDef
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${nenhum}, ${Nil}

@return ${oModel}, ${Modelo de Dados MVC}

@description

Modelo de dados MVC

/*/
Static Function ModelDef()
Local oModel
TMSA010Set(TABFRE,TIPTAB,CATTAB) //-- Seta a configuração da tabela a ser usada.
oModel := FwLoadModel("TMSA010") 
oModel:cID := AllTrim(FunName())
Return oModel

/*/{Protheus.doc} ViewDef
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param ${nenhum}, ${Nil}

@return ${oView}, ${Visão MVC}

@description

Visão dos dados MVC

/*/
Static Function ViewDef()
Local oView

TMSA010Set(TABFRE,TIPTAB,CATTAB) //-- Seta a configuração da tabela a ser usada.
oView := FwLoadView("TMSA010")
Return oView

/*/{Protheus.doc} Menudef
	
@author Daniel
@since 22/11/2013
@version 1.0
		
@param $Nenhum, $Nil

@return $aRotina, $Array com os dados de menu da rotina

@description

Menu Funcional

/*/
Static Function MenuDef()
Private aRotina := {}
     
ADD OPTION aRotina TITLE STR0002 	ACTION "AxPesqui"			OPERATION 1 ACCESS 0   //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSMWZE017"	OPERATION 2 ACCESS 0   //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSMWZE017"	OPERATION 3 ACCESS 0   //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSMWZE017"	OPERATION 4 ACCESS 0   //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSMWZE017"	OPERATION 5 ACCESS 0   //"Excluir"


Return aRotina