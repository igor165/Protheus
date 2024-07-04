#include "PROTHEUS.CH"
#INCLUDE "OFIC221.CH"

/*/{Protheus.doc} OFIC221
Consulta - Itens com Divergências em Volumes de Entrada com NF já efetivada

@author Andre Luis Almeida
@since 24/08/2021
@version undefined

@type function
/*/
Function OFIC221()

Local oWorkarea
Local oDlgOC221
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 // Itens com Divergências em Volumes de Entrada com NF já efetivada
Private oBrwVM8
Private oBrwVM7
Private cSB1Grp := Space(GetSX3Cache("B1_GRUPO", "X3_TAMANHO"))
Private cSB1Ite := Space(GetSX3Cache("B1_CODITE", "X3_TAMANHO"))

DbSelectArea("VM8")
DbSelectArea("VM7")

oDlgOC221 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oDlgOC221 )
oWorkArea:CreateHorizontalBox( "LINE1", 69 , .f. )
oWorkArea:SetBoxCols( "LINE1", { "OBJTop" } )
oWorkArea:CreateHorizontalBox( "LINE2", 30 , .f. )
oWorkArea:SetBoxCols( "LINE2", { "OBJDow" } )
oWorkArea:Activate()
//
SetKey(VK_F12,{ || OC2210011_FiltraItemGrupo() })
//
cFiltroVM8 := "@ VM8_QTORIG <> VM8_QTCONF "
cFiltroVM8 += "AND EXISTS ( "
cFiltroVM8 += " SELECT VM7.VM7_VOLUME "
cFiltroVM8 += "   FROM "+RetSQLName("VM7")+" VM7"
cFiltroVM8 += "   JOIN "+RetSqlName("VCX")+" VCX"
cFiltroVM8 += "    ON  VCX.VCX_FILIAL='"+xFilial("VCX")+"'"
cFiltroVM8 += "    AND VCX.VCX_VOLUME=VM7.VM7_VOLUME"
cFiltroVM8 += "    AND VCX.VCX_COD=VM8_COD"
cFiltroVM8 += "    AND VCX.D_E_L_E_T_=' '"
cFiltroVM8 += "   JOIN "+RetSqlName("SF1")+" SF1"
cFiltroVM8 += "    ON  SF1.F1_FILIAL='"+xFilial("SF1")+"'"
cFiltroVM8 += "    AND SF1.F1_DOC=VCX.VCX_DOC"
cFiltroVM8 += "    AND SF1.F1_SERIE=VCX.VCX_SERIE"
cFiltroVM8 += "    AND SF1.F1_FORNECE=VCX.VCX_FORNEC"
cFiltroVM8 += "    AND SF1.F1_LOJA=VCX.VCX_LOJA"
cFiltroVM8 += "    AND SF1.F1_STATUS<>' '"
cFiltroVM8 += "    AND SF1.D_E_L_E_T_=' '"
cFiltroVM8 += "  WHERE VM7.VM7_FILIAL=VM8_FILIAL"
cFiltroVM8 += "    AND VM7.VM7_CODIGO=VM8_CODVM7"
cFiltroVM8 += "    AND VM7.VM7_STATUS='4'"
cFiltroVM8 += "    AND VM7.D_E_L_E_T_=' '"
cFiltroVM8 += " )"
//
oBrwVM8:= FWMBrowse():New() 
oBrwVM8:SetOwner( oWorkarea:GetPanel("OBJTop") )
oBrwVM8:SetAlias("VM8")
oBrwVM8:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM8:DisableLocate()
oBrwVM8:DisableDetails()
oBrwVM8:SetAmbiente(.F.)
oBrwVM8:SetWalkthru(.F.)
oBrwVM8:SetDescription(STR0001) // Itens com Divergências em Volumes de Entrada com NF já efetivada
oBrwVM8:AddLegend( "VM8_QTORIG = 0"                               , "BR_AZUL"    , STR0002 ) // Itens não existentes no Volume de Entrada
oBrwVM8:AddLegend( "VM8_QTCONF = 0"                               , "BR_CINZA"   , STR0003 ) // Itens sem Conferência mas existem no Volume de Entrada
oBrwVM8:AddLegend( "VM8_QTCONF > 0 .AND. VM8_QTORIG > VM8_QTCONF" , "BR_LARANJA" , STR0004 ) // Itens com quantidades Conferidas menores do que os existentes no Volume de Entrada
oBrwVM8:AddLegend( "VM8_QTORIG > 0 .AND. VM8_QTORIG < VM8_QTCONF" , "BR_PINK"    , STR0005 ) // Itens com quantidades Conferidas maiores do que as existentes no Volume de Entrada
oBrwVM8:SetFilterDefault(cFiltroVM8)
oBrwVM8:SetInsert(.f.)
oBrwVM8:ForceQuitButton(.T.)
oBrwVM8:SetUseFilter()
oBrwVM8:lOptionReport := .f.
oBrwVM8:Activate()

oBrwVM7:= FWMBrowse():New() 
oBrwVM7:SetOwner( oWorkarea:GetPanel("OBJDow") )
oBrwVM7:SetAlias("VM7")
oBrwVM7:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM7:DisableLocate()
oBrwVM7:DisableDetails()
oBrwVM7:SetAmbiente(.F.)
oBrwVM7:SetWalkthru(.F.)
oBrwVM7:SetMenuDef("")
oBrwVM7:SetDescription(STR0006) // Conferência Aprovada relacionada a Divergência do Volume de Entrada
oBrwVM7:SetInsert(.f.)
oBrwVM7:SetUseFilter(.f.)
oBrwVM7:lOptionReport := .f.
oBrwVM7:Activate()
oRelacVol:= FWBrwRelation():New() 
oRelacVol:AddRelation( oBrwVM8 , oBrwVM7 , { { "VM7_FILIAL" , "VM8_FILIAL" }, { "VM7_CODIGO" , "VM8_CODVM7" } })
oRelacVol:Activate()

VM7->(DbGoTop())

oDlgOC221:Activate( , , , , , , ) //ativa a janela

SetKey(VK_F12, Nil)

Return

/*/{Protheus.doc} MenuDef
MenuDef

@author Andre Luis Almeida
@since 24/08/2021
@version undefined

@type function
/*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{STR0007,"AxPesqui"	,0,1})	// Pesquisar
aAdd(aRotina,{STR0008,"OC2200011_VisualizarConferencia",0,2})	// Visualizar
Return aRotina

/*/{Protheus.doc} OC2210011_FiltraItemGrupo
Filtra Browse com Grupo e Item atraves da tecla F12

@author Andre Luis Almeida
@since 09/09/2021
/*/
Function OC2210011_FiltraItemGrupo()
	Local cCod := ""
	Local aParamBox := {}
	Local aRetParam := {}

	SetKey(VK_F12, Nil)

	aAdd(aParamBox,{1,STR0009,cSB1Grp,"@!","Vazio() .OR. FG_SEEK('SBM','MV_PAR01',1,.F.)","SBM","",40,.F.}) // Grupo
	aAdd(aParamBox,{1,STR0010,cSB1Ite,"@!","Vazio() .OR. FG_POSSB1('MV_PAR02','SB1->B1_CODITE','MV_PAR01')","B01P01","",90,.F.}) // Código do Item
	If ParamBox(aParamBox,"",@aRetParam,,,,,,,,.f.)
		If !Empty(aRetParam[1]+aRetParam[2])
			if Empty(aRetParam[1]) .OR. Empty(aRetParam[2])
				MsgAlert(STR0011,STR0012) // Favor preencher o Grupo e o Código do Item! / Atenção
				SetKey(VK_F12,{ || OC2210011_FiltraItemGrupo() })
				Return
			Endif
			cCod := FM_SQL(" SELECT B1_COD FROM " + retSqlName("SB1") + " SB1 WHERE B1_FILIAL = '" + xFilial("SB1") +"' AND B1_GRUPO = '" + aRetParam[1] + "' AND B1_CODITE = '" + aRetParam[2] + "' AND D_E_L_E_T_ = ' ' ")
			If Empty(cCod)
				MsgAlert(STR0013,STR0012) // Item não encontrado! / Atenção
				SetKey(VK_F12,{ || OC2210011_FiltraItemGrupo() })
				Return
			Endif
		Endif
		cSB1Grp := aRetParam[1]
		cSB1Ite := aRetParam[2]
		oBrwVM8:DeleteFilter("b1ite")
		If !Empty(cCod)
			oBrwVM8:AddFilter(STR0014 + cSB1Grp + " " + cSB1Ite, "@ VM8_COD ='" + alltrim(cCod) + "' ",.t.,.t.,,,,"b1ite") //Item: 
		EndIf
		oBrwVM8:ExecuteFilter(.t.)
	EndIf

	SetKey(VK_F12,{ || OC2210011_FiltraItemGrupo() })

Return