#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "LOJA870C.ch"

Static nTotReg 	:= 0  // totalizador de registros
Static cAliasTrb:= '' // totalizador de registros
Static nRecno   := 0  // Recno da tabela mfi
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA870C
Efetua a exportacao de dados via arquivo texto, conforme configurado. 
no cadastro de linhas.
@author Varejo
@since 28/05/2013
@version P10
/*/
//-------------------------------------------------------------------
Function LOJA870C(cFiltro)

Local aArea		:= GetArea()    	// Posicionamento Atual da tabela
Local cPerg		:= ""			  	// Grupo de pergunta no SX1
Local cArquivo	:= ''            	// cAMINHO DO ARQUIVO TXT
Local cExtensao := "txt"        	// Extensao do arquivo
Local cTipoArq 	:= STR0001			// "Todos os Arquivos (*.*)     | *.* |"
Local cDir      := ''             	// Diretório do arquivo
Local cPath     := '' 				// Diretório do arquivo
Local oDlg		:= Nil					// Objeto para diálogo

Default cFiltro:= "GE"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria tela para informar os parametros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg := IIF( cFiltro=="GE",PadR("LOJA870C",10),PadR("LOJA871C",10) )

If Pergunte(cPerg,.T.,STR0002) //"Geração de arquivo texto"
	
	//+-----------------------------------+ 
	//| Montagem da tela de processamento.| 
	//+-----------------------------------+ 
	 
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0002) ; //"Geração de arquivo texto"
	FROM 000,000 TO 200,400 PIXEL 
		 
	@ 005,005 TO 095,195 OF oDlg PIXEL 
	@ 010,020 Say STR0003 OF oDlg PIXEL //" Este programa ira gerar um arquivo TXT, para exportação"
	@ 018,020 Say STR0004 OF oDlg PIXEL //" de informações conforme cofigurado no cadastro de linhas."

	TBtnBmp2():New(075,320,026,026,"SDUOPEN",,,,;
			{|| cPath := cGetFile(cTipoArq,STR0005,0,cDir,;
									.T.,GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_RETDIRECTORY, .F.),;
									 cDir := Iif(Empty(cPath), cDir, cPath),;
									 cArquivo := PadR(cDir + ALLTRIM(MV_PAR04)+"."+AllTrim(cExtensao), 250)},;
									 oDlg,STR0006)//"Selecione o diretório de destino"#"Pesquisa local de destino"	
	TGet():New(40,008,bSetGet(cArquivo),oDlg,;
									150,010,,,;
									,,,,;
									,.T.,,;
									,,,,;
									,.T.)
		
	DEFINE SBUTTON FROM 070, 030 TYPE 1 ; 
	ACTION ( IIF(Empty(cArquivo),Alert(STR0007),; //"Informe o diretório !"
		( IIF(cFiltro=="GE",GerArq(cArquivo,cFiltro),LJ870ASF(cArquivo,cFiltro,cExtensao)),;
		oDlg:End() ) ) ) ENABLE OF oDlg
		 
	DEFINE SBUTTON FROM 070, 070 TYPE 2 ; 
	ACTION (oDlg:End()) ENABLE OF oDlg 
		
	DEFINE SBUTTON FROM 070, 110 TYPE 5 ; 
	ACTION (Pergunte(cPerg, .T.)) ENABLE OF oDlg 	
	
	ACTIVATE DIALOG oDlg CENTERED 

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zerar todas as variaveis staticas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotReg  := 0
cAliasTrb:= ''
nRecno   := 0

RestArea(aArea)
Return()
                                                                   
//-------------------------------------------------------------------
/*/{Protheus.doc} LJ870ASF
Gera arquivo texto pelo Grupo de Layout.
@author Varejo
@since 28/05/2013
@version P11
@param cArquivo - diretorio para criacao do arquivo
@param cFltro - Estabelece diferenciacao entre Garantia (GE) e Servico (SF)
/*/
//------------------------------------------------------------------- 
Function LJ870ASF(cArquivo,cFiltro,cExtensao,cLote,;
					cCodServ)

Local aArea		:= GetArea()  // Posicionamento atual da tabela
Local cCampoTrb := '' // ALIAS TEMPORARIO
Local cDelimit  := '' // Caracter delimitador
Local aRegistro := {} // array bidimencional para registro.
Local aCabecalho:= {} // array bidimencional para o cabecalho.
Local aRodape   := {} // array bidimencional para o rodape.
Local nHdl      := 0  // Handle do arquivo
Local nX        := 1 // contador
Local lRet      := .F. // variavel de retorno logico
Local aArqAux	:= ""	//Arquivo Auxiliar
Local lAjuste	:= .F. //Define chamada da função pela rotina de Ajuste

Default cArquivo		:= ""				// Arquivo
Default cFiltro		:= ""				// Filtro
Default cExtensao		:= "txt"        	// Extensao do arquivo
Default cLote			:= ""				// Lote
Default cCodServ		:= ""				// Codigo do Serviço

If !EMPTY(cCodServ)
	MV_PAR03 := cCodServ
EndIF
If !EMPTY(cLote)
	MV_PAR04 := cLote
EndIF
lAjuste := !EMPTY(cCodServ+cLote)

Begin Transaction 
                     
DbSelectArea("MG8")
MG8->(DbSetOrder(1))
If dbSeek(xFilial("MG8")+MV_PAR03,.T.)
	// VERIFICA SE A ADM. FINANCEIRA ESTA VINCULADO A UM GRUPO DE LAYOUT
	DbSelectArea("MG6")
	MG6->(DbSetOrder(1))
	If !EMPTY(MG8->MG8_GRPLAY) .AND. dbSeek(xFilial("MG6")+MG8->MG8_GRPLAY,.T.)
		//Valida se o lote ja foi gerado.
		If VldLote(aArqAux,cFiltro,lAjuste)		
	   		While MG6->(!EOF()) .AND. xFilial("MG6")+MG8->MG8_GRPLAY == MG6->MG6_FILIAL+MG6->MG6_CODIGO			
				aArqAux := SUBSTR(cArquivo,1, RAT("."+cExtensao,cArquivo)-1 ) +"_"+ AllTrim(MG6->MG6_LAYOUT) +"."+ cExtensao
								
			   	// VERIFICA SE O GRUPO LAYOUT ESTA VINCULADO A UM OU MAIS LAYOUT
				DbSelectArea("MFG")
				MFG->(DbSetOrder(1))
				If !EMPTY(MG6->MG6_LAYOUT) .AND. MFG->(DbSeek(xFilial("MFG")+MG6->MG6_LAYOUT))
					While MFG->(!EOF())
						If MFG->MFG_TIPLAY <> "1"
			    			MFG->(dbSkip())
							Loop
						EndIf
						
						//Cria o arquivo txt.
						nHdl:= fCreate(aArqAux)
						
						//Verifica se o Layout esta vinculado a um bloco
						DbSelectArea("MFF")
						MFF->(DbSetOrder(1))
						If MFF->(DbSeek(xFilial("MFF")+ MFG->MFG_CODBLO ))
							//Verifica se o cabecalho, registro e rodape que foram vinculados ao bloco
							// Cabecalho
							MFE->(DbSetOrder(1))
							MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_CABECA,.T. ))
							While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_CABECA
								If !EMPTY(MFE->MFE_ALIAS)
									aadd(aCabecalho, {.T. ,MFE->MFE_ALIAS+"."+MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
								Else	
									aadd(aCabecalho, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
								EndIf
								MFE->(DbSkip())
							EndDo 
							For nX:= 1 To Len(aCabecalho)
								//Monta os campos do select na variavel
								If aCabecalho[nX][1] .AND. !aCabecalho[nX][2] $ cCampoTrb
									cCampoTrb+= aCabecalho[nX][2]+","
									aCabecalho[nX][2]:= SubStr(aCabecalho[nX][2],5,TamSx3("MFE_CAMPO")[1])
								Else
									aCabecalho[nX][2]:= SubStr(aCabecalho[nX][2],5,TamSx3("MFE_CAMPO")[1])
								EndIf
							Next nX
							// Registro
							MFE->(DbSetOrder(1))
							MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_REGIST,.T. ))
							While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_REGIST
								cDelimit := MFE->MFE_CARACT
								If !EMPTY(MFE->MFE_ALIAS)
									aadd(aRegistro, {.T. ,MFE->MFE_ALIAS+"."+MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN,MFE->MFE_CHAVE} )
								Else
									aadd(aRegistro, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN,MFE->MFE_CHAVE} )
								EndIf
								MFE->(DbSkip())
							EndDo  
							For nX:= 1 To Len(aRegistro)
								//Monta os campos do select na variavel
								If aRegistro[nX][1] .AND. !aRegistro[nX][2] $ cCampoTrb
									cCampoTrb+= aRegistro[nX][2]+","
									aRegistro[nX][2]:= SubStr(aRegistro[nX][2],5,TamSx3("MFE_CAMPO")[1])
								Else
									aRegistro[nX][2]:= SubStr(aRegistro[nX][2],5,TamSx3("MFE_CAMPO")[1])
								EndIf
							Next nX
							// Rodape
							MFE->(DbSetOrder(1))
							MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_RODAPE,.T. ))
							While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_RODAPE
								If !EMPTY(MFE->MFE_ALIAS)
									aadd(aRodape, {.T. ,MFE->MFE_ALIAS+"."+MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
								Else
									aadd(aRodape, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
								EndIf
								MFE->(DbSkip())
							EndDo
							
							For nX:= 1 To Len(aRodape)
								//Monta os campos do select na variavel
								If aRodape[nX][1] .AND. !aRodape[nX][2] $ cCampoTrb
									cCampoTrb+= aRodape[nX][2]+","
									aRodape[nX][2]:= SubStr(aRodape[nX][2],5,TamSx3("MFE_CAMPO")[1])
								Else
									aRodape[nX][2]:= SubStr(aRodape[nX][2],5,TamSx3("MFE_CAMPO")[1])
								EndIf
							Next nX
							//Pega Alias valido
							cAliasTrb:= GetNextAlias()
							//Efetua a consulta no banco de dados de acordo com os campos obtidos no cadastro de linhas
							MsgRun(STR0008 ,, { || FilTxt(cCampoTrb,cFiltro,MG8->MG8_ADMIN,lAjuste,cLote) })//"Aguarde, consultando dados ..."
							If (cAliasTrb)->(!EOF())
								Processa({|| lRet:= Lj870Txt(aArqAux,aRegistro,aCabecalho,aRodape,cAliasTrb,;
															 @nHdl,MV_PAR04,,cDelimit,cFiltro,lAjuste) },STR0009)//"Gerando arquivo texto..."//
								
							Else
								MsgInfo(STR0010,STR0011)//"Não existem dados, verifique os parâmetros."#//"Atenção"
								lRet:= .F.
								
							EndIf
							(cAliasTrb)->(DbCloseArea())		
						
						EndIf
						MFG->(dbSkip())

						If nHdl > 0
							fClose(nHdl)
						EndIf
					EndDo
				Else		
					MsgInfo(STR0047,STR0011)//"Layout não existe ou não esta cadastrado para Administradora financeira"###"Atenção"			
				EndIf
				
				cCampoTrb	:= ''
				cAliasTrb	:= ''
				aRegistro	:= {}
				aCabecalho	:= {}
				aRodape   	:= {}
						
				MG6->(DbSkip())	
			EndDo
		EndIf
	Else
		MsgInfo(STR0050,STR0011) //"Grupo de layout não encontrado."###"Atenção"
	EndIf
Else
	MsgInfo(STR0049,STR0011) //"Serviço financeiro não existe."###"Atenção"
EndIf	

If lRet
	MsgInfo(STR0012,STR0011)//"Arquivo texto gerado com sucesso!"
EndIf
	
End Transaction	

RestArea(aArea)
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GerArq
Gera arquivo texto.
@author Varejo
@since 28/05/2013
@version P11
@param cArquivo - diretorio para criacao do arquivo
@param cFltro - Estabelece diferenciacao entre Garantia (GE) e Servico (SF)
/*/
//------------------------------------------------------------------- 
Static Function GerArq(cArquivo,cFiltro)

Local aArea     := GetArea()    	// Posicionamento Atual da tabela
Local cCampoTrb := '' // ALIAS TEMPORARIO
Local cDelimit  := '' // Caracter delimitador
Local aRegistro := {} // array bidimencional para registro.
Local aCabecalho:= {} // array bidimencional para o cabecalho.
Local aRodape   := {} // array bidimencional para o rodape.
Local nHdl      := 0  // Handle do arquivo
Local nX        := 1 // contador
Local lRet      := .F. // variavel de retorno logico

Default cArquivo	:= ""
Default cFiltro	:= ""

Begin Transaction                     
 
If VldLote(cArquivo,cFiltro)	
	//Cria o arquivo txt.
	nHdl:= fCreate(cArquivo)
	
	DbSelectArea("SAE")
	dbGoTop()
	dbSetOrder(1)
	If dbSeek(xFilial("SAE")+MV_PAR03,.T.)
	   	// VERIFICA SE A ADM. FINANCEIRA ESTA VINCULADO A UM LAYOUT
		MFG->(DbSetOrder(1))
		If !EMPTY(SAE->AE_LAYOUT) .AND. MFG->(DbSeek(xFilial("MFG")+ SAE->AE_LAYOUT))
			//Verifica se o Layout esta vinculado a um bloco
			MFF->(DbSetOrder(1))		 
			If MFF->(DbSeek(xFilial("MFF")+ MFG->MFG_CODBLO ))
				//Verifica se o cabecalho, registro e rodape que foram vinculados ao bloco
				// Cabecalho
				MFE->(DbSetOrder(1))
				MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_CABECA,.T. ))
				While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_CABECA
					If !EMPTY(MFE->MFE_ALIAS)
						aadd(aCabecalho, {.T. ,MFE->MFE_ALIAS+"."+MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
					Else	
						aadd(aCabecalho, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
					EndIf	
					MFE->(DbSkip())			
				EndDo 
				For nX:= 1 To Len(aCabecalho)
					//Monta os campos do select na variavel
					If aCabecalho[nX][1] .AND. !aCabecalho[nX][2] $ cCampoTrb		
						cCampoTrb+= aCabecalho[nX][2]+","	 						
						aCabecalho[nX][2]:= SubStr(aCabecalho[nX][2],5,TamSx3("MFE_CAMPO")[1])
					Else	
						aCabecalho[nX][2]:= SubStr(aCabecalho[nX][2],5,TamSx3("MFE_CAMPO")[1])
					EndIf
				Next nX				 
				// Registro
				MFE->(DbSetOrder(1))
				MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_REGIST,.T. ))			
				While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_REGIST
					cDelimit := MFE->MFE_CARACT
					If !EMPTY(MFE->MFE_ALIAS)
						aadd(aRegistro, {.T. ,MFE->MFE_ALIAS+"."+MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN,MFE->MFE_CHAVE} )
					Else	
						aadd(aRegistro, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN,MFE->MFE_CHAVE} )
					EndIf	
					MFE->(DbSkip())			
				EndDo  
				For nX:= 1 To Len(aRegistro)
					//Monta os campos do select na variavel
					If aRegistro[nX][1] .AND. !aRegistro[nX][2] $ cCampoTrb	
						cCampoTrb+= aRegistro[nX][2]+","	 						
						aRegistro[nX][2]:= SubStr(aRegistro[nX][2],5,TamSx3("MFE_CAMPO")[1])
					Else
						aRegistro[nX][2]:= SubStr(aRegistro[nX][2],5,TamSx3("MFE_CAMPO")[1])
					EndIf
				Next nX							
				// Rodape
				MFE->(DbSetOrder(1))
				MFE->(DbSeek(xFilial("MFE")+ MFF->MFF_RODAPE,.T. ))			
				While MFE->(!EOF()) .AND. MFE->MFE_CODIGO == MFF->MFF_RODAPE
					If !EMPTY(MFE->MFE_ALIAS)
						aadd(aRodape, {.T. ,MFE->MFE_ALIAS+"."+MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
					Else	
						aadd(aRodape, {.F. ,MFE->MFE_CAMPO,Alltrim(MFE->MFE_FORMUL),MFE->MFE_COLINI,MFE->MFE_COLFIN} )
					EndIf	
					MFE->(DbSkip())			
				EndDo				
				For nX:= 1 To Len(aRodape)
					//Monta os campos do select na variavel
					If aRodape[nX][1] .AND. !aRodape[nX][2] $ cCampoTrb	
						cCampoTrb+= aRodape[nX][2]+","	 						
						aRodape[nX][2]:= SubStr(aRodape[nX][2],5,TamSx3("MFE_CAMPO")[1])
					Else
						aRodape[nX][2]:= SubStr(aRodape[nX][2],5,TamSx3("MFE_CAMPO")[1])	
					EndIf
				Next nX	
				//Pega Alias valido
				cAliasTrb:= GetNextAlias()
				//Efetua a consulta no banco de dados de acordo com os campos obtidos no cadastro de linhas
				MsgRun(STR0008 ,, { || FilTxt(cCampoTrb,cFiltro) })//"Aguarde, consultando dados ..."
				If (cAliasTrb)->(!EOF())
					Processa({|| lRet:= Lj870Txt(cArquivo,aRegistro,aCabecalho,aRodape,cAliasTrb,;
												 @nHdl,MV_PAR04,,cDelimit,cFiltro) },STR0009)//"Gerando arquivo texto..."//

				Else
					MsgInfo(STR0010,STR0011)//"Não a dados, verifique os parâmetros"#//"Atenção"
					lRet:= .F.

				EndIf
				(cAliasTrb)->(DbCloseArea())		
			EndIf
		Else		
			MsgInfo(STR0047,STR0011)//"Layout não existe ou não esta cadastrado para Administradora financeira"###"Atenção"			
		EndIf
		
		cCampoTrb:= ''
		cAliasTrb:= ''
		aRegistro:={}
	Else
		MsgInfo(STR0048,STR0011) //"Administradora financeira não existe."###"Atenção"
	EndIf	
	
	If lRet
		MsgInfo(STR0012,STR0011)//"Arquivo texto gerado com sucesso!"
	EndIf
	
EndIf
		
End Transaction


If nHdl>0
	fClose(nHdl)	
EndIf	
 
RestArea(aArea)
Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} FilTxt
Efetua a extracao de dados para gerar o arquivo texto.
@author Varejo
@since 28/05/2013
@version P11
@param cCampoTrb - Campos do select
/*/
//------------------------------------------------------------------- 
Static Function FilTxt(cCampoTrb,cFiltro,cAdmin,lAjuste,cLote)

Local aArea    := GetArea()    			// Posicionamento Atual da tabela
Local cQuery   := ''						// Query SQL
Local dDtIni   := CTOD("  /  /  ")		// Data Inicial
Local dDtFim   := CTOD("  /  /  ")		// Data Final

Default cCampoTrb		:= '' 
Default cFiltro		:= ""
Default cAdmin		:= ""
Default lAjuste 		:= .F.
Default cLote 		:= ""

MFH->(DbSetOrder(1))
If MFH->(DbSeek(xFilial("MFH")+MV_PAR04))
	dDtIni := MFH->MFH_DTINI
	dDtFim := MFH->MFH_DTFIM
EndIf

//Ajuste para armazenar Nro. Lote no Arquivo temporario caso faca parte da consulta
cCampoTrb := StrTran(cCampoTrb, "MFI.MFI_NUMLOT", "'" + MV_PAR04 + "' MFI_NUMLOT")

cQuery+= " SELECT "+cCampoTrb+"MFI_CODIGO,MFI_PRODUT,MFI_DESCRI,MFI_VLRITE,MFI.MFI_FILORI,MFI.MFI_DOC,MFI.MFI_SERIE,MFI.MFI_GARANT,MFI.R_E_C_N_O_ RECNOMFI FROM "+RetSqlName("MFI")+" MFI"+CRLF
// -- CABECALHO ORCAMENTO
cQuery+= " INNER JOIN "+RetSqlName("SL1")+" SL1"+CRLF
cQuery+= " ON SL1.L1_FILIAL = MFI.MFI_FILORI "+CRLF
cQuery+= " AND SL1.L1_NUM = MFI.MFI_NUM "+CRLF
cQuery+= " AND SL1.D_E_L_E_T_ <> '*' "+CRLF
// -- ITENS ORCAMENTO
cQuery+= " INNER JOIN "+RetSqlName("SL2")+" SL2"+CRLF
cQuery+= " ON SL2.L2_FILIAL = MFI.MFI_FILORI "+CRLF
cQuery+= " AND SL2.L2_NUM = MFI.MFI_NUM "+CRLF
cQuery+= " AND SL2.L2_PRODUTO = MFI.MFI_PRODUT "+CRLF
cQuery+= " AND SL2.L2_ITEM = MFI.MFI_ITEM "+CRLF
cQuery+= " AND SL2.D_E_L_E_T_ <> '*' "+CRLF
// -- CABECALHO ORCAMENTO
cQuery+= " LEFT JOIN "+RetSqlName("SL4")+" SL4"+CRLF
cQuery+= " ON SL4.L4_FILIAL = MFI.MFI_FILORI "+CRLF
cQuery+= " AND SL4.L4_NUM = MFI.MFI_NUM "+CRLF
cQuery+= " AND SL4.L4_ITEM = MFI.MFI_ITEM "+CRLF
cQuery+= " AND SL1.D_E_L_E_T_ <> '*' "+CRLF
// -- CLIENTE 
cQuery+= " INNER JOIN "+RetSqlName("SA1")+" SA1"+CRLF
cQuery+= " ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+CRLF
cQuery+= " AND SA1.A1_COD  = SL1.L1_CLIENTE "+CRLF
cQuery+= " AND SA1.A1_LOJA = SL1.L1_LOJA "+CRLF
cQuery+= " AND SA1.D_E_L_E_T_  <> '*' "+CRLF
// -- PRODUTOS
cQuery+= " INNER JOIN "+RetSqlName("SB1")+" SB1"+CRLF
cQuery+= " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
cQuery+= " AND SB1.B1_COD = MFI.MFI_PRODUT"+CRLF
cQuery+= " AND SB1.D_E_L_E_T_ <> '*' "+CRLF
// -- SERVICO FINANCEIRO
If cFiltro == "SF" .AND. !Empty(MV_PAR03)
	cQuery+= " INNER JOIN "+RetSqlName("MG8")+" MG8"+CRLF
	cQuery+= " ON MG8.MG8_FILIAL = '"+xFilial("MG8")+"' "+CRLF
	cQuery+= " AND MG8.MG8_CODIGO = '"+MV_PAR03+"' "+CRLF
	cQuery+= " AND MG8.MG8_PRDSB1 = MFI.MFI_PRODUT"+CRLF
	cQuery+= " AND MG8.D_E_L_E_T_ <> '*' "+CRLF
EndIf
// -- CONDICAO ITENS ORCAMENTO 
cQuery+= " WHERE "+CRLF
If cFiltro == "SF" 
	If lAjuste
		cQuery+= " MFI.MFI_FILORI BETWEEN '"+cFilant+"' AND '"+cFilant+"' "+CRLF
		cQuery+= " AND MFI.MFI_EMISSA  BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFim)+"' "+CRLF
		cQuery+= " AND MFI.MFI_NUMLOT = '"+cLote+"' "+CRLF
		cQuery+= " AND MFI_SITGAR IN ('03','07') "+CRLF
	Else
		cQuery+= " MFI.MFI_FILORI BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
		cQuery+= " AND MFI.MFI_EMISSA  BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFim)+"' "+CRLF
		cQuery+= " AND MFI.MFI_NUMLOT = '"+Space(TamSx3("MFI_GARANT")[1])+"' "+CRLF
		cQuery+= " AND MFI_SITGAR IN ('04','08') "+CRLF
	EndIf
Else
	cQuery+= " MFI.MFI_FILORI BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
	cQuery+= " AND MFI.MFI_EMISSA  BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFim)+"' "+CRLF
	cQuery+= " AND MFI.MFI_NUMLOT = '"+Space(TamSx3("MFI_GARANT")[1])+"' "+CRLF
	cQuery+= " AND MFI_SITGAR IN ('06','08') "+CRLF
EndIf
cQuery+= " AND MFI_GARANT = '"+Padr("",TamSx3("MFI_GARANT")[1] )+"'
If cFiltro == "GE"
	cQuery+= " AND MFI.MFI_ADMIN IN('"+MV_PAR03+"') "
Else
	cQuery+= " AND MFI.MFI_ADMIN IN('"+cAdmin+"') "
EndIf
cQuery+= " AND MFI_ORIGEM = '"+cFiltro+"' "
cQuery+= " AND MFI.D_E_L_E_T_ <> '*' "+CRLF
 
cQuery:= ChangeQuery(cQuery) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAliasTrb) > 0
	(cAliasTrb)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTrb, .F., .T.)
 
RestArea(aArea)
Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870Txt
Efetua a escrita no arquivo texto, conforme os dados obtidos na consulta ao banco de dados.
@author Varejo
@since 28/05/2013
@version P11
@param cArquivo   - diretorio para criacao do arquivo
	   aRegistro  - Contem os campos para os registros
       aCabecalho - Contem os campos para o cabecalho
       aRodape    - Contem os campos para o rodape
       cAliasTrb  - Alias para tabela temporaria
       nHdl       - Identificador do arquivo texto
       cNumLote   - Numero de lote
/*/
//------------------------------------------------------------------- 
Function Lj870Txt(cArquivo,aRegistro,aCabecalho,aRodape,;
                   cAliasTrb,nHdl,cNumLote,lStatus,;
                   cDelimit,cFiltro,lAjuste)

Local aArea     := GetArea()    	// Posicionamento Atual da tabela
Local nX        := 0 // contador
Local cLin		:= ""// efetua a escrita no aquivo texto 
Local aRecnos   := {} // recno da tabela MFI
Local lRet      := .T. // variavel de retorno logico
Local nChave	:= aScan(aRegistro,{ |x| x[6] == '1' })   //armazena a posicao chave

Default cArquivo		:= ""
Default aRegistro		:= {}
Default aCabecalho	:= {}
Default aRodape		:= {}
Default cAliasTrb		:= ""
Default nHdl			:= 0
Default cNumLote		:= ""
Default lStatus		:= .F.
Default cDelimit		:= ""
Default cFiltro		:= ""
Default lAjuste		:= .F.

(cAliasTrb)->(DBGotop())
Count To nTotReg
(cAliasTrb)->(DBGotop())
ProcRegua(nTotReg)

nRecno := (cAliasTrb)->RECNOMFI

If nHdl == -1
	MsgAlert(STR0013+AllTrim(cNumLote)+STR0014,STR0011)//"O arquivo de nome "#".txt nao pode ser executado! Verifique os parametros."
	Return .F.
Endif  
//Efetua a escrita do cabecalho do arquivo
If !Empty(aCabecalho)
	For nX:= 1 To Len(aCabecalho)
		If !Empty(aCabecalho[nX][3])		
			If ValType(&(aCabecalho[nX][3])) == 'U'
				MsgAlert(STR0044+Alltrim(aCabecalho[nX][3]),STR0011) //"Corrija o campo Formula do cabecalho: "
				Return .F.				
			ElseIf ValType(&(aCabecalho[nX][3])) == 'C'
				If !Empty(cDelimit)
					cLin+= &(Alltrim(aCabecalho[nX][3]))+cDelimit		
				Else	                  				
					cLin+= PadR(&(Alltrim(aCabecalho[nX][3])),aCabecalho[nX][5]-aCabecalho[nX][4]+1)
				EndIf	
			ElseIf ValType(&(aCabecalho[nX][3])) == 'N'  
				If !Empty(cDelimit)
					cLin+=  Alltrim(Str( &(aCabecalho[nX][3]) ))+cDelimit
				Else	
					cLin+=  PadR(Alltrim(Str( &(aCabecalho[nX][3]) )),aCabecalho[nX][5]-aCabecalho[nX][4]+1)
				EndIf
			EndIf					
		Else 
			If aCabecalho[nX][1]
				If ValType((cAliasTrb)->&(aCabecalho[nX][2])) == 'N'
					If !Empty(cDelimit)
						cLin+=  Alltrim(Str((cAliasTrb)->&(aCabecalho[nX][2])))+cDelimit
					Else	
						cLin+=  PadR(Alltrim(Str((cAliasTrb)->&(aCabecalho[nX][2]))),aCabecalho[nX][5]-aCabecalho[nX][4]+1)
					EndIf	
				Else				
					If !Empty(cDelimit)					
						cLin+= Alltrim((cAliasTrb)->&(aCabecalho[nX][2]))+cDelimit
					Else	
					 	cLin+= PadR( Alltrim((cAliasTrb)->&(aCabecalho[nX][2])),aCabecalho[nX][5]-aCabecalho[nX][4]+1)
					EndIf	
				EndIf			
			Else
				If !Empty(cDelimit)
					cLin+= Alltrim(aCabecalho[nX][2])+cDelimit		
				Else	
					cLin+= PadR( Alltrim(aCabecalho[nX][2]) ,aCabecalho[nX][5]-aCabecalho[nX][4]+1)	
				EndIf	
			EndIf	
		EndIf
		
	Next nX
EndIf
//Pula linha do cabecalho
If !Empty(cLin)
	cLin+= CRLF		
EndIf  
 
If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin) 
	MsgAlert(STR0015+AllTrim(cNumLote)+STR0016,STR0011)//"Ocorreu erro ao gravar o arquivo de nome "#".txt"#
	lRet:= .F.
	Return lRet
EndIf 
cLin:= ''
//Efetua a escrita dos registros          
While (cAliasTrb)->(!Eof())		
	nRecno := (cAliasTrb)->RECNOMFI	
	IncProc()                     
	If Empty((cAliasTrb)->MFI_GARANT)
		For nX:=1 To Len(aRegistro)     		
			If nChave == nX
				If !Empty(cDelimit)
					cLin+= (cAliasTrb)->MFI_CODIGO+cDelimit
				Else	
					cLin+= PadR(Alltrim((cAliasTrb)->MFI_CODIGO),aRegistro[nX][5]-aRegistro[nX][4]+1)
				EndIf			
				Loop
			EndIf
			If !Empty(aRegistro[nX][3])		
				If ValType(&(aRegistro[nX][3])) == 'U'
					MsgAlert(STR0045+Alltrim(aRegistro[nX][3]),STR0011) //"Corrija o campo Formula do cabecalho: "
					Return .F.				
				ElseIf ValType(&(aRegistro[nX][3])) == 'C'
					If !Empty(cDelimit)
						cLin+= &(Alltrim(aRegistro[nX][3]))+cDelimit		
					Else	
						cLin+= PadR( &( Alltrim(aRegistro[nX][3])),aRegistro[nX][5]-aRegistro[nX][4]+1)	
					EndIf	
				ElseIf ValType(&(aRegistro[nX][3])) == 'N'  
					If !Empty(cDelimit)
						cLin+=  Alltrim(Str( &(aRegistro[nX][3]) ))+cDelimit
					Else	
				   		cLin+=  PadR(Alltrim(Str( &(aRegistro[nX][3]) )),aRegistro[nX][5]-aRegistro[nX][4]+1)		
					EndIf	
				EndIf					
			Else 
				If aRegistro[nX][1]
					If ValType((cAliasTrb)->&(aRegistro[nX][2])) == 'N'
						If !Empty(cDelimit)
							cLin+=  Alltrim(Str((cAliasTrb)->&(aRegistro[nX][2])))+cDelimit
						Else	
							cLin+=  PadR(Alltrim(Str((cAliasTrb)->&(aRegistro[nX][2]))),aRegistro[nX][5]-aRegistro[nX][4]+1)	
						EndIf	
					Else				
						If !Empty(cDelimit)
							cLin+= Alltrim((cAliasTrb)->&(aRegistro[nX][2]))+cDelimit
						Else	
							cLin+= PadR(Alltrim((cAliasTrb)->&(aRegistro[nX][2])),aRegistro[nX][5]-aRegistro[nX][4]+1)
						EndIf	
					EndIf			
				Else         
					If !Empty(cDelimit)
						cLin+= Alltrim(aRegistro[nX][2])+cDelimit		
					Else	
					 	cLin+= PadR(Alltrim(aRegistro[nX][2]),aRegistro[nX][5]-aRegistro[nX][4]+1)	
					EndIf	
				EndIf	
			EndIf		
		Next nX
		cLin+= CRLF	
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin) 
			MsgAlert(STR0015+AllTrim(cNumLote)+STR0016,STR0011)//"Ocorreu erro ao gravar o arquivo de nome "#".txt"#
			lRet:= .F.
			Return lRet
		EndIf 
		aadd(aRecnos,(cAliasTrb)->RECNOMFI)		

	EndIf		
	cLin:= ''	
	(cAliasTrb)->(DbSkip())	
EndDo
 
//Efetua a escrita do rodape do arquivo
(cAliasTrb)->(DBGotop())

If !Empty(aRodape)
	For nX:= 1 To Len(aRodape)
		If !Empty(aRodape[nX][3])		
			If ValType(&(aRodape[nX][3])) == 'U'
				MsgAlert(STR0046+Alltrim(aRodape[nX][3]),STR0011) //"Corrija o campo Formula do rodapé: "
				Return .F.				
			ElseIf ValType(&(aRodape[nX][3])) == 'C'
				If !Empty(cDelimit)
					cLin+= &(Alltrim(aRodape[nX][3]))+cDelimit		
				Else	
					cLin+= PadR( &( Alltrim(aRodape[nX][3]) ),aRodape[nX][5]-aRodape[nX][4]+1)
				EndIf
			ElseIf ValType(&(aRodape[nX][3])) == 'N'  
				If !Empty(cDelimit)
					cLin+=  Alltrim(Str( &(aRodape[nX][3]) ))+cDelimit
				Else	
					cLin+=  PadR(Alltrim(Str( &(aRodape[nX][3]) )),aRodape[nX][5]-aRodape[nX][4]+1)
				EndIf	
			EndIf					
		Else 
			If aRodape[nX][1]
				If ValType((cAliasTrb)->&(aRodape[nX][2])) == 'N'
					If !Empty(cDelimit)
						cLin+=  Alltrim(Str((cAliasTrb)->&(aRodape[nX][2])))+cDelimit
					Else	
						cLin+=  PadR(Alltrim(Str((cAliasTrb)->&(aRodape[nX][2]))),aRodape[nX][5]-aRodape[nX][4]+1)
					EndIf	
				Else	 
					If !Empty(cDelimit)			
						cLin+= Alltrim((cAliasTrb)->&(aRodape[nX][2]))+cDelimit
					Else	
						cLin+= PadR(Alltrim((cAliasTrb)->&(aRodape[nX][2])),aRodape[nX][5]-aRodape[nX][4]+1)
					EndIf	
				EndIf			
			Else
				If !Empty(cDelimit)
					cLin+= Alltrim(aRodape[nX][2])+cDelimit		
				Else	
				 	cLin+= PadR(Alltrim(aRodape[nX][2]),aRodape[nX][5]-aRodape[nX][4]+1)		
				EndIf	
			EndIf	
		EndIf
		
	Next nX
EndIf
   
If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin) 
	MsgAlert(STR0015+AllTrim(cNumLote)+STR0016,STR0011)//"Ocorreu erro ao gravar o arquivo de nome "#".txt"#
	lRet:= .F.
	Return lRet
EndIf 

CursorWait()	
For nX:= 1 To Len(aRecnos)
	MFI->(dbGoTo(aRecnos[nX]))
	MFI->(RecLock("MFI",.F.))
	MFI->MFI_NUMLOT := cNumLote
	If lStatus .OR. lAjuste		
		MFI->MFI_SITGAR := Iif(MFI->MFI_SITGAR $ '03','01','05' )
		MFI->MFI_ERRO   := "  "
	Else
		MFI->MFI_SITGAR := '01'		//"01=Env. Seguradora"
		MFI->MFI_ERRO   := "  "			
	EndIf                                          
	
	MFI->(MsUnLock())
Next Nx
CursorArrow()

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldLote
Efetua a validação do lote e se o arquivo ja foi gerado.
@author Varejo
@since 28/05/2013
@version P11
@param cArquivo - diretorio para criacao do arquivo
/*/
//-------------------------------------------------------------------      
Static Function VldLote(cArquivo,cFiltro,lAjuste)

Local aArea	:= GetArea()  // Posicionamento atual da tabela
Local lRet 	:= .T.       // variavel de retorno logico
Local cQuery:= ''				// Query SQL 
Local cProdServ := ""			//Produto Servico Financeiro        

Default cArquivo	:= ""
Default cFiltro	:= ""
Default lAjuste	:= .F.

// Se estiverem preenchidos, rotina foi chamada pelo Ajuste e não precisará Validar Lote
IF cFiltro == "SF" .AND. lAjuste
	Return lRet
EndIF

DbSelectArea("MFI")
DbSetOrder(3)

//Tratamento para Servicos Financeiros - Filtro produto
If cFiltro == "SF" .AND. !Empty(MV_PAR03)
	MG8->(dbSetOrder(1))
	
	If MG8->(dbSeek(xFilial("MG8") + MV_PAR03))
		cProdServ := MG8->MG8_PRDSB1
	EndIf
EndIf

If DbSeek(xFilial("MFI")+MV_PAR04)
    If MsgYesNo(STR0017)////"O lote informado ja foi gerado, deseja gerar novamente ?"
    	// Apaga os lotes gerados
		cQuery += " UPDATE "+RetSqlName("MFI")+" SET MFI_NUMLOT = '"+Space(TamSx3("MFI_NUMLOT")[1])+"', "
		cQuery += " MFI_SITGAR = CASE MFI_SITGAR WHEN '01' THEN '04' WHEN '05' THEN '08' END"
		cQuery += " WHERE MFI_NUMLOT = '"+MV_PAR04+"' "
		cQuery += " AND MFI_PEDIDO = '"+Space(TamSx3("MFI_PEDIDO")[1])+"' "
		cQuery += " AND MFI_SITGAR ='01'"//04
		cQuery += "  OR MFI_SITGAR = '05'"//08
		cQuery += " AND MFI_ORIGEM = '"+cFiltro+"' "
		
		If cFiltro == "SF" .AND. !Empty(cProdServ)
			cQuery += " WHERE MFI_PRODUT = '"+cProdServ+"' "
		EndIf
				
		cQuery += " AND D_E_L_E_T_ <> '*'
		TCSQLEXEC (cQuery)
        //Exclui arquivo, se existir 
		If File(cArquivo)
			Ferase(cArquivo)
		EndIf
		
	Else
		lRet:= .F.	
	EndIf	
EndIf


RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870CAlias
Retorno a variavel cAliasTrb para ser utilizadas em outras funcoes
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------  
Function Lj870CAlias()
Local cRet:=cAliasTrb
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870CTotR
Retorno a variavel nTotReg para ser utilizadas em outras funcoes
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------  
Function Lj870CTotR()
Local nRet:= nTotReg
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj870CRecno
Retorno a variavel nRecno para ser utilizadas em outras funcoes
@author Varejo
@since 28/05/2013
@version P11
/*/
//-------------------------------------------------------------------  
Function Lj870CRecno()
Local nRet:= nRecno
Return nRet
