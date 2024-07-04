#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA213.CH"
/*/
{Protheus.doc} OFIA213
Exclusão de Solicitações Pendentes de Peças Oficina e Itens (OFIA214)

@author Andre Luis Almeida
@since 10/05/2021
@version undefined

@type function
/*/
Function OFIA213()

Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 // Exclusão de Solicitações Pendentes de Peças Oficina

DbSelectArea("VM3")
DbSelectArea("VM4")

oDlgOA213 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oTPanVM3 := TPanel():New(0,0,"",oDlgOA213,NIL,.T.,.F.,NIL,NIL,100,(oDlgOA213:nClientHeight/4)-10,.F.,.F.)
oTPanVM3:Align := CONTROL_ALIGN_TOP

oTPanVM4 := TPanel():New(0,0,"",oDlgOA213,NIL,.T.,.F.,NIL,NIL,100,(oDlgOA213:nClientHeight/4)-10,.F.,.F.)
oTPanVM4:Align := CONTROL_ALIGN_BOTTOM 

oBrwVM3:= FWMBrowse():New() 
oBrwVM3:SetOwner( oTPanVM3 )
oBrwVM3:SetAlias("VM3")
oBrwVM3:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM3:DisableLocate()
oBrwVM3:DisableDetails()
oBrwVM3:SetAmbiente(.F.)
oBrwVM3:SetWalkthru(.F.)
oBrwVM3:SetDescription(cCadastro)
oBrwVM3:SetFilterDefault("@ VM3_STATUS='1'")
oBrwVM3:SetInsert(.f.)
oBrwVM3:ForceQuitButton(.T.)
oBrwVM3:SetUseFilter()
oBrwVM3:lOptionReport := .f.
oBrwVM3:Activate()

oBrwVM4:= FWMBrowse():New() 
oBrwVM4:SetOwner( oTPanVM4 )
oBrwVM4:SetAlias("VM4")
oBrwVM4:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM4:DisableLocate()
oBrwVM4:DisableDetails()
oBrwVM4:SetAmbiente(.F.)
oBrwVM4:SetWalkthru(.F.)
oBrwVM4:SetMenuDef("OFIA214")
oBrwVM4:SetDescription(STR0002) // Peças Solicitadas
oBrwVM4:SetInsert(.f.)
oBrwVM4:SetUseFilter(.f.)
oBrwVM4:lOptionReport := .f.
oBrwVM4:Activate()

oRelac:= FWBrwRelation():New() 
oRelac:AddRelation( oBrwVM3 , oBrwVM4 , { { "VM4_FILIAL" , "VM3_FILIAL" }, { "VM4_CODVM3" , "VM3_CODIGO" } })
oRelac:Activate()

oDlgOA213:Activate( , , , , , , ) //ativa a janela

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
aAdd(aRotina,{STR0003,"AxPesqui"	,0,1})	// Pesquisar
aAdd(aRotina,{STR0004,"OA2130011_Excluir_Solicitacao",0,5})	// Excluir Solicitação
Return aRotina

/*/{Protheus.doc} OA2130011_Excluir_Solicitacao

@author Andre Luis Almeida
@since 11/05/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OA2130011_Excluir_Solicitacao()
If MsgNoYes(STR0006,STR0005) // Deseja excluir a Solicitação de Peças Oficina com seus respectivos Itens? / Atenção
	If VM3->VM3_STATUS == '1' // Pendente
		If !Softlock("VM3") // Travar Registro do VM3
			Return
		EndIf
		DbSelectArea("VM4")
		DbSetOrder(1)
		DbSeek( xFilial("VM4") + VM3->VM3_CODIGO )
		Do While !Eof() .and. xFilial("VM4")==VM4->VM4_FILIAL .and. VM4->VM4_CODVM3 == VM3->VM3_CODIGO
			reclock("VM4",.f.,.t.)
				dbDelete() // Excluir cada Peca
			msunlock()
			DbSelectArea("VM4")
			DbSkip()
		EndDo
		DbSelectArea("VM3")
		reclock("VM3",.f.,.t.)
			dbDelete() // Excluir a Solicitação
		msunlock()
		VM3->(MsUnlock()) // Retirar SoftLock do VM3
	EndIf
EndIf
Return