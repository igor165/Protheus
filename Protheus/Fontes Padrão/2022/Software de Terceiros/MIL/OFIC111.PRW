#include "PROTHEUS.CH"
#INCLUDE "OFIC111.CH"

/*/{Protheus.doc} OFIC111
Consulta - Oficina - Itens com Divergências entre Solicitações e Conferências Aprovadas

@author Andre
@since 12/11/2019
@version undefined

@type function
/*/
Function OFIC111()

Local oWorkarea
Local oDlgOC111
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 // Oficina - Itens com Divergências entre Solicitações e Conferências Aprovadas
Private oBrwVM4
Private oBrwVM3
Private cSB1Grp := Space(GetSX3Cache('B1_GRUPO', 'X3_TAMANHO'))
Private cSB1Ite := Space(GetSX3Cache('B1_CODITE', 'X3_TAMANHO'))

DbSelectArea("VM4")
DbSelectArea("VM3")

SetKey(VK_F12, {|| OC111001B_FiltraItemGrupo()})

oDlgOC111 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oDlgOC111 )
oWorkArea:CreateHorizontalBox( "LINE1", 69 , .f. ) // -1 para nao estourar 100% da tela ( criando scroll lateral )
oWorkArea:SetBoxCols( "LINE1", { "OBJTop" } )
oWorkArea:CreateHorizontalBox( "LINE2", 30 , .f. )
oWorkArea:SetBoxCols( "LINE2", { "OBJDow" } )
oWorkArea:Activate()
//
cFiltroVM4 := "@ VM4_QTSOLI <> VM4_QTCONF "
cFiltroVM4 += "AND EXISTS ( "
cFiltroVM4 += " SELECT VM3.VM3_CODIGO "
cFiltroVM4 += "   FROM "+RetSQLName("VM3")+" VM3"
cFiltroVM4 += "  WHERE VM3.VM3_FILIAL=VM4_FILIAL"
cFiltroVM4 += "    AND VM3.VM3_CODIGO=VM4_CODVM3"
cFiltroVM4 += "    AND VM3.VM3_STATUS='4'"
cFiltroVM4 += "    AND VM3.D_E_L_E_T_=' '"
cFiltroVM4 += " ) "
//
oBrwVM4:= FWMBrowse():New() 
oBrwVM4:SetOwner( oWorkarea:GetPanel("OBJTop") )
oBrwVM4:SetAlias("VM4")
oBrwVM4:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM4:DisableLocate()
oBrwVM4:DisableDetails()
oBrwVM4:SetAmbiente(.F.)
oBrwVM4:SetWalkthru(.F.)
oBrwVM4:SetDescription(STR0001) // Oficina - Itens com Divergências entre Solicitações e Conferências Aprovadas
oBrwVM4:AddLegend( "VM4_QTCONF = 0"          , "BR_CINZA"   , STR0002 ) // Itens sem Conferência mas existem na Solicitação da OS
oBrwVM4:AddLegend( "VM4_QTCONF > 0 .AND. VM4_QTSOLI > VM4_QTCONF" , "BR_LARANJA" , STR0003 ) // Itens com quantidades Conferidas menores do que os existentes na Solicitação da OS
oBrwVM4:SetFilterDefault(cFiltroVM4)
oBrwVM4:SetInsert(.f.)
oBrwVM4:ForceQuitButton(.T.)
oBrwVM4:SetUseFilter()
oBrwVM4:lOptionReport := .f.
oBrwVM4:Activate()

oBrwVM3:= FWMBrowse():New() 
oBrwVM3:SetOwner( oWorkarea:GetPanel("OBJDow") )
oBrwVM3:SetAlias("VM3")
oBrwVM3:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM3:DisableLocate()
oBrwVM3:DisableDetails()
oBrwVM3:SetAmbiente(.F.)
oBrwVM3:SetWalkthru(.F.)
oBrwVM3:SetMenuDef("")
oBrwVM3:SetDescription(STR0004) // Conferência Aprovada relacionada a Divergência
oBrwVM3:SetInsert(.f.)
oBrwVM3:SetUseFilter(.f.)
oBrwVM3:lOptionReport := .f.
oBrwVM3:Activate()
oRelacNF:= FWBrwRelation():New() 
oRelacNF:AddRelation( oBrwVM4 , oBrwVM3 , { { "VM3_FILIAL" , "VM4_FILIAL" }, { "VM3_CODIGO" , "VM4_CODVM3" } })
oRelacNF:Activate()

VM3->(DbGoTop())

oDlgOC111:Activate( , , , , , , ) //ativa a janela
SetKey(VK_F12, Nil)

Return

/*/{Protheus.doc} MenuDef
MenuDef

@author Andre
@since 12/11/2019
@version undefined

@type function
/*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{STR0005,"AxPesqui"	,0,1})	// Pesquisar
aAdd(aRotina,{STR0006,"OC1100011_VisualizarConferencia",0,2})	// Visualizar
Return aRotina

/*/{Protheus.doc} OC111001B_FiltraItemGrupo
//Filtra Browse com Grupo e Item através tecla F12, ParamBox.

@author Alecsandre Ferreira
@since 06/09/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OC111001B_FiltraItemGrupo()
	Local cCod := ""
	Local aParamBox := {}
	Local aRetParam := {}

	SetKey(VK_F12, Nil)

	aAdd(aParamBox,{1,STR0007,cSB1Grp,"@!","Vazio() .OR. FG_SEEK('SBM','MV_PAR01',1,.F.)","SBM","",40,.F.}) // Grupo
	aAdd(aParamBox,{1,STR0013,cSB1Ite,"@!","Vazio() .OR. FG_POSSB1('MV_PAR02','SB1->B1_CODITE','MV_PAR01')","B01P01","",90,.F.}) // Código do Item

	If ParamBox(aParamBox,"",@aRetParam,,,,,,,,.f.)
		If !Empty(aRetParam[1]+aRetParam[2])
			if Empty(aRetParam[1]) .OR. Empty(aRetParam[2])
				MsgAlert(STR0010, STR0009) //Favor preencher o Grupo e o Código do Item! / Atencao!
				SetKey(VK_F12, {|| OC111001B_FiltraItemGrupo()})
				Return
			Endif
			cCod := FM_SQL(" SELECT B1_COD FROM " + retSqlName("SB1") + " SB1 WHERE B1_FILIAL = '" + xFilial("SB1") +"' AND B1_GRUPO = '" + aRetParam[1] + "' AND B1_CODITE = '" + aRetParam[2] + "' AND D_E_L_E_T_ = ' ' ")
			If Empty(cCod)
				MsgAlert(STR0011, STR0009) //Item não encontrado! / Atenção!
				SetKey(VK_F12, {|| OC111001B_FiltraItemGrupo()})
				Return
			Endif
		Endif
		cSB1Grp := aRetParam[1]
		cSB1Ite := aRetParam[2]
		oBrwVM4:DeleteFilter("b1ite")
		If !Empty(cCod)
			oBrwVM4:AddFilter(STR0012 + cSB1Grp + " " + cSB1Ite, "@ VM4_COD ='" + alltrim(cCod) + "' ",.t.,.t.,,,,"b1ite") //Item
		EndIf
		oBrwVM4:ExecuteFilter(.t.)
	EndIf
	
	SetKey(VK_F12, {|| OC111001B_FiltraItemGrupo()})

Return
