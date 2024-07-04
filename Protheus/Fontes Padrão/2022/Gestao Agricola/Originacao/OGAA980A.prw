#INCLUDE "OGAA980.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"


/*/{Protheus.doc} OGAA980HIS
//Tela para consulta dos preços 
@author tamyris.g
@since 19/02/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function OGAA980A()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oSize     := Nil
	Local aButtons  := {}
	Local nOpcX     := 0
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],STR0011,,,,,CLR_BLACK,CLR_WHITE,,, .t. )   
		
	// Instancia o layer
	oFwLayer := FWLayer():New()

	// Inicia o Layer
	oFwLayer:init( oDlg, .F. )

	// Cria as divisões horizontais
	oFwLayer:addLine('UP' , 100, .F.)
	oFwLayer:addCollumn('ALL', 100, .F., 'UP')
	
	//cria as janelas
	oFwLayer:addWindow('ALL', 'WndUp', STR0011, 100, .F., .T.,, 'UP') 

	// Recupera os Paineis das divisões do Layer
	oPnlUP  := oFwLayer:getWinPanel('ALL' , 'WndUp'  , 'UP')
	
	oBrwHist := FWMBrowse():New()
	oBrwHist:SetAlias( "NCZ" )
	oBrwHist:SetSeek(.T.)
	oBrwHist:SetOwner(oPnlUP)
	oBrwHist:SetFilterDefault(  " !EMPTY(NCZ_DATFIM) .And. NCZ_CODPRO == '" + NCZ->NCZ_CODPRO + "' .And. NCZ_ANO == '" + NCZ->NCZ_ANO + "'"   )
	oBrwHist:SetMenuDef("OGAA980A")
	oBrwHist:Activate()
		
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )
	
	RestArea(aArea)
Return .T.

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina
@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author:    tamyris.g
@since:     04/10/2018
@Uso: 		OGAA980
*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002   ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.OGAA980" OPERATION 2 ACCESS 0 //"Visualizar"
	
Return aRotina

