#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM017F.CH"

Static lCargSQ3 := SuperGetMv("MV_CARGSQ3",,.F.) //Define se o envio do evento S-1030 serão feito pela tabela SQ3 e não pela SRJ (Padrão .F. -> SRJ).
Static oStatSR8

//------------------------------------------------------------------
/*/{Protheus.doc} fPrcTab
Funcao que processa eventos contidos na tabela RED gravando-os na RJE de acordo com cada
tipo de evento.

@author		Silvio C. Stecca
@since		12/01/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Function GPEM017F(nTipOper)

	Local aArea			:= GetArea()
    Local aAreaRED		:= RED->(GetArea())
    Local aAreaSX3		:= SX3->(GetArea())
    Local aColsMark		:= {}
    Local oTmpTable		:= Nil
    Local aFieldFilt	:= {}
    Local aSeek			:= {}
    Local lContinua     := .T.
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

    Static _Marcados    := {}

	Private oMark
    Private cArqRED     := "REDAUX"
    Private aRedStruct  := RED->(DBSTRUCT())
    Private aMarcRED	:= {}

    Default nTipOper    := 1

    Static _Marcados	:= {}

	If lMiddleware
		// CRIA UM ARQUIVO TEMPORARIO
		lContinua := fCriaTmp(@oTmpTable, @aRedStruct, @aFieldFilt, nTipOper)

		If lContinua
			// PREENCHE O ARRAY COM AS COLUNAS
			aColsMark := fMntColsMark(aRedStruct)

			// INCLUI O SEEK QUE SERÁ USADO.
			aAdd(aSeek, {OemtoAnsi(STR0001), {{"", "C", FwGetTamFilial + TamSX3("RED_EVENTO")[1] + TamSX3("RED_CHVERP")[1] + TamSX3("RED_CNPJ")[1],, 0, "RED_FILIAL + RED_EVENTO + RED_CHVERP + RED_CNPJ", "@!"}}}) // "Filial + Evento + Chave ERP + CNPJ Destino"

			// INICIALIZA O BROWSE.
			oMark := FWMarkBrowse():New()

			// SETA AS PROPIEDADES DO BROWSE.
			oMark:SetAlias(cArqRED)
			oMark:SetFields(aColsMark)
			oMark:SetFieldMark('TAB_OK')
			oMark:SetMenuDef("")

			If nTipOper == 1
				oMark:AddButton(OemtoAnsi(STR0002), {|| ProcGpe({|lEnd| fPrcTabela()}, "" )},,,, .F., 2) // "Processar"
			Else
				oMark:AddButton(OemtoAnsi(STR0002), {|| ProcGpe({|lEnd| fPrcPeriod(nTipOper)}, "" )},,,, .F., 2) // "Processar"
			EndIf

			oMark:SetDescription(OemtoAnsi(STR0003)) // "Processar Eventos e-Social"
			oMark:SetFieldFilter(aFieldFilt)
			oMark:SetSeek(.T., aSeek)
			oMark:SetAfterMark({|| fMarca()})
			oMark:SetAllMark({|| fMarkAll()})

			// ATIVA O BROWSE PARA MARCAÇÃO.
			oMark:Activate()

		EndIf
	Else
		MsgAlert(STR0042) //"Para utilização do migrador, a empresa deverá operar com o Middleware ativado."
	EndIf
    // FECHA A TABELA TEMPORARIA CRIADA.
    If ValType(oTmpTable) == "O"
        oTmpTable:Delete()
    EndIf

    // ZERA O ARRAY
    _Marcados := {}

    // RESTAURA A AREA.
    RestArea(aArea)
    RestArea(aAreaRED)
    RestArea(aAreaSX3)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} fCriaTmp
Funcao que cria um arquivo temporário de acordo com os eventos que estão sendo importados.

@author		Silvio C. Stecca
@since		12/01/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fCriaTmp(oTmpTable, aColumns, aFldFilter, nTipOper)

	Local aCampos  	:= RED->(dbStruct())
    Local cAliasRED	:= GetNextAlias()
	Local cWhere	:= ""
	Local cEvntTab	:= "S-1000|S-1010|S-1020|S-1030|S-1035|S-1040|S-1050|S-1060|S-1070"
	Local cEnvtNPer := "S-2190|S-2200|S-2205|S-2206|S-2230|S-2298|S-2299|S-2300|S-2306|S-2399"
	Local cEnvtPer  := "S-1200|S-1298|S-1210|S-1299"
    Local nCont		:= 0
    Local lRet      := .T.

    If Select(cArqRED) > 0
		DbSelectArea(cArqRED)
		DbCloseArea()
	EndIf

	aAdd(aColumns, {"TAB_OK", "C", 02, 00})

	oTmpTable := FWTemporaryTable():New(cArqRED)
	oTmpTable:SetFields(aColumns)
	oTmpTable:AddIndex("IND", {aCampos[1, 1], aCampos[2, 1], aCampos[4, 1], aCampos[11, 1]}) // RED_FILIAL + RED_EVENTO + RED_CHVERP + RED_CNPJ
	oTmpTable:Create()

	cWhere := "% RED.RED_FILIAL = '" + xFilial("RED") + "'"

	Do Case
		Case nTipOper == 1
			cWhere += " AND RED.RED_EVENTO IN " + FORMATIN(cEvntTab, "|") + ""
		Case nTipOper == 2
			cWhere += " AND RED.RED_EVENTO IN " + FORMATIN(cEnvtNPer, "|") + ""
		Case nTipOper == 3
			cWhere += " AND RED.RED_EVENTO IN " + FORMATIN(cEnvtPer, "|") + ""
	EndCase

	cWhere += " AND RED.RED_STATUS = '3'"
	cWhere += " AND RED.RED_RECIBO <> ''"
	cWhere += " AND RED.D_E_L_E_T_ = ' '"
	cWhere += " %"

	BeginSql alias cAliasRED
		SELECT R_E_C_N_O_ AS RECNORED
		FROM %table:RED% RED
		WHERE %exp:cWhere%
	EndSql

    // POSICIONA NO INICIO DO ARQUIVO
    dbSelectArea(cAliasRED)
    (cAliasRED)->(dbGoTop())

	// CASO ENCONTRE REGISTRO OCNTINUA COM O PROCESSAMENTO DAS INFORMAÇÕES.
    If (cAliasRED)->(!Eof())
        While (cAliasRED)->(!EOF())

            // POSICIONA NO REGISTRO.
            RED->(dbGoto((cAliasRED)->RECNORED))

            If RecLock(cArqRED, .T.)
                (cArqRED)->RED_FILIAL 	:= RED->RED_FILIAL
                (cArqRED)->RED_EVENTO 	:= RED->RED_EVENTO
                (cArqRED)->RED_XMLERP	:= RED->RED_XMLERP
                (cArqRED)->RED_CHVERP	:= RED->RED_CHVERP
                (cArqRED)->RED_CHVGOV	:= RED->RED_CHVGOV
                (cArqRED)->RED_STATUS 	:= RED->RED_STATUS
                (cArqRED)->RED_RECIBO	:= RED->RED_RECIBO
                (cArqRED)->RED_DHPROC	:= RED->RED_DHPROC
                (cArqRED)->RED_INDEVT 	:= RED->RED_INDEVT
                (cArqRED)->RED_XMLTOT  	:= RED->RED_XMLTOT
                (cArqRED)->RED_CNPJ     := RED->RED_CNPJ
                (cArqRED)->RED_FILDES   := RED->RED_FILDES
                (cArqRED)->RED_RECEXC   := RED->RED_RECEXC
                (cArqRED)->RED_ALIAS    := RED->RED_ALIAS
                (cArqRED)->RED_DTIMP    := RED->RED_DTIMP
                (cArqRED)->RED_HRIMP    := RED->RED_HRIMP
                (cArqRED)->(MsUnlock())
            EndIf

            (cAliasRED)->(dbSkip())
        EndDo

        (cAliasRED)->(dbCloseArea())

        For nCont := 1 To Len(aColumns)
            aAdd(aFldFilter, {aColumns[nCont, 1], FWX3Titulo(aColumns[nCont, 1]), aColumns[nCont, 2], aColumns[nCont, 3], aColumns[nCont, 4], X3Picture(aColumns[nCont, 1])})
        Next nCont

    Else
        Help(' ', 1, OemtoAnsi(STR0006),, + CRLF + OemToAnsi(STR0034), 1, 0) //"Atenção"##"Nenhum registro encontrado."
        (cAliasRED)->(dbCloseArea())
        lRet := .F.
    EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} fMntColsMark
Funcao responsavel por montrar as colunas que serão exibidas.

@author		Silvio C. Stecca
@since		12/01/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fMntColsMark(aCampos)

	Local aArea		:= GetArea()
	Local aColsAux 	:=`{}
	Local aColsSX3	:= {}
	Local nX		:= 0

	DbSelectArea("SX3")
	DbSetOrder(2)

	For nX := 1 to Len(aCampos)
		If SX3->( dbSeek(aCampos[nX,1]) )
		    aColsSX3 := {X3Titulo(), &("{||(cArqRED)->" + (aCampos[nX, 1]) + "}"), SX3->X3_TIPO, SX3->X3_PICTURE, 1, SX3->X3_TAMANHO, SX3->X3_DECIMAL, .F.,,,,,,,, 1}
		    aAdd(aColsAux, aColsSX3)
		    aColsSX3 := {}
		EndIf
	Next nX

	RestArea(aArea)

Return aColsAux

//------------------------------------------------------------------
/*/{Protheus.doc} fMarca
Funcao responsavel por marcar o registro selecionado.

@author		Silvio C. Stecca
@since		12/01/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fMarca()

    Local nPos := aScan(aMarcRED, {|x| x[1] == (cArqRED)->RED_FILIAL .And. x[2] == (cArqRED)->RED_EVENTO .And. x[4] == (cArqRED)->RED_CHVERP})

    If oMark:IsMark()
		aAdd(aMarcRED, {(cArqRED)->RED_FILIAL   , ;
                        (cArqRED)->RED_EVENTO   , ;
                        (cArqRED)->RED_XMLERP   , ;
                        (cArqRED)->RED_CHVERP   , ;
                        (cArqRED)->RED_CHVGOV   , ;
                        (cArqRED)->RED_STATUS   , ;
                        (cArqRED)->RED_RECIBO   , ;
                        (cArqRED)->RED_DHPROC   , ;
                        (cArqRED)->RED_INDEVT   , ;
                        (cArqRED)->RED_XMLTOT   , ;
                        (cArqRED)->RED_CNPJ     , ;
                        (cArqRED)->RED_FILDES   , ;
                        (cArqRED)->RED_RECEXC   , ;
                        (cArqRED)->RED_ALIAS    , ;
                        (cArqRED)->RED_DTIMP    , ;
                        (cArqRED)->RED_HRIMP    } )

        Aadd(_Marcados, oMark:At())
    Else
        If nPos > 0
            nLastSize := Len(aMarcRED)
            aDel(aMarcRED, nPos)
            aDel(_Marcados, nPos)
            aSize(aMarcRED, (nLastSize - 1))
            aSize(_Marcados, (nLastSize - 1))
        EndIF
    EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} fMarkAll
Funcao responsavel por marcar todos os registros.

@author		Silvio C. Stecca
@since		12/01/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fMarkAll()

    Local nUltimo

    oMark:GoBottom(.F.)
    nUltimo := oMark:At()
    oMark:GoTop()

    While .T.
        oMark:MarkRec()
        If nUltimo == oMark:At()
            oMark:GoTop()
            Exit
        EndIf
        oMark:GoDown()
    EndDo

Return

//------------------------------------------------------------------
/*/{Protheus.doc} fPrcTabela
Funcao busca na tabela RDE dados referentes a eventos de tabela e grava-os na tabela RED.

@author		Silvio C. Stecca
@since		12/01/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fPrcTabela()

    Local aLogTitle	:= {OemtoAnsi(STR0004)}// "Eventos Processados:"
    Local aLogFile	:= {}
    Local nCont		:= 0
    Local cTpInscr  := ""
    Local cNumInscr := ""
    Local cEvento   := ""
    Local cDtGera   := ""
    Local cHrGera   := ""
    Local cRetKey   := ""
    Local cStaRED   := ""
    Local cDescSta  := OemtoAnsi(STR0005)
    Local cIndDev   := ""
    Local cOper     := "I"
    Local cRecibo   := ""
    Local cXmlRED   := ""
    Local lRegNew   := .T.
    Local lRetRJE   := .T.
    Local cIniVld   := ""
    Local aDados    := {}
	Local lVld1000	:= .T.
    Local cStatRJE	:= ""
    Local cCmplKey  := ""
    Local cRJEFil   := ""

    // CASO NÃO TENHA SELECIONADO ALGUM REGISTRO AVISA O USUÁRIO.
    If Len(aMarcRED) < 1
        Help(' ', 1, OemtoAnsi(STR0006),, OemtoAnsi(STR0007), 1, 0) //"Atenção"##"Nenhum evento foi selecionado."
        Return
    EndIf

    // INICIA A REGUA DE PROCESSAMENTO.
    GPProcRegua(Len(aMarcRED))

	// PERCORRE O ARRAY COM OS REGISTROS SELECIONADOS.
    For nCont := 1 To Len(aMarcRED)
        cTpInscr    := ""
        cNumInscr   := ""
        cEvento     := ""
        cDtGera     := ""
        cHrGera     := ""
        cRetKey     := ""
        cStaRED     := ""
        cIndDev     := ""
        cRecibo     := ""
        cXmlRED     := ""
        cRJEFil     := ""
        lVld1000    := fVld1000(AnoMes(dDataBase), @cStatRJE)
        aDados      := {}

        // CASO NÃO ENCONTRE PROBLEMA NO PREDECESSOR S-1000 CONTINUA.
        If lVld1000
            cTpInscr    := Iif(SM0->M0_TPINSC == 2, "1", "2")
            cNumInscr   := SubStr(SM0->M0_CGC, 1, 8)
            cEvento     := StrTran(aMarcRED[nCont, 2], "-", "")
            cDtGera     := StrTran(SubStr(aMarcRED[nCont, 8], 1, 10), "-", "")
            cHrGera     := StrTran(SubStr(aMarcRED[nCont, 8], 12, 8), "-", "")
            cRetKey     := Alltrim(aMarcRED[nCont, 5])
            cStaRED     := "4"
            cIndDev     := Alltrim(aMarcRED[nCont, 9])
            cRecibo     := Alltrim(aMarcRED[nCont, 7])
            cXmlRED     := Alltrim(aMarcRED[nCont, 3])
            cRJEFil     := Iif(Empty(fRetFilEvt(cEvento)), cFilAnt, fRetFilEvt(cEvento))

            // CASO TENHA SELECIONADO UM REGISTRO SEM RECIBO.
            If Empty(cRecibo)
                aAdd(aLogfile, OemtoAnsi(STR0029) + aMarcRED[nCont, 2] + OemtoAnsi(STR0032) + Alltrim(cRetKey) + OemtoAnsi(STR0033)) //"Evento: "  ### " com o ID do governo: " ### " não possui número de recibo e não será processado"
                Loop
            EndIf

            RJE->(dbSetOrder(5)) // RJE_EVENTO + RJE_RECIB
            If !RJE->(MsSeek(cEvento + cRecibo))

                // ACRESCENTA REGISTRO PROCESSADO A REGUA DE PROCESSAMENTO.
                GPIncProc(OemtoAnsi(STR0029) + aMarcRED[nCont, 2] + OemtoAnsi(STR0028) + Alltrim(cRecibo)) // " Evento: "

                // BUSCA INFORMAÇÕES DO XML DO REGISTRO MARCADO.
                fReadXml(cXmlRED, @cCmplKey, cEvento, @cIniVld)

                aAdd(aDados, {  xFilial("RJE", cFilAnt) , ; // 1 - RJE_FILIAL
                                cRJEFil                 , ; // 2 - RJE_FIL
                                cTpInscr                , ; // 3 - RJE_TPINSC
                                cNumInscr               , ; // 4 - RJE_INSCR
                                cEvento                 , ; // 5 - RJE_EVENTO
                                cIniVld                 , ; // 6 - RJE_INI
                                cRJEFil + cCmplKey      , ; // 7 - RJE_KEY
                                cRetKey                 , ; // 8 - RJE_RETKEY
                                cIndDev                 , ; // 9 - RJE_RETF
                                cDescSta                , ; // 10 - RJE_VERS
                                cStaRED                 , ; // 11 - RJE_STATUS
                                sTod(cDtGera)           , ; // 12 - RJE_DTG
                                cHrGera                 , ; // 13 - RJE_HORAG
                                cOper                   , ; // 14 - RJE_OPER
                                cRecibo                 , ; // 15 - RJE_RECIB
                                ""                      } ) // 16 - RJE_RECANT

                // GRAVA O REGISTRO NA TABELA RJE.
                If !(lRetRJE := fGravaRJE(aDados, cXmlRED, lRegNew))
                    aAdd(aLogfile, OemtoAnsi(STR0006) + cEvento + OemtoAnsi(STR0008) + Alltrim(cRecibo)) //"Atenção"###"Ocorreu um erro na gravação do registro na tabela RJE.  Evento: "
                Else
                    aAdd(aLogfile, OemtoAnsi(STR0029) + aMarcRED[nCont, 2] + OemtoAnsi(STR0028) + Alltrim(cRecibo) + OemtoAnsi(STR0027)) //"Evento: "###" Recibo: "###" processado com sucesso."
                EndIf
            Else
                aAdd(aLogfile, OemtoAnsi(STR0029) + aMarcRED[nCont, 2] + OemtoAnsi(STR0030) + Alltrim(cRecibo) + OemtoAnsi(STR0031))//"Evento: "###" não processado pois já existe informação do recibo: "###" na tabela RJE."
            EndIf

			// MUDA O STATUS NA TABELA RED DO EVENTO PROCESSADO.
            RED->(dbSetOrder(2)) // RED_FILIAL + RED_CHVGOV + RED_CNPJ
			If RED->(MsSeek(aMarcRED[nCont, 1] + aMarcRED[nCont, 5] + aMarcRED[nCont, 11]))
				If RED->(RecLock("RED", .F.))
					RED->RED_STATUS := "5"
					RED->( MsUnlock() )
				EndIf
			EndIf
        Else
            Do Case
                Case cStatRJE == "-1" // nao encontrado na base de dados
                    aAdd(aLogfile, OemtoAnsi(STR0009)) //"Registro do evento S-1000 não localizado na base de dados"

                Case cStatRJE == "1" // nao enviado para o governo
                    aAdd(aLogfile, OemtoAnsi(STR0010)) //"Registro do evento S-1000 não transmitido para o governo"

                Case cStatRJE == "2" // enviado e aguardando retorno do governo
                    aAdd(aLogfile, OemtoAnsi(STR0011))//"Registro do evento S-1000 aguardando retorno do governo"

                Case cStatRJE == "3" // enviado e retornado com erro
                    aAdd(aLogfile, OemtoAnsi(STR0012)) //"Registro do evento S-1000 retornado com erro do governo"
            EndCase

            Exit
        EndIf

    Next nCont

    // GRAVA O LOG.
    fMakeLog({aLogFile}, aLogTitle, NIL, NIL, OemToAnsi(STR0014), OemToAnsi(STR0015), NIL, NIL, NIL, .F. ) //"Lote"##"Log de Ocorrências"

    // FECHA O BROWSE.
    CloseBrowse()

Return ()

//------------------------------------------------------------------
/*/{Protheus.doc} fPrcPeriod
Busca na tabela RED dados referentes a eventos periodicos e nao periodicos e grava-os na tabela RJE.
@type		Static Function
@author		Silvio C. Stecca
@since		27/01/2021
@version	2.0
/*/
//------------------------------------------------------------------
Static Function fPrcPeriod(nTipOper)

    Local aLogTitle	:= {OemtoAnsi(STR0004)}// "Eventos Processados:"
	Local aLogFile	:= {}
    Local nCont		:= 0
    Local cTpInscr  := ""
    Local cNumInscr := ""
    Local cEvento   := ""
    Local cDtGera   := ""
    Local cHrGera   := ""
    Local cRetKey   := ""
    Local cStaRED   := ""
    Local cDescSta  := OemtoAnsi(STR0005)
    Local cIndDev   := ""
    Local cOper     := "I"
    Local cRecibo   := ""
    Local cXmlRED   := ""
    Local lRegNew   := .T.
    Local lRetRJE   := .T.
    Local cIniVld   := ""
    Local aDados    := {}
	Local lVld1000	:= .T.
    Local cStatRJE	:= "-1"
    Local cCmplKey  := ""
    Local cRJEFil   := ""
    Local ciDmDev   := ""
    Local cIndApur  := ""
    Local cKeyRJE   := ""
    Local aErros    := {}
    Local cChvMid   := ""
    Local cStat1    := ""
    Local cRaCodUn  := ""
	Local cCatVinc	:= fCatTrabEFD("TCV")
	Local aOrdProc	:= {}

    // CASO NÃO TENHA SELECIONADO ALGUM REGISTRO AVISA O USUÁRIO.
    If Len(aMarcRED) < 1
        Help(' ', 1, OemtoAnsi(STR0006),, OemtoAnsi(STR0007), 1, 0) //"Atenção"##"Nenhum evento foi selecionado."
        Return
    EndIf

	// INICIA A REGUA DE PROCESSAMENTO.
	GPProcRegua(Len(aMarcRED))

	If nTipOper == 2
		aSort(aMarcRED,,, { |x,y| x[2] < y[2] })	// array vem por ordem de seleção, ordenar por evento
		If (nCont := aScan(aMarcRed, {|x| x[2] == "S-2300"})) > 0 //Processar 2300 antes de 2205/2230
			While nCont <= Len(aMarcRed) .And. aMarcRed[nCont][2] == "S-2300"
				aAdd(aOrdProc, aMarcRed[nCont] )
				nCont++
			EndDo
		EndIf
		For nCont := 1 to Len(aMarcRed)
			If !(aMarcRed[nCont][2] $ "S-2300|S-2298")
				aAdd(aOrdProc, aMarcRed[nCont])
			EndIf
		Next nCont
		If (nCont := aScan(aMarcRed, {|x| x[2] == "S-2298"})) > 0 //Processar 2299 antes de 2298
			While nCont <= Len(aMarcRed) .And. aMarcRed[nCont][2] == "S-2298"
				aAdd(aOrdProc, aMarcRed[nCont] )
				nCont++
			EndDo
		EndIf
		aMarcRed := aOrdProc
	Else	//periódicos ordenar alfab. desc p/ processar 1299 antes de 1298
		aSort(aMarcRED,,, { |x,y| x[2] > y[2] })
	EndIf

	// PERCORRE O ARRAY COM OS REGISTROS SELECIONADOS.
	For nCont := 1 To Len(aMarcRED)
		cTpInscr    := ""
		cNumInscr   := ""
		cEvento     := ""
		cDtGera     := ""
		cHrGera     := ""
		cRetKey     := ""
		cStaRED     := ""
		cIndDev     := ""
		cRecibo     := ""
		cXmlRED     := ""
		cRJEFil     := ""
		lVld1000    := fVld1000(AnoMes(dDataBase), @cStatRJE)
		aDados      := {}
		cKeyRJE     := ""
		ciDmDev     := ""
		cIndApur    := ""
		aErros      := {}
		cChvMid     := ""
		cStat1      := "-1"
		cRaCodUn    := ""
		cIniVld		:= ""

		// CASO NÃO ENCONTRE PROBLEMA NO PREDECESSOR S-1000 CONTINUA.
		If lVld1000
			cTpInscr    := Iif(SM0->M0_TPINSC == 2, "1", "2")
			cNumInscr   := SubStr(SM0->M0_CGC, 1, 8)
			cEvento     := StrTran(aMarcRED[nCont, 2], "-", "")
			cDtGera     := StrTran(SubStr(aMarcRED[nCont, 8], 1, 10), "-", "")
			cHrGera     := StrTran(SubStr(aMarcRED[nCont, 8], 12, 8), "-", "")
			cRetKey     := Alltrim(aMarcRED[nCont, 5])
			cStaRED     := "4"
			cIndDev     := Alltrim(aMarcRED[nCont, 9])
			cRecibo     := Alltrim(aMarcRED[nCont, 7])
			cXmlRED     := Alltrim(aMarcRED[nCont, 3])
			cRJEFil     := Iif(Empty(fRetFilEvt(cEvento)), cFilAnt, fRetFilEvt(cEvento))

			// CASO TENHA SELECIONADO UM REGISTRO SEM RECIBO.
			If Empty(cRecibo)
				aAdd(aLogfile, OemtoAnsi(STR0029) + aMarcRED[nCont, 2] + OemtoAnsi(STR0032) + Alltrim(cRetKey) + OemtoAnsi(STR0033)) //"Evento: "  ### " com o ID do governo: " ### " não possui número de recibo e não será processado"
				Loop
			EndIf

			RJE->(dbSetOrder(5)) // RJE_EVENTO + RJE_RECIB
			If !RJE->(MsSeek(cEvento + cRecibo))

				If RJE->(ColumnPos("RJE_IDMDEV")) <= 0
					aAdd(aLogfile, OemToAnsi(STR0038)) // "Campo RJE_IDMDEV não incorporado a tabela RJE. O processamento dos eventos periódicos não será concluido."
					Exit
				EndIf

				// ACRESCENTA REGISTRO PROCESSADO A REGUA DE PROCESSAMENTO.
				GPIncProc(OemtoAnsi(STR0029) + aMarcRED[nCont, 2] + OemtoAnsi(STR0028) + Alltrim(cRecibo)) // " Evento: "

				// BUSCA INFORMAÇÕES DO XML DO REGISTRO MARCADO.
				fReadXml(cXmlRED, @cCmplKey, cEvento, @cIniVld, @ciDmDev, @cIndApur)

				If ntipOper == 3	//Periódicos
					If cEvento $ "S1200|S1210"
						cKeyRJE     := cIniVld + cIndApur + cCmplKey
						cRaCodUn    := Posicione("SRA", 5, cFilAnt + cCmplKey, "RA_CODUNIC")
						cChvMid     := cTpInscr + Padr(cNumInscr, 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")

						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE(2, cChvMid, @cStat1)

						If cStat1 == "-1"
							aAdd(aLogfile, OemtoAnsi(STR0029) + cEvento + "-" + OemToAnsi(STR0036) + " " + OemToAnsi(STR0037) + cCmplKey +  OemToAnsi(STR0035)) //##" "[FALHA] Não foi possivel encontrar o registro do Funcionário
							Loop
						EndIf

					Else
						cKeyRJE := cFilAnt + cIniVld + cIndApur
						cS1299  := fRegRJE(cFilAnt, cTpInscr, cNumInscr, "S1299", cKeyRJE)

						If cEvento == 'S1298' .And. cS1299 == "N"
							aAdd(aLogfile, OemtoAnsi(STR0029) + cEvento + "-" + OemToAnsi(STR0039)) //##"[FALHA] Não encontrado registro S-1299 para o periodo informado."
							Loop
						EndIf

					EndIf
				Else	//Não periódicos
					Do Case
						Case cEvento $ "S2190|S2200|S2206|S2298|S2299|S2300"
							cKeyRJE := cCmplKey
							If cEvento $ "S2206|S2299"
								cChvMid := cTpInscr + Padr(cNumInscr, 14) + "S2200" + cKeyRJE
							ElseIf cEvento == "S2298"
								cChvMid := cTpInscr + Padr(cNumInscr, 14) + "S2299" + cKeyRJE
							EndIf

						Case cEvento $ "S2205|S2230"	//sempre buscar chave pelo CPF, fIntAdmiss usa fCatTrabEFD("TCV")
							cKeyRJE := Posicione("SRA", 5, cFilAnt + cCmplKey, "RA_CODUNIC")
							If Empty(cKeyRJE)
								aAdd(aLogfile, OemtoAnsi(STR0029) + cEvento + "-" + OemToAnsi(STR0036) + " " + cCmplKey +  OemToAnsi(STR0040)) //##" "[FALHA] Não foi possivel encontrar o registro do Funcionário na base de dados
								Loop
							EndIf
							cChvMid := cTpInscr + Padr(cNumInscr, 14) + "S2200" + cKeyRJE
							If !(SRA->RA_CATEFD $ cCatVinc)
								cKeyRJE := cCmplKey + SRA->RA_CATEFD + Dtos(SRA->RA_ADMISSA)
								cChvMid := cTpInscr + Padr(cNumInscr, 14) + "S2300" + cKeyRJE
							EndIf

							If cEvento == 'S2230'
								If Right(cIniVld, 1) $ 'C|I'
									cKeyRJE += cIniVld
								ElseIf fIniAfast(SRA->RA_MAT, @cIniVld)
									cKeyRJE += cIniVld + "F"
								Else
									aAdd(aLogfile, OemtoAnsi(STR0029) + cEvento + "-" + OemToAnsi(STR0041) + " " + cCmplKey +  OemToAnsi(STR0040)) //##" "[FALHA] Não encontrado registro do afastamento para o funcionário na base de dados
									Loop
								EndIf
								cIniVld := ""
							EndIf

						Case cEvento $ 'S2306|S2399"
							cKeyRJE := cCmplKey + DtoS(Posicione("SRA", 5, cFilAnt + cCmplKey, "RA_ADMISSA"))
							cChvMid := cTpInscr + Padr(cNumInscr, 14) + "S2300" + cKeyRJE
					EndCase
					If !Empty(cChvMid)
						GetInfRJE(2, cChvMid, @cStat1)
						If cStat1 == "-1"
							aAdd(aLogfile, OemtoAnsi(STR0029) + cEvento + "-" + OemToAnsi(STR0036) + " " + cCmplKey +  OemToAnsi(STR0035)) //##" "[FALHA] Não foi possivel encontrar o registro do Funcionário
							Loop
						EndIf
					EndIf

				EndIf

				aAdd(aDados, {  xFilial("RJE", cFilAnt) , ; // 1 - RJE_FILIAL
								cRJEFil                 , ; // 2 - RJE_FIL
								cTpInscr                , ; // 3 - RJE_TPINSC
								cNumInscr               , ; // 4 - RJE_INSCR
								cEvento                 , ; // 5 - RJE_EVENTO
								cIniVld                 , ; // 6 - RJE_INI
								cKeyRJE                 , ; // 7 - RJE_KEY
								cRetKey                 , ; // 8 - RJE_RETKEY
								cIndDev                 , ; // 9 - RJE_RETF
								cDescSta                , ; // 10 - RJE_VERS
								cStaRED                 , ; // 11 - RJE_STATUS
								sTod(cDtGera)           , ; // 12 - RJE_DTG
								cHrGera                 , ; // 13 - RJE_HORAG
								cOper                   , ; // 14 - RJE_OPER
								cRecibo                 , ; // 15 - RJE_RECIB
								""                      , ; // 16 - RJE_RECANT
								ciDmDev                 } ) // 17 - RJE_IDMDEV

				// GRAVA O REGISTRO NA TABELA RJE.
				If !(lRetRJE := fGravaRJE(aDados, cXmlRED, lRegNew))
					aAdd(aLogfile, OemtoAnsi(STR0006) + cEvento + OemtoAnsi(STR0008) + Alltrim(cRecibo)) //"Atenção"###"Ocorreu um erro na gravação do registro na tabela RJE.  Evento: "
				Else
					aAdd(aLogfile, OemtoAnsi(STR0029) + aMarcRED[nCont, 2] + OemtoAnsi(STR0028) + Alltrim(cRecibo) + OemtoAnsi(STR0027)) //"Evento: "###" Recibo: "###" processado com sucesso."

					// MUDA O STATUS NA TABELA RED DO EVENTO PROCESSADO
					RED->(dbSetOrder(2)) // RED_FILIAL + RED_CHVGOV + RED_CNPJ
					If RED->(MsSeek(aMarcRED[nCont, 1] + aMarcRED[nCont, 5] + aMarcRED[nCont, 11]))
						If RED->(RecLock("RED", .F.))
							RED->RED_STATUS := "5"
							RED->( MsUnlock() )
						EndIf
					EndIf
				EndIf
			Else
				aAdd(aLogfile, OemtoAnsi(STR0029) + aMarcRED[nCont, 2] + OemtoAnsi(STR0030) + Alltrim(cRecibo) + OemtoAnsi(STR0031))//"Evento: "###" não processado pois já existe informação do recibo: "###" na tabela RJE."
			EndIf
		Else
			Do Case
				Case cStatRJE == "-1" // nao encontrado na base de dados
					aAdd(aLogfile, OemtoAnsi(STR0009)) //"Registro do evento S-1000 não localizado na base de dados"

				Case cStatRJE == "1" // nao enviado para o governo
					aAdd(aLogfile, OemtoAnsi(STR0010)) //"Registro do evento S-1000 não transmitido para o governo"

				Case cStatRJE == "2" // enviado e aguardando retorno do governo
					aAdd(aLogfile, OemtoAnsi(STR0011))//"Registro do evento S-1000 aguardando retorno do governo"

				Case cStatRJE == "3" // enviado e retornado com erro
					aAdd(aLogfile, OemtoAnsi(STR0012)) //"Registro do evento S-1000 retornado com erro do governo"
			EndCase

			Exit
		EndIf

	Next nCont

	// GRAVA O LOG.
	fMakeLog({aLogFile}, aLogTitle, NIL, NIL, OemToAnsi(STR0014), OemToAnsi(STR0015), NIL, NIL, NIL, .F. ) //"Lote"##"Log de Ocorrências"

	// FECHA O BROWSE.
	CloseBrowse()

Return ()

//------------------------------------------------------------------
/*/{Protheus.doc} fReadXml
Funcao que lê o arquivo xml que esta sendo usado no processo.

@author		Silvio C. Stecca
@since		12/01/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fReadXml(cXmlRED, cCmplKey, cEvento, cIniVld, ciDmDev, cIndApur)

    Local cWarning   := ""
    Local cError     := ""
	Local cCpf			:= ""
	Local cDtAdm		:= ""
	Local cCategTSV		:= ""
	Local lAfastIni		:= .F.
    Private oXmlRED

    Default cCmplKey    := ""
    Default cEvento     := ""
    Default cIniVld     := ""
    Default ciDmDev     := ""
    Default cIndApur    := ""

    // MONTA O OBJETO COM OS DADOS DO XML.
    oXmlRED := XmlParser(cXmlRED, "_", @cError, @cWarning )

    Do Case
        Case cEvento = "S1010"
            cCmplKey    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABRUBRICA:_INFORUBRICA:_INCLUSAO:_IDERUBRICA:_CODRUBR,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABRUBRICA:_INFORUBRICA:_INCLUSAO:_IDERUBRICA:_INIVALID,"TEXT"), "-", "")

        Case cEvento = "S1020"
            cCmplKey    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABLOTACAO:_INFOLOTACAO:_INCLUSAO:_IDELOTACAO:_CODLOTACAO,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABLOTACAO:_INFOLOTACAO:_INCLUSAO:_IDELOTACAO:_INIVALID,"TEXT"), "-", "")

        Case cEvento = "S1030"
            cCmplKey    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABCARGO:_INFOCARGO:_INCLUSAO:_IDECARGO:_CODCARGO,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABCARGO:_INFOCARGO:_INCLUSAO:_IDECARGO:_INIVALID,"TEXT"), "-", "")

        Case cEvento = "S1035"
            cCmplKey    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABCARREIRA:_INFOCARREIRA:_INCLUSAO:_IDECARREIRA:_CODLOTACAO,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABCARREIRA:_INFOCARREIRA:_INCLUSAO:_IDECARREIRA:_INIVALID,"TEXT"), "-", "")

        Case cEvento = "S1040"
            cCmplKey    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABFUNCAO:_INFOFUNCAO:_INCLUSAO:_IDEFUNCAO:_CODCARGO,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABFUNCAO:_INFOFUNCAO:_INCLUSAO:_IDEFUNCAO:_INIVALID,"TEXT"), "-", "")

        Case cEvento = "S1050"
            cCmplKey    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABHORTUR:_INFOHORCONTRATUAL:_INCLUSAO:_IDEHORCONTRATUAL:_CODHORCONTRAT,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABHORTUR:_INFOHORCONTRATUAL:_INCLUSAO:_IDEHORCONTRATUAL:_INIVALID,"TEXT"), "-", "")

        Case cEvento = "S1060"
            cCmplKey    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABAMBIENTE:_INFOAMBIENTE:_INCLUSAO:_IDEAMBIENTE:_CODAMB,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABAMBIENTE:_INFOAMBIENTE:_INCLUSAO:_IDEAMBIENTE:_INIVALID,"TEXT"), "-", "")

        Case cEvento = "S1070"
            cCmplKey    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABPROCESSO:_INFOPROCESSO:_INCLUSAO:_IDEPROCESSO:_NRPROC,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTTABPROCESSO:_INFOPROCESSO:_INCLUSAO:_IDEPROCESSO:_INIVALID,"TEXT"), "-", "")

        Case cEvento = "S1200"
            cCmplKey    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTREMUN:_IDETRABALHADOR:_CPFTRAB,"TEXT")
            cIndApur    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTREMUN:_IDEEVENTO:_INDAPURACAO,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTREMUN:_IDEEVENTO:_PERAPUR,"TEXT"), "-", "")
            ciDmDev     := fRetDmDev(oXmlRED, cEvento)

        Case cEvento = "S1210"
            cCmplKey    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTPGTOS:_IDEBENEF:_CPFBENEF,"TEXT")
            cIndApur    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTPGTOS:_IDEEVENTO:_INDAPURACAO,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTPGTOS:_IDEEVENTO:_PERAPUR,"TEXT"), "-", "")
            ciDmDev     := fRetDmDev(oXmlRED, cEvento)

        Case cEvento = "S1298"
            cIndApur    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTREABREEVPER:_IDEEVENTO:_INDAPURACAO,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTREABREEVPER:_IDEEVENTO:_PERAPUR,"TEXT"), "-", "")

        Case cEvento = "S1299"
            cIndApur    := XmlChildEx(oXmlRED:_ESOCIAL:_EVTFECHAEVPER:_IDEEVENTO:_INDAPURACAO,"TEXT")
            cIniVld     := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTFECHAEVPER:_IDEEVENTO:_PERAPUR,"TEXT"), "-", "")
	// Não periódicos
		Case cEvento == "S2190"
			cCpf		:= XmlChildEx(oXmlRED:_ESOCIAL:_EVTADMPRELIM:_INFOREGPRELIM:_CPFTRAB,"TEXT")
			cDtAdm		:= StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTADMPRELIM:_INFOREGPRELIM:_DTNASCTO,"TEXT"), "-", "")
			cCmplKey	:= cCpf + cDtAdm

		Case cEvento == "S2200"
			cCmplKey	:= XmlChildEx(oXmlRED:_ESOCIAL:_EVTADMISSAO:_VINCULO:_MATRICULA,"TEXT")

		Case cEvento == "S2205"
			cCmplKey	:= XmlChildEx(oXmlRED:_ESOCIAL:_EVTALTCADASTRAL:_IDETRABALHADOR:_CPFTRAB,"TEXT")

		Case cEvento == "S2206"
			cCmplKey	:= XmlChildEx(oXmlRED:_ESOCIAL:_EVTALTCONTRATUAL:_IDEVINCULO:_MATRICULA,"TEXT")

		Case cEvento == "S2230"
			cCmplKey	:= XmlChildEx(oXmlRED:_ESOCIAL:_EVTAFASTTEMP:_IDEVINCULO:_CPFTRAB,"TEXT")
			If XmlChildEx(oXmlRED:_ESOCIAL:_EVTAFASTTEMP:_INFOAFASTAMENTO, "_INIAFASTAMENTO") <> Nil
				cIniVld := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTAFASTTEMP:_INFOAFASTAMENTO:_INIAFASTAMENTO:_DTINIAFAST,"TEXT"), "-", "")
				lAfastIni := .T.
			EndIf
			If XmlChildEx(oXmlRED:_ESOCIAL:_EVTAFASTTEMP:_INFOAFASTAMENTO, "_FIMAFASTAMENTO") <> Nil
				If lAfastIni
					cIniVld += "C"
				Else
					cIniVld := StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTAFASTTEMP:_INFOAFASTAMENTO:_FIMAFASTAMENTO:_DTTERMAFAST,"TEXT"), "-", "")
				EndIf
			Else
				cIniVld += "I"
			EndIf

		Case cEvento == "S2298"
			cCmplKey	:= XmlChildEx(oXmlRED:_ESOCIAL:_EVTREINTEGR:_IDEVINCULO:_MATRICULA,"TEXT")

		Case cEvento == "S2299"
			cCmplKey	:= XmlChildEx(oXmlRED:_ESOCIAL:_EVTDESLIG:_IDEVINCULO:_MATRICULA,"TEXT")
			ciDmDev		:= fRetDmDev(oXmlRED, cEvento)

		Case cEvento == "S2300"
			cCpf		:= XmlChildEx(oXmlRED:_ESOCIAL:_EVTTSVINICIO:_TRABALHADOR:_CPFTRAB,"TEXT")
			cCategTSV	:= XmlChildEx(oXmlRED:_ESOCIAL:_EVTTSVINICIO:_INFOTSVINICIO:_CODCATEG,"TEXT")
			cDtAdm		:= StrTran(XmlChildEx(oXmlRED:_ESOCIAL:_EVTTSVINICIO:_INFOTSVINICIO:_DTINICIO,"TEXT"), "-", "")
			cCmplKey	:= cCpf + cCategTSV + cDtAdm

		Case cEvento == "S2306"
			cCpf		:= XmlChildEx(oXmlRED:_ESOCIAL:_EVTTSVALTCONTR:_IDETRABSEMVINCULO:_CPFTRAB,"TEXT")
			cCategTSV	:= XmlChildEx(oXmlRED:_ESOCIAL:_EVTTSVALTCONTR:_IDETRABSEMVINCULO:_CODCATEG,"TEXT")
			cCmplKey	:= cCpf + cCategTSV

		Case cEvento == "S2399"
			cCpf		:= XmlChildEx(oXmlRED:_ESOCIAL:_evtTSVTermino:_ideTrabSemVinculo:_CPFTRAB,"TEXT")
			cCategTSV	:= XmlChildEx(oXmlRED:_ESOCIAL:_evtTSVTermino:_ideTrabSemVinculo:_CODCATEG,"TEXT")
			cCmplKey	:= cCpf + cCategTSV
			ciDmDev		:= fRetDmDev(oXmlRED, cEvento)
	EndCase

Return ()

//------------------------------------------------------------------
/*/{Protheus.doc} fRetFilEvt
Funcao responsavel por retornar a filial de acordo com o evento que esta sendo processado.

@author		Silvio C. Stecca
@since		12/01/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fRetFilEvt(cEvento)

    Local cFilEvt := ""

    Do Case
        Case cEvento = "S1010"
            cFilEvt := xFilial("SRV", cFilAnt)

        Case cEvento = "S1020"
            cFilEvt := xFilial("CTT", cFilAnt)

        Case cEvento $ "S1030|S1040" .And. lCargSQ3
            cFilEvt := xFilial("SQ3", cFilAnt)

        Case  cEvento $ "S1030|S1040" .And. !lCargSQ3
            cFilEvt := xFilial("SRJ", cFilAnt)

        Case cEvento = "S1035"
            cFilEvt := xFilial("SGY", cFilAnt)

        Case cEvento = "S1050"
            cFilEvt := xFilial("SPJ", cFilAnt)

    EndCase

Return cFilEvt

//------------------------------------------------------------------
/*/{Protheus.doc} fRetDmDev
Funcao responsavel por retornar a composição da taf idDemDev.

@author		Silvio C. Stecca
@since		12/01/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fRetDmDev(oXml, cEvento)

    Local cIdMDev   := ""
    Local nI        := 0

	// SE NÃO FOR UM ARRAY
    Do Case
        Case cEvento == "S1200"
            If ValType(oXml:_ESOCIAL:_EVTREMUN:_DMDEV:_IDEDMDEV) != "A"
                // TRANSFORMA EM ARRAY
                XmlNode2Arr(oXml:_ESOCIAL:_EVTREMUN:_DMDEV:_IDEDMDEV, "_IDEDMDEV")
            EndIf

            // PERCORRE O ARRAY PARA OBTER TODOS OS IDMDEV.
            For nI := 1 To Len(oXml:_ESOCIAL:_EVTREMUN:_DMDEV:_IDEDMDEV)
                cIdMDev += oXml:_ESOCIAL:_EVTREMUN:_DMDEV:_IDEDMDEV[nI]:Text + "|"
            Next nI

        Case cEvento == "S1210"
            If ValType(oXml:_ESOCIAL:_EVTPGTOS:_IDEBENEF:_INFOPGTO:_DETPGTOFL:_IDEDMDEV) != "A"
                // TRANSFORMA EM ARRAY
                XmlNode2Arr(oXml:_ESOCIAL:_EVTPGTOS:_IDEBENEF:_INFOPGTO:_DETPGTOFL:_IDEDMDEV, "_IDEDMDEV")
            EndIf

            // PERCORRE O ARRAY PARA OBTER TODOS OS IDMDEV.
            For nI := 1 To Len(oXml:_ESOCIAL:_EVTPGTOS:_IDEBENEF:_INFOPGTO:_DETPGTOFL:_IDEDMDEV)
                cIdMDev += oXml:_ESOCIAL:_EVTPGTOS:_IDEBENEF:_INFOPGTO:_DETPGTOFL:_IDEDMDEV[nI]:Text + "|"
            Next nI

		Case cEvento == "S2299"
			If ValType(oXml:_ESOCIAL:_EVTDESLIG:_INFODESLIG:_VERBASRESC:_DMDEV) != "A"
				XmlNode2Arr(oXml:_ESOCIAL:_EVTDESLIG:_INFODESLIG:_VERBASRESC:_DMDEV, "_DMDEV")
			EndIF

			For nI := 1 to Len(oXml:_ESOCIAL:_EVTDESLIG:_INFODESLIG:_VERBASRESC:_DMDEV)
				cIdmDev += oXml:_ESOCIAL:_EVTDESLIG:_INFODESLIG:_VERBASRESC:_DMDEV[nI]:_IDEDMDEV:Text + "|"
			Next nI

		Case cEvento == "S2399"
			If ValType(oXml:_ESOCIAL:_EVTTSVTERMINO:_INFOTSVTERMINO:_VERBASRESC:_DMDEV) != "A"
				XmlNode2Arr(oXml:_ESOCIAL:_EVTTSVTERMINO:_INFOTSVTERMINO:_VERBASRESC:_DMDEV, "_DMDEV")
			EndIF

			For nI := 1 to Len(oXml:_ESOCIAL:_EVTTSVTERMINO:_INFOTSVTERMINO:_VERBASRESC:_DMDEV)
				cIdmDev += oXml:_ESOCIAL:_EVTTSVTERMINO:_INFOTSVTERMINO:_VERBASRESC:_DMDEV[nI]:_IDEDMDEV:Text + "|"
			Next nI
	EndCase

Return cIdMDev

/*/{Protheus.doc} fIniAfast
Busca data inicial do afastamento a partir da data final do XML
@type	Static Function
@author	isabel.noguti
@since	02/02/2021
@version 1.0
/*/
Static Function fIniAfast(cMat, cDtVld)
	Local aArea		:= GetArea()
	Local cAliasSR8	:= GetNextAlias()
	Local cQrySR8	:= ""
	Local lRet		:= .F.

	If oStatSR8 == Nil
		oStatSR8 := FWPreparedStatement():New()

		cQrySR8 := "SELECT SR8.R8_DATAINI "
		cQrySR8 += "FROM " +RetSqlName("SR8") + " SR8 "
		cQrySR8 += "WHERE SR8.R8_FILIAL = ? AND "
		cQrySR8 +=		"SR8.R8_MAT = ? AND "
		cQrySR8 +=		"SR8.R8_DATAFIM = ? AND "
		cQrySR8 +=		"SR8.D_E_L_E_T_ = ' '"
		cQrySR8 := ChangeQuery(cQrySR8)
		oStatSR8:SetQuery(cQrySR8)
	EndIf

	oStatSR8:SetString(1, cFilAnt)
	oStatSR8:SetString(2, cMat)
	oStatSR8:SetString(3, cDtVld)
	cQrySR8 := oStatSR8:getFixQuery()
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQrySR8), cAliasSR8, .T., .T.)
	If (cAliasSR8)->(!EoF())
		cDtVld := (cAliasSR8)->R8_DATAINI
		lRet := .T.
	EndIf

	(cAliasSR8)->(dbCloseArea())
	RestArea(aArea)

Return lRet
