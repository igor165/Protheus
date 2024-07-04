#Include "CTBA410.CH"
#Include "PROTHEUS.CH"               

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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA410   บAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera็ใo de Lan็amentos de Encerramento/Abertura de exerci- บฑฑ
ฑฑบ          ณ cios                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณData    ณ BOPS     ณ Motivo da Alteracao                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJonathan Glzณ24/06/15ณPCREQ-4256ณSe elimina funcion AjustaSX1() y la   ณฑฑ
ฑฑณ            ณ        ณ          ณinclucion del help (SX1)en la funcion ณฑฑ
ฑฑณ            ณ        ณ          ณCtb410Proc(),por motivo de adecuacion ณฑฑ
ฑฑณ            ณ        ณ          ณa fuentes a nuevas estructuras SX paraณฑฑ
ฑฑณ            ณ        ณ          ณVersion 12.                           ณฑฑ
ฑฑณJonathan Glzณ09/10/15ณPCREQ-4261ณMerge v12.1.8                         ณฑฑ
ฑฑณM. Camargo  ณ02/12/16ณSERINN001-ณAjuste por sustituci๓n Tablas Temp    ณฑฑ
ฑฑณ            ณ        ณ155       ณCTREE. Funcion afectada: CTB410CRTRB  ณฑฑ
ฑฑบRa๚l Ortiz  ณ06/02/18ณDMICNS-821ณAl generar el cierre de asientos,     บฑฑ
ฑฑบ            ณ        ณ(ARG)     ณconsiderar correctamente las fechas deบฑฑ
ฑฑบ            ณ        ณ          ณcierre seleccionadas en los parametrosบฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function CTBA410()
Local aSays 		:= {}
Local aButtons		:= {}
LOCAL nOpca    		:= 0
Local cMens			:= ""
Local oProcess
Local cFunction		:= "CTBA410"
Local cPerg			:= "CTB410"
Local cTitle		:= STR0001	//-- "Lan็amentos de Encerramento/Abertura de exercicios"
Local cDescription	:= 	STR0002 + CRLF + CRLF +;	//-- "Esta rotina irแ gerar os lancamentos contabeis abertura e encerramento de exercicios."
						STR0015 + CRLF +;			//-- "Recomenda-se a verifica็ใo pr้via ou reprocessamento de saldos antes "
						STR0016 + CRLF +;			//-- "de executar esta rotina."
						STR0017 					//-- "Visualizar, para o Log de processamento"

Local aInfoCustom	:= {}
Local bProcess		:= {}

Private cCadastro 	:= OemToAnsi(STR0001)  //-- "Lan็amentos de Encerramento/Abertura de exercicios"
PRIVATE cString   	:= "CT2"
PRIVATE cDesc1    	:= OemToAnsi(STR0002)  //-- "Esta rotina irแ gerar os lancamentos contabeis abertura e encerramento de exercicios."
PRIVATE cDesc2    	:= ""
PRIVATE cDesc3    	:= ""
PRIVATE titulo    	:= OemToAnsi(STR0003)  //-- "Simulacao da Apuracao"
PRIVATE cCancel   	:= OemToAnsi(STR0004)  //-- "***** CANCELADO PELO OPERADOR *****"
PRIVATE nomeprog  	:= "CTBA410"
PRIVATE aLinha    	:= { },nLastKey := 0
Private oTmpTable //mc
If ( !AMIIn(34) )		//-- Acesso somente pelo SIGACTB
	Return
EndIf

If GetNewPar("MV_ATUSAL","S") == "N"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Mostra tela de aviso - Verificar se os saldos foram atualizados.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cMens := OemToAnsi(STR0011)+chr(13)  //-- "CASO A ATUALIZACAO DOS  SALDOS BASICOS  NAO  SEJA  FEITA  NA "
	cMens += OemToAnsi(STR0012)+chr(13)  //-- "DIGITACAO DOS LANCAMENTOS (MV_ATUSAL = 'N'), FAVOR VERIFICAR "
	cMens += OemToAnsi(STR0013)+chr(13)  //-- "SE OS SALDOS ESTAO ATUALIZADOS !!!!"
	
	MsgInfo(cMens,OemToAnsi(STR0014))  //-- "ATEN€O"
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros                         ณ
//ณ mv_par01 // Data de Encerramento                             ณ
//ณ mv_par02 // Data de Abertura                                 ณ
//ณ mv_par03 // Numero do Lote			                         ณ
//ณ mv_par04 // Numero do SubLote		                         ณ
//ณ mv_par05 // Numero do Documento                              ณ
//ณ mv_par06 // Cod. Historico Padrao                            ณ
//ณ mv_par07 // Moedas        			                         ณ
//ณ mv_par08 // Qual Moeda?                                      ณ
//ณ mv_par09 // Tipo de Saldo 				                     ณ
//ณ mv_par10 // Da Conta  		        						 ณ
//ณ mv_par11 // Ate a Conta                             		 ณ
//ณ mv_par12 // Encerrar calendarios                             ณ
//ณ mv_par13 // Processo:Gerar/Estornar lanctos                  ณ
//ณ mv_par14 // Reproces. Saldos ?                               ณ
//ณ mv_par15 // Seleciona Filiais?	                     		 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte("CTB410",.F.)

AADD(aSays,OemToAnsi( STR0002 ) )	//"Esta rotina irแ gerar os lancamentos contabeis abertura e encerramento de exercicios."
AADD(aSays,"" )	//""
AADD(aSays,OemToAnsi( STR0015 ) )	//"Recomenda-se a verifica็ใo pr้via ou reprocessamento de saldos antes "
AADD(aSays,OemToAnsi( STR0016 ) )	//"de executar esta rotina."
AADD(aSays,STR0017) //"Visualizar, para o Log de processamento"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa o log de processamento                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ProcLogIni( aButtons )

AADD(aButtons, { 5,.T.,{|| Pergunte("CTB410",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CtbOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )
	                                    
If nOpca == 1
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ProcLogAtu("INICIO")
   
	If MV_PAR15 == 1 .And. !Empty(xFilial("CT2")) // Seleciona filiais
		oProcess := MsNewProcess():New({|lEnd| Ctb410Fil(oProcess,Nil)},"","",.F.)
	Else
		oProcess := MsNewProcess():New({|lEnd| Ctb410Proc(oProcess)},"","",.F.)
	EndIf
	
	oProcess:Activate()		

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ProcLogAtu("FIM")

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtb410Fil บAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Sele็ใo de filiais e execu็ใo neste modo                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ctb410Fil(oProcess,oSelF)
Local cFilIni 	:= cFIlAnt
Local aArea		:= GetArea()
Local aSM0 		:= Iif( FindFunction( "ADMGETFIL" ) , ADMGETFIL() , {} )
Local nContFil := 0
Local aCalend	:= {}
Local cProcFil	:= ""

If Len( aSM0 ) > 0
	If mv_par12 == 1 .AND. mv_par13 == 1
		aCalend := CtbCalend(aSM0)
	EndIf
	For nContFil := 1 to Len(aSM0)	
		
		If cProcFil != xFilial( "CTG", aSM0[nContFil] )
			cFilAnt := aSM0[nContFil]
			ProcLogAtu(STR0064,STR0047+ cFilAnt)//" EXECUTANDO A APURACAO DA FILIAL "
			Ctb410Proc(oProcess,oSelf)			
			cProcFil := xFilial( "CTG", aSM0[nContFil] )
		EndIf			
		
	Next nContFil
	
	If Len(aCalend) > 0 
		A410Calend( oProcess, oSelf, aCalend)
	EndIf
	cFIlAnt := cFilIni
Else
	ProcLogAtu("ERRO",STR0014,STR0065 )     //"Aten็ใo!"###"Nenhuma empresa/filial selecionada!"
Endif

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA410CalendบAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Encerramento de Calendแrios selecionados                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A410Calend( oObj, oSelf, aCalend, lEstorno )
Local aAreas 	:= {CTG->(GetArea()),;
					GetArea()}
Local lObj 		:= ValType(oObj) == "O"
Local nTotRegua	:= Len(aCalend)
Local nI  
DEFAULT lEstorno := .F.

If !lEstorno	
	ProcLogAtu(STR0064,STR0066 )
Else
	ProcLogAtu(STR0064,STR0067 ) 
EndIf	

If lObj
	oObj:SetRegua2(nTotRegua)
EndIf

CTG->(DbSetOrder(1)) //-- CTG_FILIAL+CTG_CALEND+CTG_EXERC+CTG_PERIOD
For nI := 1 To Len(aCalend)
	If CTG->(MsSeek(aCalend[nI]))
		While &("CTG->(CTG_FILIAL+CTG_CALEND+CTG_EXERC)") == SubStr(aCalend[nI],1,Len(&("CTG->(CTG_FILIAL+CTG_CALEND+CTG_EXERC)")))
			If lObj
				oObj:IncRegua2(OemToAnsi(STR0048)+ " " +CTG->(CTG_EXERC+"/"+CTG_PERIOD))//#"Passo 3 -> Encerrando Exercicios... "
			EndIf	
			ProcLogAtu(STR0064,STR0068 + CTG->(CTG_FILIAL+"/"+CTG_CALEND+"/"+CTG_EXERC+"/"+CTG_PERIOD) )
			RecLock("CTG",.F.)
			
			If !lEstorno
				CTG->CTG_STATUS := "2" 
			Else
				CTG->CTG_STATUS := "1"
			EndIf
			
			CTG->(MsUnLock())	
			ProcLogAtu(STR0064,STR0069 + CTG->(CTG_FILIAL+"/"+CTG_CALEND+"/"+CTG_EXERC+"/"+CTG_PERIOD) )
			CTG->(DbSkip())	
		
		EndDo
	EndIf
Next nI
	
ProcLogAtu(STR0064,STR0070 )

aEval(aAreas, { |x| RestArea(x) })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtb410ProcบAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processo principal de gera็ใo de lan็amentos de encerramen-บฑฑ
ฑฑบ          ณ to e abertura de exercํcios. Efetua chamada เ fun็ใo de    บฑฑ
ฑฑบ          ณ estorno                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctb410Proc(oObj,oSelf)

Local nx,nProcCnt
Local dLastProc
Local lAbertura
Local dDataILP		:= mv_par01		//Data Inicial de Apura็ใo
Local dDataFLP		:= mv_par01		//Data Final de Apuracao
Local cLote 		:= mv_par03		//Num. do lote que sera gerado os lancamentos
Local cSubLote		:= mv_par04		//Num. do sublote que sera gerado os lancamentos
Local cDoc			:= mv_par05		//Num. do doc. que sera gerado os lancamentos
Local nLinha		:= 0
Local cLinha		:= '000'
Local cLinhaLan		:= '001'
Local cSeqLan		:= "001"
Local cProcFil		:= ""

Local lFirst 		:= .T.

Local nRecLan		:= 0
Local nOpcGRV 		:= 3			/// 3 = INCLUI LANCAMENTO / 4 = ALTERA
Local cHP			:= mv_par06		//Historico Padrao utilizado nos lancamentos
Local cContaIni		:= mv_par10		//Conta Inicial
Local cContaFim		:= mv_par11		//Conta Final
Local lMoedaEsp		:= Iif(mv_par07==2,.T.,.F.)	//Moedas
Local cMoeda		:= StrZero(Val(mv_par08),2)			//Define qual a moeda especifica
Local cTpSaldo		:= mv_par09		//Tipo de Saldo.
Local lPergOk		:= .T.
Local lClVl			:=	CtbMovSaldo("CTH")
Local lItem			:=	CtbMovSaldo("CTD")
Local lCusto		:= 	CtbMovSaldo("CTT")
Local aCtbMoeda 	:= {}
Local nInicio		:= 0
Local nFinal		:= 0
Local cDescHP		:= ""                                        
Local dDataAILP		:= dDataILP-1
Local dDataIRep		:= dDataFLP
Local dDataFRep		:= dDataFLP
Local lSlbase		:= Iif(GETMV("MV_ATUSAL")=="N",.F.,.T.)

////////////////////////////////////////////////////////////////////////////////////////
Local lObj		:= ValType(oObj) == "O"
Local cExerc	:= alltrim(str(Year(dDataFLP),4))

Local lJaProc 	:= .F.			/// se a rotina jม comecou a transferir registros p/ cv6 ou nรo
Local lCriaTRB	:= .T.			/// se deve ou nao criar um trb novo
Local lNovoTRB	:= .T.			/// se foi cria

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
Local lCtaOk	:= .T.
Local cDigPon	:= ""
Local aCriter	:= {}         		/// CRITERIO DE CONVERSAO DA CONTA DE ORIGEM (FORA DE USO)
Local aCritLP	:= {}				/// CRITERIO DE CONVERSAO DA CONTA DE APURACAO (FORA DE USO)
Local aCritPon	:= {}               /// CRITERIO DE CONVERSAO DA CONTA PONTE (FORA DE USO)   

Local aFilters	:= {}

Local lCTZDeb 	:= .F.

Local lGrvCT7		:= IIf(ExistBlock("GRVCT7"),.T.,.F.) // Aqui
Local lGrvCT3		:= IIf(ExistBlock("GRVCT3"),.T.,.F.) // Aqui
Local lGrvCT4		:= IIf(ExistBlock("GRVCT4"),.T.,.F.) // Aqui
Local lGrvCTI		:= IIf(ExistBlock("GRVCTI"),.T.,.F.) // Aqui
Local lEstorno		:= mv_par13 == 2
Local lAtuSldCT7	:= .T.
Local lAtuSldCT3	:= .T.
Local lAtuSldCT4	:= .T.
Local lAtuSldCTI	:= .T.
Local aOutrEntid
Local aEntid
Local lFiltra		:= .F.
Local lFilCT		:= .F.
Local aCalend		:= {}

PRIVATE aCols 		:= {} // Utilizada na conversao das moedas
Private cSeqCorr  := ""

If cPaisLoc == 'CHI' .and. Val(cLinha) < 2  // a partir da segunda linha do lanc., o correlativo eh o mesmo
	cSeqCorr := CTBSqCor( CTBSubToPad(cSubLote) )
EndIf

//-- Sele็ใo dos calendแrios, se nใo forem selecionadas vแrias filiais.
If mv_par12 == 1 .And. mv_par15 == 2 .AND. !lEstorno
	aCalend := CtbCalend()
EndIf

If mv_par15 == 1 .And. Empty(xFilial("CT2"))
	ProcLogAtu(STR0064,STR0071) 
EndIf

////////////////////////////////////////////////////////////////////////////////////////

// Sub-Lote somente eh informado se estiver em branco
mv_par04 := If(Empty(GetMV("MV_SUBLOTE")), mv_par04, GetMV("MV_SUBLOTE"))

If lMoedaEsp					// Moeda especifica
	cMoeda	:= mv_par08
	aCtbMoeda := CtbMoeda(cMoeda)
	If Empty(aCtbMoeda[1])
		Help("",1,"NOMOEDA",,OemtoAnsi(STR0055),1,0)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza o log de processamento com o erro  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ProcLogAtu("ERRO","NOMOEDA",Ap5GetHelp("NOMOEDA"))
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


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ ANTES DE INICIAR O PROCESSAMENTO, VERIFICO OS PARAMETROS.	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Data de Apuracao nao preenchida.
For nProcCnt :=  1 To 2 
	                
	lAbertura := (nProcCnt==2)
	dDataFLP := If( !lAbertura, mv_par01, mv_par02 )
	If Empty(dDataFLP)                              
		Help("",1,"NOCTBDTLP",,OemtoAnsi(STR0056),1,0)
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza o log de processamento com o erro  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ProcLogAtu("ERRO","NOCTBDTLP",Ap5GetHelp("NOCTBDTLP"))
		Return(.F.)
	ElseIf !lEstorno
		//Verificar se o calendario da data solicitada esta encerrado
		lPergOk	:= CtbValiDt(1,dDataFLP,,cTpSaldo)
		IF (cTpSaldo<>"1" .AND. cPaisLoc=="ARG")
		 Help(NIL, NIL, STR0093, NIL, STR0091, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0092}) 
		 lPergOk=.F.
		Else
		 lPergOk=.T.
		EndIf

		If !lPergOk
			Exit
		EndIf
	EndIf                            
Next	
//Historico Padrao nao preenchido.
If Empty(cHP)	
	Help("",1,"CTHPVAZIO",,OemtoAnsi(STR0057),1,0)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento com o erro  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ProcLogAtu("ERRO","CTHPVAZIO",Ap5GetHelp("CTHPVAZIO"))
	lPergOk := .F.
Else
	dbSelectArea("CT8")
	dbSetOrder(1)
	MsSeek(xFilial("CT8")+cHP)
	If found()
		cDescHP 	:= CT8->CT8_DESC
	Else            

	   	Help(" ",1,"CT210NOHP",,"FILIAL "+cFilAnt,2,0)
					
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza o log de processamento com o erro  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ProcLogAtu("ERRO","CT210NOHP",Ap5GetHelp("CT210NOHP"))	
		lPergOk := .F.
	Endif
Endif                             
	
//Lote nao preenchido.
If Empty(cLote)
	Help("",1,"NOCT210LOT",,OemtoAnsi(STR0058),1,0)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento com o erro  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ProcLogAtu("ERRO","NOCT210LOT",Ap5GetHelp("NOCT210LOT"))
	lPergOk := .F.
Endif
	
//Sub Lote nao preenchido.
If Empty(cSubLote)
	Help("",1,"NOCTSUBLOT",,OemtoAnsi(STR0059),1,0)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento com o erro  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ProcLogAtu("ERRO","NOCTSUBLOT",Ap5GetHelp("NOCTSUBLOT"))
	lPergOk := .F.
Endif
	
//Documento nao preenchido.
If Empty(cDoc)
	Help("",1,"NOCT210DOC",,OemtoAnsi(STR0060),1,0)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento com o erro  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ProcLogAtu("ERRO","NOCT210DOC",Ap5GetHelp("NOCT210DOC"))
	lPergOk := .F.
Else	//Se o documento estiver preenchido, verifico se existe lancamento com mesmo numero
		//de lote, sublote, documento e data
	dbSelectArea("CT2")
	dbSetOrder(1)

	For nProcCnt :=  1 To 2
		                
		lAbertura := (nProcCnt==2)
		dDataFLP := If( !lAbertura, mv_par01, mv_par02 )
		If MsSeek(xFilial()+dtos(dDataFLP)+cLote+cSubLote+cDoc) .AND. !lEstorno
			lPergOk := .F.
			MsgAlert(OemtoAnsi(STR0009))//Data+Lote+Sublote+documento ja existe.
			Exit
	    EndIf
	Next
Endif

If !lEstorno .AND. lPergOk
	lPergOk:= Ct410Vld(dDataILP,dDataFLP)
EndIf
	
//Conta Inicial e Conta Final nao preenchidos.
If Empty(cContaIni) .And. Empty(cContaFim)
	Help("",1,"NOCT210CT",,OemtoAnsi(STR0061),1,0)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento com o erro  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ProcLogAtu("ERRO","NOCT210CT",Ap5GetHelp("NOCT210CT"))
	lPergOk := .F.
Endif
	
//Se for moeda especifica, verificar se a moeda esta preenchida
If lMoedaEsp
	If Empty(cMoeda)
		Help("",1,"NOCTMOEDA",,OemtoAnsi(STR0062),1,0)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza o log de processamento com o erro  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ProcLogAtu("ERRO","NOCTMOEDA",Ap5GetHelp("NOCTMOEDA"))
		lPergOk := .F.
	Endif
EndIf
	     
//Tipo de saldo nao preenchido
If Empty(cTpSaldo)
	Help("",1,"NO210TPSLD",,OemtoAnsi(STR0063),1,0)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento com o erro  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	proclogatu("ERRO","NO210TPSLD",Ap5GetHelp("NO210TPSLD"))
	lPergOk := .F.
Endif

//Verifica se tem algum saldo basico desatualizado. Definido que essa verificacao so sera
//feita em top connect, pois se fosse fazer em codebase iria degradar muito a performance
//do sistema.
If !lSlBase //So ira fazer a verificacao, caso o parametro MV_ATUSAL esteja com "N"
	For nx := nInicio To nFinal
		dLastProc := GetCv7Date(cTpSaldo,StrZero(nx,2))
		For nProcCnt := 1 To 2
			lAbertura := (nProcCnt==2)
			dDataFLP  := If( !lAbertura, mv_par01, mv_par02 )

			If dDataFLP > dLastProc
				lPergOk := .F.
				MsgAlert(OemToAnsi(STR0010)+"Saldo : "+ cTpSaldo+" Moeda : "+StrZero(nx,2))//"Ha saldos basicos desatualizados. Favor atualizar os saldos."
				Exit
			EndIf
		Next nProcCnt
		If !lPergOk
			Exit
		EndIf
	Next nx
EndIf

//SE OS PARAMETROS NAO ESTIVEREM DEVIDAMENTE PREENCHIDOS
If !lPergOk
	Return
Endif
////////////////////////////////////////////////////////////////////////////////////////
If lEstorno
	CT410Est(oObj,oSelf)
Else
	////////////////////////////////////////////////////////////////////////////////////////
	/// CRIA ARQUIVO DE TRABALHO PARA GUARDAR OS SALDOS A SEREM ZERADOS
	////////////////////////////////////////////////////////////////////////////////////////
	aTpSaldos	:= {cTpSaldo}
	
	
	cArqTRB := "LENC_" + cEmpAnt + cFilAnt + Right( cExerc, 2)
	
	/// CRIACAO DE ARQUIVO TEMPORARIO.
	If ! Ct410CrTrb(cArqTRB,lJaProc,lCriaTRB,@lNovoTRB)
		Return
	EndIf
	
	If Empty(cContaFim)
		cContaFim := Replicate("Z",nTamCta)
	Endif
	
	aAdd(aFilters,{"CT", cContaIni,cContaFim} ) //Da Conta | a Conta
	
	////////////////////////////////////////////////////////////////////
	/// LE OS SALDOS DAS ENTIDADES E GUARDA NO ARQUIVO DE TRABALHO
	////////////////////////////////////////////////////////////////////
	If lNovoTRB
		/// VERIFICO OS SALDOS DA CLASSE DE VALOR (CQ7) GRAVANDO NO TRB.
		If lClvl
			ProcLogAtu(STR0064,STR0072+" CQ7")//"MENSAGEM" "OBTENDO SALDOS DO"
			
			If cPaisLoc == "ARG" .And. funname() == "CTBA410"
				CTB410GTRB('CQ7',dDataILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lMoedaEsp,cMoeda,oSelf)
			Else
				CTB410GTRB('CQ7',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lMoedaEsp,cMoeda,oSelf)
			EndIf
			
			ProcLogAtu(STR0064,STR0073+" CQ7")	//"MENSAGEM" "FIM OBTENDO SALDOS"
		EndIf
		/// VERIFICO OS SALDOS DO ITEM CONTABIL (CQ5) GRAVANDO NO TRB.
		If lItem

			ProcLogAtu(STR0064,STR0072+" CQ5") //"MENSAGEM" "OBTENDO SALDOS DO"

			If cPaisLoc == "ARG" .And. funname() == "CTBA410"
				CTB410GTRB('CQ5',dDataILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lMoedaEsp,cMoeda,oSelf)
			Else
				CTB410GTRB('CQ5',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lMoedaEsp,cMoeda,oSelf)
			EndIf

			ProcLogAtu(STR0064,STR0073+" CQ5")	//"MENSAGEM" "FIM OBTENDO SALDOS DO"
		EndIf
		/// VERIFICO OS SALDOS DO CENTRO DE CUSTO(CQ3) GRAVANDO NO TRB.
		If lCusto

			ProcLogAtu(STR0064,STR0072+" CQ3")

			If cPaisLoc == "ARG" .And. funname() == "CTBA410"
				CTB410GTRB('CQ3',dDataILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lMoedaEsp,cMoeda,oSelf)
			Else
				CTB410GTRB('CQ3',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lMoedaEsp,cMoeda,oSelf)
			EndIf

			ProcLogAtu(STR0064,STR0073+" CQ3")
		EndIf
	
		/// VERIFICO OS SALDOS DA CONTA.(CQ1) GRAVANDO NO TRB.

		ProcLogAtu(STR0064,STR0072+" CQ1")

		If cPaisLoc == "ARG" .And. funname() == "CTBA410"
			CTB410GTRB('CQ1',dDataILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lMoedaEsp,cMoeda,oSelf)
		Else
			CTB410GTRB('CQ1',dDataAILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lMoedaEsp,cMoeda,oSelf)
		EndIf

		ProcLogAtu(STR0064,STR0073+" CQ1")

	EndIf
	////////////////////////////////////////////////////////////////////////////////////////
	/// LE O ARQUIVO DE TRABALHO E GRAVA OS LANวAMENTOS DE APURACAO
	////////////////////////////////////////////////////////////////////////////////////////

	ProcLogAtu(STR0064,STR0074 )
	dbSelectArea("TRB")
	dbSetOrder(1)
	dbGoTop()
	
	If lObj
		oObj:SetRegua2(TRB->(RecCount()))
	EndIf
	
	nExecLin := 0
	
	lFiltra := ValType(aFilters) == "A"
	
	If lFiltra
		lFilCT := Len(aFilters) >= 1 .and. Len(aFilters[1]) >= 3 .and. (!Empty(aFilters[1][2]) .or. !Empty(aFilters[1][3]) )
	EndIf
	
	For nProcCnt :=  1 To 2
		TRB->(DbGoTop())
		                
		lAbertura := (nProcCnt==2)
		dDataILP := If( !lAbertura, mv_par01, mv_par02 )
		dDataFLP := If( !lAbertura, mv_par01, mv_par02 )
		While TRB->(!Eof())
		
			If lFilCT
				If TRB->CONTA < aFilters[1][2] .or. TRB->CONTA > aFilters[1][3]
					TRB->(dbSkip())
					Loop
				EndIf
			EndIf
			
			If lObj
				oObj:IncRegua2(OemToAnsi(STR0021+TRB->MOEDA+STR0022+TRB->TPSALDO))//"Passo 2 -> Gravando lan็amentos Moeda "//" Saldo "
			EndIf
		
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
		    
		    If lAbertura
		    	nSaldo := nSaldo * (-1)
		    EndIf
		    
		    If nSaldo <> 0
				nLinha := DecodSoma1( cLinha )   // a funcao esta no fonte ctbxfuna.prx
		
				If lFirst .or. nLinha > nMAX_LINHA .or. TRB->TPSALDO <> cTpSldAnt .or. TRB->MOEDA <> cMoedAnt
					cMoedAnt	:= TRB->MOEDA
					cTpSldAnt	:= TRB->TPSALDO
				
					Do While ! ProxDoc(dDataFLP,cLote,cSubLote,@cDoc,@CTF_LOCK)
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Caso o Nง do Doc estourou, incrementa o lote         ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						cLote := CtbInc_Lot(cLote, "CTB", .T.) // True para forcar chave pelo modulo CTB

					Enddo
			
					If cPaisLoc == 'CHI' .and. Val(cLinha) < 2  // a partir da segunda linha do lanc., o correlativo eh o mesmo
						cSeqCorr := CTBSqCor( CTBSubToPad(cSubLote) )
					EndIf
			
					lFirst := .F.
					cLinha := "001"
					nLinha := 1
					cSeqLan:= "001"
				EndIf
			
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSUBSTITUI VARIAVEIS DAS           ณ
				//ณ- ENTIDADES PONTE                 ณ
				//ณ- ENTIDADES DE APURACAO           ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
				lPergOk := .T.
				cCtaPon	:= cSpacCT
				
				Ct410ValCt(TRB->CONTA,@cCtaPon,@cDigPon,@lCtaOk,@aCriter,@aCritPon,@aCritLP)
			
				cCCPon	:= cSpacCC
				cCCLP	:= cSpacCC
				If lPergOk .and. lCusto .and. !Empty(TRB->CUSTO)
					Ct410ValCC(TRB->CUSTO,@cCCPon,@cCCLP,@lPergOk)
				EndIf
			
				cItemPon	:= cSpacIT
				cItemLP		:= cSpacIT
				If lPergOk .and. lItem .and. !Empty(TRB->ITEM)
					Ct410ValIt(TRB->ITEM,@cItemPon,@cItemLP,@lPergOk)
				EndIf
			
				cClVlPon	:= cSpacCL
				cClVlLP		:= cSpacCL
				If lPergOk .and. lClvl .and. !Empty(TRB->CLVL)
					Ct410ValCV(TRB->CLVL,@cClVlPon,@cClVlLP,@lPergOk)
				EndIf
			
				/// SE HOUVER ALGUM PROBLEMA COM AS ENTIDADES PONTE/APURACAO DO CADASTRO
				If !lPergOk
					/// PASSA PARA O PROXIMO DO TRB SEM MARCAR COMO "Jม PROCESSADO"
					/// AVALIAR CORREวรO NO CADASTRO E PROCESSAMENTO Sำ DOS PENDENTES PELO TRB
					TRB->(dbSkip())
					Loop
				EndIf
							
				If nSaldo > 0
					cTipo		:= "1"
					cDebito	:= TRB->CONTA
					cCustoDeb	:= TRB->CUSTO
					cItemDeb	:= TRB->ITEM
					cClVlDeb	:= TRB->CLVL
			
					cCredito	:= cSpacCT
					cCustoCrd	:= cSpacCC
					cItemCrd	:= cSpacIT
					cClVlCrd	:= cSpacCL
			
					lCTZDeb := .T.
				Else
					cTipo		:= "2"
					cDebito	:= cSpacCt
					cCustoDeb	:= cSpacCC
					cItemDeb	:= cSpacIT
					cClVlDeb	:= cSpacCL
					
					cCredito	:= TRB->CONTA
					cCustoCrd	:= TRB->CUSTO
					cItemCrd	:= TRB->ITEM
					cClVlCrd	:= TRB->CLVL
			
					lCTZDeb := .F.
				EndIf
				
				//Grava lancamento na moeda 01
				nSaldo 		:= ABS(nSaldo)
				nMoedAtu	:= VAL(TRB->MOEDA)
			    
			    //////////////////////////////////////////////////////////////////////////////////////////
			    //////////////////////////////////////////////////////////////////////////////////////////
				If TRB->MOEDA == "01"

					ProcLogAtu(STR0064,STR0075 )

					aOutrEntid 	:= CtbOutrEnt(.F., "TRB")
					aEntid 		:= aOutrEntid[1]
		
					//////////////////////////////////////////////////////////////////////////////////////////
					/// FUNCAO GRAVACTx AINDA ESTA GRAVANDO SALDO ANTERIOR INCORRETO QDO Jม EXISTE LANC. NO DIA DE LP
					/// CHAMA A GRAVSALDO PARA ATUALIZAR OS ACUMULADOS CORRETAMENTE E
					/// CHAMA REPROCESSAMENTO DO DIA DE APURACAO AO FINAL DO PROCESSAMENTO PARA ACERTAR SLD.ANTERIOR DO DIA.
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ	/// GRAVA SALDO RELATIVO AO LANวAMENTO  (CTx_LP = 'Z')                   ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
						lAtuSldCT7,lAtuSldCT3,lAtuSldCT4,lAtuSldCTI,,"+"/*cOperacao*/, aEntid)
			

					ProcLogAtu(STR0064,STR0076 )

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณPREPARA VARIAVEIS PARA INCLUSAO/ALTERACAO DE LANCAMENTO NO CT2ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	

					ProcLogAtu(STR0064,STR0077+" (01)" )
		
					nOpcGRV := 3
					cLinhaLan := cLinha ///SE HOUVER CONT. DE HISTORICO GRAVA CTZ NA LINHA DE LANวAMENTO
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณGRAVA LANCAMENTO DE APURACAO NO CT2ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					aCols := { { "01", " ", nSaldo, "2", .F., nSaldo } }
		
					ProcLogAtu(STR0064,STR0078 )  //"GRAVAวรO DO LANวAMENTO (01)"
		
					BEGIN TRANSACTION
					
					GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
							cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nSaldo,cDescHP,;
							TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,,,,,,"CTBA410",.F., , ,dDataFLP,@nRecLan)
			
				 	lGravouLan := .T.
				 				
					ProcLogAtu(STR0064,STR0079 )

					END TRANSACTION
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณATUALIZA FLAG (CTx_LP e CTx_DTLP)                   ณ
					//ณNOS REGISTROS DE SALDO NO PERIODO.                  ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

					ProcLogAtu(STR0064,STR0080)

					Ct410FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA)

					ProcLogAtu(STR0064,STR0081 )

					ProcLogAtu(STR0064,STR0082+" (01)" )

						///////////////////////////////////////////////////////////////
				Else	/// Grava Lancamento na moeda 0X com valor zerado na moeda 01 /
						///////////////////////////////////////////////////////////////

					ProcLogAtu(STR0064,STR0077+" ("+TRB->MOEDA+")" )

					If val(TRB->MOEDA) > 2
						nForaCols	:= VAL(TRB->MOEDA)-2
					Else
						nForaCols	:= 0
					EndIf
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณPREPARA VARIAVEIS PARA INCLUSAO/ALTERACAO DE LANCAMENTO NO CT2ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				    nOpcGRV := 3
					cLinhaLan := cLinha ///SE HOUVER CONT. DE HISTORICO GRAVA CTZ NA LINHA DE LANวAMENTO
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณGRAVA LANCAMENTO DE APURACAO - RELATIVO A MOEDA 01 COM VALOR ZERADOณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					aCols := { { "01", " ", 0.00, "2", .F., 0 },{ TRB->MOEDA, "4", nSaldo, "2", .F., nSaldo } }
			        
					BEGIN TRANSACTION
			
					If nOpcGrv <> 4	/// NAO PRECISA ALTERAR SE O VALOR NA MOEDA 01 ษ ZERO
						GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,'01',cHP,cDebito,cCredito,;
							  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
							  TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,0,,,,,"CTBA410",.F., , ,dDataFLP)
					EndIf
			        
					/// FUNCAO GRAVACTx AINDA ESTA GRAVANDO SALDO ANTERIOR INCORRETO QDO Jม EXISTE LANC. NO DIA DE LP
					/// CHAMA A GRAVSALDO PARA ATUALIZAR OS ACUMULADOS CORRETAMENTE E
					/// CHAMA REPROCESSAMENTO DO DIA DE APURACAO AO FINAL DO PROCESSAMENTO PARA ACERTAR SLD.ANTERIOR DO DIA.
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ	/// GRAVA SALDO RELATIVO AO LANวAMENTO (CTx_LP = 'Z')                    ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
						lAtuSldCT7,lAtuSldCT3,lAtuSldCT4,lAtuSldCTI,,"+"/*cOperacao*/, aEntid)
						  
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณGRAVA LANCAMENTO DE APURACAO NO CT2ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					cLinha := cLinhaLan			/// GRAVA LANCAMENTO DA MOEDA 0X NA MESMA LINHA DA MOEDA 01
					GravaLanc(dDataFLP,cLote,cSubLote,cDoc,@cLinha,cTipo,TRB->MOEDA,cHP,cDebito,cCredito,;
						  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
						  TRB->TPSALDO,@cSeqLan,nOpcGrv,.F.,aCols,cEmpAnt,cFilAnt,nForaCols,,,,,"CTBA410",.F.,,,dDataFLP,@nRecLan)
			
					END TRANSACTION
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณATUALIZA FLAG (CTx_LP e CTx_DTLP)                   ณ
					//ณNOS REGISTROS DE SALDO NO PERIODO.                  ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					Ct410FlgLP(TRB->CONTA,TRB->CUSTO,TRB->ITEM,TRB->CLVL, dDataILP, TRB->TPSALDO, dDataFLP, TRB->MOEDA)
		
					ProcLogAtu(STR0064,STR0082+" ("+TRB->MOEDA+")" )
	  
					lGravouLan := .T.
				EndIf
			EndIf
		
			If nExecLin <= 0 .or. nExecLin >= 2	/// Se houve quebra em 2 linhas (pois Deb e Cred estavam iguais) vai manter na mesma conta.
	
				ProcLogAtu(STR0064,STR0083 )
		
				RecLock("TRB",.F.)
				Field->JAPROC := "S"
				TRB->(MsUnlock())
			 
				TRB->(dbSkip())
				nExecLin := 0
		
				ProcLogAtu(STR0064,STR0084 )

			EndIf	
		EndDo
	Next nProcCnt
	
	dDataILP := mv_par01
	dDataFLP := mv_par01
	
	ProcLogAtu(STR0064,STR0085 )

	If lGravouLan
		
		//Chamo o Reprocessamento, se tiver saldos com data posterior ao zeramento.
		//Somente atualizo os saldos basicos
		If ( mv_par14 == 1 ) .AND. !Empty(dDataFRep)
			ProcLogAtu(STR0064,STR0086 )	
			CTBA190(.T.,dDataIRep,dDataFRep,cFilAnt,cFilAnt,cTpSaldo,lMoedaEsp,cMoeda)
			ProcLogAtu(STR0064,STR0087 )
		EndIf
	EndIf
		
	ProcLogAtu(STR0064,STR0088 )

	///	APAGA O ARQUIVO DE TRABALHO
	dbSelectArea("TRB")
	dbCloseArea()
	oTmpTable:Delete()

	ProcLogAtu(STR0064,STR0089 )

EndIf //-- lEstorno
//-- Encerra os Exercicios selecionados
If mv_par12 == 1 .And. mv_par15 == 2
	If Len(aCalend) > 0 
		A410Calend( oObj, oSelf, aCalend)
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt410VldบAutor  ณ Leandro Dourado        บ Data ณ  03/02/12 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se a rotina jแ foi executada.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Ct410Vld(dDataILP,dDataFLP)
Local lDefTop 		:= IIF( FindFunction("IfDefTopCTB"), IfDefTopCTB(), .F.) // verificar se pode executar query (TOPCONN)
Local aSaveArea	:= GetArea()
Local aSaveCT2		:= CT2->(GetArea())
Local cQuery		:= ""
Local cAliasTMP	:= ""
Local lRet			:= .T.

dbSelectArea("CT2")
dbSetOrder(1)
CT2->(DbGoTop())

cAliasTMP 	:= GetNextAlias()
	
cQuery		:= "SELECT COUNT(CT2_ROTINA) CONTADOR "
cQuery		+= "FROM "+RetSqlName("CT2")
cQuery		+= " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' AND CT2_DATA >= '"+DTOS(dDataILP)+"' AND CT2_DATA <='"+DTOS(dDataFLP)+"' AND CT2_ROTINA='CTBA410' AND D_E_L_E_T_ <> '*'"
cQuery 		:= Changequery(cQuery)
		
If ( Select ( cAliasTMP ) > 0 )
	dbSelectArea ( cAliasTMP )
	dbCloseArea ()
Endif
			
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.F.)
	
(cAliasTMP)->(DbGoTop())
	
If (cAliasTMP)->CONTADOR > 0
	lRet := .F.
	Help('',1,'JAEXECUTOU',,OemtoAnsi(STR0054),2,0) //Essa rotina jแ foi executada para esse perํodo, favor utilizar a op็ใo de estorno antes de utilizแ-la novamente.
EndIf
		
dbSelectArea("CT2")
dbCloseArea()
	
RestArea(aSaveCT2)
RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt410CrTrbบAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria arquivo de Trabalho                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ct410CrTrb(cNomeArq,lJaProc,lCriaTRB,lNovoTRB)
Local cTrb		:= ""
Local aCampos	:=  {}
Local aTamVlr	:= {}

Local cTitMsg 	:= ""
Local cMsg	  	:= ""

Local cCpoDeb 	:= ""
Local cCpoCrd 	:= ""
Local nInc		:= 0
Local nQtdEntid	:= If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
Local oTrb := Nil 
DEFAULT lNovoTRB := .F.

aTamVlr := TamSX3("CQ1_DEBITO")

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
				


// MC
If oTmpTable <> Nil
	oTmpTable:Delete()
	lNovoTRB := .T.
	lCriaTRB := .T.
EndIf

//MC

cArqIND1 := Left(cArqTRB,5)+Right(cArqTRB,2)+"A"
cArqIND2 := Left(cArqTRB,5)+Right(cArqTRB,2)+"B"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Crio arq. de trab. p/ gravar as inconsistencias.           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                        

If lCriaTRB //MC
	oTmpTable := FWTemporaryTable():New("TRB") //MC
	oTmpTable:SetFields( aCampos ) //MC	
	oTmpTable:AddIndex("TRB1", {"TPSALDO","MOEDA","CONTA","CUSTO","ITEM","CLVL","IDENT"}) //MC
	oTmpTable:AddIndex("TRB2", {"TPSALDO","MOEDA","IDENT","CONTA","CUSTO","ITEM","CLVL"}) //MC
	oTmpTable:Create()
EndIF //MC

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtb410GTrbบAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica็ใo de Saldos e grava็ใo destes em arquivo de      บฑฑ
ฑฑบ          ณ Trabalho                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTB410GTrb(cAlias,dDataILP,dDataFLP,aTpSaldos,oObj,lCusto,lItem,lClvl,aFilters,lMoedaEsp,cMoedaEsp,oSelf)
Local lObj 		:= ValType(oObj) == "O"
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

Local aSldAtu	:= {}
Local nDebTrb	:= 0 
Local nCrdTrb	:= 0
Local nTrbSlD	:= 0
Local nTrbSlC	:= 0
Local cKeyAtu	:= ""

Local lFiltra	:= ValType(aFilters) == "A"
Local lFilCT	:= .F.
Local lVai		:= .F.
Local lApZero	:= GetNewPar( "MV_CTAPMVZ" , .T. )

DEFAULT dDataILP:= CTOD("01/01/80")-1

If lFiltra
	lFilCT := Len(aFilters) >= 1 .and. Len(aFilters[1]) >= 3 .and. (!Empty(aFilters[1][2]) .or. !Empty(aFilters[1][3]) )
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
	/// SE FOR MOEDA ESPECอFICA INICIA PELA MOEDA INDICADA
	nMoedaIni := Val(cMoedaEsp)
EndIf

For nMoedAtu := nMoedaIni to __nQuantas
	cMoedAtu := STRZERO(nMoedAtu,2)

	//// FAZ O PROCESSAMENTO PARA TODOS OS TIPOS DE SALDOS
	For nTpSldAtu := 1 to Len(aTpSaldos)
		// cTpSldAtu := STRZERO(nTpSldAtu,1)
		//
		cTpSldAtu := aTpSaldos[nTpSldAtu]

		If lObj
			oObj:SetRegua2(nTotRegua)			 				
		EndIf
		
		If lFilCT
			MsSeek(cFilAlias+aFilters[1][2],.T.) //Procuro pela primeira conta a ser zerada
		Else
			MsSeek(cFilAlias,.T.) //Procuro pela primeira conta a ser zerada		
		EndIf
		
		While (cAlias)->(!Eof()) .And. (cAlias)->&(cAlias+"_FILIAL") == cFilAlias .and. (If(lFilCT,(cAlias)->&(cAlias+"_CONTA") <= aFilters[1][3],.T.))

			If lObj
				oObj:IncRegua2(OemToAnsi(STR0019+cMoedAtu+STR0020+cTpSldAtu))//#"Passo 1 -> Obtendo Saldos... Moeda "//" Saldo " 
			EndIf

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
			EndIf

			cNxtChav:= IncLast(cChave)		/// DETERMINA A PROXIMA CHAVE DE PESQUISA COM O CODIGO DAS ENTIDADES
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAvalia filtro das entidades para apuracaoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
			If cAlias == 'CQ7'
				If lFilCT
					If CQ7->CQ7_CONTA < aFilters[1][2] .or. CQ7->CQ7_CONTA > aFilters[1][3]
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

			ElseIf cAlias == 'CQ3'
				If lFilCT
					If CQ3->CQ3_CONTA < aFilters[1][2] .or. CQ3->CQ3_CONTA > aFilters[1][3]
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

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤTโ
			//ณApos filtragem , obtem saldos ate a data.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤTโ
			If cPaisLoc == "ARG" .And. funname() == "CTBA410"
				If cAlias == 'CQ7'
					aSldAtu	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)	
				ElseIf cAlias == 'CQ5'
					aSldAtu	:= SaldoCT4(cConta,cCusto,cItem,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)	
				ElseIf cAlias == 'CQ3'
					aSldAtu	:= SaldoCT3(cConta,cCusto,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)		
				ElseIf cAlias == 'CQ1'
					aSldAtu	:= SaldoCT7(cConta,dDataILP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)		
				EndIf
			Else
				If cAlias == 'CQ7'
					aSldAtu	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)	
				ElseIf cAlias == 'CQ5'
					aSldAtu	:= SaldoCT4(cConta,cCusto,cItem,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)	
				ElseIf cAlias == 'CQ3'
					aSldAtu	:= SaldoCT3(cConta,cCusto,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)		
				ElseIf cAlias == 'CQ1'
					aSldAtu	:= SaldoCT7(cConta,dDataFLP,cMoedAtu,cTpSldAtu,'CTBXFUN',.F.)		
				EndIf
			EndIf			
		
			nTrbSlD := 0
			nTrbSlC := 0
			dbSelectArea("TRB")
			dbSetOrder(2)

			lVai := aSldAtu[1] <> 0 					/// SE HOUVER SALDO

			If lVai
				If cAlias == "CQ5" //.or. (cAlias == "CT3" .and. !lItem)
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

					/// SE NรO LOCALIZOU CHAVE NO CT4 VERIFICA SE Hม NO CTI
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
				ElseIf cAlias == "CQ7"				
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
					/// SE NรO LOCALIZOU CHAVE NO CT3 VERIFICA SE Hม NO CT4
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
					
					/// SE NรO LOCALIZOU CHAVE NO CT4 VERIFICA SE Hม NO CTI
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
				EndIf

				/// CALCULA OS VALORES A DEBITO E A CREDITO PARA LANCAMENTO
				/// ABATENDO OS VALORES Jม LANวADOS COM OUTRAS ENTIDADES
				nDebTrb := ABS(aSldAtu[4]) - nTrbSlD
				nCrdTrb := ABS(aSldAtu[5]) - nTrbSlC

				dbSelectArea("TRB")
				dbSetOrder(1)
				If (nDebTrb <> 0 .or. nCrdTrb <> 0) .and. !dbSeek(cTpSldAtu+cMoedAtu+cConta+cCusto+cItem+cClvl+cAlias,.F.)
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
	If lMoedaEsp		/// SE FOR MOEDA ESPECอFICA ENCERRA AO FINAL DA 1ช PASSAGEM (FOR NEXT)
		nMoedAtu := __nQuantas
		Exit
	Endif
Next nMoedAtu

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt410ValItบAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica preenchimento de Item Contabil                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ct410ValIt(cItem,cItemPon,cItemLp,lItemOk)  

Local aSaveArea	:= GetArea()

dbSelectArea("CTD")
dbSetOrder(1)
MsSeek(xFilial("CTD")+cItem)
If Found()
	If Empty(CTD->CTD_ITLP)
		lItemOk 	:= .T.
		cItemPon	:= CTD->CTD_ITPON
		cItemLP		:= cItem
	Else
		lItemOk 	:= .T.
		cItemPon	:= CTD->CTD_ITPON
		cItemLP		:= CTD->CTD_ITLP
	Endif		
Endif

RestArea(aSaveArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt410ValCCบAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica็ใo de Centro de Custo                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ct410ValCC(cCusto,cCCPon,cCCLp,lCCOk)  
Local aSaveArea	:= GetArea()

dbSelectArea("CTT")
dbSetOrder(1)
MsSeek(xFilial("CTT")+cCusto)
If Found()
	If Empty(CTT->CTT_CCLP)
		lCCOk		:= .T.
		cCCPon 		:= CTT->CTT_CCPON
		cCCLP		:= cCusto		
	Else
		lCCOk		:= .T.
		cCCPon 		:= CTT->CTT_CCPON
		cCCLP		:= CTT->CTT_CCLP
	Endif
Endif

RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt410ValCVบAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica็ใo de Cl.Vlr                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ct410ValCV(cClVl,cClVlPon,cClVlLP,lClVlOk)  
Local aSaveArea	:= GetArea()

dbSelectArea("CTH")
dbsetOrder(1)
MsSeek(xFilial("CTH")+cClVl)

If Found()
	If Empty(CTH->CTH_CLVLLP)
		lClVlOk 	:= .T.
		cClVlPon	:= CTH->CTH_CLPON
		cClVlLP		:= cClVl
	Else
		lClVlOk 	:= .T.
		cClVlPon	:= CTH->CTH_CLPON
		cClVlLP		:= CTH->CTH_CLVLLP
	Endif
Endif

RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt410ValCtบAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica็ใo de Conta Contแbil                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ct410ValCt(cConta,cCtaPon,cDigPon,lCtaOk,aCriter,aCritPon,aCritLP)  

Local aSaveArea	:= GetArea()
Local nMoedas	:= __nQuantas
Local nCont

dbSelectArea("CT1")
dbsetOrder(1)
MsSeek(xFilial("CT1")+cConta)
If Found()
	For nCont := 1 to (nMoedas-1)        
		AADD(aCriter,&("CT1->CT1_CVD"+StrZero(nCont+1,2)))
	Next	
EndIf		

RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt410FlgLPบAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca Flag's nas tabelas de saldos                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ct410FlgLP(cConta,cCusto,cItem,cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda)
Local cKeyFlag 	:= AllTrim(cFilAnt+cMoeda+cTpSald+cConta+cCusto+cItem+cClVL)
Local nLenKey	:= Len(AllTrim(cKeyFlag))

If AsCan(__aJaFlag,{|x| Substr(x,1,nLenKey) == cKeyFlag }) <= 0
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

	/// MARCA FLAG NAS TABELAS DE SALDOS COMPOSTOS
	If !Empty(cCLVL)
		Ct190FlgLP(cFilAnt, "CTU", "","","",cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
	EndIf
	If !Empty(cITEM)
		Ct190FlgLP(cFilAnt, "CTU", "","",cITEM,"", dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
	EndIf
	If !Empty(cCUSTO)
		Ct190FlgLP(cFilAnt, "CTU", "",cCUSTO,"","", dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
	EndIf
	If !Empty(cItem) .and. !Empty(cCUSTO)
		Ct190FlgLP(cFilAnt, "CTV", "",cCUSTO,cITEM,"", dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
    EndIf
  	If !Empty(cCLVL) .and. !Empty(cCUSTO)
		Ct190FlgLP(cFilAnt, "CTW", "",cCUSTO,"",cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
    EndIf
   	If !Empty(cCLVL) .and. !Empty(cITEM)
		Ct190FlgLP(cFilAnt, "CTW", "","",cITEM,cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
    EndIf
   	If !Empty(cCLVL) .and. !Empty(cITEM) .and. !Empty(cCUSTO)
		Ct190FlgLP(cFilAnt, "CTY", "",cCUSTO,cITEM,cCLVL, dDataILP, cTpSald, dDataFLP, cMoeda,,"S")
    EndIf
    
	AAdd(__aJaFlag,cKeyFlag)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt410Est  บAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina principal de estorno de lan็amentos de encerramento บฑฑ
ฑฑบ          ณ e abertura de exercํcios                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CT410Est(oObj,oSelf)
Local dDataLP		:= CtoD('')
Local lMoedaEsp		:= Iif(mv_par07==2,.T.,.F.)		//Moedas
Local cMoeda		:= StrZero(Val(mv_par08),2)		//De!fine qual a moeda especifica
Local cTpSald		:= mv_par09						//Tipo de Saldo.
Local aCtbMoeda 	:= {}
Local nInicio		:= 0
Local nFinal		:= 0
Local dDataFim
Local aCalend		:= {}
Local dDataIni		
Local cFilDe		:= 	""
Local cFilAte		:=	""
Local lAtuSaldos	:= .F.
Local lReproc		:= If(mv_par14==1,.T.,.F.)
Local dDTIFlg		:= CTOD("  /  /  ")				//DATA PARA INICIO DA REMARCAวAO DE FLAGS (APURACAO ANTERIOR +1)
Local lApLanctos	:= .F.							//.T. INDICA QUE APAGOU LANCAMENTOS
Local lPergOk		:= .T.
Local nI

If mv_par15 == 1 .And. Empty(xFilial("CT2")) 
	ProcLogAtu(STR0064,STR0071) 
EndIf

If lMoedaEsp  // Moeda especifica
	cMoeda	:= mv_par08
	aCtbMoeda := CtbMoeda(cMoeda)
	If Empty(aCtbMoeda[1])
		Help("",1,"NOMOEDA",,OemtoAnsi(STR0055),1,0)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza o log de processamento com o erro  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		ProcLogAtu("ERRO","NOMOEDA",Ap5GetHelp("NOMOEDA"))

		Return
	EndIf                  
	nInicio := val(cMoeda)
	nFinal	:= val(cMoeda)
Else
	nInicio	:= 1
	nFinal	:= __nQuantas
EndIf


//Se for moeda especifica, verificar se a moeda esta preenchida
If lMoedaEsp
	If Empty(cMoeda)
		Help(" ",1,"NOCTMOEDA",OemtoAnsi(STR0062),1,0)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza o log de processamento com o erro  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		ProcLogAtu("ERRO","NOCTMOEDA",Ap5GetHelp("NOCTMOEDA"))

		lPergOk := .F.
	Endif
EndIf	
	     
//Tipo de saldo nao preenchido
If Empty(cTpSald)
	Help(" ",1,"NO210TPSLD",,OemtoAnsi(STR0063),1,0)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza o log de processamento com o erro  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	ProcLogAtu("ERRO","NO210TPSLD",Ap5GetHelp("NO210TPSLD"))

	lPergOk := .F.
Endif	                                                                                   

If lPergOk 
	For nI := 1 To 2
		dDataLP := Iif( nI == 1, mv_par01, mv_par02)
		 
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ ANTES DE INICIAR O PROCESSAMENTO, VERIFICO OS PARAMETROS.	 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//Data de Apuracao nao preenchida.
		If Empty(dDataLP)                              
			Help(" ",1,"NOCTBDTLP",OemtoAnsi(STR0056),1,0)
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Atualiza o log de processamento com o erro  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

			ProcLogAtu("ERRO","NOCTBDTLP",Ap5GetHelp("NOCTBDTLP"))
		
			Return(.F.)                               	
		Endif                            
			
		
		If lPergOk
			//Verificar se a data solicitada eh o ultimo zeramento.
			lPergOk	:= Ct215VldDt(dDataLp,cTpSald,lMoedaEsp,cMoeda,nInicio,nFinal)	
		EndIf
		
		If !lPergOk 
			Exit
		EndIf
	
	Next nI
EndIf

If !lPergOk 
	Return
EndIf

For nI := 1 To 2

	dDataLP := Iif( nI == 1, mv_par01, mv_par02)
	dDTIFlg := Ct215LPAnt(dDataLp,cTpSald,lMoedaEsp,cMoeda)
	
	If !lReproc	
		//"Ao final dos Estornos, antes de executar nova apura็ใo, processos ou consultas,"
		//"executar reprocessamento de saldos !"
		//"Continuar mesmo assim ?"
		//"ATENวรO ! Estorno configurado para nใo atualizar saldos."
		If !MsgYesNo(STR0049+CRLF+STR0050+CRLF+STR0051,STR0052)
			Return
		EndIf
	EndIf
	
	//Zerar os valores dos lancamentos de apuracao de lucros/perdas que deverao ser estornados.
	If Ct410Atual(dDataLP,lMoedaEsp,cMoeda,cTpSald,nInicio,nFinal,oObj,dDTIFlg,oSelf)
		lAtuSaldos := .T.
		If !lReproc
			lAtuSaldos := .F.
		EndIf
		lApLanctos := .T.
	Else
		If !lReproc
			lAtuSaldos := .F.
		Else
			If !IsBlind()
				If MsgNoYes(STR0053+CRLF+"Filial "+cFilAnt)//"Nใo foram localizados lan็amentos de apura็ใo no perํodo, for็ar reprocessamento de saldos ?"
					lAtuSaldos := .T.
				Else
					lAtuSaldos := .F.	
				EndIf
			Else
				lAtuSaldos := .T.
			EndIf
		EndIf
	EndIf
	
	If lAtuSaldos
	 
	 	//Voltar o indice 1 do CT2
		dbSelectArea("CT2")
		dbSetOrder(1)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ ATUALIZACAO DOS SALDOS							 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
		//Verifico qual a data final a ser passada para o Reprocessamento.
		Ct215MaxDt(dDataLP,@dDataFim)
		If lApLanctos					/// SE APAGOU LANCAMENTOS								
			dDataIni := dDataLP			/// REPROCESSA APENAS DATA DE APURACAO (FLAGS DE SALDO FORAM REM. JUNTO COM CT2/CTZ)
		Else							/// SE NAO APAGOU LANCAMENTOS
			If Empty(dDTIFlg)			/// SE NรO HOUVER APURACAO ANTERIOR
				dbSelectArea("CT2")
				dbSetOrder(1)
				dbSeek(xFilial("CT2"),.T.)
				dDataIni := CTOD("01/01/"+ALLTRIM(STR(YEAR(dDatabase))))	/// REPROCESSA DESDE O 1บ DIA DO ANO (AVALIAR 1ช DATA DO CALENDARIO CORRENTE)
			Else
				dDataIni := dDTIFlg			/// REPROCESSA DESDE A APURACAO ANTERIOR P/ REM. TAMBEM OS FLAGS DE SALDO
			EndIf
		Endif
		
		If !Empty(dDataFim) .And. dDataLP > dDataFim
			dDataFim	:= dDataLP
		EndIf
		
		If Empty(xFilial("CT2"))
			cFilDe	:= "  "
			cFilAte	:= "  "
		Else
			cFilDe	:= cFilAnt
			cFilAte	:= cFilAnt
		EndIf
			
		If !Empty(dDataIni) .And. !Empty(dDataFim)
			// Chamada do CTBA190 para reprocessar os saldos do perํodo (dt.apuracao ou periodo)
			CTBA190(.T.,dDataIni,dDataFim,cFilDe,cFilAnt,cTpSald,lMoedaEsp,cMoeda)
		EndIf
	EndIf

Next nI

aCalend := CtbCalend(,.T.)

If Len(aCalend) > 0 
	A410Calend( oObj, oSelf, aCalend,.T.)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCt410AtualบAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Zera/Exclui os lanctos contabeis de encerramento e aberturaบฑฑ
ฑฑบ          ณ de exercํcios                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBA410                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ct410Atual(dDataLP,lMoedaEsp,cMoeda,cTpSald,nInicio,nFinal,oObj,dDTIFlg,oSelf)
Local aSaveArea	:= GetArea()		
Local nTotRegua	:= (CTI->(Reccount())+CT4->(Reccount())+CT3->(Reccount())+CT7->(RecCount()))
Local cTamMoed	:= ""
Local cFilCT2	:= ""
Local lTemLcto	:= .F.
Local lObj 		:= ValType(oObj) == "O"
Local cLoteAtu 	:= ""

DEFAULT dDTIFlg := dDataLP

///////////////////////////////////
//// APAGA REGISTROS DE LANวAMENTO NO CT2
///////////////////////////////////
dbSelectArea("CT2")     
cTamMoed := CriaVar("CT2_MOEDAS")
dbSetOrder(1)
cFilCT2	:= xFilial("CT2")
If MsSeek(cFilCT2+DTOS(dDataLP),.F.)
	If lObj
		oObj:SetRegua2(nTotRegua)			 					
	EndIf
	lFoundLP := .F.
	cLoteAtu := CT2->CT2_LOTE
	While CT2->(!Eof()) .And. !lFoundLP .And. CT2->CT2_FILIAL == cFilCT2 .And. CT2->CT2_DATA == dDataLP
	
		If Empty(CT2->CT2_DTLP) .Or. CT2->CT2_TPSALD <> cTpSald
			dbskip() 
			Loop
		EndIf	
		
		If CT2->CT2_DTLP == dDataLP				
			While CT2->(!Eof()) .And. CT2->CT2_FILIAL == cFilCT2 .And. ;
					CT2->CT2_DTLP == dDataLP .And. CT2->CT2_TPSALD == cTpSald
			
				If AllTrim(CT2->CT2_ROTINA) != "CTBA410"
					dbskip() 
					Loop
				EndIf
				
				lTemLcto := .T.
				If lObj
					oObj:IncRegua1(OemToAnsi(STR0005))//Selecionando Registros... 		 				 		
				EndIf
				

				If lMoedaEsp 					/// SE FOR MOEDA ESPECIFICA

					If CT2->CT2_MOEDLC <> cMoeda	/// SE NรO FOR A MOEDA SOLICITADA
						CT2->(dbSkip())				/// MANTEM O REGISTRO NO CT2
						Loop
					EndIf
								
					dbSelectArea("CT2")
					nRecCT2 := (CT2->(Recno()))
					dbSetOrder(1)
					If cMoeda == '01' 
						cCt2Atual := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD)
						dbSeek(cCt2Atual+CT2->(CT2_EMPORI+CT2_FILORI)+"02",.T.)
						If cCt2Atual == CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD) .and. CT2->CT2_MOEDLC <> "01"

							/// LIMPA OS FLAGS DE APURACAO NAS TABELAS DE SALDO
							CT215FlgLp(CT2->CT2_DEBITO,CT2->CT2_CCD,CT2->CT2_ITEMD,CT2->CT2_CLVLDB, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA)
							CT215FlgLp(CT2->CT2_CREDIT,CT2->CT2_CCC,CT2->CT2_ITEMC,CT2->CT2_CLVLCR, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA)

							//Se existir valor de conversao, apenas zera o registro do CT2
							CT2->(MsGoto(nRecCT2))														
							Reclock("CT2",.F.,.T.)					
							CT2->CT2_VALOR := 0
							CT2->CT2_CRCONV := "5"
							MsUnlock()
						Else
							// Se nใo existe valor de conversใo, apaga registro no CT2.
							CT2->(MsGoto(nRecCT2))                                     
							
							/// LIMPA OS FLAGS DE APURACAO NAS TABELAS DE SALDO
							CT215FlgLp(CT2->CT2_DEBITO,CT2->CT2_CCD,CT2->CT2_ITEMD,CT2->CT2_CLVLDB, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA)
							CT215FlgLp(CT2->CT2_CREDIT,CT2->CT2_CCC,CT2->CT2_ITEMC,CT2->CT2_CLVLCR, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA)

							Reclock("CT2",.F.,.T.)					
							dbDelete()				
							MsUnlock()                  
					
						EndIf
					
					Else
						//Se for valor de conversใo

						/// LIMPA OS FLAGS DE APURACAO NAS TABELAS DE SALDO
						CT215FlgLp(CT2->CT2_DEBITO,CT2->CT2_CCD,CT2->CT2_ITEMD,CT2->CT2_CLVLDB, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA)
						CT215FlgLp(CT2->CT2_CREDIT,CT2->CT2_CCC,CT2->CT2_ITEMC,CT2->CT2_CLVLCR, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA)

						Reclock("CT2",.F.,.T.)					
						dbDelete()				
						MsUnlock()                  
					EndIf
				Else	                                                    				
					//Apaga registro de lan็amento (vai apagar para todas as moedas)

					/// LIMPA OS FLAGS DE APURACAO NAS TABELAS DE SALDO
					CT215FlgLp(CT2->CT2_DEBITO,CT2->CT2_CCD,CT2->CT2_ITEMD,CT2->CT2_CLVLDB, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA)
					CT215FlgLp(CT2->CT2_CREDIT,CT2->CT2_CCC,CT2->CT2_ITEMC,CT2->CT2_CLVLCR, CT2->CT2_MOEDLC, CT2->CT2_TPSALD, dDTIFlg, CT2->CT2_DATA)

					Reclock("CT2",.F.,.T.)					
					dbDelete()				
					MsUnlock()
				EndIf
			 	
			 	CT2->(dbSkip())
			EndDo		
		Else
			MsSeek(cFilCT2+DTOS(dDataLP)+Soma1(cLoteAtu),.T.)
		EndIf
		cLoteAtu := CT2->CT2_LOTE
	EndDo	
EndIf

RestArea(aSaveArea)	
Return lTemLcto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbCalend บAutor  ณ Daniel Leme        บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Sele็ใo de Calendแrios em Aberto em multi-filiais          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Contแbil                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbCalend( aFilSel,lEstorno )
Local aReturn		:= {} 
Local nInc			:= 0
Local nI			:= 0
Local nTo 			:= 0
Local cAuxVar		:= ""
Local cProcFil		:= ""

Private nTam		:= 0
Private aCat		:= {}
Private MvPar		:= ""
Private cTitulo		:= ""
Private MvParDef	:= ""

Default aFilSel := {cFilAnt}
DEFAULT lEstorno:= .F.

//-- Tratamento para carregar variaveis da lista de opcoes
CTG->( DbSetOrder( 1 ) ) //-- CTG_FILIAL+CTG_CALEND+CTG_EXERC+CTG_PERIOD
nTam	:= Len(&("CTG->("+CTG->(IndexKey())+")"))
cTitulo := STR0090 

//-- Se todos os niveis forem compartilhados, 
nTo := Iif( Empty(xFilial("CTG")), Min(1,Len(aFilSel)), Len(aFilSel))
For nI := 1 To nTo
	CTG->( DbSeek( xFilial( "CTG", aFilSel[nI] ) ))
	If cProcFil != xFilial( "CTG", aFilSel[nI] )
		Do While CTG->( !Eof() ) .And. CTG->CTG_FILIAL == xFilial( "CTG", aFilSel[nI] )
			
			If !lEstorno .AND. CTG->CTG_STATUS == "1"
						
				If cAuxVar != xFilial( "CTG")+CTG->CTG_CALEND + CTG->CTG_EXERC
		   			MvParDef += &("CTG->("+CTG->(IndexKey())+")")
			
					CTG->(aAdd( aCat, 	AllTrim(RetTitle("CTG_FILIAL")) + " " + CTG_FILIAL  + " -  " +;
							   			AllTrim(RetTitle("CTG_CALEND"))	+ " " + CTG_CALEND  + " - " +;
										AllTrim(RetTitle("CTG_EXERC"))	+ " " + CTG_EXERC))
										
					cAuxVar := xFilial( "CTG")+CTG->CTG_CALEND + CTG->CTG_EXERC
					
				EndIf
	        ElseIf lEstorno .AND. CTG->CTG_STATUS == "2"
	        	
	        	If cAuxVar != xFilial( "CTG")+CTG->CTG_CALEND + CTG->CTG_EXERC
		   			MvParDef += &("CTG->("+CTG->(IndexKey())+")")
			
					CTG->(aAdd( aCat, 	AllTrim(RetTitle("CTG_FILIAL")) + " " + CTG_FILIAL  + " -  " +;
							   			AllTrim(RetTitle("CTG_CALEND"))	+ " " + CTG_CALEND  + " - " +;
										AllTrim(RetTitle("CTG_EXERC"))	+ " " + CTG_EXERC))
										
					cAuxVar := xFilial( "CTG")+CTG->CTG_CALEND + CTG->CTG_EXERC
				EndIf 
			EndIf				
			CTG->( DbSkip() )
			
		EndDo
		cProcFil := xFilial( "CTG", aFilSel[nI] )
	EndIf
Next nI

//-- Executa funcao que monta tela de opcoes
If Len(aCat) > 0
	If AdmOpcoes( @MvPar, cTitulo, aCat, MvParDef,,,.F.,   nTam, Len( aCat ),.T.)
		For nInc := 1 To Len( MvPar ) Step nTam
			aAdd( aReturn, SubStr( MvPar, nInc, nTam) )
		Next	
	EndIf
EndIf
	
Return aReturn
