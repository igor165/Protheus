#INCLUDE "JURA148.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CAMPOS_TABELA    1
#DEFINE CAMPOS_ADICIONAR 2
#DEFINE CAMPOS_REMOVER   3
#DEFINE CAMPOS_ORDEM     4

Static aParticip := {}  // Vetor com a soma do parcentual das participações para validar com a originação
Static lAltClien := .F. // Indica se o usuário solicitou a réplica de informações para os contratos e pagadores (JA148ALTCT)
Static aDados    := {}  // Array com as informações alteradas para réplica de informações para os contratos e pagadores (JA148ALTCT)

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA148
Clientes.

@author David Gonçalves Fernandes
@since 30/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA148()
Local oBrowse     := Nil

Private A1_USADDA := ""
Private AGETS

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0007) // "Clientes"
	oBrowse:SetAlias("SA1")
	oBrowse:SetLocate()
	JurSetLeg(oBrowse, "SA1")
	JurSetBSize(oBrowse)
	J148Filter(oBrowse) // Adiciona fitros padrões no browse

	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J148Filter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges / Cristina Cintra
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J148Filter(oBrowse)
Local aFilSA11 := {}
Local aFilSA12 := {}
Local aFilSA13 := {}
Local aFilSA14 := {}
Local aFilSA15 := {}

	SAddFilPar("A1_DTCAD", ">=", "%A1_DTCAD0%", @aFilSA11)
	oBrowse:AddFilter(STR0104, 'A1_DTCAD >= "%A1_DTCAD0%"', .F., .F., , .T., aFilSA11, STR0104) // "Data Maior ou Igual a"

	SAddFilPar("A1_DTCAD", "<=", "%A1_DTCAD0%", @aFilSA12)
	oBrowse:AddFilter(STR0105, 'A1_DTCAD <= "%A1_DTCAD0%"', .F., .F., , .T., aFilSA12, STR0105) // "Data Menor ou Igual a"

	SAddFilPar("A1_MSBLQL", "==", "%A1_MSBLQL0%", @aFilSA13)
	oBrowse:AddFilter(STR0106, 'A1_MSBLQL == "%A1_MSBLQL0%"', .F., .F., , .T., aFilSA13, STR0106) // "Situação"

	SAddFilPar("A1_COD", "$", "%A1_COD0%", @aFilSA14)
	oBrowse:AddFilter(STR0107, 'ALLTRIM(UPPER("%A1_COD0%")) $ A1_COD', .F., .F., , .T., aFilSA14, STR0107) // "Código do cliente"

	SAddFilPar("A1_NOME", "$", "%A1_NOME0%", @aFilSA15)
	oBrowse:AddFilter(STR0108, 'ALLTRIM(UPPER("%A1_NOME0%")) $ A1_NOME', .F., .F., , .T., aFilSA15, STR0108) // "Nome do cliente"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author David Gonçalves Fernandes
@since 30/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina   := {}
Local aUserButt := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA148", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA148", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA148", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA148", 0, 5, 0, NIL } ) // "Excluir"

// Ponto de entrada para acrescentar botões no menu
If ExistBlock( 'JURA148' ) // Mesmo ID do Modelo de Dados
	aUserButt := ExecBlock( 'JURA148', .F., .F., { NIL, "MENUDEF", 'JURA148' } )
	If ValType( aUserButt ) == 'A'
		aEval( aUserButt, { |aX| aAdd( aRotina, aX ) } )
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Clientes

@author David Gonçalves Fernandes
@since 30/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel( "JURA148" )
Local lUsaHist     := SuperGetMV( 'MV_JURHS1',, .F. )
Local lHstPartic   := SuperGetMV( 'MV_JURHS3',, .F. )
Local oStructSA1   := NIL
Local oStructNUH   := NIL
Local oStructNUB   := NIL
Local oStructNUC   := NIL
Local oStructNUA   := NIL
Local oStructNU9   := NIL
Local oStructNUD   := NIL
Local oStructAC8   := NIL
Local oStructNZB   := NIL
Local oStructOHO   := Nil
Local aCampos      := {}
Local lJA148FLDS   := ExistBlock('JA148FLDS')
Local nX           := 0
Local nY           := 0
Local nZ           := 0
Local nPos         := 0
Local aX           := {}
Local aCampsSA1    := {}
Local aCampsNUH    := {}
Local lIntegrPFS   := SuperGetMV("MV_JFTJURI",, "2" ) == "1"//Se a integração estiver Habilitada 
Local lJ148Sheet   := ExistBlock("J148Sheet")
Local cParam       := AllTrim( SuperGetMv('MV_JDOCUME',, '1'))

If lIntegrPFS .Or. nModulo == 77
	oStructSA1   := FWFormStruct( 2, "SA1" ) //Clientes
	oStructNUH   := FWFormStruct( 2, "NUH" ) //Dados Cliente - Jurídico
	oStructNUB   := FWFormStruct( 2, "NUB" ) //Ativ. Não cobráveis
	oStructNUC   := FWFormStruct( 2, "NUC" ) //Desp. Não cobráveis
	oStructNUA   := FWFormStruct( 2, "NUA" ) //Relatórios
	oStructNU9   := FWFormStruct( 2, "NU9" ) //Participação do cliente
	oStructNUD   := FWFormStruct( 2, "NUD" ) //Hist. Participação Cliente
	oStructAC8   := FWFormStruct( 2, "AC8" ) //Contatos
	oStructNZB   := FWFormStruct( 2, "NZB" ) //Tipos de Serviços Correspondentes
	oStructOHO   := FWFormStruct( 2, "OHO" ) //Exceção de Valor por Tipo de Atividade
Else
	aCampsSA1    := J148JurCSA1()
	aCampsNUH    := J148JurCNUH()
	oStructSA1   := FWFormStruct( 2, 'SA1', { | cCampo | cAux := cCampo, aScan( aCampsSA1, { |x| Alltrim(cAux) == x } ) > 0 } )
	oStructNUH   := FWFormStruct( 2, "NUH", { | cCampo | aScan(aCampsNUH, Alltrim(cCampo)) > 0 } ) //Dados Cliente - Jurídico
EndIf

If lIntegrPFS .Or. nModulo == 77
	oStructNUH:RemoveField("NUH_COD")
	oStructNUH:RemoveField("NUH_LOJA")
	oStructNUH:RemoveField("NUH_CPART")
	oStructNUB:RemoveField("NUB_CCLIEN")
	oStructNUB:RemoveField("NUB_CLOJA")
	oStructNUC:RemoveField("NUC_CCLIEN")
	oStructNUC:RemoveField("NUC_CLOJA")
	oStructNUA:RemoveField("NUA_CCLIEN")
	oStructNUA:RemoveField("NUA_CLOJA")
	oStructNU9:RemoveField("NU9_COD")
	oStructNU9:RemoveField("NU9_CCLIEN")
	oStructNU9:RemoveField("NU9_CLOJA")
	oStructNU9:RemoveField("NU9_CPART")
	If lHstPartic
		oStructNUD:RemoveField("NUD_CPARTI")
		oStructNUD:RemoveField("NUD_CCLIEN")
		oStructNUD:RemoveField("NUD_CLOJA")
		oStructNUD:RemoveField("NUD_CPART")
		oStructNUD:RemoveField("NUD_COD")
	EndIf
	oStructAC8:RemoveField( "AC8_ENTIDA" )
	oStructAC8:RemoveField( "AC8_CODENT" )
	oStructNZB:RemoveField( "NZB_CCLIEN" )
	oStructNZB:RemoveField( "NZB_LCLIEN" )
	oStructOHO:RemoveField( "OHO_CCLIEN" )
	oStructOHO:RemoveField( "OHO_CLOJA" )
	oStructOHO:RemoveField( "OHO_COD" )
EndIf

If NUH->(FieldPos("NUH_CODLD")) > 0
	oStructNUH:RemoveField('NUH_CODLD')
EndIf

If NUH->(FieldPos("NUH_SRCCOD")) > 0
	oStructNUH:RemoveField('NUH_SRCCOD')
EndIf

JurSetAgrp( 'SA1',, oStructSA1 )
JurSetAgrp( 'NUH',, oStructNUH )

//--------------------------------------------------------------------
//PE - Manipulacao dos campos
//--------------------------------------------------------------------
If lJA148FLDS .And. (lIntegrPFS .Or. nModulo == 77)

	aCampos := ExecBlock('JA148FLDS', .F., .F.)

	If ValType( aCampos ) == 'A'

		For nX := 1 To Len( aCampos )
			For nY := Len( aCampos[nX] ) + 1 To 4
				aAdd( aCampos[nX], {} )
			Next

			If aCampos[nX][2] == NIL
				aCampos[nX][2]  := {}
			ElseIf aCampos[nX][3] == NIL
				aCampos[nX][3]  := {}
			ElseIf aCampos[nX][4] == NIL
				aCampos[nX][4]  := {}
			EndIf

		Next
		
		aStructs := { ;
		{ 'SA1', oStructSA1, 'SA1MASTER' },;
		{ 'NUH', oStructNUH, 'NUHMASTER' },;
		{ 'NUB', oStructNUB, 'NUBDETAIL' },;
		{ 'NUC', oStructNUC, 'NUCDETAIL' },;
		{ 'NUA', oStructNUA, 'NUADETAIL' },;
		{ 'NU9', oStructNU9, 'NU9DETAIL' },;
		{ 'NUD', oStructNUD, 'NUDDETAIL' },;
		{ 'AC8', oStructAC8, 'AC8DETAIL' },;
		{ 'NZB', oStructNZB, 'NZBDETAIL' },;
		{ 'OHO', oStructOHO, 'OHODETAIL' }}
		
		For nZ := 1 To Len( aStructs )

			If ( nPos := aScan( aCampos, { |aX| aX[CAMPOS_TABELA] == aStructs[nZ][1] } ) ) > 0

				//Adiciona Campos
				If Len( aCampos[nPos][CAMPOS_ADICIONAR] ) > 0

					aRelation := oModel:GetModel( aStructs[nZ][3] ):GetRelation()

					For nX := 1 To Len( aCampos[nPos][CAMPOS_ADICIONAR] )

						If !aStructs[nZ][2]:HasField( aCampos[nPos][CAMPOS_ADICIONAR][nX] )

							AddCampo( 2, aCampos[nPos][CAMPOS_ADICIONAR][nX], aStructs[nZ][2] )

							If aScan( aRelation[1], { |aX| aX[1] == aCampos[nPos][CAMPOS_ADICIONAR][nX] } ) > 0
								aStructs[nZ][2]:SetProperty( aCampos[nPos][CAMPOS_ADICIONAR][nX], MVC_VIEW_CANCHANGE , .F. )
							EndIf

						EndIf

					Next

				EndIf

				//Remove Campos
				For nX := 1 To Len( aCampos[nPos][CAMPOS_REMOVER] )
					If aStructs[nZ][2]:HasField( aCampos[nPos][CAMPOS_REMOVER][nX] )
						aStructs[nZ][2]:RemoveFields( aCampos[nPos][CAMPOS_REMOVER][nX] )
					EndIf
				Next

				// Ordem
				For nX := 1 To Len( aCampos[nPos][CAMPOS_ORDEM] )
					aStructs[nZ][2]:SetOrder( aCampos[nPos][CAMPOS_ORDEM][nX][1], aCampos[nPos][CAMPOS_ORDEM][nX][2] )
				Next

			EndIf

		Next

	Else

		aCampos := {}

	EndIf

EndIf

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA148_SA1", oStructSA1, "SA1MASTER"  )
oView:AddField( "JURA148_NUH", oStructNUH, "NUHMASTER"  )

If lIntegrPFS .Or. nModulo == 77
	oView:AddGrid( "JURA148_NUB", oStructNUB, "NUBDETAIL"  ) //Ativ. Não cobráveis
	oView:AddGrid( "JURA148_NUC", oStructNUC, "NUCDETAIL"  ) //Desp. Não cobráveis
	oView:AddGrid( "JURA148_NUA", oStructNUA, "NUADETAIL"  ) //Relatórios não utilizados
	oView:AddGrid( "JURA148_NU9", oStructNU9, "NU9DETAIL"  ) //Participação do cliente
	If lHstPartic .And. lUsaHist
		oView:AddGrid( "JURA148_NUD", oStructNUD, "NUDDETAIL"  ) //Hist. Participação Cliente
	EndIf
	oView:AddGrid( "JURA148_AC8", oStructAC8, "AC8DETAIL"  ) //"Dados de Relacionamento Entidade x Contato"
	oView:AddGrid( "JURA148_NZB", oStructNZB, "NZBDETAIL"  ) //Tipos de Serviços Correspondentes
	oView:AddGrid( "JURA148_OHO", oStructOHO, "OHODETAIL"  ) //Exceção de valor por Tipo de Atividade
EndIf

oView:CreateFolder("FOLDER_01")
oView:AddSheet("FOLDER_01", "ABA_01_01", STR0010 )  //"Clientes"

If lIntegrPFS .Or. nModulo == 77
	oView:AddSheet("FOLDER_01", "ABA_01_02", STR0011 )  //"Atividades não cobráveis"
	oView:AddSheet("FOLDER_01", "ABA_01_03", STR0012 )  //"Despesas não cobráveis"
	oView:AddSheet("FOLDER_01", "ABA_01_04", STR0013 )  //Relatórios não utilizados"
	oView:AddSheet("FOLDER_01", "ABA_01_05", STR0014 )  //"Participação do cliente" // + Histórico da participação
	oView:AddSheet("FOLDER_01", "ABA_01_06", STR0080 )  //"Contatos"
	oView:AddSheet("FOLDER_01", "ABA_01_07", STR0081 )  //"Tipos de Serviços Correspondentes"
	oView:AddSheet("FOLDER_01", "ABA_01_08", STR0093 ) //Exceção de valor hora por Tipo de Atividade
EndIf

oView:createHorizontalBox("SA1FIELDS", 40,,,"FOLDER_01","ABA_01_01")
oView:createHorizontalBox("HUHFIELDS", 60,,,"FOLDER_01","ABA_01_01")

If lIntegrPFS .Or. nModulo == 77
	oView:createHorizontalBox("NUBGRID", 100,,,"FOLDER_01","ABA_01_02" ) //Ativ. Não cobráveis
	oView:createHorizontalBox("NUCGRID", 100,,,"FOLDER_01","ABA_01_03" ) //Desp. Não cobráveis
	oView:createHorizontalBox("NUAGRID", 100,,,"FOLDER_01","ABA_01_04" ) //Relatórios não utilizados
	If lHstPartic .And. lUsaHist
		oView:createHorizontalBox("NU9GRID", 40,,,"FOLDER_01","ABA_01_05" ) //Participação do cliente
		oView:createHorizontalBox("NUDGRID", 60,,,"FOLDER_01","ABA_01_05" ) //Hist. Participação Cliente
	Else
		oView:createHorizontalBox("NU9GRID", 100,,,"FOLDER_01","ABA_01_05" ) //Participação do cliente
	EndIf
	oView:createHorizontalBox("AC8GRID", 100,,,"FOLDER_01","ABA_01_06" ) //"Dados de Relacionamento Entidade x Contato"
	oView:createHorizontalBox("NZBGRID", 100,,,"FOLDER_01","ABA_01_07" ) //"Tipos de Serviços Correspondentes"
	oView:CreateHorizontalBox("OHOGRID", 100,,, "FOLDER_01", "ABA_01_08" ) //Exceção de valor por Tipo de Atividade
EndIf

oView:SetOwnerView( "JURA148_SA1", "SA1FIELDS" )
oView:SetOwnerView( "JURA148_NUH", "HUHFIELDS" )

If lIntegrPFS .Or. nModulo == 77
	oView:SetOwnerView( "JURA148_NUB", "NUBGRID" )
	oView:SetOwnerView( "JURA148_NUC", "NUCGRID" )
	oView:SetOwnerView( "JURA148_NUA", "NUAGRID" )
	oView:SetOwnerView( "JURA148_NU9", "NU9GRID" )
	If lHstPartic .And. lUsaHist
		oView:SetOwnerView( "JURA148_NUD", "NUDGRID" )
	EndIf
	oView:SetOwnerView( "JURA148_AC8", "AC8GRID" )
	oView:SetOwnerView( "JURA148_NZB", "NZBGRID" )
	oView:SetOwnerView( "JURA148_OHO", "OHOGRID" )

	oView:SetCloseOnOk({||.F.})

Else
	oStructNUH:SetProperty("NUH_CIDIO", MVC_VIEW_TITULO, STR0096)
EndIf

// Ponto de entrada para criar uma nova aba no cadastro de clientes
If lJ148Sheet
	J148Sheet(@oModel, @oView)
EndIf

If !(cParam == '1' .And. IsPlugin())
	oView:AddUserButton( STR0101, "CLIPS", {| oView | JURANEXDOC("SA1", "SA1MASTER", "", "A1_COD", , , , , , "3", "A1_LOJA", , , .T.)}) //"Anexar"
EndIf

oView:SetDescription( STR0007 ) // "Clientes"
oView:EnableControlBar( .T. )

oView:EnableTitleView( "JURA148_NUH" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Clientes

@author David Gonçalves Fernandes
@since 30/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructSA1 := FWFormStruct( 1, "SA1" )
Local oStructNUH := FWFormStruct( 1, "NUH" )
Local oStructNUB := NIL
Local oStructNUC := NIL
Local oStructNUA := NIL
Local oStructNU9 := NIL
Local oStructNUD := NIL
Local oStructAC8 := NIL
Local oStructNZB := NIL
Local oStructOHO := Nil
Local lHstPartic := SuperGetMV( 'MV_JURHS3',, .T. )
Local oCommit    := JA148COMMIT():New()
Local lIntegrPFS := SuperGetMV("MV_JFTJURI",, "2" ) == "1"//Se a integração estiver Habilitada

If lIntegrPFS .Or. nModulo == 77
	oStructNUB := FWFormStruct( 1, "NUB" ) //Ativ. Não cobráveis
	oStructNUC := FWFormStruct( 1, "NUC" ) //Desp. Não cobráveis
	oStructNUA := FWFormStruct( 1, "NUA" ) //Relatórios
	oStructNU9 := FWFormStruct( 1, "NU9" ) //Participação do cliente
	oStructNUD := FWFormStruct( 1, "NUD" ) //Hist. Participação Cliente
	oStructAC8 := FWFormStruct( 1, "AC8", , .F. ) //Contatos
	oStructNZB := FWFormStruct( 1, "NZB" ) //"Tipos de Serviços Correspondentes"
	oStructOHO := FWFormStruct( 1, "OHO" ) //"Exceção de Valor por Tipo de Atividade"
EndIf

oStructNUH:RemoveField("NUH_COD")
oStructNUH:RemoveField("NUH_LOJA")

If lIntegrPFS .Or. nModulo == 77
	oStructNUB:RemoveField("NUB_CCLIEN")
	oStructNUB:RemoveField("NUB_CLOJA")
	oStructNUC:RemoveField("NUC_CCLIEN")
	oStructNUC:RemoveField("NUC_CLOJA")
	oStructNUA:RemoveField("NUA_CCLIEN")
	oStructNUA:RemoveField("NUA_CLOJA")
	oStructNU9:RemoveField("NU9_CCLIEN")
	oStructNU9:RemoveField("NU9_CLOJA")
	If lHstPartic
		oStructNUD:RemoveField("NUD_CCLIEN")
		oStructNUD:RemoveField("NUD_CLOJA")
	EndIf
	oStructNZB:RemoveField("NZB_CCLIEN")
	oStructNZB:RemoveField("NZB_LCLIEN")
	oStructOHO:RemoveField( "OHO_CCLIEN" )
	oStructOHO:RemoveField( "OHO_CLOJA" )
	oStructOHO:RemoveField( "OHO_COD" )

	// Isto faz com que sempre seja chamado o bLinePre do "AC8DETAIL".
	oStructAC8:SetProperty( 'AC8_CODCON', MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, '.T.' ) )
EndIf

oModel:= MPFormModel():New( "JURA148", { | oX | J148PREVAL( oStructSA1, oStructNUH ) }/*Pre-Validacao*/, { | oX | JA148TUDOK( oX ) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "SA1MASTER", NIL         /*cOwner*/, oStructSA1 , /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddFields( "NUHMASTER", "SA1MASTER" /*cOwner*/, oStructNUH , /*Pre-Validacao*/, /*Pos-Validacao*/ )

If lIntegrPFS .Or. nModulo == 77
	oModel:AddGrid( "NUBDETAIL" , "SA1MASTER"   /*cOwner*/, oStructNUB, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
	oModel:AddGrid( "NUCDETAIL" , "SA1MASTER"   /*cOwner*/, oStructNUC, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
	oModel:AddGrid( "NUADETAIL" , "SA1MASTER"   /*cOwner*/, oStructNUA, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
	oModel:AddGrid( "NU9DETAIL" , "SA1MASTER"   /*cOwner*/, oStructNU9, /*bLinePre*/, { |oGrid| Jur148LOk(oGrid, "NU9" ) } /*bLinePost*/, /*bPre*/, /*bPost*/ )
	If lHstPartic
		oModel:AddGrid( "NUDDETAIL" , "SA1MASTER" /*cOwner*/, oStructNUD, /*bLinePre*/, { |oGrid| Jur148LOk(oGrid, "NUD" ) }/*bLinePost*/, /*bPre*/, /*bPost*/, { |oGrid| LoadNUD( oGrid ) } )
	EndIf
	oModel:AddGrid( "AC8DETAIL" , "SA1MASTER"   /*cOwner*/, oStructAC8, { |oModelGrid, nLine, cAction, cField, xValue, xCurrentValue| JA148PREAC8(oModelGrid, nLine, cAction, cField, xValue, xCurrentValue)  } , { |oModelGrid, nLine| JA148POSAC8(oModelGrid, nLine) } /*bLinePost*/, /*bPre*/, /*bPost*/ )
	oModel:AddGrid( "NZBDETAIL" , "SA1MASTER"   /*cOwner*/, oStructNZB, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
	oModel:AddGrid( "OHODETAIL" , "SA1MASTER"   /*cOwner*/, oStructOHO, /*bLinePre*/, {|oGrid| JHistValid(oGrid, {"OHO_CATIVI"}) .And. J148ValNeg("OHO_VALOR", oGrid) } /*bLinePost*/, /*bPre*/, /*bPost*/ )
EndIf

oModel:SetRelation( "NUHMASTER"    , { { "NUH_FILIAL", "xFilial('NUH')" } , { "NUH_COD"   , "A1_COD" }, { "NUH_LOJA",  "A1_LOJA" } }, NUH->( IndexKey( 1 ) ) )
If lIntegrPFS .Or. nModulo == 77
	oModel:SetRelation( "NUBDETAIL"    , { { "NUB_FILIAL", "xFilial('NUB')" } , { "NUB_CCLIEN", "A1_COD" }, { "NUB_CLOJA", "A1_LOJA" } }, NUB->( IndexKey( 1 ) ) )
	oModel:SetRelation( "NUCDETAIL"    , { { "NUC_FILIAL", "xFilial('NUC')" } , { "NUC_CCLIEN", "A1_COD" }, { "NUC_CLOJA", "A1_LOJA" } }, NUC->( IndexKey( 1 ) ) )
	oModel:SetRelation( "NUADETAIL"    , { { "NUA_FILIAL", "xFilial('NUA')" } , { "NUA_CCLIEN", "A1_COD" }, { "NUA_CLOJA", "A1_LOJA" } }, NUA->( IndexKey( 1 ) ) )
	oModel:SetRelation( "NU9DETAIL"    , { { "NU9_FILIAL", "xFilial('NU9')" } , { "NU9_CCLIEN", "A1_COD" }, { "NU9_CLOJA", "A1_LOJA" } }, NU9->( IndexKey( 1 ) ) )
	If lHstPartic
		oModel:SetRelation( "NUDDETAIL", { { "NUD_FILIAL", "xFilial('NUD')" } , { "NUD_CCLIEN", "A1_COD" }, { "NUD_CLOJA", "A1_LOJA" } }, NUD->( IndexKey( 1 ) ) )
	EndIf
	oModel:SetRelation( "AC8DETAIL", { {"AC8_FILIAL", "XFILIAL('AC8')" }, {"AC8_FILENT", "xFilial('SA1')"}, {"AC8_ENTIDA", '"SA1"'}     , {"AC8_CODENT","PadR(SA1->(A1_COD+A1_LOJA), TamSX3('AC8_CODENT')[1] )" } }, 'AC8_CODENT' )
	oModel:SetRelation( "NZBDETAIL", { {"NZB_FILIAL", "xFilial('NZB')" }, {"NZB_CCLIEN", "A1_COD"        }, {"NZB_LCLIEN", "A1_LOJA" } }, NZB->( IndexKey( 1 ) ) )
	oModel:SetRelation( "OHODETAIL", { {"OHO_FILIAL", "xFilial('OHO')" }, {"OHO_CCLIEN", "A1_COD" }, {"OHO_CLOJA", "A1_LOJA"} }, OHO->( IndexKey( 1 ) ) )
EndIf

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Clientes"
oModel:GetModel( "SA1MASTER" ):SetDescription( STR0007 ) // "Clientes"
oModel:GetModel( "NUHMASTER" ):SetDescription( STR0009 ) // "Dados de Clientes"

If lIntegrPFS .Or. nModulo == 77
	oModel:GetModel( "NUBDETAIL" ):SetDescription( STR0011 ) // Ativ. Não cobráveis
	oModel:GetModel( "NUCDETAIL" ):SetDescription( STR0012 ) // Desp. Não cobráveis
	oModel:GetModel( "NUADETAIL" ):SetDescription( STR0013 ) // Relatórios
	oModel:GetModel( "NU9DETAIL" ):SetDescription( STR0014 ) // Participação do cliente
	If lHstPartic
		oModel:GetModel( "NUDDETAIL" ):SetDescription( STR0015 ) // "Hist. Participação do cliente"
	EndIf
	oModel:GetModel( "AC8DETAIL" ):SetDescription( STR0040 ) //Dados de Relacionamento Entidade x Contato
	oModel:GetModel( "NZBDETAIL" ):SetDescription( STR0081 ) //"Tipos de Serviços Correspondentes"
	oModel:GetModel( "OHODETAIL" ):SetDescription( STR0093 ) //"Exceção de valor hora por Tipo de Atividade"
	
	//para permitir que todas as linhas do grid sejam excluídas
	oModel:GetModel( "NUBDETAIL" ):SetDelAllLine( .T. )
	oModel:GetModel( "NUCDETAIL" ):SetDelAllLine( .T. )
	oModel:GetModel( "NUADETAIL" ):SetDelAllLine( .T. )
	oModel:GetModel( "NU9DETAIL" ):SetDelAllLine( .T. )
	If lHstPartic
		oModel:GetModel( "NUDDETAIL" ):SetDelAllLine( .T. )
	EndIf
	oModel:GetModel( "AC8DETAIL" ):SetDelAllLine( .T. )
	oModel:GetModel( "NZBDETAIL" ):SetDelAllLine( .T. )
	oModel:GetModel( "OHODETAIL" ):SetDelAllLine( .T. )

	oModel:GetModel( "NUBDETAIL" ):SetUniqueLine( { "NUB_CTPATI" } )
	oModel:GetModel( "NUCDETAIL" ):SetUniqueLine( { "NUC_CTPDES" } )
	oModel:GetModel( "NUADETAIL" ):SetUniqueLine( { "NUA_CTPREL" } )
	oModel:GetModel( "NU9DETAIL" ):SetUniqueLine( { "NU9_CPART", "NU9_CTIPO" } )
	If lHstPartic
		oModel:GetModel( "NUDDETAIL" ):SetUniqueLine( { "NUD_CPART", "NUD_CTPORI", "NUD_AMINI" } )
	EndIf
	oModel:GetModel( "AC8DETAIL" ):SetUniqueLine( { "AC8_CODCON" } )
	oModel:GetModel( "NZBDETAIL" ):SetUniqueLine( { "NZB_CTPSER" } )
	oModel:GetModel( "OHODETAIL" ):SetUniqueLine( { "OHO_AMINI", "OHO_CATIVI" } )
EndIf

JurSetRules( oModel, "SA1MASTER",, "SA1",, )
JurSetRules( oModel, "NUHMASTER",, "NUH",, )
If lIntegrPFS .Or. nModulo == 77
	JurSetRules( oModel, "NUBDETAIL",, "NUB",, )
	JurSetRules( oModel, "NUCDETAIL",, "NUC",, )
	JurSetRules( oModel, "NUADETAIL",, "NUA",, )
	JurSetRules( oModel, "NU9DETAIL",, "NU9",, )
	If lHstPartic
		JurSetRules( oModel, "NUDDETAIL",, "NUD",,  )
	EndIf
	JurSetRules( oModel, "NZBDETAIL",, "NZB",,)
	JurSetRules( oModel, "OHODETAIL",, "OHO",,)
	
	oModel:SetOptional("NUBDETAIL", .T.)
	oModel:SetOptional("NUCDETAIL", .T.)
	oModel:SetOptional("NUADETAIL", .T.)
	oModel:SetOptional("NU9DETAIL", .T.)
	If lHstPartic
		oModel:SetOptional("NUDDETAIL", .T.)
	EndIf
	oModel:SetOptional("AC8DETAIL", .T.)
	oModel:SetOptional("NZBDETAIL", .T.)
	oModel:SetOptional("OHODETAIL", .T.)
	
	If FWIsInCallStack( 'A30DELJUR' ) // Exclusao pela rotina MATA030 Cadastro de Cliente Financeiro
		oModel:SetOnlyQuery("SA1MASTER")
	EndIf

	oModel:InstallEvent("JA148COMMIT", /*cOwner*/, oCommit)
Else
	oStructNUH:SetProperty( 'NUH_CASAUT', MODEL_FIELD_INIT, {|| "1"} )
	oStructNUH:SetProperty("NUH_SIGLA",MODEL_FIELD_OBRIGAT,.T.)
	oStructNUH:SetProperty("NUH_CIDIO",MODEL_FIELD_OBRIGAT,.T.)
EndIf
oModel:SetActivate( { |oModel| JA148NUH( oModel ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J148FSinc
Faz a gravação do Cliente na Fila de Sincronização (NYS).

@param oModel - Modelo de dados de clientes

@author Cristina Cintra
@since 23/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J148FSinc(oModel)
Local nOpc     := oModel:GetOperation()
Local cCliente := oModel:GetValue("SA1MASTER", "A1_COD")
Local cLoja    := oModel:GetValue("SA1MASTER", "A1_LOJA")

	J170GRAVA(oModel, xFilial('SA1') + cCliente + cLoja)

	If nOpc == MODEL_OPERATION_DELETE .And. FindFunction("JExcAnxSinc")
		JExcAnxSinc("SA1", cCliente + cLoja) // Exclui os anexos vinculados ao cliente e registra na fila de sincronização
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } JURA148CM
Executa rotinas após o commit das alterações no Modelo

@author David Gonçalves Fernandes
@since 17/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA148CM( oModel, cTabHonOld, lUpdGrp )
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaSA1 := SA1->( GetArea() )
Local aAreaNUH := NUH->( GetArea() )

NVE->(DbSetOrder(1))

Begin Transaction
	If oModel:GetOperation() == 4
		If lUpdGrp
			JA148UPDGR( oModel, "NVE", "NVE_CGRPCL", "NVE_CCLIEN", "NVE_LCLIEN" )
			JA148UPDGR( oModel, "NT0", "NT0_CGRPCL", "NT0_CCLIEN", "NT0_CLOJA" )
			JA148UPDGR( oModel, "NVV", "NVV_CGRUPO", "NVV_CCLIEN", "NVV_CLOJA" )
			JA148UPDGR( oModel, "NWF", "NWF_CGRPCL", "NWF_CCLIEN", "NWF_CLOJA" )
			JA148UPDGR( oModel, "NVY", "NVY_CGRUPO", "NVY_CCLIEN", "NVY_CLOJA" )
			JA148UPDGR( oModel, "NV4", "NV4_CGRUPO", "NV4_CCLIEN", "NV4_CLOJA" )
			JA148UPDGR( oModel, "NXA", "NXA_CGRPCL", "NXA_CCLIEN", "NXA_CLOJA" )
			JA148UPDGR( oModel, "NX0", "NX0_CGRUPO", "NX0_CCLIEN", "NX0_CLOJA" )
			JA148UPDGR( oModel, "NUE", "NUE_CGRPCL", "NUE_CCLIEN", "NUE_CLOJA" )
			JA148UPDGR( oModel, "NW2", "NW2_CGRUPO", "NW2_CCLIEN", "NW2_CLOJA" )
			lUpdGrp := .F.
		EndIf

		If !Empty(cTabHonOld) .And. NVE->(DbSeek(xFilial("NVE") + NUH->NUH_COD + NUH->NUH_LOJA))
			If ApMsgYesNo(STR0058 + " '" + Alltrim(cTabHonOld) + "' " + STR0059 + " '" + Alltrim(oModel:GetValue("NUHMASTER", "NUH_CTABH")) + "' ?" + CRLF + STR0060 ) // "Deseja alterar todos os casos definidos com a tabela XXX para YYY"  / "Atenção: A alteração não será refletida em pré-faturas pendentes destes casos!"
				MsgRun(STR0061, , {|| lRet := JA148Caso(oModel, cTabHonOld)} ) // "Atualizando casos"
			EndIf
			cTabHonOld := ""
		EndIf
	EndIf
End Transaction

RestArea( aAreaNUH )
RestArea( aAreaSA1 )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } AvaliaPre
Avalia as informações do model antes de aplicar as alterações

@author David Gonçalves Fernandes
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AvaliaPre(oModel, cModelId, cAlias, lNewRecord, cTabHonOld, lUpdGrp)
Local nX         := 0
Local oModelNUH  := oModel:GetModel('NUHMASTER')
Local aFields    := oModelNUH:GetStruct():GetFields()
Local POSIDCAMPO := 3
Local POSVIRTUAL := 14

aDados := {} // Necessário zerar o array para não acumular dados de execuções anteriores
lAltClien := .F. //Necessário alterar o valor de alteração de clientes

If cAlias == "NUH" .And. !lNewRecord
	For nX := 1 To Len(aFields)
		//Precisa ver se o campo é virtual
		If FieldGet(  FieldPos( aFields[nX][ POSIDCAMPO ] ) ) != oModelNUH:GetValue( aFields[nX][ POSIDCAMPO ] ) .AND. !aFields[nX][ POSVIRTUAL ]
			aAdd( aDados, { aFields[nX][POSIDCAMPO], FieldGet( FieldPos( aFields[nX][ POSIDCAMPO ] ) ), oModelNUH:GetValue( aFields[nX][ POSIDCAMPO ]) } )
		EndIf
	Next nX
EndIf

If oModelNUH:GetValue("NUH_CTABH") <> NUH->NUH_CTABH
	cTabHonOld := NUH->NUH_CTABH
EndIf

If oModel:GetValue("SA1MASTER", "A1_GRPVEN") <> SA1->A1_GRPVEN
	lUpdGrp := .T.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AvaliaPos
Avalia as informações do model após aplicar as alterações

@author David Gonçalves Fernandes
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AvaliaPos(oModel, cModelId, cAlias, lNewRecord)

If cAlias == "NUH"
	JA148ALTCT()
EndIf

Return

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA148TUDOK
Executa as de validação antes de confirmar as alterações do Model

@author David Gonçalves Fernandes
@since 07/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA148TUDOK(oModel)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaSA1   := SA1->(GetArea())
Local oModelNUD  := Nil
Local lHstPartic := SuperGetMV('MV_JURHS3',, .F.) // Utilizar o historico para participacoes de cliente / casos
Local cLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local cSolucao   := ""
Local lIntPfsJur := SuperGetMV("MV_JFTJURI",, "2" ) == "1" //Se a integração estiver Habilitada 
Local nOperation := oModel:GetOperation()
Local lIsRest    := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))

If lIntPfsJur .Or. nModulo == 77
	oModelNUD  := oModel:GetModel("NUDDETAIL")
	//<-- Valida a aba de contato de instancias -->
	If !J148VConta(oModel)
		lRet := .F.
	EndIf
EndIf
If ( nOperation == 3 .Or. nOperation == 4 )

	//Validação para verificar se a flag "Cria Caso" esta como 2(Não) e a flag "Caso Automático" esta como 1 (sim)
	If oModel:GetValue("NUHMASTER", "NUH_AJNV") == '2' .AND. oModel:GetValue("NUHMASTER", "NUH_CASAUT") == '1'
		//Atenção: "Atenção: Se o campo " +  Alltrim(RetTitle('NUH_CASAUT')) +" estiver como 'Sim', será necessário que o campo "+ RetTitle('NUH_AJNV') + " também esteja preenchido como 'Sim'" )// "Realize o Ajuste Necessário"
		lRet := JurMsgErro(STR0070 + Alltrim(RetTitle('NUH_CASAUT')) + STR0071 + Alltrim(RetTitle('NUH_AJNV')) + STR0072,, STR0097)
	EndIf

	//Validação para verificar se o Pefil de Cliente como "Somente Pagador" e a flag "Caso Automático" esta como 1 (sim)
	If lRet .And. oModel:GetValue("NUHMASTER", "NUH_PERFIL") == '2' .And. lIntPfsJur
		If oModel:GetValue("NUHMASTER", "NUH_CASAUT") == '1'
			// "Atenção: Se o cliente estiver com " +Alltrim(RetTitle('NUH_PERFIL'))+ " Somente Pagador não poderá está com o campo "+Alltrim(RetTitle('NUH_CASAUT'))+" como 'Sim' "// "Realize o Ajuste Necessário"
			lRet := JurMsgErro(STR0077 + Alltrim(RetTitle('NUH_PERFIL')) + STR0078 + Alltrim(RetTitle('NUH_CASAUT')) + STR0079,, STR0097)
		EndIf

		If lRet .And. oModel:GetValue("NUHMASTER", "NUH_AJNV") == '1'
			// "Atenção: Se o cliente estiver com " +Alltrim(RetTitle('NUH_PERFIL'))+ " Somente Pagador não poderá está com o campo "+Alltrim(RetTitle('NUH_AJNV'))+" como 'Sim' "// "Realize o Ajuste Necessário"
			lRet := JurMsgErro(STR0077 + Alltrim(RetTitle('NUH_PERFIL')) + STR0078 + Alltrim(RetTitle('NUH_AJNV')) + STR0079,, STR0097)
		EndIf
	EndIf

	If(lRet .And. cLojaAuto == "1" .And. oModel:GetValue("NUHMASTER", "NUH_CASAUT") == '1';
	        .And. oModel:GetValue("SA1MASTER", "A1_LOJA") <> JurGetLjAt())

		cSolucao := I18N(STR0087,{Alltrim(RetTitle('NUH_CASAUT'))}) //"1) Altere o campo '#1' para  'Não'"
		//"Informe o valor '#1' no campo '#2'"
		cSolucao += Iif(nOperation == 3, + CRLF + "2) " + I18N(STR0086, {JurGetLjAt(), Alltrim(RetTitle('A1_LOJA'))}), "")

		// "Atenção: Se o parâmetro MV_JLOJAUT está ativo e o cliente estiver com o campo '#1' como 'Sim', não poderá ter um valor no campo '#2' diferente de '#3'"
		lRet := JurMsgErro( I18N(STR0085, {Alltrim(RetTitle('NUH_CASAUT')), Alltrim(RetTitle('A1_LOJA')), JurGetLjAt()}), "JA148TUDOK", cSolucao)

	EndIf
	If lIntPfsJur .Or. nModulo == 77
		If lRet .And. lHstPartic
			lRet := JURPerHist(oModelNUD, .F., {"NUD_CTPORI", "NUD_SIGLA"})
		EndIf
	
		If lRet .And. JA148VCAD(oModel)  .And.; // Valida os dados do caso
		              JA148DADOS(oModel) .And.; // Ajuste os dados do cadastro automaticamente
		              JA148ATIV(oModel)  .And.; // Copia as atividades com padrão não cobrar cliente
		              JA148DESP(oModel)  .And.; // Copia as despesas com padrão não cobrar cliente
		              JA148VPART(oModel) .And.; // Valida perctual das participações, participações obrigatórias
		              IIF(lHstPartic .And. J148ExHist(oModel), J148VLPER(oModel) .And. J148HTNUD(oModel), .T.) .And.; // Preenche Histórico da Participação
		              IIF(lIntPfsJur, JA148Cont(), .T.)
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf

	// Verificação de integração com o Fluig
	If lRet .And. (SuperGetMV('MV_JFLUIGA',, '2') == '1')
		lRet := J148VldFlg(oModel)
	EndIf

	//Validação de e-billing
	If lRet .And. (lIntPfsJur .Or. nModulo == 77)
		lRet := JA148VEBIL()
	EndIf

	If lRet .And. nOperation == 3 .And. lIsRest .And. NUH->(FieldPos( "NUH_CODLD" )) > 0 .And. FindFunction("JurMsgCdLD")
		lRet := JurMsgCdLD(oModel:GetValue("NUHMASTER", "NUH_CODLD"))
	EndIf

EndIf

RestArea( aAreaSA1 )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148VCAD
Valida as informações do cadastro de cliente antes da confirmação do cadastro

@param  oModel, Objeto com as regras de negócio da tela

@return lRet  , .T./.F. As informações são válidas ou não

@author David Gonçalves Fernandes
@since 07/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA148VCAD(oModel)
Local lRet       := .T.
Local oModelSA1  := oModel:GetModel("SA1MASTER")
Local oModelNUH  := oModel:GetModel("NUHMASTER")
Local cQuery     := ''
Local aArea      := GetArea()
Local lIntegraJu := SuperGetMV('MV_JFTJURI',, "2") == '1'
Local lJurxFin   := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local aRet       := {}
Local lBanco     := .F.
Local lAgencia   := .F.
Local lConta     := .F.

	// Verifica se o cliente é Definitivo e Potencial
	// "NUH_SITCAD" -> 1=Provisorio;2=Definitivo
	// "NUH_SITCLI" -> 1=Potencial;2=Efetivo
	If lRet .And. oModelNUH:GetValue("NUH_SITCAD") == '2' .And. oModelNUH:GetValue("NUH_SITCLI") == '1'
		lRet := JurMsgErro(STR0017,, STR0097) // Um cliente Parcial não pode ter caso definitivo // "Realize o Ajuste Necessário"
	ElseIf lRet .And. oModelNUH:GetValue("NUH_SITCAD") == '1' .And. NVE->(ColumnPos("NVE_SITCAD")) > 0
		//Valida se existem casos definitivos
		cQuery := "SELECT 1 TOTNVE"
		cQuery +=  " FROM " + RetSqlName("NVE") + " NVE"
		cQuery += " WHERE NVE.NVE_FILIAL  = '" + xFilial("NVE") + "'"
		cQuery +=   " AND NVE.NVE_CCLIEN = '" + oModelSA1:GetValue("A1_COD") + "'"
		cQuery +=   " AND NVE.NVE_LCLIEN = '" + oModelSA1:GetValue("A1_LOJA") + "'"
		cQuery +=   " AND NVE.NVE_SITCAD = '2'"
	
		aRet := JurSql(cQuery, {"TOTNVE"})
		If Len(aRet) > 0 .And. !Empty(aRet[1][1])
			lRet := JurMsgErro(STR0100,, STR0097) // "Não é possível alterar a situação do cadastro, pois existem casos definitivos vinculados a este cliente."// "Realize o Ajuste Necessário"
		EndIf
	EndIf

	If lIntegraJu
		// Verifica se o cliente é Definitivo e a tabela de honorários está preenchida
		If lRet .And. oModelNUH:GetValue("NUH_SITCAD") == '2' .And. Empty(oModelNUH:GetValue("NUH_CTABH"))
			lRet := JurMsgErro(STR0044,, STR0097) // "A tabela de honorários deve ser preenchida se a situação do cliente for 'Definitivo'"// "Realize o Ajuste Necessário"
		EndIf

		// Verifica se o cliente é Definitivo e o escritório está preenchido
		If lRet .And. oModelNUH:GetValue("NUH_SITCAD") == '2' .And. Empty(oModelNUH:GetValue("NUH_CESCR2"))
			lRet := JurMsgErro(STR0019,, STR0097) // "O Escritório de Faturamento deve ser preenchido se a situação do cliente for 'Definitivo'"// "Realize o Ajuste Necessário"
		EndIf

		If lRet .And. oModelNUH:GetValue("NUH_SITCAD") == '2' .And. Empty(oModelNUH:GetValue("NUH_CMOE"))
			lRet := JurMsgErro(STR0064,, STR0097) // "O Código da Moeda deve ser preenchido se a situação do cliente for 'Definitivo'"// "Realize o Ajuste Necessário"
		EndIf

		If lRet .And. oModelNUH:GetValue("NUH_SITCAD") == '2' .And. Empty(oModelNUH:GetValue("NUH_CIDIO"))
			lRet := JurMsgErro(STR0065,, STR0097) // "O Código do Idioma do Relatório deve ser preenchido se a situação do cliente for 'Definitivo'"// "Realize o Ajuste Necessário"
		EndIf

		If lRet .And. oModelNUH:GetValue("NUH_SITCAD") == '2' .And. Empty(oModelNUH:GetValue("NUH_CIDIO2"))
			lRet := JurMsgErro(STR0066,, STR0097) // "O Código do Idioma da Carta de Cobrança deve ser preenchido se a situação do cliente for 'Definitivo'"// "Realize o Ajuste Necessário"
		EndIf

		If lRet .And. oModelNUH:GetValue("NUH_SITCAD") == '2' .And. Empty(oModelNUH:GetValue("NUH_CRELAT"))
			lRet := JurMsgErro(STR0067,, STR0097) // "O Código do Relatório deve ser preenchido se a situação do cliente for 'Definitivo'"// "Realize o Ajuste Necessário"
		EndIf

		// Verifica se o cliente é Definitivo e o modelo da carta de cobrança não está preenchido
		If lRet .And. oModelNUH:GetValue("NUH_SITCAD") == '2' .And. Empty(oModelNUH:GetValue("NUH_CCARTA"))
			lRet := JurMsgErro(STR0039,, STR0097) // "O campo de modelo da carta deve ser preenchido se a situação do cliente for 'Definitivo'"// "Realize o Ajuste Necessário"
		EndIf

		// Validação preenchimento NUH_SIGLA/NUH_CPART
		If lRet
			If Empty(oModelNUH:GetValue("NUH_CPART"))
				lRet := JurMsgErro(I18N( STR0069, {RetTitle("NUH_SIGLA")} ),, STR0092 ) // "O campo '#1' não foi preenchido." -- "É necessário preencher o campo citado acima."
			Endif
		Endif

		If lRet
			lBanco   := !Empty(oModelNUH:GetValue("NUH_CBANCO")) // Indica se o banco está preenchido
			lAgencia := !Empty(oModelNUH:GetValue("NUH_CAGENC")) // Indica se a agência está preenchida
			lConta   := !Empty(oModelNUH:GetValue("NUH_CCONTA")) // Indica se a conta está preenchida

			// Verifica se o cliente é Definitivo e o os dados da conta não estão preenchidos
			If oModelNUH:GetValue("NUH_SITCAD") == '2' .And. (!lBanco .Or. !lAgencia .Or. !lConta)
				lRet := JurMsgErro(STR0020,, STR0097) // "Os dados de Banco, Agência e Conta devem ser preenchidos se a situação do cliente for 'Definitivo'"// "Realize o Ajuste Necessário"
			EndIf

			If lRet .And. lJurxFin .And. (lBanco .Or. lAgencia .Or. lConta)
				lRet := JurVldSA6('3') // Validação de banco
			EndIf
		EndIf
	EndIf

	// Verifica se há Contratos definitivos para cliente provisório
	If lRet .And. oModelNUH:GetValue("NUH_SITCAD") == '1'
		cQuery := " SELECT 1 TOTNT0 "
		cQuery +=   " FROM " + RetSqlName("NT0") + " NT0 "
		cQuery +=  " WHERE NT0.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND NT0.NT0_FILIAL = '" + xFilial( "NT0" ) + "' "
		cQuery +=    " AND NT0.NT0_CCLIEN = '" + oModel:GetValue("SA1MASTER", "A1_COD") + "' "
		cQuery +=    " AND NT0.NT0_CLOJA  = '" + oModel:GetValue("SA1MASTER", "A1_LOJA") + "' "
		cQuery +=    " AND NT0.NT0_SIT = '2' "

		aRet := JurSql(cQuery, {"TOTNT0"})
		If Len(aRet) > 0 .AND. !Empty(aRet[1][1])
			lRet := JurMsgErro(STR0018,, STR0097) // Não é possível alterar a situação do cliente para 'Provisório' pois exitem contratos definitivos// "Realize o Ajuste Necessário"
		EndIf
	EndIf

	If lRet .And. oModelNUH:GetValue("NUH_UTEBIL") == "1"

		If Empty(oModelNUH:GetValue("NUH_CEMP"))
			lRet := JurMsgErro(STR0043,, STR0097) // "O Código da Empresa de E-Billing deve ser preenchido!"// "Realize o Ajuste Necessário"
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA148DADOS
Valida as informações do cadastro de cliente antes da confirmação do cadastro

@Param  oModel	 	objeto com as regras de negócio da tela
@Return lRet	 	  .T./.F. As informações são válidas ou não

@author David Gonçalves Fernandes
@since 07/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA148DADOS( oModel )
Local lRet       := .T.

// Seta a Data de Efetivação do Cliente
// "NUH_SITCAD" -> 1=Provisorio;2=Definitivo
// "NUH_SITCLI" -> 1=Potencial;2=Efetivo
If oModel:GetOperation() == 3 .OR. oModel:GetOperation() == 4
	If lRet .AND. oModel:GetValue("NUHMASTER", "NUH_SITCLI") == '2' .AND. Empty(oModel:GetValue("NUHMASTER", "NUH_DTEFT"))
		If !oModel:LoadValue("NUHMASTER", "NUH_DTEFT", Date() )
			lRet := JurMsgErro(STR0026,, STR0097) // Erro ao alterar a situação do cliente// "Realize o Ajuste Necessário"
		EndIf
	ElseIf lRet .AND. oModel:GetValue("NUHMASTER", "NUH_SITCLI") == '1'
		If !oModel:LoadValue("NUHMASTER", "NUH_DTEFT", cTod('') )
			lRet := JurMsgErro(STR0026,, STR0097) // Erro ao alterar a situação do cliente// "Realize o Ajuste Necessário"
		EndIf
	EndIf

	// Seta a Data de encerramento do Cliente
	If lRet .AND. oModel:GetValue("NUHMASTER", "NUH_ATIVO") == '2'
		If !oModel:LoadValue("NUHMASTER", "NUH_DTENC", Date() )
			lRet := JurMsgErro(STR0027,, STR0097) // Erro ao encerrar o Cliente// "Realize o Ajuste Necessário"
		EndIf
	ElseIf lRet .AND. oModel:GetValue("NUHMASTER", "NUH_ATIVO") == '1'
		If !oModel:LoadValue("NUHMASTER", "NUH_DTENC", cTod('') )
			lRet := JurMsgErro(STR0033,, STR0097) // "Erro ao reativar o cliente"// "Realize o Ajuste Necessário"
		EndIf
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA148ATIV
Copia os tipos de atividade padrão não cobráveis para o cliente

@Param  oModel	 	objeto com as regras de negócio da tela
@Return lRet	 	  .T./.F. As informações são válidas ou não

@author David Gonçalves Fernandes
@since 07/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA148ATIV( oModel )
Local lRet        := .T.
Local cQuery      := ''
Local cResQRY     := GetNextAlias()
Local aAreaSA1    := SA1->( GetArea() )
Local aAreaNUH    := NUH->( GetArea() )
Local aArea       := GetArea()
Local oModelNUB   := oModel:GetModel("NUBDETAIL") //Ativ. Não cobráveis
Local nPos        := 0
Local nI          := 0
Local nQtdNUB     := 0

If oModel:GetOperation() == 3 //Se for inclusão
	cQuery := " SELECT NRC.NRC_COD NRC_COD"
	cQuery +=   " FROM " + RetSqlName("NRC") + " NRC "
	cQuery +=  " WHERE NRC.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NRC.NRC_FILIAL = '" + xFilial('NRC') + "' "
	cQuery +=    " AND NRC.NRC_COBRAR = '2' "
	cQuery +=    " AND NRC.NRC_ATIVO  = '1' "

	cQuery := ChangeQuery(cQuery , .F.)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	dbGoTop()
	while !(cResQRY)->(EOF())

		nPos    := 0
		nQtdNUB := oModelNUB:GetQtdLine()
		For nI := 1 To nQtdNUB
			If oModelNUB:GetValue("NUB_CTPATI", nI) == (cResQRY)->NRC_COD
				nPos := nI
			EndIf
		Next

		If nPos > 0
			oModelNUB:GoLine( nPos )
			If oModelNUB:IsDeleted()
				oModelNUB:UnDeleteLine()
			EndIf
		Else
			If nQtdNUB == 1 .And. Empty(oModelNUB:GetValue("NUB_CTPATI"))
				oModelNUB:GoLine( 1 )
			Else
				oModelNUB:AddLine()
			EndIf
			If !( oModelNUB:LoadValue( "NUB_CTPATI", (cResQRY)->NRC_COD ) )
				lRet := JurMsgErro(STR0021,, STR0097) //"Erro ao incluir atividades não cobráveis para o cliente"// "Realize o Ajuste Necessário"
			EndIf
		EndIf

		(cResQRY)->( dbSkip() )
	End

	dbSelectArea(cResQRY)
	(cResQRY)->(DbCloseArea())

EndIf

RestArea( aAreaNUH )
RestArea( aAreaSA1 )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA148DESP
Copia os tipos de atividade padrão não cobráveis para o cliente

@Param  oModel	 	objeto com as regras de negócio da tela
@Return lRet	 	  .T./.F. As informações são válidas ou não

@author David Gonçalves Fernandes
@since 07/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA148DESP( oModel )
Local lRet        := .T.
Local cQuery      := ''
Local cResQRY     := GetNextAlias()
Local aAreaSA1    := SA1->( GetArea() )
Local aAreaNUH    := NUH->( GetArea() )
Local aArea       := GetArea()
Local oModelNUC   := oModel:GetModel("NUCDETAIL") //Ativ. Não cobráveis
Local nPos        := 0
Local nI          := 0
Local nQtdNUC     := 0

If oModel:GetOperation() == 3 //Se for inclusão
	cQuery := " SELECT NRH.NRH_COD NRH_COD "
	cQuery +=   " FROM " + RetSqlName("NRH") + " NRH "
	cQuery +=  " WHERE NRH.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NRH.NRH_FILIAL = '" + xFilial('NRH') + "' "
	cQuery +=    " AND NRH.NRH_COBRAR = '2' "
	cQuery +=    " AND NRH.NRH_ATIVO  = '1' "

	cQuery := ChangeQuery(cQuery, .F.)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	dbGoTop()
	While !(cResQRY)->(EOF())

		nPos    := 0
		nQtdNUC := oModelNUC:GetQtdLine()
		For nI := 1 To nQtdNUC
			If oModelNUC:GetValue("NUC_CTPDES", nI) == (cResQRY)->NRH_COD
				nPos := nI
			EndIf
		Next

		If nPos > 0
			oModelNUC:GoLine( nPos )
			If oModelNUC:IsDeleted()
				oModelNUC:UnDeleteLine()
			EndIf
		Else
			If nQtdNUC == 1 .AND. Empty(oModelNUC:GetValue( "NUC_CTPDES"))
				oModelNUC:GoLine( 1 )
			Else
				oModelNUC:AddLine()
			EndIf
			If !( oModelNUC:SetValue( "NUC_CTPDES", (cResQRY)->NRH_COD ) )
				lRet := JurMsgErro(STR0036,, STR0097) //"Erro ao incluir despesas não cobráveis para o cliente"// "Realize o Ajuste Necessário"
			EndIf
		EndIf

		(cResQRY)->( dbSkip() )
	End

	dbSelectArea(cResQRY)
	(cResQRY)->(DbCloseArea())

EndIf

RestArea( aAreaNUH )
RestArea( aAreaSA1 )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA148NUM
Rotina para sugerir a próxima numeração no cadasdo do cliente
Esta rotina será utilizada como opção na iplantação dos clientes jurídicos

@param 	cTipo      	Tipo da numeração a ser retornada:
1 - Numeração do Cleinte
2 - Numeração da Loja
@param 	lUsaLacuna 	Indica se utiliza as lacunas na numeração para sugerir o próximo numero (.T. / .F.)

@author David Gonçalves Fernandes
@since 08/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148NUM(cTipo, lLacuna )
Local nMinNumero := 1
Local cQuery     := ''
Local cResQRY    := GetNextAlias()
Local aAreaSA1   := SA1->( GetArea() )
Local aArea      := GetArea()
Local oModel     := Nil
Local cCodigo    := ''
Local cNumero    := ''

If FWModelActive(, .T.) <> NIL

	oModel := FWModelActive()
	If cTipo == '1'
		cNumero := Criavar('A1_COD', .F.)
	ElseIf cTipo == '2'
		cNumero := Criavar('A1_LOJA', .F.)
	EndIf

	If cTipo == '1'
		cQuery := " SELECT SA1.A1_COD CODIGO, SA1.A1_LOJA "
	ElseIf cTipo == '2'
		cQuery := " SELECT SA1.A1_COD, SA1.A1_LOJA CODIGO "
	EndIf
	cQuery +=   " FROM SA1010 SA1 "
	cQuery += "  WHERE SA1.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SA1.A1_FILIAL = '" + xFilial('SA1') + "' "

	If (cTipo == '2' .And. !Empty( oModel:GetValue("SA1MASTER", "A1_COD") ) )
		cQuery += " AND SA1.A1_COD = '" + oModel:GetValue("SA1MASTER", "A1_COD") + "' "
	EndIf
	cQuery += " ORDER BY SA1.A1_COD, SA1.A1_LOJA "

	cQuery := ChangeQuery(cQuery, .F.)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	If !Empty((cResQRY)->CODIGO)
		If lLacuna == .T.
			While !(cResQRY)->(EOF())
				If nMinNumero < Val( (cResQRY)->CODIGO )
					cCodigo := nMinNumero
					Exit
				Else
					nMinNumero ++
					(cResQRY)->( dbSkip() )
				EndIf
			End
		Else
			While !(cResQRY)->(EOF())
				cCodigo := (cResQRY)->CODIGO
				(cResQRY)->( dbSkip() )
			EndDo
		EndIf
	EndIf

	If !Empty(cCodigo)
		If ( ValType(cCodigo) == 'C' )
			cNumero := StrZero( Val( cCodigo ) + 1, Len(cNumero))
		Else
			cNumero := StrZero( cCodigo + 1, Len(cNumero))
		EndIf
	Else
		cNumero := StrZero(1, Len(cNumero))
	EndIf
	If !Empty(oModel:GetValue("SA1MASTER", "A1_LOJA"))
		oModel:SetValue("SA1MASTER", "A1_LOJA", "  ")
	EndIf

	dbSelectArea(cResQRY)
	(cResQRY)->(DbCloseArea())

EndIf

RestArea( aAreaSA1 )
RestArea( aArea )

Return cNumero

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA148VLCLI
Ajusta o campo loja para não validar na sugestão ao digitar o cliente

@author David Gonçalves Fernandes
@since 07/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148VLCLI(lLacuna)
Local oModel  := Nil
Local cAux    := JA148NUM('2', lLacuna)

If FWModelActive(, .T.) <> Nil
	oModel := FWModelActive()
	If !oModel:SetValue("SA1MASTER", "A1_LOJA", cAux )
		JurMsgErro( 'Erro' )
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148NRJ
Verifica se o valor do campo de relatório é válido quando é digitado.

@param 	cMaster  	Fields ou Grid a ser verificado
@param cCampo	  	Campo a ser verificado
@Return lRet	 	  .T./.F. As informações são válidas ou não

@sample ExistCpo('RD0',M->NTE_CPART,1).AND.JURRD0('NTEDETAIL','NTE_CPART')

@author David Gonçalves Fernandes
@since 08/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148NRJ(cMaster, cCampo)
Local lRet      := .F.
Local aAreaSA1  := SA1->( GetArea() )
Local aAreaNUH  := NUH->( GetArea() )
Local aArea     := GetArea()
Local cQuery    := JA148QRY('NRJ')
Local cAliasNRJ := GetNextAlias()
Local oModel    := FWModelActive()

cQuery := ChangeQuery(cQuery, .F.)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasNRJ, .T., .T.)

(cAliasNRJ)->( dbSelectArea( cAliasNRJ ) )
(cAliasNRJ)->( dbGoTop() )

While !(cAliasNRJ)->( EOF() )
	If (cAliasNRJ)->NRJ_COD == oModel:GetValue(cMaster, cCampo)
		lRet := .T.
		Exit
	EndIf
	(cAliasNRJ)->( dbSkip() )
End

If !lRet
	JurMsgErro(STR0016,, STR0097) //Código inválido// "Realize o Ajuste Necessário"
EndIf

(cAliasNRJ)->( dbcloseArea() )

RestArea(aAreaNUH)
RestArea(aAreaSA1)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3NRJ
Monta a consulta padrão participantes ativos
Uso Geral.
@param 	cTipo Tipo do retorno dos participantes
              1 - Funcionários Ativos
              2 - Sócios
              3 - Sócios ou Revisores
              4 - Assinam Fatura

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample Consulta padrão específica RD0ATV

@author David Gonçalves Fernandes
@since 08/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148F3NRJ()
Local lRet     := .F.
Local aAreaSA1 := SA1->( GetArea() )
Local aAreaNUH := NUH->( GetArea() )
Local aArea    := GetArea()
Local cQuery   := JA148QRY('NRJ')
Local aPesq    := {"NRJ_COD", "NRJ_DESC"}
Local cTabela  := "NRJ"
Local cTela    := "JURA046" //Modelo utilizado para visualizacao do registro
Local lVisual  := .T. //Indica se a opcao de visualizacao estara presente

cQuery   := ChangeQuery(cQuery, .F.)
uRetorno := ''

RestArea( aAreaNUH )
RestArea( aAreaSA1 )
RestArea( aArea )

If JurF3Qry( cQuery, 'NRJNUH', 'NRJRECNO', @uRetorno, Nil, aPesq, cTela, Nil, Nil, lVisual, cTabela )
	NRJ->( dbGoto( uRetorno ) )
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURQRYRD0
Monta a query de Relatórios que podem ser exibidos pela consulta padrão ou
podem ser permitidos na digitação no cadastro do cliente

@Param cCliente	Código do cliente
@Param cLoja		Código da loja do cliente

@Return cQuery	 	Query montada

@author David Gonçalves Fernandes
@since 08/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148QRY(cAliasF3)
Local cQuery := ''

If cAliasF3 == 'NRJ'
	cQuery := " SELECT NRJ.NRJ_COD, NRJ.NRJ_DESC, NRJ.R_E_C_N_O_ NRJRECNO "
	cQuery +=   " FROM " + RetSqlName("NRJ") + " NRJ "
	cQuery +=  " WHERE "
	cQuery +=    " NRJ.NRJ_FILIAL = '" + xFilial( "NRJ" ) + "' "
	cQuery +=    " AND NRJ.NRJ_ATIVO = '1' "
	cQuery +=    " AND NRJ.NRJ_COD NOT IN ( "
	cQuery +=                             " SELECT NUA.NUA_CTPREL "
	cQuery +=                              " FROM " + RetSqlName("NUA") + " NUA "
	cQuery +=                             " WHERE "
	cQuery +=                                 " NUA.NUA_FILIAL = '" + xFilial( "NUA" ) + "' "
	cQuery +=                                 " AND NUA.NUA_CCLIEN = '" + M->A1_COD  + "' "
	cQuery +=                                 " AND NUA.NUA_CLOJA  = '" + M->A1_LOJA + "' "
	cQuery +=                                 " AND NUA.D_E_L_E_T_ = ' ' ) "
	cQuery +=   " AND NRJ.D_E_L_E_T_ = ' ' "
EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148ORIDT
Sugere a data final da participação confirme o prazo de validade da orignação
Funação para ser utilziada no campo Tipo de Originação e Data Inicio da
participação

@Param cCampo		Campo alterado: NU9_CTIPO / NU9_DTINI

@Return cData	 	Data final da participação ajustada

@Obs Mantida por compatibilidade para versões anteriores a 12.1.25

@author David Gonçalves Fernandes
@since 12/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148ORIDT()
Local dData    := cToD ('')
Local aAreaSA1 := SA1->( GetArea() )
Local aAreaNUH := NUH->( GetArea() )
Local aArea    := GetArea()
local nPrazo   := 0
Local oModel   := FWModelActive()
Local ddataini := oModel:GetValue("NU9DETAIL", "NU9_DTINI")
Local cTipo    := oModel:GetValue("NU9DETAIL", "NU9_CTIPO")

If !Empty(ddataini) .And. !Empty(cTipo)
	nPrazo := GetAdvFVal( 'NRI', 'NRI_PRAZOV', xFilial('NRI') + cTipo )
	If nPrazo > 0
		dData := ddataini + nPrazo
	EndIf
Else
	dData := cToD ('')
EndIf

RestArea(aAreaNUH)
RestArea(aAreaSA1)
RestArea(aArea)

Return dData

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148CHAV
Valida a chave da tabla

@Param cTabela		Tabela para validar a existencia de campo duplicado

@Return lRet	 		Existe registro repedido

@author David Gonçalves Fernandes
@since 12/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148CHAV(cTabela)
Local lRet := .T.

If cTabela == 'NU9'
	lRet := ExistChav('NU9', M->A1_COD + M->A1_LOJA + FwFldGet('NU9_CPART') + FwFldGet('NU9_CTIPO'), 1)
ElseIf cTabela == 'NUA'
	lRet := ExistChav('NUA', M->A1_COD + M->A1_LOJA + FwFldGet('NUA_CTPREL'), 1)
ElseIf cTabela == 'NUB'
	lRet := ExistChav('NUB', M->A1_COD + M->A1_LOJA + FwFldGet('NUB_CTPATI'), 1)
ElseIf cTabela == 'NUC'
	lRet := ExistChav('NUC', M->A1_COD + M->A1_LOJA + FwFldGet('NUC_CTPDES'), 1)
ElseIf cTabela == 'NUD'
	lRet := ExistChav('NUD', M->A1_COD + M->A1_LOJA + FwFldGet('NUD_CPART') + FwFldGet('NUD_CTPORI') + FwFldGet('NUD_AMINI') + FwFldGet('NUD_AMFIM'), 1)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148VPART
Valida se há participações obrigatórias não preenchidas
Valida se os percentuais de participação e os participantes
correspondem aos parâmetros do tipo de originação

@Return lRet	 		A validação está ok

@author David Gonçalves Fernandes
@since 12/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148VPART(oModel)
Local aArea       := GetArea()
Local aAreaSA1    := SA1->( GetArea() )
Local aAreaNUH    := NUH->( GetArea() )
Local aAreaNU9    := NU9->( GetArea() )
Local oModelNU9   := oModel:GetModel("NU9DETAIL")
Local nQtdLinha   := oModelNU9:GetQtdLine()
Local cResQRY     := GetNextAlias()
Local lRet        := .T.
Local nLinha      := 0
Local nPos        := 0
Local nPercent    := 0
Local nTotPerc    := 0
Local cQuery      := ""
Local cCTipo      := ""
Local cDTipo      := ""
Local cPart       := ""
Local cPerc       := ""
Local cMsg        := ""
Local aParticip   := {} //Vetor com a soma do percentual das participações por tipo de originação //{ tipo , soma }
Local nTamDec     := TamSX3("NRI_SOMAOR")[2]
Local lArredondar := SuperGetMV("MV_JARPART", .F., "2") == '1' //Arredondar participação? 1 - Sim; 2 - Não.

cQuery := " SELECT NRI.NRI_COD, NRI.NRI_DESC "
cQuery +=   " FROM " + RetSqlName("NRI") + " NRI "
cQuery +=  " WHERE NRI.D_E_L_E_T_ = ' ' "
cQuery +=    " AND NRI.NRI_FILIAL = '" + xFilial("NRI") + "' "
cQuery +=    " AND ( NRI.NRI_TIPO = '1' OR NRI.NRI_TIPO = '3' )"
cQuery +=    " AND NRI.NRI_ATIVO  = '1' "
cQuery +=    " AND NRI.NRI_OBRIGA = '1' "

cQuery := ChangeQuery(cQuery, .F.)
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

cMsg := STR0022 + CRLF // "As Originações obrigatórias precisam ser incluídas "

While !(cResQRY)->(EOF())

	nPos := 0
	For nLinha := 1 To nQtdLinha
		If !oModelNU9:IsDeleted(nLinha) .And. oModelNU9:GetValue("NU9_CTIPO", nLinha) == (cResQRY)->NRI_COD
			nPos := nLinha
		EndIf
	Next

	If nPos == 0
		cMsg += (cResQRY)->NRI_COD + " - " + AllTrim( (cResQRY)->NRI_DESC) + ". " + CRLF
		lRet := .F.
	EndIf
	(cResQRY)->( dbSkip() )
EndDo

(cResQRY)->( dbCloseArea() )

If lRet .And. nQtdLinha > 0
	cMsg := STR0023 + CRLF // "Só é permitida a inclusão de participantes que são sócios para a originação: "
	For nLinha := 1 To nQtdLinha
		If !oModelNU9:IsDeleted(nLinha)
			cCTipo := oModelNU9:GetValue("NU9_CTIPO", nLinha)
			cDTipo := oModelNU9:GetValue("NU9_DTIPO", nLinha)
			cPart  := oModelNU9:GetValue("NU9_CPART", nLinha)
			cPerc  := oModelNU9:GetValue("NU9_PERC" , nLinha)

			If JurGetDados('NRI', 1, xFilial('NRI') + cCTipo, 'NRI_INCSOC' ) == '1'
				If JurGetDados('NUR', 1, xFilial('NUR') + cPart, 'NUR_SOCIO' ) <> '1'
					lRet := .F.
					If At( AllTrim( cCTipo ), cMsg ) == 0
						cMsg +=  AllTrim( cCTipo + " - " + cDTipo ) + ". " + CRLF
					EndIf
				EndIf
			EndIf

			If lRet .And. !Empty(cCTipo)
				nPos := aScan( aParticip, { |aX| aX[1] == cCTipo } )
				If nPos > 0
					aParticip[nPos][2] := aParticip[nPos][2] + cPerc
				Else
					aAdd( aParticip, { AllTrim( cCTipo ), cPerc, AllTrim( cDTipo ) } )
				EndIf
			EndIf

		EndIf
	Next
EndIf

If lRet .And. Len(aParticip) > 0
	cMsg := STR0024 + CRLF // "A soma da participação não confere com o exigido pela originação"
	For nLinha := 1 To Len(aParticip)
		nPercent := JurGetDados('NRI', 1, xFilial('NRI') + aParticip[nLinha][1], 'NRI_SOMAOR')
		If nPercent > 0
			nTotPerc := Iif(lArredondar, Round(aParticip[nLinha][2], nTamDec), aParticip[nLinha][2])
			If nPercent <> nTotPerc
				lRet := .F.
				cMsg +=  aParticip[nLinha][1] + " - " + aParticip[nLinha][3] + " -> " + AllTrim(Str(nPercent)) + "%. " + CRLF
			EndIf
		EndIf
	Next
EndIf

If !lRet
	JurMsgErro(cMsg,, STR0097) // "Realize o Ajuste Necessário"
EndIf

RestArea(aAreaNU9)
RestArea(aAreaNUH)
RestArea(aAreaSA1)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadNUD
Faz a carga dos dados da grid do NUD e ordena decrescente pelo ano-mês

@author David Gonçalves Fernandes
@since 15/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadNUD( oGrid )
Local nOperacao := oGrid:GetModel():GetOperation()
Local aStruct   := oGrid:oFormModelStruct:GetFields()
Local nAt       := 0
Local aRet      := {}

If nOperacao <> OP_INCLUIR // <- requer o INCLUDE do "FWMVCDEF.CH"

	aRet := FormLoadGrid( oGrid )

	// Ordena decrescente pelo Ano/Mes
	If ( nAt := aScan( aStruct, { |aX| aX[MODEL_FIELD_IDFIELD] == 'NUD_AMINI' } ) ) > 0
		aSort( aRet,,, { |aX, aY| aX[2][nAt] > aY[2][nAt] } )
	EndIf

EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148ALTCT
Atualiza no contrato as informações alteradas no cadastro do cliente

@author David Gonçalves Fernandes
@since 15/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA148ALTCT()
Local lRet        := .T.
Local aArea       := GetArea()
Local aAreaSA1    := SA1->( GetArea() )
Local aAreaNUH    := NUH->( GetArea() )
Local aAreaNXP    := NXP->( GetArea() )
Local aAreaNXG    := NXG->( GetArea() )
Local aAreaNT0    := NT0->( GetArea() )
Local cResQRY     := GetNextAlias()
Local cResNXP     := GetNextAlias()
Local cResNXG     := GetNextAlias()
Local cQuery      := ''
Local cQryNXP     := ''
Local cQryNXG     := ''
Local lAltContr   := SuperGetMV( 'MV_JALTCT',, .T. ) // Ajusta nos contratos, os campos correspondentes alterados no cliente
Local nPos        := 0
Local oModel      := FWModelActive()
Local lViaTela    := !IsInCallStack("CheckTask") .And. !IsBlind() // Se não for Schedule e não for execução automática

NXP->(DBSetOrder(2))
NXP->(dbGoTop())
NT0->(DbSetOrder(5))

If oModel:GetOperation() == 4
	If lAltContr .And. NT0->(DbSeek(xFilial("NT0") + NUH->NUH_COD + NUH->NUH_LOJA)) .And. (;
		aScan( aDados,{ | x |  x[1] == 'NUH_CPART'  .OR. ;
							x[1] == 'NUH_CMOE'   .OR. ;
							x[1] == 'NUH_CESCR2' .OR. ;
							x[1] == 'NUH_CRELAT' .OR. ;
							x[1] == 'NUH_CCARTA' .OR. ;
							x[1] == 'NUH_FPAGTO' .OR. ;
							x[1] == 'NUH_CBANCO' .OR. ;
							x[1] == 'NUH_CAGENC' .OR. ;
							x[1] == 'NUH_CCONTA' .OR. ;
							x[1] == 'NUH_CIDIO'  .OR. ;
							x[1] == 'NUH_CIDIO2' .OR. ;
							x[1] == 'NUH_TPFECH'} ) > 0 )
		//Exibe a pergunta de alteraçao de clientes
		lAltClien := IIf(lViaTela, ApMsgYesNo(STR0025), lAltContr) // "Deseja que as alterações sejam refletidas nos contratos do cliente?"
	EndIf
EndIf

If lAltClien
	cQuery := " SELECT NT0.R_E_C_N_O_ NT0RECNO "
	cQuery +=   " FROM " + RetSqlName("NT0") + " NT0 "
	cQuery +=  " WHERE NT0.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQuery +=    " AND NT0.NT0_CCLIEN = '" + oModel:GetValue('SA1MASTER', 'A1_COD')  + "' "
	cQuery +=    " AND NT0.NT0_CLOJA  = '" + oModel:GetValue('SA1MASTER', 'A1_LOJA') + "' "

	cQuery := ChangeQuery(cQuery, .F.)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	(cResQRY)->(dbGoTop())
	While !(cResQRY)->(EOF())

		If (cResQRY)->NT0RECNO > 0

			NT0->( dbGoTo( (cResQRY)->NT0RECNO ) )
			RecLock( 'NT0', .F. )

			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CPART'} ) ) > 0
				NT0->NT0_CPART1 := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CESCR2'} ) ) > 0
				NT0->NT0_CESCR := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_TPFECH'} ) ) > 0
				NT0->NT0_TPFECH := aDados[nPos][3]
			EndIf

			MsUnlock()
		EndIf

		(cResQRY)->(dbskip())
	EndDo

	(cResQRY)->( dbCloseArea() )

	cQryNXP := " SELECT NXP.R_E_C_N_O_ NXPRECNO "
	cQryNXP +=   " FROM " + RetSqlName("NXP") + " NXP "
	cQryNXP +=  " WHERE NXP.D_E_L_E_T_ = ' ' "
	cQryNXP +=    " AND NXP.NXP_FILIAL = '" + xFilial("NXP") + "' "
	cQryNXP +=    " AND NXP.NXP_CLIPG  = '" + oModel:GetValue('SA1MASTER', 'A1_COD')  + "' "
	cQryNXP +=    " AND NXP.NXP_LOJAPG = '" + oModel:GetValue('SA1MASTER', 'A1_LOJA') + "' "

	cQryNXP := ChangeQuery(cQryNXP, .F.)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQryNXP), cResNXP, .T., .T.)

	(cResNXP)->(dbGoTop())
	While !(cResNXP)->(EOF())

		If (cResNXP)->NXPRECNO > 0

			NXP->( dbGoTo( (cResNXP)->NXPRECNO ) )
			RecLock( 'NXP', .F. )

			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CMOE'} ) ) > 0
				NXP->NXP_CMOE := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CRELAT'} ) ) > 0
				NXP->NXP_CRELAT := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_FPAGTO'} ) ) > 0
				NXP->NXP_FPAGTO := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CCARTA'} ) ) > 0
				NXP->NXP_CCARTA := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CBANCO'} ) ) > 0
				NXP->NXP_CBANCO := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CAGENC'} ) ) > 0
				NXP->NXP_CAGENC := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CCONTA'} ) ) > 0
				NXP->NXP_CCONTA := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CIDIO'} ) ) > 0
				NXP->NXP_CIDIO := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CIDIO2'} ) ) > 0
				NXP->NXP_CIDIO2 := aDados[nPos][3]
			EndIf

			MsUnlock()

		EndIf

		(cResNXP)->(dbskip())
	End

	(cResNXP)->( dbCloseArea() )

	cQryNXG := " SELECT NXG.R_E_C_N_O_ NXGRECNO "
	cQryNXG +=   " FROM " + RetSqlName("NXG") + " NXG "
	cQryNXG +=  " WHERE NXG.D_E_L_E_T_ = ' ' "
	cQryNXG +=    " AND NXG.NXG_FILIAL = '" + xFilial("NXG") + "' "
	cQryNXG +=    " AND NXG.NXG_CLIPG  = '" + oModel:GetValue('SA1MASTER', 'A1_COD')  + "' "
	cQryNXG +=    " AND NXG.NXG_LOJAPG = '" + oModel:GetValue('SA1MASTER', 'A1_LOJA') + "' "
	cQryNXG +=    " AND NXG.NXG_CFATAD <> '' "
	cQryNXG +=    " AND NXG.NXG_CPREFT = '' "
	cQryNXG +=    " AND NXG.NXG_CFATUR = '' "

	cQryNXG := ChangeQuery(cQryNXG , .F.)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQryNXG), cResNXG, .T., .T.)

	(cResNXG)->(dbGoTop())
	While !(cResNXG)->(EOF())

		If (cResNXG)->NXGRECNO > 0

			NXG->( dbGoTo( (cResNXG)->NXGRECNO ) )
			RecLock( 'NXG', .F. )

			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CMOE'} ) ) > 0
				NXG->NXG_CMOE := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CRELAT'} ) ) > 0
				NXG->NXG_CRELAT := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_FPAGTO'} ) ) > 0
				NXG->NXG_FPAGTO := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CCARTA'} ) ) > 0
				NXG->NXG_CCARTA := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CBANCO'} ) ) > 0
				NXG->NXG_CBANCO := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CAGENC'} ) ) > 0
				NXG->NXG_CAGENC := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CCONTA'} ) ) > 0
				NXG->NXG_CCONTA := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CIDIO'} ) ) > 0
				NXG->NXG_CIDIO := aDados[nPos][3]
			EndIf
			If (nPos := aScan( aDados, { | x | x[1] == 'NUH_CIDIO2'} ) ) > 0
				NXG->NXG_CIDIO2 := aDados[nPos][3]
			EndIf

			MsUnlock()

		EndIf

		(cResNXG)->(dbskip())
	End

	(cResNXG)->( dbCloseArea() )

EndIf

RestArea( aAreaNUH )
RestArea( aAreaSA1 )
RestArea( aAreaNXP )
RestArea( aAreaNXG )
RestArea( aAreaNT0 )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148F3NU9
Função para definir a consulta padrão co campo NU9_CPART conforme o
tipo de originação utilziado.
Se a originação permitir a inclusão de sócios, exibirá somente os sócios
caso contrário, exibirá todos os participantes ativos.

@author David Gonçalves Fernandes
@since 15/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148F3NU9()
Local lRet      := .T.
Local cTipOrig  := ''
Local cIncSocio := ''

cTipOrig  := FwFldGet("NU9_CTIPO")
cIncSocio := Posicione('NRI', 1, xFilial('NRI') + cTipOrig, 'NRI_INCSOC')

If cIncSocio == '1'
	lRet := JURF3RD0AT('2') // Somente os sócios
Else
	lRet := JURF3RD0AT('1') // Todos os ativos
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148TPORI
Função para validação do campo NU9_CPART conforme o tipo de originação
utilizado. se a originação permite inclusão somente para sócios ou para
todos os participantes ativos.

@author David Gonçalves Fernandes
@since 15/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148TPORI()
Local cRet      := ''
Local cTipOrig  := ''
Local cIncSocio := ''

cTipOrig  := FwFldGet("NU9_CTIPO")
cIncSocio := Posicione('NRI', 1, xFilial('NRI') + cTipOrig, 'NRI_INCSOC' )

If cIncSocio == '1'
	cRet := '2' // Somente os sócios
Else
	cRet := '1' // Todos os ativos
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148VLDCP
Função para validação dos campos do cadastro de cliente

@author David Gonçalves Fernandes
@since 15/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148VLDCP(cCampo)
Local lRet   := .T.
Local cMsg   := ''
Local oModel := FWModelActive()

If cCampo == 'NUD_AMFIM' .Or. cCampo == 'NUD_AMINI'
	lRet := JHISTVMIni("NUD")

ElseIf cCampo == 'NU9_CTIPO'
	lRet := JAVLDCAMPO('NU9DETAIL', 'NU9_CTIPO', 'NRI', 'NRI_ATIVO', '1') .And. ;
	        ( JAVLDCAMPO('NU9DETAIL', 'NU9_CTIPO', 'NRI', 'NRI_TIPO', '1') .Or. JAVLDCAMPO('NU9DETAIL', 'NU9_CTIPO', 'NRI', 'NRI_TIPO', '3') )
	cMsg := STR0016 //Código inválido

ElseIf cCampo == 'NU9_DTINI' .Or. cCampo == 'NU9_DTFIM'
	If !Empty(FwFldGet('NU9_DTINI')) .AND. !Empty(FwFldGet('NU9_DTFIM'))
		lRet := ( FwFldGet('NU9_DTINI') < FwFldGet('NU9_DTFIM') )
		cMsg := STR0034 //"A Data Final deve ser maior do que a Data Inicial"
	EndIf

ElseIf cCampo == "NUH_UTEBIL"
	If FwFldGet("NUH_UTEBIL") = "2" .And. !Empty( FwFldGet("NUH_CEMP") )
		oModel:ClearField("NUHMASTER", "NUH_CEMP")
		oModel:ClearField("NUHMASTER", "NUH_DEMP")
	EndIf

EndIf

If !lRet .And. !Empty(cMsg)
	JurMsgErro(cMsg,, STR0097) //"Realize o Ajuste Necessário"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur148LOk
Validação da data final no cadastro de histórico de Participação do cliente
Validação de linha:
Não permitir inclusão de mais de 1 hist com ano-mês final em branco para o mesmo participante e mesma horiginação
Não permitir inclusão com mesmo ano-mes inicial ou final para o mesmo participante e mesma horiginação
Não permitir históricos futuros
Não permitir períodos sobrepostos

@Return lRet	 	.T./.F. As informações são válidas ou não

@author David Gonçalves Fernandes
@since 04/11/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Jur148LOk(oGrid, cAliasG)
Local lRet       := .T.
Local aColsOrd   := {}
Local nPosAmIni  := 1
Local nPosAmFim  := 2
Local nPosTPORI  := 3
Local nPosCPART  := 4
Local nAscanNU9  := 0
Local nLinhaNU9  := 0
Local nLinhaNUD  := 0
Local nOperation := oGrid:GetModel():GetOperation()
Local nposSobre  := 0
Local nPosBranco := 0
Local nI         := 0
Local nLines     := 0

	If nOperation == 3 .Or. nOperation == 4 //Inclusão (3) ou Alteração (4)

		If cAliasG == "NUD"
			oStructNU9 := oGrid:GetModel():GetModel( "NU9DETAIL" )
			oStructNUD := oGrid:GetModel():GetModel( "NUDDETAIL" )

			nLinhaNU9 := oStructNU9:GetLine()
			nLinhaNUD := oStructNUD:GetLine()

			//Valida o preenchimento do participante
			nLines := oStructNUD:GetQtdLine()

			For nI := 1 To nLines
				If !oStructNUD:IsDeleted(nI) .And. !oStructNUD:IsEmpty(nI) .And. Empty(FwFldget("NUD_CPART"))
					lRet := JurMsgErro(STR0084,, STR0097) //"O participante não foi preenchido."//"Realize o Ajuste Necessário"
					Exit
				EndIf
			Next
			oStructNUD:GoLine(nLinhaNUD)

			If lRet
				// Não permitir históricos Futuros
				If oStructNUD:GetValue(cAliasG + "_AMINI") > AnoMes(MsDate())
					lRet := JurMsgErro(STR0032,, STR0097) // "Não é permitido gravar histórico futuros"//"Realize o Ajuste Necessário"
				EndIf

				If lRet .And. !Empty(oStructNUD:GetValue(cAliasG + "_AMFIM")) .And. oStructNUD:GetValue(cAliasG + "_AMFIM") > AnoMes(MsDate())
					lRet := JurMsgErro(STR0032,, STR0097) // "Não é permitido gravar histórico futuros"//"Realize o Ajuste Necessário"
				EndIf

				// Não permitir inclusão de mais de 1 hist com ano-mês final em branco para o mesmo participante e mesma originação
				If lRet .And. Empty(oStructNUD:GetValue(cAliasG + "_AMFIM"))

					nLines := oStructNU9:GetQtdLine()
					//Se não houver nenhuma participação, exige o preenchimento do ano-mês final
					For nI := 1 To nLines
						If !oStructNU9:IsDeleted() .And. ;
						 oStructNU9:GetValue("NU9_CTIPO", nI) == oStructNUD:GetValue("NUD_CTPORI") .And. ;
						 oStructNU9:GetValue("NU9_CPART", nI) == oStructNUD:GetValue("NUD_CPART")
							nAscanNU9 := nI
						EndIf
					Next

					nLines := oStructNUD:GetQtdLine()
					For nI := 1 To nLines
						If !oStructNUD:IsDeleted() .And. ;
						   Empty(oStructNUD:GetValue("NUD_AMFIM", nI)) .And. ;
						   oStructNUD:GetValue("NUD_AMINI", nI) <> oStructNUD:GetValue("NUD_AMINI") .And. ;
						   oStructNUD:GetValue("NUD_CPART", nI) == oStructNUD:GetValue("NUD_CPART") .And. ;
						   oStructNUD:GetValue("NUD_CTPORI", nI) == oStructNUD:GetValue("NUD_CTPORI")
							nPosBranco := nI
						EndIf
					Next

					If nPosBranco > 0 .Or. (nPosBranco == 0 .And. nAscanNU9 == 0)
						lRet := JurMsgErro(STR0031,, STR0097) // "É preciso preencher o ano-mês final deste histórico"//"Realize o Ajuste Necessário"
					EndIf
				EndIf

				If lRet

					nLines := oStructNUD:GetQtdLine()
					//Não permitir períodos sobrepostos
					For nI := 1 To nLines
						If !oStructNUD:IsDeleted() .And. !oStructNUD:IsEmpty()
							aAdd(aColsOrd, {oStructNUD:GetValue("NUD_AMINI", nI), oStructNUD:GetValue("NUD_AMFIM", nI), ;
							                oStructNUD:GetValue("NUD_CTPORI", nI), oStructNUD:GetValue("NUD_CPART", nI)})
						EndIf
					Next
					aSort( aColsOrd,,, { |aX, aY| aX[nPosAmIni] > aY[nPosAmIni] } )

					//Verifica se o ano-mês inicial é menor ou igual a algum ano-mês final de período anterior
					If nPosSobre == 0 .And. !oStructNUD:IsDeleted() .And. !oStructNUD:IsEmpty() .And. !Empty(oStructNUD:GetValue("NUD_AMFIM"))
						nposSobre := ascan(aColsOrd, {|x| x[ nPosCPART ] == oStructNUD:GetValue("NUD_CPART") .And. ;
						x[ nPosTPORI ] == oStructNUD:GetValue("NUD_CTPORI") .And.  ;
						x[ nPosAMIni ]   <  oStructNUD:GetValue("NUD_AMINI") .And. ; //períodos anteriores
						x[ nPosAmFim ]  >= oStructNUD:GetValue("NUD_AMINI") .And.  ;
						x[ nPosAMIni ] != x[ nPosAmFim ]}  )
					EndIf
					//Verifica se o ano-mês final é maior ou igual a algum ano-mês inicial de período posterior
					If nPosSobre == 0 .And. !oStructNUD:IsDeleted() .And. !oStructNUD:IsEmpty() .And. !Empty(oStructNUD:GetValue("NUD_AMFIM"))
						nposSobre := ascan(aColsOrd, {|x| x[ nPosCPART ] == oStructNUD:GetValue("NUD_CPART") .AND. 	;
						x[ nPosTPORI ] == oStructNUD:GetValue("NUD_CTPORI") .And.   ;
						x[ nPosAMIni ]   >  oStructNUD:GetValue("NUD_AMINI") .And. ; //períodos posteriores
						x[ nPosAMIni ]  <= oStructNUD:GetValue("NUD_AMFIM") .And.  ;
						x[ nPosAMIni ] != x[ nPosAmFim ]}  )
					EndIf
					//Verifica se o ano-mês inicial do período aberto é menor ou igual a algum ano-mês final
					If nPosSobre == 0 .And. !oStructNUD:IsDeleted() .And. !oStructNUD:IsEmpty() .And. Empty(oStructNUD:GetValue("NUD_AMFIM"))
						nposSobre := ascan(aColsOrd, {|x| x[ nPosCPART ] == oStructNUD:GetValue("NUD_CPART") .And. ;
						x[ nPosTPORI ] == oStructNUD:GetValue("NUD_CTPORI") .And.   ;
						x[ nPosAmFim ] >= oStructNUD:GetValue("NUD_AMINI") .And.   ;
						!Empty( x[ nPosAmFim ] )}  ) //Períodos fechados
					EndIf
					//Verifica se o ano-mês inicial é maior que algum ano-mês inicial em aberto
					If nPosSobre == 0 .And. !oStructNUD:IsDeleted() .And. !oStructNUD:IsEmpty() .And. !Empty(oStructNUD:GetValue("NUD_AMFIM"))
						nposSobre := ascan(aColsOrd, {|x| x[ nPosCPART ] == oStructNUD:GetValue("NUD_CPART") .And. ;
						x[ nPosTPORI ] == oStructNUD:GetValue("NUD_CTPORI") .And.   ;
						x[ nPosAMIni ] <= oStructNUD:GetValue("NUD_AMINI") .And.   ;
						Empty( x[ nPosAmFim ] )} ) //Período aberto
					EndIf

					If nposSobre > 0
						lRet := JurMsgErro(STR0029,, STR0097)//"Períodos sobrepostos no histórico das participações"//"Realize o Ajuste Necessário"
					EndIf

				EndIf
				oStructNU9:goLine(nLinhaNU9)
				oStructNUD:goLine(nLinhaNUD)
			EndIf

		ElseIf cAliasG == "NU9"

			oStructNU9 := oGrid:GetModel():GetModel( "NU9DETAIL" )
			nLinhaNU9  := oStructNU9:GetLine()
			nLines     := oStructNU9:GetQtdLine()

			For nI := 1 To nLines
				If !oStructNU9:IsDeleted(nI) .And. !oStructNU9:IsEmpty(nI) .And. Empty(FwFldget("NU9_CPART"))
					lRet := JurMsgErro(STR0084) //"O participante não foi preenchido. Verifique!"
					Exit
				EndIf
			Next
			oStructNU9:GoLine(nLinhaNU9)
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J148VLDCP
Função para validar os campos do cliente pelo dicionário

@author David G. Fernandes
@since 05/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J148VLDCP(cCampo)
Local lRet := .T.
Local cMsg := ""

If cCampo == "NUH_DIAVEN"
	If !Empty(FwFldGet("NUH_DIAVEN"))
		lRet := FwFldGet("NUH_DIAVEN") >= 1 .And. FwFldGet("NUH_DIAVEN") <= 31
		cMsg := STR0037 //"O dia deve estar entre 1 e 31"
	EndIf

ElseIf cCampo == "NUH_DIAEMI"
	If !Empty(FwFldGet("NUH_DIAEMI"))
		lRet := FwFldGet("NUH_DIAEMI") >= 1 .And. FwFldGet("NUH_DIAEMI") <= 31
		cMsg := STR0037 //"O dia deve estar entre 1 e 31"
	EndIf
EndIf

If !lRet
	JurMsgErro(cMsg,, STR0097)//"Realize o Ajuste Necessário"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J148PREVAL
Altera a propriedade dos campos como nao obrigatorio.
Quando o cliente for do tipo "Exportacao".

@author Andre Godoi
@since 16/08/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J148PREVAL( oStructSA1, oStructNUH )
Local lOk        := !FwFldGet("A1_TIPO") == "X"
Local lRet       := .T.

	oStructNUH:SetProperty('NUH_ENDI', MODEL_FIELD_OBRIGAT, !lOk )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148PREAC8
Pré-validação de linha do Contato

@author Jorge Martins
@since  03/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA148PREAC8(oModelGrid, nLine, cAction, cField, xValue, xCurrentValue)
Local oModel       := FWModelActive()
Local cContato     := ""
Local cCliente     := ""
Local cLoja        := ""
Local lRet         := .T.

Default oModelGrid := oModel:GetModel( 'AC8DETAIL' )
Default cAction    := ""

	If !oModelGrid:IsInserted() .And. cAction == "DELETE" // Valida somente exclusão de linhas já existentes
		cCliente := oModel:GetValue( 'SA1MASTER', 'A1_COD' )
		cLoja    := oModel:GetValue( 'SA1MASTER', 'A1_LOJA' )
		cContato := J148ConAtu(oModelGrid:GetDataId())
		lRet     := J148VldAC8(cContato, cCliente, cLoja)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148POSAC8
Validacao da delecao do Contato

@author Ernani Forastieri
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA148POSAC8(oModelGrid, nLine)
Local oModel   := FWModelActive()
Local cCliente := ""
Local cLoja    := ""
Local cContato := ""
Local lRet     := .T.

Default oModelGrid := oModel:GetModel( 'AC8DETAIL' )

	If !oModelGrid:IsInserted()
		cCliente := oModel:GetValue( 'SA1MASTER', 'A1_COD' )
		cLoja    := oModel:GetValue( 'SA1MASTER', 'A1_LOJA' )
		cContato := J148ConAtu(oModelGrid:GetDataId())

		If cContato <> oModelGrid:GetValue( 'AC8_CODCON' )
			lRet := J148VldAC8(cContato, cCliente, cLoja)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J148VldAC8
Query para pré e pós-validação da tabela AC8

@author Jorge Martins
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J148VldAC8(cContato, cCliente, cLoja)
	Local cQuery  := ""
	Local cTabela := ""
	Local cTmp    := ""
	Local cMsg    := ""
	Local lRet    := .T.

	cQuery += " SELECT 'NXG' TABELA FROM " + RetSqlName( 'NXG' ) + " NXG "   // Pré-Fatura
	cQuery +=  " WHERE NXG.NXG_FILIAL = '" + xFilial( 'NXG' ) + "' "
	cQuery +=    " AND NXG.NXG_CCONT  = '" + cContato + "' "
	cQuery +=    " AND NXG.NXG_CLIPG  = '" + cCliente + "' "
	cQuery +=    " AND NXG.NXG_LOJAPG = '" + cLoja + "' "
	cQuery +=    " AND NXG.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NOT EXISTS (SELECT NX0.R_E_C_N_O_ "
	cQuery +=                      " FROM " + RetSqlName( 'NX0' ) + " NX0 "
	cQuery +=                     " WHERE NX0.NX0_FILIAL = '" + xFilial( 'NX0' ) + "' "
	cQuery +=                       " AND NX0.NX0_SITUAC = '1' "
	cQuery +=                       " AND NX0.NX0_COD = NXG.NXG_CPREFT "
	cQuery +=                       " AND NX0.D_E_L_E_T_ = ' ') "
	cQuery += " UNION "
	cQuery += " SELECT 'NXP' TABELA FROM " + RetSqlName( 'NXP' ) + " NXP "  // Contrato
	cQuery +=  " WHERE NXP.NXP_FILIAL = '" + xFilial( 'NXP' ) + "' "
	cQuery +=    " AND NXP.NXP_CCONT  = '" + cContato + "' "
	cQuery +=    " AND NXP.NXP_CLIPG  = '" + cCliente + "' "
	cQuery +=    " AND NXP.NXP_LOJAPG = '" + cLoja + "' "
	cQuery +=    " AND NXP.D_E_L_E_T_ = ' ' "
	cQuery += " UNION "
	cQuery += " SELECT 'NVN' TABELA FROM " + RetSqlName( 'NVN' ) + " NVN "  // Encaminhamento de Fatura
	cQuery +=  " WHERE NVN.NVN_FILIAL = '" + xFilial( 'NVN' ) + "' "
	cQuery +=    " AND NVN.NVN_CCONT  = '" + cContato + "' "
	cQuery +=    " AND NVN.NVN_CLIPG  = '" + cCliente + "' "
	cQuery +=    " AND NVN.NVN_LOJPG  = '" + cLoja + "' "
	cQuery +=    " AND NVN.D_E_L_E_T_ = ' ' "
	cQuery += " UNION "
	cQuery += " SELECT 'NXA' TABELA FROM " +  RetSqlName( 'NXA' ) + " NXA "  // Fatura
	cQuery +=  " WHERE NXA.NXA_FILIAL = '" + xFilial( 'NXA' ) + "' "
	cQuery +=    " AND NXA.NXA_CCONT  = '" + cContato + "' "
	cQuery +=    " AND NXA.NXA_CLIPG  = '" + cCliente + "' "
	cQuery +=    " AND NXA.NXA_LOJPG  = '" + cLoja + "' "
	cQuery +=    " AND NXA.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)

	cTmp   := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)

	If !(cTmp)->( EOF() )
		cTabela := (cTmp)->TABELA
	EndIf

	(cTmp)->( dbCloseArea() )

	If !Empty(cTabela)
		cMsg := I18N(STR0099, {cContato, cTabela, Capital(AllTrim( INFOSX2( cTabela, 'X2_NOME' )))}) // "Violação de Integridade. Foi encontrada referência do contato '#1' na tabela '#2' - '#3'."
		lRet := JurMsgErro(cMsg +CRLF+CRLF+ STR0068,, STR0097) //# "Este contato não pode ser alterado ou excluido!"//"Realize o Ajuste Necessário"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J148ConAtu
Obtem no banco o contato atual da linha

@author Jorge Martins / Jonatas Martins
@since 18/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J148ConAtu(nRecLine)
Local cContato  := ""
Local nRecAtual := AC8->(Recno())

	AC8->(dbGoto(nRecLine))
	
	If AC8->(!EOF())
		cContato := AC8->AC8_CODCON
	EndIf

	AC8->(dbGoto(nRecAtual))

Return cContato

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA148UPDGR
Função responsavel por atualizar o campo GRUPO das seguintes tabelas
	NVE -	Caso 											==> INDICE 01 -- NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS
	NT0 - Contratos 								==> INDICE 05 -- NT0_FILIAL+NT0_CCLIEN+NT0_CLOJA
	NVV - Fatura Adicional 					==> INDICE 02 -- NVV_FILIAL+NVV_CCLIEN+NVV_CLOJA+NVV_PARC
	NWF - Controle de Adiantamentos ==> INDICE 02 -- NWF_FILIAL+NWF_CGRPCL+NWF_CCLIEN+NWF_CLOJA
	NVY - Despesa 									==> INDICE 02 -- NVY_FILIAL+NVY_CCLIEN+NVY_CLOJA+NVY_CCASO
	NV4 - Lançamento Tabelado 	 		==> INDICE 02 -- NV4_FILIAL+NV4_CCLIEN+NV4_CLOJA+NV4_CCASO
	NXA - Operação em Fatura 		 		==> INDICE 06 -- NXA_FILIAL+NXA_CGRPCL+NXA_CCLIEN+NXA_CLOJA
	NX0 - Operação em Pré-fatura 		==>	INDICE 03 -- NX0_FILIAL+NX0_CCLIEN+NX0_CLOJA
	NUE - Time Sheet						 		==> INDICE 02 -- NUE_FILIAL+NUE_CCLIEN+NUE_CLOJA+NUE_CCASO

@author Adalberto de Sousa Monteiro
@since 04/11/10
@version 1.0
/*/
//-------------------------------------------------------------------//
Static Function JA148UPDGR( oModel, cTabela, cCampo, cCliente, cLoja)
Local aArea    := GetArea()
Local aAreaTab := (cTabela)->(GetArea())
Local cQuery   := ""
Local cResQRY  := GetNextAlias()
Local cGrupo   := oModel:GetValue("SA1MASTER", "A1_GRPVEN")

cQuery := " SELECT " + cTabela + ".R_E_C_N_O_ RECNOTAB "
cQuery += " FROM " + RetSqlName(cTabela) + " " + cTabela
cQuery += " WHERE " + cTabela + "." + cTabela + "_FILIAL = '" + xFilial( cTabela ) + "' "
cQuery +=   " AND " + cTabela + "." + cCliente + " = '" + oModel:GetValue("SA1MASTER", "A1_COD") + "' "
cQuery +=   " AND " + cTabela + "." + cLoja + " = '" + oModel:GetValue("SA1MASTER", "A1_LOJA") + "' "
cQuery +=   " AND " + cTabela + ".D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery, .F.)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

While !(cResQRY)->(Eof())
	(cTabela)->(dbGoto((cResQRY)->(RECNOTAB)))
	RecLock(cTabela, .F.)
	&(cTabela+"->"+cCampo) := cGrupo
	(cTabela)->(MsUnLock())
	(cResQRY)->(dbSkip())
EndDo

(cResQRY)->(dbCloseArea())

RestArea( aAreaTab )
RestArea( aArea )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148Cont
Validação dos campos de Contatos - AC8

@Return lRet	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 13/11/10
/*/
//-------------------------------------------------------------------
Function JA148Cont()
	Local oModel     := FWModelActive()
	Local oModelAC8  := oModel:GetModel('AC8DETAIL')
	Local oModelNUH  := oModel:GetModel('NUHMASTER')
	Local aArea      := GetArea()
	Local nContato   := 0
	Local lRet       := .T.
	Local nI         := 0
	
	For nI := 1 To oModelAC8:GetQtdLine()
		If !oModelAC8:IsDeleted(nI) .And. !Empty(oModelAC8:GetValue('AC8_CODCON', nI))
			nContato++
		EndIf
	Next
	
	If nContato == 0 .And. oModelNUH:GetValue('NUH_SITCAD') == '2'
		lRet := JurMsgErro(STR0102,, STR0042) // "Não foi encontrato um contato válido!" # "É necessario vincular ao menos um contato ao cliente, favor preencher o formulário de contato."
	EndIf
	
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148NUH
Inicializa os campos da NUH na alteracao
@author Ernani Forastieri
@since 23/12/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA148NUH( oModel )
Local aArea      := GetArea()
Local aAreaNUH   := NUH->( GetArea() )
Local aAreaNU9   := NU9->( GetArea() )
Local aCampos    := {}
Local nI         := 0
Local nOperation := oModel:GetOperation()
Local oModelNUH  := Nil
Local xInit      := ""

If nOperation == MODEL_OPERATION_UPDATE
	oModelNUH := oModel:GetModel( 'NUHMASTER')

	NUH->( dbSetOrder( 1 ) )
	If !NUH->( dbSeek( xFilial( 'NUH' ) + oModel:GetValue( 'SA1MASTER', 'A1_COD' ) + oModel:GetValue( 'SA1MASTER', 'A1_LOJA' ) ) )
		aCampos := oModelNUH:GetStruct():GetFields()

		For nI := 1 To Len( aCampos )
			If aCampos[nI][MODEL_FIELD_INIT] <> NIL
				xInit := oModelNUH:InitValue( aCampos[nI][MODEL_FIELD_IDFIELD] )
				If !Empty( xInit )
					oModelNUH:LoadValue( aCampos[nI][MODEL_FIELD_IDFIELD], xInit )
				EndIf
			EndIf
		Next
	EndIf
EndIf

RestArea( aAreaNU9 )
RestArea( aAreaNUH )
RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148VEBIL
Validação para ao alterar o cliente para utilizar e-billing, verificar
se há time-sheets com os campos de fase e tarefa sem preenchimento

@Return lRet   .T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 27/05/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA148VEBIL()
Local cQuery    := ''
Local cResQRY   := GetNextAlias()
Local lRet      := .T.
Local cCliente  := FwFldGet("A1_COD")
Local cLoja     := FwFldGet("A1_LOJA")
Local nQtde     := 0
Local aEbil     := {}
Local cEmpEbi   := ""

If FwFldGet("NUH_UTEBIL") == "1"

	cQuery := " SELECT COUNT(NUE.NUE_COD) COUNTNUE "
	cQuery +=   " FROM " + RetSqlName("NUE") + " NUE "
	cQuery +=  " WHERE NUE.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NUE.NUE_FILIAL = '" + xFilial( "NUE" ) + "' "
	cQuery +=    " AND NUE.NUE_CCLIEN = '" + cCliente  + "' "
	cQuery +=    " AND NUE.NUE_CLOJA  = '" + cLoja + "' "
	cQuery +=    " AND NUE.NUE_SITUAC = '1'"  //Situação: Pendente
	cQuery +=    " AND NUE.NUE_CFASE  = '' "
	cQuery +=    " AND NUE.NUE_CTAREF = '' "

	cQuery := ChangeQuery(cQuery, .F.)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	nQtde := (cResQRY)->COUNTNUE

	If (cResQRY)->COUNTNUE > 0
		ApMsgAlert( STR0046 + AllTrim( Str( (cResQRY)->COUNTNUE ) ) + STR0047 ) // "Existem "###" time-sheets sem fase/tarefa. Por favor, selecionar na tela seguinte as informações para preenchimento!"
		cEmpEbi := FwFldGet("NUH_CEMP")
		aEbil   := JA148AEBIL(cCliente, cLoja, cEmpEbi)
		lRet    := aEbil[1]

		If lRet
			lRet := JA148REbil(aEbil[3], aEbil[4], aEbil[5], aEbil[6], aEbil[7], aEbil[9])
		EndIf
	EndIf

	(cResQRY)->(dbCloseArea())

	If !lRet
		JurMsgErro(STR0051)
	ElseIf nQtde > 0
		ApMsgInfo(STR0052)
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148AEBIL
Tela para escolha da fase e tarefa e-billing para preenchimento nos
time-sheets

@param cCliente, Código do cliente
@param cLoja   , Código da loja
@param cEmpEb  , Código do documento e-billing do cliente
@param lEb     , Se .T. indica que mesmo a fase, tarefa e atividade Ebil. esiverem preenchidos
                 irá substituir os valores para gravar os novos que estão sendo passados.
@param nRotina, Rotina que usará a function
                1 - Operação de Pré
                2 - Remanejamento de Caso
                3 - Transferencia de TS

@Return lRet,  .T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 27/05/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148AEBIL(cCliente, cLoja, cEmpEb, lEb, cTSCod, cNewCodTS)
	Local lRet        := .F.
	Local aArea       := GetArea()
	Local oDlg        := Nil
	Local cDocEb      := ""
	Local oFase       := Nil
	Local oTarefa     := Nil
	Local oAtivid     := Nil
	Local aEbil       := {.F., "", "", "", "", "", .F., ""}
	Local oLayer      := FWLayer():New()
	Local oMainColl   := Nil
	Local bButtonOk   := {||}
	Local cRecSA1Old  := SA1->(Recno())

	Private cFaseTS   := CriaVar("NUE_CFASE" , .F.)
	Private cTarefaTS := CriaVar("NUE_CTAREF", .F.)
	Private cAtivEBTS := CriaVar("NUE_CTAREB", .F.)

	Default cEmpEb    := JurGetDados("NUH", 1, xFilial("NUH") + cCliente + cLoja, "NUH_CEMP")
	Default lEb       := .F.
	Default cTsCod    := ""
	Default cNewCodTS := ""

	If (xFilial("SA1") + cCliente + cLoja) != (SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA)
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + cCliente + cLoja))
	EndIf

	If Empty(cTSCod) .And. !Empty(cNewCodTS)
		cTSCod := cNewCodTS
	EndIf

	cDocEb := JurGetDados("NRX", 1, xFilial("NRX") + cEmpEb, "NRX_CDOC")

	DEFINE MSDIALOG oDlg TITLE STR0048 FROM 0, 0 TO 140, 530 PIXEL // "Definir atividade, fase e tarefa e-billing"

	oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
	oLayer:addCollumn('MainColl', 100, .F.) //Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel("MainColl")

	oAtivid := TJurPnlCampo():New(10, 05, 80, 22, oMainColl,, "NUE_CTAREB", {|| }, {||cAtivEBTS := oAtivid:Valor},,,, "NS0NUH")
	oAtivid:SetValid({|| JurTrgEbil(cCliente, cLoja, , , , ,;
	                                @oAtivid, , , ,;
	                                @oFase, , , ,;
	                                @oTarefa, , , , "ATIVEBI")})

	oFase := TJurPnlCampo():New(10, 95, 80, 22, oMainColl,, 'NUE_CFASE', {|| }, {||cFaseTS := oFase:Valor},,,, "NRYNUH")
	oFase:SetValid({|| JurTrgEbil(cCliente, cLoja, , , , ,;
	                              @oAtivid, , , ,;
	                              @oFase, , , ,;
	                              @oTarefa, , , , "FASE")})

	oTarefa := TJurPnlCampo():New(10,185,80,22,oMainColl,, "NUE_CTAREF", {|| }, {||cTarefaTS := oTarefa:Valor},,,, "NRZNUH")
	oTarefa:SetValid({|| JurTrgEbil(cCliente, cLoja, , , , ,;
	                                @oAtivid, , , ,;
	                                @oFase, , , ,;
	                                @oTarefa, , , , "TAREF")})
	oTarefa:SetWhen({||!Empty(oFase:Valor)})

	bButtonOk := {||IIf((!Empty(cFaseTS := oFase:Valor) .And. !Empty(cTarefaTS := oTarefa:Valor) .And. !Empty(cAtivEBTS := oAtivid:Valor)),;
						(aEbil := {.T., cTSCod, cCliente, cLoja, cFaseTS, cTarefaTS, cAtivEBTS, lEb, cDocEb}, oDlg:End()),;
						(ApMsgStop(STR0053), lRet := .F.))}

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bButtonOk, {||(oDlg:End())}, , /*aButtons*/, /*nRecno*/, /*cAlias*/, .F., .F., .F., .T., .F.)

	If SA1->(Recno()) != cRecSA1Old
		SA1->(DbGoTo(cRecSA1Old))
	EndIf
	RestArea( aArea )

Return aEbil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148VTAEB()
Filtro de tarefa de e-billing

@Param    cDoc      Número do documento
@Param    cFaseTaf  Código da fase relacionada a tarefa

@author Juliana Iwayama Velho
@since 27/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148VTAEB()
Local cFase    := ''
Local aArea    := GetArea()
Local cCliente := SA1->A1_COD
Local cLoja    := SA1->A1_LOJA
Local cDoc     := JAEMPEBILL(cCliente, cLoja)

NRY->( dbSetOrder( 1 ) )
NRY->( dbSeek( xFilial('NRY') + cDoc ) )

While !NRY->( EOF() ) .AND. NRY->NRY_CDOC == cDoc
	If AllTrim(NRY->NRY_CFASE) == AllTrim(cFaseTS)
		cFase := AllTrim(NRY->NRY_COD)
		Exit
	EndIf
	NRY->( dbSkip() )
End
RestArea( aArea )

Return cFase

//-------------------------------------------------------------------
/*/{Protheus.doc} J148HTNUD(oModel)
Rotinas de histórico para Participação no Cliente

@author Bruno Ritter
@since 16/08/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function J148HTNUD(oModel)
	Local lRet       := .T.
	Local aCpoMdls   := {}
	Local aNU9Cpo    := {}

	aAdd(aNU9Cpo, {"NU9_CPART" , "NUD_CPART"})
	aAdd(aNU9Cpo, {"NU9_CTIPO" , "NUD_CTPORI"})
	aAdd(aNU9Cpo, {"NU9_PERC"  , "NUD_PERC"})
	aAdd(aNU9Cpo, {"NU9_DTINI" , "NUD_DTINI"})
	aAdd(aNU9Cpo, {"NU9_DTFIM" , "NUD_DTFIM"})
	aAdd(aNU9Cpo, {"NU9_COD"   , "NUD_COD"})
	aAdd(aNU9Cpo, {"NU9_SIGLA" , "NUD_SIGLA"})
	aAdd(aCpoMdls, {"NU9DETAIL", aNU9Cpo})

	lRet := JURHIST(oModel, "NUDDETAIL", aCpoMdls, .T., {"NU9_SIGLA", "NUD_SIGLA", "NU9_CTIPO", "NUD_CTPORI"})

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J148VLPER(oModel)
Rotinas de histórico para Participação no Cliente

@return lRet, .T. Registro válido  .F. Registro inválido

@author Queizy Nascimento
@since 05/02/2019
/*/
//-------------------------------------------------------------------
Static Function J148VLPER(oModel)
Local oModelNUD   := oModel:GetModel("NUDDETAIL")
Local nQtdLinha   := oModelNUD:GetQtdLine()
Local aParticip   := {} // Vetor com a soma do percentual das participações por tipo de originação //{ tipo , soma }
Local nLinha      := 0
Local nPos        := 0
Local nPercent    := 0
Local nTotPerc    := 0
Local cMsg        := ""
Local cCTipo      := ""
Local cDTipo      := ""
Local cPart       := ""
Local cPerc       := ""
Local cAMIni      := ""
Local cAMFim      := ""
Local nTamDec     := TamSX3("NRI_SOMAOR")[2]
Local lArredondar := SuperGetMV("MV_JARPART", .F., "2") == '1' //Arredondar participação? 1 - Sim; 2 - Não.
Local lRet        := .T.

	If nQtdLinha > 0
		cMsg := STR0023 + CRLF // "Só é permitida a inclusão de participantes que são sócios para a originação: "
		For nLinha := 1 To nQtdLinha
			If !oModelNUD:IsDeleted(nLinha)
				cCTipo := AllTrim(oModelNUD:GetValue("NUD_CTPORI", nLinha))
				cDTipo := oModelNUD:GetValue("NUD_DTPORI", nLinha)
				cPart  := oModelNUD:GetValue("NUD_CPART" , nLinha)
				cPerc  := oModelNUD:GetValue("NUD_PERC"  , nLinha)
				cAMIni := oModelNUD:GetValue("NUD_AMINI" , nLinha)
				cAMFim := oModelNUD:GetValue("NUD_AMFIM" , nLinha)

				If JurGetDados('NRI', 1, xFilial('NRI') + cCTipo, 'NRI_INCSOC' ) == '1'
					If JurGetDados('NUR', 1, xFilial('NUR') + cPart, 'NUR_SOCIO' ) <> '1'
						lRet := .F.
						If At( Alltrim( cCTipo ), cMsg ) == 0
							cMsg += AllTrim( cCTipo + " - " + cDTipo ) + ". " + CRLF
						EndIf
					EndIf
				EndIf
				
				If lRet .And. !Empty(cCTipo)
					nPos := aScan( aParticip, { |aX| aX[1] == cCTipo .And. aX[3] == cAMIni .And. aX[4] == cAMFim } )
					If nPos > 0
						aParticip[nPos][2] := aParticip[nPos][2] + cPerc
					Else
						aAdd( aParticip, { cCTipo, cPerc, cAMIni, cAMFim } )
					EndIf
				EndIf

			EndIf
		Next
	EndIf

	If lRet .And. Len(aParticip) > 0
		cMsg := STR0024 + CRLF // "A soma da participação não confere com o exigido pela originação"
		For nLinha := 1 To Len(aParticip)
			nPercent := JurGetDados('NRI', 1, xFilial('NRI') + aParticip[nLinha][1], 'NRI_SOMAOR')
			If nPercent > 0
				nTotPerc := Iif(lArredondar, Round(aParticip[nLinha][2], nTamDec), aParticip[nLinha][2])
				If nPercent <> nTotPerc
					lRet := .F.
					cMsg += AllTrim(Str(nPercent)) + "%. " + CRLF
				EndIf
			EndIf
		Next
	EndIf
	
	If !lRet
		JurMsgErro(cMsg,, STR0097) // "Realize o ajuste necessário."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148REbil()
Verificação para Clientes Ebilling

@author Jorge Luis Branco Martins Junior
@since 06/06/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA148REbil(cCliente, cLoja, cFase, cTarefa, cAtivi, cDocEbCli)
Local aArea    := GetArea()
Local lRet     := .T.
Local lAltHr   := NUE->(ColumnPos( "NUE_ALTHR" )) > 0

dbSelectArea('NUE')
NUE->( dbSetOrder(2) )
	If NUE->( dbSeek(xFilial("NUE") + cCliente + cLoja))
		While !NUE->( EOF() ) .And. NUE->NUE_CCLIEN == cCliente .And. NUE->NUE_CLOJA == cLoja
			If NUE->NUE_SITUAC == '1'
				RecLock( 'NUE', .F. )
				NUE->NUE_CFASE  := cFase
				NUE->NUE_CTAREF := cTarefa
				NUE->NUE_CTAREB := cAtivi
				NUE->NUE_CDOC   := cDocEbCli
				NUE->NUE_CUSERA := JurUsuario(__CUSERID)
				NUE->NUE_ALTDT  := Date()
				If lAltHr
					NUE->NUE_ALTHR := Time()
				EndIf
				NUE->(MsUnlock())

  				//Grava na fila de sincronização a alteração
				J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")
			EndIf
			NUE->( dbSkip() )
		EndDo
	EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148Caso()
Ajuste da tabela de honorários dos casos

@author David Fernandes
@since 07/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA148Caso(oModel, cTabOld )
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaNVE   := NVE->(GetArea())
Local oModelNVE  := FWLoadModel("JURA070")
Local nCount     := 0
Local cMsg       := ""

NVE->(dbSetOrder(1))
NVE->(dbSeek(xFilial("NVE") + oModel:GetValue("SA1MASTER", "A1_COD") + oModel:GetValue("SA1MASTER", "A1_LOJA")))
While ( NVE->(NVE_CCLIEN + NVE_LCLIEN) == oModel:GetValue("SA1MASTER", "A1_COD") + oModel:GetValue("SA1MASTER", "A1_LOJA") )

	If NVE->NVE_CTABH == cTabOld
		oModelNVE:SetOperation(MODEL_OPERATION_UPDATE)
		oModelNVE:Activate()
		JA070MsgRun(.T.)
		oModelNVE:SetValue("NVEMASTER", "NVE_CTABH", oModel:GetValue("NUHMASTER", "NUH_CTABH"))

		If !(oModelNVE:VldData() .And. oModelNVE:CommitData())
			cMsg += NVE->NVE_NUMCAS + CRLF
			lRet := .F.
		Else
			nCount += 1
		EndIf
		JA070MsgRun(.F.)
		oModelNVE:DeActivate()

	EndIf

	NVE->(dbSkip())
End

If !lRet
	MsgAlert( STR0062 + CRLF + cMsg + STR0089 ) //"Falha ao ajustar o(s) seguinte(s) caso(s): " + cMsg + "Verifique!"
Else
	MsgInfo( STR0063 + Alltrim(Str(nCount)) ) // "Núm. de casos alterados: "
EndIf

RestArea(aAreaNVE)
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J148VConta
Valida a aba de contatos, para que não seja escolhido um contato
que esteja inativo.

@author Rafael Rezende Costa
@since 23/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J148VConta(oModel)
Local lRet      := .T.
Local cSit      := ''
Local cContato  := ''
Local nI        := 0
Local oMAC8
Local cCod

Default oModel  := NIL

If oModel <> NIL
	oMAC8:= oModel:GetModel("AC8DETAIL")

	For nI := 1 To oMAC8:GetQtdLine()
		If oMAC8:IsUpdated(nI) .And. !oMAC8:IsDeleted(nI)

			cCod := oMAC8:GetValue("AC8_CODCON", nI)

			If !Empty(cCod)
				cSit :=  JurGetDados("SU5", 1, xFilial("SU5") + cCod, "U5_ATIVO")

				If cSit == '2' // Inativo no cadastro
					cContato := JurGetDados("SU5", 1, xFilial("SU5") + cCod, "U5_CONTAT")
					cContato := Alltrim(cContato)

					lRet := .F.

					If !Empty( cContato )
						//JurMsgErro("O Contato de número "+ alltrim(cCod) + " ( "+cContato  +" ) não pode ser utilizado porque está inativo...")//"Realize o Ajuste Necessário"
						JurMsgErro(STR0073 + Alltrim(cCod) + STR0074 + cContato + STR0075 + STR0076,, STR0097)
					Else
						//JurMsgErro("O Contato de número "+ alltrim(cCod) + " não pode ser utilizado porque está inativo...")//"Realize o Ajuste Necessário"
						JurMsgErro(STR0073 + Alltrim(cCod) + STR0076,, STR0097)
					EndIf

					Exit
				EndIf
			EndIf

		EndIf
	Next

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J148vTpSer
Verifica se os campos de tipo de serviço podem ser preenchidos dependendo do parametro de fluxo de correspondente.
Uso nos campos NZB_CTPSER\NZB_REEMBO\NRO_CTPSER

@return 	lRet - .T./.F. As informações são válidas ou não

@author		Rafael Tenorio da Costa
@since 		27/04/15
@version	1.0
/*/
//-------------------------------------------------------------------
Function J148vTpSer(cConteudo)
	Local lRet       := .T.
	Local nFlxCorres := SuperGetMV("MV_JFLXCOR", , 1) //Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"

	If nFlxCorres == 2
		If !Empty(cConteudo)
			lRet := JurMsgErro(STR0082,, STR0098) //Fluxo de correspondente configurado para ser preenchido no Assunto Jurídico, por isso esse campo não deverá ser preenchido.\\ Verifique o parâmetro MV_JFLXCOR."
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J148ArPart()
Função para pré arredondar um percentual de participação.

@Return - nRet - Valor Arredondado ou o próprio valor.

@author Bruno Ritter
@since 14/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J148ArPart()
	Local oModel     := FWModelActive()
	Local cAlias     := SubStr(ReadVar(), 4, 3)
	Local cTipoOrig  := Iif(cAlias == "NU9", oModel:GetValue("NU9DETAIL", "NU9_CTIPO"), oModel:GetValue("NUDDETAIL", "NUD_CTPORI"))
	Local nPerc      := oModel:GetValue(cAlias + "DETAIL", cAlias + "_PERC")
	Local nRet       := 0

	nRet := JurArrPart(cAlias + "_PERC", nPerc, cTipoOrig)

	If (nRet != nPerc)
		oModel:LoadValue(cAlias + "DETAIL", cAlias + "_PERC", nRet)
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J148VldFlg
Validações do cadastro de Clientes para a Integração com Fluig

@return     .T.
@author		Willian Kazahaya
@since 		06/07/2017
@version	1.0
/*/
//-------------------------------------------------------------------
Function J148VldFlg(oModel)
	If (oModel:GetValue("NUHMASTER", "NUH_CASAUT") = '2') .Or. (Empty(oModel:GetValue("NUHMASTER", "NUH_CIDIO")))
		MsgInfo(STR0090, STR0091)
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA148COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA148COMMIT FROM FWModelEvent
	Data cTabHonOld
	Data lUpdGrp

	Method New()
	Method Before()
	Method InTTS()
	Method After()
	Method Destroy()
End Class

Method New() Class JA148COMMIT
	self:cTabHonOld := ""
	self:lUpdGrp    := .F.
Return

Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class JA148COMMIT
	AvaliaPre(oSubModel:GetModel(), cModelId, cAlias, lNewRecord, @self:cTabHonOld, @self:lUpdGrp)
Return

Method After(oSubModel, cModelId, cAlias, lNewRecord) Class JA148COMMIT
	AvaliaPos(oSubModel:GetModel(), cModelId, cAlias, lNewRecord)
Return

Method InTTS(oSubModel, cModelId) Class JA148COMMIT
	JURA148CM(oSubModel:GetModel(), @self:cTabHonOld, @self:lUpdGrp)
	J148FSinc(oSubModel:GetModel())
Return

Method Destroy() Class JA148COMMIT
	self:cTabHonOld   := Nil
	self:lUpdGrp      := Nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J148ValNeg
Valida valor negativo quando a regra for do tipo Fixo

@Obs Chamada no dicionário e na pós validação da linha

@author Abner Fogaça / Cristina Cintra
@since 05/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J148ValNeg(cCampo, oModelOHO)
Local lRet        := .T.
Local oModel      := Nil
Local cRegra      := ""
Local nValor      := 0

Default oModelOHO := Nil

If oModelOHO == Nil
	oModel    := FWModelActive()
	oModelOHO := oModel:GetModel('OHODETAIL')
EndIf

cRegra := oModelOHO:GetValue("OHO_REGRA")
nValor := oModelOHO:GetValue("OHO_VALOR")

If !Empty(cRegra) .And. (cRegra == '3') // Fixo
	If nValor < 0 
		lRet := JurMsgErro(STR0094, , i18N(STR0095, {Alltrim(RetTitle(cCampo))} )) //"Para o tipo de Regra 'Fixo' não é permitido valor negativo." / "Verifique o campo ('#1')."
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J148ExHist
Verifica se existe algum registro válido no grid de participante ou
histórico do participante

@param oModel, Modelo de dados de Clientes

@return lRet, .T. Existe um registro válido / .F. Não existe nenhum registro

@author Abner Fogaça
@since 30/11/2018
/*/
//-------------------------------------------------------------------
Static Function J148ExHist(oModel)
	Local lRet      := .F.
	Local nI        := 0
	Local oGridNU9  := oModel:GetModel("NU9DETAIL")
	Local oGridNUD  := Nil
	Local nQtdLnNU9 := oGridNU9:GetQtdLine()
	Local nQtdLnNUD := 0

	For nI := 1 To nQtdLnNU9
		If !oGridNU9:IsDeleted(nI) .And. !oGridNU9:IsEmpty(nI)
			lRet := .T.
			Exit
		EndIf
	Next

	If !lRet
		oGridNUD  := oModel:GetModel():GetModel("NUDDETAIL")
		nQtdLnNUD := oGridNUD:GetQtdLine()
		For nI := 1 To nQtdLnNUD
			If !oGridNUD:IsDeleted(nI) .And. !oGridNUD:IsEmpty(nI)
				lRet := .T.
				Exit
			EndIf
		Next
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J148JurCSA1
Retorna array com campos da SA1 que são utilizados no cadastro pelo sigajuri

@Return aCampos array com campos que serão utilizados no cadastro

@author Brenno Gomes
@since 31/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J148JurCSA1()
	Local aCampos := {}

	aAdd(aCampos, "A1_COD")
	aAdd(aCampos, "A1_LOJA")
	aAdd(aCampos, "A1_NOME")
	aAdd(aCampos, "A1_PESSOA")
	aAdd(aCampos, "A1_END")
	aAdd(aCampos, "A1_NREDUZ")
	aAdd(aCampos, "A1_TIPO")
	aAdd(aCampos, "A1_EST")
	aAdd(aCampos, "A1_ESTADO")
	aAdd(aCampos, "A1_CEP")
	aAdd(aCampos, "A1_COD_MUN")
	aAdd(aCampos, "A1_MUN")
	aAdd(aCampos, "A1_DDD")
	aAdd(aCampos, "A1_TEL")
	aAdd(aCampos, "A1_CONTATO")
	aAdd(aCampos, "A1_CGC")
	aAdd(aCampos, "A1_INSCR")
	aAdd(aCampos, "A1_INSCRM")
	aAdd(aCampos, "A1_EMAIL")
	aAdd(aCampos, "A1_CNAE")
	aAdd(aCampos, "A1_MSBLQL")

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} J148JurCNUH
Retorna array com campos da tabela NUH que são utilizados no cadastro pelo sigajuri

@Return aCampos array com campos que serão utilizados no cadastro

@author Brenno Gomes
@since 31/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J148JurCNUH()
	Local aCampos := {}

	aAdd(aCampos, "NUH_SIGLA")
	aAdd(aCampos, "NUH_CIDIO")
	aAdd(aCampos, "NUH_ATIVO")
	aAdd(aCampos, "NUH_OBSCAD")
	aAdd(aCampos, "NUH_NIRE")
	
Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} J148Sheet
Função para criar aba na tela de clientes através do ponto de entrada

@param oModel, objeto, Estrutura do modelo de dados de clientes
@param oView , objeto, Estrutura da tela de clientes

@author Jonatas Martins
@since  04/05/2019
/*/
//-------------------------------------------------------------------
Static Function J148Sheet(oModel, oView)
	Local cSheetName := "DEFAULT"
	Local cTablePE   := ""
	Local cModelID   := ""
	Local cViewID    := ""
	Local cOrder     := ""
	Local aSheet     := {}
	Local aRelation  := {}
	Local aRemovePE  := {}
	Local aUniqueLin := {}
	Local nIndexPE   := 1
	Local nField     := 0
	Local lGrid      := .F.
	Local oMStructPE := Nil
	Local oVStructPE := Nil
	
	aSheet := ExecBlock("J148Sheet", .F., .F.)

	If ValType(aSheet) == "A" .And. Len(aSheet) >= 5 .And. !Empty(aSheet[2])
		aRelation := aSheet[4]

		If ValType(aRelation) == "A" .And. Len(aRelation) == 2
			cSheetName := IIF(ValType(aSheet[1]) <> "C" .Or. Empty(aSheet[1]), cSheetName, AllTrim(aSheet[1]))
			cTablePE   := AllTrim(SubStr(aSheet[2], 1, 3))
			lGrid      := IIF(ValType(aSheet[3]) <> "L", .F., aSheet[3])
			cModelID   := cTablePE + IIF(lGrid, "DETAIL", "MASTER")
			cViewID    := cTablePE + "_VIEW"
			nIndexPE   := IIF(ValType(aSheet[5]) <> "N", nIndexPE, aSheet[5])
			aRelation  := {{cTablePE + "_FILIAL", "xFilial('" + cTablePE + "')"},;
							{aRelation[1], "A1_COD"},;
							{aRelation[2], "A1_LOJA"}}
			
			// Monta esturura do Model
			oMStructPE := FWFormStruct(1, cTablePE)
			If lGrid
				oModel:AddGrid(cModelID, "SA1MASTER", oMStructPE)
				oModel:SetOptional(cModelID, .T.)
				aUniqueLin := IIF(Len(aSheet) >= 7, aSheet[7], Nil)
				If ValType(aUniqueLin) == "A"
					oModel:GetModel(cModelID):SetUniqueLine(aUniqueLin)
				EndIf
			Else
				oModel:AddFields(cModelID, "SA1MASTER", oMStructPE)
			EndIf
			cOrder := &(cTablePE)->(IndexKey(nIndexPE))
			oModel:SetRelation(cModelID, aRelation, cOrder)
			oModel:GetModel(cModelID):SetDescription(cSheetName + STR0103) // "Ponto de Entrada"

			// Monta estutura do View
			oVStructPE := FWFormStruct(2, cTablePE)
			oVStructPE:RemoveField(aRelation[2][1])
			oVStructPE:RemoveField(aRelation[3][1])
			If lGrid
				oView:AddGrid(cViewID, oVStructPE, cModelID)
				// Campo de incremento
				If Len(aSheet) == 8 .And. !Empty(aSheet[8])
					oView:AddIncrementField(cModelID, aSheet[8])
				EndIf
			Else
				oView:AddField(cViewID, oVStructPE, cModelID)
			EndIf
			//Remove campos da View
			aRemovePE := IIF(Len(aSheet) >= 6 .And. ValType(aSheet[6]) == "A", aSheet[6], Nil)
			For nField := 1 To Len(aRemovePE)
				If !Empty(aRemovePE[nField])
					oVStructPE:RemoveField(aRemovePE[nField])
				EndIf
			Next nField
			oView:AddSheet("FOLDER_01", "SHEET_PE", cSheetName)
			oView:createHorizontalBox("BOXPE", 100,,, "FOLDER_01", "SHEET_PE")
			oView:SetOwnerView(cViewID, "BOXPE")
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J148VLDSGL
Função para validar a sigla do participante.

@param cCampo campo de Sigla para validação dentro do funte JURA148

@author Victor Hayashi
@since  23/11/2020
/*/
//-------------------------------------------------------------------
Function J148VLDSGL(cCampo)
	Local lRet := .T.

	lRet := (ExistCpo('RD0', FwFldGet(cCampo), 9) .And. JURRD0('NUHMASTER', cCampo, '3', .T.))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J148VLDCOD
Função para validar o codigo do participante.

@param cCampo campo de codigo para validação dentro do funte JURA148

@author Victor Hayashi
@since  23/11/2020
/*/
//-------------------------------------------------------------------
Function J148VLDCOD(cCampo)
	Local lRet := .T.

	lRet := IIF(JurIsRest(), (ExistCpo('RD0', FwFldGet(cCampo), 1) .And. JURRD0('NUHMASTER', cCampo, '3')), .T.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAltClien
Retorna o conteúdo da variável lAltClien, referente a opção de réplica 
das informações alteradas para contratos e pagadores. E também o aDados,
variável estática contendo os campos que sofreram alteração.
Uso em Ponto de Entrada.
@return aRotina - Estrutura
[1] lAltClien, boolean, Confirmada a replica dos dados
[2] aDados,    array,   Dados alterados, estrutura
                        [n, 1] - Nome do campo
						[n, 2] - Valor Anterior
						[n, 3] - Novo Valor 
@author SIGAPFS
@since 28/07/2021
/*/
//-------------------------------------------------------------------
Function GetAltClien()

Return {lAltClien, aDados}

//-------------------------------------------------------------------
/*/{Protheus.doc} JA148Ebi
Filtro para as consultas padrão NS0NUH, NRYNUH e NRZNUH.

@param  cOption  "1" - NS0NUH, "2" - NRYNUH, "3" - NRZNUH

@return cRet     Comando para filtro

@obs Filtro das consultas padrão NS0NUH, NRYNUH e NRZNUH.

@author Jorge Martins
@since  04/01/2022
/*/
//-------------------------------------------------------------------
Function JA148Ebi(cOption)
Local cRet := "@#@#"

	If cOption == "1" // Consulta NS0NUH - Atividade Ebilling
		cRet := "@#NS0->NS0_CDOC=='" + JAEMPEBILL(SA1->A1_COD, SA1->A1_LOJA) + "'@#"
	ElseIf cOption == "2" // Consulta NRYNUH - Fase Ebilling
		cRet := "@#NRY->NRY_CDOC=='" + JAEMPEBILL(SA1->A1_COD, SA1->A1_LOJA) + "'@#"
	ElseIf cOption == "3" // Consulta NRZNUH - Tarefa Ebilling
		cRet := "@#NRZ->NRZ_CDOC=='" + JAEMPEBILL(SA1->A1_COD, SA1->A1_LOJA) + "'.AND.NRZ->NRZ_CFASE=='" + JA148VTAEB() + "'@#"
	EndIf

Return cRet
