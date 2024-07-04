#include "MATA084.CH"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"

#include "FWADAPTEREAI.CH"
#include "FWBROWSE.CH"

/*/{Protheus.doc} MATA084RUS()
Cadastro de Solicitantes
@author Artem Nikitenko
@since 19/07/2017
@version 1.0
@return NIL
/*/
Function MATA084RUS() 
Local oBrowse as object
oBrowse := BrowseDef()
oBrowse:Activate()

Return

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Artem Nikitenko
@since 19/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel as object
oModel 	:= FwLoadModel('MATA084')
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface

@author Artem Nikitenko
@since 19/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
oView := FwLoadView("MATA084")
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Artem Nikitenko
@since 19/07/2017
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()  
Local aRotina := {}
aRotina := FwLoadMenu("MATA084")
Return aRotina

/*/{Protheus.doc} BrowseDef
BrowseDef implemantation

@author Artem Nikitenko
@since 19/07/2017
@version 1.0
/*/
Static Function BrowseDef()
Local oBrowse as object
oBrowse := FWLoadBrw("MATA084")
Return oBrowse
//merge branch 12.1.19
// Russia_R5
