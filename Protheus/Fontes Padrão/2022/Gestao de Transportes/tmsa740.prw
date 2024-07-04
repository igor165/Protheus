#include "TMSA740.CH"
#include "Protheus.ch"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA740   ³ Autor ³Patricia A. Salomao    ³ Data ³01.03.2003  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pagamento de Premio                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGATMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TMSA740()

Local cAtivChg   := GetMV("MV_ATIVCHG",,'')
Local cAtivSai   := GetMV("MV_ATIVSAI",,'')                   
Local cRotGen    := GETMV('MV_ROTGTAB',,'')
Local lInvert    := .F.
Local lGerPremio := .F.   
Local lOk        := .F.
Local aSays      := {}
Local aButtons   := {}
Local aCampos    := {}
Local aMsgErr    := {}
Local aVisErr    := {}
Local aRet       := {}
Local aFrete     := {}                      
Local aDadosTot  := {}
Local aAreaDTQ   := {}
Local cCadastro  := STR0001 //'Informe o Premio para Motoristas'
Local cCond      := cSeek      := cHorChg := cHorChgReal := cSeekDUP := ''
Local nValCalc   := nOpca  	 := nOpc 	:= 0 
Local nDiaSem    := nDiaFimSem := nQtdKm  := nQtdMot := 0 
Local nQtdOco    := nPesOco    := nQtdDoc := 0
Local dDatChg, dDatChgReal, dDatIni, dDatFim
Local o1Get, oDlg    
Local nCntFor
Local nCnt
Local nValPedag   := 0
Local cCusMed     := GetMv("MV_CUSMED")
Local aHlpPor1    :=  {}
Local aHlpEsp1    :=  {}
Local aHlpEng1    :=  {}
Local aHlpPor2    :=  {}
Local aHlpEsp2    :=  {}
Local aHlpEng2    :=  {}
Local aHlpPor3    :=  {}
Local aHlpEsp3    :=  {}
Local aHlpEng3    :=  {}
Local aMsgCal     :=  {}
Local aSX5		  :=  {}
Local cTabFre     := ''
Local cTipTab     := ''
Local cTabCar     := ''
Local cAliasDTQ   := ""
Local cQuery      := ""
Local lRet        := .T.   
Local aCabSDG		:= {} 

Private aHeader    := {}
Private aCols      := {}
Private cUniao     := GetMV("MV_UNIAO")  // Cod. para Pagto. do Imposto de Renda
Private cNatuCTC   := Padr( GetMV("MV_NATCTC"), Len( SE2->E2_NATUREZ ) ) // Natureza Contrato de Carreteiro
Private cNatuPDG   := Padr( GetMV("MV_NATPDG"), Len( SE2->E2_NATUREZ ) ) // Natureza Pedagio
Private cNatuDeb   := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
Private cTipCTC    := Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro
Private cTipPDG    := Padr( GetMV("MV_TPTPDG"), Len( SE2->E2_TIPO ) )    // Tipo Pedagio
Private cTipPre    := Padr( GetMV("MV_TPTPRE"), Len( SE2->E2_TIPO ) )    // Tipo Premio
Private cCodDesCTC := Padr( GetMV("MV_DESCTC"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de contrato de carreteiro 
Private cCodDesPDG := Padr( GetMV("MV_DESPDG"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Pedagio                
Private cCodDesPRE := Padr( GetMV("MV_DESPRE"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Premio
Private cArqTrab   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o custo medio e' calculado On Line               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCusMed == "O"
	Private nHdlPrv            // Endereco do arquivo de contra prova dos lanctos cont.
	Private lCriaHeader := .T. // Para criar o header do arquivo Contra Prova
	Private cLoteTMS 	         // Numero do lote para lancamentos do TMS     
	Private nTotal      := 0	// Total dos lancamentos contabeis
	Private cArquivo           // Nome do arquivo contra prova	
	Private aRecSDGBai  := {}  // Contabiliza a partir da Baixa da Despesa
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona numero do Lote para Lancamentos do Estoque         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSX5 := FWGetSX5("09","TMS")
	cLoteTMS:=IIF(!Empty(aSX5),aSX5[1][4],"TMS ")	
EndIf

//Verifica o prenchimento de alguns parametros necessarios para se gerar o Contrato
If !TMA250Param(.T.,cNatuPDG,cNatuDeb,cTipPDG,cTipCTC)
	Return( .F. )
EndIf	

aRotina		:= {	{ STR0002,"AxPesqui", 0, 1 },; 	//"Pesquisar"
						{ STR0003,"AxVisual", 0, 2 },; 	//"Visualizar"
						{ STR0004,"AxInclui", 0, 3 },;  	//"Incluir"
						{ STR0005,"AxAltera", 0, 4 },;  	//"Alterar"
						{ STR0006,"AxExclui", 0, 5 }} 	//"Excluir"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Fil. Origem De  ?                        		     ³
//³ mv_par02 - Fil. Origem Ate ?                                 ³
//³ mv_par03 - Viagem De       ?                                 ³
//³ mv_par04 - Viagem Ate      ?                                 ³
//³ mv_par05 - Dt.Encerr.De    ?                                 ³
//³ mv_par06 - Dt.Encerr.Ate   ?                                 ³
//³ mv_par07 - Gera Premio p/ Fornecedor: 1 = Proprio            ³
//³                                       2 = Terceiro / Agregado³ 
//³ mv_par08 - Mostra lancamentos contabeis    ?                 ³
//³ mv_par09 - Aglutina lancamentos contabeis  ?                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("TMA740",.F.)

Aadd( aSays,STR0007) //"Este programa tem como finalidade gerar os Contratos de Premio de Carreteiro"

Aadd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() } } )
Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
Aadd( aButtons, { 5, .T., {|| Pergunte("TMA740",.T.) } } )
	
FormBatch(STR0008, aSays, aButtons ) //"Pagamento de Premio"
   
If nOpca <> 1	    
	Return( .F. )
EndIf

//-- Estrutura do Arquivo de Trabalho que sera mostrado na GetDados()
AADD(aCampos,{ "FILORI" , "C", FWGETTAMFILIAL, 0 })
AADD(aCampos,{ "VIAGEM" , "C", Len(DTQ->DTQ_VIAGEM), 0 })
AADD(aCampos,{ "SERTMS" , "C", 15                  , 0 })
AADD(aCampos,{ "CODFOR" , "C", Len(DA3->DA3_CODFOR), 0 })
AADD(aCampos,{ "LOJFOR" , "C", Len(DA3->DA3_LOJFOR), 0 })
AADD(aCampos,{ "NOMFOR" , "C", 30                  , 0 })
If mv_par07 == 1 // Gera Contrato de Premio para Motorista Proprio
	AADD(aCampos,{ "KMS" , "N", 11,  2 })
	AADD(aCampos,{ "CODMOT" , "C", Len(DA4->DA4_COD), 0 })	
	AADD(aCampos,{ "NOMMOT" , "C", Len(SA1->A1_NOME), 0 })		
EndIf
AADD(aCampos,{ "VALCAL" , "N", 11 , 2 })
AADD(aCampos,{ "VALPRE" , "N", 11 , 2 })
AADD(aCampos,{ "TABFRE" , "C", Len(DVG->DVG_TABFRE) , 0 })
AADD(aCampos,{ "TIPTAB" , "C", Len(DVG->DVG_TIPTAB) , 0 })
AADD(aCampos,{ "TABCAR" , "C", Len(DVG->DVG_TABCAR) , 0 })

cArqTrab := GetNextAlias()
oTempTable := FWTemporaryTable():New(cArqTrab)
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("01", {"FILORI","VIAGEM"} )
oTempTable:Create()


cAliasDTQ := GetNextAlias()                        
cQuery := 'SELECT R_E_C_N_O_ RECNODTQ FROM '
cQuery += RetSqlName("DTQ")
cQuery += "  WHERE DTQ_FILIAL = '"  + xFilial("DTQ") + "' "
cQuery += "    AND DTQ_FILORI >= '"  + MV_PAR01 + "' "
cQuery += "    AND DTQ_FILORI <= '"  + MV_PAR02 + "' "
cQuery += "    AND DTQ_VIAGEM >= '"  + MV_PAR03 + "' "
cQuery += "    AND DTQ_VIAGEM <= '"  + MV_PAR04 + "' "
cQuery += "    AND DTQ_DATENC BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
cQuery += "    AND DTQ_STATUS = '"  + StrZero(3,Len(DTQ->DTQ_STATUS)) + "' "
cQuery += "    AND D_E_L_E_T_ = ' ' "
cQuery += "    ORDER BY DTQ_FILORI, DTQ_VIAGEM "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDTQ, .F., .T.)
If (cAliasDTQ)->(Eof())
	Help("",1,"REGNOIS") //"Nao existe registro relacionado a este codigo"
	lRet:= .F.
EndIf

If lRet
	While (cAliasDTQ)->(!Eof())
		DTQ->(dbGoTo((cAliasDTQ)->RECNODTQ))

	   lGerPremio := .F.
	   
	   //-- Verifica se ja existe Contrato de Premio para a Viagem   
	   If mv_par07 == 2 // Gera Contrato de Carreteiro para Motorista Terceiro/Agregado
			DTY->(dbSetOrder(2))
			DTY->(MsSeek(cSeek := xFilial("DTY")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
			Do While !DTY->(Eof()) .And. DTY->(DTY_FILIAL+DTY->DTY_FILORI+DTY->DTY_VIAGEM) == cSeek 
			   If DTY->DTY_TIPCTC == StrZero(3, Len(DTY->DTY_TIPCTC)) // Premio
		         lGerPremio := .T.
					AAdd( aMsgErr, {STR0010 + ' ' + DTY->DTY_FILORI + '/' + DTY->DTY_VIAGEM, '01', "TMSA250()" } ) //"Ja Foi Gerado Contrato de Premio para a Viagem"
					lRet:= .F.
		     		Exit
			   EndIf
				DTY->(dbSkip())
			EndDo  
			
			If lGerPremio
				lRet:= .F.
			EndIf  
		EndIf
		
		If lRet
			
			//-- Somente Gerar Contrato de Premio para proprietarios de veiculos "Terceiro" ou "Agregado"
			DTR->(dbSetOrder(1))
			If DTR->(MsSeek(cSeek := xFilial('DTR')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
				Do While !DTR->(Eof()) .And. DTR->DTR_FILIAL+DTR->DTR_FILORI+DTR->DTR_VIAGEM == cSeek
					lOk     := .F.
					nQtdMot :=  0		   
					
					If mv_par07 == 2 .And. Empty(DTR->DTR_TABCAR)
						AAdd( aMsgErr, {STR0011 + DTR->DTR_FILORI + '/' + DTR->DTR_VIAGEM + STR0012 + DTR->DTR_CODVEI, '01', "TMSA240()" } ) //"Tabela de Carreteiro não encontrada no complemento da Viagem: "###"Veiculo"
						DTR->(dbSkip())
						Loop
					EndIf				
					
					//-- Veiculo
					DA3->(dbSetOrder(1))
					DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODVEI))							                      																
					
					If mv_par07 == 2 // Gera Premio para Terceiro / Agregado			
						If DA3->DA3_FROVEI == "2" .Or. DA3->DA3_FROVEI == "3" 
							//-- Data e Hora de Chegada da Viagem	   	     	   	      					
			       	  	DTW->(dbSetOrder(7))
			         		DTW->(MsSeek(xFilial("DTW")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+cAtivChg+'zzzzzz',.T.))         	
			       		DTW->(dbSkip(-1))
			           	 If DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID) == xFilial("DTW")+DTR->DTR_FILORI+DTR->DTR_VIAGEM+cAtivChg
				         		dDatChg     := DTW->DTW_DATPRE  // Data Prevista de Chegada 
				         		cHorChg     := DTW->DTW_HORPRE  // Hora Prevista de Chegada
				         		dDatChgReal := DTW->DTW_DATREA  // Data Real de Chegada 	         		         	         	
				         		cHorChgReal := DTW->DTW_HORREA  // Hora Real de Chegada       		         	
				         	EndIf	                       	         	                                  	                                  
				         
							//-- Calcula o Numero de Horas entre dois tempos              	         
				         	nTmpCalc := SubtHoras(dDatChg,cHorChg,dDatChgReal,cHorChgReal)
				         
				         	//-- Converte Inteiro em Horas            
				         	If nTmpCalc < 0                     
					       	  cHora := IntToHora(HoraToInt(AllTrim(Str(ABS(nTmpCalc))))*-1, 3)	
				         	Else
					       	  cHora := IntToHora(HoraToInt(AllTrim(Str(nTmpCalc))), 3)	         
				         	EndIf	 
				         	//-- Procurar Premio com a Rota da Viagem e se nao achar, procurar pela Rota Generica
				         	DTM->(dbSetOrder(1))
				         	If !DTM->(MsSeek(cSeek:=xFilial("DTM")+DTR->DTR_TABCAR+DTQ->DTQ_ROTA))
						    	  DTM->(MsSeek(cSeek:=xFilial("DTM")+DTR->DTR_TABCAR+cRotGen))
						   	EndIf
						                          
						   	Do While !DTM->(Eof()) .And. DTM->DTM_FILIAL+DTM->DTM_TABCAR+DTM->DTM_ROTA==cSeek     
				           	lOk := .T.
				          		//-- Mesmo se o Tempo de duracao da Viagem NAO pagar premio, sera mostrado na GetDados
				            	//-- esta viagem com o Valor do premio Zerado, pois existem casos em que o premio
				            	//-- e' pago devido a uma justificativa do Motorista
				         		nValCalc := 0	            
				         	
				            	//-- Se o Tempo de duracao da Viagem pagar premio, calcular o Premio a Ser Pago 
				            	If cHora >= TransForm(DTM->DTM_PONTUA,PesqPict("DTM","DTM_PONTUA"))                    
				               //-- Tipo de Premio : 1 - Valor / 2 - Percentual	                
					         		If DTM->DTM_TIPPRE == "1" 		         		
					         			nValCalc := DTM->DTM_PREMIO
					         		Else  
					         	   	//-- Premio por Percentual		         	
					         			nValCalc := (DTR->DTR_VALFRE * DTM->DTM_PREMIO)/100	         	
					         		EndIf
					         		Exit
					         	EndIf    
								DTM->(dbSkip())
				         	EndDo  		         
						EndIf
					
						If lOk 
					  		//-- Gera arquivo de Trabalho contendo os dados da Viagem 
						  	TMSA740TRB(nValCalc, nQtdKm)
					   EndIf
						
					Else // Gera Premio para Motorista Proprio
					
						nValPedag := DTR->DTR_VALPDG
		
						DA4->(DbSetOrder(1))			
						DUP->(dbSetOrder(1))
						DUP->(MsSeek(cSeekDUP := xFilial('DUP')+DTR->(DTR_FILORI+DTR_VIAGEM+DTR_ITEM) ))
						Do While !DUP->(Eof()) .And. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR) == cSeekDUP			 	
						   lGerPremio := .F.
							DTY->(dbSetOrder(2))
							DTY->(MsSeek(cSeek := xFilial("DTY")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
							Do While !DTY->(Eof()) .And. DTY->(DTY_FILIAL+DTY->DTY_FILORI+DTY->DTY_VIAGEM) == cSeek 
							   If DTY->DTY_TIPCTC == StrZero(3, Len(DTY->DTY_TIPCTC)) .And. DTY->DTY_CODMOT == DUP->DUP_CODMOT
						         lGerPremio := .T.	//Ja gerou contrato de premio para este motorista				   
							  		Exit
							   EndIf
								DTY->(dbSkip())
							EndDo				  
						   
						   If lGerPremio
								DUP->(dbSkip())
						    	Loop
						   EndIf  
						   
		               	If DA4->(MsSeek(xFilial('DA4')+DUP->DUP_CODMOT )) .And. DA4->DA4_COMISS == StrZero(1, Len(DA4->DA4_COMISS))
		                  
								// Se existir mais de um motorista para a mesma viagem, o premio sera igual ao do 1o. motorista                  
								// Sendo assim, e' desnecessario efetuar os calculos novamente ...
		                  	If nQtdMot >= 1 
							  		//-- Gera arquivo de Trabalho contendo os dados da Viagem
								  	TMSA740TRB(nValCalc, nQtdKm, cTabFre, cTipTab, cTabCar)
								  	DUP->(dbSkip())   
								  	Loop
		                  	EndIf                                  
		                  
		                  	lOk        := .T.                                               
		                  	cTabFre    := ''
		                  	cTipTab    := ''
		                  	cTabCar    := ''
		                  	nValCalc   := 0                                                 
				           	nDiaSem    := 0
				           	nDiaFimSem := 0		            
				           	nQtdKm     := 0
			               	nQtdMot++	               	                  
			               
		  						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Estrutura do Array aRet                              ³
								//³ [1] - Tabela de Frete a Pagar                        ³
								//³ [2] - Tipo da Tabela de Frete                        ³
								//³ [3] - Valor do Frete                                 ³
								//³ [4] - Qtd. de Volumes informada no Reg. de Ocorrencia³				 
								//³ [5] - Peso informado no Reg. de Ocorrencia           ³						 
								//³ [6] - Qtd. de Documentos                             ³								 
								//³ [7] - Qtd. de Diarias (Semana)                       ³										 
								//³ [8] - Kms Percorridos                                ³										  
								//³ [9] - Qtd. de Diarias (Fim de Semana)                ³										 								
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					                                                  		
					         
								aAreaDA3 := DA3->(GetArea())
								aFrete   := {}
								aMsgCal  := {}
					         
								aRet := TMSCalFrePag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTR->DTR_CODVEI, aMsgCal, .T., aFrete )
		
								If Len(aMsgCal) > 0
									Aeval(aMsgCal, { | e | Aadd(aMsgErr,{ e[1], e[2], e[3] }) })
								EndIf
				            
								RestArea(aAreaDA3)
		                  
					         	If Len(aRet) > 0
					         		cTabFre		:= aRet[1][01] //-- Tabela de Frete
									cTipTab    	:= aRet[1][02] //-- Tipo da Tabela de Frete
									nValCalc   	:= aRet[1][03] //-- Valor do frete a Pagar
									nQtdOco		:= aRet[1][04] //-- Qtd. de Volumes
									nPesOco   		:= aRet[1][05] //-- Peso
									nQtdDoc   		:= aRet[1][06] //-- Qtd. de Documentos
									nDiaSem    	:= aRet[1][07] //-- No. Diarias (Semana)
									nQtdKm     	:= aRet[1][08] //-- Quilometragem percorrida Viagem
									nDiaFimSem 	:= aRet[1][09] //-- No. Diarias (Fim de Semana)
									cTabCar    	:= aRet[1][13] //-- Tabela de Carreteiro
					         	EndIf	                   
		 							                                    
								// Guarda em um Array auxiliar os Dados dos premios a serem gerados.
								// Este array sera' utilizado para guardar a Composicao do Frete e 
								// a qtde. de diarias e pernoites das viagens realizadas. 
								AAdd(aDadosTot,{DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DA4->DA4_COD,; 
													nDiaSem, nQtdKm, DTQ->DTQ_QTDPER, nDiaFimSem, nQtdOco,; 
		                                 nPesOco, nQtdDoc, Aclone(aFrete), nValPedag, DTR->DTR_CODVEI })
							   
							EndIf                                        
				
						   If lOk 
						  		//-- Gera arquivo de Trabalho contendo os dados da Viagem
							  	TMSA740TRB(nValCalc, nQtdKm, cTabFre, cTipTab, cTabCar)
						   EndIf					
						   DUP->(dbSkip())												
						EndDo
					EndIf          
							                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                	
					DTR->(dbSkip())
					
			   EndDo
			EndIf
		EndIf
			
		(cAliasDTQ)->(DbSkip())
	EndDo
	(cAliasDTQ)->(DbCloseArea())			                                                                              
EndIf
	

If Len(aMsgErr) > 0	
	AaddMsgErr( aMsgErr,@aVisErr )	
	If !Empty( aVisErr )
		TmsMsgErr( aVisErr )
		aVisErr := {}
	EndIf								
EndIf	

dbSelectArea(cArqTrab)
dbGotop()
If !(cArqTrab)->(Eof())                       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	aTam:=TamSX3("DTQ_FILORI")	
	Aadd(aHeader,{RetTitle("DTQ_FILORI"),"DTQ_FILORI" ,PesqPict("DTQ","DTQ_FILORI" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTQ"," "})
	aTam:=TamSX3("DTQ_VIAGEM")	
	Aadd(aHeader,{RetTitle("DTQ_VIAGEM"),"DTQ_VIAGEM" ,PesqPict("DTQ","DTQ_VIAGEM" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTQ"," "})
	aTam:=TamSX3("DTQ_SERTMS")	
	Aadd(aHeader,{RetTitle("DTQ_SERTMS"),"DTQ_SERTMS" ,Space(15) ,aTam[1],aTam[2]  ,"",USADO, "C" ,"DTQ"," "})	
	aTam:=TamSX3("DA3_CODFOR")	
	Aadd(aHeader,{RetTitle("DA3_CODFOR"),"DA3_CODFOR" ,PesqPict("DA3","DA3_CODFOR" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DA3"," "})		
	aTam:=TamSX3("DA3_LOJFOR")	
	Aadd(aHeader,{RetTitle("DA3_LOJFOR"),"DA3_LOJFOR" ,PesqPict("DA3","DA3_LOJFOR" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DA3"," "})			
	aTam:=TamSX3("DA3_DESCFO")	
	Aadd(aHeader,{STR0013,"DA3_DESCFO" ,Space(30) ,aTam[1],aTam[2],"",USADO, "C" ,"DA3"," "}) //"Nome Propriet."
	If mv_par07 == 1 // Gera Contrato de Premio para Motorista Proprio
		aTam:=TamSX3("DA4_COD")	
		Aadd(aHeader,{RetTitle("DA4_COD")  ,"DA4_COD"	,PesqPict("DA4","DA4_COD"	 ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DA4"," "})	
		aTam:=TamSX3("DA4_NOME")	
		Aadd(aHeader,{RetTitle("DA4_NOME") ,"DA4_NOME"	,PesqPict("DA4","DA4_NOME"	 ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DA4"," "})			
		aTam:=TamSX3("DTY_QTDKM")	
		Aadd(aHeader,{RetTitle("DTY_QTDKM"),"DTY_QTDKM"	,PesqPict("DTY","DTY_QTDKM" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTY"," "})	
	EndIf
	aTam:=TamSX3("DTT_VALOR")	
	Aadd(aHeader,{STR0014,"DTT_VALOR"	,PesqPict("DTT","DTT_VALOR" , aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTT"," "}) //"Premio Calculado"
	aTam:=TamSX3("DTM_PREMIO")	
	Aadd(aHeader,{STR0015,"DTM_PREMIO"	,PesqPict("DTM","DTM_PREMIO", aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTM"," "}) //"Premio a Pagar"
	Aadd(aHeader,{RetTitle("DVG_TABCAR"),"DVG_TABCAR"	,PesqPict("DVG","DVG_TABCAR" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVG"," "})	
	Aadd(aHeader,{RetTitle("DVG_TABFRE"),"DVG_TABFRE"	,PesqPict("DVG","DVG_TABFRE" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVG"," "})	
	Aadd(aHeader,{RetTitle("DVG_TIPTAB"),"DVG_TIPTAB"	,PesqPict("DVG","DVG_TIPTAB" ,aTam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DVG"," "})	
	
	Do While !(cArqTrab)->(Eof())                
	   If mv_par07 == 1
			Aadd(aCols,{(cArqTrab)->FILORI,(cArqTrab)->VIAGEM,(cArqTrab)->SERTMS,(cArqTrab)->CODFOR,(cArqTrab)->LOJFOR,(cArqTrab)->NOMFOR,(cArqTrab)->CODMOT,;
							(cArqTrab)->NOMMOT,(cArqTrab)->KMS,(cArqTrab)->VALCAL,(cArqTrab)->VALPRE,(cArqTrab)->TABCAR,(cArqTrab)->TABFRE,(cArqTrab)->TIPTAB,.F.})		
		Else 
			Aadd(aCols,{(cArqTrab)->FILORI,(cArqTrab)->VIAGEM,(cArqTrab)->SERTMS,(cArqTrab)->CODFOR,(cArqTrab)->LOJFOR,(cArqTrab)->NOMFOR,(cArqTrab)->VALCAL,(cArqTrab)->VALPRE,(cArqTrab)->TABCAR,(cArqTrab)->TABFRE,(cArqTrab)->TIPTAB,.F.})				
		EndIf					
		(cArqTrab)->(dbSkip())
	EndDo
	     
	DEFINE MSDIALOG oDlg FROM 70 ,10 TO 450,775 TITLE cCadastro Of oMainWnd PIXEL			
	
		o1Get := MSGetDados():New( 38, 2, 187, 382, 3,'AllWaysTrue','AllWaysTrue',,,{"DTM_PREMIO"}, , ,Len(aCols))		
		
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpc:=1, If(o1Get:TudoOk(),oDlg:End(),nOpc := 0)},{||oDlg:End()})	
	
	If nOpc == 1 
		Begin Transaction                                         
		   For nCntFor := 1 To Len(aCols) 
		      // Gera Premio para Motorista Proprio :
		      // Neste caso, e' gerado o valor do premio na folha de pagamento (SRC) e um contrato de Premio para
	   	   // o motorista (DTY)	   
	   		If mv_par07 == 1 .And. !Empty(GdFieldGet("DTM_PREMIO",nCntFor))  

					Processa({|lEnd| TMSA740Proc(nCntFor,@aVisErr,aDadosTot)},STR0008,STR0016,.F.)  //"Pagamento de Premio"###"Gerando os Contratos de Premio dos Carreteiros ..."
				
			      // Gera Premio para Terceiro OU Agregado :
			      // Neste caso, e' gerado Contas a Pagar com o Valor do Premio (SE2) e um Contrato de Premio (DTY)
	   		   // para o Motorista
			   ElseIf mv_par07 <> 1 .And. !Empty(GdFieldGet("DTM_PREMIO",nCntFor))  
					Processa({|lEnd| TMSA250Prc("DTQ", 3, GdFieldGet("DTQ_FILORI",nCntFor), GdFieldGet("DTQ_VIAGEM",nCntFor),.T.,GdFieldGet("DTM_PREMIO",nCntFor), @aVisErr )},STR0008,STR0016,.F.) //"Pagamento de Premio"###"Gerando os Contratos de Premio dos Carreteiros ..."
					Pergunte("TMA740",.F.) //-- Recarrega as perguntas da rotina
				EndIf	
			Next	
			//-- Apresenta na Tela os erros ocorridos durante o processamento
			If !Empty( aVisErr )                                                                                                   
				TmsMsgErr( aVisErr )
			EndIf					
		End Transaction			   
	EndIf			
Else	     
	If Len(aMsgErr) == 0	
  	   Help("",1,"REGNOIS") //"Nao existe registro relacionado a este codigo"
   EndIf
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o custo medio e' calculado On Line               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCusMed == "O" .And. nTotal > 0
	lDigita   := Iif(mv_par08 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
	lAglutina := Iif(mv_par09 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se ele criou o arquivo de prova ele deve gravar o rodape'    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RodaProva(nHdlPrv,nTotal)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para Lan‡amento Cont bil 							  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cA100Incl(cArquivo,nHdlPrv,3,cLoteTMS,lDigita,lAglutina)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a Data da Contabilizacao no SDG      	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	For nCntFor := 1 To Len(aRecSDGBai)			
		SDG->(dbGoTo(aRecSDGBai[nCntFor]))
		FwFreeArray( aCabSDG )
		aCabSDG		:= {} 
		Aadd( aCabSDG , { "DG_DTLANC", dDataBase, Nil })
		AtuTabSDG( aCabSDG , 4 )
		
	Next                    
EndIf								

//-- Arquivo de trabalho
oTempTable:Delete()

CursorArrow()

Return NIL
                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA740TRB³ Autor ³Patricia A. Salomao    ³ Data ³01.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera Arquivo de Trabalho contendo as Viagens para pagamento ³±±
±±³          ³de Premio.                                                  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA740TRB(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Valor do Premio Calculado                           ³±±
±±³          ³ExpN2 - Quilometragem percorrida                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA740                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA740TRB(nValCalc, nQtdKm, cTabFre, cTipTab, cTabCar)
Default nValCalc := 0
Default nQtdKm   := 0                     
Default cTabFre  := ''
Default cTipTab  := ''
Default cTabCar  := ''
	
RecLock(cArqTrab,.T.)
Replace (cArqTrab)->FILORI  With DTQ->DTQ_FILORI
Replace (cArqTrab)->VIAGEM  With DTQ->DTQ_VIAGEM
Replace (cArqTrab)->SERTMS  With TMSValField("DTQ->DTQ_SERTMS",.F.)
Replace (cArqTrab)->CODFOR  With DA3->DA3_CODFOR
Replace (cArqTrab)->LOJFOR  With DA3->DA3_LOJFOR
Replace (cArqTrab)->NOMFOR  With Posicione("SA2",1, xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR, "A2_NOME")
If mv_par07 == 1 // Gera Contrato de Carreteiro para Motorista Proprio
   Replace (cArqTrab)->CODMOT  With DA4->DA4_COD
   Replace (cArqTrab)->NOMMOT  With DA4->DA4_NOME
   Replace (cArqTrab)->KMS     With nQtdKm   
EndIf	
Replace (cArqTrab)->VALCAL  With nValCalc           
Replace (cArqTrab)->VALPRE  With nValCalc 
Replace (cArqTrab)->TABFRE  With cTabFre
Replace (cArqTrab)->TIPTAB  With cTipTab
Replace (cArqTrab)->TABCAR  With cTabCar

(cArqTrab)->(MsUnLock())	

Return Nil

/*/           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA740Proc ³ Autor ³ Patricia A. Salomao ³ Data ³11.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os Contratos de Premio para Motorista Proprio          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA740Proc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Item do aCols                                       ³±±
±±³          ³ExpA1 - Array contendo as Mensagens de Erro                 ³±±
±±³          ³ExpA2 - Array contendo a composicao do Frete                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA740                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Static Function TMSA740Proc(nCntFor,aVisErr,aDadosTot)   

Local cCusMed   := GetMv("MV_CUSMED")
Local cVerbMot  := GetMV('MV_VERBMOT',,'')  // Codigo da Verba do Motorista 
Local lPreGpe   := GetMV('MV_PREGPE',,.T.)  // Gera Premio para Motorista Proprio na Folha de Pagamento ?
Local aMsgErr   := {}
Local cCusto    := nDiaSem := nDiaFimSem := nQtdPer := nQtdKM := nSeek := nCnt := 0
Local nQtdOco   := nPesOco := nQtdDoc    := 0
Local cContrat  := cFilOri := cViagem    := ''
Local bCampo	:= {|x| FieldName(x) }
Local aFrete    := {}
Local nCont		  
Local lGeraSDG  := ( mv_par07 == 1 .And. mv_par10 == 1 )
Local nItem     := 0
Local cDocSDG   := ''
Local nValPedag := 0
Local cSeek     := ''
Local cCodVei   := ''
Local cProcesso := ''	
Local dData 	:= '' 
Local cSemana   := ''
Local cRoteiro  := 'FOL'
Local aPerAtual := {}
Local cPeriodo  := ''
Local nIndice   := 0

Default nCntFor   := 1 
Default aVisErr   := {}
Default aDadosTot := {}                     

//-- Gera Premio para Motorista Proprio na Folha de Pagamento ?
If lPreGpe
	If Empty(cVerbMot)
		AAdd( aMsgErr, {STR0017, '01', "" } ) //"Informar o parametro MV_VERBMOT (Codigo da Verba do Motorista)"
		AaddMsgErr( aMsgErr, @aVisErr )		
		Return .T.
	EndIf               
	        
	//-- SRV -> Arquivo de Verbas
	SRV->(dbSetOrder(1))
	If !SRV->(MsSeek(xFilial('SRV')+cVerbMot))
		AAdd( aMsgErr, {STR0018, '01', "GPEA040()" } )	 //"Codigo do parametro MV_VERBMOT Invalido ... Verifique o cadastro de Verbas"
		AaddMsgErr( aMsgErr, @aVisErr )		
		Return .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o custo medio e' calculado On Line               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCusMed == "O"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se necessario cria o cabecalho do arquivo de prova           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCriaHeader
		lCriaHeader := .F.
		nHdlPrv := HeadProva(cLoteTMS,"TMSA250",cUserName,@cArquivo)
		If nHdlPrv < 0
			Help(" ",1,"SEM_LANC") //"Nao foi possivel abrir o arquivo de Contra Prova"
         Return .F. 
		EndIf			
		lCriaHead  := .F.		
	EndIf
EndIf
	
DA4->(dbSetOrder(1))
If DA4->(MsSeek(xFilial('DA4')+ GdFieldGet('DA4_COD',nCntFor) )) 
	//-- Gera Premio para Motorista Proprio na Folha de Pagamento ?
	If lPreGpe	 
	   If Empty(DA4->DA4_MAT)
			AAdd( aMsgErr, {STR0021 + DA4->DA4_COD, '01', "OMSA040()" } ) //"Informar o no. da Matricula no Cadastro do Motorista "
			AaddMsgErr( aMsgErr, @aVisErr )	                    
	      Return .F.
		Else	
		   //-- SRA -> Arquivo de Funcionarios 
		 	SRA->(dbSetOrder(1))
			SRA->(MsSeek(xFilial('SRA')+ DA4->DA4_MAT))	
			cCusto 	:= SRA->RA_CC
			cProcesso 	:= SRA->RA_PROCES 
			
			If Empty(cCusto)
				AAdd( aMsgErr, {STR0019 + DA4->DA4_COD + ' / ' + STR0020 + DA4->DA4_MAT, '01', "GPEA010()" } ) //"Informar no Cadastro de Funcionarios, o Centro de Custo do Motorista "###"Matricula "
				AaddMsgErr( aMsgErr, @aVisErr )	
		      Return .F.
			EndIf	                                                                                  
		
			If Empty(cProcesso)
				AAdd( aMsgErr, {STR0022  + DA4->DA4_MAT + '.' } ) //"Informar no Cadastro de Funcionarios de matricula, o Codigo do Processo, campo RA_PROCESS"
				AaddMsgErr( aMsgErr, @aVisErr )	
		      Return .F.
			Else
				If fGetPerAtual(@aPerAtual, FwxFilial("RCH") , cProcesso, cRoteiro) // encontra o periodo e verifica se esta ativo 
					cPeriodo:= aPerAtual[1][1]
					cSemana	:= aPerAtual[1][2]
					dData 	:= aPerAtual[1][7] 
					
					If fVldAccess(FwxFilial('RG3'), dData, cSemana,.F., cRoteiro, "3", "V") // verifica se o período não se encontra bloqueado 
												
						//-- Cria as variaveis de Memoria do Arquivo de Movimento Mensal.
						nIndice:= RetOrder("RGB", "RGB_FILIAL+RGB_MAT+RGB_PD+RGB_CC+RGB_ITEM+RGB_CLVL+RGB_SEMANA+RGB_SEQ")
						RGB->(DbSetOrder(nIndice))
						RegToMemory('RGB',.T.)		
						M->RGB_FILIAL := xFilial('RGB')             
						M->RGB_MAT    := DA4->DA4_MAT
						M->RGB_PD     := cVerbMot
						M->RGB_CC     := cCusto
						M->RGB_TIPO1  := 'I'
						M->RGB_VALOR  := GdFieldGet("DTM_PREMIO",nCntFor)
						M->RGB_PERIOD := cPeriodo 
						M->RGB_ROTEIR := cRoteiro
						M->RGB_PROCES := cProcesso
						M->RGB_SEMANA := cSemana 
																
						If RGB->(MsSeek(xFilial('RGB')+DA4->DA4_MAT+cVerbMot+cCusto))
							RecLock('RGB',.F.)
						Else                                                                                   
						  	RecLock('RGB',.T.)		
						EndIf    
							
						For nCont:= 1 To FCount()
						   	If 'RGB_VALOR' $ Field( nCont )
						      RGB->RGB_VALOR += M->RGB_VALOR
						  	Else
								FieldPut( nCont, M->&( Eval( bCampo,nCont ) ) )
							EndIf	
						Next 
						RGB->(MsUnLock())
						
					Else
						AAdd( aMsgErr, {STR0023})//"Período se encontra “bloqueado ”."                                                                                                                                                                                                                                                                                                                                                                                 
						AaddMsgErr( aMsgErr, @aVisErr )	
						Return .F.
					Endif
				
				Else
					AAdd( aMsgErr, {STR0024})//"Período informado não esta cadastrado ou já foi fechado."
					AaddMsgErr( aMsgErr, @aVisErr )	
					Return .F.
				Endif
							
			Endif
								
		EndIf
		
	EndIf		                    
	 
	cContrat := CriaVar("DTY_NUMCTC")
	If __lSX8
		ConfirmSX8()
	EndIf           
	            
	If (nSeek := Ascan(aDadosTot, {|x| x[1]+x[2] == GdFieldGet('DTQ_FILORI', nCntFor) + GdFieldGet('DTQ_VIAGEM', nCntFor)}) ) > 0 
	    
	   aFrete     := aDadosTot[nSeek][11] // Composicao do Frete
      cFilOri    := aDadosTot[nSeek][01] // Filial de Origem da Viagem
      cViagem    := aDadosTot[nSeek][02] // Numero da Viagem
      nDiaSem    := aDadosTot[nSeek][04] // Qtde. de Diarias (Semana)
      nQtdKM     := aDadosTot[nSeek][05] // Quilometragem percorrida
      nQtdPer    := aDadosTot[nSeek][06] // Qtde. de Pernoites
      nDiaFimSem := aDadosTot[nSeek][07] // Qtde. de Diarias (Fim de Semana)      
		nQtdOco	  := aDadosTot[nSeek][08] // Qtde. informada na Ocorrencia
	   nPesOco    := aDadosTot[nSeek][09] // Peso informado na Ocorrencia
	   nQtdDoc    := aDadosTot[nSeek][10] // Qtde. de Documentos
	   nValPedag  := aDadosTot[nSeek][12] // Valor do Pedagio
	   cCodVei    := aDadosTot[nSeek][13] // Veiculo
                  
		//-- Grava composicao do frete
		TmsGrvDVP( cFilOri, cContrat, cViagem, aFrete )				   
		            		
	   //-- Grava Mov. de Custo (SDG)
		If lGeraSDG
			nItem   := 1
			If GdFieldGet("DTM_PREMIO",nCntFor) > 0
				cDocSDG := NextNumero("SDG",1,"DG_DOC",.T.)										
				TMA250GrvSDG("DTY",cFilOri, cViagem, cCodDesPRE, GdFieldGet("DTM_PREMIO",nCntFor), nItem, cCodVei, cDocSDG,,,,,,,,,,,,,,"TMSA740","2")

				nItem++
			EndIf
				
		   //-- Grava Mov. de Custo (SDG) do Valor do Pedagio							
			If nValPedag > 0
			   //-- O No. do Documento (SDG) gerado para o valor do Frete e pedagio,
			   //-- devera ser o mesmo
			   If Empty(cDocSDG)
				   cDocSDG := NextNumero("SDG",1,"DG_DOC",.T.)
			   EndIf
				TMA250GrvSDG("DTY",cFilOri, cViagem, cCodDesPDG, nValPedag, nItem, cCodVei, cDocSDG,,,,,,,,,,,,,,"TMSA740","2")

			EndIf              
		EndIf

	   //-- Grava Contrato de Premio para o Motorista 
      T250GerDTY(cContrat, GdFieldGet("DA3_CODFOR",nCntFor), GdFieldGet("DA3_LOJFOR",nCntFor), GdFieldGet("DTM_PREMIO",nCntFor), 0, 0, 0,;
				    '3', nQtdOco, nPesOco, nQtdDoc, nDiaSem, nQtdKM, 0, 0, cDocSDG, nQtdPer, 0, GdFieldGet("DA4_COD",nCntFor),;
				    cFilOri, cViagem, '', '', '', 0, nDiaFimSem,,,,,,cCodVei)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o custo medio e' calculado On Line               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
		If cCusMed == "O"
			SDG->(dbSetOrder(5))
			SDG->(MsSeek(cSeek:=xFilial('SDG')+cFilOri+cViagem))
			Do While !SDG->(Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM) == cSeek
				If SDG->DG_STATUS == StrZero(3, Len(SDG->DG_STATUS)) .And. Empty(SDG->DG_DTLANC)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera o lancamento no arquivo de prova           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTotal+=DetProva(nHdlPrv,"901","TMSA250",cLoteTMS)
				   AAdd(aRecSDGBai, SDG->(Recno()) )                 			
				EndIf	                                                      
				SDG->(dbSkip())				
			EndDo
		EndIf		

	EndIf
EndIf
   
Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} AtuTabSDG
Atualiza SDG
@type Function
@author CAio Murakami
@since 10/06/2021
@version 12.1.30
@param
@return lRet
*/
//------------------------------------------------------------------
Static Function AtuTabSDG( aCab , nOpc )
Local nCount	:= 1 
Local lExclui	:= .F. 
Local aArea		:= GetArea()

Default aCab	:= {}
Default nOpc	:= 3 

If FindFunction("TMSA070Aut")
	TMSA070Aut( aCab , nOpc )
Else 

	If nOpc == 3 
		RecLock("SDG",.T.)
	ElseIf nOpc == 4 .Or. nOpc == 5 
		RecLock("SDG",.F.)
		If nOpc == 5 
			lExclui	:= .T. 
		EndIf 
	EndIf 

	If lExclui
		SDG->(DbDelete())
	Else	
		For nCount := 1 To Len(aCab )
			SDG->&(aCab[nCount,1])	:= aCab[nCount,2]
		Next nCount 
	EndIf 

	SDG->(MsUnlock())
EndIf 

RestArea(aArea)
Return 
