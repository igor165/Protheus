#INCLUDE  "PROTHEUS.CH"
#INCLUDE  "LOJC090.CH"
#INCLUDE  "DBTREE.CH"
#INCLUDE  "FWMVCDEF.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ LOJC090    ³ Autor ³ SIGALOJA           ³ Data ³ 02/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Lancamentos                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ LojC090()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ LojC090                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function LojC090()

Local oDlg   //Objeto da Dialog principal
Local oTree  //Objeto do Tree da tela principal
Local oPanel //Objeto do panel
Local lGeraTree := .F. //Confirma a geração da consulta
Local oScrollBox //componente TGrid 
Local oDlg2  //Objeto da Dialog secundaria
Local oBtn1  //Botaão que confirma a geracao da consulta 
Local oBtn2  //Botao que cancela a geração da consulta
Local oFilPai := Nil //Objeto MSGET de Filial
Local cFilPai := Space(FWGETTAMFILIAL) //Armazena o conteudo da filial pai de filtro
Local oOrcPai := Nil //Objeto MSGET de Orcamento
Local cOrcPai := Space(TamSx3("L1_NUM")[1])//Armazena o orcamento pai de filtro
Local cPedido := Space(TamSx3("C5_NUM")[1]) //Pedido de Venda
Local lConNF  := IsInCallStack("MATC090")

If !lConNF
	//Montando a tela de filtro
	DEFINE MSDIALOG oDlg2 FROM 000,000 TO 243,485 PIXEL TITLE OemToAnsi(STR0001) // "Filtro para geração dos Lancamentos"
	oScrollBox := TScrollBox():new(oDlg2              ,007,007,095,230,.T.,.T.,.T.)
	oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT			
	
	@ 012,003 SAY OemToAnsi(STR0002) SIZE 045,010 OF oScrollBox PIXEL COLOR CLR_HBLUE //"Filial Orc Pai:"
	@ 010,065 MSGET oFilPai VAR cFilPai SIZE 030,005  WHEN .T. OF oScrollBox PIXEL F3 "SM0"
	
	@ 032,003 SAY OemToAnsi(STR0003) SIZE 045,010 OF oScrollBox PIXEL COLOR CLR_HBLUE //"Orcamento Pai:"
	@ 030,065 MSGET oOrcPai VAR cOrcPai SIZE 030,005  WHEN .T. OF oScrollBox PIXEL
	 	
	DEFINE SBUTTON oBtn1 FROM 105, 175 TYPE 1 ENABLE OF oDlg2 ACTION (lGeraTree:=.T.,oDlg2:End())	 
	DEFINE SBUTTON oBtn2 FROM 105, 205 TYPE 2 ENABLE OF oDlg2 ACTION  oDlg2:End()      
	
	ACTIVATE MSDIALOG oDlg2 CENTERED
Else   	
	SL1->(DbSetOrder(2))
	
	If SL1->(DbSeek(SF2->F2_FILIAL+SF2->F2_SERIE+SF2->F2_DOC))
		cFilPai := SL1->L1_FILRES
		cOrcPai := SL1->L1_ORCRES		
	EndIf	 
		   
	lGeraTree := .T.		
EndIf	

If lGeraTree
	LojC9VCarLanc(cFilPai,cOrcPai,lConNF) 	   	       		
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ LojC9CarLanc³ Autor ³ SIGALOJA           ³ Data ³ 02/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega os pedidos lancados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LojC9VCarLanc()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojC090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LojC9VCarLanc(cFilPai,cOrcPai,lConNF)   

Local aMsSize		:= MsAdvSize()
Local aObjects  	:= {{ 100, 100, .T., .T., .T. }}
Local aInfo		:= { aMsSize[ 1 ], aMsSize[ 2 ], aMsSize[ 3 ], aMsSize[ 4 ], 4, 4 } 
Local aPosObj		:= MsObjSize( aInfo, aObjects, .T. , .T. )
Local nCont     	:= 1 //Contador
Local nI	    	:= 0 //Contador
Local nX			:= 0 //Contador
Local nOpc 		:= 0 //Opcao da rotina
Local nSeqSC5		:= 0 //Sequencia do objeto SC5
Local nSeqSL1		:= 0 //Sequencia do objeto SL1
Local nSeqSF1		:= 0 //Sequencia do objeto SF1
Local nSeqSF2		:= 0 //Sequencia do objeto SF2
Local nSeqSE1		:= 0 //Sequencia do objeto SE1
Local cParcela 	:= "" //Parcelas Financeiro
Local cFilSE1 	:= "" //Filial de referencia da SF1 para posicionar na SE1
Local cOrcSE1 	:= "" //Orcamento de referencia da SF1 para posicionar na SE1
Local cMsDevol	:= ""
Local cCliTRF		:= ""
Local cLojaTRF	:= ""
Local cQuery 		:= "" 
Local cMsgInfo   	:= "" //Informacoes ao usuario  
Local cTpcd		:= "" //Tipo do Pedido de Venda
Local cAliasSL1  	:= GetNextAlias()
Local aPedVen		:= {} //Array que armazena Pedidos de Vendas VFE 
Local aDocEnt		:= {} //Array que armazena Documentos de Entrada
Local aFiltro		:= {} //Filtro para detalhe
Local lDocSaida  	:= .F. //Flag de verificacao NF de Saida
Local lCentroDL  	:= SuperGetMv("MV_LJCDL",, .F.) //Parametro de controle VFE

Private nIndex := 1

//Variaveis utilizadas na pesqusa de texto
Private nSeqTree  := 0

cQuery := " SELECT L1_FILIAL,L1_NUM,L1_CLIENTE,L1_LOJA,L1_DOC,L1_SERIE,L1_EMISNF,L1_ORCRES, L1_FILRES, L1_DOCPED, L1_SERPED"
cQuery += " FROM " + RetSqlName("SL1") + " SL1 WHERE"	
cQuery += " SL1.L1_FILRES = '" + cFilPai + "'"
cQuery += " AND SL1.L1_ORCRES = '" + cOrcPai + "'"
cQuery += " AND D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY " + SqlOrder(SL1->(IndexKey()))
			
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSL1, .F., .T.)	

//Posiciona no inicio do arquivo
(cAliasSL1)->(dbGoTop())

If (cAliasSL1)->(!Eof())
	DEFINE MSDIALOG oDlg  TITLE OemToAnsi(STR0008) FROM aMsSize[7],000 TO aMsSize[6],aMsSize[5] OF oMainWnd Pixel //"Vendas" 
	oTree := DbTree():New(15, 3, 197, 315, oDlg,,,.T.)
	oTree:lShowHint := .F.		// Desabilita o Hint
	oTree:Align := CONTROL_ALIGN_ALLCLIENT 
			 						   			 			   		
	While (cAliasSL1)->(!EOF())				
		SL1->(DbSetOrder(1))
			
		If SL1->(dbSeek(cFilPai+cOrcPai))	        						
			//Contador SL1
			nSeqSL1 ++
									
			//Filtro SL1
			cCargo := "SL1" + cValToChar(nSeqSL1)
			cName  := LojCFilName(SL1->L1_FILIAL, "SL1")
			
			aAdd(aFiltro, {cCargo,; 								  
							 SL1->L1_FILIAL + SL1->L1_NUM})
						
			DBADDTREE oTree PROMPT PADR(STR0009+(cFilPai+" - "+cOrcPai),100) OPENED RESOURCE "FOLDER5","FOLDER6" CARGO cCargo //"Orcamento Pai:"				   				
			DBADDITEM oTree PROMPT STR0014+ SL1->L1_FILIAL +" - "+ cName RESOURCE "EDIT" CARGO cCargo //"Filial:"			
			DBADDITEM oTree PROMPT STR0017+ SL1->L1_CLIENTE +" - "+Posicione("SA1",1,xFilial("SA1")+SL1->L1_CLIENTE,"A1_NOME")	RESOURCE "EDIT" CARGO cCargo //"Cliente:"
			DBADDITEM oTree PROMPT STR0024+ SL1->L1_LOJA RESOURCE "EDIT" CARGO cCargo //"Loja:" 
				
			If !Empty(AllTrim(SL1->L1_DOC)) 
				DBADDITEM oTree PROMPT STR0025+ SL1->L1_DOC RESOURCE "EDIT" CARGO cCargo //"Doc:"
				DBADDITEM oTree PROMPT STR0026+ SL1->L1_SERIE RESOURCE "EDIT" CARGO cCargo //"Serie:"
			EndIf
				
			DBADDITEM oTree PROMPT STR0060 + DToC(SL1->L1_EMISSAO) RESOURCE "EDIT" CARGO cCargo //"Data de Emissão:"
			DBADDITEM oTree PROMPT STR0061 + (cAliasSL1)->L1_FILIAL + " - " + LojCFilName((cAliasSL1)->L1_FILIAL, "SL1") RESOURCE "EDIT" CARGO cCargo //"Filial Orc. Filho:"
			DBADDITEM oTree PROMPT STR0062 + (cAliasSL1)->L1_NUM RESOURCE "EDIT" CARGO cCargo //"Orc.Filho:"
													
			//Buscar Pedidos de venda
			Processa({|lEnd| LojC090Ped(aPedVen, (cAliasSL1)->L1_NUM)}, STR0004, STR0067) //"#Aguarde..." ##"Buscando Pedidos de Vendas" 
			
			//Contador da Regua
			ProcRegua(Len(aPedVen))
				
			SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM
								
			For nI := 1 To Len(aPedVen)					 																				
				If	SC5->(dbSeek(aPedVen[nI][1] + aPedVen[nI][2]))
					IncProc("Pedido de Venda" + " " + aPedVen[nI][1] + aPedVen[nI][2]) 
																		 						
					If nCont == 1
						cCargo := "SC5"+SC5->C5_FILIAL+SC5->C5_NUM
				    	DBADDTREE oTree PROMPT OemToAnsi(STR0010) OPENED RESOURCE "FOLDER7","FOLDER8" CARGO StrZero(nSeqTree++,20) //"Pedidos de Venda" 
				    EndIf	
														
					//Contador SC5
					nSeqSC5 ++
					
					//Pedido de Venda	
					cName  := LojCFilName(SC5->C5_FILIAL, "SC5")																																																														
					cCargo := "SC5" + cValToChar(nSeqSC5)
					
					//Filtro SC5
					aAdd(aFiltro, {cCargo,; 								  
					 	 			 SC5->C5_FILIAL + SC5->C5_NUM})
										
					//Armazena cliente e Loja do Pedido TRF para uso posterior
					If lCentroDL .AND. SC5->(ColumnPos("C5_TPCD")) > 0
						If SC5->C5_TPCD == "0"
							cCliTRF := SC5->C5_CLIENTE
							cLojaTRF := SC5->C5_LOJACLI
						EndIf
						
						cTpcd := SC5->C5_TPCD
					
						//Verifica se Pedido foi Devolvido
						cMsDevol := ""
										
						LojC090Dev(SC5->C5_FILIAL, SC5->C5_NUM, SC5->C5_NOTA, SC5->C5_SERIE, cTpcd, @cMsDevol)
					EndIf
																																						
					DBADDTREE oTree PROMPT OemToAnsi(STR0013)+SC5->C5_FILIAL +" - " + SC5->C5_NUM + cMsDevol OPENED RESOURCE "FOLDER7","FOLDER8" CARGO cCargo //"P.V. :"
					DBADDITEM oTree PROMPT STR0014+SC5->C5_FILIAL +" - "+ cName RESOURCE "Checked" CARGO cCargo //"Filial: "
					DBADDITEM oTree PROMPT STR0015+SC5->C5_NUM RESOURCE "Checked" CARGO cCargo //"Pedido: "
					DBADDITEM oTree PROMPT STR0016+SC5->C5_ORCRES RESOURCE "Checked" CARGO cCargo //"Orc.Reserva: "
					DBADDITEM oTree PROMPT STR0017+SC5->C5_CLIENTE +" - "+Posicione("SA1",1,xFilial("SA1")+AllTrim(SC5->C5_CLIENTE),"A1_NOME") RESOURCE "Checked" CARGO cCargo //"Cliente: "
					DBADDITEM oTree PROMPT STR0018+SC5->C5_LOJACLI 		RESOURCE "Checked"  CARGO cCargo //"Loja Cliente: "
					DBADDITEM oTree PROMPT STR0019+SC5->C5_CLIENT +" - "+Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENT,"A1_NOME") RESOURCE "Checked" CARGO cCargo //"Cliente de Entrega: "
					DBADDITEM oTree PROMPT STR0020+SC5->C5_LOJAENT RESOURCE  "Checked" CARGO cCargo //"Loja de Entrega: "				
					
					If lCentroDL
						DBADDITEM oTree PROMPT STR0021+cTpcd +" - "+ LojC090Desc(cTpcd) RESOURCE "Checked" CARGO cCargo //"Tipo de Pedido: "
					EndIf
					
					lDocSaida := .F. //Inicializa flag NF de Saida
					
					If !Empty(SC5->C5_NOTA)
						//Posiciona na NF de Saida
						SF2->(dbSetOrder(1)) //Filial+Nota+Serie
						
						If SF2->(DbSeek(SC5->C5_FILIAL+SC5->C5_NOTA+SC5->C5_SERIE))
							lDocSaida := .T.
							
							DBADDITEM oTree PROMPT STR0022+SF2->F2_DOC RESOURCE  "Checked" CARGO cCargo //"NF Saida: "
							DBADDITEM oTree PROMPT STR0023+SF2->F2_SERIE RESOURCE  "Checked" CARGO cCargo //"Serie da NF Saida: "																																						
							DBADDITEM oTree PROMPT STR0066 + DToC(SF2->F2_EMISSAO) RESOURCE "Checked" CARGO cCargo //"Dt Emissão da NF:" 
						EndIf
					EndIf
									            					
					//Nota Fiscal de Entrada													
					SF1->(dbSetOrder(1))
					
					//Buscar Documentos de Entrada
					If lCentroDL
						LojC090Nfe(aDocEnt, SC5->C5_FILIAL, SC5->C5_NUM)								
					EndIf
					
					For nX := 1 To Len(aDocEnt)		
						If SF1->(dbSeek(aDocEnt[nX][1] + aDocEnt[nX][2] + aDocEnt[nX][3]))	
							//Contador SF1
							nSeqSF1 ++																																																																														
																			 						
							cCargo := "SF1" + cValToChar(nSeqSF1)
							cName := LojCFilName(SF1->F1_FILIAL, "SF1")
							
							//Filtro SF1
							aAdd(aFiltro, {cCargo,; 								  
					 	 		 			 SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE})
								
							DBADDTREE oTree PROMPT OemToAnsi(STR0011)+SF1->F1_FILIAL +" - " + SF1->F1_DOC + cMsDevol OPENED RESOURCE "FOLDER10","FOLDER11" CARGO cCargo //"N.F.Entrada:"
							DBADDITEM oTree PROMPT STR0014+SF1->F1_FILIAL +" - "+ cName	RESOURCE "BR_VERDE.PNG" CARGO cCargo //"Filial: "		
							DBADDITEM oTree PROMPT STR0025+SF1->F1_DOC RESOURCE "BR_VERDE.PNG" CARGO cCargo //"Doc.: "		
							DBADDITEM oTree PROMPT STR0026+SF1->F1_SERIE RESOURCE "BR_VERDE.PNG" CARGO cCargo //"Serie: "
							DBADDITEM oTree PROMPT STR0016+SF1->F1_NUMPV RESOURCE "BR_VERDE.PNG" CARGO cCargo //"Orc.Reserva: " 																
							DBADDITEM oTree PROMPT STR0027+SF1->F1_FORNECE +" - "+Posicione("SA2",1,xFilial("SA2")+AllTrim(SF1->F1_FORNECE),"A2_NOME") RESOURCE "BR_VERDE.PNG" CARGO cCargo //"Fornecedor: " 
							DBADDITEM oTree PROMPT STR0028+SF1->F1_LOJA RESOURCE "BR_VERDE.PNG"  CARGO cCargo //"Loja Fornecedor: "
							DBADDITEM oTree PROMPT STR0029+dtoc(SF1->F1_EMISSAO)	RESOURCE "BR_VERDE.PNG"  CARGO cCargo //"Dt.Emissão: "
							DBADDITEM oTree PROMPT STR0030+dtoc(SF1->F1_RECBMTO) RESOURCE "BR_VERDE.PNG" CARGO cCargo //"Dt.Recebimento: "							
							DBENDTREE oTree															
						EndIf												
					Next nX
								       
					//Nota Fiscal de Saida								
					If lDocSaida																											
						//Contador SF2
						nSeqSF2 ++																																																																														
																		 						
						cCargo := "SF2" + cValToChar(nSeqSF2)							
						cName  := LojCFilName(SF2->F2_FILIAL, "SF2")					
						
						//Filtro SF1
						aAdd(aFiltro, {cCargo,; 								  
			 	 		 			 SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE})												
							
						DBADDTREE oTree PROMPT OemToAnsi(STR0012)+SF2->F2_FILIAL +" - " + SF2->F2_DOC + cMsDevol OPENED RESOURCE "FOLDER14","FOLDER15" CARGO cCargo //"N.F. Saida:"						
						DBADDITEM oTree PROMPT STR0014+SF2->F2_FILIAL +" - "+ cName	 RESOURCE "BR_CINZA.PNG" CARGO cCargo //"Filial: "			
						DBADDITEM oTree PROMPT STR0025+SF2->F2_DOC RESOURCE "BR_CINZA.PNG" CARGO cCargo //"Doc.: "		
						DBADDITEM oTree PROMPT STR0026+SF2->F2_SERIE RESOURCE "BR_CINZA.PNG" CARGO cCargo //"Serie: "
						DBADDITEM oTree PROMPT STR0017+SF2->F2_CLIENTE +" - "+Posicione("SA1",1,xFilial("SA1")+AllTrim(SF2->F2_CLIENTE),"A1_NOME") RESOURCE "BR_CINZA.PNG" CARGO cCargo //"Cliente: "
						DBADDITEM oTree PROMPT STR0018+SF2->F2_LOJA RESOURCE "BR_CINZA.PNG"  CARGO cCargo //"Loja Cliente: "
						DBADDITEM oTree PROMPT STR0029+dtoc(SF2->F2_EMISSAO)RESOURCE "BR_CINZA.PNG" CARGO cCargo //"Dt.Emissão: "
						DBENDTREE oTree																			
					EndIf
									
					DBENDTREE oTree
						
					nCont ++
				EndIf																							
			Next nI
				
			If nCont > 1
				DBENDTREE oTree //Dos Pedidos de Venda
			EndIf
				
			nCont := 1	       
				                                               							
			//Orcamento de transferencia gerado automaticamente:		   				
			SL1->(dbSetOrder(14)) //L1_FILIAL+L1_ORCRES
					
			If SL1->(dbSeek((cAliasSL1)->L1_FILIAL+cOrcPai))											
				cFilSE1 := SL1->L1_FILRES
				cOrcSE1 := SL1->L1_ORCRES
			EndIf
										
		    //Contas a receber			    
			SL1->(DbSetOrder(1)) //Filial+Prefixo+Num
				
			If SL1->(dbSeek(cFilSE1+cOrcSE1) )							    
				SE1->(dbSetOrder(1))//Filial+Prefixo+Num
						
				If SE1->(DbSeek(SL1->L1_FILIAL+SL1->L1_SERPED+SL1->L1_DOCPED))
					cName := LojCFilName(SE1->E1_FILIAL, "SE1")					
					
					While SE1->(!EOF()) .And. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == SL1->L1_FILIAL+SL1->L1_SERPED+SL1->L1_DOCPED 
						//Contador SE1
						nSeqSE1 ++
									
						//Filtro SE1
						cCargo := "SE1" + cValToChar(nSeqSE1)										
			
						aAdd(aFiltro, {cCargo,; 								  
							 	 		 SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM})
																
						cParcela := IIF(!Empty(SE1->E1_PARCELA), " - " + SE1->E1_PARCELA, "")
						
				    	DBADDTREE oTree PROMPT OemToAnsi(STR0038)+SE1->E1_FILIAL+" - "+ SE1->E1_PREFIXO +" - "+ AllTrim(SE1->E1_NUM) + cParcela OPEN RESOURCE "FOLDER10","FOLDER11" CARGO cCargo //"Contas a Receber:"					
						DBADDITEM oTree PROMPT STR0014+ SE1->E1_FILIAL RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Filial: "
						DBADDITEM oTree PROMPT STR0032+ SE1->E1_PREFIXO RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Prefixo: "
						DBADDITEM oTree PROMPT STR0033+ SE1->E1_NUM RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Codigo: "
						DBADDITEM oTree PROMPT STR0034+ SE1->E1_NATUREZ RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Natureza: "
						DBADDITEM oTree PROMPT STR0017+ SE1->E1_CLIENTE  +" - "+Posicione("SA1",1,xFilial("SA1")+AllTrim(SE1->E1_CLIENTE),"A1_NOME") RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Cliente: "
						DBADDITEM oTree PROMPT STR0024+ SE1->E1_LOJA  RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Loja: "
						DBADDITEM oTree PROMPT STR0029+ dtoc(SE1->E1_EMISSAO) RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Dt.Emissão: "
						DBADDITEM oTree PROMPT STR0035+ dtoc(SE1->E1_VENCTO) RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Dt.Venc.: "
						DBADDITEM oTree PROMPT STR0036+ cValToChar(SE1->E1_VALOR) RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Valor: "
						DBADDITEM oTree PROMPT STR0037+ SE1->E1_HIST RESOURCE "BR_AZUL.PNG" CARGO cCargo //"Historico: "					
						DBENDTREE oTree
						
						SE1->(dbSkip())
					EndDo
				EndIf							
			EndIf				
			
			DBENDTREE oTree  // Do Orcamento Pai
		EndIf
		
		(cAliasSL1)->(dbSkip())
	EndDo					
	    				
	aButtons := {{"BMPVISUAL", {||LojVisDetail(oTree, aFiltro)  },OemToAnsi(STR0039)},; //"Detalhe" 
				   {"PESQUISA", {|| LojPesVfe(@oTree,nBtn:=1) }, OemToAnsi(STR0040),OemtoAnsi(STR0041) }} //"Pesquisa texto genérico" #//"Pesquisa"  
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ ||oDlg:End(), nOpc := 1},{ ||oDlg:End() },,aButtons) CENTERED			
Else
	cMsgInfo := STR0064 //"A Consulta não encontrou informações para exibir"
		
	If !lConNF
		cMsgInfo += "," 
		cMsgInfo += STR0065 //"verifique os parâmetros."
	EndIf
	
	MsgInfo(cMsgInfo)
EndIf
	
//Fecha Arquivos temporarios
If (Select(cAliasSL1) > 0)
	(cAliasSL1)->(dbCloseArea())
EndIf

//Funcao chamada novamente para agilizar processo, desta forma, a tela de parametros sera acionada automaticamente
//Para sair da rotina, usuario devera cancelar na tela de parametros
If !lConNF .And. nOpc == 1
	LOJC090()
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ LojC090Desc ³ Autor ³ SIGALOJA           ³ Data ³ 02/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna a descrição do tipo de pedido                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LOJC090Desc                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojC090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LojC090Desc(cCod)

Local cDesc := ""

Do Case
	Case cCod == "1" 
		cDesc := STR0042 //"Simples Faturamento"
	Case cCod == "2" 
		cDesc := STR0043 //"Remessa Entrega Futura"
	Case cCod == "3" 
		cDesc := STR0044 //"Remessa por Conta e Ordem de Estabelecimento Showroom"
	Case cCod == "4" 
		cDesc := STR0045 //"Transferencia Simbolica"
	Otherwise
		cDesc := STR0046 //"TRF de Reserva"
EndCase

Return cDesc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³LojCFilName    ³ Autor ³ SIGALOJA         ³ Data ³ 02/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o Nome das filiais recebidas no parametro aFiliais.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LojCFilName                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojC090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LojCFilName(cCod,cAliasTab)

Local cNome   := "" //Nome da Empresa
Local aModoComp := {{ 3, "FwFilName"}, {2, "FWUnitName"}, {1,"FWCompanyName"}} //Funções do Nome
Local cFunction := "FWGrpName"
Local nC := 0  //Contador
Local bBloco := {}  //Bloco de Codigo 

Default cAliasTab := "SC5"

For nC := 1 to Len(aModoComp)

	If FWModeAccess(cAliasTab, aModoComp[nC, 01]) = "E"
		cFunction := aModoComp[nC, 02]
		Exit
	EndIf
Next


bBloco := &("{ |_Emp, _Filial| " + cFunction +"(_Emp, _Filial) }")
cNome := EVAL(bBloco, cEmpAnt, cCod )


Return cNome

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LojPesVfe   ³ Autor ³ SIGALOJA                      ³ Data ³ 15/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa Texto                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LojPesVfe(oTree, nBtn)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1-Objeto do Tree                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojC090.PRW                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LojPesVfe(oTree,nBtn)

Local nOpcao := 0
Local oDlgPesq
Local oBtn1
Local oBtn2
Local lAchou := .F.
Local cChaveTree := ""
Local cChaveSeq := "0000"

If nBtn == 1 // "Pesquisa Texto"
	lEditPTree := .T.		
Else         // "Proxima Pesquisa"
	lEditPTree := .F.
EndIf

If lEditPTree
	DEFINE MSDIALOG oDlgPesq FROM 0,0 TO 080,634 PIXEL TITLE OemToAnsi(STR0047)	// "Pesquisa Texto"

    cChaveTree := Padr(cChaveTree,100)
	@ 010,05 MSGET cChaveTree SIZE 310,08 OF oDlgPesq PIXEL

	DEFINE SBUTTON oBtn1 FROM 25,005 TYPE 1 PIXEL ENABLE OF oDlgPesq ACTION ( nOpcao:=1,oDlgPesq:End() )
	DEFINE SBUTTON oBtn2 FROM 25,035 TYPE 2 PIXEL ENABLE OF oDlgPesq ACTION ( nOpcao:=2,oDlgPesq:End() )

	ACTIVATE MSDIALOG oDlgPesq CENTERED
EndIf

If (nOpcao == 1 .Or. nOpcao == 0) .And. !Empty(AllTrim(cChaveTree))
	cChaveTree := UPPER(AllTrim(cChaveTree))
	dbSelectArea(oTree:cArqTree)
	dbGoTop()	
	While !Eof()
		If cChaveTree $ UPPER(T_PROMPT)
			If (nOpcao == 0 .And. T_CARGO > cChaveSeq) .Or. nOpcao == 1
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				// Colocado duas vezes para posicionar na linha onde esta o texto
				// porque se buscar uma vez posiciona no Item pai.                
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				cChaveSeq := T_CARGO
				lAchou := .T.
				lEditPTree := .F.
				Exit
			EndIf
		EndIf
		dbSkip()
	Enddo
	If !lAchou
		If cChaveSeq <> "0000"
			lEditPTree := .T.
		EndIf
		MsgAlert(OemToAnsi(STR0048+" '"+cChaveTree+"' "+STR0049))	// "Texto" ### "não encontrado"
	Else
		lEditPTree := .F.
		cChaveTree := ""
	EndIf
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LojVisDetail³ Autor ³ Vendas                        ³ Data ³ 10/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza detalhes do Orcamento ou do Pedido de Venda posicionado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LojVisDetail(oTree, aFiltro)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1-Objeto do Tree                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojC090.PRW                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LojVisDetail(oTree, aFiltro)

Local cCargo  := oTree:GetCargo() 
Local cFiltro := ""//Filtro de busca para visualizacao da View

Private cCadastro:= "" // necessario para visualizacao do axCadastro
Private Altera   := .F.// necessario para visualizacao do axCadastro

Do Case
	//Orcamento do Venda Assistida
	Case Left(cCargo,3) == "SL1"
		nPos := aScan(aFiltro, {|x| x[1] == cCargo})
			    		
		If nPos > 0	    	   							
			SL1->(dbSetOrder(1)) //L1_FILIAL+L1_NUM		
			
			If SL1->(dbSeek(aFiltro[nPos][2]))				
				cFiltro :=  " L1_NUM == '"+ SL1->L1_NUM +"'"
				MsgRun(STR0050,STR0051	,{|| LojView(cFiltro,"SL1","SL2",SL1->L1_FILIAL)}) //"Carregando.." #//"Aguarde..."
			EndIf
		EndIf
	//Nota Fiscal de Entrada
	Case Left(cCargo,3) == "SF1"
	    nPos := aScan(aFiltro, {|x| x[1] == cCargo})
	    
		If nPos > 0
			SF1->(dbSetOrder(1)) 
		
			If SF1->(dbSeek(aFiltro[nPos][2]))				
				cFiltro :=  " F1_DOC == '"+ SF1->F1_DOC +"' .And. F1_SERIE == '"+SF1->F1_SERIE+"'"
				MsgRun(STR0050,STR0051	,{|| LojView(cFiltro,"SF1","SD1",SF1->F1_FILIAL)}) //"Carregando.." #//"Aguarde..."
			EndIf
		EndIf	
	//Nota Fiscal de Saida
	Case  Left(cCargo,3) == "SF2"
	    nPos := aScan(aFiltro, {|x| x[1] == cCargo})
	    
	    If nPos > 0
			SF2->(dbSetOrder(1))                                                                                                        
			
			If SF2->(dbSeek(aFiltro[nPos][2]))							 
				cFiltro :=  " F2_DOC == '"+ SF2->F2_DOC +"' .And. F2_SERIE == '"+SF2->F2_SERIE+"'"			 
				MsgRun(STR0050,STR0051	,{|| LojView(cFiltro,"SF2","SD2",SF2->F2_FILIAL)}) //"Carregando.." #//"Aguarde..." 
			EndIf
		EndIf
	//Pedido de Venda do Faturamento
	Case Left(cCargo,3) == "SC5"
	    nPos := aScan(aFiltro, {|x| x[1] == cCargo})
		
		If nPos > 0
			SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM									    
	    
			If SC5->(dbSeek(aFiltro[nPos][2]))			
				cFiltro :=  " C5_NUM == '"+ SC5->C5_NUM +"'"			
				MsgRun(STR0050,STR0051	,{|| LojView(cFiltro,"SC5","SC6",SC5->C5_FILIAL) }) //"Carregando.." #//"Aguarde..."
			EndIf 
		EndIf
	//Contas a receber
	Case Left(cCargo,3) == "SE1"
	    nPos := aScan(aFiltro, {|x| x[1] == cCargo})
	    
	    If nPos > 0
			SE1->(dbSetOrder(1)) 	
	    
			If SE1->(dbSeek(aFiltro[nPos][2]))
				cCadastro:= STR0052 //"Contas a Receber"			  
				MsgRun(STR0050,STR0051 ,{|| AxVisual("SE1",SE1->(RecNo()),2)}) //"Carregando.." #//"Aguarde..."
			EndIf 
		EndIf
EndCase
	
Return Nil 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³LojView     ³ Autor ³ SIGALOJA         ³ Data ³08/10/2014   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza o fitro para visualizar o orcamento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 	LojView(cFiltro,cPai,cFilho,cFil)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojC090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LojView(cFiltro,cPai,cFilho,cFil)

Local aCoors 		:= FWGetDialogSize( oMainWnd ) //Arrays de cordenadas da tela
Local oFWLayer 		:= Nil 	// Obj Layer			
Local oPanelUp 		:= Nil 	// Panel superior
Local oPanelCenter	:= Nil 	// Panel superior   	 
Local oBrowseUp  	:= Nil 	// Obj Browser superior 	
Local oBrowseCenter := Nil 	// Obj Browser Center
Local oDlgPrinc		:= Nil	// Objeto dialog principal

Define MsDialog oDlgPrinc Title STR0053 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //"Visualização"

// Cria o conteiner onde serão colocados os browses
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )

// Painel Superior
oFWLayer:AddLine( 'UP', 30, .F. )
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

// Painel Central
oFWLayer:AddLine( 'CENTER', 70, .F. )
oFWLayer:AddCollumn( 'ALL' , 100, .T., 'CENTER' )
oPanelCenter := oFWLayer:GetColPanel( 'ALL' , 'CENTER' ) 

// Browser Vendas Superior
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetDataTable()
oBrowseUp:SetOwner( oPanelUp )

Do Case
	Case cFilho == "SL2"
		oBrowseUp:SetDescription( STR0054 ) //"Orçamento"
	Case cFilho == "SD1"
		oBrowseUp:SetDescription( STR0055 ) //"Nota Fiscal de Entrada"
	Case cFilho == "SD2"
		oBrowseUp:SetDescription( STR0056 ) //"Nota Fiscal de Saida"
	Case cFilho == "SC6"
		oBrowseUp:SetDescription( STR0057 ) //"Pedido de Venda"
EndCase

oBrowseUp:SetAlias( cPai )
oBrowseUp:SetMenuDef( '' )// Referencia vazia para que nao exiba nenhum botao
oBrowseUp:SetProfileID( '1' )
oBrowseUp:SetFilterDefault( cFiltro )// Definição de filtro 
oBrowseUp:ForceQuitButton()
oBrowseUp:DisableDetails()
oBrowseUp:DisableReport()

// Browser Itens Center
oBrowseCenter:= FWMBrowse():New()
oBrowseCenter:SetOwner( oPanelCenter )
oBrowseCenter:SetDescription( STR0058 ) //"Itens" 
oBrowseCenter:SetAlias( cFilho )
oBrowseCenter:SetMenuDef( '' )// Referencia vazia para que nao exiba nenhum botao
oBrowseCenter:SetProfileID( '2' )
oBrowseCenter:DisableDetails()
oBrowseCenter:DisableConfig()
oBrowseCenter:DisableLocate()
oBrowseCenter:DisableReport()
oBrowseCenter:DisableSaveConfig() 
oBrowseCenter:DisableSeek() 

//Ativa os Browsers
oBrowseCenter:Activate()
oBrowseUp:Activate()
oBrowseUp:SetFocus()

// Relacionamento entre os Browsers
oRelacSL2:= FWBrwRelation():New()

Do Case
	Case cFilho == "SL2"
		oRelacSL2:AddRelation( oBrowseUp , oBrowseCenter , { { 'L2_NUM' , 'L1_NUM' } } )
	Case cFilho == "SD1"//Itens da NF Entrada
		oRelacSL2:AddRelation( oBrowseUp , oBrowseCenter , { { 'D1_DOC' , 'F1_DOC' } ,{'D1_SERIE' , 'F1_SERIE' }} )
	Case cFilho == "SD2"
		oRelacSL2:AddRelation( oBrowseUp , oBrowseCenter , { { 'D2_DOC' , 'F2_DOC' },{ 'D2_SERIE' , 'F2_SERIE' } } )
	Case cFilho == "SC6"
		oRelacSL2:AddRelation( oBrowseUp , oBrowseCenter , { { 'C6_NUM' , 'C5_NUM' } } )			
EndCase 
		
oRelacSL2:Activate()

Activate MsDialog oDlgPrinc Centered

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³LojC090Dev     ³ Autor ³ Varejo           ³ Data ³21/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se houveram devolucoes para os Pedidos de Venda.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 	LojC090Dev()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojC090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function LojC090Dev(cFilOri, cPedOri, cNFOri, cSerieOri, cTpPed, cMsDevol)

Local aArea     	:= GetArea()
Local aAreaSD2  	:= SD2->(GetArea())
Local cWhere		:= ""
Local cAliasTmp	:= GetNextAlias()
Local lRet			:= .F.

Default cMsDevol := ""

//Verifica as devolucoes
If cTpPed <> "0" .AND. SF1->(ColumnPos("F1_FILPV") > 0 .AND. ColumnPos("F1_NUMPV") > 0) //Nao trata TRF
	//Condicional para a query		
	cWhere := "% "
	cWhere += " F1_FILPV = " + "'" + cFilOri + "'"
	cWhere += " AND F1_NUMPV = " + "'" + cPedOri + "'"
	cWhere += " AND SF1.D_E_L_E_T_ = '' "   		   			
	cWhere += " %"              											
		                                          
	//Executa a query
	BeginSql alias cAliasTmp
		SELECT 
			F1_FILIAL, F1_DOC, F1_SERIE 
		FROM %table:SF1% SF1							
		WHERE %exp:cWhere% 			
	EndSql	
	
	//Posiciona no inicio do arquivo temporario
	(cAliasTmp)->(dbGoTop())
	
	//Se encontrou, marca devolucao
	If (cAliasTmp)->(!EOF())
		//Pedidos de Transferencia, verifica a SF2 de Devolucao
		If cTpPed == "4"
			SD2->(dbSetOrder(10))
			
			If SD2->(dbSeek((cAliasTmp)->F1_FILIAL + (cAliasTmp)->F1_DOC + (cAliasTmp)->F1_SERIE)) .And.; 
						SD2->D2_TIPO == "D"
						
				cMsDevol := STR0059 //" - Documento devolvido"
				lRet := .T.
			EndIf
		Else
			cMsDevol := STR0059 //" - Documento devolvido"
			lRet := .T.
		EndIf
	EndIf
EndIf	
	
//Fecha Alias temporario
If (Select(cAliasTmp) > 0)
	(cAliasTmp)->(dbCloseArea())
EndIf

//Restaura a entrada da rotina                                    
RestArea(aAreaSD2)
RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³LojC090Ped     ³ Autor ³ Varejo           ³ Data ³02/07/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Busca os Pedidos de Vendas relacionados a VFE.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 	LojC090Ped(aPedVen, cL1Num)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function LojC090Ped(aPedVen, cL1Num, cTipoPed)

Local cWhere 	  := "" //Condicao da query
Local cAliasSC5 := GetNextAlias()
Local lCentroDL := SuperGetMv("MV_LJCDL",, .F.) //Parametro de controle VFE

Default cTipoPed := ""

aPedVen := {} //Inicializa array de Pedidos de Venda

//Condicional para a query		
cWhere := "%"
cWhere += " C5_ORCRES = '" + cL1Num + "'"

//Verifica se VFE esta habilitado
If lCentroDL .AND. SC5->(ColumnPos("C5_TPCD") > 0)
	If !Empty(cTipoPed)
		cWhere += " AND C5_TPCD = '" + cTipoPed + "'"
	Else
		cWhere += " AND C5_TPCD <> ''"
	EndIf
EndIf

cWhere += " AND SC5.D_E_L_E_T_ = ''"   		   			
cWhere += "%"              											
		                                          
//Executa a query
BeginSql alias cAliasSC5
	SELECT 
		C5_FILIAL, C5_NUM 
	FROM %table:SC5% SC5							
	WHERE %exp:cWhere% 			
EndSql	
	
//Posiciona no inicio do arquivo temporario
(cAliasSC5)->(dbGoTop())

//Armazena Pedidos de Vendas
While (cAliasSC5)->(!EOF())
	aAdd(aPedVen, {(cAliasSC5)->C5_FILIAL,;
					 (cAliasSC5)->C5_NUM})
	
	(cAliasSC5)->(dbSkip())
EndDo

//Fecha arquivo temporario
If (Select(cAliasSC5) > 0)
	(cAliasSC5)->(dbCloseArea())	
EndIf
	
Return Nil	

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³LojC090Nfe     ³ Autor ³ Varejo           ³ Data ³02/07/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Busca as Notas de Entrada relacionadas a VFE.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 	LojC090Nfe(aDocEnt, cFilPv, cOrcPv)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojC090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LojC090Nfe(aDocEnt, cFilPv, cOrcPv)

Local cWhere 	  := "" //Condicao da query
Local cAliasSF1 := GetNextAlias()

//Inicializa array de documentos
aDocEnt := {}

//Condicional para a query		
cWhere := "%"
cWhere += " F1_FILPV = '" + cFilPv + "'"
cWhere += " AND F1_NUMPV = '" + cOrcPv + "'"
cWhere += " AND SF1.D_E_L_E_T_ = ''"   		   			
cWhere += "%"              											
		                                          
//Executa a query
BeginSql alias cAliasSF1
	SELECT 
		F1_FILIAL, F1_DOC, F1_SERIE 
	FROM %table:SF1% SF1							
	WHERE %exp:cWhere% 			
EndSql	
	
//Posiciona no inicio do arquivo temporario
(cAliasSF1)->(dbGoTop())

//Armazena Pedidos de Vendas
While (cAliasSF1)->(!EOF())
	aAdd(aDocEnt, {(cAliasSF1)->F1_FILIAL,;
					 (cAliasSF1)->F1_DOC,;
					 (cAliasSF1)->F1_SERIE})
	
	(cAliasSF1)->(dbSkip())
EndDo

//Fecha arquivo temporario
If (Select(cAliasSF1) > 0)
	(cAliasSF1)->(dbCloseArea())	
EndIf
	
Return Nil

// comentario inserido para criar uma nova changeset, pois nao é possivel associar a primeira versao da branch