//Bibliotecas
#Include 'Protheus.ch'
#Include 'TOPCONN.CH'
#Include 'FwMVCDef.ch'
#Include 'VEIC080.ch'

Static cMVMIL0006 := GetNewPar("MV_MIL0006","")

Function VEIC080()

	Local aSize     := FWGetDialogSize( oMainWnd )
	Local aTotal    := {}

	Local aCampos1     := {} // Array para campos da tabela temporária e campos da View
	Local aCampos2     := {} // Array para campos da tabela temporária e campos da View
	Local aCampos3     := {} // Array para campos da tabela temporária e campos da View

	Private aCampos4   := {} // Array para campos da tabela temporária e campos da View

	Private cDtIni    := StoD("")
	Private cMesRet   := 1
	Private cMark     := GetMark()

	Private nIndMod   := 0

	// Criando tabela temporária
	aadd(aCampos1, {"TMP_FILIAL","C",GetSX3Cache("VVR_FILIAL","X3_TAMANHO")	,0} ) // Filial do sistema
	aadd(aCampos1, {"TMP_MARK"	,"C",2										,0} ) // Mark
	aadd(aCampos1, {"TMP_MARCA"	,"C",GetSX3Cache("VVR_CODMAR","X3_TAMANHO")	,0} ) // Marca
	aadd(aCampos1, {"TMP_GRUPO"	,"C",GetSX3Cache("VVR_GRUMOD","X3_TAMANHO")	,0} ) // Grupo de Modelo
	
	aadd(aCampos2, {"TMP_FILIAL","C",GetSX3Cache("VVR_FILIAL","X3_TAMANHO")	,0} ) // Filial do sistema
	aadd(aCampos2, {"TMP_MARK"	,"C",2										,0} ) // Mark
	aadd(aCampos2, {"TMP_MARCA"	,"C",GetSX3Cache("VVR_CODMAR","X3_TAMANHO")	,0} ) // Marca
	aadd(aCampos2, {"TMP_GRUPO"	,"C",GetSX3Cache("VVR_GRUMOD","X3_TAMANHO")	,0} ) // Grupo de Modelo
	aadd(aCampos2, {"TMP_MODELO","C",GetSX3Cache("VV2_MODVEI","X3_TAMANHO")	,0} ) // Modelo
	aadd(aCampos2, {"TMP_INDMOD","N",3										,0} ) // Indice do Modelo
	
	aadd(aCampos3, {"ZZZ_FILIAL","C",GetSX3Cache("VVR_FILIAL","X3_TAMANHO")	,0} ) // Filial do sistema
	aadd(aCampos3, {"ZZZ_MARCA"	,"C",GetSX3Cache("VVR_CODMAR","X3_TAMANHO")	,0} ) // Marca
	aadd(aCampos3, {"ZZZ_GRUPO"	,"C",GetSX3Cache("VVR_GRUMOD","X3_TAMANHO")	,0} ) // Grupo de Modelo
	aadd(aCampos3, {"ZZZ_MODELO","C",GetSX3Cache("VV2_MODVEI","X3_TAMANHO")	,0} ) // Modelo
	aadd(aCampos3, {"ZZZ_INDMES","N",3										,0} ) // Indice do Mes
	aadd(aCampos3, {"ZZZ_MESANO","C",50										,0} ) // Modelo
	aadd(aCampos3, {"ZZZ_TOTAL"	,"N",6										,0} ) // Total
	aadd(aCampos3, {"ZZZ_PEDIDO","N",6										,0} ) // Quantidade de Pedidos
	aadd(aCampos3, {"ZZZ_FATURA","N",6										,0} ) // Quantidade de Faturados
	aadd(aCampos3, {"ZZZ_ENTR"	,"N",6										,0} ) // Quantidade de Entregues
	aadd(aCampos3, {"ZZZ_NENTR"	,"N",6										,0} ) // Quantidade de Não Entregues
	aadd(aCampos3, {"ZZZ_INDMOD","N",3										,0} ) // Indice do Modelo
	aadd(aCampos3, {"ZZZ_TPREG"	,"L",1										,0} ) // Tipo do campo, .T. para Pai, .F. para Filho
	
	aadd(aCampos3, {"ZZZ_GRPMOD",;
					"C",;
					GetSX3Cache("VVR_CODMAR","X3_TAMANHO") +;
					GetSX3Cache("VVR_GRUMOD","X3_TAMANHO") +;
					GetSX3Cache("VV2_MODVEI","X3_TAMANHO"),;
					0} )// Campo para aplicação de Filtro

	aadd(aCampos4, {"ZZY_FILIAL","C",GetSX3Cache("VVR_FILIAL","X3_TAMANHO")	,0} ) // Filial do sistema
	aadd(aCampos4, {"ZZY_MARCA"	,"C",GetSX3Cache("VVR_CODMAR","X3_TAMANHO")	,0} ) // Marca
	aadd(aCampos4, {"ZZY_GRUPO"	,"C",GetSX3Cache("VVR_GRUMOD","X3_TAMANHO")	,0} ) // Grupo de Modelo
	aadd(aCampos4, {"ZZY_MODELO","C",GetSX3Cache("VV2_MODVEI","X3_TAMANHO")	,0} ) // Modelo
	aadd(aCampos4, {"ZZY_INDMES","N",3										,0} ) // Indice do Mes
	aadd(aCampos4, {"ZZY_INDMOD","N",3										,0} ) // Indice do Modelo
	aadd(aCampos4, {"ZZY_NUMPED","C",GetSX3Cache("VQ0_NUMPED","X3_TAMANHO")	,0} ) // Numero do Pedido
	aadd(aCampos4, {"ZZY_ORDNUM","C",GetSX3Cache("VJR_ORDNUM","X3_TAMANHO")	,0} ) // Numero do Pedido
	aadd(aCampos4, {"ZZY_RECVQ0","N",9										,0} ) // Numero do Pedido
	aadd(aCampos4, {"ZZY_FATURA","C",50										,0} ) // Indicador de Faturado
	aadd(aCampos4, {"ZZY_ENTR"	,"C",50										,0} ) // Indicador de Entregue
	aadd(aCampos4, {"ZZY_NENTR"	,"C",50										,0} ) // Indicador de Não Entregue

	oTmpTable1 := OFDMSTempTable():New()
	oTmpTable1:cAlias := "TEMPA"
	oTmpTable1:aVetCampos := aCampos1
	oTmpTable1:AddIndex(, {"TMP_FILIAL","TMP_MARCA","TMP_GRUPO"} )
	oTmpTable1:CreateTable()

	oTmpTable2 := OFDMSTempTable():New()
	oTmpTable2:cAlias := "TEMPB"
	oTmpTable2:aVetCampos := aCampos2
	oTmpTable2:AddIndex(, {"TMP_FILIAL","TMP_MARCA","TMP_GRUPO","TMP_MODELO"} )
	oTmpTable2:CreateTable()

	oTmpTable3 := OFDMSTempTable():New()
	oTmpTable3:cAlias := "TEMPC"
	oTmpTable3:aVetCampos := aCampos3
	oTmpTable3:AddIndex(, {"ZZZ_FILIAL","ZZZ_INDMES","ZZZ_MARCA","ZZZ_GRUPO","ZZZ_MODELO"} )
	oTmpTable3:CreateTable()

	oTmpTable4 := OFDMSTempTable():New()
	oTmpTable4:cAlias := "TEMPD"
	oTmpTable4:aVetCampos := aCampos4
	oTmpTable4:AddIndex(, {"ZZY_FILIAL","ZZY_INDMES","ZZY_INDMOD","ZZY_GRUPO","ZZY_MODELO"} )
	oTmpTable4:CreateTable()

	aCampos1 := {;
					{ STR0001	,"TMP_GRUPO"	,"C",30,0,""} ;// Grupo de Modelo
	}

	aCampos2 := {;
					{ STR0002	,"TMP_MODELO"	,"C",50,0,""} ;// Modelo
	}

	aCampos3 := {;
					{ STR0003	,"ZZZ_MESANO"	,"C",50,0,""},;// Modelo
					{ STR0001	,"ZZZ_GRUPO"	,"C",30,0,""},;// Grupo de Modelo
					{ STR0002	,"ZZZ_MODELO"	,"C",50,0,""},;// Modelo
					{ STR0004	,"ZZZ_TOTAL"	,"C",15,0,""},;// Total
					{ STR0005	,"ZZZ_PEDIDO"	,"C",15,0,""},;// Pedido
					{ STR0006	,"ZZZ_FATURA"	,"C",15,0,""},;// Faturado
					{ STR0007	,"ZZZ_ENTR"		,"C",15,0,""},;// Entregue
					{ STR0008	,"ZZZ_NENTR"	,"C",15,0,""} ;// Não Entregue
	}


	VC0800025_LevantaDados()

	oDlgOM390 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0009 , , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		oLayer := FWLayer():new()
		oLayer:Init(oDlgOM390,.f.)

		//Cria as linhas do Layer
		oLayer:addLine( 'L1', 35, .F. )
		oLayer:addLine( 'L2', 64, .F. )

		//Cria as colunas do Layer
		oLayer:addCollumn('C1L1',50,.F.,"L1") 
		oLayer:addCollumn('C2L1',49,.F.,"L1") 
		
		oLayer:addCollumn('C1L2',99,.F.,"L2")

		cL1C1 := oLayer:getColPanel('C1L1','L1')
		cL1C2 := oLayer:getColPanel('C2L1','L1')

		cL2C1 := oLayer:getColPanel('C1L2','L2')

		// Criação do browse de tela
		oBrowseA := FWMBrowse():New( )
		oBrowseA:SetOwner(cL1C1)
		oBrowseA:SetTemporary(.T.) 
		oBrowseA:DisableDetails()
		oBrowseA:DisableConfig()
		oBrowseA:DisableReport()
		oBrowseA:SetFixedBrowse(.T.)
		oBrowseA:SetAlias("TEMPA")
		oBrowseA:SetFields(aCampos1)
		oBrowseA:SetMenuDef("")
		oBrowseA:ForceQuitButton()
		oBrowseA:SetDescription( STR0001 )
		oBrowseA:AddMarkColumns( { || VC0800135_ColBMark("TEMPA") },{ || VC0800115_MarkRegistro( oBrowseA, "TEMPA", 1 ) }, { || VC0800125_MarkAllRegistro( oBrowseA , "TEMPA", 1 ), oBrowseA:Refresh() } )
		oBrowseA:Activate()

		// Criação do browse de tela
		oBrowseB := FWMBrowse():New( )
		oBrowseB:SetOwner(cL1C2)
		oBrowseB:SetTemporary(.T.) 
		oBrowseB:DisableDetails()
		oBrowseB:DisableConfig()
		oBrowseB:DisableReport()
		oBrowseB:SetFixedBrowse(.T.)
		oBrowseB:SetAlias("TEMPB")
		oBrowseB:SetFields(aCampos2)
		oBrowseB:SetMenuDef("")
		oBrowseB:ForceQuitButton()
		oBrowseB:SetDescription( STR0002 )
		oBrowseB:AddMarkColumns( { || VC0800135_ColBMark("TEMPB") },{ || VC0800115_MarkRegistro( oBrowseB, "TEMPB", 2 ) }, { || VC0800125_MarkAllRegistro( oBrowseB , "TEMPB", 2 ), oBrowseB:Refresh() })
		oBrowseB:Activate()

		// Criação do browse de tela
		oBrowseC := FWMBrowse():New( )
		oBrowseC:SetOwner(cL2C1)
		oBrowseC:SetTemporary(.T.) 
		oBrowseC:DisableDetails()
		oBrowseC:SetFixedBrowse(.T.)
		oBrowseC:SetAlias("TEMPC")
		oBrowseC:SetFields(aCampos3)
		oBrowseC:SetMenuDef("VEIC080")
		oBrowseC:SetDoubleClick( {|| VC0800075_MostraPedidos(TEMPC->ZZZ_INDMES,TEMPC->ZZZ_INDMOD) })
		oBrowseC:ForceQuitButton()
		oBrowseC:SetGroup({|| TEMPC->ZZZ_TPREG }, .T.)
		oBrowseC:SetDescription( STR0010 ) // "Consulta de Carteira de Pedidos"
		oBrowseC:Activate()

	oDlgOM390:Activate( , , , , , , ) //ativa a janela

	oTmpTable1:CloseTable()
	oTmpTable2:CloseTable()
	oTmpTable3:CloseTable()
	oTmpTable4:CloseTable()

Return

/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0011 ACTION 'VC0800015_FiltraData()' OPERATION 2 ACCESS 0 // "Define período"

Return aRotina


/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VC0800015_FiltraData()

	Local cString := ""
	Local aParamBox := {}
	Local aRet := {}

	aAdd(aParamBox,{1, STR0012 ,cDtIni,"@D","MV_PAR01 <= dDataBase","","",50,.f.}) // "Data até"
	aAdd(aParamBox,{1, STR0013 ,cMesRet,"@R 999","MV_PAR02 > 0","","",50,.f.}) // "Meses a retroagir"

	If ParamBox(aParamBox, STR0014 ,@aRet,,,,,,,,.F.,.F.) //"Filtra pedidos"

		cDtIni := aRet[1]
		cMesRet:= aRet[2]

		VC0800025_LevantaDados(aRet[1],aRet[2],.t.)

		oBrowseA:GoTop()
		oBrowseA:Refresh()

		oBrowseB:GoTop()
		oBrowseB:Refresh()

		oBrowseC:GoTop()
		oBrowseC:Refresh()

	EndIf

Return

/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800025_LevantaDados(dDataFim,nMesRetro,lDelReg)

	Local cQuery := ""
	Local nMes      := 0

	Default dDataFim  := dDataBase
	Default nMesRetro := 12
	Default lDelReg   := .f.

	If lDelReg

		cQuery := "DELETE FROM " + oTmpTable1:GetRealName()
		TCSqlExec(cQuery)

		cQuery := "DELETE FROM " + oTmpTable2:GetRealName()
		TCSqlExec(cQuery)

		cQuery := "DELETE FROM " + oTmpTable3:GetRealName()
		TCSqlExec(cQuery)

		cQuery := "DELETE FROM " + oTmpTable4:GetRealName()
		TCSqlExec(cQuery)

	EndIf

	dData := MonthSub(dDataFim,nMesRetro)

	For nMes := 1 to nMesRetro
		dDtInicial := FirstDate(dData)
		dDtFinal   := LastDate(dData)

		nIndMod := 0

		RecLock("TEMPC",.t.)
			TEMPC->ZZZ_TPREG  := .T.
			TEMPC->ZZZ_INDMES := nMes
			TEMPC->ZZZ_MESANO := MesExtenso(dDtInicial) + " " + Year2Str(dDtInicial)
		TEMPC->(MsUnlock())

		nRecTEMPC := TEMPC->(RecNo())

		aTotal := aClone(VC0800105_MontaTab(dDtInicial,dDtFinal,nMes)) // Função que carrega a tabela com as informações

		TEMPC->(DbGoTo(nRecTEMPC))

		RecLock("TEMPC",.f.)
			TEMPC->ZZZ_TOTAL  := TEMPC->ZZZ_TOTAL + aTotal[1]
			TEMPC->ZZZ_PEDIDO := TEMPC->ZZZ_PEDIDO + aTotal[2]
			TEMPC->ZZZ_FATURA := TEMPC->ZZZ_FATURA + aTotal[3]
			TEMPC->ZZZ_ENTR   := TEMPC->ZZZ_ENTR + aTotal[4]
			TEMPC->ZZZ_NENTR  := TEMPC->ZZZ_NENTR + aTotal[5]
		TEMPC->(MsUnlock())

		dData      := MonthSum(dDtFinal,1)
	Next

Return

/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800035_BlocoExecFiltro(nBrwMrk)

	Local cFilter		:= ""
	Local c2Filter		:= ""

	If nBrwMrk == 1
		cFilter += " TMP_GRUPO $ '" + VC0800045_GrupoModeloSelecionado() + "' "

		oBrowseB:SetFilterDefault(cFilter)

		c2Filter += " Empty(ZZZ_GRPMOD) .OR. ZZZ_GRPMOD $ '" + VC0800055_ModeloSelecionado() + "' "
		oBrowseC:SetFilterDefault(c2Filter)

	ElseIf nBrwMrk == 2

		cFilter += " Empty(ZZZ_GRPMOD) .OR. ZZZ_GRPMOD $ '" + VC0800055_ModeloSelecionado() + "' "

		oBrowseC:SetFilterDefault(cFilter)
	EndIf


Return

/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800045_GrupoModeloSelecionado()

	Local cString := ""

	cQuery := "SELECT TMP_MARCA, TMP_GRUPO FROM " + oTmpTable1:GetRealName() + " WHERE TMP_MARK <> ' ' "

	TcQuery cQuery New Alias "TMPGRP"

	While !TMPGRP->(Eof())
		cString += TMPGRP->TMP_GRUPO + "|"
		TMPGRP->(DbSkip())
	EndDo

	TMPGRP->(DbCloseArea())

Return cString

/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800055_ModeloSelecionado()

	Local cString := ""
	Local oSqlHelper := Dms_SqlHelper():New()

	cQuery := "SELECT " + oSqlHelper:Concat({"TMP_MARCA","TMP_GRUPO","TMP_MODELO"}) + " AS TMPMODELO FROM " + oTmpTable2:GetRealName() + " WHERE TMP_MARK <> ' ' "

	TcQuery cQuery New Alias "TMPGRP"

	While !TMPGRP->(Eof())
		cString += TMPGRP->TMPMODELO + "|"
		TMPGRP->(DbSkip())
	EndDo

	TMPGRP->(DbCloseArea())

Return cString

/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800065_LimpaMarkModelo(cMarca, cGrupo, cMark)

	Local cQuery := ""

	cQuery := "UPDATE " + oTmpTable2:GetRealName()
	cQuery += " SET TMP_MARK = '" + cMark + "'"
	cQuery += " WHERE TMP_MARCA = '" + cMarca + "'"
	cQuery +=	" AND TMP_GRUPO = '" + cGrupo + "'"

	TCSqlExec(cQuery)

Return

/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800075_MostraPedidos(nIndMes, nIndMod)

	Local nCount := 0

	Private aSize     := FWGetDialogSize( oMainWnd )

	aCampos4 := {;
					{ STR0005		,"ZZY_NUMPED"	,"C",15,0,"",1,15,.F.},;// Pedido
					{ STR0015		,"ZZY_ORDNUM"	,"C",15,0,"",1,15,.F.},;// Comar Code
					{ STR0007		,"ZZY_FATURA"	,"C",15,0,"",0,15,.T.},;// Faturado
					{ STR0008		,"ZZY_ENTR"		,"C",15,0,"",0,15,.T.} ;// Entregue
	}

	cFilter := " ZZY_INDMES = " + cValToChar(nIndMes) + " .AND. ZZY_INDMOD = " + cValToChar(nIndMod)

	oDlgVC080 := MSDialog():New( 180, 180, 820, 1000, STR0016 , , , , , , , , , .T., , , , .F. ) // "Painel de Pedidos"

		oPanel := TPanel():New(0,0,"",oDlgVC080,,.F.,.F.,,,80,80,.T.,.F.)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		oBrwPed:= FWMBrowse():New()
		oBrwPed:SetOwner(oPanel)
		oBrwPed:SetDescription( STR0005 )
		oBrwPed:SetAlias("TEMPD")
		oBrwPed:SetLocate()
		oBrwPed:DisableDetails()
		oBrwPed:DisableConfig()
		oBrwPed:SetAmbiente(.F.)
		oBrwPed:SetWalkthru(.F.)

		oBrwPed:SetFilterDefault(cFilter)

		oBrwPed:SetMenuDef("")
		oBrwPed:AddButton( STR0017 ,{|| oDlgVC080:End()},,1) //"Sair"
		oBrwPed:AddButton( STR0018 ,{|| VC0800095_VisualizaPedido( TEMPD->ZZY_RECVQ0 ) },,2) // "Visualizar"
		
		For nCount := 1 To Len(aCampos4)
			oBrwPed:AddColumn(;
								{	aCampos4[nCount][1],; // Título da coluna
									&("{|| TEMPD->" + aCampos4[nCount][2] + "}"),; // Code-Block de carga dos dados
									aCampos4[nCount][3],; // Tipo de dados
									aCampos4[nCount][6],; // Máscara
									aCampos4[nCount][7],; // Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
									aCampos4[nCount][8],; // Tamanho
									aCampos4[nCount][5],; // Decimal
									.F.,; // Indica se permite a edição
									{||.T.},; // Code-Block de validação da coluna após a edição
									aCampos4[nCount][9],; // Indica se exibe imagem
									{||.T.},; // Code-Block de execução do duplo clique
									NIL,; // Variável a ser utilizada na edição (ReadVar)
									{||.T.},; // Code-Block de execução do clique no header
									.F.,; // Indica se a coluna está deletada
									.F.,; // Indica se a coluna será exibida nos detalhes do Browse
									{}; // Opções de carga dos dados (Ex: 1=Sim, 2=Não)
								};
							)
		Next nCount

		oBrwPed:Activate()

	oDlgVC080:Activate( , , , .t. , , , ) //ativa a janela

Return


/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800085_ChassiFaturado(cFilSai , cNumtra )

	Local cQuery := ""
	Local lRetorno := .f.

	cQuery := ;
			" SELECT VV0.R_E_C_N_O_" +; 
			" FROM " + RetSqlName("VV0") + " VV0 " +; 
			" WHERE VV0.VV0_FILIAL =  '" + cFilSai + "' " +;
				" AND VV0.VV0_NUMTRA = '" + cNumtra + "' " +;
				" AND VV0.VV0_NUMNFI <> ' ' " +;
				" AND VV0.D_E_L_E_T_ = ' ' " +;
				" AND EXISTS ( SELECT SF2.F2_DOC " +;
								" FROM " + RetSqlName("SF2") + " SF2 " +;
								" INNER JOIN " + RetSqlName("SD2") + " SD2 " +;
									"  ON SD2.D2_FILIAL = SF2.F2_FILIAL " +;
									" AND SD2.D2_DOC = SF2.F2_DOC " +;
									" AND SD2.D2_SERIE = SF2.F2_SERIE " +;
									" AND SD2.D2_CLIENTE = SF2.F2_CLIENTE " +;
									" AND SD2.D_E_L_E_T_ = ' ' " +;
									" AND EXISTS ( SELECT SF4.F4_CODIGO " +;
													" FROM " + RetSqlName("SF4") + " SF4 " +;
													" WHERE SF4.F4_FILIAL ='" + xFilial("SF4") + "' " +;
														" AND SF4.F4_CODIGO = SD2.D2_TES " +;
														" AND SF4.F4_OPEMOV = '9' " +;
														" AND SF4.D_E_L_E_T_ = ' ' )" +;
								" WHERE SF2.F2_FILIAL = VV0.VV0_FILIAL " +;
									" AND SF2.F2_DOC = VV0.VV0_NUMNFI " +;
									" AND SF2.F2_SERIE = VV0.VV0_SERNFI " +;
									" AND SF2.D_E_L_E_T_ = ' ' ) "
	If FM_SQL(cQuery) > 0
		lRetorno := .t.
	EndIf

Return lRetorno

/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800095_VisualizaPedido( nRecVQ0 )

	Local oModel := FWLoadModel("VEIA142")
	Local oView  := FWLoadView("VEIA142")

	VQ0->(DbGoTo(nRecVQ0))

	oModel:setOperation(MODEL_OPERATION_VIEW)

	If oModel:Activate()
		oExecView := FWViewExec():New()
		oExecView:setTitle( STR0019 )
		oExecView:setModel(oModel)
		oExecView:setView(oView)
		oExecView:setOK( { || .T. } )
		oExecView:setCancel( { || .T. } )
		CursorArrow()
		oExecView:openView(.T.)
	EndIf

Return


/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800105_MontaTab(dDtIni,dDtFin,nIndiceMes)

	Local aFilAtu	:= FWArrFilAtu()
	Local aSM0		:= FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )

	Local nCont			:= 0 // Contador para ordem da tabela
	Local cQuery		:= ""

	Local cBkpFilAnt	:= cFilAnt
	Local aRetQtds 		:= {0,0,0,0,0}

	Local lFaturado 	:= .f. 
	Local lEntregue 	:= .f.
	Local lNEntregue	:= .f.

	cFilVV1 := ""
	cFilVV2 := ""
	cFilVVR := ""
	cFilVQ0 := ""
	cFilVJR := ""

	For nCont := 1 to Len(aSM0)
		cFilAnt := aSM0[nCont]
		cFilAux := xFilial("VV1")
		cFilVV1 += IIf(!("'"+cFilAux+"'")$cFilVV1,"'"+cFilAux+"',","") // VV1 - inserir Filial caso a mesma nao esteja na variavel de controle
		cFilAux := xFilial("VV2")
		cFilVV2 += IIf(!("'"+cFilAux+"'")$cFilVV2,"'"+cFilAux+"',","") // VV2 - inserir Filial caso a mesma nao esteja na variavel de controle
		cFilAux := xFilial("VVR")
		cFilVVR += IIf(!("'"+cFilAux+"'")$cFilVVR,"'"+cFilAux+"',","") // VVR - inserir Filial caso a mesma nao esteja na variavel de controle
		cFilAux := xFilial("VQ0")
		cFilVQ0 += IIf(!("'"+cFilAux+"'")$cFilVQ0,"'"+cFilAux+"',","") // VQ0 - inserir Filial caso a mesma nao esteja na variavel de controle
		cFilAux := xFilial("VJR")
		cFilVJR += IIf(!("'"+cFilAux+"'")$cFilVJR,"'"+cFilAux+"',","") // VQ0 - inserir Filial caso a mesma nao esteja na variavel de controle
	Next

	cFilVV1 := left(cFilVV1,len(cFilVV1)-1)
	cFilVV2 := left(cFilVV2,len(cFilVV2)-1)
	cFilVVR := left(cFilVVR,len(cFilVVR)-1)
	cFilVQ0 := left(cFilVQ0,len(cFilVQ0)-1)
	cFilVJR := left(cFilVJR,len(cFilVJR)-1)

	cFilAnt := cBkpFilAnt

	cQuery := "SELECT VV2_FILIAL, VV2_CODMAR, VV2_GRUMOD, VV2_MODVEI, VQ0.VQ0_DATPED, VQ0.VQ0_NUMPED, VJR.VJR_ORDNUM, VQ0.VQ0_DATENT, VQ0.R_E_C_N_O_ AS RECVQ0, VV1.VV1_FILSAI, VV1.VV1_NUMTRA "
	cQuery += " FROM "+RetSqlName("VV2")+" VV2 "
	cQuery += " INNER JOIN "+RetSqlName("VV1")+" VV1"
	cQuery += 		" ON VV1.VV1_FILIAL IN (" + cFilVV1 + ") "
	cQuery += 		"AND VV1.VV1_CODMAR = VV2.VV2_CODMAR "
	cQuery += 		"AND VV1.VV1_MODVEI = VV2.VV2_MODVEI "
	cQuery += 		"AND VV1.VV1_SITVEI = '8' " // 8-Pedido
	cQuery += 		"AND VV1.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RetSqlName("VQ0")+" VQ0"
	cQuery += 		" ON VQ0.VQ0_FILIAL IN (" + cFilVQ0 + ") "
	cQuery += 		"AND VQ0.VQ0_CHAINT = VV1.VV1_CHAINT "
	cQuery += 		"AND VQ0.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN "+RetSqlName("VJR")+" VJR"
	cQuery += 		" ON VJR.VJR_FILIAL IN (" + cFilVJR + ") "
	cQuery += 		"AND VJR.VJR_CODVQ0 = VQ0.VQ0_CODIGO "
	cQuery += 		"AND VJR.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN "+RetSqlName("VVR")+" VVR "
	cQuery += 		" ON VVR.VVR_FILIAL IN (" + cFilVVR + ") "
	cQuery += 		"AND VVR.VVR_CODMAR = VV2.VV2_CODMAR "
	cQuery += 		"AND VVR.VVR_GRUMOD = VV2.VV2_GRUMOD "
	cQuery += 		"AND VVR.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VV2.VV2_FILIAL IN (" + cFilVV2 + ") "

	cQuery += 		"AND VQ0.VQ0_DATPED BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFin) + "'"

	cQuery += 		"AND VV2.D_E_L_E_T_ = ' ' " 
	cQuery += " ORDER BY 1"

	TcQuery cQuery New Alias "TMPVV1"

	While !TMPVV1->( EoF() )

		If !(TEMPA->(DbSeek( TMPVV1->VV2_FILIAL + TMPVV1->VV2_CODMAR + TMPVV1->VV2_GRUMOD )))
			// Adicionado endereço 
			RecLock("TEMPA",.T.)

				TEMPA->TMP_FILIAL	:= TMPVV1->VV2_FILIAL
				TEMPA->TMP_MARK		:= cMark
				TEMPA->TMP_MARCA	:= TMPVV1->VV2_CODMAR
				TEMPA->TMP_GRUPO	:= TMPVV1->VV2_GRUMOD

			TEMPA->(MsUnlock())
		EndIf

		If !(TEMPB->(DbSeek( TMPVV1->VV2_FILIAL + TMPVV1->VV2_CODMAR + TMPVV1->VV2_GRUMOD + TMPVV1->VV2_MODVEI )))
			// Adicionado movimentações do endereço.
			RecLock("TEMPB",.T.)
				
				TEMPB->TMP_FILIAL 	:= TEMPA->TMP_FILIAL
				TEMPB->TMP_MARK		:= cMark
				TEMPB->TMP_MARCA 	:= TEMPA->TMP_MARCA
				TEMPB->TMP_GRUPO 	:= TEMPA->TMP_GRUPO
				TEMPB->TMP_MODELO 	:= TMPVV1->VV2_MODVEI
				TEMPB->TMP_INDMOD 	:= nIndMod++

			TEMPB->(MsUnlock())

		EndIf

		TEMPC->(DbSeek( TMPVV1->VV2_FILIAL + PADR(nIndiceMes,3) + TMPVV1->VV2_CODMAR + TMPVV1->VV2_GRUMOD + TMPVV1->VV2_MODVEI ))

		RecLock("TEMPC",!TEMPC->(Found()))
			TEMPC->ZZZ_TPREG	:= .F.
			TEMPC->ZZZ_FILIAL	:= TEMPB->TMP_FILIAL
			TEMPC->ZZZ_MARCA	:= TEMPB->TMP_MARCA
			TEMPC->ZZZ_GRUPO	:= TEMPB->TMP_GRUPO
			TEMPC->ZZZ_MODELO	:= TEMPB->TMP_MODELO
			TEMPC->ZZZ_INDMOD 	:= TEMPB->TMP_INDMOD
			TEMPC->ZZZ_INDMES	:= nIndiceMes
			TEMPC->ZZZ_GRPMOD	:= TEMPC->ZZZ_MARCA + TEMPC->ZZZ_GRUPO + TEMPC->ZZZ_MODELO
			TEMPC->ZZZ_PEDIDO	:= TEMPC->ZZZ_PEDIDO + 1

			
			If !Empty(TMPVV1->VV1_NUMTRA) .and. VC0800085_ChassiFaturado(TMPVV1->VV1_FILSAI,TMPVV1->VV1_NUMTRA)
				lFaturado := .t.
				TEMPC->ZZZ_FATURA	:= TEMPC->ZZZ_FATURA + 1
			EndIf

			If Empty(TMPVV1->VQ0_DATENT)
				lNEntregue := .t.
				TEMPC->ZZZ_NENTR	:= TEMPC->ZZZ_NENTR + 1
			Else
				lEntregue := .t.
				TEMPC->ZZZ_ENTR		:= TEMPC->ZZZ_ENTR + 1
			EndIf
			
			TEMPC->ZZZ_TOTAL	:= TEMPC->ZZZ_FATURA + TEMPC->ZZZ_ENTR + TEMPC->ZZZ_NENTR
		TEMPC->(MsUnlock())

		RecLock("TEMPD",.T.)

			TEMPD->ZZY_FILIAL	:= TEMPB->TMP_FILIAL
			TEMPD->ZZY_MARCA	:= TEMPB->TMP_MARCA
			TEMPD->ZZY_GRUPO	:= TEMPB->TMP_GRUPO
			TEMPD->ZZY_MODELO	:= TEMPB->TMP_MODELO
			TEMPD->ZZY_INDMOD	:= TEMPB->TMP_INDMOD
			TEMPD->ZZY_INDMES	:= nIndiceMes
			TEMPD->ZZY_NUMPED	:= TMPVV1->VQ0_NUMPED
			TEMPD->ZZY_ORDNUM	:= TMPVV1->VJR_ORDNUM
			TEMPD->ZZY_RECVQ0	:= TMPVV1->RECVQ0

			If lFaturado
				TEMPD->ZZY_FATURA	:= "pcofxok.png"
			Else
				TEMPD->ZZY_FATURA	:= "pcofxcancel.png"
			EndIf

			If lEntregue
				TEMPD->ZZY_ENTR	:= "pcofxok.png"
			Else
				TEMPD->ZZY_ENTR	:= "pcofxcancel.png"
			EndIf

		TEMPD->(MsUnlock())

		TMPVV1->( dbSkip() )

	EndDo

	aRetQtds[1] += TEMPC->ZZZ_TOTAL
	aRetQtds[2] += TEMPC->ZZZ_PEDIDO
	aRetQtds[3] += TEMPC->ZZZ_FATURA
	aRetQtds[4] += TEMPC->ZZZ_ENTR
	aRetQtds[5] += TEMPC->ZZZ_NENTR

	TMPVV1->(DbCloseArea())

Return aRetQtds

/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800115_MarkRegistro( oMarkBrow , cAliasTmp, nBrwMrk )

	RecLock((cAliasTmp),.f.)
		(cAliasTmp)->TMP_MARK := IF( !Empty((cAliasTmp)->TMP_MARK), "  ", cMark )
	(cAliasTmp)->(MsUnlock())

	If nBrwMrk == 1
		VC0800065_LimpaMarkModelo((cAliasTmp)->TMP_MARCA,(cAliasTmp)->TMP_GRUPO,(cAliasTmp)->TMP_MARK)
	EndIf

	VC0800035_BlocoExecFiltro(nBrwMrk)

Return( Nil )

/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800125_MarkAllRegistro( oMarkBrow , cAliasTmp, nBrwMrk )

	Local aArea 	 := GetArea()
	Local aAreaAlias := (cAliasTmp)->( GetArea() )

	(cAliasTmp)->( DbGoTop() )

	While (cAliasTmp)->( !EOF() )

		RecLock(((cAliasTmp)),.f.)
			(cAliasTmp)->TMP_MARK := IF( !Empty((cAliasTmp)->TMP_MARK), "  ", cMark )
		(cAliasTmp)->(MsUnlock())

		If nBrwMrk == 1
			VC0800065_LimpaMarkModelo((cAliasTmp)->TMP_MARCA,(cAliasTmp)->TMP_GRUPO,(cAliasTmp)->TMP_MARK)
		EndIf

		(cAliasTmp)->( DbSkip() )

	EndDo

	VC0800035_BlocoExecFiltro(nBrwMrk)

	RestArea( aAreaAlias )
	RestArea( aArea )

Return( Nil )

/*/{Protheus.doc} VEIC080

@author Renato Vinicius
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VC0800135_ColBMark(cAliasTmp)
	Local lRet := 'LBNO'
	
	If !Empty((cAliasTmp)->TMP_MARK)
		lRet := 'LBOK'
	EndIf
	
Return lRet