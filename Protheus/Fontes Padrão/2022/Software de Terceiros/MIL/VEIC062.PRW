#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIC062.CH"

Static oDMSBrwStru
Static oBrwVC062

/*/{Protheus.doc} VEIC062
Consulta de Pedidos Pendentes 

@author Rubens
@since 02/04/2019
@version 1.0
@type function
/*/

Function VEIC062()

	If ! Pergunte("VEIC062",.t.)
		Return
	EndIf

	VC0620023_ConfigBrowse(@oDMSBrwStru)

	// Cria um Form Browse
	oBrwVC062 := FWmBrowse():New()

	oDMSBrwStru:SetBrwOwner(oBrwVC062)

	oBrwVC062:SetTemporary(.T.)
	oBrwVC062:SetUseFilter( .T. ) 
	oBrwVC062:SetDescription(STR0001) // "Parcelas Pedidos de Venda / Atendimento de Veículos"

	oBrwVC062:SetUseFilter()
	oBrwVC062:SetWalkThru(.F.)
	oBrwVC062:SetAmbiente(.F.)

	oBrwVC062:AddLegend( 'VRJ_STATUS == "A"' , 'BR_VERDE'    , STR0002 ) // "Em Aberto"
	oBrwVC062:AddLegend( 'VRJ_STATUS == "P"' , 'BR_AMARELO'  , STR0003 ) // "Pendente de Aprovação"
	oBrwVC062:AddLegend( 'VRJ_STATUS == "O"' , 'BR_BRANCO'   , STR0004 ) // "Pré-Aprovado"
	oBrwVC062:AddLegend( 'VRJ_STATUS == "L"' , 'BR_AZUL'     , STR0005 ) // "Aprovado"
	oBrwVC062:AddLegend( 'VRJ_STATUS == "R"' , 'BR_LARANJA'  , STR0006 ) // "Reprovado"
	oBrwVC062:AddLegend( 'VRJ_STATUS == "F"' , 'BR_PRETO'    , STR0007 ) // "Finalizado"
	oBrwVC062:AddLegend( 'VRJ_STATUS == "C"' , 'BR_VERMELHO' , STR0008 ) // "Cancelado"

	oBrwVC062:SetSeek(.T.,oDMSBrwStru:GetSeek())

	oBrwVC062:SetFieldFilter(oDMSBrwStru:_aColFilter)

	oBrwVC062:SetQueryIndex(oDMSBrwStru:_aIndex)

	oDMSBrwStru:AddBrwColumn()

	oBrwVC062:SetAlias(oDMSBrwStru:GetAlias())
	
	oBrwVC062:SetParam({ || VC0620033_Param() })

	oBrwVC062:Activate()
	
	oDMSBrwStru:DelTrabTmp()

Return

Function VC0620023_ConfigBrowse(oDMSBrwStru)
	oDMSBrwStru := OFBrowseStruct():New({"VRJ", "VRK", "VV9", "SA1", "VV2"})
	oDMSBrwStru:AddField( "VRJ_PEDIDO" )
	oDMSBrwStru:AddField( "VRJ_STATUS" , "Status Ped." )
	oDMSBrwStru:AddField( "VRJ_PEDCOM" )
	oDMSBrwStru:AddField( "VRJ_DATDIG" )
	oDMSBrwStru:AddField( "VV9_NUMATE" , "Atendimento")
	oDMSBrwStru:AddField( "VV9_STATUS" , "Status Atend.")
	oDMSBrwStru:AddField( "VRJ_TIPVEN" )
	oDMSBrwStru:AddField( "VRJ_FORPAG" )
	oDMSBrwStru:AddField( "VRJ_CODVEN" )
	oDMSBrwStru:AddField( "VRJ_CODCLI" )
	oDMSBrwStru:AddField( "VRJ_LOJA" )
	oDMSBrwStru:AddField( "VRK_CHASSI" )
	oDMSBrwStru:AddField( "VRK_MODVEI" )
	oDMSBrwStru:AddField( "VV2_OPCION" )
	oDMSBrwStru:AddField( "VV2_COREXT" )
	oDMSBrwStru:AddField( "VV2_CORINT" )
	oDMSBrwStru:AddField( "VRK_VALVDA" )
	oDMSBrwStru:AddField( "A1_NOME" )

	oDMSBrwStru:AddIndex( "VRJ_PEDIDO" )
	oDMSBrwStru:AddIndex( "VRJ_PEDCOM" )
	oDMSBrwStru:AddIndex( "VRJ_CODVEN+VRJ_PEDIDO" )
	oDMSBrwStru:AddIndex( "VRJ_CODCLI+VRJ_LOJA" )
	oDMSBrwStru:AddIndex( "VRK_CHASSI" )

	oDMSBrwStru:AddSeek( { "VRJ_PEDIDO" } )
	oDMSBrwStru:AddSeek( { "VRK_CHASSI" } )
	oDMSBrwStru:AddSeek( { "VRJ_CODCLI" , "VRJ_LOJA"} )

	oDMSBrwStru:CriaTabTmp()
	oDMSBrwStru:LoadData( VC0620013_Query() )

Return


Function VC0620033_Param()

	Local lRet := .T.

	If (lRet := Pergunte('VEIC062',.T.))
		oDMSBrwStru:LoadData( VC0620013_Query() )
		oBrwVC062:Refresh(.T.)
	EndIf

Return .f.




Static Function VC0620013_Query()

	Local cQuery := ""
	//Local oAuxSQL := DMS_SQLHelper():New()

	cQuery += ;
		"SELECT " +;
			"  VRJ.VRJ_PEDIDO, VRJ.VRJ_STATUS, VRJ.VRJ_PEDCOM, VRJ.VRJ_DATDIG" +;
			", COALESCE(VV9.VV9_NUMATE, ' ' ) VV9_NUMATE" +;
			", COALESCE(VV9.VV9_STATUS, ' ' ) VV9_STATUS" +;
			", VRJ.VRJ_TIPVEN, VRJ.VRJ_FORPAG, VRJ.VRJ_CODVEN, VRJ.VRJ_CODCLI, VRJ.VRJ_LOJA" +;
			", VRK.VRK_CHASSI, VRK.VRK_MODVEI" +;
			", VV2.VV2_OPCION, VV2.VV2_COREXT, VV2.VV2_CORINT" +;
			", VRK.VRK_VALVDA" +;
			", A1.A1_NOME" +;
		 " FROM " + RetSQLName("VRJ") + " VRJ " +;
			" JOIN " + RetSQLName("VRK") + " VRK " +;
					 " ON VRK.VRK_FILIAL = VRJ.VRJ_FILIAL" +;
					" AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO" +;
					" AND VRK.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSQLName("VV9") + " VV9" +;
					 " ON VV9.VV9_FILIAL = VRK.VRK_FILIAL" +;
					" AND VV9.VV9_NUMATE = VRK.VRK_NUMTRA" +;
					" AND VV9.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("SA1") + " A1" +;
					 " ON A1.A1_FILIAL = '" + FWxFilial("SA1") + "'" +;
					" AND A1.A1_COD = VRJ.VRJ_CODCLI" +;
					" AND A1.A1_LOJA = VRJ.VRJ_LOJA" +;
					" AND A1.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("VV2") + " VV2" +;
					 " ON VV2.VV2_FILIAL = '" + FWxFilial("VV2") + "'" +;
					" AND VV2.VV2_CODMAR = VRK.VRK_CODMAR" +;
					" AND VV2.VV2_MODVEI = VRK.VRK_MODVEI" +;
					" AND VV2.VV2_SEGMOD = VRK.VRK_SEGMOD" +;
					" AND VV2.D_E_L_E_T_ = ' '" +;
		" WHERE VRJ.VRJ_FILIAL = '" + FWxFilial("VRJ") + "'" +;
		  " AND VRJ.VRJ_STATUS <> 'C'" +;
		  " AND VRJ.D_E_L_E_T_ = ' '" +;
		  " AND VRK.VRK_CANCEL IN (' ','0')" +;
		  " AND NOT EXISTS(" +;
				"SELECT VV9.R_E_C_N_O_ VV9RECNO" +;
				 " FROM " + RetSQLName("VV9") + " VV9" +;
					" JOIN " + RetSQLName("VV0") + " VV0" +;
						"  ON VV0.VV0_FILIAL = VRJ.VRJ_FILIAL" +;
						" AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE" +;
						" AND VV0.D_E_L_E_T_ = ' '" +;
						" AND VV0.VV0_OPEMOV = '0'" +;
						" AND VV0.VV0_SITNFI = '1'" +;
				"WHERE VV9.VV9_FILIAL = VRK.VRK_FILIAL" +;
				 " AND VV9.VV9_NUMATE = VRK.VRK_NUMTRA" +;
				 " AND VV9.D_E_L_E_T_ = ' '" +;
				 " AND VV9.VV9_STATUS IN ('F','T') " +;
		  " )"

	If !Empty(MV_PAR01) .AND. !EMPty(MV_PAR02)
		cQuery += " AND VRJ.VRJ_DATDIG BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
	EndIf
	If !Empty(MV_PAR03)
		cQuery += " AND VRJ.VRJ_CODCLI = '" + MV_PAR03 + "'"
		If !Empty(MV_PAR04)
			cQuery += " AND VRJ.VRJ_LOJA = '" + MV_PAR04 + "'"
		EndIf
	EndIf

	// Conout(" ")
	// Conout(" ")
	// Conout(" ")
	// Conout(cQuery)

Return cQuery

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0009 ACTION 'VC0620033_Param' OPERATION 3 ACCESS 0 // 'Parâmetros'
Return aRotina
