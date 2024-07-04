#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIC061.CH"

Static oTabTmp := NIL
Static oDMSBrwStru
Static oBrwVC061

/*/{Protheus.doc} VEIC061
Follow-up de títulos gerados relacionados ao pedido de venda montadora.
@author Rubens
@since 02/04/2019
@version 1.0
@type function
/*/

Function VEIC061()

	If ! Pergunte("VEIC061",.t.)
		Return
	EndIf

	VC0610063_ConfigBrowse(@oDMSBrwStru)

	// Cria um Form Browse
	oBrwVC061 := FWmBrowse():New()

	oDMSBrwStru:SetBrwOwner(oBrwVC061)

	oBrwVC061:SetTemporary(.T.)
	oBrwVC061:SetUseFilter( .T. ) 
	oBrwVC061:SetDescription(STR0001) // "Parcelas Pedidos de Venda / Atendimento de Veículos"
	oBrwVC061:SetParam({ || VC0610033_Param() })

	oBrwVC061:SetUseFilter()

	oBrwVC061:SetWalkThru(.F.)
	oBrwVC061:SetAmbiente(.F.)

	oBrwVC061:AddLegend('E1_SALDO = 0', 'BR_VERMELHO', STR0002 ) //"Título Baixado"
	oBrwVC061:AddLegend('!Empty(E1_NUMBOR) .and. (ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2))', 'BR_CINZA', STR0003 ) //"Título baixado parcialmente e em bordero"
	oBrwVC061:AddLegend('!Empty(E1_NUMBOR)', 'BR_PRETO', STR0004 ) //"Título em Bordero"
	oBrwVC061:AddLegend('!(ROUND(E1_SDACRES,2) > ROUND(E1_ACRESC,2)) .And. ROUND(E1_SALDO,2) + ROUND(E1_SDACRES,2) # ROUND(E1_VALOR,2) + ROUND(E1_ACRESC,2)', 'BR_AZUL', STR0005 ) //"Baixado parcialmente"
	oBrwVC061:AddLegend('ROUND(E1_SALDO,2) == ROUND(E1_VALOR,2) .and. AllTrim(E1_SITUACA)== "F"', 'BR_VERDE_ESCURO', STR0006 ) //"Título Protestado"
	oBrwVC061:AddLegend('E1_SALDO = E1_VALOR', 'BR_VERDE', STR0007 ) //"Título em aberto"

	oDMSBrwStru:AddBrwColumn()

	oBrwVC061:SetAlias(oDMSBrwStru:GetAlias())
	oBrwVC061:SetSeek(.T.,oDMSBrwStru:GetSeek())

	oBrwVC061:SetFieldFilter(oDMSBrwStru:GetColFilter())

	oBrwVC061:SetQueryIndex(oDMSBrwStru:GetIndexes())
	
	oBrwVC061:Activate()

	oDMSBrwStru:DelTrabTmp()

Return

Function VC0610063_ConfigBrowse(oDMSBrwStru)

	oDMSBrwStru := OFBrowseStruct():New({"SA1", "SE1", "SF2", "VRJ", "VRK", "VV0", "VV2"})

	oDMSBrwStru:AddField( 'VRJ_PEDIDO' )
	oDMSBrwStru:AddField( 'VRJ_STATUS' , "Status Ped." )
	oDMSBrwStru:AddField( 'VRJ_PEDCOM' )
	oDMSBrwStru:AddField( 'VRJ_CODCLI' )
	oDMSBrwStru:AddField( 'VRJ_LOJA'   )
	oDMSBrwStru:AddField( 'A1_NOME'    )
	oDMSBrwStru:AddField( 'VV0_NUMTRA' , "Atendimento" )
	oDMSBrwStru:AddField( 'VV0_STATUS' , "Status Atend." )
	oDMSBrwStru:AddField( 'VRK_CHASSI' )
	oDMSBrwStru:AddField( 'VV2_DESMOD' )
	oDMSBrwStru:AddField( 'F2_SERIE'   )
	oDMSBrwStru:AddField( 'F2_DOC'     )
	oDMSBrwStru:AddField( 'F2_EMISSAO' , "Dt. Faturamento" )
	oDMSBrwStru:AddField( 'E1_PREFIXO' )
	oDMSBrwStru:AddField( 'E1_NUM'     )
	oDMSBrwStru:AddField( 'E1_PARCELA' )
	oDMSBrwStru:AddField( 'E1_TIPO'    )
	oDMSBrwStru:AddField( 'E1_NATUREZ' )
	oDMSBrwStru:AddField( 'E1_EMISSAO' )
	oDMSBrwStru:AddField( 'E1_VENCTO'  )
	oDMSBrwStru:AddField( 'E1_VENCREA' )
	oDMSBrwStru:AddField( 'E1_BAIXA'   )
	oDMSBrwStru:AddField( 'E1_VALOR'   )
	oDMSBrwStru:AddField( 'E1_SALDO'   )
	oDMSBrwStru:AddField( 'E1_SITUACA' )
	oDMSBrwStru:AddField( 'E1_NUMBOR'  )
	oDMSBrwStru:AddField( 'E1_SDACRES' )
	oDMSBrwStru:AddField( 'E1_ACRESC'  )

	oDMSBrwStru:AddIndex( "VRJ_PEDIDO+VV0_NUMTRA" )
	oDMSBrwStru:AddIndex( "VV0_NUMTRA" )
	oDMSBrwStru:AddIndex( "VRJ_CODCLI+VRJ_LOJA+VRJ_PEDIDO+VV0_NUMTRA" )
	oDMSBrwStru:AddIndex( "E1_PREFIXO+E1_NUM+E1_PARCELA" )

	oDMSBrwStru:AddSeek({"VRJ_PEDIDO", "VV0_NUMTRA"})
	oDMSBrwStru:AddSeek({"VV0_NUMTRA"})
	oDMSBrwStru:AddSeek({"VRJ_CODCLI", "VRJ_LOJA", "VRJ_PEDIDO", "VV0_NUMTRA"})
	oDMSBrwStru:AddSeek({"E1_PREFIXO", "E1_NUM", "E1_PARCELA"})

	oDMSBrwStru:CriaTabTmp()

	oDMSBrwStru:LoadData( VC0610013_Query() )

Return


Function VC0610033_Param()

	Local lRet := .T.

	If (lRet := Pergunte('VEIC061',.T.))
		oDMSBrwStru:LoadData( VC0610013_Query() , .t. )
		oBrwVC061:Refresh(.T.)
	EndIf

Return .f.




Static Function VC0610013_Query()

	Local cQuery := ""
	Local oSQLHelper := DMS_SQLHelper():New()
	Local cPrefOri   := GetNewPar("MV_PREFVEI","VEI")

	// Ordem do Select deve ser igual a ordem de criacao dos campos na tabela 
	cQuery += ;
		"SELECT " +;
			" VRJ_PEDIDO, VRJ_STATUS, VRJ_PEDCOM, VRJ_CODCLI, VRJ_LOJA" +;
			", A1.A1_NOME" +;
			", COALESCE(VV0.VV0_NUMTRA,'" + Space(TamSX3("VV0_NUMTRA")[1]) + "') VV0_NUMTRA" +;
			", COALESCE(VV0.VV0_STATUS,'" + Space(TamSX3("VV0_STATUS")[1]) + "') VV0_STATUS" +;
			", VRK.VRK_CHASSI" +;
			", VV2.VV2_DESMOD" +;
			", '" + Space(TamSX3("F2_SERIE")[1])   + "' F2_SERIE" +;
			", '" + Space(TamSX3("F2_DOC")[1])     + "' F2_DOC" +;
			", '" + Space(TamSX3("F2_EMISSAO")[1]) + "' F2_EMISSAO" +;
			", E1PEDV.E1_PREFIXO, E1PEDV.E1_NUM, E1PEDV.E1_PARCELA, E1PEDV.E1_TIPO, E1PEDV.E1_NATUREZ, E1PEDV.E1_EMISSAO, E1PEDV.E1_VENCTO, E1PEDV.E1_VENCREA, E1PEDV.E1_BAIXA, E1PEDV.E1_VALOR, E1PEDV.E1_SALDO, E1PEDV.E1_SITUACA, E1PEDV.E1_NUMBOR, E1PEDV.E1_SDACRES, E1PEDV.E1_ACRESC" +;
		" FROM " + RetSQLName("VRJ") + " VRJ " +;
			" JOIN " + RetSQLName("VRK") + " VRK " +;
				" ON VRK.VRK_FILIAL = '" + FWxFilial("VRK") + "'" +;
				" AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO " +;
				" AND VRK.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("VV2") + " VV2 " +;
				" ON VV2.VV2_FILIAL = '" + FWxFilial("VV2") + "'" +;
				" AND VV2.VV2_CODMAR = VRK.VRK_CODMAR " +;
				" AND VV2.VV2_MODVEI = VRK.VRK_MODVEI " +;
				" AND VV2.VV2_SEGMOD = VRK.VRK_SEGMOD " +;
				" AND VV2.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("VRL") + " VRL " +;
				" ON VRL.VRL_FILIAL = '" + FWxFilial("VRL") + "'" +;
				" AND VRL.VRL_PEDIDO = VRJ.VRJ_PEDIDO " +;
				" AND VRL.VRL_ITEPED = VRK.VRK_ITEPED " +;
				" AND VRL.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("SE1") + " E1PEDV " +;
				" ON E1PEDV.E1_FILIAL = '" + FWxFilial("SE1") + "'" +;
				" AND E1PEDV.E1_PREFIXO = VRL.VRL_E1PREF" +;
				" AND E1PEDV.E1_NUM = VRL.VRL_E1NUM" +;
				" AND E1PEDV.E1_PARCELA = VRL.VRL_E1PARC" +;
				" AND E1PEDV.E1_TIPO = VRL.VRL_E1TIPO" +;
				" AND E1PEDV.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("SA1") + " A1 " +;
				" ON A1.A1_FILIAL = '" + FWxFilial("SA1") + "'" +;
				" AND A1.A1_COD = E1PEDV.E1_CLIENTE " +;
				" AND A1.A1_LOJA = E1PEDV.E1_LOJA " +;
				" AND A1.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSQLName("VVA") + " VVA " +;
				"  ON VVA.VVA_FILIAL = '" + FWxFilial("VVA") + "' " +;
				" AND VVA.VVA_NUMTRA = VRK.VRK_NUMTRA " +;
				" AND VVA.VVA_ITETRA = VRK.VRK_ITETRA " +;
				" AND VVA.D_E_L_E_T_ = ' '" +;
  			" LEFT JOIN " + RetSQLName("VV0") + " VV0 " +;
				"  ON VV0.VV0_FILIAL = '" + FWxFilial("VV0") + "' " +;
				" AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA" +;
				" AND VV0.D_E_L_E_T_ = ' '" +;
		" WHERE VRJ.VRJ_FILIAL = '" + FWxFilial("VRJ") + "'" +;
		" AND VRJ.D_E_L_E_T_ = ' '"

	If !Empty(MV_PAR01) .AND. !EMPty(MV_PAR02)
		cQuery += " AND E1PEDV.E1_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
	EndIf
	If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
		cQuery += " AND E1PEDV.E1_VENCREA BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "' "
	EndIf
	If !Empty(MV_PAR05)
		cQuery += " AND E1PEDV.E1_CLIENTE = '" + MV_PAR05 + "'"
		If !Empty(MV_PAR06)
			cQuery += " AND E1PEDV.E1_LOJA = '" + MV_PAR06 + "'"
		EndIf
	EndIf
	If !Empty(MV_PAR07)
		cQuery += " AND VRJ.VRJ_PEDIDO = '" + MV_PAR07 + "'"
	EndIf
	If !Empty(MV_PAR08)
		cQuery += " AND VV0.VV0_NUMTRA = '" + MV_PAR08 + "'"
	EndIf

	cQuery += " UNION "

	cQuery +=;
		"SELECT " +;
			"  COALESCE(VRJ.VRJ_PEDIDO,'" + Space(TamSX3("VRJ_PEDIDO")[1]) + "') VRJ_PEDIDO" +;
			", COALESCE(VRJ.VRJ_STATUS,'" + Space(TamSX3("VRJ_STATUS")[1]) + "') VRJ_STATUS" +;
			", COALESCE(VRJ.VRJ_PEDCOM,'" + Space(TamSX3("VRJ_PEDCOM")[1]) + "') VRJ_PEDCOM" +;
			", VV0_CODCLI, VV0_LOJA" +;
			", A1.A1_NOME" +;
			", VV0_NUMTRA, VV0_STATUS " +;
			", VVA.VVA_CHASSI" +;
			", VV2.VV2_DESMOD" +;
			", SF2.F2_SERIE, SF2.F2_DOC, SF2.F2_EMISSAO" +; 
			", E1TITATEN.E1_PREFIXO, E1TITATEN.E1_NUM, E1TITATEN.E1_PARCELA, E1TITATEN.E1_TIPO, E1TITATEN.E1_NATUREZ, E1TITATEN.E1_EMISSAO, E1TITATEN.E1_VENCTO, E1TITATEN.E1_VENCREA, E1TITATEN.E1_BAIXA, E1TITATEN.E1_VALOR, E1TITATEN.E1_SALDO, E1TITATEN.E1_SITUACA, E1TITATEN.E1_NUMBOR, E1TITATEN.E1_SDACRES, E1TITATEN.E1_ACRESC" +;
		" FROM " + RetSQLName("VV0") + " VV0 " +;
			" JOIN " + RetSQLName("VVA") + " VVA " +;
				"  ON VVA.VVA_FILIAL = VV0.VV0_FILIAL " +;
				" AND VVA.VVA_NUMTRA = VV0.VV0_NUMTRA " +;
				" AND VVA.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("VV2") + " VV2 " +;
				" ON VV2.VV2_FILIAL = '" + FWxFilial("VV2") + "'" +;
				" AND VV2.VV2_CODMAR = VVA.VVA_CODMAR " +;
				" AND VV2.VV2_MODVEI = VVA.VVA_MODVEI " +;
				" AND VV2.VV2_SEGMOD = VVA.VVA_SEGMOD " +;
				" AND VV2.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSQLName("SF2") + " SF2 " +;
				"  ON SF2.F2_FILIAL = '" + FWxFilial("SF2") + "'" +;
				" AND SF2.F2_SERIE = VV0.VV0_SERNFI " +;
				" AND SF2.F2_DOC = VV0.VV0_NUMNFI " +;
				" AND SF2.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("SE1") + " E1TITATEN " +;
				" ON E1TITATEN.E1_FILIAL = '" + FWxFilial("SE1") + "'" +;
				" AND ( " +;
						" E1TITATEN.E1_NUM = " + oSQLHelper:Concat( { "'V'" , oSQLHelper:CompatFunc("SUBSTR") + "(VV0.VV0_NUMTRA,2," + Str(TamSx3("E1_NUM")[1],2) + ")" } ) +; // Títulos gerados na aprovacao do atendimento
						" OR " +;
						"( E1TITATEN.E1_NUM = VV0.VV0_NUMNFI AND E1TITATEN.E1_PREFIXO = SF2.F2_PREFIXO AND E1TITATEN.E1_PREFORI = '" + cPrefOri + "' )" +; // Títulos gerados no faturamento do atendimento
						" OR " +;
						"( E1TITATEN.E1_NUM = VV0.VV0_NUMNFI AND E1TITATEN.E1_PREFIXO = SF2.F2_PREFIXO AND E1TITATEN.E1_SERIE = SF2.F2_SERIE AND E1TITATEN.E1_PREFORI = ' ' )" +; // Títulos gerados no faturamento do atendimento através de condicao de pagamento padrao 
						" ) " +;
				" AND E1TITATEN.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("SA1") + " A1 " +;
				"  ON A1.A1_FILIAL = '" + FWxFilial("SA1") + "'" +;
				" AND A1.A1_COD = E1TITATEN.E1_CLIENTE " +;
				" AND A1.A1_LOJA = E1TITATEN.E1_LOJA " +;
				" AND A1.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSQLName("VRK") + " VRK " +;
				"  ON VRK.VRK_FILIAL = '" + FWxFilial("VRK") + "' " +;
				" AND VRK.VRK_NUMTRA = VVA.VVA_NUMTRA " +;
				" AND VRK.VRK_ITETRA = VVA.VVA_ITETRA " +;
				" AND VRK.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSQLName("VRJ") + " VRJ " +;
				"  ON VRJ.VRJ_FILIAL = '" + FWxFilial("VRJ") + "' " +;
				" AND VRJ.VRJ_PEDIDO = VRK.VRK_PEDIDO " +;
				" AND VRJ.D_E_L_E_T_ = ' '" +;
		" WHERE VV0.VV0_FILIAL = '" + FWxFilial("VV0") + "'" +;
		" AND VV0.VV0_STATUS IN ('F','T') " +;
		" AND VV0.VV0_SITNFI = '1' " +;
		" AND VV0.D_E_L_E_T_ = ' '"

	If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
		cQuery += " AND SF2.F2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "
	EndIf
	If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
		cQuery += " AND E1TITATEN.E1_VENCREA BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "' "
	EndIf
	If !Empty(MV_PAR05)
		cQuery += " AND E1TITATEN.E1_CLIENTE = '" + MV_PAR05 + "'"
		If !Empty(MV_PAR06)
			cQuery += " AND E1TITATEN.E1_LOJA = '" + MV_PAR06 + "'"
		EndIf
	EndIf
	If !Empty(MV_PAR07)
		cQuery += " AND VRJ.VRJ_PEDIDO = '" + MV_PAR07 + "'"
	EndIf
	If !Empty(MV_PAR08)
		cQuery += " AND VV0.VV0_NUMTRA = '" + MV_PAR08 + "'"
	EndIf

	// Conout(" ")
	// Conout(" ")
	// Conout(cQuery)
	// Conout(" ")

Return cQuery

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0008 ACTION 'VC0610033_Param' OPERATION 3 ACCESS 0
Return aRotina


