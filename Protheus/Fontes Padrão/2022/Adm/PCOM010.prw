#Include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#Include "PCOM010.CH"

Static __aPCOM010 := {}

// Defines do grupo de perguntas.
#Define POS_DATINI 01 // Data Inicial
#Define POS_DATFIM 02 // Data Final
#Define POS_TIPSLD 03 // Tipo de Saldo
#Define POS_FILINI 04 // Finial Inicial
#Define POS_FILFIM 05 // Filial Final
#Define POS_COINI  06 // Conta Or�ament�ria Inicial
#Define POS_COFIM  07 // Conta Or�ament�ria Final
#Define POS_CLOINI 08 // Classe Or�ament�ria Inicial
#Define POS_CLOFIM 09 // Classe Or�ament�ria Final
#Define POS_OPOINI 10 // Opera��o Or�ament�ria Inicial
#Define POS_OPOFIM 11 // Opera��o Or�ament�ria Final
#Define POS_UNOINI 12 // Unidade Or�ament�ria Inicial
#Define POS_UNOFIM 13 // Unidade Or�ament�ria Final
#Define POS_CCINI  14 // Centro de Custo Inicial
#Define POS_CCFIM  15 // Centro de Custo Final
#Define POS_ITCINI 16 // Item Cont�bil Inicial
#Define POS_ITCFIM 17 // Item Cont�bil Final
#Define POS_CLCINI 18 // Classe de Valor Inicial
#Define POS_CLCFIM 19 // Classe de Valor Final
#Define POS_ARQUIV 20 // Arquivo
Static __nQtdePerg := 20  // Quantidade de par�metros (MV_PARxx).

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOM010
Rotina que realiza a exporta��o de movimentos or�ament�rios ou saldos do per�odo,
em formato txt, para integra��o com sistemas externos.

@author Alison Lemes
@since 15/05/2018
@version MP12.1.17
@param aAutoCab, Vetor com os valores informados no ExecAuto
@return lRet
/*/
//-------------------------------------------------------------------
Function PCOM010(aAutoCab)

Local lRet       := .T.
Local aSays      := {}
Local aSM0       := AdmAbreSM0()
Local aButtons   := {}
Local nOpca      := 0
Local cPerg      := ""
Local cDirTxt    := GetMV("MV_CTBDTXT",.F.,"")
Local nHandle    := 0
Local cPerg2     := "PCOM010E"
Local lCubo      := CTBisCube()
Local nI

Private l010Auto	:= (Valtype(aAutoCab) <> "U" .AND. !Empty(aAutoCab))
Private cCadastro   := STR0001 // 'Exporta��o Txt de Movimentos Or�ament�rios'
Private aEntidades	:= {} // Array de verifica��o das entidades cont�beis adicionais, com 5 posi��es.
Default aAutocab    := {} // Posi��o 01 - boleano indicando se a entidade cont�bil existe ou n�o. Posicao 02: texto do pergunte inicial em BRA.

IF Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	lRet := .F.
Else
	If !Empty(cDirTxt) .And. !l010Auto
		cPerg := "PCOM010A"
	Else
		cPerg := "PCOM010"
	EndIf
	PCO010CarE(@aEntidades)

	// Se o parametro de cubo estiver acionado e houver uma entidade adicional, cria um pergunte para entidades adicionais
	If aEntidades[1][1]
		If lCubo
			CriaSX1(cPerg2)
		Else
			lRet := .F.
		Endif
	Endif

	If lRet
		If !l010Auto
			AADD(aSays,STR0002)//'Esta rotina realiza a exporta��o de movimentos Or�ament�rios'
			AADD(aSays,STR0003)//'em formato TXT,
			AADD(aSays,STR0025)//para a integra��o com sistemas externos.'
			If aEntidades[1][1]
				AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg, .T.) .and. Pergunte(cPerg2, .T.) }} )
			Else
				AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg, .T.) }} )
			Endif
			AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CTBOk(), FechaBatch(), nOpca:=0 ) }} )
			AADD(aButtons, { 2,.T.,{|| ( FechaBatch(), lRet := .F. ) }} )

			FormBatch( cCadastro, aSays, aButtons )

			// Preenche o array de parametros, com base nas respostas do pergunte.
			__aPCOM010 := {}
			Pergunte(cPerg, .F.)
			PCOM010Arr(cPerg)
			If aEntidades[1][1]
				Pergunte(cPerg2, .F.)
				PCOM010Arr(cPerg2)
			Endif
		Else // Rotina autom�tica. Carrega o pergunte com o array enviado.
			PCO010CarP(aAutoCab)
			nOpca:=1
		Endif

		If lRet
			nHandle := FCREATE (__aPCOM010[POS_ARQUIV])

			If nHandle < 0
				Help(,,'PCO010NOFILE',,STR0029,1,0)//"N�o foi poss�vel criar o arquivo no diret�rio informado. Por favor verifique."
				lRet := .F.
			Else
				Fclose(nHandle)
				FERASE(__aPCOM010[POS_ARQUIV])
				lRet := .T.
			EndIf

			If lRet .And. nOpca == 1
				IF !IsBlind()
					MsgRun(STR0027,STR0026,{||lRet:=Pco010Mov()})//"Aguarde, processando movimentos Or�ament�rios" - 'Exporta��o TXT Mov'
				Else
					lRet:=Pco010Mov()
				Endif
			Endif
		Endif
	Else
		Help(,,'PCO010NOCUB',,STR0028,1,0)//"Para usar esta rotinas com as Entidades Or�ament�rios adicionais no sistema, � necess�rio configurar o parametro MV_CTBCUBE e recalcular os saldos."
	Endif

	If lRet .and. nOpca==1 .and. !IsBlind()
		If cPerg == "PCOM010"
			MsgInfo(STR0006+" " + __aPCOM010[POS_ARQUIV],cCadastro)//"Exporta��o realizada com sucesso! Arquivo gerado:"
		Else
			MsgInfo(STR0030,cCadastro)//"Exporta��o realizada com sucesso!"
		EndIf
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Pco010Mov
Funcao de processamento das busca a partir dos dados do pergunte (exporta��o de movimentos contabeis).

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Function Pco010Mov()

Local lRet   := .T.
Local aArea  := GetArea()
Local cQuery := ""
Local cErro  := ""
Local cAlias := ""
Local aErro  := {}
Local nX

// Tipo de arquivo
If Empty (__aPCOM010[POS_ARQUIV])
	Aadd(aErro, STR0019)//"Local de grava��o do arquivo TXT n�o informado."
	lRet := .F.
Else
	cQuery += "SELECT AKD.R_E_C_N_O_ " + CRLF
	cQuery += "FROM "+ RetSqlName("AKD") + " AKD " + CRLF
	cQuery += "WHERE AKD.D_E_L_E_T_ = ' ' " + CRLF

	// Filtro da filial
	If Empty(__aPCOM010[POS_FILFIM])
		If !Empty(__aPCOM010[POS_FILINI])
			Aadd(aErro, STR0008)//'Inconsist�ncia na Filial de/at�.'
			lRet := .F.
		Endif
	Else
		cQuery += "AND AKD.AKD_FILIAL BETWEEN '"
		cQuery += FWxFilial("AKD", __aPCOM010[POS_FILINI]) + "' AND '" + FWxFilial("AKD", __aPCOM010[POS_FILFIM]) + "' " + CRLF
	Endif

	// Filtro da data
	If Empty(__aPCOM010[POS_DATFIM])
		If !Empty(__aPCOM010[POS_DATINI])
			Aadd(aErro,STR0009)//'Inconsistencia na Data de/at�.'
			lRet := .F.
		Endif
	Else
		cQuery += "AND AKD.AKD_DATA BETWEEN '"
		cQuery += DToS(__aPCOM010[POS_DATINI]) + "' AND '" + DToS(__aPCOM010[POS_DATFIM]) + "' " + CRLF
	Endif

	// Filtro da conta or�ament�ria
	If Empty(__aPCOM010[POS_COFIM])
		If !Empty(__aPCOM010[POS_COINI])
			Aadd(aErro, STR0010)//'Inconsist�ncia na Conta Or�ament�ria de/at�.'
			lRet := .F.
		Endif
	Else
		cQuery += "AND AKD.AKD_CO BETWEEN '"
		cQuery += __aPCOM010[POS_COINI] + "' AND '" + __aPCOM010[POS_COFIM] + "' " + CRLF
	Endif

	// Filtro da classe or�ament�ria
	If Empty(__aPCOM010[POS_CLOFIM])
		If !Empty(__aPCOM010[POS_CLOINI])
			Aadd(aErro, STR0011)//"Inconsist�ncia na Classe Or�ament�ria de/at�."
			lRet := .F.
		Endif
	Else
		cQuery += "AND AKD.AKD_CLASSE BETWEEN '"
		cQuery += __aPCOM010[POS_CLOINI] + "' AND '" + __aPCOM010[POS_CLOFIM] + "' " + CRLF
	Endif

	// Filtro da opera��o or�ament�ria
	If Empty(__aPCOM010[POS_OPOFIM])
		If !Empty(__aPCOM010[POS_OPOINI])
			Aadd(aErro, STR0012)//"Inconsist�ncia na Opera��o Or�ament�ria de/at�."
			lRet := .F.
		Endif
	Else
		cQuery += "AND AKD.AKD_OPER BETWEEN '"
		cQuery += __aPCOM010[POS_OPOINI] + "' AND '" + __aPCOM010[POS_OPOFIM] + "' " + CRLF
	Endif

	// Filtro da unidade or�ament�ria
	If Empty(__aPCOM010[POS_UNOFIM])
		If !Empty(__aPCOM010[POS_UNOINI])
			Aadd(aErro, STR0013)//"Inconsist�ncia na Unidade Or�ament�ria de/at�."
			lRet := .F.
		Endif
	Else
		cQuery += "AND AKD.AKD_UNIORC BETWEEN '"
		cQuery += __aPCOM010[POS_UNOINI] + "' AND '" + __aPCOM010[POS_UNOFIM] + "' " + CRLF
	Endif

	// Filtro do centro de custo
	If Empty(__aPCOM010[POS_CCFIM])
		If !Empty(__aPCOM010[POS_CCINI])
			Aadd(aErro, STR0014)//"Inconsist�ncia no Centro de Custo de/at�."
			lRet := .F.
		Endif
	Else
		cQuery += "AND AKD.AKD_CC BETWEEN '"
		cQuery += __aPCOM010[POS_CCINI] + "' AND '"+__aPCOM010[POS_CCFIM] + "' " + CRLF
	Endif

	// Filtro do item cont�bil
	If Empty(__aPCOM010[POS_ITCFIM])
		If !Empty(__aPCOM010[POS_ITCINI])
			Aadd(aErro, STR0015)//"Inconsist�ncia no Item Or�ament�ria de/at�."
			lRet := .F.
		Endif
	Else
		cQuery += "AND AKD.AKD_ITCTB BETWEEN '"
		cQuery += __aPCOM010[POS_ITCINI] + "' AND '" +__aPCOM010[POS_ITCFIM] + "' " + CRLF
	Endif

	// Filtro da classe de valor
	If Empty(__aPCOM010[POS_CLCFIM])
		If !Empty(__aPCOM010[POS_CLCINI])
			Aadd(aErro, STR0016)//"Inconsist�ncia na Classe de Valor de/at�."
			lRet := .F.
		Endif
	Else
		cQuery += "AND AKD.AKD_CLVLR BETWEEN '"
		cQuery += __aPCOM010[POS_CLCINI] + "' AND '"+ __aPCOM010[POS_CLCFIM] + "' " + CRLF
	Endif

	// Filtro do tipo de saldo
	If Empty (__aPCOM010[POS_TIPSLD])
		Aadd(aErro, STR0017)//"Tipo de Saldo vazio."
		lRet := .F.
	Else
		cQuery += "AND AKD.AKD_TPSALD = '" + __aPCOM010[POS_TIPSLD] + "' " + CRLF
	Endif

	// Filtro de entidades cont�beis (de 5 a 9).
	For nX := 1 to Len(aEntidades)
		If aEntidades[nX][1]
			If Empty(aEntidades[nX][5])
				If !Empty(aEntidades[nX][4])
					Aadd(aErro, STR0018 + " " + StrZero(nX + 4, 2) + '.') // "Inconsist�ncia na Entidade cont�bil"
					lRet := .F.
					Exit
				Endif
			Else
				cQuery += "AND AKD.AKD_ENT" + StrZero(nX + 4, 2) + " BETWEEN '"
				cQuery += aEntidades[nX][4] + "' AND '" + aEntidades[nX][5] + "' " + CRLF
			Endif
		Else
			Exit
		Endif
	Next nX
Endif

If !lRet
	cErro := STR0020 + " "
	For nX := 1 to Len(aErro)
		cErro += CRLF + aErro[nX]
	Next
	cErro += CRLF + STR0021//'Verifique as ocorr�ncias e tente novamente.'
	Help(,,'PCO010IN',,cErro,1,0)
Else
	cAlias := MPSysOpenQuery(ChangeQuery(cQuery))
	lRet := Pco010Txt(cAlias, __aPCOM010[POS_ARQUIV], aEntidades)
	(cAlias)->(dbCloseArea())
Endif

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCO010Txt
Funcao de geracao do arquivo txt para exportacao

@param cAlias Alias que sera utilizado para a exportacao txt
@param cFileTxt - diretorio do arquivo Txt que sera gravado
@param aEntidades - Array com as entidades contabeis
@param cFilSaldo, Filial do saldo Or�ament�rio para exibir no arquivo de exporta��o com vis�o gerencial
@return lRet boleano Determina se a operacao foi realizada com sucesso

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Static Function PCO010Txt(cAlias, cFilePath, aEntidades, cFilSaldo)

Local lRet	     := .T.
Local aArea      := GetArea()
Local cLinha     := ""
Local nHandle    := -1
Local cSeparador := If(IsSrvUnix(), "/", "\")
Local lTemSaldo  := .F.
Local lPCO010TRS := ExistBlock("PCO010TRS")
Local aStruct    := {}
Local xValue
Local nX

Default cFilSaldo := ""

If Select(cAlias) > 0
	If Right(cFilePath, 1) == cSeparador
		cFilePath := left(cFilePath, len(cFilePath) - 1)
	EndIf
	nX := At(cSeparador, cFilePath) //caso venha diretorio arquivo, tento gravar o diretorio
	cFileTxt := cFilePath
	If nX > 0
		While nX > 0
			cFileTxt := SubStr(cFileTxt,nX+1)
			nX := AT(cSeparador,cFileTxt)
		Enddo
		cFilePath := SubStr(cFilePath, 1, (Len(cFilePath) - Len(cFileTxt)) -1)
		If !ExistDir(cFilePath)
			If MakeDir(cFilePath) == 0
				cFileTxt := cFilePath + cSeparador + cFileTxt
			Else
				Help(,,'PCO010ERRDIR',,STR0023 + STR(FERROR()),1,0)//"O Arquivo n�o foi criado:"
				lRet := .F.
			Endif
		Else
			cFileTxt:=cFilePath+cSeparador+cFileTxt
		EndIf
	Endif
	If lRet
		nHandle := FCreate(cFileTxt)
		If nHandle > 0
			If (cAlias)->(!EOF())
				aStruct := PCO010X3()
				While (cAlias)->(!EOF())
					AKD->(dbGoTo((cAlias)->R_E_C_N_O_))
					If lPCO010TRS
						ExecBlock("PCO010TRS", .F., .F., {(cAlias)->R_E_C_N_O_})
					EndIf

					// Retorna a estrutura do arquivo a ser gerado.
					cLinha := ""
					For nX := 1 to len(aStruct)
						xValue := Eval(aStruct[nX, 1])
						If aStruct[nX, 4] = "C"
							cLinha += PadR(xValue, aStruct[nX, 5])
						ElseIf aStruct[nX, 4] = "N"
							cLinha += Str(xValue, aStruct[nX, 5], aStruct[nX, 6])
						ElseIf aStruct[nX, 4] = "D"
							// Formato DD/MM/AAAA.
							cLinha += StrZero(Day(xValue), 2) + '/' + StrZero(Month(xValue), 2) + '/' + Str(Year(xValue), 4)
						Endif
					Next nX

					lTemSaldo := .T.
					FWrite(nHandle, cLinha + CRLF)
					(cAlias)->(DbSkip())
				EndDo
				Fclose(nHandle)
			Else
				Help(,,'PCO010TXT1',,STR0022,1,0)//"N�o foram encontrados registros com os par�metros informados."
				lRet := .F.
				Fclose(nHandle)
			Endif
		Else
			Help(,,'PCO010ERRTXT',,STR0023 + STR(FERROR()),1,0)//"O Arquivo n�o foi criado:"
			lRet := .F.
		Endif
	Endif
Else
	Help(,,'PCO010TXT2',,STR0024,1,0)//"Problemas na abertura da tabela de exporta��o Txt."
	lRet := .F.
Endif

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCO010CarE(aEntidades)
Verifica se as entidades Cont�beis existem no sistema

@param aEntidades Array contendo um campo para boleano se a entidade existe
@return Nil

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Static Function PCO010CarE(aEntidades)

Local aArea    := {}
Local aAreaAKD := {}

If len(aEntidades) <> 5
	aArea    := GetArea()
	aAreaAKD := AKD->(GetArea())

	aEntidades := {}
	aAdd(aEntidades, {AKD->(ColumnPos("AKD_ENT05")) > 0, 'Ent Cont 5 de:', 'Ent Cont 5 at�:', '', ''})
	aAdd(aEntidades, {AKD->(ColumnPos("AKD_ENT06")) > 0, 'Ent Cont 6 de:', 'Ent Cont 6 at�:', '', ''})
	aAdd(aEntidades, {AKD->(ColumnPos("AKD_ENT07")) > 0, 'Ent Cont 7 de:', 'Ent Cont 7 at�:', '', ''})
	aAdd(aEntidades, {AKD->(ColumnPos("AKD_ENT08")) > 0, 'Ent Cont 8 de:', 'Ent Cont 8 at�:', '', ''})
	aAdd(aEntidades, {AKD->(ColumnPos("AKD_ENT09")) > 0, 'Ent Cont 9 de:', 'Ent Cont 9 at�:', '', ''})

	RestArea(aAreaAKD)
	RestArea(aArea)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PCO010CarP(aAutoCab)
Carrega o pergunte com o array da rotina automatica.

@param aAutocab, Array contendo os valores para o pergunte da rotina
@return Nil

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Static Function PCO010CarP(aAutoCab)
Local nX   := 0
Local nPos := 0

// Monta os MV_PARxx.
For nX := 1 to __nQtdePerg
	nPos := aScan( aAutoCab, { |x| UPPER(AllTrim(x[1])) == "MV_PAR"+StrZero(nX,2) } )
	IF nPos > 0
		&( "MV_PAR"+StrZero(nX,2) ) := aAutoCab[nPos][2]
	Else
		If nX == POS_TIPSLD
			&( "MV_PAR"+StrZero(nX,2) ) := 'RE'
		Else
			&( "MV_PAR"+StrZero(nX,2) ) := ''
		Endif
	Endif
Next nX
PCOM010Arr("PCOM010")

// Monta a vari�vel aEntidades com as entidades gerenciais (de 5 a 9).
For nX := 1 to len (aEntidades)
	If aEntidades[nX][1]
		nPos := AScan(aAutoCab, { |x| UPPER(AllTrim(x[1])) == "ENTCONT" + StrZero(nX + 4, 2) + "DE" })
		If nPos > 0
			aEntidades[nX][4] := aAutoCab[nPos][2]
		Endif

		nPos := aScan(aAutoCab, { |x|  UPPER(AllTrim(x[1])) == "ENTCONT" + StrZero(nX + 4, 2) + "ATE" })
		If nPos > 0
			aEntidades[nX][5] := aAutoCab[nPos][2]
		Endif
	Endif
Next

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Fun��o para integra��o via Mensagem �nica Totvs.

@param  cXml          Vari�vel com conte�do XML para envio/recebimento.
@param  cTypeTrans    Tipo de transa��o (Envio / Recebimento).
@param  cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param  cVersion      Vers�o da mensagem.
@param  cTransac      Nome da transa��o.

@return  aRet   - (array)   Cont�m o resultado da execu��o e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execu��o da fun��o
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return PCOM010I(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PCOM010Arr
Fun��o que carrega a variavel de parametros com os perguntes da rotina

@author Alvaro Camillo Neto
@since 22/08/2013
@version MP11.80
/*/
//-------------------------------------------------------------------------------------
Static Function PCOM010Arr(cPerg)
	Local cArq		:= "CTBMOV" + "_" + DTOS(dDataBase) +"_"+ cValtochar(Seconds())
	Local cDirTxt	:= Alltrim(GetMV("MV_CTBDTXT",.F.,""))
	Local nOrdem    := 0
	Local nCont     := 0
	Local nX        := 0
	Local cSeparador := Iif( Upper(Alltrim(TCSrvType()))== "LINUX", "/" , "\")

	cArq := STRTRAN ( cArq , "." , "" ) + ".txt"

	If cPerg == "PCOM010" .OR. cPerg == "PCOM010A"
		__aPCOM010 := {}
		For nX := 1 To __nQtdePerg
			If !(Type("MV_PAR" + StrZero(nX, 02)) == "U")
				If (nX == POS_ARQUIV .AND. AllTrim(cPerg) == "PCOM010A")
					cDirTxt := IIf(Right(cDirTxt, 01) != cSeparador, cDirTxt + cSeparador, cDirTxt)
					aAdd(__aPCOM010, cDirTxt + cArq)
				ElseIf (nX > POS_ARQUIV .AND. AllTrim(cPerg) == "PCOM010A")
					aAdd(__aPCOM010, &("MV_PAR" + StrZero(nX - 01, 02)))
				Else
					aAdd(__aPCOM010, &("MV_PAR" + StrZero(nX, 02)))
				EndIf
			EndIf
		Next nX
	ElseIf cPerg == "PCOM010E"
		nOrdem := 1
		For nCont := 1 To Len(aEntidades)
			If aEntidades[nCont][1]
				aEntidades[nCont][4] := &("MV_PAR" + StrZero(nOrdem,2))
				nOrdem += 1
				aEntidades[nCont][5] := &("MV_PAR" + StrZero(nOrdem,2))
				nOrdem += 1
			Endif
		Next nCont
	Endif

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
Cria as perguntas da rotina

@author Alvaro Camillo Neto
@since 22/08/2013
@version MP11.80
@param cPerg, nome do pergunte a ser criado
@return nRet, Quantidade de perguntas criadas
/*/
//-------------------------------------------------------------------------------------
Static Function CriaSX1(cPerg)
Local nRet := 0
Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local aDados   := {}
Local nI       := 0
Local nJ       := 0
Local nX       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )
Local cPrefix := ""
Local nOrdem := 0

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"   }

If Alltrim(cPerg) == "PCOM010E"
	nOrdem := 1
	For nX :=1 To Len (aEntidades)
		If !aEntidades[nX][1]
			Exit
		Endif

		cPrefix:=StrZero(nX+4,2)

		aAdd( aDados, {cPerg,StrZero(nOrdem,2),'Ent Cont ' + cPrefix + ' de: ?','�De Ent Cont ' + cPrefix + ' ?','From Acc. Ent. ' + cPrefix + ': ?','MV_CH'+AllTrim(cValToChar(nOrdem + 15)),'C',9,0,0,'G','','MV_PAR'+AllTrim(cValToChar(nOrdem + 15)),'','','','','','','','','','','','','','','','','','','','','','','','','CV0','S','040','','',''} )
		aHlpPor := {"Entidade Cont�bil " + cPrefix, "inicial de exporta��o."}
		aHlpSpa := {"Entidad Contable " + cPrefix, "inicial de exportacion."}
		aHlpEng := {"Accounting Entity " + cPrefix, "Export Initial Accounting Entity"}
		PutHelp( "P."+cPerg+StrZero(nOrdem,2)+".", aHlpPor, aHlpEng, aHlpSpa, .T. )
		nOrdem += 1

		aAdd( aDados, {cPerg,StrZero(nOrdem,2),'Ent Cont ' + cPrefix + ' at�: ?','�A Ent Cont ' + cPrefix + ': ?','To Acc. Ent. ' + cPrefix + ': ?','MV_CH'+AllTrim(cValToChar(nOrdem + 15)),'C',9,0,0,'G','','MV_PAR'+AllTrim(cValToChar(nOrdem + 15)),'','','','','','','','','','','','','','','','','','','','','','','','','CV0','S','040','','',''} )
		aHlpPor := {"Entidade Cont�bil " + cPrefix, "final de exporta��o."}
		aHlpSpa := {"Entidad Contable " + cPrefix, "final de exportacion."}
		aHlpEng := {"Accounting Entity " + cPrefix, "Export Final Accounting Entity"}
		PutHelp( "P."+cPerg+StrZero(nOrdem,2)+".", aHlpPor, aHlpEng, aHlpSpa, .T. )
		nOrdem += 1
	Next
Endif

//
// Atualizando dicion�rio
//
dbSelectArea("SX1")
SX1->(dbSetOrder(1))

For nI := 1 To Len( aDados )
	If !SX1->( msSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

nRet := Len( aDados )

SX1->(RestArea( aAreaDic ))
RestArea( aArea )

Return nRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PCOM010X1E
Defini��o do Grupo de Perguntas PCOM010E

@author Alison Kaique Lemes Leite
@since 19/06/2018
@version MP12.1.17
@param cPerg, Grupo de Perguntas a ser criado
@return nRet, Quantidade de perguntas criadas
/*/
//-------------------------------------------------------------------------------------
Function PCOM010X1E(cPerg)

Local nRet     := 0 //Quantidade de perguntas criadas
Local aRelease := {} //Release do RPO
Local cFuncao  := 'EngSX1' //Rotina a ser executada para cria��o das Perguntas
Local aHelpPor := {} //Help em Portugu�s
Local aHelpEng := {} //Help em Ingl�s
Local aHelpSpa := {} //Help em Espanhol
Local cPrefixo := '' //Prefixo da Entidade
Local nOrdem   := 0  //Ordem da Pergunta
Local cOrdCH   := '0' //Ordem do MV_CH
Local nI       := 0  //Controle do For

Default cPerg  := 'PCOM010E' //Grupo de Perguntas a ser criado

If ( GetRPORelease() == "12.1.017" )

	aRelease := StrTokArr(GetRpoRelease(), '.')

	//Verifica se o array aEntidades existe
	If (Type("aEntidades") == 'U')
		//Caso n�o exista, o carrega
		aEntidades := {}
		PCO010CarE(@aEntidades)
	EndIf

	//Compondo fun��o que ser� executada
	If (Len(aRelease) == 03)
		//Exemplo: EngSX1117 (Release 12.1.17)
		cFuncao += aRelease[02] + cValToChar(Val(aRelease[03]))
		//Verifica se a fun��o est� compilada no RPO
		If (FindFunction(cFuncao))
			//Percorrendo as Entidades
			For nI := 1 To Len(aEntidades)
				//Verifica se a Entidade ser� criada
				If !(aEntidades[nI, 01])
					Exit
				Endif
				/**Efetuar a cria��o**/
				//Prefixo da Entidade
				cPrefixo := StrZero(nI + 4, 02)
				//Help's
				aHlpPor := {"Entidade Cont�bil " + cPrefixo, "inicial de exporta��o."}
				aHlpSpa := {"Entidad Contable "  + cPrefixo, "inicial de exportacion."}
				aHlpEng := {"Accounting Entity " + cPrefixo, "Export Initial Accounting Entity"}
				//Pergunta "De"
				nOrdem ++
				cOrdCH := Soma1(cOrdCH)
				PutHelp( "P." + cPerg + StrZero(nOrdem, 02)+".", aHlpPor, aHlpEng, aHlpSpa, .T. )
				&(cFuncao)(cPerg, StrZero(nOrdem, 02),;
					"Ent Cont " + cPrefixo + " de: ?",;
					"�De Ent Cont " + cPrefixo + " ?",;
					"From Acc. Ent. " + cPrefixo + ": ?",;
					"MV_CH" + cOrdCH, "C", 9, 0, ,"G", "","CV0","","","MV_PAR" + StrZero(nOrdem, 02),;
					"", "",  "", "","", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpEng, aHelpSpa, "P." + cPerg + StrZero(nOrdem, 02)+".")
				//Help's
				aHlpPor := {"Entidade Cont�bil " + cPrefixo, "final de exporta��o."}
				aHlpSpa := {"Entidad Contable "  + cPrefixo, "final de exportacion."}
				aHlpEng := {"Accounting Entity " + cPrefixo, "Export Final Accounting Entity"}
				//Pergunta "At�"
				nOrdem ++
				cOrdCH := Soma1(cOrdCH)
				PutHelp( "P." + cPerg + StrZero(nOrdem, 02)+".", aHlpPor, aHlpEng, aHlpSpa, .T. )
				&(cFuncao)(cPerg, StrZero(nOrdem, 02) ,;
					"Ent Cont " + cPrefixo + " at�: ?",;
					"�A Ent Cont " + cPrefixo + ": ?" ,;
					"To Acc. Ent. " + cPrefixo + ": ?" ,;
					"MV_CH" + cOrdCH, "C", 9, 0, ,"G", "","CV0","","","MV_PAR" + StrZero(nOrdem, 02),;
					"", "",  "", "","", "", "", "", "", "", "", "", "", "", "", "", aHelpPor, aHelpEng, aHelpSpa, "P." + cPerg + StrZero(nOrdem, 02)+".")
			Next nI
		Else
			Help(,,'PCO010NOFUNC',,STR0031,1,0)//"Fun��o de cria��o do Grupo de Perguntas n�o encontrada no Reposit�rio. Por favor verifique."
		EndIf
	Else
		Help(,,'PCO010RELEASE',,STR0032,1,0)//"N�o foi poss�vel retornar a Release do Reposit�rio. Por favor verifique."
	EndIf

EndIf

Return()

/*/{Protheus.doc} PCO010X3
Retorna a estrutura dos campos gerados por essa fun��o.

@author 	Felipe Raposo
@version	P12.1.23
@since 		02/07/2019
/*/
Function PCO010X3

Local aArea      := {}
Local aSX3Area   := {}
Local aFields    := {}
Local aEntidades := {}
Local cField     := ""
Local nX

Static aSX3Struct := {}
If empty(aSX3Struct)
	aArea    := GetArea()
	aSX3Area := SX3->(GetArea())

	// Popula a vari�vel aEntidades, se necess�rio.
	PCO010CarE(aEntidades)

	// Campos que far�o parte do arquivo.
	aAdd(aFields, "AKD_FILIAL")
	aAdd(aFields, "AKD_STATUS")
	aAdd(aFields, "AKD_LOTE")
	aAdd(aFields, "AKD_ID")
	aAdd(aFields, "AKD_DATA")
	aAdd(aFields, "AKD_CO")
	aAdd(aFields, "AKD_CLASSE")
	aAdd(aFields, "AKD_OPER")
	aAdd(aFields, "AKD_UNIORC")
	aAdd(aFields, "AKD_TPSALD")
	aAdd(aFields, "AKD_TIPO")
	aAdd(aFields, "AKD_HIST")
	aAdd(aFields, "AKD_IDREF")
	aAdd(aFields, "AKD_PROCES")
	aAdd(aFields, "AKD_CHAVE")
	aAdd(aFields, "AKD_ITEM")
	aAdd(aFields, "AKD_SEQ")
	aAdd(aFields, "AKD_VALOR1")
	aAdd(aFields, "AKD_CODPLA")
	aAdd(aFields, "AKD_VERSAO")
	aAdd(aFields, "AKD_CC")
	aAdd(aFields, "AKD_ITCTB")
	aAdd(aFields, "AKD_CLVLR")
	aAdd(aFields, "AKD_LCTBLQ")
	aAdd(aFields, "AKD_FILORI")
	For nX := 1 to Len(aEntidades) // Entidades cont�beis
		If aEntidades[nX, 1]
			aAdd(aFields, "AKD_ENT" + StrZero(nX + 4, 2))
		Endif
	Next nX

	// Monta a vari�vel aSX3Struct com a estrutura.
	// Estrutura da vari�vel -> {bCampo, cCampo, cDescri��o, cTipo, nTamanho, nDecimal}
	aAdd(aSX3Struct, {{|| cEmpAnt}, "Company", "Company", "C", len(cEmpAnt), 0})
	For nX := 1 to Len(aFields)
		cField  := aFields[nX]
		aTamSX3 := TamSX3(cField)
		If aTamSX3[3] = "D"
			aTamSX3[1] := 10  // A rotina retorna data no formato DD/MM/AAAA (10 caracteres).
		Endif
		aAdd(aSX3Struct, {&("{|| AKD->" + cField + "}"), cField, FWX3Titulo(cField), aTamSX3[3], aTamSX3[1], aTamSX3[2]})
	Next nX

	RestArea(aSX3Area)
	RestArea(aArea)
Endif

Return aClone(aSX3Struct)
