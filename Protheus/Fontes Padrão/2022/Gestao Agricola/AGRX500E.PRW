#INCLUDE "AGRA500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===================================================================================
/*****  Funções relacionadas a entrada por transferência - Romaneios  *****/
//===================================================================================


/*/{Protheus.doc} A500EntTra
Realiza a entrada por transferência com geração de romaneio de saída automaticamente
@author silvana.torres
@since 27/03/2018
@version undefined
@param cFilCli, characters, descricao
@param cFilOri, characters, descricao
@param cRomOri, characters, descricao
@param lAlgodao, logical, descricao
@param cNumOP, characters, descricao
@type function
/*/
Function A500EntTra(cFilCli, cFilOri, cRomOri, lAlgodao, cNumOP, oModel, lEfet)
	Local cRomPar	 := ""	//--Para o processo de transferencia criar romaneios pelo GFE
	Local aMsgHist	 := {}
	Local lRet		 := .T.
	Local cTpMovto   := SuperGetMV("MV_TPMVTRF",.F.,'') //Tipo de movimento para Transferência entre filiais
	Local cTesEnt	 := ""
	Local cLocalEnt	 := ""
	Local cFil		 := ""
	Local cDesPro	 := ""
	
	Private _cIdMV := ""  //usada para gravar movimentação (AGRX500H.prw)

	//Verifica se entrada foi originada por um romaneio de saída
	If NJJ->NJJ_TIPO = "A" .AND. SUBSTRING(NJJ->NJJ_OBS,1,17) = "Filial de origem:"
	   //se entrada foi criada por saída já foi gravada movimentação no mesmo ID, então não faz nada
	Else
		//senão grava movimentação entrada por transferência no OG (OGA440) 
		If lRet .And. !Empty(cTpMovto) 
		   	lRet := A500GrvMov(cTpMovto, NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)
		EndIf
	EndIf	
							
	IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_CODSAF) .AND. ;
	   .NOT. Empty(NJJ->NJJ_CODENT) .AND. .NOT. Empty(NJJ->NJJ_LOJENT) .AND. .NOT. Empty(NJJ->NJJ_TES) 
	    	   	    	   
	   cTesEnt 		:= NJJ->NJJ_TES
	   cLocalEnt	:= NJJ->NJJ_LOCAL
	    	   	    	   
       //Verifica se Gera Pré-romaneio(flag no tipo de operação)
	   if AGRX500GPR(NJJ->NJJ_TOETAP)
	   
	   		if lAlgodao
		    	lRet := AGRX500DXL(NJJ->NJJ_PSLIQU, .T., cNumOP) //Atualiza peso líquido nos fardões vinculados ao romaneio.
		    endIf
		    
			IF lRet .AND. .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
				//verifica se a produção é de outra filial
				cFilCli := AGRX500POF(NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT)
				
				if trim(cFilCli) <> ""
				
					//--ALTERA A FILIAL CORRENTE PARA A FILIAL DA ENTIDADE
					//================================
					cFilAnt := cFilCli			
					//================================
					
					//gera romaneio pendente de aprovação
					if .NOT. A500GerRom(NJJ->NJJ_TIPO, NJJ->NJJ_TOETAP, cFilOri, .T., lAlgodao, @cRomPar, oModel)
						lRet := .F.
					endIf

					//Verifica se entrada foi originada por um romaneio de saída
					If NJJ->NJJ_TIPO = "A" .AND. SUBSTRING(NJJ->NJJ_OBS,1,17) = "Filial de origem:"
					   //se entrada foi criada por saída já foi gravada movimentação no mesmo ID, então não faz nada
					Else
						//senão grava movimentação saida por transferência no OG (OGA440) 
						If lRet .And. !Empty(cTpMovto) 
						   	lRet := A500GrvMov(cTpMovto, cFilCli, NJJ->NJJ_CODROM)
						EndIf
					EndIf	
					
					//----- a partir daqui a NJJ está posicionada no novo romaneio criado na origem ---
					cRomOri    := NJJ->NJJ_CODROM 
					
					//aprovar romaneio
					aAdd(aMsgHist, STR0090) /*Aprovação automática de romaneio.*/
					aAdd(aMsgHist, 'A') 
					A500Aprov(cRomOri, .F., aMsgHist, .T.)
					
					//gera produção
					//Verifica se Lança produção (flag no tipo de operação)
				   	if AGRX500LP(NJJ->NJJ_TOETAP)
					
						IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
							if .Not. lAlgodao
								if Empty(cNumOP)
									//-- Gera ordem de produção
									Processa({|| lRet := A500GERAOP(@cNumOP, NJJ->NJJ_CODPRO, NJJ->NJJ_PSLIQU, NJJ->NJJ_LOCAL, 3) }, STR0041 , STR0040 )	//"Gerando Ordem de Produção..."###"Aguarde"
								endIf
									
								//-- Realiza o apontamento da OP 
								If lRet
									Processa({|| lRet := A500APROD(cNumOP, NJJ->NJJ_CODROM, NJJ->NJJ_CODPRO, NJJ->NJJ_PSLIQU, NJJ->NJJ_LOCAL, 3) }, STR0039, STR0040 ) //"Movimentando Ordem de Produção..."###"Aguarde"
								EndIf
							endIf
						endIf
					endIf
					
					//Efetua a transferência entre filiais.
					If lRet
					   Processa({|| lRet := AGRX500TRE(NJJ->NJJ_PSLIQU,NJJ->NJJ_CODSAF,NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT,NJJ->NJJ_CODPRO, NJJ->NJJ_TES, cLocalEnt, .T., cTesEnt, {{NJJ->NJJ_CODROM,01,cFilAnt}})}, STR0100, STR0040 ) //"Movimentando Ordem de Produção..."###"Aguarde"
					EndIf   
					
					//Efetiva transferência entre filiais
					If lRet
					   Processa({|| lRet := AGRX500EFT()}, STR0129, STR0040 ) //"Efetivando transferência..."###"Aguarde"
					   lEfet := lRet
					EndIf
					
					If lRet .AND. lAlgodao
						If !(Empty(NJJ->NJJ_PSLIQU))
							//Atualiza status dos fardões vinculados e do rateia o peso liquido nos fardões.
							lRet := AGRX500DXL(NJJ->NJJ_PSLIQU)
						EndIf
					EndIf

					
					//--RETORNA COM A FILIAL DE ORIGEM 
					//================================
					cFilAnt := cFilOri
					//================================
				endIf
			EndIf   
		else
		
			if lAlgodao
		    	lRet := AGRX500DXL(NJJ->NJJ_PSLIQU, .F., cNumOP) //Atualiza peso líquido nos fardões vinculados ao romaneio.
		    endIf
		    
			if lRet .AND. .NOT. Empty(NJJ->NJJ_QTDFIS) 							   
				if lAlgodao
					//gera pendência de diferença entre peso fiscal e peso líquido - algodão 
					If NJJ->NJJ_PSLIQU <> NJJ->NJJ_QTDFIS
					   lRet := AGRX500PFA(NJJ->NJJ_CODROM, NJJ->NJJ_CODSAF, NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT, NJJ->NJJ_PSLIQU, NJJ->NJJ_QTDFIS, NJJ->NJJ_TOETAP)
					EndIf   
				else
					//gera pendência de diferença entre peso fiscal e peso líquido - granel
					If NJJ->NJJ_PSLIQU <> NJJ->NJJ_QTDFIS
					   lRet := AGRX500PFG(NJJ->NJJ_CODROM, NJJ->NJJ_CODSAF, NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT, NJJ->NJJ_PSLIQU, NJJ->NJJ_QTDFIS, NJJ->NJJ_TOETAP)
					EndIf   
					
					if lRet
						if .NOT. A500NFLRec(NJJ->NJJ_DOCNUM, NJJ->NJJ_DOCSER, NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT)
																	
							//-- Lança NF no recebimento
							Processa({|| lRet := A500LancNF(NJJ->NJJ_CODROM, NJJ->NJJ_TIPO  , NJJ->NJJ_DOCNUM, ;
							                                NJJ->NJJ_DOCSER, NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT, ;
							                                NJJ->NJJ_DOCEMI, NJJ->NJJ_DOCESP, NJJ->NJJ_CHVNFE, ;
							                                NJJ->NJJ_PLACA , NJJ->NJJ_CODTRA, NJJ->NJJ_TPFRET, ;
						                                	NJJ->NJJ_PSLIQU, NJJ->NJJ_PSSUBT ) }, STR0071 , STR0040 )	//"Gerando Nota Fiscal de Entrada..."###"Aguarde"
						endIF
					endIf
				endIf
			endIf
		endIf
	endIf
	
	If lRet
		//somente resolve pendências se for romaneio de entrada gerado por uma saída
		if SUBSTRING(NJJ->NJJ_OBS,1,17) = "Filial de origem:"
			//soluciona pendência de diferença entre peso fiscal e peso líquido - algodão
			If NJJ->NJJ_PSLIQU <> NJJ->NJJ_QTDFIS
				if !(EMPTY(N9C->N9C_ITEM))
					//Solução automática de pendências
					DbSelectArea('N92')
					N92->(DbSetOrder(1))
					
					if N92->(MsSeek(FWxFilial('N92')+NJJ->NJJ_TOETAP))
						If N92->N92_AUTPEN			
							// Função AGRX500SPA esta no fonte AGRX500B
							lRet := AGRX500SPA(N9C->N9C_TPPEN)	
							If !(lRet)
								Help( ,, STR0048,, STR0128, 1, 0)	//"Ajuda" "Não foi possível ajustar automaticamente as pendências."
							EndIf
						Else
							If N9C->N9C_QTDPEN < 0 //devolução
								cFil := N9C->N9C_FILORI //Filial origem da pendência
							Else //complemento
								cFil := N9C->N9C_FILROM //Filial do romaneio de origem da transferência
							EndIf
							
							cDesPro := Posicione("SB1",1,FWxFilial("SB1")+NJJ->NJJ_CODPRO,"B1_DESC")
							
							MsgInfo(STR0139 + AllTrim(NJJ->NJJ_CODPRO) + " - " + AllTrim(cDesPro) + STR0140 + AllTrim(cFil) + ".") //"Foi gerada uma pendência fiscal para o produto " //" na filial " 
						EndIf
					EndIF	
					N92->(dbCloseArea())
				EndIf
			EndIf
		EndIf			
	EndIf
	
	//inicializa variavel do tipo de movimento -- função A500GrvMov()
	_cIdMV := ""	
		
Return lRet