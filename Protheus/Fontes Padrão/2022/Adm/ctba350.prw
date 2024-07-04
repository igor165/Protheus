#Include "CTBA350.Ch"
#Include "PROTHEUS.Ch"

#DEFINE D_PRELAN	"9"

// 17/08/2009 -- Filial com mais de 2 caracteres

// TRADUÇÃO RELEASE P10 1.2 - 21/07/08

STATIC __lBlind  := IsBlind()
STATIC __aRptLog := {}
STATIC __cTEMPOS := ""

STATIC lAtSldBase
STATIC lCusto
STATIC lItem
STATIC lClVl
STATIC lCtb350Ef
STATIC lEfeLanc
STATIC lCT350TRC
STATIC lCT350TSL
STATIC nQtdEntid
STATIC lUsaProc := .F.
STATIC _oCTBA350
STATIC __nTamCT2	:= TamSX3("CT2_VALOR")[1]
STATIC __nDecCT2	:= TamSX3("CT2_VALOR")[2]
Static lPE350Qry 	:= ExistBlock("CT350QRY")

//AMARRACAO
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBA350  ³ Autor ³ Simone Mie Sato       ³ Data ³ 14/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetiva os pre-lancamentos                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA350()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA350(lAutomato)

Local nOpca		:= 0
Local aSays		:= {}, aButtons := {}
Local aCampos	:= {{"CXFILCT2"	,"C"	,TamSX3("CT2_FILIAL")[1]	,0			},;					
					{"DDATA"	,"C"	,10							,0			},;
					{"LOTE"		,"C"	,TamSX3("CT2_LOTE")[1]		,0			},;
					{"DOC"		,"C"	,TamSX3("CT2_DOC")[1]		,0			},;
					{"MOEDA"	,"C"	,TamSX3("CT2_MOEDLC")[1]	,0			},;
					{"VLRDEB"	,"N"	,__nTamCT2					,__nDecCT2	},;
					{"VLRCRD"	,"N"	,__nTamCT2					,__nDecCT2	},;
					{"DESCINC"	,"C"	,80							,0			}}

Local lRet		:= .T.
Local nCont		:= 0
Local nX
Local nThread	:= GetNewPar( "MV_CT350TH", 1 )
Local nSeconds	:= 0


Private cCadastro := OemToAnsi(OemtoAnsi(STR0001))  //"Efetivacao de Pre-Lancamentos"

PRIVATE titulo    := OemToAnsi(STR0004)  //"Log Validacao Efetivacao"
PRIVATE cCancel   := OemToAnsi(STR0006)  //"***** CANCELADO PELO OPERADOR *****"

Private aCtbEntid

Default lAutomato := .F.

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

If nQtdEntid == NIL
	nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

If aCtbEntid == NIL
	aCtbEntid := Array(2,nQtdEntid)  //posicao 1=debito  2=credito
EndIf

//DEBITO
aCtbEntid[1,1] := {|| TMP->CT2_DEBITO   }
aCtbEntid[1,2] := {|| TMP->CT2_CCD      }
aCtbEntid[1,3] := {|| TMP->CT2_ITEMD    }
aCtbEntid[1,4] := {|| TMP->CT2_CLVLDB   }
//CREDITO
aCtbEntid[2,1] := {|| TMP->CT2_CREDIT  }
aCtbEntid[2,2] := {|| TMP->CT2_CCC      }
aCtbEntid[2,3] := {|| TMP->CT2_ITEMC    }
aCtbEntid[2,4] := {|| TMP->CT2_CLVLCR   }

For nX := 5 TO nQtdEntid
	aCtbEntid[1, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"DB } ")  //debito
	aCtbEntid[2, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"CR } ")  //credito
Next

lAtSldBase	:= ( GetMv("MV_ATUSAL") == "S" )
lCusto		:= CtbMovSaldo("CTT")
lItem 		:= CtbMovSaldo("CTD")
lClVl		:= CtbMovSaldo("CTH")
lCtb350Ef	:= ExistBlock("CTB350EF")
lEfeLanc 	:= ExistBlock("EFELANC")
lCT350TRC	:= GetNewPar( "MV_CT350TC", .F.)			///PARAMETRO NÃO PUBLICADO NA CRIAÇÃO (15/03/07-BOPS120975)
lCT350TSL	:= GetNewPar( "MV_CT350SL", .T.)			///PARAMETRO NÃO PUBLICADO NA CRIAÇÃO (15/03/07-BOPS120975)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Numero do Lote Inicial                           ³
//³ mv_par02 // Numero do Lote Final                             ³
//³ mv_par03 // Data Inicial                                     ³
//³ mv_par04 // Data Final                                       ³
//³ mv_par05 // Efetiva sem Bater Lote?                          ³
//³ mv_par06 // Efetiva sem Bater Documento?                     ³
//³ mv_par07 // Efetiva para sald?Real/Gerencial/Orcado          ³
//³ mv_par08 // Verifica entidades contabeis?                    ³
//³ mv_par09 // SubLote Inicial?                                 ³
//³ mv_par10 // SubLote Final?                                   ³
//³ mv_par11 // Mostra Lancamento Contabil?  Sim/Nao             ³
//³ mv_par12 // Modo Processamento                               ³
//³ mv_par13 // Documento Inicial                                ³
//³ mv_par14 // Documento Final                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte( "CTB350" , .F. )

AADD(aSays,OemToAnsi( STR0002 ) )//"Transfere os lancamentos indicados com status pre-lancamento (que nao controla saldos)"
AADD(aSays,OemToAnsi( STR0003 ) )//"para o saldo informado, acompanhando relatorio de confirmacao do processamento."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( aButtons )

AADD(aButtons, { 5,.T.,{|| Pergunte("CTB350",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

PcoIniLan("000082")

If !lAutomato
	FormBatch( cCadastro, aSays, aButtons,, 160 )
Else
	nOpca:= 1
Endif

//-----------------------------------------------------
// Crio tabela temporaroa p/ gravar as inconsistencias
//-----------------------------------------------------
CriaTmp(aCampos)

If nOpca == 1
	//Verificar se o calendario esta aberto para poder efetuar a efetivacao.
	//Somente verificar a data inicial.
	For nCont := 1 To __nQuantas
		If CtbExisCTE( StrZero(nCont,2),Year(mv_par03) )
			
			lRet := CtbStatus(StrZero(nCont,2),mv_par03,mv_par04, .F.)
			If !lRet
				nOpca	:= 0
				Exit
			EndIf
		Endif
	Next
	
	If ! lCT350TSL
		MsgInfo(STR0061,STR0062) //"Após as efetivações do periodo, para emissao de relatórios executar 'Reprocessamento de Saldos' do periodo/data.","ATENÇÃO ! At. de saldos desligada, MV_CT350SL (L) = F "
		lAtSldBase := .F.
	EndIf
	
EndIf

IF nOpca == 1
	nSeconds := Seconds()
	Conout(STR0068 + "|" + dtoc(dDatabase) + "|" + Time() + "|" + AllTrim(Str(nSeconds))) //"INICIO"

	// efetuo a criação da procedure que irá alimentar os dados para o relatorio.
	lUsaProc := CtbCriaProc()

	If FindFunction("CTBSERIALI")
		While !CTBSerialI("CTBPROC","ON")
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu(STR0068) //"INICIO"
	lEnd := .F.
	
	nThread := 1        /* RETIRADO MULTI-THREAD DEU PROBLEMA NO CLIENTE MADERO */
	If nThread <= 1
		Processa({|lEnd| Ctb350Proc(@lEnd)},cCadastro)
	Else   
		Processa({|lEnd| Ctb351Proc(@lEnd)},cCadastro)   /* RETIRADO CLIENTE MADERO */
	Endif	

	CTBSerialF("CTBPROC","ON")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu(STR0069) //"FIM"

	If lUsaProc
		If TCSPExist("CTB350REL_" + cEmpAnt )
			CtbSqlExec( "Drop procedure CTB350REL_" + cEmpAnt )
		Endif	
	Endif

	Conout(STR0070 + "|" + dtoc(dDatabase) + "|" + Time() + "|" + AllTrim(Str(Seconds())) + "| " + STR0071 + AllTrim(Str(Seconds() - nSeconds)) ) //"TERMINO"###"Tempo Gasto:"
Endif

PcoFinLan("000082")

// efetua a exclusão do arquivo temporario
DeleteTmp()

dbSelectArea("CT2")
dbSetOrder(1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb350Proc³ Autor ³ Simone Mie Sato       ³ Data ³ 14.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua os Lancamentos para efetivacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb350Proc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb350Proc(lEnd)

Local cTpSldAtu 	:= mv_par07	//Efetiva p/ que saldo?
Local lEfLote		:= Iif(mv_par05 == 1,.T.,.F.)//.T. ->Efetiva sem bater Lote / .F. ->Nao efetiva sem bater Lote
Local lEfDoc		:= Iif(mv_par06 == 1,.T.,.F.)//.T. ->Efetiva sem bater Doc / .F. ->Nao efetiva sem bater Doc
Local lProcessa		:= .F. 						//Indica se processou algum lote
Local cDescInc		:= ""
Local cLoteAnt		:= ""
Local cDocAnt		:= ""
Local dDataAnt		:= CTOD("  /  /  ")
Local aErro
Local aErroTexto 	:= {}
Local c350Fillog	:= cFilAnt

Local lMostraLct	:= ( mv_par11 == 1 )
Local lSimula		:= ( mv_par12 == 2 )

Local cLancAnt
Local cQryUser := ""
Local aPergunte   := Ct350VPerg("CTB350")
Local lFilde_Ate  := Len(aPergunte[2]) > 14
Local cFilialDe   := Space(Len(CT2->CT2_FILIAL))
Local cFilialAte  := Space(Len(CT2->CT2_FILIAL))
Local axFilCT2    := {}
Local cxFil_De  := Space(Len(CT2->CT2_FILIAL))
Local cxFil_Ate  := Space(Len(CT2->CT2_FILIAL))

//Utilizados na CTBA105
PRIVATE INCLUI 		:= .F.
PRIVATE ALTERA 		:= .T.
PRIVATE DELETA 		:= .F.

// Variaveis utilizadas na função CT105LINOK()
PRIVATE __lCusto	:= CtbMovSaldo("CTT")
PRIVATE __lItem		:= CtbMovSaldo("CTD")
PRIVATE __lCLVL		:= CtbMovSaldo("CTH")

PRIVATE dDataLanc	:= {}
PRIVATE OPCAO	:= 3

__aRptLog := {}

lAtSldBase	:= ( GetMv("MV_ATUSAL") == "S" )
lCusto		:= CtbMovSaldo("CTT")
lItem 		:= CtbMovSaldo("CTD")
lClVl		:= CtbMovSaldo("CTH")
lCtb350Ef	:= ExistBlock("CTB350EF")
lEfeLanc 	:= ExistBlock("EFELANC")
lCT350TRC	:= GetNewPar( "MV_CT350TC", .F.)			///PARAMETRO NÃO PUBLICADO NA CRIAÇÃO (15/03/07-BOPS120975)
lCT350TSL	:= GetNewPar( "MV_CT350SL", .T.)			///PARAMETRO NÃO PUBLICADO NA CRIAÇÃO (15/03/07-BOPS120975)

If lMostraLct .and. lSimula
	If !IsBlind()
		If MsgYesNo(STR0064,cCadastro)//"Nao é permitido modo 'Simulação' exibindo lançamentos, continua Simulação sem exibir lançamentos ?"
			lMostraLct	:= .F.
			mv_par11 	:= 2
		Else
			Return
		EndIf
	Else
		Return
	EndIf
EndIf

If lSimula
	If !IsBlind()
		If !MsgYesNo(STR0065,Alltrim(cCadastro)+ STR0066)//"Neste modo apenas serao listadas se houverem inconsistências, os lançamentos mesmo que válidos nao serao efetivados neste modo. Continua Simulação ?"##" Modo Simulação "
			Return
		EndIf
	EndIf
EndIf


xCONOUT("|INI CTB350PROC !")
If mv_par11 == 1
	//
	// Se mostra Lancamentos Contabeis, declarar variaveis utilizadas na rotina dos lancamentos
	//
	Private aRotina := {{},{},{},	{STR0004 ,"Ctba102Cal", 0 , 4} } // "Alterar"

	Private cLote
	Private cLoteSub := GetMv("MV_SUBLOTE")
	Private cSubLote := cLoteSub
	Private lSubLote := Empty(cSubLote)
	Private cDoc
	Private cSeqCorr
	Private aTotRdpe := {{0,0,0,0},{0,0,0,0}}
Endif

aErroTexto := ct350aerro()

// Abrindo o CT2 com o alias "TMP" para sofrer as consistencias da função CT105LINOK()
If Select("TMP") > 0
	TMP->( DbCloseArea() )
EndIf

ChkFile("CT2",.F.,"TMP")

dbSelectArea("CTC")
dbSetOrder(1)
cFilCTC := xFilial("CTC")

dbSelectArea("CT2")
cFilCT2 := xFilial("CT2")
dbSetOrder(1)

dbSeek(cFilCT2+Dtos(mv_par04)+mv_par02+(If(mv_par02==mv_par01,"Z","")),.T.)	// Localiza registro próximo ao último
nRecF := CT2->(Recno())						// Guara nº do registro final

dbSeek(cFilCT2+Dtos(mv_par03)+(If(!Empty(mv_par01),mv_par01,""))+(If(!Empty(mv_par09),mv_par09,"")),.T.) // Procuro por Filial+Data Inicial + Lote + SbLote
nRecI := CT2->(Recno()) 					// Guarda nº do registro inicial

ProcRegua(nRecF - nRecI)					// Seta regua contando intervalo de registro
dDataAnt := CT2->CT2_DATA
cLoteAnt := ""
cDocAnt	 := ""
cLancAnt := ""

aCT2DocOk := {}

cQuery := " SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, MIN(R_E_C_N_O_) MINRECNO"
cQuery += " FROM "+RetSqlName("CT2")
cQuery += " WHERE "

If ! lFilde_Ate
	cQuery += " CT2_FILIAL = '"+cFilCT2+"'"
Else
	//parametro filial de ate (mv_par15/mv_par16)
	cFilialDe   := mv_par15
	cFilialAte  := mv_par16

	axFilCT2 := Ct350LDSM0(cFilialDe, cFilialAte)   //a funcao recebe mv_par15 e mv_par16 e retorna um array com filial e xfilial
	If Len(axFilCT2) == 0
		cQuery += " CT2_FILIAL = '"+cFilCT2+"'"
	Else
		cFilialDe   := axFilCT2[1,1]                    //primeira filial do array no primeiro elemento
		cxFil_De    := axFilCT2[1,2]                    // no segundo elemento ja tem xFilial("CT2", axFilCT2[1,1] )

		cFilialAte  := axFilCT2[Len(axFilCT2),1]        //ultima filial do array no primeiro elemento
		cxFil_Ate   := axFilCT2[Len(axFilCT2),2]        // no segundo elemento ja tem xFilial("CT2", axFilCT2[Len(axFilCT2),1] )

		If ! Empty(cxFil_De) .And. ! Empty(cxFil_Ate)
			If ( cxFil_De == cxFil_Ate )
				cQuery += " CT2_FILIAL = '" + cxFil_De + " '    
			else
				cQuery += " CT2_FILIAL >= '" + cxFil_De + "' "
				cQuery += " AND CT2_FILIAL <= '" + cxFil_Ate + "' "
			EndIf
		Else
			cQuery += " CT2_FILIAL = '" + cFilCT2 + " '      
		EndIf
	EndIf
EndIf

If mv_par03 == mv_par04
	cQuery += " AND CT2_DATA = '" + DTOS(mv_par03) + "' "
Else
	cQuery += " AND CT2_DATA >= '" + DTOS(mv_par03) + "' "
	cQuery += " AND CT2_DATA <= '" + DTOS(mv_par04) + "' "
Endif

If ! Empty( mv_par01 ) .Or. ! Empty( mv_par02 )
	If ( mv_par01 == mv_par02 )
		cQuery += " AND CT2_LOTE = '" + mv_par01 + "' "
	Else
		If ! Empty( mv_par01 )
			cQuery += " AND CT2_LOTE >= '" + mv_par01 + "' "
		Endif
		
		If ! Empty( mv_par02 )
			cQuery += " AND CT2_LOTE <= '" + mv_par02 + "' "
		Endif
	Endif
Endif

If ! Empty( mv_par09 ) .Or. ! Empty( mv_par10 )
	If ( mv_par09 == mv_par10 )
		cQuery += " AND CT2_SBLOTE = '" + mv_par09 + "' "
	Else
		If ! Empty( mv_par09 )
			cQuery += " AND CT2_SBLOTE >= '" + mv_par09 + "' "
		Endif
		
		If ! Empty( mv_par10 )
			cQuery += " AND CT2_SBLOTE <= '" + mv_par10 + "' "
		Endif
	Endif
Endif

If ! Empty( mv_par13 ) .Or. ! Empty( mv_par14 )
	If ( mv_par13 == mv_par14 )
		cQuery += " AND CT2_DOC = '" + mv_par13 + "' "
	Else
		If ! Empty( mv_par13 )
			cQuery += " AND CT2_DOC >= '" + mv_par13 + "' "
		Endif
		
		If ! Empty( mv_par14 )
			cQuery += " AND CT2_DOC <= '" + mv_par14 + "' "
		Endif
	Endif
Endif
cQuery += " AND CT2_TPSALD = '" + D_PRELAN + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE "
cQuery += " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE "

If lPE350Qry
	cQryUser := 	ExecBlock("CT350QRY",.F.,.F.,{cQuery})
	If !Empty(cQryUser) //se ponto de entrada retornou string query preenchida
		cQuery := cQryUser	
	EndIf 	
EndIf

cQuery := ChangeQuery(cQuery)

If Select("TMP350") > 0
	TMP350->(DBCloseArea())
Endif

xCONOUT("|INI QUERY !")

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP350",.T.,.F.)

xCONOUT("|FIM QUERY !")

TcSetField("TMP350","MINRECNO","N",17,0)
TcSetField("TMP350","CT2_DATA","D",8,0)

If lEnd
	Return
Endif

dbSelectArea( "TMP350" )
dbGoTop()

While !TMP350->(Eof())
	
	CT2->( dbGoTo(TMP350->MINRECNO) )

	//Atualiza Filial para processar Ct350roda
	cFilCT2 := CT2->CT2_FILIAL
	If lFilde_Ate   //somente se tem as perguntas mv_par15/mv_par16, manipula variavel cFilAnt
		If FWModeAccess("CT2",3) == 'E'// Quando o ambiente CT2 é totalmente exclusivo 
			IF CT2->CT2_FILIAL != cFilAnt
				cFilAnt := CT2->CT2_FILIAL
			EndIf
		ElseIf Empty(cFilCT2) // CT2 totalmente compartilhado
			cFilAnt := c350Fillog //mantem a filial logada
		Else
			If Len(axFilCT2) == 0
				cFilAnt := c350Fillog //mantem a filial logada
			Else
				//leitura das filiais na SM0 e modo de compartilhamento / leiaute
				//setar cFilAnt na primeira filial de acordo com xFilial("CT2")
				nPosxFil := aScan( axFilCT2 , { |x| x[2] == cFilCT2 } )
				If nPosxFil > 0
					cFilAnt := axFilCT2[nPosxFil,1]
				EndIf
			EndIf
		EndIf
	EndIf	
	IncProc( DTOC( CT2->CT2_DATA ) + "-" + CT2->CT2_LOTE + STR0056 + ALLTRIM( STR( CT2->( Recno() ) )))//" Lendo Lote... Reg.: "
	
	Processa({|lEnd| Ct350roda( cFilCT2, @lEnd, @aErro, aErroTexto, cTpSldAtu, lEfLote, lEfDoc, lMostraLct, lSimula )} ,cCadastro )
	
	If lEnd
		Return
	EndIf
	
	lProcessa := .T.

	TMP350->( dbSkip() )
EndDo

xCONOUT("|" + STR0069 + " CTB350PROC !",.T.) //"FIM"
//-------------------------------------------------------------
// Se nao tiver inconsistencias, imprime mensagem que esta ok.
//-------------------------------------------------------------

lPrintR := .T.
If lProcessa .And. TRB350REL->(LastRec()) == 0
	If !__lBlind .and. MsgYesNo(STR0016+CRLF+STR0052,cCadastro)
		lPrintR := .T.
		cDescInc := OemToAnsi(STR0016)		//"Nao ha inconsistencias no lote e documento."		
		CT350GrInc(,,,,,,cDescInc)		//Gravo no arquivo temporario as inconsistencias
	Else
		lPrintR := .F.
	EndIf
ElseIf !lProcessa
	If !__lBlind .and. MsgYesNo(STR0017+CRLF+STR0052,cCadastro)
		lPrintR := .T.
		cDescInc := OemToAnsi(STR0017)		//"Nao ha lote a ser efetivado."
		CT350GrInc(,,,,,,cDescInc)		//Gravo no arquivo temporario as inconsistencias
	Else
		lPrintR := .F.
	EndIf
ElseIf TRB350REL->(LastRec()) > 0 .and. !__lBlind
	MsgInfo(STR0053+CRLF+STR0054,STR0055)//"Houveram inconsistências na efetivação !"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime relatorio de consistencias ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPrintR
	If lSimula
		titulo+=" - " +STR0066 //" Modo Simulação."
	EndIf
	C350ImpRel()
Endif

If Select("TMP350") > 0
	TMP350->(DBCloseArea())
Endif

If Select("TMP") > 0
	TMP->( DbCloseArea() )
EndIf
xCONOUT("|AFTER RPT LOG !")

cFilAnt := c350Fillog 

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CT350GrInc³ Autor ³ Simone Mie Sato       ³ Data ³ 14.05.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as Inconsistencias no Arq. de Trabalho.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CT350GrInc(dData,cLote,cDoc,cMoeda,nVlrDeb,nVlrCrd,cDescInc)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba350                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data                                                ³±±
±±³          ³ ExpC1 = Lote                                                ³±±
±±³          ³ ExpC2 = Documento                                           ³±±
±±³          ³ ExpC3 = Moeda                                               ³±±
±±³          ³ ExpN1 = Valor Debito                                        ³±±
±±³          ³ ExpN2 = Valor Credito                                       ³±±
±±³          ³ ExpC4 = Descricao da Inconsistentcia                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct350GrInc(dData,cLote,cDoc,cMoeda,nVlrDeb,nVlrCrd,cDescInc,cxFilCT2)

Default dData 		:= ""
Default cLote 		:= ""
Default cDoc 		:= ""
Default cMoeda 		:= ""
Default nVlrDeb		:= 0
Default nVlrCrd		:= 0
Default cDescInc	:= ""
Default cxFilCT2	:= xFilial("CT2")

If TCSPExist("CTB350REL_" + cEmpAnt )
	lUsaProc := .T.	
	aResult := TCSPEXEC( "CTB350REL_" + cEmpAnt, cxFilCT2 ,dData , cLote, cDoc, cMoeda, nVlrDeb, nVlrCrd, cDescInc)

	If Empty(aResult)
  		conout(STR0072) //"Falha na chamada do processo de inclusão dos dados para o relatorios. Gravação será efetuada de forma padrão."
   		lUsaProc := .F.
	EndIf

EndIf

IF !lUsaProc
	If Valtype(__aRptLog) # "A" 
		__aRptLog := {}
	Endif
  
	If aScan( __aRptLog , { |x| 	x[1] == cxFilCT2 .And. ;
									x[1] == dData .And. ;
									x[2] == cLote .And. ;
									x[3] == cDoc .And. ;
									x[4] == cMoeda .And. ;
									x[5] == nVlrDeb .And. ;
									x[6] == nVlrCrd .And. ;
									x[7] == cDescInc} ) == 0
	
		aAdd(__aRptLog,{cxFilCT2,dData,cLote,cDoc,cMoeda,nVlrDeb,nVlrCrd,cDescInc})
	
		If Select("TRB350REL") <= 0
			dbUseArea( .T., "TOPCONN", "TRB350REL", "TRB350REL", .F., .F. )
			TcRefresh("TRB350REL")
		Endif

		dbSelectArea("TRB350REL")
		Reclock("TRB350REL",.T.)

		TRB350REL->CXFILCT2	:= cxFilCT2
		TRB350REL->DDATA	:= dData
		TRB350REL->LOTE		:= cLote
		TRB350REL->DOC		:= cDoc 
		TRB350REL->MOEDA	:= cMoeda
		TRB350REL->VLRDEB	:= nVlrDeb
		TRB350REL->VLRCRD	:= nVlrCrd
		TRB350REL->DESCINC	:= cDescInc
		MsUnlock()
	Endif
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C350ImpRel

Imprime o Relatorio Final.

@author Simone Mie Sato
@since 14/05/2001
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function C350ImpRel()
Local oReport := Nil

oReport := ReportDef()
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Definicoes do relatorio de inconsistencias.

@author Totvs
@since 23/12/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oReport	:= Nil
Local oSecCab	:= Nil

oReport := TReport():New("CTBA350",titulo,"CTB350",{|oReport| ReportPrint(oReport)},titulo)

oSecCab := TRSection():New(oReport,STR0073,{"TRB350REL"}) //"Lançamentos"

//           oSection ,cCampo    ,cAlias      ,cTitulo ,cPicture               ,nTamanho                ,lPixel ,bImpressao ,cAlign ,lLineBreak
TRCell():New(oSecCab  ,"CXFILCT2"  ,"TRB350REL" , "FILIAL" ,                     ,TamSX3("CT2_FILIAL")[1] ,       ,           ,       ,           ) //"Doc"
TRCell():New(oSecCab  ,"DDATA"   ,"TRB350REL" ,STR0074 ,                       ,10                      ,       ,           ,       ,           ) //"Data"
TRCell():New(oSecCab  ,"LOTE"    ,"TRB350REL" ,STR0075 ,                       ,TamSX3("CT2_LOTE")[1]   ,       ,           ,       ,           ) //"Lote"
TRCell():New(oSecCab  ,"DOC"     ,"TRB350REL" ,STR0076 ,                       ,TamSX3("CT2_DOC")[1]    ,       ,           ,       ,           ) //"Doc"
TRCell():New(oSecCab  ,"MOEDA"   ,"TRB350REL" ,STR0077 ,                       ,TamSX3("CT2_MOEDLC")[1] ,       ,           ,       ,           ) //"Moeda"
TRCell():New(oSecCab  ,"VLRDEB"  ,"TRB350REL" ,STR0078 ,X3Picture("CT2_VALOR") ,__nTamCT2               ,       ,           ,       ,           ) //"Valor Debito"
TRCell():New(oSecCab  ,"VLRCRD"  ,"TRB350REL" ,STR0079 ,X3Picture("CT2_VALOR") ,__nTamCT2               ,       ,           ,       ,           ) //"Valor Credito"
TRCell():New(oSecCab  ,"DESCINC" ,"TRB350REL" ,STR0080 ,                       ,80                      ,       ,           ,       ,.T.        ) //"Inconsistencia"

//------------------------------------
// Desabilita a edicao dos parametros
//------------------------------------
oReport:ParamReadOnly()

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Funcao para impressao do relatorio de inconsistencias.

@author Totvs
@since 23/12/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)

Local oSection := oReport:Section(1)

oSection:Print()

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct350Valid³Autor  ³ Simone Mie Sato       ³ Data ³ 14.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica as entidades.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct350Valid()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba350                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct350Valid()

Local aSaveArea	:= GetArea()
Local lRet	:= .T.
Local cDescInc	:= ""
Local cSayCusto	:= CtbSayApro("CTT")
Local cSayItem	:= CtbSayApro("CTD")
Local cSayClVL	:= CtbSayApro("CTH")

dbSelectArea("CT2")
dbSetOrder(1)
MsSeek(xFilial("CT2")+Dtos(mv_par03)+mv_par01+mv_par13,.T.) // Procuro por Filial+Data Inicial + Lote + DOC inicial

ProcRegua(CT2->(RecCount()))
dDataAnt := CT2->CT2_DATA
cLoteAnt := ""
cDocAnt	 := ""

While !Eof() .And. CT2->CT2_FILIAL == xFilial("CT2") .And. CT2->CT2_DATA <= mv_par04 .And. CT2->CT2_DOC <= mv_par14
	
	If CT2->CT2_TPSALD != D_PRELAN //Se o tipo de saldo for diferente de pre-lancamento
		dbSkip()
		Loop
	Endif
	
	If CT2->CT2_DATA < mv_par03 .Or. CT2->CT2_DATA > mv_par04
		dbSkip()
		Loop
	Endif
	
	If  CT2->CT2_LOTE < mv_par01 .Or. CT2->CT2_LOTE > mv_par02
		dbSkip()
		Loop
	EndIf
	
	If CT2->CT2_DC $ "13"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CONTA CONTABIL A DEBITO                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a conta foi preenchida                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( CT2->CT2_DEBITO )
			lRet := .F.
			If !lRet
				cDescInc := STR0023	+ STR0025 + CT2->CT2_LINHA //Conta nao preenchida.  	Linha:
				CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,,,,cDescInc)
			EndIf
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a conta existe e nao e sintetica                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("CT1")
		lRet:= ValidaConta(CT2->CT2_DEBITO,"1",,,.T.,.F.)
		If !lRet
			cDescInc	:= STR0024 + Alltrim(CT2->CT2_DEBITO) + STR0025 + CT2->CT2_LINHA //Verificar conta: 	Linha:
			CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,,,,cDescInc)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CENTRO DE CUSTO - DEBITO                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCusto
			lRet:= ValidaCusto(CT2->CT2_CCD,"1",,,.T.,.F.)
			If !lRet
				cDescInc	:= STR0026+ Alltrim(cSayCusto) + " : " + Alltrim(CT2->CT2_CCD)+STR0025+CT2->CT2_LINHA //Verificar  Linha
				CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,,,,cDescInc)
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ITEM - DEBITO 		                                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lItem
			lRet:= ValidItem(CT2->CT2_ITEMD,"1",,,.T.,.F.)
			If !lRet
				cDescInc	:= STR0026+ Alltrim(cSayItem) + " : " + Alltrim(CT2->CT2_ITEMD)+STR0025+CT2->CT2_LINHA //Verificar  Linha
				CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,,,,cDescInc)
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CLASSE VALOR - DEBITO 		                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lClVL
			lRet:= ValidaCLVL(CT2->CT2_CLVLDB,"1",,,.T.,.F.)
			If !lRet
				cDescInc	:= STR0026+ Alltrim(cSayClVl) + " : " + Alltrim(CT2->CT2_CLVLDB)+STR0025+CT2->CT2_LINHA //Verificar  Linha
				CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,,,,cDescInc)
			EndIf
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bloco de Valida‡oes Lancamentos a Credito                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CT2->CT2_DC $ "23"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CONTA CONTABIL A CREDITO                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a conta foi preenchida                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( CT2->CT2_CREDIT )
			lRet := .F.
			If !lRet
				cDescInc 	:= STR0023	+ STR0025 + CT2->CT2_LINHA //Conta nao preenchida.  	Linha:
				CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,,,,cDescInc)
			EndIf
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a conta existe e nao e sintetica                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := ValidaConta(CT2->CT2_CREDIT,"2",,,.T.,.F.)
		If !lRet
			cDescInc	:= STR0024 + Alltrim(CT2->CT2_CREDIT) + STR0025 + CT2->CT2_LINHA //Verificar conta: 	Linha:
			CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,,,,cDescInc)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CENTRO DE CUSTO - CREDITO                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCusto
			lRet:= ValidaCusto(CT2->CT2_CCC,"2",,,.T.,.F.)
			If !lRet
				cDescInc	:= STR0026+ Alltrim(cSayCusto) + " : " + Alltrim(CT2->CT2_CCC)+STR0025+CT2->CT2_LINHA //Verificar  Linha
				CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,,,,cDescInc)
			EndIf
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ITEM - CREDITO		                                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lItem
			lRet:= ValidItem(CT2->CT2_ITEMC,"2",,,.T.,.F.)
			If !lRet
				cDescInc	:= STR0026+ Alltrim(cSayItem) + " : " + Alltrim(CT2->CT2_ITEMC)+STR0025+CT2->CT2_LINHA //Verificar  Linha
				CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,,,,cDescInc)
			EndIf
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CLASSE VALOR - CREDITO		                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lClVL
			lRet:= ValidaCLVL(CT2->CT2_CLVLCR,"2",,,.T.,.F.)
			If !lRet
				cDescInc	:= STR0026+ Alltrim(cSayClVl) + " : " + Alltrim(CT2->CT2_CLVLCR)+STR0025+CT2->CT2_LINHA //Verificar  Linha
				CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,,,,cDescInc)
			EndIf
		EndIf		
	EndIf
	dbSelectArea("CT2")
	dbSkip()
EndDo

RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT350DigLaºAutor  ³Marcos S. Lobo      º Data ³  02/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua chamada da tela de lançamento contabil manual para   º±±
±±º          ³a efetivação quando configurada para Mostrar Lançamento.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ct350DigLan(nPriLinCT2)
Local cSubLote
Local nTotInf
Local cQuery := ""
Local cAliasSQL

CT2->( DbGoTo(nPriLinCT2) )	//	Posicionando no primeiro registro do lancamento

dDataLanc := CT2->CT2_DATA // "dDataLanc" é utilizada na funcao CT105LinOK()

// Buscando o total do documento
dbSelectArea("CTC")
dbSetOrder(1)

If MsSeek(cFilCTC+DtoS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_MOEDLC+CT2->CT2_TPSALD)
	nTotInf := CTC->CTC_INF
Else
	nTotInf := 0
Endif

// Fechando o Alias "TMP", pois na funcao CTBA102LAN(), esse Alias e usado para o temporario da GetDados
TMP->( DbCloseArea() )

cDoc 		:=  CT2->CT2_DOC
cLote		:=  CT2->CT2_LOTE
cSubLote	:=	CT2->CT2_SBLOTE //variavel privada utilizada nas validacoes

Ctba102Lan(4,CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,"CT2",CT2->(Recno()),0,"",nTotInf)

//Verifica se documento foi atualizado para tipo de saldo 1

cAliasSQL := GetNextAlias()

	cQuery := " SELECT IIF( COUNT(CT2_TPSALD) > 0, 'S', 'N') AS DIV "
	cQuery += " FROM "+RetSqlName('CT2')+" "
	cQuery += " WHERE CT2_FILIAL = '"+cFilCTC+"' "
	cQuery += " AND CT2_DATA = '"+DtoS(CT2->CT2_DATA)+"' "
	cQuery += " AND CT2_LOTE = '"+CT2->CT2_LOTE+"' "
	cQuery += " AND CT2_SBLOTE = '"+CT2->CT2_SBLOTE+"'  "
	cQuery += " AND CT2_DOC = '"+CT2->CT2_DOC+"' "
	cQuery += " AND CT2_MOEDLC = '"+CT2->CT2_MOEDLC+"' "
	cQuery += " AND CT2_TPSALD != '9' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery,cAliasSQL)

	If (cAliasSQL)->DIV == "S"
		CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,,,,  OemToAnsi(STR0082) )	//Lançamento Corrigido
	EndIf	

(cAliasSQL)->(DbCloseArea())

// Abrindo novamente o CT2 com o alias "TMP"
If Select("TMP") > 0
	TMP->( DbCloseArea() )
EndIf

ChkFile("CT2",.F.,"TMP")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA350   ºAutor  ³Microsiga           º Data ³  03/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ct350roda( cFilCT2, lEnd,aErro,aErroTexto,cTpSldAtu,lEfLote,lEfDoc,lMostraLct,lSimula)

Local nCont		:= 0
Local nDocOk	:= 0
Local nPriLinCT2    := 1
Local nValor		:= 0
Local nCT6CRD		:= 0
Local nCT6DEB		:= 0
Local nCTCDEB 		:= 0
Local nCTCCRD 		:= 0
Local nVlrDeb		:= 0
Local nVlrCrd		:= 0
Local lTodas
Local lJobs := IsCtbJob()

Local lTemIncons  := .F.
Local lLoteOk		:= .T.
Local lDocOk		:= .T.

Local cLoteAtu	:= CT2->CT2_LOTE
Local dDataAtu	:= CT2->CT2_DATA
Local aOutrEntid := {}
Local aDadosCQA	:= {}

ProcRegua(1000)

If !lEfLote	///Se só efetivar LOTE batido

	//----------------------------------------------------
	// Verifico se o lote esta batendo	em todas as moedas
	// Nao informa o documento para conferir todo o lote
	//----------------------------------------------------
	aSaldo := CTBA350Sld(cFilCT2, CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,/*CT2->CT2_DOC*/,CT2->CT2_TPSALD,CT2->CT2_MOEDLC)

	If aSaldo[2] <> 0 .OR. aSaldo[3] <> 0
		
		nCT6DEB := Round(aSaldo[2],2)
		nCT6CRD := Round(aSaldo[3],2)
		
		If nCT6DEB != nCT6CRD .or. (nCT6DEB == 0 .and. nCT6CRD == 0)//Se debito e credito nao baterem
			lTemIncons := .T.
			lLoteOk	:= .F.
			cDescInc := OemToAnsi(STR0014)		//"Debito e Credito do Lote nao estao batendo"
			CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,,CT2->CT2_MOEDLC,nCT6DEB,nCT6CRD,cDescInc) //Grava TMP com as inconsistencias 
		EndIf
	Else
		lTemIncons	:= .T.
		lLoteOk		:= .F.
		//Gravo no arquivo temporario as inconsistencias
		cDescInc := OemToAnsi(STR0051)		//"Registro de Saldo Total do Lote/Doc. não encontrado. Reprocessar Pré-Lançamentos (9)."
		CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,,CT2->CT2_MOEDLC,0,0,cDescInc)
	Endif
	
	If !lLoteOk	//Se houve diferença no total Deb x Cred.
		///Ja localiza o proximo lote.
		lSkip := .F.
		
		If lSkip ///nas versoes sem query deve-se localizar o proximo registro de lote a ser validado no CT2.
			dbSelectArea("CT2")
			dbSetOrder(1)
			dbSeek(cFilCT2+DTOS(dDataAtu)+Soma1(cLoteAtu),.T.)
		EndIf
	EndIf
EndIf

If lEnd
	Return
EndIf

// Enquanto for o mesmo Lote
While CT2->(!Eof()) .And. CT2->CT2_FILIAL == cFilCT2 .And. CT2->CT2_DATA == dDataAtu .and. CT2->CT2_LOTE == cLoteAtu .and. CT2->CT2_SBLOTE <= mv_par10 .And. CT2->CT2_DOC <= mv_par14
	
	IncProc(DTOC(CT2->CT2_DATA)+"-"+CT2->CT2_LOTE+"/"+CT2->CT2_DOC+STR0058+ALLTRIM(STR(CT2->(Recno()))))///" Lendo Doc... Reg.: "
	
	If lEnd
		Return
	EndIf
	
	If CT2->CT2_LOTE < mv_par01 .or. CT2->CT2_SBLOTE < mv_par09
		CT2->(dbSeek(cFilCT2+CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+SOMA1(CT2_DOC)),.T.))
		Loop
	ElseIf CT2->CT2_TPSALD != D_PRELAN //Se o tipo de saldo for diferente de pre-lancamento
		CT2->(dbSeek(cFilCT2+CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+SOMA1(CT2_LINHA)),.T.))
		Loop
	EndIf
	
	cSubAtu := CT2->CT2_SBLOTE
	cDocAtu := CT2->CT2_DOC
	
	lDocOk		:= .T.
	lTemIncons  := .F.

	//Verifica se SubLote está em branco no documento
	If Empty(cSubAtu)
		lDocOk	:= .F.
		//Gravo no arquivo temporario as inconsistencias
		cDescInc := OemToAnsi(STR0083) //"O Sublote nao pode ficar em branco. Favor preenche-lo."
		CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,CT2->CT2_MOEDLC,nVlrDeb,nVlrCrd,cDescInc)
		Return
	EndIf
	
	If !lEfDoc			/// Se só efetivar DOCUMENTO batido.

		//---------------------------------------------------------
		// Verifico se o documento esta batendo em todas as moedas
		//---------------------------------------------------------
		aSaldo := CTBA350Sld(cFilCT2, CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_TPSALD,CT2->CT2_MOEDLC)


		nCTCDEB := Round(aSaldo[2],2)
		nCTCCRD := Round(aSaldo[3],2)

		If nCTCDEB != nCTCCRD .or. (nCTCDEB == 0 .and. nCTCCRD == 0)//Se debito e credito nao baterem
			
			lTemIncons := .T.
			lDocOk	:= .F.
			nVlrDeb	:= nCTCDEB
			nVlrCrd := nCTCCRD
			//Gravo no arquivo temporario as inconsistencias
			cDescInc := OemToAnsi(STR0015)		//"Debito e Credito do Documento nao estao batendo"			
			CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,CT2->CT2_MOEDLC,nVlrDeb,nVlrCrd,cDescInc)
		Endif

	EndIf
	
	nPriLinCT2	:= CT2->( Recno() )		// Guarda a 1ª Linha do Documento
	dDataLanc	:= CT2->CT2_DATA
	
	If lEnd
		Return
	EndIf
	
	
	If !lEfDoc .And. lTemIncons .And. lMostraLct
		CT350DigLan( nPriLinCT2 )
		dbSelectArea("CT2")
		dbSetOrder(1)
		dbSeek(cFilCT2 + CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+Soma1(CT2_DOC)) )
		nNextCT2 := CT2->(Recno())
	Else
		IF !lEfDoc .and. lTemIncons
			
			dbSelectArea("CT2")
			dbSetOrder(1)
			dbSeek(cFilCT2 + CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+Soma1(CT2_DOC)) )
			
		Else
			
			aCT2DocOk	 := {}
			
			While CT2->(!Eof()) .and. 	CT2->CT2_FILIAL == cFilCT2 .And. CT2->CT2_DATA == dDataAtu .and. CT2->CT2_LOTE == cLoteAtu .and.;						
				CT2->CT2_SBLOTE == cSubAtu .and. CT2->CT2_DOC == cDocAtu
				
				IncProc(DTOC(CT2->CT2_DATA)+"-"+CT2->CT2_LOTE+"/"+CT2->CT2_DOC+STR0059+ALLTRIM(STR(CT2->(Recno()))))//" Validado...Reg.: "
				
				If CT2->CT2_LOTE < mv_par01 .or. CT2->CT2_SBLOTE < mv_par09
					CT2->(dbSeek(cFilCT2+CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+SOMA1(CT2_DOC)),.T.))
					Loop
					
				ElseIf CT2->CT2_TPSALD != D_PRELAN //Se o tipo de saldo for diferente de pre-lancamento
					CT2->(dbSeek(cFilCT2+CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+SOMA1(CT2_LINHA)),.T.))
					Loop
				EndIf
				
				If Select("TMP") == 0
					ChkFile("CT2",.F.,"TMP")
				EndIf
				
				TMP->( DbGoTo( CT2->(Recno()) ) )		/// Posiciona o mesmo registro do CT2 no alias TMP.
				dDataLanc	 := TMP->CT2_DATA // "dDataLanc" é utilizada na funcao CT105LinOK()

				aErro		 := {}
				lTodas	 	 := (mv_par11 == 2)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verificar se ha inconsistencia (se lTodas==.T., verificara todas as inconsistencias    ³
				//³ do documento, caso contrario, retornara apos a primeira inconsistencia encontrada)	   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !CT105LinOK("",.T.,@aErro,lTodas,OPCAO)
	
					lTemIncons := .T.
					For nCont := 1 to Len(aErro)
						
						cDescInc := aErroTexto[ aErro[nCont] ]
						nVlrDeb 	:= IF( CT2->CT2_DC $ "13", CT2->CT2_VALOR, 0 )
						nVlrCrd 	:= IF( CT2->CT2_DC $ "23", CT2->CT2_VALOR, 0 )
						If nVlrDeb == 0 .And. nVlrCrd == 0
							nVlrDeb := nVlrCrd := CT2->CT2_VALOR
						EndIf
						CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_DOC,CT2->CT2_MOEDLC,nVlrDeb,nVlrCrd,cDescInc)
					Next
				Else		/// Se não teve inconsistência na Linha
					aAdd(aCT2DocOk,CT2->(Recno()) )
				EndIf

				nUltLinCT2 := CT2->( Recno()) // Guarda a última linha do Documento
				CT2->(dbSkip())
			EndDo
		EndIF

		/// Quando Terminar a leitura do documento.
		nNextCT2 := CT2->(Recno())      /// Guarda o posicionamento do próximo registro.
		
		/// Efetua gravação dos lançamentos ou mostra tela para correções e gravação
		If lTemIncons .And. lMostraLct 	// Se tem inconsistencias e deve mostrar lancamento na tela
			Ct350DigLan(nPriLinCT2)	//Mostra o lançamento para correções, grava CT2 e Saldos.
			lTemIncons := .F. //Modificado para se tiver inconsistente ele considerar os que est?o corretos
		EndIf		
		If !lTemIncons .and. ( lLoteOk	.and. lDocOk )// Se não teve inconsistência e não mostra a tela
			
			If !lSimula
				
				FOR nDocOk := 1 TO Len( aCT2DocOk )
					
					CT2->( DbGoTo( aCT2DocOk[ nDocOk ] ) )
					
					If nDocOk == 1
						IncProc(DTOC(CT2->CT2_DATA)+"-"+CT2->CT2_LOTE+"/"+CT2->CT2_DOC+STR0060+ALLTRIM(STR(CT2->(Recno()))))///" Gravando...Reg.: "
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa Ponto de Entrada antes de  ³
					//³ alterar o tipo de saldo no CT2     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lCtb350Ef
						ExecBlock("CTB350EF",.F.,.F.)
					Endif
					
					//Chamar a multlock
					aTravas := {}
					
					IF !Empty(CT2->CT2_DEBITO)
						AADD(aTravas,CT2->CT2_DEBITO)
					Endif
					IF !Empty(CT2->CT2_CREDIT)
						AADD(aTravas,CT2->CT2_CREDIT)
					Endif
					
					/// VERIFICA SE O SEMAFORO DE CONTAS PERMITE GRAVAÇÃO DOS LANÇAMENTOS/SALDOS
					If CtbCanGrv(aTravas,@lAtSldBase)
						BEGIN TRANSACTION
						
						// Utilizado para gerar o lancamento no PCO com o novo tipo de saldo
						PcoDetLan("000082","01","CTBA350",.T.)
						
						//Altero o tipo de saldo no lancamento contabil.
						Reclock("CT2",.F.)
						
						CT2->CT2_TPSALD := cTpSldAtu
						
						CT2->(MsUnlock())
						
						If lEfeLanc
							ExecBlock("EFELANC",.F.,.F.)
						Endif
						
						If lAtSldBase .And. !lJobs
							nValor	:= CT2->CT2_VALOR
							//Os parametros lReproc e lAtSldBase estao sendo passados como .T.
							//porque sempre sera atualizado os saldos basicos na efetivacao
							aOutrEntid 	:= CtbOutrEnt(.F.)
							
							CtbGravSaldo(CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_DATA,CT2->CT2_DC,CT2->CT2_MOEDLC,;
							CT2->CT2_DEBITO,CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,CT2->CT2_ITEMC,;
							CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nValor,CT2->CT2_TPSALD,3,,,;
							,,,,,,,,,,lCusto,lItem,lClVL,,.T.,.F.,,,,,,,,,,,"+"/*cOperacao*/,aOutrEntid[1])

							//Desgravo o valor do arquivo CTC
							If CT2->CT2_DC == "3"
								GRAVACTC(CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,'1',CT2->CT2_DATA,CT2->CT2_MOEDLC,nValor,D_PRELAN,,"-")
								GRAVACTC(CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,'2',CT2->CT2_DATA,CT2->CT2_MOEDLC,nValor,D_PRELAN,,"-")
							Else
								GRAVACTC(CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_DC,CT2->CT2_DATA,CT2->CT2_MOEDLC,nValor,D_PRELAN,,"-")
							Endif
						
						ElseIf lAtSldBase .And. lJobs //Tratamento para gravar CQA saldo em Fila

							aADD(aDadosCQA, {;
								CT2->CT2_FILIAL, ;
								CT2->CT2_LOTE, ;
								CT2->CT2_SBLOTE, ;
								CT2->CT2_DOC, ;
								CT2->CT2_DATA, ;
								CT2->CT2_LINHA, ;
								CT2->CT2_TPSALD, ;
								CT2->CT2_EMPORI, ;
								CT2->CT2_FILORI, ;
								CT2->CT2_MOEDLC})							
						EndIf

						// Utilizado para gerar o lancamento no PCO com o novo tipo de saldo
						PcoDetLan("000082","02","CTBA350")

						END TRANSACTION
						Ct1MUnLock()
						dbCommitAll()
					EndIf
				NEXT nDocOk
			EndIf
		Endif
				
		CT2->(dbSetOrder(1))
		CT2->(MsGoto(nNextCT2))	///Vai para o próximo registro a ser validado.
	EndIf


EndDo

	//Tratamento para gravar CQA saldo em Fila
	If Len(aDadosCQA) > 0 
		CTBGrvCQA(aDadosCQA)
		aDadosCQA:={}
	EndIf

Return

/////////////////////////////////////////////////////////////////////////////////
/// funcoes para testes
/////////////////////////////////////////////////////////////////////////////////
Static Function xCONOUT(cTexto,lResume)

Local cTxtLog := ""

DEFAULT lResume  := .F.

If !lCT350TRC
	Return
EndIf

cTxtLog := "TRACE|CTBA350|"+DTOC(Date())+"|"+Time()+"|"+ALLTRIM(STR(SECONDS()))

__cTEMPOS+= cTxtLog+cTexto+CRLF

CONOUT(cTxtLog+cTexto)

If lResume
	MsgInfo(__cTEMPOS,STR0067)//"Resumo de Tempos -> Efetivaçao CTB"
	__cTEMPOS := ""
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbExisCTEºAutor  ³CTB		         º Data ³  02/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbExisCTE( cMoeda, cAno )
Local aArea	:= GetArea()
Local lRet	:= .F.

DbSelectArea( 'CTE' )
DbSetOrder( 1 )
If MsSeek( xFilial( 'CTE' ) + cMoeda )
	DbSelectArea("CTG")
	DbSetOrder(1)
	If MsSeek(xFilial("CTG")+CTE->(CTE_CALEND)+Str(cAno))
		lRet := .T.
	EndIf
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA350Sld

Funcao para somar os Debitos e Creditos dos pre-lancamentos.

Obs: Nao é utilizada a tabela CTC pois quando o MV_ATUSAL esta desativado a
rotina CTBA190 nao aceita o tipo de saldo 9 para reprocessamento.

@author Totvs
@since 30/11/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function CTBA350Sld(cFilCT2, dDataCT2,cLoteCT2,cSbLoteCT2,cDocCT2,cTpSldCT2,cMoedaCT2)

Local aArea		:= GetArea()
Local nTotDeb	:= 0
Local nTotCred	:= 0
Local nSaldo	:= 0
Local cAliasQry	:= GetNextAlias()
Local cQuery	:= ""

Default cDocCT2	:= ""

cQuery :=	" SELECT " 
cQuery +=		" SUM( CT2_VALOR * CASE WHEN CT2_DC = '1' OR CT2_DC = '3' THEN 1 ELSE 0 END) VALORDEB"
cQuery +=		", SUM( CT2_VALOR * CASE WHEN CT2_DC = '2' OR CT2_DC = '3' THEN 1 ELSE 0 END) VALORCRD"
cQuery +=	" FROM "
cQuery +=		RetSqlTab("CT2")
cQuery +=	" WHERE "
cQuery +=		" CT2_FILIAL = '" + cFilCT2 + "' "
cQuery +=		" AND CT2_DATA = '" + DToS(dDataCT2) + "' "
cQuery +=		" AND CT2_LOTE = '" + cLoteCT2 + "' "
cQuery +=		" AND CT2_SBLOTE = '" + cSbLoteCT2 + "' "
If !Empty(cDocCT2)
	cQuery += " AND CT2_DOC = '" + cDocCT2 + "' "
EndIf
cQuery +=		" AND CT2_TPSALD = '" + cTpSldCT2 + "' "
cQuery +=		" AND CT2_MOEDLC = '" + cMoedaCT2 + "' "
cQuery +=		" AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .F.)

If (cAliasQry)->(!Eof())

	TcSetField(cAliasQry,"VALORDEB","N",__nTamCT2,__nDecCT2)
	TcSetField(cAliasQry,"VALORCRD","N",__nTamCT2,__nDecCT2)

	nTotDeb := (cAliasQry)->VALORDEB

	nTotCred := (cAliasQry)->VALORCRD

EndIf

nSaldo := nTotCred - nTotDeb

(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return({nSaldo,nTotDeb,nTotCred})

/*-------------------------------------------------------------------------
Funcao        : CriaTmp
Autor         : Renato Campos
Data          : 11/08/2012
Uso           : Cria a tabela temporaria a ser usada na impressão do relatorio
-------------------------------------------------------------------------*/
Static Function CriaTmp( aCampos)
Local aArea	:= GetArea()
Local cArqAlias	:= "TRB350REL"

DeleteTmp()

_oCTBA350 := FWTemporaryTable():New(cArqAlias)
_oCTBA350:SetFields(aCampos)
_oCTBA350:AddIndex("1",{"DDATA","LOTE","DOC"})

_oCTBA350:Create()

RestArea(aArea)

Return

/*-------------------------------------------------------------------------
Funcao        : DeleteTmp
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Executa a instrução de exclusão do temporario do banco
-------------------------------------------------------------------------*/
Static Function DeleteTmp()
Local aArea := GetArea()

If _oCTBA350 <> Nil
	_oCTBA350:Delete()
	_oCTBA350 := Nil
Endif

RestArea(aArea)

Return

/*-------------------------------------------------------------------------
Funcao        : CtbSqlExec
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Executa a instrução de banco via TCSQLExec
-------------------------------------------------------------------------*/
Static Function CtbSqlExec( cStatement )
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local lRetorno	:= .T.

BEGIN SEQUENCE
	IF TcSqlExec(cStatement) <> 0
		UserException( STR0081 + CRLF + TCSqlError()  + CRLF + ProcName(1) + CRLF + cStatement ) //"Erro na instrução de execução do SQL"
		lRetorno := .F.
	Endif
RECOVER
	lRetorno := .F.
END SEQUENCE
ErrorBlock(bBlock)

Return lRetorno

/*-------------------------------------------------------------------------
Funcao		  : CtbCriaProc()
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Executa a instrução de banco via TCSQLExec
-------------------------------------------------------------------------*/
Static Function CtbCriaProc()
Local cQuery	:= ""
Local nPTratRec	:= 0
Local lOk		:= .T.
Local cNomeTab	:= ""

//----------------------------------------------------------------------------------------------
// Exclusao da procedure pois o FWTemporaryTable fornece um novo nome de tabela a cada execucao
//----------------------------------------------------------------------------------------------
If TCSPExist("CTB350REL_" + cEmpAnt )
	CtbSqlExec( "Drop procedure CTB350REL_" + cEmpAnt )
Endif	

//-----------------------------
// Obtem o nome real da tabela
//-----------------------------
If _oCTBA350 <> Nil
	cNomeTab := _oCTBA350:GetRealName()
EndIf

cQuery := "Create Procedure CTB350REL_" + cEmpAnt + "(" + CRLF
cQuery += "    @IN_CXFILCT2   Char( " + StrZero(TAMSX3('CT2_FILIAL')[1],2) + " )," + CRLF
cQuery += "    @IN_DDATA      Char( 10 )," + CRLF
cQuery += "    @IN_LOTE       Char( " + StrZero(TAMSX3('CT2_LOTE')[1],2) + " )," + CRLF
cQuery += "    @IN_DOC        Char( " + StrZero(TAMSX3('CT2_DOC' )[1],2) + " )," + CRLF
cQuery += "    @IN_MOEDA      Char( " + StrZero(TAMSX3('CT2_MOEDLC' )[1],2) + " )," + CRLF
cQuery += "    @IN_VLRDEB     Float," + CRLF
cQuery += "    @IN_VLRCRD     Float," + CRLF
cQuery += "    @IN_DESCINC    Char( 80 )," + CRLF
cQuery += "    @OUT_RESULT    Char( 01 ) OutPut" + CRLF
cQuery += "    " + CRLF
cQuery += ")" + CRLF
cQuery += "as" + CRLF
cQuery += "    " + CRLF
cQuery += "begin" + CRLF
cQuery += "    select @OUT_RESULT = '0'" + CRLF
cQuery += "    " + CRLF
cQuery += "    begin tran" + CRLF
cQuery += "    INSERT INTO TRB350REL ( CXFILCT2 , DDATA, LOTE, DOC, MOEDA, VLRDEB, VLRCRD, DESCINC, D_E_L_E_T_ ) " + CRLF
cQuery += "                   VALUES ( @IN_CXFILCT2, @IN_DDATA, @IN_LOTE, @IN_DOC, @IN_MOEDA, @IN_VLRDEB, @IN_VLRCRD, @IN_DESCINC , ' ' )" + CRLF
cQuery += "    commit tran " + CRLF
cQuery += "    " + CRLF
cQuery += "    select @OUT_RESULT = '1'" + CRLF
cQuery += "End" + CRLF
cQuery += "    " + CRLF

cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())),.F.)
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

//---------------------------------------------------------------------------------------------------------
// Esta adequacao foi implementada pois o nome real da tabela criada no SQL fazia o MSParse apagar a query
//---------------------------------------------------------------------------------------------------------
cQuery := StrTran( cQuery,"TRB350REL",cNomeTab)

If !TCSPExist( "CTB350REL_" + cEmpAnt )
	lOk := CtbSqlExec(cQuery)
EndIf

Return lOk

/*-------------------------------------------------------------------------
Funcao		  : ct350aerro
Autor         : Totvs
Data          : 14/10/2019
Uso           : carrega arrey de erro para validação de linha no CTBA105
-------------------------------------------------------------------------*/
Function ct350aerro()

Local aErroTexto := {}

// Textos correspondentes aos erros retornados da função CT105LINOK()
Aadd( aErroTexto,STR0027 ) // "1 Erro no Tipo do Lancamento Contabil."											// 01 Help "FALTATPLAN"
Aadd( aErroTexto,STR0028 ) // "2 Ausencia do Valor do Lancamento Contabil."										// 02 Help "FALTAVALOR"
Aadd( aErroTexto,STR0029 ) // "3 O campo historico nao pode ficar em branco."									// 03 Help "CTB105HIST"
Aadd( aErroTexto,STR0030 ) // "4 Este registro nao pode conter valor, pois e um complemento de historico."		// 04 Help "CONTHIST"
Aadd( aErroTexto,STR0031 ) // "5 Lancamento de historico complementar nao pode conter entidade preenchida."	    // 05 Help "HISTNOENT"
Aadd( aErroTexto,STR0032 ) // "6 Lancamento a debito, porem conta debito nao digitada."							// 06 Help "FALTA DEB"
Aadd( aErroTexto,STR0033 ) // "7 Entidade bloqueada ou Data do lancto. menor/maior que a data da entidade."     // 07 ValidaBloq()
Aadd( aErroTexto,STR0034 ) // "8 Conta debito preenchida e seu respectivo digito verificador nao."				// 08 Help "DIG_DEBITO"
Aadd( aErroTexto,STR0035 ) // "9 Digito de Controle NAO confere com o Digito cadastrado no Plano de Contas."    // 09 Help "DIGITO"
Aadd( aErroTexto,STR0036 ) // "10 Amarracao entre as entidades nao permitida. Observe as regras de amarracao."  // 10 CtbAmarra()
Aadd( aErroTexto,STR0037 ) // "11 Entidade obrigatoria nao preenchida ou Entidade proibida preenchida."		    // 11 CtbObrig()
Aadd( aErroTexto,STR0038 ) // "12 Lancamento a credito, porem conta credito nao digitada."						// 12 Help "FALTA CRD"
Aadd( aErroTexto,STR0039 ) // "13 Conta credito preenchida e seu respectivo digito verificador nao."			// 13 Help "DIG-CREDIT"
Aadd( aErroTexto,STR0040 ) // "14 Deve-se informar o valor em outra moeda para validar o lancamento."			// 14 Help "SEMVALUS$"
Aadd( aErroTexto,STR0041 ) // "15 As entidades contabeis sao iguais no debito e credito."						// 15 Help "CTAEQUA123"
Aadd( aErroTexto,STR0042 ) // "16 C.Custo, Item e/ou Cl.Valor nao preenchidos conforme o tipo do lancamento."	// 16 Help ""NOCTADEB
Aadd( aErroTexto,STR0042 ) // "17 C.Custo, Item e/ou Cl.Valor nao preenchidos conforme o tipo do lancamento."	// 17 Help "NOCTACRD"
Aadd( aErroTexto,STR0043 ) // "18 Ponto de Entrada 'CT105LOK'" 													// 18 P.Entrada CT105LOK
Aadd( aErroTexto,STR0044 ) // "19 Moeda/Data bloqueada para lançamento"											// 19 Help "CT2_VLR0x"
Aadd( aErroTexto,STR0063) // "20 Problema com a(as) entidade(es) informada(as)

Return aErroTexto

//-------------------------------------------------------------------
/*{Protheus.doc} Ct350VPerg
Retorna array com o pergunte

@author Totvs
   
@version P12
@since   05/09/2022
@return  Nil
@obs	 
*/
//------------------------------------------------------------------
Static Function Ct350VPerg(cPerg)
//Verifica se a nova pergunta realmente foi criada, para não dar error log no cliente
Local oPerg	:= FWSX1Util():New()
Local aPergunte
oPerg:AddGroup(cPerg)
oPerg:SearchGroup()
aPergunte := oPerg:GetGroup(cPerg)

Return(aPergunte)

//-------------------------------------------------------------------
/*{Protheus.doc} Ct350LDSM0
leitura da tabela SM0
Retorna array com filiais e xFilial("CT2") de cada filial 

@author Totvs
   
@version P12
@since   05/09/2022
@return  Nil
@obs	 
*/
//------------------------------------------------------------------
Static Function Ct350LDSM0(cParFilde, cParFilAte)

Local cFilOld := cFilAnt
Local aArea := GetArea()
Local aSM0 := FwLoadSM0() //leitura da SM0 e retorno com array 
Local aSM0Aux := {}
Local nX

For nX := 1 TO Len(aSM0)

	If aSM0[nx][1] == cEmpAnt .And. aSM0[nx][2] >= cParFilde .And. aSM0[nx][2] <= cParFilAte
		AADD(aSM0Aux, { aSM0[nx][2], xFilial("CT2",aSM0[nx][2])})
    EndIf

Next

cFilAnt := cFilOld
RestArea(aArea)

Return(aSM0Aux)
