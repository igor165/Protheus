#Include "Protheus.ch"
#Include "CRMA900.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA900

Browse da estrutura de neg�cios

@sample 	CRMA900()

@return   	.T.

@author	Thamara Villa Jacomo
@since		20/05/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function CRMA900()

Local oBrowse := Nil

Private aRotina 	:= MenuDef()
Private cCadastro := STR0001 //"Estrutura de Neg�cios x Entidades" 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( "AO5" ) 
oBrowse:SetDescription( STR0001 ) //"Estrutura de Neg�cios x Entidades"
oBrowse:Activate()

Return( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Rotina respons�vel por definir as opera��es da rotina

@sample 	MenuDef()

@return   	Nil

@author	Thamara Villa Jacomo
@since		20/05/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {  { STR0002, "AxVisual", 0, 2 } } //"Visualizar"	
                
Return( aRotina )

//------------------------------------------------------------------------------
/*/{Protheus.doc} A900RetDesc

Retorna a descri��o de acordo com o campo para campo virtual.

@sample 	A900RetDesc( cEntAnex )

@param 		nTpCpo - Informa qual o campo base para consulta do retorno
					sendo: 1 - AO5_ENTANE e 2 - AO5_CODANE
@param 		cCpoRet - Entidade anexada

@return    cDesc - Descri��o da entidade anexada

@author	Thamara Villa Jacomo
@since		20/05/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function A900RetDesc( nTpCpo, cCpoRet )

Local cDesc  := ""

Default nTpCpo  := 0
Default cCpoRet := ""

If nTpCpo == 1 //AO5_ENTANE 
	Do Case
	 
		Case cCpoRet == "ADK"
			cDesc := STR0003 //"Unidade de neg�cios"
		Case cCpoRet == "ACA"
			cDesc := STR0004 //"Equipe de vendas"
		Case cCpoRet == "USU"
			cDesc := STR0005 //"Usu�rios do CRM"
			
	EndCase
EndIf 

If nTpCpo == 2 //AO5_CODANE
	Do Case
	
		Case cCpoRet == "ADK"
			cDesc := Posicione( "ADK", 1, xFilial( "ADK" ) + AO5->AO5_CODANE, "ADK_NOME" )
		Case cCpoRet == "ACA"
			cDesc := Posicione( "ACA", 1, xFilial( "ACA" ) + AO5->AO5_CODANE, "ACA_DESCRI" )
		Case cCpoRet == "USU"
			cDesc := UsrRetName( AO5->AO5_CODANE )
			
	EndCase
EndIf

Return( cDesc )

//------------------------------------------------------------------------------
/*/{Protheus.doc} A900RetCrg

Retorna cargo e descri��o para campo virtual se a tabela anexada for de usu�rio
do CRM.

@sample 	A900RetCrg( nPesq )

@param 		nPesq - Informa se o retorno da pesquisa ser�:
					 1 = cargo ou 2 = Descri��o do cargo
					 3 = Equipe ou 4 = Descri��o da equipe
					 5 = Unidade ou 6 = Descri��o da unidade

@return    cDesc - Descri��o do retorno da pesquisa

@author	Thamara Villa Jacomo
@since		21/05/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function A900RetCpo( nPesq )

Local cDesc := ""

Default nPesq := 0

If AO5->AO5_ENTANE == "USU"
	Do Case
		
		Case nPesq == 1 //Cargo
			cDesc := Posicione( "AO3", 1, xFilial( "AO3" ) + AO5->AO5_CODANE, "AO3_CARGO" )
		Case nPesq == 2 // Descri��o do cargo
			cDesc := Posicione( "AO3", 1, xFilial( "AO3" ) + AO5->AO5_CODANE, "AO3_CARGO" )
			cDesc := Posicione( "SUM", 1, xFilial( "SUM" ) + cDesc, "UM_DESC" )   
		Case nPesq == 3 // Equipe
	 		cDesc := Posicione( "AO3", 1, xFilial( "AO3" ) + AO5->AO5_CODANE, "AO3_CODEQP" )     
		Case nPesq == 4 // Descri��o da equipe
			cDesc := Posicione( "AO3", 1, xFilial( "AO3" ) + AO5->AO5_CODANE, "AO3_CODEQP" )
			cDesc := Posicione( "ACA", 1, xFilial( "ACA" ) + cDesc, "ACA_DESCRI" )
		Case nPesq == 5 // C�digo da unidade
			cDesc := Posicione( "AO3", 1, xFilial( "AO3" ) + AO5->AO5_CODANE, "AO3_CODUND" )
		Case nPesq == 6 // Descri��o da unidade
			cDesc := Posicione( "AO3", 1, xFilial( "AO3" ) + AO5->AO5_CODANE, "AO3_CODUND" )
			cDesc := Posicione( "ADK", 1, xFilial( "ADK" ) + cDesc, "ADK_NOME" )
		
	EndCase			                                      
			                                        
EndIf

Return( cDesc )