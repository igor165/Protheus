// 浜様様様曜様様様様�
// � Versao � 02     �
// 藩様様様擁様様様様�
#Include "protheus.ch"
#Include "VEICA120.ch"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � VEICA120 �Autor  � Andre Luis Almeida � Data �  10/11/15   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Cadastro de Etapas do Funil de Venda                       艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � DMS - Gestao de Concessionarias                            艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
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
	oBrowse:AddLegend( "VQT_TIPETA == '2'"                        , "BR_AMARELO" , STR0007 ) // Pe�as Balc�o
	oBrowse:AddLegend( "VQT_TIPETA == '3'"                        , "BR_LARANJA" , STR0008 ) // Pe�as/Servi�os Oficina
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