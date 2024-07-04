#INCLUDE "MSOLE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "OGR342.CH"

Static __lnewComerc	:= SuperGetMv('MV_AGRA001', , .F.) // Parametro de utilização do novo modelo de comercializaça
Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilizaçao do novo modelo de negocio


/** {Protheus.doc} 
BASEADO NA ROTINA DE INTEGRACAO DO RH - GPEWORD
Rotina de Integracao com MS-Word - **** CONTRATOS

@param: 	cContrato - cTipCtr
@author: 	Ana Laura Olegini
@since: 	29/01/2016
@Uso: 		SIGAAGR
*/ 
Function OGR342(cContrato, cTipCtr)
	//Declaracao de arrays para dimensionar tela		
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}

	Private oDlg		:= NIL
	Private	cPerg		:= ""
	
	Private aInfo		:= {}
	Private nDepen		:= 0
	
	If Empty(cContrato)
		MsgInfo(STR0029)	//"Não foi possível encontrar o contrato!"
		Return
	EndIf
	
	//*=================================================================================
	//* CRIADO UM PERGUNTE PARA CADA TIPO DE CONTRATO PARA SALVAR O CAMINHO DOS ARQUIVOS
	//*=================================================================================
	If cTipCtr == "1" 		//Compra
		cPerg := STR0001 //"OGR342T1"
		//tratando os espacos do novo tamanho do X1_GRUPO
		cPerg := cPerg + (Space( 10  - Len(cPerg) ) )
		Pergunte(cPerg,.F.)
	ElseIf cTipCtr == "2"	//Venda
		cPerg := STR0004	//"OGR342T2"
		//tratando os espacos do novo tamanho do X1_GRUPO
		cPerg := cPerg + (Space( 10  - Len(cPerg) ) )
		Pergunte(cPerg,.F.)		
	ElseIf cTipCtr == "3"	//Armazenagem De 3
		cPerg := STR0005	//"OGR342T3"
		//tratando os espacos do novo tamanho do X1_GRUPO
		cPerg := cPerg + (Space( 10  - Len(cPerg) ) )
		Pergunte(cPerg,.F.)
 	ElseIf cTipCtr == "4"	//Armazenagem Em 3
		cPerg := STR0006	//"OGR342T4"
		//tratando os espacos do novo tamanho do X1_GRUPO
		cPerg := cPerg + (Space( 10  - Len(cPerg) ) )
		Pergunte(cPerg,.F.)
	EndIf
	    
	OpenProfile()
	
	//*=================================================================================
	//*	Monta as Dimensoes dos Objetos         					  
	//*=================================================================================
	aAdvSize		:= MsAdvSize()
	aAdvSize[5]		:= (aAdvSize[5]/100) * 60	//horizontal
	aAdvSize[6]		:= (aAdvSize[6]/100) * 40	//Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord		:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*20), (((aObjSize[1,4])/100)*59) }	//1,3 Vertical /1,4 Horizontal

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL		//"Integração Com Ms-word"
	
	@ aGdCoord[1],aGdCoord[2] TO aGdCoord[3],aGdCoord[4]   PIXEL
	@ aGdCoord[1]+10,aGdCoord[2]+10 SAY OemToAnsi(STR0008) PIXEL	//"Impressão de documentos no Word."
	@ aGdCoord[1]+20,aGdCoord[2]+10 SAY OemToAnsi(STR0009) PIXEL	//"Serão impressos de acordo com a Seleção Dos Parâmetros."

	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-95 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg,.T.) 
		
	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-60 BUTTON OemToAnsi(STR0010) SIZE 55,11 ACTION fVarW_Imp()					    //"Impr. _Variáveis"  
	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+5  BUTTON OemToAnsi(STR0011) SIZE 55,11 ACTION fWord_Imp(cContrato, cTipCtr)	//"Impr. _Documento"  
		     
	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+70 BMPBUTTON TYPE 2 ACTION Close(oDlg)
	
	ACTIVATE DIALOG oDlg CENTERED

Return( NIL )

/** {Protheus.doc} 
Selecionando as pastas dos Arquivos do Word.  

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	29/01/2016
@Uso: 		SIGAAGR

Static Function fOpen_Word()
	Local cTipo			:= STR0012	//"Modelo de Documentos(*.DOT)  |*.DOT|Modelo de Documentos(*.DOTX) |*.DOTX|"
	Local cNewPathArq	:= cGetFile( cTipo,STR0013,,,,nOR(GETF_MULTISELECT,GETF_NETWORKDRIVE,GETF_LOCALHARD))	//"Selecione o ficheiro *.DOT ou *.DOTX"

	IF !Empty( cNewPathArq )
		IF Len( cNewPathArq ) > 75
			MsgAlert( STR0014 )		//"A localização completa do lugar onde está o ficheiro do Word excedeu o limite de 75 caracteres."
			Return
		Else
			IF  Upper( Subst( AllTrim( cNewPathArq ), - 3 ) ) == Upper( AllTrim( "DOT" ) )
				Aviso( STR0015 , cNewPathArq , { "Ok" } )		//"Ficheiro Selecionado"
				mv_par01 := cNewPathArq
			ElseIf	Upper( Subst( AllTrim( cNewPathArq ), - 4 ) ) == Upper( AllTrim( "DOTX" ) )
				Aviso( STR0015 , cNewPathArq , { "Ok" } )		//"Ficheiro Selecionado"
				mv_par01 := cNewPathArq
			Else
				MsgAlert( STR0016 )		//"Ficheiro inválido!"
				Return
			EndIf
		EndIf
	Else
		Aviso(STR0017 ,STR0018 ,{ "Ok" } )	//"Cancelada a Selecção! Você cancelou a selecção do registo."#"Selecione o ficheiro *.DOT ou *.DOTX"
		Return
	EndIF
Return(.T.)

*/ 

/** {Protheus.doc} 
Impressao das Variaveis disponiveis para uso.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	29/01/2016
@Uso: 		SIGAAGR
*/ 
Static Function fVarW_Imp()
	/*Define Variaveis Locais */
	Local cString		:= 'NJR'
	Local aOrd			:= {STR0019,STR0020}	//"Variável"#"Descrição Da Variável"

	/*Define Variaveis Privates Basicas*/
	Private NomeProg	:= 'OGR342'
	Private AT_PRG		:= NomeProg
	Private aReturn		:= {"Código de barras", 1,"Administração", 2, 2, 1, '',1 }
	Private cDesc1		:= STR0021	//"Relatório Das Variáveis Agr_word."
	Private cDesc2		:= STR0022	//"Sera impresso de acordo com os parâmetro s solicitados pelo"                     
	Private cDesc3		:= STR0023	//"Utilizador."   	
	Private wCabec0		:= 1
	Private wCabec1		:= STR0024	//"Variáveis                      Descrição"
	Private wCabec2		:= ""
	Private wCabec3		:= ""
	Private nTamanho	:= "P"
	Private lEnd		:= .F.
	Private Titulo		:= cDesc1
	Private Li			:= 0
	Private ContFl		:= 1
	Private cBtxt		:= ""
	Private aLinha		:= {}
	Private nLastKey	:= 0

	/*Envia controle para a funcao SETPRINT*/
	WnRel := "WORD_VAR"
	WnRel := SetPrint(cString,Wnrel,"",Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.F.)

	IF nLastKey == 27
		Return( NIL )
	EndIF

	SetDefault(aReturn,cString)

	IF nLastKey == 27
		Return( NIL )
	EndIF

	/*Chamada do Relatorio. */
	RptStatus( { |lEnd| fImpVar() } , Titulo )

Return

/** {Protheus.doc} 
Impressao das Variaveis disponiveis para uso.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	29/01/2016
@Uso: 		SIGAAGR
*/ 
Static Function fImpVar()
	Local nOrdem	:= aReturn[8]
	Local aCampos	:= {}
	Local nX		:= 0
	Local cDescr	:= ""

	/*Carregando Variaveis*/
	aCampos := fCpos_Word()

	/*Ordena aCampos de Acordo com a Ordem Selecionada*/        
	IF nOrdem = 1
		aSort( aCampos , , , { |x,y| x[1] < y[1] } )
	Else
		aSort( aCampos , , , { |x,y| x[4] < y[4] } )
	EndIF

	/*Carrega Regua de Processamento*/        
	SetRegua( Len( aCampos ) )

	/*Impressao do Relatorio*/        
	For nX := 1 To Len( aCampos )

        /*Movimenta Regua Processamento*/        
		IncRegua()

        /*Cancela ImpresÃ†o*/
		IF lEnd
			@ Prow()+1,0 PSAY cCancel
			Exit
		EndIF

		/* Mascara do Relatorio*/
        //        10        20        30        40        50        60        70        80
        //12345678901234567890123456789012345678901234567890123456789012345678901234567890
		//Variaveis                      Descricao
		// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		
		/*Carregando Variavel de Impressao*/
		cDescr := AllTrim( aCampos[nX,4] )

      	/*Imprimindo Relatorio*/
		Impr( Padr(aCampos[nX,1],31) + Left(cDescr,50) )
        
		If Len(cDescr) > 50
			Impr( Space(31) + SubStr(cDescr,51,50) )
		Endif

		If Len(cDescr) > 100
			Impr( Space(31) + SubStr(cDescr,101,50) )
		Endif

	Next nX

	IF aReturn[5] == 1
		Set Printer To
		dbCommit()
		OurSpool(WnRel)
	EndIF

	MS_FLUSH()

Return( NIL )

/** {Protheus.doc} 
Impressao do Documento Word   

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	29/01/2016
@Uso: 		SIGAAGR
*/ 
Static Function fWord_Imp(cContrato, cTipCtr)
	Local oWord		:= NIL
	
	Local cNomeAq 	:= ""
	Local nY		

	/*PARAMETROS*/
	Local cArqWord 	:= mv_par01		//local do arquivo
	Local cDestino 	:= mv_par02		//local destino do arquivo
	
	// *Checa o SO do Remote (1=Windows, 2=Linux)
	If GetRemoteType() == 2
		MsgAlert(OemToAnsi(STR0025), OemToAnsi(STR0026))	//"A integração word funciona somente com windows!!!"#"Atenção !"	
		Return
	EndIf
	
	If Empty(cArqWord)
		Help( , , STR0027, , STR0043, 1, 0 )		//"AJUDA"#"Local não informado!"
		Return
	EndIf
	
	// *CONECTA COM WORD
	oWord	:= OLE_CreateLink() ; OLE_NewFile( oWord , cArqWord )
	dbSelectArea('NJR')
	dbSetOrder(1)
	If dbSeek(xFilial('NJR')+cContrato)
		
		cNomeAq := STR0044+ AllTrim(cContrato) +".docx"	//"Contrato_"
		
		/*Carrega Campos Disponiveis para Edicao*/
		aCampos := fCpos_Word()
	   
		/*Ajustando as Variaveis do Documento*/
		Aeval( aCampos																									,;
				{ |x| OLE_SetDocumentVar( oWord, x[1]  																	,;
											IF( Subst( AllTrim( x[3] ) , 4 , 2 )  == "->"          						,;
												Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 )			,;
																			Subst( AllTrim( x[3] )  					,;
																					- ( Len( AllTrim( x[3] ) ) - 5 )	;
																				)	  	 							 	;
																			)                                          	;
														)																,;
														Transform( x[2] , x[3] )                                     	;
											  ) 														 	 		 	;
										)																			 	;
				}     																 							 	 	;
			)
			
		
		/* INICIO MACRO NO WORD */
		/* ===============================================================================================
		   CASO O CLIENTE NÃO QUEIRA UTILIZAR TABELAS CRIAR NA MACRO DO WORD A FUNCAO DE MACRO VAZIA
		   EXEMPLO:
			   SUB TABCADEN()
			   	'VAZIO NAO UTILIZA
			   END SUB 
		=============================================================================================== */
		
		If mv_par03 == 1 //SIM		
			//Dados da Cadencia NNY - Utilizado em todos os contratos	- Obrigatório
			aNNY  	 := fNNYMacro()
			cNNYMemo := ""
			If !Empty(aNNY)
				For nY := 1 To Len(aNNY)		
					cNNYMemo += AllTrim(Transform(aNNY[ny][1],"99/99/9999"))  			+ "#*"	//DATA INICIAL
					cNNYMemo += AllTrim(Transform(aNNY[ny][2],"99/99/9999")) 			+ "#*" 	//DATA FINAL
					cNNYMemo += AllTrim(Transform(aNNY[ny][3],"@E 999,999,999.99")) 	+ "#*"	//VALOR
					cNNYMemo += aNNY[nY][4] 		+ "#*" 		//ENTIDADE ORIGEM  - NOME -LOJA ORIGEM
					cNNYMemo += aNNY[nY][5] 		+ "#*" 		//ENTIDADE ORIGEM  - NOME -LOJA ORIGEM
				Next nY		
		
				OLE_SetDocumentVar(oWord, "cParam01", cNNYMemo) 					//Envia para a variavel de documento o conteudo completo da tabela
				OLE_SetDocumentVar(oWord, "cParam02", AllTrim(Str(Len(aNNY)+1))) 	//Envia para a variavel de documento a qtd de linhas da tabela
				OLE_ExecuteMacro(oWord, "TABCADEN") 								//Executa macro do Word que cria a tabela e insere o conteudo do cMemo
				OLE_SetDocumentVar(oWord, "cParam01", "") 							//Limpa variavel
				OLE_SetDocumentVar(oWord, "cParam02", "") 							//Limpa variavel
			EndIf		
		EndIf 
		
		// SE CONTRATO 1=Compra OU 2=Venda	
		If cTipCtr == "1" .OR. cTipCtr == "2"				
			If mv_par04 == 1 //SIM		
				//Dados do Financeiro NN7 - Utilizado nos contratos	1=Compra OU 2=Venda - Obrigatório
				aNN7  	 := fNN7Macro()
				cNN7Memo := ""
				If !Empty(aNN7)
					For nY := 1 To Len(aNN7)		
						cNN7Memo += aNN7[nY][1] 		+ "#*"		//PARCELA
						cNN7Memo += AllTrim(Transform(aNN7[ny][2],"99/99/9999")) 			+ "#*" 	//VENCIMENTO
						cNN7Memo += AllTrim(Transform(aNN7[ny][3],"@E 99,999,999,999.99")) 	+ "#*"	//VALOR
						cNN7Memo += aNN7[nY][4] 		+ "#*" 		//BANCO
						cNN7Memo += aNN7[nY][5] 		+ "#*" 		//AGENCIA
						cNN7Memo += aNN7[nY][6] 		+ "#*" 		//DVAGENCIA
						cNN7Memo += aNN7[nY][7] 		+ "#*" 		//CONTA
						cNN7Memo += aNN7[nY][8] 		+ "#*" 		//DVCONTA
					Next nY		
			
					OLE_SetDocumentVar(oWord, "cParam01", cNN7Memo) 					//Envia para a variavel de documento o conteudo completo da tabela
					OLE_SetDocumentVar(oWord, "cParam02", AllTrim(Str(Len(aNN7)+1))) 	//Envia para a variavel de documento a qtd de linhas da tabela
					OLE_ExecuteMacro(oWord, "TABFINAN") 								//Executa macro do Word que cria a tabela e insere o conteudo do cMemo
					OLE_SetDocumentVar(oWord, "cParam01", "") 							//Limpa variavel
					OLE_SetDocumentVar(oWord, "cParam02", "") 							//Limpa variavel
				EndIf 		
			EndIf
			
			If mv_par05 == 1 //SIM
				//Dados das Corretoras NNF - Utilizado nos contratos 1=Compra OU 2=Venda - Informativo Opcional
				aNNF  	 := fNNFMacro()
				cNNFMemo := ""
				If !Empty(aNNF)
					For nY := 1 To Len(aNNF)		
						cNNFMemo += aNNF[nY][1] 		+ "#*"		//COD ENT - NOME FAV
						cNNFMemo += aNNF[nY][2] 		+ "#*" 		//COD CORRETORA - NOM CORRETORA 
						cNNFMemo += AllTrim(Transform(aNNF[ny][3],"@E 999,999.999999")) + "#*"	//VALOR COMISSAO
						cNNFMemo += AllTrim(Transform(aNNF[ny][4],"@E 999.9999")) 		+ "#*"	//% COMISSAO
					Next nY		
			
					OLE_SetDocumentVar(oWord, "cParam01", cNNFMemo) 					//Envia para a variavel de documento o conteudo completo da tabela
					OLE_SetDocumentVar(oWord, "cParam02", AllTrim(Str(Len(aNNF)+1))) 	//Envia para a variavel de documento a qtd de linhas da tabela
					OLE_ExecuteMacro(oWord, "TABCORRET") 								//Executa macro do Word que cria a tabela e insere o conteudo do cMemo
					OLE_SetDocumentVar(oWord, "cParam01", "") 							//Limpa variavel
					OLE_SetDocumentVar(oWord, "cParam02", "") 							//Limpa variavel
				EndIf 				
			EndIf		
		EndIf
				
		// SE CONTRATO 1=Compra	
		If cTipCtr == "1"		
			If mv_par06 == 1 //SIM		 
				//Dados de Cessão de Crédito NNG - Utilizado no contrato 1=Compra - Informativo Opcional
				aNNG  	 := fNNGMacro()
				cNNGMemo := ""
				If !Empty(aNNG)
					For nY := 1 To Len(aNNG)		
						cNNGMemo += aNNG[nY][1] 		+ "#*"		//COD FAV - NOME FAV	
						cNNGMemo += AllTrim(Transform(aNNG[ny][2],"@E 999,999,999.99")) 	+ "#*"	//QUANTIDADE CESSAO	
						cNNGMemo += AllTrim(Transform(aNNG[ny][3],"@E 99,999,999,999.99")) 	+ "#*"	//VALOR PAGAMENTO
						cNNGMemo += aNNG[nY][4] 		+ "#*" 		//BANCO
						cNNGMemo += aNNG[nY][5] 		+ "#*" 		//AGENCIA
						cNNGMemo += aNNG[nY][6] 		+ "#*" 		//DVAGENCIA
						cNNGMemo += aNNG[nY][7] 		+ "#*" 		//CONTA
						cNNGMemo += aNNG[nY][8] 		+ "#*" 		//DVCONTA					
					Next nY		
			
					OLE_SetDocumentVar(oWord, "cParam01", cNNGMemo) 					//Envia para a variavel de documento o conteudo completo da tabela
					OLE_SetDocumentVar(oWord, "cParam02", AllTrim(Str(Len(aNNG)+1))) 	//Envia para a variavel de documento a qtd de linhas da tabela
					OLE_ExecuteMacro(oWord, "TABCESSC") 								//Executa macro do Word que cria a tabela e insere o conteudo do cMemo
					OLE_SetDocumentVar(oWord, "cParam01", "") 							//Limpa variavel
					OLE_SetDocumentVar(oWord, "cParam02", "") 							//Limpa variavel
				EndIf 				
			EndIf
		EndIf					
		/* FINAL MACRO NO WORD */
		
		/*Atualiza as Variaveis*/
		OLE_UpDateFields( oWord )
		
		/*Imprimindo o Documento */
		OLE_SetProperty( oWord, '208', .F. ) 
	
		OLE_SaveAsFile( oWord, Alltrim(cDestino)+Alltrim(cNomeAq) )
		
		/*Encerrando o Link com o Documento*/
		OLE_CloseLink(oWord)
	
		//ABRE WORD
		ShellExecute( "Open", Alltrim(cDestino)+Alltrim(cNomeAq), " "," ", 3 )
	Else
		Help( , , STR0027, , STR0028, 1, 0 )	//"AJUDA"#"Não foi possivel imprimir o arquivo!"
	EndIf 
	
	oDlg:End()
	
Return

/** {Protheus.doc} 
Variaveis disponiveis para impressao 

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	29/01/2016
@Uso: 		SIGAAGR
*/ 
Static Function fCpos_Word()
	Local aExp	:= {}	
	Local aFiliInfo	:= {} 
	
	//*Declarar as variaveis vazias para a impressão
	Local	cDesTipCtr	:= ""
	Local	cNomeEntid	:= ""
	Local	cNomeLjEnt	:= ""
	Local	cNomeTerce	:= ""
	Local	cNomeLjTer	:= ""
	Local	cOperTrang	:= ""
	Local	cOperVeFut	:= ""
	Local	cDescOpera	:= ""
	Local	cDescSafra	:= ""
	Local	cDescProdut	:= ""
	Local	cDescTabel	:= ""
	Local	cDescOpFis	:= ""
	Local	cTipoQueTec	:= ""
	Local	cDescIdMerc	:= ""
	Local	cIncentiDAP	:= ""
	Local	cTipoFrete	:= ""
	Local	cCtrlLogis	:= ""
	Local	cCtrlEntSai	:= ""
	Local	cCtrTransfe	:= ""
	Local	cModeloCTR	:= ""
	Local	cDescModCTR	:= ""
	Local	cStsCtrAss	:= ""
	Local	cStsCtrFis	:= ""
	Local	cStsCtrFin	:= ""
	Local	cStsCtrEst	:= ""
	Local	cStatusCtr	:= ""
	Local	cDescTabSer	:= ""
	Local	cDescModlCtr:= ""
	Local 	cDescMoeda	:= ""
	Local   cSimbMoeda	:= ""	
	Local	cCodVended	:= ""
	Local	cLojVended	:= ""
	Local	cNomVended	:= ""
	Local	cNomLjVend	:= ""
	Local	cTipVended	:= ""
	Local	cDescTipVen	:= ""
	Local	cCPFVend	:= ""
	Local	cRGVende	:= ""
	Local	cIEVendedo	:= ""
	Local	cEndVended	:= ""
	Local	cBaiVended	:= ""
	Local	cMunVended	:= ""
	Local	cEstVended	:= ""
		
	//*=================================================================================
	//*INICIA A CRIACAO DE VARIAVEIS PARA WORD			
	//*=================================================================================
				/*====================== =========================== =========================== ===============================*/
		        /*VARIAVEL PARA WORD 	, VARIAVEL DE IMPRESSAO 	, VARIAVEL DE PICTURE		,DESCRIÇÃO VARIAVEIS			*/
		        /*====================== =========================== =========================== ===============================*/ 
	aAdd( aExp, {'AGR_FILIAL'			, NJR->NJR_FILIAL 			, "NJR->NJR_FILIAL"			, STR0045 })	//"Filial do Contrato"
	aAdd( aExp, {'AGR_CONTRATO'			, NJR->NJR_CODCTR			, "NJR->NJR_CODCTR"			, STR0046 })	//"Código do Contrato"
	aAdd( aExp, {'AGR_ULTALTERA'		, NJR->NJR_ULTALT			, "NJR->NJR_ULTALT"			, STR0047 })	//"Última Alteração"
	aAdd( aExp, {'AGR_DESCRICAO'		, NJR->NJR_DESCRI 			, "NJR->NJR_DESCRI"			, STR0048 })	//"Descrição do Contrato"
	
	//*Descrição do Tipo de Contrato
	cDesTipCtr := If(NJR->NJR_TIPO=="1",STR0049,( If(NJR->NJR_TIPO=="2",STR0050,( If(NJR->NJR_TIPO=="3",STR0051,(If(NJR->NJR_TIPO=="4",STR0052,"")))))))	//"Compra"#"Venda"#"Armazenagem De 3"#"Armazenagem Em 3"
	aAdd( aExp, {'AGR_DESTIPO'			, cDesTipCtr			  	, "@!"						, STR0053 })	//"Tipo do Contrato" 
	aAdd( aExp, {'AGR_DATACTR'			, NJR->NJR_DATA				, "NJR->NJR_DATA"			, STR0054 })	//"Data do Contrato"
	
	//*Dados Entidade	
	aAdd( aExp, {'AGR_CODENTIDADE'		, NJR->NJR_CODENT			, "NJR->NJR_CODENT"			, STR0055 })	//"Código da Entidade"
	aAdd( aExp, {'AGR_LOJENTIDADE'		, NJR->NJR_LOJENT			, "@!"						, STR0056 })	//"Loja da Entidade"	
	cNomeEntid := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_NOME")
	cNomeLjEnt := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_NOMLOJ")	
	aAdd( aExp, {'AGR_NOMENTIDADE'		, cNomeEntid				, "@!"						, STR0057 })	//"Nome da Entidade"
	aAdd( aExp, {'AGR_NOMLJENTIDA'		, cNomeLjEnt				, "@!"						, STR0058 })	//"Nome Loja da Entidade"
	
	//====================================================================================================================================
	// Dados da Entidade por tipo de contrato
	// *Para compra ou de 3 = Fornecedor  
	// *Para venda  ou em 3 = Cliente		
	If NJR->NJR_TIPO=="1" .OR. NJR->NJR_TIPO=="4" //"1=Compra"#"4=Em 3"
		cCodVended := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_CODFOR")	//Codigo Fornecedor
		cLojVended := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_LOJFOR")	//Codigo Loja	
		
		//Tabela SA2 - Fornecedor
		cNomVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_NOME')					//Nome Fornecedor
		cNomLjVend := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_NREDUZ')				//Nome Loja
	
		//** Tratando CPF ou CNPJ
		cTipVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_TIPO') 				//F=Fisico;J=Juridico;X=Outros
		cDescTipVen:= If(cTipVended=="F",STR0059, If(cTipVended=="J",STR0060,STR0061))					//"Fisico"#"Juridico"#"Outros"
		If cTipVended == "J"
			cCPFVend := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_CGC')				//CPF
			cCnpj1 := Substr( cCPFVend , 1,2)
			cCnpj2 := Substr( cCPFVend , 3,3)
			cCnpj3 := Substr( cCPFVend , 6,3)
			cCnpj4 := Substr( cCPFVend , 9,4)
			cCnpj5 := Substr( cCPFVend , 13,2)			
			cCPFVend:= cCnpj1+'.'+cCnpj2+'.'+cCnpj3+'/'+cCnpj4+'-'+cCnpj5
		ElseIf cTipVended == "F"
			cCPFVend := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_CGC')		//CPF
			cRGVende := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_PFISICA')	//RG			
			cCnpj1 := Substr( cCPFVend , 1,3)
			cCnpj2 := Substr( cCPFVend , 4,3)
			cCnpj3 := Substr( cCPFVend , 7,3)
			cCnpj4 := Substr( cCPFVend , 10,2)			
			cCPFVend:= cCnpj1+'.'+cCnpj2+'.'+cCnpj3+'-'+cCnpj4			
		Else
			cCPFVend := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_CGC')		//CPF
		EndIf 

		cDDDVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_DDD')			//DDD
		cTelVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_TEL')			//Telefone		
		cIEVendedo := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_INSCR')		//Inscrição Estadual
		cEndVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_END')			//Endereço
		cBaiVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_BAIRRO')		//Bairro
		cMunVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_MUN')			//Municipio
		cEstVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_EST')		//Estado - Tiago 02/08/18	
	EndIf
	If NJR->NJR_TIPO=="2" .OR. NJR->NJR_TIPO=="3"//"2=Venda"#"3=De 3"
		cCodVended := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_CODCLI")	//Codigo Cliente
		cLojVended := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_LOJCLI")	//Codigo Loja	
	
		//Tabela SA1 - Cliente
		cNomVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_NOME')			//Nome Cliente
		cNomLjVend := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_NREDUZ')		//Nome Loja
	
		//** Tratando CPF ou CNPJ
		cTipVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_PESSOA') 		//F=Fisico;J=Juridico
		cDescTipVen:= If(cTipVended=="F","Fisico", "Juridico")
		If cTipVended == "J"
			cCPFVend := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_CGC')		//CPF
			cCnpj1 := Substr( cCPFVend , 1,2)
			cCnpj2 := Substr( cCPFVend , 3,3)
			cCnpj3 := Substr( cCPFVend , 6,3)
			cCnpj4 := Substr( cCPFVend , 9,4)
			cCnpj5 := Substr( cCPFVend , 13,2)			
			cCPFVend:= cCnpj1+'.'+cCnpj2+'.'+cCnpj3+'/'+cCnpj4+'-'+cCnpj5
		ElseIf cTipVended == "F"
			cCPFVend := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_CGC')		//CPFd
			cRGVende := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_PFISICA')	//RG			
			cCnpj1 := Substr( cCPFVend , 1,3)
			cCnpj2 := Substr( cCPFVend , 4,3)
			cCnpj3 := Substr( cCPFVend , 7,3)
			cCnpj4 := Substr( cCPFVend , 10,2)			
			cCPFVend:= cCnpj1+'.'+cCnpj2+'.'+cCnpj3+'-'+cCnpj4			
		Else
			cCPFVend := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_CGC')		//CPF
		EndIf 
		
		cDDDVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_DDD')			//DDD
		cTelVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_TEL')			//Telefone
		cIEVendedo := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_INSCR')		//Inscrição Estadual
		cEndVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_END')			//Endereço
		cBaiVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_BAIRRO')		//Bairro
		cMunVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_MUN')			//Municipio
		cEstVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_EST')		//Estado	- Tiago Dantas da Ceruz - 02/08/18
	EndIf		
	//====================================================================================================================================
		
	aAdd( aExp, {'AGR_CODVENDEDOR'		, Alltrim(cCodVended)		, "@!"						, STR0062 })	//"Código do Vendedor"
	aAdd( aExp, {'AGR_LOJAVENDEDOR'		, Alltrim(cLojVended)		, "@!"						, STR0063 })	//"Loja do Vendedor"					
	aAdd( aExp, {'AGR_NOMEVENDEDOR'		, Alltrim(cNomVended)		, "@!"						, STR0064 })	//"Nome do Vendedor"
	aAdd( aExp, {'AGR_NOMLJVENDEDOR'	, Alltrim(cNomLjVend)		, "@!"						, STR0065 })	//"Nome Loja do Vendedor"
	aAdd( aExp, {'AGR_DESCTIPVENDED'	, Alltrim(cDescTipVen)		, "@!"						, STR0066 })	//"Descrição do Tipo do Vendedor"
	aAdd( aExp, {'AGR_CPFVENDEDOR'		, Alltrim(cCPFVend)			, ""						, STR0067 })	//"CPF do Vendedor"
	aAdd( aExp, {'AGR_RGVENDEDOR'		, Alltrim(cRGVende)			, ""						, STR0068 })	//"RG do Vendedor"
	aAdd( aExp, {'AGR_DDDVENDEDOR'		, Alltrim(cDDDVended)		, "@!"						, STR0167 })	//"DDD do Vendedor"
	aAdd( aExp, {'AGR_TELVENDEDOR'		, Alltrim(cTelVended)		, "@!"						, STR0168 })	//"Telefone do Vendedor"
	aAdd( aExp, {'AGR_IEVENDEDOR'		, Alltrim(cIEVendedo)		, "@!"						, STR0069 })	//"IE do Vendedor"
	aAdd( aExp, {'AGR_ENDVENDEDOR'		, Alltrim(cEndVended)		, "@!"						, STR0070 })	//"Endereço do Vendedor"
	aAdd( aExp, {'AGR_BAIVENDEDOR'		, Alltrim(cBaiVended)		, "@!"						, STR0071 })	//"Bairro do Vendedor"
	aAdd( aExp, {'AGR_MUNVENDEDOR'		, Alltrim(cMunVended)		, "@!"						, STR0072 })	//"Municipio do Vendedor"
	aAdd( aExp, {'AGR_ESTVENDEDOR'		, Alltrim(cEstVended)		, "@!"						, STR0073 })	//"Estado do Vendedor"
	
	//*Dados Terceiro
	aAdd( aExp, {'AGR_CODTERCEIROS'		, NJR->NJR_CODTER			, "NJR->NJR_CODTER"			, STR0074 })	//"Código de Terceiros"
	aAdd( aExp, {'AGR_LOJTERCEIROS'		, NJR->NJR_LOJTER			, "NJR->NJR_LOJTER"			, STR0075 })	//"Loja de Terceiros"
	cNomeTerce := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODTER+NJR->NJR_LOJTER,"NJ0_NOME")
	cNomeLjTer := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODTER+NJR->NJR_LOJTER,"NJ0_NOMLOJ")				
	aAdd( aExp, {'AGR_NOMETERCEIROS'	, cNomeTerce				, "@!"						, STR0076 })	//"Nome de Terceiros"
	aAdd( aExp, {'AGR_NOMLJTERCEIROS'	, cNomeLjTer				, "@!"						, STR0077 })	//"Nome Loja de Terceiros"
	
	//*Operação Triangular	
	cOperTrang := If(NJR->NJR_OPETRI=="1",STR0035,STR0036)	//"Sim"#"Não"
	//*Operação Venda Futura	
	cOperVeFut := If(NJR->NJR_OPEFUT=="1",STR0035,STR0036)	//"Sim"#"Não"
	If __lnewComerc .and. __lnewNeg
		aAdd( aExp, {'AGR_OPERTRIANGULAR'	, cOperTrang				, "@!"						, STR0078 })	//"Operação Triangular"
		aAdd( aExp, {'AGR_OPERVENDAFUTURA'	, cOperVeFut				, "@!"						, STR0079 })	//"Operação Venda Futura"
	EndIf
	aAdd( aExp, {'AGR_CODOPERACAO'		, NJR->NJR_CODOPE			, "NJR->NJR_CODOPE"			, STR0080 })	//"Código da Operação"	
	cDescOpera := POSICIONE("NNO",1,XFILIAL("NNO")+NJR->NJR_CODOPE,"NNO_DESCRI")
	aAdd( aExp, {'AGR_DESCOPERACAO'		,cDescOpera					, "@!"						, STR0081 })	//"Descrição da Operação"

	aAdd( aExp, {'AGR_CODSAFRA'			,NJR->NJR_CODSAF			, "NJR->NJR_CODSAF"			, STR0082 })	//"Código da Safra"
	cDescSafra	:= POSICIONE("NJU",1,XFILIAL("NJU")+NJR->NJR_CODSAF,"NJU_DESCRI")	
	aAdd( aExp, {'AGR_DESCSAFRA'		,cDescSafra					, "@!"						, STR0083 })	//"Descrição da Safra"
	
	aAdd( aExp, {'AGR_TALHAO'			,NJR->NJR_TALHAO			, "NJR->NJR_TALHAO"			, STR0084 })	//"Código do Talhão"

	aAdd( aExp, {'AGR_CODPRODUTO'		,NJR->NJR_CODPRO			, "NJR->NJR_CODPRO"			, STR0085 })	//"Código do Produto"
	cDescProdut := Posicione('SB1',1,xFilial('SB1')+NJR->NJR_CODPRO,'B1_DESC')
	aAdd( aExp, {'AGR_DESPRODUTO'		,cDescProdut				, "@!"						, STR0086 })	//"Descrição do Produto"
	
	aAdd( aExp, {'AGR_UNIMEDPRO1'		,NJR->NJR_UM1PRO			, "NJR->NJR_UM1PRO"			, STR0087 })	//"Unidade de Medida do Produto"
	
	aAdd( aExp, {'AGR_CODTABELA'		,NJR->NJR_TABELA			, "NJR->NJR_TABELA"			, STR0088 })	//"Código da Tabela de Descontos"
	cDescTabel	:= Posicione('NNI',1,xFilial('NNI')+NJR->NJR_TABELA,'NNI_DESCRI')
	aAdd( aExp, {'AGR_DESTABELA'		,cDescTabel					, "@!"						, STR0089 })	//"Descrição da Tabela de Descontos"
	
	aAdd( aExp, {'AGR_CODCTRRPC'		,NJR->NJR_CODRPC			, "NJR->NJR_CODRPC"			, STR0090 })	//"Código Contrato RPC"
	
	aAdd( aExp, {'AGR_CODOPERFISCAL'	,NJR->NJR_OPEFIS			, "NJR->NJR_OPEFIS"			, STR0091 })	//"Código Operação Fiscal"	
	cDescOpFis	:= Posicione('SX5',1,xFilial('NJR')+'DJ'+NJR->NJR_OPEFIS,'X5_DESCRI')  
	aAdd( aExp, {'AGR_DESOPERFISCAL'	,cDescOpFis					, "@!"						, STR0092 })	//"Descrição Operação Fiscal"
	
	aAdd( aExp, {'AGR_TESMOVESTOQUE'	,NJR->NJR_TESEST			, "NJR->NJR_TESEST"			, STR0093 })	//"Cod. TES p/ Mov. Estoque"	
	
	aAdd( aExp, {'AGR_TESMOVFINANCEIRO'	,NJR->NJR_TESFIN			, "NJR->NJR_TESFIN"			, STR0094 })	//"Cod. TES p/ Mov. Financeiro"

	aAdd( aExp, {'AGR_TESQUEBRATECNICA'	,NJR->NJR_TESQTE			, "NJR->NJR_TESQTE"			, STR0095 })	//"Cod. TES Quebra Técnica"

	aAdd( aExp, {'AGR_TESRETORNOSIMBOL'	,NJR->NJR_TESRSI			, "NJR->NJR_TESRSI"			, STR0096 })	//"Cod. TES Retorno Simbolico"

	aAdd( aExp, {'AGR_TIPOEMBALAGEM'	,NJR->NJR_TIPEMB			, "NJR->NJR_TIPEMB"			, STR0097 })	//"Tipo de Embalagem"

	aAdd( aExp, {'AGR_MENSAGEMFISCAL'	,NJR->NJR_MSGNFS			, "NJR->NJR_MSGNFS"			, STR0098 })	//"Mensagem do Documento Fiscal"
	 
	aAdd( aExp, {'AGR_OBSADICIONAL' 	, NJR->NJR_OBSADT				, "@!"						, STR0099 })	//"Observacao Adicional"	
	
	aAdd( aExp, {'AGR_QUANTIDADEINCIAL'	, NJR->NJR_QTDINI			, "NJR->NJR_QTDINI"			, STR0100 })	//"Quantidade Inicial"
	
	aAdd( aExp, {'AGR_QUANTIDADECONTRA'	, NJR->NJR_QTDCTR			, "NJR->NJR_QTDCTR"			, STR0101 })	//"Quantidade Contratada"

	aAdd( aExp, {'AGR_QUANTIDADEAUTENT'	, NJR->NJR_AUTENT			, "NJR->NJR_AUTENT"			, STR0102 })	//"Quantidade Autorizada Entrada"
	
	aAdd( aExp, {'AGR_QUANTIDADEAUTSAI'	, NJR->NJR_AUTSAI			, "NJR->NJR_AUTSAI"			, STR0103 })	//"Quantidade Autorizada Saída"

	//*QTDS ENTRADA	
	aAdd( aExp, {'AGR_QUANTIDADEENTEMB'	, NJR->NJR_QTEEMB			, "NJR->NJR_QTEEMB"			, STR0104 })	//"Quantidade Entrada de Embalagem"
	aAdd( aExp, {'AGR_QUANTIDENTFISICO'	, NJR->NJR_QTEFCO			, "NJR->NJR_QTEFCO"			, STR0105 })	//"Quantidade de Entrada Fisico"
	aAdd( aExp, {'AGR_QUANTIDENTFISCAL'	, NJR->NJR_QTEFIS			, "NJR->NJR_QTEFIS"			, STR0106 })	//"Quantidade de Entrada Fiscal"
	aAdd( aExp, {'AGR_VALORENTFISCAL'	, NJR->NJR_VLEFIS			, "NJR->NJR_VLEFIS"			, STR0107 })	//"Valor de Entrada Fiscal"
	
	//*QTDS SAIDA
	aAdd( aExp, {'AGR_QUANTIDADESAIEMB'	, NJR->NJR_QTSEMB			, "NJR->NJR_QTSEMB"			, STR0108 })	//"Quantidade Saída de Embalagens"
	aAdd( aExp, {'AGR_QUANTIDSAIFISICO'	, NJR->NJR_QTSFCO			, "NJR->NJR_QTSFCO"			, STR0109 })	//"Quantidade de Saída Fisico"
	aAdd( aExp, {'AGR_QUANTIDSAIFISCAL'	, NJR->NJR_QTSFIS			, "NJR->NJR_QTSFIS"			, STR0110 })	//"Quantidade de Saída Fiscal"
	aAdd( aExp, {'AGR_VALORSAIFISCAL'	, NJR->NJR_VLSFIS			, "NJR->NJR_VLSFIS"			, STR0111 })	//"Valor de Saída Fiscal"
	
	//*QTDS SALDO
	aAdd( aExp, {'AGR_QUANTIDADESALEMB'	, NJR->NJR_QSLEMB			, "NJR->NJR_QSLEMB"			, STR0112 })	//"Quantidade Saldo Embalagem"
	aAdd( aExp, {'AGR_QUANTIDSALFISICO'	, NJR->NJR_QSLFCO			, "NJR->NJR_QSLFCO"			, STR0113 })	//"Quantidade de Saldo Fisico"
	aAdd( aExp, {'AGR_QUANTIDSALFISCAL'	, NJR->NJR_SLDFIS			, "NJR->NJR_SLDFIS"			, STR0114 })	//"Quantidade de Saldo Fiscal"
	aAdd( aExp, {'AGR_VALORSALFISCAL'	, NJR->NJR_SLDTOT			, "NJR->NJR_SLDTOT"			, STR0115 })	//"Valor de Saldo Fiscal"

	aAdd( aExp, {'AGR_QUANTIDADERESERV'	, NJR->NJR_QTDRES			, "NJR->NJR_QTDRES"			, STR0116 })	//"Quantidade Reservada"

	cTipoQueTec := If(NJR->NJR_TIPFIX=="1",STR0117,STR0118)	//1=Fixo;2=A Fixar
	aAdd( aExp, {'AGR_TIPOQUEBRATEC'	, cTipoQueTec				, "@!"						, STR0119 })	//"Tipo de Fixação"
	
	aAdd( aExp, {'AGR_VALORUNITBASE'	, NJR->NJR_VLRBAS			, "NJR->NJR_VLRBAS"			, STR0120 })	//"Valor Unitario Base"

	//*Moeda do Contrato
	aAdd( aExp, {'AGR_CODIGOMOEDA'		, NJR->NJR_MOEDA			, "NJR->NJR_MOEDA"			, STR0121 })	//"Codigo da Moeda"
	cDescMoeda := SuperGetMv("MV_MOEDA"+AllTrim(Str(NJR->NJR_MOEDA,2)))
	cSimbMoeda := SuperGetMv("MV_SIMB"+AllTrim(Str(NJR->NJR_MOEDA,2))) 	
	aAdd( aExp, {'AGR_DESCMOEDA'		, cDescMoeda				, "@!"						, STR0122 })	//"Descrição da Moeda"
	aAdd( aExp, {'AGR_SIMBMOEDA'		, cSimbMoeda				, "@!"						, STR0123 })	//"Símbolo da Moeda"				
	aAdd( aExp, {'AGR_TAXAMOEDA'		, NJR->NJR_TXMOED			, "NJR->NJR_TXMOED"			, STR0124 })	//"Taxa da Moeda"

	aAdd( aExp, {'AGR_VALORUNITARIO'	, NJR->NJR_VLRUNI			, "NJR->NJR_VLRUNI"			, STR0125 })	//"Valor Unitario"
	
	aAdd( aExp, {'AGR_UNIDADEPRECO'		, NJR->NJR_UMPRC			, "NJR->NJR_UMPRC"			, STR0126 })	//"Unidade de Preço"

	aAdd( aExp, {'AGR_VALORTOTCONTRATO'	, NJR->NJR_VLRTOT			, "NJR->NJR_VLRTOT"			, STR0127 })	//"Valor Total Contrato"

	aAdd( aExp, {'AGR_PERCLIMTCREDITO'	, NJR->NJR_PERCRD			, "NJR->NJR_PERCRD"			, STR0128 })	//"Percentual de Limite de Crédito"
			
	aAdd( aExp, {'AGR_INDICEMERCADO'	, NJR->NJR_CODIDX			, "NJR->NJR_CODIDX"			, STR0129 })	//"Indice de Mercado"
	cDescIdMerc	:= Posicione('NK0',1,xFilial('NK0')+NJR->NJR_CODIDX,'NK0_DESCRI')
	aAdd( aExp, {'AGR_DESCRIMERCADO'	, cDescIdMerc				, "@!"						, STR0130 })	//"Descrição Indice de Mercado"

	cIncentiDAP := If(NJR->NJR_ITVDAP=="1",STR0035,STR0036)	//1=Sim;2=Nao
	aAdd( aExp, {'AGR_POSSUIINCTDAP'	, cIncentiDAP				, "@!"						, STR0131 })	//"Possui o Incentivo DAP"
	
	cTipoFrete	:= If(NJR->NJR_TPFRET=="C",STR0132, If(NJR->NJR_TPFRET=="F",STR0133, If(NJR->NJR_TPFRET=="T",STR0134,STR0135)))	//"CIF"#"FOB"#"Por conta terceiros"#"Sem Frete" 	
	aAdd( aExp, {'AGR_TIPOFRETE'		, cTipoFrete				, "@!"						, STR0136 })	//"Tipo do Frete"
		
	cCtrlLogis := If(NJR->NJR_CTRLLG=="1",STR0035,STR0036)	//1=Sim;2=Nao
	aAdd( aExp, {'AGR_CONTROLALOGIST'	, cCtrlLogis				, "@!"						, STR0137 })	//"Controle de Logistica"

	cCtrlEntSai := If(NJR->NJR_CTRLCD=="0",STR0138, If(NJR->NJR_CTRLCD=="1",STR0139, If(NJR->NJR_CTRLCD=="2",STR0140, STR0141)))	//"Nenhum"#"Saída"#"Entrada"#"Entrada/Saída"	
	aAdd( aExp, {'AGR_CONTROLAENTSAI'	, cCtrlEntSai				, "@!"						, STR0142 })	//"Controle Entrada/Saída"

	cCtrTransfe := If(NJR->NJR_TRANSF=="1",STR0035,STR0036)	//1=Sim;2=Nao
	aAdd( aExp, {'AGR_CONTRATOTRANSF'	, cCtrTransfe				, "@!"						, STR0143 })	//"Contrato de Transferencia"

	cModeloCTR	:= If(NJR->NJR_MODELO=="1",STR0144, If(NJR->NJR_MODELO=="2",STR0145,STR0146))	//"Pré-Contrato"#"Contrato"#"Automatico" 	
	aAdd( aExp, {'AGR_MODELOCONTRATO'	, cModeloCTR				, "@!"						, STR0147 })	//"Modelo do Contrato"

	aAdd( aExp, {'AGR_MODELOBASECTR'	, NJR->NJR_MODBAS			, "NJR->NJR_MODBAS"			, STR0148 })	//"Modelo Base p/ Contrato"
	cDescModCTR	:= Posicione('NJX',1,xFilial('NJX')+NJR->NJR_MODBAS,'NJX_DESCRI')
	aAdd( aExp, {'AGR_DESCMODELOCTR'	, cDescModCTR				, "@!"						, STR0149 })	//"Descrição Modelo Base p/ Contrato"

	cStsCtrAss := If(NJR->NJR_STSASS=="A",STR0150,STR0151)	//A=Aberto;F=Finalizado
	aAdd( aExp, {'AGR_STATUSCTRASSI'	, cStsCtrAss				, "@!"						, STR0152 })	//"Status Assinatura do Contrato"

	cStsCtrFis := If(NJR->NJR_STSFIS=="A",STR0150,STR0151)	//A=Aberto;F=Finalizado
	aAdd( aExp, {'AGR_STATUSCTRFIS'		, cStsCtrFis				, "@!"						, STR0153 })	//"Status Fiscal do Contrato"

	cStsCtrFin := If(NJR->NJR_STSFIN=="A",STR0150,STR0151)	//A=Aberto;F=Finalizado
	aAdd( aExp, {'AGR_STATUSCTRFIN'		, cStsCtrFin				, "@!"						, STR0154 })	//"Status Financeiro do Contrato"

	cStsCtrEst := If(NJR->NJR_STSEST=="A",STR0150,STR0151)	//A=Aberto;F=Finalizado
	aAdd( aExp, {'AGR_STATUSCTREST'		, cStsCtrEst				, "@!"						, STR0155 })	//"Status Estoque do Contrato"
									
	cStatusCtr := If(NJR->NJR_STATUS=="P",STR0156, If(NJR->NJR_STATUS=="A",STR0157, If(NJR->NJR_STATUS=="I",STR0158, If(NJR->NJR_STATUS=="E",STR0159,STR0160)))) //"Previsto"#"Aberto"#"Iniciado"#"Cancelado"#"Finalizado"	
	aAdd( aExp, {'AGR_STATUSCONTRATO'	, cStatusCtr				, "@!"						, STR0161 })	//"Status do Contrato"

	aAdd( aExp, {'AGR_CODIGOTABSERV'	, NJR->NJR_CODTSE			, "NJR->NJR_CODTSE"			, STR0162 })	//"Codigo Tabela de Servico"
	cDescTabSer	:= Posicione('NKP',1,xFilial('NKP')+NJR->NJR_CODTSE,'NKP_DESTSE')
	aAdd( aExp, {'AGR_DESCTABSERV'		, cDescTabSer				, "@!"						, STR0163 })	//"Descrição Tabela de Servico"

	aAdd( aExp, {'AGR_CODIGOMODCTR'	, NJR->NJR_MODAL				, "NJR->NJR_MODAL"			, STR0164 })	//"Codigo Modalidade do Contrato"
	cDescModlCtr:= POSICIONE('NK5',1,XFILIAL('NK5')+NJR->NJR_MODAL,'NK5_DESMOD')
	aAdd( aExp, {'AGR_DESCMODCTR'		, cDescModlCtr				, "@!"						, STR0165 })	//"Descrição Modalidade do Contrato"

	aAdd( aExp, {'AGR_INSCRICAOCAMPO'	, NJR->NJR_INSCPO			, "NJR->NJR_INSCPO"			, STR0166 })	//"Inscrição de Campo"
	
	
	aFiliInfo := FWArrFilAtu() //Retorna informações referente a empresa, unidade de negócio e filial.
	
	If __lnewComerc .and. __lnewNeg	
		cMemoQ := POSICIONE("N79",1,XFILIAL("N79")+NJR->NJR_CODNGC ,"N79_INFQUA")
		cMemoP := N79->N79_DAGNGC
		cMemoE := N79->N79_INFENT
		aAdd( aExp, {'AGR_INFQUALIDADE'		, cMemoQ		, "@!"			, STR0178 })	//"Inscrição de Campo"
		aAdd( aExp, {'AGR_INFPGTO'			, cMemoP		, "@!"			, STR0179 })	//"Inscrição de Campo"
		aAdd( aExp, {'AGR_INFENTR'			, cMemoE		, "@!"			, STR0180 })	//"Inscrição de Campo"
	EndIf
			
	aAreaSA1 := SA1->(GetArea())
	Dbselectarea("SA1")
	SA1->(Dbseek(fwxFilial("SA1")+aFiliInfo[18]))	
	aAdd( aExp, {'AGR_RAZAOENDCOB'		, SA1->A1_ENDCOB												, "SA1->A1_ENDCOB"	, STR0171 })	//"Inscrição de Campo"
	aAdd( aExp, {'AGR_CGCENDCOB'		, Transform(SA1->A1_CGC,PesqPict("SA1","A1_CGC"))		, "SA1->A1_CGC"		, STR0172 })	//"Inscrição de Campo"	
	aAdd( aExp, {'AGR_INSCRICOB'		, SA1->A1_INSCR												, "SA1->A1_INSCR"		, STR0173 })	//"Inscrição de Campo"
	aAdd( aExp, {'AGR_ENDEREENT'		, SA1->A1_ENDENT												, "SA1->A1_ENDENT"	, STR0174 })	//"Inscrição de Campo"
	aAdd( aExp, {'AGR_BAIRROENT'		, SA1->A1_BAIRROE												, "SA1->A1_BAIRROE"	, STR0175 })	//"Inscrição de Campo"
	aAdd( aExp, {'AGR_CIDADEENT'		, SA1->A1_MUNE												, "SA1->A1_MUNE"	, STR0176 })	//"Inscrição de Campo"	
	aAdd( aExp, {'AGR_ESTADOENT'		, SA1->A1_ESTE												, "SA1->A1_ESTE"	, STR0177 })	//"Inscrição de Campo"
	
	cDsEst := POSICIONE("SX5",1,XFILIAL("SX5")+'12'+SA1->A1_ESTE ,"X5_DESCRI")
	aAdd( aExp, {'AGR_DSESTENT'			, cDsEst  , "@!"	,  STR0177 })	//"Inscrição de Campo"					
		
	RestArea(aAreaSA1)

	aAdd( aExp, {'AGR_DSUNIDADEPRECO'	, POSICIONE("SAH",1,XFILIAL("SAH")+NJR->NJR_UMPRC ,"AH_DESCPO")			, "SAH->AH_DESCPO"			, STR0181 })	//"Unidade de Preço"
	
	/* Ponto de Entrada ( OGR342ADV ) 28/11/2016
	   Autor: Roney Joca Maia
	   Projeto: MAGRO-228  */
	// Ponto de Entrada para manipulação de variaveis de impressão
	If ExistBlock("OGR342ADV")  
	
		aExp := ExecBlock("OGR342ADV",.F.,.F.,{aExp})
	
	EndIf
	
	/* Exemplo de ponto de Entrada ( OGR342ADV ) 28/11/2016
	   Autor: Roney Joca Maia
	   Projeto: MAGRO-228
	##############################
	
	 #Include 'Protheus.ch'

    User Function OGR342ADV()
    
	    Local aExp := PARAMIXB[1] 
	    
	    // Exemplo de customização
	    If (Len(aExp) > 0)
	        
	         //Adicionar    //VARIAVEL PARA WORD 	, VARIAVEL DE IMPRESSAO 	, VARIAVEL DE PICTURE		,DESCRIÇÃO VARIAVEIS	
	        aAdd( aExp, {'AGR_CAMPOEXEMPLO'		, NJR->NJR_INSCPO			, "NJR->NJR_INSCPO"			, "Inscrição de Campo" })	//
	        
	    EndIf 
   
    	Return (aExp)
    	
    ##############################
	*/
	
Return( aExp )

/** {Protheus.doc} fNN7Macro
Macro Word - Tabela NN7 - Dados Financeiros

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	27/04/2016
@Uso: 		SIGAAGR
*/ 
Static Function fNN7Macro()
	Local aReturn := {}

	dbSelectArea("NN7")
	dbSetOrder(1)		//NN7_FILIAL+NN7_CODCTR+NN7_ITEM
	If dbSeek(xFilial("NN7")+NJR->NJR_CODCTR)
		While !Eof() .AND. NN7->NN7_FILIAL = xFilial("NN7") .AND. NN7->NN7_CODCTR = NJR->NJR_CODCTR			
			aAdd(aReturn,{	NN7->NN7_PARCEL, ;		//PARCELA		   
							NN7->NN7_DTVENC, ;		//VENCIMENTO		
							NN7->NN7_VALOR , ;		//VALOR			
							NN7->NN7_CODBCO, ;		//BANCO			 
							NN7->NN7_CODAGE, ;		//AGENCIA  		
							NN7->NN7_DVAGE , ;		//DVAGENCIA	
							NN7->NN7_CODCTA, ;		//CONTA	
							NN7->NN7_DVCTA } )		//DVCONTA
			NN7->(dbSkip())
		EndDo
	EndIf 	
Return ( aReturn )

/** {Protheus.doc} fNNYMacro
Macro Word - Tabela NNY - Dados Cadencia

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	27/04/2016
@Uso: 		SIGAAGR
*/ 
Static Function fNNYMacro()
	Local aReturn 	:= {}
	Local cEntOri	:= ""
	Local cEntDes	:= ""

	dbSelectArea("NNY")
	dbSetOrder(1)		//NNY_FILIAL+NNY_CODCTR+NNY_ITEM
	If dbSeek(xFilial("NNY")+NJR->NJR_CODCTR)
		While !Eof() .AND. NNY->NNY_FILIAL = xFilial("NNY") .AND. NNY->NNY_CODCTR = NJR->NJR_CODCTR			
			
			cEntOri	:= Alltrim(NNY->NNY_ENTORI)+" - "+POSICIONE("NJ0",1,XFILIAL("NJ0")+NNY->NNY_ENTORI+NNY->NNY_LOJORI,"NJ0_NOME")+" - Loja: "+Alltrim(NNY->NNY_LOJORI)
			cEntDes	:= Alltrim(NNY->NNY_ENTDES)+" - "+POSICIONE("NJ0",1,XFILIAL("NJ0")+NNY->NNY_ENTDES+NNY->NNY_LOJDES,"NJ0_NOME")+" - Loja: "+Alltrim(NNY->NNY_LOJDES)
			
			aAdd(aReturn,{	NNY->NNY_DATINI, ;		//DATA INICIAL		   
							NNY->NNY_DATFIM, ;		//DATA FINAL	
							NNY->NNY_QTDINT, ;		//QUANTIDADE 			
							cEntOri		   , ;		//ENTIDADE ORIGEM  - NOME -LOJA ORIGEM
							cEntDes		   } )		//ENTIDADE DESTINO - NOME -LOJA DESTINO
			NNY->(dbSkip())
		EndDo
	EndIf 	
Return ( aReturn )

/** {Protheus.doc} fNNFMacro
Macro Word - Tabela NNF - Dados Corretoras

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	27/04/2016
@Uso: 		SIGAAGR
*/ 
Static Function fNNFMacro()
	Local aReturn 	:= {}
	Local cEntidade	:= ""
	Local cCorretor := ""

	dbSelectArea("NNF")
	dbSetOrder(1)		//NNF_FILIAL+NNF_CODCTR+NNF_ITEM
	If dbSeek(xFilial("NNF")+NJR->NJR_CODCTR)
		While !Eof() .AND. NNF->NNF_FILIAL = xFilial("NNF") .AND. NNF->NNF_CODCTR = NJR->NJR_CODCTR			
			
			cEntidade := Alltrim(NNF->NNF_CODENT)+" - "+POSICIONE("NJ0",1,XFILIAL("NJ0")+NNF->NNF_CODENT+NNF->NNF_LOJENT,"NJ0_NOME")
			cCorretor := Alltrim(NNF->NNF_CDCORR)+" - "+Alltrim(POSICIONE('SU5',1,XFILIAL('SU5')+NNF->NNF_CDCORR,'U5_CONTAT'))

			aAdd(aReturn,{	cEntidade		, ;		//COD ENT - NOME FAV		   
							cCorretor		, ;		//COD CORRETORA - NOM CORRETORA			
							NNF->NNF_VLBCOM	, ;		//VALOR COMISSAO
							NNF->NNF_PCBCOM	} ) 	//% COMISSAO
									
			NNF->(dbSkip())
		EndDo
	EndIf 	
Return ( aReturn )

/** {Protheus.doc} fNNGMacro
Macro Word - Tabela NNG - Dados Cessao de Credito

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	27/04/2016
@Uso: 		SIGAAGR
*/ 
Static Function fNNGMacro()
	Local aReturn 	:= {}
	Local cFavore	:= ""

	dbSelectArea("NNG")
	dbSetOrder(1)		//NNG_FILIAL+NNG_CODCTR+NNG_ITEM
	If dbSeek(xFilial("NNG")+NJR->NJR_CODCTR)
		While !Eof() .AND. NNG->NNG_FILIAL = xFilial("NNG") .AND. NNG->NNG_CODCTR = NJR->NJR_CODCTR			
			
			cFavore := Alltrim(NNG->NNG_CODFAV)+" - "+POSICIONE("SA2",1,XFILIAL("SA2")+NNG->NNG_CODFAV+NNG->NNG_LOJFAV,"A2_NOME")
			
			aAdd(aReturn,{	cFavore			, ;		//COD FAV - NOME FAV		   
							NNG->NNG_QTDCSS	, ;		//QUANTIDADE CESSAO		
							NNG->NNG_VLRCSS	, ;		//VALOR PAGAMENTO
							NNG->NNG_CODBCO	, ;		//BANCO			 
							NNG->NNG_CODAGE	, ;		//AGENCIA  		
							NNG->NNG_DVAGE 	, ;		//DVAGENCIA	
							NNG->NNG_CODCTA	, ;		//CONTA	
							NNG->NNG_DVCTA 	} )		//DVCONTA							
									
			NNG->(dbSkip())
		EndDo
	EndIf 
Return ( aReturn )
