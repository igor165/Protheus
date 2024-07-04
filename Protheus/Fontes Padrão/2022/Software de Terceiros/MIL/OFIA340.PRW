#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#Include "Protheus.ch"
#Include "OFIA340.ch"
#Include "AP5MAIL.CH"

/*/{Protheus.doc} OFIA340
Conferencia de Entrada por Volume

@author Andre Luis Almeida
@since 13/08/2021
@version undefined
/*/
Function OFIA340(cConfNF)

	Local aSize      := FWGetDialogSize( oMainWnd )

	Local oSqlHlp    := DMS_SqlHelper():New()
	Local lAprovador := OM3900141_UsuarioAprovador()

	Local lVldConf   := OM3900171_Trabalha_com_Conferencia() // Trabalha com Conferência de Itens na Entrada de NF ?

	Local lRet       := .t. // Return .t. Deixa passar e NAO Valida Conferencia

	Private oTabTMPV // Volumes
	Private oTabTMPI // Itens
	Private oTabTMPN // NFs

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
	Private lMostraItem := IIf(lAprovador,.t.,(substr(cTpConf,1,1) == "1"))
	Private lMostraQtd  := substr(cTpConf,2,1) == "1"
	Private lUtilAprova := substr(cTpConf,3,1) == "1"
	Private lCriouTabIt := .f. // variavel destinada para ver se criou tabela temporaria dos Itens

	Private nFiltDia  := 7
	Private cFiltFor  := Space(GetSX3Cache("D1_FORNECE","X3_TAMANHO"))
	Private cFiltLoj  := Space(GetSX3Cache("D1_LOJA","X3_TAMANHO"))
	Private cFiltVol  := Space(GetSX3Cache("VCX_VOLUME","X3_TAMANHO"))
	Private cFiltGrp  := Space(GetSX3Cache("B1_GRUPO","X3_TAMANHO"))
	Private cFiltCod  := Space(GetSX3Cache("B1_CODITE","X3_TAMANHO"))

	Private cCadastro := STR0001 // Conferência de Entrada por Volume

	If !Empty(cConfNF) // VALIDAR CONFERENCIA DE ITENS DO VOLUME DE ENTRADA - por NF Entrada
		//
		If lVldConf
			cQuery := "SELECT VCX.VCX_VOLUME , COUNT(VM7.VM7_VOLUME) AS QTDE "
			cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
			cQuery += "  LEFT JOIN " + RetSqlName("VM7") + " VM7 ON VM7.VM7_FILIAL='"+xFilial("VM7")+"' AND VM7.VM7_STATUS='4' AND VM7.VM7_VOLUME=VCX.VCX_VOLUME AND VM7.D_E_L_E_T_=' '"
			cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "' "
			cQuery += "   AND " + oSqlHlp:Concat({'VCX.VCX_DOC', 'VCX.VCX_SERIE', 'VCX.VCX_FORNEC', 'VCX.VCX_LOJA'}) + " = '" + cConfNF + "'"
			cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
			cQuery += " GROUP BY VCX.VCX_VOLUME"
			TcQuery cQuery New Alias "SQLVCX"
			While !SQLVCX->(Eof())
				If SQLVCX->( QTDE ) == 0 // Verifica se a Conferencia do Volume NÃO esta Aprovada
					lRet := .f. // Existe Conferencia NAO APROVADA para o Volume da NF de Entrada
					Exit
				EndIf
				SQLVCX->(DbSkip())
			EndDo
			SQLVCX->(dbCloseArea())
			DbSelectArea("VCX")
		EndIf
		FreeObj(oSqlHlp)
		Return lRet // Retorna: .T. (Conferencias dos Volumes Aprovadas) / .F. (Conferencias dos Volumes NAO Aprovadas)
		//
	EndIf

	FreeObj(oSqlHlp)

	oDlgOA340 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0001, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Conferência de Entrada por Volume

	oWorkArea := FWUIWorkArea():New( oDlgOA340 )

	oWorkArea:CreateHorizontalBox( "LINE01", 49 )
	oWorkArea:SetBoxCols( "LINE01", { "OBJV" } ) // Volumes
	oWorkArea:CreateHorizontalBox( "LINE02", 49 )
	If lMostraItem //Mostra item - Sim
		oWorkArea:SetBoxCols( "LINE02", { "OBJI" , "OBJN" } ) // Itens / NFs
	Else
		oWorkArea:SetBoxCols( "LINE02", { "OBJN" } ) // NFs
	EndIf
	
	oWorkArea:Activate()

	Processa( {|| OA3400381_CriaTabelasTemporarias( lMostraItem , lAprovador ) }) // Cria Tabelas Temporarias com Dados

	SetKey(VK_F12,{ || OA3400171_FiltraVolume( lMostraItem , lAprovador ) })

	// Criação do browse de Volumes na tela
	oBrwTMPV := FWMBrowse():New()
	oBrwTMPV:SetOwner(oWorkarea:GetPanel("OBJV"))
	oBrwTMPV:SetTemporary(.T.) 
	oBrwTMPV:DisableDetails()
	oBrwTMPV:DisableConfig()
	oBrwTMPV:DisableReport()
	oBrwTMPV:SetFixedBrowse(.T.)
	oBrwTMPV:SetAlias("TMPVVCX")
	oBrwTMPV:SetFields( OA3400371_MontaCampos( 2 ,"TMPV" ) )
	oBrwTMPV:SetMenuDef( 'OFIA340' )
	oBrwTMPV:SetChgAll(.T.) //nao apresentar a tela para informar a filial
	oBrwTMPV:AddStatusColumns({|| OA3400021_ColunaStatusVolume() }, {|| OA3400031_LegendaStatusVolume() })
	oBrwTMPV:ForceQuitButton()
	oBrwTMPV:SetDescription(STR0001) // Conferência de Entrada por Volume
	OA3400181_FiltroBrowseTMPV( lAprovador )
	oBrwTMPV:Activate()

	If lMostraItem //Mostra item - Sim
		// Criação do browse de Itens na tela
		oBrwTMPI := FWMBrowse():New()
		oBrwTMPI:SetOwner(oWorkarea:GetPanel("OBJI"))
		oBrwTMPI:SetTemporary(.T.) 
		oBrwTMPI:DisableDetails()
		oBrwTMPI:DisableConfig()
		oBrwTMPI:DisableReport()
		oBrwTMPI:SetFixedBrowse(.T.)
		oBrwTMPI:SetAlias("TMPIVCX")
		oBrwTMPI:SetFields( OA3400371_MontaCampos( 2 ,"TMPI" ) )
		oBrwTMPI:SetMenuDef( '' )
		oBrwTMPI:AddStatusColumns({|| OA3400421_ColunaStatusItens() }, {|| OA3400431_LegendaStatusItens() })
		oBrwTMPI:ForceQuitButton()
		oBrwTMPI:SetDescription(STR0002) // Itens do Volume
		oBrwTMPI:Activate()
		oRelTMPI:= FWBrwRelation():New()
		oRelTMPI:AddRelation( oBrwTMPV , oBrwTMPI , {{ "TPI_FILIAL", "TPV_FILIAL" }, { "TPI_VOLUME", "TPV_VOLUME" } }) // Volume x Itens
		oRelTMPI:Activate()
	EndIf

	// Criação do browse de NFs na tela
	oBrwTMPN := FWMBrowse():New()
	oBrwTMPN:SetOwner(oWorkarea:GetPanel("OBJN"))
	oBrwTMPN:SetTemporary(.T.) 
	oBrwTMPN:DisableDetails()
	oBrwTMPN:DisableConfig()
	oBrwTMPN:DisableReport()
	oBrwTMPN:SetFixedBrowse(.T.)
	oBrwTMPN:SetAlias("TMPNVCX")
	oBrwTMPN:SetFields( OA3400371_MontaCampos( 2 ,"TMPN" ) )
	oBrwTMPN:SetMenuDef( '' )
	oBrwTMPN:ForceQuitButton()
	oBrwTMPN:SetDescription(STR0003) // Notas Fiscais do Volume
	oBrwTMPN:AddStatusColumns({|| OA3400151_ColunaStatusNF() }, {|| OA3400161_LegendaStatusNF() })
	oBrwTMPN:Activate()
	oRelTMPN:= FWBrwRelation():New()
	oRelTMPN:AddRelation( oBrwTMPV , oBrwTMPN , {{ "TPN_FILIAL", "TPV_FILIAL" }, { "TPN_VOLUME", "TPV_VOLUME" } }) // Volume x NFs
	oRelTMPN:Activate()

	oDlgOA340:Activate( , , , , , , ) //ativa a janela

	SetKey(VK_F12,Nil)

	oTabTMPV:CloseTable()
	oTabTMPN:CloseTable()
	If lCriouTabIt // closetable se criou a tabela temporaria dos Itens
		oTabTMPI:CloseTable()
	EndIf

Return NIL

Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	ADD OPTION aRotina TITLE STR0004 ACTION 'OA3400011_ConferenciaItem()' OPERATION 4 ACCESS 0 // Conferir
	ADD OPTION aRotina TITLE STR0005 ACTION 'OA3400441_ReprovarConferencia( TMPVVCX->TPV_VOLUME )' OPERATION 4 ACCESS 0 // Reprovar
	ADD OPTION aRotina TITLE STR0006 ACTION 'OA3400451_VisualizarConferencia( TMPVVCX->TPV_VOLUME )' OPERATION 2 ACCESS 0 // Visualizar

Return aRotina

/*/{Protheus.doc} OA3400021_ColunaStatusVolume

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400021_ColunaStatusVolume()
	
	// Variável do Retorno
	Local cImgRPO := "BR_BRANCO"

	cAlVM7 := 'TABVM7'
	BeginSql alias cAlVM7
		SELECT
			VM7.VM7_CODIGO,
			VM7.VM7_STATUS
		FROM
			%table:VM7% VM7
		WHERE
			VM7.VM7_FILIAL = %xfilial:VM7% AND
			VM7.VM7_VOLUME = %exp:TMPVVCX->TPV_VOLUME% AND
			VM7.%notDel%
		ORDER BY 1 DESC
	EndSql

	//-- Define Status do registro
	If (cAlVM7)->VM7_STATUS == "2" //Conf.Parcial
		cImgRpo := "BR_AMARELO"
	ElseIf (cAlVM7)->VM7_STATUS == "3" //Conferido
		cImgRpo := "BR_VERDE"
	ElseIf (cAlVM7)->VM7_STATUS == "4" //Aprovado
		cImgRpo := "BR_PRETO"
	ElseIf (cAlVM7)->VM7_STATUS == "5" //Reprovado
		cImgRpo := "BR_VERMELHO"
	EndIf

	(cAlVM7)->(dbCloseArea())
	
Return cImgRPO

/*/{Protheus.doc} OA3400031_LegendaStatusVolume

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400031_LegendaStatusVolume()
	
	// Array das Legendas
	Local aLegenda := {	{"BR_BRANCO"	, STR0007 },; // Pendente
						{"BR_AMARELO"	, STR0008 },; // Conf.Parcial
						{"BR_VERDE"		, STR0009 },; // Conferido
						{"BR_PRETO"		, STR0010 },; // Aprovado
						{"BR_VERMELHO"	, STR0011 } } // Reprovado

	//-- Define Status do registro
	BrwLegenda(STR0013,STR0012,aLegenda )	// Status dos Volumes / Legenda
	
Return .T.

/*/{Protheus.doc} OA3400041_VolumesporNF

@author Andre Luis Almeida
@since 17/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400041_VolumesporNF( cNF , cSer , cFor , cLoj )
Local aRetConf := {}
Local cQuery   := ""
//
cQuery := "SELECT VCX.VCX_VOLUME , MAX(VM7.VM7_CODIGO) AS CONFERENCIA "
cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
cQuery += "  LEFT JOIN " + RetSqlName("VM7") + " VM7 "
cQuery += "    ON VM7.VM7_FILIAL = '"+xFilial("VM7")+"'"
cQuery += "   AND VM7.VM7_STATUS IN ('1','2','3','4')"
cQuery += "   AND VM7.VM7_VOLUME = VCX.VCX_VOLUME"
cQuery += "   AND VM7.D_E_L_E_T_ = ' '"
cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "' "
cQuery += "   AND VCX.VCX_DOC    = '" + cNF  + "'"
cQuery += "   AND VCX.VCX_SERIE  = '" + cSer + "'"
cQuery += "   AND VCX.VCX_FORNEC = '" + cFor + "'"
cQuery += "   AND VCX.VCX_LOJA   = '" + cLoj + "'"
cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY VCX.VCX_VOLUME"
TcQuery cQuery New Alias "SQLVCX"
While !SQLVCX->(Eof())
	aAdd(aRetConf,{ SQLVCX->( VCX_VOLUME ) , SQLVCX->( CONFERENCIA ) })
	SQLVCX->(DbSkip())
EndDo
SQLVCX->(dbCloseArea())
DbSelectArea("VCX")
//
Return aRetConf

/*/{Protheus.doc} OA3400051_NFsporVolume

@author Andre Luis Almeida
@since 17/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400051_NFsporVolume( cVolume , lRetDet )
Local aRetConf := {}
Local cQuery   := ""
Default lRetDet := .f.
//
cQuery := "SELECT DISTINCT VCX.VCX_DOC , VCX.VCX_SERIE , VCX.VCX_FORNEC , VCX.VCX_LOJA "
If lRetDet
	cQuery += " , SA2.A2_NOME , SF1.F1_DTDIGIT "
EndIf
cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
If lRetDet
	cQuery += " JOIN " + RetSqlName("SA2") + " SA2 "
	cQuery += "   ON SA2.A2_FILIAL  = '" + xFilial("SA2") + "'"
	cQuery += "  AND SA2.A2_COD     = VCX.VCX_FORNEC"
	cQuery += "  AND SA2.A2_LOJA    = VCX.VCX_LOJA"
	cQuery += "  AND SA2.D_E_L_E_T_ = ' '"
	cQuery += " JOIN " + RetSqlName("SF1") + " SF1 "
	cQuery += "   ON SF1.F1_FILIAL  = '" + xFilial("SF1") + "'"
	cQuery += "  AND SF1.F1_DOC     = VCX.VCX_DOC"
	cQuery += "  AND SF1.F1_SERIE   = VCX.VCX_SERIE"
	cQuery += "  AND SF1.F1_FORNECE = VCX.VCX_FORNEC"
	cQuery += "  AND SF1.F1_LOJA    = VCX.VCX_LOJA"
EndIf
cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "'"
cQuery += "   AND VCX.VCX_VOLUME = '" + cVolume + "'"
cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
TcQuery cQuery New Alias "SQLNFs"
While !SQLNFs->(Eof())
	If aScan(aRetConf,{|x| x[1]+x[2]+x[3]+x[4] == SQLNFs->( VCX_DOC ) + SQLNFs->( VCX_SERIE ) + SQLNFs->( VCX_FORNEC ) + SQLNFs->( VCX_LOJA ) }) <= 0
		If lRetDet
			aAdd(aRetConf,{ SQLNFs->( VCX_DOC ) , SQLNFs->( VCX_SERIE ) , SQLNFs->( VCX_FORNEC ) , SQLNFs->( VCX_LOJA ) , SQLNFs->( A2_NOME ) , stod(SQLNFs->( F1_DTDIGIT )) })
		Else
			aAdd(aRetConf,{ SQLNFs->( VCX_DOC ) , SQLNFs->( VCX_SERIE ) , SQLNFs->( VCX_FORNEC ) , SQLNFs->( VCX_LOJA ) , "" , ctod("") })
		EndIf
	EndIf
	SQLNFs->(DbSkip())
EndDo
SQLNFs->(dbCloseArea())
DbSelectArea("VCX")
//
Return aRetConf

/*/{Protheus.doc} OA3400011_ConferenciaItem

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400011_ConferenciaItem()

	Local cNroConf	 := ""
	Local cVolume	 := ""
	Local lVisualiza := .f.
	Local lOkNFs     := .t.
	Local cMsg		 := ""
	Local lAprovador := OM3900141_UsuarioAprovador()
	Local aRecVCX    := {}
	Local cQuery     := ""
	Local nCntFor    := 0
	Local lTravouVCX := .t.
	Local aNFsVol    := {}
	Local lFuncTempo := ExistFunc("OA3600011_Tempo_Total_Conferencia_NF_Entrada")

	cVolume := TMPVVCX->TPV_VOLUME

	If ExistFunc("OA3630011_Tempo_Total_Conferencia_Volume_Entrada")
		OA3630011_Tempo_Total_Conferencia_Volume_Entrada( 1 , cVolume ) // 1=Iniciar o Tempo Total da Conferencia de Volume de Entrada caso não exista o registro
	EndIf

	aNFsVol := OA3400051_NFsporVolume( cVolume , .f. )
	For nCntFor := 1 to len(aNFsVol)
		If lFuncTempo
			OA3600011_Tempo_Total_Conferencia_NF_Entrada( 1 , aNFsVol[nCntFor,1] , aNFsVol[nCntFor,2] , aNFsVol[nCntFor,3] , aNFsVol[nCntFor,4] ) // 1=Iniciar o Tempo Total da Conferencia de NF de Entrada caso não exista o registro
		EndIf
		If !Empty(OM3900125_ExisteConferencia( aClone(aNFsVol[nCntFor]) , .t. )) // Verifica se ja existe a Conferencia de NF
			MsgStop(STR0014+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Existe NF dentro deste Volume que já foi para Conferencia individual. Impossível continuar.
					STR0015+": "+aNFsVol[nCntFor,1]+"-"+aNFsVol[nCntFor,2]+CHR(13)+CHR(10)+; // NF
					STR0016+": "+aNFsVol[nCntFor,3]+"-"+aNFsVol[nCntFor,4],STR0017) // Fornecedor / Atencao
			lOkNFs := .f.
		EndIf
	Next
	If !lOkNFs
		Return
	EndIf

	cNroConf := OA3400121_ExisteConferencia( cVolume , .t. )
	If Empty(cNroConf)
		cNroConf := OA3400091_GravaRegistroConferencia( cVolume , "0" )
	EndIf
	
	VM7->( DbSeek( xFilial("VM7") + cNroConf ) )
	
	If !lAprovador .and. !(VM7->VM7_STATUS == "1" .or. VM7->VM7_STATUS == "2")
		MsgStop(STR0018,STR0017) // Volume já conferido e aguardando aprovação. / Atencao
		Return
	EndIf

	Do Case
		Case VM7->VM7_STATUS == "1" .or. VM7->VM7_STATUS == "2"
			cMsg := STR0019 // Conferência do Volume está Pendente. Deseja Visualizar?
		Case VM7->VM7_STATUS == "3"
			cMsg := STR0020 // Conferência do Volume está Finalizada. Deseja Visualizar
		Case VM7->VM7_STATUS == "4"
			cMsg := STR0021 // Conferência do Volume está Aprovada. Deseja Visualizar?
		Case VM7->VM7_STATUS == "5"
			cMsg := STR0022 // Conferência do Volume está Reprovada. Deseja Visualizar?
	EndCase
	if lAprovador .or. VM7->VM7_STATUS == "1" .or. VM7->VM7_STATUS == "2"
		If lAprovador .and. VM7->VM7_STATUS <> "3"
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
			Case VM7->VM7_STATUS == "1" .or. VM7->VM7_STATUS == "2"
				cMsg := STR0023 // Conferência do Volume ainda Pendente
			Case VM7->VM7_STATUS == "4"
				cMsg := STR0024 // Conferência do Volume já Aprovada
			Case VM7->VM7_STATUS == "5"
				cMsg := STR0025 // Conferência do Volume já Reprovada
		EndCase

		MsgInfo(cMsg,STR0017) // Atencao
	EndIf
	If !lVisualiza
		cQuery := "SELECT DISTINCT VCX.R_E_C_N_O_ AS RECVCX "
		cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
		cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "' "
		cQuery += "   AND VCX.VCX_VOLUME = '" + cVolume + "' "
		cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
		TcQuery cQuery New Alias "SQLVCX"
		While !SQLVCX->(Eof())
			aAdd(aRecVCX,{ .f. , SQLVCX->( RECVCX ) })
			SQLVCX->(DbSkip())
		EndDo
		SQLVCX->(dbCloseArea())
		DbSelectArea("VCX")
		For nCntFor := 1 to len(aRecVCX)
			VCX->(DbGoto(aRecVCX[nCntFor,2]))
			If !Softlock("VCX") // Travar todos os Registros do VCX
				lTravouVCX := .f.
				Exit
			Else
				aRecVCX[nCntFor,1] := .t. // Travou VCX
			EndIf
		Next
	EndIf
	If lTravouVCX
		OA3400061_TelaConferencia( cNroConf , lVisualiza )
	EndIf
	If !lVisualiza
		DbSelectArea("VCX")
		For nCntFor := 1 to len(aRecVCX)
			If aRecVCX[nCntFor,1] // Estava Travado
				VCX->(DbGoto(aRecVCX[nCntFor,2]))
				VCX->(MsUnlock()) // Retirar SoftLock dos VCX
			EndIf
		Next
	EndIf
Return

/*/{Protheus.doc} OA3400061_TelaConferencia

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400061_TelaConferencia( cConferencia, lVisualiza )

	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := STR0001 // Conferência de Entrada por Volume
	Local aButtons		:= {}
	Local cTexto		:= ""
	Local lAprovador    := OM3900141_UsuarioAprovador()

	Default cConferencia := ""
	Default lVisualiza  := .f.

	Private lMostraCod	:= .t.
	Private aItensVol	:= {}
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

	VM7->(DbSeek(xFilial("VM7")+cConferencia))

	OA3400071_LevantaItens(cConferencia)

	oConfBarra := MSDialog():New( aCoors[1], aCoors[2], aCoors[3], aCoors[4], cTitulo, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )    // "Área de Trabalho"
	oConfBarra:lEscClose := .F.

		oLayer := FWLayer():new()
		oLayer:Init(oConfBarra,.f.)

		//Cria as linhas do Layer
		oLayer:addLine( 'L1', 95, .F. )

		//Cria as colunas do Layer
		oLayer:addCollumn('C1L1',26,.F.,"L1") 
		oLayer:addCollumn('C2L1',74,.F.,"L1") 

		oLayer:AddWindow('C1L1','WIN_TPINF',STR0027,64,.F.,.F.,,'L1',) // Informações

		_cRight1Win:= oLayer:GetWinPanel('C1L1','WIN_TPINF', 'L1')
		
		If lMostraItem // Mostra Itens - Sim
			oLayer:AddWindow('C1L1','WIN_LEGEN',STR0012,35,.F.,.F.,,'L1',) // Legenda
			_cRight2Win:= oLayer:GetWinPanel('C1L1','WIN_LEGEN', 'L1')
		EndIf

		_cTopCol2  := oLayer:getColPanel('C2L1','L1')

		// Cria browse
		oListItens := MsBrGetDBase():new( 0, 0, 260, 170,,,, _cTopCol2,,,,,,,,,,,, .F.,, .T.,, .F.,,, )
		oListItens:Align := CONTROL_ALIGN_ALLCLIENT

		// Define vetor para a browse
		oListItens:setArray( aItensConf )
	
		// Cria colunas do browse
		oListItens:addColumn( TCColumn():new( STR0028 , { || aItensConf[oListItens:nAt,2] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Grupo
		oListItens:addColumn( TCColumn():new( STR0029 , { || aItensConf[oListItens:nAt,3] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Código do Item
		oListItens:addColumn( TCColumn():new( STR0030 , { || aItensConf[oListItens:nAt,4] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Descrição
		oListItens:addColumn( TCColumn():new( STR0034 , { || aItensConf[oListItens:nAt,9] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Locacao
		oListItens:addColumn( TCColumn():new( STR0035 , { || FG_AlinVlrs(Transform(aItensConf[oListItens:nAt,5],cPictQUANT)) },,,, "LEFT",, .F., .T.,,,, .F. ) ) // Qtd.Conferida
		
		If lAprovador
			oListItens:addColumn( TCColumn():new( STR0036 , { || FG_AlinVlrs(Transform(aItensConf[oListItens:nAt,6],cPictQUANT)) },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Qtd.Original
		EndIf

		If lMostraItem // Mostra Itens - Sim
			bColor := &("{|| aItensConf[oListItens:nAt,1] }")
			oListItens:SetBlkBackColor(bColor)

			oCorAmar := tBitmap():New(005, 005, 068, 010, 'BR_AMARELO' , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
			oSayAmar := tSay():New(005, 015, {|| STR0037 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item não conferido

			oCorAzul := tBitmap():New(015, 005, 078, 010, 'BR_AZUL', , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
			oSayAzul := tSay():New(015, 015, {|| STR0038 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item não existente no Volume

			oCorVerd := tBitmap():New(025, 005, 088, 010, 'BR_VERDE' , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
			oSayVerd := tSay():New(025, 015, {|| STR0039 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item conferido corretamente

			oCorVerm := tBitmap():New(035, 005, 088, 010, 'BR_VERMELHO' , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
			oSayVerm := tSay():New(035, 015, {|| STR0040 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Divergência na Conferência

		EndIf

		If !lVisualiza .and. !lAprovador
			oListItens:bLDblClick := { || lEditCell( aItensConf , oListItens , cPictQUANT , 5 ), OA3400361_QtdConferida(aItensConf[oListItens:nAt],aItensConf[oListItens:nAt,5],.t.)}
		EndIf

		oListItens:Refresh()

		nLinIni := 5

		If lMostraQtd // Mostra Qtde - Sim
			oSayQtd := tSay():New( nLinIni   , 005, {|| STR0041 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Quantidade
			oGetQtd := TGet():New( nLinIni+8, 005, { | u | If( PCount() == 0, nQtd, nQtd := u ) },_cRight1Win,060, 010, cPictQUANT ,{ || nQtd >= 0 },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nQtd",,,,)
			nLinIni += 27
		EndIf

		If lMostraCod
			oSayCod := tSay():New( nLinIni   , 005, {|| STR0042 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Codigo
			oGetCod := TGet():New( nLinIni+8, 005, { | u | If( PCount() == 0, cCod, cCod := u ) },_cRight1Win, 060, 010, "@!",{ || IIf(!Empty(cCod),(OA3400131_DigitacaoCodigo(),.f.),oListItens:SetFocus()) },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCod",,,,)
			nLinIni += 27
		EndIf

		oSayNf := tSay():New( nLinIni  , 005, {|| STR0032 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Volume
		oGetNf := TGet():New( nLinIni+8, 005, { || VM7->VM7_VOLUME },_cRight1Win, 080, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"cVolume",,,,)
		nLinIni += 27

		If lVisualiza
			oSaySta := tSay():New( nLinIni  , 005, {|| STR0043 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Status da Conferencia
			cStatConf := ""
			Do Case
				Case VM7->VM7_STATUS == "1"
					cStatConf := STR0007 // Pendente
				Case VM7->VM7_STATUS == "2"
					cStatConf := STR0044 // Parcial
				Case VM7->VM7_STATUS == "3"
					cStatConf := STR0045 // Finalizada
				Case VM7->VM7_STATUS == "4"
					cStatConf := STR0046 // Aprovada
				Case VM7->VM7_STATUS == "5"
					cStatConf := STR0047 // Reprovada
			EndCase
			oGetSta := TGet():New( nLinIni+8, 005, { || cStatConf },_cRight1Win, 080, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"cStatConf",,,,)
			nLinIni += 27
		EndIf

		cTexto := OA3400271_ObservacaoConferencia( VM7->VM7_CODIGO )

		oSayObs := tSay():New( nLinIni   , 005, {|| STR0048 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Observacao
		oGetObs := tMultiget():new( nLinIni+8, 005,{ || cTexto },_cRight1Win,160,050,,,,,,.T.,,,{|| .f. },,,.T.,,,,,.t.)
		nLinIni += 27

	oConfBarra:Activate( , , , .t. , , ,EnchoiceBar( oConfBarra, { || IIf( !lVisualiza .and. OA3400081_ConfirmarConferencia(cConferencia), oConfBarra:End() , oConfBarra:End() ) }, { || oConfBarra:End() }, ,aButtons, , , , , .F., .T. ) ) //ativa a janela criando uma enchoicebar

Return

/*/{Protheus.doc} OA3400071_LevantaItens

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400071_LevantaItens( cConferencia )

	Local cQuery := ""

	cQuery := "SELECT VM8.VM8_COD, VM8.VM8_QTCONF, VM8.VM8_QTORIG, R_E_C_N_O_ VM8RECNO "
	cQuery += "  FROM " + RetSqlName("VM8") + " VM8 "
	cQuery += " WHERE VM8.VM8_FILIAL = '" + xFilial("VM8") + "' "
	cQuery += "   AND VM8.VM8_CODVM7 = '" + cConferencia + "' "
	cQuery += "   AND VM8.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVM8"

	While !TMPVM8->(Eof())

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+TMPVM8->VM8_COD))

		SB5->(DbSetOrder(1))
		SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))

		Aadd(aItensVol,{ "",;
						SB1->B1_GRUPO,;
						SB1->B1_CODITE,;
						SB1->B1_DESC,;
						TMPVM8->VM8_QTCONF,;
						TMPVM8->VM8_QTORIG,;
						SB1->B1_CODBAR,;
						SB1->B1_COD,;
						FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
						TMPVM8->VM8RECNO;
					})

		OA3400351_StatusItem(aItensVol[Len(aItensVol)])

		TMPVM8->(DbSkip())

	EndDo

	TMPVM8->(dbCloseArea())

	If lMostraItem // Mostra Itens - Sim
		aItensConf := aClone(aItensVol)
	Else
		cQuery := "SELECT VM8.VM8_COD, VM8.VM8_QTCONF, VM8.VM8_QTORIG, R_E_C_N_O_ VM8RECNO "
		cQuery += "  FROM " + RetSqlName("VM8") + " VM8 "
		cQuery += " WHERE VM8.VM8_FILIAL = '" + xFilial("VM8") + "' "
		cQuery += "   AND VM8.VM8_CODVM7 = '" + cConferencia + "' "
		cQuery += "   AND VM8.VM8_QTCONF > 0 "
		cQuery += "   AND VM8.D_E_L_E_T_ = ' '"

		TcQuery cQuery New Alias "TMPVM8CONF"

		While !TMPVM8CONF->(Eof())

			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+TMPVM8CONF->VM8_COD))

			SB5->(DbSetOrder(1))
			SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))
			
			Aadd(aItensConf,{ "",;
							SB1->B1_GRUPO,;
							SB1->B1_CODITE,;
							SB1->B1_DESC,;
							TMPVM8CONF->VM8_QTCONF,;
							TMPVM8CONF->VM8_QTORIG,;
							SB1->B1_CODBAR,;
							SB1->B1_COD,;
							FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
							TMPVM8CONF->VM8RECNO;
						})

			OA3400351_StatusItem(aItensConf[Len(aItensConf)])

			TMPVM8CONF->(DbSkip())

		EndDo

		TMPVM8CONF->(dbCloseArea())

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
						0;
		})
	EndIf

Return

/*/{Protheus.doc} OA3400081_ConfirmarConferencia

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400081_ConfirmarConferencia(cNroConf)

	Local lRetorno   := .t.
	Local lAprovador := OM3900141_UsuarioAprovador()
	
	if lAprovador

		lRetorno := OA3400201_JaneladeAprovacao()

	Else
		If MsgNoYes(STR0049,STR0017) // Finaliza Conferencia? / Atencao

			VM7->(DbSeek(xfilial("VM7") + cNroConf ) )

			OA3400261_LimpaItensZerados( VM7->VM7_CODIGO )
			OA3400311_GravaConferenciaZerada( VM7->VM7_CODIGO )
			OA3400231_VerificaDivergencias( VM7->VM7_CODIGO )

			If lUtilAprova .or. VM7->VM7_DIVERG == "0"
				OA3400111_StatusConferencia( VM7->VM7_CODIGO , "3" )
			Else
				MsgStop(STR0050,STR0017) // Há itens com divergencia. Impossivel continuar. / Atencao
				lRetorno := .f.
			EndIf

			If VM7->VM7_DIVERG == "0" // NAO TEM DIVERGENCIA
				OA3400211_GravaObservacaoConferencia(STR0051+" "+Transform(dDataBase,"@D")+" "+left(time(),5)+" "+__CUSERID+"-"+left(Alltrim(UsrRetName(__CUSERID)),15)) // Aprovado automaticamente
				OA3400221_GravaConbar( VM7->VM7_VOLUME )
				OA3400111_StatusConferencia( VM7->VM7_CODIGO , "4" )
				If ExistFunc("OA3630011_Tempo_Total_Conferencia_Volume_Entrada")
					OA3630011_Tempo_Total_Conferencia_Volume_Entrada( 0 , VM7->VM7_VOLUME ) // 0=Finalizar o Tempo Total da Conferencia de Volume Entrada
				EndIf
				OA3400301_ChamaPEaposAprovReprov( "1" )
			Else // VM7->VM7_DIVERG == "1" // POSSUI DIVERGENCIA
				cEmailDiv := OA3400241_CorpoEmail( VM7->VM7_CODIGO )
				If !Empty(cEmailDiv)
					OA3400251_EMAIL( cEmailDiv , VM7->VM7_VOLUME , "0" )
				EndIf
			EndIf

		EndIf
	EndIf

Return lRetorno

/*/{Protheus.doc} OA3400091_GravaRegistroConferencia

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400091_GravaRegistroConferencia( cVolume , cTpOrigem )

	Local oModelVM7 := FWLoadModel( 'OFIA330' )
	Local lRetVM7	:= .f.
	Local cNroConf	:= ""
	Local nSequen   := 1
	Local cSequen   := ""

	Default cVolume := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	oModelVM7:SetOperation( MODEL_OPERATION_INSERT )

	lRetVM7 := oModelVM7:Activate()

	if lRetVM7

		oModelVM7:SetValue( "VM7MASTER", "VM7_VOLUME", cVolume )
		oModelVM7:SetValue( "VM7MASTER", "VM7_STATUS", "1" )

		oModelDet := oModelVM7:GetModel("VM8DETAIL")

		cQuery := "SELECT VCX.VCX_COD, SB2.B2_CM1, SUM(VCX.VCX_QTDITE) AS QTDE "
		cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
		cQuery += "  JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "    ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
		cQuery += "   AND SB1.B1_COD     = VCX.VCX_COD"
		cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
		cQuery += "  LEFT JOIN " + RetSqlName("SB2") + " SB2 "
		cQuery += "    ON SB2.B2_FILIAL  = '" + xFilial("SB2") + "'"
		cQuery += "   AND SB2.B2_COD     = VCX.VCX_COD"
		cQuery += "   AND SB2.B2_LOCAL   = SB1.B1_LOCPAD"
		cQuery += "   AND SB2.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "'"
		cQuery += "   AND VCX.VCX_VOLUME = '" + cVolume + "' "
		cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY VCX.VCX_COD, SB2.B2_CM1"

		TcQuery cQuery New Alias "TMPVCX"

		While !TMPVCX->(Eof())

			cSequen := StrZero( nSequen++ ,GetSX3Cache("VM8_SEQUEN","X3_TAMANHO") )

			oModelDet:AddLine()

			oModelDet:SetValue( "VM8_CODVM7", oModelVM7:GetValue( "VM7MASTER", "VM7_CODIGO") )
			oModelDet:SetValue( "VM8_SEQUEN", cSequen )
			oModelDet:SetValue( "VM8_COD"   , TMPVCX->VCX_COD )
			oModelDet:SetValue( "VM8_CUSPRO", TMPVCX->B2_CM1 )
			oModelDet:SetValue( "VM8_QTORIG", int(TMPVCX->QTDE) )

			TMPVCX->(DbSkip())
		EndDo

		TMPVCX->(dbCloseArea())

		If ( lRet := oModelVM7:VldData() )

			if ( lRet := oModelVM7:CommitData())
			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0052,"COMMITVM7") // Nao foi possivel incluir o(s) registro(s)
				Else
					Help("",1,"COMMITVM7",,STR0052,1,0) // Nao foi possivel incluir o(s) registro(s)
				EndIf
			EndIf

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0053,"VALIDVM7") // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
			Else
				Help("",1,"VALIDVM7",,STR0053,1,0) // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
			EndIf
		EndIf

		cNroConf := oModelVM7:GetValue("VM7MASTER","VM7_CODIGO")

		oModelVM7:DeActivate()

	Else
		If cTpOrigem == "2" // 2=Coletor de Dados
			VTAlert(STR0054,"ACTIVEVM7") // Nao foi possivel ativar o modelo de inclusão da tabela VM7
		Else
			Help("",1,"ACTIVEVM7",,STR0054,1,0) // Nao foi possivel ativar o modelo de inclusão da tabela VM7
		EndIf
	EndIf

	FreeObj(oModelVM7)

Return cNroConf

/*/{Protheus.doc} OA3400101_DuplicaConferencia

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400101_DuplicaConferencia( cConferencia, lComDiverg )

	Local lRetVM7   := .f.
	Local cNovaConf := ""
	Local oModelVM7 := FWLoadModel( 'OFIA330' )
	Local lAlterou  := .f.

	Default cConferencia := ""
	Default lComDiverg	:= .f.

	If VM7->( DbSeek( xFilial("VM7") + cConferencia ) )

		cNovaConf := OA3400091_GravaRegistroConferencia( VM7->VM7_VOLUME , "0" )

	EndIf

	If lComDiverg

		If VM7->( DbSeek( xFilial("VM7") + cNovaConf ) )

			oModelVM7:SetOperation( MODEL_OPERATION_UPDATE )

			lRetVM7 := oModelVM7:Activate()

			if lRetVM7
				
				oModelDet := oModelVM7:GetModel("VM8DETAIL")

				cQuery := "SELECT VM8.VM8_COD    , "
				cQuery += "       VM8.VM8_SEQUEN , "
				cQuery += "       VM8.VM8_QTCONF , "
				cQuery += "       VM8.VM8_DATINI , "
				cQuery += "       VM8.VM8_HORINI , "
				cQuery += "       VM8.VM8_DATFIN , "
				cQuery += "       VM8.VM8_HORFIN , "
				cQuery += "       VM8.VM8_USRCON   "
				cQuery += "  FROM " + RetSqlName("VM8") + " VM8 "
				cQuery += " WHERE VM8.VM8_FILIAL = '" + xFilial("VM8") + "' "
				cQuery += "   AND VM8.VM8_CODVM7 = '" + cConferencia + "' "
				cQuery += "   AND VM8.VM8_QTORIG = VM8.VM8_QTCONF "
				cQuery += "   AND VM8.D_E_L_E_T_ = ' ' "

				TcQuery cQuery New Alias "TMPVM8"

				While !TMPVM8->(Eof())

					lSeek := oModelDet:SeekLine({;
										{ "VM8_COD"		, TMPVM8->VM8_COD },;
										{ "VM8_SEQUEN"	, TMPVM8->VM8_SEQUEN };
									})

					If lSeek
						lAlterou := .t.
						oModelDet:SetValue( "VM8_QTCONF", TMPVM8->VM8_QTCONF )
						oModelDet:SetValue( "VM8_DATINI", stod(TMPVM8->VM8_DATINI) )
						oModelDet:SetValue( "VM8_HORINI", TMPVM8->VM8_HORINI )
						oModelDet:SetValue( "VM8_DATFIN", stod(TMPVM8->VM8_DATFIN) )
						oModelDet:SetValue( "VM8_HORFIN", TMPVM8->VM8_HORFIN )
						oModelDet:SetValue( "VM8_USRCON", TMPVM8->VM8_USRCON )
					EndIf

					TMPVM8->(DbSkip())

				EndDo

				TMPVM8->(dbCloseArea())

				If lAlterou
					If ( lRet := oModelVM7:VldData() )

						if ( lRet := oModelVM7:CommitData())
						Else
							Help("",1,"COMMITVM7",,STR0052+" "+oModelVM7:GetErrorMessage()[6],1,0) // Nao foi possivel incluir o(s) registro(s)
						EndIf

					Else
						Help("",1,"COMMITVM7",,STR0052,1,0) // Nao foi possivel incluir o(s) registro(s)
					EndIf

				Else
					Help("",1,"VALIDVM7",,STR0053,1,0) // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
				EndIf

				oModelVM7:DeActivate()

			Else
				Help("",1,"ACTIVEVM7",,STR0054,1,0) // Nao foi possivel ativar o modelo de inclusão da tabela VM7
			EndIf

		EndIf

	EndIf

	FreeObj(oModelVM7)

	If lAlterou
		OA3400111_StatusConferencia( cNovaConf , "2" ) // Grava o STATUS Parcial na Tabela de Historico
	EndIf

Return

/*/{Protheus.doc} OA3400111_StatusConferencia

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400111_StatusConferencia( cConferencia , cStatus, cTpOrigem )

	Local oModelVM7 := FWLoadModel( 'OFIA330' )
	Local lRetVM7	:= .f.
	Local cStatusRet:= ""
	Local lMudouStatus := .f.

	Default cConferencia := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	If VM7->( DbSeek( xFilial("VM7") + cConferencia ) )

		oModelVM7:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM7 := oModelVM7:Activate()

		if lRetVM7

			if cStatus <> oModelVM7:GetValue("VM7MASTER","VM7_STATUS")
				oModelVM7:SetValue( "VM7MASTER", "VM7_STATUS", cStatus )

				If oModelVM7:VldData()

					if oModelVM7:CommitData()
						lMudouStatus := .t.
					Else
						If cTpOrigem == "2" // 2=Coletor de Dados
							VTAlert(STR0055,"COMMITVM7") // Nao foi possivel gravar o(s) registro(s)
						Else
							Help("",1,"COMMITVM7",,STR0055,1,0) // Nao foi possivel gravar o(s) registro(s)
						EndIf
					EndIf

				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0053,"VALIDVM7") // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
					Else
						Help("",1,"VALIDVM7",,STR0053,1,0) // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
					EndIf
				EndIf

				cStatusRet := oModelVM7:GetValue("VM7MASTER","VM7_STATUS")

				oModelVM7:DeActivate()
			Else
				cStatusRet := oModelVM7:GetValue("VM7MASTER","VM7_STATUS")
			EndIf
		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0054,"ACTIVEVM7") // Nao foi possivel ativar o modelo de inclusão da tabela VM7
			Else
				Help("",1,"ACTIVEVM7",,STR0054,1,0) // Nao foi possivel ativar o modelo de inclusão da tabela VM7
			EndIf
		EndIf

	EndIf

	FreeObj(oModelVM7)

	If lMudouStatus
		If ExistBlock("OA340STA")
			ExecBlock("OA340STA",.f.,.f.,{ cConferencia , cStatus , cTpOrigem })
		EndIf
	EndIf

Return cStatusRet

/*/{Protheus.doc} OA3400121_ExisteConferencia

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400121_ExisteConferencia( cVolume , lSoValidos , cDesprConf )

	Local cQuery := ""
	Local cRetorno := ""

	Default lSoValidos := .f.
	Default cVolume    := ""
	Default cDesprConf := ""

	cQuery := "SELECT VM7.VM7_CODIGO "
	cQuery += "  FROM " + RetSqlName("VM7") + " VM7 "
	cQuery += " WHERE VM7.VM7_FILIAL = '" + xFilial("VM7") + "'"
	cQuery += "   AND VM7.VM7_VOLUME = '" + cVolume + "'"
	
	if !Empty(cDesprConf)
		cQuery += " AND VM7.VM7_CODIGO <> '" + cDesprConf + "'" // Despresa conferencia
	EndIf

	If lSoValidos
		cQuery += " AND VM7.VM7_STATUS IN ('1','2','3','4')"
	EndIf

	cQuery += " AND VM7.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VM7_CODIGO DESC"

	TcQuery cQuery New Alias "TMPVM7"

	If !TMPVM7->(Eof())
		cRetorno := TMPVM7->VM7_CODIGO
	EndIf

	TMPVM7->(dbCloseArea())

Return cRetorno

/*/{Protheus.doc} OA3400131_DigitacaoCodigo

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400131_DigitacaoCodigo()

	Local nPosItem  := 0
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
				nQtd := aProduto[2]
				If nQtd == 0 // Qtde por Embalagem Zerada
					nQtd := 1 // Somar Qtde 1 nos Bips
				EndIf
			EndIf
		Else
			cCodSB1 := PadR(cCod, GetSX3Cache("B1_COD","X3_TAMANHO"))
		EndIf

		If FG_POSSB1("cCodSB1","SB1->B1_COD","")

			nPosItem := OA3400141_BuscaItem(cCodSB1)

			If nPosItem > 0
				oListItens:SetArray(aItensConf)
				oListItens:nAt := nPosItem

				OA3400361_QtdConferida(aItensConf[nPosItem],nQtd)

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
			MsgStop(STR0056,STR0017) // Item não existente no Cadastro de Produtos / Atencao
		EndIf

	EndIf

	FreeObj(oPeca)

Return

/*/{Protheus.doc} OA3400141_BuscaItem

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400141_BuscaItem(cCodigo)

	Local nPosicao := 0
	Local cMIL0139 := GetNewPar("MV_MIL0139","0")

	Default cCodigo:= ""

	If !Empty(cCodigo)

		nPosicao := aScan(aItensConf,{|x| Alltrim(x[8]) == Alltrim(cCodigo) }) // CODIGO ( B1_COD )
		If nPosicao == 0
			nPosicao := aScan(aItensVol,{|x| Alltrim(x[8]) == Alltrim(cCodigo) }) // CODIGO ( B1_COD )
			If nPosicao == 0
				If ( cMIL0139 == "2" .or. ;
					( cMIL0139 == "1" .and. MsgYesNo(STR0057+". "+STR0058,STR0017) ) ) // Item não encontrado neste Volume de Entrada / Deseja incluir? / Atencao
					nPosicao := OA3400341_AdcionaItemVolume()
				ElseIf ( cMIL0139 == "0" )
					MsgStop(STR0057,STR0017) // Item não encontrado neste Volume de Entrada / Atencao
				EndIf
			Else
				nPosicao := OA3400331_AdicionaItemLista(nPosicao)
			EndIf
		EndIf

	EndIf

Return nPosicao

/*/{Protheus.doc} OA3400151_ColunaStatusNF

@author Andre Luis Almeida
@since 19/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400151_ColunaStatusNF()
	
	// Variável do Retorno
	Local cImgRPO := "BR_BRANCO"

	cAlSF1 := 'TABSF1'
	BeginSql alias cAlSF1
		SELECT
			SF1.R_E_C_N_O_ AS RECSF1 ,
			SF1.D_E_L_E_T_ AS DELSF1 ,
			SF1.F1_STATUS
		FROM
			%table:SF1% SF1
		WHERE
			SF1.F1_FILIAL  = %xfilial:SF1% AND
			SF1.F1_DOC     = %exp:TMPNVCX->TPN_NUMNFI% AND
			SF1.F1_SERIE   = %exp:TMPNVCX->TPN_SERNFI% AND
			SF1.F1_FORNECE = %exp:TMPNVCX->TPN_CODFOR% AND
			SF1.F1_LOJA    = %exp:TMPNVCX->TPN_LOJFOR%
		ORDER BY 1 DESC
	EndSql

	//-- Define Status do registro
	If (cAlSF1)->DELSF1 <> ' ' // F1 Deletado
		cImgRpo := "BR_VERMELHO"
	ElseIf (cAlSF1)->F1_STATUS <> ' '
		cImgRpo := "BR_VERDE"
	EndIf

	(cAlSF1)->(dbCloseArea())
	
Return cImgRPO

/*/{Protheus.doc} OA3400161_LegendaStatusNF

@author Andre Luis Almeida
@since 18/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400161_LegendaStatusNF()
	
	// Array das Legendas
	Local aLegenda := {	{"BR_BRANCO"	, STR0059 },; // Pré NF
						{"BR_VERDE"		, STR0060 },; // NF Confirmada (Classificada)
						{"BR_VERMELHO"	, STR0061 } } // NF Cancelada

	//-- Define Status do registro
	BrwLegenda(STR0062,STR0012,aLegenda )	// Status dos Volumes / Legenda
	
Return .T.

/*/{Protheus.doc} OA3400171_FiltraVolume

@author Andre Luis Almeida
@since 20/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400171_FiltraVolume( lMostraItem , lAprovador )

	Local aParamBox := {}
	Local aRetParam := {}

	SetKey(VK_F12,Nil)

	aAdd(aParamBox,{1,STR0063,nFiltDia,"@E 9999","Positivo()",""   ,"",50,.F.}) // Dias a Retroagir
	aAdd(aParamBox,{1,STR0016,cFiltFor,"@!"     ,"","SA2","",50,.F.}) // Fornecedor
	aAdd(aParamBox,{1,STR0064,cFiltLoj,"@!","",""   ,"",25,.F.}) // Loja
	aAdd(aParamBox,{1,STR0032,cFiltVol,"@!"     ,"","","",80,.F.}) // Volume
	If lMostraItem //Mostra item - Sim
		aAdd(aParamBox,{1,STR0028,cFiltGrp,"@!","Vazio() .OR. FG_SEEK('SBM','MV_PAR05',1,.F.)","SBM"   ,"",40,.F.}) // Grupo
		aAdd(aParamBox,{1,STR0029,cFiltCod,"@!","Vazio() .OR. FG_POSSB1('MV_PAR06','SB1->B1_CODITE','MV_PAR05')","B01P04"   ,"",90,.F.}) // Código do Item
	EndIf

	If ParamBox(aParamBox,"",@aRetParam,,,,,,,,.f.)
		
		nFiltDia := aRetParam[1]
		cFiltFor := aRetParam[2]
		cFiltLoj := aRetParam[3]
		cFiltVol := aRetParam[4]
		If lMostraItem //Mostra item - Sim
			cFiltGrp := aRetParam[5]
			cFiltCod := aRetParam[6]
		EndIf

		oTabTMPV:CloseTable()
		oTabTMPN:CloseTable()
		If lCriouTabIt // closetable se criou a tabela temporaria dos Itens
			oTabTMPI:CloseTable()
		EndIf
		Processa( {|| OA3400381_CriaTabelasTemporarias( lMostraItem , lAprovador ) }) // Cria NOVAMENTE Tabelas Temporarias com Dados

		oBrwTMPV:DeleteFilter("data")
		oBrwTMPV:DeleteFilter("volume")
		oBrwTMPV:DeleteFilter("fornece")
		oBrwTMPV:AddFilter( STR0065 , "@ TPV_DATA >='" + DtoS(dDatabase - nFiltDia) + "'",.t.,.t.,,,,"data") // Data do Volume
		If !Empty(cFiltVol)
			oBrwTMPV:AddFilter( STR0032 , "@ TPV_VOLUME ='" + cFiltVol + "'",.t.,.t.,,,,"volume") // Volume
		EndIf
		If !Empty(cFiltFor) .and. !Empty(cFiltLoj)
			oBrwTMPV:AddFilter( STR0016+"/"+STR0064 ,"@ TPV_CODFOR='" + cFiltFor + "' AND TPV_LOJFOR='" + cFiltLoj + "'",.t.,.t.,,,,"fornece") // Fornecedor/Loja
		ElseIf !Empty(cFiltFor)
			oBrwTMPV:AddFilter( STR0016 ,"@ TPV_CODFOR='" + cFiltFor + "'",.t.,.t.,,,,"fornece") // Fornecedor
		ElseIf !Empty(cFiltLoj)
			oBrwTMPV:AddFilter( STR0064 ,"@ TPV_LOJFOR='" + cFiltLoj + "'",.t.,.t.,,,,"fornece") // Loja
		EndIf
		oBrwTMPV:SetFocus()
		oBrwTMPV:ExecuteFilter(.t.)
		If lMostraItem //Mostra item - Sim
			oBrwTMPI:ExecuteFilter(.t.)
		EndIf
		oBrwTMPN:ExecuteFilter(.t.)
		
	EndIf

	SetKey(VK_F12,{ || OA3400171_FiltraVolume( lMostraItem , lAprovador ) })

Return

/*/{Protheus.doc} OA3400331_AdicionaItemLista

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static function OA3400331_AdicionaItemLista(nPosVol)

	Local nPosItem := 0

	Default nPosVol := 0

	//É necessario que esteja posicionado no SB1

	SB5->(DbSetOrder(1))
	SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))

	If nPosVol == 0
		Aadd(aItensConf,{	RGB(30,144,255),;
							SB1->B1_GRUPO,;
							SB1->B1_CODITE,;
							SB1->B1_DESC,;
							0,;
							0,;
							SB1->B1_CODBAR,;
							SB1->B1_COD,;
							FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
							0;
						})
	Else
		Aadd(aItensConf,aItensVol[nPosVol])
	EndIf

	nPosItem := Len(aItensConf)

Return nPosItem

/*/{Protheus.doc} OA3400341_AdcionaItemVolume

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400341_AdcionaItemVolume(cCodigo)

	Local nPosItem := 0

	SB5->(DbSetOrder(1))
	SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))

	nRecVM8 := OA3400191_AdicionaRegistroVM8( Len(aItensVol)+ 1 )

	Aadd(aItensVol,{RGB(30,144,255),;
					SB1->B1_GRUPO,;
					SB1->B1_CODITE,;
					SB1->B1_DESC,;
					0,;
					0,;
					SB1->B1_CODBAR,;
					SB1->B1_COD,;
					FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
					nRecVM8;
				})

	nPosItem := Len(aItensVol)

	nPosItem := OA3400331_AdicionaItemLista(nPosItem)

Return nPosItem

/*/{Protheus.doc} OA3400351_StatusItem

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400351_StatusItem(aVetItem)

	//aVetItem[1] - Cor da linha
	//aVetItem[5] - VM8_QTCONF
	//aVetItem[6] - VM8_QTORIG

	Do Case
		Case aVetItem[6] == 0 // Item nao existia no Volume
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

/*/{Protheus.doc} OA3400361_QtdConferida

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400361_QtdConferida(aItemConf,nQtdConf,lDigitado)

	Default lDigitado := .f.

	nPosVol := aScan(aItensVol,{ |x| x[10] == aItemConf[10] } )
	If nPosVol > 0
		If nQtdConf < 0
			nQtdConf := 0
		EndIf
		If nQtdConf == 0 .or. lDigitado
			aItemConf[5] := nQtdConf
		Else
			aItemConf[5] += nQtdConf
		EndIf
		aItensVol[nPosVol,5] := aItemConf[5]
		OA3400281_GravaQtdConferida( aItemConf[10] , aItemConf[5] )
		OA3400351_StatusItem(aItemConf)
		OA3400111_StatusConferencia( VM7->VM7_CODIGO , "2" )
	EndIf

Return .t.

/*/{Protheus.doc} OA3400181_FiltroBrowseTMPV

@author Andre Luis Almeida
@since 19/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400181_FiltroBrowseTMPV( lAprovador )
Local cFNome   := ""
Local cFStat   := ""
Local nCntFor  := 0
If lAprovador
	cFNome := STR0066 // Conferencias Pendentes
	cFStat := "@ ( EXISTS ( "
	cFStat += "SELECT VM7.VM7_VOLUME "
	cFStat += "  FROM " + RetSqlName("VM7") + " VM7 "
	cFStat += " WHERE VM7.VM7_FILIAL ='" + xFilial("VM7") + "' "
	cFStat += "   AND VM7.VM7_STATUS = '1' "
	cFStat += "   AND VM7.VM7_VOLUME = TPV_VOLUME "
	cFStat += "   AND VM7.D_E_L_E_T_ = ' ') "
	cFStat += "OR NOT EXISTS ( "
	cFStat += "SELECT VM7.VM7_VOLUME "
	cFStat += "  FROM " + RetSqlName("VM7") + " VM7 "
	cFStat += " WHERE VM7.VM7_FILIAL ='" + xFilial("VM7") + "' "
	cFStat += "   AND VM7.VM7_VOLUME = TPV_VOLUME "
	cFStat += "   AND VM7.D_E_L_E_T_ = ' ' ) )"
	oBrwTMPV:AddFilter(cFNome,cFStat,.f.,.f.,,,,"status1")
	For nCntFor := 2 to 5 // Criar Filtros por STATUS
		cFStat := "@ EXISTS ( "
		cFStat += "SELECT VM7.VM7_VOLUME "
		cFStat += "  FROM " + RetSqlName("VM7") + " VM7 "
		cFStat += " WHERE VM7.VM7_FILIAL ='" + xFilial("VM7") + "' "
		cFStat += "   AND VM7.VM7_STATUS = '"+strzero(nCntFor,1)+"' "
		cFStat += "   AND VM7.VM7_VOLUME = TPV_VOLUME "
		cFStat += "   AND VM7.D_E_L_E_T_ = ' ')"
		cFNome := ""
		Do Case
			Case nCntFor == 2
				cFNome := STR0067 // Conferencias Parciais
			Case nCntFor == 3
				cFNome := STR0068 // Conferencias Finalizadas
			Case nCntFor == 4
				cFNome := STR0069 // Conferencias Aprovadas
			Case nCntFor == 5
				cFNome := STR0070 // Conferencias Reprovadas
		EndCase
		oBrwTMPV:AddFilter(cFNome,cFStat,.f.,.f.,,,,"status"+strzero(nCntFor,1))
	Next
	cFNome := STR0071 // Conferencias Sem Divergencias
	cFStat := "@ ( EXISTS ( "
	cFStat += "SELECT VM7.VM7_VOLUME "
	cFStat += "  FROM " + RetSqlName("VM7") + " VM7 "
	cFStat += " WHERE VM7.VM7_FILIAL ='" + xFilial("VM7") + "' "
	cFStat += "   AND VM7.VM7_DIVERG <> '1' "
	cFStat += "   AND VM7.VM7_VOLUME = TPV_VOLUME "
	cFStat += "   AND VM7.D_E_L_E_T_ = ' ') "
	cFStat += "OR NOT EXISTS ( "
	cFStat += "SELECT VM7.VM7_VOLUME "
	cFStat += "  FROM " + RetSqlName("VM7") + " VM7 "
	cFStat += " WHERE VM7.VM7_FILIAL ='" + xFilial("VM7") + "' "
	cFStat += "   AND VM7.VM7_VOLUME = TPV_VOLUME "
	cFStat += "   AND VM7.D_E_L_E_T_ = ' ' ) )"
	oBrwTMPV:AddFilter(cFNome,cFStat,.f.,.f.,,,,"semdiverg")
	cFNome := STR0072 // Conferencias Com Divergencias
	cFStat := "@ EXISTS ( "
	cFStat += "SELECT VM7.VM7_VOLUME "
	cFStat += "  FROM " + RetSqlName("VM7") + " VM7 "
	cFStat += " WHERE VM7.VM7_FILIAL ='" + xFilial("VM7") + "' "
	cFStat += "   AND VM7.VM7_DIVERG = '1' "
	cFStat += "   AND VM7.VM7_VOLUME = TPV_VOLUME "
	cFStat += "   AND VM7.D_E_L_E_T_ = ' ') "
	oBrwTMPV:AddFilter(cFNome,cFStat,.f.,.f.,,,,"comdiverg")
EndIf
oBrwTMPV:AddFilter( STR0065 , "@ TPV_DATA >='" + DtoS(dDatabase - nFiltDia ) + "'",.t.,.t.,,,,"data") // Data do Volume
Return

/*/{Protheus.doc} OA3400191_AdicionaRegistroVM8

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400191_AdicionaRegistroVM8( nSequen, cTpOrigem )

	Local oModelVM7 := FWLoadModel( 'OFIA330' )
	Local cRecVM8 := 0
	Local cSequen := ""
	Local lSeek := .f.
	
	Default nSequen := 1
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	oModelVM7:SetOperation( MODEL_OPERATION_UPDATE )
	lRetVM7 := oModelVM7:Activate()

	if lRetVM7

		cSequen := StrZero( nSequen ,GetSX3Cache("VM8_SEQUEN","X3_TAMANHO") )

		SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))

		oModelDet := oModelVM7:GetModel("VM8DETAIL")
		
		oModelDet:AddLine()

		oModelDet:SetValue( "VM8_CODVM7", VM7->VM7_CODIGO )
		oModelDet:SetValue( "VM8_SEQUEN", cSequen )
		oModelDet:SetValue( "VM8_COD"	, SB1->B1_COD )
		oModelDet:SetValue( "VM8_CUSPRO", SB2->B2_CM1 )
		oModelDet:SetValue( "VM8_QTORIG", 0 )

		If ( lRet := oModelVM7:VldData() )

			if ( lRet := oModelVM7:CommitData())
			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0052,"COMMITVM7") // Nao foi possivel incluir o(s) registro(s)
				Else
					Help("",1,"COMMITVM7",,STR0052,1,0) // Nao foi possivel incluir o(s) registro(s)
				Endif
			EndIf

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0053,"VALIDVM7") // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
			Else
				Help("",1,"VALIDVM7",,STR0053,1,0) // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
			Endif
		EndIf
		oModelVM7:DeActivate()

		oModelVM7:Activate()
		oModelDet := oModelVM7:GetModel("VM8DETAIL")
		lSeek := oModelDet:SeekLine({;
								{ "VM8_CODVQ0"	, VM7->VM7_CODIGO },;
								{ "VM8_SEQUEN"	, cSequen };
							})

		If lSeek
			cRecVM8 := oModelDet:GETDATAID()
		EndIf

		oModelVM7:DeActivate()

	Else
		If cTpOrigem == "2" // 2=Coletor de Dados
			VTAlert(STR0054,"ACTIVEVM7") // Nao foi possivel ativar o modelo de inclusão da tabela VM7
		Else
			Help("",1,"ACTIVEVM7",,STR0054,1,0) // Nao foi possivel ativar o modelo de inclusão da tabela VM7
		Endif
	EndIf

	FreeObj(oModelVM7)

Return cRecVM8

/*/{Protheus.doc} OA3400201_JaneladeAprovacao

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static Function OA3400201_JaneladeAprovacao()

Local cMemoObs   := ""
Local nOpcao     := 0
Local lRetorno   := .t.
Local lTemDiverg := VM7->VM7_DIVERG == "1"
Local cAprRepr   := "0"
Local nCntFor    := 0
Local aNFsVol    := OA3400051_NFsporVolume( VM7->VM7_VOLUME , .f. )

SF1->(DbSetOrder(1))
For nCntFor := 1 to len(aNFsVol)
	If SF1->(DbSeek(xFilial("SF1")+aNFsVol[nCntFor,1]+aNFsVol[nCntFor,2]+aNFsVol[nCntFor,3]+aNFsVol[nCntFor,4])) .and. SF1->F1_STATUS <> ' ' // NF ja Confirmada (Classificada)
		MsgStop(STR0073+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Existe NF dentro deste Volume que já foi Confirmada (Classificada). Impossível continuar.
				STR0015+": "+aNFsVol[nCntFor,1]+"-"+aNFsVol[nCntFor,2]+CHR(13)+CHR(10)+; // NF
				STR0016+": "+aNFsVol[nCntFor,3]+"-"+aNFsVol[nCntFor,4],STR0017) // Fornecedor / Atencao
		Return .f.
	EndIf
Next

oDlgOpcoes := MSDialog():New( 0, 0, 230, 620, STR0001, , , , , , , , , .T., , , , .F. ) // Conferência de Entrada por Volume

If lTemDiverg
	oBotaoApr := tButton():New(10,200,STR0074,oDlgOpcoes, { || nOpcao := 1 , oDlgOpcoes:End() } , 100 , 20 ,,,,.T.,,,,{ || .t. }) // Aprovar Conferência com Divergencias
	oBotaoRjD := tButton():New(10,010,STR0075,oDlgOpcoes, { || nOpcao := 2 , oDlgOpcoes:End() } ,  90 , 20 ,,,,.T.,,,,{ || .t. }) // Re-Conferir Itens Divergentes
	oBotaoRjT := tButton():New(10,105,STR0076,oDlgOpcoes, { || nOpcao := 3 , oDlgOpcoes:End() } ,  90 , 20 ,,,,.T.,,,,{ || .t. }) // Re-Conferir Todos Itens
Else
	oBotaoApr := tButton():New(10,010,STR0077,oDlgOpcoes, { || nOpcao := 1 , oDlgOpcoes:End() } , 290 , 20 ,,,,.T.,,,,{ || .t. }) // Aprovar Conferência
EndIf
oGetObs := tMultiget():new( 050, 015,{ | u | if( pCount() > 0, cMemoObs := u, cMemoObs ) },oDlgOpcoes,280,050,,,,,,.T.,,,,,,.F.,,,,,.t.,"Observação",1) // Observação

oDlgOpcoes:Activate( , , , .t. , , , , ,, , , , , , ) //ativa a janela criando uma enchoicebar

If !Empty(cMemoObs)
	cMemoObs := Alltrim(cMemoObs)+" - "+Transform(dDataBase,"@D")+" "+left(time(),5)+" "+__CUSERID+"-"+left(Alltrim(UsrRetName(__CUSERID)),15)
EndIf

Do Case 
	Case nOpcao == 1
		OA3400211_GravaObservacaoConferencia(cMemoObs)
		OA3400111_StatusConferencia( VM7->VM7_CODIGO , "4" )
		If lTemDiverg
			OA3400391_GravaQtdDivergente( VM7->VM7_CODIGO )
		EndIf
		If ExistFunc("OA3630011_Tempo_Total_Conferencia_Volume_Entrada")
			OA3630011_Tempo_Total_Conferencia_Volume_Entrada( 0 , VM7->VM7_VOLUME ) // 0=Finalizar o Tempo Total da Conferencia de Volume Entrada
		EndIf
		cAprRepr := "1"
	Case nOpcao == 2
		OA3400211_GravaObservacaoConferencia(cMemoObs)
		OA3400111_StatusConferencia( VM7->VM7_CODIGO , "5" )
		OA3400101_DuplicaConferencia( VM7->VM7_CODIGO , .t. )
		cAprRepr := "2"
	Case nOpcao == 3
		OA3400211_GravaObservacaoConferencia(cMemoObs)
		OA3400111_StatusConferencia( VM7->VM7_CODIGO , "5" )
		OA3400101_DuplicaConferencia( VM7->VM7_CODIGO )
		cAprRepr := "2"
	Otherwise
		lRetorno := .f.
EndCase

If cAprRepr <> "0"
	OA3400301_ChamaPEaposAprovReprov( cAprRepr )
EndIf

Return lRetorno


/*/{Protheus.doc} OA3400211_GravaObservacaoConferencia

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400211_GravaObservacaoConferencia( cObserv , cTpOrigem )

	Local oModelVM7 := FWLoadModel( 'OFIA330' )
	Local lRetVM7	:= .f.

	Default cObserv := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	oModelVM7:SetOperation( MODEL_OPERATION_UPDATE )

	lRetVM7 := oModelVM7:Activate()

	if lRetVM7

		oModelVM7:SetValue( "VM7MASTER", "VM7_OBSERV", cObserv )

		If ( lRet := oModelVM7:VldData() )

			if ( lRet := oModelVM7:CommitData())
			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0055,"COMMITVM7") // Nao foi possivel gravar o(s) registro(s)
				Else
					Help("",1,"COMMITVM7",,STR0055,1,0) // Nao foi possivel gravar o(s) registro(s)
				EndIf
			EndIf

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0053,"VALIDVM7") // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
			Else
				Help("",1,"VALIDVM7",,STR0053,1,0) // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
			EndIf
		EndIf

		oModelVM7:DeActivate()

	Else
		If cTpOrigem == "2" // 2=Coletor de Dados
			VTAlert(STR0054,"ACTIVEVM7") // Nao foi possivel ativar o modelo de inclusão da tabela VM7
		Else
			Help("",1,"ACTIVEVM7",,STR0054,1,0) // Nao foi possivel ativar o modelo de inclusão da tabela VM7
		EndIf
	EndIf

	FreeObj(oModelVM7)

Return

/*/{Protheus.doc} OA3400221_GravaConbar

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400221_GravaConbar( cVolume )

	DbSelectArea("SD1")
	cQuery := "SELECT SD1.R_E_C_N_O_ AS SD1REC "
	cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
	cQuery += "  JOIN " + RetSqlName("SD1") + " SD1 "
	cQuery += "    ON SD1.D1_FILIAL  = '" + xFilial("SD1") + "'"
	cQuery += "   AND SD1.D1_DOC     = VCX.VCX_DOC"
	cQuery += "   AND SD1.D1_SERIE   = VCX.VCX_SERIE"
	cQuery += "   AND SD1.D1_FORNECE = VCX.VCX_FORNEC"
	cQuery += "   AND SD1.D1_LOJA    = VCX.VCX_LOJA"
	cQuery += "   AND SD1.D1_COD     = VCX.VCX_COD"
	cQuery += "   AND SD1.D1_ITEM    = VCX.VCX_ITEM"
	cQuery += "   AND SD1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("SD1") + "'"
	cQuery += "   AND VCX.VCX_VOLUME = '" + cVolume + "'"
	cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
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

/*/{Protheus.doc} OA3400231_VerificaDivergencias

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Function OA3400231_VerificaDivergencias( cConferencia , cTpOrigem )

	Local cQuery := ""
	Local oModelVM7 := FWLoadModel( 'OFIA330' )
	Local lRetVM7	:= .f.

	Default cConferencia := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	cQuery := "SELECT COUNT(VM8.VM8_SEQUEN) AS QTDE "
	cQuery += "  FROM " + RetSqlName("VM8") + " VM8 "
	cQuery += " WHERE VM8.VM8_FILIAL = '" + xFilial("VM8") + "'"
	cQuery += "   AND VM8.VM8_CODVM7 = '" + cConferencia + "' "
	cQuery += "   AND VM8.VM8_QTORIG <> VM8.VM8_QTCONF "
	cQuery += "   AND VM8.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPVM8"

	If !TMPVM8->(Eof())

		VM7->(DbSeek(xFilial("VM7") + cConferencia))

		oModelVM7:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM7 := oModelVM7:Activate()

		if lRetVM7

			If TMPVM8->(QTDE) > 0
				oModelVM7:SetValue( "VM7MASTER", "VM7_DIVERG", "1" ) // Com Divergencia
			Else
				oModelVM7:SetValue( "VM7MASTER", "VM7_DIVERG", "0" ) // Sem Divergencia
			EndIf

			If ( lRet := oModelVM7:VldData() )

				if ( lRet := oModelVM7:CommitData())
				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0055,"COMMITVM7") // Nao foi possivel gravar o(s) registro(s)
					Else
						Help("",1,"COMMITVM7",,STR0055,1,0) // Nao foi possivel gravar o(s) registro(s)
					EndIf
				EndIf

			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0053,"VALIDVM7") // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
				Else
					Help("",1,"VALIDVM7",,STR0053,1,0) // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
				EndIf
			EndIf

			oModelVM7:DeActivate()

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0054,"ACTIVEVM7") // Nao foi possivel ativar o modelo de inclusão da tabela VM7
			Else
				Help("",1,"ACTIVEVM7",,STR0054,1,0) // Nao foi possivel ativar o modelo de inclusão da tabela VM7
			EndIf
		EndIf

	EndIf

	TMPVM8->(dbCloseArea())

	FreeObj(oModelVM7)

Return

/*/{Protheus.doc} OA3400241_CorpoEmail

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
@return ${return}, ${return_description}
/*/
Static function OA3400241_CorpoEmail( cConferencia )

	Local cQuery := ""
	Local cCorpoEmail := ""

	Default cConferencia := ""

	cQuery := "SELECT VM8.VM8_COD , VM8.VM8_QTCONF , VM8.VM8_QTORIG , VM8.VM8_USRCON , VAI.VAI_NOMTEC "
	cQuery += "  FROM " + RetSqlName("VM8") + " VM8 "
	cQuery += "  JOIN " + RetSqlName("VAI") + " VAI ON ( VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODUSR=VM8.VM8_USRCON AND VAI.D_E_L_E_T_=' ' ) "
	cQuery += " WHERE VM8.VM8_FILIAL = '" + xFilial("VM8") + "' "
	cQuery += "   AND VM8.VM8_CODVM7 = '" + cConferencia + "' "
	cQuery += "   AND VM8.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVM8"

	While !TMPVM8->(Eof())

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+TMPVM8->VM8_COD))

		cCorpoEmail += "<tr>"
		cCorpoEmail += "<td width=25%><font size=2 face='verdana,arial' Color=#0000cc>"+SB1->B1_GRUPO+" "+SB1->B1_CODITE+"</font></td>"
		cCorpoEmail += "<td width=40%><font size=2 face='verdana,arial' Color=#0000cc>"+SB1->B1_DESC+"</font></td>"
		cCorpoEmail += "<td width=35%><font size=2 face='verdana,arial' Color="
		If TMPVM8->VM8_QTCONF <> TMPVM8->VM8_QTORIG
			If TMPVM8->VM8_QTORIG == 0
				cCorpoEmail += "red>"+STR0038 // Item não existente no Volume
			Else
				cCorpoEmail += "red>"+STR0078 // Item com divergencia
				cCorpoEmail += " "+STR0097+" "+Alltrim(Transform(TMPVM8->VM8_QTORIG,VM8->(X3PICTURE("VM8_QTORIG")))) // Qtd.NF:
				cCorpoEmail += " - "+STR0098+" "+Alltrim(Transform(TMPVM8->VM8_QTCONF,VM8->(X3PICTURE("VM8_QTCONF")))) // Qtd.Conf.:
			EndIf
		Else
			cCorpoEmail += "#0000cc>"+STR0079 // Ok
		EndIf
		cCorpoEmail += " - "+TMPVM8->VM8_USRCON+" "+Alltrim(TMPVM8->VAI_NOMTEC)
		cCorpoEmail += " </font></td>"
		cCorpoEmail += "</tr>"

		TMPVM8->(DbSkip())

	EndDo
	TMPVM8->(dbCloseArea())

Return cCorpoEmail

/*/{Protheus.doc} OA3400251_EMAIL
Enviar EMAIL quando ha divergencia na Conferencia - funcao chamada pelo OFIA340 e pelo Coletor de Dados

@author Andre Luis Almeida
@since 20/12/2016
@version undefined
@param cEmailDiv, caracter, Itens com Divergencia
@param cVolume, caracter, Volume
@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
/*/
Function OA3400251_EMAIL( cEmailDiv , cVolume , cTpOrigem )
Local lOk := .f., lSendOK := .f.
Local cError := ""
Local cMailConta := GETMV("MV_EMCONTA") // Usuario/e-mail de envio
Local cMailServer:= GETMV("MV_RELSERV") // Server de envio
Local cMailSenha := GETMV("MV_EMSENHA") // Senha e-mail de envio
Local lAutentica := GetMv("MV_RELAUTH",,.f.)          // Determina se o Servidor de E-mail necessita de Autenticacao
Local cUserAut   := Alltrim(GetMv("MV_RELAUSR",," ")) // Usuario para Autenticacao no Servidor de E-mail
Local cPassAut   := Alltrim(GetMv("MV_RELAPSW",," ")) // Senha para Autenticacao no Servidor de E-mail
Local cEmail	 := GetNewPar("MV_MIL0092","") 		  // E-mail destinatario
Private cTitulo  := STR0080 // Divergencia na Conferencia de Itens de Entrada
Private cMensagem := ""
Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
If !Empty(cEmail)
	If ExistBlock("OA340MAI") // Ponto de Entrada para formatacao do email
		ExecBlock("OA340MAI",.f.,.f.,{ cEmailDiv , cVolume }) // Parametro --> Detalhes dos Itens com divergencia na Conferencia
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
		cMensagem+= "<td width=20%><font size=3 face='verdana,arial' Color=black>"+STR0032+":"+"</font></td>" // Volume
		cMensagem+= "<td width=80%><font size=3 face='verdana,arial' Color=#0000cc><b>"+cVolume+"</b></font></td>"
		cMensagem+= "</tr></table><br>"
		cMensagem+= "<table border=0 width=90%>"
		cMensagem+= "<tr>"
		cMensagem+= "<td width=25%><font size=3 face='verdana,arial' Color=black>"+STR0031+"</font></td>" // Item
		cMensagem+= "<td width=50%><font size=3 face='verdana,arial' Color=black>"+STR0030+"</font></td>" // Descricao
		cMensagem+= "<td width=25%><font size=3 face='verdana,arial' Color=black>"+STR0033+"</font></td>" // Tipo
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
						VTAlert(STR0081,STR0017) // Erro no envio de e-mail.
					Else
						MsgStop(STR0081,STR0017) // Erro no envio de e-mail.
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
						VTAlert(STR0081,STR0017) //  Erro no envio de e-mail.
					Else
						MsgStop(STR0081,STR0017) // Erro no envio de e-mail.
					EndIf
				EndIf
				// Desconecta com o servidor de e-mails
				DISCONNECT SMTP SERVER
			EndIf
		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0082,STR0017) // Nao foi possivel conectar no servidor de e-mail.
			Else
				MsgStop(STR0082+" "+chr(13)+chr(10)+cMailServer,STR0017) // Nao foi possivel conectar no servidor de e-mail.
			EndIf
		EndIf
	EndIf
EndIf
Return(.t.)

/*/{Protheus.doc} OA3400261_LimpaItensZerados
Limpa Itens Zerados ( VM8_QTCONF = 0 ) que foram incluidos manualmente ( VM8_QTORIG = 0 )

@author Andre Luis Almeida
@since 20/12/2016
@version undefined
@param cEmailDiv, caracter, Itens com Divergencia
@param cNrNF, caracter, Nro da NF
@param cForn, caracter, Fornecedor
@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
/*/
Function OA3400261_LimpaItensZerados( cConferencia, cTpOrigem )

	Local cQuery      := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	If cTpOrigem == "0" .or. cTpOrigem == "1" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) )
		OA3400291_LimpaLinhaBranca()
	EndIf

	VM7->(DbSeek(xFilial("VM7") + cConferencia))

	cQuery := "SELECT VM8.R_E_C_N_O_ AS VM8RECNO "
	cQuery += "  FROM " + RetSqlName("VM8") + " VM8 "
	cQuery += " WHERE VM8.VM8_FILIAL = '" + xFilial("VM8") + "'"
	cQuery += "   AND VM8.VM8_CODVM7 = '" + cConferencia + "' "
	cQuery += "   AND VM8.VM8_QTORIG = 0 "
	cQuery += "   AND VM8.VM8_QTCONF = 0 "
	cQuery += "   AND VM8.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPVM8"

	While !TMPVM8->(Eof())

		VM8->(DbGoTo(TMPVM8->VM8RECNO))

		RecLock("VM8",.F.,.T.)
		DbDelete()
		MsUnlock()
		
		TMPVM8->(DbSkip())

	EndDo
	TMPVM8->(dbCloseArea())
	DbSelectArea("VM7")

Return

/*/{Protheus.doc} OA3400271_ObservacaoConferencia
Observacao da Conferencia

@author Andre Luis Almeida
@since 13/08/2021
@version undefined
@param cConferencia, caracter, Codigo da Conferencia
/*/
Function OA3400271_ObservacaoConferencia( cConferencia )
	
	Local cRetorno := " "
	Local cVolume  := ""
	
	VM7->(DbSeek(xFilial("VM7") + cConferencia ))

	If VM7->VM7_STATUS $ "4/5"
		cRetorno := VM7->VM7_OBSERV
	Else

		cVolume := VM7->VM7_VOLUME

		cConfAnt := OA3400121_ExisteConferencia( cVolume , .f. , cConferencia )
		If !Empty(cConfAnt)

			VM7->(DbSeek(xFilial("VM7") + cConfAnt ))
			cRetorno := STR0083 + Chr(13) + Chr(10) + VM7->VM7_OBSERV // Observação da Rejeição

			VM7->(DbSeek(xFilial("VM7") + cConferencia ))

		EndIf

	EndIf

Return cRetorno

/*/{Protheus.doc} OA3400281_GravaQtdConferida
Gravar Quantidade Conferida

@author Andre Luis Almeida
@since 13/08/2021
@version undefined
@param nRecVM8, numerico, RecNo VM8
@param nQtdConf, umerico, Qunatidade
@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
/*/
Function OA3400281_GravaQtdConferida( nRecVM8 , nQtdConf, cTpOrigem)

	Local oModelVM7 := FWLoadModel( 'OFIA330' )

	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
	Default nRecVM8 := 0

	If nRecVM8 > 0

		oModelVM7:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM7 := oModelVM7:Activate()

		if lRetVM7

			oModelDet := oModelVM7:GetModel("VM8DETAIL")
			oModelDet:GoToDataID(nRecVM8)
			oModelDet:SetValue( "VM8_QTCONF", nQtdConf )

			If Empty(oModelDet:GetValue( "VM8_DATINI"))
				oModelDet:SetValue( "VM8_DATINI", dDataBase )
				oModelDet:SetValue( "VM8_HORINI", Time() )
				oModelDet:SetValue( "VM8_USRCON", __cUserID )
			EndIf
			oModelDet:SetValue( "VM8_DATFIN", dDataBase )
			oModelDet:SetValue( "VM8_HORFIN", Time() )

			If ( lRet := oModelVM7:VldData() )

				if ( lRet := oModelVM7:CommitData())
				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0055,"COMMITVM7") // Nao foi possivel gravar o(s) registro(s)
					Else
						Help("",1,"COMMITVM7",,STR0055,1,0) // Nao foi possivel gravar o(s) registro(s)
					EndIf
				EndIf

			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0053,"VALIDVM7") // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
				Else
					Help("",1,"VALIDVM7",,STR0053,1,0) // Problema na validacao dos campos e nao foi possivel concluir o relacionamento
				EndIf
			EndIf

			oModelVM7:DeActivate()

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0054,"ACTIVEVM7") // Nao foi possivel ativar o modelo de inclusão da tabela VM7
			Else
				Help("",1,"ACTIVEVM7",,STR0054,1,0) // Nao foi possivel ativar o modelo de inclusão da tabela VM7
			EndIf
		EndIf

	EndIf

	FreeObj(oModelVM7)

Return

/*/{Protheus.doc} OA3400291_LimpaLinhaBranca
Limpa linha

@author Andre Luis Almeida
@since 20/12/2016
/*/
Function OA3400291_LimpaLinhaBranca()

	Local nPosItem := 0

	nPosItem := aScan(aItensConf,{|x| x[3] == " " })

	If nPosItem > 0
		aDel(aItensConf, nPosItem)
		aSize(aItensConf, Len(aItensConf) - 1)
	EndIf

Return

/*/{Protheus.doc} OA3400301_ChamaPEaposAprovReprov
Apos OK na Aprovacao/Reprovacao chama PE OA340DOK

@author Andre Luis Almeida
@since 13/08/2021
@version 1.0
/*/
Function OA3400301_ChamaPEaposAprovReprov( cAprRepr )
Local cVolume:= ""
Local aItens := {}
Local cQuery := ""
Default cAprRepr := "1" // Aprovacao

If ExistBlock("OA340DOK")

	cVolume := VM7->VM7_VOLUME

	cQuery := "SELECT VM8.VM8_COD, VM8.VM8_QTCONF, VM8.VM8_QTORIG, R_E_C_N_O_ VM8RECNO "
	cQuery += "  FROM " + RetSqlName("VM8") + " VM8 "
	cQuery += " WHERE VM8.VM8_FILIAL = '" + xFilial("VM8") + "' "
	cQuery += "   AND VM8.VM8_CODVM7 = '" + VM7->VM7_CODIGO + "' "
	cQuery += "   AND VM8.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVM8"

	While !TMPVM8->(Eof())

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+TMPVM8->VM8_COD))

		SB5->(DbSetOrder(1))
		SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))

		Aadd(aItens,{ "",;
					SB1->B1_GRUPO,;
					SB1->B1_CODITE,;
					SB1->B1_DESC,;
					TMPVM8->VM8_QTCONF,;
					TMPVM8->VM8_QTORIG,;
					SB1->B1_CODBAR,;
					SB1->B1_COD,;
					FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
					TMPVM8->VM8RECNO;
					})
		TMPVM8->(DbSkip())
	EndDo
	TMPVM8->(dbCloseArea())
	DbSelectArea("VCX")

	ExecBlock("OA340DOK",.f.,.f.,{cAprRepr,cVolume,aItens}) // PE apos Aprovação / Reprovacao

EndIf

Return

/*/{Protheus.doc} OA3400311_GravaConferenciaZerada
Grava registros que estao zerados no momento da Finalizacao da Conferencia

@author Andre Luis Almeida
@since 13/08/2021

@param cConferencia Codigo do VM7
@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
/*/
Function OA3400311_GravaConferenciaZerada( cConferencia , cTpOrigem )
Local cQuery      := ""
Local cQAlVM8     := "SQLVM8"
Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
//
cQuery := "SELECT VM8.R_E_C_N_O_ AS RECVM8 "
cQuery += "  FROM "+RetSQLName("VM8")+" VM8 "
cQuery += " WHERE VM8.VM8_FILIAL='"+xFilial("VM8")+"'"
cQuery += "   AND VM8.VM8_CODVM7='"+cConferencia+"'"
cQuery += "   AND VM8.VM8_QTORIG > 0 "
cQuery += "   AND VM8.VM8_QTCONF = 0 "
cQuery += "   AND VM8.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVM8 , .F., .T. )
While !( cQAlVM8 )->( Eof() )
	OA3400281_GravaQtdConferida( ( cQAlVM8 )->( RECVM8 ) , 0 , cTpOrigem )
	( cQAlVM8 )->( DbSkip() )
EndDo
( cQAlVM8 )->( DbCloseArea() )
//
DbSelectArea("VM7")
//
Return

/*/{Protheus.doc} OA3400371_MontaCampos
Monta Campos da Tela e Tabela Temporaria

@author Andre Luis Almeida
@since 18/08/2021

@param nTp, numerico Tipo de Retorno
@param cTab, caracter Tabela a Retornar
/*/
Function OA3400371_MontaCampos( nTp , cTab )
Local aRet := {}
If nTp == 1 // Montar Tabela Temporaria
	Do Case
		Case cTab == "TMPV" // Volume
			aadd(aRet, {"TPV_FILIAL","C",GetSX3Cache("VCX_FILIAL","X3_TAMANHO"),0} ) // Filial
			aadd(aRet, {"TPV_VOLUME","C",GetSX3Cache("VCX_VOLUME","X3_TAMANHO"),0} ) // Volume
			aadd(aRet, {"TPV_CODFOR","C",GetSX3Cache("F1_FORNECE","X3_TAMANHO"),0} ) // Fornecedor
			aadd(aRet, {"TPV_LOJFOR","C",GetSX3Cache("F1_LOJA"   ,"X3_TAMANHO"),0} ) // Loja
			aadd(aRet, {"TPV_NOMFOR","C",GetSX3Cache("A2_NOME"   ,"X3_TAMANHO"),0} ) // Nome
			aadd(aRet, {"TPV_DATA"  ,"D",8,0} ) // Data
		Case cTab == "TMPI" // Item
			aadd(aRet, {"TPI_FILIAL","C",GetSX3Cache("VCX_FILIAL","X3_TAMANHO"),0} ) // Filial
			aadd(aRet, {"TPI_VOLUME","C",GetSX3Cache("VCX_VOLUME","X3_TAMANHO"),0} ) // Volume
			aadd(aRet, {"TPI_COD"   ,"C",GetSX3Cache("B1_COD"    ,"X3_TAMANHO"),0} ) // Produto
			aadd(aRet, {"TPI_GRUITE","C",GetSX3Cache("B1_GRUPO"  ,"X3_TAMANHO"),0} ) // Grupo do Produto
			aadd(aRet, {"TPI_CODITE","C",GetSX3Cache("B1_CODITE" ,"X3_TAMANHO"),0} ) // CodIte do Produto
			aadd(aRet, {"TPI_DESITE","C",GetSX3Cache("B1_DESC"   ,"X3_TAMANHO"),0} ) // Descricao do Produto
		Case cTab == "TMPN" // NF
			aadd(aRet, {"TPN_FILIAL","C",GetSX3Cache("VCX_FILIAL","X3_TAMANHO"),0} ) // Filial
			aadd(aRet, {"TPN_VOLUME","C",GetSX3Cache("VCX_VOLUME","X3_TAMANHO"),0} ) // Volume
			aadd(aRet, {"TPN_NUMNFI","C",GetSX3Cache("F1_DOC"    ,"X3_TAMANHO"),0} ) // NF
			aadd(aRet, {"TPN_SERNFI","C",GetSX3Cache("F1_SERIE"  ,"X3_TAMANHO"),0} ) // Serie
			aadd(aRet, {"TPN_CODFOR","C",GetSX3Cache("F1_FORNECE","X3_TAMANHO"),0} ) // Fornecedor
			aadd(aRet, {"TPN_LOJFOR","C",GetSX3Cache("F1_LOJA"   ,"X3_TAMANHO"),0} ) // Loja
			aadd(aRet, {"TPN_NOMFOR","C",GetSX3Cache("A2_NOME"   ,"X3_TAMANHO"),0} ) // Nome
	EndCase
ElseIf nTp == 2 // Montar Tela
	Do Case
		Case cTab == "TMPV" // Volume
			aAdd(aRet,{ STR0032 ,"TPV_VOLUME" ,"C",GetSX3Cache("VCX_VOLUME" ,"X3_TAMANHO"),0,""}) // Volume
			aAdd(aRet,{ STR0084 ,"TPV_DATA" ,"D",8,0,""}) // Data
			aAdd(aRet,{ STR0016 ,"TPV_NOMFOR" ,"C",GetSX3Cache("A2_NOME" ,"X3_TAMANHO"),0,""}) // Fornecedor
		Case cTab == "TMPI" // Item
			aAdd(aRet,{ STR0028 ,"TPI_GRUITE" ,"C",GetSX3Cache("B1_GRUPO" ,"X3_TAMANHO"),0,""}) // Grupo
			aAdd(aRet,{ STR0029 ,"TPI_CODITE" ,"C",GetSX3Cache("B1_CODITE" ,"X3_TAMANHO"),0,""}) // Código do Item
			aAdd(aRet,{ STR0030 ,"TPI_DESITE" ,"C",GetSX3Cache("B1_DESC" ,"X3_TAMANHO"),0,""}) // Descrição
		Case cTab == "TMPN" // NF
			aAdd(aRet,{ STR0015 ,"TPN_NUMNFI" ,"C",GetSX3Cache("F1_DOC" ,"X3_TAMANHO"),0,""}) // NF
			aAdd(aRet,{ STR0085 ,"TPN_SERNFI" ,"C",GetSX3Cache("F1_SERIE" ,"X3_TAMANHO"),0,""}) // Serie
			aAdd(aRet,{ STR0016 ,"TPN_CODFOR" ,"C",GetSX3Cache("F1_FORNECE" ,"X3_TAMANHO"),0,""}) // Fornecedor
			aAdd(aRet,{ STR0064 ,"TPN_LOJFOR" ,"C",GetSX3Cache("F1_LOJA" ,"X3_TAMANHO"),0,""}) // Loja
			aAdd(aRet,{ STR0086 ,"TPN_NOMFOR" ,"C",GetSX3Cache("A2_NOME" ,"X3_TAMANHO"),0,""}) // Nome
	EndCase
EndIf
Return aClone(aRet)

/*/{Protheus.doc} OA3400381_CriaTabelasTemporarias
Cria Tabelas Temporarias com Dados

@author Andre Luis Almeida
@since 18/08/2021
/*/
Static Function OA3400381_CriaTabelasTemporarias( lMostraItem , lAprovador )
Local cQuery  := ""
Local cQuebra := "INICIAL"
Local nCntFor := 0
Local aNFsVol := {}
//
ProcRegua( 0 )
IncProc(STR0001) // Conferência de Entrada por Volume
//
lCriouTabIt := .f. // NAO criou tabela temporaria dos Itens
//
oTabTMPV := OFDMSTempTable():New()
oTabTMPV:cAlias := "TMPVVCX"
oTabTMPV:aVetCampos := OA3400371_MontaCampos( 1 ,"TMPV" )
oTabTMPV:AddIndex(, {"TPV_FILIAL","TPV_VOLUME"} )
oTabTMPV:CreateTable()
If lMostraItem //Mostra item - Sim
	oTabTMPI := OFDMSTempTable():New()
	oTabTMPI:cAlias := "TMPIVCX"
	oTabTMPI:aVetCampos := OA3400371_MontaCampos( 1 ,"TMPI" )
	oTabTMPI:AddIndex(, {"TPI_FILIAL","TPI_VOLUME"} )
	oTabTMPI:CreateTable()
	lCriouTabIt := .t. // criou tabela temporaria dos Itens
EndIf
oTabTMPN := OFDMSTempTable():New()
oTabTMPN:cAlias := "TMPNVCX"
oTabTMPN:aVetCampos := OA3400371_MontaCampos( 1 ,"TMPN" )
oTabTMPN:AddIndex(, {"TPN_FILIAL","TPN_VOLUME"} )
oTabTMPN:CreateTable()
//
cQuery := "SELECT DISTINCT VCX.VCX_FILIAL , VCX.VCX_VOLUME "
If lMostraItem //Mostra item - Sim
	cQuery += ", SB1.B1_COD , SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC "
EndIf
cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
If lMostraItem //Mostra item - Sim
	cQuery += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL='" + xFilial("SB1") + "' AND SB1.B1_COD=VCX.VCX_COD "
	If !Empty(cFiltGrp)
		cQuery += "  AND SB1.B1_GRUPO='"+cFiltGrp+"' "
	EndIf
	If !Empty(cFiltCod)
		cQuery += "  AND SB1.B1_CODITE='"+cFiltCod+"' "
	EndIf
	cQuery += "  AND SB1.D_E_L_E_T_=' ' "
EndIf
cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "' "
If !Empty(cFiltVol)
	cQuery += "   AND VCX.VCX_VOLUME = '"+cFiltVol+"'"
EndIf
If !Empty(cFiltFor)
	cQuery += "   AND VCX.VCX_FORNEC = '"+cFiltFor+"'"
EndIf
If !Empty(cFiltLoj)
	cQuery += "   AND VCX.VCX_LOJA = '"+cFiltLoj+"'"
EndIf
cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
If !lAprovador
	cQuery += " AND NOT EXISTS ( "
	cQuery += "SELECT VM7.VM7_VOLUME "
	cQuery += "  FROM " + RetSqlName("VM7") + " VM7 "
	cQuery += " WHERE VM7.VM7_FILIAL ='" + xFilial("VM7") + "' "
	cQuery += "   AND VM7.VM7_STATUS IN ('3','4') "
	cQuery += "   AND VM7.VM7_VOLUME = VCX.VCX_VOLUME "
	cQuery += "   AND VM7.D_E_L_E_T_ = ' ')"
EndIf
cQuery += " AND EXISTS ( "
cQuery += "SELECT SD1.D1_DOC "
cQuery += "  FROM " + RetSqlName("SD1") + " SD1 "
cQuery += "  LEFT JOIN " + RetSqlName("SF4") + " SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_=' '"
cQuery += " WHERE SD1.D1_FILIAL  ='" + xFilial("SD1") + "' "
cQuery += "   AND SD1.D1_DOC     = VCX.VCX_DOC "
cQuery += "   AND SD1.D1_SERIE   = VCX.VCX_SERIE "
cQuery += "   AND SD1.D1_FORNECE = VCX.VCX_FORNEC "
cQuery += "   AND SD1.D1_LOJA    = VCX.VCX_LOJA "
cQuery += "   AND SD1.D1_COD     = VCX.VCX_COD "
cQuery += "   AND SD1.D1_ITEM    = VCX.VCX_ITEM "
cQuery += "   AND SD1.D1_DTDIGIT >= '"+dtos(dDatabase-nFiltDia)+"'"
cQuery += "   AND ( SD1.D1_TES = ' ' OR SF4.F4_ESTOQUE='S' ) "
cQuery += "   AND SD1.D_E_L_E_T_ = ' ' )"
//
cQuery += " AND NOT EXISTS ( "
cQuery += "SELECT VM0.VM0_DOC "
cQuery += "  FROM " + RetSqlName("VM0") + " VM0 "
cQuery += " WHERE VM0.VM0_FILIAL = '" + xFilial("VM0") + "' "
cQuery += "   AND VM0.VM0_DOC    = VCX.VCX_DOC "
cQuery += "   AND VM0.VM0_SERIE  = VCX.VCX_SERIE "
cQuery += "   AND VM0.VM0_FORNEC = VCX.VCX_FORNEC "
cQuery += "   AND VM0.VM0_LOJA   = VCX.VCX_LOJA "
cQuery += "   AND VM0.VM0_STATUS IN ('1','2','3','4') "
cQuery += "   AND VM0.D_E_L_E_T_ = ' ')"
//
cQuery += " ORDER BY VCX.VCX_FILIAL , VCX.VCX_VOLUME "
If lMostraItem //Mostra item - Sim
	cQuery += ", SB1.B1_GRUPO , SB1.B1_CODITE "
EndIf
//
TcQuery cQuery New Alias "SQLVCX"
While !SQLVCX->(Eof())
	If cQuebra <> SQLVCX->( VCX_FILIAL ) + SQLVCX->( VCX_VOLUME )
		cQuebra := SQLVCX->( VCX_FILIAL ) + SQLVCX->( VCX_VOLUME )
		aNFsVol := OA3400051_NFsporVolume( SQLVCX->( VCX_VOLUME ) , .t. )
		DbSelectArea("TMPVVCX") // Volumes
		RecLock("TMPVVCX",.T.)
			TMPVVCX->TPV_FILIAL := SQLVCX->( VCX_FILIAL )
			TMPVVCX->TPV_VOLUME := SQLVCX->( VCX_VOLUME )
			If len(aNFsVol) > 0
				TMPVVCX->TPV_CODFOR := aNFsVol[1,3]
				TMPVVCX->TPV_LOJFOR := aNFsVol[1,4]
				TMPVVCX->TPV_NOMFOR := aNFsVol[1,5]
				TMPVVCX->TPV_DATA   := aNFsVol[1,6]
			EndIf
		MsUnlock()
		For nCntFor := 1 to len(aNFsVol)
			DbSelectArea("TMPNVCX") // NFs
			RecLock("TMPNVCX",.T.)
				TMPNVCX->TPN_FILIAL := SQLVCX->( VCX_FILIAL )
				TMPNVCX->TPN_VOLUME := SQLVCX->( VCX_VOLUME )
				TMPNVCX->TPN_NUMNFI := aNFsVol[nCntFor,1]
				TMPNVCX->TPN_SERNFI := aNFsVol[nCntFor,2]
				TMPNVCX->TPN_CODFOR := aNFsVol[nCntFor,3]
				TMPNVCX->TPN_LOJFOR := aNFsVol[nCntFor,4]
				TMPNVCX->TPN_NOMFOR := aNFsVol[nCntFor,5]
			MsUnlock()
		Next
	EndIf
	If lMostraItem //Mostra item - Sim
		DbSelectArea("TMPIVCX") // Itens
		RecLock("TMPIVCX",.T.)
			TMPIVCX->TPI_FILIAL := SQLVCX->( VCX_FILIAL )
			TMPIVCX->TPI_VOLUME := SQLVCX->( VCX_VOLUME )
			TMPIVCX->TPI_COD    := SQLVCX->( B1_COD )
			TMPIVCX->TPI_GRUITE := SQLVCX->( B1_GRUPO )
			TMPIVCX->TPI_CODITE := SQLVCX->( B1_CODITE )
			TMPIVCX->TPI_DESITE := SQLVCX->( B1_DESC )
		MsUnlock()
	EndIf
	SQLVCX->(DbSkip())
EndDo
SQLVCX->(dbCloseArea())
DbSelectArea("TMPVVCX")
DbGoTop()
//
Return

/*/{Protheus.doc} OA3400391_GravaQtdDivergente
Grava Qtd.Divergente (VCX_QTDDIV) -> Campo utilizado na Entrada da NF

@author Andre Luis Almeida
@since 18/08/2021
/*/
Static Function OA3400391_GravaQtdDivergente( cConferencia )
Local cQuery   := ""
Local nQtdDiv  := 0
Local aVetCpos := {}
//
aadd(aVetCpos,{ "VCX_QTDDIV" , 0 }) // Alterar Qtd.Divergente
//
VM7->(DbSeek(xFilial("VM7") + cConferencia ))
//
cQuery := "SELECT VM8.VM8_COD , SUM(( VM8.VM8_QTORIG - VM8.VM8_QTCONF )) AS QTD_DIVERG "
cQuery += "  FROM " + RetSqlName("VM8") + " VM8 "
cQuery += " WHERE VM8.VM8_FILIAL = '" + xFilial("VM8") + "'"
cQuery += "   AND VM8.VM8_CODVM7 = '" + cConferencia + "' "
cQuery += "   AND VM8.VM8_QTORIG > VM8.VM8_QTCONF "
cQuery += "   AND VM8.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY VM8.VM8_COD"
TcQuery cQuery New Alias "SQLVM8"
While !SQLVM8->(Eof())
	nQtdDiv := SQLVM8->( QTD_DIVERG )
	cQuery := "SELECT VCX.R_E_C_N_O_ AS RECVCX , VCX.VCX_QTDITE "
	cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
	cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "'"
	cQuery += "   AND VCX.VCX_VOLUME = '" + VM7->VM7_VOLUME + "'"
	cQuery += "   AND VCX.VCX_COD    = '" + SQLVM8->( VM8_COD ) + "'"
	cQuery += "   AND VCX.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY VCX.VCX_QTDITE DESC"
	TcQuery cQuery New Alias "SQLVCX"
	While !SQLVCX->(Eof()) .and. nQtdDiv > 0
		If nQtdDiv <= SQLVCX->( VCX_QTDITE )
			aVetCpos[1,2] := nQtdDiv
			nQtdDiv := 0
		Else
			aVetCpos[1,2] := SQLVCX->( VCX_QTDITE )
			nQtdDiv -= SQLVCX->( VCX_QTDITE )
		EndIf
		OA3200011_Volumes_dos_Itens_da_NF_Entrada( SQLVCX->( RECVCX ) , aVetCpos ) // Alterar Qtd.Divergente
		SQLVCX->(DbSkip())
	EndDo
	SQLVCX->(dbCloseArea())
	SQLVM8->(DbSkip())
EndDo
SQLVM8->(dbCloseArea())
DbSelectArea("VM7")
Return

/*/{Protheus.doc} OA3400421_ColunaStatusItens
Cores dos Itens

@author Andre Luis Almeida
@since 19/08/2021
/*/
Static Function OA3400421_ColunaStatusItens()
	
	// Variável do Retorno
	Local cImgRPO := "BR_BRANCO"

	cAlVM7 := 'TABVM7'
	BeginSql alias cAlVM7
		SELECT
			VM7.VM7_CODIGO,
			VM7.VM7_STATUS,
			VM8.VM8_QTCONF,
			VM8.VM8_QTORIG
		FROM
			%table:VM7% VM7
			JOIN %table:VM8% VM8 ON
				VM8.VM8_FILIAL = %xfilial:VM8% AND
				VM8.VM8_CODVM7 = VM7.VM7_CODIGO AND
				VM8.VM8_COD = %exp:TMPIVCX->TPI_COD% AND
				VM8.%notDel%
		WHERE
			VM7.VM7_FILIAL = %xfilial:VM7% AND
			VM7.VM7_VOLUME = %exp:TMPIVCX->TPI_VOLUME% AND
			VM7.%notDel%
		ORDER BY 1 DESC
	EndSql

	If !(cAlVM7)->(Eof())
		//-- Define Status do registro
		If (cAlVM7)->VM8_QTCONF == 0 //Item nao conferido
			cImgRpo := "BR_AMARELO"
		ElseIf (cAlVM7)->VM8_QTCONF == (cAlVM7)->VM8_QTORIG .and. (cAlVM7)->VM7_STATUS <> "1" //Quantidade conferida 
			cImgRpo := "BR_VERDE"
		ElseIf (cAlVM7)->VM8_QTCONF <> (cAlVM7)->VM8_QTORIG .and. (cAlVM7)->VM7_STATUS <> "1" //Divergencia na conferencia
			cImgRpo := "BR_VERMELHO"
		EndIf
	EndIf

	(cAlVM7)->(dbCloseArea())

Return cImgRPO

/*/{Protheus.doc} OA3400431_LegendaStatusItens
Legenda dos Itens

@author Andre Luis Almeida
@since 19/08/2021
/*/
Static Function OA3400431_LegendaStatusItens()
	
	// Array das Legendas
	Local aLegenda := {	{"BR_BRANCO"	, STR0088 },; // Sem Status
						{"BR_AMARELO"	, STR0037 },; // Item não Conferido
						{"BR_VERDE"		, STR0039 },; // Item conferido corretamente
						{"BR_VERMELHO"	, STR0040 } } // Divergencia na Conferência

	//-- Define Status do registro
	BrwLegenda(STR0087,STR0012,aLegenda )	// Status dos Itens / Legenda

Return .T.

/*/{Protheus.doc} OA3400441_ReprovarConferencia
Reprovar Conferencia

@author Andre Luis Almeida
@since 26/08/2021
/*/
Function OA3400441_ReprovarConferencia( cVolume )
Local lAprovador   := OM3900141_UsuarioAprovador()
Local cConferencia := ""
Local cQuery       := ""
Local lRet         := .t.
//
If !lAprovador
	MsgStop(STR0089,STR0017) // Usuário do tipo Conferente. Impossivel Reprovar. / Atenção
	lRet := .f.
Else
	cConferencia := OA3400121_ExisteConferencia( cVolume , .t. ) // Somente os Registros Validos ( Não Reprovado )
	If Empty(cConferencia)
		cConferencia := OA3400121_ExisteConferencia( cVolume , .f. ) // Todos os Registros ( inclusive o Reprovado )
	EndIf
	VM7->(DbSetOrder(1))
	If !Empty(cConferencia) .and. VM7->(DbSeek(xFilial("VM7")+cConferencia))
		Do Case
			Case VM7->VM7_STATUS == "5" // Reprovada
				MsgStop(STR0090,STR0017) // Conferencia já Reprovada. Impossivel continuar. / Atenção
				lRet := .f.
			Case VM7->VM7_STATUS == "4" // Aprovada
				cQuery := "SELECT COUNT(*) "
				cQuery += "  FROM " + RetSqlName("VCX") + " VCX "
				cQuery += "  JOIN " + RetSqlName("SF1") + " SF1 "
				cQuery += "    ON SF1.F1_FILIAL  = '" + xFilial("SF1") + "'"
				cQuery += "   AND SF1.F1_DOC     = VCX.VCX_DOC"
				cQuery += "   AND SF1.F1_SERIE   = VCX.VCX_SERIE"
				cQuery += "   AND SF1.F1_FORNECE = VCX.VCX_FORNEC"
				cQuery += "   AND SF1.F1_LOJA    = VCX.VCX_LOJA"
				cQuery += "   AND SF1.F1_STATUS <> ' '"
				cQuery += "   AND SF1.D_E_L_E_T_ = ' '"
				cQuery += " WHERE VCX.VCX_FILIAL = '" + xFilial("VCX") + "'"
				cQuery += "   AND VCX.VCX_VOLUME = '" + cVolume + "'"
				cQuery += "   AND VCX.D_E_L_E_T_ = ' '"
				If FM_SQL(cQuery) > 0
					MsgStop(STR0091,STR0017) // Conferencia Aprovada com NF de Entrada já efetivada (Classificada). Impossivel Reprovar. / Atenção
					lRet := .f.
				Else
					If !MsgYesNo(STR0092,STR0017) // Conferencia já Aprovada. Deseja Reprovar? / Atenção
						lRet := .f.
					EndIf
				EndIf
			Case VM7->VM7_STATUS == "3" // Finalizada
				If !MsgYesNo(STR0093,STR0017) // Conferencia já Finalizada. Deseja Reprovar? / Atenção
					lRet := .f.
				EndIf
			Case VM7->VM7_STATUS == "2" // Conf.Parcial
				If !MsgYesNo(STR0094,STR0017) // Conferencia já Iniciada. Deseja Reprovar? / Atenção
					lRet := .f.
				EndIf
		EndCase
		If lRet
			OA1910011_ExcluirVM2( VM7->VM7_CODIGO , "4" , "5" ) // Apagar VM2 Reprovado anteriormente (caso existir) para nao dar Chave Unica na proxima Reprovacao
			OA3400211_GravaObservacaoConferencia(STR0095+" "+Transform(dDataBase,"@D")+" "+left(time(),5)+" "+__CUSERID+"-"+left(Alltrim(UsrRetName(__CUSERID)),15)) // Reprovado Manualmente
			OA3400111_StatusConferencia( VM7->VM7_CODIGO , "5", "0" ) // Reprovar Conferencia
		EndIf
	EndIf
EndIf
//
Return lRet

/*/{Protheus.doc} OA3400451_VisualizarConferencia
	Visualizar Conferencia

	@author Andre Luis Almeida
	@since  27/08/2021
/*/
Function OA3400451_VisualizarConferencia( cVolume )
Local cNroConf := OA3400121_ExisteConferencia( cVolume , .f. )
VM7->( DbSetOrder(1) )
If !Empty(cNroConf) .and. VM7->( DbSeek( xFilial("VM7") + cNroConf ) )
	OA3400061_TelaConferencia( cNroConf , .t. )
Else
	MsgInfo(STR0096,STR0017) // Conferencia não iniciada. / Atencao
EndIf
Return
