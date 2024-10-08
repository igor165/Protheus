#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSAXFUN       � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa com as funcoes do Modulo de Cargos e Salarios     ���
�������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.          ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�18/07/14�TPZVUR�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSMEDIA       � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Media dos Dados                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSMEDIA(X,Z)          		                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� X := Frequencia   	                                 	  ���
���          � Z := Frequencia * Remuneracao                    	      ���
�������������������������������������������������������������������������Ĵ��
���Formula   � Z / X		                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsMedia(X,Z)
Local nMedia:= 0
	If X > 0
		nMedia := Z/X
	EndIf	
Return nMedia

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSVARIAN      � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Variancia dos Dados                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSVARIAN(X,Z,W)       		                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� X := Frequencia   	                                 	  ���
���          � Z := Frequencia * Remuneracao                    	      ���
���          � W := (Frequencia **2)*Frequencia                    	      ���
�������������������������������������������������������������������������Ĵ��
���Formula   � (1/(X-1)) * [W - ((Z^2)/X)]                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsVarian(X,Z,W)
Local nVariancia := (	(1/(X-1)) * (W - ((Z^2)/X)))
Return nVariancia

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSDESVIO      � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Desvio Padrao                                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSDESVIO(nVariancia)  		                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nVariancia := Valor da variancia dos dados            	  ���
�������������������������������������������������������������������������Ĵ��
���Formula   � Raiz Quadrada da Variancia                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsDesvio(nVariancia)
Local nDesvio := SQRT(nVariancia)
Return nDesvio

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSCOEFIC      � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Coeficiente da Variacao                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSCOEFIC(nDesvio,nMedia)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nDesvio := Desvio Padrao								 	  ���
���          � nMedia  := Media         							 	  ���
�������������������������������������������������������������������������Ĵ��
���Formula   � Desvio Padrao / Media                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsCoefic(nDesvio,nMedia)
Local nCoeficiente	:= 0
	If nMedia != 0
		nCoeficiente := Round(nDesvio/nMedia,2)
	EndIf	
Return nCoeficiente

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSCLASSE      � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Numero de Classes da Pesquisa                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSCLASSE(nFreq)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nFreq   := Frequencia    							 	  ���
�������������������������������������������������������������������������Ĵ��
���Formula   � 1 + 3,3 Log Freq	(Log na Base 10)		                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsClasse(nFreq)
Local nClasse := Round(1 + 3.3 * (LOG(nFreq)/LOG(10)),0)
	 
If nClasse <=0
 	nClasse := 0
EndIf

Return nClasse

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSAMPLAM      � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Amplitude Amostral                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSAMPLAM(nRemMax,nRemMin)                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nRemMax := Maior remuneracao da amostra				 	  ���
���          � nRemMin := Menor remuneracao da amostra				 	  ���
�������������������������������������������������������������������������Ĵ��
���Formula   � Maior remuneracao da amostra - Menor remuneracao da amostra���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsAmplAm(nRemMax,nRemMin)
Local nAmostra := nRemMax - nRemMin
Return nAmostra

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSAMPLAM      � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Amplitude Amostral                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSAMPLAM(nRemMax,nRemMin)                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nRemMax := Maior remuneracao da amostra				 	  ���
���          � nRemMin := Menor remuneracao da amostra				 	  ���
�������������������������������������������������������������������������Ĵ��
���Formula   � Maior remuneracao da amostra - Menor remuneracao da amostra���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsAmplCl(nAmostra, nClasse)
Local nAmplit:=0

If nClasse != 0
	nAmplit := nAmostra / nClasse
EndIf	

Return nAmplit

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSVDECIL      � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valor do Decil                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSVDECIL(nQual, nFreq)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nQual := Qual Decil deve ser calculado  				 	  ���
���          � nFreq := Frequencia                     				 	  ���
�������������������������������������������������������������������������Ĵ��
���Formula   � nQual * (Freq / 10)										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsVDecil(nQual, nFreq)
Local nDecis := Round(nQual * (nFreq/10),2)
Return nDecis

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSVQUARTIL    � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valor do Quartil                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSVQUARTIL(nQual, nFreq)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nQual := Qual Quartil deve ser calculado  				  ���
���          � nFreq := Frequencia                     				 	  ���
�������������������������������������������������������������������������Ĵ��
���Formula   � nQual * (Freq / 4)										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsVQuartil(nQual, nFreq)
Local nQuartis := Round(nQual * (nFreq/4),2)
Return nQuartis

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSDECIL       � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo para Decil 	                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSVDECIL(nQual, nLi, nFreq, nFc, nH, nFi)                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nQual := Qual Decil deve ser calculado  				 	  ���
���          � nLi   := Limite inferior da classe que contem a medida     ���
���          � nFreq := Frequencia                                        ���
���          � nFc   := Freq Acumulada da classe anterior a da medida     ���
���          � nH    := Amplitude da classe                               ���
���          � nFi   := Freq Simples da classe que contem a medida        ���
�������������������������������������������������������������������������Ĵ��
���Formula   � nLi + (((((nQual*nFreq)/10)-nFc)*nH) / nFi)				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsDecil(nQual,nLi,nFreq,nFc,nH,nFi)
Local nDecil := nLi + (((((nQual*nFreq)/10)-nFc)*nH) / nFi)
Return nDecil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSQUARTIL     � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo para Quartil                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSVQUARTIL(nQual, nLi, nFreq, nFc, nH, nFi)                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nQual := Qual Decil deve ser calculado  				 	  ���
���          � nLi   := Limite inferior da classe que contem a medida     ���
���          � nFreq := Frequencia                                        ���
���          � nFc   := Freq Acumulada da classe anterior a da medida     ���
���          � nH    := Amplitude da classe                               ���
���          � nFi   := Freq Simples da classe que contem a medida        ���
�������������������������������������������������������������������������Ĵ��
���Formula   � nLi + (((((nQual*nFreq)/4)-nFc)*nH) / nFi)				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsQuartil(nQual,nLi,nFreq,nFc,nH,nFi)
Local nQuartil := nLi + (((((nQual*nFreq)/4)-nFc)*nH) / nFi)
Return nQuartil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSVERVAL      � Autor � Cristina Ogura   � Data � 29/03/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica os valores no array das variaveis                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSVERVAL(cVar,cConteudo,cSubSoma)                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cVar  	:= Variavel a ser pesquisada no Array			  ���
���          � cConteudo:= Conteudo, qdo atualizacao				      ���
���          � cSubSoma := Tipo											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CsVerVal(cVar,cConteudo,cSubSoma)
Local cRet	:= ""
Local nPosV := 0

cSubSoma := If (cSubSoma == Nil, "S", cSubSoma)

If cConteudo != Nil
	If (nPosV := Ascan(aResult,{ |x| UPPER(x[1]) == UPPER(cVar) })) == 0
		Aadd(aResult,{cVar,cConteudo})
	Elseif cSubSoma = "S"
		aResult[nPosV,2] := cConteudo
	Else
		aResult[nPosV,2] += cConteudo			
	Endif
Else
	If (nPosV := Ascan(aResult,{ |x| UPPER(x[1]) == UPPER(cVar) } )) > 0
		cRet := aResult[nPosv,2]			
	Else
		If Upper(Subs(cVar,1,1)) = "N"
			cRet := 0
		ElseIf 	Upper(Subs(cVar,1,1)) = "C"
			cRet := ""
		ElseIf 	Upper(Subs(cVar,1,1)) = "L"
			cRet := .F.
		ElseIf 	Upper(Subs(cVar,1,1)) = "D"
			cRet := Ctod("")
		Else
			cRet := Nil
		Endif		
	Endif		
	Return(cRet)
Endif
Return            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fCarFator �Autor  �Microsiga           � Data �  06/04/00   ���
�������������������������������������������������������������������������͹��
���Desc.     �Montar Array com os Fatores,graus e pontos do cargo         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametro � cFil   = Filial do Cargo ou funcao                         ���
���          � cFuncao= Funcao do funcinario (Se nao tiver o Cargo)       ���
���          � cCargo = Cargo da Funcao(Se nao tiver o Cargo) 		      ���
���          � cMat   = Matricula do Funcionario              		      ���
���          � cGrupo = Variavel para retorno do Grupo do Cargo		      ���
���          � cDepto = variavel para retorno do Depto do Cargo		      ���
���          � aFator = Array com os fatores                              ���
���          � cCC 	  = Centro de Custo do Cargo ou Funcionario.          ���
���Observacao� Sempre deve ser passado os parametros ou Funcao ou Cargo   ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function FMontaFator( cAuxFil, cFuncao, cCargo, cMat, cGrupo, cDepto, aFator, cCC)
Local aSaveArea	:= GetArea()
Local cDescFat	:= ""
Local cFuncGrau	:= ""
Local cFuncDGrau:= ""
Local nCargoPt	:= 0
Local nFuncPt	:= 0            
Local cCargoGrau:= ""
Local cFilSQ3SRJ		:= ""
Local cFilCargo	:= ""

DEFAULT cCC		:= ""

inclui := .F.
aFator := {}
     
//-- Se Passado o Codigo da Funcao Buscar o Cargo na Funcao
If ( cCargo == Nil .Or. Empty(cCargo) ) .And.	( cFuncao != Nil .And. !Empty(cFuncao) )
	dbSelectArea("SRJ")
	cFilSQ3SRJ := IIf((cAuxFil == Nil .Or. Empty(cFilial)), cFilial, cAuxFil)
	
	If dbSeek(cFilSQ3SRJ+cFuncao)
		cCargo := SRJ->RJ_CARGO
	EndIf
EndIf	

//--Verifica se Cargo foi passado ou Carregado da Funcao, carrega os fatores	
If cCargo != Nil .And. !Empty(cCargo)                

	//--Buscar Grupo e Departamento do Cargo
	dbSelectArea("SQ3")
	dbSetOrder(1)
	cFilSQ3SRJ := xFilial("SQ3",SRA->RA_FILIAL)

	If dbSeek(cFilSQ3SRJ+cCargo+cCC) .Or. dbSeek(cFilSQ3SRJ+cCargo)
		cGrupo 	:= SQ3->Q3_GRUPO
		cDepto 	:= SQ3->Q3_DEPTO		
	EndIf
             
	//--Buscar Fatores do Cargo
	dbSelectArea("SQ4")
	dbSetOrder(2)  	
	cFilCargo := xFilial("SQ4",SRA->RA_FILIAL)
	
	If dbSeek(cFilSQ3SRJ+cCargo+SQ3->Q3_CC)
		While ! Eof() .And. SQ4->Q4_FILIAL+SQ4->Q4_CARGO+SQ4->Q4_CC == cFilCargo+cCargo+SQ3->Q3_CC

			//--Buscar Descricao do Fator		
			cDescFat := FDesc("SQV",SQ4->Q4_FATOR,"SQV->QV_DESCFAT",30)

			//--Buscar Descricao do Grau e os Pontos do Grau do Cargo
			cCargoGrau:= FDesc("SQV",SQ4->Q4_FATOR+SQ4->Q4_GRAU,"SQV->QV_DESCGRA",30)

			dbSelectArea("SQ2")
			dbSetOrder(1) 
			cFilSQ3SRJ := xFilial("SQ2",SRA->RA_FILIAL)
			
			If dbSeek(cFilSQ3SRJ+cGrupo+SQ4->Q4_FATOR+SQ4->Q4_GRAU)		
				nCargoPt  := SQ2->Q2_PONTOSI
			EndIf
    	
			//--Inicializa as variaveis do funcionario		
			cFuncGrau 	:= Space(02)
			cFuncDGrau	:= Space(30)
			nFuncPt	 	:= 0

			If cMat != Nil .And. !Empty(cMat)			
				dbSelectArea("SQ8")
				dbSetOrder(1)                                  
				cFilSQ3SRJ := xFilial("SQ8",SRA->RA_FILIAL)
				
				If dbSeek(cFilSQ3SRJ+cMat+SQ4->Q4_FATOR)
					cFuncGrau := SQ8->Q8_GRAU
					cFuncDGrau:= FDesc("SQV",SQ8->Q8_FATOR+SQ8->Q8_GRAU,"SQV->QV_DESCGRA",30)					

					dbSelectArea("SQ2")
					dbSetOrder(1)	 
					cFilSQ3SRJ :=  xFilial("SQ2",SRA->RA_FILIAL)
					
					If dbSeek(cFilSQ3SRJ+cGrupo+SQ8->Q8_FATOR+SQ8->Q8_GRAU)		
						nFuncPt	:= SQ8->Q8_PONTOS
					EndIf
			
				EndIf	
			EndIf	
	
			Aadd(aFator,{SQ4->Q4_FATOR,;		// 1 Fator
						  cDescFat,;			// 2 Descricao do Fator
						  SQ4->Q4_GRAU,;		// 3 Grau do Cargo
						  cCargoGrau,;			// 4 Descricao do Grau do Cargo
						  nCargoPt,;			// 5 Pontos do Cargo
						  cFuncGrau,;			// 6 Grau do Funcionario
						  cFuncDGrau,;			// 7 Descricao do Grau do Funcionario
						  nFuncPt,;				// 8 Pontos do Funcionario
						  cGrupo})            	// 9 Grupo
		
			dbSelectArea("SQ4")
			dbSkip()
		EndDo
	EndIf	
EndIf

RestArea(aSaveArea)

Return .T.

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � CSALoadExec	�Autor�  Igor Franzoi     � Data �29/06/2009�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao executada a cada rotina (menu) chamado pelo CSA		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �CSALoadExec													�
�����������������������������������������������������������������������Ĵ
� Uso      �Generico													�
�����������������������������������������������������������������������Ĵ
� Retorno  �															�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Function CSALoadExec()

If FindFunction("SPFLoadExec()")
	SPFLoadExec()
EndIf

Return (Nil)