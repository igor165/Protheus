#INCLUDE "PROTHEUS.CH"

 //------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA440

Rotina que faz a chamada para o perfil do contato  

@sample	CRMA440()

@return	Nenhum

@author	Victor Bitencourt
@since		19/05/2014
@version	P12
/*/ 
//------------------------------------------------------------------------------
Function CRMA440() 

Local cAlias     := Alias()
Local cFiltro    := ""
Local cFiltroEnt := ""

If !( FunName() == "CRMA440" ) .And. ProcName( 2 ) <> "CRMA290RFUN"  
	If cAlias == "SU5"
		cFiltroEnt := "U5_FILIAL = '" + xFilial("SU5") + "' .AND. U5_CODCONT = '" + SU5->U5_CODCONT + "'"
	EndIf
EndIf

cFiltro := CRMXFilEnt( "SU5", .T. )
TMKC010( cFiltro, cFiltroEnt )		// Perfil do Contato

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

Private aRotina := StaticCall( TMKC010 , MENUDEF )

Return( aRotina )