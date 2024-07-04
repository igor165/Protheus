#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#Include "Protheus.ch"
#INCLUDE "OFIA210.CH"

Function OFIA210()

	Local cFiltro   := ""
	Local aSize     := FWGetDialogSize( oMainWnd )

	VAI->(dbSetOrder(4))
	VAI->(MsSeek(xFilial("VAI")+__cUserID)) // Posiciona no VAI do usuario logado

	Private cCadastro := STR0001 // Solicitação de Peças Oficina

	Private cMark     := GetMark()

	cFiltro += "@ EXISTS ( "
	cFiltro += 			" SELECT * "
	cFiltro += 			" FROM ( "
	cFiltro += 					" SELECT VSJ.VSJ_CODIGO, "
	cFiltro += 						" VSJ.VSJ_NUMOSV, "
	cFiltro += 						" VSJ.VSJ_ORIDAD, "
	cFiltro += 						" VSJ.VSJ_TIPTEM, "
	cFiltro += 						" VSJ.VSJ_FATPAR, "
	cFiltro += 						" VSJ.VSJ_LOJA, "
	cFiltro += 						" VSJ.VSJ_GRUITE, "
	cFiltro += 						" VSJ.VSJ_CODITE, "
	cFiltro += 						" VSJ.VSJ_QTDITE, "
	cFiltro += 						" VSJ.VSJ_OPER, "
	cFiltro += 						" VSJ.VSJ_CODTES, "
	cFiltro += 						" VSJ.VSJ_RESPEC, "
	cFiltro += 						" SUM( VM4_QTSOLI ) AS QTDVM4 "
	cFiltro += 					" FROM " + RetSqlName("VSJ") + " VSJ "
	cFiltro += 					" LEFT JOIN " + RetSqlName("VM4") + " VM4 "
	cFiltro += 						"  ON VM4.VM4_FILIAL = '" + xFilial("VM4") + "' "
	cFiltro += 						" AND VM4.VM4_CODVSJ = VSJ.VSJ_CODIGO "
	cFiltro += 						" AND VM4.D_E_L_E_T_ = ' ' "
	cFiltro += 					" LEFT JOIN " + RetSqlName("VM3") + " VM3 "
	cFiltro += 						"  ON VM3.VM3_FILIAL = VM4.VM4_FILIAL "
	cFiltro += 						" AND VM3.VM3_CODIGO = VM4.VM4_CODVM3 "
	cFiltro += 						" AND VM3.VM3_STATUS IN ('1','2','3') "
	cFiltro += 						" AND VM3.D_E_L_E_T_ = ' ' "
	cFiltro += 					" WHERE VSJ.VSJ_FILIAL = VO1_FILIAL "
	cFiltro += 						" AND VSJ.VSJ_NUMOSV = VO1_NUMOSV "
	cFiltro += 						" AND VSJ.D_E_L_E_T_ = ' ' "
	cFiltro += 					" GROUP BY VSJ.VSJ_CODIGO, "
	cFiltro += 						" VSJ.VSJ_NUMOSV, "
	cFiltro += 						" VSJ.VSJ_ORIDAD, "
	cFiltro += 						" VSJ.VSJ_TIPTEM, "
	cFiltro += 						" VSJ.VSJ_FATPAR, "
	cFiltro += 						" VSJ.VSJ_LOJA, "
	cFiltro += 						" VSJ.VSJ_GRUITE, "
	cFiltro += 						" VSJ.VSJ_CODITE, "
	cFiltro += 						" VSJ.VSJ_QTDITE, "
	cFiltro += 						" VSJ.VSJ_OPER, "
	cFiltro += 						" VSJ.VSJ_CODTES, "
	cFiltro += 						" VSJ.VSJ_RESPEC "
	cFiltro +=			" ) TMP "
	cFiltro +=			" WHERE TMP.VSJ_QTDITE > 0 AND ( TMP.QTDVM4 IS NULL OR TMP.VSJ_QTDITE > TMP.QTDVM4 ) "
	cFiltro += ")"

	oDlgOA210 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0001, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Solicitação de Peças Oficina

	oBrwVO1 := FwMBrowse():New()
	oBrwVO1:SetOwner(oDlgOA210)
	oBrwVO1:SetDescription(STR0001) // Solicitação de Peças Oficina
	oBrwVO1:SetAlias('VO1')
	oBrwVO1:SetMenuDef( 'OFIA210' )
	oBrwVO1:AddStatusColumns({|| OA2100025_ColunaStatusNotaFiscal() }, {|| OA2100035_LegendaStatusNotaFiscal() })
	oBrwVO1:SetChgAll(.T.) //nao apresentar a tela para informar a filial
	oBrwVO1:SetFilterDefault( cFiltro )
	oBrwVO1:DisableDetails()
	oBrwVO1:ForceQuitButton(.T.)
	oBrwVO1:Activate()

	oDlgOA210:Activate( , , , , , , ) //ativa a janela

Return NIL

Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	ADD OPTION aRotina TITLE STR0002 ACTION 'OA2100015_SolicitacaoPecas()' OPERATION 4 ACCESS 0 // Solicitar Peças

Return aRotina

/*/{Protheus.doc} OA2100025_ColunaStatusNotaFiscal

@author Renato Vinicius
@since 06/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2100025_ColunaStatusNotaFiscal()
	
	// Variável do Retorno
	Local cImgRPO := "BR_BRANCO"

	cAlVM3 := 'TABVM3'
	BeginSql alias cAlVM3
		SELECT
			VM3.VM3_CODIGO,
			VM3.VM3_STATUS
		FROM
			%table:VM3% VM3
		WHERE
			VM3.VM3_FILIAL = %xfilial:VM3% AND
			VM3.VM3_NUMOSV = %exp:VO1->VO1_NUMOSV% AND
			VM3.%notDel%
		ORDER BY 1 DESC
	EndSql

	//-- Define Status do registro
	If (cAlVM3)->VM3_STATUS == "2" //Conf Parcial
		cImgRpo := "BR_AMARELO"
	ElseIf (cAlVM3)->VM3_STATUS == "3" //Conferido
		cImgRpo := "BR_VERDE"
	ElseIf (cAlVM3)->VM3_STATUS == "4" //Aprovado
		cImgRpo := "BR_PRETO"
	ElseIf (cAlVM3)->VM3_STATUS == "5" //Reprovado
		cImgRpo := "BR_VERMELHO"
	EndIf

	(cAlVM3)->(dbCloseArea())
	
Return cImgRPO

/*/{Protheus.doc} OA2100035_LegendaStatusNotaFiscal

@author Renato Vinicius
@since 06/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2100035_LegendaStatusNotaFiscal()
	
	// Array das Legendas
	Local aLegenda := {	{"BR_BRANCO"	, STR0003 }, ; //"Pendente"
						{"BR_AMARELO"	, STR0004 }, ; //"Conf Parcial"
						{"BR_VERDE"		, STR0005 }, ; //"Conferido"
						{"BR_PRETO"		, STR0006 }, ; //"Aprovado"
						{"BR_VERMELHO"	, STR0007 } } //"Reprovado"

	//-- Define Status do registro
	BrwLegenda(STR0009,STR0008,aLegenda )	// Status da solicitação de Peças / Legenda
	
Return .T.


Function OA2100015_SolicitacaoPecas()

	Local oWorkArea

	Local aCampos1:= {} // Array para campos da tabela temporária e campos da View
	Local aCampos2:= {} // Array para campos da tabela temporária e campos da View

	Local aSize   := FWGetDialogSize( oMainWnd )

	Local cFiltro := ""

	Local aBot210 := {}

	AADD(aBot210, {"E5"    ,{|| OA2100111_SelecionarTodasPecas() } , STR0034 } ) // Selecionar todas as Peças

	// Criando tabela temporária
	aadd(aCampos1, {"ZZ1_MARK"	,"C",2										,0} ) // Mark
	aadd(aCampos1, {"ZZ1_FILIAL",GetSX3Cache("VSJ_FILIAL","X3_TIPO"),GetSX3Cache("VSJ_FILIAL","X3_TAMANHO")	,0} ) // Filial
	aadd(aCampos1, {"ZZ1_CODIGO",GetSX3Cache("VSJ_CODIGO","X3_TIPO"),GetSX3Cache("VSJ_CODIGO","X3_TAMANHO")	,0} ) // Codigo VSJ
	aadd(aCampos1, {"ZZ1_NUMOSV",GetSX3Cache("VSJ_NUMOSV","X3_TIPO"),GetSX3Cache("VSJ_NUMOSV","X3_TAMANHO")	,0} ) // Numero da OS
	aadd(aCampos1, {"ZZ1_ORIDAD",GetSX3Cache("VSJ_ORIDAD","X3_TIPO"),GetSX3Cache("VSJ_ORIDAD","X3_TAMANHO")	,0} ) // Origem do Registro
	aadd(aCampos1, {"ZZ1_TIPTEM",GetSX3Cache("VSJ_TIPTEM","X3_TIPO"),GetSX3Cache("VSJ_TIPTEM","X3_TAMANHO")	,0} ) // Tipo de Tempo
	aadd(aCampos1, {"ZZ1_FATPAR",GetSX3Cache("VSJ_FATPAR","X3_TIPO"),GetSX3Cache("VSJ_FATPAR","X3_TAMANHO")	,0} ) // Faturar para
	aadd(aCampos1, {"ZZ1_LOJA"	,GetSX3Cache("VSJ_LOJA","X3_TIPO")	,GetSX3Cache("VSJ_LOJA","X3_TAMANHO")	,0} ) // Loja
	aadd(aCampos1, {"ZZ1_GRUITE",GetSX3Cache("VSJ_GRUITE","X3_TIPO"),GetSX3Cache("VSJ_GRUITE","X3_TAMANHO")	,0} ) // Grupo do Item
	aadd(aCampos1, {"ZZ1_CODITE",GetSX3Cache("VSJ_CODITE","X3_TIPO"),GetSX3Cache("VSJ_CODITE","X3_TAMANHO")	,0} ) // Codigo do Item
	aadd(aCampos1, {"ZZ1_QTDITE",GetSX3Cache("VSJ_QTDITE","X3_TIPO"),GetSX3Cache("VSJ_QTDITE","X3_TAMANHO")	,GetSX3Cache("VSJ_QTDITE","X3_DECIMAL")} ) // Quantidade do Item
	aadd(aCampos1, {"ZZ1_QTDREQ",GetSX3Cache("VSJ_QTDREQ","X3_TIPO"),GetSX3Cache("VSJ_QTDREQ","X3_TAMANHO")	,GetSX3Cache("VSJ_QTDREQ","X3_DECIMAL")} ) // Quantidade Requisitada
	aadd(aCampos1, {"ZZ1_OPER"	,GetSX3Cache("VSJ_OPER","X3_TIPO")	,GetSX3Cache("VSJ_OPER","X3_TAMANHO")	,0} ) // Operação
	aadd(aCampos1, {"ZZ1_CODTES",GetSX3Cache("VSJ_CODTES","X3_TIPO"),GetSX3Cache("VSJ_CODTES","X3_TAMANHO")	,0} ) // TES
	aadd(aCampos1, {"ZZ1_RESPEC",GetSX3Cache("VSJ_RESPEC","X3_TIPO"),GetSX3Cache("VSJ_RESPEC","X3_TAMANHO")	,0} ) // Teve Reserva? ( 0 = Nao / 1 = Sim )

	// Criando tabela temporária
	aadd(aCampos2, {"ZZ2_MARK"	,"C",2										,0} ) // Mark
	aadd(aCampos2, {"ZZ2_FILIAL",GetSX3Cache("VSJ_FILIAL","X3_TIPO"),GetSX3Cache("VSJ_FILIAL","X3_TAMANHO")	,0} ) // Filial
	aadd(aCampos2, {"ZZ2_CODIGO",GetSX3Cache("VSJ_CODIGO","X3_TIPO"),GetSX3Cache("VSJ_CODIGO","X3_TAMANHO")	,0} ) // Codigo VSJ
	aadd(aCampos2, {"ZZ2_NUMOSV",GetSX3Cache("VSJ_NUMOSV","X3_TIPO"),GetSX3Cache("VSJ_NUMOSV","X3_TAMANHO")	,0} ) // Numero da OS
	aadd(aCampos2, {"ZZ2_ORIDAD",GetSX3Cache("VSJ_ORIDAD","X3_TIPO"),GetSX3Cache("VSJ_ORIDAD","X3_TAMANHO")	,0} ) // Origem do Registro
	aadd(aCampos2, {"ZZ2_TIPTEM",GetSX3Cache("VSJ_TIPTEM","X3_TIPO"),GetSX3Cache("VSJ_TIPTEM","X3_TAMANHO")	,0} ) // Tipo de Tempo
	aadd(aCampos2, {"ZZ2_FATPAR",GetSX3Cache("VSJ_FATPAR","X3_TIPO"),GetSX3Cache("VSJ_FATPAR","X3_TAMANHO")	,0} ) // Faturar para
	aadd(aCampos2, {"ZZ2_LOJA"	,GetSX3Cache("VSJ_LOJA","X3_TIPO")	,GetSX3Cache("VSJ_LOJA","X3_TAMANHO")	,0} ) // Loja
	aadd(aCampos2, {"ZZ2_GRUITE",GetSX3Cache("VSJ_GRUITE","X3_TIPO"),GetSX3Cache("VSJ_GRUITE","X3_TAMANHO")	,0} ) // Grupo do Item
	aadd(aCampos2, {"ZZ2_CODITE",GetSX3Cache("VSJ_CODITE","X3_TIPO"),GetSX3Cache("VSJ_CODITE","X3_TAMANHO")	,0} ) // Codigo do Item
	aadd(aCampos2, {"ZZ2_QTDITE",GetSX3Cache("VSJ_QTDITE","X3_TIPO"),GetSX3Cache("VSJ_QTDITE","X3_TAMANHO")	,GetSX3Cache("VSJ_QTDITE","X3_DECIMAL")} ) // Quantidade do Item
	aadd(aCampos2, {"ZZ2_QTDREQ",GetSX3Cache("VSJ_QTDREQ","X3_TIPO"),GetSX3Cache("VSJ_QTDREQ","X3_TAMANHO")	,GetSX3Cache("VSJ_QTDREQ","X3_DECIMAL")} ) // Quantidade Requisitada
	aadd(aCampos2, {"ZZ2_OPER"	,GetSX3Cache("VSJ_OPER","X3_TIPO")	,GetSX3Cache("VSJ_OPER","X3_TAMANHO")	,0} ) // Operação
	aadd(aCampos2, {"ZZ2_CODTES",GetSX3Cache("VSJ_CODTES","X3_TIPO"),GetSX3Cache("VSJ_CODTES","X3_TAMANHO")	,0} ) // TES
	aadd(aCampos2, {"ZZ2_RESPEC",GetSX3Cache("VSJ_RESPEC","X3_TIPO"),GetSX3Cache("VSJ_RESPEC","X3_TAMANHO")	,0} ) // Teve Reserva? ( 0 = Nao / 1 = Sim )

	oTmpTable1 := OFDMSTempTable():New()
	oTmpTable1:cAlias := "TEMPA"
	oTmpTable1:aVetCampos := aCampos1
	oTmpTable1:AddIndex(, {"ZZ1_FILIAL","ZZ1_NUMOSV","ZZ1_CODIGO"} )
	oTmpTable1:CreateTable()

	oTmpTable2 := OFDMSTempTable():New()
	oTmpTable2:cAlias := "TEMPB"
	oTmpTable2:aVetCampos := aCampos2
	oTmpTable2:AddIndex(, {"ZZ2_FILIAL","ZZ2_NUMOSV","ZZ2_CODIGO"} )
	oTmpTable2:CreateTable()

	aCampos1 := {;
					{STR0010,"ZZ1_TIPTEM"	, GetSX3Cache("VSJ_TIPTEM"	,"X3_TIPO"),20,0, Alltrim(GetSX3Cache("VSJ_TIPTEM"	,"X3_PICTURE")),GetSX3Cache("VSJ_TIPTEM","X3_DECIMAL"),.f.},;// Tipo de Tempo
					{STR0011,"ZZ1_FATPAR"	, GetSX3Cache("VSJ_FATPAR"	,"X3_TIPO"),30,0, Alltrim(GetSX3Cache("VSJ_FATPAR"	,"X3_PICTURE")),GetSX3Cache("VSJ_FATPAR","X3_DECIMAL"),.f.},;// Faturar Para
					{STR0012,"ZZ1_LOJA"		, GetSX3Cache("VSJ_LOJA"	,"X3_TIPO"),20,0, Alltrim(GetSX3Cache("VSJ_LOJA"	,"X3_PICTURE")),GetSX3Cache("VSJ_LOJA"	,"X3_DECIMAL"),.f.},;// Loja
					{STR0013,"ZZ1_GRUITE"	, GetSX3Cache("VSJ_GRUITE"	,"X3_TIPO"),30,0, Alltrim(GetSX3Cache("VSJ_GRUITE"	,"X3_PICTURE")),GetSX3Cache("VSJ_GRUITE","X3_DECIMAL"),.f.},;// Grupo do Item
					{STR0014,"ZZ1_CODITE"	, GetSX3Cache("VSJ_CODITE"	,"X3_TIPO"),40,0, Alltrim(GetSX3Cache("VSJ_CODITE"	,"X3_PICTURE")),GetSX3Cache("VSJ_CODITE","X3_DECIMAL"),.f.},;// Codigo do Item
					{STR0015,"ZZ1_QTDITE"	, GetSX3Cache("VSJ_QTDITE"	,"X3_TIPO"),15,2, Alltrim(GetSX3Cache("VSJ_QTDITE"	,"X3_PICTURE")),GetSX3Cache("VSJ_QTDITE","X3_DECIMAL"),.f.} ;// Quantidade
	}

	aCampos2 := {;
					{STR0010,"ZZ2_TIPTEM"	, GetSX3Cache("VSJ_TIPTEM"	,"X3_TIPO"),20,0, Alltrim(GetSX3Cache("VSJ_TIPTEM"	,"X3_PICTURE")),GetSX3Cache("VSJ_TIPTEM","X3_DECIMAL"),.f.},;// Tipo de Tempo
					{STR0011,"ZZ2_FATPAR"	, GetSX3Cache("VSJ_FATPAR"	,"X3_TIPO"),30,0, Alltrim(GetSX3Cache("VSJ_FATPAR"	,"X3_PICTURE")),GetSX3Cache("VSJ_FATPAR","X3_DECIMAL"),.f.},;// Faturar Para
					{STR0012,"ZZ2_LOJA"		, GetSX3Cache("VSJ_LOJA"	,"X3_TIPO"),20,0, Alltrim(GetSX3Cache("VSJ_LOJA"	,"X3_PICTURE")),GetSX3Cache("VSJ_LOJA"	,"X3_DECIMAL"),.f.},;// Loja
					{STR0013,"ZZ2_GRUITE"	, GetSX3Cache("VSJ_GRUITE"	,"X3_TIPO"),30,0, Alltrim(GetSX3Cache("VSJ_GRUITE"	,"X3_PICTURE")),GetSX3Cache("VSJ_GRUITE","X3_DECIMAL"),.f.},;// Grupo do Item
					{STR0014,"ZZ2_CODITE"	, GetSX3Cache("VSJ_CODITE"	,"X3_TIPO"),40,0, Alltrim(GetSX3Cache("VSJ_CODITE"	,"X3_PICTURE")),GetSX3Cache("VSJ_CODITE","X3_DECIMAL"),.f.},;// Codigo do Item
					{STR0015,"ZZ2_QTDITE"	, GetSX3Cache("VSJ_QTDITE"	,"X3_TIPO"),15,2, Alltrim(GetSX3Cache("VSJ_QTDITE"	,"X3_PICTURE")),GetSX3Cache("VSJ_QTDITE","X3_DECIMAL"),.f.},;// Quantidade
					{STR0016,"ZZ2_QTDREQ"	, GetSX3Cache("VSJ_QTDREQ"	,"X3_TIPO"),15,2, Alltrim(GetSX3Cache("VSJ_QTDREQ"	,"X3_PICTURE")),GetSX3Cache("VSJ_QTDREQ","X3_DECIMAL"),.f.},;// Qtd Solicitada
					{STR0017,"ZZ2_OPER"		, GetSX3Cache("VSJ_OPER"	,"X3_TIPO"),15,0, Alltrim(GetSX3Cache("VSJ_OPER"	,"X3_PICTURE")),GetSX3Cache("VSJ_OPER"	,"X3_DECIMAL"),.f.},;// Operação
					{STR0018,"ZZ2_CODTES"	, GetSX3Cache("VSJ_CODTES"	,"X3_TIPO"),15,0, Alltrim(GetSX3Cache("VSJ_CODTES"	,"X3_PICTURE")),GetSX3Cache("VSJ_CODTES","X3_DECIMAL"),.f.} ;// TES
	}

	OA2100055_LevantaDados(VO1->VO1_NUMOSV)

	oDlgVSJ := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0001, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Solicitação de Peças Oficina

		oWorkArea := FWUIWorkArea():New( oDlgVSJ )
		
		oWorkArea:CreateHorizontalBox( "LINE01", 45 )
		oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
		oWorkArea:CreateHorizontalBox( "LINE02", 45 )
		oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )

		oWorkArea:Activate()

		cFiltro := "@ ZZ1_QTDITE > 0 AND NOT EXISTS ( "
		cFiltro += 			" SELECT TEMPB.ZZ2_CODIGO "
		cFiltro += 			" FROM " + oTmpTable2:GetRealName() + " TEMPB "
		cFiltro += 			" WHERE   TEMPB.ZZ2_FILIAL = ZZ1_FILIAL "
		cFiltro += 				" AND TEMPB.ZZ2_MARK = ' ' "
		cFiltro += 				" AND TEMPB.ZZ2_CODIGO = ZZ1_CODIGO "
		cFiltro += 				" AND TEMPB.ZZ2_NUMOSV = ZZ1_NUMOSV "
		cFiltro += 				" AND TEMPB.D_E_L_E_T_ = ' '"
		cFiltro += ")"

		// Criação do browse de tela
		oBrowseA := FWMBrowse():New( )
		oBrowseA:SetOwner(oWorkarea:GetPanel("OBJ1"))
		oBrowseA:SetTemporary(.T.) 
		oBrowseA:DisableDetails()
		oBrowseA:DisableConfig()
		oBrowseA:DisableReport()
		oBrowseA:SetFixedBrowse(.T.)
		oBrowseA:SetAlias("TEMPA")
		oBrowseA:SetFields(aCampos1)
		oBrowseA:SetMenuDef("")
		oBrowseA:ForceQuitButton()
		oBrowseA:SetDescription(STR0019) // Pendências
		oBrowseA:SetFilterDefault( cFiltro )
		oBrowseA:SetDoubleClick( { || OA2100065_MarcaRegistro(.f.) } )
		oBrowseA:Activate()

		cFiltro := "@ ZZ2_MARK = ' ' "

		// Criação do browse de tela
		oBrowseB := FWMBrowse():New( )
		oBrowseB:SetOwner(oWorkarea:GetPanel("OBJ2"))
		oBrowseB:SetTemporary(.T.) 
		oBrowseB:DisableDetails()
		oBrowseB:DisableConfig()
		oBrowseB:DisableReport()
		oBrowseB:SetFixedBrowse(.T.)
		oBrowseB:SetAlias("TEMPB")
		oBrowseB:SetFields(aCampos2)
		oBrowseB:SetMenuDef("")
		oBrowseB:ForceQuitButton()
		oBrowseB:SetDescription(STR0002) // Solicitar Peças
		oBrowseB:SetFilterDefault( cFiltro )
		oBrowseB:SetEditCell(.T., { || OA2100085_ValidaDigitacaoQtd() })

		oBrowseB:SetDelete(.T. , { || OA2100065_MarcaRegistro(.t.) , oBrowseA:GoTop() , oBrowseA:SetFocus() , oBrowseA:Refresh() , oBrowseB:GoTop() , oBrowseB:SetFocus() , oBrowseB:Refresh() })
		oBrowseB:Activate()

		oBrowseB:GetColumn(7):SetEdit(.T.)
		oBrowseB:GetColumn(7):SetReadVar("ZZ2_QTDREQ")

	oDlgVSJ:Activate( , , , , , , EnchoiceBar( oDlgVSJ, { || IIf(OA2100075_ConfirmaSolicitacao(), oDlgVSJ:End(), oDlgVSJ:Refresh()) }, { || oDlgVSJ:End() }, , aBot210 , , , , , .F., .T. ) ) //ativa a janela

	oTmpTable1:CloseTable()
	oTmpTable2:CloseTable()

Return .t.


/*/{Protheus.doc} OA2100045_ColunaEditavel

@author Renato Vinicius
@since 06/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2100045_ColunaEditavel(cVariavel)

	Default cVariavel := ""

Return .t.


/*/{Protheus.doc} OA2100055_LevantaDados

@author Renato Vinicius
@since 06/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2100055_LevantaDados(cNumOs)

	cQuery := "SELECT * "
	cQuery += " FROM ( "
	cQuery += 			" SELECT VSJ.VSJ_CODIGO, "
	cQuery += 				" VSJ.VSJ_NUMOSV, "
	cQuery += 				" VSJ.VSJ_ORIDAD, "
	cQuery += 				" VSJ.VSJ_TIPTEM, "
	cQuery += 				" VSJ.VSJ_FATPAR, "
	cQuery += 				" VSJ.VSJ_LOJA, "
	cQuery += 				" VSJ.VSJ_GRUITE, "
	cQuery += 				" VSJ.VSJ_CODITE, "
	cQuery += 				" VSJ.VSJ_QTDITE, "
	cQuery += 				" VSJ.VSJ_OPER, "
	cQuery += 				" VSJ.VSJ_CODTES, "
	cQuery += 				" VSJ.VSJ_RESPEC, "
	cQuery += 				" VSJ.VSJ_QTDINI, "
	cQuery += 				" VSJ.VSJ_QESTNA, "
	cQuery += 				" SUM( VM4_QTSOLI ) AS QTDVM4 "
	cQuery += 			" FROM " + RetSqlName("VSJ") + " VSJ "
	cQuery += 			" LEFT JOIN " + RetSqlName("VM4") + " VM4 "
	cQuery += 				"  ON VM4.VM4_FILIAL = '" + xFilial("VM4") + "' "
	cQuery += 				" AND VM4.VM4_CODVSJ = VSJ.VSJ_CODIGO "
	cQuery += 				" AND VM4.D_E_L_E_T_ = ' ' "
	cQuery += 			" LEFT JOIN " + RetSqlName("VM3") + " VM3 "
	cQuery += 				"  ON VM3.VM3_FILIAL = VM4.VM4_FILIAL "
	cQuery += 				" AND VM3.VM3_CODIGO = VM4.VM4_CODVM3 "
	cQuery += 				" AND VM3.VM3_STATUS IN ('1','2','3') "
	cQuery += 				" AND VM3.D_E_L_E_T_ = ' ' "
	cQuery += 			" WHERE VSJ.VSJ_FILIAL = '" + xFilial("VSJ") + "' "
	cQuery += 				" AND VSJ.VSJ_NUMOSV = '" + cNumOs + "' "
	cQuery += 				" AND VSJ.VSJ_QTDITE > 0 AND ( VSJ.VSJ_QTDINI = 0 OR ( VSJ.VSJ_QTDINI > 0 AND VSJ.VSJ_QESTNA > 0 ) )"
	cQuery += 				" AND VSJ.D_E_L_E_T_ = ' ' "
	cQuery += 			" GROUP BY VSJ.VSJ_CODIGO, "
	cQuery += 				" VSJ.VSJ_NUMOSV, "
	cQuery += 				" VSJ.VSJ_ORIDAD, "
	cQuery += 				" VSJ.VSJ_TIPTEM, "
	cQuery += 				" VSJ.VSJ_FATPAR, "
	cQuery += 				" VSJ.VSJ_LOJA, "
	cQuery += 				" VSJ.VSJ_GRUITE, "
	cQuery += 				" VSJ.VSJ_CODITE, "
	cQuery += 				" VSJ.VSJ_QTDITE, "
	cQuery += 				" VSJ.VSJ_OPER, "
	cQuery += 				" VSJ.VSJ_CODTES, "
	cQuery += 				" VSJ.VSJ_RESPEC, "
	cQuery += 				" VSJ.VSJ_QTDINI, "
	cQuery += 				" VSJ.VSJ_QESTNA "
	cQuery +=	" ) TMP "
	cQuery +=" WHERE TMP.QTDVM4 IS NULL OR ( TMP.VSJ_QTDITE > TMP.QTDVM4 AND TMP.VSJ_QESTNA <> TMP.QTDVM4 ) "

	TcQuery cQuery New Alias "TMPVSJ"

	While !TMPVSJ->( EoF() )

		If TMPVSJ->VSJ_QTDINI == 0 .or. ( TMPVSJ->VSJ_QESTNA >= ( TMPVSJ->VSJ_QTDITE - TMPVSJ->QTDVM4 ) )
			nQTDITE	:= TMPVSJ->VSJ_QTDITE - TMPVSJ->QTDVM4
		Else
			nQTDITE	:= TMPVSJ->VSJ_QESTNA - TMPVSJ->QTDVM4
		EndIf

		// Adicionado endereço
		RecLock("TEMPA",.T.)

		TEMPA->ZZ1_CODIGO	:= TMPVSJ->VSJ_CODIGO 
		TEMPA->ZZ1_NUMOSV	:= TMPVSJ->VSJ_NUMOSV
		TEMPA->ZZ1_ORIDAD	:= TMPVSJ->VSJ_ORIDAD
		TEMPA->ZZ1_TIPTEM	:= TMPVSJ->VSJ_TIPTEM
		TEMPA->ZZ1_FATPAR	:= TMPVSJ->VSJ_FATPAR
		TEMPA->ZZ1_LOJA		:= TMPVSJ->VSJ_LOJA
		TEMPA->ZZ1_GRUITE	:= TMPVSJ->VSJ_GRUITE
		TEMPA->ZZ1_CODITE	:= TMPVSJ->VSJ_CODITE
		TEMPA->ZZ1_QTDITE	:= nQTDITE
		TEMPA->ZZ1_QTDREQ	:= nQTDITE
		TEMPA->ZZ1_OPER		:= TMPVSJ->VSJ_OPER
		TEMPA->ZZ1_CODTES	:= TMPVSJ->VSJ_CODTES
		TEMPA->ZZ1_RESPEC	:= TMPVSJ->VSJ_RESPEC

		TEMPA->(MsUnlock())

		TMPVSJ->( dbSkip() )

	EndDo

	TMPVSJ->( dbCloseArea() )

Return


/*/{Protheus.doc} OA2100065_MarcaRegistro

@author Renato Vinicius
@since 06/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2100065_MarcaRegistro(lDelete)
Local nQtdReq := 0

	If lDelete

		cQuery := "DELETE FROM " + oTmpTable2:GetRealName()
		cQuery += " WHERE ZZ2_CODIGO = '" + TEMPB->ZZ2_CODIGO + "' "
		cQuery += 	" AND ZZ2_NUMOSV = '" + TEMPB->ZZ2_NUMOSV + "' "

		TCSqlExec(cQuery)

	Else

		// Verifica Saldo do Item na seleção //
		nQtdReq := OA2100101_ValidaSaldoDisponivel( TEMPA->ZZ1_QTDREQ , TEMPA->ZZ1_GRUITE , TEMPA->ZZ1_CODITE , TEMPA->ZZ1_TIPTEM , .t. , TEMPA->ZZ1_RESPEC )
		If nQtdReq <= 0
			Return
		EndIf

		// Adicionado endereço
		RecLock("TEMPB",.T.)

			TEMPB->ZZ2_CODIGO	:= TEMPA->ZZ1_CODIGO
			TEMPB->ZZ2_NUMOSV	:= TEMPA->ZZ1_NUMOSV
			TEMPB->ZZ2_ORIDAD	:= TEMPA->ZZ1_ORIDAD
			TEMPB->ZZ2_TIPTEM	:= TEMPA->ZZ1_TIPTEM
			TEMPB->ZZ2_FATPAR	:= TEMPA->ZZ1_FATPAR
			TEMPB->ZZ2_LOJA		:= TEMPA->ZZ1_LOJA
			TEMPB->ZZ2_GRUITE	:= TEMPA->ZZ1_GRUITE
			TEMPB->ZZ2_CODITE	:= TEMPA->ZZ1_CODITE
			TEMPB->ZZ2_QTDITE	:= TEMPA->ZZ1_QTDITE
			TEMPB->ZZ2_QTDREQ	:= nQtdReq
			TEMPB->ZZ2_OPER		:= TEMPA->ZZ1_OPER
			TEMPB->ZZ2_CODTES	:= TEMPA->ZZ1_CODTES
			TEMPB->ZZ2_RESPEC	:= TEMPA->ZZ1_RESPEC

		TEMPB->(MsUnlock())

	EndIf

	oBrowseA:ExecuteFilter(.t.)
	oBrowseB:GoTop()
	oBrowseB:Refresh()

Return

/*/{Protheus.doc} OA2100075_ConfirmaSolicitacao

@author Renato Vinicius
@since 06/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OA2100075_ConfirmaSolicitacao()

	Local oModelVM3    := FWLoadModel( 'OFIA211' )
	Local cProdutivo   := ""
	Local cPrioridade  := ""
	Local cObservacao  := ""
	Local cSolicitacao := ""
	Local lOk          := .t.
	Local nQtdReq      := 0
	Local aRetProObs   := {}

	// Verifica Saldo dos Itens //
	cQuery := " SELECT TEMPB.* "
	cQuery += " FROM " + oTmpTable2:GetRealName() + " TEMPB "
	cQuery += " WHERE   TEMPB.ZZ2_QTDREQ > 0 "
	TcQuery cQuery New Alias "TMPZZ2"
	SB1->(dbSetOrder(7))
	While !TMPZZ2->( EoF() )
		nQtdReq := OA2100101_ValidaSaldoDisponivel( TMPZZ2->ZZ2_QTDREQ , TMPZZ2->ZZ2_GRUITE , TMPZZ2->ZZ2_CODITE , TMPZZ2->ZZ2_TIPTEM , .f. , TMPZZ2->ZZ2_RESPEC )
		If nQtdReq <= 0
			lOk := .f.
		EndIf
		TMPZZ2->( dbSkip() )
	EndDo
	TMPZZ2->(dbCloseArea())
	If !lOk // Problema de SALDO
		Return .f.
	EndIf

	aRetProObs := OA2100095_ProdutivoSolicitanteObservacao()
	cProdutivo  := aRetProObs[1]
	cPrioridade := aRetProObs[2]
	cObservacao := aRetProObs[3]

	If Empty(cProdutivo)
		Return .f.
	EndIf

	oModelVM3:SetOperation( MODEL_OPERATION_INSERT )

	lRetVM3 := oModelVM3:Activate()

	if lRetVM3

		oModelVM3:SetValue( "VM3MASTER", "VM3_NUMOSV", VO1->VO1_NUMOSV )
		oModelVM3:SetValue( "VM3MASTER", "VM3_STATUS", "1" )
		oModelVM3:SetValue( "VM3MASTER", "VM3_PROSOL", cProdutivo )
		If !Empty(cPrioridade)
			oModelVM3:SetValue( "VM3MASTER", "VM3_PRISEP", cPrioridade )
		EndIf
		If !Empty(cObservacao)
			oModelVM3:SetValue( "VM3MASTER", "VM3_OBSCON", cObservacao )
		EndIf

		oModelDet := oModelVM3:GetModel("VM4DETAIL")

		cQuery := " SELECT TEMPB.* "
		cQuery += " FROM " + oTmpTable2:GetRealName() + " TEMPB "
		cQuery += " WHERE   TEMPB.ZZ2_QTDREQ > 0 "

		TcQuery cQuery New Alias "TMPZZ2"

		SB1->(dbSetOrder(7))

		While !TMPZZ2->( EoF() )

			oModelDet:AddLine()

			SB1->(DbSeek(xFilial("SB1") + TMPZZ2->ZZ2_GRUITE + TMPZZ2->ZZ2_CODITE) )

			oModelDet:SetValue( "VM4_CODVM3", oModelVM3:GetValue( "VM3MASTER", "VM3_CODIGO") )
			oModelDet:SetValue( "VM4_CODVSJ", TMPZZ2->ZZ2_CODIGO )
			oModelDet:SetValue( "VM4_COD"	, SB1->B1_COD )
			oModelDet:SetValue( "VM4_QTORIG", TMPZZ2->ZZ2_QTDITE )
			oModelDet:SetValue( "VM4_QTSOLI", TMPZZ2->ZZ2_QTDREQ )

			VM4->(MsUnlock())

			TMPZZ2->( dbSkip() )

		EndDo
	
		TMPZZ2->(dbCloseArea())

		If ( lRet := oModelVM3:VldData() )

			if ( lRet := oModelVM3:CommitData())
			Else
				Help("",1,"COMMITVM3",,STR0020,1,0) // Não foi possivel incluir o(s) registro(s)
			EndIf

		Else
			Help("",1,"VALIDVM3",,oModelVM3:GetErrorMessage()[6],1,0)
		EndIf

		cSolicitacao := oModelVM3:GetValue("VM3MASTER","VM3_CODIGO")

		oModelVM3:DeActivate()

	Else
		Help("",1,"ACTIVEVM3",,STR0021,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM3
	EndIf

	FreeObj(oModelVM3)

	If !Empty(cSolicitacao)

		If ExistFunc("OA3620011_Tempo_Total_Conferencia_Oficina")
			OA3620011_Tempo_Total_Conferencia_Oficina( 1 , cSolicitacao , VO1->VO1_NUMOSV ) // 1=Iniciar o Tempo Total da Conferencia de Oficina caso não exista o registro
		EndIf

		if ExistBlock("IMPOSOC")
			ExecBlock("IMPOSOC",.f.,.f.,{cSolicitacao})
		Endif

	EndIf

Return .t.


/*/{Protheus.doc} OA2100085_ValidaDigitacaoQtd

@author Renato Vinicius
@since 06/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2100085_ValidaDigitacaoQtd()

	Local lRetorno := .f.
	Local nQtdReq  := 0

	If TEMPB->ZZ2_QTDREQ == 0

		RecLock("TEMPB",.F.)
			TEMPB->ZZ2_MARK := cMark
		MsUnlock()
		lRetorno := .t.

		oBrowseA:ExecuteFilter(.t.)
		oBrowseB:ExecuteFilter(.t.)

	ElseIf TEMPB->ZZ2_QTDREQ > 0 

		If TEMPB->ZZ2_QTDREQ <= TEMPB->ZZ2_QTDITE

			// Verifica Saldo do Item na Digitacao da Quantidade //
			nQtdReq := OA2100101_ValidaSaldoDisponivel( TEMPB->ZZ2_QTDREQ , TEMPB->ZZ2_GRUITE , TEMPB->ZZ2_CODITE , TEMPB->ZZ2_TIPTEM , .f. , TEMPB->ZZ2_RESPEC )
			If nQtdReq > 0
				lRetorno := .t.
			EndIf

		EndIf

	EndIf

Return lRetorno


/*/{Protheus.doc} OA2100095_ProdutivoSolicitanteObservacao

@author Renato Vinicius
@since 06/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2100095_ProdutivoSolicitanteObservacao()

	Local cCdProdutivo := Space(GetSX3Cache("VO3_PROREQ","X3_TAMANHO"))
	Local cPrioridade  := ""
	Local cObservacao  := ""
	Local lVM3PRISEP   := VM3->(ColumnPos("VM3_PRISEP")) <> 0
	Local lVM3OBSCON   := VM3->(ColumnPos("VM3_OBSCON")) <> 0
	Local aParamBox    := {}
	Private aRetProObs := {}
	Private cFiltroVX5 := "077" // Prioridade de Separação da Conferência

	aAdd(aParamBox,{1,STR0022, cCdProdutivo ,GetSX3Cache("VO3_PROREQ","X3_PICTURE"),"FG_StrZero('MV_PAR01',6) .AND.FG_Seek('VAI','MV_PAR01') .AND. IF(VAI->VAI_PROFIL<>'1',VAI->VAI_FILPRO==FWCodFil(),.T.)","V1A","",30,.t.}) // Produtivo
	If lVM3PRISEP
		cPrioridade := Space(GetSX3Cache("VM3_PRISEP","X3_TAMANHO"))
		aAdd(aParamBox,{1,STR0036, cPrioridade ,GetSX3Cache("VM3_PRISEP","X3_PICTURE"),'vazio().or.FG_Seek("VX5","'+"'077'+MV_PAR02"+'",1)',"VX5AUX","",30,.f.}) // Prioridade
	EndIf
	If lVM3OBSCON
		cObservacao := Space(GetSX3Cache("VM3_OBSCON","X3_TAMANHO"))
		aAdd(aParamBox,{1,STR0035, cObservacao ,"@!","","","",100,.f.}) // Obs.Conferente
	EndIf
	If ParamBox(aParamBox,STR0023,@aRetProObs,,,,,,,,.F.,.F.) // Produtivo solicitante
		cCdProdutivo := aRetProObs[1]
		If lVM3PRISEP
			cPrioridade := aRetProObs[2]
		EndIf
		If lVM3OBSCON
			cObservacao  := aRetProObs[IIf(lVM3PRISEP,3,2)]
		EndIf
	EndIf

Return { cCdProdutivo , cPrioridade , cObservacao }

/*/{Protheus.doc} OA2100101_ValidaSaldoDisponivel

@author Andre Luis Almeida
@since 09/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2100101_ValidaSaldoDisponivel( nQtdReq , cGrpIte , cCodIte , cTipTpo , lDeixaMenor , cTeveReserva )
Local nRet := nQtdReq
Local cArm := ""
//
SB1->(dbSetOrder(7))
SB1->(DbSeek(xFilial("SB1") + cGrpIte + cCodIte ) )
//
If cTeveReserva == "1" // Teve RESERVA
	cArm := PadR( AllTrim(GetMv("MV_RESITE")) , GetSX3Cache("B2_LOCAL","X3_TAMANHO") )
Else
	cArm := OM0200065_ArmazemOrigem( cTipTpo )
EndIf
//
SB2->(dbSetOrder(1))
SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + cArm ) )
//
Do Case
	Case SB2->B2_QATU <= 0
		nRet := 0
		Help("",1,"OA2100101_ValidaSaldoDisponivel",,STR0030+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Item SEM Saldo Disponivel.
			STR0029+" "+Alltrim(SB1->B1_GRUPO)+" - "+Alltrim(SB1->B1_CODITE)+CHR(13)+CHR(10)+; // Item:
			Alltrim(SB1->B1_DESC),1,0)
	Case SB2->B2_QATU < nQtdReq
		If lDeixaMenor
			nRet := SB2->B2_QATU
			Help("",1,"OA2100101_ValidaSaldoDisponivel",,STR0031+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Será solicitado apenas o Saldo Disponivel.
				STR0033+" "+Transform(SB2->B2_QATU,GetSX3Cache("VSJ_QTDREQ"	,"X3_PICTURE"))+CHR(13)+CHR(10)+; // Saldo Disponivel:
				STR0029+" "+Alltrim(SB1->B1_GRUPO)+" - "+Alltrim(SB1->B1_CODITE)+CHR(13)+CHR(10)+; // Item:
				Alltrim(SB1->B1_DESC),1,0)
		Else
			nRet := 0
			Help("",1,"OA2100101_ValidaSaldoDisponivel",,STR0032+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Impossivel continuar.
				STR0033+" "+Transform(SB2->B2_QATU,GetSX3Cache("VSJ_QTDREQ"	,"X3_PICTURE"))+CHR(13)+CHR(10)+; // Saldo Disponivel:
				STR0029+" "+Alltrim(SB1->B1_GRUPO)+" - "+Alltrim(SB1->B1_CODITE)+CHR(13)+CHR(10)+; // Item:
				Alltrim(SB1->B1_DESC),1,0)
		EndIf
EndCase
//
Return nRet

/*/{Protheus.doc} OA2100111_SelecionarTodasPecas

Seleciona todas as Peças para serem solicitadas

@author Andre Luis Almeida
@since 23/11/2020
@version 1.0

@type function
/*/
Static Function OA2100111_SelecionarTodasPecas()
Local aRecTMP := {}
Local nCntFor := 0
DbSelectArea("TEMPA")
DbGoTop()
While !Eof()
	aAdd(aRecTMP,TEMPA->(RecNo()))
	DbSkip()
EndDo
For nCntFor := 1 to len(aRecTMP)
	TEMPA->(DbGoto(aRecTMP[nCntFor]))
	OA2100065_MarcaRegistro(.f.)
	DbSelectArea("TEMPA")
	oBrowseA:Refresh()
Next
Return