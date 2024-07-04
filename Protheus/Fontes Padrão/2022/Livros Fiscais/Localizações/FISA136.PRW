#Include 'Protheus.ch'
#Include 'FISA136.ch'
#Include 'topconn.ch'
//------------------------
/* {Protheus.doc} 
@author Danilo Santos 
@since 28/09/2017
@version P12.1.7
/*/
//------------------------

Function FISA136()

Local aArqTmp	:= {}	// Arquivo temporario para importacao
Local cAliasTMP	:= ""	// Alias atribuido ao arquivo temporario
Local nIteAge	:= 0	// Opcao de agente selecionado para importacao
Local lRet	 	:= .T.	// Determina a continuidade de processamento da rotina
Private TMP  := GetNextAlias()  

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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processo de valiadacao para Fornecedores - Agente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|| ProcFor("SA2")})
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
±±³Fun‡…o    ³TelaWiz   ³ Autor ³Danilo Santos        ³ Data ³ 28/09/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Tela Wizard inicial para selecao do arquivo a ser importado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TelaWiz()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico - FISA136                                       ³±±
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

lRet :=	xMagWizard(aTxtPre,aPaineis,"TelaWiz")
	
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GeraTemp     ³ Autor ³ Danilo Santos           ³ Data ³28/09/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Gera arquivo temporarioa a partir do XLS importado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GeraTemp(ExpC1,ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Nome do arquivo temporario                               ³±±
±±³          ³ExpN1 = Opcao de agente selecionado para importacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico FISA136                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function GeraTemp(aArqTmp,nIteAge)
Local aWizard    := {}									// Array com informacoes da tela de Wizard
Local aInforma   := {} 									// Array auxiliar com as informacoes da linha lida no arquivo XLS
Local aCampos    := {}         							// Array auxiliar para criacao do arquivo temporario
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
Local dData   := "" 
Local cDelimit := ""     
						


aIteAge := {STR0017}	//"##"Fornecedores"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o arquivo temporario para a importacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//*************Modelo do arquivo*************
//# CUIT,Razon Social,Registro,Situacion,Fecha de Publicación de la Situación
//33709144869,WORK TECH S.R.L.,REGISTRO FISCAL DE PROVEEDORES DE EMPRESAS MINERAS,ACTIVO,15/06/2016

AADD(aCampos,{"CUIT"	  ,"C",TamSX3("A2_CGC")[1],0})
AADD(aCampos,{"RAZAO" ,"C",50,0})
AADD(aCampos,{"CATEGORIA" ,"C",01,0})
AADD(aCampos,{"SITUACAO" ,"C",08,0})
AADD(aCampos,{"ALTA" ,"D",08,0})
AADD(aCampos,{"EXCLUSAO" ,"D",08,0})
AADD(aCampos,{"LIMITACAO" ,"D",08,0})


cArqTmp := CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cArqTmp,TMP) 
IndRegua(TMP,cArqTmp,"CUIT")


aArqTmp := {cArqTmp,TMP}


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
			
   			If !("#" $ cLinha) 
   				If "," $ cLinha
					cDelimit := ","
				ElseIf ";" $ cLinha
					cDelimit := ";"
				Endif	
        		
				RecLock(TMP,.T.)
				
				For nInd := 1 to 7
					nPos := at(cDelimit,cLinha)
					If nPos > 0
						AADD (aInforma,Alltrim(SubStr(cLinha,1,(nPos-1))))
					Else
						AADD (aInforma,Alltrim(cLinha))
					Endif	
					cLinha := SubStr(cLinha,nPos+1,Len(cLinha))
				Next
				
				(TMP)->CUIT		:= STRTRAN(aInforma[1],"-", "")
				
				(TMP)->RAZAO := aInforma[2]
			
				If "EMPRESAS MINERAS" $ UPPER(aInforma[3])
					If "PROVEEDORES" $ UPPER(aInforma[3])
						(TMP)->CATEGORIA   := "3"
					else
						(TMP)->CATEGORIA	:= "1" 	
					Endif
				ElseIf "CATEO" $ UPPER(aInforma[3])
					(TMP)->CATEGORIA   := "2"
				Else
					(TMP)->CATEGORIA   := ""
				Endif
				
				If "ACTIVO" $ aInforma[4]
					(TMP)->SITUACAO	:= "1" 
				Elseif "EXCLUIDO" $ aInforma[4]
					(TMP)->SITUACAO	:= "2"	 
				Endif

				(TMP)->LIMITACAO		:= CTOD(aInforma[7])
									
			Endif
			MsUnLock()
			FT_FSkip()
		Enddo 

	Endif	
	
	FT_FUse()
	FClose(nHandle)

	If Empty(cErro) .and. (TMP)->(LastRec())==0   
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
±±³Fun‡…o    ³ProcCliFor³ Autor ³Danilo Santos          ³ Data ³ 28/09/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa os arquivos de fornecedores para          ³±±
±±³          ³aplicacao das regras de validacao para agente retenedor     ³±±
±±³          ³em relacao ao arquivo enviado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ProcCliFor(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Alias da tabela a ser processada(SA1/SA2)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA136                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcFor(cAlias)
Local aArea     := GetArea()			// Salva area atual para posterior restauracao
//Local lExistTXT := .F.					// Determina se o Fornecedor consta no arquivo importado
Local dData     := ""					// Data inicial do periodo enviada no XLS


dbSelectArea(cAlias)
dbSetOrder(3) // A2_FILIAL + A2_CGC
(cAlias)->(dbGoTop())
    
ProcRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop para varrer arquivo de Cliente ou Fornecedor e validar se existe no arquivo XLS  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof()

	IncProc(STR0015)	//##"(16)Processando Fornecedores"
        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Trava registro de fornecedor para atualizacoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SA2",.F.)
	
	(TMP)->(DbGoTo(1))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se o fornecedor consta no arquivo temporario - ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (TMP)->(MsSeek((cAlias)->A2_CGC))
		While (TMP)->CUIT == (cAlias)->A2_CGC
			
			If allTrim((TMP)->SITUACAO) == "1" .AND. Empty((TMP)->LIMITACAO) .And. ColumnPos( 'A2_TIPROVM' ) > 0 .And. (cAlias)->A2_TIPROVM <> "1"
				If (TMP)->CATEGORIA == "1"
					(cAlias)->A2_TIPROVM := "0"
				ElseIf (TMP)->CATEGORIA == "3"
					(cAlias)->A2_TIPROVM := "1"
				ElseIf (TMP)->CATEGORIA == ""
					(cAlias)->A2_TIPROVM := "2"
				ElseIf (TMP)->CATEGORIA == "2"
					(cAlias)->A2_TIPROVM := "3"
				Endif
			ElseIf allTrim((TMP)->SITUACAO) == "1" .AND. !empty((TMP)->LIMITACAO) .And. ColumnPos( 'A2_TIPROVM' ) > 0 .And. (cAlias)->A2_TIPROVM <> "1"
				(cAlias)->A2_TIPROVM := "4"
			ElseIf allTrim((TMP)->SITUACAO) == "2" .And. ColumnPos( 'A2_TIPROVM' ) > 0 .And. (cAlias)->A2_TIPROVM <> "1"
				(cAlias)->A2_TIPROVM := ""
			Endif

			(TMP)->(dbSkip())
		EndDo	
	EndIf	

	MsUnLock()
	
	dbSkip()
EndDo 

RestArea(aArea) 

Return
