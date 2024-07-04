#include "PROTHEUS.CH"
#INCLUDE "OFIC101.CH"

/*/{Protheus.doc} OFIC101
Consulta - Itens com Divergências em NF de Entrada já efetivada

@author Andre
@since 20/10/2019
@version undefined

@type function
/*/
Function OFIC101()

Local oWorkarea
Local oDlgOC101
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 // Itens com Divergências em NF de Entrada já efetivada
Private oBrwVM1
Private oBrwVM0
Private cSB1Grp := Space(GetSX3Cache("B1_GRUPO", "X3_TAMANHO"))
Private cSB1Ite := Space(GetSX3Cache("B1_CODITE", "X3_TAMANHO"))

DbSelectArea("VM1")
DbSelectArea("VM0")

oDlgOC101 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oDlgOC101 )
oWorkArea:CreateHorizontalBox( "LINE1", 69 , .f. ) // -1 para nao estourar 100% da tela ( criando scroll lateral )
oWorkArea:SetBoxCols( "LINE1", { "OBJTop" } )
oWorkArea:CreateHorizontalBox( "LINE2", 30 , .f. )
oWorkArea:SetBoxCols( "LINE2", { "OBJDow" } )
oWorkArea:Activate()

SetKey(VK_F12,{ || OC101001B_FiltraItemGrupo() })

//
cFiltroVM1 := "@ VM1_QTORIG <> VM1_QTCONF "
cFiltroVM1 += "AND EXISTS ( "
cFiltroVM1 += " SELECT VM0.VM0_DOC "
cFiltroVM1 += "   FROM "+RetSQLName("VM0")+" VM0"
cFiltroVM1 += "   JOIN "+RetSqlName("SF1")+" SF1"
cFiltroVM1 += "    ON  SF1.F1_FILIAL='"+xFilial("SF1")+"'"
cFiltroVM1 += "    AND SF1.F1_DOC=VM0.VM0_DOC"
cFiltroVM1 += "    AND SF1.F1_SERIE=VM0.VM0_SERIE"
cFiltroVM1 += "    AND SF1.F1_FORNECE=VM0.VM0_FORNEC"
cFiltroVM1 += "    AND SF1.F1_LOJA=VM0.VM0_LOJA"
cFiltroVM1 += "    AND SF1.F1_STATUS<>' '"
cFiltroVM1 += "    AND SF1.D_E_L_E_T_=' '"
cFiltroVM1 += "  WHERE VM0.VM0_FILIAL=VM1_FILIAL"
cFiltroVM1 += "    AND VM0.VM0_CODIGO=VM1_CODVM0"
cFiltroVM1 += "    AND VM0.VM0_STATUS='4'"
cFiltroVM1 += "    AND VM0.D_E_L_E_T_=' '"
cFiltroVM1 += " )"
//
oBrwVM1:= FWMBrowse():New() 
oBrwVM1:SetOwner( oWorkarea:GetPanel("OBJTop") )
oBrwVM1:SetAlias("VM1")
oBrwVM1:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM1:DisableLocate()
oBrwVM1:DisableDetails()
oBrwVM1:SetAmbiente(.F.)
oBrwVM1:SetWalkthru(.F.)
oBrwVM1:SetDescription(STR0001) // Itens com Divergências em NF de Entrada já efetivada
oBrwVM1:AddLegend( "VM1_QTORIG = 0"          , "BR_AZUL"    , STR0002 ) // Itens não existentes na NF de Entrada
oBrwVM1:AddLegend( "VM1_QTCONF = 0"          , "BR_CINZA"   , STR0003 ) // Itens sem Conferência mas existem na NF de Entrada
oBrwVM1:AddLegend( "VM1_QTCONF > 0 .AND. VM1_QTORIG > VM1_QTCONF" , "BR_LARANJA" , STR0004 ) // Itens com quantidades Conferidas menores do que os existentes na NF de Entrada
oBrwVM1:AddLegend( "VM1_QTORIG > 0 .AND. VM1_QTORIG < VM1_QTCONF" , "BR_PINK"    , STR0005 ) // Itens com quantidades Conferidas maiores do que as existentes na NF de Entrada
oBrwVM1:SetFilterDefault(cFiltroVM1)
oBrwVM1:SetInsert(.f.)
oBrwVM1:ForceQuitButton(.T.)
oBrwVM1:SetUseFilter()
oBrwVM1:lOptionReport := .f.
oBrwVM1:Activate()

oBrwVM0:= FWMBrowse():New() 
oBrwVM0:SetOwner( oWorkarea:GetPanel("OBJDow") )
oBrwVM0:SetAlias("VM0")
oBrwVM0:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM0:DisableLocate()
oBrwVM0:DisableDetails()
oBrwVM0:SetAmbiente(.F.)
oBrwVM0:SetWalkthru(.F.)
oBrwVM0:SetMenuDef("")
oBrwVM0:SetDescription(STR0006) // Conferência Aprovada relacionada a Divergência da NF de Entrada
oBrwVM0:SetInsert(.f.)
oBrwVM0:SetUseFilter(.f.)
oBrwVM0:lOptionReport := .f.
oBrwVM0:Activate()
oRelacNF:= FWBrwRelation():New() 
oRelacNF:AddRelation( oBrwVM1 , oBrwVM0 , { { "VM0_FILIAL" , "VM1_FILIAL" }, { "VM0_CODIGO" , "VM1_CODVM0" } })
oRelacNF:Activate()

VM0->(DbGoTop())

oDlgOC101:Activate( , , , , , , ) //ativa a janela

SetKey(VK_F12, Nil)

Return

/*/{Protheus.doc} MenuDef
MenuDef

@author Andre
@since 15/10/2019
@version undefined

@type function
/*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{STR0007,"AxPesqui"	,0,1})	// Pesquisar
aAdd(aRotina,{STR0008,"OC1000011_VisualizarConferencia",0,2})	// Visualizar
Return aRotina


/*/{Protheus.doc} OC101001B_FiltraItemGrupo
//Filtra Browse com Grupo e Item através tecla F12, ParamBox.

@author Alecsandre Ferreira
@since 03/09/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OC101001B_FiltraItemGrupo()
	Local cCod := ""
	Local aParamBox := {}
	Local aRetParam := {}

	SetKey(VK_F12, Nil)

	aAdd(aParamBox,{1,STR0012,cSB1Grp,"@!","Vazio() .OR. FG_SEEK('SBM','MV_PAR01',1,.F.)","SBM","",40,.F.}) // Grupo
	aAdd(aParamBox,{1,STR0015,cSB1Ite,"@!","Vazio() .OR. FG_POSSB1('MV_PAR02','SB1->B1_CODITE','MV_PAR01')","B01P01","",90,.F.}) // Código do Item
	If ParamBox(aParamBox,"",@aRetParam,,,,,,,,.f.)
		If !Empty(aRetParam[1]+aRetParam[2])
			if Empty(aRetParam[1]) .OR. Empty(aRetParam[2])
				MsgAlert(STR0009, STR0010) //Favor preencher o Grupo e o Código do Item! / Atencao!
				SetKey(VK_F12,{ || OC101001B_FiltraItemGrupo() })
				Return
			Endif
			cCod := FM_SQL(" SELECT B1_COD FROM " + retSqlName("SB1") + " SB1 WHERE B1_FILIAL = '" + xFilial("SB1") +"' AND B1_GRUPO = '" + aRetParam[1] + "' AND B1_CODITE = '" + aRetParam[2] + "' AND D_E_L_E_T_ = ' ' ")
			If Empty(cCod)
				MsgAlert(STR0011, STR0010) //Item não encontrado! / Atenção!
				SetKey(VK_F12,{ || OC101001B_FiltraItemGrupo() })
				Return
			Endif
		Endif
		cSB1Grp := aRetParam[1]
		cSB1Ite := aRetParam[2]
		oBrwVM1:DeleteFilter("b1ite")
		If !Empty(cCod)
			oBrwVM1:AddFilter(STR0014 + cSB1Grp + " " + cSB1Ite, "@ VM1_COD ='" + alltrim(cCod) + "' ",.t.,.t.,,,,"b1ite") //Item: 
		EndIf
		oBrwVM1:ExecuteFilter(.t.)
	EndIf

	SetKey(VK_F12,{ || OC101001B_FiltraItemGrupo() })

Return