#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/**********************************************************************************
***********************************************************************************
***********************************************************************************
***Funcão.....: RHIMP28.PRW  Autor: PHILIPE.POMPEU  Data:21/03/2016 			   ***
***********************************************************************************
***Descrição..:	Importa o arquivo de Plano de Saúde							   ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Parâmetros.:		${param}, ${param_type}, ${param_descr}					   ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                           	   ***
***********************************************************************************
***					Alterações feitas desde a construção inicial               	   ***
***********************************************************************************
***Leandro Dr. |27/07/16|      |Tratamento para utilizacao de DE-PARA de rotina ***
***............|........|......|de importação genérica.                         ***
**********************************************************************************/
/*/{Protheus.doc} RHIMP28
	Função responsável pela importação do arquivo de Plano de Saúde;
@author PHILIPE.POMPEU
@since 21/03/2016
@version P11
@param cArquivo, caractere, arquivo para ser importado(caminho completo, ex: "C:\logix\arquivo.unl")
@return nil, Nulo
/*/
User Function RHIMP28(cArquivo,aRelac,oSelf)	
	Local cBuffer 	:= ""
	Local aLinha 	:= {}	
	Local cEmpresa 	:=""
	Local cFil 		:= ""
	Local nTipo		:= ""
	Local lProcede 	:= .F.
	Local lInvalido	:= .F.
	Local aErros 	:= {}
	Local nNumLinha := 0
	Local cNumLinha := ""
	Local lNew 		:= .T.	
	Local cConteu	:= ""
	Local aFornecdrs:= {}
	Local aUmFornec	:= {}
	Local aUmPlano 	:= {}
	Local nPos		:= 0 
	Local nI 		:= 0
	Local nJ 		:= 0
	Local nTamRccFil:= TamSx3('RCC_FIL')[1]
	Local nTamChave	:= TamSx3('RCC_CHAVE')[1]
	Local nTamCodAg	:= TamSx3('RHM_CODIGO')[1]
	Local aSeqs		:= {}
	Local lValorFixo:= .T.	
	Local nValTitul	:= 0
	Local nValDepen	:= 0
	Local nValAgreg	:= 0
	Local aUmaFaixa	:= {}
	Local aFaixas	:= {}
	Local xTemp		:= {}
	Local aPLAtivos	:= {}
	Local nLen		:= 0
	Local lFound 	:= .F.	
	Local cChave	:= ""
	Local cMesAno	:= ""
	Local aDePara	:= {}
	Local cCodPlano	:= ""
	Local cCodForn	:= ""
	Local cTpPlan	:= ""	
	
	DEFAULT aRelac	:= {}
	
	Private nTamSeq		:= TamSx3('RCC_SEQUEN')[1]
	Private cArqDePara	:= "\CODPLALOGIXPROTHEUS.UNL" /*Nome do Arquivo utilizado para De/Para dos códigos dos Planos de Saúde.*/

	FT_FUSE(cArquivo)	
	/*Seta tamanho da Regua*/
	nLen := U_ImpRegua(oSelf,3,3) /*1x pro De/Para, 1x pra Leitura do Arquivo, 1x pra Gravação*/	
	FT_FGOTOP()
	
	/*Processa qualquer registro do Tipo 2 para fazer um De/Para, necessário
	pois o campo no Logix pode ter tam. char(4) enquanto no Protheus é char(2)*/
	While !(FT_FEOF())		
		U_IncRuler("Carregando De/Para.",,,,.T.,,oSelf)
		cBuffer:= FT_FREADLN()
		if(SubStr(cBuffer,1,1) == '2')
			aLinha	:= Separa(cBuffer,'|')
			cCodForn := CodFornPic(aLinha[2])			
			aAdd(aDePara,{cCodForn,aLinha[3],PadR(aLinha[4],20),PadL(Right(aLinha[3],2),2,'0')})
			aSize(aLinha,0)							
		endIf				
		FT_FSKIP()			
	EndDo
	
	/*Após carregar os registros do arquivo, exibe tela pra configuração do De/Para do Logix para o Protheus*/	
	if(!LogToProth(aDePara))
		FT_FUSE()
		Return(Nil)//Nesse caso o usuário cancelou a operação!
	endIf	
	
	/*Volta ao arquivo original!*/	
	FT_FUSE(cArquivo)
	FT_FGOTOP()
	
	RCC->(DbSetOrder(1))
	
	/*Primeiro é feita a leitura do arquivo, cada linha jogada em um determinado vetor para
	posteriormente ser gravad no banco.*/
	While !FT_FEOF() .And. !lStopOnErr
		nNumLinha++
		cNumLinha := cValToChar(nNumLinha)
		U_IncRuler("Analisando Arquivo : Linha ["+ cNumLinha +"/"+ cValToChar(nLen)+"]...",,,,.T.,,oSelf)
					
		lInvalido	:= .F.
		cBuffer		:= FT_FREADLN()
		aLinha		:= Separa(cBuffer,'|')		
		nTipo		:= Val(aLinha[1])
		
		Do Case
			Case (nTipo == 1)/*São os registros que guardam os Fornecedores Odont/Medico.*/					
				cCodForn := CodFornPic(aLinha[2])
				/*Apenas com os registros de tipo 1 não é possível saber se o fornecedor é
				Odontológico ou Médico, dessa forma essa posição fica em branco até encontrar
				um registro do Tipo 2 que possa nos fornecer essa informação!*/
				aAdd(aUmFornec,Nil) /*Posição reservada p/ o código da Tabela*/
				aAdd(aUmFornec,cCodForn) /*Código do Fornecedor*/
				aAdd(aUmFornec,PadR(Transform(aLinha[3],"@!"),150))/*Nome do Fornecedor*/
				aAdd(aUmFornec,PadR(aLinha[4],14)) /*CNPJ do Fornecedor*/
				aAdd(aUmFornec,PadL(aLinha[5],9,'0'))/*Registro ANS*/
				aAdd(aUmFornec,{})/*Planos do Fornecedor*/
				aAdd(aFornecdrs,aUmFornec)
				
				aUmFornec := {}								
			Case (nTipo == 2)/*São os registros que guardam os Planos dos Fornecedores*/
				aUmPlano := {}
				cCodForn := CodFornPic(aLinha[2])
				/*Pesquisa o código do Fornecedor dentro do vetor de Fornecedores*/
				nPos := aScan(aFornecdrs,{|x| x[2] == cCodForn})				
				
				if(nPos > 0)
					/*Tipo do Fornecedor e Tipo do Plano*/										
					if(aLinha[5] $ "M|O" .And. aLinha[7] $ "V|I")
						if(aLinha[5] == "M") /*Assistência Médica*/					
							/*Ocasionalmente pode ser que um mesmo fornecedor seja
							Odontológico E Médico*/
							if(aFornecdrs[nPos,1] == Nil .Or. aFornecdrs[nPos,1] == "S016")							
								aFornecdrs[nPos,1] := "S016"
							else
								 /*Quando ocorre essa situação, duplicamos esse registro e o importamos pras 2 tabelas*/							
								aAdd(aFornecdrs,aClone(aFornecdrs[nPos]))
								nPos := Len(aFornecdrs)
								aFornecdrs[nPos,1] := "S016"
								aFornecdrs[nPos,6] := {}																				
							endIf
							
							if(aLinha[7] == 'V') /*Se for Valor Fixo*/
								aAdd(aUmPlano,"S028")							
							elseIf(aLinha[7] == 'I')
								aAdd(aUmPlano,"S009")
							endIf					
						elseIf(aLinha[5] == "O")	/*Odontológica*/
						
							if(aFornecdrs[nPos,1] == Nil .Or. aFornecdrs[nPos,1] == "S017")							
								aFornecdrs[nPos,1] := "S017"
							else
								aAdd(aFornecdrs,aClone(aFornecdrs[nPos]))
								nPos := Len(aFornecdrs)																				
								aFornecdrs[nPos,1] := "S017"
								aFornecdrs[nPos,6] := {}						
							endIf
						
							if(aLinha[7] == 'V')/*Se for Valor Fixo*/
								aAdd(aUmPlano,"S030")
							elseIf(aLinha[7] == 'I')
								aAdd(aUmPlano,"S014")
							endIf											
						endIf
						
						aAdd(aUmPlano,GetPLACod(cCodForn + aLinha[3],aDePara)) /*Código do Plano*/
						aAdd(aUmPlano,PadR(aLinha[4],20)) /*Descrição*/
						
						lValorFixo := aUmPlano[1] $ 'S028|S030'
	 					
						if(lValorFixo)
							aAdd(aUmPlano,Transform(Val(aLinha[6]),'@E 9,999,999.99')) /*Vl. Titular*/
							aAdd(aUmPlano,Transform(Val(aLinha[6]),'@E 9,999,999.99')) /*Vl. Dependente*/
							aAdd(aUmPlano,Transform(Val(aLinha[6]),'@E 9,999,999.99')) /*Vl. Agregado*/
							
							/*Poderia ter posto apenas Space(36), porém achei que ficaria mais claro
							colocando separadamente, facilitando a leitura do código.*/
							aAdd(aUmPlano,Space(12)) /*VLRDSCTIT*/
							aAdd(aUmPlano,Space(12)) /*VLRDSCDEP*/
							aAdd(aUmPlano,Space(12)) /*VLRDSCAGRD*/						
							aAdd(aUmPlano,cCodForn)  /*Código Fornecedor*/					
							aAdd(aFornecdrs[nPos,6],aUmPlano)
						else
							aUmaFaixa := {}
							aFaixas := {}					
							/*Obter todas as Faixas individualmente...*/
							for nI:= 8 to Len(aLinha)							
								aAdd(aUmaFaixa,aLinha[nI])
								if(Len(aUmaFaixa) == 3)
									aAdd(aFaixas,aUmaFaixa)
									aUmaFaixa := {}
								endIf							
							next nI
							/*Se alguma posição tiver menos de 3 posições, isso garantirá a consistência*/
							aEval(aFaixas,{|x|aSize(x,3)})
							
							aUmaFaixa := aClone(aFaixas)
							aFaixas := {}
							
							/*Aglutinar Faixas por Idade*/
							for nI:= 1 to Len(aUmaFaixa)
							
								if(aUmaFaixa[nI,1] $ 'T|D|A')					
									nJ := aScan(aFaixas,{|x| x[1] == aUmaFaixa[nI,2]})
									if(nJ == 0)	
										aAdd(xTemp,aUmaFaixa[nI,2]) 
										aAdd(xTemp,Array(3))
										aAdd(aFaixas,xTemp)							
										xTemp := {}
										nJ := Len(aFaixas)
									endIf
																
									Do Case
										Case (aUmaFaixa[nI,1] == 'T') /*Títular*/
											nValTitul	:= Val(aUmaFaixa[nI,3])
											nValDepen	:= IfNilZero(aFaixas[nJ,2,2])
											nValAgreg	:= IfNilZero(aFaixas[nJ,2,3])
										Case (aUmaFaixa[nI,1] == 'D') /*Dependente*/
											nValTitul	:= IfNilZero(aFaixas[nJ,2,1])
											nValDepen	:= Val(aUmaFaixa[nI,3])
											nValAgreg	:= IfNilZero(aFaixas[nJ,2,3])
										Case (aUmaFaixa[nI,1] == 'A') /*Agregado*/
											nValTitul	:= IfNilZero(aFaixas[nJ,2,1])
											nValDepen	:= IfNilZero(aFaixas[nJ,2,2])
											nValAgreg	:= Val(aUmaFaixa[nI,3])
									EndCase														
									aFaixas[nJ,2,1] := nValTitul
									aFaixas[nJ,2,2] := nValDepen
									aFaixas[nJ,2,3] := nValAgreg
								Else										
									/*Apenas os valores T, D, A serão válidos para importação*/									
									aAdd(aErros,GetErrMsg(cNumLinha,"Tipo de Beneficiário do Plano inválido -> " + aUmaFaixa[nI,1]))
								endIf																					
							next nI							
														
							for nI:= 1 to Len(aFaixas)
								xTemp := aClone(aUmPlano)								
								aAdd(xTemp,Transform(Val(aFaixas[nI,1]),'999'))
								aAdd(xTemp,Transform(aFaixas[nI,2,1],'@E 9,999,999.99'))
								aAdd(xTemp,Transform(aFaixas[nI,2,2],'@E 9,999,999.99'))
								aAdd(xTemp,Transform(aFaixas[nI,2,3],'@E 9,999,999.99'))									
								aAdd(xTemp,Space(7)) /*PERCTIT*/
								aAdd(xTemp,Space(7)) /*PERCDEP*/
								aAdd(xTemp,Space(7)) /*PERCAGR*/
								aAdd(xTemp,cCodForn) /*Código Fornecedor*/					
								aAdd(aFornecdrs[nPos,6],aClone(xTemp))
								aSize(xTemp,0)									
							next nI
													
						endIf /*Fim Tipo "Por Idade"*/
					else
					
						if!(aLinha[5] $ "M|O")										
							aAdd(aErros,GetErrMsg(cNumLinha,"Tipo do Fornecedor inválido -> " + aLinha[5]))
						endIf 
						
						if!(aLinha[7] $ "V|I")
							aAdd(aErros,GetErrMsg(cNumLinha, "Tipo do Plano inválido -> " + aLinha[7]))
						endIf				
						
					endIf
				Else
					/*Registro deve ser ignorado!*/
					aAdd(aErros,GetErrMsg(cNumLinha,"Fornecedor não encontrado no arquivo."))
				endIf
				
			Case (nTipo == 3)/*São os registros que guardam os planos Ativos*/
				xTemp := {}
				aEval(aLinha,{|x|aAdd(xTemp,x)},2)
				
				/*Guarda o número da linha para referência no Log.*/
				aAdd(xTemp,nNumLinha)
				
				if!(Empty(aLinha[9]))/*Caso sequência de Dependente esteja preenchido...*/
					aAdd(xTemp,2) //Tipo Dependente
				elseIf!(Empty(aLinha[10]) .Or. Empty(aLinha[11]) .Or. Empty(aLinha[12])) /*Caso as informações do Agregado estejam preenchidas...*/
					aAdd(xTemp,3) //Tipo Agregado
				Else /*Caso não exista nenhuma informação adicional, é Títular...*/
					aAdd(xTemp,1) //Tipo Titular
				endIf													
				
				aAdd(aPLAtivos,xTemp)			
		EndCase		
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErros)
		FT_FSKIP()			
	EndDo
	FT_FUSE()/*Libera o Arquivo.*/
		
	SM0->(dbGoTop())				
	cEmpresa := Nil
	while ( SM0->(!Eof()))
		PREPARE ENVIRONMENT EMPRESA (SM0->M0_CODIGO) FILIAL (SM0->M0_CODFIL) MODULO "GPE"		
		
		if(xFilial("RCC") != cEmpresa)
			cEmpresa := xFilial("RCC")
			
			for nI:= 1 to Len(aFornecdrs)				
				U_IncRuler("Processando Tipo 1 e 2 ["+ cEmpAnt +"/"+ cFilAnt + "]["+ cValToChar(nI) +"/"+ cValToChar(Len(aFornecdrs)) +"]",,,,.T.,,oSelf)
				
				if(Empty(aFornecdrs[nI,1]))/*Essa situação ocorre quando há um registro do Tipo 1 sem nenhum registro do Tipo 2				
				existente ou válido, nesse caso basta ignorar o registro em questão pois o mesmo já foi
				incluido no log anteriormente*/
					Loop	
				endIf
				
				Begin Transaction /*Ou o registro é gravado por completo ou é descartado.*/															
					lNew := !(ValidRCC(aFornecdrs[nI,1],aFornecdrs[nI,2],1,3,.F.))
												
					RecLock("RCC",lNew)					
					if(lNew)						
						RCC->RCC_FILIAL:= cEmpresa
						RCC->RCC_FIL	 := Space(nTamRccFil)
						RCC->RCC_CHAVE := Space(nTamChave)					
						RCC->RCC_CODIGO:= aFornecdrs[nI,1]				
						RCC->RCC_SEQUEN:= GetNextSeq(aFornecdrs[nI,1],1)
					endIf
															
					cConteu := ""					
					aEval(aFornecdrs[nI],{|x|cConteu+=x},2,4)
					
					RCC->RCC_CONTEU := cConteu
					
					RCC->(MsUnlock())				
					
					aSort(aFornecdrs[nI,6],,,{|x,y|x[2]+ aTail(x) + x[4] < y[2]+ aTail(y) + y[4]})
					
					for nJ:= 1 to Len(aFornecdrs[nI,6])						
						aUmPlano := aFornecdrs[nI,6,nJ]											 						
						lNew := !(VldPlanoRcc(aUmPlano[1], aUmPlano[2], aTail(aUmPlano),IIF(aUmPlano[4] == Nil,aUmPlano[4],"")))
						
						RecLock("RCC",lNew)
						
						if(lNew)							
							RCC->RCC_FILIAL:= cEmpresa
							RCC->RCC_FIL	 := Space(nTamRccFil)
							RCC->RCC_CHAVE := Space(nTamChave)
							
							nPos := aScan(aSeqs,{|x|x[1] == aUmPlano[1]})						
							if(nPos == 0)
								aAdd(aSeqs,{aUmPlano[1],Val(GetNextSeq(aUmPlano[1]))})
								nPos := Len(aSeqs)
							endIf						
							aSeqs[nPos,2]++						
							RCC->RCC_SEQUEN:= StrZero(aSeqs[nPos,2],nTamSeq)
							RCC->RCC_CODIGO := aUmPlano[1]				
						endIf
												
						cConteu := ""						
						aEval(aUmPlano,{|x|cConteu+=x},2)
						RCC->RCC_CONTEU := cConteu
						
						RCC->(MsUnlock())	
					next
				End Transaction
			next nI
														
		endIf
		
		SM0->(dbSkip())
	EndDo
	
	SRA->(DbSetOrder(1))
	SRB->(DbSetOrder(1))
	SRV->(DbSetOrder(1))
	nLen := Len(aPLAtivos)
	for nI:= 1 to nLen
		
		if(lStopOnErr)
			Exit
		endIf
				
		U_IncRuler("Processando Tipo 3 ["+ cValToChar(nI) +"/"+ cValToChar(nLen) +"]",,,,.T.,,oSelf)
		cEmpresa 	:= aPLAtivos[nI,1]
		cFil 		:= aPLAtivos[nI,2]
		
		
		U_RHPREARE(cEmpresa,cFil,'','',.F.,@lProcede,"RHIMP28",{'RCC','SRB','SRA'},"GPE",@aErros,"Plano de Saúde")
		
		if(lProcede)
			lInvalido:= .F.
			xTemp := Len(aPLAtivos[nI])		
			nTipo := aPLAtivos[nI,xTemp]			
			cNumLinha:= cValToChar(aPLAtivos[nI,xTemp - 1])
			
			cCodForn	:= CodFornPic(aPLAtivos[nI,5])
			cCodPlano	:= GetPLACod(cCodForn + aPLAtivos[nI,6], aDePara)
			
			//BUSCA DE-PARA dos códigos
			If !Empty(aRelac)
				aPLAtivos[nI,3] := u_GetCodDP(aRelac,"RB_MAT",aPLAtivos[nI,3],"RA_MAT") //Busca DE-PARA
				aPLAtivos[nI,7] := u_GetCodDP(aRelac,"RHK_PD",aPLAtivos[nI,7],"RV_COD") //Busca DE-PARA
			EndIf
			
			if(Empty(aPLAtivos[nI,3]) .Or. (!SRA->(DbSeek(xFilial('SRA')+aPLAtivos[nI,3]))))			
				if(Empty(aPLAtivos[nI,3]))
					aAdd(aErros,GetErrMsg(cNumLinha,'Campo [Matrícula] é obrigatório.'))
				else
					aAdd(aErros,GetErrMsg(cNumLinha,'Campo [Matrícula] inválido ->' + aPLAtivos[nI,3]))
				endIf					
				lInvalido := .T.
			Else
				/*Obtêm o Período Ativo em formato MMAAAA 
				Ex.: Se (Período == 201604) Então (cMesAno == 042016)*/
				cMesAno := GetMesAno()
				if(nTipo == 2) //Dependente					
					if!(SRB->(DbSeek(xFilial("SRB")+ SRA->RA_MAT)))
						aAdd(aErros,GetErrMsg(cNumLinha,"Funcionário["+ SRA->RA_MAT +"] não tem dependentes. Registro ignorado."))
						lInvalido := .T.
					else
						xTemp := TamSx3("RB_COD")[1]
						xTemp := PadL(aPLAtivos[nI,8],xTemp,'0')	
						lFound := .F.
						while ( SRB->(!Eof() .And. RB_FILIAL+RB_MAT == xFilial("SRB")+ SRA->RA_MAT) )							
							if(SRB->RB_COD == xTemp)
								lFound := .T.
								Exit
							endIf							
							SRB->(dbSkip())
						End							
						if(!lFound)
							aAdd(aErros,GetErrMsg(cNumLinha, "Funcionário["+ SRA->RA_MAT +"] não tem dependente com código[" + xTemp + "]."))						
							lInvalido := .T.
						endIf					
					endIf
				endIf			
			endIf
			
			if(Empty(aPLAtivos[nI,7]) .Or. (!SRV->(DbSeek(xFilial('SRV')+aPLAtivos[nI,7]))))			
				if(Empty(aPLAtivos[nI,7]))
					aAdd(aErros,GetErrMsg(cNumLinha, 'Campo [Código Verba] é obrigatório.'))
				else
					aAdd(aErros,GetErrMsg(cNumLinha, 'Campo [Código Verba] inválido ->' + aPLAtivos[nI,7]))
				endIf					
				lInvalido := .T.			
			endIf			
			
			if(!ValidRCC(IIF(aPLAtivos[nI,4] == 'M','S016','S017'),cCodForn,1,3,.F.))
				aAdd(aErros,GetErrMsg(cNumLinha, 'Campo [Código Fornecedor] inválido ->' + cCodForn))
				lInvalido := .T.
			Else
				if(aPLAtivos[nI,4] == 'M')				
					if!(VldPlanoRcc("S009", cCodPlano, cCodForn) .Or. VldPlanoRcc("S028", cCodPlano, cCodForn))
						aAdd(aErros,GetErrMsg(cNumLinha, 'Campo [Código Plano] inválido ->' + cCodPlano))
						lInvalido := .T.
					endIf					
				else					
					if!(VldPlanoRcc("S014", cCodPlano, cCodForn) .Or. VldPlanoRcc("S030", cCodPlano, cCodForn))						
						aAdd(aErros,GetErrMsg(cNumLinha, 'Campo [Código Plano] inválido ->' + cCodPlano))
						lInvalido := .T.										
					endIf					
				endIf
			endIf					
			
			if(!lInvalido)
				/*Se registro for válido, já estará posicionado na RCC, SRA,SRV e SRB(se for necessário)*/
				lValorFixo := RCC->RCC_CODIGO $ 'S028|S030' 
				if(lValorFixo)
					cTpPlan := "3"
				else
					cTpPlan := "2"				
				endIf
							
				Do Case
					Case (nTipo == 1) // Títular [ RHK ]
						cChave := xFilial("RHK")
						cChave += SRA->RA_MAT						
						cChave += IIF(aPLAtivos[nI,4] == 'M','1','2')
						cChave += cCodForn
						lNew := !(RHK->(dbSeek(cChave)))
						
						if(!lNew)							
							lNew := .T.																					
							while ( RHK->(!Eof() .And. RHK_FILIAL + RHK_MAT + RHK_TPFORN + RHK_CODFOR == cChave) )
								if(RHK->(RHK_TPPLAN + RHK_PLANO == cTpPlan + cCodPlano))
									lNew := .F. /*Posiciona no último sem período final!*/
									Exit
								endIf								
								RHK->(dbSkip())
							End
						endIf						
						 
						RecLock("RHK",lNew)
						
						if(lNew)
							RHK->RHK_FILIAL 	:= xFilial("RHK")
							RHK->RHK_MAT		:= SRA->RA_MAT 
							RHK->RHK_TPFORN		:= IIF(aPLAtivos[nI,4] == 'M','1','2')
							RHK->RHK_CODFOR		:= cCodForn
						Else	
							If(RHK->RHK_PERFIM < cMesAno)
								RHK->RHK_PERFIM := ""
							endIf							
						endIf
						
						RHK->RHK_PLANO	:= cCodPlano
						RHK->RHK_PD		:= SRV->RV_COD
						RHK->RHK_PERINI	:= cMesAno
						RHK->RHK_TPPLAN	:= cTpPlan					 
						RHK->(MsUnlock())					
					Case (nTipo == 2) // Dependente [ RHL ]						
						cChave := xFilial("RHL")
						cChave += SRA->RA_MAT						
						cChave += IIF(aPLAtivos[nI,4] == 'M','1','2')
						cChave += cCodForn
						lNew := !(RHL->(dbSeek(cChave)))
						
						if(!lNew)
							lNew := .T.
							while ( RHL->(!Eof() .And. RHL_FILIAL+RHL_MAT+RHL_TPFORN+RHL_CODFOR == cChave))								
								if(RHL->RHL_CODIGO == SRB->RB_COD)
									lNew := .F.
									Exit
								endIf								
								RHL->(dbSkip())
							End
						endIf
						 
						RecLock("RHL",lNew)
						
						if(lNew)							
							RHL->RHL_FILIAL 	:= xFilial("RHL")
							RHL->RHL_MAT		:= SRA->RA_MAT 
							RHL->RHL_TPFORN		:= IIF(aPLAtivos[nI,4] == 'M','1','2')						
							RHL->RHL_CODFOR		:= cCodForn
						EndIf
						
						RHL->RHL_CODIGO	:= SRB->RB_COD
						RHL->RHL_PLANO	:= cCodPlano						
						RHL->RHL_PERINI	:= cMesAno
						RHL->RHL_TPPLAN := cTpPlan
						
						RHL->(MsUnlock())
						
						cChave := xFilial("RHK")
						cChave += SRA->RA_MAT						
						cChave += IIF(aPLAtivos[nI,4] == 'M','1','2')
						cChave += cCodForn						
						if((RHK->(dbSeek(cChave))))
							RecLock("RHK",.F.)
							RHK->RHK_PDDAGR := SRV->RV_COD
							RHK->(MsUnlock())		
						endIf
						
					Case (nTipo == 3) // Agregado [ RHM ]
					
						cChave := xFilial("RHM")
						cChave += SRA->RA_MAT						
						cChave += IIF(aPLAtivos[nI,4] == 'M','1','2')
						cChave += cCodForn
						lNew 	:= !(RHM->(dbSeek(cChave)))
												
						if(lNew)
							xTemp := StrZero(1,nTamCodAg)
						Else							
							lNew := .T.
							xTemp := 1
							while ( RHM->(!Eof() .And. RHM_FILIAL + RHM_MAT + RHM_TPFORN + RHM_CODFOR == cChave) )
								xTemp++
								
								if!(Empty(aPLAtivos[nI,11]))
									if(RHM->RHM_CPF == aPLAtivos[nI,11])
										lNew := .F.
										Exit	
									endIf	
								endIf
																
								RHM->(dbSkip())
							End
							xTemp := StrZero(xTemp,nTamCodAg)
						endIf					
						 
						RecLock("RHM",lNew)
						
						if(lNew)							
							RHM->RHM_FILIAL 	:= xFilial("RHM")
							RHM->RHM_MAT		:= SRA->RA_MAT 
							RHM->RHM_TPFORN		:= IIF(aPLAtivos[nI,4] == 'M','1','2')						
							RHM->RHM_CODFOR		:= cCodForn
							RHM->RHM_CODIGO		:= xTemp
						EndIf
						
						RHM->RHM_PLANO	:= cCodPlano						
						RHM->RHM_PERINI	:= cMesAno
						RHM->RHM_TPPLAN	:= cTpPlan
						RHM->RHM_NOME	:= aPLAtivos[nI,9]
						RHM->RHM_DTNASC	:= cToD(aPLAtivos[nI,10]) 
						RHM->RHM_CPF	:= aPLAtivos[nI,11]
						RHL->(MsUnlock())
						
						cChave := xFilial("RHK")
						cChave += SRA->RA_MAT
						cChave += IIF(aPLAtivos[nI,4] == 'M','1','2')
						cChave += cCodForn						
						if((RHK->(dbSeek(cChave))))
							if(RHK->RHK_PD != SRV->RV_COD)							
								RecLock("RHK",.F.)
								RHK->RHK_PDDAGR := SRV->RV_COD
								RHK->(MsUnlock())							
							endIf
						endIf						
				EndCase
			endIf
						
		endIf
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErros)
	next nI
	
	U_RIM01ERR(aErros)	
Return

/*/{Protheus.doc} GetNextSeq
 Pega o próximo sequencial da RCC
@author PHILIPE.POMPEU
@since 22/03/2016
@version P11
@param cTabela, caractere, RCC_CODIGO
@return cResult, resultado
/*/
Static Function GetNextSeq(cTabela,nAdd)
	Local aArea	:= GetArea()
	Local cMyAlias := GetNextAlias()
	Local cQuery	:= ''
	Local cResult := StrZero(1,nTamSeq)
	Default nAdd := 0
		
	cQuery := "SELECT MAX(RCC_SEQUEN) AS SEQUEN FROM "
	cQuery += RetSqlName( "RCC" )
	cQuery += " WHERE RCC_FILIAL='"+ xFilial("RCC")+"' AND RCC_CODIGO ='"+cTabela+"'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	
	cQuery	:= ChangeQuery(cQuery)				
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cMyAlias, .F., .T.)
	
	if((cMyAlias)->(! Eof()))	
		if((cMyAlias)->SEQUEN != Nil)
			cResult := StrZero(Val((cMyAlias)->SEQUEN)+ nAdd,nTamSeq)
		endIf					
	EndIf
		
	(cMyAlias)->(dbCloseArea())
	RestArea(aArea)
Return (cResult)

/*/{Protheus.doc} IfNilZero
 	Se variável == Nil, retorna 0, caso contrário retorna a própria variável
@author PHILIPE.POMPEU
@since 01/04/2016
@version P11
@param xVal, variável, valor
@return nResult, valor
/*/
Static Function IfNilZero(xVal)
	Local nResult := 0
	
	nResult := IIF(xVal == Nil,0,xVal)
Return nResult

/*/{Protheus.doc} GetMesAno
	Retorna o período no formato MMAAAA
@author PHILIPE.POMPEU
@since 01/04/2016
@version P11
@param cFolMes, caractere, expressão à ser invertida
@return cResult, periodo MMAAAA
/*/
Static Function GetMesAno(cFolMes)
	Local cResult := ""
	Local aPerAtual:={}
	Default cFolMes := ""
	
	fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, fGetRotOrdinar() )
	If Empty(aPerAtual)
		fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, fGetCalcRot('9') )
	EndIf					
	
	If !(Empty(aPerAtual))
		cFolMes := AnoMes(aPerAtual[1,6])
	else
		cFolMes := AnoMes(Date())
	EndIf
		
	if(cFolMes == Nil)
		cFolMes := AnoMes(Date())
	endIf
		
	cResult := Right(cFolMes,2)
	cResult += Left(cFolMes,4)	
Return cResult

/*/{Protheus.doc} LogToProth
	Carrega De/Para do Logix pro Protheus dos códigos do Plano de Saúde;
	Ex. Logix: 0004 e 0104
	Ex. Proth: 04 e 04?
	Por isso há necessidade do De/Para
@author PHILIPE.POMPEU
@since 07/04/2016
@version P11
@param aDePara, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function LogToProth(aDePara)
	Local	oDlgSel:= Nil
	Local	oGet	:= Nil
	Local	aHeader:= {}
	Local	aCols	:= {}	
	Local	cTitulo:= 'De/Para Código PLA'
	Local lResult	:= .T.
		
	DEFINE MsDialog oDlgSel TITLE cTitulo FROM 125,00 TO 400,450 PIXEL Color CLR_BLACK,CLR_WHITE	
	
	aAdd(aHeader,{"Fornecedor"	,"FORNEC"		,"",2,0,"",,"C",,})
	aAdd(aHeader,{"Logix"		,"LOGIX"		,"",4,0,"",,"C",,})
	aAdd(aHeader,{"Descrição"	,"DESCRICAO"	,"",20,0,"",,"C",,})
	aAdd(aHeader,{"Protheus"		,"PROTHEUS"	,"",2,0,"",,"C",,})
	
	/*Além dos registros encontrados no arquivo de importação atual, é possível que já tenham ocorrido
	outras importações, nesse caso é necessário carregar o De/Para já feito anteriormente no arquivo cArqDePara*/
	LoadArq(aDePara)
		
	aEval(aDePara,{|x|aAdd(aCols,{x[1],x[2],x[3],x[4],.F.})})
	
	oGet := MsNewGetDados():New(0,0,290,290,GD_INSERT+GD_DELETE+GD_UPDATE,/*cLinhaOk*/,/*cTudoOk*/,/*cIniCpos*/,{"PROTHEUS"},;
									0,Len(aDePara),/*cFieldOk*/,/*cSuperDel*/,/*cDelOk*/,oDlgSel,aHeader,aCols)
									
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGet:Enable()
	oGet:GoTop()
	
	ACTIVATE MsDialog oDlgSel CENTERED ON INIT EnchoiceBar(oDlgSel,{||SaveArq(oGet:aCols,aDePara),oDlgSel:End() },{||lResult	:= .F.,oDlgSel:End() },,{})		
Return lResult

/*/{Protheus.doc} LoadArq
	Carregar o arquivo cArqDePara com os registros já existentes
@author PHILIPE.POMPEU
@since 08/04/2016
@version P11
@param aDePara, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function LoadArq(aDePara)
	Local aArea	:= GetArea()
	Local aDPArq	:= {}
	Local nHandle	:= 0
	Local nI := 0
	Local nPos	:= 0
	Local aLinha	:= {}
	
	if(File(cArqDePara))	/*Se o arquivo existe, é necessário carregar o De/Para já feito anteriormente*/
		FT_FUSE(cArqDePara)	
		FT_FGOTOP()	
		While !(FT_FEOF())			
			aLinha:= Separa(FT_FREADLN(),"|") 						
			aAdd(aDPArq,aLinha)		
			FT_FSKIP()			
		EndDo
		FT_FUSE()
	endIf
	
	/*Verifica se algum registro importado já tem De/Para no arquivo, se tiver atualiza!*/
	for nI:= 1 to Len(aDePara)
		nPos := aScan(aDPArq,{|x|x[1]+x[2] == aDePara[nI,1]+aDePara[nI,2]})		
		if(nPos > 0)
			aDePara[nI,4] := aDPArq[nPos,4]
		endIf
	next
	
	/*Há a possibilidade de algum registro que está no arquivo de De/Para não esteja no aDePara,
	nessa caso adiciona no vetor!*/	
	for nI:= 1 to Len(aDPArq)
		nPos := aScan(aDePara,{|x|x[1]+x[2] == aDPArq[nI,1]+aDPArq[nI,2]})		
		if(nPos == 0)
			aAdd(aDePara,aDpArq[nI])			
		endIf
	next nI
	
	RestArea(aArea)
Return nil

/*/{Protheus.doc} SaveArq
	Salva o arquivo com o De/Para para situações em quê o arquivo de plano_saude.unl tenha somente
	registros do tipo 3
@author philipe.pompeu
@since 08/04/2016
@version P11
@param aCols, array, (Descrição do parâmetro)
@param aDePara, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function SaveArq(aCols,aDePara)
	Local aArea	:= GetArea()	
	Local nHandle	:= 0
	Local nI := 0
	Local cLin := ""
	Local nPos	:= 0
	
 	/*Deleta o arquivo, sempre gera um novo arquivo de De/Para!*/
 	if(File(cArqDePara))
		FErase(cArqDePara)	
	endIf
		
	nHandle := FCreate(cArqDePara)
	
	for nI:= 1 to Len(aCols)
		cLin:= IIF(nI == 1,"",CRLF)/*Dessa forma não fica uma linha em branco no fim do arquivo.*/
		cLin+= aCols[nI,1] + "|"
		cLin+= aCols[nI,2] + "|"
		cLin+= aCols[nI,3] + "|"
		cLin+= aCols[nI,4]		
		FWrite(nHandle, cLin)
		
		nPos := aScan(aDePara,{|x|x[1]+x[2] == aCols[nI,1] + aCols[nI,2]})
		if(nPos > 0)
			aDePara[nPos,4] := aCols[nI,4] /*Atualiza o De/Para!*/
		endIf
		
	next nI
	
	FClose(nHandle)
	
	RestArea(aArea)
Return nil

/*/{Protheus.doc} GetPLACod
	Procura no De/Para pela Chave passada,
	a chave é composta do código do fornecedor + codigo do Plano no Logix,
	o valo retornado será o código do Plano no Protheus
@author philipe.pompeu
@since 08/04/2016
@version P11
@param cChave, character, (Descrição do parâmetro)
@param aDePara, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function GetPLACod(cChave, aDePara)
	Local aArea	:= GetArea()
	Local cCodProt:= ""
	Local nPos		:= 0
	
	nPos := aScan(aDePara,{|x| x[1]+x[2] == cChave})
	
	if(nPos > 0)
		cCodProt := aDePara[nPos,4]
	else
		cCodProt := Right(cChave,2)/*No caso de não achar, improvável.*/
	endIf	
	
	RestArea(aArea)
Return (cCodProt)

/*/{Protheus.doc} CodFornPic
	Formata cValue para atender ao código do fornecedor;
	Como essa formatação era feita em diversos pontos do código-fonte, preferi isolar dentro de uma
	única função
@author philipe.pompeu
@since 08/04/2016
@version P11
@param cValue, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function CodFornPic(cValue)
	Local cResult := ""
	Local nTam	:= 3 //Pegar tam. do campo fornecedor dinamicamente.
	cResult := PadL(cValue,nTam,'0')
Return cResult

/*/{Protheus.doc} VldPlanoRcc
	Valida Plano
@author PHILIPE.POMPEU
@since 08/04/2016
@version P11
@param cTab, character, (Descrição do parâmetro)
@param cCodPlan, character, (Descrição do parâmetro)
@param cCodForn, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function VldPlanoRcc(cTab,cCodPlan,cCodForn,cFaixa)
	Local aArea	:= RCC->(GetArea())
	Local lResult	:= .F.
	Local cChave := ""
	Local cCont := ""
	Local lValorFixo	:= .T.	
	
	lValorFixo := cTab $ 'S028|S030' 
	
	cChave := xFilial("RCC") + cTab
	
	if(RCC->(dbSeek(cChave)))
		while ( RCC->(!Eof() .And. RCC_FILIAL+RCC_CODIGO == cChave) )
			cCont := AllTrim(RCC->RCC_CONTEU)
			
			if(Left(cCont,2) == cCodPlan .And. Right(cCont,3) == cCodForn)				
				
				if(lValorFixo)				
					lResult := .T. /*NESSE CASO NÃO HÁ NECESSIDADE DE PROCURAR MAIS NADA, APENAS O CÓDIGO DO PLANO.*/
					Exit
				else /*NESSA SITUAÇÃO ALÉM DO CODFORN E CODPLAN, É PRECISO VERIFICAR A FAIXA ETÁRIA*/
					if(SubStr(cCont,23,3) == cFaixa .Or. cFaixa == Nil)
						lResult := .T.
						Exit	
					endIf
				endIf
			endIf			
						
			RCC->(dbSkip())
		End
	endIf
		
	if(!lResult)
		RestArea(aArea)
	endIf
Return lResult

/*/{Protheus.doc} GetErrMsg
	Formata a mensagem de erro.
@author philipe.pompeu
@since 27/06/2016
@version P1217
@param cNumLinha, caractere, número da linha
@param cMsg, caractere, mensagem
@return cResult, mensagem de erro
/*/
Static Function GetErrMsg(cNumLinha,cMsg)
	Local cResult := ""
	cResult := "[Linha "+ cNumLinha +"]"
	cResult += cMsg	
Return cResult
