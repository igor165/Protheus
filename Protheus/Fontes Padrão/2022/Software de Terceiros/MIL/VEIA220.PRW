#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA220.CH"

/*/{Protheus.doc} VEIA220
	Cadastro/Consulta de Propriedades Agricolas

	@author Andre Luis Almeida
	@since 11/01/2021
/*/
Function VEIA220( lAllReg , cGruNeg , cCodCli , cLojCli , cRegPAg , cMunPAg , cUFMPAg )

Default lAllReg := .f. // .t. Mostra todos os registros de todas as Propriedades Agricolas filtradas no Browse / .f. Mostra apenas os registros relacionados com a Propriedade Agricola posicionada no Browse
Default cGruNeg := "" // Grupo de Negocios
Default cCodCli := "" // Codigo do Cliente
Default cLojCli := "" // Loja do Cliente
Default cRegPAg := "" // Regiao da Propriedade Agricola
Default cMunPAg := "" // Codigo do IBGE do Municipio da Propriedade Agricola
Default cUFMPAg := "" // UF do Municipio da Propriedade Agricola

Processa( {|| VA2200011_TelaBrowsers( lAllReg , cGruNeg , cCodCli , cLojCli , cRegPAg , cMunPAg , cUFMPAg ) } , STR0006 , "", .T.) // Processando / Monta Tela com todos os Browses

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('VEIA220')

	ADD OPTION aRotina TITLE STR0007 ACTION 'VEIC110( "" , "" , "" , "" , "" , "" , VJY->VJY_CODIGO )' OPERATION 2 ACCESS 0 // Dados dos Clientes/Lojas da Propriedade Agricola

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVJY := FWFormStruct(1, "VJY")
	Local oStrVJZ := FWFormStruct(1, "VJZ")
	Local oStrVK0 := FWFormStruct(1, "VK0")
	Local oStrVK1 := FWFormStruct(1, "VK1")
	Local oStrVK2 := FWFormStruct(1, "VK2")
	Local aAuxTrigger := {}

	aAuxTrigger := FwStruTrigger("VJY_IBGE","VJY_MUN","Left(VAM->VAM_DESCID," + cValToChar(GetSX3Cache("VJY_MUN","X3_TAMANHO")) + ")",.T.,"VAM",1,"xFilial('VAM') + FWFldGet('VJY_IBGE')","!Empty(FWFldGet('VJY_IBGE'))")
	oStrVJY:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
	aAuxTrigger := FwStruTrigger("VJY_IBGE","VJY_EST","Left(VAM->VAM_ESTADO," + cValToChar(GetSX3Cache("VJY_EST","X3_TAMANHO")) + ")",.T.,"VAM",1,"xFilial('VAM') + FWFldGet('VJY_IBGE')","!Empty(FWFldGet('VJY_IBGE'))")
	oStrVJY:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
	aAuxTrigger := FwStruTrigger("VJY_AREPRO","VJY_ARETOT","FWFldGet('VJY_AREPRO')+FWFldGet('VJY_AREARR')",.f.,,,,)
	oStrVJY:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
	aAuxTrigger := FwStruTrigger("VJY_AREARR","VJY_ARETOT","FWFldGet('VJY_AREPRO')+FWFldGet('VJY_AREARR')",.f.,,,,)
	oStrVJY:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	aAuxTrigger := FwStruTrigger("VJZ_CODCLI","VJZ_NOMCLI","Left(SA1->A1_NOME," + cValToChar(GetSX3Cache("VJZ_NOMCLI","X3_TAMANHO")) + ")",.T.,"SA1",1,"xFilial('SA1') + FWFldGet('VJZ_CODCLI') + FwFldGet('VJZ_LOJCLI')","!Empty(FWFldGet('VJZ_CODCLI'))")
	oStrVJZ:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
	aAuxTrigger := FwStruTrigger("VJZ_LOJCLI","VJZ_NOMCLI","Left(SA1->A1_NOME," + cValToChar(GetSX3Cache("VJZ_NOMCLI","X3_TAMANHO")) + ")",.T.,"SA1",1,"xFilial('SA1') + FWFldGet('VJZ_CODCLI') + FwFldGet('VJZ_LOJCLI')","!Empty(FWFldGet('VJZ_LOJCLI'))")
	oStrVJZ:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	aAuxTrigger := FwStruTrigger("VK0_ATIVID","VK0_DESCRI","Left(SX5->X5_DESCRI," + cValToChar(GetSX3Cache("VK0_DESCRI","X3_TAMANHO")) + ")",.T.,"SX5",1,"xFilial('SX5') + 'T3' + FWFldGet('VK0_ATIVID') ","!Empty(FWFldGet('VK0_ATIVID'))")
	oStrVK0:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	aAuxTrigger := FwStruTrigger("VK1_CULTUR","VK1_DESCRI","Left(VX5->VX5_DESCRI," + cValToChar(GetSX3Cache("VK1_DESCRI","X3_TAMANHO")) + ")",.T.,"VX5",1,"xFilial('VX5') + '003' + FWFldGet('VK1_CULTUR') ","!Empty(FWFldGet('VK1_CULTUR'))")
	oStrVK1:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	oModel := MPFormModel():New('VEIA220',,,,)

	oModel:AddFields('VJYMASTER',/*cOwner*/ , oStrVJY)
	oModel:SetPrimaryKey( { "VJY_FILIAL", "VJY_CODIGO" } )

	oModel:AddGrid("VJZDETAIL","VJYMASTER",oStrVJZ)
	oModel:SetRelation( 'VJZDETAIL', { { 'VJZ_FILIAL', 'xFilial( "VJZ" )' }, { 'VJZ_PROAGR', 'VJY_CODIGO' } }, VJZ->( IndexKey( 1 ) ) )

	oModel:AddGrid("VK0DETAIL","VJYMASTER",oStrVK0)
	oModel:SetRelation( 'VK0DETAIL', { { 'VK0_FILIAL', 'xFilial( "VK0" )' }, { 'VK0_PROAGR', 'VJY_CODIGO' } }, VK0->( IndexKey( 1 ) ) )
	oModel:GetModel( 'VK0DETAIL' ):SetOptional(.T.) // Permite deixar o em branco a grid filho

	oModel:AddGrid("VK1DETAIL","VJYMASTER",oStrVK1)
	oModel:SetRelation( 'VK1DETAIL', { { 'VK1_FILIAL', 'xFilial( "VK1" )' }, { 'VK1_PROAGR', 'VJY_CODIGO' } }, VK1->( IndexKey( 1 ) ) )
	oModel:GetModel( 'VK1DETAIL' ):SetOptional(.T.) // Permite deixar o em branco a grid filho

	oModel:AddGrid("VK2DETAIL","VJYMASTER",oStrVK2)
	oModel:SetRelation( 'VK2DETAIL', { { 'VK2_FILIAL', 'xFilial( "VK2" )' }, { 'VK2_PROAGR', 'VJY_CODIGO' } }, VK2->( IndexKey( 1 ) ) )
	oModel:GetModel( 'VK2DETAIL' ):SetOptional(.T.) // Permite deixar o em branco a grid filho

	oModel:SetDescription(STR0001) // Propriedades Agricolas
	oModel:GetModel('VJYMASTER'):SetDescription(STR0001) // Propriedades Agricolas
	oModel:GetModel('VJZDETAIL'):SetDescription(STR0002) // Clientes
	oModel:GetModel('VK0DETAIL'):SetDescription(STR0003) // Atividades
	oModel:GetModel('VK1DETAIL'):SetDescription(STR0004) // Culturas
	oModel:GetModel('VK2DETAIL'):SetDescription(STR0005) // Pecuaria

	oModel:AddRules( 'VJZDETAIL', 'VJZ_LOJCLI', 'VJZDETAIL', 'VJZ_CODCLI', 3)

	oModel:GetModel( 'VJZDETAIL' ):SetUniqueLine( { "VJZ_CODCLI" , "VJZ_LOJCLI" })

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVJY:= FWFormStruct(2, "VJY")
	Local oStrVJZ:= FWFormStruct(2, "VJZ", { |cCampo| !ALLTRIM(cCampo)+"|" $ "VJZ_PROAGR|" })
	Local oStrVK0:= FWFormStruct(2, "VK0", { |cCampo| !ALLTRIM(cCampo)+"|" $ "VK0_PROAGR|" })
	Local oStrVK1:= FWFormStruct(2, "VK1", { |cCampo| !ALLTRIM(cCampo)+"|" $ "VK1_PROAGR|" })
	Local oStrVK2:= FWFormStruct(2, "VK2", { |cCampo| !ALLTRIM(cCampo)+"|" $ "VK2_PROAGR|" })

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVJY', 20)
	oView:AddField('VIEW_VJY', oStrVJY, 'VJYMASTER')
	oView:EnableTitleView('VIEW_VJY', STR0001) // Propriedades Agricolas
	oView:SetOwnerView('VIEW_VJY','BOXVJY')

	oView:CreateHorizontalBox('1DETALHES', 40)
	oView:CreateHorizontalBox('2DETALHES', 40)

	oView:CreateVerticalBox('BOXVJZ', 50, '1DETALHES')
	oView:CreateVerticalBox('BOXVK0', 50, '1DETALHES')

	oView:CreateVerticalBox('BOXVK1', 50, '2DETALHES')
	oView:CreateVerticalBox('BOXVK2', 50, '2DETALHES')

	oView:AddGrid("VIEW_VJZ",oStrVJZ, 'VJZDETAIL')
	oView:EnableTitleView('VIEW_VJZ', STR0002) // Clientes
	oView:SetOwnerView('VIEW_VJZ','BOXVJZ')

	oView:AddGrid("VIEW_VK0",oStrVK0, 'VK0DETAIL')
	oView:EnableTitleView('VIEW_VK0', STR0003) // Atividades
	oView:SetOwnerView('VIEW_VK0','BOXVK0')

	oView:AddGrid("VIEW_VK1",oStrVK1, 'VK1DETAIL')
	oView:EnableTitleView('VIEW_VK1', STR0004) // Culturas
	oView:SetOwnerView('VIEW_VK1','BOXVK1')

	oView:AddGrid("VIEW_VK2",oStrVK2, 'VK2DETAIL')
	oView:EnableTitleView('VIEW_VK2', STR0005) // Pecuaria
	oView:SetOwnerView('VIEW_VK2','BOXVK2')

Return oView

/*/{Protheus.doc} VA2200011_TelaBrowsers
	Monta tela com todos os Browses

	@author Andre Luis Almeida
	@since 08/01/2021
/*/
Static Function VA2200011_TelaBrowsers( lAllReg , cGruNeg , cCodCli , cLojCli , cRegPAg , cMunPAg , cUFMPAg )
Local oVEIA220
Local oWorkarea
Local aSize     := FWGetDialogSize( oMainWnd )
Local cTitulo   := STR0001 // Propriedades Agricolas
Local cSQLVJY   := ""
Local cSQLVJZ   := ""
Local cSQLVK0   := ""
Local cSQLVK1   := ""
Local cSQLVK2   := ""
Local aVars     := {}
Local aRotina   := {}
Local lConsulta := .f.

ProcRegua(0)
IncProc(STR0008) // Levantando Dados...

If !Empty( cGruNeg + cCodCli + cLojCli + cRegPAg + cMunPAg + cUFMPAg ) // Se passou parametros... montar a tela apenas para Consultar
	lConsulta := .t.
	aVars   := VA2200021_CarregaVariaveis( cGruNeg , cCodCli , cLojCli , cRegPAg , cMunPAg , cUFMPAg ) // Carrega variaveis para serem utilizadas nos Filtros dos Browse's
	cTitulo := aVars[1] // Titulo
	cSQLVJY := aVars[2] // Filtro SQL do Browse VJY
	cSQLVJZ := aVars[3] // Filtro SQL do Browse VJZ
	cSQLVK0 := aVars[4] // Filtro SQL do Browse VK0
	cSQLVK1 := aVars[5] // Filtro SQL do Browse VK1
	cSQLVK2 := aVars[6] // Filtro SQL do Browse VK2
EndIf

cCadastro := cTitulo // Titulo PADRÃO da Tela 

oVEIA220 := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],cTitulo,,,,128,,,,,.t.)

	oWorkArea := FWUIWorkArea():New( oVEIA220 )
	oWorkArea:CreateHorizontalBox( "LINE01", 32 , .f. )
	oWorkArea:SetBoxCols( "LINE01", { "OBJVJY" } )
	oWorkArea:CreateHorizontalBox( "LINE02", 32 , .f. )
	oWorkArea:SetBoxCols( "LINE02", { "OBJVJZ" , "OBJVK0" } )
	oWorkArea:CreateHorizontalBox( "LINE03", 32 , .f. )
	oWorkArea:SetBoxCols( "LINE03", { "OBJVK1" , "OBJVK2" } )
	oWorkArea:Activate()

	oBrwVJY := FWMBrowse():New()
	oBrwVJY:SetAlias('VJY')
	oBrwVJY:SetOwner(oWorkarea:GetPanel("OBJVJY"))
	oBrwVJY:SetDescription(cTitulo)
	If lConsulta // Apenas Consulta - Faz filtro das Propriedades Agricolas
		oBrwVJY:AddFilter(cTitulo,"@ "+cSQLVJY,.t.,.t.)
		oBrwVJY:SetMenuDef("VEIA221") // deixar somente a opcao de Imprimir Dados das Prop.Agricolas
	EndIf
	oBrwVJY:ForceQuitButton()
	oBrwVJY:DisableDetails()
	oBrwVJY:Activate()

	oBrwVJZ := FWMBrowse():New()
	oBrwVJZ:SetAlias('VJZ')
	oBrwVJZ:SetOwner(oWorkarea:GetPanel("OBJVJZ"))
	oBrwVJZ:SetDescription(STR0002) // Clientes
	If lConsulta .and. lAllReg // Apenas Consulta - Mostra todos os registros de todas as Propriedades Agricolas filtradas no Browse
		oBrwVJZ:AddFilter(STR0009,"@ "+cSQLVJZ,.t.,.t.) // Todos Clientes
	EndIf
	oBrwVJZ:DisableDetails()
	oBrwVJZ:SetAmbiente(.F.)
	oBrwVJZ:SetWalkthru(.F.)
	oBrwVJZ:SetUseFilter()
	oBrwVJZ:SetMenuDef("")
	oBrwVJZ:Activate()
	If !lConsulta .or. !lAllReg // Mostra apenas os registros relacionados com a Propriedade Agricola posicionada no Browse
		oRelacVJZ:= FWBrwRelation():New() 
		oRelacVJZ:AddRelation( oBrwVJY , oBrwVJZ , { { "VJZ_FILIAL" , "VJY_FILIAL" }, { "VJZ_PROAGR" , "VJY_CODIGO" } }) 
		oRelacVJZ:Activate()
	EndIf

	oBrwVK0 := FWMBrowse():New()
	oBrwVK0:SetAlias('VK0')
	oBrwVK0:SetOwner(oWorkarea:GetPanel("OBJVK0"))
	oBrwVK0:SetDescription(STR0003) // Atividades
	If lConsulta .and. lAllReg // Apenas Consulta - Mostra todos os registros de todas as Propriedades Agricolas filtradas no Browse
		oBrwVK0:AddFilter(STR0010,"@ "+cSQLVK0,.t.,.t.) // Todas Atividades
	EndIf
	oBrwVK0:DisableDetails()
	oBrwVK0:SetAmbiente(.F.)
	oBrwVK0:SetWalkthru(.F.)
	oBrwVK0:SetUseFilter()
	oBrwVK0:SetMenuDef("")
	oBrwVK0:Activate()
	If !lConsulta .or. !lAllReg // Mostra apenas os registros relacionados com a Propriedade Agricola posicionada no Browse
		oRelacVK0:= FWBrwRelation():New() 
		oRelacVK0:AddRelation( oBrwVJY , oBrwVK0 , { { "VK0_FILIAL" , "VJY_FILIAL" }, { "VK0_PROAGR" , "VJY_CODIGO" } }) 
		oRelacVK0:Activate()
	EndIf

	oBrwVK1 := FWMBrowse():New()
	oBrwVK1:SetAlias('VK1')
	oBrwVK1:SetOwner(oWorkarea:GetPanel("OBJVK1"))
	oBrwVK1:SetDescription(STR0004) // Culturas
	If lConsulta .and. lAllReg // Apenas Consulta - Mostra todos os registros de todas as Propriedades Agricolas filtradas no Browse
		oBrwVK1:AddFilter(STR0011,"@ "+cSQLVK1,.t.,.t.) // Todas Culturas
	EndIf
	oBrwVK1:DisableDetails()
	oBrwVK1:SetAmbiente(.F.)
	oBrwVK1:SetWalkthru(.F.)
	oBrwVK1:SetUseFilter()
	oBrwVK1:SetMenuDef("")
	oBrwVK1:Activate()
	If !lConsulta .or. !lAllReg // Mostra apenas os registros relacionados com a Propriedade Agricola posicionada no Browse
		oRelacVK1:= FWBrwRelation():New() 
		oRelacVK1:AddRelation( oBrwVJY , oBrwVK1 , { { "VK1_FILIAL" , "VJY_FILIAL" }, { "VK1_PROAGR" , "VJY_CODIGO" } }) 
		oRelacVK1:Activate()
	EndIf

	oBrwVK2 := FWMBrowse():New()
	oBrwVK2:SetAlias('VK2')
	oBrwVK2:SetOwner(oWorkarea:GetPanel("OBJVK2"))
	oBrwVK2:SetDescription(STR0005) // Pecuaria
	If lConsulta .and. lAllReg // Apenas Consulta - Mostra todos os registros de todas as Propriedades Agricolas filtradas no Browse
		oBrwVK2:AddFilter(STR0012,"@ "+cSQLVK2,.t.,.t.) // Todas Pecuaria
	EndIf
	oBrwVK2:DisableDetails()
	oBrwVK2:SetAmbiente(.F.)
	oBrwVK2:SetWalkthru(.F.)
	oBrwVK2:SetUseFilter()
	oBrwVK2:SetMenuDef("")
	oBrwVK2:Activate()
	If !lConsulta .or. !lAllReg // Mostra apenas os registros relacionados com a Propriedade Agricola posicionada no Browse
		oRelacVK2:= FWBrwRelation():New() 
		oRelacVK2:AddRelation( oBrwVJY , oBrwVK2 , { { "VK2_FILIAL" , "VJY_FILIAL" }, { "VK2_PROAGR" , "VJY_CODIGO" } }) 
		oRelacVK2:Activate()
	EndIf

oVEIA220:Activate()

Return

/*/{Protheus.doc} VA2200021_CarregaVariaveis
	Carrega variaveis para serem utilizadas nos Filtros dos Browse's para a Consulta

	@author Andre Luis Almeida
	@since 08/01/2021
/*/
Static Function VA2200021_CarregaVariaveis( cGruNeg , cCodCli , cLojCli , cRegPAg , cMunPAg , cUFMPAg )

Local cTitulo   := ""
Local cProAgr   := ""
Local cSQLVJY   := ""
Local cSQLVJZ   := ""
Local cSQLVK0   := ""
Local cSQLVK1   := ""
Local cSQLVK2   := ""
Local cQuery    := ""
Local cQAlVJZ   := "SQLVJZ"

Do Case

	Case !Empty(cGruNeg) // Filtrar todas as Propriedades Agricolas de um Grupo de Negocios com varios Clientes
		cTitulo := STR0013+": "+cGruNeg+" - " // Propr.Agricolas do Grupo de Negocio
		cTitulo += left(FM_SQL("SELECT VJW_DESCRI FROM "+RetSQLName("VJW")+" WHERE VJW_FILIAL='"+xFilial("VJW")+"' AND VJW_CODIGO='"+cGruNeg+"' AND D_E_L_E_T_=' '"),30)
		cQuery := "SELECT DISTINCT VJZ.VJZ_PROAGR "
		cQuery += "  FROM " + RetSqlName("VJX")+" VJX "
		cQuery += "  JOIN " + RetSqlName("VJZ")+" VJZ ON VJZ.VJZ_FILIAL='"+xFilial("VJZ")+"' AND VJZ.VJZ_CODCLI=VJX.VJX_CODCLI AND VJZ.VJZ_LOJCLI=VJX.VJX_LOJCLI AND VJZ.D_E_L_E_T_=' '"
		cQuery += " WHERE VJX.VJX_FILIAL ='" + xFilial("VJX") + "'"
		cQuery += "   AND VJX.VJX_GRUNEG ='" + cGruNeg + "'"
		cQuery += "   AND VJX.D_E_L_E_T_=' '"

	Case !Empty(cCodCli) // Filtrar todas as Propriedades Agricolas de um determinado Cliente
		cTitulo := STR0014+": "+cCodCli // Propr.Agricolas do Cliente
		If !Empty(cLojCli)
			cTitulo += "-"+cLojCli+" "
			cTitulo += left(FM_SQL("SELECT A1_NOME FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+cCodCli+"' AND A1_LOJA='"+cLojCli+"' AND D_E_L_E_T_=' '"),30)
		EndIf
		cQuery := "SELECT DISTINCT VJZ_PROAGR "
		cQuery += "  FROM " + RetSqlName("VJZ")
		cQuery += " WHERE VJZ_FILIAL ='" + xFilial("VJZ") + "'"
		cQuery += "   AND VJZ_CODCLI ='" + cCodCli + "'"
		If !Empty(cLojCli)
			cQuery += "   AND VJZ_LOJCLI ='" + cLojCli + "'"
		EndIf
		cQuery += "   AND D_E_L_E_T_=' '"

	Case !Empty(cRegPAg)
		cTitulo := STR0015+": "+Alltrim(cRegPAg)+" - " // Prop.Agricolas da Região
		cTitulo += Alltrim(left(FM_SQL("SELECT X5_DESCRI FROM "+RetSQLName("SX5")+" WHERE X5_FILIAL='"+xFilial("SX5")+"' AND X5_TABELA='A2' AND X5_CHAVE='"+cRegPAg+"' AND D_E_L_E_T_=' '"),30))
		cSQLVJY := "VJY_REGIAO = '"+cRegPAg+"'"
		cSQLVJZ := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VJZ_PROAGR AND VJY.VJY_REGIAO='"+cRegPAg+"' AND VJY.D_E_L_E_T_=' ' ) "
		cSQLVK0 := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VK0_PROAGR AND VJY.VJY_REGIAO='"+cRegPAg+"' AND VJY.D_E_L_E_T_=' ' ) "
		cSQLVK1 := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VK1_PROAGR AND VJY.VJY_REGIAO='"+cRegPAg+"' AND VJY.D_E_L_E_T_=' ' ) "
		cSQLVK2 := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VK2_PROAGR AND VJY.VJY_REGIAO='"+cRegPAg+"' AND VJY.D_E_L_E_T_=' ' ) "

	Case !Empty(cMunPAg)
		VAM->(DbSetOrder(1))
		VAM->(Dbseek(xFilial("VAM")+cMunPAg))
		cTitulo := STR0016+" - "+Alltrim(left(VAM->VAM_DESCID,30))+" - "+VAM->VAM_ESTADO // Propr.Agricolas
		cSQLVJY := "VJY_IBGE = '"+cMunPAg+"'"
		cSQLVJZ := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VJZ_PROAGR AND VJY.VJY_IBGE='"+cMunPAg+"' AND VJY.D_E_L_E_T_=' ' ) "
		cSQLVK0 := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VK0_PROAGR AND VJY.VJY_IBGE='"+cMunPAg+"' AND VJY.D_E_L_E_T_=' ' ) "
		cSQLVK1 := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VK1_PROAGR AND VJY.VJY_IBGE='"+cMunPAg+"' AND VJY.D_E_L_E_T_=' ' ) "
		cSQLVK2 := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VK2_PROAGR AND VJY.VJY_IBGE='"+cMunPAg+"' AND VJY.D_E_L_E_T_=' ' ) "
	
	Case !Empty(cUFMPAg)
		cTitulo := STR0016+" - "+cUFMPAg // Propr.Agricolas
		cSQLVJY := "EXISTS ( SELECT VAM.VAM_IBGE FROM " + RetSqlName("VAM") + " VAM WHERE VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND VAM.VAM_IBGE=VJY_IBGE AND VAM.VAM_ESTADO='"+cUFMPAg+"' AND VAM.D_E_L_E_T_=' ' ) "
		cSQLVJZ := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY JOIN " + RetSqlName("VAM") + " VAM ON VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND VAM.VAM_IBGE=VJY.VJY_IBGE AND VAM.D_E_L_E_T_=' ' WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VJZ_PROAGR AND VAM.VAM_ESTADO='"+cUFMPAg+"' AND VJY.D_E_L_E_T_=' ' ) "
		cSQLVK0 := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY JOIN " + RetSqlName("VAM") + " VAM ON VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND VAM.VAM_IBGE=VJY.VJY_IBGE AND VAM.D_E_L_E_T_=' ' WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VK0_PROAGR AND VAM.VAM_ESTADO='"+cUFMPAg+"' AND VJY.D_E_L_E_T_=' ' ) "
		cSQLVK1 := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY JOIN " + RetSqlName("VAM") + " VAM ON VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND VAM.VAM_IBGE=VJY.VJY_IBGE AND VAM.D_E_L_E_T_=' ' WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VK1_PROAGR AND VAM.VAM_ESTADO='"+cUFMPAg+"' AND VJY.D_E_L_E_T_=' ' ) "
		cSQLVK2 := "EXISTS ( SELECT VJY.VJY_CODIGO FROM " + RetSqlName("VJY") + " VJY JOIN " + RetSqlName("VAM") + " VAM ON VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND VAM.VAM_IBGE=VJY.VJY_IBGE AND VAM.D_E_L_E_T_=' ' WHERE VJY.VJY_FILIAL='"+xFilial("VJY")+"' AND VJY.VJY_CODIGO=VK2_PROAGR AND VAM.VAM_ESTADO='"+cUFMPAg+"' AND VJY.D_E_L_E_T_=' ' ) "

EndCase

If !Empty(cQuery) // Executa a Query somente quando for por Grupo de Negocio ou Cliente/Loja
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVJZ, .F., .T. )
	While !((cQAlVJZ)->(Eof()))
		cProAgr += "'"+(cQAlVJZ)->VJZ_PROAGR + "',"
		(cQAlVJZ)->(dbSkip())
	End
	(cQAlVJZ)->(dbCloseArea())
	DbSelectArea("VJY")
	If !Empty(cProAgr)
		cProAgr := left(cProAgr,len(cProAgr)-1)
	Else
		cProAgr += "'ZZZZZZZZZZZ'" // Não trazer registros na Consulta
	EndIf
	cSQLVJY := "VJY_CODIGO IN (" + cProAgr + ")"
	cSQLVJZ := "VJZ_PROAGR IN (" + cProAgr + ")"
	cSQLVK0 := "VK0_PROAGR IN (" + cProAgr + ")"
	cSQLVK1 := "VK1_PROAGR IN (" + cProAgr + ")"
	cSQLVK2 := "VK2_PROAGR IN (" + cProAgr + ")"
EndIf

Return { cTitulo , cSQLVJY , cSQLVJZ , cSQLVK0 , cSQLVK1 , cSQLVK2 }