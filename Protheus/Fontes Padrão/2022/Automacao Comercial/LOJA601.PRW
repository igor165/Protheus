#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA601.CH"     

#Define __L4_DATA    01
#Define __L4_FORMA   02
#Define __L4_VALOR   03
#Define __PORTE      04 
#Define __L4_CHEQID  05
#Define __L4_NUMCART 06 
#Define __L4_ADMINIS 07 
#Define __L4_AGENCIA 08
#Define __L4_CONTA   09  
#Define __L4_COMP 	 10
#Define __L4_MOEDA   11
#Define __L4DATA     12 
#Define __L4_DOCTEF  13
#Define __L4_FORMAID 14 
#Define __L4lEstorn  15 
#Define __L4_DATATEF 16
#Define __L4_NSUTEF  17
#Define __L4_DOCCANC 18
#Define __L4_HORCANC 19
#Define __L4_DATCANC 20
#Define __E1_PARCELA 21  
#Define __L4_RECNO	 22 
#Define __L4_TAMANHO 22	

Function LOJA601 ; Return  // "dummy" function - Internal Use


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LOJA601   ³ Autor ³ Fabiana Cristina      ³ Data ³10/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Explosao do Estorno de Vendas na Retaguarda                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj601EstDinh ³ Autor ³ Vendas Cliente        ³ Data ³14/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Estorno em dinheiro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj601EstDinh(ExpC1, ExpL2, ExpC3,ExpC4, ExpA5, ExpL6)         ³±±
±±³			 ³ExpC1 - Numero do Orcamento           					     ³±± 
±±³			 ³ExpL2 - Orcamento em Movimento Fechado/Cliente Padrao          ³±±
±±³			 ³ExpC3 - Numero do documento de Saida   					     ³±± 
±±³			 ³ExpC4 - Serie do documento de saida     					     ³±±
±±³			 ³ExpA5 - Pagamentos da Venda - ExpA05[N,22], vide define acima  ³±± 
±±³			 ³ExpL6 - Execução em Job     					                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Automacao Comercial									  	     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function Lj601EstDinh(cOrc,		lOrc_MovFe,		cOrc_Doc,		cOrc_Serie,; 
 					  aPagtos, 	lJob)    
 					  
Local aArea := GetArea()    //WorkAreas Ativas
Local nPos := 0             //Posicao do array
Local cParcela := ""        //Parcela do título
Local cTipo := ""           //Tipo do titulo
Local aBaixa		:= {}   //Array de baixas
Local lEstornOk     := .T.  //Estorno correto
Private lMsErroAuto := .F.                  	//Controle de erro na rotina automatica									// Decimais	

Default cOrc := ""
Default lOrc_MovFe := .F.
Default cOrc_Doc := "" 
Default cOrc_Serie := ""
Default aPagtos := {}
Default lJob := .F.

If !lOrc_MovFe //Movimento do caixa aberto ou Venda realizada com cliente NÃO padrao

	//Verifica se houve pagamento em dinheiro - estorna o pagamento e marca como estornado
	While lEstornOk .and. (nPos := nPos + 1) <= Len(aPagtos)
		If IsMoney(aPagtos[nPos, __L4_FORMA])
		
			//Busca o título referente ao pagamento em dinheiro		   		   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona no SE1 antes de executar o FINA330 ,		  ³
			//³Ajusta o tamanho dos campos L1_DOC e E1_PARCELA		  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			
			cParcela	:= PadR(aPagtos[nPos, __E1_PARCELA],TamSX3("E1_PARCELA")[1])
			cTipo       := PadR(aPagtos[nPos,__L4_FORMA], TamSX3("E1_TIPO")[1])    
			cOrc_Serie  := PadR(cOrc_Serie, TamSX3("E1_PREFIXO")[1] )
			cOrc_Doc    := PadR(cOrc_Doc, TamSX3("E1_NUM")[1])
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona no SE1 antes de executar o FINA330³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SE1")
			DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                               
			If DbSeek(xFilial("SE1") + cOrc_Serie + cOrc_Doc + cParcela + cTipo )
	

				nOpBaixa := 1
				aBaixa := {}
				
				AADD(aBaixa , {"E1_FILIAL"    , SE1->E1_FILIAL		, NIL})
				AADD(aBaixa , {"E1_PREFIXO"   , SE1->E1_PREFIXO		, NIL})
				AADD(aBaixa , {"E1_NUM"       , SE1->E1_NUM			, NIL})
				AADD(aBaixa , {"E1_PARCELA"   , SE1->E1_PARCELA		, NIL})
				AADD(aBaixa , {"E1_TIPO"      , SE1->E1_TIPO		, NIL})
				AADD(aBaixa , {"E1_CLIENTE"   , SE1->E1_CLIENTE		, NIL})
				AADD(aBaixa , {"E1_LOJA"      , SE1->E1_LOJA		, NIL})
				
				MSExecAuto({|x, y, z, v| Fina070(x, y, z, v)}, aBaixa, 5, .F., 1 )
				
				If lMsErroAuto
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| "  Tipo: "   |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DisarmTransaction()
					If lJob
						ConOut(space(23) + AnsiToOem("Lj601EstDinh - " + STR0001 + SE1->E1_PREFIXO + " " + SE1->E1_NUM + SE1->E1_PARCELA)) //"Problemas no estorno da baixa do título: "
					Else 
						MsgAlert(STR0001 + SE1->E1_PREFIXO + " " + SE1->E1_NUM + SE1->E1_PARCELA)//"Problemas no estorno da baixa do título: "
					EndIf  
					
					lEstornOk := .F.
				Else      
					aPagtos[nPos, __L4lEstorn] := .T. 
					
				EndIf			
			
			EndIf
			    		   
	
		EndIf 
	End
 
EndIf

RestArea(aArea)

Return lEstornOk 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj601GeraNFE ³ Autor ³ Vendas Cliente        ³ Data ³14/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Geração da Nota Fiscal de Entrada                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj601EstDinh(ExpC1, ExpC2, ExpC3,ExpC4, ExpC5, ExpC6, ExpC7   ³±±
±±³			 ³              ExpC8, ExpC9, ExpN10,ExpN11, ExpL12)             ³±±
±±³			 ³ExpC1 - Caixa onde foi realizado o estorno 			         ³±± 
±±³			 ³ExpC2 - Numero do documento de Saida   					     ³±± 
±±³			 ³ExpC3 - Serie do documento de saida     					     ³±±
±±³			 ³ExpC4 - Cliente da Nota Fiscal de Entrada/Saida                ³±±
±±³			 ³ExpC5 - Loja da Nota Fiscal de Entrada/Saida					 ³±± 
±±³			 ³ExpC6 - Codigo do Diario 			                             ³±± 
±±³			 ³ExpC7 - Motivo de Estorno		                                 ³±±
±±³			 ³ExpC8 - Numero da Nota Fiscal de Entrada					     ³±± 
±±³			 ³ExpC9 - Serie da Nota Fiscal de Entrada					     ³±± 
±±³			 ³ExpN10 - Total da Nota Fiscal de Entrada 	                     ³±±
±±³			 ³ExpN11 - Impostos da Nota Fiscal de Entrada				     ³±± 
±±³			 ³ExpL12 - Execução em Job     					                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Automacao Comercial									  	     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function Lj601GeraNFE(  cCaixaEst	, cOrc_Doc	, cOrc_Serie ,	cCliOri ,; 
						cLojaOri	, cCodDia	, cMotivo	 ,	cNumDoc	,; 
						cSerieDoc	, nVlrTotal	, nImpostos	 ,	lJob 	,;
						cNewCli 	, cNewLoja 	, aDocDev )

Local lRet			:= .T.					   		//Retorno da funcao
Local aArea			:= GetArea()					//Armazena o posicionamento atual
Local aAreaSD2		:= SD2->(GetArea())			//Guarda a area do SD2
Local nI			:= 0					   		//Contador 
Local lRestArea     := .F.                    		//Controla se deve restaurar a area da MATXFIS
Local aPosSd2		:= {}							//Guarda a posicao do SD2
Local cPrefixoEnt	:= ""							//Prefixo de entrada
Local cPrefixoSaida	:= ""							//Prefixo de Saida							
Local cDocOri		:= ""							//Documento original da venda
Local cSerOri		:= ""							//Serie original da venda
Local cFilSD2		:= xFilial("SD2")				//Filial da tabela SD2
Local nCount		:= 0
Local cPadrao	:= "704"                                    	// Codigo Padrao
Local lPadrao  := VerPadrao(cPadrao)							// verifica padrao
Local nHdlPrv  := 0											// Contabilizacao
Local nTotal   := 0											// Contabilizacao
Local cArquivo := ""											// Contabilizacao
Local lAglutina := .T.	                                       //contabilizacao
				                                              //Contabilizacao

Default cCaixaEst     := ""                   	
Default cOrc_Doc	  := ""                           
Default cOrc_Serie    := ""                   		
Default	cCliOri		  := ""							//Cliente original da venda
Default cLojaOri	  := ""							//Loja original da venda                 		
Default cNumDoc		  := ""                         
Default cCodDia     := ""                   		//Codigo do Diario - ver parametro
Default cMotivo		:= ""                           //Motivo de devolucao  -ver parametro   
Default cSerieDoc     := ""                   	
Default nVlrTotal	  := 0                           
Default nImpostos    := 0                   		
Default lJob		  := .F.                           
Default cNewCli	  	  := ""                         //Novo cliente para estorno.
Default cNewLoja	  := ""                         //Nova loja para estorno.  
Default aDocDev		  := {}							//Itens da venda original


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza um backup das variaveis fiscais para depois restaura-las, pois³
//³a rotina automatica reinicializa a funcao fiscal.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If MaFisFound() 
	MafisSave()
	MafisEnd()
	lRestArea  := .T.
Endif	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma os produtos vendidos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDocOri := PadR(cOrc_Doc, TamSX3("D2_DOC")[1])   
cSerOri := PadR(cOrc_Serie, TamSX3("D2_SERIE")[1])

                                                                                                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cancela a ordem de serviço do produto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction("Lj7HasDtEM") .And. Lj7HasDtEM()
 	DbSelectArea("SD2")
	DbSetOrder(3)//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA                                                                                             
	SD2->(DbSeek( cFilSD2 + cDocOri +  cSerOri + cCliOri + cLojaOri))
	While !SD2->(Eof())				.AND.;
		SD2->D2_DOC		== cDocOri	.AND.;
		SD2->D2_SERIE	== cSerOri	.AND.;
		SD2->D2_CLIENTE	== cCliOri	.AND.;
		SD2->D2_LOJA	== cLojaOri
	
		Lj7EliProdPed( SD2->D2_PEDIDO, SD2->D2_COD )
		SD2->(DbSkip())
	End
	RestArea(aAreaSD2)
EndIf


RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Geracao do documento de entrada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob           

	MsgRun(STR0002 ,,{||lRet:=Lj601DevSD2(	cCaixaEst	, cCliOri	, cLojaOri	, cDocOri	,;//"Aguarde, gerando documento de entrada..." 
											cSerOri		, @cNumDoc  , @cSerieDoc, @nVlrTotal,;
											@aPosSd2	, @aDocDev	, cCodDia	, cMotivo	,;
											nImpostos	, lJob		, cNewCli	, cNewLoja   )} )  	 
Else
	ConOut("Lj601GeraNFE - "+AnsiToOem(STR0003))//"Gerando documento de entrada."
	lRet:=	Lj601DevSD2(  cCaixaEst	, cCliOri   , cLojaOri  , cDocOri	,;
	                      cSerOri	, @cNumDoc  , @cSerieDoc, @nVlrTotal,;
	                      @aPosSd2	, @aDocDev	, cCodDia	, cMotivo	,;
	                      nImpostos	, lJob		, cNewCli	, cNewLoja   )
EndIf
//

If lRet .AND. lPadrao .AND. cPaisLoc == "MEX"
					
	nHdlPrv:=HeadProva("","LOJA601",Substr(cUsername,1,6),@cArquivo)  //contabilizacao
					
	If  nHdlPrv > 0
		nTotal+=DetProva(nHdlPrv,cPadrao,"LOJA601","")     //contabilizacao
	EndIf
							
	If  nTotal > 0
		RodaProva(nHdlPrv,nTotal)
		cA100Incl(cArquivo,nHdlPrv,3,"",.F.,lAglutina, 'N')      //contabilizacao
	EndIf				
	



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Elimina do laboratorio Registro Devolvido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	If  Hastemplate("OTC") 
		T_OtcDelDev(aDocDev)   	   	
	EndIf   


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recalcula para comissao em aberto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		LJ720RecComis( aPosSd2 )	
	Endif

EndIf		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a funcao fiscal com base nos dados backupados anteriormente.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lRestArea
	MafisRestore()
Endif
                               	
RestArea(aAreaSD2)
RestArea(aArea)	                
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj601DevSD2  ³ Autor ³ Vendas Cliente        ³ Data ³14/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Geração da Nota Fiscal de Entrada - Detalhamento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj601EstDinh(ExpC1, ExpC2, ExpC3,ExpC4, ExpC5, ExpC6, ExpC7   ³±±
±±³			 ³           ExpN8, ExpA9, ExpA10,ExpC11, ExpC12, ExpN13, ExpL14)³±±
±±³			 ³ExpC1 - Caixa onde foi realizado o estorno 			         ³±± 
±±³			 ³ExpC2 - Cliente da Nota Fiscal de Entrada/Saida                ³±±
±±³			 ³ExpC3 - Loja da Nota Fiscal de Entrada/Saida					 ³±± 
±±³			 ³ExpC4 - Numero da Nota Fiscal de Saida					     ³±± 
±±³			 ³ExpC5 - Serie da Nota Fiscal de Saida					         ³±± 
±±³			 ³ExpC6 - Numero da Nota Fiscal de Entrada					     ³±± 
±±³			 ³ExpC7 - Serie da Nota Fiscal de Entrada					     ³±± 
±±³			 ³ExpN8 - Total da Nota Fiscal de Entrada 	                     ³±±
±±³			 ³ExpA9 - Itens Estornados			                             ³±± 
±±³			 ³ExpA10 - Documento de Estorno		                             ³±±
±±³			 ³ExpC11 - Codigo do Diario 			                         ³±± 
±±³			 ³ExpC12 - Motivo de Estorno		                             ³±±
±±³			 ³ExpN13 - Impostos da Nota Fiscal de Entrada				     ³±± 
±±³			 ³ExpL14 - Execução em Job     					                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Automacao Comercial									  	     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function Lj601DevSD2( cCaixaEst     , cCliente  , cLoja     , cNotaOri 	,;
                      cSerieOri		, cNumDoc   , cSerieDoc	, nVlrTotal ,;
                      aPosSd2 		, aDocDev	, cCodDia 	, cMotivo	,; 
                      nImpostos		, lJob		, cNewCli	, cNewLoja  )

Local lRet			:= .T.                                	// Retorno da funcao, valida rotina automatica
Local aArea     	:= GetArea()                          	// Area corrente
Local aAreaSF2  	:= SF2->(GetArea())                   	// Area do arquivo SF2
Local aCab      	:= {}                                 	// Contem os campos e valores correspondentes para geracao da NF de devolucao
Local aLinha    	:= {}                                 	// Contem os itens do documento de entrada utilizado para a rotina automatica
Local aItens    	:= {}     							   	// Contem os itens do documento de entrada utilizado para a rotina automatica
Local cTipoNF   	:= ""                                 	// Tipo do documento de entrada
Local nCntSD2   	:= 0                                  	// Contador de numero de itens
Local lDevolucao	:= .T.                                	// Controla se dados invalidos
Local lPoder3   	:= .T.                                	// Valida se o TES controla poder de terceiros
Local nX        	:= 0                                  	// Controle de loop
Local cTesDev   	:= SuperGetMv("MV_TESTROC",.F.)      	// TES padrao para troca/devolucao
Local cSerie    	:= Padr(SuperGetMv("MV_LJNFTRO"),3)  	// Serie padrao para troca/devolucao
Local cNewDoc		:= CriaVar("F1_DOC",.F.)				// Numero do documento de entrada gerado
Local cMv_CondPad	:= SuperGetMv("MV_CONDPAD")				// Condicao de pagamento padrao
Local lUsafd      	:= SuperGetMV("MV_LJUSAFD",,.F.) 		// Parametro que define se o cliente utiliza Vale Compra
Local cFilSD2       := xFilial("SD2")            
Local cGrupoProd	:= ""									//Grupo de produtos
Local aProdCri		:= {}									// Array com os produtos para analise de criterio de pontos
Local nTotDev		:= 0                                    // Total devolvido para controle da pontuacao da fidelidade
Local cMV_TPNRNFS	:= LJTpNrNFS()							// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local cCliPad 		:= SuperGetMV("MV_CLIPAD",,"")  		// parametro que indica o CLIENTE PADRAO
Local cTipo			:= "2"									// Tipo da Operacao: 2 = devolucao
Local nPosTot		:= 0									// Posicao do total da devolucao	
Local nPosProd		:= 0									// Posicao do produto 
Local nPosQtd		:= 0 									// Posicao da quantidade
Local cFormul       := "S"                                   // Formulario proprio
Local cTpEspecie    := ""                                   // Especie do documento
Local cTipoDoc      := ""                                   // Tipo da NF
Local aAreaSF4												// Area do arquivo SF4
Local cCfOpF4		:= ""									// Codigo Fiscal do SF4
Local aRecAltSD2	:= {}									// alterada valor do SD2
Local nMoedaOri     := 1                                    // Moeda da Nota Fiscal de Origem
Local nTxMoedaOri   := 1                                    // Taxa da moeda a nota fiscal de Origem
Local aVales        := {}									// Array com os vales compras utilizado na venda
Local cOper                                                 //Operacao
Local cTiposDoc 	:= AllTrim( SuperGetMv( 'MV_ESPECIE',,"" ) )	// Tipos de documento (busca no param. MV_ESPECIE)
Local aCFD			:= {}
Local nCount     	:= 0										// Usada em lacos For..Next
Local nPosSign 		:= 0										// Posicao do sinal dentro da string
Local aDados		:= {}                                       //controle de folios
Local aRetCF		:= {}										//controle de folios
Local aAreaSD2      := SD2->(GetArea())                         //Area SF2
Local lContrFol     :=	SF1->(FieldPos("F1_NUMAUT")) > 0 .And. SF1->(FieldPos("F1_CODCTR")) > 0 .And.;
						SF2->(FieldPos("F2_NUMAUT")) > 0 .And. SF2->(FieldPos("F2_CODCTR")) > 0 .And.;
						SF2->(FieldPos("F2_LIMEMIS")) > 0 .And. SF3->(FieldPos("F3_NUMAUT")) > 0 .And.;
						SF3->(FieldPos("F3_CODCTR")) > 0 .And. GetNewPar("MV_CTRLFOL",.F.) //Controle folios

Local lMotDevol		:= SF1->(FieldPos("F1_MOTIVO")) > 0
Local cMV_LJDVACR 	:= AllTrim(SuperGetMV("MV_LJDVACR",,""))
Local dDtEmissao 	:= dDataBase
Local cChave        := ""

Private lMsHelpAuto := .T. 
Private lMsErroAuto := .F.    
Private cNFiscal    := ""

Default cCodDia     := ""                            
Default cMotivo		:= ""		
Default nImpostos	:= 0    
Default lJob 		:= .T.
Default cCaixaEst 	:= ""     
Default cCliente 	:= "" 
Default cLoja		:= ""     
Default cNewCli    	:= ""
Default cNewLoja   	:= ""    
Default cNotaOri 	:= ""
Default cSerieOri	:= ""
Default cNumDoc		:= ""
Default cSerieDoc	:= "" 
Default nVlrTotal	:= 0
Default aPosSd2 	:= {}	
Default aDocDev		:= {}
					  

If Empty(cTiposDoc) .OR. cPaisLoc <> "BRA"
	cTpEspecie  := CriaVar("F1_ESPECIE",.T.)
	If Empty(cTpEspecie)
	   cTpEspecie  := PadR("NF",Len(SF1->F1_ESPECIE))
	Endif             
Else
	cTiposDoc := StrTran( cTiposDoc, ";", CHR(13)+CHR(10))
	For nCount := 1 TO MLCount( cTiposDoc )
		cTpEspecie := AllTrim( StrTran( MemoLine( cTiposDoc,, nCount ), CHR(13), CHR(10) ) )
		nPosSign := Rat( "=", cTpEspecie)
		If nPosSign > 0 .AND. AllTrim( cSerie ) == AllTrim( SubStr( cTpEspecie, 1, nPosSign - 1 ) )
			If SX5->( DbSeek( xFilial("SX5") + "42" + SubStr( cTpEspecie, nPosSign + 1 ) ) )
				cTpEspecie := SubStr( cTpEspecie, nPosSign + 1 )
			Else
				cTpEspecie := SPACE(5)
			EndIf
			Exit
		Else
			cTpEspecie := SPACE(5)
		EndIf
	Next nCount
	
EndIf
		

aRecnoSD2	:= {}  


DbSelectArea("SD2")
DbSetOrder(3)//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA                                                                                             
SD2->(DbSeek( cFilSD2 + cNotaOri +  cSerieOri + cCliente + cLoja))   

While !SD2->(Eof())				.AND.;
	SD2->D2_DOC		== cNotaOri	.AND.;
	SD2->D2_SERIE	== cSerieOri	.AND.;
	SD2->D2_CLIENTE	== cCliente	.AND.;
	SD2->D2_LOJA	== cLoja  

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda a posicao do SD2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If Len(aPosSd2) == 0
		Aadd(aPosSd2,{SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe saldo em aberto para devolver³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SD2->D2_QTDEDEV < SD2->D2_QUANT .or. SD2->D2_QTDEDEV > 0			

		DbSelectArea("SF4")
		DbSetOrder(1)
		If DbSeek(xFilial("SF4")+SD2->D2_TES)
	
			aAreaSF4 := SF4->(GetArea())		
	
			If !Empty(SF4->F4_TESDV)		    
				cTesDev := SF4->F4_TESDV	
				
				DbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek(xFilial("SF4") + cTesDev)				
				cCfOpF4 := SF4->F4_CF				
				
			ElseIf !Empty(cTesDev)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona no TES                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SF4")
				DbSetOrder(1)
				If !DbSeek(xFilial("SF4") + cTesDev)
					lRet := .F.
					If !lJob
						MsgAlert(STR0004)//"TES devolucao não encontrada."
					Else
						ConOut(space(23) + "Lj601DevSD2 - "+AnsiToOem(STR0004) ) //"TES devolucao não encontrada"
					EndIf
				Else
					cCfOpF4 := SF4->F4_CF
					If SF4->F4_PODER3<>"D"
						lPoder3 := .F.
					Endif
				Endif	
			
			Else
			
				Help(" ",1,"DSNOTESDEV")
				lRet := .F.
				Exit			
			
			Endif
		
			If SF4->F4_PODER3<>"D"
				lPoder3 := .F.
			Endif
	
			SF4->(RestArea(aAreaSF4))		
	
		Endif
    	

		cTipoNF := SD2->D2_TIPO

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula o saldo a devolver tanto normal como poder de terceiros           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                        
		nCntSD2++
		If nCntSD2 > 900  // No. maximo de Itens 
			Exit
		Endif

		Aadd(aRecAltSD2,{SD2->(Recno()),SD2->D2_QUANT,SD2->D2_CLIENTE,SD2->D2_LOJA})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a linha de devolucao que sera gerado o SD1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aLinha := {}				
		AAdd( aLinha, { "D1_COD"    , SD2->D2_COD    , Nil } )
		AAdd( aLinha, { "D1_QUANT"  , SD2->D2_QUANT, Nil } )					
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametro indica se retira o acrescimo (quando for 1)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cMV_LJDVACR == "1"
			AAdd( aLinha, { "D1_VUNIT"  , (SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR - (SD2->D2_VALACRS * SD2->D2_QUANT))/SD2->D2_QUANT, Nil })								
		Else
			AAdd( aLinha, { "D1_VUNIT"  , (SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR)/SD2->D2_QUANT, Nil })					
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for devolucao total nao calcula totais e descontos proporcionais³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


		If cMV_LJDVACR == "1"					
			AAdd( aLinha, { "D1_TOTAL"  , SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR - (SD2->D2_VALACRS * SD2->D2_QUANT),Nil } )
		Else
			AAdd( aLinha, { "D1_TOTAL"  , SD2->D2_TOTAL + SD2->D2_DESCON + SD2->D2_DESCZFR,Nil } )				
		EndIf				
		
		AAdd( aLinha, { "D1_VALDESC", SD2->D2_DESCON + SD2->D2_DESCZFR , Nil } )						
                                                
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a linha de devolucao que sera gerado o SD1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aLinha, { "D1_IPI"    , SD2->D2_IPI    , Nil } )	
		AAdd( aLinha, { "D1_LOCAL"  , SD2->D2_LOCAL  , Nil } )
		AAdd( aLinha, { "D1_TES" 	, cTesDev , Nil } )
		AAdd( aLinha, { "D1_CF" 	, cCfOpF4 , Nil } )
  		AAdd( aLinha, { "D1_UM"     , SD2->D2_UM , Nil } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe rastreabilidade              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Rastro(SD2->D2_COD)
			AAdd( aLinha, { "D1_LOTECTL", SD2->D2_LOTECTL	, ".T." } )
			AAdd( aLinha, { "D1_NUMLOTE", SD2->D2_NUMLOTE	, ".T." } )
			AAdd( aLinha, { "D1_DTVALID", SD2->D2_DTVALID	, ".T." } )
			AAdd( aLinha, { "D1_POTENCI", SD2->D2_POTENCI	, ".T." } )
		Endif
		AAdd( aLinha, { "D1_NFORI"  , SD2->D2_DOC    , Nil } )
		AAdd( aLinha, { "D1_SERIORI", SD2->D2_SERIE  , Nil } )
		AAdd( aLinha, { "D1_ITEMORI", SD2->D2_ITEM   , Nil } )
		AAdd( aLinha, { "D1_ICMSRET", SD2->D2_ICMSRET, Nil } )					

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o TES eh de poder de terceiro       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF4->F4_PODER3=="D"
			AAdd( aLinha, { "D1_IDENTB6", SD2->D2_NUMSEQ, Nil } )								
		Endif
		


		AAdd( aLinha, { "D1RECNO", SD2->(RECNO()), Nil } )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona o item no array principal que sera levado para o Documento de entrada   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aItens, aLinha )
		AAdd( aRecnoSD2, {SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_ITEM,SD2->(Recno())} )
		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao ha saldo para devolucao nao pode continuar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Else 
        If !lJob
    		MsgInfo(STR0005 + SD2->D2_COD)//"Já existe devolução para o produto"
		Else 
			ConOut(space(23) + "Lj601DevSD2 - "+ AnsiToOem(STR0005 + SD2->D2_COD))    //Já existe devolução para o produto
		EndIf
		lRet:= .F.
	Endif
   
	SD2->(DbSkip(1))						
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza a database se a data de movimento da impressora³
//³for diferente da data cronologica da impressora         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFiscal .and. !lJob
	LjEcfIFData()
Endif

DbSelectArea("SD2")
If lRet 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Armazena nas variaveis a primeira posicao do aPosSd2,³
	//³pois somente esta posicao e' utiliza para o Seek     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aPosSd2) > 0

   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona o SF2 para pegar o valor da moeda e sua taxa da NF de Origem ³
   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		DbSelectArea("SF2")
		DbSetOrder(1)     		// FILIAL + DOCUMENTO+ SERIE + CLIENTE + LOJA
		If DbSeek(xFilial("SF2")+cNotaOri+cSerieOri+ cCliente +cLoja)	
    	  nMoedaOri	 := SF2->F2_MOEDA 						
    	  nTxMoedaOri:= SF2->F2_TXMOEDA 
    	  dDtEmissao := SF2->F2_EMISSAO //Define a data do campo F1_EMISSAO igual a data do campo F2_EMISSAO, pois o estorno soh pode ser feito no mesmo dia da venda
    	EndIf  
    EndIf	


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se eh para fazer o controle do numero da nota pelo SD9 (qdo ³
	//³ cMV_TPNRNFS for igual a "3"                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
	If cMV_TPNRNFS == "3"
		cNumDoc := MA461NumNf( .T., cSerie )
	Else							    
        If !Lj601Nota(@cSerie, @cNumDoc, lJob)
	   		Return .F.
    	Endif
    Endif
    cNewDoc    := cNumDoc
	cSerieDoc  := cSerie 
	cNFiscal   := cNewDoc //variável para o Mata103 não gerar nova numeracao de NF

	If cTipoNF == "B"
	   cTipoDoc  := "N"
	Else   
	   cTipoDoc  := "B"
	Endif   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a serie esta valida - Controle de folios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContrFol .AND. !ChkFolURU(cFilAnt,cSerie,cNewDoc,Nil,.F.,"NCC")
		lRet := .F.
	    DisarmTransaction()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cancela a Sequencia de nota utilizada conforme configuracao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    Lj720CnSD9(cNewDoc, cSerie, cMV_TPNRNFS)   
	EndIf
	
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do Cabecalho da Nota fiscal de Devolucao/Retorno       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFiscal .AND. cPaisLoc == "ARG" .AND. cTpEspecie $ "NCC|NDC"
			cNewDoc := GetNumCFis(cSerie,cTpEspecie)
			cNumDoc := cNewDoc
			cNFiscal := cNewDoc
		EndIf
		AAdd( aCab, { "F1_DOC"    , cNewDoc		, Nil } )	// Numero da NF : Obrigatorio
		AAdd( aCab, { "F1_SERIE"  , cSerie		, Nil } )	// Serie da NF  : Obrigatorio
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o cabecalho de acordo com o tipo da devolucao             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lPoder3
			AAdd( aCab, { "F1_TIPO"   , "D"                  		, Nil } )	// Tipo da NF   : Obrigatorio
		Else
			AAdd( aCab, { "F1_TIPO"   , cTipoDoc	                , Nil } )	// Tipo da NF   : Obrigatorio		
		Endif
		
		//Trata alteracao de cliente/loja. (Casos que a venda foi realizada para o cliente padrao)
		If Alltrim(cCliPad) == Alltrim(cCliente) .AND. !Empty(cNewCli) .AND. !Empty(cNewLoja)
		   	AAdd( aCab, { "F1_FORNECE", cNewCli    						, Nil } )	// Codigo do Fornecedor : Obrigatorio
			AAdd( aCab, { "F1_LOJA"   , cNewLoja   	   					, Nil } )	// Loja do Fornecedor   : Obrigatorio	
		Else 
			AAdd( aCab, { "F1_FORNECE", cCliente    					, Nil } )	// Codigo do Fornecedor : Obrigatorio
			AAdd( aCab, { "F1_LOJA"   , cLoja    	   					, Nil } )	// Loja do Fornecedor   : Obrigatorio
		EndIf 
		
		AAdd( aCab, { "F1_RECBMTO", dDtEmissao	           			, Nil } )	// Data de Digitacao
		AAdd( aCab, { "F1_EMISSAO", dDtEmissao           			, Nil } )	// Emissao da NF        : Obrigatorio
		AAdd( aCab, { "F1_FORMUL" , cFormul                        , Nil } )   // Formulario Proprio
		AAdd( aCab, { "F1_ESPECIE", cTpEspecie                     , Nil } )  // Especie
		AAdd( aCab, { "F1_COND"   , cMv_CondPad   	  				, Nil } )	// Condicao do Fornecedor
		
		If cPaisLoc <> "BRA" 
			AAdd( aCab, { "F1_TIPODOC" 	, "04"   	  				, Nil } )	// Tipo de documento
			AAdd( aCab, { "F1_MOEDA"   	, nMoedaOri		   	  		, Nil } )	// Numero da Moeda
			AAdd( aCab, { "F1_TXMOEDA" 	, nTxMoedaOri		   	  	, Nil } )	// Taxa da Moeda
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nota fiscal eletronica Mexico             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If cPaisLoc == "MEX" .AND. AliasIndic("MDL") .AND. SA1->(FieldPos("A1_MODCFD")) > 0
				If (CFDChkFol(xFilial("SF2"),SF2->F2_SERIE,SF2->F2_DOC,@aCFD,.F.,.T.) == 0)
					AAdd( aCab, { "F1_APROFOL" 	, aCFD[1]		   	  	, Nil } )	// Numero da aprovacao do Folio
					AAdd( aCab, { "F1_CERTFOL" 	, aCFD[2]		   	  	, Nil } )	// Certificado folio	
				EndIf
			EndIf		
			
		EndIf
	
		If cPaisLoc == "ARG" .AND. lFiscal
			AAdd( aCab, { "F1_ECF" 	, "1"		   	  				, Nil } )	// Indica que ira imprimir
		EndIf
	
		If cPaisLoc == "PTG"    // Portugal
			AAdd( aCab, { "F1_DIACTB" 	, cCodDia   	  				, Nil } )	// Codigo do Diario
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para controle de Folios³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lContrFol
			
			aDados := Array(6)
		
			aDados[1] := cSerie
			aDados[2] := cTpEspecie
			aDados[3] := cNewDoc
			If Alltrim(aDados[2]) $ "NDI/NCP"
				aDados[4] := GetAdvFVal("SA2","A2_CGC",xFilial("SA1")+cCliente+cLoja,1,"")
			Else
				aDados[4] := GetAdvFVal("SA1","A1_CGC",xFilial("SA1")+cCliente+cLoja,1,"")
			Endif
			aDados[5] := DtoS(dDataBase)
			aDados[6] := 0//Round(SL1->L1_VALBRUT,0)
			
			aRetCF := RetCF(aDados)
			
			AAdd( aCab, { "F1_NUMAUT"   , aRetCF[1]		, Nil } )
			AAdd( aCab, { "F1_CODCTR"   , aRetCF[2]		, Nil } )
		
		EndIf

		
                                                 
		
		If lMotDevol
			AAdd( aCab, { "F1_MOTIVO"   , cMotivo		, Nil } )
		Endif
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ha itens a serem devolvidos                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aItens) > 0 .AND. lRet
	
			RetIndex("SD2")	
	
			If cPaisLoc == "BRA"
				Mata103( aCab, aItens , 3)                         
			Else
				Mata465n( aCab, aItens , 3)		
			EndIf
			
			If !lMsErroAuto
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Acerta o campo de devolucao caso o cliente da venda, seja diferente do cliente da entrada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 to Len(aRecAltSD2)
					If (aRecAltSD2[nX][3] + aRecAltSD2[nX][4]) <> (cCliente + cLoja)
						DbSelectArea("SD2")                                        
						DbGoTo(aRecAltSD2[nX][1])
						RecLock("SD2",.F.)
						Replace D2_QTDEDEV With aRecAltSD2[nX][2]
						MsUnLock()
					EndIf
				Next nX
			        
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se Existir o Campo F1_NumMov,Grava o Numero do Ultimo Movimento do SLW ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF1->(!EOF())
					If SF1->(FieldPos("F1_NUMMOV"))>0
						RecLock("SF1",.F.)
						REPLACE SF1->F1_NUMMOV WITH LJNumMov()
						MsUnLock("SF1")
					Endif
				EndIf	
				
				If cPaisLoc == "ARG"
					cNewDoc := SD1->D1_DOC
					cSerie	:= SD1->D1_SERIE
				EndIf
		    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    	//³Analise de credito integrada com SIGACRD                           ³
		    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    	If CrdxInt() .AND. lUsafd                                                           
		                                 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Nao pontuar quando for cliente padrao.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    		If AllTrim(cCliPad) <> AllTrim(cCliente)	                                 
		    		    
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Localiza a posicao do produto e do total da devolucao no array³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    		    nPosTot		:= aScan(aItens[1],{|x| AllTrim(x[1])=="D1_TOTAL"})
						nPosProd	:= aScan(aItens[1],{|x| AllTrim(x[1])=="D1_COD"})	
		        		nPosQtd		:= aScan(aItens[1],{|x| AllTrim(x[1])=="D1_QUANT"})					
		                                  
						For nX := 1 to Len(aItens)	
						   cGrupoProd :=  Posicione("SB1",1,xFilial("SB1")+aItens[nX][nPosProd][2] ,"SB1->B1_GRUPO")
						   AADD ( aProdCri, { aItens[nX][nPosProd][2], cGrupoProd , ( aItens[nX][nPosTot][2]) , (aItens[nX][nposQtd][2]) } )
						   nTotDev += ( aItens[nX][nPosTot][2] )
						Next nX     
					                        			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Chama a funcao para devolucao dos pontos. somente e utilizada se    ³
						//³o sistema tiver integracao com o CRD.                               ³
						//³OBS: Esta rotina gera um registro no MAX com o campo saldo negativo.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If	Crd240_002(	cTipo			,;	// Tipo da Operacao: 1)Venda 2)Devolucao 3)Exclusao
										cCliente  		,;	// Codigo do cliente
										cLoja			,;	// Loja 
										aProdCri		,;	// Array com os produtos para analise dos pontos
										nTotDev			,;	// Total da Venda
										cNotaOri 	    ,;	// Numero do documento  - Trocado cNewDoc para SL1->L1_DOC
										cSerie			,;	// Serie
										cNotaOri		,; 	// Documento da venda original
										cSerieOri		,;	// Serie da venda original 
										Nil				,; 	// Identifica se e do Loja ou do Televendas       
										Nil				,; 	// Indica se grava MAX ou somente calcula pontos
										Nil				,; 	// Total de pontos							   
										Nil				) 	// Pagamento com Vale-Compra calcular sobre a dif.
		
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Volta status do vale compra utilizado na venda ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If AliasInDic("MB1")                       // Verifica existencia da tabela
								DbSelectArea("MB1")
								DbSetOrder(2) // MB1_FILIAL+MB1_SERIE+MB1_NF+MB1_CODIGO
								If DbSeek(xFilial("MB1") + cSerieOri + cNotaOri)
									While !EOF() .AND. MB1->MB1_FILIAL + MB1->MB1_SERIE + MB1->MB1_NF == xFilial("MB1") + cSerieOri + cNotaOri
										If MB1->MB1_OPER == 3 .OR. MB1->MB1_OPER == 2	// Utilizado ou Resgatado
									 		aVales := {{MB1->MB1_CODIGO, Nil, Nil, MB1->MB1_CODIGO, .F.}}
									 		
									 		If MB1->MB1_OPER == 2
									 			cOper := "4"
									 		ElseIf MB1->MB1_OPER == 3 	             
									 			cOper := "2"
									 		EndIf						 		
									 		
									 		// Em caso de devolucao altera o status do vale compra
									  		If !Crd240UpdMAV( aVales, cOper )	
												If !lJob
													Aviso(STR0006,STR0007,{STR0008} ) //"Atenção", "Falha no cancelamento dos pontos referente a campanha de fidelização." ,"Ok" 
												Else
													ConOut(space(23) + "Lj601DevSD2 - " + AnsiToOem(STR0007) )//"Falha no cancelamento dos pontos referente a campanha de fidelização"
												EndIf	
											Else
										 		aVales := {MB1->MB1_CODIGO,Nil,Nil,MB1->MB1_CODIGO,.F.}
									 			CRDA270Log( aVales, cOper, cNewDoc, AllTrim( LjGetStation("LG_PDV") ), cSerie, cCliente  )			 	
											EndIf	
										EndIf
										DbSelectArea("MB1")
										DbSkip()
									End	
								EndIf
							EndIf	
						EndIf					
					EndIf
				EndIf
			EndIf
	
			If lMsErroAuto
			    DisarmTransaction()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cancela a Sequencia de nota utilizada conforme configuracao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    Lj720CnSD9(cNewDoc, cSerie, cMV_TPNRNFS)
			    
				If !lJob
					MOSTRAERRO()
				EndIf
				lRet:= .F. 
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza os campos do processo do SIGALOJA³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				Lj720AtuNfe( cNewDoc   , cSerie, cCliente, cLoja , ;
				   			 2 , 2, cMotivo, @nImpostos, cCaixaEst, .T. )

	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se selecionar as opcoes "Devolucao" e "Dinheiro", exclui a NCC gerada e gera registro de ³
				//³saida de numerario 																	    ³			
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				aDocDev  := {cSerie,cNewDoc,cCliente, cLoja, 2 , cNotaOri , {} }   
				
				//Posiciona no SE1 e busca o total da Nota, devido à problemas com ICMS Solidario 
				DbSelectArea("SE1")
				DbSetOrder(1)
   				If DbSeek(xFilial("SE1") + cSerieOri + cNotaOri)  
   					cChave :=  xFilial("SE1") + cSerieOri + cNotaOri
					While SE1->(!Eof()) .and. cChave == SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM  
						If SE1->E1_VlrReal > 0
							nVlrTotal += SE1->E1_VlrReal 
						Else
							nVlrTotal += SE1->E1_VALOR
						EndIf
						SE1->(DbSkip())
					EndDo
				EndIf
				
			
			   	If lJob
			    	ConOut(space(23) + "Lj601DevSD2 - "+ AnsiToOem(STR0008+ cNewDoc + " / " + cSerie)) //"Foi gerado o documento de entrada "
			    EndIf
			Endif
		EndIf
			
	Else
		Help(" ",1,"OMS320NFD") //Nota Fiscal de devolucao ja gerada
		lRet:= .F.
	Endif
Endif

RestArea( aArea )
RestArea( aAreaSF2 )
RestArea(aAreaSD2)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj601Nota ³ Autor ³ Vendas Cliente        ³ Data ³22/10/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controle de numeracao do documento de entrada, permitindo o ³±±
±±³			 ³controle tanto pelo SXE/SXF quanto pelo SX5				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Lj601Nota(ExpC1, ExpC2, ExpL3)       						  ³±±
±±³			 ³ExpC1 - Serie padrao de devolucao			   		          ³±±
±±³			 ³ExpC2 - Numero do documento de devolucao					  ³±± 
±±³			 ³ExpL3 - Execução em Job     					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Automacao Comercial										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj601Nota(cMVSerie, cNumDoc, lJob)      


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis Locais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpcA 	 := 0									// Opcao da tela de selecao da serie
Local nSaveSx8 	 := GetSx8Len()							// Controle do SXE/SXF
Local nCntErro   := 0									// Contador de tentativas de lock do registro do SX5
Local nTamNota   := TamSx3("F1_DOC")[1]					// Tamanho do campo F1_DOC
Local aSerNf     := {}									// Series e numeros respectivos cadastrados na tabela 01 do SX5
Local cCadastro  := "Notas"								// Titulo da janela: "Notas"
Local cVarQ      := "  "								// Variavel da serie escolhida
Local cMV_LJNRNFS:= SuperGetMv("MV_LJNRNFS",.F.,"2")	// Parametro que controla o tipo de numeracao
														// 1 - Numeracao controla pelo SX5
														// 2 - Numeracao controla pelo SXE/SXF
														// 3 - Numeracao controla pelo SD9
Local lDone      := .F.									// Controle da tela de selecao da serie/numero
Local lAbandona  := .F.									// Controle da tela de selecao da serie/numero
Local lInterno   := .T.									// Controle da tela de selecao da serie/numero
Local lAvanca    := SuperGetMV("MV_LJAVANC")			// Controla se permite alterar o numero da NF sugerida
Local cMV_TPNRNFS	:= LJTpNrNFS()						// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local aLockSX5[0]										// Matriz com os recnos dos registros travados no SX5.
Local lReturn    	:= .T.								// Valor que sera retornado pela funcao.
Local oQual												// Objeto do list box das series cadastradas
Local oDlg												// Objeto do dialog
Local cFilSx5		:= If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5")) // Retorna Filial SX5	

Default lJob 	:= .T.
Default cMVSerie := ""
Default cNumDoc  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz um tratamento diferenciado para o controle de NF pelo SD9 quando ³
//³ o parametro MV_TPNRNFS for igual a "3"                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMV_TPNRNFS == "3"
	If Empty( cMvSerie )
		If !Sx5NumNota( Nil, cMV_TPNRNFS )
			Return .F.
		Else
			Return .T.
		Endif
	Else
		Return .T.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso o Parƒmetro MV_LJNFTRO estiver vazio, Desenha  ³
//³ a tela para escolha do Nota/Serie			        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_LJNFSXE")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o tratamento de pegar o numero da nota via semaforo ou via           ³
	//³ SX5 (tabela 01)                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a serie estiver em branco abre a tela para a escolha do usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cMvSerie)
		If lJob
			Return .F.
		EndIf
		If !Sx5NumNota(@cMvSerie, cMV_LJNRNFS)
			Return .F.
		Endif
	Endif
	cNumDoc := NxtSX5Nota( cMVSerie,,cMV_LJNRNFS,lAvanca )
	cNumDoc := PadR( cNumDoc , TamSx3("F2_DOC")[1] )	
	If !LjValNota(cMVSerie,cNumDoc) // Varifica se jah existe a nota
		Return .F.
	Endif
	While (GetSX8Len() > nSaveSx8 )
		ConfirmSX8()
	End
ElseIf Empty(cMvSerie)

    If !lJob
		DbSelectArea("SX5")
		While !lAbandona .AND. DbSeek( cFilSx5+"01",.F. ) .AND. !lDone
			lInterno := .T.
			While cFilial+"01" == X5_FILIAL+X5_TABELA .AND. !lAbandona
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se a S‚rie for CPF, n„o mostra no aChoice, pois ‚ utilizada ³
				//³ internamente para emissao de Cupom Fiscal.	   			     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (AllTrim(SX5->X5_CHAVE) == "CPF") .OR. ;
					(AllTrim(SX5->X5_CHAVE) == "CP")
				Else
					If !MsRLock()
						lInterno := .F.
						lDone    := .F.
						aSerNF   := {}
						If (++nCntErro > 10)
							lAbandona := .T.
						Endif
						Loop
					Else
						aAdd(aLockSX5, RecNo())
						
						If !lAbandona
							If !(ValType(aSerNF) == "A")
								aSerNF := {}
							Endif
							lDone := .T.
							AADD( aSerNF,{ Padr( X5_CHAVE, 3 ), StrZero( Val( X5Descri() ), nTamNota ) } )
						Endif
					Endif
				Endif
				DbSkip()
			End
		End
		
		If (Len(aSerNF) == 0) .OR. lAbandona
			MsUnlock()
			Help(" ",1,"A460FLOCK")
			lReturn := .F.
		Endif
		
		If lReturn
			nOpcA := 0
			While nOpcA <> 1
				DEFINE MSDIALOG oDlg TITLE "Notas" From 10,30 To 19,68 OF oMainWnd
				//"Serie"
				@ .5,.80 LISTBOX oQual VAR cVarQ Fields HEADER "Serie","Notas" SIZE 130,42 ON DBLCLICK (aSerNF:=LjxDX5Troca(oQual:nAt,aSerNF),oQual:Refresh()) NOSCROLL
				oQual:SetArray(aSerNF)
				oQual:bLine := { || {aSerNf[oQual:nAT,1],aSerNf[oQual:nAT,2]}}
				
				DEFINE SBUTTON FROM 51,109	TYPE 1 ACTION ;
				(If(LjxDANf(oQual,aSerNF,@cMVSerie,@cNumDoc),( nOpcA := 1, oDlg:End()),)) ENABLE OF oDlg
				
				ACTIVATE MSDIALOG oDlg
			End
			
			DbSelectArea("SX5")
			If DbSeek( cFilSx5+"01"+cMVSerie,.F. )
				MsRLock()
			    REPLACE X5_DESCRI  WITH PadR( StrZero(Val(cNumDoc)+1,Len(AllTrim(cNumDoc))) , nTamNota)
			    REPLACE X5_DESCSPA WITH PadR( StrZero(Val(cNumDoc)+1,Len(AllTrim(cNumDoc))) , nTamNota)
			    REPLACE X5_DESCENG WITH PadR( StrZero(Val(cNumDoc)+1,Len(AllTrim(cNumDoc))) , nTamNota)
				MsUnlock()
			Else
				MsUnlock()
				Return(.F.)
			Endif
		Endif
		aEval( aLockSX5, {|x| dbGoTo(x), MsUnlock() })    
	Else  
		ConOut("Lj601Nota - "+AnsiToOem(STR0009)) //Serie do documento fiscal devolucao não definida.
		lReturn := .F.
	EndIf	
Else
	DbSelectArea("SX5")
	DbSeek(cFilSx5+"01"+cMvSerie)
	If Eof()
		HELP(" ",1,"ERROSERIE")
		lReturn := .F.
	Else
		cNumDoc := NxtSX5Nota( cMVSerie )

	    // Quando a quantidade de digitos da NF for 6 (menor que o campo F1_DOC - 09),
	    // preencher com espacos a direita do conteudo para efeito de pesquisa.
		cNumDoc := PadR( cNumDoc, TamSX3( "F1_DOC" )[1] )
	Endif
Endif


Return lReturn
       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj601TxAdmºAutor  ³Vendas CRM          º Data ³  15/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Elimina possiveis residuos referentes a pagamentos efetuadosº±±
±±º          ³utilizando adm. financeira com taxa de cobranca.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ExpC1 - Numero do titulo original                           º±±
±±º          ³ExpC2 - Serie do titulo original                            º±±
±±º          ³ExpC3 - Codigo do cliente                                   º±±
±±º          ³ExpC4 - Loja do cliente           						  º±±   
±±º          ³ExpC5 - Caixa onde foi realizado o estorno				  º±±
±±º          ³ExpA6 - Pagamentos ExpA05[N,22], vide define acima          º±± 
±±º          ³ExpA7 - Pagamentos estornados						          º±±     
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA720                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function Lj601TxAdm(  cNumTit	, cPrefixo	, cCliente  ,cLoja     ,;
					  cCaixaEst	, aPagtos	, aPagtosExt	)

Local aArea	   			:= GetArea()				// Armazena o posicionamento atual
Local aAreaSE1 			:= SE1->(GetArea())		// Armazena o posicionamento atual da tabela SE1
Local aAreaSAE			:= SAE->(GetArea())		// Armazena o posicionamento atual da tabela SAE
Local lDevTotal			:= .F.						// Indica se a devolucao foi total ou a ultima parcela de uma devolucao parcial
Local nPos				:= 0				   		// Indice do Pagamento no Array aPagtos
Local nSldProd			:= 0						// Saldo de produtos a serem devolvidos apos o processo
Local nSaldoTit			:= 0				   		// Saldo dos titulos gerados para a venda
Local cFilSE1			:= xFilial("SE1")	   		// Filial da tabela SE1
Local nResiduo			:= 0						// Valor residual a ser abatido
Local cParcela			:= ""						// Parcela do titulo gerado
Local nTamE1_PARCELA	:= TamSX3("E1_PARCELA")[1]	// Tamanho do campo E1_PARCELA
Local cNatureza			:= ""						// Natureza a ser gravada no titulo
Local aVetMsExAut		:= {}						// Campos do titulo a ser gerado pela MsExecAuto
Local cPortador			:= ""						// Portador do titulo
Local lTemResid			:= .F.						// Indica de tem residuo ( CR )
Local nVlrTotal         := 0                        //Valor total das Vendas estornadas    
Local nC				:= 0                        //Contador
Local nTamTipo          := TamSx3("E1_TIPO")[1]     //Tamanho do campo E1_TIPO
Local nMoedaCorT		:= 1                        //Moeda corrente
Private lMsErroAuto		:= .F.						// Controle para execucao da execauto   


Default cNumTit := ""
Default cPrefixo := ""	
Default cCliente := "" 
Default cLoja := ""
Default cCaixaEst := ""
Default aPagtos	:= {}
Default aPagtosExt := {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma o total dos Pagamentos estornados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While (nC := nC +1) <= Len(aPagtos)     //parcela, Tipo, valor , agrupa as parcelas que foram estornadas
	If aPagtos[nC, __L4lEstorn] 
		If (nPos := aScan(aPagtosExt, {|e| e[1] == aPagtos[nC, __E1_PARCELA] .and. e[2] == aPagtos[nC, __L4_FORMA] })) = 0
    		aAdd( aPagtosExt, {aPagtos[nC, __E1_PARCELA], aPagtos[nC, __L4_FORMA],  0})
    		nPos := Len(aPagtosExt)
    	EndIf
    	aPagtosExt[nPos, 03] := aPagtosExt[nPos, 03] + aPagtos[nC, __L4_VALOR]
    	nVlrTotal := nVlrTotal + aPagtos[nC, __L4_VALOR]
	EndIf
End

nC := 0
DbSelectArea("SE1")
DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

While (nC := nC + 1) <= Len(aPagtosExt) 

	If DbSeek( cFilSE1 + cPrefixo + cNumTit + PadR(aPagtosExt[nC, 01],nTamE1_PARCELA) + PadR(aPagtosExt[nC, 02], nTamTipo))
		If SE1->E1_VlrReal > 0
			If SE1->E1_VLRREAL > 	SE1->E1_VALOR
				lTemResid	:= .T. 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Confronta o total dos títulos com o total dos títulos estornados no caso de  ³
//³haver uma pagamento com financeira aglutinado que não conseguiu ser estornado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				lTemResid := lTemResid .and. SE1->E1_VLRREAL = aPagtosExt[nC, 03]
			EndIf
			nSaldotit	+=	 SE1->E1_VALOR
		Else
			nSaldotit	+=	 SE1->E1_VALOR 
		EndIf
			
		SE1->(DbSkip())
    EndIf
		
End	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula o valor a ser abatido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nResiduo := nVlrTotal - nSaldoTit //Pagamentos Exotrnados X Valores Reais dos Títulos

If (nResiduo > 0) .AND. lTemResid  


	cParcela := PadR(SuperGetMV("MV_1DUP"), nTamE1_PARCELA) // Ajusta de acordo com o tamanho do E1_PARCELA


	SX5->(DbSeek(xFilial("SX5")+"24"+PADR("CR",6)))
	cNatureza := If(Empty(SX5->X5_DESCRI),"CREDITO",SX5->X5_DESCRI)

	DbSelectArea("SE1")
	DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO	

	While SE1->(DbSeek(cFilSE1 + cPrefixo + cNumTit + cParcela + PadR('CR', nTamTipo)))
		cParcela := CHR(ASC(cParcela)+1)
	End
	
	cPortador	:= cCaixaEst

	// Monta o array com as informacoes para a gravacao do titulo
	aVetMsExAut  := {	{"E1_PREFIXO"	,cPrefixo					,Nil},;
						{"E1_NUM"	  	,cNumTit  			   		,Nil},;
						{"E1_PARCELA" 	,cParcela					,Nil},;
						{"E1_TIPO"	 	,PadR('CR', nTamTipo)		,Nil},;
						{"E1_NATUREZ" 	,cNatureza					,Nil},;
						{"E1_PORTADO" 	,cPortador					,Nil},;
			          	{"E1_CLIENTE" 	,cCliente					,Nil},;
		             	{"E1_LOJA"	  	,cLoja						,Nil},;
			          	{"E1_EMISSAO" 	,dDataBase 					,Nil},;
				       	{"E1_VENCTO"  	,dDataBase 					,Nil},;
				       	{"E1_VENCREA" 	,DataValida(dDataBase)		,Nil},;
				       	{"E1_MOEDA" 	,nMoedaCorT					,Nil},;
						{"E1_ORIGEM"	,"LOJA601"					,Nil},;
						{"E1_FLUXO"		,"S"						,Nil},;
					   	{"E1_VALOR"	  	,nResiduo					,Nil }}
	
	// Se a moeda for diferente de um adiciona o valor em moeda 1 para ter a taxa da inclusao do titulo
	If nMoedaCorT <> 1
		aAdd(aVetMsExAut,{"E1_VLCRUZ",Round(xMoeda(nResiduo, nMoedaCorT, 1, dDataBase),MsDecimais(1)) ,Nil })
	EndIf

	MSExecAuto({|x,y| Fina040(x,y)},aVetMsExAut, 3) //Inclusao
	
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
	EndIf

EndIf

RestArea(aAreaSE1)
RestArea(aAreaSAE)
RestArea(aArea)

Return cParcela  

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Lj601Comp ³ Autor ³ Vendas Cliente        ³ Data ³ 16/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para compensacao te titulos estornados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 :  Numero do documento de  Entrada                    ³±±
±±³          ³ ExpC2 : Serie da nota de Entrada                            ³±±
±±³          ³ ExpC3 : Numero do documento de saida                        ³±±
±±³          ³ ExpC4 : Serie da nota de Saida                              ³±±
±±³          ³ ExpC5 : Codigo do cliente                                   ³±±
±±³          ³ ExpC6 : Loja do cadastro do cliente                         ³±±
±±³          ³ ExpA7 : Pagamentos Estornados ExpA05[N,22], vide define acima³±±  
±±|          ³ ExpC8 : Parcela da Taxa Administrativa 			           |±±
±±³          ³ ExpC9 : NFE de Orcamento com Retira + Entrega               ³±±  
±±|          ³ ExpC10: Serie de NFE de Orcmto com Retira + Entrega         |±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA - VENDA ASSISTIDA                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj601Comp( cTitEnt		,	cSerieEnt	,	cTitSaida	,	cSerieSaida	,;
                    cCliente 	,	cLoja		,   aPgtos      ,	cParcela	,;
                    cTitEnt2	,   cSerieEnt2	, 	cNewCli		, 	cNewLoja	)

Local aSE1CPS			:= {}					// Array com os titulos do SE1
Local aNCC				:= {}     				// Array com as NCCs geradas na devolucao
Local lRet				:= .T.					// Retorno da funcao
Local lCompensa			:= .T.					// Indica se o titulo deve ser compensado
Local cMV_CLIPAD  		:= SuperGetMV("MV_CLIPAD")			// Cliente padrao
Local cMV_LOJAPAD 		:= SuperGetMV("MV_LOJAPAD")			// Loja do cliente padrao  
Local nC := 0 //Laço para contabilizar os pagamento estornados
Local nTamTipo          := TamSx3("E1_TIPO")[1]     //Tamanho do campo E1_TIPO 
Local nTamParc          := TamSx3("E1_PARCELA")[1]     //Tamanho do campo E1_PARCELA
Local aPagtos 			:= aClone( aPgtos )     //Copia o array, pois o parâmetro está sendo tratado como refência, apesar de ser de valor      
Local nTamPref          := TamSx3("E1_PREFIXO")[1]     //Tamanho do Prefixo do titulo
Local nTamNum           := TamSx3("E1_NUM")[1]         //Tamanho do Numero do titulo
Local cLstDesc			:= FN022LSTCB(2)	//Lista das situacoes de cobranca (Descontada)
 
Default cTitEnt  	:= ""
Default	cSerieEnt 	:= ""  
Default	cTitSaida 	:= ""	
Default cSerieSaida := ""
Default cCliente 	:= ""
Default cLoja 		:= ""   
Default aPgtos  	:= {}	
Default cParcela 	:= ""
Default cTitEnt2 	:= ""  
Default cSerieEnt2 	:= ""
Default cNewCli     := ""
Default cNewLoja    := ""


//Trata alteracao de cliente/loja. (Casos que a venda foi realizada para o cliente padrao)
If Alltrim(cMV_CLIPAD) == Alltrim(cCliente) .AND. !Empty(cNewCli) .AND. !Empty(cNewLoja)
	cCliente := cNewCli
	cLoja 	 := cNewLoja
EndIf
                                                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Traz as NCCs que foram geradas para a devolucao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

If !Empty(cParcela)
	aAdd(aPagtos, Array(__L4_TAMANHO))
	nC := Len(aPagtos)
	aPagtos[nC, __E1_PARCELA] := cParcela
	aPagtos[nC, __L4_FORMA] := "CR"
	aPagtos[nC, __L4lEstorn] := .T.
EndIf

SE1->( DbSetOrder( 2 ) ) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                               
If SE1->( DbSeek( xFilial("SE1") + cCliente + cLoja + PadR(cSerieEnt,nTamPref) + cTitEnt  ) )

	While SE1->(!Eof()) .AND. xFilial("SE1")		== SE1->E1_FILIAL 	.AND. ;
								SE1->E1_CLIENTE		== cCliente 		.AND. ;
								SE1->E1_LOJA		== cLoja 			.AND. ;
								SE1->E1_PREFIXO		== cSerieEnt 		.AND. ;
								SE1->E1_NUM			== cTitEnt
									
	   	If !( SE1->E1_SITUACA $ cLstDesc .OR. SE1->E1_SALDO == 0 )	
		
     		If ( SE1->E1_TIPO $ MV_CRNEG )
     			Aadd( aNCC, SE1->(Recno()) )
     		Endif	

		Endif
	    
		SE1->(DbSkip())
	End

EndIf  

//Adiciona aos titulos de Contas a Pagar a NCC de devolução gerada para pedido de entrada, quando a nota ha itens de retira + entrega 
If !Empty(cTitEnt2+cSerieEnt2) .and. SE1->( DbSeek( xFilial("SE1") + cCliente + cLoja + PadR(cSerieEnt2,nTamPref ) + cTitEnt2  ) )
	While SE1->(!Eof()) .AND. xFilial("SE1")		== SE1->E1_FILIAL 	.AND. ;
								SE1->E1_CLIENTE		== cCliente 		.AND. ;
								SE1->E1_LOJA		== cLoja 			.AND. ;
								SE1->E1_PREFIXO		== cSerieEnt2 		.AND. ;
								SE1->E1_NUM			== cTitEnt2
									
	   	If !( SE1->E1_SITUACA $ cLstDesc .OR. SE1->E1_SALDO == 0 )	
		
     		If ( SE1->E1_TIPO $ MV_CRNEG )
     			Aadd( aNCC, SE1->(Recno()) )
     		Endif	

		Endif
	    
		SE1->(DbSkip())
	End
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Traz os titulos do respectivo documento que foram estornados       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   

SE1->( DbSetOrder( 1 ) ) ////E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO ))
nC := 0
While (nC :=  nC + 1) <= Len(aPagtos)
	If  aPagtos[nC, __L4lEstorn] .and. ;
		SE1->( DbSeek( xFilial("SE1") + PadR(cSerieSaida,nTamPref)  + PadR(cTitSaida,nTamNum) +  Padr(aPagtos[nC, __E1_PARCELA],nTamParc) + PadR(aPagtos[nC, __L4_FORMA], nTamTipo)) )	

					
		lCompensa := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o cliente e uma administradora para nao compensar titulo de outro cliente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (AllTrim(SE1->E1_TIPO) $ "CC/CD/CO/VA/FI" ) .AND. ( SE1->E1_CLIENTE <> cCliente )
			SAE->( DbSetOrder( 1 ) )
			If SAE->( DbSeek(xFilial("SAE")+ SubStr( SE1->E1_CLIENTE,1,3 )) )
				lCompensa := .T.
			Endif
		Else
			If 	(SE1->E1_CLIENTE == cCliente .AND. SE1->E1_LOJA == cLoja) .OR. (cMV_CLIPAD == SE1->E1_CLIENTE .AND. cMV_LOJAPAD == SE1->E1_LOJA)
				lCompensa := .T.
			Endif
		Endif
				
		If lCompensa
		   	If !( SE1->E1_SITUACA $ cLstDesc .OR. SE1->E1_SALDO == 0 )	
	     		If !( SE1->E1_TIPO $ MV_CRNEG )
		   			Aadd( aSE1Cps, SE1->(Recno()) )
		   		Endif	
			Endif
		Endif
		    
	
	Endif 
End
									
If Len(aSE1Cps) > 0 .and. Len(aNCC) > 0
	MaIntBxCR(3,aSE1Cps,Nil,aNCC)//,Nil,aParam,{|x,y| OmsGrvDAM(x,y,cCarga,cSeqcar,cLote,"3")})
EndIf

Return lRet   

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Lj601RePed³ Autor ³ Vendas Cliente        ³ Data ³ 20/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para eliminação dos resíduos do Pedido e Geracao NCC ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Codigo do Caixa                                     ³±±
±±³          ³ ExpC2 : Numero do documento de saida                        ³±±
±±³          ³ ExpC3 : Serie do documento de saida                         ³±±
±±³          ³ ExpC4 : Codigo do cliente                                   ³±±
±±³          ³ ExpC5 : Loja do cadastro do cliente                         ³±±
±±³          ³ ExpC6 : Orcamento                                           ³±±  
±±³          ³ ExpC7 : Numero do Documento Gerado                          ³±± 
±±³          ³ ExpC6 : Serie do Documento Gerado                           ³±± 
±±³          ³ ExpN7 : Valor Total do Pedido                               ³±± 
±±³          ³ ExpD8 : Data de Emissao do Orcamento                        ³±± 
±±³          ³ ExpL9 : Orcamento na Retagurada?                            ³±± 
±±³          ³ ExpC10: Cupom Fiscal                                        ³±± 
±±³          ³ ExpC11: Serie do Cupom Fiscal                               ³±±   
±±³          ³ ExpA12: Filtro do MBrowse                                   ³±± 
±±³          ³ ExpA13: Reservas do Orcamento                               ³±±  
±±³          ³ ExpL14: Execucao em Job?                                    ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA - VENDA ASSISTIDA                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj601RePed(	cL1Oper		,    cL1Doc		,   cSerEst 	,   cL1Cliente	,  ;
						cL1Loja		,	cNumOrc     ,	 cNumDoc    ,   cSerieDoc   ,  ;
						nValorNCC   ,  dL1EmisNf 	, 	lRetagOrc	,	cCupFis		, ;
						cSerieCF	,  aQuery		,   aOrc_Res	, 	lJob)

Local aArea := GetArea()
Local cParcela 		:= SuperGetMV("MV_1DUP")								//Parcela a gerar
Local aVetor		:= {}													//Dados para a rotina automatica
Local lRet 			:= .T.													//Retorno da rotina automatica
Local cErro 		:= ""													//Tratamento de erro
Local lBaixarNCC	:= .T.		  	          								// baixa o NCC total ou parcial
Local lGravaSE5		:= .T. 													// Se deve gravar o SE5
Local nValorNCCAtual:= 0													// Valor da NCC Atual
Local nRndMoed1 	:= MsDecimais(1)										// Arredondamento para localizacoes
Local aLogRotAut    := {}                                                   //Log da rotina automatica
Local nC := 0                                                              //Contador de laco dos itens da NF
Local nVlrDep       := 0                                                   //Valor dos itens que foram eliminados residuos
Local lTranOpen     := .F.                                                 //Transacao aberta
Local aPedRes       := {}                                                 //Array  com os pedidos de entregas
Local aOrcRes       := {}                                                 //Orcamentos com reservas
Local cCondicao 	:= ""                                                 //Condicao do filtro
Local cFilF4        := xFilial("SF4")                                     //Impostos Solidarios do Orcamento
Local nImpSol     := 0                                                    //Valor do imposto solidario
Local lPedRes    := SL1->(FieldPos("L1_PEDRES")) > 0                      //Pedido de reserva
Local aArea2     := {}
Local cBkpFilial  := ""          //Filial de Backup 
Private lMsErroAuto := .F.  //Problemas de execucao da rotina fina040
                                 

Default lRetagOrc := .T. 

Default	cL1Oper	 	:= ""  
Default cL1Doc 		:= ""   
Default cSerEst 	:= ""  
Default cL1Cliente 	:= ""
Default cL1Loja	 	:= ""	
Default cNumOrc   	:= ""	 
Default cNumDoc    	:= "" 
Default cSerieDoc  	:= ""
Default nValorNCC 	:= 0
Default dL1EmisNf 	:= CtoD("")	
Default cCupFis		:= ""
Default cSerieCF 	:= ""  
Default aQuery 		:= {}  
Default aOrc_Res 	:= {}	
Default lJob 		:= .F.


//Primeiramente, gera a rotina de eliminação de resídui de pedido
DbSelectArea("SL2")
SL2->(DbSetOrder(1)) //XfILIAL+oRCAMENTO
SL2->(DbSeek(xFilial("SL2")+cNumOrc))

While SL2->(!Eof() .and. L2_FILIAL+L2_NUM  == xFilial("SL2")+cNumOrc)
	If !Empty(SL2->L2_ORCRES) .and. aScan(aVetor, {|p| p[1] == SL2->L2_FILRES .and. p[2] == SL2->L2_ORCRES}) == 0 
		aAdd(aVetor, {SL2->L2_FILRES,SL2->L2_ORCRES})
	EndIf     
	SL2->(DbSkip(1))
End 

aOrc_Res := aClone(aVetor) 


If !lRetagOrc  .and. !lJob
	//Limpa o filtro do SL1 para fazer exclusao do Orcamento não finalizado 
	EndFilBrw("SL1",aQuery)
EndIf 

DbSelectAreA("SL1") 
SL1->(DbSetOrder(1)) //Filial + Orcamento


nC := 0
While (nC := nC + 1) <= Len(aVetor)   
   
    If SL1->(DbSeek(aVetor[nC, 01]+aVetor[nC, 02]))
		If  lPedRes .and. !Empty(SL1->L1_PEDRES) .And.  aScan(aPedRes, {|p| p[1] == aVetor[nC, 01] .and. p[2] == SL1->L1_PEDRES}) == 0
	    	aAdd(aPedRes, {aVetor[nC, 01], SL1->L1_PEDRES})
	    	If SL1->L1_ICMSRET > 0
	    		//Verifica se há ICMS ST para os Itens do Pedido

			    If !Empty(cFilF4)
			    	cFilF4 := aVetor[nC, 01]
			    EndIf
			    		
				SL2->(DbSeek(aVetor[nC, 01]+aVetor[nC, 02]))
				
				While SL2->(!Eof() .and. L2_FILIAL + L2_NUM == aVetor[nC, 01]+aVetor[nC, 02])
					SF4->(DbSetOrder(1))
					SF4->(DbSeek(cFilF4+SL2->L2_TES))
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faz o tratamento do valor do ICMS solidário                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					// VerIfica se agrega solidario. (Se o valor do imposto incide ou nao no total da venda)
					If SF4->F4_INCSOL <> "N"
						nImpSol	+= SL2->L2_ICMSRET
					EndIf
					
					SL2->(DbSkip(1))
				End	     
	    	EndIf
	    	
	    Else
	    	If !Empty(SL1->(L1_DOC+L1_SERIE))  //Se existem Cupons Fiscais amarrados ao pedido, então grava para posterior geracao de NFE
	    		cCupFis := SL1->L1_DOC
	    		cSerieCF := SL1->L1_SERIE
	    	Else
	    	   If SL1->L1_RESERVA = "S"  // e orcamento com reserva, enttã 
					aAdd(aOrcRes, aVetor[nC])
	    	   EndIf
	    	EndIf 
         EndIf
    EndIf
End

nValorNCC := nImpSol //Adiciona o valor do ICMS Solidario agregado ao valor

//Exclusão dos Orcamentos com retira posterior
lRet := Lj601OrRes(aOrcRes, @nValorNCC)

If !lRetagOrc .and. !lJob
	//Restaura o filtro do SL1 pois já ocorreu a exclusão do orcamento  
	DbSelectArea("SL1")
	cCondicao := "(!Empty(L1_DOC) .OR. !Empty(L1_DOCPED)) .AND. ( !Empty(L1_SERIE) .Or. !Empty(L1_SERPED) ) .AND. L1_TIPO <> 'D' .AND. ( L1_TIPO == 'V' .or. L1_TIPO == 'P') .AND. L1_STORC <> 'E'"                   
	Eval({|| FilBrowse("SL1",@aQuery,@cCondicao) })
EndIf 

nC := 0
DbSelectArea("SC5")
DbSetOrder(1) //filial + pedido 
 

DbSelectArea("SC6")
DbSetOrder(1) //Filial + Pedido + item + produto

While lRet .and. (nC := nC + 1) <= Len(aPedRes)
	    
	If SC5->(DbSeek(aPedRes[nC, 01]+aPedRes[nC, 02]))  .and. SC6->(DbSeek(aPedRes[nC, 01]+aPedRes[nC, 02]))
		// Elimina residuo de itens e atualiza cabecalho do pedido.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estorna Liberação³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
 
	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz bkp da filial atual.                   ³
		//³Carrega a Filial com a filial do Ped. Filho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cBkpFilial := cFilAnt   
		cFilAnt    := aPedRes[nC, 01]		

		DbSelectArea("SC9")
		SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO
		If SC9->(DbSeek(aPedRes[nC, 01]+SC5->C5_NUM))
			While  SC9->(!Eof()) .AND. SC9->C9_PEDIDO == SC5->C5_NUM 
				aArea2      := GetArea()
				a460Estorna()
				RestArea(aArea2)
				SC9->(DbSkip())
			End
		EndIf		
		
		
		nVlrDep := 0
		While SC6->(!Eof().and. C6_FILIAL+C6_NUM == aPedRes[nC, 01]+aPedRes[nC, 02])
			nVlrDep := 0
			aArea2 := GetArea()
			MaResDoFat(nil, .T., .F.,)
			RestArea(aArea2)
			nValorNCC += SC6->C6_VALOR  
			SC6->(DbSkip())
		End
		aArea2 := GetArea()
		MaLiberOk({ SC5->C5_NUM }, .T.)
	 	RestArea(aArea2)  
	 	
	 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega a Filial correta que foi salva no BKP³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFilAnt    := cBkpFilial      
		      	
	Else 
		If lJob
			ConOut(space(23) + "Lj601RePed - "+AnsiToOem(STR0010 +aPedRes[nC, 02] + STR0011 + aPedRes[nC, 01] + STR0012)) //Problemas na Eliminação das reservas dos pedidos. Pedido: xxxxx Filial: xx  não localizado."
		Else 
			MsgAlert(STR0010 +aPedRes[nC, 02] + STR0011 + aPedRes[nC, 01] + STR0012) //Problemas na Eliminação das reservas dos pedidos. Pedido: xxxxx Filial: xx  não localizado."
		EndIf
		lRet := .F.
	EndIf
			    
End	

If lRet .and. nValorNCC > 0
	DbSelectArea("SE1")
	DbSetOrder(1)
	While SE1->(DbSeek(xFilial("SE1") + cSerEst + cL1Doc + cParcela + "NCC"))
			cParcela := CHR(ASC(cParcela)+1)
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor que deve ser baixado das NCC's³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	
	lAutoErrNoFile := .T. 
	aVetor := {}
	
	aAdd(aVetor,{"E1_PREFIXO"	,cSerEst											,Nil})
	aAdd(aVetor,{"E1_NUM"	  	,cL1Doc 											,Nil})
	aAdd(aVetor,{"E1_PARCELA" 	,cParcela											,Nil})
	aAdd(aVetor,{"E1_NATUREZ" 	,&(SuperGetMV("MV_NATNCC"))							,Nil})
	aAdd(aVetor,{"E1_PORTADO" 	,cL1Oper											,Nil})
	aAdd(aVetor,{"E1_AGEDEP" 	,"."												,Nil})
	aAdd(aVetor,{"E1_TIPO" 		,"NCC"												,Nil})
	aAdd(aVetor,{"E1_EMISSAO"	,dL1EmisNf							   				,Nil})
	aAdd(aVetor,{"E1_VALOR"		,nValorNCC											,Nil})
	aAdd(aVetor,{"E1_VENCTO"	,dL1EmisNf											,Nil})
	aAdd(aVetor,{"E1_VENCREA"	,DataValida(dL1EmisNf,.T.)							,Nil})
	aAdd(aVetor,{"E1_VENCORI"	,dL1EmisNf											,Nil})
	aAdd(aVetor,{"E1_SALDO"		,nValorNCC											,Nil})
	aAdd(aVetor,{"E1_VLCRUZ"	,xMoeda(nValorNCC,1,1,dL1EmisNf)		 			,Nil})
	aAdd(aVetor,{"E1_CLIENTE"	,cL1Cliente											,Nil})
	aAdd(aVetor,{"E1_LOJA"		,cL1Loja											,Nil})
	
	If cPaisLoc <> "BRA"
		DbSelectArea("SA6")
		DbSetOrder(1)
		If DbSeek( xFilial("SA6") + cL1Oper + "." + "NCC" )
			aAdd(aVetor,{"E1_MOEDA"		,Max(SA6->A6_MOEDA,1)						,Nil })
		Else
			aAdd(aVetor,{"E1_MOEDA"		,1											,Nil })
		EndIf
	 			Else
		aAdd(aVetor,{"E1_MOEDA"		,1												,Nil })
	EndIf
	
	aAdd(aVetor,{"E1_STATUS"		,If(nValorNCC > 0.01,"A","B")					,Nil })
	aAdd(aVetor,{"E1_SITUACA"		,"0"											,Nil })
	aAdd(aVetor,{"E1_ORIGEM"		,"LOJA601"										,Nil })
	aAdd(aVetor,{"E1_MULTNAT"		,"2"											,Nil })
	aAdd(aVetor,{"E1_FLUXO"			,"N"											,Nil })
	aAdd(aVetor,{"E1_BASCOM1"		,xMoeda(nValorNCC,1,1,dL1EmisNf)				,Nil })
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui via rotina automatica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSExecAuto({|x,y| Fina040(x,y)},aVetor,3) 
	
	
	DbSelectArea("SE1")
	DbSetOrder(2) //E1+FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If DbSeek(xFilial("SE1") + cL1Cliente + cL1Loja + cSerEst + cL1Doc + cParcela + PadR("NCC", TamSX3("E1_TIPO")[1]))
	
		RecLock("SE1",.F.)
		
		REPLACE SE1->E1_HIST With 	xFilial("SE1") 				+ ;
									cSerEst 	+ ;
									cL1Doc 	+ ;
									cParcela  	+ ;
									"NCC"
		MsUnLock()
	   
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apresenta mensagem de erro caso a rotina automatica nao seja executada.³
	//³Desfaz a transacao                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lMsErroAuto

	    aLogRotAut := GetAutoGrLog()                                   
	    If Len(aLogRotAut) > 0 .AND. ValType(aLogRotAut[1]) == "C"
			If lJob
				Conout(space(23) + "Lj601RePed - " + AnsiToOem(aLogRotAut[1]))  
			Else 
				MsgAlert(aLogRotAut[1])
			EndIf			       
		EndIf
		lRet := .F.
	Else
		cNumDoc    := cL1Doc
		cSerieDoc  := cSerEst  
	EndIf
	
EndIf  

RestArea(aArea)
 
Return lRet

/*

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Lj601OrRes³ Autor ³ Vendas Cliente        ³ Data ³ 22/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para eliminação dos resíduos do Pedido e Geracao NCC ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 : Orcamentos com reservas                             ³±±
±±³          ³ ExpN2 : Valor cancelado                                     ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA - VENDA ASSISTIDA                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj601OrRes(	aOrcRes		,   nValorNCC )   
Local aArea := GetArea() //WorkAreasAtivas
Local lRet := .T. //Retorno da Funcao 
Local cLojaLocal := "" //Loja do Pedido de saida
Local nC := 0 //Variavel de controle de laco de repeticao 
Local nXImpostos := 0 //Contador de TES    
Local aTesImp := {} //Dados da TES do Item
Local cFilL2    := SL2->( xFilial( "SL2" ) ) //Filial SL2
Local cFilE1    := SE1->( xFilial( "SE1" ) ) //Filial SE1
Local cFilL4    := SL4->( xFilial( "SL4" ) )  //Filial SL4
Local cFilF4    := SF4->( xFilial( "SF4" ) )  //Filial SF4
Local aRetCrd   := {}                       	//Array  de retorno do cancelamento do contrato - integracao SIGACRD
Local lCrdxInt  := CrdxInt()                	//Controla se tem integracao com SIGACRD
Local aClientes	:= {}                           //Clientes
Local nPosDescPro := 0 //Desconto do produto 
Local aReservas := {}  //Reservas
Local nPosStOrc := SL1->(FieldPos("L1_STORC")) > 0 //Status do orcamento  


Default aOrcRes := {}
Default nValorNCC  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o codigo da loja local               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SLJ")
DbSetOrder(3)
If DbSeek(xFilial("SLJ")+SM0->M0_CODIGO+FWGETCODFILIAL)
	cLojaLocal := SLJ->LJ_CODIGO
EndIf
  

nPosDescPro := SL2->(FieldPos("L2_DESCPRO") )      

DbSelectArea("SL1")
SL1->(DbSetOrder(1)) //Filial + Orcamento   

While lRet .and. (nC := nC + 1) <= Len(aOrcRes)  

	If Empty(aOrcRes[nC, 01])
		cFilRes := cFilAnt
	Else 
		cFilRes := aOrcRes[nC, 01]
	EndIf
		
	If !Empty( cFilL2 )
		cFilL2 := cFilRes
	EndIf
	If !Empty( cFilL4 )
		cFilL4 := cFilRes
	EndIf  
	
	If !Empty( cFilF4 )
		cFilF4 := cFilRes
	EndIf

	If SL1->(DbSeek(cFilRes + aOrcRes[nC, 02]))
	
		DbSelectArea( "SL2" )  
		SL2->(DbSetOrder(1))
		
		If DbSeek( cFilL2+SL1->L1_NUM )
			While !Eof() .AND. cFilL2==L2_FILIAL .AND. L2_NUM == SL1->L1_NUM   
				
				nImpostos := 0
				If cPaisLoc <> "BRA"			
					aTesImp := TesImpInf(SL2->L2_TES)					// Carrega retorno da função no array de impostos
					nImpostos  := 0
					For nXImpostos := 1 To Len(aTesImp)					// Le todos os impostos
						If aTesImp[nXImpostos][3] == '1'				// Verifica se o imposto sera agregado ao valor do item
							nImpostos += &(aTesImp[nXImpostos][2])		// Agrega a somatoria de impostos o valor do campo de imposto (ex: D1_VALIMP1)
						EndIf
					Next nXImpostos
				
				Else
				
					SF4->(DbSetOrder(1))
					SF4->(DbSeek(cFilF4+SL2->L2_TES))
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faz o tratamento do valor do ICMS solidário                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					// VerIfica se agrega solidario. (Se o valor do imposto incide ou nao no total da venda)
					If SF4->F4_INCSOL <> "N"
						nImpostos	+= SL2->L2_ICMSRET
					EndIf				
				  
				EndIf
				nValorNCC += SL2->L2_VLRITEM  + nImpostos
				
				If cPaisLoc <> "BRA" .and. nPosDescPro		
					If nPosDescPro > 0
				   		nValorNCC += SL2->L2_DESCPRO
					EndIf 
			    EndIf   
			    
			    If !Empty(SL2->L2_RESERVA)
			    	aAdd(aReservas, {L2_RESERVA, IIF(Empty(SL2->L2_LOJARES), cLojaLocal, SL2->L2_LOJARES), L2_PRODUTO, L2_LOCAL} )
			    EndIf
			    
			    SL2->(DbSkip())
			    
			End
		EndIf
		
	
		
	Else 
		lRet := .F.
	 	ConOut("Lj601OrRes - " + AnsiToOem(STR0013 + aOrcRes[nC, 02] + STR0011 +aOrcRes[nC, 01] + STR0012)) //"Orçamento: xxxxxx filial: xx não localizado"   	 	
	EndIf
	
End  

If lRet .and.  Len(aReservas) >0
   If !(lRet := LjCancRes(aReservas) )
   		ConOut("Lj601OrRes - "+AnsiToOem(STR0014))//Problemas no cancelamento das reservas.
   EndIf
EndIf  


RestArea(aArea)
Return lRet 

/*

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Lj601GrStE³ Autor ³ Vendas Clientes       ³ Data ³ 23/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para gravacao do status do Orcamento e pagamentos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Orcamento                                           ³±±
±±³          ³ ExpA2 : Pagamentos do Orcamento, vide define acima          ³±±    
±±³          ³ ExpA3 : Orcamentos de Reservas                              ³±± 
±±³          ³ ExpL4 : Orcamento na retaguarda?                            ³±±    
±±³          ³ ExpA5 : Filtro MBrowse                                      ³±± 
±±³          ³ ExpL6 : Execução em Job?                                    ³±±    
±±³          ³ ExpL7 : Ambiente OffLine?                                   ³±± 
±±³          ³ ExpC8 : Documento TEF Cancelamento                          ³±±    
±±³          ³ ExpC9 : Data Cancelamento TEF                               ³±± 
±±³          ³ ExpC10: Hora Cancelamento TEF                               ³±±      
±±³          ³ ExpC11: Caixa do Cancelamento                               ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA - VENDA ASSISTIDA                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj601GrStE( cOrcamento, 	aPagtos,	aOrcRes,	lRetagOrc,;
					 aQuery,		lJob,		lOffLine,   cDocTEFCan,;
					 cDtTEFCan,		cHorTefCan, cCaixaEst)      
					 
Local aArea := GetArea()  //WorkAreasAtivas
Local nTotPagtos := Len(aPagtos) //Total de Pagamentos do Orcamento
Local nTotPgEsT := 0 //Total de Pagamentos Estornados
Local nC := 0 //Variável contadora
Local cCondicao := ""//Variavel que armazena a condicao do Filtro da SL1  
Local nPosEst := SL4->(FieldPos("L4_ESTORN") )
Local nPosStEs := SL1->(FieldPos("L1_STATUES") )
Local lRet := .T.      //Retorno de execucao da Função
Local cFilL2 := xFilial("SL2")
Local lECommerce  := SuperGetMV("MV_LJECOMM",,.F.) .And. GetRpoRelease("R5") .And. (FindFunction("LJ861ECAuto") .And. LJ861ECAuto() .Or. FindFunction("LJ862ECAuto") .And. LJ862ECAuto())
Local lExcAuto	:= IsBlind()	// Verifica se a rotina sera executada via execauto ou nao

Default cOrcamento	:= ""
Default aPagtos := {}
Default aOrcRes := {}   
Default	lRetagOrc := .f.
Default aQuery := {}  
Default	lJob := .F.	
Default lOffLine := .F.   
Default cDocTEFCan := ""
Default cDtTEFCan := ""		
Default cHorTefCan := "" 
Default cCaixaEst  := ""


If nPosEst = 0 .or. nPosStEs = 0

	lRet := .f. 
	If !lJob
		MsgInfo(STR0015)//"Para utilizacao da rotina de estorno; faz-se necessária a criacao dos campos L4_ESTORN e L1_STATUES, conforme FNC 000000225902010"
		
	Else
	
		ConOut(space(23) + "Lj601GrStE  - "+AnsiToOem(STR0016))//Não localizados campos para gravação da situação do estorno. Realizar criacao campos L1_STATUES e L4_ESTORN."
    EndIf
Else

	DbSelectArea("SL1")
	If !lRetagOrc .and. !lJob .and.  !lOffLine
		//Limpa o filtro do SL1 para fazer exclusao do Orcamento não finalizado 
		EndFilBrw("SL1",aQuery)
	EndIf 


	SL1->(DbSetOrder(1)) //Filial + L1_NUM
	
	DbSelectArea("SL4")
	SL4->(DbSetOrder(1))
	DbSeek(xFilial("SL4") + cOrcamento )
	While (nC := nC + 1) <= nTotPagtos   
		If aPagtos[nC, __L4lEstorn]
			nTotPgEsT := nTotPgEsT + 1
			SL4->(DbGoTo(aPagtos[nC, __L4_RECNO]))
			RecLock("SL4", .F.)
			
			REPLACE L4_ESTORN  With "S"
			REPLACE L4_OPERAES With cCaixaEst
			
			If !Empty(aPagtos[nC, __L4_DOCCANC])  //Grava os dados da trasacao TEF Cancelada
				REPLACE L4_DOCCANC WITH aPagtos[nC, __L4_DOCCANC]
				REPLACE L4_HORCANC WITH	aPagtos[nC, __L4_HORCANC]
				REPLACE L4_DATCANC WITH aPagtos[nC, __L4_DATCANC]   
				
			EndIf
			
			MsUnLock()	
		EndIf
	End
	
	DbSelectArea("SL1")
	If SL1->(DbSeek(xFilial("SL1") + cOrcamento))
	   RecLock("SL1", .F.)
	   If nTotPgEsT == nTotPagtos  
	   	Replace L1_STATUES With "1" //Estorno Total da Venda
	   Else 
	   	Replace L1_STATUES With "2" //Estorno Parcial da Venda
	   EndIf
	   If !Empty(cDocTEFCan)
	   		Replace L1_DOCCANC With cDocTEFCan
	   		Replace L1_DATCANC With cDtTEFCan		
	   		Replace L1_HORCANC With cHorTefCan
	   EndIf		
	EndIf  
	
	nC := 0
	//Atualiza os Orçamentos Filhos como estornados parcialmente, pois os pagamentos foram estornados no Orçamento-pai]
	While (nC := nC + 1) <= Len(aOrcRes)
		If SL1->(DbSeek(aOrcRes[nC, 01] + aOrcRes[nC, 02]))   
			RecLock("SL1", .F.)
			Replace L1_STATUES With "2" //Estorno Parcial da Venda
		EndIf
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga Pedido de vendas quando for "Entrega"    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If Empty( SL1->L1_DOCPED ) .AND. !Empty( SL1->L1_FILRES ) .AND. Empty(SL1->L1_DOC)
		DbSelectArea("SC5")
		DbSetOrder(1) //C5_FILIAL+C5_NUM 
	   	If DbSeek(xFilial("SC5")+ SL1->(L1_PEDRES)) 

			If !Empty(SC5->C5_NOTA) .AND. !Empty(SC5->C5_SERIE)
				If !lExcAuto
			   		MsgStop(STR0027)
			   		//"Este Pedido possui Pedidos de Venda finalizados, nao sera possivel efetuar o cancelamento."###"Atencao"
				Else 
					Conout(STR0027)
				EndIf
				lRet := .F.
			EndIf		   		   	
	   	    
	   		If lRet
	    		DbSelectArea("SC6")
				DbSetOrder(1) //C6_FILIAL+C6_NUM
				If DbSeek(xFilial("SC6")+SC5->(C5_NUM))
					While !Eof() .AND. C6_NUM = SC5->(C5_NUM)
			    		RecLock('SC6',.F.)  
						DbDelete() 
						MsUnLock() 
						dbSkip()
					End
				EndIf
				//Exclui liberação
				DbSelectArea("SC9")
				DbSetOrder(1) //C9_FILIAL+C9_Pedido
				If DbSeek(xFilial("SC9")+ SL1->(L1_PEDRES)) 
					While !Eof() .AND. C9_PEDIDO = SC5->(C5_NUM)
			    		RecLock('SC9',.F.)  
						DbDelete() 
						MsUnLock() 
						dbSkip()
					End
				EndIf	
				//Exclui cabeçalho(SC5)
				RecLock('SC5',.F.)  
				DbDelete() 
				MsUnLock() 		
			EndIf	
	  	EndIf
	EndIf      
            
	If lRet
		DbSelectArea( "SL2" )
		If DbSeek( cFilL2+SL1->L1_NUM )
			While !Eof() .AND. cFilL2==L2_FILIAL .AND. L2_NUM == SL1->L1_NUM
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Excluir a reserva de Estoque quando e-commerce.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  lECommerce .And. !( Empty(SL2->L2_RESERVA) )                
				
					cNumReserva := SL2->L2_RESERVA
				
					dbSelectArea("SC0")
					dbSetOrder(1)
					DbSeek(xFilial("SC0")+cNumReserva)  // Atenção caso altere este trecho, faça a manutenção tbm na função: A430DelMvc
					While !( Eof() ) .And. (C0_FILIAL+C0_NUM == xFilial("SC0")+cNumReserva)
						SC0->(RecLock("SC0",.F.))  //Ajuste para estornar o B2_RESERVA
						SC0->C0_QUANT  += SC0->C0_QTDPED
						SC0->C0_QTDPED -= SC0->C0_QUANT
						SC0->(MsUnlock())
					
						a430Reserv({3,C0_TIPO,C0_DOCRES,C0_SOLICIT,C0_FILRES},;
							cNumReserva,;
							SC0->C0_PRODUTO,;
							SC0->C0_LOCAL,;
							SC0->C0_QUANT,;
							{	SC0->C0_NUMLOTE,;
							SC0->C0_LOTECTL,;
							SC0->C0_LOCALIZ,;
							SC0->C0_NUMSERI})

						MsUnLock()
						dbSkip()
					EndDo
					
					DbSelectArea( "SL2" )
	
				EndIf			
				dbSkip()
			End
		EndIf
	Endif
	
	If !lRetagOrc .and. !lJob  .and. !lOffline .and. lRet
		//Restaura o filtro do SL1 pois já ocorreu a exclusão do orcamento  
		DbSelectArea("SL1")
		cCondicao := "(!Empty(L1_DOC) .OR. !Empty(L1_DOCPED)) .AND. ( !Empty(L1_SERIE) .Or. !Empty(L1_SERPED) ) .AND. L1_TIPO <> 'D' .AND. ( L1_TIPO == 'V' .or. L1_TIPO == 'P') .AND. L1_STORC <> 'E'"                   
		Eval({|| FilBrowse("SL1",@aQuery,@cCondicao) })
	EndIf	
EndIf

RestArea(aArea)
Return lRet
/*

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³Lj601GrPDV³ Autor ³ Vendas Clientes       ³ Data ³ 28/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para gravacao da Venda Estornada no PDV              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA - VENDA ASSISTIDA                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj601GrPDV()

Local aArea 	:= GetArea()  	//WorAreas ativas
Local aReg 		:= {}         	//Registros Referentes ao Orcamento
Local oEstorno 	:= nil 	  		//Objeto do Estorno 
Local nReg 		:= 0      		//Registro MBZ
Local nPos 		:= 1      		//Array dos dados do estorno
Local cRet 		:= ""    		//Retorno de execução da função
Local lMsg 		:= .F.
Local lOffLine 	:= .F. 			//Venda não foi realizada OffLine 
Local aPagtos 	:= {} 			//Clone dos Pagamentos        
Local nC 		:= 0        	//contador
Local lErro 	:= .F.   		//Erro de execucao
Local cCupom 	:= ""   		//Numero do cupom
Local cSerie 	:= ""   		//Serie do cupom     
Local cCliente 	:= ""			//Cliente para o estorno.
Local cLoja	 	:= ""   		//Loja para o estorno. 
Local nMBZReg   := 0    		//Conteudo do campo MBZ_REG 
 
DbSelectArea("MBZ")
MBZ->(DbSetOrder(2))  //MBZ_FILIAL + MBZ_SITUA + MBZ_CUPOM + MBZ_SERIE
MBZ->(DbSeek(xFilial("MBZ") + "RX"))  


If (lMsg :=  MBZ->(Found() )  )
	ConOut("LJGrvBatch - Lj601GrPDV: " + AnsiToOem(STR0017 + " - " + STR0011 + xFilial("MBZ"))) //"Iniciando  - Filial: " 
EndIf

While MBZ->(!Eof() .and. MBZ_FILIAL + MBZ_SITUA == xFilial("MBZ")+"RX")
	cCupom := MBZ->MBZ_CUPOM
	cSerie := MBZ->MBZ_SERIE
	ConOut("GRVBATCH - Lj601GrPDV: "+ AnsiToOem(STR0018 + cCupom + "/" + cSerie)) //Iniciando gravacao na retaguarda do estorno da venda: xxxxxx /XXX
	
	oEstorno := LjClEstVen():New(nil,MBZ->MBZ_OPERA, nil, dDataBase,0, .T.)  
	oEstorno:lJob := .T.
	oEstorno:BuscaOrcamento(MBZ->MBZ_CUPOM, MBZ->MBZ_SERIE)
	//oEstorno:cOrcamento := MBZ->MBZ_NUM
     
	If oEstorno:lCliPad .AND. ( MBZ->( FieldPos( "MBZ_CLIENT" ) ) > 0 ) .AND. ( MBZ->( FieldPos( "MBZ_LOJA" ) ) > 0 ) //Trata venda realizada para cliente padrao. 
		cCliente  := MBZ->MBZ_CLIENT
	   	cLoja	  := MBZ->MBZ_LOJA
	EndIf 
	
	aReg := {}
	nPos := 0  
	cRet := "OK" //Registro atualizado com sucesso 
	
	lOffLine := Empty(MBZ->MBZ_REG)
	
	//Carrega os Dados do Estorno no Pagamento
	While MBZ->(!Eof() .and. MBZ_FILIAL + MBZ_SITUA + MBZ->MBZ_CUPOM + MBZ->MBZ_SERIE  == xFilial("MBZ")+"RX"+cCupom+cSerie)
		
		If Type("MBZ->MBZ_REG") == "N"
			nMBZReg  := MBZ->MBZ_REG
		ElseIf !lOffLine
			nMBZReg  := Val(MBZ->MBZ_REG)
		EndIf
		
		aAdd(oEstorno:aOrc_Pagtos, Array(__L4_TAMANHO) )  
		nPos := nPos + 1
		oEstorno:aOrc_pagtos[nPos, __L4_FORMA]   := MBZ->MBZ_FORMA
		oEstorno:aOrc_pagtos[nPos, __L4_VALOR]   := MBZ->MBZ_VALOR
		oEstorno:aOrc_pagtos[nPos, __E1_PARCELA] := MBZ->MBZ_PARCEL
		oEstorno:aOrc_pagtos[nPos, __L4lEstorn]  := MBZ->MBZ_ESTORN == "S"
		oEstorno:aOrc_pagtos[nPos, __L4_RECNO] 	 := nMBZReg
		oEstorno:aOrc_pagtos[nPos, __L4_DOCCANC] := MBZ->MBZ_DOCCAN
		oEstorno:aOrc_pagtos[nPos, __L4_HORCANC] := MBZ->MBZ_HORCAN
		oEstorno:aOrc_pagtos[nPos, __L4_DATCANC] := MBZ->MBZ_DTCAN 
		
	
		If !Empty(MBZ->MBZ_DOCCAN) //Exite transacao TEF a ser cancelada?
			oEstorno:cOrc_DocCanc      := MBZ->MBZ_DOCCAN
			oEstorno:cOrc_HorCanc      := MBZ->MBZ_HORCAN
			oEstorno:cOrc_DatCanc      := MBZ->MBZ_DTCAN
		EndIf
		
		aAdd(aReg, MBZ->(Recno()) )
		MBZ->(DbSkip())
	End 
			
	If !Empty(oEstorno:cOrcamento)   
	    
		lErro := .F. //Alimenta a variavel de erro para .F.
		
		If lOffLine //Caso Esteja Off-Line, busca novamente as parcelas do Orcamento  
			aPagtos := aClone(oEstorno:aOrc_Pagtos)
			oEstorno:aOrc_Pagtos := {}
			oEstorno:BuscaPagtosOrcamento() 
			nC := 0 
			lErro := Len(aPagtos) <> Len(oEstorno:aOrc_Pagtos)
			While !lErro .and. (nC := nC + 1) <= Len(oEstorno:aOrc_Pagtos)
				nPos := aScan(aPagtos, { |p| RTrim(p[__L4_FORMA]) == RTrim(oEstorno:aOrc_Pagtos[nC,__L4_FORMA]) .and. RTrim(p[__E1_PARCELA]) == RTrim(oEstorno:aOrc_Pagtos[nC,__E1_PARCELA])})
			    If !(lErro := (nPos == 0)) //Localizou o pagamento, então alimenta os dados a serem gravados
					oEstorno:aOrc_pagtos[nPos, __L4lEstorn]  := aPagtos[nPos, __L4lEstorn]
					oEstorno:aOrc_pagtos[nPos, __L4_DOCCANC] := aPagtos[nPos, __L4_DOCCANC]
					oEstorno:aOrc_pagtos[nPos, __L4_HORCANC] := aPagtos[nPos, __L4_HORCANC]
					oEstorno:aOrc_pagtos[nPos, __L4_DATCANC] := aPagtos[nPos, __L4_DATCANC]
			    EndIf
			End
		EndIf
		
					
	   If lErro         
	   		ConOut(space(23) + AnsiToOem(STR0019))    //"Parcelas da venda gerada no PDV diferem da gravada na retaguarda."
	   		cRet := "ER"
	   Else
		   If Empty(oEstorno:cOrc_StatuEs)
		   	  If !oEstorno:ValidaOrcamento(4)
		   	  	ConOut(space(23) + AnsiToOem(STR0020 + oEstorno:cMensagem)) //"Orcamento InvÁlido - "
		   	  	cRet := "ER"
		   	  EndIf 
		   	  
		   	  If !oEstorno:RealizaEstorno( cCliente , cLoja )
		   	     ConOut(space(23) +AnsiToOem(STR0021))  //"Estorno não realizado."
		   	     cRet := "ER"
		   	  EndIf
		   Else 
		   	  cRet := "DU"
		   	  ConOut(space(23) + AnsiToOem(STR0022))  //"Venda já estornada."
		   EndIf
	   EndIf
	Else 
		cRet := "ER"
		ConOut(space(23) +AnsiToOem(STR0023+ oEstorno:cOrcamento))//"Orcamento nÃo localizado - "
	EndIf
	
	ConOut("GRVBATCH - Lj601GrPDV: "+AnsiToOem(STR0024+ cCupom+ "/" +  cSerie + STR0025 + cRet))  //Finalizando gravacao na retaguarda do estorno da venda: xxxxxx/xxx status

	nReg := MBZ->(Recno())
	
	//Atualiza a situacao do MBZ
	nPos := 0
	For nPos := 1 To Len(aReg)
		MBZ->(DbGoTo(aReg[nPos])) 
		FRTGeraSL( "MBZ",  { { "MBZ_SITUA", cRet } }, .F. )
	Next
	
	MBZ->(DbGoTo(nReg))
End 

If lMsg
	ConOut("LJGrvBatch - Lj601GrPDV: " + AnsiToOem(STR0026+ " - " + STR0011+ xFilial("MBZ") )) // "Finalizando - Filial XX"
EndIf

RestArea(aArea) 

Return
