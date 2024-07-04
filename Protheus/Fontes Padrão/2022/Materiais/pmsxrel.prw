#INCLUDE "Protheus.ch"
#INCLUDE "pmsxrel.ch"
#INCLUDE "DBTREE.CH"
#include "PMSICONS.CH"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

Static aObjRel := {}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PMRSelReg³ Autor ³ Wagner Mobile Costa   ³ Data ³27.06.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Detalhe do projeto                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PMRSelReg(	lEnd,wnrel,cString,nomeprog,Titulo)

Local lImp := .F. 			// Indica se algo foi impresso
Local cIndexKey
Local cIndTrab 
Local nIndice, cRotina, aVarRel := Array(16)
Local cEvento, cProp						// Impressao
Local nRecursos, aRecursos := {}
Local lCustos
Local lNiveis
Local lCurvaAbc
Local lIndices
Local lTProjeto
Local lSubTotal
Local lMostraCusto := .F.

Local lFluxoCaixa
Local nSaldo, cPrefixo

Local lResumoT, aResumo

Local cAlias, cChave
Local nPos, nPos02

Local cProjeto, cOrcame, lCondicao := .F.
Local nProp := 0

#DEFINE 	ESTRUTURA_PROJETO   	1
#DEFINE 	ROTINA              	2
#DEFINE 	PROJETO_ANTERIOR    	3
#DEFINE 	ALIAS               	4
#DEFINE 	TAB_FILHOS          	5
#DEFINE 	IND_REGUA           	6
#DEFINE 	CONDICAO            	7
#DEFINE 	AREA_ATUAL          	8
#DEFINE 	SALTA_PAGINA        	9
#DEFINE 	REGISTROS_IMPRESSOS 	10
#DEFINE 	POSICOES_IMPRESSAO  	11
#DEFINE 	DATA_REFERENCIA     	12
#DEFINE 	PMR_PERTENCE        	13

#DEFINE 	CUSTO_TOTAL         	14

#DEFINE 	INDICES             	15

#DEFINE		R_ALIAS					1
#DEFINE		R_RECNO					2

#DEFINE		COLUNA1					1
#DEFINE		COLUNA2					2
#DEFINE		COLUNAO					3
#DEFINE		COLUNAT					4
#DEFINE		PERCENTUAL				5
#DEFINE		QUANTIDADE				6
#DEFINE 	TOTALIZACAO				7

#DEFINE 	CONTEUDO_IMPRESSAO  	15

// Fluxo de caixa

#DEFINE		DATA_FLUXO    			01
#DEFINE		TOTAL_RECEBER			02
#DEFINE		PEDIDO_VENDA  			03
#DEFINE		QUANTOS_PV  			04
#DEFINE		TOTAL_PAGAR  			05
#DEFINE		PEDIDO_COMPRA 			06
#DEFINE		QUANTOS_PC  			07
#DEFINE		TOTAL_ACUMULADO			08
#DEFINE		PERCENTO_TOTAL 			09

#DEFINE 	FLUXO_CAIXA				16

#DEFINE 	NUMERO_DIAS         	01
#DEFINE 	QUAL_MOEDA          	02
#DEFINE 	MOSTRA_PEDIDO_PC		03
#DEFINE 	MOSTRA_PEDIDO_PV		04
#DEFINE 	TOTAL_FLUXO       		05



cRotina          			:= ""
aVarRel[PROJETO_ANTERIOR] 	:= ""
aVarRel[ALIAS]            	:= "AF8"			// Default
aVarRel[TAB_FILHOS]       	:= "AF8,AFC,AF9"	// Default
aVarRel[CONDICAO]         	:= { || .T. }    	// Default
aVarRel[SALTA_PAGINA]     	:= .T.           	// Default

If PmrPropObjeto(aObjRel, "ESTRUTURA_PROJETO", "", "SOPROPRIEDADE")
	aVarRel[ESTRUTURA_PROJETO] 	:= PmrPropObjeto(aObjRel, "ESTRUTURA_PROJETO",, "VALOR")
Endif
If PmrPropObjeto(aObjRel, "ROTINADETALHE", "", "SOPROPRIEDADE")
	cRotina := PmrPropObjeto(aObjRel, "ROTINADETALHE", "", "VALOR")
Endif
If PmrPropObjeto(aObjRel, "ALIASPRINCIPAL", "", "SOPROPRIEDADE")
	aVarRel[ALIAS] := PmrPropObjeto(aObjRel, "ALIASPRINCIPAL", "", "VALOR")
Endif
If PmrPropObjeto(aObjRel, "TAB_FILHOS", "", "SOPROPRIEDADE")
	aVarRel[TAB_FILHOS] := PmrPropObjeto(aObjRel, "TAB_FILHOS", "", "VALOR")
Endif

If 	! PmrPropObjeto(aObjRel, "CONDICAO", "", "SOPROPRIEDADE") .And.;
	aVarRel[ALIAS] $ "AF1,AF8"		// Orcamento e projeto assume condicao DEFAULT
    
	lCondicao := .T.
	If aVarRel[ALIAS] = "AF1"
		PmrAddPropO("CONDICAO",, { || 	If(Alias() $ 'AF5,AF2',;
										PmrPertence(If(Alias() = 'AF5', 	AF5->AF5_NIVEL,;
																			AF2->AF2_NIVEL),;
																			mv_par05),;
								  		If(Alias() = 'AF3', SB1->(MsSeek(xFilial("SB1") +;
					  					AF3->AF3_PRODUT)) .And.;
					  					AF3->AF3_PRODUT >= mv_par07 			.And.;
					  					AF3->AF3_PRODUT <= mv_par08 			.And.;
										PmrPertence({ AF2->AF2_NIVEL, SB1->B1_TIPO },;
													{ mv_par05, mv_par09 }),;
										PmrPertence({ AF2->AF2_NIVEL, AF4->AF4_TIPOD },;
													{ mv_par05, mv_par09 })  	.And.;
					  					AF4->AF4_TIPOD >= mv_par10 			.And.;
					  					AF4->AF4_TIPOD <= mv_par11)) } )
	Else
		PmrAddPropO("CONDICAO",, { || 	If(Alias() $ 'AFC,AF9',;    
										PmrPertence(If(Alias() = 'AFC', 	AFC->AFC_NIVEL,;
																			AF9->AF9_NIVEL),;
																			mv_par06),;
								  		If(Alias() = 'AFA',;
								  		SB1->(MsSeek(xFilial("SB1") +;
								  		AFA->AFA_PRODUT)) 						.And.;
										PmrPertence({ AF9->AF9_NIVEL, SB1->B1_TIPO },;
													{ mv_par06, mv_par12} )		.And.;
			  							AFA->AFA_RECURS >= mv_par08 			.And.;
		  								AFA->AFA_RECURS <= mv_par09				.And.;
					  					AFA->AFA_PRODUT >= mv_par10 			.And.;
					  					AFA->AFA_PRODUT <= mv_par11,;
										PmrPertence({ AF9->AF9_NIVEL, AFB->AFB_TIPOD },;
													{ mv_par06, mv_par12 })	.And.;
					  					AFB->AFB_RECURS >= mv_par08 			.And.;
					  					AFB->AFB_RECURS <= mv_par09 			.And.;
					  					AFB->AFB_TIPOD >= mv_par13 			.And.;
					  					AFB->AFB_TIPOD <= mv_par14 )) } )
	Endif
Endif						  								


If PmrPropObjeto(aObjRel, "CONDICAO", "", "SOPROPRIEDADE")
	aVarRel[CONDICAO] := PmrPropObjeto(aObjRel, "CONDICAO", "", "VALOR")
Endif
If PmrPropObjeto(aObjRel, "SALTA_PAGINA", "", "SOPROPRIEDADE")
	aVarRel[SALTA_PAGINA] := PmrPropObjeto(aObjRel, "SALTA_PAGINA", "", "VALOR")
Endif
If PmrPropObjeto(aObjRel, "MOSTRA_CUSTO", "", "SOPROPRIEDADE")
	lMostraCusto := .T.
Endif

aVarRel[REGISTROS_IMPRESSOS]	:= 0

aVarRel[PMR_PERTENCE] := PmrPropObjeto(aObjRel, "PMR_PERTENCE", "", "VALOR",, { || .T. })

If 	PmrPropObjeto(aObjRel, "INDREGUA", "CONDICAO", "NPOS") = 0 .And.;
	aVarRel[ALIAS] = "AF8"		// Indregua DEFAULT
	aVarRel[IND_REGUA] := ""
	aVarRel[IND_REGUA] += "AF8_FILIAL == '" + xFilial( "AF8" ) + "' .AND. "
	aVarRel[IND_REGUA] += "AF8_PROJET >= '" + MV_PAR01 + "' .AND. "
	aVarRel[IND_REGUA] += "AF8_PROJET <= '" + MV_PAR02 + "' .AND. "
	aVarRel[IND_REGUA] += "( ( DTOS(AF8_DATA ) >= '" + DTOS(MV_PAR03) + "' .AND. "
	aVarRel[IND_REGUA] += "    DTOS(AF8_DATA ) <= '" + DTOS(MV_PAR04) + "') .OR. " 
	aVarRel[IND_REGUA] += "DTOS(AF8_DATA)==SPACE(8))"

	aVarRel[PMR_PERTENCE] := { || PmrPertence(	{ AF8_FASE },;
												{ mv_par07 }) }
												
ElseIf 	PmrPropObjeto(aObjRel, "INDREGUA", "CONDICAO", "NPOS") = 0 .And.;
		aVarRel[ALIAS] = "AF1"		// Indregua DEFAULT
	aVarRel[IND_REGUA] := ""
	aVarRel[IND_REGUA] += "AF1_FILIAL == '" + xFilial( "AF1" ) + "' .AND. "
	aVarRel[IND_REGUA] += "AF1_ORCAME >= '" + MV_PAR01 + "' .AND. "
	aVarRel[IND_REGUA] += "AF1_ORCAME <= '" + MV_PAR02 + "' .AND. "
	aVarRel[IND_REGUA] += "( ( DTOS(AF1_VALID) >= '" + DTOS(MV_PAR03) + "' .AND. "
	aVarRel[IND_REGUA] += "    DTOS(AF1_VALID) <= '" + DTOS(MV_PAR04) + "' ) .OR. " 
	aVarRel[IND_REGUA] += "DTOS(AF1_VALID) == SPACE(8) )"

	aVarRel[PMR_PERTENCE] := { || PmrPertence(AF1_FASE, mv_par06) }
Else
	aVarRel[IND_REGUA] := PmrPropObjeto(aObjRel, "INDREGUA", "CONDICAO", "VALOR",, "")
Endif

If PmrPropObjeto(aObjRel, "INDREGUA", "COMPLEMENTO", "SOPROPRIEDADE")
	aVarRel[IND_REGUA] += If( !Empty( aVarRel[IND_REGUA] )," .And. ","" ) + PmrPropObjeto(aObjRel, "INDREGUA", "COMPLEMENTO", "VALOR")
EndIf

If ! Empty(aReturn[7])
	aVarRel[IND_REGUA] += " .And. (" + aReturn[7] + ")"
Endif

If ! Empty( aVarRel[IND_REGUA] )
	cIndTrab	:= CriaTrab( , .F. )   
	(aVarRel[ALIAS])->( dbSetOrder( 1 ) ) 
	cIndexKey 	:= (aVarRel[ALIAS])->( IndexKey() )

	IndRegua( aVarRel[ALIAS], cIndTrab, cIndexKey,, aVarRel[IND_REGUA], OemToAnsi(STR0001))  //"Aguarde,criando indice de trabalho..."
	    
	nIndice := RetIndex( aVarRel[ALIAS] ) + 1 
	    
	#IFNDEF TOP
		(aVarRel[ALIAS])->( dbSetIndex( cIndTrab + OrdBagExt() ) ) 
	#ENDIF    

	dbSelectArea(aVarRel[ALIAS])
	dbSetOrder(nIndice)
	dbGotop()
Else
	dbSelectArea(aVarRel[ALIAS])
	MsSeek(xFilial())
Endif

// SubTotaliza pelos NIVEIS PROJETO/EDT/TAREFA
lNiveis 	:= PmrPropObjeto(aObjRel, "TOTAL_DOS_NIVEIS", "", "SOPROPRIEDADE")
// Demonstracao dos custos
lCustos		:= PmrPropObjeto(aObjRel, "CUSTOS", "", "SOPROPRIEDADE")
// Calculo do tipo CURVA ABC - Estilo do relatorios
lCurvaAbc	:= PmrPropObjeto(aObjRel, "RECURSOS", "CURVA_ABC", "SOPROPRIEDADE")
// Calculo de Indices para avaliacao - COTP/COTE/CRTE
lIndices 	:= PmrPropObjeto(aObjRel, "INDICES",, "SOPROPRIEDADE")

// Indica se apresenta resumo por tipo de produto
If (lResumoT := PmrPropObjeto(aObjRel, "RECURSOS", "RESUMO", "SOPROPRIEDADE"))
	aResumo := {}
Endif

// Indica se fara laco nos elementos da matriz ou passara todo o projeto
lTProjeto	:= PmrPropObjeto(aObjRel, "TODA_MATRIZ_PROJETO", "", "SOPROPRIEDADE")
// Indica se apresenta SUB-TOTAL por projeto
lSubTotal	:= PmrPropObjeto(aObjRel, "SUBTOTAL",, "SOPROPRIEDADE")
// Relatorio do tipo fluxo de caixa (PROJETO)
lFluxoCaixa	:= PmrPropObjeto(aObjRel, "FLUXO_CAIXA",, "SOPROPRIEDADE")

If lFluxoCaixa
	// Data-Base/referencia para relatorios
	aVarRel[FLUXO_CAIXA]					:= Array(5)
	aVarRel[FLUXO_CAIXA][NUMERO_DIAS]     	:= PmrPropObjeto(aObjRel, "FLUXO_CAIXA", "NUMERO_DIAS", "VALOR")
	aVarRel[FLUXO_CAIXA][QUAL_MOEDA]     	:= PmrPropObjeto(aObjRel, "FLUXO_CAIXA", "QUAL_MOEDA", "VALOR")
	aVarRel[FLUXO_CAIXA][MOSTRA_PEDIDO_PC]	:= PmrPropObjeto(aObjRel, "FLUXO_CAIXA", "MOSTRA_PEDIDO_PC", "VALOR")
	aVarRel[FLUXO_CAIXA][MOSTRA_PEDIDO_PV]	:= PmrPropObjeto(aObjRel, "FLUXO_CAIXA", "MOSTRA_PEDIDO_PV", "VALOR")
	aVarRel[FLUXO_CAIXA][TOTAL_FLUXO]		:= 0.00

	aVarRel[POSICOES_IMPRESSAO] := PmrPropObjeto(aObjRel, "PROPRIEDADESIMPRESSAO",, "VALOR")
Endif

SetRegua( LastRec() )

While ( ! ( aVarRel[ALIAS] )->( Eof() ) )

	lImp := .T.
	If lEnd
		@ Prow()+1,001 PSAY STR0002 //"CANCELADO PELO OPERADOR"
		Exit
	EndIf

// Caso carrego o projeto pois esta indicado como estrutura de Projeto
// uso o retorno PmsMontraTree, projeto a projeto                    
//
// { { { "TW-0469", "CHESF"		, RECNO, "AF8" }	, { "RTW-0469-001", "GERAL", RECNO, "AF9" },;
//     { "0010", "ASSINATURA"	, RECNO, "AF9" } } }
    

	If ! aVarRel[ALIAS] $ "AF1,AF8"
		If FieldPos(aVarRel[ALIAS] + "_PROJET") > 0
			cProjeto := &(aVarRel[ALIAS] + "_PROJET")
			AF8->(MSSeek(xFilial("AF8") + cProjeto))
		ElseIf FieldPos(aVarRel[ALIAS] + "_ORCAME") > 0
			cOrcame  := &(aVarRel[ALIAS] + "_ORCAME")
			AF1->(MSSeek(xFilial("AF1") + cOrcame))
		Endif
	Endif
	
	If FieldPos(aVarRel[ALIAS] + "_PROJET") > 0
		SA1->(MSSeek(xFilial("SA1") + AF8->AF8_CLIENTE))
	ElseIf FieldPos(aVarRel[ALIAS] + "_ORCAME") > 0
		SA1->(MSSeek(xFilial("SA1") + AF1->AF1_CLIENTE))
	Endif
	
	If ! Eval(aVarRel[PMR_PERTENCE])
		DbSkip()
		Loop
	Endif
	
	If ! lCondicao .And. ! Eval(aVarRel[CONDICAO])
		DbSkip()
		Loop
	Endif
	
	If ! Empty(aVarRel[IND_REGUA]) .And. ! Empty(aReturn[7]) .And. ! &(aReturn[7])		// Fitro sem INDREGUA
		DbSkip()
		Loop
	Endif

	
	aVarRel[AREA_ATUAL] := GetArea()	
    If aVarRel[ESTRUTURA_PROJETO] # Nil			// Monta a matriz para impressao
    	aVarRel[ESTRUTURA_PROJETO] := {}
    	
		If aVarRel[ALIAS] = "AF1"
			PmsTreeOrc(, aVarRel[ESTRUTURA_PROJETO], aVarRel[TAB_FILHOS],;
					  	aVarRel[CONDICAO])
		Else
			PMS2TreeEDT(,If(!Empty(mv_par05),mv_par05,Nil), aVarRel[ESTRUTURA_PROJETO], aVarRel[TAB_FILHOS],;
						   aVarRel[CONDICAO])
		Endif

		If lCustos	// Projeto
		
			If lCurvaAbc
				PmrAddPropO("RECURSOS", "PERCENTO_ACUMULADO", 0)
			Endif
			
			aVarRel[CUSTO_TOTAL] := 0
						
			If PmrPropObjeto(aObjRel, "SUBTOTAL",, "SOPROPRIEDADE")
				PmrAddPropO("CUSTOS", "COLUNA_1", 0)
				PmrAddPropO("CUSTOS", "COLUNA_2", 0)
				PmrAddPropO("CUSTOS", "COLUNA_O", 0)
				PmrAddPropO("CUSTOS", "CUSTO_TOTAL", 0)
			Endif

		    If lResumoT
				aResumo := {}
			Endif
			
	  		For nIndice := 1 To Len(aVarRel[ESTRUTURA_PROJETO][1])
				If Len(aVarRel[ESTRUTURA_PROJETO][1][nIndice]) = TOTALIZACAO - 1
  					Aadd(aVarRel[ESTRUTURA_PROJETO][1][nIndice], { 0, 0, 0, 0, 0, 0 })
  				ElseIf aVarRel[ESTRUTURA_PROJETO][1][nIndice][TOTALIZACAO] = Nil	// Tarefa do RECURSO
  					aVarRel[ESTRUTURA_PROJETO][1][nIndice][TOTALIZACAO] := { 0, 0, 0, 0, 0, 0 }
 	  			Endif

   				If ! aVarRel[ESTRUTURA_PROJETO][1][nIndice][4] $ "AE8,AF3,AF4,AFA,AFB"	// Nao for recurso
    				Loop
   				Endif
                          
                aRecursos := {}
                
                If Len(aVarRel[ESTRUTURA_PROJETO][1][nIndice]) = TOTALIZACAO
 					aRecursos := { { 	aVarRel[ESTRUTURA_PROJETO][1][nIndice][4],;
										aVarRel[ESTRUTURA_PROJETO][1][nIndice][3] } }
                Else
                	aRecursos := aVarRel[ESTRUTURA_PROJETO][1][nIndice][TOTALIZACAO + 1]
                Endif

				For nRecursos := 1 To Len(aRecursos)
					DbSelectArea(aRecursos[nRecursos][R_ALIAS])
					MsGoto(aRecursos[nRecursos][R_RECNO])
					If Alias() = "AFA"
						SB1->(MsSeek(xFilial("SB1") + AFA->AFA_PRODUT))
					ElseIf Alias() = "AF3"
						SB1->(MsSeek(xFilial("SB1") + AF3->AF3_PRODUT))
					Endif						
            	
					PmrSomaNivel(If(Alias() = "AFA",;
								{ AFA_CUSTD * AFA_QUANT, AFA_QUANT, SB1->B1_TIPO },;
								If(Alias() = "AF3",;
								{ AF3_CUSTD * AF3_QUANT, AF3_QUANT, SB1->B1_TIPO },;
								If(Alias() = "AFB",;
								{ AFB_VALOR, 1, AFB_TIPOD },;
								{ AF4_VALOR, 1, AF4_TIPOD } ))), aVarRel, nIndice,;
								aRecursos[nRecursos], lNiveis, aResumo)
			  	Next
			Next 
			
			If lResumoT
				PmrAddPropO("RECURSOS", "RESUMO", aResumo)
			Endif
		  	
 	  		For nIndice := 1 To Len(aVarRel[ESTRUTURA_PROJETO][1])
 	  			If Len(	aVarRel[ESTRUTURA_PROJETO][1][nIndice]) > 5
						aVarRel[ESTRUTURA_PROJETO][1][nIndice][TOTALIZACAO][PERCENTUAL] :=;
					(aVarRel[ESTRUTURA_PROJETO][1][nIndice][TOTALIZACAO][COLUNAT] /;
  					 aVarRel[CUSTO_TOTAL]) * 100
  				Endif
	  		Next
			PmrAddPropO("CUSTOS", "CUSTO_TOTAL", aVarRel[CUSTO_TOTAL])
		Endif
		
		If lIndices
			aVarRel[INDICES] := { 	PmsIniCOTP(AF8->AF8_PROJET,If(!Empty(mv_par05),mv_par05,AF8->AF8_REVISA),mv_par08,,,,, .F.),;
									PmsIniCOTE(AF8->AF8_PROJET,If(!Empty(mv_par05),mv_par05,AF8->AF8_REVISA),mv_par08,,,,, .F.),;
									PmsIniCRTE(AF8->AF8_PROJET,AF8->AF8_REVISA,mv_par08,,,,, .F.) }
									
//			aHandle := PmsIniCOTP(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_FINISH)				
//			nCPT	:= PmsRetCOTP(aHandle,2,AFC->AFC_EDT)[mv_par09]
//			aHandle := PmsIniCOTP(AFC->AFC_PROJET,AFC->AFC_REVISA,mv_par08)
//			nCOTP	:= PmsRetCOTP(aHandle,2,AFC->AFC_EDT)[mv_par09]
//			aHandle := PmsIniCOTE(AFC->AFC_PROJET,AFC->AFC_REVISA,mv_par08)
//			nCOTE	:= PmsRetCOTE(aHandle,2,AFC->AFC_EDT)[mv_par09]
//			aHandle := PmsIniCRTE(AFC->AFC_PROJET,AFC->AFC_REVISA,mv_par08)
//			nCRTE	:= PmsRetCRTE(aHandle,2,AFC->AFC_EDT)[mv_par09]
//			nVC		:= (nCOTE - nCRTE)/nCOTE*-100
//			nIDC	:= nCOTE/nCRTE*100
//			nECT	:= nCPT/nIDC*100
//			nIDP	:= nCOTE/nCOTP*100
//			dET		:= INT((AF9->AF9_FINISH-AF9->AF9_START)/nIDP*100)+AF9->AF9_START
//			nVP		:= (nCOTE-nCOTP)/nCOTE*-100

 	  		For nIndice := 1 To Len(aVarRel[ESTRUTURA_PROJETO][1])
  				cAlias  := aVarRel[ESTRUTURA_PROJETO][1][nIndice][4]
 	  			Aadd(aVarRel[ESTRUTURA_PROJETO][1][nIndice],;
 	  				{ 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, PMS_EMPTY_DATE, 0.00, 0.00, 0.00 })
 	  			nPos 	:= 0
 	  			nPos02	:= Len(aVarRel[ESTRUTURA_PROJETO][1][nIndice])
				If cAlias = "AF9"
 	  				nPos 	:= 1
	 				DbSelectArea(cAlias)
	 				MsGoto(aVarRel[ESTRUTURA_PROJETO][1][nIndice][3])
	 				cChave := AF9_TAREFA
	  			ElseIf cAlias = "AFC"
 	  				nPos 	:= 2
	 				DbSelectArea(cAlias)
	 				MsGoto(aVarRel[ESTRUTURA_PROJETO][1][nIndice][3])
	 				cChave := AFC_EDT
 	  			Endif

 	  			If nPos > 0
 	  				If cAlias = "AF9"
		 	  			aCotp	:= PmsIniCOTP(AF9_PROJET, If(!Empty(mv_par05),mv_par05,AF9->AF9_REVISA), AF9_FINISH, AF9_TAREFA, AF9_TAREFA)
		 	  		Else
		 	  			aCotp	:= PmsIniCOTP(AFC_PROJET, If(!Empty(mv_par05),mv_par05,AFC->AFC_REVISA), AFC_FINISH)
		 	  		Endif
					nCPT 	:= PmsRetCOTP(aCotp,nPos,cChave)[1]
					nCOTP 	:= PmsRetCOTP(aVarRel[INDICES][1],nPos,cChave)[1]
					nCOTE	:= PmsRetCOTE(aVarRel[INDICES][2],nPos,cChave)[1]
					nCRTE	:= PmsRetCRTE(aVarRel[INDICES][3],nPos,cChave)[1]
					nVC		:= (nCOTE - nCRTE)/nCOTE*-100
					nIDC	:= nCOTE/nCRTE*100
					nECT	:= nCPT/nIDC*100
					nIDP	:= nCOTE/nCOTP*100
					dET		:= INT((&(cAlias + "_FINISH") - &(cAlias + "_START"))/;
												   nIDP*100)+&(cAlias + "_START")
					nVP		:= (nCOTE-nCOTP)/nCOTE*-100
					aVarRel[ESTRUTURA_PROJETO][1][nIndice][nPos02] :=;
					{ nCPT, nCotp, nCote, nCrte, nVC, nVP, dEt, nECT, nIDC, nIDP }
 	  			Endif
			Next
		Endif

		If lCurvaAbc
			aVarRel[ESTRUTURA_PROJETO]:= ASort(aVarRel[ESTRUTURA_PROJETO],,,;
												{ | x, y | X[COLUNAT] < Y[COLUNAT] })
		Endif														 	
		
    	If Len(aVarRel[ESTRUTURA_PROJETO][1]) > 0
			If lTProjeto	// Projeto
				If !lMostraCusto
					&cRotina.(NomeProg, @nLi, aVarRel[ESTRUTURA_PROJETO][1])
				Else
					&cRotina.(NomeProg, @nLi, PmsAddCusto( aVarRel[ESTRUTURA_PROJETO][1] ) )
				EndIf
	  		Else
			  	For nIndice := 1 To Len(aVarRel[ESTRUTURA_PROJETO][1])
  					&cRotina.(NomeProg, @nLi, aVarRel[ESTRUTURA_PROJETO][1][nIndice],;
	  						   If(nIndice = 1, "PRIMEIRA",;
		  					   If(nIndice = Len(aVarRel[ESTRUTURA_PROJETO][1]), "ULTIMA", "")),;
		  					   aVarRel[ESTRUTURA_PROJETO][1][nIndice - If(nIndice = 1, 0, 1)][4])
			  	Next
 			Endif
 		Endif
	ElseIf ! Empty(cRotina)
		&cRotina.(NomeProg, @nLi)
	ElseIf lFluxoCaixa
		aVarRel[DATA_REFERENCIA] := PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)

		aVarRel[CONTEUDO_IMPRESSAO] := {}        
		For nIndice := 1 To aVarRel[FLUXO_CAIXA][NUMERO_DIAS]
  			If Len(aVarRel[CONTEUDO_IMPRESSAO]) < nIndice 
	  			Aadd(aVarRel[CONTEUDO_IMPRESSAO],;
	  			   { aVarRel[DATA_REFERENCIA] + nIndice - 1, 0.00, 0.00, 0, 0.00, 0.00, 0, 0.00, 0.00 })
  			Endif

// Receitas apontadas
  		
			AFT->(DbSetOrder(3))	// AFT_VENREA + AFT_PROJET + AFT_REVISA
			AFT->(MsSeek(	xFilial("AFT") +;
							Dtos(aVarRel[CONTEUDO_IMPRESSAO][nIndice][DATA_FLUXO])+;
							(aVarRel[ALIAS])->AF8_PROJET +;
							(aVarRel[ALIAS])->AF8_REVISA))
			While 	AFT->AFT_FILIAL = xFilial("AFT") 						.And.;
					AFT->AFT_VENREA =;
						 aVarRel[CONTEUDO_IMPRESSAO][nIndice][DATA_FLUXO] 	.And.;
					AFT->AFT_PROJET = (aVarRel[ALIAS])->AF8_PROJET		.And.;
					AFT->AFT_REVISA = (aVarRel[ALIAS])->AF8_REVISA		.And.;
					! AFT->(Eof())
				If 	SE1->(MsSeek(xFilial("SE1") + 	AFT->AFT_PREFIX + AFT->AFT_NUM +;
													AFT->AFT_PARCEL + AFT->AFT_TIPO +;
													AFT->AFT_CLIENTE +;
													AFT->AFT_LOJA)) .And. SE1->E1_SALDO > 0 
					nSaldo := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),;
									   SE1->E1_MOEDA,aVarRel[QUAL_MOEDA],;
									   DataValida(SE1->E1_VENCTO,.T.))
					aVarRel[CONTEUDO_IMPRESSAO][nIndice][TOTAL_RECEBER] 	+= nSaldo
					aVarRel[CONTEUDO_IMPRESSAO][nIndice][TOTAL_ACUMULADO] 	+= nSaldo
					aVarRel[FLUXO_CAIXA][TOTAL_FLUXO]						+= nSaldo
				Endif
				AFT->(DbSkip())
			EndDo
			
// Despesas

			AFR->(DbSetOrder(3))	// AFR_VENREA + AFR_PROJET + AFR_REVISA
			AFR->(MsSeek(	xFilial("AFR") +;
							Dtos(aVarRel[CONTEUDO_IMPRESSAO][nIndice][DATA_FLUXO])+;
							(aVarRel[ALIAS])->AF8_PROJET +;
							(aVarRel[ALIAS])->AF8_REVISA))
			While 	AFR->AFR_FILIAL = xFilial("AFR") 						.And.;
					AFR->AFR_VENREA =;
						aVarRel[CONTEUDO_IMPRESSAO][nIndice][DATA_FLUXO] 	.And.;
					AFR->AFR_PROJET = (aVarRel[ALIAS])->AF8_PROJET		.And.;
					AFR->AFR_REVISA = (aVarRel[ALIAS])->AF8_REVISA		.And.;
					! AFR->(Eof())
				If 	SE2->(MsSeek(	xFilial("SE2") + 	AFR->AFR_PREFIX + AFR->AFR_NUM +;
				   										AFR->AFR_PARCEL + AFR->AFR_TIPO +;
														AFR->AFR_FORNECE + AFR->AFR_LOJA)) .And.;
					SE2->E2_SALDO > 0
					nSaldo := xMoeda((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE),;
									   SE2->E2_MOEDA,aVarRel[QUAL_MOEDA],SE2->E2_VENCREA)
					aVarRel[CONTEUDO_IMPRESSAO][nIndice][TOTAL_PAGAR] 		+= nSaldo
					aVarRel[CONTEUDO_IMPRESSAO][nIndice][TOTAL_ACUMULADO] 	-= nSaldo
					aVarRel[FLUXO_CAIXA][TOTAL_FLUXO]						-= nSaldo
				Endif
				AFR->(DbSkip())
			EndDo

			If nIndice > 1
				aVarRel[CONTEUDO_IMPRESSAO][nIndice][TOTAL_ACUMULADO] 	+=;
				aVarRel[CONTEUDO_IMPRESSAO][nIndice - 1][TOTAL_ACUMULADO]
			Endif
		Next
		
// Receitas via notas de saida

		AFS->(DbSetOrder(1))	// AFS_PROJET + AFS_REVISA
		AFS->(MsSeek(	xFilial("AFS") + (aVarRel[ALIAS])->AF8_PROJET +;
						(aVarRel[ALIAS])->AF8_REVISA))
		While 	AFS->AFS_FILIAL = xFilial("AFS") 						.And.;
				AFS->AFS_PROJET = (aVarRel[ALIAS])->AF8_PROJET		.And.;
				AFS->AFS_REVISA = (aVarRel[ALIAS])->AF8_REVISA		.And.;
				! AFS->(Eof())
			If 	SF2->(MsSeek(xFilial() + AFS->AFS_DOC + AFS->AFS_SERIE)) .And.;
				! Empty(SF2->F2_DUPL)
			 	cPrefixo := If( Empty(SF2->F2_PREFIXO), &(SuperGetMV("MV_1DUPREF")), SF2->F2_PREFIXO )
			 	cPrefixo := PadR(cPrefixo, Len(SE1->E1_PREFIXO))
				SE1->(MsSeek(xFilial() + cPrefixo + SF2->F2_DUPL))
				While 	SE1->E1_FILIAL = xFilial("SE1") 	.And.;
						SE1->E1_NUM = SF2->F2_DUPL			.And.;
						SE1->E1_PREFIXO = cPrefixo 	.And. ! SE1->(Eof())

					If (nPos := Ascan(aVarRel[CONTEUDO_IMPRESSAO],;
 						 			   { |X| X[DATA_FLUXO] = SE1->E1_VENCREA } )) > 0
						nSaldo := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),;
										   SE1->E1_MOEDA,aVarRel[QUAL_MOEDA],SE1->E1_VENCREA)
						aVarRel[CONTEUDO_IMPRESSAO][nPos][TOTAL_RECEBER] 	+= nSaldo
						aVarRel[FLUXO_CAIXA][TOTAL_FLUXO]					+= nSaldo
						For nPos02 := nPos To Len(aVarRel[CONTEUDO_IMPRESSAO])
							aVarRel[CONTEUDO_IMPRESSAO][nPos02][TOTAL_ACUMULADO] += nSaldo
						Next
					Endif
				
					SE1->(DbSkip())
				EndDo	
			Endif
			AFS->(DbSkip())
		EndDo

// Despesas via notas de entrada

		AFN->(DbSetOrder(1))	// AFS_PROJET + AFS_REVISA
		AFN->(MsSeek(	xFilial("AFN") + (aVarRel[ALIAS])->AF8_PROJET +;
						(aVarRel[ALIAS])->AF8_REVISA))
		While 	AFN->AFN_FILIAL = xFilial("AFN") 						.And.;
				AFN->AFN_PROJET = (aVarRel[ALIAS])->AF8_PROJET		.And.;
				AFN->AFN_REVISA = (aVarRel[ALIAS])->AF8_REVISA		.And.;
				! AFN->(Eof())
			If 	SF1->(MsSeek(xFilial() + AFN->AFN_DOC + AFN->AFN_SERIE)) .And.	! Empty(SF1->F1_DUPL)
			 	cPrefixo := If( Empty(SF1->F1_PREFIXO), &(SuperGetMV("MV_2DUPREF")), SF1->F1_PREFIXO )
			 	cPrefixo := PadR(cPrefixo, Len(SE2->E2_PREFIXO))
		 		SE2->(MsSeek(xFilial() + cPrefixo + SF1->F1_DUPL))	
				While 	SE2->E2_FILIAL = xFilial("SE1") 	.And.;
						SE2->E2_NUM    = SF1->F1_DUPL 		.And.;
						! SE2->(Eof())

					If 	SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO = SF1->F1_FORNECE + SF1->F1_LOJA + cPrefixo
						If (nPos := Ascan(aVarRel[CONTEUDO_IMPRESSAO],;
 											{ |X| X[DATA_FLUXO] = SE2->E2_VENCREA } )) > 0
							nSaldo := xMoeda((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE),;
												SE2->E2_MOEDA,aVarRel[QUAL_MOEDA],SE2->E2_VENCREA)
							aVarRel[CONTEUDO_IMPRESSAO][nPos][TOTAL_PAGAR]	+=	nSaldo
							aVarRel[FLUXO_CAIXA][TOTAL_FLUXO]					-=	nSaldo
							For nPos02 := nPos To Len(aVarRel[CONTEUDO_IMPRESSAO])
								aVarRel[CONTEUDO_IMPRESSAO][nPos02][TOTAL_ACUMULADO] -= nSaldo
							Next
						Endif
					Endif

					SE2->(DbSkip())
				EndDo
			Endif
			AFN->(DbSkip())
		EndDo

		If aVarRel[FLUXO_CAIXA][MOSTRA_PEDIDO_PC] = 1
			aCompras 	:= {}		// Variaveis para funcao PmrFlxPc
			aDCompras   := {}
			
			SC1->(DbSetOrder(1))	// C1_NUM + C1_ITEM
			DbSelectArea("AFG")		// Solicitacao de compras	[SC1]
			DbSetOrder(1)
			MsSeek(xFilial("AFG") + 	(aVarRel[ALIAS])->AF8_PROJET +;
										(aVarRel[ALIAS])->AF8_REVISA)
									
	        While 	AFG->AFG_FILIAL + 	AFG->AFG_PROJET + AFG->AFG_REVISA =;
					xFilial("AF8") 	+ 	(aVarRel[ALIAS])->AF8_PROJET +;
					(aVarRel[ALIAS])->AF8_REVISA .And. ! AFG->(Eof())
                                        // Localizo o SC1 para encontrar o pedido [SC7]
				DbSelectArea("SC1")		// Solicitacao de compras	[SC1]
				If 	MsSeek(xFilial("SC1") + AFG->AFG_NUMSC + AFG->AFG_ITEMSC) .And.;
					(! Empty(SC1->C1_PEDIDO) .And. ! Empty(SC1->C1_ITEMPED))	.And.;
					SC7->(MsSeek(xFilial("SC7") + SC1->C1_PEDIDO + SC1->C1_ITEMPED))
					PmrFlxPc(aDCompras, aCompras, aVarRel[DATA_REFERENCIA])
				Endif
			
				AFG->(DbSkip())						
			Enddo

			For nIndice	:= 1 To Len(aDCompras)
				If (nPos := Ascan(aVarRel[CONTEUDO_IMPRESSAO],;
 					 			   { |X| X[DATA_FLUXO] = aDCompras[nIndice] } )) > 0
					aVarRel[CONTEUDO_IMPRESSAO][nPos][PEDIDO_COMPRA] 	+=;
					aCompras[nIndice][2]
					aVarRel[CONTEUDO_IMPRESSAO][nPos][QUANTOS_PC] 		+=;
					aCompras[nIndice][3]
				Endif
			Next
		Endif

		If aVarRel[FLUXO_CAIXA][MOSTRA_PEDIDO_PV] = 1
			aVendas  	:= {}		// Variaveis para funcao PmrFlxPv
			aDVendas    := {}
            
			SC5->(DbSetOrder(1))
			
			DbSelectArea("SC6")
			DbSetOrder(8)	// C6_PROJPMS + C6_TASKPMS
			MsSeek(xFilial("SC6") + (aVarRel[ALIAS])->AF8_PROJET)
									
	        While 	SC6->C6_FILIAL + 	SC6->C6_PROJPMS =;
					xFilial("AF8") 	+ 	(aVarRel[ALIAS])->AF8_PROJET .And.;
					! SC6->(Eof())
				SC5->(MsSeek(xFilial("SC5") + SC6->C6_NUM))
				PmrFlxPv(aDVendas, aVendas, aVarRel[DATA_REFERENCIA],;
						 aVarRel[FLUXO_CAIXA][QUAL_MOEDA])	// eh maior que a data pedida
				DbSkip()
			EndDo
			
			For nIndice	:= 1 To Len(aDVendas)
				If (nPos := Ascan(aVarRel[CONTEUDO_IMPRESSAO],;
 					 			   { |X| X[DATA_FLUXO] = aDVendas[nIndice] } )) > 0
					aVarRel[CONTEUDO_IMPRESSAO][nPos][PEDIDO_VENDA] 	+=;
					aVendas[nIndice][2]
					aVarRel[CONTEUDO_IMPRESSAO][nPos][QUANTOS_PV] 		+=;
					aVendas[nIndice][3]
				Endif
			Next
		Endif

// Calculo o percentual de cada dia em relacao ao total
		
		For nIndice := 1 To Len(aVarRel[CONTEUDO_IMPRESSAO])
			aVarRel[CONTEUDO_IMPRESSAO][nIndice][PERCENTO_TOTAL] :=;
			(aVarRel[CONTEUDO_IMPRESSAO][nIndice][TOTAL_ACUMULADO] /;
			 aVarRel[FLUXO_CAIXA][TOTAL_FLUXO]) * 100
		Next
	ElseIf Empty(cRotina)
		aVarRel[POSICOES_IMPRESSAO] := PmrPropObjeto(aObjRel, "PROPRIEDADESIMPRESSAO",, "VALOR")
		aVarRel[CONTEUDO_IMPRESSAO] := {}
	Endif

	If aVarRel[POSICOES_IMPRESSAO] # Nil
		For nIndice := 1 To Max(1, Len(aVarRel[CONTEUDO_IMPRESSAO]))
			If ( nli > 60 )
				nli := cabec(Titulo,Cabec1,Cabec2,nomeprog,Tamanho,CHRCOMP)
				nli++
				If aVarRel[ALIAS] = "AF8"
					@ nLi ++,000 PSAY	AllTrim((aVarRel[ALIAS])->AF8_PROJET) + " - " +;
										AllTrim((aVarRel[ALIAS])->AF8_DESCRI)
				    @ nLi ++,000 PSAY Replicate("-", Limite)
				 Endif
			Endif

			If Len(aVarRel[CONTEUDO_IMPRESSAO]) > 0
	            For nProp := 1 To Len(aVarRel[POSICOES_IMPRESSAO])
    	        	cProp 	:= aVarRel[POSICOES_IMPRESSAO][nProp][1]
					cEvento	:= Subs(cProp, At(":", cProp) + 1)
					cProp 	:= Left(cProp, At(":", cProp) - 1)
                	
					PmrPropObjeto(aObjRel, cProp, cEvento, "INICIALIZA", aVarRel[CONTEUDO_IMPRESSAO][nIndice][nProp])
				Next
            Endif
            
			PMREnviaI(, @nLi, aVarRel[POSICOES_IMPRESSAO])
		Next
	    @ nLi ++,000 PSAY Replicate("-", Limite)
	Endif

	RestArea(aVarRel[AREA_ATUAL])

	If lSubTotal
		PmrEnviaI(, @nLi, PmrPropObjeto(aObjRel, "SUBTOTAL",, "VALOR"))
	    @ (++ nLi ++) ,000 PSAY Replicate("-", Limite)
	Endif

	If aVarRel[SALTA_PAGINA]
		nLi := 70
	Endif		
	    
	If FieldPos(aVarRel[ALIAS] + "_PROJET") > 0
		aVarRel[PROJETO_ANTERIOR] := &(aVarRel[ALIAS] + "_PROJET")
	Endif		
	If FieldPos(aVarRel[ALIAS] + "_ORCAME") > 0
		aVarRel[PROJETO_ANTERIOR] := &(aVarRel[ALIAS] + "_ORCAME")
	Endif		
	
	DbSkip()

	aVarRel[REGISTROS_IMPRESSOS] ++

	IncRegua()

EndDo

If ( lImp ) .And. PmrPropObjeto(aObjRel, "IMPRIME_RODAPE", "", "SOPROPRIEDADE")
	Roda(aVarRel[REGISTROS_IMPRESSOS],;
		 PmrPropObjeto(aObjRel, "IMPRIME_RODAPE", "", "VALOR"),Tamanho)
EndIf

dbSelectArea(aVarRel[ALIAS])
Set Device To Screen
Set Printer To
If ( aReturn[5] == 1 )
 	dbCommitAll()
	OurSpool(wnrel)
Endif  

If ! Empty(cIndTrab)
	#IFNDEF TOP
		(aVarRel[ALIAS])->( dbClearIndex() ) 
		FErase( cIndTrab + OrdBagExt() ) 	
	#ENDIF
	RetIndex( aVarRel[ALIAS] )
Endif

MS_FLUSH()

aObjRel := {}

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PMRCalcObjI ³ Autor ³ Wagner Mobile Costa ³ Data ³25.06.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alimenta as informacoes no objeto de relatorio e envia a im-³±±
±±³          ³ pressao                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PMRCalcObjI(cPar1,aPar1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPar1 = Nome do programa chamador                            ³±±
±±³          ³nPar1 = Linha atual para impressao                           ³±±
±±³          ³aPar1 = Matriz com a linha atual com informacoes para busca  ³±±
±±³          ³ { { { CODIGO DA EDT/TAREFA, DESCRICAO, RECNO, TABELA } }    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PMRCalcObjI(NomeProg, nLi, aEstrutura)

#DEFINE 	PROPRIEDADES_IMPRESSAO	1
#DEFINE 	PROPRIEDADES_CALCULO  	2
#DEFINE 	COLUNAS_IMPRESSAO       3
#DEFINE 	INICIO_PREVISTO         4
#DEFINE 	FIM_PREVISTO            5
#DEFINE 	INICIO_REALIZADO        6
#DEFINE 	FIM_REALIZADO           7
#DEFINE 	CHAVE_BUSCA             8
#DEFINE 	CHAVE_COMPARA           9

#DEFINE 	DATA_REFERENCIA         10
#DEFINE 	DURACAO                 11
#DEFINE 	PROGRESSO               12

#DEFINE 	A_INICIO_PREVISTO		10
#DEFINE 	A_INICIO_REALIZADO		11

#DEFINE 	FOI_REALIZADO           10
#DEFINE 	TEM_AFF                 11
#DEFINE 	A_FINAL_PREVISTO        12
#DEFINE 	A_FINAL_REALIZADO       13

#DEFINE 	PROPRIEDADES_RECURSO   	10
#DEFINE 	RECURSOS_POR_COLUNA    	11
#DEFINE 	PERCENTO_ACUMULADO     	12

#DEFINE 	INDICES					10

#DEFINE 	APONTAMENTOS			10

#DEFINE 	SOLICITACAO_COMPRAS		01
#DEFINE 	SOLICITACAO_ARMAZEM		02
#DEFINE 	CONTRATO_PARCERIA  		03
#DEFINE 	REQUISICAO  			04
#DEFINE 	NOTA_ENTRADA			05
#DEFINE 	ORDEM_PRODUCAO			06
#DEFINE 	NOTA_SAIDA   			07
#DEFINE 	DESPESAS_GASTAS   		08

Local aVarRel := Array(13)
Local lCurvaAbc := PmrPropObjeto(aObjRel, "RECURSOS", "CURVA_ABC", "SOPROPRIEDADE")
Local lCustosR	:= .F., nPos

aVarRel[PROPRIEDADES_IMPRESSAO] := AClone(PmrPropObjeto(aObjRel,;
	   "PROPRIEDADESIMPRESSAO",, "VALOR"))
aVarRel[PROPRIEDADES_CALCULO] 	:= 	AClone(aVarRel[PROPRIEDADES_IMPRESSAO])

// Implemento nas propriedades de calculo informacoes que sao amarradas

If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], 	"CRONOGRAMAFISICO", "",;
													"SOPROPRIEDADE")
	If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], 	"CRONOGRAMAFISICO",;
										"REALIZADO", 	"SOPROPRIEDADE")
		aVarRel[PROPRIEDADES_CALCULO] := 	{ 	{ "CRONOGRAMAFISICO"		},;
												{ "PREVISTO:DATAINICIO"		},;
				    							{ "PREVISTO:DATAFIM"		},;
												{ "REALIZADO:DATAINICIO"	},;
				    							{ "REALIZADO:DATAFIM"		} }
	Else
		aVarRel[PROPRIEDADES_CALCULO] := 	{ 	{ "CRONOGRAMAFISICO"	},;
												{ "PREVISTO:DATAINICIO"	},;
				    							{ "PREVISTO:DATAFIM"	} }
	Endif	
Endif

aVarRel[COLUNAS_IMPRESSAO] := Array(0)

// Inicializa os valores

If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "PREVISTO", "", "SOPROPRIEDADE")
	PmrPropObjeto(aObjRel, "PREVISTO"	, "QUANTIDADE"	, "INICIALIZA", 0)
	PmrPropObjeto(aObjRel, "PREVISTO" 	, "PROGRESSO"	, "INICIALIZA", 0)
	PmrPropObjeto(aObjRel, "PREVISTO" 	, "DURACAO"		, "INICIALIZA", 0)
	PmrPropObjeto(aObjRel, "PREVISTO"	, "DATAINICIO"	, "INICIALIZA", PMS_EMPTY_DATE)
	PmrPropObjeto(aObjRel, "PREVISTO"	, "DATAFIM"		, "INICIALIZA", PMS_EMPTY_DATE)
Endif	

If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "REALIZADO",, "SOPROPRIEDADE")
	PmrPropObjeto(aObjRel, "REALIZADO", "QUANTIDADE"	, "INICIALIZA", 0)
	PmrPropObjeto(aObjRel, "REALIZADO", "PROGRESSO"		, "INICIALIZA", 0)
	PmrPropObjeto(aObjRel, "REALIZADO", "DURACAO"  		, "INICIALIZA", 0)
	PmrPropObjeto(aObjRel, "REALIZADO", "DATAINICIO"	, "INICIALIZA", PMS_EMPTY_DATE)
	PmrPropObjeto(aObjRel, "REALIZADO", "DATAFIM"		, "INICIALIZA", PMS_EMPTY_DATE)
Endif	

If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "RECURSOS",, "SOPROPRIEDADE")
	PmrPropObjeto(aObjRel, "RECURSOS", "QUANTIDADE"		, "INICIALIZA", 0)
	PmrPropObjeto(aObjRel, "RECURSOS", "CUSTO_TOTAL"	, "INICIALIZA", 0)

	If (lCustosR := PmrPropObjeto(aObjRel, "CUSTOS",, "SOPROPRIEDADE"))
		PmrPropObjeto(aObjRel, "RECURSOS", "UNITARIO_C1"	, "INICIALIZA", 0)
		PmrPropObjeto(aObjRel, "RECURSOS", "UNITARIO_C2"	, "INICIALIZA", 0)
		PmrPropObjeto(aObjRel, "RECURSOS", "UNITARIO_CO"	, "INICIALIZA", 0)
		PmrPropObjeto(aObjRel, "RECURSOS", "CUSTO_UNITARIO"	, "INICIALIZA", 0)
		PmrPropObjeto(aObjRel, "RECURSOS", "CUSTO_C1"		, "INICIALIZA", 0)
		PmrPropObjeto(aObjRel, "RECURSOS", "CUSTO_C2"		, "INICIALIZA", 0)
		PmrPropObjeto(aObjRel, "RECURSOS", "CUSTO_CO"		, "INICIALIZA", 0)
	 	PmrPropObjeto(aObjRel, "RECURSOS", "PERCTOTAL"		, "INICIALIZA", 0)
	Endif
Endif

If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "INDICES",, "SOPROPRIEDADE")
	PmrPropObjeto(aObjRel, "INDICES", "CUSTO_PREVISTOTERMINO"	, "INICIALIZA", aEstrutura[Len(aEstrutura)][1])
	PmrPropObjeto(aObjRel, "INDICES", "COTP"                	, "INICIALIZA", aEstrutura[Len(aEstrutura)][2])
	PmrPropObjeto(aObjRel, "INDICES", "COTE"                	, "INICIALIZA", aEstrutura[Len(aEstrutura)][3])
	PmrPropObjeto(aObjRel, "INDICES", "CRTE"                	, "INICIALIZA", aEstrutura[Len(aEstrutura)][4])
	PmrPropObjeto(aObjRel, "INDICES", "VC"                  	, "INICIALIZA", aEstrutura[Len(aEstrutura)][5])
	PmrPropObjeto(aObjRel, "INDICES", "VP"                  	, "INICIALIZA", aEstrutura[Len(aEstrutura)][6])
	PmrPropObjeto(aObjRel, "INDICES", "ESTIMATIVA_TERMINO"   	, "INICIALIZA", aEstrutura[Len(aEstrutura)][7])
	PmrPropObjeto(aObjRel, "INDICES", "ECT"                 	, "INICIALIZA", aEstrutura[Len(aEstrutura)][8])
	PmrPropObjeto(aObjRel, "INDICES", "IDC"                 	, "INICIALIZA", aEstrutura[Len(aEstrutura)][9])
	PmrPropObjeto(aObjRel, "INDICES", "IDP"                 	, "INICIALIZA", aEstrutura[Len(aEstrutura)][10])
Endif

// Efetua os calculos
                	
If aEstrutura[4] = "AF8"		// Projeto
    aVarRel[INICIO_PREVISTO] 	:= AF8->AF8_START                                                    
    aVarRel[FIM_PREVISTO] 		:= AF8->AF8_FINISH
	aVarRel[INICIO_REALIZADO]	:= AF8->AF8_DTATUI
	aVarRel[FIM_REALIZADO]		:= AF8->AF8_DTATUF
	aVarRel[CHAVE_BUSCA]  		:= "AF8->AF8_PROJET+AF8->AF8_REVISA+Space(Len(AFQ->AFQ_EDT))"
	aVarRel[CHAVE_COMPARA] 		:= "AFQ->AFQ_PROJET+AFQ->AFQ_REVISA = AF8->AF8_PROJET+AF8->AF8_REVISA"
ElseIf aEstrutura[4] = "AFC"		// Edt
    aVarRel[INICIO_PREVISTO] 	:= AFC->AFC_START                                                    
    aVarRel[FIM_PREVISTO] 		:= AFC->AFC_FINISH
	aVarRel[INICIO_REALIZADO]	:= AFC->AFC_DTATUI
	aVarRel[FIM_REALIZADO]		:= AFC->AFC_DTATUF
	aVarRel[CHAVE_BUSCA]  		:= "AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT"
	aVarRel[CHAVE_COMPARA] 		:= "AFQ->AFQ_PROJET+AFQ->AFQ_REVISA+AFQ->AFQ_EDT = " +;
								    "AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT"

	PmrPropObjeto(aObjRel, "PREVISTO", "QUANTIDADE",, AFC->AFC_QUANT)
ElseIf aEstrutura[4] = "AF9"		// Tarefa
    aVarRel[INICIO_PREVISTO] 	:= AF9->AF9_START                                                    
    aVarRel[FIM_PREVISTO] 		:= AF9->AF9_FINISH
	aVarRel[INICIO_REALIZADO]	:= AF9->AF9_DTATUI
	aVarRel[FIM_REALIZADO]		:= AF9->AF9_DTATUF
	aVarRel[CHAVE_BUSCA]  		:= "AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA"
	aVarRel[CHAVE_COMPARA] 		:= "AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA = " +;
								    "AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA"

	PmrPropObjeto(aObjRel, "PREVISTO", "QUANTIDADE",, AF9->AF9_QUANT)
Endif

If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "PREVISTO",, "SOPROPRIEDADE")	// Calculo da previsao
	
	PmrPropObjeto(aObjRel,  "PREVISTO", "DATAINICIO",, aVarRel[INICIO_PREVISTO])
	PmrPropObjeto(aObjRel,  "PREVISTO", "DATAFIM"	 ,, aVarRel[FIM_PREVISTO])

	If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "PREVISTO", "PROGRESSO")
	
 		aVarRel[DATA_REFERENCIA] := PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)
		If aVarRel[DATA_REFERENCIA] < aVarRel[FIM_PREVISTO]
			aVarRel[DURACAO] := aVarRel[DATA_REFERENCIA] - aVarRel[INICIO_PREVISTO]
		Else
			aVarRel[DURACAO] := aVarRel[FIM_PREVISTO] - aVarRel[INICIO_PREVISTO]
		Endif
        
		If ! Empty(aVarRel[FIM_PREVISTO]) .And. ! Empty(aVarRel[INICIO_PREVISTO])
	 		aVarRel[DURACAO] := Max(1, aVarRel[DURACAO])
		Endif	 		
		PmrPropObjeto(aObjRel,  "PREVISTO", "DURACAO",, aVarRel[DURACAO])

		If aVarRel[DATA_REFERENCIA] < aVarRel[FIM_PREVISTO]
			aVarRel[PROGRESSO] := aVarRel[DATA_REFERENCIA] - aVarRel[INICIO_PREVISTO]
		Else
			aVarRel[PROGRESSO] := aVarRel[FIM_PREVISTO] - aVarRel[INICIO_PREVISTO]
		Endif

		If ! Empty(aVarRel[FIM_PREVISTO]) .And. ! Empty(aVarRel[INICIO_PREVISTO])
			aVarRel[PROGRESSO] := Max(1, aVarRel[PROGRESSO])
		Endif			
		aVarRel[PROGRESSO] := NoRound((aVarRel[DURACAO] / aVarRel[PROGRESSO]) * 100, 2)
        
  		PmrPropObjeto(aObjRel,  "PREVISTO", "PROGRESSO",, aVarRel[PROGRESSO])
	Endif
Endif	

If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "REALIZADO",, "SOPROPRIEDADE")	// Calculo do realizado

	If aEstrutura[4] = "AF9"		// Tarefa
		dbSelectArea("AFF")
	Else
		dbSelectArea("AFQ")
	Endif
	dbSetOrder(1)
	MsSeek(xFilial()+ &(aVarRel[CHAVE_BUSCA]) + Dtos(PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)), .T.)

	If ! &(aVarRel[CHAVE_COMPARA])
		DbSkip(-1)
	Endif

	If &(aVarRel[CHAVE_COMPARA]) .And. aEstrutura[4] $ "AFC,AF9"	// Edt e Tarefa
		If aEstrutura[4] = "AF9"		// Tarefa
			aVarRel[FIM_REALIZADO] := AFF_DATA
		Else
			aVarRel[FIM_REALIZADO] := AFQ_DATA
		Endif
	Endif
			
	aVarRel[FOI_REALIZADO] := ! Empty(aVarRel[FIM_REALIZADO]) .And.;
										aVarRel[FIM_REALIZADO] <=;
								PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)

	If aVarRel[FOI_REALIZADO]
		aVarRel[DATA_REFERENCIA] := PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)

		If aVarRel[DATA_REFERENCIA] < aVarRel[FIM_REALIZADO]
			aVarRel[DURACAO] := aVarRel[DATA_REFERENCIA] - aVarRel[INICIO_REALIZADO]
		Else
			aVarRel[DURACAO] := aVarRel[FIM_REALIZADO] - aVarRel[INICIO_REALIZADO]
		Endif

		aVarRel[DURACAO] := Max(1, aVarRel[DURACAO])
		PmrPropObjeto(aObjRel,  "REALIZADO", "DURACAO",, aVarRel[DURACAO])
		
		If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "REALIZADO", "PROGRESSO", "SOPROPRIEDADE")
 			If aVarRel[DATA_REFERENCIA] < aVarRel[FIM_REALIZADO]
				aVarRel[PROGRESSO] := aVarRel[DATA_REFERENCIA] - aVarRel[INICIO_REALIZADO]
			Else
				aVarRel[PROGRESSO] := aVarRel[FIM_REALIZADO] - aVarRel[INICIO_REALIZADO]
			Endif

			aVarRel[PROGRESSO] 	:= Max(1, aVarRel[PROGRESSO])
			aVarRel[PROGRESSO] 	:= NoRound((aVarRel[DURACAO] / aVarRel[PROGRESSO]) * 100, 2)
			
			PmrPropObjeto(aObjRel,  "REALIZADO", "PROGRESSO",, aVarRel[PROGRESSO])
		Endif
	Endif

   	PmrPropObjeto(aObjRel,  "REALIZADO", "DATAINICIO"	,, aVarRel[INICIO_REALIZADO])
	PmrPropObjeto(aObjRel,  "REALIZADO", "DATAFIM"		,, aVarRel[FIM_REALIZADO])

	If aEstrutura[4] = "AF9"		// Tarefa
		aVarRel[TEM_AFF] := ! Eof() .And. ! Bof() .And. &(aVarRel[CHAVE_COMPARA]) .And.;
					AFF->AFF_DATA <= PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)
					
		If  aVarRel[TEM_AFF] 
			PmrPropObjeto(aObjRel,  "REALIZADO", "QUANTIDADE"	,, AFF->AFF_QUANT)
		Endif
	Else
		aVarRel[TEM_AFF] := ! Eof() .And. ! Bof() .And. &(aVarRel[CHAVE_COMPARA]) .And.;
					AFQ->AFQ_DATA <= PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)
					
		If  aVarRel[TEM_AFF] 
			PmrPropObjeto(aObjRel,  "REALIZADO", "QUANTIDADE"	,, AFQ->AFQ_QUANT)
		Endif
	Endif
Endif

If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "ATRASOINICIO",, "SOPROPRIEDADE")	// Calculo atraso para inicio
	aVarRel[A_INICIO_PREVISTO]  := PmrPropObjeto(aObjRel, "PREVISTO", "DATAINICIO", "VALOR")
	aVarRel[A_INICIO_REALIZADO] := PmrPropObjeto(aObjRel, "REALIZADO", "DATAINICIO", "VALOR")

	If Empty(aVarRel[A_INICIO_REALIZADO]) .Or.;
	   aVarRel[A_INICIO_REALIZADO] > PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)
		aVarRel[A_INICIO_REALIZADO] := PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)
	Endif
	If (! Empty(aVarRel[A_INICIO_REALIZADO]) 	.And.;
	    ! Empty(aVarRel[A_INICIO_PREVISTO])) 	.And.;
	    		aVarRel[A_INICIO_REALIZADO] > aVarRel[A_INICIO_PREVISTO]
		PmrPropObjeto(aObjRel,  "ATRASOINICIO",, "INICIALIZA",;
					   aVarRel[A_INICIO_REALIZADO] - aVarRel[A_INICIO_PREVISTO])
	Else		
		PmrPropObjeto(aObjRel,  "ATRASOINICIO",, "INICIALIZA", 0)
	Endif
Endif

If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "ATRASOFIM",, "SOPROPRIEDADE")	// Calculo atraso do final
	aVarRel[A_FINAL_PREVISTO]  := PmrPropObjeto(aObjRel,  "PREVISTO", "DATAFIM", "VALOR")
	aVarRel[A_FINAL_REALIZADO] := PmrPropObjeto(aObjRel,  "REALIZADO", "DATAFIM", "VALOR")

	If Empty(aVarRel[A_FINAL_REALIZADO]) .Or.;
	   aVarRel[A_FINAL_REALIZADO] > PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)
		aVarRel[A_FINAL_REALIZADO] := PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)
	Endif
	If (! Empty(aVarRel[A_FINAL_REALIZADO]) 	.And.;
		! Empty(aVarRel[A_FINAL_PREVISTO])) 	.And.;
				aVarRel[A_FINAL_REALIZADO] > aVarRel[A_FINAL_PREVISTO]
		PmrPropObjeto(aObjRel,  "ATRASOFIM",, "INICIALIZA",;
					  aVarRel[A_FINAL_REALIZADO] - aVarRel[A_FINAL_PREVISTO])
	Else		
		PmrPropObjeto(aObjRel,  "ATRASOFIM",, "INICIALIZA", 0)
	Endif
Endif	

If PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "CRONOGRAMAFISICO",, "SOPROPRIEDADE")	// Calculo cronograma fisico
	For nPos := 1 To Len(aVarRel[PROPRIEDADES_IMPRESSAO])
		PmrCronograma(aEstrutura, nPos, Len(aVarRel[PROPRIEDADES_IMPRESSAO]))
	Next
Endif	

If 	aEstrutura[4] $ "AF3,AF4,AFA,AFB,AE8" .And.;
	PmrPropObjeto(aVarRel[PROPRIEDADES_CALCULO], "RECURSOS",, "SOPROPRIEDADE")		// Recurso

	PmrCustosR(aEstrutura, aVarRel, lCustosR, lCurvaAbc)
	If ! lCustosR
		aVarRel[APONTAMENTOS] := { 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 }

		If aEstrutura[4] = "AFA"
			SC1->(DbSetOrder(2))	// C1_PRODUTO + C1_NUM + C1_ITEM
			DbSelectArea("AFG")		// Solicitacao de compras	[SC1]
			MsSeek(xFilial("AFG") + 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA)
										
	        While 	AFG->AFG_FILIAL + 	AFG->AFG_PROJET + AFG->AFG_REVISA +;
					AFG->AFG_TAREFA  =;
					xFilial("AFA") 	+ 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA .And. ! AFG->(Eof())
				DbSelectArea("SC1")		// Solicitacao de compras	[SC1]
				MsSeek(xFilial("SC1") + AFG->AFG_COD + AFG->AFG_NUMSC + AFG->AFG_ITEMSC)
				If 	SC1->C1_EMISSAO <= PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase) .And.;
					AFG->AFG_COD = AFA->AFA_PRODUT
					aVarRel[APONTAMENTOS][SOLICITACAO_COMPRAS] +=;
					SC1->C1_QUANT - SC1->C1_QUJE
				Endif
				AFG->(DbSkip())						
			Enddo

			SCP->(DbSetOrder(2))	// CP_PRODUTO + CP_NUM + CP_ITEM
			DbSelectArea("AFH")		// Solicitacao ao armazem	[SCP]
			MsSeek(xFilial("AFH") + 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA)
										
            While 	AFH->AFH_FILIAL + 	AFH->AFH_PROJET + AFH->AFH_REVISA +;
					AFH->AFH_TAREFA  =;
					xFilial("AFA") 	+ 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA .And. ! AFH->(Eof())
				DbSelectArea("SCP")		// Solicitacao ao armazem	[SCP]
				MsSeek(xFilial("SCP") + AFH->AFH_COD + AFH->AFH_NUMSA + AFH->AFH_ITEMSA)
				If 	SCP->CP_EMISSAO <= PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase) .And.;
					AFH->AFH_COD = AFA->AFA_PRODUT
					aVarRel[APONTAMENTOS][SOLICITACAO_ARMAZEM] +=;
					SCP->CP_QUANT - SCP->CP_QUJE
				Endif
				AFH->(DbSkip())						
			Enddo

			SC3->(DbSetOrder(2))	// C3_PRODUTO + C3_NUM + C3_ITEM
			DbSelectArea("AFL")		// Contrato de parceria	[SC3]
			MsSeek(xFilial("AFL") + 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA)
										
            While 	AFL->AFL_FILIAL + 	AFL->AFL_PROJET + AFL->AFL_REVISA +;
					AFL->AFL_TAREFA  =;
					xFilial("AFA") 	+ 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA .And. ! AFL->(Eof())
				DbSelectArea("SC3")		// Solicitacao de compras	[SC3]
				MsSeek(xFilial("SC3") + AFL->AFL_COD + AFL->AFL_NUMCP + AFL->AFL_ITEMCP)
				If AFL->AFL_COD = AFA->AFA_PRODUT
					aVarRel[APONTAMENTOS][CONTRATO_PARCERIA] +=;
					SC3->C3_QUANT - SC3->C3_QUJE
				Endif
				AFL->(DbSkip())						
			Enddo

			DbSelectArea("AFI")		// Requisicoes	[SD3]
			MsSeek(xFilial("AFA") + 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA + AFA->AFA_PRODUT)
										
            While 	AFI->AFI_FILIAL 	+ 	AFI->AFI_PROJET + AFI->AFI_REVISA +;
					AFI->AFI_TAREFA 	+ 	AFI->AFI_COD =;
					xFilial("AFA") 		+ 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
											AFA->AFA_TAREFA + AFA->AFA_PRODUT .And.;
					! AFI->(Eof())
				If 	AFI->AFI_ESTORN # "S" .And.;
					AFI->AFI_EMISSA <= PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)
					aVarRel[APONTAMENTOS][REQUISICAO] += AFI->AFI_QUANT
				Endif
				AFI->(DbSkip())						
			Enddo
			
			DbSelectArea("AFN")		// Nota de entrada	[SD1]
			MsSeek(xFilial("AFA") + 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA)
            While 	AFN->AFN_FILIAL + 	AFN->AFN_PROJET + AFN->AFN_REVISA +;
					AFN->AFN_TAREFA  =;
					xFilial("AFA") 	+ 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA .And. ! AFN->(Eof())
				If AFN->AFN_COD = AFA->AFA_PRODUT
					aVarRel[APONTAMENTOS][NOTA_ENTRADA] += AFN->AFN_QUANT
				Endif
				AFN->(DbSkip())						
			EndDo

			DbSelectArea("AFM")		// Ordem de producao	[SC2]
			MsSeek(xFilial("AFA") + 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA)
            While 	AFM->AFM_FILIAL + 	AFM->AFM_PROJET + AFM->AFM_REVISA +;
					AFM->AFM_TAREFA  =;
					xFilial("AFA") 	+ 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA .And. ! AFM->(Eof())
				If AFM->AFM_COD = AFA->AFA_PRODUT
					aVarRel[APONTAMENTOS][ORDEM_PRODUCAO] += AFM->AFM_QUANT
				Endif
				AFM->(DbSkip())						
			EndDo

			DbSelectArea("AFS")		// Nota fiscal de saida	[SF2]
			MsSeek(xFilial("AFA") + 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA + AFA->AFA_PRODUT)
            While 	AFS->AFS_FILIAL + 	AFS->AFS_PROJET + AFS->AFS_REVISA +;
					AFS->AFS_TAREFA  =;
					xFilial("AFA") 	+ 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA + AFA->AFA_PRODUT 	.And.;
					! AFS->(Eof())

				If AFS->AFS_MOVPRJ $ "25"
					aVarRel[APONTAMENTOS][NOTA_SAIDA] += AFS->AFS_QUANT
				Endif
				AFS->(DbSkip())						
			EndDo
		ElseIf aEstrutura[4] = "AFB" .And. ! Empty(AFB->AFB_TIPOD)
			DbSelectArea("AFR")		// Despesas diversas [SE2]
			MsSeek(xFilial("AFA") + 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
										AFA->AFA_TAREFA)
	  		While 	AFR->AFR_FILIAL + 	AFR->AFR_PROJET + AFR->AFR_REVISA +;
					AFR->AFR_TAREFA  =;
						xFilial("AFA") 	+ 	AFA->AFA_PROJET + AFA->AFA_REVISA +;
											AFA->AFA_TAREFA	.And. ! AFR->(Eof())
				aVarRel[APONTAMENTOS][DESPESAS_GASTAS] += AFR->AFR_VALOR1
				AFR->(DbSkip())						
			EndDo
		Endif
		
		PmrPropObjeto(	aObjRel, "RECURSOS", "SOLICITACAO_COMPRAS"	, "INICIALIZA",;
						aVarRel[APONTAMENTOS][SOLICITACAO_COMPRAS])
		PmrPropObjeto(	aObjRel, "RECURSOS", "SOLICITACAO_ARMAZEM"	, "INICIALIZA",;
						aVarRel[APONTAMENTOS][SOLICITACAO_ARMAZEM])
		PmrPropObjeto(	aObjRel, "RECURSOS", "CONTRATO_PARCERIA"	, "INICIALIZA",;
						aVarRel[APONTAMENTOS][CONTRATO_PARCERIA])
		PmrPropObjeto(	aObjRel, "RECURSOS", "REQUISICAO"			, "INICIALIZA",;
						aVarRel[APONTAMENTOS][REQUISICAO])
		PmrPropObjeto(	aObjRel, "RECURSOS", "NOTA_ENTRADA"			, "INICIALIZA",;
						aVarRel[APONTAMENTOS][NOTA_ENTRADA])
		PmrPropObjeto(	aObjRel, "RECURSOS", "ORDEM_PRODUCAO"		, "INICIALIZA",;
						aVarRel[APONTAMENTOS][ORDEM_PRODUCAO])
		PmrPropObjeto(	aObjRel, "RECURSOS", "NOTA_SAIDA" 			, "INICIALIZA",;
						aVarRel[APONTAMENTOS][NOTA_SAIDA])
		PmrPropObjeto(	aObjRel, "RECURSOS", "DESPESAS_GASTAS"		, "INICIALIZA",;
						aVarRel[APONTAMENTOS][DESPESAS_GASTAS])
	Endif
Endif

PmrEnviaI(, @nLi, aVarRel[PROPRIEDADES_IMPRESSAO])

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PmrEnviaI   ³ Autor ³ Wagner Mobile Costa ³ Data ³05.07.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia a impressao do relatorio                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PmrEnviaI(aPar1,nPar2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aPar1 = Matriz com as colunas de impressao                   ³±±
±±³          ³nPar2 = Linha de impressao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PmrEnviaI(aColunas, nLi, aPropriedades)

Local cEvento, cProp, cMascara := "", nImpressao
Local uBloco, nBloco

If aColunas = Nil
	aColunas := {}
	For nImpressao 	:= 1 To Len(aPropriedades)
		cProp		:= aPropriedades[nImpressao][1]
		cEvento 	:= ""
		cMascara 	:= ""

		If Len(aPropriedades[nImpressao]) > 2
			cMascara := aPropriedades[nImpressao][3]
		Endif
		
        If cMascara # "BLOCO_CODIGO"
			If At(":", cProp) > 0
				cEvento	:= Subs(cProp, At(":", cProp) + 1)
				cProp 	:= Left(cProp, At(":", cProp) - 1)
			Endif
		Endif
	
        If cMascara = "TEXTO"
   			Aadd(aColunas, { cProp, aPropriedades[nImpressao][2] } )
        ElseIf cMascara = "BLOCO_CODIGO"
        	uBloco := Eval(cProp)			// Retorno a ser impresso pode ser matriz
        	If ValType(uBloco) = "A"   		// Texto em varias linhas na mesma coluna
        		For nBloco := 1 To Len(uBloco)
		   			Aadd(aColunas, { uBloco[nBloco], aPropriedades[nImpressao][2] } )
        		Next
        	Else
	   			Aadd(aColunas, { uBloco, aPropriedades[nImpressao][2] } )
	   		Endif
		ElseIf ! Empty(cMascara)
  			Aadd(aColunas, { Trans(PmrPropObjeto(aObjRel, cProp, cEvento, "VALOR"),;
	  								cMascara), aPropriedades[nImpressao][2] } )
  		Else
	  		Aadd(aColunas, { PmrPropObjeto(aObjRel, cProp, cEvento, "VALOR"),;
	  										aPropriedades[nImpressao][2] } )
		Endif
	Next
Endif

For nImpressao := 1 To Len(aColunas)

	If ( nli > 60 )		// Controle se ultrapassou o limite
		nli := cabec(Titulo,Cabec1,Cabec2,nomeprog,Tamanho,CHRCOMP)
		nli++
	Endif

	@ nLi,aColunas[nImpressao][2] PSAY aColunas[nImpressao][1]
	If nImpressao = Len(aColunas) .Or.;
	   aColunas[nImpressao + 1][2] <= aColunas[nImpressao][2]
		nLi ++
	Endif
Next

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PMRAddPropO ³ Autor ³ Wagner Mobile Costa ³ Data ³04.07.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona propriedades de parametro de impresso no objeto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PMRAddPropO(cPar1,cPar2,uPar2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPar1 = Nome da propriedade                                  ³±±
±±³          ³cPar1 = Nome do evento                                       ³±±
±±³          ³uPar1 = Valor da propriedade                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PMRAddPropO(cPropriedade, cEvento, uValor)

Local nPosO := 0

If cEvento # Nil .And. ! Empty(cEvento)
	If (nPosO := Ascan(aObjRel, { |X| X[1] = cPropriedade + ":" + cEvento })) = 0
		Aadd(aObjRel, { cPropriedade + ":" + cEvento, uValor } )
	Else
		aObjRel[nPosO][2] := uValor
	Endif		
Else
	If (nPosO := Ascan(aObjRel, { |X| X[1] = cPropriedade })) = 0
		Aadd(aObjRel, { cPropriedade, uValor } )
	Else
		aObjRel[nPosO][2] := uValor
	Endif		
Endif	

Return uValor

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PMRRetPropO ³ Autor ³ Wagner Mobile Costa ³ Data ³19.07.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna propriedades de um objeto    					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PMRRetPropO(cPar1,cPar2)                               	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPar1 = Nome da propriedade                                  ³±±
±±³          ³cPar1 = Nome do evento                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PMRRetPropO(cPropriedade, cEvento)

DEFAULT cEvento := ""

Return PmrPropObjeto(aObjRel, cPropriedade, cEvento, "VALOR")					 	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PmrPropObjeto  ³ Autor ³ Wagner Mobile Costa ³ Data ³29.06.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna se o evento eh utilizado e preenche o valor            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PmrPropObjeto(cPar1,cPar2,cPar3)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aPar1 = Propriedades relacionadas ao objeto                     ³±±
±±³          ³cPar2 = Propriedade a ser verificada                            ³±±
±±³          ³cPar3 = Evento da propriedade                                   ³±±
±±³          ³cPar4 = Acao a ser executada                                    ³±±
±±³          ³uPar5 = Valor a ser preenchido na matriz de calculo             ³±±
±±³          ³uPar6 = Valor default caso propriedade vazia                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador      ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                  ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PmrPropObjeto(aTodasProp, cPropriedade, cEvento, cAcao, uValor, uDefault)

Local nPos := nPosO := 0

cEvento 	:= If(cEvento = Nil, "", cEvento)
cAcao   	:= If(cAcao = Nil, "", cAcao)

If cAcao = "INICIALIZA"
	PMRAddPropO(cPropriedade, cEvento, uValor)
Endif	

nPos := Ascan(aTodasProp, { |X| X[1] == cPropriedade + ":" +;
										  cEvento })
If nPos = 0 .And. If(cAcao = "SOPROPRIEDADE" .And. ! Empty(cEvento), .F., .T.)
	nPos := Ascan(aTodasProp, { |X| X[1] = cPropriedade })
	If nPos > 0 .And. (":" $ aTodasProp[nPos][1] .And. (cAcao # "SOPROPRIEDADE"))
		nPos := 0
	Endif
Endif

If cAcao = "SOPROPRIEDADE"		// Verifica se existe a propriedade existe
	Return nPos > 0
Endif

If cAcao # "INICIALIZA" .And. uValor # Nil .And. nPos > 0
	aTodasProp[nPos][2] := uValor
Endif

If cAcao = "VALOR"
	If nPos > 0
		uDefault := If(uDefault # Nil .And. Empty(aTodasProp[nPos][2]), uDefault,;
													aTodasProp[nPos][2])
	Else
		uDefault := If(uDefault # Nil, uDefault, 0)
	Endif
	Return uDefault
Endif
  	
Return If(cAcao = "NPOS", nPos, nPos > 0)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PmrSomaNivel   ³ Autor ³ Wagner Mobile Costa ³ Data ³26.07.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Soma o custo nos niveis acima [TAREFA/EDT/PROJETO]             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PmrCustosR(aPar1,aPar2)                           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aPar1 = Matriz com o item atual                                 ³±±
±±³          ³aPar2 = Matriz com variaveis de memoria para calculos           ³±±
±±³          ³lPar1 = Indica se esta sendo calculado os custos do recursos    ³±±
±±³          ³lPar2 = Indica se esta sendo calculado curva ABC                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador      ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                  ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PmrCustosR(aEstrutura, aVarRel, lCustosR, lCurvaAbc)

Local nRecursos, aRecursos, nPos, nPos01

If Len(aEstrutura) = 7
	aRecursos := { { Alias(), Recno() } }
Else
   	aRecursos := aEstrutura[8]
Endif

aVarRel[PROPRIEDADES_RECURSO] := { 0, 0, "" }

For nRecursos := 1 To Len(aRecursos)
	DbSelectArea(aRecursos[nRecursos][1])
	MsGoto(aRecursos[nRecursos][2])
	If Alias() = "AFA"
		SB1->(MsSeek(xFilial("SB1") + AFA->AFA_PRODUT))
		aVarRel[PROPRIEDADES_RECURSO][1] += AFA->AFA_QUANT
		aVarRel[PROPRIEDADES_RECURSO][2] := AFA->AFA_CUSTD
		aVarRel[PROPRIEDADES_RECURSO][3] := SB1->B1_TIPO
	ElseIf Alias() = "AF3"
		SB1->(MsSeek(xFilial("SB1") + AF3->AF3_PRODUT))
		aVarRel[PROPRIEDADES_RECURSO][1] += AF3->AF3_QUANT
 		aVarRel[PROPRIEDADES_RECURSO][2] := AF3->AF3_CUSTD
 		aVarRel[PROPRIEDADES_RECURSO][3] := SB1->B1_TIPO
	ElseIf Alias() = "AFB"
 		aVarRel[PROPRIEDADES_RECURSO][1] := 1
 		aVarRel[PROPRIEDADES_RECURSO][2] += AFB->AFB_VALOR
 		aVarRel[PROPRIEDADES_RECURSO][3] := AFB->AFB_TIPOD
	ElseIf Alias() = "AF4"
 		aVarRel[PROPRIEDADES_RECURSO][1] := 1
 		aVarRel[PROPRIEDADES_RECURSO][2] += AF4->AF4_VALOR
 		aVarRel[PROPRIEDADES_RECURSO][3] := AF4->AF4_TIPOD
	Endif		
	
	PmrPropObjeto(aObjRel, "RECURSOS", "QUANTIDADE",, aVarRel[PROPRIEDADES_RECURSO][1])
						
	If ! lCurvaAbc .And. lCustosR

		aVarRel[RECURSOS_POR_COLUNA] := { 	PmrPropObjeto(aObjRel, "CUSTOS", "COLUNA_1", "VALOR"),;
									 		PmrPropObjeto(aObjRel, "CUSTOS", "COLUNA_2", "VALOR"),;	
									 		PmrPropObjeto(aObjRel, "CUSTOS", "COLUNA_O", "VALOR") }
    	
		If 	PmrPropObjeto(aObjRel,  "RECURSOS", "COLUNA_1"	, "SOPROPRIEDADE")	.And.;
			aVarRel[PROPRIEDADES_RECURSO][3] $;
			PmrPropObjeto(aObjRel,  "RECURSOS", "COLUNA_1"	, "VALOR")
			
		 	PmrPropObjeto(	aObjRel,  "RECURSOS", "UNITARIO_C1",,;
		 					aVarRel[PROPRIEDADES_RECURSO][2])
		 	PmrPropObjeto(	aObjRel,  "RECURSOS", "CUSTO_C1",, 	aVarRel[PROPRIEDADES_RECURSO][2] *;
		 														aVarRel[PROPRIEDADES_RECURSO][1])
	
		 	PmrPropObjeto(aObjRel, "CUSTOS", "COLUNA_1",, 	aVarRel[RECURSOS_POR_COLUNA][1] +;
		 													aVarRel[PROPRIEDADES_RECURSO][2])
   	
		ElseIf 	PmrPropObjeto(aObjRel,  "RECURSOS", "COLUNA_2"	, "SOPROPRIEDADE") .And.;
				aVarRel[PROPRIEDADES_RECURSO][3] $;
				PmrPropObjeto(aObjRel,  "RECURSOS", "COLUNA_2"	, "VALOR")
			
		 	PmrPropObjeto(	aObjRel,  "RECURSOS", "UNITARIO_C2",,;
		 					aVarRel[PROPRIEDADES_RECURSO][2])
		 	PmrPropObjeto(	aObjRel,  "RECURSOS", "CUSTO_C2",,;
	 						aVarRel[PROPRIEDADES_RECURSO][2] * aVarRel[PROPRIEDADES_RECURSO][1])

		 	PmrPropObjeto(aObjRel, "CUSTOS", "COLUNA_2",, 	aVarRel[RECURSOS_POR_COLUNA][2] +;
		 													aVarRel[PROPRIEDADES_RECURSO][2])
	 													
		ElseIf PmrPropObjeto(aObjRel,  "RECURSOS", "COLUNA_O"	, "SOPROPRIEDADE")
		 	PmrPropObjeto(	aObjRel,  "RECURSOS", "UNITARIO_CO",,;
		 					aVarRel[PROPRIEDADES_RECURSO][2])
		 	PmrPropObjeto(	aObjRel,  "RECURSOS", "CUSTO_CO",,;
		 					aVarRel[PROPRIEDADES_RECURSO][2] * aVarRel[PROPRIEDADES_RECURSO][1])
		 	PmrPropObjeto(aObjRel, "CUSTOS", "COLUNA_O",, 	aVarRel[RECURSOS_POR_COLUNA][3] +;
		 													aVarRel[PROPRIEDADES_RECURSO][2])
		 													
		Endif
	Endif
Next

PmrPropObjeto(	aObjRel,  "RECURSOS", "CUSTO_TOTAL",, 	aVarRel[PROPRIEDADES_RECURSO][2] *;
														aVarRel[PROPRIEDADES_RECURSO][1])
														
If lCustosR
	PmrPropObjeto(	aObjRel,  "RECURSOS", "CUSTO_UNITARIO",, aVarRel[PROPRIEDADES_RECURSO][2])

	nPos01 := PmrPropObjeto(aObjRel, "RECURSOS", "PERCTOTAL", "NPOS",;
			  		(aVarRel[PROPRIEDADES_RECURSO][2] *;
					 aVarRel[PROPRIEDADES_RECURSO][1]) /;
	PmrPropObjeto(aObjRel, "CUSTOS", "CUSTO_TOTAL", "VALOR") * 100)	// Retorno posicao PERCENTUAL RECURSO

	// Verifico se usa percentual ACUMULADO e ja com as posicoes na matriz faco o CALCULO

	If (nPos := PmrPropObjeto(aObjRel, "RECURSOS", "PERCENTO_ACUMULADO", "NPOS")) > 0
		PmrAddPropO("RECURSOS", "PERCENTO_ACUMULADO",;
	     	aObjRel[nPos][2] + aObjRel[nPos01][2])
	Endif
Endif
	
DbSelectArea(aRecursos[1][1])
MsGoto(aRecursos[1][2])
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PmrSomaNivel   ³ Autor ³ Wagner Mobile Costa ³ Data ³26.07.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Soma o custo nos niveis acima [TAREFA/EDT/PROJETO]             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PmrSomaNivel(aPar1,nPar1,aPar2,aPar3)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aPar1 = Valores a serem somados { { VALOR, QUANTO, TIPO } }     ³±±
±±³          ³nPar1 = Nivel do projeto sendo verificado                       ³±±
±±³          ³aPar2 = Matriz com variaveis de memoria para calculos           ³±±
±±³          ³aPar3 = Matriz com o recurso atual sendo somado                 ³±±
±±³          ³lPar1 = Totaliza os niveis [TAREFA/EDT/PROJETO]                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador      ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                  ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PmrSomaNivel(aValores, aVarRel, nIndice, aRecurso, lNiveis, aResumo)

Local nTarefa := nNiveis := 0, aColunas := { .F., .F., .F. }, nPosRes

aVarRel[CUSTO_TOTAL] += aValores[1]

If aResumo # Nil
	If (nPosRes := Ascan(aResumo, { |X| X[1] = aValores[3] })) = 0
		Aadd(aResumo, { aValores[3], 0.00 })
		nPosRes := Len(aResumo)
	Endif
	aResumo[nPosRes][2] += aValores[1]
Endif
                    	
// Somo o valor no PAI
				
If 	lNiveis
      	                
	If 	PmrPropObjeto(aObjRel, "RECURSOS", "COLUNA_1", "SOPROPRIEDADE") .And.;
		aValores[3] = PmrPropObjeto(aObjRel,  "RECURSOS", "COLUNA_1", "VALOR")

		aColunas[1] := .T.
		aVarRel[ESTRUTURA_PROJETO][1][nIndice][TOTALIZACAO][COLUNA1] += aValores[1]
		
	ElseIf PmrPropObjeto(aObjRel, "RECURSOS", "COLUNA_2", "SOPROPRIEDADE") .And.; 
			aValores[3] = PmrPropObjeto(aObjRel,  "RECURSOS", "COLUNA_2", "VALOR")

		aColunas[2] := .T.
		aVarRel[ESTRUTURA_PROJETO][1][nIndice][TOTALIZACAO][COLUNA2] += aValores[1]
		
	ElseIf PmrPropObjeto(aObjRel, "RECURSOS", "COLUNA_O", "SOPROPRIEDADE")

		aColunas[3] := .T.
 		aVarRel[ESTRUTURA_PROJETO][1][nIndice][TOTALIZACAO][COLUNAO] += aValores[1]
	Endif
						
	aVarRel[ESTRUTURA_PROJETO][1][nIndice][TOTALIZACAO][COLUNAT] 		+= aValores[1]
	aVarRel[ESTRUTURA_PROJETO][1][nIndice][TOTALIZACAO][QUANTIDADE]	+= aValores[2]

	While .T.
		If nNiveis = 0
			nNiveis := aVarRel[ESTRUTURA_PROJETO][1][nIndice][5]
		Else			
			nNiveis := aVarRel[ESTRUTURA_PROJETO][1][nNiveis][5]
		Endif

		If nNiveis = 0
			Exit
		Endif

		aVarRel[ESTRUTURA_PROJETO][1][nNiveis][TOTALIZACAO][COLUNAT] 		+= aValores[1]
		aVarRel[ESTRUTURA_PROJETO][1][nNiveis][TOTALIZACAO][QUANTIDADE]	+= aValores[2]
		
		If aColunas[1]
			aVarRel[ESTRUTURA_PROJETO][1][nNiveis][TOTALIZACAO][COLUNA1]	+= aValores[1]
		Endif			

		If aColunas[2]
			aVarRel[ESTRUTURA_PROJETO][1][nNiveis][TOTALIZACAO][COLUNA2]	+= aValores[1]
		Endif			                                                         

		If aColunas[3]
			aVarRel[ESTRUTURA_PROJETO][1][nNiveis][TOTALIZACAO][COLUNAO]	+= aValores[1]
		Endif			
	Enddo
Endif

Return .T.
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PmrCronograma  ³ Autor ³ Wagner Mobile Costa ³ Data ³01.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o cronograma PREVISTO/REALIZADO                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PmrCronograma(nPar1,nPar2,aPar2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aPar1 = Estrutura atual sendo analisada { AF8 / AFC / AF9 }     ³±±
±±³          ³nPar2 = Tipos a serem listados 1 - Previsto, 2 - Prv e Rea      ³±±
±±³          ³nPar1 = Tipo atual 1 - Previsto 2 = Realizado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador      ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                  ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PmrCronograma(aEstrutura, nTipo, nTipos)
	
Local nPeriodo, dPerAtual, lCAnoTerOut, lMesIniciaP, lMesFinalP, cDtosPAtual	// Cronograma
Local aCronograma 	:= Array(11)
Local cTipo			:= If(nTipo = 1, "PREVISTO", "REALIZADO")

aCronograma[1] := PmrPropObjeto(aObjRel, "POSICOESCRONOGRAMA",, "VALOR")
	
#DEFINE 	POSICAO_INI_IMP_BARRA	1
#DEFINE 	SEPARADORES           	2
#DEFINE 	PERIODOS_RELATORIOS   	3

#DEFINE 	PERIODO_COLUNA        	1
#DEFINE 	COLUNA_IMPRESSAO      	2

#DEFINE 	IMPRESSAO_PROGRESSO   	4

#DEFINE 	MAXIMO_NO_MES        	2
#DEFINE 	CONTINUA_MES_ANTERIOR	3
#DEFINE 	DIA_INICIA_BARRA       	4
#DEFINE 	POSICAO_BARRA          	5 
#DEFINE 	MARCOU_DATA_INICIO     	6 
#DEFINE 	MARCOU_DATA_FINAL      	7 
#DEFINE 	IMPRESSAO_INICIO_FIM   	8 
#DEFINE 	DATA_INICIO     		9 
#DEFINE 	DATA_FINAL      		10
#DEFINE 	PERIODOS        		11

If nTipo = 2
	aCronograma[1][IMPRESSAO_PROGRESSO] := Stuff(aCronograma[1][SEPARADORES], 0,;
	aCronograma[1][POSICAO_INI_IMP_BARRA], Left(cTipo +;
	Space(aCronograma[1][POSICAO_INI_IMP_BARRA]), aCronograma[1][POSICAO_INI_IMP_BARRA]))
Else
	aCronograma[1][IMPRESSAO_PROGRESSO] := Stuff(aCronograma[1][SEPARADORES], 0,;
	aCronograma[1][POSICAO_INI_IMP_BARRA], Left(AllTrim(aEstrutura[1])+ "-" + aEstrutura[2],;
	aCronograma[1][POSICAO_INI_IMP_BARRA]))
Endif

aCronograma[CONTINUA_MES_ANTERIOR] 	:= .F.	// Usada caso a barra seja maior de um mes
aCronograma[MARCOU_DATA_INICIO]    	:= .F.
aCronograma[MARCOU_DATA_FINAL]     	:= .F.
aCronograma[DATA_INICIO] 			:= PmrPropObjeto(aObjRel, cTipo, "DATAINICIO", "VALOR")
aCronograma[DATA_FINAL] 			:= PmrPropObjeto(aObjRel, cTipo, "DATAFIM", "VALOR")
aCronograma[PERIODOS]				:= Len(aCronograma[1][PERIODOS_RELATORIOS])

If Empty(aCronograma[DATA_FINAL])
	aCronograma[PERIODOS] := 0
Endif

For nPeriodo 	:= 1 To aCronograma[PERIODOS]
    
	cDtosPAtual	:= aCronograma[1][PERIODOS_RELATORIOS][nPeriodo][PERIODO_COLUNA]
    	
    If 	cDtosPAtual >;
    	Left(Dtos(PmrPropObjeto(aObjRel, "LIMITEPREVISTO",, "VALOR",, dDataBase)), 6) 
		Exit		// Limite do cronograma    		
    Endif
    	
	dPerAtual 	:= Stod(cDtosPAtual)

	aCronograma[MAXIMO_NO_MES] := Val(Right(cDtosPAtual, 2))
		
	lCAnoTerOut := 	Year(aCronograma[DATA_INICIO]) #;
					Year(aCronograma[DATA_FINAL]) .And.;
    Year(dPerAtual) > Year(aCronograma[DATA_INICIO])
		
	lMesIniciaP := cDtosPAtual = Left(Dtos(PmrPropObjeto(aObjRel, cTipo , "DATAINICIO", "VALOR")), 6)
	lMesFinalP	:= cDtosPAtual <= Left(Dtos(aCronograma[DATA_FINAL]), 6)
		
    If 	(lMesIniciaP).Or. (lCAnoTerOut .And. lMesFinalP) .Or.;
   		 aCronograma[CONTINUA_MES_ANTERIOR]
		If Month(dPerAtual) = Month(aCronograma[DATA_FINAL]) .And.;
       		Year(dPerAtual) = Year(aCronograma[DATA_FINAL])
       		aCronograma[MAXIMO_NO_MES] := Day(PmrPropObjeto(aObjRel, cTipo	, "DATAFIM", "VALOR"))
       		aCronograma[CONTINUA_MES_ANTERIOR] 	:= .F.
		Else
       		aCronograma[CONTINUA_MES_ANTERIOR] 	:= .T.
		Endif                                     

   		If Month(dPerAtual) = Month(aCronograma[DATA_INICIO])
       		aCronograma[DIA_INICIA_BARRA]	:= Day(aCronograma[DATA_INICIO]) - 1	// Conta o Dia
		Else
			aCronograma[DIA_INICIA_BARRA] 	:= 0
		Endif
			
		aCronograma[IMPRESSAO_INICIO_FIM] := { ">" +;
			Left(Dtoc(aCronograma[DATA_INICIO]), 5) +;
									 "<", ">" +;
		  	Left(Dtoc(aCronograma[DATA_FINAL]), 5) +;
								  	 "<",,, }
										  
		aCronograma[IMPRESSAO_INICIO_FIM][3] := Len(aCronograma[IMPRESSAO_INICIO_FIM][1])
		aCronograma[IMPRESSAO_INICIO_FIM][4] := Len(aCronograma[IMPRESSAO_INICIO_FIM][2])
										  
// 01/08/01   03/09/01
// 1234567890123456789012345678901123456789012345678901234567890
// 1234567890123456789012345678901123
// ===============================
//                                ==============================
            
		aCronograma[POSICAO_BARRA] := 	aCronograma[1][PERIODOS_RELATORIOS][nPeriodo][COLUNA_IMPRESSAO] +;
   	    						   		aCronograma[DIA_INICIA_BARRA]
      	    
   		aCronograma[1][IMPRESSAO_PROGRESSO] :=;
 Stuff(aCronograma[1][IMPRESSAO_PROGRESSO],;
   		aCronograma[POSICAO_BARRA],;
   	    aCronograma[MAXIMO_NO_MES] - aCronograma[DIA_INICIA_BARRA], Repl("=",;
   	    aCronograma[MAXIMO_NO_MES] - aCronograma[DIA_INICIA_BARRA]))
      	    
   		If ! Empty(aCronograma[DATA_INICIO]) .And. ! aCronograma[MARCOU_DATA_INICIO]	

     		aCronograma[1][IMPRESSAO_PROGRESSO] :=;
   	  Stuff(aCronograma[1][IMPRESSAO_PROGRESSO],;
   	  		 aCronograma[POSICAO_BARRA] - aCronograma[IMPRESSAO_INICIO_FIM][3]-1,;
   			 aCronograma[IMPRESSAO_INICIO_FIM][3], aCronograma[IMPRESSAO_INICIO_FIM][1])
		     aCronograma[MARCOU_DATA_INICIO] := .T.
			    
		 Endif
		    
	 	If 	! Empty(aCronograma[DATA_FINAL])	.And.;
	 		! aCronograma[MARCOU_DATA_FINAL] 	.And. ! aCronograma[CONTINUA_MES_ANTERIOR]

			aCronograma[POSICAO_BARRA] := 	aCronograma[1][PERIODOS_RELATORIOS][nPeriodo][COLUNA_IMPRESSAO] +;
   	  	    						   		aCronograma[MAXIMO_NO_MES]

     		aCronograma[1][IMPRESSAO_PROGRESSO] :=;
   	  Stuff(aCronograma[1][IMPRESSAO_PROGRESSO],;
            aCronograma[POSICAO_BARRA], aCronograma[IMPRESSAO_INICIO_FIM][4],;
             						 	 aCronograma[IMPRESSAO_INICIO_FIM][2])

		    aCronograma[MARCOU_DATA_FINAL]	:= .T.
      	
		Endif
	Endif
Next

PmrPropObjeto(	aObjRel,  "CRONOGRAMAFISICO", If(nTipos = 2, cTipo, ""), "INICIALIZA",;
				aCronograma[1][IMPRESSAO_PROGRESSO])

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PmrPertence    ³ Autor ³ Wagner Mobile Costa ³ Data ³03.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se um conteudo faz parte de string formato xx-xx;xx-xx³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PmrPertence(uPar1,uPar2)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPar1 = String a ser verificada - 01                            ³±±
±±³          ³cPar2 = Tipos de strings que sao aceitas 01-10;11-11            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador      ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                  ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PmrPertence(uVerifica, uStrings)

Local lRetorno := .F.
Local nStrings, cString
Local cInicio, cFim
Local aVerifica, aStrings
Local cVerifica, cStrings
Local nVerifica

If ValType(uVerifica) = "A"
	aVerifica := uVerifica
	aStrings  := uStrings
Else
	aVerifica := { uVerifica }
	aStrings  := { uStrings }
Endif

For nVerifica := 1 To Len(aVerifica)
	cStrings 	:= AllTrim(aStrings[nVerifica])
	cVerifica 	:= AllTrim(aVerifica[nVerifica])

	If Empty(cStrings)
		lRetorno := .T.
	Else
		For nStrings := 1 To Len(cStrings)
			cString := If(At(";", cStrings) > 0, Left(cStrings, At(";", cStrings) - 1),;
														cStrings)
			If At("-", cString) > 0
				cInicio := Left(cString, At("-", cString) -1)
				cFim	:= Subs(cString, Len(cInicio) + 2)
			Else
				cInicio := cString
				cFim	:= cString
			Endif
			If cVerifica >= cInicio .And. cVerifica <= cFim
				lRetorno := .T.
				Exit
			Else
				lRetorno := .F.
			Endif
			If At(";", cStrings) = 0
				cStrings := ""
			Else
				cStrings := Right(cStrings, Len(cStrings)-At(";", cStrings))
			Endif
			If Len(cStrings) = 0
				Exit
			Endif
		Next
	Endif
	If ! lRetorno
		Exit
	Endif
Next

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PmrFlxPc  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 13/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta array com Pedidos de Compras [SC7 Atual posicionado]  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³PmrFlxPc() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ParA1 = { 01/01/2001, 02/01/2001 }						  ³±±
±±³          ³ParA2 = { { 01/01/2001,1000,00,5 },{ 02/01/2001,2000.00,5 }}³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PmsXRel  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmrFlxPc(aDCompras, aCompras, dDataR)

LOCAL cCond,nValTot:=0,nValIpi:=0,aVenc:={},i,nPrcCompra
LOCAL dData,nValIPILiq,nl
LOCAL nTotDesc

nValTot := 0
nValIpi := 0
aVenc	:= {}
cCond	:= SC7->C7_COND
nTotDesc:= SC7->C7_VLDESC

IF SC7->C7_QUJE >= SC7->C7_QUANT .or. SC7->C7_RESIDUO == "S" .or. SC7->C7_FLUXO == "N"
	Return
Endif

SB1->(MsSeek( xFilial("SB1") + SC7->C7_PRODUTO)) // Posiciona Produto
SF4->(MsSeek( xFilial("SF4") + SC7->C7_TES ))  // Posiciona TES
IF SF4->(Eof()) .Or. SF4->F4_DUPLIC == "N" .OR. SB1->B1_IMPORT == "S"
	dbSelectArea("SC7")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula o reajuste do pedido de compra								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPrcCompra := SC7->C7_PRECO
dData		 := Iif( SC7->C7_DATPRF < dDataR, dDataR, DataValida(SC7->C7_DATPRF))
If ! Empty(SC7->C7_REAJUST)
	nPrcCompra := fc020Form(SC7->C7_REAJUST,dData)
Endif
nValTot	  	:= (SC7->C7_QUANT-SC7->C7_QUJE) * nPrcCompra
nValIPI	  	:= 0
nValIPILiq  := nValTot
If nTotDesc == 0
	nTotDesc := CalcDesc(nValTot,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Proporcionaliza o desconto de pedidos com entrega parcial	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotDesc := ((SC7->C7_VLDESC * nValTot)/SC7->C7_TOTAL)
EndIf
nValTot	:= nValTot - nTotDesc
IF SC7->C7_IPI > 0
	If SC7->C7_IPIBRUT != "L"
		nBaseIPI := nValTot
	Else
		nBaseIPI := nValIPILiq
	Endif
	IF SF4->F4_BASEIPI > 0
		nBaseIPI *= SF4->F4_BASEIPI / 100
	Endif
	nValIPI := IIf(nBaseIPI = 0, 0, nBaseIPI * SC7->C7_IPI / 100)
Endif
nValTot  += (nValIPI + SC7->C7_FRETE)
dbSelectArea("SE4")
MsSeek(xFilial("SE4")+SC7->C7_COND)
nValTot  *= (SE4->E4_ACRSFIN/100)+1
dbSelectArea("SC7")
aVenc	  := Condicao(nValTot,cCond,nValIpi,dData)

IF Len(aVenc)>0
	For i:=1 To Len(aVenc)
		IF Len(aCompras)=0
			nL:=0
		Else
			nL:=Ascan(adCompras,DataValida(aVenc[i][1]))
		Endif
		IF nL!=0
			aCompras[nL][2]+=aVenc[i][2]		// Valor dividido por vencimento
			aCompras[nL][3]++					// Quantidade de pedidos no dia
		Else
			AADD(aCompras,{DataValida(aVenc[i][1]),aVenc[i][2], 1 })
			AADD(adCompras,DataValida(aVenc[i][1]))
		Endif
	Next i
Endif
dbSelectArea("SC7")

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PmrFlxPv  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 17/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta array com Pedidos de vendas  [SC6 Atual posicionado]  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³PmrFlxPv() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ParA1 = { 01/01/2001, 02/01/2001 }						  ³±±
±±³          ³ParA2 = { { 01/01/2001,1000,00,5 },{ 02/01/2001,2000.00,5 }}³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PmsXRel  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PmrFlxPv(aDVendas, aVendas, dDataR, nMoeda, cMoedas)

LOCAL cCond,nValTot:=0,nValIpi:=0,aVenc:={},i, nPrcVen
LOCAL dData

DEFAULT cMoedas := "012345"

nValTot := 0
nValIpi := 0
aVenc := {}

If Substr(SC6->C6_BLQ,1,1) $"RS"
	Return .F.
Endif

If SC6->C6_QTDENT >= SC6->C6_QTDVEN
	Return .F.
Endif

dbSelectArea("SF4")
SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))
		
dbSelectArea("SC6")
If SF4->(Eof()) .Or. SF4->F4_DUPLIC == "N"
	Return .F.
Endif

dbSelectArea("SC5")
SC5->(MsSeek( xFilial("SC5") + SC6->C6_NUM ))
If (Str(C5_MOEDA,1) $ cMoedas)
	cCond := SC5->C5_CONDPAG
	dbSelectArea("SC6")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o reajuste do pedido de venda								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPrcVen := SC6->C6_PRCVEN
	dData   := Iif( SC6->C6_ENTREG < dDataR, dDataR, (DataValida(SC6->C6_ENTREG)))
	If !Empty(SC5->C5_REAJUST)
		nPrcVen := fc020Form(SC5->C5_REAJUST,dData)
	Endif
	nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA, nMoeda, dData)
	nValTot	:= (SC6->C6_QTDVEN-SC6->C6_QTDENT) * nPrcVen
	cProd 	:= SC6->C6_PRODUTO
	dbSelectArea("SB1")
	MsSeek(xFilial("SB1")+cProd)
	dbSelectArea("SC6")
	nValIPI	:= 0
	If SF4->F4_IPI == "S" .And. SB1->B1_IPI > 0
		nBaseIPI :=(SC6->C6_QTDVEN-SC6->C6_QTDENT)*nPrcVen
		If SF4->F4_BASEIPI > 0
			nBaseIPI*=(SF4->F4_BASEIPI/100)
		Endif
		nValIpi  :=IIf(nBaseIPI=0,0,(nBaseIPI*SB1->B1_IPI)/100)
	Endif
	nValTot += (nValIPI+IIF(SC5->C5_TPFRETE=="C",SC5->C5_FRETE,0)+SC5->C5_SEGURO)
	nValTot *= (SC5->C5_ACRSFIN/100)+1
	dbSelectArea("SC6")

	aVenc := Condicao(nValTot,cCond,nValIpi,dData)

	If Len(aVenc)>0
		For i := 1 To Len(aVenc)
			If Len(aVendas)=0
				nL := 0
			Else
				nL := Ascan(adVendas,DataValida(aVenc[i][1]))
			Endif
			IF nL != 0
				aVendas[nL][2]+=aVenc[i][2]	// Valores distribuidos por vencimento
				aVendas[nL][3]++				// Numero de pedidos no vencimento
			Else
				AADD(aVendas,{DataValida(aVenc[i][1]),aVenc[i][2], 1})
				AADD(aDVendas,DataValida(aVenc[i][1]))
			Endif
		Next i
	Endif
Endif

dbSelectArea("SC6")

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PmsAddCusto ³ Autor ³ Wagner Mobile Costa ³ Data ³17.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona o valor do custo previsto e/ou realizado           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PmsAddCusto()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PmsAddCusto(aProjeto)

Local nEdt       := 0
Local nValor     := 0
Local nValor2    := 0
Local nx         := 0
Local nData      := 0
Local nStep      := 1
Local nRecEDTAnt := 0
Local aDatas     := {}
Local aValor     := {}
Local aOpcoes    := PmrPropObjeto(aObjRel, "CONFIGURACAO",, "VALOR")

If aOpcoes[4] == 2
	nStep := 8
ElseIf aOpcoes[4] == 3
	nStep := 31
EndIf

nData := aOpcoes[3] - aOpcoes[2]

DbSelectArea("AF8")

MsGoto(aProjeto[1,3])

For nEdt := 1 to Len(aProjeto) // por item

	If aProjeto[nEdt,4] == "AFC"
		DbSelectArea(aProjeto[nEdt,4])
		MsGoto( aProjeto[nEdt,3] )
		nRecEdtAnt := aProjeto[nEdt,3]
		nx := 0
		While .t.
			aValor := PmsSeekEdt( AFC_PROJET + AFC_REVISA , aOpcoes[1], aOpcoes[2] + nx, nStep, AFC_EDT, AFC_NIVEL, aOpcoes[5] )
			nValor += aValor[1]
			nValor2 += aValor[2]
			Aadd(aDatas,{nValor, aOpcoes[2] + nx, nValor2 } )
			If aOpcoes[2] + nx > aOpcoes[3]
				Exit
			EndIf
			nx += nStep
		End
	ElseIf aProjeto[nEdt,4] == "AF9"
		DbSelectArea(aProjeto[nEdt,4])
		MsGoto( aProjeto[nEdt,3] )
		AFC->(MsGoto(nRecEdtAnt))
		nx := 0
		While .t.
			If aOpcoes[5] == 3
				nValor  += PmsCOTPTrf(aOpcoes[1],aOpcoes[2] + nx,nStep)
			ElseIf aOpcoes[5] == 1
				nValor += PmsCRTPTrf(AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDT,aOpcoes[1],aOpcoes[2] + nx,nStep)
			ElseIf aOpcoes[5] == 2
				nValor2  += PmsCOTPTrf(aOpcoes[1],aOpcoes[2] + nx,nStep)
				nValor += PmsCRTPTrf(AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDT,aOpcoes[1],aOpcoes[2] + nx,nStep)
			EndIf
			Aadd(aDatas,{nValor,aOpcoes[2] + nx, nValor2})
			If aOpcoes[2] + nx > aOpcoes[3]
				Exit
			EndIf
			nx += nStep
		End
	EndIf
	Aadd(aProjeto[nEdt],aDatas)
	aDatas  := {}
	nValor  := 0
	nValor2 := 0
Next
Return aProjeto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³PmsSeekEDT³ Autor ³ Michel Dantas       ³ Data ³11.10.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Procura EDTFILHA                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PmsSeekEdt(cEdt,nMoeda,dDataRef,nIntervalo,cEdtAtu,cNivel,nOpc)

Local aArea   := {}
Local aArea2  := {}
Local nValor  := 0
Local nValor2 := 0
Local x       := 1

Aadd(aArea,AF9->(GetArea()))
Aadd(aArea,AFC->(GetArea()))
Aadd(aArea,GetArea())

DbSelectArea("AF9")
DbSetOrder(2)

DbSelectArea("AFC")
DbSetOrder(2)

SysRefresh()
While !Eof() .And. ;
	AFC_FILIAL + AFC_PROJETO + AFC_REVISA + AFC_EDT == xFilial() + cEdt + cEdtAtu
	aArea2 := GetArea()
	DbSetOrder(2)
	If MsSeek(AFC_FILIAL + AFC_PROJETO + AFC_REVISA + AFC_EDT)
		While AFC_FILIAL + AFC_PROJETO + AFC_REVISA + AFC_EDTPAI == xFilial()+ cEdt + cEdtAtu
			aValor  := PmsSeekEdt( AFC_PROJET + AFC_REVISA, nMoeda, dDataRef, nIntervalo,AFC_EDT,AFC_NIVEL,nOpc )
			nValor  += aValor[1]
			nValor2 += aValor[2]
			dbSkip()
		End
		RestArea(aArea2)
	Else
		RestArea(aArea2)
		If nOpc == 3
			nValor  += PmsCOTPTrf(nMoeda,dDataRef,nIntervalo)
		ElseIf nOpc == 1
			nValor += PmsCRTPTrf(AFC_PROJET + AFC_REVISA + AFC_EDT,nMoeda,dDataRef,nIntervalo)
		ElseIf nOpc == 2
			nValor2 += PmsCOTPTrf(nMoeda,dDataRef,nIntervalo)
			nValor  += PmsCRTPTrf(AFC_PROJET + AFC_REVISA + AFC_EDT,nMoeda,dDataRef,nIntervalo)
		EndIf
			
	EndIf
	DbSelectArea("AFC")
	DbSkip()
End
For x := 1 to Len(aArea)
	RestArea(aArea[x])
Next

Return { nValor, nValor2 }
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³PmsCOTPTrf³ Autor ³ Michel Dantas       ³ Data ³16.10.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao auxiliar da PmsCotp                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PmsCOTPTrf(nMoeda,dDataRef,nIntervalo)

Local aCustoa := {}
Local aCustob := {}
Local nValor  := 0
Local aArea   := {}
Local x       := 1

Aadd(aArea,AFA->(GetArea()))
Aadd(aArea,AFB->(GetArea()))
Aadd(aArea,AF9->(GetArea()))
Aadd(aArea,GetArea())

DbSelectArea("AFA")
DbSetOrder(1)

DbSelectArea("AFB")
DbSetOrder(1)

DbSelectArea("AF9")
DbSetOrder(2)

MsSeek( xFilial() + AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDT )
While !Eof() .And. ;
	AF9_FILIAL + AF9_PROJET + AF9_REVISA + AF9_EDTPAI == ;
	xFilial() + AFC->AFC_PROJETO + AFC->AFC_REVISA + AFC->AFC_EDT

	DbSelectArea("AFA")
	MsSeek( xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+AF9->AF9_TAREFA )
	While AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA == ;
		xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+AF9->AF9_TAREFA
		PmsCOTP(dDataRef,dDataRef+nIntervalo,aCustoa)
		nValor += aCustoa[nMoeda]
		DbSelectArea("AFA")
		DbSkip()
	End		

	DbSelectArea("AFB")
	MsSeek( xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+AF9->AF9_TAREFA )
	While AFB_FILIAL+AFB_PROJET+AFB_REVISA+AFB_TAREFA == ;
		xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+AF9->AF9_TAREFA

		PmsCOTP(dDataRef,dDataRef+nIntervalo,aCustob)

		nValor += aCustob[nMoeda]
		DbSelectArea("AFB")
		DbSkip()
	End
	DbSelectArea("AF9")
	DbSkip()
End
For x := 1 to Len(aArea)
	RestArea(aArea[x])
Next
Return nValor
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³PmsCOTP   ³ Autor ³ Michel Dantas       ³ Data ³16.10.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do custo previsto para o intervalo de data       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PmsCOTP( dDatai, dDataf, aCusto )

Local aVetor    := Array(7)
Local x         := 1
Local cArea     := Alias()
Local lRet		:= .F.

aCusto	:= {0,0,0,0,0}

If cArea == "AFA" //Quantidade
	aVetor[1] := AFA_QUANT
Else
	aVetor[1] := 1 
EndIf
aVetor[2] := (cArea)->&(cArea+"_ACUMUL") // Acumula
If cArea == "AFA"
	aVetor[3] := AFA_CUSTD
Else
	aVetor[3] := AFB_VALOR
EndIf
aVetor[4] := (cArea)->&(cArea+"_MOEDA") // Moeda

aVetor[5] := AF9->AF9_FINISH - AF9->AF9_START // dias de trabalho
If aVetor[5] == 0
	aVetor[5] := 1
EndIf

If aVetor[2] == "1" // 50% por 50% // 0% por 100%
	If ( AF9->AF9_START + (aVetor[5]/2) ) >= dDatai .And. ( AF9->AF9_START + (aVetor[5]/2) ) < dDataf
		For x := 1 to Len(aCusto)
			aCusto[x]	:= xMoeda(aVetor[3]*aVetor[1],aVetor[4],x)/2
		Next
		lRet		:= .T.
   	EndIf
	If ( AF9->AF9_START + (aVetor[5]/2) ) = dDatai .or. ( AF9->AF9_START + (aVetor[5]/2) ) = dDataf
		For x := 1 to Len(aCusto)
			aCusto[x]	:= xMoeda(aVetor[3]*aVetor[1],aVetor[4],x)/2
		Next
		lRet		:= .T.
   	EndIf
	If  ( AF9->AF9_START + aVetor[5] ) >= dDatai .And. ( AF9->AF9_START + aVetor[5] ) < dDataf
		For x := 1 to Len(aCusto)
			aCusto[x]	+= xMoeda(aVetor[3]*aVetor[1],aVetor[4],x)/2
		Next
		lRet		:= .T.
   	EndIf
ElseIf aVetor[2] == "2" // 0% por 100%
	If  dDatai <= AF9->AF9_FINISH  .And. dDataf >= AF9->AF9_FINISH
		For x := 1 to Len(aCusto)
			aCusto[x]	:= xMoeda(aVetor[3]*aVetor[1],aVetor[4],x)
		Next
		lRet		:= .T.
   	EndIf
ElseIf aVetor[2] == "3"
	If (aVetor[7] := dPertence(AF9->AF9_START,AF9->AF9_FINISH,dDatai,dDataf)) <> 0
		aVetor[7] := aVetor[7] /aVetor[5]
		For x := 1 to Len(aCusto)
			aCusto[x]	:= xMoeda(aVetor[3]*aVetor[1],aVetor[4],x) * aVetor[7]
		Next
		lRet		:= .T.
	EndIf
ElseIf aVetor[2] == "4"
	If (cAlias)->&( (cAlias)+"_DATPRF" ) >= dDatai .And. (cAlias)->&( (cAlias)+"_DATPRF" ) < dDataf
		For x := 1 to Len(aCusto)
			aCusto[x]	:= xMoeda(aVetor[3]*aVetor[1],aVetor[4],x)
		Next
		lRet := .T.
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³PmsCRTPTrf³ Autor ³ Michel Dantas       ³ Data ³22.10.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ calcula o valor real das EDTs/Tarefas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PmsCRTPTrf(cProjeto,nMoeda,dDataRef,nIntervalo)

Local x      := 1
Local aArea  := {}
Local aCusto := {0,0,0,0,0}

Aadd(aArea,AF9->(GetArea()))
Aadd(aArea,SD3->(GetArea()))
Aadd(aArea,SD1->(GetArea()))
Aadd(aArea,GetArea())

DbSelectArea("AF9")
DbSetOrder(2)

If MsSeek(xFilial()+cProjeto)
	While !Eof() .and. xFilial() + AF9_PROJET + AF9_REVISA + AF9_EDTPAI ==;
			AFC->AFC_FILIAL + cProjeto
		DbSelectArea("SD3")
		DbSetOrder(10)

		MsSeek( xFilial() + AF9->AF9_PROJET + AF9->AF9_TAREFA )
		While !Eof() .And. D3_FILIAL + D3_PROJPMS + D3_TASKPMS ==;
							xFilial("SD3") + AF9->AF9_PROJET + AF9->AF9_TAREFA
			If D3_EMISSAO >= dDataRef .And. D3_EMISSAO < dDataRef+nIntervalo .and. SD3->D3_ESTORNO <> "S"
				aCusto[1] += D3_CUSTO1
				aCusto[2] += D3_CUSTO2
				aCusto[3] += D3_CUSTO3
				aCusto[4] += D3_CUSTO4
				aCusto[5] += D3_CUSTO5
			EndIf
			dbSelectArea("SD3")
			dbSkip()
		End
		dbSelectArea("AFR")
		dbSetOrder(1)

		MsSeek( xFilial() + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA )

		While !Eof() .And. AFR_FILIAL + AFR_PROJET + AFR_REVISA + AFR_TAREFA ==;
						xFilial("AFR") + AF9->AF9_TAREFA + AF9->AF9_REVISA + AF9->AF9_TAREFA
			If SE2->( MsSeek( xFilial() + AFR->AFR_PREFIXO + AFR->AFR_NUM + ;
					AFR->AFR_PARCELA + AFR->AFR_TIPO + AFR->AFR_FORNEC + AFR->AFR_LOJA ) ) .And. ;
					SE2->E2_EMIS1 < dDataRef

				aCusto[1] += AFR->AFR_VALOR1
				aCusto[2] += AFR->AFR_VALOR2
				aCusto[3] += AFR->AFR_VALOR3
				aCusto[4] += AFR->AFR_VALOR4
				aCusto[5] += AFR->AFR_VALOR5
			EndIf
			dbSelectArea("AFR")
			dbSkip()
		End
		dbSelectArea("AF9")
		dbSkip()
	End
End

For x := 1 to Len(aArea)
	RestArea(aArea[x])
Next

Return aCusto[nMoeda]

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³dPertence ³ Autor ³ Michel Dantas       ³ Data ³12/11/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a data esta no intervalo indicado            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function dPertence(dInicio,dFim,dCompi,dCompf)
Local nTotal := 0
Local aPert  := Array(2)

aPert[1] := Max(dInicio,dCompi)
aPert[2] := Min(dFim,dCompf)
nTotal := aPert[2] - aPert[1]
	
If nTotal < 0
	nTotal := 0
EndIf

Return nTotal

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms2TreeEDT³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta o Tree do Projeto por EDT                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Funcao Incluida provisoriamente. Edson 08/04/02
Function PMS2TreeEDT(oTree,cVersao,aEstrutura,cFilhos,bCondicao,lReset,cRevisao)

Local lTree		:= aEstrutura = Nil
Local aArea		:= GetArea()
Local lViewCod	:= .F.

DEFAULT cVersao 	:= AF8->AF8_REVISA
DEFAULT cFilhos 	:= "AF8,AFC,AF9,AFA,AFB,AFD"// Alias que sao amarrados ao TREE
DEFAULT bCondicao 	:= { || .T. }     				// Utilizado para filtro conteudo
DEFAULT lReset 		:= .T.                                                    
DEFAULT cRevisao    := CriaVar("AF8_REVISA",.F.)

If lTree
	If lReset
		oTree:BeginUpdate()
		oTree:Reset()
		oTree:EndUpdate()
	EndIf
	oTree:BeginUpdate()	
	Do Case
		Case !Empty(AF8->AF8_DTATUF)
			DBADDTREE oTree PROMPT OemToAnsi(AF8->AF8_DESCRI);
						RESOURCE BMP_EDT4,BMP_EDT4;
						CARGO "AF8"+StrZero(AF8->(RecNo()),12) OPEN
		Case !Empty(AF8->AF8_DTATUI)
			DBADDTREE oTree PROMPT OemToAnsi(AF8->AF8_DESCRI);
						RESOURCE BMP_EDT2,BMP_EDT2;
						CARGO "AF8"+StrZero(AF8->(RecNo()),12) OPEN
		Case dDataBase > AF8->AF8_START
			DBADDTREE oTree PROMPT OemToAnsi(AF8->AF8_DESCRI);
						RESOURCE BMP_EDT1,BMP_EDT1;
						CARGO "AF8"+StrZero(AF8->(RecNo()),12) OPEN
		OtherWise
			DBADDTREE oTree PROMPT OemToAnsi(AF8->AF8_DESCRI);
						RESOURCE BMP_EDT3,BMP_EDT3;
						CARGO "AF8"+StrZero(AF8->(RecNo()),12) OPEN
	EndCase		
ElseIf Alias() $ cFilhos
	Aadd(aEstrutura, { { AllTrim(AF8->AF8_PROJET), AF8->AF8_DESCRI, AF8->(RecNo()), "AF8", 0, 1 } })
ElseIf ! lTree	
	Aadd(aEstrutura, {})
Endif

dbSelectArea("AFC")
dbSetOrder(3) //AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_NIVEL
MsSeek(xFilial()+AF8->AF8_PROJET+cVersao+"001")
While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
					AFC->AFC_NIVEL==xFilial("AFC")+AF8->AF8_PROJET+cVersao+"001"
	PMSEDTTrf(@oTree,AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,;
      		If(lTree,, aEstrutura[Len(aEstrutura)]), cFilhos, bCondicao,, 2,lViewCod,cRevisao)
	dbSkip()
End


If lTree
	DBENDTREE oTree
	oTree:EndUpdate()
	oTree:Refresh()
Endif


RestArea(aArea)

Return If(lTree,, aEstrutura)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSEDTTrf³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta o a Tarefa no Tree do Projeto.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Funcao Incluida provisoriamente. Edson 08/04/02
Static Function PMSEDTTrf(oTree,cChave,aEstrutura,cFilhos,bCondicao,nPaiMat,nNivel,lViewCod,cRevisao)

Local nx		:= 0
Local lTipoTree	:= .F.
Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local aAuxArea  := {}
Local aDocAFC	:= {}
Local cResAFC   := ""
Local lTree  	:= aEstrutura = Nil
Local nPaiEdt 	:= If("AF8" $ cFilhos, 1, 0)
Local lIncTree	:= PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,1,"ESTRUT",cRevisao)
Local bAddAfC	:= { |nPaiMat,nNivel| If(Eval(bCondAdd),;
						 Aadd(aEstrutura, { AllTrim(AFC->AFC_EDT), AFC->AFC_DESCRI,;
						 				     AFC->(RecNo()), "AFC", nPaiMat, nNivel }), .F.) }

Private bCondAdd := bCondicao

DEFAULT nPaiMat	:= 1

If lTree
	Do Case
		Case !Empty(AFC->AFC_DTATUF)
			cResAFC	:= BMP_EDT4
		Case !Empty(AFC->AFC_DTATUI)
			cResAFC	:= BMP_EDT2
		Case dDataBase > AFC->AFC_START
			cResAFC	:= BMP_EDT1
		OtherWise
			cResAFC	:= BMP_EDT3
	EndCase
EndIf

If lIncTree
	If "USR"$cFilhos
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Insere os usuarios do Projeto no Tree                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AFX")
		dbSetOrder(1)
		MsSeek(xFilial()+AFC->AFC_PROJET+cRevisao+AFC->AFC_EDT)
		While !Eof() .And. AFX->AFX_FILIAL+AFX->AFX_PROJET+AFX->AFX_REVISA+AFX->AFX_EDT==xFilial()+AFC->AFC_PROJET+cRevisao+AFC->AFC_EDT
			If !lTipoTree
				If lTree
					If lViewCod
						DBADDTREE oTree PROMPT Alltrim(AFC->AFC_EDT)+"-"+Alltrim(Substr(AFC->AFC_DESCRI,1,50))+ " - POC : "+TransForm(PmsPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,PMS_MAX_DATE),"@E 999.99%"); 
										RESOURCE cResAFC,cResAFC;
										CARGO "AFC"+StrZero(AFC->(RecNo()),12)
					Else
						DBADDTREE oTree PROMPT Alltrim(Substr(AFC->AFC_DESCRI,1,50))+ " - POC : "+TransForm(PmsPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,PMS_MAX_DATE),"@E 999.99%"); 
										RESOURCE cResAFC,cResAFC;
										CARGO "AFC"+StrZero(AFC->(RecNo()),12)
					EndIf
				EndIf
				lTipoTree := .T.
			EndIf
			DBADDITEM oTree PROMPT UsrRetName(AFX->AFX_USER) RESOURCE BMP_USER_PQ;
						CARGO "AFX"+StrZero(AFX->(RecNo()),12)
			dbSkip()
		End
	EndIf
EndIf

If lIncTree 
	If "ACB"$cFilhos .And. PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,2,"DOCUME",cRevisao)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Insere os documentos da EDT no Tree                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsDocument("AFC",AFC->(RecNo()),3,,4,@aDocAFC)
		For nx := 1 to Len(aDocAFC)
			ACB->(dbGoto(aDocAFC[nx]))
			If !lTipoTree
				nPaiEdt := If("AF8" $ cFilhos, 1, 0)
				If lTree
					If lViewCod
						DBADDTREE oTree PROMPT Alltrim(AFC->AFC_EDT)+"-"+Alltrim(Substr(AFC->AFC_DESCRI,1,50))+ " - POC : "+TransForm(PmsPOCAFC(AFC_PROJET,AFC_REVISA,AFC_EDT,PMS_MAX_DATE),"@E 999.99%"); 
										RESOURCE cResAFC,cResAFC;
										CARGO "AFC"+StrZero(AFC->(RecNo()),12)
					Else
						DBADDTREE oTree PROMPT Alltrim(Substr(AFC->AFC_DESCRI,1,50))+ " - POC : "+TransForm(PmsPOCAFC(AFC_PROJET,AFC_REVISA,AFC_EDT,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
										RESOURCE cResAFC,cResAFC;
										CARGO "AFC"+StrZero(AFC->(RecNo()),12)
					EndIf
				ElseIf ("AFC" $ cFilhos) .And. AFC->(Eval(bCondAdd))
					AFC->(Eval(bAddAfc, nPaiMat, nNivel))
					nPaiEdt := Len(aEstrutura)
					nNivel ++
				Endif
				lTipoTree := .T.
			EndIf
			If lTree
				DBADDITEM oTree PROMPT Substr(ACB->ACB_DESCRI,1,50) RESOURCE BMP_DOCUMENT CARGO "ACB"+StrZero(ACB->(RecNo()),12)
			EndIf
		Next
	EndIf
EndIf	

dbSelectArea("AF9")
dbSetOrder(2)
MsSeek(xFilial()+cChave)
While !Eof() .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+;
					AF9->AF9_EDTPAI==xFilial("AF9")+cChave
	If lIncTree
		If !lTipoTree
			nPaiEdt := If("AF8" $ cFilhos, 1, 0)
			If lTree
				If lViewCod
					DBADDTREE oTree PROMPT Alltrim(AFC->AFC_EDT)+"-"+AllTrim(Substr(AFC->AFC_DESCRI,1,50))+ " - POC : "+TransForm(PmsPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
									RESOURCE cResAFC,cResAFC;
									CARGO "AFC"+StrZero(AFC->(RecNo()),12)
				Else
					DBADDTREE oTree PROMPT AllTrim(Substr(AFC->AFC_DESCRI,1,50))+ " - POC : "+TransForm(PmsPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
									RESOURCE cResAFC,cResAFC;
									CARGO "AFC"+StrZero(AFC->(RecNo()),12)
	
				EndIf
			ElseIf ("AFC" $ cFilhos) .And. AFC->(Eval(bCondAdd))
				AFC->(Eval(bAddAfc, nPaiMat, nNivel))
				nPaiEdt := Len(aEstrutura)
				nNivel ++
			Endif
			lTipoTree := .T.
		EndIf
	EndIf
	If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",cRevisao)
		PMSAddTrf(@oTree,AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA, aEstrutura,;
					cFilhos, bCondicao,nPaiEdt,nNivel,lViewCod,cRevisao)
	EndIf
	dbSkip()
End	

dbSelectArea("AFC")
dbSetOrder(2)
MsSeek(xFilial()+cChave)
While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
					AFC->AFC_EDTPAI==xFilial("AFC")+cChave
	aAuxArea	:= GetArea()
	RestArea(aAreaAFC)	
	If lIncTree
		If !lTipoTree
			If lTree
				If lViewCod
					DBADDTREE oTree PROMPT Alltrim(AFC->AFC_EDT)+"-"+Substr(AFC->AFC_DESCRI,1,50);
									RESOURCE cResAFC,cResAFC;
									CARGO "AFC"+StrZero(AFC->(RecNo()),12)
				Else
					DBADDTREE oTree PROMPT Substr(AFC->AFC_DESCRI,1,50);
									RESOURCE cResAFC,cResAFC;
									CARGO "AFC"+StrZero(AFC->(RecNo()),12)
				EndIf
			ElseIf "AFC" $ cFilhos .And. AFC->(Eval(bCondAdd))
				AFC->(Eval(bAddAfc, nPaiMat, nNivel))
				nPaiEdt := Len(aEstrutura)
				nNivel ++
			Endif
			lTipoTree := .T.
		EndIf
	EndIf
	RestArea(aAuxArea)
	PMSEDTTrf(@oTree,AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT, aEstrutura,;
				cFilhos, bCondicao,nPaiEdt,nNivel,lViewCod,cRevisao)
	dbSkip()
EndDo

RestArea(aAreaAFC)

If lTipoTree
	If lTree
		DBENDTREE oTree
	Endif
Else
	If lTree
		If lIncTree	
			If lViewCod
				DBADDITEM oTree PROMPT Alltrim(AFC->AFC_EDT)+"-"+Substr(AFC->AFC_DESCRI,1,50) RESOURCE cResAFC CARGO "AFC"+StrZero(AFC->(RecNo()),12)
			Else
				DBADDITEM oTree PROMPT Substr(AFC->AFC_DESCRI,1,50) RESOURCE cResAFC CARGO "AFC"+StrZero(AFC->(RecNo()),12)
			EndIf
		EndIf
	ElseIf "AFC" $ cFilhos .And. AFC->(Eval(bCondAdd))
		AFC->(Eval(bAddAfc, nPaiMat, nNivel))
	Endif			
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAddTrf³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta a tarefa no Tree do Projeto.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSXFUN                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Funcao Incluida provisoriamente. Edson 08/04/02
Static Function PmsAddTrf(oTree,cChave,aEstrutura,cFilhos,bCondicao,nPaiEdt,nNivel,lViewCod,cRevisao)

Local nx
Local aDocAF9	:= {}
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFA	:= AFA->(GetArea())
Local aAreaAFB	:= AFB->(GetArea())
Local aAreaAFC	:= AFC->(GetArea())
Local lTipoTree	:= .F.
Local bAddAf9	:= { |nPaiEdt,nNivel| If(Eval(bCondAdd),;
						 Aadd(aEstrutura, { 	AllTrim(AF9->AF9_TAREFA),;
						 						AF9->AF9_DESCRI,;
						 				     	AF9->(RecNo()), "AF9", nPaiEdt, nNivel }), .F.) }
Local lTree  	:= aEstrutura = Nil
Local nPaiTrf 	:= 0
Local lRecurso	:= "AE8" $ cFilhos, nRecurso := 0
local lAglutina := "AGLUTINA" $ cFilhos
local lTodoProjeto:= "TODO_PROJETO" $ cFilhos
Local lIncTree	:= PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,1,"ESTRUT",cRevisao)
Local cResAF9

Private bCondAdd := bCondicao

If lTree
	Do Case
		Case !Empty(AF9->AF9_DTATUF)
			cResAF9	:= "PMSTASK3"
		Case !Empty(AF9->AF9_DTATUI)
			cResAF9	:= "PMSTASK2"
		Case dDataBase > AF9->AF9_START
			cResAF9	:= "PMSTASK1"
		OtherWise
			cResAF9	:= "PMSTASK4"
	EndCase
EndIf

If lIncTree
	If "USR"$cFilhos
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Insere os usuarios do Projeto no Tree                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AFV")
		dbSetOrder(1)
		MsSeek(xFilial("AFV")+AF9->AF9_PROJET+cRevisao+AF9->AF9_TAREFA)
		While !Eof() .And. AFV->AFV_FILIAL+AFV->AFV_PROJET+AFV->AFV_REVISA+AFV->AFV_TAREFA==xFilial("AFV")+AF9->AF9_PROJET+cRevisao+AF9->AF9_TAREFA
			If !lTipoTree
				nPaiTrf := If("AF8" $ cFilhos, 1, 0)
				If lTree
					If lViewCod
							DBADDTREE oTree PROMPT AllTrim(AF9->AF9_TAREFA)+"-"+AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
											RESOURCE cResAF9,cResAF9;
											CARGO "AF9"+StrZero(AF9->(RecNo()),12)
					Else
							DBADDTREE oTree PROMPT AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
											RESOURCE cResAF9,cResAF9;
											CARGO "AF9"+StrZero(AF9->(RecNo()),12)
					EndIf
				ElseIf "AF9" $ cFilhos .And. AF9->(Eval(bCondAdd))
					AF9->(Eval(bAddAf9, nPaiEdt, nNivel))
					nPaiTrf := Len(aEstrutura)
				Endif							
				lTipoTree := .T.
			EndIf

			DBADDITEM oTree PROMPT UsrRetName(AFV->AFV_USER) RESOURCE BMP_USER_PQ;
						CARGO "AFV"+StrZero(AFV->(RecNo()),12)
			dbSkip()
		End
	EndIf
EndIf

If "ACB"$cFilhos .And. PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"DOCUME",cRevisao)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Insere os documentos da Tarefa no Tree                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsDocument("AF9",AF9->(RecNo()),3,,4,@aDocAF9)
	For nx := 1 to Len(aDocAF9)
		If !lTipoTree
			nPaiTrf := If("AF8" $ cFilhos, 1, 0)
			If lTree
				If lViewCod
					DBADDTREE oTree PROMPT AllTrim(AF9->AF9_TAREFA)+"-"+AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
									RESOURCE cResAF9,cResAF9;
									CARGO "AF9"+StrZero(AF9->(RecNo()),12)
				Else
					DBADDTREE oTree PROMPT AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
									RESOURCE cResAF9,cResAF9;
									CARGO "AF9"+StrZero(AF9->(RecNo()),12)
				EndIf
			ElseIf "AF9" $ cFilhos .And. AF9->(Eval(bCondAdd))
				AF9->(Eval(bAddAf9, nPaiEdt, nNivel))
				nPaiTrf := Len(aEstrutura)
			Endif							
			lTipoTree := .T.
		EndIf
		ACB->(dbGoto(aDocAF9[nx]))
		If lTree
			DBADDITEM oTree PROMPT Substr(ACB->ACB_DESCRI,1,50) RESOURCE BMP_DOCUMENT CARGO "ACB"+StrZero(ACB->(RecNo()),12)
		EndIf
	Next
EndIf
	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui os produtos da tarefa AFA                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SB1->(dbSetOrder(1))
dbSelectArea("AFA")
dbSetOrder(1)
MsSeek(xFilial()+cChave)
While !Eof() .And. AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+;
					AFA->AFA_TAREFA==xFilial("AFA")+cChave .And.;
					(Alias() $ cFilhos .Or. lRecurso)
	If !lTipoTree
		nPaiTrf := If("AF8" $ cFilhos, 1, 0)
		If lTree
			If lViewCod
					DBADDTREE oTree PROMPT AllTrim(AF9->AF9_TAREFA)+"-"+AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
									RESOURCE cResAF9,cResAF9;
									CARGO "AF9"+StrZero(AF9->(RecNo()),12)
			Else
					DBADDTREE oTree PROMPT AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
									RESOURCE cResAF9,cResAF9;
									CARGO "AF9"+StrZero(AF9->(RecNo()),12)
			EndIf
		ElseIf "AF9" $ cFilhos .And. AF9->(Eval(bCondAdd))
			AF9->(Eval(bAddAf9, nPaiEdt, nNivel))
			nPaiTrf := Len(aEstrutura)
		Endif							
		lTipoTree := .T.
	EndIf
	SB1->(MsSeek(xFilial()+AFA->AFA_PRODUT))
	If lTree
		If !Empty(AFA->AFA_RECURS)
			DBADDITEM oTree PROMPT Subs(SB1->B1_DESC,1,30) RESOURCE BMP_USER_PQ;
							CARGO "AFA"+StrZero(AFA->(RecNo()),12)
		Else
			DBADDITEM oTree PROMPT Subs(SB1->B1_DESC,1,30) RESOURCE BMP_MATERIAL;
							CARGO "AFA"+StrZero(AFA->(RecNo()),12)
		EndIf
	ElseIf Eval(bCondAdd)
		If lRecurso
			AE8->(DbSeek(xFilial("AE8") + AFA->AFA_RECURS))
			If (nRecurso := Ascan(aEstrutura, { |X| 	X[1] = AllTrim(AFA->AFA_RECURS) 	.And.;
														X[4] = "AE8" 						.And.;
														X[10] = AFA->AFA_CUSTD			 	.And.;
														X[11] = "AFA" 						.And.;
  													  If(lTodoProjeto, .T.,;
  														X[9] = AFA->AFA_TAREFA ) })) > 0
 				Aadd(aEstrutura[nRecurso][8], { "AFA", AFA->(Recno()) } )
 			Else
				Aadd(aEstrutura, { 	AllTrim(AFA->AFA_RECURS), AE8->AE8_DESCRI,;
									AE8->(Recno()), "AE8", nPaiTrf, nNivel,,;
									{ { "AFA", AFA->(RecNo()) } },;
									AFA->AFA_TAREFA, AFA->AFA_CUSTD, "AFA" })
			Endif									
		Else
			If lAglutina
				If (nRecurso := Ascan(aEstrutura, { |X|	X[1] = AllTrim(AFA->AFA_PRODUT) 	.And.;
															X[4] = "AFA" 						.And.;			
															X[10] = AFA->AFA_CUSTD	 			.And.;			
  														 If(lTodoProjeto, .T.,;
  														 	X[9] = AFA->AFA_TAREFA ) })) > 0
	 				Aadd(aEstrutura[nRecurso][8], { "AFA", AFA->(Recno()) } )
	 			Else
					Aadd(aEstrutura, { 	AllTrim(AFA->AFA_PRODUT), Subs(SB1->B1_DESC,1,30),;
										AFA->(RecNo()), "AFA", nPaiTrf, nNivel,,;
										{ { "AFA", AFA->(Recno()) } },;
										AFA->AFA_TAREFA, AFA->AFA_CUSTD })
				Endif
			Else
				Aadd(aEstrutura, { 	AllTrim(AFA->AFA_PRODUT), Subs(SB1->B1_DESC,1,30),;
									AFA->(RecNo()), "AFA", nPaiTrf, nNivel })
			Endif
		Endif								
	Endif
	dbSkip()
End	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui as despesas da tarefa AFB                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AFB")
dbSetOrder(1)
MsSeek(xFilial()+cChave)
While !Eof() .And. AFB->AFB_FILIAL+AFB->AFB_PROJET+AFB->AFB_REVISA+;
					AFB->AFB_TAREFA==xFilial("AFB")+cChave .And.;
					(Alias() $ cFilhos .Or. lRecurso)
	If !lTipoTree
		nPaiTrf := If("AF8" $ cFilhos, 1, 0)
		If lTree
			If lViewCod
				DBADDTREE oTree PROMPT AllTrim(AF9->AF9_TAREFA)+"-"+AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
								RESOURCE cResAF9,cResAF9;
								CARGO "AF9"+StrZero(AF9->(RecNo()),12)
			Else
				DBADDTREE oTree PROMPT AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
								RESOURCE cResAF9,cResAF9;
								CARGO "AF9"+StrZero(AF9->(RecNo()),12)
			EndIf
		ElseIf "AF9" $ cFilhos .And. AF9->(Eval(bCondAdd))
			AF9->(Eval(bAddAf9, nPaiEdt, nNivel))
			nPaiTrf := Len(aEstrutura)
		Endif							
		lTipoTree := .T.
	EndIf
	If lTree
		DBADDITEM oTree PROMPT AFB->AFB_DESCRI RESOURCE BMP_BUDGET;
						CARGO "AFB"+StrZero(AFB->(RecNo()),12)
	ElseIf Eval(bCondAdd)
		If lRecurso
			AE8->(DbSeek(xFilial("AE8") + AFB->AFB_RECURS))
			If (nRecurso := Ascan(aEstrutura, { |X|  	X[1] = AllTrim(AFB->AFB_RECURS)	.And.;
														X[4] = "AE8" 						.And.;
														X[11] = "AFB" 						.And.;
  													 If(lTodoProjeto, .T.,;
														X[9] = AFB->AFB_TAREFA ) })) > 0
 				Aadd(aEstrutura[nRecurso][8], { "AFB", AFB->(Recno()) } )
 			Else
				Aadd(aEstrutura, { 	AllTrim(AFB->AFB_RECURS), AE8->AE8_DESCRI,;
									AE8->(Recno()), "AE8",;
									nPaiTrf, nNivel,, { { "AFB", AFB->(RecNo()) } },;
									AFB->AFB_TAREFA, AFB->AFB_VALOR, "AFB" })
			Endif
		Else
			If lAglutina
				If (nRecurso := Ascan(aEstrutura, { |X| 	X[2] = AFB->AFB_DESCRI 		.And.;
															X[4] = "AFB" 				.And.;			
															If(lTodoProjeto, .T.,;
															X[9] = AFB->AFB_TAREFA ) })) > 0
	 				Aadd(aEstrutura[nRecurso][8], { "AFB", AFB->(Recno()) } )
	 			Else
					Aadd(aEstrutura, { 	"", AFB->AFB_DESCRI, AFB->(RecNo()), "AFB",;
 										nPaiTrf, nNivel,, { { "AFB", AFB->(Recno()) } },;
										AFB->AFB_TAREFA })
				Endif
			Else
				Aadd(aEstrutura, { 	"", AFB->AFB_DESCRI, AFB->(RecNo()),;
									"AFB", nPaiTrf, nNivel })
			Endif
		Endif								
	Endif
	dbSkip()
End	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui os Relacionamentos    AFD                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AFD")
dbSetOrder(1)
MsSeek(xFilial()+cChave)
While !Eof() .And. AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+;
					AFD->AFD_TAREFA==xFilial("AFD")+cChave .And.;
					Alias() $ cFilhos
	If !lTipoTree
		nPaiTrf := If("AF8" $ cFilhos, 1, 0)
		If lTree
			If lViewCod
				DBADDTREE oTree PROMPT AllTrim(AF9->AF9_TAREFA)+"-"+AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
								RESOURCE cResAF9,cResAF9;
								CARGO "AF9"+StrZero(AF9->(RecNo()),12)
			Else
				DBADDTREE oTree PROMPT AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
								RESOURCE cResAF9,cResAF9;
								CARGO "AF9"+StrZero(AF9->(RecNo()),12)
			EndIf
		ElseIf "AF9" $ cFilhos .And. AF9->(Eval(bCondAdd))
			AF9->(Eval(bAddAf9, nPaiEdt, nNivel))
			nPaiTrf := Len(aEstrutura)
		Endif
		lTipoTree := .T.
	EndIf
	aAuxArea := AF9->(GetArea())
	AF9->(dbSetOrder(1))
	AF9->(MsSeek(xFilial()+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC))
	If lTree
		DBADDITEM oTree PROMPT AF9->AF9_DESCRI RESOURCE BMP_RELACIONAMENTO_DIREITA;
						CARGO "AFD"+StrZero(AFD->(RecNo()),12)
	ElseIf Eval(bCondAdd)
		Aadd(aEstrutura, { 	AllTrim(AFD->AFD_TAREFA), AF9->AF9_DESCRI,;
							AFD->(RecNo()), "AFD", nPaiTrf, nNivel })
	Endif
	RestArea(aAuxArea)
	dbSelectArea("AFD")
	dbSkip()
EndDo

If lTipoTree 
	If lTree
		DBENDTREE oTree
	Endif			
Else
	If lTree
		If lViewCod
			DBADDITEM oTree PROMPT AllTrim(AF9->AF9_TAREFA)+"-"+AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
							RESOURCE cResAF9 CARGO "AF9"+StrZero(AF9->(RecNo()),12)
		Else
			DBADDITEM oTree PROMPT AllTrim(Substr(AF9->AF9_DESCRI,1,50))+" - POC : "+TransForm(PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE),"@E 999.99%"); //" - POC : "
							RESOURCE cResAF9 CARGO "AF9"+StrZero(AF9->(RecNo()),12)
		EndIf
	ElseIf "AF9" $ cFilhos .And. AF9->(Eval(bCondAdd))
		AF9->(Eval(bAddAf9, nPaiEdt, nNivel))
	Endif
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFA)
RestArea(aAreaAFB)
RestArea(aAreaAFC)
RestArea(aArea)

Return
