#Include "CTBA211.CH"
#Include "PROTHEUS.CH"
#Include "FWLIBVERSION.CH"

STATIC lGravouLan	:= .F.
STATIC nTamCta	:= TAMSX3("CT1_CONTA")[1]
STATIC nTamCC	:= TAMSX3("CTT_CUSTO")[1]
STATIC nTamItem	:= TAMSX3("CTD_ITEM")[1]
STATIC nTamClVl	:= TAMSX3("CTH_CLVL")[1]

STATIC cSpacCt	:= REPLICATE(" ",nTamCta)
STATIC cSpacCC	:= REPLICATE(" ",nTamCC)
STATIC cSpacIt	:= REPLICATE(" ",nTamItem)
STATIC cSpacCl  := REPLICATE(" ",nTamClVl)

STATIC cArqTrb	:= ""
STATIC cArqIND1	:= ""
STATIC cArqIND2	:= ""
STATIC nMAX_LINHA := CtbLinMax(GetMv("MV_NUMLIN"))

STATIC __cKeyCTZATU := ""
STATIC __cSeqLICTZ 	:= ""

STATIC __aJaFlag := {}
STATIC __aDocsLP := {}  

STATIC __lOKCusto := .F.
STATIC __lOKItem := .F.
STATIC __lOKClasse := .F.

STATIC _oCTBA2111
STATIC _lBlind := IsBlind()

Static nCA211Cnt	:= 0

// Manejo de entidad 05
Static lEntidad05   := (cPaisLoc $ "COL|PER" .And. CtbMovSaldo("CT0",,"05") .And. FWAliasInDic("QL6") .And. FWAliasInDic("QL7")) // Manejo de entidad 05
Static nTamE05	    := IIf(FWAliasInDic("QL6") .And. FWAliasInDic("QL7"), GetSx3Cache("QL6_ENT05","X3_TAMANHO"),0)
Static cSpacE05	    := IIf(FWAliasInDic("QL6") .And. FWAliasInDic("QL7"), Replicate(" ",nTamE05),"")

//Metricas apenas em Lib a partir de 20210517 e Binario 19.3.0.6
Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6"
Static __lCtbLgAp := SuperGetMV("MV_CTBLGAP", .F. , "0" ) == '1' //gera log de execução / default 0 nao gera 


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBA211   ³ Autor ³ Marcos S. Lobo        ³ Data ³ 26.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apuracao de Resultados -Lucros/Perdas	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba211()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba211                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA211(lAuto)
Local aSays 		:= {}
Local aButtons		:= {}
LOCAL nOpca    		:= 0
Local cMens			:= ""
Local oProcess
Local cFunction		:= "CTBA211"
Local cPerg			:= "CTB211"
Local cTitle		:= STR0001	// "Apuracao de Lucros / Perdas"
Local cDescription	:= 	STR0002 + CRLF + CRLF +;	//"Esta rotina ir  gerar os lancamentos contabeis de lucros e perdas."
						STR0015 + CRLF +;	//"Recomenda-se a verificação prévia ou reprocessamento de saldos antes "
						STR0016 + CRLF +;	//"de executar esta rotina."
						STR0017 + CRLF +;	//"Visualizar, para o Log de processamento"
						STR0018 // "Ordem, para sequencia de apurações ja processadas"
Local aInfoCustom	:= {}						
Local lExclusivo := IIF(FindFunction("ADMTabExc"), ADMTabExc("CT2") , !Empty(xFilial("CT2") ))
Local bProcess		:= { }
Private cCadastro 	:= OemToAnsi(STR0001)  //"Apuracao de Lucros / Perdas"
PRIVATE cString   	:= "CT2"
PRIVATE cDesc1    	:= OemToAnsi(STR0002)  //"Esta rotina ir  gerar os lancamentos contabeis de lucros e perdas."
PRIVATE cDesc2    	:= ""
PRIVATE cDesc3    	:= ""
PRIVATE titulo    	:= OemToAnsi(STR0003)  //"Simulacao da Apuracao"
PRIVATE cCancel   	:= OemToAnsi(STR0004)  //"***** CANCELADO PELO OPERADOR *****"
PRIVATE nomeprog  	:= "CTBA211"
PRIVATE aLinha    	:= { },nLastKey := 0

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf         

//Verifica se o CT2 é compartilhado


//Atualizar o arquivo SX5 com o flag de apuracao, apenas se for execução da 12.1.017
If GetRPORelease() <= "12.1.017"
	Ct210UpdX5()
EndIf

If GetNewPar("MV_ATUSAL","S") == "N"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra tela de aviso - Verificar se os saldos foram atualizados.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMens := OemToAnsi(STR0011)+chr(13)  //"CASO A ATUALIZACAO DOS  SALDOS BASICOS  NAO  SEJA  FEITA  NA "
	cMens += OemToAnsi(STR0012)+chr(13)  //"DIGITACAO DOS LANCAMENTOS (MV_ATUSAL = 'N'), FAVOR VERIFICAR "
	cMens += OemToAnsi(STR0013)+chr(13)  //"SE OS SALDOS ESTAO ATUALIZADOS !!!!"
	
	MsgInfo(cMens,OemToAnsi(STR0014))  //"ATEN€O"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Data Inicial de Apuracao                         ³
//³ mv_par02 // Data de Apuracao                                 ³
//³ mv_par03 // Numero do Lote			                         ³
//³ mv_par04 // Numero do SubLote		                         ³
//³ mv_par05 // Numero do Documento                              ³
//³ mv_par06 // Cod. Historico Padrao                            ³
//³ mv_par07 // Da Conta  		        						 ³
//³ mv_par08 // Ate a Conta                             		 ³
//³ mv_par09 // Moedas        			                         ³
//³ mv_par10 // Qual Moeda?                                      ³
//³ mv_par11 // Considera Entidades Pontes                       ³
//³ mv_par12 // Tipo de Saldo 				                     ³
//³ mv_par13 // Considera Entidades de Apuracao?Cadastro/Rotina  ³
//³ mv_par14 // Conta Ponte   				                     ³
//³ mv_par15 // Conta de Apuracao de Resultados                  ³
//³ mv_par16 // C.Custo Ponte 				                     ³
//³ mv_par17 // C.Custo de Apuracao de Resultados                ³
//³ mv_par18 // Item Ponte    				                     ³
//³ mv_par19 // Item de Apuracao de Resultados                   ³
//³ mv_par20 // Cl. Valor Ponte				                     ³
//³ mv_par21 // Cl. Valor de Apuracao de Resultados              ³
//³ mv_par22 // Do C.Custo		        						 ³
//³ mv_par23 // Ate o C.Custo                           		 ³
//³ mv_par24 // Do Item Contabil	    						 ³
//³ mv_par25 // Ate o Item Contabil                     		 ³
//³ mv_par26 // Da Classe de Valor	    						 ³
//³ mv_par27 // Ate a Classe de Valor                     		 ³
//³ mv_par28 //Reproces. Saldos   ?
//³ mv_par29 // Seleciona Filiais?	                     		 ³
//³ mv_par30 // Filial De	                     		 ³
//³ mv_par31 // Filial Ate	                     		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("CTB211",.F.)

Aadd( aInfoCustom, { STR0048, { |oCenterPanel| A211Ordem(oCenterPanel) }, "PROCESSA", { {} , {} } } )

If !lAuto

	bProcess := { |oSelf| If(MV_PAR29==1 .And. lExclusivo , ;// Seleciona filiais
								CTB211Fil(Nil,oSelf,MV_PAR30,MV_PAR31);
								, ;//Else
								Ctb211Proc(oProcess,oSelf) ;
							) }
	tNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg, aInfoCustom )	
Else
	Ctb211Proc(oProcess,oSelf,lAuto)
Endif

__lOKCusto 	:= .F.
__lOKItem 	:= .F.
__lOKClasse := .F.

nCA211Cnt	:= 0

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb211Fil ºAutor  ³Alvaro Camillo Neto º Data ³  21/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa o processamento para cada filial                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA211                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb211Fil(oProcess,oSelF,cFilDe,cFilAte)
Local cFilIni 	:= cFIlAnt
Local aArea		:= GetArea()
Local aSM0 		:= Iif( FindFunction( "AdmAbreSM0" ) , AdmAbreSM0() , {} )
Local nContFil 	:= 0     
Local cFilProc	:= "" // Variavel de controle 

If Len( aSM0 ) > 0
	For nContFil := 1 to Len(aSM0)
		If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
			Loop
		EndIf
		
		cFilAnt := aSM0[nContFil][SM0_CODFIL]
		If Alltrim(cFilProc) != Alltrim(xFilial("CT2")) 
			cFilProc:= xFilial("CT2")
		Else
			Loop
		EndIf
        If __lCtbLgAp
			oSelf:SaveLog( STR0046 + cFilAnt)//"MENSAGEM: EXECUTANDO A APURACAO DA FILIAL "
		EndIf

		Ctb211Proc(oProcess,oSelf)
	Next nContFil

	cFIlAnt := cFilIni
Else
	ProcLogAtu("ERRO","Atenção!","Nenhuma empresa/filial encontrada. Verique se está utilizando a ultima versão do ADMXFUN (MAR/2010)" )
Endif

RestArea(aArea)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb211Proc³ Autor ³ Marcos S. Lobo        ³ Data ³ 26.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Zeramento de Lucros/Perdas.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB211Proc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba211                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb211Proc(oObj,oSelf,lAuto)
Local nx
Local dLastProc
Local dDataILP		:= mv_par01		//Data Inicial de Apuração
Local dDataFLP		:= mv_par02		//Data Final de Apuracao
Local cLote 		:= mv_par03		//Num. do lote que sera gerado os lancamentos
Local cSubLote		:= mv_par04		//Num. do sublote que sera gerado os lancamentos
Local cDoc			:= mv_par05		//Num. do doc. que sera gerado os lancamentos
Local nLinha		:= 0
Local cLinha		:= '000'
Local cLinhaLan		:= '001'
Local cSeqLan		:= "001"
Local lFirst 		:= .T.
Local cLoteAtu 		:= cLote
Local cSubAtu		:= cSubLote
Local cDocAtu		:= cDoc
Local cKeyEntAtu	:= ""
Local nRecLanAtu	:= 0
Local nRecLan		:= 0
Local nOpcGRV 		:= 3			/// 3 = INCLUI LANCAMENTO / 4 = ALTERA
Local cKeyDocLP		:= ""			/// CHAVE DO DOCUMENTO ATUAL DE APURACAO
Local nRecLinha		:= 0		
Local nVlrCTZ		:= 0			/// VALOR DO LANCAMENTO NO CTZ (VALOR DO CT2 PODE SER SOMADO X vezes)
Local cHP			:= mv_par06		//Historico Padrao utilizado nos lancamentos
Local cContaIni		:= mv_par07		//Conta Inicial
Local cContaFim		:= mv_par08		//Conta Final
Local cCustoIni		:= mv_par22		//C.Custo Inicial
Local cCustoFim		:= mv_par23		//C.Custo Final
Local cItemIni		:= mv_par24		//Item Inicial
Local cItemFim		:= mv_par25		//Item Final
Local cClVlIni		:= mv_par26		//Classe Inicial
Local cClVlFim		:= mv_par27		//Classe Final
Local lMoedaEsp		:= Iif(mv_par09==2,.T.,.F.)	//Moedas
Local cMoeda		:= StrZero(Val(mv_par10),2)			//Define qual a moeda especifica
Local lPontes		:= Iif(mv_par11 == 1,.T.,.F.) //Considera Entidades Pontes
Local lCadastro		:= Iif(mv_par13 == 1,.T.,.F.)	//Consdera Endidades Pontes/Lp dos Cadastros
Local cTpSaldo		:= mv_par12		//Tipo de Saldo.
Local lPergOk		:= .T.
Local lClVl			:=	CtbMovSaldo("CTH")
Local lItem			:=	CtbMovSaldo("CTD")
Local lCusto		:= 	CtbMovSaldo("CTT")
Local aCtbMoeda 	:= {}
Local nInicio		:= 0
Local nFinal		:= 0
Local cDescHP		:= ""                                        
Local dDataAILP		:= dDataILP-1	/// DATA ANTERIOR À INICIAL DE LUCROS E PERDAS
Local dDataIRep		:= dDataFLP		/// DATA INI REPROC. IGUAL DATA FINAL DE APURACAO (ENQUANTO AINDA ESTA SEM A FUNCAO CTBGRAVSALDO)
Local dDataFRep		:= dDataFLP		/// REPROCESSAMENTO DE SALDOS DEVE SER SEMPRE ATÉ A DATA DE APURACAO -> POSTERIOR É APENAS ACUMULADO
Local cCampo		:= ""
Local lJaExec := .F.
Local lSlbase		:= Iif(GETMV("MV_ATUSAL")=="N",.F.,.T.)
Local nIndTmp		:= 0
Local lCtbCCLP	:= Iif(ExistBlock("CTB211CC"),.T.,.F.)
Local lCtbItLP 	:= Iif(ExistBlock("CTB211IT"),.T.,.F.)
Local lCtbCVLP 	:= Iif(ExistBlock("CTB211CV"),.T.,.F.)
Local lRetSaldo	:= .T.

////////////////////////////////////////////////////////////////////////////////////////
Local lObj		:= ValType(oObj) == "O"
Local cExerc	:= alltrim(str(Year(dDataFLP),4))
Local cFilCTG	:= ""
Local nMoed		:= 1
Local cMoed		:= "01"
Local nTpSld	:= 1
Local lJaProc 	:= .F.			/// SE A ROTINA JÁ COMECOU A TRANSFERIR REGISTROS P/ CV6 OU NÃO
Local lCriaTRB	:= .T.			/// SE DEVE OU NAO CRIAR UM TRB NOVO
Local lNovoTRB	:= .T.			/// SE FOI CRIA
Local cTpSldAnt	:= ""
Local cMoedAnt	:= ""
Local CTF_LOCK	:= 0
Local nForaCols	:= 0
Local cClVlPon	:= cSpacCL
Local cItemPon	:= cSpacIT
Local cCCPon	:= cSpacCC
Local cCtaPon	:= cSpacCT
Local cClVlLP	:= cSpacCL
Local cItemLP	:= cSpacIT
Local cCCLP		:= cSpacCC
Local cCtaLP	:= cSpacCT
Local lClVlOk	:= .T.
Local lItemOk	:= .T.
Local lCCOk		:= .T.
Local lCtaOk	:= .T.
Local cDigPon	:= ""
Local cDigLP	:= ""
Local aCriter	:= {}         		/// CRITERIO DE CONVERSAO DA CONTA DE ORIGEM (FORA DE USO)
Local aCritLP	:= {}				/// CRITERIO DE CONVERSAO DA CONTA DE APURACAO (FORA DE USO)
Local aCritPon	:= {}               /// CRITERIO DE CONVERSAO DA CONTA PONTE (FORA DE USO)   
Local aFilters	:= {}
Local lSaldo	:= .F.		/// INDICA SE APURACAO SERA PELO .F.->MOVIMENTO/.T. ->SALDO
Local lCTZDeb 	:= .F.
Local lGrvCT7		:= IIf(ExistBlock("GRVCT7"),.T.,.F.)
Local lGrvCT3		:= IIf(ExistBlock("GRVCT3"),.T.,.F.)
Local lGrvCT4		:= IIf(ExistBlock("GRVCT4"),.T.,.F.)
Local lGrvCTI		:= IIf(ExistBlock("GRVCTI"),.T.,.F.)
Local lAtuSldCT7	:= .T.
Local lAtuSldCT3	:= .T.
Local lAtuSldCT4	:= .T.
Local lAtuSldCTI	:= .T.
Local nK		:= 0
Local aOutrEntid
Local aEntid
Local lFiltra	:= .F.
Local lFilCT	:= .F.
Local lFilCC	:= .F.
Local lFilIT	:= .F.
Local lFilCL	:= .F.
Local lExclusivo := IIF(FindFunction("ADMTabExc"), ADMTabExc("CT2") , !Empty(xFilial("CT2") ))
Local nCtdSemaf  := 0
Local lReproc    := mv_par28 == 1
Local cMsgErroPg := ""
Local cIdioma    := Upper(Left(FWRetIdiom(), 2))

Local aMoedas	:= {}
Local cEnt05    := ""

/*variavel criada para permitir visualização do lançamento
 caso não tenha sido solicitada apuração na moeda 01*/
Local lApurMoeda1 := .F. 

Private  aCols 		:= {} // Utilizada na conversao das moedas
Private cSeqCorr  := ""

Default oObj	:= Nil
Default oSelf	:= Nil

//inicializando as variáveis estáticas para não ocorrer problemas de valores existentes
__aJaFlag 		:= {}	
__aDocsLP 		:= {}

__cKeyCTZATU 	:= ""
__cSeqLICTZ		:= ""
//Fim da inicialização das variáveis estáticas

//Iniciar telemetria - Tempo médio
If __lMetric
	nStart := Seconds()
EndIf

If lGrvCT7
	lAtuSldCT7	:= ExecBlock("GRVCT7",.F.,.F.)
Endif
If lGrvCT3
	lAtuSldCT3	:= ExecBlock("GRVCT3",.F.,.F.)
Endif
If lGrvCT4
	lAtuSldCT4	:= ExecBlock("GRVCT4",.F.,.F.)
Endif
If lGrvCTI
	lAtuSldCTI	:= ExecBlock("GRVCTI",.F.,.F.)
Endif

If cPaisLoc == 'CHI' .and. Val(cLinha) < 2  // a partir da segunda linha do lanc., o correlativo eh o mesmo
	cSeqCorr := CTBSqCor( CTBSubToPad(cSubLote) )
EndIf

If MV_PAR29 == 1 .And. !lExclusivo .and. __lCtbLgAp
	oSelf:SaveLog(STR0057) //"TRATAMENTO MULTI FILIAL DESABILITADO: CT2 COMPARTILHADO"
EndIf

////////////////////////////////////////////////////////////////////////////////////////

// Sub-Lote somente eh informado se estiver em branco
mv_par04 := Iif(Empty(GetMV("MV_SUBLOTE")), mv_par04, GetMV("MV_SUBLOTE"))

If lMoedaEsp					// Moeda especifica
	cMoeda	:= mv_par10
	aCtbMoeda := CtbMoeda(cMoeda)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSelf:SaveLog(GtDescHelp("NOMOEDA"))
		Return
	EndIf                  
	nInicio := val(cMoeda)
	nFinal	:= val(cMoeda)
Else
	nInicio	:= 1
	nFinal	:= __nQuantas
EndIf

If Empty(mv_par01)
	mv_par01 := CTOD("01/01/80")
EndIf

cTpApu := IIf(lPontes,"P","Z")

If ( !lMoedaEsp )
	
	For nX := nInicio to nFinal
		aAdd(aMoedas,StrZero(nX,2))
	Next nX

Else
	aMoedas := {cMoeda}	
Endif

// Caso a tabela LP exista na tabela CW0 o processo será feito por ela e nao pela SX5
If CtLPCW0Tab()
	If !CtLPCW0Vdt(dDataFLP,@lJaExec,@lPergOk,cMoeda,cTpSaldo,lMoedaEsp,!_lBlind)
		Return(.F.)
	EndIf	
Else
	Do Case 
	Case cIdioma == "PT"
		cCampo	:= "SX5->X5_DESCRI"
	Case cIdioma == "ES"
		cCampo	:= "SX5->X5_DESCSPA"
	Case cIdioma == "EN"
		cCampo	:= "SX5->X5_DESCENG"
	EndCase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ANTES DE INICIAR O PROCESSAMENTO, VERIFICO OS PARAMETROS.	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Data de Apuracao nao preenchida.
	If Empty(dDataFLP)                              
		Help(" ",1,"NOCTBDTLP")
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSelf:SaveLog(GtDescHelp("NOCTBDTLP"))
		Return(.F.)
	Else //Se a data estiver preenchida, verifica se ja foi rodado nessa data.
		dbSelectarea("SX5")
		dbSetOrder(1)
		If MsSeek(xFilial()+"LP"+cEmpAnt+cFilAnt)			
			While !Eof() .and. SX5->X5_TABELA == "LP"
				If Subs(&(cCampo),1,8) == Dtos(dDataFLP) 
					If (!lMoedaEsp .Or. (lMoedaEsp .And. Subs(&(cCampo),9,2) == cMoeda)) .And.;
							Subs(&(cCampo),11,1) == cTpSaldo
							If ! MsgYesNo(STR0008,OemToAnsi(STR0014+"Filial "+cFilAnt))
								Return(.F.)
							Else
								lJaExec := .T.
								Exit
							Endif
						EndIf
				Endif
				dbSkip() 
			End			
		EndIf
		//Verificar se o calendario da data solicitada esta encerrado
		lPergOk	:= CtbValiDt(1,dDataFLP,,cTpSaldo)
	Endif                            
EndIf
	
//Historico Padrao nao preenchido.
If Empty(cHP)	
	Help(" ",1,"CTHPVAZIO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSelf:SaveLog(GtDescHelp("CTHPVAZIO"))
	lPergOk := .F.
Else
	dbSelectArea("CT8")
	dbSetOrder(1)
	MsSeek(xFilial("CT8")+cHP)
	If found()
		cDescHP 	:= CT8->CT8_DESC
	Else            
		//Historico Padrao nao existe no cadastro.
	   	Help(" ",1,"CT210NOHP",,"FILIAL "+cFilAnt,2,0)
					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSelf:SaveLog(GtDescHelp("CT210NOHP"))
		lPergOk := .F.
	Endif
Endif                             
	
//Lote nao preenchido.
If Empty(cLote)
	Help(" ",1,"NOCT210LOT")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSelf:SaveLog(GtDescHelp("NOCT210LOT"))
	lPergOk := .F.
Endif
	
//Sub Lote nao preenchido.
If Empty(cSubLote)
	Help(" ",1,"NOCTSUBLOT")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSelf:SaveLog(GtDescHelp("NOCTSUBLOT"))
	lPergOk := .F.
Endif
	
//Documento nao preenchido.
If Empty(cDoc)
	Help(" ",1,"NOCT210DOC")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSelf:SaveLog(GtDescHelp("NOCT210DOC"))
	lPergOk := .F.
Else	//Se o documento estiver preenchido, verifico se existe lancamento com mesmo numero
		//de lote, sublote, documento e data
	dbSelectArea("CT2")
	dbSetOrder(1)

//	If ! lJaExec .And. MsSeek(xFilial()+dtos(dDataFLP)+cLote+cSubLote+cDoc)	
	
	If MsSeek(xFilial()+dtos(dDataFLP)+cLote+cSubLote+cDoc)	
		lPergOk := .F.		
		MsgAlert(OemtoAnsi(STR0009))//Data+Lote+Sublote+documento ja existe. 		
    Endif
Endif
	
//Conta Inicial e Conta Final nao preenchidos. 	
If Empty(cContaIni) .And. Empty(cContaFim)
	Help(" ",1,"NOCT210CT")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSelf:SaveLog(GtDescHelp("NOCT210CT"))
	lPergOk := .F.
Endif                                          
	
//Se for moeda especifica, verificar se a moeda esta preenchida
If lMoedaEsp
	If Empty(cMoeda)
		Help(" ",1,"NOCTMOEDA")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSelf:SaveLog(GtDescHelp("NOCTMOEDA"))
		lPergOk := .F.
	Endif
EndIf	
	     
//Tipo de saldo nao preenchido
If Empty(cTpSaldo)
	Help(" ",1,"NO210TPSLD")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSelf:SaveLog(GtDescHelp("NO210TPSLD"))
	lPergOk := .F.
Endif	       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VALIDACAO DAS ENTIDADES PONTE E DE APURACAO - ENTIDADES PELA ROTINA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Se utiliza as entidades ponte/LP da Rotina, verificar se os parametros estao preenchidos
If !lCadastro
	If lPontes .And. ( Empty( Mv_Par14 ) .Or. Empty( Mv_Par15 ) )
		If Empty( Mv_Par14 ) .And. Empty( Mv_Par15 )
			cMsgErroPg := OemToAnsi( STR0116 )
		ElseIf Empty( Mv_Par15 )
			cMsgErroPg := OemToAnsi( STR0115 )
		Else
			cMsgErroPg := OemToAnsi( STR0114 )
		EndIf

		If !_lBlind
			MsgAlert( cMsgErroPg )
		Else
			Help( " " , 1 , "NOCT210CT" )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSelf:SaveLog( GtDescHelp("NOCT210CT") + Space( 1 ) + cMsgErroPg )
		lPergOk := .F.	
	ElseIf !lPontes .And. Empty( Mv_Par15 )
		cMsgErroPg := OemToAnsi( STR0115 )

		If !_lBlind
			MsgAlert( cMsgErroPg )
		Else
			Help( " " , 1 , "NOCT210CT" )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSelf:SaveLog( GtDescHelp("NOCT210CT") + Space( 1 ) + cMsgErroPg )
		lPergOk := .F.		
	EndIf 

	cCtaPon := Mv_Par14
	cCtaLP  := Mv_Par15

	Ct211ValCt(cCtaLP,@cCtaPon,@cDigPon,@cCtaLP,@cDigLP,lPontes,@lCtaOk,@aCriter,@aCritPon,@aCritLP,lCadastro, .F. ,@cMsgErroPg)

	If !lCtaOk
		lPergOk := .F.

		If !Empty( cMsgErroPg )
			oSelf:SaveLog( cMsgErroPg )
		EndIf
	EndIf

    // Verifica se a Conta ponte está sendo apurada também
    If lPergOk .And. lPontes .And. !Empty(cCtaPon) .And.  ( cCtaPon >= cContaIni .And.  cCtaPon <= cContaFim )
    	Help("  ",1,"CT211PONTCT1",,STR0049 ,1,0) //"Conta ponte não pode estar no intervalo das contas apuradas"
    	lPergOk := .F.
		oSelf:SaveLog(STR0049)//"Conta ponte não pode estar no intervalo das contas apuradas"
    EndIf
    
    If lPergOk .And. !Empty(cCtaLP) .And.  ( cCtaLP >= cContaIni .And.  cCtaLP <= cContaFim )
    	Help("  ",1,"CT211APRCT1",,STR0050 ,1,0) //"Conta de Apuração não pode estar no intervalo das contas apuradas "
    	lPergOk := .F.
		oSelf:SaveLog(STR0050)//"Conta de Apuração não pode estar no intervalo das contas apuradas "
    EndIf

	If lCusto .and. lPergOk
		If Empty(mv_par17) 
			If _lBlind .OR. __lOKCusto
				lCCOk := .T.
			Else
				If MsgYesNo(STR0043+CRLF+STR0044,ALLTRIM(RetTitle("CTT_CUSTO"))+STR0045 ) //"Entidade em uso, porém não indicado codigo para apuração."#"Entidade não será considerada para os lançamentos. Continuar ?"#" de apuração vazio."
					lCCOk := .T.
					__lOKCusto := .T.
				Else
					lCCOk := .F.
				EnDif			
			EndIf
		Else
			cCCPon	:= mv_par16
			cCCLP	:= mv_par17		
			Ct211ValCC(cCCLP,@cCCPon,@cCCLP,lPontes,@lCCOk,lCadastro)											
		EndIf
		Iif(!lCCOk, lPergOk := .F., )
		
	
	    // Verifica se ao Centro de Custo ponte está sendo apurada também
	    If lPergOk .And. lPontes .And. !Empty(cCCPon) .And.  ( cCCPon >= cCustoIni .And.  cCCPon <= cCustoFim )
	    	Help("  ",1,"CT211PONTCTT",,STR0051 ,1,0) //"Centro Custo ponte não pode estar no intervalo dos centros de Custos apurados"
	    	lPergOk := .F.
			oSelf:SaveLog(STR0051)//"Centro Custo ponte não pode estar no intervalo dos centros de Custos apurados"
	    EndIf
	    
	    If lPergOk .And. !Empty(cCCLP) .And. ( cCCLP >= cCustoIni .And.  cCCLP <= cCustoFim )
	    	Help("  ",1,"CT211APRCTT",,STR0052 ,1,0) //"Centro Custo de Apuracao não pode estar no intervalo dos centros de Custos apurados "
	    	lPergOk := .F.
			oSelf:SaveLog(STR0052)//"Centro Custo de Apuracao não pode estar no intervalo dos centros de Custos apurados "
	    EndIf
	EndIf

	If lItem .and. lPergOk
	    If Empty(mv_par19)
			If _lBlind .OR. __lOKItem
				lItemOk := .T.
			Else
				If MsgYesNo(STR0043+CRLF+STR0044,ALLTRIM(RetTitle("CTD_ITEM"))+STR0045 ) //"Entidade em uso, porém não indicado codigo para apuração."#"Entidade não será considerada para os lançamentos. Continuar ?"#" de apuração vazio."
					lItemOk := .T.
					__lOKItem := .T.
				Else       
					lItemOk := .F.
				EnDif			
			EndIf
		Else
			cItemPon	:= mv_par18
			cItemLP		:= mv_par19
			Ct211ValIt(cItemLP,@cItemPon,@cItemLP,lPontes,@lItemOk,lCadastro)						
		Endif
		Iif(!lItemOk, lPergOk := .F., )
		

		// Verifica se o Item Contabil ponte está sendo apurada também
	    If lPergOk .And. lPontes .And.  !Empty(cItemPon) .And. ( cItemPon >= cItemIni .And.  cItemPon <= cItemFim )
	    	Help("  ",1,"CT211PONTCTD",,STR0053 ,1,0) //"Item Contábil Ponte não pode estar no intervalo dos itens contábeis apurados"
	    	lPergOk := .F.
			oSelf:SaveLog(STR0053)//"Item Contábil Ponte não pode estar no intervalo dos itens contábeis apurados"
	    EndIf
	    
	    If lPergOk .And. !Empty(cItemLP) .And.  ( cItemLP >= cItemIni .And.  cItemLP <= cItemFim )
	    	Help("  ",1,"CT211APRCTD",,STR0054 ,1,0) //"Item Contábil de Apuracao não pode estar no intervalo dos itens contábeis apurados "
	    	lPergOk := .F.
			oSelf:SaveLog(STR0054)//"Item Contábil de Apuracao não pode estar no intervalo dos itens contábeis apurados "
	    EndIf
		
	EndIf

	If lClvl .and. lPergOk
		If Empty(mv_par21)
			If _lBlind .OR. __lOKClasse
				lCLVLOk := .T.
			Else
				If MsgYesNo(STR0043+CRLF+STR0044,ALLTRIM(RetTitle("CTH_CLVL"))+STR0045 ) //"Entidade em uso, porém não indicado codigo para apuração."#"Entidade não será considerada para os lançamentos. Continuar ?"#" de apuração vazio."
					lCLVLOk := .T.
					__lOKClasse := .T.
				Else       
					lCLVLOk := .F.
				EnDif			
			EndIf
		Else
			cClVlPon	:= mv_par20
			cClVlLP		:= mv_par21 	
			Ct211ValCV(cClVlLP,@cClVlPon,@cClVlLP,lPontes,@lClVlOk,lCadastro) 
		EndIf
		Iif(!lCLVLOk, lPergOk := .F., ) 
		
	    If lPergOk .And. lPontes .And. !Empty(cClVlPon) .And.  ( cClVlPon >= cClVlIni .And.  cClVlPon <= cClVlFim )
	    	Help("  ",1,"CT211PONTCTH",,STR0055 ,1,0) //"Classe de Valor Ponte não pode estar no intervalo das classes de valor apuradas"
	    	lPergOk := .F.
			oSelf:SaveLog(STR0055)//"Classe de Valor Ponte não pode estar no intervalo das classes de valor apuradas"
	    EndIf
	    
	    If lPergOk .And. !Empty(cClVlLP) .And. ( cClVlLP >= cClVlIni .And.  cClVlLP <= cClVlFim )
	    	Help("  ",1,"CT211APRCTH",,STR0056 ,1,0) //"Classe de Valor de Apuracao não pode estar no intervalo das classes de valor apuradas "
	    	lPergOk := .F.
			oSelf:SaveLog(STR0056)//"Classe de Valor de Apuracao não pode estar no intervalo das classes de valor apuradas "
	    EndIf 
	    
	EndIf

EndIf

//Verifica se tem algum saldo basico desatualizado. Definido que essa verificacao so sera 
//feita em top connect, pois se fosse fazer em codebase iria degradar muito a performance
//do sistema. 
If !lSlBase .OR. !lReproc //So ira fazer a verificacao, caso o parametro MV_ATUSAL esteja com "N"
	For nx := nInicio to nFinal
		dLastProc := GetCv7Date(cTpSaldo,StrZero(nx,2))
		If dDataFLP > dLastProc
			lPergOk := .F.
			MsgAlert(OemToAnsi(STR0010)+"Saldo : "+ cTpSaldo+" Moeda : "+StrZero(nx,2))//"Ha saldos basicos desatualizados. Favor atualizar os saldos."	
			Exit
		EndIf
	Next
EndIf

//SE OS PARAMETROS NAO ESTIVEREM DEVIDAMENTE PREENCHIDOS               
If !lPergOk	
	Return
Endif		
////////////////////////////////////////////////////////////////////////////////////////

If lEntidad05
	// Asegurar que las tablas de saldos de entidad 05 estén creadas
	If FWAliasInDic("QL6") .And. FWAliasInDic("QL7")
		dbSelecTArea("QL6")
		dbSelecTArea("QL7")
		dbSelectArea("CT2")
	Else
		MsgInfo(STR0125,STR0014) //"Antes debe crear las tablas de saldos contables de la entidad 05 (QL6 y QL7) a través del configurador de Protheus."
		// Atualiza o log de processamento com o erro
		oSelf:SaveLog(STR0125)
		Return
	EndIf
EndIf

////////////////////////////////////////////////////////////////////////////////////////
/// CRIA ARQUIVO DE TRABALHO PARA GUARDAR OS SALDOS A SEREM ZERADOS
////////////////////////////////////////////////////////////////////////////////////////
aTpSaldos	:= {cTpSaldo}

// Inclui (_) antes do LP para que ao renomear nao seja enviado ao periferico LPT1 quando 
// o codigo da empresa inicia com T1. Caso encontrado pelo SQA
cArqTRB := "_LP" + cEmpAnt + StrTran(cFilAnt, " ", "") + Right( cExerc, 2) 

//criar semaforo para nao permitir outro usuario logado na mesma empresa filial possa executar a rotina
nCtdSemaf := 0
//inicia o semaforo
While !LockByName(cArqTRB+"_APUR",.T.,.T.,.T.) .And. nCtdSemaf <= 15
	nCtdSemaf++
	Sleep(1)
	If nCtdSemaf > 15
		Exit
	EndIf
EndDo

If nCtdSemaf > 15
	MsgAlert(STR0032+cArqTRB+GetDbExtension(),STR0033)//"Não foi possível excluir o arquivo: "//"Erro - Arquivo em uso ou travado."
	Return
EndIf

/// CRIACAO DE ARQUIVO TEMPORARIO.
If ! Ct211CrTrb(cArqTRB,lJaProc,lCriaTRB,@lNovoTRB)
	Return
EndIf

If Empty(cContaFim)
	cContaFim := Replicate("Z",nTamCta)
Endif

aAdd(aFilters,{"CT", cContaIni,cContaFim} ) //Da Conta | a Conta

If lCusto
	If Empty(cCustoIni).And. Empty(cCustoFim)
		lCusto := .F.
	ElseIf Empty(cCustoFim)
		cCustoFim := Replicate("Z",nTamCC)
	Endif
	aAdd(aFilters,{"CC", cCustoIni,cCustoFim} ) //Do C.Custo| ao C.Custo
EndIf
If lItem
	If Empty(cItemIni).And. Empty(cItemFim)
		lItem := .F.
	ElseIf Empty(cItemFim)
		cItemFim := Replicate("Z",nTamItem)
	Endif
	aAdd(aFilters,{"IT", cItemIni,cItemFim} ) //Do Item | ao Item
EndIf
If lClVL
	If Empty(cClVlIni).And. Empty(cClVlFim)
		lClVL := .F.
	ElseIf Empty(cClVlFim)
		cClVlFim := Replicate("Z",nTamClVl)
	Endif
	aAdd(aFilters,{"CL", cClVlIni,cClVlFim} ) //Da Classe | a Classe
EndIf

////////////////////////////////////////////////////////////////////
/// LE OS SALDOS DAS ENTIDADES E GUARDA NO ARQUIVO DE TRABALHO
////////////////////////////////////////////////////////////////////
If lNovoTRB

	If !lAuto
		/// VERIFICO OS SALDOS DA ENTIDADE 05 (QL7) GRAVANDO NO TRB.
		If lEntidad05
			If __lCtbLgAp 
				oSelf:SaveLog(STR0126) //"MENSAJE: OBTENIENDO SALDOS DE QL7"
			EndIf
			CTB211GTRB('QL7',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
			If __lCtbLgAp
				oSelf:SaveLog(STR0127) //"MENSAJE: FIN OBTENIENDO SALDOS DE QL7"
			EndIf
		EndIf
		/// VERIFICO OS SALDOS DA CLASSE DE VALOR (CQ7) GRAVANDO NO TRB.
		If lClvl
			If __lCtbLgAp  
				oSelf:SaveLog(STR0058) //"MENSAGEM: OBTENDO SALDOS DO CQ7"
			EndIf
			CTB211GTRB('CQ7',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
			If __lCtbLgAp
				oSelf:SaveLog(STR0060) //"MENSAGEM: FIM OBTENDO SALDOS CQ7"
			EndIF
		EndIf
		/// VERIFICO OS SALDOS DO ITEM CONTABIL (CQ5) GRAVANDO NO TRB.
		If lItem
			If __lCtbLgAp
				oSelf:SaveLog(STR0062) //"MENSAGEM: OBTENDO SALDOS DO CQ5"
			EndIf
			CTB211GTRB('CQ5',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
			If __lCtbLgAp 
				oSelf:SaveLog(STR0064) //"MENSAGEM: FIM OBTENDO SALDOS DO CQ5"
			EndIf
		EndIf
		/// VERIFICO OS SALDOS DO CENTRO DE CUSTO(CQ3) GRAVANDO NO TRB.
		If lCusto
			If __lCtbLgAp
				oSelf:SaveLog(STR0065) //"MENSAGEM: OBTENDO SALDOS DO CQ3"
			EndIf
			CTB211GTRB('CQ3',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
			If __lCtbLgAp
				oSelf:SaveLog(STR0067) //"MENSAGEM: FIM OBTENDO SALDOS DO CQ3"
			EndIf
		EndIf
	
		/// VERIFICO OS SALDOS DA CONTA.(CQ1) GRAVANDO NO TRB.
		If __lCtbLgAp
			oSelf:SaveLog(STR0069) //"MENSAGEM: OBTENDO SALDOS DO CQ1"
		EndIf
		CTB211GTRB('CQ1',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
		If __lCtbLgAp
			oSelf:SaveLog(STR0071) //"MENSAGEM: FIM OBTENDO SALDOS DO CQ1"
		EndIf
	Else
		/// VERIFICO OS SALDOS DA ENTIDADE 05 (QL7) GRAVANDO NO TRB.
		If lEntidad05
			CTB211GTRB('QL7',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
		EndIf
		/// VERIFICO OS SALDOS DA CLASSE DE VALOR (CQ7) GRAVANDO NO TRB.
		If lClvl
			CTB211GTRB('CQ7',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
		EndIf
		/// VERIFICO OS SALDOS DO ITEM CONTABIL (CQ5) GRAVANDO NO TRB.
		If lItem
			CTB211GTRB('CQ5',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
		EndIf
		/// VERIFICO OS SALDOS DO CENTRO DE CUSTO(CQ3) GRAVANDO NO TRB.
		If lCusto
			CTB211GTRB('CQ3',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
		EndIf
		/// VERIFICO OS SALDOS DA CONTA.(CQ1) GRAVANDO NO TRB.
		CTB211GTRB('CQ1',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoeda,oSelf,lAuto)
	Endif
	
EndIf

////////////////////////////////////////////////////////////////////////////////////////
/// LE O ARQUIVO DE TRABALHO E GRAVA OS LANÇAMENTOS DE APURACAO
////////////////////////////////////////////////////////////////////////////////////////
If !lAuto .and. __lCtbLgAp
	oSelf:SaveLog(STR0073) //"MENSAGEM: INICIANDO A LEITURA/GRAVAÇÃO DOS LANÇAMENTOS" 
Endif

dbSelectArea("TRB")
dbSetOrder(1)
dbGoTop()

If !lAuto
	If lObj
		oObj:SetRegua2(TRB->(RecCount()))			 				
	Else
		oSelf:SetRegua2(TRB->(RecCount()))
	EndIf 
Endif

nExecLin := 0

lFiltra := ValType(aFilters) == "A"

If lFiltra
	lFilCT := Len(aFilters) >= 1 .and. Len(aFilters[1]) >= 3 .and. (!Empty(aFilters[1][2]) .or. !Empty(aFilters[1][3]) )
	lFilCC := Len(aFilters) >= 2 .and. Len(aFilters[2]) >= 3 .and. (!Empty(aFilters[2][2]) .or. !Empty(aFilters[2][3]) )
	lFilIT := Len(aFilters) >= 3 .and. Len(aFilters[3]) >= 3 .and. (!Empty(aFilters[3][2]) .or. !Empty(aFilters[3][3]) )
	lFilCL := Len(aFilters) >= 4 .and. Len(aFilters[3]) >= 3 .and. (!Empty(aFilters[4][2]) .or. !Empty(aFilters[4][3]) )
EndIf


While TRB->(!Eof())  

	If lFilCT
		If TRB->CONTA < aFilters[1][2] .or. TRB->CONTA > aFilters[1][3]
			TRB->(dbSkip())
			Loop
		EndIf
	EndIf
	If lFilCC
		If TRB->CUSTO < aFilters[2][2] .or. TRB->CUSTO > aFilters[2][3]
			TRB->(dbSkip())
			Loop
		EndIf
	EndIf
	If lFilIT
		If TRB->ITEM < aFilters[3][2] .or. TRB->ITEM > aFilters[3][3]
			TRB->(dbSkip())
			Loop
		EndIf
	EndIf
	If lFilCL
		If TRB->CLVL < aFilters[4][2] .or. TRB->CLVL > aFilters[4][3]
			TRB->(dbSkip())
			Loop
		EndIf
	EndIf
	
	If !lAuto
		If lObj
			oObj:IncRegua2(OemToAnsi(STR0021+TRB->MOEDA+STR0022+TRB->TPSALDO))//"Passo 2 -> Gravando lançamentos Moeda "//" Saldo "
		Else
			oSelf:IncRegua2(OemToAnsi(STR0021+TRB->MOEDA+STR0022+TRB->TPSALDO))//"Passo 2 -> Gravando lançamentos Moeda "//" Saldo "
		EndIf
	Endif
	
	If lJaProc
		If TRB->JAPROC == "S"
			TRB->(dbSkip())
			Loop			
		EndIf
	EndIf
    
   	nSaldo := TRB->SALDOC - TRB->SALDOD
	
	nExecLin++
	If nExecLin == 1
		nSaldo := TRB->SALDOC
	ElseIf nExecLin == 2
		nSaldo := TRB->SALDOD * -1
	EndIf
    
    If nSaldo <> 0	    
		nLinha := DecodSoma1( cLinha )   // a funcao esta no fonte ctbxfuna.prx

		If lFirst .or. nLinha > nMAX_LINHA .or. TRB->TPSALDO <> cTpSldAnt .or. TRB->MOEDA <> cMoedAnt
			cMoedAnt	:= TRB->MOEDA
			cTpSldAnt	:= TRB->TPSALDO
		
			Do While ! ProxDoc(dDataFLP,cLote,cSubLote,cDoc,@CTF_LOCK)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso o N§ do Doc estourou, incrementa o lote         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cLote := CtbInc_Lot(cLote, "CTB", .T.) // True para forcar chave pelo modulo CTB

			Enddo
	
			If cPaisLoc == 'CHI' .and. Val(cLinha) < 2  // a partir da segunda linha do lanc., o correlativo eh o mesmo
				cSeqCorr := CTBSqCor( CTBSubToPad(cSubLote) )
			EndIf
	
			cDoc   := IIF(nLinha > nMAX_LINHA .And. !lFirst .And. TRB->MOEDA == cMoedAnt, Soma1(cDoc), cDoc) //Identifica se está na ultima linha do maximo, soma1 no numero de documento

			lFirst := .F.		
			cLinha := "001"
			nLinha := 1
			cSeqLan:= "001"			
			If cPaisLoc $ "BOL" // a partir da segunda linha do lanc., o correlativo eh o mesmo
				cSeqCorr := CTBSqCor( CTBSubToPad(cSubLote),,dDataFLP)
				CTBSQGrv(cSeqCorr, dDataFLP )
			EndIf	
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VALIDACAO DAS ENTIDADES PONTE E DE APURACAO - ENTIDADES PELO CAD.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCadastro
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SE UTILIZAR ENTIDADES DO CADASTRO ³
			//³SUBSTITUI VARIAVEIS DAS           ³
			//³- ENTIDADES PONTE                 ³
			//³- ENTIDADES DE APURACAO           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			lPergOk := .T.
			cCtaPon	:= cSpacCT
			cCtaLP	:= cSpacCT
			
			Ct211ValCt(TRB->CONTA,@cCtaPon,@cDigPon,@cCtaLP,@cDigLP,lPontes,@lCtaOk,@aCriter,@aCritPon,@aCritLP,lCadastro)  				
			
			If lPontes .And. (Empty(cCtaPon) .Or. Empty(cCtaLP))		
				lPergOk	:= .F.	
			ElseIf !lPontes .And. Empty(cCtaLP)	
				lPergOk	:= .F.		
			EndIf 
		
			cCCPon	:= cSpacCC
			cCCLP	:= cSpacCC
			If lPergOk .and. lCusto .and. !Empty(TRB->CUSTO)
				Ct211ValCC(TRB->CUSTO,@cCCPon,@cCCLP,lPontes,@lPergOk,lCadastro)											
			EndIf
		
			cItemPon	:= cSpacIT
			cItemLP		:= cSpacIT
			If lPergOk .and. lItem .and. !Empty(TRB->ITEM)
				Ct211ValIt(TRB->ITEM,@cItemPon,@cItemLP,lPontes,@lPergOk,lCadastro)						
			EndIf
		
			cClVlPon	:= cSpacCL
			cClVlLP		:= cSpacCL
			If lPergOk .and. lClvl .and. !Empty(TRB->CLVL)
				Ct211ValCV(TRB->CLVL,@cClVlPon,@cClVlLP,lPontes,@lPergOk,lCadastro) 
			EndIf
		
			/// SE HOUVER ALGUM PROBLEMA COM AS ENTIDADES PONTE/APURACAO DO CADASTRO
			If !lPergOk                                              	
				/// PASSA PARA O PROXIMO DO TRB SEM MARCAR COMO "JÁ PROCESSADO"
				/// AVALIAR CORREÇÃO NO CADASTRO E PROCESSAMENTO SÓ DOS PENDENTES PELO TRB
				TRB->(dbSkip())
				nExecLin := 0
				Loop
			EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se as entidades ponte/apuração estão Ok        ³
		//³                                               ³
		//³AVALIA SALDO OBTIDO PARA LANÇAMENTO DE APURACAO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		EndIf
		
		cTipo		:= "3"		
		
		If nSaldo > 0					/// SE O SALDO FOR A CREDITO / CREDOR
			If !lPontes
				cDebito		:= TRB->CONTA	/// LANCAMENTO A DEBITO NA CONTA ORIGEM (PARA ZERAR)
				cCustoDeb	:= TRB->CUSTO
				cItemDeb	:= TRB->ITEM
				cClVlDeb	:= TRB->CLVL
			Else
				cDebito		:= cCtaPon	/// LANCAMENTO A DEBITO NA CONTA PONTE (PARA NÃO ZERAR ORIGEM)
				If !Empty(TRB->CUSTO)
					cCustoDeb	:= cCCPon
				Else
					cCustoDeb	:= cSpacCC
				EnDif
				If !Empty(TRB->ITEM)
					cItemDeb	:= cItemPon
				Else
					cItemDeb	:= cSpacIT
				EndIf
				If !Empty(TRB->CLVL)
					cClVlDeb	:= cClVlPon
				Else
					cClVlDeb	:= cSpacCL
				EndIf
			EndIf
	
			cCredito	:= cCtaLP		/// LANCAMENTO A CREDITO NA CONTA DE APURACAO
			If !Empty(TRB->CUSTO)
				cCustoCrd	:= cCCLP
			Else
				cCustoCrd	:= cSpacCC
			EndIf
			If !Empty(TRB->ITEM)
				cItemCrd	:= cItemLP
			Else
				cItemCrd	:= cSpacIT
			EndIf
			If !Empty(TRB->CLVL)
				cClVlCrd	:= cClVlLP
			Else
				cClVlCrd	:= cSpacCL
			EndIf
	
			lCTZDeb := .T.	
		Else                        	/// SE O SALDO FOR A DEBITO / DEVEDOR
			cDebito		:= cCtaLP		/// LANCAMENTO A DEBITO NA CONTA DE APURACAO
			If !Empty(TRB->CUSTO)
				cCustoDeb	:= cCCLP
			Else
				cCustoDeb	:= cSpacCC
			EndIf
			If !Empty(TRB->ITEM)
				cItemDeb	:= cItemLP
			Else
				cItemDeb	:= cSpacIT
			EndIf
			If !Empty(TRB->CLVL)
				cClVlDeb	:= cClVlLP
			Else
				cClVlDeb	:= cSpacCL
			EndIf
			
			If !lPontes
				cCredito	:= TRB->CONTA	/// LANCAMENTO A CREDITO NA CONTA ORIGEM (PARA ZERAR)
				cCustoCrd	:= TRB->CUSTO
				cItemCrd	:= TRB->ITEM	
				cClVlCrd	:= TRB->CLVL
			Else
				cCredito	:= cCtaPon	/// LANCAMENTO A DEBITO NA CONTA PONTE (PARA NÃO ZERAR ORIGEM)
				If !Empty(TRB->CUSTO)
					cCustoCrd	:= cCCPon
				Else
					cCustoCrd	:= cSpacCC
				EndIf
				If !Empty(TRB->ITEM)
					cItemCrd	:= cItemPon
				Else
					cItemCrd	:= cSpacIT
				EndIf
				If !Empty(TRB->CLVL)
					cClVlCrd	:= cClVlPon
				Else
					cClVlCrd	:= cSpacCL			
				EndIf
			EndIf  
	
			lCTZDeb := .F.
		EndIf 
		
		//Grava lancamento na moeda 01
		nSaldo 		:= ABS(nSaldo)	
		nMoedAtu	:= VAL(TRB->MOEDA)

		If lEntidad05
			// Entidad 05 no usa código puente, el mismo aplica como débito / crédito
			cEnt05	:= TRB->ENT05
		EndIf

	    //////////////////////////////////////////////////////////////////////////////////////////
	    //////////////////////////////////////////////////////////////////////////////////////////
		If TRB->MOEDA == "01" 
			lApurMoeda1 := .T. 
			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0075) //"MENSAGEM: INICIANDO A GRAVAÇÃO DOS SALDOS (MOEDA 01)" 
			Endif
			
			aOutrEntid 	:= CtbOutrEnt(.F., "TRB")
			aEntid 		:= aOutrEntid[1]
			If lReproc
				//////////////////////////////////////////////////////////////////////////////////////////
				/// FUNCAO GRAVACTx AINDA ESTA GRAVANDO SALDO ANTERIOR INCORRETO QDO JÁ EXISTE LANC. NO DIA DE LP
				/// CHAMA A GRAVSALDO PARA ATUALIZAR OS ACUMULADOS CORRETAMENTE E 
				/// CHAMA REPROCESSAMENTO DO DIA DE APURACAO AO FINAL DO PROCESSAMENTO PARA ACERTAR SLD.ANTERIOR DO DIA.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	/// GRAVA SALDO RELATIVO AO LANÇAMENTO DE LUCROS E PERDAS (CTx_LP = 'Z')³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CtbGravSaldo(cLote,cSubLote,cDoc,dDataFLP,cTipo,"01",;
					cDebito,cCredito,;
					cCustoDeb,cCustoCrd,;
					cItemDeb,cItemCrd,;
					cClVlDeb,cClVlCrd,;
					nSaldo,TRB->TPSALDO,3,;
					cDebito,cCredito,;
					cCustoDeb,cCustoCrd,;
					cItemDeb,cItemCrd,;
					cClVlDeb,cClVlCrd,;			
					0,cTipo,TRB->TPSALDO,"01",;			
					lCusto,lItem,lClVL,;
					,.T.,.F.,dDataFLP,;
					lGrvCT7,lGrvCT3,lGrvCT4,lGrvCTI,;
					lAtuSldCT7,lAtuSldCT3,lAtuSldCT4,lAtuSldCTI,,"+"/*cOperacao*/, aEntid,;
					,cDescHP)
			EndIf 		
			
			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0077) //"MENSAGEM: FINALIZANDO A GRAVAÇÃO DOS SALDOS" 
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PREPARA VARIAVEIS PARA INCLUSAO/ALTERACAO DE LANCAMENTO NO CT2³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0079) //"MENSAGEM: INICIANDO A INCLUSAO/ALTERACAO DOS LANCAMENTOS NO CT2 (01)" 
			Endif
			
			nOpcGRV := 3
			If lPontes
				/// SE FOR APURACAO COM CONTA PONTE
				cLoteBak := cLote
				cSubBak	 := cSubLote
				cDocBak	 := cDoc
				cLinBak	 := cLinha
				cSeqLBak := cSeqLan
				
				nVlrCTZ := nSaldo
				
				If lEntidad05 
					If cKeyEntAtu <> '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEnt05
						cKeyDocLP := DTOS(dDataFLP)+cLote+cSubLote+cDoc
						If Len(__aDocsLP) <= 0 .or. Ascan(__aDocsLP, {|x| x[1] == cKeyDocLP }) <= 0
							aAdd(__aDocsLP, { cKeyDocLP , dDataFLP , cLote, cSubLote, cDoc } )
						EndIf
						/// VERIFICA DENTRO DOS LOTES/DOCS JÁ GERADOS NA APURACAO SE EXISTE LANCAMENTO IGUAL
						nRecLinha := Ct211Seek(__aDocsLP,'01',TRB->TPSALDO,;
								cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,cEnt05,cEnt05)
	
						nRecLanAtu := nRecLinha
						cKeyEntAtu := '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEnt05
					EndIf
				ElseIf cKeyEntAtu <> '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd
	
					cKeyDocLP := DTOS(dDataFLP)+cLote+cSubLote+cDoc			
					If Len(__aDocsLP) <= 0 .or. Ascan(__aDocsLP, {|x| x[1] == cKeyDocLP }) <= 0
						aAdd(__aDocsLP, { cKeyDocLP , dDataFLP , cLote, cSubLote, cDoc } )
					EndIf
					/// VERIFICA DENTRO DOS LOTES/DOCS JÁ GERADOS NA APURACAO SE EXISTE LANCAMENTO IGUAL
					nRecLinha := Ct211Seek(__aDocsLP,'01',TRB->TPSALDO,;
							cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd)
										   
					nRecLanAtu := nRecLinha
					cKeyEntAtu := '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd							
				
				Else		/// ENQUANTO FOR A MESMA CHAVE DE ENTIDADES NÃO PRECISA MODIFICAR LOTE, DOC, LINHA ETC.
					nRecLinha := nRecLanAtu				
				EndIf			
				
				If nRecLinha > 0
					/// SE JA EXISTE LANÇAMENTO IGUAL ALTERA A MESMA LINHA SOMANDO O VALOR.
					CT2->(dbGoTo(nRecLinha))
					nSaldo 		:= nSaldo + CT2->CT2_VALOR
					cLote		:= CT2->CT2_LOTE
					cSubLote	:= CT2->CT2_SBLOTE
					cDoc		:= CT2->CT2_DOC
					cLinha 		:= CT2->CT2_LINHA
					cSeqLan		:= CT2->CT2_SEQLAN
					nOpcGrv := 4
				EnDif	
			EndIf		
		
			cLinhaLan := cLinha ///SE HOUVER CONT. DE HISTORICO GRAVA CTZ NA LINHA DE LANÇAMENTO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVA LANCAMENTO DE APURACAO NO CT2³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCols := { { "01", " ", nSaldo, "2", .F., nSaldo } }

			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0081) //"MENSAGEM: GRAVAÇÃO DO LANÇAMENTO (01)" 
			Endif
			
			BEGIN TRANSACTION
			If cPaisLoc=="BOL"
				GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,;
						cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,;
						cClVlCrd,nSaldo,cDescHP,TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,;
						cEmpAnt,cFilAnt,,,,,,"CTBA211",;
						.F., , ,dDataFLP,@nRecLan,,,cSeqCorr)
			ElseIf lEntidad05
				GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
					cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nSaldo,cDescHP,;
					TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,,,,,,"CTBA211",.F., , ,dDataFLP,@nRecLan,,,,,,,,,aEntid)
			Else
				GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
					cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nSaldo,cDescHP,;
					TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,,,,,,"CTBA211",.F., , ,dDataFLP,@nRecLan)
			EndIf
		 	lGravouLan := .T.
		 	
		 	If !lAuto .and. __lCtbLgAp			
				oSelf:SaveLog(STR0083) //"MENSAGEM: FIM DA GRAVAÇÃO DO LANÇAMENTO (01)"
			Endif
			
			If lPontes		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SE UTILIZAR CONTA PONTE ATUALIZA TABELA CTZ COM AS CONTAS DE ORIGEM³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lAuto .and. __lCtbLgAp
					oSelf:SaveLog(STR0085) //"MENSAGEM: GRAVAÇÃO DO CTZ (01)" 
				Endif
				If lEntidad05
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,"01",TRB->TPSALDO,;
						Iif(lCTZDeb,"1","2"),nVlrCTZ,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL,cEnt05)
				Else
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,"01",TRB->TPSALDO,;
						Iif(lCTZDeb,"1","2"),nVlrCTZ,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL)
				EndIf

				If nOpcGrv == 4	/// SE FOI ALTERACAO DE LANCAMENTO, RESTAURA PROXIMO "ORIGINAL"
					cLote		:= cLoteBak
					cSubLote	:= cSubBak
					cDoc		:= cDocBak
					cLinha		:= cLinBak
					cSeqLan		:= cSeqLBak
				Else			/// SE FOI INCLUSAO, GUARDA O REC. ATUAL P/ ALT. SE O PROX. FOR MESMA CHAVE
					nRecLanAtu	:= nRecLan
					If lEntidad05
						cKeyEntAtu := '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEnt05
					Else
						cKeyEntAtu := '01'+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd
					EndIf
				EndIf
				
				If !lAuto .and. __lCtbLgAp
					oSelf:SaveLog(STR0087) //"MENSAGEM: FIM DA GRAVAÇÃO DO CTZ (01)"
				Endif
				 
			EndIf
			
			END TRANSACTION
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ATUALIZA FLAG DE LUCROS E PERDAS (CTx_LP e CTx_DTLP)³
			//³NOS REGISTROS DE SALDO NO PERIODO.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0089) //"MENSAGEM: GRAVAÇÃO DA FLGLP (01)"
				If lEntidad05
					Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA, cEnt05)
				Else
					Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA)
				EndIf
				oSelf:SaveLog(STR0091) //"MENSAGEM: FIM DA GRAVAÇÃO DA FLGLP (01)"
				oSelf:SaveLog(STR0093) //"MENSAGEM: FINALIZANDO A INCLUSAO/ALTERACAO DOS LANCAMENTOS NO CT2 (01)"
			Else
				If lEntidad05
					Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA, cEnt05)
				Else
					Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA)
				EndIf
			Endif
			
				//////////////////////////////////////////////////////////////////////////////////////////
		Else	/// Grava Lancamento na moeda 0X com valor zerado na moeda 01
				//////////////////////////////////////////////////////////////////////////////////////////
			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0095+" ("+TRB->MOEDA+")") //"MENSAGEM: INICIANDO A INCLUSAO/ALTERACAO DOS LANCAMENTOS NO CT2 ("+TRB->MOEDA+")" 
    		Endif
    		
			If val(TRB->MOEDA) > 2
				nForaCols	:= VAL(TRB->MOEDA)-2
			Else                
				nForaCols	:= 0
			EndIf		
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PREPARA VARIAVEIS PARA INCLUSAO/ALTERACAO DE LANCAMENTO NO CT2³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		    nOpcGRV := 3
			If lPontes
				/// SE FOR APURACAO COM CONTA PONTE
				cLoteBak := cLote
				cSubBak	 := cSubLote
				cDocBak	 := cDoc
				cLinBak	 := cLinha
				cSeqLBak := cSeqLan

				nVlrCTZ := nSaldo
				If lEntidad05 
					If cKeyEntAtu <> TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEnt05
						cKeyDocLP := DTOS(dDataFLP)+cLote+cSubLote+cDoc
						If Len(__aDocsLP) <= 0 .or. Ascan(__aDocsLP, {|x| x[1] == cKeyDocLP }) <= 0
							aAdd(__aDocsLP, { cKeyDocLP , dDataFLP , cLote, cSubLote, cDoc } )
						EndIf
						/// VERIFICA DENTRO DOS LOTES/DOCS JÁ GERADOS NA APURACAO SE EXISTE LANCAMENTO IGUAL
						nRecLinha := Ct211Seek(__aDocsLP,TRB->MOEDA,TRB->TPSALDO,;
								cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,cEnt05,cEnt05)
	
						nRecLanAtu := nRecLinha
						cKeyEntAtu := TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEnt05
					EndIf
				ElseIf cKeyEntAtu <> TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd
	
					cKeyDocLP := DTOS(dDataFLP)+cLote+cSubLote+cDoc			
					If Len(__aDocsLP) <= 0 .or. Ascan(__aDocsLP, {|x| x[1] == cKeyDocLP }) <= 0
						aAdd(__aDocsLP, { cKeyDocLP , dDataFLP , cLote, cSubLote, cDoc } )
					EndIf
					/// VERIFICA DENTRO DOS LOTES/DOCS JÁ GERADOS NA APURACAO SE EXISTE LANCAMENTO IGUAL
					nRecLinha := Ct211Seek(__aDocsLP,TRB->MOEDA,TRB->TPSALDO,;
							cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd)
										   
					nRecLanAtu := nRecLinha
					cKeyEntAtu := TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd							
				
				Else /// ENQUANTO FOR A MESMA CHAVE DE ENTIDADES NÃO PRECISA MODIFICAR LOTE, DOC, LINHA ETC.
					nRecLinha := nRecLanAtu				
				EndIf			
				
				If nRecLinha > 0
					/// SE JA EXISTE LANÇAMENTO IGUAL ALTERA A MESMA LINHA SOMANDO O VALOR.
					CT2->(dbGoTo(nRecLinha))
					nSaldo 		:= nSaldo + CT2->CT2_VALOR
					cLote		:= CT2->CT2_LOTE
					cSubLote	:= CT2->CT2_SBLOTE
					cDoc		:= CT2->CT2_DOC
					cLinha 		:= CT2->CT2_LINHA
					cSeqLan		:= CT2->CT2_SEQLAN
					nOpcGrv := 4
				EnDif	
			EndIf		
			
			cLinhaLan := cLinha ///SE HOUVER CONT. DE HISTORICO GRAVA CTZ NA LINHA DE LANÇAMENTO		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVA LANCAMENTO DE APURACAO - RELATIVO A MOEDA 01 COM VALOR ZERADO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			aCols := { { "01", " ", 0.00, "2", .F., 0 },{ TRB->MOEDA, "4", nSaldo, "2", .F., nSaldo } }
	        
			BEGIN TRANSACTION
	
			If nOpcGrv <> 4	/// NAO PRECISA ALTERAR SE O VALOR NA MOEDA 01 É ZERO
				If cPaisLoc=="BOL"
				
				
				GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
					  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
					  TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,0,,,,,"CTBA211",.F., , ,dDataFLP,,,,cSeqCorr)   
				
				Else
					/*caso nao tenha solicitação na moeda 01 dever ser gerado lançamento
					com valor 0 para que possa ser visualizado o lançamento de apuração*/
					If !lApurMoeda1 
						GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
							cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
							TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,0,,,,,"CTBA211",.F., , ,dDataFLP)
					Endif
				EndIf	  
			EndIf
	        
			/// FUNCAO GRAVACTx AINDA ESTA GRAVANDO SALDO ANTERIOR INCORRETO QDO JÁ EXISTE LANC. NO DIA DE LP
			/// CHAMA A GRAVSALDO PARA ATUALIZAR OS ACUMULADOS CORRETAMENTE E 
			/// CHAMA REPROCESSAMENTO DO DIA DE APURACAO AO FINAL DO PROCESSAMENTO PARA ACERTAR SLD.ANTERIOR DO DIA.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³	/// GRAVA SALDO RELATIVO AO LANÇAMENTO DE LUCROS E PERDAS (CTx_LP = 'Z')³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CtbGravSaldo(cLote,cSubLote,cDoc,dDataFLP,cTipo,TRB->MOEDA,;
				cDebito,cCredito,;
				cCustoDeb,cCustoCrd,;
				cItemDeb,cItemCrd,;
				cClVlDeb,cClVlCrd,;
				nSaldo,TRB->TPSALDO,3,;
				cDebito,cCredito,;
				cCustoDeb,cCustoCrd,;
				cItemDeb,cItemCrd,;
				cClVlDeb,cClVlCrd,;			
				0,cTipo,TRB->TPSALDO,TRB->MOEDA,;			
				lCusto,lItem,lClVL,;
				,.T.,.F.,dDataFLP,;
				lGrvCT7,lGrvCT3,lGrvCT4,lGrvCTI,;
				lAtuSldCT7,lAtuSldCT3,lAtuSldCT4,lAtuSldCTI,,"+"/*cOperacao*/, aEntid,;
				,cDescHP)
				  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³GRAVA LANCAMENTO DE APURACAO NO CT2³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLinha := cLinhaLan			/// GRAVA LANCAMENTO DA MOEDA 0X NA MESMA LINHA DA MOEDA 01
			If cPaisLoc=="BOL"
				GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,TRB->MOEDA,cHP,cDebito,cCredito,;
				  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
				  TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,nForaCols,,,,,"CTBA211",.F.,,,dDataFLP,@nRecLan,,,cSeqCorr)
			
			ElseIf lEntidad05
			GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,TRB->MOEDA,cHP,cDebito,cCredito,;
				  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
				  TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,nForaCols,,,,,"CTBA211",.F.,,,dDataFLP,@nRecLan,,,,,,,,,aEntid)
			Else
			GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,TRB->MOEDA,cHP,cDebito,cCredito,;
				  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
				  TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,nForaCols,,,,,"CTBA211",.F.,,,dDataFLP,@nRecLan)
			EndIf
			If lPontes
				If lEntidad05
					//Gravar zerado para a moeda 01 na CTZ para considerar na tabela 'LP' da CW0
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,"01",TRB->TPSALDO,;
						Iif(lCTZDeb,"1","2"),0,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL,cEnt05)
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³SE UTILIZAR CONTA PONTE ATUALIZA TABELA CTZ COM AS CONTAS DE ORIGEM³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,TRB->MOEDA,TRB->TPSALDO,;
						IIf(lCTZDeb,"1","2"),nVlrCTZ,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL,cEnt05)
	
					If nOpcGrv == 4	/// SE FOI ALTERACAO DE LANCAMENTO, RESTAURA PROXIMO "ORIGINAL"
						cLote		:= cLoteBak
						cSubLote	:= cSubBak
						cDoc		:= cDocBak
						cLinha		:= cLinBak
						cSeqLan		:= cSeqLBak
					Else			/// SE FOI INCLUSAO, GUARDA O REC. ATUAL P/ ALT. SE O PROX. FOR MESMA CHAVE
						nRecLanAtu	:= nRecLan
						cKeyEntAtu	:= TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd+cEnt05
					EndIf
				Else
					//Gravar zerado para a moeda 01 na CTZ para considerar na tabela 'LP' da CW0
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,"01",TRB->TPSALDO,;
						Iif(lCTZDeb,"1","2"),0,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³SE UTILIZAR CONTA PONTE ATUALIZA TABELA CTZ COM AS CONTAS DE ORIGEM³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinhaLan,TRB->MOEDA,TRB->TPSALDO,;
						IIf(lCTZDeb,"1","2"),nVlrCTZ,TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL)
					
					If nOpcGrv == 4	/// SE FOI ALTERACAO DE LANCAMENTO, RESTAURA PROXIMO "ORIGINAL"
						cLote		:= cLoteBak
						cSubLote	:= cSubBak
						cDoc		:= cDocBak
						cLinha		:= cLinBak
						cSeqLan		:= cSeqLBak
					Else			/// SE FOI INCLUSAO, GUARDA O REC. ATUAL P/ ALT. SE O PROX. FOR MESMA CHAVE
						nRecLanAtu	:= nRecLan
										cKeyEntAtu := TRB->MOEDA+TRB->TPSALDO+cDebito+cCredito+cCustoDeb+cCustoCrd+cItemDeb+cItemCrd+cClVlDeb+cClVlCrd							
					EndIf
				EndIf
			EndIf
	
			END TRANSACTION
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ATUALIZA FLAG DE LUCROS E PERDAS (CTx_LP e CTx_DTLP)³
			//³NOS REGISTROS DE SALDO NO PERIODO.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lEntidad05 
				Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA, cEnt05)
			Else
				Ct211FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA)
			EndIf

			If !lAuto .and. __lCtbLgAp
				oSelf:SaveLog(STR0097+" ("+TRB->MOEDA+")") //"MENSAGEM: FINALIZANDO A INCLUSAO/ALTERACAO DOS LANCAMENTOS NO CT2 ("+TRB->MOEDA+")" 
			Endif

			lGravouLan := .T.
		EndIf
	EndIf

	If nExecLin <= 0 .or. nExecLin >= 2	/// Se houve quebra em 2 linhas (pois Deb e Cred estavam iguais) vai manter na mesma conta.
		If !lAuto .and. __lCtbLgAp
			oSelf:SaveLog(STR0099) //"MENSAGEM: GRAVANDO FLAG DO PROCESSAMENTO" 
		Endif
		
		RecLock("TRB",.F.)
		Field->JAPROC := "S"
		TRB->(MsUnlock())
	 
		TRB->(dbSkip())
		nExecLin := 0

		If !lAuto .and. __lCtbLgAp
			oSelf:SaveLog(STR0101) //"MENSAGEM: FINALIZANDO A GRAVAÇÃO DO FLAG DO PROCESSAMENTO"
		Endif
		 
	EndIf		
EndDo

If !lAuto .and. __lCtbLgAp
	oSelf:SaveLog(STR0103) //"MENSAGEM: FINAL DA LEITURA/GRAVAÇÃO DOS LANÇAMENTOS"
Endif 

////////////////////////////////////////////////////////////////////////////////////////
//Atualiza tabela do SX5 com a data de apuracao, mesmo antes de reprocessar pois
//reprocessamento pode ser rodado posteriormente para ajuste dos saldos
//observação, tem influencia no retorno da data de lucros e perdas anterior
//(para o intervalo de datas na marcação dos flags _LP no reprocessamento).

If lGravouLan
	Ct211AtSx5(dDataFLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSaldo,lPontes)
Endif

//termina o semaforo 
UnLockByName(cArqTRB+"_APUR",.T.,.T.,.T.)

If lGravouLan
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ATUALIZA OS SALDOS COM DATA POSTERIOR AO L/P -REPROCESSAMENTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Verifico qual a data final a ser passada para o Reprocessamento.
	/// MANTIDA DATA DA APURACAO PARA NÃO REPROCESSAR PERIODOS POSTERIORES
	//Ct211MaxDt(dDataFLP,@dDataFRep,cContaIni,cContaFim, cCustoIni, cCustoFim, cItemIni, cItemFim, cClVlIni, cClVlFim)
	
	//Caso exista algum ponto de entrada, o reprocessamento sera rodado a partir da data de apuracao para 
	//atualizar os saldos de todas as tabelas
	If lCtbCCLP .Or. lCtbItLP .Or. lCtbCVLP
		dDataIRep	:= dDataFLP
		If Empty(dDataFRep)
			dDataFRep	:= dDataIRep
		EndIf
	EndIf
	
	//Chamo o Reprocessamento, se tiver saldos com data posterior ao zeramento.
	//Somente atualizo os saldos basicos
	If lReproc .AND. (!Empty(dDataFRep) .Or. (lCtbCCLP .Or. lCtbItLP .Or. lCtbCVLP))
		If !lAuto .and. __lCtbLgAp
			oSelf:SaveLog(STR0105) //"MENSAGEM: REPROCESSANDO OS SALDOS" 
			CTBA190(.T.,dDataILP,dDataFRep,cFilAnt,cFilAnt,cTpSaldo,lMoedaEsp,cMoeda) 
			oSelf:SaveLog(STR0107) //"MENSAGEM: FINALIZANDO O REPROCESSANDO OS SALDOS"
		Else
			CTBA190(.T.,dDataILP,dDataFRep,cFilAnt,cFilAnt,cTpSaldo,lMoedaEsp,cMoeda)
		Endif
	EndIf
EndIf

If !lAuto .and. __lCtbLgAp
	oSelf:SaveLog(STR0109) //"MENSAGEM: APAGANDO O ARQUIVO DE TRABALHO"
Endif
 
///	APAGA O ARQUIVO DE TRABALHO
dbSelectArea("TRB")
dbCloseArea()

//Apaga tabela temporaria do banco de dados
If  _oCTBA2111<> Nil
	_oCTBA2111:Delete()
	_oCTBA2111 := Nil
Endif

If !lAuto .and. __lCtbLgAp
	oSelf:SaveLog(STR0111) //"MENSAGEM: FINALIZANDO - APAGANDO O ARQUIVO DE TRABALHO" 
Endif

If __lMetric
	CTB211Metrics("01" /*cEvent*/, nStart, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/)
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct211CrTrb³ Autor ³ Marcos S. Lobo        ³ Data ³ 26.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria arquivo de trabalho									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct211CrTrb()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct211CrTrb()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct211CrTrb(cNomeArq,lJaProc,lCriaTRB,lNovoTRB)

Local cTrb		:= ""
Local aCampos	:=  {}
Local aTamVlr	:= {}

Local cTitMsg 	:= ""
Local cMsg	  	:= ""

Local cCpoDeb 	:= ""
Local cCpoCrd 	:= ""
Local nInc		:= 0
Local nQtdEntid	:= Iif(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor

If lEntidad05
	aAdd(aTamVlr, GetSx3Cache("CQ1_DEBITO","X3_TAMANHO"))
	aAdd(aTamVlr, GetSx3Cache("CQ1_DEBITO","X3_DECIMAL"))
Else
	aTamVlr := TamSX3("CQ1_DEBITO")
EndIf
aCampos := {{"IDENT"	,"C",3			,0},;
 		    {"CONTA" 	,"C",nTamCta	,0},;
 		    {"CUSTO" 	,"C",nTamCC		,0},;
 			{"ITEM"  	,"C",nTamItem	,0},;
 			{"CLVL" 	,"C",nTamClvl	,0},;
   			{"SALDOD"	,"N",aTamVlr[1]+2,aTamVlr[2]},;
   			{"SALDOC"	,"N",aTamVlr[1]+2,aTamVlr[2]},;
   			{"TPSALDO"	,"C",1			,0},;
			{"MOEDA"	,"C",2			,0},;
			{"JAPROC"	,"C",1			,0}}

If lEntidad05
	aAdd(aCampos, {"ENT05" 	,"C",nTamE05	,0})
EndIf

// Inclui as novas entidades
For nInc := 1 To ( nQtdEntid - 4 )
    cCpoDeb := CtbCposCrDb("", "D", StrZero(nInc + 4,2)) 
	cCpoCrd := CtbCposCrDb("", "C", StrZero(nInc + 4,2))  

	aAdd( aCampos, { cCpoDeb, "C", 200, 0 } )
	aAdd( aCampos, { cCpoCrd, "C", 200, 0 } )
Next

If Empty(cArqTRB)
	cArqTRB := cNomeArq
EndIf
				
If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
Endif

If lCriaTRB
	If _oCTBA2111 <> Nil	  // Se tabela temporaria de saldos finais já existir
	
		cTitMsg := STR0023//"Arquivo de saldos finais já existe."
		cMsg	:= STR0024+_oCTBA2111:GetRealName()+CHR(13)+CHR(10)         ///"Arquivo encontrado: "
		cMsg	+= STR0025//"Carregar novamente saldos ? "

		nRetMsg := Aviso(cTitMsg,cMsg, { STR0026,STR0027,STR0028 } )//"Sim"//"Não"//"Sair"

		If nRetMsg == 1
			/// CASO A TRANSFERÊNCIA DE LANCAMENTOS JÁ TENHA SIDO INICIADA
			If lJaProc .and. !MsgNoYes(STR0029+chr(13)+chr(10)+STR0030,STR0031)//"Recalcular os saldos pode afetar os valores de apuracao, caso já existam lançamentos de apuracao."//"Deseja Realmente continuar ?"//"A T E N C Ä O !!!"
				Return .F.
			EndIf
			
			_oCTBA2111:Delete()
			_oCTBA2111 := Nil
				
			lNovoTRB := .T.					/// UTILIZA O ARQUIVO DE SALDOS JÁ CALCULADO (RECOMENDADO SE NÃO TRANSFERIU LANCAMENTOS)
		ElseIf nRetMsg == 2	
			lNovoTRB := .F.
		Else 
			Return .F.
		EndIf
	EndIf
Else	
    If _oCTBA2111 == Nil 
        
		cMsg := STR0034+cArqTRB+GetDbExtension()+STR0035+CHR(13)+CHR(10)+STR0036//"Arquivo de Saldos "//" não encontrado ! "//"Recalcular saldos e continuar ?"
		
		If lJaProc
			cMsg += CHR(13)+CHR(10)+STR0037//"(Recalcular os saldos finais podera afetar o valor de apuracao se já foram movidos lançamentos)."
		EndIf

		nRetMsg := Aviso(STR0031,cMsg, { STR0026,STR0027 } )//"Atenção!!!"//"Sim"//"Não"
		
		If nRetMsg == 1
			lNovoTRB := .T.
		Else
			Return .F.
		EndIf
	Else
		lNovoTRB := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ11ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Crio arq. de trab. p/ gravar as inconsistencias.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                        
If lNovoTRB
		
	If _oCTBA2111 <> Nil
		_oCTBA2111:Delete()
		_oCTBA2111 := Nil
	Endif

	_oCTBA2111 := FWTemporaryTable():New( "TRB" )
	_oCTBA2111:SetFields(aCampos)

	If !lEntidad05
		_oCTBA2111:AddIndex("1", {"TPSALDO","MOEDA","CONTA","CUSTO","ITEM","CLVL","IDENT"})
		_oCTBA2111:AddIndex("2", {"TPSALDO","MOEDA","IDENT","CONTA","CUSTO","ITEM","CLVL"})
	Else
		_oCTBA2111:AddIndex("1", {"TPSALDO","MOEDA","CONTA","CUSTO","ITEM","CLVL","ENT05","IDENT"})
		_oCTBA2111:AddIndex("2", {"TPSALDO","MOEDA","IDENT","CONTA","CUSTO","ITEM","CLVL","ENT05"})
	EndIf

	//------------------
	//Criação da tabela temporaria
	//------------------
	_oCTBA2111:Create()  
	
EndIf

dbSelectArea( "TRB" )
dbSetOrder(1)	

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTB211GTRB³ Autor ³ Marcos S. Lobo        ³ Data ³ 26.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifico os Saldos e Grava no Arquivo de Trabalho			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB211GTRB()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA211                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION CTB211GTRB(cAlias,dDataILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lSaldo,lMoedaEsp,cMoedaEsp,oSelf,lAuto)

Local lObj := ValType(oObj) == "O"

Local nRecno	:=	0
Local nTotRegua	:= ((cAlias)->(Reccount()))
Local cConta 	:= SPACE(nTamCta)
Local cCusto 	:= SPACE(nTamCC)
Local cItem  	:= SPACE(nTamItem)
Local cClVl		:= SPACE(nTamClVl)

Local nMoedAtu	:= 1
Local cMoedAtu	:= "01"
Local nTpSldAtu	:= 1
Local cTpSldAtu	:= "1"

Local aSldAnt	:= {}
Local aSldAtu	:= {}
Local nDebTrb	:= 0 
Local nCrdTrb	:= 0
Local nTrbSlD	:= 0
Local nTrbSlC	:= 0
Local cKeyAtu	:= ""

Local lFiltra	:= ValType(aFilters) == "A"
Local lFilCT	:= .F.
Local lFilCC	:= .F.
Local lFilIT	:= .F.
Local lFilCL	:= .F.
Local lVai		:= .F.
Local lApZero	:= GetNewPar( "MV_CTAPMVZ" , .T. )
Local cEnt05	:= IIF(lEntidad05, cSpacE05, "")

DEFAULT lSaldo  := .F.			/// PADRAO .F. OBTEM MOVIMENTO / .T. OBTEM SALDO
DEFAULT dDataILP:= CTOD("01/01/80")-1

If lFiltra
	lFilCT := Len(aFilters) >= 1 .and. Len(aFilters[1]) >= 3 .and. (!Empty(aFilters[1][2]) .or. !Empty(aFilters[1][3]) )
	lFilCC := Len(aFilters) >= 2 .and. Len(aFilters[2]) >= 3 .and. (!Empty(aFilters[2][2]) .or. !Empty(aFilters[2][3]) )
	lFilIT := Len(aFilters) >= 3 .and. Len(aFilters[3]) >= 3 .and. (!Empty(aFilters[3][2]) .or. !Empty(aFilters[3][3]) )
	lFilCL := Len(aFilters) >= 4 .and. Len(aFilters[3]) >= 3 .and. (!Empty(aFilters[4][2]) .or. !Empty(aFilters[4][3]) )
EndIf

dbSelectArea(cAlias)
If cAlias $ "CQ0/CQ1"
	dbSetOrder(2)
Else
	dbSetOrder(3)
Endif
cFilAlias := xFilial(cAlias)



If !lMoedaEsp
	//// FAZ O PROCESSAMENTO PARA TODAS AS MOEDAS
	nMoedaIni := 1
Else
	/// SE FOR MOEDA ESPECÍFICA INICIA PELA MOEDA INDICADA
	nMoedaIni := Val(cMoedaEsp)
EndIf

For nMoedAtu := nMoedaIni to __nQuantas
	cMoedAtu := STRZERO(nMoedAtu,2)

	//// FAZ O PROCESSAMENTO PARA TODOS OS TIPOS DE SALDOS
	For nTpSldAtu := 1 to Len(aTpSaldos)
		// cTpSldAtu := STRZERO(nTpSldAtu,1)
		//
		cTpSldAtu := aTpSaldos[nTpSldAtu]
		
		If !lAuto
			If lObj
				oObj:SetRegua2(nTotRegua)			 				
			Else
				oSelf:SetRegua1(nTotRegua)	
			EndIf
		Endif
		
		If lFilCT
			MsSeek(cFilAlias+aFilters[1][2],.T.) //Procuro pela primeira conta a ser zerada
		Else
			MsSeek(cFilAlias,.T.) //Procuro pela primeira conta a ser zerada		
		EndIf
		
		While (cAlias)->(!Eof()) .And. (cAlias)->&(cAlias+"_FILIAL") == cFilAlias .and. (If(lFilCT,(cAlias)->&(cAlias+"_CONTA") <= aFilters[1][3],.T.))
		
			If !lAuto
				If lObj
					oObj:IncRegua2(OemToAnsi(STR0019+cMoedAtu+STR0020+cTpSldAtu))//#"Passo 1 -> Obtendo Saldos... Moeda "//" Saldo " 
				Else
					oSelf:IncRegua1(OemToAnsi(STR0019+cMoedAtu+STR0020+cTpSldAtu))//#"Passo 1 -> Obtendo Saldos... Moeda "//" Saldo " 
				EndIf
			Endif
					
			If cAlias == 'CQ7'			
				cChave := CQ7->(CQ7_CONTA+CQ7_CCUSTO+CQ7_ITEM+CQ7_CLVL)
				cConta := CQ7->CQ7_CONTA
				cCusto := CQ7->CQ7_CCUSTO
				cItem  := CQ7->CQ7_ITEM
				cClVl  := CQ7->CQ7_CLVL
			ElseIf cAlias == 'CQ5'
				cChave := CQ5->(CQ5_CONTA+CQ5_CCUSTO+CQ5_ITEM)
				cConta := CQ5->CQ5_CONTA
				cCusto := CQ5->CQ5_CCUSTO
				cItem  := CQ5->CQ5_ITEM
			ElseIf cAlias == 'CQ3'       
				cChave := CQ3->(CQ3_CONTA+CQ3_CCUSTO)
				cConta := CQ3->CQ3_CONTA
				cCusto := CQ3->CQ3_CCUSTO
			ElseIf cAlias == 'CQ1'
				cChave := CQ1->CQ1_CONTA
				cConta := CQ1->CQ1_CONTA
			ElseIf lEntidad05 .And. cAlias == 'QL7'
				cChave := QL7->(QL7_CONTA+QL7_CCUSTO+QL7_ITEM+QL7_CLVL+QL7_ENT05)
				cConta := QL7->QL7_CONTA
				cCusto := QL7->QL7_CCUSTO
				cItem  := QL7->QL7_ITEM
				cClVl  := QL7->QL7_CLVL
				cEnt05 := QL7->QL7_ENT05
			EndIf

			cNxtChav:= IncLast(cChave)		/// DETERMINA A PROXIMA CHAVE DE PESQUISA COM O CODIGO DAS ENTIDADES
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Avalia filtro das entidades para apuracao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lEntidad05 .And. cAlias == 'QL7'
				If lFilCT
					If QL7->QL7_CONTA < aFilters[1][2] .or. QL7->QL7_CONTA > aFilters[1][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilCC
					If QL7->QL7_CCUSTO < aFilters[2][2] .or. QL7->QL7_CCUSTO > aFilters[2][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilIT
					If QL7->QL7_ITEM < aFilters[3][2] .or. QL7->QL7_ITEM > aFilters[3][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf
				If lFilCL
					If QL7->QL7_CLVL < aFilters[4][2] .or. QL7->QL7_CLVL > aFilters[4][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
						Loop
					EndIf
				EndIf

			ElseIf cAlias == 'CQ7'
				If lFilCT
					If CQ7->CQ7_CONTA < aFilters[1][2] .or. CQ7->CQ7_CONTA > aFilters[1][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))		
						Loop
					EndIf
				EndIf
				If lFilCC
					If CQ7->CQ7_CCUSTO < aFilters[2][2] .or. CQ7->CQ7_CCUSTO > aFilters[2][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))		
						Loop
					EndIf
				EndIf
				If lFilIT
					If CQ7->CQ7_ITEM < aFilters[3][2] .or. CQ7->CQ7_ITEM > aFilters[3][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))		
						Loop
					EndIf
				EndIf
				If lFilCL
					If CQ7->CQ7_CLVL < aFilters[4][2] .or. CQ7->CQ7_CLVL > aFilters[4][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))		
						Loop
					EndIf
				EndIf
				
			ElseIf cAlias == 'CQ5'
				If lFilCT
					If CQ5->CQ5_CONTA < aFilters[1][2] .or. CQ5->CQ5_CONTA > aFilters[1][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))		
						Loop
					EndIf
				EndIf
				If lFilCC
					If CQ5->CQ5_CCUSTO < aFilters[2][2] .or. CQ5->CQ5_CCUSTO > aFilters[2][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))		
						Loop
					EndIf
				EndIf
				If lFilIT
					If CQ5->CQ5_ITEM < aFilters[3][2] .or. CQ5->CQ5_ITEM > aFilters[3][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))		
						Loop
					EndIf
				EndIf

			ElseIf cAlias == 'CQ3'
				If lFilCT
					If CQ3->CQ3_CONTA < aFilters[1][2] .or. CQ3->CQ3_CONTA > aFilters[1][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))		
						Loop
					EndIf
				EndIf
				If lFilCC
					If CQ3->CQ3_CCUSTO < aFilters[2][2] .or. CQ3->CQ3_CCUSTO > aFilters[2][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))		
						Loop
					EndIf
				EndIf

			ElseIf cAlias == 'CQ1'
				If lFilCT
					If CQ1->CQ1_CONTA < aFilters[1][2] .or. CQ1->CQ1_CONTA > aFilters[1][3]
						dbSelectArea(cAlias)
						(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))		
						Loop
					EndIf
				EndIf

			EndIf			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄTâ
			//³Apos filtragem , obtem saldos ate a data.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄTâ
			If cAlias == 'CQ7'
				If !lSaldo
					aSldAnt	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)	
				EndIf
				aSldAtu	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)	
			ElseIf cAlias == 'CQ5'
				If !lSaldo
					aSldAnt	:= SaldoCT4(cConta,cCusto,cItem,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)	
				EndIf
				aSldAtu	:= SaldoCT4(cConta,cCusto,cItem,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)	
			ElseIf cAlias == 'CQ3'
				If !lSaldo
					aSldAnt	:= SaldoCT3(cConta,cCusto,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)		
				EndIf
				aSldAtu	:= SaldoCT3(cConta,cCusto,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)		
			ElseIf cAlias == 'CQ1'
				If !lSaldo
					aSldAnt	:= SaldoCT7(cConta,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)		
				EndIf
				aSldAtu	:= SaldoCT7(cConta,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)
			ElseIf lEntidad05 .And. cAlias == 'QL7'
				If !lSaldo
					aSldAnt := SaldoCQ("CV0",cConta,cCusto,cItem,cClVL,/*cIdent*/,dDataILP,cMoedAtu,cTpSldAtu,"CTBXFUN",.F.,/*dDataLP*/,/*cFilEsp*/,/*lUltDtVl*/,cEnt05)
				EndIf
				aSldAtu := SaldoCQ("CV0",cConta,cCusto,cItem,cClVL,/*cIdent*/,dDataFLP,cMoedAtu,cTpSldAtu,"CTBXFUN",.F.,/*dDataLP*/,/*cFilEsp*/,/*lUltDtVl*/,cEnt05)
			EndIf

			nTrbSlD := 0
			nTrbSlC := 0
			dbSelectArea("TRB")
			dbSetOrder(2)

			lVai := .F.
			If lSaldo								/// SE FOR APURACAO PELO SALDO
				If aSldAtu[1] <> 0 					/// SE HOUVER SALDO
					lVai := .T.
				EndIf
			Else
				If ( aSldAtu[4] - aSldAnt[4]) <> 0 .or. (aSldAtu[5] - aSldAnt[5] <> 0  )     /// SE HOUVER MOVIMENTO
					IF !lApZero 
						lVai := ( (( aSldAtu[4] - aSldAnt[4]) - (aSldAtu[5] - aSldAnt[5] ) ) <> 0 )
					Else
					    lVai := .T.
					Endif
				EndIf
			EndIf

			If lVai
				If lEntidad05 .And. cAlias == "CQ7"
					cKeyAtu := cTpSldAtu+cMoedAtu+"QL7"+cConta+cCusto+cItem+cClVL
					If dbSeek(cKeyAtu,.F.)
						While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO+ITEM+CLVL)
							nTrbSlD += TRB->SALDOD
							nTrbSlC += TRB->SALDOC
							TRB->(dbSkip())
						EndDo
					EndIf
				ElseIf cAlias == "CQ5" //.or. (cAlias == "CT3" .and. !lItem)
					If lClvl
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ7"+cConta+cCusto+cItem
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO+ITEM)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf
					If lEntidad05
						cKeyAtu := cTpSldAtu+cMoedAtu+"QL7"+cConta+cCusto+cItem
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO+ITEM)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf
				ElseIf cAlias == "CQ3" //.or. (cAlias == "CT7" .and. !lCusto)
					If lItem
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ5"+cConta+cCusto
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf

					/// SE NÃO LOCALIZOU CHAVE NO CT4 VERIFICA SE HÁ NO CTI
					If lClvl
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ7"+cConta+cCusto
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf

					If lEntidad05
						cKeyAtu := cTpSldAtu+cMoedAtu+"QL7"+cConta+cCusto
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA+CUSTO)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf
				ElseIf cAlias == "CQ1"				
					If lCusto
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ3"+cConta
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo					
						EndIf
					EndIf
					/// SE NÃO LOCALIZOU CHAVE NO CT3 VERIFICA SE HÁ NO CT4
					If lItem
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ5"+cConta
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo					
						EndIf
					EndIf
					
					/// SE NÃO LOCALIZOU CHAVE NO CT4 VERIFICA SE HÁ NO CTI
					If lClvl
						cKeyAtu := cTpSldAtu+cMoedAtu+"CQ7"+cConta
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf

					If lEntidad05
						cKeyAtu := cTpSldAtu+cMoedAtu+"QL7"+cConta
						If dbSeek(cKeyAtu,.F.)
							While TRB->(!Eof()) .and. cKeyAtu == TRB->(TPSALDO+MOEDA+IDENT+CONTA)
								nTrbSlD += TRB->SALDOD
								nTrbSlC += TRB->SALDOC
								TRB->(dbSkip())
							EndDo
						EndIf
					EndIf
				EndIf

				/// CALCULA OS VALORES A DEBITO E A CREDITO PARA LANCAMENTO
				/// ABATENDO OS VALORES JÁ LANÇADOS COM OUTRAS ENTIDADES
				If lSaldo
					nDebTrb := ABS(aSldAtu[4]) - nTrbSlD
					nCrdTrb := ABS(aSldAtu[5]) - nTrbSlC
				Else
					nDebTrb := (ABS(aSldAtu[4]) - ABS(aSldAnt[4])) - nTrbSlD
					nCrdTrb := (ABS(aSldAtu[5]) - ABS(aSldAnt[5])) - nTrbSlC				
				EndIf

				dbSelectArea("TRB")
				dbSetOrder(1)
				If lEntidad05 
					If (nDebTrb <> 0 .or. nCrdTrb <> 0) .and. !dbSeek(cTpSldAtu+cMoedAtu+cConta+cCusto+cItem+cClvl+cEnt05+cAlias,.F.)
						dbSetOrder(2)
						RecLock("TRB",.T.)
						Field->TPSALDO	:= cTpSldAtu
						Field->MOEDA	:= cMoedAtu
						Field->CONTA	:= cConta
						Field->CUSTO	:= cCusto
						Field->ITEM		:= cItem
						Field->CLVL		:= cClVL
						Field->IDENT	:= cAlias
						Field->SALDOD	:= ABS(nDebTrb)
						Field->SALDOC	:= ABS(nCrdTrb)
						Field->ENT05 := cEnt05
						Field->CT2_EC05DB := cEnt05
						Field->CT2_EC05CR := cEnt05
						TRB->(MsUnlock())
					EndIf
				ElseIf (nDebTrb <> 0 .or. nCrdTrb <> 0) .and. !dbSeek(cTpSldAtu+cMoedAtu+cConta+cCusto+cItem+cClvl+cAlias,.F.)
					dbSetOrder(2)
					RecLock("TRB",.T.)
					Field->TPSALDO	:= cTpSldAtu
					Field->MOEDA	:= cMoedAtu
					Field->CONTA	:= cConta
					Field->CUSTO	:= cCusto
					Field->ITEM		:= cItem
					Field->CLVL		:= cClVL
					Field->IDENT	:= cAlias
					Field->SALDOD	:= ABS(nDebTrb)
					Field->SALDOC	:= ABS(nCrdTrb)
					TRB->(MsUnlock())
				EndIf
			EndIf

			dbSelectArea(cAlias)
			(cAlias)->(MsSeek(cFilAlias+cNxtChav,.T.))
		EndDo
	Next nTpSldAtu
	If lMoedaEsp		/// SE FOR MOEDA ESPECÍFICA ENCERRA AO FINAL DA 1ª PASSAGEM (FOR NEXT)
		nMoedAtu := __nQuantas
		Exit
	Endif
Next nMoedAtu

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct211ValIt³ Autor ³ Simone Mie Sato       ³ Data ³ 22.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o item ponte e item L/P estao preenchidos.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct211ValIt()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ct211ValIt()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct211ValIt(cItem,cItemPon,cItemLp,lPontes,lItemOk,lCadastro)  

Local aSaveArea	:= GetArea()

dbSelectArea("CTD")
dbSetOrder(1)
If lCadastro	//Se utiliza item ponte/LP do Cadastro de Item.
	MsSeek(xFilial("CTD")+cItem)
	If Found()
		If	lPontes .And. Empty(CTD->CTD_ITPON)
			lItemOk 	:= .F.
		ElseIf Empty(CTD->CTD_ITLP)
			lItemOk 	:= .T.
			cItemPon	:= CTD->CTD_ITPON
			cItemLP		:= cItem
		Else
			lItemOk 	:= .T.
			cItemPon	:= CTD->CTD_ITPON
			cItemLP		:= CTD->CTD_ITLP
		Endif		
	Endif
Else
	If lPontes
		If Subs(CTD->CTD_ITPON,1,1) = "*"
			lItemOk	:= .F.
		EndIf
		MsSeek(xFilial("CTD")+cItemPon)	
	Else
		If Subs(CTD->CTD_ITLP,1,1) = "*"
			lItemOk	:= .F.    
		EndIf	
		MsSeek(xFilial("CTD")+cItemLP)			
	EndIf

	If lItemOk .And. !Found() 
		lItemOk		:= .F.    
	EndIf	
EndIf

RestArea(aSaveArea)

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct211ValCC³ Autor ³ Simone Mie Sato       ³ Data ³ 02.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o C.C. ponte e C.C. L/P estao preenchidos.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct211ValCC()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ct211ValCC()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct211ValCC(cCusto,cCCPon,cCCLp,lPontes,lCCOk,lCadastro)  

Local aSaveArea	:= GetArea()

dbSelectArea("CTT")
dbSetOrder(1)
If lCadastro//Se utiliza c.cust Ponte/LP do Cadastro de Centro de Custo
	MsSeek(xFilial("CTT")+cCusto)
	If Found()
		If lPontes .And. Empty(CTT->CTT_CCPON)
			lCCOk 		:= .F.
		ElseIf Empty(CTT->CTT_CCLP)
			lCCOk		:= .T.
			cCCPon 		:= CTT->CTT_CCPON
			cCCLP		:= cCusto		
		Else
			lCCOk		:= .T.
			cCCPon 		:= CTT->CTT_CCPON
			cCCLP		:= CTT->CTT_CCLP
		Endif
	Endif
Else
	If lPontes
		If Subs(CTT->CTT_CCPON,1,1) = "*"
			lCCOk		:= .F.
		EndIf
		MsSeek(xFilial("CTT")+cCCPon)
	Else
		If Subs(CTT->CTT_CCLP,1,1) = "*"
			lCCOk		:= .F.
		EndIf
		MsSeek(xFilial("CTT")+cCCLP)
	EndIf
	If lCCOk .And. !Found()
		lCCOk	:= .F.        
	EndIf
EndIf

RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct211ValCV³ Autor ³ Simone Mie Sato       ³ Data ³ 02.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a Cl.Vlr Ponte e Cl.Vlr LP estao preenchidos.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct211ValCV()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ct211ValCV()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct211ValCV(cClVl,cClVlPon,cClVlLP,lPontes,lClVlOk,lCadastro)  

Local aSaveArea	:= GetArea()

dbSelectArea("CTH")
dbsetOrder(1)
MsSeek(xFilial("CTH")+cClVl)

If lCadastro//Se utiliza Cl.Valor Ponte/LP do Cadastro de Cl.Valor
	If Found()
		If	lPontes .And. Empty(CTH->CTH_CLPON)
			lClVlOk 	:= .F.
		ElseIf Empty(CTH->CTH_CLVLLP)
			lClVlOk 	:= .T.
			cClVlPon	:= CTH->CTH_CLPON
			cClVlLP		:= cClVl
		Else
			lClVlOk 	:= .T.
			cClVlPon	:= CTH->CTH_CLPON
			cClVlLP		:= CTH->CTH_CLVLLP
		Endif
	Endif
Else
	If lPontes                		
		If Subs(CTH->CTH_CLPON,1,1) = "*" 
			lClVlOk		:= .F.					
		EndIf
		MsSeek(xFilial("CTH")+cClVlPon)		
	Else                                   
		If Subs(CTH->CTH_CLVLLP,1,1) = "*" 
			lClVlOk		:= .F.					
		EndIf	
		MsSeek(xFilial("CTH")+cClVlLP)	
	EndIf            
	If lClVlOk .And. !Found()
		lClVlOk	:= .F.        
	EndIf
EndIf

RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct211ValCt³ Autor ³ Simone Mie Sato       ³ Data ³ 02.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a Conta Ponte e Conta LP estao preenchidas.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct211ValCt()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA211()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct211ValCt(cConta,cCtaPon,cDigPon,cCtaLP,cDigLP,lPontes,lCtaOk,aCriter,aCritPon,aCritLP,lCadastro,lAutomato,cMsgErroPg)
Local aSaveArea := GetArea()
Local nMoedas   := __nQuantas
Local nCont     := 0
Local lExibeMsg := .F.

Default lAutomato  := _lBlind
Default cMsgErroPg := ""

dbSelectArea( "CT1" )
dbsetOrder( 1 )
MsSeek( xFilial( "CT1" ) + cConta )
lExibeMsg := Empty( cMsgErroPg )

If lCadastro	//Se utiliza Conta Ponte/LP do Cadastro de Plano de Contas
	If Found()
		If	( Empty( CT1->CT1_CTALP )  .Or. ;
			( lPontes .And. Empty( CT1->CT1_CTAPON ) ) )
			lCtaOk 	:= .F.
		Else
			lCtaOk 	:= .T.
			cCtaPon	:= CT1->CT1_CTAPON
			cCtaLP 	:= CT1->CT1_CTALP
		EndIf
	EndIf
Else 
	If lPontes
		If Subs( CT1->CT1_CTAPON , 1 , 1 ) == "*"
			lCtaOk	:= .F.
		EndIf

		MsSeek( xFilial("CT1") + cCtaPon )
	Else
		If Subs( CT1->CT1_CTALP , 1 , 1 ) == "*"
			lCtaOk	:= .F.
		EndIf

		MsSeek( xFilial("CT1") + cCtaLP )
	EndIf

	If lCtaOk .And. !Found()
		lCtaOk	:= .F.
	EndIf
EndIf

If lCtaOk
	For nCont := 1 To (nMoedas - 1 )
		aAdd( aCriter , &("CT1->CT1_CVD"+StrZero(nCont+1,2)) )
	Next nCount

	MsSeek( xFilial( "CT1" ) + cCtaPon )
	cDigPon := CT1->CT1_DC

	For nCont := 1 To ( nMoedas - 1 )
		aAdd( aCritPon , &("CT1->CT1_CVD"+StrZero(nCont+1,2)) )
	Next nCount

	MsSeek( xFilial( "CT1" ) + cCtaLP )
	cDigLP	:= CT1->CT1_DC

	For nCont := 1 To ( nMoedas - 1 )
		aAdd( aCritLP , &("CT1->CT1_CVD"+StrZero(nCont+1,2)) )
	Next nCount
Else
	If lExibeMsg .And. !lCadastro
		If lPontes
			cMsgErroPg := OemToAnsi( STR0118 )
		Else
			cMsgErroPg := OemToAnsi( STR0117 )
		EndIf

		If !_lBlind .And. !lAutomato
			MsgInfo( cMsgErroPg )
		EndIf
	Else
		cMsgErroPg := ""
	EndIf
EndIf

RestArea( aSaveArea )

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct211AtSX5³ Autor ³ Simone Mie Sato       ³ Data ³ 11.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualizo a tabela do SX5.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct211AtSX5(dDataFLP)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct211AtSX5()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct211AtSX5(dDataFLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSaldo,lPontes)

Local aSaveArea	:= GetArea()
Local cChave	:= cEmpAnt+cFilant
Local cCampo	:= ""
Local lExiste	:= .F.                                        
Local nContad
Local cChar		:= ""

// Caso a tabela LP exista na tabela CW0 o processo será feito por ela e nao pela SX5
If CtLPCW0Tab()
	CtAtLPCW0(dDataFLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSaldo,lPontes)
	dbSelectArea("CW0")
	FKCOMMIT()
EndIf  


RestArea(aSaveArea)

Return




/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct211GrCTZ³ Autor ³ Marcos S. Lobo        ³ Data ³ 26.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava Registros ref. o arquivo CTZ.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct211GrCTZ(aGrvLan)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct211GrCTZ()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct211GrCTZ(dDataFLP,cLote,cSubLote,cDoc,cLinha,cMoedLC,cTpSald,;
					cTipo,nValorLC,cConta,cCusto,cItem,cCLVL,cEnt05)

Local aSaveArea		:= GetArea()         
Local cSeqLiCTZ		:= ""
Local nLCTZSeqLin	:= 0
Local cFilCTZ		:= ""
Local cLastSeqLin	:= ""

Default cEnt05		:= ""

dbSelectArea("CTZ")
dbSetOrder(1)	//DATA+LOTE+SUBLOTE+DOC+TP SALDO+EMPORI+FILORI+MOEDA+LINHA+SEQLIN
cFilCTZ	:= xFilial("CTZ")
nLCTZSeqLin := Len(CTZ->CTZ_SEQLIN)				/// TAMANHO DO CTZ_SEQLIN
cSeqLiCTZ	:= StrZero(0,nLCTZSeqLin)			/// INICIALIZA CTZ_SEQLIN
cLastSeqLin	:= Replicate("z",nLCTZSeqLin)		/// ULTIMO CTZ_SEQLIN POSSÍVEL

/// CASO MUDE A LINHA DE LANÇAMENTO OU DOCUMENTO 
/// FAZ VERIFICAÇÕES DE EXISTENCIA DA LINHA NO CTZ
If __cKeyCTZATU <> cFilCTZ+dtos(dDataFLP)+cLote+cSubLote+cDoc+cTpSald+cEmpAnt+cFilAnt+cMoedLC+cLinha
	/// SE ENCONTRAR MESMA LINHA DO CT2 NO CTZ -> INCREMENTA SEQUENCIAL DO CTZ
	If MsSeek(cFilCTZ+dtos(dDataFLP)+cLote+cSubLote+cDoc+cTpSald+cEmpAnt+cFilAnt+cMoedLC+cLinha,.F.)
		/// LOCALIZA ÚLTIMA SEQUENCIA DE CTZ UTILIZADA PARA A LINHA
		MsSeek(cFilCTZ+dtos(dDataFLP)+cLote+cSubLote+cDoc+cTpSald+cEmpAnt+cFilAnt+cMoedLC+cLinha+cLastSeqLin,.T.)
		dbSkip(-1)
		/// DETERMINA A PRÓXIMA SEQUECIA DE CTZ
		cSeqLiCTZ := Soma1(CTZ->CTZ_SEQLIN)
	Else
		/// SE NÃO ENCONTRAR A MESMA LINHA DO CT2 NO CTZ
	    cSeqLiCTZ := StrZero(1,nLCTZSeqLin)
	EndIf
	
	__cKeyCTZATU := cFilCTZ+dtos(dDataFLP)+cLote+cSubLote+cDoc+cTpSald+cEmpAnt+cFilAnt+cMoedLC+cLinha
Else
	cSeqLICTZ := Soma1(__cSeqLICTZ)
EndIf

/// VERIFICA SE A PROXIMA SEQUENCIA DE CTZ NÃO EXISTE
While MsSeek(cFilCTZ+dtos(dDataFLP)+cLote+cSubLote+cDoc+cTpSald+cEmpAnt+cFilAnt+cMoedLC+cLinha+cSeqLiCTZ,.F.)
	If cSeqLiCTZ >= cLastSeqLin
		/// SE HOUVER ESTOURO DA QUANTIDADE DE SEQUENCIAS PARA 1 LINHA
		If !_lBlind
			MsgAlert("Contact the Administrator. "+CRLF+;
			"The CTZ_SEQLIN Field Length it´s too short, try to increase field length."+CRLF+;
			"The next sequences of this line will be recorded with line 'zzz',"+;
			 "duplicate key errors can happen.","CTBA211 Alert")			
		EndIf
		CONOUT("CTBA211 ALERT!"+CRLF+"Contact the Administrator."+CRLF+"The CTZ_SEQLIN Field Length it´s too short, try to increase field length.")
		cLinha := Replicate("z",Len(CTZ->CTZ_LINHA))
		cSeqLiCTZ := StrZero(0,nLCTZSeqLin)
	EndIf
	cSeqLiCTZ := Soma1(cSeqLiCTZ)
EndDo

__cSeqLICTZ := cSeqLiCTZ

dbSelectArea("CTZ")   
//Sempre sera incluido um novo registro no CTZ
Reclock("CTZ",.T.)
CTZ_FILIAL	:= cFilCTZ
CTZ_DATA	:= dDataFLP
CTZ_LOTE	:= cLote
CTZ_SBLOTE	:= cSubLote
CTZ_DOC		:= cDoc
CTZ_LINHA	:= cLinha
CTZ_SEQLIN	:= cSeqLiCTZ
CTZ_TPSALD	:= cTPSald
CTZ_CONTA	:= cConta
CTZ_CUSTO	:= cCusto
CTZ_ITEM	:= cItem
CTZ_CLVL	:= cCLVL
CTZ_MOEDLC	:= cMoedLC
CTZ_EMPORI	:= cEmpAnt
CTZ_FILORI	:= cFilAnt
If cTipo == "1"
	CTZ_VLRDEB	:= nValorLC
ElseIf cTipo == "2"
	CTZ_VLRCRD	:= nValorLC
EndIf
If lEntidad05
	If cTipo == "1"
		CTZ_EC05DB := cEnt05
	ElseIf cTipo == "2"
		CTZ_EC05CR := cEnt05
	EndIf
EndIf
MsUnlock()

RestArea(aSaveArea)

Return						


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA211   ºAutor  ³Marcos S. Lobo      º Data ³  26.09.06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct211FlgLP(cConta,cCusto,cItem,cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda, cEnt05)

Local cKeyFlag := alltrim(cFilAnt+cMoeda+cTpSald+cConta+cCusto+cItem+cClVL)
Local nLenKey	  := Len(alltrim(cKeyFlag))
Local lReproc := mv_par28 == 1

Default cEnt05	:= ""
/*Foi necessária proteção para nao fazer atualização nesse processo pois causava errorlog
a atualização das flags já é realizada no reprocessamento com ou sem procedure
protegido para Brasil para não afetar regras de apuração MI */
If !(cPaisLoc == 'BRA' ) 

	If AsCan(__aJaFlag,{|x| Substr(x,1,nLenKey) == cKeyFlag }) <= 0
		If lReproc
			If lEntidad05 .And. !Empty(cEnt05)
				Ct190FlgLP(cFilAnt, "QL6", cConta,cCusto,cItem,cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,,"S",cEnt05)
			EndIf
			If !Empty(cCLVL)
				Ct190FlgLP(cFilAnt, "CTI", cConta,cCusto,cItem,cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
			EndIf
			If !Empty(cITEM)
				Ct190FlgLP(cFilAnt, "CT4", cConta,cCusto,cItem,"", dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
			EndIf
			If !Empty(cCUSTO)
				Ct190FlgLP(cFilAnt, "CT3", cConta,cCusto,"","", dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
			EndIf
			If !Empty(cConta)
				Ct190FlgLP(cFilAnt, "CT7", cConta,"","","", dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
			EndIf
		Endif

		If lReproc
			/// MARCA FLAG NAS TABELAS DE SALDOS COMPOSTOS
			If lEntidad05 .And. !Empty(cEnt05)
				Ct190FlgLP(cFilAnt, "CTU", "","","","", dDataILP, cTpSald, dDataFLP, cMoeda,"QL6","S",cEnt05)
			EndIf
			If !Empty(cCLVL)
				Ct190FlgLP(cFilAnt, "CTU", "","","",cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,"CTH","S")
			EndIf
			If !Empty(cITEM)
				Ct190FlgLP(cFilAnt, "CTU", "","",cITEM,"", dDataILP, cTpSald, dDataFLP, cMoeda,"CTD","S")
			EndIf
			If !Empty(cCUSTO)
				Ct190FlgLP(cFilAnt, "CTU", "",cCUSTO,"","", dDataILP, cTpSald, dDataFLP, cMoeda,"CTT","S")
			EndIf
		Endif        
		AAdd(__aJaFlag,cKeyFlag)
	EndIf

	If !lReproc
		// forço a atualização do flag de reprocessamento de saldo.
		PutCv7Date(cTpSald,cMoeda,cTod(""))
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA211   ºAutor  ³Marcos S. Lobo      º Data ³  26/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MostraSX5LP()

Local a
Local b
Local c
Local aAreaOri := GetArea()
Local aAreaX5  := SX5->(GetArea())

// Caso a tabela LP exista na tabela CW0 o processo será feito por ela e nao pela SX5
If CtLPCW0Tab()
	CtMosLPCW0()  	
Else
	dbSelectArea("SX5")
	aAreax5 := GetArea()
	dbSetOrder(1)
	If !MsSeek(xFilial("SX5")+"LP",.F.)
		MsgInfo(STR0041,STR0042)//"Não existem apurações registradas."//"Tabela LP - Apurações de resultado"
	Else
		ConPad1(a,b,c,"CTZ",,,.F.)
	EndIf 
EndIf

RestArea(aAreaX5)
RestArea(aAreaOri)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA211   ºAutor  ³Microsiga           º Data ³  09/27/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct211Seek(aDocsLP,cMoeda,cTpSald,cDebito,cCredito,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,cEnt05DB,cEnt05CR)

Local nRecFound := 0
Local _nD		:= 1
Local cFilCT2	:= ""

DEFAULT aDocsLP := {}
DEFAULT cEnt05DB:= ""
DEFAULT cEnt05CR:= ""

If Len(aDocsLP) == 0 .or. ValType(aDocsLP) <> "A"
	Return(nRecFound)
EndIf

For _nD := 1 to Len(aDocsLP)			/// RODA TODOS OS DOCUMENTOS GERADOS PELA APURACAO
	dbSelectArea("CT2")
	dbSetOrder(1)
	cFilCT2 := xFilial("CT2")
	If MsSeek(cFilCT2+DTOS(aDocsLP[_nD][2])+aDocsLP[_nD][3]+aDocsLP[_nD][4]+aDocsLP[_nD][5],.F.)
		While CT2->(!Eof()) .and. CT2->CT2_FILIAL == cFilCT2 .and. CT2->CT2_DATA == aDocsLP[_nD][2] .and.;
			CT2->CT2_LOTE == aDocsLP[_nD][3] .and. CT2->CT2_SBLOTE == aDocsLP[_nD][4] .and.;
			CT2->CT2_DOC == aDocsLP[_nD][5]
			// LE ENQUANTO FOR O DOCUMENTO DE APURACAO
			If CT2->CT2_MOEDLC == cMoeda .and. CT2->CT2_TPSALD == cTpSald
				// SE FOR A MESMA MOEDA E TIPO DE SALDO A SER GERADO
				If lEntidad05
					If CT2->CT2_DEBITO == cDebito .and. CT2->CT2_CREDIT == cCredito .and.;
						CT2->CT2_CCD == cCustoDeb .and. CT2->CT2_CCC == cCustoCrd .and.;
						CT2->CT2_ITEMD == cItemDeb .and. CT2->CT2_ITEMC == cItemCrd .and.;
						CT2->CT2_CLVLDB == cClVlDeb .and. CT2->CT2_CLVLCR == cClVlCrd .And. ;
						CT2->CT2_EC05DB == cEnt05DB .And. CT2->CT2_EC05CR == cEnt05CR
						/// E POSSUIR A MESMA COMBINAÇÃO DE ENTIDADES PARA O LANCAMENTO (DEB E CRED).
						nRecFound := CT2->(Recno())	 /// RETORNA O RECNO PARA SOMAR NO MESMO.
					EndIf
				ElseIf CT2->CT2_DEBITO == cDebito .and. CT2->CT2_CREDIT == cCredito .and.;
				   CT2->CT2_CCD == cCustoDeb .and. CT2->CT2_CCC == cCustoCrd .and.;
				   CT2->CT2_ITEMD == cItemDeb .and. CT2->CT2_ITEMC == cItemCrd .and.;
				   CT2->CT2_CLVLDB == cClVlDeb .and. CT2->CT2_CLVLCR == cClVlCrd
				   /// E POSSUIR A MESMA COMBINAÇÃO DE ENTIDADES PARA O LANCAMENTO (DEB E CRED).
				   nRecFound := CT2->(Recno())	 /// RETORNA O RECNO PARA SOMAR NO MESMO.
				EndIf
			EndIf			
		
			dbSkip()
		EndDo	
	EndIf
Next

Return(nRecFound)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A211OrdemºAutor  ³ Gustavo Henrique   º Data ³  14/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao customizada para apresentar consulta de apuracoes   º±±
±±º          ³ jah realizadas no objeto tNewProcess                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A211Ordem(oCenterPanel)

MsAguarde( { || MostraSX5LP() },,STR0005)	//Selecionando Registros...

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GtDescHelpºAutor  ³ Daniel Mendes   º Data ³  13/07/2016   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o help informado removendo a quebra de linha       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA211                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GtDescHelp( cHelp )
Local cDescHelp := ""

cDescHelp := Ap5GetHelp( cHelp )
cDescHelp := StrTran( cDescHelp , CRLF , Space( 1 ) ) 

Return cDescHelp


/*/{Protheus.doc} CTB211Metrics
	
	CTB211Metrics - Funcao utilizada para metricas no CTBA211

	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function CTB211Metrics(cEvent, nStart, cSubEvent, cSubRoutine, nQtdReg)

Local cFunBkp	:= ""
Local cFunMet	:= ""

Local nFim := 0

Local cIdMetric  := ""
Local dDateSend := CtoD("") 
Local nLapTime := 0
Local cTotal := ""

Default cEvent := ""
Default nStart := Seconds()
Default cSubEvent := ""
Default cSubRoutine := Alltrim(ProcName(1))
Default nQtdReg := 0

//Só capturar metricas se a vers?o da lib for superior a 20210517
If __lMetric .And. !Empty(cEvent)
	
	//grava funname atual na variavel cFunBkp
	cFunBkp := FunName()

	If cEvent == "01" //Evento 01 - Metrica de tempo médio

		
		If cSubEvent == '001'
			
			cFunMet := cFunBkp
			SetFunName(cFunMet)

			nFim := Seconds() - nStart // Capturar tempo final | Diferença com o tempo inicial
			
			//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
			
			cSubRoutine := Alltrim(cSubRoutine)
			cIdMetric  := "contabilidade-gerencial-protheus_apuracao-de-resultados-tempo-total_seconds"
			dDateSend := LastDay( Date() )
			nLapTime := nFim
			cTotal	:= "1"
			// Metrica
			FWCustomMetrics():SetMetric(cSubRoutine, cIdMetric, cTotal, dDateSend, nLapTime)

		EndIf

	Endif
	//Restaura setfunname a partir da variavel salva cFunBkp
	SetFunName(cFunBkp)
EndIf

Return
