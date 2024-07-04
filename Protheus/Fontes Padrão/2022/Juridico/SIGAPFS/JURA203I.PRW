#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA203I.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA203I
Rotina para calcular o numero da fatura na geracao
e geral

@param cTpNum,    Tipo de fatura:
                   - FT - Fatura
                   - MF - Minuta de Fatura
                   - MP - Minuta de Pre-Fatura
                   - MS - Minuta de Sócio
@param cCodEscr,  Código do Escritorio
@param cCodMoeda, Código da Moeda da Fatura
@param lHonor,    Possui honorarios?
@param lDesp,     Possui despesas?
@param cMsgProc,  Mensagem para barra de progresso
@param dDtEmiss,  Data de emissão da Fatura

@return aNumFat,  aNumFat[1]: .T. ou .F. para o numero da fatura;
                  aNumFat[2]: Função JURA203I ou chave do tipo de numeração em caso de falha

@author Luciano Pereira dos Santos
@since 14/09/15
/*/
//-------------------------------------------------------------------
Function JURA203I( cTpNum, cCodEscr, cCodMoeda, lHonor, lDesp, cMsgProc, dDtEmiss)
Local lMV_JDFTINT := GetMv( "MV_JDFTINT", Nil, .F.                    ) // Diferenciar Numeração de Faturas Internacionais? - Padrão .F.
Local lMV_JDFTHON := GetMv( "MV_JDFTHON", Nil, .F.                    ) // Diferenciar Numeração de Faturas de Honorários? - Padrão .F.
Local lMV_JDFTDES := GetMv( "MV_JDFTDES", Nil, .F.                    ) // Diferenciar Numeração de Faturas de Despesas? - Padrão .F.
Local cMV_JMOENAC := GetMv( "MV_JMOENAC", Nil, "01"                   ) // Moeda Nacional
Local cMV_JNFTINT := GetMv( "MV_JNFTINT", Nil, CriaVar("NXA_COD",.F.) ) // Numeração Diferenciada para Faturas Internacionais
Local cMV_JNFTHON := GetMv( "MV_JNFTHON", Nil, CriaVar("NXA_COD",.F.) ) // Numeração Diferenciada para Faturas de Honorários
Local cMV_JNTDES  := GetMv( "MV_JNTDES" , Nil, CriaVar("NXA_COD",.F.) ) // Numeração Diferenciada para Faturas de Despesas

Local lFatIntl   := (cCodMoeda <> cMV_JMOENAC)
Local nTamCod    := TamSX3("NXA_COD")[1]
Local cNumFat    := ''
Local cFilFat    := xFilial("NXA")

Local lRegraInt  := .F. //Usa Regra de Fat Internacional
Local lRegraHon  := .F. //Usa Regra de Fat Honorarios
Local lRegraDsp  := .F. //Usa Regra de Fat Despesas

Local lGetNext   := .T.
Local cFlagSXE   := ""
Local aNumFat    := {.T., "JURA203I"}

Local lCode      := .F.

Local cMaxRange  := Replicate("9", nTamCod) // Número máximo do range da emissão de fatura.
Local lLog       := File('numfat.pfs') //Ativa o log atraves da criação do arquivo numfat.pfs na pasta system

//Privates utilizadas na rotina J203CriaSXE para inicializacao do controle de numeracao
Private cCodMin  := ""
Private cCodMax  := ""
Private aRegra   := {}

ProcRegua( 0 )
IncProc()
IncProc()
IncProc()
IncProc()
IncProc()

While !(lCode := MayIUseCode("JURA203I"))
	Sleep(1000)
EndDo

cCodMin := ""
cCodMax := ""

If cTpNum == "FT"

	cMV_JNFTINT := IIf(Empty(cMV_JNFTINT), cMV_JNFTINT, StrZero(Val(cMV_JNFTINT), nTamCod))
	cMV_JNFTHON := IIf(Empty(cMV_JNFTHON), cMV_JNFTHON, StrZero(Val(cMV_JNFTHON), nTamCod))
	cMV_JNTDES  := IIf(Empty(cMV_JNTDES) , cMV_JNTDES , StrZero(Val(cMV_JNTDES) , nTamCod))

	lRegraInt := (lMV_JDFTINT .And. !Empty(cMV_JNFTINT))
	lRegraHon := (lMV_JDFTHON .And. !Empty(cMV_JNFTHON))
	lRegraDsp := (lMV_JDFTDES .And. !Empty(cMV_JNTDES ))

	If !lRegraInt .And. !lRegraHon .And. !lRegraDsp // Não existe numeração diferenciada

		aRegra    := {.F., .F., .F., .F., cMV_JMOENAC}

		cFlagSXE  := "JURNFT"
		cCodMin   := StrZero(1, nTamCod)
		cCodMax   := Replicate("9", nTamCod)

	ElseIf lRegraInt .And. !lRegraHon .And. !lRegraDsp // Numeração de faturas internacionais diferente

		aRegra := {.F., .F., lRegraInt, lFatIntl, cMV_JMOENAC}

		If lFatIntl // Internacional
			cFlagSXE  := "JURNFTINT"
			cCodMin   := cMV_JNFTINT
			cCodMax   := Replicate("9", nTamCod)
		Else // Nacional
			cFlagSXE  := "JURNFT"
			cCodMin   := StrZero(1, nTamCod)
			cCodMax   := StrZero(Val(cMV_JNFTINT) - 1, nTamCod) 
		EndIf

	ElseIf !lRegraInt .And. !lRegraHon .And. lRegraDsp // Diferença na numeração de faturas de despesas

		aRegra := {lHonor, lDesp, .F., .F., cMV_JMOENAC}

		If lHonor // Honorários ou Honorários + Despesas
			cFlagSXE  := "JURNFTHONDES"
			cCodMin   := StrZero(1, nTamCod)
			cCodMax   := StrZero(Val(cMV_JNTDES) - 1, nTamCod) 
		Else // Despesas
			cFlagSXE  := "JURNFTDES"
			cCodMin   := cMV_JNTDES
			cCodMax   := Replicate("9", nTamCod)
		EndIf

	ElseIf !lRegraInt .And. lRegraHon .And. !lRegraDsp // Diferença na numeração de faturas de honorários ou honorários e despesas juntos

		aRegra := {lHonor, lDesp, .F., .F., cMV_JMOENAC}

		If lHonor // Honorários ou Honorários + Despesas
			cFlagSXE  := "JURNFTHONDES"
			cCodMin   := cMV_JNFTHON
			cCodMax   := Replicate("9", nTamCod)
		Else // Despesas
			cFlagSXE  := "JURNFTDES"
			cCodMin   := StrZero(1, nTamCod)
			cCodMax   := StrZero(Val(cMV_JNFTHON) - 1, nTamCod) 
		EndIf

	ElseIf !lRegraInt .And. lRegraHon .And. lRegraDsp // Diferença na numeração de faturas de (honorários ou honorários e despesas juntos) e somente de despesas

		aRegra := {lHonor, lDesp, .F., .F., cMV_JMOENAC}

		If lHonor // Honorários ou Honorários + Despesas
			cFlagSXE  := "JURNFTHONDES"
			cCodMin   := cMV_JNFTHON
			cCodMax   := IIf(cMV_JNTDES > cMV_JNFTHON, StrZero(Val(cMV_JNTDES) - 1, nTamCod), Replicate("9", nTamCod))
		Else // Despesas
			cFlagSXE  := "JURNFTDES"
			cCodMin   := cMV_JNTDES
			cCodMax   := IIf(cMV_JNTDES < cMV_JNFTHON, StrZero(Val(cMV_JNFTHON) - 1, nTamCod), Replicate("9", nTamCod))
		EndIf

	ElseIf  lRegraInt .And. !lRegraHon .And. lRegraDsp // Diferença na numeração de faturas internacionais e de despesas

		aRegra := {lHonor, lDesp, lRegraInt, lFatIntl, cMV_JMOENAC}

		If (!lFatIntl .And. lHonor) // Nacional de Honorários ou Honorários + Despesas (1º)
			cFlagSXE  := "JURNFTHONDES"
			cCodMin   := StrZero(1, nTamCod)
			cCodMax   := StrZero(Val(IIf(cMV_JNTDES < cMV_JNFTINT, cMV_JNTDES, cMV_JNFTINT)) - 1, nTamCod) // Max do menor dos parametros
		EndIf

		If (!lFatIntl .And. !lHonor) // Nacional de Despesas (2º)
			cFlagSXE  := "JURNFTDES"
			cCodMin   := cMV_JNTDES
			cCodMax   := StrZero(Val(IIf(cMV_JNTDES < cMV_JNFTINT, cMV_JNFTINT, StrZero(Val(cMV_JNFTINT) + Val(cMV_JNTDES), nTamCod))) - 1, nTamCod) 
		EndIf

		If (lFatIntl .And. lHonor)
			cFlagSXE  := "JURNFTINTHON" // Internacional de Honorários ou Honorários + Despesas (3º)
			cCodMin   := cMV_JNFTINT
			cCodMax   := StrZero(Val(IIf(cMV_JNTDES < cMV_JNFTINT, StrZero(Val(cMV_JNFTINT) + Val(cMV_JNTDES), nTamCod), cMV_JNTDES)) - 1, nTamCod) 
		EndIf

		If (lFatIntl .And. !lHonor) // Internacional de Despesas (4º)
			cFlagSXE  := "JURNFTINTDES"
			cCodMin   := StrZero(Val(cMV_JNFTINT) + Val(cMV_JNTDES), nTamCod)
			cCodMax   := Replicate("9", nTamCod)
		EndIf

	ElseIf lRegraInt .And. lRegraHon .And. !lRegraDsp // Diferença na numeração de faturas internacionais e de honorários ou honorários e despesas juntos

		aRegra := {lHonor, lDesp, lRegraInt, lFatIntl, cMV_JMOENAC}

		If (!lFatIntl .And. !lHonor) // Nacional de Despesas (1º)
			cFlagSXE  := "JURNFTDES"
			cCodMin   := StrZero(1, nTamCod)
			cCodMax   := StrZero(Val(IIf(cMV_JNFTHON < cMV_JNFTINT, cMV_JNFTHON, cMV_JNFTINT)) - 1, nTamCod) // Max do menor dos parametros
		EndIf

		If (!lFatIntl .And. lHonor) // Nacional de Honorários ou Honorários + Despesas (2º)
			cFlagSXE  := "JURNFTHONDES"
			cCodMin   := cMV_JNFTHON
			cCodMax   := StrZero(Val(IIf(cMV_JNFTHON < cMV_JNFTINT, cMV_JNFTINT, StrZero(Val(cMV_JNFTINT) + Val(cMV_JNFTHON), nTamCod))) - 1, nTamCod)
		EndIf

		If (lFatIntl .And. !lHonor)
			cFlagSXE  := "JURNFTINTDES" // Internacional de Despesas (3º)
			cCodMin   := cMV_JNFTINT
			cCodMax   := StrZero(Val(IIf(cMV_JNFTHON < cMV_JNFTINT, StrZero(Val(cMV_JNFTINT) + Val(cMV_JNFTHON), nTamCod), cMV_JNFTHON)) - 1, nTamCod)
		EndIf

		If (lFatIntl .and. lHonor) // Internacional de Honorários ou Honorários + Despesas (4º)
		
			cFlagSXE  := "JURNFTINTHON"
			cCodMin   := StrZero(Val(cMV_JNFTINT) + Val(cMV_JNFTHON), nTamCod)
			cCodMax   := Replicate("9", nTamCod)
		EndIf

	ElseIf lRegraInt .And. lRegraHon .And. lRegraDsp // Erro na configuração dos parametros de numeração de fatura.

		aNumFat  := {.F., STR0001} // "Erro na configuração dos parametros de numeração de fatura. Somente dois parametros de numeração pode ser habilitados ao mesmo tempo."
		Return aNumFat

	EndIf

	If lLog
		J203ILog('', cTpNum, cCodEscr, cCodMoeda, lHonor, lDesp, lFatIntl, cCodMin, cCodMax, cFlagSXE, dDtEmiss)
	EndIf

	While lGetNext

		cNumFat := GetSXENum("NXA", "NXA_COD", cFilFat + cCodEscr + cFlagSXE)

		If (cNumFat > cMaxRange) // Se o número da fatura é maior que o range máximo numérico, então contém letras (pode ser uma minuta ou extrapolou a numeração)
			aNumFat := {.F., I18N(STR0002, {cCodMax, cCodEscr + cFlagSXE})} // "Erro no controle de numeração da fatura. Verifique o controle de numeração para chave '#2'."
			Exit
		EndIf

		lGetNext := J203TemNXA(cCodEscr, cNumFat, cTpNum, dDtEmiss, aRegra, cCodMin, cCodMax)

		If lGetNext
			If cNumFat > cCodMax // Validação para o limite do intervalo da numeração de fatura
				aNumFat := {.F., I18N(STR0003, {cCodMax, cCodEscr + cFlagSXE})} // "A numeração máxima de #1 foi atingida. Verifique os parametros e o controle de numeração para chave '#2'."
				Exit
			Else
				ConfirmSX8() //Confirma para não deixar no controle de numeração, números pendentes
			EndIf
		EndIf

	EndDo

	If aNumFat[1]
		aNumFat := {.T., cNumFat}
	EndIf

ElseIf (cTpNum $ "MF|MP|MS") // Numeracao de Minuta de (Pre) Fatura

	// "JURNMF" - "JURNMP" - "JURNMS"

	aRegra   := {.F., .F., .F., .F., cMV_JMOENAC}
	cCodMin  := cTpNum + StrZero(1, nTamCod-Len(cTpNum) )
	cCodMax  := cTpNum + Replicate("9",nTamCod-Len(cTpNum))
	cFlagSXE := "JURN" + cTpNum

	If lLog
		J203ILog('', cTpNum, cCodEscr, cCodMoeda, lHonor, lDesp, lFatIntl, cCodMin, cCodMax, cFlagSXE, dDtEmiss)
	EndIf

	While lGetNext

		cNumFat := GetSXENum("NXA", "NXA_COD", cFilFat + cCodEscr + cFlagSXE)

		// Adiciona o prefixo de minuta
		If !(substr(cNumFat,1,2) $ cTpNum)
			cNumFat := cTpNum + StrZero(val(cNumFat), nTamCod-Len(cTpNum) )
		EndIf

		lGetNext := J203TemNXA(cCodEscr, cNumFat, cTpNum, dDtEmiss, aRegra, cCodMin, cCodMax)

		If lGetNext
			ConfirmSX8()
		EndIf
	EndDo

	aNumFat := {.T., cNumFat}

EndIf

If lLog
	J203ILog(cNumFat)
EndIf

Leave1Code("JURA203I")

Return aNumFat

//-------------------------------------------------------------------
/*/{Protheus.doc} J203TemNXA()
Função para verificar se o número de fatura já esta sendo utilizado no banco,
e se respeita as regras de exceção de numeração.

@param     cCodEscr,   Código do escritório da Fatura
@param     cNumFat,    Código de fatura a ser testado
@param     cTpNum,     Tipo de fatura: Ex: FT -fatura; MF -Minuta de fatura; etc...
@param     dDtEmiss,   Data e emissão da fatura
@param     aRegra,     Array com as regras de numeração de fatura
           - aRegra[1] - .T. se tem honorários ou honorarios mais despesas
           - aRegra[2] - .T. se tem somente despesas
           - aRegra[3] - .T. se é fatura internacional
           - aRegra[4] - Moeda Nacional (paramentro MV_JMOENAC)
@param     cCodMin,    Numeração minima da fatura
@param     cCodMax,    Numeração maxima da fatura

@return    lRet,   .T. O número de fatura não contemplou alguma das regras de numeração;
                   .F. O numero pode ser utilizado

@author Luciano Pereira dos Santos
@since  11/09/2015
/*/
//-------------------------------------------------------------------
Function J203TemNXA(cCodEscr, cNumFat, cTpNum, dDtEmiss, aRegra, cCodMin, cCodMax)
Local lRet      := .F.
Local cPrefixo  := PadR(SuperGetMV('MV_JPREFAT',,'PFS'), TamSX3('E1_PREFIXO')[1] )
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local cFilSE1   := ""
Local cMoeNac   := ""
Local lFathon   := .F.
Local lFatDes   := .F.
Local lDifInt   := .F.
Local lFatInt   := .F.

Default aRegra  := {}

// Verifica o intervalo de numeração
lRet := (cNumFat < cCodMin .Or. cNumFat >= cCodMax)

If lRet // O número de fatura sendo menor que o do parametro, a rotina pai testa se maior
	IncProc(STR0010 + cNumFat + " / " + cCodMin ) // "Validando numeração inicial da fatura: "
EndIf

If !lRet // Verifica se existe fatura emitida com a nuemração
	NXA->(dbSetOrder(1))
	lRet := NXA->(dbSeek(xFilial('NXA') + cCodEscr + cNumFat))

	If lRet
		IncProc(I18N(STR0004, {Iif(cTpNum == "FT", STR0008, STR0009), cCodEscr + cNumFat})) // "Localizando um número de #1 válido: '#2'" ##fatura ###minuta
	EndIf
EndIf

If cTpNum == "FT"
	If !lRet // Verifica se exite titulo gerados para esse numero de fatura
		cFilSE1 := JurGetDados('NS7', 1, xFilial('NS7') + cCodEscr, 'NS7_CFILIA')
		SE1->(dbSetOrder(1))
		lRet := SE1->(dbSeek(cFilSE1 + cPrefixo + cNumFat))

		If lRet
			IncProc(STR0006 + "'" + cFilSE1 + cPrefixo + cNumFat + "'") // "Localizando um número de título válido: "
		EndIf
	EndIf
EndIf

If !lRet
	cQuery :=      " SELECT A.EXISTE "
	cQuery +=        " FROM ( "
	cQuery +=               " SELECT NXA.NXA_COD EXISTE"
	cQuery +=                 " FROM " + RetSqlName("NXA") + " NXA"
	cQuery +=                " WHERE NXA.NXA_FILIAL = '" + xFilial('NXA') + "'"
	cQuery +=                  " AND NXA.NXA_CESCR = '" + cCodEscr + "'"
	cQuery +=                  " AND NXA.NXA_TIPO = '" + PadR(cTpNum , TamSX3("NXA_TIPO")[1]) + "'"
	cQuery +=                  " AND NXA.NXA_DTEMI < '" + DtoS(dDtEmiss) + "'"
	cQuery +=                  " AND NXA.NXA_COD = '" + cNumFat + "'"
	cQuery +=                  " AND NXA.D_E_L_E_T_ = ' '"

	If cTpNum == "FT"
		// Regra de numeração
		If !Empty(aRegra)
			lFathon := aRegra[1]
			lFatDes := aRegra[2]
			lDifInt := aRegra[3]
			lFatInt := aRegra[4]
			cMoeNac := aRegra[5]
		EndIf

		// Regra de diferenciação de numeração de honorarios e despesas
		If lFathon
			cQuery +=          " AND NXA.NXA_VLFATH > 0" // Honorários ou Honorários + Despesas
		ElseIf lFatDes
			cQuery +=          " AND NXA.NXA_VLFATD > 0 AND NXA.NXA_VLFATH = 0" // Só Despesas
		EndIf

		// Regra da diferenciação de Internacional / Nacional
		If lDifInt
			cQuery +=          " AND NXA.NXA_CMOEDA " + Iif(lFatInt,'<>', '=') + " '" + cMoeNac + "'" // Internacional / Nacional
		EndIf

		// Desconsidera as faturas da exceção de numeração
		cQuery +=              " AND NOT EXISTS (SELECT 1 "
		cQuery +=                                " FROM " + RetSqlName("NSE") + " NSE "
		cQuery +=                               " WHERE NSE.NSE_FILIAL = '" + xFilial("NSE") + "'"
		cQuery +=                                 " AND NSE.NSE_CESC = NXA.NXA_CESCR "
		cQuery +=                                 " AND NXA.NXA_COD BETWEEN NSE.NSE_NUMINI AND NSE.NSE_NUMFIN "
		cQuery +=                                 " AND NSE.D_E_L_E_T_ = ' ' "
		cQuery +=                             " ) "
		cQuery +=            " UNION ALL "
		cQuery +=           " SELECT NSE_NUMFIN EXISTE "
		cQuery +=             " FROM " + RetSqlName("NSE") + " NSE "
		cQuery +=            " WHERE NSE.NSE_FILIAL = '" + xFilial("NSE") + "'"
		cQuery +=              " AND NSE.NSE_CESC = '" + cCodEscr + "' "
		cQuery +=              " AND '" + cNumFat + "' BETWEEN NSE.NSE_NUMINI AND NSE.NSE_NUMFIN "
		cQuery +=              " AND NSE.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery +=             " ) A "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	lRet := !(cAliasQry)->(Eof())

	(cAliasQry)->(DbCloseArea())

	If lRet
		IncProc(I18N(STR0007, {Iif(cTpNum == "FT", STR0008, STR0009), cCodEscr + cNumFat})) //#"Localizando número de #1 diponível: '#2'"  ##fatura ###minuta
	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203CriaSXE
Funcao para calculo da numeracao das faturas quando o SXE estiver
zerado

@Param  PARAMIXB      Array com as informações da rotina CriaSXE, fonte MATXATU.PRX
         PARAMIXB[1]  Alias da tabela
         PARAMIXB[2]  Campo da tabela para numeração
         PARAMIXB[3]  Chave do controle de numeração

@Return cNextNum Proximo Numero de Fatura

@author Daniel Magalhaes
@since 01/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203CriaSXE(ParamIXB)
Local cAlias   := ""
Local cCampo   := ""
Local cChave   := ""

Local cNextNum := Nil

Local cIniNum  := ""
Local cFimNum  := ""

Local cQuery   := ""
Local cFilNXA  := ""
Local cEscrit  := ""

Local lFathon  := .F.
Local lFatDes  := .F.
Local lDifInt  := .F.
Local lFatInt  := .F.

Local cMoeNac  := ""
Local cAliasQr := GetNextAlias()

Default ParamIXB := {}

If Len(ParamIXB) == 0
	Return nil
EndIf

cAlias := ParamIXB[1]
cCampo := ParamIXB[2]
cChave := ParamIXB[3]

SetPrvt("cCodMin")
SetPrvt("cCodMax")
SetPrvt("aRegra" )

If cAlias == "NXA" .And. cCampo == "NXA_COD"

	cFilNXA := xFilial('NXA')
	cEscrit := SubStr(cChave,Len(cFilNXA)+1,TamSX3("NXA_CESCR")[1])

	If "JURNFT" $ cChave //Faturas

		//Variaveis Private da JURA203I
		If ValType(cCodMin) == "C"
			cIniNum := cCodMin
		EndIf

		If ValType(cCodMax) == "C"
			cFimNum := cCodMax
		EndIf
		
		If ValType(aRegra)  == "A"
			lFathon := aRegra[1]
			lFatDes := aRegra[2]
			lDifInt := aRegra[3]
			lFatInt := aRegra[4]
			cMoeNac := aRegra[5]
		EndIf
		
		cQuery := " SELECT MAX(NXA_COD) MAX_COD"
		cQuery +=   " FROM " + RetSqlName("NXA") + " NXA"
		cQuery +=  " WHERE NXA.NXA_FILIAL = '" + cFilNXA + "'"
		cQuery +=    " AND NXA.NXA_CESCR = '" + cEscrit + "'"
		cQuery +=    " AND NXA_TIPO = '" + PadR( "FT", TamSX3("NXA_TIPO")[1] ) + "' "
		//Intervalo de faturamento
		If !Empty(cIniNum) .And. !Empty(cFimNum)
			cQuery +=   " AND NXA.NXA_COD between '" + cIniNum + "' AND '" + cFimNum + "'"
		EndIf

		//Testa se o máximo não esta dentro da exceção de numeração de fatura
		cQuery +=    " AND NOT EXISTS (SELECT 1 "
		cQuery +=                      " FROM " + RetSqlName("NSE") + " NSE "
		cQuery +=                     " WHERE NSE.NSE_FILIAL = '" + xFilial("NSE") + "'"
		cQuery +=                       " AND NSE.NSE_CESC = NXA.NXA_CESCR "
		cQuery +=                       " AND NXA.NXA_COD BETWEEN NSE.NSE_NUMINI AND NSE.NSE_NUMFIN "
		cQuery +=                       " AND NSE.D_E_L_E_T_ = ' ' "
		cQuery +=                   " ) "

		//Regra de diferenciação de numeração de honorarios e despesas
		If lFathon
			cQuery +=   " AND NXA.NXA_VLFATH > 0" //Hon ou Hon+Desp
		ElseIf lFatDes
			cQuery +=   " AND NXA.NXA_VLFATD > 0 AND NXA.NXA_VLFATH = 0" // só Desp
		EndIf

		// Regra da diferenciação de Internacional / Nacional
		If lDifInt
			cQuery +=   " AND NXA.NXA_CMOEDA " + Iif(lFatInt,'<>', '=') + " '" + cMoeNac + "'"
		EndIf
		cQuery +=       " AND NXA.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )

		DbUseArea(.T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQr, .T., .T.)

		If !Empty((cAliasQr)->MAX_COD)
			cNextNum := Soma1((cAliasQr)->MAX_COD)
		ElseIf !Empty(cIniNum)
			cNextNum := cIniNum
		EndIf

		(cAliasQr)->(DbCloseArea())

	ElseIf "JURNMF" $ cChave //Minuta Fatura

		cQuery := " SELECT MAX(NXA_COD) MAX_COD"
		cQuery +=   " FROM " + RetSqlName("NXA") + " NXA "
		cQuery +=  " WHERE NXA.NXA_FILIAL = '" + cFilNXA + "'"
		cQuery +=    " AND NXA.NXA_CESCR = '" + cEscrit + "'"
		cQuery +=    " AND NXA_TIPO = '" + PadR( "MF", TamSX3("NXA_TIPO")[1] ) + "'"
		cQuery +=    " AND NXA.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )

		DbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQr, .T., .T. )

		If !Empty((cAliasQr)->MAX_COD)
			cNextNum := (cAliasQr)->MAX_COD
			cNextNum := '00'+Substr(cNextNum,3) //Retira o prefixo
			cNextNum := Soma1(cNextNum) //Incrementa o numero
		Else
			cNextNum := StrZero( 1, TamSX3("NXA_COD")[1] )
		EndIf

		(cAliasQr)->(DbCloseArea())

	ElseIf "JURNMP" $ cChave //Minuta Pre-Fatura

		cQuery := " SELECT MAX(NXA_COD) as MAX_COD"
		cQuery +=   " FROM " + RetSqlName("NXA") + " NXA"
		cQuery +=  " WHERE NXA.NXA_FILIAL = '" + cFilNXA + "'"
		cQuery +=    " AND NXA.NXA_CESCR = '" + cEscrit + "'"
		cQuery +=    " AND NXA_TIPO = '" + PadR( "MP", TamSX3("NXA_TIPO")[1] ) + "'"
		cQuery +=    " AND NXA.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )

		DbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQr, .T., .T. )

		If !Empty((cAliasQr)->MAX_COD)
			cNextNum := (cAliasQr)->MAX_COD
			cNextNum := '00'+Substr(cNextNum,3) //Retira o prefixo
			cNextNum := Soma1(cNextNum) //Incrementa o numero
		Else
			cNextNum := StrZero( 1, TamSX3("NXA_COD")[1] )
		EndIf

		(cAliasQr)->(DbCloseArea())

	ElseIf "JURNMS" $ cChave //Minuta Sócio

		cQuery := " SELECT MAX(NXA_COD) as MAX_COD"
		cQuery +=   " FROM " + RetSqlName("NXA") + " NXA"
		cQuery +=  " WHERE NXA.NXA_FILIAL = '" + cFilNXA + "'"
		cQuery +=    " AND NXA.NXA_CESCR = '" + cEscrit + "'"
		cQuery +=    " AND NXA_TIPO = '" + PadR( "MS", TamSX3("NXA_TIPO")[1] ) + "'"
		cQuery +=    " AND NXA.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )

		DbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQr, .T., .T. )

		If !Empty((cAliasQr)->MAX_COD)
			cNextNum := (cAliasQr)->MAX_COD
			cNextNum := '00'+Substr(cNextNum,3) //Retira o prefixo
			cNextNum := Soma1(cNextNum) //Incrementa o numero
		Else
			cNextNum := StrZero( 1, TamSX3("NXA_COD")[1] )
		EndIf

		(cAliasQr)->(DbCloseArea())

	EndIf

EndIf

Return cNextNum

//-------------------------------------------------------------------
/*/{Protheus.doc} J203IExcFt
Retorna em um array as exceções de numeração cadastradas para o 
escritório

@Param  cCodEscr Código de escritório com para numeração.

@Return aRet  aRet[1] número inicial da exceção;
              aRet[2] número final da exceção;

@author  Luciano Pereira dos Santos
@since   10/09/2015
/*/
//-------------------------------------------------------------------
Static Function J203IExcFt(cCodEscr)
Local cQuery := ""
Local aRet   := {}

Default cCodEscr := ""

	cQuery := " SELECT NSE.NSE_NUMINI, NSE.NSE_NUMFIN "
	cQuery +=   " FROM " + RetSqlName("NSE") + " NSE "
	cQuery +=  " WHERE NSE.NSE_FILIAL = '" + xFilial("NSE") + "' "
	cQuery +=    " AND NSE.NSE_CESC = '" + cCodEscr + "' "
	cQuery +=    " AND NSE.D_E_L_E_T_ = ' ' "
	cQuery +=  " ORDER BY NSE.NSE_NUMINI "

	aRet := JurSql(cQuery, "*")

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ILog
Rotina para exibir o log de diagnóstico de teste da rotina da J203I

@param cNumFat,   Código da Fatura
@param cTpNum,    Tipo de fatura:
                   - FT - Fatura
                   - MF - Minuta de Fatura
                   - MP - Minuta de Pre-Fatura
                   - MS - Minuta de Sócio
@param cCodEscr,  Código do Escritorio
@param cCodMoeda, Código da Moeda da Fatura
@param lHonor,    Possui honorarios?
@param lDesp,     Possui despesas?
@param lFatIntl,  Indica se é fatura internacional
@param cCodMin,   Código mínimo permitido para emissão
@param cCodMax,   Código máximo permitido para emissão
@param cFlagSXE,  Flag usada no controle de numeração
@param dDtEmiss,  Data de emissão da Fatura

@return Nil

@author Luciano Pereira dos Santos
@since  17/09/2015
/*/
//-------------------------------------------------------------------
Static Function J203ILog(cNumFat, cTpNum, cCodEscr, cCodMoeda, lHonor, lDesp, lFatIntl, cCodMin, cCodMax, cFlagSXE, dDtEmiss)
Local cMsgLog := ""
Local lMV_JDFTINT := .F.// Diferenciar Numeração de Faturas Internacionais? - Padrão .F.
Local lMV_JDFTHON := .F.// Diferenciar Numeração de Faturas de Honorários? - Padrão .F.
Local lMV_JDFTDES := .F.// Diferenciar Numeração de Faturas de Despesas? - Padrão .F.
Local cMV_JMOENAC := '' // Moeda Nacional
Local cMV_JNFTINT := '' // Numeração Diferenciada para Faturas Internacionais
Local cMV_JNFTHON := '' // Numeração Diferenciada para Faturas de Honorários
Local cMV_JNTDES  := '' // Numeração Diferenciada para Faturas de Despesas
Local nTamCod     := 0
Local aRet        := {}
Local nHandle     := 0
Local nExec       := 0

If Empty(cNumFat)
	lMV_JDFTINT := GetMv( "MV_JDFTINT", Nil, .F.                )
	lMV_JDFTHON := GetMv( "MV_JDFTHON", Nil, .F.                )
	lMV_JDFTDES := GetMv( "MV_JDFTDES", Nil, .F.                )
	cMV_JMOENAC := GetMv( "MV_JMOENAC", Nil, "01"               )
	cMV_JNFTINT := GetMv( "MV_JNFTINT", Nil, CriaVar("NXA_COD",.F.) )
	cMV_JNFTHON := GetMv( "MV_JNFTHON", Nil, CriaVar("NXA_COD",.F.) )
	cMV_JNTDES  := GetMv( "MV_JNTDES" , Nil, CriaVar("NXA_COD",.F.) )

	nTamCod :=  TamSX3("NXA_COD")[1]
	If !Empty(cMV_JNFTINT)
		cMV_JNFTINT := StrZero(Val(cMV_JNFTINT),nTamCod)
	EndIf
	If !Empty(cMV_JNFTHON)
		cMV_JNFTHON := StrZero(Val(cMV_JNFTHON),nTamCod)
	EndIf
	If !Empty(cMV_JNTDES)
		cMV_JNTDES  := StrZero(Val(cMV_JNTDES), nTamCod)
	EndIf
	If Empty(cCodMin)
		cCodMin     := StrZero(0, nTamCod)
	EndIf
	aRet    := J203IExcFt(cCodEscr)

	cMsgLog += "========================================"          + CRLF
	cMsgLog += OemToAnsi(STR0011)                                  + CRLF //"Rotina numeração de fatura JURA203I"
	cMsgLog += OemToAnsi(I18N(STR0012,{AllToChar(Date()),AllToChar(Time())})) + CRLF //"Data: #1  horário: #2"
	cMsgLog += "========================================"          + CRLF
	cMsgLog += OemToAnsi(STR0013)                                  + CRLF //"Parametros de entrada da rotina: "
	cMsgLog += OemToAnsi(STR0031) + AllToChar(dDtEmiss)            + CRLF //"Data de emissão      := "
	cMsgLog += OemToAnsi(STR0014) + "'" + cTpNum + "'"             + CRLF //"Tipo de fatura       := "
	cMsgLog += OemToAnsi(STR0015) + "'" + cCodEscr + "'"           + CRLF //"Código do Escritório := "
	cMsgLog += OemToAnsi(STR0016) + cCodMoeda                      + CRLF //"Moeda da Fatura      := "
	cMsgLog += OemToAnsi(STR0017) + Iif(lHonor,STR0018,STR0019)    + CRLF //"Tem honorários?      := "
	cMsgLog += OemToAnsi(STR0020) + Iif(lDesp,STR0018,STR0019)     + CRLF //"Tem despesas?        := "
	cMsgLog += OemToAnsi(STR0021) + Iif(lFatIntl,STR0018,STR0019)  + CRLF //"É internacional?     := "
	For nExec := 1 To Len(aRet)
		cMsgLog += "----------------------------------------"      + CRLF
		cMsgLog += OemToAnsi(STR0022)                              + CRLF //"Controle de Exceção de Fatura: "
		cMsgLog += OemToAnsi(STR0023) + aRet[nExec][1]             + CRLF //"Inicio da exceção    := "
		cMsgLog += OemToAnsi(STR0024) + aRet[nExec][2]             + CRLF //"Final da exceção     := "
	Next nExec
	cMsgLog += "----------------------------------------"          + CRLF
	cMsgLog += OemToAnsi(STR0025)                                  + CRLF //"Configuração dos parametros do sistema: "
	cMsgLog += "MV_JDFTINT := " + alltochar(lMV_JDFTINT) + CRLF
	cMsgLog += "MV_JNFTINT := " + cMV_JNFTINT            + CRLF
	cMsgLog += "MV_JDFTHON := " + alltochar(lMV_JDFTHON) + CRLF
	cMsgLog += "MV_JNFTHON := " + cMV_JNFTHON            + CRLF
	cMsgLog += "MV_JDFTDES := " + alltochar(lMV_JDFTDES) + CRLF
	cMsgLog += "MV_JNTDES  := " + cMV_JNTDES             + CRLF
	cMsgLog += "MV_JMOENAC := " + cMV_JMOENAC            + CRLF

	cMsgLog += "----------------------------------------"          + CRLF
	cMsgLog += OemToAnsi(STR0026)                                  + CRLF //"Condições para gerar o número: "
	cMsgLog += OemToAnsi(STR0027) + cCodMin                        + CRLF //"Inicio do intervalo := "
	cMsgLog += OemToAnsi(STR0028) + cCodMax                        + CRLF //"Fim do intervalo    := "
	cMsgLog += OemToAnsi(STR0029) + cFlagSXE                       + CRLF //"Chave de controle   := "
Else
	cMsgLog := OemToAnsi(STR0030) + cNumFat                        + CRLF //"Número gerado       := "
	cMsgLog += CRLF
EndIf

If (nHandle := FOpen('numfat.pfs', 2 )) > 0
	FSeek(nHandle, 0, 2)
	FWrite(nHandle, cMsgLog)
	Fclose(nHandle)
EndIf

JurLogMsg(cMsgLog)

Return
