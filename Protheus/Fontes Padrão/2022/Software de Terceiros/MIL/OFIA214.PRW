#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA214.CH"
/*/
{Protheus.doc} OFIA214
Exclusão de Peças das Solicitações Pendentes de Peças Oficina

@author Andre Luis Almeida
@since 11/05/2021
@version undefined

@type function
/*/
Function OFIA214()

Local cFiltro     := ""
Private cCadastro := STR0001 // Exclusão de Peças das Solicitações Pendentes de Peças Oficina

cFiltro := "@ EXISTS ( SELECT VM3.VM3_CODIGO "
cFiltro +=				"FROM " + RetSqlName("VM3") + " VM3 "
cFiltro +=				"WHERE VM3.VM3_FILIAL = VM4_FILIAL "
cFiltro +=				"AND VM3.VM3_CODIGO = VM4_CODVM3 "
cFiltro +=				"AND VM3.VM3_STATUS = '1' "
cFiltro +=				"AND VM3.D_E_L_E_T_ = ' ' "
cFiltro +=	") "

DbSelectArea("VM4")

oBrwVM4:= FWMBrowse():New() 
oBrwVM4:SetAlias("VM4")
oBrwVM4:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM4:DisableLocate()
oBrwVM4:DisableDetails()
oBrwVM4:SetAmbiente(.F.)
oBrwVM4:SetWalkthru(.F.)
oBrwVM4:SetDescription(cCadastro)
oBrwVM4:SetFilterDefault(cFiltro)
oBrwVM4:SetInsert(.f.)
oBrwVM4:SetUseFilter(.f.)
oBrwVM4:lOptionReport := .f.
oBrwVM4:Activate()

Return

/*/{Protheus.doc} MenuDef
MenuDef

@author Andre Luis Almeida
@since 10/05/2021
@version undefined

@type function
/*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{STR0002,"AxPesqui"	,0,1})	// Pesquisar
aAdd(aRotina,{STR0003,"OA2140011_Excluir_Peca",0,5})	// Excluir Peça
Return aRotina

/*/{Protheus.doc} OA2140011_Excluir_Peca

@author Andre Luis Almeida
@since 11/05/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OA2140011_Excluir_Peca()
Local cQuery  := ""
If MsgNoYes(STR0004,STR0005) // Deseja excluir a Peça Solicitada? / Atenção
	DbSelectArea("VM3")
	DbSetOrder(1)
	DbSeek( xFilial("VM3") + VM4->VM4_CODVM3 )
	If VM3->VM3_STATUS == '1' // Pendente
		If !Softlock("VM3") // Travar Registro do VM3
			Return
		EndIf
		DbSelectArea("VM4")
		reclock("VM4",.f.,.t.)
			dbDelete() // Excluir a Peca Especifico
		msunlock()
		//
		cQuery := "SELECT COUNT(VM4_CODVM3) "
		cQuery += "  FROM " + RetSqlName("VM4") 
		cQuery += " WHERE VM4_FILIAL = '"+VM3->VM3_FILIAL+"'"
		cQuery += "   AND VM4_CODVM3 = '"+VM3->VM3_CODIGO+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		If FM_SQL(cQuery) == 0 // Se não existem mais Peças nessa Solicitação
			DbSelectArea("VM3")
			reclock("VM3",.f.,.t.)
				dbDelete() // Excluir a Solicitação
			msunlock()
		EndIf
		VM3->(MsUnlock()) // Retirar SoftLock do VM3
	EndIf
EndIf
Return