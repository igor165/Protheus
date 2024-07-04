#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER040.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Função    ³ GPER045  ³ Autor ³ Gabriel A.              ³ Data ³ 29/03/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ³±±
±±³Descrição ³ Folha de Pagamento - Dissídio                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³Programador ³ Data   ³ Issue    ³  Motivo da Alteração                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±|Gabriel A.  |29/03/17|MRH-8376  |Criação do relatório para dissídio        ³±±
±±|            |        |          |conforme existente na versão 11.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPER045()

	Local cDesc1  := STR0108 //"Dissídio"
	Local cDesc2  := STR0002 //"Ser  impresso de acordo com os parametros solicitados pelo usuario."
	Local cString := "SRA"   // Alias do arquivo principal (Base)
	Local aOrd    := {STR0004,STR0005,STR0006,STR0007,STR0008,STR0095} //"C.Custo do Cadastro","Matricula","Nome","C.Custo do Movto.","C.Custo + Nome","Departamento"
	Local cMesAnoRef

	Private lDicInter	:= FindFunction("fChkInterm") .And. fChkInterm()
	Private aReturn   := { STR0009, 1,STR0010, 2, 2, 1,"",1 } //"Zebrado","Administração"
	Private nomeprog  := "GPER045"
	Private aLinha    := {},nLastKey := 0
	Private cPerg     := "GPR040"
	Private lPaisagem := .F.

	// Variaveis Utilizadas na funcao IMPR
	Private Titulo   := STR0107     //"Relatório de Dissídio"
	Private AT_PRG   := "GPER045"
	Private wCabec0  := 1
	Private wCabec1  := ""
	Private CONTFL   := 1
	Private LI       := 0
	Private nTamanho := "M"
	Private cCabec
	Private nOrdem
	Private aInfo    := {}
	Private cTipCC, cRefOco, cVerbaLiq
	Private dRefMoeda

	Private nItensRetirados := 0
	Private nPosRetirada    := 0

	nPosRetirada := Len(aOrd) + 1

	Private lItemClVl 	:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "13"	// Determina se utiliza Item Contabil e Classe de Valores

	If lItemClVl
		aAdd( aOrd, STR0072 ) // "C.Custo + Item + Classe"
	EndIf

	Pergunte("GPR040",.F.)

	// Envia controle para a funcao SETPRINT
	wnrel:="GPER045" //Nome Default do relatorio em Disco
	wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,"",.F.,aOrd,,nTamanho)

	If nLastKey = 27
		Return
	EndIf

	SetDefault( aReturn, cString )

	If nLastKey = 27
		Return
	Endif

	If Empty(mv_par01)
		Help( ' ' , 1 , "DATAREF" , , STR0111 , 1 , 0 )//"Data de referência obrigatória para impressão do relatório."
		Return .F.
	EndIf

	/*	Teste para o ADVPR (Automação de Testes) - lRobo vem .T. do Caso de Teste	*/
	IF TYPE ("lRobo") == "L"
		If !lRobo
			nOrdem 		:= aReturn[8]
		Else
			nOrdem		:= nOrd
		Endif
	Else
		nOrdem 		:= aReturn[8]
	Endif

	// Carregando variaveis mv_par para Variaveis do Sistema
	dDataRef    := mv_par01    // Data de Referencia para a impressao
	dDtaComp    := mv_par01    // Data de Referencia para a impressao
	Semana      := mv_par03    // Numero da Semana
	cFilDe      := mv_par04    // Filial  De
	cFilAte     := mv_par05    // Filial  Ate
	cCcDe       := mv_par06    // Centro de Custo De
	cCcAte      := mv_par07    // Centro de Custo Ate
	cMatDe      := mv_par08    // Matricula De
	cMatAte     := mv_par09    // Matricula Ate
	cNomDe      := mv_par10    // Nome De
	cNomAte     := mv_par11    // Nome Ate
	cSit        := mv_par12    // Situacao
	cCat        := mv_par13    // Categoria
	lSalta      := If(mv_par14 == 1,.T.,.F.)   // Imprime C.C em outra Pagina
	cSinAna     := If(mv_par15 == 1,"A","S")   // Folha Sintetica ou Analitica
	lImpFil     := If(mv_par16 == 1,.T.,.F.)   // Imprime Total Filial
	lImpEmp     := If(mv_par17 == 1,.T.,.F.)   // Imprime Total Empresa
	lImpNiv     := If(mv_par18 == 1,.T.,.F.)   // Imprime Niveis C.Custo
	lUnicNV     := If(mv_par19 == 1,.T.,.F.)   // Imprime Unico Nivel
	lImpTot     := If(mv_par20 == 1,.T.,.F.)   // Imprime Apenas Totais Filial/Empresa
	cTipCC      := mv_par21    // Imprime Codigo ou Descricao C.Custo
	cRefOco     := mv_par22    // Imprime Referencia ou Ocorrencias
	nTpContr    := mv_par23    // Tp Contrato
	cDeptoDe    := mv_par24    // Departamento De
	cDeptoAte   := mv_par25    // Departamento Até
	lImpDepto   := If(mv_par26 == 1,.T.,.F.)   // Imprime Total Departamento
	lSaltaDepto := If(mv_par27 == 1,.T.,.F.)   // Imprime Departamento em Outra Página

	If aReturn[4] == 2 // 1-Retrato/2-Paisagem
		lPaisagem := .T.
		nTamanho := "G"
	EndIf

	// Pega descricao da semana
	cDesOrdem:=If(nOrdem == 1,STR0012,If(nOrdem==2,STR0013,If(nOrdem==3,STR0014,If(nOrdem==4,STR0015,If(nOrdem==5,STR0016,Iif(nOrdem==6,STR0095,Iif(nOrdem ==7,STR0093,"")))))))
	cCabec := " / "+Upper(MesExtenso(Month(dDataRef)))+STR0017+STR(YEAR(dDataRef),4) + cDesOrdem	//" DE "

	Titulo     := STR0018 + STR0090 + cCabec // DISSÍDIO
	NewHead    := Nil
	cMesAnoRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)
	cRelFil    := aReturn[7]

	RptStatus({|lEnd| GR045Imp(@lEnd,wnRel,cString,cMesAnoRef,nTpContr)},Capital(Titulo))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GR045Imp ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 03.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Folha de Pagamanto                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GPR040Imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd        - A‡ao do Codelock                             ³±±
±±³          ³ wnRel       - T¡tulo do relat¢rio                          ³±±
±±³          ³ cString     - Mensagem                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Esta funcao tambem e utilizada a partir da impressao da GPS³±±
±±³          ³ e Contabilizacao(para gerar lancamentos), queira,ao altera-³±±
±±³          ³ la, testar ambas as rotinas.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GR045Imp(lEnd,WnRel,cString,cMesAnoRef,nTpContr)

	Local cArqMov     := ""
	Local cMesArqRef
	Local dChkDtRef   := CTOD("01/"+Left(cMesAnoRef,2)+"/"+Right(cMesAnoRef,4),"DDMMYY")
	Local nQ
	Local nNumCasas   := 1
	Local nG          := 0
	Local nX          := 0
	Local nRegTC      := 0
	Local cArqSRC
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})

	Private lOfusca		:= Len(aFldRel) > 0
	Private cMascCus    := GetMv("MV_MASCCUS")
	Private cQuebFun    := GetMv("MV_QUEBFUN",,"S") //quando for igual a nao, imprime funcionario sem quebrar pagina
	Private aNiveis     := {}
	Private aCodFol     := {}
	Private cTpC        := ""
	Private cTpC1       := ""
	Private aEmpP       := {}  // Empresa
	Private aEmpD       := {}
	Private aEmpB       := {}
	Private aEmpTCP     := {}
	Private aEmpTCD     := {}
	Private aEmpTCB     := {}
	Private aFilP       := {}  // Filial
	Private aFilD       := {}
	Private aFilB       := {}
	Private aFilTCP     := {}
	Private aFilTCD     := {}
	Private aFilTCB     := {}
	Private aCcP        := {}  // Centro de Custo
	Private aCcD        := {}
	Private aCcB        := {}
	Private lCorpManage := fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
	Private lUniNeg     := !Empty(FWSM0Layout(cEmpAnt, 2)) // Verifica se possui tratamento para unidade de Negocios
	Private lEmpFil     := !Empty(FWSM0Layout(cEmpAnt, 1)) // Verifica se possui tratamento para Empresa

	If lCorpManage
		Private aUnNegP  := {}	 // Unidade de Negocios
		Private aUnNegD  := {}
		Private aUnNegB  := {}
		Private aUnNTCP  := {}
		Private aUnNTCD  := {}
		Private aUnNTCB  := {}
		Private aEmpFilP := {}	 // Empresa da Gestao Corporativa - Junto com a Filial
		Private aEmpFilD := {}
		Private aEmpFilB := {}
		Private aEFTCP   := {}
		Private aEFTCD   := {}
		Private aEFTCB   := {}

		Private cLayoutGC  := FWSM0Layout(cEmpAnt)
		Private nEmpLength := Len(FWSM0Layout(cEmpAnt, 1))
		Private nUnNLength := Len(FWSM0Layout(cEmpAnt, 2))
	EndIf

	Private aDeptoP := {}  // Departamento
	Private aDeptoD := {}
	Private aDeptoB := {}

	//Definicao para identificar item e classe na gravação do SRZ
	If Type("lItemClVl") == "U"
		Private lItemClVl := SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "13"
	EndIf

	Private cContribuicao := cContrProAuto := ""
	Private cAnoMesRef    := Right(cMesAnoRef,4) + Left(cMesAnoRef,2)
	Private cAliasMov     := ""
	Private cItAnt        := ""
	Private cClAnt		  := ""
	Private cItCt         := ""
	Private cClVl         := ""
	Private nLi           := SuperGetMv("MV_QBIMPFO",,58)
	Private aTot          := Array( 5, 7 )

	//Situacao Total dos funcionarios de contrato Determinado e Indeterminado
	For nX := 1 To 4
		aFill( aTot[nX], 0 )
	Next nX

	//O valor minimo para saltar de pagina e 58 linhas
	nLi:=  If(nLi > 58, nLi, 58 )

	If Type("aErrProc") == "U"
		Private aErrProc := Array(3,0)
	EndIf

	cMesArqRef := cMesAnoRef

	If !Empty(cAliasMov)
		cArqSRC := cArqMov
	Else
		cArqSRC := RetSqlName( "RHH" )
	Endif

	//aNiveis -  Armazena as chaves de quebra
	If lImpNiv
		aNiveis:= MontaMasc(cMascCus)

		//--Criar os Arrays com os Niveis de Quebras
		For nQ = 1 to Len(aNiveis)
			If nQ > 9
				nNumCasas := 2
			EndIf
			cQ := STR(NQ,nNumCasas)
			Private aCcP&cQ := {}    // Centro de Custo
			Private aCcD&cQ := {}
			Private aCcB&cQ := {}
			cCcAnt&cQ       := ""    //Variaveis c.custo dos niveis de quebra
			//--Totais dos Funcionarios dos Niveis de quebra
			nCnor&cQ := nCafa&cQ := nCdem&cQ := nCfer&cQ := 0
			nCexc&cQ := nCadm&cQ := nCtot&cQ := 0
		Next nQ
	EndIf

	//Imprime folha para tipo de contrato INDETERMINADO
	If nTpContr == 1 .Or. nTpContr == iif(lDicInter,4,3)
		cTpC  := "1"
		cTpC1 := " *1"
		fImpFol(lEnd,cAnoMesRef,cArqSRC)
	EndIf

	//Imprime folha para tipo de contrato DETERMINADO
	If nTpContr == 2 .Or. nTpContr == iif(lDicInter,4,3)
		cTpC  := "2"
		cTpC1 := "2"
		fImpFol(lEnd,cAnoMesRef,cArqSRC)
	EndIf

	If lDicInter .ANd. (nTpContr == 3 .Or. nTpContr == 4)
		cTpC  := "1"
		cTpC1 := "3"
		fImpFol(lEnd,cAnoMesRef,cArqSRC)
	EndIf


	// Impressao dos TOTAIS para os Tipos de Contratos
	If nTpContr == iif(lDicInter,4,3)
		If lImpFil
			// Impressao do TOTAL de Filial
			nRegTC := Len(aFilTCP)
			For nG := 1 To nRegTC
				cFilAnterior 	:= aFilTCP[nG,1]
				aInfo 			:= aFilTCP[nG,2]
				fImprime(aFilTCP[nG,3],aFilTCD[nG,3],aFilTCB[nG,3],91)
			Next nG

			If lCorpManage
				If lUniNeg
					// Impressao do TOTAL da Unidade de Negocios
					nRegTC := Len(aUnNTCP)
					For nG := 1 To nRegTC
						cFilAnterior:= aUnNTCP[nG,1]
						aInfo 		:= aUnNTCP[nG,2]
						fImprime(aUnNTCP[nG,3],aUnNTCD[nG,3],aUnNTCB[nG,3],92)
					Next nG
				EndIf
				If lEmpFil
					nRegTC := Len(aEFTCP)
					For nG := 1 To nRegTC
						cFilAnterior:= aEFTCP[nG,1]
						aInfo 		:= aEFTCP[nG,2]
						fImprime(aEFTCP[nG,3],aEFTCD[nG,3],aEFTCB[nG,3],93)
					Next nG
				EndIf
			EndIf
		EndIf

		If lImpEmp
			nRegTC := Len(aEmpTCP)
			For nG := 1 To nRegTC
				cFilAnterior:= aEmpTCP[nG,1]
				aInfo 		:= aEmpTCP[nG,2]
				fImprime(aEmpTCP[nG,3],aEmpTCD[nG,3],aEmpTCB[nG,3],94)
			Next nG
		EndIf
	EndIf

	//Seleciona arq. defaut do Siga caso Imp. Mov. Anteriores
	If ! Empty( cAliasMov )
		fFimArqMov( cAliasMov , {} , cArqMov )
	EndIf

	//Retorna ordem 1 dos arquivos processados
	dbSelectArea("SRA")
	DbClearFilter()
	dbSetOrder(1)

	//--Gerar Rodape no final da Impressão
	Li := nLi
	Impr("","F")
	Set Device To Screen
	If aReturn[5] = 1
		Set Printer To
		Commit
		ourspool(wnrel)
	Endif
	MS_FLUSH()

Return ( .F. )

*-----------------------------------------------------------*
Static Function fSoma(aMatriz,cArq,cCod,nValor,lResidente)
*-----------------------------------------------------------*
	// 1- Matriz onde os dados estao sendo armazenados
	// 2- Tipo de Arquivo "C" ou "I"
	// 3- Prov/Desc/Base a ser gravado

	Local nRet
	Local nVal1 := nVal2 := nVal3 := 0

	DEFAULT lResidente := .F.
	If Type("lImpDolar") == "U"
		lImpDolar  := .F.
	EndIf


	If cCod == Nil
		cCod := ( cRHHTmp )->RHH_VERBA
	EndIf

	If lResidente .and. ! ( cCod $ cContribuicao )
		Return NIL
	EndIf

	If nValor == Nil
		nValor := ( cRHHTmp )->RHH_VALOR
	EndIf

	nVal1 := If(( cRHHTmp )->RHH_QTDSEM > 0, ( cRHHTmp )->RHH_QTDSEM, ( cRHHTmp )->RHH_HORAS)
	nVal2 := nValor
	nVal3 := 0

	cRVFil := ( cSRCTmp )->RC_FILIAL

	nRet := Ascan( aMatriz,{|X| x[1] == cCod } )				// Testa se ja existe
	If	nRet == 0
		Aadd (aMatriz,{cCod,nVal1,nVal2,nVal3,1,cItCt,cClVl,cRVFil})	// se nao cria elemento
	Else
		aMatriz[nRet,2] += nVal1								// se ja so adiciona
		aMatriz[nRet,3] += nVal2
		aMatriz[nRet,4] += nVal3
		aMatriz[nRet,5] ++
		aMatriz[nRet,8] := cRVFil
	EndIf

Return Nil

*---------------------------*
Static Function fTestaTotal()      // Executa Quebras
*---------------------------*
	Local cCusto
	Local cItem
	Local cClasse
	Local cFilCond
	Local nQ
	Local nNumCasas := 1

	cFilAnterior := ( cSRATmp )->RA_FILIAL

	If nOrdem == 4 .Or. nOrdem == 7
		dbSelectArea( cMainTmp )
		cCcAnt := cCcto
		cItAnt := cItCt
		cClAnt := cClVl
	Else
		cCcAnt := ( cMainTmp )->RA_CC
		If lItemClVl
			cItAnt := ( cMainTmp )->RA_ITEM
			cClAnt := ( cMainTmp )->RA_CLVL
		Else
			cItAnt := ""
			cClAnt := ""
		EndIf

		dbSelectArea( cMainTmp )
		dbSkip()
	Endif

	If lImpNiv .And. Len(aNiveis) > 0
		For nQ = 1 TO Len(aNiveis)
			If nQ > 9
				nNumCasas := 2
			EndIf
			cQ        := Str(nQ,nNumCasas)
			cCcAnt&cQ := Subs(cCcAnt,1,aNiveis[nQ])
		Next nQ
	EndIf

	cFilCond := ( cMainTmp )->RA_FILIAL
	cDeptoCond := ( cMainTmp )->RA_DEPTO

	If nOrdem == 6 .AND. ( Eof() .AND. (lSaltaDepto .OR. lImpDepto) )
		If lCorpManage
			If lEmpFil
				cEmpFil := ""
			EndIf
			If lUniNeg
				cUniNeg := ""
			EndIf
		EndIf
		if lImpDepto
			fImpDepto()
		elseIf lSaltaDepto .AND. !lImpDepto
			Impr("","P")
		endIf
	ElseIf nOrdem == 6 .AND. (cDeptoAnterior # cDeptoCond) .AND. (lSaltaDepto .OR. lImpDepto)
		If lCorpManage
			If lEmpFil
				cEmpFil := ""
			EndIf
			If lUniNeg
				cUniNeg := ""
			EndIf
		EndIf

		If lImpDepto
			fImpDepto()
		ElseIf lSaltaDepto .AND. !lImpDepto
			Impr("","P")
		EndIf

		cDeptoAnterior := cDeptoCond
	EndIf

	If Eof()
		cCusto := Quebra( nOrdem, 'CC' )
		cItem  := Quebra( nOrdem, 'IT' )
		cClasse:= Quebra( nOrdem, 'CL' )
		fImpCc()
		If nOrdem # 7
			fImpNiv(cCcAnt,.T.,cItAnt,cClAnt)
		EndIf
		If lCorpManage
			If lEmpFil
				cEmpFil := ""
			EndIf
			If lUniNeg
				cUniNeg := ""
			EndIf
		EndIf
		fImpFil()
		fImpEmp()

	Elseif cFilAnterior # cFilCond
		fImpCc()
		If nOrdem # 7 // Nao imprime niveis de c.custo na ordem de item + classe
			fImpNiv(cCcAnt,.T.,cItAnt,cClAnt)
		EndIf

		If lCorpManage
			If lEmpFil
				cEmpFil := Substr(cFilCond,At("E",cLayoutGC),nEmpLength)
			EndIf
			If lUniNeg
				cUniNeg := Substr(cFilCond,At("U",cLayoutGC),nUnNLength)
			EndIf
		EndIf
		fImpFil()

	Elseif nOrdem == 7 .And. ! Eof() .And. cCcAnt+cItAnt+cClAnt # ;
		Quebra( nOrdem, 'CC' ) + Quebra( nOrdem, 'IT' ) + Quebra( nOrdem, 'CL' )
		cCusto := Quebra( nOrdem, 'CC' )
		cItem  := Quebra( nOrdem, 'IT' )
		cClasse:= Quebra( nOrdem, 'CL' )
		fImpCc()

	Elseif ! Eof() .And. cCcAnt # Quebra( nOrdem, 'CC' )
		cCusto := Quebra( nOrdem, 'CC' )
		cItem  := Quebra( nOrdem, 'IT' )
		cClasse:= Quebra( nOrdem, 'CL' )
		fImpCc()
		If nOrdem # 7 // Nao imprime niveis de c.custo na ordem de item + classe
			fImpNiv(cCusto,.F.,cItem,cClasse)
		EndIf
	Endif

	dbSelectArea( cMainTmp )

Return Nil

*---------------------------------------*
Static Function fImpFun(aFunP,aFunD,aFunB)            // Imprime um Funcionario
*---------------------------------------*
	Local lGerar	:= .F.

	If	Len(aFunP) == 0 .And. Len(aFunD) == 0 .And. Len(aFunB) == 0
		Return Nil
	Endif

	If ! lImpTot
		If cSinAna == "A"
			fImprime(aFunP,aFunD,aFunB,1)
		Endif
	EndIf

	aFunP := {}
	aFunD := {}
	aFunB := {}

Return Nil

*------------------------*
Static Function fImpCc()             // Imprime Centro de Custo
*------------------------*
	Local lGerar  	:= .F.
	Local nValBas 	:= 0.00
	Local nValAut 	:= 0.00
	Local nValPro 	:= 0.00
	Local nNumCasas := 1
	Local nQ

	If (Len(aCcP) == 0 .And. Len(aCcD) == 0 .And. Len(aCcB) == 0)

		// Zera variaveis do c.c. anterior
		aCcP := {}
		aCcD := {}
		aCcB := {}
		aMatExt	:= {} // bases para funcionários expatriados
		aMatProlab	:= {} // bases para pro-labore
		nCnor := nCafa := nCdem := nCfer := nCexc := nCtot := nCinss := cCadm := 0

		Return Nil
	Endif

	//--SomaToria para os Niveis de Quebra
	If lImpNiv .And. Len(aNiveis) > 0
		For nQ:=1 To Len(aNiveis)
			If nQ > 9
				nNumCasas := 2
			EndIf
			cQ := Str(nQ,nNumCasas)
			aEval(aCcP , { |X| fSomaNv(aCcP&cQ,x[1],x[2],x[3],x[4],x[5]) } )
			aEval(aCcD , { |X| fSomaNv(aCcD&cQ,x[1],x[2],x[3],x[4],x[5]) } )
			aEval(aCcB , { |X| fSomaNv(aCcB&cQ,x[1],x[2],x[3],x[4],x[5]) } )
			nCnor&cQ  += nCnor
			nCafa&cQ  += nCafa
			nCdem&cQ  += nCdem
			nCfer&cQ  += nCfer
			nCexc&cQ  += nCexc
			nCtot&cQ  += nCtot
			nCadm&cQ  += nCadm
		Next nQ
	Endif

	If !lUnicNV .And. !lImpTot
		If nOrdem == 1 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 7
			fImprime(aCcP,aCcD,aCcB,2) // Imprime
		Endif
	Endif

	aCcP := {}
	aCcD := {}
	aCcB := {}
	aMatExt	:= {} // bases para funcionários expatriados
	aMatProLab:= {} // bases para pro-labore
	nCnor := nCafa := nCdem := nCfer := nCexc := nCtot := nCinss := nCadm := 0

Return Nil

*------------------------------------------------*
Static Function fImpNiv(cCusto,lGeral,cItem,cClasse)     // Imprime Centro de Custo
*------------------------------------------------*
	Local nNumCasas := 2
	Local nQ

	//-- Verifica se houve quebra dos Niveis de C.Custo
	If nOrdem == 1 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 7
		If lImpNiv .And. Len(aNiveis) > 0
			For nQ := Len(aNiveis) to 1 Step -1
				If nQ < 10
					nNumCasas := 1
				EndIf
				cQ := Str(nQ,nNumCasas)
				//-- Verifica se houve quebra dos Niveis de C.Custo
				If Subs(cCusto,1,aNiveis[nQ]) # cCcAnt&cQ .Or. lGeral
					If (Len(aCcP&cQ) # 0 .Or. Len(aCcD&cQ) # 0 .Or. Len(aCcB&cQ) # 0)
						fImprime(aCcP&cQ,aCcD&cQ,aCcB&cQ,5,cCcAnt&cQ,cQ,cItAnt,cClAnt)
						aCcP&cQ   := {}
						aCcD&cQ   := {}
						aCcB&cQ   := {}
						nCnor&cQ  := 0
						nCafa&cQ  := 0
						nCdem&cQ  := 0
						nCfer&cQ  := 0
						nCexc&cQ  := 0
						nCtot&cQ  := 0
						nCadm&cQ  := 0
					Endif
				Endif
			Next nQ
		Endif
	Endif

Return Nil

*-----------------------*
Static Function fImpFil()            // Imprime Filial
*-----------------------*
	Local lGerar	:= .F.
	Local lRatDes	:= SuperGetMv( "MV_RAT0973", .F., .F. )

	If	Len(aFilP) == 0 .And. Len(aFilD) == 0 .And. Len(aFilB) == 0
		Return Nil
	Endif

	If lImpFil
		fImprime(aFilP,aFilD,aFilB,3)

		// Totalizar Tipos de Contratos
		If nTpContr == iif(lDicInter,4,3)
			fTotTP(3, aFilP, aFilD, aFilB, @aFilTCP, @aFilTCD, @aFilTCB)
		EndIf

		If lCorpManage
			If lUniNeg
				If Substr(cFilAnterior,At("U",cLayoutGC),nUnNLength) # cUniNeg
					fImprime(aUnNegP,aUnNegD,aUnNegB,6)

					// Totalizar Tipos de Contratos
					If nTpContr == iif(lDicInter,4,3)
						fTotTP(6, aUnNegP, aUnNegD, aUnNegB, @aUnNTCP, @aUnNTCD, @aUnNTCB)
					EndIf

					aUnNegP	  := {}	 // Unidade de Negocios
					aUnNegD	  := {}
					aUnNegB	  := {}
				EndIf
			EndIf
			If lEmpFil
				If Substr(cFilAnterior,At("E",cLayoutGC),nEmpLength) # cEmpFil
					fImprime(aEmpFilP,aEmpFilD,aEmpFilB,7)

					// Totalizar Tipos de Contratos
					If nTpContr == iif(lDicInter,4,3)
						fTotTP(7, aEmpFilP, aEmpFilD, aEmpFilB, @aEFTCP, @aEFTCD, @aEFTCB)
					EndIf

					aEmpFilP  := {}	 // Empresa da Gestao Corporativa - Junto com a Filial
					aEmpFilD  := {}
					aEmpFilB  := {}
				EndIf
			EndIf
		EndIf
	Endif

	aFilP := {}
	aFilD := {}
	aFilB := {}
	nFnor := nFafa := nFdem := nFfer := nFexc := nFtot := nFinss := nFAdm := 0

Return Nil

*------------------------*
Static Function fTotTP(nTipo, aPDP, aPDD, aPDB, aSvPDP, aSvPDD, aSvPDB) // Geração do array de totalizacao por Tipo
*------------------------*
	Local aArray
	Local aSvArray
	Local cPD
	Local cChave
	Local lRatDes	:= SuperGetMv( "MV_RAT0973", .F., .F. )
	Local nI
	Local nY
	Local nPD
	Local nPos
	Local nPosPD

	If nTipo == 3 // nTipo 3 = Filial
		cChave := cFilAnterior
	ElseIf nTipo == 4 // Total da Empresa
		cChave := aInfo[2]
	ElseIf nTipo == 6 // Unidade de Negocio
		cChave := Substr(cFilAnterior,At("U",cLayoutGC),nUnNLength)
	ElseIf nTipo == 7
		cChave := Substr(cFilAnterior,At("E",cLayoutGC),nEmpLength)
	EndIf

	For nI := 1 To 3 // Provento, desconto e base
		If nI == 1
			aArray := aClone(aPDP)
			aSvArray := aClone(aSvPDP)
		ElseIf nI == 2
			aArray := aClone(aPDD)
			aSvArray := aClone(aSvPDD)
		Else
			aArray := aClone(aPDB)
			aSvArray := aClone(aSvPDB)
		EndIf

		nPD 	:= Len( aArray )

		nPos := aScan( aSvArray, { |x| x[1] == cChave } )
		If nPos == 0
			aAdd(aSvArray, { cChave, aInfo, aArray } )
		Else
			For nY := 1 To nPD
				cPD := aArray[nY, 1]
				nPosPD := aScan( aSvArray[nPos,3], { |x| x[1] == cPD } )

				If nPosPD == 0
					Aadd (aSvArray[nPos,3],{aArray[nY,1],aArray[nY,2],aArray[nY,3],aArray[nY,4],aArray[nY,5],aArray[nY,6],aArray[nY,7]})	// se nao cria elemento
				Else
					If lRatDes .Or. (!lRatDes .And. cPD != aCodFol[973, 1])//INSS Empresa s/ Faturamento
						aSvArray[nPos,3,nPosPD, 2] += aArray[nY, 2]								// se ja so adiciona
						aSvArray[nPos,3,nPosPD, 3] += aArray[nY, 3]
						aSvArray[nPos,3,nPosPD, 4] += aArray[nY, 4]
					EndIf
				Endif
			Next nY
		EndIf
		If nI == 1
			aSvPDP := aClone(aSvArray)
		ElseIf nI == 2
			aSvPDD := aClone(aSvArray)
		Else
			aSvPDB  := aClone(aSvArray)
		EndIf
	Next nI

Return

*------------------------*
Static Function fImpEmp()            // Imprime Empresa
*------------------------*
	If Len(aEmpP) == 0 .And. Len(aEmpD) == 0 .And. Len(aEmpB) == 0
		Return Nil
	Endif

		If lImpEmp
			fImprime(aEmpP,aEmpD,aEmpB,4)

			// Totalizar Tipos de Contratos
			If nTpContr == iif(lDicInter,4,3)
				fTotTP(4, aEmpP, aEmpD, aEmpB, @aEmpTCP, @aEmpTCD, @aEmpTCB)
			EndIf

		Endif

	aEmpP := {}
	aEmpD := {}
	aEmpB := {}
	nEnor := nEafa := nEdem := nEfer := nEexc := nEtot := nEinss := 0
	nFuncs := 0

Return Nil

*-----------------------------------------------------------*
Static Function fImprime(aProv,aDesc,aBase,nTipo,cCt,cN,cIt,cCl)
*-----------------------------------------------------------*
	// nTipo: 1- Funcionario
	//        2- Centro de Custo
	//        3- Filial
	//        4- Empresa
	//        5-
	//        6-
	//        7-
	//        8- Departamento
	//		  9x-TOTAL Por Tipo de Contratos - Filial
	Local nMaximo
	Local nConta,nCon
	Local nTVP := nTVD := nLIQ := 0   // Totais dos Valores
	Local nTHP := nTHD := 0 		    // Referencias
	Local cFil,cCc,cPd,nHrs,nVal,nOco
	Local cCodFunc	:= ""
	Local cDescFunc	:= ""
	Local cFilAux	:= cFilAnterior
	Local nRefOco   := 1
	Local nDesc		:= 14
	Local nEsp0		:= 0
	Local nEsp1		:= 1
	Local nEsp4  	:= 4
	Local nEsp6	    := 6
	Local nEsp15 	:= 15
	Local nEsp20 	:= 20
	Local nEsp30 	:= 30
	Local nEsp45 	:= 45
	Local nEsp132	:= 132
	Local nBasDes   := 0
	Local nLinAtu      := 0
	Local nTotalLinhas := 0
	Local nTpTipo	:= Val(Substr(Str(nTipo,2),2,1))

	Private cNv := cN

	//Os espacos foram trocados por variaveis com nomes conforme o
	//tamanho para serem ajustados na impressao em formato Paisagem
	If lPaisagem
		nDesc  := 20
		nEsp0  := 10
		nEsp1  := 21
		nEsp4  := If( cRefOco==2 .And. cSinAna=="S", 26, 29 )
		nEsp6  := 32
		nEsp15 := 30
		nEsp20 := 46
		nEsp30 := 54
		nEsp45 := 71
		nEsp132:= 207
	EndIf

	aProv := ASort (aProv,,,{|x,y| x[1] < y[1] }) // Sorteando Arrays
	aDesc := ASort (aDesc,,,{|x,y| x[1] < y[1] })
	aBase := ASort (aBase,,,{|x,y| x[1] < y[1] })

	nMaximo:= MAX(MAX(Len(aProv),Len(aDesc)),Len(aBase))
	If	nTipo == 1
		If cQuebFun == "S"
			If Li + nMaximo + 6 >= nLi  // Testa somente quando e funcionario
				Impr("","P")            // Salta Pagina caso nao caiba
			EndIf
		Endif
	Elseif nTipo == 2
		If lSalta
			Impr("","P")
		Endif
	Elseif nTipo == 8
		If lSaltaDepto
			Impr("","P")
		Endif
	Else
		Impr("","P")
	Endif

	If Val(Substr(Str(nTipo,2),1,1))==9
		cTit := STR0109 //Todos
	Else
		If cTpC1 $ " *1"
			cTit := STR0025
		ElseIf cTpC1 == "2"
			cTit := STR0026
		ElseIf cTpC1 == "3"
			cTit := STR0110 //"Intermitente"
		EndIf
	EndIf
	WCabec1 := STR0023 + Substr(aInfo[3],1,45) +" " + ;
		If(nTipo#4 .AND. ntipo#6 .AND. nTipo#7 .AND. nTpTipo#2 .AND. nTpTipo#3 .AND. nTpTipo#4, STR0027 + cFilAnterior +" - " + Substr(aInfo[1],1,15), Space(26)) + ;
		STR0024 + cTit	//"Empresa: "###" Contrato do Tipo : "###"Indeterminado"###"Determinado"

	If nTipo == 1

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega Funcao do Funcion. de acordo com a Dt Referencia     ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		fBuscaFuncRel(dDataRef,@cCodFunc, @cDescFunc )

		DET:= ALLTRIM(STR0028)		 //" C.CUSTO: "
		If cTipCC == 1              //-- Codigo
			Det:= Det + If (nOrdem # 4 .And. nOrdem # 7,Subs(( cSRATmp )->RA_CC+Space(20),1,20),Subs(cCcto+Space(20),1,20))
		ElseIf cTipCC == 2          //-- Descricao
			Det:= Det + DescCc(If(nOrdem # 4 .And. nOrdem # 7,( cSRATmp )->RA_CC,cCcto),cFilAnterior,18)
		ElseIf cTipCC == 3          //-- Ambos
			Det:= Det + AllTrim(Subs(If(nOrdem # 4 .And. nOrdem # 7,( cSRATmp )->RA_CC,cCcto)+Space(20),1,20))+" - "+DescCc(If(nOrdem # 4,( cSRATmp )->RA_CC,cCcto),cFilAnterior,20)
		ElseIf cTipCC == 4          //-- Dados Tomador
		    If(Alltrim(POSICIONE("CTT",1,xFilial("CTT")+( cSRATmp )->RA_CC ,"CTT->CTT_NOME")) != "") .and. ;
				( ( CTT->(FieldPos('CTT_RECFAT')) == 0 ) .or. ( Alltrim(POSICIONE("CTT",1,xFilial("CTT")+( cSRATmp )->RA_CC ,"CTT->CTT_RECFAT")) != "S" ) )
				Det:= Det + If (nOrdem # 4 .And. nOrdem # 7,Subs(( cSRATmp )->RA_CC+Space(20),1,20),Subs(cCcto+Space(20),1,20));
				+STR0073+POSICIONE("CTT",1,xFilial("CTT")+( cSRATmp )->RA_CC ,"CTT->CTT_NOME");
				+STR0074+POSICIONE("CTT",1,xFilial("CTT")+( cSRATmp )->RA_CC ,"CTT->CTT_CEI")
				IMPR(DET,"C")
				Det := ""
			Else
				Det:= Det + If (nOrdem # 4 .And. nOrdem # 7,Subs(( cSRATmp )->RA_CC+Space(20),1,20),Subs(cCcto+Space(20),1,20))
			EndIf
		Endif

		Det += STR0029+( cSRATmp )->RA_MAT+STR0030+ If(lOfusca, Replicate('*',30), Subs(( cSRATmp )->RA_NOME,1,30) )+;//" MAT.: "###" NOME: "
		STR0031 + cCodFunc + " " + cDescFunc															 //" FUNCAO: "

	Elseif nTipo == 2
		DET:= STR0032+cFilAnterior+STR0035+cCcAnt+" - "+AllTrim(DescCc(cCcAnt,cFilAnterior))//"Filial: "###" C.CUSTO: "
		//--Descricao Item e Classe
		If nOrdem==7
			cDescIt := AllTrim(fDesc( "CTD", cItAnt , "CTD_DESC01" ))
			cDescCl := AllTrim(fDesc( "CTH", cClAnt , "CTH_DESC01" ))
	        DET += " - "+ STR0080 + AllTrim(cItAnt)+" - "+cDescIt+" - "+STR0081 +Alltrim(cClAnt)+" - "+cDescCl //"ITEM: "##"CLASSE: "
		EndIf
	Elseif nTipo == 3
		DET:= STR0033+cFilAnterior+" - "+aInfo[1]		//"Filial: "
	Elseif nTipo == 6
		DET:= STR0085+" "+aInfo[3] 		//"Unidade de Negocios: "
	Elseif nTipo == 7
		DET:= STR0034+" "+aInfo[3] 		//"Empresa: "
	Elseif nTipo == 4
		If !lCorpManage
			DET:= STR0034+aInfo[3]		//"Empresa: "
		Else
			DET:= STR0086+aInfo[2]		//"Grupo de Empresas: "
		EndIf
	Elseif nTipo == 5
		If cCt # Nil
			DET:= STR0033+cFilAnterior+STR0035+AllTrim(cCt)+" - "+AllTrim(DescCc(cCt,cFilAnterior))+If(nOrdem==7," - "+cIt+" - "+ccCl,'')//"Filial: "###" C.CUSTO: "
		Else
			DET:= STR0033+cFilAnterior+STR0035+AllTrim(cCcAnt)+" - "+AllTrim(DescCc(cCcAnt,cFilAnterior))+If(nOrdem==7," - "+cItAnt+" - "+cClAnt,'')	//"Filial: "###" C.CUSTO: "
		Endif
	Elseif nTipo == 8
		DET:= STR0094+" "+cDeptoAnterior + " - " + fDesc('SQB',cDeptoAnterior,'QB_DESCRIC')
	ElseIf Val(Substr(Str(nTipo,2),1,1))==9
		If nTpTipo==1
			DET:= STR0033+cFilAnterior+" - "+aInfo[1]		//"Filial: "
		ElseIf nTpTipo==2
			DET:= STR0085+" "+aInfo[3] 		//"Unidade de Negocios: "
		ElseIf nTpTipo==3
			DET:= STR0034+aInfo[3]		//"Empresa: "
		ElseIf nTpTipo==4
			DET:= STR0086+aInfo[2]		//"Grupo de Empresas: "
		EndIf
	Endif

	IMPR(DET,"C")

	If	nTipo == 1
		//--vERIFICA SE EXISTEW O CAMPO PARA IMPRESSAO
		If Type("SRA->RA_NOMECOM") # "U" .And. ! Empty(( cSRATmp )->RA_NOMECOM)
			Det := 	STR0067+" "+( cSRATmp )->RA_NOMECOM
			IMPR(DET,"C")
		Endif
		DET:= STR0036+Dtoc(( cSRATmp )->RA_ADMISSA)+STR0037+fDesc("SX5","28"+( cSRATmp )->RA_CATFUNC,"X5DESCRI()",12,( cSRATmp )->RA_FILIAL)+" "
		If !Empty( cAliasMov )
			nValSal := 0
			nValSal := fBuscaSal(dDataRef,,,.f.,cSRATmp)
			If nValSal ==0
				nValSal := ( cSRATmp )->RA_SALARIO
			EndIf
		Else
			nValSal := ( cSRATmp )->RA_SALARIO
		EndIf
		DET+= STR0043+TRANSFORM(nValSal,"@E 999,999,999.99")+STR0044		//"SAL.: "###"  DEP.I.R.: "
		DET+= ( cSRATmp )->RA_DEPIR+STR0045+( cSRATmp )->RA_DEPSF+STR0046+StrZero(( cSRATmp )->RA_PERCADT,3) + " %"+" HR.MES: "	//"  DEP.SAL.FAM.: "###"  PERC.ADTO: "
		DET+= STR(( cSRATmp )->RA_HRSMES,6,2)
	Else
		Det:=" "
	Endif

	IMPR(DET,"C")
	DET:= SPACE(nEsp15)+STR0047+SPACE(nEsp30)+STR0048+SPACE(nEsp30)+STR0049	//"P R O V E N T O S"###"D E S C O N T O S"###"B A S E S"
	IMPR(DET,"C")

	If cRefOco == 2 .And. cSinAna == "S"   //-- Ocorrencia
		If !lPaisagem
			Det := STR0050					//"COD DESCRICAO         OCOR.          VALOR PC|"
			Det += space(1)+STR0050	//"COD DESCRICAO         OCOR.          VALOR PC|"
			Det += space(1)+STR0051			//"COD DESCRICAO              VALOR OCOR."
		Else
			Det := STR0098					//"COD DESCRICAO                                  OCOR.           VALOR PC|"
			Det += space(1)+STR0098	//"COD DESCRICAO                                  OCOR.           VALOR PC|"
			Det += space(1)+STR0099			//"COD DESCRICAO                                    VALOR OCOR."
		EndIf
	Else
		If !lPaisagem
			Det := STR0052					//"COD DESCRICAO          REF.          VALOR PC|"
			Det += space(1)+STR0052	//"COD DESCRICAO          REF.          VALOR PC|"
			Det += space(1)+STR0053			//"COD DESCRICAO                VALOR"
		Else
			Det := STR0097					//"COD DESCRICAO                                    REF.           VALOR PC|"
			Det += space(1)+STR0097	//"COD DESCRICAO                                    REF.           VALOR PC|"
			Det += space(1)+STR0100			//"COD DESCRICAO                                         VALOR"
		EndIf
	EndIf

	IMPR(DET,"C")

	//No total da empresa o conteudo de cFilAnterior traz o nome e nao a Filial
	If nTipo == 94
		cFilAux := cFilAnt
	EndIf

	If cRefOco == 2 .And. cSinAna == "S"   //-- Ocorrencia
		For nConta :=1 TO nMaximo
			cFilAux := IIf(Empty(cFilAux), aProv[nConta,8],cFilAux)
			Det:= If (nConta > Len(aProv),Space(nEsp45),aProv[nConta,1]+" "+Left(DescPd(aProv[nConta,1],If(nTipo = 1,( cSRATmp )->RA_FILIAL,cFilAux)),nDesc)+Space(nEsp1)+;
			Transform(aProv[nConta,5],'99999999')+" "+Transform(aProv[nConta,3],'@E 999,999,999.99')+" "+StrZero(aProv[nConta,4],2))+"| "
			Det +=If (nConta > Len(aDesc),Space(nEsp45),aDesc[nConta,1]+" "+Left(DescPd(aDesc[nConta,1],If(nTipo = 1,( cSRATmp )->RA_FILIAL,cFilAux)),nDesc)+Space(nEsp1)+;
			Transform(aDesc[nConta,5],'99999999')+" "+Transform(aDesc[nConta,3],'@E 999,999,999.99')+" "+StrZero(aDesc[nConta,4],2))+"| "
			Det +=If (nConta > Len(aBase),Space(36),aBase[nConta,1]+" "+Left(DescPd(aBase[nConta,1],If(nTipo = 1,( cSRATmp )->RA_FILIAL,cFilAux)),nDesc)+Space(nEsp1-3)+;
			Transform(aBase[nConta,3],'@E 99,999,999.99')+" "+Transform(aBase[nConta,5],'@E 99999'))
			Impr(Det,"C")
		Next nConta
	Else
		For nConta :=1 TO nMaximo
			cFilAux := IIf(Empty(cFilAux), aProv[nConta,8],cFilAux)
			Det:= If (nConta > Len(aProv),Space(nEsp45+1),aProv[nConta,1]+" "+Left(DescPd(aProv[nConta,1],If(nTipo = 1,( cSRATmp )->RA_FILIAL,cFilAux)),nDesc)+Space(nEsp1)+;
			Transform(aProv[nConta,2],'999999.99')+" "+Transform(aProv[nConta,3],'@E 999,999,999.99')+" "+StrZero(aProv[nConta,4],2))+"| "
			Det +=If (nConta > Len(aDesc),Space(nEsp45+1),aDesc[nConta,1]+" "+Left(DescPd(aDesc[nConta,1],If(nTipo = 1,( cSRATmp )->RA_FILIAL,cFilAux)),nDesc)+Space(nEsp1)+;
			Transform(aDesc[nConta,2],'999999.99')+" "+Transform(aDesc[nConta,3],'@E 999,999,999.99')+" "+StrZero(aDesc[nConta,4],2))+"| "
			Det +=If (nConta > Len(aBase),Space(37),aBase[nConta,1]+" "+Left(DescPd(aBase[nConta,1],If(nTipo = 1,( cSRATmp )->RA_FILIAL,cFilAux)),nDesc)+Space(nEsp1)+;
			Transform(aBase[nConta,3],'@E 999,999,999.99'))
			Impr(Det,"C")
		Next nConta
	Endif

	AeVal(aProv,{ |X| nTHP += X[2]})	// Acumula Referencias
	AeVal(aDesc,{ |X| nTHD += X[2]})
	AeVal(aProv,{ |X| nTVP += X[3]})	// Acumula Valores
	AeVal(aDesc,{ |X| nTVD += X[3]})

	nLIQ := nTVP - nTVD
	DET  := REPLICATE("-",nEsp132)
	IMPR(DET,"C")

	nRefOco := If(cRefOco==2 .And. cSinAna=="S",0,1)	//Determinar o espaco do valor no Provento
	nBasDes := If(nRefOco==0,2,0)	//Determinar o espaco do valor na Base

	DET := STR0054 + If(cSinAna=="A" .Or. cRefOco==1,SPACE(nEsp6+1),SPACE(nEsp6)) + TRANSFORM(nTHP,"999999999.99") + " " + TRANSFORM(nTVP,"@E 999,999,999.99")+;
	SPACE(nEsp20 + nRefOco) + TRANSFORM(nTHD,"999999999.99") + " " + TRANSFORM(nTVD,"@E 999,999,999.99")+;
	SPACE(9) + STR0062 + SPACE(nEsp4-nBasDes) + TRANSFORM(nLIQ,"@E 999,999,999.99")					//"SALARIO LIQ."
	IMPR(DET,"C")

	DET:=REPLICATE("-",nEsp132)
	IMPR(DET,"C")

	If nTipo # 1
		If Val(Substr(Str(nTipo,2),1,1))#9
			Det:=STR0055+			   	Strzero(If(nTipo==2,nCnor,If(nTipo==3.or.nTipo==6.or.nTipo==7,nFnor,If (nTipo==4,nEnor,If (nTipo==8,nDnor,nCnor&cNv)))),7)		//" Sit.Normal: "
			Det+=Space(nEsp0)+STR0068+	Strzero(If(nTipo==2,nCadm,If(nTipo==3.or.nTipo==6.or.nTipo==7,nFadm,If (nTipo==4,nEadm,If (nTipo==8,nDadm,nCadm&cNv)))),7)		//" Admitidos: "
			Det+=Space(nEsp0)+STR0056+	Strzero(If(nTipo==2,nCafa,If(nTipo==3.or.nTipo==6.or.nTipo==7,nFafa,If (nTipo==4,nEafa,If (nTipo==8,nDafa,nCafa&cNv)))),7)		//" Afastados: "
			Det+=Space(nEsp0)+STR0057+	Strzero(If(nTipo==2,nCdem,If(nTipo==3.or.nTipo==6.or.nTipo==7,nFdem,If (nTipo==4,nEdem,If (nTipo==8,nDdem,nCdem&cNv)))),7)		//" Demitidos:"
			Det+=Space(nEsp0)+STR0058+	Strzero(If(nTipo==2,nCfer,If(nTipo==3.or.nTipo==6.or.nTipo==7,nFfer,If (nTipo==4,nEfer,If (nTipo==8,nDfer,nCfer&cNv)))),7)		//" Ferias:"
			Det+=Space(nEsp0)+STR0060+	Strzero(If(nTipo==2,nCexc,If(nTipo==3.or.nTipo==6.or.nTipo==7,nFexc,If (nTipo==4,nEexc,If (nTipo==8,nDexc,nCexc&cNv)))),7)		//" Outros C.Custo:"
			Det+=Space(nEsp0)+STR0061+	Strzero(If(nTipo==2,nCtot,If(nTipo==3.or.nTipo==6.or.nTipo==7,nFtot,If (nTipo==4,nEtot,If (nTipo==8,nDtot,nCtot&cNv)))),8)		//" Total:"

			If nTipo == 3 //Filial
				aTot[1,1] += nFnor
				aTot[1,2] += nFadm
				aTot[1,3] += nFafa
				aTot[1,4] += nFdem
				aTot[1,5] += nFfer
				aTot[1,6] += nFexc
				aTot[1,7] += nFtot
			EndIf
			If nTipo == 6 //Unidade Negocios
				aTot[2,1] += nFnor
				aTot[2,2] += nFadm
				aTot[2,3] += nFafa
				aTot[2,4] += nFdem
				aTot[2,5] += nFfer
				aTot[2,6] += nFexc
				aTot[2,7] += nFtot
			EndIf
			If nTipo == 7 //Empresa
				aTot[3,1] += nFnor
				aTot[3,2] += nFadm
				aTot[3,3] += nFafa
				aTot[3,4] += nFdem
				aTot[3,5] += nFfer
				aTot[3,6] += nFexc
				aTot[3,7] += nFtot
			EndIf
			If nTipo == 4 //Grupo Empresas
				aTot[4,1] += nEnor
				aTot[4,2] += nEadm
				aTot[4,3] += nEafa
				aTot[4,4] += nEdem
				aTot[4,5] += nEfer
				aTot[4,6] += nEexc
				aTot[4,7] += nEtot
			EndIf
		Else
			Det:=STR0055+			  	Strzero(If(nTipo==91,aTot[1,1],If(nTipo==92,aTot[2,1],If (nTipo==93,aTot[3,1],If (nTipo==94,aTot[4,1],aTot[1,1])))),7)		//" Sit.Normal: "
			Det+=Space(nEsp0)+STR0068+	Strzero(If(nTipo==91,aTot[1,2],If(nTipo==92,aTot[2,2],If (nTipo==93,aTot[3,2],If (nTipo==94,aTot[4,2],aTot[1,2])))),7)		//" Admitidos: "
			Det+=Space(nEsp0)+STR0056+	Strzero(If(nTipo==91,aTot[1,3],If(nTipo==92,aTot[2,3],If (nTipo==93,aTot[3,3],If (nTipo==94,aTot[4,3],aTot[1,3])))),7)		//" Afastados: "
			Det+=Space(nEsp0)+STR0057+	Strzero(If(nTipo==91,aTot[1,4],If(nTipo==92,aTot[2,4],If (nTipo==93,aTot[3,4],If (nTipo==94,aTot[4,4],aTot[1,4])))),7)		//" Demitidos:"
			Det+=Space(nEsp0)+STR0058+	Strzero(If(nTipo==91,aTot[1,5],If(nTipo==92,aTot[2,5],If (nTipo==93,aTot[3,5],If (nTipo==94,aTot[4,5],aTot[1,5])))),7)		//" Ferias:"
			Det+=Space(nEsp0)+STR0060+	Strzero(If(nTipo==91,aTot[1,6],If(nTipo==92,aTot[2,6],If (nTipo==93,aTot[3,6],If (nTipo==94,aTot[4,6],aTot[1,6])))),7)		//" Outros C.Custo:"
			Det+=Space(nEsp0)+STR0061+	Strzero(If(nTipo==91,aTot[1,7],If(nTipo==92,aTot[2,7],If (nTipo==93,aTot[3,7],If (nTipo==94,aTot[4,7],aTot[1,7])))),8)		//" Total:"
		EndIf

		Impr (Det,"C")
		IMPR(REPL("=",nEsp132),"C")   // Salta Pagina apos Quebra Cc/Filial/Empresa/Departamento
	    If nTipo # 2 .Or. (nTipo == 2 .And. lSalta) .OR. (nTipo == 8 .And. lSaltaDepto)
			Impr("","P")
		Else
			Impr("","C")
		Endif
	Endif

Return Nil

*-----------------------------------------------*
Static Function  fBuscaFuncRel(dDataDe,cCodFunc, cDescFunc, nTamFunc, cCatFunc, cDescCateg, nTamCateg, lDataRef )
*-----------------------------------------------*

	Local aRecno	:= {}
	Local nPos 		:= 0
	Local lCateg	:= .F.

	DEFAULT lDataRef 	:= .T.

	DEFAULT nTamFunc	:= 20
	DEFAULT nTamCateg   := 25

	//-- Verifica se foi passado o codigo da categoria para buscar a sua descricao
	lCateg				:= (cCatFunc <> NIL)
	DEFAULT cCatFunc	:= ""
	DEFAULT cDescCateg	:= SPACE(nTamCateg)

	If SR7->( dbSeek( ( cSRATmp )->RA_FILIAL+( cSRATmp )->RA_MAT )  )
		While SR7->(!EOF()) .and. If(lDataRef, (MesAno(SR7->R7_DATA)	<= MesAno(dDataDe) ), ( SR7->R7_DATA	<= dDataDe) ) .AND.;
			SR7->R7_FILIAL 	== ( cSRATmp )->RA_FILIAL .AND. ;
			SR7->R7_MAT   	== ( cSRATmp )->RA_MAT
			AADD(aRecno, {DTOS(SR7->R7_DATA), strzero(SR7->(Recno()),10) , SR7->R7_FUNCAO, SR7->R7_DESCFUN, SR7->R7_CATFUNC })
			SR7->(dbSkip())
		EndDo
		If Len(aRecno) > 0
			aSort( aRecno,,,{ |x,y| x[1] + x[2] < y[1] + y[2]  } )
			nPos 		:= Len( aRecno )
			cCodFunc 	:=	aRecno[nPos,3]+ space(1)
			cDescFunc 	:= 	aRecno[nPos,4]									//-- 20 Bytes
			cCatFunc	:= 	aRecno[nPos,5]
		Endif
	Endif

	//-- Se nao encontrou a funcao na data solicitada, assume a do Cadastro de Funcionarios
	If  Empty( Len(aRecno) )
		cCodFunc 	:=	( cSRATmp )->RA_CODFUNC + space(1)
		cDescFunc	:=  LEFT(fDesc("SRJ",( cSRATmp )->RA_CODFUNC,"RJ_DESC",,( cSRATmp )->RA_FILIAL),nTamFunc)
		cCatFunc	:=  ( cSRATmp )->RA_CATFUNC
	Endif

	//-- Se foi passado o Codigo de Categoria, busca a descricao
	cDescCateg	:=   If( lCateg , DescCateg(cCatFunc, nTamCateg, cSRATmp), cDescCateg )						//-- 25 Bytes

Return


*--------------------------------------*
Static Function fSomaNv(aMatriz,cVerba,nHorCc,nValCc,nParCc,nQtdCc)
*--------------------------------------*
	// 1- Matriz onde os dados estao sendo armazenados
	// 2- elemrnto a ser somado

	Local nRet
	nRet := Ascan( aMatriz,{|X| x[1] == cVerba } )   // Testa se ja existe
	If	nRet == 0
		Aadd (aMatriz,{cVerba,nHorCc,nValCc,nParCc,nQtdCc})  // se nao cria elemento
	Else
		aMatriz[nRet,2] += nHorCc                   // se ja so adiciona
		aMatriz[nRet,3] += nValCc
		aMatriz[nRet,4] += nParCc
		aMatriz[nRet,5] += nQtdCc
	Endif
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImpFol   ³ Autor ³ R.H.                  ³ Data ³ 14.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime a folha ou gera o arquivo SRZ.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fImpFol(lEnd,cAnoMesRef)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpFol(lEnd,cAnoMesRef,cArqSRC)
	Local lInssFun    := .F.
	Local aFunP       := {}
	Local aFunD   	  := {}
	Local aFunB   	  := {}
	Local aCodBenef   := {}
	Local cBuscaSRA   := ""
	Local cBuscaSRI   := ""
	Local cAcessaSRA  := &("{ || " + ChkRH("GPER040","SRA","2") + "}")
	Local cAcessaSRC  := &("{ || " + ChkRH("GPER040","SRC","2") + "}")
	Local cAcessaSRI  := &("{ || " + ChkRH("GPER040","SRI","2") + "}")

	Local cAcessaRHH  := &("{ || " + ChkRH("GPER040","RHH","2") + "}")

	Local cTipAfas    := " "
	Local dDtAfas
	Local dDtRet
	Local dDtPesqAf
	Local lCotFun	  := .F.
	Local lFuncAtivo  := .F.
	Local nx		  := 0
	Local nCpoQry	  := 0
	Local lTodosSRA  := .F.
	Local nPosItem
	Local nPosClvl
	Local nPosM		  := 0
	Local cAcessaArq  := ChkRH("GPER040","SRA","2")
	Local lTodosCpos  := !(cAcessaArq==".T.")
	Local lGerar	  := .F.
	Local lGetSRG	  := .F.
	Local lRatDes 	  := SuperGetMv( "MV_RAT0973", .F., .F. )
	Local dDtIni	:= Ctod("//")

	Local cMainCpos	:= ""
	Local cSRACpos	:= ""
	Local cSRCCpos	:= ""
	Local cSRICpos	:= ""
	Local cRHHCpos	:= ""
	Local cQuery	:= ""
	local cSelSRA	:= ""
	Local cWhere	:= ""
	Local cAcess	:= ""
	Local cMainOrd	:= ""
	Local cSeekFil	:= ""
	Local cSeekMat	:= ""
	Local nUltDia	:= ""
	Local aSRAStru	:= {}
	Local aRHHStru	:= {}
	Local dDtLim	:= Ctod("//")


	Private lResExt		:= .F.
	Private lProLab		:= .F.
	Private aGPSVal 	:= {}
	Private aGPSPer 	:= {} // Carrega os percentuais de terceiros do parametro 15
	Private aMatExt		:= {} // bases para funcionários expatriados
	Private aMatProLab	:= {} // bases para Pro-labore
	Private cMainTmp	:= ""
	Private cSRATmp		:= "SRA"
	Private cSRCTmp		:= "SRC"
	Private cSRITmp		:= "SRI"
	Private cRHHTmp		:= "RHH"

	dbSelectArea( "SRA" )

	aSRAStru	:= SRA->( dbStruct() ) // Monta estrutura do SRA

	nFilSRA		:= aScan( aSRAStru, { |x| x[1] == "RA_FILIAL" } )
	nCcSRA		:= aScan( aSRAStru, { |x| x[1] == "RA_CC" 	} )
	nMatSRA		:= aScan( aSRAStru, { |x| x[1] == "RA_MAT" } )
	nNomeSRA	:= aScan( aSRAStru, { |x| x[1] == "RA_NOME" } )

	dbSelectArea( "RHH" )
	aRHHStru	:= RHH->( dbStruct() )	// Monta estrutura do RHH
	nFilRHH		:= aScan( aRHHStru, { |x| x[1] == "RHH_FILIAL"	} )
	nMatRHH		:= aScan( aRHHStru, { |x| x[1] == "RHH_MAT"		} )
	nPdRHH		:= aScan( aRHHStru, { |x| x[1] == "RHH_VERBA"	} )
	nCcRHH		:= aScan( aRHHStru, { |x| x[1] == "RHH_CC"		} )


	If Type( "cRelFil" ) == "U"
		cRelFil := ""
	EndIf

	If (!Empty( cRelFil ) .or. lTodosCpos)
		lTodosSRA  := .T.
	Endif

	If Type( "cDeptoDe" ) == "U"
		cDeptoDe  := Replicate(' ', TamSX3('RA_DEPTO')[1] )
		cDeptoAte := Replicate('Z', TamSX3('RA_DEPTO')[1] )
	EndIf

	dbSelectArea( "SRA" )
	dbGoTop()

	If nOrdem == 1  //Centro Custo

		dbSetOrder( 2 )
		dbSeek(cFilDe + cCcDe + cMatDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
		cFim     := cFilAte + cCcAte + cMatAte

		If lTodosSRA
			cMainOrd := AllTrim( Str(nFilSRA))+","+AllTrim(Str(nCcSRA))+","+AllTrim(Str(nMatSRA))
		Else
			cMainOrd := "1,2,3"
		EndIf

	ElseIf nOrdem == 2   // Matricula

		dbSetOrder( 1 )
		dbSeek(cFilDe + cMatDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_MAT"
		cFim     := cFilAte + cMatAte

		If lTodosSRA
			cMainOrd := AllTrim( Str(nFilSRA))+","+AllTrim(Str(nMatSRA))
		Else
			cMainOrd := "1,3"
		EndIf

	ElseIf nOrdem == 3 //Nome

		dbSetOrder( 3 )
		dbSeek(cFilDe + cNomDe + cMatDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
		cFim     := cFilAte + cNomAte + cMatAte

		If lTodosSRA
			cMainOrd := AllTrim( Str(nFilSRA))+","+AllTrim(Str(nNomeSRA))+","+AllTrim(Str(nMatSRA))
		Else
			cMainOrd := "1,4,3"
		EndIf

	ElseIf nOrdem == 4 // C.Custo Movimento

		dbSelectArea( "RHH" )
		dbSetOrder( 4 )			// RHH_FILIAL + RHH_MESANO + RHH_CC + RHH_MAT + RHH_DATA + RHH_VB + RHH_ITEM + RHH_CLVL
		dbSeek( cFilDe + cAnoMesRef + cCcDe + cMatDe, .T. )
		cInicio  := "RHH->RHH_FILIAL + RHH->RHH_MESANO + RHH->RHH_CC + RHH->RHH_MAT"
		cFim     := cFilAte + cAnoMesRef + cCcAte + cMatAte

		// Independente da ordem dos campos nas tabelas de acordo com os parametros do relatorio, o ORDER BY
		// para C.C. Movto sempre sera 1, 2, 3, pois a montagem da QUERY  e UNION foi feita de maneira FIXA
		// para nao correr riscos na ordem dos campos das tabelas que podem ser modificadas pelo usuario.

		cMainOrd := "1,2,3"

	ElseIf nOrdem == 5  //Centro Custo + Nome

		dbSetOrder( 8 )
		dbSeek(cFilDe + cCcDe + cNomDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_NOME"
		cFim     := cFilAte + cCcAte + cNomAte

		If lTodosSRA
			cMainOrd := AllTrim( Str(nFilSRA))+","+AllTrim(Str(nCcSRA))+","+AllTrim(Str(nNomeSRA))
		Else
			cMainOrd := "1,2,4"
		EndIf

	ElseIf nOrdem == 7 //Centro Custo + item + classe

		nPosItem :=  aScan( aSRAStru, { |x| x[1] == "RA_ITEM" } )
		nPosClvl :=  aScan( aSRAStru, { |x| x[1] == "RA_CLVL" } )

		dbSelectarea( "RHH" )
		dbSetOrder( 4 )			// RHH_FILIAL + RHH_MESANO + RHH_CC + RHH_ITEM + RHH_CLVL +RHH_MAT + RHH_DATA + RHH_VB
		dbSeek( cFilDe + cAnoMesRef + cCcDe + Space( TamSX3('RI_ITEM')[1] ) + Space( TamSX3('RI_CLVL')[1] ) + cMatDe, .T. )
		cInicio	:= "RHH->RHH_FILIAL + RHH->RHH_MESANO + RHH->RHH_CC + RHH->RHH_ITEM + RHH->RHH_CLVL +RHH->RHH_MAT"
		cFim	:= cFilAte +  cAnoMesRef + cCcAte + Replicate('Z', TamSX3('RHH_ITEM')[1] ) + Replicate('Z', TamSX3('RHH_CLVL')[1] ) + cMatAte

		If lTodosSRA
			cMainOrd := AllTrim( Str(nFilSRA))+","+AllTrim(Str(nCcSRA))+","+ AllTrim(str(nPosItem ) ) + "," + AllTrim(str(nPosclvl ) ) +","+AllTrim(Str(nMatSRA)) //Filial, Centro Custo, Item, Classe, Matricula
		Else
			cMainOrd := "1,2,20,21,3"
		EndIf

	ElseIf nOrdem == 6 //Departamento

		cInicio  := "RA_FILIAL + RA_DEPTO"
		cFim     := cDeptoDe + cDeptoAte

		If lTodosSRA
			cMainOrd := "RA_FILIAL, RA_DEPTO" //AllTrim( Str(nFilSRA))+","+AllTrim(Str(nNomeSRA))+","+AllTrim(Str(nMatSRA))
		Else
			cMainOrd := "RA_DEPTO"
		EndIf

	Endif

	dbSelectArea( "SRA" )

	cAliasTMP := "QNRO"
	BeginSql alias cAliasTMP
		SELECT COUNT(*) as NROREG
		FROM %table:SRA% SRA
		WHERE      SRA.RA_FILIAL BETWEEN %exp:cFilDe% AND %exp:cFilAte%
		AND SRA.RA_MAT    BETWEEN %exp:cMatDe% AND %exp:cMatAte%
		AND SRA.RA_CC     BETWEEN %exp:cCCDe%  AND %exp:cCCAte%
        AND SRA.RA_DEPTO  BETWEEN %exp:cDeptoDe%  AND %exp:cDeptoAte%
		AND SRA.%notDel%
	EndSql

	nRegProc := (cAliasTMP)->(NROREG)
	( cAliasTMP )->( dbCloseArea() )


	SetRegua(nRegProc)


	cFilAnterior := Space(FWGETTAMFILIAL)
	cCcAnt  	 := Space(09)

	nEnor := nEafa := nEdem := nEfer := nEexc := nEtot := nEadm := 0	// Totalizadores Empresa
	nFnor := nFafa := nFdem := nFfer := nFexc := nFtot := nFadm := 0	//               Filial
	nCnor := nCafa := nCdem := nCfer := nCexc := nCtot := nCadm := 0	//               Centro Custo
	nDnor := nDafa := nDdem := nDfer := nDexc := nDtot := nDadm := 0	//               Departamento
	nCinss := nFinss := nEinss := nDinss := 0							// Totalizador dos func. con ret. Inss

	nFuncs    := 0
	aFuncsBSE :=	{}

	dDtIni	:= Ctod( "01/" + Right( cAnoMesRef, 2 ) + "/" + Left( cAnoMesRef, 4 ), "DDMMYY" )

	If lTodosSRA  //Caso utilize filtro, excluir do select os campos tipo MEMO ("M")
		For nx:= 1 to len(aSRAStru)
			If aSRAStru[nx,2] # "M"
				If nx == 1
					cSRACpos += aSRAStru[nx,1]
				else
					cSRACpos += "," + aSRAStru[nx,1]
				EndIf

			EndIf
		Next nx
	EndIf

	dbselectArea( "RHH" )

	aEval( aRHHStru, { |x| cRHHCpos += x[1] + ", " } ) // Inclui campos do RHH
	cRHHCpos += "RV_TIPOCOD "

	nUltDia	:= f_UltDia( CTOD( "01/" + Right( cAnoMesRef, 2 ) + "/" + Left( cAnoMesRef, 4 ), "DDMMYY" ) )
	dDtLim	:= Ctod( StrZero( nUltDia, 2 ) + "/" + Right( cAnoMesRef, 2 ) + "/" + Left( cAnoMesRef, 4 ), "DDMMYY" )

	cMainTmp	:= GetNextAlias()
	cSRATmp	:= cMainTmp

	If nOrdem # 4 .And. nOrdem # 7
		If lTodosSRA
			cSelSRA := " SELECT " + cSRACpos
		Else
			cSelSRA := " SELECT RA_FILIAL, RA_CC,RA_MAT, RA_NOME, RA_ADMISSA, RA_CATFUNC, RA_SALARIO, RA_DEPIR, "
			cSelSRA += "RA_DEPSF, RA_PERCADT, RA_HRSMES, RA_DEMISSA,RA_TPCONTR, "
			cSelSRA += If( Type("SRA->RA_NOMECOM") # "U", "RA_NOMECOM", "' ' AS RA_NOMECOM" ) + ", RA_CODFUNC"
			cSelSRA += ", RA_PERCSAT, " + Iif( Type("SRA->RA_RESEXT") # "U", "RA_RESEXT", "' ' AS RA_RESEXT" )
			cSelSRA += ", RA_DEPTO "
		Endif

		If lItemClVl .and. !lTodosSRA
			cSelSRA += ", RA_ITEM, RA_CLVL "
		Endif

		cQuery := cSelSRA
		cQuery += " FROM " + RetSqlName("SRA") + " SRA "
		cQuery += "WHERE	SRA.RA_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte	+ "' AND "
		cQuery += "			SRA.RA_MAT    BETWEEN '" + cMatDe + "' AND '" + cMatAte	+ "' AND "
		cQuery += "			SRA.RA_CC     BETWEEN '" + cCcDe  + "' AND '" + cCcAte	+ "' AND "
		cQuery += "			SRA.RA_DEPTO  BETWEEN '" + cDeptoDe  + "' AND '" + cDeptoAte	+ "' AND "
		cQuery += "       EXISTS( SELECT RHH_MAT FROM " + cArqSRC + " RHH "
    	cQuery += "                WHERE RHH.RHH_FILIAL = SRA.RA_FILIAL "
    	cQuery += "                  AND RHH.RHH_MAT = SRA.RA_MAT "

    	If !( Empty(Semana) )
    		cQuery += "              AND RHH.RHH_SEMANA = '" + Semana + "' "
		EndIf

		cQuery += "                  AND RHH.D_E_L_E_T_ = ' ' ) AND "

		cQuery += " SRA.D_E_L_E_T_ = ' ' "

		cQuery += " UNION "
		cQuery += cSelSRA
		cQuery += " FROM " +  RetSqlName("SR8") + " SR8, " + RetSqlName("SRA") + " SRA "
		cQuery += "WHERE SR8.R8_FILIAL = SRA.RA_FILIAL AND "
		cQuery += "SR8.R8_MAT = SRA.RA_MAT AND "
		cQuery += "SRA.RA_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte	+ "' AND "
		cQuery += "SRA.RA_MAT    BETWEEN '" + cMatDe + "' AND '" + cMatAte	+ "' AND "
		cQuery += "SRA.RA_CC     BETWEEN '" + cCcDe  + "' AND '" + cCcAte	+ "' AND "
	    cQuery += "SRA.RA_DEPTO  BETWEEN '" + cDeptoDe  + "' AND '" + cDeptoAte	+ "' AND "
		cQuery += "(R8_DATAINI <= '" + DtoS(dDtLim) + "' AND (R8_DATAFIM >= '" + DtoS(dDtIni) + "' OR R8_DATAFIM = '" + Space(Len(DtoS(SR8->R8_DATAINI))) + "') ) AND "

		cQuery += "SR8.D_E_L_E_T_ = ' ' AND "
		cQuery += "SRA.D_E_L_E_T_ = ' ' "

		cQuery += "ORDER BY " + cMainOrd
	Else
		// Query para impressao da Folha de Dissidio
		cQuery := " SELECT DISTINCT "
		cQuery += "RHH_FILIAL, RHH_CC, RHH_MAT, "

		If lTodosSRA	//Todos campos SRA
			cQuery += cSRACpos
		Else
			cQuery += "SRA.RA_NOME, SRA.RA_ADMISSA, SRA.RA_CATFUNC, SRA.RA_SALARIO, SRA.RA_DEPIR,  "
			cQuery += "SRA.RA_DEPSF, SRA.RA_PERCADT, SRA.RA_HRSMES, SRA.RA_DEMISSA, SRA.RA_TPCONTR, "
			cQuery += If( Type("SRA->RA_NOMECOM") # "U", "SRA.RA_NOMECOM,","' ' AS RA_NOMECOM,")+ " SRA.RA_CODFUNC"
			cQuery += ", SRA.RA_PERCSAT, SRA.RA_FILIAL, SRA.RA_CC, SRA.RA_MAT "
		EndIf

		If nOrdem == 7
			cQuery += ", RHH_ITEM, RHH_CLVL "
		Endif

	    If lItemClVl .and. !lTodosSRA
			cQuery += ", SRA.RA_ITEM, SRA.RA_CLVL "
		Endif

		cQuery += ", SRA.RA_DEPTO "

		cQuery += " FROM " + cArqSRC + " RHH, " + RetSqlName("SRA") + " SRA "
		cQuery += "WHERE RHH.RHH_FILIAL = SRA.RA_FILIAL AND RHH.RHH_MAT = SRA.RA_MAT "
		cQuery += "  AND RHH.RHH_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
		cQuery += "  AND RHH.RHH_MAT    BETWEEN '" + cMatDe + "' AND '" + cMatAte + "' "
		cQuery += "  AND RHH.RHH_CC     BETWEEN '" + cCcDe  + "' AND '" + cCcAte  + "' "

		If !( Empty(Semana) )
			cQuery += "  AND RHH.RHH_SEMANA = '" + Semana + "' "
		EndIf

		cQuery += "  AND SRA.RA_DEPTO   BETWEEN '" + cDeptoDe  + "' AND '" + cDeptoAte	+ "' "
		cQuery += "  AND RHH.D_E_L_E_T_ = ' ' "
		cQuery += "  AND SRA.D_E_L_E_T_ = ' ' "

		cQuery += " UNION "

		If lTodosSRA  //Todos campos do SRA
			cQuery += " SELECT SRA.RA_FILIAL AS RHH_FILIAL, SRA.RA_CC AS RHH_CC, SRA.RA_MAT AS RHH_MAT, "
			cQuery += cSRACpos
		Else
			cQuery += " SELECT RA_FILIAL AS RHH_FILIAL, RA_CC AS RHH_CC, RA_MAT AS RHH_MAT, "
			cQuery += "SRA.RA_NOME, SRA.RA_ADMISSA, SRA.RA_CATFUNC, SRA.RA_SALARIO, SRA.RA_DEPIR, "
			cQuery += "SRA.RA_DEPSF, SRA.RA_PERCADT, SRA.RA_HRSMES, SRA.RA_DEMISSA, SRA.RA_TPCONTR, "
			cQuery += If(Type("SRA->RA_NOMECOM") # "U" ,"SRA.RA_NOMECOM,","' ' AS RA_NOMECOM,")+ " SRA.RA_CODFUNC"
			cQuery += ", SRA.RA_PERCSAT, SRA.RA_FILIAL, SRA.RA_CC, SRA.RA_MAT "
		EndIf

		If nOrdem == 7
			cQuery += ", SRA.RA_ITEM AS RHH_ITEM, SRA.RA_CLVL AS RHH_CLVL "
		Endif

	    If lItemClVl .and. !lTodosSRA
	    	cQuery += ", SRA.RA_ITEM, SRA.RA_CLVL "
		Endif

		cQuery += ", SRA.RA_DEPTO "

		cQuery += " FROM " +  RetSqlName("SR8") + " SR8, " + RetSqlName("SRA") + " SRA "
		cQuery += "WHERE SR8.R8_FILIAL = SRA.RA_FILIAL "
		cQuery += "  AND SR8.R8_MAT = SRA.RA_MAT "
		cQuery += "  AND SRA.RA_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
		cQuery += "  AND SRA.RA_MAT    BETWEEN '" + cMatDe + "' AND '" + cMatAte + "' "
		cQuery += "  AND SRA.RA_CC     BETWEEN '" + cCcDe  + "' AND '" + cCcAte  + "' "
		cQuery += "  AND SRA.RA_DEPTO  BETWEEN '" + cDeptoDe  + "' AND '" + cDeptoAte	+ "' "
		cQuery += "  AND (R8_DATAINI <= '" + DtoS(dDtLim) + "' AND (R8_DATAFIM >= '" + DtoS(dDtIni) + "' OR R8_DATAFIM = '" + Space(Len(DtoS(SR8->R8_DATAINI))) + "') ) "
		cQuery += "  AND SR8.D_E_L_E_T_ = ' ' "
		cQuery += "  AND SRA.D_E_L_E_T_ = ' ' AND "

		cQuery += "NOT EXISTS( SELECT RHH_MAT "
		cQuery += "              FROM " +  cArqSRC + " RHH "
		cQuery += "             WHERE RHH.RHH_FILIAL = SRA.RA_FILIAL "
		cQuery += "               AND RHH.RHH_MAT = SRA.RA_MAT "
		cQuery += "               AND SRA.D_E_L_E_T_ = ' ' "
		cQuery += "               AND RHH.D_E_L_E_T_ = ' ' ) "

		cQuery += "ORDER BY " + cMainOrd
	Endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cMainTmp, .F., .T.)

	For nX := 1 To Len(aSRAStru)
		If aSRAStru[nX][2]<>"C"
			TcSetField(cMainTmp,aSRAStru[nX][1],aSRAStru[nX][2],aSRAStru[nX][3],aSRAStru[nX][4])
		EndIf
	Next nX

	dbSelectArea( cMainTmp )

	cDeptoAnterior := ( cMainTmp )->RA_DEPTO

	While !( cMainTmp )->( Eof() )

		IncRegua()

		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restauracao do alias principal nas ordens 4 ou 6             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOrdem == 4 .Or. nOrdem == 7
			cSRATmp := cMainTmp
		EndIf

		If nOrdem == 4 // Encargos por C.Custo
			cItCt := " "
			cClVl := " "

			dbSelectArea( "SRA" )
			dbSetOrder( 1 )

			dbSeek( ( cMainTmp )->RHH_FILIAL + ( cMainTmp )->RHH_MAT )
			cCcto :=  ( cMainTmp )->RHH_CC

			If Eof() // Nao encontrou funcionario para o lancamento que esta posicionado
				cCcto := " "
				dbSelectArea( cMainTmp )
				( cMainTmp )->( dbSkip() )

				fTestaTotal()
				Loop
			Endif

		ElseIf nOrdem == 7      // Encargos por C.Custo + Item + Classe

			dbSelectArea( "SRA" )
			dbSetOrder(1)

			dbSeek( ( cMainTmp )->RHH_FILIAL + ( cMainTmp )->RHH_MAT )
			cCcto :=  ( cMainTmp )->RHH_CC
			cItCt :=  ( cMainTmp )->RHH_ITEM
			cClVl :=  ( cMainTmp )->RHH_CLVL

			If Eof() // Nao encontrou funcionario para o lancamento que esta posicionado
				cCcto := " "
				cItCt := " "
				cClVl := " "
				dbSelectArea( cMainTmp )
				( cMainTmp )->( dbSkip() )

				fTestaTotal()
				Loop
			Endif
		Else
			cCcto :=  ( cMainTmp )->RA_CC
			cItCt :=  ' '
			cClVl :=  ' '
		Endif

		If ( cSRATmp )->( FieldPos( "RA_RESEXT" )) # 0
			lResExt := If(( cSRATmp )->RA_RESEXT == "1", .T., .F. )
		EndIf

		lProLab := If(( cSRATmp )->RA_CATFUNC == "P", .T., .F. )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Quebra de Filial                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( cSRATmp )->RA_FILIAL # cFilAnterior

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Resgata Valores utilizados na GPS que estao armazenados no Parametro 15 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fGPSVal(( cSRATmp )->RA_FILIAL,  cAnoMesRef , @aGPSVal, cTpC )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Resgata os percentuais de terceiros armazenados no parametro 15			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fGPSVal(( cSRATmp )->RA_FILIAL,"999999",@aGPSPer,cTpC)

			If cFilAnterior # Space(FWGETTAMFILIAL) .And. ( nOrdem == 4 .or. nOrdem == 7 )
				If lCorpManage
					If lEmpFil
						cEmpFil := ""
					EndIf
					If lUniNeg
						cUniNeg := ""
					EndIf
				EndIf
				fImpFil()    // Totaliza Filial
			Endif
			If !FP_CODFOL(@aCodFol,( cSRATmp )->RA_FILIAL) .Or. !fInfo(@aInfo,( cSRATmp )->RA_FILIAL)
				Exit
			Endif
			If cFilAnterior # Space(FWGETTAMFILIAL) .And. ( nOrdem # 4 .AND. nOrdem # 7 )
				If lCorpManage
					If lEmpFil
						cEmpFil := ""
					EndIf
					If lUniNeg
						cUniNeg := ""
					EndIf
				EndIf
				fImpFil()    // Totaliza Filial
			Endif

			cFilAnterior := ( cSRATmp )->RA_FILIAL

			cContribuicao := aCodFol[013,1]+"x"+aCodFol[014,1]+"x"+aCodFol[19,1]+"x"+aCodFol[20,1] //+"x"+aCodFol[338,1]+"x"+aCodFol[399,1]
			cContrProAuto := aCodFol[217,1]+"x"+aCodFol[218,1]+"x"+aCodFol[349,1]+"x"+aCodFol[352,1]
			If Len(aCodFol) > 1412
				cContrProAuto += "x"+aCodFol[1413,1]
			Endif
			If Len(aCodFol) >= 1430
				cContrProAuto += "x"+aCodFol[1430,1]+"x"+aCodFol[1431,1]
			EndIf
			If Len(aCodFol) >= 1448
				cContrProAuto += "x"+aCodFol[1448,1]
			EndIf
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste Parametrizacao do Intervalo de Impressao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( FtAcento(( cSRATmp )->RA_NOME) < cNomDe ) .Or. ( FtAcento(( cSRATmp )->RA_NOME) > cNomAte ) .Or. ;
		   ( ( cSRATmp )->RA_MAT < cMatDe )  .Or. ( ( cSRATmp )->RA_MAT > cMatAte )

			If nOrdem == 4 .Or. nOrdem == 7 // Ordem do Arquivo Movimento "SRC"
				dbSelectArea( cMainTmp )
				( cMainTmp )->( dbSkip() )
			Endif

			fTestaTotal()
			Loop
		Endif

		If (( nOrdem  # 4 .And. nOrdem  # 7 ) .And. ((( cMainTmp )->RA_CC < cCcDe) .Or. (( cMainTmp )->RA_CC > cCcAte))) .Or.;
		   (( nOrdem == 4 .Or. nOrdem == 7 ) .And. ((( cMainTmp )->RHH_CC < cCcDe) .Or. (( cMainTmp )->RHH_CC > cCcAte)))
			If nOrdem == 4 .Or. nOrdem == 7  // Ordem do Arquivo Movto.
				dbSelectArea( cMainTmp )
				( cMainTmp )->( dbSkip() )
			Endif

			fTestaTotal()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o tipo de Afastamentono mes que esta sendo listado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTipAfas	:= " "
		dDtAfas		:= dDtRet := ctod("")
		dDtPesqAf	:= CTOD("01/" + Right(cAnoMesRef,2) + "/" + Left(cAnoMesRef,4),"DDMMYY")

	    //-- Verifica se o funcionario eh ativo para a empresa+filial
	    lFuncAtivo := fFuncAtivo(( cSRATmp )->RA_FILIAL,( cSRATmp )->RA_MAT  ,( cSRATmp )->(RA_ADMISSA), dDtPesqAf)

		fChkAfas(( cSRATmp )->RA_FILIAL, ( cSRATmp )->RA_MAT, dDtPesqAf, @dDtAfas, @dDtRet, @cTipAfas )

		If cTipAfas $"HIJKLMNSU234" .Or. ( !Empty(( cSRATmp )->RA_DEMISSA) .And. MesAno(( cSRATmp )->RA_DEMISSA) <= MesAno(dDtPesqAf))
			cTipAfas := "D"
		Elseif cTipAfas $"OPQRXYV8W1D"
			cTipAfas := "A"
		ElseIf cTipAfas == "F"
			cTipAfas := "F"
		Else
			cTipAfas := " "
		EndIf

		If MesAno(dDtAfas) > MesAno(dDtPesqAf)
			cTipAfas := " "
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Situacao e Categoria do Funcionario                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	!(cTipAfas $ cSit) .Or. !(( cSRATmp )->RA_CATFUNC $ cCat) .Or. !fChkTpCon(( cSRATmp )->RA_TPCONTR,cTpC1,dDtIni)
			If nOrdem == 4 .Or. nOrdem == 7 // Ordem do Arquivo Movto.
				dbSelectArea( cMainTmp )
				( cMainTmp )->( dbSkip() )
			Endif

			fTestaTotal()
			Loop
		EndIf

		cAcessaSRA := GetCBSource( cAcessaSRA )
		cAcessaSRA := StrTran( cAcessaSRA, "SRA->","( cSRATmp )->")
		cAcessaSRA := 	bChkSRE := &( cAcessaSRA )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste controle de acessos e filiais validas				 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( !(( cSRATmp )->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA) );
			.Or.;
			( !Empty( cRelFil ) .And. !(( cSRATmp )->&( cRelFil ) ) )

			If nOrdem == 4 .Or. nOrdem == 7   // Ordem do Arquivo Movto.
				dbSelectArea( cMainTmp )
				( cMainTmp )->( dbSkip() )
			Endif

			fTestaTotal()
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se e Adiantamento e Folha                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		lInssFun := .F.

		dbSelectArea( "RHH" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se ordem for por CC do Movimento, imprimir baseado na chave  ³
		//³ de busca do RHH, caso contrario na chave de busca do SRA.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOrdem == 4 .Or. nOrdem == 7
			cBuscaSRA := RHH->RHH_FILIAL + RHH->RHH_CC + RHH->RHH_MAT
			cBuscaRHH := "RHH->RHH_FILIAL + RHH->RHH_CC + RHH->RHH_MAT"

			cSeekFil  := ( cMainTmp )->RHH_FILIAL
			cSeekMat  := ( cMainTmp )->RHH_MAT
		Else
			cBuscaSRA := SRA->RA_FILIAL + SRA->RA_MAT
			cBuscaRHH := "RHH->RHH_FILIAL + RHH->RHH_MAT"

			cSeekFil  := ( cMainTmp )->RA_FILIAL
			cSeekMat  := ( cMainTmp )->RA_MAT
		EndIf

		cRHHTmp	:= GetNextAlias()

		cQuery := " SELECT " + cRHHCpos + " "
		cQuery += " FROM " + cArqSRC	+ " RHHQ, "	+ RetSQLName("SRV") + " SRVQ "
		cQuery += " WHERE	RHHQ.RHH_FILIAL	= '" + cSeekFil 		+ "' AND "
		cQuery += " 		RHHQ.RHH_MAT	= '" + cSeekMat 		+ "' AND "
		cQuery += " 		RHHQ.RHH_MESANO 	= '" + cAnoMesRef 		+ "' AND "
		cQuery += "			SRVQ.RV_FILIAL	= '" + xFilial("SRV", cSeekFil) + "' AND "
		cQuery += "			SRVQ.RV_COD		=	RHHQ.RHH_VERBA AND "

		If ! Empty( cWhere )
			cQuery += cWhere + " AND "
		EndIf

		cQuery += " 		SRVQ.D_E_L_E_T_	= ' ' AND "
		cQuery += " 		RHHQ.D_E_L_E_T_	= ' ' "

		If nOrdem == 4 .Or. nOrdem == 7
			cQuery += " ORDER BY " + Alltrim( Str( nFilRHH ) + "," + Str( nMatRHH ) + "," + Str( nPdRHH ) )
		Else
			cQuery += " ORDER BY " + Alltrim( Str( nFilRHH ) + "," + Str( nCcRHH ) + "," + Str( nMatRHH ) + "," + Str( nPdRHH ) )
		EndIf

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cRHHTmp )

		//-- Ajusta a estrutura dos campos
		For nCpoQry := 1 To Len( aRHHStru )
			If ( aRHHStru[nCpoQry][2] <> "C" )
				TcSetField( cRHHTmp, aRHHStru[nCpoQry][1], aRHHStru[nCpoQry][2], aRHHStru[nCpoQry][3], aRHHStru[nCpoQry][4] )
			EndIf
		Next nCpoQry

		While !( cRHHTmp )->( Eof() )

			 cAcessaRHH := GetCBSource( cAcessaRHH )
			 cAcessaRHH	:= StrTran( cAcessaRHH, "RHH->","( cRHHTmp )->" )
			 cAcessaRHH := bChkSRE := &( cAcessaRHH )

			If ! Eval( cAcessaRHH )
				dbSelectArea( cRHHTmp )
				( cRHHTmp )->( dbSkip() )
				Loop
			EndIf

			If ( cRHHTmp )->RV_TIPOCOD == "1"	//Eval( bRHH1 )
				fSoma( @aFunP, "I" )
				fSoma( @aCcP , "I" )
				fSoma( @aFilP, "I" )
				fSoma( @aEmpP, "I" )
                fSoma( @aDeptoP, "I" )

			ElseIf ( cRHHTmp )->RV_TIPOCOD == "2"	//Eval( bRHH2 )
				fSoma( @aFunD, "I" )
				fSoma( @aCcD , "I" )
				fSoma( @aFilD, "I" )
				fSoma( @aEmpD, "I" )
                fSoma( @aDeptoD, "I" )

				//--Verifica se Funcionario teve Retencao de Inss
				If ( cRHHTmp )->RHH_VERBA $ aCodFol[070,1]
					lInssFun := .T.
				Endif

			ElseIf ( cRHHTmp )->RV_TIPOCOD == "3"	//Eval( bRHH3 )
				fSoma( @aFunB, "I" )
				fSoma( @aCcB , "I" )
				fSoma( @aFilB, "I" )
				fSoma( @aEmpB, "I" )
                fSoma( @aDeptoB, "I" )
			Endif

			( cRHHTmp )->( dbSkip() )
		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nas ordens 4 e 6 em ambiente TOP, como o o SRA eh unificado  ³
		//³ ao SRI/SRC, neste ponto efetuamos um skip no alias principal ³
		//³ para posicionar no proximo lancamento e utilizamos o SRA real³
		//³ posicionado para buscar os dados dos funcionarios.           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( nOrdem == 4 .Or. nOrdem == 7 )
			( cMainTmp )->( dbSkip() )
			cSRATmp := "SRA"
		EndIf

		lGetSRG := fLoadRecSRG( ( cSRATmp )->RA_FILIAL, ( cSRATmp )->RA_MAT, dDtPesqAf )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao considera funcionarios admitidos apos o periodo do movimento ³
		//³ e nem os demitidos anterior ao periodo.						     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( MesAno(( cSRATmp )->RA_ADMISSA) <= MesAno(dDtPesqAf) .and. (Empty(( cSRATmp )->RA_DEMISSA) ) .or. ;
		   ( MesAno(( cSRATmp )->RA_DEMISSA) >= MesAno(dDtPesqAf) .Or. lGetSRG ))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somente considera os acumulados de situacao de funcioario para:    ³
			//³ Funcionario considerado ativo para Empresa+Filial  ou              ³
			//³ Funcionario nao ativo mas que possue movimento                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF lFuncAtivo .OR. ( ! lFuncAtivo .and. !( Len(aFunP) == 0 .And. Len(aFunD) == 0 .And. Len(aFunB) == 0 ) )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Somatorias de Situacoes dos Funcionarios                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( cSRATmp )->RA_CC = cCcto
					If lInssFun
						nEinss ++ ; nFinss++ ; nCinss ++ ; nDinss ++ //-- Total de Func. Ret. Inss
					Endif

					If mesano(( cSRATmp )->RA_ADMISSA) = MesAno(dDtPesqAf)
						nEadm ++ ; nFadm ++ ; nCadm ++  //-- Total Admitidos
						//	nEtot ++ ; nFtot ++ ; nCtot ++  //-- Total de Funcionarios
					Endif

					If cTipAfas == " "
						nEnor ++ ; nFnor ++ ; nCnor ++ ; nDnor ++  //-- Total Situacao Normal
						nEtot ++ ; nFtot ++ ; nCtot ++ ; nDtot ++  //-- Total de Funcionarios
					Elseif cTipAfas == "A"
						nEafa ++ ; nFafa ++ ; nCafa ++ ; nDafa ++ //-- Total Afastados
						nEtot ++ ; nFtot ++ ; nCtot ++ ; nDtot ++  //-- Total de Funcionarios
					Elseif cTipAfas == "D"
						If Len(aFunP) > 0 .Or. Len(aFunD) > 0 .Or. Len(aFunB) > 0
							nEdem ++ ; nFdem ++ ; nCdem ++ ; nDdem ++ // Demitidos
							nEtot ++ ; nFtot ++ ; nCtot ++ ; nDtot ++ // Total de Funcionarios
						Endif
					Elseif cTipAfas == "F"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Procura No Arquivo de Ferias o Periodo a Ser Listado         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea( "SRH" )
						If dbSeek( ( cSRATmp )->RA_FILIAL + ( cSRATmp )->RA_MAT )
							While !Eof() .And. ( cSRATmp )->RA_FILIAL + ( cSRATmp )->RA_MAT == SRH->RH_FILIAL + SRH->RH_MAT
								dbSkip()
							Enddo
							dbSkip(-1)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica Se Esta Dentro Das Datas Selecionadas               ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If MesAno(SRH->RH_DATAINI) > cAnoMesRef
								nEnor ++ ; nFnor ++ ; nCnor ++ ; nDnor ++ //-- Total Situacao Normal
							Else
								nEfer ++ ; nFfer ++ ; nCfer ++ ; nDfer ++ //-- Ferias
							Endif
							nEtot ++ ; nFtot ++ ; nCtot ++ ; nDtot ++ //-- Total de Funcionarios
						Endif
						dbSelectArea( "SRA" )
					Endif
				Else
					If lInssFun
						nCinss ++
					Endif
					nEexc ++ ; nFexc ++ ; nCexc ++ ; nDexc ++ //-- Outro C.Custo
					nEtot ++ ; nFtot ++ ; nCtot ++ ; nDtot ++ //-- Outro C.Custo
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Testa Verbas de Provento / Descontos / Base                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If	Len(aFunP) == 0 .And. Len(aFunD) == 0 .And. Len(aFunB) == 0
				fTestaTotal()
				( cRHHTmp )->( dbCloseArea() )
				Loop
			Endif
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Funcionarios                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fImpFun( @aFunP, @aFunD, @aFunB )
		fTestaTotal()

		( cRHHTmp )->( dbCloseArea() )
		dbSelectArea( "SRA" )

	Enddo

	( cMainTmp )->( dbCloseArea() )
	dbSelectArea( "SRA" )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER040   ºAutor  ³Microsiga           º Data ³  11/30/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a quebra de c.custo + item + Classe                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Quebra( nOrdem, cTipo )

	Local cRet := ''

	If nOrdem == 4
		If cTipo = 'CC'
			cRet := ( cMainTmp )->RHH_CC
		Else
			cRet := ' '
		EndIf
	ElseIf nOrdem == 7
		cRet := IIf( cTipo == 'CC', ( cMainTmp )->RHH_CC, IIf( cTipo == 'IT', ( cMainTmp )->RHH_ITEM, IIf( cTipo == 'CL', ( cMainTmp )->RHH_CLVL, ' ') ) )
	Else
		If cTipo = 'CC'
			cRet := ( cMainTmp )->RA_CC
		Else
			cRet := ' '
		EndIf
	EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³DescCc 	³ Autor ³ Marcelo Silveira      ³ Data ³ 15/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Descricao do Centro de Custo					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ AP                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
STATIC Function DescCc( cCodigo, cFil, nBytes )

	Local cAlias := Alias()

	If nBytes = Nil
		nBytes := 40
	Endif

	dbSelectArea( "CTT" ) //-->Prioriza a utilizacao da tabela CTT
	If !EOF()
		cFil := xFilial("CTT",cFil)
		If dbSeek( cFil + cCodigo )
			cRet := Left( CTT_DESC01 + Space( nBytes ), nBytes )
		Else
			cRet := Left( STR0102 + Space( nBytes ), nBytes )  //"** Nao Cadastrado **"
		Endif
	Else
		dbSelectArea( "SI3" ) //-->Utiliza a tabela SI3 caso a tabela CTT esteja vazia
		cFil := xFilial("SI3",cFil)
		If dbSeek( cFil + cCodigo )
			cRet := Left( I3_DESC + Space( nBytes ), nBytes )
		Else
			cRet := Left( STR0102 + Space( nBytes ), nBytes )  //"** Nao Cadastrado **"
		Endif
	Endif

	dbSelectArea( cAlias )

Return( cRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fLoadRecSRG ³ Autor ³ Jordan Lazarine       ³ Data ³19/01/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Identifica se existe rescisao complementar para o funcionario³±±
±±³          ³ no mês de calculo da Folha para totalizacao.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fDifPensaoSM( cFil, cMat, dDtPesq )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFil     = Filial do funci. a verificar                      ³±±
±±³          ³ cMat     = Matricula do funci. a verificar                   ³±±
±±³          ³ dDtPesq  = Data referencia para verificacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fLoadRecSRG(cFil, cMat, dDtPesq, dDtLim)
	Local aArea		:= GetArea()
	Local _aAreaSRG := SRG->(GetArea())
	Local cChave 	:= ""
	Local cFilPsq	:= ""
	Local cMatPsq	:= ""
	Local nCompl	:= 0
	Local lComplmes := .F.
	Local lRet	    := .F.

	//Caracteres
	Local cQuery		:= ""	// Variavel p/ montagem da query
	Local cAliasSRG		:= ""	// Alias da query para cabecalho de rescisao

	cFilPsq := Iif( cFil == NIL, xFilial("SRG", SRA->RA_FILIAL), cFil )
	cMatPsq := Iif( cMat == NIL, SRA->RA_MAT, cMat )
	cChave  := cFilPsq + cMatPsq //+ DtoS(MV_PAR01)

	// Verifica Todos os Registros do Funcionario no "SRG"
	dbSelectArea("SRG")

	cAliasSRG  := GetNextAlias()

	cQuery := " SELECT RG_DTGERAR, RG_DATAHOM, RG_MAT"
	cQuery += "   FROM " + RetSqlName("SRG") + " SRG "
	cQuery += "  WHERE SRG.RG_FILIAL  = '" + cFilPsq + "' AND "
	cQuery += "		   SRG.RG_MAT	  = '" + cMatPsq + "' AND "
	cQuery += "		   SRG.RG_EFETIVA = 'S' AND "
	cQuery += "		   SRG.D_E_L_E_T_ = ' ' "

	cQuery 	   := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRG)

	(cAliasSRG)->(dbGoTop())

	If ValType(dDtLim)=="U"
		While !(cAliasSRG)->(Eof())
			lComplmes := If (MesAno( StoD((cAliasSRG)->RG_DTGERAR)) == MesAno(dDtPesq), .T., .F. ) // rescisao complementar mesmo mes
			If lComplMes 															// se for rescisao complementar ultimo mes, utilizar somente o da ultima rescisao
				nCompl++
			EndIf
			(cAliasSRG)->(dbSkip())
		EndDo
	Else
	    dbSelectArea("SRG")
	    dbSetOrder(1)
	    While dDtPesq <= dDtLim .and. nCompl < 1
			dDtPesq:=dToS(dDtPesq)
			If dbSeek(cFil+cMat+dDtPesq)
	 			nCompl++
			EndIf
			dDtPesq:=SToD(dDtPesq)
	 		dDtPesq ++
	 	Enddo
	Endif

	(cAliasSRG)->(dbCloseArea())

	lRet := Iif( nCompl > 0, .T., .F. )

	RestArea(_aAreaSRG)
	RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fImpDepto ºAutor  ³Equipe RH  	     º Data ³  07/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime um departamento                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fImpDepto()            // Imprime um Departamento

	If	Len(aDeptoP) == 0 .And. Len(aDeptoD) == 0 .And. Len(aDeptoB) == 0
		Return Nil
	Endif

	If lImpDepto
		fImprime(aDeptoP,aDeptoD,aDeptoB,8)
	EndIf

	aDeptoP := {}
	aDeptoD := {}
	aDeptoB := {}

	aEmpP := {}
	aEmpD := {}
	aEmpB := {}
	nDnor := nDafa := nDdem := nDfer := nDexc := nDtot := nDinss := 0

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fChkTpCon ºAutor  ³Renan Borges 	     º Data ³  15/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca tipo de contrato de trabalho da época.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fChkTpCon( cTpFun, cTpFil, dDataPer )
	Local cCampo	:= "RA_TPCONTR"
	Local lRet		:= .F.
	Local aArea	:= GetArea()

	DbselectArea("SR9")
	DbsetOrder(1)
	If DbSeek( (cSRATmp)->(RA_FILIAL+RA_MAT) + cCampo )
		While !eof() .and. (SR9->R9_FILIAL + SR9->R9_MAT + SR9->R9_CAMPO  == (cSRATmp)->(RA_FILIAL+RA_MAT) + cCampo )
			If !(Year(SR9->R9_DATA) > Year(dDataPer)) .AND. !(Month(SR9->R9_DATA) > Month(dDataPer))
				If Substr(SR9->R9_DESC,1,1) $ cTpFil
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			Else
				Exit
			EndIf
			DbSkip()
		EndDo
	Else
		lRet := (cTpFun $ cTpFil)
	EndIf

	RestArea(aArea)

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fFuncAtivo    ºAutor  ³Mauricio MR         º Data ³ 15/05/09º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se funcionario esta ativo para o AnoMes da data    º±±
±±º          ³informada                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³RH                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lTemMov -> .T. tem movimento / .F. Nao tem movimento   	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cFil     : Filial do funcionario                            º±±
±±º          ³cMat     : Matricula do funcionario                         º±±
±±º          ³dIngresso: Data de Ingresso na Filial                       º±±
±±º          ³dData    : Data de Referencia para obter AnoMes             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fFuncAtivo(cFil, cMat,dIngresso, dData)

	Local aTransfAdm	:= {}
	Local cAnoMesData	:= AnoMes(dData)
	Local cFilMat
	Local lTemMov		:= .F.
	Local nPos			:= 0
	Local nPosUlt		:= 0
	Local nPosterior	:= 0
	Local nAnterior 	:= 0


	DEFAULT cFil		:= SRA->RA_FILIAL
	DEFAULT cMat		:= SRA->RA_MAT
	DEFAULT dIngresso	:= SRA->RA_ADMISSA

	cFilMat:= cFil + cMat

	//-- Obtem todas as transferencias para o funcionario corrente a partir da Empresa+Filial+Mat atuais
	fTransfAll( @aTransfAdm,,,.T., cFil, cMat )

	nPosUlt	:= len(aTransfAdm)
	If nPosUlt > 0
		//-- Pesquisa a empresa/filial/matricula corrente e AnoMes igual a data de referencia
		nPos := Ascan(aTransfAdm,{|X|	AnoMes(X[7]) == AnoMes(dData) .And. cEmpAnt == X[4] .And. ( cFilMat ) == X[5] })

		If nPos > 0
			//-- Corre as transferencias e verifica se a ultima no AnoMes eh da Empresa+Filial+Mat Correntes
			nPosterior := nPos + 1
			lTemMov    := .T.
			dIngresso  := aTransfAdm[nPos]

			While (nPosterior <= nPosUlt) .and. AnoMes(aTransfAdm[nPosterior,7] ) == cAnoMesData
			//-- Se ocorreu quebra de Empresa+Filial+Mat, o funcionario foi transferido e nao esta ativo
			If ( ( cEmpAnt +  ( cFilMat ) ) <> ( aTransfAdm[nPosterior][4]	+ aTransfAdm[nPosterior][5] ) )
				lTemMov := .F.
			Else
				//-- Recupera o estado de que o funcionario esta ativo para o AnoMes
				lTemMov 	:= .T.
			Endif

			nPosterior++
			End While
		Else
		    //-- Nao Tem Transferencia no AnoMes para a Empresa+Filial+Mat Correntes
			//-- Neste caso procura a Transferencia Logo Posterior ao AnoMes
			nPosterior	:= Ascan(aTransfAdm,{|X|	AnoMes(X[7]) > cAnoMesData})
	  	    lTemMov 	:= .F.
		    If nPosterior > 0
			    //-- Pesquisa a primeira transferencia "Para" anterior a transferencia posterior ao AnoMes data de referencia
		        nAnterior	:= nPosterior - 1
		    	If (nAnterior ) > 0
	    	    	If ( ( cEmpAnt +  ( cFilMat ) ) <> ( aTransfAdm[nAnterior][4]	+ aTransfAdm[nAnterior][5] ) )
		         	   lTemMov 	:= .F.
	                Else
		    	      lTemMov 	:= .T.
		    	      dIngresso	:= aTransfAdm[nAnterior][7]
		    	    Endif
		    	Else
		    	    //-- Se astransferenciasocorreram depois do AnoMes, verificar se Empresa+Filial+Mat eh a Corrente
		    	    If ( cEmpAnt + ( cFilMat ) ) <> ( aTransfAdm[nPosterior,1] + aTransfAdm[nPosterior,2] )
			    		lTemMov 	:= .F.
				    Else
				      	lTemMov 	:= .T.
			    	Endif
		    	Endif
		    Else
		    	//-- Se Nao Tem Posterior, a Transferencia eh anterior ao AnoMes
		    	If cEmpAnt + ( cFilMat ) <> aTransfAdm[Len(aTransfAdm),4]+aTransfAdm[Len(aTransfAdm),5]
			    	lTemMov 	:= .F.
			    Else
					lTemMov 	:= ( AnoMes(dIngresso) <= AnoMes(dData) )
		    	Endif
		    Endif
		Endif
	Else
		lTemMov := ( AnoMes(dIngresso) <= AnoMes(dData) )
	Endif

Return( lTemMov )
