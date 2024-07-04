#include "PROTHEUS.CH"
#INCLUDE "OFIC131.CH"

/*/{Protheus.doc} OFIC131
Consulta - Orçamento - Itens com Divergências entre o Orçamento e Conferências Aprovadas

@author Andre
@since 20/11/2019
@version undefined

@type function
/*/
Function OFIC131()

Local oWorkarea
Local oDlgOC131
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 // Itens com Divergências entre o Orçamento e Conferências Aprovadas
Private oBrwVM6
Private oBrwVM5
Private cSB1Grp := Space(GetSX3Cache("B1_GRUPO", "X3_TAMANHO"))
Private	cSB1Ite := Space(GetSX3Cache("B1_CODITE", "X3_TAMANHO"))

DbSelectArea("VM6")
DbSelectArea("VM5")

SetKey(VK_F12,{ || OC131001B_FiltraItemGrupo() })

oDlgOC131 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oDlgOC131 )
oWorkArea:CreateHorizontalBox( "LINE1", 69 , .f. ) // -1 para nao estourar 100% da tela ( criando scroll lateral )
oWorkArea:SetBoxCols( "LINE1", { "OBJTop" } )
oWorkArea:CreateHorizontalBox( "LINE2", 30 , .f. )
oWorkArea:SetBoxCols( "LINE2", { "OBJDow" } )
oWorkArea:Activate()

cFiltroVM6 := "@ VM6_QTORIG <> VM6_QTCONF "
cFiltroVM6 += "AND EXISTS ( "
cFiltroVM6 += " SELECT VM5.VM5_CODIGO "
cFiltroVM6 += "   FROM "+RetSQLName("VM5")+" VM5"
cFiltroVM6 += "  WHERE VM5.VM5_FILIAL=VM6_FILIAL"
cFiltroVM6 += "    AND VM5.VM5_CODIGO=VM6_CODVM5"
cFiltroVM6 += "    AND VM5.VM5_STATUS='4'"
cFiltroVM6 += "    AND VM5.D_E_L_E_T_=' '"
cFiltroVM6 += " )"
//
oBrwVM6:= FWMBrowse():New() 
oBrwVM6:SetOwner( oWorkarea:GetPanel("OBJTop") )
oBrwVM6:SetAlias("VM6")
oBrwVM6:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM6:DisableLocate()
oBrwVM6:DisableDetails()
oBrwVM6:SetAmbiente(.F.)
oBrwVM6:SetWalkthru(.F.)
oBrwVM6:SetDescription(STR0001) // Itens com Divergências entre o Orçamento e Conferências Aprovadas
oBrwVM6:AddLegend( "VM6_QTCONF = 0"          , "BR_CINZA"   , STR0002 ) // Itens sem Conferência mas existem no Orçamento
oBrwVM6:AddLegend( "VM6_QTCONF > 0 .AND. VM6_QTORIG > VM6_QTCONF" , "BR_LARANJA" , STR0003 ) // Itens com quantidades Conferidas menores do que os existentes no Orçamento
oBrwVM6:SetFilterDefault(cFiltroVM6)
oBrwVM6:SetInsert(.f.)
oBrwVM6:ForceQuitButton(.T.)
oBrwVM6:SetUseFilter()
oBrwVM6:lOptionReport := .f.
oBrwVM6:Activate()

oBrwVM5:= FWMBrowse():New() 
oBrwVM5:SetOwner( oWorkarea:GetPanel("OBJDow") )
oBrwVM5:SetAlias("VM5")
oBrwVM5:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM5:DisableLocate()
oBrwVM5:DisableDetails()
oBrwVM5:SetAmbiente(.F.)
oBrwVM5:SetWalkthru(.F.)
oBrwVM5:SetMenuDef("")
oBrwVM5:SetDescription(STR0004) // Conferência Aprovada relacionada a Divergência
oBrwVM5:SetInsert(.f.)
oBrwVM5:SetUseFilter(.f.)
oBrwVM5:lOptionReport := .f.
oBrwVM5:Activate()
oRelacNF:= FWBrwRelation():New() 
oRelacNF:AddRelation( oBrwVM6 , oBrwVM5 , { { "VM5_FILIAL" , "VM6_FILIAL" }, { "VM5_CODIGO" , "VM6_CODVM5" } })
oRelacNF:Activate()

VM5->(DbGoTop())

oDlgOC131:Activate( , , , , , , ) //ativa a janela
SetKey(VK_F12, Nil)

Return

/*/{Protheus.doc} MenuDef
MenuDef

@author Andre
@since 20/11/2019
@version undefined

@type function
/*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{STR0005,"AxPesqui"	,0,1})	// Pesquisar
aAdd(aRotina,{STR0006,"OC1300011_VisualizarConferencia",0,2})	// Visualizar
Return aRotina

/*/{Protheus.doc} OC131001B_FiltraItemGrupo
//Filtra Browse com Grupo e Item através tecla F12, ParamBox.

@author Alecsandre Ferreira
@since 06/09/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OC131001B_FiltraItemGrupo()
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
				SetKey(VK_F12,{ || OC131001B_FiltraItemGrupo() })
				Return
			Endif
			cCod := FM_SQL(" SELECT B1_COD FROM " + retSqlName("SB1") + " SB1 WHERE B1_FILIAL = '" + xFilial("SB1") +"' AND B1_GRUPO = '" + aRetParam[1] + "' AND B1_CODITE = '" + aRetParam[2] + "' AND D_E_L_E_T_ = ' ' ")
			If Empty(cCod)
				MsgAlert(STR0011, STR0009) //Item não encontrado! / Atenção!
				SetKey(VK_F12,{ || OC131001B_FiltraItemGrupo() })
				Return
			Endif
		Endif
		cSB1Grp := aRetParam[1]
		cSB1Ite := aRetParam[2]
		oBrwVM6:DeleteFilter("b1ite")
		If !Empty(cCod)
			oBrwVM6:AddFilter(STR0012 + cSB1Grp + " " + cSB1Ite, "@ VM6_COD ='" + alltrim(cCod) + "' ",.t.,.t.,,,,"b1ite") // Item:
		EndIf
		oBrwVM6:ExecuteFilter(.t.)
	EndIf

	SetKey(VK_F12,{ || OC131001B_FiltraItemGrupo() })

Return
