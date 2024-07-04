#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "GPEM922.CH"

Static lMid	:= SuperGetMv( "MV_MID",, .F. )

/*/{Protheus.doc} function GPEM922
Realiza a exclusão de eventos
@author  Hugo de Oliveira
@since   11/12/2019
@version 1.0
/*/
Function GPEM922()
	Static oBrowse
	Static aMarkRJE		:= {}
	Static _Mark 		:= {}
	Local cFiltraRh     := ""
	Local nOp			:= 0

	If !lMid
		nOp := Aviso(STR0023, STR0022, {STR0024, STR0002})//Rotina só deve ser utilizada quando parâmetro MV_MID estiver habiltado, pesquise Middleware na página centralizadora de Entregas Legais para maiores informações
		If nOp == 1
			shellExecute("Open","https://tdn.totvs.com/x/4JQYEw", "", "", 1)
		EndIf
		Return
	ElseIf !ChkFile( "RJE" ) // STR0001: "Tabela RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
		Help( " ", 1, OemToAnsi( STR0023 ),, OemToAnsi( STR0001 ), 1, 0 ) //"Fechar"
		Return
	EndIf

	// Realiza o processamento
	DbSelectArea( "RJE" )
	DbSetOrder( 3 )

	oBrowse := FWMarkBrowse():New()

	oBrowse:SetAlias( "RJE" )
	oBrowse:SetFieldMark( "RJE_OKTRAN" )
	oBrowse:SetDescription( STR0003 ) // STR0003: "Exclusão de Eventos"

	// NãoPeriódicos
	cFiltraRh := "( RJE_EVENTO $ 'S2190,S2200,S2205,S2206,S2210,S2220,S2240,S2250,S2260,S2298,S2300,S2306'"

	// Todos que não estão aguardando retorno do governo
	cFiltraRh += " .And. RJE_STATUS != '2' "

	// Periódicos não enviados ou que retornaram com erro. Outros status devem ser excluídos na rotina de periódicos.
	cFiltraRh += ".Or. RJE_EVENTO $ 'S1200,S1210' .And. RJE_STATUS $ '1|3' )"

	cFiltraRh += " .And. RJE_EXC = ' '"

	oBrowse:SetFilterDefault( cFiltraRh )

	oBrowse:SetmenuDef( "GPEM922" )
	oBrowse:SetAfterMark( { || fMark() } )
	oBrowse:SetAllMark( { || fMarkAll() } )

	//Legendas
	oBrowse:AddLegend( "RJE->RJE_STATUS == '1' ", "GREEN",	STR0004 ) // STR0004: "Pendentes de envio"
	oBrowse:AddLegend( "RJE->RJE_STATUS == '2' ", "YELLOW",	STR0005 ) // STR0005: "Aguardando governo"
	oBrowse:AddLegend( "RJE->RJE_STATUS == '3' ", "RED",	STR0006 ) // STR0006: "Rejeitado"
	oBrowse:AddLegend( "RJE->RJE_STATUS == '4' ", "BLUE",	STR0007 ) // STR0007: "Sucesso"
	oBrowse:Activate()
Return


/*/{Protheus.doc} function MenuDef
Função que monta o menu da rotina.
@author Hugo de Oliveira
@since  11/12/2019
@version 1.0
/*/
Static Function MenuDef()
	Local aRotina :=  {}
	ADD OPTION aRotina TITLE OemToAnsi( STR0008 ) ACTION "VIEWDEF.GPEM922" 	OPERATION 2 ACCESS 0 // STR0008: "Visualizar"
	ADD OPTION aRotina TITLE OemToAnsi( STR0009 ) ACTION "fRemove()" 		OPERATION 5 ACCESS 0 // STR0009: "Excluir"
Return aRotina


/*/{Protheus.doc} function ModelDef
Função que processa os dados da rotina.
@author  hugo.de.oliveira
@since   11/12/2019
@version 1.0
/*/
Static Function ModelDef()
	Local oModel
	Local oStructRJE
	Local cFiltraRh := ""

	oStructRJE	:= FWFormStruct( 1, "RJE" )
	oModel 		:= MpFormModel():New("GPEM922",/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)

	oModel:AddFields("GPEM922RJE", /*cOwner*/, oStructRJE ,/*Pre-Validacao*/, /*Pos-Validacao*/, /*Carga*/)
	oModel:GetModel("GPEM922RJE"):SetOnlyView(.T.)
	oModel:GetModel('GPEM922RJE'):SetOnlyQuery(.T.)
	oModel:SetPrimaryKey( {} )
Return oModel


/*/{Protheus.doc} function ViewDef
Função que apresenta os dados da rotina na tela.
@author Hugo de Oliveira
@since  11/12/2019
@version 1.0
/*/
Static Function ViewDef()
	Local oModel
	Local oStructRJE
	Local oView

	oView  := FWFormView():New()
	oModel := FwLoadModel( "GPEM922" )

	oView:SetModel( oModel )
	oStructRJE	:= FWFormStruct( 2, "RJE" )
	oStructRJE:SetNoFolder()

	oView:AddField( "GPEM922RJE" , oStructRJE )
	oView:SetViewProperty("GPEM922RJE", "OnlyView")
	oView:createHorizontalBox("FORMFIELD", 100)
	oView:SetOwnerView( "GPEM922RJE", "FORMFIELD")
Return oView


/*/{Protheus.doc} function fRemove
Função que realiza a remoção dos eventos selecionados
@author Hugo de Oliveira
@since  11/12/2019
@version 1.0
/*/
Function fRemove()
	Local nX 		 := 1
	Local nRecRJE  	 := 0
	Local cStatus	 := ""
	Local cAliasRJE	 := "RJE"
	Local nQtdeReg 	 := Len( aMarkRJE )
	Local cXML		 := ""
	Local cRetKey	 := ""
	Local aData		 := {}
	Local aLogFil	 :=	{}
	Local aProc		 := {}
	Local aNProc	 := {}
	Local aInfoProc	 := {}
	Local aInfoNProc := {}
	Local aMotivo	 := {}

	If nQtdeReg < 1
		Help(" ", 1, OemToAnsi( "Atenção" ),, OemToAnsi( STR0010 ), 1, 0) // STR0010: "Nenhum evento selecionado."
		Return
	EndIf

	// Processamento da Exclusão
	For nX := 1 to nQtdeReg
		dbSelectArea( cAliasRJE )
		( cAliasRJE )->( DbSetOrder( 3 ) ) // RJE_EVENTO, RJE_RETKEY
		( cAliasRJE )->( DbGoTop() )

		If ( cAliasRJE )->( DbSeek( aMarkRJE[nX][2] + aMarkRJE[nX][3] ) )
			Begin Transaction

				// Status 4 gera um evento S-3000
				If aMarkRJE[nX][4] == "4"
					aData 	:= fGetData( aMarkRJE[nX][8], aMarkRJE[nX][2], aMarkRJE[nX][6], ALLTRIM(aMarkRJE[nX][7]), aMarkRJE[nX][9], @cRetKey )
					cXML 	:= fGetNewXML( @aMarkRJE[nX][5], aMarkRJE[nX][2], ALLTRIM( aMarkRJE[nX][9]), aMarkRJE[nX][6], ALLTRIM(aMarkRJE[nX][7]), cRetKey)
					cStatus := fGetStat( ALLTRIM( aMarkRJE[nX][9] ) )

					// Cria um novo evento S-3000
					If Empty( cStatus )
						If !( fGravaRJE( aData, cXML, .T., nRecRJE ) ) // Função do fonte GPEM017A
							aInfoNProc := { aMarkRJE[nX][10], aMarkRJE[nX][2], aMarkRJE[nX][4], aMarkRJE[nX][8], aMarkRJE[nX][7] }
							aAdd( aNProc, aInfoNProc )
						Else
							aInfoProc := { aMarkRJE[nX][10], aMarkRJE[nX][2], aMarkRJE[nX][4], aMarkRJE[nX][8], aMarkRJE[nX][7] }
							aAdd( aProc, aInfoProc )
						EndIf

					ElseIf cStatus $ "1|2"
						// STR0011: "Já existe uma exclusão(S-3000) aguardando processamento ou retorno para este evento."
						aInfoNProc := { aMarkRJE[nX][10], aMarkRJE[nX][2], aMarkRJE[nX][4], aMarkRJE[nX][8], aMarkRJE[nX][7], STR0011 }
						aAdd( aNProc, aInfoNProc )

					// Sobrescreve o evento S-3000
					ElseIf cStatus == "3"
						Reclock( cAliasRJE, .F.)
							( cAliasRJE )->RJE_STATUS 	:= "1"
							( cAliasRJE )->RJE_XML 		:= cXML
						( cAliasRJE )->( MsUnLock() )

						aInfoProc := { aMarkRJE[nX][10], aMarkRJE[nX][2], aMarkRJE[nX][4], aMarkRJE[nX][8], aMarkRJE[nX][7] }
						aAdd( aProc, aInfoProc )
					EndIf

				// Status 1 e 3 apenas são removidos da RJE. Status 2 não é considerado.
				Else
					Reclock( cAliasRJE, .F.)
					( cAliasRJE )->( dbDelete() )
					( cAliasRJE )->( MsUnLock() )

					aInfoProc := { aMarkRJE[nX][10], aMarkRJE[nX][2], aMarkRJE[nX][4], aMarkRJE[nX][8], aMarkRJE[nX][7] }
					aAdd( aProc, aInfoProc )
				EndIf
			End Transaction
		EndIf

		aInfoNProc  := {}
		aInfoProc	:= {}
	Next nX

	fShowLog( aProc, aNProc )
Return


/*/{Protheus.doc} function fShowLog
Função que trata os dados e chama a apresentação dos dados.
@author Hugo de Oliveira
@since  17/12/2019
@version 1.0
/*/
Static Function fShowLog( aProc, aNProc )
	Local nX 		:= 1
	Local aTitle 	:= {}
	Local aLog 		:= {}

	Aadd( aLog,  OemToAnsi( STR0021 ) ) // STR0021: "Monitoramento do(s) Evento(s): "
	aAdd( aLog, Replicate( "-",132) )
	Aadd( aLog, OemToAnsi( STR0012 ) ) // STR0012: "Evento(s) Processado(s): "

	If !Empty( aProc )
		For nX := 1 To Len( aProc )
			aAdd( aLog, OemToAnsi( STR0014 ) + ALLTRIM( aProc[nX][1] ) ) // STR0014: "Key: "
			aAdd( aLog, OemToAnsi( STR0015 ) + aProc[nX][4] )			// STR0015: "Filial: "
			aAdd( aLog, OemToAnsi( STR0016 ) + aProc[nX][2] )			// STR0016: "Evento: "
			aAdd( aLog, OemToAnsi( STR0017 ) + aProc[nX][3] )			// STR0017: "Status: "
			aAdd( aLog, OemToAnsi( STR0018 ) + ALLTRIM( aProc[nX][5]) )  // STR0018: "Inscrição: "
			aAdd( aLog, "" )
		Next nX
	Else
		Aadd( aLog, OemToAnsi( "Não há registros" ) ) //
	EndIf

	aAdd( aLog, Replicate( "-",132) )
	aAdd( aLog, OemToAnsi( STR0013 ) ) // STR0013: "Evento(s) Não Processado(s): "

	If !Empty( aNProc )
		For nX := 1 To Len( aNProc )
			aAdd( aLog, OemToAnsi( STR0014 ) + ALLTRIM( aNProc[nX][1] ) )
			aAdd( aLog, OemToAnsi( STR0015 ) + aNProc[nX][4] )
			aAdd( aLog, OemToAnsi( STR0016 ) + aNProc[nX][2] )
			aAdd( aLog, OemToAnsi( STR0017 ) + aNProc[nX][3] )
			aAdd( aLog, OemToAnsi( STR0018 )	+ ALLTRIM( aNProc[nX][5]) )
			aAdd( aLog, OemToAnsi( STR0019 )	+ ALLTRIM( aNProc[nX][6]) ) // STR0019: "Motivo: "
			aAdd( aLog, "" )
		Next nX
	Else
		Aadd( aLog, OemToAnsi( "Não há registros" ) ) //
	EndIf

	aAdd( aLog, Replicate( "-",132) )
	aAdd( aLog, "" )
	aAdd( aLog, "" )
	fMakeLog( { aLog }, aTitle, Nil, Nil, ,OemToAnsi( STR0020 ), "M", "L",, .F.) // STR0020: "Log de Exclusão de eventos"
Return


/*/{Protheus.doc} function Mark
Realiza a marcação de um registro no browse
@author Hugo de Oliveira
@since  11/12/2019
@version 1.0
/*/
Static Function fMark()
	Local cKey := RJE->( RJE_EVENTO + RJE_RETKEY )
	Local nPos := aScan( aMarkRJE, { |x| ( x[1] == cKey ) } )

	If oBrowse:IsMark()
		Aadd( aMarkRJE, { RJE_EVENTO + RJE_RETKEY, RJE_EVENTO, RJE_RETKEY, RJE_STATUS, RJE_XML, RJE_TPINSC, RJE_INSCR, RJE_FIL, RJE_RECIB, RJE_KEY } )
		Aadd( _Mark, oBrowse:At() )
	Else
		If ( nPos > 0 )
			nLastSize := Len( aMarkRJE )

			aDel( aMarkRJE, nPos )
			aDel( _Mark, nPos )

			aSize( aMarkRJE, ( nLastSize - 1 ) )
			aSize( _Mark, ( nLastSize - 1 ) )
		EndIF
	EndIf
Return


/*/{Protheus.doc} function MarkAll
Faz a marcação de todos os registros do browse
@author Hugo de Oliveira
@since  11/12/2019
@version 1.0
/*/
Static Function fMarkAll()
	Local nLast

	oBrowse:GoBottom(.F.)
	nLast := oBrowse:At()
	oBrowse:GoTop()

	While .T.
		oBrowse:MarkRec()
		If nLast == oBrowse:At()
			oBrowse:GoTop()
			Exit
		EndIf
		oBrowse:GoDown()
	EndDo
Return


/*/{Protheus.doc} function fGetNewXML
Cria um registro de exclusão na Tabela de eventos, de acordo com o seu tipo.
@author Hugo de Oliveira
@since  11/12/2019
@version 1.0
/*/
Static Function fGetNewXML( cXML, cEvt, cRecib, cTpInsc, cNrInsc, cId  )
	Local cCIC		:= ""
	Local cPIS		:= ""
	Local cNewXML 	:= ""
	Local cNewEvt	:= ""
	Local cStatNew	:= "1"
	Local cRetfNew  := "1"
	Local cOperNew	:= "I"
	Local cKeyMid	:= ""
	Local cExp		:= ""
	Local cAmb		:= SuperGetMv( "MV_GPEAMBE",, "2" )
	Local nRecEvt	:= 0
	Local nIni		:= 0
	Local lNovoRJE 	:= .T.
	Local lAdmPubl	:= .F.
	Local aErros	:= {}

	Default cXML   	:= ""
	Default cEvt   	:= ""
	Default cRecib  := ""
	Default cTpInsc := ""
	Default cNrInsc := ""
	Default cId 	:= ""

	cNewEvt := SUBSTR( cEvt, 0, 1 ) + "-" + SUBSTR( cEvt, 2, len( cEvt ) )
	cCPFXML := ALLTRIM( fGetXML( "cpfTrab", cXML ) )

	InExc3000( @cNewXML,cNewEvt,cRecib,cCPFXML,Nil,Nil,Nil,Nil,Nil,cFilAnt, lAdmPubl, cTpInsc, cNrInsc, cId, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cKeyMid, @aErros)


	// Ajusta Ambiente
	nIni 	:= AT("<tpAmb>", cNewXML )
	cExp 	:= SUBSTR( cNewXML, nIni, 16 )
	cNewXML := STRTRAN( cNewXML, cExp, "<tpAmb>" + cAmb + "</tpAmb>" )

Return cNewXML


/*/{Protheus.doc} function fGetXML
Retorna o valor de uma TAG do XML informado
@author  Hugo de Oliveira
@since   12/12/2019
@version 1.0
/*/
Static Function fGetXML( cTAG, cXML )
	Local nIni 	:= 0
	Local nFim 	:= 0
	Local cData := ""

	nIni 	:= AT("<" + cTAG + ">",  cXML )
	nFim 	:= AT("</" + cTAG + ">", cXML )
	cData 	:= ALLTRIM( STRTRAN(  SUBSTR( cXML, nIni, nFim-nIni ), "<" + cTAG + ">","" ) )

Return cData


/*/{Protheus.doc} function fGetData
Retorna dados necessários para inserção do registro na RJE
@author  Hugo de Oliveira
@since   12/12/2019
@version 1.0
/*/
Static Function fGetData( cBranch, cEvt, cTpInsc, cInsc, cKey, cRetKey )
	Local cRetfNew	:= "1" // Original
	Local cStatus	:= "1" // Pendente de Envio
	Local cOperNew 	:= "I" // Inclusão
	Local cFilRJE	:= ""
	Local cSrcFil	:= ""
	Local cRetKey	:= ""
	Local dDtGer	:= Date()
	Local cHrGer	:= Time()
	Local cAno		:= Alltrim( Str( Year( dDataBase ) ) )
	Local cMes		:= StrZero( Month( dDataBase ), 2 )
	Local cAnoMes	:= ""
	Local aInfoC	:= {}
	Local aData		:= {}

	cSrcFil	:= fGetFil( SUBSTR( cEvt, 1, 1 ) + "-" + SUBSTR( cEvt, 2, LEN( cEvt ) ), cBranch )
	cFilRJE := xFilial( "RJE", cBranch )
	cAnoMes := cAno + cMes

	// Preenchimento RJE_RETKEY
	fPosFil( cEmpAnt, cBranch )
	aInfoC   := fXMLInfos()
	If  LEN( aInfoC ) > 2
		cRetKey  := aInfoC[3]
	EndIf

	aAdd( aData, { cFilRJE, cSrcFil, cTpInsc, cInsc, "S3000", cAnoMes, ALLTRIM( cKey ), cRetKey, cRetfNew, "12", cStatus, dDtGer, cHrGer, cOperNew } )

Return aData


/*/{Protheus.doc} function fGetFil
Função que retorna as filiais de acordo com o compartilhamento da tabela que originou o evento gravado na RJE
@author  Hugo de Oliveira
@since   16/12/2019
@version 1.0
/*/
Static Function fGetFil( cEvent, cBranch )
	Local cRet  	:= ""
	Local lParcial 	:= .F.

	If !Empty(cBranch)
		If cEvent == "S-1005"
			cRet := cBranch

			If fVldObraRJ( @lParcial, .F. ) .And. !lParcial
				cRet := xFilial( "RJ4", cBranch )
			Else
				cRet := xFilial( "CTT", cBranch )
			EndIf

		ElseIf cEvent == "S-1010"
			cRet := xFilial( "SRV", cBranch )

		ElseIf cEvent == "S-1020"
			If fVldObraRJ( @lParcial, .F.) .And. !lParcial
				cRet := xFilial( "RJ3", cBranch )
			Else
				cRet := xFilial( "CTT", cBranch )
			EndIf

		ElseIf cEvent == "S-1030"
			If SuperGetMv("MV_CARGSQ3",,.F.)
				cRet := xFilial( "SQ3", cBranch )
			Else
				cRet := xFilial( "SRJ", cBranch )
			EndIf

		ElseIf cEvent == "S-1035"
			cRet := xFilial( "SGY", cBranch )

		ElseIf cEvent == "S-1040"
			cRet := xFilial( "SRJ", cBranch )

		ElseIf cEvent == "S-1050"
			cRet := xFilial( "SR6", cBranch )

		ElseIf cEvent $ ("S-1000|S-1200|S-1210|S-1295|S-1298|S-1299|S-1300|S-2190|S-2200|S-2205|S-2206|S-2210|S-2220|S-2230|S-2240|S-2250|S-2260|S-2299|S-2300|S-2306|S-2399|S-3000")
			cRet := cBranch
		EndIf
	EndIf

Return cRet


/*/{Protheus.doc} function fPreValid
Verifica se pode gerar um novo evento de exclusão
@author  Hugo de Oliveira
@since   16/12/2019
@version 1.0
/*/
Static Function fGetStat( cRecib )
	Local cStatus 	:= ""

	dbSelectArea( "RJE" )
	RJE->( DbSetOrder(4) ) // RJE_EVENTO, RJE_KEY
	RJE->( DbGoTop() )

	If RJE->( dbSeek( "S3000" + cRecib ) ) // A Key do S3000 é o recibo do evento que o gerou
		cStatus := RJE->RJE_STATUS
	EndIf

Return cStatus
