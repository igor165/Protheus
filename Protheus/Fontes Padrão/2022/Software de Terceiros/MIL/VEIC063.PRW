#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIC063.CH"

Static oDMSBrwStru
Static oBrwVC063

/*/{Protheus.doc} VEIC063
Consulta de Faturamento por Tipo

@author Rubens
@since 02/04/2019
@version 1.0
@type function
/*/

Function VEIC063()

	Local oObjSX1 := FWSX1Util():New()
	Local oIHelper := DMS_InterfaceHelper():New()

	Local oVC063Dlg
	Local oPanBrowse
	Local oPanDialog
	Local oAuxParam

	Private lFiltroMarca

	oObjSX1:AddGroup("VEIC063")
	oObjSX1:SearchGroup()
	lFiltroMarca := (Len(oObjSX1:GetGroup("VEIC063")[2]) >= 7)

	If ! Pergunte("VEIC063",.t.)
		Return
	EndIf

	VC0630023_ConfigBrowse(@oDMSBrwStru)

	oIHelper:SetOwnerPvt(FunName())

	oVC063Dlg := oIHelper:CreateDialog("Faturamento por tipo",, .t.)
	oAuxParam := DMS_DataContainer():New()

	oIHelper:SetDialog(oVC063Dlg)
	oPanDialog := oIHelper:CreateTPanel({;
		{"ALINHAMENTO", CONTROL_ALIGN_ALLCLIENT};
		})

	oIHelper:SetDialog(oPanDialog)
	oIHelper:nOpc := 2

			oIHelper:AddMGetTipo( {;
					{ 'X3_TIPO'    , 'N' },;
					{ 'X3_TAMANHO' , TamSX3('VRJ_VALTOT')[1] },;
					{ 'X3_DECIMAL' , TamSX3('VRJ_VALTOT')[1] },;
					{ 'X3_CAMPO'   , 'TOTPERIODO'},;
					{ 'X3_TITULO'  , 'Valor Total'},;
					{ 'X3_PICTURE' , '@E 99,999,999,999.99' } ;
				})
			//&(oAuxParam:GetValue('CAMPO')) := oAuxParam:GetValue("VALOR")

	oIHelper:CreateMSMGet(.F., {;
		{"VISUALIZA"  , .t.               },;
		{"YSIZE", 30},;
		{"COLUNA", .t.},;
		{"ALINHAMENTO", CONTROL_ALIGN_BOTTOM};
		})

	oIHelper:SetDialog(oPanDialog)
	oPanBrowse := oIHelper:CreateTPanel({;
		{"ALINHAMENTO", CONTROL_ALIGN_ALLCLIENT};
		})

	// Cria um Form Browse
	oBrwVC063 := FWmBrowse():New()

	oDMSBrwStru:SetBrwOwner(oBrwVC063)

	oBrwVC063:SetTemporary(.T.)
	//oBrwVC063:SetUseFilter( .F. ) 
	oBrwVC063:SetDescription(STR0001) // Faturamento por Tipo

	oBrwVC063:SetWalkThru(.F.)
	oBrwVC063:SetAmbiente(.F.)

	oBrwVC063:SetSeek(.T.,oDMSBrwStru:GetSeek())

	oBrwVC063:SetFieldFilter(oDMSBrwStru:GetColFilter())

	oBrwVC063:SetQueryIndex(oDMSBrwStru:GetIndexes())

	oDMSBrwStru:AddBrwColumn()

	oBrwVC063:SetAlias(oDMSBrwStru:GetAlias())

	oBrwVC063:SetParam({ || VC0630033_Param() })


	oBrwVC063:DisableDetails()
	oBrwVC063:SetOwner(oPanBrowse)


	oBrwVC063:Activate()
	oBrwVC063:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	VC0630053_Total()

	ACTIVATE MSDIALOG oVC063Dlg // ON INIT EnchoiceBar(oVC063Dlg,{ || oVC063Dlg:End() }, { || oVC063Dlg:End() })

	oDMSBrwStru:DelTrabTmp()
Return

Function VC0630023_ConfigBrowse(oDMSBrwStru)

	Local nTamSX3 := TamSX3("VX5_DESCRI")[1]

	oDMSBrwStru := OFBrowseStruct():New({"CC2", "SA1", "SA3", "SF2", "VRJ", "VRK", "VV0", "VV2", "VV3", "VV9"})

	oDMSBrwStru:AddField( "VRJ_PEDIDO" )
	oDMSBrwStru:AddField( "VRJ_PEDCOM" )
	oDMSBrwStru:AddField( "VRJ_DATDIG" )
	oDMSBrwStru:AddField( "VV3_DESCRI" ,STR0002 ) // "Tipo Venda"
	oDMSBrwStru:AddField( "VRK_CHASSI" )
	oDMSBrwStru:AddField( "VRK_MODVEI" )
	oDMSBrwStru:AddField( "VV2_DESMOD" )
	oDMSBrwStru:AddField( "VRK_OPCION" )
	oDMSBrwStru:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'DESCOPCION' },;
											{ 'cTitulo' , STR0003  },; // 'Descr. Opcional'
											{ 'cTipo' , 'C' },;
											{ 'nTamanho' , nTamSX3 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@!' } } ) )
	oDMSBrwStru:AddField( "VRK_COREXT" )
	oDMSBrwStru:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'DESCCOREXT' },;
											{ 'cTitulo' , STR0004 },; // 'Descr. Cor Externa'
											{ 'cTipo' , 'C' },;
											{ 'nTamanho' , nTamSX3 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@!' } } ) )
	oDMSBrwStru:AddField( "VRK_CORINT" )
	oDMSBrwStru:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'DESCCORINT' },;
											{ 'cTitulo' , STR0005 },; // 'Descr. Cor Interna'
											{ 'cTipo' , 'C' },;
											{ 'nTamanho' , nTamSX3 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@!' } } ) )
	oDMSBrwStru:AddField( "VRK_FABMOD" )
	oDMSBrwStru:AddField( "F2_SERIE"   , STR0006 ) // "Série NF"
	oDMSBrwStru:AddField( "F2_DOC"     , STR0007 ) // "Número NF"
	oDMSBrwStru:AddField( "F2_EMISSAO" )
	oDMSBrwStru:AddField( "F2_CHVNFE"  )
	oDMSBrwStru:AddField( "VRK_VALTAB" )
	oDMSBrwStru:AddField( "VRK_VALVDA" )
	oDMSBrwStru:AddField( "VRJ_CODVEN" )
	oDMSBrwStru:AddField( "A3_NOME"    , STR0008)
	oDMSBrwStru:AddField( "VRJ_CODCLI" )
	oDMSBrwStru:AddField( "VRJ_LOJA"   )
	oDMSBrwStru:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'A1_CGC' },;
											{ 'cTitulo' , RetTitle("A1_CGC") },;
											{ 'cTipo' , 'C' },;
											{ 'nTamanho' , 14 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , { || IIF(Len(Alltrim((oBrwVC063:GetAlias())->A1_CGC)) == 11 , "@R 999.999.999-99","@R 99.999.999/9999-99") } } } ) )
	oDMSBrwStru:AddField( "A1_NOME"    )
	oDMSBrwStru:AddField( "A1_NREDUZ"  )
	oDMSBrwStru:AddField( "CC2_MUN"    )
	oDMSBrwStru:AddField( "A1_EST"     )

	oDMSBrwStru:AddField( "VRJ_CLIRET" )
	oDMSBrwStru:AddField( "VRJ_LOJRET" )

	oDMSBrwStru:AddIndex( "VRJ_PEDIDO" )
	oDMSBrwStru:AddIndex( "VRJ_PEDCOM" )
	oDMSBrwStru:AddIndex( "VRJ_CODCLI+VRJ_LOJA" )
	oDMSBrwStru:AddIndex( "VRK_CHASSI" )

	oDMSBrwStru:AddSeek( { "VRJ_PEDIDO" } )
	oDMSBrwStru:AddSeek( { "VRK_CHASSI" } )
	oDMSBrwStru:AddSeek( { "VRJ_CODCLI" , "VRJ_LOJA"} )

	oDMSBrwStru:CriaTabTmp()
	oDMSBrwStru:LoadData( VC0630013_Query() )

Return


Function VC0630033_Param()

	Local lRet := .T.

	If (lRet := Pergunte('VEIC063',.T.))
		oDMSBrwStru:LoadData( VC0630013_Query() , .t. )
		oBrwVC063:Refresh(.T.)
	EndIf

Return .f.

Static Function VC0630053_Total()
	Local cQuery := "SELECT SUM(VRK_VALVDA) TOTAL FROM " + oDMSBrwStru:GetRealName()
	M->TOTPERIODO := FM_SQL(cQuery)
Return



Static Function VC0630013_Query()

	Local cQuery := ""

	cQuery := ;
		"SELECT " +;
			" VRJ_PEDIDO, VRJ_PEDCOM, VRJ_DATDIG" +;
			", COALESCE( VV3_DESCRI , ' ' ) VV3_DESCRI" +;
			", VRK_CHASSI, VRK_MODVEI " +;
			", VV2_DESMOD" +;
			", VRK_OPCION, COALESCE( RTRIM( VX5OPC.VX5_DESCRI ) , ' ' ) DESCOPCION"+;
			", VRK_COREXT, COALESCE( RTRIM( VX5EXT.VX5_DESCRI ) , ' ' ) DESCCOREXT "+;
			", VRK_CORINT, COALESCE( RTRIM( VX5INT.VX5_DESCRI ) , ' ' ) DESCCORINT "+;
			", VRK_FABMOD" +;
			", F2_SERIE, F2_DOC, F2_EMISSAO, F2_CHVNFE" +;
			", VRK_VALTAB, VRK_VALVDA" +;
			", VRJ_CODVEN" +;
			", COALESCE( A3_NOME , ' ' ) A3_NOME" +;
			", VRJ_CODCLI, VRJ_LOJA, A1_CGC, A1_NOME, A1_NREDUZ" +;
			", CC2_MUN" +;
			", A1_EST" +;
			", VRJ_CLIRET, VRJ_LOJRET" +;
		" FROM " + RetSQLName("VRJ") + " VRJ " +;
			" JOIN " + RetSQLName("VRK") + " VRK" +;
					"  ON VRK.VRK_FILIAL = '" + FWxFilial("VRK") + "'" +;
					" AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO" +;
					" AND VRK.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("VV9") + " VV9" +;
					"  ON VV9.VV9_FILIAL = '" + FWxFilial("VV9") + "'" +;
					" AND VV9.VV9_NUMATE = VRK.VRK_NUMTRA" +;
					" AND VV9.D_E_L_E_T_ = ' '" +;
					" AND VV9.VV9_STATUS IN ('F','T') " +;
			" JOIN " + RetSQLName("VV0") + " VV0" +;
					"  ON VV0.VV0_FILIAL = '" + FWxFilial("VV0") + "'" +;
					" AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE" +;
					" AND VV0.D_E_L_E_T_ = ' '" +;
					" AND VV0.VV0_OPEMOV = '0' " +;
					" AND VV0.VV0_SITNFI = '1' " +;
			" JOIN " + RetSQLName("SF2") + " F2 " +;
					"  ON F2.F2_FILIAL = '" + FWxFilial("SF2") + "'" +;
					" AND F2.F2_DOC = VV0.VV0_NUMNFI" +;
					" AND F2.F2_SERIE = VV0.VV0_SERNFI" +;
					" AND F2.F2_CLIENTE = VV0.VV0_CODCLI" +;
					" AND F2.F2_LOJA = VV0.VV0_LOJA" +;
					" AND F2.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("SA1") + " A1" +;
					"  ON A1.A1_FILIAL = '" + FWxFilial("SA1") + "'" +;
					" AND A1.A1_COD = VRJ.VRJ_CODCLI" +;
					" AND A1.A1_LOJA = VRJ.VRJ_LOJA" +;
					" AND A1.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSQLName("SA3") + " A3" +;
					"  ON A3.A3_FILIAL = '" + FWxFilial("SA3") + "'" +;
					" AND A3.A3_COD = VRJ.VRJ_CODVEN" +;
					" AND A3.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSQLName("CC2") + " CC2" +;
					"  ON CC2.CC2_FILIAL = '" + FWxFilial("CC2") + "'" +;
					" AND CC2.CC2_EST = A1.A1_EST" +;
					" AND CC2.CC2_CODMUN = A1.A1_COD_MUN" +;
					" AND CC2.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("VV2") + " VV2" +;
					"  ON VV2.VV2_FILIAL = '" + FWxFilial("VV2") + "'" +;
					" AND VV2.VV2_CODMAR = VRK.VRK_CODMAR" +;
					" AND VV2.VV2_MODVEI = VRK.VRK_MODVEI" +;
					" AND VV2.VV2_SEGMOD = VRK.VRK_SEGMOD" +;
					" AND VV2.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSqlName("VX5") + " VX5INT ON VX5INT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5INT.VX5_CHAVE = '066' AND VX5INT.VX5_CODIGO = VV2.VV2_CORINT AND VX5INT.D_E_L_E_T_ = ' ' " +;
			" LEFT JOIN " + RetSqlName("VX5") + " VX5EXT ON VX5EXT.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5EXT.VX5_CHAVE = '067' AND VX5EXT.VX5_CODIGO = VV2.VV2_COREXT AND VX5EXT.D_E_L_E_T_ = ' ' " +;
			" LEFT JOIN " + RetSqlName("VX5") + " VX5OPC ON VX5OPC.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5OPC.VX5_CHAVE = '068' AND VX5OPC.VX5_CODIGO = VV2.VV2_OPCION AND VX5OPC.D_E_L_E_T_ = ' ' " +;
			" LEFT JOIN " + RetSQLName("VV3") + " VV3" +;
					"  ON VV3.VV3_FILIAL = '" + FWxFilial("VV3") + "'" +;
					" AND VV3.VV3_TIPVEN = VRJ.VRJ_TIPVEN" +;
					" AND VV3.D_E_L_E_T_ = ' '" +;
		" WHERE VRJ.VRJ_FILIAL = '" + FWxFilial("VRJ") + "'" +;
		  " AND VRJ.VRJ_STATUS <> 'C'" +;
		  " AND VRJ.D_E_L_E_T_ = ' '" +;
		  " AND VRK.VRK_CANCEL IN (' ','0')"

	If !Empty(MV_PAR01) .AND. !EMPty(MV_PAR02)
		cQuery += " AND F2.F2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
	EndIf
	If !Empty(MV_PAR03)
		cQuery += " AND VRJ.VRJ_CODCLI = '" + MV_PAR03 + "'"
		If !Empty(MV_PAR04)
			cQuery += " AND VRJ.VRJ_LOJA = '" + MV_PAR04 + "'"
		EndIf
	EndIf
	If !Empty(MV_PAR05)
		cQuery += " AND VRJ.VRJ_CODVEN = '" + MV_PAR05 + "'"
	EndIf
	If !Empty(MV_PAR06)
		cQuery += " AND VRJ.VRJ_TIPVEN = '" + MV_PAR06 + "'"
	EndIf
	If lFiltroMarca .and. !Empty(MV_PAR07)
		cQuery += " AND VRK.VRK_CODMAR = '" + MV_PAR07 + "'"
	EndIf

	If ( ExistBlock("VC063QRY") )
		cQuery := ExecBlock("VC063QRY",.f.,.f.,{cQuery})
	EndIf

Return cQuery

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0009 ACTION 'VC0630033_Param' OPERATION 3 ACCESS 0 // 'Parâmetros'
	ADD OPTION aRotina TITLE STR0010 ACTION 'VC0630043_PlanilhaEstoque' OPERATION 2 ACCESS 0 // 'Gerar Planilha'
Return aRotina


Function VC0630043_PlanilhaEstoque()

	Local oExcel
	Local aAuxLinha
	Local nQtdCol
	Local nLoopRec
	Local nPosCol
	Local lTotalizar
	Local cTipo

	If oBrwVC063:LogicLen() <= 0
		Return .t.
	EndIf

	Pergunte("VEIC063IMP",.t.)

	oExcel := FWMSEXCEL():New()
	oExcel:AddworkSheet("Faturamento")
	oExcel:AddTable("Faturamento","Faturamento")

	nQtdCol := Len(oBrwVC063:aColumns)
	For nPosCol := 1 to nQtdCol

		lTotalizar := (oBrwVC063:GetColumn(nPosCol):GetID() $ "VRK_VALVDA")
		cTipo := oBrwVC063:GetColumn(nPosCol):GetType()

		oExcel:AddColumn( ;
			"Faturamento" , ;
			"Faturamento" , ;
			oBrwVC063:GetColumn(nPosCol):GetTitle() , ;
			IIf( cTipo == "N" , 3 , 1 ) , ; // Alinhamento da coluna ( 1-Left,2-Center,3-Right )
			IIf( oBrwVC063:GetColumn(nPosCol):GetID() $ "VRK_VALVDA/VRK_VALTAB" , 2 , ( IIf(cTipo == "N" , 2 , 1 ) ) ) , ; // Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
			lTotalizar )
	Next nPosCol

	oBrwVC063:GoTop()
	nUlRec := oBrwVC063:LogicLen()
	nCurrRec := oBrwVC063:At()
	While .T.
		nLoopRec := oBrwVC063:At()

		aAuxLinha := Array(nQtdCol)
		For nPosCol := 1 to nQtdCol
			cIdField := oBrwVC063:GetColumn(nPosCol):GetID()

			Do Case
			Case cIdField $ "VRK_VALVDA/VRK_VALTAB"
				aAuxLinha[nPosCol] := val(strtran(strtran(oBrwVC063:GetColumnData(nPosCol),".",""),",","."))
			Otherwise
				aAuxLinha[nPosCol] := AllTrim(oBrwVC063:GetColumnData(nPosCol))
			End Case

		Next nPosCol

		oExcel:AddRow("Faturamento","Faturamento",aAuxLinha) // Peças / Peças

		oBrwVC063:GoDown()
		If nLoopRec == oBrwVC063:At()
			Exit
		EndIf
	End

	oExcel:Activate()

	oExcel:GetXMLFile(AllTrim(MV_PAR01))
	oExcel:DeActivate()

	oBrwVC063:GoTo( nCurrRec, .T. )

	MsgInfo("Arquivo Gerado")

Return