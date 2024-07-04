#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMA390.CH"

 //------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA390

Rotina que faz a chamada para a consulta de analise gerencial da conta  

@sample		CRMA390()

@return		Nenhum

@author		Thiago Tavares 
@since			10/04/2014
@version		P12
/*/
//------------------------------------------------------------------------------
Function CRMA390()

//Analise Gerencial da Conta
TMKC040()

Return Nil



//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Operações que serão utilizadas pela aplicação

@return   	aRotina - Array das operações

@author		Vendas CRM
@since		15/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := StaticCall( TMKC040 , MENUDEF )

Return( aRotina )