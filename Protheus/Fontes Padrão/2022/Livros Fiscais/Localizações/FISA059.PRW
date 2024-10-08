#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA059.CH"



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FISA059   � Autor �  Marco Aurelio - Mano � Data �14/02/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Importacao de arquivo TXT retornado pela AFIP referente a   ���
���          �Agentes de Retencao IVA Percepcao                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �FISA059()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL              ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���M.Camargo   �02.01.17�      �SERINN001-616 Remover uso arq temporales  ���
���            �        �      �uso de FWTemporaryTable                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA059()

Local aArqTmp	:= {}	// Arquivo temporario para importacao
Local cAliasTMP	:= ""	// Alias atribuido ao arquivo temporario
Local nIteAge	:= 0	// Opcao de agente selecionado para importacao
Local lRet	 	:= .T.	// Determina a continuidade de processamento da rotina

Private oTmpTable := Nil
//����������������������������������������������������������������������������������Ŀ
//�Chama tela de Wizard para informacao dos parametros para importacao do arquivo TXT�
//������������������������������������������������������������������������������������
If TelaWiz()	            

	//���������������������������������������������������Ŀ
	//�Gera arquivo temporarioa a partir do TXT importado �
	//�����������������������������������������������������
	Processa({|| lRet := GeraTemp(@aArqTmp,@nIteAge)})

	cAliasTMP := aArqTmp[02]   
	
	If lRet

		If Str(nIteAge,1) $ "1|3"	// Cliente ou Ambos

			//������������������������������������������������������������Ŀ
			//�Processo de valiadacao para Clientes - Agente Percepcao IVA �
			//��������������������������������������������������������������
			Processa({|| ProcCliFor("SA1")})

		EndIf
		
		If Str(nIteAge,1) $ "2|3"	// Fornecedor ou Ambos

			//����������������������������������������������������������������Ŀ
			//�Processo de valiadacao para Fornecedores - Agente Percepcao IVA �
			//������������������������������������������������������������������
			Processa({|| ProcCliFor("SA2")})

		EndIf

	EndIf
		
	//����������������������������������Ŀ
	//�Exclui o arquivo temporario criado�
	//������������������������������������
	dbSelectArea(cAliasTMP)
	(cAliasTMP)->(dbCloseArea())
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
	EndIF	

Endif

Return




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TelaWiz   � Autor �Marco Aurelio          � Data � 14/02/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Tela Wizard inicial para selecao do arquivo a ser importado ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TelaWiz()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico - FISA059                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TelaWiz()

//������������������������Ŀ
//�Declaracao das variaveis�
//��������������������������
Local cMask		:= Replicate("X",245)	// Mascara para edicao do arquivo a ser informado para importacao
Local aTxtPre 	:= {}					// Array com textos a serem apresentados na tela de Wizard
Local aPaineis 	:= {} 					// Array de paineis a serem criados na tela de Wizard
Local aParImp 	:= {} 					// Array com as opcoes para selecionar o tipo de agente a ser importado(Cliente,Fornecedor, Ambos)
Local nPos		:= 0        			// Referencia de posicionamento dos paineis da tela de Wizard
Local lRet		:= .T.    				// Conteudo de retorno da funcao

//�����������������������������������������Ŀ
//�Monta wizard com as perguntas necessarias�
//�������������������������������������������
aAdd(aTxtPre,STR0002) 			//##"Importa��o do arquivo Agentes de Reten��o IVA"
aAdd(aTxtPre,STR0001) 			//##"Aten��o"
aAdd(aTxtPre,STR0003) 			//##"Preencha corretamente as informa��es solicitadas."
aAdd(aTxtPre,Alltrim(STR0004))	//## "Esta rotina ir� importar o arquivo padr�o de Agentes de Reten��o disponibilizados pela AFIP."

//����������������������������������������������Ŀ
//�Painel 1 - Informacoes para importacao do TXT �
//������������������������������������������������
aAdd(aPaineis,{})   

nPos :=	Len(aPaineis)     

aAdd(aPaineis[nPos],STR0005) //##"Assistente de parametriza��o" 
aAdd(aPaineis[nPos],STR0006) //##"Informa��es sobre o arquivo de retorno: "
aAdd(aPaineis[nPos],{})

aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{1,STR0007,,,,,,}) //##"Arquivo a ser importado: "
aAdd(aPaineis[nPos][3],{2,"",cMask,1,,,,150,,.T.})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

aAdd(aParImp,STR0018)	//##"Clientes"
aAdd(aParImp,STR0019)	//##"Fornecedores"
aAdd(aParImp,STR0020)	//##"Ambos"

aAdd (aPaineis[nPos][3], {0,"",,,,,,})					
aAdd (aPaineis[nPos][3], {1,STR0021,,,,,,})	//##"Tipo de agente a ser importado:"
aAdd (aPaineis[nPos][3], {3,,,,,aParImp,,})					

lRet :=	xMagWizard(aTxtPre,aPaineis,"TelaWiz")
	
Return(lRet)   




/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun�ao    �GeraTemp     � Autor � Marco Aurelio - Mano    � Data �14/02/13  ���
������������������������������������������������������������������������������Ĵ��
���Descri�ao �Gera arquivo temporarioa a partir do TXT importado               ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   �GeraTemp(ExpC1,ExpN1)                                            ���
������������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Nome do arquivo temporario                               ���
���          �ExpN1 = Opcao de agente selecionado para importacao              ���
������������������������������������������������������������������������������Ĵ��
���Uso       �Especifico FISA059                                               ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/          
Static Function GeraTemp(aArqTmp,nIteAge)
Local aWizard    := {}									// Array com informacoes da tela de Wizard
Local aInforma   := {} 									// Array auxiliar com as informacoes da linha lida no arquivo TXT
Local aArqPro    := {}         							// Array auxiliar para criacao do arquivo temporario
Local aIteAge    := {}         							// Array de itens selecionaveis na tela de Wizard
Local lRet       := xMagLeWiz("TelaWiz",@aWizard,.T.) 	// Determina a continuidade do processamento como base nas informacoes da tela de Wizard
Local cArqProc   := Alltrim(aWizard[01][01])			// Arquivo a ser importado selecionado na tela de Wizard
Local cTitulo    := STR0008								// "Problemas na Importa��o de Arquivo"
Local cErro	     := ""   								// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
Local cSolucao   := ""           						// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
Local cLinha     := ""									// Informacao lida para cada linha do arquivo TXT
Local lArqValido := .T.                               	// Determina se o arquivo TXT esta ok para importacao
Local nInd       := 0                   				// Indexadora de laco For/Next
Local nHandle    := 0            						// Numero de referencia atribuido na abertura do arquivo TXT
Local nTam       := 0 									// Tamanho de buffer do arquivo TXT           						

aIteAge := {STR0018,STR0019,STR0020}	//##"Clientes"##"Fornecedores"##"Ambos"
nIteAge := aScan(aIteAge,aWizard[01][02])

//���������������������������������������������
//�Cria o arquivo temporario para a importacao�
//���������������������������������������������
AADD(aArqPRO,{"CGC"	  ,"C",TamSX3("A1_CGC")[1],0})
AADD(aArqPRO,{"RAZAO" ,"C",50,0})
AADD(aArqPRO,{"DATAI" ,"D",08,0})
AADD(aArqPRO,{"DATAF" ,"D",08,0})
AADD(aArqPRO,{"INCISO","C",01,0})

aArqTmp := {"","TMP"}
oTmpTable := FWTemporaryTable():New("TMP") // mc
oTmpTable:SetFields(aArqPRO) //MC	
oTmpTable:AddIndex("IN1", {"CGC","DATAI"}) //MC
oTmpTable:Create() //MC

If File(cArqProc) .And. lRet

	nHandle	:= FOpen(cArqProc)
   
	If nHandle > 0 
		nTam := FSeek(nHandle,0,2)  
	
		FSeek(nHandle,0,0)
		FT_FUse(cArqProc)
		FT_FGotop()
		
	Else
		lArqValido := .F.	
		cErro	   := STR0009 + cArqProc	//"N�o foi poss�vel efetuar a abertura do arquivo: "
		cSolucao   := STR0010 				//"Verifique se foi informado o arquivo correto para importa��o"
	EndIf

	If lArqValido 

		ProcRegua(nTam)

		//��������������������������������������������������
		//�Gera arquivo temporario a partir do arquivo TXT �
		//��������������������������������������������������
		While (!FT_FEof()) 		

			IncProc()

		    aInforma := {}	            
   			cLinha   := FT_FREADLN()
   			
        	RecLock("TMP",.T.)

			For nInd := 1 to 5
				nPos := at(";",cLinha)
				AADD (aInforma,Alltrim(SubStr(cLinha,1,(nPos-1))))
				cLinha := SubStr(cLinha,nPos+1,Len(cLinha))
			Next

  	  		TMP->CGC		:= aInforma[1]
			TMP->RAZAO  	:= aInforma[2]
			TMP->DATAI		:= cTOd(aInforma[3])
			TMP->DATAF		:= cTod(aInforma[4])
			TMP->INCISO		:= aInforma[5]  
			
			FT_FSkip()

		Enddo 

	Endif	

	FT_FUse()
	FClose(nHandle)

	If Empty(cErro) .and. TMP->(LastRec())==0     
		cErro		:= STR0011	//"A importa��o n�o foi realizada por n�o existirem informa��es no arquivo texto informado."
		cSolucao	:= STR0012	//"Verifique se foi informado o arquivo correto para importa��o"
	Endif
	
Else

	cErro	 := STR0013+CHR(13)+cArqProc	//"O arquivo informado para importa��o n�o foi encontrado: "
	cSolucao := STR0014 		   			//"Informe o diret�rio e o nome do arquivo corretamente e processe a rotina novamente."

EndIf
	 
If !Empty(cErro)

	xMagHelpFis(cTitulo,cErro,cSolucao)

	lRet := .F.
	
Endif

Return(lRet)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ProcCliFor� Autor �Marco Aurelio          � Data � 14/02/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Processa os arquivos de clientes/fornecedores para          ���
���          �aplicacao das regras de validacao para agente retenedor     ���
���          �em relacao ao arquivo enviado pela AFIP                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ProcCliFor(ExpC1)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Alias da tabela a ser processada(SA1/SA2)           ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Especifico - FISA059                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ProcCliFor(cAlias)
Local aArea     := GetArea()			// Salva area atual para posterior restauracao
Local lExistTXT := .F.					// Determina se o Clinte ou Fornecedor consta no arquivo importado da AFIP
Local lCli      := (cAlias=="SA1")		// Determina se a rotina foi chamada para processar o arquivo de clientes ou fornecedores
Local cPrefTab  := Substr(cAlias,2,2)	// Prefixo para acesso dos campos
Local dDatIni   := ""					// Data inicial do periodo enviada no TXT
Local dDatFim   := ""					// Data final do periodo enviada no TXT

dbSelectArea(cAlias)
dbGoTop()
    
ProcRegua(RecCount())

//���������������������������������������������������������������������������������������
//�Loop para varrer arquivo de Cliente ou Fornecedor e validar se existe no arquivo TXT �
//���������������������������������������������������������������������������������������
While !Eof()

	IncProc(Iif(lCli,STR0015,STR0016))	//##"(15)Processando Clientes/(16)Processando Fornecedores"
        
	//�������������������������������������������������������������������������������
	//�Trava registro de fornecedor para atualizacoes referentes ao Retencion SUSS  �
	//�������������������������������������������������������������������������������
	If !lCli
		RecLock("SA2",.F.)
	EndIf
	
	//�����������������������������������������������������������������������
	//�Verifica se o cliente/fornecedor consta no arquivo temporario - AFIP �
	//�����������������������������������������������������������������������
	If TMP->(dbSeek((cAlias)->&(cPrefTab+"_CGC")))

		While TMP->CGC == (cAlias)->&(cPrefTab+"_CGC")

			dDatIni := TMP->DATAI
			dDatFim := TMP->DATAF
			
			PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IVP",lCli,.T.)

			TMP->(dbSkip())
			
		EndDo	

		//���������������������������������������������������������������������������
		//�Atualiza informacoes eferente a Retencion SUSS na tabela de fornecedores �
		//���������������������������������������������������������������������������
		If !lCli 
		
			If (Empty(dDatFim) .or. (dDatFim > dDataBase)) 
	
				SA2->A2_AGENRET := "S"		

				If SA2->A2_CONCSUS == "2"		
					SA2->A2_PORSUS  := 0		
					SA2->A2_DTICALS := dDatIni		
					SA2->A2_DTFCALS := dDatFim		
				EndIf
							
			ElseIf (!Empty(dDatFim) .and. (dDatFim <= dDataBase) .and. Empty(SA2->A2_DTFCALS) )
				SA2->A2_DTFCALS := dDatFim		
			EndIf
			
		EndIf				
	Else 
		
		PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IVP",lCli,.F.)

		//����������������������������������������������������������������������������
		//�Atualiza informacoes referente a Retencion SUSS na tabela de fornecedores �
		//����������������������������������������������������������������������������
		If !lCli
			SA2->A2_AGENRET := "N"		
			SA2->A2_DTICALS := CTOD("")
			SA2->A2_DTfCALS := CTOD("")
		EndIf	
		
	EndIf	
	
	If !lCli
		MsUnLock()
	EndIf

	dbSkip()
	
EndDo

RestArea(aArea)

Return
                                                   


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun�ao    �PesqSFH     � Autor � Marco Aurelio - Mano    � Data �25/02/13  ���
�����������������������������������������������������������������������������Ĵ��
���Descri�ao �Pesquisa existencia de registros na tabela SFH(Ingressos Brutos)���
���          �referente ao cliente ou forcedor passado como parametro         ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   �PesqSFH(ExpN1,ExpC1,ExpL1,ExpL2)                                ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1 = Ordem do indice da tabela SFH                           ���
���          �ExpC1 = Chave de pesquisa para a tabela SFH                     ���
���          �ExpL1 = Determina se a pesquisa trata cliente ou fornecedor     ���
���          �ExpL2 = Determina se Cliente/Fornecedor consta no TXT(AFIP)     ���
�����������������������������������������������������������������������������Ĵ��
���Uso       �Especifico - FISA059                                            ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/          
Static Function PesqSFH(nOrd,cKeySFH,lCli,lExistTXT)
Local aArea    := GetArea()		// Salva area atual para posterior restauracao
Local lRet     := .T.			// Conteudo e retorno
Local lIncSFH  := lExistTXT		// Determina se deve ser incluido um novo registro na tabela SFH
Local lAtuSFH  := .F.			// Determina se deve atualizar a tabela SFH
Local nRegSFH  := 0				// Numero do registros correspondente ao ultimo periodo de vigencia na SFH
Local cDatIni  := TMP->DATAI    // Data de inicio da vigencia enviada no TXT
Local cDatFim  := TMP->DATAF    // Data final da vigencia enviada no TXT
Local dDatAux  := Ctod("")    	// Data auxiliar para validacao de periodo de vigencia na tabela SFH

dbSelectArea("SFH")
DbSetOrder(nOrd) 

//���������������������������������������������������������������������
//�Verifica se existe registro do Cliente ou Fornecedor na tabela SFH �
//���������������������������������������������������������������������
If dbSeek(xFilial("SFH")+cKeySFH)

	lIncSFH := .F.
	lAtuSFH := .T.	 
	
	//�������������������������������������������������������������������������������������������������
	//�Loop para pegar o registro referente ao periodo vigente do cliente ou fornecedor na tabela SFH �
	//�������������������������������������������������������������������������������������������������
	While xFilial("SFH")+cKeySFH==SFH->FH_FILIAL+Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE)+SFH->FH_LOJA +SFH->FH_IMPOSTO
		
		If  Empty(SFH->FH_FIMVIGE) 
		                
			nRegSFH := Recno()
			
			Exit
		Else

			If SFH->FH_FIMVIGE > dDatAux
				nRegSFH := Recno() 
				dDatAux := SFH->FH_FIMVIGE
			EndIf
				
		EndIf
		
		DbSkip()
		
	EndDo
	
	dbGoto(nRegSFH)   
	
	If lExistTXT 
	   
		//���������������������������������������������������������������������������������������������������������������
		//�Determina a data final do periodo conforme regras em que cliente/fornecedor deve ser considerado como agente �
		//���������������������������������������������������������������������������������������������������������������
		If (Empty(TMP->DATAF) .or. (TMP->DATAF >= dDataBase))    
		
			If (Empty(SFH->FH_FIMVIGE) .or. (SFH->FH_FIMVIGE >= dDataBase)) 

				If SFH->FH_AGENTE=="N"
					lIncSFH := .T.   
					cDatFim := dDataBase
					cDatIni := (dDataBase+1)                                 	
				EndIf

			Else

				//�������������������������������������������������������������������������������������������
				//�Determina a inclusao de um novo periodo para considerar o cliente/fornecedor como agente �
				//�������������������������������������������������������������������������������������������
				lAtuSFH := .F.
				lIncSFH := .T.   
				cDatIni := (dDataBase+1)

			EndIf
		
		Else

			If(Empty(SFH->FH_FIMVIGE) .or. (SFH->FH_FIMVIGE > dDataBase))
				cDatFim := dDataBase
			Else
				lAtuSFH := .F.
			EndIf	
		
		EndIf

	Else	

		//�����������������������������������������������������������������������������������������������������������������
		//�Quando nao existir o cliente/fornecedor no TXT(AFIP) o periodo de rentecao na tabela SFH deverah ser encerrado �
		//�����������������������������������������������������������������������������������������������������������������
		cDatFim := dDataBase
		lAtuSFH := !(SFH->FH_AGENTE=="N" .or. (!Empty(SFH->FH_FIMVIGE) .and. SFH->FH_FIMVIGE < dDataBase))
	EndIf
		
Else

	//������������������������������������������������������������������������������������������������������������������������������������
	//�Quando houver a necessidade de se inluir um periodo na tabela SFH que tenha sido enviado no TXT onde a data final for maior que a �
	//�data base do sistema, considerar que a data inicial deste periodo(FH_INIVIGE) devera ser atualizada com "dDataBase+1" afim de se  �
	//�preservar o historico dos documentos emitidos no periodo anterior.                                                                �
	//������������������������������������������������������������������������������������������������������������������������������������
	If lExistTXT .and. (Empty(cDatFim) .or. (cDatFim > dDataBase))
		cDatIni := dDataBase+1
	EndIf	
				
EndIf
	
If lAtuSFH 

	Reclock("SFH",.F.)
   	SFH->FH_FIMVIGE := cDatFim

	MsUnLock()
	
EndIf

If lIncSFH

	Reclock("SFH",.T.)

	SFH->FH_FILIAL  := xFilial("SFH")
	SFH->FH_TIPO    := "I"
	SFH->FH_PERCIBI := "N"
	SFH->FH_ISENTO  := "N"
	SFH->FH_APERIB  := "N"
	SFH->FH_IMPOSTO := "IVP"
	SFH->FH_INIVIGE := cDatIni
	SFH->FH_FIMVIGE := TMP->DATAF
	SFH->FH_AGENTE  := "S"

	If lCli
		SFH->FH_CLIENTE := SA1->A1_COD
		SFH->FH_LOJA    := SA1->A1_LOJA
		SFH->FH_ZONFIS  := SA1->A1_EST 
		SFH->FH_NOME    := SA1->A1_NOME
	Else	
		SFH->FH_LOJA    := SA2->A2_LOJA
		SFH->FH_FORNECE := SA2->A2_COD
		SFH->FH_ZONFIS  := SA2->A2_EST
		SFH->FH_NOME    := SA2->A2_NOME
	EndIf

	MsUnLock()
	
EndIf

RestArea(aArea)

Return(lRet)
