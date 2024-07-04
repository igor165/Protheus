#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

#INCLUDE "VEIC030.CH"

#DEFINE lDebug .F.

Static oPrincipal
Static oMModeloSel
Static lChamadaPedVen := .t.

/*/{Protheus.doc} VEIC030
	(long_description)
	@type  Function
	@author Takahashi
	@since 11/11/2018
	@version 1
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function VEIC030(oParConsulta, oModelVRK)

	Local aRetConsulta := {}

	Local oModel
	Local oView 
	Local oModelPar

	Default oParConsulta := DMS_DataContainer():New()

	lChamadaPedVen := (oParConsulta:Count() > 0)

	oModel := FWLoadModel("VEIC030")
	oView := FWLoadView("VEIC030")

	If lChamadaPedVen
		oView:SetViewProperty("PARMASTER", "ONLYVIEW")
	EndIf

	CursorWait()
	oModel:setOperation(MODEL_OPERATION_INSERT)
	If ! oModel:Activate()
		MostraErro()
		CursorArrow()
		Return .f.
	EndIf

	oModelPar := oModel:GetModel("PARMASTER")
	If oParConsulta:Count() > 0
		oModelPar:LoadValue("PARCODMAR" , oParConsulta:GetValue("PARCODMAR") ) // "HYU" )
		oModelPar:LoadValue("PARMODVEI" , oParConsulta:GetValue("PARMODVEI") ) // "GBZ5" )
		oModelPar:LoadValue("PARSEGMOD" , oParConsulta:GetValue("PARSEGMOD") ) // "1K20K42S" )
		oModelPar:LoadValue("PAROPCION" , oParConsulta:GetValue("PAROPCION") ) // "K42S" )
		oModelPar:LoadValue("PARCOREXT" , oParConsulta:GetValue("PARCOREXT") ) // "1K " )
		oModelPar:LoadValue("PARCORINT" , oParConsulta:GetValue("PARCORINT") ) // "20 " )
		oModelPar:LoadValue("PARFABMOD" , oParConsulta:GetValue("PARFABMOD") ) // "20 " )
		oModelPar:LoadValue("PARVENDIDO" , oParConsulta:GetValue("PARVENDIDO") )
		oModelPar:LoadValue("PARSELEC" , oParConsulta:GetValue("PARSELEC") )
	EndIf

	// Carrega dados da GRID
	lContinua := CONS_VEIC(oModel, lChamadaPedVen)
	//
	
	CursorArrow()
	If lContinua
		oExecView := FWViewExec():New()
		oExecView:setTitle(STR0001) // "Consulta Chassi por Modelo"
		oExecView:setModel(oModel)
		oExecView:setView(oView)
		oExecView:setOK( { || VC0300023_ButtonOK(@aRetConsulta) })
		oExecView:setCancel( { || .T. } )
		oExecView:setOperation(MODEL_OPERATION_UPDATE)
		oExecView:openView(.T.)
	EndIf

Return aClone(aRetConsulta)


Static Function ModelDef()

	Local oModel 

	Local oPrinStru
	Local oModeloSelStru

	If oPrincipal == NIL
		oPrincipal := VC0300013_Master(lChamadaPedVen)
		oMModeloSel := VC0300033_ModeloSelecionados()
	EndIf

	oPrinStru  := oPrincipal:GetModel()
	oModeloSelStru := oMModeloSel:GetModel()

	// Atualiza variavel private utilizada em consulta padrao 
	aAuxTrigger := FwStruTrigger("PARCODMAR","PARCODMAR","cFilCodMar := FWFldGet('PARCODMAR')",.F.,"")
	oPrinStru:AddTrigger(aAuxTrigger[1],aAuxTrigger[2],aAuxTrigger[3],aAuxTrigger[4])
	//

	oModel := MPFormModel():New( 'VEIC030', /* bPre */, /* bPost */ , { || .t. } /* bCommit */ , { || .T. } /* bCancel */ )
	oModel:AddFields('PARMASTER', /* cOwner */ , oPrinStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ { || } )
	oModel:AddGrid('LISTA_CHASSI','PARMASTER',oModeloSelStru, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )

	oModel:SetDescription(STR0002) // 'Consulta de Estoque de Veículos por Modelo'
	oModel:GetModel('PARMASTER'):SetDescription(STR0003) //  'Parametros da Consulta'
	oModel:GetModel('LISTA_CHASSI'  ):SetDescription(STR0004) //  'Lista de Modelos Selecionados'

	oModel:GetModel('PARMASTER'):SetOnlyQuery( .T. )
	oModel:GetModel('LISTA_CHASSI'  ):SetOnlyQuery( .T. )
	oModel:GetModel('LISTA_CHASSI'  ):SetOptional( .T. )

	oModel:SetPrimaryKey({})
//	oModel:SetActivate( { |oModel| VC0100063_ActivateModel(oModel) , .T.} )

//	oModel:InstallEvent("LOG",,MVCLogEv():New("VEIC030"))
	oModel:InstallEvent("PADRAO",,VEIC030EVDEF():New())

Return oModel



Static Function ViewDef()
	Local oModel	:= FWLoadModel( 'VEIC030' )
	Local oView 	:= Nil

	Local oPrinStru  := oPrincipal:GetView()
	Local oModeloSelStru := oMModeloSel:GetView()

	If ! lChamadaPedVen
		oPrinStru:RemoveField("PARVENDIDO")
		oPrinStru:RemoveField("PARSELEC")
		oModeloSelStru:RemoveField('SELCHASSI')
	Endif

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_PARAM', oPrinStru , 'PARMASTER')
	oView:AddGrid('GRID_LISTA_CHASSI', oModeloSelStru , 'LISTA_CHASSI')

	oView:EnableTitleView('FORM_PARAM', 'Parametros')

	oView:SetNoInsertLine('GRID_LISTA_CHASSI')
	oView:EnableTitleView('GRID_LISTA_CHASSI'	,STR0005 ) // 'Lista de Chassis em Estoque'

	oView:CreateHorizontalBox('TELA_PARAM', 170,,.t.)
	oView:CreateHorizontalBox('TELA_LISTA' ,100)


	oView:SetOwnerView('FORM_PARAM','TELA_PARAM')
	oView:SetOwnerView('GRID_LISTA_CHASSI','TELA_LISTA')

	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o 
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 

	//Executa a ação no acionamento do botão confirmar da View
	//	oView:SetViewAction("BUTTONOK", {|oView| VC0100053_ButtonOK(oView,"SetViewAction") })

	//Desabilita order no grid
	//	oView:SetViewProperty( "*", "GRIDNOORDER")

	oView:SetViewProperty("GRID_LISTA_CHASSI", "GRIDSEEK", {.T.})
	//	oView:SetViewProperty('FORM_PARAM','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP , 2})
	
	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView



Static Function VC0300013_Master(lChamadaPedVen)
	Local oRetorno := OFDMSStruct():New()
	Local aParAdd

	Local lCanEdit := ! lChamadaPedVen

	aParAdd := { ;
		{ "lVirtual" , .t. } ,;
		{ "lCanChange" , .f. } ;
	}

	oRetorno:AddFieldDictionary( "VV2" , "VV2_CODMAR" , { {"cIdField" , "PARCODMAR"} , { "lVirtual", .t. } , { "lCanChange" , lCanEdit } } )
	oRetorno:AddFieldDictionary( "VV2" , "VV2_MODVEI" , { {"cIdField" , "PARMODVEI"} , { "lVirtual", .t. } , { "lCanChange" , lCanEdit } } )
	oRetorno:AddFieldDictionary( "VV2" , "VV2_SEGMOD" , { {"cIdField" , "PARSEGMOD"} , { "lVirtual", .t. } , { "lCanChange" , lCanEdit } } )
	If VV2->(ColumnPos('VV2_CORINT')) > 0
		oRetorno:AddFieldDictionary( "VV2" , "VV2_OPCION" , { {"cIdField" , "PAROPCION"} , { "lVirtual", .t. } , { "lCanChange" , lCanEdit } } )
		oRetorno:AddFieldDictionary( "VV2" , "VV2_COREXT" , { {"cIdField" , "PARCOREXT"} , { "lVirtual", .t. } , { "lCanChange" , lCanEdit } } )
		oRetorno:AddFieldDictionary( "VV2" , "VV2_CORINT" , { {"cIdField" , "PARCORINT"} , { "lVirtual", .t. } , { "lCanChange" , lCanEdit } } )
	EndIf
	oRetorno:AddFieldDictionary( "VV1" , "VV1_FABMOD" , { {"cIdField" , "PARFABMOD"} , { "lVirtual", .t. } , { "lCanChange" , lCanEdit } } )

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0006 } ,; // "Quantidade"
		{ "cTooltip" , STR0006 } ,; // "Quantidade"
		{ "cIdField" , "PARVENDIDO" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 3 } ,;
		{ "lCanChange" , .f. } ,;
		{ "cPicture" , "@E 999"} ,;
		{ "lVirtual" , .t. } ;
	})
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0007 } ,; // "Quantidade Vinculada"
		{ "cTooltip" , STR0006 } ,; // "Quantidade"
		{ "cIdField" , "PARSELEC" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 3 } ,;
		{ "lCanChange" , .f. } ,;
		{ "cPicture" , "@E 999"} ,;
		{ "lVirtual" , .t. } ;
	})


//	oRetorno:AddButton('Pesquisar','BTNPESQUISA',{ |oMdl| VC0100073_AtualizaGridModelos(oMdl) })
Return oRetorno

Static Function VC0300033_ModeloSelecionados()

	Local oRetorno := OFDMSStruct():New()
//	Local nOrdem := 2
//	Local bAuxValid := FWBuildFeature(STRUCT_FEATURE_VALID, ".t." )
	Local aParAdd

	aParAdd := { ;
		{ "lVirtual" , .t. } ,;
		{ "lCanChange" , .f. } ;
	}

	oRetorno:AddSelect('','SELCHASSI', , .T.)

	oRetorno:AddFieldDictionary( "VV1", "VV1_CODMAR" , aParAdd )
	oRetorno:AddFieldDictionary( "VV1", "VV1_MODVEI" , aParAdd )
	oRetorno:AddFieldDictionary( "VV1", "VV1_SEGMOD" , aParAdd )
	If VV2->(ColumnPos('VV2_CORINT')) > 0
		oRetorno:AddFieldDictionary( "VV2", "VV2_OPCION" , aParAdd )
		oRetorno:AddFieldDictionary( "VV2", "VV2_COREXT" , aParAdd )
		oRetorno:AddFieldDictionary( "VV2", "VV2_CORINT" , aParAdd )
	EndIF
	oRetorno:AddFieldDictionary( "VV1", "VV1_CHAINT" , aParAdd )
	oRetorno:AddFieldDictionary( "VV1", "VV1_CHASSI" , aParAdd )
	oRetorno:AddFieldDictionary( "VV1", "VV1_FABMOD" , aParAdd )
	oRetorno:AddFieldDictionary( "VV1", "VV1_FABANO" , aParAdd )
	oRetorno:AddFieldDictionary( "VV1", "VV1_FABMES" , aParAdd )
	oRetorno:AddFieldDictionary( "VV1", "VV1_COMVEI" , aParAdd )

	oRetorno:AddField({{ 'cIdField' , 'DIAESTQ' },;
							 { 'cTitulo' , STR0008 },; // 'Dias de Estoque'
							 { 'cTipo' , 'N' },;
							 { 'nTamanho' , 5 },;
							 { 'nDecimal' , 0 },;
							 { 'cPicture' , '@! 99999' } } )


Return oRetorno





Static Function CONS_VEIC(oModel, lChamadaPedVen)

	Local cQuery
	Local oSQLHelper := DMS_SqlHelper():New()

	Local cFuncStr := oSQLHelper:CompatFunc("SUBSTR")

	Local cStrConvData
	Local aStrConv := {}

	Local cQAlSQL := "TTMPVV1"

	Local oModelPar := oModel:GetModel("PARMASTER")
	Local oMGrid_Selecionados := oModel:GetModel("LISTA_CHASSI")

	Local nQtdAdd := 0

	Local cFiltroSBF := ""

	If lChamadaPedVen
		cFiltroSBF := " AND EXISTS ( SELECT SBF.BF_NUMSERI " +;
											  " FROM " + RetSQLName("SBF") + " SBF " +;
										   " WHERE SBF.BF_FILIAL = '" + FWxFilial("SBF") + "'" +;
											   " AND SBF.BF_NUMSERI = VV1.VV1_CHASSI " +;
											   " AND SBF.BF_QUANT > 0" +;
											   " AND SBF.D_E_L_E_T_ = ' ' )"
	EndIf

	aStrConv := {;
		"'20'" , cFuncStr + "(VV1_DTHVAL,7,2)" , "'-'" ,;
		cFuncStr + "(VV1_DTHVAL,4,2)" , "'-'" ,;
		cFuncStr + "(VV1_DTHVAL,1,2)" , "' '" ,;
		cFuncStr + "(VV1_DTHVAL,10,2)" , "':'" ,; 
		cFuncStr + "(VV1_DTHVAL,12,2)" , "':59'";
	}
	cStrConvData := oSQLHelper:Concat(aStrConv)
	cStrConvData := oSQLHelper:ConvToDate(cStrConvData,,'YYYY-MM-DD HH24:MI:SS')

	cQueryUMov := oSQLHelper:TOPFunc( ;
		"SELECT VVF_DATMOV, " +;
				"'20' || SUBSTR(VVF_DTHEMI, 7, 2) || '-' || SUBSTR(VVF_DTHEMI, 4, 2) || '-' || SUBSTR(VVF_DTHEMI, 1, 2) || ' ' || SUBSTR(VVF_DTHEMI, 10, 8)" +;
			" FROM " + RetSQLName("VVF") + " VVF " +;
			" INNER JOIN " + RetSQLName("VVG") + " VVG " +;
					" ON VVG.VVG_FILIAL = VVF.VVF_FILIAL" +;
					" AND VVG.VVG_TRACPA = VVF.VVF_TRACPA" +;
					" AND VVG.D_E_L_E_T_ = ' '" +;
			" WHERE VVG.VVG_CHAINT = VV1.VV1_CHAINT" +;
			" AND VVF.VVF_SITNFI <> '0'" +;
			" AND VVF.VVF_OPEMOV = '0'" +;
			" AND VVF.D_E_L_E_T_ = ' '" +;
			" ORDER BY 2 DESC" , 1 )
	
	oMGrid_Selecionados:SetNoInsertLine(.f.)

	If oMGrid_Selecionados:CanClearData() 
		oMGrid_Selecionados:ClearData(.t., .f.)
	EndIf

	cQuery := ;
		"SELECT TEMP.* " +;
  		 " FROM ( " +;
					"SELECT " +;
					" CASE VV1.VV1_DTHVAL " +;
						" WHEN ' ' THEN TO_DATE('') " +;
						" ELSE " + cStrConvData +;
					" END DTHVAL, " +;
					" VV1_RESERV, VV1_CODMAR, VV1_MODVEI, VV1_SEGMOD, VV2_OPCION, VV2_COREXT, VV2_CORINT, VV1_CHAINT, VV1_CHASSI, VV1_FABMOD, VV1_FABANO, VV1_FABMES, VV1_COMVEI, " +;
					"( SELECT COALESCE( TRUNC(SYSDATE - TO_DATE(VVF_DATMOV, 'YYYYMMDD'), 0), 0 ) DIAESTQ FROM (" + cQueryUMov + ") ) DIAESTQ, " +;
					" CASE " +;
						" WHEN ( " +;
									" SELECT COUNT(*)" +;
									" FROM " + RetSqlName("VRK") + " VRKCONS " +;
											" JOIN " + RetSqlName("VRJ") + " VRJCONS " +;
												"  ON VRJCONS.VRJ_FILIAL = VRKCONS.VRK_FILIAL " +;
												" AND VRJCONS.VRJ_PEDIDO = VRKCONS.VRK_PEDIDO " +;
												" AND VRJCONS.D_E_L_E_T_ = ' ' " +;
									" WHERE VRKCONS.VRK_FILIAL = '" + FWxFilial("VRK") + "'" +;
									" AND VRKCONS.VRK_CHAINT = VV1.VV1_CHAINT" +;
									" AND VRKCONS.VRK_CANCEL IN ('0',' ') " +;
									" AND ( VRJCONS.VRJ_STATUS NOT IN ('C','R','F') OR (VRJCONS.VRJ_STATUS = 'F' AND VRKCONS.VRK_NUMTRA = ' ' ) )" +;
									" AND VRKCONS.D_E_L_E_T_ = ' '" +;
								" ) > 0" +;
							" THEN 'P' " +; // Veiculo já selecionado em pedido de venda de montadora
						" WHEN ( " +;
									" SELECT COUNT(*) " +;
									" FROM " + RetSqlName("VB0") + " VB0" +;
									" WHERE VB0_FILIAL = '" + xFilial("VB0") + "' " +;
										" AND VB0.VB0_CHAINT = VV1.VV1_CHAINT" +;
										" AND VB0.VB0_DATDES = ' ' " +;
										" AND ( VB0.VB0_DATVAL > '" + DtoS(dDataBase) + "' OR ( VB0.VB0_DATVAL = '" + DtoS(dDataBase) + "' AND VB0.VB0_HORVAL > '" + StrTran(Left(Time(),5),":","") + "' ))" +;
										" AND VB0.D_E_L_E_T_ = ' ' " +;
								" ) > 0" +;
							" THEN 'B' " +; // Veiculo Bloqueado
						" WHEN ( " +;
									"SELECT COUNT(*) " +;
									" FROM " + RetSQLName("VVA") + " VVA " +;
											"JOIN " + RetSQLName("VV0") + " VV0 ON VV0.VV0_FILIAL = VVA.VVA_FILIAL AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_ = ' ' " +;
											"JOIN " + RetSQLName("VV9") + " VV9 ON VV9.VV9_FILIAL = VVA.VVA_FILIAL AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA AND VV9.D_E_L_E_T_ = ' ' " +;
									" WHERE VVA.VVA_FILIAL = '" + xFilial("VVA") + "'" + ;
										" AND VVA.VVA_CHAINT = VV1.VV1_CHAINT " +;
										" AND VVA.D_E_L_E_T_ = ' '" +;
										" AND VV9.VV9_STATUS NOT IN ('C','F','T','R','D')" +;
								" ) > 0" +;
							" THEN 'A' " +; // Veiculo em Atendimento
						" ELSE ' '" +; // Veiculo pode ser selecionado 
					" END BLOQ" +;
					" FROM " + RetSqlName("VV1") + " VV1 " +;
						" INNER JOIN " + RetSqlName("VV2") + " VV2 " +;
								"  ON VV2.VV2_FILIAL = '" + xFilial("VV2") + "' " +;
								" AND VV2.VV2_CODMAR = VV1.VV1_CODMAR " +;
								" AND VV2.VV2_MODVEI = VV1.VV1_MODVEI " +;
								" AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD " +;
								" AND VV2.D_E_L_E_T_ = ' ' " +;
						" LEFT JOIN " + RetSqlName("VVC") + " VVC " +; 
								"  ON VVC.VVC_FILIAL = '" + xFilial("VVC") + "'" +;
								" AND VVC.VVC_CODMAR=VV1.VV1_CODMAR " +;
								" AND VVC.VVC_CORVEI=VV1.VV1_CORVEI " +;
								" AND VVC.D_E_L_E_T_=' ' " +;
					"WHERE VV1.VV1_FILIAL = '" + xFilial("VV1") + "'" +;
					 " AND VV1.VV1_FILENT = '" + cFilAnt + "'" +;
					 IIf ( Empty(oModelPar:GetValue("PARCODMAR")), "" , " AND VV1.VV1_CODMAR = '" + oModelPar:GetValue("PARCODMAR")  + "' ") +;
					 IIf ( Empty(oModelPar:GetValue("PARMODVEI")), "" , " AND VV2.VV2_MODVEI = '" + oModelPar:GetValue("PARMODVEI")  + "' ") +;
					 IIf ( Empty(oModelPar:GetValue("PARSEGMOD")), "" , " AND VV2.VV2_SEGMOD = '" + oModelPar:GetValue("PARSEGMOD")  + "' ") +;
					 IIf ( Empty(oModelPar:GetValue("PAROPCION")), "" , " AND VV2.VV2_OPCION = '" + oModelPar:GetValue("PAROPCION")  + "' ") +;
					 IIf ( Empty(oModelPar:GetValue("PARCOREXT")), "" , " AND VV2.VV2_COREXT = '" + oModelPar:GetValue("PARCOREXT")  + "' ") +;
					 IIf ( Empty(oModelPar:GetValue("PARCORINT")), "" , " AND VV2.VV2_CORINT = '" + oModelPar:GetValue("PARCORINT")  + "' ") +;
					 IIf ( Empty(oModelPar:GetValue("PARFABMOD")), "" , " AND VV1.VV1_FABMOD = '" + oModelPar:GetValue("PARFABMOD")  + "' ") +;
					 " AND VV1.VV1_ESTVEI = '0' " +;
					 " AND ( ( VV1.VV1_SITVEI='0' AND VV1.VV1_TRACPA<>' ' ) OR VV1.VV1_SITVEI IN ('2','8') )" +;
					 " AND VV1.VV1_IMOBI <> '1' " +;
				 	 " AND VV1.D_E_L_E_T_=' '" +;
					 cFiltroSBF +;
			" ) TEMP " +;
		 " WHERE " +;
		 	"(" +;
				" ( TEMP.VV1_RESERV IN ('1','3') AND SYSDATE > TEMP.DTHVAL ) " +;
				" OR " +;
				 "TEMP.VV1_RESERV NOT IN ('1','3') " +;
			")" +;
			" AND TEMP.BLOQ = ' '" +;
	" ORDER BY TEMP.DIAESTQ, TEMP.VV1_CHASSI "
	
	If lDebug
		CopytoClipBoard(cQuery)
	EndIf

	nQtdAdd := 0

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
	While !( cQAlSQL )->( Eof() )

		oMGrid_Selecionados:AddLine()
		oMGrid_Selecionados:SetValue("VV1_CODMAR" , (cQAlSQL)->VV1_CODMAR )
		oMGrid_Selecionados:SetValue("VV1_MODVEI" , (cQAlSQL)->VV1_MODVEI )
		oMGrid_Selecionados:SetValue("VV1_SEGMOD" , (cQAlSQL)->VV1_SEGMOD )
		oMGrid_Selecionados:SetValue("VV2_OPCION" , (cQAlSQL)->VV2_OPCION )
		oMGrid_Selecionados:SetValue("VV2_COREXT" , (cQAlSQL)->VV2_COREXT )
		oMGrid_Selecionados:SetValue("VV2_CORINT" , (cQAlSQL)->VV2_CORINT )
		oMGrid_Selecionados:SetValue("VV1_CHAINT" , (cQAlSQL)->VV1_CHAINT )
		oMGrid_Selecionados:SetValue("VV1_CHASSI" , (cQAlSQL)->VV1_CHASSI )
		oMGrid_Selecionados:SetValue("VV1_FABMOD" , (cQAlSQL)->VV1_FABMOD )
		oMGrid_Selecionados:SetValue("VV1_FABANO" , (cQAlSQL)->VV1_FABANO )
		oMGrid_Selecionados:SetValue("VV1_FABMES" , (cQAlSQL)->VV1_FABMES )
		oMGrid_Selecionados:SetValue("VV1_COMVEI" , (cQAlSQL)->VV1_COMVEI )
		oMGrid_Selecionados:SetValue("DIAESTQ" , (cQAlSQL)->DIAESTQ )

		( cQAlSQL )->( DbSkip() )

		If lChamadaPedVen
			nQtdAdd++
			If nQtdAdd >= (oModelPar:GetValue("PARVENDIDO") - oModelPar:GetValue("PARSELEC"))
				Exit
			EndIf
		EndIf

	EndDo
	( cQAlSQL )->( dbCloseArea() )

	oMGrid_Selecionados:SetNoInsertLine(.t.)
	If oMGrid_Selecionados:Length() >= 1
		oMGrid_Selecionados:GoLine(1)
	Else
		MsgInfo(STR0009) // "Não existe veículos disponíveis para os parâmetros informados."
		Return .f.
	EndIf

Return .t.

Static Function VC0300023_ButtonOK(aRetConsulta)

	Local oModel     := FWModelActive()
	Local oMGrid_Selecionados  := oModel:GetModel("LISTA_CHASSI")
	Local nQtdLines  := oMGrid_Selecionados:Length()
	Local nX
	Local aAuxRet := {}
	
	For nX := 1 to nQtdLines

		If oMGrid_Selecionados:IsDeleted(nX)
			Loop
		EndIf
		oMGrid_Selecionados:GoLine(nX)

		If ! oMGrid_Selecionados:GetValue("SELCHASSI")
			Loop
		EndIf

		AADD( aAuxRet , { oMGrid_Selecionados:GetValue("VV1_CHAINT") , oMGrid_Selecionados:GetValue("VV1_CHASSI")} )
		
	Next nX
	If Len(aAuxRet) > 0
		aRetConsulta := aClone(aAuxRet)
	EndIf

Return .t.

Function VC0300043_ChassiJaSelecionado(cChaInt, cNumPedido)
	Local cAlChassiJaSel := "TVRKPED"
	Local lRetorno := .f.

	cNumPedido := ""
	
	BeginSQL Alias cAlChassiJaSel
		
		SELECT VRK.VRK_PEDIDO
		FROM 
			%table:VRK% VRK
			JOIN 
				%table:VRJ% VRJ 
					ON VRJ.VRJ_FILIAL = VRK.VRK_FILIAL 
					AND VRJ.VRJ_PEDIDO = VRK.VRK_PEDIDO 
					AND VRJ.VRJ_STATUS NOT IN ('F','C')
					AND VRJ.D_E_L_E_T_ = ' ' 
		WHERE VRK.VRK_FILIAL = %xFilial:VRK%
			AND VRK.VRK_CHAINT = %exp:cChaInt%
			AND VRK.VRK_CANCEL IN ('0',' ') 
			AND VRK.%notDel% 
	EndSql

	If ! (cAlChassiJaSel)->(Eof()) .and. !Empty((cAlChassiJaSel)->VRK_PEDIDO)
		lRetorno := .t.
	End
	(cAlChassiJaSel)->(dbCloseArea())

Return lRetorno
