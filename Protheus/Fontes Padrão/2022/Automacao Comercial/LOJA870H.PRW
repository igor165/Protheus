#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "LOJA870H.ch"

Static nTotReg 	:= 0  // totalizador de registros
Static cAliasTrb:= '' // totalizador de registros				
Static nRecno   := 0  // Recno da tabela mfi
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA870H
Efetua a importacao de dados via arquivo texto, conforme configurado 
no cadastro de linhas para a administradora financeira..
@author Varejo
@since 28/05/2013
@version P10
/*/
//-------------------------------------------------------------------
Function LOJA870H(cFiltro)

Local aArea		:= GetArea()         // Posicionamento atual da tabela
Local cPerg		:= ""					// grupo de pergunta no SX1
Local cArquivo	:= ''                // Nome do arquivo
Local cExtensao := STR0001 				//"txt"     	//Extensao
Local cTipoArq 	:= STR0002				//"Todos os Arquivos (*.txt)    | *.txt |"
Local cDir      := '' 					// Pasta do arquivo
Local cPath     := ''					// Caminho do arquivo 
Local oDlg		:= Nil						// Objeto para diálogo

Default cFiltro:= "GE"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria tela para informar os parametros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg := IIF( cFiltro=="GE",PadR("LOJA870H",10),PadR("LOJA871H",10) )

If Pergunte(cPerg,.T.,STR0003) //"Validacao de arquivo texto"

	//+-----------------------------------+
	//| Montagem da tela de processamento.|
	//+-----------------------------------+

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0003) ; //"Validacao de arquivo texto"
	FROM 000,000 TO 200,400 PIXEL 
		 
	@ 005,005 TO 095,195 OF oDlg PIXEL 
	@ 010,020 Say STR0004 OF oDlg PIXEL //" Este programa ira validar o arquivo TXT retornado "
	@ 018,020 Say STR0005 OF oDlg PIXEL  //" pela Adminisradora financeira"
	
	TBtnBmp2():New(075,320,026,026,"SDUOPEN",,,,;
				  {|| cPath := cGetFile(cTipoArq,STR0006,1,cDir,.F.),; //"Selecione o diretório do aquivo"
				   cDir := Iif(Empty(cPath), cDir, cPath), cArquivo := cDir 		         },;
				   oDlg,STR0007)//"Pesquisa local de destino"
				   
	TGet():New(40,008,bSetGet(cArquivo),oDlg,150,010,,,,,,,,.T.,,,,,,,.T.)
		
	DEFINE SBUTTON FROM 070, 030 TYPE 1 ; 
	ACTION ( IIF(Empty(cArquivo),Alert(STR0008),; //"Informe o diretório !"
		( IIF(cFiltro="GE",LJ870HArq(cArquivo,cFiltro),LJ870HASF(cArquivo,cFiltro,cExtensao)),;
		oDlg:End() ) ) ) ENABLE OF oDlg
		 
	DEFINE SBUTTON FROM 070, 070 TYPE 2 ; 
	ACTION (oDlg:End()) ENABLE OF oDlg 
		
	DEFINE SBUTTON FROM 070, 110 TYPE 5 ; 
	ACTION (Pergunte(cPerg, .T.)) ENABLE OF oDlg 	
	
	ACTIVATE DIALOG oDlg CENTERED 
Else
	Return()
EndIf							

RestArea(aArea)
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870HASF
Processa arquivo texto pelo Grupo de Layout.
@author Varejo
@since 28/05/2013
@version P11
@param cArquivo - diretorio do arquivo texto
@param cFltro - Estabelece diferenciacao entre Garantia (GE) e Servico (SF)
/*/
//------------------------------------------------------------------- 
Static Function LJ870HASF(cArquivo,cFiltro,cExtensao)

Local aArea		:= GetArea()	// Posicionamento atual da tabela
Local cCampoTrb	:= ''   		// Camppos da query
Local aRegistro	:= {} 			// array bidimensional.
Local aCabecalho	:= {} 			// array bidimensional.
Local aRodape		:= {} 			// array bidimensional.
Local nHdl			:= 0  			// handle do arquivo
Local nX			:= 1  			// Contador
Local nScan		:= 0			// Localiza a posição do campo chave
Local lRet			:= .T. 		// Variável de retorno

Default cArquivo := ""
Default cFiltro := ""
Default cExtensao := "" 

Begin Transaction 
                     
//Valida se o lote ja foi gerado.
If LJ870HLote(cArquivo) 
	
	// *** ABRIR ARQUIVO TEXTO. 
	If !FILE(AllTrim(cArquivo))
	   MsgAlert(STR0009,"Alerta")//"Arquivo informado nao foi encontrado, Verifique diretorio ou nome do arquivo"
	   Return()
	EndIf 
	        
	If (nHdl := FT_FUse(AllTrim(cArquivo)))== -1
	   MsgAlert(STR0010,"Alerta") //"Arquivo vazio!!"
	   Return()
	EndIf				
						
	DbSelectArea("MG8")
	MG8->(DbSetOrder(1))
	If dbSeek(xFilial("MG8")+MV_PAR02,.T.)
	
		// VERIFICA SE A ADM. FINANCEIRA ESTA VINCULADO A UM GRUPO DE LAYOUT
		DbSelectArea("MG6")
		MG6->(DbSetOrder(1))
		If !EMPTY(MG8->MG8_GRPLAY) .AND. dbSeek(xFilial("MG6")+MG8->MG8_GRPLAY,.T.)
		
		   	// Verifica se a Adm.Financeira esta vinculado a um layout
		   	DbSelectArea("MFG")
			MFG->(DbSetOrder(1))
			If !EMPTY(MG6->MG6_LAYOUT) .AND. MFG->(DbSeek(xFilial("MFG")+MG6->MG6_LAYOUT))
				While MFG->(!EOF())
					If MFG->MFG_TIPLAY <> "2"
		    			MFG->(dbSkip())
						Loop
					EndIf
					
					//Verifica se o layout esta vinculado a um bloco
					DbSelectArea("MFF")
					MFF->(DbSetOrder(1))		 
					If MFF->(DbSeek(xFilial("MFF")+ MFG->MFG_CODBLO ))
						//Verifica se o cabecalho, registro e rodape que foram vinculados ao bloco
						// Cabecalho
						MFE->(DbSetOrder(1))
						MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_CABECA,.T. ))
						While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_CABECA
							aadd(aCabecalho, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
							MFE->(DbSkip())			
						EndDo  
						// Registro
						MFE->(DbSetOrder(1))
						MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_REGIST,.T. ))			
						While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_REGIST
							aadd(aRegistro, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_CHAVE,;
										      MFE->MFE_CARACT,MFE->MFE_IDERRO,MFE->MFE_RETSEP,MFE->MFE_COLINI,;
										      MFE->MFE_COLFIN} )
							MFE->(DbSkip())								
						EndDo			
						// Rodape
						MFE->(DbSetOrder(1))
						MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_RODAPE,.T. ))			
						While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_RODAPE
							aadd(aRodape, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
							MFE->(DbSkip())			
						EndDo				
						    
		                If !Empty(aRegistro)
							If !FT_FEOF()
								Processa({|| LJ870HPrSF(aRegistro,aCabecalho,aRodape,@nHdl,MG6->MG6_CODERR) },STR0011)//"Processando arquivo texto..."
							Else
								MsgRun(STR0012 ,,{|| LJ870AtMfi() })//"Aguarde, atualizando tabela de garantia estendida ..."
							EndIf
							
							MsgInfo(STR0013,STR0015) //"Arquivo processado com sucesso."##"Atencao"
						Else
							MsgInfo(STR0014,STR0015)	//"O cadastro de registro esta vazio."##"Atencao"
						EndIf
		
					EndIf
					MFG->(dbSkip())
				EndDo
			Else
				MsgInfo(STR0016,STR0015)		 //"Layout de importacao nao esta vinculado para Administradora financeira."##"Atencao"
			EndIf
			
			cCampoTrb:= ''
			cAliasTrb:= ''
			aRegistro:={}
		Else
			MsgInfo(STR0027,STR0015)	//"Grupo de layout não encontrado."###"Atenção"
		EndIf	
	Else
		MsgInfo("Serviço financeiro não existe.",STR0015) //"Serviço financeiro não existe."###"Atenção"
	EndIf
EndIf
		
End Transaction        

If nHdl>0
	fClose(nHdl)	
EndIf	

RestArea(aArea)
Return        

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870HArq
Gera arquivo texto.
@author Varejo
@since 28/05/2013
@version P11
@param cArquivo - diretorio do arquivo texto
/*/
//------------------------------------------------------------------- 
Static Function LJ870HArq(cArquivo,cFiltro)

Local aArea		:= GetArea()    	// Posicionamento Atual da tabela
Local cCampoTrb 	:= ''   // Campos da query
Local aRegistro := {} // array bidimensional.
Local aCabecalho:= {} // array bidimensional.
Local aRodape   := {} // array bidimensional.
Local nHdl      := 0  // handle do arquivo
Local nX        := 1  // Contador
Local nScan     := 0	 // Pesquisa de Caracteres
Local lRet      := .T. //variavel de retorno 

Default cArquivo := ""
Default cFiltro := ""

Begin Transaction 
                     
//Valida se o lote ja foi gerado.
If LJ870HLote(cArquivo) 
	
	// *** ABRIR ARQUIVO TEXTO. 
	If !FILE(AllTrim(cArquivo))
	   MsgAlert(STR0009,"Alerta")//"Arquivo informado nao foi encontrado, Verifique diretorio ou nome do arquivo"
	   Return()
	EndIf 
	        
	If (nHdl := FT_FUse(AllTrim(cArquivo)))== -1
	   MsgAlert(STR0010,"Alerta") //"Arquivo vazio!!"
	   Return()
	EndIf				
						
	dbSelectArea("SAE")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("SAE")+MV_PAR02,.T.)
	   	// Verifica se a Adm.Financeira esta vinculado a um layout
		MFG->(DbSetOrder(1))
		If MFG->(DbSeek(xFilial("MFG")+ SAE->AE_LAYIMP))
			//Verifica se o layout esta vinculado a um bloco
			MFF->(DbSetOrder(1))		 
			If MFF->(DbSeek(xFilial("MFF")+ MFG->MFG_CODBLO ))
				//Verifica se o cabecalho, registro e rodape que foram vinculados ao bloco
				// Cabecalho
				MFE->(DbSetOrder(1))
				MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_CABECA,.T. ))
				While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_CABECA
					aadd(aCabecalho, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
					MFE->(DbSkip())			
				EndDo  
				// Registro
				MFE->(DbSetOrder(1))
				MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_REGIST,.T. ))			
				While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_REGIST
					aadd(aRegistro, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_CHAVE,;
								      MFE->MFE_CARACT,MFE->MFE_IDERRO,MFE->MFE_RETSEP,MFE->MFE_COLINI,;
								      MFE->MFE_COLFIN} )
					MFE->(DbSkip())								
				EndDo			
				// Rodape
				MFE->(DbSetOrder(1))
				MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_RODAPE,.T. ))			
				While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_RODAPE
					aadd(aRodape, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
					MFE->(DbSkip())			
				EndDo				
				    
                If !Empty(aRegistro)
					If !FT_FEOF()
						Processa({|| LJ870HProc(aRegistro,aCabecalho,aRodape,@nHdl) },STR0011)//"Processando arquivo texto..."
					Else
						MsgRun(STR0012 ,,{|| LJ870AtMfi() })//"Aguarde, atualizando tabela de garantia estendida ..."
					EndIf
					
					MsgInfo(STR0013,STR0015) //"Arquivo processado com sucesso."##"Atencao"
				Else
					MsgInfo(STR0014,STR0015)	//"O cadastro de registro esta vazio."##"Atencao"
				EndIf

			EndIf
		Else
			MsgInfo(STR0016,STR0015)		 //"Layout de importacao nao esta vinculado para Administradora financeira."##"Atencao"
		EndIf
		
		cCampoTrb:= ''
		cAliasTrb:= ''
		aRegistro:={}
	Else
		MsgInfo(STR0027,STR0015)	//"Administradora financeira não existe."###"Atencao"					
	EndIf	
	
EndIf
		
End Transaction        

If nHdl>0
	fClose(nHdl)	
EndIf	

RestArea(aArea)
Return 
   
      
//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870HProc
Processa o arquivo texto retornado pela administradora financeira
@author Varejo
@since 28/05/2013
@version P11
@param 
/*/
//-------------------------------------------------------------------      
Static Function LJ870HProc(aRegistro,aCabecalho,aRodape,nHdl)

Local aArea	:= GetArea()    	// Posicionamento Atual da tabela
Local cErro  := ''  // Codigo do erro no arquivo
Local cLinha := ''  //Linha do arquivo texto
Local cId    := ''  //Caracter identificador do arquivo
Local nLin   := 0   //Contador
Local nScan  := 0   //Localiza a posicao do campo chave
Local nScanErro:= 0 //Localiza a posicao do campo erro 
Local aSepara:= {}  // Array para funcao Separa

Local lRodape:= .F. //Valida se no arquivo existe rodape
Local lErroArq := .F.    // Valida se a leitura do arquivo texto foi concluida para gravacao
Local aRecno := {}  // Array de recnos da MFI
Local cRetSep:='' // Caracter de retorno
Local cMsg   := '' // Mensagem de erros

FT_FGOTOP()
nTotReg := FT_FLastRec()
FT_FGOTOP()
    
ProcRegua(nTotReg) 
//Posicao chave no array aRegistro
nScan	 := aScan(aRegistro,{ |x| x[4] == '1' })
nScanErro:= aScan(aRegistro,{ |x| x[6] == '1' })
cId		 := aRegistro[1][5]
cRetSep  := aRegistro[1][7]
//Pula linha do cabecalho  
If !Empty(aCabecalho)
	FT_FSkip()		
	nLin++ 
EndIf
//Validacao se existe rodape 
If !Empty(aRodape)
	lRodape:= .T.
EndIf
While !FT_FEOF()
	nLin++  
	
	IncProc(STR0017+Alltrim(Str(nLin)) )	//"Linha: "
	
	If nLin == nTotReg
		If lRodape
			Exit
		EndIf	
	EndIf         
	cLinha := FT_FReadLn()	
	cLinha := StrTran(cLinha,cRetSep,cId)
	If !Empty(cId)				
		aSepara:= Separa(cLinha,cId)  
		If Len(aSepara) < nScanErro .OR. Len(aSepara) < nScan
			lErroArq:= .T.
			Alert(STR0030+CRLF+STR0031)//"Erro !"###"Arquivo texto não esta dentro do layout de importação cadastrado."
			aRecno:={}
			Exit
		EndIf
		cErro  := aSepara[nScanErro]	
		nRecno := Val(aSepara[nScan])
	Else
	    nRecno:= Val(SubStr(cLinha,aRegistro[nScan][8],aRegistro[nScan][9]-aRegistro[nScan][8]+1))
    	cErro := SubStr(cLinha,aRegistro[nScanErro][8],aRegistro[nScanErro][9]-aRegistro[nScanErro][8]+1)
	EndIf	       
	
	
		
	MFI->(DbGoTo(nRecno))
	If MFI->(!EOF())
		MFI->(RecLock("MFI",.F.))
		
		If !Empty(cErro)
			MFI->MFI_SITGAR := Iif(MFI->MFI_SITGAR $ "01|02|03|04" , "03","07")
		EndIf	
				
		MFI->MFI_ERRO  := cErro 
		MFI->(MsUnLock())
		Aadd(aRecno,nRecno)
	Else
    	cMsg+= STR0017+Alltrim(Str(nLin))+CRLF 			
	EndIf
	FT_FSkip()
EndDo

If !lErroArq 
	//Altera os Status dos registros na tabela MFI
	//que nao estava no arquivo texto
	MsgRun( STR0012,,{|| LJ870AtMfi(aRecno,.T.) })//"Aguarde, atualizando tabela de garantia estendida ..."
	
	If !Empty(cMsg)
		cMsg+= STR0028//" - Recno não encontrado na tabela MFI."
		Aviso(STR0025,cMsg,{"Ok"},2,STR0029)//"Atenção"##"Erro ao processar a(s) linhas(s) abaixo:"
	EndIf
EndIf

RestArea(aArea)
Return  

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870HPrSF
Processa o arquivo texto retornado pela seguradora-Servico Finaneiro
@author Varejo
@since 19/08/2014
@version P11
@param 
/*/
//-------------------------------------------------------------------      
Static Function LJ870HPrSF(aRegistro,aCabecalho,aRodape,nHdl,cMG6Erro)

Local aArea		:= GetArea()    	// Posicionamento Atual da tabela
Local cErro  := ''  // Codigo do erro no arquivo
Local cLinha := ''  //Linha do arquivo texto
Local cId    := ''  //Caracter identificador do arquivo
Local nLin   := 0   //Contador
Local nScan  := 0   //Localiza a posicao do campo chave
Local nScanErro:= 0 //Localiza a posicao do campo erro 
Local aSepara:= {}  // Array para funcao Separa
Local aRecnoOK := {} //Recno dos registros encontrados
Local aRecnoER := {} //Recno dos registros encontrados
Local lRodape:= .F. //Valida se no arquivo existe rodape
Local lErroArq := .F.    // Valida se a leitura do arquivo texto foi concluida para gravacao
Local aRecno := {}  // Array de recnos da MFI
Local cRetSep:='' 	// Caracter de retorno
Local cMsg   := '' 	// Mensagem de erros
Local cChave:= ''	// armazena a chave do arquivo texto
Local nPos	:= 0 	// Posicao do Array

Default cMG6Erro := ""

FT_FGOTOP()
nTotReg := FT_FLastRec()
FT_FGOTOP()
    
ProcRegua(nTotReg) 
//Posicao chave no array aRegistro
nScan	 := aScan(aRegistro,{ |x| x[4] == '1' })
nScanErro:= aScan(aRegistro,{ |x| x[6] == '1' })
cId		 := aRegistro[1][5]
cRetSep  := aRegistro[1][7]
//Pula linha do cabecalho  
If !Empty(aCabecalho)
	FT_FSkip()		
	nLin++ 
EndIf
//Validacao se existe rodape 
If !Empty(aRodape)
	lRodape:= .T.
EndIf
While !FT_FEOF()
	nLin++  
	
	IncProc(STR0017+Alltrim(Str(nLin)) )	//"Linha: "
	
	If nLin == nTotReg
		If lRodape
			Exit
		EndIf	
	EndIf         
	cLinha := FT_FReadLn()	
	cLinha := StrTran(cLinha,cRetSep,cId)
	If !Empty(cId)				
		aSepara:= Separa(cLinha,cId)  
		If Len(aSepara) < nScanErro .OR. Len(aSepara) < nScan
			lErroArq:= .T.
			Alert(STR0030+CRLF+STR0031)//"Erro !"###"Arquivo texto não esta dentro do layout de importação cadastrado."
			aRecno:={}
			Exit
		EndIf
		
		cErro  := aSepara[nScanErro]
		cChave := aSepara[nScan]
	Else
	   	cChave := SubStr(cLinha,aRegistro[nScan][8],aRegistro[nScan][9]-aRegistro[nScan][8]+1)
    	cErro := SubStr(cLinha,aRegistro[nScanErro][8],aRegistro[nScanErro][9]-aRegistro[nScanErro][8]+1)
	EndIf
	
	//Valida codigo do registro
	MFI->(DbSetOrder(5)) //Filial + Codigo
	
	If MFI->(DbSeek(xFilial("MFI") + cChave))
		//Adiciona Recnos para atualizacao
		Aadd(aRecno,MFI->(Recno()))
		If EMPTY(cErro)
			Aadd( aRecnoOK,MFI->(Recno()) )
		Else
			Aadd( aRecnoER,{MFI->(Recno()),cErro} )
		EndIF
	Else				
		//Adiciona Recno para atualizacao					
		Aadd(aRecno,MFI->(Recno()))
		cMsg+= STR0017+Alltrim(Str(nLin))+CRLF	//"Linha:"
	EndIf
	
	FT_FSkip()
EndDo	

//Altera Status de registros nao encontrados no lote
MFI->(DbSetOrder(3)) //Filial + Num.Lote
	
If MFI->(DbSeek(xFilial("MFI") + MV_PAR01))
	While MFI->(!EOF()) .AND. MFI->(MFI_FILIAL + MFI_NUMLOT) == xFilial("MFI") + MV_PAR01
		//Nao encontrou o registro
		If ( nPos := aScan(aRecnoER,{ |x| x[01] == MFI->(Recno())}) ) > 0
			//Altera status do registro
			MFI->(RecLock("MFI",.F.))
			MFI->MFI_SITGAR	:= Iif(MFI->MFI_SITGAR $ "01|02|03|04", "03","07")
			If ( nPos := aScan(aRecnoER,{ |x| x[01] == MFI->(Recno())}) ) == 0
				MFI->MFI_ERRO  	:= STR0033 //"ERR"
			Else
				DbSelectArea('MFO')
				MFO->(DbSetOrder(1)) //MFO_FILIAL+MFO_CODIGO
				If MFO->(DbSeek(xFilial("MFO") + aRecnoER[nPos][02]))
					MFI->MFI_ERRO  	:= MFO->MFO_CODIGO
				Else
					MFI->MFI_ERRO  	:= STR0033 //"ERR"
				EndIf
			EndIf
			MFI->(MsUnLock())
		EndIf
										
		MFI->(dbSkip())
	EndDo		
EndIf    	

If !lErroArq 
	//Altera os Status dos registros na tabela MFI
	//que nao estava no arquivo texto
	MsgRun( STR0012,,{|| LJ870AtMfi(aRecnoOK,.T.) })//"Aguarde, atualizando tabela de garantia estendida ..."
	
	If !Empty(cMsg)
		cMsg+= STR0028 //" - Resgistro(s) não encontrado na tabela MFI."
		Aviso(STR0025,cMsg,{STR0032},2,STR0029)//"Atenção"##"Erro ao processar a(s) linhas(s) abaixo:" #"Ok"
	EndIf
EndIf

RestArea(aArea)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870AtMfi
Atualiza tabela MFI para os registros que nao deram erro.
@author Varejo
@since 28/05/2013
@version P11
@param cArquivo - diretorio para criacao do arquivo
/*/
//-------------------------------------------------------------------      
Static Function LJ870AtMfi(aRecno,lRecno)

Local aArea		:= GetArea()    	// Posicionamento Atual da tabela
Local aFinDel		:= {}				// Array com os titulos provisorios que devem ser deletados.
Local nI			:= 0				// Contador

Default aRecno := {}     // Recno da tabela MFI
Default lRecno :=.F.

If Empty(aRecno) .AND. !lRecno
	MFI->(DbSetOrder(3))
	If MFI->( DbSeek(xFilial("MFI")+MV_PAR01) )
		While MFI->MFI_FILIAL+MFI->MFI_NUMLOT == xFilial("MFI")+MV_PAR01
			If Empty(MFI->MFI_GARANT)
				If !MFI->MFI_SITGAR $ "03|07" .OR. Empty(aRecno)
					MFI->(RecLock("MFI",.F.))
					MFI->MFI_SITGAR:= Iif(MFI->MFI_SITGAR $ "01|02|03|04", "02","06")
					MFI->(MsUnLock())
					
					If MFI->MFI_SITGAR == '06'
						Aadd(aFinDel,{MFI->MFI_FILORI,MFI->MFI_PREFIX,MFI->MFI_TITULO,MFI->MFI_PARCEL,MFI->MFI_TIPO,MFI->MFI_FORNEC,MFI->MFI_LJFORN} )
					EndIf
				EndIf
			EndIf
			MFI->(DbSkip())
		EndDo
	EndIf
Else
	For nI:= 1 To Len(aRecno)
		MFI->(DbGoTo(aRecno[nI]))
		If !MFI->MFI_SITGAR $ "03|07" .OR. Empty(aRecno)
			MFI->(RecLock("MFI",.F.))
			MFI->MFI_SITGAR:= Iif(MFI->MFI_SITGAR $ "01|02|03|04", "02","06")		
			MFI->(MsUnLock())
		EndIf

		If MFI->MFI_SITGAR == '06'
			Aadd(aFinDel,{MFI->MFI_FILORI,MFI->MFI_PREFIX,MFI->MFI_TITULO,MFI->MFI_PARCEL,MFI->MFI_TIPO,MFI->MFI_FORNEC,MFI->MFI_LJFORN} )
		EndIf
	Next nI
EndIf
If !Empty(aFinDel)
	//Deleta os registros provisórios que foram aprovados o cancelamento pela administradora financeira
	Lj870HDelFin(aFinDel)
EndIf

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870HDelFin
Deleta os registros provisórios que foram aprovados o cancelamento pela administradora financeira
@author Varejo
@since 28/05/2013
@version P11
@param aFinDel - Array com informacoes do titulo provisório.		
/*/
//-------------------------------------------------------------------      
Function Lj870HDelFin(aFinDel)

Local aArea		:= GetArea()    	// Posicionamento Atual da tabela
Local nI			:= 1				// Contador                        
Local cMsg			:= ''				// Mensagem para Aviso

Private lMsErroAuto:= .F.			// Determina se houve algum tipo de erro durante a execucao do ExecAuto 

SE2->(DbSetOrder(1))
For nI:= 1 To Len(aFinDel)
	If  SE2->(DbSeek(aFinDel[nI][1]+aFinDel[nI][2]+aFinDel[nI][3]+aFinDel[nI][4]+;
					 aFinDel[nI][5]+aFinDel[nI][6]+aFinDel[nI][7]))
		aArray := { { "E2_PREFIXO"  ,SE2->E2_PREFIXO , NIL },;
		            { "E2_NUM"      ,SE2->E2_NUM     , NIL }}			 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz a exclusao do contas a pagar via ExecAuto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MSExecAuto({|x,y,z| Fina050(x,y,z)},aArray,,5)
		If lMsErroAuto
		    MostraErro()
		Else		
			cMsg+= STR0023+aFinDel[nI][2]+STR0024+aFinDel[nI][3]+CRLF//"Prefixo : "##" Numero : "
		EndIf
	EndIf
Next nI	 

If !Empty(cMsg)
	Aviso(STR0025,cMsg,{"Ok"},2,STR0026)//"Atenção"##"Titulos Provisorios excluidos com sucesso."
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870HLote
Efetua a validação do lote e se o arquivo ja foi gerado.
@author Varejo
@since 28/05/2013
@version P11
@param cArquivo - diretorio para criacao do arquivo
/*/
//-------------------------------------------------------------------      
Static Function LJ870HLote(cArquivo)

Local aArea	:= GetArea()			// Posicionamento Atual da tabela
Local lRet 	:= .F.					// Variável de retorno

DbSelectArea('MFI')
DbSetOrder(3)
If DbSeek(xFilial("MFI")+MV_PAR01)
	lRet:= .T.		
Else
	MsgInfo(STR0018,STR0015)	//"O numero de lote informado ainda não foi gerado." ##"Atencao"
EndIf


RestArea(aArea)
Return lRet

