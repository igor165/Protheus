#INCLUDE "PROTHEUS.CH"
//#INCLUDE "FIVEWIN.CH"
#INCLUDE "FINR112.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} FINR112
"Registro del Régimen de Retenciones" en el cual controlará los débitos
y créditos con respecto a la cuenta por pagar por cada proveedor

@author Mayra L. Camargo
@since 09/04/2013
@version P11

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR ³ DATA   ³ BOPS    ³          MOTIVO DA ALTERACAO          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glez³03/01/17³SERINN001³Se modifica uso de tablas temporales   ³±±
±±³             ³        ³     -898³por motivo de limpieza de CTREE.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/
//-------------------------------------------------------------------

Function FINR112()
	Private oTmpTable
	Private aOrder    :={}
	Private nValTran  :=0
	Private cIndE1    :=cIndE2 :=cIndE5 :=cIndA1 :=cIndA2 :=" "


		FINR112R3()

	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf

	If oTmpTable <> Nil   //jgr
		oTmpTable:Delete()  //jgr
		oTmpTable := Nil
	Endif

Return

/*----------------------------------------------------------------------------R3------------------------------------------------*/

Function Finr112R3()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL wnrel
	LOCAL cDesc1 :=OemToAnsi(STR0001)  //"Este relatorio ir  imprimir o razonete de Clientes ou"
	LOCAL cDesc2 :=OemToAnsi(STR0002)  //"Fornecedores. Poder  ser emitida toda a movimenta‡„o "
	LOCAL cDesc3 :=OemToAnsi(STR0003)  //"dos mesmos, ou somente os valores originais."
	LOCAL limite := 132
	LOCAL cString:="SE1"
	LOCAL Tamanho:= "M"

	PRIVATE cabec1
	PRIVATE cabec2
	PRIVATE titulo  := OemToAnsi(STR0007)  //"REGISTRO DEL RÉGIMEN DE RETENCIONES DEL IGV "
	PRIVATE aReturn := { OemToAnsi(STR0005), 1, OemToAnsi(STR0006) , 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
	PRIVATE nomeprog:= "FINR112"
	PRIVATE aLinha  := { },nLastKey := 0
	PRIVATE cPerg   := "FINR112"
	Private cTipos  := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para Filtrar os tipos sem entrar na tela do ³
	//³ FINRTIPOS(), localizacao Argentina.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF cPaisLoc <> "BRA" .And. EXISTBLOCK("FARGTIP")
		cTipos   := EXECBLOCK("FARGTIP")
	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                        ³
	//³ mv_par01            // A partir de                          ³
	//³ mv_par02            // Ate a data                           ³
	//³ mv_par03            // Do Codigo                            ³
	//³ mv_par04            // Ate o Codigo                         ³
	//³ mv_par05            // Imprime Valores Financeiros (Sim/Nao)³
	//³ mv_par06            // Impime (Todos,Normais,Adiantamentos) ³
	//³ mv_par07            // Do Prefixo                           ³
	//³ mv_par08            // Ate o Prefixo                        ³
	//³ mv_par09            // Lista Por 1 - Filial     2 -Empresa  ³
	//³ mv_par10            // Seleciona Tipos                      ³
	//³ mv_par11            // Natureza de  ?                       ³
	//³ mv_par12            // Natureza ate ?                       ³
	//³ mv_par13            // Cual Moneda                          ³
	//³ mv_par14            // Otras Moneda  Converter/No Imprimir  ³
	//³ mv_par15            // Por fecha/Factura                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := "FINR112"            //Nome Default do relatorio em Disco
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho,"",.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	#IFDEF WINDOWS
		RptStatus({|lEnd| FA112Imp(@lEnd,wnRel,cString)},titulo)
	#ELSE
		fA112Imp(.f.,Wnrel,cString)
	#ENDIF
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA112Imp ³ Autor ³ Wagner Xavier         ³ Data ³ 25.02.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Razonete de Cliente/Fornecedores                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FA112Imp(lEnd,wnRel,cString)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd    - A‡Æo do Codeblock                                ³±±
±±³          ³ wnRel   - T¡tulo do relat¢rio                              ³±±
±±³          ³ cString - Mensagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA112Imp(lEnd,wnRel,cString)
	LOCAL CbCont,CbTxt
	Local nX, nI
	LOCAL cPosTp
	LOCAL cChaveSe1
	LOCAL cChaveSe2
	LOCAL nRegAtu,lImprime
	LOCAL nTotAbat,  cCodigo, cLoja
	LOCAL nRegistro
	LOCAL nRec, nPrim, cPrefixo, cNumero, cParcela, cTipo, cNaturez, nValliq
	LOCAL cNome, nTotDeb := 0, nTotCrd := 0, nSaldoAtu := 0, nTotDebG := 0,nTotCrdG := 0, nSalAtuG := 0, nSalAntG := 0
	LOCAL tamanho:="M"
	LOCAL nQuebra:=0,lImprAnt := .F.
	LOCAL aSaldos:={},j,dEmissao:=CTOD(""),dVencto:=CTOD("")
	LOCAL nAnterior:=0,cAnterior,cFornece,dDtDigit,cRecPag,nRec1,cSeq
	LOCAL lNoSkip := .T.
	LOCAL lFlag := .F.
	LOCAL nSaldoFinal:=0
	LOCAL aCampos:={},aTam:={}
	LOCAL aInd:={}
	LOCAL cCondE1:=cCondE2:=cCondE5:=" "
	LOCAL cIndE1 :=cIndE2 :=cIndE5 :=cIndA1 :=cIndA2 :=" "
	Local cOrdem	:=""
	LOCAL nRegSe1Atu := SE1->(RecNo())
	LOCAL nOrdSe1Atu := SE1->(IndexOrd())
	LOCAL lBaixa     := .F.
	LOCAL nRegSe2Atu := SE2->(RecNo())
	LOCAL nOrdSe2Atu := SE2->(IndexOrd())
	LOCAL nDecs		:=MsDecimais(MV_PAR13)
	Local cUniao	 	:= Alltrim(GetMv("MV_UNIAO"))
	Local cSimb  		:=	""
	Local cSimbolo	:=	""
	Local aDataEmp	:=	{}
	Local nTotRet		:= 0
	Local cTipTran	:= ""
	Local cCodGob		:= ""
	Local cCodDesc	:= ""

	Local aMeses		:= {"Enero",;
							"Febrero",;
							"Marzo",;
							"Abril",;
							"Mayo",;
							"Junio",;
							"Julio",;
							"Agosto",;
							"Septiembre",;
							"Octubre",;
							"Noviembre",;
							"Diciembre"}
	Local nMes			:= Month(dDatabase)
	Local cMesRep 	:= aMeses[nMes]

	aDataEmp := getDatosEmp()

	If cPaisLoc != "BRA"
	   For nX := 1 to MoedFin()
	      cSimbolo := GetMv("MV_SIMB"+Str(nX,1))
	      If !Empty(cSimbolo)
	         cSimb    += PadR(cSimbolo,3)+","
	      EndIf
	      cSimbolo    := ""
	   Next nX
	   cSimb  := Substr(cSimb,1,len(cSimb)-1)  //Contem os simbolos das moedas utilizadas pelo sistema
	EndIf                                       //para realizar o filtro

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cbtxt    := SPACE(10)
	cbcont   := 0
	li       := 80
	m_pag  := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Referencia para imprimir descricao dos tipos de cliente A1_TIPO ³
	//ÀÄLocalizacoesÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc != "BRA"
		SX3->(dbSetOrder(2))
		SX3->(dbSeek("A1_TIPO"))
		If SX3->(Found())
			cTipoCli := AllTrim(SX3->(X3CBox()) )
			cTipoCli := '{"'+StrTran(cTipoCli,';','","')+'"}'
			aTipoCli := &(cTipoCli)
		Else
			cTipoCli := ""
			aTipoCli := {}
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se seleciona tipos                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par10 == 1
		finRTipos()
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao dos cabecalhos                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	titulo := 	OemToAnsi(STR0007)//+IIF(mv_par03==1,OemToAnsi(STR0008), OemToAnsi(STR0009))  //"RAZONETE DE CONTAS CORRENTES DE "###"CLIENTES"###"FORNECEDORES"
	cabec2 := 	OemToAnsi(STR0010)  //"FECHA      DENOMINACION          DOCUMENTO       REFERENCIA    TIPO TRANSACCION          DEBITO        CREDITO   SALDO ACTUAL"
	cabec1 :=	STR0008 + cMesRep + " del " + alltrim(STR(YEAR(DATE()))) + space(5)+;	// PERIODO:
				STR0009 + aDataEmp[1] + space(5) +;												// RUC
				STR0018 + aDataEmp[2]																// RAZÓN SOCIAL



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo de Trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTam:=TamSX3("E1_CLIENTE")
	AADD(aCampos,{"CODIGO" ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_LOJA")
	AADD(aCampos,{"LOJA"   ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_EMISSAO")
	AADD(aCampos,{"DATAEMI","D",aTam[1],aTam[2]})
	AADD(aCampos,{"NUMERO" ,"C",16,0})
	aTam:=TamSX3("E1_TIPO")
	AADD(aCampos,{"TIPO"   ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_PORTADO")
	AADD(aCampos,{"BANCO"  ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_EMISSAO")
	AADD(aCampos,{"EMISSAO","D",aTam[1],aTam[2]})
	AADD(aCampos,{"BAIXA"  ,"D",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_VENCREA")
	AADD(aCampos,{"VENCTO" ,"D",aTam[1],aTam[2]})
	AADD(aCampos,{"VALOR"  ,"N",18,2})
	AADD(aCampos,{"HISTOR" ,"C",40,0})
	AADD(aCampos,{"DC"     ,"C", 1,0})
	AADD(aCampos,{"TIPOTRANS","C",15,0})
	aadD(aCampos,{"DENOM","C",20,0})

	//Creacion de Objeto
	If mv_par15 == 1
		aOrdem	:=	{"CODIGO","LOJA","DATAEMI","NUMERO","HISTOR"} //jgr
	Else
		aOrdem	:=	{"CODIGO","LOJA","EMISSAO","NUMERO","TIPO","BAIXA","HISTOR"} //jgr
	Endif

	oTmpTable := FWTemporaryTable():New("cNomeArq") //jgr
	oTmpTable:SetFields( aCampos ) //jgr
	oTmpTable:AddIndex("I01", aOrdem)
	oTmpTable:Create()

	dbGoTop()

	//IF mv_par03 == 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Localiza e grava titulos a pagar dentro dos parametros       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE2")
		dbSetOrder (6)
		If mv_par09 = 1
			dbSeek(xFilial()+mv_par03,.T.)

			cCondE2:="E2_FILIAL=='"+xFilial() +"'.and. E2_FORNECE >='"+ mv_par03+"' .And. E2_FORNECE <= '"+mv_par04+"'"
		Else
			cArqTrab :=CriaTrab(NIL,.F.)
			AADD(aInd,cArqTrab)
			cIndE2   :=IndexKey()
			cIndE2   :=Right(cIndE2,Len(cIndE2)-10)
			IndRegua("SE2",cArqTrab,cIndE2,,,OemToAnsi(STR0011))  //"Selecionando Registros..."
			cCondE2:="E2_FORNECE >='"+ mv_par03+"' .And. E2_FORNECE <='"+ mv_par04+"'"
			dbCommit()
			nIndex:=RetIndex("SE2")
			dbSelectArea("SE2")
			#IFNDEF TOP
				dbSetIndex(cArqTrab+OrdBagExt())
			#ENDIF
			dbSetOrder(nIndex+1)
			dbSeek(mv_par03,.T.)
		EndIf

		While !SE2->(Eof()) .and. &(cCondE2)

			If SE2->E2_PREFIXO < mv_par07 .Or. SE2->E2_PREFIXO > mv_par08  .Or. SE2->E2_EMIS1 > dDataBase
				SE2->(dbSkip())
				Loop
			EndIf

			If ( SE2->E2_NATUREZ < mv_par11 .Or. SE2->E2_NATUREZ > mv_par12 )
				SE2->(dbSkip())
				Loop
			EndIf

			IF SubStr(SE2->E2_TIPO,1,2) == "PR"
				SE2->(dbSkip())
				Loop
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica quais serao impressos                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par06 == 2 .and. (SE2->E2_TIPO $ "PA /"+MV_CPNEG)  // So'Normais
				dbSkip()
				Loop
			Endif

	      If mv_par06 == 3 .And. !(SE2->E2_TIPO $ MVPAGANT+","+MV_CPNEG) //So'Adiantamentos
				dbSkip()
				Loop
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Le registros com data anterior a data inicial (para compor   ³
			//³ os saldos anteriores) ate a data final.                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE2->E2_EMIS1 > mv_par02
				SE2->(dbSkip())
				Loop
			End

			if MV_PAR14==2 .AND. MV_PAR13<>SE2->E2_MOEDA
				DbSkip()
				Loop
			Endif

			if ! Inside(SE2->E2_TIPO)
				dbSkip()
				Loop
			End

			//Denominacion
			cCodGob := POSICIONE("CCM",1,XFILIAL("CCM")+SE2->E2_TIPO,"CCM_CODGOV")
			cCodDesc:= POSICIONE("CCL",1,XFILIAL("CCM")+cCodGob,"CCL_DESCRI")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava debito no arquivo de trabalho                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//If ! dbSeek(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
			Reclock("cNomeArq",.t.)
			Replace CODIGO		With SE2->E2_FORNECE
			Replace LOJA			With SE2->E2_LOJA
			Replace DATAEMI 		With SE2->E2_EMIS1
			Replace NUMERO		With SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA
			Replace TIPO			With SE2->E2_TIPO
			Replace BANCO			With SE2->E2_PORTADO
			Replace EMISSAO		With SE2->E2_EMISSAO
			Replace VENCTO		With SE2->E2_VENCREA
			Replace VALOR			With xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,MV_PAR13,,nDecs+1)
			Replace DENOM			With IIF(!Empty(cCodDesc),cCodDesc,SE2->E2_TIPO)
			If cPaisLoc <> "BRA"
				cHistor := ""
				If SE2->E2_TIPO == "NCP"
					cHistor := OemToAnsi(STR0030)	// "NOTA DE CREDITO No. "
					cTipTran:= OemToAnsi(STR0056)	//	Devolución parcial
				ElseIf SE2->E2_TIPO == "NDP"
					cHistor := OemToAnsi(STR0031)	// "NOTA DE DEBITO No. "
					cTipTran:= OemToAnsi(STR0057)	// Ajuste de Precios
				ElseIf SE2->E2_TIPO $ "NF |FT "
					cHistor := OemToAnsi(STR0032)	// "FACTURA No. "
					cTipTran:= OemToAnsi(STR0054)	// Compra
				ElseIf SE2->E2_TIPO == "NCE"
					cHistor := OemToAnsi(STR0036)	// "NOTA DE CRED. EXTERNA"
				ElseIf SE2->E2_TIPO == "NDE"
					cHistor := OemToAnsi(STR0037)	// "NOTA DE DEB. EXTERNA"
				ElseIf SE2->E2_TIPO == "PA "
					cHistor := OemToAnsi(STR0033)	// "ANTICIPO"
					cTipTran:=OemToansi(STR0055)
				ElseIf SE2->E2_TIPO == "CH "
					cHistor := OemToAnsi(STR0044)	// "CHEQUE"
					cTipTran:= OemToAnsi(STR0055)
				ElseIf SE2->E2_TIPO $ "TX  "
					//cHistor := OemToAnsi(STR0060)
					Replace DENOM with STR0060
					cTipTran := oemToAnsi(STR0053)
				EndIf


				Replace HISTOR  With IIF(Empty(SE2->E2_HIST),cHistor,SE2->E2_HIST)
				Replace TIPOTRANS with cTipTran
			ElseIf SE2->E2_FATURA="NOTFAT" .and. cPaisLoc == 'BRA'
				Replace HISTOR  With IIF(Empty(SE2->E2_HIST),OemToAnsi(STR0029),SE2->E2_HIST)  //"Pela Emissao da Fatura"
			Else
				Replace HISTOR  With IIF(Empty(SE2->E2_HIST),OemToAnsi(STR0012),SE2->E2_HIST)  //"Pela Emissao do Titulo"
			Endif
	       IF SE2->E2_TIPO $ MV_CPNEG+","+MVPAGANT .Or. (SE2->E2_TIPO $ MVCHEQUES .And. AllTrim(SE2->E2_ORIGEM) != "FINA085A") .Or. SubStr(SE2->E2_TIPO,3,1) == "-"
				Replace DC     With "D"
			Else
				Replace DC     With "C"     //Abatimentos
			Endif



			MsUnlock()
			//EndIf

			nRegSe2Atu := SE2->(RecNo())
			nOrdSe2Atu := SE2->(IndexOrd())
			lBaixa     := .F.

			If SE2->E2_FATURA == "NOTFAT"
				dbSelectArea("SE2")
				dbSetOrder(9)
				cChaveSe2 := xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
				If (dbSeek(cChaveSe2))
					If E2_DTFATUR <= dDataBase .and. SE2->E2_BAIXA <= mv_par02
						lBaixa := .T.
					Endif
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se houve a substituicao do NF -> DP                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBaixa
				dbSelectArea("cNomeArq")
				If !(dbSeek(SE2->E2_FORNECE+SE2->E2_LOJA+DTOS(SE2->E2_DTFATUR)+SE2->E2_PREFIXO+SE2->E2_NUM))
					dbSelectArea("SE2")
					While !Eof() .and. cChaveSe2 == xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_FATPREF+SE2->E2_FATURA

						//If ! dbSeek(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
						//Denominacion
						cCodGob := POSICIONE("CCM",1,XFILIAL("CCM")+SE2->E2_TIPO,"CCM_CODGOV")
						cCodDesc:= POSICIONE("CCL",1,XFILIAL("CCM")+cCodGob,"CCL_DESCRI")

						if MV_PAR14==2 .AND. MV_PAR13<>SE2->E2_MOEDA
							dbSelectArea("SE2")
							dbSkip()
						else
							Reclock("cNomeArq",.T.)
							Replace CODIGO		With SE2->E2_FORNECE
							Replace LOJA			With SE2->E2_LOJA
							Replace DATAEMI 		With SE2->E2_DTFATUR
							Replace NUMERO		With SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA
							Replace EMISSAO		With SE2->E2_EMIS1
							Replace HISTOR		With STR0013 + SE2->E2_FATURA
							Replace VALOR			With xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,MV_PAR16,,nDecs+1)
							Replace VENCTO		With SE2->E2_VENCREA
							Replace DENOM 		With cCodDesc
							IF Substr(SE2->E2_TIPO,3,1) != "-" .and. ! ( SE2->E2_TIPO $ "PA /"+MV_CPNEG)
								Replace DC     With "D"
							Else
								Replace DC     With "C"    //Abatimentos/PA/NDF
							Endif
							MsUnlock()
							dbSelectArea("SE2")
							dbSkip()
						EndIf

					Enddo
				Endif
			Endif
			dbSelectArea("SE2")
			dbSetOrder(nOrdSe2Atu)
			dbGoto(nRegSe2Atu)
			dbSkip()
		Enddo
	//Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza na movimentacao bancaria, os titulos do periodo     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE5")
	dbSetOrder(7)
	If mv_par09 = 1
		dbSeek(xFilial(),.T.) // Com SoftSeek ON
		cCondE5:="'"+xFilial('SE5')+"' == SE5->E5_FILIAL"
	Else
		cArqTrab :=CriaTrab(NIL,.F.)
		AADD(aInd,cArqTrab)
		cIndE5   :=IndexKey()
		cIndE5   :=Right(cIndE5,Len(cIndE5)-10)
		IndRegua("SE5",cArqTrab,cIndE5,,,OemToAnsi(STR0011))  //"Selecionando Registros..."
		cCondE5:=".T."
		dbCommit()
		nIndex:=RetIndex("SE5")
		dbSelectArea("SE5")
		#IFNDEF TOP
			dbSetIndex(cArqTrab+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndex+1)
		dbGoTop()

		// SE1
		dbSelectArea("SE1")
		dbSetOrder(1)
		cArqTrab :=CriaTrab(NIL,.F.)
		AADD(aInd,cArqTrab)
		cIndE1   :=IndexKey()
		cIndE1   :=Right(cIndE1,Len(cIndE1)-10)
		IndRegua("SE1",cArqTrab,cIndE1,,,OemToAnsi(STR0011)) //"Selecionando Registros..."
		dbCommit()
		nIndex:=RetIndex("SE1")
		dbSelectArea("SE1")
		#IFNDEF TOP
			dbSetIndex(cArqTrab+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndex+1)
		dbGoTop()

		//SE2
		dbSelectArea("SE2")
		dbSetOrder(1)
		cArqTrab :=CriaTrab(NIL,.F.)
		AADD(aInd,cArqTrab)
		cIndE2   :=IndexKey()
		cIndE2   :=Right(cIndE2,Len(cIndE2)-10)
		IndRegua("SE2",cArqTrab,cIndE2,,,OemToAnsi(STR0011))  //"Selecionando Registros..."
		dbCommit()
		nIndex:=RetIndex("SE2")
		dbSelectArea("SE2")
		#IFNDEF TOP
			dbSetIndex(cArqTrab+OrdBagExt())
		#ENDIF
		dbSetOrder(nIndex+1)
		dbGotop()
	EndIf
	//If mv_par15==1  -->Siempre se seleccionaran TODOS
		dbSelectArea("SE5")
		While !SE5->(Eof()) .and. &(cCondE5)

			If Empty(SE5->E5_NUMERO) .Or. SE5->E5_SITUACA = "C" .Or. !SE5->E5_TIPODOC $ "VLüBAüCPüV2üLJüES"
				SE5->(dbSkip())
				Loop
			EndIf
			//Ignorar baixas do Loja de titulos a vista
			If cPaisLoc <> "BRA" .And. SE5->E5_RECPAG=='R' .And. IsMoney(SE5->E5_TIPO) .And. SE5->E5_TIPODOC == "LJ"
				SE5->(dbSkip())
				Loop
			EndIf

			If SE5->E5_PREFIXO < mv_par07 .Or. SE5->E5_PREFIXO > mv_par08
				SE5->(dbSkip())
				Loop
			EndIf

			If  ( SE5->E5_NATUREZ < mv_par11 .Or. SE5->E5_NATUREZ > mv_par12 )
				SE5->(dbSkip())
				Loop
			EndIf

			If cPaisLoc	# "BRA"
				SA6->(DbSetOrder(1))
				SA6->(DbSeek(xFilial()+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
				nMoedaBco := Max(SA6->A6_MOEDA,1)
			else
				nMoedaBco:=1
			Endif

			if MV_PAR14==2 .AND. MV_PAR13<>nMoedaBco
				SE5->(dbskip())
				Loop
			endif

			If SE5->E5_RECPAG == "R"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica quais serao impressos                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	         If mv_par06 == 2 .and. (E5_TIPO $ MVRECANT+","+MV_CRNEG)    // So'Normais
					dbSkip()
					Loop
				Endif

	         If mv_par06 == 3 .and. !(E5_TIPO $ MVRECANT+","+MV_CRNEG)  //So'Adiantamentos
					dbSkip()
					Loop
				Endif
			ElseIf SE5->E5_RECPAG == "P"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica quais serao impressos                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	         If mv_par06 == 2 .and. ( E5_TIPO $ MVPAGANT+","+MV_CPNEG ) // So'Normais
					dbSkip( )
					Loop
				Endif

	         If mv_par06 == 3 .and. E5_TIPO != MVPAGANT+","+MV_CPNEG  //So'Adiantamentos
					dbSkip()
					Loop
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ignora PA's pagos com Junta de Cheque                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If E5_TIPO=="PA " .and. E5_TIPODOC == "BA" .and. !empty(E5_NUMCHEQ)
					DbSkip()
					Loop
				Endif
			Endif

			IF SE5->E5_DTDIGIT > mv_par02
				SE5->(dbSkip( ) )
				Loop
			Endif

			IF SE5->E5_CLIFOR < mv_par03 .Or. SE5->E5_CLIFOR > mv_par04
				SE5->(dbSkip())
				Loop
			EndIF

			/*if mv_par03 == 1 .and. SE5->E5_RECPAG == "R" .and. SE5->E5_TIPODOC =="ES"
				dbskip()
				loop
			Elseif mv_par03 == 2 .and. SE5->E5_RECPAG == "P" .and. SE5->E5_TIPODOC =="ES"
				dbskip()
				loop
			endif
			*/
			If SE5->E5_RECPAG == "P" .and. SE5->E5_TIPODOC =="ES"
				dbskip()
				loop
			endif
			/*IF mv_par03 == 1 .and. SE5->E5_RECPAG != "R"
	            If ! (SE5->E5_TIPO $ MVRECANT+","+MV_CRNEG) .And. SE5->E5_TIPODOC != "ES"     //Baixa de RA
					SE5->(dbSkip())
					Loop
				End
			EndIF*/

			IF SE5->E5_RECPAG != "P"
	            If ! (SE5->E5_TIPO $ MVPAGANT+","+MV_CPNEG) .And. SE5->E5_TIPODOC != "ES"       //Baixa de PA
					SE5->(dbSkip())
					Loop
				End
			End

			/*If mv_par03 == 1        // Se for baixa de adiantamentos
	            If SE5->E5_RECPAG == "R" .and. E5_TIPO $ MVPAGANT+","+MV_CPNEG .And. SE5->E5_TIPODOC $ "VL/BA"
					dbSkip()
					LOOP
				End
			End*/

			//If mv_par03 == 2        // Se for baixa de adiantamentos
	       If SE5->E5_RECPAG == "P" .and. E5_TIPO $ MVRECANT+","+MV_CRNEG .And. SE5->E5_TIPODOC $ "VL/BA"
				dbSkip()
				LOOP
			End
			//End

			If ! Inside(SE5->E5_TIPO)
				dbSkip()
				Loop
			Endif

			nRec := SE5 -> ( Recno () )
			nPrim:= 0
			cPrefixo := SE5->E5_PREFIXO
			cNumero  := SE5->E5_NUMERO
			cParcela := SE5->E5_PARCELA
			cTipo    := SE5->E5_TIPO
			cNaturez := SE5->E5_NATUREZ
			nValliq  := 0
			cFornece := SE5->E5_CLIFOR
			cLoja    := SE5->E5_LOJA
			dDtDigit := SE5->E5_DTDIGIT
			cRecPag  := SE5->E5_RECPAG
			cSeq     := SE5->E5_SEQ

			IF nAnterior = 0
				cAnterior := cPrefixo+cNumero+cParcela+cTipo+cFornece+Dtos(dDtDigit)+SE5->E5_RECPAG
				nAnterior := 1
				If mv_par10 = 1
					dbSeek(xFilial()+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja+cSeq)
				Else
					dbSeek(cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja+cSeq)
				EndIf
			EndIF

			While ! SE5->(Eof()) .and. SE5->E5_PREFIXO==cPrefixo .and. ;
				SE5->E5_NUMERO==cNumero   .and. ;
				SE5->E5_PARCELA==cParcela .and. ;
				SE5->E5_TIPO==cTipo       .and. ;
				SE5->E5_CLIFOR==cFornece  .and. ;
				SE5->E5_LOJA==cLoja       .and. ;
				SE5->E5_SEQ==cSeq

				/*If mv_par03 == 2 .and. SE5->E5_CLIFOR+E5_LOJA != cFornece+cLoja
					Exit
				Endif*/

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Devera' ser considerado o valor sem liquido da baixa         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF Empty(SE5->E5_NUMERO) .Or. SE5->E5_SITUACA = "C"
					SE5->(dbSkip())
					Loop
				EndIF

				IF SE5->E5_DTDIGIT > mv_par02
					SE5->(dbSkip( ) )
					Loop
				End

				IF SE5->E5_CLIFOR < mv_par03 .Or. SE5->E5_CLIFOR > mv_par04
					SE5->(dbSkip())
					Loop
				EndIF

	/*			If cPaisLoc<>"BRA" .and. E5_TIPO=="EF " .and. !Empty(E5_ORDREC)
					dbskip()
					Loop
				Endif
	*/
			 /*IF mv_par03 == 1 .and. SE5->E5_RECPAG != "R"
					If ! ( SE5->E5_TIPO $ MVRECANT+","+MV_CRNEG ) .AND. SE5->E5_TIPODOC !="ES"       //Baixa de RA
						SE5->(dbSkip())
						Loop
					Endif
				EndIF*/

				//IF mv_par03 == 2 .and. SE5->E5_RECPAG != "P"
				IF SE5->E5_RECPAG != "P"
					If ! ( SE5->E5_TIPO $ MVPAGANT+","+MV_CPNEG ) .AND. SE5->E5_TIPODOC !="ES"       //Baixa de PA
						SE5->(dbSkip())
						Loop
					Endif
				Endif


				if MV_PAR14==2 .AND. MV_PAR15 <> nMoedaBco
					SE5->(dbSkip())
					Loop
				endif

				If nPrim == 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Localiza o cliente ou fornecedor                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCarteira := SE5->E5_RECPAG
					If SE5->E5_RECPAG == "R"
	               If (SE5->E5_TIPO $ MVPAGANT+","+MV_CPNEG).and.SE5->E5_TIPODOC $ "BAüVL" .and. !Empty(SE5->E5_BANCO);
							.OR. SE5->E5_TIPODOC =="ES"
							cCarteira := "P"        //Baixa de adiantamento (inverte)
						End
					End

					If SE5->E5_RECPAG == "P"
	               If SE5->E5_TIPO $ MVRECANT+","+MV_CRNEG .And. SE5->E5_TIPODOC $ "BAüVL" .And.!Empty(SE5->E5_BANCO);
							.OR. SE5->E5_TIPODOC =="ES"
							cCarteira := "R"        //Baixa de adiantamento (inverte)
						End
					End

					IF cCarteira == "R"
						dbSelectArea("SE1")
						If mv_par09 = 1
							dbSetOrder(1)
							dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO)
						Else
							dbSeek(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO)
						EndIf
					Else
						dbSelectArea("SE2")
						If mv_par09 = 1
							dbSetOrder(1)
							dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA)
						Else
							dbSeek(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA)
						EndIf
					End

					dbSelectArea("SE5")
					IF cCarteira == "R"
						dEmissao := SE1->E1_EMISSAO
						dVencto  := SE1->E1_VENCREA
					Else
						dEmissao := SE2->E2_EMISSAO
						dVencto  := SE2->E2_VENCREA
					End
					nPrim++
				End


				If SE5->E5_TIPODOC $ "VLüBAüCPüV2üLJüES"
					nValliq+=xmoeda(SE5->E5_VALOR,nMoedaBco,MV_PAR13,,nDecs+1)
					IIF(mv_par05==1,GravaTrab("B",dEmissao,dVencto),NIL)
				ElseIf SE5->E5_TIPODOC $ "DC/D2"
					nValliq+=xmoeda(SE5->E5_VALOR,nMoedaBco,MV_PAR13,,nDecs+1)
					IIF(mv_par05==1,GravaTrab("D",dEmissao,dVencto),NIL)
				Elseif SE5->E5_TIPODOC $ "MT/JR/J2/M2"
					IIF(mv_par05==1,GravaTrab("M",dEmissao,dVencto),NIL)
					nValliq-=xmoeda(SE5->E5_VALOR,nMoedaBco,MV_PAR13,,nDecs+1)
				Elseif SE5->E5_TIPODOC $ "CM/C2/CX"
					IIF(mv_par05==1,GravaTrab("C",dEmissao,dVencto),NIL)
					nValLiq-=xmoeda(SE5->E5_VALOR,nMoedaBco,MV_PAR13,,nDecs+1)
				End
				SE5->(dbSkip())
			End
			nRec1 := SE5 -> ( Recno () )
			dbGoto(nRec)
			if mv_par05==2 .and. nValLiq != 0
				GravaTrab("B",dEmissao,dVencto,nValLiq)
			End
			dbGoto(nRec1)
			nAnterior := 0
		End
	//Endif
	nTotDebG := 0
	nTotCrdG := 0
	nSalAtuG := 0

	SetRegua(RecCount())
	DbSelectArea("cNomeArq")
	DbGoTop()
	While !Eof()

		#IFNDEF WINDOWS
			Inkey()
			If LastKey() = K_ALT_A
				lEnd := .t.
			End
		#ENDIF

		IF lEnd
			@Prow()+1,0 PSAY OemToAnsi(STR0014) //"***** Cancelado pelo Operador *****"
			Exit
		End

		cCodigo  := CODIGO
		cLoja    := LOJA
		nSaldoAtu:= 0
		nTotDeb     := 0
		nTotCrd  := 0

		IF li>50
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
			li:=8
		End

		nRegAtu := RecNo()
		lImprime := .F.
		While cNomeArq->CODIGO == cCodigo .And. cNomeArq->LOJA == cLoja .And. ! Eof()

			If (If(mv_par15==1,DATAEMI,EMISSAO) >= mv_par01 )   // Procura titulos no intervalo e
				lImprime := .T.     // se houver, dever  imprimir
				Exit
			Endif
			dbSkip()
		Enddo
		dbGoto(nRegAtu)

		While cNomeArq->CODIGO == cCodigo .And. cNomeArq->LOJA == cLoja .And. ! Eof()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Loop para calculo do saldo anterior                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While cNomeArq->CODIGO == cCodigo .And. cNomeArq->LOJA == cLoja .And. ;
				If(mv_par15==1,cNomeArq->DATAEMI,cNomeArq->EMISSAO) < mv_par01 .And. ! Eof()
					If DC == "C"
						nSaldoAtu += cNomeArq->VALOR
					Else
						nSaldoAtu -= cNomeArq->VALOR
					EndIf
				///Suma de retenciones IGV
				/*IF cNomeArq -> TIPO $ "TX  "
					If DC == "D"
						nTotRet -= cNomeArq->VALOR
					Else
						nTotRet += cNomeArq->VALOR
					End IF
				End If*/

				IncRegua()

				dbSkip()
				If cNomearq->CODIGO != ccodigo .Or. cNomeArq->LOJA != cLoja
					lNoSkip := .T.
				Endif
			Enddo

			If lImprime .Or. nSaldoAtu != 0
				If li > 60
					IF m_pag>1
						li++
						@ li,072 PSAY OemToAnsi(STR0015)  //"A TRANSPORTAR : "
						@ li,113 PSAY Abs(nSaldoAtu)    Picture tm(Abs(nSaldoAtu),14)
						//@ li,131 PSAY IIF(nSaldoAtu<0,"D",IIF(nSaldoAtu>0,"C"," "))
					Endif

					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
					li:=8

					If nQuebra == 1
							dbSelectArea("SA2")
							If mv_par09 = 1
								dbSeek(xFilial()+cCodigo+cLoja)
							Else
								If cIndA2 == " "
									cArqTrab :=CriaTrab(NIL,.F.)
									AADD(aInd,cArqTrab)
									cIndA2   :=IndexKey()
									cIndA2   :=Right(cIndA2,Len(cIndA2)-10)
									IndRegua("SA2",cArqTrab,cIndA2,,,OemToAnsi(STR0011))  //"Selecionando Registros..."
									dbCommit()
									nIndex:=RetIndex("SA2")
									dbSelectArea("SA2")
									#IFNDEF TOP
										dbSetIndex(cArqTrab+ordBagExt())
									#ENDIF
									dbSetOrder(nIndex+1)
								EndIf
								dbSeek(cCodigo+cLoja)
							EndIf
							cNome := SA2->A2_NOME+" "+SA2->A2_CGC+" "+SA2->A2_CONTA

						li++
						If cPaisLoc == 'BRA'
							@li+1,000 PSAY OemToAnsi(STR0022) + cCodigo + "-" + cLoja + " " + cNome
							li++
							//@li,092 PSAY OemToAnsi(STR0028)  //"DE TRANSPORTE : "
							//@li,116 PSAY Abs(nSaldoAtu) Picture tm(Abs(nSaldoAtu),14)
							li++
						Else

							SA2->( dbSetOrder(1) )
							SA2->( dbSeek(xFilial("SA2")+cCodigo+cLoja) )

							li+=1
							@li+1,000 PSAY OemToAnsi(STR0022) + cCodigo + "-" + cLoja
							li+=2
							@li,000 PSAY Subs(SA2->A2_NOME,1,40)
							//@li,050 PSAY cCodigo + "-" + cLoja
							//MLCM @li,092 PSAY OemToAnsi(STR0028)  //"TRANSPORTAR : "
							//MLCM @li,116 PSAY Abs(nSaldoAtu) Picture tm(Abs(nSaldoAtu),14)
							//@li,131 PSAY IIF(nSaldoAtu<0,"D",IIF(nSaldoAtu>0,"C"," "))
							li+=2

							EndIf

					EndIf
				Endif
			EndIf

			If nQuebra == 0 .and. (lImprime .Or. nSaldoAtu != 0 )
				nQuebra  := 1
				lImprAnt := .F.
				dbSelectArea("SA2")
				If mv_par09 = 1
					dbSeek(xFilial()+cCodigo+cLoja)
				Else
					If cIndA2 == " "
						cArqTrab :=CriaTrab(NIL,.F.)
						AADD(aInd,cArqTrab)
						cIndA2   :=IndexKey()
						cIndA2   :=Right(cIndA2,Len(cIndA2)-10)
						IndRegua("SA2",cArqTrab,cIndA2,,,OemToAnsi(STR0011))  //"Selecionando Registros..."
						dbCommit()
						nIndex:=RetIndex("SA2")
						dbSelectArea("SA2")
						#IFNDEF TOP
							dbSetIndex(cArqTrab+OrdBagExt())
						#ENDIF
						dbSetOrder(nIndex+1)
					EndIf
					dbSeek(cCodigo+cLoja)
				EndIf

				cNome := SA2->A2_NOME+" "+SA2->A2_CGC+" "+SA2->A2_CONTA
				//EndIF

				If cPaisLoc == "BRA"
					@li,000 PSAY cCodigo + "-" + cLoja + " " + cNome
					dbSelectArea("cNomeArq")
					li++
					@li, 60 PSAY OemToAnsi(STR0016)  //"SALDO ANTERIOR : "
					@li,114 PSAY Abs(nSaldoAtu)     Picture tm(Abs(nSaldoAtu),14)
					//@li,131 PSAY IIF(nSaldoAtu<0," D",IIF(nSaldoAtu>0," C"," "))
					nSalAntG += nSaldoAtu
					li++
				Else

					SA2->( dbSetOrder(1) )
					SA2->( dbSeek(xFilial("SA2")+cCodigo+cLoja) )

					li+=1
					@li,000 PSAY OemToAnsi(STR0022) + cCodigo + "-" + cLoja
					li+=1
					@li,000 PSAY Subs(SA2->A2_NOME,1,40)
					li++
					@li,60 PSAY OemToAnsi(STR0016)  //"SALDO ANTERIOR : "
					@li,IIF(nSaldoAtu>0,84,99) PSAY Abs(nSaldoAtu) Picture tm(Abs(nSaldoAtu),14)
					nSalAntG += nSaldoAtu

				EndIf

			End
			dbSelectArea("cNomeArq")

			If (If(mv_par15==1,cNomeArq->DATAEMI,cNomeArq->EMISSAO) >= mv_par01 ).And. !lNoSkip
				If DC == "D"
					nSaldoAtu -= cNomeArq->VALOR
					nTotDeb   += cNomeArq->VALOR
					nTotDebG  += cNomeArq->VALOR
					nSalAtuG  -= cNomeArq->VALOR
				Else
					nSaldoAtu += cNomeArq->VALOR
					nTotCrd   += cNomeArq->VALOR
					nTotCrdG  += cNomeArq->VALOR
					nSalAtuG  += cNomeArq->VALOR
				End
				IF cNomeArq -> TIPO $ "TX  "
					If DC == "D"
						nTotRet -= cNomeArq->VALOR
					Else
						nTotRet += cNomeArq->VALOR
					End IF
				End If

				//If mv_par14 == 1  // Analitico
				li++
				aTam := TamSX3("E1_NUM")
				If !Empty(DATAEMI)
					@li,000 PSAY DATAEMI
				Endif
				@li,012 PSAY DENOM
				If Subs(HISTOR,1,7)== OemToAnsi(STR0041)	// "Recibo:"
					@li,049 PSAY OemToAnsi(STR0040) + SubStr(HISTOR,8,8)	// "RECIBO No.: "
				ElseIf Subs(HISTOR,1,11)== OemToAnsi(STR0043)	// "Baja recibo"
					@li,049 PSAY OemToAnsi(STR0040) + SubStr(HISTOR,17,6)	// "RECIBO No.:"
				Else
					@li,049 PSAY SubStr(HISTOR,1,22)
				EndIf

				@li,72 PSAY TIPOTRANS
				@li,033 PSAY (SubStr(NUMERO, 1,3) +SubStr(NUMERO, 4,aTam[1]) +Substr(NUMERO,aTam[1]+4,1))
				//@li,037 PSAY SubStr(NUMERO, 4,aTam[1])
				//@li,051 PSAY SubStr(NUMERO,aTam[1]+4,1)

				//@li,053 PSAY EMISSAO
				//@li,064 PSAY VENCTO
				/*IF !Empty(BAIXA)
					@li,075 PSAY BAIXA
				End*/

				@li,IIF(DC=="D",85,100) PSAY cNomeArq->VALOR PicTure tm(cNomeArq->VALOR,14)
				@li,114 PSAY Abs(nSaldoAtu)      Picture tm(Abs(nSaldoAtu),14)
				//@li,131 PSAY IIF(nSaldoAtu<0,"D",IIF(nSaldoAtu>0,"C"," "))
				//Endif
			End
			lFlag := .T.
			If ! lNoSkip
				IncRegua()
				dbSkip( )
			End
			lNoSkip := .F.
		End
		If lImprime .Or. nSaldoAtu != 0
			li+= 2
			@li,072 	PSAY OemToAnsi(STR0017) //"TOTALES
			@li,84 	PSAY nTotDeb               Picture tm(nTotDeb,14)
			@li,99 	PSAY nTotCrd               Picture tm(nTotCrd,14)
			@li+1,72	PSAY OemToAnsi(STR0059)
			@li+1,113 	PSAY Abs(nSaldoAtu)     	Picture tm(Abs(nSaldoAtu),14)
			//@li,131 PSAY IIF(nSaldoAtu<0,"D",IIF(nSaldoAtu>0,"C"," "))
			li++
			@li+1,  0  PSAY Repl("-",132)
			li++
		Endif
		nQuebra:=0
	End

	If nQuebra # 0 .and.(lImprime .Or. nSaldoAtu != 0)
		li+=2
		@li,072  	PSAY OemToAnsi(STR0017)//"T o t a i s  d o  "###"C l i e n t e"###"F o r n e c e d o r"
		@li,084 	PSAY nTotDeb                Picture tm(nTotDeb,14)
		@li,099  	PSAY nTotCrd                Picture tm(nTotCrd,14)
		@li+1,060 	PSAY OEMTOANSI(STR0059)
		@li+1,115  PSAY Abs(nSaldoAtu)			Picture tm(Abs(nSaldoAtu),14)
		//@li,131  PSAY IIF(nSaldoAtu<0,"D",IIF(nSaldoAtu>0,"C"," "))
	End
	If lFlag
		li++
		IF li>50
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
			li:=8
		End
		//@li,  0  PSAY OemToAnsi(STR0020)//+OemToAnsi(STR0022)  //"T o t a l   G e r a l  d o s  "###"C l i e n t e s"###"F o r n e c e d o r e s"
		//@li, 86  PSAY nTotDebG               Picture tm(nTotDebG,14)
		//@li,101  PSAY nTotCrdG               Picture tm(nTotCrdG,14)
		//@li,116  PSAY Abs(nSalAtuG)      Picture tm(Abs(nSalAtuG),14)
		//@li,131  PSAY IIF(nSalAtuG<0,"D",IIF(nSalAtuG>0,"C"," "))
		li+=2
		//@li, 0   PSAY Repl("-",132)
		li++
		@li, 060  PSAY OemToAnsi(STR0023)  //"(*) Total de Retenciones del Mes "
		//nSaldoFinal := (nSalAntG-nTotDebG+nTotCrdG)
		nSaldoFinal := nTotRet
		@li, 113 PSAY Abs(nSaldoFinal)  Picture tm(Abs(nSaldoFinal),14)
		//@li ,131 PSAY IIF(nSaldoFinal<0,"D",IIF(nSaldoFinal>0,"C"," "))
		li++
		//@li+1, 0 PSAY Repl("-",132)
	End
	Roda( cbCont, cbTxt, Tamanho )
	dbSelectArea("cNomeArq")
	Use
	//Ferase(cNomeArq+GetDBExtension())         // Elimina arquivos de Trabalho
	//Ferase(cNomeArq+OrdBagExt())    // Elimina arquivos de Trabalho

	dbSelectArea("SA1")
	RetIndex("SA1")
	dbSetOrder(1)
	DbClearFilter()

	dbSelectArea("SA2")
	RetIndex("SA2")
	dbSetOrder(1)
	DbClearFilter()

	dbSelectArea("SE1")
	RetIndex("SE1")
	dbSetOrder(1)
	DbClearFilter()

	dbSelectArea("SE2")
	RetIndex("SE2")
	dbSetOrder(1)
	DbClearFilter()

	dbSelectArea("SE5")
	RetIndex("SE5")
	dbSetOrder(1)
	DbClearFilter()

	For nI:=1 to Len(aInd)
		if File(aInd[nI]+OrdBagExt())
			Ferase(aInd[nI]+OrdBagExt())
		Endif
	   If File(aInd[nI]+GetDBExtension())
	      Ferase(aInd[nI]+GetDBExtension())
	   Endif
	Next

	Set Device To Screen
	If aReturn[5] = 1
		Set Printer To
		Commit
		Ourspool(wnrel)
	Endif
MS_FLUSH()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaTrab ³ Autor ³ Wagner Xavier         ³ Data ³ 25.02.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava um registro no arquivo de trabalho para impressao     ³±±
±±³          ³do Razonete.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³GravaTrab( ExpC1, ExpD1, ExpD2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaTrab( cTipo,dEmissao,dVencto,nValor )
Local cHist,cDCR,cDCP,cAlias:=Alias()
Local ndecs:=MsDecimais(MV_PAR13)
Local aAreaSE2 := {}
Local lCheque := .F.
Local cChaveSE5 := ""
Local cFornece	:= ""
Local cLoja 	:= ""
If cPaisLoc	# "BRA"
	SA6->(DbSetOrder(1))
	SA6->(DbSeek(xFilial()+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
	nMoedaBco := Max(SA6->A6_MOEDA,1)
else
	nMoedaBco:=1
Endif

nValor := Iif( nValor=Nil,xmoeda(SE5->E5_VALOR,nMoedaBco,MV_PAR13,,nDecs+1),nValor )

Do Case
	Case cTipo == "B"
		cHist := Iif(Empty(SE5->E5_HISTOR) .or. (cPaisloc<>"BRA" .and. SE5->E5_TIPODOC $ "VL".AND. Empty(SE5->E5_ORDREC)),OemToAnsi(STR0024),SE5->E5_HISTOR)  //"Ref. a Baixa do Titulo"
		cDCR="C"
		cDCP="D"
	Case cTipo == "D"
		cHist := OemToAnsi(STR0025)  //"Desconto sobre o titulo"
		cDCR="C"
		cDCP="D"
	Case cTipo == "M"
		cHist := OemToAnsi(STR0026)  //"Multa/Juros s/ o Titulo"
		cDCR="D"
		cDCP="C"
	OtherWise
		cHist := OemToAnsi(STR0027)  //"Corr.Monetaria s/ o Titulo"
		cDCR="D"
		cDCP="C"
EndCase

//Gerou cheque no SE2
If SE5->E5_TIPODOC $ "BA"

	cFornece := SE5->E5_CLIFOR
	cLoja := SE5->E5_LOJA
	cChaveSE5 := xFilial("SE5")+Space(TamSx3("E5_PREFIXO")[1])+PadR(SE5->E5_ORDREC,TamSx3("E5_NUMERO")[1])+Space(TamSx3("E5_PARCELA")[1])

	dbSelectArea("SE2")
	aAreaSE2:= SE2->(GetArea())
	SE2->(dbSetOrder(1))

	If SE2->(dbSeek(cChaveSE5))
		While !SE2->(Eof()) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA) == cChaveSE5 .And. SE2->(E2_FORNECE+E2_LOJA) == cFornece+cLoja
			If SE2->(E2_TIPO) $ MVCHEQUES
				lCheque := .T.
				Exit
			Endif
			SE2->(dbSkip())
		EndDo
	Endif

	SE2->(RestArea(aAreaSE2))
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava registro no arquivo de trabalho                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	//   If ! dbSeek(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA)
	Reclock("cNomeArq",.t.)
	Replace CODIGO  With SE5->E5_CLIFOR
	Replace LOJA    With SE5->E5_LOJA
	Replace NUMERO  With ALLTRIM(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA)
	Replace BANCO   With SE5->E5_BANCO
	Replace BAIXA   With SE5->E5_DATA
	Replace VALOR   With nValor
	Replace HISTOR  With cHist
	If mv_par15 == 1
		Replace DATAEMI With SE5->E5_DTDIGIT
		Replace EMISSAO With dEmissao
	Else
		Replace EMISSAO With dEmissao
	Endif
	Replace VENCTO  With dVencto
	Replace TIPO    With SE5->E5_TIPO
	If SE5->E5_RECPAG = "R"
         Replace DC With If( !( SE5->E5_TIPO $ MVRECANT+","+MV_CRNEG) .or.;
		SE5->E5_TIPODOC=="ES",cDCR,cDCP)
	Else
         Replace DC With If( !( SE5->E5_TIPO $ MVPAGANT+","+MV_CPNEG).or. ;
		SE5->E5_TIPODOC=="ES",cDCP,cDCR)
      EndIf
	MsUnlock()

ElseIf SE5->E5_TIPO $ "TF ,EF " .Or. (SE5->E5_TIPO $ "NF " .And. SE5->E5_TIPODOC $ "DC") .Or. (SE5->E5_TIPODOC $ "VL".And. Empty(SE5->E5_ORDREC)) .Or. lCheque

	If MV_PAR14==1 .or. MV_PAR13==SE2->E2_MOEDA

		//Denominacion
		cCodGob := POSICIONE("CCM",1,XFILIAL("CCM")+SE5->E5_TIPO,"CCM_CODGOV")
		cCodDesc:= POSICIONE("CCL",1,XFILIAL("CCM")+cCodGob,"CCL_DESCRI")

		Reclock("cNomeArq",.t.)
		Replace CODIGO  With SE5->E5_CLIFOR
		Replace LOJA    With SE5->E5_LOJA
		Replace NUMERO  With ALLTRIM(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA)
		Replace BANCO   With SE5->E5_BANCO
		Replace VALOR   With nValor
		Replace VENCTO  With dVencto
		Replace TIPO    With SE5->E5_TIPO
		If mv_par15 == 1
			Replace DATAEMI With SE5->E5_DTDIGIT
			Replace EMISSAO With dEmissao
		Else
			Replace EMISSAO With dEmissao
		Endif

		If SE5->E5_RECPAG = "R"
         	Replace DC 		With If( !(SE5->E5_TIPO $ MVRECANT+","+MV_CRNEG),cDCR,cDCP)
			Replace BAIXA   With SE1->E1_EMISSAO
			If ! Empty(SE5->E5_ORDREC) .AND. SE5->E5_TIPODOC == "BA"
				Replace HISTOR  With  OemToAnsi(STR0041) + SE5->E5_ORDREC	// "RECIBO: "      // Diego 12/08/99
			Else
				Replace HISTOR  With cHist
			EndIf
		ELSE
       		Replace DC With If( !(SE5->E5_TIPO $ MVPAGANT+","+MV_CPNEG),cDCP,cDCR)
			Replace BAIXA   With SE5->E5_DATA
			If ! Empty(SE5->E5_ORDREC) .AND. SE5->E5_TIPODOC == "BA"
				Replace HISTOR  With  OemToAnsi(STR0042) + SE5->E5_ORDREC	// "ORDEN DE PAGO: "      // Diego 12/08/99
				Replace TIPOTRANS With OemToansi(STR0055) //PAgo
			Else
				Replace HISTOR  With cHist
			EndIf
      	EndIf
      	If SE5->E5_TIPO $ "TF ,EF ,PA "
			Replace TIPOTRANS With OemToansi(STR0055)
		Else
			Replace TIPOTRANS With SE5->E5_TIPO
		End If
		Replace DENOM with IIF(!Empty(cCodDesc),cCodDesc,SE5->E5_TIPO)
		lCheque := .F.
		MsUnlock()

	Endif
EndIf

dbSelectArea(cAlias)
Return Nil


Static Function InSide(cTp)
Return If(mv_par10 == 1, cTp $ cTipos, .t.)




//---------------------------------------------------------------------------------------
// Obtiene los datos fiscales de la empresa.
// Autor: Mayra Camargo
//----------------------------------------------------------------------------------------
Static function getDatosEmp()
	Local aData := {}
	dbSelectArea("SM0")
	dbsetorder(1)
	dbSeek(cEmpAnt+cFilAnt)

	If Found()
		AADD(aData,SM0->M0_CGC)
		AADD(aData,SM0->M0_NOMECOM)
	End If

Return aData
