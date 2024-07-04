#INCLUDE "PLSR595.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

static lAutoSt := .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR595 ³ Autor ³Geraldo Felix Junior.   ³ Data ³ 19.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Emissao do resumo de cobranca (Padrao / Intercambio)       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR595                                                    ³±±±
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
Function PLSR595(cmv_par01, cmv_par02, cmv_par03, cmv_par04, cmv_par05)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis padroes para todos os relatorios...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nQtdLin     := 60
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := FunDesc() //"Conferência de Lote de Cobrança"
PRIVATE cDesc1      := STR0002 //"Este Relatorio tem como objetivo emitir resumo demonstrando a composicao de"
PRIVATE cDesc2      := STR0003  //"um lote de cobranca."
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BDC"
PRIVATE cPerg       := "PLR595"
PRIVATE cRel        := "PLSR595"
PRIVATE nli         := 132
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .F. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := '' 
PRIVATE cCabec2     := '' 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa ambiente do relatorio somente top...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! PLSRelTop()
   Return
Endif    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         				³
//³ mv_par01 // Operadora Inicial                          						³
//³ mv_par02 // Operado Final                                    				³
//³ mv_par03 // Numero Cobranca incial                    						³
//³ mv_par04 // Numero Cobranca Final                            				³
//³ mv_par05 // Empresa de                                       				³
//³ mv_par06 // Empresa ate                                      				³
//³ mv_par07 // Contrato de                                      				³
//³ mv_par08 // Contrato ate                                     				³
//³ mv_par09 // Sub Contrato de                                  				³
//³ mv_par10 // Sub Contrato ate                                 				³
//³ mv_par11 // Matricula de                                     				³
//³ mv_par12 // Matricula ate                                    				³
//³ mv_par13 // Detalha usuarios cobrados                        				³
//³ mv_par14 // Demonstra criticas ?                             				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
If !lAutoSt .ANd. cMv_par01 # Nil
	mv_par01 := cMv_par01
	mv_par02 := cMv_par02
	mv_par03 := cMv_par03
	mv_par04 := cMv_par04                                                    	
	mv_par05 := cMv_par05
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint (padrao)                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao (padrao)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt .AND. nLastKey  == 27 
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura impressora (padrao)                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	SetDefault(aReturn,cAlias) 
endif

if lAutoSt
	R595ImpAn()
	R595ImpSi()
else
	If mv_par14 == 1           
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Emite relat¢rio Analitico...                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		MsAguarde({|| R595ImpAn() }, cTitulo, "", .T.)
				
	Elseif mv_par14 = 2                                
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Emite relat¢rio sintetico...                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsAguarde({|| R595ImpSi() }, cTitulo, "", .T.)

	Endif	
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R595ImpSi³ Autor ³ Geraldo Felix Junior. ³ Data ³ 14.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime detalhe do relatorio sintetico...                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R595ImpSi()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cLinha	:= ''
LOCAL cQuebra   := ''
LOCAL cSQL  	:= ''
LOCAL cFiltro	:= ''
LOCAL nTotGrp 	:= 0
LOCAL nCol		:= 05
LOCAL nTotCre	:= 0
LOCAL nTotDeb	:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis com os alias utilizados nas querys...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cBDCName 	:= BDC->(RetSQLName("BDC"))
LOCAL cBD0Name 	:= BD0->(RetSQLName("BD0"))
LOCAL cBM1Name 	:= BM1->(RetSQLName("BM1"))
LOCAL cBDGName 	:= BDG->(RetSQLName("BDG"))
LOCAL cBDFName 	:= BDF->(RetSQLName("BDF"))
LOCAL cBG9Name 	:= BG9->(RetSQLName("BG9"))
LOCAL cStatus	:= ""
LOCAL Primeiro 	:= ""
LOCAL lTraco := .F.
LOCAL cNivel	:= ""
LOCAL a595Usu	:= {}
LOCAL nCo		:= 0
LOCAL aColunas	:= {{1,000},{2,41},{3,076}}
LOCAL a595Usu1  := {}
LOCAL a595Usu2  := {}
LOCAL nMax		:= 0,nCnt
Local lTemFat	:= .T.
PRIVATE _cChave := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine o cabecalho...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec1     := STR0015+"                                               "+STR0016+"        "+STR0017+"  "+STR0018+"  "+STR0017+"  " //"GRUPO"###"CONTRATO"###"VERSAO"###"SUB CONTRATO"###"VERSAO"
cCabec2     := STR0019+"                                         "+STR0020+"  "+STR0021+"   "+STR0022+"           "+STR0023+"               "+STR0024 //"CLIENTE"###"PRF"###"NUMERO"###"DATA VENCIMENTO"###"COMPETENCIA"###"VALOR TOTAL"

BM1->(DbSetOrder(3))
BDC->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par13 = 1		// InterCambio
	cSQL := "SELECT * FROM "+cBD0Name+" WHERE "
	cSQL += "BD0_FILIAL = '"+xFilial("BD0")+"' AND "
	cSQL += "BD0_CODOPE >= '"+mv_par01+"' AND "
	cSQL += "BD0_NUMERO >= '"+mv_par03+"' AND "
	cSQL += "BD0_CODOPE <= '"+mv_par02+"' AND "
	cSQL += "BD0_NUMERO <= '"+mv_par04+"' AND "
	cSQL += cBD0Name+".D_E_L_E_T_ = '' "
	cSQL += "ORDER BY " + BD0->(IndexKey())
	cStatus	:= "1"
Else
	cSQL := "SELECT * FROM "+cBDCName+" WHERE "
	cSQL += "BDC_FILIAL = '"+xFilial("BDC")+"' AND "
	cSQL += "BDC_CODOPE >= '"+mv_par01+"' AND "
	cSQL += "BDC_NUMERO >= '"+mv_par03+"' AND "
	cSQL += "BDC_CODOPE <= '"+mv_par02+"' AND "
	cSQL += "BDC_NUMERO <= '"+mv_par04+"' AND "
	cSQL += cBDCName+".D_E_L_E_T_ = '' "
	cSQL += "ORDER BY " + BDC->(IndexKey())
	cStatus	:= "0"
Endif

PLSQuery(cSQL,"R595Imp")

If R595Imp->(Eof())
   R595Imp->(DbCloseArea())
   Help("",1,"RECNO")
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe mensagem...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	MsProcTxt(PLSTR0001) 
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da impressao dos detalhes...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BG9->(DbSetOrder(1))
nLi := 80

While ! r595Imp->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o cabecalho do relatorio...                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	              
	VldPag()
	If lTemFat
		nLi += 2
	EndIf
	lTemFat := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Arquivos diferente para pre-pagamento e intercambio...                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	              
	If mv_par13 = 1		// InterCambio
		cCodOpe := R595Imp->BDO_CODOPE
		cNumero := R595Imp->BDO_NUMERO
	Else
		cCodOpe := R595Imp->BDC_CODOPE
		cNumero := R595Imp->BDC_NUMERO
	Endif				
		                                                      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtem dados das faturas geradas para o lote de cobranca...               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	              		
	cFiltro := "SELECT * FROM "+cBDFName+","+cBG9Name+" WHERE "
	cFiltro += cBDFName+".D_E_L_E_T_ = '' AND "
	cFiltro += cBG9Name+".D_E_L_E_T_ = '' AND "
	cFiltro += "BDF_CODOPE = BG9_CODINT AND BDF_CODEMP = BG9_CODIGO AND "
	cFiltro += "BDF_CODOPE = '"+cCodOpe+"' AND BDF_NUMERO = '"+cNumero+"' "
	cFiltro += "AND BDF_CODEMP >= '"+mv_par05+"' AND BDF_CODEMP <= '"+mv_par06+"' "
	cFiltro += "AND BDF_NUMCON >= '"+mv_par07+"' AND BDF_NUMCON <= '"+mv_par08+"' "
	cFiltro += "AND BDF_SUBCON >= '"+mv_par09+"' AND BDF_SUBCON <= '"+mv_par10+"' "
	cFiltro += "ORDER BY BDF_CODOPE, BDF_CODEMP, BDF_NUMERO,  BDF_PREFIX, BDF_NUMTIT  "	
	PLSQUERY(cFiltro,"TRB1")
	
	While !TRB1->( Eof() )
		nLi += 1
		lTemFat := .T.
	
		@ nLi, 000 Psay TRB1->BDF_CODEMP+Space(02)+" - "+Alltrim(Left(TRB1->BG9_DESCRI,30))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime e posiciona o contrato caso seja pessoa juridica...              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	              		
		If !Empty(TRB1->BDF_NUMCON)
			BT5->( dbSeek(xFilial("BT5")+TRB1->BDF_CODOPE+TRB1->BDF_CODEMP+TRB1->BDF_NUMCON+TRB1->BDF_VERCON) )
			@ nLi, 052 Psay TRB1->BDF_NUMCON
			@ nLi, 070 Psay TRB1->BDF_VERCON
		Else
			@ nLi, 052 Psay STR0025+"..." //"TODOS"
		Endif                          
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime e posiciona o sub contrato caso seja pessoa juridica...          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	              		
		If !Empty(TRB1->BDF_SUBCON)
			BQC->( dbSeek(xFilial("BQC")+TRB1->BDF_CODOPE+TRB1->BDF_CODEMP+TRB1->BDF_NUMCON+;
										  TRB1->BDF_VERCON+TRB1->BDF_SUBCON+TRB1->BDF_VERSUB) )
			@ nLi, 076 Psay TRB1->BDF_SUBCON
			@ nLi, 084 Psay TRB1->BDF_VERSUB
			@ nLi, 093 Psay Alltrim(Left(BQC->BQC_DESCRI,30))
		Else
			@ nLi, 076 Psay STR0025+"..." //"TODOS"
		Endif                          			
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime os dados da fatura...                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	              								  		
        SE1->(DbSeek(xFilial("SE1")+TRB1->BDF_PREFIX+TRB1->BDF_NUMTIT+TRB1->BDF_PARCEL+TRB1->BDF_TIPTIT))
		nLi++
		
		@ nLi, 000 Psay SE1->E1_CLIENTE+" - "
		@ nLi, 009 Psay Alltrim(Left(SE1->E1_NOMCLI,30))
		@ nLi, 048 Psay SE1->E1_PREFIXO
		@ nLi, 053 Psay SE1->E1_NUM
		@ nLi, 066 Psay dToc(SE1->E1_VENCTO)
		@ nLi, 090 Psay SE1->E1_ANOBASE+"/"+SE1->E1_MESBASE
		@ nLi, 107 Psay Transform(SE1->E1_VALOR,"@E 99,999,999,999.99")
		nTotGrp += SE1->E1_VALOR
                  
		cSQL := "SELECT BM1_VALOR, BM1_CODTIP, BM1_DESTIP,BM1_TIPO, BM1_LTOTAL FROM "+cBM1Name+" WHERE "
		cSQL += "BM1_FILIAL = '"+xFilial("BM1")+"' 		AND "
		cSQL += "BM1_PREFIX	= '"+TRB1->BDF_PREFIX+"' 	AND "
		cSQL += "BM1_NUMTIT	= '"+TRB1->BDF_NUMTIT+"' 	AND "
		cSQL += "BM1_PARCEL	= '"+TRB1->BDF_PARCEL+"' 	AND "
		cSQL += "BM1_TIPTIT	= '"+TRB1->BDF_TIPTIT+"' 	AND "
		cSQL += "BM1_INTERC	= '"+TRB1->BDF_INTERC+"' 	AND "
		cSQL += "BM1_MES 	= '"+TRB1->BDF_MESTIT+"' 	AND "
		cSQL += "BM1_ANO 	= '"+TRB1->BDF_ANOTIT+"' 	AND "
		cSQL += "BM1_NIVCOB	= '"+TRB1->BDF_NIVEL+"' 	AND "
		cSQL += cBM1Name+".D_E_L_E_T_ = '' "
		cSQL += "ORDER BY " + BM1->(IndexKey())

		PLSQuery(cSQL,"R595Usu")
		lPrimeiro := .F.                            
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula os tipo de lancamentos num array para imprimi-lo...        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		       
		a595Usu1 := {}
		a595Usu2 := {}
		While !R595Usu->( Eof() )
			If R595Usu->BM1_TIPO == '1'
				nPos  := Ascan(a595Usu1, {|x| x[2] == R595Usu->BM1_CODTIP .AND. x[4] == R595Usu->BM1_TIPO} )
				If nPos == 0
					Aadd(a595Usu1, {R595Usu->BM1_VALOR, R595Usu->BM1_CODTIP, R595Usu->BM1_DESTIP,;
									  R595Usu->BM1_TIPO,R595Usu->BM1_LTOTAL})
				Else
					a595Usu1[nPos][1] += R595Usu->BM1_VALOR
				Endif                      
				
			Elseif R595Usu->BM1_TIPO == '2'
				nPos  := Ascan(a595Usu2, {|x| x[2] == R595Usu->BM1_CODTIP .AND. x[4] == R595Usu->BM1_TIPO} )
				If nPos == 0
					Aadd(a595Usu2, {R595Usu->BM1_VALOR, R595Usu->BM1_CODTIP, R595Usu->BM1_DESTIP,;
									  R595Usu->BM1_TIPO,R595Usu->BM1_LTOTAL})
				Else
					a595Usu2[nPos][1] += R595Usu->BM1_VALOR
				Endif
			Endif			
			R595Usu->( dbSkip() )
		Enddo    
		R595Usu->(dbClosearea())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ordena o array por tipo de lancamento...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                     
		aSort(a595Usu,,,{|x, y| x[2] < y[2]})
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o resumo dos debitos da fatura...                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCo := 4
		nLi += 2            
		@ nLi, 010 Psay STR0026		 //"Debitos:"
		@ nLi, 075 Psay STR0027 //"Creditos:"

		nMax := Iif(Len(a595Usu1) >= Len(a595Usu2), Len(a595Usu1), Len(a595Usu2))
		                   
		nLi++
		For nCnt := 1 To nMax

			VldPag()		
			If nCnt <= Len(a595Usu1)
				@ nLi, 010 Psay Alltrim(Left(a595Usu1[nCnt][3],28))+": "
				@ nLi, 044 Psay Transform(a595Usu1[nCnt][1],"@E 99,999,999,999.99")
				nTotDeb += a595Usu1[nCnt][1]
			Endif
										
			If nCnt <= Len(a595Usu2)
				@ nLi, 075 Psay Alltrim(Left(a595Usu2[nCnt][3],28))+": "
				@ nLi, 109 Psay Transform(a595Usu2[nCnt][1],"@E 99,999,999,999.99")
				nTotCre += a595Usu2[nCnt][1]
			Endif
						
			nLi++
		Next
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o total dos debitos da fatura...                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If (nTotDeb+nTotCre) <> 0
			nLi++   
		Endif
		
		If nTotDeb <> 0
			VldPag()          
			@ nLi, 010 Psay STR0028 //"Total dos Debitos:"
			@ nLi, 044 Psay Transform(nTotDeb,"@E 99,999,999,999.99")
			nTotDeb := 0
		Endif
		    	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o total dos creditos da fatura...                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If nTotCre <> 0
			VldPag()
			@ nLi, 075 Psay STR0029 //"Total dos Creditos:"
			@ nLi, 109 Psay Transform(nTotCre,"@E 99,999,999,999.99")
			nTotCre := 0
		Endif		
		
		nLi++
		@ nLi, 000 Psay Replicate("=",132)	
		
		TRB1->( dbSkip() )
	Enddo
	
 	R595Imp->(DbSkip())
	TRB1->( dbClosearea() )
Enddo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime rodape do relatorio...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	Roda(0,space(10),cTamanho)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha arquivo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
R595Imp->(DbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt .ANd. aReturn[5] == 1 
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
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R595ImpAn³ Autor ³ Geraldo Felix Junior. ³ Data ³ 14.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime detalhe do relatorio analitico...                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R595ImpAn()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cLinha	:= ''
LOCAL cQuebra   := ''
LOCAL cSQL  	:= ''
LOCAL cFiltro	:= ''
LOCAL nTotGrp 	:= 0
LOCAL nCol		:= 05
LOCAL nTotCre	:= 0
LOCAL nTotDeb	:= 0
LOCAL cKey		:= ''
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis com os alias utilizados nas querys...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cBDCName 	:= BDC->(RetSQLName("BDC"))
LOCAL cBD0Name 	:= BD0->(RetSQLName("BD0"))
LOCAL cBM1Name 	:= BM1->(RetSQLName("BM1"))
LOCAL cBDGName 	:= BDG->(RetSQLName("BDG"))
LOCAL cBDFName 	:= BDF->(RetSQLName("BDF"))
LOCAL cBG9Name 	:= BG9->(RetSQLName("BG9"))
LOCAL cBDDName  := BDD->(RetSQLName("BDD"))
LOCAL cStatus	:= ""
LOCAL Primeiro 	:= ""
LOCAL lTraco := .F.
LOCAL cNivel	:= ""
LOCAL a595Usu	:= {}
LOCAL nCo		:= 0
LOCAL aColunas	:= {{1,000},{2,41},{3,076}}
LOCAL a595Usu1  := {}
LOCAL a595Usu2  := {}
LOCAL nMax		:= 0
LOCAL nGroup1 := 0
LOCAL nGroup2 := 0 ,nCnt
Local lTemFat := .T.
PRIVATE _cChave := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine o cabecalho...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec1     := STR0015+"                                                                                   "+STR0030+" " //"GRUPO"###"NUMERO DO LOTE"
cCabec2     := STR0019+"                                         "+STR0020+"  "+STR0021+"   "+STR0022+"           "+STR0023+"               "+STR0024 //"CLIENTE"###"PRF"###"NUMERO"###"DATA VENCIMENTO"###"COMPETENCIA"###"VALOR TOTAL"

BM1->(DbSetOrder(3))
BDC->(DbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cSQL := "SELECT * FROM "+cBDCName+" WHERE "
cSQL += "BDC_FILIAL = '"+xFilial("BDC")+"' AND "
cSQL += "BDC_CODOPE >= '"+mv_par01+"' AND "
cSQL += "BDC_NUMERO >= '"+mv_par03+"' AND "
cSQL += "BDC_CODOPE <= '"+mv_par02+"' AND "
cSQL += "BDC_NUMERO <= '"+mv_par04+"' AND "
If mv_par13 = 1
	cSql += "BDC_INTERC = '1' AND "
Else
	cSql += "BDC_INTERC = '0' AND "
Endif
cSQL += cBDCName+".D_E_L_E_T_ = '' "
cSQL += "ORDER BY " + BDC->(IndexKey())
cStatus	:= "0"

PLSQuery(cSQL,"R595Imp")


If !lAutoSt .AND. R595Imp->(Eof())
   R595Imp->(DbCloseArea())
   Help("",1,"RECNO")
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe mensagem...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	MsProcTxt(PLSTR0001) 
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da impressao dos detalhes...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BG9->(DbSetOrder(1))
nLi := 80

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime todos os lotes selecionados no parametros...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ! r595Imp->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o cabecalho do relatorio...                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VldPag()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Arquivos diferente para pre-pagamento e intercambio...                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
	If mv_par13 = 1		// InterCambio
		cCodOpe := R595Imp->BDO_CODOPE
		cNumero := R595Imp->BDO_NUMERO
	Else
*/	
		cCodOpe := R595Imp->BDC_CODOPE
		cNumero := R595Imp->BDC_NUMERO
//	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtem dados das faturas geradas para o lote de cobranca...               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltro := "SELECT * FROM "+cBDFName+","+cBG9Name+","+cBDDName+" WHERE "
	cFiltro += cBDFName+".D_E_L_E_T_ = '' AND "
	cFiltro += cBG9Name+".D_E_L_E_T_ = '' AND " 
	cFiltro += cBDDName+".D_E_L_E_T_ = '' AND " 
	cFiltro += "BDF_CODOPE = BG9_CODINT AND BDF_CODEMP = BG9_CODIGO AND "
	cFiltro += "BDF_CODOPE = BDD_CODOPE AND BDF_NUMERO = BDD_NUMERO AND "
	cFiltro += "BDF_NIVEL  = BDD_NIVEL  AND BDD_VLREXT = 0          AND "
	
	cFiltro += "BDF_CODOPE = '"+cCodOpe+"' AND BDF_NUMERO = '"+cNumero+"' AND "
	// contempla novos paremetros...
	cFiltro += "BDF_CODEMP >= '"+mv_par05+"' AND BDF_CODEMP <= '"+mv_par06+"' AND "
	cFiltro += "BDF_NUMCON >= '"+mv_par07+"' AND BDF_NUMCON <= '"+mv_par08+"' AND "
	cFiltro += "BDF_SUBCON >= '"+mv_par09+"' AND BDF_SUBCON <= '"+mv_par10+"' AND "
	cFiltro += "BDF_MATRIC >= '"+mv_par11+"' AND BDF_MATRIC <= '"+mv_par12+"' "
	cFiltro += "ORDER BY BDF_CODOPE, BDF_CODEMP, BDF_NUMERO,  BDF_PREFIX, BDF_NUMTIT  "	
	PLSQUERY(cFiltro,"TRB1")
	If lTemFat
		nLi++
	EndIf
	lTemFat := .F.
	
	While !TRB1->( Eof() )                                        
		cKey := TRB1->BDF_CODOPE+TRB1->BDF_CODEMP+TRB1->BDF_NUMERO
		While !TRB1->( Eof() ) .AND. TRB1->(BDF_CODOPE+BDF_CODEMP+BDF_NUMERO) == cKey
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona o titulo da linha gerada...                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE1->(DbSeek(xFilial("SE1")+TRB1->BDF_PREFIX+TRB1->BDF_NUMTIT+TRB1->BDF_PARCEL+TRB1->BDF_TIPTIT))
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Primeira quebra, empresa...                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				BG9->( dbSetorder(01) )
				BG9->( dbSeek(xFilial("BG9")+TRB1->(BDF_CODOPE+BDF_CODEMP)) )
				
				@ nLi, 002 Psay TRB1->BDF_CODEMP+" - "+Left(Posicione("BG9",1,xFilial("BG9")+TRB1->BDF_CODOPE+TRB1->BDF_CODEMP,"BG9_DESCRI"),35)+;
				 									   Iif(!Empty(BG9->BG9_EMPANT) .and. !BG9->( Eof() ), "( "+Alltrim(BG9->BG9_EMPANT)+" )", '')
				@ nLi, 090 Psay Substr(SE1->E1_PLNUCOB,5,8)
				nLi++
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime os dados do titulo...                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLi++
				@ nLi, 000 Psay SE1->E1_CLIENTE+" - "+Alltrim(Left(SE1->E1_NOMCLI,30))
				@ nLi, 048 Psay SE1->E1_PREFIXO
				@ nLi, 053 Psay SE1->E1_NUM
				@ nLi, 066 Psay dToc(SE1->E1_VENCTO)
				@ nLi, 090 Psay SE1->E1_ANOBASE+"/"+SE1->E1_MESBASE				
				@ nLi, 112 Psay Transform(SE1->E1_VALOR,"@E 99,999,999,999.99")
				nLi++
				@ nLi, 000 Psay Replicate('-',132)
				nLi++
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obtem a quantidade de usuarios por faixa x produto x sub contrato...     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cFiltro := "SELECT * FROM "+cBM1Name+" WHERE "
				cFiltro += "BM1_NUMTIT = '"+SE1->E1_NUM+"' 		AND "
				cFiltro += "BM1_PREFIX = '"+SE1->E1_PREFIXO+"' 	AND "
				cFiltro += "D_E_L_E_T_ <> '*' "
				cFiltro += "Order by BM1_CODEMP, BM1_CONEMP, BM1_VERCON, BM1_SUBCON, BM1_VERSUB,BM1_CODEVE, BM1_IDAINI, BM1_IDAFIN "
				PlsQuery(cFiltro, "TRB2")
				                                  
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processa o resultado obtido...                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While !TRB2->( Eof() ) 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Somente processa mensalidade e opcionais...                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					If TRB2->BM1_CODTIP <> '101' .AND. TRB2->BM1_CODTIP <> '102' .AND. TRB2->BM1_CODTIP <> '103'
						TRB2->( dbSkip() )
						Loop
					Endif
					
					aAcumula 	:= {}
					cNumCon		:= TRB2->BM1_CONEMP
					cVerCon		:= TRB2->BM1_VERCON
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Alimenta array com as faixas etarias...                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
					If !Empty(TRB2->BM1_CONEMP)
						BT5->( dbSetorder(01) )
						BT5->( dbSeek(xFilial("BT5")+TRB2->(BM1_CODINT+BM1_CODEMP+BM1_CONEMP+BM1_VERCON)) )
						
						@ nLi, 009 Psay STR0016+" -> "+TRB2->BM1_CONEMP+" / "+STR0017+" -> "+TRB2->BM1_VERCON+; //"Contrato"###"Versao"
										Iif((!Empty(BT5->BT5_ANTCON) .and. !BT5->(Eof())), " ( "+Alltrim(BT5->BT5_ANTCON)+" )", '')
						nLi++
					Endif
					While !TRB2->( Eof() ) .and. TRB2->BM1_CONEMP == cNumCon .and. TRB2->BM1_VERCON == cVerCon
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Quebra do sub contrato...                                                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(TRB2->BM1_SUBCON)
							BQC->( dbSetorder(01) )
							BQC->( dbSeek(xFilial("BQC")+TRB2->(BM1_CODINT+BM1_CODEMP+BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB)) )
							
							@ nLi, 005 Psay "Sub Contrato"+" ->    "+TRB2->BM1_SUBCON+" / "+STR0017+" -> "+TRB2->BM1_VERSUB+; //"Versao"
							" - "+Left(Posicione("BQC",1,xFilial("BQC")+;
							TRB2->BM1_CODINT+TRB2->BM1_CODEMP+;
							TRB2->BM1_CONEMP+TRB2->BM1_VERCON+;
							TRB2->BM1_SUBCON+TRB2->BM1_VERSUB,;
							"BQC_DESCRI"),45)+Iif(!Empty(BQC->BQC_ANTCON) .and. !BQC->(Eof())," ( "+Alltrim(BQC->BQC_ANTCON)+" )",'')
							nLi+=2
						Endif
						
						cSubCon		:= TRB2->BM1_SUBCON
						cVerSub		:= TRB2->BM1_VERSUB
						While !TRB2->( Eof() ) .and. TRB2->BM1_CONEMP == cNumCon .and. TRB2->BM1_VERCON == cVerCon .and. ;
							TRB2->BM1_SUBCON == cSubCon .and. TRB2->BM1_VERSUB == cVerSub
							    
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Somente processa mensalidade e opcionais...                              ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
							If TRB2->BM1_CODTIP <> '101' .AND. TRB2->BM1_CODTIP <> '102' .AND. TRB2->BM1_CODTIP <> '103'
								TRB2->( dbSkip() )
								Loop
							Endif

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Quebra do produto...                                                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If TRB2->BM1_CODTIP <> '103'
								@ nLi, 010 Psay STR0031+" ->         "+Alltrim(TRB2->BM1_CODEVE)+" / "+STR0017+" -> "+TRB2->BM1_VERCON+; //"Produto"###"Versao"
								" - "+Posicione("BI3",1,xFilial("BI3")+;
								TRB2->BM1_CODINT+Substr(TRB2->BM1_CODEVE,1,4),;
								"BI3_DESCRI")
							Else
								@ nLi, 001 Psay STR0032+" ->" //"Taxa de Incricao"
							Endif
							nLi += 2
							
							cCodEve		:= TRB2->BM1_CODEVE
							While !TRB2->( Eof() ) .and. TRB2->BM1_CONEMP == cNumCon .and. TRB2->BM1_VERCON == cVerCon .and. ;
								TRB2->BM1_SUBCON == cSubCon .and. TRB2->BM1_VERSUB == cVerSub .and. ;
								TRB2->BM1_CODEVE == cCodEve
								
								If (nPos := Ascan(aAcumula, {| x |	 x[2] == TRB2->BM1_VALOR  .and.;
									x[3] == TRB2->BM1_IDAINI .and.;
									x[4] == TRB2->BM1_IDAFIN})) == 0
									Aadd(aAcumula, {1, TRB2->BM1_VALOR, TRB2->BM1_IDAINI, TRB2->BM1_IDAFIN})
								Else
									aAcumula[nPos][1] += 1
								Endif
								
								TRB2->( dbSkip() )
							Enddo
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Imprimea as faixas, qtd. de usuarios e valores...                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nCnt := 1 To Len(aAcumula)
								@ nLi, 030 Psay STR0033+StrZero(aAcumula[nCnt][3],3)+" a "+; //"Faixa de "
								StrZero(aAcumula[nCnt][4],3)+"     -   "+;
								Transform(aAcumula[nCnt][1], "@E 999999")+"      x   "+;
								Transform(aAcumula[nCnt][2], "@E 99,999,999,999.99")+"      =   "+;
								Transform((aAcumula[nCnt][2]*aAcumula[nCnt][1]),"@E 9,999,999,999,999.99")
								
								nGroup1 += aAcumula[nCnt][1]
								nGroup2 +=(aAcumula[nCnt][2]*aAcumula[nCnt][1])
								
								nLi++
							Next

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Imprime o valor total por produto...                                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							    
							@ nLi, 080 Psay STR0034+" -> " //"Total"
							@ nLi, 100 Psay Transform(nGroup2,"@E 9,999,999,999,999.99")
							nLi+= 2
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Reseta as variaveis totalizadoras...                                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							    							
							aAcumula := {}
							nGroup1  := 0
							nGroup2  := 0							
						Enddo
					Enddo
				Enddo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acumula os tipo de lancamentos num array para imprimi-lo...        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				a595Usu1 := {}
				a595Usu2 := {}
				TRB2->( dbGotop() )
				
				While !TRB2->( Eof() )
					If TRB2->BM1_TIPO == '1'
						nPos  := Ascan(a595Usu1, {|x| x[2] == TRB2->BM1_CODTIP .AND. x[4] == TRB2->BM1_TIPO} )
						If nPos == 0
							Aadd(a595Usu1, {TRB2->BM1_VALOR, TRB2->BM1_CODTIP, TRB2->BM1_DESTIP,;
							TRB2->BM1_TIPO,TRB2->BM1_LTOTAL,1})
						Else
							a595Usu1[nPos][1] += TRB2->BM1_VALOR  
							a595Usu1[nPos][6] ++
						Endif
						
					Elseif TRB2->BM1_TIPO == '2'
						nPos  := Ascan(a595Usu2, {|x| x[2] == TRB2->BM1_CODTIP .AND. x[4] == TRB2->BM1_TIPO} )
						If nPos == 0
							Aadd(a595Usu2, {TRB2->BM1_VALOR, TRB2->BM1_CODTIP, TRB2->BM1_DESTIP,;
							TRB2->BM1_TIPO,TRB2->BM1_LTOTAL,1})
						Else
							a595Usu2[nPos][1] += TRB2->BM1_VALOR
							a595Usu2[nPos][6] ++
						Endif
					Endif
					TRB2->( dbSkip() )
				Enddo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ordena o array por tipo de lancamento...                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aSort(a595Usu,,,{|x, y| x[2] < y[2]})
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime o resumo dos debitos da fatura...                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nCo := 4                            				
				
				@ nLi, 000 Psay Replicate('-', 132); nLi++				
				@ nLi, 010 Psay STR0026 //"Debitos:"
				@ nLi, 075 Psay STR0027 //"Creditos:"
				
				nMax := Iif(Len(a595Usu1) >= Len(a595Usu2), Len(a595Usu1), Len(a595Usu2))
				
				nLi++
				For nCnt := 1 To nMax
					VldPag()
					If nCnt <= Len(a595Usu1)
						@ nLi, 005 Psay Alltrim(Left(a595Usu1[nCnt][3],28))
						@ nLi, 038 Psay " - "+Transform(a595Usu1[nCnt][6],"99999")
						@ nLi, 050 Psay Transform(a595Usu1[nCnt][1],"@E 9,999,999,999,999.99")
						nTotDeb += a595Usu1[nCnt][1]
					Endif
					
					If nCnt <= Len(a595Usu2)
						@ nLi, 075 Psay Alltrim(Left(a595Usu2[nCnt][3],28))
						@ nLi, 102 Psay " - "+Transform(a595Usu2[nCnt][6],"99999")
						@ nLi, 110 Psay Transform(a595Usu2[nCnt][1],"@E 9,999,999,999,999.99")
						nTotCre += a595Usu2[nCnt][1]
					Endif
					nLi++
				Next
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime o total dos debitos da fatura...                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nTotDeb+nTotCre) <> 0
					nLi++
				Endif
				
				If nTotDeb <> 0
					VldPag()
					@ nLi, 005 Psay STR0028 //"Total dos Debitos:"
					@ nLi, 050 Psay Transform(nTotDeb,"@E 9,999,999,999,999.99")
					nTotDeb := 0
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime o total dos creditos da fatura...                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nTotCre <> 0
					VldPag()
					@ nLi, 075 Psay STR0029 //"Total dos Creditos:"
					@ nLi, 110 Psay Transform(nTotCre,"@E 9,999,999,999,999.99")
					nTotCre := 0
				Endif
				
				nLi++
				@ nLi, 000 Psay Replicate("=",132)
				nLi++
				TRB2->( dbClosearea() )
			Endif
			TRB1->( dbSkip() )
		Enddo
		nLi++
	Enddo
	TRB1->( dbCloseArea() )
	r595Imp->( dbSkip() )
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime rodape do relatorio...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	Roda(0,space(10),cTamanho)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha arquivo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
R595Imp->(DbCloseArea())

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
±±³Programa   ³ R595Cabec ³ Autor ³ Tulio Cesar          ³ Data ³ 14.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime Cabecalho                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R595Cabec()      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime cabecalho...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
endif
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
   R595Cabec()
Endif 

Return

/*                                                                           
          10        20        30        40        50        60        70        80        90        100       110
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
GRUPO                                               CONTRATO    VERSAO  SUB CONTRATO  VERSAO  
Cliente                               		    PRF  NUMERO      Data Vencimento                        Valor
-----------------------------------------------------------------------------------------------------------------
9999   - ASSOCIACAO DOS FUNCIONARIOS DA UNIFAC	    0000000001  0001      000001      0001
999999 - SPADOTTO & SPADOTTO LTDA ME  		    PLS  000001	    20/03/04			  			 9.999.999,99
	    
Debitos:
Produto/Plano (Mensalidade): 999.999,99  Taxa Inscrição/Adesão: 999.999,99  Custo Operacional.....: 999.999,99
Cartão de Identificação....:  99.999,99  Taxa Administrativa..:  99.999,99  Mensalidade Retroativa: 999.999,99
Valor base IR..............: 999.999,99  Valor do IR..........:  99.999,99
*/

Function PLSR595stA(lValor)
lAutoSt := lValor
return
