//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"
#Include "TOTVS.CH"
#Include "VEIA162.CH"

Static __aWidgets		:= {}		//Array de objetos com os Widgets ativos.
Static __lIsBrwInChg	:= .F.
Static __nOptBrwRot		:= 1

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VEIA162()

	Local lCriaMenu			:= .T.
	Local aButtons			:= {}
	Local cMenuItem  		:= Nil
	Local oMenu      		:= Nil
	Local aSize      		:= FWGetDialogSize( oMainWnd )
	Local ni				:= 0
	Local aMenu				:= {}
	Local nPropPed			:= 0
	Local nPropBon			:= 0

	Local cCompVQ0 := FwModeAccess("VQ0",1) + FwModeAccess("VQ0",2) + FwModeAccess("VQ0",3)
	Local cCompVJR := FwModeAccess("VJR",1) + FwModeAccess("VJR",2) + FwModeAccess("VJR",3)

	Local lVQ0_STATUS := ( VQ0->(FieldPos("VQ0_STATUS")) > 0 )

	Local oAuxFil   := DMS_FilialHelper():New()
	Local aFiliais  := oAuxFil:GetAllFilEmpresa(.t.)
	Local aMapFilDealerCode := {}
	Local nPosFil   := 0

	Local lVA162COR := ExistBlock('VA162COR')

	Private aRegSel   := {}
	Private oDlgWA    := Nil
	
	// 1 - Azul // 2 - Amarelo // 3 - Vermelho
	Private aCores    := {{"#1E90FF",RGB(30,144,255)},{"#FFD700",RGB(255,215,0)},{"#FF6347",RGB(255,99,71)}}

	If cCompVQ0 <> cCompVJR
		MsgInfo( STR0001, STR0002 ) // "Compartilhamento entre as tabelas VQ0 e VJR estão divergentes. Os arquivos não serão importados!" / "Atenção"
	EndIf

	VA1620295_AtualizaDadosPedido()

	nPropPed := aSize[3] * 0.6 // 60% da tela é para o Browse de Pedido
	nPropBon := aSize[3] - nPropPed

	oDlgWA := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0003, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )    // "Área de Trabalho"

		oWorkArea := FWUIWorkArea():New( oDlgWA )
		oWorkArea:CreateHorizontalBox( "LINE01", nPropPed, .t. )
		oWorkArea:SetBoxCols( "LINE01", { "WDGT01" } )
		oWorkArea:CreateHorizontalBox( "LINE02", nPropBon, .t. )
		oWorkArea:SetBoxCols( "LINE02", { "WDGT02" } )
		oWorkArea:Activate()

		oBrwVQ0 := FwMBrowse():New()
		oBrwVQ0:SetOwner(oWorkArea:GetPanel( "WDGT01" ))
		oBrwVQ0:SetDescription( STR0004 )
		oBrwVQ0:SetAlias('VQ0')
		oBrwVQ0:SetMenuDef( 'VEIA142' )
		oBrwVQ0:lOptionReport := .f.

		oBrwVQ0:AddLegend( 'VQ0->VQ0_STATUS == "1"' , 'BR_VERDE'	, STR0027 ) // "Confirmado"
		oBrwVQ0:AddLegend( 'VQ0->VQ0_STATUS == "2"' , 'BR_AZUL'		, STR0028 ) // "Faturado"
		oBrwVQ0:AddLegend( 'VQ0->VQ0_STATUS == "3"' , 'BR_VERMELHO' , STR0029 ) // "Cancelado"
		oBrwVQ0:AddLegend( 'VQ0->VQ0_STATUS == " "' , 'BR_BRANCO' 	, STR0030 ) // "Status não definido"

		If lVA162COR
			oBrwVQ0:AddStatusColumns({|| VA1620355_ColunaStatus() }, {|| VA1620365_LegendaStatus() })
		EndIf

		For nPosFil := 1 to Len(aFiliais)
			oBrwVQ0:AddFilter( STR0005 + aFiliais[nPosFil], "@ VQ0_FILENT = '" + aFiliais[nPosFil] + "'")
		Next nPosFil

		oBrwVQ0:DisableDetails()
		oBrwVQ0:SetBlkBackColor( { || VA1620255_AlteraCorLinha()} )
		oBrwVQ0:Activate()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define os itens do Menu PopUp                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MENU oMenu POPUP 
			MENUITEM STR0006 Action VA1620325_RightClick() //"Sinaliza como visto"
			MENUITEM STR0007 Action VA1620345_VisualizaAlteracoes() //"Visualiza Hist. Alteração"
		ENDMENU

		oRightClick := oBrwVQ0:Browse()
		oRightClick:bRClicked:= { |o,nX,nY| oMenu:Activate( nX, nY ) }
		oRightClick:Refresh()

		oBrwVQ1 := FwMBrowse():New()
		oBrwVQ1:SetOwner(oWorkArea:GetPanel( "WDGT02" ))
		oBrwVQ1:SetDescription( STR0008 )
		oBrwVQ1:SetMenuDef( 'VEIA163' )
		oBrwVQ1:SetAlias('VQ1')

		oBrwVQ1:AddMarkColumns( { |x,y| VA1620015_ColBMark(x,y) },{ || VA1620025_MarkRegistro( oBrwVQ1, "VQ1" ) }, {|| VA1620035_MarkAllRegistro( oBrwVQ1 , "VQ1" ), oBrwVQ1:Refresh() } )
		oBrwVQ1:AddStatusColumns({|| VA1620045_ColunaStatus() }, {|| VA1620055_LegendaStatus() })
		oBrwVQ1:AddStatusColumns({|| VA1620285_StatusColAtendimento() }, {|| VA1620055_LegendaStatus() })

		oBrwVQ1:DisableDetails()
		oBrwVQ1:SetUseFilter()
		oBrwVQ1:lOptionReport := .f.
		oBrwVQ1:Activate()

		oRelacPed:= FWBrwRelation():New()
		oRelacPed:AddRelation( oBrwVQ0 , oBrwVQ1 , {{ "VQ1_FILIAL", "xFilial('VQ1')" }, { "VQ1_CODIGO", "VQ0_CODIGO" } })
		oRelacPed:Activate()

		SetKey(VK_F12, {|| VA1620145_ConfiguraAlerta() })

	oDlgWA:Activate( , , , , , , ) //ativa a janela criando uma enchoicebar

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620015_ColBMark(x,y)
	Local lRet := 'LBNO'

	If aScan(aRegSel,{|x| x == VQ1->(RecNo()) }) > 0
		lRet := 'LBOK'
	EndIf

Return lRet

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620025_MarkRegistro( oMarkBrow , cAliasTmp )

	Local lRet := .T.

	If aScan(aRegSel,{|x| x == VQ1->(RecNo()) }) == 0
		aAdd(aRegSel, VQ1->(RecNo()) )
	Else
		aDel(aRegSel,aScan(aRegSel,{|x| x == VQ1->(RecNo()) }))
		aSize(aRegSel, Len(aRegSel) - 1)
	EndIf

Return( Nil )

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620035_MarkAllRegistro( oMarkBrow , cAliasTmp )

	Local aArea 	 := GetArea()
	Local aAreaAlias := VQ0->( GetArea() )
	Local lMarca	 := .F.

	While VQ1->( !EOF() )

		If aScan(aRegSel,{|x| x == VQ1->(RecNo()) }) == 0
			aAdd(aRegSel, VQ1->(RecNo()) )
		Else
			aDel(aRegSel,aScan(aRegSel,{|x| x == VQ1->(RecNo()) }))
			aSize(aRegSel, Len(aRegSel) - 1)
		EndIf
		VQ1->( DbSkip() )

	EndDo

	RestArea( aAreaAlias ) 
	RestArea( aArea )

Return( Nil )

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620045_ColunaStatus()
	
	// Variável do Retorno
	Local cImgRPO := ""

	//-- Define Status do registro
	If VQ1->VQ1_STATUS == "1"
		cImgRpo := "BR_AMARELO"
	ElseIf VQ1->VQ1_STATUS == "2"
		cImgRpo := "BR_VERDE"
	ElseIf VQ1->VQ1_STATUS == "3"
		cImgRpo := "BR_AZUL"
	ElseIf VQ1->VQ1_STATUS == "4"
		cImgRpo := "BR_VERMELHO"
	ElseIf VQ1->VQ1_STATUS == "5"
		cImgRpo := "PMSEDT4"
	EndIf

Return cImgRPO

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620055_LegendaStatus()

	// Array das Legendas
	Local aLegenda := {	{"BR_AMARELO" 	, STR0009 }, ; //"Gravado"
						{"BR_VERDE"		, STR0010 }, ; //"Liberado para faturar"
						{"BR_AZUL"		, STR0011 }, ; //"NF gerada"
						{"BR_VERMELHO"	, STR0012 }, ; //"Cancelado"
						{"PMSEDT4"		, STR0013 } } //"Bonus selecionado no atendimento"

	//-- Define Status do registro
	BrwLegenda(STR0014, STR0015 ,aLegenda )	//"Bônus de Maquinas" / "Legenda"

Return .T.

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1620145_ConfiguraAlerta()
	
	Local aSize			:= MsAdvSize()
	
	Local aButtons		:= {}
	Local cAliasPesq	:= GetNextAlias()
	Local nLargura		:= 170

	Private aCpoMark	:= {}
	Private aLMostrar
	Private lAvanca		:= .f.
	Private nRadio 		:= 1

	Private aItems := {STR0016 , STR0017 , STR0018 } //'Azul' / 'Amarelo' / 'Vermelho'

	aLMostrar := VA1620215_LevantaCampos()

	oDlg := MSDialog():New( 180, 180, 750, 900, STR0019, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )    // "Configurar"

		oPanelFull := TPanelCss():New(0,0,"",oDlg,,.F.,.F.,,,80,80,.T.,.F.)
		oPanelFull:SetCSS("TPanelCss { background-color : #FFFFFF; border-radius: 4px; border: 4px solid #DCDCDC; } ")
		oPanelFull:Align := CONTROL_ALIGN_ALLCLIENT

		oTPanelTOP := TPanelCss():New(0,0,"",oPanelFull,,.F.,.F.,,,00,30,.T.,.F.)
		oTPanelTOP:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }")
		oTPanelTOP:Align := CONTROL_ALIGN_TOP

		oTPanelMIDLE := TPanelCss():New(0,0,"",oPanelFull,,.F.,.F.,,,00,15,.T.,.F.)
		oTPanelMIDLE:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
		oTPanelMIDLE:Align := CONTROL_ALIGN_TOP

		oTPM_LEFT := TPanelCss():New(0,0,"",oTPanelMIDLE,,.F.,.F.,,,nLargura,00,.T.,.F.)
		oTPM_LEFT:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
		oTPM_LEFT:Align := CONTROL_ALIGN_LEFT

		oTPM_CENTER := TPanelCss():New(0,0,"",oTPanelMIDLE,,.F.,.F.,,,10,00,.T.,.F.)
		oTPM_CENTER:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
		oTPM_CENTER:Align := CONTROL_ALIGN_CENTER

		oTPM_RIGHT := TPanelCss():New(0,0,"",oTPanelMIDLE,,.F.,.F.,,,nLargura,00,.T.,.F.)
		oTPM_RIGHT:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
		oTPM_RIGHT:Align := CONTROL_ALIGN_RIGHT

		oTPanelALL := TPanelCss():New(0,0,"",oPanelFull,NIL,.T.,.F.,NIL,NIL,0,10,.T.,.F.)
		oTPanelALL:SetCSS("TPanelCss { background-color : transparent; border: 0px; }") 
		oTPanelALL:Align := CONTROL_ALIGN_ALLCLIENT

		oTPA_LEFT := TPanelCss():New(0,0,"",oTPanelALL,NIL,.T.,.F.,NIL,NIL,nLargura,00,.T.,.F.)
		oTPA_LEFT:Align := CONTROL_ALIGN_LEFT

		oTPA_CENTER := TPanelCss():New(0,0,"",oTPanelALL,,.F.,.F.,,,10,00,.T.,.F.)
		oTPA_CENTER:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
		oTPA_CENTER:Align := CONTROL_ALIGN_ALLCLIENT

		oTPA_RIGHT := TPanelCss():New(0,0,"",oTPanelALL,NIL,.T.,.F.,NIL,NIL,nLargura,00,.T.,.F.)
		oTPA_RIGHT:Align := CONTROL_ALIGN_RIGHT

		oTextConf := tSimpleEditor():New(0,0, oTPanelTOP,300 ,70,,.T.,,,.T. )
		oTextConf:Setcss("color: #757776; font-size: 20px; background-color : transparent; border: 0px;") 
		oTextConf:Load("<h2 align='center'>" + STR0020 + "</h2>") //Configurar atualizações críticas
		oTextConf:Align := CONTROL_ALIGN_ALLCLIENT

		oTextCpo := tSimpleEditor():New(0,0, oTPM_LEFT,300 ,30,,.T.,,,.T. )
		oTextCpo:Setcss("color: #757776; font-size: 13px; background-color : transparent; border: 0px; ") 
		oTextCpo:Load("<h4 align='center'>" + STR0021 + "</h4>") //Campos normais
		oTextCpo:Align := CONTROL_ALIGN_ALLCLIENT
		
		oScroll := TScrollBox():New(oTPA_LEFT,01,01,180,100)
		oScroll:Align := CONTROL_ALIGN_TOP
		oScroll:SetCSS("QScrollArea { background-color : #FFFFFF; margin-left: 4px;}")

		oTextCpA := tSimpleEditor():New(0,0, oTPM_RIGHT,300 ,30,,.T.,,,.T. )
		oTextCpA:Setcss("color: #757776; font-size: 13px; background-color : transparent; border: 0px; ") 
		oTextCpA:Load("<h4 align='center'>" + STR0022 +"</h4>") //Campos de atualização crítica
		oTextCpA:Align := CONTROL_ALIGN_ALLCLIENT

		oScroll2 := TScrollBox():New(oTPA_RIGHT,01,01,100,100)
		oScroll2:Align := CONTROL_ALIGN_ALLCLIENT

		VA1620175_CheckBoxCampos(oScroll)
		VA1620275_BotaoAvancar(oScroll2)

		oTPM_COR := TPanelCss():New(0,0,"",oTPA_LEFT,,.F.,.F.,,,100,80,.T.,.F.)
		oTPM_COR:SetCSS("TPanelCss { background-color : #FFFFFF; border-radius: 4px; margin-left: 4px; margin-top: 16px; }")
		oTPM_COR:Align := CONTROL_ALIGN_TOP
		
		oTextRad := tSimpleEditor():New(0,0, oTPM_COR,100 ,20,,.T.,,,.T. )
		oTextRad:Setcss("color: #757776; font-size: 13px; background-color : transparent; border: 0px; margin-top: 8px; ")
		oTextRad:Load("<h4 align='center'>" + STR0023 + "</h4>") //Cores
		oTextRad:Align := CONTROL_ALIGN_TOP

		oRadio := TRadMenu():New (01,01,aItems,{|u|Iif (PCount()==0,nRadio,nRadio:=u)},oTPM_COR,,,,,,,,100,12,,,,,.T.)
		oRadio:Align := CONTROL_ALIGN_TOP
		oRadio:SetCSS("QRadioButton{ font-size: 14px; margin-left: 8px;}")

		oBtn1 := TBtnBmp2():New( 02,02,26,26,'triright',,,,{|| VA1620275_BotaoAvancar(oScroll2)   },oTPA_CENTER,,,.T. )
		oBtn1:Align := CONTROL_ALIGN_TOP
		oBtn2 := TBtnBmp2():New( 02,32,26,26,'trileft' ,,,,{|| VA1620225_BotaoRetroceder(oScroll2)},oTPA_CENTER,,,.T. )
		oBtn2:Align := CONTROL_ALIGN_TOP

	oDlg:Activate( , , , .t. , , ,EnchoiceBar( oDlg, {|| VA1620195_ConfirmaConfiguracao(), oDlg:End() }, { || oDlg:End() }, ,aButtons, , , , , .F., .T. ) ) //ativa a janela criando uma enchoicebar

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1620175_CheckBoxCampos(oPanel)

	Local nPosicao := 005
	Local nCpo
	Local cNomeVar := ""

	Default oPanel := Nil

	For nCpo := 1 to Len(aLMostrar)
		cNomeVar := "oChkPed" + cValToChar(nCpo)
		_SetNamedPrvt( AllTrim(cNomeVar) , cNomeVar , "VA1620145_ConfiguraAlerta" )
		&( cNomeVar ) := TCheckBox():New( nPosicao, 2, aLMostrar[nCpo,2] , &('{ | U | IF( PCOUNT() == 0, aLMostrar[' + Str(nCpo) + ',1] , aLMostrar[' + Str(nCpo) + ',1] := U ) }') , oPanel, 100,10,, &("{|| VA1620205_ClickAvanca(aLMostrar[ " + Str(nCpo) + " ]), }"),,/*[ bValid]*/,,,,.T., STR0024 ,,/*[ bWhen]*/ ) //"Marque para visualizar as máquinas que não ainda chegaram ao ponto de controle"
		aLMostrar[nCpo,4] := cNomeVar
		nPosicao := nPosicao+15

		If aLMostrar[ nCpo, 1]
			VA1620205_ClickAvanca( aLMostrar[ nCpo ] )
			&( cNomeVar ):bWhen := {|| .f. }
		EndIf

	Next

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1620205_ClickAvanca(aVetor)

Local nPosCpo := 0

Default aVetor := {}

If aVetor[1]
	aAdd(aCpoMark,{.t.,;		//Marcação
					aVetor[2],; //Titulo do Campo
					aVetor[3],; //Nome do Campo
					aVetor[5],; //Nome do Objeto origem
					,;			//Nome do Objeto destino
					aVetor[6]})// Cor selecionada
Else
	nPosCpo := aScan(aCpoMark,{|x| x[2] == aVetor[2]})
	If nPosCpo > 0
		aDel(aCpoMark,nPosCpo)
		aSize(aCpoMark,Len(aCpoMark)-1)
	EndIf
EndIf

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1620185_CheckBoxCamposAlerta(oPnlCpo)

	Local nPosicao := 005
	Local nCpo
	Local cNomeVar := ""
	Local cCodCor

	Default oPnlCpo := Nil

	For nCpo := 1 to Len(aCpoMark)
		cNomeVar := "oChkCpo" + cValToChar(nCpo)

		nAchou := aScan(aCpoMark,{|x| x[5] == cNomeVar})
		If nAchou == 0
			_SetNamedPrvt( AllTrim(cNomeVar) , cNomeVar , "VA1620145_ConfiguraAlerta" )
			&( cNomeVar ) := TCheckBox():New( nPosicao, 2, aCpoMark[nCpo,2] , &('{ | U | IF( PCOUNT() == 0, aCpoMark[' + cValToChar(nCpo) + ',1] , aCpoMark[' + cValToChar(nCpo) + ',1] := U ) }') , oPnlCpo, 100,10,,,,/*[ bValid]*/,,,,.T., STR0024 ,,/*[ bWhen]*/ ) //"Marque para visualizar as máquinas que não ainda chegaram ao ponto de controle"

			If !Empty(aCpoMark[nCpo,6])
				cCodCor := aCores[Val(aCpoMark[nCpo,6]),1]
			Else
				cCodCor := aCores[nRadio,1]
				aCpoMark[nCpo,6] := cValToChar(nRadio)
			EndIf

			&( cNomeVar ):SetCSS("QCheckBox { background-color: " + cCodCor + " }")
			aCpoMark[nCpo,5] := cNomeVar

		EndIf
		nPosicao := nPosicao+15
	Next

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1620195_ConfirmaConfiguracao()

	Local nVet      := 0
	Local oModelVJT := FWLoadModel( 'VEIA164' )
	Local lAchouVJT

	For nVet := 1 to Len(aCpoMark)
	
		VJT->(DbSetOrder(2))
		lAchouVJT := VJT->(DbSeek(xFilial("VJT")+"001"+aCpoMark[nVet,4]))

		If aCpoMark[nVet,1]

			If lAchouVJT
				oModelVJT:SetOperation( MODEL_OPERATION_UPDATE )
			Else
				oModelVJT:SetOperation( MODEL_OPERATION_INSERT )
			EndIf

			lRet := oModelVJT:Activate()

			If lRet

				oModelVJT:SetValue( "VJTMASTER", "VJT_ORIGEM", "001" )
				oModelVJT:SetValue( "VJTMASTER", "VJT_NOMCPO", aCpoMark[nVet,4] )
				oModelVJT:SetValue( "VJTMASTER", "VJT_CORCPO", aCpoMark[nVet,6] )

				If ( lRet := oModelVJT:VldData() )
					if ( lRet := oModelVJT:CommitData())
					Else
						Help("",1,"COMMITVJT",, oModelVJT:GetErrorMessage()[6] ,1,0)
					EndIf
				Else
					Help("",1,"VALIDVJT",,oModelVJT:GetErrorMessage()[6] + STR0025 + oModelVJT:GetErrorMessage()[2],1,0) // " Campo: "
				EndIf

				oModelVJT:DeActivate()

			Else
				Help("",1,"ACTIVEVJT",, STR0026 ,1,0) //"Não foi possivel ativar o modelo da tabela"
			EndIf

		Else

			If lAchouVJT
				oModelVJT:SetOperation( MODEL_OPERATION_DELETE )
				lRet := oModelVJT:Activate()

				If lRet

					If ( lRet := oModelVJT:VldData() )
						if ( lRet := oModelVJT:CommitData())
						Else
							Help("",1,"COMMITVJT",, oModelVJT:GetErrorMessage()[6] ,1,0)
						EndIf
					Else
						Help("",1,"VALIDVJT",, oModelVJT:GetErrorMessage()[6] + STR0025 + oModelVJT:GetErrorMessage()[2],1,0)
					EndIf

					oModelVJT:DeActivate()

				Else
					Help("",1,"ACTIVEVJT",, STR0026 ,1,0)
				EndIf

			EndIf

		EndIf

	Next

	FreeObj(oModelVJT)

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1620215_LevantaCampos()

	Local aCampos  := {}
	Local oStruVQ0 := FWFormStruct(3,"VQ0")
	Local oStruVJR := FWFormStruct(3,"VJR")
	Local cNCpoVQ0 := "VQ0_FILIAL/VQ0_DATFDD/VQ0_DATORS/VQ0_EVENTO"
	Local cNCpoVJR := "VJR_FILIAL/VJR_STAIMP/VJR_CODVQ0/VJR_CODUSU"
	Local nPos     := 0
	Local nVQ0, nVJR
	Local aCfgCpo

	For nVQ0 := 1 to Len(oStruVQ0[1])
		If !(oStruVQ0[1,nVQ0,3] $ cNCpoVQ0)
			aCfgCpo := VA1620265_MarcacaoCampo(oStruVQ0[1,nVQ0,3])
			nPos++
			aAdd(aCampos,{ aCfgCpo[1] ,;
							oStruVQ0[1,nVQ0,1],;
							nPos,;
							,;
							oStruVQ0[1,nVQ0,3],;
							aCfgCpo[2]})
		EndIf
	Next

	For nVJR := 1 to Len (oStruVJR[1])
		If !(oStruVJR[1,nVJR,3] $ cNCpoVJR)
			aCfgCpo := VA1620265_MarcacaoCampo(oStruVJR[1,nVJR,3])
			nPos++
			aAdd(aCampos,{ aCfgCpo[1],;
							oStruVJR[1,nVJR,1],;
							nPos,;
							,;
							oStruVJR[1,nVJR,3],;
							aCfgCpo[2]})
		EndIf
	Next

Return aCampos

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1620225_BotaoRetroceder(oPanel)

	Local nCpo := 0
	Local aDelCpo := {}
	Local nPMostra := 0

	For nCpo := 1 to Len(aCpoMark)

		If aCpoMark[nCpo,1]

			nPMostra := aCpoMark[nCpo,3]

			aLMostrar[nPMostra,1] := .f.
			&( aLMostrar[nPMostra,4] ):bWhen := {|| .t. }
			aLMostrar[nPMostra,6] := ""

			FreeObj(&(aCpoMark[nCpo,5]))
			
			aAdd(aDelCpo,nCpo)
		EndIf

	Next

	aSort(aDelCpo,,,{|x,y| x > y}) // Ordenacao em ordem decrescente dos registro deletados do vetor

	For nCpo := 1 to Len(aDelCpo)

		aDel(aCpoMark,aDelCpo[nCpo])
		aSize(aCpoMark,Len(aCpoMark)-1)
	Next

	VA1620245_AtualizaCheckBoxCampos(oPanel)

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1620235_WhenCheckBoxCampos(lRetrocede)

	Local lRetorno := .f.
	Local nI

	Default lRetrocede := .f.

	For nI := 1 to Len(aLMostrar)
		If aLMostrar[nI,1]
			&( aLMostrar[nI,4] ):bWhen := {|| lRetrocede }
		EndIf
	Next

Return lRetorno

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1620245_AtualizaCheckBoxCampos(oPnlCpo)

	Local nCpo
	Local nPosicao := 005
	Local cCodCor

	For nCpo := 1 to Len(aCpoMark)

		FreeObj(&(aCpoMark[nCpo,5]))
		cNomeVar := "oChkCpo" + cValToChar(nCpo)
		_SetNamedPrvt( AllTrim(cNomeVar) , cNomeVar , "VA1620145_ConfiguraAlerta" )
		&( cNomeVar ) := TCheckBox():New( nPosicao, 2, aCpoMark[nCpo,2] , &('{ | U | IF( PCOUNT() == 0, aCpoMark[' + cValToChar(nCpo) + ',1] , aCpoMark[' + cValToChar(nCpo) + ',1] := U ) }') , oPnlCpo, 100,10,,,,/*[ bValid]*/,,,,.T., STR0024 ,,/*[ bWhen]*/ )

		If !Empty(aCpoMark[nCpo,6])
			cCodCor := aCores[Val(aCpoMark[nCpo,6]),1]
		Else
			cCodCor := aCores[nRadio,1]
		EndIf

		&( cNomeVar ):SetCSS("QCheckBox { background-color: " + cCodCor + " }")

		aCpoMark[nCpo,5] := cNomeVar
		nPosicao := nPosicao+15

	Next

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function VA1620255_AlteraCorLinha()

	Local cQuery := ""
	Local cOpcCor:= ""
	Local nOpcCor

	cQuery := "SELECT MAX(VJT.VJT_CORCPO) "
	cQuery += " FROM " + RetSqlName("VJT") + " VJT "
	cQuery += " WHERE VJT.VJT_FILIAL = '" + xFilial("VJT") + "'"
	cQuery +=	" AND VJT.VJT_ORIGEM = '001'"
	cQuery += 	" AND EXISTS ( "
	cQuery += 					"SELECT VJS_CPOALT "
	cQuery += 					" FROM " + RetSQLName("VJS") + " VJS "
	cQuery += 					" WHERE VJS.VJS_CODVQ0 = '" + VQ0->VQ0_CODIGO + "' "
	cQuery += 					  " AND VJS.VJS_CPOALT = VJT.VJT_NOMCPO "
	cQuery += 					  " AND VJS.VJS_REGVIS <> '1' "
	cQuery +=					  " AND VJS.D_E_L_E_T_ = ' ' "
	cQuery +=				" ) "
	cQuery +=	" AND VJT.D_E_L_E_T_ = ' ' "

	cOpcCor := FM_SQL(cQuery)

	If !Empty(cOpcCor)

		nOpcCor := Val(cOpcCor)
		Return aCores[nOpcCor,2]

	EndIf

Return Nil

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620265_MarcacaoCampo(cNomCpo)

	Local cQuery   := ""
	Local lRet     := .f.
	Local nRecVJT  := 0
	Local aRetorno := {}

	Default cNomCpo := ""

	If !Empty(cNomCpo)
		cQuery := " SELECT VJT.R_E_C_N_O_ "
		cQuery += " FROM " + RetSqlName("VJT") + " VJT "
		cQuery += " WHERE VJT.VJT_FILIAL = '" + xFilial("VJT") + "' "
		cQuery +=   " AND VJT.VJT_NOMCPO = '" + cNomCpo + "' "
		cQuery +=   " AND VJT.D_E_L_E_T_ = ' ' "

		nRecVJT := FM_SQL(cQuery)
		If nRecVJT > 0
			VJT->(DbGoTo(nRecVJT))
			aRetorno := {.t.,VJT->VJT_CORCPO}
		EndIf

	EndIf

	If Len(aRetorno) == 0
		aRetorno := {.f.,""}
	EndIf

Return aRetorno

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620275_BotaoAvancar(oPanel)

	VA1620185_CheckBoxCamposAlerta(oPanel)
	VA1620235_WhenCheckBoxCampos( .f. )

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620285_StatusColAtendimento()
	
	// Variável do Retorno
	Local cImgRPO := ""

	If VM190EVZS(VQ1->VQ1_CODBON) // Verifica se existe registro no VZS - Bonus esta selecionado no Atendimento
		cImgRpo := "PMSEDT4"
	EndIf

Return cImgRPO

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VM190EVZS(_cCodBon)

	Local cQuery := ""

	Local cIteTra := ""

	Local lVZS_FILATE := ( VZS->(FieldPos("VZS_FILATE")) > 0 )
	Local lVZS_ITETRA := ( VZS->(FieldPos("VZS_ITETRA")) > 0 )

	If !Empty(VQ0->VQ0_ITETRA)

		cIteTra := VQ0->VQ0_ITETRA

	Else

		cQuery := "SELECT VVA.VVA_ITETRA "
		cQuery += " FROM " + RetSqlName("VVA") + " VVA "
		cQuery += " WHERE VVA.VVA_FILIAL = '" + VQ0->VQ0_FILATE +"' "
		cQuery += 	" AND VVA.VVA_NUMTRA = '" + VQ0->VQ0_NUMATE +"' "
		cQuery += 	" AND VVA.VVA_CHAINT = '" + VQ0->VQ0_CHAINT +"' "
		cQuery += 	" AND VVA.D_E_L_E_T_=' '"

		cIteTra := FM_SQL(cQuery)

	EndIf

	cQuery := "SELECT R_E_C_N_O_ AS RECVZS"
	cQuery += "  FROM " + RetSqlName("VZS")
	cQuery += " WHERE VZS_FILIAL = '" + xFilial("VZS") + "' "
	cQuery += "   AND VZS_CODBON = '" + _cCodBon + "'"

	If lVZS_FILATE
		cQuery += " AND VZS_FILATE = '" + VQ0->VQ0_FILATE + "'"
	EndIf

	cQuery += "   AND VZS_NUMATE = '" + VQ0->VQ0_NUMATE + "'"

	If lVZS_ITETRA
		cQuery += " AND VZS_ITETRA = '" + cIteTra + "'"
	EndIf

	cQuery += "   AND D_E_L_E_T_ = ' ' "

Return ( FM_SQL(cQuery) > 0 ) // Existe registro no VZS - Bonus esta selecionado no Atendimento/Item

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620295_AtualizaDadosPedido()

	Local lVQ0_ITETRA := ( VQ0->(FieldPos("VQ0_ITETRA")) > 0 )
	Local cQAlSQL    := "ALIASSQL"
	Local aTravas 	 := {}
	Local lRegBloq	 := .F.

	// Atualiza o CHASSI, caso houve atualização no VV1
	cQuery := "SELECT VQ0.R_E_C_N_O_ AS RECVQ0 , VV1.VV1_CHASSI, VVA.VVA_ITETRA "
	cQuery += "FROM " + RetSQLName("VQ0") + " VQ0 "
	cQuery += "LEFT JOIN " + RetSQLName("VV1") + " VV1 ON ( VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1.VV1_CHAINT=VQ0.VQ0_CHAINT AND VV1.VV1_CHASSI<>' ' AND VV1.D_E_L_E_T_=' ' ) "

	If lVQ0_ITETRA
		cQuery += "LEFT JOIN "+RetSQLName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VQ0.VQ0_FILATE AND VVA.VVA_NUMTRA=VQ0.VQ0_NUMATE AND VVA.VVA_CHAINT=VQ0.VQ0_CHAINT AND VVA.D_E_L_E_T_=' ' ) "
	EndIf

	cQuery += "WHERE VQ0.VQ0_FILIAL = '" + xFilial("VQ0") + "'"
	cQuery += " AND ( "
	cQuery += 			" VQ0.VQ0_CHASSI = ' ' "

	If lVQ0_ITETRA
		cQuery +=		 " OR VQ0.VQ0_ITETRA = ' ' "
	EndIf

	cQuery += " ) AND VQ0.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )

	While !( cQAlSQL )->( Eof() )

		DbSelectArea("VQ0")
		DbGoto(( cQAlSQL )->( RECVQ0 ))
		
		//Atualiza o registro apenas se ele não estiver travado (sendo alterado por alguém)
		If VQ0->(DBRLock(( cQAlSQL )->( RECVQ0 )))
			
			If !Empty(( cQAlSQL )->( VV1_CHASSI )) .and. Empty(VQ0->VQ0_CHASSI)
				VQ0->VQ0_CHASSI := ( cQAlSQL )->( VV1_CHASSI )
			EndIf

			If lVQ0_ITETRA
				If !Empty(( cQAlSQL )->( VVA_ITETRA )) .and. Empty(VQ0->VQ0_ITETRA)
					VQ0->VQ0_ITETRA := ( cQAlSQL )->( VVA_ITETRA )
				EndIf
			EndIf

			VQ0->(DBRUnlock(( cQAlSQL )->( RECVQ0 )))
		EndIf
		( cQAlSQL )->( DbSkip() )

	EndDo

	( cQAlSQL )->( DbCloseArea() )

	DbSelectArea("VQ0")

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620305_ColunaStatusPedido()
	
	// Variável do Retorno
	Local cImgRPO := ""

	//-- Define Status do registro
	If VQ1->VQ1_STATUS == "1"
		cImgRpo := "BR_VERDE"
	ElseIf VQ1->VQ1_STATUS == "2"
		cImgRpo := "BR_AZUL"
	ElseIf VQ1->VQ1_STATUS == "3"
		cImgRpo := "BR_VERMELHO"
	ElseIf Empty(VQ1->VQ1_STATUS)
		cImgRpo := "BR_BRANCO"
	EndIf

Return cImgRPO

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620315_LegendaStatusPedido()
	
	// Array das Legendas
	Local aLegenda := {	{"BR_VERDE" 	, STR0027 }, ; //"Confirmado"
						{"BR_AZUL"		, STR0028 }, ; 	//"Faturado"
						{"BR_VERMELHO"	, STR0029 }, ;	//"Cancelado"
						{"BR_BRANCO"	, STR0030 } }
	
	If ExistBlock("VM190STA") 
		aLegenda := ExecBlock("VM190STA",.f.,.f.)
	EndIf

	//-- Define Status do registro
	BrwLegenda( STR0031 , STR0015 ,aLegenda )	// "Pedidos de Máquina" / "Legenda"
	
Return .T.

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620325_RightClick()

	Local oVJS := FWLoadModel( 'VEIA143' )

	If MsgNoYes( STR0032 , STR0002 ) //"Todas as alterações não vistas serão marcadas. Deseja continuar?" / "Atenção"

		cQuery := "SELECT VJS.R_E_C_N_O_ VJSRECNO "
		cQuery += " FROM " + RetSQLName("VJS") + " VJS "
		cQuery += " WHERE VJS.VJS_CODVQ0 = '" + VQ0->VQ0_CODIGO + "' "
		cQuery +=	" AND VJS.VJS_REGVIS <> '1' "
		cQuery +=	" AND VJS.D_E_L_E_T_ = ' ' "

		TcQuery cQuery New Alias "TMPVJS"

		While !TMPVJS->(Eof())

			VJS->(DbGoTo(TMPVJS->VJSRECNO))

			oVJS:SetOperation( MODEL_OPERATION_UPDATE )
			
			lRet := oVJS:Activate()

			if lRet

				oVJS:SetValue( "VJSMASTER", "VJS_REGVIS", "1" )

				If ( lRet := oVJS:VldData() )
					if ( lRet := oVJS:CommitData())
					Else
						Help("",1,"COMMITVJS",, oVJS:GetErrorMessage()[6] ,1,0)
					EndIf
				Else
					Help("",1,"VALIDVJS",,oVJS:GetErrorMessage()[6] + STR0025 + oVJS:GetErrorMessage()[2],1,0)
				EndIf
					
				oVJS:DeActivate()

			Else
				Help("",1,"ACTIVEVJS",, STR0026 ,1,0)
			EndIf

			TMPVJS->(DbSkip())

		EndDo

		TMPVJS->(DbCloseArea())

	EndIf

	FreeObj(oVJS)

	oBrwVQ0:Refresh()

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620335_Sair()

	oDlgWA:End()

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620345_VisualizaAlteracoes()

	Local lNaoVistos := .f.

	cQuery := "SELECT VJS.R_E_C_N_O_"
	cQuery += " FROM " + RetSQLName("VJS") + " VJS "
	cQuery += " WHERE VJS.VJS_FILIAL = '" + xFilial("VJS") + "' "
	cQuery +=	" AND VJS.VJS_CODVQ0 = '" + VQ0->VQ0_CODIGO + "' "
	cQuery +=	" AND VJS.VJS_REGVIS <> '1' "
	cQuery +=	" AND VJS.D_E_L_E_T_ = ' ' "

	lNaoVistos := FM_SQL(cQuery) > 0

	VEIA161(VQ0->VQ0_CODIGO,lNaoVistos)

Return

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620355_ColunaStatus()

	Local cImgRPO := ""
	cImgRpo := ExecBlock("VA162COR",.f.,.f.,{ VQ0->(Recno()) })

Return cImgRPO

/*/{Protheus.doc} VEIA162

@author Renato Vinicius
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function VA1620365_LegendaStatus()

	Local aLegenda := {}

	If ExistBlock("VA162LEG")
		aLegenda := ExecBlock("VA162LEG",.f.,.f.,{ aLegenda })
	EndIf

	BrwLegenda(STR0015, STR0031, aLegenda)

Return .T.