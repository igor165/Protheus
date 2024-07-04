#Include "CTBA210.CH"
#Include "PROTHEUS.CH"

STATIC lGravouLan	:= .F.
STATIC nTamCta		:= TAMSX3("CT1_CONTA")[1]
STATIC nTamCC		:= TAMSX3("CTT_CUSTO")[1]
STATIC nTamItem		:= TAMSX3("CTD_ITEM")[1]
STATIC nTamClVl		:= TAMSX3("CTH_CLVL")[1]

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBA210   ³ Autor ³ Simone Mie Sato       ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apuracao de Resultados -Lucros/Perdas	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba210()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION CTBA210()

Local aSays 		:= {}
Local aButtons		:= {}
Local nOpca    		:= 0
Local cMens			:= ""
Local oProcess
Local cVersaoLP		:= ALLTRIM(GetNewPar("MV_CTBLPV",""))
Local lExclusivo := IIF(FindFunction("ADMTabExc"), ADMTabExc("CT2") , !Empty(xFilial("CT2") ))

PRIVATE cCadastro 	:= OemToAnsi(STR0001)  //"Apuracao de Lucros / Perdas"
PRIVATE cString   	:= "CT2"
PRIVATE cDesc1    	:= OemToAnsi(STR0002)  //"Esta rotina ir  gerar os lancamentos contabeis de lucros e perdas."
PRIVATE cDesc2    	:= ""
PRIVATE cDesc3    	:= ""
PRIVATE titulo    	:= OemToAnsi(STR0003)  //"Simulacao da Apuracao"
PRIVATE cCancel   	:= OemToAnsi(STR0004)  //"***** CANCELADO PELO OPERADOR *****"
PRIVATE nomeprog  	:= "CTBA210"
PRIVATE aLinha    	:= { },nLastKey := 0

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TRATAMENTO PARA CHAMAR A VERSAO REVISADA     ³
//³DA APURACAO DE RESULTADOS -> CTBA211         ³
//³PERMITE SELECAO DO USUARIO E DEFINIR REVISADA³
//³COMO PADRAO. (DEFINIR ORIGINAL COMO PADRAO   ³
//³APENAS VIA CONFIGURADOR / SX6 )              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cVersaoLP == ""
	If MsgYesNo(STR0017,STR0018)//"Utilizar nova versão da Apuração de Resultados ? (Recomendado SIM)"//"Parâmetro MV_CTBLPV"
		CTBA211()
		Return
	EndIf	
ElseIf cVersaoLP == "211"
	CTBA211()
	Return
EndIf

///... continuação lógica original CTBA210
//Atualizar o arquivo SX5 com o flag de apuracao
Ct210UpdX5()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra tela de aviso - Verificar se os saldos foram atualizados.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMens := OemToAnsi(STR0011)+chr(13)  //"CASO A ATUALIZACAO DOS  SALDOS BASICOS  NAO  SEJA  FEITA  NA "
cMens += OemToAnsi(STR0012)+chr(13)  //"DIGITACAO DOS LANCAMENTOS (MV_ATUSAL = 'N'), FAVOR VERIFICAR "
cMens += OemToAnsi(STR0013)+chr(13)  //"SE OS SALDOS ESTAO ATUALIZADOS !!!!"

IF !MsgYesNo(cMens,OemToAnsi(STR0014))  //"ATEN€O"
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Data de Apuracao                                 ³
//³ mv_par02 // Numero do Lote			                         ³
//³ mv_par03 // Numero do SubLote		                         ³
//³ mv_par04 // Numero do Documento                              ³
//³ mv_par05 // Cod. Historico Padrao                            ³
//³ mv_par06 // Da Conta  		        						 ³
//³ mv_par07 // Ate a Conta                             		 ³
//³ mv_par08 // Moedas        			                         ³
//³ mv_par09 // Qual Moeda?                                      ³
//³ mv_par10 // Considera Entidades Pontes                       ³
//³ mv_par11 // Cod. Rateio Resultado Final                      ³
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
//³ mv_par28 // Seleciona FIlial                     		 ³
//³ mv_par29 // Filial De                     		 ³
//³ mv_par30 // Filial Até                     		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Pergunte( "CTB210", .T. )
	

AADD(aSays,OemToAnsi( STR0002 ) )	//"Esta rotina ir  gerar os lancamentos contabeis de lucros e perdas."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( aButtons )

AADD(aButtons, { 5,.T.,{|| Pergunte("CTB210",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CtbOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )
	                                    
If nOpca == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("INICIO")
	If !CTBSerialI("CTBPROC","OFF")
		Return
	Endif
  
	If MV_PAR28 == 1 .And. lExclusivo // Seleciona filiais
		oProcess := MsNewProcess():New({|lEnd| Ctb210Fil(oProcess,MV_PAR29,MV_PAR30)},"","",.F.)
	Else
		oProcess := MsNewProcess():New({|lEnd| Ctb210Proc(oProcess)},"","",.F.)
	EndIf

	oProcess:Activate()		

	CTBSerialF("CTBPROC","OFF")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("FIM")

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb210Fil ºAutor  ³Alvaro Camillo Neto º Data ³  21/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa o processamento para cada filial                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA210                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb210Fil(oProcess,cFilDe,cFilAte)
Local cFilIni 	:= cFIlAnt
Local aArea		:= GetArea()
Local aSM0 		:= AdmAbreSM0()
Local nContFil	:= 0   
Local cFilProc	:= ""

If Len( aSM0 ) > 0
	For nContFil := 1 to Len( aSM0 )
		If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
			Loop
		EndIf 
	
		cFilAnt := aSM0[nContFil][SM0_CODFIL]
		If Alltrim(cFilProc) != Alltrim(xFilial("CT2")) 
			cFilProc:= xFilial("CT2")
		Else
			Loop
		EndIf   
	
		ProcLogAtu("MENSAGEM",STR0020 + cFilAnt) // "EXECUTANDO A APURACAO DA FILIAL " 
		Ctb210Proc(oProcess)
	Next nContFil
	
	cFIlAnt := cFilIni
Else
	ProcLogAtu("ERRO","Atenção!","Nenhuma empresa/filial encontrada. Verique se está utilizando a ultima versão do ADMXFUN (MAR/2010)" )
Endif

RestArea(aArea)

Return
	
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb210Proc³ Autor ³ Simone Mie Sato       ³ Data ³ 30.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Zeramento de Lucros/Perdas.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB210Proc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ctb210Proc(oObj)
	
Local nx
Local dLastProc
Local dDataLP		:= mv_par01		//Data de Apuracao
Local cLote 		:= mv_par02		//Num. do lote que sera gerado os lancamentos
Local cSubLote		:= mv_par03		//Num. do sublote que sera gerado os lancamentos
Local cDoc			:= mv_par04		//Num. do doc. que sera gerado os lancamentos
Local cHP			:= mv_par05		//Historico Padrao utilizado nos lancamentos
Local cContaIni		:= mv_par06		//Conta Inicial
Local cContaFim		:= mv_par07		//Conta Final
Local cCustoIni		:= mv_par22		//C.Custo Inicial
Local cCustoFim		:= mv_par23		//C.Custo Final
Local cItemIni		:= mv_par24		//Item Inicial
Local cItemFim		:= mv_par25		//Item Final
Local cClVlIni		:= mv_par26		//Classe Inicial
Local cClVlFim		:= mv_par27		//Classe Final
Local lMoedaEsp		:= Iif(mv_par08==2,.T.,.F.)	//Moedas
Local cMoeda		:= StrZero(Val(mv_par09),2)			//Define qual a moeda especifica
Local lPontes		:= Iif(mv_par10 == 1,.T.,.F.) //Considera Entidades Pontes
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
Local dDataIni		:= dDataLP +1
Local dDataFim
Local nLinha		:= 0
Local cLinha		:= '000'
Local cCampo		:= ""
Local cFilDe		:= ""
Local cFilAte		:= ""
Local cSeqLin		:= "000"
Local cLinhaAnt		:= "000", lJaExec := .F.
Local lSlbase		:= Iif(GETMV("MV_ATUSAL")=="N",.F.,.T.)
Local nIndTmp		:= 0
Local lCtbCCLP		:= Iif(ExistBlock("CTB210CC"),.T.,.F.)
Local lCtbItLP 		:= Iif(ExistBlock("CTB210IT"),.T.,.F.)
Local lCtbCVLP 		:= Iif(ExistBlock("CTB210CV"),.T.,.F.)
Local lRetSaldo		:= .T.


Local lFirst 		:= .T.
Local cLoteAtu 		:= cLote
Local cSubAtu		:= cSubLote
Local cDocAtu		:= cDoc 
Local nK			:= 0    
Local lExclusivo    := IIF(FindFunction("ADMTabExc"), ADMTabExc("CT2") , !Empty(xFilial("CT2") ) )
Local cIdioma       := ""

// Sub-Lote somente eh informado se estiver em branco
mv_par03 := If(Empty(GetMV("MV_SUBLOTE")), mv_par03, GetMV("MV_SUBLOTE"))

If MV_PAR28 == 1 .And. Empty(xFilial("CT2")) 
	ProcLogAtu("MENSAGEM","TRATAMENTO MULTI FILIAL DESABILITADO: CT2 COMPARTILHADO") 
EndIf

If lMoedaEsp					// Moeda especifica
	cMoeda	:= mv_par09
	aCtbMoeda := CtbMoeda(cMoeda)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO","NOMOEDA",Ap5GetHelp("NOMOEDA"))

		Return
	EndIf                  
	nInicio := val(cMoeda)
	nFinal	:= val(cMoeda)
Else
	nInicio	:= 1
	nFinal	:= __nQuantas
EndIf

// Caso a tabela LP exista na tabela CW0 o processo será feito por ela e nao pela SX5
If CtLPCW0Tab()
	If !CtLPCW0Vdt(dDataLP,@lJaExec,@lPergOk,cMoeda,cTpSaldo,lMoedaEsp) 
		Return(.F.)
	EndIf	  	
Else
	cIdioma  := Upper(Left(FWRetIdiom(), 2))
	Do Case 
	Case cIdioma == 'PT'
		cCampo	:= "SX5->X5_DESCRI"
	Case cIdioma == 'ES'
		cCampo	:= "SX5->X5_DESCSPA"
	Case cIdioma == 'EN'
		cCampo	:= "SX5->X5_DESCENG"
	EndCase 
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ANTES DE INICIAR O PROCESSAMENTO, VERIFICO OS PARAMETROS.	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Data de Apuracao nao preenchida.
	If Empty(dDataLP)                              
		Help(" ",1,"NOCTBDTLP")
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO","NOCTBDTLP",Ap5GetHelp("NOCTBDTLP"))
	
		Return(.F.)
	Else //Se a data estiver preenchida, verifica se ja foi rodado nessa data.
		dbSelectarea("SX5")
		dbSetOrder(1)
		If MsSeek(xFilial()+"LP"+cEmpAnt+cFilAnt)			
			While !Eof() .and. SX5->X5_TABELA == "LP"
				If Subs(&(cCampo),1,8) == Dtos(dDataLP) 
					If (!lMoedaEsp .Or. (lMoedaEsp .And. Subs(&(cCampo),9,2) == cMoeda)) .And.;
							Subs(&(cCampo),11,1) == cTpSaldo 
						If ! MsgYesNo(STR0008,OemToAnsi(STR0014))
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
		lPergOk	:= CtbValiDt(1,dDataLP)
	Endif                            
EndIf
	
//Historico Padrao nao preenchido.
If Empty(cHP)	
	Help(" ",1,"CTHPVAZIO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","CTHPVAZIO",Ap5GetHelp("CTHPVAZIO"))

	lPergOk := .F.
Else
	dbSelectArea("CT8")
	dbSetOrder(1)
	MsSeek(xFilial("CT8")+cHP)
	If found()
		cDescHP 	:= CT8->CT8_DESC
	Else            
		//Historico Padrao nao existe no cadastro.
		Help(" ",1,"CT210NOHP")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO","CT210NOHP",Ap5GetHelp("CT210NOHP"))
	
		lPergOk := .F.
	Endif
Endif                             
	
//Lote nao preenchido.
If Empty(cLote)
	Help(" ",1,"NOCT210LOT")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","NOCT210LOT",Ap5GetHelp("NOCT210LOT"))

	lPergOk := .F.
Endif
	
//Sub Lote nao preenchido.
If Empty(cSubLote)
	Help(" ",1,"NOCTSUBLOT")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","NOCTSUBLOT",Ap5GetHelp("NOCTSUBLOT"))

	lPergOk := .F.
Endif
	
//Documento nao preenchido.
If Empty(cDoc)
	Help(" ",1,"NOCT210DOC")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","NOCT210DOC",Ap5GetHelp("NOCT210DOC"))

	lPergOk := .F.
Else	//Se o documento estiver preenchido, verifico se existe lancamento com mesmo numero
		//de lote, sublote, documento e data
	dbSelectArea("CT2")
	dbSetOrder(1)
//	If ! lJaExec .And. MsSeek(xFilial()+dtos(dDataLP)+cLote+cSubLote+cDoc)	
	If MsSeek(xFilial()+dtos(dDataLP)+cLote+cSubLote+cDoc)	
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
	ProcLogAtu("ERRO","NOCT210CT",Ap5GetHelp("NOCT210CT"))

	lPergOk := .F.
Endif                                          
	
//Se for moeda especifica, verificar se a moeda esta preenchida
If lMoedaEsp
	If Empty(cMoeda)
		Help(" ",1,"NOCTMOEDA")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO","NOCTMOEDA",Ap5GetHelp("NOCTMOEDA"))

		lPergOk := .F.
	Endif
EndIf	
	     
//Tipo de saldo nao preenchido
If Empty(cTpSaldo)
	Help(" ",1,"NO210TPSLD")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","NO210TPSLD",Ap5GetHelp("NO210TPSLD"))

	lPergOk := .F.
Endif	       

//Se utiliza as entidades ponte/LP da Rotina, verificar se os parametros estao preenchidos
If !lCadastro
	If lPontes .And. (Empty(mv_par14) .Or. Empty(mv_par15))
		Help(" ",1,"NOCT210CT")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO","NOCT210CT",Ap5GetHelp("NOCT210CT"))
	
		lPergOk	:= .F.	
	ElseIf	!lPontes .And. Empty(mv_par15)
		Help(" ",1,"NOCT210CT")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO","NOCT210CT",Ap5GetHelp("NOCT210CT"))

		lPergOk	:= .F.		
	EndIf 
	
	    // Verifica se a Conta ponte está sendo apurada também
    If lPergOk .And. lPontes .And. !Empty(mv_par14) .And.  ( mv_par14 >= cContaIni .And.  mv_par14 <= cContaFim )
    	Help("  ",1,"CT210PONTCT1",,STR0021 ,1,0) //"Conta ponte não pode estar no intervalo das contas apuradas"
    	lPergOk := .F.
		ProcLogAtu("ERRO","CT210PONTCT1",STR0021 )//"Conta ponte não pode estar no intervalo das contas apuradas"
    EndIf 
    
    If lPergOk .And. !Empty(mv_par15) .And.  ( mv_par15 >= cContaIni .And.  mv_par15 <= cContaFim )
    	Help("  ",1,"CT211APRCT1",,STR0022 ,1,0) //"Conta de Apuração não pode estar no intervalo das contas apuradas "
    	lPergOk := .F.
		ProcLogAtu("ERRO","CT211APRCT1",STR0022 )//"Conta de Apuração não pode estar no intervalo das contas apuradas "	
    EndIf
	
EndIf

//Verifica se tem algum saldo basico desatualizado. Definido que essa verificacao so sera 
//feita em top connect, pois se fosse fazer em codebase iria degradar muito a performance
//do sistema. 
If !lSlBase //So ira fazer a verificacao, caso o parametro MV_ATUSAL esteja com "N"
	For nx := nInicio to nFinal
		dLastProc := GetCv7Date(cTpSaldo,StrZero(nx,2))
		If dDataLP > dLastProc
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

If lPontes
	cSeqLin := CtbLinCTZ(cLote,cSubLote,cDoc,dDataLP,nLinha,cMoeda,cTpSaldo)
	lFirst := .F.
	cLoteAtu := cLote
	cSubAtu	 := cSubLote
	cDocAtu	 := cDoc					
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICO OS SALDOS DA CLASSE DE VALOR (CTI).   			  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lClvl
	Ctb210CTB('CTI',nInicio,nFinal,dDataLP,cContaIni,cContaFim,lPontes,cTpSaldo,@cLote,cSubLote,@cDoc,cHP,cDescHP,oObj,@nLinha,lMoedaEsp,cMoeda,lCadastro,@cSeqLin,@cLinhaAnt,lJaExec,@cLinha,nIndTMP, cCustoIni, cCustoFim, cItemIni, cItemFim, cClVlIni, cClVlFim)
EndIf

If lPontes .and. (cLote <> cLoteAtu .or. cSubLote <> cSubAtu .or. cDoc <> cDocAtu)
	cSeqLin := CtbLinCTZ(cLote,cSubLote,cDoc,dDataLP,nLinha,cMoeda,cTpSaldo)
	lFirst := .F.
	cLoteAtu := cLote
	cSubAtu	 := cSubLote
	cDocAtu	 := cDoc					
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICO OS SALDOS DO ITEM CONTABIL (CT4).     			  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lItem
	Ctb210CTB('CT4',nInicio,nFinal,dDataLP,cContaIni,cContaFim,lPontes,cTpSaldo,@cLote,cSubLote,@cDoc,cHP,cDescHP,oObj,@nLinha,lMoedaEsp,cMoeda,lCadastro,@cSeqLin,@cLinhaAnt,lJaExec,@cLinha,nIndTMP, cCustoIni, cCustoFim, cItemIni, cItemFim)
EndIf

If lPontes .and. (cLote <> cLoteAtu .or. cSubLote <> cSubAtu .or. cDoc <> cDocAtu)
	cSeqLin := CtbLinCTZ(cLote,cSubLote,cDoc,dDataLP,nLinha,cMoeda,cTpSaldo)
	lFirst := .F.
	cLoteAtu := cLote
	cSubAtu	 := cSubLote
	cDocAtu	 := cDoc					
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICO OS SALDOS DO CENTRO DE CUSTO(CT3).    			  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCusto
	Ctb210CTB('CT3',nInicio,nFinal,dDataLP,cContaIni,cContaFim,lPontes,cTpSaldo,@cLote,cSubLote,@cDoc,cHP,cDescHP,oObj,@nLinha,lMoedaEsp,cMoeda,lCadastro,@cSeqLin,@cLinhaAnt,lJaExec,@cLinha,nIndTMP, cCustoIni, cCustoFim)
EndIf

If lPontes .and. (cLote <> cLoteAtu .or. cSubLote <> cSubAtu .or. cDoc <> cDocAtu)
	cSeqLin := CtbLinCTZ(cLote,cSubLote,cDoc,dDataLP,nLinha,cMoeda,cTpSaldo)
	lFirst := .F.
	cLoteAtu := cLote
	cSubAtu	 := cSubLote
	cDocAtu	 := cDoc					
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICO OS SALDOS DA CONTA.(CT7)              			  	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ctb210CTB('CT7',nInicio,nFinal,dDataLP,cContaIni,cContaFim,lPontes,cTpSaldo,@cLote,cSubLote,@cDoc,cHP,cDescHP,oObj,@nLinha,lMoedaEsp,cMoeda,lCadastro,@cSeqLin,@cLinhaAnt,lJaExec,@cLinha,nIndTMP)

If lPontes .and. (cLote <> cLoteAtu .or. cSubLote <> cSubAtu .or. cDoc <> cDocAtu)
	cSeqLin := CtbLinCTZ(cLote,cSubLote,cDoc,dDataLP,nLinha,cMoeda,cTpSaldo)
	lFirst := .F.
	cLoteAtu := cLote
	cSubAtu	 := cSubLote
	cDocAtu	 := cDoc					
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICAR SE RESTOU ALGUM SALDO RESIDUAL NAS TABELAS CT4/CT3/CT7 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lItem
	Ctb210CTB('CT4',nInicio,nFinal,dDataLP,cContaIni,cContaFim,lPontes,cTpSaldo,@cLote,cSubLote,@cDoc,cHP,cDescHP,oObj,@nLinha,lMoedaEsp,cMoeda,lCadastro,@cSeqLin,@cLinhaAnt,lJaExec,@cLinha,nIndTMP, cCustoIni, cCustoFim, cItemIni, cItemFim, , ,.T.)
EndIf

If lPontes .and. (cLote <> cLoteAtu .or. cSubLote <> cSubAtu .or. cDoc <> cDocAtu)
	cSeqLin := CtbLinCTZ(cLote,cSubLote,cDoc,dDataLP,nLinha,cMoeda,cTpSaldo)
	lFirst := .F.
	cLoteAtu := cLote
	cSubAtu	 := cSubLote
	cDocAtu	 := cDoc					
EndIf

If lCusto
	Ctb210CTB('CT3',nInicio,nFinal,dDataLP,cContaIni,cContaFim,lPontes,cTpSaldo,@cLote,cSubLote,@cDoc,cHP,cDescHP,oObj,@nLinha,lMoedaEsp,cMoeda,lCadastro,@cSeqLin,@cLinhaAnt,lJaExec,@cLinha,nIndTMP, cCustoIni, cCustoFim,,,,,.T.)
EndIf

If lPontes .and. (cLote <> cLoteAtu .or. cSubLote <> cSubAtu .or. cDoc <> cDocAtu)
	cSeqLin := CtbLinCTZ(cLote,cSubLote,cDoc,dDataLP,nLinha,cMoeda,cTpSaldo)
	lFirst := .F.
	cLoteAtu := cLote
	cSubAtu	 := cSubLote
	cDocAtu	 := cDoc					
EndIf
Ctb210CTB('CT7',nInicio,nFinal,dDataLP,cContaIni,cContaFim,lPontes,cTpSaldo,@cLote,cSubLote,@cDoc,cHP,cDescHP,oObj,@nLinha,lMoedaEsp,cMoeda,lCadastro,@cSeqLin,@cLinhaAnt,lJaExec,@cLinha,nIndTMP,,,,,,,.T.)

If Empty(xFilial("CT2"))
	cFilDe	:= "  "
	cFilAte	:= "  "     
Else
	cFilDe	:= cFilAnt
	cFilAte	:= cFilAnt
EndIf    

If lGravouLan
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ATUALIZA OS SALDOS COM DATA POSTERIOR AO L/P -REPROCESSAMENTO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Verifico qual a data final a ser passada para o Reprocessamento.
	Ct210MaxDt(dDataLP,@dDataFim,cContaIni,cContaFim, cCustoIni, cCustoFim, cItemIni, cItemFim, cClVlIni, cClVlFim)
	
	//Caso exista algum ponto de entrada, o reprocessamento sera rodado a partir da data de apuracao para 
	//atualizar os saldos de todas as tabelas
	If lCtbCCLP .Or. lCtbItLP .Or. lCtbCVLP
		dDataIni	:= dDataLP
		If Empty(dDataFim)
			dDataFim	:= dDataIni
		EndIf
	EndIf
	
	//Chamo o Reprocessamento, se tiver saldos com data posterior ao zeramento.
	//Somente atualizo os saldos basicos
	If !Empty(dDataFim) .Or. (lCtbCCLP .Or. lCtbItLP .Or. lCtbCVLP)
		CTBA190(.T.,dDataIni,dDataFim,cFilDe,cFilAnt,cTpSaldo,lMoedaEsp,cMoeda)
	EndIf
EndIf
//Atualiza tabela do SX5 com a data de apuracao.
Ct210AtSx5(dDataLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSaldo,lPontes)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb210CTB ³ Autor ³ Simone Mie Sato       ³ Data ³ 21.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifico os Saldos .                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb210CTB()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ctb210CTB(cAlias,nInicio,nFinal,dDataLP,cContaIni,cContaFim,lPontes,cTpSaldo,cLote,cSubLote,;
				cDoc,cHP,cDescHP,oObj,nLinha,lMoedaEsp,cMoeda,lCadastro,cSeqLin,cLinhaAnt,lJaExec,cLinha,nIndTmp,;
				cCustoIni, cCustoFim, cItemIni, cItemFim, cClVlIni, cClVlFim,lSldRes )

Local aSaveArea	:=	GetArea()                                                
Local nRecno	:=	0
Local nTotRegua	:= (CTI->(Reccount())+CT4->(Reccount())+CT3->(Reccount())+CT7->(RecCount()))
Local bCondLP	:= {||.F.}   
Local cChaveAntD:= ""	//Utilizado na gravacao de lancamento contabil.
Local cChaveAntC:= ""	//Utilizado na gravacao de lancamento contabil.
Local cEntidAnt	:= ""
Local cEntidAtu	:= ""                           
Local cMoedaAtu	:= ""
Local cMoedFrst	:= ""
Local lGrvM1Zer	:= .F.
Local lFirst	:= .T.
Local dMaxDtLP	:= CTOD("  /  /  ")

DEFAULT lSldRes	:= .F.	//Se está verificando se existe algum saldo residual apos a primeira execucao.

If cCustoIni == Nil
	cCustoIni := ""
EndIf
If cCustoFim == Nil
	cCustoFim := Replicate("Z",Len(CT3->CT3_CUSTO))
EndIf
If cItemIni	== Nil
	cItemIni	:= ""
EndIf
If cItemFim == Nil
	cItemFim	:= Replicate("Z",Len(CT4->CT4_ITEM))
EndIf
If cClVlIni == Nil
	cClVlIni	:= ""
EndIf
If cClVlFim	== Nil
	cClVlFim	:= Replicate("Z",Len(CTI->CTI_CLVL))
EndIf                 

//Retorna qual a ultima data de apuracao SEM conta ponte (zerando receitas/despesas)
dMaxDtLp	:= CtbMaxDtLp()

//Monta query que traz os registros a serem zerados
Ct210Query(cAlias,lMoedaEsp,nInicio,nFinal,dDataLP,cContaIni,cContaFim,cTpSaldo,lPontes,lJaExec,;
			cCustoIni, cCustoFim, cItemIni, cItemFim, cClVlIni, cClVlFim, lSldRes,dMaxDtLp )
						
oObj:SetRegua1(nTotRegua)			 				

dbSelectArea('c210Query')                              			
While !Eof()		 	
													
	If lFirst
		If cAlias == "CTI"
			cMoedFrst	:= c210Query->CTI_MOEDA
		ElseIf cAlias == "CT4"
			cMoedFrst	:= c210Query->CT4_MOEDA		
		ElseIf cAlias == "CT3"
			cMoedFrst	:= c210Query->CT3_MOEDA		
		ElseIf cAlias == "CT7"
			cMoedFrst	:= c210Query->CT7_MOEDA		
		EndIf	
	EndIf

	//Verificar se devera gravar lançamento na moeda 01 zerado (pois nao existe saldo na 
	//moeda 01 a ser zerado) 
	If !lMoedaEsp .And. ((!Empty(cEntidAnt) .And.  (cEntidAnt <> cEntidAtu .And. cMoedaAtu <> '01')) .Or. (lFirst .and. cMoedFrst <> '01'))
		lGrvM1Zer := .T.                                                        
	Else
		lGrvM1Zer := .F.                                                        							
	EndIf
	
	If cAlias == 'CTI'                                                                                                                                                                                                  
		Ct210Atual('CTI',c210Query->CTI_CLVL,c210Query->CTI_ITEM,c210Query->CTI_CUSTO,c210Query->CTI_CONTA,c210Query->CTI_ATUDEB,c210Query->CTI_ATUCRD,lPontes,c210Query->CTI_DATA,c210Query->CTI_MOEDA, cTpSaldo,dDataLP,;
		@cLote,cSubLote,@cDoc,cHP,cDescHP,c210Query->RECNO,@nLinha,lMoedaEsp,@cChaveAntD,@cChaveAntC,lCadastro,@cSeqLin,@cLinhaAnt,lJaExec,@cLinha,nIndTmp,lGrvM1Zer,lSldRes)
		cEntidAnt	:= c210Query->CTI_CLVL+c210Query->CTI_ITEM+c210Query->CTI_CUSTO+c210Query->CTI_CONTA
	ElseIf cAlias == 'CT4'
		Ct210Atual('CT4',,c210Query->CT4_ITEM,c210Query->CT4_CUSTO,c210Query->CT4_CONTA,c210Query->CT4_ATUDEB,c210Query->CT4_ATUCRD,lPontes,c210Query->CT4_DATA,c210Query->CT4_MOEDA,cTpSaldo,dDataLP,;				
		@cLote,cSubLote,@cDoc,cHP,cDescHP,c210Query->RECNO,@nLinha,lMoedaEsp,@cChaveAntD,@cChaveAntC,lCadastro,@cSeqLin,@cLinhaAnt,lJaExec,@cLinha,nIndTmp,lGrvM1Zer,lSldRes)
		cEntidAnt	:= c210Query->CT4_ITEM+c210Query->CT4_CUSTO+c210Query->CT4_CONTA					
	ElseIf cAlias == 'CT3'
		Ct210Atual('CT3',,,c210Query->CT3_CUSTO,c210Query->CT3_CONTA,c210Query->CT3_ATUDEB,c210Query->CT3_ATUCRD,lPontes,c210Query->CT3_DATA,c210Query->CT3_MOEDA,cTpSaldo,dDataLP,;				
		@cLote,cSubLote,@cDoc,cHP,cDescHP,c210Query->RECNO,@nLinha,lMoedaEsp,@cChaveAntD,@cChaveAntC,lCadastro,@cSeqLin,@cLinhaAnt,lJaExec,@cLinha,nIndTmp,lGrvM1Zer,lSldRes)
		cEntidAnt	:= c210Query->CT3_CUSTO+c210Query->CT3_CONTA					
	ElseIf cAlias == 'CT7'				
		Ct210Atual('CT7',,,,c210Query->CT7_CONTA,c210Query->CT7_ATUDEB,c210Query->CT7_ATUCRD,lPontes,c210Query->CT7_DATA,c210Query->CT7_MOEDA,cTpSaldo,dDataLP,;				
		@cLote,cSubLote,@cDoc,cHP,cDescHP,c210Query->RECNO,@nLinha,lMoedaEsp,@cChaveAntD,@cChaveAntC,lCadastro,@cSeqLin,@cLinhaAnt,lJaExec,@cLinha,nIndTmp,lGrvM1Zer,lSldRes)
		cEntidAnt	:= c210Query->CT7_CONTA					
	EndIf
	dbSelectArea('c210Query')
	dbSkip()
	If cAlias == "CTI"
		cEntidAtu	:= c210Query->CTI_CLVL+c210Query->CTI_ITEM+c210Query->CTI_CUSTO+c210Query->CTI_CONTA		 							
		cMoedaAtu	:= c210Query->CTI_MOEDA
	ElseIf cAlias == "CT4"
		cEntidAtu	:= c210Query->CT4_ITEM+c210Query->CT4_CUSTO+c210Query->CT4_CONTA									
		cMoedaAtu	:= c210Query->CT4_MOEDA					
	ElseIf cAlias == "CT3"
		cEntidAtu	:= c210Query->CT3_CUSTO+c210Query->CT3_CONTA													
		cMoedaAtu	:= c210Query->CT3_MOEDA					
	ElseIf cAlias == "CT7"
		cEntidAtu	:= c210Query->CT7_CONTA
		cMoedaAtu	:= c210Query->CT7_MOEDA																		
	EndIf
	lFirst	:= .F.			
	oObj:IncRegua1(OemToAnsi(STR0005))//Selecionando Registros... 		 		
End	 		
If ( Select ( "c210Query" ) <> 0 )
	dbSelectArea ( "c210Query" )
	dbCloseArea ()
Endif
	
RestArea(aSaveArea)  
Return	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct210Atual³ Autor ³ Simone Mie Sato       ³ Data ³ 02.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os lancamentos contabeis de zeramento e atualiza saldo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210Atual()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct210Atual())                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct210Atual(cAlias,cClVl,cItem,cCusto,cConta,nAtuDeb,nAtuCrd,lPontes,;
		dData,cMoeda,cTpSaldo,dDataLP,cLote,cSubLote,cDoc,cHP,cDescHP,nRec,nLinha,;
		lMoedaEsp,cChaveAntD,cChaveAntC,lCadastro,cSeqLin,cLinhaAnt,lJaExec,cLinha,nIndTmp,lGrvM1Zer,lSldRes)

Local aSaveArea	:= GetArea()		
Local cClVlPon	:= ""
Local cItemPon	:= ""
Local cCCPon	:= ""
Local cCtaPon	:= ""
Local cClVlLP	:= ""
Local cItemLP	:= ""
Local cCCLP		:= ""
Local cCtaLP	:= ""
Local lClVlOk	:= .T.
Local lItemOk	:= .T.
Local lCCOk		:= .T.
Local lCtaOk	:= .T.
Local cDigPon	:= ""
Local cDigLP	:= ""
Local lHaItem	:= .F.
Local lHaCusto	:= .F.
Local aGrvLan	:= {}			//Guarda as informacoes a serem gravadas no arq. temporario
Local nTotLPDeb := 0 			//Total debito-conta ponte ou conta de apuracao de resultado
Local nTotLPCrd	:= 0			//Total credito-conta ponte ou conta de apuracao de resultado
Local aArqs		:= {}			//Arquivos a serem atualizados
Local nSldAntDeb:= 0			//Saldo anterior debito 
Local nSldAntCrd:= 0			//Saldo anterior credito
Local lZera		:= .F. 		//Se os saldos das entidades abaixo do origem foram zerados, atualizar flag
Local nRecno	:= 0
Local nVlrLanc	:= 0	   		//Valor do lancamento  
Local aCriter	:= {}         
Local aCritLP	:= {}
Local aCritPon	:= {}                   
Local nVlDebCTZ	:= 0		//Valor Debito do CTZ
Local nVlCrdCTZ	:= 0		//Valor Credito do CTZ
Local nContador
Local cFilArqs	:= ""
Local lCtbCCLP	:= Iif(ExistBlock("CTB210CC"),.T.,.F.)
Local lCtbItLP 	:= Iif(ExistBlock("CTB210IT"),.T.,.F.)
Local lCtbCVLP 	:= Iif(ExistBlock("CTB210CV"),.T.,.F.)
Local lCTB210GR := ExistBlock("CTB210GR")

cClVl	:= Iif(cClVl == Nil,Space(Len(CTH->CTH_CLVL)),cClVl)
cItem	:= Iif(cItem == Nil,Space(Len(CTD->CTD_ITEM)),cItem)
cCusto	:= Iif(cCusto == Nil,Space(Len(CTT->CTT_CUSTO)),cCusto)

DEFAULT lGrvM1Zer := .F.
DEFAULT lSldRes	  := .F.

//Adiciono ao aArqs todos os arquivos a serem atualizados. 
If cAlias == 'CTI'
	Aadd(aArqs,'CTI')
	Aadd(aArqs,'CT4')
	Aadd(aArqs,'CT3')
	Aadd(aArqs,'CT7')
ElseIf cAlias == 'CT4'	
	Aadd(aArqs,'CT4')
	Aadd(aArqs,'CT3')
	Aadd(aArqs,'CT7')
ElseIf cAlias == 'CT3'
	Aadd(aArqs,'CT3')
	Aadd(aArqs,'CT7')	
ElseIf cAlias == 'CT7'
	Aadd(aArqs,'CT7')
EndIf                                           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se tiver Item, verifico se o Item Ponte e o Item Luc/Perd estao	 ³
//³preenchidos. 													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAlias $ 'CTI/CT4'  
	If !Empty(cItem)
		lHaItem := .T.				
		If !lCadastro
			cItemPon	:= mv_par18
			cItemLP		:= mv_par19
		EndIf
		Ct210ValIt(cItem,@cItemPon,@cItemLP,lPontes,@lItemOk,lCadastro)						
	EndIf	
EndIf
						 	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se tiver C.Custo, verifico se o C.Custo Ponte e o C.Custo Luc/Perd³
//³estao preenchidos. 												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAlias $ 'CTI/CT4/CT3'
	If !Empty(cCusto)
		lHaCusto	:= .T.					
		If !lCadastro
			cCCPon	:= mv_par16
			cCCLP	:= mv_par17		
		EndIf		
		Ct210ValCC(cCusto,@cCCPon,@cCCLP,lPontes,@lCCOk,lCadastro)											
	EndIf 
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se a cl.valor ponte e cl.valor de LP estao preenchidas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAlias == 'CTI'
	If !lCadastro
		cClVlPon	:= mv_par20
		cClVlLP		:= mv_par21 	
	EndIf
	Ct210ValCV(cClVl,@cClVlPon,@cClVlLP,lPontes,@lClVlOk,lCadastro)  	
EndIf	
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se a conta ponte a conta de LP estao preenchidas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCadastro
	cCtaPon	:= mv_par14
	cCtaLP	:= mv_par15	
EndIf
Ct210ValCt(cConta,@cCtaPon,@cDigPon,@cCtaLP,@cDigLP,lPontes,@lCtaOk,@aCriter,@aCritPon,@aCritLP,lCadastro)  				


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se estiverem ok, gravo os lancamentos e atualizo saldos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCtaOk 									 	
	//Se atualiza saldo por Classe de Valor
	If cAlias == 'CTI' .And. lCLVLOk 
		aGrvLan := {}	
		AAdd(aGrvLan,cClVl)	
		If lHaItem .And. lItemOk
			AAdd(aGrvLan,cItem)    
		Else
			AAdd(aGrvLan,"")	
		EndIf
		If lHaCusto .And. lCCOk
			AAdd(aGrvLan,cCusto)	
		Else                        
			AAdd(aGrvLan,"")		
		EndIf    
		If lCtaOk
			AAdd(aGrvLan,cConta)
		Else                    
			AAdd(aGrvLan,"")	
		EndIf
		AAdd(aGrvLan,dData)	
		AAdd(aGrvLan,cMoeda)
		AAdd(aGrvLan,cTpSaldo)
	ElseIf cAlias == 'CT4' .And. lHaItem .And. lItemOk
		aGrvLan := {}	
		AAdd(aGrvLan,"")   
		AAdd(aGrvLan,cItem)
		If lHaCusto .and. lCCOk
			AAdd(aGrvLan,cCusto)
		Else                    
			AAdd(aGrvLan,"")			
		EndIf
		AAdd(aGrvLan,cConta)
		AAdd(aGrvLan,dData)	
		AAdd(aGrvLan,cMoeda)
		AAdd(aGrvLan,cTpSaldo)
	ElseIf cAlias == 'CT3' .And. lHaCusto .And. lCCOk
		aGrvLan := {}	
		AAdd(aGrvLan,"")
		AAdd(aGrvLan,"")
		AAdd(aGrvLan,cCusto)           
		AAdd(aGrvLan,cConta)
		AAdd(aGrvLan,dData)	
		AAdd(aGrvLan,cMoeda)
		AAdd(aGrvLan,cTpSaldo)
	ElseIf cAlias == 'CT7' .And. lCtaOk
		aGrvLan := {}	
		AAdd(aGrvLan,"")
		AAdd(aGrvLan,"")
		AAdd(aGrvLan,"")
		AAdd(aGrvLan,cConta)
		AAdd(aGrvLan,dData)	
		AAdd(aGrvLan,cMoeda)
		AAdd(aGrvLan,cTpSaldo)
	EndIf 

	If lCtbCCLP	
		cCCLP	:= ExecBlock("CTB210CC",.F.,.F.,{mv_par17})
	EndIf      
	
	If lCtbItLP
		cItemLP	:= ExecBlock("CTB210IT",.F.,.F.,{mv_par19})
	EndIf
	
	If lCtbCVLP
		cClVlLP	:= ExecBlock("CTB210CV",.F.,.F.,{mv_par21})
	EndIf

	If len(aGrvLan) <> 0
	
		For nContador := 1 to len(aArqs)
			If nContador == 1  
				//Calcula o valor a ser zerado
				C210CalSld(@aGrvLan,dDataLP,cAlias,nAtuDeb,nAtuCrd,lPontes,cClVlPon,cItemPon,cCCPon,cCtaPon,lJaExec,lSldRes)
				If lPontes
					//Chama a rotina para trazer qual o valor ja zerado para a conta. 
					Ct210ClCTZ(@nVlDebCTZ,@nVlCrdCTZ,cAlias,aGrvLan,dDataLP,.F.,.F.)		
				Endif

				//Grava o lancamento de zeramento
				If (aGrvLan[8] - nVlDebCTZ # 0 .or. aGrvLan[9] - nVlCrdCTZ # 0)		
					C210GrvLan(aGrvLan,lPontes,cClVlPon,cClVlLP,cItemPon,cItemLP,cCCPon,cCCLP,cCtaPon,cDigPon,cCtaLP,cDigLP,dDataLP,@nTotLPDeb,@nTotLPCrd,@cLote,cSubLote,@cDoc,cHP,cDescHP,@nLinha,nAtuDeb,nAtuCrd,@nVlrLanc,aCriter,aCritPon,aCritLP,lMoedaEsp,;
					@cChaveAntD,@cChaveAntC,nVlCrdCTZ,nVlDebCTZ,@cLinha,nIndTmp,lGrvM1Zer) 
					
					
					If lCTB210GR
						ExecBlock("CTB210GR",.F.,.F.,{aArqs[nContador],aGrvLan})
					EndIf
					
					//Conta Ponte => os valores sao gravados no arquivo CTZ			
					If lPontes
						              
						If (aGrvLan[9]- nVlDebCTZ) - (aGrvLan[8]-nVlCrdCTZ) < 0
							Ct210GrCTZ("2",aGrvLan,@cSeqLin,nVlCrdCTZ,nVlDebCTZ,@cLinhaAnt)	
							cSeqLin := Soma1(cSeqLin)
						EndIf          

						If (aGrvLan[9]- nVlDebCTZ) - (aGrvLan[8]-nVlCrdCTZ) > 0
							Ct210GrCTZ("1",aGrvLan,@cSeqLin,nVlCrdCTZ,nVlDebCTZ,@cLinhaAnt)	
							cSeqLin := Soma1(cSeqLin)
						EndIf						
					EndIf					
				EndIf
			ElseIf nContador > 1           
					If (aArqs[nContador] == 'CT4' .And. lHaItem .And. lItemOk) .Or. ;				
					   (aArqs[nContador] == 'CT3' .And. lHaCusto .And. lCCOk).Or. ;
					   (aArqs[nContador] == 'CT7') 
						//Recupera o saldo anterior 								
						Ct210SlAnt(aArqs[nContador],dDataLP,@nSldAntDeb,@nSldAntCrd,aGrvLan[1],aGrvLan[2],aGrvLan[3],aGrvLan[4],cMoeda,cTpSaldo)		
					EndIf		
			EndIf
       	                                
			If lPontes    
//				If aArqs[nContador] <> 'CTI'
					//Se for zeramento com conta ponte, gravo no arquivo de trabalho
					//somente se for diferente de CTI
  //					Ct210GrTrb(aGrvLan,aArqs[nContador])
//				EndIf
			
				If nContador == 1 .Or. (nContador > 1 .And.  ;                                      
					(aArqs[nContador] == 'CT4' .And. lHaItem .And. lItemOk) .Or. ;				
					(aArqs[nContador] == 'CT3' .And. lHaCusto .And. lCCOk).Or. ;
					(aArqs[nContador] == 'CT7')) 
					//Recupera o saldo anterior 									
					Ct210SlAnt(aArqs[nContador],dDataLP,@nSldAntDeb,@nSldAntCrd,cClVlPon,cItemPon,cCCPon,cCtaPon,cMoeda,cTpSaldo)			
				EndIf
			EndIf
			
			If nContador == 1 .Or. (nContador > 1 .And.  ;                                      
					(aArqs[nContador] == 'CT4' .And. lHaItem .And. lItemOk) .Or. ;				
					(aArqs[nContador] == 'CT3' .And. lHaCusto .And. lCCOk) .Or.;
					(aArqs[nContador] == 'CT7'))              
				//Gravar o saldo
				C210GrvSld(aGrvLan,dDataLP,aArqs[nContador],nAtudeb,nAtuCrd,.F.,lPontes,cClVlPon,cClVlLP,cItemPon,cItemLP,cCCPon,cCCLP,cCtaPon,cDigPon,cCtaLP,cDigLP,nSldAntDeb,nSldAntCrd,nVlrLanc,nContador,lJaExec)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizo o arq.de saldos com a data de apuracao e com o flag.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(aArqs[nContador])	 	
		
			If nContador == 1
				dbGoto(nRec)			
			Else //Se estiver atualizando os saldos abaixo do origem				
				If	(aArqs[nContador] == 'CT4' .And. lHaItem .And. lItemOk) .Or. ;				
					(aArqs[nContador] == 'CT3' .And. lHaCusto .And. lCCOk) .Or.;
					(aArqs[nContador] == 'CT7')		
					//Verifico se zerou os saldos das entidades abaixo do origem
				 	C210Zerado(aGrvLan,aArqs[nContador],dDataLP,@lZera,@nRecno,lPontes)						
				 	If !lPontes
	 					dbGoto(nRecno)
	 				EndIf
 				EndIf
			EndIf

		    If nContador == 1 .Or. (((!lPontes .And. nContador > 1 .And. nRecno > 0 .And. lZera) .Or.  ;
				 (lPontes .And. nContador > 1 .And. lZera))   .And. ;
				 ((aArqs[nContador] == 'CT4' .And. lHaItem .And. lItemOk) .Or. ;				
				 (aArqs[nContador] == 'CT3' .And. lHaCusto .And. lCCOk) .Or. ;									
				 (aArqs[nContador] == 'CT7'))) 

            	If Empty(xFilial("CT2"))
					cFilArqs	:= "  "
				Else	
					cFilArqs	:= cFilAnt
				EndIf				 
				 
				//Atualizo o flag ref. lucros e perdas com data anterior ao zeramento.
				Do Case
				Case (aArqs[nContador]) == 'CT7'
					Ct190FlgLP(cFilArqs, 'CT7', aGrvLan[4],,,,aGrvLan[5], aGrvLan[7], dDataLP, aGrvLan[6])					
				Case (aArqs[nContador]) == 'CT3'
					Ct190FlgLP(cFilArqs, 'CT3', aGrvLan[4],aGrvLan[3],,, aGrvLan[5], aGrvLan[7], dDataLP, aGrvLan[6])					
				Case (aArqs[nContador]) == 'CT4'
					Ct190FlgLP(cFilArqs, 'CT4', aGrvLan[4],aGrvLan[3],aGrvlan[2],, aGrvLan[5], aGrvLan[7], dDataLP, aGrvLan[6])					
				Case (aArqs[nContador]) == 'CTI'
					Ct190FlgLP(cFilArqs, 'CTI', aGrvLan[4],aGrvLan[3],aGrvlan[2],aGrvLan[1], aGrvLan[5], aGrvLan[7], dDataLP, aGrvLan[6])					
				EndCase
			EndIf		 					
		
			If nContador == 1 .Or. (nContador > 1 .And.  ;                                      
				((aArqs[nContador] == 'CT4' .And. lHaItem .And. lItemOk) .Or. ;				
				(aArqs[nContador] == 'CT3' .And. lHaCusto .And. lCCOk) .Or. ;									
				(aArqs[nContador] == 'CT7'))) 
        	
				//Verifica qual o saldo anterior das contas de L/P. 			
				Ct210SlAnt(aArqs[nContador],dDataLP,@nSldAntDeb,@nSldAntCrd,cClVlLP,cItemLP,cCCLP,cCtaLP,cMoeda,cTpSaldo)		
		
		   		//Gravar saldo das contas de L/P. 		
				C210GrvSld(aGrvLan,dDataLP,aArqs[nContador],nAtudeb,nAtuCrd,.T.,lPontes,cClVlPon,cClVlLP,cItemPon,cItemLP,cCCPon,cCCLP,cCtaPon,cDigPon,cCtaLP,cDigLP,nSldAntDeb,nSldAntCrd,nVlrLanc,nContador)
			EndIf		
		Next		
	EndIf
EndIf
RestArea(aSaveArea)

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C210GrvLan³ Autor ³ Simone Mie Sato       ³ Data ³ 06.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava os lancamentos de zeramento no arquivo CT2.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C210GrvLan									      		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C210GrvLan(aGrvLan,lPontes,cClVlPon,cClVlLP,cItemPon,cItemLP,cCCPon,cCCLP,;
	cCtaPon,cDigPon,cCtaLP,cDigLP,dDataLP,nTotLPDeb,nTotLPCrd,cLote,cSubLote,cDoc,;
	cHP,cDescHP,nLinha,nAtuDeb,nAtuCrd,nVlrLanc,aCriter,aCritPon,aCritLP,lMoedaEsp,;
	cChaveAntD,cChaveAntC,nVlCrdCTZ,nVlDebCTZ,cLinha,nIndTmp,lGrvM1Zer)
	
Local cChave	:= ""
Local aTamCTI 	:=	TamSX3("CTI_CLVL")
Local aTamCT4	:=	TamSX3("CT4_ITEM")
Local aTamCT3	:=	TamSX3("CT3_CUSTO")
Local nTamCTI	:=	aTamCTI[1]
Local nTamCT4	:=	aTamCT4[1]
Local nTamCT3	:=	aTamCT3[1]
Local cClvl		:= ""
Local cItem		:= ""
Local cCusto	:= ""
Local cConta	:= ""                       
Local cMoeda	:= ""
Local cTpSaldo	:= ""
Local CTF_LOCK	:= 0
Local lPonteOk	:= .F.
Local lExistDoc	:= .F.
Local nMaxLinha	:= GetMv("MV_NUMMAN")                                 
Local nRecCT2:= 0

DEFAULT	nVlCrdCTZ	:= 0
DEFAULT nVlDebCTZ	:= 0
DEFAULT lGrvM1Zer := .F.
		
//Se nVlrLanc for > 0 devera ser feito um lancamento a debito na conta a ser zerada.
nVlrLanc := (aGrvLan[9]- nVlDebCTZ) - (aGrvLan[8]-nVlCrdCTZ)

If Empty(aGrvLan[1])
	cClVl	:= Space(nTamCTI)	     
Else                                                                        
	If lPontes .And. ! Empty(cClVlPon)		//Se estiver usando entidade ponte
		cClVl	:= cClVlPon	
	Else
		cClvl 	:= aGrvLan[1]
	EndIf
Endif                     
	
If Empty(aGrvLan[2])
	cItem	:= Space(nTamCT4)	     
Else                 
	If lPontes .And. ! Empty(cItemPon) 				//Se estiver usando entidade ponte 
		cItem 	:= cItemPon	
	Else
		cItem	:= aGrvLan[2]
	EndIf
Endif                     

If Empty(aGrvLan[3])
	cCusto	:= Space(nTamCT3)	     
Else
	If lPontes .And. ! Empty(cCcPon) 				//Se estiver usando entidade ponte 
		cCusto 	:= cCCPon		
	Else                 
		cCusto 	:= aGrvLan[3]                                      
	EndIf
Endif   
                       
If lPontes .And. ! Empty(cCtaPon) 				//Se estiver usando entidade ponte 
	cConta	:= cCtaPon			
Else
	cConta := aGrvLan[4]           
EndIf

cMoeda	 	:= aGrvLan[6]	 
cTpSaldo	:= aGrvLan[7]

dbSelectArea("CT2")
cChave	:= xFilial("CT2")+dtos(dDataLP)+'3'+cClVl+cItem+cCusto+cConta+cTpSaldo+cMoeda                  

If (Round(NoRound(nVlrLanc,3),2)) < 0
	
	//SE FOR CONTA PONTE, OS LANCAMENTOS SERAO AGLUTINADOS !!!!
	If lMoedaEsp .Or. (lPontes .And. !lMoedaEsp)
		nRecCT2	:= 	Ctb210Seek(dDataLp,cClVl,cItem,cCusto,cConta,cMoeda,cTpSaldo,"2")
		If nRecCT2 > 0 
			dbGoto(nRecCT2)				
			lPonteOk	:= .T.
		EndIf
		
		//Se achou registro com a mesma chave, verificar se eh o numero de documento desejado.		
		If lMoedaEsp .And. lPonteOk
			While !Eof() .And. (cChave == CT2->(CT2_FILIAL+dtos(CT2_DATA)+CT2_DC+CT2_CLVLCR+CT2_ITEMC+CT2_CCC+CT2_CREDIT))
                If Dtos(dDataLP) == Dtos(CT2->CT2_DATA) .And. cLote == CT2->CT2_LOTE .And. cSubLote == CT2->CT2_SBLOTE .And.;
                   cDoc == CT2->CT2_DOC .And. aGrvLan[7] == CT2->CT2_TPSALD
                   lExistDoc	:= .T. 
                   Exit
                EndIf					
				dbSkip()
				Loop
			EndDo
		EndIf
	Endif                      
	
	If (!lPontes .And. cChave <> cChaveAntD) .Or. (lPontes .And. !lPonteOk) .Or. (lMoedaEsp .And. lPontes .And. lPonteOk .And. !lExistDoc)
	
			If cMoeda ='01'		
				// Grava numero da ultima linha no arquivo de controle (CTF)			
				dbSelectArea("CTF")                    
				If MsSeek(xFilial("CTF")+Dtos(dDataLP)+cLote+cSubLote+cDoc)
					RecLock("CTF")
				Else
					RecLock("CTF",.T.)
					Replace CTF_FILIAL 	With xFilial()
					Replace CTF_LOTE	With cLote
					Replace CTF_SBLOTE	With cSubLote
					Replace CTF_DOC		With cDoc
					Replace CTF_DATA	With dDataLp
				EndIf		
				Replace CTF_LINHA With CT2->CT2_LINHA
				MsUnlock()                                 		
			EndIf

			dbSelectArea("CT2")                        		
	
			If nLinha == nMaxLinha	//Se nLinha for igual ao conteudo do parametro MV_NUMMAN,implementa 1 no documento. 
				If (!lMoedaEsp .And. cMoeda = '01') .Or. lMoedaEsp					
					If !C102ProxDoc(dDataLP,cLote,@cSubLote,@cDoc,,,,@CTF_LOCK) .And. cDoc == '999999'	//Se o documento for igual a 999999 implementa 1 no lote.		
						cLote	:= StrZero((Val(cLote)+1),6)	
						cDoc	:= '000001'
						LockDoc(dDataLP,cLote,cSubLote,cDoc, @CTF_LOCK )		
					EndIf  
					cLinha := '000'
					nLinha := 0			            
				EndIf
			EndIf	

 			If (!lMoedaEsp .And. cMoeda = '01') .Or. lMoedaEsp .Or. lGrvM1Zer 
				nLinha++		       
				cLinha := Soma1(cLinha)				
			EndIf

			/// VERIFICA EXISTENCIA DO DOCUMENTO NO CT2 PARA EVITAR DUPLICIDADE
			nRecCt2Atu := CT2->(Recno())
			nOrdCt2Atu := CT2->(IndexOrd())

			dbSelectArea("CT2")
			dbSetOrder(1)
			While MsSeek(xFilial("CT2")+DTOS(dDataLp)+cLote+cSubLote+cDoc+cLinha+aGrvLan[7]+cEmpAnt+cFilAnt+cMoeda,.F.)
				cLinha := Soma1(cLinha)
				nLinha++
				If nLinha >= nMaxLinha
					If !C102ProxDoc(dDataLP,cLote,@cSubLote,@cDoc,,,,@CTF_LOCK) .And. cDoc == '999999'	//Se o documento for igual a 999999 implementa 1 no lote.		
						cLote	:= StrZero((Val(cLote)+1),6)	
						cDoc	:= '000001'
						LockDoc(dDataLP,cLote,cSubLote,cDoc, @CTF_LOCK )		
					EndIf  
					cLinha := '001'
					nLinha := 1
				EndIf			            
			EndDo
			
			CT2->(dbSetOrder(nOrdCt2Atu))
			CT2->(MsGoTo(nRecCt2Atu))


			//Se estiver fazendo a apuracao de lucros/perdas para uma moeda especifica diferente da 01, gravar o lancamento
			//na moeda 01 zerado. 
			If ( lMoedaEsp .And. 	cMoeda <>'01' )  .Or. lGrvM1Zer 
				nRecCt2Atu := CT2->(Recno())
				nOrdCt2Atu := CT2->(IndexOrd())
				dbSelectArea("CT2")
				dbSetOrder(1)
				If !MsSeek(xFilial("CT2")+DTOS(dDataLp)+cLote+cSubLote+cDoc+cLinha+aGrvLan[7]+cEmpAnt+cFilAnt+"01",.F.)
									
					Reclock("CT2",.T.)
					CT2->CT2_FILIAL		:= xFilial("CT2")
					CT2->CT2_DATA		:= dDataLP
					CT2->CT2_LOTE		:= cLote
					CT2->CT2_SBLOTE		:= cSubLote
					CT2->CT2_DOC		:= cDoc
					CT2->CT2_LINHA		:= cLinha
					CT2->CT2_DC			:= '3'	//Tipo de lancamento Partida Dobrada
					CT2->CT2_DEBITO		:=	cCtaLP
					CT2->CT2_DCD		:=	cDigLp
					CT2->CT2_CCD		:=	cCCLP
					CT2->CT2_ITEMD		:=	cItemLP
					CT2->CT2_CLVLDB		:=	cClVlLP
					CT2->CT2_CRCONV		:= "5"	//A moeda 01 eh zerada
					If lPontes		         
						CT2->CT2_CREDIT		:= cCtaPon
						CT2->CT2_DCC		:= cDigPon
						CT2->CT2_CCC		:=	cCCPon
						CT2->CT2_ITEMC		:=	cItemPon
						CT2->CT2_CLVLCR		:=	cClVlPon
					Else
						CT2->CT2_CREDIT		:=	aGrvLan[4]
						dbSelectArea("CT1")
						dbSetOrder(1)
						MsSeek(xFilial("CT1")+CT2->CT2_CREDIT)
						If found()
							CT2->CT2_DCC		:= CT1->CT1_DC
						Endif
						dbSelectArea("CT2")
						CT2->CT2_CCC					:=	aGrvLan[3]
						CT2->CT2_ITEMC					:=	aGrvLan[2]
						CT2->CT2_CLVLCR					:=	aGrvLan[1]
					EndIf
					CT2->CT2_MOEDLC					:=	'01'
					CT2->CT2_TPSALD					:=	aGrvLan[7]
					CT2->CT2_VALOR					:=	0	//Valor Zerado
					CT2->CT2_HP			  			:=	cHP
					CT2->CT2_HIST					:=	cDescHP
					CT2->CT2_EMPORI					:=	cEmpAnt
					CT2->CT2_FILORI					:= 	cFilAnt
					CT2->CT2_MANUAL					:= '1'
					CT2->CT2_ROTINA					:= 'CTBA210'
					CT2->CT2_AGLUT					:= '2'
					CT2->CT2_SEQHIS					:= '001'
					CT2->CT2_SEQLAN					:= CT2->CT2_LINHA
					CT2->CT2_DTLP	 				:= dDataLP
					CT2->CT2_SLBASE					:= 'S'
					MsUnlock()
					CT2->(dbCommit())
				EndIf
				CT2->(dbSetOrder(nOrdCt2Atu))
				CT2->(MsGoTo(nRecCt2Atu))
			EndIf			
			//Novo Reclock para gravar o registro da moeda especifica				
			Reclock("CT2",.T.)
			CT2->CT2_FILIAL		:= xFilial("CT2")
			CT2->CT2_DATA		:= dDataLP
			CT2->CT2_LOTE		:= cLote
			CT2->CT2_SBLOTE		:= cSubLote
			CT2->CT2_DOC		:= cDoc
			CT2->CT2_LINHA		:= cLinha
			CT2->CT2_DC			:= '3'	//Tipo de lancamento Partida Dobrada
			CT2->CT2_DEBITO		:=	cCtaLP
			CT2->CT2_DCD		:=	cDigLp
			CT2->CT2_CCD		:=	cCCLP
			CT2->CT2_ITEMD		:=	cItemLP
			CT2->CT2_CLVLDB		:=	cClVlLP
			If cMoeda = '01'
	    		CT2->CT2_CRCONV	:= "1"
	  		Else
				CT2->CT2_CRCONV	:= '4'	//O critero de conversao eh informado
	  		EndIf
			If lPontes		         
				CT2->CT2_CREDIT		:= cCtaPon
				CT2->CT2_DCC		:= cDigPon
				CT2->CT2_CCC		:=	cCCPon
				CT2->CT2_ITEMC		:=	cItemPon
				CT2->CT2_CLVLCR		:=	cClVlPon
			Else
				CT2->CT2_CREDIT		:=	aGrvLan[4]
				dbSelectArea("CT1")
				dbSetOrder(1)
				MsSeek(xFilial("CT1")+CT2->CT2_CREDIT)
				If found()
					CT2->CT2_DCC		:= CT1->CT1_DC
				Endif
				dbSelectArea("CT2")
				CT2->CT2_CCC					:=	aGrvLan[3]
				CT2->CT2_ITEMC					:=	aGrvLan[2]
				CT2->CT2_CLVLCR					:=	aGrvLan[1]
			EndIf
			CT2->CT2_MOEDLC					:=	cMoeda
			CT2->CT2_TPSALD					:=	aGrvLan[7]
			CT2->CT2_VALOR					:=	Abs(nVlrLanc)
			CT2->CT2_HP			  			:=	cHP
			CT2->CT2_HIST					:=	cDescHP
			CT2->CT2_EMPORI					:=	cEmpAnt
			CT2->CT2_FILORI					:= 	cFilAnt
			CT2->CT2_MANUAL					:= '1'
			CT2->CT2_ROTINA					:= 'CTBA210'
			CT2->CT2_AGLUT					:= '2'
			CT2->CT2_SEQHIS					:= '001'
			CT2->CT2_SEQLAN					:= CT2->CT2_LINHA
			CT2->CT2_DTLP	 				:= dDataLP
			CT2->CT2_SLBASE					:= 'S'
			MsUnlock()
			CT2->(dbCommit())
			nTotLPDeb			 			+= CT2->CT2_VALOR
			
	Else
		RecLock("CT2",.F.)                              
		If lPontes	                                     
			CT2->CT2_VALOR					+= Abs(nVlrLanc)
			lPonteOk	:= .F.
		Else		
			CT2->CT2_VALOR					:= Abs(nVlrLanc)
		EndIf
		MsUnlock()
	Endif			
	cChaveAntD	:= xFilial("CT2")+DTOS(CT2->CT2_DATA)+'3'+CT2->CT2_CLVLCR+CT2->CT2_ITEMC+CT2->CT2_CCC+CT2->CT2_CREDIT+CT2->CT2_TPSALD+CT2->CT2_MOEDLC	
Endif
            
If (Round(NoRound(nVlrLanc,3),2)) > 0

	//SE FOR CONTA PONTE, OS LANCAMENTOS SERAO AGLUTINADOS !!!!
	If lMoedaEsp .Or. (lPontes .And. !lMoedaEsp)
		nRecCT2	:= 	Ctb210Seek(dDataLp,cClVl,cItem,cCusto,cConta,cMoeda,cTpSaldo,"1")
		If nRecCT2 > 0        
			dbGoto(nRecCT2)
			lPonteOk	:= .T.
		EndIf		
		//Se achou registro com a mesma chave, verificar se eh o numero de documento desejado.		
		If lMoedaEsp .And. lPonteOk
			While !Eof() .And. (cChave == CT2->(CT2_FILIAL+dtos(CT2_DATA)+CT2_DC+CT2_CLVLDB+CT2_ITEMD+CT2_CCD+CT2_DEBITO))
                If Dtos(dDataLP) == Dtos(CT2->CT2_DATA) .And. cLote == CT2->CT2_LOTE .And. cSubLote == CT2->CT2_SBLOTE .And.;
                   cDoc == CT2->CT2_DOC .And. aGrvLan[7] == CT2->CT2_TPSALD
                   lExistDoc	:= .T. 
                   Exit
                EndIf					
				dbSkip()
				Loop
			End
		EndIf
	Endif                      
	
	If (!lPontes .And. cChave <> cChaveAntC) .Or. (lPontes .And. !lPonteOk)  .Or. (lMoedaEsp .And. lPontes .And. lPonteOk .And. !lExistDoc)	//Se a chave for diferente, procuro no CT2.
			// Grava numero da ultima linha no arquivo de controle (CTF)			
			If cMoeda = '01'
				dbSelectArea("CTF")                    
				If MsSeek(xFilial("CTF")+Dtos(dDataLP)+cLote+cSubLote+cDoc)
					RecLock("CTF")
				Else
					RecLock("CTF",.T.)
					Replace CTF_FILIAL 	With xFilial()
					Replace CTF_LOTE	With cLote
					Replace CTF_SBLOTE	With cSubLote
					Replace CTF_DOC		With cDoc
					Replace CTF_DATA	With dDataLp
				EndIf		
				Replace CTF_LINHA With CT2->CT2_LINHA
				MsUnlock()                                 		
			EndIf

			dbSelectArea("CT2")           

			If nLinha == nMaxLinha	//Se nLinha for igual ao conteudo do parametro MV_NUMMAN,implementa 1 no documento. 
				If (!lMoedaEsp .And. cMoeda = '01') .Or. lMoedaEsp							
					If !C102ProxDoc(dDataLP,cLote,@cSubLote,@cDoc,,,,@CTF_LOCK) .And. cDoc == '999999'	//Se o documento for igual a 999999 implementa 1 no lote.								
						cLote	:= StrZero((Val(cLote)+1),6)	
						cDoc	:= '000001'
						LockDoc(dDataLP,cLote,cSubLote,cDoc, @CTF_LOCK )		
					EndIf  
					nLinha	:= 0			            
					cLinha	:= '000'
				EndIf	
			EndIf

			If (!lMoedaEsp .And. cMoeda = '01') .Or. lMoedaEsp	.Or. lGrvM1Zer
				nLinha++		
				cLinha	:= Soma1(cLinha)
			EndIf

			/// VERIFICA EXISTENCIA DO DOCUMENTO NO CT2 PARA EVITAR DUPLICIDADE
			nRecCt2Atu := CT2->(Recno())
			nOrdCt2Atu := CT2->(IndexOrd())

			dbSelectArea("CT2")
			dbSetOrder(1)
			While MsSeek(xFilial("CT2")+DTOS(dDataLp)+cLote+cSubLote+cDoc+cLinha+aGrvLan[7]+cEmpAnt+cFilAnt+cMoeda,.F.)
				cLinha := Soma1(cLinha)
				nLinha++
				If nLinha >= nMaxLinha
					If !C102ProxDoc(dDataLP,cLote,@cSubLote,@cDoc,,,,@CTF_LOCK) .And. cDoc == '999999'	//Se o documento for igual a 999999 implementa 1 no lote.		
						cLote	:= StrZero((Val(cLote)+1),6)	
						cDoc	:= '000001'
						LockDoc(dDataLP,cLote,cSubLote,cDoc, @CTF_LOCK )		
					EndIf  
					cLinha := '001'
					nLinha := 1
				EndIf			            
			EndDo
			
			CT2->(dbSetOrder(nOrdCt2Atu))
			CT2->(MsGoTo(nRecCt2Atu))

			//Se estiver fazendo a apuracao de lucros/perdas para uma moeda especifica diferente da 01, gravar o lancamento
			//na moeda 01 zerado. 
			If ( lMoedaEsp .And. cMoeda <>'01' ) .Or. lGrvM1Zer 
				nRecCt2Atu := CT2->(Recno())
				nOrdCt2Atu := CT2->(IndexOrd())
				dbSelectArea("CT2")
				dbSetOrder(1)
				If !MsSeek(xFilial("CT2")+DTOS(dDataLp)+cLote+cSubLote+cDoc+cLinha+aGrvLan[7]+cEmpAnt+cFilAnt+"01",.F.)
					Reclock("CT2",.T.)
					CT2->CT2_FILIAL		:= xFilial("CT2")
					CT2->CT2_DATA		:= dDataLP
					CT2->CT2_LOTE		:= cLote
					CT2->CT2_SBLOTE		:= cSubLote
					CT2->CT2_DOC		:= cDoc
					CT2->CT2_LINHA		:= cLinha
					CT2->CT2_DC			:= '3'	//Tipo de lancamento Partida Dobrada
					CT2->CT2_CREDIT		:=	cCtaLP
					CT2->CT2_DCC		:= 	cDigLP
					CT2->CT2_CCC		:=	cCCLP
					CT2->CT2_ITEMC		:=	cItemLP
					CT2->CT2_CLVLCR		:=	cClVlLP
					CT2->CT2_CRCONV		:= "5"	//A moeda 01 eh zerada						
			 		If lPontes
						CT2->CT2_DEBITO		:=	cCtaPon
						CT2->CT2_DCD		:=	cDigPon
						CT2->CT2_CCD		:=	cCCPon
						CT2->CT2_ITEMD		:=	cItemPon
						CT2->CT2_CLVLDB		:=	cClVlPon				
					Else
						CT2->CT2_DEBITO		:=	aGrvLan[4]
						dbSelectArea("CT1")
						dbSetOrder(1)
						MsSeek(xFilial("CT1")+CT2->CT2_DEBITO)
						If found()
							CT2->CT2_DCD		:= CT1->CT1_DC
						Endif
						dbSelectArea("CT2")
						CT2->CT2_CCD					:=	aGrvLan[3]
						CT2->CT2_ITEMD					:=	aGrvLan[2]
						CT2->CT2_CLVLDB					:=	aGrvLan[1]
					EndIf
					CT2->CT2_MOEDLC					:=	'01'
					CT2->CT2_TPSALD					:=	aGrvLan[7]
					CT2->CT2_VALOR					:=	0	//Valor Zerado
					CT2->CT2_HP			  			:=	cHP
					CT2->CT2_HIST					:=	cDescHP
					CT2->CT2_EMPORI					:=	cEmpAnt
					CT2->CT2_FILORI					:= 	cFilAnt
					CT2->CT2_MANUAL					:= '1'
					CT2->CT2_ROTINA					:= 'CTBA210'
					CT2->CT2_AGLUT					:= '2'
					CT2->CT2_SEQHIS					:= '001'
					CT2->CT2_SEQLAN					:= CT2->CT2_LINHA
					CT2->CT2_DTLP	 				:= dDataLP
					CT2->CT2_SLBASE					:= 'S'
					MsUnlock()			
					CT2->(dbCommit())
				EndIf
				CT2->(dbSetOrder(nOrdCt2Atu))
				CT2->(MsGoTo(nRecCt2Atu))
			EndIf						
			//Novo Reclock para gravar o registro da moeda especifica				
			Reclock("CT2",.T.)
			CT2->CT2_FILIAL		:= xFilial("CT2")
			CT2->CT2_DC			:= '3'	//Tipo de lancamento especifico para lancamento de zeramento.
			CT2->CT2_DATA		:=	dDataLP
			CT2->CT2_LOTE		:=	cLote
			CT2->CT2_SBLOTE		:= 	cSubLote
			CT2->CT2_DOC		:=	cDoc
			CT2->CT2_LINHA		:=	cLinha
			CT2->CT2_CREDIT		:=	cCtaLP
			CT2->CT2_DCC		:= 	cDigLP
			CT2->CT2_CCC		:=	cCCLP
			CT2->CT2_ITEMC		:=	cItemLP
			CT2->CT2_CLVLCR		:=	cClVlLP
			
			If cMoeda = '01'
	    		CT2->CT2_CRCONV	:= "1"
  			Else
				CT2->CT2_CRCONV	:= '4'	//O critero de conversao eh informado
  			EndIf				
			
	 		If lPontes
				CT2->CT2_DEBITO		:=	cCtaPon
				CT2->CT2_DCD		:=	cDigPon
				CT2->CT2_CCD		:=	cCCPon
				CT2->CT2_ITEMD		:=	cItemPon
				CT2->CT2_CLVLDB		:=	cClVlPon
			Else
				CT2->CT2_DEBITO	   		:=	aGrvLan[4]
				dbSelectArea("CT1")
				dbSetOrder(1)
				MsSeek(xFilial("CT1")+CT2->CT2_DEBITO)
				If found()
					CT2->CT2_DCD		:= CT1->CT1_DC
				Endif
				CT2->CT2_CCD					:=	aGrvLan[3]
				CT2->CT2_ITEMD					:=	aGrvLan[2]
				CT2->CT2_CLVLDB					:=	aGrvLan[1]
								
				dbSelectArea("CT2")				
			EndIf                                       
			CT2->CT2_MOEDLC				:=	cMoeda    
			CT2->CT2_TPSALD					:=	aGrvLan[7]
			CT2->CT2_VALOR					:=	Abs(nVlrLanc)
			CT2->CT2_HP			  			:=	cHP
			CT2->CT2_HIST					:=	cDescHP
			CT2->CT2_EMPORI					:=	cEmpAnt
			CT2->CT2_FILORI					:= 	cFilAnt
			CT2->CT2_MANUAL					:= '1'
			CT2->CT2_ROTINA					:= 'CTBA210'
			CT2->CT2_AGLUT					:= '2'
			CT2->CT2_SEQHIS					:= '001'
			CT2->CT2_SEQLAN					:= CT2->CT2_LINHA
			CT2->CT2_DTLP					:= dDataLP
			CT2->CT2_SLBASE					:= 'S'		
			MsUnlock()                                    
			CT2->(dbCommit())
		
			nTotLPCrd 	+= CT2->CT2_VALOR		
	Else
		Reclock("CT2",.F.)                  
		If lPontes
			CT2->CT2_VALOR	+=	Abs(nVlrLanc)		
			lPonteOk	:= .F.			
		Else
			CT2->CT2_VALOR	:= Abs(nVlrLanc)
		EndIf
		MsUnlock()                        
	Endif			

	cChaveAntC	:= xFilial("CT2")+DTOS(CT2->CT2_DATA)+'3'+CT2->CT2_CLVLDB+CT2->CT2_ITEMD+CT2->CT2_CCD+CT2->CT2_DEBITO+CT2->CT2_TPSALD+CT2->CT2_MOEDLC
Endif
    
If nVlrLanc <> 0
	lGravouLan := .T.
	// Atualizo arquivo CTC - Saldos de Documento => Atualizo debito e credito, por ser
	//um lancamento tipo "3"
	If cMoeda == CT2->CT2_MOEDLC
		GravaCTC(CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,"1",CT2->CT2_DATA,cMoeda,Abs(nVlrLanc),CT2->CT2_TPSALD,,"+")
		GravaCTC(CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,"2",CT2->CT2_DATA,cMoeda,Abs(nVlrLanc),CT2->CT2_TPSALD,,"+")
	Endif
EndIf
	
//RestArea(aSaveArea)
	
Return
	
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C210GrvSld³ Autor ³ Simone Mie Sato       ³ Data ³ 06.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava os saldos de zeramento no arquivo CTZ.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C210GrvSld									      		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C210GrvSld(aGrvLan,dDataLP,cAlias,nAtuDeb,nAtucrd,lLP,lPontes,;
	cClVlPon,cClVlLP,cItemPon,cItemLP,cCCPon,cCCLP,cCtaPon,cDigPon,cCtaLP,cDigLP,;
	nSldAntDeb,nSldAntCrd,nVlrLanc,nCont)

Local aSaveArea :=	GetArea()
Local cChave 	:=	""

cCCLP	:= Iif(Empty(cCCLP),Space(Len(CT3->CT3_CUSTO)),cCCLP)
cCCPon	:= Iif(Empty(cCCPon),Space(Len(CT3->CT3_CUSTO)),cCCPon)            
cItemLP	:= Iif(Empty(cItemLP),Space(Len(CT4->CT4_ITEM)),cItemLP)
cItemPon:= Iif(Empty(cItemPon),Space(Len(CT4->CT4_ITEM)),cItemPon)
aGrvLan[3]	:= Iif(Empty(aGrvLan[3]),Space(Len(CT3->CT3_CUSTO)),aGrvLan[3])
aGrvLan[2]	:= Iif(Empty(aGrvLan[2]),Space(Len(CT4->CT4_ITEM)),aGrvLan[2])

If lLp //Se grava saldos de entidade de L/P
	Do Case
	Case cAlias == 'CTI'    
		cChave := cCtaLP+cCCLP+cItemLP+cClVlLP
		cChave += aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
	Case cAlias == 'CT4'
		cChave := cCtaLP+cCCLP+cItemLP
		cChave += aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
	Case cAlias == 'CT3'
		cChave := cCtaLP+cCCLP+aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
	Case cAlias == 'CT7'
		cChave := cCtaLP+aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
	EndCase	

Else
	If lPontes		//Se for entidade ponte
		Do Case
		Case cAlias == 'CTI'
			cChave := cCtaPon+cCCPon+cItemPon+cClVlPon
			cChave += aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
		Case cAlias == 'CT4'
			cChave := cCtaPon+cCCPon+cItemPon
			cChave += aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
		Case cAlias == 'CT3'
			cChave := cCtaPon+cCCPon+aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
		Case cAlias == 'CT7'
			cChave := cCtaPon+aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
		EndCase	                                                                  
	Else	//Se grava saldo das entidades a serem zeradas
		Do Case
		Case cAlias == 'CTI'						
			cChave := aGrvLan[4]+aGrvLan[3]+aGrvLan[2]+aGrvLan[1]
			cChave += aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
		Case cAlias == 'CT4'
			cChave := aGrvLan[4]+aGrvLan[3]+aGrvLan[2]
			cChave += aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
		Case cAlias == 'CT3'
			cChave := aGrvLan[4]+aGrvLan[3]+aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
		Case cAlias == 'CT7'
			cChave := aGrvLan[4]+aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)
		EndCase
	Endif
Endif
	         
dbSelectArea(cAlias)	
dbSetOrder(2)
If !MsSeek(xFilial(cAlias)+cChave+"Z")
	Reclock(cAlias,.T.)
	(cAlias)->&(cAlias+"_FILIAL")		:= xFilial(cAlias)
	If lLP //Se atualiza saldos entidades de L/P
		Do Case
		Case cAlias == 'CTI'		
			CTI->CTI_CLVL   	:=	cClVlLP
			CTI->CTI_ITEM		:= 	cItemLP
			CTI->CTI_CUSTO		:=	cCCLP
		Case cAlias == 'CT4'
			CT4->CT4_ITEM		:= 	cItemLP
			CT4->CT4_CUSTO		:=	cCCLP
		Case cAlias == 'CT3'
			CT3->CT3_CUSTO		:=	cCCLP
		EndCase		                                   
		(cAlias)->&(cAlias+"_CONTA")		:=	cCtaLP		
		(cAlias)->&(cAlias+"_ANTDEB")		:=	nSldAntDeb
		(cAlias)->&(cAlias+"_ANTCRD")		:=	nSldAntCrd				
		If nVlrLanc < 0  
			(cAlias)->&(cAlias+"_DEBITO")		:=	Abs(nVlrLanc)
		ElseIf nVlrLanc > 0
			(cAlias)->&(cAlias+"_CREDIT")		:=	Abs(nVlrLanc)
		EndIf                                                    
		(cAlias)->&(cAlias+"_ATUDEB")		:=	(cAlias)->&(cAlias+"_ANTDEB")+(cAlias)->&(cAlias+"_DEBITO")					
		(cAlias)->&(cAlias+"_ATUCRD")		:=	(cAlias)->&(cAlias+"_ANTCRD")+(cAlias)->&(cAlias+"_CREDIT")						
		If cAlias <> 'CT7'
			(cAlias)->&(cAlias+"_SLCOMP") 		:= "N"	
		EndIf		
		(cAlias)->&(cAlias+"_DTLP") 		:= dDataLP 	// Data de lucros/perdas							
	Else	//Se atualiza saldos das contas a serem zeradas ou saldos das contas ponte.
		If lPontes	//Se atualiza saldo entidade Ponte
			Do Case
			Case cAlias == 'CTI'		
				CTI->CTI_CLVL   	:=	cClVlPon
				CTI->CTI_ITEM		:=	cItemPon
				CTI->CTI_CUSTO		:=	cCCPon
			Case cAlias == 'CT4'
				CT4->CT4_ITEM		:= 	cItemPon
				CT4->CT4_CUSTO		:=	cCCPon
			Case cAlias == 'CT3'
				CT3->CT3_CUSTO		:=	cCCPon
			EndCase
			(cAlias)->&(cAlias+"_CONTA")		:=	cCtaPon                          
			(cAlias)->&(cAlias+"_DTLP") 		:= dDataLP 	// Data de lucros/perdas						
		Else		//Se atualiza saldo entidade L/P	
			Do Case
			Case cAlias == 'CTI'		
				CTI->CTI_CLVL   	:=	aGrvLan[1]
				CTI->CTI_ITEM		:= 	aGrvLan[2]
				CTI->CTI_CUSTO		:=	aGrvLan[3]
			Case cAlias == 'CT4'
				CT4->CT4_ITEM		:= 	aGrvLan[2]
				CT4->CT4_CUSTO		:=	aGrvLan[3]
			Case cAlias == 'CT3'
				CT3->CT3_CUSTO		:=	aGrvLan[3]
			EndCase                                 
			(cAlias)->&(cAlias+"_CONTA")		:=	aGrvLan[4]          			
			(cAlias)->&(cAlias+"_DTLP") 		:= dDataLP 	// Data de lucros/perdas			
		EndIf
		If nCont == 1
			If lPontes			
				(cAlias)->&(cAlias+"_ANTCRD")		:=	nSldAntCrd
				(cAlias)->&(cAlias+"_ANTDEB")		:=	nSldAntDeb
			Else
				(cAlias)->&(cAlias+"_ANTCRD")		:=	nAtuCrd
				(cAlias)->&(cAlias+"_ANTDEB")		:=	nAtuDeb		
			EndIf			
		Else
			(cAlias)->&(cAlias+"_ANTCRD")		:=	nSldAntCrd
			(cAlias)->&(cAlias+"_ANTDEB")		:=	nSldAntDeb
		EndIf
		If nVlrLanc < 0 		//Conta a ser zerada => grava credito
			(cAlias)->&(cAlias+"_CREDIT")		:=	Abs(nVlrLanc)
		ElseIf nVlrLanc > 0    //Conta a ser zerada => grava debito
			(cAlias)->&(cAlias+"_DEBITO")		:=	Abs(nVlrLanc)
		EndIf                                                    
		(cAlias)->&(cAlias+"_ATUCRD")		:=	(cAlias)->&(cAlias+"_ANTCRD")+(cAlias)->&(cAlias+"_CREDIT")
		(cAlias)->&(cAlias+"_ATUDEB")		:=	(cAlias)->&(cAlias+"_ANTDEB")+(cAlias)->&(cAlias+"_DEBITO")
	Endif		
	(cAlias)->&(cAlias+"_MOEDA")		:=	aGrvLan[6]
	(cAlias)->&(cAlias+"_DATA") 		:=	dDataLP
	(cAlias)->&(cAlias+"_TPSALD")		:=	aGrvLan[7]
	(cAlias)->&(cAlias+"_STATUS") 	:= "1"
	(cAlias)->&(cAlias+"_LP") 		:= "Z"		// Flag de saldo de lucros/perdas
	(cAlias)->&(cAlias+"_SLBASE") 	:= "S"	
	If cAlias <> 'CT7'
		(cAlias)->&(cAlias+"_SLCOMP") 		:= "N"	
	EndIf
	MsUnlock()
Else	//Se ja existe registro com essa chave 
	Reclock(cAlias,.F.)
	If lLp	//Se atualiza saldos da entidade de L/P
		(cAlias)->&(cAlias+"_ANTDEB")		:=	nSldAntDeb
		(cAlias)->&(cAlias+"_ANTCRD")		:=	nSldAntCrd
		If nVlrLanc < 0 
			(cAlias)->&(cAlias+"_DEBITO")		+=	Abs(nVlrLanc)
		ElseIf nVlrLanc > 0 
			(cAlias)->&(cAlias+"_CREDIT")		+=	Abs(nVlrLanc)
		EndIf		
		(cAlias)->&(cAlias+"_ATUDEB")		:=	(cAlias)->&(cAlias+"_ANTDEB")+(cAlias)->&(cAlias+"_DEBITO")			
		(cAlias)->&(cAlias+"_ATUCRD")		:=	(cAlias)->&(cAlias+"_ANTCRD")+(cAlias)->&(cAlias+"_CREDIT")								
		If cAlias <> 'CT7'
			(cAlias)->&(cAlias+"_SLCOMP") 		:= "N"	
		EndIf		
	Else	//Se atualiza saldos das entidades a serem zeradas ou da entidade ponte	 	
		If nVlrLanc < 0                                                           
			(cAlias)->&(cAlias+"_CREDIT")		+=	Abs(nVlrLanc)			
		ElseIf nVlrLanc >0                   
			(cAlias)->&(cAlias+"_DEBITO")		+=	Abs(nVlrLanc)
		EndIf	                                              	
		(cAlias)->&(cAlias+"_ATUCRD")		:=	(cAlias)->&(cAlias+"_ANTCRD")+(cAlias)->&(cAlias+"_CREDIT")					
		(cAlias)->&(cAlias+"_ATUDEB")		:=	(cAlias)->&(cAlias+"_ANTDEB")+(cAlias)->&(cAlias+"_DEBITO")			
		If cAlias <> 'CT7'
			(cAlias)->&(cAlias+"_SLCOMP") 		:= "N"	
		EndIf		
	EndIf	
	MsUnlock()		
EndIf

RestArea(aSaveArea)
Return	
	
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct210Query³ Autor ³ Simone Mie Sato       ³ Data ³ 02.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Query para selecionar os registros a serem zerados.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210Query()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct210Query(cAlias,lMoedaEsp,nInicio,nFinal,dDataLP,cContaIni,cContaFim,cTpSaldo,lPontes,lJaExec,;
					cCustoIni, cCustoFim, cItemIni, cItemFim, cClVlIni, cClVlFim, lSldRes,dMaxDtLp )

Local aSaveArea	:= GetArea()
Local c210Query	:= ""
Local cQuery	:= ""
Local cInicial	:= cAlias + "_" 
Local cSelect	:= ""
Local cCond		:= ""
Local cCond3	:= ""
Local cCondMoed1:= ""    
Local cCondMoed2:= ""    
Local cCondMoed3:= ""
Local cOrder	:= ""              
Local ni

DEFAULT lSldRes	:= .F.

If lMoedaEsp         	
	cCondMoed1	:= " ARQ."+cInicial+"MOEDA = '"+StrZero(nInicio,2)+"' AND "
Else
	cCondMoed1	:=  " ARQ."+cInicial+"MOEDA >= '"+StrZero(nInicio,2)+"' AND "
	cCondMoed1	+=  " ARQ."+cInicial+"MOEDA <= '"+StrZero(nFinal,2)+"' AND "	
Endif
cCondMoed2	:= " ARQ2."+cInicial+"MOEDA = ARQ."+cInicial+"MOEDA AND "
cCondMoed3	:= " ARQ3."+cInicial+"MOEDA = ARQ."+cInicial+"MOEDA AND "

If cAlias == 'CTI'   
	cSelect	:=	" ARQ.CTI_CLVL, ARQ.CTI_ITEM, ARQ.CTI_CUSTO, "
	cCond	:= 	" ARQ2.CTI_CLVL = ARQ.CTI_CLVL AND "	
	cCond	+= 	" ARQ2.CTI_ITEM = ARQ.CTI_ITEM AND "
	cCond	+= 	" ARQ2.CTI_CUSTO = ARQ.CTI_CUSTO AND "
	cCond3	:= 	" ARQ3.CTI_CLVL = ARQ.CTI_CLVL AND "	
	cCond3	+= 	" ARQ3.CTI_ITEM = ARQ.CTI_ITEM AND "
	cCond3	+= 	" ARQ3.CTI_CUSTO = ARQ.CTI_CUSTO AND "	
	cOrder	:= " CTI_CLVL, CTI_ITEM, CTI_CUSTO, CTI_CONTA, CTI_MOEDA"
ElseIf cAlias == 'CT4'
	cSelect	:=	" ARQ.CT4_ITEM, ARQ.CT4_CUSTO, "
	cCond	:= 	" ARQ2.CT4_ITEM = ARQ.CT4_ITEM AND "
	cCond	+= 	" ARQ2.CT4_CUSTO = ARQ.CT4_CUSTO AND "
	cCond3	:= 	" ARQ3.CT4_ITEM = ARQ.CT4_ITEM AND "
	cCond3	+= 	" ARQ3.CT4_CUSTO = ARQ.CT4_CUSTO AND "	
	cOrder	:= 	" CT4_ITEM, CT4_CUSTO, CT4_CONTA, CT4_MOEDA"
ElseIf cAlias == 'CT3'
	cSelect	:=	" ARQ.CT3_CUSTO, "        
	cCond	:= 	" ARQ2.CT3_CUSTO = ARQ.CT3_CUSTO AND "	
	cCond3	:= 	" ARQ3.CT3_CUSTO = ARQ.CT3_CUSTO AND "	
	cOrder	:= " CT3_CUSTO, CT3_CONTA, CT3_MOEDA "
ElseIf cAlias == 'CT7'
	cOrder	:= " CT7_CONTA, CT7_MOEDA "
Endif
                          
c210Query	:= "c210Query"
cQuery		:= "SELECT ARQ."+cInicial+"CONTA, ARQ."+cInicial+"MOEDA, ARQ."+cInicial+"DATA, ARQ."+cInicial+"DTLP, "
cQuery		+= "ARQ."+cInicial+"ATUDEB, ARQ."+cInicial+"ATUCRD, "
cQuery 		+= cSelect
cQuery		+= " R_E_C_N_O_ RECNO "
cQuery 		+= " FROM "+RetSqlName(cAlias)+ " ARQ "
cQuery		+= " WHERE ARQ.D_E_L_E_T_ <> '*' AND "              
cQuery		+= " ARQ."+cInicial+"FILIAL = '"+xFilial(cAlias)+"' AND "
cQuery		+= " ARQ."+cInicial+"CONTA >= '"+cContaIni+"' AND "
cQuery		+= " ARQ."+cInicial+"CONTA <= '"+cContaFim+"' AND "
If cAlias == "CTI"
	If cCustoIni == Nil
		cCustoIni := ""
	EndIf
	If cCustoFim == Nil
		cCustoFim := Replicate("Z",Len(CT3->CT3_CUSTO))
	EndIf
	If cItemIni	== Nil
		cItemIni	:= ""
	EndIf
	If cItemFim == Nil
		cItemFim	:= Replicate("Z",Len(CT4->CT4_ITEM))
	EndIf
	If cClVlIni == Nil
		cClVlIni	:= ""
	EndIf
	If cClVlFim	== Nil
		cClVlFim	:= Replicate("Z",Len(CTI->CTI_CLVL))
	EndIf
	cQuery		+= " ARQ."+cInicial+"CUSTO >= '"+cCustoIni+"' AND "
	cQuery		+= " ARQ."+cInicial+"CUSTO <= '"+cCustoFim+"' AND "
	cQuery		+= " ARQ."+cInicial+"ITEM >= '"+cItemIni+"' AND "
	cQuery		+= " ARQ."+cInicial+"ITEM <= '"+cItemFim+"' AND "
	cQuery		+= " ARQ."+cInicial+"CLVL >= '"+cCLVLIni+"' AND "
	cQuery		+= " ARQ."+cInicial+"CLVL <= '"+cCLVLFim+"' AND "
ElseIf cAlias == "CT4"
	If cCustoIni == Nil
		cCustoIni := ""
	EndIf
	If cCustoFim == Nil
		cCustoFim := Replicate("Z",Len(CT3->CT3_CUSTO))
	EndIf
	If cItemIni	== Nil
		cItemIni	:= ""
	EndIf
	If cItemFim == Nil
		cItemFim	:= Replicate("Z",Len(CT4->CT4_ITEM))
	EndIf
	cQuery		+= " ARQ."+cInicial+"CUSTO >= '"+cCustoIni+"' AND "
	cQuery		+= " ARQ."+cInicial+"CUSTO <= '"+cCustoFim+"' AND "
	cQuery		+= " ARQ."+cInicial+"ITEM >= '"+cItemIni+"' AND "
	cQuery		+= " ARQ."+cInicial+"ITEM <= '"+cItemFim+"' AND "
ElseIf cAlias == "CT3"
	If cCustoIni == Nil
		cCustoIni := ""
	EndIf
	If cCustoFim == Nil
		cCustoFim := Replicate("Z",Len(CT3->CT3_CUSTO))
	EndIf
	cQuery		+= " ARQ."+cInicial+"CUSTO >= '"+cCustoIni+"' AND "
	cQuery		+= " ARQ."+cInicial+"CUSTO <= '"+cCustoFim+"' AND "
EndIf
cQuery 		+= cCondMoed1
cQuery		+= " ARQ."+cInicial+"TPSALD = '"+cTpSaldo+"' AND "

If ! lJaExec
	If lSldRes
		cQuery	+= "(ARQ."+cInicial+"LP = 'Z' "
		cQuery	+= "OR ARQ."+cInicial+"LP = 'N' OR ARQ."+cInicial+"LP = ' ' ) AND " 		
	Else                                            
		cQuery	+= "((ARQ."+cInicial+"LP = 'Z' AND "	
		cQuery	+= "ARQ."+cInicial+"DATA <> '" + Dtos(dDataLp) + "') OR ARQ."+cInicial+"LP = 'N' OR ARQ."+cInicial+"LP = ' '  " 	
		If !lPontes
			cQuery += " OR ( ARQ."+cInicial+"LP = 'S' AND ARQ."+cInicial+"DATA <> '" + Dtos(dDataLp) + "') " 	
		EndIf
		cQuery += ") AND " 			
	EndIf
Endif
If lPontes
	cQuery	+= "ARQ."+cInicial+"LP <> 'S' AND " 
Endif
cQuery		+= " ARQ."+cInicial+"DATA = (SELECT MAX(ARQ2."+cInicial+"DATA) "
cQuery		+= " FROM "+RetSqlName(cAlias)+ " ARQ2 "
cQuery		+= " WHERE ARQ2.D_E_L_E_T_ <> '*' AND "                  
cQuery		+= " ARQ2."+cInicial+"FILIAL = '"+xFilial(cAlias)+"' AND "
cQuery		+= cCond
cQuery		+= " ARQ2."+cInicial+"CONTA = ARQ."+cInicial+"CONTA AND "
cQuery 		+= cCondMoed2
cQuery		+= " ARQ2."+cInicial+"TPSALD = '"+cTpSaldo+"' AND "
If ! lJaExec
	If lSldRes
		cQuery	+= "(ARQ2."+cInicial+"LP = 'Z' "                                                       
		cQuery	+= "  OR ARQ2."+cInicial+"LP = 'N' OR ARQ2."+cInicial+"LP = ' ' )AND " 	
	Else
		cQuery	+= "((ARQ2."+cInicial+"LP = 'Z' AND "                                                       
		cQuery	+= "  ARQ2."+cInicial+"DATA <> '" + Dtos(dDataLp) + "') OR ARQ2."+cInicial+"LP = 'N' OR ARQ2."+cInicial+"LP = ' '  " 		
		If !lPontes
			cQuery += " OR ( ARQ2."+cInicial+"LP = 'S' AND ARQ2."+cInicial+"DATA <> '" + Dtos(dDataLp) + "') " 	
		EndIf
		cQuery += ") AND " 			
	EndIf
Endif	
If lPontes
	cQuery	+= " ARQ2."+cInicial+"LP <> 'S' AND "
Endif
cQuery		+= " ARQ2."+cInicial+"DATA <= '" +DTOS(dDataLP)+"') AND "

cQuery		+= " ARQ."+cInicial+"LP = (SELECT MAX(ARQ3."+cInicial+"LP) "
cQuery		+= " FROM "+RetSqlName(cAlias)+ " ARQ3 "
cQuery		+= " WHERE ARQ3.D_E_L_E_T_ <> '*' AND "                  
cQuery		+= " ARQ3."+cInicial+"FILIAL = '"+xFilial(cAlias)+"' AND "
cQuery		+= cCond3
cQuery		+= " ARQ3."+cInicial+"CONTA = ARQ."+cInicial+"CONTA AND "
cQuery 		+= cCondMoed3
cQuery		+= " ARQ3."+cInicial+"TPSALD = '"+cTpSaldo+"' AND "
cQuery 		+= " ARQ3."+cInicial+"DATA = ARQ."+cInicial+"DATA AND "
If lPontes
	cQuery	+= " ARQ3."+cInicial+"LP <> 'S' AND "
Endif
cQuery		+= " ARQ3."+cInicial+"DATA <= '" +DTOS(dDataLP)+"')"

If !lPontes
	cQuery		+= "AND  ( ARQ."+cInicial+"ATUDEB <> ARQ."+cInicial+"ATUCRD ) "
Else
	cQuery	+= " AND ( ARQ."+cInicial+"ATUDEB <> ARQ."+cInicial+"ATUCRD ) OR "		
	cQuery	+= " ( ( ARQ."+cInicial+"ATUDEB = ARQ."+cInicial+"ATUCRD ) AND  "			
	cQuery += "  ( ARQ."+cInicial+"ATUDEB <> ( SELECT SUM(CTZ_VLRDEB) "
	cQuery += " 							FROM "+RetSqlName("CTZ")+ " CTZD "
	cQuery += "								WHERE "
	cQuery += "								ARQ."+cInicial+"MOEDA = CTZD.CTZ_MOEDLC AND "
	cQuery += "								ARQ."+cInicial+"TPSALD = CTZD.CTZ_TPSALD AND "
	cQuery += "								ARQ."+cInicial+"CONTA = CTZD.CTZ_CONTA AND "
	If cAlias $ "CT3/CT4/CTI"
		cQuery += "								ARQ."+cInicial+"CUSTO = CTZD.CTZ_CUSTO AND "	
	ElseIf cAlias == "CT4/CTI"
		cQuery += "								ARQ."+cInicial+"ITEM = CTZD.CTZ_ITEM AND "		
	ElseIf cAlias == "CTI"
		cQuery += "								ARQ."+cInicial+"CLVL = CTZD.CTZ_CLVL AND "			
	EndIf                                                                               
	If !Empty(dMaxDtLP)
		cQuery += " CTZD.CTZ_DATA > '"+dtos(dMaxDtLP) + "' AND "	
	EndIf  
	cQuery += " CTZD.CTZ_DATA < '"+dtos(dDataLP) + "' AND "
	cQuery += " CTZD.D_E_L_E_T_ = ' ' ) "
	cQuery += "	OR "
	cQuery += "  ARQ."+cInicial+"ATUCRD <> ( SELECT SUM(CTZ_VLRCRD) "
	cQuery += " 							FROM "+RetSqlName("CTZ")+ " CTZC "
	cQuery += "								WHERE "
	cQuery += "								ARQ."+cInicial+"MOEDA = CTZC.CTZ_MOEDLC AND "
	cQuery += "								ARQ."+cInicial+"TPSALD = CTZC.CTZ_TPSALD AND "
	cQuery += "								ARQ."+cInicial+"CONTA = CTZC.CTZ_CONTA AND "
	If cAlias $ "CT3/CT4/CTI"
		cQuery += "								ARQ."+cInicial+"CUSTO = CTZC.CTZ_CUSTO AND "	
	ElseIf cAlias == "CT4/CTI"
		cQuery += "								ARQ."+cInicial+"ITEM = CTZC.CTZ_ITEM AND "		
	ElseIf cAlias == "CTI"
		cQuery += "								ARQ."+cInicial+"CLVL = CTZC.CTZ_CLVL AND "			
	EndIf                                                
	If !Empty(dMaxDtLP)
		cQuery += " CTZC.CTZ_DATA > '"+dtos(dMaxDtLP) + "' AND "	
	EndIf  	
	cQuery += " CTZC.CTZ_DATA < '"+dtos(dDataLP) + "' AND "	
	cQuery += " CTZC.D_E_L_E_T_ = ' ' )))"	
EndIf
cQuery		+= " ORDER BY "
cQuery 		+= cOrder
cQuery 		:= ChangeQuery(cQuery)

If ( Select ( "c210Query" ) <> 0 )
	dbSelectArea ( "c210Query" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),c210Query,.T.,.F.)

aStru := (cAlias)->(dbStruct())
		
For ni := 1 to Len(aStru)
	If aStru[ni,2] != 'C'
		If Subs(aStru[ni,1],1,8) == cInicial+"DATA"
			TCSetField(c210Query, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		ElseIf Subs(aStru[ni,1],1,8) == cInicial+"DTLP"
			TCSetField(c210Query, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])		
		ElseIf Subs(aStru[ni,1],1,8) == cInicial+"ATUDEB" 
			TCSetField(c210Query, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])				
		ElseIf Subs(aStru[ni,1],1,8) == cInicial+"ATUCRD" 
			TCSetField(c210Query, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])							
		EndIf
	Endif
Next ni

/*		
If ( Select ( "c210Query" ) <> 0 )
	dbSelectArea ( "c210Query" )
	dbCloseArea ()
Endif
*/
RestArea(aSaveArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct210ValIt³ Autor ³ Simone Mie Sato       ³ Data ³ 02.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o item ponte e item L/P estao preenchidos.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210ValIt()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ct210ValIt()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct210ValIt(cItem,cItemPon,cItemLp,lPontes,lItemOk,lCadastro)  

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
±±³Fun‡…o    ³Ct210ValCC³ Autor ³ Simone Mie Sato       ³ Data ³ 02.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o C.C. ponte e C.C. L/P estao preenchidos.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210ValCC()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ct210ValCC()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct210ValCC(cCusto,cCCPon,cCCLp,lPontes,lCCOk,lCadastro)  

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
±±³Fun‡…o    ³Ct210ValCV³ Autor ³ Simone Mie Sato       ³ Data ³ 02.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a Cl.Vlr Ponte e Cl.Vlr LP estao preenchidos.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210ValCV()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ct210ValCV()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct210ValCV(cClVl,cClVlPon,cClVlLP,lPontes,lClVlOk,lCadastro)  

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
±±³Fun‡…o    ³Ct210ValCV³ Autor ³ Simone Mie Sato       ³ Data ³ 02.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a Cl.Vlr Ponte e Cl.Vlr LP estao preenchidos.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210ValCV()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ct210ValCV()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct210ValCt(cConta,cCtaPon,cDigPon,cCtaLP,cDigLP,lPontes,lCtaOk,aCriter,aCritPon,aCritLP,lCadastro)  

Local aSaveArea	:= GetArea()
Local nMoedas	:= __nQuantas
Local nCont

dbSelectArea("CT1")
dbsetOrder(1)
MsSeek(xFilial("CT1")+cConta)
If lCadastro	//Se utiliza Conta Ponte/LP do Cadastro de Plano de Contas
	If Found()
		If	(Empty(CT1->CT1_CTALP)  .Or. ;
			(lPontes .And. Empty(CT1->CT1_CTAPON)))
			lCtaOk 	:= .F.
		Else
			lCtaOk 	:= .T.
			cCtaPon	:= CT1->CT1_CTAPON
			cCtaLP 	:= CT1->CT1_CTALP
		Endif
	Endif
Else 
	If lPontes
		If Subs(CT1->CT1_CTAPON,1,1) == "*"
			lCtaOk	:= .F.                 
		EndIf		
		MsSeek(xFilial("CT1")+cCtaPon)			
	Else
		If Subs(CT1->CT1_CTALP,1,1) == "*"
			lCtaOk	:= .F.
		EndIf			
		MsSeek(xFilial("CT1")+cCtaLP)
	EndIf    
	
	If lCtaOk .And. !Found()
		lCtaOk	:= .F.    
	EndIF
	
EndIf
	
If lCtaOk
	For nCont := 1 to (nMoedas-1)        
		AADD(aCriter,&("CT1->CT1_CVD"+StrZero(nCont+1,2)))
	Next
			
	MsSeek(xFilial("CT1")+cCtaPon)		
	cDigPon := CT1->CT1_DC
	For nCont := 1 to (nMoedas-1)
		AADD(aCritPon,&("CT1->CT1_CVD"+StrZero(nCont+1,2)))
	Next
		
	MsSeek(xFilial("CT1")+cCtaLP)
	cDigLP	:= CT1->CT1_DC          
	For nCont := 1 to (nMoedas-1)
		AADD(aCritLP,&("CT1->CT1_CVD"+StrZero(nCont+1,2)))
	Next		
EndIf		

RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C210CalSld³ Autor ³ Simone Mie Sato       ³ Data ³ 13.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o saldo a ser zerado.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C210CalSld									      		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C210CalSld(aGrvLan,dDataLP,cAlias,nValDeb,nValCrd,lPontes,cClVlPon,cItemPon,cCCPon,cCtaPon,lJaExec,lSldRes)

Local aSaveArea :=	GetArea()
Local aSaldo	:= {0,0,0,0,0,0,0,0}
Local cChave 	:=	""                           

Local nRecno	:= 0 		//Guarda o numero do registro 
Local nValZera  := 0		//Valor de zeramento.

DEFAULT lSldRes	:= .F.

cCCPon	:= Iif(Empty(cCCPon),Space(Len(CT3->CT3_CUSTO)),cCCPon)            
cItemPon:= Iif(Empty(cItemPon),Space(Len(CT4->CT4_ITEM)),cItemPon)
aGrvLan[3]	:= Iif(Empty(aGrvLan[3]),Space(Len(CT3->CT3_CUSTO)),aGrvLan[3])
aGrvLan[2]	:= Iif(Empty(aGrvLan[2]),Space(Len(CT4->CT4_ITEM)),aGrvLan[2])

If lPontes
	//Se for zeramento com conta ponte, considero como chave:
	//CONTA+CUSTO+ITEM+MOEDA,pois sera procurado no arquivo de trabalho.
	cChave := aGrvLan[4]+aGrvLan[3]+aGrvLan[2]+aGrvLan[1]
Else
	Do Case
	Case cAlias == 'CTI'             
		cChave := aGrvLan[4]+aGrvLan[3]+aGrvLan[2]+aGrvLan[1]
	Case cAlias == 'CT4'                               
		cChave := aGrvLan[4]+aGrvLan[3]+aGrvLan[2]
	Case cAlias == 'CT3'                     
		cChave := aGrvLan[4]+aGrvLan[3] 		
	Case cAlias == 'CT7'
		cChave	:= aGrvLan[4]
	EndCase
EndIf
cChave += aGrvLan[6]+aGrvLan[7]+dtos(dDataLP)	

//Se for zeramento c/ conta ponte e o alias for diferente de CTI,
// procuro no arq. de trabalho
If lPontes .And. cAlias <> 'CTI'	

	Do Case
	Case cAlias == 'CT4' 
		aSaldo	:= SaldoCT4(aGrvLan[4],aGrvLan[3],aGrvLan[2],dDataLP,aGrvLan[6],aGrvLan[7],'CTBA210',.F.)	
	Case cAlias == 'CT3' 
		aSaldo	:= SaldoCT3(aGrvLan[4],aGrvLan[3],dDataLP,aGrvLan[6],aGrvLan[7],'CTBA210',.F.)		
	Case cAlias == 'CT7' 
		aSaldo	:= SaldoCT7(aGrvLan[4],dDataLP,aGrvLan[6],aGrvLan[7],'CTBA210',.F.)		
	EndCase
	
	nValCrd	:= aSaldo[4]
	nValDeb	:= aSaldo[5]

	nValZera	:= nValCrd-nValDeb
	AAdd(aGrvLan,(Iif(nValZera>0,Abs(nValZera),0)))
	AAdd(aGrvLan,(Iif(nValZera<0,Abs(nValZera),0)))
Else     
	dbSelectArea(cAlias)
	dbSetOrder(2)       
	nRecno	:= Recno()	//Guarda o numero do registro atual

	If ! lJaExec .And. MsSeek(xFilial(cAlias)+cChave+'Z',.F.) 	
		If lSldRes
			nValZera	:= nValCrd-nValDeb		
		Else
			nValZera	:= (nValCrd +(cAlias)->&(cAlias+'_CREDIT')) - (nValDeb+(cAlias)->&(cAlias+'_DEBITO'))		
		EndIf
		AAdd(aGrvLan,(Iif(nValZera<0,Abs(nValZera),0)))
		AAdd(aGrvLan,(Iif(nValZera>0,Abs(nValZera),0)))
		dbGoto(nRecno)
	Else              
		dbGoto(nRecno)                   
		If ( TcSrvType()!="AS/400" )
			AAdd(aGrvLan,(c210Query->&(cAlias+'_ATUDEB')))
			AAdd(aGrvLan,(c210Query->&(cAlias+'_ATUCRD')))
		Else
			AAdd(aGrvLan,((cAlias)->&(cAlias+'_ATUDEB')))
			AAdd(aGrvLan,((cAlias)->&(cAlias+'_ATUCRD')))
		EndIf
	Endif
EndIf         
RestArea(aSaveArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct210SldLP³ Autor ³ Simone Mie Sato       ³ Data ³ 02.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o saldo anterior das contas pontes ou LP            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210SldLP()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct210SldLP()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct210SlAnt(cAlias,dDataLP,nSldAntDeb,nSldAntCrd,cClVl,cItem,cCusto,cConta,;
			cMoeda,cTpSaldo)


Local aSaveArea	:= GetArea()
Local aSldLP	:= {0,0,0,0,0,0,0,0}

Do Case
Case cAlias == 'CTI'  .And. !Empty(cClVl)
	aSldLP	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataLP,cMoeda,cTpSaldo,'CTBA210',.F.)	
Case cAlias == 'CT4' .And. !Empty(cItem)                        
	aSldLP	:= SaldoCT4(cConta,cCusto,cItem,dDataLP,cMoeda,cTpSaldo,'CTBA210',.F.)	
Case cAlias == 'CT3' .And. !Empty(cCusto)
	aSldLP	:= SaldoCT3(cConta,cCusto,dDataLP,cMoeda,cTpSaldo,'CTBA210',.F.)		
Case cAlias == 'CT7' .And. !Empty(cConta)
	aSldLP	:= SaldoCT7(cConta,dDataLP,cMoeda,cTpSaldo,'CTBA210',.F.)		
EndCase

nSldAntDeb	:=  aSldLP[7]
nSldAntCrd	:=  aSldLP[8]

RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct210MaxDt³ Autor ³ Simone Mie Sato       ³ Data ³ 02.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a data final a ser reprocessada.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210MaxDt()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct210MaxDt()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct210MaxDt(dDataLp,dDataFim,cContaIni,cContaFim, cCustoIni, cCustoFim, cItemIni, cItemFim, cClVlIni, cClVlFim)

Local aSaveArea	:= GetArea()
Local cMaxData	:= ""
Local cQuery	:= ""
Local ni

If cCustoIni == Nil
	cCustoIni := ""
EndIf
If cCustoFim == Nil
	cCustoFim := Replicate("Z",Len(CT3->CT3_CUSTO))
EndIf
If cItemIni	== Nil
	cItemIni	:= ""
EndIf
If cItemFim == Nil
	cItemFim	:= Replicate("Z",Len(CT4->CT4_ITEM))
EndIf
If cClVlIni == Nil
	cClVlIni	:= ""
EndIf
If cClVlFim	== Nil
	cClVlFim	:= Replicate("Z",Len(CTI->CTI_CLVL))
EndIf

cMaxData	:= "cMaxData"
cQuery		:= "SELECT MAX(CT2_DATA) MAXDATA FROM "+RetSqlName("CT2")+ " CT2 "
cQuery		+=	"WHERE CT2.CT2_DATA > '" + DTOS(dDataLP)+"' AND "
cQuery		+=	"CT2.CT2_DTLP = '' AND "       
cQuery		+=	"(CT2.CT2_DEBITO >= '"+cContaIni+"' AND CT2.CT2_DEBITO <= '"+cContaFim + "' "
cQuery		+=	" AND CT2.CT2_CCD >= '"+cCustoIni+"' AND CT2.CT2_CCD <= '"+cCustoFim+"' "
cQuery		+=	" AND CT2.CT2_ITEMD >= '"+cItemIni+"' AND CT2.CT2_ITEMD <= '"+cCustoFim+"' "
cQuery		+=	" AND CT2.CT2_CLVLDB >= '"+cCustoIni+"' AND CT2.CT2_CLVLDB <= '"+cCustoFim+"' ) OR "

cQuery		+=	"(CT2.CT2_CREDIT >= '"+cContaIni+"' AND CT2.CT2_CREDIT <= '"+cContaFim + "' "
cQuery		+=	" AND CT2.CT2_CCC >= '"+cCustoIni+"' AND CT2.CT2_CCC <= '"+cCustoFim+"' "
cQuery		+=	" AND CT2.CT2_ITEMC >= '"+cItemIni+"' AND CT2.CT2_ITEMC <= '"+cCustoFim+"' "
cQuery		+=	" AND CT2.CT2_CLVLCR >= '"+cCustoIni+"' AND CT2.CT2_CLVLCR <= '"+cCustoFim+"' ) AND "		
cQuery		+= "D_E_L_E_T_ <> '*'"
cQuery 		:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cMaxData,.T.,.F.)

aStru := CT2->(dbStruct())

For ni := 1 to Len(aStru)
	If aStru[ni,2] != 'C'
		If Subs(aStru[ni,1],1,8) == "CT2_DATA"
			TCSetField(cMaxData, "MAXDATA", aStru[ni,2],aStru[ni,3],aStru[ni,4])
		EndIf
	Endif
Next ni                 
dDataFim	:= cMaxData->MAXDATA
If ( Select ( "cMaxData" ) <> 0 )
	dbSelectArea ( "cMaxData" )
	dbCloseArea ()
Endif


RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C210Zerado³ Autor ³ Simone Mie Sato       ³ Data ³ 04.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se os saldos estao zerados para atualizar flag.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C210Zerado									      		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba210                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C210Zerado(aGrvLan,cArquivo,dDataLP,lZera,nRecno,lPontes)		

Local aSaveArea	:= GetArea()                                   
Local cChave	:= ""
Local nMovDeb	:=	0	//Valor a debito ja gravado
Local nMovCrd	:=	0	//Valor a credito ja gravado
Local nVlrMovCrd:= 0
Local nVlrMovDeb:= 0
Local nVlDebCTZ	:= 0
Local nVlCrdCTZ	:= 0
Local bCond		:= {||.F.}
Local aSaldo	:= {0,0,0,0,0,0,0,0}

lZera	:= .F.
Do Case
Case cArquivo == 'CT4'
	cChave := aGrvLan[4]+aGrvLan[3]+aGrvLan[2]+aGrvLan[6]+aGrvLan[7]
	bCond  := { ||CT4->CT4_FILIAL == xFilial("CT4") .And. CT4->CT4_ITEM == aGrvLan[2] .And. CT4->CT4_CUSTO == aGrvLan[3] .And. CT4->CT4_CONTA == aGrvLan[4].And. CT4->CT4_MOEDA == aGrvLan[6] .And. CT4->CT4_TPSALD ==  aGrvLan[7]}
Case cArquivo == 'CT3'
	cChave := aGrvLan[4]+aGrvLan[3]+aGrvLan[6]+aGrvLan[7]                                                                
	bCond  := { ||CT3->CT3_FILIAL == xFilial("CT3") .And. CT3->CT3_CUSTO == aGrvLan[3] .And. CT3->CT3_CONTA == aGrvLan[4] .And. CT3->CT3_MOEDA == aGrvLan[6] .And. CT3->CT3_TPSALD ==  aGrvLan[7]}	
Case cArquivo == 'CT7'
	cChave := aGrvLan[4]+ aGrvLan[6]+aGrvLan[7]
	bCond  := { ||CT7->CT7_FILIAL == xFilial("CT7") .And. CT7->CT7_CONTA == aGrvLan[4] .And. CT7->CT7_MOEDA == aGrvLan[6] .And. CT4->CT4_TPSALD ==  aGrvLan[7]}	
EndCase

dbSelectArea(cArquivo)
If lPontes                                                                  
	
	Do Case
	Case cArquivo == 'CT4' 
		aSaldo	:= SaldoCT4(aGrvLan[4],aGrvLan[3],aGrvLan[2],dDataLP,aGrvLan[6],aGrvLan[7],'CTBA210',.F.)	
	Case cArquivo == 'CT3' 
		aSaldo	:= SaldoCT3(aGrvLan[4],aGrvLan[3],dDataLP,aGrvLan[6],aGrvLan[7],'CTBA210',.F.)		
	Case cArquivo == 'CT7' 
		aSaldo	:= SaldoCT7(aGrvLan[4],dDataLP,aGrvLan[6],aGrvLan[7],'CTBA210',.F.)		
	EndCase
	
	nValCrd	:= aSaldo[4]
	nValDeb	:= aSaldo[5]
	
	//Verifico qual o valor ja gravado no CTZ
	Ct210ClCTZ(@nVlDebCTZ,@nVlCrdCTZ,cArquivo,aGrvLan,dDataLP,.F.,.T.)		

	nVlrMovCrd	:= nValCrd-nVlCrdCTZ	
	nVlrMovDeb	:= nValDeb-nVlDebCtz                                    

	//Verifico qual o valor zerado na data	
	Ct210ClCTZ(@nMovDeb,@nMovCrd,cArquivo,aGrvLan,dDataLP,.T.,.F.)			
	
//	If (nMovDeb <> 0 .And. nMovDeb == nVlrMovDeb) .Or. (nMovCrd <> 0 .And. nMovCrd == nVlrMovCrd) 			
	If (nVlrMovDeb <> 0 .And. nVlrMovCrd = 0 .And. nMovDeb == nVlrMovDeb) 
		lZera	:= .T.
	ElseIf (nVlrMovCrd <> 0 .And. nVlrMovDeb = 0 .And. nMovCrd == nVlrMovCrd) 			
		lZera	:= .T.
	ElseIf (nVlrMovCrd <> 0 .And. nVlrMovDeb <> 0 .And. nMovCrd == nVlrMovCrd .And. nMovDeb == nVlrMovDeb) 			
		lZera	:= .T.
	EndIf		
Else
	dbSelectArea(cArquivo)
	dbGoTop()
	dbSetOrder(2) 
	If MsSeek(xFilial(cArquivo)+cChave+dtos(dDataLP)+'Z')	//Procuro o registro de zeramento
		nRecno		:= Recno()
		nMovDeb		:=	(cArquivo)->&(cArquivo+'_ANTDEB')+(cArquivo)->&(cArquivo+'_DEBITO')
		nMovCrd		:=	(cArquivo)->&(cArquivo+'_ANTCRD')+(cArquivo)->&(cArquivo+'_CREDIT')
	EndIf
	If 	(nMovDeb == nMovCrd) .And. (nMovDeb <> 0 .or. nMovCrd <> 0)
		lZera := 	.T.
	EndIf	
EndIf

RestArea(aSaveArea)
Return       

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct210AtSX5³ Autor ³ Simone Mie Sato       ³ Data ³ 11.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualizo a tabela do SX5.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210AtSX5(dDataLP)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct210AtSX5()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct210AtSX5(dDataLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSaldo,lPontes)

Local aSaveArea	:= GetArea()
Local cChave	:= cEmpAnt+cFilant
Local cCampo	:= ""
Local lExiste	:= .F.                                        
Local nContad
Local cChar		:= ""

// Caso a tabela LP exista na tabela CW0 o processo será feito por ela e nao pela SX5
If CtLPCW0Tab()
	CtAtLPCW0(dDataLP,lMoedaEsp,cMoeda,nInicio,nFinal,cTpSaldo,lPontes)
EndIf	           

RestArea(aSaveArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct210GrTrb³ Autor ³ Simone Mie Sato       ³ Data ³ 04.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava arquivo de trabalho,caso seja zeramento c/ conta ponte³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210GrTrb()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct210GrTrb()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct210GrTrb(aGrvLan,cAlias)

Local aSaveArea	:= GetArea()
Local cChave	:= ""

Do Case
Case cAlias == 'CT4'
	cChave	:= 'CT4'+aGrvLan[4]+aGrvLan[3]+aGrvLan[2]+aGrvLan[6]
Case cAlias == 'CT3'
	cChave	:= 'CT3'+aGrvLan[4]+aGrvLan[3]+Space(nTamItem)+aGrvLan[6]
Case cAlias == 'CT7'
	cChave	:= 'CT7'+aGrvLan[4]+Space(nTamCC)+Space(nTamItem)+aGrvLan[6]
EndCase

dbSelectArea("TRB")
dbSetOrder(1)	//conta+c.custo+item+cl.valor+moeda

If !MsSeek(cChave,.F.)
	RecLock("TRB",.T.)
	TRB->IDENT	:= 	cAlias
	If cAlias == 'CT4'
		TRB->ITEM	:= 	aGrvLan[2]
	EndIf
	If cAlias $'CT3/CT4'			
		TRB->CUSTO	:= 	aGrvLan[3]
	EndIf
	TRB->CONTA	:= 	aGrvLan[4]
	TRB->MOEDA	:= 	aGrvLan[6]
	TRB->DEBITO	:=	aGrvLan[9]
	TRB->CREDIT	:=	aGrvlan[8]
Else
	Reclock("TRB",.F.)
	TRB->DEBITO	+=	aGrvLan[9]
	TRB->CREDIT	+=	aGrvLan[8]
EndIf
MsUnlock()


RestARea(aSaveArea)

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct210VlRat³ Autor ³ Simone Mie Sato       ³ Data ³ 10.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe mensagem que a pergunta de rateio nao esta disponivel.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210VlRat()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct210vlRat()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct210VlRat()

Local aSaveArea	:= GetArea()
Local cMensagem	:= ""
Local lRet		:= .T.

If !Empty(mv_par11) 
	cMensagem	:= STR0015 + chr(13)//"Favor deixar essa pergunta em branco.. Ainda nao esta disponivel.."
	cMensagem	+= STR0016 + chr(13)//"Sera implementado futuramente..."		 
	lRet	:= .F.
	MsgAlert(cMensagem)
EndIf

RestArea(aSaveArea)

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct210GrCTZ³ Autor ³ Simone Mie Sato       ³ Data ³ 27.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava Registros ref. o arquivo CTZ.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210GrCTZ(aGrvLan)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ct210GrCTZ()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct210GrCTZ(cTipo,aGrvLan,cSeqLin,nVlCrdCTZ,nVlDebCTZ,cLinhaAnt)

Local aSaveArea	:= GetArea()         

dbSelectArea("CTZ")   
//Sempre sera incluido um novo registro no CTZ
Reclock("CTZ",.T.)
CTZ_FILIAL	:= xFilial("CTZ")
CTZ_DATA	:= CT2->CT2_DATA
CTZ_LOTE	:= CT2->CT2_LOTE
CTZ_SBLOTE	:= CT2->CT2_SBLOTE
CTZ_DOC		:= CT2->CT2_DOC
CTZ_LINHA	:= CT2->CT2_LINHA
CTZ_SEQLIN	:= cSeqLin
CTZ_TPSALD	:= CT2->CT2_TPSALD
CTZ_CONTA	:= aGrvLan[4]
CTZ_CUSTO	:= aGrvlan[3]
CTZ_ITEM	:= aGrvLan[2]
CTZ_CLVL	:= aGrvLan[1]	
CTZ_MOEDLC	:= aGrvLan[6]
CTZ_EMPORI	:= CT2->CT2_EMPORI
CTZ_FILORI	:= CT2->CT2_FILORI       
If cTipo == "1"
	CTZ_VLRDEB	+= Abs((aGrvLan[9]- nVlDebCTZ) - (aGrvLan[8]-nVlCrdCTZ))
ElseIf cTipo == "2"
	CTZ_VLRCRD	+= Abs((aGrvLan[9]- nVlDebCTZ) - (aGrvLan[8]-nVlCrdCTZ))
EndIf	        
MsUnlock()    

cLinhaAnt	:= CTZ->CTZ_LINHA
cSeqLin		:= CTZ->CTZ_SEQLIN
RestArea(aSaveArea)

Return						

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct210ClCTZ³ Autor ³ Simone Mie Sato       ³ Data ³ 27.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna os valores ja zerados para conta ponte.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210ClCTZ(nVlDebCTZ,nVlCrdCTZ)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ctba210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct210ClCTZ(nVlDebCTZ,nVlCrdCTZ,cAlias,aGrvLan,dDataLP,lDataIgual,lDataMenor)

Local aSaveArea	:= GetArea()
Local cChave	:= ""
Local bCond		:= {||.F.}
Local bCondData	:= {||.F.}
Local aArea		:= (cAlias)->(GetArea()), lLoop := .F.
Local cDataICTZ	:= CTOD("  /  /  ")

DbSelectArea(cAlias)
Do Case
Case cAlias = 'CT7'
	DbSetOrder(5)
	MsSeek(xFilial("CT7")+"Z"+aGrvLan[4]+aGrvLan[6]+aGrvLan[7]+DTOS(dDataLP),.T.)
	If Found()
		(cAlias)->(RestArea(aArea))
		RestArea(aSaveArea)
		Return
	Else			
		CT7->(dbSkip(-1))
		If CT7->CT7_FILIAL == xFilial("CT7") .AND. CT7->CT7_LP = "Z" .And. CT7->CT7_CONTA = aGrvLan[4] .And.;
			CT7->CT7_MOEDA = aGrvLan[6] .And. CT7->CT7_TPSALD = aGrvLan[7]
			cDataICTZ	:= DTOS(CT7->CT7_DATA) 		// ULTIMA APURACAO ZERADO OS VALORES
		EndIf
	Endif
Case cAlias = 'CT3'
	DbSetOrder(8)                                                                              			
	MsSeek(xFilial("CT3")+"Z"+aGrvLan[4]+aGrvLan[3]+aGrvLan[6]+aGrvLan[7]+DTOS(dDataLP),.T.)
	If Found()
		(cAlias)->(RestArea(aArea))
		RestArea(aSaveArea)
		Return			
	Else
		CT3->(dbSkip(-1))
		If CT3->CT3_FILIAL == xFilial("CT3") .and. CT3->CT3_LP = "Z" .And. CT3->CT3_CONTA = aGrvLan[4] .And.;
			CT3->CT3_CUSTO = aGrvLan[3] .And. CT3->CT3_MOEDA = aGrvLan[6] .And. CT3->CT3_TPSALD = aGrvLan[7]
			cDataICTZ	:= DTOS(CT3->CT3_DATA) 		// ULTIMA APURACAO ZERADO OS VALORES
		Endif
	EndIf
Case cAlias = 'CT4'
	DbSetOrder(6)
	MsSeek(xFilial("CT4")+"Z"+aGrvLan[4]+aGrvLan[3]+aGrvLan[2]+aGrvLan[6]+aGrvLan[7]+DTOS(dDataLP),.T.)
	If Found()
		(cAlias)->(RestArea(aArea))
		RestArea(aSaveArea)
		Return							
	Else
		CT4->(dbSkip(-1))
		If CT4->CT4_FILIAL == xFilial("CT4") .and. CT4->CT4_LP = "Z" .And. CT4->CT4_CONTA = aGrvLan[4] .And. CT4->CT4_CUSTO = aGrvLan[3] .And.;
				CT4->CT4_ITEM = aGrvLan[2] .And. CT4->CT4_MOEDA = aGrvLan[6] .and.;
				CT4->CT4_TPSALD = aGrvLan[7]
			cDataICTZ	:= DTOS(CT4->CT4_DATA) 		// ULTIMA APURACAO ZERADO OS VALORES
		Endif
	EndIf
Case cAlias = 'CTI'
	DbSetOrder(6)
	MsSeek(xFilial("CTI")+"Z"+aGrvLan[4]+aGrvLan[3]+aGrvLan[2]+aGrvLan[1]+aGrvLan[6]+aGrvLan[7]+DTOS(dDataLP),.T.)
	If Found()
		(cAlias)->(RestArea(aArea))
		RestArea(aSaveArea)
		Return											
	Else
		CTI->(dbSkip(-1))
		If CTI->CTI_LP = "Z" .And. CTI->CTI_CONTA = aGrvLan[4] .And. CTI->CTI_CUSTO = aGrvLan[3] .And.;
				CTI->CTI_ITEM = aGrvLan[2] .And. CTI->CTI_CLVL = aGrvLan[1] .and.;
				CTI->CTI_MOEDA = aGrvLan[6] .And. CTI->CTI_TPSALD = aGrvLan[7]
			cDataICTZ	:= DTOS(CTI->CTI_DATA) 		// ULTIMA APURACAO ZERADO OS VALORES
		Endif
	EndIf
EndCase


cQuery := "		SELECT SUM(CTZ_VLRDEB) CTZ_VLRDEB,SUM(CTZ_VLRCRD) CTZ_VLRCRD "
cQuery += " FROM "+RetSqlName("CTZ")
cQuery += " WHERE CTZ_FILIAL = '"+xFilial("CTZ")+"' "

Do Case
Case cAlias = 'CT7'
	cQuery += "   AND CTZ_CONTA = '"+aGrvLan[4]+"' "
Case cAlias = 'CT3'
	cQuery += "   AND CTZ_CONTA = '"+aGrvLan[4]+"' " 
	cQuery += "   AND CTZ_CUSTO = '"+aGrvLan[3]+"' "
Case cAlias = 'CT4'
	If Empty(aGrvLan[3]) //Se nao tiver centro de custo                                                           
		cQuery += "   AND CTZ_CONTA = '"+aGrvLan[4]+"' "
		cQuery += "   AND CTZ_CUSTO = '"+Space(nTamCC)+"' "
		cQuery += "   AND CTZ_ITEM  = '"+aGrvLan[2]+"' "
	Else
		cQuery += "   AND CTZ_CONTA = '"+aGrvLan[4]+"' "
		cQuery += "   AND CTZ_CUSTO = '"+aGrvLan[3]+"' "
		cQuery += "   AND CTZ_ITEM  = '"+aGrvLan[2]+"' "
	EndIf
Case cAlias = 'CTI'                               
	If Empty(aGrvLan[3]) .And. !Empty(aGrvLan[2])//Se tiver item e nao tiver centro de custo
		cQuery += "   AND CTZ_CONTA = '"+aGrvLan[4]+"' "
		cQuery += "   AND CTZ_CUSTO = '"+space(nTamCC)+"' "
		cQuery += "   AND CTZ_ITEM  = '"+aGrvLan[2]+"' "
		cQuery += "   AND CTZ_CLVL  = '"+aGrvLan[1]+"' "							
	ElseIf !Empty(aGrvLan[3]) .And. Empty(aGrvlan[2])//Se tiver centro de custo e nao tiver item
		cQuery += "   AND CTZ_CONTA = '"+aGrvLan[4]+"' "
		cQuery += "   AND CTZ_CUSTO = '"+aGrvLan[3]+"' "
		cQuery += "   AND CTZ_ITEM  = '"+space(nTamItem)+"' "
		cQuery += "   AND CTZ_CLVL  = '"+aGrvLan[1]+"' "
	ElseIf Empty(aGrvLan[3]) .And. Empty(aGrvLan[2])//Se nao tiver item nem centro de custo
		cQuery += "   AND CTZ_CONTA = '"+aGrvLan[4]+"' "
		cQuery += "   AND CTZ_CUSTO = '"+space(nTamCC)+"' "
		cQuery += "   AND CTZ_ITEM  = '"+space(nTamItem)+"' "
		cQuery += "   AND CTZ_CLVL  = '"+aGrvLan[1]+"' "
	Else//Tem Item e Centro de Custo
		cQuery += "   AND CTZ_CONTA = '"+aGrvLan[4]+"' "
		cQuery += "   AND CTZ_CUSTO = '"+aGrvLan[3]+"' "
		cQuery += "   AND CTZ_ITEM  = '"+aGrvLan[2]+"' "
		cQuery += "   AND CTZ_CLVL  = '"+aGrvLan[1]+"' "
	Endif	
EndCase                   

cQuery += "   AND CTZ_MOEDLC='"+aGrvLan[6]+"'"
cQuery += "   AND CTZ_TPSALD='"+aGrvLan[7]+"'"
cQuery += "   AND CTZ_EMPORI='"+cEmpAnt+"'"
cQuery += "   AND CTZ_FILORI='"+cFilAnt+"'"

If !lDataIgual .and. !Empty(cDataICTZ)
	cQuery += " AND CTZ_DATA > '"+cDataICTZ+"' "	/// MAIOR QUE A DATA DE APURACAO ZERANDO
EndIf
If lDataIgual
	cQuery += " AND CTZ_DATA = '"+DTOS(dDataLP)+"' "
ElseIf lDataMenor
	cQuery += " AND CTZ_DATA < '"+DTOS(dDataLP)+"' "
Else
	cQuery += " AND CTZ_DATA <= '"+DTOS(dDataLP)+"' "
EndIf

cQuery += " AND D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CTZVLR",.T.,.F.)
		
TcSetField("CTZVLR","CTZ_VLRDEB","N",17,2)
TcSetField("CTZVLR","CTZ_VLRCRD","N",17,2)

dbSelectArea("CTZVLR")
dbGoTop()      
nVlDebCTZ	+= CTZVLR->CTZ_VLRDEB
nVlCrdCTZ	+= CTZVLR->CTZ_VLRCRD
If ( Select ( "CTZVLR" ) <> 0 )
	dbSelectArea ( "CTZVLR" )
	dbCloseArea ()
Endif

(cAlias)->(RestArea(aArea))
RestArea(aSaveArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbSXBDtLP³ Autor ³ Simone Mie Sato       ³ Data ³ 09.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a data formatada para o SX3 =>da Tabela SZ do SX5   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbSXBDtLP()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ctba210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbSxbDtLP()

Return(DTOC(STOD(Subs(X5DESCRI(),1,8))))
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbSXBMoed³ Autor ³ Simone Mie Sato       ³ Data ³ 09.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a moeda 											  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbSXBMoed()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ctba210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbSxbMoed()

Return((Subs(X5DESCRI(),9,2)))

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbSXBTpSl³ Autor ³ Simone Mie Sato       ³ Data ³ 09.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a moeda 											  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbSXBTpSl()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ctba210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbSxbTpSl()

Return((Subs(X5DESCRI(),11,1)))

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbRetSZ  ³ Autor ³ Simone Mie Sato       ³ Data ³ 09.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a data  											  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbRetSZ()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ctba210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbRetSZ()

Return(STOD(Subs(X5DESCRI(),1,8)))


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbFltSZ  ³ Autor ³ Simone Mie Sato       ³ Data ³ 09.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a data  											  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbRetSZ()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ctba210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbFltSZ()

Local cFiltro	:= ""

cFiltro	:= Subs(SX5->X5_CHAVE,1,2) = cEmpAnt .And. SUBS(SX5->X5_CHAVE,3,2) == cFilAnt

Return(cFiltro)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbLinCTZ ³ Autor ³ Simone Mie Sato       ³ Data ³ 31.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o numero da sequencia da linha 					  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbLinCTZ(nLinha)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ctba210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbLinCTZ(cLote,cSubLote,cDoc,dDataLP,nLinha,cMoeda,cTpSaldo)

Local aSaveArea	:= GetArea()
Local cSeqLin	:= "000"

dbSelectArea("CTZ")
dbSetOrder(1)	//DATA+LOTE+SUBLOTE+DOC+TP SALDO+EMPORI+FILORI+MOEDA+LINHA+SEQLIN
//MsSeek(IncLast(xFilial()+dtos(dDataLP)+cLote+cSubLote+cDoc+cTpSaldo+cEmpAnt+cFilAnt+cMoeda+CT2->CT2_LINHA))
MsSeek(IncLast(xFilial()+dtos(dDataLP)+cLote+cSubLote+cDoc+cTpSaldo+cEmpAnt+cFilAnt+cMoeda),.T.)
dbSkip(-1)
If CTZ->CTZ_LOTE = cLote .And. CTZ->CTZ_SBLOTE = cSubLote .And. CTZ->CTZ_DOC = cDoc .And. ;
	CTZ->CTZ_TPSALD = cTpSaldo .And. CTZ->CTZ_MOEDLC = cMoeda .And. CTZ->CTZ_EMPORI = cEmpAnt .And.;
	dtos(CTZ->CTZ_DATA) = dtos(dDataLP) .And. 	CTZ->CTZ_FILORI = cFilAnt 
	If CTZ->CTZ_LINHA == CT2->CT2_LINHA
		cSeqLin := Soma1(CTZ->CTZ_SEQLIN)	
	ElseIf CTZ->CTZ_LINHA > CT2->CT2_LINHA
		cSeqLin	:= Soma1(CT2->CT2_LINHA)
	Else
		cSeqLin	:= "001"	
	EndIf
Else
	cSeqLin	:= "001"
EndIf
	

RestArea(aSaveArea)

Return(cSeqLin)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb210CInd³ Autor ³ Simone Mie Sato       ³ Data ³ 26.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria indice temporario na tabela CT2=>SOMENTE PARA CODEBASE |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct210CInd	                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ctba210                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb210CInd()

Local cChaveD	:= ""
Local cChaveC	:= ""
Local cIndTmp1	:= ""
Local cIndTmp2	:= ""

Local nIndex	:= 0

dbSelectArea("CT2")

cIndTmp1 := CriaTrab(nil,.F.)
cChaveD 	:= "CT2_FILIAL+DTOS(CT2_DATA)+CT2_DC+CT2_CLVLDB+CT2_ITEMD+CT2_CCD+CT2_DEBITO+CT2_TPSALD+CT2_MOEDLC"	
IndRegua("CT2",cIndTmp1,cChaveD,,)

dbCommit()                                  
nIndex	:= RetIndex("CT2")

cIndTmp2 := CriaTrab(nil,.F.)
cChaveC		:= "CT2_FILIAL+DTOS(CT2_DATA)+CT2_DC+CT2_CLVLCR+CT2_ITEMC+CT2_CCC+CT2_CREDIT+CT2_TPSALD+CT2_MOEDLC"	
IndRegua("CT2",cIndTmp2,cChaveC,,)

dbCommit()                                  
nIndex	:= RetIndex("CT2")

dbSetIndex(cIndTmp1+OrdBagExt())
dbSetIndex(cIndTmp2+OrdBagExt())

dbSelectArea( "CT2" )     

Return(nIndex)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb210Seek³ Autor ³ Simone Mie Sato       ³ Data ³ 26.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Dar seek na tabela.                                         |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb210Seek                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Ctb210Seek                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb210Seek(dDataLp,cClVl,cItem,cCusto,cConta,cMoeda,cTpSaldo,cTipo)

Local aSaveArea	:= GetArea()             
Local nRet		:= 0 
Local cQuery	:= ""
Local cSelRecno	:= ""

cSelRecno := "cSelRecno"

cQuery	:= " SELECT R_E_C_N_O_ RECNOS "
cQuery	+= " FROM " + RetSqlName("CT2")
cQuery	+= " WHERE CT2_FILIAL = '" + xFilial("CT2") + "' AND " 

If cTipo == "1"
	cQuery	+= " CT2_DEBITO = '" + cConta + "' AND "
ElseIf cTipo == "2"
	cQuery	+= " CT2_CREDIT = '" + cConta + "' AND "
EndIf

cQuery	+= " CT2_DATA = '" + DTOS(dDataLP)+ "' AND " 

If cTipo == "1"
	cQuery	+= " CT2_CLVLDB = '" + cClVl + "' AND "
	cQuery	+= " CT2_ITEMD	= '" + cItem + "' AND "
	cQuery	+= " CT2_CCD = '" + cCusto	+ "' AND "
ElseIf cTipo == "2"
	cQuery	+= " CT2_CLVLCR = '" + cClVl + "' AND "
	cQuery	+= " CT2_ITEMC	= '" + cItem + "' AND "
	cQuery	+= " CT2_CCC = '" + cCusto	+ "' AND "
EndIf                           
cQuery	+= " CT2_MOEDLC = '"+cMoeda+"' AND "
cQuery	+= " CT2_TPSALD = '"+cTpSaldo+"' AND "
cQuery	+= " D_E_L_E_T_ = ' ' " 

cQuery := ChangeQuery(cQuery)
		
			
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSelRecno,.T.,.F.)

TcSetField("cSelRecno","RECNOS","N",18,0)
	
nRet := (cSelRecno)->RECNOS

If ( Select ( "cSelRecno" ) <> 0 )
	dbSelectArea ( "cSelRecno" )
	dbCloseArea ()
Endif			

RestArea(aSaveArea)

Return(nRet)

/*/      	
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct210UpdX5³ Autor ³ Simone Mie Sato       ³ Data ³ 05.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o SX5 indicando se eh zeram. c/cta ponte ou nao.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct210UpdX5()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct210UpdX5()

Local aSaveArea	:= GetArea()

Local cQuery	:= ""
Local Ct210UpdX5:= ""
Local cChar		:= ""           
Local cCampo	:= ""

Local dDataLP	:= CTOD("  /  /  ")

Local cLote		:= ""
Local cSubLote	:= ""
Local cDoc		:= ""
Local cTpSald	:= ""
Local cEmpOri	:= ""
Local cFilOri	:= ""
Local cMoeda	:= ""           

// Caso a tabela LP exista na tabela CW0 o processo será feito por ela e nao pela SX5
If CtLPCW0Tab()
	CtUpdLPCW0()  	
EndIf	           

Restarea(aSaveArea)
Return

/*/      	
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbMaxDtLp³ Autor ³ Simone Mie Sato       ³ Data ³ 05.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna qual eh a ultima data de zeramento SEM conta ponte. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbMaxDtLp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbMaxDtLp()

Local aSaveArea	:= GetArea()
Local dMaxData	:= CTOD("  /  /  ")                                      
Local cCampo 	:= ""
Local cIdioma   := ""

// Caso a tabela LP exista na tabela CW0 o processo será feito por ela e nao pela SX5
If CtLPCW0Tab()
	dMaxData := CtMaxLPCW0() 
Else
	cIdioma  := Upper(Left(FWRetIdiom(), 2))	
	Do Case 
	Case cIdioma == 'PT'
		cCampo	:= "SX5->X5_DESCRI"
	Case cIdioma == 'ES'
		cCampo	:= "SX5->X5_DESCSPA"
	Case cIdioma == 'EN'
		cCampo	:= "SX5->X5_DESCENG"
	EndCase
	
	dbSelectArea("SX5")
	dbSetOrder(1)   
	If MsSeek(xFilial()+"LP"+cEmpAnt+cFilAnt,.F.)
		While !Eof() .And. SX5->X5_FILIAL == xFilial() .And. Subs(SX5->X5_CHAVE,1,2) == cEmpAnt .And. ;
			Subs(SX5->X5_CHAVE,3,2) == cFilAnt 
			
			If Subs(&(cCampo),12,1) == "Z"
				dMaxData	:= STOD(Subs(&(cCampo),1,8))
			EndIf
					
			dbSkip()
		End
	EndIf
	RestArea(aSaveArea)
EndIf

Return(dMaxData)
           
