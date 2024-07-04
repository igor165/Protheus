#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA420.CH"

//---------------------------------------------------------------------

/*/{Protheus.doc} TAFA420

Cadastro MVC do Cadastro do Trabalhador - Carga Inicial

@author Denis R. de Oliveira 
@since 03/02/2016
@version 1.0

/*/
//---------------------------------------------------------------------
Function TAFA420()

	Local oBrw := FwMBrowse():New()

	oBrw:SetDescription( STR0001 ) //"Cadastro do Trabalhador - Carga Inicial"
	oBrw:SetAlias( "C9V" )
	oBrw:SetMenuDef( "TAFA420" )
	oBrw:SetFilterDefault( "C9V_ATIVO == '1' .And. C9V_NOMEVE == 'S2100'")
	
	TafLegend(2,"C9V",@oBrw)

	oBrw:Activate()

Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funçao generica MVC com as opcoes de menu

@Return aRotina - Array com as opções do Menu

@author Denis R. de Oliveira
@since 03/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA420",,,, .T. ) 

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@Return Nil

@author Denis R. de Oliveira
@since 03/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()


Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@Return Nil

@author Denis R. de Oliveira
@since 03/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()


Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} IncCarInic
Funçao que realiza a Inclusão do Cadastro do Trabalhador - Carga Inicial

@Author Denis R de Oliveira
@Since 03/02/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function IncCarInic()

Local nOpc	:= 0 

	nOpc:= Aviso( STR0003, STR0004 + CRLF + CRLF + STR0005 + CRLF + CRLF + STR0006, { STR0007 ,STR0008 }, 3 )
	
	If nOpc == 1
 		FWMsgRun(,{||FWExecView(STR0003, "TAFA256", 3,,{||.T.} )},,"Executando Rotina do Trabalhador... ")
 	EndIf
	
Return
