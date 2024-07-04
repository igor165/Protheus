#INCLUDE "plsa960.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA960ESP
Especialidade do profissional de saúde

@author    PLS TEAM
@version   12.1.17
@since     07/05/2019
/*/
Function PLSA960ESP

Local oBrowse := nil
Local cFiltro := "@BQ1_FILIAL = '"+xFilial("BQ1")+"' AND BQ1_CODIGO = '"+BB0->BB0_CODIGO+"' AND D_E_L_E_T_ = ' '"
oBrowse := FWMBrowse():New()
oBrowse:setMainProc("PLSA960ESP")
oBrowse:SetAlias('BQ1')
oBrowse:SetDescription(PLSRetTit('BQ1')) 	//Documentação
oBrowse:SetMenuDef('PLSA960ESP')		//Define que este é o Browse que será utilizado na chamada da função
oBrowse:SetFilterDefault(cFiltro) //Define o Filtro padrão
oBrowse:Activate()

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - MVC

@author    PLS TEAM
@version   12.1.17
@since     07/05/2019
/*/
static function MenuDef()

local aRotina := {	{ 'Pesquisar' 		, 'AxPesqui' 								, 0, K_Pesquisar 	, 0, .F.},; 	//"Pesquisar"
						{ 'Incluir' 	, 'PLSESPMOV' 								, 0, K_Incluir		, 0, Nil},; 	//"Incluir"
       		         	{ 'Alterar' 	, 'AxAltera' 								, 0, K_Alterar   	, 0, Nil},; 	//"Alterar"
			   			{ 'Excluir' 	, 'AxDeleta("BQ1", BQ1->( Recno() ), 5)' 	, 0, K_Excluir   	, 0, Nil},; 	//"Excluir"
			   			{ 'Visualizar' 	, 'AxVisual' 								, 0, K_Visualizar   , 0, Nil}} 		//"Visualizar"

return aRotina
