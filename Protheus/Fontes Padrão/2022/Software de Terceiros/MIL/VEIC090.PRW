#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIC090.CH"

/*/{Protheus.doc} VEIC090
	Consulta Frota de Clientes

	@author Andre Luis Almeida
	@since 11/01/2021
/*/
Function VEIC090( lAllReg , cGruNeg , cCodCli , cLojCli , cRegCli , cMunCli , cUFMCli )

Private lVC3SEGMOD := ( VC3->(ColumnPos("VC3_SEGMOD")) > 0 )
Default lAllReg := .f. // .t. Mostra todos os registros de todas os Clientes filtrados no Browse / .f. Mostra apenas os registros relacionados com o Cliente posicionado no Browse
Default cGruNeg := "" // Grupo de Negocios
Default cCodCli := "" // Codigo do Cliente
Default cLojCli := "" // Loja do Cliente
Default cRegCli := "" // Regiao do Cliente
Default cMunCli := "" // Codigo do IBGE do Municipio do Cliente
Default cUFMCli := "" // UF do Municipio do Cliente

Processa( {|| VC0900011_TelaBrowsers( lAllReg , cGruNeg , cCodCli , cLojCli , cRegCli , cMunCli , cUFMCli ) } , STR0003 , "", .T.) // Processando / Monta Tela com todos os Browses

Return

/*/{Protheus.doc} VC0900011_TelaBrowsers
	Monta tela com todos os Browses

	@author Andre Luis Almeida
	@since 22/01/2021
/*/
Static Function VC0900011_TelaBrowsers( lAllReg , cGruNeg , cCodCli , cLojCli , cRegCli , cMunCli , cUFMCli )
Local oVEIC090
Local oWorkarea
Local aSize     := FWGetDialogSize( oMainWnd )
Local cTitulo   := STR0002 // Clientes
Local cSQLSA1   := ""
Local cSQLVC3   := ""
Local cSQLVK3   := ""
Local aVars     := {}
Local aRotina   := {}
Local aColDef   := {}
Local aColVC3   := {}
Local aColVK3   := {}
Local cCpoNAO   := ""
Local nCntFor   := 0

ProcRegua(0)
IncProc(STR0004) // Levantando Dados...

If !Empty( cGruNeg + cCodCli + cLojCli + cRegCli + cMunCli + cUFMCli ) // Se passou parametros... montar a tela com Filtros

	aVars := VC0900021_CarregaVariaveis( cGruNeg , cCodCli , cLojCli , cRegCli , cMunCli , cUFMCli ) // Carrega variaveis para serem utilizadas nos Filtros dos Browse's
	cTitulo := aVars[1] // Titulo que vem da funcao
	cSQLSA1 := aVars[2] // SQL de SA1 - Clientes a serem filtrados no browse
	cSQLVC3 := aVars[3] // SQL de VC3 - Frotas a serem filtradas no browse
	cSQLVK3 := aVars[4] // SQL de VK3 - Frotas a serem filtradas no browse

EndIf

cCadastro := cTitulo

oVEIC090 := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],(STR0001+" - "+cTitulo),,,,128,,,,,.t.) // Frotas

	oWorkArea := FWUIWorkArea():New( oVEIC090 )
	oWorkArea:CreateHorizontalBox( "LINE01", 40 , .f. )
	oWorkArea:SetBoxCols( "LINE01", { "OBJSA1" , "OBJVK3" } )
	oWorkArea:CreateHorizontalBox( "LINE02", 55 , .f. )
	oWorkArea:SetBoxCols( "LINE02", { "OBJVC3" } )
	oWorkArea:Activate()

	oBrwSA1 := FWMBrowse():New()
	oBrwSA1:SetAlias('SA1')
	oBrwSA1:SetOwner(oWorkarea:GetPanel("OBJSA1"))
	oBrwSA1:SetDescription(cTitulo)
	If !Empty(cSQLSA1)
		oBrwSA1:AddFilter(cTitulo,"@ "+cSQLSA1,.t.,.t.)
	EndIf
	oBrwSA1:SetMenuDef("") // Apenas Consultar - SEM MENU
	oBrwSA1:ForceQuitButton()
	oBrwSA1:DisableDetails()
	oBrwSA1:Activate()

	oBrwVC3 := FWMBrowse():New()
	oBrwVC3:SetAlias('VC3')
	oBrwVC3:SetOwner(oWorkarea:GetPanel("OBJVC3"))
	If lAllReg .and. !Empty(cSQLVC3) // Mostra todos os registros de todos os Clientes filtrados no Browse
		cCpoNAO := "VC3_NOMCLI/"
		oBrwVC3:SetDescription(STR0005) // Frota dos Clientes filtrados
		oBrwVC3:AddFilter(STR0007,"@ "+cSQLVC3,.t.,.t.) // Frotas Agrupadas
	Else
		cCpoNAO := "VC3_CODCLI/VC3_LOJA/VC3_NOMCLI/"
		oBrwVC3:SetDescription(STR0006) // Frota do Cliente posicionado
	EndIf
	aColDef := oBrwVC3:LoadColumns()
	For nCntFor := 1 To Len(aColDef)
		If !Alltrim(aColDef[nCntFor,12])+"/" $ cCpoNAO
			AAdd(aColVC3,aColDef[nCntFor,12]) // Retirar o Nome do Cliente no Browse filho para nao dar problema no browse do SA1
		EndIf
	Next
	oBrwVC3:SetOnlyFields( aColVC3 )
	oBrwVC3:DisableDetails()
	oBrwVC3:ForceQuitButton()
	oBrwVC3:AddLegend(" VC0900031_CorBrowseFrota() == '0' " , "BR_PRETO"    , STR0008 ) // Não pertence mais ao Cliente
	oBrwVC3:AddLegend(" VC0900031_CorBrowseFrota() == '1' " , "BR_BRANCO"   , STR0009 ) // Não possui o cadastro de média de anos para troca
	oBrwVC3:AddLegend(" VC0900031_CorBrowseFrota() == '2' " , "BR_VERDE"    , STR0010 ) // Dentro do prazo de troca em relação a aquisição
	oBrwVC3:AddLegend(" VC0900031_CorBrowseFrota() == '3' " , "BR_AMARELO"  , STR0011 ) // Vencendo este ano o prazo de troca em relação a aquisição
	oBrwVC3:AddLegend(" VC0900031_CorBrowseFrota() == '4' " , "BR_VERMELHO" , STR0012 ) // Estourou o prazo de troca em relação a aquisição
	oBrwVC3:SetAmbiente(.F.)
	oBrwVC3:SetWalkthru(.F.)
	oBrwVC3:SetUseFilter()
	oBrwVC3:SetMenuDef("")
	oBrwVC3:Activate()
	If !lAllReg .or. Empty(cSQLVC3) // Mostra apenas os registros relacionados com o Cliente posicionado no Browse
		oRelacVC3:= FWBrwRelation():New() 
		oRelacVC3:AddRelation( oBrwSA1 , oBrwVC3 , { { "VC3_FILIAL" , "xFilial('VC3')" }, { "VC3_CODCLI" , "A1_COD" }, { "VC3_LOJA" , "A1_LOJA" } }) 
		oRelacVC3:Activate()
	EndIf

	oBrwVK3 := FWMBrowse():New()
	oBrwVK3:SetAlias('VK3')
	oBrwVK3:SetOwner(oWorkarea:GetPanel("OBJVK3"))
	If lAllReg .and. !Empty(cSQLVK3) // Mostra todos os registros de todos os Clientes filtrados no Browse
		cCpoNAO := "VK3_NOMCLI/"
		oBrwVK3:SetDescription(STR0013) // Troca de Frota dos Clientes filtrados
		oBrwVK3:AddFilter(STR0015,"@ "+cSQLVK3,.t.,.t.) // Troca de Frotas Agrupadas
	Else
		cCpoNAO := "VK3_CODCLI/VK3_LOJCLI/VK3_NOMCLI/"
		oBrwVK3:SetDescription(STR0014) // Troca de Frota do Cliente posicionado
	EndIf
	aColDef := oBrwVK3:LoadColumns()
	For nCntFor := 1 To Len(aColDef)
		If !Alltrim(aColDef[nCntFor,12])+"/" $ cCpoNAO
			AAdd(aColVK3,aColDef[nCntFor,12]) // Retirar o Nome do Cliente no Browse filho para nao dar problema no browse do SA1
		EndIf
	Next
	oBrwVK3:SetOnlyFields( aColVK3 )
	oBrwVK3:DisableDetails()
	oBrwVK3:ForceQuitButton()
	oBrwVK3:SetAmbiente(.F.)
	oBrwVK3:SetWalkthru(.F.)
	oBrwVK3:SetUseFilter()
	oBrwVK3:SetMenuDef("")
	oBrwVK3:Activate()
	If !lAllReg .or. Empty(cSQLVK3) // Mostra apenas os registros relacionados com o Cliente posicionado no Browse
		oRelacVK3:= FWBrwRelation():New() 
		oRelacVK3:AddRelation( oBrwSA1 , oBrwVK3 , { { "VK3_FILIAL" , "xFilial('VK3')" }, { "VK3_CODCLI" , "A1_COD" }, { "VK3_LOJCLI" , "A1_LOJA" } }) 
		oRelacVK3:Activate()
	EndIf

oVEIC090:Activate()

Return

/*/{Protheus.doc} VC0900021_CarregaVariaveis
	Carrega variaveis para serem utilizadas nos Filtros dos Browse's para as Consultas de Frotas e Troca de Frota

	@author Andre Luis Almeida
	@since 22/01/2021
/*/
Static Function VC0900021_CarregaVariaveis( cGruNeg , cCodCli , cLojCli , cRegCli , cMunCli , cUFMCli )

Local cTitulo   := ""
Local cSQLSA1   := "" // Query Retorno SA1
Local cSQLVC3   := "" // Query Retorno VC3
Local cSQLVK3   := "" // Query Retorno VK3
Local cQuery    := ""
Local cQAlVJX   := "SQLVJX"
Local nTotCli   := 0

Do Case

	Case !Empty(cGruNeg) // Filtrar todos os Clientes/Lojas de um Grupo de Negocios
		cTitulo := STR0016+": "+cGruNeg+" - " // Clientes do Grupo de Negocio
		cTitulo += left(FM_SQL("SELECT VJW_DESCRI FROM "+RetSQLName("VJW")+" WHERE VJW_FILIAL='"+xFilial("VJW")+"' AND VJW_CODIGO='"+cGruNeg+"' AND D_E_L_E_T_=' '"),30)
		cQuery := "SELECT DISTINCT VJX_CODCLI , VJX_LOJCLI "
		cQuery += "  FROM " + RetSqlName("VJX")
		cQuery += " WHERE VJX_FILIAL ='" + xFilial("VJX") + "'"
		cQuery += "   AND VJX_GRUNEG ='" + cGruNeg + "'"
		cQuery += "   AND D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVJX, .F., .T. )
		While !((cQAlVJX)->(Eof()))
			cSQLSA1 += "( A1_COD='"+(cQAlVJX)->VJX_CODCLI+"' AND "+"A1_LOJA='"+(cQAlVJX)->VJX_LOJCLI+"' ) OR "
			cSQLVC3 += "( VC3_CODCLI='"+(cQAlVJX)->VJX_CODCLI+"' AND VC3_LOJA='"+(cQAlVJX)->VJX_LOJCLI+"' ) OR "
			cSQLVK3 += "( VK3_CODCLI='"+(cQAlVJX)->VJX_CODCLI+"' AND VK3_LOJCLI='"+(cQAlVJX)->VJX_LOJCLI+"' ) OR "
			(cQAlVJX)->(dbSkip())
		End
		(cQAlVJX)->(dbCloseArea())
		DbSelectArea("SA1")
		If !Empty(cSQLSA1)
			cSQLSA1 := " ( "+left(cSQLSA1,len(cSQLSA1)-4)+" )"
			cSQLVC3 := " ( "+left(cSQLVC3,len(cSQLVC3)-4)+" )"
			cSQLVK3 := " ( "+left(cSQLVK3,len(cSQLVK3)-4)+" )"
		Else
			cSQLSA1 := "A1_COD='ZZZZZZZZZZZZ'" // Não trazer registros na Consulta
			cSQLVC3 := "VC3_CODCLI='ZZZZZZZZZZZZ'" // Não trazer registros na Consulta
			cSQLVK3 := "VK3_CODCLI='ZZZZZZZZZZZZ'" // Não trazer registros na Consulta
		EndIf

	Case !Empty(cCodCli) // Filtrar todas as Propriedades Agricolas de um determinado Cliente
		cTitulo := STR0017+": "+cCodCli // Cliente
		If !Empty(cLojCli)
			cTitulo += "-"+cLojCli+" "
			cTitulo += left(FM_SQL("SELECT A1_NOME FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+cCodCli+"' AND A1_LOJA='"+cLojCli+"' AND D_E_L_E_T_=' '"),30)
		Else
			nTotCli := FM_SQL("SELECT COUNT(*) FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+cCodCli+"' AND D_E_L_E_T_=' '")
			cTitulo += " ( "+Alltrim(str(nTotCli))+" "+STR0019+" )" // loja(s)
		EndIf
		cSQLSA1 := "A1_COD='"+cCodCli+"'"
		cSQLVC3 := "VC3_CODCLI='"+cCodCli+"'"
		cSQLVK3 := "VK3_CODCLI='"+cCodCli+"'"
		If !Empty(cLojCli)
			cSQLSA1 += " AND A1_LOJA='"+cLojCli+"'"
			cSQLVC3 += " AND VC3_LOJA='"+cLojCli+"'"
			cSQLVK3 += " AND VK3_LOJCLI='"+cLojCli+"'"
		EndIf
	
	Case !Empty(cRegCli)
		cTitulo := STR0018+": "+Alltrim(cRegCli)+" - " // Clientes da Regiao
		cTitulo += Alltrim(left(FM_SQL("SELECT X5_DESCRI FROM "+RetSQLName("SX5")+" WHERE X5_FILIAL='"+xFilial("SX5")+"' AND X5_TABELA='A2' AND X5_CHAVE='"+cRegCli+"' AND D_E_L_E_T_=' '"),30))
		cSQLSA1 := "A1_REGIAO='"+cRegCli+"'"
		cSQLVC3 := "EXISTS ( SELECT SA1.A1_COD FROM " + RetSqlName("SA1") + " SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VC3_CODCLI AND SA1.A1_LOJA=VC3_LOJA AND SA1.A1_REGIAO='"+cRegCli+"' AND SA1.D_E_L_E_T_=' ' ) "
		cSQLVK3 := "EXISTS ( SELECT SA1.A1_COD FROM " + RetSqlName("SA1") + " SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VK3_CODCLI AND SA1.A1_LOJA=VK3_LOJCLI AND SA1.A1_REGIAO='"+cRegCli+"' AND SA1.D_E_L_E_T_=' ' ) "

	Case !Empty(cMunCli)
		VAM->(DbSetOrder(1))
		VAM->(Dbseek(xFilial("VAM")+cMunCli))
		cTitulo := STR0002+" - "+Alltrim(left(VAM->VAM_DESCID,30))+" - "+VAM->VAM_ESTADO // Clientes 
		cSQLSA1 := "A1_IBGE='"+cMunCli+"'"
		cSQLVC3 := "EXISTS ( SELECT SA1.A1_COD FROM " + RetSqlName("SA1") + " SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VC3_CODCLI AND SA1.A1_LOJA=VC3_LOJA AND SA1.A1_IBGE='"+cMunCli+"' AND SA1.D_E_L_E_T_=' ' ) "
		cSQLVK3 := "EXISTS ( SELECT SA1.A1_COD FROM " + RetSqlName("SA1") + " SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VK3_CODCLI AND SA1.A1_LOJA=VK3_LOJCLI AND SA1.A1_IBGE='"+cMunCli+"' AND SA1.D_E_L_E_T_=' ' ) "
	
	Case !Empty(cUFMCli)
		cTitulo := STR0002+" - "+cUFMCli // Clientes
		cSQLSA1 := "A1_EST='"+cUFMCli+"'"
		cSQLVC3 := "EXISTS ( SELECT SA1.A1_COD FROM " + RetSqlName("SA1") + " SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VC3_CODCLI AND SA1.A1_LOJA=VC3_LOJA AND SA1.A1_EST='"+cUFMCli+"' AND SA1.D_E_L_E_T_=' ' ) "
		cSQLVK3 := "EXISTS ( SELECT SA1.A1_COD FROM " + RetSqlName("SA1") + " SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VK3_CODCLI AND SA1.A1_LOJA=VK3_LOJCLI AND SA1.A1_EST='"+cUFMCli+"' AND SA1.D_E_L_E_T_=' ' ) "

EndCase

Return { cTitulo , cSQLSA1 , cSQLVC3 , cSQLVK3 }

/*/{Protheus.doc} VC0900031_CorBrowseFrota
	Monta as cores no Browse das Frotas em relação ao cadastro de Troca de Frota do Cliente

	@author Andre Luis Almeida
	@since 22/01/2021
/*/
Function VC0900031_CorBrowseFrota()
Local cRetCor   := "0" // Preto - Não pertence mais ao cliente
Local nQtdAnos  := 0
Local nAnoAtual := 0
Local nAnoAquis := 0
Local cQuery    := ""
If Empty(VC3->VC3_DATVEN)
	cRetCor := "1" // Branco - Não possui o cadastro de média de anos para troca
	FGX_VV2( VC3->VC3_CODMAR , VC3->VC3_MODVEI , IIF( lVC3SEGMOD , VC3->VC3_SEGMOD , "" ) )
	cQuery := "SELECT VK3_QTDANO "
	cQuery += "  FROM " + RetSqlName("VK3")
	cQuery += " WHERE VK3_FILIAL ='" + xFilial("VK3") + "'"
	cQuery += "   AND VK3_CODCLI ='" + VC3->VC3_CODCLI + "'"
	cQuery += "   AND VK3_LOJCLI ='" + VC3->VC3_LOJA   + "'"
	cQuery += "   AND VK3_CODMAR ='" + VC3->VC3_CODMAR + "'"
	cQuery += "   AND VK3_GRUMOD ='" + VV2->VV2_GRUMOD + "'"
	cQuery += "   AND D_E_L_E_T_=' '"
	nQtdAnos := FM_SQL(cQuery)
	If nQtdAnos > 0
		nAnoAtual := year(dDataBase)
		nAnoAquis := year(VC3->VC3_DATAQU)
		If nAnoAtual == ( nAnoAquis+nQtdAnos )
			cRetCor := "3" // Amarelo - Vencendo este ano o prazo de troca em relação a aquisição
		ElseIf nAnoAtual < ( nAnoAquis+nQtdAnos )
			cRetCor := "2" // Verde - Dentro do prazo de troca em relação a aquisição
		Else
			cRetCor := "4" // Vermelho - Estourou o prazo de troca em relação a aquisição
		EndIf
	EndIf
EndIf
Return cRetCor