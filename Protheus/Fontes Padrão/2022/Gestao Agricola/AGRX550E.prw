#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRX550.CH"

//====================================================================================
/*****  Funções para gerar autorização carregamento através contrato logístico  *****/
//====================================================================================

/*/{Protheus.doc} GFEAGR001
//Função criar autorização de carregamento a partir de um contrato logistico
@author marina.muller
@since 13/09/2018
@version 1.0
@return ${return}, ${return_description}
@param CFilGXT, , descricao
@param cNrCtGXT, characters, descricao
@type function
/*/
Function GFEAGR001(CFilGXT, cNrCtGXT, lEfetiva)
	Local aArea     := GetArea()
	Local lRet	    := .T.
	Local aAutoN8N  := {}
	Local aItemN8O  := {}
	Local cCodSaf   := ""
	Local cCodPro   := ""
	Local cCodTrp   := ""
	Local cMsgAprov	:= STR0040 + cNrCtGXT //"Contrato Logístico - "
	Local cEmitTmp  := SuperGetMv("MV_EMITMP",.F.,"0") //Modo de codificação do emitente de transporte
	Local nQtdAuto  := 0 
	
	Private _cCodAut := ""
	
	//primeira vez GFE manda como .F. somente para validar valores no AGRO
	//segunda  vez GFE manda como .T. para efetivar gravação do registro
	//se não vier variavel defult será .T. 
	Default lEfetiva := .T.
	
	if !EMPTY(cNrCtGXT)
		//-- INICIO TRANSACAO --//
		BEGIN TRANSACTION
			
			//busca filtrando pelo contrato o ID da requisição 
			GXS->(dbSelectArea('GXS'))
			GXS->(dbSetOrder(2))    	
			If GXS->(dbSeek(CFilGXT+cNrCtGXT)) //GXS_FILCT+GXS_NRCT
		
			    //trabalha por 0=CNPJ/CPF
			    If cEmitTmp == "0" 
				    //busca transportadora pelo código emitente
				    SA4->(dbSelectArea('SA4'))
					SA4->(dbSetOrder(3))    	
					If SA4->(MsSeek(FwxFilial("SA4")+GXS->GXS_CDTRP)) //A4_FILIAL+A4_CGC
						cCodTrp := SA4->A4_COD
					EndIf  
					SA4->(dbCloseArea())
				
				//trabalha por 1=Numeração própria
				Else
				    //busca transportadora pela numeração própria
				    GU3->(dbSelectArea('GU3'))
					GU3->(dbSetOrder(1))    	
					If GU3->(MsSeek(FwxFilial("GU3")+GXS->GXS_CDTRP)) //GU3_FILIAL+GU3_CDEMIT
						//Transpotador ou autonomo.
						WHILE !(EOF()) .AND. (GU3->GU3_TRANSP = '1' .OR. GU3->GU3_AUTON = '1')
						
							cCodTrp := GU3->GU3_CDTERP  //transportadora ERP (se estiver branco não foi feita sincronização do GFE)
							
							GU3->(dbSkip())
						endDo
					EndIf  
					GU3->(dbCloseArea())
				EndIf	
				
				//busca filtrando pelo ID da requisição os código das IE´s 
				N9R->(dbSelectArea('N9R'))
				N9R->(dbSetOrder(3))    	
				If N9R->(MsSeek(GXS->GXS_FILIAL+GXS->GXS_IDREQ)) //N9R_FILORI+N9R_IDREQ
					While N9R->(!Eof())                      .And.;
					      N9R->N9R_FILORI == GXS->GXS_FILIAL .And.; 
					      N9R->N9R_IDREQ  == GXS->GXS_IDREQ
					      			
						//busca filtrando pelos códigos IE´s para buscar regra
						N7S->(dbSelectArea('N7S'))
						N7S->(dbSetOrder(3))    	
						If N7S->(MsSeek(FwxFilial("N7S")+N9R->N9R_CODINE+N9R->N9R_FILORI)) //N7S_FILIAL+N7S_CODINE+N7S_FILORG
							
							//busca filtrando pelos códigos IE´s para buscar safra/ entidade/ loja/ produto
							N7Q->(dbSelectArea('N7Q'))
							N7Q->(dbSetOrder(1))    	
							If N7Q->(MsSeek(FwxFilial("N7Q")+N7S->N7S_CODINE)) //N7Q_FILIAL+N7Q_CODINE
								aAdd(aItemN8O, {GXS->GXS_FILIAL,;   //1 - filial
								                "1",;               //2 - status (1=Pendente;2=Aberta;3=Atendida)
								                N9R->N9R_CODINE,;   //3 - IE
								                N9R->N9R_ITEM,;     //4 - ID entrega
								                N9R->N9R_CODCTR,;   //5 - contrato
								                N9R->N9R_FILORI,;   //6 - filial origem
								                N7S->N7S_SEQPRI,;   //7 - ID regra
								                N7Q->N7Q_ENTENT,;   //8 - entidade destino
								                N7Q->N7Q_LOJENT,;	//9 - loja destino
								                N9R->N9R_QTDCTR})   //10 - qtidade atendida
								
								cCodSaf  := N7Q->N7Q_CODSAF
								cCodPro  := N7Q->N7Q_CODPRO 
								nQtdAuto += N9R->N9R_QTDCTR
								
								OGA710Status(1,1,cMsgAprov)
							EndIf
							N7Q->(dbCloseArea())
						EndIf
						N7S->(dbCloseArea())
					
						N9R->(dbSkip())
					EndDo
				EndIf
				N9R->(dbCloseArea())
					
				aAdd(aAutoN8N, {GXS->GXS_FILIAL,;    //1 - filial
								"2",;                //2 - tipo (1=Entrada;2=Saída)
								cCodTrp,;            //3 - transportadora
								"1",;				 //4 - status (1=Pendente;2=Aberta;3=Atendida)
								RetCodUsr(),;		 //5 - usuario
								dDataBase,;			 //6 - data transação
								cCodSaf,;			 //7 - safra
								cCodPro,;			 //8 - produto
								nQtdAuto})			 //9 - qtidade autorizada	
				
			
				//inclui registro na N8N / N8O 
				lRet := AGRX550N8N(aAutoN8N, aItemN8O, lEfetiva)
			
			    If !(lRet)
				   DisarmTransaction()
				EndIf
		
				GXS->(dbCloseArea())
				EndIf
		END TRANSACTION
		//-- FINAL TRANSACAO --//
	endIf

    RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} AGRX550N8N
//Função incluir tabelas N8N e N8O
@author marina.muller
@since 13/09/2018
@version 1.0
@return ${return}, ${return_description}
@param aAutoN8N, array, descricao
@param aItemN8O, array, descricao
@type function
/*/
Static Function AGRX550N8N(aAutoN8N, aItemN8O, lEfetiva)
	Local aArea    := GetArea()
	Local lRet	   := .T.
	Local nI
	Local cCodItem := ""

	//Instancia o Model do AGRA540 (Autorização Carregamento)
	oMdlN8N := FwLoadModel("AGRA540")
   
	//Seta operação de Inclusão
	oMdlN8N:SetOperation(MODEL_OPERATION_INSERT)
    
    //Ativa o modelo
	oMdlN8N:Activate()
	
	//seta valores N8N - cabecalho autorização
	oMdlN8N:SetValue('AGRA540_N8N','N8N_FILIAL', aAutoN8N[1][1])   //1 - filial      
	oMdlN8N:SetValue('AGRA540_N8N','N8N_TIPO',   aAutoN8N[1][2])   //2 - tipo (1=Entrada;2=Saída)
	oMdlN8N:SetValue('AGRA540_N8N','N8N_CODTRA', aAutoN8N[1][3])   //3 - transportadora           
	oMdlN8N:SetValue('AGRA540_N8N','N8N_STATUS', aAutoN8N[1][4])   //4 - status (1=Pendente;2=Aberta;3=Atendida)
	oMdlN8N:SetValue('AGRA540_N8N','N8N_CODUSU', aAutoN8N[1][5])   //5 - usuario
	oMdlN8N:SetValue('AGRA540_N8N','N8N_DTTRAN', aAutoN8N[1][6])   //6 - data transação
	oMdlN8N:SetValue('AGRA540_N8N','N8N_SAFRA',  aAutoN8N[1][7])   //7 - safra
	oMdlN8N:SetValue('AGRA540_N8N','N8N_CODPRO', aAutoN8N[1][8])   //8 - produto
	oMdlN8N:SetValue('AGRA540_N8N','N8N_QTDAUT', aAutoN8N[1][9])   //9 - qtidade autorizada
	
	If ( lRet := oMdlN8N:VldData() )
		//se parâmetro estiver .T. grava autorização
		If lEfetiva
			lRet := FWFormCommit(oMdlN8N)
		EndIf	
		
		If lRet
		    _cCodAut := FWFLDGET('N8N_CODIGO')   //Armazena código da autorização carregamento
		   
			For nI := 1 To Len(aItemN8O)
				cCodItem := nI
				
				//seta valores N8O - itens autorização
				oMdlN8N:SetValue('AGRA540_N8O','N8O_FILIAL', aItemN8O[nI][1])                           //1 - filial      
				oMdlN8N:SetValue('AGRA540_N8O','N8O_CODAUT', _cCodAut)                                  //código autorização carregamento
				oMdlN8N:SetValue('AGRA540_N8O','N8O_ITEM',   StrZero(cCodItem , TamSX3('N8O_ITEM')[1])) //código item
				oMdlN8N:SetValue('AGRA540_N8O','N8O_STATUS', aItemN8O[nI][2])                           //2 - status (1=Pendente;2=Aberta;3=Atendida)
				oMdlN8N:SetValue('AGRA540_N8O','N8O_CODINE', aItemN8O[nI][3])                           //3 - IE
				oMdlN8N:SetValue('AGRA540_N8O','N8O_IDENTR', aItemN8O[nI][4])                           //4 - ID entrega
				oMdlN8N:SetValue('AGRA540_N8O','N8O_CODCTR', aItemN8O[nI][5])                           //5 - contrato
				oMdlN8N:SetValue('AGRA540_N8O','N8O_FILORI', aItemN8O[nI][6])                           //6 - filial origem
				oMdlN8N:SetValue('AGRA540_N8O','N8O_IDREGR', aItemN8O[nI][7])                           //7 - ID regra
				oMdlN8N:SetValue('AGRA540_N8O','N8O_ENTDES', aItemN8O[nI][8])                           //8 - entidade destino
				oMdlN8N:SetValue('AGRA540_N8O','N8O_LOJDES', aItemN8O[nI][9])                           //9 - loja destino
				oMdlN8N:SetValue('AGRA540_N8O','N8O_QTATEN', aItemN8O[nI][10])                          //10 - qtidade atendida
			
				If ( lRet := oMdlN8N:VldData() )
					//se parâmetro estiver .T. grava itens autorização
					If lEfetiva
						lRet := FWFormCommit(oMdlN8N)
					EndIf	
				Else
					lRet := .F.
					
					// Se os dados não foram validados obtemos a descrição do erro para gerar
					// LOG ou mensagem de aviso
					AutoGrLog(oMdlN8N:GetErrorMessage()[6])
					AutoGrLog(oMdlN8N:GetErrorMessage()[7])
					If !Empty(oMdlN8N:GetErrorMessage()[2]) .And. !Empty(oMdlN8N:GetErrorMessage()[9])
						AutoGrLog(oMdlN8N:GetErrorMessage()[2] + " = " + oMdlN8N:GetErrorMessage()[9])
					EndIf
					
					MostraErro()
			   EndIf
		    Next nI
		EndIf   
	Else
		lRet := .F. 
				
		// Se os dados não foram validados obtemos a descrição do erro para gerar
		// LOG ou mensagem de aviso
		AutoGrLog(oMdlN8N:GetErrorMessage()[6])
		AutoGrLog(oMdlN8N:GetErrorMessage()[7])
		If !Empty(oMdlN8N:GetErrorMessage()[2]) .And. !Empty(oMdlN8N:GetErrorMessage()[9])
			AutoGrLog(oMdlN8N:GetErrorMessage()[2] + " = " + oMdlN8N:GetErrorMessage()[9])
		EndIf
		
		MostraErro()
   EndIf
   
   // Desativamos o Model
   oMdlN8N:DeActivate()
   
   RestArea(aArea)

Return lRet
