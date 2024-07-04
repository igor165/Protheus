#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#Include "OFIOM390.ch"
#Include "Protheus.ch"
#INCLUDE "AP5MAIL.CH"
/*/{Protheus.doc} OFIOM390
Conferencia de NF de Entrada - Pre-Nota

@author Renato
@since 18/11/2019
@version undefined

@type function
/*/
Function OFIOM390(cConfNF)

	Local cFiltro    := ""
	Local aSize      := FWGetDialogSize( oMainWnd )

	Local oSqlHlp    := DMS_SqlHelper():New()
	Local lAprovador := OM3900141_UsuarioAprovador()

	Local cFNome     := ""
	Local cFStatus   := ""
	Local nCntFor    := 0
	Local lVldConf   := OM3900171_Trabalha_com_Conferencia() // Trabalha com Conferência de Itens na Entrada de NF ?
	Local lRet       := .t. // Return .t. Deixa passar na Validação da Conferencia

	Default cConfNF  := ""

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//                                                                                                                                        //
	// Parametro para controlar comportamento da rotina de conferencia: XYZ, onde:                                                            //
	//                                                                                                                                        //
	// X = Traz os Itens na Tela e indica se o item ja esta conferido (legenda/cores)        -->   0 = Nao            /   1 = Sim (default)   //
	// Y = Mostra o campo de Qtde de Itens na propria tela de digitacao do codigo de barras  -->   0 = Nao            /   1 = Sim (default)   //
	// Z = Utiliza Controle de Aprovação da Conferencia de Itens de Entrada                  -->   0 = Nao (default)  /   1 = Sim             //
	//                                                                                                                                        //
	Private cTpConf := GetNewPar("MV_MIL0091","110")                                                                                          // 
	//                                                                                                                                        //
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Private lMostraItem := substr(cTpConf,1,1) == "1"
	Private lMostraQtd  := substr(cTpConf,2,1) == "1"
	Private lUtilAprova := substr(cTpConf,3,1) == "1"

	Private nFiltDia  := 7
	Private cFiltFor  := Space(GetSX3Cache("F1_FORNECE","X3_TAMANHO"))
	Private cFiltLoj  := Space(GetSX3Cache("F1_LOJA","X3_TAMANHO"))

	Private lNFTransf := .f. // NF de Entrada é uma Transferencia?

	Private cCadastro := STR0056 // Conferência de Nota Fiscal de Entrada

	If ExistBlock("OM390ROT")
	
		Return ExecBlock("OM390ROT",.f.,.f.,{ cConfNF }) // Substitui a Rotina Padrão OFIOM390
	
	Else

		If !Empty(cConfNF) // VALIDAR CONFERENCIA DE ITENS DA NF DE ENTRADA
			//
			If lVldConf
				cQuery := "SELECT COUNT(VM0.VM0_DOC) AS QTDE "
				cQuery += "  FROM " + RetSqlName("VM0") + " VM0 "
				cQuery += " WHERE VM0.VM0_FILIAL = '" + xFilial("VM0") + "' "
				cQuery += "   AND VM0.VM0_STATUS = '4'"
				cQuery += "   AND " + oSqlHlp:Concat({'VM0_DOC', 'VM0_SERIE', 'VM0_FORNEC', 'VM0_LOJA'}) + " = '" + cConfNF + "'"
				cQuery += "   AND VM0.D_E_L_E_T_ = ' '"
				If FM_SQL(cQuery) == 0 // NAO Existe Conferencia da NF APROVADA Individualmente
					cQuery := "SELECT COUNT(VM7.VM7_VOLUME) AS QTDE "
					cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
					cQuery += "  LEFT JOIN " + RetSqlName("VM7") + " VM7 ON VM7.VM7_FILIAL='"+xFilial("VM7")+"' AND VM7.VM7_STATUS='4' AND VM7.VM7_VOLUME=VCX.VCX_VOLUME AND VM7.D_E_L_E_T_=' '"
					cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "' "
					cQuery += "   AND " + oSqlHlp:Concat({'VCX.VCX_DOC', 'VCX.VCX_SERIE', 'VCX.VCX_FORNEC', 'VCX.VCX_LOJA'}) + " = '" + cConfNF + "'"
					cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
					If FM_SQL(cQuery) == 0 .or. !OFIA340(cConfNF) // NAO Existe Conferencia de Volume ou NAO esta com TODAS as Conferencias dos Volumes APROVADAS ( Todos os Volumes que fazem parte da NF de Entrada )
						cQuery := "SELECT COUNT(*) "
						cQuery += "  FROM " + RetSqlName("SD1") + " SD1 "
						cQuery += "  LEFT JOIN " + RetSqlName("SF4") + " SF4 ON ( SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_=' ' )"
						cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
						cQuery += "   AND " + oSqlHlp:Concat({'D1_DOC', 'D1_SERIE', 'D1_FORNECE', 'D1_LOJA'}) + " = '" + cConfNF + "'"
						cQuery += "   AND ( SF4.F4_ESTOQUE IS NULL OR SF4.F4_ESTOQUE='S' ) "
						cQuery += "   AND SD1.D_E_L_E_T_ = ' '"
						If FM_SQL(cQuery) > 0 // Itens da NF Movimentam Estoque
							lRet := .f. // .f. (default) Bloqueia pq NAO existe Conferencia APROVADA
							If ExistBlock("OM390VLD")
								lRet := ExecBlock("OM390VLD",.f.,.f.,{ cConfNF }) // Ponto de Entrada utilizado para validar se NF pode avançar a Classificação mesmo sem que houve a Conferencia realizada
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			FreeObj(oSqlHlp)
			Return lRet
			//
		EndIf
		FreeObj(oSqlHlp)

		SetKey(VK_F12,{ || OM3900255_FiltraNotaFiscal() })

		cFiltro := "@ F1_STATUS = ' ' "
		If !lAprovador
			cFiltro += " AND NOT EXISTS ( "
			cFiltro += 				" SELECT VM0.VM0_DOC "
			cFiltro += 				" FROM " + RetSqlName("VM0") + " VM0 "
			cFiltro += 				" WHERE VM0.VM0_FILIAL ='" + xFilial("VM0") + "' "
			cFiltro += 				" AND VM0.VM0_STATUS IN ('3','4') "
			cFiltro += 				" AND VM0.VM0_DOC = F1_DOC "
			cFiltro += 				" AND VM0.VM0_SERIE = F1_SERIE "
			cFiltro += 				" AND VM0.VM0_FORNEC = F1_FORNECE "
			cFiltro += 				" AND VM0.VM0_LOJA = F1_LOJA "
			cFiltro += 				" AND VM0.D_E_L_E_T_ = ' '"
			cFiltro += ")"
		EndIf
		cFiltro += " AND EXISTS ( "
		cFiltro += 				" SELECT SD1.D1_DOC "
		cFiltro += 				" FROM " + RetSqlName("SD1") + " SD1 "
		cFiltro += 				" LEFT JOIN " + RetSqlName("SF4") + " SF4 ON ( SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_=' ' )"
		cFiltro += 				" WHERE SD1.D1_FILIAL ='" + xFilial("SD1") + "' "
		cFiltro += 				" AND SD1.D1_DOC = F1_DOC "
		cFiltro += 				" AND SD1.D1_SERIE = F1_SERIE "
		cFiltro += 				" AND SD1.D1_FORNECE = F1_FORNECE "
		cFiltro += 				" AND SD1.D1_LOJA = F1_LOJA "
		cFiltro += 				" AND ( SD1.D1_TES = ' ' OR SF4.F4_ESTOQUE='S' ) "
		cFiltro += 				" AND SD1.D_E_L_E_T_ = ' '"
		If ExistBlock("OMSQLSD1")
			cFiltro += ExecBlock("OMSQLSD1",.f.,.f.,{"1"}) // Ponto de Entrada para completar o SQL de Levantamento das NFs de Entrada a Conferir
		EndIf
		cFiltro += ")"

		oDlgOM390 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0056, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Conferência de Nota Fiscal de Entrada

		oWorkArea := FWUIWorkArea():New( oDlgOM390 )
			
		If !lMostraItem //Mostra item - Não
			oWorkArea:CreateHorizontalBox( "LINE01", 100 )
			oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
		Else
			oWorkArea:CreateHorizontalBox( "LINE01", 49 )
			oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
			oWorkArea:CreateHorizontalBox( "LINE02", 49 )
			oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )
		EndIf

		oWorkArea:Activate()

		oBrwSF1 := FwMBrowse():New()
		oBrwSF1:SetOwner(oWorkarea:GetPanel("OBJ1"))
		oBrwSF1:SetDescription(STR0056) // Conferência de Nota Fiscal de Entrada
		oBrwSF1:SetAlias('SF1')
		oBrwSF1:DisableReport()
		oBrwSF1:SetMenuDef( 'OFIOM390' )
		oBrwSF1:AddStatusColumns({|| OM3900025_ColunaStatusNotaFiscal() }, {|| OM3900035_LegendaStatusNotaFiscal() })
		oBrwSF1:SetChgAll(.T.) //nao apresentar a tela para informar a filial
		oBrwSF1:SetFilterDefault( cFiltro )

		oBrwSF1:AddFilter(STR0057,"@ F1_DTDIGIT >='" + DtoS(dDataBase - nFiltDia) + "'",.t.,.t.,,,,"data") // Data da NF

		If lAprovador
			For nCntFor := 2 to 5 // Criar Filtros por STATUS
				cFStatus := "@ EXISTS ( "
				cFStatus += 		" SELECT VM0_DOC "
				cFStatus += 		" FROM " + RetSqlName("VM0") + " VM0 "
				cFStatus += 		" WHERE VM0.VM0_FILIAL ='" + xFilial("VM0") + "' "
				cFStatus += 		" AND VM0.VM0_STATUS = '"+strzero(nCntFor,1)+"' "
				cFStatus += 		" AND VM0.VM0_DOC = F1_DOC "
				cFStatus += 		" AND VM0.VM0_SERIE = F1_SERIE "
				cFStatus += 		" AND VM0.VM0_FORNEC = F1_FORNECE "
				cFStatus += 		" AND VM0.VM0_LOJA = F1_LOJA "
				cFStatus += 		" AND VM0.D_E_L_E_T_ = ' '"
				cFStatus += ")"
				cFNome := ""
				Do Case
					Case nCntFor == 2
						cFNome := STR0058 // Conferencias Parciais
					Case nCntFor == 3
						cFNome := STR0059 // Conferencias Finalizadas
					Case nCntFor == 4
						cFNome := STR0060 // Conferencias Aprovadas
					Case nCntFor == 5
						cFNome := STR0061 // Conferencias Reprovadas
				EndCase
				oBrwSF1:AddFilter(cFNome,cFStatus,.f.,.f.,,,,"status"+strzero(nCntFor,1))
			Next
		EndIf

		oBrwSF1:DisableDetails()
		oBrwSF1:ForceQuitButton(.T.)
		oBrwSF1:Activate()

		If lMostraItem //Mostra item - Sim
			oBrwSD1 := FwMBrowse():New()
			oBrwSD1:SetOwner(oWorkarea:GetPanel("OBJ2"))
			oBrwSD1:SetDescription(STR0062) // Itens da Nota Fiscal de Entrada
			oBrwSD1:SetMenuDef( '' )
			oBrwSD1:SetAlias('SD1')
			oBrwSD1:AddStatusColumns({|| OM3900045_ColunaStatusItens() }, {|| OM3900055_LegendaStatusItens() })
			oBrwSD1:DisableLocate()
			oBrwSD1:DisableDetails()
			oBrwSD1:SetAmbiente(.F.)
			oBrwSD1:SetWalkthru(.F.)
			oBrwSD1:SetInsert(.f.)
			oBrwSD1:SetUseFilter()
			oBrwSD1:lOptionReport := .f.
			oBrwSD1:Activate()

			oRelacPed:= FWBrwRelation():New()
			oRelacPed:AddRelation( oBrwSF1 , oBrwSD1 , {{ "D1_FILIAL", "F1_FILIAL" }, { "D1_DOC", "F1_DOC" }, { "D1_SERIE", "F1_SERIE" }, { "D1_FORNECE", "F1_FORNECE" }, { "D1_LOJA", "F1_LOJA" } })
			oRelacPed:Activate()
		EndIf

		oDlgOM390:Activate( , , , , , , ) //ativa a janela

		SetKey(VK_F12,Nil)
	
	EndIf

Return NIL

Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	ADD OPTION aRotina TITLE STR0043 ACTION 'OM3900015_ConferenciaItem()' OPERATION 4 ACCESS 0 // Conferir
	ADD OPTION aRotina TITLE STR0116 ACTION 'OM3900321_VisualizarConferencia()' OPERATION 2 ACCESS 0 // Visualizar

Return aRotina

/*/{Protheus.doc} OM3900025_ColunaStatusNotaFiscal

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM3900025_ColunaStatusNotaFiscal()
	
	// Variável do Retorno
	Local cImgRPO := "BR_BRANCO"

	cAlVM0 := 'TABVM0'
	BeginSql alias cAlVM0
		SELECT
			VM0.VM0_CODIGO,
			VM0.VM0_STATUS
		FROM
			%table:VM0% VM0
		WHERE
			VM0.VM0_FILIAL = %xfilial:VM0% AND
			VM0.VM0_DOC = %exp:SF1->F1_DOC% AND
			VM0.VM0_SERIE = %exp:SF1->F1_SERIE% AND
			VM0.VM0_FORNEC = %exp:SF1->F1_FORNECE% AND
			VM0.VM0_LOJA = %exp:SF1->F1_LOJA% AND
			VM0.%notDel%
		ORDER BY 1 DESC
	EndSql

	//-- Define Status do registro
	If (cAlVM0)->VM0_STATUS == "2" //Conf Parcial
		cImgRpo := "BR_AMARELO"
	ElseIf (cAlVM0)->VM0_STATUS == "3" //Conferido
		cImgRpo := "BR_VERDE"
	ElseIf (cAlVM0)->VM0_STATUS == "4" //Aprovado
		cImgRpo := "BR_PRETO"
	ElseIf (cAlVM0)->VM0_STATUS == "5" //Reprovado
		cImgRpo := "BR_VERMELHO"
	EndIf

	(cAlVM0)->(dbCloseArea())
	
Return cImgRPO

/*/{Protheus.doc} OM3900035_LegendaStatusNotaFiscal

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM3900035_LegendaStatusNotaFiscal()
	
	// Array das Legendas
	Local aLegenda := {	{"BR_BRANCO"	, STR0065 },; // Pendente
						{"BR_AMARELO"	, STR0066 },; // Conf Parcial
						{"BR_VERDE"		, STR0067 },; // Conferido
						{"BR_PRETO"		, STR0068 },; // Aprovado
						{"BR_VERMELHO"	, STR0069 } } // Reprovado

	//-- Define Status do registro
	BrwLegenda(STR0064,STR0063,aLegenda )	// Status das Notas Fiscais / Legenda
	
Return .T.

/*/{Protheus.doc} OM3900045_ColunaStatusItens

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM3900045_ColunaStatusItens()
	
	// Variável do Retorno
	Local cImgRPO := "BR_BRANCO"

	cAlVM0 := 'TABVM0'
	BeginSql alias cAlVM0
		SELECT
			VM0.VM0_CODIGO,
			VM0.VM0_STATUS,
			VM1.VM1_QTCONF,
			VM1.VM1_QTORIG
		FROM
			%table:VM0% VM0
			JOIN %table:VM1% VM1 ON
				VM1.VM1_FILIAL = %xfilial:VM1% AND
				VM1.VM1_CODVM0 = VM0.VM0_CODIGO AND
				VM1.VM1_COD = %exp:SD1->D1_COD% AND
				VM1.%notDel%
		WHERE
			VM0.VM0_FILIAL = %xfilial:VM0% AND
			VM0.VM0_DOC = %exp:SD1->D1_DOC% AND
			VM0.VM0_SERIE = %exp:SD1->D1_SERIE% AND
			VM0.VM0_FORNEC = %exp:SD1->D1_FORNECE% AND
			VM0.VM0_LOJA = %exp:SD1->D1_LOJA% AND
			VM0.%notDel%
		ORDER BY 1 DESC
	EndSql

	If !(cAlVM0)->(Eof())
		//-- Define Status do registro
		If (cAlVM0)->VM1_QTCONF == 0 //Item nao conferido
			cImgRpo := "BR_AMARELO"
		ElseIf (cAlVM0)->VM1_QTCONF == (cAlVM0)->VM1_QTORIG .and. (cAlVM0)->VM0_STATUS <> "1" //Quantidade conferida 
			cImgRpo := "BR_VERDE"
		ElseIf (cAlVM0)->VM1_QTCONF <> (cAlVM0)->VM1_QTORIG .and. (cAlVM0)->VM0_STATUS <> "1" //Divergencia na conferencia
			cImgRpo := "BR_VERMELHO"
		EndIf
	EndIf

	(cAlVM0)->(dbCloseArea())

Return cImgRPO

/*/{Protheus.doc} OM3900055_LegendaStatusItens

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM3900055_LegendaStatusItens()
	
	// Array das Legendas
	Local aLegenda := {	{"BR_BRANCO"	, STR0071 },; // Sem Status
						{"BR_AMARELO"	, STR0072 },; // Item nao Conferido
						{"BR_VERDE"		, STR0074 },; // Item conferido corretamente
						{"BR_VERMELHO"	, STR0075 } } // Divergencia na Conferencia

	//-- Define Status do registro
	BrwLegenda(STR0070,STR0063,aLegenda )	// Status dos Itens / Legenda
	
Return .T.


/*/{Protheus.doc} OM3900015_ConferenciaItem

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM3900015_ConferenciaItem()

	Local cNroConf	 := ""
	Local aNota		 := {}
	Local lVisualiza := .f.
	Local cMsg		 := ""
	Local lAprovador := OM3900141_UsuarioAprovador()
	Local cQuery     := ""
	Local nCntFor    := 0
	Local aVolumes   := {}
	Local lOkConf    := .t.
	Local lFuncTempo := ExistFunc("OA3630011_Tempo_Total_Conferencia_Volume_Entrada")

	If ExistFunc("OA3600011_Tempo_Total_Conferencia_NF_Entrada")
		OA3600011_Tempo_Total_Conferencia_NF_Entrada( 1 , SF1->F1_DOC , SF1->F1_SERIE , SF1->F1_FORNECE , SF1->F1_LOJA ) // 1=Iniciar o Tempo Total da Conferencia de NF de Entrada caso não exista o registro
	EndIf

	aVolumes := OA3400041_VolumesporNF( SF1->F1_DOC , SF1->F1_SERIE , SF1->F1_FORNECE , SF1->F1_LOJA )
	For nCntFor := 1 to len(aVolumes)
		If lFuncTempo
			OA3630011_Tempo_Total_Conferencia_Volume_Entrada( 1 , aVolumes[nCntFor,1] ) // 1=Iniciar o Tempo Total da Conferencia de Volume de Entrada caso não exista o registro
		EndIf
		If !Empty(aVolumes[nCntFor,2]) // Existe Conferencia para o Volume
			MsgStop(STR0117+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Esta NF contem Volume que já foi para Conferencia. Impossível continuar.
					STR0118+": "+aVolumes[nCntFor,1],STR0009) // Volume / Atencao
			lOkConf := .f.
		EndIf
	Next
	If !lOkConf
		Return
	EndIf

	aNota := {SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA}

	cNroConf := OM3900125_ExisteConferencia( aNota , .t. )
	If Empty(cNroConf)
		cNroConf := OM3900095_GravaRegistroConferencia( aNota )
	EndIf
	
	If VM0->( DbSeek( xFilial("VM0") + cNroConf ) )
	
		If !lAprovador .and. !(VM0->VM0_STATUS == "1" .or. VM0->VM0_STATUS == "2")
			MsgStop(STR0076,STR0009) // Nota fiscal já conferida e aguardando aprovação. / Atencao
			Return
		EndIf

		Do Case
			Case VM0->VM0_STATUS == "1" .or. VM0->VM0_STATUS == "2"
				cMsg := STR0102 // Conferência da NF de Entrada está Pendente. Deseja Visualizar?
			Case VM0->VM0_STATUS == "3"
				cMsg := STR0103 // Conferência da NF de Entrada está Finalizada. Deseja Visualizar
			Case VM0->VM0_STATUS == "4"
				cMsg := STR0104 // Conferência da NF de Entrada está Aprovada. Deseja Visualizar?
			Case VM0->VM0_STATUS == "5"
				cMsg := STR0105 // Conferência da NF de Entrada está Reprovada. Deseja Visualizar?
		EndCase
		if lAprovador .or. VM0->VM0_STATUS == "1" .or. VM0->VM0_STATUS == "2"
			If lAprovador .and. VM0->VM0_STATUS <> "3"
				If !MsgYesNo(cMsg)
					Return
				EndIf
				lVisualiza := .t.
			EndIf
		Else
			If !MsgYesNo(cMsg)
				Return
			EndIf
			lVisualiza := .t.
			
			Do Case
				Case VM0->VM0_STATUS == "1" .or. VM0->VM0_STATUS == "2"
					cMsg := STR0077 // Conferência de Nota Fiscal ainda Pendente
				Case VM0->VM0_STATUS == "4"
					cMsg := STR0078 // Conferência de Nota Fiscal já Aprovada
				Case VM0->VM0_STATUS == "5"
					cMsg := STR0079 // Conferência de Nota Fiscal já Reprovada
			EndCase

			MsgInfo(cMsg,STR0009) // Atencao
		EndIf
		If !lVisualiza
			//
			lNFTransf := .f.
			If SF1->F1_TIPO <> "D"
				cQuery := "SELECT R_E_C_N_O_ AS RECSF2"
				cQuery += "  FROM "+RetSQLName("SF2")
				cQuery += " WHERE F2_FILIAL  = '"+SF1->F1_FILORIG+"'"
				cQuery += "   AND F2_DOC     = '"+SF1->F1_DOC+"'"
				cQuery += "   AND F2_SERIE   = '"+SF1->F1_SERIE+"'"
				cQuery += "   AND F2_FILDEST = '"+SF1->F1_FILIAL+"'"
				cQuery += "   AND D_E_L_E_T_ = ' '"
				If FM_SQL(cQuery) > 0
					lNFTransf := .t. // NF de Transferencia de outra Filial
				EndIf
			EndIf
			//
			If !Softlock("SF1") // Travar Registro do SF1
				Return
			EndIf
			//
		EndIf
		OM3900065_TelaConferencia( cNroConf, lVisualiza )
		If !lVisualiza
			//
			SF1->(MsUnlock()) // Retirar SoftLock do SF1
			//
		EndIf
	
	EndIf

Return

/*/{Protheus.doc} OM3900065_TelaConferencia

@author Renato Vinicius
@since 07/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM3900065_TelaConferencia( cConferencia, lVisualiza )

	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := STR0056 // Conferência Nota Fiscal de Entrada
	Local aButtons		:= {}
	Local cTexto		:= ""
	Local lAprovador    := OM3900141_UsuarioAprovador()

	Default cConferencia := ""
	Default lVisualiza  := .f.

	Private lMostraCod	:= .t.
	Private aItensNF	:= {}
	Private aItensConf	:= {}

	Private cPictQUANT  := Alltrim(GetSX3Cache("D1_QUANT","X3_PICTURE"))
	Private cCod        := space(50)
	Private nQtd        := 1

	if Empty(cConferencia)
		Return
	EndIf

	If lVisualiza .or. lAprovador
		lMostraItem := .t.
		lMostraQtd := .f.
		lMostraCod  := .f.
	EndIf
	
	If !lVisualiza
		cTitulo +=	If(VAI->VAI_APRCON=="1"," - "+STR0026,"") // Aprovacao
	EndIf

	VM0->(DbSeek(xFilial("VM0")+cConferencia))

	SF1->(DbSetOrder(1))
	SF1->(DbSeek(xFilial("SF1")+VM0->VM0_DOC+VM0->VM0_SERIE+VM0->VM0_FORNEC+VM0->VM0_LOJA))
	If SF1->F1_TIPO <> "D"
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2")+VM0->VM0_FORNEC+VM0->VM0_LOJA))
	Else
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+VM0->VM0_FORNEC+VM0->VM0_LOJA))
	EndIf

	OM390007_LevantaItens(cConferencia)

	oConfBarra := MSDialog():New( aCoors[1], aCoors[2], aCoors[3], aCoors[4], cTitulo, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )    // "Área de Trabalho"
	oConfBarra:lEscClose := .F.

		oLayer := FWLayer():new()
		oLayer:Init(oConfBarra,.f.)

		//Cria as linhas do Layer
		oLayer:addLine( 'L1', 95, .F. )

		//Cria as colunas do Layer
		oLayer:addCollumn('C1L1',26,.F.,"L1") 
		oLayer:addCollumn('C2L1',74,.F.,"L1") 

		oLayer:AddWindow('C1L1','WIN_TPINF',STR0080,64,.F.,.F.,,'L1',) // Informações

		_cRight1Win:= oLayer:GetWinPanel('C1L1','WIN_TPINF', 'L1')
		
		If lMostraItem // Mostra Itens - Sim
			oLayer:AddWindow('C1L1','WIN_LEGEN',STR0063,35,.F.,.F.,,'L1',) // Legenda
			_cRight2Win:= oLayer:GetWinPanel('C1L1','WIN_LEGEN', 'L1')
		EndIf

		_cTopCol2  := oLayer:getColPanel('C2L1','L1')

		// Cria browse
		oListItens := MsBrGetDBase():new( 0, 0, 260, 170,,,, _cTopCol2,,,,,,,,,,,, .F.,, .T.,, .F.,,, )
		oListItens:Align := CONTROL_ALIGN_ALLCLIENT

		// Define vetor para a browse
		oListItens:setArray( aItensConf )
	
		// Cria colunas do browse
		oListItens:addColumn( TCColumn():new( STR0003 , { || aItensConf[oListItens:nAt,2] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Grupo
		oListItens:addColumn( TCColumn():new( STR0004 , { || aItensConf[oListItens:nAt,3] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Cod.Item
		oListItens:addColumn( TCColumn():new( STR0005 , { || aItensConf[oListItens:nAt,4] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Descricao
		oListItens:addColumn( TCColumn():new( STR0021 , { || aItensConf[oListItens:nAt,9] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Locacao
		oListItens:addColumn( TCColumn():new( STR0081 , { || FG_AlinVlrs(Transform(aItensConf[oListItens:nAt,5],cPictQUANT)) },,,, "LEFT",, .F., .T.,,,, .F. ) ) // Qtd.Conferida
		
		If lAprovador
			oListItens:addColumn( TCColumn():new( STR0030 , { || FG_AlinVlrs(Transform(aItensConf[oListItens:nAt,6],cPictQUANT)) },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Qtd.Original
		EndIf

		If lMostraItem // Mostra Itens - Sim
			bColor := &("{|| aItensConf[oListItens:nAt,1] }")
			oListItens:SetBlkBackColor(bColor)

			oCorAmarelo := tBitmap():New(005, 005, 068, 010, 'BR_AMARELO' , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
			oSayAmarelo := tSay():New(005, 015, {|| STR0072 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item nao conferido

			oCorAzul := tBitmap():New(015, 005, 078, 010, 'BR_AZUL', , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
			oSayAzul := tSay():New(015, 015, {|| STR0073 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item não existente na NF

			oCorVerde := tBitmap():New(025, 005, 088, 010, 'BR_VERDE' , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
			oSayVerde:= tSay():New(025, 015, {|| STR0074 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item conferido corretamente

			oCorVermelho := tBitmap():New(035, 005, 088, 010, 'BR_VERMELHO' , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
			oSayVermelho:= tSay():New(035, 015, {|| STR0075 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Divergencia na Conferencia

		EndIf

		If !lVisualiza .and. !lAprovador
			oListItens:bLDblClick := { || lEditCell( aItensConf , oListItens , cPictQUANT , 5 ), OM3900185_QtdConferida(aItensConf[oListItens:nAt],aItensConf[oListItens:nAt,5],.t.)}
		EndIf

		oListItens:Refresh()

		nLinIni := 5

		If lMostraQtd // Mostra Qtde - Sim
			oSayQtd := tSay():New( nLinIni   , 005, {|| STR0082 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Quantidade
			oGetQtd := TGet():New( nLinIni+8, 005, { | u | If( PCount() == 0, nQtd, nQtd := u ) },_cRight1Win,060, 010, cPictQUANT ,{ || nQtd >= 0 },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nQtd",,,,)
			nLinIni += 27
		EndIf

		If lMostraCod
			oSayCod := tSay():New( nLinIni   , 005, {|| STR0083 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Codigo
			oGetCod := TGet():New( nLinIni+8, 005, { | u | If( PCount() == 0, cCod, cCod := u ) },_cRight1Win, 060, 010, "@!",{ || IIf(!Empty(cCod),(OM3900135_DigitacaoCodigo(),.f.),oListItens:SetFocus()) },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCod",,,,)
			nLinIni += 27
		EndIf

		oSayNf := tSay():New( nLinIni  , 005, {|| STR0084 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Nota Fiscal
		oGetNf := TGet():New( nLinIni+8, 005, { || VM0->VM0_DOC + " - " + VM0->VM0_SERIE },_cRight1Win, 060, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"cNota",,,,)
		nLinIni += 27

		If SF1->F1_TIPO <> "D"
			oSayFor := tSay():New( nLinIni  , 005, {|| STR0019 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Fornecedor
			oGetFor := TGet():New( nLinIni+8, 005, { || SA2->A2_COD + "-" + SA2->A2_LOJA + " " + Alltrim(SA2->A2_NOME)},_cRight1Win, 160, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"cFornece",,,,)
		Else
			oSayFor := tSay():New( nLinIni  , 005, {|| STR0106 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Cliente Devolução
			oGetFor := TGet():New( nLinIni+8, 005, { || SA1->A1_COD + "-" + SA1->A1_LOJA + " " + Alltrim(SA1->A1_NOME)},_cRight1Win, 160, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"cFornece",,,,)
		EndIf
		nLinIni += 27

		If lVisualiza
			oSaySta := tSay():New( nLinIni  , 005, {|| STR0107 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Status da Conferencia
			cStatConf := ""
			Do Case
				Case VM0->VM0_STATUS == "1"
					cStatConf := STR0065 // Pendente
				Case VM0->VM0_STATUS == "2"
					cStatConf := STR0108 // Parcial
				Case VM0->VM0_STATUS == "3"
					cStatConf := STR0109 // Finalizada
				Case VM0->VM0_STATUS == "4"
					cStatConf := STR0110 // Aprovada
				Case VM0->VM0_STATUS == "5"
					cStatConf := STR0111 // Reprovada
			EndCase
			oGetSta := TGet():New( nLinIni+8, 005, { || cStatConf },_cRight1Win, 060, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"cStatConf",,,,)
			nLinIni += 27
		EndIf

		cTexto := OM3900275_ObservacaoConferencia( VM0->VM0_CODIGO )

		oSayObs := tSay():New( nLinIni   , 005, {|| STR0042 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Observacao
		oGetObs := tMultiget():new( nLinIni+8, 005,{ || cTexto },_cRight1Win,160,050,,,,,,.T.,,,{|| .f. },,,.T.,,,,,.t.)
		nLinIni += 27

	oConfBarra:Activate( , , , .t. , , ,EnchoiceBar( oConfBarra, { || IIf( !lVisualiza .and. OM3900085_ConfirmarConferencia(cConferencia), oConfBarra:End() , oConfBarra:End() ) }, { || oConfBarra:End() }, ,aButtons, , , , , .F., .T. ) ) //ativa a janela criando uma enchoicebar

Return


/*/{Protheus.doc} OM390007_LevantaItens

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM390007_LevantaItens( cConferencia )

	cQuery := "SELECT VM1.VM1_COD, VM1.VM1_QTCONF, VM1.VM1_QTORIG, R_E_C_N_O_ VM1RECNO "
	cQuery += " FROM " + RetSqlName("VM1") + " VM1 "
	cQuery += " WHERE VM1.VM1_FILIAL = '" + xFilial("VM1") + "' "
	cQuery +=	" AND VM1.VM1_CODVM0 = '" + cConferencia + "' "
	cQuery +=	" AND VM1.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVM1"

	While !TMPVM1->(Eof())

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+TMPVM1->VM1_COD))

		SB5->(DbSetOrder(1))
		SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))

		Aadd(aItensNF,{ "",;
						SB1->B1_GRUPO,;
						SB1->B1_CODITE,;
						SB1->B1_DESC,;
						TMPVM1->VM1_QTCONF,;
						TMPVM1->VM1_QTORIG,;
						SB1->B1_CODBAR,;
						SB1->B1_COD,;
						FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
						VM0->VM0_TIPO,;
						TMPVM1->VM1RECNO;
					})

		OM3900175_StatusItem(aItensNF[Len(aItensNF)])

		TMPVM1->(DbSkip())

	EndDo

	TMPVM1->(dbCloseArea())

	If lMostraItem // Mostra Itens - Sim
		aItensConf := aClone(aItensNF)
	Else
		cQuery := "SELECT VM1.VM1_COD, VM1.VM1_QTCONF, VM1.VM1_QTORIG, R_E_C_N_O_ VM1RECNO "
		cQuery += " FROM " + RetSqlName("VM1") + " VM1 "
		cQuery += " WHERE VM1.VM1_FILIAL = '" + xFilial("VM1") + "' "
		cQuery +=	" AND VM1.VM1_CODVM0 = '" + cConferencia + "' "
		cQuery +=	" AND VM1.VM1_QTCONF > 0 "
		cQuery +=	" AND VM1.D_E_L_E_T_ = ' '"

		TcQuery cQuery New Alias "TMPVM1CONF"

		While !TMPVM1CONF->(Eof())

			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+TMPVM1CONF->VM1_COD))

			SB5->(DbSetOrder(1))
			SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))
			
			Aadd(aItensConf,{ "",;
							SB1->B1_GRUPO,;
							SB1->B1_CODITE,;
							SB1->B1_DESC,;
							TMPVM1CONF->VM1_QTCONF,;
							TMPVM1CONF->VM1_QTORIG,;
							SB1->B1_CODBAR,;
							SB1->B1_COD,;
							FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
							VM0->VM0_TIPO,;
							TMPVM1CONF->VM1RECNO;
						})

			OM3900175_StatusItem(aItensConf[Len(aItensConf)])

			TMPVM1CONF->(DbSkip())

		EndDo

		TMPVM1CONF->(dbCloseArea())

	EndIf

	If Len(aItensConf) == 0
		Aadd(aItensConf,{ "",;
						"",;
						"",;
						"",;
						0,;
						0,;
						"",;
						"",;
						"",;
						"",;
						0;
		})
	EndIf

Return

/*/{Protheus.doc} OM3900085_ConfirmarConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM3900085_ConfirmarConferencia(cNroConf)

	Local lRetorno := .t.
	Local lAprovador := OM3900141_UsuarioAprovador()

	if lAprovador

		lRetorno := OM3900205_JaneladeAprovacao()

	Else
		If MsgNoYes(STR0085,STR0009) // Finaliza Conferencia? / Atencao

			VM0->(DbSeek(xfilial("VM0") + cNroConf ) )

			OM3900265_LimpaItensZerados( VM0->VM0_CODIGO )
			OM3900311_GravaConferenciaZerada( VM0->VM0_CODIGO )
			OM3900235_VerificaDivergencias( VM0->VM0_CODIGO )

			If lUtilAprova .or. VM0->VM0_DIVERG == "0"
				OM3900115_StatusConferencia( VM0->VM0_CODIGO , "3" )
			Else
				MsgStop(STR0086,STR0009) // Há itens com divergencia. Impossivel continuar. / Atencao
				lRetorno := .f.
			EndIf

			If VM0->VM0_DIVERG == "0" // NAO TEM DIVERGENCIA
				OM3900215_GravaObservacaoConferencia(STR0112+" "+Transform(dDataBase,"@D")+" "+left(time(),5)+" "+__CUSERID+"-"+left(Alltrim(UsrRetName(__CUSERID)),15)) // Aprovado automaticamente
				OM3900225_GravaConbar(VM0->VM0_DOC,VM0->VM0_SERIE,VM0->VM0_FORNEC,VM0->VM0_LOJA)
				OM3900115_StatusConferencia( VM0->VM0_CODIGO , "4" )
				If ExistFunc("OA3600011_Tempo_Total_Conferencia_NF_Entrada")
					OA3600011_Tempo_Total_Conferencia_NF_Entrada( 0 , VM0->VM0_DOC , VM0->VM0_SERIE , VM0->VM0_FORNEC , VM0->VM0_LOJA ) // 0=Finalizar o Tempo Total da Conferencia de NF Entrada
				EndIf
				OM3900301_ChamaPEaposAprovReprov( "1" )
			Else // VM0->VM0_DIVERG == "1" // POSSUI DIVERGENCIA
				cEmailDiv := OM3900245_CorpoEmail( VM0->VM0_CODIGO )
				If !Empty(cEmailDiv)
					cNota := VM0->VM0_DOC + VM0->VM0_SERIE
					cFornece := VM0->VM0_FORNEC + VM0->VM0_LOJA
					SF1->(DbSetOrder(1))
					SF1->(DbSeek(xFilial("SF1")+cNota+cFornece))
					If SF1->F1_TIPO <> "D"
						SA2->(DbSetOrder(1))
						SA2->(DbSeek(xFilial("SA2")+cFornece))
						cNomeFornece := Left(SA2->A2_NOME,40)						
					Else
						SA1->(DbSetOrder(1))
						SA1->(DbSeek(xFilial("SA1")+cFornece))
						cNomeFornece := Left(SA1->A1_NOME,40)
					EndIf
					OM3900021_EMAIL( cEmailDiv , cNota , cFornece +"-"+ cNomeFornece , "0" )
				EndIf
			EndIf

		EndIf
	EndIf

Return lRetorno

/*/{Protheus.doc} OM3900095_GravaRegistroConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM3900095_GravaRegistroConferencia( aNotaFiscal, cTpOrigem )

	Local oModelVM0 := FWLoadModel( 'OFIA190' )
	Local lRetVM0	:= .f.
	Local cNroConf	:= ""

	Default aNotaFiscal := Array(4)
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	oModelVM0:SetOperation( MODEL_OPERATION_INSERT )

	lRetVM0 := oModelVM0:Activate()

	if lRetVM0

		oModelVM0:SetValue( "VM0MASTER", "VM0_TIPO", "1" )
		oModelVM0:SetValue( "VM0MASTER", "VM0_DOC", aNotaFiscal[1] )
		oModelVM0:SetValue( "VM0MASTER", "VM0_SERIE", aNotaFiscal[2] )
		oModelVM0:SetValue( "VM0MASTER", "VM0_FORNEC", aNotaFiscal[3] )
		oModelVM0:SetValue( "VM0MASTER", "VM0_LOJA", aNotaFiscal[4] )
		oModelVM0:SetValue( "VM0MASTER", "VM0_STATUS", "1" )

		oModelDet := oModelVM0:GetModel("VM1DETAIL")

		cQuery := "SELECT SD1.D1_COD, SB2.B2_CM1, MIN(SD1.D1_ITEM) AS ITEM, SUM(SD1.D1_QUANT) AS QTDE "
		cQuery += "  FROM " + RetSqlName("SD1") + " SD1 "
		cQuery += "  JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "    ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery += "   AND SB1.B1_COD = SD1.D1_COD"
		cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
		cQuery += "  LEFT JOIN " + RetSqlName("SB2") + " SB2 "
		cQuery += "    ON SB2.B2_FILIAL = '" + xFilial("SB2") + "'"
		cQuery += "   AND SB2.B2_COD = SD1.D1_COD"
		cQuery += "   AND SB2.B2_LOCAL = SB1.B1_LOCPAD"
		cQuery += "   AND SB2.D_E_L_E_T_ = ' '"
		cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "'"
		cQuery += "   AND SD1.D1_DOC = '" + aNotaFiscal[1] + "' "
		cQuery += "   AND SD1.D1_SERIE = '" + aNotaFiscal[2] + "' "
		cQuery += "   AND SD1.D1_FORNECE = '" + aNotaFiscal[3] + "' "
		cQuery += "   AND SD1.D1_LOJA = '" + aNotaFiscal[4] + "' "
		cQuery += "   AND SD1.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY SD1.D1_COD, SB2.B2_CM1"

		TcQuery cQuery New Alias "TMPSD1"

		While !TMPSD1->(Eof())

			oModelDet:AddLine()

			oModelDet:SetValue( "VM1_CODVM0", oModelVM0:GetValue( "VM0MASTER", "VM0_CODIGO") )
			oModelDet:SetValue( "VM1_SEQUEN", Alltrim(TMPSD1->ITEM) )
			oModelDet:SetValue( "VM1_COD"	, TMPSD1->D1_COD )
			oModelDet:SetValue( "VM1_CUSPRO", TMPSD1->B2_CM1 )
			oModelDet:SetValue( "VM1_QTORIG", int(TMPSD1->QTDE) )

			TMPSD1->(DbSkip())
		EndDo

		TMPSD1->(dbCloseArea())

		If ( lRet := oModelVM0:VldData() )

			if ( lRet := oModelVM0:CommitData())
			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0087,"COMMITVM0") // Não foi possivel incluir o(s) registro(s)
				Else
					Help("",1,"COMMITVM0",,STR0087,1,0) // Não foi possivel incluir o(s) registro(s)
				EndIf
			EndIf

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0088,"VALIDVM0") // Problema na validação dos campos e não foi possivel concluir o relacionamento
			Else
				Help("",1,"VALIDVM0",,STR0088,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
			EndIf
		EndIf

		cNroConf := oModelVM0:GetValue("VM0MASTER","VM0_CODIGO")

		oModelVM0:DeActivate()

	Else
		If cTpOrigem == "2" // 2=Coletor de Dados
			VTAlert(STR0089,"ACTIVEVM0") // Não foi possivel ativar o modelo de inclusão da tabela VM0
		Else
			Help("",1,"ACTIVEVM0",,STR0089,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM0
		EndIf
	EndIf

	FreeObj(oModelVM0)

Return cNroConf

/*/{Protheus.doc} OM3900105_DuplicaConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM3900105_DuplicaConferencia( cConferencia, lComDiverg )

	Local lRetVM0	:= .f.
	Local aNotaFiscal:= {}
	Local cNovaConf := ""
	Local oModelVM0 := FWLoadModel( 'OFIA190' )
	Local lAlterou  := .f.

	Default cConferencia := ""
	Default lComDiverg	:= .f.

	If VM0->( DbSeek( xFilial("VM0") + cConferencia ) )

		aNotaFiscal := {VM0->VM0_DOC,VM0->VM0_SERIE,VM0->VM0_FORNEC,VM0->VM0_LOJA}

		cNovaConf := OM3900095_GravaRegistroConferencia( aNotaFiscal )

	EndIf

	If lComDiverg

		If VM0->( DbSeek( xFilial("VM0") + cNovaConf ) )

			oModelVM0:SetOperation( MODEL_OPERATION_UPDATE )

			lRetVM0 := oModelVM0:Activate()

			if lRetVM0
				
				oModelDet := oModelVM0:GetModel("VM1DETAIL")

				cQuery := "SELECT VM1.VM1_COD    , "
				cQuery += "       VM1.VM1_SEQUEN , "
				cQuery += "       VM1.VM1_QTCONF , "
				cQuery += "       VM1.VM1_DATINI , "
				cQuery += "       VM1.VM1_HORINI , "
				cQuery += "       VM1.VM1_DATFIN , "
				cQuery += "       VM1.VM1_HORFIN , "
				cQuery += "       VM1.VM1_USRCON   "
				cQuery += "  FROM " + RetSqlName("VM1") + " VM1 "
				cQuery += " WHERE VM1.VM1_FILIAL = '" + xFilial("VM1") + "' "
				cQuery += "   AND VM1.VM1_CODVM0 = '" + cConferencia + "' "
				cQuery += "   AND VM1.VM1_QTORIG = VM1.VM1_QTCONF "
				cQuery += "   AND VM1.D_E_L_E_T_ = ' ' "

				TcQuery cQuery New Alias "TMPVM1"

				While !TMPVM1->(Eof())

					lSeek := oModelDet:SeekLine({;
										{ "VM1_COD"		, TMPVM1->VM1_COD },;
										{ "VM1_SEQUEN"	, TMPVM1->VM1_SEQUEN };
									})

					If lSeek
						lAlterou := .t.
						oModelDet:SetValue( "VM1_QTCONF", TMPVM1->VM1_QTCONF )
						oModelDet:SetValue( "VM1_DATINI", stod(TMPVM1->VM1_DATINI) )
						oModelDet:SetValue( "VM1_HORINI", TMPVM1->VM1_HORINI )
						oModelDet:SetValue( "VM1_DATFIN", stod(TMPVM1->VM1_DATFIN) )
						oModelDet:SetValue( "VM1_HORFIN", TMPVM1->VM1_HORFIN )
						oModelDet:SetValue( "VM1_USRCON", TMPVM1->VM1_USRCON )
					EndIf

					TMPVM1->(DbSkip())

				EndDo

				TMPVM1->(dbCloseArea())

				If lAlterou
					If ( lRet := oModelVM0:VldData() )

						if ( lRet := oModelVM0:CommitData())
						Else
							Help("",1,"COMMITVM0",,STR0087+" "+oModelVM0:GetErrorMessage()[6],1,0) // Não foi possivel incluir o(s) registro(s)
						EndIf

					Else
						Help("",1,"COMMITVM0",,STR0087,1,0) // Não foi possivel incluir o(s) registro(s)
					EndIf

				Else
					Help("",1,"VALIDVM0",,STR0088,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
				EndIf

				oModelVM0:DeActivate()

			Else
				Help("",1,"ACTIVEVM0",,STR0089,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM0
			EndIf

		EndIf

	EndIf

	FreeObj(oModelVM0)

	If lAlterou
		OM3900115_StatusConferencia( cNovaConf , "2" ) // Grava o STATUS Parcial na Tabela de Historico
	EndIf

Return

/*/{Protheus.doc} OM3900115_StatusConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM3900115_StatusConferencia( cConferencia , cStatus, cTpOrigem )

	Local oModelVM0 := FWLoadModel( 'OFIA190' )
	Local lRetVM0	:= .f.
	Local cStatusRet:= ""
	Local lMudouStatus := .f.

	Default cConferencia := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	If VM0->( DbSeek( xFilial("VM0") + cConferencia ) )

		oModelVM0:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM0 := oModelVM0:Activate()

		if lRetVM0

			if cStatus <> oModelVM0:GetValue("VM0MASTER","VM0_STATUS")
				oModelVM0:SetValue( "VM0MASTER", "VM0_STATUS", cStatus )

				If oModelVM0:VldData()

					if oModelVM0:CommitData()
						lMudouStatus := .t.
					Else
						If cTpOrigem == "2" // 2=Coletor de Dados
							VTAlert(STR0090,"COMMITVM0") // Não foi possivel gravar o(s) registro(s)
						Else
							Help("",1,"COMMITVM0",,STR0090,1,0) // Não foi possivel gravar o(s) registro(s)
						EndIf
					EndIf

				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0088,"VALIDVM0") // Problema na validação dos campos e não foi possivel concluir o relacionamento
					Else
						Help("",1,"VALIDVM0",,STR0088,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
					EndIf
				EndIf

				cStatusRet := oModelVM0:GetValue("VM0MASTER","VM0_STATUS")

				oModelVM0:DeActivate()
			Else
				cStatusRet := oModelVM0:GetValue("VM0MASTER","VM0_STATUS")
			EndIf
		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0089,"ACTIVEVM0") // Não foi possivel ativar o modelo de inclusão da tabela VM0
			Else
				Help("",1,"ACTIVEVM0",,STR0089,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM0
			EndIf
		EndIf

	EndIf

	FreeObj(oModelVM0)

	If lMudouStatus
		If ExistBlock("OM390STA")
			ExecBlock("OM390STA",.f.,.f.,{ cConferencia , cStatus, cTpOrigem })
		EndIf
	EndIf

Return cStatusRet

/*/{Protheus.doc} OM3900125_ExisteConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM3900125_ExisteConferencia(aNotaFiscal, lSoValidos, cDesprConf )

	Local cQuery := ""
	Local cRetorno := ""

	Default lSoValidos := .f.
	Default aNotaFiscal := Array(4)
	Default cDesprConf := ""

	cQuery := "SELECT VM0.VM0_CODIGO "
	cQuery += " FROM " + RetSqlName("VM0") + " VM0 "
	cQuery += " WHERE VM0.VM0_FILIAL = '" + xFilial("VM0") + "'"
	cQuery +=	" AND VM0.VM0_DOC = '" + aNotaFiscal[1] + "'"
	cQuery +=	" AND VM0.VM0_SERIE = '" + aNotaFiscal[2] + "'"
	cQuery +=	" AND VM0.VM0_FORNEC = '" + aNotaFiscal[3] + "'"
	cQuery +=	" AND VM0.VM0_LOJA = '" + aNotaFiscal[4] + "'"
	
	if !Empty(cDesprConf)
		cQuery +=	" AND VM0.VM0_CODIGO <> '" + cDesprConf + "'" // Despresa conferencia
	EndIf

	If lSoValidos
		cQuery +=	" AND VM0.VM0_STATUS IN ('1','2','3','4')"
	EndIf

	cQuery +=	" AND VM0.D_E_L_E_T_ = ' '"
	cQuery +=" ORDER BY VM0_CODIGO DESC"

	TcQuery cQuery New Alias "TMPVM0"

	If !TMPVM0->(Eof())
		cRetorno := TMPVM0->VM0_CODIGO
	EndIf

	TMPVM0->(dbCloseArea())

Return cRetorno

/*/{Protheus.doc} OM3900135_DigitacaoCodigo

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM3900135_DigitacaoCodigo()

	Local lCodBarra := .f.
	Local aProduto  := {}
	Local oPeca     := DMS_Peca():New()

	Private cCodSB1   := ""

	If !Empty(cCod)

		aProduto := oPeca:LeCodBarras(cCod) // Leitura do Codigo de Barras
		lCodBarra := Len(aProduto) > 0 .and. !Empty(aProduto[1])
		
		If lCodBarra
			cCodSB1 := aProduto[1]
			IF nQtd > 0 .and. !lMostraQtd
				If lNFTransf // Se for NF de Transferencia
					nQtd := 1 // Somar Qtde 1 nos Bips
				Else
					nQtd := aProduto[2]
					If nQtd == 0 // Qtde por Embalagem Zerada
						nQtd := 1 // Somar Qtde 1 nos Bips
					EndIf
				EndIf
			EndIf
		Else
			cCodSB1 := PadR(cCod, GetSX3Cache("B1_COD","X3_TAMANHO"))
		EndIf

		If FG_POSSB1("cCodSB1","SB1->B1_COD","")

			nPosItem := OM3900145_BuscaItem(cCodSB1)

			If nPosItem > 0
				oListItens:SetArray(aItensConf)
				oListItens:nAt := nPosItem

				OM3900185_QtdConferida(aItensConf[nPosItem],nQtd)

				nQtd:= 1
				cCod:= space(50)

				If lMostraQtd
					oGetQtd:Refresh()
				EndIf
				If lMostraCod
					oGetCod:Refresh()
				EndIf
				oListItens:SetFocus()
				oListItens:Refresh()

			EndIf
		Else
			MsgStop(STR0091,STR0009) // Item não existente no Cadastro de Produtos. / Atencao
		EndIf

	EndIf

	FreeObj(oPeca)

Return

/*/{Protheus.doc} OM3900145_BuscaItem

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM3900145_BuscaItem(cCodigo)

	Local nPosicao := 0
	Local cMIL0139 := GetNewPar("MV_MIL0139","0")

	Default cCodigo:= ""

	If !Empty(cCodigo)

		nPosicao := aScan(aItensConf,{|x| Alltrim(x[8]) == Alltrim(cCodigo) }) // CODIGO ( B1_COD )
		If nPosicao == 0
			nPosicao := aScan(aItensNF,{|x| Alltrim(x[8]) == Alltrim(cCodigo) }) // CODIGO ( B1_COD )
			If nPosicao == 0
				If ( cMIL0139 == "2" .or. ;
					( cMIL0139 == "1" .and. MsgYesNo(STR0092+" "+STR0093,STR0009) ) ) // Item não encontrado nesta nota fiscal de entrada. / Deseja incluir? / Atencao
					nPosicao := OM3900165_AdcionaItemNotaFiscal()
				ElseIf ( cMIL0139 == "0" )
					MsgStop(STR0092,STR0009) // Item não encontrado nesta nota fiscal de entrada. / Atencao
				EndIf
			Else
				nPosicao := OM3900155_AdicionaItemLista(nPosicao)
			EndIf
		EndIf

	EndIf

Return nPosicao


/*/{Protheus.doc} OM3900155_AdicionaItemLista

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static function OM3900155_AdicionaItemLista(nPosNF)

	Local nPosItem := 0

	Default nPosNF := 0

	//É necessario que esteja posicionado no SB1

	SB5->(DbSetOrder(1))
	SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))

	If nPosNF == 0
		Aadd(aItensConf,{	RGB(30,144,255),;
							SB1->B1_GRUPO,;
							SB1->B1_CODITE,;
							SB1->B1_DESC,;
							0,;
							0,;
							SB1->B1_CODBAR,;
							SB1->B1_COD,;
							FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
							VM0->VM0_TIPO,;
							0;
						})
	Else
		Aadd(aItensConf,aItensNF[nPosNF])
	EndIf

	nPosItem := Len(aItensConf)

Return nPosItem

/*/{Protheus.doc} OM3900165_AdcionaItemNotaFiscal

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM3900165_AdcionaItemNotaFiscal(cCodigo)

	Local nPosItem := 0

	SB5->(DbSetOrder(1))
	SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))

	nRecVM1 := OM3900195_AdcionaRegistroVM1( Len(aItensNF)+ 1 )

	Aadd(aItensNF,{	RGB(30,144,255),;
					SB1->B1_GRUPO,;
					SB1->B1_CODITE,;
					SB1->B1_DESC,;
					0,;
					0,;
					SB1->B1_CODBAR,;
					SB1->B1_COD,;
					FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
					VM0->VM0_TIPO,;
					nRecVM1;
				})

	nPosItem := Len(aItensNF)

	nPosItem := OM3900155_AdicionaItemLista(nPosItem)

Return nPosItem

/*/{Protheus.doc} OM3900175_StatusItem

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM3900175_StatusItem(aVetItem)

	//aVetItem[1] - Cor da linha
	//aVetItem[5] - VM1_QTCONF
	//aVetItem[6] - VM1_QTORIG

	Do Case
		Case aVetItem[6] == 0 // Item nao existia na NF
			aVetItem[1] := RGB(30,144,255)
		Case aVetItem[5] == 0 // Item nao conferido
			aVetItem[1] := RGB(255,215,0)
		Case aVetItem[5] == aVetItem[6] // Quantidade conferida 
			aVetItem[1] := RGB(80,200,0)
		Case aVetItem[5] <> aVetItem[6] // Divergencia na conferencia 
			aVetItem[1] := RGB(255,99,71)
		OtherWise
			aVetItem[1] := RGB(30,144,255)
	EndCase

Return

/*/{Protheus.doc} OM3900185_QtdConferida

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM3900185_QtdConferida(aItemConf,nQtdConf,lDigitado)

	Default lDigitado := .f.

	nPosNF := aScan(aItensNF,{ |x| x[11] == aItemConf[11] } )
	If nPosNF > 0
		If nQtdConf < 0
			nQtdConf := 0
		EndIf
		If nQtdConf == 0 .or. lDigitado
			aItemConf[5] := nQtdConf
		Else
			aItemConf[5] += nQtdConf
		EndIf
		aItensNF[nPosNF,5] := aItemConf[5]
		OM3900285_GravaQtdConferida( aItemConf[11] , aItemConf[5] )
		OM3900175_StatusItem(aItemConf)
		OM3900115_StatusConferencia( VM0->VM0_CODIGO , "2" )
	EndIf

Return .t.


/*/{Protheus.doc} OM3900195_AdcionaRegistroVM1

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM3900195_AdcionaRegistroVM1( nSequen, cTpOrigem )

	Local oModelVM0 := FWLoadModel( 'OFIA190' )
	Local cRecVM1 := 0
	Local cSequen := ""
	Local lSeek := .f.
	
	Default nSequen := 1
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	oModelVM0:SetOperation( MODEL_OPERATION_UPDATE )
	lRetVM0 := oModelVM0:Activate()

	if lRetVM0

		cSequen := StrZero( nSequen ,GetSX3Cache("VM1_SEQUEN","X3_TAMANHO") )

		SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))

		oModelDet := oModelVM0:GetModel("VM1DETAIL")
		
		oModelDet:AddLine()

		oModelDet:SetValue( "VM1_CODVM0", VM0->VM0_CODIGO )
		oModelDet:SetValue( "VM1_SEQUEN", cSequen )
		oModelDet:SetValue( "VM1_COD"	, SB1->B1_COD )
		oModelDet:SetValue( "VM1_CUSPRO", SB2->B2_CM1 )
		oModelDet:SetValue( "VM1_QTORIG", 0 )

		If ( lRet := oModelVM0:VldData() )

			if ( lRet := oModelVM0:CommitData())
			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0087,"COMMITVM0") // Não foi possivel incluir o(s) registro(s)
				Else
					Help("",1,"COMMITVM0",,STR0087,1,0) // Não foi possivel incluir o(s) registro(s)
				Endif
			EndIf

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0088,"VALIDVM0") // Problema na validação dos campos e não foi possivel concluir o relacionamento
			Else
				Help("",1,"VALIDVM0",,STR0088,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
			Endif
		EndIf
		oModelVM0:DeActivate()

		oModelVM0:Activate()
		oModelDet := oModelVM0:GetModel("VM1DETAIL")
		lSeek := oModelDet:SeekLine({;
								{ "VM1_CODVQ0"	, VM0->VM0_CODIGO },;
								{ "VM1_SEQUEN"	, cSequen };
							})

		If lSeek
			cRecVM1 := oModelDet:GETDATAID()
		EndIf

		oModelVM0:DeActivate()

	Else
		If cTpOrigem == "2" // 2=Coletor de Dados
			VTAlert(STR0089,"ACTIVEVM0") // Não foi possivel ativar o modelo de inclusão da tabela VM0
		Else
			Help("",1,"ACTIVEVM0",,STR0089,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM0
		Endif
	EndIf

	FreeObj(oModelVM0)

Return cRecVM1

/*/{Protheus.doc} OM3900205_JaneladeAprovacao

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM3900205_JaneladeAprovacao()

Local cMemoObs   := ""
Local nOpcao     := 0
Local lRetorno   := .t.
Local lTemDiverg := VM0->VM0_DIVERG == "1"
Local cAprRepr   := "0"

oDlgOpcoes := MSDialog():New( 0, 0, 230, 620, STR0056, , , , , , , , , .T., , , , .F. ) // Conferência Nota Fiscal de Entrada

If lTemDiverg
	oBotaoApr := tButton():New(10,200,STR0095,oDlgOpcoes, { || nOpcao := 1 , oDlgOpcoes:End() } , 100 , 20 ,,,,.T.,,,,{ || .t. }) // Aprovar Conferência com Divergencias
	oBotaoRjD := tButton():New(10,010,STR0096,oDlgOpcoes, { || nOpcao := 2 , oDlgOpcoes:End() } ,  90 , 20 ,,,,.T.,,,,{ || .t. }) // Re-Conferir Itens Divergentes
	oBotaoRjT := tButton():New(10,105,STR0097,oDlgOpcoes, { || nOpcao := 3 , oDlgOpcoes:End() } ,  90 , 20 ,,,,.T.,,,,{ || .t. }) // Re-Conferir Todos Itens
Else
	oBotaoApr := tButton():New(10,010,STR0094,oDlgOpcoes, { || nOpcao := 1 , oDlgOpcoes:End() } , 290 , 20 ,,,,.T.,,,,{ || .t. }) // Aprovar Conferência
EndIf
oGetObs := tMultiget():new( 050, 015,{ | u | if( pCount() > 0, cMemoObs := u, cMemoObs ) },oDlgOpcoes,280,050,,,,,,.T.,,,,,,.F.,,,,,.t.,STR0042,1) // Observacao

oDlgOpcoes:Activate( , , , .t. , , , , ,, , , , , , ) //ativa a janela criando uma enchoicebar

If !Empty(cMemoObs)
	cMemoObs := Alltrim(cMemoObs)+" - "+Transform(dDataBase,"@D")+" "+left(time(),5)+" "+__CUSERID+"-"+left(Alltrim(UsrRetName(__CUSERID)),15)
EndIf

Do Case 
	Case nOpcao == 1
		OM3900215_GravaObservacaoConferencia(cMemoObs)
		OM3900115_StatusConferencia( VM0->VM0_CODIGO , "4" )
		If ExistFunc("OA3600011_Tempo_Total_Conferencia_NF_Entrada")
			OA3600011_Tempo_Total_Conferencia_NF_Entrada( 0 , VM0->VM0_DOC , VM0->VM0_SERIE , VM0->VM0_FORNEC , VM0->VM0_LOJA ) // 0=Finalizar o Tempo Total da Conferencia de NF Entrada
		EndIf
		cAprRepr := "1"
	Case nOpcao == 2
		OM3900215_GravaObservacaoConferencia(cMemoObs)
		OM3900115_StatusConferencia( VM0->VM0_CODIGO , "5" )
		OM3900105_DuplicaConferencia( VM0->VM0_CODIGO , .t. )
		cAprRepr := "2"
	Case nOpcao == 3
		OM3900215_GravaObservacaoConferencia(cMemoObs)
		OM3900115_StatusConferencia( VM0->VM0_CODIGO , "5" )
		OM3900105_DuplicaConferencia( VM0->VM0_CODIGO )
		cAprRepr := "2"
	Otherwise
		lRetorno := .f.
EndCase

If cAprRepr <> "0"
	OM3900301_ChamaPEaposAprovReprov( cAprRepr )
EndIf

Return lRetorno


/*/{Protheus.doc} OM3900215_GravaObservacaoConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM3900215_GravaObservacaoConferencia(cObserv, cTpOrigem)

	Local oModelVM0 := FWLoadModel( 'OFIA190' )
	Local lRetVM0	:= .f.

	Default cObserv := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	oModelVM0:SetOperation( MODEL_OPERATION_UPDATE )

	lRetVM0 := oModelVM0:Activate()

	if lRetVM0

		oModelVM0:SetValue( "VM0MASTER", "VM0_OBSERV", cObserv )

		If ( lRet := oModelVM0:VldData() )

			if ( lRet := oModelVM0:CommitData())
			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0090,"COMMITVM0") // Não foi possivel gravar o(s) registro(s)
				Else
					Help("",1,"COMMITVM0",,STR0090,1,0) // Não foi possivel gravar o(s) registro(s)
				EndIf
			EndIf

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0088,"VALIDVM0") // Problema na validação dos campos e não foi possivel concluir o relacionamento
			Else
				Help("",1,"VALIDVM0",,STR0088,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
			EndIf
		EndIf

		oModelVM0:DeActivate()

	Else
		If cTpOrigem == "2" // 2=Coletor de Dados
			VTAlert(STR0089,"ACTIVEVM0") // Não foi possivel ativar o modelo de inclusão da tabela VM0
		Else
			Help("",1,"ACTIVEVM0",,STR0089,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM0
		EndIf
	EndIf

	FreeObj(oModelVM0)

Return

/*/{Protheus.doc} OM3900225_GravaConbar

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM3900225_GravaConbar(cNota, cSerie, cForn, cLoja)

	DbSelectArea("SD1")
	cQuery := "SELECT SD1.R_E_C_N_O_ AS SD1REC "
	cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
	cQuery += 	" AND SD1.D1_DOC = '" + cNota + "'"
	cQuery += 	" AND SD1.D1_SERIE = '" + cSerie + "'"
	cQuery += 	" AND SD1.D1_FORNECE = '" + cForn + "'"
	cQuery += 	" AND SD1.D1_LOJA = '" + cLoja + "'"
	cQuery += 	" AND SD1.D_E_L_E_T_ = ' '"
	TcQuery cQuery New Alias "TMPSD1"
	While !TMPSD1->(Eof())
		SD1->(DbGoTo(TMPSD1->SD1REC))
		RecLock("SD1",.f.)
			SD1->D1_CONBAR := '1'
		MsUnlock()
		TMPSD1->(DbSkip())
	EndDo
	TMPSD1->(dbCloseArea())

Return

/*/{Protheus.doc} OM3900235_VerificaDivergencias

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM3900235_VerificaDivergencias(cConferencia , cTpOrigem)

	Local cQuery := ""
	Local oModelVM0 := FWLoadModel( 'OFIA190' )
	Local lRetVM0	:= .f.

	Default cConferencia := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	cQuery := "SELECT COUNT(VM1.VM1_SEQUEN) AS QTDE "
	cQuery += "  FROM " + RetSqlName("VM1") + " VM1 "
	cQuery += " WHERE VM1.VM1_FILIAL = '" + xFilial("VM1") + "'"
	cQuery += "   AND VM1.VM1_CODVM0 = '" + cConferencia + "' "
	cQuery += "   AND VM1.VM1_QTORIG <> VM1.VM1_QTCONF "
	cQuery += "   AND VM1.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPVM1"

	If !TMPVM1->(Eof())

		VM0->(DbSeek(xFilial("VM0") + cConferencia))

		oModelVM0:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM0 := oModelVM0:Activate()

		if lRetVM0

			If TMPVM1->(QTDE) > 0
				oModelVM0:SetValue( "VM0MASTER", "VM0_DIVERG", "1" ) // Com Divergencia
			Else
				oModelVM0:SetValue( "VM0MASTER", "VM0_DIVERG", "0" ) // Sem Divergencia
			EndIf

			If ( lRet := oModelVM0:VldData() )

				if ( lRet := oModelVM0:CommitData())
				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0090,"COMMITVM0") // Não foi possivel gravar o(s) registro(s)
					Else
						Help("",1,"COMMITVM0",,STR0090,1,0) // Não foi possivel gravar o(s) registro(s)
					EndIf
				EndIf

			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0088,"VALIDVM0") // Problema na validação dos campos e não foi possivel concluir o relacionamento
				Else
					Help("",1,"VALIDVM0",,STR0088,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
				EndIf
			EndIf

			oModelVM0:DeActivate()

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0089,"ACTIVEVM0") // Não foi possivel ativar o modelo de inclusão da tabela VM0
			Else
				Help("",1,"ACTIVEVM0",,STR0089,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM0
			EndIf
		EndIf

	EndIf

	TMPVM1->(dbCloseArea())

	FreeObj(oModelVM0)

Return

/*/{Protheus.doc} OM3900245_CorpoEmail

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static function OM3900245_CorpoEmail( cConferencia )

	Local cQuery := ""
	Local cCorpoEmail := ""

	Default cConferencia := ""

	cQuery := "SELECT VM1.VM1_COD , VM1.VM1_QTCONF , VM1.VM1_QTORIG , VM1.VM1_USRCON , VAI.VAI_NOMTEC "
	cQuery += " FROM " + RetSqlName("VM1") + " VM1 "
	cQuery += " JOIN " + RetSqlName("VAI") + " VAI ON ( VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODUSR=VM1.VM1_USRCON AND VAI.D_E_L_E_T_=' ' ) "
	cQuery += " WHERE VM1.VM1_FILIAL = '" + xFilial("VM1") + "' "
	cQuery += 	" AND VM1.VM1_CODVM0 = '" + cConferencia + "' "
	cQuery += 	" AND VM1.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVM1"

	While !TMPVM1->(Eof())

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+TMPVM1->VM1_COD))

		cCorpoEmail += "<tr>"
		cCorpoEmail += "<td width=25%><font size=2 face='verdana,arial' Color=#0000cc>"+SB1->B1_GRUPO+" "+SB1->B1_CODITE+"</font></td>"
		cCorpoEmail += "<td width=40%><font size=2 face='verdana,arial' Color=#0000cc>"+SB1->B1_DESC+"</font></td>"
		cCorpoEmail += "<td width=35%><font size=2 face='verdana,arial' Color="
		If TMPVM1->VM1_QTCONF <> TMPVM1->VM1_QTORIG
			If TMPVM1->VM1_QTORIG == 0
				cCorpoEmail += "red>"+STR0033 // Item não existente na NF
			Else
				cCorpoEmail += "red>"+STR0035 // Item com divergencia
				cCorpoEmail += " "+STR0054+" "+Alltrim(Transform(TMPVM1->VM1_QTORIG,VM1->(X3PICTURE("VM1_QTORIG")))) // Qtd.NF:
				cCorpoEmail += " - "+STR0055+" "+Alltrim(Transform(TMPVM1->VM1_QTCONF,VM1->(X3PICTURE("VM1_QTCONF")))) // Qtd.Conf.:
			EndIf
		Else
			cCorpoEmail += "#0000cc>"+STR0041 // OK
		EndIf
		cCorpoEmail += " - "+TMPVM1->VM1_USRCON+" "+Alltrim(TMPVM1->VAI_NOMTEC)
		cCorpoEmail += " </font></td>"
		cCorpoEmail += "</tr>"

		TMPVM1->(DbSkip())

	EndDo
	TMPVM1->(dbCloseArea())

Return cCorpoEmail


/*/{Protheus.doc} OM3900255_FiltraNotaFiscal

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM3900255_FiltraNotaFiscal()

	Local aParamBox := {}
	Local aRetParam := {}

	SetKey(VK_F12,Nil)

	aAdd(aParamBox,{1,STR0098,nFiltDia,"@E 9999","",""   ,"",50,.F.}) // Dias a Retroagir
	aAdd(aParamBox,{1,STR0019,cFiltFor,"@!"     ,"","SA2","",50,.F.}) // Fornecedor
	aAdd(aParamBox,{1,STR0099,cFiltLoj,"@!"     ,"",""   ,"",25,.F.}) // Loja

	If ParamBox(aParamBox,"",@aRetParam,,,,,,,,.f.)
		
		nFiltDia := aRetParam[1]
		cFiltFor := aRetParam[2]
		cFiltLoj := aRetParam[3]
		
		oBrwSF1:DeleteFilter("data")
		oBrwSF1:DeleteFilter("fornece")
		If !Empty(aRetParam[1])
			oBrwSF1:AddFilter( STR0100 , "@ F1_DTDIGIT >='" + DtoS(dDatabase - aRetParam[1]) + "'",.t.,.t.,,,,"data") // Data da NF
		EndIf
		If !Empty(aRetParam[2]) .and. !Empty(aRetParam[3])
			oBrwSF1:AddFilter( STR0019+"/"+STR0099 ,"@ F1_FORNECE='" + aRetParam[2] + "' AND F1_LOJA='" + aRetParam[3] + "'",.t.,.t.,,,,"fornece") // Fornecedor/Loja
		ElseIf !Empty(aRetParam[2])
			oBrwSF1:AddFilter( STR0019 ,"@ F1_FORNECE='" + aRetParam[2] + "'",.t.,.t.,,,,"fornece") // Fornecedor
		ElseIf !Empty(aRetParam[3])
			oBrwSF1:AddFilter( STR0099 ,"@ F1_LOJA='" + aRetParam[3] + "'",.t.,.t.,,,,"fornece") // Loja
		EndIf
		oBrwSF1:ExecuteFilter(.t.)
	EndIf

	SetKey(VK_F12,{ || OM3900255_FiltraNotaFiscal() })

Return

/*/{Protheus.doc} OM3900265_LimpaItensZerados
Limpa Itens Zerados ( VM1_QTCONF = 0 ) que foram incluidos manualmente ( VM1_QTORIG = 0 )

@author Andre Luis Almeida
@since 20/12/2016
@version undefined
@param cEmailDiv, caracter, Itens com Divergencia
@param cNrNF, caracter, Nro da NF
@param cForn, caracter, Fornecedor
@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

@type function
/*/
Function OM3900265_LimpaItensZerados( cConferencia, cTpOrigem )

	Local cQuery      := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	If cTpOrigem == "0" .or. cTpOrigem == "1" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) )
		OM3900295_LimpaLinhaBranca()
	EndIf

	VM0->(DbSeek(xFilial("VM0") + cConferencia))

	cQuery := "SELECT VM1.R_E_C_N_O_ AS VM1RECNO "
	cQuery += " FROM " + RetSqlName("VM1") + " VM1 "
	cQuery += " WHERE VM1.VM1_FILIAL = '" + xFilial("VM1") + "'"
	cQuery += 	" AND VM1.VM1_CODVM0 = '" + cConferencia + "' "
	cQuery += 	" AND VM1.VM1_QTORIG = 0 "
	cQuery += 	" AND VM1.VM1_QTCONF = 0 "
	cQuery += 	" AND VM1.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPVM1"

	While !TMPVM1->(Eof())

		VM1->(DbGoTo(TMPVM1->VM1RECNO))

		RecLock("VM1",.F.,.T.)
		DbDelete()
		MsUnlock()
		
		TMPVM1->(DbSkip())

	EndDo
	TMPVM1->(dbCloseArea())
	DbSelectArea("VM0")

Return


/*/{Protheus.doc} OM3900275_ObservacaoConferencia
Enviar EMAIL quando ha divergencia na Conferencia - funcao chamada pelo OFIOM390 e pelo Coletor de Dados

@author Andre Luis Almeida
@since 20/12/2016
@version undefined
@param cEmailDiv, caracter, Itens com Divergencia
@param cNrNF, caracter, Nro da NF
@param cForn, caracter, Fornecedor
@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

@type function
/*/
Function OM3900275_ObservacaoConferencia( cConferencia )
	
	Local cRetorno := " "
	Local aNota := {}
	
	VM0->(DbSeek(xFilial("VM0") + cConferencia ))

	If VM0->VM0_STATUS $ "4/5"
		cRetorno := VM0->VM0_OBSERV
	Else

		aNota := {VM0->VM0_DOC,VM0->VM0_SERIE,VM0->VM0_FORNEC,VM0->VM0_LOJA}

		cConfAnt := OM3900125_ExisteConferencia( aNota, .f. ,cConferencia )
		If !Empty(cConfAnt)

			VM0->(DbSeek(xFilial("VM0") + cConfAnt ))
			cRetorno := STR0101 + Chr(13) + Chr(10) + VM0->VM0_OBSERV // Observação da Rejeição 

			VM0->(DbSeek(xFilial("VM0") + cConferencia ))

		EndIf

	EndIf

Return cRetorno

/*/{Protheus.doc} OM3900285_GravaQtdConferida
Enviar EMAIL quando ha divergencia na Conferencia - funcao chamada pelo OFIOM390 e pelo Coletor de Dados

@author Andre Luis Almeida
@since 20/12/2016
@version undefined
@param cEmailDiv, caracter, Itens com Divergencia
@param cNrNF, caracter, Nro da NF
@param cForn, caracter, Fornecedor
@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

@type function
/*/
Function OM3900285_GravaQtdConferida( nRecVM1 , nQtdConf, cTpOrigem)

	Local oModelVM0 := FWLoadModel( 'OFIA190' )

	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
	Default nRecVM1 := 0

	If nRecVM1 > 0

		oModelVM0:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM0 := oModelVM0:Activate()

		if lRetVM0

			oModelDet := oModelVM0:GetModel("VM1DETAIL")
			oModelDet:GoToDataID(nRecVM1)
			oModelDet:SetValue( "VM1_QTCONF", nQtdConf )

			If Empty(oModelDet:GetValue( "VM1_DATINI"))
				oModelDet:SetValue( "VM1_DATINI", dDataBase )
				oModelDet:SetValue( "VM1_HORINI", Time() )
				oModelDet:SetValue( "VM1_USRCON", __cUserID )
			EndIf
			oModelDet:SetValue( "VM1_DATFIN", dDataBase )
			oModelDet:SetValue( "VM1_HORFIN", Time() )

			If ( lRet := oModelVM0:VldData() )

				if ( lRet := oModelVM0:CommitData())
				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0090,"COMMITVM0") // Não foi possivel gravar o(s) registro(s)
					Else
						Help("",1,"COMMITVM0",,STR0090,1,0) // Não foi possivel gravar o(s) registro(s)
					EndIf
				EndIf

			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0088,"VALIDVM0") // Problema na validação dos campos e não foi possivel concluir o relacionamento
				Else
					Help("",1,"VALIDVM0",,STR0088,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
				EndIf
			EndIf

			oModelVM0:DeActivate()

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0089,"ACTIVEVM0") // Não foi possivel ativar o modelo de inclusão da tabela VM0
			Else
				Help("",1,"ACTIVEVM0",,STR0089,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM0
			EndIf
		EndIf

	EndIf

	FreeObj(oModelVM0)

Return


/*/{Protheus.doc} OM3900295_LimpaLinhaBranca
Enviar EMAIL quando ha divergencia na Conferencia - funcao chamada pelo OFIOM390 e pelo Coletor de Dados

@author Andre Luis Almeida
@since 20/12/2016
@version undefined
@param cEmailDiv, caracter, Itens com Divergencia
@param cNrNF, caracter, Nro da NF
@param cForn, caracter, Fornecedor
@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

@type function
/*/
Function OM3900295_LimpaLinhaBranca()

	Local nPosItem := 0

	nPosItem := aScan(aItensConf,{|x| x[3] == " " })

	If nPosItem > 0
		aDel(aItensConf, nPosItem)
		aSize(aItensConf, Len(aItensConf) - 1)
	EndIf

Return

/*/{Protheus.doc} OM3900021_EMAIL
Enviar EMAIL quando ha divergencia na Conferencia - funcao chamada pelo OFIOM390 e pelo Coletor de Dados

@author Andre Luis Almeida
@since 20/12/2016
@version undefined
@param cEmailDiv, caracter, Itens com Divergencia
@param cNrNF, caracter, Nro da NF
@param cForn, caracter, Fornecedor
@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

@type function
/*/
Function OM3900021_EMAIL( cEmailDiv , cNrNF , cForn , cTpOrigem )
Local lOk := .f., lSendOK := .f.
Local cError := ""
Local cMailConta := GETMV("MV_EMCONTA") // Usuario/e-mail de envio
Local cMailServer:= GETMV("MV_RELSERV") // Server de envio
Local cMailSenha := GETMV("MV_EMSENHA") // Senha e-mail de envio
Local lAutentica := GetMv("MV_RELAUTH",,.f.)          // Determina se o Servidor de E-mail necessita de Autenticacao
Local cUserAut   := Alltrim(GetMv("MV_RELAUSR",," ")) // Usuario para Autenticacao no Servidor de E-mail
Local cPassAut   := Alltrim(GetMv("MV_RELAPSW",," ")) // Senha para Autenticacao no Servidor de E-mail
Local cEmail	 := GetNewPar("MV_MIL0092","") 		  // E-mail destinatario
Private cTitulo  := STR0031 // Divergencia na Conferencia de Itens de Entrada
Private cMensagem := ""
Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
If !Empty(cEmail)
	If ExistBlock("OM390MAI") // Ponto de Entrada para formatacao do email
		ExecBlock("OM390MAI",.f.,.f.,{cEmailDiv}) // Parametro --> Detalhes dos Itens com divergencia na Conferencia
	Else // HTML Padrao //
		cMensagem+= "<center><table border=0 width=90%><tr>"
		If !Empty( GetNewPar("MV_ENDLOGO","") )
			cMensagem+= "<td width=20%><img src='" + GetNewPar("MV_ENDLOGO","") + "'></td>"
		EndIf
		cMensagem+= "<td align=center width=90%><font size=3 face='verdana,arial' Color=#0000cc><b>"
		cMensagem+= FWFilialName()+"<br></font></b>"
		cMensagem+= "</td></tr></table><hr width=90%>"
		cMensagem+= "<font size=3 face='verdana,arial' Color=black><b>"+cTitulo+"<br></font></b><hr width=90%><br>"
		cMensagem+= "<table border=0 width=90%><tr>"
		cMensagem+= "<td width=10%><font size=3 face='verdana,arial' Color=black>"+STR0017+":"+"</font></td>" // NF
		cMensagem+= "<td width=20%><font size=3 face='verdana,arial' Color=#0000cc><b>"+cNrNF+"</b></font></td>"
		cMensagem+= "<td width=20%><font size=3 face='verdana,arial' Color=black>"+STR0019+":"+"</font></td>" // Fornecedor
		cMensagem+= "<td width=50%><font size=3 face='verdana,arial' Color=#0000cc><b>"+cForn+"</b></font></td>"
		cMensagem+= "</tr></table><br>"
		cMensagem+= "<table border=0 width=90%>"
		cMensagem+= "<tr>"
		cMensagem+= "<td width=25%><font size=3 face='verdana,arial' Color=black>"+STR0050+"</font></td>" // Item
		cMensagem+= "<td width=50%><font size=3 face='verdana,arial' Color=black>"+STR0005+"</font></td>" // Descricao
		cMensagem+= "<td width=25%><font size=3 face='verdana,arial' Color=black>"+STR0051+"</font></td>" // Tipo
		cMensagem+= "</tr>"
		cMensagem+= cEmailDiv
		cMensagem+= "</table></center>"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia e-mail do Evento 003                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cMailConta) .And. !Empty(cMailServer) .And. !Empty(cMailSenha)
		// Conecta uma vez com o servidor de e-mails
		CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
		If lOk
			lOk := .f.
			If lAutentica
				If !MailAuth(cUserAut,cPassAut)
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0052,STR0009) //  Erro no envio de e-mail.
					Else
						MsgStop(STR0052,STR0009) // Erro no envio de e-mail.
					EndIf
					DISCONNECT SMTP SERVER
				Else
					lOk := .t.
				EndIf
			Else
				lOk := .t.
			EndIf
			If lOk
				// Envia e-mail com os dados necessarios
				SEND MAIL FROM cMailConta to Alltrim(cEmail) SUBJECT (cTitulo) BODY cMensagem FORMAT TEXT RESULT lSendOk
				If !lSendOk
					//Erro no Envio do e-mail
					GET MAIL ERROR cError
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0052,STR0009) //  Erro no envio de e-mail.
					Else
						MsgStop(STR0052,STR0009) // Erro no envio de e-mail.
					EndIf
				EndIf
				// Desconecta com o servidor de e-mails
				DISCONNECT SMTP SERVER
			EndIf
		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0053,STR0009) //  Nao foi possivel conectar no servidor de e-mail.
			Else
				MsgStop((STR0053+" "+chr(13)+chr(10)+cMailServer),STR0009) // Nao foi possivel conectar no servidor de e-mail.
			EndIf
		EndIf
	EndIf
EndIf
Return(.t.)

/*/{Protheus.doc} OM3900141_UsuarioAprovador
Retorna se o usuario logado é Aprovador

@author Andre Luis Almeida
@since 12/11/2019
@version 1.0
@return logico ( .t. / .f. )

@type function
/*/
Function OM3900141_UsuarioAprovador()
	VAI->(dbSetOrder(4))
	VAI->(MsSeek(xFilial("VAI")+__cUserID)) // Posiciona no VAI do usuario logado
Return VAI->VAI_APRCON == "1"

/*/{Protheus.doc} OM3900151_AposOkMATA103
Apos OK via MATA103 - Chamada dentro do MATA103

@author Andre Luis Almeida
@since 29/11/2019
@version 1.0
@return logico ( .t. / .f. )

@type function
/*/
Function OM3900151_AposOkMATA103(nOpcao,nConfirma,cF1_DOC,cF1_SERIE,cF1_FORNECE,cF1_LOJA)
Local aArea    := GetArea()
Local lRet     := .t.
Local oEstoq   := DMS_Estoque():New()
Local cDocSDB  := ""
Local cArmDiv  := GetNewPar("MV_MIL0140","") // Conferencia de Entrada - Armazem de Destino das Divergencias
Local lVldConf := OM3900171_Trabalha_com_Conferencia() // Trabalha com Conferência de Itens na Entrada de NF ?
Local cQuery   := ""
Local cQAlSQL  := "SQLALIAS"
Local cCodVM0  := ""
Local aNotaFiscal := Array(4)
Default cF1_DOC     := SF1->F1_DOC
Default cF1_SERIE   := SF1->F1_SERIE
Default cF1_FORNECE := SF1->F1_FORNECE
Default cF1_LOJA    := SF1->F1_LOJA
//
If nConfirma == 1 // Confirmou a Tela
	//
	If lVldConf .and. !Empty(cArmDiv) // Esta configurado para fazer a movimentacao automatica para um Armazem de Divergencia
		//
		If nOpcao == 3 .or. nOpcao == 4 .or. nOpcao == 5
			//
			aNotaFiscal[1] := cF1_DOC
			aNotaFiscal[2] := cF1_SERIE
			aNotaFiscal[3] := cF1_FORNECE
			aNotaFiscal[4] := cF1_LOJA
			//
			cCodVM0 := OM3900125_ExisteConferencia(aNotaFiscal,.f.)
			If !Empty(cCodVM0) // Conferencia da NF individual
				//
				If nOpcao == 3 .or. nOpcao == 4 // Inclusao ou Alteracao
					cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1 , "
					cQuery += "       VM1.R_E_C_N_O_ AS RECVM1 , "
					cQuery += " SD1.D1_LOCAL  AS LOCAL_DE   , "
					cQuery += " '"+cArmDiv+"' AS LOCAL_PARA , "
					cQuery += "       ( VM1.VM1_QTORIG - VM1.VM1_QTCONF ) AS QTDE "
					cQuery += "  FROM "+RetSQLName("VM1")+" VM1"
					cQuery += "  JOIN "+RetSqlName("SB1")+" SB1"
					cQuery += "       ON  SB1.B1_FILIAL='"+xFilial("SB1")+"'"
					cQuery += "       AND SB1.B1_COD=VM1.VM1_COD"
					cQuery += "       AND SB1.D_E_L_E_T_=' '"
					cQuery += "  JOIN "+RetSqlName("SD1")+" SD1"
					cQuery += "       ON  SD1.D1_FILIAL='"+xFilial("SD1")+"'"
					cQuery += "       AND SD1.D1_DOC='"+aNotaFiscal[1]+"'"
					cQuery += "       AND SD1.D1_SERIE='"+aNotaFiscal[2]+"'"
					cQuery += "       AND SD1.D1_FORNECE='"+aNotaFiscal[3]+"'"
					cQuery += "       AND SD1.D1_LOJA='"+aNotaFiscal[4]+"'"
					cQuery += "       AND SD1.D1_ITEM=VM1.VM1_SEQUEN"
					cQuery += "       AND SD1.D_E_L_E_T_=' '"
					cQuery += " WHERE VM1.VM1_FILIAL = '"+xFilial("VM1")+"'"
					cQuery += "   AND VM1.VM1_CODVM0 = '"+cCodVM0+"'"
					cQuery += "   AND ( VM1.VM1_QTORIG - VM1.VM1_QTCONF ) > 0"
					cQuery += "   AND VM1.D_E_L_E_T_ = ' '"
				Else // nOpcao == 5 // Exclusao
					cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1 , "
					cQuery += "       VM1.R_E_C_N_O_ AS RECVM1 , "
					cQuery += " '"+cArmDiv+"' AS LOCAL_DE   , "
					cQuery += " SD3.D3_LOCAL  AS LOCAL_PARA , "
					cQuery += " SD3.D3_QUANT  AS QTDE "
					cQuery += "  FROM "+RetSQLName("VM1")+" VM1"
					cQuery += "  JOIN "+RetSqlName("SB1")+" SB1"
					cQuery += "       ON  SB1.B1_FILIAL='"+xFilial("SB1")+"'"
					cQuery += "       AND SB1.B1_COD=VM1.VM1_COD"
					cQuery += "       AND SB1.D_E_L_E_T_=' '"
					cQuery += "  JOIN "+RetSqlName("SD3")+" SD3"
					cQuery += "       ON  SD3.D3_FILIAL='"+xFilial("SD3")+"'"
					cQuery += "       AND SD3.D3_DOC=VM1.VM1_DOCSDB "
					cQuery += "       AND SD3.D3_TM='999'"
					cQuery += "       AND SD3.D_E_L_E_T_=' '"
					cQuery += " WHERE VM1.VM1_FILIAL = '"+xFilial("VM1")+"'"
					cQuery += "   AND VM1.VM1_CODVM0 = '"+cCodVM0+"'"
					cQuery += "   AND VM1.VM1_DOCSDB <> ' '"
					cQuery += "   AND VM1.D_E_L_E_T_ = ' '"
				EndIf
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
				While !( cQAlSQL )->( Eof() )
					SB1->(DbGoTo(( cQAlSQL )->( RECSB1 )))
					cDocSDB := oEstoq:TransfereLote(	SB1->B1_COD                 ,;
														( cQAlSQL )->( LOCAL_DE )   ,; 
														( cQAlSQL )->( LOCAL_PARA ) ,;
														( cQAlSQL )->( QTDE )       ,;
														"" /*VM1_NUMLOT*/           ,; 
														"" /*VM1_LOTECT*/           )
					If Empty(cDocSDB) .or. cDocSDB == "ERRO"
						conout(	"OM3900151_AposOkMATA103 - "+STR0120)
						conout(	"    - "+STR0121+" '"+SB1->B1_COD+"' - "+STR0122+" '"+( cQAlSQL )->( LOCAL_DE ) + "' -> '"+( cQAlSQL )->( LOCAL_PARA )+"'")
						conout(	"    - "+STR0123+" "+aNotaFiscal[1]+"-"+aNotaFiscal[2]+" "+STR0124+" "+aNotaFiscal[3]+"-"+aNotaFiscal[4])
						lRet := .f.
					Else
						DbSelectArea("VM1")
						DbGoTo(( cQAlSQL )->( RECVM1 ))
						RecLock("VM1",.f.)
							If nOpcao == 3 .or. nOpcao == 4 // Inclusao ou Alteracao
								VM1->VM1_DOCSDB := cDocSDB // Codigo do SD3 - Movimentacao
							Else // nOpcao == 5 // Exclusao
								VM1->VM1_DOCSDB := "" // Limpa Codigo do SD3 - Movimentacao
							EndIf
						MsUnLock()
					EndIf
					( cQAlSQL )->( DbSkip() )
				EndDo
				( cQAlSQL )->( DbCloseArea() )
				//
				If nOpcao == 5 // Exclusao - Excluir todos os registros relacionados a NF Entrada + Serie + Fornecedor + Loja
					OM3900181_ExcluirConferencia( aNotaFiscal ) // Excluir VM0/VM1/VM2/VCX/VN4/VN7/VM7/VM8 referente a NF
				EndIf
				//
			Else // verificar divergencia gerada pela Conferencia por Volume
				cQuery := "SELECT VCX.VCX_COD    ,"
				cQuery += "       VCX.VCX_ITEM   ,"
				cQuery += "       VCX.VCX_QTDDIV ," 
				cQuery += "       VCX.VCX_DOCSDB ,"
				cQuery += "       VCX.R_E_C_N_O_ AS RECVCX "
				cQuery += "  FROM "+RetSQLName("VCX")+" VCX "
				cQuery += " WHERE VCX.VCX_FILIAL = '"+xFilial("VCX")+"'"
				cQuery += "   AND VCX.VCX_DOC    = '"+aNotaFiscal[1]+"'"
				cQuery += "   AND VCX.VCX_SERIE  = '"+aNotaFiscal[2]+"'"
				cQuery += "   AND VCX.VCX_FORNEC = '"+aNotaFiscal[3]+"'"
				cQuery += "   AND VCX.VCX_LOJA   = '"+aNotaFiscal[4]+"'"
				cQuery += "   AND VCX.VCX_QTDDIV > 0"
				cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
				TcQuery cQuery New Alias "SQLVCX"
				While !SQLVCX->(Eof())
					//
					If nOpcao == 3 .or. nOpcao == 4 // Inclusao ou Alteracao
						cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1 , "
						cQuery += "       SD1.D1_LOCAL AS LOCAL_DE , "
						cQuery += "      '"+cArmDiv+"' AS LOCAL_PARA "
						cQuery += "  FROM "+RetSQLName("SD1")+" SD1 "
						cQuery += "  JOIN "+RetSqlName("SB1")+" SB1"
						cQuery += "    ON SB1.B1_FILIAL  ='"+xFilial("SB1")+"'"
						cQuery += "   AND SB1.B1_COD     = SD1.D1_COD"
						cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
						cQuery += " WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"
						cQuery += "   AND SD1.D1_DOC     = '"+aNotaFiscal[1]+"'"
						cQuery += "   AND SD1.D1_SERIE   = '"+aNotaFiscal[2]+"'"
						cQuery += "   AND SD1.D1_FORNECE = '"+aNotaFiscal[3]+"'"
						cQuery += "   AND SD1.D1_LOJA    = '"+aNotaFiscal[4]+"'"
						cQuery += "   AND SD1.D1_COD     = '"+SQLVCX->( VCX_COD )+"'"
						cQuery += "   AND SD1.D1_ITEM    = '"+SQLVCX->( VCX_ITEM )+"'"
						cQuery += "   AND SD1.D_E_L_E_T_ = ' '"
					ElseIf nOpcao == 5 // Exclusao
						cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1     ,"
						cQuery += "       '"+cArmDiv+"'  AS LOCAL_DE   ,"
						cQuery += "       SD3.D3_LOCAL   AS LOCAL_PARA  "
						cQuery += "  FROM "+RetSqlName("SD3")+" SD3 "
						cQuery += "  JOIN "+RetSqlName("SB1")+" SB1"
						cQuery += "    ON SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"
						cQuery += "   AND SB1.B1_COD     = '"+SQLVCX->( VCX_COD )+"'"
						cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
						cQuery += " WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"'"
						cQuery += "   AND SD3.D3_DOC     = '"+SQLVCX->( VCX_DOCSDB )+"'"
						cQuery += "   AND SD3.D3_TM      = '999'"
						cQuery += "   AND SD3.D_E_L_E_T_ = ' '"
					EndIf
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
					If !( cQAlSQL )->( Eof() )
						SB1->(DbGoTo(( cQAlSQL )->( RECSB1 )))
						cDocSDB := oEstoq:TransfereLote(	SB1->B1_COD                 ,;
															( cQAlSQL )->( LOCAL_DE )   ,; 
															( cQAlSQL )->( LOCAL_PARA ) ,;
															SQLVCX->( VCX_QTDDIV )      ,;
															"" /*VM1_NUMLOT*/           ,; 
															"" /*VM1_LOTECT*/           )
						If Empty(cDocSDB) .or. cDocSDB == "ERRO"
							conout(	"OM3900151_AposOkMATA103 - "+STR0125)
							conout(	"    - "+STR0121+" '"+SB1->B1_COD+"' - "+STR0122+" '"+( cQAlSQL )->( LOCAL_DE ) + "' -> '"+( cQAlSQL )->( LOCAL_PARA )+"'")
							conout(	"    - "+STR0123+" "+aNotaFiscal[1]+"-"+aNotaFiscal[2]+" "+STR0124+" "+aNotaFiscal[3]+"-"+aNotaFiscal[4])
							lRet := .f.
						Else
							DbSelectArea("VCX")
							DbGoTo( SQLVCX->( RECVCX ) )
							If nOpcao == 3 .or. nOpcao == 4 // Inclusao ou Alteracao
								RecLock("VCX",.f.)
									VCX->VCX_DOCSDB := cDocSDB // Codigo do SD3 - Movimentacao
								MsUnLock()
							ElseIf nOpcao == 5 // Exclusao
								RecLock("VCX",.F.)
									VCX->VCX_DOCSDB := "" // Limpa Codigo do SD3 - Movimentacao
								MsUnlock()
							EndIf
						EndIf
					EndIf
					( cQAlSQL )->( DbCloseArea() )
					//
					SQLVCX->(DbSkip())
				EndDo
				SQLVCX->(dbCloseArea())
				//
				If nOpcao == 5 // Exclusao
					OM3900181_ExcluirConferencia( aNotaFiscal ) // Excluir VM0/VM1/VM2/VCX/VN4/VN7/VM7/VM8 referente a NF
				EndIf
				//
			EndIf
			//
			DbSelectArea("SF1")
			//
		EndIf
		//
	EndIf
	//
EndIf
//
FreeObj(oEstoq)
//
RestArea(aArea)	
//
Return lRet

/*/{Protheus.doc} OM3900161_PermiteClassificarNFEntrada
Permite Classificar via MATA103 ? - Chamada dentro do MATA103

@author Andre Luis Almeida
@since 29/11/2019
@version 1.0
@return logico ( .t. / .f. )

@type function
/*/
Function OM3900161_PermiteClassificarNFEntrada( cTpNF , cNrNF , lINC103 )
Local aArea    := GetArea()
Local lRet     := .T.
Local cCodVM0  := ""
Local nCntFor  := 0
Local aVolumes := {}
Local cArmDiv  := GetNewPar("MV_MIL0140","") // Conferencia de Entrada - Armazem de Destino das Divergencias
Local lVldConf := OM3900171_Trabalha_com_Conferencia() // Trabalha com Conferência de Itens na Entrada de NF ?
Local aNotaFiscal := Array(4)
//
IF lVldConf .and. ( cTpNF=="N" .or. cTpNF=="D" ) .and. !Empty(cNrNF) .and. !lINC103
	If OFIOM390( SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )// Indica Classificacao e nao inclusao
		If !Empty(cArmDiv) // Esta configurado para fazer a movimentacao automatica para um Armazem de Divergencia
			//
			aNotaFiscal[1] := SF1->F1_DOC
			aNotaFiscal[2] := SF1->F1_SERIE
			aNotaFiscal[3] := SF1->F1_FORNECE
			aNotaFiscal[4] := SF1->F1_LOJA
			cCodVM0 := OM3900125_ExisteConferencia(aNotaFiscal,.t.)
			If !Empty(cCodVM0)
				If VM0->(DbSeek(xfilial("VM0") + cCodVM0 ) ) .and. VM0->VM0_DIVERG == "1" // Tem Divergencia
					If !MsgYesNo(STR0113,STR0009) // Existe(m) divergência(s) na Conferência da NF de Entrada. Deseja continuar? / Atenção
						lRet := .f.
					EndIf
				EndIf
			Else
				aVolumes := OA3400041_VolumesporNF( SF1->F1_DOC , SF1->F1_SERIE , SF1->F1_FORNECE , SF1->F1_LOJA )
				For nCntFor := 1 to len(aVolumes)
					If !Empty(aVolumes[nCntFor,2])
						If VM7->(DbSeek(xfilial("VM7") + aVolumes[nCntFor,2] ) ) .and. VM7->VM7_DIVERG == "1" // Tem Divergencia
							If !MsgYesNo(STR0119,STR0009) // Existe(m) divergência(s) na Conferência dos Volumes da NF de Entrada. Deseja continuar? / Atenção
								lRet := .f.
							EndIf
							Exit
						EndIf
					EndIf
				Next
			EndIf
			//
		EndIf
	Else
		MsgAlert(STR0114,STR0115) // Pré-Nota não foi Conferida. Necessário Conferir a NF de Entrada para liberar classificação da mesma. / Classificação não permitida
		lRet := .f.
	EndIf
EndIf
RestArea(aArea)
//
Return lRet

/*/{Protheus.doc} OM3900171_Trabalha_com_Conferencia
Trabalha com Conferência de Itens na Entrada de NF ?

@author Andre Luis Almeida
@since 29/11/2019
@version 1.0
@return logico ( .t. / .f. )  .t. Valida a Conferencia

@type function
/*/
Function OM3900171_Trabalha_com_Conferencia()
Local lConBar  := SD1->(FieldPos("D1_CONBAR")) > 0
Local lVldConf := .f.

////////////////////////////////////////////////////////////////////////////
//
If SuperGetMV("MV_MIL0147",.F.,"NAOEXISTE") <> "NAOEXISTE"
	lVldConf := ( GetNewPar("MV_MIL0147","0") == "1" ) // Trabalha com Conferencia de Itens na Entrada de NF ?  ( 0 = Nao / 1 = Sim )
////////////////////////////////////////////////////////////////////////////
// Necessario para compatibilizacao versao antiga ( utilizava D1_CONBAR ) //
////////////////////////////////////////////////////////////////////////////
ElseIf lConBar .and. CriaVar("D1_CONBAR") <> "1"
	lVldConf := .t.
EndIf
//
Return lVldConf

/*/{Protheus.doc} OM3900301_ChamaPEaposAprovReprov
Apos OK na Aprovacao/Reprovacao chama PE OM390DOK

@author Andre Luis Almeida
@since 03/12/2019
@version 1.0

@type function
/*/
Function OM3900301_ChamaPEaposAprovReprov( cAprRepr )
Local aNFS   := {}
Local aItens := {}
Local cQuery := ""
Default cAprRepr := "1" // Aprovacao

If ExistBlock("OM390DOK")

	aAdd(aNFS,{.t.,;
				"",;
				"",;
				"",;
				"SF1",;
				"",;
				VM0->VM0_DOC,;
				VM0->VM0_SERIE,;
				VM0->VM0_FORNEC,;
				VM0->VM0_LOJA,;
				"";
			})

	cQuery := "SELECT VM1.VM1_COD, VM1.VM1_QTCONF, VM1.VM1_QTORIG, R_E_C_N_O_ VM1RECNO "
	cQuery += " FROM " + RetSqlName("VM1") + " VM1 "
	cQuery += " WHERE VM1.VM1_FILIAL = '" + xFilial("VM1") + "' "
	cQuery +=	" AND VM1.VM1_CODVM0 = '" + VM0->VM0_CODIGO + "' "
	cQuery +=	" AND VM1.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVM1"

	While !TMPVM1->(Eof())

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+TMPVM1->VM1_COD))

		SB5->(DbSetOrder(1))
		SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))

		Aadd(aItens,{ "",;
					SB1->B1_GRUPO,;
					SB1->B1_CODITE,;
					SB1->B1_DESC,;
					TMPVM1->VM1_QTCONF,;
					TMPVM1->VM1_QTORIG,;
					SB1->B1_CODBAR,;
					SB1->B1_COD,;
					FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
					VM0->VM0_TIPO,;
					TMPVM1->VM1RECNO;
					})
		TMPVM1->(DbSkip())
	EndDo
	TMPVM1->(dbCloseArea())
	DbSelectArea("SF1")

	ExecBlock("OM390DOK",.f.,.f.,{cAprRepr,aNFs,aItens}) // PE apos Aprovação / Reprovacao

EndIf

Return

/*/{Protheus.doc} OM3900181_ExcluirConferencia
	Exclui registros referente a Conferencia da NF de Entrada

	@author Andre Luis Almeida
	@since  27/12/2019

	@param aNotaFiscal NF de Entrada que sera excluida
/*/
Function OM3900181_ExcluirConferencia( aNotaFiscal )
Local cQuery   := ""
Local cQAlVM0  := "SQLVM0"
Local cQAlSQL  := "SQLVM1"
Local cQAlVM2  := "SQLVM2"
Local cFilVM0  := ""
Local cCodVM0  := ""
Local aVolumes := {}
Local nCntFor  := 0
Local oSqlHelp := DMS_SqlHelper():New()
Local lVN4     := oSqlHelp:ExistTable(RetSqlName("VN4"))
Local lVN7     := oSqlHelp:ExistTable(RetSqlName("VN7"))
Local lVM7VM8  := ( oSqlHelp:ExistTable(RetSqlName("VM7")) .and. oSqlHelp:ExistTable(RetSqlName("VM8")) )
Default aNotaFiscal := {}
If len(aNotaFiscal) > 0
	BEGIN TRANSACTION
	/////////////////
	// VM0/VM1/VM2 //
	/////////////////
	cQuery := "SELECT R_E_C_N_O_ AS RECVM0 "
	cQuery += "  FROM "+RetSQLName("VM0")
	cQuery += " WHERE VM0_FILIAL='"+xFilial("VM0")+"'"
	cQuery += "   AND VM0_DOC='"+aNotaFiscal[1]+"'"
	cQuery += "   AND VM0_SERIE='"+aNotaFiscal[2]+"'"
	cQuery += "   AND VM0_FORNEC='"+aNotaFiscal[3]+"'"
	cQuery += "   AND VM0_LOJA='"+aNotaFiscal[4]+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVM0 , .F., .T. )
	While !( cQAlVM0 )->( Eof() )
		DbSelectArea("VM0")
		VM0->(DbGoTo(( cQAlVM0 )->( RECVM0 )))
		cFilVM0 := VM0->VM0_FILIAL
		cCodVM0 := VM0->VM0_CODIGO
		RecLock("VM0",.F.,.T.)
		DbDelete()
		MsUnlock()
		//
		cQuery := "SELECT VM2.R_E_C_N_O_ AS RECVM2 "
		cQuery += "  FROM "+RetSQLName("VM2")+" VM2 "
		cQuery += " WHERE VM2.VM2_FILIAL='"+cFilVM0+"'"
		cQuery += "   AND VM2.VM2_CODIGO='"+cCodVM0+"'"
		cQuery += "   AND VM2.VM2_TIPO='1'"
		cQuery += "   AND VM2.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVM2 , .F., .T. )
		While !( cQAlVM2 )->( Eof() )
			DbSelectArea("VM2")
			VM2->(DbGoTo(( cQAlVM2 )->( RECVM2 )))
			RecLock("VM2",.F.,.T.)
			DbDelete()
			MsUnlock()
			( cQAlVM2 )->( DbSkip() )
		EndDo
		( cQAlVM2 )->( DbCloseArea() )
		//
		cQuery := "SELECT VM1.R_E_C_N_O_ AS RECVM1 "
		cQuery += "  FROM "+RetSQLName("VM1")+" VM1 "
		cQuery += " WHERE VM1.VM1_FILIAL='"+cFilVM0+"'"
		cQuery += "   AND VM1.VM1_CODVM0='"+cCodVM0+"'"
		cQuery += "   AND VM1.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			DbSelectArea("VM1")
			VM1->(DbGoTo(( cQAlSQL )->( RECVM1 )))
			RecLock("VM1",.F.,.T.)
			DbDelete()
			MsUnlock()
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		//
		( cQAlVM0 )->( DbSkip() )
	EndDo
	( cQAlVM0 )->( DbCloseArea() )
	/////////
	// VCX //
	/////////
	cQuery := "SELECT VCX.R_E_C_N_O_ AS RECVCX "
	cQuery += "  FROM "+RetSQLName("VCX")+" VCX "
	cQuery += " WHERE VCX.VCX_FILIAL = '"+xFilial("VCX")+"'"
	cQuery += "   AND VCX.VCX_DOC    = '"+aNotaFiscal[1]+"'"
	cQuery += "   AND VCX.VCX_SERIE  = '"+aNotaFiscal[2]+"'"
	cQuery += "   AND VCX.VCX_FORNEC = '"+aNotaFiscal[3]+"'"
	cQuery += "   AND VCX.VCX_LOJA   = '"+aNotaFiscal[4]+"'"
	cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
	TcQuery cQuery New Alias "SQLVCX"
	While !SQLVCX->(Eof())
		DbSelectArea("VCX")
		DbGoTo( SQLVCX->( RECVCX ) )
		If lVN7 .or. lVM7VM8
			If Ascan(aVolumes,VCX->VCX_VOLUME) == 0
				aAdd(aVolumes,VCX->VCX_VOLUME) // Volumes para deletar do VN7
			EndIf
		EndIf
		RecLock("VCX",.F.,.T.)
			DbDelete()
		MsUnlock()
		SQLVCX->(DbSkip())
	EndDo
	SQLVCX->(dbCloseArea())
	/////////
	// VN4 //
	/////////
	If lVN4
		cQuery := "SELECT VN4.R_E_C_N_O_ AS RECVN4 "
		cQuery += "  FROM "+RetSQLName("VN4")+" VN4 "
		cQuery += " WHERE VN4.VN4_FILIAL = '"+xFilial("VN4")+"'"
		cQuery += "   AND VN4.VN4_DOC    = '"+aNotaFiscal[1]+"'"
		cQuery += "   AND VN4.VN4_SERIE  = '"+aNotaFiscal[2]+"'"
		cQuery += "   AND VN4.VN4_FORNEC = '"+aNotaFiscal[3]+"'"
		cQuery += "   AND VN4.VN4_LOJA   = '"+aNotaFiscal[4]+"'"
		cQuery += "   AND VN4.D_E_L_E_T_ = ' '"
		TcQuery cQuery New Alias "SQLVN4"
		While !SQLVN4->(Eof())
			DbSelectArea("VN4")
			DbGoTo( SQLVN4->( RECVN4 ) )
			RecLock("VN4",.F.,.T.)
				DbDelete()
			MsUnlock()
			SQLVN4->(DbSkip())
		EndDo
		SQLVN4->(dbCloseArea())
	EndIf
	/////////
	// VN7 //
	/////////
	If lVN7
		For nCntFor := 1 to len(aVolumes)
			cQuery := "SELECT VN7.R_E_C_N_O_ AS RECVN7 "
			cQuery += "  FROM "+RetSQLName("VN7")+" VN7 "
			cQuery += " WHERE VN7.VN7_FILIAL = '"+xFilial("VN7")+"'"
			cQuery += "   AND VN7.VN7_VOLUME = '"+aVolumes[nCntFor]+"'"
			cQuery += "   AND VN7.D_E_L_E_T_ = ' '"
			cQuery += "   AND NOT EXISTS"
			cQuery += "   ( "
			cQuery += "    SELECT VCX.VCX_VOLUME "
			cQuery += "      FROM "+RetSQLName("VCX")+" VCX "
			cQuery += "     WHERE VCX.VCX_FILIAL = '"+xFilial("VCX")+"'"
			cQuery += "       AND VCX.VCX_VOLUME = '"+aVolumes[nCntFor]+"'"
			cQuery += "       AND VCX.D_E_L_E_T_ = ' '"
			cQuery += "   ) "
			TcQuery cQuery New Alias "SQLVN7"
			While !SQLVN7->(Eof())
				DbSelectArea("VN7")
				DbGoTo( SQLVN7->( RECVN7 ) )
				RecLock("VN7",.F.,.T.)
					DbDelete()
				MsUnlock()
				SQLVN7->(DbSkip())
			EndDo
			SQLVN7->(dbCloseArea())
		Next
	EndIf
	/////////////
	// VM7/VM8 //
	/////////////
	If lVM7VM8
		For nCntFor := 1 to len(aVolumes)
			cQuery := "SELECT R_E_C_N_O_ AS RECVCX "
			cQuery += "  FROM "+RetSQLName("VCX")
			cQuery += " WHERE VCX_FILIAL = '"+xFilial("VCX")+"'"
			cQuery += "   AND VCX_VOLUME = '"+aVolumes[nCntFor]+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			If FM_SQL(cQuery) == 0 // Nao encontrou nenhuma NF para o Volume excluido
				cQuery := "SELECT VM7.VM7_CODIGO , VM7.R_E_C_N_O_ AS RECVM7 "
				cQuery += "  FROM "+RetSQLName("VM7")+" VM7 "
				cQuery += " WHERE VM7.VM7_FILIAL = '"+xFilial("VM7")+"'"
				cQuery += "   AND VM7.VM7_VOLUME = '"+aVolumes[nCntFor]+"'"
				cQuery += "   AND VM7.D_E_L_E_T_ = ' '"
				TcQuery cQuery New Alias "SQLVM7"
				While !SQLVM7->(Eof())
					cQuery := "SELECT VM8.R_E_C_N_O_ AS RECVM8 "
					cQuery += "  FROM "+RetSQLName("VM8")+" VM8 "
					cQuery += " WHERE VM8.VM8_FILIAL = '"+xFilial("VM8")+"'"
					cQuery += "   AND VM8.VM8_CODVM7 = '"+SQLVM7->( VM7_CODIGO )+"'"
					cQuery += "   AND VM8.D_E_L_E_T_ = ' '"
					TcQuery cQuery New Alias "SQLVM8"
					While !SQLVM8->(Eof())
						DbSelectArea("VM8")
						DbGoTo( SQLVM8->( RECVM8 ) )
						RecLock("VM8",.F.,.T.)
							DbDelete()
						MsUnlock()
						SQLVM8->(DbSkip())
					EndDo
					SQLVM8->(dbCloseArea())
					DbSelectArea("VM7")
					DbGoTo( SQLVM7->( RECVM7 ) )
					RecLock("VM7",.F.,.T.)
						DbDelete()
					MsUnlock()
					SQLVM7->(DbSkip())
				EndDo
				SQLVM7->(dbCloseArea())
			EndIf
		Next
	EndIf
	END TRANSACTION
EndIf
DbSelectArea("SF1")
Return

/*/{Protheus.doc} OM3900311_GravaConferenciaZerada
	Grava registros que estao zerados no momento da Finalizacao da Conferencia

	@author Andre Luis Almeida
	@since  10/06/2020

	@param cConferencia Codigo do VM0
	@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
/*/
Function OM3900311_GravaConferenciaZerada( cConferencia , cTpOrigem )
Local cQuery      := ""
Local cQAlSQL     := "SQLVM1"
Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
//
cQuery := "SELECT VM1.R_E_C_N_O_ AS RECVM1 "
cQuery += "  FROM "+RetSQLName("VM1")+" VM1 "
cQuery += " WHERE VM1.VM1_FILIAL='"+xFilial("VM1")+"'"
cQuery += "   AND VM1.VM1_CODVM0='"+cConferencia+"'"
cQuery += 	" AND VM1.VM1_QTORIG > 0 "
cQuery += 	" AND VM1.VM1_QTCONF = 0 "
cQuery += "   AND VM1.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	OM3900285_GravaQtdConferida( ( cQAlSQL )->( RECVM1 ) , 0 , cTpOrigem )
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
//
DbSelectArea("VM0")
//
Return

/*/{Protheus.doc} OM3900321_VisualizarConferencia
	Visualizar Conferencia

	@author Andre Luis Almeida
	@since  27/08/2021
/*/
Function OM3900321_VisualizarConferencia()
Local aNota := {SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA}
Local cNroConf := OM3900125_ExisteConferencia( aNota , .f. )
VM0->( DbSetOrder(1) )
If !Empty(cNroConf) .and. VM0->( DbSeek( xFilial("VM0") + cNroConf ) )
	OM3900065_TelaConferencia( cNroConf, .t. )
Else
	MsgInfo(STR0126,STR0009) // Conferencia não iniciada. / Atencao
EndIf
Return

/*/{Protheus.doc} OM3900341_AposOkMATA140
	Apos OK via MATA140 - Chamada dentro do MATA140

	@author Andre Luis Almeida
	@since  17/11/2021
/*/
Function OM3900341_AposOkMATA140(nOpcao,nConfirma,cF1_DOC,cF1_SERIE,cF1_FORNECE,cF1_LOJA,cTIPO)
Local lRet := .t.
Local aNotaFiscal := {}
If nConfirma == 1 // Confirmou a Tela
	If nOpcao == 3 .or. nOpcao == 4 // Inclusao ou Alteracao Pré-NF
		If ExistFunc("OA3600011_Tempo_Total_Conferencia_NF_Entrada")
			OA3600011_Tempo_Total_Conferencia_NF_Entrada( 1 , cF1_DOC , cF1_SERIE , cF1_FORNECE , cF1_LOJA ) // 1=Iniciar o Tempo Total da Conferencia de NF de Entrada caso não exista o registro
		EndIf
	ElseIf nOpcao == 5 // Exclusao Pré-NF
		aNotaFiscal := { cF1_DOC , cF1_SERIE , cF1_FORNECE , cF1_LOJA } // Numero da NF , Serie da NF , Fornecedor , Loja
		OM3900181_ExcluirConferencia( aNotaFiscal ) // Excluir VM0/VM1/VM2/VCX/VN4/VN7/VM7/VM8 referente a NF
	EndIf
EndIf
Return lRet