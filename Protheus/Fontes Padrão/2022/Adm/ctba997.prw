#Include "Ctba997.Ch"
#Include "PROTHEUS.Ch"
#Define CRLF CHR(13)+CHR(10)


// 17/08/2009 -- Filial com mais de 2 caracteres

// TRADUÇÃO RELEASE P10 1.2 - 21/07/08
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Ctba997  ³ Autor ³ Marcos S. Lobo        ³ Data ³ 08.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao de arquivos p/ importação no SINCO Contabeis.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba997(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB/SIGAFIS                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba997()
Local aSays		:={}
Local aButtons	:={}
Local nOpca 	:= 0
Local lParsOk	:= .F.
Local lCancel	:= .F.
Local cStartPath := ""

Private cCadastro := STR0001 //"Arquivos SINCO Contabeis"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros             ³
//³ mv_par01 // Data Inicial						 ³
//³ mv_par02 // Data Final                           ³
//³ mv_par03 // Moeda / CTO                          ³
//³ mv_par04 // Tipo de Saldo                        ³
//³ mv_par05 // Gera Cadastros ?                     ³
//³ mv_par06 // Gera Lancamentos ?                   ³
//³ mv_par07 // Gera Saldos ?  		                 ³
//³ mv_par08 // Diretorio para Geração ?             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("CTB997",.F.)

AADD(aSays,STR0002 ) //"Este programa faz a geracao dos arquivos para "
AADD(aSays,STR0003 ) //"importacao no sistema SINCO Contabeis."

AADD(aButtons, { 5,.T.,{|| Pergunte("CTB997",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CTBOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	If CTT->(FieldPos("CTT_CSINCO")) == 0 .and. mv_par09 == 3
   		MsgInfo(STR0004+CHR(13)+STR0005+CHR(13)+STR0006,STR0007)///"Verifique a existência do campo CTT_CSINCO (Char 1), "#"com opcoes: 0=C.Custo/Producao;1=C.Despesa"#"Classifique os Centros de Custo no cadastro#"Campo CTT_CSINCO não encontrado no CTT."
		Return
	Endif
	While !lParsOk				
		If Empty(mv_par01) .or. Empty(mv_par02)
			MsgInfo(STR0008,STR0009)///"Preencha as datas !"#"Data em branco."
		Else
			lParsOk := .T.		
		EndIf
		If !lParsOk
			If !Pergunte("CTB997",.T.)
				lCancel := .T.
				Exit
			EndIf
		EndIf
	EndDo
	If !lCancel						/// SE NÃO CANCELOU A TELA DE PERGUNTAS...
		lParsOk := .F.
		While !lParsOk				
			If Empty(mv_par08)
				cStartPath := GetSrvProfString("Startpath","")
				If MsgYesNo(STR0010+cStartPath+" ?",STR0011)///"Utiliza diretorio "#"Diretorio em branco."
					mv_par08 := cStartPath
					lParsOk := .T.
				Else
					mv_par08 := cGetFile("\", STR0016,,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY/*128+GETF_NETWORKDRIVE*/)//"Selecione o Diretorio p/ Gerar os Arquivos"
					If Empty(mv_par08)
						lParsOk := .F.			
					Else
						If MsgYesNo(STR0012+CHR(13)+mv_par08+CHR(13)+STR0021)
							lParsOk := .T.			
						Else
							lParsOk := .F.			
						EndIf
					EndIf
				Endif
			Else
				lParsOk := .T.
			EndIf
			If !lParsOk
				If !Pergunte("CTB997",.T.)
					lCancel := .T.
					Exit
				EndIf
			EndIf
		EndDo
		If !Right(mv_par08,1) $ "\/"
			mv_par08 := ALLTRIM(mv_par08)+"\"
		EndIf
	EndIf
	mv_par08 := ALLTRIM(mv_par08)
	If !lCancel				/// SE NÃO CANCELOU A TELA DE PERGUNTAS...
		If mv_par10 == 1
			Processa({|| Ctb997Lay1(mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,mv_par09)} , "Gerando arquivos SINCO - Contabeis...")
		Else
			Processa({|| Ctb997Lay2(mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,mv_par09)} , "Gerando arquivos SINCO - Contabeis...")		
		EndIf
	EndIf
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Ctb997Lay1³ Autor ³ Marcos S. Lobo        ³ Data ³ 08.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Process. geração dos arquivos SINCO Contabeis PORT COFIS	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb997Lay1()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA997                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 dDtIni	 - Data Inicial para geração dos arquivos.		  ³±±
±±³          ³ 2 dDtFim	 - Data Final para geração dos arquivos.		  ³±±
±±³          ³ 3 cMoeda  - Moeda para a geração dos arquivos      		  ³±±
±±³          ³ 4 cTpSald - Tipo de Saldo para a geração dos arquivos	  ³±±
±±³          ³ 5 cPlan	 - Geração dos cadastros (1=Gera / 2=Não Gera)	  ³±±
±±³          ³ 6 cLanc	 - Geração dos lancamentos  (1=Gera / 2=Não Gera) ³±±
±±³          ³ 7 cSald	 - Geração dos saldos  (1=Gera / 2=Não Gera)	  ³±±
±±³          ³ 8 cDir	 - Diretorio para a geração dos arquivosNenhum	  ³±±
±±³          ³ 9 nCusto	 - Trata C.Custo 1=Custo/2=Despes/3=Cadastro/4=Nao³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb997Lay1(dDtIni,dDtFim,cMoeda,cTpSald,cPlan,cLanc,cSald,cDir,nCusto)

Local nHdl
Local nArq2Ger 		:= 1
Local aSaldo		:= {}
Local aSldAnt		:= {}
Local nSaldo
Local aPlanArqs := {}
Local aLancArqs := {}
Local aSaldArqs := {}
Local nPart := 2
Local cFilCT2	:= ""
Local cFilCT1	:= ""
Local cFilCT8	:= ""
Local cFilCTT	:= ""
Local cValor	:= ""
Local nMovDeb	:= 0
Local nMovCrd	:= 0
Local lGravou 	:= .F.
Local nDC		:= 1

DEFAULT dDtIni	:= FirstDay(dDataBase)									/// Data Inicial para geração dos arquivos
DEFAULT dDtFim	:= LastDay(CTOD("01/12/"+STRZERO(YEAR(dDataBase),4)))	/// Data Final para geração dos arquivos
DEFAULT cMoeda  := "01"													/// Moeda a ser considerada para a geração dos arquivos
DEFAULT cTpSald := "1"													/// Tipo de Saldo a considerado para a geração dos arquivos
DEFAULT cPlan	:= "11111"												/// Flags para a geração dos cadastros
DEFAULT cLanc	:= "11"													/// Flags para a geração dos lancamentos
DEFAULT cSald	:= "11"													/// Flags para a geração dos saldos
DEFAULT cDir	:= ""													/// Diretorio para a geração dos arquivos
DEFAULT nCusto	:= 4													/// Tratamento para a coluna do C.Custo (DEFAULT NAO GERA)

If Empty(cMoeda) 
	cMoeda := "01"
EndIf

If Empty(cTpSald)
	cTpSald := "1"
EndIf

cPlan := ALLTRIM(cPlan)
cLanc := ALLTRIM(cLanc)
cSald := ALLTRIM(cSald)

aAdd(aPlanArqs,{cDir+"CONTAS.TXT"	,0})
aAdd(aPlanArqs,{cDir+"CONTASDA.TXT"	,0})
aAdd(aPlanArqs,{cDir+"CCUSTOS.TXT"	,0})
aAdd(aPlanArqs,{cDir+"CDESPESA.TXT" ,0})
aAdd(aPlanArqs,{cDir+"HISTORIC.TXT"	,0})

For nArq2Ger := 1 to Len(aPlanArqs)
	If Substr(cPlan,nArq2Ger,1) == "1"
		IF File(aPlanArqs[nArq2Ger][1])
			IF !MsgYesNo( STR0013 + aPlanArqs[nArq2Ger][1] + "?" , STR0014 ) //"Sobregravar "###"Arquivo já existe!"
				For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aPlanArqs[nArq2Ger][2])
					EndIf
				Next
				Return
			Endif
		Endif
		nHdl := fCreate(aPlanArqs[nArq2Ger][1])
		If nHdl == -1
			For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aPlanArqs[nArq2Ger][2])
				EndIf
			Next
			ApMsgAlert(STR0015 + Str(fError(),2)) //"Erro na criação do arquivo - ERRO Nº "
			Return
		Else
			aPlanArqs[nArq2Ger][2] := nHdl
		EndIf
	EndIf
Next

aAdd(aLancArqs,{cDir+"LANCTOS.TXT"	,0})
aAdd(aLancArqs,{cDir+"LANCTSDA.TXT"	,0})
For nArq2Ger := 1 to Len(aLancArqs)
	If Substr(cLanc,nArq2Ger,1) == "1"
		IF File(aLancArqs[nArq2Ger][1])
			IF !MsgYesNo( STR0013 + aLancArqs[nArq2Ger][1] + "?" , STR0014 ) //"Sobregravar "###"Arquivo já existe!"
				For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aPlanArqs[nArq2Ger][2])
					EndIf
				Next
				For nArq2Ger := 1 to Len(aLancArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aLancArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aLancArqs[nArq2Ger][2])
					EndIf
				Next
				Return
			Endif
		Endif
		nHdl := fCreate(aLancArqs[nArq2Ger][1])
		If nHdl == -1
			For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aPlanArqs[nArq2Ger][2])
				EndIf
			Next
			For nArq2Ger := 1 to Len(aLancArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aLancArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aLancArqs[nArq2Ger][2])
				EndIf
			Next
			ApMsgAlert(STR0015 + Str(fError(),2)) //"Erro na criação do arquivo - ERRO Nº "
			Return
		Else
			aLancArqs[nArq2Ger][2] := nHdl
		EndIf
	EndIf
Next

aAdd(aSaldArqs,{cDir+"SALDOS.TXT"	,0})
aAdd(aSaldArqs,{cDir+"SALDOSDA.TXT"	,0})
For nArq2Ger := 1 to Len(aSaldArqs)
	If Substr(cSald,nArq2Ger,1) == "1"
		IF File(aSaldArqs[nArq2Ger][1])
			IF !MsgYesNo( STR0013 + aSaldArqs[nArq2Ger][1] + "?" , STR0014 ) //"Sobregravar "###"Arquivo já existe!"
				For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aPlanArqs[nArq2Ger][2])
					EndIf
				Next
				For nArq2Ger := 1 to Len(aLancArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aLancArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aLancArqs[nArq2Ger][2])
					EndIf
				Next
				For nArq2Ger := 1 to Len(aSaldArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aSaldArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aSaldArqs[nArq2Ger][2])
					EndIf
				Next
				Return
			Endif
		Endif
		nHdl := fCreate(aSaldArqs[nArq2Ger][1])
		If nHdl == -1
			For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aPlanArqs[nArq2Ger][2])
				EndIf
			Next
			For nArq2Ger := 1 to Len(aLancArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aLancArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aLancArqs[nArq2Ger][2])
				EndIf
			Next
			For nArq2Ger := 1 to Len(aSaldArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aSaldArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aSaldArqs[nArq2Ger][2])
				EndIf
			Next
			ApMsgAlert(STR0015 + Str(fError(),2)) //"Erro na criação do arquivo - ERRO Nº "
			Return
		Else
			aSaldArqs[nArq2Ger][2] := nHdl
		EndIf
	EndIf
Next

If aSaldArqs[1][2] > 0 .or. aSaldArqs[2][2] > 0 .or. aPlanArqs[1][2] > 0 .or. aPlanArqs[2][2] > 0
	DbSelectArea("CT1")
	cFilCT1 := xFilial("CT1")
	dbSetOrder(1)												//// ORDENADO PELA CLASSE DA CONTA
	ProcRegua(RecCount())
	MsSeek(cFilCT1,.T.)										//// LOCALIZA A PRIMEIRA ANALITICA
	While CT1->(!Eof()) .and. CT1->CT1_FILIAL == cFilCT1 
		IncProc(STR0017+ALLTRIM(CT1->CT1_CONTA))///"Gerando Plano/Saldos da conta: "

		/// GRAVA A CONTA SINTETICA NO PLANO DE CONTAS DO DIARIO GERAL (CADASTRO)
		If aPlanArqs[1][2] > 0 .and. CT1->CT1_CLASSE == "1"
			cCampo := STRZERO(DAY(CT1->CT1_DTEXIS),2)+STRZERO(MONTH(CT1->CT1_DTEXIS),2)+STRZERO(YEAR(CT1->CT1_DTEXIS),4)			/// DATA DE INICIO DE EXISTENCIA DA CONTA
			cCampo += "001"										/// CODIGO DA TABELA
			cCampo += PADR(CT1->CT1_CONTA,28)					/// CODIGO DA CONTA CONTABIL
			cCampo += PADR(CT1->CT1_DESC01,45)					/// DESCRICAO DA CONTA
			If aPlanArqs[1][2] > 0
				fWrite(aPlanArqs[1][2],cCampo+CRLF)	
			EndIf
		EndIf
        
        If CT1->CT1_CLASSE <> "2"				/// CONTAS SINTETICAS VÃO SOMENTE NO ARQ. PLANO DE CONTAS DO DIARIO GERAL
        	CT1->(dbSkip())
        	Loop
        EndIf
        
		//// VALIDA PELAS DATA INICIAIS E FINAIS SE HOUVE MOVIMENTAÇÃO NO PERIODO
		aSldAnt := SaldoCT7(CT1->CT1_CONTA,dDtIni-1,cMoeda,cTpSald)
		aSaldo  := SaldoCT7(CT1->CT1_CONTA,dDtFim,cMoeda,cTpSald)
		nSaldo  := aSaldo[1] - aSldAnt[1]
		nMovDeb := aSaldo[4] - aSldAnt[4]
		nMovCrd := aSaldo[5] - aSldAnt[5]
		
		If nSaldo == 0 .and. aSaldo[1] == 0 .and. nMovDeb == 0 .and. nMovCrd == 0 	//// SE NÃO HOUVE MOVIMENTO E NÃO TEM SALDO NA CONTA
			dbSelectArea("CT1")
			CT1->(dbSkip())										/// PASSA PARA O PROXIMO
			Loop
		EndIf

		If aPlanArqs[1][2] > 0 .or. aPlanArqs[2][2] > 0
			/// SE TEM MOVIMENTO NO PERIODO GERA A CONTA CONTABIL (CADASTRO)
			cCampo := STRZERO(DAY(CT1->CT1_DTEXIS),2)+STRZERO(MONTH(CT1->CT1_DTEXIS),2)+STRZERO(YEAR(CT1->CT1_DTEXIS),4)			/// DATA DE INICIO DE EXISTENCIA DA CONTA
			cCampo += "001"										/// CODIGO DA TABELA
			cCampo += PADR(CT1->CT1_CONTA,28)					/// CODIGO DA CONTA CONTABIL
			cCampo += PADR(CT1->CT1_DESC01,45)					/// DESCRICAO DA CONTA
			If aPlanArqs[1][2] > 0
				fWrite(aPlanArqs[1][2],cCampo+CRLF)	
			EndIf		
			If aPlanArqs[2][2] > 0
				fWrite(aPlanArqs[2][2],cCampo+CRLF)	
			EndIf		
		EndIf
	                                
		If aSaldArqs[1][2] > 0 .or. aSaldArqs[2][2] > 0 
			/// EFETUA O CALCULO DE SALDO MES A MES PARA A GERAÇÃO NO ARQUIVO DE SALDOS
			dDataFAtu	:= LastDay(dDTini)
			nAnoFAtu	:= Year(dDataFAtu)
			nMesFAtu	:= Month(dDataFAtu)
			While dDataFAtu <= dDtFim
				dDataIAtu := FirstDay(dDataFAtu)
				aSldAnt := SaldoCT7(CT1->CT1_CONTA,dDataIAtu-1,cMoeda,cTpSald)
				aSaldo  := SaldoCT7(CT1->CT1_CONTA,dDataFAtu,cMoeda,cTpSald)
				nSaldo  := aSaldo[1] - aSldAnt[1]
				nMovDeb := aSaldo[4] - aSldAnt[4]
				nMovCrd := aSaldo[5] - aSldAnt[5]
	            
				cCampo := STRZERO(DAY(dDataIAtu),2)+STRZERO(MONTH(dDataIAtu),2)+STRZERO(YEAR(dDataIAtu),4)				/// USA A DATA DO PARAMETRO
				cCampo += PADR(CT1->CT1_CONTA,28)					/// CODIGO DA CONTA CONTABIL
				
				cValor := STRZERO(ABS(aSldAnt[1]),17,2)
				cValor := "0"+Left(cValor,14)+Right(cValor,2)				
				
				cCampo += cValor									/// SALDO INICIAL SEM SINAL E SEM VIRGULA 2 DECIMAIS
				If aSldAnt[1] > 0									/// SINAL RELATIVO AO SALDO INICIAL
					cCampo += "C"
				Else
					cCampo += "D"		
				EndIf
				
				cValor := STRZERO(ABS(nMovDeb),17,2)
				cValor := "0"+Left(cValor,14)+Right(cValor,2)		
				cCampo += cValor									/// MOVIMENTO À DEBITO
		
				cValor := STRZERO(ABS(nMovCrd),17,2)
				cValor := "0"+Left(cValor,14)+Right(cValor,2)		
				cCampo += cValor									/// MOVIMENTO À CREDITO
				
				cValor := STRZERO(ABS(aSaldo[1]),17,2)
				cValor := "0"+Left(cValor,14)+Right(cValor,2)		
				cCampo += cValor									/// SALDO FINAL SEM SINAL E SEM VIRGULA 2 DECIMAIS		
				If aSaldo[1] > 0									/// SINAL RELATIVO AO SALDO INICIAL
					cCampo += "C"
				Else
					cCampo += "D"		
				EndIf		                             
		
				If aSaldArqs[1][2] > 0
					fWrite(aSaldArqs[1][2],cCampo+CRLF)	
				EndIf		
				If aSaldArqs[2][2] > 0
					fWrite(aSaldArqs[2][2],cCampo+CRLF)	
				EndIf		
				
				/// INCREMENTA OS CONTADORES DE MES E ANO
				If nMesFAtu >= 12
					nMesFAtu := 1
					nAnoFAtu++
				Else
					nMesFAtu++
				EndIf		
				dDataFAtu := LASTDAY(CTOD("01/"+STRZERO(nMesFAtu,2)+"/"+STRZERO(nAnoFAtu,4)))
			EndDo
		EndIf

	    dbSelectArea("CT1")    	    
		DbSkip()
	EndDo
	If aPlanArqs[1][2] > 0
		FClose(aPlanArqs[1][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
	If aPlanArqs[2][2] > 0
		FClose(aPlanArqs[1][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
	If aSaldArqs[1][2] > 0
		FClose(aSaldArqs[1][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
	If aSaldArqs[2][2] > 0
		FClose(aSaldArqs[2][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
EndIf

If aPlanArqs[5][2] > 0
	dbSelectArea("CT8")
	cFilCT8 := xFilial("CT8")
	dbSetOrder(1)
	ProcRegua(RecCount())
	MsSeek(cFilCT8,.T.)
	While CT8->(!Eof()) .and. CT8->CT8_FILIAL = cFilCT8
		IncProc(STR0018+CT8->CT8_HIST)//"Gerando Historico Padrao: "
		cCampo := STRZERO(DAY(dDtIni),2)+STRZERO(MONTH(dDtIni),2)+STRZERO(YEAR(dDtIni),4)				/// USA A DATA DO PARAMETRO
		cCampo += "005"
		cCampo += PADR(CT8->CT8_HIST,28)
		cCampo += PADR(CT8->CT8_DESC,45)
		If aPlanArqs[5][2] > 0
			fWrite(aPlanArqs[5][2],cCampo+CRLF)	
		EndIf		
		If CT8->CT8_IDENT == "I"
			CT8->(dbSeek(cFilCT8+Soma1(CT8->CT8_HIST),.T.))
		Else
			dbSkip()
		EndIf
	EndDo
	If aPlanArqs[5][2] > 0
		FClose(aPlanArqs[5][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
EndIf			

dbSelectArea("CTT")
cFilCTT := xFilial("CTT")
If (aPlanArqs[3][2] > 0 .or. aPlanArqs[4][2] > 0 ) .and. nCusto <> 4
	dbSetOrder(2)
	ProcRegua(RecCount())
	dbSeek(cFilCTT+"2",.T.)
	While CTT->(!Eof()) .and. CTT->CTT_FILIAL == cFilCTT 
		IncProc(STR0019+CTT->CTT_CUSTO)
		cCampo := STRZERO(DAY(CTT->CTT_DTEXIS),2)+STRZERO(MONTH(CTT->CTT_DTEXIS),2)+STRZERO(YEAR(CTT->CTT_DTEXIS),4)			/// DATA DE INICIO DE EXISTENCIA DA CONTA
		cCampo += "003"										/// CODIGO DA TABELA
		cCampo += PADR(CTT->CTT_CUSTO,28)					/// CODIGO DA CONTA CONTABIL
		cCampo += PADR(CTT->CTT_DESC01,45)					/// DESCRICAO DA CONTA
		
		
		If nCusto == 3						/// SE FOR CLASS. C.CUSTO CONF. CADASTRO
			If CTT->CTT_CSINCO $ " 0"
				If aPlanArqs[3][2] > 0
					fWrite(aPlanArqs[3][2],cCampo+CRLF)	
				EndIf		
			Else
				If aPlanArqs[4][2] > 0
					cCampo := Left(cCampo,8)+"004"+Right(cCampo,73)
					fWrite(aPlanArqs[4][2],cCampo+CRLF)	
				EndIf					
			EndIf		
		ElseIf nCusto == 1					/// SE FOR GERAR COMO C.CUSTO / PRODUCAO
			If aPlanArqs[3][2] > 0
				fWrite(aPlanArqs[3][2],cCampo+CRLF)	
			EndIf		
		ElseIf nCusto == 2 					/// SE FOR GERAR COMO C.DE DESPESAS
			If aPlanArqs[4][2] > 0
				cCampo := Left(cCampo,8)+"004"+Right(cCampo,73)
				fWrite(aPlanArqs[4][2],cCampo+CRLF)	
			EndIf		
		EndIf
	
		dbSelectArea("CTT")
		dbSkip()
	EndDo			

	If aPlanArqs[3][2] > 0
		FClose(aPlanArqs[3][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
	If aPlanArqs[4][2] > 0
		FClose(aPlanArqs[4][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
EndIf

If aLancArqs[1][2] > 0 .or. aLancArqs[2][2] > 0
	dbSelectArea("CTT")
	dbSetOrder(1)
	cFilCT2 := xFilial("CT2")
	dbSelectArea("CT2")
	dbSetOrder(1)
	MsSeek(cFilCT2+DTOS(dDtIni),.T.)
	dDataProc := CT2->CT2_DATA
	ProcRegua(RecCount())
	IncProc(STR0020+DTOC(CT2->CT2_DATA))
	While CT2->(!Eof()) .and. CT2->CT2_FILIAL == cFilCT2 .and. CT2->CT2_DATA <= dDtFim
		If dDataProc <> CT2->CT2_DATA
			IncProc(STR0020+DTOC(CT2->CT2_DATA))
			dDataProc := CT2->CT2_DATA
		EndIf
		If CT2->CT2_MOEDLC <> cMoeda .or. CT2->CT2_TPSALD <> cTpSald .or. CT2->CT2_DC > "3" .or. CT2->CT2_VALOR == 0
			dbSkip()
			Loop
		EndIf
		nPart := 2
		For nDC := 1 to nPart
			cCampo := STRZERO(DAY(CT2->CT2_DATA),2)+STRZERO(MONTH(CT2->CT2_DATA),2)+STRZERO(YEAR(CT2->CT2_DATA),4)
			If CT2->CT2_DC == "1"
				nDC := 1
				nPart := 1
			ElseIf CT2->CT2_DC == "2"
				nDC := 2		
				nPart := 2
			EndIf
			
			If CT2->CT2_DC $ "13"
				If nDC == 1
					cCampo += PADR(CT2->CT2_DEBITO,28)				/// CONTA DO LANCAMENTO (A DEBITO) PARTIDA SIMPLES DEVEDORA
					cCusto := CT2->CT2_CCD
				Else
					cCampo += PADR(CT2->CT2_CREDIT,28)				/// CONTA DO LANCAMENTO (A DEBITO) PARTIDA-DOBRADA (2ª LINHA)				
					cCusto := CT2->CT2_CCC
				EndIf
			Else
				cCampo += PADR(CT2->CT2_CREDIT,28)					/// CONTA DO LANCAMENTO (A CREDITO) PARTIDA SIMPLES CREDORA
				cCusto := CT2->CT2_CCC
			EndIf
			cValor := STRZERO(ABS(CT2->CT2_VALOR),17,2)
			cValor := "0"+Left(cValor,14)+Right(cValor,2)
			cCampo += cValor										/// VALOR DO MOVIMENTO SEM SINAL E SEM VIRGULA 2 DECIMAIS
			
			IF CT2->CT2_DC $ "13"
				If nDC == 1
					cCampo += "D"
					cCampo += PADR(CT2->CT2_CREDIT,28)					/// CONTA DE CONTRA-PARTIDA (A CREDITO) PARTIDA SIMPLES DEVEDORA
				Else											
					cCampo += "C"
					cCampo += PADR(CT2->CT2_DEBITO,28)					/// CONTA DE CONTRA-PARTIDA (A DEBITO) PARTIDA-DOBRADA (2ª LINHA)						
				EndIf
			Else
				cCampo += "C"		
				cCampo += PADR(CT2->CT2_DEBITO,28)					/// CONTA DE CONTRA-PARTIDA (A DEBITO) - PARTIDA SIMPLES CREDORA
			EndIf
			cCampo += "   "										/// TIPO DE OPERAÇÃO (INDEFINIDO)
		
			If nCusto == 3				/// Se deve gerar conforme a class. no cadastro.
				CTT->(MsSeek(cFilCTT+cCusto,.T.))
				If CTT->CTT_CSINCO $ " 0"
					cCampo += PADR(cCusto,28)						/// CENTRO DE CUSTOS			
					cCampo += SPACE(28)								/// CENTRO DE DESPESAS
				Else
					cCampo += SPACE(28)								/// CENTRO DE CUSTOS
					cCampo += PADR(cCusto,28)						/// CENTRO DE DESPESAS
				EndIf
			ElseIf nCusto == 1			/// Se deve gerar como C.Custo/Producao
				cCampo += PADR(cCusto,28)						/// CENTRO DE CUSTOS
				cCampo += SPACE(28)									/// CENTRO DE DESPESAS
			ElseIf nCusto == 2			/// Se deve gerar como C.Despesas
				cCampo += SPACE(28)									/// CENTRO DE CUSTOS
				cCampo += PADR(cCusto,28)				/// CENTRO DE DESPESAS			
			Else
				cCampo += SPACE(56)						/// CENTRO DE CUSTOS e CENTRO DE DESPESAS EM BRANCO (NÃO GERA)
			EndIf
			
			cCampo += PADR(CT2->CT2_HP,4)						/// CODIGO DO HISTORICO PADRAO
			cCampo += PADR(CT2->CT2_HIST,45)					/// HISTORICO DO LANCAMENTO
			cCampo += PADR(CT2->(CT2_LOTE+CT2_DOC),12)			/// CHAVE PARA IDENTIFICAR O LANCAMENTO	(LOTE+DOCUMENTO)	
			If aLancArqs[1][2] > 0
				fWrite(aLancArqs[1][2],cCampo+CRLF)	
			EndIf		
			If aLancArqs[2][2] > 0
				fWrite(aLancArqs[2][2],cCampo+CRLF)	
			EndIf		
			
			If nPart == 2 .and. nDC == 2
				Exit
			ElseIf nPart == 1 .and. nDC == 1
				Exit
			EndIf			
		Next

		dbSelectArea("CT2")
		dbSkip()
	EndDo

	If aLancArqs[1][2] > 0
		FClose(aLancArqs[1][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
	If aLancArqs[2][2] > 0
		FClose(aLancArqs[1][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
EndIf

For nArq2Ger := 1 to Len(aPlanArqs)									 /// RODA O ARRAY DOS ARQUIVOS DE CADASTRO
	If aPlanArqs[nArq2Ger][2] > 0 .and. File(aPlanArqs[nArq2Ger][1]) /// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
		fClose(aPlanArqs[nArq2Ger][2])								 /// SE AINDA ESTIVEREM ABERTOS
	EndIf
Next
For nArq2Ger := 1 to Len(aLancArqs)									///  RODA O ARRAY DOS ARQUIVOS DE LANCAMENTO
	If aLancArqs[nArq2Ger][2] > 0 .and. File(aLancArqs[nArq2Ger][1])/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
		fClose(aLancArqs[nArq2Ger][2])								/// SE AINDA ESTIVEREM ABERTOS
	EndIf
Next
For nArq2Ger := 1 to Len(aSaldArqs)									/// RODA O ARRAY DOS ARQUIVOS DE SALDO
	If aSaldArqs[nArq2Ger][2] > 0 .and. File(aPlanArqs[nArq2Ger][1])/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
		fClose(aSaldArqs[nArq2Ger][2])								/// SE AINDA ESTIVEREM ABERTOS
	EndIf
Next

If lGravou 
	MsgInfo(STR0022+CHR(13)+mv_par08)
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Ctb997Lay2³ Autor ³ Marcos S. Lobo        ³ Data ³ 22.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Process. geração dos arquivos SINCO Contabeis PORT COFIS	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb997Lay2()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA997                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 dDtIni	 - Data Inicial para geração dos arquivos.		  ³±±
±±³          ³ 2 dDtFim	 - Data Final para geração dos arquivos.		  ³±±
±±³          ³ 3 cMoeda  - Moeda para a geração dos arquivos      		  ³±±
±±³          ³ 4 cTpSald - Tipo de Saldo para a geração dos arquivos	  ³±±
±±³          ³ 5 cPlan	 - Geração dos cadastros (1=Gera / 2=Não Gera)	  ³±±
±±³          ³ 6 cLanc	 - Geração dos lancamentos  (1=Gera / 2=Não Gera) ³±±
±±³          ³ 7 cSald	 - Geração dos saldos  (1=Gera / 2=Não Gera)	  ³±±
±±³          ³ 8 cDir	 - Diretorio para a geração dos arquivosNenhum	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb997Lay2(dDtIni,dDtFim,cMoeda,cTpSald,cPlan,cLanc,cSald,cDir,nCusto)

Local nHdl
Local nArq2Ger 		:= 1
Local aSaldo		:= {}
Local aSldAnt		:= {}
Local nSaldo
Local aPlanArqs := {}
Local aLancArqs := {}
Local aSaldArqs := {}
Local nPart := 2
Local cFilCT2	:= ""
Local cFilCT1	:= ""
Local cFilCTT	:= ""
Local nTamCTDB	:= 0
Local nTamCTCR	:= 0
Local nTamCT1	:= 0

Local cValor	:= ""
Local nMovDeb	:= 0
Local nMovCrd	:= 0
Local lGravou 	:= .F.

Local cHistorico:= ""
Local nRecCT2	:= 0
Local nOrdCT2	:= 1
Local cKeyCT2	:= ""
Local cEmpOri	:= ""
Local cFilOri	:= ""
Local cSeqLan	:= ""
Local nDC		:= 1

DEFAULT dDtIni	:= FirstDay(dDataBase)									/// Data Inicial para geração dos arquivos
DEFAULT dDtFim	:= LastDay(CTOD("01/12/"+STRZERO(YEAR(dDataBase),4)))	/// Data Final para geração dos arquivos
DEFAULT cMoeda  := "01"													/// Moeda a ser considerada para a geração dos arquivos
DEFAULT cTpSald := "1"													/// Tipo de Saldo a considerado para a geração dos arquivos
DEFAULT cPlan	:= "11111"												/// Flags para a geração dos cadastros
DEFAULT cLanc	:= "11"													/// Flags para a geração dos lancamentos
DEFAULT cSald	:= "11"													/// Flags para a geração dos saldos
DEFAULT cDir	:= ""													/// Diretorio para a geração dos arquivos
DEFAULT nCusto	:= 4													/// Tratamento para a coluna do C.Custo (DEFAULT NAO GERA)

If Empty(cMoeda) 
	cMoeda := "01"
EndIf

If Empty(cTpSald)
	cTpSald := "1"
EndIf

cPlan := ALLTRIM(cPlan)
cLanc := ALLTRIM(cLanc)
cSald := ALLTRIM(cSald)

aAdd(aPlanArqs,{cDir+"CONTAS.TXT"	,0})
aAdd(aPlanArqs,{cDir+"CONTASDA.TXT"	,0})
aAdd(aPlanArqs,{cDir+"CCUSTOS.TXT"	,0})
aAdd(aPlanArqs,{cDir+"CDESPESA.TXT" ,0})

For nArq2Ger := 1 to Len(aPlanArqs)
	If Substr(cPlan,nArq2Ger,1) == "1"
		IF File(aPlanArqs[nArq2Ger][1])
			IF !MsgYesNo( STR0013 + aPlanArqs[nArq2Ger][1] + "?" , STR0014 ) //"Sobregravar "###"Arquivo já existe!"
				For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aPlanArqs[nArq2Ger][2])
					EndIf
				Next
				Return
			Endif
		Endif
		nHdl := fCreate(aPlanArqs[nArq2Ger][1])
		If nHdl == -1
			For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aPlanArqs[nArq2Ger][2])
				EndIf
			Next
			ApMsgAlert(STR0015 + Str(fError(),2)) //"Erro na criação do arquivo - ERRO Nº "
			Return
		Else
			aPlanArqs[nArq2Ger][2] := nHdl
		EndIf
	EndIf
Next

aAdd(aLancArqs,{cDir+"LANCTOS.TXT"	,0})
aAdd(aLancArqs,{cDir+"LANCTSDA.TXT"	,0})
For nArq2Ger := 1 to Len(aLancArqs)
	If Substr(cLanc,nArq2Ger,1) == "1"
		IF File(aLancArqs[nArq2Ger][1])
			IF !MsgYesNo( STR0013 + aLancArqs[nArq2Ger][1] + "?" , STR0014 ) //"Sobregravar "###"Arquivo já existe!"
				For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aPlanArqs[nArq2Ger][2])
					EndIf
				Next
				For nArq2Ger := 1 to Len(aLancArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aLancArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aLancArqs[nArq2Ger][2])
					EndIf
				Next
				Return
			Endif
		Endif
		nHdl := fCreate(aLancArqs[nArq2Ger][1])
		If nHdl == -1
			For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aPlanArqs[nArq2Ger][2])
				EndIf
			Next
			For nArq2Ger := 1 to Len(aLancArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aLancArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aLancArqs[nArq2Ger][2])
				EndIf
			Next
			ApMsgAlert(STR0015 + Str(fError(),2)) //"Erro na criação do arquivo - ERRO Nº "
			Return
		Else
			aLancArqs[nArq2Ger][2] := nHdl
		EndIf
	EndIf
Next

aAdd(aSaldArqs,{cDir+"SALDOS.TXT"	,0})
aAdd(aSaldArqs,{cDir+"SALDOSDA.TXT"	,0})
For nArq2Ger := 1 to Len(aSaldArqs)
	If Substr(cSald,nArq2Ger,1) == "1"
		IF File(aSaldArqs[nArq2Ger][1])
			IF !MsgYesNo( STR0013 + aSaldArqs[nArq2Ger][1] + "?" , STR0014 ) //"Sobregravar "###"Arquivo já existe!"
				For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aPlanArqs[nArq2Ger][2])
					EndIf
				Next
				For nArq2Ger := 1 to Len(aLancArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aLancArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aLancArqs[nArq2Ger][2])
					EndIf
				Next
				For nArq2Ger := 1 to Len(aSaldArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
					If aSaldArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
						fClose(aSaldArqs[nArq2Ger][2])
					EndIf
				Next
				Return
			Endif
		Endif
		nHdl := fCreate(aSaldArqs[nArq2Ger][1])
		If nHdl == -1
			For nArq2Ger := 1 to Len(aPlanArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aPlanArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aPlanArqs[nArq2Ger][2])
				EndIf
			Next
			For nArq2Ger := 1 to Len(aLancArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aLancArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aLancArqs[nArq2Ger][2])
				EndIf
			Next
			For nArq2Ger := 1 to Len(aSaldArqs)					/// SE CANCELAR A SOBREPOSICAO DOS ARQUIVOS
				If aSaldArqs[nArq2Ger][2] > 0					/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
					fClose(aSaldArqs[nArq2Ger][2])
				EndIf
			Next
			ApMsgAlert(STR0015 + Str(fError(),2)) //"Erro na criação do arquivo - ERRO Nº "
			Return
		Else
			aSaldArqs[nArq2Ger][2] := nHdl
		EndIf
	EndIf
Next

If aSaldArqs[1][2] > 0 .or. aSaldArqs[2][2] > 0 .or. aPlanArqs[1][2] > 0 .or. aPlanArqs[2][2] > 0
	DbSelectArea("CT1")
	cFilCT1 := xFilial("CT1")
	nTamCT1 := Len(CT1->CT1_CONTA)-1
	dbSetOrder(1)												//// ORDENADO PELA CLASSE DA CONTA
	ProcRegua(RecCount())
	MsSeek(cFilCT1,.T.)										//// LOCALIZA A PRIMEIRA ANALITICA
	While CT1->(!Eof()) .and. CT1->CT1_FILIAL == cFilCT1 
		IncProc(STR0017+ALLTRIM(CT1->CT1_CONTA))///"Gerando Plano/Saldos da conta: "

		/// GRAVA A CONTA SINTETICA NO PLANO DE CONTAS DO DIARIO GERAL (CADASTRO)
		If aPlanArqs[1][2] > 0 .and. CT1->CT1_CLASSE == "1"
			cCampo := STRZERO(DAY(CT1->CT1_DTEXIS),2)+STRZERO(MONTH(CT1->CT1_DTEXIS),2)+STRZERO(YEAR(CT1->CT1_DTEXIS),4)			/// DATA DE INICIO DE EXISTENCIA DA CONTA
			cCampo += PADR(CT1->CT1_CONTA,28)					/// CODIGO DA CONTA CONTABIL
			cCampo += "S"										/// CLASSE DA CONTA (A=ANALITICA/S=SINTETICA)
			cCampo += PADR(CT1->CT1_CTASUP,28)					/// CODIGO DA CONTA SUPERIOR
			cCampo += PADR(CT1->CT1_DESC01,45)					/// DESCRICAO DA CONTA
			If aPlanArqs[1][2] > 0
				fWrite(aPlanArqs[1][2],cCampo+CRLF)	
			EndIf
		EndIf
        
        If CT1->CT1_CLASSE <> "2"				/// CONTAS SINTETICAS VÃO SOMENTE NO ARQ. PLANO DE CONTAS DO DIARIO GERAL
        	CT1->(dbSkip())
        	Loop
        EndIf
        
		//// VALIDA PELAS DATA INICIAIS E FINAIS SE HOUVE MOVIMENTAÇÃO NO PERIODO
		aSldAnt := SaldoCT7(CT1->CT1_CONTA,dDtIni-1,cMoeda,cTpSald)
		aSaldo  := SaldoCT7(CT1->CT1_CONTA,dDtFim,cMoeda,cTpSald)
		nSaldo  := aSaldo[1] - aSldAnt[1]
		nMovDeb := aSaldo[4] - aSldAnt[4]
		nMovCrd := aSaldo[5] - aSldAnt[5]
		
		If nSaldo == 0 .and. aSaldo[1] == 0 .and. nMovDeb == 0 .and. nMovCrd == 0 	//// SE NÃO HOUVE MOVIMENTO E NÃO TEM SALDO NA CONTA
			dbSelectArea("CT1")
			CT1->(dbSkip())										/// PASSA PARA O PROXIMO
			Loop
		EndIf

		If aPlanArqs[1][2] > 0 .or. aPlanArqs[2][2] > 0
			/// SE TEM MOVIMENTO NO PERIODO GERA A CONTA CONTABIL ANALITICA (CADASTRO)
			cCampo := STRZERO(DAY(CT1->CT1_DTEXIS),2)+STRZERO(MONTH(CT1->CT1_DTEXIS),2)+STRZERO(YEAR(CT1->CT1_DTEXIS),4)			/// DATA DE INICIO DE EXISTENCIA DA CONTA
			cCampo += PADR(CT1->CT1_CONTA,28)					/// CODIGO DA CONTA CONTABIL
			cCampo += "A"										/// CLASSE DA CONTA (A=ANALITICA/S=SINTETICA)
			cCampo += PADR(CT1->CT1_CTASUP,28)					/// CODIGO DA CONTA SUPERIOR
			cCampo += PADR(CT1->CT1_DESC01,45)					/// DESCRICAO DA CONTA
			If aPlanArqs[1][2] > 0
				fWrite(aPlanArqs[1][2],cCampo+CRLF)	
			EndIf		
			If aPlanArqs[2][2] > 0
				/// TRANSFORMA O CODIGO DA CONTA FORMADO POR 1º DIGITO DA CONTA + "0" + RESTANTE DA CONTA
				/// PARA PASSAR NA VALIDACAO DO PLANO DE CONTAS DO DIARIO AUXILIAR (NAO ACEITA CONTA TOTALIZADORA IGUAL A PROPRIA CONTA)
				cCampo := Left(cCampo,8)+Padr(Left(CT1->CT1_CONTA,1)+"0"+Right(CT1->CT1_CONTA,nTamCT1),28)+"A"+PADR(CT1->CT1_CONTA,28)+Right(cCampo,45)
				fWrite(aPlanArqs[2][2],cCampo+CRLF)	
			EndIf		
		EndIf
	                                
		If aSaldArqs[1][2] > 0 .or. aSaldArqs[2][2] > 0 
			/// EFETUA O CALCULO DE SALDO MES A MES PARA A GERAÇÃO NO ARQUIVO DE SALDOS
			dDataFAtu	:= LastDay(dDTini)
			nAnoFAtu	:= Year(dDataFAtu)
			nMesFAtu	:= Month(dDataFAtu)
			While dDataFAtu <= dDtFim
				dDataIAtu := FirstDay(dDataFAtu)
				aSldAnt := SaldoCT7(CT1->CT1_CONTA,dDataIAtu-1,cMoeda,cTpSald)
				aSaldo  := SaldoCT7(CT1->CT1_CONTA,dDataFAtu,cMoeda,cTpSald)
				nSaldo  := aSaldo[1] - aSldAnt[1]
				nMovDeb := aSaldo[4] - aSldAnt[4]
				nMovCrd := aSaldo[5] - aSldAnt[5]
           
				cCampo := STRZERO(DAY(dDataIAtu),2)+STRZERO(MONTH(dDataIAtu),2)+STRZERO(YEAR(dDataIAtu),4)				/// USA A DATA DO PARAMETRO
				cCampo += PADR(CT1->CT1_CONTA,28)					/// CODIGO DA CONTA CONTABIL
				cValor := STRZERO(ABS(aSldAnt[1]),17,2)
				cValor := "0"+Left(cValor,14)+Right(cValor,2)
				cCampo += cValor									/// SALDO INICIAL SEM SINAL E SEM VIRGULA 2 DECIMAIS
				If aSldAnt[1] > 0									/// SINAL RELATIVO AO SALDO INICIAL
					cCampo += "C"
				Else
					cCampo += "D"		
				EndIf
				cValor := STRZERO(ABS(nMovDeb),17,2)
				cValor := "0"+Left(cValor,14)+Right(cValor,2)		
				cCampo += cValor									/// MOVIMENTO À DEBITO
		
				cValor := STRZERO(ABS(nMovCrd),17,2)
				cValor := "0"+Left(cValor,14)+Right(cValor,2)		
				cCampo += cValor									/// MOVIMENTO À CREDITO
				
				cValor := STRZERO(ABS(aSaldo[1]),17,2)
				cValor := "0"+Left(cValor,14)+Right(cValor,2)		
				cCampo += cValor									/// SALDO FINAL SEM SINAL E SEM VIRGULA 2 DECIMAIS		
				If aSaldo[1] > 0									/// SINAL RELATIVO AO SALDO INICIAL
					cCampo += "C"
				Else
					cCampo += "D"		
				EndIf		                             
		             
				If aSaldArqs[1][2] > 0
					fWrite(aSaldArqs[1][2],cCampo+CRLF)	
				EndIf		
				If aSaldArqs[2][2] > 0
					/// TRANSFORMA O CODIGO DA CONTA FORMADO POR 1º DIGITO DA CONTA + "0" + RESTANTE DA CONTA
					/// PARA PASSAR NA VALIDACAO DO PLANO DE CONTAS DO DIARIO AUXILIAR (NAO ACEITA CONTA TOTALIZADORA IGUAL A PROPRIA CONTA)
					cCampo := Left(cCampo,8)+Padr(Left(CT1->CT1_CONTA,1)+"0"+Right(CT1->CT1_CONTA,nTamCT1),28)+Right(cCampo,70)
					fWrite(aSaldArqs[2][2],cCampo+CRLF)	
				EndIf		
				
				/// INCREMENTA OS CONTADORES DE MES E ANO
				If nMesFAtu >= 12
					nMesFAtu := 1
					nAnoFAtu++
				Else
					nMesFAtu++
				EndIf		
				dDataFAtu := LASTDAY(CTOD("01/"+STRZERO(nMesFAtu,2)+"/"+STRZERO(nAnoFAtu,4)))
			EndDo
		EndIf

	    dbSelectArea("CT1")    	    
		DbSkip()
	EndDo
	If aPlanArqs[1][2] > 0
		FClose(aPlanArqs[1][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
	If aPlanArqs[2][2] > 0
		FClose(aPlanArqs[1][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
	If aSaldArqs[1][2] > 0
		FClose(aSaldArqs[1][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
	If aSaldArqs[2][2] > 0
		FClose(aSaldArqs[2][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
EndIf

dbSelectArea("CTT")
cFilCTT := xFilial("CTT")
If (aPlanArqs[3][2] > 0 .or. aPlanArqs[4][2] > 0 ) .and. nCusto <> 4
	dbSetOrder(2)
	ProcRegua(RecCount())
	dbSeek(cFilCTT+"2",.T.)
	While CTT->(!Eof()) .and. CTT->CTT_FILIAL == cFilCTT 
		IncProc(STR0019+CTT->CTT_CUSTO)
		cCampo := STRZERO(DAY(CTT->CTT_DTEXIS),2)+STRZERO(MONTH(CTT->CTT_DTEXIS),2)+STRZERO(YEAR(CTT->CTT_DTEXIS),4)			/// DATA DE INICIO DE EXISTENCIA DA CONTA
		cCampo += PADR(CTT->CTT_CUSTO,28)					/// CODIGO DA CONTA CONTABIL
		cCampo += PADR(CTT->CTT_DESC01,45)					/// DESCRICAO DA CONTA
		
		If aPlanArqs[3][2] > 0
			fWrite(aPlanArqs[3][2],cCampo+CRLF)	
		EndIf		
		If aPlanArqs[4][2] > 0
			fWrite(aPlanArqs[4][2],cCampo+CRLF)	
		EndIf
	
		dbSelectArea("CTT")
		dbSkip()
	EndDo			
    
	If aPlanArqs[3][2] > 0
		FClose(aPlanArqs[3][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
	If aPlanArqs[4][2] > 0
		FClose(aPlanArqs[4][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
EndIf

If aLancArqs[1][2] > 0 .or. aLancArqs[2][2] > 0
	dbSelectArea("CT2")
	cFilCT2 := xFilial("CT2")
	nTamCTDB := Len(CT2->CT2_DEBITO)-1
	nTamCTCR := Len(CT2->CT2_CREDIT)-1
	dbSetOrder(1)
	MsSeek(cFilCT2+DTOS(dDtIni),.T.)
	dDataProc := CT2->CT2_DATA
	ProcRegua(RecCount())
	IncProc(STR0020+DTOC(CT2->CT2_DATA))
	While CT2->(!Eof()) .and. CT2->CT2_FILIAL == cFilCT2 .and. CT2->CT2_DATA <= dDtFim
		If dDataProc <> CT2->CT2_DATA
			IncProc(STR0020+DTOC(CT2->CT2_DATA))
			dDataProc := CT2->CT2_DATA
		EndIf
		If CT2->CT2_MOEDLC <> cMoeda .or. CT2->CT2_TPSALD <> cTpSald .or. CT2->CT2_DC > "3" .or. CT2->CT2_VALOR == 0
			dbSkip()
			Loop
		EndIf
		nPart := 2
		For nDC := 1 to nPart
			cCampo := STRZERO(DAY(CT2->CT2_DATA),2)+STRZERO(MONTH(CT2->CT2_DATA),2)+STRZERO(YEAR(CT2->CT2_DATA),4)
			If CT2->CT2_DC == "1"
				nDC := 1
				nPart := 1
			ElseIf CT2->CT2_DC == "2"
				nDC := 2		
				nPart := 2
			EndIf
			
			cCampo2 := cCampo
			If CT2->CT2_DC $ "13"
				If nDC == 1
					cCampo	+= Padr(CT2->CT2_DEBITO,28)
					cCampo2 += Padr(Left(CT2->CT2_DEBITO,1)+"0"+Right(CT2->CT2_DEBITO,nTamCTDB),28)	/// CONTA DO LANCAMENTO (A DEBITO) PARTIDA SIMPLES DEVEDORA												
					If nCusto <> 4
						cCampo += PADR(CT2->CT2_CCD,28)					/// CENTRO DE CUSTOS/DESPESAS
						cCampo2 += PADR(CT2->CT2_CCD,28)					/// CENTRO DE CUSTOS/DESPESAS
					Else
						cCampo += SPACE(28)								/// CASO NAO UTILIZE CENTRO DE CUSTO
						cCampo2 += SPACE(28)							/// CASO NAO UTILIZE CENTRO DE CUSTO
					EndIf
					//cCampo += Padr(Left(CT2->CT2_CREDIT,1)+"0"+Right(CT2->CT2_CREDIT,nTamCTCR),28)	/// CONTA DE CONTRA-PARTIDA (A CREDITO) PARTIDA SIMPLES DEVEDORA
					/// A VERSÃO 1.01 DO SINCO ESTA RECEBENDO A CONTRA PARTIDA COM A CONTA ORIGINAL DO PLANO DE CONTAS (NÃO DO AUXILIAR)
					cCampo += Padr(CT2->CT2_CREDIT,28)
					cCampo2 += Padr(CT2->CT2_CREDIT,28)
					cSinal	:= "D"
				Else
					cCampo += Padr(CT2->CT2_CREDIT,28)
					cCampo2 += Padr(Left(CT2->CT2_CREDIT,1)+"0"+Right(CT2->CT2_CREDIT,nTamCTCR),28)	/// CONTA DO LANCAMENTO (A DEBITO) PARTIDA-DOBRADA (2ª LINHA)				
					If nCusto <> 4
						cCampo += PADR(CT2->CT2_CCC,28)					/// CENTRO DE CUSTOS/DESPESAS
						cCampo2 += PADR(CT2->CT2_CCC,28)				/// CENTRO DE CUSTOS/DESPESAS
					Else
						cCampo += SPACE(28)								/// CASO NAO UTILIZE CENTRO DE CUSTO
						cCampo2 += SPACE(28)							/// CASO NAO UTILIZE CENTRO DE CUSTO
					EndIf
					//cCampo += Padr(Left(CT2->CT2_DEBITO,1)+"0"+Right(CT2->CT2_DEBITO,nTamCTDB),28)/// CONTA DE CONTRA-PARTIDA (A DEBITO) PARTIDA-DOBRADA (2ª LINHA)						
					/// A VERSÃO 1.01 DO SINCO ESTA RECEBENDO A CONTRA PARTIDA COM A CONTA ORIGINAL DO PLANO DE CONTAS (NÃO DO AUXILIAR)
					cCampo += Padr(CT2->CT2_DEBITO,28)
					cCampo2 += Padr(CT2->CT2_DEBITO,28)					
					cSinal	:= "C"
				EndIf
			Else
				cCampo += Padr(CT2->CT2_CREDIT,28)
				cCampo2 += Padr(Left(CT2->CT2_CREDIT,1)+"0"+Right(CT2->CT2_CREDIT,nTamCTCR),28)	/// CONTA DO LANCAMENTO (A CREDITO) PARTIDA SIMPLES CREDORA
				If nCusto <> 4
					cCampo += PADR(CT2->CT2_CCC,28)					/// CENTRO DE CUSTOS/DESPESAS
					cCampo2 += PADR(CT2->CT2_CCC,28)				/// CENTRO DE CUSTOS/DESPESAS
				Else
					cCampo += SPACE(28)								/// CASO NAO UTILIZE CENTRO DE CUSTO
					cCampo2 += SPACE(28)							/// CASO NAO UTILIZE CENTRO DE CUSTO
				EndIf
				//cCampo += Padr(Left(CT2->CT2_DEBITO,1)+"0"+Right(CT2->CT2_DEBITO,nTamCTDB),28)	/// CONTA DE CONTRA-PARTIDA (A DEBITO) - PARTIDA SIMPLES CREDORA
				/// A VERSÃO 1.01 DO SINCO ESTA RECEBENDO A CONTRA PARTIDA COM A CONTA ORIGINAL DO PLANO DE CONTAS (NÃO DO AUXILIAR)
				cCampo += Padr(CT2->CT2_DEBITO,28)
				cCampo2 += Padr(CT2->CT2_DEBITO,28)
				cSinal	:= "C"
			EndIf
	
			cValor := STRZERO(ABS(CT2->CT2_VALOR),17,2)
			cValor := "0"+Left(cValor,14)+Right(cValor,2)
			cCampo += cValor										/// VALOR DO MOVIMENTO SEM SINAL E SEM VIRGULA 2 DECIMAIS
			cCampo2 += cValor										/// VALOR DO MOVIMENTO SEM SINAL E SEM VIRGULA 2 DECIMAIS
			
			cCampo += cSinal										/// SINAL DO LANCAMENTO (D=Debito/C=Credito)
			cCampo2 += cSinal										/// SINAL DO LANCAMENTO (D=Debito/C=Credito)
			
			cCampo += PADR(CT2->(CT2_LOTE+CT2_DOC),12)				/// NUMERO DE ARQUIVAMENTO (DOC LASTREADOR OPERACAO)
			cCampo2 += PADR(CT2->(CT2_LOTE+CT2_DOC),12)				/// NUMERO DE ARQUIVAMENTO (DOC LASTREADOR OPERACAO)			
			cCampo += PADR(CT2->(CT2_LOTE+CT2_DOC),12)				/// CHAVE PARA IDENTIFICAR O LANCAMENTO	(LOTE+DOCUMENTO)
			cCampo2 += PADR(CT2->(CT2_LOTE+CT2_DOC),12)				/// CHAVE PARA IDENTIFICAR O LANCAMENTO	(LOTE+DOCUMENTO)
			
			cHistorico 	:= CT2->CT2_HIST
			
			//// BUSCA LANCAMENTOS DE COMPLEMENTO DE HISTORICO
			nRecCT2	:= CT2->(Recno())
			nOrdCT2 := CT2->(IndexOrd())

			cKeyCT2	:= cFilCT2+CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_SEQLAN)			
			cEmpOri := CT2->CT2_EMPORI 
			cFilOri := CT2->CT2_FILORI
			cSeqLan := CT2->CT2_SEQLAN						
			dbSelectArea("CT2")
			dbSetOrder(10)
			dbSkip()	
			While CT2->(!Eof()) .and. CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_SEQLAN) == cKeyCT2
				IF CT2->CT2_DC <> "4" .or. CT2->CT2_EMPORI <> cEmpOri .or. CT2->CT2_FILORI <> cFilOri
		 			CT2->(dbSkip())
		 			Loop    	
		 	    EndIf
				cHistorico += CT2->CT2_HIST
				CT2->(dbSkip())
			EndDo
			dbSelectArea("CT2")
			dbSetOrder(nOrdCT2)
			MsGoTo(nRecCT2)
				
			cCampo += PADR(cHistorico,150)						/// HISTORICO DO LANCAMENTO			
			cCampo2 += PADR(cHistorico,150)						/// HISTORICO DO LANCAMENTO			
			
			If aLancArqs[1][2] > 0
				fWrite(aLancArqs[1][2],cCampo+CRLF)	
			EndIf		
			If aLancArqs[2][2] > 0
				fWrite(aLancArqs[2][2],cCampo2+CRLF)	
			EndIf		
			
			If nPart == 2 .and. nDC == 2
				Exit
			ElseIf nPart == 1 .and. nDC == 1
				Exit
			EndIf			
		Next
        
		dbSelectArea("CT2")
		dbSkip()
	EndDo
	
	If aLancArqs[1][2] > 0
		FClose(aLancArqs[1][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
	If aLancArqs[2][2] > 0
		FClose(aLancArqs[1][2])
		lGravou := .T.					/// Indica que houve gravação de arquivo (para mensagem de conclusao).
	EndIf
EndIf

For nArq2Ger := 1 to Len(aPlanArqs)									 /// RODA O ARRAY DOS ARQUIVOS DE CADASTRO
	If aPlanArqs[nArq2Ger][2] > 0 .and. File(aPlanArqs[nArq2Ger][1]) /// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
		fClose(aPlanArqs[nArq2Ger][2])								 /// SE AINDA ESTIVEREM ABERTOS
	EndIf
Next
For nArq2Ger := 1 to Len(aLancArqs)									///  RODA O ARRAY DOS ARQUIVOS DE LANCAMENTO
	If aLancArqs[nArq2Ger][2] > 0 .and. File(aLancArqs[nArq2Ger][1])/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
		fClose(aLancArqs[nArq2Ger][2])								/// SE AINDA ESTIVEREM ABERTOS
	EndIf
Next
For nArq2Ger := 1 to Len(aSaldArqs)									/// RODA O ARRAY DOS ARQUIVOS DE SALDO
	If aSaldArqs[nArq2Ger][2] > 0 .and. File(aPlanArqs[nArq2Ger][1])/// FECHA OS ARQUIVOS ABERTOS ANTERIORMENTE
		fClose(aSaldArqs[nArq2Ger][2])								/// SE AINDA ESTIVEREM ABERTOS
	EndIf
Next

If lGravou 
	MsgInfo(STR0022+CHR(13)+mv_par08)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA997   ºAutor  ³Marcos S. Lobo      º Data ³  10/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³RETORNA A PRIMEIRA DATA DE SALDO A CONTAR DA DATA INDICADA  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct7DtSlIni(cConta,dDtIni,cMoeda,cTpSald)

Local dDtSlIni := CTOD("  /  /  ")
Local aAreaOri := GetArea()
Local aCT7Area := CT7->(GetArea())

dbSelectArea("CT7")
dbSetOrder(1)
MsSeek(xFilial("CT7")+cMoeda+cTpSald+cConta+DTOS(dDtIni),.T.)
If CT7->CT7_MOEDA == cMoeda .and. CT7->CT7_TPSALD == cTpSald .and. CT7->CT7_CONTA == cConta
	dDtSlIni := CT7->CT7_DATA
EndIf

RestArea(aCT7Area)
RestArea(aAreaOri)
Return(dDtSlIni)
