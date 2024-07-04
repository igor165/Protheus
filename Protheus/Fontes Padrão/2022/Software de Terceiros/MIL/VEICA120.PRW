// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 02     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#Include "protheus.ch"
#Include "VEICA120.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEICA120 ºAutor  ³ Andre Luis Almeida º Data ³  10/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de Etapas do Funil de Venda                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DMS - Gestao de Concessionarias                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICA120()

Private oBrowse
Private aRotina   := MenuDef()
Private cCadastro := STR0001 // Etapas do Funil de Venda

DbSelectArea("VQT")
oBrowse:= FWMBrowse():New()
oBrowse:SetAlias('VQT')
oBrowse:SetDescription(cCadastro) //  Etapas do Funil de Venda
oBrowse:DisableDetails()
If VQT->(FieldPos("VQT_TIPETA")) > 0
	oBrowse:AddLegend( "Empty(VQT_TIPETA) .or. VQT_TIPETA == '1'" , "BR_BRANCO"  , STR0006 ) // Veiculos/Maquinas
	oBrowse:AddLegend( "VQT_TIPETA == '2'"                        , "BR_AMARELO" , STR0007 ) // Peças Balcão
	oBrowse:AddLegend( "VQT_TIPETA == '3'"                        , "BR_LARANJA" , STR0008 ) // Peças/Serviços Oficina
EndIf
oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef()
MenuDef da rotina VEICA120

@author Andre Luis Almeida
@since 07/02/2019
@version undefined
/*/
Static Function MenuDef()
Local aRotina := {	{ STR0005 ,"axPesqui", 0 , 1 },; 	// Pesquisar
					{ STR0002 ,"axVisual" , 0 , 2 },;	// Visualizar
					{ STR0003 ,"axInclui" , 0 , 3 },;	// Incluir
					{ STR0004 ,"axAltera" , 0 , 4 }}	// Exlcuir
Return aRotina