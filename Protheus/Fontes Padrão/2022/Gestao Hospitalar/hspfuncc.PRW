#INCLUDE "HSPFUNCC.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "plstiss.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_VerDigi ³ Autor ³ Patricia Queiroz      ³ Data ³01.02.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para validar os caracteres informados. Os caracteres   ³±±
±±³          ³nao permitidos serao informados no parametro MV_CARACTE.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Conteudo do campo válido                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome do campo a ser validado                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VerDigi(cCampo)

	Local aArea     := GetArea()
	Local cCaracter := GETMV("MV_CARACTE")
	Local lRet      := .T.
	Local nFor      := 0, nCont := 0
	Local aDigito   := {}

	For nFor := 1 To Len(cCaracter)
		aAdd(aDigito, {SubStr(cCaracter, nFor, 1)})
	Next

	For nFor := 1 To Len(aDigito)
		If aDigito[nFor, 1] $ cCampo
			nCont++
		EndIf
	Next

	If nCont > 0
		HS_MsgInf(STR0001, STR0002, STR0003) //"Há caracteres não permitidos."###"Atenção"###"Validação de Caracteres"
		lRet := .F.
	EndIf
	RestArea(aArea)

Return(lRet)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_AtuApt  ³ Autor ³ Patricia Queiroz      ³ Data ³29.03.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡ao ³Funcao para scheduler da aptidao do doador.                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nil                                                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpL1: Indica se a rotina é rodada pelo scheduler        (OPC)³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_AtuApt(lDireto)

	Default lDireto := .F.


	If IsBlind() .Or. lDireto
		BatchProcess(STR0004, STR0005,, { || FS_AtuApt()}, { || .F. }) //"Atualização da aptidão do doador."###"A rotina de atualização de aptidão do doador tem por objetivo atualizar no Cadastro de Paciente a aptidão do doador."
	Return(Nil)
	Else
		If MsgYesNo(STR0006, STR0002) //"Confirma atualização da aptidão do doador."###"Atenção"
			FS_AtuApt()
		EndIf
	EndIf

Return(Nil)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ FS_AtuApt  ³ Autor ³ Patricia Queiroz      ³ Data ³29.03.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡ao ³Funcao para atualizar automaticamente se o doador está apto   ³±±
	±±³          ³ou nao                                                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nil                                                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³                                                              ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function FS_AtuApt()

	Local aArea    := GetArea()
	Local cSql     := ""
	Local dUltData := dDataBase - 365
	Local nQtdDia  := 0
	Local linap    := .F.


	DbSelectArea("GBH")
	DbSetOrder(1) //GBH_FILIAL + GBH_CODPAC
	DbGoTop()

	While !Eof() .And. xFilial("GBH") == GBH->GBH_FILIAL
		If (!Empty(GBH->GBH_CDINAP) .And. (lInap := HS_IniPadr("GGN", 1, GBH->GBH_CDINAP, "GGN_TPINAP",, .F.) <> "0"))

			nQtdDia := HS_IniPadr("GGN", 1, GBH->GBH_CODPAC, "GGN_QTDDIA",, .F.)

			cSql := "SELECT MAX(GCY.GCY_DATATE) QRY_DATATE
			cSql += " FROM " + RetSqlName("GCY") + " GCY "
			cSql += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
			cSql += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dUltData) + "' AND '" + DTOS(dDataBase) + "' "
			cSql += " AND GCY.GCY_REGGER = '" + GBH->GBH_CODPAC + "' AND GCY.GCY_ATENDI = '3' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "QRY"

			DbSelectArea("QRY")

			If !Empty(QRY_DATATE)
				If (nQtdDia + STOD(QRY_DATATE)) < dDataBase
					RecLock("GBH", .F.)
					GBH->GBH_CDINAP := Space(Len(GBH->GBH_CDINAP))
					MsUnLock()
				EndIf
			EndIf
		EndIf

		DbSkip()
	EndDo


	RestArea(aArea)

Return(Nil)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_RetCpos ³ Autor ³ Bruno Santos          ³ Data ³25.05.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Funcao para retornar todos os campos da SX3 para select       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpU1: String com todos os campos separados por virgulas      ³±±
	±±³          ³       ou array com todos os campos                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Alias da tabela                                        ³±±
	±±³          ³ExpL2: Retorna campos com prefixo                        (OPC)³±±
	±±³          ³ExpC3: Separador do prefixo com o campo(".","->")        (OPC)³±±
	±±³          ³ExpC4: Filtro na tabela SX3                              (OPC)³±±
	±±³          ³ExpA5: Retorna Array com os campos                       (OPC)³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_RetCpos(cAlias, lRetPref, cSepPref, cFiltroSX3, lRetArray)

	Local aArea        := GetArea()
	Local aRetCpo      := {}
	Local cRetCpo      := ""
	Local cPref        := ""

	Default lRetPref   := .F.
	Default cSepPref   := "."
	Default cFiltroSX3 := " 1 = 1 "
	Default lRetArray  := .F.

	cPref      := PrefixoCpo(cAlias)+cSepPref
	cFiltroSX3 := IIF(Empty(cFiltroSX3),"1 = 1",cFiltroSX3)

	DbSelectArea("SX3")
	DbSetOrder(1)

	DbGoTop()
	DbSeek(cAlias)
	While !Eof() .And. (SX3->X3_ARQUIVO == cAlias)
		If SX3->X3_CONTEXT <> "V" .And. &(cFiltroSX3)
			If cRetCpo # ""
				cRetCpo += ","
			EndIf
			cRetCpo += IIF(lRetPref,cPref," ")+SX3->X3_CAMPO
			aAdd(aRetCpo,IIF(lRetPref,cPref," ")+SX3->X3_CAMPO)
		EndIf
		dbSkip()
	EndDo

	RestArea(aArea)

Return(IIF(lRetArray,aRetCpo,cRetCpo))

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_DescFil ³ Autor ³ Daniel Peixoto        ³ Data ³14.06.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Retorna a conteudo de um campo da SM0 de acordo com a filial  ³±±
	±±³          ³passada por parametro                                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpC1: Conteudo do campo                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Codigo da filial                                       ³±±
	±±³          ³ExpC2: Nome do campo de retorno                               ³±±
	±±³          ³ExpL3: Se campo esta em uma enchoice                     (OPC)³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_DescFil(cCodFil, cCpoRet, lEnch)
	Local aAreaOld  := GetArea()
	Local cCodChave := ""
	Local cDescri   := ""
	Local aSM0      := SM0->(GetArea())

	Default lEnch := .F.

	cCodChave := IIf(Inclui, "", IIf("TMP" $ Alias() .Or. lEnch	, &(cCodFil), ""))

	DBSelectArea("GHZ")
	If !EMPTY(cCodChave)
		cDescri := Posicione("SM0", 1, IIF(FindFunction("FWGRPCompany"), FWGRPCompany(),SM0->M0_CODIGO) + cCodChave, cCpoRet)
	EndIf

	RestArea(aSM0)
	RestArea(aAreaOld)
Return(cDescri)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_RetFilF ³ Autor ³ Daniel Peixoto        ³ Data ³15.06.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Rotina que verifica se existe alguma regra para filial        ³±±
	±±³      			 ³de faturamento                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpC1: Filial de faturamento                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Código do convenio                                     ³±±
	±±³          ³ExpC2: Código do plano                                        ³±±
	±±³          ³ExpC3: Código do setor                                        ³±±
	±±³          ³ExpC3: Código do tipo de guia                                 ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_RetFilF(cCodCon, cCodPla, cCodLoc, cCodTpg)
	Local aAreaOld := GetArea()
	Local cCodFilF := xFilial("GCZ")
	Local cChvGhz  := cCodCon

	If Empty(xFilial("GA9")) .And. Empty(xFilial("GCM"))
		DbSelectArea("GHZ")
		DbSetOrder(1) //CODCON+PRIORI+CODPLA+CODLOC+CODTPG
		If DbSeek(xFilial("GHZ") + cCodCon)

			While !Eof() .And. xFilial("GHZ") == GHZ->GHZ_FILIAL .And. GHZ->GHZ_CODCON == cCodCon
				cChvGhz += IIf(GHZ->GHZ_CODPLA == "0", cCodPla, Space(Len(GHY->GHY_CODPLA)))
				cChvGhz += IIf(GHZ->GHZ_CODLOC == "0", cCodLoc, Space(Len(GHY->GHY_CODLOC)))
				cChvGhz += IIf(GHZ->GHZ_CODTPG == "0", cCodTpg, Space(Len(GHY->GHY_CODTPG)))

				DbSelectArea("GHY")
				DbSetOrder(2) //FILIAL+CODCON+CODPLA+CODLOC+CODTPG
				If DbSeek(xFilial("GHY") + cChvGhz) .And. GHY->GHY_VIGENC <= dDataBase
					cCodFilF := GHY->GHY_FILFAT
					Exit
				EndIf

				DbSelectArea("GHZ")
				DbSkip()
			EndDo

		EndIf

	EndIf


	RestArea(aAreaOld)

Return(cCodFilF)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_CADPRO  ³ Autor ³ Mario Arizono         ³ Data ³02.07.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Função para cadastrar novo profissional.                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpA1: Array contendo se cadastrou profissional e mensagem de ³±±
	±±³          ³       erro                                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Alias da tabela onde tem o código do medico a relaciona³±±
	±±³          ³ExpO2: Objeto MsNewGetDados onde tem o código do medico a     ³±±
	±±³          ³       relacionar                                             ³±±
	±±³          ³ExpN3: Posicao da coluna Nome do Medico na MsNewGetDados      ³±±
	±±³          ³ExpC4: Variavel de memoria referente ao codigo do medico      ³±±
	±±³          ³ExpC4: Variavel de memoria referente ao nome do medico        ³±±
	±±³          ³ExpC4: Se valida tipo de profissional                    (OPC)³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_CadPro(cAlias, oVet, nPosCrm, nPosNome, cVarCrm, cVarNome, lTipPro)

	Local aArea   := GetArea()
	Local lRet    := .F.
	Local lVldTip := .T.
	Local cMsg    := ""
	Default lTipPro := .F.

	If MsgYesNo(STR0007)//"Profissional não encontrado, deseja cadastrá-lo ?"
		HS_MntA24("SRA", 0, 3)
		If !EMPTY(SRA->RA_CODIGO)
			lVldTip := IIF(lTipPro, GBJ->GBJ_TIPPRO $ "0/1/2", .T.)
			If lVldTip
				If GBJ->GBJ_STATUS <> "0"
					If oVet <> Nil
						oVet:aCols[oVet:nAt, nPosCrm]  := SRA->RA_CODIGO
						oVet:aCols[oVet:nAt, nPosNome] := SRA->RA_NOME
						oVet:oBrowse:Refresh()
						lRet := .T.
					Else
						&("M->" + cAlias + "_" + cVarCrm) := SRA->RA_CODIGO
						&("M->" + cAlias + "_" + cVarNome):= SRA->RA_NOME
						lRet := .T.
					Endif
				Else
					cMsg := STR0010 //"Profissional encontra-se inativo em seu cadastro."
				Endif
			Else
				cMsg := STR0008 //"Profissional não é do tipo médico em seu cadastro. Verifique."
			Endif
		Else
			cMsg := STR0009 //"Nenhum profissional cadastrado."
		Endif
	Else
		cMsg := STR0009 //"Nenhum profissional cadastrado."
	Endif

	RestArea(aArea)

Return({lRet, cMsg})

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_MntTISS ³ Autor ³ Patricia Queiroz      ³ Data ³09.07.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Funcao responsavel pela impressao das guias TISS.             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Nome da rotina que executou a funcao                   ³±±
	±±³          ³ExpC2: Parametro inutilizado                             (OPC)³±±
	±±³          ³ExpC3: Sequencial da guia para impressao                 (OPC)³±±
	±±³          ³ExpN4: Indica se chama partiu de uma opcao na browse     (OPC)³±±
	±±³          ³ExpL5: Parametro inutilizado                             (OPC)³±±
	±±³          ³ExpA5: Array contendo os numeros sequenciais das guias para a ³±±
	±±³          ³       impressao (utilizado da Auditoria de contas)      (OPC)³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_MntTISS(cRot, cLayout, cNrSeqG, nOpcRot, lOutDesp, aMarkBrow)

	Local aCpos := {{"C", "GA9_OUTDES"},;
		{"C", "G17_MODIMP"},;
		{"C", "GBJ_CBOTIS"},;
		{"C", "G20_CODXML"}}

	Local aArea    := GetArea()
	Local aParLay  := {}
	Local nQtdDigAno := IIf(Len(DToC(Date())) == 10, 4, 2)
	Local cPerg      := "HSPTIS"
	Local nForModImp := 0, iConta := 0
	Local aAux := {}, nCont := 0
	Private cImpTISS := GetMV("MV_IMPTISS")
	Private lDefPap  := IIF(GetMV("MV_DEFPAPE",, "N") == "S", .T., .F.)  // Determina se o usuario ira redefinir o papel para impressao, se S a pergunta será apresentada, se N nao apresenta pergunta considerando o valor salvo, e se nao tiver nada passa a considerar o padrão que é A4
	Private cRotina := cRot
	Private lVsTISS  := IIF(GetMV("MV_VISTISS") == "S", .F., .T.)  // S para visualizar e N para não visualizar// F visualiza a impressão T imprimi direto

	Private nLayout    := 2    //1 - Formato Ofício II (216x330mm)
																											//2 - Formato A4 (210x297mm)
																											//3 - Formato Carta (216x279mm)

	Default cLayout   := ""
	Default cNrSeqG   := ""
	Default nOpcRot   := 0
	Default lOutDesp  := .F.
	Default aMarkBrow := {}

	If !HS_ExisDic(aCpos)
	Return(.F.)
	EndIf

	If cRotina = "M24"
		If !Pergunte("HSPTI3", cImpTISS == "S")
		Return(.F.)
		EndIf
	Else
		If !Pergunte("HSPTI2", cImpTISS == "S")
		Return(.F.)
		EndIf
	Endif
	aParLay := {MV_PAR01, MV_PAR02, MV_PAR03} // MV_PAR01 Imprime Guia do TISS

	If MV_PAR01 == 1 .Or. MV_PAR02 == 1 .Or. MV_PAR03 == 1
		Pergunte(cPerg, lDefPap)
		nLayout := MV_PAR01

		If nQtdDigAno == 4
			SET DATE FORMAT "dd/mm/yy"
		EndIf

		If cRotina == "M24" .And. nOpcRot == 1 //Chamada da opcao Guias TISS do M24
			If !(aGuiaTISS := FS_RetLay(aParLay))[1]
			Return(.F.)
			Else
				lSelGuias := .T.
			EndIf
		Else
			aGuiaTISS := FS_RetLay(aParLay, cNrSeqG)
			lSelGuias := .T.
		EndIf
	Else
	Return(.F.)
	EndIf

	If cRotina == "P12" .And. Iif(Type("MV_PAR04") == "N", MV_PAR04 == 2, .F.) //Marcacao
		AADD(aAux, aGuiaTISS[1])
		AADD(aAux, {})
		For nCont := 1 To Len(aMarkBrow)
			If (nPos := aScan(aGuiaTISS[2], {|aVet| aVet[1] == aMarkBrow[nCont][1]})) > 0
				AADD(aAux[2], aGuiaTISS[2][nPos])
			EndIf
		Next
		aGuiaTISS := aClone(aAux)
	EndIf
	If aGuiaTISS[1] //Não Ok
		For iConta := 1 to Len(aGuiaTiss[2])
			For nForModImp := 1 to Len(aGuiaTiss[2][iConta][2])
				If aGuiaTiss[2][iConta][2][nForModImp] == "0" // ***Guia Consulta***
					Hs_ImpGCon(aGuiaTiss[2][iConta][1])
				ElseIf aGuiaTiss[2][iConta][2][nForModImp] == "1" //***SADT***
					Hs_ImpSadt(aGuiaTiss[2][iConta][1])
				ElseIf aGuiaTiss[2][iConta][2][nForModImp] == "2" // ***Solicitacao de Internacao***
					Hs_ImpSInt(aGuiaTiss[2][iConta][1])
				ElseIf aGuiaTiss[2][iConta][2][nForModImp] == "3" // ***Resumo de Internacao***
					Hs_ImpRInt(aGuiaTiss[2][iConta][1])
				EndIf
			Next

			If aGuiaTiss[2][iConta][3] //***Outras Despesas***
				Hs_ImpODsp(aGuiaTiss[2][iConta][1])
			EndIf
		Next
		Hs_ImpHInd(aGuiaTiss[2])
	EndIf

	If nQtdDigAno == 4
		SET DATE FORMAT "dd/mm/yyyy"
	EndIf

	RestArea(aArea)
Return(Nil)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ Fs_RetLay  ³ Autor ³ Patricia Queiroz      ³ Data ³21.07.2007 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡ao ³Função para retornar os layout TISS.                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpA1: Array contendo se Tudo Ok e array com guias selecionadas³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpA1: Array com os tipos de guias que virao pre-selecionados  ³±±
	±±³          ³ExpC2: Sequenciais das guias para impressao              (OPC) ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function FS_RetLay(aParLay, cGuiaP12)

	Local aArea   := GetArea()
	Local aSize   := {}, aObjects := {}, aInfo := {}, aPObjs := {}
	Local cSql := "", aGuias := {}
	Local cGCZNRGUIA := "", cGCZDESPLA := "", cG17MODIMP := "", cRetGuia := "", cOutras := 0, cHonInd := "", cGCZNRSEQG := 0
	Local aHGCZ   := {}, aCGCZ := {}, aButtons := {}
	Local nUGCZ   := 0
	Local lOK     := cRotina # "M24", lMarca := .T.
	Local nTdOk   := 0
	Local nForGCZ := 0
	Local nPos    := 0

	Private oGCZ
	Private nGCZNRGUIA := 0, nGCZDESPLA := 0, nG17MODIMP := 0,  nGUIAS := 0, nOUTRAS := 0, nHonInd := 0, nGCZNRSEQG := 0

	Default cGuiaP12 := ""

	Define  FONT oFont NAME "Arial,16," BOLD

	Aadd(aHGCZ, {"Nro Guia"     , "cGCZNRGUIA", "@!", Len(GCZ->GCZ_NRGUIA), 0, ".F.", ""    , "C", "", "V" ,"" , "", "", "V"})
	nGCZNRGUIA := ++nUGCZ

	Aadd(aHGCZ, {"Desc. Plano"  , "cGCZDESPLA", "@!", Len(GCM->GCM_DESPLA), 0, ".F.", ""    , "C", "", "V" ,"" , "", "", "V"})
	nGCZDESPLA := ++nUGCZ

	Aadd(aHGCZ, {"Mod. Relator.", "cG17MODIMP", "@!", Len(G17->G17_MODIMP), 0, ".F.", ""    , "C", "", "V" ,"" , "","","V"})
	nG17MODIMP := ++nUGCZ

	Aadd(aHGCZ, {"Guia"         , "cRetGuia", "@BMP"  , 2, 0, ".F.", ""    , "C", "", "V" , "" , "","","V"})
	nGuias     := ++nUGCZ

	Aadd(aHGCZ, {"Outras Desp." , "cOutras", "@BMP" , 2, 0, ".F.",""    , "C", "",   "V", "" , "","","V"})
	nOutras    := ++nUGCZ

	Aadd(aHGCZ, {"Honor. Indiv." , "cHonInd", "@BMP" , 2, 0, ".F.",""    , "C", "",   "V", "" , "","","V"})
	nHonInd    := ++nUGCZ

	Aadd(aHGCZ, {"Nro. Seq. Guia", "cGCZNRSEQG", "@!", Len(GCZ->GCZ_NRSEQG), 0,".F.",""    , "C", "", "V" ,"" , "","","V"})
	nGCZNRSEQG := ++nUGCZ

 /*If GCZ->GCZ_NRSEQG $ cGuiaP12
	 If !IsMark("GCZ_IDMARC",cMarca)
	 	RecLock("GCZ",.F.)
		 	Replace GCZ->GCZ_IDMARC With cMarca
		MsUnLock()
	 EndIf
 EndIf*/

	cSql := "SELECT GCZ.GCZ_FILIAL, GCZ.GCZ_REGGER, GCZ.GCZ_FILFAT, GCZ.GCZ_FILATE, GCZ.GCZ_NRLOTE, GCZ.GCZ_NREXTC, "
	cSql += " GCZ.GCZ_NRPROT, GCZ.GCZ_CODPLA, GCZ.GCZ_NUMORC, GCZ.GCZ_NRNOTA, GCZ.GCZ_NRSEQG, GCZ.GCZ_IDGUIA, "
	cSql += " GCZ.GCZ_NRGUIA, GCM.GCM_DESPLA, GCZ.GCZ_STATUS, G17.G17_MODIMP MODIMP, GCZ.GCZ_REGATE, GCZ_IDMARC, "
	cSql += " GCZ.GCZ_CODCON, GCZ.GCZ_DATFAT, GCZ.GCZ_CODTPG, GCZ.GCZ_NOME, GCZ.GCZ_SERIE, GCZ.GCZ_CDCCNA, GCZ.GCZ_CDCBOR, "
	cSql += " GCZ.GCZ_DATATE, GCZ.GCZ_LOCATE, GCZ.GCZ_ATENDI, GCZ.GCZ_CANCEL "
	cSql += "FROM " + RetSqlName("GCZ") + " GCZ "
	cSql += "JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA "
	cSql += "JOIN " + RetSqlName("GCU") + " GCU ON GCU.GCU_FILIAL = '" + xFilial("GCU") + "' AND GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG "
	cSql += "JOIN " + RetSqlName("G17") + " G17 ON G17.G17_FILIAL = '" + xFilial("G17") + "' AND G17.D_E_L_E_T_ <> '*' AND G17.G17_CODIGO = GCU.GCU_TGTISS "
	cSql += "JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_TIPCON <> '1' "
	cSql += "WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
	If cRotina == "M24"
		cSql += " AND GCZ.GCZ_REGATE = '" + GCY->GCY_REGATE + "' "
	Else
		If FunName() == "HSPAHP12"
			cSql += " AND (GCZ.GCZ_IDMARC = '" + cMarca + "'  OR GCZ.GCZ_NRSEQG IN (" + HS_InSql(cGuiaP12, 20) + ")) "
		Else
			cSql += " AND GCZ.GCZ_NRSEQG IN (" + HS_InSql(cGuiaP12, 20) + ") "
		EndIf
	EndIf

	cSql += "  AND G17.G17_MODIMP <> '"+Space(TamSx3("G17_MODIMP")[1])+"' "

	cSql += "UNION "

	cSql += "SELECT GCZ.GCZ_FILIAL, GCZ.GCZ_REGGER, GCZ.GCZ_FILFAT, GCZ.GCZ_FILATE, GCZ.GCZ_NRLOTE, GCZ.GCZ_NREXTC, "
	cSql += " GCZ.GCZ_NRPROT, GCZ.GCZ_CODPLA, GCZ.GCZ_NUMORC, GCZ.GCZ_NRNOTA, GCZ.GCZ_NRSEQG, GCZ.GCZ_IDGUIA, "
	cSql += " GCZ.GCZ_NRGUIA, GCM.GCM_DESPLA, GCZ.GCZ_STATUS, GN2.GN2_MODIMP MODIMP, GCZ.GCZ_REGATE, GCZ_IDMARC, "
	cSql += " GCZ.GCZ_CODCON, GCZ.GCZ_DATFAT, GCZ.GCZ_CODTPG, GCZ.GCZ_NOME, GCZ.GCZ_SERIE, GCZ.GCZ_CDCCNA, GCZ.GCZ_CDCBOR, "
	cSql += " GCZ.GCZ_DATATE, GCZ.GCZ_LOCATE, GCZ.GCZ_ATENDI, GCZ.GCZ_CANCEL "
	cSql += "FROM " + RetSqlName("GCZ") + " GCZ "
	cSql += "JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA "
	cSql += "JOIN " + RetSqlName("GCU") + " GCU ON GCU.GCU_FILIAL = '" + xFilial("GCU") + "' AND GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG "
	cSql += "JOIN " + RetSqlName("GN2") + " GN2 ON GN2.GN2_FILIAL = '" + xFilial("GN2") + "' AND GN2.D_E_L_E_T_ <> '*' AND GN2.GN2_CODTGT = GCU.GCU_TGTISS "
	cSql += "JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_TIPCON <> '1' "
	cSql += "WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") +  "' AND GCZ.D_E_L_E_T_ <> '*' "

	If cRotina == "M24"
		cSql += " AND GCZ.GCZ_REGATE = '" + GCY->GCY_REGATE + "' "
	Else
		If FunName() == "HSPAHP12"
			cSql += " AND (GCZ.GCZ_IDMARC = '" + cMarca + "'  OR GCZ.GCZ_NRSEQG IN (" + HS_InSql(cGuiaP12, 20) + ")) "
		Else
			cSql += " AND GCZ.GCZ_NRSEQG IN (" + HS_InSql(cGuiaP12, 20) + ") "
		EndIf
	EndIf

	cSql += " ORDER BY " + SqlOrder(GCZ->(IndexKey()))
	cSql := ChangeQuery(cSql)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), "TMPGCZ",.T.,.T.)

	DBSelectArea("TMPGCZ")
	DbGoTop()

	While !Eof()
		aAdd(aCGCZ, {TMPGCZ->GCZ_NRGUIA, SubStr(TMPGCZ->GCM_DESPLA, 1, 35), SubStr(HS_RDescrB("G17_MODIMP", TMPGCZ->MODIMP), 1, 25), IIF(aParLay[1] = 1, "LBTIK", "LBNO"), IIF(aParLay[2] = 1, "LBTIK", "LBNO"), IIF(aParLay[3] = 1, "LBTIK", "LBNO"), TMPGCZ->GCZ_NRSEQG, TMPGCZ->MODIMP, .F.})
		cModImp := TMPGCZ->MODIMP
		DbSkip()
	End

	If Empty(aCGCZ)
		Hs_MsgInf("Nenhum modelo encontrado",STR0002,STR0014)
		DbSelectArea("TMPGCZ")
		DbCLoseArea()
		RestArea(aArea)
	Return({.F., aGuias})
	EndIf

	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd(aObjects, {100, 100, .T., .T.})
	aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
	aPObjs := MsObjSize(aInfo, aObjects, .T.)

	aAdd(aButtons, {"CHECKED", {|| FS_MarcT(lMarca), lMarca := !lMarca}, STR0018, STR0019}) //"Todos"###"Marcar Todos"

	If cRotina == "M24"
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0020) From aSize[5]/5, aSize[6]/100 To aSize[6], aSize[5]*0.65	PIXEL Of oMainWnd //"Guias TISS"

		@aPObjs[1][1] + 06, aPObjs[1][2] + 12 Say STR0020 + " - " + GCY->GCY_REGGER + " - "  + AllTrim(HS_IniPadr("GBH", 1, GCY->GCY_REGGER, "GBH_NOME")) Of oDlg Pixel COLOR CLR_RED FONT oFont //"Guias TISS"

		oGCZ := MsNewGetDados():New(aPObjs[1][1], aPObjs[1][2], aPObjs[1][3], aPObjs[1][4], 0,,,,,,,,,, oDlg, aHGCZ, aCGCZ)
		oGCZ:oBrowse:BlDblClick := {|| FS_DbClik(oGCZ)}
		oGCZ:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nTdOk := 1, IIF(!FS_VldTISS(), nTdOk := 0, oDlg:End())}, {|| nTdOk := 0, oDlg:End()},, aButtons)

		If nTdOk == 1
			lOk := .T.
		EndIf
	EndIf

	If lOk
		oObj := IIF(cRotina == "M24",oGCZ:aCols, aCGCZ)

		For nForGCZ := 1 To Len(oObj)

			If oObj[nForGCZ, nGuias] == "LBNO" .And. oObj[nForGCZ, nOutras] == "LBNO" .And. oObj[nForGCZ, nHonInd] == "LBNO"
				Loop
			EndIf

			If (nPos := aScan(aGuias,{|aVet| aVet[1] == oObj[nForGCZ, nGCZNRSEQG]})) == 0
				aAdd(aGuias, {oObj[nForGCZ, nGCZNRSEQG], {}, .F., .F. })
				nPos := Len(aGuias)
			EndIf

			If oObj[nForGCZ, nGuias] == "LBTIK" .AND. (!oObj[nForGCZ, nGCZNRSEQG+1] $ "4/5")
				aAdd(aGuias[nPos][2], oObj[nForGCZ, nGCZNRSEQG+1])
			EndIf

			If oObj[nForGCZ, nOutras] == "LBTIK" .Or. (oObj[nForGCZ, nGCZNRSEQG+1] == "5" .AND. oObj[nForGCZ, nGuias] == "LBTIK")
				aGuias[nPos][3] := .T.
			EndIf

			If oObj[nForGCZ, nHonInd] == "LBTIK" .Or. (oObj[nForGCZ, nGCZNRSEQG+1] == "4" .AND. oObj[nForGCZ, nGuias] == "LBTIK")
				aGuias[nPos][4] := .T.
			EndIf

		Next
	EndIf

	DbSelectArea("TMPGCZ")
	DbCLoseArea()
	RestArea(aArea)

Return({lOk, aGuias})

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ FS_VldTISS ³ Autor ³ Patricia Queiroz      ³ Data ³25.07.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Funcao para validar Ok na tela de impressao das guias TISS.   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³                                                              ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function FS_VldTISS()

	Local lRet := .T.

	If !(lRet := ( aScan(oGCZ:aCols, {| aVet | aVet[nGuias] == "LBTIK"}) > 0 ;
			.Or.          aScan(oGCZ:aCols, {| aVet | aVet[nOutras] == "LBTIK"}) > 0 ;
			.Or.          aScan(oGCZ:aCols, {| aVet | aVet[nHonInd] == "LBTIK"}) > 0))
		HS_MsgInf(STR0021, STR0002, STR0014) //"Não há guias selecionadas."###"Atenção"###"Validação da guia TISS"
	EndIf

Return(lRet)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ FS_DbClik  ³ Autor ³ Patricia Queiroz      ³ Data ³21.07.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Funcao para marcar e desmarcar o item da MsNewGetDados.       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nil                                                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpO1: MsNewGetDados que sofrera as alteracoes                ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function FS_DbClik(oGCZ)
	If oGCZ:aCols[oGCZ:nAt, oGCZ:oBrowse:ColPos] $ "LBTIK/LBNO"
		oGCZ:aCols[oGCZ:nAt, oGCZ:oBrowse:ColPos] := IIF(oGCZ:aCols[oGCZ:nAt, oGCZ:oBrowse:ColPos] == "LBTIK", "LBNO", "LBTIK")
	EndIf
Return(Nil)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ FS_MarcT   ³ Autor ³ Patricia Queiroz      ³ Data ³24.07.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Funcao para marcar e desmarcar todos.                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nil                                                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpL1: Marca tudo                                             ³±±
	±±³          ³ExpO2: MsNewGetDados que sofrera as alteracoes                ³±±
	±±³          ³ExpA3: Array com a posicao das colunas de marcacao(LBTIK)     ³±±
	±±³          ³       referentes ao modelo, a Outras Despesas e ao Honorario ³±±
	±±³          ³       individual                                             ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function FS_MarcT(lMarca, oObj, aPos)

	Local nForCols := 0
	Local nContFor := 0
	Local cMarcT   := IIF(lMarca, "LBTIK", "LBNO")

	Default oObj := oGCZ
	Default aPos := {nGUIAS, nOUTRAS, nHonInd}

	For nForCols := 1 To Len(oObj:aCols)
		For nContFor := 1 To Len(aPos)
			oObj:aCols[nForCols, aPos[nContFor]] := cMarcT
		Next
	Next

Return(Nil)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_GuiasPr ³ Autor ³ Daniel Peixoto        ³ Data ³16.08.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Exibe as guias particulares de um atendimento caso exista mais³±±
	±±³      			 ³que uma, senao retorna a unica guia                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpA1: Array contendo o sequenciais das guias selecionadas    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Registro de atendimento                                ³±±
	±±³          ³ExpC1: Condicao de pesquisa para guia                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_GuiasPr(cRegAte, cCondGCZ)
	Local aAreaOLd := GetArea()
	Local aGuias   := {}
	Local aHGCZ    := {}, aCGCZ := {}, nUGCZ := 0
	Local nNroGuias:= 0, nCOnt := 0
	Local aJoin    := {}
	Local cCond    := "GCZ->GCZ_REGATE == '" + cRegAte + "' "
	Local aCposGCZ := {"GCZ_NRSEQG", "GCZ_REGATE", "GCZ_CODPLA", "GCZ_DESPLA", "GCZ_NRGUIA", "GCZ_CODTPG", "GCZ_DESTPG"}

	Private oGCZ

	Default cCondGCZ := ""

	cCond += cCondGCZ

	AADD(aJoin, {" JOIN " + RetSqlName("GA9") + " GA9", "", "GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_TIPCON = '1' AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*'", ""})

	nNroGuias := HS_BDados("GCZ", @aHGCZ, @aCGCZ, @nUGCZ,,, cCond,,,"/",,,, "GCZ_IDMARC", "'LBNO'", .T.,,,,,, aCposGcz, aJoin)
	nGCZIDMARC := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_IDMARC"})
	nGCZNRSEQG := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_NRSEQG"})
	nGCZREGATE := aScan(aHGCZ, {| aVet | aVet[2] == "GCZ_REGATE"})

	If nNroGuias == 0
		HS_MsgInf(STR0023, STR0002, STR0022)//"Nenhuma guia particular encontrada"###"Atenção"###"Seleção de guias Particulares"
	Return(aGuias)
	EndIf

	If nNroGuias == 1
		AADD(aGuias, {aCGCZ[1, nGCZNRSEQG], aCGCZ[1, nGCZREGATE]})

	Else

		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0024) From 000,000 To 300, 800 Of oMainWnd PIXEL//"Guias Particulares"

		oGCZ := MsNewGetDados():New(0, 0, 250, 800,,,,,,,,,,, oDlg, aHGCZ, aCGCZ)
		oGCZ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGCZ:oBrowse:BlDblClick := {|| HS_MARCA("oGCZ", oGCZ:oBrowse:nAt, nGCZIDMARC)}

		nOpcA := 0
		ACTIVATE MSDIALOG oDlg Centered ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIF(FS_VldGPrt(oGCZ:aCols, nGCZIDMARC), oDlg:End(), nOpcA := 0)}, ;
			{|| nOpcA := 0, oDlg:End()})

		If nOpcA == 0
		Return(aGuias)
		Else
			For nCont := 1 To Len(oGCZ:aCols)
				If oGCZ:aCols[nCont, nGCZIDMARC] == "LBTIK"
					AADD(aGuias, {oGCZ:aCols[nCont, nGCZNRSEQG], oGCZ:aCols[nCont, nGCZREGATE]})
				EndIf
			Next
		EndIf

	EndIf

	RestArea(aAreaOld)
Return(aGuias)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ FS_VldGPrt ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Verifica se alguma guia particular foi marcada                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpA1: Array para validacao                                   ³±±
	±±³          ³ExpN1: Posicao do campo de marcacao(LBTIK) no array           ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function FS_VldGPrt(aCols, nPos)
	Local lRet  := .F.
	Local nCont := 0

	For nCont := 1 To Len(aCols)
		If aCols[nCont, nPos] == "LBTIK"
			lRet := .T.
			Exit
		EndIf
	Next

	If !lRet
		HS_MsgInf(STR0025, STR0002, STR0024)//"Nenhuma guia particular encontrada"###"Atenção"###"Guias Particulares"
	EndIf
Return(lRet)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_CalcDsc ³ Autor ³ Daniel Peixoto        ³ Data ³21.08.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Calcula os valores/percentuais de descontos e valida se o     ³±±
	±±³      			 ³usuário caixa tem permissão para aplica-lo.                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Conteudo do campo válido                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Nome do campo a ser validado                           ³±±
	±±³          ³ExpN2: Valor do descont a ser aplicado                        ³±±
	±±³          ³ExpC3: Observação referente ao deconto                        ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_CalcDsc(cCpo, nDesPer, cDesObs)
	Local aAreaOld   := GetArea()
	Local cAlias     := ""
	Local cColAtu    := ""
	Local oObj
	Local nValor     := 0, nDescP := 0, nDescV := 0
	Local lRet       := .T.
	Local aDesc      := {}
	Local cCodCon    := ""
	Local lRepCDsc   := .F.
	Local lFacilit   := ValType(nDesPer) <> "U"
	Local aCposDsc   := {{"C", "GD5_DESPER"}, {"C", "GD5_DESVAL"}, {"C", "GD5_DESOBS"}, {"C", "GD5_VALTOT"}, {"C", "GD5_TOTDSC"},;
		{"C", "GD6_DESPER"}, {"C", "GD6_DESVAL"}, {"C", "GD6_DESOBS"}, {"C", "GD6_VALTOT"}, {"C", "GD6_TOTDSC"},;
		{"C", "GD7_DESPER"}, {"C", "GD7_DESVAL"}, {"C", "GD7_DESOBS"}, {"C", "GD7_VALTOT"}, {"C", "GD7_TOTDSC"},{"C","GD7_VALREB"},;
		{"C", "GE5_DESPER"}, {"C", "GE5_DESVAL"}, {"C", "GE5_DESOBS"}, {"C", "GE5_VALTOT"}, {"C", "GE5_TOTDSC"},;
		{"C", "GE6_DESPER"}, {"C", "GE6_DESVAL"}, {"C", "GE6_DESOBS"}, {"C", "GE6_VALTOT"}, {"C", "GE6_TOTDSC"},;
		{"C", "GE7_DESPER"}, {"C", "GE7_DESVAL"}, {"C", "GE7_DESOBS"}, {"C", "GE7_VALTOT"}, {"C", "GE7_TOTDSC"},{"C","GD7_VALREB"},;
		{"C", "GG5_DESPER"}, {"C", "GG5_DESVAL"}, {"C", "GG5_DESOBS"}, {"C", "GG5_VALTOT"}, {"C", "GG5_TOTDSC"},;
		{"C", "GG6_DESPER"}, {"C", "GG6_DESVAL"}, {"C", "GG6_DESOBS"}, {"C", "GG6_VALTOT"}, {"C", "GG6_TOTDSC"},;
		{"C", "GG7_DESPER"}, {"C", "GG7_DESVAL"}, {"C", "GG7_DESOBS"}, {"C", "GG7_VALTOT"}, {"C", "GG7_TOTDSC"}}

	Default cCpo    := ReadVar()

	cAlias := SUBSTR(cCpo, 4, 3)

	If HS_ExisDic(aCposDsc, .F.) .And. !Empty(cCpo) .And.(lFacilit .Or. Type(cCpo) <> "U") .And. ;
			((FunName() <> "HSPAHP12" .And. IsCaixaLoja(xNumCaixa())) .Or. FunName() == "HSPAHP12") .And. cAlias $ "GD5/GE5/GD6/GE6/GD7/GE7"

		If !HS_VldSx6({{"MV_REPCDSC",{"L","T/F","$"}}},.T.)
			RestArea(aAreaOld)
		Return(lRet)
		EndIf
		lRepCDsc   := GetMv("MV_REPCDSC")

		cPref  := IIF(cAlias $ "GD5/GE5", "MM", IIF(cAlias $ "GD6/GE6", "TD", "PR"))
		oObj := &("oGD" + cPref)

		If !lFacilit .And. SUBSTR(cCpo, 8) $ "VALDES/VFILME/VCUSOP/QTDDES/DESVAL/DESPER/PGTMED/CODCRM"
			oObj:aCols[oObj:nAt, &("n" + cPref + SUBSTR(cCpo, 8))] := &(ReadVar())
		EndIf

		nValor := HS_CValDes(cAlias,,, oObj,,,, .F.)

		If SUBSTR(cCpo, 8) == "DESPER"
			nDescP := IIF(ValType(nDesPer) <> "U", nDesPer,  oObj:aCols[oObj:nAt, &("n" + cPref + "DESPER")])
			nDescV := nValor * (nDescP / 100)
		ElseIf SUBSTR(cCpo, 8) == "DESVAL" .Or. Empty(oObj:aCols[oObj:nAt, &("n" + cPref + "DESPER")])
			nDescV := oObj:aCols[oObj:nAt, &("n" + cPref + "DESVAL")]
			nDescP := 0
		Else
			nDescP := IIF(ValType(nDesPer) <> "U", nDesPer,  oObj:aCols[oObj:nAt, &("n" + cPref + "DESPER")])
			nDescV := nValor * (nDescP / 100)
		EndIf

		If cAlias $ "GD7/GE7" .And. SUBSTR(cCpo, 8) $ "DESPER/DESVAL/PGTMED" .And. oObj:aCols[oObj:nAt, &("n" + cPref + "PGTMED")] == "0"
			cCodCon := HS_IniPadR("GCM", 2, oGDGcz:aCols[oGDGcz:nAt, nGCZCODPLA], "GCM_CODCON",, .F.)
			If HS_RCfgCP(cCodCon, oGDGcz:aCols[oGDGcz:nAt, nGCZCODPLA], "_TIPCON") <> "1"
				If SUBSTR(cCpo, 8) == "PGTMED"
					nDescP := 0
					nDescV := 0
					HS_MsgInf(STR0026, STR0002, STR0027)//"Para Pagamento Médico igual a 'Direto' e o convênio não é particular os descontos serão zerados."###"Atenção"###"Validação de Desconto"
				Else
					HS_MsgInf(STR0028, STR0002, STR0027)//"Impossível aplicar desconto em procedimentos cujo o Pagamento Médico é 'Direto' e o convênio não é particular."###"Atenção"###"Validação de Desconto"
				Return(.F.)
				EndIf
			EndIf
		EndIf

		If nDescV > nValor
			HS_MsgInf(STR0029, STR0002, STR0027)//"Desconto informado maior que o valor da despesa."###"Atenção"###"Validação de Desconto"
		Return(.F.)

		ElseIf nValor == 0 .And. SUBSTR(cCpo, 8) $ "DESPER/DESVAL" .And. (nDescV > 0 .Or. nDescP > 0)
			HS_MsgInf(STR0030, STR0002, STR0027)//"Valor da despesas zerado."###"Atenção"###"Validação de Desconto"
		Return(.F.)
		EndIf
		If !(IsInCallStack("HSPAHAIH") .AND. (oGDGcz:aCols[oGDGcz:nAt, nGczCodPla] $ __cCodAIH ))
			oObj:aCols[oObj:nAt, &("n" + cPref + "VALTOT")] := HS_CValDes(cAlias,,, oObj,,,, .F.)
		Endif
		aDesc := {"V", nDescV}
		If (lRet := IIF(FunName() == "HSPAHP12", .T., LjProfile(11,, aDesc, nDescP, nDescV) ))
			oObj:aCols[oObj:nAt, &("n" + cPref + "DESPER")]  := nDescP
			oObj:aCols[oObj:nAt, &("n" + cPref + "DESVAL")]  := nDescV

			If ValType(nDesPer) <> "U" //Usa percentual desc. e ObdDesc passado no parametro e nao da GetDados
				oObj:aCols[oObj:nAt, &("n" + cPref + "DESPER")] := nDesPer
				oObj:aCols[oObj:nAt, &("n" + cPref + "DESOBS")] := IIF(!Empty(cDesObs), cDesObs, SPACE(LEN(GD5->GD5_DESOBS)))
			EndIF

			oObj:aCols[oObj:nAt, &("n" + cPref + "TOTDSC")] := HS_CValDes(cAlias,,, oObj)

			If nDescV == 0
				oObj:aCols[oObj:nAt, &("n" + cPref + "DESOBS")] := SPACE(LEN(GD5->GD5_DESOBS))
			EndIf

			If HS_ExisDic({{"C", cAlias + "_VALREP"}}, .F.)
				oObj:aCols[oObj:nAt, &("n" + cPref + "VALREP")]  := IIF(lRepCDsc,((oObj:aCols[oObj:nAt, &("n" + cPref + "TOTDSC")]/oObj:aCols[oObj:nAt, &("n" + cPref + "VALTOT")])),1) * oObj:aCols[oObj:nAt, &("n" + cPref + "VALREB")]
			EndIf
		EndIf

	EndIf

	RestArea(aAreaOld)
Return(lRet)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_FaciDsc ³ Autor ³ Daniel Peixoto        ³ Data ³05.09.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Facilitador para aplicar desconto nas despesas da guia        ³±±
	±±³      			 ³posicionada                                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³                                                              ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_FaciDsc(nGCZStatus)
	Local cTipo := IIF(oGDGcz:aCols[oGDGcz:nAt, nGCZStatus] < "2" , "D", "E")
	Local aTabs := {{"G" + cTipo + "5", "MM", "GBI"}, {"G" + cTipo + "6", "TD", "GAA"}, {"G" + cTipo + "7", "PR", "GA7"}}
	Local nTabs := 0, nDesp := 0
	Local nDesPer := 0, cDesObs := "", cCodLocDe := "", cCodLocAte := "", cGrpDesDe := "", cGrpDesAte := ""
	Local cGrpDes := "", cCodLoc:= ""
	Local cCdAtrib := Iif(Type("cCondAtrib") <> "U",cCondAtrib,"")

	cCondAtrib := ""

	If !Pergunte("HSM24E", .T.)
	Return(Nil)
	EndIf

	cCodLocDe  := MV_PAR01
	cCodLocAte := MV_PAR02
	cGrpDesDe  := MV_PAR03
	cGrpDesAte := MV_PAR04
	nDesPer    := MV_PAR05
	cDesObs    := MV_PAR06

	For nTabs := 1 To Len(aTabs)
		oObj := &("oGD" + aTabs[nTabs, 2])
		For nDesp :=  1 To Len(oObj:aCols)
			oObj:nAt := nDesp

			if &("n" + aTabs[nTabs, 2] + "CODLOC") > 0
				cCodLoc  := oObj:aCols[oObj:nAt, &("n" + aTabs[nTabs, 2] + "CODLOC")]
			EndIf

			cGrpDes  := HS_IniPadR(aTabs[nTabs, 3], 1, oObj:aCols[oObj:nAt, &("n" + aTabs[nTabs, 2] + "CODDES")], aTabs[nTabs, 3] + "_CODGDE",, .F.)
			If oObj:aCols[oObj:nAt, &("n" + aTabs[nTabs, 2] + "VALDES")] > 0 .And. IIF(&("n" + aTabs[nTabs, 2] + "CODLOC") > 0,cCodLoc >= cCodLocDe .And. cCodLoc <= cCodLocAte,.T.) .And. ;
					cGrpDes >= cGrpDesDe .And. cGrpDes <= cGrpDesAte
				HS_CalcDsc("M->" + aTabs[nTabs, 1] + "_DESPER", nDesPer, cDesObs)
				HS_GDAtrib(oObj, {{&("n" + aTabs[nTabs, 2] + "StaReg"), 'BR_AMARELO', 'BR_VERDE'}})
			EndIf
		Next
		oObj:oBrowse:Refresh()
	Next

	cCondAtrib := cCdAtrib
Return(Nil)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_VldDsc  ³ Autor ³ Daniel Peixoto        ³ Data ³03.09.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Retorna a picture para campos numericos, de acordo com        ³±±
	±±³      			 ³seu tamanho e numero de casas decimais que devera' ter.       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Valor do desconto OK                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Alias da tabela de despesa                             ³±±
	±±³	         ³ExpN2: Novo valor da despesa      	                  	  				  ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_VldDsc(cAlias, nValNew)
	Local lRet     := .T.
	Local cPref := cAlias + "->" + cAlias

	If HS_ExisDic({{"C", cAlias + "_DESVAL"}}, .F.)
		lRet :=  nValNew >= &(cPref + "_DESVAL")
	EndIf

Return(lRet)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_RTotais ³ Autor ³ Patricia Queiroz      ³ Data ³01.02.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Inicializador padrão dos campos de totais das tabelas de      ³±±
	±±³      			 ³despesa(GD5,GD6,GD7,GE5,GE6,GE7,GG5,GG6,GG7)                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpN1: Valor total da despesa                                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Nome do campo a ser inicializado                       ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_RTotais(cCpo)
	Local oObj
	Local nTotal := 0
	Local cAlias := SUBSTR(cCpo, 1, 3)
	Local cPref  := cAlias + "->" + cAlias

	If Type("TMP" + cPref + "_SEQDES") <> "U" .And. !EMPTY(&("TMP" + cPref + "_SEQDES"))
		nTotal := HS_CValDes(cAlias, &("TMP" + cPref + "_SEQDES"),,,,,, IIF(SUBSTR(cCpo, 5) == "VALTOT", .F., .T.))
	EndIf

Return(nTotal)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_ImpCntP ³ Autor ³ Daniel Peixoto        ³ Data ³05.09.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Impressao das guias particulares do atendimento               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nil                                                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³                                                              ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_ImpCntP()
	Local aGuias := {}

	aGuias := HS_GuiasPr(GCY->GCY_REGATE)
	If Len(aGuias) > 0
		HSPAHR15("HSPAHM24", aGuias)
	EndIf

Return(Nil)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_LOJAVEN ³ Autor ³ Rogerio Tabosa        ³ Data ³07.05.2010³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Chamada da rotina Venda Assistida do Controle de Lojas        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nil                                                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_LOJAVEN()
	Local lRet := .T.
	Local cSql	:= ""
	Local aSCJ	:= {}

	If oApp:lMDI  // verifica a propriedade do objeto verdadeiro se MDI
		MsgStop(STR0060) //"O acesso a rotina venda assistida na interface SIGAMDI não é permitido"
		lRet  := .F.
	Else
	/* *****************************************************************************
		VERIFICA SE EXISTE ALGUM ORÇAMENTO DO FATURAMENTO SCJ QUE NÃO ESTA INSERIDO
		NO LOJA (SL1) ANTES DA UTILIZAÇÃO DA ROTINA DE VENDA ASSITIDA
	********************************************************************************/
		cSql := " SELECT CJ_NUM FROM " + RetSqlName("SCJ") + " SCJ "
		cSql += " WHERE SCJ.D_E_L_E_T_ <> '*' AND SCJ.CJ_FILIAL = '" + xFilial("SCJ") + "' AND SCJ.CJ_STATUS = 'B' AND"
		cSql += " NOT EXISTS(SELECT 1 FROM " + RetSqlName("GT9") + " GT9 WHERE GT9.GT9_NUMFAT = SCJ.CJ_NUM AND "
		cSql += " GT9.D_E_L_E_T_ <> '*' AND GT9.GT9_FILIAL = '" + xFilial("GT9") + "')"

		cSql := ChangeQuery(cSql)
		TCQUERY cSql NEW ALIAS "QRYORC"

		DbSelectArea("QRYORC")
		If !Eof()
			While !Eof()
				AADD(aSCJ, QRYORC->CJ_NUM)
				DbSkip()
			EndDo
		EndIf
		DbSelectArea("QRYORC")
		DbCloseArea()

		If Len(aSCJ) > 0
			MsgRun("Aguarde, atualizando venda...",, { || HS_AtuLoja(aSCJ)})  //"Aguarde, atualizando venda..."
		EndIf

		LOJA701()
	EndIf
Return(lRet)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_GerCaix ³ Autor ³ Daniel Peixoto        ³ Data ³23.08.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Gerar a informação para ser visto e tratado na opção de Venda ³±±
	±±³      			 ³Assistida, para o caso de um caixa especifico                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nil                                                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpN1: Opçcao selecionada para funcao                         ³±±
	±±³          ³       1 - Gerar Caixa(Orçamento)                             ³±±
	±±³          ³       2 - Finaliza Venda                                     ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_GerCaix(nOpc)
	Local aGuias   := {}, aGuiasGer := {}
	Local nGuias   := 0
	Local aAreaOld := GetArea()
	Local cMsgErro := "", cMsgEFat := ""

	Private cLocCont   := AllTrim(GetMv("MV_LOCCONT"))

	If !lIsCaixa
		HS_MSgInf(STR0032, STR0002, STR0031)//"Impossível executar essa rotina, pois o usuário não é Caixa"###"Atençao"
		RestArea(aAreaOld)
	Return(Nil)
	EndIf

	If GCY->GCY_TPALTA == "99"
		HS_MsgInf(STR0033+ " - " + GCY->GCY_REGATE + STR0034, STR0002, STR0035)//"Atendimento"###"-"###" está cancelado."###"Atenção"###"Controle de Caixa"
		RestArea(aAreaOld)
	Return(Nil)
	EndIf

	If !LockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
		HSPVerFiCo("ExecM24",GCY->GCY_REGATE,.T.)
	Return(Nil)
	Else
		HSPGerFiCo("ExecM24",GCY->GCY_REGATE)
	EndIf
	aGuias := HS_GuiasPr(GCY->GCY_REGATE, ".And. GCZ->GCZ_STATUS == '0'")
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Ponto de entrada para indicar se ira continuar o processo                ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("HSPVLDCX") .And. Len(aGuias) > 0
		lHspVldCX := ExecBlock( "HSPVLDCX",.F.,.F., {GCY->GCY_REGATE} )
		If !lHspVldCX
			UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
			HSPDelFiCo("ExecM24",Alltrim(GCY->GCY_REGATE))
			RestArea(aAreaOld)
		Return(Nil)
		EndIf
	EndIf


	If Len(aGuias) > 0
		For nGuias := 1 To Len(aGuias)

			DBSelectArea("GCZ")
			DbSetOrder(1)
			DBSeek(xFilial("GCZ") + aGuias[nGuias, 1])

			IncProc("Gerando [" + GCZ->GCZ_NRSEQG + "][" + StrZero(nGuias, 6) + "/" + StrZero(nGuias, 6) + "]")

			If !Empty(GCZ->GCZ_NUMORC)
				cMsgErro += STR0036 + " - " + GCZ->GCZ_NRSEQG + STR0037 + GCZ->GCZ_NUMORC + Chr(10)//"NRSEQG"###" - "###" já possui orçamento gerado. Orçamento No. "
			ElseIf GCZ->GCZ_CANCEL == "1"
				cMsgErro += STR0036 + " - " + GCZ->GCZ_NRSEQG + STR0038 + Chr(10) //"NRSEQG"###" - "###" está cancelada e não pode ser utilizada"
			ElseIf HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON") <> "1"
				cMsgErro += STR0036 + " - " + GCZ->GCZ_NRSEQG + STR0039 + GCZ->GCZ_CODPLA + Chr(10)//"NRSEQG"###" Este plano no é particular. Não será possível gerar um orçamento. Plano "
			Else
				Begin Transaction

					cMsgEFat := ""

     // Gera faturamento da guia
					If !Empty(cMsgEFat := Hs_Hp12Fat(GCZ->GCZ_NRSEQG))
						cMsgErro += cMsgEFat
					EndIf

     // Gera o orcamento no SL1, SL2 e SL4, caso não haja nenhuma inconsistencia geracao do faturamento da guia
					If Empty(cMsgEFat)
						If HS_IntLoja(GCZ->GCZ_NRSEQG, GCZ->GCZ_REGGER) .And. nOpc == 1
							AADD(aGuiasGer, {aGuias[nGuias, 1], aGuias[nGuias, 2]})
						EndIf

						If nOpc == 2 //finaliza venda
							DbSelectArea("SL1")
							DbSetOrder(1) //FILIAL + NUM
							DbSeek(xFilial("SL1") + GCZ->GCZ_NUMORC)

							DbSelectArea("GBH")
							DbSetOrder(1) //FILIAL + REGGER
							DbSeek(xFilial("GBH") + GCZ->GCZ_REGGER)

							DbSelectArea("SA1")
							DbSetOrder(1) //COD + LOJA
							DbSeek(xFilial("SA1") + GBH->GBH_CODCLI + GBH->GBH_LOJA)

							If Loja701(.T., 4, SA1->A1_COD, SA1->A1_LOJA)
								AADD(aGuiasGer, {aGuias[nGuias, 1], aGuias[nGuias, 2]})
							EndIf
						EndIf
					EndIf

				End Transaction
			EndIf

		Next

		If !Empty(cMsgErro)
			HS_MsgInf(cMsgErro, STR0002, STR0035)//### "Atenção"###"Controle de Caixa"
		ElseIf Len(aGuiasGer) > 0
			HS_MsgInf(STR0040 + IIF(nOpc == 2, STR0041, "")+ STR0042, STR0002, STR0035)//"Geração do Caixa "###"e Finalização da Venda"###" finalizada com sucesso"### "Atenção"###"Controle de Caixa"
			HSPAHRC6("HSPAHM24", aGuiasGer)

   //Se FINALIZA VENDA abre a tela para impressao sem validar Usuarios Bloq./Ficha
			If nOpc == 2
				GDN->(dbSetOrder(1))
				If GDN->(DbSeek(xFilial("GDN") + GCY->GCY_LOCATE))
					HSPAHP44(.T., GCY->GCY_LOCATE, {{"GBH", 1, GCY->GCY_REGGER}}, .F.)
				EndIf
			EndIf

		EndIf
	EndIf

	UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",Alltrim(GCY->GCY_REGATE))

	RestArea(aAreaOld)
Return(Nil)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_ExcCaix ³ Autor ³ Daniel Peixoto        ³ Data ³28.08.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Exclui orçamento e/ou fatura geradas pelo sigaloja            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³                                                              ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_ExcCaix()
	Local aGuias   := {}
	Local nGuias   := 0
	Local aAreaOld := GetArea(), aAreaGCZ := {}
	Local cMsgErro := "", lExcOK := .F.
	Local lExcDesp := IIf(GetMv("MV_EXCDFAT",,"S") == "N", .F., .T.)

	If !lIsCaixa
		HS_MSgInf(STR0032, STR0002, STR0031)
		RestArea(aAreaOld)
	Return(Nil)
	EndIf

	If GCY->GCY_TPALTA == "99"
		HS_MsgInf(STR0033 + " - " + GCY->GCY_REGATE + STR0034, STR0002, STR0035)//"Atendimento"###" - "###"está cancelado"### "Atenção"###"Controle de Caixa"
		RestArea(aAreaOld)
	Return(Nil)
	EndIf

	If !LockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
		HSPVerFiCo("ExecM24",GCY->GCY_REGATE,.T.)
	Return(Nil)
	Else
		HSPGerFiCo("ExecM24",GCY->GCY_REGATE)
	EndIf

	aGuias := HS_GuiasPr(GCY->GCY_REGATE, ".And. GCZ->GCZ_STATUS IN ('2', '4') ")
	If Len(aGuias) > 0
		For nGuias := 1 To Len(aGuias)

			DBSelectArea("GCZ")
			DbSetOrder(1)//FILIAL + NRSEQG
			DBSeek(xFilial("GCZ") + aGuias[nGuias, 1])

			IncProc(STR0043 + GCZ->GCZ_NRSEQG + "][" + StrZero(nGuias, 6) + "/" + StrZero(nGuias, 6) + "]")//"Excluindo ["###"] ["###"]"

			If Empty(GCZ->GCZ_NUMORC)
				cMsgErro += STR0036 + " - " + GCZ->GCZ_NRSEQG + STR0044 + Chr(10)//"NRSEQG"###" - "###" não possui orçamento gerado."
			ElseIf GCZ->GCZ_CANCEL == "1"
				cMsgErro += STR0036 + " - " + GCZ->GCZ_NRSEQG + STR0045 + Chr(10)//"NRSEQG"###" - "###" está cancelada e não pode ser utilizada"
			Else
				Begin Transaction

					aAreaGCZ := GetArea()
     //Exclui orçamento
					DbSelectArea("SL1")
					DbSetOrder(1)
					DbSeek(xFilial("SL1") + GCZ->GCZ_NUMORC)
					lExcOk := Lj140Exc("SL1", SL1->(RECNO()), 2)
					If ValType(lExcOk) == "U"
						lExcOK := .F.
					ElseIf ValType(lExcOk) == "N"
						lExcOK := IIF(lExcOk == 1, .T., .F.)
					Else //Logico
						lExcOK := lExcOk
					EndIf

					If !lExcOK
						cMsgErro += STR0036 + " - " + GCZ->GCZ_NRSEQG + STR0046 + Chr(10)//"NRSEQG"###" - "###" erro na exclusão da NF/Orc/Ped"
					EndIf

					If EMPTY(cMsgErro)

						RestArea(aAreaGCZ)

      // Exclui Fatura
						If !HS_ExcTitu(GCZ->GCZ_SERIE, GCZ->GCZ_NRFATU, GCZ->GCZ_CODCON)
							cMsgErro += STR0036 + " - " + GCZ->GCZ_NRSEQG + STR0059+ Chr(10) //"NRSEQG"###" - "###" erro na exclusão da NF/Orc/Ped"
						EndIf

						If EMPTY(cMsgErro)

       //Exclui Faturamento
							If lExcDesp
								HS_ExluiDes(GCZ->GCZ_NRSEQG)
							EndIf

							DbSelectArea("GB3")
							M->GB3_NRPROT := HS_VSxeNum("GB3", "M->GB3_NRPROT", 1)
							ConfirmSx8()

    		 //Atualiza dados da Guia
							DbSelectArea("GCZ")
							RecLock("GCZ",.F.)
							GCZ->GCZ_DTGERA := CToD(" ")
							GCZ->GCZ_HRGERA := Space(Len(GCZ->GCZ_HRGERA))
							GCZ->GCZ_USGERA := Space(Len(GCZ->GCZ_USGERA))
							GCZ->GCZ_DATSTA := dDataBase
							GCZ->GCZ_NRPROT := M->GB3_NRPROT
							GCZ->GCZ_DATFAT := CtoD("")
							GCZ->GCZ_HORFAT := Space(Len(GCZ->GCZ_HORFAT))
							GCZ->GCZ_NRFATU := Space(Len(GCZ->GCZ_NRFATU))
							GCZ->GCZ_NRNOTA := Space(Len(GCZ->GCZ_NRNOTA))
							GCZ->GCZ_SERIE  := Space(Len(GCZ->GCZ_SERIE))
							GCZ->GCZ_VLGUIA := 0
							GCZ->GCZ_LOGARQ := HS_LOGARQ()
							MsUnlock()

 	     //Cria Protocolo de Ctrl de Contas
							DbSelectArea("GB3")
							RecLock("GB3", .T.)
							GB3->GB3_FILIAL	:= xFilial("GB3")
							GB3->GB3_NRPROT	:= M->GB3_NRPROT
							GB3->GB3_DATPRO	:= dDataBase
							GB3->GB3_USEREN	:= cUserName
							GB3->GB3_TIPTRF := "1"
							GB3->GB3_LOGARQ	:= HS_LOGARQ()
							MsUnLock()

						EndIf

					EndIf

				End Transaction
			EndIf

		Next

		If !Empty(cMsgErro)
			HS_MsgInf(cMsgErro, STR0002,STR0047)//"Atenção"###"Exclusão da Fatura"
		Else
			HS_MsgInf(STR0048, STR0002,STR0047)//"Exclusão da Fatura finalizada com sucesso"###"Atenção"###"Exclusão da Fatura"
		EndIf

	EndIf

	UnLockByName("ExecM24" + GCY->GCY_REGATE,.T.,.T.,.F.)
	HSPDelFiCo("ExecM24",Alltrim(GCY->GCY_REGATE))

	RestArea(aAreaOld)
Return(Nil)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ HS_VldSx6  ³ Autor ³ Bruno Santos          ³ Data ³17.10.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Valida parametros da SX6                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Parametro Ok                                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpA1: Array contendo parametros a serem validados            ³±±
	±±³	         ³       1 - Array com parametros e validacoes                  ³±±
	±±³	         ³           1 - Nome do Parametro                              ³±±
	±±³	         ³           ***A segunda posicao do vetor pode assumir         ³±±
	±±³	         ³           ***duas estruturas:                                ³±±
	±±³	         ³              2 - Vetor com os valores esperados              ³±±
	±±³	         ³                  1 - Tipo Esperado                           ³±±
	±±³	         ³                  2 - Valores Esperados (Ex "0123" ou "S/N")  ³±±
	±±³	         ³                  3 - Operador "<", "==", "$"                 ³±±
	±±³	         ³                  4 - Validacao por funcao                    ³±±
	±±³	         ³           ***Ou                                              ³±±
	±±³	         ³              2 - Vetor com a relacionamento para consistencia³±±
	±±³	         ³                  do parâmetro                                ³±±
	±±³	         ³                  1 - Tabela de relacao                       ³±±
	±±³	         ³                  2 - Campo para comparacao                   ³±±
	±±³	         ³                  3 - Condicao para busca                     ³±±
	±±³	         ³           3 - Separador Ex: GD5/GD6/GD7 Separador = "/"      ³±±
	±±³	         ³           4 - Tamanho para separacao                         ³±±
	±±³	         ³       2 - Exibe Mensagem de Inconsistencia                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function HS_VldSx6(aParams, lExbMsg)
	Local aArea		 := GetArea()
	Local cMsgErro := ""
	Local lRet := .F.
	Local i := 0
	Local cParam  := ""
	Local cContPar := ""
	Local aVet := {}
	Local nPos := 0, nIniPos := 1, nTamSep := 0
	Local cChrSep := "/"
	Local lVldVal := .T.
	Default lExbMsg := .F.

	If Len(aParams) == 0
	Return(lRet)
	EndIf

	For i := 1 To Len(aParams)

		cParam  := aParams[i][1] //Nome do Parametro
		aVet    := IIF(Len(aParams[i]) > 1 .And. ValType(aParams[i][2]) == "A", aParams[i][2], nil)
		cChrSep := IIF(Len(aParams[i]) > 2 .And. ValType(aParams[i][3]) == "C", aParams[i][3], nil)
		nTamSep := IIF(Len(aParams[i]) > 3 .And. ValType(aParams[i][4]) == "N", aParams[i][4], 0)

		If Empty(cParam)
			HS_MsgInf(STR0050,STR0002,STR0049)//"Obrigatório informar o nome do parâmetro a ser validado"###"Atenção"###"Validação Parâmetro SX6"
		Return(lRet)
		EndIf

		DbSelectArea("SX6")
		DbSetOrder(1)

  		// Verifica se o parametro existe no SX6
		If !SX6->(DbSeek(  IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL) + PadR(cParam, Len(X6_VAR)) ))	// procurar exclusivo
			If !SX6->(DbSeek(space(FWSizeFilial()) + PadR(cParam, Len(X6_VAR))       )) // procurar compartilhado
				cMsgErro += STR0051 + cParam + STR0052 + chr(13) + chr(10)//"O parâmetro"###" não foi encontrado."
				Loop
			//Else
				//cContPar := SuperGetMv(cParam)
			EndIf
		EndIf

		If (aVet == nil)
			Loop
		EndIf

		lVldVal := ValType(aVet[1]) == "C" .And. Len(aVet[1]) == 1 //Verifica o tipo de consistência a ser feito, por valor ou relacional

		If IIF(lVldVal,aVet[1] # ValType(SuperGetMv(cParam)),HS_CfgSx3(aVet[2])[SX3->(FieldPos("X3_TIPO"))] # ValType(SuperGetMv(cParam)))
			cMsgErro += STR0051 + cParam + STR0053 + IIF(lVldVal,aVet[1],HS_CfgSx3(aVet[2])[SX3->(FieldPos("X3_TIPO"))]) + "."  + chr(13) + chr(10)	 //O parâmetro"###" está com o tipo incorreto. ele deve ser do tipo "
			Loop
		EndIf

		nIniPos := 1
		lErro   := .F.
		If (cChrSep # nil) .And. ((nPos := aT(cChrSep,X6Conteud())) > 0)
			While(nPos > 0)
			nPos := aT(cChrSep,SubStr(X6Conteud(),nIniPos, len(X6Conteud())))
			If lErro := !Fs_VldCont(lVldVal, aVet, nIniPos, nPos-1, @cMsgErro, cParam, X6Conteud())
				Exit
			EndIf
			nIniPos += nPos
		End
	ElseIf nTamSep > 0
		For nIniPos := 0 To Len(Trim(X6Conteud())) Step nTamSep+1
			If lErro := !Fs_VldCont(lVldVal, aVet, nIniPos, nTamSep, @cMsgErro, cParam, X6Conteud())
				Exit
			EndIf
		Next nIniPos
	Else
		lErro := !Fs_VldCont(lVldVal, aVet, 1, Len(Trim(X6Conteud())), @cMsgErro, cParam, X6Conteud())
	EndIf

	If lErro
		Loop
	EndIf
Next i

If !(lRet := Empty(cMsgErro)) .And. lExbMsg
	HS_MsgInf(cMsgErro, STR0002, STR0054)//"Atenção"###"Parâmetros (SX6) inconsistentes"
EndIf
RestArea(aArea)
Return(lRet)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ Fs_VldCont ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Valida conteudo de um parametro                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpL1: Valida valor do parametro                              ³±±
	±±³          ³ExpA2: Array com os dados para validacao                      ³±±
	±±³          ³ExpN3: Posicao inicial para a validacao do conteudo do        ³±±
	±±³          ³       parametro                                              ³±±
	±±³          ³ExpN4: Quantidade de caracteres a ser validada                ³±±
	±±³          ³ExpC5: Mensagem de erro, parametro de ser passado por         ³±±
	±±³          ³       referencia                                             ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function Fs_VldCont(lVldVal, aVet, nIniPos, nPos, cMsgErro, cParam, cContPar)
	Local lRet  := .T.
	Local aArea := getArea()

	If lVldVal
		If !(Iif(Len(aVet) > 3,&(aVet[4]),&(" '"+SubStr(Trim(cContPar),nIniPos, nPos) + "' " + Iif(Len(aVet) < 3," $ ", aVet[3]) + "  '" + aVet[2]+"'")))
			cMsgErro += STR0051 + cParam + STR0055  + chr(13) + chr(10)	 //"O parâmetro "###" está com o conteúdo incorreto."
			lRet := .F.
		Endif
	Else
		If HS_CountTB(aVet[1], aVet[2] + " = '" + SubStr(Trim(cContPar),nIniPos, nPos) + "' And "+Iif(Len(aVet) < 3," 1 = 1 ", aVet[3]) )  == 0
			SX2->( dbSetOrder( 1 ) )
			SX2->( dbSeek( aVet[1] ) )
			cMsgErro += STR0056 + cParam + STR0057 + Capital( X2Nome() ) + STR0058 + chr(13) + chr(10)//"O conteúdo do parametro "###" não foi encontrado na tabela de "###", preencha com um conteudo existente."
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)
Return(lRet)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ FS_RetHI   ³ Autor ³ Paulo César           ³ Data ³28.01.2008 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Função para retornar as guias para impressao dos honorário     ³±±
	±±³          ³individuais                                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpA1: Array contendo se Tudo Ok e array com guias selecionadas³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpA1: Array com os dados da guia                              ³±±
	±±³          ³ExpN2: Posicao do campo Sequencial da guia no array de guias   ³±±
	±±³          ³ExpN3: Posicao do campo de marcacao(LBTIK) no array de guias   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function FS_RetHI(aVetGuia, nPosNrSeqG, nPosHonInd)

	Local aArea   := GetArea()
	Local aSize   := {}, aObjects := {}, aInfo := {}, aPObjs := {}
	Local cGuias  := "", cSql := "", aGuiasIn := {}
	Local cG17MODIMP := "", cRetGuia := ""
	Local aHGD   := {}, aCGD := {}, aButtons := {}
	Local nUGD   := 0
	Local lOK     := .T., lMarca := .T.
	Local nTdOk   := 0
	Local nForGE7 := 0
	Local aCores			:= {{"GCZ->GE7_STATUS == ''",	"BR_BRANCO"  },;
		{"GCZ->GE7_STATUS <> ''",	"BR_VERDE"	  }}

	Local nContFor := 0
	Local aDesp    := {"GD7","GE7"}


	For nContFor := 1 to Len(aVetGuia)
		If aVetGuia[nContFor][nPosHonInd]
			cGuias += IIF(Empty(cGuias), "", ", ") + "'" + aVetGuia[nContFor][nPosNrSeqG] + "'"
		EndIf
	Next

	If Empty(cGuias)
	Return({.F., aGuiasIn})
	EndIf
	Define  FONT oFont NAME "Arial,16," BOLD

	For nContFor := 1 to Len(aDesp)

		cSql += "SELECT "+aDesp[nContFor]+"_REGATE REGATE, "+aDesp[nContFor]+"_NRSEQG NRSEQG, "
		cSql += "       SRA.RA_CODIGO CRM, SRA.RA_NOME NOME "
		cSql += "FROM " + RetSqlName(aDesp[nContFor]) + " "+aDesp[nContFor]+" "
		cSql += "JOIN " + RetSqlName("SRA") + " SRA "
		cSql += "ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
		cSql += "AND SRA.RA_CODIGO = "+aDesp[nContFor]+"_CODCRM "
		cSql += "AND SRA.D_E_L_E_T_ <> '*' "
		cSql += "JOIN " + RetSqlName("GA7") + " GA7 "
		cSql += "ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' "
		cSQL += "AND GA7.GA7_CODPRO = " + aDesp[nContFor] + "_CODDES "
		cSQL += "AND GA7.GA7_TIPPRO IN ('1','9') AND GA7.GA7_HONORA = '1'"
		cSql += "AND GA7.D_E_L_E_T_ <> '*' "
		cSql += "WHERE "+aDesp[nContFor]+"_FILIAL = '" + xFilial("GE7") + "' AND "+aDesp[nContFor]+"_NRSEQG IN (" + cGuias + ") "
		cSql += "AND "+aDesp[nContFor]+"_PGTMED = '0' "
		cSql += "AND "+aDesp[nContFor]+".D_E_L_E_T_ <> '*' "

		If nContFor # Len(aDesp)
			cSql += "UNION "
		EndIf
	Next

	cSql := ChangeQuery(cSql)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), "TMPQRY",.T.,.T.)

	DBSelectArea("TMPQRY")
	DbGoTop()

	Aadd(aHGD, {" "         , "cRetGuia", "@BMP"  , 2, 0, ".F.", ""    , "C", "", "V" , "" , "","","V"})
	nGuias  := ++nUGD

	Aadd(aHGD, {"Nro Guia"     , "cNRSEQG", "@!", Len(TMPQRY->NRSEQG), 0, ".F.", ""    , "C", "", "V" ,"" , "", "", "V"})
	nNrSeqG := ++nUGD

	Aadd(aHGD, {"CRM"          , "cCRM"   , "@!", Len(TMPQRY->CRM)   , 0, ".F.", ""    , "C", "", "V" ,"" , "", "", "V"})
	nCrm    := ++nUGD

	Aadd(aHGD, {"Nome"         , "cNOME"  , "@!", Len(TMPQRY->NOME)  , 0, ".F.", ""    , "C", "", "V" ,"" , "", "", "V"})
	nNome   := ++nUGD

	Aadd(aHGD, {"Atendimento" , "cREGATE" , "@!", Len(TMPQRY->REGATE), 0,".F.",""    , "C", "", "V" ,"" , "","","V"})
	nRegAte := ++nUGD


	While !Eof()
		aAdd(aCGD, {"LBNO", TMPQRY->NRSEQG, TMPQRY->CRM, TMPQRY->NOME, TMPQRY->REGATE, .F.})
		DbSkip()
	End

	If Len(aCGD) == 1
		aAdd(aGuiasIn, {aCGD[1, nNrSeqG], aCGD[1, nCrm]})
	ElseIf Len(aCGD) > 1
		aSize := MsAdvSize(.T.)
		aObjects := {}
		AAdd(aObjects, {100, 80, .T., .T.})

		aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
		aPObjs := MsObjSize(aInfo, aObjects, .T.)

		aAdd(aButtons, {"CHECKED", {|| FS_MarcT(lMarca, oGDDesp, {nGuias}), lMarca := !lMarca}, STR0018, STR0019}) //"Todos"###"Marcar Todos"

		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0020) From aSize[5]/5, aSize[6]/100 To aSize[6], aSize[5]*0.65	PIXEL Of oMainWnd //"Guias TISS"

		@aPObjs[1][1] + 06, aPObjs[1][2] + 12 Say STR0020 + " - " + GCY->GCY_REGGER + " - "  + AllTrim(HS_IniPadr("GBH", 1, GCY->GCY_REGGER, "GBH_NOME")) Of oDlg Pixel COLOR CLR_RED FONT oFont //"Guias TISS"

		oGDDesp := MsNewGetDados():New(aPObjs[1][1], aPObjs[1][2], aPObjs[1][3], aPObjs[1][4], 0,,,,,,,,,, oDlg, aHGD, aCGD)
		oGDDesp:oBrowse:BlDblClick := {|| FS_DbClik(oGDDesp)}
		oGDDesp:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nTdOk := 1, IIF(!FS_VldHonor(oGDDesp, nGuias), nTdOk := 0, oDlg:End())}, {|| nTdOk := 0, oDlg:End()},, aButtons)

		If nTdOk == 1
			For nForGE7 := 1 To Len(oGDDesp:aCols)
				If oGDDesp:aCols[nForGE7, nGuias] == "LBTIK"
					aAdd(aGuiasIn, {aCGD[nForGE7, nNrSeqG], aCGD[nForGE7, nCrm]})
				EndIf
			Next
		Else
			lOk := .F.
		EndIf
	Else
		lOk := .F.
	EndIf

	DbSelectArea("TMPQRY")
	DbCLoseArea()
	RestArea(aArea)

Return({lOk, aGuiasIn})

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ FS_VldHonor³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Funcao para validar Ok na tela de impressao das guias TISS de ³±±
	±±³          ³Honorario Individual                                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Conteudo do campo válido                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpO1: MsNewGetDados a ser validada                           ³±±
	±±³          ³ExpN2: Posicao do campo de marcacao(LBTIK) na MsNewGetDados   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Static Function FS_VldHonor(oObj, nPos)

	Local lRet := .T.

	If !(lRet := (aScan(oObj:aCols, {| aVet | aVet[nPos] == "LBTIK"}) > 0))
		HS_MsgInf(STR0021, STR0002, STR0014) //"Não há guias selecionadas."###"Atenção"###"Validação da guia TISS"
	EndIf

Return(lRet)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ Hs_ImpGCon ³ Autor ³ Bruno Santos          ³ Data ³16.04.2008³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Impressao da guia de Consultas do TISS.                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Sequencial da guia                                     ³±±
	±±³          ³ExpC2: Alias da tabela de despesas com procedimento      (OPC)³±±
	±±³          ³ExpC3: Registro de Atendimento                           (OPC)³±±
	±±³          ³ExpC4: Numero do Protuario                               (OPC)³±±
	±±³          ³ExpC5: Codigo do Plano                                   (OPC)³±±
	±±³          ³ExpA6: Array com as despesas com procedimento            (OPC)³±±
	±±³          ³ExpA6: Array com os dados da empresa(SM0)                (OPC)³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function Hs_ImpGCon(cNrSeqG, cAliasG7, cRegAte, cPaciente, cCodPla, aCPR, aSM0Dados) //Guia Consulta

	Local aCposPR   := {}
	Local aHPR      := {}
	Local aVetPR    := {}
	Local nUPR := 0

	Local aGuiaCon  := {}
	Local nForLin   := 0
	Local cAliasTab := ""
	Local cCBO      := ""

	Default aCPR      := {}
	Default aSM0Dados := {}
	Default cAliasG7  := ""
	Default cRegAte   := ""
	Default cPaciente := ""
	Default cCodPla   := ""

	IIF(Alias()         # "GCZ"  , DbSelectArea("GCZ"), Nil)
	IIF(IndexOrd()      # 1      , DbSetOrder(1), Nil) // GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
	IIF(GCZ->GCZ_NRSEQG # cNrSeqG, DbSeek(xFilial("GCZ") + cNrSeqG), Nil)

	cAliasG7  := IIF(!Empty(cAliasG7) ,cAliasG7 , IIF(GCZ->GCZ_STATUS < "2", "GD7", "GE7"))
	cRegAte   := IIF(!Empty(cRegAte)  ,cRegAte  , GCZ->GCZ_REGATE)
	cPaciente := IIF(!Empty(cPaciente),cPaciente, GCZ->GCZ_REGGER)
	cCodPla   := IIF(!Empty(cCodPla)  ,cCodPla  , GCZ->GCZ_CODPLA)

	aCposPR := {cAliasG7 + "_CODPRT", cAliasG7 + "_TABELA", cAliasG7 + "_PGTMED", cAliasG7 + "_GLODES", cAliasG7 + "_VALDES"}

	If GetNewPar("MV_TISSVER", "2.02.03") >= "3"
		aCposPR[1] := cAliasG7 + "_CODDES"
	EndIf

	IIF(Alias()         # "GCY"  , DbSelectArea("GCY"), Nil)
	IIF(IndexOrd()      # 1      , DbSetOrder(1), Nil)// GCY_FILIAL+GCY_REGATE
	IIf(GCY->GCY_REGATE # cRegAte, DbSeek(xFilial("GCY") + cRegAte), Nil)

	If Empty(aSM0Dados)
		nRECNOSM0 := SM0->(RecNo())
		If !Empty(GCZ->GCZ_FILFAT)
			DbSelectArea("SM0")
			DbSetOrder(1)  // M0_CODIGO + M0_CODFIL
			DbSeek(IIF(FindFunction("FWGRPCompany"), FWGRPCompany(),SM0->M0_CODIGO) + GCZ->GCZ_FILFAT)
		EndIf
		aAdd(aSM0Dados, {SM0->M0_CGC, SM0->M0_NOMECOM, SM0->M0_ENDENT, SM0->M0_COMPENT, SM0->M0_CIDENT, SM0->M0_ESTENT, SM0->M0_CEPENT, GETMV("MV_HSPCNES") })
		SM0->(DbGoTo(nRECNOSM0))
	EndIf

	IIF(Alias()         # "GD4", DbSelectArea("GD4"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GD4_FILIAL + GD4_REGGER + GD4_CODPLA
	DbSeek(xFilial("GD4") + cPaciente + cCodPla)

	IIF(Alias()         # "GCM", DbSelectArea("GCM"), Nil)
	IIF(IndexOrd()      # 2, DbSetOrder(2), Nil) // GCM_FILIAL + GCM_CODPLA
	IIF(GCM->GCM_CODPLA # cCodPla, DbSeek(xFilial("GCM") + cCodPla), Nil)

	IIF(Alias()         # "GA9", DbSelectArea("GA9"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GA9_FILIAL+GA9_CODCON
	IIF(GA9->GA9_CODCON # GCM->GCM_CODCON, DbSeek(xFilial("GA9") + GCM->GCM_CODCON), Nil)
	cLogoGH := GA9->GA9_LOGOTP

	IIF(Alias()         # "GBH", DbSelectArea("GBH"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GBH_FILIAL + GBH_CODPAC
	IIF(GBH->GBH_CODPAC # cPaciente, DbSeek(xFilial("GBH") + cPaciente), Nil)

	IIF(Alias()         # "GAM", DbSelectArea("GAM"), Nil)
	IIF(IndexOrd()      # 3, DbSetOrder(3), Nil) // GAM_FILIAL + GAM_CEP
	IIF(GAM->GAM_CEP    # SM0->M0_CEPCOB, DbSeek(xFilial("GAM") + SM0->M0_CEPCOB), Nil)

	IIF(Alias()         # "SRA", DbSelectArea("SRA"), Nil)
	IIF(IndexOrd()      # 11, DbSetOrder(11), Nil) // RA_FILIAL + RA_CODIGO
	IIF(SRA->RA_CODIGO  # GCY->GCY_CODCRM, DbSeek(xFilial("SRA") + GCY->GCY_CODCRM), Nil)

	IIF(Alias()         # "GBJ", DbSelectArea("GBJ"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)  //GBJ_FILIAL + GBJ_CRM
	IIF(GBJ->GBJ_CRM    # GCY->GCY_CODCRM, DbSeek(xFilial("GBJ") + GCY->GCY_CODCRM), Nil)

	IIF(Alias()         # "GF4", DbSelectArea("GF4"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)   // GF4_FILIAL + GF4_TPALTA
	IIF(GF4->GF4_TPALTA # GCY->GCY_TPALTA, DbSeek(xFilial("GF4") + GCY->GCY_TPALTA), Nil)

	If Empty(aCPR)
		HS_BDados(cAliasG7, @aHPR, @aCPR, @nUPR, 2,, cAliasG7 + "->" + cAliasG7 + "_NRSEQG == '" + cNrSeqG + "' ",,, "/",,,,,, .T.,,,,,, aCposPR)
	EndIf

	//Procedimentos
	For nForLin := 1 To Len(aCPR)
		If !Empty(aCPR[nForLin, 1]) .And. aCPR[nForLin, 3] <> "0" .And. aCPR[nForLin, 4] == "0" //o repasse medico nao pode ser direto e o campo que deermina glosa nao pode ser Excecao
			If (GetNewPar("MV_TISSVER", "2.02.03") < "3")
				DbSelectArea("GDB")
				DbSetOrder(1) //GDB_FILIAL + GDB_CHAVE

				If !Empty(aCPR[nForLin, 2]) .And. DbSeek(xFilial("GDB") + aCPR[nForLin, 2])
					aAdd(aVetPR, {aCPR[nForLin, 1], IIF(!Empty(GDB->GDB_TBTISS), GDB->GDB_TBTISS, "00"), aCPR[nForLin, 5], aCPR[nForLin, 2]})
					cAliasTab := "GDB"
				Else
					aAdd(aVetPR, {aCPR[nForLin, 1], IIF(!Empty(GA9->GA9_TBTISS), GA9->GA9_TBTISS, "00"), aCPR[nForLin, 5], aCPR[nForLin, 2]}) // caso a despesa tenha a valor proveniente de valores diferenciados do convenio, buscar no convenio a tabela TISS
					cAliasTab := "GA9"
				EndIf
			Else
				aAdd(aVetPR, {aCPR[nForLin, 1],aCPR[nForLin, 2], aCPR[nForLin, 5], aCPR[nForLin, 2]})
			EndIf
		EndIf
	Next

	If Len(aVetPR) == 0
		aAdd(aVetPR, {"", "", ""})
	EndIf

	If GetNewPar("MV_TISSVER", "2.02.03") < "3"
		aGuiaCon := {  {GA9->GA9_CODOPE         ,;  //1
		GCZ->GCZ_NRGUIA         ,;  //2
		GCZ->GCZ_DTGUIA         ,;  //3
		GD4->GD4_MATRIC         ,;  //4
		GCM->GCM_DESPLA         ,;  //5
		GD4->GD4_DTVALI         ,;  //6
		GBH->GBH_NOME           ,;  //7
		GBH->GBH_NUMCNS         ,;  //8
		HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2],;  //9
		aSM0Dados[1, 2]         ,;  //10
		aSM0Dados[1, 8]         ,;  //11 GETMV("MV_HSPCNES")
		GAM->GAM_TIPLOG         ,;  //12
		aSM0Dados[1, 3] + " " + aSM0Dados[1, 4],;  //13
		aSM0Dados[1, 3] + " " + aSM0Dados[1, 4],;  //14
		aSM0Dados[1, 3] + " " + aSM0Dados[1, 4],;  //15
		aSM0Dados[1, 5]    		,;  //16
		aSM0Dados[1, 6]    		,;  //17
		GAM->GAM_CODIGO    		,;  //18
		aSM0Dados[1, 7]    		,;  //19
		SRA->RA_NOME      		,;  //20
		GBJ->GBJ_CONSEL    		,;  //21
		SRA->RA_CODIGO     		,;  //22
		GBJ->GBJ_UFCONS    		,;  //23
		HS_RetCBO(GCZ->GCZ_CODCRM, GCY->GCY_CODCRM, GCZ->GCZ_CODDES),; //24
		""                 		,;  //25
		{GCZ->GCZ_TEDVLR, GCZ->GCZ_TEDUND}            ,;  //26
		GCZ->GCZ_IATISS 		,;  //27
		HS_RetCID(GCY->GCY_REGATE, GCZ->GCZ_CODCON, "GA9_ICIDCO", "1"),; //28
		HS_RetCID(GCY->GCY_REGATE, GCZ->GCZ_CODCON, "GA9_ICIDCO", "2"),; //29
		HS_RetCID(GCY->GCY_REGATE, GCZ->GCZ_CODCON, "GA9_ICIDCO", "3"),; //30
		""                 		,;  //31
		GCY->GCY_DATATE    		,;  //32
		aVetPR[1, 2]       		,;  //33
		aVetPR[1, 1]       		,;  //34
		GCZ->GCZ_TIPCON 		,;  //35
		SubStr(GF4->GF4_TSTISS, 2, 1),;  //36
		GCZ->GCZ_OBSTIS         ,;  //37
		CTOD("      ")        ,;  //38
		CTOD("      ")		}} 	//39

		PLSTISS1(aGuiaCon, lVsTISS, nLayout, cLogoGH)
	Else

		cCBO = HS_RetCBO(GCZ->GCZ_CODCRM, GCY->GCY_CODCRM, GCZ->GCZ_CODDES)

		aGuiaCon := {  {GA9->GA9_CODOPE         ,; //1
						GCZ->GCZ_NRGUIA         ,; //2
						GCZ->GCZ_GUIAOP 		,; //3
						GD4->GD4_MATRIC         ,; //4
						GD4->GD4_DTVALI         ,; //5
						GCY->GCY_ATERN			,; //6
						GBH->GBH_NOME           ,; //7
						GBH->GBH_NUMCNS         ,; //8
						HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2],;  //9
						aSM0Dados[1, 2]         ,; //10
						aSM0Dados[1, 8]         ,; //11
						SRA->RA_NOME			,; //12
						IIF(Empty(ALLTRIM(GBJ->GBJ_CONSEL)), "", PLSGETVINC("BTU_CDTERM", "BAH", .F., "26", ALLTRIM(GBJ->GBJ_CONSEL))),; //13
						SRA->RA_CODIGO     		,; //14
						IIF(Empty(ALLTRIM(GBJ->GBJ_UFCONS)), "", PLSGETVINC("BTU_CDTERM", "SX5", .F., "59", "12"+ALLTRIM(GBJ->GBJ_UFCONS))),; //15
						IIF(Empty(ALLTRIM(cCBO)),            "", PLSGETVINC("BTU_CDTERM", "GN1", .F., "24", ALLTRIM(cCBO)))           ,; //16
						IIF(Empty(ALLTRIM(GCZ->GCZ_IATISS)), "", PLSGETVINC("BTU_CDTERM", "   ", .F., "36", ALLTRIM(GCZ->GCZ_IATISS))),; //17
						GCY->GCY_DATATE    		,; //18
						IIF(Empty(ALLTRIM(GCZ->GCZ_TIPCON)), "", PLSGETVINC("BTU_CDTERM", "G12", .F., "52", ALLTRIM(GCZ->GCZ_TIPCON))),; //19
						IIF(Empty(ALLTRIM(aVetPR[1, 2])),    "", PLSGETVINC("BTU_CDTERM", "GDB", .F., "87", aVetPR[1, 2]))              ,; //20
						IIF(Empty(AllTrim(aVetPR[1, 1])),    "", PLSGETVINC("BTU_CDTERM", "GA7", .F., "22", ALLTRIM(aVetPR[1, 1])))   ,; //21
						aVetPR[1, 3]			,; //22
						GCZ->GCZ_OBSTIS         }} //37

		PLSTISSD(aGuiaCon, lVsTISS, nLayout, cLogoGH)
	EndIf
Return(.T.)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ Hs_ImpSadt ³ Autor ³ Bruno Santos          ³ Data ³16.04.2008³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Impressao da guia de SADT do TISS.                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Sequencial da guia                                (OPC)³±±
	±±³          ³ExpC2: Registro de Atendimento                                ³±±
	±±³          ³ExpD3: Data da Solicitacao                               (OPC)³±±
	±±³          ³ExpC4: Hora da Solicitacao                               (OPC)³±±
	±±³          ³ExpC5: Numero do Prontuario                              (OPC)³±±
	±±³          ³ExpC6: Codigo do plano                                   (OPC)³±±
	±±³          ³ExpC7: Medigo da guia(Solicitante)                       (OPC)³±±
	±±³          ³ExpC8: Codigo do servico principal                       (OPC)³±±
	±±³          ³ExpC9: Alias da tabela de despesa de Mat/Med             (OPC)³±±
	±±³          ³ExpCA: Alias da tabela de despesa de Tax/Dia             (OPC)³±±
	±±³          ³ExpCB: Alias da tabela de despesa de Procedimentos       (OPC)³±±
	±±³          ³ExpCC: Array com as despesas com Procedimento            (OPC)³±±
	±±³          ³ExpCD: Array com as despesas com Mat/Med                 (OPC)³±±
	±±³          ³ExpCE: Array com as despesas com Tax/Dia                 (OPC)³±±
	±±³          ³ExpCF: Array com os dados da Empresas(SM0)               (OPC)³±±
	±±³          ³ExpCG: Nome da rotina que executou a funcao              (OPC)³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function Hs_ImpSadt(cNrSeqG, cRegAte, dDataSol,cHorSol, cPaciente, cCodPla, cMedGuia, cCodDes , cAliasG5, cAliasG6, cAliasG7, aCPR, aCMM, aCTD, aSM0Dados, cOrigem)

	Local aCoeDes58 := {}
	Local aValUni61 := {}
	Local aValQtd62 := {}
	Local aValUni83 := {}
	Local aValQtd84 := {}
	Local aSADTDes  := {}
	Local aVCodCp   := {}
	Local nValQtd   := 0
	Local aTot65    := {}
	Local aTot71    := {}
	Local aTot66    := {}
	Local aTot67    := {}
	Local aTot68    := {}
	Local aTot69    := {}
	Local aTot70    := {}
	Local aTot85    := {}
	Local nAtoMed   := 99
	Local aAtoMed   := {}
	Local nForLin, nForCol,nVetCp
	Local cCdOper 	:= ""
	Local nPosCpt	:= 0
	Local cObs := ""
	Local nX := 0
	Local AVetPr := {}, AVetMMTD := {}
	Local aHMM := {}, nUMM := 0
	Local aHTD := {}, nUTD := 0
	Local aHPR := {}, nUPR := 0
	Local cTissVer := GetNewPar("MV_TISSVER", "2.02.03")
	Local cCboTiss := ""

	Default cNrSeqG   := ""
	Default dDataSol  := CTOD("  /  /  ")
	Default cHorSol   := ""
	Default cPaciente := ""
	Default cCodPla   := ""
	Default cMedGuia  := ""
	Default cCodDes   := ""
	Default cAliasG5  := {}
	Default cAliasG6  := {}
	Default cAliasG7  := {}
	Default aCPR      := {}
	Default aCMM      := {}
	Default aCTD      := {}
	Default aSM0Dados := {}
	Default cOrigem:= ""


	If !Empty(cNrSeqG)
		IIF(Alias()         # "GCZ"  , DbSelectArea("GCZ"), Nil)
		IIF(IndexOrd()      # 1      , DbSetOrder(1), Nil) // GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
		IIF(GCZ->GCZ_NRSEQG # cNrSeqG, DbSeek(xFilial("GCZ") + cNrSeqG), Nil)

		cAliasG5  := IIF(!Empty(cAliasG5) ,cAliasG5 , IIF(GCZ->GCZ_STATUS < "2", "GD5", "GE5"))
		cAliasG6  := IIF(!Empty(cAliasG6) ,cAliasG6 , IIF(GCZ->GCZ_STATUS < "2", "GD6", "GE6"))
		cAliasG7  := IIF(!Empty(cAliasG7) ,cAliasG7 , IIF(GCZ->GCZ_STATUS < "2", "GD7", "GE7"))

		aCposMM := {cAliasG5 + "_TABELA", cAliasG5 + "_CODPRO", cAliasG5 + "_DESPRO", cAliasG5 + "_QTDDES", cAliasG5 + "_VALDES", ;
			cAliasG5 + "_SEQDES", cAliasG5 + "_CODDES", cAliasG5 + "_GLODES"}

		aCposTD := {cAliasG6 + "_TABELA", cAliasG6 + "_CODTXC", cAliasG6 + "_DESTXC", cAliasG6 + "_QTDDES", cAliasG6 + "_VALDES", ;
			cAliasG6 + "_SEQDES", cAliasG6 + "_CODDES", cAliasG6 + "_GLODES"}

		aCposPR := {cAliasG7 + "_CODCRM", cAliasG7 + "_CODATO", cAliasG7 + "_DATDES", cAliasG7 + "_HORDES", cAliasG7 + "_TABELA", ;
			cAliasG7 + "_CODPRT", cAliasG7 + "_DESPRT", cAliasG7 + "_QTDDES", cAliasG7 + "_COEDES", cAliasG7 + "_VALDES", ;
			cAliasG7 + "_COEFAM", cAliasG7 + "_SEQDES", cAliasG7 + "_CODDES", cAliasG7 + "_PGTMED", cAliasG7 + "_GLODES", ;
			cAliasG7 + "_TECUTI", cAliasG7 + "_NOMMED", cAliasG7 + "_CODVIA"}

		cRegAte   := IIF(!Empty(cRegAte)  ,cRegAte  , GCZ->GCZ_REGATE)
		cPaciente := IIF(!Empty(cPaciente),cPaciente, GCZ->GCZ_REGGER)
		cCodPla   := IIF(!Empty(cCodPla)  ,cCodPla  , GCZ->GCZ_CODPLA)
		dDataSol  := IIF(!Empty(dDataSol) ,dDataSol , GCZ->GCZ_DATSOL)
		cHorSol   := GCZ->GCZ_HORSOL
		cMedGuia  := IIf(cOrigem == "M08" .AND. !Empty(cMedGuia),cMedGuia, GCZ->GCZ_CODCRM)
		cCodDes   := GCZ->GCZ_CODDES

		If Empty(aCMM)
			HS_BDados(cAliasG5, @aHMM, @aCMM, @nUMM, 2,, cAliasG5 + "->" + cAliasG5 + "_NRSEQG == '" + cNrSeqG + "'",,, "/",,,,,, .T.,,,,,, aCposMM)
		EndIf
		If Empty(aCTD)
			HS_BDados(cAliasG6, @aHTD, @aCTD, @nUTD, 2,, cAliasG6 + "->" + cAliasG6 + "_NRSEQG == '" + cNrSeqG + "'",,, "/",,,,,, .T.,,,,,, aCposTD)
		EndIf
		If Empty(aCPR)
			HS_BDados(cAliasG7, @aHPR, @aCPR, @nUPR, 2,, cAliasG7 + "->" + cAliasG7 + "_NRSEQG == '" + cNrSeqG + "' ",,, "/",,,,,, .T.,,,,,, aCposPR)
			nPosCRMGD7 := aScan(aHPR, {|aVet| AllTrim(aVet[2]) == cAliasG7 + "_CODCRM"})
		EndIf
	EndIf

	IIF(Alias()         # "GCY"  , DbSelectArea("GCY"), Nil)
	IIF(IndexOrd()      # 1      , DbSetOrder(1), Nil)// GCY_FILIAL+GCY_REGATE
	IIf(GCY->GCY_REGATE # cRegAte, DbSeek(xFilial("GCY") + cRegAte), Nil)

	If Empty(aSM0Dados)
		nRECNOSM0 := SM0->(RecNo())
		If !Empty(GCZ->GCZ_FILFAT)
			DbSelectArea("SM0")
			DbSetOrder(1)  // M0_CODIGO + M0_CODFIL
			DbSeek(IIF(FindFunction("FWGRPCompany"), FWGRPCompany(),SM0->M0_CODIGO) + GCZ->GCZ_FILFAT)
		EndIf
		aAdd(aSM0Dados, {SM0->M0_CGC, SM0->M0_NOMECOM, SM0->M0_ENDENT, SM0->M0_COMPENT, SM0->M0_CIDENT, SM0->M0_ESTENT, SM0->M0_CEPENT, GETMV("MV_HSPCNES") })
		SM0->(DbGoTo(nRECNOSM0))
	EndIf

	IIF(Alias()         # "GD4", DbSelectArea("GD4"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GD4_FILIAL + GD4_REGGER + GD4_CODPLA
	DbSeek(xFilial("GD4") + cPaciente + cCodPla)

	IIF(Alias()         # "GCM", DbSelectArea("GCM"), Nil)
	IIF(IndexOrd()      # 2, DbSetOrder(2), Nil) // GCM_FILIAL + GCM_CODPLA
	IIF(GCM->GCM_CODPLA # cCodPla, DbSeek(xFilial("GCM") + cCodPla), Nil)

	IIF(Alias()         # "GA9", DbSelectArea("GA9"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GA9_FILIAL+GA9_CODCON
	IIF(GA9->GA9_CODCON # GCM->GCM_CODCON, DbSeek(xFilial("GA9") + GCM->GCM_CODCON), Nil)
	cLogoGH := GA9->GA9_LOGOTP
	cCdOper := IIf(GA9->GA9_CNPJOP=="1",GA9->GA9_CDOPER,"")

	IIF(Alias()         # "GBH", DbSelectArea("GBH"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GBH_FILIAL + GBH_CODPAC
	IIF(GBH->GBH_CODPAC # cPaciente, DbSeek(xFilial("GBH") + cPaciente), Nil)

	IIF(Alias()         # "GAM", DbSelectArea("GAM"), Nil)
	IIF(IndexOrd()      # 3, DbSetOrder(3), Nil) // GAM_FILIAL + GAM_CEP
	IIF(GAM->GAM_CEP    # SM0->M0_CEPCOB, DbSeek(xFilial("GAM") + SM0->M0_CEPCOB), Nil)

	IIF(Alias()         # "GF4", DbSelectArea("GF4"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)   // GF4_FILIAL + GF4_TPALTA
	IIF(GF4->GF4_TPALTA # GCY->GCY_TPALTA, DbSeek(xFilial("GF4") + GCY->GCY_TPALTA), Nil)

	IIF(Alias()         # "GD1", DbSelectArea("GD1"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GD1_FILIAL + GD1_CARATE
	IIF(GD1->GD1_CARATE # GCY->GCY_CARATE, 	DbSeek(xFilial("GD1") + GCY->GCY_CARATE), Nil)

	IIF(Alias()         # "GBJ", DbSelectArea("GBJ"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)  //GBJ_FILIAL + GBJ_CRM
	IIF(GBJ->GBJ_CRM    # GCY->GCY_CODCRM, DbSeek(xFilial("GBJ") + GCY->GCY_CODCRM), Nil)

	If cTissVer < "3"
		If  HS_ExisDic({{"C", "GA9_TPCRM"}}, .F.) .and. GA9->GA9_TPCRM =='1' .and. Len(aCPR[1]) > 0
			IIF(Alias()         # "SRA", DbSelectArea("SRA"), Nil)
			IIF(IndexOrd()      # 11, DbSetOrder(11), Nil) // RA_FILIAL + RA_CODIGO
			IIF(SRA->RA_CODIGO  # ACPR[1,nPosCRMGD7]	, DbSeek(xFilial("SRA") + ACPR[1,nPosCRMGD7]), Nil)
			aG7Crm := {GBJ->GBJ_CIC, SRA->RA_NOME, GBJ->GBJ_CONSEL, GBJ->GBJ_UFCONS, HS_RetCBO(, ACPR[1,nPosCRMGD7], cCodDes), aCPR[1, 2]}
		Else
			IIF(Alias()         # "SRA", DbSelectArea("SRA"), Nil)
			IIF(IndexOrd()      # 11, DbSetOrder(11), Nil) // RA_FILIAL + RA_CODIGO
			IIF(SRA->RA_CODIGO  # GCY->GCY_CODCRM, DbSeek(xFilial("SRA") + GCY->GCY_CODCRM), Nil)
			aG7Crm := {GBJ->GBJ_CIC, SRA->RA_NOME, GBJ->GBJ_CONSEL, GBJ->GBJ_UFCONS, HS_RetCBO(, GCY->GCY_CODCRM, cCodDes), aCPR[1, 2]}
		Endif
	EndIf

	IIF(Alias()         # "GBJ", DbSelectArea("GBJ"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)  //GBJ_FILIAL + GBJ_CRM
	IIF(GBJ->GBJ_CRM    # cMedGuia, DbSeek(xFilial("GBJ") + cMedGuia), Nil)

	IIF(Alias()         # "SRA", DbSelectArea("SRA"), Nil)
	IIF(IndexOrd()      # 11, DbSetOrder(11), Nil) // RA_FILIAL + RA_CODIGO
	IIF(SRA->RA_CODIGO  # cMedGuia, DbSeek(xFilial("SRA") + cMedGuia), Nil)

	aAdd(aTot65, 0)
	aAdd(aTot66, 0)
	aAdd(aTot67, 0)
	aAdd(aTot68, 0)
	aAdd(aTot69, 0)
	aAdd(aTot70, 0)
	aAdd(aTot71, 0)
	aAdd(aTot85, 0)

//Procedimentos
	aAtoMed := {"", ""}

	For nForCol := 1 To IIF(Len(aCPR) > 0,Len(aCPR[1]),1)
		AADD(aVetPR, {})

		aAtoMed := {HS_IniPadr("GBJ", 1,IIF(HS_ExisDic({{"C", "GA9_TPCRM"}}, .F.) .and. GA9->GA9_TPCRM =='1' .and. Len(aCPR[1]) > 0,ACPR[1,nPosCRMGD7],GCY->GCY_CODCRM), "GBJ_CBOTIS"), ""}
		For nForLin := 1 To Len(aCPR)
			If !Empty(aCPR[nForLin, 2]) .and. val(aCPR[nForLin, 2]) < nAtoMed
				nAtoMed := val(aCPR[nForLin, 2])
			EndIf

			DbSelectArea("GA7")
			DbSetOrder(1) //GA7_FILIAL + GA7_CODPRO
			DbSeek(xFilial("GA7") + aCPR[nForLin, 13])
			If lSomaProc := ((GA7->GA7_TIPPRO $ "3/6/8" .Or. (GA7->GA7_TIPPRO $ "1/9" .And. GA7->GA7_HONORA == "1")) .And. !Empty(aCPR[nForLin, 13]) .And. aCPR[nForLin, 14] <> "0" .And. aCPR[nForLin, 15] == "0")
				ASize(aVetPR[nForCol], Len(aVetPR[nForCol]) + 1)
				If nForCol == 3
					aVetPR[nForCol, Len(aVetPR[nForCol])] := aCPR[nForLin, nForCol]
				ElseIf nForCol == 5 .AND. cTissVer < "3"
					DbSelectArea("GDB")
					DbSetOrder(1) //GDB_FILIAL + GDB_CHAVE
					If !Empty(aCPR[nForLin, 5]) .And. DbSeek(xFilial("GDB") + aCPR[nForLin, 5])
						aVetPR[nForCol, Len(aVetPR[nForCol])] := IIF(!Empty(GDB->GDB_TBTISS), GDB->GDB_TBTISS, "00")
					Else
						aVetPR[nForCol, Len(aVetPR[nForCol])] := IIF(!Empty(GA9->GA9_TBTISS), GA9->GA9_TBTISS, "00")
					EndIf
				ElseIf nForCol == 9
					aVetPR[nForCol, Len(aVetPR[nForCol])] := IIf(aCPR[nForLin, nForCol] < 1, aCPR[nForLin, nForCol]*100, 0)
				Else
					aVetPR[nForCol, Len(aVetPR[nForCol])] := aCPR[nForLin, nForCol]
				EndIf
				DbSelectArea("GA7")
				DbSetOrder(1) // GA7_FILIAL + GA7_CODPRO
				DBSeek(xFilial("GA7") + aCPR[nForLin, 13])
				If EMPTY(GA7->GA7_CITISS)
					HS_MsgInf(STR0012 + AllTrim(aCPR[nForLin, 13]) + STR0013, STR0002, STR0014) //"A despesa "###" não está com a classificação do item preenchida."###"Atenção"###"Validação da Guia TISS"
				Return(.F.)
				EndIf
			EndIf

			If !Empty(aCPR[nForLin, 13]) .And. aCPR[nForLin, 14] <> "0" .And. nForCol == 10 .And. aCPR[nForLin, 15] == "0" //pagamento medico nao pode ser repasse direto e o campo _GLODES == normal
				DbSelectArea("G20")
				DbSetOrder(1) //G20_FILIAL + G20_CITISS
				DBSeek(xFilial("G20") + GA7->GA7_CITISS)

				
				nValQtd := HS_CValDes(cAliasG7, aCPR[nForLin, 12])
				aTot71[1]  += nValQtd
				If lSomaProc
					aTot65[1] += nValQtd
					If cTissVer < "3"
						AADD(aCoeDes58, IIF(aCPR[nForLin, 9] == 1, "U", IIF(aCPR[nForLin, 9] == 0.7, "D", IIF(aCPR[nForLin, 9] == 0.5, "M","U"))) )
					Else
						//1=Unica 2=Mesma Via 3=Diferentes Vias
						AADD(aCoeDes58, IIF(aCPR[nForLin, 9] == 1, "1", IIF(aCPR[nForLin, 9] == 0.7, "3", IIF(aCPR[nForLin, 9] == 0.5, "2","1"))) )
					EndIf
					AADD(aValUni61, HS_CValDes(cAliasG7, aCPR[nForLin, 12],,, .T.))
					AADD(aValQtd62, nValQtd)
				Else
					If G20->G20_CODXML $ "04/06"
						aTot66[1] += nValQtd
					ElseIf G20->G20_CODXML == "03"
						aTot67[1] += nValQtd
					ElseIf G20->G20_CODXML == "02"
						aTot68[1] += nValQtd
					ElseIf G20->G20_CODXML == "05"
						aTot69[1] += nValQtd
					ElseIf G20->G20_CODXML == "01"
						aTot70[1] += nValQtd
					EndIf
				EndIf
			EndIf
		Next
	Next

	If cTissVer >= "3"
		DbSelectArea("GBJ")
		DbSetOrder(1) //GBJ_FILIAL + GBJ_CRM
		aG7Crm := {{},{},{},{},{}}
		For nForCol := 1 To Len(aVetPR[1])
			If DbSeek(xFilial("GBJ") + aVetPR[1, nForCol])
				AaDD(aG7Crm[1], GBJ->GBJ_CIC)
				AaDD(aG7Crm[2], GBJ->GBJ_CONSEL)
				AaDD(aG7Crm[3], aVetPR[1,nForCol])
				AaDD(aG7Crm[4], GBJ->GBJ_UFCONS)
				AaDD(aG7Crm[5], GBJ->GBJ_CBOTIS)
			EndIf
		Next
	EndIf

//Materiais
	For nForCol := 1 To IIF(Len(aCMM) > 0,Len(aCMM[1]),1)
		AADD(aVetMMTD, {})
		For nForLin := 1 To Len(aCMM)
			If !Empty(aCMM[nForLin, 2])
				DbSelectArea("GBI")
				DbSetOrder(1) //GBI_FILIAL + GBI_PRODUT
				DBSeek(xFilial("GBI") + aCMM[nForLin, 7])
				If EMPTY(GBI->GBI_CITISS)
					HS_MsgInf(STR0012 + AllTrim(aCMM[nForLin, 7]) + STR0013, STR0002, STR0014) //"A despesa "###" não está com a classificação do item preenchida."###"Atenção"###"Validação da Guia TISS"
				Return(.F.)
				Else
					DbSelectArea("G20")
					DbSetOrder(1) //G20_FILAIL + G20_CITISS
					DBSeek(xFilial("G20") + GBI->GBI_CITISS)
					If G20->G20_CODXML == "11" .And. aCMM[nForLin, 8] == "0" //classificacao do item == 11 e o campo _GLODES == normal
						ASize(aVetMMTD[nForCol], Len(aVetMMTD[nForCol]) + 1)
						If nForCol == 1 .AND. cTissVer < "3"
							DbSelectArea("GCA")
							DbSetOrder(1) //GCA_FILIAL + GCA_CODTAB
							If !Empty(aCMM[nForLin, 1]) .And. DbSeek(xFilial("GCA") + aCMM[nForLin, 1])
								aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := IIF(!Empty(GCA->GCA_TBTISS), GCA->GCA_TBTISS, "00")
							Else
								aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := IIF(!Empty(GA9->GA9_TBTISS), GA9->GA9_TBTISS, "00")
							EndIf
						Else
							aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := aCMM[nForLin, nForCol]
						EndIf
					EndIf

					If nForCol == 5 .And. aCMM[nForLin, 8] == "0"
						nValQtd := HS_CValDes(cAliasG5, aCMM[nForLin, 6])
						aTot71[1] += nValQtd
						If G20->G20_CODXML $ "04/06"
							aTot66[1] += nValQtd
						ElseIf G20->G20_CODXML == "03"
							aTot67[1] += nValQtd
						ElseIf G20->G20_CODXML == "02"
							aTot68[1] += nValQtd
						ElseIf G20->G20_CODXML == "05"
							aTot69[1] += nValQtd
						ElseIf G20->G20_CODXML == "01"
							aTot70[1] += nValQtd
						ElseIf G20->G20_CODXML == "11"
							AADD(aValUni83, HS_CValDes(cAliasG5, aCMM[nForLin, 6],,, .T.))
							AADD(aValQtd84, nValQtd)
							aTot85[1] += nValQtd
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	Next

//Taxas
	For nForCol := 1 To IIF(Len(aCTD) > 0,Len(aCTD[1]),1)
		For nForLin := 1 To Len(aCTD)
			If !Empty(aCTD[nForLin, 2])
				DbSelectArea("GAA")
				DbSetOrder(1) //GAA_FILIAL + GAA_CODTXD
				DBSeek(xFilial("GAA") + aCTD[nForLin, 7])
				If EMPTY(GAA->GAA_CITISS)
					HS_MsgInf(STR0012 + AllTrim(aCTD[nForLin, 7]) + STR0013, STR0002, STR0014) //"A despesa "###" não está com a classificação do item preenchida."###"Atenção"###"Validação da Guia TISS"
				Return(.F.)
				Else
					DbSelectArea("G20")
					DbSetOrder(1) //G20_FILIAL + G20_CITISS
					DBSeek(xFilial("G20") + GAA->GAA_CITISS)
					If G20->G20_CODXML == "11" .And. aCTD[nForLin, 8] == "0"  // classificacao do item == 11 e o campo _GLODES == normal
						ASize(aVetMMTD[nForCol], Len(aVetMMTD[nForCol]) + 1)
						If nForCol == 1 .AND. cTissVer < "3"
							DbSelectArea("GD2")
							DbSetOrder(1) //GD2_FILIAL + GD2_CODTAB
							If !Empty(aCTD[nForLin, 1]) .And. DbSeek(xFilial("GD2") + aCTD[nForLin, 1])
								aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := IIF(!Empty(GD2->GD2_TBTISS), GD2->GD2_TBTISS, "00")
							Else
								aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := IIF(!Empty(GA9->GA9_TBTISS), GA9->GA9_TBTISS, "00")
							EndIf
						Else
							aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := aCTD[nForLin, nForCol]
						EndIf
					EndIf

					If nForCol == 5 .And. aCTD[nForLin, 8] == "0"
						nValQtd := HS_CValDes(cAliasG6, aCTD[nForLin, 6])
						aTot71[1] += nValQtd
						
						If cTissVer >= "3"
							If G20->G20_CODXML $  "04/05/06/09"
								aTot66[1] += nValQtd
							ElseIf G20->G20_CODXML == "03"
								aTot67[1] += nValQtd
							ElseIf G20->G20_CODXML == "02"
								aTot68[1] += nValQtd
							ElseIf G20->G20_CODXML == "01"
								aTot70[1] += nValQtd
							ElseIf G20->G20_CODXML == "11"
								AADD(aValUni83, HS_CValDes(cAliasG6, aCTD[nForLin, 6],,, .T.))
								AADD(aValQtd84, nValQtd)
								aTot85[1] += nValQtd
							EndIf
						Else
							If G20->G20_CODXML $  "04/06"
								aTot66[1] += nValQtd
							ElseIf G20->G20_CODXML == "03"
								aTot67[1] += nValQtd
							ElseIf G20->G20_CODXML == "02"
								aTot68[1] += nValQtd
							ElseIf G20->G20_CODXML == "05"
								aTot69[1] += nValQtd
							ElseIf G20->G20_CODXML == "01"
								aTot70[1] += nValQtd
							ElseIf G20->G20_CODXML == "11"
								AADD(aValUni83, HS_CValDes(cAliasG6, aCTD[nForLin, 6],,, .T.))
								AADD(aValQtd84, nValQtd)
								aTot85[1] += nValQtd
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	Next

// Processo para tratar o conceito de trazer o codigo do procedimento exame e complemento
// Criado vetor para impressao da guia tiss pelo fonte PLSTISS funcione - posição 64.

	For nVetCp := 1 to FS_LINTIS(Len(aVetPR[6]))
		If cOrigem == "M08" .AND. ValType("aCptoM08") <> "U" .AND. nVetCp <= Len(aVetPR[6])  // Complemento quando vindo do pedido de exames
			nPosCpt := ASCAN(aCptoM08, {| aVet | aVet[1] == aVetPR[13,nVetCp]})
			If nPosCpt > 0
				AADD(aVCodCp,IIf (!Empty(aCptoM08[nPosCpt,2]),aVetPR[6,nVetCp]+ " - " + aCptoM08[nPosCpt,2],""))  // Codigo do exame e Complemento do exame
			Else
				AADD(aVCodCp," ")
			EndIf
		ElseIf nVetCp <= Len(aVetPR[6])  .AND. !Empty(HS_IniPadr("GBY", 4,aVetPR[12,nVetCp], "GBY_COMPTO"))
			AADD(aVCodCp,IIf (Empty(aVetPR[6,nVetCp]),"",aVetPR[6,nVetCp])+ " " +HS_IniPadr("GBY", 4,aVetPR[12,nVetCp], "GBY_COMPTO"))  // Codigo do exame e Complemento do exame
		Else
			AADD(aVCodCp," ")
		EndIf
	Next nVetCp

	If Len(aVCodCp) == 0
		AADD(aVCodCp," ")
		AADD(aVCodCp," ")
		AADD(aVCodCp," ")
		AADD(aVCodCp," ")
		AADD(aVCodCp," ")
	EndIf

	If cTissVer < "3"
		If cOrigem # "M08"
			aSADTDes := {{	GA9->GA9_CODOPE,; //1
			GCZ->GCZ_NRGUIA,; //2
			GCZ->GCZ_GUIAPR      ,; //3
			GCZ->GCZ_DATAUT,; //4
			GCZ->GCZ_NRSEN1      ,; //5
			GCZ->GCZ_VALSEN,; //6
			GCY->GCY_DATATE         ,; //7
			GD4->GD4_MATRIC    ,; //8
			GCM->GCM_DESPLA    ,; //9
			GD4->GD4_DTVALI    ,; //10
			GCY->GCY_NOME      ,; //11
			GBH->GBH_NUMCNS    ,; //12
			IIf(Empty(cCdOper),aSM0Dados[1, 1],cCdOper),; //13
			aSM0Dados[1, 2],; //14
			aSM0Dados[1, 8]    ,; //15
			IIF(Empty(GCZ->GCZ_CODCRM), "", SRA->RA_NOME)   ,; //16
			IIF(Empty(GCZ->GCZ_CODCRM), "", GBJ->GBJ_CONSEL),; //17
			GCZ->GCZ_CODCRM                                 ,; //18
			IIF(Empty(GCZ->GCZ_CODCRM), "", GBJ->GBJ_UFCONS),; //19
			HS_IniPadr("GBJ", 1,GCZ->GCZ_CODCRM, "GBJ_CBOTIS"),; //20
			{dDataSol, cHorSol},; //21
			GD1->GD1_CATISS    ,; //22
			HS_RetCID(GCZ->GCZ_REGATE, GA9->GA9_CODCON, "GA9_ICIDSP", "4"),; //23
			GCZ->GCZ_INDCLI ,; //24
			aVetPR[5]          ,; //25
			aVetPR[6]          ,; //26
			aVetPR[7]          ,; //27
			aVetPR[8]          ,; //28
			aVetPR[8]          ,; //29
			HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2],; //30
			aSM0Dados[1, 2]    ,; //31
			GAM->GAM_TIPLOG    ,; //32
			aSM0Dados[1, 3] + " " + aSM0Dados[1, 4],; //33
			""                 ,; //34
			""                 ,; //35
			aSM0Dados[1, 5]    ,; //36
			aSM0Dados[1, 6]    ,; //37
			SM0->M0_CODMUN     ,; //38
			aSM0Dados[1, 7]    ,; //39
			Iif(IsInCallStack("HSPAHM30"),{"",""},{aSM0Dados[1,8], aG7Crm[1]}),; //40
			Iif(IsInCallStack("HSPAHM30"),"",aG7Crm[2])          ,; //41
			Iif(IsInCallStack("HSPAHM30"),"",aG7Crm[3])          ,; //42
			Iif(IsInCallStack("HSPAHM30"),"",IIF( HS_ExisDic({{"C", "GA9_TPCRM"}}, .F.) .and. GA9->GA9_TPCRM =='1',ACPR[1,nPosCRMGD7],GCY->GCY_CODCRM))    ,; //43
			Iif(IsInCallStack("HSPAHM30"),"",aG7Crm[4])          ,; //44
			Iif(IsInCallStack("HSPAHM30"),{"",""},aAtoMed)            ,; //45
			GCZ->GCZ_TATISS ,; //46
			GCZ->GCZ_IATISS ,; //47
			SUBSTR(GF4->GF4_TSTISS, 2, 1)           ,; //48
			IIf(GCZ->GCZ_TDTISS == "0", "A", "C"),; //49
			{GCZ->GCZ_TEDVLR, GCZ->GCZ_TEDUND},;  //50
			aVetPR[3]          ,; //51
			aVetPR[4]          ,; //52
			aVetPR[4]          ,; //53
			aVetPR[5]          ,; //54
			aVetPR[6]          ,; //55
			aVetPR[7]          ,; //56
			aVetPR[8]          ,; //57
			aCoeDes58          ,; //58
			aVetPR[16]         ,; //59
			aVetPR[9]          ,; //60
			aValUni61          ,; //61
			aValQtd62          ,; //62
			{}                 ,; //63
			aVCodCp            ,; //64
			aTot65             ,; //65
			aTot66             ,; //66
			aTot67             ,; //67
			aTot68             ,; //68
			aTot69             ,; //69
			aTot70             ,; //70
			aTot71             ,; //71
			{}          ,; //72
			{}          ,; //73
			{}          ,; //74
			{}          ,; //75
			{}          ,; //76
			{}          ,; //77
			aVetMMTD[1] ,; //78
			aVetMMTD[2] ,; //79
			aVetMMTD[3] ,; //80
			aVetMMTD[4] ,; //81
			{}          ,; //82
			aValUni83   ,; //83
			aValQtd84   ,; //84
			aTot85      ,; //85
			CTOD("")    ,; //86
			CTOD("")    ,; //87
			CTOD("")    ,; //88
			CTOD("")    }} //89
		Else
			aSADTDes := {{	GA9->GA9_CODOPE ,; //1
			PadL(GCY->GCY_REGATE,20,"0"),; //2
			"",; //3
			CTOD(""),; //4
			"",; //5
			CTOD(""),; //6
			dDataBase,; //7
			GD4->GD4_MATRIC,; //8
			GCM->GCM_DESPLA,; //9
			GD4->GD4_DTVALI,; //10
			IIF(Type("cTpNasc") # "U" .And. !Empty(cTpNasc),cNomeRn, GCY->GCY_NOME) ,; //11
			GBH->GBH_NUMCNS,; //12
			IIf(Empty(cCdOper),aSM0Dados[1, 1],cCdOper),; //13
			aSM0Dados[1, 2],; //14
			aSM0Dados[1, 8],; //15
			SRA->RA_NOME,; //16
			GBJ->GBJ_CONSEL,; //17
			cMedGuia,; //18
			GBJ->GBJ_UFCONS,; //19
			HS_IniPadr("GBJ", 1,GCY->GCY_CODCRM, "GBJ_CBOTIS"),; //HS_RetCBO(cMedGuia, GCY->GCY_CODCRM, cCodDes),; //20
			{dDataSol, cHorSol},; //21
			GD1->GD1_CATISS,; //22
			HS_RetCID(GCZ->GCZ_REGATE, GA9->GA9_CODCON, "GA9_ICIDSP", "4"),; //23
			GCZ->GCZ_INDCLI ,; //24
			aVetPR[5],; //25
			aVetPR[6],; //26
			aVetPR[7],; //27
			aVetPR[8],; //28
			aVetPR[8],; //29
			HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2],; //30
			aSM0Dados[1, 2]    ,; //31
			GAM->GAM_TIPLOG    ,; //32
			aSM0Dados[1, 3] + " " + aSM0Dados[1, 4],; //33
			""                 ,; //34
			""                 ,; //35
			aSM0Dados[1, 5]    ,; //36
			aSM0Dados[1, 6]    ,; //37
			SM0->M0_CODMUN     ,; //38
			aSM0Dados[1, 7]    ,; //39
			Iif(IsInCallStack("HSPAHM30"),{"",""},{aSM0Dados[1,8], aG7Crm[1]}),; //40
			Iif(IsInCallStack("HSPAHM30"),"",aG7Crm[2])          ,; //41
			Iif(IsInCallStack("HSPAHM30"),"",aG7Crm[3])          ,; //42
			Iif(IsInCallStack("HSPAHM30"),"",GCY->GCY_CODCRM)    ,; //43
			Iif(IsInCallStack("HSPAHM30"),"",aG7Crm[4])          ,; //44
			Iif(IsInCallStack("HSPAHM30"),{"",""},aAtoMed)            ,; //45
			GCZ->GCZ_TATISS ,; //46
			GCZ->GCZ_IATISS ,; //47
			SUBSTR(GF4->GF4_TSTISS, 2, 1)           ,; //48
			IIf(GCZ->GCZ_TDTISS == "0", "A", "C"),; //49
			{GCZ->GCZ_TEDVLR, GCZ->GCZ_TEDUND},;  //50
			aVetPR[3]          ,; //51
			aVetPR[4]          ,; //52
			aVetPR[4]          ,; //53
			aVetPR[5]          ,; //54
			aVetPR[6]          ,; //55
			aVetPR[7]          ,; //56
			aVetPR[8]          ,; //57
			aCoeDes58          ,; //58
			aVetPR[16]         ,; //59
			aVetPR[9]          ,; //60
			aValUni61          ,; //61
			aValQtd62          ,; //62
			{}                 ,; //63
			aVCodCp ,; //64
			aTot65             ,; //65
			aTot66             ,; //66
			aTot67             ,; //67
			aTot68             ,; //68
			aTot69             ,; //69
			aTot70             ,; //70
			aTot71             ,; //71
			{}          ,; //72
			{}          ,; //73
			{}          ,; //74
			{}          ,; //75
			{}          ,; //76
			{}          ,; //77
			aVetMMTD[1] ,; //78
			aVetMMTD[2] ,; //79
			aVetMMTD[3] ,; //80
			aVetMMTD[4] ,; //81
			{}          ,; //82
			aValUni83   ,; //83
			aValQtd84   ,; //84
			aTot85      ,; //85
			dDataBase    ,; //86
			CTOD("")    ,; //87
			CTOD("")    ,; //88
			CTOD("")    }} //89
		EndIf

		PLSTISS2(aSADTDes, lVsTISS, nLayout, cLogoGH)

	Else

		cCboTiss := HS_IniPadr("GBJ", 1,GCZ->GCZ_CODCRM, "GBJ_CBOTIS")

		aVetPR[7] := AClone(aVetPR[13])

		aVetPR[5] := HS_AJUSTIS(aVetPR[5], "BTU_CDTERM", "GDB", .F., "87")
		aVetPR[13] := HS_AJUSTIS(aVetPR[13], "BTU_CDTERM", "GA7", .F., "22")
		aVetPR[7] := HS_AJUSTIS(aVetPR[7], "BTQ_DESTER", "GA7", .F., "22")
		aVetPR[16]:= HS_AJUSTIS(aVetPR[16], "BTU_CDTERM", "   ", .F., "48")
		aVetPR[2] := HS_AJUSTIS(aVetPR[2], "BTU_CDTERM", "GMC", .F., "35")
		aG7Crm[2] := HS_AJUSTIS(aG7Crm[2], "BTU_CDTERM", "BAH", .F., "26")
		aG7Crm[4] := HS_AJUSTIS(aG7Crm[4], "BTU_CDTERM", "SX5", .F., "59")
		aG7Crm[5] := HS_AJUSTIS(aG7Crm[5], "BTU_CDTERM", "GN1", .F., "24")
		If cOrigem # "M08"
			aSADTDes := {{	GA9->GA9_CODOPE		,; //1
							GCZ->GCZ_NRGUIA		,; //2
							GCZ->GCZ_GUIAPR     ,; //3
							GCZ->GCZ_DATAUT		,; //4
							GCZ->GCZ_NRSEN1     ,; //5
							GCZ->GCZ_VALSEN		,; //6
							GCZ->GCZ_GUIAOP		,; //7
							GD4->GD4_MATRIC    	,; //8
							GD4->GD4_DTVALI    	,; //9
							GCY->GCY_NOME      	,; //10
							GBH->GBH_NUMCNS    	,; //11
							GCY->GCY_ATERN		,; //12
							IIf(Empty(cCdOper),aSM0Dados[1, 1],cCdOper) ,; //13
							aSM0Dados[1, 2]		,; //14
							IIF(Empty(GCZ->GCZ_CODCRM), "", SRA->RA_NOME) ,; //15
							IIF(Empty(ALLTRIM(GCZ->GCZ_CODCRM)) .OR. Empty(ALLTRIM(GBJ->GBJ_CONSEL)), "", PLSGETVINC("BTU_CDTERM", "BAH", .F., "26", ALLTRIM(GBJ->GBJ_CONSEL))) ,; //16
							GCZ->GCZ_CODCRM		,; //17
							IIF(Empty(ALLTRIM(GCZ->GCZ_CODCRM)) .OR. Empty(ALLTRIM(GBJ->GBJ_UFCONS)), "", PLSGETVINC("BTU_CDTERM", "SX5", .F., "59", "12"+ALLTRIM(GBJ->GBJ_UFCONS))) ,; //18
							IIF(Empty(ALLTRIM(cCboTiss)), "", PLSGETVINC("BTU_CDTERM", "GN1", .F., "24", cCboTiss)) ,; //19
							""					,;//20
							IIF(Empty(ALLTRIM(GD1->GD1_CARATE)), "", PLSGETVINC("BTU_CDTERM", "GD1", .F., "23", ALLTRIM(GD1->GD1_CARATE))) ,; //21
							dDataSol			,; //22
							GCZ->GCZ_INDCLI 	,; //23
							aVetPR[5]			,; //24
							aVetPR[13]			,; //25
							aVetPR[7]			,;//26
							aVetPR[8]          	,; //27
							aVetPR[8]          	,; //28
							HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2] ,; //29
							aSM0Dados[1, 2]    	,; //30
							Iif(IsInCallStack("HSPAHM30"),"",aSM0Dados[1,8]) ,; //31
							IIF (Empty(ALLTRIM(GCZ->GCZ_TATISS)), "" ,PLSGETVINC("BTU_CDTERM", "G08", .F., "50", ALLTRIM(GCZ->GCZ_TATISS))) ,; //32
							IIF (Empty(ALLTRIM(GCZ->GCZ_IATISS)), "" ,PLSGETVINC("BTU_CDTERM", "   ", .F., "36", ALLTRIM(GCZ->GCZ_IATISS))) ,; //33
							IIF (Empty(ALLTRIM(GCZ->GCZ_TIPCON)), "" ,PLSGETVINC("BTU_CDTERM", "G12", .F., "52", ALLTRIM(GCZ->GCZ_TIPCON))) ,; //34
							IIF (Empty(ALLTRIM(GF4->GF4_TSTISS)), "" ,PLSGETVINC("BTU_CDTERM", "GF4", .F., "39", ALLTRIM(GF4->GF4_TPALTA))) ,; //35
							aVetPR[3]          	,; //36
							aVetPR[4]          	,; //37
							aVetPR[4]          	,; //38
							aVetPR[5]           ,; //39
							aVetPR[13]			,; //40
							aVetPR[7]			,; //41
							aVetPR[8]          	,; //42
							{}			,; //43
							aVetPR[16]			,; //44
							aVetPR[9]          	,; //45
							aValUni61          	,; //46
							aValQtd62          	,; //47
							{}					,; //48
							aVetPR[2]			,; //49
							aG7Crm[1]			,; //50
							{}			,; //51
							aG7Crm[2]			,; //52
							aG7Crm[3]			,; //53
							aG7Crm[4]			,; //54
							aG7Crm[5]			,; //55
							{CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD("")} ,; //56
							""					,; //57 Assinatura
							GCZ->GCZ_OBSTIS		,; //58
							aTot65[1]             	,; //59
							aTot66[1]             	,; //60
							aTot67[1]             	,; //61
							aTot85[1]					,; //62
							aTot68[1]             	,; //63
							aTot70[1]             	,; //64
							aTot71[1]             	}} //65
		Else
			aSADTDes := {{	GA9->GA9_CODOPE		,; //1
							PadL(GCY->GCY_REGATE,20,"0"),; //2
							"",					; //3
							CTOD("")			,; //4
							""					,; //5
							CTOD("")			,; //6
							GCZ->GCZ_GUIAOP		,; //7
							GD4->GD4_MATRIC		,; //8
							GD4->GD4_DTVALI		,; //9
							IIF(Type("cTpNasc") # "U" .And. !Empty(cTpNasc),cNomeRn, GCY->GCY_NOME) ,; //10
							GBH->GBH_NUMCNS		,; //11
							GCY->GCY_ATERN		,; //12
							IIf(Empty(cCdOper),aSM0Dados[1, 1],cCdOper),; //13
							aSM0Dados[1, 2]		,; //14
							SRA->RA_NOME		,; //15
							IIF(Empty(ALLTRIM(GBJ->GBJ_CONSEL)), "", PLSGETVINC("BTU_CDTERM", "BAH", .F., "26", ALLTRIM(GBJ->GBJ_CONSEL)))	,; //16
							cMedGuia			,; //17
							IIF(Empty(ALLTRIM(GBJ->GBJ_UFCONS)), "", PLSGETVINC("BTU_CDTERM", "SX5", .F., "59", "12"+ALLTRIM(GBJ->GBJ_UFCONS))),; //18
							IIF(Empty(ALLTRIM(cCboTiss)),        "", PLSGETVINC("BTU_CDTERM", "GN1", .F., "24", ALLTRIM(cCboTiss))),; //19
							""					,; //20
							IIF(Empty(ALLTRIM(GD1->GD1_CARATE)), "", PLSGETVINC("BTU_CDTERM", "GD1", .F., "23", ALLTRIM(GD1->GD1_CARATE)))	,; //21
							dDataSol			,; //22
							GCZ->GCZ_INDCLI 	,; //23
							aVetPR[5]			,; //24
							aVetPR[13] 			,; //25
							aVetPR[7]			,; //26
							aVetPR[8]			,; //27
							aVetPR[8]			,; //28
							HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2],; //29
							aSM0Dados[1, 2]    	,; //30
							Iif(IsInCallStack("HSPAHM30"),"",aSM0Dados[1,8]),; //31
							IIF (Empty(ALLTRIM(GCZ->GCZ_TATISS)), "", PLSGETVINC("BTU_CDTERM", "G08", .F., "50", ALLTRIM(GCZ->GCZ_TATISS))) ,; //32
							IIF (Empty(ALLTRIM(GCZ->GCZ_IATISS)), "", PLSGETVINC("BTU_CDTERM", "   ", .F., "36", ALLTRIM(GCZ->GCZ_IATISS))) ,; //33
							IIF (Empty(ALLTRIM(GCZ->GCZ_TIPCON)), "", PLSGETVINC("BTU_CDTERM", "G12", .F., "52", ALLTRIM(GCZ->GCZ_TIPCON))) ,; //34
							IIF (Empty(ALLTRIM(GF4->GF4_TSTISS)), "", PLSGETVINC("BTU_CDTERM", "GF4", .F., "39", ALLTRIM(GF4->GF4_TPALTA))) ,; //35
							aVetPR[3]          	,; //36
							aVetPR[4]          	,; //37
							aVetPR[4]          	,; //38
							aVetPR[5]			,; //39
							aVetPR[13]			,; //40
							aVetPR[7]			,; //41
							aVetPR[8]          	,; //42
							{}			,; //43
							aVetPR[16]			,; //44
							aVetPR[9]          	,; //45
							aValUni61          	,; //46
							aValQtd62          	,; //47
							{}					,; //48
							aVetPR[2]			,; //49
							{}					,; //50
							{}			,; //51
							{}					,; //52
							{}					,; //53
							{}					,; //54
							{}					,; //55
							{CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD(""),CtoD("")},; //56
							""					,; //57 assinatura
							GCZ->GCZ_OBSTIS		,; //58
							aTot65[1]             	,; //59
							aTot66[1]             	,; //60
							aTot67[1]             	,; //61
							aTot85[1]					,; //62
							aTot68[1]             	,; //63
							aTot70[1]             	,; //64
							aTot71[1]             	}} //65
		EndIf

		PLSTISSC(aSADTDes, lVsTISS, nLayout, cLogoGH, Nil, Nil, Nil, .T.)

	EndIf
Return(.T.)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ Hs_ImpSInt ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Impressao da guia de solicitacao de Internacao do TISS.       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Sequencial da guia                                     ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function Hs_ImpSInt(cNrSeqG,cCodSol)
	Default cCodSol = ""
	Default cNrSeqG = ""

	Local aArea	  := GetArea()
	Local cRegAte   := ""
	Local cPaciente := ""
	Local cCodPla   := ""
	Local aHPR      := {}
	Local aCPR 	  := {}
	Local nUPR 	  := 0
	//Local aHOP      := {}, aCOP := {}, nUOP := 0
	Local aSM0Dados := {}
	Local aVetPr	  := {}
	Local aVetTab	  := {}
	Local cSql      := ""

	Local lVsTISS   := IIF(GetMV("MV_VISTISS") == "S", .F., .T.)
	Local nLayout   := 2
	Local nForCol	  := 0
	Local nForLin   := 0
	Local cCBO      := ""
	If Empty(aSM0Dados)
		DbSelectArea("SM0")
		aAdd(aSM0Dados, {SM0->M0_CGC, SM0->M0_NOMECOM, SM0->M0_ENDENT, SM0->M0_COMPENT, SM0->M0_CIDENT, SM0->M0_ESTENT, SM0->M0_CEPENT, GETMV("MV_HSPCNES") })
	EndIf

	If !Empty(cCodSol)
		cSql += " SELECT GNX.GNX_CODSOL,SRA.RA_NOME,SRA.RA_CODIGO,GNX.GNX_CODCRM GCY_CODCRM,GNX.GNX_CODPLA GCZ_CODPLA,GNX.GNX_REGATE GCZ_REGATE, "
		cSql += " GNX.GNX_REGGER GCZ_REGGER,GA9.GA9_CODOPE,GNX.GNX_CODSOL GCZ_NRGUIA,GNX.GNX_DATAUT GCZ_DATAUT,GNX.GNX_SENHA GCZ_NRSEN1, "
		cSql += " GNX.GNX_DATVLD GCZ_VALSEN,GNX.GNX_DATADM GCY_DATATE,GBH.GBH_NUMCNS, "
		cSql += " GD4.GD4_MATRIC,GCM.GCM_DESPLA,GD4.GD4_DTVALI,GNX.GNX_NOMPAC GBH_NOME ,GBJ.GBJ_UFCONS,GBJ.GBJ_CONSEL, "
		cSql += " GBJ.GBJ_CIC,GNX.GNX_CARINT GD1_CATISS,GNX.GNX_CODCRM GCZ_CODCRM,GBJ.GBJ_CIC,GNX.GNX_TIPINT GCW_TITISS, "
		cSql += " GNX.GNX_REGINT GCY_REGIME,GNX.GNX_DIASOL GE8_QTDIAS,GNX.GNX_INDCLI GE8_INDCLI,GNX.GNX_TDTISS GCZ_TDTISS,GNX.GNX_CODPAT GCY_CIDALT ,"
		cSql += " '' GCY_CIDCMP,GNX.GNX_DTPADM GE8_ADMHOS, "
		cSql += " GNX.GNX_DIAAUT GE8_QTDLIB,'' GE8_TPDIAR,'' GCZ_CODTPG,GA9.GA9_CODCON,GNX.GNX_DATSOL GE8_DATSOL,''GE8_RESAUT,GCY.GCY_ATERN,GCZ.GCZ_IATISS, '' GD1_CARATE, 'N' GCZ_USOOPM, 'N' GCZ.GCZ_USOQUI "
		cSql += " FROM " + RetSqlName("GNX") + " GNX "
		cSql += " JOIN " + RetSqlName("GD4") + " GD4 ON GD4.GD4_REGGER=GNX.GNX_REGGER  AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("GCM") + " GCM ON GNX.GNX_CODPLA=GCM.GCM_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_CODCON=GCM.GCM_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
		cSql += " LEFT JOIN " + RetSqlName("GBH") + " GBH ON GBH.GBH_CODPAC=GNX.GNX_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ.GBJ_CRM=GNX.GNX_CODCRM AND GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_CODIGO=GNX.GNX_CODCRM AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
		cSql += " WHERE GNX.GNX_CODSOL = '" + cCodSol + "' AND GNX.GNX_FILIAL = '" + xFilial("GNX") + "' AND GNX.D_E_L_E_T_ <> '*' "
	Else
		cSql += " SELECT GCZ.GCZ_CODDES,GCZ.GCZ_NRSEQG,SRA.RA_NOME,SRA.RA_CODIGO,GCY.GCY_CODCRM,GCZ.GCZ_CODPLA,GCZ.GCZ_REGATE,GCZ.GCZ_REGGER,GA9.GA9_CODOPE,GCZ.GCZ_NRGUIA,GCZ.GCZ_DATAUT,GCZ.GCZ_NRSEN1,GCZ.GCZ_VALSEN,GCY.GCY_DATATE, "
		cSql += " GD4.GD4_MATRIC,GCM.GCM_DESPLA,GD4.GD4_DTVALI,GBH.GBH_NOME ,GBH.GBH_NOME ,GBJ.GBJ_UFCONS,GBJ.GBJ_CONSEL, "
		cSql += " GBJ.GBJ_CIC,GD1.GD1_CATISS,GCZ.GCZ_CODCRM,GBJ.GBJ_CIC,GD1.GD1_CATISS,GCW.GCW_TITISS,GBH.GBH_NUMCNS, "
		cSql += " GCY.GCY_REGIME,GE8.GE8_QTDIAS,GE8.GE8_INDCLI,GCZ.GCZ_TDTISS,GCY.GCY_CIDALT ,GCY.GCY_CIDCMP,GE8.GE8_ADMHOS, "
		cSql += " GE8.GE8_QTDLIB,GE8.GE8_TPDIAR,GCZ.GCZ_CODTPG,GA9.GA9_CODCON,GE8.GE8_DATSOL,GE8.GE8_RESAUT,GCY.GCY_ATERN,GCZ.GCZ_IATISS,GD1.GD1_CARATE,GCZ.GCZ_USOOPM, GCZ.GCZ_USOQUI "
		cSql += " FROM " + RetSqlName("GCZ") + " GCZ "
		cSql += " JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_REGATE=GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
		cSql += " LEFT JOIN " + RetSqlName("GE8") + " GE8 ON GE8.GE8_NRSEQG=GCZ.GCZ_NRSEQG AND GE8.GE8_FILIAL = '" + xFilial("GE8") + "' AND GE8.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("GD4") + " GD4 ON GD4.GD4_REGGER=GCY.GCY_REGGER  AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("GCM") + " GCM ON GCZ.GCZ_CODPLA=GCM.GCM_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_CODCON=GCM.GCM_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("GBH") + " GBH ON GBH.GBH_CODPAC=GCY.GCY_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("GF4") + " GF4 ON GF4.GF4_TPALTA=GCY.GCY_TPALTA AND GF4.GF4_FILIAL = '" + xFilial("GF4") + "' AND GF4.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("GD1") + " GD1 ON GD1.GD1_CARATE=GCY.GCY_CARATE AND GD1.GD1_FILIAL = '" + xFilial("GD1") + "' AND GD1.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ.GBJ_CRM=GCZ.GCZ_CODCRM AND GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_CODIGO=GE8.GE8_CODCRM AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
		cSql += " JOIN " + RetSqlName("GCW") + " GCW ON GCW.GCW_CODCLI=GCY.GCY_CODCLI AND GCW.GCW_FILIAL = '" + xFilial("GCW") + "' AND GCW.D_E_L_E_T_ <> '*' "
		cSql += " LEFT JOIN " + RetSqlName("GAV") + " GAV ON GAV.GAV_CODLOC=GCY.GCY_CODLOC AND GAV.GAV_QUARTO=GCY.GCY_QUAINT AND GAV.GAV_LEITO=GCY.GCY_LEIINT "
		cSql += " AND GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' "
		cSql += " WHERE GCZ.GCZ_NRSEQG = '" + cNrSeqG + "' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
	Endif

	TCQUERY cSql NEW ALIAS "QRY"
	DbSelectArea("QRY")

	cRegAte   := IIF(!Empty(cRegAte)  ,cRegAte  , QRY->GCZ_REGATE)
	cPaciente := IIF(!Empty(cPaciente),cPaciente, QRY->GCZ_REGGER)
	cCodPla   := IIF(!Empty(cCodPla)  ,cCodPla  , QRY->GCZ_CODPLA)

	aCposPR := {"GE3_CODDES", "GE3_DDESPE", "GE3_QTDSOL", "GE3_QTDAUT"}
	aCposOP := {"GE2_CODDES", "GE2_DDESPE", "GE2_QTDSOL", "GE2_QTDAUT"}
	cLogoGH := GA9->GA9_LOGOTP

	If !Empty(cCodSol)
		HS_BDados("GE3", @aHPR, @aCPR, @nUPR, 2,, " GE3->GE3_CODSOL == '" + cCodSol + "' ",,, "/",,,,,, .T.,,,,,, aCposPR)
	Else
		HS_BDados("GE3", @aHPR, @aCPR, @nUPR, 2,, " GE3->GE3_NRSEQG == '" + QRY->GCZ_NRSEQG + "' ",,, "/",,,,,, .T.,,,,,, aCposPR)
	Endif

	AADD(aVetTab, {})
	For nForLin := 1 to Len(aCPR)
		AADD(aVetTab[1], "00") //Outras tabelas TISS
	Next

	For nForCol := 1 To nUPR
		AADD(aVetPR, {})
		For nForLin := 1 To Len(aCPR)
			ASize(aVetPR[nForCol], Len(aVetPR[nForCol]) + 1)
			If nForCol <> 7
				aVetPR[nForCol, Len(aVetPR[nForCol])] := aCPR[nForLin, nForCol]
			EndIf
		Next nForLin
	Next nForCol

	If GetNewPar("MV_TISSVER", "2.02.03") < "3"

		aSolInte := {{QRY->GA9_CODOPE          ,; //1
		QRY->GCZ_NRGUIA       ,; //2
		STOD(QRY->GCZ_DATAUT) ,; //3
		QRY->GCZ_NRSEN1       ,; //4
		STOD(QRY->GCZ_VALSEN) ,; //5
		STOD(QRY->GCY_DATATE)          ,; //6
		QRY->GD4_MATRIC          ,; //7
		QRY->GCM_DESPLA          ,; //8
		STOD(QRY->GD4_DTVALI)          ,; //9
		QRY->GBH_NOME            ,; //10
		QRY->GBH_NUMCNS          ,; //11
		HS_RetOper(, QRY->GCZ_CODTPG, QRY->GA9_CODCON)[2],;  //12
		aSM0Dados[1, 2]          ,; //13
		aSM0Dados[1, 8]          ,; //14
		QRY->RA_NOME,; //15
		QRY->GBJ_CONSEL,; //16
		QRY->RA_CODIGO,; //17
		QRY->GBJ_UFCONS,; //18
		HS_RetCBO(QRY->GCZ_CODCRM, QRY->GCY_CODCRM,),; //19
		QRY->GBJ_CIC,; // 20
		QRY->RA_NOME,; //21
		QRY->GD1_CATISS ,; //22
		SubStr(GCW->GCW_TITISS, 2, 1),; //23
		QRY->GCY_REGIME,; //24
		QRY->GE8_QTDIAS,; //25
		QRY->GE8_INDCLI,; // 26
		IIf(QRY->GCZ_TDTISS == "0", "A", "C"),; //27
		{0,""},;          //28
		"",;          //29
		QRY->GCY_CIDALT  ,; //30
		QRY->GCY_CIDCMP  ,; //31
		""               ,; //32
		""               ,; //33
		aVetTab[1]     	,;  //34
		aVetPr[1]		,;//{aCPR[1,1]}       ,;  //35
		aVetPr[2]		,;//{aCPR[1,2]}       ,;  //36
		aVetPr[3]		,;	//{aCPR[1,3]}       ,;  //37
		aVetPr[4]		,;//{aCPR[1,4]}       ,;  //38
		{},;                //39
		{},;                //40
		{},;                //41
		{},;                //42
		{},;                //43
		{},;                //44
		STOD(QRY->GE8_ADMHOS),; //45
		QRY->GE8_QTDLIB,; //46
		{QRY->GE8_TPDIAR, ""},; //47
		HS_RetOper(, QRY->GCZ_CODTPG, QRY->GA9_CODCON)[2],;  //48
		aSM0Dados[1, 2] ,; //49
		aSM0Dados[1, 8] ,; //50
		"",; //51
		CTOD("") ,; //52
		CTOD("") ,; //53
		CTOD("") ,; //54
		{STOD(QRY->GE8_DATSOL)},; //55
		{""},;  // 56
		{QRY->GE8_RESAUT},; //57
		{""},; //58
		{""},; //59
		{QRY->GE8_QTDLIB},; //60
		{}       ,;  //61
		{},;//aVetPr[1],;//{{aCPR[1,1]}}       ,;  //62
		{},;//aVetPr[2],;//{{aCPR[1				,2]}}       ,;  //63
		{},;//aVetPr[3],;//{{aCPR[1,3]}}       ,;  //64
		{},;//aVetPr[4],;//{{aCPR[1,4]}}       ,;  //65
		{},;                //66
		{},;                //67
		{},;                //68
		{},;                //69
		{},;                //70
		{}}}                //71

		DbSelectArea("QRY")
		QRY->(DbCloseArea())

		PLSTISS3(aSolInte, lVsTISS, nLayout, cLogoGH)
	Else

		cCBO = HS_RetCBO(QRY->GCZ_CODCRM, QRY->GCY_CODCRM,)

		aVetPr[2] := AClone(aVetPr[1])

		aVetTab[1] := HS_AJUSTIS(aVetTab[1], "BTU_CDTERM", "GDB", .F., "87")
		aVetPr[1] := HS_AJUSTIS(aVetPr[1], "BTU_CDTERM", "GA7", .F., "22")
		aVetPr[2] := HS_AJUSTIS(aVetPr[2], "BTQ_DESTER", "GA7", .F., "22")

		aSolInte := {{QRY->GA9_CODOPE		,; //1
					  QRY->GCZ_NRGUIA		,; //2
					  GCZ->GCZ_GUIAOP		,; //3
					  STOD(QRY->GCZ_DATAUT) ,; //4
					  QRY->GCZ_NRSEN1       ,; //5
					  STOD(QRY->GCZ_VALSEN) ,; //6
					  QRY->GD4_MATRIC       ,; //7
					  STOD(QRY->GD4_DTVALI) ,; //8
					  QRY->GCY_ATERN		,; //9
					  QRY->GBH_NOME         ,; //10
					  QRY->GBH_NUMCNS       ,; //11
					  HS_RetOper(, QRY->GCZ_CODTPG, QRY->GA9_CODCON)[2],;  //12
					  aSM0Dados[1, 2]       ,; //13
					  QRY->RA_NOME			,; //14
					  IIF(Empty(ALLTRIM(QRY->GBJ_CONSEL)), "", PLSGETVINC("BTU_CDTERM", "BAH", .F., "26", ALLTRIM(QRY->GBJ_CONSEL))),; //15
					  QRY->RA_CODIGO		,; //16
					  IIF(Empty(ALLTRIM(QRY->GBJ_UFCONS)), "", PLSGETVINC("BTU_CDTERM", "SX5", .F., "59", "12"+ALLTRIM(QRY->GBJ_UFCONS))),; //17
					  IIF(Empty(ALLTRIM(cCBO)),            "", PLSGETVINC("BTU_CDTERM", "GN1", .F., "24", ALLTRIM(cCBO))),; //18
					  QRY->GBJ_CIC			,; //19
					  QRY->RA_NOME			,; //20
					  GCZ->GCZ_DTSUGE		,; //21
					  IIF(Empty(ALLTRIM(QRY->GD1_CARATE)), "", PLSGETVINC("BTU_CDTERM", "GD1", .F., "23", ALLTRIM(QRY->GD1_CARATE))),; //22
					  IIF(Empty(ALLTRIM(GCW->GCW_CODCLI)), "", PLSGETVINC("BTU_CDTERM", "G05", .F., "57", ALLTRIM(GCW->GCW_TITISS))),; //23
					  IIF(Empty(ALLTRIM(QRY->GCY_REGIME)), "", PLSGETVINC("BTU_CDTERM", "   ", .F., "41", ALLTRIM(QRY->GCY_REGIME))),; //24
					  QRY->GE8_QTDIAS		,; //25
					  QRY->GCZ_USOOPM		,; //26
					  QRY->GCZ_USOQUI       ,; //27
					  QRY->GE8_INDCLI		,; //28
					  QRY->GCY_CIDALT  		,; //29
					  QRY->GCY_CIDCMP  		,; //30
					  ""               		,; //31
					  ""               		,; //32
					  IIF(Empty(ALLTRIM(QRY->GCZ_IATISS)), "", PLSGETVINC("BTU_CDTERM", "   ", .F., "36", ALLTRIM(QRY->GCZ_IATISS))),; //33
					  aVetTab[1]			,; //34
					  aVetPr[1]				,; //35
					  aVetPr[2]				,; //36
					  aVetPr[3]				,; //37
					  aVetPr[4]				,; //38
					  STOD(QRY->GE8_ADMHOS)	,; //39
					  QRY->GE8_QTDLIB		,; //40
					  IIF(Empty(ALLTRIM(QRY->GE8_TPDIAR)), "", PLSGETVINC("BTU_CDTERM", "   ", .F., "49", ALLTRIM(QRY->GE8_TPDIAR))),; //41
					  HS_RetOper(, QRY->GCZ_CODTPG, QRY->GA9_CODCON)[2],;  //42
					  aSM0Dados[1, 2] 		,; //43
					  aSM0Dados[1, 8] 		,; //44
					  ""					,; //45
					  CtoD("")				,; //46
					  ""					,; //47
					  ""					,; //48
					  ""					} } //49

		DbSelectArea("QRY")
		QRY->(DbCloseArea())

		PLSTISSE(aSolInte, lVsTISS, nLayout, cLogoGH)

	EndIf

	RestArea(aArea)
Return(.T.)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ Hs_ImpRInt ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Impressao da guia de Resumo de Internacao do TISS             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Sequencial da guia                                     ³±±
	±±³          ³ExpC2: Alias da tabela de despesa de Mat/Med             (OPC)³±±
	±±³          ³ExpC3: Alias da tabela de despesa de Tax/Dia             (OPC)³±±
	±±³          ³ExpC4: Alias da tabela de despesa de Procedimentos       (OPC)³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function Hs_ImpRInt(cNrSeqG, cAliasG5, cAliasG6, cAliasG7)
	Local aCposMM   := {}
	Local aCMM      := {}
	Local aHMM      := {}
	Local aCposTD   := {}
	Local aCTD      := {}
	Local aHTD      := {}
	Local aVetMMTD  := {}
	Local aVetPR	   := {}
	Local nUMM := 0
	Local nUTD := 0
	Local aHPR := {}, ACPR := {}, nUPR := 0

	Local aSeqRef   := {}
	Local nSeqRef    := 1
	Local aGBJCPF   := {}
	Local aSRAMED   := {}
	Local aSRACOD   := {}
	Local aGBJCON   := {}
	Local aGBJUFC   := {}
	Local aGBJCIC   := {}
	Local aGBJCBO   := {}
	Local aTotMMTD  := {}
	Local nTotMMTD  := 0
	Local aInteObs  := {}
	Local aResInte  := {}
	Local aValUni55 := {}
	Local aValTot56 := {}
	Local nTotMMTD  := 0
	Local nValTot74 := 0
	Local nTotDia75 := 0
	Local nTotTA76  := 0
	Local nTotMat77 := 0
	Local nTotMed78 := 0
	Local nTotGas79 := 0
	Local nTotGerRI := 0

	Local nForCol 	:= 0, nForLin := 0
	Local cRegAte		:= ""
	Local cPaciente 	:= ""
	Local cCodPla   	:= ""
	Local ASM0DADOS 	:= {}
	Local cCodDes 	:= ""
	Local dDatDes 	:= StoD("")
	Local aRVldVig 	:= {{"","GC1_FAUINT"}}

	Local lSeekRN 	:= .F.
	Local cTissVer 	:= GetNewPar("MV_TISSVER", "2.02.03")

	Default cAliasG5 	:= ""
	Default cAliasG6 	:= ""
	Default cAliasG7 	:= ""

	IIF(Alias()         # "GCZ"  , DbSelectArea("GCZ"), Nil)
	IIF(IndexOrd()      # 1      , DbSetOrder(1), Nil) // GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
	IIF(GCZ->GCZ_NRSEQG # cNrSeqG, DbSeek(xFilial("GCZ") + cNrSeqG), Nil)

	cRegAte   := IIF(!Empty(cRegAte)  ,cRegAte  , GCZ->GCZ_REGATE)
	cPaciente := IIF(!Empty(cPaciente),cPaciente, GCZ->GCZ_REGGER)
	cCodPla   := IIF(!Empty(cCodPla)  ,cCodPla  , GCZ->GCZ_CODPLA)

	cAliasG5  := IIF(!Empty(cAliasG5) ,cAliasG5 , IIF(GCZ->GCZ_STATUS < "2", "GD5", "GE5"))
	cAliasG6  := IIF(!Empty(cAliasG6) ,cAliasG6 , IIF(GCZ->GCZ_STATUS < "2", "GD6", "GE6"))
	cAliasG7  := IIF(!Empty(cAliasG7) ,cAliasG7 , IIF(GCZ->GCZ_STATUS < "2", "GD7", "GE7"))

	IIF(Alias()         # "GCY"  , DbSelectArea("GCY"), Nil)
	IIF(IndexOrd()      # 1      , DbSetOrder(1), Nil)// GCY_FILIAL+GCY_REGATE
	IIf(GCY->GCY_REGATE # cRegAte, lSeekRN := DbSeek(xFilial("GCY") + cRegAte), Nil)

	If Empty(aSM0Dados)
		nRECNOSM0 := SM0->(RecNo())
		If !Empty(GCZ->GCZ_FILFAT)
			DbSelectArea("SM0")
			DbSetOrder(1)  // M0_CODIGO + M0_CODFIL
			DbSeek(IIF(FindFunction("FWGRPCompany"), FWGRPCompany(),SM0->M0_CODIGO) + GCZ->GCZ_FILFAT)
		EndIf
		aAdd(aSM0Dados, {SM0->M0_CGC, SM0->M0_NOMECOM, SM0->M0_ENDENT, SM0->M0_COMPENT, SM0->M0_CIDENT, SM0->M0_ESTENT, SM0->M0_CEPENT, GETMV("MV_HSPCNES") })
		SM0->(DbGoTo(nRECNOSM0))
	EndIf

	IIF(Alias()         # "GD4", DbSelectArea("GD4"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GD4_FILIAL + GD4_REGGER + GD4_CODPLA
	DbSeek(xFilial("GD4") + cPaciente + cCodPla)

	IIF(Alias()         # "GCM", DbSelectArea("GCM"), Nil)
	IIF(IndexOrd()      # 2, DbSetOrder(2), Nil) // GCM_FILIAL + GCM_CODPLA
	IIF(GCM->GCM_CODPLA # cCodPla, DbSeek(xFilial("GCM") + cCodPla), Nil)

	IIF(Alias()         # "GA9", DbSelectArea("GA9"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GA9_FILIAL+GA9_CODCON
	IIF(GA9->GA9_CODCON # GCM->GCM_CODCON, DbSeek(xFilial("GA9") + GCM->GCM_CODCON), Nil)
	cLogoGH := GA9->GA9_LOGOTP

	IIF(Alias()         # "GBH", DbSelectArea("GBH"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GBH_FILIAL + GBH_CODPAC
	IIF(GBH->GBH_CODPAC # cPaciente, DbSeek(xFilial("GBH") + cPaciente), Nil)

	IIF(Alias()         # "GF4", DbSelectArea("GF4"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)   // GF4_FILIAL + GF4_TPALTA
	IIF(GF4->GF4_TPALTA # GCY->GCY_TPALTA, DbSeek(xFilial("GF4") + GCY->GCY_TPALTA), Nil)

	IIF(Alias()         # "GAM", DbSelectArea("GAM"), Nil)
	IIF(IndexOrd()      # 3, DbSetOrder(3), Nil) // GAM_FILIAL + GAM_CEP
	IIF(GAM->GAM_CEP    # SM0->M0_CEPCOB, DbSeek(xFilial("GAM") + SM0->M0_CEPCOB), Nil)

	IIF(Alias()         # "GD1", DbSelectArea("GD1"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GD1_FILIAL + GD1_CARATE
	IIF(GD1->GD1_CARATE # GCY->GCY_CARATE, 	DbSeek(xFilial("GD1") + GCY->GCY_CARATE), Nil)

	IIF(Alias()         # "GBJ", DbSelectArea("GBJ"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)  //GBJ_FILIAL + GBJ_CRM
	IIF(GBJ->GBJ_CRM    # GCZ->GCZ_CODCRM, DbSeek(xFilial("GBJ") + GCZ->GCZ_CODCRM), Nil)

	IIF(Alias()         # "SRA", DbSelectArea("SRA"), Nil)
	IIF(IndexOrd()      # 11, DbSetOrder(11), Nil) // RA_FILIAL + RA_CODIGO
	IIF(SRA->RA_CODIGO  #  GCZ->GCZ_CODCRM, DbSeek(xFilial("SRA") +  GCZ->GCZ_CODCRM), Nil)

	IIF(Alias()         # "GCW", DbSelectArea("GCW"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)   //GCW_FILIAL + GCW_CODCLI
	IIF(GCW->GCW_CODCLI # GCY->GCY_CODCLI, DbSeek(xFilial("GCW") + GCY->GCY_CODCLI), Nil)

	IIF(Alias()         # "GB2", DbSelectArea("GB2"), Nil)
	IIF(IndexOrd()      # 2, DbSetOrder(2), Nil) // GB2_FILIAL + GB2_REGATE
	IIF(GB2->GB2_REGATE # GCY->GCY_REGATE, DbSeek(xFilial("GB2") + GCY->GCY_REGATE), Nil)

	IIF(Alias()         # "GAV", DbSelectArea("GAV"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GAV_FILIAL + GAV_CODLOC + GAV_QUARTO + GAV_LEITO
	IIF(GAV->GAV_CODLOC + GAV->GAV_QUARTO + GAV->GAV_LEITO # GCY->GCY_CODLOC + GCY->GCY_QUAINT + GCY->GCY_LEIINT, DbSeek(xFilial("GAV") + GCY->GCY_CODLOC + GCY->GCY_QUAINT + GCY->GCY_LEIINT), Nil)

	aCposMM := {cAliasG5 + "_SEQDES", cAliasG5 + "_TABELA", cAliasG5 + "_CODPRO", cAliasG5 + "_DESPRO", cAliasG5 + "_QTDDES",;
		cAliasG5 + "_VALDES", cAliasG5 + "_CODDES", cAliasG5 + "_GLODES", cAliasG5 + "_DATDES"}

	aCposTD := {cAliasG6 + "_SEQDES", cAliasG6 + "_TABELA", cAliasG6 + "_CODTXC", cAliasG6 + "_DESTXC", cAliasG6 + "_QTDDES",;
		cAliasG6 + "_VALDES", cAliasG6 + "_CODDES", cAliasG6 + "_GLODES", cAliasG6 + "_DATDES"}

	aCposPR := {cAliasG7 + "_CODPRT", cAliasG7 + "_DESPRT", cAliasG7 + "_DATDES", cAliasG7 + "_HORDES", cAliasG7 + "_HORFIM",;
		cAliasG7 + "_QTDDES", cAliasG7 + "_TABELA", cAliasG7 + "_CODVIA", cAliasG7 + "_CODATO", cAliasG7 + "_CODCRM",;
		cAliasG7 + "_COEDES", cAliasG7 + "_PGTMED", cAliasG7 + "_CODDES", cAliasG7 + "_VALDES", cAliasG7 + "_SEQDES",;
		cAliasG7 + "_GLODES", cAliasG7 + "_TECUTI", cAliasG7 + "_COEDES", cAliasG7 + "_URGDES"}

	HS_BDados(cAliasG5, @aHMM, @aCMM, @nUMM, 2,, cAliasG5 + "->" + cAliasG5 + "_NRSEQG == '" + cNrSeqG + "'",,, "/",,,,,,.T.,,,,,, aCposMM)
	HS_BDados(cAliasG6, @aHTD, @aCTD, @nUTD, 2,, cAliasG6 + "->" + cAliasG6 + "_NRSEQG == '" + cNrSeqG + "'",,, "/",,,,,,.T.,,,,,, aCposTD)
	HS_BDados(cAliasG7, @aHPR, @aCPR, @nUPR, 2,, cAliasG7 + "->" + cAliasG7 + "_NRSEQG == '" + cNrSeqG + "'",,, "/",,,,,,.T.,,,,,, aCposPR)

	If GA9->GA9_RESINT $ "1/2"
		aSort(aCMM,,,{|x,y| x[7]+DTOS(x[9]) < y[7]+DTOS(y[9])})
		aSort(aCTD,,,{|x,y| x[7]+DTOS(x[9]) < y[7]+DTOS(y[9])})
	EndIf

	//Procedimentos
	For nForCol := 1 To nUPR
		AADD(aVetPR, {})
		For nForLin := 1 To Len(aCPR)
			DbSelectArea("GA7")
			DbSetOrder(1) //GA7_FILIAL + GA7_CODPRO
			DbSeek(xFilial("GA7") + aCPR[nForLin, 13])
			If lSomaProc := ((GA7->GA7_TIPPRO $ "3/6/8" .Or. (GA7->GA7_TIPPRO $ "1/9" .And. GA7->GA7_HONORA == "1" .And. aCPR[nForLin, 12] <> "0")) .And. !Empty(aCPR[nForLin, 1]) .And. aCPR[nForLin, 16] == "0")
				ASize(aVetPR[nForCol], Len(aVetPR[nForCol]) + 1)
				If nForCol == 3
					aVetPR[nForCol, Len(aVetPR[nForCol])] := aCPR[nForLin, nForCol]
				ElseIf nForCol == 7 .AND. cTissVer < "3"
					DbSelectArea("GDB")
					DbSetOrder(1) //GDB_FILIAL + GDB_CHAVE
					If !Empty(aCPR[nForLin, 7]) .And. DbSeek(xFilial("GDB") + aCPR[nForLin, 7])
						IIF(!Empty(GDB->GDB_TBTISS), aVetPR[nForCol, Len(aVetPR[nForCol])] := GDB->GDB_TBTISS, aVetPR[nForCol, Len(aVetPR[nForCol])] := "00")
					Else
						IIF(!Empty(GA9->GA9_TBTISS), aVetPR[nForCol, Len(aVetPR[nForCol])] := GA9->GA9_TBTISS, aVetPR[nForCol, Len(aVetPR[nForCol])] := "00")
					EndIf
				ElseIf nForCol == 9
					DbSelectArea("GMC")
					DbSetOrder(1) //GMC_FILIAL + GMC_CODATO + GMC_IDEATI
					DbSeek(xFilial("GMC") + aCPR[nForLin, 9])
					IIF(!Empty(GMC->GMC_PPTISS), aVetPR[nForCol, Len(aVetPR[nForCol])] := GMC->GMC_PPTISS,  IIF(GA7->GA7_TIPPRO == "1" .Or. GA7->GA7_TIPPRO == "9", aVetPR[nForCol, Len(aVetPR[nForCol])] := "12", aVetPR[nForCol, Len(aVetPR[nForCol])] := "11")) // Quando 1-Honorario ou 9-Pacote informar 12 (Clinico) senão informar 11 (Auxiliar SADT)
				ElseIf nForCol == 11
					aVetPR[nForCol, Len(aVetPR[nForCol])] := IIF(aCPR[nForLin, 11] == 1.00, "U", IIF(aCPR[nForLin, 11] == 0.70, "D", IIF(aCPR[nForLin, 11] == 0.50, "M", "U")))
				Else
					aVetPR[nForCol, Len(aVetPR[nForCol])] := aCPR[nForLin, nForCol]
				EndIf
				If nForCol == 1
					DbSelectArea("SRA")
					DbSetOrder(11) // RA_FILIAL + RA_CODIGO
					DbSeek(xFilial("SRA") + aCPR[nForLin, 10])

					DbSelectArea("GBJ")
					DbSetOrder(1)  //GBJ_FILIAL + GBJ_CRM
					DbSeek(xFilial("GBJ") + aCPR[nForLin, 10])
					aAdd(aSeqRef, Str(nSeqRef++))
					aAdd(aGBJCPF, GBJ->GBJ_CIC)
					aAdd(aSRAMED, SRA->RA_NOME)
					aAdd(aSRACOD, SRA->RA_CODIGO)
					aAdd(aGBJCON, GBJ->GBJ_CONSEL)
					aAdd(aGBJUFC, GBJ->GBJ_UFCONS)
					aAdd(aGBJCIC, GBJ->GBJ_CIC)
					aAdd(aGBJCBO, GBJ->GBJ_CBOTIS)
				EndIf
				If nForCol == 14
					aAdd(aValUni55,aCPR[nForLin, nForCol])
					aAdd(aValTot56,aCPR[nForLin, nForCol] * aVetPR[6,nForLin])
					nValTot74 += aValTot56[nForLin]
					
				EndIf
				If nForCol == 19
					If !Empty(aCPR[nForLin, nForCol]) .AND. aCPR[nForLin, nForCol] == "1"
						HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + cCodPla + "'", "GC1_DATVIG", @aRVldVig, dDataBase)
						aVetPR[nForCol, Len(aVetPR[nForCol])] := IIf(!Empty(aRVldVig[1,1]),Iif(aRVldVig[1,1]>0,(aRVldVig[1,1]-1)*100,0),0)
					Else
						If !(nForCol > Len(aVetPR))
							aVetPR[nForCol, Len(aVetPR[nForCol])] := 0
						EndIf
					EndIf
				EndIf
			Else
				If nForCol == 14
					aAdd(aValTot56,0)
					aAdd(aVetPR[6],0)
				EndIf
			EndIf
			// Acumuladores
			If !Empty(aCPR[nForLin, 1]) .And. aCPR[nForLin, 12] <> "0" .And. nForCol == 14 .And. aCPR[nForLin, 16] == "0"
				DbSelectArea("G20")
				DbSetOrder(1) //G20_FILIAL + G20_CITISS
				DBSeek(xFilial("G20") + GA7->GA7_CITISS)
				If lSomaProc
					//aAdd(aValUni55, IIf(val(GA9->GA9_TISSRD) < 2, 0, Round(HS_CValDes(cAliasG7, aCPR[nForLin, 15],,, .T.), 2)))
					//aAdd(aValTot56, IIf(val(GA9->GA9_TISSRD) < 2, 0, HS_CValDes(cAliasG7, aCPR[nForLin, 15])))
					aValUni55[nForLin] += IIf(val(GA9->GA9_TISSRD) < 2, 0, Round(HS_CValDes(cAliasG7, aCPR[nForLin, 15],,, .T.), 2))
					aValTot56[nForLin] += IIf(val(GA9->GA9_TISSRD) < 2, 0, HS_CValDes(cAliasG7, aCPR[nForLin, 15]))
					nValTot74 += IIf(val(GA9->GA9_TISSRD) < 2, 0, HS_CValDes(cAliasG7, aCPR[nForLin, 15]))

				Else

					If G20->G20_CODXML $ "04/06"
						nTotTA76 += IIf(val(GA9->GA9_TISSRD) < 2, 0, HS_CValDes(cAliasG7, aCPR[nForLin, 15]))
					ElseIf G20->G20_CODXML == "03"
						nTotMat77 += IIf(val(GA9->GA9_TISSRD) < 2, 0, HS_CValDes(cAliasG7, aCPR[nForLin, 15]))
					ElseIf G20->G20_CODXML == "02"
						nTotMed78 += IIf(val(GA9->GA9_TISSRD) < 2, 0, HS_CValDes(cAliasG7, aCPR[nForLin, 15]))
					ElseIf G20->G20_CODXML == "05"
						nTotDia75 += IIf(val(GA9->GA9_TISSRD) < 2, 0, HS_CValDes(cAliasG7, aCPR[nForLin, 15]))
					ElseIf G20->G20_CODXML == "01"
						nTotGas79 += IIf(val(GA9->GA9_TISSRD) < 2, 0, HS_CValDes(cAliasG7, aCPR[nForLin, 15]))
					EndIf

				EndIf
				nTotGerRI += IIf(val(GA9->GA9_TISSRD) < 2, 0, HS_CValDes(cAliasG7, aCPR[nForLin, 15]))
			Else
				aAdd(aValUni55,0)
			EndIf
		Next
	Next
	nTotGerRI += nValTot74
	//Mat/Med
	For nForCol := 1 To nUMM
		cCodDes := ""
		dDatDes := StoD("")
		AADD(aVetMMTD, {})
		For nForLin := 1 To Len(aCMM)
			If !Empty(aCMM[nForLin, 3])
				DbSelectArea("GBI")
				DbSetOrder(1) //GBI_FILIAL + GBI_PRODUT
				If DbSeek(xFilial("GBI") + aCMM[nForLin, 7]) .And. !Empty(GBI->GBI_CITISS)
					DbSelectArea("G20")
					DbSetOrder(1)  // G20_FILIAL + G20_CODIGO
					DbSeek(xFilial("G20") + GBI->GBI_CITISS)

					If G20->G20_CODXML == "11" .And. aCMM[nForLin, 8] == "0" // classificacao do item == 11 e o campo _GLODES == normal

						If GA9->GA9_RESINT $ "1/2" .And. cCodDes == aCMM[nForLin, 7] .And. IIF(GA9->GA9_RESINT == "2",.T.,	dDatDes == aCMM[nForLin, 9]) .And. Len(aCMM) >1

							If nForCol == 1
								aTotMMTD[len(aTotMMTD)] += HS_CValDes(cAliasG5, aCMM[nForLin, 1])
								nTotMMTD += HS_CValDes(cAliasG5, aCMM[nForLin, 1])
							ElseIf nForCol == 5
								aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] += aCMM[nForLin, nForCol]
							EndIf

						Else
							ASize(aVetMMTD[nForCol], Len(aVetMMTD[nForCol]) + 1)
							If nForCol == 2 .AND. cTissVer < "3"
								DbSelectArea("GCA")
								DbSetOrder(1) //GCA_FILIAL + GCA_CODTAB
								If !Empty(aCMM[nForLin, 2]) .And. DbSeek(xFilial("GCA") + aCMM[nForLin, 2])
									aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := IIF(!Empty(GCA->GCA_TBTISS), GCA->GCA_TBTISS, "00")
								Else
									aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := IIF(!Empty(GA9->GA9_TBTISS), GA9->GA9_TBTISS, "00")
								EndIf
							Else
								aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := aCMM[nForLin, nForCol]
							EndIf
							If nForCol == 1
								aAdd(aTotMMTD, HS_CValDes(cAliasG5, aCMM[nForLin, 1]))
								nTotMMTD += HS_CValDes(cAliasG5, aCMM[nForLin, 1])
							EndIf
						EndIf
					EndIf

					If nForCol == 6 .And. aCMM[nForLin, 8] == "0"
						If G20->G20_CODXML $ "04/06/09"
							nTotTA76 += HS_CValDes(cAliasG5, aCMM[nForLin, 1])
						ElseIf G20->G20_CODXML == "03"
							nTotMat77 += HS_CValDes(cAliasG5, aCMM[nForLin, 1])
						ElseIf G20->G20_CODXML == "02"
							nTotMed78 += HS_CValDes(cAliasG5, aCMM[nForLin, 1])
						ElseIf G20->G20_CODXML == "05"
							nTotDia75 += HS_CValDes(cAliasG5, aCMM[nForLin, 1])
						ElseIf G20->G20_CODXML == "01"
							nTotGas79 += HS_CValDes(cAliasG5, aCMM[nForLin, 1])
						EndIf
						nTotGerRI += HS_CValDes(cAliasG5, aCMM[nForLin, 1])
					EndIf
					cCodDes := aCMM[nForLin, 7]
					dDatDes := aCMM[nForLin, 9]
				Else
					HS_MsgInf(STR0012 + AllTrim(aCMM[nForLin, 7]) + STR0013, STR0002, STR0014) //"A despesa "###" não está com a classificação do item preenchida."###"Atenção"###"Validação da Guia TISS"
				Return(.F.)
				EndIf
			EndIf
		Next
	Next

	//Tax/Dia
	For nForCol := 1 To nUTD
		cCodDes := ""
		dDatDes := StoD("")
		For nForLin := 1 To Len(aCTD)
			If !Empty(aCTD[nForLin, 3])
				DbSelectArea("GAA")
				DbSetOrder(1) //GAA_FILIAL + GAA_CODTXD
				If DbSeek(xFilial("GAA") + aCTD[nForLin, 7]) .And. !Empty(GAA->GAA_CITISS)
					DbSelectArea("G20")
					DbSetOrder(1) // G20_FILIAL + G20_CODIGO
					DbSeek(xFilial("G20") + GAA->GAA_CITISS)
					If G20->G20_CODXML == "11" .And. aCTD[nForLin, 8] == "0"

						If GA9->GA9_RESINT $ "1/2" .And. cCodDes == aCTD[nForLin, 7] .And. IIF(GA9->GA9_RESINT == "2",.T.,	dDatDes == aCTD[nForLin, 9]) .And. Len(aCTD) >1

							If nForCol == 1
								aTotMMTD[len(aTotMMTD)] += HS_CValDes(cAliasG6, aCTD[nForLin, 1])
								nTotMMTD += HS_CValDes(cAliasG6, aCTD[nForLin, 1])
							ElseIf nForCol == 5
								aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] += aCTD[nForLin, nForCol]
							EndIf

						Else
							ASize(aVetMMTD[nForCol], Len(aVetMMTD[nForCol]) + 1)
							If nForCol == 2 .AND. cTissVer < "3"
								DbSelectArea("GD2")
								DbSetOrder(1) //GD2_FILIAL + GD2_CODTAB
								If !Empty(aCTD[nForLin, 2]) .And. DbSeek(xFilial("GD2") + aCTD[nForLin, 2])
									aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := IIF(!Empty(GD2->GD2_TBTISS), GD2->GD2_TBTISS, "00")
								Else
									aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := IIF(!Empty(GA9->GA9_TBTISS), GA9->GA9_TBTISS, "00")
								EndIf
							Else
								aVetMMTD[nForCol, Len(aVetMMTD[nForCol])] := aCTD[nForLin, nForCol]
							EndIf
							If nForCol == 1
								aAdd(aTotMMTD, HS_CValDes(cAliasG6, aCTD[nForLin, 1]))
								nTotMMTD += HS_CValDes(cAliasG6, aCTD[nForLin, 1])
							EndIf
						EndIf
					EndIf
					If nForCol == 6 .And. aCTD[nForLin, 8] == "0"
						If G20->G20_CODXML $ "04/06"
							nTotTA76 += HS_CValDes(cAliasG6, aCTD[nForLin, 1])
						ElseIf G20->G20_CODXML == "03"
							nTotMat77 += HS_CValDes(cAliasG6, aCTD[nForLin, 1])
						ElseIf G20->G20_CODXML == "02"
							nTotMed78 += HS_CValDes(cAliasG6, aCTD[nForLin, 1])
						ElseIf G20->G20_CODXML == "05"
							nTotDia75 += HS_CValDes(cAliasG6, aCTD[nForLin, 1])
						ElseIf G20->G20_CODXML == "01"
							nTotGas79 += HS_CValDes(cAliasG6, aCTD[nForLin, 1])
						EndIf
						nTotGerRI += HS_CValDes(cAliasG6, aCTD[nForLin, 1])
					EndIf
					cCodDes := aCTD[nForLin, 7]
					dDatDes := aCTD[nForLin, 9]
				Else
					HS_MsgInf(STR0012 + AllTrim(aCTD[nForLin, 7]) + STR0013, STR0002, STR0014) //"A despesa "###" não está com a classificação do item preenchida."###"Atenção"###"Validação da Guia TISS"
				Return(.F.)
				EndIf
			EndIf
		Next
	Next

	If GCW->GCW_TITISS == "03" // OBSTETRICIA
		IIF(!Empty(GCY->GCY_GESTAC) .And. GCY->GCY_GESTAC <> "0", aAdd(aInteObs, "X"), aAdd(aInteObs, ""))          //Em Gestacao
		IIF(!Empty(GCY->GCY_ABORTO) .And. GCY->GCY_ABORTO <> "0", aAdd(aInteObs, "X"), aAdd(aInteObs, ""))          //Aborto
		IIF(!Empty(GCY->GCY_TRAMAT) .And. GCY->GCY_TRAMAT <> "0", aAdd(aInteObs, "X"), aAdd(aInteObs, ""))          //Transtorno Materno
		IIF(!Empty(GCY->GCY_COMPUE) .And. GCY->GCY_COMPUE <> "0", aAdd(aInteObs, "X"), aAdd(aInteObs, ""))          //Complic Puerpeio
		IIF(!Empty(GB2->GB2_ATSALA) .And. GB2->GB2_ATSALA <> "0", aAdd(aInteObs, "X"), aAdd(aInteObs, ""))          //Atend RN
		IIF(!Empty(GB2->GB2_UTINEO) .And. GB2->GB2_UTINEO <> "0", aAdd(aInteObs, "X"), aAdd(aInteObs, ""))          //C. Neonatal
		IIF(!Empty(GB2->GB2_PESO)   .And. GB2->GB2_PESO < 2.5   , aAdd(aInteObs, "X"), aAdd(aInteObs, ""))          //Bx Peso
		IIF(!Empty(GB2->GB2_TIPO)   .And. GB2->GB2_TIPO <> "0"  , aAdd(aInteObs, "X"), aAdd(aInteObs, ""))          //Parto Cesareo
		IIF(!Empty(GB2->GB2_TIPO)   .And. GB2->GB2_TIPO == "1"  , aAdd(aInteObs, "X"), aAdd(aInteObs, ""))          //Parto Normal
	else
		aAdd(aInteObs, "")          //Em Gestacao
		aAdd(aInteObs, "")          //Aborto
		aAdd(aInteObs, "")          //Transtorno Materno
		aAdd(aInteObs, "")          //Complic Puerpeio
		aAdd(aInteObs, "")          //Atend RN
		aAdd(aInteObs, "")          //C. Neonatal
		aAdd(aInteObs, "")          //Bx Peso
		aAdd(aInteObs, "")          //Parto Cesareo
		aAdd(aInteObs, "")          //Parto Normal
	EndIf

	If cTissVer < "3"

		aResInte := {{GA9->GA9_CODOPE ,; //1
		GCZ->GCZ_NRGUIA ,; //2
		GCZ->GCZ_GUIAPR ,; //3
		GCZ->GCZ_DATAUT ,; //4
		GCZ->GCZ_NRSEN1 ,; //5
		GCZ->GCZ_VALSEN ,; //6
		GCY->GCY_DATATE          ,; //7
		GD4->GD4_MATRIC          ,; //8
		GCM->GCM_DESPLA          ,; //9
		GD4->GD4_DTVALI          ,; //10
		GBH->GBH_NOME            ,; //11
		GBH->GBH_NUMCNS          ,; //12
		HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2],; //13
		aSM0Dados[1, 2]          ,; //14
		aSM0Dados[1, 8]          ,; //15
		GAM->GAM_TIPLOG    ,; //16
		aSM0Dados[1, 3] + " " + aSM0Dados[1, 4],; //17
		""                                     ,;     //18
		""                                     ,;     //19
		aSM0Dados[1, 5] ,; //20
		aSM0Dados[1, 6] ,; //21
		SM0->M0_CODMUN  ,; //22
		aSM0Dados[1, 7] ,; //23
		GD1->GD1_CATISS ,; //24
		{GAV->GAV_TATISS, HS_IniPadR("G07", 1, GAV->GAV_TATISS, "G07_DESCRI")},; //25
		{GCY->GCY_DATATE, GCY->GCY_HORATE},; //26
		IIf(Empty(GCY->GCY_DATALT), {GCZ->GCZ_DCPARF, ""}, {GCY->GCY_DATALT, GCY->GCY_HORALT}),; //27
		SubStr(GCW->GCW_TITISS, 2, 1)     ,; //28
		GCY->GCY_REGIME    ,; //29
		aInteObs           ,; //30
		GCY->GCY_OBIMUL    ,; //31
		{GCZ->GCZ_OBNEOP,GCZ->GCZ_OBNEOT}  ,; //32
		GB2->GB2_NRODEC    ,; //33
		IIF(!Empty(GCZ->GCZ_RNNVIV), STRZERO(GCZ->GCZ_RNNVIV, 2), ""),; //34
		IIF(!Empty(GCZ->GCZ_RNNOBI), STRZERO(GCZ->GCZ_RNNOBI, 2), ""),; //35
		GCZ->GCZ_RNVPRE  ,; //36
		HS_RetCID(GCY->GCY_REGATE, GCZ->GCZ_CODCON, "GA9_ICIDRI", "1"),; //37
		HS_RetCID(GCY->GCY_REGATE, GCZ->GCZ_CODCON, "GA9_ICIDRI", "2"),; //38
		HS_RetCID(GCY->GCY_REGATE, GCZ->GCZ_CODCON, "GA9_ICIDRI", "3"),; //39
		""                 ,;  //40
		GCZ->GCZ_IATISS  ,; //41
		Posicione("GF4", 1, xFilial("GF4")+IIf(Empty(GCY->GCY_TPALTA),GCZ->GCZ_TPALTA, GCY->GCY_TPALTA),"GF4_TSTISS") ,; //42
		IIF(!Empty(GCY->GCY_CIDALT) .And. GCY->GCY_CIDALT $ GETMV("MV_TPALTA"), GCY->GCY_CIDALT, ""),; //43
		GCY->GCY_OBTDOC    ,; //44
		aVetPR[3]          ,; //45
		aVetPR[4]          ,; //46
		aVetPR[5]          ,; //47
		aVetPR[7]          ,; //48
		aVetPR[1]          ,; //49
		aVetPR[2]          ,; //50
		aVetPR[6]          ,; //51
		aVetPR[11]         ,; //52
		aVetPR[17]         ,; //53
		aVetPR[19]         ,; //54
		aValUni55          ,; //55
		aValTot56          ,; //56
		aSeqRef            ,; //57
		aVetPR[9]          ,; //58
		aGBJCPF            ,; //59
		aSRAMED            ,; //60
		aGBJCON            ,; //61
		aSRACOD            ,; //62
		aGBJUFC            ,; //63
		aGBJCIC            ,; //64
		aVetMMTD[2]        ,; //65
		aVetMMTD[3]        ,; //66
		aVetMMTD[4]        ,; //67
		aVetMMTD[5]        ,; //68
		{}                 ,; //69
		aVetMMTD[6]        ,; //70
		aTotMMTD           ,; //71
		nTotMMTD           ,; //72
		IIF(!Empty(GCY->GCY_DATALT) .And. GCY->GCY_DATALT == GCZ->GCZ_DCPARF, {"X", ""}, {"", "X"}),;  // 73
		nValTot74          ,; //74
		nTotDia75          ,; //75
		nTotTA76           ,; //76
		nTotMat77          ,; //77
		nTotMed78          ,; //78
		nTotGas79          ,; //79
		nTotGerRI          ,; //80
		GCZ->GCZ_OBSTIS ,; //81
		CTOD("")           ,; //82
		CTOD("")           }} //83
		PLSTISS4(aResInte, lVsTISS, nLayout, cLogoGH)

	Else

		aVetPR[2] := AClone(aVetPR[13])

		aVetPR[7] := HS_AJUSTIS(aVetPR[7], "BTU_CDTERM", "GDB", .F., "87")
		aVetPR[13] := HS_AJUSTIS(aVetPR[13], "BTU_CDTERM", "GA7", .F., "22")
		aVetPR[2] := HS_AJUSTIS(aVetPR[2], "BTQ_DESTER", "GA7", .F., "22")
		aVetPR[8] := HS_AJUSTIS(aVetPR[8], "BTU_CDTERM", "GE4", .F., "61")
		aVetPR[17] := HS_AJUSTIS(aVetPR[17], "BTU_CDTERM", "   ", .F., "48")
		aVetPR[9] := HS_AJUSTIS(aVetPR[9], "BTU_CDTERM", "GMC", .F., "35")
		aGBJCON := HS_AJUSTIS(aGBJCON, "BTU_CDTERM", "BAH", .F., "26")
		aGBJUFC := HS_AJUSTIS(aGBJUFC, "BTU_CDTERM", "SX5", .F., "59")
		aGBJCBO := HS_AJUSTIS(aGBJCBO, "BTU_CDTERM", "GN1", .F., "24")

		aResInte := {{GA9->GA9_CODOPE 	,; //1 - Registro ANS
  					  GCZ->GCZ_NRGUIA 	,; //2 - Nº Guia no Prestador
					  GCZ->GCZ_GUIAPR 	,; //3 - Número da Guia de Solicitação de Internação
					  GCZ->GCZ_DATAUT 	,; //4 - Data da Autorização
					  GCZ->GCZ_NRSEN1 	,; //5 - Senha
					  GCZ->GCZ_VALSEN 	,; //6 - Data de Validade da Senha
					  GCZ->GCZ_GUIAOP	,; //7 - Número da Guia Atribuído pela Operadora 
					  GD4->GD4_MATRIC   ,; //8 - Número da Carteira
					  GD4->GD4_DTVALI   ,; //9 - Validade da Carteira
					  GBH->GBH_NOME     ,; //10 - Nome
					  GBH->GBH_NUMCNS   ,; //11 - Cartão Nacional de Saúde
					  GCY->GCY_ATERN	,; //12 -Atendimento a RN
					  HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2],;//13 - Código na Operadora
					  aSM0Dados[1, 2]   ,; //14 - Nome do Contratado
					  aSM0Dados[1, 8]   ,; //15 - Código CNES
					  IIF (Empty(ALLTRIM(GD1->GD1_CARATE)), "", PLSGETVINC("BTU_CDTERM", "GD1", .F., "23", ALLTRIM(GD1->GD1_CARATE))),;//16 - Caráter do Atendimento
					  IIF (!Empty(GCY->GCY_DATALT) .And. GCY->GCY_DATALT == GCZ->GCZ_DCPARF, "4", "1"),;// 17- Tipo de Faturamento 
					  GCZ->GCZ_DCPARI	,; //18- Data do Início do Faturamento
					  GCZ->GCZ_HORFAT	,; //19- Hora do Início do Faturamento
					  GCZ->GCZ_DCPARF	,; //20- Data do Fim do Faturamento
					  GCZ->GCZ_HORFAT	,; //21 - Hora do Fim do Faturamento
					  IIF (Empty(ALLTRIM(GCW->GCW_TITISS)), "", PLSGETVINC("BTU_CDTERM", "G05", .F., "57", ALLTRIM(GCW->GCW_TITISS))),; //22- Tipo de Internação
					  IIF (Empty(ALLTRIM(GCY->GCY_REGIME)), "", PLSGETVINC("BTU_CDTERM", "   ", .F., "41", ALLTRIM(GCY->GCY_REGIME))),; //23- Regime de Internação
					  HS_RetCID(GCY->GCY_REGATE, GCZ->GCZ_CODCON, "GA9_ICIDRI", "1"),; //24- CID 10 Principal
					  HS_RetCID(GCY->GCY_REGATE, GCZ->GCZ_CODCON, "GA9_ICIDRI", "2"),; //25- CID 10 (2)
					  HS_RetCID(GCY->GCY_REGATE, GCZ->GCZ_CODCON, "GA9_ICIDRI", "3"),; //26- CID 10 (3)
					  ""                ,; //27 - CID 10 (4)
					  IIF (EMPTY(GCZ->GCZ_IATISS), "", PLSGETVINC("BTU_CDTERM", "   ", .F., "36", ALLTRIM(GCZ->GCZ_IATISS))),; //28 - Indicação de Acidente (acidente ou doença relacionada)
					  IIf (!Empty(GCY->GCY_TPALTA), PLSGETVINC("BTU_CDTERM", "GF4", .F., "39", ALLTRIM(GCY->GCY_TPALTA)), IIF(!EMPTY(GCZ->GCZ_TPALTA), PLSGETVINC("BTU_CDTERM", "GF4", .F., "39", ALLTRIM(GCZ->GCZ_TPALTA)), "")),; //29 - Motivo de Encerramento da Internação
					  GB2->GB2_NRODEC   ,; //30 -Número da declaração de nascido vivo
					  IIF (!Empty(GCY->GCY_CIDALT) .And. GCY->GCY_CIDALT $ GETMV("MV_TPALTA"), GCY->GCY_CIDALT, ""),; //31- CID 10 Óbito
					  GCY->GCY_OBTDOC   ,; //32- Numero da declaração de óbito
					  IIf (lSeekRN, IIF(GB2->GB2_STNASC=="1", "S", "N"), IIF(!Empty(GCY->GCY_OBTDOC), "S", "N")),; //33-Indicador D.O. de RN
					  aVetPR[3]         ,; //34-Data
					  aVetPR[4]         ,; //35-Hora Inicial
					  aVetPR[5]         ,; //36-Hora Final
					  aVetPR[7]			,;//37-Tabela
					  aVetPR[13]		,;//38-Código do Procedimento
					  aVetPR[2]			,;//39-Descrição
					  aVetPR[6]         ,; //40-Qtde.
					  aVetPR[8]			,;//41-Via
					  aVetPR[17]		,;//42-Téc
					  aVetPR[19]        ,; //43-Fator Red/Acresc
					  aValUni55         ,; //44-Valor Unitário (R$)
					  aValTot56         ,; //45-Valor Total (R$)
					  aSeqRef           ,; //46-Seq.Ref
					  aVetPR[9]			,;//47-Grau Part.
					  aGBJCPF           ,; //48-Código na Operadora/CPF
					  aSRAMED           ,; //49-Nome do Profissional
					  aGBJCON			,;//50-Conselho Profissional
					  aSRACOD           ,; //51-Número no Conselho
					  aGBJUFC			,;//52-UF
					  aGBJCBO			,;//53-Código CBO
					  nValTot74         ,; //54 - Total de Procedimentos (R$)
					  nTotDia75         ,; //55- Total de Diárias (R$)
					  nTotTA76          ,; //56- Total de Taxase Aluguéis (R$)
					  nTotMat77         ,; //57- Total de Materiais (R$)
					  nTotMMTD          ,; //58- Total de OPME (R$)
					  nTotMed78         ,; //59- Total de Medicamentos (R$)
					  nTotGas79         ,; //60- Total de Gases Medicinais (R$)
					  nTotGerRI         ,; //61- Total Geral (R$)
					  CTOD("")			,; //62- Data da assinatura do contratado
					  ""				,; //63
					  ""				,; //64
					  GCZ->GCZ_OBSTIS } }  //65– Observações / Justificativa

		PLSTISSF(aResInte, lVsTISS, nLayout, cLogoGH)

	EndIf

Return(.T.)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ Hs_ImpODsp ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Impressao da guia de Outras despesas do TISS                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Sequencial da guia                                     ³±±
	±±³          ³ExpC2: Alias da tabela de despesa de Mat/Med             (OPC)³±±
	±±³          ³ExpC3: Alias da tabela de despesa de Tax/Dia             (OPC)³±±
	±±³          ³ExpC4: Alias da tabela de despesa de Procedimentos       (OPC)³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function Hs_ImpODsp(cNrSeqG, cAliasG5, cAliasG6, cAliasG7)
	Local aCOM      	:= {}
	Local aCOMAux   	:= {}
	Local aCOT      	:= {}
	Local aCOP      	:= {}
	Local aHOM      	:= {}
	Local aHOT      	:= {}
	Local aHOP      	:= {}
	Local aHHPR     	:= {}
	Local aCHPR     	:= {}
	Local aVtOutDes 	:= {}
	Local aOutDesp  	:= {}
	Local aTotDes   	:= {}
	Local aSM0Dados 	:= {}
	Local nGasMed   	:= {}
	Local nTotMed   	:= {}
	Local nTotMat   	:= {}
	Local nTotTax   	:= {}
	Local nTotDia   	:= {}
	Local nTotAlu   	:= {}
	Local nTotGer   	:= {}
	Local aCodDes   	:= {}

	Local nForLin   	:= 0
	Local nForCol   	:= 0
	Local nForDesp  	:= 0
	Local nForGuias 	:= 0
	Local nUMM      	:= 0
	Local nUTD      	:= 0
	Local nUPR      	:= 0
	Local nUOM      	:= 0
	Local nUOT      	:= 0
	Local nUOP      	:= 0
	Local nUHPR     	:= 0
	Local cGE7Fil   	:= ""
	Local cCodPropr 	:= ""
	Local cCpoPropr 	:= ""
	Local cRegAte   	:= "", cPaciente := "", cCodPla := ""
	Local cTissVer  	:= GetNewPar("MV_TISSVER", "2.02.03")
	Local nUltimo   	:= 1
	Local cAux      	:= ""
	Local cCodBkp	  	:= ""
	Local nCN 		  	:= 1
	Local nGas		  	:= 0
	Local nMed			:= 0
	Local nMat			:= 0
	Local nTax 	  	:= 0
	Local nDia 	  	:= 0
	Local nAlu 	  	:= 0
	Local nGer 	  	:= 0
	Local cHSPCNES  	:= GETMV("MV_HSPCNES")
	Default cAliasG5	:= ""
	Default cAliasG6	:= ""
	Default cAliasG7	:= ""

	IIF(Alias()         # "GCZ"  , DbSelectArea("GCZ"), Nil)
	IIF(IndexOrd()      # 1      , DbSetOrder(1), Nil) // GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
	IIF(GCZ->GCZ_NRSEQG # cNrSeqG, DbSeek(xFilial("GCZ") + cNrSeqG), Nil)

	cCodPropr := HS_INIPADR("GA9",1, GCZ->GCZ_CODCON, "GA9_CODPRO",,.F.)
	cCpoPropr := Iif(FindFunction("HS_RCDPROD"),HS_RCDPROD(GCZ->GCZ_CODCON)[1], "")

	cAliasG5  := IIF(!Empty(cAliasG5) ,cAliasG5 , IIF(GCZ->GCZ_STATUS < "2", "GD5", "GE5"))
	cAliasG6  := IIF(!Empty(cAliasG6) ,cAliasG6 , IIF(GCZ->GCZ_STATUS < "2", "GD6", "GE6"))
	cAliasG7  := IIF(!Empty(cAliasG7) ,cAliasG7 , IIF(GCZ->GCZ_STATUS < "2", "GD7", "GE7"))
	cRegAte   := IIF(!Empty(cRegAte)  ,cRegAte  , GCZ->GCZ_REGATE)
	cPaciente := IIF(!Empty(cPaciente),cPaciente, GCZ->GCZ_REGGER)
	cCodPla   := IIF(!Empty(cCodPla)  ,cCodPla  , GCZ->GCZ_CODPLA)

	IIF(Alias()         # "GCY"  , DbSelectArea("GCY"), Nil)
	IIF(IndexOrd()      # 1      , DbSetOrder(1), Nil)// GCY_FILIAL+GCY_REGATE
	IIf(GCY->GCY_REGATE # cRegAte, DbSeek(xFilial("GCY") + cRegAte), Nil)

	IIF(Alias()         # "GD4", DbSelectArea("GD4"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GD4_FILIAL + GD4_REGGER + GD4_CODPLA
	DbSeek(xFilial("GD4") + cPaciente + cCodPla)

	IIF(Alias()         # "GCM", DbSelectArea("GCM"), Nil)
	IIF(IndexOrd()      # 2, DbSetOrder(2), Nil) // GCM_FILIAL + GCM_CODPLA
	IIF(GCM->GCM_CODPLA # cCodPla, DbSeek(xFilial("GCM") + cCodPla), Nil)

	IIF(Alias()         # "GA9", DbSelectArea("GA9"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GA9_FILIAL+GA9_CODCON
	IIF(GA9->GA9_CODCON # GCM->GCM_CODCON, DbSeek(xFilial("GA9") + GCM->GCM_CODCON), Nil)
	cLogoGH := GA9->GA9_LOGOTP

	IIF(Alias()         # "GBH", DbSelectArea("GBH"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GBH_FILIAL + GBH_CODPAC
	IIF(GBH->GBH_CODPAC # cPaciente, DbSeek(xFilial("GBH") + cPaciente), Nil)

	IIF(Alias()         # "GF4", DbSelectArea("GF4"), Nil)
	IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)   // GF4_FILIAL + GF4_TPALTA
	IIF(GF4->GF4_TPALTA # GCY->GCY_TPALTA, DbSeek(xFilial("GF4") + GCY->GCY_TPALTA), Nil)

	aCpOMM := {cAliasG5 + "_SEQDES", cAliasG5 + "_CODDES", cAliasG5 + "_DATDES", cAliasG5 + "_QTDDES", cAliasG5 + "_HORDES", ;
		cAliasG5 + "_TABELA", cAliasG5 + "_CODPRO", cAliasG5 + "_DESPRO", cAliasG5 + "_VALDES", cAliasG5 + "_GLODES", cAliasG5 + "_UNICON", "GBI_CODANV", "GBI_CODFOR", "GBI_AUTFUN"}

	aJoinGBI   := {{" JOIN " + RetSqlName("GBI") + " GBI", "GBI_CODANV, GBI_CODFOR, GBI_AUTFUN", "GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_PRODUT = " + cAliasG5 + "_CODDES", ""}}

	aCpOTD := {cAliasG6 + "_SEQDES", cAliasG6 + "_CODDES", cAliasG6 + "_DATDES", cAliasG6 + "_QTDDES", cAliasG6 + "_HORDES",;
		cAliasG6 + "_TABELA", cAliasG6 + "_CODTXC", cAliasG6 + "_DESTXC", cAliasG6 + "_VALDES", cAliasG6 + "_GLODES"}

	aCpOPR := {cAliasG7 + "_SEQDES", cAliasG7 + "_CODDES", cAliasG7 + "_DATDES", cAliasG7 + "_QTDDES", cAliasG7 + "_HORDES",;
		cAliasG7 + "_TABELA", cAliasG7 + "_CODPRT", cAliasG7 + "_DESPRT", cAliasG7 + "_VALDES", cAliasG7 + "_GLODES"}

	HS_BDados(cAliasG5, @aHOM, @aCOM, @nUOM, 1,, cAliasG5 + "->" + cAliasG5 + "_NRSEQG == '" + cNrSeqG + "'",,, "/",,,,,, .T.,,,,,, aCpOMM, aJoinGBI)
	HS_BDados(cAliasG6, @aHOT, @aCOT, @nUOT, 1,, cAliasG6 + "->" + cAliasG6 + "_NRSEQG == '" + cNrSeqG + "'",,, "/",,,,,, .T.,,,,,, aCpOTD)
	HS_BDados(cAliasG7, @aHOP, @aCOP, @nUOP, 1,, cAliasG7 + "->" + cAliasG7 + "_NRSEQG == '" + cNrSeqG + "' ",,,"/",,,,,, .T.,,,,,, aCpOPR)

    // Dados complementares (Adicionados no Array aCOMAux)
	If Len(aCOM) > 0
		For	nForLin := 1 to Len(aCOM)
		cSql := "SELECT MAX(GCB_DATVIG) DATVIG FROM " + RetSqlName("GCB") + " GCB  "
		cSql += " WHERE GCB.GCB_CODTAB='" + aCOM[nForLin][6] + "' AND GCB.GCB_PRODUT='" + aCOM[nForLin][2] + "' "
		cSql += " AND GCB.D_E_L_E_T_ <> '*' AND GCB.GCB_FILIAL = '" + xFilial("GCB") + "'"
		TCQuery cSql New Alias "TMPVIG"

		DbSelectArea("GCB")
		DbSetOrder(1)
		If DbSeek(xFilial("GCB") + aCOM[nForLin][6] + aCOM[nForLin][2] + TMPVIG->DATVIG)
			If !Empty(cCodPropr) .AND. !Empty(cCpoPropr)
				AADD(aCOMAux, {aCOM[nForLin][7],&("GCB->" + cCpoPropr),IIf(cCpoPropr == "GCB_CODCON",GCB->GCB_DESCON,IIf(cCpoPropr == "GCB_CODPRO",GCB->GCB_DESPRO,"")),aCOM[nForLin][3],GCB->GCB_PRODUT})
			Else
				AADD(aCOMAux, {aCOM[nForLin][7],GCB->GCB_CDTISS,"",aCOM[nForLin][3],GCB->GCB_PRODUT})
			EndIf
		Else
			AADD(aCOMAux, {aCOM[nForLin][7],"","",aCOM[nForLin][3],GCB->GCB_PRODUT})
		EndIf
		TMPVIG->(DbCloseArea())
	Next
EndIf

If GA9->GA9_OUTDES $ "1/2"
	aSort(aCOM,,,{|x,y| x[2]+DTOS(x[3]) < y[2]+DTOS(y[3])})
	aSort(aCOT,,,{|x,y| x[2]+DTOS(x[3]) < y[2]+DTOS(y[3])})
	aSort(aCOP,,,{|x,y| x[2]+DTOS(x[3]) < y[2]+DTOS(y[3])})
	aSort(aCOMAux,,,{|x,y| x[5]+DTOS(x[4]) < y[5]+DTOS(y[4])})
Else
	aSort(aCOM,,,{|x,y| DTOS(x[3])+x[2] < DTOS(y[3])+y[2]})
	aSort(aCOT,,,{|x,y| DTOS(x[3])+x[2] < DTOS(y[3])+y[2]})
	aSort(aCOP,,,{|x,y| DTOS(x[3])+x[2] < DTOS(y[3])+y[2]})
	aSort(aCOMAux,,,{|x,y| DTOS(x[4])+x[5] < DTOS(y[4])+y[5]})
EndIf

nLinhaTot  := 1
nQuebraTot := 14
nQtdVezes  := 0

aAdd(nGasMed, 0) //17
aAdd(nTotMed, 0) //18
aAdd(nTotMat, 0) //19
aAdd(nTotTax, 0) //20
aAdd(nTotDia, 0) //21
aAdd(nTotAlu, 0) //22
aAdd(nTotGer, 0) //23

For nForCol := 1 To nUOM
	AADD(aVtOutDes, {})
	dDatDes    := CToD("")
	cCodDes    := ""
	For nForLin := 1 To Len(aCOM)
		If !Empty(aCOM[nForLin, 2])
			DbSelectArea("GBI")
			DbSetOrder(1) // GBI_FILIAL + GBI_PRODUT
			If DbSeek(xFilial("GBI") + aCOM[nForLin, 2]) .And. !Empty(GBI->GBI_CITISS)
				DbSelectArea("G20")
				DbSetOrder(1) //G20_FILIAL + G20_CITISS
				If DBSeek(xFilial("G20") + GBI->GBI_CITISS) .And. !Empty(G20->G20_CODXML) .And. G20->G20_CODXML <> "11" .And. aCOM[nForLin, 10] == "0" // classificacao do item <> 11 e o campo _GLODES == normal
					If GA9->GA9_OUTDES $ "1/2" .And. IIF(GA9->GA9_OUTDES == "2",.T.,	dDatDes == aCOM[nForLin, 3]) .And. cCodDes == aCOM[nForLin, 2] .And. Len(aCOM) > 1
						If Len(aVtOutDes[nForCol]) == 0
							If nForCol == 4
								ASize(aVtOutDes[nForCol], Len(aVtOutDes[nForCol]) + 1)
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := aCOM[nForLin, nForCol]
								aAdd(aTotDes, HS_CValDes(cAliasG5, aCOM[nForLin, 1]))
							ElseIf nForCol == 5
								ASize(aVtOutDes[nForCol], Len(aVtOutDes[nForCol]) + 1)
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := ""
							EndIf
						ElseIf nForCol == 4
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] += aCOM[nForLin, nForCol]
							aTotDes[Len(aTotDes)] += HS_CValDes(cAliasG5, aCOM[nForLin, 1])
						ElseIf nForCol == 5
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := ""
						EndIf
					Else
						ASize(aVtOutDes[nForCol], Len(aVtOutDes[nForCol]) + 1)
						If nForCol == 4
							nQuebraTot++
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := aCOM[nForLin, nForCol]
							aAdd(aTotDes, HS_CValDes(cAliasG5, aCOM[nForLin, 1]))
						ElseIf nForCol == 6 .AND. cTissVer < "3"
							DbSelectArea("GCA")
							DbSetOrder(1) //GCA_FILIAL + GCA_CODTAB
							If !Empty(aCOM[nForLin, 6]) .And. DbSeek(xFilial("GCA") + aCOM[nForLin, 6])
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := IIF(!Empty(GCA->GCA_TBTISS), GCA->GCA_TBTISS, "00")
							Else
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := IIF(!Empty(GA9->GA9_TBTISS), GA9->GA9_TBTISS, "00")
							EndIf
						Else
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := aCOM[nForLin, nForCol]
						EndIf
					EndIf
					If nForCol == 4

						If nQuebraTot > Len(aCOM)
							nLinhaTot++
							nQuebraTot := 1
							aAdd(nGasMed, 0) //17
							aAdd(nTotMed, 0) //18
							aAdd(nTotMat, 0) //19
							aAdd(nTotTax, 0) //20
							aAdd(nTotDia, 0) //21
							aAdd(nTotAlu, 0) //22
							aAdd(nTotGer, 0) //23
						EndIf
						nQtdVezes++
						If cTissVer < "3"
							aAdd(aCodDes, SubStr(G20->G20_CODXML, 2, 1))
						Else
							aAdd(aCodDes, G20->G20_CODIGO)
						EndIf
						If G20->G20_CODXML == "01"
							nGasMed[nLinhaTot] += HS_CValDes(cAliasG5, aCOM[nForLin, 1])
						ElseIf G20->G20_CODXML == "02"
							nTotMed[nLinhaTot] += HS_CValDes(cAliasG5, aCOM[nForLin, 1])
						ElseIf G20->G20_CODXML == "03"
							nTotMat[nLinhaTot] += HS_CValDes(cAliasG5, aCOM[nForLin, 1])
						ElseIf G20->G20_CODXML == "04"
							nTotTax[nLinhaTot] += HS_CValDes(cAliasG5, aCOM[nForLin, 1])
						ElseIf G20->G20_CODXML == "05"
							nTotDia[nLinhaTot] += HS_CValDes(cAliasG5, aCOM[nForLin, 1])
						ElseIf G20->G20_CODXML == "06"
							nTotAlu[nLinhaTot] += HS_CValDes(cAliasG5, aCOM[nForLin, 1])
						EndIf
						nTotGer[nLinhaTot] += HS_CValDes(cAliasG5, aCOM[nForLin, 1])
					EndIf
					dDatDes := aCOM[nForLin, 3]
					cCodDes := aCOM[nForLin, 2]
				EndIf
			Else
				HS_MsgInf(STR0012 + AllTrim(aCOM[nForLin, 2]) + STR0013, STR0002, STR0014) //"A despesa "###" não está com a classificação do item preenchida."###"Atenção"###"Validação da Guia TISS"
				Return(.F.)
			EndIf
		EndIf
	Next
Next

Aadd(aVtOutDes, {})
If (Len(aVtOutDes) >= 1)
	nUltimo := Len(aVtOutDes[1])
	For nForCol := 1 To nUltimo
		Aadd(aVtOutDes[Len(aVtOutDes)], "SB1")
	Next
EndIf

// taxas e diarias
For nForCol := 1 To nUOT
	dDatDes := CTOD("")
	cCodDes := ""

	For nForLin := 1 To Len(aCOT)
		If !Empty(aCOT[nForLin, 2])
			DbSelectArea("GAA")
			DbSetOrder(1) // GAA_FILIAL + GAA_CODTXD
			If DbSeek(xFilial("GAA") + aCOT[nForLin, 2]) .And. !Empty(GAA->GAA_CITISS)
				DbSelectArea("G20")
				DbSetOrder(1) //G20_FILIAL + G20_CITISS
				If DBSeek(xFilial("G20") + GAA->GAA_CITISS) .And. !Empty(G20->G20_CODXML) .And. G20->G20_CODXML <> "11" .And. aCOT[nForLin, 10] == "0" // classificacao do item <> 11 e o campo _GLODES == normal
					If GA9->GA9_OUTDES $ "1/2" .And. IIF(GA9->GA9_OUTDES == "2",.T.,	dDatDes == aCOT[nForLin, 3]) .And. cCodDes == aCOT[nForLin, 2] .And. Len(aCOT) > 1
						If Len(aVtOutDes[nForCol]) == 0
							If nForCol == 4
								ASize(aVtOutDes[nForCol], Len(aVtOutDes[nForCol]) + 1)
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := aCOT[nForLin, nForCol]
								aAdd(aTotDes, HS_CValDes(cAliasG6, aCOT[nForLin, 1]))
							ElseIf nForCol == 5
								ASize(aVtOutDes[nForCol], Len(aVtOutDes[nForCol]) + 1)
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := ""
							EndIf
						ElseIf nForCol == 4
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])]  += aCOT[nForLin, nForCol]
							aTotDes[Len(aTotDes)] += HS_CValDes(cAliasG6, aCOT[nForLin, 1])
						ElseIf nForCol == 5
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := ""
						EndIf
					Else
						ASize(aVtOutDes[nForCol], Len(aVtOutDes[nForCol]) + 1)
						If nForCol == 4
							nQuebraTot++
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := aCOT[nForLin, nForCol]
							aAdd(aTotDes, HS_CValDes(cAliasG6, aCOT[nForLin, 1]))
						ElseIf nForCol == 6 .AND. cTissVer < "3"
							DbSelectArea("GD2")
							DbSetOrder(1) //GD2_FILIAL + GD2_CODTAB
							If !Empty(aCOT[nForLin, 6]) .And. DbSeek(xFilial("GD2") + aCOT[nForLin, 6])
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := IIF(!Empty(GD2->GD2_TBTISS), GD2->GD2_TBTISS, "00")
							Else
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := IIF(!Empty(GA9->GA9_TBTISS), GA9->GA9_TBTISS, "00")
							EndIf
						Else
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := aCOT[nForLin, nForCol]
						EndIf
					EndIf
					If nForCol == 4

						If nQuebraTot > Len(aCOT)
							nLinhaTot++
							nQuebraTot := 1
							aAdd(nGasMed, 0) //17
							aAdd(nTotMed, 0) //18
							aAdd(nTotMat, 0) //19
							aAdd(nTotTax, 0) //20
							aAdd(nTotDia, 0) //21
							aAdd(nTotAlu, 0) //22
							aAdd(nTotGer, 0) //23
						EndIf
						nQtdVezes++
						If cTissVer < "3"
							aAdd(aCodDes, SubStr(G20->G20_CODXML, 2, 1))
						Else
							aAdd(aCodDes, G20->G20_CODIGO)
						EndIf
						If G20->G20_CODXML == "01"
							nGasMed[nLinhaTOt] += HS_CValDes(cAliasG6, aCOT[nForLin, 1])
						ElseIf G20->G20_CODXML == "02"
							nTotMed[nLinhaTOt] += HS_CValDes(cAliasG6, aCOT[nForLin, 1])
						ElseIf G20->G20_CODXML == "03"
							nTotMat[nLinhaTOt] += HS_CValDes(cAliasG6, aCOT[nForLin, 1])
						ElseIf G20->G20_CODXML == "04"
							nTotTax[nLinhaTOt] += HS_CValDes(cAliasG6, aCOT[nForLin, 1])
						ElseIf G20->G20_CODXML == "05"
							nTotDia[nLinhaTOt] += HS_CValDes(cAliasG6, aCOT[nForLin, 1])
						ElseIf G20->G20_CODXML == "06"
							nTotAlu[nLinhaTOt] += HS_CValDes(cAliasG6, aCOT[nForLin, 1])
						EndIf
						nTotGer[nLinhaTOt] += HS_CValDes(cAliasG6, aCOT[nForLin, 1])
					EndIf
					dDatDes := aCOT[nForLin, 3]
					cCodDes := aCOT[nForLin, 2]
				EndIf
			Else
				HS_MsgInf(STR0012 + AllTrim(aCOT[nForLin, 2]) + STR0013, STR0002, STR0014) //"A despesa "###" não está com a classificação do item preenchida."###"Atenção"###"Validação da Guia TISS"
			Return(.F.)
			EndIf
		EndIf
	Next
Next

If (Len(aVtOutDes) >= 1 .AND. nUltimo < Len(aVtOutDes[1]))
	For nForCol := nUltimo To Len(aVtOutDes[1])
		Aadd(aVtOutDes[Len(aVtOutDes)], "GAA")
	Next
	nUltimo := Len(aVtOutDes[1])
EndIf

	// Procedimento Honorario Medico = Não
For nForCol := 1 To nUOP
	dDatDes := CTOD("")
	cCodDes := ""
	For nForLin := 1 To Len(aCOP)
		If !Empty(aCOP[nForLin, 2])
			DbSelectArea("GA7")
			DbSetOrder(1) // GA7_FILIAL + GA7_CODPRO
			If DbSeek(xFilial("GA7") + aCOP[nForLin, 2]) .And. GA7->GA7_TIPPRO $ "1/9" .And. GA7->GA7_HONORA == "0" .And. !Empty(GA7->GA7_CITISS)
				DbSelectArea("G20")
				DbSetOrder(1) //G20_FILIAL + G20_CITISS
				If DBSeek(xFilial("G20") + GA7->GA7_CITISS) .And. !Empty(G20->G20_CODXML) .And. G20->G20_CODXML <> "11" .And. aCOP[nForLin, 10] == "0" // classificacao do item <> 11 e o campo _GLODES == normal
					If GA9->GA9_OUTDES == "1/2" .And. IIF(GA9->GA9_OUTDES == "2",.T.,	dDatDes == aCOP[nForLin, 3]) .And. cCodDes == aCOP[nForLin, 2] .And. Len(aCOP) > 1
						If Len(aVtOutDes[nForCol]) == 0
							If nForCol == 4
								ASize(aVtOutDes[nForCol], Len(aVtOutDes[nForCol]) + 1)
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := aCOP[nForLin, nForCol]
								aAdd(aTotDes, HS_CValDes(cAliasG7, aCOP[nForLin, 1]))
							ElseIf nForCol == 5
								ASize(aVtOutDes[nForCol], Len(aVtOutDes[nForCol]) + 1)
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := ""
							EndIf
						ElseIf nForCol == 4
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])]  += aCOP[nForLin, nForCol]
							aTotDes[Len(aTotDes)] += HS_CValDes(cAliasG7, aCOP[nForLin, 1])
						ElseIf nForCol == 5
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := ""
						EndIf
					Else
						ASize(aVtOutDes[nForCol], Len(aVtOutDes[nForCol]) + 1)
						If nForCol == 4
							nQuebraTot++
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := aCOP[nForLin, nForCol]
							aAdd(aTotDes, HS_CValDes(cAliasG7, aCOP[nForLin, 1]))
						ElseIf nForCol == 6 .AND. cTissVer < "3"
							DbSelectArea("GDB")
							DbSetOrder(1) //GDB_FILIAL + GDB_CHAVE
							If !Empty(aCOP[nForLin, 6]) .And. DbSeek(xFilial("GDB") + aCOP[nForLin, 6])
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := IIF(!Empty(GDB->GDB_TBTISS), GDB->GDB_TBTISS, "00")
							Else
								aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := IIF(!Empty(GA9->GA9_TBTISS), GA9->GA9_TBTISS, "00")
							EndIf
						Else
							aVtOutDes[nForCol, Len(aVtOutDes[nForCol])] := aCOP[nForLin, nForCol]
						EndIf
					EndIf
					If nForCol == 4

						If nQuebraTot > Len(aCOP)
							nLinhaTot++
							nQuebraTot := 1
							aAdd(nGasMed, 0) //17
							aAdd(nTotMed, 0) //18
							aAdd(nTotMat, 0) //19
							aAdd(nTotTax, 0) //20
							aAdd(nTotDia, 0) //21
							aAdd(nTotAlu, 0) //22
							aAdd(nTotGer, 0) //23
						EndIf
						nQtdVezes++
						If cTissVer < "3"
							aAdd(aCodDes, SubStr(G20->G20_CODXML, 2, 1))
						Else
							aAdd(aCodDes, G20->G20_CODIGO)
						EndIf
						If G20->G20_CODXML == "01"
							nGasMed[nLinhaTOt] += HS_CValDes(cAliasG7, aCOP[nForLin, 1])
						ElseIf G20->G20_CODXML == "02"
							nTotMed[nLinhaTOt] += HS_CValDes(cAliasG7, aCOP[nForLin, 1])
						ElseIf G20->G20_CODXML == "03"
							nTotMat[nLinhaTOt] += HS_CValDes(cAliasG7, aCOP[nForLin, 1])
						ElseIf G20->G20_CODXML == "04"
							nTotTax[nLinhaTOt] += HS_CValDes(cAliasG7, aCOP[nForLin, 1])
						ElseIf G20->G20_CODXML == "05"
							nTotDia[nLinhaTOt] += HS_CValDes(cAliasG7, aCOP[nForLin, 1])
						ElseIf G20->G20_CODXML == "06"
							nTotAlu[nLinhaTOt] += HS_CValDes(cAliasG7, aCOP[nForLin, 1])
						EndIf
						nTotGer[nLinhaTOt] += HS_CValDes(cAliasG7, aCOP[nForLin, 1])
					EndIf
					dDatDes := aCOP[nForLin, 3]
					cCodDes := aCOP[nForLin, 2]
				EndIf
			ElseIf GA7->GA7_TIPPRO $ "1/9" .And. GA7->GA7_HONORA == "0"
				HS_MsgInf(STR0012 + AllTrim(aCOP[nForLin, 2]) + STR0013, STR0002, STR0014) //"A despesa "###" não está com a classificação do item preenchida."###"Atenção"###"Validação da Guia TISS"
			Return(.F.)
			EndIf
		EndIf
	Next
Next

If (Len(aVtOutDes) >= 1 .AND. nUltimo < Len(aVtOutDes[1]))
	For nForCol := nUltimo To Len(aVtOutDes[1])
		Aadd(aVtOutDes[Len(aVtOutDes)], "GA7")
	Next
EndIf

For nCN := 1 To Len(nTotGer)
	nGas += nGasMed[nCN]
	nMed += nTotMed[nCN]
	nMat += nTotMat[nCN]
	nTax += nTotTax[nCN]
	nDia += nTotDia[nCN]
	nAlu += nTotAlu[nCN]
	nGer += nTotGer[nCN]
Next

If cTissVer < "3"

	If Len(aVtOutDes[7]) > 0
		nLinhaTot := 0
		For nForGuias := 1 To Len(aVtOutDes[7]) Step 13
			nLinhaTot++
			aAdd(aOutDesp, {GA9->GA9_CODOPE    ,;  //1
			GCZ->GCZ_NRGUIA ,; //2
			HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2],; //3
			SM0->M0_NOMECOM    ,; //4
			cHSPCNES,; //5
			{},; //6
			{},; //7
			{},; //8
			{},; //9
			{},; //10
			{},; //11
			{},; //12
			{},; //13
			{},; //14
			{},; //15
			{},; //16
			nGasMed[nLinhaTot],; //17
			nTotMed[nLinhaTot],; //18
			nTotMat[nLinhaTot],; //19
			nTotTax[nLinhaTot],; //20
			nTotDia[nLinhaTot],; //21
			nTotAlu[nLinhaTot],; //22
			nTotGer[nLinhaTot]}) //23
			For nForDesp := nForGuias To IIf(nForGuias + 12 > Len(aVtOutDes[7]), Len(aVtOutDes[7]), nForGuias + 12)
				aAdd(aOutDesp[Len(aOutDesp)][06], aCodDes[nForDesp])
				aAdd(aOutDesp[Len(aOutDesp)][07], aVtOutDes[3][nForDesp])
				aAdd(aOutDesp[Len(aOutDesp)][08], aVtOutDes[5][nForDesp])
				aAdd(aOutDesp[Len(aOutDesp)][09], aVtOutDes[5][nForDesp])
				aAdd(aOutDesp[Len(aOutDesp)][10], aVtOutDes[6][nForDesp])
				If nForDesp <= Len(aCOMAux) .AND. aVtOutDes[7][nForDesp] == aCOMAux[nForDesp][1] .AND. !Empty(aCOMAux[nForDesp][2]) //Caso tenha Codigo GCB_CDTISS imprime Else Codigo Proprio
					aAdd(aOutDesp[Len(aOutDesp)][11], aCOMAux[nForDesp,2])
					If !Empty(aCOMAux[nForDesp,3])
						aAdd(aOutDesp[Len(aOutDesp)][16], aCOMAux[nForDesp,3])
					Else
						aAdd(aOutDesp[Len(aOutDesp)][16], aVtOutDes[8][nForDesp])
					EndIf
				Else
					aAdd(aOutDesp[Len(aOutDesp)][11], aVtOutDes[7][nForDesp])
					aAdd(aOutDesp[Len(aOutDesp)][16], aVtOutDes[8][nForDesp])
				EndIf
				aAdd(aOutDesp[Len(aOutDesp)][12], aVtOutDes[4][nForDesp])
				aAdd(aOutDesp[Len(aOutDesp)][14], aVtOutDes[9][nForDesp])
				aAdd(aOutDesp[Len(aOutDesp)][15], aTotDes[nForDesp])
			Next
		Next
	Else
		aOutDesp := {{GA9->GA9_CODOPE    ,;  //1
		GCZ->GCZ_NRGUIA ,; //2
		SM0->M0_CGC        ,; //3
		SM0->M0_NOMECOM    ,; //4
		cHSPCNES,; //5
		{},; //6
		{},; //7
		{},; //8
		{},; //9
		{},; //10
		{},; //11
		{},; //12
		{},; //13
		{},; //14
		{},; //15
		{},; //16
		0,; //17
		0,; //18
		0,; //19
		0,; //20
		0,; //21
		0,; //22
		0}} //23
	EndIf

	PLSTISS6(aOutDesp, lVsTISS, nLayout, cLogoGH)

Else

	If Len(aVtOutDes[7]) > 0
		nLinhaTot := 0
		For nForGuias := 1 To 1 Step 13
			nLinhaTot++
			aAdd(aOutDesp,{GA9->GA9_CODOPE,; //1
							GCZ->GCZ_NRGUIA,; //2
							HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2],; //3
							SM0->M0_NOMECOM,; //4
							cHSPCNES,; //5
							{},; //6
							{},; //7
							{},; //8
							{},; //9
							{},; //10
							{},; //11
							{},; //12
							{},; //13
							{},; //14
							{},; //15
							{},; //16
							{},; //17
							{},; //18
							{},; //19
							{},; //20
							nGas,; //21
							nMed,; //22
							nMat,; //23
							0,; //24
							nTax + nAlu,; //25
							nDia,; //26
							nGer}) //27
			For nForDesp := nForGuias To Len(aVtOutDes[7])
				aAdd(aOutDesp[Len(aOutDesp)][06], PLSGETVINC("BTU_CDTERM", "G20", .F., "25", aCodDes[nForDesp]))
				aAdd(aOutDesp[Len(aOutDesp)][07], aVtOutDes[3][nForDesp])
				aAdd(aOutDesp[Len(aOutDesp)][08], aVtOutDes[5][nForDesp])
				aAdd(aOutDesp[Len(aOutDesp)][09], aVtOutDes[5][nForDesp])

				If (aVtOutDes[Len(aVtOutDes)][nForDesp] == "SB1")
					cCodBkp := PLSGETVINC("BTU_CDTERM", "GCA", .F., "87", aVtOutDes[6][nForDesp])
					aAdd(aOutDesp[Len(aOutDesp)][10], cCodBkp )

					If (Alltrim(cCodBkp) == "19")
						cAux := PLSGETVINC("BTU_CDTERM", "SB1", .F., "19", aVtOutDes[2][nForDesp])
						aAdd(aOutDesp[Len(aOutDesp)][11], cAux)
						cAux := PLSGETVINC("BTQ_DESTER", "SB1", .F., "19", cAux)
						If (Alltrim(cCodBkp) == "20")
							cAux := PLSGETVINC("BTU_CDTERM", "SB1", .F., "20", aVtOutDes[2][nForDesp])
							aAdd(aOutDesp[Len(aOutDesp)][11], cAux)
							cAux := PLSGETVINC("BTQ_DESTER", "SB1", .F., "20", cAux)
						EndIf
					Else
						cAux := PLSGETVINC("BTU_CDTERM", "SB1", .F., "20", aVtOutDes[2][nForDesp])
						aAdd(aOutDesp[Len(aOutDesp)][11], cAux)
						cAux := PLSGETVINC("BTQ_DESTER", "SB1", .F., "20", cAux)
					EndIf

					aAdd(aOutDesp[Len(aOutDesp)][20], cAux)
				ElseIf (aVtOutDes[Len(aVtOutDes)][nForDesp] == "GAA")
					aAdd(aOutDesp[Len(aOutDesp)][10], PLSGETVINC("BTU_CDTERM", "GD2", .F., "87", aVtOutDes[6][nForDesp]))

					cAux:= PLSGETVINC("BTU_CDTERM", "GAA", .F., "18", aVtOutDes[2][nForDesp])
					aAdd(aOutDesp[Len(aOutDesp)][11],cAux )
					aAdd(aOutDesp[Len(aOutDesp)][20],PLSGETVINC("BTQ_DESTER", "GAA", .F., "18", cAux))
				Else
					aAdd(aOutDesp[Len(aOutDesp)][10], PLSGETVINC("BTU_CDTERM", "GDB", .F., "87", aVtOutDes[6][nForDesp]))
					
					cAux:= PLSGETVINC("BTU_CDTERM", "GA7", .F., "22", aVtOutDes[2][nForDesp])
					aAdd(aOutDesp[Len(aOutDesp)][11],cAux )
					aAdd(aOutDesp[Len(aOutDesp)][20], PLSGETVINC("BTQ_DESTER", "GA7", .F., "22", cAux))
				EndIf

				aAdd(aOutDesp[Len(aOutDesp)][12], aVtOutDes[4][nForDesp])
				//Unidade de medida
				//GD5_UNICON (PARA mat/MED) Para Taxas e Procedimento "36"
				//GD5_UNICON é um campo virtual que faz relacao com a tabela SAH
				If (Len(aVtOutDes[11]) >= nForDesp)
					aAdd(aOutDesp[Len(aOutDesp)][13], PLSGETVINC("BTU_CDTERM", "SAH", .F., "60", aVtOutDes[11][nForDesp]))
				Else
					aAdd(aOutDesp[Len(aOutDesp)][13], "36") //36 representa a Unidade de Medida "UN-Unidade"
				EndIf
				aAdd(aOutDesp[Len(aOutDesp)][15], aVtOutDes[9][nForDesp])
				aAdd(aOutDesp[Len(aOutDesp)][16], aTotDes[nForDesp])

				//estes dados so existem no array aCpOMM, que é de mat/med
				If (Len(aVtOutDes[12]) >= nForDesp)
					aAdd(aOutDesp[Len(aOutDesp)][17], aVtOutDes[12][nForDesp])
				EndIf
				If (Len(aVtOutDes[13]) >= nForDesp)
					aAdd(aOutDesp[Len(aOutDesp)][18], aVtOutDes[13][nForDesp])
				EndIf
				If (Len(aVtOutDes[14]) >= nForDesp)
					aAdd(aOutDesp[Len(aOutDesp)][19], aVtOutDes[14][nForDesp])
				EndIf
			Next
		Next
	Else
		aOutDesp := {{GA9->GA9_CODOPE,; //1
					  GCZ->GCZ_NRGUIA,; //2
					  SM0->M0_CGC    ,; //3
					  SM0->M0_NOMECOM,; //4
					  GETMV("MV_HSPCNES"),; //5
					  {},; //6
					  {},; //7
					  {},; //8
					  {},; //9
					  {},; //10
					  {},; //11
					  {},; //12
					  {},; //13
					  {},; //14
					  {},; //15
					  {},; //16
					  {},; //17
					  {},; //18
					  {},; //19
					  {},; //20
					  0 ,; //21
					  0 ,; //22
					  0 ,; //23
					  0 ,; //24
					  0 ,; //25
					  0 ,; //26
					  0 }} //27
	EndIf

	PLSTISSH(aOutDesp, nLayout, cLogoGH,,,,lVsTISS)
	 

EndIf

Return(.T.)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ Hs_ImpHInd ³ Autor ³ Gestao Hospitalar     ³ Data ³19.01.2009³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³Impressao da guia de Outras despesas do TISS                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpL1: Tudo Ok                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpC1: Array com o sequenciais das guias                      ³±±
	±±³          ³ExpC2: Posicao da coluna Sequencial da Guia no array de       ³±±
	±±³          ³       Sequencias da Guia                                (OPC)³±±
	±±³          ³ExpC3: Posicao da coluna de marcacao(LBTIK) se imprime guia de³±±
	±±³          ³       honorario individual                              (OPC)³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
Function Hs_ImpHInd(aVetGuia, nPosNrSeqG, nPosHonInd)

	Local aCposPR      	:= {}
	Local nContFor     	:= 0
	Local cAliasG7     	:= ""
	Local aHPR				:= {}
	Local aCPR 			:= {}
	Local nUPR 			:= 0
	Local cTPDIAR 		:= ""
	Local cPPrfTiss 		:= ""
	Local aCoeDes58  		:= {}
	Local cNrSeqG   		:= "",cRegAte   := "", cPaciente := "", cCodPla   := ""
	Local cCodCrm   		:= ""
	Local aSM0Dados 		:= {}
	Local aTot65  		:= {} , aTot66 := {}, aTot67  := {}, aTot68  := {}, aTot69  := {}, aTot70  := {}, aTot85   := {}
	Local nTot35  		:= 0
	Local aAtoMed 		:= {"", ""}, nAtoMed := 0
	Local aVetPR  		:= {}
	Local aVetPrf  		:= {{},{},{},{},{},{},{},{}}
	Local aVetGrPart 		:= {}
	Local nForCol 		:= 0 , nForLin := 0
	Local cCond   		:= ""
	Local aValUni61 		:= {}, aValQtd62 := {}, nValQtd := 0
	Local lExDicINGSEN 	:= HS_ExisDic({{"C", "GA9_INGSEN"}}, .F.)
	Local cCampo3			:= ""
	Local cTissVer 		:= GetNewPar("MV_TISSVER", "2.02.03")
	Default nPosHonInd 	:= 4
	Default nPosNrSeqG 	:= 1

	aListaHI := IIF( (aAuxHI := FS_RetHI(aVetGuia, nPosNrSeqG, nPosHonInd))[1],aAuxHI[2], {})

	IF Empty(aListaHI)
	Return(.F.)
	EndIf

	For nContFor := 1 To Len(aListaHI)
		aHPR := {}
		aCPR := {}
		nUPR := 0

		cNrSeqG := aListaHI[nContFor][1]
		cCodCrm := aListaHI[nContFor][2]

		IIF(Alias()         # "GCZ"  , DbSelectArea("GCZ"), Nil)
		IIF(IndexOrd()      # 1      , DbSetOrder(1), Nil) // GCZ_FILIAL+GCZ_NRSEQG+GCZ_STATUS
		IIF(GCZ->GCZ_NRSEQG # cNrSeqG, DbSeek(xFilial("GCZ") + cNrSeqG), Nil)

		cAliasG7  := IIF(!Empty(cAliasG7) ,cAliasG7 , IIF(GCZ->GCZ_STATUS < "2", "GD7", "GE7"))

		aCposPR := {cAliasG7 + "_CODCRM", cAliasG7 + "_CODATO", cAliasG7 + "_DATDES", cAliasG7 + "_HORDES", cAliasG7 + "_TABELA", ;
			cAliasG7 + "_CODPRT", cAliasG7 + "_DESPRT", cAliasG7 + "_QTDDES", cAliasG7 + "_COEDES", cAliasG7 + "_VALDES", ;
			cAliasG7 + "_COEFAM", cAliasG7 + "_SEQDES", cAliasG7 + "_CODDES", cAliasG7 + "_PGTMED", cAliasG7 + "_GLODES", ;
			cAliasG7 + "_TECUTI"}

		cRegAte   := IIF(!Empty(cRegAte)  ,cRegAte  , GCZ->GCZ_REGATE)
		cPaciente := IIF(!Empty(cPaciente),cPaciente, GCZ->GCZ_REGGER)
		cCodPla   := IIF(!Empty(cCodPla)  ,cCodPla  , GCZ->GCZ_CODPLA)

		cCond   := cAliasG7 + "->" + cAliasG7 + "_NRSEQG == '"+cNrSeqG+"' AND "+ cAliasG7 + "->" + cAliasG7 + "_CODCRM == '"+cCodCrm+"' "

		HS_BDados(cAliasG7, @aHPR, @aCPR, @nUPR, 2,,cCond,,, "/",,,,,, .T.,,,,,, aCposPR )

		IIF(Alias()         # "GCY"  , DbSelectArea("GCY"), Nil)
		IIF(IndexOrd()      # 1      , DbSetOrder(1), Nil)// GCY_FILIAL+GCY_REGATE
		IIf(GCY->GCY_REGATE # cRegAte, DbSeek(xFilial("GCY") + cRegAte), Nil)

		If Empty(aSM0Dados)
			nRECNOSM0 := SM0->(RecNo())
			If !Empty(GCZ->GCZ_FILFAT)
				DbSelectArea("SM0")
				DbSetOrder(1)  // M0_CODIGO + M0_CODFIL
				DbSeek(IIF(FindFunction("FWGRPCompany"), FWGRPCompany(),SM0->M0_CODIGO) + GCZ->GCZ_FILFAT)
			EndIf
			aAdd(aSM0Dados, {SM0->M0_CGC, SM0->M0_NOMECOM, SM0->M0_ENDENT, SM0->M0_COMPENT, SM0->M0_CIDENT, SM0->M0_ESTENT, SM0->M0_CEPENT, GETMV("MV_HSPCNES") })
			SM0->(DbGoTo(nRECNOSM0))
		EndIf

		IIF(Alias()         # "GE8", DbSelectArea("GE8"), Nil)
		IIF(IndexOrd()      # 2, DbSetOrder(2), Nil)  // GE8_FILIAL + GE8_NRSEQG
		IIF(GE8->GE8_NRSEQG # GCZ->GCZ_NRSEQG, DbSeek(xFilial("GE8") + GCZ->GCZ_NRSEQG), Nil)
		cTPDIAR := IIF(GE8->GE8_NRSEQG # GCZ->GCZ_NRSEQG,"",GE8->GE8_TPDIAR)

		IIF(Alias()         # "GD4", DbSelectArea("GD4"), Nil)
		IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GD4_FILIAL + GD4_REGGER + GD4_CODPLA
		DbSeek(xFilial("GD4") + cPaciente + cCodPla)

		IIF(Alias()         # "GCM", DbSelectArea("GCM"), Nil)
		IIF(IndexOrd()      # 2, DbSetOrder(2), Nil) // GCM_FILIAL + GCM_CODPLA
		IIF(GCM->GCM_CODPLA # cCodPla, DbSeek(xFilial("GCM") + cCodPla), Nil)

		IIF(Alias()         # "GA9", DbSelectArea("GA9"), Nil)
		IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GA9_FILIAL+GA9_CODCON
		IIF(GA9->GA9_CODCON # GCM->GCM_CODCON, DbSeek(xFilial("GA9") + GCM->GCM_CODCON), Nil)
		cLogoGH := GA9->GA9_LOGOTP

		IIF(Alias()         # "GBH", DbSelectArea("GBH"), Nil)
		IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GBH_FILIAL + GBH_CODPAC
		IIF(GBH->GBH_CODPAC # cPaciente, DbSeek(xFilial("GBH") + cPaciente), Nil)

		IIF(Alias()         # "GAM", DbSelectArea("GAM"), Nil)
		IIF(IndexOrd()      # 3, DbSetOrder(3), Nil) // GAM_FILIAL + GAM_CEP
		IIF(GAM->GAM_CEP    # SM0->M0_CEPCOB, DbSeek(xFilial("GAM") + SM0->M0_CEPCOB), Nil)

		IIF(Alias()         # "GF4", DbSelectArea("GF4"), Nil)
		IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)   // GF4_FILIAL + GF4_TPALTA
		IIF(GF4->GF4_TPALTA # GCY->GCY_TPALTA, DbSeek(xFilial("GF4") + GCY->GCY_TPALTA), Nil)

		IIF(Alias()         # "GD1", DbSelectArea("GD1"), Nil)
		IIF(IndexOrd()      # 1, DbSetOrder(1), Nil) // GD1_FILIAL + GD1_CARATE
		IIF(GD1->GD1_CARATE # GCY->GCY_CARATE, 	DbSeek(xFilial("GD1") + GCY->GCY_CARATE), Nil)

		IIF(Alias()         # "GBJ", DbSelectArea("GBJ"), Nil)
		IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)  //GBJ_FILIAL + GBJ_CRM
		IIF(GBJ->GBJ_CRM    # aCPR[1, 1], DbSeek(xFilial("GBJ") + aCPR[1, 1]), Nil)

		IIF(Alias()         # "SRA", DbSelectArea("SRA"), Nil)
		IIF(IndexOrd()      # 11, DbSetOrder(11), Nil) // RA_FILIAL + RA_CODIGO
		IIF(SRA->RA_CODIGO  # aCPR[1, 1], DbSeek(xFilial("SRA") + aCPR[1, 1]), Nil)
		aG7Crm := {GBJ->GBJ_CIC, SRA->RA_NOME, GBJ->GBJ_CONSEL, GBJ->GBJ_UFCONS, HS_RetCBO(cCodCrm, GCY->GCY_CODCRM, GCZ->GCZ_CODDES), aCPR[1, 2]}

		IIF(Alias()         # "GBJ", DbSelectArea("GBJ"), Nil)
		IIF(IndexOrd()      # 1, DbSetOrder(1), Nil)  //GBJ_FILIAL + GBJ_CRM
		IIF(GBJ->GBJ_CRM    # cCodCrm, DbSeek(xFilial("GBJ") + cCodCrm), Nil)

		IIF(Alias()         # "SRA", DbSelectArea("SRA"), Nil)
		IIF(IndexOrd()      # 11, DbSetOrder(11), Nil) // RA_FILIAL + RA_CODIGO
		IIF(SRA->RA_CODIGO  # cCodCrm, DbSeek(xFilial("SRA") + cCodCrm), Nil)

		aCoeDes58 := {}
		aValUni61 := {}
		aValQtd62 := {}
		aAdd(aTot65, 0)
		aAdd(aTot66, 0)
		aAdd(aTot67, 0)
		aAdd(aTot68, 0)
		aAdd(aTot69, 0)
		aAdd(aTot70, 0)
		aAdd(aTot85, 0)
		nTot35  := 0

	//Procedimentos
		aAtoMed := {"", ""}

		If cTissVer < "3"
			aVetPR := {}
		EndIf

		For nForCol := 1 To nUPR
			AADD(aVetPR, {})
			aAtoMed := {HS_RetCBO(cCodCrm, GCY->GCY_CODCRM, GCZ->GCZ_CODDES), ""}
			For nForLin := 1 To Len(aCPR)
				If !Empty(aCPR[nForLin, 2])
					cPPrfTiss := IIf(aCPR[nForLin, 1]==cCodCrm,HS_IniPadr('GMC', 1, aCPR[nForLin, 2], 'GMC_PPTISS' ,, .F.),"")
					If val(aCPR[nForLin, 2]) < nAtoMed
						nAtoMed := val(aCPR[nForLin, 2])
					EndIf
				EndIf

				DbSelectArea("GA7")
				DbSetOrder(1) //GA7_FILIAL + GA7_CODPRO
				DbSeek(xFilial("GA7") + aCPR[nForLin, 13])
				If lSomaProc := (((GA7->GA7_TIPPRO $ "1/9" .And. GA7->GA7_HONORA == "1")) .And. !Empty(aCPR[nForLin, 13]) .And. aCPR[nForLin, 14] == "0") //.And. aCPR[nForLin, 15] == "0")
					ASize(aVetPR[nForCol], Len(aVetPR[nForCol]) + 1)
					If nForCol == 3
						aVetPR[nForCol, Len(aVetPR[nForCol])] := aCPR[nForLin, nForCol]
					ElseIf nForCol == 5 .AND. cTissVer < "3"
						DbSelectArea("GDB")
						DbSetOrder(1) //GDB_FILIAL + GDB_CHAVE
						If !Empty(aCPR[nForLin, 5]) .And. DbSeek(xFilial("GDB") + aCPR[nForLin, 5])
							aVetPR[nForCol, Len(aVetPR[nForCol])] := IIF(!Empty(GDB->GDB_TBTISS), GDB->GDB_TBTISS, "00")
						Else
							aVetPR[nForCol, Len(aVetPR[nForCol])] := IIF(!Empty(GA9->GA9_TBTISS), GA9->GA9_TBTISS, "00")
						EndIf
					ElseIf nForCol == 9
						aVetPR[nForCol, Len(aVetPR[nForCol])] := IIf(aCPR[nForLin, nForCol] < 1, aCPR[nForLin, nForCol]*100, 0)
					Else
						aVetPR[nForCol, Len(aVetPR[nForCol])] := aCPR[nForLin, nForCol]
					EndIf
					DbSelectArea("GA7")
					DbSetOrder(1) // GA7_FILIAL + GA7_CODPRO
					DBSeek(xFilial("GA7") + aCPR[nForLin, 13])
					If EMPTY(GA7->GA7_CITISS)
						HS_MsgInf(STR0012 + AllTrim(aCPR[nForLin, 13]) + STR0013, STR0002, STR0014) //"A despesa "###" não está com a classificação do item preenchida."###"Atenção"###"Validação da Guia TISS"
					Return(.F.)
					EndIf

					If !Empty(aCPR[nForLin, 13]) .And. aCPR[nForLin, 14] == "0" .And. nForCol == 10 //.And. aCPR[nForLin, 15] == "0" //pagamento medico nao pode ser repasse direto e o campo _GLODES == normal
						DbSelectArea("G20")
						DbSetOrder(1) //G20_FILIAL + G20_CITISS
						DBSeek(xFilial("G20") + GA7->GA7_CITISS)

						nValQtd := HS_CValDes(cAliasG7, aCPR[nForLin, 12])

						nTot35  += nValQtd
						If lSomaProc
							aTot65[1] += nValQtd
							AADD(aCoeDes58, IIF(aCPR[nForLin, 9] == 1, "U", IIF(aCPR[nForLin, 9] == 0.7, "D", IIF(aCPR[nForLin, 9] == 0.5, "M","U"))) )
							AADD(aValUni61, HS_CValDes(cAliasG7, aCPR[nForLin, 12],,, .T.))
							AADD(aValQtd62, nValQtd)

						Else
							If G20->G20_CODXML $ "04/06"
								aTot66[1] += nValQtd
							ElseIf G20->G20_CODXML == "03"
								aTot67[1] += nValQtd
							ElseIf G20->G20_CODXML == "02"
								aTot68[1] += nValQtd
							ElseIf G20->G20_CODXML == "05"
								aTot69[1] += nValQtd
							ElseIf G20->G20_CODXML == "01"
								aTot70[1] += nValQtd
							EndIf
						EndIf
					EndIf
				EndIf
			Next
		Next

		If nAtoMed == 99
			aAtoMed := {"", ""}
		EndIf

		If lExDicINGSEN
			If GA9->GA9_INGSEN == "1"
				cCampo3 := GCZ->GCZ_NRGUIA
			Else
				cCampo3 := GCZ->GCZ_NRSEN1
			EndIf
		Else
			cCampo3 := GCZ->GCZ_NRSEN1
		EndIf

		If cTissVer < "3"
			aHonInd := {{	GA9->GA9_CODOPE,; //1
			GCZ->GCZ_NRGUIA       ,; //2
			cCampo3				      ,; //3	GCZ->GCZ_NRSEN1
			GCY->GCY_DATATE          ,; //4
			GD4->GD4_MATRIC          ,; //5
			GCM->GCM_DESPLA          ,; //6
			GD4->GD4_DTVALI          ,; //7
			GBH->GBH_NOME            ,; //8
			""                       ,; //9
			HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2],;  //10
			aSM0Dados[1, 2]          ,; //11
			aSM0Dados[1, 8]          ,; //12
			aSM0Dados[1, 1]          ,; //13
			aSM0Dados[1, 2]          ,; //14
			aSM0Dados[1, 8]          ,; //15
			{cTPDIAR, ""}            ,; //16
			cPPrfTiss                ,; //17
			aG7Crm[2]                ,; //18
			GBJ->GBJ_CONSEL          ,; //19
			SRA->RA_CODIGO           ,; //20
			GBJ->GBJ_UFCONS          ,; //21
			GBJ->GBJ_CIC             ,; //22
			aVetPR[3]                ,; //23
			aVetPR[4]                ,; //24
			aVetPR[4]                ,; //25
			aVetPR[5]                ,; //26
			aVetPR[6]                ,; //27
			aVetPR[7]                ,; //28
			aVetPR[8]                ,; //29
			aCoeDes58                ,; //30
			aVetPR[16]               ,; //31
			aVetPR[9]                ,; //32
			aValUni61                ,; //33
			aValQtd62                ,; //34
			nTot35                   ,; //35
			GCZ->GCZ_OBSTIS       ,; //36
			CTOD("")                 ,; //37
			{CTOD(""), "  :  "}      }} //38

			FS_AJSVET(@aHonInd)
			PLSTISS5(aHonInd, lVsTISS, nLayout, cLogoGH)
		Else
			DbSelectArea("GBJ")
			DbSetOrder(1) //GBJ_FILIAL + GBJ_CRM

			For nForCol := Len(aVetPrf[1])+1 To Len(aVetPR[1])
				AaDD(aVetPrf[1], nForCol)
				AaDD(aVetPrf[2], aVetPR[2,nForCol])
				AaDD(aVetPrf[4], aG7Crm[2])
				//AaDD(aVetPrf[6], SRA->RA_CODIGO)
				If DbSeek(xFilial("GBJ") + cCodCrm)
					AaDD(aVetPrf[3], GBJ->GBJ_CIC)
					AaDD(aVetPrf[5], GBJ->GBJ_CONSEL)
					AaDD(aVetPrf[6], GBJ->GBJ_CRM)
					AaDD(aVetPrf[7], GBJ->GBJ_UFCONS)
					AaDD(aVetPrf[8], GBJ->GBJ_CBOTIS)
				Else
					AaDD(aVetPrf[3], "")
					AaDD(aVetPrf[5], "")
					AaDD(aVetPrf[6], "")
					AaDD(aVetPrf[7], "")
					AaDD(aVetPrf[8], "")
				EndIf
			Next
		EndIf

	Next

	//a guia de honorarios esta sendo impressa aqui pois na TISS 3 ela pode conter varios medicos
	If cTissVer >= "3"

		aVetPR[7] := AClone(aVetPR[13])

		aVetPR[5] := HS_AJUSTIS(aVetPR[5], "BTU_CDTERM", "GDB", .F., "87")
		aVetPR[13] := HS_AJUSTIS(aVetPR[13], "BTU_CDTERM", "GA7", .F., "22")
		aVetPR[7] := HS_AJUSTIS(aVetPR[7], "BTQ_DESTER", "GA7", .F., "22")
		aCoeDes58 := HS_AJUSTIS(aCoeDes58, "BTU_CDTERM", "GE4", .F., "61")
		aVetPR[16] := HS_AJUSTIS(aVetPR[16], "BTU_CDTERM", "   ", .F., "48")
		aVetPrf[2] := HS_AJUSTIS(aVetPrf[2], "BTU_CDTERM", "GMC", .F., "35")
		aVetPrf[5] := HS_AJUSTIS(aVetPrf[5], "BTU_CDTERM", "BAH", .F., "26")
		aVetPrf[7] := HS_AJUSTIS(aVetPrf[7], "BTU_CDTERM", "SX5", .F., "59")
		aVetPrf[8] := HS_AJUSTIS(aVetPrf[8], "BTU_CDTERM", "GN1", .F., "24")

		aHonInd := {{	GA9->GA9_CODOPE		 ,; //1
					GCZ->GCZ_NRGUIA      	 ,; //2
					cCampo3				     ,; //3	GCZ->GCZ_NRSEN1
					GCZ->GCZ_NRSEN1			 ,; //4
					GCZ->GCZ_GUIAOP			 ,; //5
					GD4->GD4_MATRIC          ,; //6
					GBH->GBH_NOME            ,; //7
					GCY->GCY_ATERN			 ,; //8
					HS_RetOper(, GCZ->GCZ_CODTPG, GA9->GA9_CODCON)[2],;  //9
					aSM0Dados[1, 2]          ,; //10
					aSM0Dados[1, 8]          ,; //11
					aSM0Dados[1, 1]          ,; //12
					aSM0Dados[1, 2]          ,; //13
					aSM0Dados[1, 8]          ,; //14
					GCZ->GCZ_DCPARI			 ,; //15
					GCZ->GCZ_DCPARF			 ,; //16
					aVetPR[3]                ,; //17
					aVetPR[4]                ,; //18
					aVetPR[4]                ,; //19
					aVetPR[5]				 ,; //20
					aVetPR[13]				 ,; //21
					aVetPR[7]				 ,; //22
					aVetPR[8]                ,; //23
					aCoeDes58				 ,;//24
					aVetPR[16]				 ,;//25
					aVetPR[9]                ,; //26
					aValUni61                ,; //27
					aValQtd62                ,; //28
					aVetPrf[1]				 ,; //29
					aVetPrf[2]				 ,; //30
					aVetPrf[3]				 ,; //31
					aVetPrf[4]				 ,; //32
					aVetPrf[5]				 ,; //33
					aVetPrf[6]				 ,; //34
					aVetPrf[7]				 ,; //35
					aVetPrf[8]				 ,; //36
					GCZ->GCZ_OBSTIS          ,; //37
					nTot35                   ,; //38
					CTOD("")                }} //39

		PLSTISSG(aHonInd, lVsTISS, nLayout, cLogoGH)
	EndIf

Return(.T.)


Static Function FS_AJSVET(aDados)
	Local aItensAux := {}
	Local nTotPos 	:= 0
	Local nTotComp 	:= 0
	Local nI,nU,nY	:= 0

	For nU := 1 To Len(aDados)
		nTotPos := FS_LINTIS(Len(aDados[nU,23]), 10)
		For nY := 23 To 34
			aItensAux := aClone(aDados[nU,nY])
			nTotComp := nTotPos - Len(aDados[nU,nY])
			For nI := 1 To nTotComp
				If ValType(aDados[nU,nY,1]) == "N"
					AADD(aItensAux,0)
				ElseIf ValType(aDados[nU,nY,1]) == "L"
					AADD(aItensAux,.F.)
				Else
					AADD(aItensAux,"")
				EndIf
			Next nI
			aDados[nU,nY] := aItensAux
		Next nY
	Next nU

Return(nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LINTIS ºAutor  ³Rogerio Tabosa      º Data ³  15/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para retornar o total de linhas para o FOR que monta º±±
±±º          ³o Array do campo Observacao da Guia de SPSADT               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_LINTIS(nLenPR, nMulti)
	Local nTotLin := 0

	Default nMulti := 5

	nTotLin  := nMulti


	If nLenPR > nMulti
		If Round(nLenPR/nMulti,0) < (nLenPR/nMulti)
			nTotLin := (Round(nLenPR/nMulti,0)+1)*nMulti
		Else
			nTotLin := Round(nLenPR/nMulti,0)*nMulti
		EndIf
	EndIf

Return(IIf(nLenPR > 0,nTotLin,0))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPGerFiCoºAutor  ³Microsiga           º Data ³  29/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera arquivo texto para controle de lock de registros       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPGerFiCo(cRotContr,cRegistro)

	aInfoUsr := PswRet()
	nHandle := FCREATE(cRotContr+cRegistro+".txt", 0)
	If nHandle <> -1
		fopen(cRotContr+cRegistro+".txt",64)
		FWrite(nHandle,Alltrim(aInfoUsr[1][2]), 25) // Insere texto no arquivo
		fclose(nHandle) // Fecha arquivo
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPGerFiCoºAutor  ³Microsiga           º Data ³  29/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica o usuario que esta locando o registro e exibe      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPVerFiCo(cRotContr,cRegistro,lMsg)
	Local cUsuArq := ""
	Default lMsg := .T.

	nHandle := fopen(cRotContr+cRegistro+".txt" , 64 )
	If nHandle <> -1
		FRead( nHandle, cUsuArq, 25 )
		fclose(nHandle) // Fecha arquivo
	EndIf

	If lMsg
		HS_MsgInf(STR0061+" - "+cUsuArq, STR0002, Funname()) //"O registro está alocado por outro usuário."###"Atencao"###"Funname()"
	EndIf

Return(cUsuArq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPDelFiCoºAutor  ³Microsiga           º Data ³  29/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta arquivo texto para controle de lock de registros     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPDelFiCo(cRotContr,cRegistro)
	Local   cUsuArq := ""

	nHandle := fopen(cRotContr+cRegistro+".txt", 64 )
	If nHandle <> -1
		aInfoUsr := PswRet()
		FRead( nHandle, cUsuArq, 25 )
		fclose(nHandle) // Fecha arquivo
		If Alltrim(cUsuArq) == Alltrim(aInfoUsr[1][2])
			FERASE(cRotContr+Alltrim(cRegistro)+".txt")
		EndIf
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPWheEsp ºAutor  ³ Victor Ferreira    º Data ³  13/03/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o parametro MV_GHALTES para ativar/desativar      º±±
±±º          ³ o campo de especialidade                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPWheEsp()
	Local lRet 	:= .F.

	lRet := Iif(ValType(cGczCodPla) <> "U",GetNewPar("MV_GHALTES",.F.) .And. cGczCodPla $ GetNewPar("MV_PSUSBPA",""),.F.)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPBPATRIGºAutor  ³ Victor Ferreira    º Data ³  13/03/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o parametro MV_GHALTES para executar o gatilho    º±±
±±º          ³ nos campos das tabelas GE7/GD7                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPBPATRIG(cAliBPA,cDom,cConCamp)
	Local aCpos		:= {}
	Local aNum		:= {}
	Local aAux		:= {}
	Local lAltEsp 	:= GetNewPar("MV_GHALTES",.F.) .And. Iif(ValType(cGczCodPla) <> "U",cGczCodPla $ GetNewPar("MV_PSUSBPA",""),.F.)
	Local nX		:= 0
	Local aArea     := GetArea()

	If cDom == "CODDES" .Or. cDom == "CODCRM"
		aAux := TamSx3("GFR_CDESPE")
		aAdd(aCpos,{"CODESP",Space(aAux[1])})
		aAux := TamSx3("GFR_CDESPE")
		aAdd(aCpos,{"NOMESP",Space(aAux[1])})
	Elseif cDom == "CODESP"
		aAdd(aCpos,{"NOMESP",Posicione("GFR",1,xFilial("GFR")+cConCamp,"GFR_DSESPE")})
	Endif

	For nX:= 1 to Len(aCpos)
		aAdd(aNum,aScan(oGDPR:aHeader, {|aVet| aVet[2] == cAliBPA + "_" + aCpos[nX][1]}))
	Next nX

	If lAltEsp
		For nX:= 1 to Len(aCpos)
			oGDPR:aCols[oGDPR:nAt,aNum[nX]]:= aCpos[nX][2]
		Next nX
	Endif

	oGDPR:Refresh()

	RestArea(aArea)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPVLDBPA ºAutor  ³Victor Ferreira     º Data ³  13/03/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa validacao do campo especialidade para atendimentos º±±
±±º          ³ com planos BPA                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPVLDBPA(cAliBPA,cCampo)
	Local cSql 		:= ""
	Local cEspec	:= ""
	Local cCodProc	:= ""
	Local cCodCRM	:= ""
	Local lRet 		:= .F.
	Local lAltEsp	:= GetNewPar("MV_GHALTES",.F.) .And. Iif(ValType(cGczCodPla) <> "U",cGczCodPla $ GetNewPar("MV_PSUSBPA",""),.F.)
	Local nProc		:= 0
	Local nCRM		:= 0
	Local aArea     := GetArea()

	If lAltEsp

		nProc	:= aScan(oGDPR:aHeader, {|aVet| aVet[2] == cAliBPA + "_CODDES"})
		nCRM	:= aScan(oGDPR:aHeader, {|aVet| aVet[2] == cAliBPA + "_CODCRM"})
		cEspec	:= &(cCampo)
		cCodProc:= oGDPR:aCols[oGDPR:nAt,nProc]
		cCodCRM	:= oGDPR:aCols[oGDPR:nAt,nCRM]

		If Empty(cEspec)
		Return .T.
		Endif

		If Empty(cCodCRM)
			HS_MsgInf("Preencha o codigo do CRM do profissional antes de prosseguir", STR0002, "Validação dos Campos")
		Return lRet
		Endif

		cSql := "SELECT GFR_CDESPE CODIGO, GFR_DSESPE ESPECIALIDADE FROM " +RetSqlName("GFR")+ " GFR "
		cSql += "JOIN " + RetSqlName("GHD") + " GHD ON GHD.GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD_CODPRO = '" + cCodProc + "' AND GHD_CODCBO = GFR_CBOSUS AND GHD.D_E_L_E_T_ <> '*' "
		cSql += "JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ_CRM = '" + cCodCRM + "' AND GBJ.D_E_L_E_T_ <> '*' "
		cSql += "LEFT JOIN " + RetSqlName("GFP") + " GFP ON GFP.GFP_FILIAL = '" + xFilial("GFP") + "' AND GFP_CODCRM = '" + cCodCRM + "' AND GFP.D_E_L_E_T_ <> '*' "
		cSql += "LEFT JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7_CODPRO = '" + cCodProc + "' AND GA7_CODESP = GFR_CDESPE AND GA7.D_E_L_E_T_ <> '*' "
		cSql += "WHERE GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND "
		cSql += "(GFR_CDESPE = GBJ_ESPEC1 OR GFR_CDESPE = GBJ_ESPEC2 OR GFR_CDESPE = GBJ_ESPEC3 OR GFR_CDESPE = GFP_CODESP) "
		cSql += "AND GFR.D_E_L_E_T_ <> '*' "
		cSql += "GROUP BY GFR_CDESPE, GFR_DSESPE "
		cSql += "UNION "
		cSql += "SELECT GFR_CDESPE CODIGO, GFR_DSESPE ESPECIALIDADE FROM " +RetSqlName("GFR")+ " GFR "
		cSql += "JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7_CODPRO = '" + cCodProc + "' AND GA7_CODESP = GFR_CDESPE AND GA7.D_E_L_E_T_ <> '*' "
		cSql += "WHERE GFR.GFR_FILIAL = '" + xFilial("GFR") + "'"
		cSql += "GROUP BY GFR_CDESPE, GFR_DSESPE "

		cSql := ChangeQuery(cSql)
		TCQUERY cSql NEW ALIAS "TpVlBPA"

	//Verfica se a especialidade informada e valida a partir dos resultados  da query
		While !TpVlBPA->(Eof())
			If AllTrim(cEspec) == AllTrim(TpVlBPA->CODIGO)
				lRet := .T.
				Exit
			Endif
			TpVlBPA->(dbSkip())
		Enddo

	//Fechando area de trabalho temporaria
		TpVlBPA->(dbCloseArea())

	//Caso nao encontre a especialidade na query o retorno permanece falso e a mensagem de atencao e acionada
		If !lRet .And. !Empty(&(cCampo))
			HS_MsgInf("Especialidade inválida para o profissional selecionado", STR0002, "Validação dos Campos")
		Endif

		RestArea(aArea)

	Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSFLBPAESPºAutor  ³ Victor Ferreira    º Data ³  13/03/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria a consulta padrao dos campos especialidade para as    º±±
±±º          ³ tabelas GD7 e GE7                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSFLBPAESP()
	Local nProc		:= 0
	Local nCRM		:= 0
	Local cAliBPA	:= ""
	Local cSql 		:= ""
	Local cSqlAux	:= ""
	Local cCodProc	:= ""
	Local cCodCRM	:= ""
	Local aIndices 	:= {}
	Local aHeader 	:= {}
	Local oConsulta	:= Nil
	Local lRet 		:= .F.
	Local aArea     := GetArea()

	If aScan(oGDPR:aHeader, {|aVet| SubStr(aVet[2],1,3)  == "GD7"}) > 0
		cAliBPA := "GD7"
	Else
		cAliBPA := "GE7"
	Endif

	nProc	:= aScan(oGDPR:aHeader, {|aVet| aVet[2] == cAliBPA + "_CODDES"})
	nCRM	:= aScan(oGDPR:aHeader, {|aVet| aVet[2] == cAliBPA + "_CODCRM"})

	cCodProc:= oGDPR:aCols[oGDPR:nAt,nProc]
	cCodCRM	:= oGDPR:aCols[oGDPR:nAt,nCRM]

	If Empty(cCodCRM)
		HS_MsgInf("Preencha o codigo do CRM do profissional antes de prosseguir", STR0002, "Validação dos Campos")
	Return lRet
	Endif

	cSql := "SELECT GFR_CDESPE ,GFR_DSESPE FROM " +RetSqlName("GFR")+ " GFR "
	cSql += "JOIN " + RetSqlName("GHD") + " GHD ON GHD.GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD_CODPRO = '" + cCodProc + "' AND GHD_CODCBO = GFR_CBOSUS AND GHD.D_E_L_E_T_ <> '*' "
	cSql += "JOIN " + RetSqlName("GBJ") + " GBJ ON GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ_CRM = '" + cCodCRM + "' AND GBJ.D_E_L_E_T_ <> '*' "
	cSql += "LEFT JOIN " + RetSqlName("GFP") + " GFP ON GFP.GFP_FILIAL = '" + xFilial("GFP") + "' AND GFP_CODCRM = '" + cCodCRM + "' AND GFP.D_E_L_E_T_ <> '*' "
	cSql += "LEFT JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7_CODPRO = '" + cCodProc + "' AND GA7_CODESP = GFR_CDESPE AND GA7.D_E_L_E_T_ <> '*' "
	cSql += "WHERE GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND "
	cSql += "(GFR_CDESPE = GBJ_ESPEC1 OR GFR_CDESPE = GBJ_ESPEC2 OR GFR_CDESPE = GBJ_ESPEC3 OR GFR_CDESPE = GFP_CODESP) "
	cSql += "AND GFR.D_E_L_E_T_ <> '*' "
	cSql += "GROUP BY GFR_CDESPE, GFR_DSESPE "
	cSql += "UNION "
	cSql += "SELECT GFR_CDESPE ,GFR_DSESPE FROM " +RetSqlName("GFR")+ " GFR "
	cSql += "JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7_CODPRO = '" + cCodProc + "' AND GA7_CODESP = GFR_CDESPE AND GA7.D_E_L_E_T_ <> '*' "
	cSql += "WHERE GFR.GFR_FILIAL = '" + xFilial("GFR") + "'"
	cSql += "GROUP BY GFR_CDESPE, GFR_DSESPE "

	cSqlAux := ChangeQuery(cSql)
	TCQUERY cSqlAux NEW ALIAS "TpVlBPA"

//Caso nao encontre a especialidade na query o retorno e falso e a mensagem de atencao e acionada
	If TpVlBPA->(Eof())
		HS_MsgInf("Especialidade inválida para o profissional selecionado", STR0002, "Validação dos Campos")
		TpVlBPA->(dbCloseArea())
	Return lRet
	Endif

	TpVlBPA->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a aHeader da consulta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX3->( dbSetOrder( 2 ) )
	SX3->( dbGotop(  ) )

	If SX3->( dbSeek( "GFR_CDESPE", .F. ) )
		Aadd(aHeader,{X3TITULO(),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Cod. Especialidade"
		aAdd( aIndices, {"GFR_CDESPE",X3TITULO()})
	Endif

	If SX3->( dbSeek( "GFR_DSESPE", .F. ) )
		Aadd(aHeader,{X3TITULO(),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Descr. Especialidade"
		aAdd( aIndices, {"GFR_DSESPE",X3TITULO()})
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a consulta padrao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oConsulta				:= HSPCONESP():New()
	oConsulta:cTitle 		:= "Especialidades" 		//Titulo da Consulta
	oConsulta:cQuery 		:= cSql						//Query dos dados a serem apresentados
	oConsulta:aIndex 		:= aIndices					//Indices disponiveis (deve usar os mesmos campos da query)
	oConsulta:aHeader 		:= aHeader                  //Header da grid presente consulta (deve usar os mesmos campos da query)
	oConsulta:aReturn		:= {"GFR_CDESPE"}			//Campos de retorno da consulta (deve usar os mesmos campos da query)
	oConsulta:lDataBaseRM 	:= .T.						//Indica se a query eh executada na base do protheus ou da RM
	oConsulta:Show()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coleta o retorno³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(oConsulta:aRetSXB) > 0
		cRetSxb := oConsulta:aRetSXB[1]
		lRet	:=.T.
	EndIf

	RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSFLBPAPROºAutor  ³ Victor Ferreira    º Data ³  13/03/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria a consulta padrao dos campos profissional  para as    º±±
±±º          ³ tabelas GD7 e GE7                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSFLBPAPRO()
	Local nProc		:= 0
	Local cAliBPA	:= ""
	Local cSql 		:= ""
	Local cSqlAux	:= ""
	Local cCodProc	:= ""
	Local cCodEsp	:= ""
	Local aIndices 	:= {}
	Local aHeader 	:= {}
	Local oConsulta	:= Nil
	Local lRet 		:= .F.
	Local aArea     := GetArea()
	Local lAltEsp 	:= GetNewPar("MV_GHALTES",.F.) .And. Iif(ValType(cGczCodPla) <> "U",cGczCodPla $ GetNewPar("MV_PSUSBPA",""),.F.)

	If aScan(oGDPR:aHeader, {|aVet| SubStr(aVet[2],1,3)  == "GD7"}) > 0
		cAliBPA := "GD7"
	Else
		cAliBPA := "GE7"
	Endif

	nProc	:= aScan(oGDPR:aHeader, {|aVet| aVet[2] == cAliBPA + "_CODDES"})

	cCodProc:= oGDPR:aCols[oGDPR:nAt,nProc]

	cCodEsp:= Posicione("GA7",1,xFilial("GA7")+cCodProc, "GA7_CODESP")

	If lAltEsp
		cSql += "SELECT RA_CODIGO, RA_NOME FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = '" + xFilial("SRA")
		cSql += "' AND RA_CODIGO <> '" + Space(Len(SRA->RA_CODIGO)) + "' AND (RA_CODIGO IN"
		cSql += "(SELECT GBJ.GBJ_CRM FROM " + RetSqlName("GBJ") + " GBJ "
		cSql += "LEFT JOIN " + RetSqlName("GFP") + " GFP ON GFP_FILIAL = '" + xFilial("GFP") + "' AND GFP.GFP_CODCRM = GBJ.GBJ_CRM AND GFP.D_E_L_E_T_ <> '*' "
		cSql += "WHERE GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' "
		cSql += "AND GBJ.GBJ_STATUS = '1' AND GBJ_ESPEC1 IN "
		cSql += "(SELECT GFR_CDESPE ESP01 FROM " + RetSqlName("GA7") + " GA7 "
		cSql += "LEFT JOIN " + RetSqlName("GHD") + " GHD ON GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD.GHD_CODPRO = GA7.GA7_CODPRO AND GHD.D_E_L_E_T_ <> '*' "
		cSql += "INNER JOIN " + RetSqlName("GFR") + " GFR ON GFR_FILIAL = '" + xFilial("GFR") + "' AND (GFR.GFR_CDESPE = GA7.GA7_CODESP OR GFR.GFR_CBOSUS = GHD.GHD_CODCBO) AND GFR.D_E_L_E_T_ <> '*' "
		cSql += "WHERE GA7.GA7_CODPRO = '" + cCodProc + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' GROUP BY GFR_CDESPE)"
		cSql += "OR GBJ_ESPEC2 IN "
		cSql += "(SELECT GFR_CDESPE ESP02 FROM " + RetSqlName("GA7") + " GA7 "
		cSql += "LEFT JOIN " + RetSqlName("GHD") + " GHD ON GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD.GHD_CODPRO = GA7.GA7_CODPRO AND GHD.D_E_L_E_T_ <> '*' "
		cSql += "INNER JOIN " + RetSqlName("GFR") + " GFR ON GFR_FILIAL = '" + xFilial("GFR") + "' AND (GFR.GFR_CDESPE = GA7.GA7_CODESP OR GFR.GFR_CBOSUS = GHD.GHD_CODCBO) AND GFR.D_E_L_E_T_ <> '*' "
		cSql += "WHERE GA7.GA7_CODPRO = '" + cCodProc + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' GROUP BY GFR_CDESPE)"
		cSql += "OR GBJ_ESPEC3 IN "
		cSql += "(SELECT GFR_CDESPE ESP03 FROM " + RetSqlName("GA7") + " GA7 "
		cSql += "LEFT JOIN " + RetSqlName("GHD") + " GHD ON GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD.GHD_CODPRO = GA7.GA7_CODPRO AND GHD.D_E_L_E_T_ <> '*' "
		cSql += "INNER JOIN " + RetSqlName("GFR") + " GFR ON GFR_FILIAL = '" + xFilial("GFR") + "' AND (GFR.GFR_CDESPE = GA7.GA7_CODESP OR GFR.GFR_CBOSUS = GHD.GHD_CODCBO) AND GFR.D_E_L_E_T_ <> '*' "
		cSql += "WHERE GA7.GA7_CODPRO = '" + cCodProc + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' GROUP BY GFR_CDESPE)"
		cSql += "OR GFP_CODESP IN "
		cSql += "(SELECT GFR_CDESPE ESPN FROM " + RetSqlName("GA7") + " GA7 "
		cSql += "LEFT JOIN " + RetSqlName("GHD") + " GHD ON GHD_FILIAL = '" + xFilial("GHD") + "' AND GHD.GHD_CODPRO = GA7.GA7_CODPRO AND GHD.D_E_L_E_T_ <> '*' "
		cSql += "INNER JOIN " + RetSqlName("GFR") + " GFR ON GFR_FILIAL = '" + xFilial("GFR") + "' AND (GFR.GFR_CDESPE = GA7.GA7_CODESP OR GFR.GFR_CBOSUS = GHD.GHD_CODCBO) AND GFR.D_E_L_E_T_ <> '*' "
		cSql += "WHERE GA7.GA7_CODPRO = '" + cCodProc + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' GROUP BY GFR_CDESPE) "
		cSql += "GROUP BY GBJ.GBJ_CRM) AND D_E_L_E_T_ <> '*' )"
	Else
		cSql += "SELECT RA_CODIGO, RA_NOME FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = '" + xFilial("SRA") "
		cSql += "' AND RA_CODIGO <> '" + Space(Len(SRA->RA_CODIGO)) + "' AND (RA_CODIGO IN "
		cSql += "(SELECT GBJ.GBJ_CRM FROM " + RetSqlName("GBJ") + " GBJ "
		cSql += "WHERE GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' AND "
		cSql += "GBJ.GBJ_STATUS = '1'"

		If Type("cGbjCodEsp") # "U" .And. !Empty(cGbjCodEsp)
			cSql += "AND '" + cGbjCodEsp + "' IN (GBJ.GBJ_ESPEC1, GBJ.GBJ_ESPEC2, GBJ.GBJ_ESPEC3)) "
			cSql += "OR RA_CODIGO IN "
			cSql += "(SELECT GFP.GFP_CODCRM FROM " + RetSqlName("GFP") + " GFP, " + RetSqlName("GBJ") + " GBJ "
			cSql += "WHERE GFP.GFP_FILIAL = '" + xFilial("GFP") + "' AND GFP.D_E_L_E_T_ <> '*' AND GFP.GFP_CODCRM = GBJ_CRM AND "
			cSql += "GFP.GFP_CODESP = '" + cGbjCodEsp + "' "
		EndIf

		If Type("cGbjTipPro") # "U" .And. !Empty(cGbjTipPro)
			cSql += "AND GBJ.GBJ_TIPPRO IN (" + HS_InSql(cGbjTipPro) + ") "
		EndIf

		cSql += "))"
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a aHeader da consulta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX3->( dbSetOrder( 2 ) )
	SX3->( dbGotop(  ) )

	If SX3->( dbSeek( "RA_CODIGO", .F. ) )
		Aadd(aHeader,{X3TITULO(),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Cod. Especialidade"
		aAdd( aIndices, {"RA_CODIGO",X3TITULO()})
	Endif

	If SX3->( dbSeek( "RA_NOME", .F. ) )
		Aadd(aHeader,{X3TITULO(),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Descr. Especialidade"
		aAdd( aIndices, {"RA_NOME",X3TITULO()})
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a consulta padrao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oConsulta				:= HSPCONESP():New()
	oConsulta:cTitle 		:= "Profissionais"	 		//Titulo da Consulta
	oConsulta:cQuery 		:= cSql						//Query dos dados a serem apresentados
	oConsulta:aIndex 		:= aIndices					//Indices disponiveis (deve usar os mesmos campos da query)
	oConsulta:aHeader 		:= aHeader                  //Header da grid presente consulta (deve usar os mesmos campos da query)
	oConsulta:aReturn		:= {"RA_CODIGO"}			//Campos de retorno da consulta (deve usar os mesmos campos da query)
	oConsulta:lDataBaseRM 	:= .T.						//Indica se a query eh executada na base do protheus ou da RM
	oConsulta:Show()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coleta o retorno³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(oConsulta:aRetSXB) > 0
		cRetCrm := oConsulta:aRetSXB[1]
		lRet	:=.T.
	EndIf

	RestArea(aArea)

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºClasse	 ³HSPCONESP ºAutor  ³                    º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Interface padrao para elaboracao de consultas padrao de tabeº±±
±±º          ³las que intermediarias da integracao Protheus x Classis. Tamº±±
±±º          ³bem se aplica a tabelas do banco de dados do CorporeRM      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPremissas ³1 - Chaves utilizadas nao podem conter campos numericos.    º±±
±±º          ³2 - aHeader deve estar no mesmo layout do padrao microsiga. º±±
±±º          ³3 - Layout de aIndexes deve ser {x1 - Chave, x2 - Descricao}º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Integracao Microsiga Protheus x Rm ClassisNet               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Class HSPCONESP
	Data oDlg	   			//Formulario "Dialog" principal
	Data oCmbIndP			//ComboBox de Indices exibidos
	Data oBtnPsq			//Botao Pesquisar
	Data oGetDds			//GetDados com os itens da consulta
	Data oGetExp			//Get com a expressao a ser buscada
	Data cTitle				//Titulo da consulta Padrao
	Data cQuery				//Query dos itens a buscar
	Data lDataBaseRM		//Consulta eh feita no banco da RM - Default .F.
	Data aHeader			//Header da grid da consulta padrao
	Data aIndex				//Indices da consulta {x1= Chave,x2=Descricao}
	Data aReturn			//Campos a serem retornados pela consulta
	Data cIndPesq			//RESERVADO - Indice utilizado na pesquisa
	Data cExpres			//RESERVADO - Expressao a ser buscada
	Data aCols				//RESERVADO - Itens da getDados buscada
	Data aRetSXB			//RESERVADO - Retorno definido

	Method New() CONSTRUCTOR
	Method LoadData()
	Method ReLoadData()
	Method LoadInterface()
	Method Search()
	Method Show()
	Method setReturn()

EndClass
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method New 	                                              º±±
±±º          ³ Metodo Construtor da classe HSPCONESP                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New() Class HSPCONESP

	::oDlg	   		:= Nil
	::oCmbIndP		:= Nil
	::oBtnPsq		:= Nil
	::oGetDds		:= Nil
	::cTitle		:= ""
	::cQuery		:= ""
	::aRetSXB		:= {}
	::aReturn		:= {}
	::aHeader		:= {}
	::aCols			:= {}
	::aIndex		:= {}
	::cIndPesq		:= ""
	::cExpres		:= Space(300)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method Show 	                                              º±±
±±º          ³ Exibe a Consulta Padrao				                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Show() class HSPCONESP
	If ::oDlg == Nil
		::LoadInterface()
	Endif

	If Select('TRQ') <= 0
		::LoadData()
	Endif

	::oDlg:Activate()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method LoadData                                            º±±
±±º          ³ Executa a query e grava na aCols 	                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LoadData() class HSPCONESP
	Local aStruct := {}
	Local nI := 0
	Local nJ := 0
	Local cMacro := ""
	Local nAmbTOP,nAmbCLASSIS
	Local cIndSel := ::aIndex[::oCmbIndP:nAt,1]
	Local cQryAux := ""
	Private aColsAux := {}

	If !Empty(::cQuery)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona a ordenacao de acordo com o indice escolhido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! "ORDER BY" $ upper(::cQuery)
			cQryAux += ::cQuery + " ORDER BY "
			For nI:= 1 to len(cIndSel)
				If substr(cIndSel,nI,1) != "+"
					cQryAux += substr(cIndSel,nI,1)
				else
					cQryAux += ","
				endif
			Next nI
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a query³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQryAux := ChangeQuery(cQryAux)
		iif(Select('QRY')>0,QRY->(dbCloseArea()),Nil)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryAux),'QRY', .F., .T.)
		dbSelectArea('QRY')

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem a estrutura da tabela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aStruct := QRY->(dbStruct())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona os registros na aCols Auxiliar³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aColsAux := {}
		nI := 1
		While QRY->(!Eof())
			cMacro := "aAdd(aColsAux,{"

	        //Adiciona cada campo da query
			For ni := 1 to len(aStruct)
				cMacro += "QRY->" + alltrim(aStruct[nI,1])

				//Adiciona a virgula ou fecha o bloco se for ultimo campo
				if nI < len(aStruct)
					cMacro += ","
				else
					cMacro += ",.F.})"
				endif
			Next nI

			//Executa a macro montada, (adiciona na aCols Auxiliar)
			&(cMacro)

			QRY->(dbSkip())
		EndDo
		QRY->(dbCloseArea())

		//Copia a aCols auxiliar para a aCols da classe HSPCONESP
		::aCols := aClone(aColsAux)
		::oGetDds:aCols := aClone(aColsAux)
		::oGetDds:Refresh()
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method ReLoadData                                          º±±
±±º          ³ Recarrega os dados de acordo com o indice                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method ReloadData() class HSPCONESP
	if ValType(::oGetDds) == "O"
		::LoadData()
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method LoadInterface                                       º±±
±±º          ³ Realiza a pintura da dialog da consulta                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method LoadInterface() class HSPCONESP
	Local aIndAux := {}
	Local nI := 0
	Local lOk := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona os indices na variavel auxiliar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to len(::aIndex)
		aAdd(aIndAux,::aIndex[nI,2])
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a tela da consulta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	::oDlg:= MSDIALOG():Create()
	::oDlg:cName     := "oDlg"
	::oDlg:cCaption  := ::cTitle
	::oDlg:nLeft     := 0
	::oDlg:nTop      := 10
	::oDlg:nWidth    := 507
	::oDlg:nHeight   := 440
	::oDlg:lShowHint := .F.
	::oDlg:lCentered := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a Combo "Indice"		       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	::oCmbIndP:= TCOMBOBOX():Create(::oDlg)
	::oCmbIndP:cName 	  	  	:= "oCmbIndP"
	::oCmbIndP:nLeft 	  	  	:= 10
	::oCmbIndP:nTop 	  		:= 8
	::oCmbIndP:nWidth 	  		:= 380
	::oCmbIndP:nHeight   		:= 22
	::oCmbIndP:lShowHint 		:= .F.
	::oCmbIndP:lReadOnly 		:= .F.
	::oCmbIndP:Align 	  		:= 0
	::oCmbIndP:cVariable 		:= "::cIndPesq"
	::oCmbIndP:bSetGet   		:= {|u| If(PCount()>0,::cIndPesq:=u,::cIndPesq)}
	::oCmbIndP:lVisibleControl 	:= .T.
	::oCmbIndP:aItems    		:= aIndAux
	::oCmbIndP:bWhen     		:= {|| .T.}
	::oCmbIndP:bChange			:= {|| ::ReLoadData() }
	::oCmbIndP:nAt				:= 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o Get "Expressao"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	::oGetExp:= TGET():Create(::oDlg)
	::oGetExp:cName 	 		:= "oGetExp"
	::oGetExp:nLeft 	 		:= 10
	::oGetExp:nTop 	 	   		:= 35
	::oGetExp:nWidth 	 		:= 380
	::oGetExp:nHeight 	 		:= 22
	::oGetExp:lShowHint 		:= .F.
	::oGetExp:lReadOnly 		:= .F.
	::oGetExp:Align 	 		:= 0
	::oGetExp:lVisibleControl 	:= .T.
	::oGetExp:lPassword 		:= .F.
	::oGetExp:lHasButton		:= .F.
	::oGetExp:cVariable 		:= "::cExpres"
	::oGetExp:bSetGet 	 		:= {|u| If(PCount()>0,::cExpres:=u,::cExpres)}
	::oGetExp:Picture   		:= "@!"
	::oGetExp:bWhen     		:= {|| .T.}
	::oGetExp:bChange			:= {|| .T.}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o botao Pesquisar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	::oBtnPsq:= TButton():Create(::oDlg)
	::oBtnPsq:cName 		:= "oBtnPsq"
	::oBtnPsq:cCaption 		:= "Pesquisar"
	::oBtnPsq:nLeft 		:= 400
	::oBtnPsq:nTop  		:= 8
	::oBtnPsq:nWidth    	:= 90
	::oBtnPsq:nHeight 		:= 22
	::oBtnPsq:lShowHint 	:= .F.
	::oBtnPsq:lReadOnly 	:= .F.
	::oBtnPsq:Align 		:= 0
	::oBtnPsq:bAction 		:= {|| ::Search() }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a getDados Alunos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	::oGetDds:= MsNewGetDados():New( 33, 5, 185, 244 ,GD_UPDATE, /*cLinhaOk*/, /*cTudoOk*/,/*incremento*/,/*aAltera*/,/*lVazio*/,999,/*cCampoOk*/,/*Superdel*/,/*cApagaOk*/,::oDlg,::aHeader,::aCols)
	::oGetDds:oBrowse:bLdblClick := {||  ::oDlg:End(), ::setReturn() }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o botao Cancel³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBtnCancel := SButton():Create(::oDlg)
	oBtnCancel:cName	:= "oBtnCancel"
	oBtnCancel:nLeft	:= 75
	oBtnCancel:nTop		:= 380
	oBtnCancel:nWidth	:= 30
	oBtnCancel:nHeight	:= 24
	oBtnCancel:nType	:= 02
	oBtnCancel:bAction	:= {|| ::oDlg:End() }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o botao OK³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBtnOK := SButton():Create(::oDlg)
	oBtnOK:cName	:= "oBtnOk"
	oBtnOK:nLeft	:= 13
	oBtnOK:nTop		:= 380
	oBtnOK:nWidth	:= 30
	oBtnOK:nHeight	:= 24
	oBtnOK:nType	:= 01
	oBtnOk:bAction	:= {|| ::oDlg:End(), ::setReturn() }

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method Search		                                      º±±
±±º          ³Busca por um registro na getDados de acordo com a expressao º±±
±±º          ³informada. (Busca do SXB)									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Search() class HSPCONESP
	Local nI 		:= 0
	Local nJ		:= 0
	Local cIndSel 	:= ::aIndex[::oCmbIndP:nAt,1]
	Local aCmpInd  	:= {}
	Local aPosicoes := {}
	Local cAux 		:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Coleta todos os campos do indice escolhido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to len(cIndSel)
		if substr(cIndSel,nI,1) != "+"
			cAux += substr(cIndSel,nI,1)
		else
			aAdd(aCmpInd,alltrim(cAux))
			cAux := ""
		endif
	Next ni
	aAdd(aCmpInd,alltrim(cAux))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Coleta as posicoes dos campos do indice escolhido dentro da aHeader³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to len(aCmpInd)
		For nJ := 1 to len(::aHeader)
			If alltrim(upper(::aHeader[nJ,2])) == alltrim(upper(aCmpInd[nI]))
				aAdd(aPosicoes,nJ)
				exit
			EndIf
		Next nJ
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a expressao a partir das posicoes coletadas e compara com a expressao do usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAux := ""
	For nI := 1 to len(::oGetDds:aCols)
		//Coleta o valor da linha, somando somente os campos que compoe o indice
		For nJ := 1 to len(aPosicoes)
			cAux += ::oGetDds:aCols[nI,aPosicoes[nJ]]
		Next

		If rtrim(::cExpres) $ cAux
			::oGetDds:oBrowse:nAt := nI
			exit
		Else
			cAux := ""
		Endif
	Next nI

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Microsiga           º Data ³  29/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Method setReturn		                                      º±±
±±º          ³Define o conteudo de retorno da consulta					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method setReturn() class HSPCONESP
	Local nPosCmp	:= 0
	Local nI		:= 0
	Local nJ		:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Coleta a posicao do campo de retorno³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(::aReturn) > 0
		For nI := 1 to len(::aReturn)
			For nJ := 1 to len(::aHeader)
				If alltrim(upper(::aReturn[nI])) == alltrim(upper(::aHeader[nJ,2]))
					nPosCmp := nJ
					exit
				EndIf
			Next nJ

			If nPosCmp > 0 .And. Len(::oGetDds:aCols) > 0
				aAdd(::aRetSXB,::oGetDds:aCols[::oGetDds:oBrowse:nAt,nPosCmp])
			EndIf
			nPosCmp := 0
		Next nI
	EndIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVINARRTºAutor  ³Bruno Iserhardt     º Data ³  27/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta o objeto(array, string, inteiro) enviado para o     º±±
±±º          ³ representar os códigos da TISS.                            º±±
±±º          ³ Tem os mesmos parametros da funcao PLSGETVINC mais o       º±±
±±º          ³ o objeto a ser alterado.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Utilizado para ajusar os dados enviados para os relatórios º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_AJUSTIS(oObj, cColuna, cAlias, lMsg, cCodTab)
Local i

If (ValType(oObj) == "A")
	For i := 1 To Len(oObj)
		oObj[i] := HS_AJUSTIS(oObj[i], cColuna, cAlias, lMsg, cCodTab)
	Next
ElseIf (ValType(oObj) == "C")
	If !Empty(ALLTRIM(oObj))
		oObj := PLSGETVINC(cColuna, cAlias, lMsg, cCodTab , IIF(cCodTab == "59", "12", "")+oObj)
	EndIf
EndIf

i := i

return oObj

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_TabTISSºAutor  ³Bruno Iserhardt     º Data ³  25/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o código da Tabela TISS que o item pertence.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ nTpItem: Tipo do item que foi enviado no cCodProth         º±±
±±º          ³ 1 = Mat/Med, 2 = Taxa, 3 = Procedimento                    º±±
±±º          ³ cCodProth: Código do item no protheus                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_TabTISS(nTpItem, cCodProth)
Local cRet := ""

If nTpItem == 1 //Mat/Med
	cRet := PLSGETVINC("BTU_CDTERM", "GCA", .F., "87", cCodProth)
ElseIf nTpItem == 2 //Taxa
	cRet := PLSGETVINC("BTU_CDTERM", "GD2", .F., "87", cCodProth)
ElseIf nTpItem == 3 //Procedimento
	cRet := PLSGETVINC("BTU_CDTERM", "GDB", .F., "87", cCodProth)
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_TabTISSºAutor  ³Bruno Iserhardt     º Data ³  25/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o código ou descrição do item TISS.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ nTpItem: Tipo do item que foi enviado no cCodProth         º±±
±±º          ³ 1 = Mat/Med, 2 = Taxa, 3 = Procedimento                    º±±
±±º          ³ cCodProth: Código do item no protheus                      º±±
±±º          ³ nTpRet: Tipo de retorno TISS. 1 = Código 2 = Descrição     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_ODspItm(nTpItem, cCodProth, nTpRet)
Local cRet := ""
Local cTpRet := IIF(nTpRet == 1, "BTU_CDTERM", "BTQ_DESTER")

If nTpItem == 1 //Mat/Med
	cRet := PLSGETVINC(cTpRet, "SB1", .F., "19", cCodProth)
	If Empty(cRet)
		cRet := PLSGETVINC(cTpRet, "SB1", .F., "20", cCodProth)
	EndIf
ElseIf nTpItem == 2 //Taxa
	cRet := PLSGETVINC(cTpRet, "GAA", .F., "18", cCodProth)
ElseIf nTpItem == 3 //Procedimento
	cRet := PLSGETVINC(cTpRet, "GA7", .F., "22", cCodProth)
EndIf

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PLSTISS6  ³ Autor ³ Luciano Aparecido     ³ Data ³ 26.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estrutura Relatório TISS (Guia Outras Despesas)-BOPS 095189 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aDados - Array com as informações do relat´rio              ³±±
±±³          ³ lGerTXT - Define se imprime direto sem passar pela tela 	   ³±±
±±³          ³			 de configuracao/preview do relatorio 		       ³±±
±±³          ³ nLayout - Define o formato de papél para impressao:         ³±±
±±³          ³           1 - Formato Ofício II (216x330mm)                 ³±±
±±³          ³           2 - Formato A4 (210x297mm)                        ³±±
±±³          ³  		 3 - Formato Carta (216x279mm)     			       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSTISS6(aDados, lGerTXT, nLayout, cLogoGH, lAuto)

	Local nLinMax
	Local nColMax
	Local nLinIni	:=	0		// Linha Lateral (inicial) Esquerda
	Local nColIni	:=	0		// Coluna Lateral (inicial) Esquerda
	Local nColA4    :=  0
	Local cFileLogo
	Local lPrinter
	Local nOldLinIni
	Local nI, nJ, nX
	Local oFont01
	Local oFont02n
	Local oFont03n
	Local oFont04
	Local cFileName := ""

	Default nLayout := 2
	Default lGerTXT := .F.
	Default cLogoGH := ''
	Default lAuto   := .F.
	Default aDados := { { ;
						"123456",;
						"12345678901234567892",;
						"14.141.114/00001-35",;
						Replicate("M",70),;
						"1234567",;
						{ "1","1","1","1","1","1","1","1","1","1","1","1","1" },;
						{ CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06"),CtoD("12/03/06") },;
						{ "0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507" },;
						{ "0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507","0507" },;
						{ "MM","AA","BB","CC","DD","DD","DD","DD","DD","DD","DD","DD","DD"},;
						{ "5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234","5678901234"},;
						{ 4,4,4,4,4,4,4,4,4,4,4,4,4},;
						{ 999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99,999.99 },;
						{ 11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,11111.11,911111.11,911111.11,911111.11,911111.11,911111.11,911111.11 },;
						{ 88888.00,88888.00,88888.00,88888.00,88888.00,88888.00,88888.00,88888.00,911111.11,911111.11,911111.11,911111.11,911111.11 },;
						{ Replicate("M",60),Replicate("W",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60),Replicate("E",60)},;
						3999999.99,;
						3999999.99,;
						3999999.99,;
						3999999.99,;
						3999999.99,;
						3999999.99,;
						3999999.99 } }

	If nLayout  == 1 // Ofício 2
		nLinMax := 2435
		nColMax := 3705
	Elseif nLayout == 2   // Papél A4
	   	nLinMax	:=	2375
		nColMax	:=	3370 //3365
	Else //Carta
		nLinMax	:=	2435
		nColMax	:=	3175
	Endif

	oFont01		:= TFont():New("Arial",  6,  6, , .F., , , , .T., .F.) // Normal
	if nLayout == 1 // Oficio 2
		oFont02n	:= TFont():New("Arial", 12, 12, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 14, 14, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 09, 09, , .F., , , , .T., .F.) // Normal
	Else  // Papél A4 ou Carta
	  	oFont02n	:= TFont():New("Arial", 11, 11, , .T., , , , .T., .F.) // Negrito
		oFont03n	:= TFont():New("Arial", 13, 13, , .T., , , , .T., .F.) // Negrito
		oFont04		:= TFont():New("Arial", 08, 08, , .F., , , , .T., .F.) // Normal
	Endif

	if lAuto
		cPathSrvJ := GETMV("MV_RELT")
		cFileName := "pdfauto"+lower(CriaTrab(NIL,.F.))+".pdf"
		oPrint    := FWMSPrinter():New ( cFileName,,.F., cPathSrvJ,.T.,nil,@oPrint,nil,nil,.F.,.F.)
		oPrint:lServer := .T.
		oPrint:cPathPDF := cPathSrvJ
	else
		oPrint	:= TMSPrinter():New(STR0231) //"GUIA DE OUTRAS DESPESAS"
	endIf
	
	oPrint:SetLandscape()		// Modo paisagem

	if nLayout ==2
		oPrint:SetPaperSize(9)// Papél A4
	Elseif nLayout ==3
		oPrint:SetPaperSize(1)// Papél Carta
	Else
		oPrint:SetPaperSize(14) //Papel Oficio2 216 x 330mm / 8 1/2 x 13in
	Endif

	// Verifica se existe alguma impressora configurada para Impressao Grafica
	lPrinter := oPrint:IsPrinterActive()

	If lAuto
		oPrint:setDevice(IMP_PDF)
		oPrint:lPDFAsPNG := .T.
	ElseIf ! lPrinter
		oPrint:Setup()
	EndIf

	For nX := 1 To Len(aDados)

		If ValType(aDados[nX]) == 'U' .OR. Len(aDados[nX]) == 0
			Loop
		EndIf

		For nI := 6 To 16
			If Len(aDados[nX, nI]) < 20
				For nJ := Len(aDados[nX, nI]) + 1 To 20
					If AllTrim(StrZero(nI, 2, 0)) $ "07"
						aAdd(aDados[nX, nI], StoD(""))
					ElseIf AllTrim(StrZero(nI, 2, 0)) $ "12,13,14,15"
						aAdd(aDados[nX, nI], 0)
					Else
						aAdd(aDados[nX, nI], "")
					EndIf
				Next nJ
			EndIf
		Next nI

		nLinIni := 0
		nColIni := 0
		nColA4  := 0

		oPrint:StartPage()		// Inicia uma nova pagina
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Box Principal                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Box(nLinIni + 0000, nColIni + 0000, nLinIni + nLinMax, nColIni + nColMax)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega e Imprime Logotipo da Empresa                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fLogoEmp(@cFileLogo,, cLogoGH)

		If File(cFilelogo)
			oPrint:SayBitmap(nLinIni + 0050, nColIni + 0020, cFileLogo, 400, 090) 		// Tem que estar abaixo do RootPath
		EndIf

		If nLayout == 2 // Papél A4
			nColA4    := -0335
		Elseif nLayout == 3// Carta
			nColA4    := -0530
		Endif

		oPrint:Say(nLinIni + 0080, nColIni + 1852 + IIF(nLayout == 2 .Or. nLayout == 3,nColA4+140,0), STR0231, oFont02n,,,, 2) //"GUIA DE OUTRAS DESPESAS"

		nLinIni += 60
		oPrint:Box(nLinIni + 0175, nColIni + 0010, nLinIni + 0269, nColIni + 0315)
		oPrint:Say(nLinIni + 0180, nColIni + 0020, "1 - "+STR0003, oFont01) //"Registro ANS"
		oPrint:Say(nLinIni + 0210, nColIni + 0030, aDados[nX, 01], oFont04)
		oPrint:Box(nLinIni + 0175, nColIni + 0320, nLinIni + 0269, nColIni + 1035)
		oPrint:Say(nLinIni + 0180, nColIni + 0330, "2 - "+STR0232, oFont01) //"Nº Guia Referenciada"
		oPrint:Say(nLinIni + 0210, nColIni + 0340, aDados[nX, 02], oFont04)

		nLinIni += 20
		oPrint:Say(nLinIni + 0274, nColIni + 0010, STR0079, oFont01) //"Dados do Contratado Executante"
		oPrint:Box(nLinIni + 0304, nColIni + 0010, nLinIni + 0398, nColIni + 0426)
		oPrint:Say(nLinIni + 0309, nColIni + 0020, "3 - "+STR0012, oFont01) //"Código na Operadora / CNPJ / CPF"
		oPrint:Say(nLinIni + 0339, nColIni + 0030, aDados[nX, 03], oFont04)
		oPrint:Box(nLinIni + 0304, nColIni + 0431, nLinIni + 0398, nColIni + 2395)
		oPrint:Say(nLinIni + 0309, nColIni + 0441, "4 - "+STR0013, oFont01) //"Nome do Contratado"
		oPrint:Say(nLinIni + 0339, nColIni + 0451, aDados[nX, 04], oFont04)
		oPrint:Box(nLinIni + 0304, nColIni + 2400, nLinIni + 0398, nColIni + 2615)
		oPrint:Say(nLinIni + 0309, nColIni + 2410, "5 - "+STR0014, oFont01) //"Código CNES"
		oPrint:Say(nLinIni + 0339, nColIni + 2420, aDados[nX, 05], oFont04)

		nLinIni += 20
		oPrint:Say(nLinIni + 0403, nColIni + 0010, STR0233+"    "+STR0234+"1-"+STR0235+"     "+"2-"+STR0236+"     "+"3-"+STR0237+"     "+"4-"+STR0238+"     "+"5-"+STR0239+"     "+"6-"+STR0240, oFont01) //"Código de Despesas Realizadas"###"CD = "###"Gases Medicinais"###"Medicamentos"###"Materiais"###"Taxas Diversas"###"Diárias"###"Aluguéis"
		oPrint:Box(nLinIni + 0433, nColIni + 0010, nLinIni + 1701, nColIni + 3695 + nColA4)
		oPrint:Say(nLinIni + 0438, nColIni + 0030, "6 - "+STR0241, oFont01) //"CD"
		oPrint:Say(nLinIni + 0438, nColIni + 0120, "7 - "+STR0098, oFont01) //"Data"
		oPrint:Say(nLinIni + 0438, nColIni + 0305, "8 - "+STR0099, oFont01) //"Hora Inicial"
		oPrint:Say(nLinIni + 0438, nColIni + 0480, "9 - "+STR0100, oFont01) //"Hora Final"
		oPrint:Say(nLinIni + 0438, nColIni + 0740, "10 - "+STR0074, oFont01) //"Tabela"
		oPrint:Say(nLinIni + 0438, nColIni + 0910, "11 - "+STR0242, oFont01) //"Código do Item"
	  	oPrint:Say(nLinIni + 0438, nColIni + 2555 + nColA4, "12 - "+STR0101, oFont01,,,,1) //"Qtde."
		oPrint:Say(nLinIni + 0438, nColIni + 2805 + nColA4, "13 - "+STR0104, oFont01,,,,1) //"% Red./Acresc."
		oPrint:Say(nLinIni + 0438, nColIni + 3065 + nColA4, "14 - "+STR0105, oFont01,,,,1) //"Valor Unitário - R$"
		oPrint:Say(nLinIni + 0438, nColIni + 3275 + nColA4, "15 - "+STR0106, oFont01,,,,1) //"Valor Total - R$"

		nOldLinIni := nLinIni
		For nI := 1 To 13
			oPrint:Say(nLinIni + 0503, nColIni + 0030, AllTrim(Str(nI)) + " - ", oFont01)
			oPrint:Say(nLinIni + 0498, nColIni + 0065, aDados[nX, 6, nI], oFont04)
			oPrint:Say(nLinIni + 0498, nColIni + 0120, IIf(Empty(aDados[nX, 7, nI]), "", DtoC(aDados[nX, 7, nI])), oFont04)
			oPrint:Say(nLinIni + 0498, nColIni + 0305, IIf(Empty(aDados[nX, 8, nI]), "", Transform(aDados[nX, 8, nI], "@R 99:99")), oFont04)
		 	oPrint:Say(nLinIni + 0498, nColIni + 0480, IIf(Empty(aDados[nX, 9, nI]), "", Transform(aDados[nX, 9, nI], "@R 99:99")), oFont04)
			oPrint:Say(nLinIni + 0498, nColIni + 0740, aDados[nX, 10, nI], oFont04)
			oPrint:Say(nLinIni + 0498, nColIni + 0910, aDados[nX, 11, nI], oFont04)
			oPrint:Say(nLinIni + 0498, nColIni + 2555 + nColA4, IIf(Empty(aDados[nX, 12, nI]), "", Transform(aDados[nX, 12, nI], "@E 9999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 0498, nColIni + 2805 + nColA4, IIf(Empty(aDados[nX, 13, nI]), "", Transform(aDados[nX, 13, nI], "@E 999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 0498, nColIni + 3065 + nColA4, IIf(Empty(aDados[nX, 14, nI]), "", Transform(aDados[nX, 14, nI], "@E 99,999,999.99")), oFont04,,,,1)
			oPrint:Say(nLinIni + 0498, nColIni + 3275 + nColA4, IIf(Empty(aDados[nX, 15, nI]), "", Transform(aDados[nX, 15, nI], "@E 99,999,999.99")), oFont04,,,,1)
			nLinIni += 43
			oPrint:Say(nLinIni + 0503, nColIni + 0065, "16 - "+STR0076, oFont01) //"Descrição"
			oPrint:Say(nLinIni + 0498, nColIni + 0225, aDados[nX, 16, nI], oFont04)
			nLinIni += 45
		Next nI

		nLinIni := nOldLinIni

		oPrint:Box(nLinIni + 1706, nColIni + 0010, nLinIni + 1800, nColIni + 0531 + (nColA4/7))
		oPrint:Say(nLinIni + 1711, nColIni + 0020, "17 - "+STR0113, oFont01) //"Total Gases Medicinais R$"
		oPrint:Say(nLinIni + 1741, nColIni + 0506 + (nColA4/7), Transform(aDados[nX, 17], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1706, nColIni + 0536 + (nColA4/7), nLinIni + 1800, nColIni + 1057 + (2*(nColA4/7)))
		oPrint:Say(nLinIni + 1711, nColIni + 0546 + (nColA4/7), "18 - "+STR0111, oFont01) //"Total Medicamentos R$"
		oPrint:Say(nLinIni + 1741, nColIni + 1032 + (2*(nColA4/7)), Transform(aDados[nX, 18], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1706, nColIni + 1062 + (2*(nColA4/7)), nLinIni + 1800, nColIni + 1583 + (3*(nColA4/7)))
		oPrint:Say(nLinIni + 1711, nColIni + 1072 + (2*(nColA4/7)), "19 - "+STR0110, oFont01) //"Total Materiais R$"
		oPrint:Say(nLinIni + 1741, nColIni + 1558 + (3*(nColA4/7)), Transform(aDados[nX, 19], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1706, nColIni + 1588 + (3*(nColA4/7)), nLinIni + 1800, nColIni + 2109 + (4*(nColA4/7)))
		oPrint:Say(nLinIni + 1711, nColIni + 1598 + (3*(nColA4/7)), "20 - "+STR0243, oFont01) //"Total Taxas Diversas R$"
		oPrint:Say(nLinIni + 1741, nColIni + 2084 + (4*(nColA4/7)), Transform(aDados[nX, 20], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1706, nColIni + 2114 + (4*(nColA4/7)), nLinIni + 1800, nColIni + 2635 + (5*(nColA4/7)))
		oPrint:Say(nLinIni + 1711, nColIni + 2124 + (4*(nColA4/7)), "21 - "+STR0112, oFont01) //"Total Diárias R$"
		oPrint:Say(nLinIni + 1741, nColIni + 2610 + (5*(nColA4/7)), Transform(aDados[nX, 21], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1706, nColIni + 2640 + (5*(nColA4/7)), nLinIni + 1800, nColIni + 3161 + (6*(nColA4/7)))
		oPrint:Say(nLinIni + 1711, nColIni + 2650 + (5*(nColA4/7)), "22 - "+STR0244, oFont01) //"Total Aluguéis R$"
		oPrint:Say(nLinIni + 1741, nColIni + 3136 + (6*(nColA4/7)), Transform(aDados[nX, 22], "@E 999,999,999.99"), oFont04,,,,1)
		oPrint:Box(nLinIni + 1706, nColIni + 3166 + (6*(nColA4/7)), nLinIni + 1800, nColIni + 3695 + (7*(nColA4/7)))
		oPrint:Say(nLinIni + 1711, nColIni + 3176 + (6*(nColA4/7)), "23 - "+STR0214, oFont01) //"Total Geral R$"
		oPrint:Say(nLinIni + 1741, nColIni + 3675 + (7*(nColA4/7)), Transform(aDados[nX, 23], "@E 999,999,999.99"), oFont04,,,,1)

		oPrint:EndPage()	// Finaliza a pagina

	Next nX

	If lGerTXT
		oPrint:Print()		// Imprime Relatorio
	Else
		oPrint:Print()	// Visualiza impressao grafica antes de imprimir
	EndIf

Return cFileName


Static Function fLogoEmp(cLogo, cTipo, cLogoGH)

    Local cStartPath    := GetSrvProfString("STARTPATH","")

    Default cTipo   := "1"
    Default cLogoGH := ""

    If ValType(cLogoGH) <> "U" .And. !Empty(cLogoGH) .And. File(cLogoGH) //logo a partir do campo do Gestao Hospitalar
         cLogo := cLogoGH
    Else // Logotipo da Empresa
         If cTipo == "1"
            cLogo := cStartPath + "LGRL"+FWCompany()+FWCodFil()+".BMP"  // Empresa+Filial
            //If !File(cLogo)
            //  cLogo := cStartPath + "LGRL"+FWCompany()+".BMP"             // Empresa
            //EndIf
         Else
            //cLogo := cStartPath + "LogoSiga.bmp"
            cLogo := cStartPath + "LGRL"+FWCompany()+".BMP"             // Empresa
         EndIf
    EndIf

Return(Nil)