#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

#INCLUDE "VEIC010.CH"

Static nAVEIMAX := GetNewPar("MV_AVEIMAX",1)	// Quantidade Maxima de veiculos no atendimento 

Static oVC010Principal
Static oMModelo
Static oMModeloBtn
Static oMModeloSel

/*/{Protheus.doc} VEIC010
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
Function VEIC010()

	Local aRetFiltro := { VX002ADDRETFILTRO() }

	Private cFilCodMar := "" // Utilizado na consulta padrao de modelos 

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0001) // "Consulta por Modelo"
	oExecView:setSource("VEIC010")
	oExecView:setOK( { || VC0100053_ButtonOK(@aRetFiltro) })
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

Return aClone(aRetFiltro)


Static Function ModelDef()

	Local oModel 

	Local oPrinStru
	Local oModeloStru
	Local oModeloBtnStru
	Local oModeloSelStru

	Local bPost :=  { |oModel| VC0100123_ConfirmaSelecao(oModel) }

	If oVC010Principal == NIL
		oVC010Principal := VC0100013_Master()
		oMModelo := VC0100033_Modelo()
		oMModeloBtn := VC0100083_ModeloBotao()
		oMModeloSel := VC0100093_ModeloSelecionados()
	EndIf

	oPrinStru  := oVC010Principal:GetModel()
	oModeloStru := oMModelo:GetModel()
	oModeloBtnStru := oMModeloBtn:GetModel()
	oModeloSelStru := oMModeloSel:GetModel()

	aAuxTrigger := FwStruTrigger("PARCODMAR","PARCODMAR","cFilCodMar := FWFldGet('PARCODMAR')",.F.,"")
	oPrinStru:AddTrigger(aAuxTrigger[1],aAuxTrigger[2],aAuxTrigger[3],aAuxTrigger[4])

	oModel := MPFormModel():New( 'VEIC010', /* bPre */, bPost , { || .t. } /* bCommit */ , { || .T. }/* bCancel */ )
	oModel:AddFields('PARMASTER', /* cOwner */ , oPrinStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ { || } )
	oModel:AddFields('MODELOSBOTAO', 'PARMASTER' , oModeloBtnStru , /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ { || } )

	oModel:AddGrid('MODELOS','PARMASTER',oModeloStru, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
	oModel:AddGrid('MODELOS_SELECIONADOS','PARMASTER',oModeloSelStru, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )

	oModel:SetDescription( STR0002 ) // 'Consulta de Veiculos Por Modelo'
	oModel:GetModel('PARMASTER'):SetDescription( STR0003 )	// 'Parametros da Consulta' 
	oModel:GetModel('MODELOSBOTAO'):SetDescription( STR0004 )	// 'Botão da Grid de Modelos' 
	oModel:GetModel('MODELOS'  ):SetDescription( STR0005 )	// 'Lista de Modelos' 
	oModel:GetModel('MODELOS_SELECIONADOS'  ):SetDescription( STR0006 )	// 'Lista de Modelos Selecionados' 

	oModel:GetModel('PARMASTER'):SetOnlyQuery( .T. )
	oModel:GetModel('MODELOS'  ):SetOnlyQuery( .T. )
	oModel:GetModel('MODELOS_SELECIONADOS'  ):SetOnlyQuery( .T. )
	oModel:GetModel('MODELOS'  ):SetOptional( .T. )
	oModel:GetModel('MODELOS_SELECIONADOS'  ):SetOptional( .T. )

	oModel:SetPrimaryKey({})
	oModel:SetActivate( { |oModel| VC0100063_ActivateModel(oModel) , .T.} )
	
Return oModel

Function VC0100063_ActivateModel()
Return

Static Function ViewDef()
	Local oModel	:= FWLoadModel( 'VEIC010' )
	Local oView 	:= Nil

	Local oPrinStru  := oVC010Principal:GetView()
	Local oModeloStru := oMModelo:GetView()
	Local oModeloBtnStru := oMModeloBtn:GetView()
	Local oModeloSelStru := oMModeloSel:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_PARAM', oPrinStru , 'PARMASTER')
	oView:AddField('GRID_MODELO_BOTAO', oModeloBtnStru , 'MODELOSBOTAO')
	oView:AddGrid('GRID_MODELO', oModeloStru , 'MODELOS')
	oView:AddGrid('GRID_MODELO_SELECIONADO', oModeloSelStru , 'MODELOS_SELECIONADOS')

	oView:EnableTitleView('FORM_PARAM', 'Parametros')

	oView:SetNoInsertLine('GRID_MODELO')
	oView:SetNoDeleteLine('GRID_MODELO')
	oView:EnableTitleView('GRID_MODELO'	, STR0007 ) // 'Modelo'

	oView:SetNoInsertLine('GRID_MODELO_SELECIONADO')
	oView:EnableTitleView('GRID_MODELO_SELECIONADO'	, STR0008 ) // 'Modelos Selecionados'

	oView:CreateHorizontalBox('TELA_SELECAO',60)
	oView:CreateHorizontalBox('TELA_LISTA',40)

	oView:createVerticalBox('TELA_PARAM', 300, 'TELA_SELECAO' , .T.)
	oView:createVerticalBox('TELA_MODELO', 100, 'TELA_SELECAO')
	oView:createHorizontalBox('TELA_MODELO_GRID', 100, 'TELA_MODELO')
	oView:createHorizontalBox('TELA_MODELO_BOTAO', 65, 'TELA_MODELO' , .T.)

	oView:SetOwnerView('FORM_PARAM','TELA_PARAM')
	oView:SetOwnerView('GRID_MODELO'      ,'TELA_MODELO_GRID')
	oView:SetOwnerView('GRID_MODELO_BOTAO','TELA_MODELO_BOTAO')
	oView:SetOwnerView('GRID_MODELO_SELECIONADO','TELA_LISTA')

	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o 
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 

	//Executa a ação no acionamento do botão confirmar da View
//	oView:SetViewAction("BUTTONOK", {|oView| VC0100053_ButtonOK(oView,"SetViewAction") })

	//Desabilita order no grid
//	oView:SetViewProperty( "*", "GRIDNOORDER")

	oView:SetViewProperty('FORM_PARAM','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP , 2})
	
	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView

Static Function VC0100053_ButtonOK(aRetFiltro)

	Local oModel     := FWModelActive()
	Local oMGrid_Selecionados  := oModel:GetModel("MODELOS_SELECIONADOS")
	Local nQtdLines  := oMGrid_Selecionados:Length()
	Local nX
	//Local lCposCorOpc := oMGrid_Selecionados:HasField("SELCORINT")
	Local nVlTabela
	Local aAuxRet := {}
	
	LOcal nQtdeMod
	Local nLenRet


	For nX := 1 to nQtdLines

		If oMGrid_Selecionados:IsDeleted(nX) .or. oMGrid_Selecionados:GetValue("SELQTDE",nX) == 0
			Loop
		EndIf
		oMGrid_Selecionados:GoLine(nX)
		
		VV2->(DbSetOrder(1))
		VV2->(MsSeek(xFilial("VV2") + oMGrid_Selecionados:GetValue("SELCODMAR") + oMGrid_Selecionados:GetValue("SELMODVEI") + oMGrid_Selecionados:GetValue("SELSEGMOD")))
		
		nVlTabela := FGX_VLRSUGV(;
			"",;  // _cChaInt
			oMGrid_Selecionados:GetValue("SELCODMAR"),;  // _cCodMar
			oMGrid_Selecionados:GetValue("SELMODVEI"),;  // _cModVei
			oMGrid_Selecionados:GetValue("SELSEGMOD"),;  // _cSegMod
			" ",;  // _cCorVei
			.t.,;  // _lMinCom
			"",;  // _cCodCli
			"" ,;  // _cLojCli
			oMGrid_Selecionados:GetValue("SELFABMOD") )  // _cFabMod

		nQtdeMod := oMGrid_Selecionados:GetValue("SELQTDE")
		For nQtdLines := 1 to nQtdeMod
			aAdd(aAuxRet,VX002ADDRETFILTRO() )
			
			nLenRet :=  len(aAuxRet)
			aAuxRet[ nLenRet , 01 ] := "" // CHAINT
			aAuxRet[ nLenRet , 02 ] := "0" // Estado do Veiculo (0=Novo/1=Usado)
			aAuxRet[ nLenRet , 03 ] := VV2->VV2_CODMAR // Marca
			aAuxRet[ nLenRet , 04 ] := VV2->VV2_GRUMOD  // Grupo do Modelo
			aAuxRet[ nLenRet , 05 ] := VV2->VV2_MODVEI // Modelo
			aAuxRet[ nLenRet , 06 ] := " " // aVetMod[ni,6] // Cor
			aAuxRet[ nLenRet , 07 ] := "" // Codigo Progresso
			aAuxRet[ nLenRet , 08 ] := "3" // 3=Venda Futura / 4=Simulacao
			aAuxRet[ nLenRet , 09 ] := nVlTabela
			aAuxRet[ nLenRet , 10 ] := VV2->VV2_SEGMOD
			aAuxRet[ nLenRet , 11 ] := oMGrid_Selecionados:GetValue("SELFABMOD")
		Next nQtdLines

	Next nX
	If Len(aAuxRet) > 0
		aRetFiltro := aClone(aAuxRet)
	Else
		aRetFiltro := { VX002ADDRETFILTRO() }
	EndIf

Return .t.

Static Function VC0100013_Master()
	Local oRetorno := OFDMSStruct():New()
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0008 } ,; // "Marca"
		{ "cTooltip" , STR0009 } ,; // "Código da Marca"
		{ "cIdField" , "PARCODMAR" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSx3Cache( "VE1_CODMAR" , "X3_TAMANHO" ) } ,;
		{ "cLookUp" , "VE1" } ,;
		{ "bValid" , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCPO('VE1', FWFldGet('PARCODMAR'),,,.f.)") } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0007 } ,; // "Modelo"
		{ "cTooltip" , STR0011 } ,; // "Código do Modelo"
		{ "cIdField" , "PARMODVEI" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 30 } ,;
		{ "cLookUp" , "VV2SQL" } ,;
		{ "bValid" , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCPO('VV2', FWFldGet('PARCODMAR') + FWFldGet('PARMODVEI'),,,.f.)") } ,;
		{ "bInit" , { || Space(30) } } ,;
		{ "lVirtual" , .t. } ;
	})
	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle("VV2_OPCION") } ,;
		{ "cTooltip" , STR0012 } ,; // "Código do Opcional"	
		{ "cIdField" , "VV2_OPCION" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSx3Cache("VV2_OPCION","X3_TAMANHO") } ,;
		{ "bValid" , { || .T. } } ,;
		{ "cLookUp" , "VX5" } ,;
		{ "bInit" , { || Space(TamSX3("VV2_OPCION")[1]) } } ,;
		{ "lVirtual" , .t. } ;
	})
	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle("VV2_CORINT") } ,;
		{ "cTooltip" , STR0013 } ,; // "Código da Cor Interna"
		{ "cIdField" , "VV2_CORINT" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSx3Cache("VV2_CORINT","X3_TAMANHO") } ,;
		{ "cLookUp" , "VX5" } ,;
		{ "bValid" , { || .T. } } ,;
		{ "bInit" , { || Space(TamSX3("VV2_CORINT")[1]) } } ,;
		{ "lVirtual" , .t. } ;
	})
	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle("VV2_COREXT") } ,;
		{ "cTooltip" , STR0014 } ,; // "Código da Cor Externa"
		{ "cIdField" , "VV2_COREXT" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSx3Cache("VV2_COREXT","X3_TAMANHO") } ,;
		{ "cLookUp" , "VX5" } ,;
		{ "bValid" , { || .T. } } ,;
		{ "bInit" , { || Space(TamSX3("VV2_COREXT")[1]) } } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddButton( STR0015 ,'BTNPESQUISA',{ |oMdl| VC0100073_AtualizaGridModelos(oMdl) }) // Pesquisar
Return oRetorno

Static Function VC0100073_AtualizaGridModelos()
	Local oModel		:= FWModelActive()
	Local oMGrid_Modelos		:= oModel:GetModel("MODELOS")
	Local oMParametros	:= oModel:GetModel("PARMASTER")
	//Local oView			:= FWViewActive()
	Local cAls := "TMODVEI"
	Local cSQL
	Local lCposCorOpc := VV2->(ColumnPos('VV2_CORINT')) > 0

	Local cParMarca   := oMParametros:GetValue("PARCODMAR")
	Local cParModelo  := oMParametros:GetValue("PARMODVEI")
	Local cParCorInt  := ""
	Local cParCorExt  := ""
	Local cParOpcional := ""

	If lCposCorOpc
		cParCorInt  := oMParametros:GetValue("VV2_CORINT")
		cParCorExt  := oMParametros:GetValue("VV2_COREXT")
		cParOpcional := oMParametros:GetValue("VV2_OPCION")
	EndIf
	
	oMGrid_Modelos:SetNoInsertLine(.F.)

	cSQL := ;
		"SELECT VV2_CODMAR, VV2_MODVEI, VV2_SEGMOD, VV2_DESMOD " +;
		IIf( lCposCorOpc , ", VV2_CORINT, VV2_COREXT, VV2_OPCION" , "" ) +;
		 " FROM " + RetSQLName("VV2") + " VV2 " +;
		" WHERE VV2.VV2_FILIAL = '" + xFilial("VV2") + "' " + ;
		  IIf( Empty(cParMarca) , "" , " AND VV2.VV2_CODMAR = '" + cParMarca + "' " ) +;
		  IIf( Empty(cParModelo) , "" , " AND VV2.VV2_MODVEI = '" + cParModelo + "' " ) +;
		  IIf( Empty(cParCorInt) , "" , " AND VV2.VV2_CORINT = '" + cParCorInt + "' " ) +;
		  IIf( Empty(cParCorExt) , "" , " AND VV2.VV2_COREXT = '" + cParCorExt + "' " ) +;
		  IIf( Empty(cParOpcional) , "" , " AND VV2.VV2_OPCION = '" + cParOpcional + "' " ) +;
		  " AND VV2.D_E_L_E_T_ = ' '" +;
		" ORDER BY VV2_CODMAR, VV2_MODVEI, VV2_SEGMOD"
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	//Na nova carga do Grid, as linhas existentes são apagadas.
	If oMGrid_Modelos:CanClearData() 
		oMGrid_Modelos:ClearData(.T., (cAls)->(Eof()) )
	EndIf

	While (cAls)->(!Eof())
		oMGrid_Modelos:AddLine()
		oMGrid_Modelos:LoadValue("MODSELMOD" , .f.  , .t. )
		oMGrid_Modelos:SetValue("MODCODMAR" , (cAls)->VV2_CODMAR , .t. )
		oMGrid_Modelos:LoadValue("MODMODVEI" , (cAls)->VV2_MODVEI , .t. )
		If lCposCorOpc
			oMGrid_Modelos:LoadValue("MODCORINT" , (cAls)->VV2_CORINT , .t. )
			oMGrid_Modelos:LoadValue("MODCOREXT" , (cAls)->VV2_COREXT , .t. )
			oMGrid_Modelos:LoadValue("MODOPCION" , (cAls)->VV2_OPCION , .t. )
		EndIf
		oMGrid_Modelos:LoadValue("MODSEGMOD" , (cAls)->VV2_SEGMOD , .t. )
		oMGrid_Modelos:LoadValue("MODDESMOD" , (cAls)->VV2_DESMOD , .t. )
		oMGrid_Modelos:LoadValue("MODQTDE"   , 0 , .t. )

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())

	oMGrid_Modelos:SetNoInsertLine(.T.)
	oMGrid_Modelos:SetLine(1)

	dbSelectArea("VV1")

Return .t.


Static Function VC0100033_Modelo()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','MODSELMOD', , .f.)

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0008 } ,; // "Marca"
		{ "cTooltip" , STR0009 } ,; // "Código da Marca"
		{ "cIdField" , "MODCODMAR" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 3 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})
	
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0007 } ,; // "Modelo" 
		{ "cTooltip" , STR0011 } ,; // "Código do Modelo" 
		{ "cIdField" , "MODMODVEI" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 30 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})
	
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0016 } ,; // "Segmento" 
		{ "cTooltip" , STR0017 } ,; // "Segmento do Modelo" 
		{ "cIdField" , "MODSEGMOD" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSX3Cache("VV2_SEGMOD","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0018 } ,; // "Descrição" 
		{ "cTooltip" , STR0019 } ,; // "Descrição Segmento do Modelo" 
		{ "cIdField" , "MODDESMOD" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 40 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle('VV2_OPCION') } ,	{ "cTooltip" , STR0012 } ,; // "Código do Opcional"
		{ "cIdField" , "MODOPCION" } ,;
		{ "cTipo"    , "C" } , { "nTamanho" , GetSx3Cache("VV2_OPCION","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } , { "lVirtual" , .t. } ;
	})
	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle('VV2_CORINT') } ,	{ "cTooltip" , STR0013 } ,; // "Código da Cor Interna"
		{ "cIdField" , "MODCORINT" } ,;
		{ "cTipo"    , "C" } , { "nTamanho" , GetSx3Cache("VV2_CORINT","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } , { "lVirtual" , .t. } ;
	})
	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle('VV2_COREXT') } ,	{ "cTooltip" , STR0014 } ,; // "Código da Cor Externa"
		{ "cIdField" , "MODCOREXT" } ,;
		{ "cTipo"    , "C" } , { "nTamanho" , GetSx3Cache("VV2_COREXT","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } , { "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0020 } ,; // "Quantidade"
		{ "cTooltip" , STR0020 } ,; // "Quantidade"
		{ "cIdField" , "MODQTDE" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 3 } ,;
		{ "lCanChange" , .t. } ,;
		{ "cPicture" , "@E 999"} ,;
		{ "bWhen" , FWBuildFeature(STRUCT_FEATURE_WHEN,"!Empty(FwFldGet('MODCODMAR'))") } ,;
		{ "bValid" , FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo() .and. VC0100103_FieldOkQtde()") },;
		{ "lVirtual" , .t. } ;
	})

Return oRetorno

Function VC0100103_FieldOkQtde()

	Local oModel := FWModelActive()
	Local oModelMod := oModel:GetModel("MODELOS")

	oModelMod:LoadValue("MODSELMOD", (oModelMod:GetValue("MODQTDE") > 0))

Return .T.

Static Function VC0100083_ModeloBotao()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddButton(STR0021,'BTNPESQUISA',{ |oMdl| VC0100113_ConfirmarSelecao(oMdl) }) // 'Confirmar'

Return oRetorno 


Static Function VC0100113_ConfirmarSelecao()

	Local oModel		:= FWModelActive()

	Local oMGrid_Modelos := oModel:GetModel("MODELOS")
	Local oMGrid_Selecionados := oModel:GetModel("MODELOS_SELECIONADOS")

	//Local nQtdLines		:= oMGrid_Modelos:Length()
	//Local aSaveLines 		:= FWSaveRows()
	Local nX
	Local lCposCorOpc := oMGrid_Selecionados:HasField("SELCORINT")
	Local oView			:= FWViewActive()
	Local lAddLine		:= .t.

	If oMGrid_Modelos:SeekLine({{"MODSELMOD",.t.}},.f.,.f.) == .f.
		MessageBox(STR0021,"",64) // "Selecionar ao menos um modelo."
		Return .t. 
	EndIf

	oMGrid_Selecionados:SetNoInsertLine(.f.)

	If oMGrid_Selecionados:Length() == 1
		If Empty(oMGrid_Selecionados:GetValue("SELCODMAR",1))
			lAddLine := .f.
		EndIf
	EndIf

	For nX:= 1 to oMGrid_Modelos:Length()
		oMGrid_Modelos:GoLine(nX)
		If oMGrid_Modelos:GetValue("MODSELMOD")
			If lAddLine
				oMGrid_Selecionados:AddLine()
			Else
				oMGrid_Selecionados:GoLine(1)
				lAddLine := .t.
			EndIf
			oMGrid_Selecionados:SetValue("SELCODMAR" , oMGrid_Modelos:GetValue("MODCODMAR") )
			oMGrid_Selecionados:LoadValue("SELMODVEI" , oMGrid_Modelos:GetValue("MODMODVEI") )
			If lCposCorOpc
				oMGrid_Selecionados:LoadValue("SELCOREXT" , oMGrid_Modelos:GetValue("MODCOREXT") )
				oMGrid_Selecionados:LoadValue("SELCORINT" , oMGrid_Modelos:GetValue("MODCORINT") )
				oMGrid_Selecionados:LoadValue("SELOPCION" , oMGrid_Modelos:GetValue("MODOPCION") )
			EndIf
			oMGrid_Selecionados:LoadValue("SELSEGMOD" , oMGrid_Modelos:GetValue("MODSEGMOD") )
			oMGrid_Selecionados:LoadValue("SELDESMOD" , oMGrid_Modelos:GetValue("MODDESMOD") )
			oMGrid_Selecionados:LoadValue("SELQTDE"   , oMGrid_Modelos:GetValue("MODQTDE"  ) )
		EndIF
	Next

	oMGrid_Selecionados:SetNoInsertLine(.t.)

	If oMGrid_Modelos:CanClearData() 
		oMGrid_Modelos:ClearData(.T., .T. )
	EndIf

	If oMGrid_Selecionados:Length() > 1
		oMGrid_Selecionados:GoLine(1)
	EndIf

	oView:Refresh()
	
Return .t.


Static Function VC0100093_ModeloSelecionados()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0008 } ,; // "Marca"
		{ "cTooltip" , STR0009 } ,; // "Código da Marca"
		{ "cIdField" , "SELCODMAR" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 3 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0007 } ,; // "Modelo"
		{ "cTooltip" , STR0011 } ,; // "Código do Modelo"
		{ "cIdField" , "SELMODVEI" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 30 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0016 } ,; // "Segmento"
		{ "cTooltip" , STR0017 } ,; // "Segmento do Modelo"
		{ "cIdField" , "SELSEGMOD" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSX3Cache("VV2_SEGMOD","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0018 } ,; // 'Modelo'
		{ "cTooltip" , STR0010 } ,; // "Descrição do Modelo"
		{ "cIdField" , "SELDESMOD" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 40 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle('VV2_OPCION') } ,	{ "cTooltip" , STR0012 } ,; // "Código do Opcional"
		{ "cIdField" , "SELOPCION" } ,;
		{ "cTipo"    , "C" } , { "nTamanho" , GetSx3Cache("VV2_OPCION","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } , { "lVirtual" , .t. } ;
	})
	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle('VV2_CORINT') } ,	{ "cTooltip" , STR0013 } ,; // "Código da Cor Interna"
		{ "cIdField" , "SELCORINT" } ,;
		{ "cTipo"    , "C" } , { "nTamanho" , GetSx3Cache("VV2_CORINT","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } , { "lVirtual" , .t. } ;
	})
	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle('VV2_COREXT') } ,	{ "cTooltip" , STR0014 } ,; // "Código da Cor Externa"
		{ "cIdField" , "SELCOREXT" } ,;
		{ "cTipo"    , "C" } , { "nTamanho" , GetSx3Cache("VV2_COREXT","X3_TAMANHO") } ,;
		{ "lCanChange" , .f. } , { "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , RetTitle("VRK_FABMOD") } ,;
		{ "cTooltip" , STR0022 } ,; // "Ano de fabricação/modelo."
		{ "cIdField" , "SELFABMOD" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , GetSx3Cache("VRK_FABMOD","X3_TAMANHO") } ,;
		{ "bValid" , FWBuildFeature( STRUCT_FEATURE_VALID , "Vazio() .OR. FG_ANOMOD(,FWFldGet('SELFABMOD'))" ) } ,;
		{ "cValid" , 'Vazio() .OR. FG_ANOMOD(,FWFldGet("SELFABMOD")' } ,;
		{ "cPicture" , '@R 9999/9999' } ,;
		{ "lCanChange" , .t. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0020 } ,; // "Quantidade"
		{ "cTooltip" , STR0020 } ,; // "Quantidade"
		{ "cIdField" , "SELQTDE" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 3 } ,;
		{ "lCanChange" , .t. } ,;
		{ "bWhen" , FWBuildFeature(STRUCT_FEATURE_WHEN,"!Empty(FwFldGet('SELCODMAR'))") } ,;
		{ "cPicture" , "@E 999"} ,;
		{ "bValid" , FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo()") },;
		{ "lVirtual" , .t. } ;
	})

Return oRetorno


Static Function VC0100123_ConfirmaSelecao()

	Local oModel     := FWModelActive()
	Local oMGrid_Selecionados  := oModel:GetModel("MODELOS_SELECIONADOS")
	Local nQtdLines  := oMGrid_Selecionados:Length()
	Local nX

	If IsInCallStack("VEIA060")
		Return .t.
	EndIf

	nContVVA := 0
	If !Empty(M->VV0_NUMTRA)
		nContVVA := FM_SQL(;
							"SELECT COUNT(*) " + ;
							 " FROM "+RetSQLName('VVA')+" " +;
							" WHERE VVA_FILIAL='"+xFilial('VVA')+"'" +;
							  " AND VVA_NUMTRA='"+M->VV0_NUMTRA+"'" +;
							  " AND D_E_L_E_T_=' '")
	EndIf
	For nX := 1 to nQtdLines

		If oMGrid_Selecionados:IsDeleted(nX)
			Loop
		EndIf
		nContVVA += oMGrid_Selecionados:GetValue("SELQTDE",nX)

	Next nX

	// Verificar as Qtdades: "MAXIMA permitida por Atendimento" com "Veiculos Informados na Venda Futura" + "Veiculos que ja estao no Atendimento"
	If nContVVA > nAVEIMAX  // Qtde MAXIMA permitida
		oModel:SetErrorMessage(;
			"",;// cIdForm
			,;// cIdField 
			oModel:GetId(),;// cIdFormErr 
			"",;// cIdFieldErr 
			"AVEIMAX",;// cId
			STR0023 ,; // cMessage   - "Impossível selecionar o Veiculo. A quantidade máxima permitida por Atendimento foi atingida."
			STR0024 )  // cSoluction - "Modifique a quantidade selecionada ou remova veículos do atendimento."
		Return .f.
	EndIf

Return .t.
