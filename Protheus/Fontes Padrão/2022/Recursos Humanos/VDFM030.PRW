#include "VDFM030.CH"
# INCLUDE "PROTHEUS.CH"
# INCLUDE "FWMBROWSE.CH"
# INCLUDE "FWMVCDEF.CH"
# INCLUDE "TOTVS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFM030
Concurso - Itens Atos/Portarias
@sample		VDFM030()
@author		Nivia Ferreira
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFM030()
Local oBrowse

Private aTab		:= {}
Private cCtlMenu	:= "VDFM030"

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'REW' )
oBrowse:SetDescription( STR0001 )//'Concurso - Itens Atos/Portarias'
oBrowse:Activate()

Return( NIL )


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Incluindo opção no Menu do browse.
@sample	MenuDef()
@return		aRotina, array, lista de opções do Menu 
@author		Nivia Ferreira
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}  

	If !IsInCallStack("VDFA060")
		cCtlMenu := "VDFM030"
	EndIf

	If cCtlMenu == "VDFM030"	
		ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.VDFM030'							OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina Title STR0003 Action 'VDFA060({"VDFM030",REW->REW_CODIGO,""})'	OPERATION 3 ACCESS 0 //'Itens Atos/Port'
	Else
		ADD OPTION aRotina Title STR0004 Action 'VD060PROC()'								OPERATION 3 ACCESS 0 //'Processar'
	EndIf

Return aRotina


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cria a estrutura a ser usada no Modelo de Dados 
@sample		MenuDef()
@return		oModel, objeto, Retorna o Modelo de dados 
@author		Nivia Ferreira
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oStruREW := FWFormStruct( 1, 'REW' )   // Cria as estruturas a serem usadas no Modelo de Dados  
Local oModel                                 // Modelo de dados construido  

	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('VDFM030MODEL', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	//Adiciona ao modelo um componente de formulario
	oModel:AddFields( 'REWMASTER',, oStruREW )

	//Cria a chave primaria
	oModel:SetPrimaryKey( { "REW_FILIAL", "REW_CODIGO"} ) 

	//Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0005 ) //'Modelo de Complemento'

	//Adiciona a descricao dos Componentes do Modelo de Dados
	oModel:GetModel( 'REWMASTER' ):SetDescription( STR0006 )  //'Cadastro de Concurso'

Return (oModel)  // Retorna o Modelo de dados


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria um objeto de Modelo de Dados baseado no ModelDef 
@sample		ViewDef()
@return		oView, objeto, Retorna o objeto de View criado
@author		Nivia Ferreira
@since		11/06/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FWLoadModel( 'VDFM030' ) // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruREW	:= FWFormStruct( 2, 'REW')  // Cria as estruturas a serem usadas na View
Local oView                                 // Interface de visualizacao construida

	oView := FWFormView():New()  // Cria o objeto de View
	oView:SetModel( oModel )     // Define qual Modelo de dados sera utilizado

	//Adiciona no nosso View um controle do tipo formulario (antiga Enchoice)
	oView:AddField( 'VIEW_REW', oStruREW, 'REWMASTER' ) 

	//Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'TELA', 80 )

	//Relaciona o identificador (ID) da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_REW', 'TELA' )  

Return (oView)  // Retorna o objeto de View criado


