#INCLUDE "TMSC050.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSC050
Consulta de documentos
@type function
@author Wellington A Santos
@version 12
@since 02/06/2004
@return Nil Não há retorno
@obs Alterado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 25/05/2017
/*/
//-------------------------------------------------------------------------------------------------
Function TMSC050()

	Local aCores := {}

	Private lRet      := .T.
	Private cFilMbrow := ""
	Private cCadastro := STR0001 //'Consulta de Documentos'
	Private aRotina	  := MenuDef()

	Aadd(aCores, {"DT6_STATUS == '1'","BR_VERDE"})    //-- Em aberto
	Aadd(aCores, {"DT6_STATUS == '2'","BR_VERMELHO"}) //-- Carregado
	Aadd(aCores, {"DT6_STATUS == '3'","BR_AMARELO"})  //-- Em transito
	Aadd(aCores, {"DT6_STATUS == '4'","BR_LARANJA"})  //-- Chegada parcial
	Aadd(aCores, {"DT6_STATUS == '5'","BR_AZUL"})     //-- Chegada final
	Aadd(aCores, {"DT6_STATUS == '6'","BR_CINZA"})    //-- Indicado p/ entrega
	Aadd(aCores, {"DT6_STATUS == '7'","BR_MARRON"})   //-- Entregue

	DbSelectArea('DT6')
	DbSetOrder(1)

	If ! TMSC050Per() //-- Chama os filtros e o pergunte
		lRet := .F.
	EndIf

	If lRet
		mBrowse(6, 1, 22, 75, "DT6",,,,,, aCores,,,,,,,, cFilMBrow)
	EndIf
	
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSC050Per
Chama o pergunte e faz o filtro
@type function
@author Wellington A Santos
@version 12
@since 02/06/2004
@return lRet True ou False
@obs Alterado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 25/05/2017
/*/
//-------------------------------------------------------------------------------------------------
Function TMSC050Per()

	DbSelectArea('DT6')
	DbSetOrder(1)

	If ! Pergunte("TMC050", .T.)
		lRet := .F.
	EndIf

	cFilMbrow := "     DT6_CLIREM >= '" + MV_PAR01 + "'"				
	cFilMbrow += " And DT6_LOJREM >= '" + MV_PAR02 + "'"		
	cFilMbrow += " And DT6_CLIREM <= '" + MV_PAR03 + "'"				
	cFilMbrow += " And DT6_LOJREM <= '" + MV_PAR04 + "'"		
	cFilMbrow += " And DT6_CLIDES >= '" + MV_PAR05 + "'"				
	cFilMbrow += " And DT6_LOJDES >= '" + MV_PAR06 + "'"		
	cFilMbrow += " And DT6_CLIDES <= '" + MV_PAR07 + "'"				
	cFilMbrow += " And DT6_LOJDES <= '" + MV_PAR08 + "'"		
	cFilMbrow += " And DT6_DATEMI >= '" + Dtos(MV_PAR09) + "'"				
	cFilMbrow += " And DT6_DATEMI <= '" + Dtos(MV_PAR10) + "'"		

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilização de menu Funcional
@type function
@author Wellington A Santos
@version 12
@since 02/06/2004
@return aRotina Array com opções da rotina
@obs Alterado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 25/05/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef()
     
	Private aRotina := {{ STR0002, "TmsXPesqui"  , 0, 1, 0, .F.},; //STR0002 "Pesquisar"
					    { STR0003, "TmsA500Mnt"  , 0, 2, 0, NIL},; //STR0003 "Visualizar" 
					    { STR0055, "TmsA500Leg()", 0, 7, 0, .F.}}  //STR0055 "Legenda"

	If ExistBlock("TMC050MNU")
		ExecBlock("TMC050MNU", .F., .F.)
	EndIf

Return aRotina