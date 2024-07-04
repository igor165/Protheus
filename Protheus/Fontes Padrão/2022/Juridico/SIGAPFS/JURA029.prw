#INCLUDE "JURA029.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDef.ch"

Static _lAutomato := .F.
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA029
Idioma de Faturamento

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA029()
	Local oBrowse

	Jr209StAut(.F.) //Desativa execução do robô
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )
	oBrowse:SetAlias( "NR1" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "NR1" )
	JurSetBSize( oBrowse )
	oBrowse:Activate()

Return NIL

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

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA029", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA029", 0, 3, 0, NIL } ) // "Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA029", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA029", 0, 5, 0, NIL } ) // "Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA029", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Idioma de Faturamento

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel     := FWLoadModel( "JURA029" )
	Local oStruct    := FWFormStruct( 2, "NR1" ) // Dados de Idioma de Faturamento
	Local oStructNR2 := FWFormStruct( 2, "NR2" ) // Desc. Cat. Prof. por Idioma
	Local oStructNR3 := FWFormStruct( 2, "NR3" ) // Desc Itens tabelados p/ Idioma
	Local oStructNR4 := FWFormStruct( 2, "NR4" ) // Desc Tp Desp por Idioma
	Local oStructNR5 := FWFormStruct( 2, "NR5" ) // Desc Tp Ativ por Idioma
	Local oStructNYY := FWFormStruct( 2, "NYY" ) // Tarifador - Descrição por Tipo Despesa

	oStructNR2:RemoveField( 'NR2_CIDIOM' )
	oStructNR3:RemoveField( 'NR3_CIDIOM' )
	oStructNR4:RemoveField( 'NR4_CIDIOM' )
	oStructNR5:RemoveField( 'NR5_CIDIOM' )
	oStructNYY:RemoveField( 'NYY_CIDIOM' )
	oStructNR2:RemoveField( 'NR2_DIDIOM' )
	oStructNR3:RemoveField( 'NR3_DIDIOM' )
	oStructNR4:RemoveField( 'NR4_DIDIOM' )
	oStructNR5:RemoveField( 'NR5_DIDIOM' )
	oStructNYY:RemoveField( 'NYY_DIDIOM' )

	JurSetAgrp( 'NR1',, oStruct )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA029_VIEW", oStruct, "NR1MASTER" )
	oView:AddGrid( "JURA029_GRIDNR2", oStructNR2, "NR2DETAIL" )
	oView:AddGrid( "JURA029_GRIDNR3", oStructNR3, "NR3DETAIL" )
	oView:AddGrid( "JURA029_GRIDNR4", oStructNR4, "NR4DETAIL" )
	oView:AddGrid( "JURA029_GRIDNR5", oStructNR5, "NR5DETAIL" )
	oView:AddGrid( "JURA029_GRIDNYY", oStructNYY, "NYYDETAIL" )

	oView:CreateHorizontalBox( "FORMFIELD" , 20 )
	oView:CreateHorizontalBox( "FORMFOLDER", 80 )

	oView:CreateFolder('FOLDER_01',"FORMFOLDER")
	oView:AddSheet('FOLDER_01','ABA_NR2', STR0010)
	oView:AddSheet('FOLDER_01','ABA_NR3', STR0011)
	oView:AddSheet('FOLDER_01','ABA_NR4', STR0012)
	oView:AddSheet('FOLDER_01','ABA_NR5', STR0013)
	oView:AddSheet('FOLDER_01','ABA_NYY', STR0019)

	oView:CreateHorizontalBox("FORMFOLDER_NR2",100,,,'FOLDER_01','ABA_NR2')
	oView:CreateHorizontalBox("FORMFOLDER_NR3",100,,,'FOLDER_01','ABA_NR3')
	oView:CreateHorizontalBox("FORMFOLDER_NR4",100,,,'FOLDER_01','ABA_NR4')
	oView:CreateHorizontalBox("FORMFOLDER_NR5",100,,,'FOLDER_01','ABA_NR5')
	oView:CreateHorizontalBox("FORMFOLDER_NYY",100,,,'FOLDER_01','ABA_NYY')

	oView:SetOwnerView( "JURA029_VIEW"   , "FORMFIELD" )
	oView:SetOwnerView( "JURA029_GRIDNR2", "FORMFOLDER_NR2" )
	oView:SetOwnerView( "JURA029_GRIDNR3", "FORMFOLDER_NR3" )
	oView:SetOwnerView( "JURA029_GRIDNR4", "FORMFOLDER_NR4" )
	oView:SetOwnerView( "JURA029_GRIDNR5", "FORMFOLDER_NR5" )
	oView:SetOwnerView( "JURA029_GRIDNYY", "FORMFOLDER_NYY" )

	oView:SetDescription( STR0007 ) // "Idioma de Faturamento"
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Idioma de Faturamento

@author Felipe Bonvicini Conti
@since 28/04/09
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStruct    := FWFormStruct( 1, "NR1" )
	Local oStructNR2 := FWFormStruct( 1, 'NR2' )
	Local oStructNR3 := FWFormStruct( 1, 'NR3' )
	Local oStructNR4 := FWFormStruct( 1, 'NR4' )
	Local oStructNR5 := FWFormStruct( 1, 'NR5' )
	Local oStructNYY := FWFormStruct( 1, 'NYY' )
	Local oCommit    := JA029COMMIT():New()

	oStructNR2:RemoveField( 'NR2_CIDIOM' )
	oStructNR3:RemoveField( 'NR3_CIDIOM' )
	oStructNR4:RemoveField( 'NR4_CIDIOM' )
	oStructNR5:RemoveField( 'NR5_CIDIOM' )
	oStructNYY:RemoveField( 'NYY_CIDIOM' )
	oStructNR2:RemoveField( 'NR2_DIDIOM' )
	oStructNR3:RemoveField( 'NR3_DIDIOM' )
	oStructNR4:RemoveField( 'NR4_DIDIOM' )
	oStructNR5:RemoveField( 'NR5_DIDIOM' )
	oStructNYY:RemoveField( 'NYY_DIDIOM' )

	If _lAutomato
		//Desabilita o When do campo para o caso de automação
		oStructNYY:SetProperty( 'NYY_CODCFG', MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, ".T." ))
	EndIf

	oModel := MPFormModel():New( "JURA029", /*Pre-Validacao*/, { | oX | JA029TUDOK( oX ) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields( "NR1MASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:AddGrid( 'NR2DETAIL', 'NR1MASTER' /*cOwner*/, oStructNR2, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:AddGrid( 'NR3DETAIL', 'NR1MASTER' /*cOwner*/, oStructNR3, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:AddGrid( 'NR4DETAIL', 'NR1MASTER' /*cOwner*/, oStructNR4, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:AddGrid( 'NR5DETAIL', 'NR1MASTER' /*cOwner*/, oStructNR5, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:AddGrid( 'NYYDETAIL', 'NR1MASTER' /*cOwner*/, oStructNYY, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

	oModel:SetDescription( STR0008 ) // "Modelo de Dados de Idioma de Faturamento"
	oModel:GetModel( "NR1MASTER" ):SetDescription( STR0009 ) // "Dados de Idioma de Faturamento"
	oModel:GetModel( 'NR2DETAIL' ):SetUniqueLine( { 'NR2_CATPAR' } )
	oModel:GetModel( 'NR3DETAIL' ):SetUniqueLine( { 'NR3_CITABE' } )
	oModel:GetModel( 'NR4DETAIL' ):SetUniqueLine( { 'NR4_CTDESP' } )
	oModel:GetModel( 'NR5DETAIL' ):SetUniqueLine( { 'NR5_CTATV'  } )
	oModel:GetModel( 'NYYDETAIL' ):SetUniqueLine( { 'NYY_CODCFG', 'NYY_TIPO' } )
	oModel:SetRelation( 'NR2DETAIL', { { 'NR2_FILIAL', "XFILIAL('NR2')" }, { 'NR2_CIDIOM', 'NR1_COD' } }, NR2->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'NR3DETAIL', { { 'NR3_FILIAL', "XFILIAL('NR3')" }, { 'NR3_CIDIOM', 'NR1_COD' } }, NR3->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'NR4DETAIL', { { 'NR4_FILIAL', "XFILIAL('NR4')" }, { 'NR4_CIDIOM', 'NR1_COD' } }, NR4->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'NR5DETAIL', { { 'NR5_FILIAL', "XFILIAL('NR5')" }, { 'NR5_CIDIOM', 'NR1_COD' } }, NR5->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'NYYDETAIL', { { 'NYY_FILIAL', "XFILIAL('NYY')" }, { 'NYY_CIDIOM', 'NR1_COD' } }, NYY->( IndexKey( 1 ) ) )

	oModel:InstallEvent("JA029COMMIT", /*cOwner*/, oCommit)

	oModel:SetOptional( "NR2DETAIL", .T.)
	oModel:SetOptional( "NR3DETAIL", .T.)
	oModel:SetOptional( "NR4DETAIL", .T.)
	oModel:SetOptional( "NR5DETAIL", .T.)
	oModel:SetOptional( "NYYDETAIL", .T.)

	JurSetRules( oModel, 'NR1MASTER',, 'NR1' )
	JurSetRules( oModel, 'NR2DETAIL',, 'NR2' )
	JurSetRules( oModel, 'NR3DETAIL',, 'NR3' )
	JurSetRules( oModel, 'NR4DETAIL',, 'NR4' )
	JurSetRules( oModel, 'NR5DETAIL',, 'NR5' )
	JurSetRules( oModel, 'NYYDETAIL',, 'NYY' )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA029COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Cristina Cintra Santos
@since 18/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA029COMMIT FROM FWModelEvent
	Method New()
	Method InTTS()
	Method Activate()
End Class

Method New() Class JA029COMMIT
Return

Method InTTS(oSubModel, cModelId) Class JA029COMMIT
	JFILASINC(oSubModel:GetModel(), "NR1", "NR1MASTER", "NR1_COD")
Return  
//-------------------------------------------------------------------
/*/{Protheus.doc} Activate()
Metodo de ativação do modelo.

@Param oView View de dados do idioma de fatura

@author Victor Hayashi
@since 13/11/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Method Activate(oView) Class JA029COMMIT
	JA029Carga( oView )
Return

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA029TUDOK
Executa as rotinas ao confirmar as alteração no Model.

@author Felipe Bonvicini Conti
@since 14/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA029TUDOK ( oModel )
	Local lRet      := .T.
	Local oModelNR2 := oModel:GetModel( "NR2DETAIL" )
	Local oModelNR3 := oModel:GetModel( "NR3DETAIL" )
	Local oModelNR4 := oModel:GetModel( "NR4DETAIL" )
	Local oModelNR5 := oModel:GetModel( "NR5DETAIL" )
	Local oModelNYY := oModel:GetModel( "NYYDETAIL" )

	If (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4)
		Do Case
		Case JurValidLine(oModelNR2, 'NR2_CATPAR') < JurQtdReg('NRN', "NRN_ATIVO = '1'")
			JurMsgErro( STR0014 )// É preciso incluir o idioma para todas as Categorias de Profissionais
			lRet := .F.
		Case JurValidLine(oModelNR3, 'NR3_CITABE') < JurQtdReg('NRD', "NRD_ATIVO = '1'")
			JurMsgErro( STR0015 )// É preciso incluir o idioma para todos os Itens tabelados
			lRet := .F.
		Case JurValidLine(oModelNR4, 'NR4_CTDESP') < JurQtdReg('NRH', "NRH_ATIVO = '1'")
			JurMsgErro( STR0016 )// É preciso incluir o idioma para todos os Tipos de Despesas
			lRet := .F.
		Case JurValidLine(oModelNR5, 'NR5_CTATV') < JurQtdReg('NRC', "NRC_ATIVO = '1'")
			JurMsgErro( STR0017 )// É preciso incluir o idioma para todos os Tipos de Atividades
			lRet := .F.
		Case JurValidLine(oModelNYY, 'NYY_TIPO') < JurQtdReg('NYV', "NYV_CODCFG IN ( SELECT NYT_COD FROM " + RetSqlName("NYT") + " WHERE NYT_FILIAL = '" + xFilial("NYT") + "' AND  D_E_L_E_T_ = ' ' AND NYT_ATIVO  = '1' ) AND NYV_TIPO IN ( SELECT NRH_COD FROM " + RetSqlName("NRH") +"  WHERE NRH_FILIAL = '" + xFilial("NRH") + "' AND D_E_L_E_T_ = ' ' AND NRH_ATIVO = '1' ) ")
			JurMsgErro( STR0020 )// É preciso incluir o idioma para todas as configurações por Tipos de Despesas
			lRet := .F.
		End Case
		
		If(lRet .And. JurValidLine(oModelNR4, 'NR4_CTDESP') > 0, lRet := JurVldDesc(oModelNR4, { "NR4_DESC" } ), )
		If(lRet .And. JurValidLine(oModelNR5, 'NR5_CTATV') > 0, lRet := JurVldDesc(oModelNR5, { "NR5_DESC" } ), )

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURVALIDLINE
Retorna a quantidade de linhas validas no model

@param 	oModel		Model
@Return nQtd		Quantidade de linhas validas

@author Felipe Bonvicini Conti
@since 15/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurValidLine(oModel, cChave)
	Local nLinha
	Local nDeleted := 0
	Local nQtd     := oModel:GetQtdLine()

	For nLinha := 1 To nQtd
		If oModel:IsDeleted( nLinha ) .Or. Empty(oModel:GetValue(cChave))
			nDeleted ++
		EndIf
	Next

Return nQtd-nDeleted

//-------------------------------------------------------------------
/*/{Protheus.doc} JA029VLATI
Retorna se o valor digitado/selecionado está ativo

@Param 	cTabela		Tabela a ser verificada
@Param 	cCampo		Nome do campo que contem a informação de ativo/inativo
@Param 	cCodigo		Codigo para referencia da procura
@Return lRet		.T./.F.

@author Jacques Alves Xavier
@since 26/07/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA029VLATI(cTabela, cCampo, cCodigo)
	Local lRet

	lRet := Iif(GetAdvFVal( cTabela, cCampo, xFilial(cTabela) + cCodigo ) == '1', .T., .F.)
	If !lRet 
		JurMsgErro( STR0018 ) // Registro inativo, favor verificar!
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/ { Protheus.doc } JA029Carga
Carrega as informações das grids de Categoria, Tabelados, Tipo de despesa,
Tipo de Atividade e Tarifador para facilitar a criação e manutenção dos
idiomas.

@param oView - Objeto View

@author Victor Hayashi
@since 13/11/2020
/*/
//-------------------------------------------------------------------
Static Function JA029Carga( oView )
	Local aArea      := GetArea()
	Local aTabelas   := {}
	Local oModel     := FWModelActive()
	Local nOperation := oModel:GetOperation()

	If nOperation == 3 
	
		/* Categorias de Participante */
		aAdd(aTabelas, {"NRN", "NR2", "NR2DETAIL", "NR2_CATPAR", {"NRN_COD","NRN_DESC"}, {"NR2_DESC"}})

		/* Itens Tabelados */
		aAdd(aTabelas, {"NRD", "NR3", "NR3DETAIL", "NR3_CITABE", {"NRD_COD","NRD_DESCH","NRD_DESCD"}, {"NR3_DESCHO","NR3_DESCDE","NR3_NARRAP"} })

		/* Tipos de Despesa */
		If( NR4->(ColumnPos("NR4_TXTPAD")) > 0 )
			aAdd(aTabelas, {"NRH", "NR4", "NR4DETAIL", "NR4_CTDESP", {"NRH_COD","NRH_DESC"}, {"NR4_DESC"}})
		Else
			aAdd(aTabelas, {"NRH", "NR4", "NR4DETAIL", "NR4_CTDESP", {"NRH_COD","NRH_DESC"}, {"NR4_DESC"}})
		EndIf

		/* Tipos de Atividade */
		aAdd(aTabelas, {"NRC", "NR5", "NR5DETAIL", "NR5_CTATV", {"NRC_COD","NRC_DESC"}, {"NR5_DESC"}})

		/* Tarifador */
		aAdd(aTabelas, {"NYV", "NYY", "NYYDETAIL", "NYY_TIPO", {"NYV_CODCFG","NYV_TIPO","NRH_DESC"}, {"NYY_CODCFG","NYY_TIPO","NYY_DESC"}})

		oView := JA029CgTab(oView, aTabelas)

		RestArea( aArea )
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA029CgTab
Carrega as informações das grids de idiomas, considerando as informações
do parâmetro.

@param oView - Objeto View
@param aTabelas - Tabelas das Grids a serem preenchidas

@author Victor Hayashi
@since 13/11/2020
/*/
//-------------------------------------------------------------------
Static Function JA029CgTab(oView, aTabelas)
	Local aArea      := GetArea()
	Local aSaveLines := FWSaveRows()
	Local cQuery     := ""
	Local cTrb       := ""
	Local oModelGrid := Nil
	Local nPosCpo    := 1
	Local nPos       := 0
	Local nI         := 0
	Local nX         := 0
	Local nY         := 0
	Local nLines     := 0
	Local aCols      := {}
	Local cCpoCod    := ""
	Local cCpoFil    := ""
	Local cCpoAtv    := ""
	Local cOrder     := ""
	Local cTabOri    := ""
	Local aDescDest  := {}

	For nI := 1 To Len(aTabelas)
		cTrb       := GetNextAlias()
		aCols      := {}
		cTabOri    := Alltrim(aTabelas[nI][1])
		cCpoCod    := aTabelas[nI][5][1]
		cCpoFil    := Alltrim(cTabOri) + "_FILIAL"
		cCpoAtv    := Alltrim(cTabOri) + "_ATIVO"
		cOrder     := cCpoFil + ", " + cCpoCod
		cCampoDest := Alltrim(aTabelas[nI][4])
		cModelo    := aTabelas[nI][3]
		aDescDest  := aTabelas[nI][6]

		cQuery := "SELECT "

		//Laco para montar os campos da query
		For nY := 1 to len(aTabelas[nI][5])
			If nY == len(aTabelas[nI][5])
				cQuery += aTabelas[nI][5][nY]
			Else
				cQuery += aTabelas[nI][5][nY] + ", "
			EndIf			
		Next

		cQuery += " FROM " + RetSqlName( cTabOri ) + " " + cTabOri + " "

		If cTabOri == "NYV"
			cQuery += "INNER JOIN  " + RetSqlName( "NRH" ) + " NRH ON NRH_FILIAL = '" + xFilial( "NRH" ) +"'"
			cQuery += " AND NRH_COD = NYV_TIPO"
			cQuery += " AND NRH.D_E_L_E_T_ = ' ' "
			cQuery += " AND NRH_ATIVO  = '1' "
			cQuery += "INNER JOIN  " + RetSqlName( "NYT" ) + " NYT ON NYT_FILIAL = '" + xFilial( "NYT" ) +"'"
			cQuery += " AND NYV_CODCFG = NYT_COD"
			cQuery += " AND NYT.D_E_L_E_T_ = ' ' "
			cQuery += " AND NYT_ATIVO  = '1' "
		EndIf

		cQuery += "WHERE " + cCpoFil + " = '" + xFilial( cTabOri ) + "' "
		
		If cTabOri != "NYV"
			cQuery +=   " AND " + cCpoAtv + " = '1' "
		EndIf

		cQuery +=   " AND " + cTabOri + ".D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY " + cOrder

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTrb, .T., .F. )
		(cTrb)->( dbSelectArea( cTrb ) )
		(cTrb)->( dbGoTop() )

		oModelGrid := oView:GetModel(cModelo)
		nLines     := oModelGrid:GetQtdLine()

		For nX := 1 To nLines
			If cTabOri == "NYV"
				aAdd(aCols, {oModelGrid:GetValue("NYY_CODCFG", nX) + oModelGrid:GetValue(cCampoDest, nX)})
			Else
				aAdd(aCols, {oModelGrid:GetValue(cCampoDest, nX)})
			EndIf
		Next

		While !(cTrb)->( EOF() )

			If cTabOri == "NYV"
				nPos := aScan( aCols, { | x | x[nPosCpo] == &((cTrb)->(cCpoCod)) + (cTrb)->NYV_TIPO } )
			Else
				nPos := aScan( aCols, { | x | x[nPosCpo] == &((cTrb)->(cCpoCod)) } )
			EndIf

			If nPos > 0
				oModelGrid:GoLine( nPos )
				If oModelGrid:IsDeleted( nPos )
					oModelGrid:UnDeleteLine()
				EndIf
			Else
				If nLines == 1 .And. Empty(oModelGrid:GetValue(cCampoDest))
					oModelGrid:GoLine( 1 )
				ElseIf nPos == 0
					oModelGrid:AddLine( )
				EndIf
				oModelGrid:SetValue(cCampoDest, &((cTrb)->(cCpoCod)))

				//Laco para preenchimento do(s) campo(s) de descricao(oes)
				For nY := 1 to Len(aDescDest)
					If cTabOri == "NYV"
						oModelGrid:SetValue(aDescDest[nY], Alltrim( &((cTrb)->(aTabelas[nI][5][nY]))))
					ElseIf cTabOri $ "NRC|NRH"
						oModelGrid:SetValue(aDescDest[nY],Alltrim( &((cTrb)->(aTabelas[nI][5][2]))))
					ElseIf cTabOri == "NRD"
						If aDescDest[nY] == "NR3_NARRAP"
							oModelGrid:SetValue(aDescDest[nY], JurGetDados("NRD",1,xFilial("NRD") + &((cTrb)->(cCpoCod)),"NRD_NARRAT"))
						Else
							oModelGrid:SetValue(aDescDest[nY], Alltrim( &((cTrb)->(aTabelas[nI][5][nY+1]))))
						EndIf
					Else
						oModelGrid:SetValue(aDescDest[nY], Alltrim( &((cTrb)->(aTabelas[nI][5][nY+1]))))
					EndIf
				Next

			EndIf

			(cTrb)->( dbSkip() )
		EndDo
		oModelGrid:GoLine( 1 )
		(cTrb)->( dbCloseArea() )

	Next nI

	FWRestRows( aSaveLines )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } Jr209StAut
Carrega a variável estática de execução da automação
do parâmetro.

@param lPar - Valor a ser carregado

@return _lAutomato  - Conteuúdo da variável estática _lAutomato

@author Victor Hayashi
@since 13/11/2020
/*/
//-------------------------------------------------------------------
Function Jr209StAut(lPar)
	Default lPar := _lAutomato

	_lAutomato := lPar
	
Return _lAutomato 
