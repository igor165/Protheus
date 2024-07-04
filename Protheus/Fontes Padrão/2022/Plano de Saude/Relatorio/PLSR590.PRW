
#INCLUDE "PLSR590.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
static objCENFUNLGP := CENFUNLGP():New() 
static lAutoSt := .F.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR590 ³ Autor ³ Wagner Mobile Costa    ³ Data ³ 19.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Emissao do resumo de cobranca (Padrao / Intercambio)       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR590                                                    ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define nome da funcao                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function PLSR590(cmv_par01, cmv_par02, cmv_par03, cmv_par04, cmv_par05,lauto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis padroes para todos os relatorios...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nQtdLin     := 60
PRIVATE cTamanho    := "P"
PRIVATE cTitulo     := STR0001 //"RESUMO DA COBRANCA"
PRIVATE cDesc1      := STR0002 //"Este Relatorio tem como objetivo emitir resumo demonstrando a composicao de"
PRIVATE cDesc2      := STR0003  //"um lote de cobranca."
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BDC"
PRIVATE cPerg       := "PLR590"
PRIVATE cRel        := "PLSR590"
PRIVATE nli         := 80
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .F. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""

default lauto := .F.

lAutoSt := lauto

//-- LGPD ----------
if !lAuto .AND. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa ambiente do relatorio somente top...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAuto .AND. ! PLSRelTop()
   Return
Endif    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         				³
//³ mv_par01 // Operadora Inicial                          						³
//³ mv_par02 // Numero Cobranca Inicial                          				³
//³ mv_par03 // Operadora Final                            						³
//³ mv_par04 // Numero Cobranca Final                            				³
//³ mv_par05 // Intercambio Sim/Nao                              				³
//³ mv_par06 // Detalha usuarios cobrados                        				³
//³ mv_par07 // Demonstra criticas ?                             				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
If cMv_par01 # Nil
	mv_par01 := cMv_par01
	mv_par02 := cMv_par02
	mv_par03 := cMv_par03
	mv_par04 := cMv_par04
	mv_par05 := cMv_par05
Endif

if !lAuto
	mv_par01 := "0001"
	mv_par02 := "  "
	mv_par03 := "0001"
	mv_par04 := "ZZ"
	mv_par05 := cMv_par05
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint (padrao)                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAuto
	cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao (padrao)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAuto .AND. nLastKey  == 27 
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura impressora (padrao)                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAuto
	SetDefault(aReturn,cAlias)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emite relat¢rio                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAuto
	MsAguarde({|| r590Imp() }, cTitulo, "", .T.)
else
	r590Imp()
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ r590Imp  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 14.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime detalhe do relatorio...                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function r590Imp()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//LOCAL cLinha
//LOCAL cQuebra     
LOCAL cSQL  
LOCAL cBDCName 	:= BDC->(RetSQLName("BDC"))
LOCAL cBD0Name 	:= BD0->(RetSQLName("BD0"))
LOCAL cBM1Name 	:= BD0->(RetSQLName("BM1"))
LOCAL cBDGName 	:= BD0->(RetSQLName("BDG"))
Local cStatus	:= "", lPrimeiro := lTraco := .F.
Local cNivel	:= ""

Private _cChave := ""

BM1->(DbSetOrder(3))
BDC->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par05 = 1		// InterCambio
	cSQL := "SELECT * FROM "+cBD0Name+" WHERE "
	cSQL += "BD0_FILIAL = '"+xFilial("BD0")+"' AND "
	cSQL += "BD0_CODOPE >= '"+mv_par01+"' AND "
	cSQL += "BD0_NUMERO >= '"+mv_par02+"' AND "
	cSQL += "BD0_CODOPE <= '"+mv_par03+"' AND "
	cSQL += "BD0_NUMERO <= '"+mv_par04+"' AND "
	cSQL += cBD0Name+".D_E_L_E_T_ = '' "
	cSQL += "ORDER BY " + BD0->(IndexKey())
	cStatus	:= "1"
Else
	cSQL := "SELECT * FROM "+cBDCName+" WHERE "
	cSQL += "BDC_FILIAL = '"+xFilial("BDC")+"' AND "
	cSQL += "BDC_CODOPE >= '"+mv_par01+"' AND "
	cSQL += "BDC_NUMERO >= '"+mv_par02+"' AND "
	cSQL += "BDC_CODOPE <= '"+mv_par03+"' AND "
	cSQL += "BDC_NUMERO <= '"+mv_par04+"' AND "
	cSQL += cBDCName+".D_E_L_E_T_ = '' "
	cSQL += "ORDER BY " + BDC->(IndexKey())
	cStatus	:= "0"
Endif

PLSQuery(cSQL,"r590Imp")

If r590Imp->(Eof())
   r590Imp->(DbCloseArea())
   Help("",1,"RECNO")
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe mensagem...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsProcTxt(PLSTR0001) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da impressao dos detalhes...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

BG9->(DbSetOrder(1))

While ! r590Imp->(Eof())
	nLi := 80
	VldPag()
	
	@ nLi,00 PSAY STR0004 //"| Vlr Total"
	If mv_par05 = 1		// InterCambio
		@ nLi,11 PSAY Trans(r590Imp->BD0_VALOR, "@E 9,999,999.99")
		@ nLi,25 PSAY STR0005 + Str(r590Imp->BD0_CONGER, 6) //"Contratos Gerados "
		@ nLi,51 PSAY STR0006 + Str(r590Imp->BD0_CONCRI, 6) //"Contratos Criticados "
	Else
		@ nLi,11 PSAY Trans(r590Imp->BDC_VALOR, "@E 9,999,999.99")
		@ nLi,25 PSAY STR0005 + Str(r590Imp->BDC_CONGER, 6) //"Contratos Gerados "
		@ nLi,51 PSAY STR0006 + Str(r590Imp->BDC_CONCRI, 6) //"Contratos Criticados "
	Endif
	@ nLi++,79 PSAY "|"
	If mv_par05 = 1 .Or. r590Imp->BDC_TIPO	= "1" // InterCambio ou Juridica
		@ nLi ++,00 PSAY "+---------------------------------+------------------+-----------------+-------+"
		@ nLi ++,00 PSAY STR0007 //"|EMPRESA                          |  Contrato/Versao | Sub.Cont/Versao | Vencto|"
		@ nLi ++,00 PSAY "+---------------------------------+------------------+-----------------+-------+"
		BDW->(DbSeek(xFilial("BDW") + cStatus + _cChave))
		While 	! BDW->(Eof()) .And. BDW->BDW_FILIAL = xFilial("BDW") .And.;
				BDW->BDW_TIPO = cStatus .And. BDW->BDW_CODOPE + BDW->BDW_NUMERO = _cChave
			BG9->(MsSeek(xFilial("BG9") + BDW->BDW_CODOPE + BDW->BDW_CODEMP))
			@ nLi,00 PSAY "|" + BDW->BDW_CODEMP + " - " + Left(BG9->BG9_DESCRI, 25)
			@ nLi,34 PSAY "| " + BDW->BDW_CONEMP + "/" + BDW->BDW_VERCON + " |"
			@ nLi,55 PSAY BDW->BDW_SUBCON + " / " + BDW->BDW_VERSUB + " |"
			@ nLi++,79 PSAY "|"
			BDW->(DbSkip())
		EndDo
		@ nLi ++,00 PSAY "+---------------------------------+------------------+-----------------+-------+"
		@ nLi ++,00 PSAY STR0008 //"| * Vencimento informado somente para esse lote de cobranca                    |"
	Endif
	BDF->(DbSetOrder(3))
	If BDF->(DbSeek(xFilial("BDF") + cStatus + _cChave))
		@ nLi ++,00 PSAY "+------------------------------ NIVEIS DE COBRANCA ----------------------------+"
		@ nLi ++,00 PSAY STR0009 //"|EMPRESA| Contrato/Versao|Sub.Cont/Versao |Familia/T|Niv| Num Titulo|    Valor |"
		@ nLi ++,00 PSAY "+-------+----------------+----------------+---------+---+-----------+----------+"

		While 	! BDF->(Eof()) .And. BDF->BDF_FILIAL = xFilial("BDW") .And.;
				BDF->BDF_CODOPE + BDF->BDF_NUMERO = _cChave .And. BDF->BDF_NIVEL < "7"
			cNivel := BDF->BDF_NIVEL
			While 	! BDF->(Eof()) .And. BDF->BDF_FILIAL = xFilial("BDW") .And.;
					BDF->BDF_CODOPE + BDF->BDF_NUMERO = _cChave .And. BDF->BDF_NIVEL = cNivel
				VldPag()
				@ nLi,00 PSAY "| " + BDF->BDF_CODEMP
				@ nLi,08 PSAY "|" + BDF->BDF_NUMCON + "/" + BDF->BDF_VERCON
				@ nLi,25 PSAY "| " + BDF->BDF_SUBCON + " / " + BDF->BDF_VERSUB
				@ nLi,42 PSAY "|" + BDF->BDF_MATRIC + "/" + BDF->BDF_TIPREG
				@ nLi,52 PSAY "| " + BDF->BDF_NIVEL
				@ nLi,56 PSAY "| " + BDF->BDF_PREFIX + "/" + BDF->BDF_NUMTIT + "|"
				@ nLi,69 PSAY Trans(BDF->BDF_VALOR, "@E 999,999.99")
				@ nLi++,79 PSAY "|"
				
				lTraco := .T.
				
				If mv_par06 = 1		// Detalha Usuarios Cobrados
					cSQL := "SELECT BM1_MATUSU, BM1_NOMUSR, BM1_VALOR FROM "+cBM1Name+" WHERE "
					cSQL += "BM1_FILIAL = '"+xFilial("BM1")+"' AND "
					cSQL += "BM1_PREFIX = '"+BDF->BDF_PREFIX+"' AND "
					cSQL += "BM1_NUMTIT = '"+BDF->BDF_NUMTIT+"' AND "
					cSQL += "BM1_PARCEL = '"+BDF->BDF_PARCEL+"' AND "
					cSQL += "BM1_TIPTIT = '"+BDF->BDF_TIPTIT+"' AND "
					If BDF->BDF_INTERC == '0'
						cSQL += "(BM1_INTERC = '0' or BM1_INTERC = ' ') AND "
					Else
						cSQL += "BM1_INTERC = '"+BDF->BDF_INTERC+"' AND "
					Endif
					cSQL += "BM1_MES = '"+BDF->BDF_MESTIT+"' AND "
					cSQL += "BM1_ANO = '"+BDF->BDF_ANOTIT+"' AND "
					cSQL += "BM1_NIVCOB = '"+cNivel+"' AND "
					cSQL += "BM1_LTOTAL = '0' AND " + cBM1Name+".D_E_L_E_T_ = '' "
					cSQL += "ORDER BY " + BM1->(IndexKey())

					PLSQuery(cSQL,"r590Usu")
					lPrimeiro := .F.
					
					While ! R590USU->(Eof())
						VldPag()
						If ! lPrimeiro 
							@ nLi ++,00 PSAY "+------------------------------ USUARIOS COBRADOS ------------------+----------+"
							@ nLi ++,00 PSAY STR0010 //"|Usuario - Nome do Usuario                                          |Vl Cobrado|"
							@ nLi ++,00 PSAY "+-------------------------------------------------------------------+----------+"
							lPrimeiro := .T.
						Endif

						@ nLi,00 PSAY "|" + Trans(R590Usu->BM1_MATUSU, __cPictUsr + ".!")+;
						" - " + R590Usu->BM1_NOMUSR
						@ nLi ++,68 PSAY "|" + Trans(R590Usu->BM1_VALOR, "@E 999,999.99") + "|"
						R590USU->(DbSkip())
					EndDo
					R590USU->(DbCloseArea())
					
                    If lPrimeiro
						lTraco := .F.
						@ nLi ++,00 PSAY "+=======+================+================+=========+===+===========+==========+"
					Endif
				Endif

				If mv_par07 = 1		// Detalha Criticas                                         
					cSQL := "SELECT BDG_CODCRI, BDG_DTCRIT FROM "+cBDGName+" WHERE "
					cSQL += "BDG_FILIAL = '"+xFilial("BDG")+"' AND "
					cSQL += "BDG_INTERC = '"+BDF->BDF_INTERC+"' AND "
					cSQL += "BDG_CODOPE = '"+BDF->BDF_CODOPE+"' AND "
					cSQL += "BDG_NUMERO = '"+BDF->BDF_NUMERO+"' AND "
					cSQL += "BDG_CODSEQ = '"+BDF->BDF_CODSEQ+"' AND "
					cSQL += "BDG_NIVEL = '"+BDF->BDF_NIVEL+"' AND "
					cSQL += cBDGName+".D_E_L_E_T_ = '' "
					cSQL += "ORDER BY " + BDG->(IndexKey())

					PLSQuery(cSQL,"r590Cri")
					
					lPrimeiro := .F.
					
					While ! R590CRI->(Eof())
						If ! lPrimeiro
							@ nLi ++,00 PSAY "+--------------------------- CRITICAS NIVEL COBRANCA ---------------+----------+"
							@ nLi ++,00 PSAY STR0011 //"|Codigo / Descricao da Critica                                      |Dt Critica|"
							@ nLi ++,00 PSAY "+-------------------------------------------------------------------+----------+"
							lPrimeiro := .T.
						Endif
                                                                                                           
						SX5->(DbSeek(xFilial("SX5") + "BI" + R590Cri->BDG_CODCRI))
						@ nLi,00 PSAY "|" + R590Cri->BDG_CODCRI + " - " + X5Descri()
						@ nLi ++,68 PSAY "|" + Left(Dtoc(R590Cri->BDG_DTCRIT), 5) +;
						Str(Year(R590Cri->BDG_DTCRIT), 4) + "|"
						R590CRI->(DbSkip())
					EndDo
					R590CRI->(DbCloseArea())

					If lPrimeiro
						lTraco := .F.
						@ nLi ++,00 PSAY "+=======+================+================+=========+===+===========+==========+"
					Endif
				Endif
				BDF->(DbSkip())
			EndDo
			If lTraco
				@ nLi ++,00 PSAY "+=======+================+================+=========+===+===========+==========+"
			Endif
		EndDo
		@ nLi ++,00 PSAY STR0012 //"|Nivel 1-Empresa  2-Contrato  3-Sub-Contrato  4-Familia  5-Usuario  6-Opcional |"
		@ nLi ++,00 PSAY "+------------------------------------------------------------------------------+"
	Endif
	BDF->(DbSetOrder(1))
		                            
 	r590Imp->(DbSkip())
Enddo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime rodape do relatorio...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Roda(0,space(10),cTamanho)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha arquivo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
r590Imp->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt .AND. aReturn[5] == 1 
    Set Printer To
    Ourspool(cRel)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Relat¢rio                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("BDC")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Programa   ³ R590Cabec ³ Autor ³ Tulio Cesar          ³ Data ³ 14.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime Cabecalho                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R590Cabec()      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime cabecalho...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
nLi ++
@ nLi,00 PSAY STR0013 //"| Lote Cobranca"
If mv_par05 = 1		// InterCambio
	@ nLi,16 PSAY r590Imp->BD0_CODOPE + "-" + r590Imp->BD0_NUMERO
	@ nLi,57 PSAY 	"Mes " + r590Imp->BD0_MESINI + "/" + r590Imp->BD0_ANOINI +;
					" a " + r590Imp->BD0_MESFIM + "/" + r590Imp->BD0_ANOFIM
	_cChave := r590Imp->BD0_CODOPE + r590Imp->BD0_NUMERO
Else
	@ nLi,16 PSAY r590Imp->BDC_CODOPE + "-" + r590Imp->BDC_NUMERO
	@ nLi,31 PSAY Padc(STR0014 + QA_CBOX("BDC_TIPO",r590Imp->BDC_TIPO), 24) //"Lote Pessoa "
	@ nLi,57 PSAY 	"Mes " + r590Imp->BDC_MESINI + "/" + r590Imp->BDC_ANOINI +;
					" a " + r590Imp->BDC_MESFIM + "/" + r590Imp->BDC_ANOFIM
	_cChave := r590Imp->BDC_CODOPE + r590Imp->BDC_NUMERO
Endif
@ nLi++,79 PSAY "|"
@ nLi++,00 PSAY "+------------------------------------------------------------------------------+"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return                                                                       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Programa   ³ VLDPAG    ³ Autor ³ Tulio Cesar          ³ Data ³ 14.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Valida a proxima pagina...                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function VldPag()

If nLi > nQtdLin
   R590Cabec()
Endif 


Return
