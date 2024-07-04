#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA059.CH"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FISA059   ³ Autor ³  Marco Aurelio - Mano ³ Data ³14/02/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Importacao de arquivo TXT retornado pela AFIP referente a   ³±±
±±³          ³Agentes de Retencao IVA Percepcao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³FISA059()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo   ³02.01.17³      ³SERINN001-616 Remover uso arq temporales  ³±±
±±³            ³        ³      ³uso de FWTemporaryTable                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA059()

Local aArqTmp	:= {}	// Arquivo temporario para importacao
Local cAliasTMP	:= ""	// Alias atribuido ao arquivo temporario
Local nIteAge	:= 0	// Opcao de agente selecionado para importacao
Local lRet	 	:= .T.	// Determina a continuidade de processamento da rotina

Private oTmpTable := Nil
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama tela de Wizard para informacao dos parametros para importacao do arquivo TXT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TelaWiz()	            

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera arquivo temporarioa a partir do TXT importado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| lRet := GeraTemp(@aArqTmp,@nIteAge)})

	cAliasTMP := aArqTmp[02]   
	
	If lRet

		If Str(nIteAge,1) $ "1|3"	// Cliente ou Ambos

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processo de valiadacao para Clientes - Agente Percepcao IVA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Processa({|| ProcCliFor("SA1")})

		EndIf
		
		If Str(nIteAge,1) $ "2|3"	// Fornecedor ou Ambos

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processo de valiadacao para Fornecedores - Agente Percepcao IVA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Processa({|| ProcCliFor("SA2")})

		EndIf

	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui o arquivo temporario criado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasTMP)
	(cAliasTMP)->(dbCloseArea())
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
	EndIF	

Endif

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TelaWiz   ³ Autor ³Marco Aurelio          ³ Data ³ 14/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tela Wizard inicial para selecao do arquivo a ser importado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TelaWiz()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico - FISA059                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TelaWiz()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao das variaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cMask		:= Replicate("X",245)	// Mascara para edicao do arquivo a ser informado para importacao
Local aTxtPre 	:= {}					// Array com textos a serem apresentados na tela de Wizard
Local aPaineis 	:= {} 					// Array de paineis a serem criados na tela de Wizard
Local aParImp 	:= {} 					// Array com as opcoes para selecionar o tipo de agente a ser importado(Cliente,Fornecedor, Ambos)
Local nPos		:= 0        			// Referencia de posicionamento dos paineis da tela de Wizard
Local lRet		:= .T.    				// Conteudo de retorno da funcao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta wizard com as perguntas necessarias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aTxtPre,STR0002) 			//##"Importação do arquivo Agentes de Retenção IVA"
aAdd(aTxtPre,STR0001) 			//##"Atenção"
aAdd(aTxtPre,STR0003) 			//##"Preencha corretamente as informações solicitadas."
aAdd(aTxtPre,Alltrim(STR0004))	//## "Esta rotina irá importar o arquivo padrão de Agentes de Retenção disponibilizados pela AFIP."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Painel 1 - Informacoes para importacao do TXT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aPaineis,{})   

nPos :=	Len(aPaineis)     

aAdd(aPaineis[nPos],STR0005) //##"Assistente de parametrização" 
aAdd(aPaineis[nPos],STR0006) //##"Informações sobre o arquivo de retorno: "
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GeraTemp     ³ Autor ³ Marco Aurelio - Mano    ³ Data ³14/02/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Gera arquivo temporarioa a partir do TXT importado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GeraTemp(ExpC1,ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Nome do arquivo temporario                               ³±±
±±³          ³ExpN1 = Opcao de agente selecionado para importacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico FISA059                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function GeraTemp(aArqTmp,nIteAge)
Local aWizard    := {}									// Array com informacoes da tela de Wizard
Local aInforma   := {} 									// Array auxiliar com as informacoes da linha lida no arquivo TXT
Local aArqPro    := {}         							// Array auxiliar para criacao do arquivo temporario
Local aIteAge    := {}         							// Array de itens selecionaveis na tela de Wizard
Local lRet       := xMagLeWiz("TelaWiz",@aWizard,.T.) 	// Determina a continuidade do processamento como base nas informacoes da tela de Wizard
Local cArqProc   := Alltrim(aWizard[01][01])			// Arquivo a ser importado selecionado na tela de Wizard
Local cTitulo    := STR0008								// "Problemas na Importação de Arquivo"
Local cErro	     := ""   								// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
Local cSolucao   := ""           						// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
Local cLinha     := ""									// Informacao lida para cada linha do arquivo TXT
Local lArqValido := .T.                               	// Determina se o arquivo TXT esta ok para importacao
Local nInd       := 0                   				// Indexadora de laco For/Next
Local nHandle    := 0            						// Numero de referencia atribuido na abertura do arquivo TXT
Local nTam       := 0 									// Tamanho de buffer do arquivo TXT           						

aIteAge := {STR0018,STR0019,STR0020}	//##"Clientes"##"Fornecedores"##"Ambos"
nIteAge := aScan(aIteAge,aWizard[01][02])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o arquivo temporario para a importacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		cErro	   := STR0009 + cArqProc	//"Não foi possível efetuar a abertura do arquivo: "
		cSolucao   := STR0010 				//"Verifique se foi informado o arquivo correto para importação"
	EndIf

	If lArqValido 

		ProcRegua(nTam)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera arquivo temporario a partir do arquivo TXT ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		cErro		:= STR0011	//"A importação não foi realizada por não existirem informações no arquivo texto informado."
		cSolucao	:= STR0012	//"Verifique se foi informado o arquivo correto para importação"
	Endif
	
Else

	cErro	 := STR0013+CHR(13)+cArqProc	//"O arquivo informado para importação não foi encontrado: "
	cSolucao := STR0014 		   			//"Informe o diretório e o nome do arquivo corretamente e processe a rotina novamente."

EndIf
	 
If !Empty(cErro)

	xMagHelpFis(cTitulo,cErro,cSolucao)

	lRet := .F.
	
Endif

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcCliFor³ Autor ³Marco Aurelio          ³ Data ³ 14/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa os arquivos de clientes/fornecedores para          ³±±
±±³          ³aplicacao das regras de validacao para agente retenedor     ³±±
±±³          ³em relacao ao arquivo enviado pela AFIP                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ProcCliFor(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Alias da tabela a ser processada(SA1/SA2)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA059                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop para varrer arquivo de Cliente ou Fornecedor e validar se existe no arquivo TXT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof()

	IncProc(Iif(lCli,STR0015,STR0016))	//##"(15)Processando Clientes/(16)Processando Fornecedores"
        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Trava registro de fornecedor para atualizacoes referentes ao Retencion SUSS  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lCli
		RecLock("SA2",.F.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o cliente/fornecedor consta no arquivo temporario - AFIP ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TMP->(dbSeek((cAlias)->&(cPrefTab+"_CGC")))

		While TMP->CGC == (cAlias)->&(cPrefTab+"_CGC")

			dDatIni := TMP->DATAI
			dDatFim := TMP->DATAF
			
			PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IVP",lCli,.T.)

			TMP->(dbSkip())
			
		EndDo	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza informacoes eferente a Retencion SUSS na tabela de fornecedores ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza informacoes referente a Retencion SUSS na tabela de fornecedores ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PesqSFH     ³ Autor ³ Marco Aurelio - Mano    ³ Data ³25/02/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Pesquisa existencia de registros na tabela SFH(Ingressos Brutos)³±±
±±³          ³referente ao cliente ou forcedor passado como parametro         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PesqSFH(ExpN1,ExpC1,ExpL1,ExpL2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Ordem do indice da tabela SFH                           ³±±
±±³          ³ExpC1 = Chave de pesquisa para a tabela SFH                     ³±±
±±³          ³ExpL1 = Determina se a pesquisa trata cliente ou fornecedor     ³±±
±±³          ³ExpL2 = Determina se Cliente/Fornecedor consta no TXT(AFIP)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA059                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro do Cliente ou Fornecedor na tabela SFH ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dbSeek(xFilial("SFH")+cKeySFH)

	lIncSFH := .F.
	lAtuSFH := .T.	 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Loop para pegar o registro referente ao periodo vigente do cliente ou fornecedor na tabela SFH ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Determina a data final do periodo conforme regras em que cliente/fornecedor deve ser considerado como agente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Empty(TMP->DATAF) .or. (TMP->DATAF >= dDataBase))    
		
			If (Empty(SFH->FH_FIMVIGE) .or. (SFH->FH_FIMVIGE >= dDataBase)) 

				If SFH->FH_AGENTE=="N"
					lIncSFH := .T.   
					cDatFim := dDataBase
					cDatIni := (dDataBase+1)                                 	
				EndIf

			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Determina a inclusao de um novo periodo para considerar o cliente/fornecedor como agente ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando nao existir o cliente/fornecedor no TXT(AFIP) o periodo de rentecao na tabela SFH deverah ser encerrado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDatFim := dDataBase
		lAtuSFH := !(SFH->FH_AGENTE=="N" .or. (!Empty(SFH->FH_FIMVIGE) .and. SFH->FH_FIMVIGE < dDataBase))
	EndIf
		
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando houver a necessidade de se inluir um periodo na tabela SFH que tenha sido enviado no TXT onde a data final for maior que a ³
	//³data base do sistema, considerar que a data inicial deste periodo(FH_INIVIGE) devera ser atualizada com "dDataBase+1" afim de se  ³
	//³preservar o historico dos documentos emitidos no periodo anterior.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
