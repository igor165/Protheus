
#INCLUDE "PLSR591.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

Static lAutoSt := .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR591 ³ Autor ³Geraldo Felix Junior    ³ Data ³ 28.04.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Emissao do resumo de cobranca (Intercambio Eventual)       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR591                                                    ³±±±
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
Function PLSR591(cmv_par01, cmv_par02, cmv_par03, cmv_par04, cmv_par05, cmv_par06, cmv_par07, cmv_par08)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis padroes para todos os relatorios...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nQtdLin     := 60
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := FunDesc() //"Resumo de Intercâmbio Eventual"
PRIVATE cDesc1      := STR0002 //"Este Relatorio tem como objetivo emitir resumo demonstrando a composicao de"
PRIVATE cDesc2      := STR0003  //"um lote de cobranca."
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BDC"
PRIVATE cPerg       := "PLR591"
PRIVATE cRel        := "PLSR591"
PRIVATE nli         := 80
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .F. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := STR0007  //"NUM. LOTE  DT GERACAO    HORA    REFERENCIA  FATURADAS  CRITIC.  NAO SELEC.  SEVICO MED.    SER. ACESSORIO         TAXAS          TOTAL"
PRIVATE cCabec2     := STR0008  //"OPERADORA ORIGEM                          PRFX TITULO  PARC. TIPO QTD EVE. "

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
//³ mv_par05 // Operadora inicial                                				³
//³ mv_par06 // Operadora final                                  				³
//³ mv_par07 // Tipo de relatorio  ? analitico/resumido/sintetico				³
//³ mv_par08 // Demonstra criticas ?                             				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
If !lAutoSt .AND. cMv_par01 # Nil
	mv_par01 := cMv_par01
	mv_par02 := cMv_par02
	mv_par03 := cMv_par03
	mv_par04 := cMv_par04
	mv_par05 := cMv_par05
	mv_par06 := cMv_par06	
	mv_par07 := cMv_par07
	mv_par08 := cMv_par08
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emite relat¢rio                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	MsAguarde({|| r591Imp() }, cTitulo, "", .T.)
else
	r591Imp()
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera threads                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	Ms_Flush()
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ r591Imp  ³ Autor ³Geraldo Felix Junior...³ Data ³ 28.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime detalhe do relatorio...                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function r591Imp()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cSQL  
LOCAL cBTFName 	:= BTF->(RetSQLName("BTF"))
LOCAL cBTOName 	:= BTO->(RetSQLName("BTO"))
LOCAL cBDHName 	:= BDH->(RetSQLName("BDH"))
LOCAL cBA1Name 	:= BA1->(RetSQLName("BA1"))
LOCAL cStatus	:= ''
LOCAL cLote		:= '' 
LOCAL cNumCob 	:= ''
LOCAL cSequen 	:= ''
LOCAL lFat		:= .F.
LOCAL lCri		:= .F.
LOCAL lNosel	:= .F.
LOCAL lImprimiu := .F.
LOCAL nVLRCOP	:= 0
LOCAL nVLRCP2	:= 0
LOCAL nVLRCP3	:= 0
LOCAL nVLRTAX	:= 0 
LOCAL nCUSTOT	:= 0
LOCAL nQTDEVE	:= 0
LOCAL cTipInt   := GetNewPar("MV_PLSCDIE","1")
Private _cChave := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT * FROM "+cBTFName+","+cBTOName+" WHERE "
cSQL += "BTF_FILIAL = '"+xFilial("BTF")+"' AND "
cSQL += "BTF_CODOPE >= '"+mv_par01+"' AND "
cSQL += "BTF_CODOPE <= '"+mv_par02+"' AND "
cSQL += "BTF_NUMERO >= '"+mv_par03+"' AND "
cSQL += "BTF_NUMERO <= '"+mv_par04+"' AND "

cSQL += "BTO_OPEORI >= '"+mv_par05+"' AND "
cSQL += "BTO_OPEORI <= '"+mv_par06+"' AND "

cSQL += cBTFName+".D_E_L_E_T_ = '' AND "
cSQL += cBTOName+".D_E_L_E_T_ = '' AND "
cSql += "BTF_CODOPE = BTO_CODOPE   AND "
cSql += "BTF_NUMERO = BTO_NUMERO "
cSQL += "ORDER BY " + BTF->(IndexKey()) +"+BTO_STATUS"

PLSQuery(cSQL,"TRB1")

If !lAutoSt .AND. TRB1->(Eof())
   TRB1->(DbCloseArea())
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
While ! TRB1->(Eof())
	nLi := 80
	VldPag()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Referentes ao cabecalho do lote...                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			                           
	@ nLi, 000 PSAY TRB1->BTF_NUMERO
	@ nLi, 010 PSAY dToc(TRB1->BTF_DATGER)
	@ nLi, 020 PSAY TRB1->BTF_ANOINI+"/"+TRB1->BTF_MESINI
	If TRB1->BTF_OPEGER > 0
		@ nLi, 036 PSAY StrZero(TRB1->BTF_OPEGER,4)
	Endif
	If TRB1->BTF_OPECRI > 0
		@ nLi, 045 PSAY StrZero(TRB1->BTF_OPECRI,4)
	Endif
	If TRB1->BTF_NOSELE > 0 
		@ nLi, 053 PSAY StrZero(TRB1->BTF_NOSELE,4)
	Endif
	@ nLi, 059 PSAY Transform(TRB1->BTF_VLRCOP,"@E 99,999,999.99")
	@ nLi, 074 PSAY Transform(TRB1->BTF_VLRCP2,"@E 99,999,999.99")
	If BTF->( FieldPos("BTF_VLRCP3") ) > 0
		@ nLi, 090 PSAY Transform(TRB1->BTF_VLRCP3,"@E 99,999,999.99")	
	Endif
	@ nLi, 103 PSAY Transform(TRB1->BTF_VLRTAX,"@E 99,999,999.99")	
	@ nLi, 118 PSAY Transform(TRB1->BTF_CUSTOT,"@E 99,999,999.99")
	nLi += 2
	
	cLote := TRB1->BTF_NUMERO
	While !TRB1->( Eof() ) .and. TRB1->BTO_NUMERO == cLote

		If TRB1->BTO_STATUS == '1'
			@ nLi, 000 PSAY STR0009 ; nLi++   	// FATURADAS
			@ nLi, 000 PSAY "----------"		
			lFat := .T.
		Elseif TRB1->BTO_STATUS == '2'			// CRITICADAS
			@ nLi, 000 PSAY STR0010	; nLi++
			@ nLi, 000 PSAY "------------"
			lCri := .T.
		Else
			@ nLi, 000 PSAY STR0011 ; nLi++		// NAO SELECIONADAS
			@ nLi, 000 PSAY "-----------------"		
			lNoSel := .T.
		Endif	
		nLi++
		cStatus := TRB1->BTO_STATUS                           
		
		While !TRB1->( Eof() ) .and. TRB1->BTO_NUMERO == cLote .and. TRB1->BTO_STATUS == cStatus
		
			@ nLi, 000 PSAY TRB1->BTO_OPEORI+"-"
			@ nLi, 007 PSAY Left(Posicione("BA0",1,xFilial("BA0")+TRB1->BTO_OPEORI,"BA0_NOMINT"),18)
			@ nLi, 034 PSAY TRB1->BTO_PREFIX
			@ nLi, 039 PSAY TRB1->BTO_NUMTIT
			@ nLi, 049 PSAY TRB1->BTO_PARCEL
			@ nLi, 053 PSAY TRB1->BTO_TIPTIT
			@ nLi, 056 PSAY StrZero(TRB1->BTO_QTDEVE, 5)
			
			@ nLi, 062 PSAY Transform(TRB1->BTO_VLRCOP,"@E 99,999,999.99")
			@ nLi, 077 PSAY Transform(TRB1->BTO_VLRCP2,"@E 99,999,999.99")
			If BTO->( FieldPos("BTO_VLRCP3") ) > 0
				@ nLi, 093 PSAY Transform(TRB1->BTO_VLRCP3,"@E 99,999,999.99")	
			Endif		 
			@ nLi, 106 PSAY Transform(TRB1->BTO_VLRTAX,"@E 99,999,999.99")	
			@ nLi, 121 PSAY Transform(TRB1->BTO_CUSTOT,"@E 99,999,999.99")
			nLi++           
			        
            If mv_par07 == 1 // Analitico
            	If lfat
            	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Busca a movimentacao da operadora por usuarios... somente analitico³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			        	            	
            		cSql := "SELECT * FROM "+cBDHName+","+cBA1Name+" WHERE "
            		cSql += cBDHName+".D_E_L_E_T_ = ' ' AND "
            		cSql += cBA1Name+".D_E_L_E_T_ = ' ' "
            		cSql += "AND BDH_CODEMP = BA1_CODEMP "
            		cSql += "AND BDH_MATRIC = BA1_MATRIC "
            		cSql += "AND BDH_TIPREG = BA1_TIPREG "
            		cSql += "AND BDH_NUMFAT = '"+TRB1->BTO_CODOPE+TRB1->BTO_NUMERO+"' "
            		cSql += "AND BDH_OPEORI = '"+TRB1->BTO_OPEORI+"' "
            		cSql += "AND BDH_CODINT = '"+TRB1->BTO_CODOPE+"' "
            		cSql += "AND BDH_INTERC = '1' AND BDH_TIPINT = '"+cTipInt+"' "
            		cSql += "ORDER BY BA1_NOMUSR "
            		PlsQuery(cSql, "TRB2")
            		                              
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Imprime a movimentacao...                                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			        	            		
            		TRB2->( dbGotop() )
            		While !TRB2->( Eof() )
            			@ nLi, 000 PSAY Left(TRB2->BA1_NOMUSR,31)+'-'+;
            			Transform(TRB2->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), __cPictUsr)

						If TRB2->( FieldPos("BDH_QTDEVE") ) <> 0
							@ nLi, 053 PSAY StrZero(TRB2->BDH_QTDEVE, 5)
						Else
							@ nLi, 053 PSAY StrZero(0, 5)
						Endif
						
						@ nLi, 062 PSAY Transform(TRB2->BDH_VLRCOP,"@E 99,999,999.99")
						@ nLi, 077 PSAY Transform(TRB2->BDH_VLRCP2,"@E 99,999,999.99")
						If BDH->( FieldPos("BDH_VLRCP3") ) > 0
							@ nLi, 093 PSAY Transform(TRB2->BDH_VLRCP3,"@E 99,999,999.99")	
						Endif		 						
						@ nLi, 106 PSAY Transform(TRB2->BDH_VLRTAX,"@E 99,999,999.99")	
						@ nLi, 121 PSAY Transform(TRB2->(BDH_VLRCOP+BDH_VLRCP2+BDH_VLRTAX),"@E 99,999,999.99")
            			nLi ++
            			TRB2->( dbSkip() )
            			lImprimiu := .T.
            			
            			VldPag()
            			
      				Enddo
      				If lImprimiu
      					nLi++
      				Endif
      				TRB2->( dbClosearea() )
      			Elseif lCri 
      				BTG->( dbSetorder(02) )
      				If BTG->( dbSeek(xFilial("BTG")+TRB1->(BTF_CODOPE+BTF_NUMERO+BTO_SEQUEN)) )
	      				cNumCob := TRB1->BTF_NUMERO
	      				cSequen := TRB1->BTO_SEQUEN
	      				
	      				While !BTG->( Eof() ) .and. BTG->BTG_NUMERO == cNumCob .and. BTG->BTG_SEQUEN == cSequen
	      					@ nLi, 007 PSAY BTG->BTG_CODCRI+" - "+Posicione("SX5",1,xFilial("SX5")+"BI"+BTG->BTG_CODCRI,"X5_DESCRI")

	      					BTG->( dbSkip() ) 
	      					lImprimiu := .T.
	      					nLi++
	      					
	      					VldPag()	      					
	      				
	      				Enddo
	      				If lImprimiu
	      					nLi++
	      				Endif
					Endif
      			Endif
      		Endif
      		lImprimiu := .F.
      		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sumariza as variaveis totalizadoras...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			        	
			nVLRCOP	+= TRB1->BTO_VLRCOP
			nVLRCP2	+= TRB1->BTO_VLRCP2
			If BTO->( FieldPos("BTO_VLRCP3") ) > 0
				nVLRCP3 += TRB1->BTO_VLRCP3
			Endif
			nVLRTAX	+= TRB1->BTO_VLRTAX
			nCUSTOT	+= TRB1->BTO_CUSTOT
			nQTDEVE += TRB1->BTO_QTDEVE
			
 			TRB1->(DbSkip())
 			
 			VldPag()
 			
	 	Enddo
		@ nLi, 067 PSAY Replicate('-', 65); nLi++
		@ nLi, 037 PSAY STR0012 // TOTAIS --->
		@ nLi, 053 PSAY StrZero(nQTDEVE, 5)
		
		@ nLi, 062 PSAY Transform(nVLRCOP,"@E 99,999,999.99")
		@ nLi, 077 PSAY Transform(nVLRCP2,"@E 99,999,999.99")
		If BTO->( FieldPos("BTO_VLRCP3") ) > 0
			@ nLi, 093 PSAY Transform(nVLRCP2,"@E 99,999,999.99")
		Endif
		@ nLi, 106 PSAY Transform(nVLRTAX,"@E 99,999,999.99")	
		@ nLi, 121 PSAY Transform(nCUSTOT,"@E 99,999,999.99")		
		nLi 	+= 2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reseta as variaveis...                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		lFat 	:= .F.
		lCri 	:= .F.
		lNoSel  := .F.
		
		nQTDEVE	:= 0
		nVLRCOP := 0
		nVLRCP2 := 0
		nVLRTAX := 0
		nCUSTOT := 0
		
		VldPag()
		
 	Enddo
 	@ nLi, 000 PSAY Replicate('-',132)
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
TRB1->(DbCloseArea())
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
±±³Programa   ³ R590Cabec ³ Autor ³Geraldo Felix Junior. ³ Data ³ 28.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime Cabecalho                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R590Cabec()      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime cabecalho...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoSt
	nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
	nLi ++
endif

Return                                                                       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±± 
±±³Programa   ³ VLDPAG    ³ Autor ³Geraldo Felix Junior. ³ Data ³ 28.04.04 ³±±
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

function PLSR591StA(lValor)
lAutoSt := lValor
return
