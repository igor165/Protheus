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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿎hama tela de Wizard para informacao dos parametros para importacao do arquivo XLS�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If TelaWiz()	            

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿒era arquivo temporario a partir do XLS importado �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	Processa({|| lRet := GeraTemp(@aArqTmp,@nIteAge)})

	cAliasTMP := aArqTmp[02]  
	(cAliasTMP)->(DbGoTo(1))
	
	If lRet
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿛rocesso de valiadacao para Fornecedores - Agente �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		Processa({|| ProcFor("SA2")})
	EndIf

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿐xclui o arquivo temporario criado�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	dbCloseArea()
	Ferase(aArqTmp[1]+GetDBExtension())
	Ferase(aArqTmp[1]+OrdBagExt())

Endif

Return

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    쿟elaWiz   � Autor 쿏anilo Santos        � Data � 28/09/2017 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao 쿟ela Wizard inicial para selecao do arquivo a ser importado 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   쿟elaWiz()                                                   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros�                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � Especifico - FISA136                                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function TelaWiz()

//旼컴컴컴컴컴컴컴컴컴컴컴커
//쿏eclaracao das variaveis�
//읕컴컴컴컴컴컴컴컴컴컴컴켸
Local cMask		:= Replicate("X",245)	// Mascara para edicao do arquivo a ser informado para importacao
Local aTxtPre 	:= {}					// Array com textos a serem apresentados na tela de Wizard
Local aPaineis 	:= {} 					// Array de paineis a serem criados na tela de Wizard
Local nPos		:= 0        			// Referencia de posicionamento dos paineis da tela de Wizard
Local lRet		:= .T.    				// Conteudo de retorno da funcao

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿘onta wizard com as perguntas necessarias�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aAdd(aTxtPre,STR0002) 			//##"Importa豫o do arquivo Agentes de Percepcion/Reten豫o"
aAdd(aTxtPre,STR0001) 			//##"Aten豫o"
aAdd(aTxtPre,STR0003) 			//##"Preencha corretamente as informa寤es solicitadas."
aAdd(aTxtPre,Alltrim(STR0004))	//## "Esta rotina ir� importar o arquivo padr�o de Agentes de Reten豫o disponibilizados pelo portal portal.rentascordoba."

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿛ainel 1 - Informacoes para importacao do arquivo �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aAdd(aPaineis,{})   

nPos :=	Len(aPaineis)     

aAdd(aPaineis[nPos],STR0005) //##"Assistente de parametriza豫o" 
aAdd(aPaineis[nPos],STR0006) //##"Informa寤es sobre o arquivo de retorno: "
aAdd(aPaineis[nPos],{})

aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})
aAdd(aPaineis[nPos][3],{1,STR0007,,,,,,}) //##"Arquivo a ser importado: "
aAdd(aPaineis[nPos][3],{2,"",cMask,1,,,,150,,.T.})
aAdd(aPaineis[nPos][3],{0,"",,,,,,})

lRet :=	xMagWizard(aTxtPre,aPaineis,"TelaWiz")
	
Return(lRet)   

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇쿑un놹o    쿒eraTemp     � Autor � Danilo Santos           � Data �28/09/17  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escri놹o 쿒era arquivo temporarioa a partir do XLS importado               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇쿞intaxe   쿒eraTemp(ExpC1,ExpN1)                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇쿛arametros쿐xpC1 = Nome do arquivo temporario                               낢�
굇�          쿐xpN1 = Opcao de agente selecionado para importacao              낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇쿢so       쿐specifico FISA136                                               낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/          
Static Function GeraTemp(aArqTmp,nIteAge)
Local aWizard    := {}									// Array com informacoes da tela de Wizard
Local aInforma   := {} 									// Array auxiliar com as informacoes da linha lida no arquivo XLS
Local aCampos    := {}         							// Array auxiliar para criacao do arquivo temporario
Local aIteAge    := {}         							// Array de itens selecionaveis na tela de Wizard
Local lRet       := xMagLeWiz("TelaWiz",@aWizard,.T.) 	// Determina a continuidade do processamento como base nas informacoes da tela de Wizard
Local cArqProc   := Alltrim(aWizard[01][01])			// Arquivo a ser importado selecionado na tela de Wizard
Local cTitulo    := STR0008								// "Problemas na Importa豫o de Arquivo"
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ria o arquivo temporario para a importacao�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

//*************Modelo do arquivo*************
//# CUIT,Razon Social,Registro,Situacion,Fecha de Publicaci�n de la Situaci�n
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
		cErro	   := STR0009 + cArqProc	//"N�o foi poss�vel efetuar a abertura do arquivo: "
		cSolucao  := STR0010 			//"Verifique se foi informado o arquivo correto para importa豫o"
	EndIf

	If lArqValido 

		ProcRegua(nTam)

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
		//쿒era arquivo temporario a partir do arquivo XLS �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
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
		cErro		:= STR0011	//"A importa豫o n�o foi realizada por n�o existirem informa寤es no arquivo texto informado."
		cSolucao	:= STR0012	//"Verifique se foi informado o arquivo correto para importa豫o"
	Endif
	
Else

	cErro	 := STR0013+CHR(13)+cArqProc	//"O arquivo informado para importa豫o n�o foi encontrado: "
	cSolucao := STR0014 		   			//"Informe o diret�rio e o nome do arquivo corretamente e processe a rotina novamente."

EndIf
	 
If !Empty(cErro)

	xMagHelpFis(cTitulo,cErro,cSolucao)

	lRet := .F.
	
Endif

Return(lRet)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    쿛rocCliFor� Autor 쿏anilo Santos          � Data � 28/09/17 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao 쿛rocessa os arquivos de fornecedores para          낢�
굇�          쿪plicacao das regras de validacao para agente retenedor     낢�
굇�          쿮m relacao ao arquivo enviado                               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   쿛rocCliFor(ExpC1)                                           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿐xpC1 = Alias da tabela a ser processada(SA1/SA2)           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       쿐specifico - FISA136                                        낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function ProcFor(cAlias)
Local aArea     := GetArea()			// Salva area atual para posterior restauracao
//Local lExistTXT := .F.					// Determina se o Fornecedor consta no arquivo importado
Local dData     := ""					// Data inicial do periodo enviada no XLS


dbSelectArea(cAlias)
dbSetOrder(3) // A2_FILIAL + A2_CGC
(cAlias)->(dbGoTop())
    
ProcRegua(RecCount())

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿗oop para varrer arquivo de Cliente ou Fornecedor e validar se existe no arquivo XLS  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
While !Eof()

	IncProc(STR0015)	//##"(16)Processando Fornecedores"
        
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
	//쿟rava registro de fornecedor para atualizacoes �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
	RecLock("SA2",.F.)
	
	(TMP)->(DbGoTo(1))
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿣erifica se o fornecedor consta no arquivo temporario - �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
