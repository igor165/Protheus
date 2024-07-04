#Include "DIMESC.CH"
#Include "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "APWIZARD.CH"

//Registro 51 - EXCLUSÕES DE VALORES PARA APURAÇÃO DO VALOR ADICIONADO
//A partir do período de referência janeiro de 2012, estes itens não estarám disponível para preenchimento;
//Item 030
//Item 040
//Item 080
//Item 090
Static dCorte :="20120101"
Static cCodLanRess  := "SC020061"
Static cCfopRess	:= "1603/2603" //http://legislacao.sef.sc.gov.br/legtrib_internet/html/portarias/2012/port_12_153.htm
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIMESC    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do meio-magnetico para a DIME - SC               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aWizard -> Array com as informacoes preenchidas no CFP.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DIMESC ()
	Local	lContinua	:=	.F.
	Local	aWizard		:=	MontPainel (@lContinua)
	Local	aTrb		:=	{}
	Local	lMVIT4910	:=	!GetNewPar ("MV_IT4910", "XXX")=="XXX"
	Local	lMVIT4911	:=	!GetNewPar ("MV_IT4911", "XXX")=="XXX"
	Local	lMVCMPEXTR	:=	!GetNewPar ("MV_CMPEXTR", "XXX")=="XXX"
	Local	nMVCMPEXTR	:=	Iif (lMVCMPEXTR, SB5->(FieldPos (SuperGetMv ("MV_CMPEXTR"))), 0)
	Local	aGNRE		:=	{}
	Local	aLog		:=	{}
	Local	aApICMMe	:=	{}
	Local	aApICM1D	:=	{}
	Local	aApICM2D	:=	{}
	Local	cFilDe		:=	""
	Local	cFilAte		:=	""
	Local	nConsFil	:=	""
	Local	aArq		:=	{}
	Local	aEntr		:=	{}
	Local	aSaid		:=	{}
	Local	aFilsOrd	:=	{}
	Local	lPriFil		:=	.F.
	Local	nFilOrd		:=	0
	Local	aValDIFAL	:= {}
	Local	aCalcPres	:= {}
	Local	aExclVlAd	:= {0,0}
	Local 	lFilCentral := Iif(Type("cFilLog") <> "U",.T.,.F.) 
	Local 	aAreaSM0	:= {}
	Local	aCalcRessa	:= {}

	PRIVATE aProt		:=	{}
	Private lSimples	:=	GetNewPar("MV_SIMPLSC",.F.) // Indica se eh optante do Simples
	Private aProcess	:=  {}
	//
	If !lContinua
		Return ({})
	EndIf
	//Verifica se vai informar protocolos
	If ("Sim"$aWizard[22][1])
		aProt	:= IncProtoc()
	endif
	//
	If !(lMVIT4910)
		xMagHelpFis(STR0001, STR0002, STR0003)
	EndIf
	//
	If !(lMVIT4911)
		xMagHelpFis(STR0001, STR0004, STR0005)
	EndIf
	//
	aAdd (aTrb, {"TRB_REGIST",	"C",	02,	0})
	aAdd (aTrb, {"TRB_QUADRO",	"C",	02,	0})
	aAdd (aTrb, {"TRB_ITEM",	"C",	03,	0})
	aAdd (aTrb, {"TRB_VALOR",	"N",	17,	2})
	aAdd (aTrb, {"TRB_DESCRI",	"C",	15,	0})
	aAdd (aTrb, {"TRB_ORIGEM",	"N",	02,	0})
	//
	CriaTemp("TRB", "TRB_REGIST+TRB_QUADRO+TRB_ITEM", aTrb, aArq)
	//
	aTrb := {}
	aAdd (aTrb, {"TUF_REGIST",	"C",	02,	0})
	aAdd (aTrb, {"TUF_QUADRO",	"C",	02,	0})
	aAdd (aTrb, {"TUF_UF",		"C",	02,	0})
	aAdd (aTrb, {"TUF_VLNCON",	"N",	17,	2})
	aAdd (aTrb, {"TUF_BSNCAL",	"N",	17,	2})
	aAdd (aTrb, {"TUF_VLRCON",	"N",	17,	2})
	aAdd (aTrb, {"TUF_BSCALC",	"N",	17,	2})
	aAdd (aTrb, {"TUF_OUTRAS",	"N",	17,	2})
	aAdd (aTrb, {"TUF_PETROL",	"N",	17,	2})
	aAdd (aTrb, {"TUF_OUTRST",	"N",	17,	2})
	aAdd (aTrb, {"TUF_ICMSST",	"N",	17,	2})
	//
	CriaTemp("TUF", "TUF_REGIST+TUF_QUADRO+TUF_UF", aTrb, aArq)
	//
	aTrb := {}
	aAdd (aTrb, {"T4X_REGIST",	"C",	02,	0})
	aAdd (aTrb, {"T4X_QUADRO",	"C",	02,	0})
	aAdd (aTrb, {"T4X_MUNIC",	"C",	05,	0})
	aAdd (aTrb, {"T4X_VALOR",	"N",	17,	2})
	//
	CriaTemp("T4X", "T4X_REGIST+T4X_QUADRO+T4X_MUNIC", aTrb, aArq)
	//
	aTrb := {}
	aAdd (aTrb, {"R48_REGIST",	"C",	02,	0})
	aAdd (aTrb, {"R48_QUADRO",	"C",	02,	0})
	aAdd (aTrb, {"R48_MUNIC",	"C",	05,	0})
	aAdd (aTrb, {"R48_VALOR",	"N",	26,	8})
	aAdd (aTrb, {"R48_TIPO",	"C",	03,	0})
	//
	CriaTemp("R48", "R48_REGIST+R48_QUADRO+R48_MUNIC+R48_TIPO", aTrb, aArq)
	//
	aTrb := {}
	aAdd (aTrb, {"GNR_REGIST",	"C",	02,	0})
	aAdd (aTrb, {"GNR_QUADRO",	"C",	02,	0})
	aAdd (aTrb, {"GNR_ORIGEM",	"C",	01,	0})
	aAdd (aTrb, {"GNR_RECEIT",	"C",	04,	0})
	aAdd (aTrb, {"GNR_DATA",	"C",	08,	0})
	aAdd (aTrb, {"GNR_VALOR",	"N",	17,	2})
	aAdd (aTrb, {"GNR_CLVEN",	"C",	05,	0})
	aAdd (aTrb, {"GNR_ACORDO",	"C",	15,	0})
	//
	CriaTemp("GNR", "GNR_REGIST+GNR_QUADRO+GNR_ORIGEM", aTrb, aArq)
	//
	If (lContinua)
		aAddLog ("XX", 1,,,, aWizard, @aLog)
		aAddLog ("XX", 2,,,, aWizard, @aLog)

		//Seleciona informações da F0I (Difal)
		aValDIFAL := DIMEDIFAL(aWizard)

		//Calcula Credito presumido
		aCalcPres := CALCPRESU(MV_PAR01,MV_PAR02,aWizard)
		
		//Calcula Ressarssimento Conforme consta na Portaria 396/2018 art.12 - Registro 32, Quadro 11, item 115
		aCalcRessa	:= RessarcIcm(MV_PAR01,MV_PAR02)
		
		//Procurar processo referenciado para adicionar no Quadro 46, conforme consta na Portaria  Portaria SEF 201/19, art. 1º - Registro 46, Quadro 46
		aProcess	:= AUCOTCIcm(MV_PAR01,MV_PAR02)
		
		If lFilCentral
			aAreaSM0 := SM0->(GetArea())
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cEmpAnt+cFilLog))
		EndIf

		//*********************************************** NAO TIRAR DA ORDEM *****************************************************//
		If (!"Decendial"$aWizard[2][12]) 
			aApICMMe	:=	FisApur ("IC", Year (MV_PAR02), Month (MV_PAR02), 3, 0, "*", .F., {}, 1, .F., "")
		Else
			aApICM1D	:=	FisApur ("IC", Year (MV_PAR02), Month (MV_PAR02), 1, 4, "*", .F., {}, 1, .F., "")
			aApICM2D	:=	FisApur ("IC", Year (MV_PAR02), Month (MV_PAR02), 1, 3, "*", .F., {}, 1, .F., "")
		EndIf
		
		If lFilCentral
			RestArea(aAreaSM0)
		EndIf

		//Registro Tipo 46 - Creditos por regimes e autorizacoes especiais.
		DIME46 (aWizard, aApICMMe, aApICM1D, aApICM2D)
		//Registro Tipo 42 - Debitos por transferencia de creditos acumulados
		DIME42 (aWizard, aApICMMe, aApICM1D, aApICM2D)
		//Registro Tipo 43 - Creditos recebidos por transferencias
		DIME43 (aWizard, aApICMMe, aApICM1D, aApICM2D)
		//Registro Tipo 41 - Demonstrativos de creditos acumulados
		DIME41 (aWizard, aApICMMe, aApICM1D, aApICM2D, @aLog)
		//Registro Tipo 44 - Creditos presumidos
		DIME44 (aWizard, aApICMMe, aApICM1D, aApICM2D, @aLog)
		//Registro Tipo 31 - Debitos especificos.
		aGNRE	:=	DIME31 (aWizard, aApICMMe, aApICM1D, aApICM2D)
		//GNRE 1=ICMS, 2=ICMS/ST e 3=Debitos Especificos
		DIME33 (aWizard, aGNRE)
		//Registro Tipo 27 - Apuracao para empresas do regime simples. Somente para apuracao do regime optante pelo SIMPLES.
		//Agora a verificacao sera feita pelo parâmetro MV_SIMPLSC, pois foi retirada da wizard a opcao "Simples" pelo novo layout
		DIME27 (aWizard, aApICMMe)
		//**************************** FIM DO BLOCO QUE NAO PODE SOFRER ALTERACAO NA ORDEM DA CHAMADA ****************************//
		//Registro Tipo 25 - Resumo das apuracoes dos Debitos. Somente para apuracao do tipo NORMAL (ICMS/ST)
		DIME25 (aWizard, aApICMMe, aApICM1D, aApICM2D, aGNRE, @aValDIFAL)
		//Registro Tipo 26 - Resumo das apuracoes dos Creditos. Somente para apuracao do tipo NORMAL (ICMS/ST)
		DIME26 (aWizard, aApICMMe, aApICM1D, aApICM2D, @aLog, aValDIFAL[13])
		//Registro Tipo 28 - Apuracao Especial para Bares, Restaurantes e Similares
		//DIME28 (aWizard) --> (Revogado pelo Art. 14 da Portaria SEF nº 004/16 - Efeitos fatos geradores a partir da referência janeiro/2016)
		//Apuracao do regime especial de estimativa fixa - Somente para apuracao de Regime de Estimativa fixa
		DIME29 (aWizard, aApICMMe, aApICM1D, aApICM2D)
		//Registro Tipo 30 - Calculo Imposto a pagar ou saldo credor. 
		DIME30 (aWizard, @aLog, aApICMMe, aApICM1D, aApICM2D,aCalcPres)
		//Registro Tipo 32 - Informacoes sobre Substituicao Tributaria. Somente para Substituto ou Substituido
		DIME32 (aWizard,aCalcRessa)
		//Registro Tipo 34 - Informações Sobre Diferença De Alíquota De Operação Interestadual a Consumidor - DIFAL
		DIME34	(aValDIFAL)
		//Registro Tipo 35 - Demonstrativo da Apuração do Imposto Devido pela Apropriação de Crédito Presumido em Substituição aos Créditos pelas Entradas (DAICP)
		DIME35	(aWizard,aCalcPres,aApICMMe, aApICM1D, aApICM2D)
		//Registro Tipo 80 - Declaracao complementar Anual --> Para todas as declaracoes independente da escrita contabil. Basta estar preenchida.
		DIME80 (aWizard)
		//Registro tipo 81 - Ativo	--> Somente contribuintes que possuirem escrita contabil (Informado no 2. painel do wizard). Basta estar preenchida.
		DIME81 (aWizard)
		//Registro tipo 82 - Passivo --> Somente contribuintes que possuirem escrita contabil (Informado no 2. painel do wizard). Basta estar preenchida.
		DIME82 (aWizard)
		//Registro tipo 83 - Demonstracao de resultado	--> Somente contribuintes que possuirem escrita contabil (Informado no 2. painel do wizard). Basta estar preenchida.
		DIME83 (aWizard)
		//Registro tipo 84 - Detalhamento das despesas --> Para todas as declaracoes independente da escrita contabil. Basta estar preenchida.
		DIME84 (aWizard)
		//
		If ("Encerramento"$aWizard[2][2])
			//Registro Tipo 90 - Declaracao complementar de encerramento de atividade --> Para todas as declaracoes independente da escrita contabil. Basta estar preenchida.
			DIME90 (aWizard)
			//Registro tipo 91 - Ativo	--> Somente contribuintes que possuirem escrita contabil (Informado no 2. painel do wizard).Basta estar preenchida.
			DIME91 (aWizard)
			//Registro tipo 92 - Passivo --> Somente contribuintes que possuirem escrita contabil (Informado no 2. painel do wizard).Basta estar preenchida.
			DIME92 (aWizard)
			//Registro tipo 93 - Demonstracao de resultado	--> Somente contribuintes que possuirem escrita contabil (Informado no 2. painel do wizard).Basta estar preenchida.
			DIME93 (aWizard)
			//Registro tipo 94 - Detalhamento das despesas --> Para todas as declaracoes independente da escrita contabil. Basta estar preenchida.
			DIME94 (aWizard)
		EndIf
		
		//Registro Tipo 45 - Creditos por incentivos fiscais
		DIME45 (aWizard, aApICMMe, aApICM1D, aApICM2D)
		//Cria log
		GeraTxtLog (MV_PAR05, aLog)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando a apuracao for centralizada e o arquivo magnetico que esta sendo      ³
		//³gerado for do estabelecimento centralizador, as informacoes de notas fiscais ³
		//³deverao ser processadas atraves dos parametros filial de/ate, desde que as   ³
		//³filiais sejam de Santa Catarina (Decreto 305 de 03/06/2003). As informacoes  ³
		//³referentes a apuracao do imposto, deverao ser lancadas na propria apuracao   ³
		//³(MATA953) visto que o recolhimento do imposto deve ser centralizado.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If "consolidador"$aWizard[2][5]			// .And. (!Empty(aWizard[2][14]) .Or. !Empty(aWizard[2][15]))
			//-- Ordena por CNPJ+IE+Codigo para facilitar a quebra da rotina
			aFilsOrd := aClone(aFilsCalc)
			aSort(aFilsOrd,,,{|x,y| x[4]+x[5]+x[2] < y[4]+y[5]+y[2]})
			For nFilOrd := 1 To Len(aFilsOrd)
				If aFilsOrd[nFilOrd][1]
					If lPriFil
						cFilDe 	:= aFilsOrd[nFilOrd][2]
						lPriFil	:= .F.
					EndIf
					cFilAte		:= aFilsOrd[nFilOrd][2]
				EndIf
			Next
			nConsFil	:= 1 
			lExitPFil	:= .T.			// Faz com que o consolidado seja processado uma unica vez no Mata950
		Else
			cFilDe 		:= cFilAnt
			cFilAte		:= cFilAnt
			nConsFil	:= 2
		Endif

		//Processa dados para quadro 01 - entradas e 02 - sa´das
		ResumeF3 ("IC", MV_PAR01, MV_PAR02, "*", .F., .T., 1, .F., nConsFil, cFilDe, cFilAte, {}, {}, "",.T., "CFO",,,,,,,,,.T.,,,,,,,aFilsCalc)	

		//Adiciona no arquivo CFO notas de ISS com especie SPED para compor registros quadro 01 e 02
		aExclVlAd:= ResumeISS(MV_PAR01,MV_PAR02,aFilsCalc,"*","CFO")
		//Registro tipo 51 - Exclusoes do valor adicionado no mes
		DIME51 (aWizard,aExclVlAd)
		
		ResumeF3 ("IC", MV_PAR01, MV_PAR02, "*", .F., .F., 1, .F., nConsFil, cFilDe, cFilAte, @aEntr, @aSaid, "",.T., "EST", .T.,,.F.,,,,,.F.,.T.,,,,,,,aFilsCalc,,,,,,,,,,.F.)
		//Registro Tipo 49 - Entradas por Unidade de Federacao
		//Registro Tipo 50 - Saidas por Unidade de Federacao
		ResumeISS(MV_PAR01,MV_PAR02,aFilsCalc,"*","EST")
		DIME4950 (aWizard, lMVIT4910, lMVIT4911,@aEntr,@aSaid)
		//Registro tipo 47 - Compras de Extratores, Produtores Agropecuarios e Pescadores
		DIME47 (nMVCMPEXTR,cFilDe,cFilAte)
		//Registro tipo 48 - Receita de prestacao de servico e fornecimento e energia eletrica.
		DIME48 (aWizard,cFilDe,cFilAte)
	EndIf
Return (aWizard)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME20    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 20 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³             DADOS DO CONTABILISTA RESPONSAVEL              ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes solicitadas no 1. painel do wizard³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet -> String para o Registro                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DIME20 (aWizard)
	Local	cRet	:=	""
	Local   cCompl  :=  ""
	//
	If StrZero(Year (MV_PAR02),4)+StrZero(Month (MV_PAR02),2) >= "201201"
        cCompl := Dtos(Date())+Replace(Time(),":","") 	
	EndIf
	cRet	:=	"20  "+PadR (aWizard[1][1], 11)+PadR (aWizard[1][2], 50)+cCompl
Return (cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME21    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 21 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³                   INICIO DA DECLARACAO                     ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes solicitadas no 2. painel do wizard³±±
±±³          ³ e do campo M0_INSC do sigamat.emp                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet -> String para o Registro                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DIME21 (aWizard)
	Local	cRet	:=	"2100"
	//
	cRet	+=	PadR (SM0->M0_INSC, 9)		//Numero Incricao
	cRet	+=	PadR (aWizard[2][1], 50)	//Nome do contribuinte
	cRet	+=	StrZero (Month (MV_PAR02), 2)+StrZero (Year (MV_PAR02), 4)	//Periodo de referencia da declaracao	
	//Tipo da declaracao
	If ("Normal"$aWizard[2][2])
		cRet += "1"
	ElseIf "Encerramento"$aWizard[2][2]
		cRet += "2"
	ElseIf "Estimativa"$aWizard[2][2]
		cRet += "3"
	Else
		cRet += "4"
	EndIf
	//Regime de apuracao
	If ("Normal"$aWizard[2][3])
		cRet	+=	"2"
	Else
		If ("Estimativa"$aWizard[2][3])
			cRet	+=	"3"
		Else
			cRet	+=	Iif ("Bares"$aWizard[2][3], "7", "9")
		EndIf
	EndIf
	//Porte da empresa
	If StrZero(Year (MV_PAR02),4)+StrZero(Month (MV_PAR02),2) >= "201201"
		cRet	+=	"1"
	Else
		If ("ME (Microempresa)"$aWizard[2][4])
			cRet	+=	"1"
		Else
			If ("EPP (Empresa Peq. Porte)"$aWizard[2][4])
				cREt	+=	"2"
			Else
				cRet	+=	Iif ("Normal"$aWizard[2][4], "3", "9")
			EndIf
		EndIf
    EndIf
	//
	cRet	+=	Iif ("consolidada"$aWizard[2][5], "1", Iif ("consolidador"$aWizard[2][5], "2", "3"))		//Apuracao consolidada
	cRet	+=	"1"  //apuração centralizada
	//Transferencias de creditos no periodo
	If ("nem recebeu"$aWizard[2][6])
		cRet	+=	"1"
	Else
		If ("reservou cr"$aWizard[2][6])
			cRet	+=	"2"
		Else
			cRet	+=	Iif ("reservou e recebeu cr"$aWizard[2][6], "4", "3")
		EndIf
	EndIf
	
	If StrZero(Year (MV_PAR02),4)+StrZero(Month (MV_PAR02),2) >= "201201"
		cRet	+=	"1"
    Else
	    cRet	+=	Iif ("Sim"$aWizard[2][7], "1", "2")														//Tem creditos presumidos
	EndIf

	If StrZero(Year (MV_PAR02),4)+StrZero(Month (MV_PAR02),2) >= "201201"
    	cRet	+=	"1"
    Else
	    cRet	+=	Iif ("Sim"$aWizard[2][8], "1",Iif("Não"$aWizard[2][8],"2","3"))							//Tem creditos por incentivos fiscais
	EndIf
	
	cRet	+=	Iif ("e sem saldos"$aWizard[2][9], "1", Iif ("e com saldos"$aWizard[2][9], "2", "3"))		//Movimento
	cRet	+=	Iif ("Sim"$aWizard[2][10], "1", Iif ("Substitu"$aWizard[2][10], "3", "2"))   				//Substituto tributario
	cRet	+=	Iif ("dados"$aWizard[2][11], "3", Iif("Não"$aWizard[2][11], "2","1"))						//Tem escrita contabil
	cRet	+=	StrZero (Val (aWizard[2][13]), 5, 0)														//Quantidade de trabalhadores em atividade
Return (cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME25    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 25 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³             RESUMO DA APURACAO DOS DEBITOS                 ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente, podendo ser decendial ou mensal.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN -> Subtotal de debitos para o quadro 09 item 010.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME25 (aWizard, aApICMMe, aApICM1D, aApICM2D, aGNRE, aValDIFAL)
	//Local nX := 0   // Auxiliar para o For 
	Local	aValor		:=	Array(11)				//1-Debitos pela saida
													//2-Estorno de credito
											   		//3-Outros Debitos
											   		//4-SubTotal Debitos
											  		//5-Debito por diferencial de aliquota do ativo permanente
											  		//6-Debito por diferencial de aliquota do material de uso e consumo
											 		//7-Debitos de maquinas/equipamentos importados para ativo permanente
											 		//8-Outros estornos
											 		//9-Outros debitos
											 		//10-Débito da Diferença de Alíquota de Operação ou Prestação a Consumidor Final de Outro Estado 
	aFill (aValor, 0)											 		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para todas as declaracoes |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ("Normal"$aWizard[2][3]) .Or. ("Produtor"$aWizard[2][3])
		If (!"Decendial"$aWizard[2][12]) 
			DIME25Val(@aValor,aApICMMe)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PRIMEIRO DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			DIME25Val(@aValor,aApICM1D)
	    	    		    	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SEGUNDO DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DIME25Val(@aValor,aApICM2D)
 	
		EndIf

		//Verificação do Sub item da apuração referente ao estorno de DIFAL 
		//de SC para ser lançado como outros creditos do ICMS Próprio

		aValDIFAL[11] :=  Iif(aValor[10] > 0, aValor[10],aValDIFAL[11])

		//Tratamento para não gerar os itens 070 e 090
		aValDIFAL[6] :=  Iif(aValor[10] > 0, 0,aValDIFAL[6])
		aValDIFAL[7] :=  Iif(aValor[10] > 0, 0,aValDIFAL[7])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Este array (aGNRE) somente estara alimentado quando possuir lancamentos     ³
		//³  dos debitos especificos via Apuracao de ICMS. Neste caso devo subtrair de ³
		//³  outros debitos (conforme explicacao abaixo), caso contrario NAO.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len (aGNRE)>0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Subtraio o valor de debitos especificos, pois ha necessidade de demonstrar em conta grafica.         ³
			//³Portanto ao informar na propria Apuracao de ICMS a GNRE e Classe de vencimento, eh gerado os titulos ³
			//³separados para o Debito especifico. Neste caso como eh lancado em Outros Debitos agregando ao valor, ³
			//³mais eh necessario subtrair do total da apuracao para bater o IMPOSTO A RECOLHER com a GNRE Tipo 1, o³
			//³os DEBITOS ESPECIFICOS com as GNREs tipo 3.                                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aValor[3]	-=	AtuVlrDime(.T., "31", "10", "990")
			aValor[4]	-=	AtuVlrDime(.T., "31", "10", "990")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Subtraio pois ja esta incluso em outros debitos que considero neste mesmo quadro.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	aValor[3]	-=	aValor[5]+aValor[6]+aValor[7]+aValor[10]   //tratamento retirado baseado no chamado - TQHAH7
    	aValor[2]	-=	aValor[8]
		//
		//Debito pelas saidas
		AtuVlrDime (.F., "25", "04", "010", aValor[1], 2)
		//
		//Debito por diferencial de aliquotas do ativo permanente
		AtuVlrDime (.F., "25", "04", "020", aValor[5], 2)
		//
		//Debito por diferencial de aliquotas do material de uso e consumo
		AtuVlrDime (.F., "25", "04", "030", aValor[6], 2)
		//
		//Debito de maquinas/equipamentos importados para o ativo permanente
		AtuVlrDime (.F., "25", "04", "040", aValor[7], 2)
		//
		//Débito da Diferença de Alíquota de Operação ou Prestação a Consumidor Final de Outro Estado
		AtuVlrDime (.F., "25", "04", "045", aValDIFAL[11], 2)
		//
		//Estorno de credito
		AtuVlrDime (.F., "25", "04", "050", aValor[2], 2)
		//
		//Outros estornos
		AtuVlrDime (.F., "25", "04", "060", aValor[8], 2)
		//Estorno de Crédito da Entrada em Decorrência da Utilização de Crédito Presumido 
		AtuVlrDime (.F., "25", "04", "065", aValor[11], 2)
		//
		//Outros debitos
		AtuVlrDime (.F., "25", "04", "070", aValor[9], 2)
		

		/* --------------------------------------------------
		  Outros debitos
		  Este valor de Outros Debitos sera verificado posteriormente na funcao DIME30() atraves dos codigos utilizados no Quadro 09.
		  Esse eh um procedimento do proprio manual da DIME descrito desta forma:
		
		a)	Item 070 - Outros Débitos: lançar o valor correspondente a outros débitos do ICMS, previstos no RICMS-SC/01 
			que não se enquadrem nos itens anteriores ou não estejam especificados em campo próprio no 
			Quadro 09 - Cálculo do Imposto a Pagar ou Saldo Credor;
			
		  Portanto os valores de outros Debitos que entram na regra do Quadro 09 - Registro 30 serao somados ao item 020 deste registro
		   e serao posteriormente subtraidos do item 070 do registro 25.
		   
		   Consultar reflexo neste codigo fonte utilizando a palavra: DIME_RELAC_001
		-------------------------------------------------- */
		AtuVlrDime (.F., "25", "04", "070", aValor[3], 1)
		//
		//Subtotal de debitos
		AtuVlrDime (.F., "25", "04", "990", aValor[4], 2)
	EndIf
Return (.T.)

/*/{Protheus.doc} DIME25Val 
@description Preenche o array aValor de acordo com as regras
Já existia o código abaixo, somente transformei em função para melhorar a repetição de código
@author Matheus Massarotto
@since 18/11/2021
@version 12.1.27
/*/
Static Function DIME25Val(aValor,aArray)
Local nX := 0 
Local cConteudo := ""

	For nX := 1 To Len(aArray)

		cConteudo := SubStr(aArray[nX][4],1,5)

		//1-Debitos pela saida
		aValor[1]	+=	Iif(aArray[nX][1]=="001" .AND. empty(aArray[nX][4]) , aArray[nX][3], 0)
		//2-Estorno de credito
		aValor[2]	+=	Iif(cConteudo=="25050" , aArray[nX][3], 0)
		//3-Outros Debitos
		aValor[3]	+=	Iif(aArray[nX][1]=="002" .AND. aArray[nX][4]=="002.00", aArray[nX][3], 0)
		//4-SubTotal Debitos
		aValor[4]	+=	Iif(aArray[nX][1]=="004" .AND. empty(aArray[nX][4]) , aArray[nX][3], 0)	    	
		//5-Debito por diferencial de aliquota do ativo permanente
		aValor[5]	+=	Iif(cConteudo=="25020" , aArray[nX][3], 0)
		//6-Debito por diferencial de aliquota do material de uso e consumo
		aValor[6]	+=	Iif(cConteudo=="25030" , aArray[nX][3], 0)
		//7-Debitos de maquinas/equipamentos importados para ativo permanente
		aValor[7]	+=	Iif(cConteudo=="25040" , aArray[nX][3], 0)
		//8-Outros estornos
		aValor[8]	+=	Iif(cConteudo=="25060" , aArray[nX][3], 0)
		//Outros Debitos	    	
		aValor[9]	+=	Iif(cConteudo=="25070" , aArray[nX][3], 0)
		//10-Débito da Diferença de Alíquota de Operação ou Prestação a Consumidor Final de Outro Estado 
		aValor[10]	+=	Iif(cConteudo=="25045" , aArray[nX][3], 0)
		//11-Estorno de Crédito da Entrada em Decorrência da Utilização de Crédito Presumido
		aValor[11]	+=	Iif(cConteudo=="25065" , aArray[nX][3], 0)
	Next nX

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME26    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 26 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³             RESUMO DA APURACAO DOS CREDITOS                ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente, podendo ser decendial ou mensal.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME26 (aWizard, aApICMMe, aApICM1D, aApICM2D, aLog, nValDifAlq)
	Local	nI			:=	0
	Local 	nTotReg26   :=  0
	Local	aValor		:=	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	//1-Saldo credor do periodo anterior
																	//2-Credito pelas entradas
																	//3-Credito de ativo permanente
																	//4-Credito por diferencial de aliquota de material de uso e consumo
																	//5-Credito de ICMS retido por ST
															   		//6-Estorno de debito por transferencia de creditos acumulados
																	//7-Outros estorno de debitos
																	//8-Total de creditos presumidos
																	//9-Total de creditos por incentivos fiscais
																	//10-Credito relativo a operacoes de importacoes
																	//11-Credito relativo a aquisicao de atacadistas de outras UF
																	//12-Credito por responsabilidades tributarias
																	//13-Outros pagamentos devidos por ocasiao do fato gerador
																	//14-Total de creditos por regime especial
																	//15-Restituicao de ICMS
																	//16-Outros creditos
																	//17-Subtotal de creditos
																	//18-Total de creditos por regime e autorização especial
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para apuracao do tipo NORMAL(ICMS/ST) ou produtor primario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ("Normal"$aWizard[2][3]) .Or. ("Produtor"$aWizard[2][3])
		If (!"Decendial"$aWizard[2][12])
			DIME26Val(@aValor,aApICMMe)
			
			nTotReg26 	+= aValor[2] + aValor[3] + aValor[4] + aValor[5] + aValor[10] + aValor[11] + aValor[12] + aValor[13] + aValor[15]
				 
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PRIMEIRO DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DIME26Val(@aValor,aApICM1D)

			nTotReg26 	:= aValor[2] + aValor[3] + aValor[4] + aValor[5] + aValor[10] + aValor[11] + aValor[12] + aValor[13] + aValor[15]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SEGUNDO DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DIME26Val(@aValor,aApICM2D)

			nTotReg26 	:= aValor[2] + aValor[3] + aValor[4] + aValor[5] + aValor[10] + aValor[11] + aValor[12] + aValor[13] + aValor[15]
		EndIf 
		/* Retirado tratamento para considerar o saldo anterior do quadro 41. 
		aValor[1]	+=	AtuVlrDime(.T., "41", "41", "160")+;
						AtuVlrDime(.T., "41", "41", "170")+;
						AtuVlrDime(.T., "41", "41", "180")+;
						AtuVlrDime(.T., "41", "41", "190")		//Valores de saldos da apuracao anterior lancado com os codigos de subitem 41???
        */           

		//Acumula valor do saldo credor periodo anterior
		nTotReg26 	+= aValor[1]
		
		aValor[6]	:=	AtuVlrDime(.T., "41", "41", "220")+;
						AtuVlrDime(.T., "41", "41", "230")+;
						AtuVlrDime(.T., "41", "41", "240")		//Valores de estorno lancado com os codigos de subitem 41???
		aValor[7]	-=	aValor[6]								//Subtraio, para nao duplicar o aValor[6], pois para o 
																//	aValor[7] utilizo o totalizados da linha 007 da apuracao (ESTORNOS).
		aValor[8]	:=	AtuVlrDime(.T., "44", "44", "990")		//Valores transportados do quadro 44 item 990 conforme layout

	    aValor[9]	:=	AtuVlrDime(.T., "45", "45", "990")		//Valores transportados do quadro 45 item 990 conforme layout
	    aValor[17]	+=	aValor[9]								//Somo ao subtotal dos creditos para transportar para o Registro 30, pois foi lancado nas Deducoes da Apuracao de ICMS, subitem 012
	    //
	    //14-Total de creditos por regime especial
	    aValor[14]	:=	AtuVlrDime(.T., "46", "46",,,2,,90)	//Quando se tratar de Regimes especiais - Registro 46, o mesmo
																//  pode conter diversos lancamentos com diversos protocolos, 
																//  onde deverao ser aglutinados neste item.
																
		aValor[18]	:=	AtuVlrDime(.T., "46", "46",,,2,,14)	//Quando se tratar de Regimes especiais - Registro 46, o mesmo
		aValor[17]	-=	aValor[18]							//  pode conter diversos lancamentos com diversos protocolos, 
																//  onde deverao ser aglutinados neste item.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Como os lancamentos na apuracao sao na parte de outros creditos, devo subtrair    ³
		//³        do campo 16(Outros Creditos), pois possuem campos especificos e se nao for³
		//³        feito este FOR, duplicarah os valores.                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    nI:= 0
		For nI := 1 To Len (aValor)
	    	//Somente itens que foram lancados em outros debitos.
	    	If 	(nI>=3 .And. nI<=5) .Or.; 				//Fixos na apuracao deste quadro
	    		(nI==8) .Or. (nI>=10 .And. nI<=15) .Or.;	//Fixos na apuracao deste quadro
	    		nI==18								  		//Fixos na apuracao deste quadro
			    aValor[16]	-=	aValor[nI]
			EndIf
		Next nI
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³CONSISTENCIA NO ARQUIVO DE LOG PARA QUANDO TOTAL DE CREDITOS  ³
		//³  NA ENTRADA SER INFERIOR AOS CREDITOS ACUMULADOS LANCADOS NO ³
		//³  QUADRO 41, ITENS 120, 130 E 140.                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAddLog ("26010",,aValor[2],,,, @aLog)
		//Saldo credor do mes anterior
		AtuVlrDime (.F., "26", "05", "010", aValor[1], 2)
		//Credito pelas entradas
		AtuVlrDime (.F., "26", "05", "020", aValor[2], 2)
		//Credito de ativo permanente
		AtuVlrDime (.F., "26", "05", "030", aValor[3], 2)
		//Credito por diferencial de aliquota de material de uso e consumo
		AtuVlrDime (.F., "26", "05", "040", aValor[4], 2)
		//Crédito da Diferença de Alíquota de Operação ou Prestação a Consumidor Final de Outro Estado
		AtuVlrDime (.F., "26", "05", "045", nValDifAlq, 2)
		//Credito ICMS retido por ST
		AtuVlrDime (.F., "26", "05", "050", aValor[5], 2)
		//Credito relativo a operacoes de importacao
		AtuVlrDime (.F., "26", "05", "100", aValor[10], 2)
		//Credito relativo a aquisicao de atacadistas de outras UF
		AtuVlrDime (.F., "26", "05", "110", aValor[11], 2)
		//Creditos por responsabilidade tributaria
		AtuVlrDime (.F., "26", "05", "120", aValor[12], 2)
		//Outros pagamentos devidos por ocasiao do fato gerador
		AtuVlrDime (.F., "26", "05", "130", aValor[13], 2)
		//Restituicao de ICMS
		AtuVlrDime (.F., "26", "05", "150", aValor[15], 2)
		//Subtotal de creditos
		AtuVlrDime (.F., "26", "05", "990", nTotReg26, 2)
	EndIf
Return (.T.)


/*/{Protheus.doc} DIME26Val 
@description Preenche o array aValor de acordo com as regras
Já existia o código abaixo, somente transformei em função para melhorar a repetição de código
@author Matheus Massarotto
@since 18/11/2021
@version 12.1.27
/*/
Static Function DIME26Val(aValor,aArray)
Local nI := 0 
Local cConteudo := ""

	For nI := 1 To Len(aArray)

		cConteudo := SubStr(aArray[nI][4],1,5)

		aValor[1]	+=	Iif (aArray[nI][1]=="009" .AND. empty(aArray[nI][4])	, aArray[nI][3], 0)
		aValor[2]	+=	Iif (aArray[nI][1]=="005" .AND. empty(aArray[nI][4])	, aArray[nI][3], 0)
		aValor[3]	+=	Iif (cConteudo=="26030" , aArray[nI][3], 0)
		aValor[4]	+=	Iif (cConteudo=="26040" , aArray[nI][3], 0)
		aValor[5]	+=	Iif (cConteudo=="26050" , aArray[nI][3], 0)
		aValor[6]	:=	0	//Abaixo
		aValor[7]	+=	Iif (aArray[nI][1]=="007" .AND. aArray[nI][4]=="007.00" , aArray[nI][3], 0)
		aValor[8]	:=	0	//Abaixo
		aValor[9]	:=	0	//Abaixo
		aValor[10]	+=	Iif (cConteudo=="26100" , aArray[nI][3], 0)
		aValor[11]	+=	Iif (cConteudo=="26110" , aArray[nI][3], 0)
		aValor[12]	+=	Iif (cConteudo=="26120" , aArray[nI][3], 0)
		aValor[13]	+=	Iif (cConteudo=="26130" , aArray[nI][3], 0)
		aValor[14]	:=	0	//Abaixo
		aValor[15]	+=	Iif (cConteudo=="26150" , aArray[nI][3], 0)
		aValor[16]	+=	Iif (aArray[nI][1]=="006" .AND. aArray[nI][4]=="006.00" , aArray[nI][3], 0)
		aValor[17]	+=	Iif (aArray[nI][1]=="010" .AND. empty(aArray[nI][4])	, aArray[nI][3], 0)
		aValor[18]	:=	0	//Abaixo
	Next nX

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME27    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 27 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³        APRUACAO PARA EMPRESAS DO REGIME SIMPLES            ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente no regime simples.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME27 (aWizard, aApICMMe)
	Local	aValor		:=	{0,0,0,0,0,0}		//1-Imposto devido calculado sobre o total da receita tributavel
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para apuracao do regime optante pelo SIMPLES.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSimples .And. (("ME (Microempresa)"$aWizard[2][4]) .Or. ("EPP (Empresa Peq. Porte)"$aWizard[2][4]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³OBSERVACAO: OS ITENS 010 E 030 SAO CALCULADOS NO INI³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Imposto devido calculado sobre o total da receita tributavel
		aValor[1]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="1303"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="1303"})][3], 0)
		AtuVlrDime (.F., "27", "06", "040", aValor[1], 2)
		//Credito pela regularidade de pagamento
		aValor[2]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="27050"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="27050"})][3], 0)
		AtuVlrDime (.F., "27", "06", "050", aValor[2], 2)
		//Credito Presumido Permitido
		aValor[3]	:=	AtuVlrDime (.T., "44", "44", "990")
		AtuVlrDime (.F., "27", "06", "060", aValor[3], 2)   
		//Credito Relativo a aquisicao de atacadistas de outras UFs
		aValor[4]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="27070"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="27070"})][3], 0)
		AtuVlrDime (.F., "27", "06", "070", aValor[4], 2)
		//Saldo Credor do Mes Anterior
		aValor[5]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="27080"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="27080"})][3], 0)
		AtuVlrDime (.F., "27", "06", "080", aValor[5], 2)
		// Subtotal de Creditos   
		aValor[6] := aValor[2] + aValor[3] + aValor[4] + aValor[5]
		AtuVlrDime (.F., "27", "06", "990", aValor[6], 2)
		//  
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME28    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 28 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³   APURACAO ESPECIAL PARA BARES, RESTAURANTES E SIMILARES   ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente no regime simples.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME28 (aWizard)
	Local	aValor	:=	{0,0,0,0,0}		//1-Debito sobre o valor das entradas
										//2-Debito sobre a diferenca entre entradas/saidas
										//3-Credito relativo a aquisicao de atacadistas de outras UF
										//4-Credito Presumido Permitido
										//5-Saldo credor do periodo anterior
	
	If ("Bares"$aWizard[2][3])
		aValor[1]	:=	Val (aWizard[11][1])
		aValor[2]	:=	Val (aWizard[11][2])
		aValor[3]	:=	Val (aWizard[11][3])
		aValor[4]	:=	AtuVlrDime (.T., "44", "44", "990")
		aValor[5]	:=	Val (aWizard[11][4])
		//Debito sobre o valor das entradas
		AtuVlrDime (.F., "28", "07", "010", aValor[1], 2)
		//Debito sobre a diferenca entre entradas/saidas
		AtuVlrDime (.F., "28", "07", "020", aValor[2], 2)
		//SubTotal de debitos
		AtuVlrDime (.F., "28", "07", "980", aValor[1]+aValor[2], 2)
		//Credito relativo a aquisicao de atacadistas de outras UF
		AtuVlrDime (.F., "28", "07", "030", aValor[3], 2)
		//Credito Presumido Permitido
		AtuVlrDime (.F., "28", "07", "040", aValor[4], 2)
		//Saldo credor do periodo anterior
		AtuVlrDime (.F., "28", "07", "050", aValor[5], 2)
		//SubTotal de Creditos
		AtuVlrDime (.F., "28", "07", "990", aValor[3]+aValor[4]+aValor[5], 2)
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME29    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 29 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³      APURACAO PARA CONTRIBUINTES COM ESTIMATIVA FISCAL     ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN -> Valor a ser retornado para o quadro 45 item 010.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME29 (aWizard, aApICMMe, aApICM1D, aApICM2D)
	Local	aValor		:=	{0,0,0,0}	//1-Debito Apurado no Mes
										//2-Credito Apurado no Mes
										//3-Saldo Credor Apurado no Mes anterior
										//4-Total de debitos acumulados
	//
	If ("Estimativa"$aWizard[2][3])
		If (!"Decendial"$aWizard[2][12]) 
		    //1-Debito Apurado no Mes
			aValor[1]	:=	Iif (aScan (aApICMMe, {|a| a[1]=="004"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[1]=="004"})][3], 0)
			//2-Credito Apurado no Mes
			aValor[2]	:=	Iif (aScan (aApICMMe, {|a| a[1]=="008"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[1]=="008"})][3], 0)
			//3-Saldo Credor Apurado no Mes anterior
			aValor[3]	:=	Iif (aScan (aApICMMe, {|a| a[1]=="009"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[1]=="009"})][3], 0)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PRIMEIRO DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//1-Debito Apurado no Mes
			aValor[1]	:=	Iif (aScan (aApICM1D, {|a| a[1]=="004"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[1]=="004"})][3], 0)
			//2-Credito Apurado no Mes
			aValor[2]	:=	Iif (aScan (aApICM1D, {|a| a[1]=="008"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[1]=="008"})][3], 0)
			//3-Saldo Credor Apurado no Mes anterior
			aValor[3]	:=	Iif (aScan (aApICM1D, {|a| a[1]=="009"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[1]=="009"})][3], 0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SEGUNDO  DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//1-Debito Apurado no Mes
			aValor[1]	+=	Iif (aScan (aApICM2D, {|a| a[1]=="004"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[1]=="004"})][3], 0)
			//2-Credito Apurado no Mes
			aValor[2]	+=	Iif (aScan (aApICM2D, {|a| a[1]=="008"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[1]=="008"})][3], 0)
			//3-Saldo Credor Apurado no Mes anterior
			aValor[3]	+=	Iif (aScan (aApICM2D, {|a| a[1]=="009"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[1]=="009"})][3], 0)
		EndIf
		//4-Total de debitos acumulados
		aValor[4]	:=	aValor[2]+aValor[3]
		//Debito Apurado no Mes
		AtuVlrDime (.F., "29", "08", "010", aValor[1], 2)
		//Total de debitos acumulados
		AtuVlrDime (.F., "29", "08", "980", aValor[1], 2)
		//Credito Apurado no Mes
		AtuVlrDime (.F., "29", "08", "030", aValor[2], 2)
		//Saldo Credor Apurado no Mes anterior
		AtuVlrDime (.F., "29", "08", "040", aValor[3], 2)
		//Total de debitos acumulados
		AtuVlrDime (.F., "29", "08", "990", aValor[4], 2)
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME30    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 30 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³         CALCULO DO IMPOSTO A PAGAR OU SALDO CREDOR         ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN -> Valor a ser retornado para o quadro 45 item 010.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME30 (aWizard, aLog, aApICMMe, aApICM1D, aApICM2D,aCalcPres)
	Local	aValor		:=	Array (30)	//1-Subtotal de debitos
										//2-Complemento de debito por mudanca de regime de apuracao
										//3-Saldos devedores recebidos de estabelecimentos consolidados
										//4-Creditos transferidos para outros contribuintes
										//5-Total dos debitos
										//6-subtotal de creditos
										//7-Complemento de credito por mudanca de regime de apuracao
										//8-Credito por pagamento indevido em periodo anterior
										//9-Saldos credores recebidos de estabelecimentos consolidados
										//10-Creditos recebidos por transferencias de outros contribuintes
										//11-Total de creditos
										//12-Imposto do 1. decendio
										//13-Imposto do 2. decendio
										//14-Total de ajustes
										//15-Saldo devedor (5-(11+14))
										//16-Saldo devedor transferido ao estabelecimento consolidador
										//17-Imposto a recolher (15-16)
										//18-Saldo credor ((11+14)-5)
										//19-Saldo credor transferido ao estabelecimentos consolidador
										//20-Saldo credor para o mes seguinte
										//21-Saldo credor transferivel relativo a exportacao
										//22-Saldo credor transferivel relativo a saidas isentas
										//23-Saldo credor transferivel relativo a saidas diferidas
										//24-Saldo credor relativo a outros creditos
										//25-Antecipação Combustiveis liquidos e gasosos
										//26-Crédito informado no DCIP
										//27-Segregação dos Débitos Relativos às Saídas com Crédito Presumido em Substituição aos Créditos pelas Entradas 076
										//28-Segregação do Crédito Presumido Utilizado em Substituição aos Créditos pelas Entradas 036
										//29-Segregação do Crédito Decorrente do Pagamento Antecipado do ICMS Devido na Saída Subsequente à Importação, com Utilização de Crédito Presumido 037
										//30-Segregação de outros créditos permitidos para compensar com o débito pela utilização do crédito presumido (ACRESCIDO – Atualização 24/05/17)
	Local	nSldCrAnt	:= 0
	Local	ntranscred	:= 0
	Local 	nAjuQd25	:= 0 //Valor de ajuste do totalizador do quadro 25, subtração de valores.									
	aFill (aValor, 0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para todos os tipos de apuracao e declaracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !("Sem movimentos e sem saldo"$(Alltrim(aWizard[2][9])))
	If !(lSimples .And. (("ME (Microempresa)"$aWizard[2][4]) .Or. ("EPP (Empresa Peq. Porte)"$aWizard[2][4])))
		If ("Bares"$aWizard[2][3])
			aValor[1]	:=	AtuVlrDime (.T., "28", "07", "980")
			aValor[6]	:=	AtuVlrDime (.T., "28", "07", "990")
		Else
			If (!"Decendial"$aWizard[2][12]) 
				aValor[2]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="30011"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="30011"})][3], 0)
				aValor[3]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="30020"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="30020"})][3], 0)
				aValor[7]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="30051"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="30051"})][3], 0)
				aValor[8]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="30052"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="30052"})][3], 0)
				aValor[9]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="30060"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="30060"})][3], 0)
				aValor[16]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="30130"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="30130"})][3], 0)
				aValor[19]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="30150"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="30150"})][3], 0)
				nSldCrAnt	:=	Iif (aScan (aApICMMe, {|a| a[1]=="009"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[1]=="009"})][3], 0)
				aValor[27]	:=	IF(val(aWizard[24][02])>0,val(aWizard[24][02]),Iif (aCalcPres[8]<>0, aCalcPres[8], 0))
				aValor[28]	:=	IF(val(aWizard[24][03])>0,val(aWizard[24][03]),Iif (aCalcPres[9]<>0, aCalcPres[9], 0))
				aValor[29]	:=	IF(val(aWizard[24][08])>0,val(aWizard[24][08]),Iif (aScan (aApICMMe, {|a| a[4]=="30037"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="30037"})][3], 0))
				aValor[30]	:=	IF(val(aWizard[24][04])>0,val(aWizard[24][04]),Iif (aCalcPres[7]<>0, aCalcPres[7], 0))
				nAjuQd25	+= Iif (aScan (aApICMMe, {|a| a[4]=="30036"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="30036"})][3], 0)
				nAjuQd25	+= Iif (aScan (aApICMMe, {|a| a[4]=="30038"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="30038"})][3], 0)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³valores da apuracao ICMS do 1 decendio³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aValor[2]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="30011"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="30011"})][3], 0)
				aValor[3]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="30020"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="30020"})][3], 0)
				aValor[7]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="30051"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="30051"})][3], 0)
				aValor[8]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="30052"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="30052"})][3], 0)
				aValor[9]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="30060"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="30060"})][3], 0)
				aValor[16]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="30130"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="30130"})][3], 0)
				aValor[19]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="30150"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="30150"})][3], 0)
				nSldCrAnt	:=	Iif (aScan (aApICM1D, {|a| a[1]=="009"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[1]=="009"})][3], 0)				
				aValor[27]	:=	IF(val(aWizard[24][02])>0,val(aWizard[24][02]),Iif (aCalcPres[8]<>0, aCalcPres[8], 0))
				aValor[28]	:=	IF(val(aWizard[24][03])>0,val(aWizard[24][03]),Iif (aCalcPres[2]<>0, aCalcPres[2], 0))
				aValor[29]	:=	IF(val(aWizard[24][08])>0,val(aWizard[24][08]),Iif (aScan (aApICM1D, {|a| a[4]=="30037"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="30037"})][3], 0))
				aValor[30]	:=	IF(val(aWizard[24][04])>0,val(aWizard[24][04]),Iif (aCalcPres[7]<>0, aCalcPres[7], 0))
				nAjuQd25	+= Iif (aScan (aApICM1D, {|a| a[4]=="30036"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="30036"})][3], 0)
				nAjuQd25	+= Iif (aScan (aApICM1D, {|a| a[4]=="30038"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="30038"})][3], 0)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³valores da apuracao ICMS do 2 decendio³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aValor[2]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="30011"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="30011"})][3], 0)
				aValor[3]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="30020"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="30020"})][3], 0)
				aValor[7]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="30051"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="30051"})][3], 0)
				aValor[8]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="30052"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="30052"})][3], 0)
				aValor[9]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="30060"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="30060"})][3], 0)
				aValor[16]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="30130"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="30130"})][3], 0)
				aValor[19]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="30150"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="30150"})][3], 0)
				nSldCrAnt	+=	Iif (aScan (aApICM2D, {|a| a[1]=="009"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[1]=="009"})][3], 0)				
				aValor[27]	:=	IF(val(aWizard[24][02])>0,val(aWizard[24][02]),Iif (aCalcPres[8]<>0, aCalcPres[8], 0))
				aValor[28]	:=	IF(val(aWizard[24][03])>0,val(aWizard[24][03]),Iif (aCalcPres[2]<>0, aCalcPres[2], 0))
				aValor[29]	+=	IF(val(aWizard[24][08])>0,val(aWizard[24][08]),Iif (aScan (aApICM2D, {|a| a[4]=="30037"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="30037"})][3], 0))
				aValor[30]	:=	IF(val(aWizard[24][04])>0,val(aWizard[24][04]),Iif (aCalcPres[7]<>0, aCalcPres[7], 0))
				nAjuQd25	+= Iif (aScan (aApICM2D, {|a| a[4]=="30036"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="30036"})][3], 0)
				nAjuQd25	+= Iif (aScan (aApICM2D, {|a| a[4]=="30038"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="30038"})][3], 0)

			EndIf 		
			
		    aValor[4]	:=	AtuVlrDime (.T., "42", "42", "990")	//Estes debitos devem ser transportados do registro 42 nesta coluna (aValor[2]). Ja esta acumulado nos 2 decendios ou mensal

		    aValor[10]	:=	AtuVlrDime(.T., "46", "46",,,2,,1)	//Quando se tratar de Créditos Recebidos por Transferencia de Outros Contribuintes - Registro 46, o mesmo
																//  pode conter diversos lancamentos com diversos protocolos, 
																//  onde deverao ser aglutinados neste item.

			aValor[10]	+=	AtuVlrDime(.T., "46", "46",,,2,,3)	//Quando se tratar de Créditos Recebidos por Transferencia de Outros Contribuintes - Registro 46, o mesmo
																//  pode conter diversos lancamentos com diversos protocolos, 
																//  onde deverao ser aglutinados neste item.
			
			aValor[26]	:=	AtuVlrDime(.T., "46", "46",,,2,,14)	//Quando se tratar de Regimes especiais - Registro 46, o mesmo
																//  pode conter diversos lancamentos com diversos protocolos, 
																//  onde deverao ser aglutinados neste item.
		    
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizo o registro 25, pois ele considerou os lancamentos do quadro 30 como outros debitos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/* A acao abaixo necessita ser realizada em decorrencia dos valores somados na composicao do registro 25 Quadro 04.
			
			Alguns valores do item 070 do Registro 25 devem ser utilizados pelo item 020 do registro 30, portanto eh necessario
			fazer a subtracao abaixo.
			
			Consultar reflexo neste codigo fonte utilizando a palavra: DIME_RELAC_001
			*/
			AtuVlrDime (.F., "25", "04", "070", aValor[2]+aValor[3]+aValor[4]+aValor[19], 3)
			AtuVlrDime (.F., "25", "04", "990", aValor[2]+aValor[3]+aValor[4]+aValor[19]+nAjuQd25, 3)
			
			/*
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizo o registro 26, pois ele considerou os lancamentos do quadro 30 como outros creditos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  StrZero (Month (MV_PAR02), 2)+StrZero (Year (MV_PAR02), 4) < '042008'
				AtuVlrDime (.F., "26", "05", "160", aValor[10]+aValor[7]+aValor[8]+aValor[9]+aValor[16], 3)
			EndIf
			AtuVlrDime (.F., "26", "05", "990", aValor[10]+aValor[7]+aValor[8]+aValor[9]+aValor[16], 3)
			*/
			//Quando se tratar de Saida Regime Estimativa Fiscal devo gerar o Registro 30 com as informacoes do registro 29.
			If ("Estimativa"$aWizard[2][3])
				//Utilizo os valores atualizados
				aValor[1]	:=	AtuVlrDime (.T., "29", "08", "980")
				aValor[6]	:=	AtuVlrDime (.T., "29", "08", "990")
			Else
				//Utilizo os valores atualizados
				aValor[1]	:=	AtuVlrDime (.T., "25", "04", "990")
				aValor[6]	:=	AtuVlrDime (.T., "26", "05", "990")
			EndIf
		EndIf
    Else
		aValor[1]	:=	AtuVlrDime (.T., "27", "06", "040")
		aValor[6]	:=	AtuVlrDime (.T., "27", "06", "990")
    EndIf
	
    //5-Total dos debitos
    aValor[5]	:=	aValor[1]+aValor[2]+aValor[3]+aValor[4]+aValor[28]+aValor[29]+aValor[30]
    //11-Total de creditos
    aValor[11]	:=	aValor[6]+aValor[7]+aValor[8]+aValor[9]+aValor[10]+aValor[26]+aValor[27]
    //12-Imposto/Antecipacoes do primeiro decendio - informado na Wizard
    aValor[12]  := Val(aWizard[16][1])
    //13-Imposto/Antecipacoes do primeiro decendio - informado na Wizard
    aValor[13]  := Val(aWizard[16][2]) 
    //25-Antecipação de Combustiveis liquidos 
    aValor[25]  := Val(aWizard[16][3])
    //14-Total de ajustes
    aValor[14]	:=	aValor[12]+aValor[13]+aValor[25]
    //15-Saldo devedor (5-(11+14))
    aValor[15]	:=	aValor[5]-(aValor[11]+aValor[14])
    //17-Imposto a recolher (15-16)
    aValor[17]	:=	aValor[15]-aValor[16]
    //18-Saldo credor ((11+14)-5)
    aValor[18]	:=	(aValor[11]+aValor[14])-aValor[5]
	//20-Saldo credor para o mes seguinte (18-19)
	aValor[20]	:=	aValor[18]-aValor[19]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente quando houver saldo credor envio as informacoes abaixo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (aValor[20]>0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para satisfazer as condicoes dos itens D, E e F implementado pelo SRF 021/2006 para o                                 ³
		//³     Registro 41. Sao elas:                                                                                           ³
		//³1)Se a soma dos itens 41960, 41970 e 41980 for menor ou igual a soma dos                                              ³
		//³   itens 30160, 30170 e 30180, transporto os mesmos valores dos itens 41960, 41970 e 41980.                           ³
		//³2)Se a soma dos itens 41960, 41970 e 41980 for maior que a soma dos                                                   ³
		//³   itens 30160, 30170 e 30180, transporto os mesmos valores dos itens 41960, 41970 e 41980,                           ³
		//³   reduzindo um dos valores de forma que não ultrapasse o item 30998. Qual valor reduzir fica a cargo do contribuinte.³
		//³3)Se não houver item 30998 (Saldo credor), os itens 30160, 30170, 30180 e 30190                                       ³
		//³   não devem ser enviados, mesmo que os itens 41960, 41970 e 41980 apresentem saldos.                                 ³
		//³                                                                                                                      ³
		//³OBSERVACAO                                                                                                            ³
		//³Apesar do layout comentar sobre esta Regra, o validador somente aceita os lancamentos quando haver saldo credor para o³
		//³ o periodo. Sendo assim, sempre o valor lancado para o quadro 41 serah menor ou igual ao Saldo Credor do registro 30. ³
		//³Exemplo: Como somente posso fazer lancamentos se houver Saldo Credor no registro 30, suponhamos ter R$500,00 de Saldo ³
		//³ Credor por entradas, onde farei os lancamentos no assistente para os itens 120, 130 e 140 no valor de R$300,00 (100  ³
		//³ pra cada), o total permanecera R$500,00 onde esses R$300,00 lancados identificam valores entre as entradas, sendo    |
		//| assim, os valores do Registro 41 (Itens 960, 970 e 980) somados (R$300,00) eh menor que R$500,00 (Total Saldo) Credor³
		//³ do Registo 30 item 998).                                                                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AtuVlrDime (.T., "41", "41", "960")+;
			AtuVlrDime (.T., "41", "41", "970")+;
			AtuVlrDime (.T., "41", "41", "980")<=aValor[20]
			//21-Saldo credor de créditos relativos a exportacao
			aValor[21]	:=	AtuVlrDime (.T., "41", "41", "960")
			//22-Saldo credor de créditos relativos a saidas isentas
			aValor[22]	:=	AtuVlrDime (.T., "41", "41", "970")
			//23-Saldo credor de créditos relativos a saidas diferidas
			aValor[23]	:=	AtuVlrDime (.T., "41", "41", "980")			
		Else
			//21-Saldo credor de créditos relativos a exportacao	
			aValor[21]	:=	Iif(Empty(aValor[4]),aWizard[8][5],(aWizard[8][1] * aWizard[8][5]) / 100)
			AtuVlrDime (.F., "41", "41", "960", aWizard[8][8] + ((aWizard[8][1] * aWizard[8][5]) / 100), 1)		//Como devo manipular os valores quando for superior ao saldo credor, devo tambem alterar o totalizador 960 do quadro 41
			//22-Saldo credor de créditos relativos a saidas isentas
			aValor[22]	:=	(aWizard[8][1]*aWizard[8][3]/100)+aValor[16]+aWizard[8][13]
			AtuVlrDime (.F., "41", "41", "970", ((aWizard[8][1]*aWizard[8][3]/100)+aValor[16]+aWizard[8][13]), 1)		//Como devo manipular os valores quando for superior ao saldo credor, devo tambem alterar o totalizador 970 do quadro 41
			//23-Saldo credor de créditos relativos a saidas diferidas
			aValor[23]	:=	aWizard[8][7]
			AtuVlrDime (.F., "41", "41", "980", aValor[23], 1)		//Como devo manipular os valores quando for superior ao saldo credor, devo tambem alterar o totalizador 980 do quadro 41
		EndIf
		//24-Saldo credor de outros creditos
		aValor[24]	:=	aValor[20]-(aValor[21]+aValor[22]+aValor[23])
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Geracao do Arquivo de LOG.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAddLog ("30130", 1, aValor[16], "É estabelecimento consolidado", aWizard[2][5],, @aLog)
	aAddLog ("30150", 1, aValor[19], "É estabelecimento consolidado", aWizard[2][5],, @aLog)
	aAddLog ("30020", 1, aValor[3], "consolidador", aWizard[2][5],, @aLog)
	aAddLog ("30060", 1, aValor[9], "consolidador", aWizard[2][5],, @aLog)
	aAddLog ("30998", 1, aValor[20],,, aValor, @aLog)
	aAddLog ("30998", 2, aValor[20],,, aValor, @aLog)
	aAddLog ("30999", 1, aValor[17], "É estabelecimento consolidado", aWizard[2][5],, @aLog)
	//
	//Subtotal de debitos
	AtuVlrDime (.F., "30", "09", "010", aValor[1], 2)
	//
	//Complemento de debitos por mudanca de regime de apuracao
	AtuVlrDime (.F., "30", "09", "011", aValor[2], 2)
	//    	
	//Saldo devedores recebidos de estabelecimentos consolidados
	AtuVlrDime (.F., "30", "09", "020", aValor[3], 2)
	//
	//Creditos transferidos para outros contribuintes
	AtuVlrDime (.F., "30", "09", "030", aValor[4], 2)
	//
	AtuVlrDime (.F., "30", "09", "036", aValor[28], 2)
	//Segregação do Crédito Presumido Utilizado em Substituição aos Créditos pelas Entradas (Redação dada pelo Art. 3º da Portaria SEF nº 070/17 - Efeitos fatos geradores a partir da referência abril/2017)
	AtuVlrDime (.F., "30", "09", "037", aValor[29], 2)
	//Segregação do Crédito Decorrente do Pagamento Antecipado do ICMS Devido na Saída Subsequente à Importação, com Utilização de Crédito Presumido (Redação dada pelo Art. 3º da Portaria SEF nº 070/17 - Efeitos fatos geradores a partir da referência abril/2017)
	//Total de debitos
	AtuVlrDime (.F., "30", "09", "038", aValor[30], 2)
	//Segregação de outros créditos permitidos para compensar com o débito pela utilização do crédito presumido (ACRESCIDO – Atualização 24/05/17)
	//
	AtuVlrDime (.F., "30", "09", "040", aValor[5], 2)
	//
	//Subtotal de creditos
	AtuVlrDime (.F., "30", "09", "050", aValor[6], 2)
	//
	//Saldos credores recebidos de estabelecimentos consolidados
	AtuVlrDime (.F., "30", "09", "060", aValor[9], 2)
	//	
	//Creditos recebidos de transferencias por outros contribuintes
	AtuVlrDime (.F., "30", "09", "070", aValor[10], 2)
	//	
	//Credito informado no DCIP
	AtuVlrDime (.F., "30", "09", "075", aValor[26], 2)
	//Segregação dos Débitos Relativos às Saídas com Crédito Presumido em Substituição aos Créditos pelas Entradas
	AtuVlrDime (.F., "30", "09", "076", aValor[27], 2)
	//
	//Total de creditos
	AtuVlrDime (.F., "30", "09", "080", aValor[11], 2)
	//
	//Imposto do 1. decendio
	AtuVlrDime (.F., "30", "09", "090", aValor[12], 2)
	//
	//Imposto do 2. decendio
	AtuVlrDime (.F., "30", "09", "100", aValor[13], 2)
	//
	//Antecipação Combustiveis liquidos e gasosos
	AtuVlrDime (.F., "30", "09", "105", aValor[25], 2)
	//
	//Total de ajustes da apuracao decendial
	AtuVlrDime (.F., "30", "09", "110", aValor[14], 2)
	//
	//Saldo devedor
	/*a) Item 120 - Saldo Devedor: preencher com o valor da diferença entre o 
	item 40 (Total de débitos) e o somatório dos itens 80 (Total de créditos) e 
	110 (Total de Ajustes da Apuração Decendial), se o total de débitos for maior 
	que o somatório ou igual a 0 (zero). Quando o resultado for igual a 0 (zero) preencher com 0 (zero);*/
	IF aValor[15] >=0
		AtuVlrDime (.F., "30", "09", "120", aValor[15], 2)
	Endif	
	//
	If !("consolidada"$aWizard[2][5]) .And. !("consolidador"$aWizard[2][5])
	//Soh deve gerar se o estabelecimento for consolidado
		//Saldo devedor transferido ao estabelecimento consolidador
		AtuVlrDime (.F., "30", "09", "130", aValor[16], 2)
	EndIf
	/* Se for estabelecimento consolidado diferença entre o item 120 
		(Saldo Devedor) e o 130 (Saldo Devedor Transferido ao Estabelecimento Consolidador),
		Se não o mesmo valor do item 120 (Saldo Devedor), quando se tratar de estabelecimento
		 único ou empresa que não adote apuração consolidada, inclusive se o valor do item 120
		(Saldo Devedor) for igual a zero.	*/	
	ntranscred := Len(aWizard[2][6])	
	//Imposto a recolher
	If Substr(Alltrim(aWizard[2][5]),3,27) == "estabelecimento consolidado" 
		AtuVlrDime (.F., "30", "09", "999", aValor[17], 2)
	ElseIf aValor[15] >=0 //(aValor[5] > 0 .And. aValor[11] > 0) // Quando apuração não consolidada deve imprime registro 999 mesmo com 0		
		/*o mesmo valor do item 120 (Saldo Devedor), quando se tratar de estabelecimento 
		único ou empresa que não adote apuração consolidada, 
		inclusive se o valor do item 120 (Saldo Devedor) for igual a zero.*/
		AtuVlrDime (.F., "30", "09", "999", aValor[15], 2)
	EndIf
	//Saldo credor
	AtuVlrDime (.F., "30", "09", "140", aValor[18], 2)
	//
	//Saldo credor transferido ao estabelecimento consolidador
	AtuVlrDime (.F., "30", "09", "150", aValor[19], 2)
	//
	//Saldo credor para o periodo seguinte
	AtuVlrDime (.F., "30", "09", "998", aValor[20], 2)
	//
	//Saldo credor de créditos relativos a exportacao
	AtuVlrDime (.F., "30", "09", "160", aValor[21], 2)
	//
	//Saldo credor de créditos relativos a saidas isentas
	AtuVlrDime (.F., "30", "09", "170", aValor[22], 2)
	//
	//Saldo credor de créditos relativos a saidas diferidas
	AtuVlrDime (.F., "30", "09", "180", aValor[23], 2)
	//
	//Saldo credor de outros creditos
	AtuVlrDime (.F., "30", "09", "190", aValor[24], 2)
EndIf	
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME31    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 31 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³                  DEBITOS ESPECIFICOS                       ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.t.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME31 (aWizard, aApICMMe, aApICM1D, aApICM2D)
	Local	nI		:=	1
	Local	aGNRE	:=	{}
	Local	aValor	:=	{0,0,0,0,0}		//1-Debito relativo a operacao de importacao
										//2-Debito relativo a aquisicao de atacadistas de outras UFs
										//3-Debito por responsabilidade tributaria
										//4-Outros debitos por ocasiao do fato gerador
										//5-total de debitos
	If (!"Decendial"$aWizard[2][12]) 
	    //1-Debito relativo a operacao de importacao
	    aValor[1]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="31010"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="31010"})][3], 0)	    
	    aAddGNRE (@aGNRE, aApICMMe, "31010")
	    //2-Debito relativo a aquisicao de atacadistas de outras UFs
	    aValor[2]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="31020"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="31020"})][3], 0)
	    aAddGNRE (@aGNRE, aApICMMe, "31020")
	    //3-Debito por responsabilidade tributaria
	    aValor[3]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="31030"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="31030"})][3], 0)
		aAddGNRE (@aGNRE, aApICMMe, "31030")
	    //4-Outros debitos por ocasiao do fato gerador
	    aValor[4]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="31040"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="31040"})][3], 0)
		aAddGNRE (@aGNRE, aApICMMe, "31040")
	    //5-total de debitos
	    aValor[5]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="31050"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="31050"})][3], 0)
		aAddGNRE (@aGNRE, aApICMMe, "31050")
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³PRIMEIRO DECENDIO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    //1-Debito relativo a operacao de importacao 
	    aValor[1]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="31010"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="31010"})][3], 0)
	    aAddGNRE (@aGNRE, aApICM1D, "31010")
	    //2-Debito relativo a aquisicao de atacadistas de outras UFs
	    aValor[2]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="31020"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="31020"})][3], 0)
	    aAddGNRE (@aGNRE, aApICM1D, "31020")
	    //3-Debito por responsabilidade tributaria
	    aValor[3]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="31030"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="31030"})][3], 0)
	    aAddGNRE (@aGNRE, aApICM1D, "31030")
	    //4-Outros debitos por ocasiao do fato gerador
	    aValor[4]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="31040"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="31040"})][3], 0)
	    aAddGNRE (@aGNRE, aApICM1D, "31040")
	    //5-total de debitos
	    aValor[5]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="31050"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="31050"})][3], 0)
	    aAddGNRE (@aGNRE, aApICM1D, "31050")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SEGUNDO  DECENDIO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    //1-Debito relativo a operacao de importacao
	    aValor[1]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="31010"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="31010"})][3], 0)
	    aAddGNRE (@aGNRE, aApICM2D, "31010")	//Apesar de estar acumulando nao importa, o que preciso mesmo eh do codigo de receita + classe vencimento
	    //2-Debito relativo a aquisicao de atacadistas de outras UFs
	    aValor[2]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="31020"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="31020"})][3], 0)
	    aAddGNRE (@aGNRE, aApICM2D, "31020")	//Apesar de estar acumulando nao importa, o que preciso mesmo eh do codigo de receita + classe vencimento
	    //3-Debito por responsabilidade tributaria
	    aValor[3]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="31030"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="31030"})][3], 0)
	    aAddGNRE (@aGNRE, aApICM2D, "31030")	//Apesar de estar acumulando nao importa, o que preciso mesmo eh do codigo de receita + classe vencimento
	    //4-Outros debitos por ocasiao do fato gerador	
	    aValor[4]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="31040"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="31040"})][3], 0)
	    aAddGNRE (@aGNRE, aApICM2D, "31040")	//Apesar de estar acumulando nao importa, o que preciso mesmo eh do codigo de receita + classe vencimento
	    //5-total de debitos
	    aValor[5]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="31050"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="31050"})][3], 0)
	    aAddGNRE (@aGNRE, aApICM2D, "31050")	//Apesar de estar acumulando nao importa, o que preciso mesmo eh do codigo de receita + classe vencimento
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PEGANDO AS INFORMACOES PREENCHIDAS NO WIZARD, CASO TENHA NA APURACAO E NO WIZARD, ACUMULO-AS.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aValor[1]	+=	Val (aWizard[15][1])
	aValor[2]	+=	Val (aWizard[15][2])
	aValor[3]	+=	Val (aWizard[15][3])
	aValor[4]	+=	Val (aWizard[15][4])
	aValor[5]	+=	Val (aWizard[15][5])
	//
	//1-Debito relativo a operacao de importacao
	AtuVlrDime (.F., "31", "10", "010", aValor[1], 2)
	//
	//2-Debito relativo a aquisicao de atacadistas de outras UFs
	AtuVlrDime (.F., "31", "10", "020", aValor[2], 2)
	//
	//3-Debito por responsabilidade tributaria
	AtuVlrDime (.F., "31", "10", "030", aValor[3], 2)
	//
	//4-Outros debitos por ocasiao do fato gerador
	AtuVlrDime (.F., "31", "10", "040", aValor[4], 2)
	//
	//5-Outros debitos eventuais
	AtuVlrDime (.F., "31", "10", "050", aValor[5], 2)
	//
	//5-total de debitos
	For nI := 1 To Len (aValor)
		AtuVlrDime (.F., "31", "10", "990", aValor[nI], 2)
	Next (nI)
Return (aGNRE)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME32    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 32 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³        INFORMACOES SOBRE SUBSTITUICAO TRIBUTARIA           ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente no que se refere a ST.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME32 (aWizard,aCalcRessa)
	Local	aValor		:=	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	Local	aApICMMe	:=	FisApur ("ST", Year (MV_PAR02), Month (MV_PAR02), 3, 0, "*", .F., {}, 1, .F., "")
	Local	nVal105		:=	0
	Local	nI			:=	0	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para Substituto tributario ou substituido        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len (aProt)
		If	aProt [nI][04] == '1'
	   		nVal105	+= 	aProt [nI][02]	
		EndIf
	Next (nI)
	If (("Sim"$aWizard[2][10]) .Or.("Substitu"$aWizard[2][10]))
		If  StrZero (Month (MV_PAR02), 2) < '08' .AND. StrZero (Year (MV_PAR02), 4) < '2013'
			aValor[01]	:=	Val (aWizard[14][01])
			aValor[02]	:=	Val (aWizard[14][02])
			aValor[03]	:=	Val (aWizard[14][03])
			aValor[04]	:=	Val (aWizard[14][04])
			aValor[05]	:=	Val (aWizard[14][05])
			aValor[10]	:=	Val (aWizard[14][10])
			aValor[11]	:=	Val (aWizard[14][11])
			aValor[12]	:=	Val (aWizard[14][12])			
		EndIf
		aValor[06]	:=	Val (aWizard[14][06])
   		aValor[21]  :=	Val (aWizard[14][07]) 			
		aValor[07]	:=	Val (aWizard[14][08]) 
		aValor[08]	:=	aValor[07]
		aValor[09]	:=	Val (aWizard[14][09])
		aValor[22]	:=	nVal105
		aValor[13]	:=	aValor[09]+aValor[10]+aValor[11]+aValor[12]+aValor[22]
		If  StrZero (Month (MV_PAR02), 2)+StrZero (Year (MV_PAR02), 4) < '022010'
			aValor[14]	:=	Val (aWizard[14][13])
			aValor[15]	:=	Val (aWizard[14][14])
        EndIf		
		aValor[17]	:=	Val (aWizard[14][15])		
		aValor[16]	:=	aValor[14]+aValor[15]+aValor[17]	//Total decendios
		If Val (aWizard[14][17]) > 0
	   		aValor[20]	:=	Val (aWizard[14][18])
	   	else
	   	    aValor[20] := Iif (aScan (aApICMMe, {|a| a[4]=="30020"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="30020"})][3], 0)
	   	endif 		
		//	
		//Valor dos produtos
		//AtuVlrDime (.F., "32", "11", "010", aValor[1], 2)
		//
		//Valor do IPI
		//AtuVlrDime (.F., "32", "11", "020", aValor[2], 2)
		//
		//Despesas acessorias
		AtuVlrDime (.F., "32", "11", "030", aValor[3], 2)
		//
		//Base de calculo do ICMS proprio
		//AtuVlrDime (.F., "32", "11", "040", aValor[4], 2)
		//
		//ICMS proprio
		//AtuVlrDime (.F., "32", "11", "050", aValor[5], 2)
		//
		//Base de calculo ST
		AtuVlrDime (.F., "32", "11", "060", aValor[6], 2)
		//
		//Debitos por ocasião do fato gerador
		AtuVlrDime (.F., "32", "11", "065", aValor[21], 2)       
		//
		//ICMS ST
		AtuVlrDime (.F., "32", "11", "070", aValor[7], 2)
		//
   	//Saldo devedor
		If (("consolidador" $ aWizard[2][5]) .and. aValor[20] > 0  .and. "Sim" $ aWizard[14][16])           
			//Saldos devedores recebidos de estabelecimentos consolidados
			AtuVlrDime (.F., "32", "11", "075", aValor[20], 2)
			aValor[08] := aValor[08] + aValor[20]    
		EndIf
		//Total dos Debitos
		AtuVlrDime (.F., "32", "11", "080", aValor[8], 2)
		//
		//Saldo credor do periodo anterior
		AtuVlrDime (.F., "32", "11", "090", aValor[9], 2)
		//
		//Devolucao / Desfazimento mercadorias com ST 
		AtuVlrDime (.F., "32", "11", "100", aValor[10], 2)
		// 
		//Creditos declarados no DCIP
		AtuVlrDime (.F., "32", "11", "105", aValor[22], 2)
		//		
		//Ressarcimento ICMS/ST
		AtuVlrDime (.F., "32", "11", "110", aValor[11], 2)
		//
		
		//Ressarcimento do ICMS substituição tributária acobertado por NF-e
		if aCalcRessa[1]<>0 .and. (!empty(aProcess[1][1]) .and. aScan(aProcess,{|a| a[4]=="A"})<>0 ) //Precisa ter um processo vinculado para gerar o 115, e não pode ser Manual. Tem q ser gerado de Nota.
			AtuVlrDime (.F., "32", "11", "115", aCalcRessa[1], 2)
		endif

		//Outros Creditos
		AtuVlrDime (.F., "32", "11", "120", aValor[12], 2)
		//
		//Total de Creditos
		AtuVlrDime (.F., "32", "11", "130", aValor[13], 2)
		//
		//1. Decendio
		AtuVlrDime (.F., "32", "11", "140", aValor[14], 2)
		//
		//2. Decendio
		AtuVlrDime (.F., "32", "11", "150", aValor[15], 2)
		//
		//Antecipações Combustiveis liquidos e gasosos
		AtuVlrDime (.F., "32", "11", "155", aValor[17], 2)
		//
		//Total de ajustes Decendiais
		AtuVlrDime (.F., "32", "11", "160", aValor[16], 2)
		//
		//Saldo devedor
		If (aValor[08]>(aValor[13]+aValor[16]))
			AtuVlrDime (.F., "32", "11", "170", aValor[8]-(aValor[13]+aValor[16]), 2)
			aValor[18] := aValor[8]-(aValor[13]+aValor[16])
		Else 
			AtuVlrDime (.F., "32", "11", "170", 0, 2)
		EndIf
		If (!("consolidada"$aWizard[2][5]) .And. !("consolidador"$aWizard[2][5]) .and. aValor[18] > 0  .and. "Sim" $ aWizard[14][16])                    
			//                                                                            	
			//Saldo devedor transferido ao estabelecimento consolidador 
			AtuVlrDime (.F., "32", "11", "180", aValor[18], 2)    
		EndIf
		
		// Saldo Credor
		If ((aValor[13]+aValor[16]) > aValor[08])
			AtuVlrDime (.F., "32", "11", "190", (aValor[13]+aValor[16])-aValor[08], 2)
			aValor[19] :=(aValor[13]+aValor[16])-aValor[08]
		EndIf                       
                                                                   
		If (!("consolidada"$aWizard[2][5]) .And. !("consolidador"$aWizard[2][5]).and. aValor[19] > 0 .and. "Sim" $ aWizard[14][17])                       
			//
			//Saldo credor transferido ao estabelecimento consolidador 
			AtuVlrDime (.F., "32", "11", "200", aValor[19], 2)	   
		EndIf

		//Imposto a recolher sobre a substituicao tributaria
		If (("consolidada"$aWizard[2][5]) .Or. ("consolidador"$aWizard[2][5])) //Não imprime registro 999 para consolidado
			If (aValor[08]>(aValor[13]+aValor[16]))
				AtuVlrDime (.F., "32", "11", "999", aValor[8]-(aValor[13]+aValor[16]), 2)
			Else
				AtuVlrDime (.F., "32", "11", "999", 0, 2)
			EndIf
		Else
			AtuVlrDime (.F., "32", "11", "999", 0, 2)
		EndIf 
		
		If ("consolidada"$aWizard[2][5]) .Or. ("consolidador"$aWizard[2][5])                     
			//
			//Saldo credor para o mes seguinte sobre a substituicao tributaria
			If ((aValor[13]+aValor[16]) > aValor[08])
				AtuVlrDime (.F., "32", "11", "998", (aValor[13]+aValor[16])-aValor[08], 2)
			EndIf		
		EndIf
	EndIf	
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME33    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 31 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          DISCRIMINACAO DOS PAGAMENTOS DO IMPOSTO E DEBITOS ESPECIFICOS³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes do FSQUERY no SF6.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±³          ³aGNRE -> Array contendo as informacoes das GNRE.            ³±±
±±³          ³  Codigo Receita-Classe Vencimento - Ex: 1600-10014         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME33 (aWizard, aGNRE)
Local	aSf6 		:=	{"SF6", ""}
Local	cData		:=	""
Local 	aAreaSM0 	:= 	SM0->(GetArea())
Local	cMvEstado	:= GetMv("MV_ESTADO")
Local	nForFilial	:= 0
Local	lF6Acordo	:= SF6->(FieldPos("F6_ACORDO"))> 0

SM0->(dbSetOrder(1))

For nForFilial := 1 To Len( aFilsCalc )

	If !aFilsCalc[ nForFilial, 1 ]
		Loop
	EndIf

	SM0->(dbSeek(cEmpAnt+aFilsCalc[nForFilial][2]))
	If SM0->M0_ESTENT <> 'SC'
		Loop
	EndIf

	cFilAnt 	:= SM0->M0_CODFIL
	cMvEstado	:= 'SC'				// Checou no SM0 se o Estado era SC, o parâmetro não deve ser diferente
	//
	FsQuery(	aSf6,;
				1,;
				"F6_FILIAL='"+xFilial("SF6")+"' AND F6_ANOREF="+StrZero (Year (MV_PAR01), 4)+" AND F6_MESREF="+StrZero (Month (MV_PAR02), 2)+" AND F6_TIPOIMP IN ('1', '3') AND F6_EST = 'SC' ",;
				"F6_FILIAL=='"+xFilial("SF6")+"' .AND. StrZero(F6_ANOREF, 4)=='"+StrZero (Year (MV_PAR01), 4)+"' .AND. StrZero(F6_MESREF, 2)=='"+StrZero(Month (MV_PAR02), 2)+"'.AND. F6_EST == 'SC' .AND. F6_TIPOIMP$'13' ", "F6_TIPOIMP+F6_CODREC")  

	SF6->( DbGotop() )
	//
	Do While !SF6->( Eof() )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando for Substituto Tributario, pego todas as guias (ICMS Normal e ST)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lSubstituto	:=	(("Sim"$aWizard[2][10]) .Or. ("Substitu"$aWizard[2][10]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando NAO for substituto tributario, pego somente as guias de ICMS Normal³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   lNormal		:=	!(("Sim"$aWizard[2][10]) .Or.	("Substitu"$aWizard[2][10])) .And. !"3"$SF6->F6_TIPOIMP
	   //
	   If (lSubstituto) .Or. (lNormal)
				cData		:=	StrZero (Day (SF6->F6_DTVENC), 2)+StrZero (Month (SF6->F6_DTVENC), 2)+StrZero (Year (SF6->F6_DTVENC), 4)
				//
				RecLock ("GNR", .T.)
				GNR->GNR_REGIST	:=	"33"
				GNR->GNR_QUADRO	:=	"12"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Guia gerada para quando houver debitos especificos, quadro 31. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aScan (aGNRE, AllTrim(SF6->F6_NUMERO))<>0 .Or.;   						//Caso esteja lancado na apuracao de icms atraves de subitem
					AllTrim(SF6->F6_NUMERO)$aWizard[15][6] .Or.;			   				//caso esteja informado no wizard o numero da gnre
					AllTrim(SF6->F6_CODREC)+"-"+AllTrim(SF6->F6_CLAVENC)$aWizard[15][7]	//caso esteja informado no wizard o codigo de receita + classe de vencimento
					GNR->GNR_ORIGEM	:=	"3"
				Else
					GNR->GNR_ORIGEM	:=	Iif ("3"$SF6->F6_TIPOIMP, "2", "1")
				EndIf
				GNR->GNR_RECEIT	:=	SF6->F6_CODREC
				GNR->GNR_DATA		:=	cData
				GNR->GNR_VALOR		:=	SF6->F6_VALOR
				GNR->GNR_CLVEN		:=	Left (AllTrim (SF6->F6_CLAVENC), 5)
				GNR->GNR_ACORDO		:=  Iif(lF6Acordo,SF6->F6_ACORDO,"")				
				MsUnLock ()                      
				//
            If GNR->GNR_RECEIT=="1449"
            	Do Case
	            	Case GNR->GNR_CLVEN=="10316"
							AtuVlrDime (.F., "30", "09", "090", GNR->GNR_VALOR, 2)
	            	Case GNR->GNR_CLVEN=="10375"
							AtuVlrDime (.F., "30", "09", "100", GNR->GNR_VALOR, 2)
	            	Case GNR->GNR_CLVEN=="10383"
							AtuVlrDime (.F., "30", "09", "105", GNR->GNR_VALOR, 2)
					EndCase
				Endif            
				//
		EndIf
		//
		SF6->( DbSkip() )
	EndDo
	FsQuery (aSf6, 2,) 
	
Next

RestArea(aAreaSM0)		
Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME34    ³ Autor ³ Cleber Maldonado      ³ Data ³03.02.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 34 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³  DIFERENÇA DE ALÍQUOTA DE OPERAÇÃO INTERESTADUAL A         ³±±
±±³          ³             CONSUMIDOR FINAL - DIFAL                       ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes do CFP e de um FSQUERY no SF3.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME34(aValor)

aValor[3]	+=	aValor[1] + aValor[2]
aValor[7]	+=	aValor[4] + aValor[5] + aValor[6] //Credito Neste período de apuração ou em anterior
	
//Débito da diferença de alíquota devido ao Estado
AtuVlrDime (.F., "34", "13", "010", aValor[1], 2)
//Outros débitos
AtuVlrDime (.F., "34", "13", "020", aValor[2], 2)
//Total de débitos
AtuVlrDime (.F., "34", "13", "040", aValor[3], 2)

//Saldo credor do período anterior sobre a diferença de alíquota
//AtuVlrDime (.F., "34", "13", "050", aValor[4], 2) desabilitado conforme layout 125/12.13

//Devolução de mercadorias e anulações de venda
AtuVlrDime (.F., "34", "13", "060", aValor[5], 2)
//Outros créditos
AtuVlrDime (.F., "34", "13", "070", aValor[6], 2)
//Total de créditos
AtuVlrDime (.F., "34", "13", "090", aValor[7], 2)
//Pagamentos Antecipados
AtuVlrDime (.F., "34", "13", "100", aValor[8], 2)
//Total Pagamentos Antecipados
AtuVlrDime (.F., "34", "13", "110", aValor[9], 2)
//Saldo devedor (Total de Débitos - (Total de Créditos + Total de Pagamentos Antecipados)
AtuVlrDime (.F., "34", "13", "120", aValor[10], 2)
//Saldo devedor a compensar em conta gráfica
AtuVlrDime (.F., "34", "13", "130", aValor[11], 2)
//Saldo Credor (Total de Créditos + Total de ajustes das antecipações combustíveis) - (Total de Débitos)
AtuVlrDime (.F., "34", "13", "150", aValor[12], 2)
//Saldo Credor a compensar em conta gráfica
AtuVlrDime (.F., "34", "13", "160", aValor[13], 2)

//Saldo Credor da diferença de alíquota para o mês seguinte
//AtuVlrDime (.F., "34", "13", "998", aValor[13], 2) desabilitado conforme layout 125/12.13

Return (.T.)


/*/{Protheus.doc} DIME35
DEMONSTRATIVO DA APURAÇÃO DO IMPOSTO DEVIDO PELA APROPRIAÇÃO DE CRÉDITO PRESUMIDO EM SUBSTITUIÇÃO AOS CRÉDITOS PELAS ENTRADAS (DAICP)

@author Alison L. Gonçalves
@since 04/05/2017
@version P11

/*/
Static Function DIME35(aWizard,aCalcPres,aApICMMe, aApICM1D, aApICM2D)
Local aValor	:=	Array(13)
Local lGera		:=	.T.
//falta alterações da Wizard e no registro 30 de amabas as informações nela que deve estar contida.

Afill(aValor,0)

//045 somente para consolidadora
If "consolidador"$aWizard[2][5]
	If (!"Decendial"$aWizard[2][12]) 	
		aValor[12]	:=	IF(val(aWizard[24][05])>0,val(aWizard[24][05]),Iif (aScan (aApICMMe, {|a| a[4]=="35045"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="35045"})][3], 0))
	Else
		aValor[12]	:=	IF(val(aWizard[24][05])>0,val(aWizard[24][05]),Iif (aScan (aApICM1D, {|a| a[4]=="35045"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="35045"})][3], 0))
		aValor[12]	+=	IF(val(aWizard[24][05])>0,val(aWizard[24][05]),Iif (aScan (aApICM2D, {|a| a[4]=="35045"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="35045"})][3], 0))
	Endif
Else
	aValor[12] := 0
Endif

aValor[1]	:=	iIF(val(aWizard[24][01]) > 0,val(aWizard[24][01]),aCalcPres[1])
aValor[2]	:=	AtuVlrDime (.T., "30", "09", "076")
aValor[3]	:=	AtuVlrDime (.T., "30", "09", "036")
aValor[11]	:=  AtuVlrDime (.T., "30", "09", "038")
aValor[4]	:=	Max(Avalor[2]-(Avalor[3]+Avalor[11]),0)
aValor[5]	:=	val(aWizard[24][06]) 
aValor[6]	:=	val(aWizard[24][07])  
aValor[7]	:=	AtuVlrDime (.T., "30", "09", "037")
aValor[8]	:=	aValor[6]+aValor[7]
aValor[13]	:=	Iif(!("consolidador"$aWizard[2][5]),Iif((aValor[4]+aValor[12]+aValor[5])-aValor[8]>0,(aValor[4]+aValor[12]+aValor[5])-aValor[8],0),0) 
If "consolidada"$aWizard[2][5]
	aValor[13] := 0 //0150 somente quando for consolidado
Endif
aValor[10]	:=	IIf((aValor[8]-(aValor[4]+aValor[12]+aValor[5]))>0,aValor[8]-(aValor[4]+aValor[12]+aValor[5]),0)
aValor[9]	:=	IIf((aValor[4]+aValor[12]+aValor[5]-aValor[8]-aValor[13])>0,aValor[4]+aValor[12]+aValor[5]-aValor[8]-aValor[13],0)

if empty(aValor[1]) .and. empty(aValor[2]) .and. empty(aValor[3]) .and. empty(aValor[11])
	lGera:=.F.
endif

IF  aValor[1]+aValor[2]+aValor[3]+aValor[11]+aValor[5]+aValor[6] > 0 //Somente gera registro se houver valor em alguma linha 
	AtuVlrDime (.F., "35", "14", "010", aValor[1], 2)//010
	AtuVlrDime (.F., "35", "14", "020", aValor[2], 2)//020
	AtuVlrDime (.F., "35", "14", "030", aValor[3], 2)//030
	AtuVlrDime (.F., "35", "14", "031", aValor[11],2)//031
	AtuVlrDime (.F., "35", "14", "040", aValor[4], 2,,,lGera)//040
	AtuVlrDime (.F., "35", "14", "045", aValor[12], 2)//045
	AtuVlrDime (.F., "35", "14", "050", aValor[5], 2)//050
	AtuVlrDime (.F., "35", "14", "110", aValor[6], 2)//110
	AtuVlrDime (.F., "35", "14", "120", aValor[7], 2)//120
	AtuVlrDime (.F., "35", "14", "130", aValor[8], 2)//130
	AtuVlrDime (.F., "35", "14", "150", aValor[13], 2)//150
	AtuVlrDime (.F., "35", "14", "199", aValor[9], 2)//199
	AtuVlrDime (.F., "35", "14", "198", aValor[10], 2)//198
Endif

Return (.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME41    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 41 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³           DEMONSTRATIVO DE CREDITOS ACUMULADOS             ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes do CFP e de um FSQUERY no SF3.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME41 (aWizard, aApICMMe, aApICM1D, aApICM2D, aLog)
	Local	nSldCrAnt	:=	0
	Local	aValor		:=	Array(27)	
	Local 	nX			:=	0
	Local	n960deb	:=	0
	Local	n970deb	:=	0
	Local	aArea	:=	{}
	/*1-Item 010 - Percentual do Crédito em Relação ao Total das Aquisições Aplicável no Mês: Informado na Wizard campo “Credito nas aquisições”.
	2-Item 017 - Valor das Operações dos produtos exportados no Mês: Informado na Wizard campo Valor das Operações > Produtos Exportados no Mês.
	3-Item 018 - Valor das Operações dos Produtos com saída isenta ou não tributada no mês.
	4-Item 019 - Valor das Operações dos Produtos com saída diferida ou suspensa no mês.
	5-Item 020 - Mercadorias, Materiais e Serviços Empregados em Produtos Exportados no Mês.
	6-Item 030 - Mercadorias, Materiais e Serviços Empregados em Produtos com Saída Isenta ou Não Tributada no Mês. 
	7-Item 040 - Mercadorias, Materiais e Serviços Empregados em Produtos com Saída Diferida no Mês.
	8-Item 120 - Créditos Gerados por Exportações Ocorridas no Mês.
	9-Item 130 - Créditos Gerados por Saídas Isentas Ocorridas no Mês.
	10-Item 140 - Créditos Gerados por Saídas Diferidas Ocorridas no Mês.
	11-Item 160 – Saldo Credor Transferível do Mês Anterior Relativo à Exportação.
	12-Item 170 – Saldo Credor Transferível do Mês Anterior Relativo a Saídas Isentas.
	13-Item 180 – Saldo Credor Transferível do Mês Anterior Relativo a Saídas Diferidas.
	14-Item 190 – Saldo Credor do Mês Anterior Relativo a Outros Créditos Não Transferível.
	15-Item 217 - Crédito Transferível Autorizado Relativo à Exportação Lançado em DCIP.
	16-Item 218 - Crédito Transferível Autorizado Relativo à Saída Isenta Lançado em DCIP.
	17-Item 219 - Crédito Transferível Autorizado Relativo a Saídas Diferidas Lançado em DCIP.
	18-Item 960 – Saldo Credor Acumulado Relativo à Exportação.
	19-Item 961 - Proporção do Saldo Relativo à Exportação em Relação ao Saldo Acumulado Total.
	20-Item 970 – Saldo Credor Acumulado Relativo à Saída Isenta.
	21-Item 971 - Proporção do Saldo Relativo à Saída Isenta em Relação Saldo Acumulado Total.
	22-Item 980 - Saldo Credor Acumulado Relativo a Saídas Diferidas.
	23-Item 981 - Proporção do Saldo Relativo a Saídas Diferidas em Relação Saldo Acumulado Total.		
	24-Item 991 - Montante dos Saldos Credores Recebidos de Estabelecimentos Consolidados Deduzível do Saldo.
	25-Item 993 - Montante do Crédito Recebido por Transferência de Outros Contribuintes Deduzível do Saldo.
	26-Item 997 – Outras deduções do Saldo Credor.
	27-Item 999 - Total das Deduções Aplicáveis ao Saldo Credor para o Mês Seguinte.*/
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para todos os tipos de declaracao sendo ela do tipo Normal ou Produtor Primario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (("Normal"$aWizard[2][3]) .Or. ("Produtor"$aWizard[2][3]))
		If (!"Decendial"$aWizard[2][12]) 
			//Saldo Credor Apurado do periodo anterior
			nSldCrAnt	:=	Iif (aScan (aApICMMe, {|a| a[1]=="009"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[1]=="009"})][3], 0)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PRIMEIRO DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Saldo Credor Apurado do periodo anterior
			nSldCrAnt	:=	Iif (aScan (aApICM1D, {|a| a[1]=="009"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[1]=="009"})][3], 0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SEGUNDO  DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*Saldo Credor Apurado do periodo anterior*/
			nSldCrAnt	+=	Iif (aScan (aApICM2D, {|a| a[1]=="009"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[1]=="009"})][3], 0)
		EndIf			
		
		
		For nX := 1 To Len(aWizard[8])
			aWizard[8][nX]:= Val(aWizard[8][nX])
		Next	
		
		
		For nX := 1 To Len(aValor)
			IF Empty(aValor[nX])
				aValor[nX]:= 0
			EndIf
		Next	
		
		/*010 - Percentual do crédito em relação ao total das aquisições (média dos últimos 3 meses)*/
		aValor[1]:= aWizard[8][1]
		
		/*017-Produtos exportados no mês */
		aValor[2]:= aWizard[8][2]
		
		/*018-Produtos com saída isenta ou não tributada no mês */
		aValor[3]:= aWizard[8][3]
		
		/*019-Produtos com saída diferida ou suspensa no mês */
		aValor[4]:= aWizard[8][4]
		
		/*020- produtos exportados no mês */
		aValor[5]:= aWizard[8][5]
		
		/*030- produtos com saída isenta ou não tributada no mês */
		aValor[6]:= aWizard[8][6]
		
		/*040- produtos com saída diferida ou suspensa no mês */
		aValor[7]:= aWizard[8][7]
		
		
		/*120-Créditos gerados por exportações ocorridas no mês */
		aValor[8]:= ((aValor[1] * aValor[5]) / 100)
		
		/*130-Créditos gerados por saídas isentas ocorridas no mês */
		aValor[9]:= ((aValor[1] * aValor[6]) / 100) 
		
		/*140-Créditos gerados por saídas diferidas ocorridas no mês */
		aValor[10]:= ((aValor[1] * aWizard[8][7]) / 100) 
		
		
		
		IF (nSldCrAnt>0)	
			/*160-Saldo credor transferível do mês anterior relativo à exportação */
			aValor[11]:= aWizard[8][8]
			
			/*170-Saldo credor transferível do mês anterior relativo a saídas isentas */
			aValor[12]:= aWizard[8][9]
			
			/*180-Saldo credor transferível do mês anterior relativo a saídas diferidas */
			aValor[13]:= aWizard[8][10]
			
			/*190-Saldo credor do mês anterior relativo a outros créditos não transferíveis */
			aValor[14]:= aWizard[8][11]
			
			If(aValor[8] + aValor[9]+ aValor[10] + aValor[11]) > 0
			    aAddLog ("26010", 2, nSldCrAnt,,,aWizard[8], @aLog)  
		    EndIf
		EndIf
		

		/*217-Crédito transferível relativo à exportação autorizado lançado em DCIP */
		aValor[15]:= aWizard[8][12]
		
		/*218-Crédito transferível relativo à saída isenta lançado em DCIP */
		aValor[16]:= aWizard[8][13]
		
		/*219-Crédito transferível a saídas diferidas lançado em DCIP */
		aValor[17]:= aWizard[8][14]
		
		//Art. 1º da Portaria SEF nº 344/14 – Efeitos a partir da referência 09/2014
	    If "Apurou ou reservou"$aWizard[2][6] .And. ;
	    	(YEAR(MV_PAR02) > 2014 .OR. (YEAR(MV_PAR02) = 2014 .AND. MONTH(MV_PAR02) > 9 ))  
	    	
	    	Aarea:=getarea()
			TRB->(DBGoTop())
			
			If MsSeek('4242010')			
				n960deb	:=	TRB->TRB_VALOR
			EndIf	
			If MsSeek('4242020')	
				n970deb	:=	TRB->TRB_VALOR
			EndIf	
			If MsSeek('4242030')
				n970deb	+=	TRB->TRB_VALOR
			EndIf
	    	RestArea(aArea)
	    EndIf
	    
		/*Saldo Credor Acumulado*/
		/*960-*Saldo Credor Acumulado Relativo à Exportação*/
		aValor[18]:= aValor[8]+aValor[11]+aValor[15]- n960deb
		
		/*970 – Saldo Credor Acumulado Relativo à Saída Isenta*/
		//Foi atribuido 0 por causa da conta feita aqui, quando não for apurado e reservado, pois é necessário subtrair o valor do debito.		
		aValor[20]:= aValor[9]+aValor[12]+aValor[16]- n970deb
		
		/*980 - Saldo Credor Acumulado Relativo a Saídas Diferidas*/
		aValor[22]:= aValor[10]+aValor[13]+aValor[17]
	
		/*Proporção*/
		/*961 - Proporção do Saldo Relativo à Exportação em Relação ao Saldo Acumulado Total*/
		aValor[19]:= ((aValor[18]+ aValor[20]+ aValor[22]) * 100)/ aValor[18]
		
		/*Item 971 - Proporção do Saldo Relativo à Saída Isenta em Relação Saldo Acumulado Total*/
		aValor[21]:= 	((aValor[18]+ aValor[20]+ aValor[22]) * 100)/ aValor[20]
		
		/*Item 981 - Proporção do Saldo Relativo a Saídas Diferidas em Relação Saldo Acumulado Total*/
		aValor[23]:= ((aValor[18]+aValor[20]+aValor[22]) * 100)/aValor[22]
		
		/*Deduções Aplicáveis ao Saldo Credor para o Mês Seguinte */
		/*Item 991 - Montante dos Saldos Credores Recebidos de Estabelecimentos Consolidados Deduzível do Saldo*/
		aValor[24]:= aWizard[8][15]
		
		/*Item 993 - Montante do Crédito Recebido por Transferência de Outros Contribuintes Deduzível do Saldo:*/
		aValor[25]:= aWizard[8][16]
	
		/*Item 997 – Outras deduções do Saldo Credor: outras hipóteses de dedução do saldo credor*/
		aValor[26]:= aWizard[8][17]
		
		/*Item 999 - Total das Deduções Aplicáveis ao Saldo Credor para o Mês Seguinte*/
		aValor[27]:= aValor[24]+aValor[25]+aValor[26]
		
		AtuVlrDime (.F., "41", "41", "010", aValor[1], 2)
		AtuVlrDime (.F., "41", "41", "017", aValor[2], 2)
		AtuVlrDime (.F., "41", "41", "018", aValor[3], 2)
		AtuVlrDime (.F., "41", "41", "019", aValor[4], 2)
		AtuVlrDime (.F., "41", "41", "020", aValor[5], 2)
		AtuVlrDime (.F., "41", "41", "030", aValor[6], 2)
		AtuVlrDime (.F., "41", "41", "040", aValor[7], 2)
		AtuVlrDime (.F., "41", "41", "120", aValor[8], 2)
		AtuVlrDime (.F., "41", "41", "130", aValor[9], 2)
		AtuVlrDime (.F., "41", "41", "140", aValor[10], 2)
		AtuVlrDime (.F., "41", "41", "160", aValor[11], 2)
		AtuVlrDime (.F., "41", "41", "170", aValor[12], 2)
		AtuVlrDime (.F., "41", "41", "180", aValor[13], 2)
		AtuVlrDime (.F., "41", "41", "190", aValor[14], 2)
		AtuVlrDime (.F., "41", "41", "217", aValor[15], 2)
		AtuVlrDime (.F., "41", "41", "218", aValor[16], 2)
		AtuVlrDime (.F., "41", "41", "219", aValor[17], 2)
		AtuVlrDime (.F., "41", "41", "960", aValor[18], 2)
		AtuVlrDime (.F., "41", "41", "970", aValor[20], 2)
		AtuVlrDime (.F., "41", "41", "980", aValor[22], 2)
		AtuVlrDime (.F., "41", "41", "961", aValor[19], 2)
		AtuVlrDime (.F., "41", "41", "971", aValor[21], 2)
		AtuVlrDime (.F., "41", "41", "981", aValor[23], 2)
		AtuVlrDime (.F., "41", "41", "991", aValor[24], 2)
		AtuVlrDime (.F., "41", "41", "993", aValor[25], 2)
		AtuVlrDime (.F., "41", "41", "997", aValor[26], 2)
		AtuVlrDime (.F., "41", "41", "999", aValor[27], 2)
	EndIf	
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME42    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 42 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³     DEBITOS POR TRANSFERENCIA DE CREDITOS ACUMULADOS       ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente. O item 990 deve ser transportado para a coluna 30 do³±±
±±³          ³ quadro 9(Registro 30)                                      ³±±
±±³          ³Os codigos de linha da apuracao tratado neste quadro devem  ³±±
±±³          ³ ser rigorosamente respeitado.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN -> Valor a ser retornado para o quadro 9 item 30.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME42 (aWizard, aApICMMe, aApICM1D, aApICM2D)
	Local	aValor	:=	{0,0,0,0,0,0}		//1-Debito por transferencia de creditos acumulados relativos a exportacao
											//2-Debito por transferencia de creditos acumulados relativos a saidas isentas ou nao tributadas
											//3-Debito por transferencia de creditos acumulados relativos a saidas diferidas ou com suspensao do imposto
											//4-Debito por transferencia de bens do ativo permanente de outro estabelecimentos da mesma empresa
											//5-Outros debitos por transferencia de creditos.
											//6-Total de debito por transferencia de creditos acumulados
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para todos os tipos de declaracao sendo ela do tipo Normal ou Produtor Primario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (("Normal"$aWizard[2][3]) .Or. ("Produtor"$aWizard[2][3])) .And. "Apurou ou reservou"$aWizard[2][6]
		If (!"Decendial"$aWizard[2][12]) 
		    //1-Debito por transferencia de creditos acumulados relativos a exportacao
		    aValor[1]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="42010"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="42010"})][3], 0)
		    //2-Debito por transferencia de creditos acumulados relativos a saidas isentas ou nao tributadas
		    aValor[2]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="42020"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="42020"})][3], 0)
		    //3-Debito por transferencia de creditos acumulados relativos a saidas diferidas ou com suspensao do imposto
		    aValor[3]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="42030"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="42030"})][3], 0)
		    //4-Debito por transferencia de bens do ativo permanente de outro estabelecimentos da mesma empresa
		    aValor[4]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="42040"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="42040"})][3], 0)
		    //5-Outros debitos por transferencia de creditos.
		    aValor[5]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="42070"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="42070"})][3], 0)  
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PRIMEIRO DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//1-Debito por transferencia de creditos acumulados relativos a exportacao
			aValor[1]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="42010"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="42010"})][3], 0)
			//2-Debito por transferencia de creditos acumulados relativos a saidas isentas ou nao tributadas
			aValor[2]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="42020"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="42020"})][3], 0)
			//3-Debito por transferencia de creditos acumulados relativos a saidas diferidas ou com suspensao do imposto
			aValor[3]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="42030"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="42030"})][3], 0)
			//4-Debito por transferencia de bens do ativo permanente de outro estabelecimentos da mesma empresa
			aValor[4]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="42040"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="42040"})][3], 0)
			//5-Outros debitos por transferencia de creditos.
			aValor[5]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="42070"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="42070"})][3], 0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SEGUNDO  DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//1-Debito por transferencia de creditos acumulados relativos a exportacao
			aValor[1]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="42010"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="42010"})][3], 0)
			//2-Debito por transferencia de creditos acumulados relativos a saidas isentas ou nao tributadas
			aValor[2]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="42020"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="42020"})][3], 0)
			//3-Debito por transferencia de creditos acumulados relativos a saidas diferidas ou com suspensao do imposto
			aValor[3]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="42030"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="42030"})][3], 0)
			//4-Debito por transferencia de bens do ativo permanente de outro estabelecimentos da mesma empresa
			aValor[4]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="42040"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="42040"})][3], 0)
			//5-Outros debitos por transferencia de creditos.
			aValor[5]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="42070"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="42070"})][3], 0)
		EndIf
		//6-Total de debito por transferencia de creditos acumulados
		aValor[6]	:=	aValor[1]+aValor[2]+aValor[3]+aValor[4]+aValor[5]
		//
		//1-Debito por transferencia de creditos acumulados relativos a exportacao
		AtuVlrDime (.F., "42", "42", "010", aValor[1], 2)
		//
		//2-Debito por transferencia de creditos acumulados relativos a saidas isentas ou nao tributadas
		AtuVlrDime (.F., "42", "42", "020", aValor[2], 2)
		//
		//3-Debito por transferencia de creditos acumulados relativos a saidas diferidas ou com suspensao do imposto
		AtuVlrDime (.F., "42", "42", "030", aValor[3], 2)
		//
		//4-Debito por transferencia de bens do ativo permanente de outro estabelecimentos da mesma empresa
		AtuVlrDime (.F., "42", "42", "040", aValor[4], 2)
		//
		//5-Outros debitos por transferencia de creditos.
		AtuVlrDime (.F., "42", "42", "070", aValor[5], 2)
		//
		//6-Total de debito por transferencia de creditos acumulados
		AtuVlrDime (.F., "42", "42", "990", aValor[6], 2)
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME43    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 43 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³           CREDITOS RECEBIDOS POR TRANSFERENCIA             ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente. O item 990 deve ser transportado para a coluna 30 do³±±
±±³          ³ quadro 9(Registro 30)                                      ³±±
±±³          ³Os codigos de linha da apuracao tratado neste quadro devem  ³±±
±±³          ³ ser rigorosamente respeitado.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN -> Valor a ser retornado para o quadro 9 item 70.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME43 (aWizard, aApICMMe, aApICM1D, aApICM2D)
	Local	aValor	:=	{0,0,0,0}		//1-Credito por transferencia de creditos acumulados
										//2-Credito por transferencia de bens do ativo permanente de outro estabelecimentos da mesma empresa
										//3-Outros creditos por transferencia de creditos.
										//4-Total de credito por transferencia de credito
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para todos os tipos de declaracao sendo ela do tipo Normal ou Produtor Primario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (("Normal"$aWizard[2][3]) .Or. ("Produtor"$aWizard[2][3])) .And. "RECEBEU C"$Upper (aWizard[2][6])
		If (!"Decendial"$aWizard[2][12]) 
		    //1-Credito por transferencia de creditos acumulados
		    aValor[1]	:=	0
		    //2-Credito por transferencia de bens do ativo permanente de outro estabelecimentos da mesma empresa
		    aValor[2]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="43020"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="43020"})][3], 0)
		    //3-Outros creditos por transferencia de creditos.
		    aValor[3]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="43050"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="43050"})][3], 0)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SEGUNDO  DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    //1-Credito por transferencia de creditos acumulados
			aValor[1]	:=	0
			//2-Credito por transferencia de bens do ativo permanente de outro estabelecimentos da mesma empresa
			aValor[2]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="43020"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="43020"})][3], 0)
			//3-Outros creditos por transferencia de creditos.
			aValor[3]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="43050"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="43050"})][3], 0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PRIMEIRO DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//1-Credito por transferencia de creditos acumulados
			aValor[1]	+=	0
			//2-Credito por transferencia de bens do ativo permanente de outro estabelecimentos da mesma empresa
			aValor[2]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="43020"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="43020"})][3], 0)
			//3-Outros creditos por transferencia de creditos.
			aValor[3]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="43050"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="43050"})][3], 0)
		EndIf
		
		//Não preencher o registro 43010 a partir do periodo de referencia março de 2008
		If  StrZero (Year (MV_PAR02), 4)+StrZero (Month (MV_PAR02), 2) < '200803'
				//1-Credito por transferencia de creditos acumulados
				aValor[1]	:=	AtuVlrDime(.T., "46", "46",,,2,,1)		//Quando se tratar de Regimes especiais - Registro 46, o mesmo
																		//  pode conter diversos lancamentos com diversos protocolos, 
																		//  onde deverao ser aglutinados neste item.
				//1-Creidto por transferencia de creditos acumulados
				AtuVlrDime (.F., "43", "43", "010", aValor[1], 2)
		
		EndIf
		
		//Totalizador
		aValor[4]	:=	aValor[1]+aValor[2]+aValor[3]
		
		//
		//2-Credito por transferencia de bens do ativo permanente de outro estabelecimentos da mesma empresa
		AtuVlrDime (.F., "43", "43", "020", aValor[2], 2)
		//
		//3-Outros creditos por transferencia de creditos.
		AtuVlrDime (.F., "43", "43", "050", aValor[3], 2)
		//
		//4-Total de credito por transferencia de credito
		AtuVlrDime (.F., "43", "43", "990", aValor[4], 2)
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME44    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 44 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³                   CREDITOS PRESUMIDOS                      ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente. O item 990 deve ser transportado para a coluna 80 do³±±
±±³          ³ quadro 5(Registro 26)                                      ³±±
±±³          ³Os codigos de linha da apuracao tratado neste quadro devem  ³±±
±±³          ³ ser rigorosamente respeitado.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN -> Valor a ser retornado para o quadro 5(R26) item 80. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME44 (aWizard, aApICMMe, aApICM1D, aApICM2D, aLog)
	Local	nI		:=	0
	Local	aValor	:=	{0,0,0,0,0,0,0,0,0,0,0,0,0,0}	//1-Credito Presumido - Incentivo a geracao de emprego
														//2-Credito Presumido de estabelecimento abatedor de aves (5%)
														//3-Credito Presumido de estabelecimento abatedor de aves (4%)
														//4-Credito Presumido de estabelecimento abatedor de aves (3%)
														//5-Credito Presumido de estabelecimento abatedor de suinos (6%)
														//6-Credito Presumido de estabelecimento abatedor de suinos (5%)
														//7-Credito Presumido de estabelecimento abatedor de suinos (4%)
														//8-Credito presumido pela aquisicao de ECF
														//9-Contribuicao ao FUNDOSOCIAL
														//10-Credito pela contribuição ao FUNDOSOCIAL
														//11-Aplicacao no FUNCULTURAL
														//12-Aplicacao no FUNTURISMO 
														//13-Aplicacao no FUNDESPORTE 
														//14-Outros creditos presumidos
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para todos os tipos de apuracao com regime normal, Produtor Primario ou Simples e declaracao com Credito Presumido definido como SIM no CFP.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ("Sim"$aWizard[2][7]) .And.	(("Normal"$aWizard[2][3]) .Or.;
									 ("Produtor"$aWizard[2][3]) .Or.;
									 (lSimples .And. (("ME (Microempresa)"$aWizard[2][4]) .Or. ("EPP (Empresa Peq. Porte)"$aWizard[2][4]))))
		If (!"Decendial"$aWizard[2][12]) 
		    //(+) Crédito presumido - incentivo à geração de emprego
		    aValor[1]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="44040"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="44040"})][3], 0)
		    //(+) Crédito presumido de estabelecimento abatedor de aves (5%)
		    aValor[2]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="44050"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="44050"})][3], 0)
		    //(+) Crédito presumido de estabelecimento abatedor de aves 4%)
		    aValor[3]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="44060"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="44060"})][3], 0)
		    //(+) Crédito presumido de estabelecimento abatedor de aves (3%)
		    aValor[4]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="44070"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="44070"})][3], 0)
		    //(+) Crédito presumido de estabelecimento abatedor de suínos (6%)
		    aValor[5]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="44080"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="44080"})][3], 0)
		    //(+) Crédito presumido de estabelecimento abatedor de suínos (5%)
		    aValor[6]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="44090"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="44090"})][3], 0)
		    //(+) Crédito presumido de estabelecimento abatedor de suínos (4%) 
		    aValor[7]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="44100"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="44100"})][3], 0)
			//Credito presumido pela aquisicao de ECF
		    aValor[8]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="44120"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="44120"})][3], 0)
   			//Contribuicao ao FUNDOSOCIAL
		    aValor[9]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="44130"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="44130"})][3], 0)
		    //Credito pela contribuicao ao FUNDOSOCIAL
		    aValor[10]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="44131"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="44131"})][3], 0)
			//14-Aplicacao no FUNCULTURAL
			aValor[11]	:=	0	//Abaixo
			//15 - Aplicacao no FUNTURISMO
			aValor[12]	:=	0	//Abaixo
			//16-Aplicacao no FUNDESPORTE
			aValor[13]	:=	0	//Abaixo
		    //Outros créditos presumidos 
		    aValor[14]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="44190"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="44190"})][3], 0)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PRIMEIRO DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    //(+) Crédito presumido - incentivo à geração de emprego
			aValor[1]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="44040"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="44040"})][3], 0)
		    //(+) Crédito presumido de estabelecimento abatedor de aves (5%)
			aValor[2]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="44050"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="44050"})][3], 0)
			//(+) Crédito presumido de estabelecimento abatedor de aves 4%)
			aValor[3]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="44060"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="44060"})][3], 0)
			//(+) Crédito presumido de estabelecimento abatedor de aves (3%)
			aValor[4]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="44070"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="44070"})][3], 0)
			//(+) Crédito presumido de estabelecimento abatedor de suínos (6%)
			aValor[5]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="44080"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="44080"})][3], 0)
			//(+) Crédito presumido de estabelecimento abatedor de suínos (5%)
			aValor[6]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="44090"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="44090"})][3], 0)
			//(+) Crédito presumido de estabelecimento abatedor de suínos (4%) 
			aValor[7]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="44100"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="44100"})][3], 0)
			//Credito presumido pela aquisicao de ECF
			aValor[8]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="44120"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="44120"})][3], 0)
   			//Contribuicao ao FUNDOSOCIAL
		    aValor[9]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="44130"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="44130"})][3], 0)
		    //Credito pela contribuicao ao FUNDOSOCIAL
		    aValor[10]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="44131"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="44131"})][3], 0)
			//14-Aplicacao no FUNCULTURAL
			aValor[11]	:=	0	//Abaixo
			//15 - Aplicacao no FUNTURISMO
			aValor[12]	:=	0	//Abaixo
			//16-Aplicacao no FUNDESPORTE
			aValor[13]	:=	0	//Abaixo
		    //(+) Outros créditos presumidos 
		    aValor[14]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="44190"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="44190"})][3], 0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SEGUNDO  DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//(+) Crédito presumido - incentivo à geração de emprego
			aValor[1]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="44040"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="44040"})][3], 0)
			//(+) Crédito presumido de estabelecimento abatedor de aves (5%)
			aValor[2]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="44050"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="44050"})][3], 0)
			//(+) Crédito presumido de estabelecimento abatedor de aves 4%)
			aValor[3]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="44060"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="44060"})][3], 0)
			//(+) Crédito presumido de estabelecimento abatedor de aves (3%)
			aValor[4]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="44070"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="44070"})][3], 0)
			//(+) Crédito presumido de estabelecimento abatedor de suínos (6%)
			aValor[5]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="44080"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="44080"})][3], 0)
			//(+) Crédito presumido de estabelecimento abatedor de suínos (5%)
			aValor[6]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="44090"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="44090"})][3], 0)
			//(+) Crédito presumido de estabelecimento abatedor de suínos (4%)
			aValor[7]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="44100"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="44100"})][3], 0)
			//Credito presumido pela aquisicao de ECF
			aValor[8]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="44120"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="44120"})][3], 0)
   			//Contribuicao ao FUNDOSOCIAL
		    aValor[9]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="44130"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="44130"})][3], 0)
		    //Credito pela contribuicao ao FUNDOSOCIAL
		    aValor[10]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="44131"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="44131"})][3], 0)
			//14-Aplicacao no FUNCULTURAL
			aValor[11]	:=	0	//Abaixo
			//15 - Aplicacao no FUNTURISMO
			aValor[12]	:=	0	//Abaixo
			//16-Aplicacao no FUNDESPORTE
			aValor[13]	:=	0	//Abaixo
		    //(+) Outros créditos presumidos 
		    aValor[14]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="44190"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="44190"})][3], 0)
		EndIf
		//14-Aplicacao no FUNCULTURAL
		aValor[11]	:=	AtuVlrDime(.T., "46", "46",,,2,,2)		//Quando se tratar de Regimes especiais - Registro 46, o mesmo
																//  pode conter diversos lancamentos com diversos protocolos, 
																//  onde deverao ser aglutinados neste item.
		//15 - Aplicacao no FUNTURISMO
		aValor[12]	:=	AtuVlrDime(.T., "46", "46",,,2,,3) 	//Quando se tratar de Regimes especiais - Registro 46, o mesmo
																//  pode conter diversos lancamentos com diversos protocolos, 
																//  onde deverao ser aglutinados neste item.
		//16-Aplicacao no FUNDESPORTE
		aValor[13]	:=	AtuVlrDime(.T., "46", "46",,,2,,4)		//Quando se tratar de Regimes especiais - Registro 46, o mesmo
																//  pode conter diversos lancamentos com diversos protocolos, 
																//  onde deverao ser aglutinados neste item.
		// Estes Registros Nao devem ser gerados para o Simples
		If !(lSimples .And. (("ME (Microempresa)"$aWizard[2][4]) .Or. ("EPP (Empresa Peq. Porte)"$aWizard[2][4])))
			//1-Total dos valores pagos no mes aos empregados
			AtuVlrDime(, "44", "44", "010", Val (aWizard[9][1]), 2)
			//
			//2-Media dos valores pagos aos seus empregados no exercicio anterior
			AtuVlrDime(, "44", "44", "020", Val (aWizard[9][2]), 2)
			//
			//3-Incremento verificado
			AtuVlrDime(, "44", "44", "030", Val (aWizard[9][1])-Val (aWizard[9][2]), 2)
			//
			//4-Credito Presumido - Incentivo a geracao de emprego
			AtuVlrDime(, "44", "44", "040", aValor[1], 2)
			//
			//5-Credito Presumido de estabelecimento abatedor de aves (5%)
			AtuVlrDime(, "44", "44", "050", aValor[2], 2)
			//
			//6-Credito Presumido de estabelecimento abatedor de aves (4%)
			AtuVlrDime(, "44", "44", "060", aValor[3], 2)
			//
			//7-Credito Presumido de estabelecimento abatedor de aves (3%)
			AtuVlrDime(, "44", "44", "070", aValor[4], 2)
			//
			//8-Credito Presumido de estabelecimento abatedor de suinos (6%)
			AtuVlrDime(, "44", "44", "080", aValor[5], 2)
			//
			//9-Credito Presumido de estabelecimento abatedor de suinos (5%)
			AtuVlrDime(, "44", "44", "090", aValor[6], 2)
			//
			//10-Credito Presumido de estabelecimento abatedor de suinos (4%)
			AtuVlrDime(, "44", "44", "100", aValor[7], 2)
			//
		Else
			aAddLog ("44130",,aValor[9],,, aWizard, @aLog)
			aAddLog ("44131",,aValor[10],,, aWizard, @aLog)
		Endif
		//           
		//11-Credito Presumido pela aquisicao de ECF
		AtuVlrDime(, "44", "44", "120", aValor[8], 2)
		//           
		//12 - Contribuicao ao Fundo Social
		AtuVlrDime(, "44", "44", "130", aValor[9], 2)
		//           
		//13-Credito pela Contribuicao ao Fundo Social
		AtuVlrDime(, "44", "44", "131", aValor[10], 2)
		//           
		//14-Aplicacao no FUNCULTURAL
		AtuVlrDime(, "44", "44", "140", aValor[11], 2)
		//           
		//15 - Aplicacao no FUNTURISMO
		AtuVlrDime(, "44", "44", "150", aValor[12], 2)
		//           
		//16-Aplicacao no FUNDESPORTE
		AtuVlrDime(, "44", "44", "160", aValor[13], 2)
		//
		//17-Outros creditos presumidos
		AtuVlrDime(, "44", "44", "190", aValor[14], 2)
		//	   
		//18-Total de creditos presumidos
		For nI := 1 To Len (aValor)
			AtuVlrDime(, "44", "44", "990", aValor[nI], 2)
		Next (nI) 
	Endif
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME45    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 45 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³             CREDITOS POR INCENTIVOS FISCAIS                ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente. O item 990 deve ser transportado para a coluna 90 do³±±
±±³          ³ quadro 5(Registro 26)                                      ³±±
±±³          ³Os codigos de linha da apuracao tratado neste quadro devem  ³±±
±±³          ³ ser rigorosamente respeitado.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN -> Valor a ser retornado para o quadro 5(R26) item 90. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME45 (aWizard, aApICMMe, aApICM1D, aApICM2D)
	Local	aValor	:=	{0,0,0,0,0}		//1-Valor do saldo devedor do mes antes da deducao do incentivo
										//2-Credito por incentivo fiscal - 5% do saldo devedor do mes antes da deducao do incentivo(Dec. n. 3.604/98 - Art. 41 $ 2., I)
										//3-Valor recibo
										//4-Credito por incnetivo fiscal - percentual sobre o valor do recibo(Dec. n. 3.604/98 - Art. 41 $ 2., III)
										//5-Outros creditos por incentivos ficais
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para todos os tipos de apuracao com regime normal ou produtor primario e declaracao com Credito por incentivo fiscais definido como SIM no CFP.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ("Sim"$aWizard[2][8]) .And. (("Normal"$aWizard[2][3]) .Or. ("Produtor"$aWizard[2][3]))
		If (!"Decendial"$aWizard[2][12]) 
		    //valores da apuracao ICMS Mensal
		    aValor[2]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="45020"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="45020"})][3], 0)
		    aValor[3]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="45040"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="45040"})][3], 0)
		    aValor[4]	:=	Iif (aScan (aApICMMe, {|a| a[4]=="45050"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[4]=="45050"})][3], 0)
		Else
		    //valores da apuracao ICMS do 1 decendio
			aValor[2]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="45020"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="45020"})][3], 0)
			aValor[3]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="45040"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="45040"})][3], 0)
			aValor[4]	:=	Iif (aScan (aApICM1D, {|a| a[4]=="45050"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[4]=="45050"})][3], 0)
			//
			//valores da apuracao ICMS do 2 decendio
			aValor[2]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="45020"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="45020"})][3], 0)
			aValor[3]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="45040"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="45040"})][3], 0)
			aValor[4]	+=	Iif (aScan (aApICM2D, {|a| a[4]=="45050"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[4]=="45050"})][3], 0)
		EndIf
		//
		//1-Valor do saldo devedor do mes antes da deducao do incentivo
		aValor[1]	+=	AtuVlrDime(.T., "30", "09", "120")
		//
		RecLock ("TRB", .T.)
			TRB->TRB_REGIST	:=	"45"
			TRB->TRB_QUADRO	:=	"45"
			TRB->TRB_ITEM	:=	"010"
			TRB->TRB_VALOR	:=	aValor[1]
		MsUnLock ()	
		//
		//2-Credito por incentivo fiscal - 5% do saldo devedor do mes antes da deducao do incentivo(Dec. n. 3.604/98 - Art. 41 $ 2., I)
		RecLock ("TRB", .T.)
			TRB->TRB_REGIST	:=	"45"
			TRB->TRB_QUADRO	:=	"45"
			TRB->TRB_ITEM	:=	"020"
			TRB->TRB_VALOR	:=	aValor[2]	//Transportado do registro 30, item 120.
		MsUnLock ()		
		//
		//3-Valor recibo
		RecLock ("TRB", .T.)
			TRB->TRB_REGIST	:=	"45"
			TRB->TRB_QUADRO	:=	"45"
			TRB->TRB_ITEM	:=	"030"
			TRB->TRB_VALOR	:=	Val (aWizard[10][1])
		MsUnLock ()
		//
		//4-Credito por incnetivo fiscal - percentual sobre o valor do recibo(Dec. n. 3.604/98 - Art. 41 $ 2., III)
		RecLock ("TRB", .T.)
			TRB->TRB_REGIST	:=	"45"
			TRB->TRB_QUADRO	:=	"45"
			TRB->TRB_ITEM	:=	"040"
			TRB->TRB_VALOR	:=	aValor[3]
		MsUnLock ()
		//
		//5-Outros creditos por incentivos ficais
		RecLock ("TRB", .T.)
			TRB->TRB_REGIST	:=	"45"
			TRB->TRB_QUADRO	:=	"45"
			TRB->TRB_ITEM	:=	"050"
			
			If aValor[2]<aValor[3]
				aValor[4]	:=	aValor[2]
			Else
				aValor[4]	:=	aValor[3]
			EndIf		
			
			TRB->TRB_VALOR	:=	aValor[4]
		MsUnLock ()
		//
		//Total de Creditos por incentivos fiscais - Transportar para o item 90 do quadro 5.
		RecLock ("TRB", .T.)
			TRB->TRB_REGIST	:=	"45"
			TRB->TRB_QUADRO	:=	"45"
			TRB->TRB_ITEM	:=	"990"
			If aValor[2]<aValor[3]
				aValor[5]	:=	aValor[2]+aValor[4]
			Else
				aValor[5]	:=	aValor[3]+aValor[4]
			EndIf
			TRB->TRB_VALOR	:=	aValor[5]
		MsUnLock ()	
	EndIf	
Return (.T.)      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME46    ³ Autor ³Gustavo G. Rueda       ³ Data ³21.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 46 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³        CREDITOS POR REGIMES E AUTORIZACOES ESPECIAIS       ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente. O item 990 deve ser transportado para a coluna 90 do³±±
±±³          ³ quadro 5 (Registro 26), onde eh lido atraves da funcao     ³±±
±±³          ³ AtuVlrDime.                                                ³±±
±±³          ³Os codigos de linha da apuracao tratado neste quadro devem  ³±±
±±³          ³ ser rigorosamente respeitado.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME46 (aWizard, aApICMMe, aApICM1D, aApICM2D)
	Local	lRet	:=	.T.
	Local	nI		:=	1
	Local	nAcItem	:=	0
	Local	aGer46	:=	{}	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para todos os tipos de apuracao com regime normal, Produtor Primario ou Simples ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ("Normal"$aWizard[2][3]) .Or. ("Produtor"$aWizard[2][3]) .Or. (lSimples .And. (("ME (Microempresa)"$aWizard[2][4]) .Or. ("EPP (Empresa Peq. Porte)"$aWizard[2][4])))
		If (!"Decendial"$aWizard[2][12])
			RetAp46 (aApICMMe, @aGer46, @nAcItem)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PRIMEIRO DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RetAp46 (aApICM1D, @aGer46)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SEGUNDO DECENDIO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RetAp46 (aApICM2D, @aGer46)
   		EndIf
   		//
		//Reg. 30, item 075 - Crédito informado no DCIP - Esta informacao deve acompanhar o item 075 do quadro 09.
		For nI := 1 To Len(aProt)
			If !Empty(aProt[nI][1]) .And. Val(Str(aProt[nI][2])) > 0
				nAcItem++
				aAdd (aGer46, {"46", "46", StrZero (nAcItem, 3), Val(Str(aProt[nI][2])), 2, aProt[nI][1], aProt[nI][3]})
			EndIf
		Next
   		
		For nI:=1 To len(aProcess)
			If !Empty(aProcess[nI][1]) .And. Val(Str(aProcess[nI][2])) > 0
				nAcItem++
				aAdd (aGer46, {"46", "46", StrZero (nAcItem, 3), Val(Str(aProcess[nI][2])), 2, aProcess[nI][1], aProcess[nI][3]})
			Endif
		Next  
		//
   		For nI := 1 To Len (aGer46)
   			//Lancamentos
   		   	AtuVlrDime(, aGer46[nI][1], aGer46[nI][2], aGer46[nI][3], aGer46[nI][4], aGer46[nI][5], aGer46[nI][6], aGer46[nI][7]) 
   		   	//Totalizador - Item 990
   		   	AtuVlrDime(, "46", "46", "990", aGer46[nI][4], 2, Replicate ("0", 15), 0)
   		Next (nI)
   EndIf
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME47    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 47                                 ³±±
±±³          ³                                                            ³±±
±±³          ³COMPRA DE EXTRATORES, PRODUTORES AGROPECUARIOS E PESCADORES.³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do SF3            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nMVCMPEXTR -> Posicao do campo que identifica compra de     ³±±
±±³          ³ extratores na tabela SB5.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME47 (nMVCMPEXTR,cFilDe,cFilAte)
Local aSf3		:= {"SF3",""}
Local aAreaSM0  := SM0->(GetArea())
Local aArea		:= {}
Local nAcTotal	:= 0
Local cChave	:= ""
Local cMvEstado := GetMv("MV_ESTADO")
Local nMvMunFor := 0
Local cMvMunFor := ""
Local cMvCfop   := GetNewPar("MV_CFREG47","")
Local nForFilial:= 0

SM0->(dbSetOrder(1))

For nForFilial := 1 To Len( aFilsCalc )

	If !aFilsCalc[ nForFilial, 1 ]
		Loop
	EndIf

	SM0->(dbSeek(cEmpAnt+aFilsCalc[nForFilial][2]))
	If SM0->M0_ESTENT <> 'SC'
		Loop
	EndIf

	cFilAnt   := SM0->M0_CODFIL
	cMvEstado := 'SC'				// Checou no SM0 se o Estado era SC, o parâmetro não deve ser diferente
	nMvMunFor := 0
	cMvMunFor := GetNewPar("MV_CMUNSCF","")
	If !Empty(cMvMunFor)
		nMvMunFor := SA2->(FieldPos(cMvMunFor))
	Endif 

	//
	SF3->(DbSetOrder(1))
	FsQuery(aSf3, 1, "F3_FILIAL='"+xFilial("SF3")+"' AND F3_ENTRADA>='"+DTOS(MV_PAR01)+"' AND F3_ENTRADA<='"+DTOS(MV_PAR02)+"' AND F3_DTCANC=' ' AND SUBSTRING(F3_CFO, 1, 1)='1' AND F3_TIPO NOT IN ('D','B', 'S') ", "F3_FILIAL='"+xFilial("SF3")+"' .AND. DTOS(F3_ENTRADA)>='"+DTOS(MV_PAR01)+"' .AND. DTOS(F3_ENTRADA)<='"+DTOS(MV_PAR02)+"' .And. Empty(F3_DTCANC) .And. SubStr(F3_CFO, 1, 1)=='1' .And. !F3_TIPO$'DBS' ", SF3->(IndexKey()))
	//
	Do While !SF3->(Eof())
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		If (SA2->(DbSeek(xFilial("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA))) .And. !Empty(SA2->A2_TIPORUR) .And. IIf(SA2->(FieldPos("A2_CCICMS"))>0, SA2->A2_CCICMS<>"1", .T.) .AND. ((SA2->A2_TIPO == 'F') .Or. (SA2->A2_TIPO == 'J'))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando nao existir o campo na tabela SB5 ou ate mesmo o parametro que se refere processo utilizando somente o tiporur³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nMVCMPEXTR<>0)
				DbSelectArea("SD1")
				SD1->(DbSetOrder(1))
				SD1->(DbSeek (xFilial ("SD1")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
				cChave := xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
				Do While !SD1->(Eof()) .And. (cChave==xFilial("SD1")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA) .And. !(AllTrim(SD1->D1_CF) $ (cMvCfop))
					//
					DbSelectArea ("SB5")
					SB5->(DbSetOrder (1))
					If SB5->(DbSeek (xFilial ("SB5")+SD1->D1_COD)) .And. "S"$SB5->(FieldGet (nMVCMPEXTR)) 
						If ((T4X->(DbSeek("4747"+StrZero(Val(SA2->A2_COD_MUN), 5)))) .And. Empty(nMvMunFor)) .Or. (!Empty(nMvMunFor) .And. (T4X->(DbSeek("4747"+SA2->(FieldGet(nMvMunFor))))))
							RecLock ("T4X", .F.)
						Else
							RecLock ("T4X", .T.)
								T4X->T4X_REGIST	:=	"47"
								T4X->T4X_QUADRO	:=	"47"
							If !Empty(nMvMunFor)
								T4X->T4X_MUNIC	:= SA2->(FieldGet(nMvMunFor))
							Else
								T4X->T4X_MUNIC	:=	StrZero (Val (SA2->A2_COD_MUN), 5)
							EndIf
						EndIf
							T4X->T4X_VALOR	+=	SD1->D1_TOTAL
						MsUnLock ()
						//
						nAcTotal	+=	SD1->D1_TOTAL
					EndIf
					SD1->(dbSkip())
					cChave	:=	xFilial ("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
				Enddo
			ElseIf !(AllTrim(SF3->F3_CFO) $ (cMvCfop))
				If ((T4X->(DbSeek("4747"+StrZero(Val(SA2->A2_COD_MUN), 5)))) .And. Empty(nMvMunFor)) .Or. (!Empty(nMvMunFor) .And. (T4X->(DbSeek("4747"+SA2->(FieldGet(nMvMunFor))))))
					RecLock ("T4X", .F.)
				Else
					RecLock ("T4X", .T.)
					T4X->T4X_REGIST	:=	"47"
					T4X->T4X_QUADRO	:=	"47"
					If !Empty(nMvMunFor)
						T4X->T4X_MUNIC	:= SA2->(FieldGet(nMvMunFor))
					Else
						T4X->T4X_MUNIC	:=	StrZero (Val (SA2->A2_COD_MUN), 5)
					EndIf
				EndIf
					T4X->T4X_VALOR	+=	SF3->F3_VALCONT
				MsUnLock ()
				//
				nAcTotal	+=	SF3->F3_VALCONT
			EndIf
		EndIf
		//
		If (nMVCMPEXTR<>0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando houver mais de um SF3 para a mesma nota fiscal processo todos atraves deste while e garanto que o proximo nao seria referente a mesma nota ja processada anteriormente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChave	:=	xFilial ("SF3")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
			Do While !SF3->(Eof ()) .And. (cChave==xFilial("SF3")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA)
				SF3->(DbSkip ())
			EndDo
		Else
			SF3->(DbSkip ())
		EndIf
	EndDo
	//
	FsQuery (aSf3, 2,)
	//
Next


RecLock ("T4X", .T.)
	T4X->T4X_REGIST	:=	"47"
	T4X->T4X_QUADRO	:=	"47"
	T4X->T4X_MUNIC	:=	"99999"
	T4X->T4X_VALOR	:=	nAcTotal
MsUnLock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a filial e area corrente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArea := GetArea()
RestArea(aAreaSM0)
cFilAnt := SM0->M0_CODFIL
RestArea(aArea)

Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME48    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 48                                 ³±±
±±³          ³                                                            ³±±
±±³          ³RECEITA DE PRESTACAO DE SERVICO E FORNECIMENTO E ENERGIA EL.³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do SF3            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME48 (aWizard,cFilDe,cFilAte)
Local aAreaSM0  := SM0->(GetArea())
Local aArea     := {}
Local nForFilial:= 0
Local nMvMunFor := 0
Local nMvMunCli := 0
Local cMvMunFor := 0
Local cMvMunCli := 0
Local cRG48001	:= ""
Local cRG48002	:= ""
Local cRG48003	:= ""
Local cRG48004	:= ""
Local cRG48005	:= ""
Local cRG48006	:= ""
Local cRG48007	:= ""
Local cRG48008	:= ""
Local cRG48501	:= ""
Local cRG48502	:= ""
Local cRG48503	:= ""
Local cRG48504	:= ""
Local cRG48505	:= ""
Local cRG48506	:= ""
Local cTipo		:= "000"
Local nTotVlCont:= 0
Local lProc     := .F.
Local lQuery    := .F.
Local nAcTotal	:= 0
Local nPerc		:= 0
Local lIntTms	:= GetNewPar("MV_INTTMS",.F.)
Local cUFOri	:= ""
Local cUFDest	:= ""
Local cCodMunArq:= ""
Local cCodMunDes:= ""
Local cCodMunOri:= ""
Local nMvMunDUL	:= ""
Local nMvMunDUE := ""
Local lDUESol   := DUE->(FieldPos("DUE_CODSOL")) > 0
Local dDtInicial:= MV_PAR01
Local dDtFinal  := MV_PAR02
Local cCfop		:= ""
Local nPos		:= 0
Local cCFoFltr  := ""
Local cAliasTot := ""
Local cAliasSF3 := ""
Local lFound	:= .F.
Local lDMSCTP   := ExistBlock("DMSC48TP")  //ponto de entrada para receber o tipo de atividade
Local aTpAux    := {}
Local aInf48    := {}
Local nValDoc   := 0


If !(("Normal"$aWizard[2][3]) .Or. (lSimples .And. (("ME (Microempresa)"$aWizard[2][4]) .Or. ("EPP (Empresa Peq. Porte)"$aWizard[2][4]))))
	Return (.T.)
EndIf

SM0->(dbSetOrder(1))
For nForFilial := 1 To Len(aFilsCalc)

	If !aFilsCalc[ nForFilial, 1 ]
		Loop
	EndIf

	SM0->(dbSeek(cEmpAnt+aFilsCalc[nForFilial][2]))
	If SM0->M0_ESTENT <> 'SC'
		Loop
	EndIf

	If SuperGetMv("MV_ESTADO") <> 'SC'
		Loop
	EndIf

	cFilAnt    := SM0->M0_CODFIL
	nTotVlCont := 0

	nMvMunCli := 0
	cMvMunCli := GetNewPar("MV_CMUNSCC","")
	If !Empty(cMvMunCli)
		nMvMunCli := SA1->(FieldPos(cMvMunCli))
	Endif

	nMvMunFor := 0
	cMvMunFor := GetNewPar("MV_CMUNSCF","")
	If !Empty(cMvMunFor)
		nMvMunFor := SA2->(FieldPos(cMvMunFor))
	Endif

	cRG48001 := SuperGetMv("MV_RG48001",,"")
	cRG48002 := SuperGetMv("MV_RG48002",,"")
	cRG48003 := SuperGetMv("MV_RG48003",,"")
	cRG48004 := SuperGetMv("MV_RG48004",,"")
	cRG48005 := SuperGetMv("MV_RG48005",,"")
	cRG48006 := SuperGetMv("MV_RG48006",,"")
	cRG48007 := SuperGetMv("MV_RG48007",,"")
	cRG48008 := SuperGetMv("MV_RG48008",,"")
	cRG48501 := SuperGetMv("MV_RG48501",,"")
	cRG48502 := SuperGetMv("MV_RG48502",,"")
	cRG48503 := SuperGetMv("MV_RG48503",,"")
	cRG48504 := SuperGetMv("MV_RG48504",,"")
	cRG48505 := SuperGetMv("MV_RG48505",,"")
	cRG48506 := SuperGetMv("MV_RG48506",,"")

	If !Empty(cRG48001)
		cCFoFltr += cRG48001 + ','
	EndIf
	If !Empty(cRG48002)
		cCFoFltr += cRG48002 + ','
	EndIf
	If !Empty(cRG48003)
		cCFoFltr += cRG48003 + ','
	EndIf
	If !Empty(cRG48004)
		cCFoFltr += cRG48004 + ','
	EndIf
	If !Empty(cRG48005)
		cCFoFltr += cRG48005 + ','
	EndIf
	If !Empty(cRG48006)
		cCFoFltr += cRG48006 + ','
	EndIf
	If !Empty(cRG48007)
		cCFoFltr += cRG48007 + ','
	EndIf
	If !Empty(cRG48008)
		cCFoFltr += cRG48008 + ','
	EndIf
	If !Empty(cRG48501)
		cCFoFltr += cRG48501 + ','
	EndIf
	If !Empty(cRG48502)
		cCFoFltr += cRG48502 + ','
	EndIf
	If !Empty(cRG48503)
		cCFoFltr += cRG48503 + ','
	EndIf
	If !Empty(cRG48504)
		cCFoFltr += cRG48504 + ','
	EndIf
	If !Empty(cRG48505)
		cCFoFltr += cRG48505 + ','
	EndIf
	If !Empty(cRG48506)
		cCFoFltr += cRG48506 + ','
	EndIf

	nPos := AT(',', cCFoFltr)

	If Empty(cCFoFltr)
		cCfop := "%''%"
	Else
		cCfop := '%'
		While nPos > 0
			cCfop += "'" + Alltrim(Substr(cCFoFltr, 1, nPos-1)) + "',"
			cCFoFltr := Substr(cCFoFltr, nPos+1, Len(cCFoFltr))
			nPos := AT(',', cCFoFltr)
		EndDo
		If Substr(cCfop, Len(cCfop) , 1) == ","
			cCfop := Substr(cCfop, 1,Len(cCfop)-1)
		EndIF
		cCfop := cCfop + '%'
	EndIf

	If aWizard[23][1]=='Sim'
		/*Processamento dos Documentos Fiscais*/
		dbSelectArea("SF3")
		SF3->(DbSetOrder(1))
		ProcRegua(LastRec())
		#IFDEF TOP
			If (TcSrvType ()<>"AS/400")
				cAliasTot := GetNextAlias()

				BeginSql Alias cAliasTot

					SELECT SUM(F3_VALCONT) AS Total
					FROM
					%TABLE:SF3% SF3
					WHERE SF3.F3_FILIAL=%XFILIAL:SF3%
					AND SF3.F3_ENTRADA >= %EXP:DTOS(MV_PAR01)%
					AND SF3.F3_ENTRADA <= %EXP:DTOS(MV_PAR02)%
					AND SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))% 
					AND SF3.F3_CFO IN (%Exp:cCfop%)
					AND SF3.%NOTDEL%
				EndSql
				nTotVlCont := (cAliasTot)->Total
				DbSelectArea (cAliasTot)
				(cAliasTot)->(DbCloseArea())
			Else
			#ENDIF
			cIndex  := CriaTrab(NIL,.F.)
			cFiltro := 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
			cFiltro += 'DTOS(F3_ENTRADA) >= "' + DTOS(dDtInicial) + '" '
			cFiltro += '.And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFinal) + '"'
			IndRegua (cAliasTot, cIndex, SF2->(IndexKey ()),, cFiltro)
			nIndex := RetIndex(cAliasTot)
			#IFNDEF TOP
				DbSetIndex (cIndex+OrdBagExt ())
			#ENDIF
			DbSelectArea (cAliasTot)
			DbSetOrder (nIndex+1)
			#IFDEF TOP
			Endif
		#ENDIF
	EndIf

	/*Processamento dos Documentos Fiscais*/
	dbSelectArea("SF3")
	SF3->(DbSetOrder(1))
	ProcRegua(LastRec())
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			lQuery := .T.
			cAliasSF3 := GetNextAlias()

			BeginSql Alias cAliasSF3

				COLUMN F3_ENTRADA AS DATE

				SELECT F3_FILIAL,
						F3_NFISCAL,
						F3_SERIE,
						F3_ENTRADA,
						F3_TIPO,
						F3_DTCANC,
						F3_OBSERV,
						F3_CFO,
						F3_CLIEFOR,
						F3_LOJA,
						F3_VALCONT,
						F3_ESTADO
				FROM
				%TABLE:SF3% SF3
				WHERE SF3.F3_FILIAL=%XFILIAL:SF3%
				AND SF3.F3_ENTRADA >= %EXP:DTOS(MV_PAR01)%
				AND SF3.F3_ENTRADA <= %EXP:DTOS(MV_PAR02)%
				AND SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))% 
				AND SF3.F3_CFO IN (%Exp:cCfop%)
				AND SF3.%NOTDEL%
				ORDER BY %Order:SF3%
				EndSql
				DbSelectArea (cAliasSF3)
				(cAliasSF3)->(DbGoTop())
		Else
	#ENDIF
			cIndex  := CriaTrab(NIL,.F.)
			cFiltro := 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
			cFiltro += 'DTOS(F3_ENTRADA) >= "' + DTOS(dDtInicial) + '" '
			cFiltro += '.And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFinal) + '"'
			IndRegua (cAliasSF3, cIndex, SF2->(IndexKey ()),, cFiltro)
			nIndex := RetIndex(cAliasSF3)
	#IFNDEF TOP
		DbSetIndex (cIndex+OrdBagExt ())
	#ENDIF

	DbSelectArea (cAliasSF3)
	DbSetOrder (nIndex+1)
		#IFDEF TOP
	Endif
	#ENDIF

	(cAliasSF3)->(DbGoTop())
	Do While  (cAliasSF3)->(!EOF())

		lProc := .F.
		cCodMunOri := ""
		cUFOri     := ""
		cCodMunDes := ""
		cUFDest    := ""

		/* Verifica se o CFOP esta em algum dos parametros*/
		If (AllTrim((cAliasSF3)->F3_CFO)$cRG48001 .Or. AllTrim((cAliasSF3)->F3_CFO)$cRG48002 .Or. ;
			AllTrim((cAliasSF3)->F3_CFO)$cRG48003 .Or. AllTrim((cAliasSF3)->F3_CFO)$cRG48004 .Or. ;
			AllTrim((cAliasSF3)->F3_CFO)$cRG48005 .Or. AllTrim((cAliasSF3)->F3_CFO)$cRG48006 .Or. ;
			AllTrim((cAliasSF3)->F3_CFO)$cRG48007 .Or. AllTrim((cAliasSF3)->F3_CFO)$cRG48008 .Or. ;
			AllTrim((cAliasSF3)->F3_CFO)$cRG48501 .Or. AllTrim((cAliasSF3)->F3_CFO)$cRG48502 .Or. ;
			AllTrim((cAliasSF3)->F3_CFO)$cRG48503 .Or. AllTrim((cAliasSF3)->F3_CFO)$cRG48504 .Or. ;
			AllTrim((cAliasSF3)->F3_CFO)$cRG48505 .Or. AllTrim((cAliasSF3)->F3_CFO)$cRG48506 )

			lProc := .T.
			/*Prenchimento dos Tipos de Acordo com os CFOPs*/
			If AllTrim((cAliasSF3)->F3_CFO)$cRG48001
				cTipo:= "001"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48002
				cTipo:= "002"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48003
				cTipo:= "003"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48004
				cTipo:= "004"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48005
				cTipo:= "005"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48006
				cTipo:= "006"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48007
				cTipo:= "007"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48008
				cTipo:= "008"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48501
				cTipo:= "501"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48502
				cTipo:= "502"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48503
				cTipo:= "503"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48504
				cTipo:= "504"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48505
				cTipo:= "505"
			ElseIf AllTrim((cAliasSF3)->F3_CFO)$cRG48506
				cTipo:= "506"
			EndIf
		EndIf

		If lProc 

			DbSelectArea("DT6")
			DT6->(dbSetOrder(1))
			lFound := .F.
			If cTipo == "001" .And. lIntTms .And. (DT6->(MsSeek(xFilial("DT6")+(cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE)))  
				DTC->(DbSetOrder(3))
				If DT6->DT6_DOCTMS <> (StrZero(8,Len(DT6->DT6_DOCTMS)))
					/*
						Tipos de Documentos TMS
						-----------------------
						6 - CTRC Devolucao
						7 - CTRC Reentrega
						8 - CTRC Complemento
						9 - CTRC Retorno
						P - CTRC Subustituição
						M - CTRC Anulação

						Os Tipos de Documentos "6|7|8|9|P|M|", não estão relacionados com um registro da tabela DTC, para encontrar o DTC, 
						o processo abaixo busca o DT6 original para poder posicionar no DTC correspondente.					
					*/
					If ( DT6->DT6_DOCTMS $ "6|7|8|9|P|M|" )
						aArea := GetArea("DT6")
						DT6->(MsSeek (xFilial ("DT6")+DT6->DT6_FILDOC+DT6->DT6_DOCDCO+DT6->DT6_SERIE))
						lFound:= DTC->(MsSeek (xFilial ("DTC")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
						RestArea(aArea)
					Else
						lFound:= DTC->(MsSeek (xFilial ("DTC")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))
					EndIf
				Else	// CTRC COMPLEMENTAR
					lFound:= DTC->(MsSeek (xFilial ("DTC")+DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO))
				EndIf
				If lFound 
					/*Quanto o inicio do Frete for na Transportadora*/
					If DTC->DTC_SELORI == "1"
						/*Inicio do Frete*/
						If SM0->(MsSeek(cEmpAnt+cFilAnt))
							cCodMunOri := GetNewPar("MV_MUNICSC","")
							/*Se o parâmetro não estiver preenchido pego da SM0*/
							If Empty(cCodMunOri)
								cCodMunOri := Substr(SM0->M0_CIDENT,1,26)
							EndIf
							cUFOri := SM0->M0_ESTENT
						EndIf
						/*Destino do Frete*/
						//DbSelectArea( "SA1" )
						SA1->(DbSetOrder(1) )
						SA1->(MsSeek( xFilial( "SA1" )+DT6->(DT6_CLIDES+DT6_LOJDES))) 
						cUFDest := SA1->A1_EST
						If !Empty(nMvMunCli)
							cCodMunDes := SA1->(FieldGet(nMvMunCli))
						Else
							/*Se o parâmetro não estiver preenchido pego do A1_COD_MUN*/
							cCodMunDes := StrZero (Val (SA1->A1_COD_MUN), 5)
						EndIf
					/*Quanto o inicio do Frete for no Cliente*/
					ElseIf DTC->DTC_SELORI == "2" 
						/*Inicio do Frete*/
						//DbSelectArea("SA1")
						SA1->(MsSeek(xFilial("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM)))
						cUFOri := SA1->A1_EST
						If !Empty(nMvMunCli)
							cCodMunOri := SA1->(FieldGet(nMvMunCli))					
						Else
							/*Se o parâmetro não estiver preenchido pego do A1_COD_MUN*/
							cCodMunOri := StrZero(Val(SA1->A1_COD_MUN), 5)
						EndIf
						/*Encontrando o Destino do Frete*/
						//DbSelectArea("SA1")
						SA1->(DbSetOrder(1))
						SA1->(MsSeek(xFilial("SA1")+DT6->(DT6_CLIDES+DT6_LOJDES))) 
						cUFDest := SA1->A1_EST
						If !Empty(nMvMunCli)
							cCodMunDes := SA1->(FieldGet(nMvMunCli))
						Else
							/*Se o parâmetro não estiver preenchido pego do A1_COD_MUN*/
							cCodMunDes := StrZero(Val(SA1->A1_COD_MUN), 5)
						EndIf
					ElseIf DTC->DTC_SELORI == "3"
						If !Empty(DTC->DTC_NUMSOL)  /*Origem e Local de Coleta*/
							/*Inicio do Frete*/
							/*Posiciona na Ordem de Coleta*/
							DT5->(DbSetOrder(1))
							If DT5->(MsSeek(xFilial("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL))
								/*Verifica se o Solicitante tem Sequencias de Endereco*/
								If Empty(DT5->DT5_SEQEND)
									DUE->(dbSetOrder(1))
									If !lDUESol
										DUE->(MsSeek(xFilial("DUE")+DT5->(DT5_DDD+DT5_TEL)))
									Else
										DUE->(MsSeek(xFilial("DUE")+DT5->DT5_CODSOL))
									EndIf
									If !Empty(GetNewPar("MV_MUNDUE",""))
										nMvMunDUE := DUE->(FieldPos((GetNewPar("MV_MUNDUE",""))))
									Endif
									IF !Empty(nMvMunDUE)
										cUFOri     := Substr(DUE->(FieldGet(nMvMunDUE)),1,2)
										cCodMunOri := Substr(DUE->(FieldGet(nMvMunDUE)),3,5)
									EndIf
								Else
									If !lDUESol
										DUL->(dbSetOrder(1))
										DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_DDD+DT5_TEL+DT5_SEQEND)))
									Else
										DUL->(dbSetOrder(3))
										DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_CODSOL+DT5_SEQEND)))
									EndIf
									If !Empty(GetNewPar("MV_MUNDUL",""))
										nMvMunDUL := DUL->(FieldPos((GetNewPar("MV_MUNDUL",""))))
									Endif
									IF !Empty(nMvMunDUL)
										cUFOri     := Substr(DUL->(FieldGet(nMvMunDUL)),1,2)
										cCodMunOri := Substr(DUL->(FieldGet(nMvMunDUL)),3,5)
									EndIf
								EndIf
							EndIf
							/*Destino do Frete*/
							/*Encontrando o Destino do Frete*/
							//DbSelectArea("SA1")
							SA1->(DbSetOrder(1))
							SA1->(MsSeek(xFilial("SA1")+DTC->(DTC_CLIDES+DTC_LOJDES)))
							cUFDest := SA1->A1_EST
							If !Empty(nMvMunCli)
								cCodMunDes := SA1->(FieldGet(nMvMunCli))
							Else
								/*Se o parâmetro não estiver preenchido pego do A1_COD_MUN*/
								cCodMunDes := StrZero(Val(SA1->A1_COD_MUN), 5)
							EndIf
						Else
							// Considera como Origem o Expedidor
							If !Empty(DTC->DTC_CLIEXP)
								//DbSelectArea("SA1")
								SA1->(MsSeek(xFilial("SA1")+DT6->(DT6_CLIEXP+DT6_LOJEXP)))
								cUFOri := SA1->A1_EST
								If !Empty(nMvMunCli)
									cCodMunOri := SA1->(FieldGet(nMvMunCli))					
								Else
									/*Se o parâmetro não estiver preenchido pego do A1_COD_MUN*/
									cCodMunOri := StrZero(Val(SA1->A1_COD_MUN), 5)
								EndIf
								//DbSelectArea("SA1")
								SA1->(DbSetOrder(1))
								SA1->(MsSeek(xFilial("SA1")+DTC->(DTC_CLIDES+DTC_LOJDES)))
								cUFDest := SA1->A1_EST
								If !Empty(nMvMunCli)
									cCodMunDes := SA1->(FieldGet(nMvMunCli))
								Else
									/*Se o parâmetro não estiver preenchido pego do A1_COD_MUN*/
									cCodMunDes := StrZero(Val(SA1->A1_COD_MUN), 5)
								EndIf
							Endif
						EndIf
					EndIf
				EndIf

				cCodMunArq := cCodMunOri
						
				If  DTC->DTC_SELORI == "3"
					If  (cUFOri <> "SC" .and. cUFDest <> "SC")
						Loop	
					Endif
				ElseIf (cCodMunOri == cCodMunDes .And. cUFOri == cUFDest) .Or. (cUFDest == "EX") .Or. (cUFOri <> "SC")
					(cAliasSF3)->(dbSkip())
					Loop
				EndIf

			Else
				If (SubStr((cAliasSF3)->F3_CFO , 1 , 1 )>="5") /*Saida*/
					If (AllTrim((cAliasSF3)->F3_TIPO)$"DB") /*Devolução ou Beneficiamento*/
						//DbSelectArea("SA2")
						SA2->(DbSetOrder(1))
						SA2->(MsSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+SF3->F3_LOJA))
						cUFDest := SA2->A2_EST
						If !Empty(nMvMunFor)
							cCodMunDes := SA2->(FieldGet(nMvMunFor))
						Else
							cCodMunDes := StrZero(Val(SA2->A2_COD_MUN), 5)
						EndIf
					Else
						//DbSelectArea("SA1") /*Saida Normal*/
						SA1->(DbSetOrder(1))
						SA1->(MsSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
						cUFDest := SA1->A1_EST
						If !Empty(nMvMunCli)
							cCodMunDes := SA1->(FieldGet(nMvMunCli))
						Else
							cCodMunDes := StrZero(Val(SA1->A1_COD_MUN), 5)
						EndIf
					EndIf
				Else /* Entrada*/
					If (AllTrim(SF3->F3_TIPO )$"DB")  /*Devolução ou Beneficiamento*/
						//DbSelectArea("SA1")
						SA1->(DbSetOrder(1))
						SA1->(MsSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
						If !Empty(nMvMunCli)
							cCodMunDes := SA1->(FieldGet(nMvMunCli))
						Else
							cCodMunDes := StrZero(Val(SA1->A1_COD_MUN), 5)
						EndIf
					Else /* Entrada Normal*/
						//DbSelectArea("SA2")
						SA2->(DbSetOrder(1))
						SA2->(MsSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
						If !Empty(nMvMunFor)
							cCodMunDes := SA2->(FieldGet(nMvMunFor))
						Else
							cCodMunDes := StrZero(Val(SA2->A2_COD_MUN), 5)
						EndIf
					EndIf
				EndIf
				cCodMunArq := cCodMunDes
			EndIf

			/*Se for em % o codigo sempre será 901*/
			If  aWizard[23][1]=='Sim'
				cTipo := "901"
			Endif

			nValDoc := (cAliasSF3)->F3_VALCONT
			nPerc := ((cAliasSF3)->F3_VALCONT * 100)/nTotVlCont	

			If lDMSCTP // Ponto de entrada para ajuste do Tipo
				aInf48 := {}			
				aAdd (aInf48, {"FILIAL",(cAliasSF3)->F3_FILIAL })
				aAdd (aInf48, {"NUM.DOC.",(cAliasSF3)->F3_NFISCAL })
				aAdd (aInf48, {"SERIE",(cAliasSF3)->F3_SERIE })
				aAdd (aInf48, {"DT.ENTRADA",(cAliasSF3)->F3_ENTRADA })
				aAdd (aInf48, {"TIPO DOC.",(cAliasSF3)->F3_TIPO })
				aAdd (aInf48, {"DT. CANCEL",(cAliasSF3)->F3_DTCANC })
				aAdd (aInf48, {"OBSERVAÇÃO",(cAliasSF3)->F3_OBSERV })
				aAdd (aInf48, {"CFOP",(cAliasSF3)->F3_CFO })
				aAdd (aInf48, {"CLI/FOR",(cAliasSF3)->F3_CLIEFOR })
				aAdd (aInf48, {"LOJA",(cAliasSF3)->F3_LOJA })
				aAdd (aInf48, {"VAL DOC",(cAliasSF3)->F3_VALCONT })
				aAdd (aInf48, {"ESTADO",(cAliasSF3)->F3_ESTADO })
				aAdd (aInf48, {"TIPO REG",cTipo })		
				aAdd (aInf48, {"Cod Municipio",cCodMunArq })			
				
				aTpAux := ExecBlock("DMSC48TP",.F.,.F.,aInf48)	

				If  ValType(aTpAux) == "A" .And. Len(aTpAux) == 3 
					If ValType(aTpAux[1]) == "C"
						cCodMunArq := aTpAux[1]
					Endif
					If ValType(aTpAux[2]) == "C"
						cTipo := aTpAux[2]
					Endif
					If ValType(aTpAux[3]) == "N"
						nValDoc := aTpAux[3]
						nPerc := aTpAux[3]					
					EndIf				
				EndIf
			EndIf			

			If (R48->(MsSeek("4848"+AllTrim(cCodMunArq)+cTipo)))
				RecLock("R48", .F.)
				If aWizard[23][1]=='Sim' .And. nTotVlCont > 0 .And. substr((cAliasSF3)->F3_CFO,1,1)>="5"					
					R48->R48_VALOR += nPerc
					R48->(MSunlock())
					nAcTotal += nPerc
				ElseIf aWizard[23][1]=='Não'
					R48->R48_VALOR += nValDoc					
					R48->(MSunlock())
					nAcTotal += nValDoc					
				EndIf
			Else
				RecLock ("R48",.T.)
				R48->R48_REGIST	:= "48"
				R48->R48_QUADRO	:= "48"
				R48->R48_MUNIC	:= AllTrim(cCodMunArq)
				R48->R48_TIPO	:= cTipo
				If aWizard[23][1]=='Sim' .And. nTotVlCont > 0 .And. substr((cAliasSF3)->F3_CFO,1,1)>="5" 					
					R48->R48_VALOR := nPerc
					R48->(MSunlock())
					nAcTotal += nPerc
				ElseIf aWizard[23][1]=='Não'
					R48->R48_VALOR := nValDoc
					R48->(MSunlock())
					nAcTotal += nValDoc
				EndIf
			EndIf			
		EndIf

		(cAliasSF3)->(DbSkip())
	EndDo
	If lQuery
		(cAliasSF3)->(DbCloseArea())
	EndIf
Next

RecLock ( "R48", .T. )
R48->R48_REGIST := "48"
R48->R48_QUADRO := "48"
R48->R48_MUNIC  := "99999"
R48->R48_VALOR  := nAcTotal
R48->R48_TIPO   := "999"
MsUnLock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a filial e area corrente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArea := GetArea()
RestArea(aAreaSM0)
cFilAnt := SM0->M0_CODFIL
RestArea(aArea)

Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME4950  ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 49 e 50 para o meio-magnetico.     ³±±
±±³          ³                                                            ³±±
±±³          ³                  ENTRADAS/SAIDAS POR UF                    ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do SF3 e resumindo³±±
±±³          ³ por estado.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±³          ³lMVIT4910 -> Flag de existendia do parametro MV_IT4910      ³±±
±±³          ³lMVIT4911 -> Flag de existendia do parametro MV_IT4911      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME4950 (aWizard, lMVIT4910, lMVIT4911,aTentr,aTsaid)
	Local	cMVIT4910	:=	Iif (lMVIT4910, SuperGetMv ("MV_IT4910"), "")
	Local	cMVIT4911	:=	Iif (lMVIT4911, SuperGetMv ("MV_IT4911"), "")
	Local	aTotalTUF	:=	{}
	Local	nPos		:=	0
	Local	nCont		:=	0
	Local	nX			:=	0
	Default aTentr		:=	{}
	Default	aTsaid		:=	{}
	//	
	EST->( DbGoTop() )
	Do While !EST->(Eof ())
		nCont := aScan(aTsaid, {|ax| ax[1] == EST->UF})
		nX := aScan(aTentr, {|ax| ax[1] == EST->UF}) 
		If (SubStr (AllTrim (EST->CFOP), 1, 1)=="S") 
			If (TUF->(DbSeek ("5050"+AllTrim (EST->UF))))
				RecLock ("TUF", .F.)
			Else
				RecLock ("TUF", .T.)
				TUF->TUF_REGIST	:=	"50"
				TUF->TUF_QUADRO	:=	"50"
				TUF->TUF_UF		:=	AllTrim (EST->UF)
			EndIf
			TUF->TUF_VLNCON		+=	EST->VALCONNC
			TUF->TUF_BSNCAL		+=	EST->BASEICNC
			TUF->TUF_ICMSST		+=	Iif(Len(aTsaid) > 0 .And. nCont > 0, aTsaid[nCont][04], 0)
			TUF->TUF_VLRCON		+=	EST->VALCONC
			TUF->TUF_BSCALC		+=	EST->BASEICC
		Else
			If (TUF->(DbSeek ("4949"+AllTrim (EST->UF))))
				RecLock ("TUF", .F.)
			Else
				RecLock ("TUF", .T.)
					TUF->TUF_REGIST	:=	"49"
					TUF->TUF_QUADRO	:=	"49"
					TUF->TUF_UF		:=	AllTrim (EST->UF)
			EndIf
			//
			TUF->TUF_PETROL		+=	Iif (AllTrim (EST->CFOP)$cMVIT4910 .And. EST->ICMSRET>0, EST->ICMSRET, 0)
			TUF->TUF_OUTRST		+=	Iif (AllTrim (EST->CFOP)$cMVIT4911 .And. Len(aTentr)>0 .And. nX>0, aTentr[nX][04], 0)
			TUF->TUF_VLRCON		+=	EST->VALCONC+EST->VALCONNC
			TUF->TUF_BSCALC		+=	EST->BASEICC+EST->BASEICNC
		EndIf
			//
		TUF->TUF_OUTRAS		+=	EST->OUTRICM+EST->ISENICM
		MsUnLock ()
		//
		EST->(DbSkip ())
	EndDo
	//
	DbSelectArea ("TUF")
		TUF->(DbGoTop ())
	//
	Do While !TUF->(Eof ())
		nPos := aScan(aTotalTUF, {|x| x[1]==TUF->TUF_REGIST})
		If (npos==0)
			aAdd (aTotalTUF, {TUF->TUF_REGIST, TUF->TUF_QUADRO, "TT", TUF->TUF_VLNCON, TUF->TUF_BSNCAL, TUF->TUF_VLRCON, TUF->TUF_BSCALC, TUF->TUF_OUTRAS, TUF->TUF_PETROL, TUF->TUF_OUTRST, TUF->TUF_ICMSST})
		Else
			aTotalTUF[nPos][4]	+=	TUF->TUF_VLNCON
			aTotalTUF[nPos][5]	+=	TUF->TUF_BSNCAL
			aTotalTUF[nPos][6]	+=	TUF->TUF_VLRCON
			aTotalTUF[nPos][7]	+=	TUF->TUF_BSCALC
			aTotalTUF[nPos][8]	+=	TUF->TUF_OUTRAS
			aTotalTUF[nPos][9]	+=	TUF->TUF_PETROL
			aTotalTUF[nPos][10]	+=	TUF->TUF_OUTRST
			aTotalTUF[nPos][11]	+=	TUF->TUF_ICMSST
		EndIf
		//
		TUF->(DbSkip ())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Acrescento os totalizadores TT do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nPos := 1 To Len (aTotalTUF)
		RecLock ("TUF", .T.)
			TUF->TUF_REGIST		:=	aTotalTUF[nPos][1]
			TUF->TUF_QUADRO		:=	aTotalTUF[nPos][2]
			TUF->TUF_UF			:=	aTotalTUF[nPos][3]
			TUF->TUF_VLNCON		:=	aTotalTUF[nPos][4]
			TUF->TUF_BSNCAL		:=	aTotalTUF[nPos][5]
			TUF->TUF_VLRCON		:=	aTotalTUF[nPos][6]
			TUF->TUF_BSCALC		:=	aTotalTUF[nPos][7]
			TUF->TUF_OUTRAS		:=	aTotalTUF[nPos][8]
			TUF->TUF_PETROL		:=	aTotalTUF[nPos][9]
			TUF->TUF_OUTRST		:=	aTotalTUF[nPos][10]
			TUF->TUF_ICMSST		:=	aTotalTUF[nPos][11]
		MsUnLock ()
	Next (nPos)
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME51    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do registro 51 para o meio-magnetico.            ³±±
±±³          ³                                                            ³±±
±±³          ³          EXCLUSOES DO VALOR ADICIONADO NO MES              ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes das apuracoes efetuadas anterior- ³±±
±±³          ³ mente.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME51 (aWizard,aExclVlAd)
	Local	aValor	:=	{0,0,0,0,0,0,0,0,0,0}	
						//1-Prestacao de serviços sujeita ao ISS, se foi lançada no Quadro 01 - Valores fiscais das entradas
						//2-25% das transferências recebidas a preço de venda a varejo
						//3-Tributo a recuperar incidente na entrada de mercadoria transferida a preço de custo para estabelecimento da mesma empresa
						//4-IPI relativo à aquisição de matérias-primas e mercadorias, se foi lançada no Quadro 01 - Valores fiscais das entradas
						//5-Parcela do ICMS retido por (Substituição Tributária), se foi lançada no Quadro 01 - Valores fiscais das entradas
						//6-Subsídios concedidos por órgãos dos governos federal, estadual ou municipal 
						//7-Prestação de serviços sujeita ao ISS, se foi lançada no Quadro  02 - Valores fiscais das saídas
						//8-25% das transferências efetuadas a preço de venda a varejo
						//9-IPI incidente na saída de mercadorias, se foi lançada no Quadro 02- Valores fiscais das saídas
						//10-Parcela do ICMS retido por Substituição Tributária, se foi lançada no Quadro 02 - Valores fiscais das saídas
	Local	aTotal		:=	{0,0}	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para todos os tipos de apuracao e declaracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ENTRADAS
	aValor[01]	:=	Val (aWizard[12][1])
	aValor[02]	:=	Val (aWizard[12][2])
	aValor[03]	:=	Val (aWizard[12][3])
	aValor[04]	:=	Val (aWizard[12][4])
	aValor[05]	:=	Val (aWizard[12][5])
	aValor[06]	:=	Val (aWizard[12][6])

	//Quando informado na wizard não alterar, caso contrario utiliza o calculado pelo sistema do registo 01 
	If aValor[01] == 0 .and. aExclVlAd[1] > 0
		aValor[01] := aExclVlAd[1]
	Endif
	aTotal[01]	:=	aValor[01]+aValor[02]+aValor[03]+aValor[04]+aValor[05]+aValor[06]
	//SAIDAS
	aValor[07]	:=	Val (aWizard[13][1])
	aValor[08]	:=	Val (aWizard[13][2])
	aValor[09]	:=	Val (aWizard[13][3])
	aValor[10]	:=	Val (aWizard[13][4])

	//Quando informado na wizard não alterar, caso contrario utiliza o calculado pelo sistema do registo 02
	If aValor[07] == 0 .and. aExclVlAd[2] > 0
		aValor[07] := aExclVlAd[2]
	Endif

	aTotal[02]	:=	aValor[07]+aValor[08]+aValor[09]+aValor[10]
	//Prestacao de serviços sujeita ao ISS, se foi lançada no Quadro 01 - Valores fiscais das entradas
	AtuVlrDime(, "51", "51", "010", aValor[01], 2)
	//25% das transferências recebidas a preço de venda a varejo
	AtuVlrDime(, "51", "51", "020", aValor[02], 2)
	//Tributo a recuperar incidente na entrada
	AtuVlrDime(, "51", "51", "021", aValor[03], 2)
	//
	If (aWizard[3][3]) < dCorte
		//IPI relativo à aquisição de matérias-primas e mercadorias, se foi lançada no Quadro 01 - Valores fiscais das entradas
 		AtuVlrDime(, "51", "51", "030", aValor[04], 2)
		//Parcela do ICMS retido por (Substituição Tributária), se foi lançada no Quadro 01 - Valores fiscais das entradas
		AtuVlrDime(, "51", "51", "040", aValor[05], 2)
	EndIf
	//Subsídios concedidos por órgãos dos governos federal, estadual ou municipal 
	AtuVlrDime(, "51", "51", "050", aValor[06], 2)
	//Prestação de serviços sujeita ao ISS, se foi lançada no Quadro  02 - Valores fiscais das saídas
	AtuVlrDime(, "51", "51", "060", aValor[07], 2)
	//25% das transferências efetuadas a preço de venda a varejo
	AtuVlrDime(, "51", "51", "070", aValor[08], 2)
	//
	If (aWizard[3][3]) < dCorte
		//IPI incidente na saída de mercadorias, se foi lançada no Quadro 02- Valores fiscais das saídas
   	AtuVlrDime(, "51", "51", "080", aValor[09], 2)
		//Parcela do ICMS retido por Substituição Tributária, se foi lançada no Quadro 02 - Valores fiscais das saídas
		AtuVlrDime(, "51", "51", "090", aValor[10], 2)
	EndIf
	//Total dos valores excluídos das entradas
	AtuVlrDime(, "51", "51", "980", aTotal[1], 2)
	//Total dos valores excluídos das saídas
	AtuVlrDime(, "51", "51", "990", aTotal[2], 2)
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME80    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 80 para o meio-magnetico.          ³±±
±±³          ³                                                            ³±±
±±³          ³     RESUMO DO LIVRO REGISTRO INVENTARIO E RECEITA BRUTA    ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do CFP.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME80 (aWizard)
	Local	aInv		:=	{"INV",""}
	Local	nAcEstIni	:=	0
	Local	nAcEstFim	:=	0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para declaracao NORMAL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "Sim" $ AllTrim(aWizard[3][1]) .And. !Empty(AllTrim(aWizard[3][3]))		//Inventario
		
		/* 
		
		*** Gera quadro 80 zerado ***
		 
		Conforme a portaria SEF 153/2012, item 3.3.1.1 do ANEXO I: 
		
		a.3) os itens 010 e 020 serão preenchidos com 0 (zero), sempre que:
			a.3.1) o valor do estoque for igual a 0 (zero);
			a.3.2) o declarante tiver iniciado a atividades no exercício corrente.
		
		*/
		
		If "Sim" $ AllTrim(aWizard[3][2])
			nAcEstIni := 0
			nAcEstFim := 0
		Else
			// Apenas ira processar o estoque pelo FsEstInv quando nao for lancado o valor de estoque na wizard
			If Val(aWizard[3][4]) == 0
				FsEstInv (aInv, 1, .T., .F., StoD (AllTrim (aWizard[3][3])),,,,,,,,,, aFilsCalc, .T.,,, )
				INV->(DbGoTop ())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicio do exercicio³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do While !INV->(Eof ())
					nAcEstIni	+=	INV->CUSTO
					//
					INV->(DbSkip ())
				EndDo
				FsEstInv (aInv, 2)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Fim do exercicio³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FsEstInv (aInv, 1, .T., .F., StoD (AllTrim (aWizard[3][5])),,,,,,,,,, aFilsCalc, .T.,,, )
				INV->(DbGoTop ())
				//
				Do While !INV->(Eof ())
					nAcEstFim	+=	INV->CUSTO
					//
					INV->(DbSkip ())
				EndDo
				FsEstInv (aInv, 2)
			Else 
				nAcEstIni := Val(aWizard[3][4])
				nAcEstFim := Val(aWizard[3][6])
			Endif			
		Endif
		//
		//Estoque no inicio do periodo
		AtuVlrDime(, "80", "80", "010", nAcEstIni, 2)
		//
		//Estoque no fim do periodo
		AtuVlrDime(, "80", "80", "020", nAcEstFim, 2)
		//
		//Receita Bruta de vendas e servicos
		AtuVlrDime(, "80", "80", "030", Val (aWizard[3][7]), 2)	//Contribuintes que possui escrita contabil nao informar este campo no wizard.
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME81    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 81 para o meio-magnetico.          ³±±
±±³          ³                                                            ³±±
±±³          ³                              ATIVO                         ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do CFP.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME81 (aWizard)
	Local	nCirculante	:=	0
	Local	nRealizavel	:=	0
	Local	nPermanente	:=	0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para declaracao NORMAL e quando estiver escrita contabil³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty (AllTrim (aWizard[3][3])) .And.;		//Inventario
		("1"==Iif ("dados"$aWizard[2][11], "3", Iif("Não"$aWizard[2][11], "2","1")))	//Com escrita contabil
		nCirculante	:=	Val (aWizard[4][1])	//Disponibilidades
		nCirculante	+=	Val (aWizard[4][2])	//Contas a receber do circulante
		nCirculante	+=	Val (aWizard[4][3])	//Estoque de mercadorias e materia-prima
		nCirculante	+=	Val (aWizard[4][4])	//Outros estoques
		nCirculante	+=	Val (aWizard[4][5])	//Outras contas do ativo circulantes
		//
		nRealizavel	:=	Val (aWizard[4][6])
		nRealizavel	+=	Val (aWizard[4][7])
		//
		nPermanente	:=	Val (aWizard[4][8])		//Investimentos
		nPermanente	+=	Val (aWizard[4][9])		//Imobilizado
		nPermanente	+=	Val (aWizard[4][10])	//Diferido
		nPermanente	+=	Val (aWizard[4][11])	//Intangivel
		//
		//110 - Circulante
		AtuVlrDime(, "81", "81", "110", nCirculante, 2)
		//
		//111 - Disponibilidades
		AtuVlrDime(, "81", "81", "111", Val (aWizard[4][1]), 2)
		//
		//113 - Contas a receber do circulante
		AtuVlrDime(, "81", "81", "113", Val (aWizard[4][2]), 2)
		//
		//121 - Estoque de mercadorias e materia-prima
		AtuVlrDime(, "81", "81", "121", Val (aWizard[4][3]), 2)
		//
		//123 - Outros estoques
		AtuVlrDime(, "81", "81", "123", Val (aWizard[4][4]), 2)
		//
		//128 - Outras contas do ativo circulantes
		AtuVlrDime(, "81", "81", "128", Val (aWizard[4][5]), 2)
		//
		//130 - Realizavel a longo prazo
		AtuVlrDime(, "81", "81", "130", nRealizavel, 2)
		//
		//131 - Contas a receber do realizavel
		AtuVlrDime(, "81", "81", "131", Val (aWizard[4][6]), 2)
		//
		//148 - Outras contas do realizavel
		AtuVlrDime(, "81", "81", "148", Val (aWizard[4][7]), 2)
		//
		//Permanente
		AtuVlrDime(, "81", "81", "150", nPermanente, 2)
		//
		//Investimentos
		AtuVlrDime(, "81", "81", "151", Val (aWizard[4][8]), 2)
		//
		//Imobilizado
		AtuVlrDime(, "81", "81", "155", Val (aWizard[4][9]), 2)
		//
		//Diferido
		AtuVlrDime(, "81", "81", "157", Val (aWizard[4][10]), 2)
        		
		//Intangivel
    	If StrZero(Year (MV_PAR02),4)+StrZero(Month (MV_PAR02),2) >= "201201"
    		AtuVlrDime(, "81", "81", "159", Val (aWizard[4][11]), 2)                            
		EndIf
		//
		//Total Geral do Ativo
		AtuVlrDime(, "81", "81", "199", nCirculante+nRealizavel+nPermanente, 2)
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME82    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 82 para o meio-magnetico.          ³±±
±±³          ³                                                            ³±±
±±³          ³                         PASSIVO                            ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do CFP.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME82 (aWizard)
	Local	nCirculante	:=	0
	Local	nPatrimonio	:=	0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para declaracao NORMAL e quando estiver escrita contabil³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty (AllTrim (aWizard[3][3])) .And.;		//Inventario
		("1"==Iif ("dados"$aWizard[2][11], "3", Iif("Não"$aWizard[2][11], "2","1")))	//Com escrita contabil
		//
		nCirculante	:=	Val (aWizard[5][1])	//Fornecedores
		nCirculante	+=	Val (aWizard[5][2])	//Emprestimos e Financiamentos
		nCirculante	+=	Val (aWizard[5][3])	//Outras contas do passivo circulante
		//
		nPatrimonio	:=	Val (aWizard[5][6])	//Capital Social
		nPatrimonio	+=	Val (aWizard[5][7])	//Outras contas do Patrimonio Liquido
		nPatrimonio	-=	Val (aWizard[5][8])	
		//
		//Circulante
		AtuVlrDime(, "82", "82", "210", nCirculante, 2)
		//
		//Fornecedores
		AtuVlrDime(, "82", "82", "211", Val (aWizard[5][1]), 2)
		//
		//Emprestimos e Financiamentos
		AtuVlrDime(, "82", "82", "213", Val (aWizard[5][2]), 2)
		//
		//Outras contas do passivo circulante
		AtuVlrDime(, "82", "82", "215", Val (aWizard[5][3]), 2)
		//
		//Exigivel a longo prazo
		AtuVlrDime(, "82", "82", "230", Val (aWizard[5][4]), 2)
		//
		//Resultados de exercicios futuros
		AtuVlrDime(, "82", "82", "240", Val (aWizard[5][5]), 2)
		
		If nPatrimonio<0
			//Passivo descoberto
			AtuVlrDime(, "82", "82", "269", Abs(nPatrimonio), 2)
		Else
			//Patrimonio Liquido
			AtuVlrDime(, "82", "82", "270", nPatrimonio, 2)
		EndIf
		
		//
		//Capital Social
		AtuVlrDime(, "82", "82", "271", Val (aWizard[5][6]), 2)
		//		
		//Outras contas do Patrimonio Liquido
		AtuVlrDime(, "82", "82", "278", Val (aWizard[5][7]), 2)
		//
		//Outras contas do Patrimonio Liquido (Negativo)
		AtuVlrDime(, "82", "82", "279", Val (aWizard[5][8]), 2)
		//
		//Total Geral do Passivo
		AtuVlrDime(, "82", "82", "299", nCirculante+nPatrimonio+Val(aWizard[5][4])+Val(aWizard[5][5]), 2)
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME83    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 83 para o meio-magnetico.          ³±±
±±³          ³                                                            ³±±
±±³          ³                DEMONSTRACAO DE RESULTADOS                  ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do CFP.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³BREVE RESUMO PARA PREENCHIMENTO DESTE QUADRO NO WIZARD³
		³320 = 310 - 311                                       ³
		³330/331 = 320 - 323                                   ³
		³340/341 = 330/331 + 333 - 335                         ³
		³350/351 = 340/341 + 343 - 345                         ³
		³360/361 = 350/351 - 353                               ³
		³398/399 = 360/361 - 363                               ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Static Function DIME83 (aWizard)
	Local	nReceita	:=	0
	Local	nLucPrej	:=	0
	Local	nOpLucPre	:=	0
	Local	nNOpLucPre	:=	0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para declaracao NORMAL e quando estiver escrita contabil³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty (AllTrim (aWizard[3][3])) .And.;		//Inventario
		("1"==Iif ("dados"$aWizard[2][11], "3", Iif("Não"$aWizard[2][11], "2","1")))	//Com escrita contabil
		//
		nReceita	:=	Val (aWizard[6][1])-Val (aWizard[6][2])
		nLucPrej	:=	nReceita-Val (aWizard[6][3])
		nOpLucPre	:=	nLucPrej+Val (aWizard[6][4])-Val (aWizard[6][5])		
		nNOpLucPre	:=	nOpLucPre+Val (aWizard[6][6])-Val (aWizard[6][7])
		//
		//310-Receita bruta vendas/servico
		AtuVlrDime(, "83", "83", "310", Val (aWizard[6][1]), 2)		
		//
		//311-Devolucoes/Abatimentos e impostos
		AtuVlrDime(, "83", "83", "311", Val (aWizard[6][2]), 2)
		//
		//320-Receita liquida venda/servicos
		AtuVlrDime(, "83", "83", "320", nReceita, 2)
		//
		//323-Custo da mercadoria vendida
		AtuVlrDime(, "83", "83", "323", Val (aWizard[6][3]), 2)
		//
		If (nLucPrej>0)
			//330-Lucro Bruto
			AtuVlrDime(, "83", "83", "330", Abs (nLucPrej), 2)
		Else
			//331-Prejuizo Bruto
			AtuVlrDime(, "83", "83", "331", Abs (nLucPrej), 2)
		EndIf
		//
		//333-Outras Receitas Operacionais
		AtuVlrDime(, "83", "83", "333", Val (aWizard[6][4]), 2)
		//
		//335-Despesas operacionais
		AtuVlrDime(, "83", "83", "335", Val (aWizard[6][5]), 2)
		//
		If (nOpLucPre>0)
			//340-Lucro operacional
			AtuVlrDime(, "83", "83", "340", Abs (nOpLucPre), 2)
		Else
			//341-Prejuizo operacional
			AtuVlrDime(, "83", "83", "341", Abs (nOpLucPre), 2)
		EndIf
		//
		//343-Receitas nao operacionais
		AtuVlrDime(, "83", "83", "343", Val (aWizard[6][6]), 2)
		//
		//345-Despesas nao operacionais
		AtuVlrDime(, "83", "83", "345", Val (aWizard[6][7]), 2)
		//
		If (nNOpLucPre>0)
			//350-Resultado antes do IR
			AtuVlrDime(, "83", "83", "350", Abs (nNOpLucPre), 2)
		Else
			//351-Resultado negativo antes do IR e da contribuicao social
			AtuVlrDime(, "83", "83", "351", Abs (nNOpLucPre), 2)
		EndIf
		//
		//353-Provisao para o IR
		AtuVlrDime(, "83", "83", "353", Val (aWizard[6][8]), 2)		
		//
		//354-Provisão para o IR e para contribuição social
		AtuVlrDime(, "83", "83", "354", Val (aWizard[6][9]), 2)
		
		If (nNOpLucPre- Val(aWizard[6][8]) + Val(aWizard[6][9])) > 0
			//360-Resultado apos o IR
			AtuVlrDime(, "83", "83", "360", Abs (nNOpLucPre - Val(aWizard[6][8])+ Val(aWizard[6][9])), 2)
		Else
			//361-Resultado negativo apos o IR e Contribuicao Social
			AtuVlrDime(, "83", "83", "361", Abs (nNOpLucPre - Val(aWizard[6][8])+ Val(aWizard[6][9])), 2)
		EndIf
		//
		//363-Participacoes e contribuicoes
		AtuVlrDime(, "83", "83", "363", Val (aWizard[6][10]), 2)
		//
		If (nNOpLucPre - Val(aWizard[6][8]) + Val(aWizard[6][9]) - Val(aWizard[6][10]))>0
			//399-Lucro do Exercicio
			AtuVlrDime(, "83", "83", "399", Abs (nNOpLucPre - Val(aWizard[6][8]) + Val(aWizard[6][9]) - Val(aWizard[6][10])), 2)
		ElseIf (nNOpLucPre - Val(aWizard[6][8]) + Val(aWizard[6][9]) - Val(aWizard[6][10]))==0
			//399-Sem Movimento		
			AtuVlrDime(, "83", "83", "399", 0, 2)
		Else
			//398-Prejuizo do Exercicio
			AtuVlrDime(, "83", "83", "398", Abs (nNOpLucPre - Val(aWizard[6][8]) + Val(aWizard[6][9]) - Val(aWizard[6][10])), 2)
		EndIf
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME84    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 84 para o meio-magnetico.          ³±±
±±³          ³                                                            ³±±
±±³          ³                 DETALHAMENTO DAS DESPESAS                  ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do CFP.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIME84 (aWizard)
	Local	nTotal	:=	0
	Local	nI		:=	0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para declaracao NORMAL independente da escrita contabil ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty (AllTrim (aWizard[3][3]))
		//
		//Pro-labore
		AtuVlrDime(, "84", "84", "411", Val (aWizard[7][1]), 2)
		//
		//Conissoes, salarios ou ordenados
		AtuVlrDime(, "84", "84", "412", Val (aWizard[7][2]), 2)
		//
		//Combustiveis e Lubrificantes
		AtuVlrDime(, "84", "84", "431", Val (aWizard[7][3]), 2)
		//
		//Encargos sociais
		AtuVlrDime(, "84", "84", "421", Val (aWizard[7][4]), 2)
		//
		//Tributos federais
		AtuVlrDime(, "84", "84", "422", Val (aWizard[7][5]), 2)
		//
		//Tributos estaduais
		AtuVlrDime(, "84", "84", "423", Val (aWizard[7][6]), 2)
		//
		//Tributos municipais
		AtuVlrDime(, "84", "84", "424", Val (aWizard[7][7]), 2)
		//
		//Agua e telefone
		AtuVlrDime(, "84", "84", "432", Val (aWizard[7][8]), 2)
		//
		//Energia eletrica
		AtuVlrDime(, "84", "84", "433", Val (aWizard[7][9]), 2)
		//
		//Alugueis
		AtuVlrDime(, "84", "84", "441", Val (aWizard[7][10]), 2)
		//
		//Servicos profissionais
		AtuVlrDime(, "84", "84", "451", Val (aWizard[7][11]), 2)
		//
		//Seguros
		AtuVlrDime(, "84", "84", "442", Val (aWizard[7][12]), 2)
		//
		//Fretes e carretos
		AtuVlrDime(, "84", "84", "443", Val (aWizard[7][13]), 2)
		//
		//Despesas financeiras
		AtuVlrDime(, "84", "84", "461", Val (aWizard[7][14]), 2)
		//
		//Outras despesas
		AtuVlrDime(, "84", "84", "498", Val (aWizard[7][15]), 2)
		//
		//Totalizador
		For nI :=1 To Len (aWizard[7])
			nTotal	+=	Val (aWizard[7][nI])
		Next (nI)
		//
		//Total
		AtuVlrDime(, "84", "84", "499", nTotal, 2)
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME90    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 90 para o meio-magnetico.          ³±±
±±³          ³                                                            ³±±
±±³          ³     RESUMO DO LIVRO REGISTRO INVENTARIO E RECEITA BRUTA    ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do CFP.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME90 (aWizard)
	Local	aInv		:=	{"INV",""}
	Local	nAcEstIni	:=	0
	Local	nAcEstFim	:=	0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para declaracao NORMAL³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty (AllTrim (aWizard[17][1]))		//Inventario
		//       
        // Apenas ira processar o estoque pelo FsEstInv quando nao for lancado o valor de estoque na wizard
		If Val(aWizard[17][2]) == 0
		FsEstInv (aInv, 1, .T., .F., StoD (AllTrim (aWizard[17][1])),,,,,,,,,, aFilsCalc, .T.,,, )
			INV->(DbGoTop ())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicio do exercicio³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do While !INV->(Eof ())
				nAcEstIni	+=	INV->CUSTO
				//
				INV->(DbSkip ())
			EndDo
			FsEstInv (aInv, 2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Fim do exercicio³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FsEstInv (aInv, 1, .T., .F., StoD (AllTrim (aWizard[17][3])),,,,,,,,,, aFilsCalc, .T.,,, )
			INV->(DbGoTop ())
			//
			Do While !INV->(Eof ())
				nAcEstFim	+=	INV->CUSTO
				//
				INV->(DbSkip ())
			EndDo
			FsEstInv (aInv, 2)
		Else 
			nAcEstIni := Val(aWizard[17][2])
			nAcEstFim := Val(aWizard[17][4])
		Endif			
		//
		//Estoque no inicio do periodo
		AtuVlrDime(, "90", "90", "010", nAcEstIni, 2)
		//
		//Estoque no fim do periodo
		AtuVlrDime(, "90", "90", "020", nAcEstFim, 2)
		//
		//Receita Bruta de vendas e servicos
		AtuVlrDime(, "90", "90", "030", Val (aWizard[17][5]), 2)	//Contribuintes que possui escrita contabil nao informar este campo no wizard.
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME91    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 91 para o meio-magnetico.          ³±±
±±³          ³                                                            ³±±
±±³          ³                              ATIVO                         ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do CFP.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME91 (aWizard)
	Local	nCirculante	:=	0
	Local	nRealizavel	:=	0
	Local	nPermanente	:=	0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para declaracao NORMAL e quando estiver escrita contabil³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty (AllTrim (aWizard[17][1])) .And.;		//Inventario
		("1"==Iif ("dados"$aWizard[2][11], "3", Iif("Não"$aWizard[2][11], "2","1")))	//Com escrita contabil

		nCirculante	:=	Val (aWizard[18][1])	//Disponibilidades
		nCirculante	+=	Val (aWizard[18][2])	//Contas a receber do circulante
		nCirculante	+=	Val (aWizard[18][3])	//Estoque de mercadorias e materia-prima
		nCirculante	+=	Val (aWizard[18][4])	//Outros estoques
		nCirculante	+=	Val (aWizard[18][5])	//Outras contas do ativo circulantes
		//
		nRealizavel	:=	Val (aWizard[18][6])
		nRealizavel	+=	Val (aWizard[18][7])
		//
		nPermanente	:=	Val (aWizard[18][8])	//Investimentos
		nPermanente	+=	Val (aWizard[18][9])	//Imobilizado
		nPermanente	+=	Val (aWizard[18][10])	//Diferido
		nPermanente	+=	Val (aWizard[18][11])  //Intangivel
		//
		//110 - Circulante
		AtuVlrDime(, "91", "91", "110", nCirculante, 2)
		//
		//111 - Disponibilidades
		AtuVlrDime(, "91", "91", "111", Val (aWizard[18][1]), 2)
		//
		//113 - Contas a receber do circulante
		AtuVlrDime(, "91", "91", "113", Val (aWizard[18][2]), 2)
		//
		//121 - Estoque de mercadorias e materia-prima
		AtuVlrDime(, "91", "91", "121", Val (aWizard[18][3]), 2)
		//
		//123 - Outros estoques
		AtuVlrDime(, "91", "91", "123", Val (aWizard[18][4]), 2)
		//
		//128 - Outras contas do ativo circulantes
		AtuVlrDime(, "91", "91", "128", Val (aWizard[18][5]), 2)
		//
		//130 - Realizavel a longo prazo
		AtuVlrDime(, "91", "91", "130", nRealizavel, 2)
		//
		//131 - Contas a receber do realizavel
		AtuVlrDime(, "91", "91", "131", Val (aWizard[18][6]), 2)
		//
		//148 - Outras contas do realizavel
		AtuVlrDime(, "91", "91", "148", Val (aWizard[18][7]), 2)
		//
		//Permanente
		AtuVlrDime(, "91", "91", "150", nPermanente, 2)
		//
		//Investimentos
		AtuVlrDime(, "91", "91", "151", Val (aWizard[18][8]), 2)
		//
		//Imobilizado
		AtuVlrDime(, "91", "91", "155", Val (aWizard[18][9]), 2)
		//
		//Diferido
		AtuVlrDime(, "91", "91", "157", Val (aWizard[18][10]), 2)
		//Intangivel
    	If StrZero(Year (MV_PAR02),4)+StrZero(Month (MV_PAR02),2) >= "201201"
       		AtuVlrDime(, "91", "91", "159", Val (aWizard[18][11]), 2)
	    EndIf
		//
		//Total Geral do Ativo
		AtuVlrDime(, "91", "91", "199", nCirculante+nRealizavel+nPermanente, 2)
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME92    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 92 para o meio-magnetico.          ³±±
±±³          ³                                                            ³±±
±±³          ³                         PASSIVO                            ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do CFP.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME92 (aWizard)
	Local	nCirculante	:=	0
	Local	nPatrimonio	:=	0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para declaracao NORMAL e quando estiver escrita contabil³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty (AllTrim (aWizard[17][1])) .And.;		//Inventario
		("1"==Iif ("dados"$aWizard[2][11], "3", Iif("Não"$aWizard[2][11], "2","1")))	//Com escrita contabil
		//
		nCirculante	:=	Val (aWizard[19][1])	//Fornecedores
		nCirculante	+=	Val (aWizard[19][2])	//Emprestimos e Financiamentos
		nCirculante	+=	Val (aWizard[19][3])	//Outras contas do passivo circulante
		//
		nPatrimonio	:=	Val (aWizard[19][6])	//Capital Social
		nPatrimonio	+=	Val (aWizard[19][7])	//Outras contas do Patrimonio Liquido
		nPatrimonio	-=	Val (aWizard[19][8])	
		//
		//Circulante
		AtuVlrDime(, "92", "92", "210", nCirculante, 2)
		//
		//Fornecedores
		AtuVlrDime(, "92", "92", "211", Val (aWizard[19][1]), 2)
		//
		//Emprestimos e Financiamentos
		AtuVlrDime(, "92", "92", "213", Val (aWizard[19][2]), 2)
		//
		//Outras contas do passivo circulante
		AtuVlrDime(, "92", "92", "215", Val (aWizard[19][3]), 2)
		//
		//Exigivel a longo prazo
		AtuVlrDime(, "92", "92", "230", Val (aWizard[19][4]), 2)
		//
		//Resultados de exercicios futuros
		AtuVlrDime(, "92", "92", "240", Val (aWizard[19][5]), 2)
		
		If nPatrimonio<0
			//Passivo descoberto
			AtuVlrDime(, "92", "92", "269", Abs(nPatrimonio), 2)
		Else
			//Patrimonio Liquido
			AtuVlrDime(, "92", "92", "270", nPatrimonio, 2)
		EndIf
		
		//
		//Capital Social
		AtuVlrDime(, "92", "92", "271", Val (aWizard[19][6]), 2)
		//		
		//Outras contas do Patrimonio Liquido
		AtuVlrDime(, "92", "92", "278", Val (aWizard[19][7]), 2)
		//
		//Outras contas do Patrimonio Liquido (Negativo)
		AtuVlrDime(, "92", "92", "279", Val (aWizard[19][8]), 2)
		//
		//Total Geral do Passivo
		AtuVlrDime(, "92", "92", "299", nCirculante+nPatrimonio+Val(aWizard[19][4])+Val(aWizard[19][5]), 2)
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME93    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 93 para o meio-magnetico.          ³±±
±±³          ³                                                            ³±±
±±³          ³                DEMONSTRACAO DE RESULTADOS                  ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do CFP.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³BREVE RESUMO PARA PREENCHIMENTO DESTE QUADRO NO WIZARD³
		³320 = 310 - 311                                       ³
		³330/331 = 320 - 323                                   ³
		³340/341 = 330/331 + 333 - 335                         ³
		³350/351 = 340/341 + 343 - 345                         ³
		³360/361 = 350/351 - 353                               ³
		³398/399 = 360/361 - 363                               ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Static Function DIME93 (aWizard)
	Local	nReceita	:=	0
	Local	nLucPrej	:=	0
	Local	nOpLucPre	:=	0
	Local	nNOpLucPre	:=	0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para declaracao NORMAL e quando estiver escrita contabil³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty (AllTrim (aWizard[17][1])) .And.;		//Inventario
		("1"==Iif ("dados"$aWizard[2][11], "3", Iif("Não"$aWizard[2][11], "2","1")))	//Com escrita contabil
		//
		nReceita	:=	Val (aWizard[20][1])-Val (aWizard[20][2])
		nLucPrej	:=	nReceita-Val (aWizard[20][3])
		nOpLucPre	:=	nLucPrej+Val (aWizard[20][4])-Val (aWizard[20][5])		
		nNOpLucPre	:=	nOpLucPre+Val (aWizard[20][6])-Val (aWizard[20][7])
		//
		//310-Receita bruta vendas/servico
		AtuVlrDime(, "93", "93", "310", Val (aWizard[20][1]), 2)		
		//
		//311-Devolucoes/Abatimentos e impostos
		AtuVlrDime(, "93", "93", "311", Val (aWizard[20][2]), 2)
		//
		//320-Receita liquida venda/servicos
		AtuVlrDime(, "93", "93", "320", nReceita, 2)
		//
		//323-Custo da mercadoria vendida
		AtuVlrDime(, "93", "93", "323", Val (aWizard[20][3]), 2)
		//
		If (nLucPrej>0)
			//330-Lucro Bruto
			AtuVlrDime(, "93", "93", "330", Abs (nLucPrej), 2)
		Else
			//331-Prejuizo Bruto
			AtuVlrDime(, "93", "93", "331", Abs (nLucPrej), 2)
		EndIf
		//
		//333-Outras Receitas Operacionais
		AtuVlrDime(, "93", "93", "333", Val (aWizard[20][4]), 2)
		//
		//335-Despesas operacionais
		AtuVlrDime(, "93", "93", "335", Val (aWizard[20][5]), 2)
		//
		If (nOpLucPre>0)
			//340-Lucro operacional
			AtuVlrDime(, "93", "93", "340", Abs (nOpLucPre), 2)
		Else
			//341-Prejuizo operacional
			AtuVlrDime(, "93", "93", "341", Abs (nOpLucPre), 2)
		EndIf
		//
		//343-Receitas nao operacionais
		AtuVlrDime(, "93", "93", "343", Val (aWizard[20][6]), 2)
		//
		//345-Despesas nao operacionais
		AtuVlrDime(, "93", "93", "345", Val (aWizard[20][7]), 2)
		//
		If (nNOpLucPre>0)
			//350-Resultado antes do IR
			AtuVlrDime(, "93", "93", "350", Abs (nNOpLucPre), 2)
		Else
			//351-Resultado negativo antes do IR e da contribuicao social
			AtuVlrDime(, "93", "93", "351", Abs (nNOpLucPre), 2)
		EndIf
		//
		//353-Provisao para o IR
		AtuVlrDime(, "93", "93", "353", Val (aWizard[20][8]), 2)		
		//
		//354-Provisão para o IR e para contribuição social
		AtuVlrDime(, "93", "93", "354", Val (aWizard[20][9]), 2)
		
		If (nNOpLucPre-Val (aWizard[20][8]) + Val(aWizard[20][9])) > 0
			//360-Resultado apos o IR
			AtuVlrDime(, "93", "93", "360", Abs (nNOpLucPre - Val(aWizard[20][8]) + Val(aWizard[20][9])), 2)
		Else
			//361-Resultado negativo apos o IR e Contribuicao Social
			AtuVlrDime(, "93", "93", "361", Abs (nNOpLucPre - Val(aWizard[20][8]) + Val(aWizard[20][9])), 2)
		EndIf
		//
		//363-Participacoes e contribuicoes
		AtuVlrDime(, "93", "93", "363", Val (aWizard[20][10]), 2)
		//
		If (nNOpLucPre - Val(aWizard[20][8]) + Val(aWizard[20][9]) -Val(aWizard[20][10])) > 0
			//399-Lucro do Exercicio
			AtuVlrDime(, "93", "93", "399", Abs (nNOpLucPre-Val (aWizard[20][8]) + Val(aWizard[20][9]) -Val (aWizard[20][10])), 2)
		ElseIf (nNOpLucPre - Val(aWizard[20][8]) + Val(aWizard[20][9]) - Val(aWizard[20][10]))==0
			//399-Sem Movimento		
			AtuVlrDime(, "93", "93", "399", 0, 2)
		Else
			//398-Prejuizo do Exercicio
			AtuVlrDime(, "93", "93", "398", Abs (nNOpLucPre-Val (aWizard[20][8]) + Val(aWizard[20][9])-Val (aWizard[20][10])), 2)
		EndIf
	EndIf
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIME94    ³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao dos registros 94 para o meio-magnetico.          ³±±
±±³          ³                                                            ³±±
±±³          ³                 DETALHAMENTO DAS DESPESAS                  ³±±
±±³          ³                                                            ³±±
±±³          ³ Composta das informacoes obtidas atraves do CFP.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array contendo as informacoes preenchidas no     ³±±
±±³          ³ wizard                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIME94 (aWizard)
	Local	nTotal	:=	0
	Local	nI		:=	0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente para declaracao NORMAL independente da escrita contabil ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty (AllTrim (aWizard[17][1]))
		//
		//Pro-labore
		AtuVlrDime(, "94", "94", "411", Val (aWizard[21][1]), 2)
		//
		//Conissoes, salarios ou ordenados
		AtuVlrDime(, "94", "94", "412", Val (aWizard[21][2]), 2)
		//
		//Combustiveis e Lubrificantes
		AtuVlrDime(, "94", "94", "431", Val (aWizard[21][3]), 2)
		//
		//Encargos sociais
		AtuVlrDime(, "94", "94", "421", Val (aWizard[21][4]), 2)
		//
		//Tributos federais
		AtuVlrDime(, "94", "94", "422", Val (aWizard[21][5]), 2)
		//
		//Tributos estaduais
		AtuVlrDime(, "94", "94", "423", Val (aWizard[21][6]), 2)
		//
		//Tributos municipais
		AtuVlrDime(, "94", "94", "424", Val (aWizard[21][7]), 2)
		//
		//Agua e telefone
		AtuVlrDime(, "94", "94", "432", Val (aWizard[21][8]), 2)
		//
		//Energia eletrica
		AtuVlrDime(, "94", "94", "433", Val (aWizard[21][9]), 2)
		//
		//Alugueis
		AtuVlrDime(, "94", "94", "441", Val (aWizard[21][10]), 2)
		//
		//Servicos profissionais
		AtuVlrDime(, "94", "94", "451", Val (aWizard[21][11]), 2)
		//
		//Seguros
		AtuVlrDime(, "94", "94", "442", Val (aWizard[21][12]), 2)
		//
		//Fretes e carretos
		AtuVlrDime(, "94", "94", "443", Val (aWizard[21][13]), 2)
		//
		//Despesas financeiras
		AtuVlrDime(, "94", "94", "461", Val (aWizard[21][14]), 2)
		//
		//Outras despesas
		AtuVlrDime(, "94", "94", "498", Val (aWizard[21][15]), 2)
		//
		//Totalizador
		For nI :=1 To Len (aWizard[21])
			nTotal	+=	Val (aWizard[21][nI])
		Next (nI)
		//
		//Total
		AtuVlrDime(, "94", "94", "499", nTotal, 2)
	EndIf
Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MontPainel³ Autor ³Gustavo G. Rueda       ³ Data ³15.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do wizard para auxilio das informacoes necessa-  ³±±
±±³          ³ rias na composicao do meio-magnetico.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aWizard -> Array contendo as informacoes do wizard.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontPainel (lContinua)
	Local	aPInicial	:=	{}
	Local	aPCfp		:=	{}
	Local	aWizard		:=	{}
	Local	cXNumEmp	:=	AllTrim(cEmpAnt+cFilAnt)
	Local	aFileDime	:=	Directory ("DIME"+AllTrim(cXNumEmp)+".*")
	Local	nI			:=	0
	Local	aQuadro32	:= {}

	//
	//Consistencia do CFP utilizado para este meio-magnetico. Caso o que exista nao esta nas caracteristicas do utilizado pela rotina sera excluido e gerado um novo correto.
	If (xMagLeWiz ("DIME"+cXNumEmp, @aWizard, .T.))
		If Len (aWizard)<>24
			aFileDime	:=	aSort (aFileDime,,,{|aX, aY| aX[1]<aY[1]})
			cExistF		:=	"DIME"+cXNumEmp+"."+Upper (Soma1 ("000"))
			Do While (.T.)
				If (aScan (aFileDime, {|aX| aX[1]==cExistF}))==0
					FRename("DIME"+cXNumEmp+".CFP" , cExistF)
					FErase ("DIME"+cXNumEmp+".CFP")
					Exit					
				ElseIf (".ZZZ"$cExistF)
					For nI := 1 To Len (aFileDime) 
						FErase (aFileDime[nI][1])
					Next nI
					Exit
				EndIf
				cExistF	:=	SubStr (cExistF, 1, 9)+Soma1 (SubStr (cExistF, 10, 3))
			EndDo
		EndIf
	EndIf
	aWizard		:=	{}
	//Painel Principal
	aAdd (aPInicial, STR0007)
	aAdd (aPInicial, "")
	aAdd (aPInicial, STR0008)
	aAdd (aPInicial, STR0009)
	//Painel do Registro Tipo 20.
	aAdd (aPCfp, {})
	aAdd (aPCfp[1], STR0007)
	aAdd (aPCfp[1], STR0010)
	aAdd (aPCfp[1], {})
	aAdd (aPCfp[1][3], {1, STR0011,,,,,,})
	aAdd (aPCfp[1][3], {1, STR0012,,,,,,})
	aAdd (aPCfp[1][3], {2, ,"XXXXXXXXXXX",1,,,,11})
	aAdd (aPCfp[1][3], {2, ,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",1,,,,50})
	//Painel para o Registro Tipo 21.
	aAdd (aPCfp, {})
	aAdd (aPCfp[2], STR0007)
	aAdd (aPCfp[2], STR0013)
	aAdd (aPCfp[2], {})
	aAdd (aPCfp[2][3], {1, STR0014,,,,,,})
	aAdd (aPCfp[2][3], {1, STR0015,,,,,,})
	aAdd (aPCfp[2][3], {2, ,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 1,0,,,50})
	aAdd (aPCfp[2][3], {3,,,,,{"Normal", "Encerramento Atividades","Enquadramento no Simples Nacional"},,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {1, STR0016,,,,,,})
	aAdd (aPCfp[2][3], {1, STR0017,,,,,,})
	aAdd (aPCfp[2][3], {3,,,,,{"Normal", "Produtor Primário"},,})
	aAdd (aPCfp[2][3], {3,,,,,{"ME (Microempresa)", "EPP (Empresa Peq. Porte)", "Normal", "Produtor Primário"},,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {1, STR0018,,,,,,})
	aAdd (aPCfp[2][3], {1, STR0020,,,,,,})
	aAdd (aPCfp[2][3], {3,,,,,{"Não é apuração consolidada", "É estabelecimento consolidador", "É estabelecimento consolidado"},,})
	aAdd (aPCfp[2][3], {3,,,,,{"Não apurou ou reservou nem recebeu créditos", "Apurou ou reservou créditos", "Recebeu Créditos", "Apurou ou reservou e recebeu créditos"},,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {1, STR0021,,,,,,})
	aAdd (aPCfp[2][3], {1, STR0022,,,,,,})
	aAdd (aPCfp[2][3], {3,,,,,{"Sim", "Não"},,})
	aAdd (aPCfp[2][3], {3,,,,,{"Sim", "Não", "Informação Desnecessária"},,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {1, STR0023,,,,,,})
	aAdd (aPCfp[2][3], {1, STR0024,,,,,,})
	aAdd (aPCfp[2][3], {3,,,,,{"Sem movimentos e sem saldos", "Sem movimento e com saldos", "Com movimento"},,})
	aAdd (aPCfp[2][3], {3,,,,,{"Sim", "Não", "Substituído solidário"},,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {1, STR0025,,,,,,})
	aAdd (aPCfp[2][3], {1, STR0026,,,,,,})
	aAdd (aPCfp[2][3], {3,,,,,{"Sim é estab. principal", "Não", "Sim, dados informados no estab. principal"},,})
	aAdd (aPCfp[2][3], {3,,,,,{"Mensal", "Decendial"},,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {1, STR0027,,,,,,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {2, ,"XXXXX", 1,,,,5})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	aAdd (aPCfp[2][3], {0,"",,,,,,})
	//Painel do Registro Tipo 90 e 80.
	aAdd (aPCfp, {})
	aAdd (aPCfp[3], STR0007)
	aAdd (aPCfp[3], STR0028)
	aAdd (aPCfp[3], {})
	aAdd (aPCfp[3][3], {1, "Gera Quadro 80?",,,,,,})
	aAdd (aPCfp[3][3], {1, "Quadro 80 Zerado?",,,,,,})
	aAdd (aPCfp[3][3], {3,,,,,{"Sim", "Não"},,})
	aAdd (aPCfp[3][3], {3,,,,,{"Sim", "Não"},,})
	aAdd (aPCfp[3][3], {0,"",,,,,,})
	aAdd (aPCfp[3][3], {0,"",,,,,,})
	// Inicio do exercicio - data e estoque, quando nao for processar pelo FsEstInv
	aAdd (aPCfp[3][3], {1, STR0029,,,,,,}) 
	aAdd (aPCfp[3][3], {1, STR0260,,,,,,}) 	
	aAdd (aPCfp[3][3], {2,,,3,,,,})
	aAdd (aPCfp[3][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[3][3], {0,"",,,,,,})
	aAdd (aPCfp[3][3], {0,"",,,,,,})	
	// Final do exercicio - data e estoque, quando nao for processar pelo FsEstInv
	aAdd (aPCfp[3][3], {1, STR0259,,,,,,}) 
	aAdd (aPCfp[3][3], {1, STR0261,,,,,,}) 	
	aAdd (aPCfp[3][3], {2,,,3,,,,})
	aAdd (aPCfp[3][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[3][3], {0,"",,,,,,})
	aAdd (aPCfp[3][3], {0,"",,,,,,})
	// Receita bruta de vendas/servicos	
	aAdd (aPCfp[3][3], {1, STR0030,,,,,,})
	aAdd (aPCfp[3][3], {0,"",,,,,,})
	aAdd (aPCfp[3][3], {2,,"@E 99,999,999,999.99",2,2,,,17})	
	aAdd (aPCfp[3][3], {0,"",,,,,,})
	aAdd (aPCfp[3][3], {0,"",,,,,,})	
	//Painel do Registro Tipo 91.
	aAdd (aPCfp, {})
	aAdd (aPCfp[4], STR0007)
	aAdd (aPCfp[4], STR0031)
	aAdd (aPCfp[4], {})
	aAdd (aPCfp[4][3], {1, STR0037,,,,,,})	//"Circulante"
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {1, STR0032,,,,,,})	//"Disponibilidades"
	aAdd (aPCfp[4][3], {1, STR0033,,,,,,})	//"Contas a receber do circulante"
	aAdd (aPCfp[4][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[4][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {1, STR0034,,,,,,})	//"Estoque de mercadorias e materia-prima"
	aAdd (aPCfp[4][3], {1, STR0035,,,,,,})	//"Outros estoques"
	aAdd (aPCfp[4][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[4][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {1, STR0036,,,,,,})	//"Outras contas do ativo circulante"
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {1, STR0257,,,,,,})	//"- Realizável a longo prazo"
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {1, STR0038,,,,,,})	//"Contas a receber do realizavel"
	aAdd (aPCfp[4][3], {1, STR0039,,,,,,})	//"Outras Contas do realizavel"
	aAdd (aPCfp[4][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[4][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {1, STR0258,,,,,,})	//"- Permanente"
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {1, STR0040,,,,,,})	//"Investimentos"
	aAdd (aPCfp[4][3], {1, STR0041,,,,,,})	//"Imobilizado (Liquido)"
	aAdd (aPCfp[4][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[4][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {1, STR0042,,,,,,})	//"Diferido"
	aAdd (aPCfp[4][3], {1, STR0283,,,,,,})  //Intangivel
	aAdd (aPCfp[4][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[4][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	aAdd (aPCfp[4][3], {0, "",,,,,,})
	//Painel do Registro Tipo 92.
	aAdd (aPCfp, {})
	aAdd (aPCfp[5], STR0007)
	aAdd (aPCfp[5], STR0043)
	aAdd (aPCfp[5], {})
	aAdd (aPCfp[5][3], {1, STR0037,,,,,,})	//"Circulante"
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {1, STR0044,,,,,,})	//"Fornecedores"
	aAdd (aPCfp[5][3], {1, STR0045,,,,,,})	//"Emprestimos e financiamentos"
	aAdd (aPCfp[5][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[5][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {1, STR0046,,,,,,})	//"Outras contas do passivo circulante"
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {1, STR0047,,,,,,})	//"- Exigivel a longo prazo"
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {2,,"@E 99,999,999,999.99",2,2,,,17})	
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {1, STR0048,,,,,,})	//"- Resultado de exercicios futuros"
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {2,,"@E 99,999,999,999.99",2,2,,,17})	
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {1, STR0061,,,,,,})	//"- Patrimônio Líquido"
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {1, STR0049,,,,,,})	//"Capital social"
	aAdd (aPCfp[5][3], {1, STR0050,,,,,,})	//"Outras contas do patrimonio liquido"
	aAdd (aPCfp[5][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[5][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {1, STR0150,,,,,,})	//"Outras contas patrimônio líquido (valor negativo)"
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	aAdd (aPCfp[5][3], {0, "",,,,,,})
	//Painel do Registro Tipo 93.
	aAdd (aPCfp, {})
	aAdd (aPCfp[6], STR0007)
	aAdd (aPCfp[6], STR0051)
	aAdd (aPCfp[6], {})
	aAdd (aPCfp[6][3], {1, STR0054,,,,,,})	//"- Receita liquida vendas/servicos"
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {1, STR0052,,,,,,})	//"Receita bruta vendas/servico"
	aAdd (aPCfp[6][3], {1, STR0053,,,,,,})	//"Devolucöes/Abatimentos e impostos"
	aAdd (aPCfp[6][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[6][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {1, STR0056,,,,,,})	//"- Lucro/Prejuíso bruto"
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {1, STR0055,,,,,,})	//"Custo da mercadoria vendida"
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {1, STR0058,,,,,,})	//"- Lucro/prejuizo operacional"
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {1, STR0054,,,,,,})	//"Outras Receitas operacionais	
	aAdd (aPCfp[6][3], {1, STR0057,,,,,,})	//"Despesas operacionais"
	aAdd (aPCfp[6][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[6][3], {2,,"@E 99,999,999,999.99",2,2,,,17})	
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {1, STR0062,,,,,,})	//"- Resultado antes do IR"
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {1, STR0059,,,,,,})	//"Receitas näo operacionais"
	aAdd (aPCfp[6][3], {1, STR0060,,,,,,})	//"Despesas näo operacionais"
	aAdd (aPCfp[6][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[6][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})	
	aAdd (aPCfp[6][3], {1, STR0064,,,,,,})	//"- Resultado após o IR"
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {1, STR0063,,,,,,})	//"Provisäo para o IR"
	aAdd (aPCfp[6][3], {1, STR0313,,,,,,})	//"Provisão para o IR e para contribuição social"
	aAdd (aPCfp[6][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[6][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {1, STR0066,,,,,,})	//"- Lucro/Prejuizo exercício"
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {1, STR0065,,,,,,})	//"Participacöes e contribuicöes"
	aAdd (aPCfp[6][3], {0, "",,,,,,})	
	aAdd (aPCfp[6][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	aAdd (aPCfp[6][3], {0, "",,,,,,})
	//Painel do Registro Tipo 94.
	aAdd (aPCfp, {})
	aAdd (aPCfp[7], STR0007)
	aAdd (aPCfp[7], STR0067)
	aAdd (aPCfp[7], {})
	aAdd (aPCfp[7][3], {1, STR0068,,,,,,})
	aAdd (aPCfp[7][3], {1, STR0069,,,,,,})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {1, STR0070,,,,,,})
	aAdd (aPCfp[7][3], {1, STR0071,,,,,,})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {1, STR0072,,,,,,})
	aAdd (aPCfp[7][3], {1, STR0073,,,,,,})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {1, STR0074,,,,,,})
	aAdd (aPCfp[7][3], {1, STR0075,,,,,,})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {1, STR0076,,,,,,})
	aAdd (aPCfp[7][3], {1, STR0077,,,,,,})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {1, STR0078,,,,,,})
	aAdd (aPCfp[7][3], {1, STR0079,,,,,,})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {1, STR0080,,,,,,})
	aAdd (aPCfp[7][3], {1, STR0081,,,,,,})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {1, STR0082,,,,,,})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[7][3], {0,,"",,,,,17})
	aAdd (aPCfp[7][3], {0, "",,,,,,})
	aAdd (aPCfp[7][3], {0, "",,,,,,})   
	
	//Painel do Registro Tipo 41.
	aAdd (aPCfp, {})
	aAdd (aPCfp[8], STR0007)									//"Processamento da DIME - SC"
	aAdd (aPCfp[8], STR0083)									//"Preenchimento de algumas informacöes necessarias para montagem do Registro Tipo 41 - Demonstrativo de creditos acumulados."
	aAdd (aPCfp[8], {})
	
	aAdd (aPCfp[8][3], {1, STR0238,,,,,,}) //Percentual Aplicavel no mês	
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {1, STR0239,,,,,,})	// Credito nas aquisicöes
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})

	
	aAdd (aPCfp[8][3], {1, STR0240,,,,,,})		//	Valor das Operações
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {1, STR0241,,,,,,})		 //Produtos Exportados no Mês			
	aAdd (aPCfp[8][3], {1, STR0242,,,,,,})	    //Saídas Isentas ou Não Tributadas				
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {1, STR0243,,,,,,})		 //Saídas Diferidas ou Suspensas			
	aAdd (aPCfp[8][3], {0, "",,,,,,})					
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	
	
	aAdd (aPCfp[8][3], {1, STR0244,,,,,,})	 //Valor das mercadorias, materiais e serviços:				
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {1, STR0245,,,,,,})	  //Produtos Exportados no Mês				
	aAdd (aPCfp[8][3], {1, STR0246,,,,,,})	 	//Saídas Isentas ou Não Tributadas			
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {1, STR0247,,,,,,})			//Saídas Diferidas ou Suspensas		
	aAdd (aPCfp[8][3], {0, "",,,,,,})					
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	
	
	aAdd (aPCfp[8][3], {1, STR0248,,,,,,})			 //Saldo Credor transf. do mês anterior		
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {1, STR0249,,,,,,})	  // Relativo à exportação			
	aAdd (aPCfp[8][3], {1, STR0287,,,,,,})   //Relativo a saídas isentas					
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {1, STR0288,,,,,,})    //Relativo a saídas diferidas					
	aAdd (aPCfp[8][3], {1, STR0289,,,,,,})		//Outros créditos não transferíveis		
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	
	aAdd (aPCfp[8][3], {1, STR0290,,,,,,})	 //Crédito transferível autorizado				
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {1, STR0291,,,,,,})	 //Exportação lançado em DCIP				
	aAdd (aPCfp[8][3], {1, STR0292,,,,,,})		 //Saída isenta lançado em DCIP			
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {1, STR0293,,,,,,})		//Saídas diferidas lançado em DCIP                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  			
	aAdd (aPCfp[8][3], {0, "",,,,,,})					
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	
	
	aAdd (aPCfp[8][3], {1, STR0294,,,,,,})	//Ded. no Saldo Credor Mês Seguinte				
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {1, STR0295,,,,,,}) //Rec. estabelecimentos consolidados					
	aAdd (aPCfp[8][3], {1, STR0296,,,,,,})			//Crédito recebido por transferência		
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {1, "Outras deduções do saldo credor",,,,,,})	//"Outras deduções do saldo credor"				
	aAdd (aPCfp[8][3], {0, "",,,,,,})					
	aAdd (aPCfp[8][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
	aAdd (aPCfp[8][3], {0, "",,,,,,})
		
	
	
	//Painel do Registro Tipo 44.
	aAdd (aPCfp, {})
	aAdd (aPCfp[9], STR0007)									//"Processamento da DIME - SC"
	aAdd (aPCfp[9], STR0085)									//"Preenchimento de algumas informacöes necessarias para montagem do Registro Tipo 44 - Creditos Presumidos."
	aAdd (aPCfp[9], {})
	aAdd (aPCfp[9][3], {1, STR0086,,,,,,})					//"Total pago no mes aos empregados"
	aAdd (aPCfp[9][3], {1, STR0087,,,,,,})					//"Media no exercicio anterior"
	aAdd (aPCfp[9][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[9][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	//Painel do Registro Tipo 45.
	aAdd (aPCfp, {})
	aAdd (aPCfp[10], STR0007)
	aAdd (aPCfp[10], STR0088)
	aAdd (aPCfp[10], {})
	aAdd (aPCfp[10][3], {1, STR0089,,,,,,})					//"Valor do Recibo"
	aAdd (aPCfp[10][3], {0, "",,,,,,})
	aAdd (aPCfp[10][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	//Painel do Registro Tipo 28.
	aAdd (aPCfp, {})
	aAdd (aPCfp[11], STR0007)
	aAdd (aPCfp[11], STR0090)
	aAdd (aPCfp[11], {})
	aAdd (aPCfp[11][3], {1, STR0091,,,,,,})
	aAdd (aPCfp[11][3], {1, STR0092,,,,,,})
	aAdd (aPCfp[11][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[11][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[11][3], {0, "",,,,,,})
	aAdd (aPCfp[11][3], {0, "",,,,,,})
	aAdd (aPCfp[11][3], {1, STR0093,,,,,,})
	aAdd (aPCfp[11][3], {1, STR0095,,,,,,})
	aAdd (aPCfp[11][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[11][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[11][3], {0, "",,,,,,})
	aAdd (aPCfp[11][3], {0, "",,,,,,})
	//Painel do Registro Tipo 51(ENTRADAS).
	aAdd (aPCfp, {})
	aAdd (aPCfp[12], STR0007)
	aAdd (aPCfp[12], STR0103)
	aAdd (aPCfp[12], {})
	aAdd (aPCfp[12][3], {1, STR0104,,,,,,})
	aAdd (aPCfp[12][3], {1, STR0105,,,,,,})
	aAdd (aPCfp[12][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[12][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[12][3], {0, "",,,,,,})
	aAdd (aPCfp[12][3], {0, "",,,,,,})
	aAdd (aPCfp[12][3], {1, STR0284,,,,,,})
	aAdd (aPCfp[12][3], {1, STR0106,,,,,,})
	aAdd (aPCfp[12][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[12][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[12][3], {0, "",,,,,,})
	aAdd (aPCfp[12][3], {0, "",,,,,,})
	aAdd (aPCfp[12][3], {1, STR0107,,,,,,})
	aAdd (aPCfp[12][3], {1, STR0108,,,,,,})
	aAdd (aPCfp[12][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[12][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[12][3], {0, "",,,,,,})
	aAdd (aPCfp[12][3], {0, "",,,,,,})		
	//Painel do Registro Tipo 51(SAIDAS).
	aAdd (aPCfp, {})
	aAdd (aPCfp[13], STR0007)
	aAdd (aPCfp[13], STR0109)
	aAdd (aPCfp[13], {})
	aAdd (aPCfp[13][3], {1, STR0104,,,,,,})
	aAdd (aPCfp[13][3], {1, STR0110,,,,,,})
	aAdd (aPCfp[13][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[13][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[13][3], {0, "",,,,,,})
	aAdd (aPCfp[13][3], {0, "",,,,,,})
	aAdd (aPCfp[13][3], {1, STR0111,,,,,,})
	aAdd (aPCfp[13][3], {1, STR0112,,,,,,})
	aAdd (aPCfp[13][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[13][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[13][3], {0, "",,,,,,})
	aAdd (aPCfp[13][3], {0, "",,,,,,})
	//Painel do Registro Tipo 32(ST).
	MsgRun('Preenchendo quadro 11 - Registro tipo 32', 'Aguarde...',	{|| aQuadro32 := DIME32b()})
	//--Estrutura do vetor aQuadro32:
	//--[01]: Valor dos Produtos (Valor Contabil)
	//--[02]: Valor do IPI
	//--[03]: Valor de Despesas Acessórias
	//--[04]: Base ICMS
	//--[05]: Valor ICMS
	//--[06]: Base ICMS-ST
	//--[07]: Valor ICMS-ST
	//--[08]: Saldo Credor Periodo Anterior	
    //--[09]: Imposto Retido	
	//--[10]: Débitos por Ocasião do Fato Gerador	
	aAdd (aPCfp, {})
	aAdd (aPCfp[14], STR0007)
	aAdd (aPCfp[14], STR0116)
	aAdd (aPCfp[14], {})
	aAdd (aPCfp[14][3], {1, STR0117,,,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0118,,,,,,})
	aAdd (aPCfp[14][3], {1, STR0119,,,,,,})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17,{.F.,aQuadro32[1], .T.}})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17,{.F.,aQuadro32[2], .T.}})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0120,,,,,,})
	aAdd (aPCfp[14][3], {1, STR0121,,,,,,})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17,{.F.,aQuadro32[3], .T.}})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17,{.F.,aQuadro32[4], .T.}})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0122,,,,,,})
	aAdd (aPCfp[14][3], {1, STR0123,,,,,,})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17,{.F.,aQuadro32[5], .T.}})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17,{.F.,aQuadro32[6], .T.}})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0282,,,,,,})
	aAdd (aPCfp[14][3], {1, STR0124,,,,,,})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17,{.F.,aQuadro32[11], .T.}})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17,{.F.,aQuadro32[7], .T.}})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0125,,,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0126,,,,,,})
	aAdd (aPCfp[14][3], {1, STR0127,,,,,,})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17,{.F.,aQuadro32[8], .T.}})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0128,,,,,,})
	aAdd (aPCfp[14][3], {1, STR0129,,,,,,})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17,{.F.,aQuadro32[9], .T.}})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0130,,,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0131,,,,,,})
	aAdd (aPCfp[14][3], {1, STR0132,,,,,,})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0270,,,,,,})
	aAdd (aPCfp[14][3], {1, STR0279,,,,,,})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[14][3], {3,,,,,{"Sim", "Nao"},,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0280,,,,,,})
	aAdd (aPCfp[14][3], {1, STR0281,,,,,,})   
	aAdd (aPCfp[14][3], {3,,,,,{"Sim", "Nao"},,})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {1, STR0285,,,,,,})                       //Creditos Declarados no DCIP
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	aAdd (aPCfp[14][3], {0,,"",,,,,})
	//Painel do Registro Tipo 31.
	aAdd (aPCfp, {})
	aAdd (aPCfp[15], STR0007)
	aAdd (aPCfp[15], STR0230)										//"Preenchimento de algumas informacöes necessarias para montagem do Registro Tipo 31 - Débitos específicos."
	aAdd (aPCfp[15], {})                                        	
	aAdd (aPCfp[15][3], {1, STR0231,,,,,,})						//"Débito relativo a operações de importação"
	aAdd (aPCfp[15][3], {1, STR0232,,,,,,})						//"Débito relativo a aquisição de outras UF"
	aAdd (aPCfp[15][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[15][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[15][3], {0,,"",,,,,})
	aAdd (aPCfp[15][3], {0,,"",,,,,})
	aAdd (aPCfp[15][3], {1, STR0233,,,,,,})						//"Débito por responsabilidade Tributária"
	aAdd (aPCfp[15][3], {1, STR0234,,,,,,})						//"Outros débitos por ocasião do Fat. Ger."
	aAdd (aPCfp[15][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[15][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[15][3], {0,,"",,,,,})
	aAdd (aPCfp[15][3], {0,,"",,,,,})
	aAdd (aPCfp[15][3], {1, STR0235,,,,,,})						//"Outros débitos eventuais"
	aAdd (aPCfp[15][3], {1, STR0236,,,,,,})						//"Numero GNRE Débitos específico"
	aAdd (aPCfp[15][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[15][3], {2, ,"XXXXXXXXXXXX",1,,,,12})
	aAdd (aPCfp[15][3], {0,,"",,,,,})
	aAdd (aPCfp[15][3], {0,,"",,,,,})
	aAdd (aPCfp[15][3], {1, STR0237,,,,,,}) 		   				// Codigo de Receita e Classe de Vencimento
	aAdd (aPCfp[15][3], {0,,"",,,,,})
	aAdd (aPCfp[15][3], {2, ,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",1,,,,40})
	//Painel do Registro Tipo 30.
	aAdd (aPCfp, {})
	aAdd (aPCfp[16], STR0007)
	aAdd (aPCfp[16], STR0262)										//"Preenchimento de algumas informacöes necessarias para montagem do Registro Tipo 31 - Débitos específicos."
	aAdd (aPCfp[16], {})                                        	
	aAdd (aPCfp[16][3], {1, STR0263,,,,,,})						//"Imposto 1º decendio ou 1ª parc. antecipa."
	aAdd (aPCfp[16][3], {1, STR0264,,,,,,})						//"Imposto 2º decendio ou 2ª parc. antecipa."
	aAdd (aPCfp[16][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[16][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[16][3], {0,,"",,,,,})  
	aAdd (aPCfp[16][3], {0,,"",,,,,})
	aAdd (aPCfp[16][3], {1, STR0270,,,,,,})
	aAdd (aPCfp[16][3], {0,,"",,,,,})
	aAdd (aPCfp[16][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[16][3], {0,,"",,,,,})
	aAdd (aPCfp[16][3], {0,,"",,,,,})
	aAdd (aPCfp[16][3], {0,,"",,,,,})
	//Painel do Registro Tipo 90.
	aAdd (aPCfp, {})
	aAdd (aPCfp[17], STR0007)
	aAdd (aPCfp[17], STR0271)	//"Preenchimento de algumas informacöes necessarias para montagem do Registro Tipo 90 - Resumo Livro de inventario e Receita bruta."
	aAdd (aPCfp[17], {})
	// Inicio do exercicio - data e estoque, quando nao for processar pelo FsEstInv
	aAdd (aPCfp[17][3], {1, STR0029,,,,,,}) 
	aAdd (aPCfp[17][3], {1, STR0260,,,,,,}) 	
	aAdd (aPCfp[17][3], {2,,,3,,,,})
	aAdd (aPCfp[17][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[17][3], {0,,"",,,,,})
	aAdd (aPCfp[17][3], {0,,"",,,,,})
	// Final do exercicio - data e estoque, quando nao for processar pelo FsEstInv
	aAdd (aPCfp[17][3], {1, STR0259,,,,,,}) 
	aAdd (aPCfp[17][3], {1, STR0261,,,,,,}) 	
	aAdd (aPCfp[17][3], {2,,,3,,,,})
	aAdd (aPCfp[17][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[17][3], {0,,"",,,,,})
	aAdd (aPCfp[17][3], {0,,"",,,,,})
	// Receita bruta de vendas/servicos	
	aAdd (aPCfp[17][3], {1, STR0030,,,,,,})
	aAdd (aPCfp[17][3], {1, "",,,,,,})
	aAdd (aPCfp[17][3], {2,,"@E 99,999,999,999.99",2,2,,,17})	
	aAdd (aPCfp[17][3], {1, "",,,,,,})
	//Painel do Registro Tipo 91.
	aAdd (aPCfp, {})
	aAdd (aPCfp[18], STR0007)
	aAdd (aPCfp[18], STR0272)	//"Preenchimento de algumas informacöes necessarias para montagem do Registro Tipo 91 - Ativo."
	aAdd (aPCfp[18], {})
	aAdd (aPCfp[18][3], {1, STR0037,,,,,,})	//"Circulante"
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {1, STR0032,,,,,,})	//"Disponibilidades"
	aAdd (aPCfp[18][3], {1, STR0033,,,,,,})	//"Contas a receber do circulante"
	aAdd (aPCfp[18][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[18][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {1, STR0034,,,,,,})	//"Estoque de mercadorias e materia-prima"
	aAdd (aPCfp[18][3], {1, STR0035,,,,,,})	//"Outros estoques"
	aAdd (aPCfp[18][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[18][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {1, STR0036,,,,,,})	//"Outras contas do ativo circulante"
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {1, STR0257,,,,,,})	//"- Realizável a longo prazo"
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {1, STR0038,,,,,,})	//"Contas a receber do realizavel"
	aAdd (aPCfp[18][3], {1, STR0039,,,,,,})	//"Outras Contas do realizavel"
	aAdd (aPCfp[18][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[18][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {1, STR0258,,,,,,})	//"- Permanente"
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {1, STR0040,,,,,,})	//"Investimentos"
	aAdd (aPCfp[18][3], {1, STR0041,,,,,,})	//"Imobilizado (Liquido)"
	aAdd (aPCfp[18][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[18][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {1, STR0042,,,,,,})	//"Diferido"
	aAdd (aPCfp[18][3], {1, STR0283,,,,,,})	//"Intangivel"
	aAdd (aPCfp[18][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[18][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	aAdd (aPCfp[18][3], {0, "",,,,,,})
	//Painel do Registro Tipo 92.
	aAdd (aPCfp, {})
	aAdd (aPCfp[19], STR0007)
	aAdd (aPCfp[19], STR0273)	//"Preenchimento de algumas informacöes necessarias para montagem do Registro Tipo 92 - Passivo."
	aAdd (aPCfp[19], {})
	aAdd (aPCfp[19][3], {1, STR0037,,,,,,})	//"Circulante"
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {1, STR0044,,,,,,})	//"Fornecedores"
	aAdd (aPCfp[19][3], {1, STR0045,,,,,,})	//"Emprestimos e financiamentos"
	aAdd (aPCfp[19][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[19][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {1, STR0046,,,,,,})	//"Outras contas do passivo circulante"
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {1, STR0047,,,,,,})	//"- Exigivel a longo prazo"
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {2,,"@E 99,999,999,999.99",2,2,,,17})	
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {1, STR0048,,,,,,})	//"- Resultado de exercicios futuros"
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {2,,"@E 99,999,999,999.99",2,2,,,17})	
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {1, STR0061,,,,,,})	//"- Patrimônio Líquido"
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {1, STR0049,,,,,,})	//"Capital social"
	aAdd (aPCfp[19][3], {1, STR0050,,,,,,})	//"Outras contas do patrimonio liquido"
	aAdd (aPCfp[19][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[19][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {1, STR0150,,,,,,})	//"Outras contas patrimônio líquido (valor negativo)"
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	aAdd (aPCfp[19][3], {0, "",,,,,,})
	//Painel do Registro Tipo 93.
	aAdd (aPCfp, {})
	aAdd (aPCfp[20], STR0007)
	aAdd (aPCfp[20], STR0274)	//"Preenchimento de algumas informacöes necessarias para montagem do Registro Tipo 93 - Demonstracao de resultados."
	aAdd (aPCfp[20], {})
	aAdd (aPCfp[20][3], {1, STR0054,,,,,,})	//"- Receita liquida vendas/servicos"
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {1, STR0052,,,,,,})	//"Receita bruta vendas/servico"
	aAdd (aPCfp[20][3], {1, STR0053,,,,,,})	//"Devolucöes/Abatimentos e impostos"
	aAdd (aPCfp[20][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[20][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {1, STR0056,,,,,,})	//"- Lucro/Prejuíso bruto"
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {1, STR0055,,,,,,})	//"Custo da mercadoria vendida"
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {1, STR0058,,,,,,})	//"- Lucro/prejuizo operacional"
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {1, STR0054,,,,,,})	//"Outras Receitas operacionais	
	aAdd (aPCfp[20][3], {1, STR0057,,,,,,})	//"Despesas operacionais"
	aAdd (aPCfp[20][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[20][3], {2,,"@E 99,999,999,999.99",2,2,,,17})	
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {1, STR0062,,,,,,})	//"- Resultado antes do IR"
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {1, STR0059,,,,,,})	//"Receitas näo operacionais"
	aAdd (aPCfp[20][3], {1, STR0060,,,,,,})	//"Despesas näo operacionais"
	aAdd (aPCfp[20][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[20][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})	
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})	
	aAdd (aPCfp[20][3], {1, STR0064,,,,,,})	//"- Resultado após o IR"
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {1, STR0063,,,,,,})	//"Provisäo para o IR"
	aAdd (aPCfp[20][3], {1, STR0313,,,,,,})	//"Provisão para o IR e para contribuição social"
	aAdd (aPCfp[20][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[20][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {1, STR0066,,,,,,})	//"- Lucro/Prejuizo exercício"
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {0, "",,,,,,})
	aAdd (aPCfp[20][3], {1, STR0065,,,,,,})	//"Participacöes e contribuicöes"
	aAdd (aPCfp[20][3], {0, "",,,,,,})	
	aAdd (aPCfp[20][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	/*
	aAdd (aPCfp[6][3], {1, STR0061,,,,,,})	//"Saldo da conta correcäo monetaria"
	*/
	//
	//Painel do Registro Tipo 94.
	aAdd (aPCfp, {})
	aAdd (aPCfp[21], STR0007)
	aAdd (aPCfp[21], STR0275)	//"Preenchimento de algumas informacöes necessarias para montagem do Registro Tipo 94 - Detalhamento das despesas."
	aAdd (aPCfp[21], {})
	aAdd (aPCfp[21][3], {1, STR0068,,,,,,})
	aAdd (aPCfp[21][3], {1, STR0069,,,,,,})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {1, STR0070,,,,,,})
	aAdd (aPCfp[21][3], {1, STR0071,,,,,,})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {0, "",,,,,,})	
	aAdd (aPCfp[21][3], {1, STR0072,,,,,,})
	aAdd (aPCfp[21][3], {1, STR0073,,,,,,})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {1, STR0074,,,,,,})
	aAdd (aPCfp[21][3], {1, STR0075,,,,,,})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {1, STR0076,,,,,,})
	aAdd (aPCfp[21][3], {1, STR0077,,,,,,})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {1, STR0078,,,,,,})
	aAdd (aPCfp[21][3], {1, STR0079,,,,,,})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {0, "",,,,,,})	
	aAdd (aPCfp[21][3], {1, STR0080,,,,,,})
	aAdd (aPCfp[21][3], {1, STR0081,,,,,,})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {0, "",,,,,,})	
	aAdd (aPCfp[21][3], {1, STR0082,,,,,,})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[21][3], {0,,"",,,,,17})
	aAdd (aPCfp[21][3], {0, "",,,,,,})
	aAdd (aPCfp[21][3], {0, "",,,,,,})

	//Painel do Registro Tipo 46 (Valores retornados da DCIP) e Concessões
	aAdd (aPCfp, {})
	aAdd (aPCfp[22], STR0007)
	aAdd (aPCfp[22], STR0276)	//	"Preenchimento de algumas informacöes necessarias para montagem do Registro Tipo 46 (Créditos por regimes e autorizações especiais), relativo ao Crédito informado no DCIP"
	aAdd (aPCfp[22], {})
	aAdd (aPCfp[22][3], {1, "Informa Protocolos?",,,,,,})
	aAdd (aPCfp[22][3], {3,,,,,{"Sim", "Não"},,})
	
	//Painel do Registro Tipo 48 (Valores retornados da DCIP) e Concessões
	aAdd (aPCfp, {})
	aAdd (aPCfp[23], STR0007)
	aAdd (aPCfp[23], STR0286)	//	Preenchimento de informacöes necessarias para montagem do Registro Tipo 48
	aAdd (aPCfp[23], {})
	aAdd (aPCfp[23][3], {1, "Envia Informações para Reg. 48 em %?",,,,,,})
	aAdd (aPCfp[23][3], {3,,,,,{"Não", "Sim"},,})
	
	//Painel do Registro Tipo 35 (Demonstrativo da Apuração do Imposto Devido pela Apropriação de Crédito Presumido em Substituição aos Créditos pelas Entradas (DAICP)
	aAdd (aPCfp, {})
	aAdd (aPCfp[24], STR0007)
	aAdd (aPCfp[24], STR0298)	//	Preenchimento de informacöes necessarias para montagem do Registro Tipo 48
	aAdd (aPCfp[24], {})
	aAdd (aPCfp[24][3], {1, STR0299,,,,,,})//10
	aAdd (aPCfp[24][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[24][3], {1, STR0300,,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {1, STR0301,,,,,,})//20
	aAdd (aPCfp[24][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[24][3], {1, STR0302,,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {1, STR0303,,,,,,})//30
	aAdd (aPCfp[24][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[24][3], {1, STR0304,,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {1, STR0305,,,,,,})//31
	aAdd (aPCfp[24][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[24][3], {1, STR0306,,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {1, STR0314,,,,,,})//45
	aAdd (aPCfp[24][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[24][3], {1, STR0315,,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {1, STR0307,,,,,,})//50
	aAdd (aPCfp[24][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[24][3], {1, STR0308,,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {1, STR0309,,,,,,})//110
	aAdd (aPCfp[24][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[24][3], {1, STR0310,,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {1, STR0311,,,,,,})//120
	aAdd (aPCfp[24][3], {2,,"@E 99,999,999,999.99",2,2,,,17})
	aAdd (aPCfp[24][3], {1, STR0312,,,,,,})	
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})
	aAdd (aPCfp[24][3], {0, "",,,,,,})	

	lContinua	:=	xMagWizard (aPInicial, aPCfp, "DIME"+cXNumEmp)
   
	If (lContinua)
		lContinua	:=	xMagLeWiz ("DIME"+cXNumEmp, @aWizard, .T.)
	EndIf  
	
	
	
Return (aWizard)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuVlrDimeº Autor ³Gustavo G. Rueda    º Data ³  27/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³Funcao de atualizacao de Registros        				  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  cRegistro  - Numero do Registro							  ³±±
±±³          ³  cQuadro  - Numero do Quadro								  ³±±
±±³          ³  cItem - Numero do Item          						  ³±±
±±³          ³  cValor - Valor utilizado para atualizacao				  ³±±
±±³          ³  nOperacao - Operacao a ser realizada					  ³±±
±±³          ³  (1 - Atribuicao / 2 - Soma / 3  - Subtracao) 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³DIMESC.PRW                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuVlrDime (lRetVlr, cNumero, cQuadro, cItem, nValor, nOperacao, cDesc, nOrigem, lGera)   
	Local 	aAreaTRB   	:= 	TRB->(GetArea ())
	Local	nRet		:=	0  
	//
	Default	lRetVlr	:=	.F.
	Default	cDesc	:=	""
	Default	nOrigem	:=	0
	Default lGera	:= .T.
	//  
	
	If (lRetVlr .And. Empty (cItem) .And. nOrigem<>0)
		If (TRB->(DbSeek (cNumero+cQuadro)))
			Do While !TRB->(Eof ()) .And.;
				cNumero==TRB->TRB_REGIST .And.;
				cQuadro==TRB->TRB_QUADRO
				//
				If (nOrigem==TRB->TRB_ORIGEM)
					If (nOperacao==2)
						nRet	+=	TRB->TRB_VALOR
					ElseIf (nOperacao==3)
						nRet	-=	TRB->TRB_VALOR	-=	nValor
					EndIf
				EndIf
				//
				TRB->(DbSkip ())
			EndDo
		EndIf
		Return (nRet)
	EndIf
	//
	DbSelectArea ("TRB")
	TRB->(DbSetOrder (1))
	If (TRB->(DbSeek (cNumero+cQuadro+cItem)))
		If (lRetVlr)
			nRet	:=	TRB->TRB_VALOR
		Else
			RecLock ("TRB", .F.)
				If (nOperacao==1)
					TRB->TRB_VALOR	:=	nValor
				Else 
					If (nOperacao==2)
						TRB->TRB_VALOR	+=	nValor
					Else  
						If (nOperacao==3)
							TRB->TRB_VALOR	-=	nValor
						EndIf
					EndIf
				EndIf  
	   		MsUnLock ()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao considero itens com valores zerados no TRB, pois a DIME nao considera também. ³
			//³Campos zerados nao devem ser enviados. Com excessao do:                           |
			//| - Quadro 09 itens 999 e 120;                                                     |
			//| - Quadro 80 itens 010 e 020                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		If  (TRB->TRB_VALOR==0) .And.;
	   			!((TRB->TRB_QUADRO=="09" .And. TRB->TRB_ITEM$"999/120") .Or.;
	   			(TRB->TRB_QUADRO$"80/90" .And. TRB->TRB_ITEM$"010/020/030") .Or.;
				(TRB->TRB_QUADRO$"14" .And. TRB->TRB_ITEM$"040" .And. lGera))
		   		RecLock ("TRB", .F.)
		   			TRB->(DbDelete ())
		   		MsUnLock ()
		   	EndIf
		EndIf
	Else
		If (lRetVlr)
			nRet	:=	0
		Else
			If (nValor>0) .Or.;
				(cQuadro=="09" .And. cItem$"999/120") .Or.; 
				(cQuadro=="11" .And. cItem$"999/170") .Or.;
				(cQuadro$"80/90" .And. cItem$"010/020/030") .Or.;
				(cQuadro$"81/91" .And. cItem=="199" .And. nValor==0) .Or.;
				(cQuadro$"82/92" .And. cItem=="299" .And. nValor==0) .Or.;
				(cQuadro$"83/93" .And. cItem=="399" .And. nValor==0) .Or.;
				(cQuadro$"84/94" .And. cItem=="499" .And. nValor==0) .Or.;
				(cQuadro$"14" .And. cItem $ "199/040" .And. nValor==0 .And. lGera)
				RecLock ("TRB", .T.)
					TRB->TRB_REGIST	:=	cNumero
					TRB->TRB_QUADRO	:=	cQuadro
					TRB->TRB_ITEM	:=	cItem
					TRB->TRB_DESCRI	:=	cDesc
					TRB->TRB_VALOR	:=	nValor
					TRB->TRB_ORIGEM	:=	nOrigem
		   		MsUnLock ()
		   EndIf
	   EndIf
	EndIf
	//
RestArea(aAreaTRB)
Return (nRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³aAddLog   º Autor ³Gustavo G. Rueda    º Data ³  27/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³Funcao que atribui em um array algumas inconsistencias p/  oº±±
±±º          ³ arquivo de logo gerado no mesmo diretorio do arquivo texto.º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cSubItem -> Codigo do subitem da apuracao 				  ³±±
±±³          ³nSeq -> Sequencia para o mesmo codigo de subitem, caso tenha³±±
±±³          ³ mais de uma validacao.                                     ³±±
±±³          ³nValor -> Valor principal a ser validado                    ³±±
±±³          ³cString -> String para validacao.                           ³±±
±±³          ³cValido -> Conteudo para verificacao se a string (cString)  ³±±
±±³          ³ esta contida.                                              ³±±
±±³          ³aValor -> Array com todos os valores para o registro.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³DIMESC.PRW                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             		  ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function aAddLog (cSubItem, nSeq, nValor, cString, cValido, aValor, aLog)
	Local	cErro		:=	""
	Local	cSolucao	:=	""
	//
	Default	nSeq	:=	1
	Default	nValor	:=	0
	Default	cString	:=	""
	Default	cValido	:=	""
	Default	aValor	:=	{}
	//
	
	If (SubStr (cSubItem, 1, 2)$"26")
		If (SubStr (cSubItem, 3, 3)$"010")
			If (nSeq==2)
			    If (nValor<>(aValor[8]+aValor[9]+aValor[10]+aValor[11]))
					cErro		+=	STR0250		//"Valor Transportado para o subitem 009 (Saldo Credor do período anterior) [R$ "
					cErro		+=	AllTrim (Str (nValor, 16, 2))
					cErro		+=	STR0251		//"] está diferente do informado no wizard da rotina para o Quadro 41 (Demonstrativo de Créditos Acumulados) [R$ "
					cErro		+=	AllTrim (Str ( aValor[8]+ aValor[9]+aValor[10]+aValor[11], 16, 2))
					cErro		+=	STR0252		//"]."
					//
					cSolucao	:=	STR0253		//"Estes valores não devem estar diferentes, pois a digitação no wizard da "
					cSolucao	+=	STR0254		//"rotina, Quadro 41 (Demonstrativo de Créditos Acumulados) deve compreender "
					 cSolucao	+=	STR0255		//"o mesmo valor lançado no subitem 009 (Saldo Credor do "
					cSolucao	+=	STR0256		//"Período Anterior) na apuração de ICMS."
					//
					aAdd (aLog, {cErro, cSolucao})
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Subtraio os valores dos iten 120, 130 e 140 do Registro 41, pois jah estah incluso³
				//³   nas movimentacoes do mes e consequentemente considerado na Apuracao de         ³
				//³   ICMS do periodo na linha CREDITO POR ENTRADAS.                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				If nValor<AtuVlrDime (.T., "41", "41", "120")+;	//Saldo credor de créditos relativos a exportacao
					AtuVlrDime (.T., "41", "41", "130")+;			//Saldo credor de créditos relativos a saidas isentas
					AtuVlrDime (.T., "41", "41", "140")			//Saldo credor de créditos relativos a saidas diferidas				
					cErro		:=	STR0222		//"O valor de [Credito pelas entradas] NÃO PODE ser inferior a soma dos valores do Quadro 41 "
					cErro		+=	STR0223		//"(Demonstrativo de créditos acumulados), itens 120, 130 e 140."
					//
					cSolucao	:=	STR0224		//"O valor de [Credito pelas entradas] apresentado no meio-magnético foi retirado da Apuração de ICMS "
					cSolucao	+=	STR0225		//"do período e os valores do Quadro 41 (Demonstrativo de créditos acumulados), itens 120, 130 e 140 "
					cSolucao	+=	STR0226		//"são lançados manualmente no assistente da rotina. Sendo assim, a soma dos valores lançados no "
					cSolucao	+=	STR0227		//"assistente da rotina através dos itens 120, 130 e 140 NÃO PODEM ser superior ao [Total de créditos "
					cSolucao	+=	STR0228		//"pelas entradas]."
					//
					aAdd (aLog, {cErro, cSolucao})
				EndIf
			EndIf
		EndIf
	ElseIf (SubStr (cSubItem, 1, 2)$"30")
		If (SubStr (cSubItem, 3, 3)$"130/150")
			If (nValor>0)
				If !(cString$cValido)
					cErro		:=	STR0197+cSubItem+STR0198	//"O código de subitem "###" inserido na Apuração de ICMS não deve ser enviado neste "
					cErro		+=	STR0203	//"meio-magnético gerado com a configuração atual do wizard, pois não se trata de estabelecimento consolidado."
					//
					cSolucao	:=	STR0202	//"Como esta informação somente deve ser enviada por estabelecimentos consolidados, aconselhamos que "
					cSolucao	+=	STR0201	//"se o estabelecimento for CONSOLIDADO, altere a opção [Apuração Consolidada] no wizard da rotina. "
					cSolucao	+=	STR0200+cSubItem+STR0194	//"Se o estabelecimento NÃO for CONSOLIDADO, exclua o codigo de subitem "###" inserido na "
					cSolucao	+=	STR0192	//"Apuração de ICMS."
					//
					aAdd (aLog, {cErro, cSolucao})
				EndIf
			EndIf
		ElseIf (SubStr (cSubItem, 3, 3)$"020/060")
			If (nValor>0)
				If !(cString$cValido)
					cErro		:=	STR0198+cSubItem+STR0199	//"O código de subitem "###" inserido na Apuração de ICMS não deve ser enviado neste "
					cErro		+=	STR0197	//"meio-magnético gerado com a configuração atual do wizard, pois não se trata de estabelecimento consolidador."
					//
					cSolucao	:=	STR0196	//"Como esta informação somente deve ser enviada por estabelecimentos consolidadores, aconselhamos que "
					cSolucao	+=	STR0195	//"se o estabelecimento for realmente CONSOLIDADOR, deve-se altar a opção [Apuração Consolidada] no wizard da rotina. "
					cSolucao	+=	STR0193+cSubItem+STR0194	//"Se o estabelecimento NÃO for CONSOLIDADOR, exclua o código de subitem "###" inserido na "
					cSolucao	+=	STR0192	//"Apuração de ICMS."
					//
					aAdd (aLog, {cErro, cSolucao})
				EndIf
			EndIf
		ElseIf (SubStr (cSubItem, 3, 3)$"998")
			If (nSeq==1) .And. (nValor>0) .And. (nValor<>aValor[21]+aValor[22]+aValor[23]+aValor[24])
				cErro		:=	STR0191	//"Valor de credito resultante da Apuração de ICMS não possui saldo relacionado."
				//
				cSolucao	:=	STR0190	//"Quando se tratar de Apuração com SALDO CREDOR, o mesmo deverá ter um apontamento no wizard da rotina. Em uma das opções "
				cSolucao	+=	STR0189+CHR (13)+CHR (10)	//"do Registro 30: "
				cSolucao	+=	STR0188+CHR (13)+CHR (10)	//"1) De créditos relativos a exportação "
				cSolucao	+=	STR0187+CHR (13)+CHR (10)	//"2) De créditos relativos a saídas isentas "
				cSolucao	+=	STR0186+CHR (13)+CHR (10)	//"3) De créditos relativos a saídas diferidas "
				cSolucao	+=	STR0185	//"4) De Outros créditos "
				//
				aAdd (aLog, {cErro, cSolucao})
				
			ElseIf (nSeq==2) .And. (nValor<=0) .And. ;
				AtuVlrDime (.T., "41", "41", "960")+AtuVlrDime (.T., "41", "41", "970")+AtuVlrDime (.T., "41", "41", "980")>0
				cErro		:=	STR0206	//"Registro 41 (Demonstrativo de Creditos Acumulados) NÃO deve ser enviado nesta declaração."
				//
				cSolucao	:=	STR0207	//"O Registro 41 (Demonstrativo de Creditos Acumulados) somente deve ser enviado quando a Apuração de ICMS "
				cSolucao	+=	STR0208	//"resultar um SALDO CREDOR para o período. Como o tratamento para este quadro se baseia em lançamentos "
				cSolucao	+=	STR0209	//"manuais na Apuração de ICMS (conforme boletim), deve-se observar se estes lançamentos estão sendo realizados"
				cSolucao	+=	STR0210	//"em uma Apuração com SALDO CREDOR, caso NÃO seja a situação desta Apuração, deve-se retirar os lançamentos "
				cSolucao	+=	STR0211	//"manuais."
				//
				aAdd (aLog, {cErro, cSolucao})
			EndIf
		ElseIf (SubStr (cSubItem, 3, 3)$"999")
			If (nSeq==1) .And. (cString$cValido) .And. (nValor>0)
				cErro		:=	STR0184	//"Valor do Imposto a Recolher quando para estabelecimento consolidado não deve possui valor."
				//
				cSolucao	:=	STR0183	//"Quando se tratar de Apuração CONSOLIDADA com SALDO DEVEDOR a mesma deverá ter "
				cSolucao	+=	STR0182	//"seu valor ZERADO, ou seja, a Apuração de ICMS NÃO deve ter IMPOSTO A RECOLHER quando se tratar de "
				cSolucao	+=	STR0181+CHR (13)+CHR (10)	//"estabelecimento CONSOLIDADO."
				cSolucao	+=	STR0180	//"- Para ZERAR o Saldo da Apuração será necessário inserir o código de subitem 30130 em OUTROS CRÉDITO "
				cSolucao	+=	STR0179	//"com o objetivo de ZERAR o valor do Imposto a Recolher. Este código de subitem identifica que o SALDO "
				cSolucao	+=	STR0178+CHR (13)+CHR (10)	//"DEVEDOR será transferido ao estabelecimento consolidador."
				cSolucao	+=	STR0177	//"- No caso do SALDO DEVEDOR não ter a necessidade de ser transferido ao estabelecimento consolidador, "
				cSolucao	+=	STR0176	//"basta alterar a pergunta [Apuração Consolidada] no WIZARD da rotina para [Não é Apuração Consolidada],"
				cSolucao	+=	STR0175	//"neste caso, o código de subitem 30130 nã deverá ser incluído na Apuração de ICMS e o valor do IMPOSTO "
				cSolucao	+=	STR0174	//"A RECOLHER contido em um GNRE."
				//
				aAdd (aLog, {cErro, cSolucao})
			EndIf
		EndIf
	ElseIf (SubStr (cSubItem, 1, 2)$"41")
		If (SubStr (cSubItem, 3, 3)$"220")
			If (nValor<>AtuVlrDime (.T., "42", "42", "010"))
				cErro		:=	STR0212	//"Valor de Estorno de Débito para o Registro 41 (Demonstrativo de Créditos Acumulados) NÃO está correto."
				//
				cSolucao	:=	STR0213+cSubItem	//"Quando houver Lançamento manual na Apuração de ICMS para o código de subitem ["
				cSolucao	+=	STR0214				//"], o mesmo deverá ser o mesmo valor lançado com o código de subitem "
				cSolucao	+=	"[42010]."
				//
				aAdd (aLog, {cErro, cSolucao})
			EndIf
		ElseIf (SubStr (cSubItem, 3, 3)$"230")
			If (nValor<>AtuVlrDime (.T., "42", "42", "020"))
				cErro		:=	STR0212	//"Valor de Estorno de Débito para o Registro 41 (Demonstrativo de Créditos Acumulados) NÃO está correto."
				//
				cSolucao	:=	STR0213+cSubItem	//"Quando houver Lançamento manual na Apuração de ICMS para o código de subitem ["
				cSolucao	+=	STR0214				//"], o mesmo deverá ser o mesmo valor lançado com o código de subitem "
				cSolucao	+=	"[42020]."
				//
				aAdd (aLog, {cErro, cSolucao})
			EndIf 
		ElseIf (SubStr (cSubItem, 3, 3)$"240")
			If (nValor<>AtuVlrDime (.T., "42", "42", "030"))
				cErro		:=	STR0212	//"Valor de Estorno de Débito para o Registro 41 (Demonstrativo de Créditos Acumulados) NÃO está correto."
				//
				cSolucao	:=	STR0213+cSubItem	//"Quando houver Lançamento manual na Apuração de ICMS para o código de subitem ["
				cSolucao	+=	STR0214				//"], o mesmo deverá ser o mesmo valor lançado com o código de subitem "
				cSolucao	+=	"[42030]."
				//
				aAdd (aLog, {cErro, cSolucao})
			EndIf
		EndIf
	ElseIf (SubStr (cSubItem, 1, 2)$"44")
		If (SubStr (cSubItem, 3, 3)$"130/131")
			//Tipo da declaracao
			If (nValor>0) .And. !("Normal"$aValor[2][2] .Or. "Encerramento"$aValor[2][2])
				cErro		:=	STR0173	//"Valor de Fundo Social e/ou Credito 10% Fundo Social não deve ser calculado na Apuração de ICMS para "
				cErro		+=	STR0172	//"Declaração do tipo [Saída Regime Estimativa Fiscal], configurado no WIZARD da rotina."
				//
				cSolucao	:=	STR0171	//"Quando se tratar de declaração do tipo [Saída Regime Estimativa Fiscal] os lançamentos automáticos "
				cSolucao	+=	STR0170	//"via P9AUTOTEXT.SC (localizado no diretório SIGAADV ou correspondente) para o Fundo Social, Crédito 10%"
				cSolucao	+=	STR0169	//" Fundo Social e Simples não devem ser calculados no período. Como estes cálculos se baseiam em movimentações, "
				cSolucao	+=	STR0168+cSubItem+")"	//"deve-se verificar com a SECRETARIA/FISCO, como proceder nesta situação.(Item: "
				//
				aAdd (aLog, {cErro, cSolucao})
			ElseIf (nValor>0) .And. !("Sim"$aValor[2][8])
				cErro		:=	STR0173	//"Valor de Fundo Social e/ou Credito 10% Fundo Social não deve ser calculado na Apuração de ICMS para "
				cErro		+=	STR0204	//"Declaração que NÃO trata Crédito Presumido, configurado no WIZARD da rotina como NÃO."
				//
				cSolucao	:=	STR0205	//"Quando se tratar de declaração sem Crédito Presumido os lançamentos automáticos "
				cSolucao	+=	STR0170	//"via P9AUTOTEXT.SC (localizado no diretório SIGAADV ou correspondente) para o Fundo Social, Crédito 10%"
				cSolucao	+=	STR0169	//" Fundo Social e Simples não devem ser calculados no período. Como estes cálculos se baseiam em movimentações, "
				cSolucao	+=	STR0168+cSubItem+")"	//"deve-se verificar com a SECRETARIA/FISCO, como proceder nesta situação.(Item: "
				//
				aAdd (aLog, {cErro, cSolucao})
			EndIf			
		EndIf
	ElseIf (SubStr (cSubItem, 1, 2)$"XX")
		If (nSeq==1) .And. ("Sim"$aValor[2][8]) .And. !("Normal"$aValor[2][2] .Or. "Encerramento"$aValor[2][2])
			cErro		:=	STR0167	//"A opção [Tem Crédito Presumido] configurado no WIZARD da rotina não deve estar como SIM quando o "
			cErro		+=	STR0166	//"Tipo da Declaração está também configurado como [Saída Regime Estimativa Fiscal]."
			//
			cSolucao	:=	STR0165	//"Quando se tratar de declaração do tipo [Saída Regime Estimativa Fiscal] o quadro de Crédito Presumido (44) "
			cSolucao	+=	STR0164	//"não deve ser enviado, para isso, deve-se alterar o WIZARD da rotina para NÃO na opção [Tem Crédito Presumido]."
			//
			aAdd (aLog, {cErro, cSolucao})
			
		ElseIf (nSeq==2) .And. !("Estimativa"$aValor[2][3]) .And. !("Normal"$aValor[2][2] .Or. "Encerramento"$aValor[2][2])
			cErro		:=	STR0161	//"A opção tipo de declaração configurado no WIZARD da rotina para [Saída Regime Estimativa Fiscal] "
			cErro		+=	STR0162	//"não confere com a opção [Regime de Apuração]."
			//
			cSolucao	:=	STR0163	//"A opção [Regime de Apuração] deve estar como [Estimativa] para tipo de declaração [Saída Regime Estimativa Fiscal]."
			//
			aAdd (aLog, {cErro, cSolucao})
		EndIf
	EndIf
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraTxtLogº Autor ³Gustavo G. Rueda    º Data ³  27/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³Funcao que gera o arquivo TXT de log.                       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cDir -> Diretorio a ser gerado o arquivo de log.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³DIMESC.PRW                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTxtLog (cDir, aLog)
	Local	lRet	:=	.T.
	Local	cTxt	:=	AllTrim (cDir)+"LOGDIME.TXT"
	Local	nHandle	:=	0
	Local	cTxtBkp	:=	""
	Local	nI		:=	0
	//
	If !(File (cTxt))
		nHandle	:=	MsFCreate (cTxt)
	Else
		cTxtBkp	:=	StrTran	(cTxt,	".TXT",	".#XT")
		If File (cTxtBkp)
			FErase (cTxtBkp)
		Endif
		FRename (cTxt, cTxtBkp)
		nHandle	:=	MsFCreate (cTxt)
	Endif
	//
		//
	If (Len (aLog)==0)
		cRegistro	:=	STR0158	//"Nenhuma ocorrência conhecida foi constatada."
		DIMEGRV (cRegistro, @nHandle)
	Else
		For nI := 1 To Len (aLog)
			cRegistro	:=	STR0159+Str (nI, 3)+"): "+aLog[nI][1]		//"ERRO("
			DIMEGRV (cRegistro, @nHandle)
			//
			cRegistro	:=	STR0160+Str (nI, 3)+"): "+aLog[nI][2]		//"SOLUCAO("
			DIMEGRV (cRegistro, @nHandle)
			//
			DIMEGRV ("", @nHandle)
		Next (nI)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha arquivo texto                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	If (nHandle>=0)
		FClose (nHandle)
	Endif	
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIMEGrv   º Autor ³Gustavo G. Rueda    º Data ³  27/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³Funcao de gravacao do nHandle.                              º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cConteudo -> Conteudo a ser gravado.                        ³±±
±±³          ³nHandle -> Handle do arquivo.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³DIMESC.PRW                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIMEGrv (cConteudo, nHandle)
	cConteudo += Chr (13)+Chr (10)
	
	FWrite (nHandle, cConteudo, Len (cConteudo))
Return (.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³aAddGNRE  º Autor ³Gustavo G. Rueda    º Data ³  27/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³Funcao que adiciona itens no array de debitos especificos paraº±±
±±º          ³ poder filtrar o SF6.                                       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aGNRE -> Array contendo os Codigos de Receita e Classe de   ³±±
±±³          ³ vencimento.                                                ³±±
±±³          ³aApICM -> Array de Apuracao                                 ³±±
±±³          ³cSubItem -> Codigo de subitem                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³DIMESC.PRW                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function aAddGNRE (aGNRE, aApICM, cSubItem)
	Local	cGNRE	:=	""
	Local	lRet	:=	.F.
	//
    //Como eh padrao o lancamento para debitos especificos do Codigo de receita e classe de vencimento tambem.
	If (aScan (aApICM, {|a| a[4]==cSubItem})<>0)
    	cGNRE	:=	AllTrim (aApICM[aScan (aApICM, {|a| a[4]==cSubItem})][5])
    	If (aScan (aGNRE, cGNRE)==0)    		
		    aAdd (aGNRE, cGNRE)	//Armazeno as informacoes para gerar as GNRE dos debitos especificos.
		    lRet	:=	.T.
	   	EndIf
	EndIf
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetAp46   º Autor ³Gustavo G. Rueda    º Data ³  08/05/2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³Funcao para retornar as informacoes a serem geradas no      º±±
±±º          ³ no registro 46 de acordo com os lancamentos na apuracao.   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aApICM -> Array de Apuracao                                 ³±±
±±³          ³aGer46 -> Array a ser retornado com as informacoes para o   ³±±
±±³          ³ registro 46.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³DIMESC.PRW                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetAp46 (aApICM, aGer46, nAcItem)
	Local	nI		:=	0
	Local	cRegEsp	:=	""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PARA ESTES ITENS QUE IRAO GERAR O QUADRO 46 EH POSSIVEL TER MAIS DE UM         ³
	//³  SUBITEM, BASTA INSERIR COM AS 5 PRIMEIRAS POSICOES IGUAIS, POIS SERAO GERADOS³
	//³  UM A UM NO QUADRO 46 E ACUMULADO NO QUADRO 44. PODE OCORRER DE HAVER MAIS DE ³
	//³  CREDITO NO PERIODO PARA A MESMA ORIGEM. EX: FUNTURISMO DUAS VEZES NO PERIODO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    For nI := 1 To Len (aApICM)
	    //Reg. 44, item 140 - Aplicacao no FUNCULTURAL
    	If ("44140"$aApICM[nI][4])
	    	nAcItem++
	    	//Reg. 44, item 140 - Aplicacao no FUNCULTURAL - Descricao do regime especial para lancamento no quadro 46.
		    If (aApICM[nI][3]>0)
			    cRegEsp	:=	Left (aApICM[nI][2], 15)
			    aAdd (aGer46, {"46", "46", StrZero (nAcItem, 3), aApICM[nI][3], 2, cRegEsp, 2})
		    EndIf

		//Reg. 44, item 150 - Aplicacao no FUNTURISMO
		ElseIf ("44150"$aApICM[nI][4])
			nAcItem++
	    	//Reg. 44, item 150 - Aplicacao no FUNTURISMO  - Descricao do regime especial para lancamento no quadro 46.
		    If (aApICM[nI][3]>0)
			    cRegEsp	:=	Left (aApICM[nI][2], 15)
			    aAdd (aGer46, {"46", "46", StrZero (nAcItem, 3), aApICM[nI][3], 2, cRegEsp, 3})
		    EndIf
		    
		//Reg. 44, item 160 - Aplicacao no FUNDESPORTE 
		ElseIf ("44160"$aApICM[nI][4])
			nAcItem++
    		//Reg. 44, item 160 - Aplicacao no FUNDESPORTE   - Descricao do regime especial para lancamento no quadro 46.
		    If (aApICM[nI][3]>0)
   					    cRegEsp	:=	Left (aApICM[nI][2], 15)
	    		aAdd (aGer46, {"46", "46", StrZero (nAcItem, 3), aApICM[nI][3], 2, cRegEsp, 4})
		    EndIf	
		 
		//Reg. 26, item 140 - Outros Creditos por regime especial
		ElseIf ("26140"$aApICM[nI][4])
			nAcItem++
			//Outros Creditos por regime especial - Quando gerar esta informacao para o registro 26, item 140 o registro do quadro 46
			//	deve estar com o mesmo valor.
		    If (aApICM[nI][3]>0)
   					    cRegEsp	:=	Left (aApICM[nI][2], 15)
	    		aAdd (aGer46, {"46", "46", StrZero (nAcItem, 3), aApICM[nI][3], 2, cRegEsp, 14})
		    EndIf
		    	
		//Reg. 41, item 220 - Estorno de debito por transferencia de creditos relativo a exportacoes
		ElseIf ("41220"$aApICM[nI][4])
			nAcItem++
  			//Reg. 41, item 220 - Estorno de debito por transferencia de creditos relativo a exportacoes - Esta informacao deve acompanhar o item 220 do quadro 41.
		    If (aApICM[nI][3]>0)
   					    cRegEsp	:=	Left (aApICM[nI][2], 15)
	    		aAdd (aGer46, {"46", "46", StrZero (nAcItem, 3), aApICM[nI][3], 2, cRegEsp, 11})
		    EndIf
		    
		//Reg. 41, item 230 - Estorno de debito por transferencia de creditos relativo a saidas isentas
		ElseIf ("41230"$aApICM[nI][4])
			nAcItem++
    		//Reg. 41, item 230 - Estorno de debito por transferencia de creditos relativo a saidas isentas - Esta informacao deve acompanhar o item 230 do quadro 41.
		    If (aApICM[nI][3]>0)
   			    cRegEsp	:=	Left (aApICM[nI][2], 15)
	    		aAdd (aGer46, {"46", "46", StrZero (nAcItem, 3), aApICM[nI][3], 2, cRegEsp, 12})
		    EndIf		    
		//Reg. 41, item 240 - Estorno de debito por transferencia de creditos relativo a saidas diferidas
		ElseIf ("41240"$aApICM[nI][4])
			nAcItem++
 			//Reg. 41, item 240 - Estorno de debito por transferencia de creditos relativo a saidas diferidas - Esta informacao deve acompanhar o item 240 do quadro 41.
		    If (aApICM[nI][3]>0)
   			   cRegEsp	:=	Left (aApICM[nI][2], 15)
	    			aAdd (aGer46, {"46", "46", StrZero (nAcItem, 3), aApICM[nI][3], 2, cRegEsp, 13})
 		    EndIf		    
		//Reg. 30, item 070 - Crédito por transferência de créditos acumulados
		ElseIf ("09070"$aApICM[nI][4])
			nAcItem++
		    If (aApICM[nI][3]>0)
			    cRegEsp	:=	Left (aApICM[nI][2], 15)
	    		aAdd (aGer46, {"46", "46", StrZero (nAcItem, 3), aApICM[nI][3], 2, cRegEsp, 1})
		    EndIf		    
    	EndIf    	
    Next (nI)
    
Return (.T.) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³DIME32B   ³ Autor ³Rodrigo Trefft         ³ Data ³20.Jul.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para preenchimento automatico dos dados constantes   ³±±
±±³          ³no quadro 11 - Registro 32.                                 ³±±
±±³          ³Estes dados serao apresentados no wizard para geracao do    ³±±
±±³          ³arquivo magnetico                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet -> Vetor com os valores, sendo:                        ³±±
±±³          ³        [01]: Valor dos produtos (Val. Contabil)            ³±±
±±³          ³        [02]: Valor do IPI                                  ³±±
±±³          ³        [03]: Despesas Acessorias                           ³±±
±±³          ³        [04]: Base ICMS                                     *±±
±±³          ³        [05]: Valor ICMS                                    ³±±
±±³          ³        [06]: Base ICMS-ST                                  ³±±
±±³          ³        [07]: Valor ICMS-ST                                 ³±±
±±³          ³        [08]: Saldo Credor Período Anterior                 ³±±
±±³          ³        [09]: Outros Creditos                               ³±±
±±³          ³        [10]: Debitos por Ocasiao do Fato Gerador           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIME32b()
Local	nVlrTeste	:= 0
Local	nVlrSldC	:= 0
Local	nVlrCred	:= 0
Local	nVlrDeb		:= 0
Local	aApICM1D	:= FisApur ("ST", Year (MV_PAR02), Month (MV_PAR02), 1, 4, "*", .F., {}, 1, .F., "")
Local	aApICM2D	:= FisApur ("ST", Year (MV_PAR02), Month (MV_PAR02), 1, 3, "*", .F., {}, 1, .F., "")
Local	aApICMMe	:= FisApur ("ST", Year (MV_PAR02), Month (MV_PAR02), 3, 0, "*", .F., {}, 1, .F., "")
Local 	aDadosApur 	:= {}
Local 	cQuery     	:= ""
Local 	cAliasQry  	:= ""
Local 	nX         	:= 0

//1. DECENDIO
//Imposto a recolher
nVlrTeste	+=	Abs(Iif (aScan (aApICM1D, {|a| a[1]=="015"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[1]=="015"})][3], 0))
//Saldo Credor
nVlrTeste	+=	Abs(Iif (aScan (aApICM1D, {|a| a[1]=="016"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[1]=="016"})][3], 0))
//Por saidas
nVlrTeste	+=	Abs(Iif (aScan (aApICM1D, {|a| a[1]=="001"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[1]=="001"})][3], 0))
//Por entradas
nVlrTeste	+=	Abs(Iif (aScan (aApICM1D, {|a| a[1]=="006"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[1]=="006"})][3], 0))
//2. DECENDIO
//Imposto a recolher
nVlrTeste	+=	Abs(Iif (aScan (aApICM2D, {|a| a[1]=="015"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[1]=="015"})][3], 0))
//Saldo Credor
nVlrTeste	+=	Abs(Iif (aScan (aApICM2D, {|a| a[1]=="016"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[1]=="016"})][3], 0))
//Por saidas
nVlrTeste	+=	Abs(Iif (aScan (aApICM2D, {|a| a[1]=="001"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[1]=="001"})][3], 0))
//Por entradas
nVlrTeste	+=	Abs(Iif (aScan (aApICM2D, {|a| a[1]=="006"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[1]=="006"})][3], 0))
//Apuracao foi efetuada de forma decendial.
If nVlrTeste<>0	
	nVlrSldC	+=	Iif (aScan (aApICM1D, {|a| a[1]=="009"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[1]=="009"})][3], 0)
	nVlrSldC	+=	Iif (aScan (aApICM2D, {|a| a[1]=="009"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[1]=="009"})][3], 0)
	nVlrCred	+=	Abs(Iif (aScan (aApICM1D, {|a| a[1]=="006"})<>0, aApICM1D[aScan (aApICM1D, {|a| a[1]=="006"})][3], 0))
	nVlrCred	+=	Abs(Iif (aScan (aApICM2D, {|a| a[1]=="006"})<>0, aApICM2D[aScan (aApICM2D, {|a| a[1]=="006"})][3], 0)) 
	nVlrDeb		+=	Abs(Iif (aScan (aApICMMe, {|a| a[1]=="005"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[1]=="005"})][3], 0))
Else
	nVlrSldC	+=	Iif (aScan (aApICMMe, {|a| a[1]=="009"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[1]=="009"})][3], 0)
	nVlrCred	+=	Abs(Iif (aScan (aApICMMe, {|a| a[1]=="006"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[1]=="006"})][3], 0))
	nVlrDeb		+=	Abs(Iif (aScan (aApICMMe, {|a| a[1]=="005"})<>0, aApICMMe[aScan (aApICMMe, {|a| a[1]=="005"})][3], 0))
EndIf

#IFDEF TOP
	cQuery := "SELECT SF3.F3_FILIAL, SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_VALCONT, SF3.F3_BASEICM, SF3.F3_VALICM, "
	cQuery += "       SF3.F3_VALIPI, SF3.F3_ICMSRET, SF3.F3_BASERET, SF3.F3_DESPESA, SF3.F3_DTCANC, SF3.F3_ESTADO, SF3.F3_CFO "
	cQuery += "FROM   " + RetSqlTab("SF3")                                    				
	cQuery += " WHERE SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND "
	cQuery += "       SF3.F3_ENTRADA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' AND SF3.F3_DTCANC = ' ' AND"
	cQuery += "       SF3.F3_ICMSRET > 0 AND SF3.D_E_L_E_T_ = ' '"
	
	cQuery    := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
#ELSE
	cAliasQry := "SF3"
	cArqTrb   := CriaTrab(,.F.)
	cKey      := "DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA"
	cQuery    := "F3_FILIAL == '" + xFilial("SF3") + "' .And. "
	cQuery    += "DTOS(F3_ENTRADA) >= '" + DtoS(MV_PAR01) + "' .And. DTOS(F3_ENTRADA) <= '" + DtoS(MV_PAR02) + "' .And. EMPTY(SF3->F3_DTCANC)"

	IndRegua(cAliasQry, cArqTrb, cKey,, cQuery,, .F.)
#ENDIF		

aDadosApur := {0,0,0,0,0,0,0,0,0,0,0,0}

(cAliasQry)->(DbGoTop())
While !(cAliasQry)->(Eof())
		   
	If 	SubStr((cAliasQry)->F3_CFO, 1, 1) >= '5' .AND. SubStr((cAliasQry)->F3_CFO, 1, 1) <= '7'
		If(cAliasQry)->F3_ESTADO == "SC"
			aDadosApur[1] += (cAliasQry)->F3_VALCONT
			aDadosApur[2] += (cAliasQry)->F3_VALIPI
			aDadosApur[3] += (cAliasQry)->F3_DESPESA
			aDadosApur[4] += (cAliasQry)->F3_BASEICM
			aDadosApur[5] += (cAliasQry)->F3_VALICM
			aDadosApur[6] += (cAliasQry)->F3_BASERET			            
			aDadosApur[7] += (cAliasQry)->F3_ICMSRET
		EndIf
	Else
			aDadosApur[8] := nVlrSldC
			aDadosApur[9] := nVlrCred + nVlrDeb
	EndIF 
		
(cAliasQry)->(DbSkip())
End

//--Fecha a Query e/ou filtro na tabela temporaria
(cAliasQry)->(DbCloseArea())

#IFNDEF TOP
	RetIndex(cAliasQry)
	FErase(cArqTrb+OrdBagExt())
#ENDIF

// totalizar o valor da guia para levar para o item 065 do quadro 11
cQuery      := ""
cAliasQry   := ""
#IFDEF TOP
	cQuery := "SELECT SF6.F6_FILIAL, SF6.F6_DTARREC, SF6.F6_MESREF, SF6.F6_EST, SF6.F6_CODREC, SF6.F6_TIPOIMP, SF6.F6_VALOR, SF6.F6_JUROS, SF6.F6_MULTA, SF6.F6_CLAVENC "
	cQuery += "FROM   " + RetSqlTab("SF6")                                    				
	cQuery += " WHERE SF6.F6_FILIAL = '" + xFilial("SF6") + "' AND SF6.F6_DTARREC >= '" + DTOS(MV_PAR01)+ "' AND F6_DTARREC<='"+DTOS (MV_PAR02)	
	cQuery += "' AND F6_TIPOIMP IN ('1', '3')"
	cQuery += " AND SF6.F6_EST = 'SC' AND SF6.F6_CODREC IN ('1473', '1554', '1570', '1589', '1651', '1716', '1724', '1740', '1759') AND SF6.D_E_L_E_T_ = ' '"
	
	cQuery    := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
#ELSE
	cAliasQry := "SF6"
	cArqTrb   := CriaTrab(,.F.)
	cKey      := "DTOS(F6_DTARREC)+STRZERO(F6_MESREF,2)+STRZERO(F6_ANOREF,4)"
	cQuery    := "F6_FILIAL == '" + xFilial("SF6") + "' .And. "	
	cQuery    += "F6_ANOREF == " + StrZero (Year (MV_PAR01), 4) + " .And. F6_MESREF == " + StrZero(Month (MV_PAR02), 2)
	cQuery    +=  " .And. (F6_TIPOIMP $ '1/3') .And. F6_EST == 'SC' .And. (F6_CODREC $ '1473/1554/1570/1589/1651/1716/1724/1740/1759')"
	IndRegua(cAliasQry, cArqTrb, cKey,, cQuery,, .F.)
#ENDIF	

(cAliasQry)->(DbGoTop())
While !(cAliasQry)->(Eof())
	If Alltrim((cAliasQry)->F6_CODREC) == '1740' .And. Alltrim((cAliasQry)->F6_CLAVENC) == '19992'
		aDadosApur[11] += (cAliasQry)->F6_VALOR + (cAliasQry)->F6_JUROS + (cAliasQry)->F6_MULTA			
	Else 
		aDadosApur[10] += (cAliasQry)->F6_VALOR + (cAliasQry)->F6_JUROS + (cAliasQry)->F6_MULTA
	EndIf 
	(cAliasQry)->(DbSkip())
End

//--Fecha a Query e/ou filtro na tabela temporaria
(cAliasQry)->(DbCloseArea())

#IFNDEF TOP
	RetIndex(cAliasQry)
	FErase(cArqTrb+OrdBagExt())
#ENDIF
	
//--Transforma os elementos do vetor em caractere para utilizacao na funcao --xMagLeWiz()
For nX := 1 To Len(aDadosApur)
	aDadosApur[nX] := AllTrim(Str(aDadosApur[nX]))
Next

Return(aDadosApur)      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IncProtoc ³ Autor ³Patricia Rajao         ³ Data ³23/08/2010³±±                                                 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina auxiliar para incluir protocolos (Grid)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aWizard -> Array com as informacoes preenchidas.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IncProtoc()
	//conforme exemplo TDN - IncProtoc(cAlias,nReg,nOpc)
	//Local nX					:= 0
	Local aHeader			:= {}
	//Local aCampos			:= {}                     
	//Local aCols1			:= {} 
	//Local aCols2			:= {} 
	//Local aCols3			:= {} 
	//Local aCols4			:= {} 
	//Local aCols5			:= {} 
	//Local aCols6			:= {}
	//Local aParams			:= {}

	Private oDlg
	PRIVATE oGetD
	Private aCols			:= {}        
	Private VISUAL			:= .T.
	Private INCLUI			:= .T.
	Private ALTERA			:= .T.
	Private DELETA			:= .T.
	Private aPageCtrl1		:= {"Aba 1","Aba 2"}

	Private aAlterGDa		:= {}
	Private oEnch
	Private aTELA[0][0]
	Private aGETS[0]

	// Carrega aHeader       
	Aadd(aHeader,{'Protocolo      ','TXT_PROT'    ,'@!'                   ,015  ,0, '','€€€€€€€€€€€€€€ ','C','','    ',''})
	Aadd(aHeader,{'Valor          ','TXT_VALOR'   ,'@E 99,999,999,999.99' ,017  ,2, '','€€€€€€€€€€€€€€ ','N','','    ',''})
	Aadd(aHeader,{'Origem         ','TXT_ORIGEM'  ,'@E 99'                ,002  ,2, '','€€€€€€€€€€€€€€ ','N','','    ',''})
	Aadd(aHeader,{'Credito ST     ','TXT_CRDST'   ,'@!'               	   ,005  ,0, 'Pertence("12")','€€€€€€€€€€€€€€ ','C','','','1=Sim;2=Nao'})

	//	DEFINE MSDIALOG oDlg TITLE "Configuração da AutoNf-e" FROM 178,181 TO 532,717 PIXEL - autonfe
	oDlg := MSDIALOG():New(000,000,400,600, "Processamento da DIME-SC",,,,,,,,,.T.)
	nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
	// Cria os Botoes
	@ 158,228 Button "OK"      Size 037,012 PIXEL OF oDlg ACTION (nOpca := 1, oDlg:End())
	@ 158,186 Button "Cancela" Size 037,012 PIXEL OF oDlg ACTION (nOpca := 0, oDlg:End())	
	// Chamada da GetDados
	oGetD:= MsNewGetDados():New(001,001,150,300, nOpc,,,,,000,999,,,,oDLG,aHeader,aCols)
    
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0,.F.)

Return(oGetD:aCols) 

//-------------------------------------------------------------------
/*/{Protheus.doc} DIMEDIFAL
INFORMAÇÕES SOBRE DIFERENÇA DE ALÍQUOTA DE OPERAÇÃO INTERESTADUAL À CONSUMIDOR

@author Mauro A. Goncalves
@since 21/06/2016
@version P11

/*/
//-------------------------------------------------------------------
Static Function DIMEDIFAL(aWizard)

Local	aValor		:=	{0,0,0,0,0,0,0,0,0,0,0,0,0}	// 1- 010 - Débito da diferença de alíquota devido ao Estado
														// 2- 020 - Outros débitos
											   			// 3- 040 - Outros Debitos
											   			// 4- 050 - Saldo credor do período anterior sobre a diferença de alíquota 
											  			// 5- 060 - Devolução de mercadorias e anulações de venda
											  			// 6- 070 - Outros créditos
											 			// 7- 090 - Total de créditos
											 			// 8- 100 - Pagamentos Antecipados
											 			// 9- 110 - Total Pagamentos Antecipados
											 			//10- 120 - Saldo devedor = (Total de Débitos-(Total de Créditos + Total de Pagamentos Antecipados))   --SALDO DEVEDOR F0I_DEVDIF
														//11- 130 - Saldo devedor a compensar em conta gráfica   - deduções F0I_DEDDIF
														//12- 150 - Saldo Credor = (Total de Créditos+Total de ajustes das antecipações combustíveis)-(Total de Débitos))
														//13- 998 - Saldo Credor da diferença de alíquota para o mês seguinte
Local	cFrom		:=	"%"+RetSqlName("F0I")+" F0I%"
Local	cWhere		:=	""
Local	cSelect	:=	"%*%"
Local	cAliasF0I	:=	""

If !AliasIndic("F0I")
	Return aValor
Endif

cWhere	:=	"%F0I.F0I_FILIAL='"+xFilial("F0I")+"' AND "
cWhere	+=	"F0I.F0I_PER>='"+Dtos(FIRSTDAY(MV_PAR01))+"' AND "
cWhere	+=  "F0I.F0I_PER<='"+Dtos(LASTDAY(MV_PAR02))+"' AND "
cWhere	+=	"F0I.F0I_UF = 'SC' AND "
cWhere	+=	"F0I.D_E_L_E_T_=''%"

If (TcSrvType ()<>"AS/400")
	cAliasF0I	:=	GetNextAlias()
	BeginSql Alias cAliasF0I
		SELECT 
			%Exp:cSelect%
		FROM 
			%Exp:cFrom%
		WHERE 
			%Exp:cWhere%
	EndSql
Endif

While !(cAliasF0I)->(Eof())
	aValor[1]	+=	(cAliasF0I)->(Iif(F0I_DEBDIF > 0, F0I_DEBDIF, 0))
	aValor[2]	+=	(cAliasF0I)->(Iif(F0I_OUTDEB > 0, F0I_OUTDEB, 0))
	aValor[4]	+=	(cAliasF0I)->(Iif(F0I_SADIF  > 0, F0I_SADIF,  0))
	aValor[5]	+=	(cAliasF0I)->(Iif(F0I_CRDDIF > 0, F0I_CRDDIF, 0))
	aValor[6]	+=	(cAliasF0I)->(Iif(F0I_OUTCRE > 0, F0I_OUTCRE, 0))
	aValor[10]	+=	(cAliasF0I)->(Iif(F0I_DEVDIF > 0, F0I_DEVDIF, 0))
	aValor[11]	+=	(cAliasF0I)->(Iif(F0I_DEDDIF > 0, F0I_DEDDIF, 0))
	aValor[12]	+=	(cAliasF0I)->(Iif(F0I_SPDIF  > 0, F0I_SPDIF,  0))
	aValor[13]	+=	(cAliasF0I)->(Iif(F0I_SPDIF  > 0, F0I_SPDIF,  0))
	(cAliasF0I)->(dbSkip())
Enddo
(cAliasF0I)->(DbCloseArea())

Return aValor

//-------------------------------------------------------------------
/*/{Protheus.doc} CALCPRESU
INFORMAÇÕES SOBRE CREDITO PRESUMIDO PARA QUADROS 30 E 14

@author Rafael Santos
@since 14/08/2017
@version P11

/*/
//-------------------------------------------------------------------
Function CALCPRESU(dDtIni,dDtFim,aWizard)

Local aArea  	:= GetArea()
Local cAlias 	:= GetNextAlias()
Local aValor	:= {0,0,0,0,0,0,0,0,0,0,0,0}
Local aCODPRES	:= IIf(Empty(SuperGetMv("MV_CODPRES",,"")),{""},&(SuperGetMv("MV_CODPRES",,{""}))) //Códigos Presumido
Local cCDASAI	:= ""
//Local cCDADEV	:= ""
Local nA		:= 0
Local cSelect	:= ''
Local cFrom		:= ''
Local cWhere	:= ''
//Local cGroup	:= ''

Default aWizard := {}

//Quando parametros estiverem em branco finaliza processo.
IF Empty(aCODPRES[1])
	Return aValor
Endif

//Monta váriavel para selecionar os códigos lançamento validos
For nA:=1 To Len(aCODPRES)
	cCDASAI += aCODPRES[nA] + IIf(nA<Len(aCODPRES),"/","")	
Next
cCDASAI := "CDA.CDA_CODLAN IN " + FormatIn(cCDASAI,"/")


cSelect += "SUM(CASE WHEN SFT.FT_TIPO <> 'D'  THEN SFT.FT_BASEICM ELSE 0 END) BASESAIDA,"
cSelect += "SUM(CASE WHEN SFT.FT_TIPO <> 'D'  THEN SFT.FT_CRDPRES ELSE 0 END) CREDSAIDA,"
cSelect += "SUM(CASE WHEN SFT.FT_TIPO <> 'D'  THEN SFT.FT_VALICM ELSE 0  END) ICMSSAIDA,"
cSelect += "SUM(CASE WHEN SFT.FT_TIPO  = 'D'  THEN SFT.FT_BASEICM ELSE 0 END) BASEDEV,"
cSelect += "SUM(CASE WHEN SFT.FT_TIPO  = 'D'  THEN SFT.FT_VALICM ELSE 0  END) ICMSDEV,"
cSelect += "SUM(CASE WHEN SFT.FT_TIPO  = 'D'  THEN SFT.FT_CRDPRES ELSE 0 END) CREDDEV,"
cSelect += "SUM(CASE WHEN SFT.FT_TIPO  = 'D'  AND SFT2.FT_ENTRADA BETWEEN '" + DTOS(dDtIni) +"' AND '" + DTOS(dDtFim) +"' THEN SFT.FT_CRDPRES ELSE 0 END) CRDEVPER,"
cSelect += "SUM(CASE WHEN SFT.FT_TIPO  = 'D'  AND SFT2.FT_ENTRADA < '" + DTOS(dDtIni) +"' THEN SFT.FT_CRDPRES ELSE 0 END) CRDEVANT"


cFrom	+=	RetSqlName("SFT") + " SFT "
cFrom	+=	"LEFT JOIN " + RetSqlName("CDA") + " CDA ON (CDA.CDA_FILIAL='"  + xFilial("CDA") + "' AND CDA.CDA_TPMOVI = 'S' AND CDA.CDA_ESPECI = SFT.FT_ESPECIE AND SFT.FT_NFISCAL=CDA.CDA_NUMERO AND SFT.FT_SERIE=CDA.CDA_SERIE AND  "
cFrom	+=	"SFT.FT_CLIEFOR=CDA.CDA_CLIFOR AND SFT.FT_LOJA=CDA.CDA_LOJA AND SFT.FT_ITEM=CDA.CDA_NUMITE AND CDA.D_E_L_E_T_='') "
cFrom	+=	"LEFT JOIN " + RetSqlName("SFT") + " SFT2 ON ( SFT2.FT_FILIAL = '" + xFilial("SFT") + "' AND SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_NFISCAL = SFT.FT_NFORI  AND SFT2.FT_SERIE = SFT.FT_SERORI AND SFT2.FT_ITEM = SFT.FT_ITEMORI AND SFT2.D_E_L_E_T_ = '') "


cWhere	+= "SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND "
cWhere	+= "((SFT.FT_TIPOMOV = 'S' AND "+cCDASAI+") OR ( SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO = 'D' ) ) AND "
cWhere	+= "SFT.FT_ENTRADA BETWEEN '" + DTOS(dDtIni) + "' AND '" + DTOS(dDtFim) +"' AND "
cWhere	+= "SFT.FT_CRDPRES > 0 AND "
cWhere	+= "SFT.FT_DTCANC = '' AND "
cWhere	+= "SFT.D_E_L_E_T_ = '' "


//Monta variaveis para executar a query
cSelect	:= "%" + cSelect + "%"
cFrom	:= "%" + cFrom	+ "%"
cWhere	:= "%" + cWhere	+ "%"

BeginSql Alias cAlias

	SELECT %Exp:cSelect%
	FROM   %Exp:cFrom% 
	WHERE  %Exp:cWhere%
	
EndSql


DbSelectArea (cAlias)
aValor[1]	:=	(cAlias)->BASESAIDA		// Base ICMS Saída
aValor[2]	:=	(cAlias)->CREDSAIDA  	// Credito presumido Saída
aValor[3]	:=	(cAlias)->ICMSSAIDA  	// Valor ICMS Saída
aValor[4]	:=	(cAlias)->ICMSDEV  		// Valor ICMS Devolução de venda
aValor[5]	:=	(cAlias)->CREDDEV 		// Credito presumido Devolução de venda


aValor[6]	:=	(cAlias)->(ICMSSAIDA - CREDSAIDA) 	// VALOR ICMS - CREDITO PRESUMIDO
aValor[7]	:=	(cAlias)->(ICMSDEV - CREDDEV) 		// CALCULO DEVOLUÇÃO

aValor[8]	:=	(cAlias)->(ICMSSAIDA + CREDDEV) 	// Total Saídas com credito presumido + credito da entrada
aValor[9]	:=	(cAlias)->(CREDSAIDA + CREDDEV) 	// Total credito presumido Saída + credito da entrada
aValor[10]	:=	IIF(aValor[6] - aValor[7] > 0, aValor[6] - aValor[7], 0)    // Valor debito - credito

aValor[11]	:=	(cAlias)->CRDEVPER					// Valor credito presumido de devolução no periodo
aValor[12]	:=	(cAlias)->CRDEVANT					// Valor credito presumido de devolução fora do periodo


(cAlias)->(dbCloseArea())
RestArea(aArea)

Return aValor

Static Function CriaTemp(cAlias, cInd, aCmp, aArq)
Local cArq := CriaTrab (aCmp)

DbUseArea(.T., __LocalDriver, cArq, cAlias)
IndRegua(cAlias, cArq, cInd)
aAdd(aArq, {cAlias, cArq})

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ResumeISS
INFORMAÇÕES SOBRE ISS para compor registros de entrada e saída com especie SPED

Retorna valor contabil totalizados 

@author Rafael Santos
@since 14/08/2017
@version P11

/*/
//-------------------------------------------------------------------
Static Function ResumeISS(dDtIni,dDtFim,aFilsCalc,cNrLivro,cArqCFO)
local cQuery 	:= ""
Local cAliasSF3	:= ""
Local nTotEnt	:= 0
Local nTotSai	:= 0
Local aArea		:= GetArea()
Local aAreaSM0 	:= 	SM0->(GetArea())
Local nForFilial := 0
//Local cInscr	:= "" 
//Local cTipo		:= ""
Local lContrib	:= .T.

For nForFilial := 1 To Len( aFilsCalc )

	If !aFilsCalc[ nForFilial, 1 ]
		Loop
	EndIf

	SM0->(dbSeek(cEmpAnt+aFilsCalc[nForFilial][2]))
	If SM0->M0_ESTENT <> 'SC'
		Loop
	EndIf

	cFilAnt 	:= SM0->M0_CODFIL
	
	

	//F3_FILIAL, F3_ENTRADA, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, F3_CFO, F3_ALIQICM, R_E_C_N_O_, D_E_L_E_T_
	cQuery	:= ""
	If cNrLivro <> "*"
		cQuery := "F3_NRLIVRO = '" + cNrLivro + "' AND "
	Endif
	//If !Empty(cUF)
	cQuery += "	F3_ENTRADA BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFim)+"' AND "
	cQuery += " SF3.F3_ESPECIE = 'SPED' AND " // quando bloco B entrar no SPED este esta validação deve ser removida
	cQuery += "F3_CODISS <> '" + Space(TamSx3('F3_CODISS')[1]) + "' AND  F3_TIPO = 'S' AND SF3.F3_DTCANC = '" + Space(TamSx3('F3_DTCANC')[1]) + "' "

	

	cQuery := "%" + cQuery + "%"

	cAliasSF3	:= GetNextAlias()   

	BeginSql Alias cAliasSF3
		COLUMN F3_ENTRADA 	AS DATE
		COLUMN F3_EMISSAO 	AS DATE
		COLUMN F3_DTLANC 	AS DATE
		COLUMN F3_DTCANC 	AS DATE
		COLUMN F3_EMINFE 	AS DATE
		
		SELECT F3_FILIAL, F3_CFO, F3_VALCONT, F3_BASEICM, F3_VALICM, F3_ISENICM, F3_OUTRICM, F3_BASERET, F3_ICMSRET, F3_ICMSCOM,F3_ESTADO,;
		 F3_CODISS,F3_CLIEFOR,F3_LOJA, F3_TIPO
		
		
		FROM %table:SF3% SF3								
		WHERE SF3.F3_FILIAL = %xFilial:SF3%
			AND %Exp:cQuery%
			AND SF3.%NotDel%

		ORDER BY F3_ESTADO, F3_CFO
	EndSql

	dbSelectArea(cAliasSF3)
	dbSelectArea(cArqCFO)
	If cArqCFO = "EST"
		While (cAliasSF3)->(!Eof())
			SA2->(DbSeek(aFilsCalc[nForFilial][2]+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			SA1->(DbSeek(aFilsCalc[nForFilial][2]+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))						 
			            //FNaoContri(cAliasSF3, lBuscaA1A2, lDimeSC, lCfopAnt)
			lContrib := !(FNaoContri(cAliasSF3, .T.       , .T.    , .F.)) //Verificacao - Contribuinte ou nao
			//Adiciona no arquivo notas encontradas
			If (cArqCFO)->(MsSeek((cAliasSF3)->F3_ESTADO+ Iif(SubStr((cAliasSF3)->F3_CFO , 1 , 1 ) < "5","E","S" )) )  
				Reclock((cArqCFO),.F.)
			Else
				Reclock((cArqCFO),.T.)
			Endif	
				(cArqCFO)-> UF 	:= (cAliasSF3)->F3_ESTADO
				(cArqCFO)-> CFOP 	:= Iif(SubStr((cAliasSF3)->F3_CFO , 1 , 1 ) < "5","E","S" )
				(cArqCFO)-> ICMSRET += (cAliasSF3)->F3_ICMSRET
				(cArqCFO)-> ISENICM	+= (cAliasSF3)->F3_ISENICM
				(cArqCFO)-> OUTRICM += Iif(!Empty((cAliasSF3)->F3_CODISS) ,(cAliasSF3)->F3_VALCONT,(cAliasSF3)->F3_OUTRICM)
				(cArqCFO)->VALCONNC += Iif(lContrib,0,(cAliasSF3)->F3_VALCONT)    // NÃO CONTRIBUINTE
				(cArqCFO)->BASEICNC += Iif(lContrib,0, Iif(!Empty((cAliasSF3)->F3_CODISS) ,0,(cAliasSF3)->F3_BASEICM))  // NÃO CONTRIBUINTE
				(cArqCFO)->VALCONC	+= Iif(lContrib,(cAliasSF3)->F3_VALCONT,0)   // CONTRIBUINTE
				(cArqCFO)->BASEICC	+= Iif(lContrib,Iif(!Empty((cAliasSF3)->F3_CODISS) ,0,(cAliasSF3)->F3_BASEICM),0)   // CONTRIBUINTE
			MsUnLock()
			(cAliasSF3)->(dbSkip())
		Enddo
	Else
		While (cAliasSF3)->(!Eof())
			//Adiciona no arquivo notas encontradas
			If (cArqCFO)->(MsSeek((cAliasSF3)->F3_CFO))
				Reclock((cArqCFO),.F.)
			Else
				Reclock((cArqCFO),.T.)
			Endif	
				(cArqCFO)-> CFOP 	:= (cAliasSF3)->F3_CFO
				(cArqCFO)-> VALCONT += (cAliasSF3)->F3_VALCONT
				(cArqCFO)-> BASEICM += Iif(!Empty((cAliasSF3)->F3_CODISS), 0 , (cAliasSF3)->F3_BASEICM)
				(cArqCFO)-> VALICM	+= Iif(!Empty((cAliasSF3)->F3_CODISS), 0 , (cAliasSF3)->F3_VALICM)
				(cArqCFO)-> ISENICM	+= (cAliasSF3)->F3_ISENICM
				(cArqCFO)-> OUTRICM += Iif(!Empty((cAliasSF3)->F3_CODISS), (cAliasSF3)->F3_VALCONT , (cAliasSF3)->F3_OUTRICM)
				(cArqCFO)-> BASERET += (cAliasSF3)->F3_BASERET
				(cArqCFO)-> ICMSRET += (cAliasSF3)->F3_ICMSRET
				(cArqCFO)-> ICMSCOM += (cAliasSF3)->F3_ICMSCOM
			MsUnLock()

			If !Empty((cAliasSF3)->F3_CODISS) .And. !(Alltrim((cAliasSF3)->F3_CFO) $ "1933/2933/5933/6933")
				If (SubStr((cAliasSF3)->F3_CFO , 1 , 1 ) < "5")  
					nTotEnt += (cAliasSF3)->F3_VALICM
				Else
					nTotSai += (cAliasSF3)->F3_VALICM
				Endif
			Endif

			(cAliasSF3)->(dbSkip())
		Enddo
	Endif
	//Fecha a area de trabalho da cAliasSF3
	(cAliasSF3)->( dbCloseArea() )
Next

RestArea(aArea)
RestArea(aAreaSM0)
cFilAnt := SM0->M0_CODFIL

Return {nTotEnt,nTotSai}
//-------------------------------------------------------------------


//-------------------------------------------------------------------
/*/{Protheus.doc} RessarcIcm
Informações sobre ressarcimento de icms, quadros 32 - Registro 115 

@author Matheus Massarotto
@since 22/04/2020
@version P12

/*/
//-------------------------------------------------------------------
Static Function RessarcIcm(dDtIni,dDtFim)

Local aArea  	:= GetArea()
Local cAlias 	:= GetNextAlias()
Local aValor	:= {0}
Local cSelect	:= ''
Local cFrom		:= ''
Local cWhere	:= ''

cSelect += "SUM(SFT.FT_VALCONT) VALCONT "

cFrom	+=	RetSqlName("SFT") + " SFT "
cFrom	+=	"JOIN " + RetSqlName("CDA") + " CDA ON (CDA.CDA_FILIAL='"  + xFilial("CDA") + "' AND CDA.CDA_ESPECI = SFT.FT_ESPECIE AND SFT.FT_NFISCAL=CDA.CDA_NUMERO AND SFT.FT_SERIE=CDA.CDA_SERIE AND  "
cFrom	+=	"SFT.FT_CLIEFOR=CDA.CDA_CLIFOR AND SFT.FT_LOJA=CDA.CDA_LOJA AND SFT.FT_ITEM=CDA.CDA_NUMITE AND CDA.D_E_L_E_T_='') "
cFrom	+=	"AND CDA.CDA_TPMOVI = 'E' "

cWhere	+= "SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND "
cWhere	+= "SFT.FT_TIPOMOV = 'E' AND "
cWhere	+= "SFT.FT_ENTRADA BETWEEN '" + DTOS(dDtIni) + "' AND '" + DTOS(dDtFim) +"' AND "
cWhere	+= "SFT.FT_DTCANC = '' AND "
cWhere	+= "SFT.FT_CFOP IN "+ FormatIn(cCfopRess,"/") +" AND "
cWhere	+= "SFT.D_E_L_E_T_ = '' "
cWhere	+= "AND CDA.CDA_CODLAN IN " + FormatIn(cCodLanRess,"/")

//Monta variaveis para executar a query
cSelect	:= "%" + cSelect + "%"
cFrom	:= "%" + cFrom	+ "%"
cWhere	:= "%" + cWhere	+ "%"

BeginSql Alias cAlias

	SELECT %Exp:cSelect%
	FROM   %Exp:cFrom% 
	WHERE  %Exp:cWhere%
	
EndSql

DbSelectArea (cAlias)
aValor[1]	:=	(cAlias)->VALCONT		// Valor contábil das notas

(cAlias)->(dbCloseArea())

RestArea(aArea)

Return aValor


//-------------------------------------------------------------------
/*/{Protheus.doc} RessarcIcm
Informações sobre Autorização para Utilização de Crédito (AUC) ou Ordem de Transferência de Crédito (OTC), quadro 46

@author Matheus Massarotto
@since 23/04/2020
@version P12

/*/
//-------------------------------------------------------------------
Static Function AUCOTCIcm(dDtIni,dDtFim)

Local aArea  	:= GetArea()
Local cAlias 	:= GetNextAlias()
Local aDados	:= {}
Local cSelect	:= ''
Local cFrom		:= ''
Local cWhere	:= ''
Local nTamPos1	:= 15 //De acorod com o layout  |04	Identificação 	Identificação do Regime ou da Autorização Especial	15	008/022	N
Local cSGBD     := TCGetDB()

Local cImp	:= "IC"
Local nOrig	:= 3 //De acordo com a portaria http://legislacao.sef.sc.gov.br/html/portarias/2019/port_19_007.htm
/*
	(3) para Autorização Gerada a Partir do "Sistema de Apuração e Controle dos 
	Créditos de Ressarcimento e Restituição do ICMS Retido por Substituição Tributária. 
	O lançamento do crédito na DIME somente deve ser efetuado a partir do mês em que for 
	disponibilizada a AUC de crédito a ressarcir ou restituir na Internet, por meio da página 
	oficial da Secretaria de Estado da Fazenda. Transportar o somatório dos valores com esta origem para
	 o item 070 (Créditos Recebidos por Transferência de Outros Contribuintes) do Quadro 09 - Cálculo do 
	 Imposto a Pagar ou Saldo Credor. ” (NR
*/

cSelect += " CDH_PROCES,CDH_VALOR,CDH_TPLANC "

cFrom	+= RetSqlName("CDH")+ " A "
cFrom	+= " JOIN "+RetSqlName("CCF")+" CCF ON CCF.CCF_FILIAL='" + xFilial("CCF") + "' AND  CCF.CCF_NUMERO=A.CDH_PROCES AND CCF.CCF_TIPO=A.CDH_PROCTP AND CCF.CCF_INDAUT=A.CDH_PROIND AND CCF.CCF_IDITEM=A.CDH_ITPROC AND CCF.D_E_L_E_T_='' "

cWhere	+= " A.D_E_L_E_T_='' "
cWhere	+= " AND A.CDH_FILIAL='" + xFilial("CDH") + "' "
cWhere	+= " AND A.CDH_DTINI='"+DTOS(dDtIni)+"' "
//cWhere	+= " AND A.CDH_DTFIM='"+DTOS(dDtFim)+"' " //Baseado na query SPEDXFUN nao usa 
cWhere	+= " AND A.CDH_TIPOIP='"+cImp+"' "
cWhere	+= " AND A.CDH_CODLAN IN " + FormatIn(cCodLanRess,"/")
cWhere	+= " AND A.CDH_SEQUEN=(SELECT MAX(B.CDH_SEQUEN) FROM "+RetSqlName("CDH")+" B WHERE B.CDH_FILIAL=A.CDH_FILIAL AND B.CDH_TIPOIP=A.CDH_TIPOIP AND B.CDH_TIPOPR=A.CDH_TIPOPR AND B.CDH_PERIOD=A.CDH_PERIOD AND B.CDH_DTINI=A.CDH_DTINI AND B.CDH_LIVRO=A.CDH_LIVRO AND B.D_E_L_E_T_='') "
If cSGBD $ 'ORACLE/POSTGRES/DB2'
cWhere  += " AND A.CDH_PROCES||A.CDH_PROCTP||A.CDH_PROIND||A.CDH_ITPROC<>'' "
Else
cWhere	+= " AND A.CDH_PROCES+A.CDH_PROCTP+A.CDH_PROIND+A.CDH_ITPROC<>'' "
Endif

//Monta variaveis para executar a query
cSelect	:= "%" + cSelect + "%"
cFrom	:= "%" + cFrom	+ "%"
cWhere	:= "%" + cWhere	+ "%"

BeginSql Alias cAlias

	SELECT %Exp:cSelect%
	FROM   %Exp:cFrom% 
	WHERE  %Exp:cWhere%
	
EndSql


DbSelectArea (cAlias)
While (cAlias)->(!EOF())
	
	AADD(aDados,{"",0,0,""})

	aDados[len(aDados)][1]	:=	StrZero(val((cAlias)->CDH_PROCES),nTamPos1)	// Identificação do Regime ou da Autorização Especial
	aDados[len(aDados)][2]	:=	(cAlias)->CDH_VALOR		// Valor do crédito utilizado na apuração
	aDados[len(aDados)][3]	:=	nOrig					// Informar a Origem do lançamento, de acordo com o manual http://www.sef.sc.gov.br/servicos/servico/41/DIME_-_Declara%C3%A7%C3%A3o_do_ICMS_e_do_Mov._Econ%C3%B4mico, item 3.2.18. Quadro 46 
	aDados[len(aDados)][4]	:=	LEFT((cAlias)->CDH_TPLANC,1) // Tipo de lançamento M - Manual, A- Automatica		

	(cAlias)->(DbSkip())

EndDo

if empty(aDados) //Para garantir que sempre retorna a estrutura com 1 linha e 2 colunas
	AADD(aDados,{"",0,0,""})
endif

(cAlias)->(dbCloseArea())
RestArea(aArea)

Return(aDados)
