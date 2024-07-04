#INCLUDE "GPER007COS.CH"
#INCLUDE "PROTHEUS.CH"

#IFNDEF CRLF
	#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPER007COS  ³ Autor ³ Flor - HUB Mexico     ³ Data ³ 15.09.11 		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao de Recibos de Pagamento Costa Rica                 			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER007COS(void)                                           			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC 			 ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³00000024237/2011|Foi adicionado todas as perguntas pertine-³±±
±±³            ³        ³      			 |ntes ao IMPREC mediante ajustaSx1()       ³±±
±±³Christiane V³26/10/11³00000024237/2011³Correção de Error Log na emissão do recibo³±±
±±³Raquel Hager³15/05/12³00000011889/2012³Ajustes de: alinhamento e captura de par. ³±±
±±³Leandro Dr. ³19/10/12³          TFWRUN³Alteracao no nome para possibilitar       ³±±
±±³            ³        ³                ³inclusao no ATUSX como rdmake.            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function GPR007COS(lTerminal,cFilTerminal,cMatTerminal,cMesAnoRef,nRecTipo,cSemanaTerminal)

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Locais (Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local cString:="SRA"        // alias do arquivo principal (Base)
	Local aOrd   := {STR0001,STR0002,STR0003,STR0004,STR0005} //"Matricula"###"C.Custo"###"Nome"###"Chapa"###"C.Custo + Nome"
	Local cDesc1 := STR0006		//"Emiss„o de Recibos de Pagamento."
	Local cDesc2 := STR0007		//"Devido a tilizacäo de caracteres de compressäo,  e necessario que na impressäo"
	Local cDesc3 := STR0008		//" em formulario seja selecionado, no Tipo de Impressäo, a opcäo 'Direta na Porta'. "
	Local aDriver:= ReadDriver()
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Locais (Programa)                           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local cIndCond
	Local Baseaux 	:= "S"
	Local cHtml 	:= ""
	Local cMes		:= ""
	Local cAno		:= ""
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o numero da linha de impressão como 0                 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	SetPrc(0,0)
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Private(Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private aReturn  := {STR0009, 1,STR0010, 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
	Private nomeprog := "GPER007COS"
	Private aLinha   := { }
	Private nLastKey := 0
	Private cPerg    := "GPR007COS"
	Private nAteLim , nBaseFgts , nFgts , nBaseIr , nBaseIrFe
	
	Private cCompac := aDriver[1]
	Private cNormal := aDriver[2]
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Private(Programa)                           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private aLanca 		:= {}
	Private aProve 		:= {}
	Private aDesco 		:= {}
	Private aBases 		:= {}
	Private aInfo  		:= {}
	Private aCodFol		:= {}
	Private li     		:= _PROW()
	Private Titulo 		:= STR0011		//"EMISSO DE RECIBOS DE PAGAMENTOS"
	Private lEnvioOk 	:= .F.
	Private lRetCanc	:= .t.
	Private cIRefSem    := GetMv("MV_IREFSEM",,"S")
	Private aPerAberto	:= {}
	Private aPerFechado	:= {}
	Private cProcesso	:= "" // Armazena o processo selecionado na Pergunte GPR040 (mv_par01).
	Private cRoteiro	:= "" // Armazena o Roteiro selecionado na Pergunte GPR040 (mv_par02).
	Private cPeriodo	:= "" // Armazena o Periodo selecionado na Pergunte GPR040 (mv_par03).
	Private cCcto		:= ""
	Private cCond		:= ""
	Private cRot		:= ""
	Private cMensRec 	:= ""
	Private cDescProc
	Private nOrdemX :=0
	Private nSumaCon :=0//Imprime mensaje 1=No 2=Si
	
	// Nova ordem de impressao para o Mexico - Local de Pago
	// If cPaisLoc == "MEX"
		// aAdd(aOrd,STR0127)
		// AjustaSX1()
	// Endif
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Envia controle para a funcao SETPRINT                        ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	wnrel:="GPER007COS"            //Nome Default do relatorio em Disco
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica se o programa foi chamado do terminal - TCF         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	lTerminal := If( lTerminal == Nil, .F., lTerminal )
	
	IF !( lTerminal )
		wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)
	EndIF
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define a Ordem do Relatorio                                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	nOrdem := IF( !( lTerminal ), aReturn[8] , 1 )
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica as perguntas selecionadas                           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Pergunte("GPR007COS",.F.)
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cSemanaTerminal := IF( Empty( cSemanaTerminal ) , Space( Len( SRC->RC_SEMANA ) ) , cSemanaTerminal )
	cProcesso  := IF( !( lTerminal ), mv_par01 , cProcTerminal		)   //Processo
	cRoteiro   := IF( !( lTerminal ), mv_par02 , nRecTipo			)	//Emitir Recibos(Roteiro)
	cPeriodo   := IF( !( lTerminal ), mv_par03 , cPerTerminal		)   //Periodo
	Semana     := IF( !( lTerminal ), mv_par04 , cSemanaTerminal	)	//Numero da Semana
	
	//Carregar os periodos abertos (aPerAberto) e/ou 
	// os periodos fechados (aPerFechado), dependendo 
	// do periodo (ou intervalo de periodos) selecionado
	RetPerAbertFech(cProcesso	,; // Processo selecionado na Pergunte.
					cRoteiro	,; // Roteiro selecionado na Pergunte.
					cPeriodo	,; // Periodo selecionado na Pergunte.
					Semana		,; // Numero de Pagamento selecionado na Pergunte.
					NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
					NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
					@aPerAberto	,; // Retorna array com os Periodos e NrPagtos Abertos
					@aPerFechado ) // Retorna array com os Periodos e NrPagtos Fechados
					
	// Retorna o mes e o ano do periodo selecionado na pergunte.
	AnoMesPer(	cProcesso	,; // Processo selecionado na Pergunte.
				cRoteiro	,; // Roteiro selecionado na Pergunte.
				cPeriodo	,; // Periodo selecionado na Pergunte.
				@cMes		,; // Retorna o Mes do Processo + Roteiro + Periodo selecionado
				@cAno		 ) // Retorna o Ano do Processo + Roteiro + Periodo selecionado
	dDataRef := CTOD("01/" + cMes + "/" + cAno)
	
	nTipRel    := IF( !( lTerminal ), 2 , 3				)	//Tipo de Recibo (Pre/Zebrado/EMail)#Por default Costa Rica  "Con Rayas"
	cFilDe     := IF( !( lTerminal ), mv_par05,cFilTerminal		)	//Filial De
	cFilAte    := IF( !( lTerminal ), mv_par06,cFilTerminal		)	//Filial Ate
	cCcDe      := IF( !( lTerminal ), mv_par11,SRA->RA_CC		)	//Centro de Custo De
	cCcAte     := IF( !( lTerminal ), If(!Empty(mv_par12),mv_par12,Replicate("Z",FWGETTAMFILIAL)),SRA->RA_CC		)	//Centro de Custo Ate
	cMatDe     := IF( !( lTerminal ), mv_par07,cMatTerminal		)	//Matricula Des
	cMatAte    := IF( !( lTerminal ), If(!Empty(mv_par08),mv_par08,"999999"),cMatTerminal		)	//Matricula Ate
	cNomDe     := IF( !( lTerminal ), mv_par09,SRA->RA_NOME		)	//Nome De
	cNomAte    := IF( !( lTerminal ), If(!Empty(mv_par10),mv_par10,Replicate("Z",TamSx3("RA_NOME")[1])),SRA->RA_NOME		)	//Nome Ate
	//ChapaDe    := IF( !( lTerminal ), mv_par14,SRA->RA_CHAPA 	)	//Chapa De
	//ChapaAte   := IF( !( lTerminal ), mv_par15,SRA->RA_CHAPA 	)	//Chapa Ate
	Mensag1    := mv_par19										 	//Mensagem 1
	Mensag2    := mv_par20											//Mensagem 2
	Mensag3    := mv_par21	
	nOrdemX    :=mv_par24
	nSumaCon	  :=mv_par23
	//Mensagem 3
	cSituacao  := IF( !( lTerminal ),mv_par17, fSituacao( NIL , .F. ) )	//Situacoes a Imprimir
	cCategoria := IF( !( lTerminal ),mv_par18, fCategoria( NIL , .F. ))	//Categorias a Imprimir
	cBaseAux   := "N"									   				//Imprimir BaseS
	// If cPaisLoc == "MEX"
		// cLocalDe    := mv_par22		//De Local Pago
		// cLocalAte   := mv_par23		//A Local Pago
	// Endif
	            
	cMensRec := AllTrim( fPosTab( "S018", mv_par22, "=", 4,,,,5) ) //duda
	
	If RCJ->RCJ_CODIGO <> cProcesso
	   DbSelectArea( "RCJ" )
	   DbSetOrder( 1 )  // RCJ_FILIAL + RCJ_CODIGO
	   DbSeek( xFilial( "RCJ" ) + cProcesso, .F. )
	EndIf
	If RCJ->( Eof() )
	   cDescProc := Space(15)
	Else
	   cDescProc := SubStr( RCJ->RCJ_DESCRI, 1, 15 )
	EndIf
	
	If aReturn[5] == 1 .and. nTipRel == 1
		li	:=  0
	EndIf
	
	IF !( lTerminal )
		cMesAnoRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)
	
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Inicializa Impressao                                         ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !fInicia(cString,nTipRel)
			Return
		EndIf
		
	EndIF
	
	DbSelectArea( "SRA" )
	IF nTipRel==3
		IF lTerminal
			cHtml := R030Imp(.F.,wnRel,cString,cMesAnoRef,lTerminal)
		Else
			ProcGPE({|lEnd| R030IMP(@lEnd,wnRel,cString,cMesAnoRef,.f.)},,,.T.)  // Chamada do Processamento
		EndIF
	Else
		RptStatus({|lEnd| R030Imp(@lEnd,wnRel,cString,cMesAnoRef,.f.)},Titulo)  // Chamada do Relatorio
	EndIF
Return( IF( lTerminal , cHtml , NIL ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R030IMP  ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 14.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento Para emissao do Recibo                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R030Imp(lEnd,WnRel,cString,cMesAnoRef,lTerminal)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R030Imp(lEnd,WnRel,cString,cMesAnoRef,lTerminal)
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Locais (Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local aCodBenef   := {}
	Local cAcessaSR1  := &("{ || " + ChkRH("GPER007COS","SR1","2") + "}")
	Local cAcessaSRA  := &("{ || " + ChkRH("GPER007COS","SRA","2") + "}")
	Local cAcessaSRC  := &("{ || " + ChkRH("GPER007COS","SRC","2") + "}")
	Local cAcessaSRD  := &("{ || " + ChkRH("GPER007COS","SRD","2") + "}")
	Local cNroHoras   := &("{ || If(aVerbasFunc[nReg,05] > 0 .And. cIRefSem == 'S', aVerbasFunc[nReg,05], aVerbasFunc[nReg,6]) }")
	Local cHtml		  := ""
	Local nHoras      := 0
	Local nMes, nAno
	Local nX
	Local nReg		  := 0
	Local cPerAnt	  := ""                    
	Local aVerbasFunc := {}
	
	Local dDataLibRh
	Local cMesCorrente	:= getmv("MV_FOLMES")
	Local nTcfDadt		:= If(lTerminal,getmv("MV_TCFDADT",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF 
	Local nTcfDfol		:= If(lTerminal,getmv("MV_TCFDFOL",,0),0)		// indica a quantidade de dias a somar ou diminuir no ultimo dia do mes corrente para liberar a consulta do TCF
	Local nTcfD131		:= If(lTerminal,getmv("MV_TCFD131",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
	Local nTcfD132		:= If(lTerminal,getmv("MV_TCFD132",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
	Local nTcfDext		:= If(lTerminal,getmv("MV_TCFDEXT",,0),0)		// indica o dia a partir do qual esta liberada a consulta ao TCF
	
	
	Local nIdx :=0
	Local aPf	:={}
	Local aDf	:={}
	Local abf	:={}
	Local aPs	:={}
	Local aDs	:={}
	Local abs	:={}
	
	Local nTpf	:=0
	Local nTdf  :=0
	Local nTps	:=0
	Local nTds  :=0
	
	Private tamanho     :=	"M"
	Private limite		:=	132
	Private cDtPago     :=	""
	Private cPict1		:=	"@E 999,999,999.99"
	Private cPict2 		:=	"@E 99,999,999.99"
	Private cPict3 		:=	"@E 9,999,999.99"
	Private cTipoRot 	:=	PosAlias("SRY", cRoteiro, SRA->RA_FILIAL, "RY_TIPO")
	
	If MsDecimais(1) == 0
		cPict1	:=	"@E 99,999,999,999"
		cPict2 	:=	"@E 9,999,999,999"
		cPict3 	:=	"@E 9999,999,999"
	Endif
	
	// Ajuste do tipo da variavel
	nTcfDadt	:= if(valtype(ntcfdadt)=="C",val(ntcfdadt),ntcfdadt)
	nTcfD131	:= if(valtype(nTcfD131)=="C",val(nTcfD131),nTcfD131)
	nTcfD132	:= if(valtype(nTcfD132)=="C",val(nTcfD132),nTcfD132)
	nTcfDfol	:= if(valtype(ntcfdfol)=="C",val(ntcfdfol),ntcfdfol)
	nTcfDext	:= if(valtype(ntcfdext)=="C",val(ntcfdext),ntcfdext)
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	| Verifica se o Mes solicitado esta liberado para consulta no  |
	| terminal de consulta do funcionario.                         |
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If lTerminal
	
		If !empty(cMesCorrente)
			cMesCorrente := substr(cMesCorrente,-2)+substr(cMesCorrente,1,4)
		endif
	
		If	cMesCorrente == cMesArqRef  .or. right(cMesCorrente,4)+left(cMesCorrente,2) == mesano(ddataref) .Or. ;
			mesano(ddataref) > substr(cMesCorrente,3,4)+substr(cMesCorrente,1,2) .Or.;		
			left(cMesArqRef,2) == "13"
	
			If  cTipoRot == "2" //Adiantamento
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
					( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTCFDADT,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				EndIf
			ElseIf cTipoRot == "1" .and. !empty(nTCFDFOL) //Folha
				dDataLibRh := fMontaDtTcf(cMesCorrente,nTCFDFOL)
				If date() < dDataLibRH 
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				Endif
			ElseIf cTipoRot == "5" //1a parcela 13o Salario
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
					( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTCFD131,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				Endif
			ElseIf cTipoRot == "6" //2a parcela 13o Salario
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
					( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTCFD132,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				Endif
			ElseIf cRoteiro == "EXT"  // Valores Extras
				If ( Right(cMesAnoRef,4)+Left(cMesAnoRef,2) > Right(cMesCorrente,4)+Left(cMesCorrente,2) ) .Or.;
					( If(MESANO(DATE()) == SUPERGETMV("MV_FOLMES"),day(date()) < nTCFDEXT,.F.) )
					Return( IF( lTerminal <> NIL .And. lTerminal , cHtml , NIL ) )
				Endif
			endif
		Endif
	Endif
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Selecionando a Ordem de impressao escolhida no parametro.    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea( "SRA")
	IF !( lTerminal )
		If nOrdem == 1
			dbSetOrder(1)
		ElseIf nOrdem == 2
			dbSetOrder(2)
		ElseIf nOrdem == 3
			dbSetOrder(3)
		Elseif nOrdem == 4
			cArqNtx  := CriaTrab(NIL,.f.)
			cIndCond :="RA_Filial + RA_Chapa + RA_Mat"
			IndRegua("SRA",cArqNtx,cIndCond,,,STR0012)		//"Selecionando Registros..."
		ElseIf nOrdem == 5
			dbSetOrder(8)
		ElseIf nOrdem == 6
			dbSetOrder(RetOrder("SRA","RA_FILIAL+RA_KEYLOC+RA_NOME"))
		Endif
		
		dbGoTop()
		
		If nTipRel == 2
			@ LI,00 PSAY AvalImp(Limite)
		Endif
	Endif
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Selecionando o Primeiro Registro e montando Filtro.          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If nOrdem == 1 .or. lTerminal
		cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
		IF !( lTerminal )
			dbSeek(cFilDe + cMatDe,.T.)
			cFim    := cFilAte + cMatAte
		Else
			cFim    := &(cInicio)
		EndIF
	ElseIf nOrdem == 2
		dbSeek(cFilDe + cCcDe + cMatDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
		cFim     := cFilAte + cCcAte + cMatAte
	ElseIf nOrdem == 3
		dbSeek(cFilDe + cNomDe + cMatDe,.T.)
		cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
		cFim    := cFilAte + cNomAte + cMatAte
	ElseIf nOrdem == 4
		dbSeek(cFilDe + ChapaDe + cMatDe,.T.)
		cInicio := "SRA->RA_FILIAL + SRA->RA_CHAPA + SRA->RA_MAT"
		cFim    := cFilAte + ChapaAte + cMatAte
	ElseIf nOrdem == 5
		dbSeek(cFilDe + cCcDe + cNomDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_NOME"
		cFim     := cFilAte + cCcAte + cNomAte
	ElseIf nOrdem == 6
		dbSeek(cFilDe + cLocalDe + cNomDe,.T.)
		cInicio  := "SRA->RA_FILIAL + SRA->RA_KEYLOC + SRA->RA_NOME"
		cFim     := cFilAte + cLocalAte + cNomAte
	Endif
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega Regua Processamento                                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("SRA")
	If nTipRel # 3
		SetRegua(RecCount())	// Total de elementos da regua
	Else
		If !( lTerminal )
			GPProcRegua(RecCount())// Total de elementos da regua
		EndIf
	EndIF
	
	TOTVENC:= TOTDESC:= FLAG:= CHAVE := 0
	
	Desc_Fil := Desc_End := DESC_CC:= DESC_FUNC:=Desc_Bair:= ""
	Desc_Comp:= Desc_Est := Desc_Cid := Desc_CEP := ""
	DESC_MSG1:= DESC_MSG2:= DESC_MSG3:= Space(01)
	dRCHDtIni := PosAlias( "RCH" , (cProcesso+cPeriodo+Semana+cRoteiro), SRA->RA_FILIAL , "RCH_DTINI")
	dRCHDtFim := PosAlias( "RCH" , (cProcesso+cPeriodo+Semana+cRoteiro), SRA->RA_FILIAL , "RCH_DTFIM")
	cFilialAnt := "  "
	Vez        := 0
	OrdemZ     := nOrdemX
	
	While SRA->( !Eof() .And. &cInicio <= cFim )
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Movimenta Regua Processamento                                ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !( lTerminal )
			
			If nTipRel # 3
				IncRegua()  // Anda a regua
			ElseIf !( lTerminal )
				GPIncProc(SRA->RA_FILIAL+" - "+SRA->RA_MAT+" - "+SRA->RA_NOME)
			EndIf
			
			If lEnd
				@Prow()+1,0 PSAY cCancel
				Exit
			EndIf
	
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Consiste Parametrizacao do Intervalo de Impressao            ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			/*If (SRA->RA_CHAPA < ChapaDe) .Or. (SRA->RA_CHAPA > ChapaAte) .Or. ;*/
			IF	(SRA->RA_NOME < cNomDe)    .Or. (SRA->RA_NOME > cNomAte)    .Or. ;
				(SRA->RA_MAT < cMatDe)     .Or. (SRA->RA_MAT > cMatAte)     .Or. ;
				(SRA->RA_CC < cCcDe)       .Or. (SRA->RA_CC > cCcAte)
				SRA->(dbSkip(1))
				Loop
			EndIf
			
			// If cPaisLoc == "MEX" .And. ( SRA->RA_KEYLOC < cLocalDe .Or. SRA->RA_KEYLOC > cLocalAte )
				// SRA->(dbSkip(1))
				// Loop		
			// Endif
		EndIf
	
		aLanca	:= {}         // Zera Lancamentos
		aProve	:= {}         // Zera Lancamentos
		aDesco	:= {}         // Zera Lancamentos
		aBases	:= {}         // Zera Lancamentos
		nAteLim := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := 0.00
		
		Ordem_rel := 1     // Ordem dos Recibos
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Verifica Data Demissao         ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cSitFunc := SRA->RA_SITFOLH
		dDtPesqAf:= CTOD("01/" + Left(cMesAnoRef,2) + "/" + Right(cMesAnoRef,4),"DDMMYY")
		If cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) > MesAno(dDtPesqAf))
			cSitFunc := " "
		Endif
		
		IF !( lTerminal )
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Consiste situacao e categoria dos funcionarios			   |
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !( cSitFunc $ cSituacao ) .OR.  ! ( SRA->RA_CATFUNC $ cCategoria )
				dbSkip()
				Loop
			Endif
			If cSitFunc $ "D" .And. Mesano(SRA->RA_DEMISSA) # Mesano(dDataRef)
				dbSkip()
				Loop
			Endif
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Consiste controle de acessos e filiais validas			   |
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
				dbSkip()
				Loop
			EndIf
			
		EndIF
		
		If SRA->RA_Filial # cFilialAnt
			If !Fp_CodFol(@aCodFol, SRA->RA_FILIAL) .Or. !fInfo(@aInfo, SRA->RA_FILIAL)
				Exit
			Endif
			Desc_Fil := aInfo[3]
			Desc_End := aInfo[4]                // Dados da Filial
			Desc_CGC := aInfo[8]
			DESC_MSG1:= DESC_MSG2:= DESC_MSG3:= Space(01)
			Desc_Est := Substr(fDesc("SX5","12"+aInfo[6],"X5DESCRI()"),1,12)
			Desc_Comp:= aInfo[14]        			// Complemento Cobranca
			Desc_Cid := aInfo[05]
			Desc_Bair:= aInfo[13]
			Desc_CEP := aInfo[07]
	
			// MENSAGENS
			If MENSAG1 # SPACE(3)
				If FPHIST82(SRA->RA_FILIAL,"06",MENSAG1)
					DESC_MSG1 := Left(SRX->RX_TXT,30)
				Endif
			Endif
			
			If MENSAG2 # SPACE(3)
				If FPHIST82(SRA->RA_FILIAL,"06",MENSAG2)
					DESC_MSG2 := Left(SRX->RX_TXT,30)
				Endif
			Endif
			
			If MENSAG3 # SPACE(3)
				If FPHIST82(SRA->RA_FILIAL,"06",MENSAG3)
					DESC_MSG3 := Left(SRX->RX_TXT,30)
				Endif
			Endif
			dbSelectArea("SRA")
			cFilialAnt := SRA->RA_FILIAL
		Endif
		
		Totvenc := Totdesc := 0
		            
		//Retorna as verbas do funcionario, de acordo com os periodos selecionados
		aVerbasFunc	:= RetornaVerbasFunc(	SRA->RA_FILIAL					,; // Filial do funcionario corrente
											SRA->RA_MAT	  					,; // Matricula do funcionario corrente
											NIL								,; // 
											cRoteiro	  					,; // Roteiro selecionado na pergunte
											NIL			  					,; // Array com as verbas que deverão ser listadas. Se NIL retorna todas as verbas.
											aPerAberto	  					,; // Array com os Periodos e Numero de pagamento abertos
											aPerFechado	 	 				 ) // Array com os Periodos e Numero de pagamento fechados
		
		If cRoteiro <> "EXT"
			For nReg := 1 to Len(aVerbasFunc)
				If (Len(aPerAberto) > 0 .AND. !Eval(cAcessaSRC)) .OR. (Len(aPerFechado) > 0 .AND. !Eval(cAcessaSRD))
					dbSkip()
					Loop
				EndIf
				
				If PosSrv( aVerbasFunc[nReg,3] , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
					If cPaisLoc == "PAR" .and. Eval(cNroHoras) == 30
						LocGHabRea(Ctod("01/"+SubStr(DTOC(dDataRef),4)), Ctod(StrZero(F_ULTDIA(dDataRef),2)+"/"+Strzero(Month(dDataRef),2)+"/"+right(str(Year(dDataRef)),2),"ddmmyy"),@nHoras)
					Else
						nHoras := Eval(cNroHoras)
					Endif
					fSomaPdRec("P",aVerbasFunc[nReg,3],nHoras,aVerbasFunc[nReg,7])
					TOTVENC += aVerbasFunc[nReg,7]
				Elseif SRV->RV_TIPOCOD == "2"
					fSomaPdRec("D",aVerbasFunc[nReg,3],Eval(cNroHoras),aVerbasFunc[nReg,7])
					TOTDESC += aVerbasFunc[nReg,7]
				Elseif SRV->RV_TIPOCOD $ "3/4"
					//No Paraguai imprimir somente o valor liquido
					If cPaisLoc <> "PAR" .Or. (aVerbasFunc[nReg,3] == aCodFol[047,1])
						fSomaPdRec("B",aVerbasFunc[nReg,3],Eval(cNroHoras),aVerbasFunc[nReg,7])
					Endif
				Endif
			
				If (aVerbasFunc[nReg,3] $ aCodFol[10,1]+'*'+aCodFol[15,1]+'*'+aCodFol[27,1])
					nBaseIr += aVerbasFunc[nReg,7]
				ElseIf (aVerbasFunc[nReg,3] $ aCodFol[13,1]+'*'+aCodFol[19,1])
					nAteLim += aVerbasFunc[nReg,7]
				Elseif (aVerbasFunc[nReg,3] $ aCodFol[108,1]+'*'+aCodFol[17,1])
					nBaseFgts += aVerbasFunc[nReg,7]
				Elseif (aVerbasFunc[nReg,3] $ aCodFol[109,1]+'*'+aCodFol[18,1])
					nFgts += aVerbasFunc[nReg,7]
				Elseif (aVerbasFunc[nReg,3] == aCodFol[16,1])
					nBaseIrFe += aVerbasFunc[nReg,7]
				Endif
			Next nReg
		Elseif cRoteiro == "EXT"
			dbSelectArea("SR1")
			dbSetOrder(1)
			If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
				While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT ==	SR1->R1_FILIAL + SR1->R1_MAT
					If Semana # "99"
						If SR1->R1_SEMANA # Semana
							dbSkip()
							Loop
						Endif
					Endif
					If !Eval(cAcessaSR1)
						dbSkip()
						Loop
					EndIf
					If PosSrv( SR1->R1_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
						fSomaPdRec("P",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
						TOTVENC = TOTVENC + SR1->R1_VALOR
					Elseif SRV->RV_TIPOCOD == "2"
						fSomaPdRec("D",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
						TOTDESC = TOTDESC + SR1->R1_VALOR
					Elseif SRV->RV_TIPOCOD $ "3/4"
						fSomaPdRec("B",SR1->R1_PD,SR1->R1_HORAS,SR1->R1_VALOR)
					Endif
					dbskip()
				Enddo
			Endif
		Endif             
		     
		dbSelectArea("SRA")
	
		If Empty( aVerbasFunc )
			dbSkip()
			Loop
		Endif
		             
		If nTipRel == 1 .and. !( lTerminal )
			fImpressao()   // Impressao do Recibo de Pagamento
			IF !( lTerminal )
				If Vez = 0  .and. nTipRel # 3  .and. aReturn[5] # 1
	
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Descarrega teste de impressao                                ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					fImpTeste(cString)
					If !lRetCanc
						Exit
					Endif
					TotDesc := TotVenc := 0
					If nTipRel = 2
						Loop
					Endif
				Endif
			Endif
		ElseIf nTipRel == 2 .and. !( lTerminal )
		
		if nSumaCon==2
			nIdx:=1
			While nIdx<=len(aProve)
				cCon:=SUBSTR(aProve[nIdx,1],1,4)
				While cCon==SUBSTR(aProve[nIdx,1],1,4).and. nIdx<=len(aProve)
					aadd(aPf,aProve[nIdx])
					nIdx++
					If nIdx>len(aProve)
						Exit
					End
				EnDDo
			EndDo
			nIdx:=1
			While nIdx<=len(aDesco)
				cCon:=SUBSTR(aDesco[nIdx,1],1,4)
				While cCon==SUBSTR(aDesco[nIdx,1],1,4).and. nIdx<=len(aDesco)
					aadd(adf,aDesco[nIdx])
					nIdx++
					If nIdx>len(aDesco)
						Exit
					End
				EnDDo
			EndDo
			nIdx:=1
			While nIdx<=len(aBases)
				cCon:=SUBSTR(aBases[nIdx,1],1,4)
				While cCon==SUBSTR(aBases[nIdx,1],1,4).and. nIdx<=len(aBases)
					aadd(aPf,aBases[nIdx])
					nIdx++
					If nIdx>len(aBases)
						Exit
					End
				EnDDo
			EndDo	

			aProve 	:=aClone(apf)
			aDesco	:=aClone(adf)
			aBases	:=aClone(abf)
			
			apf:={}
			adf:={}
			abf:={}
			
		EndIf
		
		
		
		
		
		
		
			If cRoteiro=="04 "
			//Imprimir conceptos de finiquitos
				For nIdx:=1 to len(aProve)
					
					If SUBSTR(aProve[nIdx,1],1,4)=="110 " .Or. SUBSTR(aProve[nIdx,1],1,4)=="111 " .or. SUBSTR(aProve[nIdx,1],1,4)=="112 ".Or. SUBSTR(aProve[nIdx,1],1,4)=="121 " .Or. SUBSTR(aProve[nIdx,1],1,4)=="122 ".Or.;
					   SUBSTR(aProve[nIdx,1],1,4)=="123 " .Or. SUBSTR(aProve[nIdx,1],1,4)=="124 " .or. SUBSTR(aProve[nIdx,1],1,4)=="135 ".or. SUBSTR(aProve[nIdx,1],1,4)=="149 " .OR. SUBSTR(aProve[nIdx,1],1,4)=="150 "

						aadd(aPf,aProve[nIdx])     
						nTpf+=aProve[nIdx,3]
					   
					Else
						aadd(aPs,aProve[nIdx]) 
						nTps+=aProve[nIdx,3]
					EndIf
						
				Next
				For nIdx:=1 to len(aDesco)
					
					If aDesco[nIdx,1]=="110" .Or.aDesco[nIdx,1]=="111" .or.aDesco[nIdx,1]=="112".Or.aDesco[nIdx,1]=="121" .Or.aDesco[nIdx,1]=="122".Or.;
					   aDesco[nIdx,1]=="123".Or.aDesco[nIdx,1]=="124".or. aDesco[nIdx,1]=="135".or. aDesco[nIdx,1]=="149".OR.aDesco[nIdx,1]=="150"
					   
						aadd(adf,aDesco[nIdx])
						nTdf+=aDesco[nIdx,3]
					   
					Else
						aadd(ads,aDesco[nIdx])
						nTdS+=aDesco[nIdx,3]
					EndIf
					
				Next	
				For nIdx:=1 to len(aBases)
					If aBases[nIdx,1]=="110" .Or.aBases[nIdx,1]=="111" .or.aBases[nIdx,1]=="112".Or.aBases[nIdx,1]=="121" .Or.aBases[nIdx,1]=="122".Or.;
					   aBases[nIdx,1]=="123".Or.aBases[nIdx,1]=="124".or. aBases[nIdx,1]=="135".or. aBases[nIdx,1]=="149".OR.aBases[nIdx,1]=="150"
						aadd(abf,aBases[nIdx])
					   
					Else
						aadd(abs,aBases[nIdx])
					EndIf
				Next
				aProve 	:=aClone(apf)
				aDesco	:=aClone(adf)
				aBases	:=aClone(abf)
				TOTVENC :=nTpF

				TOTDESC :=nTDF 
				
				For nX := 1 to If(cPaisLoc <> "ARG",1,2)
					fImpreZebr()
				Next nX
				
				aProve 	:=aClone(aps)
				aDesco	:=aClone(ads)
				aBases	:=aClone(abs)
				TOTVENC :=nTpS
				TOTDESC :=nTDS
				
				For nX := 1 to If(cPaisLoc <> "ARG",1,2)
					fImpreZebr()
				Next nX
				
			Else
				For nX := 1 to If(cPaisLoc <> "ARG",1,2)
					fImpreZebr()
				Next nX

			EndIf
		
			ASize(AProve,0)
			ASize(ADesco,0)
			ASize(aBases,0)
		ElseIf nTipRel == 3 .or. lTerminal
			cHtml := fSendDPgto(lTerminal)   //Monta o corpo do e-mail e envia-o
		Endif
		
		dbSelectArea("SRA")
		SRA->( dbSkip() )
		TOTDESC := TOTVENC := 0
		
	EndDo
	
	IF !( lTerminal )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Termino do relatorio                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SRC")
		dbSetOrder(1)          // Retorno a ordem 1
		dbSelectArea("SRD")
		dbSetOrder(1)          // Retorno a ordem 1
		dbSelectArea("SRA")
		SET FILTER TO
		RetIndex("SRA")
		
		If !(Type("cArqNtx") == "U")
			fErase(cArqNtx + OrdBagExt())
		Endif
		
		Set Device To Screen
		
		If lEnvioOK
			APMSGINFO(STR0042)
		ElseIf nTipRel== 3
			APMSGINFO(STR0043)
		EndIf
		SeTPgEject(.F.)
		nlin:= 0	
		If aReturn[5] = 1 .and. nTipRel # 3
			Set Printer To
			Commit
			ourspool(wnrel)
		Endif
		MS_FLUSH()
		
	EndIF
Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImpressao³ Autor ³ R.H. - Ze Maria       ³ Data ³ 14.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMRESSAO DO RECIBO FORMULARIO CONTINUO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fImpressao()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpressao()
	Local lLinhaRoda := .T.	// Variavel que informa se foram impressas todas as linhas do miolo do recibo.
	Local nConta  := 0
	Local nContr  := 0
	Local nContrT := 0
	
	Private nLinhas:=16     // Numero de Linhas do Miolo do Recibo
	
	Ordem_Rel := 1
	
	fCabec()
	
	For nConta = 1 To Len(aLanca)
		fLanca(nConta)
		nContr ++
		nContrT ++
		If nContr = nLinhas .And. nContrT < Len(aLanca)
			nContr:=0
			Ordem_Rel ++
			fContinua()
			fCabec()
		Endif
	Next nConta
	Li:=Li -1
	Li+=IF( lLinhaRoda := (nLinhas-nContr) == 0,1,(nLinhas-nContr))
	
	fRodape(lLinhaRoda)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImpreZebr³ Autor ³ R.H. - Ze Maria       ³ Data ³ 14.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMRESSAO DO RECIBO FORMULARIO ZEBRADO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fImpreZebr()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpreZebr()

	Local nConta    := nContr := nContrT:=0
	If li >= 70
		li := 0
	Endif
	fCabecZ()
	fLancaZ(nConta)	
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCabec    ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 14.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMRESSAO Cabe‡alho Form Continuo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCabec()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fCabec()   		// Cabecalho do Recibo
	Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
	Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario
	Local cDescRot		:= PosAlias("SRY", cRoteiro, SRA->RA_FILIAL, "RY_DESC")
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega Funcao do Funcion. de acordo com a Dt Referencia     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc )
	
	@ PROW(),PCOL() PSAY ""
	LI ++
	@ LI,01 PSAY &cNormal+DESC_FIL
	LI ++
	@ LI,01 PSAY DESC_END
	LI ++
	@ LI,01 PSAY DESC_CGC
	@ LI,20 PSAY "- " + cDescRot + " - " + cPeriodo+"/"+Semana
	
	LI +=2
	@ LI,01 PSAY SRA->RA_Mat
	@ LI,08 PSAY Left(SRA->RA_NOME,28)
	@ LI,37 PSAY fCodCBO(SRA->RA_FILIAL,cCodFunc ,dDataRef)
	@ LI,44 PSAY SRA->RA_Filial
	@ LI,47 PSAY PADC(ALLTRIM(SRA->RA_CC),20)
	@ LI,67 PSAY ORDEM_REL PICTURE "99"
	LI ++
	
	cDet := STR0015       + cCodFunc						//-- Funcao
	cDet += cDescFunc     + ' '
	cDet += DescCc(SRA->RA_CC, xFilial("CTT", SRA->RA_FILIAL)) + ' '
	cDet += STR0016 + SRA->RA_CHAPA					//'CHAPA: '
	@ Li,01 pSay cDet
	
	Li += 3
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCabecz   ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 14.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMRESSAO Cabe‡alho Form ZEBRADO                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCabecz()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fCabecZ( lCopia )   	// Cabecalho do Recibo Zebrado
	Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
	Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario
	Local dDataPagto 	:= PosAlias( "RCH" , (cProcesso+cPeriodo+Semana+cRoteiro) , SRA->RA_FILIAL , "RCH_DTPAGO")
	DEFAULT lCopia := .F.
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega Funcao do Funcion. de acordo com a Dt Referencia     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc )
	
	@ Li,00 PSAY Avalimp(Limite)
	LI ++
	@ LI,00 PSAY "*"+REPLICATE("=",130)+"*"
	
	LI ++
	@ LI,00  PSAY  "|"
	@ LI,46  PSAY STR0017		//"RECIBO DE PAGAMENTO  "
	@ LI,131 PSAY "|"
	
	LI ++
	@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"
	
	DbSelectArea( "RCO" )
	If RCO->RCO_CODIGO <> SRA->RA_CODRPAT
		DbSetOrder( 1 ) // RCO_FILIAL+RCO_CODIGO+RCO_NREPAT
		DbSeek( xFilial("RCO") + SRA->RA_CODRPAT, .F. )
	EndIf
	
	LI ++
	@ LI,00  PSAY STR0018 + Alltrim(DESC_Fil)	//"| Empresa   : "
	@ LI,54  PSAY STR0121 + RCO->RCO_NREPAT		//"Cod. Reg. Patr: "
	@ LI,94 PSAY STR0099  + Desc_CGC			//"CGC: "
	@ LI,131 PSAY "|"
	
	LI++
	@ LI,00  PSAY fFormatLine(Alltrim(Desc_End) + If(Empty(Desc_End), "", " - ") + Alltrim(Desc_Bair) + If(Empty(Desc_Bair), "", ", ") + AllTrim( Desc_Cid ) + If( Empty(Desc_Cid), "",  ", ") + AllTrim(Desc_Est))
	
	LI ++
	@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"
	
	LI ++
	If !lCopia
		ORDEMZ ++
	EndIf
	@ LI,00  PSAY STR0023 + SRA->RA_MAT //"| Matricula : "
	@ LI,30  PSAY STR0024 + SubStr(SRA->RA_NOME + Space(TamSx3("RA_NOME")[1]-Len(SRA->RA_NOME)),1,25)	//"Nome  : "
	If cRoteiro =="04 ".Or. cRoteiro =="05 "
		@ LI,86  PSAY STR0138   //"Motivo:"
		@ LI,100 PSAY SRA->RA_TIPOFIN
	Else
		@ LI,86  PSAY STR0025					//"Recibo : "
		@ LI,100 PSAY StrZero(ORDEMZ,6) Picture "999999"
	EndIf
	@ LI,131 PSAY "|"
	
	LI ++
	@ LI,00 PSAY STR0020 + Alltrim( SRA->RA_CC ) + " - " + DescCc(SRA->RA_CC, xFilial("CTT", SRA->RA_FILIAL), 25)	//"| C Custo   : "
	@ LI,85 PSAY STR0026 + cCodFunc + " - " + AllTrim( cDescFunc )					//" Funcao    : "
	@ LI,131 PSAY "|"
	
	LI ++
	@ LI,00  PSAY "| " + STR0109 + SRA->RA_CIC		//"Identificación"
	If SRA->RA_CATFUNC <> "A"	// Autonomos nao possui Registro no IMSS
		@ LI,50  PSAY STR0122 + SRA->RA_RG			//"CCSS  : "
	EndIf
	@ LI,131 PSAY "|"
	
	LI ++
	//@ LI,00  PSAY STR0124 + TRANSFORM(SRA->RA_SALDIA,"@E 999,999.999999") 	//"| Salario Diario: "
	//If SRA->RA_CATFUNC <> "A"// Autonomos nao possui Salario Integrado
		//@ LI,046 PSAY STR0125 + TRANSFORM(SRA->RA_SALINT,"@E 999,999.999999")	//"Sal. Dia. Int : "
	//EndIf   
	@ LI,00  PSAY "|"
	@ LI,085 PSAY  STR0126 + AllTrim( SRA->RA_KEYLOC ) + " - " + Substr( AllTrim( fPosTab( "S015", SRA->RA_KEYLOC, "=", 4,,,,5) ), 1, 30 ) // "Local Pagto: "
	@ LI,131 PSAY "|"
	//Fecha de Ingreso Fecha de Baja Tiempo Laborado
	//////////
	
	LI++
	@ LI,00 PSAY STR0133 +Space(1)+ Dtoc(SRA->RA_ADMISSA) + SPACE(10) + STR0134+ if(empty(SRA->RA_DEMISSA),"",Dtoc(SRA->RA_DEMISSA)) + SPACE(8) + STR0135+SPACE(1)+calcTLabor(SRA->RA_ADMISSA,iif(empty(SRA->RA_DEMISSA),dDataPagto,SRA->RA_DEMISSA))//#Fecha de Ingreso# Fecha Baja#Tiempo Laborado
	@ LI,100 PSAY STR0136+Space(1)+DtoC(dDataPagto)
	//@ LI,106 PSAY DtoC( GravaData( dRCHDtIni, .T. ) ) + STR0046 + DtoC( GravaData( dRCHDtFim, .T. ) )
	@ LI,131 PSAY "|"

	LI++
	@ LI,00 PSAY /*STR0117 + cProcesso + "-" + cDescProc + SPACE(5) +*/ STR0118 + cRoteiro +"-"+ SubStr(Posicione("SRY",1,xFilial("SRY")+cRoteiro, "RY_DESC") + Space(30-Len(Posicione("SRY",1,xFilial("SRY")+cRoteiro, "RY_DESC"))),1,25)+ STR0119 + cPeriodo + SPACE(1) + STR0120 + Semana + SPACE(1) // 	#"| Tipo Nómina : "#	"Periodo: "
	@ LI,84 PSAY DtoC( GravaData( dRCHDtIni, .T. ) ) + STR0046 + DtoC( GravaData( dRCHDtFim, .T. ) )+SPACE(1)+STR0137+SPACE(1)+SRA->RA_CTDEPSA //Cuenta
	@ LI,131 PSAY "|"
	
	LI ++
	@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"
	
	LI ++
	@ LI,000 PSAY STR0027		//"| B E N E F I C I O S "
	@ LI,044 PSAY STR0028		//"  D E D U C C I O N E S "
	@ LI,088 PSAY STR0029		//"  B A S E S"
	@ LI,131 PSAY "|"
	
	LI ++
	@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"
	LI++
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fLanca    ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 14.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao das Verbas (Lancamentos) Form. Continuo          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fLanca()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fLanca(nConta)   // Impressao dos Lancamentos
	Local cString := Transform(aLanca[nConta,5],cPict2)
	Local nCol := If(aLanca[nConta,1]="P",43,If(aLanca[nConta,1]="D",57,27))
	
	@ LI,01 PSAY aLanca[nConta,2]
	@ LI,05 PSAY aLanca[nConta,3]
	If aLanca[nConta,1] # "B"        // So Imprime se nao for base
		@ LI,36 PSAY TRANSFORM(aLanca[nConta,4],"999.99")
	Endif
	@ LI,nCol PSAY cString
	Li ++
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fLancaZ   ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 14.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao das Verbas (Lancamentos) Zebrado                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fLancaZ()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fLancaZ(nConta)   // Impressao dos Lancamentos
	Local nTermina  := 0
	Local nCont     := 0
	Local nCont1    := 0
	Local nValidos  := 0
	Local nTam		:= 0
	Local nFinal	:= 0
	Local nControl 	:= 0
	Local nLastCont := 0
	Local nSvCont	:= 0
	
	nTermina := Max(Max(Len(aProve),Len(aDesco)),Len(aBases))
	
	nTermina := If( nTermina > 0, nTermina, 1 )
	
	For nCont := 1 To nTermina
		@ LI,00 PSAY "|"                                                      

		
		If nCont <= LEN(aProve)
			@ LI,02 PSAY substr(aProve[nCont,1],1,19)             //Cod y concepto
			@ LI,21 PSAY TRANSFORM(aProve[nCont,2],'99999999')    //Unidades                             
			@ LI,31 PSAY TRANSFORM(aProve[nCont,3],cPict3)        //Importe
		Endif
		
		@ LI,44 PSAY "|"
		
		If nCont <= LEN(aDesco)      
			//@ LI,46 PSAY aDesco[nCont,1]+TRANSFORM(aDesco[nCont,2],'999.99') +TRANSFORM(aDesco[nCont,3],cPict3)
			@ LI,46 PSAY substr(aDesco[nCont,1],1,19)        //Cod y concepto
			@ LI,75 PSAY TRANSFORM(aDesco[nCont,3],cPict3)	  //Importe		
		Endif
		@ LI,88 PSAY "|" 
		
		If nCont <= LEN(aBases)
 							//Cod y concepto   Unidades                             Importe
			//@ LI,90 PSAY aBases[nCont,1]+TRANSFORM(aBases[nCont,2],'999.99') +TRANSFORM(aBases[nCont,3],cPict3)
			@ LI,90  PSAY substr(aBases[nCont,1],1,18)		
			@ LI,119 PSAY TRANSFORM(aBases[nCont,3],cPict3)
		Endif
		@ LI,131 PSAY "|"
	
		//---- Soma 1 nos nValidos e Linha
		nValidos ++
		Li ++
	
		If nValidos = 9 .and. nCont < nTermina
			@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"
			
			LI ++
			@ LI,00 PSAY fFormatLine(Space(5) + STR0030)			// "CONTINUA !!!"	
			
			LI ++
			@ LI,00 PSAY "*"+REPLICATE("=",130)+"*"
			
			LI += 8
			If li >= 60
				li := 0
			Endif
	
			If nControl = 0
				fCabecZ(.T.)
				nSvCont 	:= nCont
				nCont 		:= nLastCont
				nLastCont 	:= nSvCont
				nControl 	:= 1
			Else
				fCabecZ()
				nCont 	 := nLastCont
				nControl := 0
			EndIf
	
			nValidos := 0
		ElseIf nCont = nTermina
	
			For nCont1 := nValidos+1 To 9
				@ Li,00  PSAY "|"
				@ Li,44  PSAY "|"
				@ Li,88  PSAY "|"
				@ Li,131 PSAY "|"
				Li++
			Next nCont1
	
			@ LI,00 PSAY "|"+REPLICATE("-",130)+"|"
			LI ++
			nTam := 43 - (Len(STR0031) + Len(TRANS(TOTVENC, cPict1) ) )		
			@ LI,00 PSAY STR0031 + SPACE(nTam) + TRANS(TOTVENC,cPict1)	//"| TOTAL BENEFICIO     "
			nTam := 41 - (Len(STR0032) + Len(TRANS(TOTDESC, cPict1) ) )
			@ LI,44 PSAY "|"
			@ LI,46 PSAY  STR0032 + SPACE(nTam) + TRANS(TOTDESC, cPict1)// + " |"	//" TOTAL DESCONTOS     "

			//	nTam := 43 - (Len(STR0033) + Len(SRA->RA_BCDEPSA) + 1)
			//@ LI,090 PSAY STR0033+SRA->RA_BCDEPSA+"-"+Substr(DescBco(SRA->RA_BCDEPSA,SRA->RA_FILIAL), 1, nTam)	//"| CREDITO:"
			nTam := 42 - (Len(STR0034) + Len(TRANS((TOTVENC-TOTDESC),cPict1)))
			@ LI,088 PSAY "|"
			@ LI,089 PSAY STR0034+SPACE(nTam)+TRANS((TOTVENC-TOTDESC),cPict1) 			//"| LIQUIDO A RECEBER     "
			@ LI,130 PSAY "|"
				LI ++
			@ LI,000 PSAY "|"+REPLICATE("-",130)+"|"
			
			LI ++
			@ LI,000 PSAY "|"
			@ LI,005 PSAY DESC_MSG1
			@ LI,131 PSAY "|"
			
			LI ++
			@ LI,000 PSAY "|"
			@ LI,005 PSAY DESC_MSG2
			@ LI,131 PSAY "|"
			
			LI ++
			@ LI,000 PSAY "|"
			@ LI,005 PSAY DESC_MSG3
			@ LI,131 PSAY "|"
	
			LI ++
			@ LI,000 PSAY "|"
			@ LI,002 PSAY Substr( cMensRec, 1, 128 )
			@ LI,130 PSAY "|"
	
			LI ++
			@ LI,000 PSAY "|"
			@ LI,002 PSAY Substr( cMensRec, 129, 46 )

			@ LI,130 PSAY "|"
	
			LI ++
			@ LI,000 PSAY "|"
			@ LI,002 PSAY Substr( cMensRec, 175, 47 )
			@ LI,130 PSAY "|"
			

			LI ++
			@ LI,000 PSAY "|"
			@ LI,046 PSAY REPLICATE("_",40)
			@ LI,088 PSAY REPLICATE("_",40)
			@ LI,131 PSAY "|"

			LI ++
			@ LI,000 PSAY "|"
			@ LI,002 PSAY STR0130 //"Nombre del Trabajador"
			@ LI,046 PSAY STR0131 //"Cédula"
			@ LI,088 PSAY STR0132 //"Fecha"
			@ LI,131 PSAY "|"

	
			LI ++
			@ LI,000 PSAY "*"+REPLICATE("=",129)+"*"
	
			LI += 1
			If LI >= 60
				LI := 0
			Endif
	
			If nFinal = 0
				fCabecZ(.T.)
				nSvCont 	:= nCont
				nCont 		:= nLastCont
				nLastCont 	:= nSvCont
				nFinal	 	:= 1
			Else
				nCont 	 := nLastCont
				nFinal := 0
			EndIf
	
			nValidos := 0
	
		Endif
		
	Next nCont
	
	//Quebrar pagina
	If LI > 70
		LI := 0
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fContinua ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 14.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressap da Continuacao do Recibo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fContinua()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fContinua()    // Continuacao do Recibo
	Li+=1
	@ LI,05 PSAY &cNormal + STR0037		//"CONTINUA !!!"
	Li+= 7
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fRodape   ³ Autor ³ R.H. - Ze Maria       ³ Data ³ 14.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Rodape                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRodape()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fRodape(lLinhaRoda)    // Rodape do Recibo
	If !lLinhaRoda
		LI += 1
	Endif
	@ LI,05 PSAY DESC_MSG1
	LI ++
	@ LI,05 PSAY DESC_MSG2
	@ LI,42 PSAY TOTVENC PICTURE cPict1
	@ LI,56 PSAY TOTDESC PICTURE cPict1
	LI ++
	@ LI,05 PSAY DESC_MSG3
	LI ++
	IF MONTH(dDataRef) = MONTH(SRA->RA_NASC)
		@ LI, 02 PSAY STR0038		//"F E L I Z   A N I V E R S A R I O  ! !"
	ENDIF
	@ LI,56 PSAY TOTVENC - TOTDESC PICTURE cPict1
	LI +=2
	
	nValSal := 0
	nValSal := fBuscaSal(dDataRef)
	If nValSal ==0
		nValSal := SRA->RA_SALARIO
	EndIf
	
	@ LI,05 PSAY &cCompac+Transform(nValSal,cPict2)
	
	If cTipoRot = "2"  // Bases de Adiantamento
		If cBaseAux = "S" .And. nBaseIr # 0
			@ LI,89 PSAY nBaseIr PICTURE cPict1
		Endif
	ElseIf cTipoRot = "1" .Or. cTipoRot = "6"  // Bases de Folha e 13o. 2o.Parc.
		If cBaseAux = "S"
			@ LI,23 PSAY Transform(nAteLim,cPict1)
			If nBaseFgts # 0
				@ LI,46 PSAY nBaseFgts PICTURE cPict1
			Endif
			If nFgts # 0
				@ LI,66 PSAY nFgts PICTURE cPict2
			Endif
			If nBaseIr # 0
				@ LI,89 PSAY nBaseIr PICTURE cPict1
			Endif
			@ LI,103 PSAY Transform(nBaseIrfE,cPict1)
		Endif
	ElseIf cTipoRot = "5" // Bases de FGTS e FGTS Depositado da 1¦ Parcela
		If cBaseAux = "S"
			If nBaseFgts # 0
				@ LI,46 PSAY nBaseFgts PICTURE cPict1
			Endif
			If nFgts # 0
				@ LI,66 PSAY nFgts PICTURE cPict2
			Endif
		Endif
	Endif
	
	@ LI,Pcol() Psay &cNormal
	
	Li ++
	IF SRA->RA_BCDEPSAL # SPACE(8)
		Desc_Bco := DescBco(Sra->Ra_BcDepSal,Sra->Ra_Filial)
		@ LI,01 PSAY STR0039	//"CRED:"
		@ LI,06 PSAY SRA->RA_BCDEPSAL
		@ LI,14 PSAY "-"
		@ LI,15 PSAY DESC_BCO
		@ LI,50 PSAY STR0040 + SRA->RA_CTDEPSAL	//"CONTA:"
	ENDIF
	LI += 2
	@ LI,05 PSAY " "
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSomaPdRec³ Autor ³ R.H. - Mauro          ³ Data ³ 24.09.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Somar as Verbas no Array                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSomaPdRec(Tipo,Verba,Horas,Valor)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSomaPdRec(cTipo,cPd,nHoras,nValor)
	Local Desc_paga
	
	Desc_paga := DescPd(cPd,Sra->Ra_Filial)  // mostra como pagto
	
	If PosSrv(cPD, SRA->RA_FILIAL, "RV_IMPRIPD") == "2"
		Return
	EndIf
	
	If cTipo # 'B'
	
		//--Array para Recibo Pre-Impresso
		nPos := Ascan(aLanca,{ |X| X[2] = cPd })
		If nPos == 0
			Aadd(aLanca,{cTipo,cPd,Desc_Paga,nHoras,nValor})
		Else
			aLanca[nPos,4] += nHoras
			aLanca[nPos,5] += nValor
		Endif
	Endif
	
	//--Array para o Recibo Pre-Impresso
	If cTipo = 'P'
		cArray := "aProve"
	Elseif cTipo = 'D'
		cArray := "aDesco"
	Elseif cTipo = 'B'
		cArray := "aBases"
	Endif
	
	nPos := Ascan(&cArray,{ |X| X[1] = cPd })
	If nPos == 0
		Aadd(&cArray,{cPd+" "+Desc_Paga,nHoras,nValor })
	Else
		&cArray[nPos,2] += nHoras
		&cArray[nPos,3] += nValor
	Endif
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSendDPgto| Autor ³ R.H.-Natie            ³ Data ³ 15.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envio de E-mail -Demonstrativo de Pagamento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico :Envio Demonstrativo de Pagto atraves de eMail  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSendDPgto(lTerminal)
	Local aSvArea		:= GetArea()
	Local aGetArea		:= {}
	Local cEmail		:= If(SRA->RA_RECMAIL=="S",SRA->RA_EMAIL,"    ")
	Local cHtml			:= ""
	Local cSubject		:= STR0044	//" DEMONSTRATIVO DE PAGAMENTO "
	Local cMesComp		:= IF( Month(dDataRef) + 1 > 12 , 01 , Month(dDataRef) )
	Local cTipo			:= ""
	Local cReferencia	:= ""
	Local cVerbaLiq		:= ""
	Local dDataPagto	:= Ctod("//")
	Local nZebrado		:= 0.00
	Local nResto		:= 0.00
	Local nProv
	Local nDesco
	Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
	Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario
	
	Private cMailConta	:= NIL
	Private cMailServer	:= NIL
	Private cMailSenha	:= NIL
	
	lTerminal := IF( lTerminal == NIL .or. ValType( lTerminal ) != "L" , .F. , lTerminal )
	
	aGetArea	:= SRC->( GetArea() )
	cTipo		:= PosAlias("SRY", cRoteiro, SRA->RA_FILIAL, "RY_DESC")
	
	IF cTipoRot == "2"
		cVerbaLiq	:= PosSrv( "007ADT" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
	ElseIF cTipoRot == "1"
		cVerbaLiq	:= PosSrv( "047CAL" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
	ElseIF cTipoRot == "5"
		cVerbaLiq	:= PosSrv( "022C13" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
	ElseIF cTipoRot == "6"
		cVerbaLiq	:= PosSrv( "021C13" , xFilial("SRA") , "RV_COD" , RetOrdem("SRV","RV_FILIAL+RV_CODFOL") , .F. )
	ElseIF  cRoteiro == "EXT"
		cTipo		:= STR0064 //"Valores Extras"
		cVerbaLiq	:= ""
	EndIF
	
	IF  cRoteiro <> "EXT"
		dDataPagto := PosAlias( "RCH" , (cProcesso+cPeriodo+Semana+cRoteiro) , SRA->RA_FILIAL , "RCH_DTPAGO")
	EndIf
	
	IF !( lTerminal )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca parametros                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMailConta	:=If(cMailConta == NIL,GETMV("MV_EMCONTA"),cMailConta)             //Conta utilizada p/envio do email
		cMailServer	:=If(cMailServer == NIL,GETMV("MV_RELSERV"),cMailServer)           //Server
		cMailSenha	:=If(cMailSenha == NIL,GETMV("MV_EMSENHA"),cMailSenha)
		
		If Empty(cEmail)
			Return
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe o SMTP Server                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	Empty(cMailServer)
			Help(" ",1,"SEMSMTP")//"O Servidor de SMTP nao foi configurado !!!" ,"Atencao"
			Return(.F.)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe a CONTA                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	Empty(cMailConta)
			Help(" ",1,"SEMCONTA")//"A Conta do email nao foi configurado !!!" ,"Atencao"
			Return(.F.)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe a Senha                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	Empty(cMailServer)
			Help(" ",1,"SEMSENHA")	//"A Senha do email nao foi configurado !!!" ,"Atencao"
			Return(.F.)
		EndIf
		
	EndIF
	
	cReferencia	:= AllTrim( MesExtenso(Month(dDataRef))+"/"+STR(YEAR(dDataRef),4) ) + " - ( " + cTipo + "-" + cPeriodo + "/" + Semana + " )"
	
	cHtml +=	'<html>'
	cHtml +=		'<head>'
	IF !( lTerminal )
		
		cHtml += 		'<title>DEMONSTRATIVO DE PAGAMENTO</title>'
		cHtml +=			'<style>'
		cHtml +=				'th { text-align:left; background-color:#4B87C2; line-height:01; line-width:400; border-left:0px solid  #FF9B06; border-right:0px solid #FF9B06; border-bottom:0px solid #FF9B06 ; border-top:0px solid #FF9B06 }'
		cHtml +=				'.tdPrinc { text-align:left; line-height:1; line-width:340 ; border-left:0px solid #FF9B06; border-right:0px solid #FF9B06; border-bottom:0px solid #FF9B06 ; border-top:0px solid #FF9B06 > }'
		cHtml +=				'.td18_94_AlignR { text-align:right ; line-height:1; line-width:94 }'
		cHtml +=				'.td18_95_AlignR { text-align:right ; line-height:1; line-width:95 }'
		cHtml +=				'.td26_94_AlignR { text-align:right ; line-height:1; line-width:94 }'
		cHtml +=				'.td26_95_AlignR { text-align:right ; line-height:1; line-width:95 }'
		cHtml += 				'.td26_18_AlignL { lext-align:left ; line-height:1; line:width:18 ; border-left:0px solid #FF9B06; border-right:0px solid #FF9B06; border-bottom:0px solid #FF9B06 ; border-top:0px solid #FF9B06 bgcolor=#6F9ECE" }'
		cHtml +=    			'.pStyle1 { line-height:100% ; margin-top:15 ; margin-bottom:0 }'
		cHtml +=			'</style>'
		cHtml +=	'</head>'
		cHtml +=		'<body bgcolor="#FFFFFF"  topmargin="0" leftmargin="0">'
		cHtml +=			'<center>'
		cHtml +=				'<table  border="1" cellpadding="0" cellspacing="0" bordercolor="#FF9B06" bgcolor="#000082" width=598 height="637">'
		cHtml +=    				'<td width="598" height="181" bgcolor="FFFFFF">'
		cHtml += 					'<center>'
		cHtml += 					'<font color="#000000">'
		cHtml +=					'<b>'
		cHtml += 					'<h4 size="03">'
		cHtml +=					'<br>'
		cHtml += 						STR0044 // " DEMONSTRATIVO DE PAGAMENTO "
		cHtml += 					'<br>'
		
	Else
		
		cHtml += 		'<title>RH Online</title>' + CRLF
		cHtml += 		'<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">' + CRLF
		cHtml += 		'<link rel="stylesheet" href="css/rhonline.css" type="text/css">' + CRLF
		cHtml += 	'</head>' + CRLF
		cHtml += 	'<body bgcolor="#FFFFFF" text="#000000">' + CRLF
		cHtml += 		'<Table width="515" border="0" cellspacing="0" cellpadding="0">' + CRLF
		
		//Cabecalho
		cHtml += 			CabecHtml( cReferencia , dDataPagto , dDataRef )
		
		//Separador
		cHtml +=			"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
		cHtml +=				"<TBODY>" + CRLF
		cHtml +=					"<TR>" + CRLF
		cHtml +=						"<TD vAlign=top width='100%' height=10>" + CRLF
		cHtml +=						"</TD>" + CRLF
		cHtml +=	 				"</TR>" + CRLF
		cHtml +=				"</TBODY>" + CRLF
		cHtml +=			"</TABLE>" + CRLF
		
		cHtml +=			"<TABLE border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
		cHtml +=				"<TBODY>" + CRLF
	EndIF
	
	If !Empty(Semana) .And. Semana # "99" .And.  Upper(SRA->RA_TIPOPGT) == "S"
		IF !( lTerminal )
			cHtml += cReferencia
		EndIF
	Else
		IF !( lTerminal )
			cHtml += cReferencia
		EndIF
	EndIf
	
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega Funcao do Funcion. de acordo com a Dt Referencia     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc   )
	
	IF !( lTerminal )
		
		cHtml += '</b></h4></font></center>'
		cHtml += '<hr whidth = 100% align=right color="#FF812D">'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados do funcionario                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHtml += '<!Dados do Funcionario>'
		cHtml += '<p align=left  style="margin-top: 0">'
		cHtml +=   '<font color="#000082" face="Courier New"><i><b>'
		cHtml +=  	'&nbsp;&nbsp;&nbsp' + SRA->RA_NOME + "-" + SRA->RA_MAT+'</i><br>'
		cHtml += 	'&nbsp;&nbsp;&nbsp' + STR0048 + cCodFunc + "  "+cDescFunc	+'<br>' //"Funcao    - "
		cHtml +=  	'&nbsp;&nbsp;&nbsp' + STR0047 + SRA->RA_CC + " - " + DescCc(SRA->RA_CC, xFilial("CTT", SRA->RA_FILIAL)) +'<br>' //"C.Custo   - "
		cHtml +=    '&nbsp;&nbsp;&nbsp' + STR0049 + SRA->RA_BCDEPSAL+"-"+DescBco(SRA->RA_BCDEPSAL,SRA->RA_FILIAL)+ '&nbsp;'+  SRA->RA_CTDEPSAL //"Bco/Conta - "
		cHtml += '</b></p></font>'
		cHtml += '<!Proventos e Desconto>'
		cHtml += '<div align="center">'
		cHtml += '<Center>'
		cHtml += '<Table bgcolor="#6F9ECE" border="0" cellpadding ="1" cellspacing="0" width="553" height="296">'
		cHtml += '<TBody><Tr>'
		cHtml +=	'<font face="Arial" size="02" color="#000082"><b>'
		cHtml += 	'<th>' + STR0050 + '</th>' //"Cod  Descricao "
		cHtml += 	'<th>' + STR0051 + '</th>' //"Referencia"
		cHtml += 	'<th>' + STR0052 + '</th>' //"Valores"
		cHtml += 	'</b></font></tr>'
		cHtml += '<font color=#000082 face="Courier new"  size=2">'
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Espacos Entre os Cabecalho e os Proventos/Descontos          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHtml += 	'<tr>'
		cHtml += 		'<td class="tdPrinc"></td>'
		cHtml += 		'<td class="td18_94_AlignR">&nbsp;&nbsp</td>'
		cHtml += 		'<td class="td18_95_AlignR">&nbsp;&nbsp</td>'
		cHtml += 		'<td class="td18_18_AlignL"></td>'
		cHtml += 	'</tr>'
		
	Else
		
		//Cabecalho dos valores
		cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
		cHtml +=						"<TBODY>" + CRLF
		cHtml += 							'<tr align="center">' + CRLF
		cHtml += 								'<td width="45" height="1">' + CRLF
		cHtml += 									'<span class="etiquetas"><div align="Left">'+ STR0068 + '</span></div>' + CRLF //C&oacute;digo
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="219" valign="top">' + CRLF
		cHtml += 									'<span class="etiquetas"><div align="left">' + STR0069 + '</span></div>' + CRLF //Descri&ccedil;&atilde;o
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="127" valign="top">' + CRLF
		cHtml += 									'<span class="etiquetas"><div align="right">' + STR0070  + '</span></div>' + CRLF //Refer&ecirc;ncia
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="127" valign="top">' + CRLF
		cHtml += 									'<span class="etiquetas"><div align="right">' + STR0052 + '</span></div>' + CRLF //Valores
		cHtml += 								'<td width="107" valign="top">' + CRLF
		cHtml += 									'<span class="etiquetas"><div align="right"> (+/-) </span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 							'</tr>' + CRLF
		cHtml +=						"</TBODY>" + CRLF
		cHtml += 					'</TABLE>' + CRLF
		
		//Separador
		cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
		cHtml +=						"<TBODY>" + CRLF
		cHtml +=							"<TR>" + CRLF
		cHtml +=								"<TD vAlign=top width='100%' height=05>" + CRLF
		cHtml +=								"</TD>" + CRLF
		cHtml +=	 						"</TR>" + CRLF
		cHtml +=						"</TBODY>" + CRLF
		cHtml +=					"</TABLE>" + CRLF
		
		cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
		cHtml +=						"<TBODY>" + CRLF
		cHtml +=							"<TR>" + CRLF
		
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Proventos                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nProv:=1 To Len( aProve )
		
		nResto := ( ++nZebrado % 2 )
		
		IF !( lTerminal )
			
			cHtml += '<tr>'
			cHtml += 	'<td class="tdPrinc">' + aProve[nProv,1] + '</td>'
			cHtml += 	'<td class="td18_94_AlignR">' + Transform(aProve[nProv,2],'999.99')+'</td>'
			cHtml += 	'<td class="td18_95_AlignR">' + Transform(aProve[nProv,3],cPict3) + '</td>'
			cHtml +=    '<td class="td18_18_AlignL"></td>'
			cHtml += '</tr>'
			
		Else
			
			cHtml += 							'<tr>' + CRLF
			IF nResto > 0.00
				cHtml += 							'<td width="45" vAlign=top height="1" bgcolor="#FAFBFC">'
			Else
				cHtml += 							'<td width="45" vAlign=top height="1">' + CRLF
			EndIF
			cHtml += 									'<div align="left"><span class="dados">'  + Substr( aProve[nProv,1] , 1 , 3 ) + '</span></div>' + CRLF
			cHtml += 								'</td>' + CRLF
			IF nResto > 0.00
				cHtml += 							'<td width="219" valign="top" bgcolor="#FAFBFC">' + CRLF
			Else
				cHtml += 							'<td width="219" vAlign=top="top">' + CRLF
			EndIF
			cHtml += 									'<div align="Left"><span class="dados">'  + Capital( AllTrim( Substr( aProve[nProv,1] , 4 ) ) ) + '</span></div>' + CRLF
			cHtml += 								'</td>' + CRLF
			IF nResto > 0.00
				cHtml += 							'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
			Else
				cHtml += 							'<td width="127" valign="top">' + CRLF
			EndIF
			cHtml += 									'<div align="right"><span class="dados">' + Transform(aProve[nProv,2],'999.99') + '</span></div>' + CRLF
			cHtml += 								'</td>' + CRLF
			IF nResto > 0.00
				cHtml += 							'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
			Else
				cHtml += 							'<td width="127" valign="top">' + CRLF
			EndIF
			cHtml += 									'<div align="right"><span class="dados">' + Transform(aProve[nProv,3],cPict3) + '</span></div>' + CRLF
			cHtml += 								'</td>' + CRLF
			IF nResto > 0.00
				cHtml += 							'<td width="107" valign="top" bgcolor="#FAFBFC">' + CRLF
			Else
				cHtml += 							'<td width="107" valign="top">' + CRLF
			EndIF
			cHtml += 									'<div align="right"><span class="dados"> (+) </span></div>' + CRLF
			cHtml += 								'</td>' + CRLF
			cHtml += 							'</tr>' + CRLF
		EndIF
	Next nProv
	
	IF ( lTerminal )
		cHtml +=							"</TR>" + CRLF
		cHtml +=							"<TR>" + CRLF
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descontos                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nDesco := 1 to Len(aDesco)
		
		nResto := ( ++nZebrado % 2 )
		
		IF !( lTerminal )
			
			cHtml += '<tr>'
			cHtml += 	'<td class="tdPrinc">' + aDesco[nDesco,1] + '</td>'
			cHtml += 	'<td class="td18_94_AlignR">' + Transform(aDesco[nDesco,2],'999.99') + '</td>'
			cHtml += 	'<td class="td18_95_AlignR">' + Transform(aDesco[nDesco,3],cPict3) + '</td>'
			cHtml += 	'<td class="td18_18_AlignL">-</td>'
			cHtml += '</tr>'
			
		Else
			
			cHtml += 							'<tr>' + CRLF
			IF nResto > 0.00
				cHtml += 							'<td width="45" align="center" height="19" bgcolor="#FAFBFC">'
			Else
				cHtml += 							'<td width="45" align="center" height="19">' + CRLF
			EndIF
			cHtml += 									'<div align="left"><span class="dados">'  + Substr( aDesco[nDesco,1] , 1 , 3 ) + '</span></div>' + CRLF
			cHtml += 								'</td>' + CRLF
			IF nResto > 0.00
				cHtml += 							'<td width="219" valign="top" bgcolor="#FAFBFC">' + CRLF
			Else
				cHtml += 							'<td width="219" valign="top">' + CRLF
			EndIF
			cHtml += 									'<div align="Left"><span class="dados">'  + Capital( AllTrim( Substr( aDesco[nDesco,1] , 4 ) ) ) + '</span></div>' + CRLF
			cHtml += 								'</td>' + CRLF
			IF nResto > 0.00
				cHtml += 							'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
			Else
				cHtml += 							'<td width="127" valign="top">' + CRLF
			EndIF
			cHtml += 									'<div align="right"><span class="dados">' + Transform(aDesco[nDesco,2],'999.99') + '</span></div>' + CRLF
			cHtml += 								'</td>' + CRLF
			IF nResto > 0.00
				cHtml += 							'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
			Else
				cHtml += 							'<td width="127" valign="top">' + CRLF
			EndIF
			cHtml += 									'<div align="right"><span class="dados">' + Transform(aDesco[nDesco,3],cPict3) + '</span></div>' + CRLF
			cHtml += 								'</td>' + CRLF
			IF nResto > 0.00
				cHtml += 							'<td width="107" valign="top" bgcolor="#FAFBFC">' + CRLF
			Else
				cHtml += 							'<td width="107" valign="top">' + CRLF
			EndIF
			cHtml += 									'<div align="right"><span class="dados"> (-) </span></div>' + CRLF
			cHtml += 								'</td>' + CRLF
			cHtml += 							'</tr>' + CRLF
		EndIF
	Next nDesco
	
	IF ( lTerminal )
		
		cHtml +=							"</TR>" + CRLF
		cHtml +=						"</TBODY>" + CRLF
		cHtml +=					"</TABLE>" + CRLF
		
		//Separador
		cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
		cHtml +=						"<TBODY>" + CRLF
		cHtml +=							"<TR>" + CRLF
		cHtml +=								"<TD vAlign=top width='100%' height=05>" + CRLF
		cHtml +=								"</TD>" + CRLF
		cHtml +=	 						"</TR>" + CRLF
		cHtml +=						"</TBODY>" + CRLF
		cHtml +=					"</TABLE>" + CRLF
		
		cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
		cHtml +=						"<TBODY>" + CRLF
		cHtml +=							"<TR>" + CRLF
		
	EndIF
	
	IF !( lTerminal )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Espacos Entre os Proventos e Descontos e os Totais           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHtml += 	'<tr>'
		cHtml += 		'<td class="tdPrinc"></td>'
		cHtml += 		'<td class="td18_94_AlignR">&nbsp;&nbsp</td>'
		cHtml += 		'<td class="td18_95_AlignR">&nbsp;&nbsp</td>'
		cHtml += 		'<td class="td18_18_AlignL"></td>'
		cHtml += 	'</tr>'
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totais                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHtml += '<!Totais >'
		cHtml +=	'<b><i>'
		cHtml += 	'<tr>'
		cHtml += 		'<td class="tdPrinc">' + STR0053 + '</td>' //"Total Bruto "
		cHtml += 		'<td class="td18_94_AlignR"></td>'
		cHtml += 		'<td class="td18_95_AlignR">' + Transform(TOTVENC,cPict3) + '</td>'
		cHtml += 		'<td class="td18_18_AlignL"></td>'
		cHtml +=	'</tr>'
		cHtml += 	'<tr>'
		cHtml += 		'<td class="tdPrinc">' + STR0054 + '</td>' //"Total Descontos "
		cHtml += 		'<td class="td18_94_AlignR"></Td>'
		cHtml += 		'<td class="td18_95_AlignR">' + Transform(TOTDESC,cPict3) + '</td>'
		cHtml += 		'<td class="td18_18_AlignL">-</td>'
		cHtml += 	'</tr>'
		cHtml += 	'<tr>'
		cHtml += 		'<td class="tdPrinc">' + STR0055 + '</td>' //"Liquido a Receber "
		cHtml += 		'<td class="td18_94_AlignR"></td>'
		cHtml += 		'<td align=right height="18" width="95" Style="border-left:0px solid #FF812D; border-right:0px solid #FF9B06; border-bottom:0px solid #FF9B06 ; border-top:1px solid #FF9B06 bgcolor=#4B87C2">'
		cHtml +=        Transform((TOTVENC-TOTDESC),cPict3) +'</td>'
		cHtml += 	'</tr>'
		cHtml += '<!Bases>'
		cHtml += 	'<tr>'
		
	Else
		
		//Total de Proventos
		cHtml += 							'<tr>' + CRLF
		cHtml += 								'<td width="219" valign="top" bgcolor="#FAFBFC">' + CRLF
		cHtml += 									'<div align="left" class="etiquetas"> ' + STR0065 + '</div>' + CRLF //"Total Bruto: "
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="45" valign="top" bgcolor="#FAFBFC">' + CRLF
		cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
		cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
		cHtml += 									'<div align="right"><span class="dados">' + Transform(TOTVENC,cPict3) + '</span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="107" valign="top" bgcolor="#FAFBFC">' + CRLF
		cHtml += 									'<div align="right"><span class="dados"> (+) </span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 							'</tr>' + CRLF
		
		//Total de Descontos
		cHtml += 							'<tr>' + CRLF
		cHtml += 								'<td width="219" valign="top">' + CRLF
		cHtml += 									'<div align="left" class="etiquetas"> ' + STR0066 + '</div>' + CRLF //"Total de Descontos: "
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="45" valign="top">' + CRLF
		cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="127" valign="top">' + CRLF
		cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="127" valign="top">' + CRLF
		cHtml += 									'<div align="right"><span class="dados">' + Transform(TOTDESC,cPict3) + '</span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="107" valign="top">' + CRLF
		cHtml += 									'<div align="right"><span class="dados"> (-) </span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 							'</tr>' + CRLF
		
		
		//Liquido
		cHtml += 							'<tr>' + CRLF
		cHtml += 								'<td width="219" valign="top" bgcolor="#FAFBFC">' + CRLF
		cHtml += 									'<div align="left" class="etiquetas">' + STR0067  + '</div>' + CRLF //"L&iacute;quido a Receber: "
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="45" valign="top" bgcolor="#FAFBFC">' + CRLF
		cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
		cHtml += 									'<div align="left" class="etiquetas"> </div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="127" valign="top" bgcolor="#FAFBFC">' + CRLF
		cHtml += 									'<div align="right"><span class="dados">' + Transform((TOTVENC-TOTDESC),cPict3) + '</span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 								'<td width="107" valign="top" bgcolor="#FAFBFC">' + CRLF
		cHtml += 									'<div align="right"><span class="dados"> (=) </span></div>' + CRLF
		cHtml += 								'</td>' + CRLF
		cHtml += 							'</tr>' + CRLF
		
		cHtml +=							"</TR>" + CRLF
		cHtml +=						"</TBODY>" + CRLF
		cHtml +=					"</TABLE>" + CRLF
		
		//Separador
		cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
		cHtml +=						"<TBODY>" + CRLF
		cHtml +=							"<TR>" + CRLF
		cHtml +=								"<TD vAlign=top width='100%' height=10>" + CRLF
		cHtml +=								"</TD>" + CRLF
		cHtml +=	 						"</TR>" + CRLF
		cHtml +=						"</TBODY>" + CRLF
		cHtml +=					"</TABLE>" + CRLF
		
		cHtml +=					"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
		cHtml +=						"<TBODY>" + CRLF
		cHtml +=							"<TR>" + CRLF
		
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Espacos Entre os Totais e as Bases                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !( lTerminal )
		cHtml += 	'<tr>'
		cHtml += 		'<td class="tdPrinc"></td>'
		cHtml += 		'<td class="td18_94_AlignR">&nbsp;&nbsp</td>'
		cHtml += 		'<td class="td18_95_AlignR">&nbsp;&nbsp</td>'
		cHtml += 		'<td class="td18_18_AlignL"></td>'
		cHtml += 	'</tr>'
	Else
		cHtml += '<table width="498" border="0" cellspacing="0" cellpadding="0">' + CRLF
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Base de Adiantamento                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipoRot = "2"
		If cBaseAux = "S" .And. nBaseIr # 0
			IF !( lTerminal )
				cHtml +=	'<tr>'
				cHtml +=		'<td class="tdPrinc"><p class="pStyle1"><font color=#000082 face="Courier new" size=2><i>'+STR0058+'</i></p></td></font>' //"Base IR Adiantamento"
				cHtml +=		'<td class="td26_94_AlignR"><p></td>'
				cHtml +=		'<td class="td26_95_AlignR"><p>'+ Transform(nBaseIr,cPict1)+'</td>'
				cHtml +=		'<td class="td26_18_AlignL"><p></td>'
				cHtml += 	'</tr>'
			Else
				cHtml += '<tr>'
				cHtml += '<td width="304" class="etiquetas">' + STR0058 + ' + </td>' + CRLF
				cHtml += '<td width="103" class="dados"><div align="center">' + Transform(nBaseIr,cPict3) + '</div></td>' + CRLF
				cHtml += '<td width="91"  class="dados"><div align="center">' + Transform(0.00   ,cPict3) + '</div></td>' + CRLF
				cHtml += '</tr>'
			EndIF
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Base de Folha e de 13o 20 Parc.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cTipoRot = "1" .Or. cTipoRot = "6"
		
		IF cBaseAux = "S"
			
			IF !( lTerminal )
				
				cHtml += '<tr>'
				cHtml +=	'<td class="tdPrinc">'
				cHtml +=    '<p class="pStyle1">'+ STR0056 +'</p></td>'//"Base FGTS/Valor FGTS"
				cHtml +=	'<td class="td26_94_AlignR">' + Transform(nBaseFgts,cPict3)+'</td>'
				cHtml +=	'<td class="td26_95_AlignR">' + Transform(nFgts    ,cPict3)+'</td>'
				cHtml += '</tr>'
				cHtml += '<tr>'
				cHtml +=	'<td class="tdPrinc">'
				cHtml +=    '<p class="pStyle1">'+ STR0057 +'</p></td>'//"Base IRRF Folha/Ferias"
				cHtml +=	'<td class="td26_94_AlignR">' + Transform(nBaseIr,cPict3)+'</td>'
				cHtml +=	'<td class="td26_95_AlignR">' + Transform(nBaseIrfe,cPict3)+'</td>'
				cHtml += '</tr>'
				
			Else
				
				cHtml += 								"<tr>"
				cHtml += 									"<td width=219' bgcolor='#FAFBFC' class='etiquetas'>"
				cHtml +=										STR0056 + CRLF //"Base FGTS/Valor FGTS"
				cHtml +=									"</td>" + CRLF
				cHtml += 									"<td width='45' bgcolor='#FAFBFC' class='dados'>" + CRLF
				cHtml += 										'<div align="left" class="etiquetas"> </div>' + CRLF
				cHtml +=									"</td>" + CRLF
				cHtml += 									"<td width='127' bgcolor='#FAFBFC' class='dados'>" + CRLF
				cHtml +=										"<div align='right'>" + Transform(nBaseFgts,cPict3) + "</div>" + CRLF
				cHtml +=									"</td>" + CRLF
				cHtml += 									"<td width='127'  bgcolor='#FAFBFC' class='dados'>" + CRLF
				cHtml +=										"<div align='right'>" + Transform(nFgts    ,cPict3) + "</div>" + CRLF
				cHtml +=									'</td>' + CRLF
				cHtml += 									"<td width='107' valign='top' bgcolor='#FAFBFC'>" + CRLF
				cHtml += 										"<div align='right'><span class='dados'></span></div>" + CRLF
				cHtml += 									"</td>" + CRLF
				cHtml += 								"</tr>" + CRLF
				
				cHtml += 								"<tr>" + CRLF
				cHtml += 									"<td width='219' class='etiquetas'>"
				cHtml +=										STR0057 + CRLF //"Base IRRF Folha/Ferias"
				cHtml += 									"</td>" + CRLF
				cHtml += 									"<td width='45' class='dados'>" + CRLF
				cHtml += 										'<div align="left" class="etiquetas"> </div>' + CRLF
				cHtml +=									"</td>" + CRLF
				cHtml += 									"<td width='127' class='dados'>" + CRLF
				cHtml +=											"<div align='right'>" + Transform(nBaseIr,cPict3) + "</div>" + CRLF
				cHtml += 									"</td>" + CRLF
				cHtml += 									"<td width='127'  class='dados'>"  + CRLF
				cHtml += 										"<div align='right'>" + Transform(nBaseIrFe,cPict3) + "</div>" + CRLF
				cHtml += 									"</td>" + CRLF
				cHtml += 									"<td width='107' class='dados'>" + CRLF
				cHtml +=									"</td>" + CRLF
				cHtml += 								'</tr>'
				
				cHtml += 								"<tr>" + CRLF
				cHtml += 									"<td width='219' class='etiquetas' bgcolor='#FAFBFC' >"
				cHtml +=										STR0116 + CRLF //"Base INSS"
				cHtml += 									"</td>" + CRLF
				cHtml += 									"<td width='45' class='dados'>" + CRLF
				cHtml += 										'<div align="left" class="etiquetas" bgcolor="#FAFBFC"> </div>' + CRLF
				cHtml +=									"</td>" + CRLF
				cHtml += 									"<td width='127' class='dados' bgcolor='#FAFBFC' >" + CRLF
				cHtml +=											"<div align='right'>" + Transform(nAteLim,cPict3) + "</div>" + CRLF
				cHtml += 									"</td>" + CRLF
				cHtml += 									"<td width='127'  class='dados' bgcolor='#FAFBFC' >"  + CRLF
				cHtml += 										"<div align='right'></div>" + CRLF
				cHtml += 									"</td>" + CRLF
				cHtml += 									"<td width='107' class='dados' bgcolor='#FAFBFC' >" + CRLF
				cHtml +=									"</td>" + CRLF
				cHtml += 								'</tr>'
				
			EndIF
			
		EndIF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bases de FGTS e FGTS Depositado da 1¦ Parcela                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cTipoRot = "5"
		
		If cBaseAux = "S"
			
			IF !( lTerminal )
				
				cHtml += 	'<tr>'
				cHtml += 		'<td class="tdPrinc">'
				cHtml +=		'<p class="pStyle1">'+ STR0056 +'</td>' //"Base FGTS / Valor FGTS"
				cHtml += 		'<td class="td26_94_AlignL">' + Transform(nBaseFgts,cPict1) +'</td>'
				cHtml += 		'<td class="td26_95_AlignL">' + Transform(nFgts,cPict2)+'</td>'
				cHtml +=		'<td align=right height="26" width="95"  style="border-left: 0px solid #FF9B06; border-right:0px solid #FF9B06; border-bottom:1px solid #FF9B06 ; border-top: 0px solid #FF9B06 bgcolor=#6F9ECE"></td>'
				cHtml += 	'</tr>'
				
			Else
				
				cHtml += 								"<tr>"
				cHtml += 									"<td width=219' bgcolor='#FAFBFC' class='etiquetas'>"
				cHtml +=										STR0056 + CRLF //"Base FGTS/Valor FGTS"
				cHtml +=									"</td>" + CRLF
				cHtml += 									"<td width='45' bgcolor='#FAFBFC' class='dados'>" + CRLF
				cHtml += 										'<div align="left" class="etiquetas"> </div>' + CRLF
				cHtml +=									"</td>" + CRLF
				cHtml += 									"<td width='127' bgcolor='#FAFBFC' class='dados'>" + CRLF
				cHtml +=										"<div align='right'>" + Transform(nBaseFgts,cPict3) + "</div>" + CRLF
				cHtml +=									"</td>" + CRLF
				cHtml += 									"<td width='127'  bgcolor='#FAFBFC' class='dados'>" + CRLF
				cHtml +=										"<div align='right'>" + Transform(nFgts    ,cPict3) + "</div>" + CRLF
				cHtml +=									'</td>' + CRLF
				cHtml += 									"<td width='107' valign='top' bgcolor='#FAFBFC'>" + CRLF
				cHtml += 										"<div align='right'><span class='dados'></span></div>" + CRLF
				cHtml += 									"</td>" + CRLF
				cHtml += 								"</tr>" + CRLF
				
			EndIF
			
		Endif
		
	EndIF
	
	IF !( lTerminal )
		
		cHtml += '</font></i></b>'
		cHtml += '</TBody>'
		cHtml += '</table>'
		cHtml += '</center>'
		cHtml += '</div>'
		cHtml += '<hr whidth = 100% align=right color="#FF812D">'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Espaco para Observacoes/mensagens                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHtml += '<!Mensagem>'
		cHtml += '<Table bgColor=#6F9ECE border=0 cellPadding=0 cellSpacing=0 height=100 width=598>'
		cHtml += 	'<TBody>'
		cHtml +=	'<tr>'
		cHtml +=	'<td align=left height=18 width=574 style="border-left:1px solid #FF9B06; border-right:1px solid #FF9B06; border-bottom: 0px solid #FF9B06 ; border-top:1px solid #FF9B06 bgcolor=#6F9ECE"><i><font face="Arial" size="2" color="#000082">'+DESC_MSG1+ '</font></td></tr>'
		cHtml +=	'<tr>'
		cHtml +=	'<td align=left height=18 width=574 style="border-left:1px solid #FF9B06; border-right:1px solid #FF9B06; border-bottom: 0px solid #FF9B06 ; border-top: 0px solid #FF9B06 bgcolor=#6F9ECE"><i><font face="Arial" size="2" color="#000082">'+DESC_MSG2+ '</font></td></tr>'
		cHtml +=	'<tr>'
		cHtml += 	'<td align=left height=18 width=574 style="border-left:1px solid #FF9B06; border-right:1px solid #FF9B06; border-bottom:1px solid #FF9B06 ; border-top: 0px solid #FF9B06 bgcolor=#6F9ECE"><i><font face="Arial" size="2" color="#000082">'+DESC_MSG3+ '</font></td></tr>'
		IF cMesComp == Month(SRA->RA_NASC)
			cHtml += '<TD align=left height=18 width=574 bgcolor="#FFFFFF"><EM><B><CODE>      <font face="Arial" size="4" color="#000082">'
			cHtml += '<MARQUEE align="middle" bgcolor="#FFFFFF">' + STR0059	+ '</marquee><code></b></font></td></tr>' //"F E L I Z &nbsp;&nbsp  A N I V E R S A R I O !!!! "
		EndIF
		cHtml += '</TBody>'
		cHtml += '</Table>'
		cHtml += '</table>'
		cHtml += '</body>'
		cHtml += '</html>'
		
	Else
		
		cHtml +=							"</TR>" + CRLF
		cHtml +=						"</TBODY>" + CRLF
		cHtml +=					"</TABLE>" + CRLF
		
		cHtml +=				"</TBODY>" + CRLF
		cHtml +=			"</TABLE>" + CRLF
		
		//Separador
		cHtml +=			"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
		cHtml +=				"<TBODY>" + CRLF
		cHtml +=					"<TR>" + CRLF
		cHtml +=						"<TD vAlign=top width='100%' height=10>" + CRLF
		cHtml +=						"</TD>" + CRLF
		cHtml +=			 		"</TR>" + CRLF
		cHtml +=				"</TBODY>" + CRLF
		cHtml +=			"</TABLE>" + CRLF
		
		//Rodape
		cHtml += 			RodaHtml()
		
		cHtml += 		'</TABLE>' + CRLF
		cHtml += 		'<p align="right"><a href="javascript:self.print()"><img src="imagens/imprimir.gif" width="90" height="28" hspace="20" border="0"></a></p>' + CRLF
		cHtml += 	'</body>' + CRLF
		cHtml += '</html>' + CRLF
		
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia e-mail p/funcionario                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !( lTerminal )
		lEnvioOK := GPEMail(cSubject,cHtml,cEMail)
	EndIF
	
	RestArea( aSvArea )
Return( IF( lTerminal , cHtml , NIL ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fImpTeste ºAutor  ³R.H. - Natie        º Data ³  11/29/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Testa impressao de Formulario Teste                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpTeste(cString,nTipoRel)
	//--Comando para nao saltar folha apos o MsFlush.
	SetPgEject(.F.)
	
	@ PROW(),PCOL() PSAY ""
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Descarrega teste de impressao                                ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	MS_Flush()
	fInicia(cString,nTipoRel)
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o Li com a a linha de impressão correten para não saltar linhas no teste  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	li := _Prow()
	
	If nTipoRel == 2
		@ LI,00 PSAY AvalImp(Limite)
	Endif
	
	lRetCanc	:= Pergunte("GPR30A",.T.)
	
	Vez := If(nTipRel = 1,1,0)
Return Vez

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fInicia   ºAutor  ³Natie               º Data ³  04/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa parametros para impressao                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fInicia(cString,nTipoRel)
	If LastKey() = 27 .Or. nLastKey = 27
		Return  .F.
	EndIf
	
	If nTipoRel# 3
		SetDefault(aReturn,cString)
	EndIf
	
	If LastKey() = 27 .OR. nLastKey = 27
		Return .F.
	EndIf
Return .T.

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³CabecHtml  		³Autor³Marinaldo de Jesus ³ Data ³18/09/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna Cabecalho HTML para o RHOnLine                      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³cHtml  														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso	   ³GPER030       										    	³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function CabecHtml( cReferencia , dDataPagto , dDataRef )
	Local cHtml 		:= ""
	Local cLogoEmp		:= RetLogoEmp()
	Local nSalario		:= 0
	Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
	Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario
	
	nSalario := fBuscaSal( dDataRef )
	IF ( nSalario == 0 )
		nSalario := SRA->RA_SALARIO
	EndIf
	
	DEFAULT cReferencia	:= ""
	
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega Funcao do Funcion. de acordo com a Dt Referencia     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc  )
	
	//Logo e Titulo
	cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY class='fundo'>"
	cHtml +=			"<img src='" + cLogoEmp +"' width='206' height='030' align=left hspace=30>" + CRLF
	cHtml +=					"<b>" + CRLF
	cHtml += 						"<span class='titulo_opcao'>" + Capital( STR0044 ) + "</span>" + CRLF //DEMONSTRATIVO DE PAGAMENTO
	cHtml +=					"</b>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Empresa
	cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0097 + CRLF //"Empresa: "
	cHtml += 						"</span>" + CRLF
	cHtml +=	        			 "<span class='dados'>" + CRLF
	cHtml +=								Capital( AllTrim( Desc_Fil ) ) + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=	 		"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Separador
	cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=	 		"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Endereco e CNPJ
	cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='65%' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0098 + CRLF //"Endereço:"
	cHtml +=						"</span>" + CRLF
	cHtml +=						"<span class='dados'>"
	cHtml +=								Capital( AllTrim( Desc_End ) ) + "</span>" + CRLF
	cHtml +=						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=				"<TD vAlign=top width='35%' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0099 + CRLF	//"CNPJ:"
	cHtml +=						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								Transform( Desc_CGC , "@R 99.999.999/9999-99") + CRLF
	cHtml +=						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=			"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Separador
	cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=	 		"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Data do Credito e Conta Corrente
	cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=				"<TD vAlign=top width='40%' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0101 + CRLF //"Crédito em:"
	cHtml +=						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								Dtoc(dDataPagto) + CRLF
	cHtml +=						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=				"<TD vAlign=top width='60%' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0102 + CRLF //"Banco/Agência/Conta:"
	cHtml +=						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								AllTrim( Transform( SRA->RA_BCDEPSA , "@R 999/999999" ) ) + "/" + SRA->RA_CTDEPSA + CRLF
	cHtml +=						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=			"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Separador
	cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=	 		"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Referencia
	cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" +  STR0100 + CRLF //"Referência:"
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								cReferencia + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=	 		"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Separador
	cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100%' height=5>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=	 		"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Nome e Matricula
	cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='75%' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0105 + CRLF //"Nome:
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								Capital( AllTrim( SRA->RA_NOME ) ) + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=				"<TD vAlign=top width='25%' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0106 + CRLF //"Matricula:"
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								SRA->RA_MAT + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=			"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Separador
	cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=	 		"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//CTPS, Serie e CPF
	cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0107 + CRLF	//"CTPS:"
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=							SRA->RA_NUMCP + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=				"<TD vAlign=top width='100' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0108 + CRLF //"Série:"
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								SRA->RA_SERCP + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=				"<TD vAlign=top width='172' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0109 + CRLF //"CPF:"
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								Transform( SRA->RA_CIC , "@R 999.999.999-99" ) + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=	 		"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Separador
	cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=	 		"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='60%' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0103  + CRLF //Funcao
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								Capital( AllTrim( cDescFunc ) ) + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=				"<TD vAlign=top width='40%' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0104 + CRLF //Salário Nominal:
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								Transform( nSalario , cPict1 ) + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=			"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Separador
	cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=	 		"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Centro de Custo
	cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0110 + CRLF //Centro de Custo:
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								AllTrim( SRA->RA_CC ) + " - " + Capital( AllTrim(fDesc("SI3",SRA->RA_CC,"I3_DESC",TamSx3("I3_DESC")[1]) ) ) + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=			"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Separador
	cHtml +=	"<TABLE border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#FFFFFF' bordercolordark='#FFFFFF'bordercolorlight='#FFFFFF' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='100%' height=1>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=	 		"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
	
	//Admissao
	cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top width='329' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0111 + CRLF //"Admissão:"
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								Dtoc( SRA->RA_ADMISSA ) + CRLF
	cHtml +=						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=				"<TD vAlign=top width='231' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0112 + CRLF //"Dependente(s) IR:"
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								SRA->RA_DEPIR + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=				"<TD vAlign=top width='390' height=1>" + CRLF
	cHtml +=					"<P align=left>" + CRLF
	cHtml +=						"<span class='etiquetas'>" + STR0113 + CRLF //"Dependente(s) Salário Família:"
	cHtml += 						"</span>" + CRLF
	cHtml +=						"<span class='dados'>" + CRLF
	cHtml +=								SRA->RA_DEPSF + CRLF
	cHtml += 						"</span>" + CRLF
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=			"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF	
Return cHtml

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³RodaHtml  		³Autor³Marinaldo de Jesus ³ Data ³18/09/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna Rodape HTML para o RHOnLine                         ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³cHtml  														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso	   ³GPER030       										    	³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function RodaHtml()
	Local cHtml	:= ""
	
	cHtml +=	"<TABLE border='2' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1'>" + CRLF
	cHtml +=		"<TBODY>" + CRLF
	cHtml +=			"<TR>" + CRLF
	cHtml +=				"<TD vAlign=top height=1>" + CRLF
	cHtml +=					"<P align=center>" + CRLF
	cHtml += 							STR0114 + CRLF //'"Válido como Comprovante Mensal de Rendimentos"'
	cHtml +=						"<br>" + CRLF
	cHtml += 							STR0115 + CRLF //"( Artigo no. 41 e 464 da CLT, Portaria MTPS/GM 3.626 de 13/11/1991 )"
	cHtml +=					"</P>" + CRLF
	cHtml +=				"</TD>" + CRLF
	cHtml +=			"</TR>" + CRLF
	cHtml +=		"</TBODY>" + CRLF
	cHtml +=	"</TABLE>" + CRLF
Return cHtml

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o	   ³fMontaDtTcf 	³Autor³Ricardo Duarte     ³ Data ³13/08/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna a data valida para a consulta do Terminal Consulta  ³
³          ³do Funcionario                                         		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³cHtml  														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso	   ³GPER030       										    	³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fMontaDtTcf(cMesAno,nDia)
	Local dDataValida
	Default nDia := 0
	
	dDataValida := stod(right(cMesAno,4)+left(cMesAno,2)+"01")
	dDataValida := stod(right(cMesAno,4)+left(cMesAno,2)+strzero(f_UltDia(dDataValida),2))+nDia
Return dDataValida

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fFormatLin³ Autor ³ Rogerio			    ³ Data ³ 23.02.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fFormatLine(cString)
	If Len(cString) > 128
		cString:= SubStr(cString, 1, 128)
	ElseIf Len(cString) < 128
		cString:= PadR(cString, 128)
	EndIf
Return "| " + cString + " |"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³DescBco	³ Autor ³ Ze Maria			    ³ Data ³ 23.02.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Descricao de Banco ou de Agˆncia 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function DescBco(cCodigo,cFil,nBytes,lNomeAg)
	Local cAlias := ALIAS()
	
	DEFAULT lNomeAg := .F.
	DEFAULT nBytes := 40
	
	If nBytes > 40
		nBytes := 40
	Endif
	
	dbSelectArea ( "SA6" )
	
	If (cFil # Nil .And. cFilial == '  ' ) .Or. cFil == Nil
		cFil := cFilial
	Endif
	
	If dbSeek( cFil + cCodigo )
		If lNomeAg
			cRet := Left(A6_NomeAge+Space(nBytes),nBytes)
		Else
			cRet := Left(A6_Nome+Space(nBytes),nBytes)
		Endif
	Else
		cRet := Space(nBytes)
	Endif
	
	dbSelectArea ( cAlias )
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³DescCc 	³ Autor ³ Ze Maria			    ³ Data ³ 23.02.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Descricao do Centro de Custo					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function DescCc(cCodigo,cFil,nBytes)
	Local cAlias := Alias()
	
	If nBytes = Nil
		nBytes := 20
	Endif
	
	If nBytes > 25
		nBytes := 25
	Endif
	
	dbSelectArea( "CTT" )
	
	If ( cFil # Nil .And. cFilial == "  " ) .Or. cFil == Nil
		cFil := cFilial
	Endif
	
	If dbSeek( cFil + cCodigo )
		cRet := Left(CTT_DESC01 + Space(nBytes), nBytes)
	Else
		cRet := Space(nBytes)
	Endif
	
	dbSelectArea( cAlias )
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³calcTLabor| Autor ³ FMonroy               ³ Data ³ 29.08.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcular Tiempo Laborado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³calcTLabor(cExp,dExp)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Encabezado de Recibo.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function calcTLabor(dDataIni,dDatafim)

Local nDias:=0
Local nDI:=day(dDataIni)
Local nDF:=Day(dDataFim)
Local nMes:=0
Local nMI:=Month(dDataIni)
Local nMF:=Month(dDataFim)
Local nAnios:=0
Local nAI:=Year(dDataIni)
Local nAF:=Year(dDataFim)
Local nMesT:=0
Local n:=0

Local cCadena


If nMI>nMF .AND. nDI<nDF
	nAnios:=nAF-nAI-1
	nMes:=12-nMI+nMF
	nDias:=nDF-nDI
EndIf
If nMI>nMF .AND. nDI>nDF
	nAnios:=nAF-nAI-1
	nMes:=12-nMI+nMF-1
	
	
	nMesT:=nMI
	n:=1
	While n<=nMes
		nMesT++
		If nMesT==13
			nMesT:=1
		EndIf
		n++
	EndDo
	
	nDias:=F_UltDia(CTOD("01/" + strzero(nMesT,2) + "/" + str(nAI+nAnios)))-nDI+nDF
	
EndIf

If nMI>nMF .AND. nDI=nDF
	nAnios:=nAF-nAI-1
	nMes:=12-nMI+nMF
	nDias:=nDF-nDI

EndIf
/////////////////////////////////////////////
If nMI<nMF .AND. nDI>nDF
	nAnios:=nAF-nAI
	nMes:=12-nMI+nMF-1
	
	
	nMesT:=nMI
	n:=1
	While n<=nMes
		nMesT++
		If nMesT==13
			nMesT:=1
		EndIf
		n++
	EndDo
	
	nDias:=F_UltDia(CTOD("01/" + strzero(nMesT,2) + "/" + str(nAI+nAnios)))-nDI+nDF
	

EndIf
If nMI<nMF .AND. nDI<nDF

	nAnios:=nAF-nAI
	nMes:=nMF-nMI
	nDias:=nDF-nDI

EndIf
If nMI<nMF .AND. nDI=nDF
	nAnios:=nAF-nAI
	nMes:=nMF-nMI
	nDias:=nDF-nDI
EndIf

/////////////////////////////////////////////////////////

If nMI=nMF .AND. nDI<nDF
	nAnios:=nAF-nAI
	nMes:=nMF-nMI
	nDias:=nDF-nDI
EndIf

If nMI=nMF .AND. nDI>nDF
	nAnios:=nAF-nAI-1
	nMes:=11
	IIF((nMI-1)==0,nMesT:=12,nMesT:=nMI-1)
	nDias:=F_UltDia(CTOD("01/" + strzero(nMesT,2) + "/" + str(nAI+nAnios)))-nDI+nDF

EndIf

If nMI=nMF .AND. nDI=nDF
	nAnios:=0
	nMes:=0
	nDias:=0

EndIf

cCadena:= strzero(nAnioS,2)+SPACE(1)+STR0127+space(1)+strzero(nMes,2)+SPACE(1)+STR0128+space(2)+strzero(nDiaS,2)+SPACE(1)+STR0129

Return cCadena