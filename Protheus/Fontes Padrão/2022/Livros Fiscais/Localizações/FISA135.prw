#INCLUDE "PROTHEUS.CH"      
#INCLUDE "FISA135.CH"   
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FISA135   ³ Autor ³  Danilo Santos        ³ Data ³26/10/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Importacao de arquivo referente a                           ³±±
±±³          ³RN 1-17 - Córdoba - Agentes de ret/perc  riesgo fiscal      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³FISA135()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA135()

Local aArqTmp	:= {}	// Arquivo temporario para importacao
Local cAliasTMP	:= ""	// Alias atribuido ao arquivo temporario
Local nIteAge	:= 0	// Opcao de agente selecionado para importacao
Local lRet	 	:= .T.	// Determina a continuidade de processamento da rotina
Private cPer	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama tela de Wizard para informacao dos parametros para importacao do arquivo XLS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TelaWiz()	            

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera arquivo temporario a partir do XLS importado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| lRet := GeraTemp(@aArqTmp,@nIteAge)})

	cAliasTMP := aArqTmp[02]  
	(cAliasTMP)->(DbGoTo(1))
	
	If lRet

		If Str(nIteAge,1) $ "1|3"	// Cliente ou Ambos

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processo de valiadacao para Clientes - Agente  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Processa({|| ProcCliFor("SA1")})

		EndIf
		
		If Str(nIteAge,1) $ "2|3"	// Fornecedor ou Ambos

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processo de valiadacao para Fornecedores - Agente ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Processa({|| ProcCliFor("SA2")})

		EndIf

	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui o arquivo temporario criado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbCloseArea()
	Ferase(aArqTmp[1]+GetDBExtension())
	Ferase(aArqTmp[1]+OrdBagExt())

Endif

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TelaWiz   ³ Autor ³Danilo Santos        ³ Data ³ 26/10/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tela Wizard inicial para selecao do arquivo a ser importado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TelaWiz()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico - FISA135                                       ³±±
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
aAdd(aTxtPre,STR0002) 			//##"Importação do arquivo Agentes de Percepcion/Retenção"
aAdd(aTxtPre,STR0001) 			//##"Atenção"
aAdd(aTxtPre,STR0003) 			//##"Preencha corretamente as informações solicitadas."
aAdd(aTxtPre,Alltrim(STR0004))	//## "Esta rotina irá importar o arquivo padrão de Agentes de Retenção disponibilizados pelo portal portal.rentascordoba."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Painel 1 - Informacoes para importacao do arquivo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

aAdd (aPaineis[nPos][3], {0,"",,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})
aAdd (aPaineis[nPos][3], {1,STR0022,,,,,,})	//##"Periodo a ser importado:"	
aAdd (aPaineis[nPos][3], {2,"",cPer,1,,,,6,,})
//aAdd (aPaineis[nPos][3], {2,"",,1,,,,150,,.T.})				
//aAdd (aPaineis[nPos][3], {6,STR0022,,,,,,})	//##"Periodo a ser importado:"

lRet :=	xMagWizard(aTxtPre,aPaineis,"TelaWiz")
	
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GeraTemp     ³ Autor ³ Danilo Santos           ³ Data ³26/10/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Gera arquivo temporarioa a partir do TXT importado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GeraTemp(ExpC1,ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Nome do arquivo temporario                               ³±±
±±³          ³ExpN1 = Opcao de agente selecionado para importacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico FISA135                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function GeraTemp(aArqTmp,nIteAge)
Local aWizard    := {}									// Array com informacoes da tela de Wizard
Local aInforma   := {} 									// Array auxiliar com as informacoes da linha lida no arquivo XLS
Local aIIBB      := {}         							// Array auxiliar para criacao do arquivo temporario
Local aIteAge    := {}         							// Array de itens selecionaveis na tela de Wizard
Local lRet       := xMagLeWiz("TelaWiz",@aWizard,.T.) 	// Determina a continuidade do processamento como base nas informacoes da tela de Wizard
Local cArqProc   := Alltrim(aWizard[01][01])			// Arquivo a ser importado selecionado na tela de Wizard
Local cTitulo    := STR0008								// "Problemas na Importação de Arquivo"
Local cErro	     := ""   								// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
Local cSolucao   := ""           						// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
Local cLinha     := ""									// Informacao lida para cada linha do arquivo XLS
Local lArqValido := .T.                               	// Determina se o arquivo XLS esta ok para importacao
Local nInd       := 0                   				// Indexadora de laco For/Next
Local nHandle    := 0            						// Numero de referencia atribuido na abertura do arquivo XLS
Local nTam       := 0 									// Tamanho de buffer do arquivo XLS
Local dDataIni   := ""            						
Local dDataFim   := ""
Local cDelimit   := ""
Local aTeste		:= {}
Private oTmpTable

aIteAge := {STR0018,STR0019,STR0020}	//##"Clientes"##"Fornecedores"##"Ambos"
nIteAge := aScan(aIteAge,aWizard[01][02])
cPer := "01/" + Substr(aWizard[01][03],1,2)  + "/" + Substr(aWizard[01][03],3,6)
dDataIni:= FirstDay(CTOD(cPer))
dDataFim := LastDay(CTOD(cPer)) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o arquivo temporario para a importacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aIIBB,{"CUIT"	  ,"C",TamSX3("A1_CGC")[1],0})
AADD(aIIBB,{"RAZAO" ,"C",50,0})
AADD(aIIBB,{"NROINSC" ,"C",10,0})
AADD(aIIBB,{"DATAI" ,"D",08,0})
AADD(aIIBB,{"DATAF" ,"D",08,0})

	aTeste:={"CUIT"}
	cTemp:= "TMP"
	oTmpTable:= FWTemporaryTable():New(cTemp) 
	oTmpTable:SetFields( aIIBB ) 
	oTmpTable:AddIndex("1",aTeste)
	//Creacion de la tabla
	oTmpTable:Create()

//aArqTmp := {cArqTmp,"TMP"}
aArqTmp := {"TMP","TMP"}

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
		cSolucao  := STR0010 			//"Verifique se foi informado o arquivo correto para importação"
	EndIf

	If lArqValido 

		ProcRegua(nTam)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera arquivo temporario a partir do arquivo XLS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (!FT_FEof()) 		

			IncProc()

		    aInforma := {}	            
   			cLinha   := FT_FREADLN()
   			If "," $ cLinha
				cDelimit := ","
			ElseIf ";" $ cLinha
				cDelimit := ";"
			Endif
        	RecLock("TMP",.T.)

			For nInd := 1 to 5
				nPos := at(";",cLinha)
				If nPos > 0
					AADD (aInforma,Alltrim(SubStr(cLinha,1,(nPos-1))))
				Else
					AADD (aInforma,Alltrim(cLinha))
				Endif	
				cLinha := SubStr(cLinha,nPos+1,Len(cLinha))
			Next

  	  		TMP->CUIT		:= STRTRAN(aInforma[1],"-", "")
			TMP->RAZAO  	:= aInforma[2]
			TMP->NROINSC	:= aInforma[3]  
			TMP->DATAI		:= dDataIni
			TMP->DATAF		:= dDataFim
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
±±³Fun‡…o    ³ProcCliFor³ Autor ³Danilo Santos          ³ Data ³ 26/10/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa os arquivos de clientes/fornecedores para          ³±±
±±³          ³aplicacao das regras de validacao para agente retenedor     ³±±
±±³          ³em relacao ao arquivo enviado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ProcCliFor(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Alias da tabela a ser processada(SA1/SA2)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA135                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcCliFor(cAlias)
Local aArea     := GetArea()			// Salva area atual para posterior restauracao
Local lExistTXT := .F.					// Determina se o Clinte ou Fornecedor consta no arquivo importado
Local lCli      := (cAlias=="SA1")		// Determina se a rotina foi chamada para processar o arquivo de clientes ou fornecedores
Local cPrefTab  := Substr(cAlias,2,2)	// Prefixo para acesso dos campos
Local dDatIni   := ""					// Data inicial do periodo enviada no XLS
Local dDatFim   := ""					// Data final do periodo enviada no XLS

dbSelectArea(cAlias)
(cAlias)->(dbGoTop())
    
ProcRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop para varrer arquivo de Cliente ou Fornecedor e validar se existe no arquivo XLS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof()

	IncProc(Iif(lCli,STR0015,STR0016))	//##"(15)Processando Clientes/(16)Processando Fornecedores"
        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Trava registro de fornecedor para atualizacoes referentes ao Retencion SUSS  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lCli
		RecLock("SA2",.F.)
	EndIf
	TMP->(DbGoTo(1))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se o cliente/fornecedor consta no arquivo temporario - rentascordoba.gob.ar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TMP->(dbSeek((cAlias)->&(cPrefTab+"_CGC")))

		While TMP->CUIT == (cAlias)->&(cPrefTab+"_CGC")

			dDatIni := TMP->DATAI
			dDatFim := TMP->DATAF
			
			PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IB8",lCli,.T.)

			TMP->(dbSkip())
			
		EndDo	
				
	Else 
		
		PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IB8",lCli,.F.)	
		
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
±±³Fun‡ao    ³PesqSFH     ³ Autor ³ Danilo Santos           ³ Data ³26/10/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Pesquisa existencia de registros na tabela SFH(Ingressos Brutos)³±±
±±³          ³referente ao cliente ou forcedor passado como parametro         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PesqSFH(ExpN1,ExpC1,ExpL1,ExpL2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Ordem do indice da tabela SFH                           ³±±
±±³          ³ExpC1 = Chave de pesquisa para a tabela SFH                     ³±±
±±³          ³ExpL1 = Determina se a pesquisa trata cliente ou fornecedor     ³±±
±±³          ³ExpL2 = Determina se Cliente/Fornecedor consta no XLS           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA135                                            ³±±
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
Local lAtuRet	 := .F.
Local lFinPer  := .F.
Local dDatIni  := TMP->DATAI    // Data de inicio da vigencia enviada no XLS
Local dDatFim  := TMP->DATAF    // Data final da vigencia enviada no XLS
Local dDatAux  := Ctod("")    	// Data auxiliar para validacao de periodo de vigencia na tabela SFH
Local cAliasSFB:= "SFB"
Local cKeyIBR	 := ""
Local nAliqPerc:= 0
Local nAliqRet := 0

dbSelectArea("SFH")
DbSetOrder(nOrd) 
SFH->(DbGoTo(1))

dbSelectArea(cAliasSFB)
DbSetOrder(1) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a aliquota do imposto de percepção e retenção na tabela SFB ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dbSeek(xFilial("SFB")+"IB8")
	nAliqPerc:= (cAliasSFB)->FB_ALIQ
Endif
If dbSeek(xFilial("SFB")+"IBR")
	nAliqRet:= SFB->FB_ALIQ
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro do Cliente ou Fornecedor na tabela SFH ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If 	SFH->(dbSeek(xFilial("SFH")+cKeySFH))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Loop para pegar o registro referente ao periodo vigente do cliente ou fornecedor na tabela SFH ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While xFilial("SFH")+cKeySFH==SFH->FH_FILIAL+Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE)+SFH->FH_LOJA +SFH->FH_IMPOSTO
		
		If nAliqPerc <> SFH->FH_ALIQ .And. SFH->FH_ISENTO  == "N" .And. (dDatini > SFH->FH_FIMVIGE)// .Or. Empty(SFH->FH_FIMVIGE))
			lIncSFH:= .T.
			lFinPer := .T.
			lAtuSFH := .F.            
			nRegSFH := SFH->(Recno())
		ElseIf nAliqPerc == SFH->FH_ALIQ .And. SFH->FH_ISENTO  == "N" .And. (SFH->FH_INIVIGE == dDatIni .And. Empty(SFH->FH_FIMVIGE))//Verificar esse ponto
			lFinPer := .F.
			lAtuSFH := .T.
			lIncSFH := .F.
			nRegSFH := SFH->(Recno())
		ElseIf nAliqPerc == SFH->FH_ALIQ .And. SFH->FH_ISENTO  == "N" .And. (SFH->FH_INIVIGE <> dDatIni	.And. SFH->FH_FIMVIGE < dDatFim)
			lFinPer := .F.
			lAtuSFH := .T.
			lIncSFH := .F.
			nRegSFH := SFH->(Recno())
		EndIf
		
		SFH->(DbSkip())
		
	EndDo
	
	SFH->(dbGoto(nRegSFH))
	
	If lFinPer .And. SFH->FH_ISENTO  == "N"
		Reclock("SFH",.F.)            
			SFH->FH_FIMVIGE := (dDatIni-1)
		MsUnLock()	
	Endif
EndIf
	
If lAtuSFH 
	If !(SFH->FH_INIVIGE == dDatIni .And. (Empty(SFH->FH_FIMVIGE) .Or. dDatFim < SFH->FH_FIMVIGE)) 
		Reclock("SFH",.F.)
   		SFH->FH_FIMVIGE := dDatFim
		MsUnLock()
	Endif
EndIf		

If lIncSFH

	Reclock("SFH",.T.)

	SFH->FH_FILIAL  := xFilial("SFH")
	SFH->FH_TIPO    := "I"
	SFH->FH_PERCIBI := "S"
	SFH->FH_ISENTO  := "N"
	SFH->FH_APERIB  := "N"
	SFH->FH_IMPOSTO := "IB8"
	SFH->FH_PERCENT := 0
	SFH->FH_ALIQ	  := nAliqPerc
	SFH->FH_INIVIGE := dDatIni  
	SFH->FH_FIMVIGE := ctod(" / / ")
	SFH->FH_AGENTE  := "N"
	SFH->FH_SITUACA := "2"

	If lCli
		SFH->FH_CLIENTE := SA1->A1_COD
		SFH->FH_LOJA    := SA1->A1_LOJA
		SFH->FH_ZONFIS  := "CO" 
		SFH->FH_NOME    := SA1->A1_NOME
	Else	
		SFH->FH_LOJA    := SA2->A2_LOJA
		SFH->FH_FORNECE := SA2->A2_COD
		SFH->FH_ZONFIS  := "CO"
		SFH->FH_NOME    := SA2->A2_NOME
	EndIf

	MsUnLock()
	
EndIf

SFH->(dbCloseArea()) 

RestArea(aArea)

dbSelectArea("SFH")
SFH->(DbSetOrder(nOrd)) 
SFH->(DbGoTo(1))
 
nRegSFH  := 0
cKeyIBR:= (IIf(lCli,SA1->A1_COD+SA1->A1_LOJA,SA2->A2_COD+SA2->A2_LOJA)+"IBR")
lIncSFH  := lExistTXT
lAtuSFH  := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro do Cliente ou Fornecedor na tabela SFH ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
If 	SFH->(dbSeek(xFilial("SFH")+cKeyIBR)) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Loop para pegar o registro referente ao periodo vigente do cliente ou fornecedor na tabela SFH ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While xFilial("SFH")+cKeyIBR==SFH->FH_FILIAL+Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE)+SFH->FH_LOJA +SFH->FH_IMPOSTO
		
		If nAliqRet <> SFH->FH_ALIQ .And. SFH->FH_ISENTO  == "N" .And. (dDatini > SFH->FH_FIMVIGE)
			lIncSFH:= .T.
			lFinPer := .T.
			lAtuSFH := .F.            
			nRegSFH := SFH->(Recno())
		ElseIf nAliqRet == SFH->FH_ALIQ .And. SFH->FH_ISENTO  == "N" .And. (SFH->FH_INIVIGE == dDatIni .And. Empty(SFH->FH_FIMVIGE))
			lFinPer := .F.
			lAtuSFH := .T.
			lIncSFH := .F.
			nRegSFH := SFH->(Recno())	
		ElseIf nAliqRet == SFH->FH_ALIQ .And. SFH->FH_ISENTO  == "N" .And. (SFH->FH_INIVIGE <> dDatIni	.And. SFH->FH_FIMVIGE < dDatFim)
			lFinPer := .F.
			lAtuSFH := .T.
			lIncSFH := .F.
			nRegSFH := SFH->(Recno())		
		EndIf
		
		SFH->(DbSkip())
		
	EndDo
	
	SFH->(dbGoto(nRegSFH))
	
	If lFinPer .And. SFH->FH_ISENTO  == "N"
		Reclock("SFH",.F.)            
			SFH->FH_FIMVIGE := (dDatIni-1)
		MsUnLock()	
	Endif
EndIf

If lAtuSFH 
	If !(SFH->FH_INIVIGE == dDatIni .And. Empty(SFH->FH_FIMVIGE))
		Reclock("SFH",.F.)
   		SFH->FH_FIMVIGE := dDatFim
		MsUnLock()
	Endif
EndIf

If lIncSFH

	Reclock("SFH",.T.)

	SFH->FH_FILIAL  := xFilial("SFH")
	SFH->FH_TIPO    := "I"
	SFH->FH_PERCIBI := "S"
	SFH->FH_ISENTO  := "N"
	SFH->FH_APERIB  := "N"
	SFH->FH_IMPOSTO := "IBR"
	SFH->FH_PERCENT := 0
	SFH->FH_ALIQ	  := nAliqRet
	SFH->FH_INIVIGE := dDatIni 
	SFH->FH_FIMVIGE := ctod(" / / ")
	SFH->FH_AGENTE  := "N"
	SFH->FH_SITUACA := "2"

	If lCli
		SFH->FH_CLIENTE := SA1->A1_COD
		SFH->FH_LOJA    := SA1->A1_LOJA
		SFH->FH_ZONFIS  := "CO" 
		SFH->FH_NOME    := SA1->A1_NOME
	Else	
		SFH->FH_LOJA    := SA2->A2_LOJA
		SFH->FH_FORNECE := SA2->A2_COD
		SFH->FH_ZONFIS  := "CO"
		SFH->FH_NOME    := SA2->A2_NOME
	EndIf

	MsUnLock()
	
EndIf

SFH->(dbCloseArea()) 

RestArea(aArea)

Return(lRet)