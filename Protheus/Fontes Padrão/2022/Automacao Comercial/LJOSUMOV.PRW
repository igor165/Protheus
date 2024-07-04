#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "LJOSUMOV.CH"

#DEFINE INSERIR   1
#DEFINE Hora_Inicio 11
#DEFINE Data_Fim    12
#DEFINE Hora_Fim    13
#DEFINE ITEM_IDENTIFICADOR 16
#DEFINE Status 18
#DEFINE Data_Status 19
#DEFINE Hora_Status 20
#DEFINE OBSERVACAO 21
#DEFINE FOTO_POS_MONTAGEM 23

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LJOSUMOV      ³Autor  ³TOTVS                  ³ Data ³ 04/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel pela importação do arquivo ftp uMov.me       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao do Venda Assistida x TELEMARKETING x uMov           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJOSUMOV(cXml)

Local aArea 	  := GetArea() //salva a area atual
Local lMsErroAuto := .F.  // Informa a ocorrência de erros no ExecAuto 
Local lRet        := .T.  // Retorno do exec auto do Atendimento da OS 
Local cLinha 	  := ""   //lê a linha do arquivo recebido do uMov
Local cError	  := ""   //armazena se ocorreu algum erro ao ler o arquivo do uMov
Local cWarning	  := ""   //armazena as mensagens de aviso ao ler o arquivo do uMov
Local cUkey       := ""   //armazena a chave apos leitura do uMov
Local cArquivo	  := ""   //arquivo do uMov
Local cRet		  := ""   //valida retorno do uMov
Local dDTINI      := ""   //data inicial da montagem
Local cHRINI      := ""   //hora inicial da montagem
Local dDTFIM      := ""   //data fim da montagem
Local cHRFIM      := ""   //hora fim da montagem
Local cTecnico    := ""   //tecnico responsavel por executar a montagem
Local cStatus     := ""   //armazena o status do atendimento encerrado ou aberto
Local cDtFim      := ""   // data de fim de execucao da tarefa
Local cData       := ""   // data da tarefa
Local cOS         := ""   // controla a alteração do registro SL1
Local cChave      := ""   // recebe a chave da SL1 na exportação dos dados
Local aDados 	  := {}   //arrray contendo os campos do uMov
Local aCampos 	  := {}   //campos importados do uMov
Local aChave	  := {}   // chave de exportação para o uMov
Local aCabec 	  := {}	  //array contendo os campos do cabecalho do Atendimento da OS de entrega	
Local aItem    	  := {}	  //Array auxiliar para os itens da O.S
Local aItens   	  := {}	  //Array para o item da O.S
Local cArq 	   	  := cXml //recebera o arquivo do ftp do uMov
Local oXml		  := Nil  //objeto responsavel por acessar o ftp do uMov
Local nX		  := 1    //variavel contador de array
Local nHandle     := 0    //variavel usada para controlar a existencia do arquivo importado do uMov
Local nHrTotal    := 0    //total de horas
Local cTotFat     := 0    //total trabalhadas
Local cSeq        := "0"  // controla a sequencia de atendimento da OS de entrega
Local cSeq2       := "0"  // controla a sequencia de atendimento da OS de montagem
Local cCont       := "0"  // controla a revisao do registro SL1
Local cTPServ     := SuperGetMv("MV_LJTPSER",,.F.)     //Tipo de serviço a ser utilizado na geração do item do Atendimento da OS.
Local cCodEntrega := SuperGetMv("MV_LJOCOEN",,.F.)     //Codigo da ocorrencia no SIGATMK que corresponde a entrega.
Local cCodMontagem:= SuperGetMv("MV_LJOCOMO",,.F.)    //Codigo da ocorrencia no SIGATMK que corresponde a montagem.
Local lRegcEntrega:= SuperGetMv("MV_LJREGEN",,.F.)    //Registra atendimento da OS para o item entrega
Local nMG4Rev		:= ""										// Variável auxiliar para gravação do MG4->MG4_REV
Local csData		:= ""										// Data transformada em DtoS()
Local nTamL2Filial	:= Iif(TamSx3("L2_FILIAL")[1]=0,8,TamSx3("L2_FILIAL")[1])		// Comprimento da filial, pode ser entre 2 e 8 caracteres
Local nTamL2Num		:= TamSx3("L2_NUM")[1]												// Comprimento do L2_NUM
Local nTamL2Item		:= TamSx3("L2_ITEM")[1]												// Comprimento do L2_ITEM
Local nTamL2Produto	:= Iif(TamSx3("L2_PRODUTO")[1]=0,15,TamSx3("L2_PRODUTO")[1])	// Comprimento do Produto na tabela SL2
Local lTemFluMov		:= .F.																	// Se existe campo L2_FLUMOV
Local lGravaStatus	:= .F.																	// Se posso gravar status L2_DTUMOV e L2_HRUMOV
Local cChaveAGD      := ""   // recebe a chave da SL1 na exportação dos dados (var. auxiliar em Agenda/Tarefas)

Private INCLUI 	  := .T.  // Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
Private aRotina   := {}   // Array com os menus disponiveis para o ExecAuto


oXML := XmlParser(cArq,"_",@cError,@cWarning)

If XmlChildEx( oXML, "_UMOVIMPORT" ) <> Nil
	cCaminho := oXML:_UmovImport:_RelativeDirectory:Text+"\"+oXML:_UmovImport:_FileName:Text

	nHandle := FT_FUSE(cCaminho) //Abri o Arquivo.

	If nHandle == -1
		Conout("Sem Arquivo Para Ser Importado.")
	Endif
	
	    
	While !FT_FEof()
		
		cLinha 		:= FT_FReadLn()
		cLinha 		:= LJOSLimpar(cLinha)
		aDados 		:= Separa(cLinha,";")
			
		aCampos 	:= {}
		
		If aDados[INSERIR] == "INSERT" //essa linha é importante para que não se leia desde a primeira linha do arquivo ou seja ira ler apartir dos dados
		    DbSelectArea("SL2")
			SL2->(DbSetOrder(1))//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO                                                                                                                             
			If SL2->(DbSeek(xFilial("SL2")+SubStr(aDados[ITEM_IDENTIFICADOR],nTamL2Filial+1,8)))

                cData    := SubStr(aDados[Data_Status],9,2)+"/"+SubStr(aDados[Data_Status],6,2)+"/"+SubStr(aDados[Data_Status],1,4) 
                csData    := SubStr(aDados[Data_Status],1,4)+SubStr(aDados[Data_Status],6,2)+SubStr(aDados[Data_Status],9,2) 
                cDtFim   := SubStr(aDados[Data_Fim],9,2)+"/"+SubStr(aDados[Data_Fim],6,2)+"/"+SubStr(aDados[Data_Fim],1,4) 
				If SL2->L2_REV > 0
					nMG4Rev    := SL2->L2_REV - 1
				Else
					nMG4Rev    := 0
				Endif	
				
				//Atualizacao do historico de importacoes
				DbSelectArea("MG4")
				DbSetOrder(1)//MG4_FILIAL+MG4_NUMLOJ+MG4_PRODUT+MG4_DTMONT+MG4_HRMONT+STR(MG4_REV,2) 
				If !MG4->( DbSeek(xFilial("SL2")+PadR(SL2->L2_NUM,TamSx3("MG4_NUMLOJ")[1]);
								+PadR(SL2->L2_PRODUTO,TamSx3("MG4_PRODUT")[1]);
								+csData+aDados[Hora_Status]) ) 
					RecLock("MG4",.T.)
					MG4_FILIAL     := SL2->L2_FILIAL
					MG4_NUMLOJ     := SL2->L2_NUM
					MG4_REV		:= nMG4Rev
					MG4_CODCONT    := SL2->L2_CODCONT
					MG4_DTMONT     := ctod(cData)
					MG4_HRMONT     := aDados[Hora_Status]
					MG4_OBSERV     := aDados[OBSERVACAO]
					MG4_FOTO       := aDados[FOTO_POS_MONTAGEM]
					MG4_PRODUT     := SL2->L2_PRODUTO
					MG4_DTPROT     := dDataBase 
					MG4_HRPROT     := SubStr( StrTran(Time(),":",""),1,2)+":"+SubStr( StrTran(Time(),":",""),3,2)
				Else
					RecLock("MG4",.F.)
				EndIf					
                
				If aDados[Status] == STR0001 //"Completa" //GERA ATENDIMENTO DA OS SOMENTE SE O ITEM ESTIVER COMPLETO, CONFORME ORIENTACAO DO Conrado e Luiz
		    	  cStatus := "1"						        
				Else
				  If aDados[Status] == STR0002 //"Pendente" //GRAVA HISTORICO NA MG4, PARA POSTERIOR ANALISE E SOLICITAÇÃO MANUAL DE NOVA TAREFA NO UMOV.
					cStatus := "2"
				  Else
				   	cStatus := "3"//"Não realizada" - GRAVA HISTORICO NA MG4, PARA POSTERIOR ANALISE E SOLICITAÇÃO MANUAL DE NOVA TAREFA NO UMOV.
				  Endif	
				Endif 
				
				MG4_STATUS := 	cStatus
				MG4->(MsUnlock())

				DbSelectArea("AB6")
				AB6->(DbSetOrder(5))//AB6_FILIAL+AB6_NUMLOJ
				If AB6->(DbSeek(xFilial("AB6")+SubStr(aDados[ITEM_IDENTIFICADOR],nTamL2Filial+1,6)))

					If aDados[Status] == STR0001 //"Completa" 
						DbSelectArea("ABB")
						ABB->(DbSetOrder(3))//ABB_FILIAL+ABB_NUM
						If ABB->(DbSeek(xFilial("ABB")+AB6->AB6_NUMOS))
				         	cTecnico := ABB->ABB_CODTEC   				         				         
				         	dDTINI   := ABB->ABB_DTINI
						 	cHRINI   := ABB->ABB_HRINI
					     	dDTFIM   := ABB->ABB_DTFIM
						 	cHRFIM   := ABB->ABB_HRFIM  
	
							 //Calcula Total de Horas Realizadas
					   	 	nHrTotal:= SubtHoras(dDTINI,cHRINI,ctod(cData),aDados[Hora_Status])
						 	cTotFat := IntToHora(nHrTotal)   
						 						  
						 	//Adiciona itens para o cabeçalho do Atendimento				 
							cSeq  := 1 + val(LjSeqAtend(AB6->AB6_NUMOS))
						 	cSeq2 := cSeq+1
							 
							cSeq  := PADL(cSeq,2,"0")
						 	cSeq2 := PADL(cSeq2,2,"0")
	                         
	          				aAdd(aCabec,{"AB9_NUMOS"	,AB6->AB6_NUMOS+cSeq	   ,Nil})// Numero da O.S + Item				 
						 	aAdd(aCabec,{"AB9_SEQ"		,"01"		               ,Nil})// Sequencia de Atendimento
						 	aAdd(aCabec,{"AB9_CODTEC"  ,alltrim(ABB->ABB_CODTEC)  ,Nil})// Codigo do Técnico
					 	 	aAdd(aCabec,{"AB9_DTCHEG"	,ABB->ABB_DTINI			   ,Nil})// Data de Chegada				 
						 	aAdd(aCabec,{"AB9_HRCHEG" 	,ABB->ABB_HRINI			   ,Nil})// Hora de Chegada
						 	aAdd(aCabec,{"AB9_DTSAID"	,ctod(cDtFim)		   	   ,Nil})// Data de Saida 12							 
						 	aAdd(aCabec,{"AB9_HRSAID"  ,SubStr(aDados[Hora_Status],1,5)  ,Nil})// Hora de Saida 20
						 	aAdd(aCabec,{"AB9_DTINI"  	,ABB->ABB_DTINI			   ,Nil})// Data de Inicio
						 	aAdd(aCabec,{"AB9_HRINI"  	,ABB->ABB_HRINI 		   ,Nil})// Hora de Inicio
						 	aAdd(aCabec,{"AB9_DTFIM"  	,ctod(cDATA)		  	   ,Nil})// Data de Fim  19
						 	aAdd(aCabec,{"AB9_HRFIM"  	,SubStr(aDados[Hora_Status],1,5)  ,Nil})// Hora de Fim 20
						 	aAdd(aCabec,{"AB9_CODPRB"  ,alltrim(cCodEntrega)	   ,Nil})// Codigo da Ocorrencia - caso o codigo nao exista não grava
						 	
							If cStatus == "1" //COMPLETA                
						 		aAdd(aCabec,{"AB9_TIPO"  	,"1"  ,Nil})// Tipo 1= Encerrado, não é possivel incluir mais sequencias
						 	Else
							 	aAdd(aCabec,{"AB9_TIPO"  	,"2"  ,Nil})// Tipo 2=Aberta						 					 											 							 	
		 				 	Endif
					 
							aAdd(aCabec,{"AB9_TOTFAT"	,PADL(cTotFat,5,"0"),Nil})// Horas Faturadas
							
							// Cliente						 
						 	aAdd(aCabec,{"AB9_CODCLI"  	,PadR(SL1->L1_CLIENTE,TamSx3("L1_CLIENTE")[1]) ,Nil})// Código Cliente
						 	aAdd(aCabec,{"AB9_LOJA"  	,PadR(SL1->L1_LOJA,TamSx3("L1_LOJA")[1]) ,Nil})// Código Loja
						 	aAdd(aCabec,{"AB9_CODPRO"  	,PadR(SL2->L2_PRODUTO,nTamL2Produto) ,Nil})// Código Produto
						 	aAdd(aCabec,{"AB9_NUMORC"  	,PadR(SL1->L1_NUMORC,TamSx3("L1_NUMORC")[1]) ,Nil})// Número Orçamento
							aAdd(aCabec,{"AB9_OBSOL"		,PADL("N",TamSx3("AB9_OBSOL")[1]),Nil})// Obsolescência
							aAdd(aCabec,{"AB9_ATUPRE"	,PADL("N",TamSx3("AB9_ATUPRE")[1]),Nil})// Atual Prev.
							aAdd(aCabec,{"AB9_ATUOBS"	,PADL("N",TamSx3("AB9_ATUOBS")[1]),Nil})// Atual Obsolescência
							aAdd(aCabec,{"AB9_GARANT"	,PADL("N",TamSx3("AB9_GARANT")[1]),Nil})// Garantia
						   	aAdd(aItem, {"AB9_TMKLST"	,PADL(AB6->AB6_NUMOS,TamSx3("AB9_TMKLST")[1]),Nil})// Lista TMK
							
							//Itens do Atendimento da O.S    				
							//Servico Entrega
							
							aAdd(aItem, {"ABA_ITEM"		, "01"	                                           , Nil}) 	    // Local obrigatorio
							aAdd(aItem, {"ABA_CODPRO"		, PadR(SL2->L2_PRODUTO,nTamL2Produto)	   , Nil}) 		// Cod. do Produto				
							aAdd(aItem, {"ABA_LOCAL"		, alltrim(SL2->L2_LOCAL)                           , Nil}) 		// Item 
							aAdd(aItem, {"ABA_QUANT"		, 1								        	       , Nil}) 		// Quantidade usada, DEVE SER NUMERICA
							aAdd(aItem, {"ABA_CODSER"		, alltrim(cTPServ)		 	   					   , Nil}) 	    // Cod. do servico, TEM QUE ESTA CONFIGURADO PARA ATUALIZAR OS
						   	aAdd(aItens,aItem)		
						    	     
						    
							// Executa a rotina automatica para geracao do Atendimento da OS de entrega: Favor nao excluir esse trecho           
							If lRegcEntrega
								lRet:= TECA460(aCabec,aItens,3)						 				    	
							Endif	
	                         
							
							/*/ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Atendimento da montagem ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	                        if lRegCEntrega
		                        aCabec[1][2] := AB6->AB6_NUMOS+cSeq2
		                    else    
		                        aCabec[1][2] := AB6->AB6_NUMOS+cSeq
		                    endif    
	                        aCabec[2][2] := "01"
	                        aCabec[12][2]:= alltrim(cCodMontagem) //caso o codigo nao exista não grava
	                        If cStatus == "1"
							  	aCabec[13][2]:= "1" //Tipo 1= Encerrado, não é possivel incluir mais sequencias
							Else
							 	aCabec[13][2]:= "2" //Tipo 2=Aberta
							Endif	
	
							 // Executa a rotina automatica novamente para geracao do Atendimento da OS referente a montagem:            
							lRet:= TECA460(aCabec,aItens,3)						 				    	
	                                                
						Endif                                                                       			
					    
					EndIf
				
					//Atualizacao do status do Item da Ordem de Serviço
					DbSelectArea("AB7")
					DbSetOrder(1)
					DbSeek(xFilial("AB7")+AB6->AB6_NUMOS)
					While ( AB7->(!Eof()) .And. (xFilial("AB7") == AB6->AB6_FILIAL) .And. (AB7->AB7_NUMOS == AB6->AB6_NUMOS))
               			If (AB7->AB7_CODPRO = PadR(SL2->L2_PRODUTO,nTamL2Produto)) .AND. (alltrim(AB7->AB7_CODPRB) == alltrim(cCodMontagem))
		    				RecLock("AB7",.F.)
               				If cStatus == "1" //"Completa" 
		    	  				AB7->AB7_TIPO := "4"	//"Atendido"					        
							Else
				  				If cStatus == "2" //"Pendente" 
									AB7->AB7_TIPO := "3"//"Em andamento"
				  				Else
							   		AB7->AB7_TIPO := "1"//"Não realizada"##"OS" 
					  			Endif	
							Endif		
							AB7->(MsUnlock())
		    			Endif
						AB7->(DbSkip())
					EndDo
		
				Endif	
			Endif
		EndIf
		
		aCabec := {}
		aItem  := {}
		aItens := {}
		cData  := ""
		cDtFim := ""
		
		FT_FSkip()
		
	EndDo  
				
	Ft_fuse()	//Fecha o arquivo
	
	RestArea(aArea)

EndIf

If XmlChildEx( oXML, "_UMOVEXPORT" ) <> Nil

    If ValType(oXML:_UMovExport:_ListOfKeys:_Key) <> "A"  
   	   XmlNode2Arr(oXML:_UMovExport:_ListOfKeys:_Key,"_Key")
    EndIf                                                   	
    
    cUkey := oXML:_UmovExport:_UniqueKey:Text
	
	cArquivo := oXML:_UmovExport:_FileName:Text
	
	aCampos:=Separa(cUkey,";")
                                                      
  
	For nX := 1 To Len( oXml:_UMovExport:_ListOfKeys:_Key)   
		cRet := oXml:_UMovExport:_ListOfKeys:_Key[nX]:Text
	    Aadd(aChave,cRet)   
	Next nX
	
	If Upper(Left(cArquivo,3)) = "AGD"   // Representa a tabela Tarefa ou Agenda.
		// Preciso marcar um flag para não acontecer o IAG ser o primeiro.
		// Pode acontecer OS disponível na exportação e o IAG ser o primeiro, 
		// isso evita a gravação do status.
		If (SL2->(FieldPos("L2_FLUMOV")) > 0)
			For nX := 1 To Len(aChave)
			    IF cChaveAGD <> (PadR(alltrim(Substr(aChave[nX],nTamL2Filial+2,6)),nTamL2Num)+PadR(Substr(aChave[nX],nTamL2Filial+9,2),nTamL2Item))
    		    	cChaveAGD := PadR(alltrim(Substr(aChave[nX],nTamL2Filial+2,6)),nTamL2Num)+PadR(Substr(aChave[nX],nTamL2Filial+9,2),nTamL2Item)
					If SL2->(DbSeek(xFilial("SL2")+PadR(alltrim(Substr(aChave[nX],nTamL2Filial+2,6)),nTamL2Num)+PadR(Substr(aChave[nX],nTamL2Filial+9,2),nTamL2Item)))
						RecLock("SL2",.F.)
						SL2->L2_FLUMOV := "X" 
						SL2->(MsUnlock())
					EndIf
				EndIf
			Next	 
		EndIf
	ElseIf Upper(Left(cArquivo,3)) = "IAG"   // Representa a tabela Itens da Tarefa.
		// Somente se for a última ordem de exportação (item (do produto)), status preenchido no L1_DTUMOV e L1_HRUMOV.
		// Isto evita exportações repetidas, não podendo passar novamente registros de tarefa, itens do produto e itens da tarefa.
		// Lembrando que a ordem de exportação é: Local, Pessoa, Atividades dos Locais, Tarefas, Item, Itens da Tarefa.	
		For nX := 1 To Len(aChave)
			lTemFluMov 	:= .F.
			lGravaStatus  := .F.
		    IF cChave <> (PadR(alltrim(Substr(aChave[nX],nTamL2Filial+2,6)),nTamL2Num)+PadR(Substr(aChave[nX],nTamL2Filial+9,2),nTamL2Item))
    	    	cChave := PadR(alltrim(Substr(aChave[nX],nTamL2Filial+2,6)),nTamL2Num)+PadR(Substr(aChave[nX],nTamL2Filial+9,2),nTamL2Item)
				DbSelectArea("SL2")
				SL2->(DbSetOrder(1))//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
				lTemFlumov := (SL2->(FieldPos("L2_FLUMOV")) > 0)
				If SL2->(DbSeek(xFilial("SL2")+PadR(alltrim(Substr(aChave[nX],nTamL2Filial+2,6)),nTamL2Num)+PadR(Substr(aChave[nX],nTamL2Filial+9,2),nTamL2Item)))
					If lTemFlUmov 
						If SL2->L2_FLUMOV == "X"
							lGravaStatus := .T.
						EndIf
					Else
						lGravaStatus := .T.
					EndIf				
					IF lGravaStatus
						RecLock("SL2",.F.)
						SL2->L2_DTUMOV := dDataBase
						SL2->L2_HRUMOV := SubStr( StrTran(Time(),":",""),1,2)+":"+SubStr( StrTran(Time(),":",""),3,2)
						SL2->L2_REV    := SL2->L2_REV+1
						If lTemFluMov
							SL2->L2_FLUMOV := "" 
						EndIf
					EndIf
					SL2->(MsUnlock()) 
				EndIf                		
			Endif
		Next nX
	EndIf
EndIf                                                                       


Return {.T.,"OK"}

                                                        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LJOSLimpar       ³Autor  ³TOTVS             ³ Data ³ 04/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Remove a acentuação.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao com o uMov                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LJOSLimpar(cTxt)
Local cRet	:= "" //variavel de retorno
Local nX	:= 0  //contador

For nX := 1 To Len(cTxt)
	If SubStr(cTxt,nX,1) $ "ÃÁÂÀÇÉÊÈÍÎÌÓÕÔÒÚÛÙãáâàçéêèíîìóõôòúûù,'~"
		If SubStr(cTxt,nX,1) == ","
			cRet += " "
		ElseIf SubStr(cTxt,nX,1) == "'"
			cRet += " "
		ElseIf SubStr(cTxt,nX,1) == "~"
			cRet += " "
		ElseIf SubStr(cTxt,nX,1) == "-"
			cRet += " "
		ElseIf SubStr(cTxt,nX,1) == "Ã"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "Á"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "Â"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "À"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "Ç"
			cRet += "C"
		ElseIf SubStr(cTxt,nX,1) == "É"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "Ê"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "È"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "Í"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "Î"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "Ì"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "Ó"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Õ"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Ô"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Ò"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Ú"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "Û"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "Ù"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "ã"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "á"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "â"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "à"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "ç"
			cRet += "C"
		ElseIf SubStr(cTxt,nX,1) == "é"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "ê"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "è"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "í"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "î"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "ì"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "ó"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "õ"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "ô"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "ò"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "ú"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "û"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "ù"
			cRet += "U"
		EndIf
	Else
		cRet += SubStr(cTxt,nX,1)
	EndIf
	
Next nX

Return AllTrim(cRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LjEnceAtend      ³Autor  ³TOTVS               ³ Data ³ 05/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna se encerra o atendimento, caso todos os produtos estao ³±±
±±³           com status completo                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao com o uMov                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LjSeqAtend(cChave)
Local aArea  	:= GetArea()// Salva a area atual
Local cQuery    := ""       // Texto SQL que é enviado para o comando TCGenQry
Local cSeq      := "0"      // retorna a ultima sequencia do atendimento

DbSelectArea("AB9")

cQuery :=	" SELECT AB9_NUMOS " +;
		" FROM 	" + RetSqlName("AB9")  +;
		" WHERE AB9_FILIAL = '"+alltrim(xFilial("AB9"))+"'"+;
		" AND AB9_NUMOS LIKE '%" + alltrim(cChave) + "%'" +;
		" AND D_E_L_E_T_ =  ' '  " +;
		" ORDER BY AB9_NUMOS DESC "  			                                                                                  

cQuery := ChangeQuery(cQuery)

DbSelectArea("AB9")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)

TRB->(DBGoTop())

If TRB->(!Eof()) //se estiver vazio, pode encerrar o atendimento			         
    cSeq := alltrim(SUBSTR(TRB->AB9_NUMOS,7,2))//retorna a ultima sequencia     
Endif 

RestArea(aArea)

TRB->(DbCloseArea())

Return cSeq 
                         
