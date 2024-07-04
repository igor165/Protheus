
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "PLSMFPG.CH"

Static _aBfq	:= {}
Static _nBfq

#DEFINE nBFQ_CODLAN		1		// Definido tambem no PLSMCOB
#DEFINE nBFQ_DEBCRE		2
#DEFINE nBFQ_DESCRI		3
#DEFINE nBFQ_CALRAT		4
#DEFINE nBFQ_INCIR		5
#DEFINE nBFQ_REGCIR		6
#DEFINE nBFQ_RELBFR		7		// Alias Relacionados com o BFR

#DEFINE EVENTO_DEVOLUCAO	"101"		// Codigo do tipo para devolucao

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSMFPGFai ³ Autor ³ Tulio Cesar       ³ Data ³ 05.03.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca valor da faixa etaria                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function 	PLSMFPGFai(cCodInt,cCodEmp,cConEmp,cVerCon,cMatric,cCodPla,cVersao,cForPag,;
			nIdade,cTipUsu,cSexo,cGrauPar,cSubCon,cVerSub,nQtdUsr,lCobra,_cNivel,cTipReg,;
			cAno,cMes)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis LOCAIS...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nCont
LOCAL cSQL
LOCAL nVlrFai 	:= 0
LOCAL cCodFai	 := ""
LOCAL cNivFai
LOCAL aVetRet 	:= {}
LOCAL cCodQtd 	:= ""
Local nRejApl 	:= 0		// Reajuste aplicado
Local cMesRej 	:= ""		// Mes de Reajuste
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel que Testa se existe faixa etaria no nivel grupo/empresa... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nFlag 	:= 0
Local nIdaIni   := nIdaFim := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a faixa etaria e especifica para um usuario...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(cTipReg)
	BDK->(DbSetOrder(1))
	If BDK->(MsSeek(xFilial("BDK")+cCodInt+cCodEmp+cMatric+cTipReg))
		While ! BDK->(Eof()) .And. BDK->(BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG) == cCodInt+cCodEmp+cMatric+cTipReg
			
			If nIdade >= BDK->BDK_IDAINI .And. nIdade <= BDK->BDK_IDAFIN
				nVlrFai := BDK->BDK_VALOR
				cCodFai := BDK->BDK_CODFAI
				cNivFai := "4"
				lCobra  := .F.
				nFlag   := 4
				nIdaIni := BDK->BDK_IDAINI
				nIdaFim := BDK->BDK_IDAFIN
				Exit
			Endif
			
			BDK->(DbSkip())
		Enddo
	Endif
Endif
	
if _cNivel == "3" .And. nFlag == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca no nivel de Familia primeiro se e familiar...                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nQtdUsr > 0
		cSQL := "SELECT BBU_CODFAI, BBU_VALFAI,BBU_QTDMIN, BBU_QTDMAX, BBU_FAIFAM, BBU_TABVLD, BBU_REJAPL FROM "
		cSQL += RetSQLName("BBU")+" "
		cSQL += "WHERE BBU_FILIAL = '"+xFilial("BBU")+"' AND BBU_CODOPE = '"+cCodInt+"' AND "
		cSQL += "BBU_CODEMP = '"+cCodEMP+"' AND BBU_MATRIC = '"+cMatric+"' AND "
		cSQL += "BBU_FAIFAM = '1' AND BBU_CODFOR = '"+cForPag+"' AND " 
		cSQL += "D_E_L_E_T_= '' AND BBU_TABVLD = ' ' " 
		cSQL += "ORDER BY BBU_TIPUSR DESC ,BBU_GRAUPA DESC ,BBU_SEXO DESC"
	
		PLSQuery(cSQL,"TrbBBU")
	
		If !TrbBBU->(Eof())
			While ! TRBBBU->(Eof())
				if TrbBBU->BBU_QTDMIN <= nQtdUsr .And. nQtdUsr <= TrbBBU->BBU_QTDMAX
					nVlrFai := TrbBBU->BBU_VALFAI
					cCodFai := TrbBBU->BBU_CODFAI
					cMesRej := TrbBBU->BBU_TABVLD
					nRejApl := TrbBBU->BBU_REJAPL
					cNivFai := "3"
					lCobra := .T.
					nFlag   := 10
					Exit
				Else
					lCobra := .F.
					TrbBBU->(DbSkip())
				Endif
			EndDo
		Endif
		
		TrbBBU->(DbCloseArea())
	Endif
		
	if (nFlag == 0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca no nivel de Familia...                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BBU_CODFAI, BBU_VALFAI,BBU_TIPUSR,BBU_GRAUPA,BBU_SEXO,BBU_IDAINI,"
		cSQL += "BBU_IDAFIN, BBU_QTDMIN, BBU_QTDMAX, BBU_FAIFAM, BBU_TABVLD, BBU_REJAPL FROM "
		cSQL += RetSQLName("BBU")+" WHERE "
		cSQL += "BBU_FILIAL = '"+xFilial("BBU")+"' AND "
		cSQL += "BBU_CODOPE = '"+cCodInt+"' AND "
		cSQL += "BBU_CODEMP = '"+cCodEMP+"' AND "
		cSQL += "BBU_MATRIC = '"+cMatric+"' AND "
		cSQL += "BBU_FAIFAM = '0' AND BBU_CODFOR = '" + cForPag + "' AND "
		cSQL += "BBU_TABVLD = ' ' AND D_E_L_E_T_= '' " 
		cSQL += "ORDER BY BBU_TIPUSR DESC ,BBU_GRAUPA DESC ,BBU_SEXO DESC"
		
		PLSQuery(cSQL,"TrbBBU")
		
		While !TrbBBU->(Eof())
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o sexo e tipo de usuario e grau de parentesco... ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBBU->BBU_TIPUSR) .And. !Empty(TrbBBU->BBU_GRAUPA) .And. !Empty(TrbBBU->BBU_SEXO)
				if cTipUsu == TrbBBU->BBU_TIPUSR .And. ;
					cGrauPar == TrbBBU->BBU_GRAUPA .And.;
					(cSexo == TrbBBU->BBU_SEXO .Or. TrbBBU->BBU_SEXO == "3")
					if nIdade >= TrbBBU->BBU_IDAINI .And.;
						nIdade <= TrbBBU->BBU_IDAFIN
						nVlrFai := TrbBBU->BBU_VALFAI
						cCodFai := TrbBBU->BBU_CODFAI
						nIdaIni := TrbBBU->BBU_IDAINI
						nIdaFim := TrbBBU->BBU_IDAFIN
						cMesRej := TrbBBU->BBU_TABVLD
						nRejApl := TrbBBU->BBU_REJAPL
						cNivFai := "3"
						nFlag := 1
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o sexo e tipo de usuario...                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBBU->BBU_TIPUSR) .And. Empty(TrbBBU->BBU_GRAUPA) .And. !Empty(TrbBBU->BBU_SEXO)
				if cTipUsu == TrbBBU->BBU_TIPUSR .And. ;
					(cSexo == TrbBBU->BBU_SEXO .Or. TrbBBU->BBU_SEXO == "3")
					if nIdade >= TrbBBU->BBU_IDAINI .And.;
						nIdade <= TrbBBU->BBU_IDAFIN
						nVlrFai := TrbBBU->BBU_VALFAI
						cCodFai := TrbBBU->BBU_CODFAI
						cMesRej := TrbBBU->BBU_TABVLD
						nRejApl := TrbBBU->BBU_REJAPL
						cNivFai := "3"
						nFlag   := 1
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o tipo de usuario e grau parentesco...           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBBU->BBU_TIPUSR) .And. !Empty(TrbBBU->BBU_GRAUPA) .And. (Empty(TrbBBU->BBU_SEXO) .or. TrbBBU->BBU_SEXO == "3")
				if cTipUsu == TrbBBU->BBU_TIPUSR .And. ;
					cGrauPar == TrbBBU->BBU_GRAUPA
					if nIdade >= TrbBBU->BBU_IDAINI .And. ;
						nIdade <= TrbBBU->BBU_IDAFIN
						nVlrFai := TrbBBU->BBU_VALFAI
						cCodFai := TrbBBU->BBU_CODFAI
						nIdaIni := TrbBBU->BBU_IDAINI
						nIdaFim := TrbBBU->BBU_IDAFIN
						cMesRej := TrbBBU->BBU_TABVLD
						nRejApl := TrbBBU->BBU_REJAPL
						cNivFai := "3"
						nFlag   := 1
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o grau de parentesco e sexo                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBBU->BBU_TIPUSR) .And. !Empty(TrbBBU->BBU_GRAUPA) .And. !Empty(TrbBBU->BBU_SEXO)
				if cGrauPar == TrbBBU->BBU_GRAUPA .And.;
					(cSexo == TrbBBU->BBU_SEXO .Or. TrbBBU->BBU_SEXO == "3")
					if nIdade >= TrbBBU->BBU_IDAINI .And.;
						nIdade <= TrbBBU->BBU_IDAFIN
						nVlrFai := TrbBBU->BBU_VALFAI
						cCodFai := TrbBBU->BBU_CODFAI
						nIdaIni := TrbBBU->BBU_IDAINI
						nIdaFim := TrbBBU->BBU_IDAFIN
						cMesRej := TrbBBU->BBU_TABVLD
						nRejApl := TrbBBU->BBU_REJAPL
						cNivFai := "3"
						nFlag   := 1
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente o tipo de usuario...                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBBU->BBU_TIPUSR) .And. Empty(TrbBBU->BBU_GRAUPA) .And. (Empty(TrbBBU->BBU_SEXO) .or. TrbBBU->BBU_SEXO == "3")
				if cTipUsu == TrbBBU->BBU_TIPUSR
					if nIdade >= TrbBBU->BBU_IDAINI .And. ;
						nIdade <= TrbBBU->BBU_IDAFIN
						nVlrFai := TrbBBU->BBU_VALFAI
						cCodFai := TrbBBU->BBU_CODFAI
						nIdaIni := TrbBBU->BBU_IDAINI
						nIdaFim := TrbBBU->BBU_IDAFIN
						cMesRej := TrbBBU->BBU_TABVLD
						nRejApl := TrbBBU->BBU_REJAPL
						cNivFai := "3"
						nFlag   := 1
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente o sexo...                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBBU->BBU_TIPUSR) .And. Empty(TrbBBU->BBU_GRAUPA) .And. !Empty(TrbBBU->BBU_SEXO)
				if (cSexo == TrbBBU->BBU_SEXO .Or. TrbBBU->BBU_SEXO == "3")
					if nIdade >= TrbBBU->BBU_IDAINI .And. ;
						nIdade <= TrbBBU->BBU_IDAFIN
						nVlrFai := TrbBBU->BBU_VALFAI
						cCodFai := TrbBBU->BBU_CODFAI
						nIdaIni := TrbBBU->BBU_IDAINI
						nIdaFim := TrbBBU->BBU_IDAFIN
						cMesRej := TrbBBU->BBU_TABVLD
						nRejApl := TrbBBU->BBU_REJAPL
						cNivFai := "3"
						nFlag   := 1
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente o grau de parentesco...                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBBU->BBU_TIPUSR) .And. !Empty(TrbBBU->BBU_GRAUPA) .And. (Empty(TrbBBU->BBU_SEXO) .or. TrbBBU->BBU_SEXO == "3")
				if cGrauPar == TrbBBU->BBU_GRAUPA
					if nIdade >= TrbBBU->BBU_IDAINI .And. ;
						nIdade <= TrbBBU->BBU_IDAFIN
						nVlrFai := TrbBBU->BBU_VALFAI
						cCodFai := TrbBBU->BBU_CODFAI
						nIdaIni := TrbBBU->BBU_IDAINI
						nIdaFim := TrbBBU->BBU_IDAFIN
						cMesRej := TrbBBU->BBU_TABVLD
						nRejApl := TrbBBU->BBU_REJAPL
						cNivFai := "3"
						nFlag   := 1
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente a faixa...                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBBU->BBU_TIPUSR) .And. Empty(TrbBBU->BBU_GRAUPA) .And. (Empty(TrbBBU->BBU_SEXO) .or. TrbBBU->BBU_SEXO == "3")
				if nIdade >= TrbBBU->BBU_IDAINI .And. ;
					nIdade <= TrbBBU->BBU_IDAFIN
					nVlrFai := TrbBBU->BBU_VALFAI
					cCodFai := TrbBBU->BBU_CODFAI
					nIdaIni := TrbBBU->BBU_IDAINI
					nIdaFim := TrbBBU->BBU_IDAFIN
					cMesRej := TrbBBU->BBU_TABVLD
					nRejApl := TrbBBU->BBU_REJAPL
					cNivFai := "3"
					nFlag   := 1
					Exit
				Endif
			Endif
			
			TrbBBU->(DbSkip())
		Enddo
		TrbBBU->(DbCloseArea())
	Endif
Endif

if (nFlag == 0) .And. (_cNivel == "2")
	cCodQtd := PlsRetQtd(	cCodInt,cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub,;
							cCodPla,cVersao,cForPag,cTipUsu,cSexo,cGrauPar)
	
	If nQtdUsr > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura para todos as chaves preenchidas...                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BTN_CODFAI, BTN_VALFAI,BTN_TIPUSR,BTN_GRAUPA,"
		cSQL += "BTN_SEXO,BTN_QTDMIN,BTN_QTDMAX, BTN_TABVLD, BTN_REJAPL FROM "
		cSQL += RetSQLName("BTN")+" WHERE "
		cSQL += "BTN_FILIAL = '"+xFilial("BTN")+"' AND "
		cSQL += "BTN_CODIGO = '"+cCodInt+cCodEmp+"' AND "
		cSQL += "BTN_NUMCON = '"+cConEmp+"' AND "
		cSQL += "BTN_VERCON = '"+cVerCon+"' AND "
		cSQL += "BTN_SUBCON = '"+cSubCon+"' AND "
		cSQL += "BTN_VERSUB = '"+cVerSub+"' AND "
		cSQL += "BTN_CODPRO = '"+cCodPla+"' AND "
		cSQL += "BTN_VERPRO = '"+cVersao+"' AND "
		cSQL += "BTN_CODQTD = '"+cCodQtd+"' AND "
		cSQL += "BTN_FAIFAM = '1' AND BTN_CODFOR = '"+cForPag + "' AND "
		cSQL += "BTN_TABVLD = ' ' AND D_E_L_E_T_ = '' " 
		cSQL += "ORDER BY BTN_CODFOR, BTN_TIPUSR DESC,BTN_GRAUPA DESC ,BTN_SEXO DESC"
		
		PLSQuery(cSQL,"TrbBTN")
		
		If !TrbBTN->(Eof())
			While !TrbBTN->(Eof())
				if TrbBTN->BTN_QTDMIN <= nQtdUsr .And. nQtdUsr <= TrbBTN->BTN_QTDMAX
					nVlrFai := TrbBTN->BTN_VALFAI
					cCodFai := TrbBTN->BTN_CODFAI
					cMesRej := TrbBTN->BTN_TABVLD
					nRejApl := TrbBTN->BTN_REJAPL
					cNivFai := "2"
					lCobra := .T.
					nFlag   := 20
					Exit
				Else
					lCobra := .F.
					TrbBTN->(DbSkip())
				Endif
			EndDo
		Else
			lCobra := .F.
		Endif
		
		TrbBTN->(DbCloseArea())
	Endif
			
	if (nFlag == 0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura para todos as chaves preenchidas...                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BTN_CODFAI, BTN_VALFAI,BTN_TIPUSR,"
		cSQL += "BTN_GRAUPA,BTN_SEXO,BTN_IDAINI,BTN_IDAFIN, BTN_TABVLD, BTN_REJAPL FROM "
		cSQL += RetSQLName("BTN")+" WHERE "
		cSQL += "BTN_FILIAL = '"+xFilial("BTN")+"' AND "
		cSQL += "BTN_CODIGO = '"+cCodInt+cCodEmp+"' AND "
		cSQL += "BTN_NUMCON = '"+cConEmp+"' AND "
		cSQL += "BTN_VERCON = '"+cVerCon+"' AND "
		cSQL += "BTN_SUBCON = '"+cSubCon+"' AND "
		cSQL += "BTN_VERSUB = '"+cVerSub+"' AND "
		cSQL += "BTN_CODPRO = '"+cCodPla+"' AND "
		cSQL += "BTN_VERPRO = '"+cVersao+"' AND "
		cSQL += "BTN_CODQTD = '"+cCodQtd+"' AND "
		cSQL += "BTN_FAIFAM = '0' AND BTN_CODFOR = '"+cForPag+"' AND "
		cSQL += "D_E_L_E_T_ = '' AND BTN_TABVLD = ' ' " 
		cSQL += "ORDER BY BTN_TIPUSR DESC,BTN_GRAUPA DESC ,BTN_SEXO DESC"
		
		PLSQuery(cSQL,"TrbBTN")
		
		While !TrbBTN->(Eof())
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o sexo e tipo de usuario e grau de parentesco... ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBTN->BTN_TIPUSR) .And. !Empty(TrbBTN->BTN_GRAUPA) .And. !Empty(TrbBTN->BTN_SEXO)
				if cTipUsu == TrbBTN->BTN_TIPUSR .And. ;
					cGrauPar == TrbBTN->BTN_GRAUPA .And.;
					(cSexo == TrbBTN->BTN_SEXO .Or. TrbBTN->BTN_SEXO == "3")
					if nIdade >= TrbBTN->BTN_IDAINI .And.;
						nIdade <= TrbBTN->BTN_IDAFIN
						nVlrFai := TrbBTN->BTN_VALFAI
						cCodFai := TrbBTN->BTN_CODFAI
						nIdaIni := TrbBTN->BTN_IDAINI
						nIdaFim := TrbBTN->BTN_IDAFIN
						cMesRej := TrbBTN->BTN_TABVLD
						nRejApl := TrbBTN->BTN_REJAPL
						cNivFai := "2"
						nFlag   := 2
						Exit
					Endif
				Endif
			Endif
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o sexo e tipo de usuario...                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBTN->BTN_TIPUSR) .And. Empty(TrbBTN->BTN_GRAUPA) .And. !Empty(TrbBTN->BTN_SEXO)
				if cTipUsu == TrbBTN->BTN_TIPUSR .And. ;
					(cSexo == TrbBTN->BTN_SEXO .Or. TrbBTN->BTN_SEXO == "3")
					if nIdade >= TrbBTN->BTN_IDAINI .And.;
						nIdade <= TrbBTN->BTN_IDAFIN
						nVlrFai := TrbBTN->BTN_VALFAI
						cCodFai := TrbBTN->BTN_CODFAI
						nIdaIni := TrbBTN->BTN_IDAINI
						nIdaFim := TrbBTN->BTN_IDAFIN
						cMesRej := TrbBTN->BTN_TABVLD
						nRejApl := TrbBTN->BTN_REJAPL
						cNivFai := "2"
						nFlag   := 2
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o tipo de usuario e grau parentesco...           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBTN->BTN_TIPUSR) .And. !Empty(TrbBTN->BTN_GRAUPA) .And. (Empty(TrbBTN->BTN_SEXO) .or. TrbBTN->BTN_SEXO == "3")
				if cTipUsu == TrbBTN->BTN_TIPUSR .And. ;
					cGrauPar == TrbBTN->BTN_GRAUPA
					if nIdade >= TrbBTN->BTN_IDAINI .And.;
						nIdade <= TrbBTN->BTN_IDAFIN
						nVlrFai := TrbBTN->BTN_VALFAI
						cCodFai := TrbBTN->BTN_CODFAI
						nIdaIni := TrbBTN->BTN_IDAINI
						nIdaFim := TrbBTN->BTN_IDAFIN
						cMesRej := TrbBTN->BTN_TABVLD
						nRejApl := TrbBTN->BTN_REJAPL
						cNivFai := "2"
						nFlag   := 2
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o grau de parentesco e sexo                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBTN->BTN_TIPUSR) .And. !Empty(TrbBTN->BTN_GRAUPA) .And. !Empty(TrbBTN->BTN_SEXO)
				if cGrauPar == TrbBTN->BTN_GRAUPA .And.;
					(cSexo == TrbBTN->BTN_SEXO .Or. TrbBTN->BTN_SEXO == "3")
					if nIdade >= TrbBTN->BTN_IDAINI .And.;
						nIdade <= TrbBTN->BTN_IDAFIN
						nVlrFai := TrbBTN->BTN_VALFAI
						cCodFai := TrbBTN->BTN_CODFAI
						nIdaIni := TrbBTN->BTN_IDAINI
						nIdaFim := TrbBTN->BTN_IDAFIN
						cMesRej := TrbBTN->BTN_TABVLD
						nRejApl := TrbBTN->BTN_REJAPL
						cNivFai := "2"
						nFlag   := 2
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente o tipo de usuario...                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBTN->BTN_TIPUSR) .And. Empty(TrbBTN->BTN_GRAUPA) .And. (Empty(TrbBTN->BTN_SEXO) .or. TrbBTN->BTN_SEXO == "3")
				if cTipUsu == TrbBTN->BTN_TIPUSR
					if nIdade >= TrbBTN->BTN_IDAINI .And.;
						nIdade <= TrbBTN->BTN_IDAFIN
						nVlrFai := TrbBTN->BTN_VALFAI
						cCodFai := TrbBTN->BTN_CODFAI
						nIdaIni := TrbBTN->BTN_IDAINI
						nIdaFim := TrbBTN->BTN_IDAFIN
						cMesRej := TrbBTN->BTN_TABVLD
						nRejApl := TrbBTN->BTN_REJAPL
						cNivFai := "2"
						nFlag   := 2
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente o sexo...                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBTN->BTN_TIPUSR) .And. Empty(TrbBTN->BTN_GRAUPA) .And. !Empty(TrbBTN->BTN_SEXO)
				if (cSexo == TrbBTN->BTN_SEXO .Or. TrbBTN->BTN_SEXO == "3")
					if nIdade >= TrbBTN->BTN_IDAINI .And.;
						nIdade <= TrbBTN->BTN_IDAFIN
						nVlrFai := TrbBTN->BTN_VALFAI
						cCodFai := TrbBTN->BTN_CODFAI
						nIdaIni := TrbBTN->BTN_IDAINI
						nIdaFim := TrbBTN->BTN_IDAFIN
						cMesRej := TrbBTN->BTN_TABVLD
						nRejApl := TrbBTN->BTN_REJAPL
						cNivFai := "2"
						nFlag   := 2
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente o grau de parentesco...                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBTN->BTN_TIPUSR) .And. !Empty(TrbBTN->BTN_GRAUPA) .And. (Empty(TrbBTN->BTN_SEXO) .or. TrbBTN->BTN_SEXO == "3")
				if cGrauPar == TrbBTN->BTN_GRAUPA
					if nIdade >= TrbBTN->BTN_IDAINI .And.;
						nIdade <= TrbBTN->BTN_IDAFIN
						nVlrFai := TrbBTN->BTN_VALFAI
						cCodFai := TrbBTN->BTN_CODFAI
						nIdaIni := TrbBTN->BTN_IDAINI
						nIdaFim := TrbBTN->BTN_IDAFIN
						cMesRej := TrbBTN->BTN_TABVLD
						nRejApl := TrbBTN->BTN_REJAPL
						cNivFai := "2"
						nFlag   := 2
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente a faixa...                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBTN->BTN_TIPUSR) .And. Empty(TrbBTN->BTN_GRAUPA) .And. (Empty(TrbBTN->BTN_SEXO) .or. TrbBTN->BTN_SEXO == "3")
				if nIdade >= TrbBTN->BTN_IDAINI .And.;
					nIdade <= TrbBTN->BTN_IDAFIN
					nVlrFai := TrbBTN->BTN_VALFAI
					cCodFai := TrbBTN->BTN_CODFAI
					nIdaIni := TrbBTN->BTN_IDAINI
					nIdaFim := TrbBTN->BTN_IDAFIN
					cMesRej := TrbBTN->BTN_TABVLD
					nRejApl := TrbBTN->BTN_REJAPL
					cNivFai := "2"
					nFlag   := 2
					Exit
				Endif
			Endif
			
			TrbBTN->(dbSkip())
		Enddo
		TrbBTN->(dbCloseArea())
	Endif
Endif

if (nFlag == 0) .And. (_cNivel == "1")
	If nQtdUsr > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca no nivel PRODUTO para Faixa Familiar...                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BB3_CODFAI, BB3_VALFAI,BB3_TIPUSR,BB3_GRAUPA,BB3_SEXO,BB3_IDAINI,"
		cSQL += "BB3_IDAFIN,BB3_QTDMIN,BB3_QTDMAX, BB3_TABVLD, BB3_REJAPL FROM "
		cSQL += RetSQLName("BB3")+" WHERE "
		cSQL += "BB3_FILIAL = '"+xFilial("BB3")+"' AND "
		cSQL += "BB3_CODIGO = '"+cCodInt+cCodPla+"' AND "
		cSQL += "BB3_VERSAO = '"+cVersao+"' AND "
		cSQL += "BB3_FAIFAM = '1' AND BB3_CODFOR = '" + cForPag + "' AND "
		cSQL += "D_E_L_E_T_= '' AND BB3_TABVLD = ' ' "
		cSQL += "ORDER BY BB3_TIPUSR DESC ,BB3_GRAUPA DESC ,BB3_SEXO DESC "
		
		PLSQuery(cSQL,"TrbBB3")
		
		If !TrbBB3->(Eof())
			While ! TRBBB3->(Eof())
				if TrbBB3->BB3_QTDMIN <= nQtdUsr .And. nQtdUsr <= TrbBB3->BB3_QTDMAX
					nVlrFai := TrbBB3->BB3_VALFAI
					cCodFai := TrbBB3->BB3_CODFAI
					cMesRej := TrbBB3->BB3_TABVLD
					nRejApl := TrbBB3->BB3_REJAPL
					cNivFai := "1"
					lCobra := .T.
					nFlag   := 30
					Exit
				Else
					lCobra := .F.
					TRBBB3->(DbSkip())
				Endif
			EndDo
		Else
			lCobra := .F.
		Endif
		TrbBB3->(DbCloseArea())
	Endif
		
	if (nFlag == 0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca no nivel PRODUTO...                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := "SELECT BB3_CODFAI, BB3_VALFAI,BB3_TIPUSR,BB3_GRAUPA,BB3_SEXO,"
		cSQL += "BB3_IDAINI,BB3_IDAFIN, BB3_TABVLD, BB3_REJAPL FROM "
		cSQL += RetSQLName("BB3")+" BB3 WHERE "
		cSQL += "BB3_FILIAL = '"+xFilial("BB3")+"' AND "
		cSQL += "BB3_CODIGO = '"+cCodInt+cCodPla+"' AND "
		cSQL += "BB3_VERSAO = '"+cVersao+"' AND "
		cSQL += "BB3_FAIFAM = '0' AND BB3_CODFOR = '" + cForPag + "' AND "
		cSQL += "BB3_TABVLD = ' ' AND D_E_L_E_T_= ''"
		cSQL += "ORDER BY BB3_TIPUSR DESC ,BB3_GRAUPA DESC ,BB3_SEXO DESC "
		
		PLSQuery(cSQL,"TrbBB3")
		
		While !TrbBB3->(Eof())
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o sexo e tipo de usuario e grau de parentesco... ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBB3->BB3_TIPUSR) .And. !Empty(TrbBB3->BB3_GRAUPA) .And. !Empty(TrbBB3->BB3_SEXO)
				if cTipUsu == TrbBB3->BB3_TIPUSR .And. ;
					cGrauPar == TrbBB3->BB3_GRAUPA .And.;
					(cSexo == TrbBB3->BB3_SEXO .Or. TrbBB3->BB3_SEXO == "3")
					if nIdade >= TrbBB3->BB3_IDAINI .And.;
						nIdade <= TrbBB3->BB3_IDAFIN
						nVlrFai := TrbBB3->BB3_VALFAI
						cCodFai := TrbBB3->BB3_CODFAI
						nIdaIni := TrbBB3->BB3_IDAINI
						nIdaFim := TrbBB3->BB3_IDAFIN
						cMesRej := TrbBB3->BB3_TABVLD
						nRejApl := TrbBB3->BB3_REJAPL
						cNivFai := "1"
						nFlag   := 3
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o sexo e tipo de usuario...                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBB3->BB3_TIPUSR) .And. Empty(TrbBB3->BB3_GRAUPA) .And. !Empty(TrbBB3->BB3_SEXO)
				if cTipUsu == TrbBB3->BB3_TIPUSR .And. ;
					(cSexo == TrbBB3->BB3_SEXO .Or. TrbBB3->BB3_SEXO == "3")
					if nIdade >= TrbBB3->BB3_IDAINI .And.;
						nIdade <= TrbBB3->BB3_IDAFIN
						nVlrFai := TrbBB3->BB3_VALFAI
						cCodFai := TrbBB3->BB3_CODFAI
						nIdaIni := TrbBB3->BB3_IDAINI
						nIdaFim := TrbBB3->BB3_IDAFIN
						cMesRej := TrbBB3->BB3_TABVLD
						nRejApl := TrbBB3->BB3_REJAPL
						cNivFai := "1"
						nFlag   := 3
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o tipo de usuario e grau parentesco...           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBB3->BB3_TIPUSR) .And. !Empty(TrbBB3->BB3_GRAUPA) .And. (Empty(TrbBB3->BB3_SEXO) .or. TrbBB3->BB3_SEXO == "3")
				if cTipUsu == TrbBB3->BB3_TIPUSR .And. ;
					cGrauPar == TrbBB3->BB3_GRAUPA
					if nIdade >= TrbBB3->BB3_IDAINI .And. ;
						nIdade <= TrbBB3->BB3_IDAFIN
						nVlrFai := TrbBB3->BB3_VALFAI
						cCodFai := TrbBB3->BB3_CODFAI
						nIdaIni := TrbBB3->BB3_IDAINI
						nIdaFim := TrbBB3->BB3_IDAFIN
						cMesRej := TrbBB3->BB3_TABVLD
						nRejApl := TrbBB3->BB3_REJAPL
						cNivFai := "1"
						nFlag   := 3
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para todos o grau de parentesco e sexo                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBB3->BB3_TIPUSR) .And. !Empty(TrbBB3->BB3_GRAUPA) .And. !Empty(TrbBB3->BB3_SEXO)
				if cGrauPar == TrbBB3->BB3_GRAUPA .And.;
					(cSexo == TrbBB3->BB3_SEXO .Or. TrbBB3->BB3_SEXO == "3")
					if nIdade >= TrbBB3->BB3_IDAINI .And.;
						nIdade <= TrbBB3->BB3_IDAFIN
						nVlrFai := TrbBB3->BB3_VALFAI
						cCodFai := TrbBB3->BB3_CODFAI
						nIdaIni := TrbBB3->BB3_IDAINI
						nIdaFim := TrbBB3->BB3_IDAFIN
						cMesRej := TrbBB3->BB3_TABVLD
						nRejApl := TrbBB3->BB3_REJAPL
						cNivFai := "1"
						nFlag   := 3
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente o tipo de usuario...                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBB3->BB3_TIPUSR) .And. Empty(TrbBB3->BB3_GRAUPA) .And. (Empty(TrbBB3->BB3_SEXO) .or. TrbBB3->BB3_SEXO == "3")
				if cTipUsu == TrbBB3->BB3_TIPUSR
					if nIdade >= TrbBB3->BB3_IDAINI .And. ;
						nIdade <= TrbBB3->BB3_IDAFIN
						nVlrFai := TrbBB3->BB3_VALFAI
						cCodFai := TrbBB3->BB3_CODFAI
						nIdaIni := TrbBB3->BB3_IDAINI
						nIdaFim := TrbBB3->BB3_IDAFIN
						cMesRej := TrbBB3->BB3_TABVLD
						nRejApl := TrbBB3->BB3_REJAPL
						cNivFai := "1"
						nFlag   := 3
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente o sexo...                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBB3->BB3_TIPUSR) .And. Empty(TrbBB3->BB3_GRAUPA) .And. !Empty(TrbBB3->BB3_SEXO)
				if (cSexo == TrbBB3->BB3_SEXO .Or. TrbBB3->BB3_SEXO == "3")
					if nIdade >= TrbBB3->BB3_IDAINI .And. ;
						nIdade <= TrbBB3->BB3_IDAFIN
						nVlrFai := TrbBB3->BB3_VALFAI
						cCodFai := TrbBB3->BB3_CODFAI
						nIdaIni := TrbBB3->BB3_IDAINI
						nIdaFim := TrbBB3->BB3_IDAFIN
						cMesRej := TrbBB3->BB3_TABVLD
						nRejApl := TrbBB3->BB3_REJAPL
						cNivFai := "1"
						nFlag   := 3
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente o grau de parentesco...                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBB3->BB3_TIPUSR) .And. !Empty(TrbBB3->BB3_GRAUPA) .And. (Empty(TrbBB3->BB3_SEXO) .or. TrbBB3->BB3_SEXO == "3")
				if cGrauPar == TrbBB3->BB3_GRAUPA
					if nIdade >= TrbBB3->BB3_IDAINI .And. ;
						nIdade <= TrbBB3->BB3_IDAFIN
						nVlrFai := TrbBB3->BB3_VALFAI
						cCodFai := TrbBB3->BB3_CODFAI
						nIdaIni := TrbBB3->BB3_IDAINI
						nIdaFim := TrbBB3->BB3_IDAFIN
						cMesRej := TrbBB3->BB3_TABVLD
						nRejApl := TrbBB3->BB3_REJAPL
						cNivFai := "1"
						nFlag   := 3
						Exit
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura para somente a faixa...                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBB3->BB3_TIPUSR) .And. Empty(TrbBB3->BB3_GRAUPA) .And. (Empty(TrbBB3->BB3_SEXO) .or. TrbBB3->BB3_SEXO == "3")
				if nIdade >= TrbBB3->BB3_IDAINI .And. ;
					nIdade <= TrbBB3->BB3_IDAFIN
					nVlrFai := TrbBB3->BB3_VALFAI
					cCodFai := TrbBB3->BB3_CODFAI
					nIdaIni := TrbBB3->BB3_IDAINI
					nIdaFim := TrbBB3->BB3_IDAFIN
					cMesRej := TrbBB3->BB3_TABVLD
					nRejApl := TrbBB3->BB3_REJAPL
					cNivFai := "1"
					nFlag   := 3
					Exit
				Endif
			Endif
			
			TrbBB3->(DbSkip())
		Enddo
		TrbBB3->(DbCloseArea())
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Le tabela de descontos de acordo com tabela de faixa etaria...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodigo := ""
if nFlag == 1  .Or. nFlag == 10
	cCodigo := cCodInt+cCodEmp+cMatric
	nFlag   := 1
Elseif nFlag == 2 .Or. nFlag == 20
	cCodigo := cCodInt+cCodEmp
	nFlag   := 2
Elseif nFlag == 3 .Or. nFlag == 30
	cCodigo := cCodInt+cCodPla
	nFlag   := 3
ElseIf nFlag == 4 .Or. nFlag == 40
	cCodigo := cCodInt+cCodEmp+cMatric+cTipReg
	nFlag   := 4
Endif

aVetRet := PLSMFPDeFai(cCodigo,cVersao,cTipUsu,cGrauPar,cSexo,cCodInt+cCodEmp+cMatric,nVlrFai,cCodQtd,cCodFai,nFlag,cConEmp,cVerCon,cSubCon,cVerSub,cCodPla,cTipReg)

nCont := 0

For nCont := 1 to Len(aVetRet)
	if aVetRet[nCont,1] > 0
		if aVetRet[nCont,3] == "1"
			nVlrFai := nVlrFai - aVetRet[nCont,1]
		Elseif aVetRet[nCont,3] == "2"
			nVlrFai := nVlrFai + aVetRet[nCont,1]
		Endif
	Endif
	if aVetRet[nCont,2] > 0
		if aVetRet[nCont,3] == "1"
			nVlrFai := nVlrFai - (nVlrFai * aVetRet[nCont,2]/100)
		Elseif aVetRet[nCont,3] == "2"
			nVlrFai := nVlrFai + (nVlrFai * aVetRet[nCont,2]/100)
		Endif
	Endif
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o valor da faixa...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return({nVlrFai,cCodFai,cNivFai,lCobra,nRejApl,nIdaIni,nIdaFim,cMesRej})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSMFPDeFai³ Autor ³ Antonio de Padua  ³ Data ³ 01.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Desconto por faixa etaria...                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodigo  - Codigo de PLano								  ³±±
±±³          ³ cVersao  - Versao do Plano (Ex.: 001,002)				  ³±±
±±³          ³ cTipUsu  - Tipo do Usuario (Ex.: T=Titular, D=Dependente)  ³±±
±±³          ³ cGrauPar - Grau de Parentesco (Ex.: 01=Filho,02=Filha)     ³±±
±±³          ³ cSexo    - Sexo do Usuario (Ex.: 1=Masculino)              ³±±
±±³          ³ cMatric  - Matricula da Familia 							  ³±±
±±³          ³ nVlrFai  - Valor da Faixa Etaria (Para calculo)            ³±±
±±³          ³ cCodFai  - Codigo da Faixa (Para procurar o desconto)      ³±±
±±³          ³ lTipo    - Flag para saber se foi Faixa da Empresa/Produto ³±±
±±³          ³ cConEmp  - Contrato Empresa   						      ³±±
±±³          ³ cVerCon  - Versao do Contrato                              ³±±
±±³          ³ cSubCon  - Sub Contrato                                    ³±±
±±³          ³ cVerSub  - Versao do Sub Contrato                          ³±±
±±³          ³ cCodPla  - Codigo do Plano sem Operadora                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//Retorna o {Valor do Desconto, Percentual de Desconto}
//
//
/*/
Function PLSMFPDeFai(cCodigo,cVersao,cTipUsu,cGrauPar,cSexo,cMatric,nVlrFai,cCodQtd,cCodFai,nTipo,cConEmp,cVerCon,cSubCon,cVerSub,cCodPla,cTipReg)

Local nQtdUsr := 0
Local aRetorno := {}
Local aRetDesFai := {}
Local cSql
Local lFlag := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico quantos usuarios existem deste tipo na familia...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aQtdUsrTip := PLSQTDUSR(cMatric,1,"VET")
Local aQtdUsrGra := PLSQTDUSR(cMatric,2,"VET")
Local nQtdUsrTot := PLSQTDUSR(cMatric)

DEFAULT cCodFai := "001"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquiso com todos os parametros...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BIH_CODTIP FROM "+RetSQLName("BIH")+" WHERE "
cSQL += " D_E_L_E_T_= ''"
PLSQuery(cSQL,"TrbBIH")

cSQL := "SELECT BRP_CODIGO FROM "+RetSQLName("BRP")+" WHERE "
cSQL += " D_E_L_E_T_= ''"
PLSQuery(cSQL,"TrbBRP")

If nTipo == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faco uma Sql dos dados que usarei para nao mais ir no banco de dados..³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT BFY_PERCEN,BFY_VALOR,BFY_TIPO,BFY_TIPUSR,BFY_GRAUPA,BFY_QTDDE,BFY_QTDATE,BFY_DATDE,BFY_DATATE FROM "+RetSQLName("BFY")+" WHERE "
	cSQL += "BFY_FILIAL = '"+xFilial("BFY")+"' AND "
	cSQL += "BFY_CODOPE = '"+Substr(cCodigo,1,4)+"' AND "
	cSQL += "BFY_CODEMP = '"+Substr(cCodigo,5,4)+"' AND "
	cSQL += "BFY_MATRIC = '"+Substr(cCodigo,9,6)+"' AND "
	cSQL += "BFY_CODFAI = '"+cCodFai+"'"
	cSQL += " AND D_E_L_E_T_= ''"
	Csql += " ORDER BY BFY_TIPUSR DESC ,BFY_GRAUPA DESC "
	
	PLSQuery(cSQL,"TrbBFY")
	
	While ! TrbBFY->(Eof())
		
		If ! PLSMDesVld(TrbBFY->BFY_DATDE, TrbBFY->BFY_DATATE)
			TrbBFY->(DbSkip())
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 1 - Desc/Acres eh dado com as informacoes referente a familia do usuario..³
		//³ 2 - Desc/Acres eh dado com as informacoes referente ao usuario...         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if TrbBFY->BFY_QTDATE > 0
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFY->BFY_TIPUSR) .And. ! Empty(TrbBFY->BFY_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					TRBBRP->(DbGoTop())
					While ! TRBBRP->(Eof()) .And. !lFlag
						if TRBBIH->BIH_CODTIP == TrbBFY->BFY_TIPUSR .And.;
							TRBBRP->BRP_CODIGO == TrbBFY->BFY_GRAUPA
							nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFY->BFY_TIPUSR})
							nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFY->BFY_GRAUPA})
							if nPosTip > 0 .And. nPosGra > 0
								if aQtdUsrTip[nPosTip,2] >= TrbBFY->BFY_QTDDE  .And.;
									aQtdUsrTip[nPosTip,2] <= TrbBFY->BFY_QTDATE .And.;
									aQtdUsrGra[nPosGra,2] >= TrbBFY->BFY_QTDDE  .And.;
									aQtdUsrGra[nPosGra,2] <= TrbBFY->BFY_QTDATE
									aadd (aRetorno, {TrbBFY->BFY_VALOR,TrbBFY->BFY_PERCEN,TrbBFY->BFY_TIPO})
									lFlag  := .T.
								Endif
							Endif
						Endif
						TRBBRP->(DbSkip())
					Enddo
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Grau de parentesco...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFY->BFY_GRAUPA)	 .And.  Empty(TrbBFY->BFY_TIPUSR)
				TRBBRP->(DbGoTop())
				While ! TRBBRP->(Eof()) .And. !lFlag
					if TRBBRP->BRP_CODIGO == TrbBFY->BFY_GRAUPA
						nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFY->BFY_GRAUPA})
						if nPosGra > 0
							if aQtdUsrGra[nPosGra,2] >= TrbBFY->BFY_QTDDE  .And.;
								aQtdUsrGra[nPosGra,2] <= TrbBFY->BFY_QTDATE
								aadd (aRetorno, {TrbBFY->BFY_VALOR,TrbBFY->BFY_PERCEN,TrbBFY->BFY_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBRP->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Tipo de Usuario...                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFY->BFY_TIPUSR) .And. Empty(TrbBFY->BFY_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					if TRBBIH->BIH_CODTIP == TrbBFY->BFY_TIPUSR
						nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFY->BFY_TIPUSR})
						if nPosTip > 0
							if aQtdUsrTip[nPosTip,2] >= TrbBFY->BFY_QTDDE  .And.;
								aQtdUsrTip[nPosTip,2] <= TrbBFY->BFY_QTDATE
								aadd (aRetorno, {TrbBFY->BFY_VALOR,TrbBFY->BFY_PERCEN,TrbBFY->BFY_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se nada esta preenchido, somente qtd de usuarios 		        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBFY->BFY_TIPUSR) .And. Empty(TrbBFY->BFY_GRAUPA)
				if nQtdUsrTot >= TrbBFY->BFY_QTDDE  .And.;
					nQtdUsrTot <= TrbBFY->BFY_QTDATE
					aadd (aRetorno, {TrbBFY->BFY_VALOR,TrbBFY->BFY_PERCEN,TrbBFY->BFY_TIPO})
				Endif
			Endif
			
		Else
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFY->BFY_TIPUSR) .And. ! Empty(TrbBFY->BFY_GRAUPA)
				if cTipUsu == TrbBFY->BFY_TIPUSR .And. cGrauPar == TrbBFY->BFY_GRAUPA
					aadd (aRetorno, {TrbBFY->BFY_VALOR,TrbBFY->BFY_PERCEN,TrbBFY->BFY_TIPO})
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Grau de parentesco...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFY->BFY_GRAUPA)	 .And.  Empty(TrbBFY->BFY_TIPUSR)
				if cGrauPar == TrbBFY->BFY_GRAUPA
					aadd (aRetorno, {TrbBFY->BFY_VALOR,TrbBFY->BFY_PERCEN,TrbBFY->BFY_TIPO})
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Tipo de Usuario...                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFY->BFY_TIPUSR) .And. Empty(TrbBFY->BFY_GRAUPA)
				if TrbBFY->BFY_TIPUSR == cTipUsu
					aadd (aRetorno, {TrbBFY->BFY_VALOR,TrbBFY->BFY_PERCEN,TrbBFY->BFY_TIPO})
				Endif
			Endif
			
		Endif
		
		TrbBFY->(DbSkip())
	Enddo
	
	TrbBFY->(DbCloseArea())
	
ElseIf nTipo == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faco uma Sql dos dados que usarei para nao mais ir no banco de dados..³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT BFT_PERCEN,BFT_VALOR,BFT_TIPO,BFT_TIPUSR,BFT_GRAUPA,BFT_QTDDE,BFT_QTDATE,BFT_DATDE,BFT_DATATE FROM "+RetSQLName("BFT")+" WHERE "
	cSQL += "BFT_FILIAL = '"+xFilial("BFT")+"' AND "
	cSQL += "BFT_CODIGO = '"+cCodigo+"' AND "
	cSQL += "BFT_NUMCON = '"+cConEmp+"' AND "
	cSQL += "BFT_VERCON = '"+cVerCon+"' AND "
	cSQL += "BFT_SUBCON = '"+cSubCon+"' AND "
	cSQL += "BFT_VERSUB = '"+cVerSub+"' AND "
	cSQL += "BFT_CODPRO = '"+cCodPla+"' AND "
	cSQL += "BFT_VERPRO = '"+cVersao+"' AND "
	cSQL += "BFT_CODFAI = '"+cCodQtd+"' AND "
	cSQL += "BFT_CODFAI = '"+cCodFai+"'"
	cSQL += " AND D_E_L_E_T_= ''"
	Csql += " ORDER BY BFT_TIPUSR DESC ,BFT_GRAUPA DESC"
	PLSQuery(cSQL,"TrbBFT")
	
	While ! TrbBFT->(Eof())
		
		If ! PLSMDesVld(TrbBFT->BFT_DATDE, TrbBFT->BFT_DATATE)
			TrbBFT->(DbSkip())
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 1 - Desc/Acres eh dado com as informacoes referente a familia do usuario..³
		//³ 2 - Desc/Acres eh dado com as informacoes referente ao usuario...         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if  TrbBFT->BFT_QTDATE > 0
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFT->BFT_TIPUSR) .And. ! Empty(TrbBFT->BFT_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					TRBBRP->(DbGoTop())
					While ! TRBBRP->(Eof()) .And. !lFlag
						if TRBBIH->BIH_CODTIP == TrbBFT->BFT_TIPUSR .And.;
							TRBBRP->BRP_CODIGO == TrbBFT->BFT_GRAUPA
							nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFT->BFT_TIPUSR})
							nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFT->BFT_GRAUPA})
							if nPosTip > 0 .And. nPosGra > 0
								if aQtdUsrTip[nPosTip,2] >= TrbBFT->BFT_QTDDE  .And.;
									aQtdUsrTip[nPosTip,2] <= TrbBFT->BFT_QTDATE .And.;
									aQtdUsrGra[nPosGra,2] >= TrbBFT->BFT_QTDDE  .And.;
									aQtdUsrGra[nPosGra,2] <= TrbBFT->BFT_QTDATE
									aadd (aRetorno, {TrbBFT->BFT_VALOR,TrbBFT->BFT_PERCEN,TrbBFT->BFT_TIPO})
									lFlag  := .T.
								Endif
							Endif
						Endif
						TRBBRP->(DbSkip())
					Enddo
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Grau de parentesco...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFT->BFT_GRAUPA)	 .And.  Empty(TrbBFT->BFT_TIPUSR)
				TRBBRP->(DbGoTop())
				While ! TRBBRP->(Eof()) .And. !lFlag
					if TRBBRP->BRP_CODIGO == TrbBFT->BFT_GRAUPA
						nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFT->BFT_GRAUPA})
						if nPosGra > 0
							if aQtdUsrGra[nPosGra,2] >= TrbBFT->BFT_QTDDE  .And.;
								aQtdUsrGra[nPosGra,2] <= TrbBFT->BFT_QTDATE
								aadd (aRetorno, {TrbBFT->BFT_VALOR,TrbBFT->BFT_PERCEN,TrbBFT->BFT_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBRP->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Tipo de Usuario...                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFT->BFT_TIPUSR) .And. Empty(TrbBFT->BFT_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					if TRBBIH->BIH_CODTIP == TrbBFT->BFT_TIPUSR
						nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFT->BFT_TIPUSR})
						if nPosTip > 0
							if aQtdUsrTip[nPosTip,2] >= TrbBFT->BFT_QTDDE  .And.;
								aQtdUsrTip[nPosTip,2] <= TrbBFT->BFT_QTDATE
								aadd (aRetorno, {TrbBFT->BFT_VALOR,TrbBFT->BFT_PERCEN,TrbBFT->BFT_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se nada esta preenchido, somente qtd de usuarios 		        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBFT->BFT_TIPUSR) .And. Empty(TrbBFT->BFT_GRAUPA)
				if nQtdUsrTot >= TrbBFT->BFT_QTDDE  .And.;
					nQtdUsrTot <= TrbBFT->BFT_QTDATE
					aadd (aRetorno, {TrbBFT->BFT_VALOR,TrbBFT->BFT_PERCEN,TrbBFT->BFT_TIPO})
				Endif
			Endif
			
		Else
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFT->BFT_TIPUSR) .And. ! Empty(TrbBFT->BFT_GRAUPA)
				if cTipUsu == TrbBFT->BFT_TIPUSR .And. cGrauPar == TrbBFT->BFT_GRAUPA
					aadd (aRetorno, {TrbBFT->BFT_VALOR,TrbBFT->BFT_PERCEN,TrbBFT->BFT_TIPO})
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Grau de parentesco...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFT->BFT_GRAUPA)	 .And.  Empty(TrbBFT->BFT_TIPUSR)
				if cGrauPar == TrbBFT->BFT_GRAUPA
					aadd (aRetorno, {TrbBFT->BFT_VALOR,TrbBFT->BFT_PERCEN,TrbBFT->BFT_TIPO})
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Tipo de Usuario...                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFT->BFT_TIPUSR) .And. Empty(TrbBFT->BFT_GRAUPA)
				if TrbBFT->BFT_TIPUSR == cTipUsu
					aadd (aRetorno, {TrbBFT->BFT_VALOR,TrbBFT->BFT_PERCEN,TrbBFT->BFT_TIPO})
				Endif
			Endif
			
		Endif
		
		TrbBFT->(DbSkip())
	Enddo
	
	TrbBFT->(DbCloseArea())
	
ElseIf nTipo == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faco uma Sql dos dados que usarei para nao mais ir no banco de dados..³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT BFS_PERCEN,BFS_VALOR,BFS_TIPO,BFS_TIPUSR,BFS_GRAUPA,BFS_QTDDE,BFS_QTDATE,BFS_DATDE,BFS_DATATE FROM "+RetSQLName("BFS")+" WHERE "
	cSQL += "BFS_FILIAL = '"+xFilial("BFS")+"' AND "
	cSQL += "BFS_CODIGO = '"+cCodigo+"' AND "
	cSQL += "BFS_VERSAO = '"+cVersao+"' AND "
	cSQL += "BFS_CODFAI = '"+cCodFai+"'"
	cSQL += " AND D_E_L_E_T_= ''"
	Csql += " ORDER BY BFS_TIPUSR DESC ,BFS_GRAUPA DESC "
	
	PLSQuery(cSQL,"TrbBFS")
	
	While ! TrbBFS->(Eof())
		
		If ! PLSMDesVld(TrbBFS->BFS_DATDE, TrbBFS->BFS_DATATE)
			TrbBFS->(DbSkip())
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 1 - Desc/Acres eh dado com as informacoes referente a familia do usuario..³
		//³ 2 - Desc/Acres eh dado com as informacoes referente ao usuario...         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if TrbBFS->BFS_QTDATE > 0
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFS->BFS_TIPUSR) .And. ! Empty(TrbBFS->BFS_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					TRBBRP->(DbGoTop())
					While ! TRBBRP->(Eof()) .And. !lFlag
						if TRBBIH->BIH_CODTIP == TrbBFS->BFS_TIPUSR .And.;
							TRBBRP->BRP_CODIGO == TrbBFS->BFS_GRAUPA
							nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFS->BFS_TIPUSR})
							nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFS->BFS_GRAUPA})
							if nPosTip > 0 .And. nPosGra > 0
								if aQtdUsrTip[nPosTip,2] >= TrbBFS->BFS_QTDDE  .And.;
									aQtdUsrTip[nPosTip,2] <= TrbBFS->BFS_QTDATE .And.;
									aQtdUsrGra[nPosGra,2] >= TrbBFS->BFS_QTDDE  .And.;
									aQtdUsrGra[nPosGra,2] <= TrbBFS->BFS_QTDATE
									aadd (aRetorno, {TrbBFS->BFS_VALOR,TrbBFS->BFS_PERCEN,TrbBFS->BFS_TIPO})
									lFlag  := .T.
								Endif
							Endif
						Endif
						TRBBRP->(DbSkip())
					Enddo
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Grau de parentesco...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFS->BFS_GRAUPA)	 .And.  Empty(TrbBFS->BFS_TIPUSR)
				TRBBRP->(DbGoTop())
				While ! TRBBRP->(Eof()) .And. !lFlag
					if TRBBRP->BRP_CODIGO == TrbBFS->BFS_GRAUPA
						nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBFS->BFS_GRAUPA})
						if nPosGra > 0
							if aQtdUsrGra[nPosGra,2] >= TrbBFS->BFS_QTDDE  .And.;
								aQtdUsrGra[nPosGra,2] <= TrbBFS->BFS_QTDATE
								aadd (aRetorno, {TrbBFS->BFS_VALOR,TrbBFS->BFS_PERCEN,TrbBFS->BFS_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBRP->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Tipo de Usuario...                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFS->BFS_TIPUSR) .And. Empty(TrbBFS->BFS_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					if TRBBIH->BIH_CODTIP == TrbBFS->BFS_TIPUSR
						nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBFS->BFS_TIPUSR})
						if nPosTip > 0
							if aQtdUsrTip[nPosTip,2] >= TrbBFS->BFS_QTDDE  .And.;
								aQtdUsrTip[nPosTip,2] <= TrbBFS->BFS_QTDATE
								aadd (aRetorno, {TrbBFS->BFS_VALOR,TrbBFS->BFS_PERCEN,TrbBFS->BFS_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se nada esta preenchido, somente qtd de usuarios 		        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBFS->BFS_TIPUSR) .And. Empty(TrbBFS->BFS_GRAUPA)
				if nQtdUsrTot >= TrbBFS->BFS_QTDDE  .And.;
					nQtdUsrTot <= TrbBFS->BFS_QTDATE
					aadd (aRetorno, {TrbBFS->BFS_VALOR,TrbBFS->BFS_PERCEN,TrbBFS->BFS_TIPO})
				Endif
			Endif
			
		Else
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFS->BFS_TIPUSR) .And. ! Empty(TrbBFS->BFS_GRAUPA)
				if cTipUsu == TrbBFS->BFS_TIPUSR .And. cGrauPar == TrbBFS->BFS_GRAUPA
					aadd (aRetorno, {TrbBFS->BFS_VALOR,TrbBFS->BFS_PERCEN,TrbBFS->BFS_TIPO})
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Grau de parentesco...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFS->BFS_GRAUPA)	 .And.  Empty(TrbBFS->BFS_TIPUSR)
				if cGrauPar == TrbBFS->BFS_GRAUPA
					aadd (aRetorno, {TrbBFS->BFS_VALOR,TrbBFS->BFS_PERCEN,TrbBFS->BFS_TIPO})
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Tipo de Usuario...                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBFS->BFS_TIPUSR) .And. Empty(TrbBFS->BFS_GRAUPA)
				if TrbBFS->BFS_TIPUSR == cTipUsu
					aadd (aRetorno, {TrbBFS->BFS_VALOR,TrbBFS->BFS_PERCEN,TrbBFS->BFS_TIPO})
				Endif
			Endif
			
		Endif
		
		TrbBFS->(DbSkip())
	Enddo
	
	TrbBFS->(DbCloseArea())
	
ElseIf nTipo == 4
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faco uma Sql dos dados que usarei para nao mais ir no banco de dados..³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT BDQ_PERCEN,BDQ_VALOR,BDQ_TIPO,BDQ_TIPUSR,BDQ_GRAUPA,BDQ_QTDDE,BDQ_QTDATE,BDQ_DATDE,BDQ_DATATE FROM "+RetSQLName("BDQ")+" WHERE "
	cSQL += "BDQ_FILIAL = '"+xFilial("BDQ")+"' AND "
	cSQL += "BDQ_CODINT = '"+Subs(cMatric,atCodOpe[1],atCodOpe[2])+"' AND "
	cSQL += "BDQ_CODEMP = '"+Subs(cMatric,atCodEmp[1],atCodEmp[2])+"' AND "
	cSQL += "BDQ_MATRIC = '"+Subs(cMatric,atMatric[1],atMatric[2])+"' AND "
	cSQL += "BDQ_TIPREG = '"+cTipReg+"' AND "
	cSQL += "BDQ_CODFAI = '"+cCodFai+"' AND "
	cSQL += "D_E_L_E_T_= ''"
	Csql += " ORDER BY BDQ_TIPUSR DESC ,BDQ_GRAUPA DESC "
	
	PLSQuery(cSQL,"TrbBDQ")
	
	While ! TrbBDQ->(Eof())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 1 - Desc/Acres eh dado com as informacoes referente a familia do usuario..³
		//³ 2 - Desc/Acres eh dado com as informacoes referente ao usuario...         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if TrbBDQ->BDQ_QTDATE > 0
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBDQ->BDQ_TIPUSR) .And. ! Empty(TrbBDQ->BDQ_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					TRBBRP->(DbGoTop())
					While ! TRBBRP->(Eof()) .And. !lFlag
						if TRBBIH->BIH_CODTIP == TrbBDQ->BDQ_TIPUSR .And.;
							TRBBRP->BRP_CODIGO == TrbBDQ->BDQ_GRAUPA
							nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBDQ->BDQ_TIPUSR})
							nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBDQ->BDQ_GRAUPA})
							if nPosTip > 0 .And. nPosGra > 0
								if aQtdUsrTip[nPosTip,2] >= TrbBDQ->BDQ_QTDDE  .And.;
									aQtdUsrTip[nPosTip,2] <= TrbBDQ->BDQ_QTDATE .And.;
									aQtdUsrGra[nPosGra,2] >= TrbBDQ->BDQ_QTDDE  .And.;
									aQtdUsrGra[nPosGra,2] <= TrbBDQ->BDQ_QTDATE
									aadd (aRetorno, {TrbBDQ->BDQ_VALOR,TrbBDQ->BDQ_PERCEN,TrbBDQ->BDQ_TIPO})
									lFlag  := .T.
								Endif
							Endif
						Endif
						TRBBRP->(DbSkip())
					Enddo
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Grau de parentesco...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBDQ->BDQ_GRAUPA)	 .And.  Empty(TrbBDQ->BDQ_TIPUSR)
				TRBBRP->(DbGoTop())
				While ! TRBBRP->(Eof()) .And. !lFlag
					if TRBBRP->BRP_CODIGO == TrbBDQ->BDQ_GRAUPA
						nPosGra := aScan(aQtdUsrGra,{|x|x[1]==TrbBDQ->BDQ_GRAUPA})
						if nPosGra > 0
							if aQtdUsrGra[nPosGra,2] >= TrbBDQ->BDQ_QTDDE  .And.;
								aQtdUsrGra[nPosGra,2] <= TrbBDQ->BDQ_QTDATE
								aadd (aRetorno, {TrbBDQ->BDQ_VALOR,TrbBDQ->BDQ_PERCEN,TrbBDQ->BDQ_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBRP->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Tipo de Usuario...                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBDQ->BDQ_TIPUSR) .And. Empty(TrbBDQ->BDQ_GRAUPA)
				TRBBIH->(DbGoTop())
				While ! TRBBIH->(Eof()) .And. !lFlag
					if TRBBIH->BIH_CODTIP == TrbBDQ->BDQ_TIPUSR
						nPosTip := aScan(aQtdUsrTip,{|x|x[1]==TrbBDQ->BDQ_TIPUSR})
						if nPosTip > 0
							if aQtdUsrTip[nPosTip,2] >= TrbBDQ->BDQ_QTDDE  .And.;
								aQtdUsrTip[nPosTip,2] <= TrbBDQ->BDQ_QTDATE
								aadd (aRetorno, {TrbBDQ->BDQ_VALOR,TrbBDQ->BDQ_PERCEN,TrbBDQ->BDQ_TIPO})
								lFlag  := .T.
							Endif
						Endif
					Endif
					TRBBIH->(DbSkip())
				Enddo
			Endif
			
			lFlag := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se nada esta preenchido, somente qtd de usuarios 		        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Empty(TrbBDQ->BDQ_TIPUSR) .And. Empty(TrbBDQ->BDQ_GRAUPA)
				if nQtdUsrTot >= TrbBDQ->BDQ_QTDDE  .And.;
					nQtdUsrTot <= TrbBDQ->BDQ_QTDATE
					aadd (aRetorno, {TrbBDQ->BDQ_VALOR,TrbBDQ->BDQ_PERCEN,TrbBDQ->BDQ_TIPO})
				Endif
			Endif
			
		Else
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido o Grau e o Tipo do Usuario ao mesmo tempo...³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBDQ->BDQ_TIPUSR) .And. ! Empty(TrbBDQ->BDQ_GRAUPA)
				if cTipUsu == TrbBDQ->BDQ_TIPUSR .And. cGrauPar == TrbBDQ->BDQ_GRAUPA
					aadd (aRetorno, {TrbBDQ->BDQ_VALOR,TrbBDQ->BDQ_PERCEN,TrbBDQ->BDQ_TIPO})
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Grau de parentesco...             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBDQ->BDQ_GRAUPA)	 .And.  Empty(TrbBDQ->BDQ_TIPUSR)
				if cGrauPar == TrbBDQ->BDQ_GRAUPA
					aadd (aRetorno, {TrbBDQ->BDQ_VALOR,TrbBDQ->BDQ_PERCEN,TrbBDQ->BDQ_TIPO})
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico se esta preenchido somente o Tipo de Usuario...                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(TrbBDQ->BDQ_TIPUSR) .And. Empty(TrbBDQ->BDQ_GRAUPA)
				if TrbBDQ->BDQ_TIPUSR == cTipUsu
					aadd (aRetorno, {TrbBDQ->BDQ_VALOR,TrbBDQ->BDQ_PERCEN,TrbBDQ->BDQ_TIPO})
				Endif
			Endif
			
		Endif
		
		TrbBDQ->(DbSkip())
	Enddo
	
	TrbBDQ->(DbCloseArea())
	
	
Endif

TrbBRP->(DbCloseArea())
TrbBIH->(DbCloseArea())

Return(aRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRFIX  ³ Autor ³ Tulio Cesar       ³ Data ³ 06.03.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Forma de pagamento valor fixo por contrato...              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Na versao 6.09 para traz ela tinha o nome de PLVALCONT     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRFIX(	cAno, cMes, _nTipo, _cNivel, cCodFor, lAcumul, lFaturamento,;
					cModal, nUsuarios, nLido, nValCont, nValCob)
Local nIndice
Local aMeses	:= {}, nMeses
LOCAL cMatric
LOCAL cCodInt
LOCAL cCodEmp
LOCAL cMatricUsr
LOCAL cTipReg
LOCAL aRet    	:= {}
Local _nValAum, _nValAns
Local aVlrTx
Local lFecha	:= .T.
Local cAnoAnt 	:= cAno, cMesAnt := cMes
Local aBfq		:= {}
Local nVlrTxa	:= 0
Local nTotusr	:= 0
Local nMesCobra	:= 1
Local lProporc	:= .F.
LOCAL cCodTit  	:= SuperGetMv("MV_PLCDTIT")

DEFAULT lAcumul := .F.
DEFAULT lFaturamento := .F.
DEFAULT cModal := ""

If cMes = "01"
	cMesAnt := "12"
	cAnoAnt := Str(Val(cAno) - 1, 4)
Else
	cMesAnt := StrZero(Val(cMes) - 1, 2)
Endif
dData := LastDay(Ctod("01/" + cMes + "/" + cAno))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se e por usuario ou por familia...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if _nTipo == 0
	cMatric    := BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
	cCodInt    := BA3->BA3_CODINT
	cCodEmp    := BA3->BA3_CODEMP
	cMatricUsr := BA3->BA3_MATRIC
Else
	cMatric    := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
	cCodInt    := BA1->BA1_CODINT
	cCodEmp    := BA1->BA1_CODEMP
	cMatricUsr := BA1->BA1_MATRIC
	cTipReg    := BA1->BA1_TIPREG
Endif

If Select("SELEUSR") = 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a familia/sub-contrato tem cobranca no mes              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	! lAcumul .And.;
		! PLSMCalMes(	BA3->BA3_CODINT,;
		  				BA3->BA3_CODEMP,;
						BA3->BA3_CONEMP,;
						BA3->BA3_VERCON,;
						BA3->BA3_MATRIC,;
						BA3->BA3_CODPLA,;
						BA3->BA3_VERSAO,;
						BA3->BA3_SUBCON,;
						BA3->BA3_VERSUB,;
						"2", BA3->BA3_FORPAG, cAno, cMes, aMeses, @nMesCobra)
		Return aRet
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Leitura de todos os usuarios de uma familia...                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DATINC, BA1_COEFIC, BA1_DATNAS, BA1_10ANOS, BA1_TIPUSU, "
	cSQL += "BA1_GRAUPA, BA1_SEXO, BA1_NOMUSR, BA1_DATBLO, BA1_MOTBLO, BA1_DATINC, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_DIGITO, BA1_INDREA, BA1_MESREA, BA1_FXCOB, BA1_OUTLAN, R_E_C_N_O_ BA1REG "
	cSQL += "FROM "+RetSQLName("BA1")+" WHERE "
	cSQL += "BA1_FILIAL = '"+xFilial("BA1")+"' AND "
	cSQL += "BA1_CODINT = '"+cCodInt+"' AND "
	cSQL += "BA1_CODEMP = '"+cCodEmp+"' AND "
	cSQL += "BA1_MATRIC = '"+cMatricUsr+"' AND "
	if _nTipo == 1
		cSQL += "BA1_TIPREG = '"+cTipReg+"' AND "
	Endif
	cSQL += "D_E_L_E_T_ = '' ORDER BY "
	cSQL += "BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG"

	PLSQUERY(cSQL,"SELEUSR")
Else
	DbSelectArea("SELEUSR")
	lFecha := .F.
Endif

While ! SELEUSR->(Eof())
	dNascto  := SELEUSR->BA1_DATNAS
	nIdade	 := Calc_Idade(dData,dNascto)
	If ! PLSXUsrBlo(cAno,cMes,SELEUSR->BA1_DATBLO,SELEUSR->BA1_MOTBLO)
		PlsMGerDev(	SELEUSR->BA1_DATBLO,SELEUSR->BA1_CODINT,SELEUSR->BA1_CODEMP,SELEUSR->BA1_CONEMP,;
					SELEUSR->BA1_VERCON,SELEUSR->BA1_SUBCON,SELEUSR->BA1_VERSUB,;
					SELEUSR->BA1_MATRIC,SELEUSR->BA1_TIPREG,SELEUSR->BA1_DIGITO,;
					AllTrim(SELEUSR->BA1_NOMUSR)+" ("+AllTrim(Str(nIdade))+")",;
					SELEUSR->BA1_SEXO, SELEUSR->BA1_GRAUPA, SELEUSR->BA1_TIPUSU,;
					cMesAnt, cAnoAnt, aRet, nTotUsr)
	
		SELEUSR->(DbSkip())
		Loop
	Else
		dDataInc := SELEUSR->BA1_DATINC
		nCoefic  := SELEUSR->BA1_COEFIC
		nTotUsr  := 0
	Endif

    aBfq := {}
    If cModal <> "2"	// Custo-Operacional
		aBfq := RetornaBfq(cCodInt, "101")
	Endif
	nLido ++
	
	If nUsuarios = nLido
	   	nTotUsr := Round(nValCont - nValCob, 2)
	Else
		nTotUsr := Round(nValCont / nUsuarios, 2)
		nValCob += nTotUsr
	Endif    

	lProporc := PlsProCalc(@nTotUsr, dDataInc, nMesCobra, cMes, cAno, aMeses)

    If Len(aBfq) > 0
		aadd(aRet,{	"1",;
		nTotUsr,;
		"101",;
		BA3->BA3_CODPLA,;
		BI3->BI3_DESCRI,;
		"",;
		SELEUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
		AllTrim(SELEUSR->BA1_NOMUSR),;
		.T.,;
		SELEUSR->BA1_SEXO,;
		SELEUSR->BA1_GRAUPA,;
		0,;
		"",;
		"",;
		SELEUSR->BA1_TIPUSU,;
		"",;
		"",;
		PlsBaseIR(aBfq[nBFQ_INCIR], aBfq[nBFQ_REGCIR], nTotUsr),;
		0.00 })
	Endif
		
	If Len(aRet) > 0 
		PlsAplURea(	aRet, cAno, cMes, @nTotUsr, SELEUSR->BA1_MATRIC,;
					SELEUSR->BA1_TIPREG,SELEUSR->BA1_DIGITO,SELEUSR->BA1_CODINT,;
					SELEUSR->BA1_CODEMP,SELEUSR->BA1_CONEMP,;
					SELEUSR->BA1_VERCON,SELEUSR->BA1_SUBCON,;
					SELEUSR->BA1_VERSUB,SELEUSR->BA1_NOMUSR,;
					SELEUSR->BA1_SEXO,SELEUSR->BA1_GRAUPA,;
					SELEUSR->BA1_TIPUSU,"101",Nil,"SELEUSR")
		aRet[Len(aRet)][18] := PlsBaseIR(aBfq[nBFQ_INCIR], aBfq[nBFQ_REGCIR], nTotUsr)
	Endif
		
// Cobrancas padroes - Taxa de Adesao, Reajuste e Taxa de Identificacao
	If ! lAcumul
		aBfq := RetornaBfq(cCodInt, "103")
	Else
		aBfq := {}
	Endif
	If Len(aBfq) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Codigo 103 - Taxa de Adesao.                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aVlrTx := 	PLSVLRTXAD(SELEUSR->BA1_CODINT,SELEUSR->BA1_CODEMP,;
					SELEUSR->BA1_MATRIC,SELEUSR->BA1_TIPREG,SELEUSR->BA1_DIGITO,;
					cAno, cMes, aRet, nUsuarios, .T.)

// Limito o valor da taxa de adesao por familia de acordo caso o limite esteja definido
// no Produto
		
		If ! aVlrTx[1] .And. aVlrTx[2] > 0 .And. BI3->BI3_LIMTXA > 0
			If nVlrTxa + aVlrTx[2] > BI3->BI3_LIMTXA
				aVlrTx[2] := BI3->BI3_LIMTXA - nVlrTxa
			Endif
		Endif      

		If ! aVlrTx[1] .And. aVlrTx[2] > 0
			nVlrTxa += aVlrTx[2]
			lCalc := .T.
			aadd(aRet,{	aBfq[nBFQ_DEBCRE],;
			aVlrTx[2],;
			aBfq[nBFQ_CODLAN],;
			"",;
			aBfq[nBFQ_DESCRI],;
			"",;
			SELEUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
			AllTrim(SELEUSR->BA1_NOMUSR)+" ("+AllTrim(Str(nIdade))+")",;
			.T.,;
			SELEUSR->BA1_SEXO,;
			SELEUSR->BA1_GRAUPA,;
			0,;
			aVlrTx[3],;
			aVlrTx[4],;
			SELEUSR->BA1_TIPUSU,;
			"",;
			"",;
			PlsBaseIR(aBfq[nBFQ_INCIR], aBfq[nBFQ_REGCIR], aVlrTx[2]),;
			0.00 })
			nTotUsr += aVlrTx[2]
		Endif
	Endif

	aBfq := RetornaBfq(cCodInt, "105")
	If Len(aBfq) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Codigo 105 - Aumentos ANS...                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca valores dos aumentos da ANS...
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		_nValAns := PLSVLRRANS(SELEUSR->BA1_CODINT,SELEUSR->BA1_CODEMP,;
		SELEUSR->BA1_MATRIC,SELEUSR->BA1_TIPREG,cAno,cMes,SELEUSR->BA1_DATINC,;
		aRet,BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,;
		BG9->BG9_TIPO,SELEUSR->BA1_NOMUSR,aBfq[nBFQ_DESCRI],SELEUSR->BA1_SEXO,;
		BA1->BA1_GRAUPA,SELEUSR->BA1REG,SELEUSR->BA1_TIPUSU,;
		SELEUSR->BA1_DIGITO,BA3->BA3_DATCIV,aBfq)
		if ValType(_nValAns) == "N"
			nTotUsr += _nValAns
		Endif
	Endif

	aBfq := RetornaBfq(cCodInt, "106")
	If Len(aBfq) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Codigo 106 - Aumentos de Empresas..                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca valores dos aumentos das Empresas...                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_nValAum := PLSVLAUEM(SELEUSR->BA1_CODINT,SELEUSR->BA1_CODEMP,;
		SELEUSR->BA1_MATRIC,SELEUSR->BA1_TIPREG,cAno,cMes,SELEUSR->BA1_DATINC,aRet,;
		BA3->BA3_CONEMP,BA3->BA3_VERCON,BG9->BG9_TIPO,SELEUSR->BA1_NOMUSR,aBfq[nBFQ_DESCRI],;
		SELEUSR->BA1_SEXO,SELEUSR->BA1_GRAUPA,SELEUSR->BA1REG,SELEUSR->BA1_TIPUSU,;
		SELEUSR->BA1_DIGITO,SELEUSR->BA1_SUBCON,SELEUSR->BA1_VERSUB,"SELEUSR",aBfq)
		if ValType(_nValAum) == "N"
			nTotUsr += _nValAum
		Endif
	Endif

    If ! lAcumul
		aBfq := RetornaBfq(cCodInt, "107")
	Else
		aBfq := {}
	Endif
	If Len(aBfq) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca valores de cobranca de identificacao de usuarios...           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aVlrCIden := SELEUSR->(PLSVLRCBID(BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO,BA1_CONEMP,BA1_VERCON,BA1_SUBCON,BA1_VERSUB,.F.))
		
		If Len(aVlrCIden) > 0
			For nIndice := 1 To Len(aVlrCIden)
				If aVlrCIden[nIndice][2] > 0
					lCalc := .T.
					aadd(aRet,{aBFQ[nBFQ_DEBCRE],;
					aVlrCIden[nIndice][2],;
					aBFQ[nBFQ_CODLAN],;
					"",;
					aBFQ[nBFQ_DESCRI],;
					"",;
					SELEUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
					AllTrim(SELEUSR->BA1_NOMUSR)+" ("+AllTrim(Str(nIdade))+")",;
					.T.,;
					SELEUSR->BA1_SEXO,;
					SELEUSR->BA1_GRAUPA,;
					0,;
					"",;
					"",;
					SELEUSR->BA1_TIPUSU,;
					"BED",;
					aVlrCIden[nIndice][1],;
					PlsBaseIR(aBFQ[nBFQ_INCIR], aBFQ[nBFQ_REGCIR], aVlrCIden[nIndice][2]),;
					0.00})
					nTotUsr += aVlrCIden[nIndice][2]
				Endif
			Next
		Endif
	Endif

    If ! lAcumul
		aBfq := RetornaBfq(cCodInt, "110")
	Else
		aBfq := {}
	Endif
	If Len(aBfq) > 0 .And. (SELEUSR->BA1_TIPUSU == cCodTit)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca valores para agravo...                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrAgr := SELEUSR->(PLSVLRAGR(BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,cMes,cAno))
		
		If nVlrAgr > 0
			lCalc := .T.
			aadd(aRet,{aBfq[nBFQ_DEBCRE],;
			nVlrAgr,;
			aBfq[nBFQ_CODLAN],;
			"",;
			aBfq[nBFQ_DESCRI],;
			"",;
			SELEUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
			AllTrim(SELEUSR->BA1_NOMUSR)+" ("+AllTrim(Str(nIdade))+")",;
			.T.,;
			SELEUSR->BA1_SEXO,;
			SELEUSR->BA1_GRAUPA,;
			0,;
			"",;
			"",;
			SELEUSR->BA1_TIPUSU,;
			"",;
			"",;
			PlsBaseIR(aBfq[nBFQ_INCIR], aBfq[nBFQ_REGCIR], nVlrAgr),;
			0.00 })
			nTotUsr += nVlrAgr
		Endif
	Endif

	PlsEndCalc(aRet, cAno, cMes, @nTotUsr, "SELEUSR")
	
	aadd(aRet,{	"",;
	nTotUsr,;
	"",;
	"",;
	"TOTAL DO USUARIO",;
	"",;
	SELEUSR->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
	"",;
	.F.,;
	"",;
	"",;
	0,;
	"",;
	"",;
	"",;
	"",;
	"",;
	0,;
	If(lProporc, dDataInc, Ctod("")) })
	/*
	// Usuarios Retroativos - Caso seja pessoa juridica 
	If 	Len(aRet) > 0 .And. BA3->BA3_TIPOUS = "2" .And. BQC->BQC_COBRET = "1" .And.;
		BQC->BQC_DIARET > 0 .And.;
		Left(Dtos(SELEUSR->BA1_DATINC), 6) = cAnoAnt + cMesAnt .And.;
		Day(SELEUSR->BA1_DATINC) <= BQC->BQC_DIARET
		
		PlsIncCalc(	aRet, PLSPORFAI(cAnoAnt, cMesAnt, _nTipo, _cNivel, cForPag,;
  					lAcumul, lFaturamento,cModal,{,,, .T. }))
	// Usuarios Retroativos - Caso seja pessoa Fisica
	ElseIf 	Len(aRet) > 0 .And. BA3->BA3_TIPOUS = "1" .And. BA3->BA3_COBRET = "1" .And.;
			BA3->BA3_DIARET > 0 .And.;
			Left(Dtos(SELEUSR->BA1_DATINC), 6) = cAnoAnt + cMesAnt .And.;
			Day(SELEUSR->BA1_DATINC) <= BA3->BA3_DIARET
   		PlsIncCalc(	aRet, PLSPORFAI(cAnoAnt, cMesAnt, _nTipo, _cNivel, cForPag,;
     				lAcumul, lFaturamento,cModal,{,,, .T. }))
	Endif
	*/
	if _nTipo == 1
		Exit
	Endif

	SELEUSR->(DbSkip())
Enddo

If lFecha
	SELEUSR->(DbCloseArea())
Endif

If ! lAcumul
	For nMeses := 1 To Len(aMeses)
		aCalc := PLSVLRFIX(	Right(aMeses[nMeses][1], 4),;
					  		Left(aMeses[nMeses][1], 2), _nTipo, _cNivel, cCodFor, .T.,;
							lFaturamento, If(aMeses[nMeses][2], "1", "2"), nUsuarios,;
							nLido, nValCont, @nValCob)
		PlsIncCalc(aRet, aCalc, cMes, cAno, aMeses[nMeses])
	Next
Endif

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSMCalMesºAutor  ³Wagner Mobile Costa º Data ³  07/28/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao que retorna se deve ser efetuada cobranca no MES     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSMFPG                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSMCalMes(	cCodInt,cCodEmp,cConEmp,cVerCon,cMatric,cCodPla,cVersao,;
cSubCon,cVerSub,_cNivel,cForPag,cAno, cMes, aMeses, nMesCobra)
Local nIndice
Local aRet 		:= {}, cSql := cAlias := "", cArea := Alias()
Local aCpoMes	:= { 	"JAN", "FEV", "MAR", "ABR", "MAI", "JUN", "JUL", "AGO", "SET",;
"OUT", "NOV", "DEZ" }
Local cAnoCalc	:= cAno, cMesCalc := cMes, lExit, lRet := .T.

If cMes = "01"
	cMesCalc := "12"
	cAnoCalc := Str(Val(cAno) - 1, 4)
Else
	cMesCalc := StrZero(Val(cMes) - 1, 2)
Endif

If _cNivel = "2"	// Sub-Contrato
	cSQL := "SELECT * FROM "+RetSQLName("BBZ")+" WHERE "
	cSQL += "BBZ_FILIAL = '"+xFilial("BBZ")+"' AND "
	cSQL += "BBZ_CODIGO = '"+cCodInt+cCodEmp+"' AND "
	cSQL += "BBZ_NUMCON = '"+cConEmp+"' AND "
	cSQL += "BBZ_VERCON = '"+cVerCon+"' AND "
	cSQL += "BBZ_SUBCON = '"+cSubCon+"' AND "
	cSQL += "BBZ_VERSUB = '"+cVerSub+"' AND "
	cSQL += "BBZ_CODPRO = '"+cCodPla+"' AND "
	cSQL += "BBZ_VERPRO = '"+cVersao+"' AND "
	cSQL += "BBZ_CODFOR = '"+cForPag+"' AND "
	cSQL += "D_E_L_E_T_ = ''"
	cAlias := "BBZ"
ElseIF _cNivel = "3"		// Familia
	cSQL := "SELECT * FROM "+RetSQLName("BZY")+" WHERE "
	cSQL += "BZY_FILIAL = '"+xFilial("BZY")+"' AND "
	cSQL += "BZY_CODOPE = '"+cCodInt+"' AND "
	cSQL += "BZY_CODEMP = '"+cCodEMP+"' AND "
	cSQL += "BZY_MATRIC = '"+cMatric+"' AND "
	cSQL += "BZY_CODFOR = '"+cForPag+"' AND "
	cSQL += " D_E_L_E_T_= ''"
	cAlias := "BZY"
Endif

If ! Empty(cSql)
	PLSQuery(cSQL,"PLSMESCOB")
	lRet := &(cAlias + "_COB" + aCpoMes[Val(cMes)]) <> "0"

	If lRet .And. ! Eof() .And. &(cAlias + "_COB" + aCpoMes[Val(cMesCalc)]) <> "1"
		While .T.
			lExit := .F.
			For nIndice := Val(cMesCalc) To 1 Step -1
				If 	&(cAlias + "_COB" + aCpoMes[nIndice]) <> "1"
					nMesCobra ++
					Aadd(aMeses, { StrZero(nIndice, 2) + cAnoCalc, &(cAlias + "_ACU" + aCpoMes[nIndice]) = "1" })
				ElseIf &(cAlias + "_COB" + aCpoMes[nIndice]) <> "0"
					lExit := .T.
					Exit
				Endif
			Next
			cAnoCalc := Str(Val(cAnoCalc) - 1, 4)
			cMesCalc := "12"
			If lExit
				Exit
			Endif
		EndDo
	Endif
	PLSMESCOB->( DbCloseArea() )
	DbSelectArea(cArea)
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCalcJurºAutor  ³Wagner Mobile Costa º Data ³  08/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao que calcula o juros sobre cobranca do mes anterior   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSMFPG                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PlsCalcJur(aRet, cAno, cMes, nTotUsr, cMATRIC,cTIPREG,cDigito,;
				cCODINT,cCODEMP,cCONEMP,cVERCON,cSUBCON,cVERSUB,cNome,cSexo,cGrauPar,;
				cTipUsu)

Local nBaseJur := 0, nJuros, aBfq := {}
Local lCalcJur := .F., 	nTaxDia := 0, nJurDia := 0, cChvTit := "", cSql, cArea := Alias()

If BA3->BA3_TIPOUS = "2"
	lCalcJur := BT6->BT6_COBJUR = "1"
	nTaxDia := BT6->BT6_TAXDIA
	nJurDia := BT6->BT6_JURDIA
Else
	lCalcJur := BI3->BI3_COBJUR = "1"
	nTaxDia := BI3->BI3_TAXDIA
	nJurDia := BI3->BI3_JURDIA
Endif

If lCalcJur
	cSQL := "SELECT * FROM "+RetSQLName("BM1")+" WHERE "
	cSQL += "BM1_FILIAL = '"+xFilial("BA1")+"' AND "
	cSQL += "BM1_CODINT = '"+cCodInt+"' AND "
	cSQL += "BM1_CODEMP = '"+cCodEmp+"' AND "
	cSQL += "BM1_CONEMP = '"+cConEmp+"' AND "
	cSQL += "BM1_VERCON = '"+cVerCon+"' AND "
	cSQL += "BM1_SUBCON = '"+cSubCon+"' AND "
	cSQL += "BM1_VERSUB = '"+cVerSub+"' AND "
	cSQL += "BM1_MATRIC = '"+cMatric+"' AND "
	cSQL += "BM1_LTOTAL = '1' AND "
	cSQL += "D_E_L_E_T_ = '' "
	cSQL += "ORDER BY BM1_FILIAL, BM1_CODINT, BM1_CODEMP, BM1_MATRIC, BM1_ANO, BM1_MES"
	
	PLSQUERY(cSQL,"BM1QRY")
	While ! Eof()
		nBaseJur += BM1QRY->BM1_VALOR
		cChvTit := BM1QRY->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT)
		BM1QRY->(DbSkip())
	EndDo
	BM1QRY->( DbCloseArea() )
	DbSelectArea(cArea)
	If Empty(cChvTit)
		lCalcJur := .F.
	Endif
	
Endif

If lCalcJur
	// Codigo do faturamento da cobranca de juros do mes anterior 111
	aBfq := RetornaBfq(BA3->BA3_CODINT, "111")
Endif

If 	lCalcJur .And.;
	(SE1->(MsSeek(xFilial("SE1") + cChvTit)) .And. SE1->E1_SALDO > 0 .And.;
	SE1->E1_VALJUR + SE1->E1_PORCJUR = 0)		// Para nao calcular o juros caso ja tenha sido gerado no titulo
	
	If (nJuros := PlsJuros(nTAXDIA,nJURDIA,nBaseJur)) > 0
		aadd(aRet,{	"1",;
		nJuros,;
		"111",;
		"",;
		aBfq[nBFQ_DESCRI],;
		"",;
		cCodInt+cCodEmp+cMatric+cTipReg+cDigito,;
		"",;
		.T.,;
		"",;
		"",;
		0,;
		"",;
		"",;
		"",;
		"",;
		0.00 })

		nTotUsr += nJuros
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsIncCalcºAutor  ³Wagner Mobile Costa º Data ³  08/05/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao que junta mais de um mes de calculo                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSMFPG                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PlsIncCalc(aRet, aCalc, cMes, cAno, cMesAnoIni, __cUsuario)
							  
Local nPosAglu, nRet, nPosCob, cMAUsIni

DEFAULT __cUsuario := ""

For nRet := 1 To Len(aCalc)
	nPosAglu := Ascan(aRet, {|x| 	x[5] == "TOTAL DO USUARIO" .And.;
									x[7] == aCalc[nRet][7] })
	If ! Empty(aCalc[nRet][3])
		If (nPosAglu := (Ascan(aRet, {|x| 	x[1] == aCalc[nRet][1] .And.;
											aCalc[nRet][2] > 0 .And.;
											x[3] == aCalc[nRet][3] .And.;
											x[7] == aCalc[nRet][7] } ))) > 0
			aRet[nPosAglu][2] += aCalc[nRet][2]
			If Len(aCalc[nRet]) > 17
				aRet[nPosAglu][18] += aCalc[nRet][18]
			Endif
		Else
			Aadd(aRet, aClone(aCalc[nRet]))
		Endif
		nPosAglu := Ascan(aRet, {|x| 	x[5] == "TOTAL DO USUARIO" .And.;
										x[7] == aCalc[nRet][7] })
		aRet[nPosAglu][2] += aCalc[nRet][2]
	Endif
	If 	! Empty(aCalc[nRet][6]) .And. Empty(aRet[nPosAglu][6])
		aRet[nPosAglu][6] := aCalc[nRet][6]
	Endif
Next

// Troco o codigo de total de usuario ZZZ para que fique no final

For nRet := 1 To Len(aRet)
	If Empty(aRet[nRet][3])
		If cMes <> Nil .And. cAno # Nil .And. (Empty(__cUsuario) .Or. aRet[nRet][7] = __cUsuario)
			If Right(aRet[nRet][6], 5) = "Dias]"
				aRet[nRet][6] := Left(aRet[nRet][6], Len(aRet[nRet][6]) - 1) + " " +;
				Trans(cMesAnoIni, "@R 99/9999") + " - " + cMes + "/" + cAno + "]"
			Else
				cMAUsIni := cMesAnoIni
				If ! Empty(aRet[nRet][19])
					cMAUsIni := StrZero(Month(aRet[nRet][19]), 2) +;
								Str(Year(aRet[nRet][19]), 4)
				Endif
				If (nPosCob := At("[Cobranca", aRet[nRet][6])) > 0
					aRet[nRet][6] := 	Left(aRet[nRet][6], nPosCob - 1) +;
										"[Cobranca " + Trans(cMAUsIni, "@R 99/9999")  + " - " +;
										cMes + "/" + cAno + "]"
				Else
					aRet[nRet][6] += 	If(Empty(aRet[nRet][6]), "", " ") +;
										"[Cobranca " + Trans(cMAUsIni, "@R 99/9999")  + " - " +;
										cMes + "/" + cAno + "]"
				Endif
			Endif
		Endif
		If aRet[nRet][9]
			aRet[nRet][3] := aRet[nRet][4] + "ZZZ"
		Else
			aRet[nRet][3] := "ZZZ"
		Endif
	Endif
Next
aRet := Aclone(aSort(aRet,,, { |x,y| x[7] + x[3] < y[7] + y[3] }))

For nRet := 1 To Len(aRet)
	If "ZZZ" $ aRet[nRet][3]
		aRet[nRet][3] := "   "
	Endif
Next

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PlsJuros  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 06/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o juros de um determinado titulo.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³PlsJuros(ExpN1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1		: Juros Diarios									  ³±±
±±³			 ³ExpN2		: Percentual de juros                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaPls 	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsJuros(nJurDia,nPerJur,nVlrTit,cAlias,nMoeda,dBaixa)

Local nJuros := 0

If cAlias == NIL
	cAlias := "SE1"
Endif

nJurDia:= If(nJurDia==Nil,(cAlias)->E1_VALJUR,nJurDia)
nPerJur:= If(nPerJur==Nil,(cAlias)->E1_PORCJUR,nPerJur)
nMoeda := If(nMoeda==Nil,1,nMoeda)
nVlrTit:= If(nVlrTit==Nil,(cAlias)->E1_SALDO,nVlrTit)
dBaixa := If(Type("dBaixa")=="U",dDataBase,dBaixa)

nJuros := faJuros(Nil,nVlrTit,(cAlias)->E1_VENCREA,nJurDia,nPerJur,(cAlias)->E1_MOEDA,(cAlias)->E1_EMISSAO,dBaixa)
nJuros := xMoeda(nJuros,1,nMoeda,If((cAlias)->E1_MOEDA==nMoeda,(cAlias)->E1_EMISSAO,dDataBase))

Return(nJuros)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PlsAplURea³ Autor ³ Wagner Mobile Costa   ³ Data ³ 09/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Procura pelo ultimo reajuste aplicado para considerar no mes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³PlsAplURea(ExpA1, ExpC1, ExpC2)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1		: Array com a composicao de cobranca			  ³±±
±±³			 ³ExpC1		: Ano                                             ³±±
±±³			 ³ExpC2		: Mes                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaPls 	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsAplURea(aRet, cAno, cMes, nTotUsr, cMATRIC,cTIPREG,cDigito,;
					cCODINT,cCODEMP,cCONEMP,;
					cVERCON,cSUBCON,cVERSUB,cNome,cSexo,cGrauPar,cTipUsu,cCodBFQ,;
					cCodFai,cAliasBA1)
LOcal nCodBfr
Local cAnoAnt := cAno, cMesAnt	:= cMes, cArea := Alias()
Local nCrdAju := nPerRea := 0, nRet
LOCAL nVlrBase := nAjuste := nReajuste := 0
Local lReajuste := .F., nPerAju := 0, aBfq
Local nBfr 		:= nCodBfr := 0

If BA1->BA1_LANREJ <> "1"		// Usuario tem reajustes lancados
	Return
Endif

If aRet <> Nil
	nRet := Len(aRet)
Endif

// Ajustes aplicados

If cMes = "01"
	cMesAnt := "12"
	cAnoAnt := Str(Val(cAno) - 1, 4)
Else
	cMesAnt := StrZero(Val(cMes) - 1, 2)
Endif

cFiltro := 	"SELECT SUM(BM1_VALOR) BM1_VALOR FROM " + RetSqlName("BM1") + " "+;
			"WHERE BM1_FILIAL = '" + xFilial("BM1") + "' AND "+;
			"BM1_CODTIP IN ('105', '106') AND BM1_ORIGEM = '" + cCodBFQ + "' AND " +;
			"BM1_MATRIC = '" + cMatric + "' AND " +;
			"BM1_TIPREG = '" + cTipReg + "' AND " +;
			"BM1_DIGITO = '" + cDigito + "' AND " +;
			"BM1_CODINT = '" + cCodInt + "' AND " +;
			"BM1_CODEMP = '" + cCodEmp + "' AND " +;
			"BM1_CONEMP = '" + cConEmp + "' AND " +;
			"BM1_VERCON = '" + cVerCon + "' AND " +;
			"BM1_SUBCON = '" + cSubCon + "' AND " +;
			"BM1_VERSUB = '" + cVerSub + "' AND " +;
			"BM1_ANO + BM1_MES <= '" + cAnoAnt + cMesAnt + "' AND " +;
			"D_E_L_E_T_ = ' '"
cFiltro := ChangeQuery(cFiltro)
			
dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BM1QRY", .F., .T.)
If aRet <> Nil
	aRet[nRet][2] += BM1QRY->BM1_VALOR
Endif
nTotUsr += BM1QRY->BM1_VALOR
nReajuste := BM1QRY->BM1_VALOR
BM1QRY->( DbCloseArea() )

// Creditos aplicados

cFiltro := 	"SELECT SUM(BM1_VALOR) BM1_VALOR FROM " + RetSqlName("BM1") + " "+;
			"WHERE BM1_FILIAL = '" + xFilial("BM1") + "' AND "+;
			"BM1_CODTIP = '112' AND BM1_ORIGEM = '" + cCodBFQ + "' AND " +;
			"BM1_MATRIC = '" + cMatric + "' AND " +;
			"BM1_TIPREG = '" + cTipReg + "' AND " +;
			"BM1_DIGITO = '" + cDigito + "' AND " +;
			"BM1_CODINT = '" + cCodInt + "' AND " +;
			"BM1_CODEMP = '" + cCodEmp + "' AND " +;
			"BM1_CONEMP = '" + cConEmp + "' AND " +;
			"BM1_VERCON = '" + cVerCon + "' AND " +;
			"BM1_SUBCON = '" + cSubCon + "' AND " +;
			"BM1_VERSUB = '" + cVerSub + "' AND " +;
			"BM1_ANO + BM1_MES <= '" + cAnoAnt + cMesAnt + "' AND " +;
			"D_E_L_E_T_ = ' '"
cFiltro := ChangeQuery(cFiltro)
			
dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "BM1QRY", .F., .T.)
If aRet <> Nil
	aRet[nRet][2] -= BM1QRY->BM1_VALOR
Endif
nTotUsr -= BM1QRY->BM1_VALOR
nAjuste := BM1QRY->BM1_VALOR
BM1QRY->( DbCloseArea() )

If aRet = Nil
	BM1->(DbSetOrder(1))

	If ! Empty(cArea)
		DbSelectArea(cArea)
	Endif
	Return
Endif
/*
BM1->(DbSetOrder(3))
If BM1->(MsSeek(xFilial("BM1") + cCodInt + cCodEmp + cConEmp + cVerCon + cSubCon +;
				cVerSub + cMatric + cTipReg + "106" + cAnoAnt + cMesAnt))
	lReajuste := PlsRetRej(	aRet, cCodInt, cCodEmp, cConEmp, cVerCon, cSubCon, cVerSub,;
							BA3->BA3_MATRIC, cTipReg, cDigito, cNome, cSexo,;
							cGrauPar, cTipUsu, BA3->BA3_CODPLA,;
							BA3->BA3_VERSAO, cAnoAnt, cMesAnt, cAliasBA1, Nil,;
							Nil, Nil, Nil, Nil, Nil, @nPerAju)
Endif
*/
If lReajuste .And. nPerAju > 0
	M->BHW_CODINT := BHW->BHW_CODINT
	M->BHW_CODEMP := BHW->BHW_CODEMP
	M->BHW_CONEMP := BHW->BHW_CONEMP
	M->BHW_VERCON := BHW->BHW_VERCON
	M->BHW_SUBCON := BHW->BHW_SUBCON
	M->BHW_VERSUB := BHW->BHW_VERSUB
	M->BHW_CODPLA := BHW->BHW_CODPLA
	M->BHW_VERPLA := BHW->BHW_VERPLA
	M->BHW_MATRIC := BHW->BHW_MATRIC
	M->BHW_ANOMES := cAnoAnt + cMesAnt
	
	If ! PLS750Cob(.T.)
		RecLock("BHW", .F.)
		BHW->BHW_PERAJU := 0
		BHW->(MsUnLock())
	Else
	
		nPerRea := BM1->BM1_VALOR

		nBfr := RetPosBfr(cCodInt, "106")
		
		For nCodBfr := 1 To Len(_aBfr[nBfr][2])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procura pelo valor base...                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If BM1->(MsSeek(	xFilial("BM1") + cMatric + cTipReg + cCodInt + cCodEmp + cConEmp +;
								cVerCon + cSubCon + cVerSub + _aBfr[nBfr][2][nCodBfr] + cAnoAnt +;
								cMesAnt))
							
				If BM1->BM1_TIPO = "1"
					nVlrBase += BM1->BM1_VALOR
				Else
					nVlrBase -= BM1->BM1_VALOR
				Endif
			Endif
		Next
		
		nVlrBase += nReajuste
		nVlrBase -= nPerRea
		nVlrBase -= nAjuste
	
		nCrdAju	:= ((nVlrBase*nPerAju)/100)
		aRet[nRet][2] -= nCrdAju
	
		nTotUsr -= nCrdAju	// Tiro do acumulado em relacao ao produto
		nTotUsr -= nCrdAju	// Tiro do valor total pois o Ajuste eh credor
	
        If Len(aBfq := RetornaBfq(cCodInt, "112")) > 0
			aadd(aRet,{aBfq[nBFQ_DEBCRE],;
			nCrdAju,;
			"112",;
			"",;
			aBfq[nBFQ_DESCRI],;
			AllTrim(Str(nPerAju)) + " %",;
			cCodInt+cCodEmp+cMatric+cTipReg+cDigito,;
			cNome,;
			.T.,;
			cSexo,;
			cGrauPar,;
			0,;
			"",;
			"6",;
			cTipUsu,;
			"BFQ",;
			cCodBFQ,;
			PlsBaseIR(aBfq[nBFQ_INCIR], aBfq[nBFQ_REGCIR], nCrdAju),;
			0.00})
		Endif
	Endif
Endif
BM1->(DbSetOrder(1))

If ! Empty(cArea)
	DbSelectArea(cArea)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSEndCalcºAutor  ³Wagner Mobile Costa º Data ³  11/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Finaliza o calculo por usuario de todas as formas cobranca  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSMFPG                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PlsEndCalc(aRet, cAno, cMes, nTotUsr, cAliasBA1)

Local nRet, nBaseIR := nIRRF := 0, aBfq := {}, cSql

If (cAliasBA1)->BA1_OUTLAN = "1" .Or. BA3->BA3_OUTLAN = "1"
	aBfq := RetornaBfq((cAliasBA1)->BA1_CODINT, "113")
Endif

If Len(aBfq) > 0	
	BSQ->(DbSetOrder(2))
	cSQL := "SELECT * FROM "+RetSQLName("BSQ")+" WHERE "
	cSQL += "BSQ_FILIAL = '"+xFilial("BSQ")+"' AND "
	cSQL += "BSQ_USUARI = '"+(cAliasBA1)->BA1_CODINT+(cAliasBA1)->BA1_CODEMP+;
			(cAliasBA1)->BA1_MATRIC+(cAliasBA1)->BA1_TIPREG+(cAliasBA1)->BA1_DIGITO+"' AND "
	cSQL += "BSQ_CODINT = '"+(cAliasBA1)->BA1_CODINT+"' AND "
	cSQL += "BSQ_CODEMP = '"+(cAliasBA1)->BA1_CODEMP+"' AND "
	cSQL += "BSQ_CONEMP = '"+(cAliasBA1)->BA1_CONEMP+"' AND "
	cSQL += "BSQ_VERCON = '"+(cAliasBA1)->BA1_VERCON+"' AND "
	cSQL += "BSQ_SUBCON = '"+(cAliasBA1)->BA1_SUBCON+"' AND "
	cSQL += "BSQ_VERSUB = '"+(cAliasBA1)->BA1_VERSUB+"' AND "
	cSQL += "BSQ_ANO = '"+cAno+"' AND BSQ_MES = '"+cMes+"' AND "
	cSQL += "D_E_L_E_T_ = ' ' ORDER BY " + SqlOrder(BSQ->(IndexKey()))
	
	BSQ->(PLSQuery(cSQL,"PLSBSQ"))
Endif
	
While Len(aBfq) > 0 .And. ! PLSBSQ->(Eof())
	BSP->(MsSeek(xFilial("BSP") + PLSBSQ->BSQ_CODLAN))
	aadd(aRet,{PLSBSQ->BSQ_TIPO,;
	PLSBSQ->BSQ_VALOR,;
	"113",;
	PLSBSQ->BSQ_CODLAN,;
	BSP->BSP_DESCRI,;
	"",;
	(cAliasBA1)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
	(cAliasBA1)->(BA1_NOMUSR),;
	.T.,;
	(cAliasBA1)->(BA1_SEXO),;
	(cAliasBA1)->(BA1_GRAUPA),;
	0,;
	"",;
	"",;
	(cAliasBA1)->(BA1_TIPUSU),;
	"BSQ",;
	PLSBSQ->BSQ_CODSEQ,;
	PlsBaseIR(aBfq[nBFQ_INCIR], aBfq[nBFQ_REGCIR], PLSBSQ->BSQ_VALOR),;
	0.00 })
	If PLSBSQ->BSQ_TIPO = "1"
		nTotUsr += PLSBSQ->BSQ_VALOR
	Else
		nTotUsr -= PLSBSQ->BSQ_VALOR
	Endif
	PLSBSQ->(DbSkip())		
EndDo

If Select("PLSBSQ") > 0
	PLSBSQ->(DbCloseArea())
Endif

If (cAliasBA1)->BA1_TIPUSU = SuperGetMv("MV_PLCDTIT")
	PlsCalcJur(	aRet, cAno, cMes, @nTotUsr, (cAliasBA1)->(BA1_MATRIC),;
				(cAliasBA1)->(BA1_TIPREG),(cAliasBA1)->(BA1_DIGITO),;
				(cAliasBA1)->(BA1_CODINT),(cAliasBA1)->(BA1_CODEMP),;
				(cAliasBA1)->(BA1_CONEMP),(cAliasBA1)->(BA1_VERCON),;
				(cAliasBA1)->(BA1_SUBCON),(cAliasBA1)->(BA1_VERSUB),;
				(cAliasBA1)->(BA1_NOMUSR),(cAliasBA1)->(BA1_SEXO),;
				(cAliasBA1)->(BA1_GRAUPA),(cAliasBA1)->(BA1_TIPUSU))
Endif

For nRet := 1 To Len(aRet)
	If 	aRet[nRet][7] = (cAliasBA1)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) .And.;
		Len(aRet[nRet]) > 17
		nBaseIR += aRet[nRet][18]	// Base do IR
	Endif
Next

aBfq := RetornaBfq((cAliasBA1)->BA1_CODINT, "199")

If nBaseIR > 0 .And. Len(aBfq) > 0
	nIRRF := nBaseIR * (SuperGetMv("MV_ALIQIRF") / 100)
Endif

If nIrrf > 0
	aadd(aRet,{"2",;
	0,;
	"199",;
	"",;
	aBfq[nBFQ_DESCRI],;
	"",;
	(cAliasBA1)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
	(cAliasBA1)->(BA1_NOMUSR),;
	.T.,;
	(cAliasBA1)->(BA1_SEXO),;
	(cAliasBA1)->(BA1_GRAUPA),;
	0,;
	"",;
	"",;
	(cAliasBA1)->(BA1_TIPUSU),;
	"",;
	"",;
	"0",;
	nIRRF })	
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsBaseIr ºAutor  ³Wagner Mobile Costa º Data ³  10/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Retorna se o item compoe a base e de qual forma             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSMFPG                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PlsBaseIr(cBaseIR, cFormula, nValor)

Local nRet := 0

If cBaseIR = "1" .And. BA3->BA3_TIPOUS = "2"		// Somente pessoa juridica
	If ! Empty(cFormula)
		If "PLS" $ Upper(cFormula) .And. FindFunction("U_" + cFormula)
			nRet := ExecBlock(cFormula, .F., .F., nValor)
		Else
			nRet := (nValor * &(cFormula))
		Endif
	Else
		nRet := nValor
	Endif
	
	nRet := Round(nRet, 2)
Endif

Return nRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSMDesVld ³ Autor ³Wagner Mobile Costa³ Data ³ 11.09.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna se a data de desconto eh valida                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dDatde   - Inicio da Validade do Desconto				  ³±±
±±³          ³ dDatde   - Final da Validade do Desconto				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSMDesVld(dDatDe, dDatAte)

//Return 	(Empty(dDatDe) .Or. Ctod("01/" + __MES + "/" + __ANO) >= dDatDe) .And.;
//		(Empty(dDatAte) .Or. Ctod("01/" + __MES + "/" + __ANO) <= dDatAte)
		
Return 	(Empty(dDatDe) .Or. Ctod("01/" + STRZERO(Month(Date()),2) + "/" + ALLTRIM(STR(year(Date())))) >= dDatDe) .And.;
       (Empty(dDatAte) .Or. Ctod("01/" + STRZERO(Month(Date()),2) + "/" + ALLTRIM(STR(year(Date())))) <= dDatAte)
		
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSMGerDev ³ Autor ³Wagner Mobile Costa³ Data ³ 12.09.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se deve ser gerada devolucao de valor em bloqueio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChave   - Usuario para verificacao       			  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSMGerDev(dDataBlo,cCODINT,cCODEMP,cCONEMP,cVERCON,cSUBCON,cVERSUB,cMATRIC,;
					cTIPREG, cDIGITO, cNomUsr, cSexo, cGrauPa, cTipUsu, cMesAnt, cAnoAnt,;
					aRet, nTotUsr)

Local cAnoBlq := Str(Year(dDataBlo), 4), cMesBlq := StrZero(Month(dDataBlo), 2)
Local aBfq

BM1->(DbSetOrder(3))
BD6->(DbSetOrder(5))
aBfq := RetornaBfq(cCODINT, "114")

If  cAnoBlq = cAnoAnt .And. cMesBlq = cMesAnt .And.;
	BM1->(MsSeek(xFilial("BM1") + cCODINT + cCODEMP + cCONEMP + cVERCON + cSUBCON +;
				 cVERSUB + cMATRIC + cTIPREG + EVENTO_DEVOLUCAO + cAnoAnt + cMesAnt)) .And.;
   ! BD6->(MsSeek(xFilial("BD6") + cCodInt + cCodEmp + cMatric + cTipReg + cDigito))
	nTotUsr -= BM1->BM1_VALOR
	aadd(aRet,{	"2",;
				BM1->BM1_VALOR,;
				"114",;
				"",;
				aBfq[nBFQ_DESCRI],;
				"",;
				cCodInt+cCodEmp+cMatric+cTipReg+cDigito,;
				cNomUsr,;
				.T.,;
				cSexo,;
				cGrauPa,;
				0,;
				"",;
				"",;
				cTipUsu,;
				"",;
				"",;
				PlsBaseIR(aBfq[nBFQ_INCIR], aBfq[nBFQ_REGCIR], BM1->BM1_VALOR),;
				0.00})
				
	aadd(aRet,{	"",;
	nTotUsr,;
	"",;
	"",;
	"TOTAL DO USUARIO",;
	"",;
	cCodInt+cCodEmp+cMatric+cTipReg+cDigito,;
	"",;
	.F.,;
	"",;
	"",;
	0,;
	"",;
	"",;
	"",;
	"",;
	"",;
	Ctod("") })
Endif
BM1->(DbSetOrder(1))
BD6->(DbSetOrder(1))

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CarregaBfq ³ Autor ³Wagner Mobile Costa³ Data ³ 01.10.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega o array das definicoes de cobranca da operadora    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodInt  - Codigo da Operadora a ser incluida		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CarregaBfq(cCodInt)
Local i
Local cArea := Alias()
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta area com os lancamentos do faturamento...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BFQ_PROPRI, BFQ_CODLAN, BFQ_DEBCRE, BFQ_DESCRI, BFQ_INCIR, BFQ_REGCIR, BFQ_SEQUEN FROM "+RetSQLName("BFQ")+" WHERE "
cSQL += "BFQ_FILIAL = '"+xFilial("BFQ")+"' AND "
cSQL += "BFQ_CODINT = '"+cCodInt+"' ORDER BY "
cSQL += "BFQ_FILIAL, BFQ_SEQUEN"
	
PLSQuery(cSQL,"PLSBFQTrb")

aAux := {}
While ! Eof()
 
   Aadd(aAux, {PLSBFQTrb->(BFQ_PROPRI+BFQ_CODLAN),PLSBFQTrb->BFQ_DEBCRE, PLSBFQTrb->BFQ_DESCRI,;
 			    "",PLSBFQTrb->BFQ_INCIR, PLSBFQTrb->BFQ_REGCIR,;
			    .F.,;
			    PLSBFQTrb->BFQ_SEQUEN })
   DbSkip()
EndDo

PLSBFQTrb->( DbCloseArea() )

lInc := .F.
For i := 1 to len(__aCodCob)
    If  aScan(aAux,{|X| X[1] = "1"+__aCodCob[i,1]}) == 0
        BFQ->(RecLock("BFQ",.T.))
        BFQ->BFQ_FILIAL := xFilial("BFQ")
        BFQ->BFQ_CODINT := cCodInt
        BFQ->BFQ_PROPRI := "1"
        BFQ->BFQ_CODLAN := __aCodCob[i,1]
        BFQ->BFQ_DESCRI := __aCodCob[i,2]
        BFQ->BFQ_SEQUEN := __aCodCob[i,3]
        BFQ->BFQ_DEBCRE := __aCodCob[i,4]
        BFQ->BFQ_COMISS := __aCodCob[i,5]
        BFQ->BFQ_INCIR  := __aCodCob[i,6]
//      BFQ->BFQ_CALRAT := __aCodCob[i,7]
        BFQ->(msUnLock())
        Aadd(aAux, {BFQ->(BFQ_PROPRI+BFQ_CODLAN), BFQ->BFQ_DEBCRE, BFQ->BFQ_DESCRI,;
		 		     "", BFQ->BFQ_INCIR, BFQ->BFQ_REGCIR,;
				     .F., BFQ->BFQ_SEQUEN})
        lInc := .T.
    Endif
Next    
If  lInc
    aSort(aAux,,,{|x,y| x[1]+x[8] < y[1]+y[8]})
Endif

Aadd(_aBfq, { cCodInt, aAux })

If ! Empty(cArea)
	DbSelectArea(cArea)
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RetornaBfq ³ Autor ³Wagner Mobile Costa³ Data ³ 01.10.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Array com as defiicoes de um codigo de cobranca    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodInt  - Codigo da Operadora a ser incluida		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RetornaBfq(cCodInt, cCodLan)

Local nBfq := 0

_nBfq := 0
If (_nBfq := Ascan(_aBfq, { |x| x[1] = cCodInt })) = 0
	CarregaBfq(cCodInt)
	_nBfq := Len(_aBfq)
Endif

nBfq := Ascan(_aBfq[_nBfq][2], {|x| x[nBFQ_CODLAN] = cCodLan })

Return If(nBfq > 0, _aBfq[_nBfq][2][nBfq], {})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PlsProCalc ³ Autor ³Wagner Mobile Costa³ Data ³ 17.10.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Proporcionaliza o calculo dependendo da data da fam/usuario³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTotUsr  - Valor de cobranca do usuario          	      ³±±
±±³          ³ dDataInc - Data em que o usuario foi incluido    	      ³±±
±±³          ³ nMesCobra- Numero de Meses da cobranca completa  	      ³±±
±±³          ³ cMes     - Mes em que a cobranca e efetuada      	      ³±±
±±³          ³ cAno     - Ano em que a cobranca e efetuada      	      ³±±
±±³          ³ aMeses   - Array com os meses que compoe a cobranca        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsProCalc(nTotUsr, dDataInc, nMesCobra, cMes, cAno, aMeses)

Local lProporc := .F.
Local cAnoMes  := ""

// Proporcionaliza o calculo de acordo com o numero de meses de cobranca
If Len(aMeses) > 1
	cAnoMes := Right(aMeses[Len(aMeses)][1], 4) + Left(aMeses[Len(aMeses)][1], 2)
Endif

If 	nMesCobra > 1 .And. ! Empty(cAnoMes) .And.;
	Left(Dtos(dDataInc), 6) <> Left(Dtos(BA3->BA3_DATBAS), 6) .And.;
	cAnoMes <= Str(Year(dDataInc), 4) + StrZero(Month(dDataInc), 2)
	nTotUsr /= 	nMesCobra 
	nTotUsr *= 	PLSDIFANOS(Str(Year(dDataInc), 4),;
				StrZero(Month(dDataInc), 2),cAno,cMes,"M") + 1
    lProporc := .T.
ElseIf 	nMesCobra > 1 .And. ! Empty(cAnoMes) .And. BA3->BA3_TIPOUS = "2" .And.;
		Left(Dtos(BQC->BQC_DATCON), 6) <> Left(Dtos(BA3->BA3_DATBAS), 6) .And.;
		cAnoMes <= Str(Year(BA3->BA3_DATBAS), 4) + StrZero(Month(BA3->BA3_DATBAS), 2)
	nTotUsr /= 	nMesCobra 
	nTotUsr *= 	PLSDIFANOS(Str(Year(BA3->BA3_DATBAS), 4),;
				StrZero(Month(BA3->BA3_DATBAS), 2),cAno,cMes,"M") + 1
    lProporc := .T.
Endif

Return lProporc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PlsRetQtd  ³ Autor ³Wagner Mobile Costa³ Data ³ 14.11.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca a tabela a indica de qual tabela devera ser utilizada³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsRetQtd(	cCodInt,cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub,;
					cCodPla,cVersao,cForPag,cTipUsu,cSexo,cGrauPar)
Local nPos
Local cCodQtd := "ZZZ"
Local aQtdUsu
Local nQtdusu := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guardo Quantidade de Usuarios do Sub Contrato...                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aQtdUsu := PLQTUSEMP(cCodInt,cCodEmp,cConEmp,cVerCon,cSubCon,cVerSub)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura para todos as chaves preenchidas...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BBS_CODFAI, BBS_TIPUSR,BBS_SEXO,BBS_QTDMIN,"
cSql += "BBS_QTDMAX FROM "+RetSQLName("BBS")+" WHERE "
cSQL += "BBS_FILIAL = '"+xFilial("BBS")+"' AND "
cSQL += "BBS_CODIGO = '"+cCodInt+cCodEmp+"' AND "
cSQL += "BBS_NUMCON = '"+cConEmp+"' AND "
cSQL += "BBS_VERCON = '"+cVerCon+"' AND "
cSQL += "BBS_SUBCON = '"+cSubCon+"' AND "
cSQL += "BBS_VERSUB = '"+cVerSub+"' AND "
cSQL += "BBS_CODPRO = '"+cCodPla+"' AND "
cSQL += "BBS_VERPRO = '"+cVersao+"' AND "
cSQL += "BBS_CODFOR = '"+cForPag+"' AND "
cSQL += "D_E_L_E_T_ = ''"

PLSQuery(cSQL,"TrbBBS")

While !TrbBBS->(Eof())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura para todos o sexo e tipo de usuario... 					  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !Empty(TrbBBS->BBS_TIPUSR) .And. !Empty(TrbBBS->BBS_SEXO)
		if cTipUsu == TrbBBS->BBS_TIPUSR .And. ;
			(cSexo == TrbBBS->BBS_SEXO .Or. TrbBBS->BBS_SEXO == "3")
			nPos := aScan(aQtdUsu,{|x|x[1]==TrbBBS->BBS_TIPUSR .AND. (x[2]==TrbBBS->BBS_SEXO .OR. TrbBBS->BBS_SEXO == "3")})
			if nPos > 0
				if aQtdUsu[nPos,3] >= TrbBBS->BBS_QTDMIN .And.;
					aQtdUsu[nPos,3] <= TrbBBS->BBS_QTDMAX
					cCodQtd := TrbBBS->BBS_CODFAI
					Exit
				Endif
			Endif
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura para todos o tipo de usuario								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !Empty(TrbBBS->BBS_TIPUSR) .And. (Empty(TrbBBS->BBS_SEXO) .or. TrbBBS->BBS_SEXO == "3")
		if cTipUsu == TrbBBS->BBS_TIPUSR
			nQtdUsu := 0
			For nPos := 1 To Len(aQtdUsu)
				nQtdUsu += If(aQtdUsu[nPos][1]==TrbBBS->BBS_TIPUSR,aQtdUsu[nPos][3], 0)
			Next
			if 	nQtdusu >= TrbBBS->BBS_QTDMIN .And.;
				nQtdUsu <= TrbBBS->BBS_QTDMAX
				cCodQtd := TrbBBS->BBS_CODFAI
				Exit
			Endif
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura para todos os sexos                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Empty(TrbBBS->BBS_TIPUSR) .And. !Empty(TrbBBS->BBS_SEXO)
		if (cSexo == TrbBBS->BBS_SEXO .Or. TrbBBS->BBS_SEXO == "3")
			nQtdUsu := 0
			For nPos := 1 To Len(aQtdUsu)
				nQtdUsu += If(aQtdUsu[nPos][2]==TrbBBS->BBS_SEXO .OR. TrbBBS->BBS_SEXO == "3",aQtdUsu[nPos][3], 0)
			Next
			if 	nQtdusu >= TrbBBS->BBS_QTDMIN .And.;
				nQtdUsu <= TrbBBS->BBS_QTDMAX
				cCodQtd := TrbBBS->BBS_CODFAI
				Exit
			Endif
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura para somente a faixa...                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Empty(TrbBBS->BBS_TIPUSR) .And. (Empty(TrbBBS->BBS_SEXO) .or. TrbBBS->BBS_SEXO == "3")
		nQtdUsu := 0
		For nPos := 1 To Len(aQtdUsu)
			nQtdUsu += aQtdUsu[nPos][3]
		Next
		if 	nQtdusu >= TrbBBS->BBS_QTDMIN .And.;
			nQtdUsu <= TrbBBS->BBS_QTDMAX
			cCodQtd := TrbBBS->BBS_CODFAI
			Exit
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura quando nem existe um tratamento de quantidade de usuarios...³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Empty(TrbBBS->BBS_TIPUSR) .And. (Empty(TrbBBS->BBS_SEXO) .or. TrbBBS->BBS_SEXO == "3")
		if 	TrbBBS->BBS_QTDMIN == 0 .And.;
			TrbBBS->BBS_QTDMAX == 999999
			cCodQtd := TrbBBS->BBS_CODFAI
			Exit
		Endif
	Endif
	
	
	TrbBBS->(dbSkip())
Enddo
TrbBBS->(dbCloseArea())

Return cCodQtd

