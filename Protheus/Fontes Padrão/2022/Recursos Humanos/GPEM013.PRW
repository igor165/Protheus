#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM013.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM013	³ Autor ³ Allyson M	                 ³ Data ³ 10/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ ROTINA PARA CHAMADA DO CALCULO DA DESONERACAO FOLHA	   	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 		ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.		           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ Chamado   ³  Motivo da Alteracao			  	       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leandro Dr. ³28/01/14³RHU210_30  ³Unificao da Folha. Ver 12             	   ³±±
±±³Flavio C.   ³09/06/14³TPUOTR     ³REPLICA V11 Ajuste p/ tratar nova opcao   ³±±
±±³            ³        ³           ³preenchimento do campo X14_RECFAT.	       ³±±
±±³Raquel Hager³16/07/14³TPXRTO     ³Replica - Integ. Faturamento.     	       ³±±
±±³Flavio Corr.³03/09/14³TQKIS1     ³Recompilar fonte - Erro Tecnologia	       ³±±
±±³Cícero Alves³26/08/15³TTF183     ³Alteração para apresentar o valor total   ³±±
±±³            ³        ³           ³com a dedução das exportações.			   ³±±
±±³Allyson M   ³14/10/15³TTLNPT     ³Ajuste p/ gravar a receita bruta na S033 e³±±
±±³            ³        ³           ³gravar a diferenca entre a receita bruta e³±±
±±³            ³        ³           ³liquida no novo campo da S033.			   ³±±
±±³Claudinei S.³30/11/16³MRH-1469   ³Incluídos ajustes para empresas não estão ³±±
±±³            ³        ³TUQEAR     ³mais beneficiadas pela desoneração.       ³±±
±±³Allyson M   ³20/01/17³MRH-5109   ³Ajuste p/ desoneração de 13º p/ gerar o   ³±±
±±³            ³        ³           ³registro de 13/2016 na S033 quando não    ³±±
±±³            ³        ³           ³possui integração com faturamento		   ³±±
±±³Cícero Alves³01/09/17³DRHPAG-256 ³Tratamento para calculo de INSS Empresa de³±±
±±³            ³        ³      	    ³residentes no exterior.				   ³±±
±±³Oswaldo L   ³05/12/17³DSERFAT3491³Tratar retorno apos função RhInssPat      ³±±
±±³            ³        ³           ³ter sido adequada ao projeto soyuz        ³±±
±±³Oswaldo L   ³05/12/17³DSERFAT3495³Alertei outra situação no gpem013: Função ³±±
±±³            ³        ³           ³FTotF100 deixou de gerar memória de cálcu ³±±
±±³            ³        ³           ³lo em tabela DBF do system. Mas nosso rela³±±
±±³            ³        ³           ³tório emite mensagem instruindo usuário a ³±±
±±³            ³        ³           ³conferir esta memória de cálculo. O Finan-³±±
±±³            ³        ³           ³ceiro deveria gerar est dado em uma tabela³±±
±±³            ³        ³           ³física e deixa-lo p/ que estes possam ser ³±±
±±³            ³        ³           ³consultados por nossos usuarios. Mas isto ³±±
±±³            ³        ³           ³não fora feito e a                        ³±±
±±³            ³        ³           ³instrução fora de simplesmente remover a  ³±±
±±³            ³        ³           ³mensagem de alerta do nosso código.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM013( lRobo )

Local aArea			:= GetArea()
Local bProcesso 	:= { |oSelf| GPMProcessa(oSelf) }
Local cDescricao 	:= ""

Private aLogDes		:= {}
Private aTitle		:= {}
Private cRotSXB		:= fGetCalcRot("1") + "*" + fGetCalcRot("9") + "*" + fGetCalcRot("5") + "*" + fGetCalcRot("6") //Roteiros para filtro na consulta padroa RCHGEN
Private cPerSelSXB	:= "1" //Filtrar periodos selecionados na consulta padrao RCHGEN
Private cLayoutGC	:= FWSM0Layout(cEmpAnt)
Private lTemEmp		:= !Empty(FWSM0Layout(cEmpAnt, 1))
Private lTemGC		:= fIsCorpManage( FWGrpCompany() )
Private nIniEmp 	:= At("E", cLayoutGC)
Private nTamEmp		:= Len(FWSM0Layout(cEmpAnt, 1))

DEFAULT lRobo		:= .F.

cCadastro 	:= OemToAnsi(STR0001) //"Desoneração da Folha de Pagamento"

Begin Sequence

	Pergunte("GPM013",.F.)
	If !lRobo
		cDescricao 	:= OemToAnsi(STR0002)//"Este programa atualiza, se configurado, a tabela auxiliar S033 - Faturamento Mensal com as informações da receita obtida no período. Também efetua a apuração da Contribuição Previdenciária Patronal"

		tNewProcess():New( "GPEM013" , cCadastro , bProcesso , cDescricao , "GPM013", , , , ,.T.,.T.  )

		fMakeLog(aLogDes,aTitle,,,STR0006,OemToAnsi(STR0007),"M","P",,.F.) //"Desonera"##"Log de Ocorrências do Cálculo"
	Else
		GPMProcessa( Nil, .T.)
	EndIf

End Sequence

RestArea( aArea )

Return()

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³ GPMProcessa ³ Autor ³ Equipe de RH    	  ³ Data ³10/09/2012³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³ Confirmar as Configuracoes dos Parametros                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³ GPMProcessa(oSelf)											³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso	   ³ Generico 												    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function GPMProcessa(oSelf, lRobo)

Local aArea			:= GetArea()
Local aAreaSM0	 	:= SM0->( GetArea() )
Local aAuxS033		:= {}
Local aCalcDes		:= {}
Local aCargFil		:= FwLoadSM0()
Local aCateg		:= {}
Local aFilProc	 	:= {}
Local aSrcFields	:= SRC->( dbStruct() )
Local aSrdFields	:= SRD->( dbStruct() )
Local aTab13Sal  	:= {}
Local aTabInss	 	:= {}
Local aTabS033	 	:= {}
Local aPdMat		:= {}
Local aPdAfa		:= {}
Local cAliasFat	 	:= ""
Local cAliasTMP 	:= "QNRO"
Local cAliasSRA		:= "SRA"
Local cAliasSRC		:= "SRC"
Local cAliasSRD		:= "SRD"
Local cCatQuery		:= 0
Local cProcesso		:= ""
Local cRoteiro		:= ""
Local cPeriodo		:= ""
Local cCposQuery	:= ""
Local cCateg	 	:= ""
Local cChave	 	:= ""
local cChvBas	 	:= ""
Local cCodEmp	 	:= SM0->M0_CODIGO
Local cFilRange  	:= ""
Local cLastEmp		:= "_cLastEmp"
Local cLastFil		:= "_cLastFil"
Local cLimRef		:= Str( Val( SubStr( mv_par03, 1, 4 ) ) - 1, 4 ) + "12"
Local cMatRange	 	:= ""
Local cRecFatEmp 	:= ""
Local cRefAux		:= SubStr( mv_par03, 1, 4 ) + "11"
Local cTextoLog		:= ""
Local cTextoLog1	:= ""
Local cTipFat	 	:= ""
Local cTpC			:= ""
Local cConta		:= ""
Local cAux			:= ""
Local cVerba		:= ""
Local cPdAux		:= ""
Local dDataPg		:= cToD("//")
Local dDataRef	 	:= cToD("//")
Local dDataFim		:= cToD("//")
Local lAliqPad		:= .F.
Local lFirst		:= .T.
Local lGera			:= .T.
Local lItemClVl 	:= ( GetMvRH( "MV_ITMCLVL", .F., "2" ) $ "1*3" )
Local lLogRec		:= .F.
Local lLogRec13		:= .F.
Local lRatDes 	 	:= .F.
Local lRatProv 	 	:= ( SuperGetMv("MV_RATPROV", .F., "N") == "S" ) // Rateio da Desoneração.
Local lRecDesTot 	:= .F.
Local lTemClvl		:= ( SRA->( FieldPos( "RA_CLVL" ) ) != 0 )
Local lTemInssAut	:= ( SRA->( FieldPos( "RA_INSSAUT" ) ) != 0 )
Local lTemItem		:= ( SRA->( FieldPos( "RA_ITEM" ) ) != 0 )
Local cOneFol		:= ""
Local lFolha		:= .F.
Local lOnera		:= .F.
Local nPosOnera 	:= 0
Local nAliq		 	:= 0
Local nAv13Des     	:= 0
Local nAv13Resc   	:= 0
Local nBasDes     	:= 0
Local nBase318     	:= 0
Local nBaseInss     := 0
Local nCont  		:= 0
Local nCont13		:= 0
Local nCont973		:= 0
Local nContPd		:= 0
Local nContInss		:= 0
Local nContr		:= 0
Local nContrib		:= 0
Local nEmpFatDes	:= 0
Local nEmpFatFol	:= 0
Local nEmpFatTot	:= 0
Local nFatBas    	:= 0
Local nFatExc    	:= 0
Local nFatExp    	:= 0
Local nFatRecB	 	:= 0
Local nFatRecL	 	:= 0
Local nFatRec	 	:= 0
Local nFatTot		:= 0
Local nFatTotDev	:= 0
Local nFatTotExp	:= 0
Local nFatTotLiq	:= 0
Local nField		:= 0
Local nFilial	 	:= 0
Local nOrdSRC		:= RetOrder("SRC","RC_FILIAL+RC_PROCES+RC_MAT+RC_PERIODO+RC_SEMANA+RC_ROTEIR+RC_PD+RC_CC+RC_SEQ+DTOS(RC_DTREF)")
Local nPer13Sal		:= 0
Local nPerFatEmp	:= 0
Local nRecBruto		:= 0
Local nRecDes		:= 0
Local nRecOut		:= 0
Local nReg			:= 0
Local nRegProc		:= 0
Local nSalCont		:= 0
Local nSalCon13		:= 0
Local nSrcFields 	:= Len( aSrcFields )
Local nSrdFields 	:= Len( aSrdFields )
Local nTot318		:= 0
Local nTot973		:= 0
Local nTotCLiq		:= 0
Local nTotCont		:= 0
Local nTotDev		:= 0
Local nTotExp		:= 0
Local nTotImp		:= 0
Local nTpContr	 	:= 0
Local nValSBas		:= 0
Local nVlAux		:= 0
Local nFatRecAux	:= 0
Local nVerFatFin 	:= 0
Local nVl13Des     	:= 0
Local nVl13Resc   	:= 0
Local nValDev 		:= 0
Local nValExp 		:= 0
Local nExpNDes 		:= 0  //exportações não desoneradas
Local nX			:= 0
Local uRatDes
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
Local lOfusca		:= Len(aFldRel) > 0

Private aCodFol		:= {}
Private aPd			:= {}
Private aPdv		:= {}
Private aSalBase	:= {}
Private aRateio     := {}
Private aEncM013    := {}
Private cAnoMes 	:= ""
Private cSemana		:= ""
Private lDissidio 	:= .F.
Private nOrdGrPd	:= 0

DEFAULT lRobo		:= .F.

SetMnemonicos(NIL,NIL,.T.)
cOneFol := If(Type("P_FDESFOL") # "U", P_FDESFOL, "")
lEncPatro	:= If( Type("lEncPatro") == "U", .T., lEncPatro)

uRatDes 	 	:= GetMvRH( "MV_RAT0973", .F., .F. )

// Parametro era logico e mudou para caracter indevidamente no P12
If ValType( uRatDes ) == "L"
	lRatDes := uRatDes
ElseIf ValType( uRatDes ) == "C"
	uRatDes := GetMvRH( "MV_RAT0973", .F., ".F." )
	lRatDes	:= ( uRatDes == ".T." )
EndIf

Aadd( aTitle, OemToAnsi( STR0012 ) )//"Log do Cálculo da Contribuição Previdenciária Patronal"
Aadd( aLogDes	, {} )
Aadd( aTitle, OemToAnsi( STR0013 ) )//"Avisos"
Aadd( aLogDes	, {} )
Aadd( aTitle, OemToAnsi( STR0034 ) )//"Log do Cálculo da Contribuição Previdenciária Patronal - 13º Salário"
Aadd( aLogDes	, {} )

cProcesso	:= mv_par01
cRoteiro	:= mv_par02
cPeriodo	:= mv_par03
cSemana		:= mv_par04
cFiliais	:= AllTrim(mv_par05)

MakeSqlExpr( "GPM013" ) //Transforma perguntas do tipo Range em expressao SQL

cFilRange  	:= mv_par05		//Range de Filiais
cMatRange	:= mv_par06		//Range de Matriculas
cCateg	 	:= mv_par07		//Categorias a serem calculadas
nVerFatFin 	:= mv_par08		//Vericar Faturamento-Financeiro (1-Nao; 2-Faturamento; 3-Financeiro; 4-Ambos)

lFolha := fGetRotOrdinar() == cRoteiro .OR. cRoteiro == fGetCalcRot("9") //Autonomo ou folha

DbSelectArea("RCH")
DbSetOrder(1)

If !(DbSeek(xFilial("RCH")+cProcesso+cPeriodo+cSemana+cRoteiro))
	Help( ,, OemToAnsi("Atenção"),, OemToAnsi("Periodo nao encontrado. Informe Processo, Roteiro, Periodo e Nro. Pagamento"), 1, 0 ) //"Atencao" ## "Periodo nao encontrado. Informe Processo, Roteiro, Periodo e Nro. Pagamento"
	Return Nil
EndIf

If !Empty(RCH->RCH_DTFECH) .or. RCH->RCH_PERSEL <> "1"
	Help( ,, OemToAnsi("Atenção"),, OemToAnsi("Periodo fechado ou  ão esta ativo. Verifique"), 1, 0 ) //"Atencao" ## "Periodo fechado ou  ão esta ativo. Verifique"
	Return Nil
EndIf

//Monta variavel dDataRef da data de competencia em aberto p/ busca do fCarrTab
dDataRef := RCH->RCH_DTINI
dDataFim := RCH->RCH_DTFIM
cAnoMes	 := RCH->RCH_ANO + RCH->RCH_MES
dDataPg	 := RCH->RCH_DTPAGO

RstGpexIni()

If lFolha
	//Chama fCarrTab para carregar tabela auxiliar S033
	fCarrTab( @aTabS033, "S033", dDataRef, .T. )
Else
	//Chama fCarrTab para recarregar tabela auxiliar S033 - 13o. salario
	fCarrTab( @aTab13Sal, "S033", ,.T.,SubStr( cAnoMes, 1, 4 ) + "13" )
EndIf

//Se for calculo da folha, verificar faturamento e/ou financeiro
If lFolha .And. nVerFatFin != 1
	//Monta o array das filiais a processar.
	aEval( aCargFil, { |aCargFil| If( aCargFil[1] == cCodEmp .And. ( Empty(cFiliais) .Or. AllTrim(aCargFil[2]) $ cFiliais ), aAdd(aFilProc, { aCargFil[2] } ), Nil ) } )

	//Verifica todas as filiais que foram selecionadas no processamento,
	//para validar se possuem registro na tabela auxiliar S033
	For nFilial := 1 To Len( aFilProc )
		//Reinicializa variaveis
		nAliq	 	:= 0
		nContr		:= 0
		nFatTot	 	:= 0
		nFatTotDev	:= 0
		nFatTotExp	:= 0
		nFatTotLiq	:= 0
		nFatRecB 	:= 0
		nFatRecL 	:= 0
		nFatRec 	:= 0
		nFatExc 	:= 0
		nFatExp 	:= 0
		nFatBas		:= 0
		nTotCLiq 	:= 0
		nTotCont 	:= 0
		nTotDev 	:= 0
		nTotExp 	:= 0
		nTotImp 	:= 0
		nVlAux	 	:= 0
		nFatRecAux	:= 0
		nValDev 	:= 0
		nValExp 	:= 0
		cConta		:= ""
		//Busca no parametro 14 se a empresa recolhe contribuicao previdenciaria sobre a receita (X14_RECFAT)
		If fInssEmp( aFilProc[nFilial, 1], @aTabInss, Nil, cAnoMes )
			//Verifica os dois tipos de contrato
			For nTpContr := 1 To 2
				cRecFatEmp 	:= aTabInss[27, nTpContr]//X14_RECFAT
				//Se recolher sobre o faturamento ou for recolhimento misto
				If cRecFatEmp $ "S*M*C"
	            	//Se somente verifica Financeiro
	            	If nVerFatFin == 3
						//Entra na funcao do Financeiro para buscar os valores dos titulos de acordo
						//com a filial logada. A funcao nao permite passar a filial como parametro
						//entao a variavel cFilAnt sera alterada de acordo com a filial em processamento.
						//A funcao retorna o valor das receitas financeiras.
						cSvFilAnt := cFilAnt
						cFilAnt	  := aFilProc[nFilial, 1]
						nFatTot   := FTotF100( Val( SubStr( cAnoMes, 5, 2 ) ), Val( SubStr( cAnoMes, 1, 4 ) ) )
						cFilAnt	  := cSvFilAnt
		                //Grava o registro da receito de tipo 2
						If nFatTot > 0
							fGravaS033( aFilProc[nFilial, 1], cAnoMes, Nil, "2", nFatTot, 0.00, 0.00, nFatTot, 0.00, 0.00, aTabS033 )
						EndIf
			            cTextoLog := ""//ideal seria financeiro gerar memoria em tabela fisica e aqui instruirmos consulta desta, assim como fora feito no faturamento
						If aScan( aLogDes[2], {|x| x == cTextoLog } ) == 0
							aAdd( aLogDes[2], cTextoLog )
						EndIf
	            	//Se verifica Faturamento e/ou Financeiro
	            	Else
						//Entra na funcao do Faturamento para buscar os valores das notas fiscais de saida
						//na tabela SD2 para verificar o faturamento da filial na competencia. A funcao
						//do faturamento retorna os dados gravados em um alias temporario
						cSvFilAnt := cFilAnt
						cFilAnt	  := aFilProc[nFilial, 1]
						cAliasFat := RhInssPat( SubStr(cAnoMes,5,2)+SubStr(cAnoMes,1,4), aFilProc[nFilial, 1],,,.T.)
						cFilAnt	  := cSvFilAnt
						If !Empty( cAliasFat )
							dbSelectArea( cAliasFat )
							(cAliasFat)->( dbGoTop() )
							While (cAliasFat)->( !EoF() )
				                cCodAti		:= (cAliasFat)->CODATV
				                cTipFat 	:= "1"
				                nAliq		:= SpedPCCG1( cCodAti, dDataRef )
				                nFatTot 	:= (cAliasFat)->TOTAL 		// Total
				                nFatTotLiq 	:= (cAliasFat)->TOTALLIQ	// Total
				                nFatTotDev 	:= (cAliasFat)->TOTLIQDEV	// Total devolucao
				                nFatTotExp 	:= (cAliasFat)->TOTLIQEXP  	// Total exportacao
				                nFatRecB	:= (cAliasFat)->TOTCODAT	// Total do codigo de atividade bruto
				                nFatRecL	:= (cAliasFat)->TCODATLQ	// Total do codigo de atividade liquido
				                nFatExc		:= (cAliasFat)->TCATVDEV	// Total devolucoes do codigo de atividade
				                nFatExp		:= (cAliasFat)->TLQCATVEXP	// Total exportacoes do codigo de atividade
				                nFatBas 	:= (cAliasFat)->TCDEVEXP 	// Total codigo de atividade - devolucoes - exportacoes (base calculo)
				                If (cAliasFat)->(ColumnPos("CONTARECE")) > 0
				                	cConta		:= (cAliasFat)->CONTARECE 	// Conta de Receita / Conta Contábil
                                EndIf
                                //Calcula a contribuicao com base na aliquota encontrada
				                If nAliq > 0
					                nContr	:= ( nFatBas * ( nAliq/100 ) )
					  			EndIf
				                //Grava a informacao do recolhimento devido na tabela auxiliar S033.
								If nFatBas > 0
									fGravaS033( aFilProc[nFilial, 1], cAnoMes, cCodAti, cTipFat, nFatBas, nAliq, nContr, nFatRecB, nFatExc, nFatExp, aTabS033, nFatRecB - nFatRecL, cConta )
									//Chama fCarrTab para recarregar tabela auxiliar S033
									aTabS033 := {}
									fCarrTab( @aTabS033, "S033", dDataRef, .T. )
								Else
								 //Senao tiver faturamento com produtos com cod atividade, mas tiver algum faturamento gravar tabela S033, com tipo 2 (produtos nao desonerados)
									If nFatTot > 0 .Or. nFatTotDev > 0
										If Empty(cCodAti)
											cTipFat 	:= "2"
										Else
											cTipFat 	:= "1"
										EndIf
										fGravaS033( aFilProc[nFilial, 1], cAnoMes, cCodAti, cTipFat, nFatBas, nAliq, nContr, nFatRecB, nFatExc, nFatExp, aTabS033, nFatRecB - nFatRecL, cConta )
										//Chama fCarrTab para recarregar tabela auxiliar S033
										aTabS033 := {}
										fCarrTab( @aTabS033, "S033", dDataRef, .T. )
									EndIf
								EndIf

								//Caso algum Codigo de Atividade fique com valor Base zerado devido exportacoes e devolucoes, ou no caso
								//de haver somente valores nao desonerados, o total da atividade processada sera atribuido a variavel
								//auxiliar nFatRecAux para posterior deducao do Total Geral para que o valor da Receita Tipo 2 saia correto
								nFatRecAux += If( nFatBas == 0, nFatTotLiq, 0 )

								(cAliasFat)->( dbSkip() )
							End While
							//Faz a totalizacao da faturamento da filial gravadas na tabela S033
							aEval(aTabS033, {|aTabS033| If( aTabS033[2] + aTabS033[6] == aFilProc[nFilial, 1] + "1", nTotCont += aTabS033[10], Nil ) } )
							aEval(aTabS033, {|aTabS033| If( aTabS033[2] + aTabS033[6] == aFilProc[nFilial, 1] + "1", nTotCLiq += aTabS033[7], Nil ) } )
							aEval(aTabS033, {|aTabS033| If( aTabS033[2] + aTabS033[6] == aFilProc[nFilial, 1] + "1", nTotDev += aTabS033[11], Nil ) } )
							aEval(aTabS033, {|aTabS033| If( aTabS033[2] + aTabS033[6] == aFilProc[nFilial, 1] + "1", nTotExp += aTabS033[12], Nil ) } )
							If Len(aTabS033) >= 1 .And. Len(aTabS033[1]) >= 13
								aEval(aTabS033, {|aTabS033| If( aTabS033[2] + aTabS033[6] == aFilProc[nFilial, 1] + "1", nTotImp += aTabS033[13], Nil ) } )
							EndIf
							//Entra na funcao do Financeiro para buscar os valores dos titulos de acordo
							//com a filial logada. A funcao nao permite passar a filial como parametro
							//entao a variavel cFilAnt sera alterada de acordo com a filial em processamento.
							//A funcao retorna o valor da receita total.
							If nVerFatFin == 4
								cSvFilAnt := cFilAnt
								cFilAnt	  := aFilProc[nFilial, 1]
								nVlAux    := FTotF100( Val( SubStr( cAnoMes, 5, 2 ) ), Val( SubStr( cAnoMes, 1, 4 ) ) )
								nFatTot   += nVlAux
								nFatTotLiq+= nVlAux
								cFilAnt	  := cSvFilAnt
					            cTextoLog := STR0014 + SubStr( cAnoMes, 5, 2 )  +  SubStr( cAnoMes, 1, 4 ) + STR0016//"- Verifique a tabela do Financeiro FINDES"##" gravada na pasta system"
								If aScan( aLogDes[2], {|x| x == cTextoLog } ) == 0
									aAdd( aLogDes[2], cTextoLog )
								EndIf
							EndIf
							//Se o total de faturamento da filial for maior do que os registros gravados
							//significa que ha faturamento de atividades que nao estao enquadradas na Lei
							//Esse registro deve ser gravado na tabela auxiliar com o tipo de receita 2
							nValDev := If( nFatTotDev > nTotDev, nFatTotDev, nTotDev )
							nValExp := If( nFatTotExp > nTotExp, nFatTotExp, nTotExp )

							If nFatTotLiq - nFatTotDev - nFatTotExp >= nTotCLiq .And. ( ( nFatTotLiq - nTotCLiq - nFatRecAux - ( nFatTotDev - nTotDev ) - ( nFatTotExp - nTotExp ) ) > 0 .Or. ( nFatTot - nTotCont ) > 0 )
								fGravaS033( aFilProc[nFilial, 1], cAnoMes, Nil, "2", ( nFatTotLiq - nTotCLiq - nValExp - nValDev ), 0.00, 0.00, ( nFatTot - nTotCont ), ( nValDev - nTotDev ), ( nValExp - nTotExp ), aTabS033, ( nFatTot - nFatTotLiq - nTotImp ) )
							EndIf

							cTextoLog := STR0048 + "(" + SubStr( cAnoMes, 5, 2 )  +  SubStr( cAnoMes, 1, 4 ) + ")"
							If aScan( aLogDes[2], {|x| x == cTextoLog } ) == 0
								aAdd( aLogDes[2], cTextoLog )
							EndIf
						EndIf

						If Select(cAliasFat) > 0

							(cAliasFat)->( dbCloseArea() )
						EndIf

					EndIf
	            	//Sai do For dos tipos de contratos pois ja alimentou a S033 com os valores da competencia
	            	Exit
				EndIf
			Next nTpContr
		EndIf
	Next nFilial

	//Chama fCarrTab para recarregar tabela auxiliar S033
	aTabS033 := {}
	RstGpexIni()
	fCarrTab( @aTabS033, "S033", dDataRef, .T.,, .T. )
ElseIf !lFolha .And. nVerFatFin == 1 .And. Empty(aTab13Sal)
	//Faz a busca dos valores da S033 de dezembro do ano anterior até novembro do ano atual
	//para geração do registro de 13/2016 para uso no cálculo da desoneração do 13º salário
	While cRefAux >= cLimRef
		aTabS033 := {}
		fCarrTab( @aTabS033, "S033", , .T., cRefAux )

		For nCont := 1 To Len(aTabS033)
			If ( nPosAux := aScan(aAuxS033, {|x| x[1] + x[2] + x[10]+x[11] == aTabS033[nCont, 2] + aTabS033[nCont, 5] + aTabS033[nCont, 14] + aTabS033[nCont, 6] }) ) == 0
				aAdd( aAuxS033, { aTabS033[nCont, 2], aTabS033[nCont, 5], aTabS033[nCont, 7], aTabS033[nCont, 8], aTabS033[nCont, 9], aTabS033[nCont, 10], aTabS033[nCont, 11], aTabS033[nCont, 12], aTabS033[nCont, 13], aTabS033[nCont, 14] ,aTabS033[nCont, 6]  } )
			Else
				aAuxS033[nPosAux, 3] += aTabS033[nCont, 07]
				aAuxS033[nPosAux, 5] += aTabS033[nCont, 09]
				aAuxS033[nPosAux, 6] += aTabS033[nCont, 10]
				aAuxS033[nPosAux, 7] += aTabS033[nCont, 11]
				aAuxS033[nPosAux, 8] += aTabS033[nCont, 12]
				aAuxS033[nPosAux, 9] += aTabS033[nCont, 13]
			EndIf
		Next nCont

		cRefAux := SubMesAno( cRefAux )
	End While

	//Grava o registro 13/2016 na S033
	For nCont := 1 To Len(aAuxS033)
		fGravaS033( aAuxS033[nCont, 1], SubStr(cPeriodo, 1, 4) + "13", aAuxS033[nCont, 2], aAuxS033[nCont, 11], aAuxS033[nCont, 3], aAuxS033[nCont, 4], aAuxS033[nCont, 5], aAuxS033[nCont, 6], aAuxS033[nCont, 7], aAuxS033[nCont, 8], aTabS033, aAuxS033[nCont, 9], aAuxS033[nCont, 10] )
	Next nCont
	
	RstGpexIni()
	//Chama fCarrTab para recarregar tabela auxiliar S033 - 13o. salario
	fCarrTab( @aTab13Sal, "S033", , , SubStr( cPeriodo, 1, 4 ) + "13" )
ElseIf !lFolha .And. nVerFatFin != 1
	//Atualiza os dados de 13o. Salario na Tabela S033
	Gpm13AtuS033(nVerFatFin,dDataRef)

	//Recarrega a tabela para atualizar os array aTab13Sal que ja estava carregado
	aTab13Sal := {}
	fCarrTab( @aTab13Sal, "S033", ,.T., SubStr( cPeriodo, 1, 4 ) + "13" )

EndIf

cAliasSRA 	:= "QSRA"
If ( Select( cAliasSRA ) > 0 )
	( cAliasSRA )->( dbCloseArea() )
EndIf
cCposQuery 	:= "SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CC, SRA.RA_CATFUNC, SRA.RA_TPCONTR"
If lTemInssAut
	cCposQuery += ", SRA.RA_INSSAUT"
EndIf
If lTemItem
	cCposQuery += ", SRA.RA_ITEM"
EndIf
If lTemClvl
	cCposQuery += ", SRA.RA_CLVL"
EndIf
cCposQuery := "% " + cCposQuery + " %"
cCatQuery   := "%"

For nReg := 1 to Len(cCateg)
	If Subs(cCateg,nReg,1) # "*" .and. Subs(cCateg,nReg,1) # " "
		aAdd(aCateg,Subs(cCateg,nReg,1))
	EndIf
	cCatQuery += "'"+Subs(cCateg,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCateg)
		cCatQuery += ","
	EndIf
Next nReg

cCatQuery += "%"

cWhere := ""

If !Empty(cFilRange)
	cWhere :=  cFilRange + " AND "
EndIf

If !Empty(cMatRange)
	cWhere += cMatRange + " AND "
EndIf

cWhere		:= "%" + cWhere + "%"

BeginSql alias cAliasSRA
	SELECT %exp:cCposQuery%
	FROM %table:SRA% SRA
	WHERE  %exp:cWhere%
		   SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%)
		       AND SRA.RA_PROCES = %exp:cProcesso%
   			   AND SRA.%notDel%
	ORDER BY SRA.RA_FILIAL, SRA.RA_MAT
EndSql

BeginSql alias cAliasTMP
	SELECT COUNT(*) as NROREG
	FROM %table:SRA% SRA
	WHERE  %exp:cWhere%
		   SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%)
		       AND SRA.RA_PROCES = %exp:cProcesso%
   			   AND SRA.%notDel%
EndSql

While (cAliasTMP)->( !Eof() )
	nRegProc += (cAliasTMP)->(NROREG)
	(cAliasTMP)->( dbSkip() )
EndDo

( cAliasTMP )->( dbCloseArea() )

If !lRobo
	//Inicia a regua de processamento
	oSelf:SaveLog( STR0001 + " - " + STR0008 ) //"Desoneração da Folha de Pagamento"##"Inicio do processamento"
	oSelf:SetRegua1(nRegProc)
EndIf

Begin Sequence
	//Faz o While dos funcionarios selecionadas na parametrizacao
	While ( cAliasSRA )->( !EoF() )
		//Aborta o Calculo
		If !lRobo .And. oSelf:lEnd
			Break
		EndIf

	    If !lRobo
			//Atualiza regua de processamento
			oSelf:IncRegua1( OemToAnsi(STR0019) + ( cAliasSRA )->RA_FILIAL + " - " + ( cAliasSRA )->RA_MAT + If(lOfusca, "", " - " + ( cAliasSRA )->RA_NOME ))//"Verificando o funcionário: "
		EndIf

        //Se a filial for diferente da anterior, carrega codigo de verbas e parametro 14
		If cLastFil != ( cAliasSRA )->RA_FILIAL
			cLastFil := ( cAliasSRA )->RA_FILIAL
			If !FP_CODFOL( @aCodFol, ( cAliasSRA )->RA_FILIAL )
				( cAliasSRA )->( dbSkip() )
				Loop
			EndIf
			fInssEmp( ( cAliasSRA )->RA_FILIAL, @aTabInss, Nil, cAnoMes )
			aPdMat := {}
			aPdAfa := {}
			If !Empty(P_ENCEMP) .and. ( P_ENCEMP == '1' .or. aCodFol[148,1] $ P_ENCEMP )
				If !Empty(P_DEDMAT)
					cAux := ""
					If !(P_DEDMAT == '1') .and. !("*" $ P_DEDMAT)
						For nX := 1 to Len(P_DEDMAT) step 3
							cVerba := SubStr(P_DEDMAT,nX,3)
							If RetValSrv( cVerba, ( cAliasSRA )->RA_FILIAL, "RV_INSS" ) == "S"
								cAux += cVerba + "*"
								aAdd(aPdMat, cVerba)
							EndIf
						Next nX
						P_DEDMAT := cAux
					ElseIf P_DEDMAT == "1"
						aPdMat := fCarPdMat() //Carrega as verbas de maternidade que não devem ser consideradas na composição dos encargos
						For nX := 1 to Len(aPdMat)
							cAux += aPdMat[nX] + "*"
						Next nX
						P_DEDMAT := cAux
					EndIf 
				EndIf
			Else
				P_DEDMAT := ""
			EndIf
			If !Empty(P_ENCEMPAF) .and. ( P_ENCEMPAF == '1' .or. aCodFol[148,1] $ P_ENCEMPAF )
				aPdAfa := fCarPdAfa() //Carrega as verbas de afastamento que não devem ser consideradas na composição dos encargos
			EndIf

			cPdAux := ""

			For nX := 1 to Len(aPdMat)
				cPdAux += ", '" + aPdMat[nX] + "'"
			Next nX

			For nX := 1 to Len(aPdAfa)
				cPdAux += ", '" + aPdAfa[nX] + "'"
			Next nX
		EndIf

		If Empty(aCodFol)
			( cAliasSRA )->( dbSkip() )
		   	Loop
		EndIf

		SRA->( DbSeek( ( cAliasSRA )->RA_FILIAL + ( cAliasSRA )->RA_MAT ) )

		If cLastEmp != FwCodEmp()
			cLastEmp	:= FwCodEmp()
			lFirst	 	:= .T.
			lLogRec 	:= .F.
			lLogRec13 	:= .F.
			nBasDes	 	:= 0
			nEmpFatDes	:= 0
			nEmpFatFol	:= 0
			nEmpFatTot	:= 0
			nFatFol	 	:= 0
			nTot973	 	:= 0
		EndIf

		//Reinicializa variaveis
		aEncM013    := {}
		aPd			:= {}
		cTpC		:= If( ( cAliasSRA )->RA_TPCONTR $ " *1*3", "1", "2" )
		cRecFatEmp 	:= aTabInss[27, Val( cTpC )]//X14_RECFAT
		nAv13Des 	:= 0
		nAv13Resc	:= 0
		nBase318	:= 0
		nBaseINSS	:= 0
		nSalCont    := 0
		nSalCon13	:= 0
		nValBasInss	:= 0
		nVl13Des	:= 0
		nVl13Resc	:= 0

      //Somente faz o calculo quando recolher a contribuicao previdenciaria sobre o faturamento
		If cRecFatEmp $ "S*M*C" .Or. (cPeriodo > cOneFol .And. !Empty(cOneFol) .And. SubStr(cOneFol,1,4) == SubStr(cPeriodo,1,4) )

			cAliasSRC 	:= "QSRCDES"
			If ( Select( cAliasSRC ) > 0 )
				( cAliasSRC )->( dbCloseArea() )
			EndIf
			cCposQuery := "% "
	  		For nField := 1 To nSrcFields
				cCposQuery += aSrcFields[ nField , 01 ] + ", "
			Next nField

			cCposQuery += "R_E_C_N_O_ RECNO %"
			cWhere		:=	" ( SRC.RC_FILIAL = '" + ( cAliasSRA )->RA_FILIAL + "' AND SRC.RC_MAT = '" + ( cAliasSRA )->RA_MAT + "' AND " +;
							" SRC.RC_PROCES = '" + cProcesso + "' AND SRC.RC_PERIODO = '" + cPeriodo + "' AND SRC.RC_ROTEIR = '" + cRoteiro + "' AND SRC.RC_SEMANA = '" + cSemana + "' AND " +;
							" SRC.RC_PD IN ('" + aCodFol[013,1] + "', '" + aCodFol[014,1] + "', '" + aCodFol[019,1] + "', '" + aCodFol[020,1] + "', '" + aCodFol[024,1] + "', '" +;
											aCodFol[114,1] + "', '" + aCodFol[221,1] + "', '" + aCodFol[225,1] + "', '" + aCodFol[318,1] + "', '" +;
											aCodFol[350,1] + "', '" + aCodFol[353,1] + "', '" + aCodFol[991,1] + "', '" + aCodFol[1385,1] + "'" +;
											If(Empty(cPdAux), " ) ) ", cPdAux + " ) ) ") 
											
			cWhere		:= "%" + cWhere + "%"

			BeginSql alias cAliasSRC
				SELECT %exp:cCposQuery%
				FROM %table:SRC% SRC
				WHERE  %exp:cWhere%
	   				   AND SRC.%notDel%
				ORDER BY SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_PD
			EndSql

			For nField := 1 To nSrcFields
				If !( aSrcFields[ nField , 02 ] == "C" )
					TcSetField(cAliasSRC,aSrcFields[nField,01],aSrcFields[nField,02],aSrcFields[nField,03],aSrcFields[nField,04])
				EndIf
			Next nField

			//Faz o While dos lancamentos mensais do funcionario para encontrar a base de calculo
			//para apuracao da contribuicao previdenciaria
			While ( cAliasSRC )->( !EoF() )
				If lFolha
					If ( cAliasSRC )->RC_PD == aCodFol[013,1]//Sal Contr. Ate Limite Base
					    nSalCont +=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[014,1]//Sal Contr. Acima Limite Base
						nSalCont +=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[019,1]//Base Inss Ate Lim p/ 13o. Sal.
						nSalCon13 +=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[020,1]//Base Inss Aci Lim p/ 13o. Sal.
						nSalCon13 +=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[114,1]//13§ na Indenizacao Rescisao
						nAv13Resc  :=  Int( ( cAliasSRC )->RC_HORAS )
						nVl13Resc  :=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[221,1]//Base Inss Aut./Pro-Labore 15%
						nSalCont +=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[225,1]//Base Inss Aut./Pro-Labore 20%
						nSalCont +=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[318,1]//Salario do Mes
						dDataPg	 := ( cAliasSRC )->RC_DATA
						nBase318 += ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[350,1]//Base do INSS P.FISICA
						nSalCont +=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[353,1]//Base de INSS P.JURIDICA
						nSalCont +=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[991,1]//Base Inss Antes Desoneracao p/ 13o. Sal.
						nAv13Des  :=  Int( ( cAliasSRC )->RC_HORAS )
						nVl13Des  :=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[1385,1]//Base Inss Antes Oneracao p/ 13o. Sal.
						nVl13Des +=  ( cAliasSRC )->RC_VALOR
						lOnera := .T.
					ElseIf !Empty(aPdAfa) .and. ( aScan(aPdAfa, {|x| x == ( cAliasSRC )->RC_PD} ) ) > 0
						nSalCont -=  ( cAliasSRC )->RC_VALOR
					ElseIf !Empty(aPdMat) .and. ( aScan(aPdMat, {|x| x == ( cAliasSRC )->RC_PD} ) ) > 0
						If RetValSRV(( cAliasSRC )->RC_PD, ( cAliasSRC )->RC_FILIAL, "RV_REF13") == "S"
							nSalCon13 -=  ( cAliasSRC )->RC_VALOR
						Else
							nSalCont -=  ( cAliasSRC )->RC_VALOR
						EndIf
					EndIf
				Else
					If ( cAliasSRC )->RC_PD == aCodFol[019,1]//Base Inss Ate Lim p/ 13o. Sal.
						nSalCon13 +=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[020,1]//Base Inss Aci Lim p/ 13o. Sal.
						nSalCon13 +=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[024,1]//Parcela Final 13§ Sal
						dDataPg := ( cAliasSRC )->RC_DATA
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[991,1]//Base Inss Antes Desoneracao p/ 13o. Sal.
						nAv13Des  :=  Int( ( cAliasSRC )->RC_VALOR )
						nVl13Des  :=  ( cAliasSRC )->RC_VALOR
					ElseIf ( cAliasSRC )->RC_PD == aCodFol[1385,1]//Base Inss Antes Oneracao p/ 13o. Sal.
						nVl13Des +=  ( cAliasSRC )->RC_VALOR
						lOnera := .T.
					ElseIf !Empty(aPdMat) .and. ( aScan(aPdMat, {|x| x == ( cAliasSRC )->RC_PD} ) ) > 0
						If RetValSRV(( cAliasSRC )->RC_PD, ( cAliasSRC )->RC_FILIAL, "RV_REF13") == "S"
							nSalCon13 -=  ( cAliasSRC )->RC_VALOR
						EndIf
					EndIf
				EndIf
				( cAliasSRC )->( !dbSkip() )
			End While

			If ( cAliasSRA )->RA_CATFUNC == "S"
				cAliasSRD 	:= "QSRDDES"
				If ( Select( cAliasSRD ) > 0 )
					( cAliasSRD )->( dbCloseArea() )
				EndIf
				cCposQuery := "% "
		  		For nField := 1 To nSrdFields
					cCposQuery += aSrdFields[ nField , 01 ] + ", "
				Next nField
				cCposQuery += "R_E_C_N_O_ RECNO %"
				cWhere		:=	" ( SRD.RD_FILIAL = '" + ( cAliasSRA )->RA_FILIAL + "' AND SRD.RD_MAT = '" + ( cAliasSRA )->RA_MAT + "' AND "+;
								" SRD.RD_PROCES = '" + cProcesso + "' AND SRD.RD_PERIODO = '" + cPeriodo + "' AND SRD.RD_ROTEIR = '" + cRoteiro + "' AND "+;
								" SRD.RD_PD IN ('" + aCodFol[013,1] + "', '" + aCodFol[014,1] + "', '" + aCodFol[019,1] + "', '" + aCodFol[020,1] + "', '" + aCodFol[024,1] + "', '" +;
												aCodFol[114,1] + "', '" + aCodFol[221,1] + "', '" + aCodFol[225,1] + "', '" + aCodFol[318,1] + "', '" +;
												aCodFol[350,1] + "', '" + aCodFol[353,1] + "', '" + aCodFol[991,1] + "'" +;
											If(Empty(cPdAux), " ) ) ", cPdAux + " ) ) ") 
				cWhere		:= "%" + cWhere + "%"

				BeginSql alias cAliasSRD
					SELECT %exp:cCposQuery%
					FROM %table:SRD% SRD
					WHERE  %exp:cWhere%
		   				   AND SRD.%notDel%
					ORDER BY SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_PD
				EndSql

				For nField := 1 To nSrdFields
					If !( aSrdFields[ nField , 02 ] == "C" )
						TcSetField(cAliasSRD,aSrdFields[nField,01],aSrdFields[nField,02],aSrdFields[nField,03],aSrdFields[nField,04])
					EndIf
				Next nField

				//Faz o While dos lancamentos mensais do funcionario para encontrar a base de calculo
				//para apuracao da contribuicao previdenciaria
				While ( cAliasSRD )->( !EoF() )
					If lFolha
						If ( cAliasSRD )->RD_PD == aCodFol[013,1]//Sal Contr. Ate Limite Base
						    nSalCont +=  ( cAliasSRD )->RD_VALOR
						ElseIf ( cAliasSRD )->RD_PD == aCodFol[014,1]//Sal Contr. Acima Limite Base
							nSalCont +=  ( cAliasSRD )->RD_VALOR
						ElseIf ( cAliasSRD )->RD_PD == aCodFol[019,1]//Base Inss Ate Lim p/ 13o. Sal.
							nSalCon13 +=  ( cAliasSRD )->RD_VALOR
						ElseIf ( cAliasSRD )->RD_PD == aCodFol[020,1]//Base Inss Aci Lim p/ 13o. Sal.
							nSalCon13 +=  ( cAliasSRD )->RD_VALOR
						ElseIf ( cAliasSRD )->RD_PD == aCodFol[114,1]//13§ na Indenizacao Rescisao
							nAv13Resc  :=  Int( ( cAliasSRD )->RD_HORAS )
							nVl13Resc  :=  ( cAliasSRD )->RD_VALOR
						ElseIf ( cAliasSRD )->RD_PD == aCodFol[221,1]//Base Inss Aut./Pro-Labore 15%
							nSalCont +=  ( cAliasSRD )->RD_VALOR
						ElseIf ( cAliasSRD )->RD_PD == aCodFol[225,1]//Base Inss Aut./Pro-Labore 20%
							nSalCont +=  ( cAliasSRD )->RD_VALOR
						ElseIf ( cAliasSRD )->RD_PD == aCodFol[350,1]//Base do INSS P.FISICA
							nSalCont +=  ( cAliasSRD )->RD_VALOR
						ElseIf ( cAliasSRD )->RD_PD == aCodFol[353,1]//Base de INSS P.JURIDICA
							nSalCont +=  ( cAliasSRD )->RD_VALOR
						ElseIf ( cAliasSRD )->RD_PD == aCodFol[991,1]//Base Inss Antes Desoneracao p/ 13o. Sal.
							nAv13Des  :=  Int( ( cAliasSRD )->RD_HORAS )
							nVl13Des  :=  ( cAliasSRD )->RD_VALOR
						ElseIf !Empty(aPdAfa) .and. ( aScan(aPdAfa, {|x| x == ( cAliasSRD )->RD_PD} ) ) > 0
							nSalCont -=  ( cAliasSRD )->RD_VALOR
						ElseIf !Empty(aPdMat) .and. ( aScan(aPdMat, {|x| x == ( cAliasSRD )->RD_PD} ) ) > 0
							If RetValSRV(( cAliasSRD )->RD_PD, ( cAliasSRD )->RD_FILIAL, "RV_REF13") == "S"
								nSalCon13 -=  ( cAliasSRD )->RD_VALOR
							Else
								nSalCont -=  ( cAliasSRD )->RD_VALOR
							EndIf
						EndIf
					Else
						If ( cAliasSRD )->RD_PD == aCodFol[019,1]//Base Inss Ate Lim p/ 13o. Sal.
							nSalCon13 +=  ( cAliasSRD )->RD_VALOR
						ElseIf ( cAliasSRD )->RD_PD == aCodFol[020,1]//Base Inss Aci Lim p/ 13o. Sal.
							nSalCon13 +=  ( cAliasSRD )->RD_VALOR
						ElseIf ( cAliasSRD )->RD_PD == aCodFol[991,1]//Base Inss Antes Desoneracao p/ 13o. Sal.
							nAv13Des  :=  Int( ( cAliasSRD )->RD_VALOR )
							nVl13Des  :=  ( cAliasSRD )->RD_VALOR
						ElseIf !Empty(aPdMat) .and. ( aScan(aPdMat, {|x| x == ( cAliasSRD )->RD_PD} ) ) > 0
							If RetValSRV(( cAliasSRD )->RD_PD, ( cAliasSRD )->RD_FILIAL, "RV_REF13") == "S"
								nSalCon13 -=  ( cAliasSRD )->RD_VALOR
							EndIf
						EndIf
					EndIf
					( cAliasSRD )->( !dbSkip() )
				End While
			EndIf

			If lFolha
				//Calcula a aliquota reduzida que sera aplicada na base do INSS e os valores das receitas
				If !lOnera
					aCalcDes := fPerFatEmp( cRecFatEmp, 0, aTabInss[ 1, Val( cTpC ) ], aTabS033, dDataRef ,, FWCodEmp())
				ElseIf cPeriodo > cOnefol .And. !Empty(cOneFol) .And. SubStr(cOneFol,1,4) == SubStr(cPeriodo,1,4)
					aCalcDes := fAliqOnera(cOnefol, aTabInss[ 1, Val( cTpC ) ], FwCodEmp())
				EndIf
	           	nPerFatEmp 	:= aCalcDes[1]//Aliquota reduzida
				nRecOut		:= aCalcDes[2]//Receitas de outras atividades
				nRecBruto	:= aCalcDes[3]//Receita bruta
				nRecDes		:= aCalcDes[4]//Receitas de atividades desoneradas
				nExpDes		:= aCalcDes[9]//total das exportações tipo 1
				nExpNDes	:= aCalcDes[10]//total das exportações tipo 2
				lAliqPad	:= nPerFatEmp == aTabInss[ 1, Val( cTpC ) ] //Indica que sera aplicada a aliquota padrao

				If lOnera .Or. (cRecFatEmp $ "S*M*C" .And. (cPeriodo <= cOneFol .Or. Empty(cOneFol) ))
					If cPeriodo > cOnefol .And. !Empty(cOneFol) .And. SubStr(cOneFol,1,4) == SubStr(cPeriodo,1,4)
						If nPerFatEmp > 0
							cRecFatEmp := "oM"
						Else
							cRecFatEmp := "oS"
						Endif
					EndIf

					//Cria o resumo das bases de calculo utilizadas para encontrar a aliquota reduzida no calculo misto
					If cRecFatEmp $ "M*C*oM*oS" .And. !lLogRec
						lLogRec := .T.
						If lTemGC .And. lTemEmp
							aAdd( aLogDes[1], "")
							aAdd( aLogDes[1], STR0047 + cLastEmp )//"Empresa: "
						EndIf
						//Valida se o percentual reduzido e' maior do que zero e exibe o calculo efetuado para encontrar o %
						If nPerFatEmp > 0
							aAdd( aLogDes[1], OemToAnsi(STR0020) )//"Composição do cálculo para apurar a alíquota reduzida: "
							aAdd( aLogDes[1], OemToAnsi(STR0021) + cValToChar( Transform( nRecOut, "@E 99,999,999,999.99" ) ) )//" - Receitas de outras atividades (Tipo 2): R$ "
							aAdd( aLogDes[1], OemToAnsi(STR0022) + cValToChar( Transform( nRecBruto, "@E 99,999,999,999.99" ) ) )//" - Receita bruta total: R$ "
							aAdd( aLogDes[1], OemToAnsi(STR0023) + cValToChar( Transform( nRecOut, "@E 99,999,999,999.99" ) ) + " / R$ " + cValToChar( Transform( nRecBruto, "@E 99,999,999,999.99" ) ) + " = " + cValToChar( nRecOut/nRecBruto ) )//" - Receitas de outras atividades / Receita bruta total: R$ "
							aAdd( aLogDes[1], OemToAnsi(STR0024) + cValToChar( nRecOut/nRecBruto ) )//" - Coeficiente de redução: "
							aAdd( aLogDes[1], OemToAnsi(STR0025) + cValToChar( aTabInss[ 1, Val( cTpC ) ] * 100 ) + " %" )//" - Alíquota padrão: "

							If lAliqPad .And. nRecBruto == 0
								aAdd( aLogDes[1], OemToAnsi(STR0041) )//" - Será aplicada a Alíquota Padrão, pois não há receita bruta no mês."
							ElseIf lAliqPad
								aAdd( aLogDes[1], OemToAnsi(STR0040) )//" - Será aplicada a Alíquota Padrão, pois as Receitas de atividades não desoneradas ultrapassaram o limite de 95%"
							Else
								aAdd( aLogDes[1], OemToAnsi(STR0026) + cValToChar( nRecOut/nRecBruto ) + " X " + cValToChar( aTabInss[ 1, Val( cTpC ) ] * 100 ) + " % = " + cValToChar( Round( nPerFatEmp * 100, 6 ) ) + " %" )//" - Coeficiente de redução X Alíquota Padrão: "
								aAdd( aLogDes[1], OemToAnsi(STR0027) + cValToChar( Round( nPerFatEmp * 100, 6 ) ) + " %" )//" - Alíquota reduzida: "
							EndIf

						//Exibe a mensagem que nao sera efetuado o calculo da contribuicao patronal sobre a folha devido o %
						Else
							nRecBruto := nRecBruto - ( nExpDes + nExpNDes )
							nRecDes   := nRecDes   - nExpDes
							aAdd( aLogDes[1], OemToAnsi(STR0028) + " " + OemToAnsi(STR0032) )//"Cálculo sobre a folha de pagamento NÃO será efetuado"##"pois a receita desonerada ultrapassou o limite de 95%"
							aAdd( aLogDes[1], OemToAnsi(STR0033) )//"em relação a receita total:"
							aAdd( aLogDes[1], OemToAnsi(STR0029) + cValToChar( Transform( nRecDes, "@E 99,999,999,999.99" ) ) )//" - Receitas de atividades desoneradas (Tipo 1): R$ "
							aAdd( aLogDes[1], OemToAnsi(STR0022) + cValToChar( Transform( nRecBruto, "@E 99,999,999,999.99" ) ) )//" - Receita bruta total: R$ "
							aAdd( aLogDes[1], OemToAnsi(STR0030) + cValToChar( Transform( nRecDes, "@E 99,999,999,999.99" ) ) + " / R$ " + cValToChar( Transform( nRecBruto, "@E 99,999,999,999.99" ) ) + " = " + cValToChar( nRecDes/nRecBruto ) )//" - Receitas de atividades desoneradas / Receita bruta total: R$ "
							aAdd( aLogDes[1], OemToAnsi(STR0031) + cValToChar( ( nRecDes/nRecBruto ) * 100 ) + " %" )//" - Percentual: "
						EndIf
					EndIf

			        //Quando a empresa tiver faturamento misto, deve aplicar a aliquota reduzida no salario do mes
			        //+ os avos de 13 adquiridos apos o inicio da desoneracao da folha
			        If cRecFatEmp $ "M*C*oM*oS"
				        nBaseINSS := Round( nSalCont + ( nSalCon13 - nVl13Des ), 2 )
			        //Quando a empresa tiver faturamento exclusivo sobre o faturamento, nao deve calcular a
			        //contribuicao sobre a folha
			        Else
				        nBaseINSS := 0.00
			        EndIf

					If cRecFatEmp == "oS" .Or. cRecFatEmp == "oM"
						If cRecFatEmp == "oM"
							//Aplica a base do salario do mes na aliquota padrao
							nContInss := Round( nBaseINSS * aTabInss[1, Val( cTpC )], 2 )
							//O valor dos avos de 13o. adquiridos na desoneracao, que tera a aliquota reduzida
							nCont13  :=  Round( nVl13Des * nPerFatEmp, 2)
							//A contribuicao previdenciaria sera a soma dos dois calculos
							nContrib := ( nContInss + nCont13 )
						Else
							//Caso a empresa era desonerada exclusivamente pelo faturamento o valor da contribuicao sera somente o nBaseINSS (subtrai o ID 1385)
							//Aplica a base do salario do mes na aliquota padrao
							nContrib := Round( nBaseINSS * aTabInss[1, Val( cTpC )], 2 )
						Endif
					Else
						//Aplica a base do salario do mes na aliquota reduzida
						nContInss := Round( nBaseINSS * nPerFatEmp, 2)
						//O valor dos avos de 13o. adquiridos antes do inicio da desoneracao tem tributacao antiga
						nCont13  :=  Round( nVl13Des * aTabInss[1, Val( cTpC )], 2 )
						//A contribuicao previdenciaria sera a soma dos dois calculos
						nContrib := ( nContInss + nCont13 )
					Endif

			        //Aplica a base do salario do mes na aliquota reduzida
					nContInss := Round( nBaseINSS * nPerFatEmp, 2)

					If lRatDes .And. lFirst .And. ( Empty(cOneFol) .Or. cPeriodo <= cOneFol )
						lFirst	:= .F.
						For nCont := 1 To Len(aTabS033)
							If lTemGC .And. lTemEmp .And. cLastEmp != SubStr( aTabS033[nCont, 2], nIniEmp, nTamEmp )
								Loop
							EndIf
							//Apura a receita bruta total da empresa
							nEmpFatTot += aTabS033[nCont, 7]
							If aTabS033[nCont, 6] == "1"
								//Apura a receita bruta que e' sobre as atividades beneficiadas da Lei no. 12.546/2011
								nEmpFatDes += aTabS033[nCont, 7]
							ElseIf  aTabS033[nCont, 10] > 0
								//Apura a receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
								nEmpFatFol += aTabS033[nCont, 7]
							EndIf
						Next nCont

					    //Verifica se a receita desonerada da empresa e' superior a 95% do total
						lRecDesTot := ( nRecDes / nRecBruto >= 0.95 )
						//Somente havera recolhimento sobre o Faturamento se o total nao desonerado da empresa for MENOR que 95% do total geral
						lGera := ( nRecOut / nRecBruto < 0.95 )

						If lGera
							If lRecDesTot
								//Se a receita bruta da atividade desonerada for maior do que 95% do total devera ser
								//considerado a receita bruta da atividade nao desonerada.Sera aplicado a proporcionalidade
								//das aliquotas das atividades desoneradas conforme correspondencia do percentual da receita
								//desonerada em relacao ao total desonerado
								//Ex: Cod de atividade X possui receita bruta de 45.000 com aliquota de 1%. A receita bruta
								//    total de atividade desonerada e' igual a 98.000 e ha 2.000 de atividade nao desonerada.
								//	  Sera feito a regra de 3 para saber quanto da receita bruta da atividade corresponde
								//    ao total desonerado. Percentual = 45.000 * 100 / 98.000 = 45,91%. O percentual sera
								//    aplicado sobre os 2.000 da receita nao desonerada. Sobre o valorencontrado sera
								//	  aplicado a aliquota correspondente ao codigo da atividade. Esse valor sera somado ao
								//    que a empresa ja recolhe de contribuicao sobre a atividade desonerada.
								For nCont := 1 To Len(aTabS033)
									If lTemGC .And. lTemEmp .And. cLastEmp != SubStr( aTabS033[nCont, 2], nIniEmp, nTamEmp )
										Loop
									EndIf
									If aTabS033[nCont, 6] == "1"
										//Apura a receita bruta que e' sobre as atividades beneficiadas da Lei no. 12.546/2011
										nBasDes	:= aTabS033[nCont, 7]
										nProp	:= ( nBasDes / nEmpFatDes )
										nTot973	+= ( nProp * nEmpFatFol ) * ( aTabS033[nCont, 8] / 100 )
									EndIf
								Next nCont
							EndIf
							//Apura o total da contribuicao sobre a receita bruta da filial
							aEval( aTabS033, { |aTabS033| If( (!lTemGC .Or. !lTemEmp .Or. (lTemGC .And. lTemEmp .And. SubStr( aTabS033[2], nIniEmp, nTamEmp ) == cLastEmp )) .And. aTabS033[6] == "1", nTot973 += aTabS033[9], Nil ) } )
						EndIf
						//Apura o total de salario na SRC
						nTot318 := fVerTot318( cLastEmp, lRobo )
					EndIf

			    	//Se rateia o Id 0973 e a contribuicao sobre a receita bruta e' maior do que 0
			    	If lRatDes .And. nTot973 > 0 .And. (cPeriodo <= cOneFol .Or. Empty(cOneFol))
			    		//Verifica quantos % o salario do funcionario corresponde em relacao ao total de salarios
			    		//A % sera a parte do funcionario da contribuicao sobre a receita bruta da empresa
			    		nCont973 := ( ( nBase318 / nTot318 ) * nTot973 )
						If lItemClVl
							fMatriz(aCodFol[973,1], nCont973, Nil, cSemana, ( cAliasSRA )->RA_CC, "V", "C", Nil, Nil, dDataPg, .T., Nil, Nil, ( cAliasSRA )->RA_ITEM, ( cAliasSRA )->RA_CLVL, Nil, Nil, Nil, dDataFim )
						Else
							fMatriz(aCodFol[973,1], nCont973, Nil, cSemana, ( cAliasSRA )->RA_CC, "V", "C", Nil, Nil, dDataPg, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, dDataFim )
						Endif
			    	EndIf

					//Se rateia lancamentos por centro de custo, chama a funcao fEncarCc() p/ ratear a contribuicao conforme programao de rateio
					If lRatProv
						If lItemClVl
							Aadd(aEncM013, { ( cAliasSRA )->RA_CC, 0.00, nCont973, 0.00, ( cAliasSRA )->RA_ITEM, ( cAliasSRA )->RA_CLVL, "S" })
						Else
							Aadd(aEncM013, { ( cAliasSRA )->RA_CC, 0.00, nCont973, 0.00, "S" })
						Endif
						fEncarCc( ,.T.)
					EndIf

			    	//Faz a gravacao das contribuicoes no SRC
			    	For nContPd := 1 To Len(aPd)
						If aPd[nContPd, 9] != "D"
							If lItemClVl
								cChave	:= ( cAliasSRA )->RA_FILIAL + cProcesso + ( cAliasSRA )->RA_MAT + cPeriodo + cSemana + cRoteiro + aPd[nContPd, 1] + aPd[nContPd, 2] + aPd[nContPd, 13] + aPd[nContPd, 14]
								cChvBas	:= ( cAliasSRA )->RA_FILIAL + cProcesso + ( cAliasSRA )->RA_MAT + cPeriodo + cSemana + cRoteiro + aCodFol[973,1] + aPd[nContPd, 2] + aPd[nContPd, 13] + aPd[nContPd, 14]
							Else
								cChave	:= ( cAliasSRA )->RA_FILIAL + cProcesso + ( cAliasSRA )->RA_MAT + cPeriodo + cSemana + cRoteiro + aPd[nContPd, 1] + aPd[nContPd, 2]
								cChvBas	:= ( cAliasSRA )->RA_FILIAL + cProcesso + ( cAliasSRA )->RA_MAT + cPeriodo + cSemana + cRoteiro + aCodFol[973,1] + aPd[nContPd, 2]
							EndIf

							If lItemClVl
								SRC->(DbSetOrder( 15 ))
							Else
								SRC->(DbSetOrder( nOrdSRC ))
							EndIf

							nValSBas := 0
							If SRC->( dbSeek( cChvBas ) )
								nValSBas := SRC->RC_VALOR
							EndIf

							If !SRC->( dbSeek( cChave ) )
			                 	If SRC->( Reclock("SRC", .T., .T.) )
			                 		SRC->RC_FILIAL 	:= ( cAliasSRA )->RA_FILIAL
			                 		SRC->RC_MAT		:= ( cAliasSRA )->RA_MAT
			                 		SRC->RC_PD		:= aPd[nContPd, 1]
			                 		SRC->RC_TIPO1 	:= aPd[nContPd, 6]
			                 		SRC->RC_VALOR	:= aPd[nContPd, 5]
			                 		SRC->RC_DATA	:= aPd[nContPd, 10]
			                 		SRC->RC_DTREF	:= dDataFim
			                 		SRC->RC_CC		:= aPd[nContPd, 2]
			                 		SRC->RC_TIPO2	:= aPd[nContPd, 7]
			                 		SRC->RC_SEMANA	:= aPd[nContPd, 3]
			                 		If lTemItem
			                 			SRC->RC_ITEM	:= aPd[nContPd, 13]
			                 		EndIf
			                 		If lTemClvl
			                 			SRC->RC_CLVL   	:= aPd[nContPd, 14]
			                 		EndIf
			                 		SRC->RC_PROCES	:= cProcesso
			                 		SRC->RC_ROTEIR	:= cRoteiro
			                 		SRC->RC_PERIODO	:= cPeriodo
			                 		SRC->RC_VALORBA	:= nValSBas
			                 		SRC->( MsUnlock() )
			                 	EndIF
							Else
			                 	If SRC->( Reclock("SRC", .F., .T.) )
			                 		SRC->RC_VALOR	:= aPd[nContPd, 5]
       		                 		SRC->RC_DATA	:= dDataPg
       		                 		SRC->RC_DTREF	:= dDataFim
			                 		SRC->( MsUnlock() )
			                 	EndIF
							EndIf
						EndIf
			    	Next nContPd
				ElseIf cRecFatEmp == "N"
					cTextoLog := STR0017 + ( cAliasSRA )->RA_FILIAL + STR0042//'- Filial: '##" configurada para não recolher contribuição sobre o faturamento."
					If aScan( aLogDes[2], {|x| x == cTextoLog } ) == 0
						aAdd( aLogDes[2], cTextoLog )
					EndIF
				Else
					cTextoLog := STR0017 + ( cAliasSRA )->RA_FILIAL + STR0043//'- Filial: '##" configurada para recolher contribuição sobre o faturamento, mas a data preenchida no parâmetro MV_FDESFOL"
					cTextoLog1 := "-" + STR0044 //' informa que a filial não é mais desonerada, verifique a data no parâmetro ou configure corretamente a filial."
					IF aScan( aLogDes[2], {|x| x == cTextoLog } ) == 0
						aAdd( aLogDes[2], cTextoLog )
					EndIF
					IF aScan( aLogDes[2], {|x| x == cTextoLog1 } ) == 0
						aAdd( aLogDes[2], cTextoLog1 )
					EndIF
				EndIf
			Else //Se for calculo sobre 2a parcela do 13o salário

				//Calcula a aliquota reduzida que sera aplicada na base do INSS e os valores das receitas
				aCalc13 	:= fPerFatEmp( cRecFatEmp, 0, aTabInss[ 1, Val( cTpC ) ], aTab13Sal, dDataRef, .T. )
	          	nPer13Sal 	:= aCalc13[5] //Aliquota reduzida
				nRecOut13	:= aCalc13[6] //Receitas de outras atividades
				nRecBru13	:= aCalc13[7] //Receita bruta
				nRecDes13	:= aCalc13[8] //Receitas de atividades desoneradas
				nExpDes     := aCalc13[9] //Receitas de exportações desoneradas.
				nExpNDes    := aCalc13[10] //Receitas de exportações não desoneradas.


				If cPeriodo > cOnefol .And. !Empty(cOneFol) .And. SubStr(cOneFol,1,4) == SubStr(cPeriodo,1,4)
					nPosOnera := Ascan(aTab13Sal, { |X| X[6] == "2" })
					If nPosOnera > 0
						cRecFatEmp := "oM"
					Else
						cRecFatEmp := "oS"
					Endif
				Endif

				//Cria o resumo das bases de calculo utilizadas para encontrar a aliquota reduzida no calculo misto
				If cRecFatEmp $ "M*C*oM" .And. !lLogRec13
					lLogRec13 := .T.
					//Valida se o percentual reduzido e' maior do que zero e exibe o calculo efetuado para encontrar o %
					If nPer13Sal > 0
						aAdd( aLogDes[3], OemToAnsi(STR0020) )//"Composição do cálculo para apurar a alíquota reduzida: "
						aAdd( aLogDes[3], OemToAnsi(STR0021) + cValToChar( Transform( nRecOut13, "@E 99,999,999,999.99" ) ) )//" - Receitas de outras atividades (Tipo 2): R$ "
						aAdd( aLogDes[3], OemToAnsi(STR0022) + cValToChar( Transform( nRecBru13, "@E 99,999,999,999.99" ) ) )//" - Receita bruta total: R$ "
						aAdd( aLogDes[3], OemToAnsi(STR0023) + cValToChar( Transform( nRecOut13, "@E 99,999,999,999.99" ) ) + " / R$ " + cValToChar( Transform( nRecBru13, "@E 99,999,999,999.99" ) ) + " = " + cValToChar( nRecOut13/nRecBru13 ) )//" - Receitas de outras atividades / Receita bruta total: R$ "
						aAdd( aLogDes[3], OemToAnsi(STR0024) + cValToChar( nRecOut13/nRecBru13 ) )//" - Coeficiente de redução: "
						aAdd( aLogDes[3], OemToAnsi(STR0025) + cValToChar( aTabInss[ 1, Val( cTpC ) ] * 100 ) + " %" )//" - Alíquota padrão: "
						aAdd( aLogDes[3], OemToAnsi(STR0026) + cValToChar( nRecOut13/nRecBru13 ) + " X " + cValToChar( aTabInss[ 1, Val( cTpC ) ] * 100 ) + " % = " + cValToChar( Round( nPer13Sal * 100, 6 ) ) + " %" )//" - Coeficiente de redução X Alíquota Padrão: "
						aAdd( aLogDes[3], OemToAnsi(STR0027) + cValToChar( Round( nPer13Sal * 100, 6 ) ) + " %" )//" - Alíquota reduzida: "
					//Exibe a mensagem que nao sera efetuado o calculo da contribuicao patronal sobre a folha devido o %
					Else
						nRecBru13 := nRecBru13 - ( nExpDes + nExpNDes )
						nRecDes13 := nRecDes13 - nExpDes

						aAdd( aLogDes[3], OemToAnsi(STR0028) + " " + OemToAnsi(STR0032) )//"Cálculo sobre a folha de pagamento NÃO será efetuado"##"pois a receita desonerada ultrapassou o limite de 95%"
						aAdd( aLogDes[3], OemToAnsi(STR0033) )//"em relação a receita total:"
						aAdd( aLogDes[3], OemToAnsi(STR0029) + cValToChar( Transform( nRecDes13, "@E 99,999,999,999.99" ) ) )//" - Receitas de atividades desoneradas (Tipo 1): R$ "
						aAdd( aLogDes[3], OemToAnsi(STR0022) + cValToChar( Transform( nRecBru13, "@E 99,999,999,999.99" ) ) )//" - Receita bruta total: R$ "
						aAdd( aLogDes[3], OemToAnsi(STR0030) + cValToChar( Transform( nRecDes13, "@E 99,999,999,999.99" ) ) + " / R$ " + cValToChar( Transform( nRecBru13, "@E 99,999,999,999.99" ) ) + " = " + cValToChar( nRecDes13/nRecBru13 ) )//" - Receitas de atividades desoneradas / Receita bruta total: R$ "
						aAdd( aLogDes[3], OemToAnsi(STR0031) + cValToChar( ( nRecDes13/nRecBru13 ) * 100 ) + " %" )//" - Percentual: "
					EndIf
				ElseIf cRecFatEmp $ "S*oS" .And. !lLogRec13
					cTextoLog := STR0017 + ( cAliasSRA )->RA_FILIAL + STR0049//'- Filial: '##" configurada para recolher contribuição exclusivamente sobre o faturamento."
					If aScan( aLogDes[3], {|x| x == cTextoLog } ) == 0
						aAdd( aLogDes[3], cTextoLog )
					EndIF
				EndIf

		       //Quando a empresa tiver faturamento misto, deve aplicar a aliquota reduzida no salario do mes
		       //+ os avos de 13 adquiridos apos o inicio da desoneracao da folha
		       If cRecFatEmp $ "M/C/oM/oS"
			    	nBaseINSS := Round( nSalCon13 - nVl13Des, 2 )
		       	//Quando a empresa tiver faturamento exclusivo sobre o faturamento, nao deve calcular a
		        	//contribuicao sobre a folha
		      	Else
			    	nBaseINSS := 0.00
		      	EndIf

				If cRecFatEmp == "oM" .Or. cRecFatEmp == "oS"
					//Se a desoneracao era M ou C
					If cRecFatEmp == "oM"
						//Aplica a base do salario do mes na aliquota padrao
						nContInss := Round( nBaseINSS * aTabInss[1, Val( cTpC )], 2 )
						//O valor dos avos de 13o. adquiridos na desoneracao, que tera a aliquota reduzida
						nCont13  :=  Round( nVl13Des * nPer13Sal, 2)
						//A contribuicao previdenciaria sera a soma dos dois calculos
						nContrib := ( nContInss + nCont13 )
					// Se a desoneracao era S
					Else
						//Aplica a base do salario do mes na aliquota padrao
						nContInss := Round( nBaseINSS * aTabInss[1, Val( cTpC )], 2 )
						//Contribuicao previdenciaria
						nContrib := nContInss
					Endif
				Else
					//Aplica a base do salario do mes na aliquota reduzida
					nContInss := Round( nBaseINSS * nPer13Sal, 2)
					//O valor dos avos de 13o. adquiridos antes do inicio da desoneracao tem tributacao antiga
					nCont13  :=  Round( nVl13Des * aTabInss[1, Val( cTpC )], 2 )
					//A contribuicao previdenciaria sera a soma dos dois calculos
					nContrib := ( nContInss + nCont13 )
	          	EndIf

		        //Aplica a base do salario do mes na aliquota reduzida
				nContInss := Round( nBaseINSS * nPer13Sal, 2)
			EndIf

	    	//Somente gera o ID 148 se estiver configurado para calcular a contribuicao previdenciaria
	    	If nContrib > 0 .And. ( !lTemInssAut .Or. ( lTemInssAut .And. ( cAliasSRA )->RA_INSSAUT != "N" ) ) .And. lEncPatro

				If lItemClVl
					fMatriz(aCodFol[148,1], nContrib, Nil, cSemana, ( cAliasSRA )->RA_CC, "V", "C", Nil, Nil, dDataPg, .T., Nil, Nil, ( cAliasSRA )->RA_ITEM, ( cAliasSRA )->RA_CLVL, Nil, Nil, Nil, dDataFim )
				Else
					fMatriz(aCodFol[148,1], nContrib, Nil, cSemana, ( cAliasSRA )->RA_CC, "V", "C", Nil, Nil, dDataPg, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, dDataFim )
				Endif

				If lRatProv
					If lItemClVl
						Aadd(aEncM013, { ( cAliasSRA )->RA_CC, 0.00, nContrib, 0.00, ( cAliasSRA )->RA_ITEM, ( cAliasSRA )->RA_CLVL, "S" })
					Else
						Aadd(aEncM013, { ( cAliasSRA )->RA_CC, 0.00, nContrib, 0.00, "S" })
					Endif
					fEncarCc( ,.T.)
				EndIf
				//Faz a gravacao das contribuicoes no SRC
			    For nContPd := 1 To Len(aPd)
					If aPd[nContPd, 9] != "D"
						If lItemClVl
							cChave	:= ( cAliasSRA )->RA_FILIAL + cProcesso + ( cAliasSRA )->RA_MAT + cPeriodo + cSemana + cRoteiro + aPd[nContPd, 1] + aPd[nContPd, 2] + aPd[nContPd, 13] + aPd[nContPd, 14]
							cChvBas	:= ( cAliasSRA )->RA_FILIAL + cProcesso + ( cAliasSRA )->RA_MAT + cPeriodo + cSemana + cRoteiro + aCodFol[318,1] + aPd[nContPd, 2] + aPd[nContPd, 13] + aPd[nContPd, 14]
						Else
							cChave	:= ( cAliasSRA )->RA_FILIAL + cProcesso + ( cAliasSRA )->RA_MAT + cPeriodo + cSemana + cRoteiro + aPd[nContPd, 1] + aPd[nContPd, 2]
							cChvBas	:= ( cAliasSRA )->RA_FILIAL + cProcesso + ( cAliasSRA )->RA_MAT + cPeriodo + cSemana + cRoteiro + aCodFol[318,1] + aPd[nContPd, 2]
						EndIf

						If lItemClVl
							SRC->(DbSetOrder( 15 ))
						Else
							SRC->(DbSetOrder( nOrdSRC ))
						EndIf

						nValSBas := 0
						If SRC->( dbSeek( cChvBas ) )
							nValSBas := SRC->RC_VALOR
						EndIf

						If !SRC->( dbSeek( cChave ) )
			                If SRC->( Reclock("SRC", .T., .T.) )
			                	SRC->RC_FILIAL 	:= ( cAliasSRA )->RA_FILIAL
			                	SRC->RC_MAT		:= ( cAliasSRA )->RA_MAT
			                	SRC->RC_PD		:= aPd[nContPd, 1]
			                	SRC->RC_TIPO1 	:= aPd[nContPd, 6]
			                	SRC->RC_VALOR	:= aPd[nContPd, 5]
			                	SRC->RC_DATA	:= aPd[nContPd, 10]
			                	SRC->RC_DTREF	:= dDataFim
			                	SRC->RC_CC		:= aPd[nContPd, 2]
			                	SRC->RC_TIPO2	:= aPd[nContPd, 7]
			                	SRC->RC_SEMANA	:= aPd[nContPd, 3]
			                	If lTemItem
			                		SRC->RC_ITEM	:= aPd[nContPd, 13]
			                	EndIf
			                	If lTemClvl
			                		SRC->RC_CLVL   	:= aPd[nContPd, 14]
			                	EndIf
			                	SRC->RC_PROCES	:= cProcesso
			                	SRC->RC_ROTEIR	:= cRoteiro
			                	SRC->RC_PERIODO	:= cPeriodo
			                	SRC->RC_VALORBA	:= nValSBas
			                	SRC->( MsUnlock() )
							EndIf
						Else
			               	If SRC->( Reclock("SRC", .F., .T.) )
			               		SRC->RC_VALOR	:= aPd[nContPd, 5]
       		               		SRC->RC_DATA	:= dDataPg
       		               		SRC->RC_DTREF	:= dDataFim
			               		SRC->( MsUnlock() )
			               	Endif
						EndIf
					EndIf
				Next nContPd
	    	EndIf
		Else
            cTextoLog := '- Filial: ' + ( cAliasSRA )->RA_FILIAL + " configurada para não recolher contribuição sobre o faturamento."
			If aScan( aLogDes[2], {|x| x == cTextoLog } ) == 0
				aAdd( aLogDes[2], cTextoLog )
			EndIf
		EndIf
		( cAliasSRA )->( dbSkip() )
	End While

End Sequence

( cAliasSRA )->( dbCloseArea() )

If !lRobo
	//Atualiza o log com a mensagem do termino do processamento
	oSelf:SaveLog( STR0001 + " - " + STR0009 ) //"Desoneração da Folha de Pagamento"##"Termino do processamento"
EndIf

RestArea(aArea)
RestArea(aAreaSM0)

Return()

/*{Protheus.doc} fAliqOnera

Funcao que verifica a alíquota reduzida do 13º na desoneração

@author Allyson Mesashi
@since 09/03/2015
@version P11 R8
@param cRefAux Competência do fim da desoneração
@param nAliqPad Alíquota padrão da contribuição patronal
@param cLastEmp Código da empresa
@Return aRetPerc Retorna array com a alíquota da desoneração e os valores da receita bruta
*/
Static Function fAliqOnera( cRefAux, nAliqPad, cLastEmp )

Local aRetPerc	:= {}
Local aTabS033	:= {}
Local cLimRef	:= Str( Val( SubStr( cRefAux, 1, 4 ) ) - 1, 4 ) + "12"
Local cReceitDes:= SuperGetMv("MV_RECDES",,"A")
Local cRecFatEmp:= ""
Local nAliq 	:= 0.2
Local nCont 	:= 0
Local nFatFol 	:= 0
Local nFatTot 	:= 0
Local nFatDes 	:= 0
Local nExportD 	:= 0
Local nExportF 	:= 0

Local cLayoutGC	:= FWSM0Layout(cEmpAnt)
Local lTemEmp	:= !Empty(FWSM0Layout(cEmpAnt, 1))
Local lTemGC	:= fIsCorpManage( FWGrpCompany() )
Local nIniEmp 	:= At("E", cLayoutGC)
Local nTamEmp	:= Len(FWSM0Layout(cEmpAnt, 1))

While cRefAux >= cLimRef
	aTabS033 := {}
	//Chama fCarrTab para recarregar tabela auxiliar S033
	fCarrTab( @aTabS033, "S033",,.T., cRefAux)
	For nCont := 1 To Len(aTabS033)
		If lTemGC .And. lTemEmp .And. cLastEmp != SubStr( aTabS033[nCont, 2], nIniEmp, nTamEmp )
			Loop
		EndIf
		//Apura a receita bruta total da empresa
		nFatTot += aTabS033[nCont, 10]
		If cReceitDes $ "A|C"
			//Deduz as exclusoes da receita bruta total da empresa
			nFatTot -= aTabS033[nCont, 11]
			If aTabS033[nCont, 6] == "1"
				//Deduz as exclusoes da receita bruta que e' sobre as atividades beneficiadas da Lei no. 12.546/2011
				nFatDes -= aTabS033[nCont, 11]
			Else
				//Deduz as exclusoes da receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
				nFatFol -= aTabS033[nCont, 11]
			EndIf
		Endif
		If cReceitDes $ "B|C"
			//Deduz as exportacoes da receita bruta total da empresa
			nFatTot -= aTabS033[nCont, 12]
			If aTabS033[nCont, 6] == "1"
				//Deduz as exportacoes da receita bruta que e' sobre as atividades beneficiadas da Lei no. 12.546/2011
				nFatDes -= aTabS033[nCont, 12]
			Else
				//Deduz as exportacoes da receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
				nFatFol -= aTabS033[nCont, 12]
			EndIf
		Endif
		//Deduz os impostos da receita bruta total da empresa
		nFatTot -= aTabS033[nCont, 13]
		If aTabS033[nCont, 6] == "1"
			//Apura a receita bruta que e' sobre as atividades beneficiadas da Lei no. 12.546/2011
			nFatDes += aTabS033[nCont, 10]
			//Deduz os impostos da receita bruta que e' sobre as atividades beneficiadas da Lei no. 12.546/2011
			nFatDes -= aTabS033[nCont, 13]
		Else
			//Apura a receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
			nFatFol += aTabS033[nCont, 10]
			//Deduz as exclusoes da receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
			nFatFol -= aTabS033[nCont, 13]
		EndIf
		If aTabS033[nCont, 6] == "1"
			nExportD += aTabS033[nCont, 12]
		Else
			nExportF += aTabS033[nCont, 12]
		EndIf
	Next nCont
	//Subtrai um mes da variaval que controla a competencia
	cRefAux := SubMesAno( cRefAux )
End While

//Calcula a razao entre o faturamento de atividades diversas sobre o faturamento total
nPerFatEmp 	:= ( nFatFol / nFatTot )

If nPerFatEmp > 0
	//Empresa atualmente nao e desonerada mas ja foi desonerada mista
	cRecFatEmp := "oM"
Else
	////Empresa atualmente nao e desonerada mas ja foi desonerada exclusivamente sobre o faturamento
	cRecFatEmp := "oS"
Endif

If cRecFatEmp $ "M|oM" .And. nPerFatEmp >= 0.95
	nAliq := nAliqPad
//Receita nao Desonerada MAIOR que 5% e MENOR que 95% do Total - Aplicacao da aliquota reduzida
ElseIf cRecFatEmp $ "M|oM" .And. ( nPerFatEmp > 0.05 .And. nPerFatEmp < 0.95 )
	nAliq := ( nPerFatEmp * nAliqPad )
//Receita nao Desonerada MAIOR que 5% - Aplicacao da aliquota reduzida
ElseIf cRecFatEmp == "C" .And. nPerFatEmp > 0.05
	nAliq := ( nPerFatEmp * nAliqPad )
Else
    //A aliquota sera zerada
    If cRecFatEmp $ "S*M"
       nAliq :=0
    Else
	   nAliq := nAliqPad
	Endif
EndIf

aRetPerc := { nAliq, nFatFol, nFatTot, nFatDes, 0, 0, 0, 0, nExportD, nExportF }

Return( aRetPerc )

/*{Protheus.doc} fVerTot318

Funcao de busca do total de salarios na SRC atraves do Id 318

@author Allyson Mesashi
@since 09/03/2015
@version P11 R8
@param cCodEmp Codigo da empresa desonerada
@Return nTot Retorna o total de valor da verba de Id 318
*/
Static Function fVerTot318( cCodEmp, lRobo )

Local cAliasTmp	:= ""
Local cSRCTop	:= ""
Local cQrySRC	:= ""
Local nTot	 	:= 0

Default cCodEmp := FwCodEmp()
Default lRobo	:= .F.

cSRCTop	:= RetSqlName("SRC")
cQrySRC := "SELECT SUM(" + cSRCTop + ".RC_VALOR) AS RC_VALOR FROM " + cSRCTop
cQrySRC += " INNER JOIN " + RetSqlname("SRA")+ " SRA ON SRA.RA_MAT="+ cSRCTop +".RC_MAT AND "+ cSRCTop +".RC_FILIAL=SRA.RA_FILIAL AND SRA.RA_CATFUNC NOT IN ('E','G')"
cQrySRC +=  " WHERE "
If lTemGC .And. lTemEmp
	cQrySRC += "SUBSTRING(" + cSRCTop + ".RC_FILIAL," + cValToChar(nIniEmp) + "," + cValToChar(nTamEmp) + ") = '" + cCodEmp + "' AND "
EndIf
cQrySRC += cSRCTop + ".RC_PD = '" + aCodFol[318,1] + "' "
If lRobo
	cQrySRC += "AND " + cSRCTop + ".RC_PROCES = '" + mv_par01 + "' "
EndIf
cQrySRC += "AND " + cSRCTop + ".D_E_L_E_T_ = ' ' "
cQrySRC += "AND SRA.D_E_L_E_T_ = ' ' "

cQrySRC	  := ChangeQuery(cQrySRC)
cAliasTmp := GetNextAlias()
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQrySRC), cAliasTmp)

If (cAliasTmp)->( !Eof() )
	nTot := ( cAliasTmp )->RC_VALOR
EndIf

(cAliasTmp)->( dbCloseArea() )

Return nTot
/*{Protheus.doc} Gpm13AtuS033

Funcao para atualizar tabela S033 no calculo do 13o.

@author Marcelo Silveira
@since 22/12/2017
@version P12
@param nVerFatFin Indica o tipo de Integracao (2-Faturamento, 3-Financeiro, 4-Ambos)
@param dDtRef Data de referencia para pesquisa na tabela S033
@return Nil Nenhum
*/
Function Gpm13AtuS033(nVerFatFin,dDtRef)

Local aArea			:= GetArea()
Local aAreaSM0 		:= SM0->( GetArea() )
Local aCargFil		:= FwLoadSm0()
Local aFilProc		:= {}
Local aTabInss	 	:= {}
Local aTabS033	 	:= {}
Local cAnoMesAte	:= cTod("//")
Local cAnoMesDe		:= cTod("//")
Local cCodEmp	 	:= SM0->M0_CODIGO
Local nAliq	 		:= 0
Local nContr		:= 0
Local nFatBas		:= 0
Local nFatDExp 		:= 0
Local nFatExc 		:= 0
Local nFatExp 		:= 0
Local nFatTot	 	:= 0
Local nFatTotDev	:= 0
Local nFatTotExp	:= 0
Local nFatTotLiq	:= 0
Local nFatRecAux	:= 0
Local nFatRecB 		:= 0
Local nFatRecL 		:= 0
Local nFilial		:= 0
Local nTotCLiq		:= 0
Local nTotCont 		:= 0
Local nTotDev 		:= 0
Local nTotExp 		:= 0
Local nTotImp 		:= 0
Local nVlAux		:= 0
Local nValDev		:= 0
Local nValExp		:= 0
Local nTpContr		:= 0
Local cAnoMes		:= ""
Local cConta		:= ""

DEFAULT nVerFatFin	:= 1

If Type("aPergunte") # "U" .And. !Empty( aPergunte )
	nVerFatFin	:= APERGUNTE[5][3]
	cAnoMesDe	:= APERGUNTE[6,3]
	cAnoMesAte	:= APERGUNTE[7,3]
EndIf

Begin Sequence

	If nVerFatFin != 1

		dDataRef := If( Type("dDataRef") == "U", dDtRef, dDataRef )
		cAnoMes	 := AnoMes(dDataRef)

		//Monta o array das filiais a processar.
		aEval( aCargFil, { |aCargFil| If(aCargFil[1] == cCodEmp, Aadd(aFilProc,{ aCargFil[2] }),Nil )} )

		//Chama fCarrTab para recarregar tabela auxiliar S033
		fCarrTab( @aTabS033, "S033", ,.T., cValToChar( Year( dDataRef ) ) + "13" )

		//Verifica todas as filiais que foram selecionadas no processamento, para validar se possuem registro na tabela auxiliar S033
		For nFilial := 1 To Len( aFilProc )
			//Reinicializa variaveis
			nAliq	 	:= 0
			nContr		:= 0
			nFatRecAux 	:= 0
			nFatTot	 	:= 0
			nFatTotDev	:= 0
			nFatTotExp	:= 0
			nFatTotLiq	:= 0
			nFatRecB 	:= 0
			nFatRecL 	:= 0
			nFatExc 	:= 0
			nFatExp 	:= 0
			nFatDExp 	:= 0
			nFatBas		:= 0
			nTotCLiq 	:= 0
			nTotCont 	:= 0
			nTotDev 	:= 0
			nTotExp 	:= 0
			nTotImp 	:= 0
			nVlAux	 	:= 0
			nValDev		:= 0
			nValExp		:= 0
			cConta		:= ""

			//Busca no parametro 14 se a empresa recolhe contribuicao previdenciaria sobre a receita (X14_RECFAT)
			If fInssEmp( aFilProc[nFilial, 1], @aTabInss, Nil, cAnoMes )
				//Verifica os dois tipos de contrato
				For nTpContr := 1 To 2
					cRecFatEmp 	:= aTabInss[27, nTpContr]//X14_RECFAT
					//Se recolher sobre o faturamento ou for recolhimento misto
					If cRecFatEmp $ "S*M*C"
					   	//Se nao encontrar registros para a filial, verificar as funcoes das integracoes
					    If ( aScan( aTabS033, {|x| x[2] == aFilProc[nFilial, 1] } ) == 0 )

							//Validacao do preenchimento da data de
							If Empty( cAnoMesDe )
								cAnoMesDe := cToD( "01/12/" + cValToChar( Year( dDataRef ) - 1 ) )
							EndIf
							//Validacao do preenchimento da data ate
							If Empty( cAnoMesAte )
								cAnoMesAte := cToD( "30/11/" + cValToChar( Year( dDataRef ) ) )
							EndIf

					       	//Se somente verifica Financeiro
					       	If nVerFatFin == 3
								//Entra na funcao do Financeiro para buscar os valores dos titulos de acordo
								//com a filial logada. A funcao nao permite passar a filial como parametro
								//entao a variavel cFilAnt sera alterada de acordo com a filial em processamento.
								//A funcao retorna o valor das receitas financeiras.
								cSvFilAnt := cFilAnt
								cFilAnt	  := aFilProc[nFilial, 1]
								nFatTot   := FTotF100( Val( "13" ), Year( dDataRef ), dToS( cAnoMesDe ), dToS( cAnoMesAte ) )
								cFilAnt	  := cSvFilAnt
					            //Grava o registro da receito de tipo 2
								If nFatTot > 0
									fGravaS033( aFilProc[nFilial, 1], cValToChar( Year( dDataRef ) ) + "13" , Nil, "2", nFatTot, 0.00, 0.00, nFatTot, 0.00, 0.00, aTabS033 )
								EndIf
					        //Se verifica Faturamento e/ou Financeiro
					        Else
								//Entra na funcao do Faturamento para buscar os valores das notas fiscais de saida
								//na tabela SD2 para verificar o faturamento da filial na competencia. A funcao
								//do faturamento retorna os dados gravados em um alias temporario
								cSvFilAnt := cFilAnt
								cFilAnt	  := aFilProc[nFilial, 1]
								cAliasFat := RhInssPat( "12" + cValToChar( Year( dDataRef ) ), aFilProc[nFilial, 1], .T., SubStr( dToS(cAnoMesDe), 5, 2 )  + SubStr( dToS(cAnoMesDe), 1, 4 ) + "/" + SubStr( dToS(cAnoMesAte), 5, 2 ) + SubStr( dToS(cAnoMesAte), 1, 4 ),.T. )
								cFilAnt	  := cSvFilAnt
								If !Empty( cAliasFat )
									dbSelectArea( cAliasFat )
									(cAliasFat)->( dbGoTop() )
									While (cAliasFat)->( !EoF() )
						                cCodAti		:= (cAliasFat)->CODATV
						                cTipFat 	:= "1"
						                nAliq		:= SpedPCCG1( cCodAti, dDataRef )
						                nFatTot 	:= (cAliasFat)->TOTAL 		// Total
						                nFatTotLiq 	:= (cAliasFat)->TOTALLIQ	// Total
						                nFatTotDev 	:= (cAliasFat)->TOTLIQDEV 	// Total devolucao
						                nFatTotExp 	:= (cAliasFat)->TOTLIQEXP  	// Total exportacao
						                nFatRecB	:= (cAliasFat)->TOTCODAT	// Total do codigo de atividade bruto
						                nFatRecL	:= (cAliasFat)->TCODATLQ	// Total do codigo de atividade liquido
						                nFatExc		:= (cAliasFat)->TCATVDEV	// Total devolucoes do codigo de atividade
						                nFatExp		:= (cAliasFat)->TLQCATVEXP	// Total exportacoes do codigo de atividade
						                nFatBas 	:= (cAliasFat)->TCDEVEXP 	// Total codigo de atividade - devolucoes - exportacoes (base calculo)
										If (cAliasFat)->(ColumnPos("CONTARECE")) > 0
					                		cConta		:= (cAliasFat)->CONTARECE 	// Conta de Receita / Conta Contábil
										EndIf
					                    //Calcula a contribuicao com base na aliquota encontrada
						                If nAliq > 0
							                nContr	:= ( nFatBas * ( nAliq/100 ) )
							  			EndIf
						                //Grava a informacao do recolhimento devido na tabela auxiliar S033.
										If nFatBas > 0
											fGravaS033( aFilProc[nFilial, 1], cValToChar( Year( dDataRef ) ) + "13" , cCodAti, cTipFat, nFatBas, nAliq, nContr, nFatRecB, nFatExc, nFatExp, aTabS033, nFatRecB - nFatRecL,cConta )

											//Chama fCarrTab para recarregar tabela auxiliar S033
											aTabS033 := {}
											fCarrTab( @aTabS033, "S033", ,.T., cValToChar( Year( dDataRef ) ) + "13" )
										Else
										 	//Senao tiver faturamento com produtos com cod atividade, mas tiver algum faturamento gravar tabela S033, com tipo 2 (produtos nao desonerados)
											If nFatTot > 0
												If Empty(cCodAti)
													cTipFat := "2"
												Else
													cTipFat := "1"
												EndIf
												fGravaS033( aFilProc[nFilial, 1], cValToChar( Year( dDataRef ) ) + "13" , cCodAti, cTipFat, nFatBas, nAliq, nContr, nFatRecB, nFatExc, nFatExp, aTabS033, nFatRecB - nFatRecL, cConta )
												//Chama fCarrTab para recarregar tabela auxiliar S033
												aTabS033 := {}
												fCarrTab( @aTabS033, "S033", ,.T., cValToChar( Year( dDataRef ) ) + "13" )
											EndIf
										EndIf

										//Caso algum Codigo de Atividade fique com valor Base zerado devido exportacoes e devolucoes, ou no caso
										//de haver somente valores nao desonerados, o total da atividade processada sera atribuido a variavel
										//auxiliar nFatRecAux para posterior deducao do Total Geral para que o valor da Receita Tipo 2 saia correto
										nFatRecAux += If( nFatBas == 0, nFatTotLiq, 0 )

										(cAliasFat)->( dbSkip() )
									End While

									//FAZ A TOTALIZACAO DA FATURAMENTO DA FILIAL GRAVADAS NA TABELA S033
									aEval(aTabS033, {|aTabS033| If(aTabS033[2] + aTabS033[6] == aFilProc[nFilial, 1] + "1", nTotCont += aTabS033[10], Nil) })
									aEval(aTabS033, {|aTabS033| If(aTabS033[2] + aTabS033[6] == aFilProc[nFilial, 1] + "1", nTotCLiq += aTabS033[7], Nil) })
									aEval(aTabS033, {|aTabS033| If(aTabS033[2] + aTabS033[6] == aFilProc[nFilial, 1] + "1", nTotDev += aTabS033[11], Nil) })
									aEval(aTabS033, {|aTabS033| If(aTabS033[2] + aTabS033[6] == aFilProc[nFilial, 1] + "1", nTotExp += aTabS033[12], Nil) })
									If Len(aTabS033) >= 1 .And. Len(aTabS033[1]) >= 13
										aEval(aTabS033, {|aTabS033| If(aTabS033[2] + aTabS033[6] == aFilProc[nFilial, 1] + "1", nTotImp += aTabS033[13], Nil ) } )
									EndIf

									//Entra na funcao do Financeiro para buscar os valores dos titulos de acordo
									//com a filial logada. A funcao nao permite passar a filial como parametro
									//entao a variavel cFilAnt sera alterada de acordo com a filial em processamento.
									//A funcao retorna o valor da receita total.
									If nVerFatFin == 4
										cSvFilAnt := cFilAnt
										cFilAnt	  := aFilProc[nFilial, 1]
										nVlAux    := FTotF100( Val( "13" ), Year( dDataRef ), dToS( cAnoMesDe ), dToS( cAnoMesAte ) )
										nFatTot   += nVlAux
										nFatTotLiq+= nVlAux
										cFilAnt	  := cSvFilAnt
									EndIf
									//Se o total de faturamento da filial for maior do que os registros gravados
									//significa que ha faturamento de atividades que nao estao enquadradas na Lei
									//Esse registro deve ser gravado na tabela auxiliar com o tipo de receita 2
									nValDev := If( nFatTotDev > nTotDev, nFatTotDev, nTotDev )
									nValExp := If( nFatTotExp > nTotExp, nFatTotExp, nTotExp )

									If nFatTotLiq - nValDev - nValExp >= nTotCLiq .And. ( ( nFatTotLiq - nTotCLiq - nFatRecAux - ( nValDev - nTotDev ) - ( nValExp - nTotExp ) ) > 0 .Or. ( nFatTot - nTotCont ) > 0 )
										fGravaS033( aFilProc[nFilial, 1], cValToChar( Year( dDataRef ) ) + "13", Nil, "2", ( nFatTotLiq - nTotCLiq - nValExp - nValDev ), 0.00, 0.00, ( nFatTot - nTotCont ), ( nValDev - nTotDev ), ( nValExp - nTotExp ), aTabS033, ( nFatTot - nFatTotLiq - nTotImp ) )
									EndIf
									(cAliasFat)->( dbCloseArea() )
								EndIf
							EndIf
			            	//Sai do For dos tipos de contratos pois ja alimentou a S033 com os valores da competencia
			            	Exit
						EndIf
					EndIf
				Next nTpContr
			EndIf
		Next nFilial
	EndIf
End Sequence

RestArea(aArea)
RestArea(aAreaSM0)

Return()
