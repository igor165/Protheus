#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

#INCLUDE "VEIA030A.CH"

Static oPrV030AMaster
Static oMGrpMod
Static oMGrpModSel
Static lCheckGrupo
Static lCheckModelo

/*/{Protheus.doc} VEIA030A
Funcao de replicacao do campo de comercializacao entre modelos de uma marca

@author Rubens
@since 28/11/2018
@version 1.0


@type function
/*/
Function VEIA030A()

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0001) // "Replica Comercialização"
	oExecView:setSource("VEIA030A")
	oExecView:setOK( { || VA0300103A_GravaComercializa() })
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

Return .T.

Static Function ModelDef()
	Local oModel

	Local oPrinStru
	Local oGrpModelStru
	Local oGrpModSelStru

	Local bLoadModel

	If oPrV030AMaster == NIL
		oPrV030AMaster := VA0300013A_Master()
		oMGrpMod := VA0300033A_GrupoModelo()
		oMGrpModSel := VA0300043A_ModeloSelecionado()
		lCheckGrupo := .f.
		lCheckModelo := .f.
	EndIf

	oPrinStru  := oPrV030AMaster:GetModel()
	oGrpModelStru := oMGrpMod:GetModel()
	oGrpModSelStru := oMGrpModSel:GetModel()

	bLoadModel := { |oGridModel, lCopy| VA0300023A_LoadGrupoMod(oGridModel, lCopy) }

	aAuxTrigger := FwStruTrigger("MODSELMOD","MODSELMOD","VA0300093A_LoadModelos()",.F.,"")
	oGrpModelStru:AddTrigger(aAuxTrigger[1],aAuxTrigger[2],aAuxTrigger[3],aAuxTrigger[4])

	oModel := MPFormModel():New( 'VEIA030A', /* bPre */, /*bPost*/ , /* bCommit */ , /* bCancel */ )
	oModel:AddFields('PARMASTER', /* cOwner */ , oPrinStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ { || } )

	oModel:AddGrid('GRPMOD','PARMASTER',oGrpModelStru, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, bLoadModel )
	oModel:AddGrid('GRPMOD_SELECIONADOS','PARMASTER',oGrpModSelStru, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )

	oModel:SetDescription(STR0002) // 'Replicar Comercialização'
	oModel:GetModel('PARMASTER'):SetDescription(STR0003) // 'Parâmetros da Alteração'
	oModel:GetModel('GRPMOD'  ):SetDescription(STR0004) // 'Lista de Grupo de Modelos'
	oModel:GetModel('GRPMOD_SELECIONADOS'  ):SetDescription(STR0005) // 'Lista de Modelos Selecionados'

	oModel:GetModel('PARMASTER'):SetOnlyQuery( .T. )
	oModel:GetModel('GRPMOD'  ):SetOnlyQuery( .T. )
	oModel:GetModel('GRPMOD_SELECIONADOS'  ):SetOnlyQuery( .T. )

	oModel:GetModel('GRPMOD'  ):SetOptional( .T. )
	oModel:GetModel('GRPMOD_SELECIONADOS'  ):SetOptional( .T. )

	oModel:SetPrimaryKey({})
	oModel:SetActivate( { |oModel| VC0100063_ActivateModel(oModel) , .T.} )

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel('VEIA030A')

	Local oView := NIL

	Local oPrinStru := oPrV030AMaster:GetView()

	Local oGrpModelStru := oMGrpMod:GetView()
	Local oGrpModSelStru := oMGrpModSel:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_PARAM',oPrinStru, 'PARMASTER')

	oGrpModSelStru:RemoveField('VV2REC')

	oView:AddGrid('GRID_GRPMOD', oGrpModelStru, 'GRPMOD')
	oView:AddGrid('GRID_GRPMOD_SEL', oGrpModSelStru , 'GRPMOD_SELECIONADOS')

	oView:AddOtherObject('GRID_GRPMOD_BTNSELTODOS', { |oPanel| VA0300053A_GrupoModelosBtnSelTodos(oPanel) })
	oView:AddOtherObject('GRID_GRPMOD_SEL_BTNSELTODOS', { |oPanel| VA0300073A_ModelosSelBtnSelTodos(oPanel) })

	oView:EnableTitleView('FORM_PARAM', STR0006 ) // 'Parâmetros'

	oView:SetNoInsertLine('GRID_GRPMOD')
	oView:SetNoDeleteLine('GRID_GRPMOD')
	oView:EnableTitleView('GRID_GRPMOD'	, STR0007 ) // 'Grupo de Modelos'

	oView:SetNoDeleteLine('GRID_GRPMOD')
	oView:SetNoInsertLine('GRID_GRPMOD_SEL')
	oView:EnableTitleView('GRID_GRPMOD_SEL'	, STR0008 ) // 'Modelos Selecionados'

	oView:CreateHorizontalBox('TELA_SELECAO',40)
	oView:CreateHorizontalBox('TELA_GRPMOD_SEL_GRID',60)
	oView:CreateHorizontalBox('TELA_GRPMOD_SEL_BTNSELTODOS', 30, ,.T.)

	oView:createVerticalBox('TELA_PARAM', 300, 'TELA_SELECAO' , .T.)
	oView:createVerticalBox('TELA_GRPMOD', 100, 'TELA_SELECAO')

	oView:CreateHorizontalBox('TELA_GRPMOD_GRID', 100, 'TELA_GRPMOD')
	oView:CreateHorizontalBox('TELA_GRPMOD_BTNSELTODOS', 30, 'TELA_GRPMOD',.T.)

	oView:SetOwnerView('FORM_PARAM','TELA_PARAM')
	
	oView:SetOwnerView('GRID_GRPMOD'            ,'TELA_GRPMOD_GRID')
	oView:SetOwnerView('GRID_GRPMOD_BTNSELTODOS', 'TELA_GRPMOD_BTNSELTODOS')

	oView:SetOwnerView('GRID_GRPMOD_SEL','TELA_GRPMOD_SEL_GRID')
	oView:SetOwnerView('GRID_GRPMOD_SEL_BTNSELTODOS', 'TELA_GRPMOD_SEL_BTNSELTODOS')

	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o 
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 

	oView:SetViewProperty('FORM_PARAM','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP , 2})

	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

//	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView


Static Function VA0300023A_LoadGrupoMod(oModel, lCopy)
	Local aLoad := {}
	Local oSQL := DMS_SQLHelper():New()
	Local cSQL

	cSQL := ;
		"SELECT ' ' , VVR.VVR_CODMAR , VVR.VVR_GRUMOD , VVR.VVR_DESCRI " + ;
		 " FROM " + RetSqlName("VVR") + " VVR " + ;
		" WHERE VVR.VVR_FILIAL = '" + xFilial("VVR") + "' " + ;
		  " AND VVR.D_E_L_E_T_ = ' '" + ;
		  " AND EXISTS( SELECT R_E_C_N_O_ " + ;
							 " FROM " + RetSQLName("VV2") + " VV2 " + ;
							" WHERE VV2.VV2_FILIAL = '" + xFilial("VV2") + "'" + ;
							  " AND VV2.VV2_CODMAR = VVR_CODMAR " + ;
							  " AND VV2.VV2_GRUMOD = VVR_GRUMOD " + ;
							  " AND VV2.D_E_L_E_T_ = ' ' " + ;
							" ) " + ;
		" ORDER BY VVR.VVR_CODMAR , VVR.VVR_GRUMOD , VVR.VVR_DESCRI "
	aLoad := oSQL:GetSelectMVC(cSQL,4)
	aEval(aLoad, { |x| x[2,1] := .f. })
Return aLoad

Static Function VA0300013A_Master()

	Local oRetorno := OFDMSStruct():New()
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0009 } ,; // "Comercializa"
		{ "cTooltip" , STR0009 } ,; // "Comercializa"
		{ "cIdField" , "PARCOMERC" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 1 } ,;
		{ "aComboValues" , {"0=Nao Comercializa","1=Comercializa" } } ,;
		{ "bValid" , FWBuildFeature(STRUCT_FEATURE_VALID,"Pertence('01')") } ,;
		{ "bInit" , FWBuildFeature(STRUCT_FEATURE_INIPAD ,"'1'") } ;
	})

Return oRetorno

Static Function VA0300033A_GrupoModelo()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','MODSELMOD', , .t.)

	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle("VV2_CODMAR") } ,;
		{ "cTooltip" , RetTitle("VV2_CODMAR") } ,;
		{ "cIdField" , "MODCODMAR" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSX3Cache("VV2_CODMAR","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle("VV2_GRUMOD") } ,;
		{ "cTooltip" , RetTitle("VV2_GRUMOD") } ,;
		{ "cIdField" , "MODGRUMOD" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSX3Cache("VV2_GRUMOD","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0010 } ,; // "Descrição"
		{ "cTooltip" , STR0010 } ,; // "Descrição"
		{ "cIdField" , "MODDESGRU" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 40 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})
Return oRetorno

Static Function VA0300043A_ModeloSelecionado()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','SELSELMOD', , .t.)

	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle("VV2_CODMAR") } ,;
		{ "cTooltip" , RetTitle("VV2_CODMAR") } ,;
		{ "cIdField" , "SELCODMAR" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 3 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle("VV2_GRUMOD") } ,;
		{ "cTooltip" , RetTitle("VV2_GRUMOD") } ,;
		{ "cIdField" , "SELGRUMOD" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSX3Cache("VV2_GRUMOD","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle("VV2_MODVEI") } ,;
		{ "cTooltip" , RetTitle("VV2_MODVEI") } ,;
		{ "cIdField" , "SELMODVEI" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSX3Cache("VV2_MODVEI","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	If VV2->(ColumnPos('VV2_CORINT')) > 0
		oRetorno:AddField( { ;
			{ "cTitulo"  , RetTitle('VV2_CORINT') } ,	{ "cTooltip" , STR0011 } ,; // "Cor Interna do Veiculo"
			{ "cIdField" , "SELCORINT" } ,;
			{ "cTipo"    , "C" } , { "nTamanho" , 2 } ,;
			{ "lCanChange" , .f. } , { "lVirtual" , .t. } ;
		})
		oRetorno:AddField( { ;
			{ "cTitulo"  , RetTitle('VV2_COREXT') } ,	{ "cTooltip" , STR0012 } ,; // "Cor Externa do Veiculo"
			{ "cIdField" , "SELCOREXT" } ,;
			{ "cTipo"    , "C" } , { "nTamanho" , 2 } ,;
			{ "lCanChange" , .f. } , { "lVirtual" , .t. } ;
		})
		oRetorno:AddField( { ;
			{ "cTitulo"  , RetTitle('VV2_OPCION') } ,	{ "cTooltip" , STR0013 } ,; // "Opcionais do Veiculo"
			{ "cIdField" , "SELOPCION" } ,;
			{ "cTipo"    , "C" } , { "nTamanho" , 4 } ,;
			{ "lCanChange" , .f. } , { "lVirtual" , .t. } ;
		})
	EndIF

	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle("VV2_SEGMOD") } ,;
		{ "cTooltip" , RetTitle("VV2_SEGMOD") } ,;
		{ "cIdField" , "SELSEGMOD" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSX3Cache("VV2_SEGMOD","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0010 } ,; // "Descrição"
		{ "cTooltip" , STR0010 } ,; // "Descrição"
		{ "cIdField" , "SELDESMOD" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 40 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0009 } ,; // "Comercializa"
		{ "cTooltip" , STR0009 } ,; // "Comercializa"
		{ "cIdField" , "SELCOMERC" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 1 } ,;
		{ "aComboValues" , {"0=" + STR0014 ,"1=" + STR0009 } } ,; // "Não comercializa" - "Comercializa"
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , "VV2REC" } ,;
		{ "cTooltip" , "VV2REC" } ,;
		{ "cIdField" , "VV2REC" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 10 } ,;
		{ "lVirtual" , .t. } ;
	})

Return oRetorno

Static Function VA0300053A_GrupoModelosBtnSelTodos(oPanel)

	TCheckBox():New(;
		3 ,; // nRow
		3 ,; // nCol
		STR0015,; // cCaption - 'Marcar/Desmarcar Todos'
		bSETGET( lCheckGrupo ),; // bSetGet
		oPanel,; // oDlg
		100,; // nWidth
		200,; // nHeight
		,; // uParam8
		{ || VA0300063A_GrupoMarcarDesmarcar() },; // bLClicked
		,; // oFont
		,; // bValid
		,; // nClrText
		,; // nClrPane
		,; // uParam14
		.t.,; // lPixel
		,; // cMsg
		,; // uParam17
		)  // bWhen

Return

Static Function VA0300063A_GrupoMarcarDesmarcar()
	VA0300083A_ProcMarcarDesmarcar('GRPMOD', 'MODSELMOD', lCheckGrupo)
	VA0300093A_LoadModelos()
Return

Static Function VA0300083A_ProcMarcarDesmarcar(cNomeModel, cNomeCampo, lCheck)
	Local oModel     := FWModelActive()
	Local oAuxModel := oModel:GetModel( cNomeModel)
	Local nQtdLinha  := oAuxModel:Length()
	Local aSaveLine  := FwSaveRows()
	Local oView      := FWViewActive()
	Local nLinha

	For nLinha := 1 to nQtdLinha
		oAuxModel:GoLine(nLinha)
		oAuxModel:LoadValue(cNomeCampo , lCheck)
	Next nLinha

	FWRestRows( aSaveLine )
	oView:Refresh()
Return

Static Function VA0300073A_ModelosSelBtnSelTodos(oPanel)

	TCheckBox():New(;
		3 ,; // nRow
		3 ,; // nCol
		STR0015,; // cCaption - 'Marcar/Desmarcar Todos'
		bSETGET( lCheckModelo ),; // bSetGet
		oPanel,; // oDlg
		100,; // nWidth
		200,; // nHeight
		,; // uParam8
		{ || VA0300083A_ProcMarcarDesmarcar('GRPMOD_SELECIONADOS','SELCODMAR',lCheckModelo) },; // bLClicked
		,; // oFont
		,; // bValid
		,; // nClrText
		,; // nClrPane
		,; // uParam14
		.t.,; // lPixel
		,; // cMsg
		,; // uParam17
		)  // bWhen

Return

Function VA0300093A_LoadModelos()

	Local oModel := FWModelActive()
	Local oView := FWViewActive()

	Local oMGrid_GrupoMod := oModel:GetModel('GRPMOD')
	Local oMGrid_Selecionados := oModel:GetModel('GRPMOD_SELECIONADOS')
	Local lCposCorOpc := oMGrid_Selecionados:HasField("SELCORINT")

	Local nLinha
	Local nQtdLinha := oMGrid_GrupoMod:Length()

	Local cSQL

	Local aGrpSel := {}
	Local cAls := "TMODVEI"

	oMGrid_Selecionados:SetNoInsertLine(.F.)

	If oMGrid_GrupoMod:SeekLine({{"MODSELMOD",.t.}},.f.,.f.) == .f.
		If oMGrid_Selecionados:CanClearData()
			oMGrid_Selecionados:ClearData(.T., .T. )
		EndIf
		oMGrid_Selecionados:SetNoInsertLine(.T.)
		oMGrid_Selecionados:SetLine(1)
		oView:Refresh()
		Return
	EndIF

	CursorWait() 

	// Se todos os grupos estiverem selecionados, nao filtra nada ...
	If lCheckGrupo
		cSQL := ;
			"SELECT VV2_CODMAR, VV2_GRUMOD, VV2_MODVEI, VV2_SEGMOD, VV2_DESMOD, VV2_COMERC, VV2.R_E_C_N_O_ VV2RECNO " +;
			IIf( lCposCorOpc , ", VV2_CORINT, VV2_COREXT, VV2_OPCION" , "" ) +;
			" FROM " + RetSQLName("VV2") + " VV2 " +;
			" WHERE VV2.VV2_FILIAL = '" + xFilial("VV2") + "' " + ;
			" AND VV2.D_E_L_E_T_ = ' '" +;
			" ORDER BY VV2_CODMAR, VV2_GRUMOD, VV2_MODVEI, VV2_SEGMOD"
	Else

		// Monta claususa WHERE para filtrar modelos
		For nLinha := 1 to nQtdLinha
			If oMGrid_GrupoMod:GetValue('MODSELMOD',nLinha)
				If (nLinhaGrpSel := aScan(aGrpSel, { |x| x[1] == oMGrid_GrupoMod:GetValue('MODCODMAR',nLinha) })) == 0
					AADD( aGrpSel, { ;
						oMGrid_GrupoMod:GetValue('MODCODMAR',nLinha) ,;
						"'" + oMGrid_GrupoMod:GetValue('MODGRUMOD',nLinha) + "'," ;
					})
				Else
					aGrpSel[nLinhaGrpSel,2] += "'" + oMGrid_GrupoMod:GetValue('MODGRUMOD',nLinha) + "',"
				EndIf
			EndIf
		Next nLinha
		//

		cSQL := ;
			"SELECT VV2_CODMAR, VV2_GRUMOD, VV2_MODVEI, VV2_SEGMOD, VV2_DESMOD, VV2_COMERC, VV2.R_E_C_N_O_ VV2RECNO " +;
			IIf( lCposCorOpc , ", VV2_CORINT, VV2_COREXT, VV2_OPCION" , "" ) +;
			" FROM " + RetSQLName("VV2") + " VV2 " +;
			" WHERE VV2.VV2_FILIAL = '" + xFilial("VV2") + "' " +;
			" AND ( "

		nQtdLinha := Len(aGrpSel)
		For nLinha := 1 to nQtdLinha
			cSQL += ;
				    " ( VV2.VV2_CODMAR = '" + aGrpSel[nLinha,1] + "'" +;
				  " AND VV2.VV2_GRUMOD IN (" + Left( aGrpSel[nLinha,2] , Len(aGrpSel[nLinha,2]) - 1) + ") ) "

			If nLinha <> nQtdLinha
				cSQL += " OR"
			EndIf
		Next nLinha

		cSQL += " ) AND VV2.D_E_L_E_T_ = ' '" +;
			" ORDER BY VV2_CODMAR, VV2_GRUMOD, VV2_MODVEI, VV2_SEGMOD"
	EndIf

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	If oMGrid_Selecionados:CanClearData()
		oMGrid_Selecionados:ClearData(.T., (cAls)->(Eof()) )
	EndIf

	While !(cAls)->(Eof())
		oMGrid_Selecionados:AddLine()
		oMGrid_Selecionados:LoadValue("SELSELMOD", .f. , .t. )
		oMGrid_Selecionados:LoadValue("SELCODMAR", (cAls)->VV2_CODMAR, .t. )
		oMGrid_Selecionados:LoadValue("SELGRUMOD", (cAls)->VV2_GRUMOD, .t. )
		oMGrid_Selecionados:LoadValue("SELMODVEI", (cAls)->VV2_MODVEI, .t. )
		If lCposCorOpc
			oMGrid_Selecionados:LoadValue("SELCORINT", (cAls)->VV2_CORINT, .t. )
			oMGrid_Selecionados:LoadValue("SELCOREXT", (cAls)->VV2_COREXT, .t. )
			oMGrid_Selecionados:LoadValue("SELOPCION", (cAls)->VV2_OPCION, .t. )
		EndIF
		oMGrid_Selecionados:LoadValue("SELSEGMOD", (cAls)->VV2_SEGMOD, .t. )
		oMGrid_Selecionados:LoadValue("SELDESMOD", (cAls)->VV2_DESMOD, .t. )
		oMGrid_Selecionados:LoadValue("SELCOMERC", (cAls)->VV2_COMERC, .t. )
		oMGrid_Selecionados:LoadValue("VV2REC", (cAls)->VV2RECNO, .t. )

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())
	dbSelectArea("VV2")

	oMGrid_Selecionados:SetNoInsertLine(.T.)
	oMGrid_Selecionados:SetLine(1)

	oView:Refresh()

	CursorArrow()
Return .t.


Static Function VA0300103A_GravaComercializa()
	Local oModel := FWModelActive()
	Local oView := FWViewActive()

	Local oMPrincipal := oModel:GetModel('PARMASTER')
	Local oMGrid_Selecionados := oModel:GetModel('GRPMOD_SELECIONADOS')

	Local nLinha
	Local nQtdLinha := oMGrid_Selecionados:Length()

	Local cComerc := oMPrincipal:GetValue("PARCOMERC")

	If oMGrid_Selecionados:SeekLine({{"SELSELMOD",.t.}},.f.,.f.) == .f.
		Return .T.
	EndIF

	CursorWait()
	Begin Transaction

		dbSelectArea("VV2")
		For nLinha := 1 to nQtdLinha
			oMGrid_Selecionados:GoLine(nLinha)
			If oMGrid_Selecionados:GetValue('SELSELMOD')
				VV2->(dbGoTo(oMGrid_Selecionados:GetValue('VV2REC')))

				Reclock("VV2",.f.)
				VV2->VV2_COMERC := cComerc
				VV2->(MSUnlock())

			EndIf
		Next nLinha

	End Transaction
	CursorArrow()

Return .t.