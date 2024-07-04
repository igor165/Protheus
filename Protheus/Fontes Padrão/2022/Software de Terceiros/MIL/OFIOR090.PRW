// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 07     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "OFIOR090.CH"
#INCLUDE "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ OFIOR090 ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.09.91 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emiss„o da Rela‡„o de de Notas Fiscais                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR090()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utiliza variavel static para diminuir acessos ao SXG         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static aTamSXG
Static aTamSXG2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel
LOCAL titulo :=STR0001	//"Rela‡„o de Notas Fiscais"
LOCAL cDesc1 :=STR0002	//"Emiss„o da Rela‡„o de Notas de Compras"
LOCAL cDesc2 :=STR0003	//"A op‡„o de filtragem deste relat¢rio s¢ ‚ v lida na op‡„o que lista os"
LOCAL cDesc3 :=STR0004	//"itens. Os parƒmetros funcionam normalmente em qualquer op‡„o."
LOCAL cString:="SD1"
LOCAL aOrd    := {OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0043)}		//" Por Nota           "###" Por Produto        "###" Por Data Digitacao "
LOCAL Tamanho  := "M"
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private lA2_IBGE := If(SA2->(FieldPos("A2_IBGE"))>0,.t.,.f.)
PRIVATE cPerg  :="OFR090"
PRIVATE nTotal := 0
PRIVATE aReturn := { OemToAnsi(STR0007), 1,OemToAnsi(STR0008), 2, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica conteudo da variavel STATIC p/ Grupo de Clientes    ³
//³ (001) e Grupo de Lojas (002)                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTamSXG := If(aTamSXG  == NIL,TamSXG("001"),aTamSXG)
aTamSXG2:= If(aTamSXG2 == NIL,TamSXG("002"),aTamSXG2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("ACV")
ValidPerg()
Pergunte("OFR090",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Produto de                                       ³
//³ mv_par02 // Produto ate                                      ³
//³ mv_par03 // Data de                                          ³
//³ mv_par04 // Data ate                                         ³
//³ mv_par05 // Lista os itens da nota                           ³
//³ mv_par06 // Grupo de                                         ³
//³ mv_par07 // Grupo ate                                        ³
//³ mv_par08 // Fornecedor de                                    ³
//³ mv_par09 // Fornecedor ate                                   ³
//³ mv_par10 // Almoxarifado de                                  ³
//³ mv_par11 // Almoxarifado ate                                 ³
//³ mv_par12 // De  Nota                                         ³
//³ mv_par13 // Ate Nota                                         ³
//³ mv_par14 // De  Serie                                        ³
//³ mv_par15 // Ate Serie                                        ³
//³ mv_par16 // Do  Tes                                          ³
//³ mv_par17 // Ate Tes                                          ³
//³ mv_par18 // Moeda                                            ³
//³ mv_par19 // Otras moedas                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "OFIOR090"

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| C080Imp(@lEnd,wnRel,cString,Tamanho)},titulo)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C080IMP  ³ Autor ³ Cristina M. Ogura     ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR090			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C080Imp(lEnd,WnRel,cString,Tamanho)
LOCAL cbCont := 0
LOCAL cbTxt  := Space(10)

PRIVATE nDecs:=Msdecimais(mv_par18) //casas decimais utilizadas na moeda da impressao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
li       := 80
m_pag    := 1
imprime  := .T.
nOrdem 	:= aReturn[8]
nTipo  	:= IIF(aReturn[4]=1,15,18)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos de acordo com os parametros              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1    := STR0009	//"** RELACAO DAS NOTAS FISCAIS DE COMPRAS **"
If nOrdem == 1
	If mv_par05 == 1
		ImpAnalit(@lEnd,Tamanho)
	Else
		ImpSintet(@lEnd,Tamanho)
	Endif
ElseIf nOrdem == 2
	ImpProduto(@lEnd,Tamanho)
ElseIf nOrdem == 3
	ImpDataDig(@lEnd,Tamanho)
Endif

If li != 80
	roda(cbcont,cbtxt)
EndIF

dbSelectArea("SD1")
Set Filter To
dbSetOrder(1)

If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpAnalit³ Autor ³ Claudinei M. Benzi    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime as notas com os itens				  	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpAnalit( Void )                              		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR090                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function ImpAnalit(lEnd,Tamanho)

LOCAL nFirst   :=0,nTotGeral:=0,nTotDesco:=0,nTGerIcm :=0,nTGerIpi :=0
Local nTGImpInc:= 0, nTGImpNoInc:= 0
LOCAL titulo   :=STR0010	//"RELACAO DE NOTAS FISCAIS"
LOCAL cabec1   :=STR0011	//"RELACAO DOS ITENS DAS NOTAS"
LOCAL cabec2   :=""
LOCAL cCabec   := IIF(cPaisLoc == "BRA",STR0012,STR0050)	//"CODIGO DO MATERIAL   D E S C R I C A O             CFO  TE  ICM  IPI  LOCAL             QUANTIDADE   VALOR UNITARIO      VALOR TOTAL"
LOCAL nomeprog :="OFIOR090"
LOCAL nSavOrder
LOCAL loper		:= .T.
Local nValIpi,nValMerc,nValDesc,nValIcm,nImpInc,nImpNoInc
Local nValImpInc:=0,nValImpNoInc:=0
Local cQuery	:= ""
Local cIndex 	:= CriaTrab("",.F.)
Local nIndex	:= 0
Local nY		:= 0
Private aImpostos :={}
Private nTaxa:=1 //taxa para convesao a moeda da impressao
Private nMoeda:=1
Private dDtDig:=dDataBase

dbselectarea("SF1")
dbsetorder(1)

dbSelectArea("SF4")
dbSetOrder(1)

dbSelectArea("SD1")
dbSetOrder(1)

cQuery 	+= "D1_FILIAL=='"+xFilial("SD1")+"'.And.D1_DOC>='"+mv_par12+"'.And.D1_DOC<='"+mv_par13+"'"
cQuery	+= ".And.D1_SERIE>='"+mv_par14+"'.And.D1_SERIE<='"+mv_par15+"'.And."
cQuery 	+= "D1_COD>='"+mv_par01+"'.And.D1_COD<='"+mv_par02+"'.And."
cQuery 	+= "DTOS(D1_DTDIGIT)>='"+DTOS(mv_par03)+"'.And.DTOS(D1_DTDIGIT)<='"+DTOS(mv_par04)+"'"

IndRegua("SD1",cIndex,IndexKey(),,cQuery)
nIndex := RetIndex("SD1")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbSeek(xFilial("SD1"),.T.)

SetRegua(RecCount())		// Total de Elementos da regua

While !Eof() .And. xFilial("SD1")==SD1->D1_FILIAL
	
	IncRegua()			// Incrementa a Regua de processamento
	
	if !Empty(mv_par20)
		dbSelectArea("ACV")
		dbSetOrder(5)
		dbSeek(xFilial("ACV")+SD1->D1_COD)
		if ACV->ACV_CODPRO <> mv_par20
			dbSelectArea("SD1")
			dbSkip()
			Loop
		Endif
	Endif
	If lEnd
		@PROW()+1,001 PSAY STR0013	//"CANCELADO PELO OPERADOR"
		loper:=.F.
		Exit
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a validacao do filtro do usuario           	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aReturn[7]) .And. !&(aReturn[7])
		dbSelectArea("SD1")
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Faixa Do Grupo do Produto               	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_GRUPO < mv_par06 .or. SD1->D1_GRUPO > mv_par07
		dbSelectArea("SD1")
		dbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Fornecedor                                	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_FORNECE < mv_par08 .or. SD1->D1_FORNECE > mv_par09
		dbSelectArea("SD1")
		dbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica local                				 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SD1->D1_LOCAL < mv_par10 .Or. SD1->D1_LOCAL > mv_par11
		dbSelectArea("SD1")
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Tes                  				 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SD1->D1_TES < mv_par16 .Or. SD1->D1_TES > mv_par17
		dbSelectArea("SD1")
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Moeda                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SF1->(dbseek(SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)) //posiciona o cabecalho da nota
	if mv_par19==2  //nao imprimir notas com moeda diferente da escolhida
		if if(SF1->F1_MOEDA==0,1,SF1->F1_MOEDA)!=mv_par18
			dbSelectArea("SD1")
			dbSkip()
			Loop
		Endif
	Endif
	
	nTaxa :=SF1->F1_TXMOEDA  // taxa para conversao da moeda
	nMoeda:=SF1->F1_MOEDA
	dDtDig:=SF1->F1_DTDIGIT
	
	nValIpi  := 0
	nValMerc := 0
	nValDesc := 0
	nValIcm  := 0
	nValImpInc	:= 0
	nValImpNoInc:= 0
	nImpInc		:= 0
	nImpNoInc	:= 0
	
	cDocAnt := SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
	
	While !Eof().And.SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA==xFilial("SD1")+cDocAnt
		
		If lEnd
			@PROW()+1,001 PSAY STR0013	//"CANCELADO PELO OPERADOR"
			loper:=.F.
			Exit
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a Faixa Do Codigo do Produto               		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SD1->D1_COD < mv_par01 .or. SD1->D1_COD > mv_par02
			dbSelectArea("SD1")
			dbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a Faixa De Data de Digitacao               	     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SD1->D1_DTDIGIT < mv_par03 .or. SD1->D1_DTDIGIT > mv_par04
			dbSelectArea("SD1")
			dbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a Faixa Do Grupo do Produto               	         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SD1->D1_GRUPO < mv_par06 .or. SD1->D1_GRUPO > mv_par07
			dbSelectArea("SD1")
			dbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica local                				 				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SD1->D1_LOCAL < mv_par10 .Or. SD1->D1_LOCAL > mv_par11
			dbSelectArea("SD1")
			dbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Tes                  				 				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SD1->D1_TES < mv_par16 .Or. SD1->D1_TES > mv_par17
			dbSelectArea("SD1")
			dbSkip()
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a validacao do filtro do usuario           	         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			dbSelectArea("SD1")
			dbSkip()
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se e nova pagina                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If li > 56
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			If nFirst != 0
				li++
			EndIf
		Endif
		
		If nFirst == 0
			nFirst := 1
			ImprNota()
			li++
			@li,000 PSAY cCabec
			li++
		Endif
		
		If ( cPaisLoc#"BRA" )
			aImpostos:=TesImpInf(SD1->D1_TES)
			nImpInc	:=	0
			nImpNoInc:=	0
			nImpos	:=	0
			For nY:=1 to Len(aImpostos)
				cCampImp:="SD1->"+(aImpostos[nY][2])
				nImpos:=&cCampImp
				nImpos:=xmoeda(nImpos,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
				If ( aImpostos[nY][3]=="1" )
					nImpInc	+=nImpos
				Else
					nImpNoInc+=nImpos
				EndIf
			Next
		Endif
		@li,00 PSay SD1->D1_COD
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+SD1->D1_COD)
		
		@li,pCol()+1  PSAY B1_GRUPO
		@li,pCol()+1  PSAY B1_CODITE
		@li,pCol()+1  PSAY SubStr(B1_DESC,1,20)
		
		dbSelectArea("SD1")
		If ( cPaisLoc<>"BRA" )
			@li,pCol()+1 PSAY SD1->D1_TES
			@li,pCol()+1 PSAY nImpNoInc   Picture TM(nImpNoInc,9)
			@li,pCol()+1 PSAY nImpInc     Picture TM(nImpInc,9)
			@li,pCol()+1 PSAY SD1->D1_LOCAL
		Else
			@li,pCol()+1 PSAY SD1->D1_CF
			@li,pCol()+1 PSAY SD1->D1_TES
			@li,pCol()+1 PSAY SD1->D1_PICM    Picture PesqPict("SD1","D1_PICM")
			@li,pCol()+1 PSAY SD1->D1_IPI     Picture PesqPict("SD1","D1_IPI")
			@li,pCol()+1 PSAY SD1->D1_LOCAL
		EndIf
		@li,pCol()+2 PSAY Transform(SD1->D1_QUANT,"@E 99999")
		@li,pCol()+1 PSAY xmoeda(SD1->D1_VUNIT,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SD1","D1_VUNIT",14,mv_par18)
		@li,pCol()+1 PSAY xmoeda(SD1->D1_TOTAL,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SD1","D1_TOTAL",15,mv_par18)
		li++
		
		If ( cPaisLoc=="BRA" )
			nValIpi  += SD1->D1_VALIPI
			nValMerc := nValMerc + SD1->D1_TOTAL + SD1->D1_ICMSRET
			nValIcm  += SD1->D1_VALICM
			
			nTgerIcm += SD1->D1_VALICM
			nTgerIpi += SD1->D1_VALIPI
			nTotGeral := nTotGeral + SD1->D1_TOTAL - SD1->D1_VALDESC + SD1->D1_ICMSRET
		Else
			nValImpInc	+=nImpInc
			nValImpNoInc+=nImpNoInc
			nValMerc 	:= nValMerc + xmoeda(SD1->D1_TOTAL,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
			
			nTgImpInc 	+= nImpInc
			nTgImpNoInc += nImpNoInc
			nTotGeral 	:= nTotGeral + xmoeda(SD1->D1_TOTAL-SD1->D1_VALDESC,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
		EndIf
		
		nValDesc += xmoeda(SD1->D1_VALDESC,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
		nTotDesco+= xmoeda(SD1->D1_VALDESC,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
		
		If cPaisLoc == "BRA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Soma valor do IPI caso a nota nao seja compl. de IPI    	 ³
			//³ e o TES Calcula IPI nao seja "R"                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SF4")
			If dbSeek(xFilial("SF4")+SD1->D1_TES)
				dbSelectArea("SD1")
				If SD1->D1_TIPO != "P" .And. SF4->F4_IPI != "R"
					nValMerc += SD1->D1_VALIPI
					nTotGeral+= SD1->D1_VALIPI
				EndIf
			Else
				dbSelectArea("SD1")
				If SD1->D1_TIPO != "P"
					nValMerc += SD1->D1_VALIPI
					nTotGeral+= SD1->D1_VALIPI
				EndIf
			EndIf
		Else
			nValMerc  += nImpInc
			nTotGeral += nImpInc
		EndIf
		
		dbSelectArea("SD1")
		dbSkip()
	End
	
	nFirst   := 0
	
	If (nValIcm + nValMerc + nValIpi + nValImpInc + nValImpNoInc) > 0
		li++
		dbSelectArea("SF1")
		dbSetOrder(1)
		dbSeek(xFilial("SF1")+cDocAnt)
		@li,000 PSAY STR0014+SF1->F1_COND		//"COND. PAGTO : "
		@li,029 PSAY IIF(cPaisLoc == "BRA",STR0015,STR0051) //"TOTAL ICM :"
		
		If cPaisLoc=="BRA"
			@li,040 PSAY nValIcm   	Picture tm(SF1->F1_VALICM,15)
		Else
			@li,045 PSAY nValImpNoInc Picture pesqpict("SF1","F1_VALIMP1",15,mv_par18)
		Endif
		
		If ( cPaisLoc=="BRA" )
			@li,056 PSAY STR0016							//"TOTAL IPI :"
			@li,067 PSAY nValIpi    Picture tm(SF1->F1_VALIPI,15)
		Else
			@li,061 PSAY STR0056							//"TOTAL IPI :"
			@li,077 PSAY nValImpInc Picture pesqpict("SF1","F1_VALIMP1",15,mv_par18)
		EndIf
		
		li++
		@li,000 PSAY STR0017							//"FRETE :"
		@li,010 PSAY xmoeda(SF1->F1_FRETE,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SF1","F1_FRETE",15,mv_par18)
		@li,029 PSAY STR0018							//"DESP.:"
		@li,040 PSAY xmoeda(SF1->F1_DESPESA,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)Picture pesqpict("SF1","F1_DESPESA",15,mv_par18)
		@li,056 PSAY STR0019							//"DESC.:"
		@li,067 PSAY nValDesc Picture pesqpict("SF1","F1_DESCONT",15,mv_par18)
		@li,096 PSAY STR0020							//"TOTAL NOTA   :"
		@li,115 PSAY (nValMerc-nValDesc)+xmoeda(SF1->F1_DESPESA+SF1->F1_FRETE,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SF1","F1_VALMERC",17,mv_par18)
		
		nTotGeral := nTotGeral + xmoeda(SF1->F1_DESPESA+SF1->F1_FRETE,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
		
		li++
		@li,000 PSAY __PrtThinLine()
	Endif
	
	dbSelectArea("SD1")
	dbSkip()
	
EndDo

If (nTgerIcm + nTgerIpi + nTotGeral + nTgImpInc + nTgImpNoInc) > 0 .and. lOper
	li+=2
	@li,000 PSAY STR0021			//"TOTAL GERAL - "
	@li,027 PSAY IIF(cPaisLoc == "BRA",STR0022,STR0052)	//"ICM :"
	If ( cPaisLoc=="BRA" )
		@li,036 PSAY nTgerIcm		Picture tm(nTGerIcm,15)
	Else
		@li,036 PSAY nTgImpNoInc Picture tm(nTGImpNoInc,15,nDecs)
	EndIf
	If ( cPaisLoc=="BRA" )
		@li,052 PSAY STR0023			//"IPI :"
		@li,063 PSAY nTgerIpi		Picture tm(nTGerIpi,15)
	Else
		@li,052 PSAY STR0057			//"IPI :"
		@li,063 PSAY nTgImpInc Picture tm(nTGImpInc,15,nDecs)
	EndIf
	@li,080 PSAY STR0024			//"DESC.:"
	@li,088 PSAY nTotDesco Picture tm(nTotDesco,13,nDecs)
	@li,105 PSAY STR0025			//"TOTAL :"
	@li,115 PSAY nTotGeral Picture tm(nTotGeral,17,nDecs)
Endif

If File(cIndex+OrdBagExt())
	Ferase(cIndex+OrdBagExt())
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImprNota ³ Autor ³ Claudinei M. Benzi    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o Corpo da Nota 				  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImprNota( Void )                 		             	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function ImprNota(lEnd)
Local nPosNome :=92
Local nTamNome :=34

// Caso nao utilize tamanho min, considera tamanho max e altera layout de impressao ref grupo 001
If aTamSXG[1] != aTamSXG[3]
	nPosNome += aTamSXG[4]-aTamSXG[3]
	nTamNome -= aTamSXG[4]-aTamSXG[3]
EndIf

// Caso nao utilize tamanho min, considera tamanho max e altera layout de impressao ref grupo 002
If aTamSXG2[1] != aTamSXG2[3]
	nPosNome += aTamSXG2[4]-aTamSXG2[3]
	nTamNome -= aTamSXG2[4]-aTamSXG2[3]
EndIf

li++
@li,000 PSAY STR0026+SD1->D1_DOC+" " + SD1->D1_SERIE		//"NUMERO : "
@li,026 PSAY STR0027 + Dtoc(SD1->D1_EMISSAO)		//"EMISSAO:"
@li,045 PSAY STR0028 + Dtoc(SD1->D1_DTDIGIT)		//"DIG.:"
@li,061 PSAY STR0029 + SD1->D1_TIPO				//"TIPO: "

If SD1->D1_TIPO $ "BD"
	@li,68 PSAY STR0030 + SD1->D1_FORNECE + " " + SD1->D1_LOJA		//" CLIENTE    : "
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek( xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA )
	@li,nPosNome PSAY SubStr(A1_NOME,1,nTamNome)
Else
	@li,68 PSAY STR0031 + SD1->D1_FORNECE + " " + SD1->D1_LOJA		//" FORNECEDOR : "
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek( xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA)
	@li,nPosNome PSAY SubStr(A2_NOME,1,nTamNome)
EndIf

dbselectArea("SD1")
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpSintet³ Autor ³ Claudinei M. Benzi    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime as Notas sem Itens						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImprSintet( Void )                           	   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR090                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function ImpSintet(lEnd,Tamanho)

LOCAL titulo,cabec1,cabec2,nomeprog
LOCAL nTotGeral,nTotGerIcm,nTGerIpi,nTGImpNoInc,nTGImpInc
LOCAL nValIcm,nValIpi,nValMerc,nImpInc,nImpNoInc,nImpos
LOCAL lOper := .T.
LOCAL nPosNome := 35
LOCAL nTamNome := 30
LOCAL nY	   := 0

Private aImposto:={}
Titulo   :=STR0032	//"RELACAO DE NOTAS FISCAIS"

// Caso nao utilize tamanho min, considera tamanho max e altera layout de impressao ref grupo 001
If aTamSXG[1]  !=  aTamSXG[3]
	// Caso nao utilize tamanho min, considera tamanho max e altera layout de impressao ref grupo 001
	cabec1   :=STR0047   //"NUMERO       SER   DATA     CODIGO               RAZAO SOCIAL         PRACA       PGTO     ICM            IPI       TOTAL MERCADORIA"
	//                      123456789012 123 99/99/9999 12345678901234567890 1234567890123456 123456789012345 XXX 999,999,999.99 999,999,999.99 9,999,999,999.99
	//                      0         1         2         3         4         5         6         7         8         9         0         1         2         3
	//                      0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
Else
	// Caso utilize tamanho min,considera tamano minimo e nao altera Layout
	cabec1   := IIF(cPaisLoc == "BRA", STR0033, STR0053)	//"NUMERO       SER   DATA     CODIGO RAZAO SOCIAL                       PRACA       PGTO     ICM            IPI       TOTAL MERCADORIA"
	//                      123456789012 123 99/99/9999 123456 123456789012345678901234567890 123456789012345 XXX 999,999,999.99 999,999,999.99 9,999,999,999.99
	//                      0         1         2         3         4         5         6         7         8         9         0         1         2         3
	//                      0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
Endif

cabec2      :=STR0034	//"                  EMISSAO   FORNEC "
// 123456789012 123 99/99/9999 123456 123456789012345678901234567890 123456789012345 XXX 999,999,999.99 999,999,999.99 9,999,999,999.99
// 0         1         2         3         4         5         6         7         8         9         0         1         2         3
// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
nTotGeral:=0
nTGerIcm:=0
nTGerIpi:=0
nTGImpNoInc:=0
nTGImpInc:=0

// Caso nao utilize tamanho min, considera tamanho max e altera layout de impressao ref grupo 001
If aTamSXG[1] != aTamSXG[3]
	nPosNome += aTamSXG[4] - aTamSXG[3]
	nTamNome -= aTamSXG[4] - aTamSXG[3]
Endif

nomeprog :="OFIOR090"
dbSelectArea("SF4")
dbSetOrder(1)

dbselectArea("SF1")
dbSetOrder(1)
dbSeek(xFilial("SF1")+mv_par12+mv_par14,.T.)

SetRegua(RecCount())		// Total de Elementos da regua

Do While !Eof() .And. SF1->F1_FILIAL == xFilial("SF1") .And. SF1->F1_DOC <= mv_par13
	
	IncRegua()				// Incrementa a regua
	
	If lEnd
		@PROW()+1,001 PSAY STR0013	//"CANCELADO PELO OPERADOR"
		loper:=.F.
		Exit
	Endif
	
	If SF1->F1_SERIE < mv_par14 .Or. SF1->F1_SERIE > mv_par15
		dbSkip()
		Loop
	Endif
	
	If SF1->F1_DTDIGIT < mv_par03 .or. SF1->F1_DTDIGIT > mv_par04
		dbSkip()
		Loop
	EndIf
	
	If SF1->F1_FORNECE < mv_par08 .or. SF1->F1_FORNECE > mv_par09
		dbSkip()
		Loop
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Moeda                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if mv_par19==2  //nao imprimir notas com moeda diferente da escolhida
		If IIf(SF1->F1_MOEDA==0,1,SF1->F1_MOEDA)!=mv_par18
			dbskip()
			loop
		endif
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se e nova pagina           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If li > 56
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	nValMerc := 0
	nValIcm  := 0
	nValIpi  := 0
	nImpInc	 := 0
	nImpNoInc:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incluido para acumular valores considerando parametros  	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	dbSetOrder(1)
	If dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
		cNotAnt := xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
		While !Eof() .And. cNotAnt == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			
			If lEnd
				@PROW()+1,001 PSAY STR0013	//"CANCELADO PELO OPERADOR"
				loper:=.F.
				Exit
			Endif
			IF SD1->D1_FORNECE < mv_par08 .or. SD1->D1_FORNECE > mv_par09
				dbSkip()
				Loop
			Endif
			If SD1->D1_COD < mv_par01 .or. SD1->D1_COD > mv_par02
				dbSkip()
				Loop
			Endif
			If SD1->D1_DTDIGIT < mv_par03 .or. SD1->D1_DTDIGIT > mv_par04
				dbSkip()
				Loop
			Endif
			If SD1->D1_GRUPO < mv_par06 .or. SD1->D1_GRUPO > mv_par07
				dbSkip()
				Loop
			Endif
			If SD1->D1_LOCAL < mv_par10 .Or. SD1->D1_LOCAL > mv_par11
				dbSkip()
				Loop
			Endif
			If SD1->D1_TES < mv_par16 .Or. SD1->D1_TES > mv_par17
				dbSkip()
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa a validacao do filtro do usuario           	         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aReturn[7]) .And. !&(aReturn[7])
				dbSkip()
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Moeda                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if mv_par19==2  //nao imprimir notas com moeda diferente da escolhida
				if if(SF1->F1_MOEDA==0,1,SF1->F1_MOEDA)!=mv_par18
					dbskip()
					loop
				endif
			endif
			
			If ( cPaisLoc#"BRA" )
				aImpostos:=TesImpInf(SD1->D1_TES)
				For nY:=1 to Len(aImpostos)
					cCampImp:="SD1->"+(aImpostos[nY][2])
					nImpos:=&cCampImp
					nImpos:=xmoeda(nImpos,SF1->F1_MOEDA,mv_par18,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
					If ( aImpostos[nY][3]=="1" )
						nImpInc	+=nImpos
					Else
						nImpNoInc+=nImpos
					EndIf
				Next
				nValMerc := nValMerc + xmoeda(SD1->D1_TOTAL-SD1->D1_VALDESC,SF1->F1_MOEDA,mv_par18,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
			Else
				nValMerc := nValMerc + SD1->D1_TOTAL - SD1->D1_VALDESC + SD1->D1_ICMSRET
				nValIcm  += SD1->D1_VALICM
				nValIpi  += SD1->D1_VALIPI
				dbSelectArea("SF4")
				If dbSeek(xFilial("SF4")+SD1->D1_TES)
					nValMerc+=IF(SF1->F1_TIPO!="P".And.SF4->F4_IPI!="R",SD1->D1_VALIPI,0)
				Else
					nValMerc+=IF(SF1->F1_TIPO!="P",SD1->D1_VALIPI,0)
				EndIf
			EndIf
			dbSelectArea("SD1")
			dbSkip()
		End
	EndIf
	dbSelectArea("SF1")
	If (nValMerc+nValipi+nValicm+nImpInc+nImpNoInc) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime a linha da nota fiscal                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@li,000 PSAY SF1->F1_DOC
		@li,013 PSAY SF1->F1_SERIE
		@li,017 PSAY SF1->F1_EMISSAO
		@li,028 PSAY SF1->F1_FORNECE
		
		If SF1->F1_TIPO $ "BD"
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek( xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA )
			@li,nPosNome PSAY SubStr(SA1->A1_NOME,1,nTamNome)
			if lA1_IBGE
				dbSelectArea("VAM")
				dbSetOrder(1)
				dbSeek( xFilial("VAM") + SA1->A1_IBGE )
				@li,066 PSAY SubStr(VAM->VAM_DESCID,1,15)
			else
				@li,066 PSAY SubStr(SA1->A1_MUN,1,15)
			endif
		Else
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek( xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA)
			@li,nPosNome PSAY SubStr(SA2->A2_NOME,1,nTamNome)
			if lA2_IBGE
				dbSelectArea("VAM")
				dbSetOrder(1)
				dbSeek( xFilial("VAM") + SA2->A2_IBGE )
				@li,066 PSAY SubStr(VAM->VAM_DESCID,1,15)
			else
				@li,066 PSAY SubStr(SA2->A2_MUN,1,15)
			endif
		EndIf
		dbSelectArea("SF1")
		@li,082 PSAY SF1->F1_COND    Picture "!!!"
		If ( cPaisLoc=="BRA" )
			@li,086 PSAY nValIcm    Picture tm(SF1->F1_VALICM ,14)
			@li,101 PSAY nValIpi    Picture tm(SF1->F1_VALIPI ,14)
			@li,115 PSAY (nValMerc+SF1->F1_FRETE+SF1->F1_DESPESA)   Picture tm(SF1->F1_VALMERC,17)
		Else
			@li,086 PSAY nImpNoInc Picture pesqpict("SF1","F1_VALIMP1",14,mv_par18)
			@li,101 PSAY nImpInc   Picture pesqpict("SF1","F1_VALIMP1",14,mv_par18)
			@li,115 PSAY (nValMerc+xmoeda(SF1->F1_FRETE+SF1->F1_DESPESA,SF1->F1_MOEDA,mv_par18,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)) Picture pesqpict("SF1","F1_VALMERC",17,mv_par18)
		EndIf
		li++
		If ( cPaisLoc=="BRA" )
			nTgerIcm += nValIcm
			nTgerIpi += nValIpi
		Else
			nTgImpInc+=nImpInc
			nTgImpNoInc+=nImpNoInc
		EndIf
		nTotGeral:= nTotGeral + nValMerc + xmoeda(SF1->F1_FRETE + SF1->F1_DESPESA,SF1->F1_MOEDA,mv_par18,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
	Endif
	SF1->(dbSkip())
End

If lOper
	li++
	@li,000 PSAY __PrtThinLine()
	li++
	@li,025 PSAY STR0035	//"T O T A L  G E R A L : "
	If ( cPaisLoc=="BRA" )
		@li,086 PSAY nTgerIcm  Picture tm(nTGerIcm,14)
		@li,101 PSAY nTgerIpi  Picture tm(nTGerIpi,14)
	Else
		@li,086 PSAY nTgImpNoInc  Picture tm(nTGImpNoInc,14,nDecs)
		@li,101 PSAY nTgImpInc  Picture tm(nTGImpInc,14,nDecs)
	Endif                                                                                             0
	@li,115 PSAY nTotGeral Picture tm(nTotGeral,17,nDecs)
	li++
	@li,000 PSAY __PrtThinLine()
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpProduto³ Autor ³ Claudinei M. Benzi    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista por ordem de Produto							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpProduto( Void )                              			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR090                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpProduto(lEnd,Tamanho)
LOCAL nCodAnt,nTotProd,nTotGer,titulo,cabec1,cabec2,cCabec,nomeprog
LOCAL nQuebra,nTotQger
LOCAL nPosNome := 29
LOCAL nTamNome := 30
nTotProd := 0
nTotquant:= 0
nTotGer  := 0
nTotQGer := 0
Private nTaxa:=1 //taxa para convesao a moeda da impressao
Private nMoeda:=1
Private nDtDig:=dDataBase

dbselectarea("SF1")
dbsetorder(1)

cabec1  :=STR0036	 //"RELACAO DAS NOTAS FISCAIS DE COMPRAS"
cabec2  :=" "
titulo  :=STR0010 //"RELACAO DE NOTAS FISCAIS"
// Caso nao utilize tamanho min, considera tamanho max e altera layout de impressao ref grupo 001
If aTamSXG[1] != aTamSXG[3]
	cCabec  := IIF(cPaisLoc == "BRA", STR0048, STR0054)	 //"NUMERO       EMISSAO    FORNEC               RAZAO SOCIAL    LC CFO TE  ICM   IPI   TP    QUANTIDADE VALOR UNITARIO     VALOR TOTAL"
	//                   012345678901 99/99/9999 12345678901234567890 1234567890123456 12 123 123 12345 12345 1  1234567890123 12345678901234  12345678901234
	//                             1         2         3         4         5         6         7         8         9        10        11        12        13
	//                   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
Else
	cCabec  :=STR0037	 //"NUMERO       EMISSAO    FORNEC RAZAO SOCIAL                  LC CFO TE  ICM   IPI   TP    QUANTIDADE VALOR UNITARIO     VALOR TOTAL"
	//                   012345678901 99/99/9999 123456 12345679012345678901234567890  12 123 123 12345 12345 1  1234567890123 12345678901234   12345678901234
	//                             1         2         3         4         5         6         7         8         9        10        11        12        13
	//                   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
Endif

nomeprog:="OFIOR090
nQuebra := 0

// Caso nao utilize tamanho min, considera tamanho max e altera layout de impressao ref grupo 001
If aTamSXG[1] != aTamSXG[3]
	nPosNome += aTamSXG[4] - aTamSXG[3]
	nTamNome -= aTamSXG[4] - aTamSXG[3]
Endif

dbselectArea("SD1")
dbSetOrder(2)
dbSeek(xFilial("SD1")+mv_par01,.T.)

SetRegua(RecCount())		// Total de Elementos da regua

While !Eof().And.SD1->D1_FILIAL = xFilial("SD1") .And. SD1->D1_COD >= mv_par01 ;
	.And. SD1->D1_COD <= mv_par02
	
	If lEnd
		@PROW()+1,001 PSAY STR0013	//"CANCELADO PELO OPERADOR"
		loper:=.F.
		Exit
	Endif
	
	IncRegua()		// Incrementa a regua
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o numero da Nota Fiscal                    		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_DOC < mv_par12 .or. SD1->D1_DOC > mv_par13
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a serie da Nota Fiscal                    			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_SERIE < mv_par14 .or. SD1->D1_SERIE > mv_par15
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Faixa De Data de Digitacao               		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_DTDIGIT < mv_par03 .or. SD1->D1_DTDIGIT > mv_par04
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Faixa Do Grupo do Produto               	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_GRUPO < mv_par06 .or. SD1->D1_GRUPO > mv_par07
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Fornecedor                                	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_FORNECE < mv_par08 .or. SD1->D1_FORNECE > mv_par09
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica local                				 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SD1->D1_LOCAL < mv_par10 .Or. SD1->D1_LOCAL > mv_par11
		dbSkip()
		Loop
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Tes                  				 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SD1->D1_TES < mv_par16 .Or. SD1->D1_TES > mv_par17
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a validacao do filtro do usuario           	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aReturn[7]) .And. !&(aReturn[7])
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Moeda                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SF1->(dbseek(SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)) //posiciona o cabecalho da nota
	if mv_par19==2  //nao imprimir notas com moeda diferente da escolhida
		if if(SF1->F1_MOEDA==0,1,SF1->F1_MOEDA)!=mv_par18
			dbskip()
			loop
		endif
	endif
	nTaxa:=SF1->F1_TXMOEDA  //taxa para conversao da moeda
	nMoeda:=SF1->F1_MOEDA
	dDtDig:=SF1->F1_DTDIGIT
	
	If li > 56
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	If nQuebra == 0
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+SD1->D1_COD)
			@li,000 PSAY left(STR0038 + SD1->D1_COD,39)		//"PRODUTO : "
			@li,40 PSAY SubStr(SB1->B1_DESC,1,29)
		Else
			@li,000 PSAY left(STR0038 + SD1->D1_COD,70)		//"PRODUTO : "
		Endif
		@li ,72 PSAY STR0040			//"GRUPO : "
		@li ,81 PSAY SB1->B1_GRUPO
		dbselectArea("SD1")
		li++
		@li,000 PSAY cCabec
		nQuebra := 1
		nCodAnt := SD1->D1_COD
		nTotProd:= 0
		nTotQuant:= 0
	Endif
	If nCodant != SD1->D1_COD
		nQuebra := 0
		li++
		@li,000  PSAY STR0041		//"TOTAL DO PRODUTO : "
		@li,085  PSAY  nTotQuant Picture pesqpict("SD1","D1_TOTAL",16)
		@li,115  PSAY  nTotProd  Picture pesqpict("SD1","D1_TOTAL",17,mv_par18)
		li++
		@li,000 PSAY __PrtThinLine()
		li++
		nTotQger+=  nTotQuant
		nTotGer +=  nTotProd
		Loop
	Endif
	
	If li > 56
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	li++
	@li,00 PSAY SD1->D1_DOC
	@li,11 PSAY SD1->D1_EMISSAO
	@li,22 PSAY SD1->D1_FORNECE
	If SD1->D1_TIPO $ "BD"
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)
		@li,nPosNome PSAY SUBSTR(A1_NOME,1,nTamNome)
	Else
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
		@li,nPosNome PSAY SUBSTR(A2_NOME,1,nTamNome)
	EndIf
	dbSelectArea("SD1")
	@li,060 PSAY SD1->D1_LOCAL
	If cPaisLoc=="BRA"
		@li,063 PSAY SD1->D1_CF
	Endif
	
	@li,069 PSAY SD1->D1_TES
	
	If ( cPaisLoc=="BRA" )
		@li,073 PSAY SD1->D1_PICM		Picture PesqPict("SD1","D1_PICM",5)
	EndIf
	@li,079 PSAY SD1->D1_IPI		Picture PesqPict("SD1","D1_IPI",5)
	@li,085 PSAY SD1->D1_TIPO
	@li,088 PSAY SD1->D1_QUANT	Picture TM(D1_QUANT,13)
	@li,102 PSAY xmoeda(SD1->D1_VUNIT,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SD1","D1_VUNIT",14,mv_par18)
	@li,118 PSAY xmoeda(SD1->D1_TOTAL-SD1->D1_VALDESC+SD1->D1_ICMSRET,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SD1","D1_TOTAL",14,mv_par18)
	nTotProd+=xmoeda(SD1->D1_TOTAL-SD1->D1_VALDESC+SD1->D1_ICMSRET,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa)
	nTotQuant+=SD1->D1_QUANT
	dbSkip()
EndDo

li++
@li,000  PSAY STR0041		//"TOTAL DO PRODUTO : "
@li,087  PSAY  nTotQuant Picture pesqpict("SD1","D1_QUANT",14)
@li,115  PSAY  nTotProd  Picture pesqpict("SD1","D1_TOTAL",17,mv_par18)
li++
@li,000  PSAY __PrtThinLine()
li++
nTotGer  += nTotProd
nTotQGer += nTotQuant

@li,000  PSAY STR0042	//"T O T A L  G E R A L : "
@li,087  PSAY  nTotQger  Picture pesqpict("SD1","D1_QUANT",14)
@li,115  PSAY  nTotGer   Picture tm(nTotGer,17,nDecs)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpDataDig³ Autor ³Rodrigo de A. Sartorio ³ Data ³ 15/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista por ordem de Data de Digitacao   					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpDataDig( Void )                              			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR090                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpDataDig(lEnd,Tamanho)
LOCAL dDataAnt,nTotData,nTotGer,titulo,cabec1,cabec2,cCabec,nomeprog
LOCAL nQuebra
LOCAL nPosNome := 53
LOCAL nTamNome := 10
nTotData := 0
nTotGer  := 0
Private nTaxa:=1 //taxa para convesao a moeda da impressao
Private nMoeda:=1
Private nDtDig:=dDataBase

dbselectarea("SF1")
dbsetorder(1)

titulo  :=STR0010	 //"RELACAO DE NOTAS FISCAIS"
cabec1  :=STR0036	 //"RELACAO DAS NOTAS FISCAIS DE COMPRAS"
cabec2  :=" "

// Caso nao utilize tamanho min, considera tamanho max e altera layout de impressao ref grupo 001
If aTamSXG[1] != aTamSXG[3]
	cCabec  := IIF(cPaisLoc == "BRA", STR0049, STR0055)//"NUMERO       PRODUTO         FORNEC              RAZAO SOCIAL LC CFO TE  ICM   IPI   TP    QUANTIDADE VALOR UNITARIO      VALOR TOTAL"
	//                   123456789012 123456789012345 12345678901234567890 12345678901 12 123 001 12345 12345 1  9,999,999,999 99,999,999,999 9999,999,999,999
	//                             1         2         3         4         5         6         7         8         9        10        11        12        13
	//                   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
Else
	cCabec  :=STR0044	//"NUMERO       PRODUTO         FORNEC RAZAO SOCIAL              LC CFO TE  ICM   IPI   TP    QUANTIDADE VALOR UNITARIO      VALOR TOTAL"
	//                   123456789012 123456789012345 123456 1234567890123456789012345 12 123 001 12345 12345 1  9,999,999,999 99,999,999,999 9999,999,999,999
	//                             1         2         3         4         5         6         7         8         9        10        11        12        13
	//                   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
Endif

nomeprog:="OFIOR090"
nQuebra := 0

// Caso nao utilize tamanho min, considera tamanho max e altera layout de impressao ref grupo 001
If aTamSXG[1] != aTamSXG[3]
	nPosNome += aTamSXG[4] - aTamSXG[3]
	nTamNome -= aTamSXG[4] - aTamSXG[3]
Endif

dbselectArea("SD1")
dbSetOrder(6)
dbSeek(xFilial("SD1")+DTOS(mv_par03),.T.)

SetRegua(RecCount())		// Total de Elementos da regua

While !Eof().And.SD1->D1_FILIAL = xFilial("SD1") .And. SD1->D1_DTDIGIT >= mv_par03 ;
	.And. SD1->D1_DTDIGIT <= mv_par04
	
	If lEnd
		@PROW()+1,001 PSAY STR0013	//"CANCELADO PELO OPERADOR"
		loper:=.F.
		Exit
	Endif
	
	IncRegua()		// Incrementa a regua
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Faixa Do Codigo do Produto               		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SD1->D1_COD < mv_par01 .or. SD1->D1_COD > mv_par02
		dbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o numero da Nota Fiscal                    		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_DOC < mv_par12 .or. SD1->D1_DOC > mv_par13
		dbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a serie da Nota Fiscal                    			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_SERIE < mv_par14 .or. SD1->D1_SERIE > mv_par15
		dbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Faixa Do Grupo do Produto               	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_GRUPO < mv_par06 .or. SD1->D1_GRUPO > mv_par07
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Fornecedor                                	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SD1->D1_FORNECE < mv_par08 .or. SD1->D1_FORNECE > mv_par09
		dbSkip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica local                				 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SD1->D1_LOCAL < mv_par10 .Or. SD1->D1_LOCAL > mv_par11
		dbSkip()
		Loop
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Tes                  				 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SD1->D1_TES < mv_par16 .Or. SD1->D1_TES > mv_par17
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a validacao do filtro do usuario           	         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aReturn[7]) .And. !&(aReturn[7])
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Moeda                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SF1->(dbseek(SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)) //posiciona o cabecalho da nota
	if mv_par19==2  //nao imprimir notas com moeda diferente da escolhida
		If IIf(SF1->F1_MOEDA==0,1,SF1->F1_MOEDA)!=mv_par18
			dbskip()
			loop
		endif
	endif
	nTaxa:=SF1->F1_TXMOEDA  //taxa para conversao da moeda
	nMoeda:=SF1->F1_MOEDA
	dDtDig:=SF1->F1_DTDIGIT
	
	If li > 56
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	If nQuebra == 0
		@li,000 PSAY STR0045	//"DATA DE DIGITACAO : "
		@li,020 PSAY SD1->D1_DTDIGIT
		li++
		@li,000 PSAY cCabec
		nQuebra := 1
		dDataAnt := SD1->D1_DTDIGIT
		nTotData:= 0
	Endif
	If dDataAnt != SD1->D1_DTDIGIT
		nQuebra := 0
		li++
		@li,000  PSAY STR0046		//"TOTAL NA DATA : "
		@li,115  PSAY  nTotData  Picture pesqpict("SD1","D1_TOTAL",17,mv_par18)
		li++
		@li,000 PSAY __PrtThinLine()
		li++
		nTotGer +=  nTotData
		Loop
	Endif
	
	If li > 56
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	li++
	@li,00 PSAY SD1->D1_DOC
	@li,10 PSAY left(SD1->D1_COD,30)
	@li,41 PSAY SD1->D1_FORNECE
	If SD1->D1_TIPO $ "BD"
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)
		@li,nPosNome PSAY SUBSTR(A1_NOME,1,nTamNome)
	Else
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
		@li,nPosNome PSAY SUBSTR(A2_NOME,1,nTamNome)
	EndIf
	@li,059 PSAY SD1->D1_LOCAL
	If cPaisLoc=="BRA"
		@li,062 PSAY SD1->D1_CF
	Endif
	@li,068 PSAY SD1->D1_TES
	If ( cPaisLoc=="BRA" )
		@li,072 PSAY SD1->D1_PICM        Picture PesqPict("SD1","D1_PICM",5)
	EndIf
	@li,078 PSAY SD1->D1_IPI     Picture PesqPict("SD1","D1_IPI",5)
	@li,084 PSAY SD1->D1_TIPO
	@li,087 PSAY SD1->D1_QUANT   Picture pesqpict("SD1","D1_QUANT",13)
	@li,101 PSAY xmoeda(SD1->D1_VUNIT,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SD1","D1_VUNIT",14,mv_par18)
	@li,116 PSAY xmoeda(SD1->D1_TOTAL-SD1->D1_VALDESC+SD1->D1_ICMSRET,nMoeda,mv_par18,dDtDig,nDecs+1,nTaxa) Picture pesqpict("SD1","D1_TOTAL",16,mv_par18)
	nTotData+=xmoeda(SD1->D1_TOTAL-SD1->D1_VALDESC+SD1->D1_ICMSRET,nMoeda,mv_par18,,nDecs+1,nTaxa)
	dbSelectArea("SD1")
	dbSkip()
EndDo

li++
@li,000  PSAY STR0046		//"TOTAL NA DATA : "
@li,115  PSAY  nTotData  Picture pesqpict("SD1","D1_TOTAL",17,mv_par18)
li++
@li,000  PSAY __PrtThinLine()
li++
nTotGer  += nTotData

@li,000  PSAY STR0042	//"T O T A L  G E R A L : "
@li,115  PSAY  nTotGer   Picture tm(nTotGer,17,nDecs)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³VALIDPERG º Autor ³ Thiago		     º Data ³  30/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))

aAdd(aRegs,{cPerg,"20",STR0058,"","","mv_chk","C", 06,0,0,"G","","mv_par20","","","","","","","","","","","","","","","","","","","","","","","","","ACV1",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return

