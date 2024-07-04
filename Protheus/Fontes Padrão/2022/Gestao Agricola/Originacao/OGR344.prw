#INCLUDE "MSOLE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "OGR344.CH"

/** {Protheus.doc} 
BASEADO NA ROTINA DE INTEGRACAO DO RH - GPEWORD
Rotina de Integracao com MS-Word - CONTRATOS - ADITIVOS

@param: 	cContrato - cTipCtr
@author: 	Ana Laura Olegini
@since: 	24/02/2016
@Uso: 		SIGAAGR
*/ 
Function OGR344(cContrato, cItemFx)
	
	//Declaracao de arrays para dimensionar tela		
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}

	Private	cPerg		:= ""
	
	Private aInfo		:= {}
	Private nDepen		:= 0
	
	//*Variaveis de parametros
	Private cContrato   := cContrato
	Private cItemFx		:= cItemFx
	Private cTipCtr		:= ""
	Private oDlg		:= NIL	

	If Empty(cContrato)
		MsgInfo(STR0029)	//"Não foi possível encontrar o contrato!"
		Return
	EndIf
	
	dbSelectArea("NJR")
	dbSetOrder(1)
	If dbSeek(xFilial("NJR")+cContrato)
		cTipCtr	:= NJR->NJR_TIPO
	EndIf
	NJR->(dbCloseArea())
	
	//*=================================================================================
	//* CRIADO UM PERGUNTE PARA CADA TIPO DE CONTRATO PARA SALVAR O CAMINHO DOS ARQUIVOS
	//*=================================================================================
	If cTipCtr == "1" 		//Compra
		cPerg := "OGR344T1"
		//tratando os espacos do novo tamanho do X1_GRUPO
		cPerg := cPerg + (Space( 10 - Len(cPerg) ) )

		Pergunte(cPerg,.F.)
	ElseIf cTipCtr == "2"	//Venda
		cPerg := "OGR344T2"
		//tratando os espacos do novo tamanho do X1_GRUPO
		cPerg := cPerg + (Space( 10 - Len(cPerg) ) )

		Pergunte(cPerg,.F.)
	ElseIf cTipCtr == "3"	//Armazenagem De 3
		cPerg := "OGR344T3"
		//tratando os espacos do novo tamanho do X1_GRUPO
		cPerg := cPerg + (Space( 10 - Len(cPerg) ) )

		Pergunte(cPerg,.F.)
 	ElseIf cTipCtr == "4"	//Armazenagem Em 3
		cPerg := "OGR344T4"
		//tratando os espacos do novo tamanho do X1_GRUPO
		cPerg := cPerg + (Space( 10 - Len(cPerg) ) )

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
	aGdCoord := { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*20), (((aObjSize[1,4])/100)*59) }	//1,3 Vertical /1,4 Horizontal

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL		//"Integração Com Ms-word"
	
	@ aGdCoord[1],aGdCoord[2] TO aGdCoord[3],aGdCoord[4]   PIXEL
	@ aGdCoord[1]+10,aGdCoord[2]+10 SAY OemToAnsi(STR0008) PIXEL	//"Impressão de documentos no Word."
	@ aGdCoord[1]+20,aGdCoord[2]+10 SAY OemToAnsi(STR0009) PIXEL	//"Serão impressos de acordo com a Seleção Dos Parâmetros."

	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-95 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg,.T.) 
		
	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-60 BUTTON OemToAnsi(STR0010) SIZE 55,11 ACTION fVarW_Imp() //"Impr. _Variáveis"
	@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+5  BUTTON OemToAnsi(STR0011) SIZE 55,11 ACTION fWord_Imp(cContrato, cItemFx) //"Impr. _Documento"
	                                                                                                                         
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
	Local cString		:= 'NNW'
	Local aOrd			:= {STR0019,STR0020}	//"Variável"#"Descrição Da Variável"

	/*Define Variaveis Privates Basicas*/
	Private NomeProg	:= 'OGR344'
	Private AT_PRG		:= NomeProg
	Private aReturn		:= {"Código de barras", 1,"Administração", 2, 2, 1, '',1 }
	Private cDesc1		:= STR0021	//"Relatório Das Variáveis Gpe_word."
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

	/*Carregando Informacoes da Empresa*/
	IF !fInfo(@aInfo,xFilial("NNW"))
		Return( NIL )
	EndIF

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
Static Function fWord_Imp(cContrato, cItemFx)
	Local oWord		:= NIL

	Local cNomeAq 	:= ""

	/*PARAMETROS*/
	Local cArqWord 	:= mv_par01		//local do arquivo
	Local cDestino 	:= mv_par02		//local destino do arquivo
	
	
	// *Checa o SO do Remote (1=Windows, 2=Linux)
	If GetRemoteType() == 2
		MsgAlert(OemToAnsi(STR0025), OemToAnsi(STR0026))	//"A integração word funciona somente com windows!!!"#"Atenção !"	
		Return
	EndIf

	If Empty(cArqWord)
		Help( , , STR0027, , STR0032, 1, 0 )		//"AJUDA"#"Local não informado!"
		Return
	EndIf

	// *CONECTA COM WORD
	oWord	:= OLE_CreateLink()  
	OLE_NewFile( oWord , cArqWord )

	cNomeAq := STR0033+ AllTrim(cContrato) + STR0034 + AllTrim(cItemFx) +".docx"			//"BoletaFixacao_Ctr_"#"_ItemFx_"
	
	dbSelectArea('NN8')
	dbSetOrder(1)
	If dbSeek(xFilial('NN8')+cContrato+cItemFx)	

		/*Carrega Campos Disponiveis para Edicao*/
		aCampos := fCpos_Word()
		If Empty(aCampos)
			/*Encerrando o Link com o Documento*/
			OLE_CloseLink(oWord)
			Return
		EndIf
		
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
														Transform( x[2] , x[3] )		                               	;
											  ) 					 	 		 										;
										)																	 			;
				}  						   																 				;
			) 	
   		
		/*Atualiza as Variaveis*/
		OLE_UpDateFields( oWord )
		
		/*Imprimindo o Documento */
		//OLE_SetProperty( oWord, '208', .F. ) 
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
	Local aRet	:= {}
	
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
	Local	cObseAdicio	:= ""
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
	Local	cMunVended	:= ""
	Local	cEstVended	:= ""
	Local	nQteNaf		:= 0

	Local	cTipoFixac	:= ""	
	Local	cStatusFix	:= ""
	Local	cDescIdxFix	:= ""
	
	//*=================================================================================
	//*INICIA A CRIACAO DE VARIAVEIS PARA WORD			
	//*=================================================================================
	aAdd( aExp, {'AGR_FIXFILIAL'			,NN8->NN8_FILIAL		, "NN8->NN8_FILIAL"			, STR0035 })	//"Filial da Fixação"
	aAdd( aExp, {'AGR_FIXCONTRATO'			,NN8->NN8_CODCTR		, "NN8->NN8_CODCTR"			, STR0036 })	//"Contrato da Fixação" 
	aAdd( aExp, {'AGR_FIXITEMFIX'			,NN8->NN8_ITEMFX		, "NN8->NN8_ITEMFX"			, STR0037 })	//"Item da Fixação" 
	
	cTipoFixac 	:= If(NN8->NN8_TIPOFX=="0",STR0039,STR0040)	 //0=Prevista;1=Firme
	aAdd( aExp, {'AGR_FIXTIPOFIX'			,cTipoFixac				, "@!"						, STR0038 })	//"Tipo da Fixação" 
	
	cStatusFix	:= If(NN8->NN8_STATUS=="0",STR0039, If(NN8->NN8_STATUS=="1",STR0041, If(NN8->NN8_STATUS=="2",STR0042,STR0043))) //0=Prevista;1=Aberta;2=Parcial;3=Fechada
	aAdd( aExp, {'AGR_FIXSTATUS'			,cStatusFix				, "@!"						, STR0044 })	//"Status da Fixação" 
	
	aAdd( aExp, {'AGR_FIXDATA'				,NN8->NN8_DATA			, "NN8->NN8_DATA"			, STR0045 })	//"Data da Fixação" 
	aAdd( aExp, {'AGR_FIXDATINI'			,NN8->NN8_DATINI		, "NN8->NN8_DATINI"			, STR0046 })	//"Data Início Entrega da Fixação" 
	aAdd( aExp, {'AGR_FIXDATFIN'			,NN8->NN8_DATFIN		, "NN8->NN8_DATFIN"			, STR0047 })	//"Data Final Entrega da Fixação" 
	
	aAdd( aExp, {'AGR_FIXQTDFIX'			,NN8->NN8_QTDFIX		, "NN8->NN8_QTDFIX"			, STR0048 })	//"Quantidade Fixada" 
	aAdd( aExp, {'AGR_FIXQTDENT'			,NN8->NN8_QTDENT		, "NN8->NN8_QTDENT"			, STR0049 })	//"Quantidade Entregue da Fixacao" 
	
	nQteNaf	:= Og430IniEV(NN8->NN8_CODCTR)
	aAdd( aExp, {'AGR_FIXQTENAF'			,nQteNaf				, "@E 999,999,999.99"		, STR0050 })	//"Quantidade Entregue a Fixar" 
	
	aAdd( aExp, {'AGR_FIXQTDRES'			,NN8->NN8_QTDRES		, "NN8->NN8_QTDRES"			, STR0051 })	//"Quantidade Reservada da Fixação" 
	
	aAdd( aExp, {'AGR_FIXCODIDX'			,NN8->NN8_CODIDX		, "NN8->NN8_CODIDX"			, STR0052 })	//"Código Indice de Mercado da Fixação" 
	cDescIdxFix := POSICIONE("NK0",1,XFILIAL("NK0")+NN8->NN8_CODIDX,"NK0_DESCRI")
	aAdd( aExp, {'AGR_FIXDESCIDX'			,cDescIdxFix			, "@!"						, STR0053 })	//"Descrição Indice de Mercado da Fixação" 
	
	aAdd( aExp, {'AGR_FIXMOEDA'				,NN8->NN8_MOEDA			, "NN8->NN8_MOEDA"			, STR0054 })	//"Código da Moeda da Fixação" 
	aAdd( aExp, {'AGR_FIXTXMOED'			,NN8->NN8_TXMOED		, "NN8->NN8_TXMOED"			, STR0055 })	//"Taxa da Moeda da Fixação" 
	aAdd( aExp, {'AGR_FIXVLRUNI'			,NN8->NN8_VLRUNI		, "NN8->NN8_VLRUNI"			, STR0056 })	//"Valor Unitário na Moeda 1 da Fixação" 
	aAdd( aExp, {'AGR_FIXVALUNI'			,NN8->NN8_VALUNI		, "NN8->NN8_VALUNI"			, STR0057 })	//"Valor Unitário da Fixação" 
	aAdd( aExp, {'AGR_FIXVLRTOT'			,NN8->NN8_VLRTOT		, "NN8->NN8_VLRTOT"			, STR0058 })	//"Valor Total na Moeda 1 da Fixação" 
	aAdd( aExp, {'AGR_FIXVLRLQT'			,NN8->NN8_VLRLQT		, "NN8->NN8_VLRLQT"			, STR0059 })	//"Valor Líquido Sem Impostos Moeda"
	aAdd( aExp, {'AGR_FIXVALTOT'			,NN8->NN8_VALTOT		, "NN8->NN8_VALTOT"			, STR0060 })	//"Valor Total da Fixação"
	aAdd( aExp, {'AGR_FIXVALLQT'			,NN8->NN8_VALLQT		, "NN8->NN8_VALLQT"			, STR0061 })	//"Valor Total Fixado Líquido Sem Imposto"
	aAdd( aExp, {'AGR_FIXVLENT'				,NN8->NN8_VLENT			, "NN8->NN8_VLENT"			, STR0062 })	//"Valor Total Entregue da Fixação" 
	aAdd( aExp, {'AGR_FIXVLRLIQ'			,NN8->NN8_VLRLIQ		, "NN8->NN8_VLRLIQ"			, STR0063 })	//"Valor Líquido na Moeda 1 da Fixação" 
	aAdd( aExp, {'AGR_FIXVALLIQ'			,NN8->NN8_VALLIQ		, "NN8->NN8_VALLIQ"			, STR0064 })	//"Valor Líquido da Fixação" 
	aAdd( aExp, {'AGR_FIXQTDFIN'			,NN8->NN8_QTDFIN		, "NN8->NN8_QTDFIN"			, STR0065 })	//"Quantidade Financeira da Fixação" 
	aAdd( aExp, {'AGR_FIXVLRFIN'			,NN8->NN8_VLRFIN		, "NN8->NN8_VLRFIN"			, STR0066 })	//"Valor Financeiro da Fixação" 
	aAdd( aExp, {'AGR_FIXFREFIN'			,NN8->NN8_FREFIN		, "NN8->NN8_FREFIN"			, STR0067 })	//"Valor Frete em OP/OR" 
	aAdd( aExp, {'AGR_FIXSEGFIN'			,NN8->NN8_SEGFIN		, "NN8->NN8_SEGFIN"			, STR0068 })	//"Valor Seguro em OP/OR"
	aAdd( aExp, {'AGR_FIXDSPFIN'			,NN8->NN8_DSPFIN		, "NN8->NN8_DSPFIN"			, STR0069 })	//"Valor Despesa em OP/OR"
	aAdd( aExp, {'AGR_FIXDTPAGT'			,NN8->NN8_DTPAGT		, "NN8->NN8_DTPAGT"			, STR0070 })	//"Data Prevista para Pagamento"
	
	//*=================================================================================
	//* TABELA DE CONTRATO 			
	//*=================================================================================
	dbSelectArea("NJR")
	dbSetOrder(1)
	If dbSeek(xFilial("NJR")+NN8->NN8_CODCTR)
		aAdd( aExp, {'AGR_FILIAL'			, NJR->NJR_FILIAL 			, "NJR->NJR_FILIAL"		, STR0071 })	//"Filial do Contrato"
		aAdd( aExp, {'AGR_CONTRATO'			, NJR->NJR_CODCTR			, "NJR->NJR_CODCTR"		, STR0072 })	//"Código do Contrato"
		aAdd( aExp, {'AGR_ULTALTERA'		, NJR->NJR_ULTALT			, "NJR->NJR_ULTALT"		, STR0073 })	//"Última Alteração"
		aAdd( aExp, {'AGR_DESCRICAO'		, NJR->NJR_DESCRI 			, "NJR->NJR_DESCRI"		, STR0074 })	//"Descrição do Contrato"
		
		//*Descrição do Tipo de Contrato
		cDesTipCtr := If(NJR->NJR_TIPO=="1",STR0075,( If(NJR->NJR_TIPO=="2",STR0076,( If(NJR->NJR_TIPO=="3",STR0077,(If(NJR->NJR_TIPO=="4",STR0078,"")))))))	//"Compra"#"Venda"#"Armazenagem De 3"#"Armazenagem Em 3"
		aAdd( aExp, {'AGR_DESTIPO'			, cDesTipCtr			  	, "@!"					, STR0079 })	//"Tipo do Contrato" 
		aAdd( aExp, {'AGR_DATACTR'			, NJR->NJR_DATA				, "NJR->NJR_DATA"		, STR0080 })	//"Data do Contrato"
		
		//*****************************************
		// Dados da Entidade
		aAdd( aExp, {'AGR_CODENTIDADE'		, NJR->NJR_CODENT			, "NJR->NJR_CODENT"		, STR0081 })	//"Código da Entidade"
		aAdd( aExp, {'AGR_LOJENTIDADE'		, NJR->NJR_LOJENT			, "@!"					, STR0082 })	//"Loja da Entidade"	
		cNomeEntid := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_NOME")
		cNomeLjEnt := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_NOMLOJ")	
		aAdd( aExp, {'AGR_NOMENTIDADE'		, cNomeEntid				, "@!"					, STR0083 })	//"Nome da Entidade"
		aAdd( aExp, {'AGR_NOMLJENTIDA'		, cNomeLjEnt				, "@!"					, STR0084 })	//"Nome Loja da Entidade"

		// Dados da Entidade por tipo de contrato
		// *Para compra = Fornecedor  
		// *Para venda  = Cliente		
		If NJR->NJR_TIPO=="1"	//"1=Compra"
			cCodVended := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_CODFOR")	//Codigo Fornecedor
			cLojVended := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_LOJFOR")	//Codigo Loja	
			cTpDoc	   := 'E'
			
			//Tabela SA2 - Fornecedor
			cNomVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_NOME')			//Nome Fornecedor
			cNomLjVend := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_NREDUZ')		//Nome Loja
		
			//** Tratando CPF ou CNPJ
			cTipVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_TIPO') 		//F=Fisico;J=Juridico;X=Outros
			cDescTipVen:= If(cTipVended=="F",STR0085, If(cTipVended=="J",STR0086,STR0087))
			If cTipVended == "J"
				cCPFVend := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_CGC')		//CPF
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
				cCnpj2 := Substr( cCPFVend , 5,7)
				cCnpj3 := Substr( cCPFVend , 9,11)
				cCnpj4 := Substr( cCPFVend , 13,14)
				
				cCPFVend:= cCnpj1+'.'+cCnpj2+'.'+cCnpj3+'-'+cCnpj4			
			Else
				cCPFVend := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_CGC')		//CPF
			EndIf 
			
			cIEVendedo := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_INSCR')		//Inscrição Estadual
			cEndVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_END')			//Endereço
			cBaiVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_BAIRRO')		//Bairro
			cMunVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_MUN')			//Municipio
			cEstVended := POSICIONE('SA2',1,XFILIAL('SA2')+cCodVended+cLojVended,'A2_EST')			//Estado	
		EndIf

		If NJR->NJR_TIPO=="2"	//"2=Venda"
			cCodVended := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_CODFOR")	//Codigo Cliente
			cLojVended := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_LOJFOR")	//Codigo Loja	
			cTpDoc	   := 'S'
			
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
				cCPFVend := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_CGC')		//CPF
				cRGVende := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_PFISICA')	//RG
				
				cCnpj1 := Substr( cCPFVend , 1,3)
				cCnpj2 := Substr( cCPFVend , 5,7)
				cCnpj3 := Substr( cCPFVend , 9,11)
				cCnpj4 := Substr( cCPFVend , 13,14)
				
				cCPFVend:= cCnpj1+'.'+cCnpj2+'.'+cCnpj3+'-'+cCnpj4			
			Else
				cCPFVend := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_CGC')		//CPF
			EndIf 
			
			cIEVendedo := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_INSCR')		//Inscrição Estadual
			cEndVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_END')			//Endereço
			cBaiVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_BAIRRO')		//Bairro
			cMunVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_MUN')			//Municipio
			cEstVended := POSICIONE('SA1',1,XFILIAL('SA1')+cCodVended+cLojVended,'A1_EST')			//Estado	
		EndIf		
		
		aAdd( aExp, {'AGR_CODVENDEDOR'		, Alltrim(cCodVended)		, "@!"						, STR0088 })	//"Código do Vendedor"
		aAdd( aExp, {'AGR_LOJAVENDEDOR'		, Alltrim(cLojVended)		, "@!"						, STR0089 })	//"Loja do Vendedor"
		aAdd( aExp, {'AGR_NOMEVENDEDOR'		, Alltrim(cNomVended)		, "@!"						, STR0090 })	//"Nome do Vendedor"
		aAdd( aExp, {'AGR_NOMLJVENDEDOR'	, Alltrim(cNomLjVend)		, "@!"						, STR0091 })	//"Nome Loja do Vendedor"
		aAdd( aExp, {'AGR_DESCTIPVENDED'	, Alltrim(cDescTipVen)		, "@!"						, STR0092 })	//"Descrição do Tipo do Vendedor"
		aAdd( aExp, {'AGR_CPFVENDEDOR'		, Alltrim(cCPFVend)			, "@!"						, STR0093 })	//"CPF do Vendedor"
		aAdd( aExp, {'AGR_RGVENDEDOR'		, Alltrim(cRGVende)			, "@!"						, STR0094 })	//"RG do Vendedor"
		aAdd( aExp, {'AGR_IEVENDEDOR'		, Alltrim(cIEVendedo)		, "@!"						, STR0095 })	//"IE do Vendedor"
		aAdd( aExp, {'AGR_ENDVENDEDOR'		, Alltrim(cEndVended)		, "@!"						, STR0096 })	//"Endereço do Vendedor"
		aAdd( aExp, {'AGR_BAIVENDEDOR'		, Alltrim(cBaiVended)		, "@!"						, STR0097 })	//"Bairro do Vendedor"
		aAdd( aExp, {'AGR_MUNVENDEDOR'		, Alltrim(cMunVended)		, "@!"						, STR0098 })	//"Municipio do Vendedor"
		aAdd( aExp, {'AGR_ESTVENDEDOR'		, Alltrim(cEstVended)		, "@!"						, STR0099 })	//"Estado do Vendedor"

		//----------------------------------------------------------------------------------------------------------
		nVlrFun := OG430FTxa(cTpDoc, cCodVended, cLojVended, NJR->NJR_CODPRO, NJR->NJR_TESEST, 1, NN8->NN8_VLRTOT )
		aAdd( aExp, {'AGR_FIXVLRFUNR'		, nVlrFun					, "@E 999,999,999.99"		, STR0197 })	//"Valor do Funrural"
		
		aAdd( aExp, {'AGR_CODTERCEIROS'		, NJR->NJR_CODTER			, "NJR->NJR_CODTER"			, STR0100 })	//"Código de Terceiros"
		aAdd( aExp, {'AGR_LOJTERCEIROS'		, NJR->NJR_LOJTER			, "NJR->NJR_LOJTER"			, STR0101 })	//"Loja de Terceiros"
		
		//*Dados Terceiro
		cNomeTerce := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODTER+NJR->NJR_LOJTER,"NJ0_NOME")
		cNomeLjTer := POSICIONE("NJ0",1,XFILIAL("NJ0")+NJR->NJR_CODTER+NJR->NJR_LOJTER,"NJ0_NOMLOJ")				
		aAdd( aExp, {'AGR_NOMETERCEIROS'	, cNomeTerce				, "@!"						, STR0102 })	//"Nome de Terceiros"
		aAdd( aExp, {'AGR_NOMLJTERCEIROS'	, cNomeLjTer				, "@!"						, STR0103 })	//"Nome Loja de Terceiros"
		
		//*Operação Triangular	
		cOperTrang := If(NJR->NJR_OPETRI=="1",STR0110,STR0111)	//"Sim"#"Não"
		//*Operação Venda Futura	
		cOperVeFut := If(NJR->NJR_OPEFUT=="1",STR0110,STR0111)	//"Sim"#"Não"
		aAdd( aExp, {'AGR_OPERTRIANGULAR'	, cOperTrang				, "@!"						, STR0104 })	//"Operação Triangular"
		aAdd( aExp, {'AGR_OPERVENDAFUTURA'	, cOperVeFut				, "@!"						, STR0105 })	//"Operação Venda Futura"
		
		aAdd( aExp, {'AGR_CODOPERACAO'		, NJR->NJR_CODOPE			, "NJR->NJR_CODOPE"			, STR0106 })	//"Código da Operação"	
		cDescOpera := POSICIONE("NNO",1,XFILIAL("NNO")+NJR->NJR_CODOPE,"NNO_DESCRI")
		aAdd( aExp, {'AGR_DESCOPERACAO'		,cDescOpera					, "@!"						, STR0107 })	//"Descrição da Operação"
	
		aAdd( aExp, {'AGR_CODSAFRA'			,NJR->NJR_CODSAF			, "NJR->NJR_CODSAF"			, STR0108 })	//"Código da Safra"
		cDescSafra	:= POSICIONE("NJU",1,XFILIAL("NJU")+NJR->NJR_CODSAF,"NJU_DESCRI")	
		aAdd( aExp, {'AGR_DESCSAFRA'		,cDescSafra					, "@!"						, STR0109 })	//"Descrição da Safra"
		
		aAdd( aExp, {'AGR_TALHAO'			,NJR->NJR_TALHAO			, "NJR->NJR_TALHAO"			, STR0112 })	//"Código do Talhão"
	
		aAdd( aExp, {'AGR_CODPRODUTO'		,NJR->NJR_CODPRO			, "NJR->NJR_CODPRO"			, STR0113 })	//"Código do Produto"
		cDescProdut := Posicione('SB1',1,xFilial('SB1')+NJR->NJR_CODPRO,'B1_DESC')
		aAdd( aExp, {'AGR_DESPRODUTO'		,cDescProdut				, "@!"						, STR0114 })	//"Descrição do Produto"
		
		aAdd( aExp, {'AGR_UNIMEDPRO1'		,NJR->NJR_UM1PRO			, "NJR->NJR_UM1PRO"			, STR0115 })	//"Unidade de Medida do Produto"
		
		aAdd( aExp, {'AGR_CODTABELA'		,NJR->NJR_TABELA			, "NJR->NJR_TABELA"			, STR0116 })	//"Código da Tabela de Descontos"
		cDescTabel	:= Posicione('NNI',1,xFilial('NNI')+NJR->NJR_TABELA,'NNI_DESCRI')
		aAdd( aExp, {'AGR_DESTABELA'		,cDescTabel					, "@!"						, STR0117 })	//"Descrição da Tabela de Descontos"
		
		aAdd( aExp, {'AGR_CODCTRRPC'		,NJR->NJR_CODRPC			, "NJR->NJR_CODRPC"			, STR0118 })	//"Código Contrato RPC"
		
		aAdd( aExp, {'AGR_CODOPERFISCAL'	,NJR->NJR_OPEFIS			, "NJR->NJR_OPEFIS"			, STR0119 })	//"Código Operação Fiscal"	
		cDescOpFis	:= Posicione('SX5',1,xFilial('NJR')+'DJ'+NJR->NJR_OPEFIS,'X5_DESCRI')  
		aAdd( aExp, {'AGR_DESOPERFISCAL'	,cDescOpFis					, "@!"						, STR0120 })	//"Descrição Operação Fiscal"
		
		aAdd( aExp, {'AGR_TESMOVESTOQUE'	,NJR->NJR_TESEST			, "NJR->NJR_TESEST"			, STR0121 })	//"Cod. TES p/ Mov. Estoque"	
		
		aAdd( aExp, {'AGR_TESMOVFINANCEIRO'	,NJR->NJR_TESFIN			, "NJR->NJR_TESFIN"			, STR0122 })	//"Cod. TES p/ Mov. Financeiro"
	
		aAdd( aExp, {'AGR_TESQUEBRATECNICA'	,NJR->NJR_TESQTE			, "NJR->NJR_TESQTE"			, STR0123 })	//"Cod. TES Quebra Técnica"
	
		aAdd( aExp, {'AGR_TESRETORNOSIMBOL'	,NJR->NJR_TESRSI			, "NJR->NJR_TESRSI"			, STR0124 })	//"Cod. TES Retorno Simbolico"
	
		aAdd( aExp, {'AGR_TIPOEMBALAGEM'	,NJR->NJR_TIPEMB			, "NJR->NJR_TIPEMB"			, STR0125 })	//"Tipo de Embalagem"
	
		aAdd( aExp, {'AGR_MENSAGEMFISCAL'	,NJR->NJR_MSGNFS			, "NJR->NJR_MSGNFS"			, STR0126 })	//"Mensagem do Documento Fiscal"
		
		cObseAdicio := Alltrim(MSMM(NJR->NJR_OBSADT,80)) 
		aAdd( aExp, {'AGR_OBSADICIONAL' 	, cObseAdicio				, "@!"						, STR0127 })	//"Observacao Adicional"
		
		aAdd( aExp, {'AGR_QUANTIDADEINCIAL'	, NJR->NJR_QTDINI			, "NJR->NJR_QTDINI"			, STR0128 })	//"Quantidade Inicial"
		
		aAdd( aExp, {'AGR_QUANTIDADECONTRA'	, NJR->NJR_QTDCTR			, "NJR->NJR_QTDCTR"			, STR0129 })	//"Quantidade Contratada"
	
		aAdd( aExp, {'AGR_QUANTIDADEAUTENT'	, NJR->NJR_AUTENT			, "NJR->NJR_AUTENT"			, STR0130 })	//"Quantidade Autorizada Entrada"
		
		aAdd( aExp, {'AGR_QUANTIDADEAUTSAI'	, NJR->NJR_AUTSAI			, "NJR->NJR_AUTSAI"			, STR0131 })	//"Quantidade Autorizada Saída"
	
		//*QTDS ENTRADA	
		aAdd( aExp, {'AGR_QUANTIDADEENTEMB'	, NJR->NJR_QTEEMB			, "NJR->NJR_QTEEMB"			, STR0132 })	//"Quantidade Entrada de Embalagem"
		aAdd( aExp, {'AGR_QUANTIDENTFISICO'	, NJR->NJR_QTEFCO			, "NJR->NJR_QTEFCO"			, STR0133 })	//"Quantidade de Entrada Fisico"
		aAdd( aExp, {'AGR_QUANTIDENTFISCAL'	, NJR->NJR_QTEFIS			, "NJR->NJR_QTEFIS"			, STR0134 })	//"Quantidade de Entrada Fiscal"
		aAdd( aExp, {'AGR_VALORENTFISCAL'	, NJR->NJR_VLEFIS			, "NJR->NJR_VLEFIS"			, STR0135 })	//"Valor de Entrada Fiscal"
		
		//*QTDS SAIDA
		aAdd( aExp, {'AGR_QUANTIDADESAIEMB'	, NJR->NJR_QTSEMB			, "NJR->NJR_QTSEMB"			, STR0136 })	//"Quantidade Saída de Embalagens"
		aAdd( aExp, {'AGR_QUANTIDSAIFISICO'	, NJR->NJR_QTSFCO			, "NJR->NJR_QTSFCO"			, STR0137 })	//"Quantidade de Saída Fisico"
		aAdd( aExp, {'AGR_QUANTIDSAIFISCAL'	, NJR->NJR_QTSFIS			, "NJR->NJR_QTSFIS"			, STR0138 })	//"Quantidade de Saída Fiscal"
		aAdd( aExp, {'AGR_VALORSAIFISCAL'	, NJR->NJR_VLSFIS			, "NJR->NJR_VLSFIS"			, STR0139 })	//"Valor de Saída Fiscal"
		
		//*QTDS SALDO
		aAdd( aExp, {'AGR_QUANTIDADESALEMB'	, NJR->NJR_QSLEMB			, "NJR->NJR_QSLEMB"			, STR0140 })	//"Quantidade Saldo Embalagem"
		aAdd( aExp, {'AGR_QUANTIDSALFISICO'	, NJR->NJR_QSLFCO			, "NJR->NJR_QSLFCO"			, STR0141 })	//"Quantidade de Saldo Fisico"
		aAdd( aExp, {'AGR_QUANTIDSALFISCAL'	, NJR->NJR_SLDFIS			, "NJR->NJR_SLDFIS"			, STR0142 })	//"Quantidade de Saldo Fiscal"
		aAdd( aExp, {'AGR_VALORSALFISCAL'	, NJR->NJR_SLDTOT			, "NJR->NJR_SLDTOT"			, STR0143 })	//"Valor de Saldo Fiscal"
	
		aAdd( aExp, {'AGR_QUANTIDADERESERV'	, NJR->NJR_QTDRES			, "NJR->NJR_QTDRES"			, STR0144 })	//"Quantidade Reservada"
	
		cTipoQueTec := If(NJR->NJR_TIPFIX=="1",STR0146,STR0147)	//1=Fixo;2=A Fixar
		aAdd( aExp, {'AGR_TIPOQUEBRATEC'	, cTipoQueTec				, "@!"						, STR0148 })	//"Tipo de Fixação"
		
		aAdd( aExp, {'AGR_VALORUNITBASE'	, NJR->NJR_VLRBAS			, "NJR->NJR_VLRBAS"			, STR0149 })	//"Valor Unitario Base"
		
		//*Moeda do Contrato
		aAdd( aExp, {'AGR_CODIGOMOEDA'		, NJR->NJR_MOEDA			, "NJR->NJR_MOEDA"			, STR0150 })	//"Codigo da Moeda"
		cDescMoeda := SuperGetMv("MV_MOEDA"+AllTrim(Str(NJR->NJR_MOEDA,2)))
		cSimbMoeda := SuperGetMv("MV_SIMB"+AllTrim(Str(NJR->NJR_MOEDA,2))) 	
		aAdd( aExp, {'AGR_DESCMOEDA'		, cDescMoeda				, "@!"						, STR0151 })	//"Descrição da Moeda"
		aAdd( aExp, {'AGR_SIMBMOEDA'		, cSimbMoeda				, "@!"						, STR0152 })	//"Símbolo da Moeda" 				
		aAdd( aExp, {'AGR_TAXAMOEDA'		, NJR->NJR_TXMOED			, "NJR->NJR_TXMOED"			, STR0153 })	//"Taxa da Moeda"
	
		aAdd( aExp, {'AGR_VALORUNITARIO'	, NJR->NJR_VLRUNI			, "NJR->NJR_VLRUNI"			, STR0154 })	//"Valor Unitario"
		
		aAdd( aExp, {'AGR_UNIDADEPRECO'		, NJR->NJR_UMPRC			, "NJR->NJR_UMPRC"			, STR0155 })	//"Unidade de Preço"
	
		aAdd( aExp, {'AGR_VALORTOTCONTRATO'	, NJR->NJR_VLRTOT			, "NJR->NJR_VLRTOT"			, STR0156 })	//"Valor Total Contrato"
	
		aAdd( aExp, {'AGR_PERCLIMTCREDITO'	, NJR->NJR_PERCRD			, "NJR->NJR_PERCRD"			, STR0157 })	//"Percentual de Limite de Crédito"
				
		aAdd( aExp, {'AGR_INDICEMERCADO'	, NJR->NJR_CODIDX			, "NJR->NJR_CODIDX"			, STR0158 })	//"Indice de Mercado"
		cDescIdMerc	:= Posicione('NK0',1,xFilial('NK0')+NJR->NJR_CODIDX,'NK0_DESCRI')
		aAdd( aExp, {'AGR_DESCRIMERCADO'	, cDescIdMerc				, "@!"						, STR0159 })	//"Descrição Indice de Mercado"
			
		cIncentiDAP := If(NJR->NJR_ITVDAP=="1",STR0110,STR0111)	//1=Sim;2=Nao
		aAdd( aExp, {'AGR_POSSUIINCTDAP'	, cIncentiDAP				, "@!"						, STR0160 })	//"Possui o Incentivo DAP"
		
		cTipoFrete	:= If(NJR->NJR_ITVDAP=="C",STR0161, If(NJR->NJR_ITVDAP=="F",STR0162, If(NJR->NJR_ITVDAP=="T",STR0163,STR0164))) 	
		aAdd( aExp, {'AGR_TIPOFRETE'		, cTipoFrete				, "@!"						, STR0165 })	//"Tipo do Frete"
			
		cCtrlLogis := If(NJR->NJR_CTRLLG=="1",STR0110,STR0111)	//1=Sim;2=Nao
		aAdd( aExp, {'AGR_CONTROLALOGIST'	, cCtrlLogis				, "@!"						, STR0166 })	//"Controle de Logistica"
	
		cCtrlEntSai := If(NJR->NJR_CTRLCD=="0",STR0167, If(NJR->NJR_CTRLCD=="1",STR0168, If(NJR->NJR_CTRLCD=="2",STR0169,STR0170)))	//"Nenhum"#"Saída"#"Entrada"#"Entrada/Saída"	
		aAdd( aExp, {'AGR_CONTROLAENTSAI'	, cCtrlEntSai				, "@!"						, STR0171 })	//"Controle Entrada/Saída"
	
		cCtrTransfe := If(NJR->NJR_TRANSF=="1",STR0110,STR0111)	//1=Sim;2=Nao
		aAdd( aExp, {'AGR_CONTRATOTRANSF'	, cCtrTransfe				, "@!"						, STR0172 })	//"Contrato de Transferencia"
	
		cModeloCTR	:= If(NJR->NJR_MODELO=="1",STR0173, If(NJR->NJR_MODELO=="2",STR0174,STR0175))	//"Pré-Contrato"#"Contrato"#"Automatico" 	
		aAdd( aExp, {'AGR_MODELOCONTRATO'	, cModeloCTR				, "@!"						, STR0176 })	//"Modelo do Contrato"
	
		aAdd( aExp, {'AGR_MODELOBASECTR'	, NJR->NJR_MODBAS			, "NJR->NJR_MODBAS"			, STR0177 })	//"Modelo Base p/ Contrato"
		cDescModCTR	:= Posicione('NJX',1,xFilial('NJX')+NJR->NJR_MODBAS,'NJX_DESCRI')
		aAdd( aExp, {'AGR_DESCMODELOCTR'	, cDescModCTR				, "@!"						, STR0178 })	//"Descrição Modelo Base p/ Contrato"
	
		cStsCtrAss := If(NJR->NJR_STSASS=="A",STR0179,STR0180)	//A=Aberto;F=Finalizado
		aAdd( aExp, {'AGR_STATUSCTRASSI'	, cStsCtrAss				, "@!"						, STR0181 })	//"Status Assinatura do Contrato"
	
		cStsCtrFis := If(NJR->NJR_STSFIS=="A",STR0179,STR0180)	//A=Aberto;F=Finalizado
		aAdd( aExp, {'AGR_STATUSCTRFIS'		, cStsCtrFis				, "@!"						, STR0182 })	//"Status Fiscal do Contrato"
	
		cStsCtrFin := If(NJR->NJR_STSFIN=="A",STR0179,STR0180)	//A=Aberto;F=Finalizado
		aAdd( aExp, {'AGR_STATUSCTRFIN'		, cStsCtrFin				, "@!"						, STR0183 })	//"Status Financeiro do Contrato"     	
	
		cStsCtrEst := If(NJR->NJR_STSEST=="A",STR0179,STR0180)	//A=Aberto;F=Finalizado
		aAdd( aExp, {'AGR_STATUSCTREST'		, cStsCtrEst				, "@!"						, STR0184 })	//"Status Estoque do Contrato"
										
		cStatusCtr := If(NJR->NJR_STATUS=="P",STR0185, If(NJR->NJR_STATUS=="A",STR0186, If(NJR->NJR_STATUS=="I",STR0187, If(NJR->NJR_STATUS=="E",STR0188,STR0189))))	//"Previsto"#"Aberto"#"Iniciado"#"Cancelado"#"Finalizado"	
		aAdd( aExp, {'AGR_STATUSCONTRATO'	, cStatusCtr				, "@!"						, STR0190 })	//"Status do Contrato"
	
		aAdd( aExp, {'AGR_CODIGOTABSERV'	, NJR->NJR_CODTSE			, "NJR->NJR_CODTSE"			, STR0191 })	//"Codigo Tabela de Servico"
		cDescTabSer	:= Posicione('NKP',1,xFilial('NKP')+NJR->NJR_CODTSE,'NKP_DESTSE')
		aAdd( aExp, {'AGR_DESCTABSERV'		, cDescTabSer				, "@!"						, STR0192 })	//"Descrição Tabela de Servico"
	
		aAdd( aExp, {'AGR_CODIGOMODCTR'		, NJR->NJR_MODAL			, "NJR->NJR_MODAL"			, STR0193 })	//"Codigo Modalidade do Contrato"
		cDescModlCtr:= POSICIONE('NK5',1,XFILIAL('NK5')+NJR->NJR_MODAL,'NK5_DESMOD')
		aAdd( aExp, {'AGR_DESCMODCTR'		, cDescModlCtr				, "@!"						, STR0194 })	//"Descrição Modalidade do Contrato"
	
		aAdd( aExp, {'AGR_INSCRICAOCAMPO'	, NJR->NJR_INSCPO			, "NJR->NJR_INSCPO"			, STR0195 })	//"Inscrição de Campo"
	Else 
		Help( , , STR0027, , STR0196, 1, 0 ) //"AJUDA"# "Contrato não encontrado."
		Return(aRet)
	EndIf

Return( aExp )
