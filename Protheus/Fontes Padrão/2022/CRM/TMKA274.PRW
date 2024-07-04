#INCLUDE "TMKA274.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"
#INCLUDE "AP5MAIL.CH"

Static lFWCodFil := FindFunction("FWCodFil")
Static lNewRolTLC := IIf( FindFunction( 'Tk280NewTC' ), Tk280NewTC(), .F. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMKA274   ºAutor  ³Vendas Clientes      º Data ³  06/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Este fonte possui somente funcoes de uso exclusivo           º±±
±±º          ³do atendimento TELECOBRANCA                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Telecobranca 						                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Tk271Htlc ³ Autor ³ Vendas Clientes       ³ Data ³ 29/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Hist¢rico das liga‡oes do Cliente na Telecobranca          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    	 ³ Telecobranca           									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Tipo de operacao (3=Inclui;4=Altera;etc.)          ³±±
±±³          ³ ExpL2 - Habilita/desabilita o get dos objetos              ³±±
±±³          ³ ExpO3 - Objeto do Folder Telecobranca                      ³±±
±±³          ³ ExpO4 - Objeto da Enchoice de Telecobranca                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Htlc(nOpc,lHabilita,oFolderTlc,oEnchTlc)

Local aArea		:= GetArea()						// Salva a area atual	
Local oDlgHist                                      // Tela
Local oObsMemo										// Objeto Memo da observacao
Local cObsMemo 	:= ""								// Variavel com a descricao da observacao
Local oEnceMemo										// Objeto Memo da observacao
Local cEnceMemo	:= ""								// Variavel com a descricao da observacao
Local oCancMemo										// Objeto Memo da observacao
Local cCancMemo	:= ""								// Variavel com a descricao da observacao
Local oMonoAs  	:= TFont():New( "Courier New",6,0)	// Fonte para o campo Memo
Local aHeadACF	:= {}								// aHeader do ACF 	- CABECALHO
Local aColsACF	:= {}								// aCols do ACF
Local oGetACF										// NewGet do ACF
Local aHeadACG	:= {}								// aHeader do ACG	- ITENS	
Local aColsACG	:= {}								// aCols do ACG
Local oGetACG										// NewGet do ACG
Local nPCodigo	:= 0								// Codigo do Atendimento
Local nUsado	:= 0								// Contador para o Acols/Aheader
Local nI		:= 0 								// Contador
Local aRdp		:= aClone(aRdpTlc) 					// Vai controlar a exibicao dos totais no rodape da tela de historico 
Local oFolderRdp									// Objeto FOLDER para os totais
Local nRow 		:= 0								// variavel auxiliar para calculo do tamanho da LINHA
Local nCol 		:= 0								// variavel auxiliar para calculo do tamanho da COLUNA
Local nOpcA     := 0 								// Flag para controlar se o Operador clicou em OK ou CANCELA
Local cPerg		:= "TMKH03"                         // Pergunte exibida para filtrar os atendimentos exibidos no historico
Local lTMKCHIST := ExistBlock("TMKCHIST") 			// P.E. na confirmacao da tela de historico de ligacoes
Local lRet		:= .F.								// Retorno da funcao
Local cQuery	:= ""								// Variavel para composicao do SELECT
Local nPosSit	:= 0
Local aAuxACols		:=	aCols						//Array auxiliar para manter o aCols da tela anterior
Local aAuxAHeader	:=	aHeader						//Array auxiliar para manter o aHeader da tela anterior
                          
If !Pergunte(cPerg,.T.) 
    RestArea(aArea)
	Return(lRet)
Endif	                                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pergunte - TMKH03                                                             ³
//³MV_PAR01 - Da Emissao                                                         ³
//³MV_PAR02 - Ate a Emissão                                                      ³
//³MV_PAR03 - Do Operador                                                        ³
//³MV_PAR04 - Ate o Operador                                                     ³
//³MV_PAR05 - Status: (1-Todos 2-Atendimento 3-Cobranca 4-Encerrado  			 ³
//³MV_PAR06 - Ligacao:(1-Ambos 2-Receptivo 3-Ativo)							     ³
//³MV_PAR07 - Ocorrencia                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

lRet:= .T.
CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o aHeader do cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ACF")
DbSetOrder(2)	// ACF_CLIENT+ACF_LOJA
#IFDEF TOP
	cQuery	:=	" SELECT	* " +;
				" FROM " +	RetSqlName("ACF") + " ACF " +;
				" WHERE	ACF.ACF_FILIAL = '" + xFilial("ACF") + "' AND" +;
				"		ACF.ACF_CLIENT = '" + M->ACF_CLIENT + "' AND" +;
				"		ACF.ACF_LOJA = '" + M->ACF_LOJA + "' AND" +;
				"		ACF.ACF_DATA 	BETWEEN '" + DTOS(MV_PAR01) + "' AND  '" + DTOS(MV_PAR02) + "' AND " +;
				"		ACF.ACF_OPERAD 	BETWEEN '" + MV_PAR03 + "' AND  '" + MV_PAR04 + "' AND " 
		If MV_PAR05 <> 1 //Todas
			cQuery += 	"ACF.ACF_STATUS = '" + STR(MV_PAR05-1,1) + "' AND "
		Endif

        If MV_PAR06 <> 1 //Todos
           	cQuery += 	"ACF.ACF_OPERA = '" + STR(MV_PAR06-1,1) + "' AND "   
		Endif

        If !Empty(MV_PAR07)//Ocorrencia 
           	cQuery += 	"ACF.ACF_MOTIVO = '"+ MV_PAR07 + "' AND "  
		Endif
		
		cQuery +=" ACF.D_E_L_E_T_ = ' '" 
		cQuery +=" ORDER BY " + SqlOrder(IndexKey())
		
		cQuery	:= ChangeQuery(cQuery)
		// MemoWrite("TK274HTLC.SQL", cQuery)
#ENDIF       

Aadd(aHeadACF,	{"","CHECKBOL","@BMP",20,00,,,"C",,"V" } )
cSeek	:= xFilial("ACF") + M->ACF_CLIENT + M->ACF_LOJA
cWhile	:= "ACF->ACF_FILIAL + ACF->ACF_CLIENT + ACF->ACF_LOJA"	
bCond	:= {||IIf(ACF->ACF_FILIAL == xFilial("ACF") .AND. ACF->ACF_CLIENT == M->ACF_CLIENT	.AND. ACF->ACF_LOJA 	== M->ACF_LOJA,.T.,.F.)}    


DbSelectArea("ACF")
DbCloseArea() 

FillGetDados(	nOpc/*nOpcX*/, "ACF"/*cAlias*/, 2/*nIndex*/, cSeek/*cSeek*/,; 
				{||&(cWhile)}/*{||&cWhile}*/, bCond/*{|| bCond,bAct1,bAct2}*/, {"ACF_OBS"}/*aNoFields*/,; 
				/*aYesFields*/, /*lOnlyYes*/, cQuery/*cQuery*/, /*bMontAcols*/, .F./*lEmpty*/,; 
				@aHeadACF/*aHeaderAux*/, @aColsACF/*aColsAux*/, {||Tk274AfterCols(@aColsACF)}/*bAfterCols*/, {||Tk274BeforeCols()}/*bBeforeCols*/,;
				/*bAfterHeader*/, "ACF"/*cAliasQry*/, {|cField|Tk274CriaVar(cField)}/*bCriaVar*/)

DbSelectArea("ACF")
DbCloseArea()

If Len(aHeadACF) > 0 
	nPCodigo := Ascan(aHeadACF, {|x| AllTrim(x[2])=="ACF_CODIGO"} )
Endif
	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao houver Historico anterior de atendimento exibe a tela vazia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aColsACF)
//	Help( " ",1,"VAZIO")
    nUsado	:=	Len(aHeadACF)
	Aadd(aColsACF,Array(nUsado+1))
	For nI := 1 To nUsado-2
		If nI <> 1
			aColsACF[Len(aColsACF)][nI] := CriaVar(aHeadACF[nI,2],.F.)
		Else
			aColsACF[Len(aColsACF)][nI] := "BR_VERDE"	
		Endif		
	Next nI	

	aColsACF[Len(aColsACF)][nUsado-1]	:= "ACG"
	aColsACF[Len(aColsACF)][nUsado]	:= 0	
	aColsACF[Len(aColsACF)][nUsado+1] := .F.
Endif


CursorArrow()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados do Produto.								     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgHist FROM 0,0 TO 580,750 TITLE STR0001 + ": " + M->ACF_DESC PIXEL  //"Historico" 
	
			

	// Cabecalho
	oGetACF := MsNewGetDados():New(40,05,95,370,0,,,,,,4096,,,,oDlgHist,aHeadACF,aColsACF)
	oGetACF:bChange := {|| Tk274HACG(@oGetACG:aHeader, @oGetACG:aCols, oGetACF:aCols[oGetACF:nAt][nPCodigo], @cObsMemo, @cEnceMemo, @cCancMemo, @aRdp ),;
							oObsMemo:Refresh(),;
							oEnceMemo:Refresh(),;
							oCancMemo:Refresh(),; 
							oGetACG:Refresh() }

	// Itens do Cabecalho
	Tk274HACG(@aHeadACG, @aColsACG, M->ACF_CODIGO)
	oGetACG := MsNewGetDados():New(98,05,155,370,0,,,,,,4096,,,,oDlgHist,aHeadACG,aColsACG)

	nPosSit := aScan(oGetACG:aHeader, {|x| AllTrim(x[2]) == "ACG_DSITCB"}) 
	If nPosSit > 0
		nPosSit := aScan(oGetACG:aHeader, {|x| AllTrim(x[2]) == "ACG_SITUAC"}) 
		If nPosSit > 0	
			oGetACG:aInfo[nPosSit][2] := " " 
			oGetACG:aInfo[nPosSit][6] := " "
			oGetACG:oBrowse:aColumns[nPosSit]:bData :=  {|| Transform(oGetACG:aCols[Iif( Len( oGetACG:aCols ) >= oGetACG:oBrowse:nAt, oGetACG:oBrowse:nAt, Len( oGetACG:aCols ) )][nPosSit],Trim(oGetACG:aHeader[nPosSit][3])) }
			oGetACG:Refresh()
		EndIf
	EndIf
	
	@ 160,05 FOLDER oFolderRdp ITEMS STR0104,STR0105 OF oDlgHist SIZE 370,60 PIXEL //"Variações"###"Saldos"
	nRow := (oFolderRdp:nHeight*.9)/2
	nCol := oFolderRdp:nWidth/2
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o rodape da tela de historicos de Telecobranca.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aRdp <> NIL
		For nI := 1 To Len(aRdp)
			aRdp[nI][2] := 0 
		Next nI
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³VARIACOES                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nRow*.10,nCol*.02  SAY STR0106 OF oFolderRdp:aDialogs[1] PIXEL //"Abatimentos"
	@ nRow*.10,nCol*.22  MSGET aRdp[1][1] VAR aRdp[1][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[1] PIXEL READONLY SIZE 70 ,9
	
	@ nRow*.35,nCol*.02 SAY STR0107 OF oFolderRdp:aDialogs[1] PIXEL //"Correções Monetária"
	@ nRow*.35,nCol*.22 MSGET aRdp[2][1] VAR aRdp[2][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[1] PIXEL READONLY SIZE 70 ,9
	
	@ nRow*.60,nCol*.02 SAY STR0108 OF oFolderRdp:aDialogs[1] PIXEL //"Juros"
	@ nRow*.60,nCol*.22 MSGET aRdp[3][1] VAR aRdp[3][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[1] PIXEL READONLY SIZE 70 ,9
	
	@ nRow*.10,nCol*.52  SAY STR0109 OF oFolderRdp:aDialogs[1] PIXEL //"Acréscimos"
	@ nRow*.10,nCol*.72  MSGET aRdp[4][1] VAR aRdp[4][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[1] PIXEL READONLY SIZE 70 ,9
	
	@ nRow*.35,nCol*.52 SAY STR0110 OF oFolderRdp:aDialogs[1] PIXEL //"Decréscimos"
	@ nRow*.35,nCol*.72 MSGET aRdp[5][1] VAR aRdp[5][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[1] PIXEL READONLY SIZE 70 ,9
	
	@ nRow*.60,nCol*.52 SAY STR0111 OF oFolderRdp:aDialogs[1] PIXEL //"Descontos"
	@ nRow*.60,nCol*.72 MSGET aRdp[6][1] VAR aRdp[6][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[1] PIXEL READONLY SIZE 70 ,9
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SALDOS                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nRow*.10,nCol*.02  SAY STR0112 OF oFolderRdp:aDialogs[2] PIXEL //"Valores Originais"
	@ nRow*.10,nCol*.22  MSGET aRdp[7][1] VAR aRdp[7][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[2] PIXEL READONLY SIZE 70 ,9
	
	@ nRow*.35,nCol*.02 SAY STR0113 OF oFolderRdp:aDialogs[2] PIXEL //"Saldos Moeda Titulo"
	@ nRow*.35,nCol*.22 MSGET aRdp[8][1] VAR aRdp[8][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[2] PIXEL READONLY SIZE 70 ,9
	
	@ nRow*.60,nCol*.02 SAY STR0114 OF oFolderRdp:aDialogs[2] PIXEL //"Saldos Moeda Corrente"
	@ nRow*.60,nCol*.22 MSGET aRdp[9][1] VAR aRdp[9][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[2] PIXEL READONLY SIZE 70 ,9
	
	@ nRow*.10,nCol*.52  SAY STR0115 OF oFolderRdp:aDialogs[2] PIXEL //"Pagamentos Parciais"
	@ nRow*.10,nCol*.72  MSGET aRdp[10][1] VAR aRdp[10][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[2] PIXEL READONLY SIZE 70 ,9
	
	@ nRow*.35,nCol*.52 SAY STR0116 OF oFolderRdp:aDialogs[2] PIXEL COLOR CLR_RED //"Dívida Moeda Título"
	@ nRow*.35,nCol*.72 MSGET aRdp[11][1] VAR aRdp[11][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[2] PIXEL READONLY SIZE 70 ,9 COLOR CLR_RED
	
	@ nRow*.60,nCol*.52 SAY STR0117 OF oFolderRdp:aDialogs[2] PIXEL COLOR CLR_RED //"Dívida Moeda Corrente"
	@ nRow*.60,nCol*.72 MSGET aRdp[12][1] VAR aRdp[12][2] Picture "@E 999,999,999.99" OF oFolderRdp:aDialogs[2] PIXEL READONLY SIZE 70 ,9 COLOR CLR_RED
	
	//Observacao da ligacao
	@ 227,02 TO 275,122 LABEL STR0118 OF oDlgHist PIXEL //"Observação da ligação"
	@ 235,05 GET oObsMemo VAR cObsMemo OF oDlgHist MEMO SIZE 114,35 PIXEL READONLY
	oObsMemo:oFont := oMonoAs
	oObsMemo:bRClicked := {|| AllwaysTrue() }
	
	//Motivo do Encerramento - Se a liga‡„o for encerrada
	@ 227,125 TO 275,245 LABEL STR0119 OF oDlgHist PIXEL //"Motivo do Encerramento"
	@ 235,128 GET oEnceMemo VAR cEnceMemo OF oDlgHist MEMO SIZE 114,35 PIXEL READONLY
	oEnceMemo:oFont := oMonoAs
	oEnceMemo:bRClicked := {|| AllwaysTrue() }
	
	//Motivo do Cancelamento - Se a liga‡„o for cancelada
	@ 227,249 TO 275,373 LABEL STR0120 OF oDlgHist PIXEL //"Motivo do Cancelamento"
	@ 235,252 GET oCancMemo VAR cCancMemo OF oDlgHist MEMO SIZE 114,35 PIXEL READONLY
	oCancMemo:oFont := oMonoAs
	oCancMemo:bRClicked := {|| AllwaysTrue() }
	
	// Legendas da Tela
	@ 280,05 BITMAP ResName "BR_AZUL" OF oDlgHist Size 10,10 NoBorder Pixel
	@ 280,15 SAY STR0121 OF oDlgHist Color CLR_BLUE,CLR_WHITE PIXEL //"Atendimento"

	@ 280,60 BITMAP ResName "BR_VERDE" OF oDlgHist Size 10,10 NoBorder Pixel 
	@ 280,70 SAY STR0122 OF oDlgHist Color CLR_GREEN,CLR_WHITE PIXEL //"Cobrança"

	@ 280,115 BITMAP ResName "BR_VERMELHO" OF oDlgHist Size 10,10 NoBorder Pixel 
	@ 280,125 SAY STR0123 OF oDlgHist Color CLR_RED,CLR_WHITE PIXEL //"Encerrada"

	@ 280,170 BITMAP ResName "BR_CINZA" OF oDlgHist Size 10,10 NoBorder Pixel
	@ 280,180 SAY STR0124 OF oDlgHist Color CLR_GRAY,CLR_WHITE PIXEL //"Cancelado"

	FATPDLogUser("TK274HTLC")
	
ACTIVATE MSDIALOG oDlgHist CENTER ON INIT (	EnchoiceBar(oDlgHist,{|| (nOpcA := 1,oDlgHist:End())},{|| oDlgHist:End()} )) //  Botao de OK , Botao de CANCELA		


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o aCols e aHeader da tela anterior|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols	:= aAuxACols
aHeader	:= aAuxAHeader

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o Operador confirmou a alteracao do Historico e nao esta na rotina de pre-atendimento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcA == 1 .AND. FUNNAME() <> "TMKA280"
	cNumTlc	:= ACF->ACF_CODIGO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa o ponto de entrada na confirmacao da tela de historico        ³
	//³que recebera um retorno para prosseguir com o preenchimento dos dados.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTMKCHIST
		lRet:= U_TMKCHIST(cNumTlc)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida o retorno do ponto de entrada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ValType(lRet) <> "L")
			lRet := .F.          
		Endif
	Endif

	If lRet
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os valores de totais da tela de historicos para a tela de atendimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aEval( aRdp, { |x,n| aRdpTlc[n][2] := x[2] } )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz um refresh no rodape da tela de atendimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRdpTlc <> NIL
			aEval( aRdpTlc, { |x| x[1]:Refresh() } )	
		Endif
	
		Tk274NumTlc(@nOpc,cNumTlc,@lHabilita,@oFolderTlc,@oEnchTlc)
	
	Endif
					
Else
	M->ACF_DESCOP := Posicione("SU7",1,xFilial("SU7") + M->ACF_OPERAD, "U7_NOME")
	M->ACF_DESCNT := Posicione("SU5",1,xFilial("SU5") + M->ACF_CODCON, "U5_CONTAT")
	M->ACF_DESCMO := Posicione("SU9",2,xFilial("SU9") + M->ACF_MOTIVO, "U9_DESC")
EndIf
	
lRet:= .T.

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274HAcg ºAutor  ³ Vendas Clientes    º Data ³  18/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os itens do ACG de acordo com o ACF selecionado     º±±
±±º          ³na consulta de historico de cobranca                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SOMENTE TELECOBRANCA                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk274HAcg(	aHeadNew,	aColsNew,	cCodigo,	cObsMemo,;
							cEnceMemo,	cCancMemo, aRdp)


Local nUsado	:= 0									// Contador auxiliar de linhas do aheader
Local nI		:= 0									// Contado auxiliar	
Local lAux		:= INCLUI                               // Armazena o conteudo da variavel publica INCLUI                   	
Local aValores	:= {}									// Array auxiliar para alimentar os campos do rodape da tela de telecobranca
Local nPPrefix	:= 0									// Posicao do Prefixo no array aHeader
Local nPTitulo	:= 0									// Posicao do Titulo  no array aHeader
Local nPParcel	:= 0									// Posicao do Parcela no array aHeader
Local nPTipo	:= 0									// Posicao do Tipo    no array aHeader
Local nPFilOrig := 0									// Posicao do Filial de Origem no array aHeader 
Local nPDescFi	:= 0									// Posicao do campo de desconto sobre o titulo
Local nPDescJu	:= 0									// Posicao do campo de desconto sobre os Juros do titulo
Local nPValRef	:= 0									// Valor do titulo utilizado para referencia do desconto
Local cFilOrig	:= ""									// Conteudo da Filial de Origem
Local nPMulta	:= 0									// Posicao do campo ACG_MULTA que armazena o valor de multa nos itens do atendimento de telecobranca  (somente para integracao com sigaloja)
Local cTmkJuros	:= GetNewPar("MV_TMKAJUR","1") 			// Define se o calculo de juros sera baseado nos campos do financeiro ou nos parametros do sigaloja.  1-Financeiro, 2- Sigaloja 
Local nValDesc	:= 0									// Valor do desconto para o titulo
Local nPHist	:= 0									// Histórico do título
Local nPSituac	:= 0									// Situação do título
Local nPDSituac := 0									// Descrição da situação do título
Local nPPortad	:= 0									// Portador

#IFDEF TOP
	Local cQuery	:= ""								// Variavel auxiliar para compor a Query
	Local aStruct	:= ACG->(DbStruct()) 				// Array com a estrutura da tabela ACG
#ENDIF

// Limpa os dados carregados no aCols
aColsNew	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa o rodape de Telecobranca³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aRdp <> NIL
	For nI := 1 To Len(aRdp)
		aRdp[nI][2] := 0 
	Next nI
Endif

If Empty(aHeadNew)
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("ACG")
	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "ACG"

		If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
			Aadd(aHeadNew, {   	AllTrim(X3Titulo())	,;  // 01 - Titulo
								SX3->X3_CAMPO		,;  // 02 - Campo 
								SX3->X3_PICTURE		,;  // 03 - Picture
								SX3->X3_TAMANHO		,;  // 04 - Tamanho
								SX3->X3_DECIMAL		,;  // 05 - Decimal
								SX3->X3_VALID		,;  // 06 - Valid
								SX3->X3_USADO		,;  // 07 - Usado
								SX3->X3_TIPO		,;  // 08 - Tipo
								SX3->X3_F3			,;  // 09 - F3
								SX3->X3_CONTEXT } )     // 10 - Contexto

								nUsado++
		Endif
		SX3->(DbSkip())
	End 
	ADHeadRec("ACG", aHeadNew) 
	nUsado := Len(aHeadNew)   
	
Else
	nUsado := Len(aHeadNew)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega a posicao dos campos no acols do titulo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPPrefix	:= Ascan(aHeadNew, {|x| x[2] == "ACG_PREFIX"} )
nPTitulo	:= Ascan(aHeadNew, {|x| x[2] == "ACG_TITULO"} )
nPParcel	:= Ascan(aHeadNew, {|x| x[2] == "ACG_PARCEL"} )
nPTipo		:= Ascan(aHeadNew, {|x| x[2] == "ACG_TIPO  "} )
nPJuros		:= Ascan(aHeadNew, {|x| x[2] == "ACG_JUROS "} )
nPRecebe	:= Ascan(aHeadNew, {|x| x[2] == "ACG_RECEBE"} )
nPValRef	:= Ascan(aHeadNew, {|x| x[2] == "ACG_VALREF"} )
nPDescFi	:= Ascan(aHeadNew, {|x| x[2] == "ACG_DESCFI"} )
nPFilOrig	:= Ascan(aHeadNew, {|x| x[2] == "ACG_FILORI"} )
nPMulta		:= Ascan(aHeadNew, {|x| x[2] == "ACG_MULTA "} )     
nPDescJ		:= Ascan(aHeadNew, {|x| x[2] == "ACG_DESCJU"} )
nPHist		:= Ascan(aHeadNew, {|x| x[2] == "ACG_HIST  "} )
nPSituac	:= Ascan(aHeadNew, {|x| x[2] == "ACG_SITUAC"} )
nPDSituac	:= Ascan(aHeadNew, {|x| x[2] == "ACG_DSITCB"} )
nPPortad	:= Ascan(aHeadNew, {|x| x[2] == "ACG_PORTAD"} )

If !Empty(cCodigo)
	DbSelectArea("ACG")
	DbSetOrder(1)
	#IFDEF TOP
		cQuery	:=	" SELECT	* " +;
					" FROM " +	RetSqlName("ACG") + " ACG " +;
					" WHERE	ACG.ACG_FILIAL = '" + xFilial("ACG") + "' AND" +;
					"		ACG.ACG_CODIGO = '" + cCodigo + "' AND" +;
					"		ACG.D_E_L_E_T_ = ' '" +;
					" ORDER BY " + SqlOrder(IndexKey())
			
		cQuery	:= ChangeQuery(cQuery)
		// MemoWrite("TK280ACG.SQL", cQuery)
		DbSelectArea("ACG")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACG', .F., .T.)
	
		For nI := 1 To Len(aStruct)
			If aStruct[nI][2] $ "NDL"
				TCSetField("ACG", aStruct[nI][1], aStruct[nI][2], aStruct[nI][3], aStruct[nI][4])
			Endif
		Next nI
	#ELSE
		DbSeek(xFilial("ACG")+cCodigo)
	#ENDIF
	
	INCLUI := .F.
	While	!ACG->(Eof())						.AND.;
			ACG->ACG_FILIAL == xFilial("ACG")	.AND.;
			ACG->ACG_CODIGO == cCodigo
		
		Aadd(aColsNew,Array(nUsado+1))
		For nI := 1 To nUsado
			If IsHeadRec(aHeadNew[nI,2])      
            	#IFDEF TOP
                	aColsNew[Len(aColsNew)][nI] := ACG->R_E_C_N_O_
             	#ELSE
                	aColsNew[Len(aColsNew)][nI] := ACG->(Recno())			                                
              	#ENDIF
              	
			ElseIf IsHeadAlias(aHeadNew[nI,2])
				aColsNew[Len(aColsNew)][nI] := "ACG"						
			ElseIf ( aHeadNew[nI,10] <>  "V" )
				aColsNew[Len(aColsNew)][nI] := FieldGet(FieldPos(aHeadNew[nI,2]))
			Else
				aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.T.)
			Endif								
		Next nI
		aColsNew[Len(aColsNew)][nUsado+1] := .F.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valido a existencia do campo ACG_FILORI criado. Caso nao exista, assumo a filial corrente do SE1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPFilOrig > 0
			cFilOrig	:= aColsNew[Len(aColsNew)][nPFilOrig]
		Else
			cFilOrig	:= xFilial("SE1")
		Endif
		
		If aRdp <> NIL
			DbSelectArea("ACF")
			DbSetOrder(1)
			DbSeek(xFilial("ACF")+cCodigo)
			
			DbSelectArea("SE1")
			DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
			If DbSeek(cFilOrig+	ACF->ACF_CLIENT+;
			                    ACF->ACF_LOJA  +;
								aColsNew[Len(aColsNew)][nPPrefix] + ;
								aColsNew[Len(aColsNew)][nPTitulo] + ;
								aColsNew[Len(aColsNew)][nPParcel] + ;
								aColsNew[Len(aColsNew)][nPTipo];
								)

				/*
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³   Retorno   ³ExpA1: Array com a seguinte estrutura                        ³
				//³             ³       [1] Valor Original do Titulo                          ³
				//³             ³       [2] Abatimentos                                       ³
				//³             ³       [3] Pagto Parcial                                     ³
				//³             ³       [4] Decrescimo                                        ³
				//³             ³       [5] Acrescimo                                         ³
				//³             ³       [6] Saldo do Titulo na Moeda do Titulo                ³
				//³             ³       [7] Saldo do Titulo na Moeda Corrente                 ³
				//³             ³       [8] Juros                                             ³
				//³             ³       [9] Desconto                                          ³
				//³             ³       [10] Correcao Monetaria                               ³
				//³             ³       [11] Valor a ser Recebido na moeda do titulo          ³
				//³             ³       [12] Valor a ser Recebido na moeda corrente           ³
				//³             ³       [13] Multa                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				*/ 
				aValores := FaVlAtuCr(	NIL		, NIL	, NIL	, NIL	,;
										cFilOrig, .T.	)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o calculo dos juros do titulo for baseado nos parametros MV_LJJUROS e MV_LJMULT   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cTmkJuros == "2" 	// SIGALOJA
					Tk274CalcJuros(	@aValores	  	, @aColsNew		, aHeadNew		, NIL,;
									ACF->ACF_CLIENT	,ACF->ACF_LOJA 	, ACF->ACF_DATA)
			    Endif

				nValDesc := (aColsNew[Len(aColsNew)][nPDescFi] * aColsNew[Len(aColsNew)][nPValRef]) / 100
				
				If nPDescJu > 0
					nValDesc += (aColsNew[Len(aColsNew)][nPDescJu] * aColsNew[Len(aColsNew)][nPJuros]) / 100
				EndIf

				If nPHist > 0
					aColsNew[Len(aColsNew)][nPHist]	:= SE1->E1_HIST			//Historico do título
				EndIf

				If nPSituac > 0
					aColsNew[Len(aColsNew)][nPSituac] := SE1->E1_SITUACA	//Situação do título
				EndIf

				If nPDSituac > 0
					aColsNew[Len(aColsNew)][nPDSituac] := Posicione("FRV",1,xFilial("FRV")+SE1->E1_SITUACA,"FRV_DESCRI")	//Descricao da situação do título
				EndIf
							
				If nPPortad > 0
					aColsNew[Len(aColsNew)][nPPortad] := SE1->E1_PORTADO	//Portador
				EndIf
				
				// [1]  Abatimentos
				// [2]  Correcao Monetaria
				// [3]  Juros
				// [4]  Acrescimo    - E1_SDACRES
				// [5]  Decrescimo   - E1_SDDECRE
				// [6]  Desconto
				// [7]  Valor Original do Titulo
				// [8]  Saldo do Titulo na Moeda do Titulo
				// [9]  Saldo do Titulo na Moeda Corrente
				// [10] Pagto Parcial
				// [11] Valor a ser Recebido na moeda do titulo
				// [12] Valor a ser Recebido na moeda corrente
				
				aRdp[1][2]	:= aRdp[1][2] + aValores[2]
				aRdp[2][2]	:= aRdp[2][2] + aValores[10]
				aRdp[3][2]	:= aRdp[3][2] + aValores[8]
				aRdp[4][2]	:= aRdp[4][2] + ACG->ACG_ACRESC
				aRdp[5][2]	:= aRdp[5][2] + ACG->ACG_DECRESC
				aRdp[6][2]	:= aRdp[6][2] + nValDesc
				aRdp[7][2]	:= aRdp[7][2] + aValores[1]
				aRdp[8][2]	:= aRdp[8][2] + aValores[6]
				aRdp[9][2]	:= aRdp[9][2] + aValores[7]
				aRdp[10][2]	:= aRdp[10][2] + aValores[3]
				aRdp[11][2]	:= aRdp[11][2] + aValores[11] + aValores[9] - nValDesc
				aRdp[12][2]	:= aRdp[12][2] + aValores[12] + aValores[9] - nValDesc
			Endif
		Endif
		
		DbSelectArea("ACG")
		ACG->(DbSkip())
	End
	INCLUI := lAux
	
	#IFDEF TOP
		DbSelectArea("ACG")
		DbCloseArea()
		ChkFile("ACG")
	#ENDIF
Endif

If Empty(aColsNew)
	Aadd(aColsNew,Array(nUsado+1))
	For nI := 1 To nUsado
		If IsHeadAlias(aHeadNew[nI,2]) 
			aColsNew[Len(aColsNew)][nI] := "ACG"						
		ElseIf IsHeadRec(aHeadNew[nI,2])
			aColsNew[Len(aColsNew)][nI] := 0		                                            
		Else
			aColsNew[Len(aColsNew)][nI] := CriaVar(aHeadNew[nI,2],.F.)
		EndIf
	Next nI
	aColsNew[Len(aColsNew)][nUsado+1] := .F.
Endif
		
// Faz um refresh no rodape
If aRdp <> NIL
	For nI := 1 To Len(aRdp)
		aRdp[nI][1]:Refresh()
	Next nI
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrego a observa‡„o da cobranca.						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cObsMemo	:= ""
cEnceMemo	:= ""
cCancMemo	:= ""
DbSelectArea("ACF")
DbSetOrder(1)
If DbSeek(xFilial("ACF") + cCodigo)
	cObsMemo	:= MSMM(ACF->ACF_CODOBS,TamSx3("ACF_OBS")[1])
	cEnceMemo	:= MSMM(ACF->ACF_CODMOT,TamSx3("ACF_OBSMOT")[1])
	cCancMemo	:= MSMM(ACF->ACF_CCANC,TamSx3("ACF_OBSCAN")[1])
Endif
			
Return(.T.)

		
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271NumTc  ³ Autor ³ Vendas Clientes     ³ Data ³ 19/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega os dados do atendimento de acordo com o codigo      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Tmka274													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk274NumTlc(nOpc,cNumTlc,lHabilita,oFolderTlc,oEnchTlc)

Local cNumAux 	:= ""					// Proximo codigo de atendimento
Local cCampo    := ""					// Nome do campo do SX3 para utilizacao na marco substituicao

CursorWait()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Existe a liga‡„o preencho a tela com os dados da liga‡„o ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "ACF" )
DbSetOrder(1)
If DbSeek(xFilial("ACF") + cNumTlc)
	
	nOpc     := 4   // Alteracao
	Inclui   := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a enchoice de Telemarketing.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("ACF")
	While ( !SX3->( Eof() ) .AND. SX3->X3_ARQUIVO == "ACF")
		If X3USO(SX3->X3_USADO)
			cCampo := AllTrim(SX3->X3_CAMPO)
			If (X3_CONTEXT # "V")
				M->&(cCampo) := ACF->&(cCampo)
			ElseIf (X3_CONTEXT == "V")
				M->&(cCampo) :=  CriaVar(cCampo)
			Endif
		Endif
		
		SX3->(DbSkip())
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura‡ao da GetDados - Folder 01			     ³
	//³ *** Telemarketing                       			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TK271Config("ACG","ACG_CODIGO",nOpc,,,cNumTlc)
	
	aHeader  := {}
	aCols    := {}
	aHeader  := aClone(aSvFolder[3][1])
	aCols    := aClone(aSvFolder[3][2])
	n		 := aSvFolder[3][3]
	
	oGetTlc:oBrowse:Refresh()
	
Else             
	TK271Config("ACG","ACG_CODIGO",nOpc,,,cNumTlc)
	cNumAux      := GetSxeNum("ACF","ACF_CODIGO")
	M->ACF_CODIGO := cNumAux
	RollBackSxe()
	
	If cNumTlc > cNumAux
		Help( " ",1,"FORA_SEQ")
	Endif
Endif

CursorArrow()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274GrvTlcºAutor  ³ Vendas Clientes    º Data ³  12/09/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a gravacao do atendimento de Telecobranca.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274GrvTlc(nOpc		,oFolderTlc	,lHabilita	,l380,;
					 cAgenda	,aSX3ACF	,cEncerra	,cMotivo)

Local nPTitulo		:= aPosicoes[1][2]						// Titulo
Local nPPrefix		:= aPosicoes[2][2]						// Prefixo
Local nPParcel		:= aPosicoes[3][2]						// Parcela
Local nPTipo		:= aPosicoes[4][2]						// Tipo
Local nPStatus		:= aPosicoes[30][2]						// Status do Titulo
Local nI        	:= 0									// Contador	de linhas
Local nJ        	:= 0                                    // Contador de colunas
Local cNumAux		:= M->ACF_CODIGO						// Variavel para gravar o codigo do atendimento 
Local cMay			:= ""                                   // Variavel para uso do mayiusecode	
Local cHisTlc   	:= ""									// Variavel para gravacao dos dados no cadastro de cliente - MEMO
Local cCampo    	:= ""									// Variavel para gravacao dos campos
Local lRet 			:= .F.                                  // Retorno da funcao     	
Local lNovo 		:= .F.									// Flag para gravacao - .T. inclui, .F. altera
Local lTMKCFIM 		:= ExistBlock("TMKCFIM") 				// P.E. no fim da grava‡ao do sistema do ACF/ACG
Local aACFCampos	:= {}									// Carregas os campos do SX3 - alias ACF em memoria	
Local cOperAtend	:= ""									// Codigo do Operador
Local cCidade		:= ""									// Cidade do contato	
Local cEst			:= ""									// Estado do contato
Local cTelRes		:= ""									// Telefone residencial do contato
Local cTelCom1		:= ""									// Telefone Comercial do contato 
Local cEnd			:= ""									// Endereco do contato
Local aRegras		:= {}									// Regras para cobranca
Local nIni          := 0									// Controle de selecao de regras de cobranca
Local nFim	        := 0									// Controle de selecao de regras de cobranca
Local nPFilOrig     := 0									// Posicao da Filial de Origem do Titulo
Local cFilOrig		:= ""                                  	// Filial de origem do titulo
Local lEncerra		:= .T.									// Indica se o atendimento podera ser encerrado quando o status for igual a 3
Local lTKSEQACF		:= ExistBlock("TKSEQACF") 				// P.E. para pegar o prox. codigo do arquivo ACF


//Variaveis para Liquidacao de titulos
Local aCab			:= {}	//Cabecalho para a liquidacao
Local aItens		:= {}	//Itens para a liquidacao
Local aParcelas		:= {}	//Parcelas para o novo titulo gerado na liquidacao
Local cFiltro		:= ""	//Filtro de usuario para a liquidacao
Local cPrefixo 		:= ""	//Prefixo do titulo negociado
Local cTitulo 		:= ""	//Numero do titulo negociado
Local cParcela		:= ""	//Parcela do titulo negociado
Local cTipo 		:= ""	//Tipo do titulo negociado
Local cNatLiq		:= SuperGetMV("MV_TMKNTCB",.F.,"")	//Natureza utilizada na liquidacao dos titulos
Local cTipoTit		:= SuperGetMV("MV_TMKTPTR",.F.,cTipo)	//Tipo do titulo gerado pela liquidacao
Local cPrefTit		:= SuperGetMV("MV_TMKPRTR",.F.,"REN")	//Prefixo do título gerado pela liquidação
Local cSeqIni		:= SuperGetMv("MV_1DUP"   ,.F.,"1")		//Sequência inicial das parcelas geradas pela liquidação.
Local cSequencia	:= cSeqIni	//Sequência das parcelas geradas pela liquidação
Local cTitLiq		:= ""	//Numero do titulo gerado pela liquidacao
Local nValRec		:= 0	//Valor a receber do titulo negociado
Local nJuros		:= 0	//Valor de Juros do titulo negociado
Local nDecres		:= 0	//Valor do decrscimo dado na negociacao
Local nDescJuros	:= 0 	//Valor do desconto sobre o Juros dado na negociacao
Local nPorJur		:= 0	//Percentual Juros
Local dEmissao		:= ""	//Data de emissao dos titulos gerados na liquidacao
Local cFilOrigem	:= ""	//Filial de origem do titulo selecionado para encontrar o SE1
Local lLiquida      := .F.  //Regra de Negociacao tem liquidacao habilitada
Local cSitNewTC		:= GetNewPar( 'MV_TSITCOB', '0|F|G' )	//Situacao dos Titulos Para Serem Considerados pelo Novo Modelo de TeleCobranca

Private lMsErroAuto	:= .F.				// Indica a presenca de erro na execucao da msexecauto

DEFAULT cEncerra	:= ""									// Codigo do Encerramento	
DEFAULT cMotivo		:= ""    								// Descricao do motivo de encerramento

If M->ACF_OPERA == "1"		// Receptivo	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pesquisa o usuario no cadastro de operadores					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SU7")
	DbSetOrder(4)
	//Posiciona no operador
	If !DbSeek(xFilial("SU7") + __cUserId) // Nome completo
		cOperAtend := SU7->U7_COD
	Else
		cOperAtend := SU7->U7_COD
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o Status nao for somente de Atendimento e o usuario nao informou o Titulo nao faz a gravacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->ACF_STATUS <> "1" .AND. Empty( aCols[1][nPTitulo] )
	If !lTk271Auto
		Help("",1,"FALTA_TIT")
	Endif	
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se o atendimento pode ser encerrado.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->ACF_STATUS == "3"    //Encerrado
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao for entrada automatica exibe mensagem de encerramento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !lTk271Auto
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe algum código de encerramento cadastrado. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Tk272VerSUN("3")
			If !TmkOk(STR0130)//"Confirma Encerramento ?"
				lEncerra:= .F.
			Endif
		Else
			Help(" ",1,"TK272SUN")
			lEncerra:= .F.
		EndIf
	Endif

	If lEncerra				
		For nI := 1 To Len(aCols)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o status estiver em branco ou 2-Negociado ou 4-Baixa, e a linha nao estiver deletada³
			//³o operador nao podera encerrar o atendimento. O atendimento de Telecobranca somente    ³
			//³podera ser encerrado quando os titulos ja estiverem pagos ou enviados a cartorio.      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (aCols[nI][nPStatus]) $ " 24" .AND. !(aCols[nI][Len(aHeader)+1])
				If !lTk271Auto
					Help(" ",1,"TK274NOENC") //Este título não poderá ser encerrado"
				Endif
				Return(lRet)
			Endif
		Next nI   
	Else
		Return(lRet)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for uma alteracao, posiciona no respectivo atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	nOpc == 4
	DbSelectArea("ACF")
	DbSetOrder(1)
	If !DbSeek(xFilial("ACF") + M->ACF_CODIGO)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se por alguma falha no BD nao encontrar o registro ³
		//³ Posiciona no primeiro e pesquisa novamente.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    ACF->( DbGoTop() )
		ACF->( DbSetOrder(1) )
		ACF->( DbSeek(xFilial("ACF")) )
		If !DbSeek(xFilial("ACF") + M->ACF_CODIGO)
			If !lTk271Auto
				Help(" ",1,"TK270NSEEK")
				Alert(STR0155 + M->ACF_CODIGO + STR0156)		//"O atendimento: " / " nao foi encontrado. Verifique se e o mesmo numero do atendimento atual"
			Endif	
			Return(lRet)
		EndIf
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a ligacao estava encerrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ACF->ACF_STATUS == "3"
		If !lTk271Auto
			Help(" ",1,"ENCERRADA")
		Endif	
		Return(lRet)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a ligacao estava cancelada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(ACF->ACF_CCANC)
		If !lTk271Auto
			Help(" ",1,"CANCELADA")
		Endif	
		Return(lRet)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se existe um telefone valido para o contato para a geracao de ligacao pendente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->ACF_PENDEN) .And. M->ACF_STATUS <> "3"

	If !TK274HACF(M->ACF_HRPEND,M->ACF_PENDEN)
		Aviso(STR0128,STR0160,{"OK"})//"Atencao"###"Informe a hora de retorno da ligação corretamente"
		Return(lRet)
	EndIf
	
	If !Empty(M->ACF_CODCON)
		DbSelectArea("SU5")
		DbSetOrder(1)
		If DbSeek( xFilial("SU5") + M->ACF_CODCON)
			
			If 	Empty(SU5->U5_FONE) 	.AND.;
				Empty(SU5->U5_CELULAR) 	.AND.;
				Empty(SU5->U5_FAX) 		.AND.;
				Empty(SU5->U5_FCOM1) 	.AND.;
				Empty(SU5->U5_FCOM2)

				If !lTk271Auto
					Help(" ",1,"TMKSEMTEL")
				Endif	
				Return(lRet)
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega dados do cadastro do contato para colocar no e-mail - quando existe envio de e-mail³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCidade	:= SU5->U5_MUN
			cEst	:= SU5->U5_EST
			cTelRes := SU5->U5_FCOM1
			cTelCom1:= SU5->U5_FONE
			cEnd	:= SU5->U5_END
		Endif		 

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obriga o operador a indicar um contato para poder gerar a Lista de Contato Pendente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			Aviso(STR0128,STR0080,{"OK"})//"Atencao,Por favor informe o contato para a geracao da pendencia"
		Endif	
		Return(lRet)                     
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os campos do cabecalho que deverao ser gravados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("ACF")
While !SX3->(EOF()) .AND. (X3_ARQUIVO == "ACF")
	If X3USO(X3_USADO) 
		Aadd(aACFCampos,{ SX3->X3_CAMPO, SX3->X3_CONTEXT, .T. })
	Else
		Aadd(aACFCampos,{ SX3->X3_CAMPO, SX3->X3_CONTEXT, .F. })
	Endif
	SX3->(DbSkip())
End

BEGIN TRANSACTION

	For nI := 1 To Len(aCols)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava o cabecalho do atendimento e as tabelas de relacionamento 1 p/ 1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nI == 1
			
			DbSelectArea("ACF")
			Do Case
				Case nOpc == 3  // INCLUSAO
					DbSelectArea("ACF")
					DbSetOrder(1)
					
					cMay := "ACF" + AllTrim(xFilial("ACF")) + cNumAux
					While ( DbSeek(xFilial("ACF") + cNumAux) .OR.;
							(!lTKSEQACF .AND. !MayIUseCode(cMay)) )
						cNumAux := Soma1(cNumAux,Len(cNumAux))
						cMay 	:= "ACF" + AllTrim(xFilial("ACF")) + cNumAux
					End
					
					If (cNumAux <> M->ACF_CODIGO)
						If !lTk271Auto
							Help(" ",1,"NUMSEQ",,cNumAux,4,15)
						Endif	
						M->ACF_CODIGO := cNumAux
					Endif
					
					If __lSX8
						ConfirmSX8()
					Endif     
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Libera numeros reservados                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lTKSEQACF
						FreeUsedCode(.T.)
					EndIf
					
					lNovo := .T.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o status dos semaforos para evitar o empilhamento do ultimo folder ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If TkGetTipoAte() == "4"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³O usuario esta no terceiro folder     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nFolder == 3  //TLC
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Volta a sequencia do ultimo folder    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							DbSelectArea("SUC")
							RollBackSX8()
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Volta a sequencia do penultimo folder ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							DbSelectArea("SUA")
							RollBackSX8()
							
							DbSelectArea("ACF")
						Endif
					Endif
			Endcase
			
			RecLock("ACF",lNovo)
			For nJ := 1 To Len(aACFCampos)
				cCampo := AllTrim(aACFCampos[nJ][1])
				
				Do Case
					Case cCampo == "ACF_FILIAL"
						ACF->&(cCampo) := xFilial("ACF")
						
					Case cCampo == "ACF_INICIO"
						ACF->&(cCampo) := cTimeIni
						
					Case cCampo == "ACF_FIM"
						ACF->&(cCampo) := Time()
						
					Case cCampo == "ACF_DIASDA"
						ACF->&(cCampo) :=  CtoD("01/01/2045") - M->ACF_DATA
						
					Case cCampo == "ACF_HORADA"
						ACF->&(cCampo) :=  86400 - ( (Val(Substr(cTimeIni,1,2))*3600) + ( Val(Substr(cTimeIni,4,2))*60) + Val(Substr(cTimeIni,7,2))  )
						
					Case cCampo == "ACF_OPERAT"
						ACF->&(cCampo) :=  cOperAtend
						
					Case cCampo == "ACF_CODENC"
						ACF->&(cCampo) := cEncerra

					Case cCampo == "ACF_ULTATE"
						ACF->&(cCampo) := dDataBase

					OtherWise
						If (aACFCampos[nJ][2] <> "V") .AND. (aACFCampos[nJ][3])		// X3_CONTEXT e .T.
							If ACF->(FieldPos(cCampo))  > 0														
								ACF->&(cCampo) := M->&(cCampo)
							EndIf
						Endif
				Endcase
				
			Next nJ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava uma NOVA ligacao na lista de contatos pendentes - SU4/SU6                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M->ACF_STATUS <> "3"		// Encerrada
				If !(M->ACF_STATUS == "1" .AND. Empty(aCols[1,GdFieldPos("ACG_TITULO")]))
					If !Empty(M->ACF_PENDEN)
						If !Empty(cAgenda)
							TKGrvSU4(M->ACF_CODCON	,"SA1"			,M->ACF_CLIENT + M->ACF_LOJA	,M->ACF_OPERAD,;
									"3"				,M->ACF_CODIGO	,M->ACF_PENDEN					,M->ACF_HRPEND,;
									l380			,cAgenda)
						Else
							TKGrvSU4(M->ACF_CODCON	,"SA1"			,M->ACF_CLIENT + M->ACF_LOJA	,M->ACF_OPERAD,;
									"3"				,M->ACF_CODIGO	,M->ACF_PENDEN					,M->ACF_HRPEND,;
									l380)
						Endif
					Endif
				EndIf
		
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Encerra o atendimento com o status de encerrado                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Tk274Encerra(.F.,M->ACF_CODIGO,@cEncerra,@cMotivo)
				
				If !Empty(cEncerra)
					ACF->ACF_CODENC := cEncerra
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Encerra as listas de pendencias se existir alguma - SOMENTE PARA ESSE ATENDIMENTO ENCERRADO ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				TK274DelSU4(M->ACF_CODIGO)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³MEMO DO MOTIVO DE ENCERRAMENTO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cMotivo)  // Sempre e inclusao porque so pode encerrar 1 vez
				MSMM(,TamSx3("ACF_OBSMOT")[1],,cMotivo,1,,,"ACF","ACF_CODMOT")
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³MEMO DA OBSERVACAO ATENDIMENTO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(M->ACF_OBS)
				If nOpc == 3 //Inclusao
					MSMM(,TamSx3("ACF_OBS")[1],,M->ACF_OBS,1,,,"ACF","ACF_CODOBS")
			    Else         //Alteracao
				    MSMM(ACF->ACF_CODOBS,TamSx3("ACF_OBS")[1],,M->ACF_OBS,1,,,"ACF","ACF_CODOBS")
			    Endif
			Endif
			MsUnlock()
			ACF->(FkCommit())
			
			//Gravo no hist¢rio do cliente o contato, a data, a observa‡„o e a origem(TMK)
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(xFilial("SA1") + M->ACF_CLIENT + M->ACF_LOJA)
				If Empty(SA1->A1_CODHIST)
		        	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		            //³Se ainda n„o existe historico gravado para esse cliente fa‡o uma inclus„o ³
		   	        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   		//Visualizacao
	    	    	//cHisTlc	+= MSMM(SA1->A1_CODHIST,35)//Carrego o historico acumulado da entidade antes de inserir o novo
			       	cHisTlc += DTOC(DDATABASE)+STR0011+CRLF //"-Telecobranca-" 
			        cHisTlc += IIF(Empty(M->ACF_OBS),"",M->ACF_OBS + CRLF)
			        MSMM(SA1->A1_CODHIST,TamSx3("A1_HISTMK")[1],,cHisTlc,1,,,"SA1","A1_CODHIST",,.T.)
				Else
			        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			       	//³Se ja existe historico atualizo com o SA1+ACF atual  ³
			        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   		//Visualizacao
	    	    	//cHisTlc += MSMM(SA1->A1_CODHIST,35)//Carrego o historico acumulado da entidade antes de inserir o novo
	   		       	cHisTlc += DTOC(DDATABASE)+STR0011+CRLF //"-Telecobranca-" 
			        cHisTlc += IIF(Empty(M->ACF_OBS),"",M->ACF_OBS + CRLF)
			        MSMM(SA1->A1_CODHIST,TamSx3("A1_HISTMK")[1],,cHisTlc,1,,,"SA1","A1_CODHIST",,.T.)
				EndIf
			Endif
			MsUnlock()
		    ACF->(FkCommit())
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravacao dos itens do atendimento de Telecobranca³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
		If nPFilOrig > 0
			cFilOrig := aCols[nI][nPFilOrig]
		Else
			cFilOrig := xFilial("SE1")	
		Endif 	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os Titulos do atendimento e as tabelas de relacionamento 1 p/ 1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("ACG")
		DbSetOrder(1)
		If DbSeek(xFilial("ACG") + M->ACF_CODIGO + aCols[nI][nPPrefix] + aCols[nI][nPTitulo] + aCols[nI][nPParcel] + aCols[nI][nPTipo]+ cFilOrig)
			lNovo := .F.
		Else
			lNovo := .T.
		Endif
		
		If !lNovo .AND. aCols[nI][Len(aCols[nI])]	// Se a linha foi deletada
			RecLock("ACG",lNovo,.T.)
			DbDelete()
		Else
			RecLock("ACG",lNovo)
			ACG->ACG_FILIAL := xFilial("ACG")
			ACG->ACG_CODIGO := M->ACF_CODIGO
			For nJ := 1 To Len(aHeader)
				cCampo := AllTrim(aHeader[nJ][2])				
				If (aHeader[nJ][10] <> "V")	// X3_CONTEXT
					If ACG->(FieldPos(cCampo)) > 0
						ACG->&(cCampo) := aCols[nI][Ascan(aHeader, {|x| x[2] == aHeader[nJ][2]} )]
					EndIf											
				Endif
			Next nJ
		Endif            
		MsUnlock()
		ACG->(FkCommit())
		
		//Busca regra de negociacao do operador
		dbSelectArea("SK2")		//Regras de Negociacao
		SK2->( dbSetOrder(1) )	//Filial + Regra
		SK2->( dbSeek( Tk190Cons( __cUserId ) ) )	//Funcao Tk190Cons, retorna a chave de busca para encontrar a regra do operador.
					
		//Verifica se a Regra de Negociacao esta com a liquidacao habilitada			
		If SK2->K2_LIQUIDA == "1" //1-Sim e 2-Nao
			lLiquida := .T.
		EndIf
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os dados dos titulos cobrados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SE1")
		DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
		If DbSeek(cFilOrig + M->ACF_CLIENT + M->ACF_LOJA + aCols[nI][nPPrefix] + aCols[nI][nPTitulo] + aCols[nI][nPParcel] + aCols[nI][nPTipo])
			SE1->(RecLock("SE1", .F.))
			SE1->E1_VENCTO			:= ACG->ACG_DTVENC
			SE1->E1_VENCREA			:= ACG->ACG_DTREAL
			SE1->E1_HIST			:= ACG->ACG_HIST

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
			//³Se ainda nao houve baixa para o titulo, significa que os dados de   ³
			//³Desconto Financeiro, Descrescimo e Acrescimo poderao ser alterados. ³
			//³No Financeiro os Acrescimos, Decrescimos e Descontos, sao concedidos³
			//³somente na primeira baixa do titulo. Se existirem novos valores     ³
			//³o usuario  devera informar manualmente na baixa de titulo.		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  Empty(SE1->E1_BAIXA)
				SE1->E1_DESCFIN		:= ACG->ACG_DESCFI		// Percentual de Desconto Financeiro
				SE1->E1_LIDESCF		:= ACG->ACG_LIDESC		// Data Limite para Desconto Financeiro
				SE1->E1_ACRESC		:= ACG->ACG_ACRESC		// Valor de Acrescimo
				SE1->E1_DECRESC		:= ACG->ACG_DECRES		// Valor de Descrescimo
				SE1->E1_DESCJUR		:= ACG->ACG_DESCJU		// Percentual de Desconto sobre Juros

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Os Saldos de Acrescimo e Decrescimo devem ser atualizados       ³
				//³para serem avaliados no momento da baixa do titulo. 			   ³
				//³Os Saldos sao atualizados ate que o titulo seja baixado, 	   ³
				//³apos a baixa (parcial), o mesmo nao podera ser alterado.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SE1->E1_SDACRES		:= ACG->ACG_ACRESC		// Saldo de Acrescimo
				SE1->E1_SDDECRE		:= ACG->ACG_DECRESC		// Saldo de Descrescimo
			Endif
			SE1->(MsUnlock())
		EndIf
		
		lRet := .T.
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Efetua a liquidacao do titulo negociado quando a regra de negociacao ³
		³ estiver configurada com o campo K2_LIQUIDA igual a Sim.              ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
				
		//Protege caso o repositorio esteja desatualizado
		If 	lRet 	
		
			If lLiquida	//Regra de Negociacao está com a liquidacao habilitada	
			
				//Efetua a liquidacao apenas dos titulos com status 2-Negociado
				If ( ACG->ACG_STATUS == '2' )
				
					//Valida os dados necessarios para a liquidacao antes de continuar
					lRet := Tk274VldCpo()
					
					If lRet
								
						//Pega dados do titulo original
						For nJ := 1 To Len(aHeader)
							If AllTrim( aHeader[nJ, 2] ) == "ACG_PREFIX"
								cPrefixo := aCols[nI, nJ]
							ElseIf AllTrim( aHeader[nJ, 2] ) == "ACG_TITULO"
								cTitulo := aCols[nI, nJ]
							ElseIf AllTrim( aHeader[nJ, 2] ) == "ACG_PARCEL"
								cParcela := aCols[nI, nJ]
							ElseIf AllTrim( aHeader[nJ, 2] ) == "ACG_TIPO"
								cTipo := aCols[nI, nJ]
							ElseIf AllTrim( aHeader[nJ, 2] ) == "ACG_RECEBE"
								nValRec := aCols[nI, nJ]
							ElseIf AllTrim( aHeader[nJ, 2] ) == "ACG_JUROS"
								nJuros := aCols[nI, nJ]
							ElseIf AllTrim( aHeader[nJ, 2] ) == "ACG_DECRES"
								nDecres := aCols[nI, nJ]
							ElseIf AllTrim( aHeader[nJ, 2] ) == "ACG_DESCJU"
								nDescJuros := aCols[nI, nJ]
							ElseIf Alltrim( aHeader[nJ, 2] ) == "ACG_FILORI"
								cFilOrigem := aCols[nI, nJ]
							ElseIf Alltrim( aHeader[nJ, 2] ) == "ACG_PORJUR"
								nPorJur    := aCols[nI, nJ]	
							End If
						Next nJ
										
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Trata se os parametros estiverem em branco.                        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ( AllTrim( cTipoTit ) == "" )
							cTipoTit := cTipo
						EndIf 
						
						If ( AllTrim( cPrefTit ) == "" )
							cPrefTit := "REN"
						EndIf
						
						//Calcula valor do desconto sobre juros dado na negociacao
						If ( nDescJuros > 0 )
							nDescJuros := nJuros * ( nDescJuros / 100 )
						End If
						
						//Busca titulo a receber negociado na tabela SE1
						dbSelectArea("SE1")
						SE1->(dbSetOrder(2))	//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo						
						If SE1->( dbSeek ( cFilOrigem + M->ACF_CLIENTE + M->ACF_LOJA + cPrefixo + cTitulo + cParcela + cTipo ) )
							cFiltro := "E1_FILIAL == '" + cFilOrigem + "' .And. "
							cFiltro += "E1_CLIENTE == '" + M->ACF_CLIENTE + "' .And. E1_LOJA == '" + M->ACF_LOJA + "' .And. "
							cFiltro += "E1_PREFIXO == '" + cPrefixo + "' .And. "
							cFiltro += "E1_NUM == '" + cTitulo + "' .And. "
							cFiltro += "E1_PARCELA == '" + cParcela + "' .And. "
							cFiltro += "E1_TIPO == '" + cTipo + "' .And. "

							If (lNewRolTLC .And. !Empty(cSitNewTC))
								cFiltro += "E1_SITUACA $ '"+ AllTrim(cSitNewTC) +"' .And. E1_SALDO > 0 .And. "
							Else
								cFiltro += "E1_SITUACA $ '0FG' .And. E1_SALDO > 0 .And. "
							EndIf
							cFiltro += "DTOS(E1_EMISSAO) == '" + DTOS(SE1->E1_EMISSAO) + "'"
							If Empty( SE1->E1_NUMLIQ )
								cFiltro += " .And. E1_NUMLIQ == '" + Space(TamSx3("E1_NUMLIQ")[1]) + "'"
								nOpc := 3	//3 = Opção de Liquidação
							Else
								nOpc := 4	//4 = Opção de Reliquidação
							EndIf
	
							//Array do processo automatico (aAutoCab)
							//Cabecalho da liquidacao
							aCab	:= {{"cCondicao", M->ACF_CONDPG},;
							    	    {"cNatureza", cNatLiq},;
							    	    {"E1_TIPO",   cTipoTit},;
							    	    {"cCliente",  M->ACF_CLIENTE},;
							    	    {"nMoeda",    SE1->E1_MOEDA},;		
							    	    {"cLoja",     M->ACF_LOJA},;
							    	    {"FO0_TXJUR", nPorJur}}
							
							//Array com as parcelas a gerar de acordo com a condicao de pagamento
							dEmissao 	:= dDataBase
							aParcelas	:= Condicao( nValRec, M->ACF_CONDPG, , dEmissao )
							
							//Divide o desconto total pela quantidade de parcelas
							If Len(aParcelas) > 0
								nDescJuros := nDescJuros / Len(aParcelas)
								nDecres := nDecres / Len(aParcelas)
							End If
							
							//Gera numeracao do titulo criado na liquidacao
							cTitLiq := M->ACF_CODIGO + PadL( nI, 2, "0" )
							
							aItens := {}
							
							For nJ := 1 to Len(aParcelas)
								If nJ == 1
									cSequencia := cSeqIni
								Else
									cSequencia := MaParcela(cSequencia)
								EndIf
								//Dados das parcelas a serem geradas			                      
								aAdd(aItens, {{"E1_PREFIXO", cPrefTit},;				//Prefixo
								              {"E1_BCOCHQ",  "001"},;					//Banco
								              {"E1_AGECHQ",  "001"},;					//Agencia
								              {"E1_CTACHQ",  "001"},;					//Conta
											  {"E1_PARCELA", cSequencia},;				//Parcela
								              {"E1_NUM",     cTitLiq},;					//Nro. do titulo
								              {"E1_EMITCHQ", M->ACF_DESC},;				//Emitente do cheque
								              {"E1_VENCTO",  aParcelas[nJ,1]},;			//Data boa	
								              {"E1_VLCRUZ",  aParcelas[nJ,2]},;			//Valor do titulo
								              {"E1_ACRESC",  0},;						//Acrescimo
								              {"E1_DECRESC", nDescJuros + nDecres}})	//Decrescimo
							Next nJ

							//Aciona rotina de liquidacao do titulo
							If ( Len( aParcelas ) > 0 ) 
								MSExecAuto({|a,b,c,d,e|FINA460(a,b,c,d,e)},,aCab,aItens,nOpc,cFiltro)
								If lMsErroAuto
									MostraErro()
									lRet := .F.
								Else
									//Altera status do titulo para pago
									Reclock( "ACG", .F. )
										ACG->ACG_STATUS = "1"
									MsUnlock()
								EndIf
							EndIf
						Else
							lRet := .F.
							Help( " ", 1, "Tk274GrvTlc", , STR0161, 1)	//"Titulo nao encontrado na tabela SE1."
						End If	//dbSeek SE1						
					End If	//Validacao de dados				
				End If	//Status da cobranca
			End If	//dbSeek SK2
		End If	//FindFunction
		
		//Se houve erro na liquidacao encerra e desfaz as alteracoes nos dados
		If !lRet
			DisarmTransaction()
			Exit
		End If
			
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a data do ultimo contato.  SU5.                       ³
	//³Para que possam ser geradas listas por ultimo contato todas as ³
	//³interacoes devem atualizar a data do ultimo contato no cadastro³
	//³de Contatos.                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If ( lRet ) .And. ( !Empty(M->ACF_CODCON ) )
    	DbSelectArea("SU5")
		DbSetOrder(1)
		If DbSeek(xFilial("SU5") + M->ACF_CODCON)
			Reclock("SU5",.F.)
			Replace SU5->U5_ULTCONT With M->ACF_DATA
			MsUnlock()			
		Endif
	Endif    

END TRANSACTION
		
If lRet		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega um array com as regras de cobranca para atualizar o SK1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SK0")
	DbSetOrder(2)
	DbSeek(xFilial("SK0"))
	While !SK0->(Eof())
	    nIni := nFim + 1
	    If SK0->K0_PRAZO == "999999"		// Trabalha com lista de contato
	    	nFim := nFim + 100000
	    Else
	    	nFim := nFim + Val(SK0->K0_PRAZO)
		Endif
	    Aadd(aRegras, {SK0->K0_REGSEL, nIni, nFim})
		SK0->(DbSkip())
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao para atualizar no SK1 os titulos para o operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk280AtuSK1(M->ACF_CLIENT,M->ACF_LOJA,M->ACF_OPERAD,aRegras)		            	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia e-mail para o responsavel pela cobranca.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk274EnvTlc(cCidade,cEst,cTelRes,cTelCom1,cEnd,aSX3ACF)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa o ponto de Entrada TMKCFIM apos a gravacao do ACF/ACG ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTMKCFIM
		U_TMKCFIM(M->ACF_CODIGO)
	Endif
End If

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ Tk274CanLiq º Autor ³ Vendas Clientes    º Data ³ 04/01/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Cancela a liquidacao de um titulo negociado, permitindo uma   º±±
±±º          ³ nova negociacao. O status da cobranca sera apagado.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Telecobrança                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274CanLiq()

Local aArea 		:= GetArea()
Local aAreaACG	:= ACG->(GetArea())
Local aAreaSE1		:= {}
Local nOldIdxSE1	:= 0
Local lRet 		:= .F.	//Retorno da Funcao
Local cLiqCan		:= ""	//Numero da liquidacao a cancelar
Local cPrefixo 	:= ""	//Prefixo do titulo negociado
Local cTitulo 	:= ""	//Numero do titulo negociado
Local cParcela	:= ""	//Parcela do titulo negociado
Local cTipo 		:= ""	//Tipo do titulo negociado
Local cFilOri		:= ""	//Filial de origem do titulo
Local nPosStatus	:= 0	//Posicao da coluna Status
Local nI			:= 0	//Variavel numerica de uso geral
Local cQuery 		:= ""	//Query para montar area temporaria

//Pega dados do titulo a cancelar
For nI := 1 To Len(aHeader)
	If AllTrim( aHeader[nI, 2] ) == "ACG_PREFIX"
		cPrefixo := aCols[n, nI]
	ElseIf AllTrim( aHeader[nI, 2] ) == "ACG_TITULO"
		cTitulo := aCols[n, nI]
	ElseIf AllTrim( aHeader[nI, 2] ) == "ACG_PARCEL"
		cParcela := aCols[n, nI]
	ElseIf AllTrim( aHeader[nI, 2] ) == "ACG_TIPO"
		cTipo := aCols[n, nI]
	ElseIf AllTrim( aHeader[nI, 2] ) == "ACG_FILORI"
		cFilOri := aCols[n, nI]
	ElseIf AllTrim( aHeader[nI, 2] ) == "ACG_STATUS"
		nPosStatus := nI
	End If
Next nJ

#IFDEF TOP
	aArea 		:= GetArea()
	aAreaACG	:= ACG->(GetArea())
	aAreaSE1	:= SE1->(GetArea())
	nOldIdxSE1	:= SE1->(IndexOrd())
	
	cquery := "SELECT E5_DOCUMEN" 
	cQuery += " FROM " + RetSqlName("SE5")
	cQuery += " WHERE E5_FILIAL = '" + xFilial("SE5") + "'"
	cQuery += " AND E5_PREFIXO = '" + cPrefixo + "'"	
	cQuery += " AND E5_NUMERO = '" + cTitulo + "'"
	cQuery += " AND E5_PARCELA = '" + cParcela + "'"
	cQuery += " AND E5_TIPO = '" + cTipo + "'"
	cQuery += " AND E5_CLIFOR = '" + M->ACF_CLIENT + "'"
	cQuery += " AND E5_LOJA = '" + M->ACF_LOJA + "'"
	cquery += " AND E5_SITUACA <> 'C'"
	cQuery += " AND E5_MOTBX = 'LIQ'"
	cQuery += " AND E5_TIPODOC = 'BA'"
	cQuery += " AND D_E_L_E_T_ = ' '"	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry( , , cQuery ), 'SE5TMP', .F., .T.)
	DbSelectArea("SE5TMP")
#ELSE
	Help( " ", 1, "Tk274CanLiq", , STR0163, 1)	//"Rotina disponivel apenas para bases Top Connection."
	Return lRet
#ENDIF
				
If SE5TMP->(Eof()) .And. SE5TMP->(Bof())	
	Help( " ", 1, "Tk274CanLiq", , STR0164, 1)	//"A movimentacao do titulo selecionado nao foi encontrada."
Else	
	Begin Transaction
	
		cLiqCan := AllTrim( SE5TMP->E5_DOCUMEN )

		//--- Posiciona no Título, pois a função FINA460 utiliza o RECNO do SE1... 
		SE1->(DbSetOrder(2))	//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
		SE1->(DbSeek(cFilOri + M->ACF_CLIENT + M->ACF_LOJA + cPrefixo + cTitulo + cParcela + cTipo))
		SE1->(dBSetOrder(nOldIdxSE1))	//Devolve o índice original que o SE1 chegou na função

		FINA460( , , , 5, , cLiqCan )	//Cancelamento da liquidacao
		
		//Limpa status da negociacao
		dbselectArea("ACG")
		ACG->(dbSetOrder(1))	//ACG_FILIAL+ACG_CODIGO+ACG_PREFIX+ACG_TITULO+ACG_PARCEL+ACG_TIPO+ACG_FILORI	
		
		If ACG->( dbSeek( xFilial("ACG") + M->ACF_CODIGO + cPrefixo + cTitulo + cParcela + cTipo + cFilOri ) )
			Reclock( "ACG", .F. )
				ACG->ACG_STATUS := " "
			MsUnlock()	
			
			//Limpa o status na grid
			aCols[n, nPosStatus] := " "
			lRet := .T.
		End If
		
		Tk274Client()	//Atualiza os títulos
	
	If !lRet
		DisarmTransaction()
	End If
	
	End Transaction
End If

dbSelectArea("SE5TMP")
dbCloseArea()

RestArea(aAreaACG)
RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ Tk274VldCpo º Autor ³ Vendas Clientes    º Data ³ 04/01/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Validação de dados do telecobrança quando for utilizada a     º±±
±±º          ³ liquidação de títulos negociados.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Telecobrança                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274VldCpo()

Local aArea 	:= GetArea()		//Salva área atual
Local aAreaSED	:= SED->(GetArea())	//Salva área utilizada SED
Local aAreaSX5	:= SX5->(GetArea())	//Salva área utilizada SX5
Local lRet		:= .T.					//Retorno da validação
Local cNatureza	:= SuperGetMV( "MV_TMKNTCB", .F., "" )		//Natureza utilizada na liquidação do título negociado
Local cTipo		:= SuperGetMV( "MV_TMKTPTR", .F., "BOL" )	//Tipo do título gerado na liquidação (Padrão "BOL")
Local cPrefixo	:= SuperGetMV( "MV_TMKPRTR", .F., "REN" )	//Prefixo do título gerado na liquidação (Padrão "REN")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata se os parametros estiverem em branco.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( AllTrim( cTipo ) == "" )
	cTipo := "BOL"
EndIf 

If ( AllTrim( cPrefixo ) == "" )
	cPrefixo := "REN"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se foi informada a condição de pagamento para a liquidação. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lRet ) 
	If ( AllTrim( M->ACF_CONDPG ) == "" )
		Help( " ", 1, "Tk274VldCpo", , STR0165, 1)	//"Preencha a condição de pagamento para a liquidação."
		lRet := .F.
	End If
EndIf
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a natureza usada na liquidação do título negociado.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lRet ) 
	If ( AllTrim( cNatureza ) != "" )
		dbSelectArea("SED")	//Naturezas
		SED->(dbSetOrder(1))	//Filial + Código
		If ( !SED->( dbSeek ( xFilial("SED") + cNatureza ) ) )
			Help( " ", 1, "Tk274VldCpo", , STR0166, 1)	//"Natureza informada no parâmetro MV_TMKNTCB não está cadastrada."
			lRet := .F.
		End If
	Else
		Help( " ", 1, "Tk274VldCpo", , STR0167, 1)		//"Informe a natureza para a liquidação no parâmetro MV_TMKNTCB."
		lRet := .F.
	End If
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o Tipo do título usado na liquidação do título negociado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lRet ) 
	dbSelectArea("SX5")	//Tabelas
	SX5->(dbSetOrder(1))	//Filial + Tabela + Chave
	If ( !SX5->( dbSeek( xFilial("SX5") + "05" + cTipo ) ) )
		Help( " ", 1, "Tk274VldCpo", , STR0168, 1)	//"Tipo do título informado no parâmetro MV_TMKTPTR não está cadastrado."
		lRet := .F.
	End If
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o prefixo do título usado na liquidação do título negociado. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Valida o prefixo
If ( lRet ) 
	If ( AllTrim( cPrefixo ) == "" )
		Help( " ", 1, "Tk274VldCpo", , STR0170, 1)	//"Informe o prefixo do título para a liquidação no parâmetro MV_TMKPRTR."
		lRet := .F.
	End If	
EndIf
	
RestArea(aAreaSX5)
RestArea(aAreaSED)
RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271Titulo  ºAutor  ³ Vendas Clientes    º Data ³  15/10/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do conteudo digitado no campo do numero do titulo no º±±
±±º          ³telecobranca.                                                  º±±
±±º          ³Essa funcao tem que posicionar no SE1 para executar os gatilhosº±±
±±º          ³existentes no campo ACG_TITULO                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TK274Titulo()

Local aArea		:= GetArea()				// Salva a Area atual
Local lRet		:= .T.						// Retorno da funcao
Local nPTitulo	:= aPosicoes[1][2]			// Posicao do Numero do Titulo
Local nPPrefix	:= aPosicoes[2][2]			// Posicao do Prefixo			
Local nPParcel	:= aPosicoes[3][2]			// Posicao da Parcela
Local nPTipo	:= aPosicoes[4][2]			// Posicao do Tipo
Local nPFilOrig	:= 0                       	// Posicao da filial de origem do titulo
Local cTitulo	:= M->ACG_TITULO          	// Numero do titulo
Local lInvertSel:= .F. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o usuario digitou um numero de titulo, utilizo esse numero para posicionar no SE1      ³
//³do contrario, utilizo o numero que foi preenchido no acols, para fazer o posicionamento.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF Len(aCols)==1 .And. Empty(aCols[n][nPTitulo]) .And. Empty(aCols[n][nPPrefix]) .And. Empty(aCols[n][nPTipo]) 
	M->ACG_TITULO := Space(TamSX3("ACG_TITULO")[1])
	lInvertSel := .T.
EndIf
If Empty(cTitulo)
	cTitulo:= aCols[n][nPTitulo]
Endif

nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
If nPFilOrig > 0
   cFilOrig:= aCols[n][nPFilOrig]
Else
	cFilOrig	:= xFilial("SE1")
Endif

DbSelectArea("SE1")
DbSetOrder(1)
If !DbSeek(cFilOrig + aCols[n][nPPrefix] + cTitulo + aCols[n][NPParcel] + aCols[n][NPTipo])
	If lInvertSel
    	lRet := .T.
	Else
		If !lTk271Auto
			Help(" ",1,"TK274PESQF")
		Endif
		lRet := .F.
	EndIF	
Endif

RestArea(aArea)

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TK274Tit ³ Autor ³ Vendas Clientes       ³ Data ³ 24/04/04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe os titulos vencidos do cliente	(F3/ACG/SXB)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELECOBRANCA                                                 ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk274Tit()

Local aTitulos	:= {}										// Array com os titulos vencidos
Local nOpcao	:= 0										// Opcao de confirmacao
Local nCampo	:= 0										// Controle para carregar o acols
Local nTitulo	:= 1										// Titulo selecionado
Local oDlg													// Dialog com Titulos
Local oTitulos												// Listbox com titulos vencidos
Local oOk		:= LoaDbitmap(GetResources(),"LBOK")		// X Verde
Local oNo		:= LoaDbitmap(GetResources(),"LBNO")		// X Vermelho
Local lFlag		:= .F.										// Define se o titulo sera marcado ou desmarcado
Local oVerd		:= LoaDbitmap(GetResources(),"ENABLE")		// Bitmap Verde
Local oVerm		:= LoaDbitmap(GetResources(),"DISABLE")		// Bitmap Vermelho
Local lVencido	:= .F.										// Define se o titulo esta vencido ou nao
Local nPTitulo	:= aPosicoes[1][2]                         	// Posicao do Titulo
Local nPPrefix	:= aPosicoes[2][2]							// Posicao do Prefixo			
Local nPParcel	:= aPosicoes[3][2]							// Posicao da Parcela
Local nPTipo	:= aPosicoes[4][2]							// Posicao do Tipo       
Local nPRecebe	:= aPosicoes[11][2]							// Valor a Receber do Titulo
Local nPJuros	:= aPosicoes[12][2]							// Valor de Juros do Titulo
Local nPValRef	:= aPosicoes[28][2]							// Valor de Referencia
Local nPBaixa   := aPosicoes[29][2]							// Log de Baixa        
Local nPStatus  := aPosicoes[30][2]	   						// Status do Atendimento
Local nPPromoc	:= aPosicoes[16][2]							// Codigo da Promocao de cobranca
Local nPDescFi	:= aPosicoes[13][2]							// Posicao do desconto financeiro
Local nPDescJu	:= 0										// Posicao do desconto sobre os juros
Local lRet		:= .F.										// Retorno da funcao
Local oTodos												// Objeto de selecao
Local lTodos	:= .F.										// Valor do objeto de selecao
Local oInverte												// Objeto de selecao
Local lInverte	:= .F.										// Valor do objeto de selecao
Local cSK1		:= "SK1"									// Alias temporario de controle
Local cSE1		:= "SE1"									// Alias temporario de controle
Local aValores	:= {}										// Array com todos os valores para o rodape.
Local oBmp1													// Objeto da legenda
Local oBmp2													// Objeto da legenda
Local aButtons	:= {}										// Botoes da tool bar
Local oPanel												// Painel de pesquisa
Local oPrefixo												// Objetos de pesquisa
Local oNum													// Objetos de pesquisa
Local oParcela												// Objetos de pesquisa
Local oTipo													// Objetos de pesquisa
Local oVencimento											// Objetos de pesquisa
Local oVencOrig												// Objetos de pesquisa
Local oHistorico											// Objetos de pesquisa
Local oNaturez												// Objetos de pesquisa
Local oPortado												// Objetos de pesquisa
Local oNumBor												// Objetos de pesquisa
Local oEmissao												// Objetos de pesquisa
Local oVencRea												// Objetos de pesquisa
Local lPrefixo		:= .F.									// Variaveis de pesquisa
Local lNum			:= .F.									// Variaveis de pesquisa
Local lParcela		:= .F.									// Variaveis de pesquisa
Local lTipo			:= .F.									// Variaveis de pesquisa
Local lVencimento	:= .F.									// Variaveis de pesquisa
Local lVencOrig		:= .F.									// Variaveis de pesquisa
Local lHistorico	:= .F.									// Variaveis de pesquisa
Local lNaturez		:= .F.									// Variaveis de pesquisa
Local lPortado		:= .F.									// Variaveis de pesquisa
Local lNumBor		:= .F.									// Variaveis de pesquisa
Local lEmissao		:= .F.									// Variaveis de pesquisa
Local lVencRea		:= .F.									// Variaveis de pesquisa
Local oExpressao											// Objetos de pesquisa
Local cExpressao	:= Space(100)							// Variaveis de pesquisa
Local nLenAux		:= 0 									// Variavel auxiliar para o FOR/NEXT	
Local nLenaHead		:= 0 									// Variavel auxiliar para o FOR/NEXT	
Local nPFilOrig		:= 0                                   	// Posicao da filial de origem do titulo da tabela SK1
Local nPFilACG 		:= 0                                   	// Posicao da filial de origem do titulo da tabela ACG
Local cFilOrig		:= ""									// Filial de Origem do titulo
Local nPMulta		:= 0									// Posicao do campo ACG_MULTA que armazena o valor de multa nos itens do atendimento de telecobranca  (somente para integracao com sigaloja)
Local cTmkJuros		:= GetNewPar("MV_TMKAJUR","1")			// Define se o calculo de juros sera baseado nos campos do financeiro ou nos parametros do sigaloja.  1-Financeiro, 2- Sigaloja
Local lMV_TMKTLCT	:= SuperGetMv("MV_TMKTLCT")				// Le o parametro para carregar os titulos a vencer. Somente quando a selecao de titulos for MANUAL.
Local aBkRdpTlc		:= {}									// Armazena o Rodape para reprocessamento dos descontos
Local lTkQry		:= ExistBlock("TK274QRY")		//Ponto de entrada utilizado para adicionar mais filtros na query
Local cQueryPE		:= "" //Filtros do ponto de entrada
Local cFilSK1		:= xFilial("SK1")
Local bSeekTit	    := {|| }
Local cPictValor    := ""
Local cPictSaldo    := ""
Local cSM0LayOut	:= FWSM0Layout()
Local lGestaoEmp    := Iif(lFWCodFil, ("E" $ cSM0LayOut .OR. "U" $ cSM0LayOut), .F.)
Local nLvlModAcc    := IIf(lGestaoEmp, 1, 3)

#IFDEF TOP
	Local cQuery	:= ""									// Query para TOP
	Local aStruSK1	:= SK1->(DbStruct())					// Estrutura do Alias SK1
	Local aStruSE1	:= SE1->(DbStruct())					// Estrutura do Alias SE1
	Local nI		:= 0 
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recupera posicao do campo ACG_DESCJU³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aPosicoes) >= 32
	nPDescJu := aPosicoes[32][2]
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Evita que entre nesta tela caso seja Simulacao de Valores do Telecobranca|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IsInCallStack("Tk274Simul")
	Return(.T.)
EndIf

nPFilOrig	:= SK1->(ColumnPos("K1_FILORIG"))

nPFilACG 	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )

nPMulta	:= Ascan(aHeader, {|x| x[2] == "ACG_MULTA "} )

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona os titulos atrasados do cliente atual.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SK1")
DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DbSelectArea no SE1 para abrir o arquivo on Demand     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE1")
DbSetOrder(1)		

#IFDEF TOP
	cSK1	:= "TMPSK1"				// Alias temporario do SK1
	cSE1	:= "TMPSK1"				// Alias temporario do SK1
	cQuery	:= " SELECT	K1_FILIAL, K1_CLIENTE, K1_LOJA, K1_NUM, K1_PARCELA, K1_TIPO, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, " +;
			   " 			E1_FILIAL, E1_VENCREA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_VENCTO, E1_VENCORI, " +;
			   " 			E1_LOJA, E1_NATUREZ, E1_PORTADO, E1_NUMBOR, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_SALDO, E1_HIST, SK1.K1_FILORIG "
	cQuery += " FROM " +	RetSqlName("SK1") + " SK1, " + RetSqlName("SE1") + " SE1 " +;
			   " WHERE	SK1.K1_FILIAL 	= '" + cFilSK1 + "' AND" +;
			   "		SK1.K1_CLIENTE 	= '" + M->ACF_CLIENT + "' AND" +;
			   "		SK1.K1_LOJA 	= '" + M->ACF_LOJA + "' AND" +;
			   "		SK1.K1_OPERAD 	<> 'XXXXXX' AND" +;
			   "		SK1.D_E_L_E_T_ 	= ' ' AND" 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para filtrar apenas os titulos da filial de origem.  ³
	//³Se o campo nao estiver criado, assumo a filial corrente do SE1. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
	If ( lNewRolTLC )
		cQuery += "		SK1.K1_DTFRENE = '        ' 	AND"
		cQuery += "		SK1.K1_HRFRENE = '     ' 	    AND"
	EndIf
	cQuery += "		SE1.E1_FILIAL 	= SK1.K1_FILORIG 	AND"	
	cQuery += "		SE1.E1_PREFIXO 	= SK1.K1_PREFIXO 	AND" 
	cQuery += "		SE1.E1_NUM 		= SK1.K1_NUM 		AND" 
	cQuery += "		SE1.E1_PARCELA 	= SK1.K1_PARCELA 	AND" 
	cQuery += "		SE1.E1_TIPO 	= SK1.K1_TIPO 		AND" 
	cQuery += "		SE1.E1_VENCTO 	<= SK1.K1_VENCTO 		AND" 
	cQuery += "		SE1.E1_VENCREA <= SK1.K1_VENCREA 		AND" 
	cQuery += "		SE1.E1_SALDO    > 0  AND " 
			
	If lTkQry
		cQueryPE := ExecBlock("TK274QRY",.F.,.F.)
		If ValType(cQueryPE) == "C"
			cQuery += cQueryPE + " AND "
		EndIf						
	EndIf
				
	cQuery+= "		SE1.D_E_L_E_T_ 	= ' '" 
	cQuery+= " 		ORDER BY " + SqlOrder(IndexKey())
	
	cQuery	:= ChangeQuery(cQuery)
	MemoWrite("TK274F3.SQL", cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cSK1, .F., .T.)

	DbSelectArea(cSK1)
	For nI := 1 To Len(aStruSK1)
		If aStruSK1[nI][2] $ "NDL" .AND. FieldPos(aStruSK1[nI][1]) > 0
			TCSetField(cSK1, aStruSK1[nI][1], aStruSK1[nI][2], aStruSK1[nI][3], aStruSK1[nI][4])
		Endif
	Next nI
	
	For nI := 1 To Len(aStruSE1)
		If aStruSE1[nI][2] $ "NDL" .AND. FieldPos(aStruSE1[nI][1]) > 0
			TCSetField(cSK1, aStruSE1[nI][1], aStruSE1[nI][2], aStruSE1[nI][3], aStruSE1[nI][4])
		Endif
	Next nI
#ELSE
	DbSelectArea("SK1")
	DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
	DbSeek(cFilSK1+M->ACF_CLIENT+M->ACF_LOJA)
#ENDIF

cPictValor := PESQPICT("SE1", "E1_VALOR")
cPictSaldo := PESQPICT("SE1", "E1_SALDO")

While	!(cSK1)->(Eof())                    .AND.;
		(cSK1)->K1_FILIAL  == cFilSK1       .AND.;
		(cSK1)->K1_CLIENTE == M->ACF_CLIENT .AND.;
		(cSK1)->K1_LOJA    == M->ACF_LOJA
	
	#IFNDEF TOP
		If (cSK1)->K1_OPERAD == "XXXXXX"
			(cSK1)->(DbSkip())
			Loop
		Endif
		
		If nPFilOrig > 0
			cFilOrig 	:= (cSK1)->K1_FILORIG
		Else
			cFilOrig	:= cFilSE1
		Endif	
		DbSelectArea("SE1")
		DbSetOrder(1)
		If !DbSeek(cFilOrig + (cSK1)->K1_PREFIXO + (cSK1)->K1_NUM + (cSK1)->K1_PARCELA + (cSK1)->K1_TIPO)
			(cSK1)->(DbSkip())
			Loop
		Endif
	#ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o flag de marcado se o titulo ja existir no Acols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If !Empty(aCols[n][nPTitulo])
		If	nPFilACG > 0
			cFilOrig 	:= aCols[n][nPFilACG]
			bSeekTit	:= {|x| x[nPFilACG] + x[nPPrefix] + x[nPTitulo] + x[nPParcel] + x[nPTipo] == cFilOrig + (cSK1)->K1_PREFIXO + (cSK1)->K1_NUM + (cSK1)->K1_PARCELA + (cSK1)->K1_TIPO}
		Else
			bSeekTit	:= {|x| x[nPPrefix] + x[nPTitulo] + x[nPParcel] + x[nPTipo] == (cSK1)->K1_PREFIXO +(cSK1)->K1_NUM + (cSK1)->K1_PARCELA + (cSK1)->K1_TIPO}
		EndIf
		lFlag := ( AScan(aCols, bSeekTit) > 0 )
	Endif
	
	Aadd( aTitulos, {	lFlag,;														// 01 - [x] ou [ ]
						lVencido,;													// 02 - Vermelho ou O - Verde
						(cSE1)->E1_PREFIXO,;										// 03 - Prefixo
						(cSE1)->E1_NUM,;											// 04 - Titulo
						(cSE1)->E1_PARCELA,;										// 05 - Parcela
						(cSE1)->E1_TIPO,;											// 06 - Tipo
						DtoC((cSE1)->E1_EMISSAO),;									// 07 - Emissao 
						DtoC((cSE1)->E1_VENCTO),;									// 08 - Vencimento
						DtoC((cSE1)->E1_VENCREA),;									// 09 - Venc. Real	
						DtoC((cSE1)->E1_VENCORI),;									// 10 - Venc. Original
						(cSE1)->E1_HIST,;											// 11 - Historico
						(cSE1)->E1_NATUREZ,;										// 12 - Natureza 
						(cSE1)->E1_PORTADO,;										// 13 - Portador
						(cSE1)->E1_NUMBOR,;											// 14 - Numero do Bordero
						TRANSFORM((cSE1)->E1_VALOR,   cPictValor),;                 // 15 - Valor	
						TRANSFORM((cSE1)->E1_SALDO,   cPictSaldo),;
						(cSE1)->E1_FILIAL;
						} )
	DbSelectArea(cSK1)
	(cSK1)->(DbSkip())
End
#IFDEF TOP
	DbSelectArea(cSK1)
	DbCloseArea()
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega titulos a vencer se a opcao Selecao de titulos = SIM³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMV_TMKTLCT
	lVencido := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona os titulos A VENCER do cliente atual. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SE1")
	DbSetOrder(7)		// E1_FILIAL+DTOS(E1_VENCREA)+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA

	#IFDEF TOP
		cSE1	:= "TMPSE1"				// Alias temporario do SE1
		cQuery	:=	" SELECT	E1_FILIAL, E1_VENCREA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_VENCTO, E1_VENCORI, " +;
					" 			E1_LOJA, E1_NATUREZ, E1_PORTADO, E1_NUMBOR, E1_EMISSAO, E1_VALOR, E1_SALDO, E1_HIST " +;
					" FROM " +	RetSqlName("SE1") + " SE1 " +;
					" WHERE	SE1.E1_FILIAL " + IIf(FWModeAccess("SE1", nLvlModAcc) == "C", " = ", " > ") + "'" + Space(TamSX3("E1_FILIAL")[1]) + "' AND" +;
					"		SE1.E1_CLIENTE 	= 	'" + M->ACF_CLIENT + 	"' AND" +;
					"		SE1.E1_LOJA 	= 	'" + M->ACF_LOJA + 		"' AND" +;
					"  		SE1.E1_VENCREA 	>= 	'" + DtoS(dDataBase) + 	"' AND" +;
					"		SE1.D_E_L_E_T_ 	= 	' '" +;
					" ORDER BY " + SqlOrder(IndexKey())
		
		cQuery	:= ChangeQuery(cQuery)
		MemoWrite("TK274F3.SQL", cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cSE1, .F., .T.)
		
		DbSelectArea(cSE1)		
		nLenAux := Len(aStruSE1)
		For nI := 1 TO nLenAux
			If aStruSE1[nI][2] $ "NDL" .AND. FieldPos(aStruSE1[nI][1]) > 0
				TCSetField(cSE1, aStruSE1[nI][1], aStruSE1[nI][2], aStruSE1[nI][3], aStruSE1[nI][4])
			Endif
		Next nI
		
	#ELSE

		DbSeek(cFilSE1 + DtoS(dDataBase),.T.)

	#ENDIF
	
	cPictValor := PESQPICT("SE1", "E1_VALOR")
	cPictSaldo := PESQPICT("SE1", "E1_SALDO")

	While (!(cSE1)->(Eof())) .AND.(cSE1)->E1_VENCREA >= dDataBase
		
		#IFNDEF TOP
			If (cSE1)->E1_CLIENTE <> M->ACF_CLIENT .OR. (cSE1)->E1_LOJA <> M->ACF_LOJA
				(cSE1)->(DbSkip())
				Loop
			Endif
		#ENDIF

	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Atualiza o flag de marcado se o titulo ja existir no Acols³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aCols[n][nPTitulo])
			If	nPFilACG > 0
				cFilOrig 	:= (cSE1)->E1_FILIAL
				bSeekTit	:= {|x| x[nPFilACG] + x[nPPrefix] + x[nPTitulo] + x[nPParcel] + x[nPTipo] == cFilOrig + (cSE1)->E1_PREFIXO + (cSE1)->E1_NUM + (cSE1)->E1_PARCELA + (cSE1)->E1_TIPO}
			Else
				bSeekTit	:= {|x| x[nPPrefix] + x[nPTitulo] + x[nPParcel] + x[nPTipo] == (cSE1)->E1_PREFIXO +(cSE1)->E1_NUM + (cSE1)->E1_PARCELA + (cSE1)->E1_TIPO}
			EndIf
			lFlag := ( AScan(aCols, bSeekTit) > 0 )
		Endif 
		
		Aadd( aTitulos, {	lFlag,;															// 01 - [x] ou [ ]
							lVencido,;														// 02 - Vermelho ou O - Verde
							(cSE1)->E1_PREFIXO,;											// 03 - Prefixo
							(cSE1)->E1_NUM,;												// 04 - Titulo
							(cSE1)->E1_PARCELA,;											// 05 - Parcela
							(cSE1)->E1_TIPO,;												// 06 - Tipo
							DtoC((cSE1)->E1_EMISSAO),;										// 07 - Emissao 
							DtoC((cSE1)->E1_VENCTO),;										// 08 - Vencimento
							DtoC((cSE1)->E1_VENCREA),;										// 09 - Venc. Real	
							DtoC((cSE1)->E1_VENCORI),;										// 10 - Venc. Original
							(cSE1)->E1_HIST,;												// 11 - Historico
							(cSE1)->E1_NATUREZ,;											// 12 - Natureza 
							(cSE1)->E1_PORTADO,;											// 13 - Portador
							(cSE1)->E1_NUMBOR,;												// 14 - Numero do Bordero
							TRANSFORM((cSE1)->E1_VALOR,   cPictValor),;	                    // 15 - Valor	
							TRANSFORM((cSE1)->E1_SALDO,   cPictSaldo),;	                    // 16 - Saldo
							(cSE1)->E1_FILIAL;                                         		// 17 - Filial de Origem  	
							} )
		(cSE1)->(DbSkip())
	End
	
	#IFDEF TOP
		DbSelectArea(cSE1)
		DbCloseArea()
	#ENDIF
	
Endif

If (Len(aTitulos) == 0)
	AAdd(aTitulos,{.F., .F., "", "", "", "", "", "", "", "", "", "", "", "", "", "",""} )
Else
	Asort( aTitulos,,, { |x,y| CtoD(x[9]) < CtoD(y[9]) } )
Endif

CursorArrow()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria tela para a escolha do titulo a ser negociado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0081 FROM 0,0 To 380,500 PIXEL //"Seleção de Títulos para negociação"
	
	Aadd(aButtons, { "bmpvisual", { || Tk274SE1Visual(	aTitulos[oTitulos:nAt,3]	,aTitulos[oTitulos:nAt,4]	,aTitulos[oTitulos:nAt,5],;
														aTitulos[oTitulos:nAt,6]	,aTitulos[oTitulos:nAt,17]) }, STR0088} ) //"Visualiza"
	Aadd(aButtons, { "PESQUISA",{ || Tk274SE1Pesq(	oPanel		,oTodos			,oInverte	,cExpressao	,;
													oTitulos	,lPrefixo		,lNum		,lParcela	,;
													lTipo		,lVencimento	,lVencOrig	,lHistorico	,;
													lNaturez	,lPortado		,lNumBor	,lEmissao	,;
													lVencRea	,.F.) }, STR0089} ) //"Pesquisa"
	
	@ 30,05	Listbox oTitulos Fields;
			HEADER	"",;		// 01 - [x] ou [ ]
					"",;		// 02 - Vermelho ou Verde
					STR0017,;	// 03 - Prefixo
					STR0082,;	// 04 - Titulo
					STR0018,;	// 05 - Parcela
					STR0019,;	// 06 - Tipo
					STR0023,;   // 07 - Emissao
					STR0021,;   // 08 - Vencimento
					STR0024,; 	// 09 - Venc. Real
					STR0025,;	// 10 - Venc. Orig
					STR0027,;	// 11 - Historico
					STR0028,;	// 12 - Natureza
					STR0029,;	// 13 - Portador
					STR0030,;	// 14 - Bordero
					STR0022,;	// 15 - Valor
					STR0026;	// 16 - Saldo
			On DbLCLICK (aTitulos[oTitulos:nAt,1]:= !aTitulos[oTitulos:nAt,1], oTitulos:Refresh());
			On Change (nTitulo:= oTitulos:nAt) Size 242,115 Of oDlg Pixel NoScroll

	oTitulos:SetArray(aTitulos)
	oTitulos:bLine:={||{IIF(aTitulos[oTitulos:nAt,1],oOk,oNo),;			// 01 - [x] ou [ ]
						IIF(aTitulos[oTitulos:nAt,2],oVerd,oVerm),;		// 02 - Vermelho ou Verde
					 	aTitulos[oTitulos:nAt,3],;						// 03 - Prefixo
					 	aTitulos[oTitulos:nAt,4],;						// 04 - Titulo
					 	aTitulos[oTitulos:nAt,5],;						// 05 - Parcela
					 	aTitulos[oTitulos:nAt,6],;						// 06 - Tipo
					 	aTitulos[oTitulos:nAt,7],;						// 07 - Emissao
					 	aTitulos[oTitulos:nAt,8],;						// 08 - Vencimento
					 	aTitulos[oTitulos:nAt,9],;						// 09 - Venc. Real	
					 	aTitulos[oTitulos:nAt,10],;						// 10 - Venc. Orig
					 	aTitulos[oTitulos:nAt,11],;						// 11 - Historico
					 	aTitulos[oTitulos:nAt,12],;						// 12 - Natureza		
					 	aTitulos[oTitulos:nAt,13],;						// 13 - Portador
					 	aTitulos[oTitulos:nAt,14],;						// 14 - Bordero	
					 	aTitulos[oTitulos:nAt,15],;						// 15 - Valor
					 	aTitulos[oTitulos:nAt,16],;
						aTitulos[oTitulos:nAt,17]}}
	oTitulos:Refresh()
	
    // Painel de Pesquisa
	@ 030,05 MsPanel oPanel Prompt "" Size 242,115 Of oDlg Centered Lowered
	oPanel:lVisible := .F.
	@ 005,05 To 80,230 Of oPanel Label STR0090 Pixel //"Composicao Sequencial da pesquisa avancada"

	@ 15,010 CheckBox oPrefixo		Var lPrefixo	Size 60,9 Pixel Of oPanel Prompt STR0091 //"01 - Prefixo"
	@ 15,085 CheckBox oNum			Var lNum		Size 60,9 Pixel Of oPanel Prompt STR0092 //"02 - Numero"
	@ 15,165 CheckBox oParcela		Var lParcela	Size 60,9 Pixel Of oPanel Prompt STR0093 //"03 - Parcela"
	@ 30,010 CheckBox oTipo			Var lTipo		Size 60,9 Pixel Of oPanel Prompt STR0094 //"04 - Tipo"
	@ 30,085 CheckBox oEmissao		Var lEmissao	Size 60,9 Pixel Of oPanel Prompt STR0095 //"05 - Emissso"
	@ 30,165 CheckBox oVencimento	Var lVencimento	Size 60,9 Pixel Of oPanel Prompt STR0096 //"06 - Vencimento"
	@ 45,010 CheckBox oVencRea		Var lVencRea	Size 60,9 Pixel Of oPanel Prompt STR0097 //"07 - Vencto Real"
	@ 45,085 CheckBox oVencOrig		Var lVencOrig	Size 60,9 Pixel Of oPanel Prompt STR0098 //"08 - Vencto Original"
	@ 45,165 CheckBox oHistorico	Var lHistorico	Size 60,9 Pixel Of oPanel Prompt STR0099 //"09 - Historico"
	@ 60,010 CheckBox oNaturez		Var lNaturez	Size 60,9 Pixel Of oPanel Prompt STR0100 //"10 - Natureza"
	@ 60,085 CheckBox oPortado		Var lPortado	Size 60,9 Pixel Of oPanel Prompt STR0101 //"11 - Portador"
	@ 60,165 CheckBox oNumBor		Var lNumBor		Size 60,9 Pixel Of oPanel Prompt STR0102 //"12 - Bordero"
	
	@ 85,05 Say STR0103 Of oPanel Pixel //"Expressão da pesquisa"
	@ 95,05 MsGet oExpressao Var cExpressao Size 225,09 Of oPanel Pixel When .T. Valid Tk274SE1Pesq(	oPanel,		oTodos,		oInverte,	cExpressao,;
																										oTitulos,	lPrefixo,	lNum,		lParcela,;
																										lTipo,		lVencimento,lVencOrig,	lHistorico,;
																										lNaturez,	lPortado,	lNumBor,	lEmissao,;
																										lVencRea,	.T.)
	

	@ 150,05 CheckBox oTodos Var lTodos Size 130,9 Pixel Of oDlg Prompt STR0086 On Change Tk274Tools(1, oTitulos, lTodos) //"Marca e Desmarca Todos"
	@ 150,85 CheckBox oInverte Var lInverte Size 130,9 Pixel Of oDlg Prompt STR0087 On Change Tk274Tools(2, oTitulos, lInverte) //"Inverte e Retorna Seleção"
	
    // Legendas da Tela
	@ 165,05 To 185,247 Of oDlg Label STR0083 Pixel //"Legenda"
	@ 173,10 BitMap oBmp1 ResName "BR_VERDE" OF oDlg Size 10,10 NoBorder When .F. Pixel
	@ 173,20 Say STR0084 Of oDlg Pixel //"Titulos a Vencer em aberto"
	
	@ 173,120 BitMap oBmp2 ResName "BR_VERMELHO" OF oDlg Size 10,10 NoBorder When .F. Pixel
	@ 173,130 Say STR0085 Of oDlg Pixel //"Titulos Vencidos em aberto"
	
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| (nOpcao:= 1,oDlg:End())}, {|| oDlg:End() },,aButtons )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Na confirmacao posiciona no titulo selecionado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpcao == 1)
	If !IsInCallStack("TK271CallCenter")
		Return(.T.)
	EndIf
	nUsado:= Len(aHeader) + 1
	aCols := {}
	lRet  := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria linhas no acols se existir mais de um item selecionado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLenAux := Len(aTitulos)

	Tk274LimpaRdp()
	
	For nTitulo:= 1 To nLenAux
		
		If (aTitulos[nTitulo][1])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona uma linha no acols e inicializa os campos.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd(aCols,Array(nUsado))
			nLenaHead := Len(aHeader)
			For nCampo := 1 TO nLenaHead - 2
				aCols[Len(aCols)][nCampo] := CriaVar(aHeader[nCampo][2])
			Next nCampo
			
			aCols[Len(aCols)][nUsado-2]	:= "ACG"
			aCols[Len(aCols)][nUsado-1]	:= 0	

			aCols[Len(aCols)][nUsado] := .F.
			
			DbSelectArea("SE1")
			DbSetOrder(1)
			If DbSeek(aTitulos[nTitulo,17] + aTitulos[nTitulo,3] + aTitulos[nTitulo,4] + aTitulos[nTitulo,5] + aTitulos[nTitulo,6])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o campos do acols e executa os gatilhos.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCols[Len(aCols)][nPTitulo] := aTitulos[nTitulo][4]
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valido a existencia do campo ACG_FILORI criado. Caso nao exista, assumo a filial corrente do SE1³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  		If nPFilACG > 0
			  		aCols[Len(aCols)][nPFilACG] := aTitulos[nTitulo][17]
			  	Endif
		
				Posicione("SX3",2,"ACG_TITULO","")
				RunTrigger(2,Len(aCols))

				If ((nPDescJu > 0) .And. !Empty(SE1->E1_DESCJUR))
					aCols[Len(aCols)][nPDescJu] := SE1->E1_DESCJUR
				EndIf
				
				aValores := FaVlAtuCr(	NIL					, NIL	, NIL	, NIL	,;
										aTitulos[nTitulo,17], .T.	)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o calculo dos juros do titulo for baseado nos parametros MV_LJJUROS e MV_LJMULT ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cTmkJuros == "2" // SIGALOJA
					Tk274CalcJuros(	@aValores		, @aCols		, aHeader, NIL,;
									M->ACF_CLIENT	, M->ACF_LOJA)
				Else                    
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o Valor de Referencia, Receber, Juros, Baixa e Status na Inclusao dos tit³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aCols[Len(aCols)][nPValRef]	:= aValores[6]		// Saldo do Titulo 
					aCols[Len(aCols)][nPJuros]	:= aValores[8]		// Valor de Juros
					aCols[Len(aCols)][nPRecebe]	:= aValores[12] 	// Valor a Receber
	            Endif
	            
		        Do Case 
		        	Case !Empty(SE1->E1_BAIXA) // Se houve uma baixa verifica se foi TOTAL ou PARCIAL
		        		 If (SE1->E1_SALDO > 0)
							aCols[Len(aCols)][nPBaixa] := "1" //Baixa Parcial
							aCols[Len(aCols)][nPStatus]:= "4" //Baixa
						 Endif
						 
						 If (SE1->E1_SALDO == 0)
							aCols[Len(aCols)][nPBaixa] := "3" //Baixa Total
							aCols[Len(aCols)][nPStatus]:= "1" //Pago
						 Endif	
		
			        Case Empty(SE1->E1_BAIXA) // Nao houve nenhuma baixa 
						aCols[Len(aCols)][nPBaixa] := "2" //Sem Baixa            	
		
			  	EndCase	  	
		
				// [2] Abatimentos
				// [A] Correcao Monetaria
				// [8] Juros
				// [5] Acrescimo     - E1_SDACRES
				// [4] Decrescimo    - E1_SDDECRE
				// [9] Desconto
				// [1] Valor Original do Titulo
				// [6] Saldo do Titulo na Moeda do Titulo
				// [7] Saldo do Titulo na Moeda Corrente
				// [3] Pagto Parcial
				// [B] Valor a ser Recebido na moeda do titulo
				// [C] Valor a ser Recebido na moeda corrente
				
				aRdpTlc[1][2]	:= aRdpTlc[1][2] + aValores[2]
				aRdpTlc[2][2]	:= aRdpTlc[2][2] + aValores[10]
				aRdpTlc[3][2]	:= aRdpTlc[3][2] + aValores[8]
				aRdpTlc[4][2]	:= aRdpTlc[4][2] + SE1->E1_SDACRES 
				aRdpTlc[5][2]	:= aRdpTlc[5][2] + SE1->E1_SDDECRE 
				aRdpTlc[6][2]	:= aRdpTlc[6][2] 
				aRdpTlc[7][2]	:= aRdpTlc[7][2] + aValores[1]
				aRdpTlc[8][2]	:= aRdpTlc[8][2] + aValores[6]
				aRdpTlc[9][2]	:= aRdpTlc[9][2] + aValores[7]
				aRdpTlc[10][2]	:= aRdpTlc[10][2] + aValores[3]
				aRdpTlc[11][2]	:= aRdpTlc[11][2] + aValores[11] + aValores[9] - SE1->E1_SDDECRE
				aRdpTlc[12][2]	:= aRdpTlc[12][2] + aValores[12] + aValores[9]
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica as regras de desconto no cadastro ³
				//³ de Promocao de Cobranca (SK3)              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SK3")
				DbSetOrder(2)		// K3_FILIAL+K3_VCTINI
				DbSeek(xFilial("SK3") + DtoS(SE1->E1_VENCREA), .T.)
				If SE1->E1_VENCREA >= SK3->K3_VCTINI .AND. SE1->E1_VENCREA <= SK3->K3_VCTFIM
					If dDataBase >= SK3->K3_INICIO .AND. dDataBase <= SK3->K3_FINAL
						aCols[Len(aCols)][nPPromoc] := SK3->K3_CODIGO
					Endif
				Else
					SK3->(DbSkip(-1))
					If SE1->E1_VENCREA >= SK3->K3_VCTINI .AND. SE1->E1_VENCREA <= SK3->K3_VCTFIM
						If dDataBase >= SK3->K3_INICIO .AND. dDataBase <= SK3->K3_FINAL
							aCols[Len(aCols)][nPPromoc] := SK3->K3_CODIGO
						Endif
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Recalcula os descontos ja aplicados³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						

				aBkRdpTlc 	:= aClone(aRdpTlc) 

				Tk274DescFi(aCols[Len(aCols)][nPDescFi]		, aCols		, Len(aCols)	, Nil	,;
							Nil								, @aBkRdpTlc, .T.			)

				aRdpTlc := aClone(aBkRdpTlc)

	            If (nPDescJu <> 0) 

       				aBkRdpTlc 	:= aClone(aRdpTlc)
       				
		            Tk274DescJu(aCols[Len(aCols)][nPDescJu]	, aCols		, Len(aCols) 	, Nil	,;
							Nil								, @aBkRdpTlc, .T.			)
					
					aRdpTlc := aClone(aBkRdpTlc)   

		        EndIf
				
			Endif	   
		Endif
	Next nTitulo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Depois de carregar o aCols com os titulos selecionados atualiza os totais do Rodape³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRdpTlc[1][1]:Refresh()
	aRdpTlc[2][1]:Refresh()
	aRdpTlc[3][1]:Refresh()
	aRdpTlc[4][1]:Refresh()
	aRdpTlc[5][1]:Refresh()
	aRdpTlc[6][1]:Refresh()
	aRdpTlc[7][1]:Refresh()
	aRdpTlc[8][1]:Refresh()
	aRdpTlc[9][1]:Refresh()
	aRdpTlc[10][1]:Refresh()
	aRdpTlc[11][1]:Refresh()
	aRdpTlc[12][1]:Refresh()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso chegar ate aqui com o aCols vazio, entao carrega em branco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) == 0
	AAdd(aCols,Array(nUsado))

	nLenaHead := Len(aHeader)
	For nCampo := 1 TO nLenaHead-2
		aCols[Len(aCols)][nCampo] := CriaVar(aHeader[nCampo][2])
	Next nCampo

	aCols[Len(aCols)][nUsado-2]	:= "ACG"
	aCols[Len(aCols)][nUsado-1]	:= 0	
	aCols[Len(aCols)][nUsado] := .F.
	lRet := .T.
	M->ACG_TITULO := Space(TamSX3("ACG_TITULO")[1])	
	
Else
	// Posiciona no primeiro titulo dos itens do atendimento de Telecobranca
	n							:= 1
	
	oGetTlc:oBrowse:Refresh()

	If nPFilACG > 0
		cFilOrig 	:= aCols[n][nPFilACG]
	Else
		cFilOrig	:= xFilial("SE1")
	Endif	
	DbSelectArea("SE1")
	DbSeek(cFilOrig + aCols[n][nPPrefix] + aCols[n][nPTitulo] + aCols[n][nPParcel] + aCols[n][nPTipo] )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a data limite para realizar a cobranca e carrega os campos necessarios³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
Tk274AtuPz(Tk274GtPz())

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274SE1VisualºAutor³ Vendas Clientes    º Data ³ 04/11/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de visualizacao do Titulo, auxiliar da pesquisa F3 naº±±
±±º          ³rotina de Telecobranca Tk274Tit().                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274SE1Visual(cPrefixo, cNum, cParcela, cTipo, cFilOrig)

DbSelectArea("SE1")
DbSetOrder(1)
DbSeek(cFilOrig + cPrefixo + cNum + cParcela + cTipo)

AxVisual("SE1", SE1->(Recno()), 2)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274SE1PesqºAutor³ Vendas Clientes    º Data ³  04/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de pesquisa do Titulo, auxiliar da pesquisa F3 na ro-º±±
±±º          ³tina de Telecobranca Tk274Tit().                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274SE1Pesq(	oPanel,		oTodos,		oInverte,	cExpressao,;
						oTitulos,	lPrefixo,	lNum,		lParcela,;
						lTipo,		lVencimento,lVencOrig,	lHistorico,;
						lNaturez,	lPortado,	lNumBor,	lEmissao,;
						lVencRea,	lPesq)


Local nPos	:= 0			// Indice utilizado para posicionamento no vetor oTitulos:aArray

If oPanel:lVisible
	oPanel:lVisible		:= .F.
	oTodos:Enable()
	oInverte:Enable()
Else
	oPanel:lVisible 	:= .T.
	oTodos:Disable()
	oInverte:Disable()
Endif

If !lPesq
	Return(.T.)
Endif

nPos := Ascan( oTitulos:aArray, {|x|	SubStr(	AllTrim(IIF(lPrefixo,x[3],"")) +;
												AllTrim(IIF(lNum,x[4],"")) +;
												AllTrim(IIF(lParcela,x[5],"")) +;
												AllTrim(IIF(lTipo,x[6],"")) +;
												AllTrim(IIF(lEmissao,x[7],"")) +;
												AllTrim(IIF(lVencimento,x[8],"")) +;
												AllTrim(IIF(lVencRea,x[9],"")) +;
												AllTrim(IIF(lVencOrig,x[10],"")) +;
												AllTrim(IIF(lHistorico,x[11],"")) +;
												AllTrim(IIF(lNaturez,x[12],"")) +;
												AllTrim(IIF(lPortado,x[13],"")) +;
												AllTrim(IIF(lNumBor,x[14],"")),1,Len(AllTrim(cExpressao))) == AllTrim(cExpressao) } )


If nPos > 0
	oTitulos:nAt := nPos
	oTitulos:SetFocus()
	oTitulos:Refresh()
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274DtVencºAutor ³ Vendas Clientes    º Data ³  14/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de validacao do campo ACF_DTVENC que representa a  daº±±
±±º          ³ta de vencimento do titulo.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cCodOper  - Define o Operador que esta alterando a data paraº±±
±±º          ³            verificar as permicoes.                         º±±
±±º          ³nLin      - Numero da linha, para execucao interna.         º±±
±±º          ³dDataPag  - Data para pagamento do titulo.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274DtVenc(cOperador,nLin,dDataPag)

Local lRet		:= .F.									// Retorno da funcao
Local aArea		:= GetArea()							// Guarda a area atual	
Local aAreaSE1	:= SE1->(GetArea())					// Guarda a area do SE1
Local cRegNeg   := TkPosto(M->ACF_OPERAD,"U0_REGNEG") 	// Codigo da Regra de Negociacao
Local nPFilOrig	:= 0									// Filial de origem do titulo
Local nPPrefix	:= 0									// Posicao do campo prefixo
Local nPTitulo	:= 0									// Posicao do campo titulo
Local nPParcel	:= 0									// Posicao do campo parcela
Local nPTipo	:= 0									// Posicao do campo tipo
Local nPJuros	:= 0									// Posicao do campo juros
Local nPRecebe	:= 0									// Posicao do campo recebe
Local nPValRef	:= 0									// Posicao do campo valor de referencia
Local nPDescFi	:= 0									// Posicao do campo desconto financeiro
Local nPDescJu	:= 0									// Posicao do campo desconto sobre juros
Local nPBaixa	:= 0									// Posicao do campo baixa
Local nPStatus	:= 0									// Posicao do campo status da cobranca
Local nDescJur	:= 0									// Desconto aplicado sobre os juros
Local nJuros	:= 0									// Valor dos Juros
Local lAuto		:= .F.									// Indica se a funcao foi acionada internamente
Local nNBkp		:= N									// Armazena o numero da linha atual

Default dDataPag:= &(ReadVar()) 						// Data informada pelo usuario

If nLin <> NIL
	lAuto	:= .T.
	N		:= nLin
EndIf

DbSelectArea("SK2")
DbSetOrder(1)
If DbSeek(xFilial("SK2") + cRegNeg)
	If SK2->K2_ALTTIT == "1"	// SIM - Pode alterar Titulo
		If dDataPag >= dDataBase
			If SK2->K2_DIAPROR == 0
				lRet := .F.
			ElseIf dDataPag <= dDataBase + SK2->K2_DIAPROR
				lRet := .T.
			Endif
		Endif
	Endif
Endif

If !lRet   

	If !lAuto
		Help(" ",1,"TKNPERMITE")
	EndIf

ElseIf aCols[N][Ascan(aHeader,{|x|x[2]=="ACG_STATUS"})] == "1" 

	If !lAuto
		Help(" ",1,"TK274VENTIT")   //"A data de vencimento não pode ser"##"alterada, pois o título já foi pago."
	EndIf
	lRet := .F.

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega a posicao dos campos no acols do titulo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPPrefix	:= Ascan(aHeader, {|x| x[2] == "ACG_PREFIX"} )
	nPTitulo	:= Ascan(aHeader, {|x| x[2] == "ACG_TITULO"} )
	nPParcel	:= Ascan(aHeader, {|x| x[2] == "ACG_PARCEL"} )
	nPTipo		:= Ascan(aHeader, {|x| x[2] == "ACG_TIPO  "} )
	nPJuros		:= Ascan(aHeader, {|x| x[2] == "ACG_JUROS "} )
	nPRecebe	:= Ascan(aHeader, {|x| x[2] == "ACG_RECEBE"} )
	nPValRef	:= Ascan(aHeader, {|x| x[2] == "ACG_VALREF"} )
	nPDescFi	:= Ascan(aHeader, {|x| x[2] == "ACG_DESCFI"} )
	nPBaixa 	:= AScan(aHeader, {|x| x[2] == "ACG_BAIXA "} )
	nPStatus  	:= Ascan(aHeader, {|x| x[2] == "ACG_STATUS"} )
		
	nPDescJu	:= Ascan(aHeader, {|x| x[2] == "ACG_DESCJU"} )
	
	nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
	
	If nPfilOrig > 0
		cFilOrig:= aCols[N][nPFilOrig]	//Filial de origem do titulo
	Else
		cFilOrig:= xFilial("SE1")
	Endif  
	
	DbSelectArea("SE1")
	DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Numero + Parcela + Tipo

	If DbSeek(cFilOrig + M->ACF_CLIENT + M->ACF_LOJA + aCols[N][nPPrefix] + aCols[N][nPTitulo] + aCols[N][nPParcel] + aCols[N][nPTipo])
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recalcula os juros e os descontos para o titulo apos a alteracao³
		//³da data                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDescJur			:= (aCols[N][nPJuros] * (aCols[N][nPDescJu] / 100) )
		
		aRdpTlc[3][2]		:= aRdpTlc[3][2]  - aCols[N][nPJuros]
		aRdpTlc[6][2]		:= aRdpTlc[6][2]  - nDescJur
		aRdpTlc[11][2]		:= aRdpTlc[11][2] + nDescJur - aCols[N][nPJuros]
		aRdpTlc[12][2]		:= aRdpTlc[12][2] + nDescJur - aCols[N][nPJuros]
		aCols[N][nPRecebe]	:= aCols[N][nPRecebe] - aCols[N][nPJuros]
		
		nJuros	:= FaJuros(	SE1->E1_VALOR	, SE1->E1_SALDO		, dDataPag			, SE1->E1_VALJUR	,;
							SE1->E1_PORCJUR	, SE1->E1_MOEDA		, SE1->E1_EMISSAO	, dDataPag			,;
							SE1->E1_BAIXA	, SE1->E1_VENCREA	)


		aCols[N][nPJuros] := nJuros
		
		nDescJur := 0
		
		If nJuros > 0
			nDescJur := (aCols[N][nPJuros] * (aCols[N][nPDescJu] / 100) )
		Else
			aCols[N][nPDescJu]	:= 0
		EndIf
		
		aRdpTlc[3][2]		:= aRdpTlc[3][2]  + aCols[N][nPJuros]
		aRdpTlc[6][2]		:= aRdpTlc[6][2]  - aCols[N][nPJuros]
		aRdpTlc[11][2]		:= aRdpTlc[11][2] + aCols[N][nPJuros] - nDescJur
		aRdpTlc[12][2]		:= aRdpTlc[12][2] + aCols[N][nPJuros] - nDescJur
		aCols[N][nPRecebe]	:= aCols[N][nPRecebe] + aCols[N][nPJuros]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula a simulacao dos descontos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
		Tk274DescFi(	aCols[N][nPDescFi]	, @aCols	, N	, M->ACF_OPERAD	,;
						aHeader 			, Nil		, .T.)
							
		If (nPDescJu <> 0) 
        	Tk274DescJu(aCols[N][nPDescJu]	, @aCols	, N	, M->ACF_OPERAD	,;
            			aHeader				, Nil		, .T.)
        EndIf	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Faz um refresh no rodape da tela de atendimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRdpTlc <> NIL
			aEval( aRdpTlc, { |x| x[1]:Refresh() } )	
		Endif

	EndIf	

Endif

If lAuto
	N := nNBkp
EndIf

RestArea(aAreaSE1)
RestArea(aArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Tk271Valor³ Autor ³ Vendas Clientes       ³ Data ³ 21/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se valor podera' ser alterado, ou se abat > valor  ³±±
±±³          ³Funcao existente no campo ACG_VALOR.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Tk274Valor() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CALL CENTER - TELECOBRANCA   							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk274Valor(lValor)

Local nValor   := IIf(lValor,&(ReadVar()),aCols[n,aPosicoes[10,2]])	// Valor a ser considerado
Local nRec     := 0														// Recno do SE1
Local lRet     := .T.													// Retorno da funcao
Local nPTitulo := aPosicoes[1,2]										// Posicao do titulo
Local nPPrefixo:= aPosicoes[2,2]										// Posicao do prefixo do titulo
Local nPParcela:= aPosicoes[3,2]										// Posicao da parcela do titulo
Local nPTipo   := aPosicoes[4,2]										// Posicao do tipo do titulo
Local nPFilOrig:= 0														// Posicao da filial de origem do titulo
Local cFilOrig := ""													// Filial de origem do titulo


nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
If nPFilOrig > 0
	cFilOrig := aCols[N][nPFilOrig]
Else
	cFilOrig := xFilial("SE1")		
Endif	

If (Posicione("SE1",1,cFilOrig + aCols[n,nPPrefixo] + aCols[n,nPTitulo] + aCols[n,nPParcela] + aCols[n,nPTipo],"E1_MOEDA") > 99)
	Return(.F.)
Else
	nRec:= SE1->(RecNo())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o abatimento e' maior que valor do titulo         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[n,nPTipo])
	If (aCols[n,nPTipo] $ MVPROVIS)
		DbSelectArea( "SE1" )
		If DbSeek( cFilOrig +  aCols[n,nPPrefixo] + aCols[n,nPTitulo] + aCols[n,nPParcela])
			
			While !SE1->(Eof()) .AND. (SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA) == (cFilOrig,aCols[n,nPPrefixo] + aCols[n,nPTitulo] + aCols[n,nPParcela])
				If (SE1->E1_TIPO $ MVABATIM)
					DbSkip( )
					Loop
				Endif
				
				If (nValor > SE1->E1_SALDO)
					Help(" ",1,"ABATMAIOR")
					lRet := .F.
					Exit
				Endif

				Exit
			End
			
			SE1->(DbGoTo(nRec))
		Endif
	Endif
Endif

If (SE1->E1_LA = "S")
	Help(" ",1,"NAOVALOR")
	lRet:=.F.
Endif

If (SE1->E1_TIPO $ MVIRABT+"/"+MVINABT+"/"+MVCFABT+"/"+MVCSABT+"/"+MVPIABT)
		Help(" ",1,"NOVALORIR")
		lRet:=.F.
Endif
	
If (SE1->E1_TIPO $ MVRECANT)
	Help( " ",1,"FA040ADTO")
	lRet := .F.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Tk271Natur³ Autor ³ Vendas Clientes       ³ Data ³ 21/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula os impostos se a natureza assim o mandar			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tk274Natur()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Ap6 Call Center	Telecobraca / Dicionario de dados   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk274Natur(lNatureza)

Local lRet     := .T.
Local nPTitulo := aPosicoes[1][2] 	 		// Numero do Titulo
Local nPPrefixo:= aPosicoes[2][2]			// Prefixo do titulo
Local nPParcela:= aPosicoes[3][2]			// Parcela do Titulo
Local nPTipo   := aPosicoes[4][2]			// Tipo do titulo
Local nPNaturez:= aPosicoes[6][2]	 		// Natureza do titulo
Local nPValor  := aPosicoes[10][2]	 		// Valor Original do Titulo
Local nPIrrf   := aPosicoes[23][2]	  		// Valor do IRRF
Local nPIss    := aPosicoes[24][2]	  		// Valor do ISS
Local nPCsll   := aPosicoes[25][2]	  		// Valor do CSLL
Local nPCofins := aPosicoes[26][2]	   		// Valor do COFINS
Local nPPis    := aPosicoes[27][2]	   		// Valor do PIS
Local cNatureza:= ""                 		// Codigo da Natureza
Local nPFilOrig:= 0                    		// Posicao da Filial do titulo
Local cFilOrig := ""                    	// Filial do Titulo
Local nAliqIRF := SuperGetMV("MV_ALIQIRF")	// Aliquota de IRF
Local nAliqISS := SuperGetMV("MV_ALIQISS")	// Aliquota de ISS
Local nVlRetIRF:= SuperGetMv("MV_VLRETIR")	// Valor para retencao de IRF
Local nVlRetCsl:= SuperGetMv("MV_VRETCSL")	// Valor para retencao de CSLL
Local nTxCofin := SuperGetMv("MV_TXCOFIN")	// Taxa do Cofins
Local nVlRetCof:= SuperGetMv("MV_VRETCOF")	// Valor para retencao de Cofins
Local nTxPis   := SuperGetMv("MV_TXPIS")	// Taxa do PIS
Local nVlRetPis:= SuperGetMv("MV_VRETPIS")	// Valor para retencao do PIS
Local cNatIRF  := SuperGetMv("MV_IRF")		// Natureza para IRF
Local cNatISS  := SuperGetMv("MV_ISS")		// Natureza para ISS
Local cNatINSS := SuperGetMv("MV_INSS")		// Natureza para INSS
Local cNatCSLL := SuperGetMv("MV_CSLL")		// Natureza para CSLL
Local cNatCOF  := SuperGetMv("MV_COFINS")	// Natureza para Cofins
Local cNatPis  := SuperGetMv("MV_PISNAT")	// Natureza para PIS

Default lNatureza := .T.

nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
    If nPFilOrig > 0
	cFilOrig := aCols[N][nPFilOrig]
Else
	cFilOrig := xFilial("SE1")	
Endif	


cNatureza:= IIf(lNatureza, &(ReadVar()), aCols[n,nPNaturez])

If Empty(cNatureza)
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ N„o permite alterar natureza se titulo ja foi contabiliz. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Posicione("SE1",1,cFilOrig + aCols[n,nPPrefixo] + aCols[n,nPTitulo] + aCols[n,nPParcela] + aCols[n,nPTipo] ,"E1_LA") = "S")
	Help(" ",1,"NAOVALOR")
	Return(.F.)
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ N„o permite alterar natureza quando adiantamento para n„o ³
//³ desbalancear o arquivo de Movimenta‡„o Banc ria (SE5).    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (aCols[n,nPTipo] $ MVRECANT)
	Help(" ",1,"FA040NONAT")
	Return(.F.)
Endif

DbSelectArea("SED")
If !(DbSeek(xFilial("SED") + cNatureza))
	Help(" ",1,"E1_NATUREZ")
	lRet := .F.
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento dos campos dos impostos Brasileiros E1_IRRF,  ³
	//³ E1_INSS, etc...											 ³
	//ÀÄTransp DM Argentina Lucas e Armando 05/01/00ÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (aCols[n,nPValor] > 0)
		aCols[n,nPIrrf] := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula IR se a natureza mandar  				    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SED->ED_CALCIRF == "S")
			aCols[n,nPIrrf]:= NoRound(aCols[n,nPValor] * Iif(AllTrim(Str(SE1->E1_MOEDA,2))$"01",1,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA))) * IIf(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nAliqIRF )/100
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Titulos Provisorios ou Antecipados n†o geram IR        	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aCols[n,nPTipo] $ MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM)
			aCols[n,nPIrrf] := 0
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento de Dispensa de Retencao de IRF             	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aCols[n,nPIrrf] <= nVlRetIRF )
			aCols[n,nPIrrf] := 0
		Endif              
		
		aCols[n,nPIss]:= 0
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula ISS se natureza mandar                         	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SED->ED_CALCISS == "S")
			aCols[n,nPIss]  := aCols[n,nPValor] * nAliqIss / 100
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Titulos Provisorios ou Antecipados n†o geram ISS       	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aCols[n,nPTipo] $ MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM)
			aCols[n,nPIss] := 0
		Endif             
		
		aCols[n,nPCsll] := 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula CSLL se a natureza mandar 					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SED->ED_CALCCSL == "S") .AND. (SA1->A1_RECCSLL == "S")
			aCols[n,nPCsll] := (aCols[n,nPValor] * (SED->ED_PERCCSL / 100))
		Endif                                  
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Titulos Provisorios ou Antecipados n†o geram CSLL         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aCols[n,nPTipo] $ MVPROVIS+"/"+MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG+"/"+MVABATIM)
			aCols[n,nPCsll] := 0
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento de Dispensa de Retencao de CSLL             	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( aCols[n,nPCsll] < nVlRetCsl )
			aCols[n,nPCsll] := 0
		Endif

		aCols[n,nPCofins] := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula COFINS se a natureza mandar 					  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SED->ED_CALCCOF == "S") .AND. (SA1->A1_RECCOFI == "S")
			aCols[n,nPCofins] := (aCols[n,nPValor] * (IIf(SED->ED_PERCCOF > 0, SED->ED_PERCCOF, nTxCofin) / 100))
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Titulos Provisorios ou Antecipados n†o geram COFINS       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aCols[n,nPTipo] $ MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM)
			aCols[n,nPCofins]:= 0
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento de Dispensa de Retencao de COFINS           	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( aCols[n,nPCofins] < nVlRetCof )
			aCols[n,nPCofins] := 0
		Endif

		aCols[n,nPPis] := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula PIS se a natureza mandar 					  	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SED->ED_CALCPIS == "S") .AND. (SA1->A1_RECPIS == "S")
			aCols[n,nPPis] := (aCols[n,nPValor] * (IIf(SED->ED_PERCPIS > 0, SED->ED_PERCPIS, nTxPis ) / 100))
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Titulos Provisorios ou Antecipados n†o geram PIS          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aCols[n,nPTipo] $ MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM)
			aCols[n,nPPis] := 0
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento de Dispensa de Retencao de PIS             	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( aCols[n,nPPis] < nVlRetPis )
			aCols[n,nPPis] := 0
		Endif

	Endif

	If  cNatureza $ &(cNatIRF) 	.OR. ;
		cNatureza $ &(cNatISS) 	.OR. ;
		cNatureza $ &(cNatINSS) .OR. ;
		cNatureza $ (cNatCSLL)	.OR. ;
		cNatureza $ (cNatCOF).OR. ;
		cNatureza $ (cNatPis) 

		aCols[n,nPTipo] := MVTAXA
		aCols[n,nPTipo]	:= IIf(cNatureza $ (cNatCSLL)	,"MVCSABT" , aCols[n,nPTipo])
		aCols[n,nPTipo]	:= IIf(cNatureza $ (cNatCOF),"MVCFABT-", aCols[n,nPTipo])
		aCols[n,nPTipo]	:= IIf(cNatureza $ (cNatPis),"MVPIABT" , aCols[n,nPTipo]) 
	Endif
Endif  

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Tk271TlcImposto ³ Autor ³ Vendas Clientes       ³ Data ³ 21/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula os impostos se a natureza assim o mandar		            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Ap6 Call Center / Telecobranca - Dicionario de dados             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk274TlcImposto(cImposto)

Local lRet     := .T.
Local nPTitulo := aPosicoes[1][2]		// Numero do Titulo
Local nPPrefixo:= aPosicoes[2][2]		// Prefixo do Titulo
Local nPParcela:= aPosicoes[3][2]      // Parcela do Titulo
Local nPTipo   := aPosicoes[4][2]		// Tipo do Titulo
Local nPValor  := aPosicoes[10][2]		// Valor Original do Titulo	
Local nPIrrf   := aPosicoes[23][2]		// Valor de IRRF
Local nPIss    := aPosicoes[24][2]		// Valor de ISS
Local nPCsll   := aPosicoes[25][2]		// Valor de CSLL
Local nPCofins := aPosicoes[26][2]		// Valor de COFINS
Local nPPis    := aPosicoes[27][2]		// Valor de PIS
Local nPFilOrig:= 0						// Posicao da filial de origem do titulo
Local cFilOrig := ""					// Filial de origem do titulo
	

nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
If nPFilOrig > 0
	cFilOrig := aCols[N][nPFilOrig]
Else
	cFilOrig := xFilial("SE1")
Endif	

If (Posicione("SE1",1,cFilOrig + aCols[n,nPPrefixo] + aCols[n,nPTitulo] + aCols[n,nPParcela] + aCols[n,nPTipo] ,"E1_LA") = "S")
	Help(" ",1,"NAOVALOR")
	Return(.F.)
Endif

Do Case
	Case (cImposto == "IRRF")
		lRet:= ((aCols[n,nPIrrf] < aCols[n,nPValor]) .AND. (aCols[n,nPTipo] <> "PR" .AND. aCols[n,nPIrrf] > 0))
					
	Case (cImposto == "ISS")
		lRet:= ((aCols[n,nPIss] < aCols[n,nPValor]) .AND. (aCols[n,nPTipo] <> "PR" .AND. aCols[n,nPIss] > 0))

	Case (cImposto == "CSLL")
		lRet:= ((aCols[n,nPCsll] > aCols[n,nPValor]) .AND. (aCols[n,nPTipo] <> "PR" .AND. aCols[n,nPCsll] > 0))

	Case (cImposto == "COFINS")
		lRet:= ((aCols[n,nPCofins] > aCols[n,nPValor]) .AND. (aCols[n,nPTipo] <> "PR" .AND. aCols[n,nPCofins] > 0))

	Case (cImposto == "PIS")
		lRet:= ((aCols[n,nPPis] > aCols[n,nPValor]) .AND. (aCols[n,nPTipo] <> "PR" .AND. aCols[n,nPPis] > 0))

EndCase

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk271EnvTlc  ³ Autor ³ Vendas Clientes     ³ Data ³ 29/11/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa o envio de email para os usuarios selecionados      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Somente Telecobranca		   						          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Tk274EnvTlc(cCidade,cEst,cTelRes,cTelCom1,cEnd,aSX3ACF)

Local aCabecalho:= {}                                         					// Array que carrega a descricao do atendimento
Local aItens	:= {}															// Array para compor os itens do atendimento
Local aLabel	:= {}															// Contem a descricao dos itens de cobranca
Local nLinhas	:= 0															// Percorre as linhas do acols para montar a descricao
Local cMensagem := ""															// Monta a descricao do atendimento
Local aSend		:= {}															// Monta um array com os destinatarios de cada linha do acols
Local cEmail	:= ""															// e-mail do remetente
Local cAssunto	:= ""															// Assunto do email
Local nCont		:= 0															// Contador	
Local nPTitulo	:= aPosicoes[1][2]												// Titulo
Local nPPrefix	:= aPosicoes[2][2]                             					// Prefixo
Local nPParcel	:= aPosicoes[3][2]                                              // Parcela
Local nPTipo	:= aPosicoes[4][2]												// Tipo
Local nPDtVenc	:= aPosicoes[8][2]                                              // Data de Vencimento
Local nPDtReal	:= aPosicoes[9][2] 												// Data de Vencimento Real				
Local nPValor	:= aPosicoes[10][2]                                             // Valor do titulo
Local nPAcresc	:= aPosicoes[14][2]												// Acrescimo
Local nPDecres	:= aPosicoes[15][2]                                             // Decrescimo
Local nPOperad	:= aPosicoes[17][2]                                             // Operador
Local nPValJur	:= aPosicoes[20][2]                                             // Valor de juros
Local nPPorJur	:= aPosicoes[21][2]                                             // Porcentual de juros
Local nPStatus	:= aPosicoes[30][2]                                             // Status

//Variaveis utilizadas nos itens do e-mail para exibir os titulos
Local cStatus	:= ""															// Contem o status do titulo
Local cPrefixo	:= ""                                                          	// Contem o prefixo do titulo
Local cTitulo 	:= ""                                                          	// Contem o Numero do titulo
Local cParcela	:= ""                                                          	// Contem a Parcela do titulo
Local cTipo   	:= ""                                                          	// Contem o Tipo do titulo
Local cDtVencto := ""                                                          	// Contem a Data de Vencimento 
Local cDtReal   := ""                                                          	// Contem o Data Real 
Local cValor	:= ""                                                          	// Contem o Valor a Receber
Local cAcresc	:= ""                                                          	// Contem o Valor de Acrescimo
Local cDescres	:= ""                                                          	// Contem o Valor de Descrecimo
Local cTxPerm	:= ""                                                          	// Contem a Taxa de Permanencia
Local cJuros	:= ""                                                          	// Contem a Taxa de Juros 
Local aStatuAt	:= TkSx3Box("ACF_STATUS")                                      	// Contem o status do atendimento 
Local cAccount	:= Posicione("SU7",1,xFilial("SU7") + M->ACF_OPERAD,"U7_CONTA")	// Conta do remetente
Local cPassword	:= Posicione("SU7",1,xFilial("SU7") + M->ACF_OPERAD,"U7_SENHA")	// Senha do remetente
Local cUsaEmail := TkPosto(M->ACF_OPERAD,"U0_TLCMAIL")							// Validacao se o operador pode mandar email
Local cRelServ	:= SuperGetMv("MV_RELSERV")										// Servidor para envio de e-mails de relatorios
Local lTK274ema := ExistBlock("TK274EMA")

// Captura a senha do operador sem criptografia
If !Empty(cPassword)
	cPassword := Embaralha(cPassword,1)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o operador pode mandar email para os clientes   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cUsaEmail == "1"  //Sim

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pesquisa no SX3 qual a descricao dos campos, caso o usuario tenha alterado³
	//³e monta o ARRAY  com o cabecalho do atendimento de Telecobranca.			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// 01 - Atendimento
	nPos	:= Ascan(aSx3ACF,{|x| x[1] $ "ACF_CODIGO"})
	IIf (nPos > 0,AAdd(aCabecalho, {aSx3ACF[nPos][4], M->ACF_CODIGO}),"")	
    
    // 02 - Codigo + Loja + Nome do cliente
	nPos	:= Ascan(aSx3ACF,{|x| x[1] $ "ACF_CLIENT"})
	IIf (nPos > 0,AAdd(aCabecalho, {aSx3ACF[nPos][4], M->ACF_CLIENT + "-" + M->ACF_LOJA + " - " +M->ACF_DESC }),"")	
	
	// 03 - Contato + Nome do contato
	nPos	:= Ascan(aSx3ACF,{|x| x[1] $ "ACF_CODCON"})
	IIf (nPos > 0,AAdd(aCabecalho, {aSx3ACF[nPos][4], M->ACF_CODCON + " - " + ACF_DESCNT}),"") 
	
	// 04 - Cidade - Estado 
	Aadd(aCabecalho, {STR0157 ,cCidade + "-" + cEst})		//"Cidade"
	// 05 - Endereco			
	Aadd(aCabecalho, {STR0158 ,cEnd})						//"Endereço"		
	// 06 - Telefone Resid/Comer -06
	Aadd(aCabecalho, {STR0159 ,Transform(cTelRes,"@R 9999-9999") + "/" + Transform(cTelCom1,"@R 9999-9999")}) //"Telefones"

	// 07 - Operador + Nome do operador
	nPos	:= Ascan(aSx3ACF,{|x| x[1] $ "ACF_OPERAD"})
	IIf (nPos > 0,AAdd(aCabecalho, {aSx3ACF[nPos][4], M->ACF_OPERAD+ " - " + ACF_DESCOP}),"")	
	
	// 08 - Ligacao: ATIVO/RECEPTIVO 
	nPos	:= Ascan(aSx3ACF,{|x| x[1] $ "ACF_OPERA "})
	IIf (nPos > 0,AAdd(aCabecalho, {aSx3ACF[nPos][4],IIF(Val(M->ACF_OPERA) == ATIVO,STR0056,STR0057)}),"")

	// 09 - Status: STATUS DO ATENDIMENTO
	nPos	:= Ascan(aSx3ACF,{|x| x[1] $ "ACF_STATUS"})
	IIf (nPos > 0,AAdd(aCabecalho, {aSx3ACF[nPos][4],IIF(!Empty(M->ACF_STATUS),aStatuAt[Val(M->ACF_STATUS)],"")}),"")
	
	// 10 - Ocorrencia + Codigo + Descricao da ocorrencia
	nPos	:= Ascan(aSx3ACF,{|x| x[1] $ "ACF_MOTIVO"})
	IIf (nPos > 0,AAdd(aCabecalho, {aSx3ACF[nPos][4], M->ACF_MOTIVO + " - " +ACF_DESCMO }),"")
	
	// 11 - Data do atendimento 
	nPos	:= Ascan(aSx3ACF,{|x| x[1] $ "ACF_DATA  "})
	IIf (nPos > 0,AAdd(aCabecalho, {aSx3ACF[nPos][4],DTOC(M->ACF_DATA)}),"")	

	// 12 - Data e Hora do Retorno
	AAdd(aCabecalho, {STR0060, DTOC(M->ACF_PENDEN) + " - " + M->ACF_HRPEND})								
	
	// 13 - Observacao do atendimento	 
	nPos	:= Ascan(aSx3ACF,{|x| x[1] $ "ACF_OBS   "})  
	IIf (nPos > 0,AAdd(aCabecalho, {aSx3ACF[nPos][4],MSMM(ACF->ACF_CODOBS,80)}),"")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para acrescentar informacoes no e-mail. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lTK274ema
		aCabecalho := ExecBlock("TK274EMA",.F.,.F.,aCabecalho)
	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca a descricao dos campos existentes no SX3.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Posicione("SX3",2,"ACG_PREFIX"	,"X3_TITULO")
	cPrefixo	:= AllTrim(X3Titulo())       
	Posicione("SX3",2,"ACG_TITULO"	,"X3_TITULO")
	cTitulo 	:= AllTrim(X3Titulo())       
	Posicione("SX3",2,"ACG_PARCEL"	,"X3_TITULO")
	cParcela	:= AllTrim(X3Titulo())       
	Posicione("SX3",2,"ACG_TIPO"	,"X3_TITULO")
	cTipo   	:= AllTrim(X3Titulo())       
	Posicione("SX3",2,"ACG_DTVENC"	,"X3_TITULO")
	cDtVencto:= AllTrim(X3Titulo())       
	Posicione("SX3",2,"ACG_DTREAL"	,"X3_TITULO")
	cDtReal 	:= AllTrim(X3Titulo())       
	Posicione("SX3",2,"ACG_VALOR"	,"X3_TITULO")
	cValor  	:= AllTrim(X3Titulo())       
	Posicione("SX3",2,"ACG_ACRESC"	,"X3_TITULO")
	cAcresc 	:= AllTrim(X3Titulo())       
	Posicione("SX3",2,"ACG_DECRES"	,"X3_TITULO")
	cDescres	:= AllTrim(X3Titulo())       
	Posicione("SX3",2,"ACG_VALJUR"	,"X3_TITULO")
	cTxPerm 	:= AllTrim(X3Titulo())       
	Posicione("SX3",2,"ACG_JUROS"	,"X3_TITULO")
	cJuros  	:= AllTrim(X3Titulo())       
	Posicione("SX3",2,"ACG_STATUS"	,"X3_TITULO")
	cStatus 	:= AllTrim(X3Titulo())       

	AAdd( aLabel, {cPrefixo	, "30",	"left"}) 	//"Prf"
	AAdd( aLabel, {cTitulo 	, "50",	"left"}) 	//"Titulo"
	AAdd( aLabel, {cParcela	, "30",	"left"}) 	//"Par"
	AAdd( aLabel, {cTipo   	, "30",	"left"}) 	//"Tipo"
	AAdd( aLabel, {cDtVencto, "55",	"left"})	//"Venc"
	AAdd( aLabel, {cDtReal 	, "55",	"left"}) 	//"Real"
	AAdd( aLabel, {cValor 	, "75",	"right"}) 	//"Valor"
	AAdd( aLabel, {cAcresc	, "60",	"right"}) 	//"Acresc"
	AAdd( aLabel, {cDescres	, "60",	"right"}) 	//"Decres"
	AAdd( aLabel, {cTxPerm	, "40",	"right"}) 	//"Perm"
	AAdd( aLabel, {cJuros 	, "40",	"right"}) 	//"Juros"
	AAdd( aLabel, {cStatus 	, "50",	"left"}) 	//"Status"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o ARRAY  com os itens do atendimento do Telecobranca  	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLinhas := 1 TO len(aCols)
		
		Do Case
			Case aCols[nLinhas][nPStatus] == "1"
				cStatus := STR0073 //"PAGO"
		
			Case aCols[nLinhas][nPStatus] == "2"
				cStatus := STR0074 //"NEGOCIADO"
		
			Case aCols[nLinhas][nPStatus] == "3"
				cStatus := STR0075 //"CARTORIO"
		
			Otherwise
				cStatus := ""
		EndCase
		
		If !(aCols[nLinhas][Len(aHeader)+1])	// Se a linha nao estiver apagada.
		
			If !Empty(aCols[nLinhas][nPOperad]) // Se houver um operador selecionado
				AAdd( aItens,	{ SubStr(aCols[nLinhas][nPPrefix],1,TamSX3("E1_PREFIXO")[1]),;								// 01
								  SubStr(aCols[nLinhas][nPTitulo],1,TamSX3("E1_NUM")[1]),;								// 02
								  SubStr(aCols[nLinhas][nPParcel],1,TamSX3("E1_PARCELA")[1]),;								// 03
								  SubStr(aCols[nLinhas][nPTipo],1,TamSX3("E1_TIPO")[1]),;                                 // 04
								  DTOC(aCols[nLinhas][nPDtVenc]),;                                      // 05
								  DTOC(aCols[nLinhas][nPDtReal]),;                                      // 06
								  Transform(aCols[nLinhas][nPValor] , PesqPict("ACG", "ACG_VALOR")),;   // 07  
								  Transform(aCols[nLinhas][nPAcresc], PesqPict("ACG", "ACG_ACRESC")),;  // 08
								  Transform(aCols[nLinhas][nPDecres], PesqPict("ACG", "ACG_DECRES")),;  // 09 
								  Transform(aCols[nLinhas][nPValJur], PesqPict("ACG", "ACG_VALJUR")),;  // 10
								  Transform(aCols[nLinhas][nPPorJur], PesqPict("ACG", "ACG_PORJUR")),;  // 11
								  cStatus } )
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta o ARRAY para o numero de usuarios que vao receber³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cEmail 	 := UsrRetMail(aCols[nLinhas][nPOperad])+";"
				cAssunto := STR0076 //"Atendimento call center - Telecobrança"
				
				If (At("@",cEmail) > 0)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³So serao somados os e-mails diferentes.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (Ascan(aSend,{|x| AllTrim(x[1]) == AllTrim(cEmail)}) == 0 )
						AAdd(aSend,{cEmail,cAssunto,"",""})
					Endif
				Endif
			Endif
			
		Endif      
		
	Next nLinhas
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega a conta e a senha do email do usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aSend) > 0
		If TkAccount(@cAccount,@cPassword)
		
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta o corpo do E-mail                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    Tk274Body(@cMensagem,aCabecalho,aItens,aLabel)

			For nCont := 1 TO Len(aSend)
				aSend[nCont][MENSAGEM] := cMensagem
			Next nCont
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Envio de E-mail³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nCont:= 1 To Len(aSend)              
				MsgRun(  STR0077,"",; //"Enviando e-mail para os responsáveis..."
						{ ||lSend:= TkSendMail(	cAccount			,cPassword				,cRelServ				,UsrRetMail(__cUserID),;
												aSend[nCont][EMAIL]	,aSend[nCont][ASSUNTO]	,aSend[nCont][MENSAGEM]	,aSend[nCont][ANEXO]) })
			Next nCont
		Endif
	Endif
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TK274Body ºAutor  ³ Vendas Clientes    º Data ³  16/10/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o corpo do e-mail em Html                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Somente Telecobranca                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Body(cMensagem,aCabecalho,aItens,aLabel)

Local nI := 0			// Contador
Local nJ := 0			// Contador	

cMensagem := "<html>"  
cMensagem += "<body>"  

cMensagem += '<p align="center"><b><font color="#FF0000" face="Arial" size="4">'
cMensagem += STR0034 //"Call Center TeleCobrança"
cMensagem += '</font></b></p>'

cMensagem += '<hr>'

cMensagem += '<p><font face="Arial"><b>'
cMensagem += STR0035 //"Dados do Atendimento"
cMensagem += '</b></font></p>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³comeca a montar o cabecalho do atendimento no e-mail        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMensagem += '<table border="1" >'	// width="100%"

For nI := 1 TO Len(aCabecalho)
	cMensagem += '<tr>'
	cMensagem += '<td width="200"><b><font size="2">&nbsp;<font color="#0000FF" face="Verdana">'
	cMensagem += IIF(!Empty(aCabecalho[nI][1]),aCabecalho[nI][1],'&nbsp;')
	cMensagem += '</font>&nbsp;</font></b></td>'
	cMensagem += '<td width="460"><font face="Verdana" size="2">'
	cMensagem += IIF(!Empty(aCabecalho[nI][2]),aCabecalho[nI][2],'&nbsp;')
	cMensagem += '</font></td>'
	cMensagem += '</tr>'
Next nI
                        
cMensagem += "</table>"
cMensagem += "<br>"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agora monta  o label dos itens do atendimento para o e-mail      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMensagem += '<table border="1" >'		// width="100%"

cMensagem += '<tr>'
For nI := 1 TO Len(aLabel)
	cMensagem += '<td width="'+aLabel[nI][2]+'"><b><font color="#0000FF" face="Verdana" size="1">'
	cMensagem += IIF(!Empty(aLabel[nI][1]),aLabel[nI][1]+'&nbsp;','&nbsp;')
	cMensagem += '</font></td>'
Next nI
cMensagem += '</tr>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta os itens do atendimento para o e-mail³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aItens)
	cMensagem += '<tr>'
	For nJ := 1 to Len(aItens[nI])
		cMensagem += '<td width="'+aLabel[nJ][2]+'"><font face="Verdana" size="1">'
		cMensagem += Iif(!Empty(aItens[nI][nJ]),'<p align="'+aLabel[nJ][3]+'">'+aItens[nI][nJ]+'&nbsp;'+'</td>','&nbsp;')
		cMensagem += '</font></td>'
	Next nJ
	cMensagem += '</tr>'
Next nI
cMensagem += "</table>"

//cMensagem += '<p>&nbsp;</p>'
cMensagem += '</body>'
cMensagem += '</html>'

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK271EvaTlc  ºAutor  ³ Vendas Clientes    º Data ³  15/10/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao na troca da linha no browser que contem os titulos   º±±
±±º          ³no telecobranca.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Call Center                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK274EvaTlc()

Local lRet := .T.													// Retorno da validacao
Local nPTitulo	:= Ascan(aHeader, {|x| x[2] == "ACG_TITULO"} )		// Posicao do campo ACG_TITULO no aHeader

If !aCols[n][Len(aCols[n])] .AND. Empty(aCols[n][nPTitulo])
	Help("",1,"FALTA_TIT")
	lRet := .F.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK274HACF     ºAutor  ³ Vendas Clientesº Data ³  22/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao da hora de retorno                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TELECOBRANCA                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TK274HACF(cHora,dData)

Local lRet		:= .T.					// Retorno da validacao
Local nQtdZero	:= 0  					// Quantidade de zeros a complementar
Local nX		:= 1  					// Auxiliar de loop
Local cDigito	:= ""					// Digito da hora avaliado

Default cHora	:= &( ReadVar() )		// Hora para retorno
Default dData	:= M->ACF_PENDEN		// Data para retorno

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o formato foi respeitado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While lRet .AND. nX <= 5       
	cDigito := SubStr(cHora,nX,1)
	If nX <> 3 .AND. !Empty(cDigito) .AND. !IsDigit(cDigito)
		lRet := .F.
	EndIf  
	nX++
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Corrige a hora, se foi informada parcialmente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet 
	cHora := StrZero(Val(SubStr(cHora,1,2)),2) + ":" + SubStr(cHora,4,2)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Corrige os minutos, se foram informados parcialmente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. (nQtdZero := Len(AllTrim(SubStr(cHora,4,2)))) < 2
	cHora := SubStr(cHora,1,2) + ":" + SubStr(cHora,4,nQtdZero) + Replicate("0",2-nQtdZero)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a validade da hora³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	lRet .AND. (Val(SubStr(cHora,1,2)) < 24) .AND. (Val(SubStr(cHora,4,2)) < 60)
	If dData == dDataBase .AND. (cHora < PadR(Time(),5))
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta a hora no campo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. IsInCallStack("TK271CALLCENTER") .AND. Type("M->ACF_HRPEND") == "C"  
	M->ACF_HRPEND := cHora
EndIf
                                                                          
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274ItensºAutor  ³ Vendas Clientes    º Data ³  31/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta funcao carrega os titulos na tela de atendimento que deº±±
±±º          ³verao ser cobrados pelo operador.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Itens(aItens)

Local nPTitulo	:= aPosicoes[1][2]											// Numero do Titulo
Local nPRecebe	:= aPosicoes[11][2]											// Valor a Receber do Titulo
Local nPJuros	:= aPosicoes[12][2]											// Valor de Juros do Titulo
Local nPPromoc	:= aPosicoes[16][2]											// Promocao 
Local nPValRef	:= aPosicoes[28][2]											// Valor de Referencia
Local nPBaixa   := aPosicoes[29][2]											// Log de Baixa        
Local nPStatus  := aPosicoes[30][2]											// Status do Atendimento
Local nPDtVenc	:= aPosicoes[8][2] 											// Data de Vencimento			
Local nPAtraso	:= Ascan(aHeader, {|x| x[2] == "ACG_ATRASO"} )				// Dias em atraso
Local nUsado	:= Len(aHeader) + 1  										// Numero de campos usados
Local nI		:= 0                                 						// Contador de loop
Local nJ		:= 0                                         				// Contador de loop
Local aValores	:= {}                                         				// Array com os valores de cada titulo com a ultima posicao de acordo com o SE1
Local nPFilOrig	:= 0             											// Posicao da filial de origem do titulo na tabela ACG    
Local cFilOrig	:= ""           											// Filial de origem do titulo
Local nPMulta	:= 0														// Posicao do campo ACG_MULTA que armazena o valor de multa nos itens do atendimento de telecobranca  (somente para integracao com sigaloja)
Local cTmkJuros	:= GetNewPar("MV_TMKAJUR","1")								// Define se o calculo de juros sera baseado nos campos do financeiro ou nos parametros do sigaloja.  1-Financeiro, 2- Sigaloja
Local nPDescJu  := Ascan(aHeader, {|x| x[2] == "ACG_DESCJU"} )  // Posicao no aCols do campo ACG_DESCJU

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta a posicao do campo Filial de Origem ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )

nPMulta		:= Ascan(aHeader, {|x| x[2] == "ACG_MULTA "} )

// Limpa os Itens para comecar a carregar
aCols := {}

// Zera o rodape para recalcular e acordo com os itens carregados
Tk274LimpaRdp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria linhas no acols se existir mais de um item selecionado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI:= 1 To Len(aItens)
	
	If nPfilOrig > 0
		cFilOrig:= aItens[nI][5]	//Filial de origem do titulo
	Else
		cFilOrig:= xFilial("SE1")
	Endif		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o titulo ainda existe no SE1    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SE1")
	DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Numero + Parcela + Tipo
	If DbSeek(cFilOrig + M->ACF_CLIENT+ M->ACF_LOJA+ aItens[nI][1] + aItens[nI][2] + aItens[nI][3] + aItens[nI][4])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona uma linha no acols e inicializa os campos.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aCols,Array(nUsado))
		For nJ := 1 to Len(aHeader)-2
			aCols[Len(aCols)][nJ] := CriaVar(aHeader[nJ][2])
		Next nJ                      
		aCols[Len(aCols)][nUsado-2]	:= "ACG"
		aCols[Len(aCols)][nUsado-1]	:= 0		
		
		aCols[Len(aCols)][nUsado] := .F.
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o campos do acols e executa os gatilhos.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols[Len(aCols)][nPTitulo] := aItens[nI][2]
		Posicione("SX3",2,"ACG_TITULO","")
		RunTrigger(2,Len(aCols))

		If ((nPDescJu > 0) .And. !Empty(SE1->E1_DESCJUR))
			aCols[Len(aCols)][nPDescJu] := SE1->E1_DESCJUR
		EndIf
		
		aValores := FaVlAtuCr(	NIL		, NIL	, NIL	, NIL	,;
								cFilOrig, .T.	)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o calculo dos juros do titulo for baseado nos parametros MV_LJJUROS e MV_LJMULT ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTmkJuros == "2"		//SIGALOJA
			Tk274CalcJuros(	@aValores		,@aCols		, aHeader, NIL,;
							M->ACF_CLIENT	,M->ACF_LOJA)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o Valor de Referencia, Receber, Juros, Baixa e Status na Inclusao        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCols[Len(aCols)][nPValRef]	:= aValores[6]	//Saldo do Titulo 
			aCols[Len(aCols)][nPJuros]	:= aValores[8] 	//Juros baseado no SE1
			aCols[Len(aCols)][nPRecebe]	:= aValores[12]	//Valor a Receber 
			aCols[Len(aCols)][nPStatus]:=Posicione("ACG",1,xFilial("ACG")+ACF->ACF_CODIGO+aItens[nI][1]+aItens[nI][2]+aItens[nI][3]+aItens[nI][4],"ACG_STATUS") 
		Endif
			
		aCols[Len(aCols)][nPAtraso]	:= dDataBase - aCols[Len(aCols)][nPDtVenc]
  		If nPFilOrig > 0
	  		aCols[Len(aCols)][nPFilOrig]:= aItens[nI][5] //Filial Original do titulo
	  	Endif

        Do Case 
        	Case !Empty(SE1->E1_BAIXA) // Se houve uma baixa verifica se foi TOTAL ou PARCIAL
        		 If (SE1->E1_SALDO > 0)
					aCols[Len(aCols)][nPBaixa] := "1" //Baixa Parcial
					aCols[Len(aCols)][nPStatus]:= "4" //Baixa
				 Endif
				 
				 If (SE1->E1_SALDO == 0)
					aCols[Len(aCols)][nPBaixa] := "3" //Baixa Total
					aCols[Len(aCols)][nPStatus]:= "1" //Pago
				 Endif	

	        Case Empty(SE1->E1_BAIXA) // Nao houve nenhuma baixa 
				aCols[Len(aCols)][nPBaixa] := "2" //Sem Baixa            	

	  	EndCase	  	
	  	
		// [2] Abatimentos
		// [A] Correcao Monetaria
		// [8] Juros
		// [5] Acrescimo	- E1_SDACRES
		// [4] Decrescimo   - E1_SDDECRE
		// [9] Desconto
		// [1] Valor Original do Titulo
		// [6] Saldo do Titulo na Moeda do Titulo
		// [7] Saldo do Titulo na Moeda Corrente
		// [3] Pagto Parcial
		// [B] Valor a ser Recebido na moeda do titulo
		// [C] Valor a ser Recebido na moeda corrente				

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os valores no Rodape ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRdpTlc[1][2]	:= aRdpTlc[1][2] + aValores[2]
		aRdpTlc[2][2]	:= aRdpTlc[2][2] + aValores[10]
		aRdpTlc[3][2]	:= aRdpTlc[3][2] + aValores[8]
		aRdpTlc[4][2]	:= aRdpTlc[4][2] + SE1->E1_SDACRES 
		aRdpTlc[5][2]	:= aRdpTlc[5][2] + SE1->E1_SDDECRE
		aRdpTlc[6][2]	:= aRdpTlc[6][2] + aValores[9]
		aRdpTlc[7][2]	:= aRdpTlc[7][2] + aValores[1]
		aRdpTlc[8][2]	:= aRdpTlc[8][2] + aValores[6]
		aRdpTlc[9][2]	:= aRdpTlc[9][2] + aValores[7]
		aRdpTlc[10][2]	:= aRdpTlc[10][2]+ aValores[3]
		aRdpTlc[11][2]	:= aRdpTlc[11][2]+ aValores[11]
		aRdpTlc[12][2]	:= aRdpTlc[12][2]+ aValores[12]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao for entrada automatica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lTk271Auto
			aRdpTlc[1][1]:Refresh()
			aRdpTlc[2][1]:Refresh()
			aRdpTlc[3][1]:Refresh()
			aRdpTlc[4][1]:Refresh()
			aRdpTlc[5][1]:Refresh()
			aRdpTlc[6][1]:Refresh()
			aRdpTlc[7][1]:Refresh()
			aRdpTlc[8][1]:Refresh()
			aRdpTlc[9][1]:Refresh()
			aRdpTlc[10][1]:Refresh()
			aRdpTlc[11][1]:Refresh()
			aRdpTlc[12][1]:Refresh()
		Endif
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as regras de desconto no cadastro ³
		//³ de Promocao de Cobranca (SK3)              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SK3")
		DbSetOrder(2)		// K3_FILIAL+K3_VCTINI
		DbSeek(xFilial("SK3") + DtoS(SE1->E1_VENCREA), .T.)
		If SE1->E1_VENCREA >= SK3->K3_VCTINI .AND. SE1->E1_VENCREA <= SK3->K3_VCTFIM
			If dDataBase >= SK3->K3_INICIO .AND. dDataBase <= SK3->K3_FINAL
				aCols[Len(aCols)][nPPromoc] := SK3->K3_CODIGO
			Endif
		Else
			SK3->(DbSkip(-1))
			If SE1->E1_VENCREA >= SK3->K3_VCTINI .AND. SE1->E1_VENCREA <= SK3->K3_VCTFIM
				If dDataBase >= SK3->K3_INICIO .AND. dDataBase <= SK3->K3_FINAL
					aCols[Len(aCols)][nPPromoc] := SK3->K3_CODIGO
				Endif
			Endif
		Endif
		
	Endif
Next nI
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso chegar ate aqui com o aCols vazio, entao carrega em branco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aCols) == 0
	AAdd(aCols,Array(nUsado))
	For nI := 1 to Len(aHeader)-2
		aCols[Len(aCols)][nI] := CriaVar(aHeader[nI][2])
	Next nI	
	aCols[Len(aCols)][nUsado-2]	:= "ACG"
	aCols[Len(aCols)][nUsado-1]	:= 0		
	aCols[Len(aCols)][nUsado] := .F.
	n := 1
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274CamposºAutor ³ Vendas Clientes    º Data ³  13/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta funcao define os campo que estarao desabilitados para eº±±
±±º          ³dicao na enchoice.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos - Devolve por @ os campos que ficarao desabilitados º±±
±±º          ³lAtivo  - Tipo de atendimento ATIVO / RECEPTIVO             º±±
±±º          ³nOpc    - Tipo de Operacao Inclusao,Alteracao,Exclusao,etc  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Campos(aCampos, lAtivo, nOpc)

Local cFora	:= ""	// Contem os campos que estarao desabilitados na enchoice

// Se o atendimento for ATIVO desabilita a edicao dos campos abaixo
If lAtivo .OR. nOpc <> 3
	cFora := "ACF_CLIENT"
Endif

DbSelectArea("SX3")
DbSetOrder(1)
If DbSeek("ACF")
	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "ACF"
		If X3USO(SX3->X3_USADO) .AND. !(AllTrim(SX3->X3_CAMPO) $ cFora)
			Aadd(aCampos, SX3->X3_CAMPO )
		Endif
		SX3->(DbSkip())
	End
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274ClientºAutor ³ Vendas Clientes    º Data ³  15/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valid do campo ACF_CLIENT que atualiza os titulos a serem   º±±
±±º          ³cobrados pelo operador.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Client()

Local aArea		:= GetArea()				// Salva a area atual
Local aItens	:= {}				 		// Titulos que serao cobrados
Local dAntigo	:= CTOD("//")				// Data de vencimento mais antiga
Local lRet		:= .F.				 		// Retorno da funcao
Local cRegSel   := ""				  		// Codigo da Regra de Selecao do Operador "dono" do titulo
Local cRegNeg   := ""				   		// Codigo da Regra de Negociacao do Operador "dono" do titulo
Local cCodOper	:= CRIAVAR("U7_COD",.F.)	//Codigo do Operador que sera usado para buscar as regras no Grupo de Atendimento
Local cFilOrig  := ""						// Filial de origem do titulo
Local cLojaPad	:= SuperGetMv("MV_LOJAPAD")	// Loja padrao do cliente

#IFDEF TOP
	Local cQuery:= ""						// Expressao de pesquisa no banco de dados
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa as variaveis do rodape sempre³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLigacao := ""
cOperador:= ""
cOperacao:= ""
cStatus  := ""
cProximo := ""
cContHist:= ""
cNomeHist:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O campo ACF_LOJA nao possui inicilizador padrao. Utilizo a loja padrao³
//³existente no parametro caso a mesma nao tenha sido informada.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(M->ACF_LOJA)
	M->ACF_LOJA:= cLojaPad
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for uma ALTERACAO nao permite a alteracao dos dados do cliente , caso contrario o operador pode apagar todo o historico de um atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !INCLUI
	If M->ACF_CLIENT + M->ACF_LOJA <> ACF->ACF_CLIENT + ACF->ACF_LOJA
		Aviso(STR0128,STR0079,{"Ok"}) //"Na alteração de cobrança não é possível alterar o cliente","Atenção",{"OK"}) 
		Return(lRet)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Primeiro: Atualiza o nome do cliente a partir do codigo e da loja (se estiver preenchido)                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
DbSetOrder(1)
If ReadVar() == "M->ACF_CLIENT"
	If !Empty(M->ACF_LOJA)
		If DbSeek(xFilial("SA1") + M->ACF_CLIENT + M->ACF_LOJA,.T.)
		 	M->ACF_DESCCLI := SA1->A1_NOME
		 	cTipo		   := SA1->A1_TIPO
		 	M->ACF_LOJA	   := SA1->A1_LOJA    
		ElseIf DbSeek(xFilial("SA1") + M->ACF_CLIENT,.T.)
		 	M->ACF_DESCCLI := SA1->A1_NOME
		 	cTipo		   := SA1->A1_TIPO
		 	M->ACF_LOJA	   := SA1->A1_LOJA    		
		EndIf
	ElseIf DbSeek(xFilial("SA1") + M->ACF_CLIENT,.T.)
	 	M->ACF_DESCCLI := SA1->A1_NOME
	 	cTipo		   := SA1->A1_TIPO
	 	M->ACF_LOJA	   := SA1->A1_LOJA    		
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe o cliente  na base ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistCpo("SA1",M->ACF_CLIENTE+M->ACF_LOJA)
	M->ACF_DESCCLI := ""
	Return(lRet)
Endif

	                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os dados da entidade e do contato que serao exibidos no rodape³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cContHist:=TkDadosContato(M->ACF_CODCON,0)
cNomeHist:=TkEntidade("SA1",M->ACF_CLIENTE+M->ACF_LOJA,1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Segundo: Atualiza o rodape da tela com o ultimo atendimento feito para o cliente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ACF")
DbSetOrder(3)//ACF_CLIENT+ACF+LOJA+STR(ACF_DIASDA,8,0)+STR(ACF_HORADA,8,0)
If DbSeek(xFilial("ACF") + M->ACF_CLIENT + M->ACF_LOJA)
	cLigacao 	:= DTOC(CTOD("01/01/45")-ACF->ACF_DIASDA) + " - " + Substr(ACF->ACF_INICIO,1,5)
	cOperador	:= Posicione("SU7",1,xFilial("SU7") + ACF->ACF_OPERAT,"U7_NOME")
    If Val(ACF->ACF_OPERA) == ATIVO    
	    cOperacao	:= STR0056  
    ElseIf Val(ACF->ACF_OPERA) == RECEPTIVO
	    cOperacao	:= STR0057  
    Endif    
    
	If Val(ACF->ACF_STATUS) == PLANEJADA
		cStatus := STR0121 // "Atendimento" 
	ElseIf Val(ACF->ACF_STATUS) == PENDENTE
		cStatus := STR0122 // "Cobranca"   
	Else
		cStatus := STR0123 // "Encerrado" 
	Endif
    
	DbSelectArea("SU7")
	DbSetOrder(1)
	If DbSeek(xFilial("SU7") + ACF->ACF_OPERAD)
		If !Empty(ACF->ACF_PENDEN)
			cProximo := DTOC(ACF->ACF_PENDEN) + " - " + ACF->ACF_HRPEND + " - " + cOperador
		Endif
	Endif
Endif             


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao for entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTk271Auto
	oLigacao:Refresh()
	oOperador:Refresh()
	oStatus:Refresh()
	oOperacao:Refresh()
	oProximo:Refresh()
	oContHist:Refresh()
	oNomeHist:Refresh()
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa os itens de cobranca porque os titulos so podem ser informados depois da escolha do CLIENTE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If INCLUI
	aCols := Array(1, Len(aHeader) + 1)
	TkHeader("ACF","ACG_CODIGO",@aCols,aHeader)
	If !lTk271Auto
		oGetTlc:oBrowse:Refresh(.T.)
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa os Titulos pendentes do cliente para serem cobrados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CursorWait()

If Select("SK1") > 0
	SK1->(DbCloseArea())
EndIf

DbSelectArea("SK1")
DbSetOrder(4)	// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
#IFDEF TOP
	cQuery	:=	" SELECT K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, K1_FILIAL, K1_VENCREA, K1_CLIENTE, K1_LOJA, K1_OPERAD " 
	cQuery+= " ,K1_FILORIG "

	cQuery+=	" FROM " +	RetSqlName("SK1") + " SK1 " +;
				" WHERE	SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' AND" +;
				"		SK1.K1_CLIENTE 	= '" + SA1->A1_COD 	+ "' AND" +;
				"		SK1.K1_LOJA 	= '" + SA1->A1_LOJA + "' AND" +;
				"		SK1.K1_OPERAD <> 'XXXXXX' AND"+;
				"		SK1.D_E_L_E_T_ = ' '" +;
				" ORDER BY " + SqlOrder(IndexKey())
	
	cQuery	:= ChangeQuery(cQuery)
	// MemoWrite("TK280SK1.SQL", cQuery)
	DbSelectArea("SK1")
	DbCloseArea()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SK1', .F., .T.)
	
	TcSetField("SK1", "K1_VENCREA", "D")
	
#ELSE
	DbSeek(xFilial("SK1") + SA1->A1_COD + SA1->A1_LOJA)
#ENDIF

While !SK1->(Eof())							.AND.;
	  SK1->K1_FILIAL	== xFilial("SK1")	.AND.;
	  SK1->K1_CLIENTE	== SA1->A1_COD		.AND.;
	  SK1->K1_LOJA		== SA1->A1_LOJA
	
	#IFNDEF TOP
		// Nao carrega titulos marcados para a regra de excessao de cobranca
		If SK1->K1_OPERAD == "XXXXXX"
			DbSelectArea("SK1")
			SK1->(DbSkip())
			Loop
		Endif
	#ENDIF
	
	cFilOrig:=	SK1->K1_FILORIG

	AAdd(aItens, {	SK1->K1_PREFIXO	,;
					SK1->K1_NUM		,;
					SK1->K1_PARCELA	,;
					SK1->K1_TIPO	,;
					cFilOrig})
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a data de cobranca mais antiga³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(dAntigo) .OR. dAntigo > SK1->K1_VENCREA
		dAntigo := SK1->K1_VENCREA
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se esses titulosja tem um operador "dono" da conta do titulo           ³
	//³o sistema mantem esse operador como responsavel pelo atendimento atual ³
	//³O operador do titulo mais antigo                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SK1->K1_OPERAD) .AND. Empty(cCodOper)
		cCodOper := SK1->K1_OPERAD
	Endif
	
	DbSelectArea("SK1")
	SK1->(DbSkip())
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se os titulos nao tem um "dono" o Operador logado assume os titulos e usa as regras do seu Grupo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCodOper)
	cCodOper := M->ACF_OPERAD
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³busca as regras do operador "dono" dos titulos no Grupo de atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU7")
DbSetOrder(1)
If DbSeek(xFilial("SU7") + cCodOper)
	
	M->ACF_OPERAD	:= SU7->U7_COD
	M->ACF_DESCOP	:= SU7->U7_NOME

	DbSelectArea("SU0")
	DbSetOrder(1)
	If DbSeek(xFilial("SU0") + SU7->U7_POSTO)
		cRegSel := SU0->U0_REGSEL
		cRegNeg := SU0->U0_REGNEG
		
		DbSelectArea("SK0")
		DbSetOrder(2)
		DbSeek(xFilial("SK0"))
		While !SK0->(Eof()) .AND. SK0->K0_FILIAL == xFilial("SK0")
			dAntigo := dAntigo + Val(SK0->K0_PRAZO)
			If SK0->K0_REGSEL == cRegSel
				Exit
			Endif
			SK0->(DbSkip())
		End
		
		M->ACF_OPERA	:= "1"
		M->ACF_PENDEN	:= dDataBase
		M->ACF_HRPEND	:= Time()
		M->ACF_PRAZO	:= dAntigo
		
		DbSelectArea("SK2")
		DbSetOrder(1)
		If DbSeek(xFilial("SK2") + cRegNeg)
			// Verifica se a selecao sera automatica
			If SK2->K2_SELTIT <> "2"		// 1=Automático;2=Manual
				Tk274Itens(aItens)
			Else
				M->ACF_PRAZO	:= CtoD(Space(08))
			Endif
		Endif
	Endif	
Else
	Aviso(STR0128,STR0129,{"OK"})//"Atençao","O operador não foi localizado para realizar o atendimento",{"OK"})	
	Return(lRet)
Endif  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao for entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTk271Auto
	oGetTlc:oBrowse:Refresh(.T.)
Endif	

#IFDEF TOP
	DbSelectArea("SK1")
	DbCloseArea()
	ChkFile("SK1")
#ENDIF

CursorArrow()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o status da tabela de atendentes IN/OUT para o Monitor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TkGrvSUV(__cUserId,"TLC1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ativa o cronometro da tela 10 - 10 Segundos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTimeIni := Time()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao for entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTk271Auto
	oTimerCro:Activate()
Endif
	
RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274PendenºAutor ³ Vendas Clientes    º Data ³  05/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao da data de reagendamento do atendimento.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Penden(dData,cCodOper)

Local lRet			:= .F.                 	// Retorno da Funcao
Local aArea			:= GetArea()           	// Guarda a area atual
Local cRegNeg   	:= ""					// Codigo da Regra de Negociacao
Default dData		:= M->ACF_PENDEN		// Assume a data do campo M->ACF_PENDEN quando nao for passada como parametro
Default cCodOper	:= ""                  	// Codigo do Operador que ira executar o reagendamento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a funcao foi chamada pelo  Valid do campo ACF_PENDEN, nao foi passado  ³
//³como parametro o codigo do operador, por isso valido o seu preenchimento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCodOper)
	cCodOper:= M->ACF_OPERAD
Endif
	
cRegNeg:= TkPosto(cCodOper,"U0_REGNEG")

DbSelectArea("SK2")
DbSetOrder(1)
If DbSeek(xFilial("SK2") + cRegNeg)
    //Data do reagendamento deve ser superior a database 
	If dData < dDataBase
		lRet := .F.
	ElseIf dData <= dDataBase + SK2->K2_DIAREAG
		lRet := .T.
	Endif
Endif

RestArea(aArea)

If !lRet
	Help(" ",1,"TKNPERMITE")
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274DescFiºAutor ³ Vendas Clientes    º Data ³  08/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do desconto financeiro concedido na cobranca.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274DescFi(	nDescFi	 	, aColsTmp	, nLin	, cOperad	,;
						aHeadTmp	, aRodape	, lAuto )

Local aArea		:= GetArea()							// Armazena dados do alias posicionado
Local lRet		:= .F.   								// Retorno da validacao
Local cRegNeg   := ""								 	// Codigo da Regra de Negociacao
Local nPRecebe	:= 0									// Valor a Receber do Titulo
Local nPJuros	:= 0									// Valor dos Juros
Local nPDescFi	:= 0									// Percentual do Desconto Financeiro
Local nPDescJu	:= 0									// Percentual do Desconto sobre Juros
Local nPPromoc	:= 0									// Promocao
Local nPValRef	:= 0									// Valor de Referencia
Local nPBaixa 	:= 0									// Log de Baixa        
Local nPLidesc	:= 0									// Data limite para descontos
Local nDescNom	:= 0			   						// Valor de desconto sobre o valor nominal
Local nDescJur	:= 0			   						// Valor de desconto sobre o valor de juros
Local nMaxNom 	:= 0									// Valor Maximo de desconto permitido sobre o valor nominal
Local nDescTot	:= 0                                   	// Valor Total do desconto  
Local aColsBk	:= {}									// Armazena o aCols existente   
Local nNBk		:= 0									// Armazena a variavel N existente
Local aRdpTlcBk	:= {}									// Armazena o Rodape anterior se houver
Local nPos		:= 0									// Resultado da pesquisa no vetor aPosicoes

Default nDescFi	:= &(ReadVar())    						// Percentual de desconto concedido
Default cOperad	:= M->ACF_OPERAD						// Operador atual
Default lAuto	:= .F.									// Indica se a rotina foi acionada internamente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a rotina foi acionada pela criacao da tela, utiliza o aCols³
//³e a variavel N recebidas via parametro                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAuto
	If Type('aCols') <> "U"
		aColsBk := aClone(aCols)
	EndIf
	If Type('N') <> "U"
		nNBk := N
	EndIf
	If Type('aRdpTlc') <> "U"
		aRdpTlcBk := aClone(aRdpTlc)
	EndIf
	If aRodape <> Nil
		aRdpTlc := aClone(aRodape)
	EndIf
	aCols 	:= aClone(aColsTmp)
	N		:= nLin
EndIf

If aHeadTmp <> Nil
	nPRecebe	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_RECEBE"	})
	nPJuros		:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_JUROS"	})
	nPDescFi	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_DESCFI"	})
	nPDescJu	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_DESCJU"	})
	nPPromoc	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_PROMOC"	})
	nPValRef	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_VALREF"	})
	nPBaixa 	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_BAIXA"	})
Else
	nPRecebe	:= aPosicoes[11][2]
	nPJuros		:= aPosicoes[12][2]
	nPDescFi	:= aPosicoes[13][2]
	nPPromoc	:= aPosicoes[16][2]
	nPValRef	:= aPosicoes[28][2]
	nPBaixa 	:= aPosicoes[29][2]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recupera posicao do campo ACG_DESCJU³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPos := aScan(aPosicoes,{|x| AllTrim(x[1]) == "ACG_DESCJU" })) > 0 
		nPDescJu := aPosicoes[nPos][2]
	EndIf	
EndIf

cRegNeg   := TkPosto(cOperad,"U0_REGNEG")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Avalia se houve baixa parcial para o titulo. Quando ha uma baixa     ³
//³parcial para o titulo, o valor de desconto  nao podera ser alterado, ³
//³deve ser alterado no momento da baixa do titulo no Financeiro.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Acols[n][nPBaixa] == "2" //Sem Baixa

	DbSelectArea("SK3")
	DbSetOrder(1)
	If DbSeek(xFilial("SK3") + aCols[n][nPPromoc])
		nMaxNom := aCols[n][nPValRef] 	* SK3->K3_DSCNOM / 100	//Valor Maximo de Desconto sobre o valor nominal
	Else
		DbSelectArea("SK2")
		DbSetOrder(1)
		If DbSeek(xFilial("SK2") + cRegNeg)
			nMaxNom := aCols[n][nPValRef] 	* SK2->K2_DSCNOM / 100	//Valor Maximo de Desconto sobre o valor nominal
		Endif
	Endif

	If nMaxNom > 0
		nDescNom:=aCols[n][nPValRef] 	* nDescFi / 100
	Endif
		
	If nPDescJu > 0
		nDescJur := (aCols[n][nPDescJu] * aCols[n][nPJuros]) / 100
	Endif

	If nMaxNom > 0
		If nDescNom <= nMaxNom
			lRet 	:= .T.
			nDescTot:= nDescNom + nDescJur
		Endif
	Endif
	
	If !lRet 
		If !lAuto
			Help(" ",1,"TKNPERMITE")
		EndIf
	Else 
	    //Desconto Financeiro
	    //Tira o desconto que estava no total anteriormente, e atualiza com o novo valor 
	    If !lAuto
			aRdpTlc[06][02] := aRdpTlc[06][2] - IIF(nMaxNom > 0,aCols[n][nPDescFi] * aCols[n][nPValRef] / 100,0)
		EndIf
		aRdpTlc[06][02] := aRdpTlc[06][2] + nDescNom
		
		//Valor a ser Recebido na moeda do titulo
		If !lAuto
			aRdpTlc[11][02] := aRdpTlc[11][2] + IF(nMaxNom > 0,aCols[n][nPDescFi] * aCols[n][nPValRef] / 100,0)
		EndIf
		aRdpTlc[11][02] := aRdpTlc[11][2] - nDescNom
		
		//Valor a ser Recebido na moeda do corrente
		If !lAuto
			aRdpTlc[12][02] := aRdpTlc[12][2] + IF(nMaxNom > 0,aCols[n][nPDescFi] * aCols[n][nPValRef] / 100,0)
		EndIf
		aRdpTlc[12][02] := aRdpTlc[12][2] - nDescNom
		
		If !lAuto
			aRdpTlc[06][01]:Refresh()
			aRdpTlc[11][01]:Refresh()
			aRdpTlc[12][01]:Refresh()
		EndIf
		
		//Se a data limite de desconto estiver em branco utiliza a database
		If !lAuto 
			nPLiDesc := aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_LIDESC"})
			If (nPLiDesc > 0) .AND. (Empty(aCols[N][nPLiDesc]) .OR. aCols[N][nPLiDesc] < dDataBase)
				aCols[N][nPLiDesc] := dDataBase
			EndIf
		EndIf
	Endif
	
Else	// Sem Baixa
	If !lAuto
		Help(" ",1,"TK274DESCF")	
	EndIf
Endif	
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura variaveis existentes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAuto
	If Len(aColsBk) > 0
		aCols := aClone(aColsBk)
	EndIf
	If nNBk <> 0
		N := nNBk
	EndIf
	If aRodape <> NIL
		aRodape := aClone(aRdpTlc)
	EndIf
	If Len(aRdpTlcBk) > 0
		aRdpTlc := aClone(aRdpTlcBk)
	EndIf
EndIf

RestArea(aArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274LiDescºAutor ³ Vendas Clientes    º Data ³  08/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao da data de vencimento do desconto financeiro conceº±±
±±º          ³dido na negociação da cobranca.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274LiDesc()

Local lRet		:= .F.                     	// Retorno da Funcao
Local aArea		:= GetArea()				// Guarda a area atual
Local nPDescFi	:= aPosicoes[13][2]			// Percentual do Desconto Financeiro
Local dLiDesc	:= &(ReadVar())            // Data Limite digitada na GetDados
Local nPPromoc	:= Ascan(aHeader, {|x| x[2] == "ACG_PROMOC"} )	// Codigo da Promocao
Local cRegNeg   := TkPosto(M->ACF_OPERAD,"U0_REGNEG") 	// Codigo da Regra de Negociacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se pode apagar o conteudo da Data Limite³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(dLiDesc) .AND. aCols[n][nPDescFi] == 0
	lRet := .T.
Endif

DbSelectArea("SK3")
DbSetOrder(1)
If DbSeek(xFilial("SK3") + aCols[n][nPPromoc])
	If dLiDesc <= dDataBase + SK3->K3_DIADESC
		lRet := .T.
	Endif
Else
	DbSelectArea("SK2")
	DbSetOrder(1)
	If DbSeek(xFilial("SK2") + cRegNeg)
		If dLiDesc >= dDataBase .AND. dLiDesc <= dDataBase + SK2->K2_DIADESC
			lRet := .T.
		Endif
	Endif
Endif

RestArea(aArea)

If !lRet
	Help(" ",1,"TKNPERMITE")
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274DescJuºAutor ³ Vendas Clientes    º Data ³  02/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do desconto sobre os juros, concedido na cobranca.º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Protheus 10                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274DescJu(	nDescJur	, aColsTmp	, nLin	, cOperad	,;
						aHeadTmp	, aRodape	, lAuto)

Local aArea		:= GetArea()
Local lRet		:= .F.
Local cRegNeg   := ""								 	// Codigo da Regra de Negociacao
Local nPRecebe	:= 0	  								// Valor a Receber do Titulo
Local nPJuros	:= 0									// Valor dos Juros
Local nPDescFi	:= 0									// Percentual do Desconto Financeiro
Local nPDescJu	:= 0		   							// Percentual do Desconto sobre Juros
Local nPPromoc	:= 0				  					// Promocao
Local nPValRef	:= 0									// Valor de Referencia
Local nPBaixa 	:= 0				  					// Log de Baixa        
Local nPLidesc	:= 0									// Data limite para descontos
Local nMaxJur 	:= 0									// Valor Minimo de desconto permitido sobre o valor de juros
Local nDescTot	:= 0                                   	// Valor Total do desconto
Local aColsBk	:= {}									// Armazena o aCols existente   
Local nNBk		:= 0									// Armazena a variavel N existente
Local aRdpTlcBk	:= {}									// Armazena o Rodape anterior se houver
Local nPos		:= 0									// Resultado da pesquisa no vetor aPosicoes
      
Default nDescJur:= &(ReadVar())    						// Percentual de desconto concedido
Default cOperad	:= M->ACF_OPERAD						// Operador atual
Default lAuto	:= .F.									// Indica se a rotina foi acionada internamente
        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a rotina foi acionada pela criacao da tela, utiliza o aCols³
//³e a variavel N recebidas via parametro                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAuto
	If Type('aCols') <> "U"
		aColsBk := aClone(aCols)
	EndIf
	If Type('N') <> "U"
		nNBk := N
	EndIf
	If Type('aRdpTlc') <> "U"
		aRdpTlcBk := aClone(aRdpTlc)
	EndIf
	If aRodape <> Nil
		aRdpTlc := aClone(aRodape)
	EndIf
	aCols 	:= aClone(aColsTmp)
	N		:= nLin
EndIf

If aHeadTmp <> Nil
	nPRecebe	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_RECEBE"	})
	nPJuros		:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_JUROS"	})
	nPDescFi	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_DESCFI"	})
	nPDescJu	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_DESCJU"	})
	nPPromoc	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_PROMOC"	})
	nPValRef	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_VALREF"	})
	nPBaixa 	:= aScan(aHeadTmp,{|x| AllTrim(x[2]) == "ACG_BAIXA"	})
Else
	nPRecebe	:= aPosicoes[11][2]
	nPJuros		:= aPosicoes[12][2]
	nPDescFi	:= aPosicoes[13][2]
	nPPromoc	:= aPosicoes[16][2]
	nPValRef	:= aPosicoes[28][2]
	nPBaixa 	:= aPosicoes[29][2]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recupera posicao do campo ACG_DESCJU³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPos := aScan(aPosicoes,{|x| AllTrim(x[1]) == "ACG_DESCJU" })) > 0 
		nPDescJu := aPosicoes[nPos][2]
	EndIf
EndIf

cRegNeg   := TkPosto(cOperad,"U0_REGNEG")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Avalia se houve baixa parcial para o titulo. Quando ha uma baixa     ³
//³parcial para o titulo, o valor de desconto  nao podera ser alterado, ³
//³deve ser alterado no momento da baixa do titulo no Financeiro.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Acols[n][nPBaixa] == "2" //Sem Baixa

	DbSelectArea("SK3")
	DbSetOrder(1)
	If DbSeek(xFilial("SK3") + aCols[n][nPPromoc])
		nMaxJur := aCols[n][nPJuros] 	* SK3->K3_DSCJUR / 100	//Valor Maximo de Desconto sobre o valor dos juros
	Else
		DbSelectArea("SK2")
		DbSetOrder(1)
		If DbSeek(xFilial("SK2") + cRegNeg)
			nMaxJur := aCols[n][nPJuros] 	* SK2->K2_DSCJUR / 100	//Valor Maximo de Desconto sobre o valor dos juros
		Endif
	Endif
	
	nDescNom := (aCols[n][nPValRef] * aCols[n][nPDescFi]) / 100
		
	If nMaxJur > 0
		nDescJur := (aCols[n][nPJuros] * nDescJur) / 100
	Endif

	If nMaxJur > 0
		If nDescJur <= nMaxJur
			lRet 	:= .T.
			nDescTot:= nDescNom + nDescJur
		Endif
	Endif
	
	If !lRet 
		If !lAuto
			Help(" ",1,"TKNPERMITE")
		EndIf
	Else 
	    //Desconto Financeiro
	    //Tira o desconto que estava no total anteriormente, e atualiza com o novo valor 
	    If !lAuto
			aRdpTlc[06][02] := aRdpTlc[06][2] - IIF(nMaxJur > 0, aCols[n][nPDescJu] * aCols[n][nPJuros] / 100,0)
		EndIf
		aRdpTlc[06][02] := aRdpTlc[06][2] + nDescJur
		
		//Valor a ser Recebido na moeda do titulo
		If !lAuto
			aRdpTlc[11][02] := aRdpTlc[11][2] + IIF(nMaxJur > 0, aCols[n][nPDescJu] * aCols[n][nPJuros] / 100,0)
		EndIf
		aRdpTlc[11][02] := aRdpTlc[11][2] - nDescJur
		
		//Valor a ser Recebido na moeda do corrente
		If !lAuto
			aRdpTlc[12][02] := aRdpTlc[12][2] + IIF(nMaxJur > 0, aCols[n][nPDescJu] * aCols[n][nPJuros] / 100,0)
		EndIf
		aRdpTlc[12][02] := aRdpTlc[12][2] - nDescJur
		
		If !lAuto
			aRdpTlc[06][01]:Refresh()
			aRdpTlc[11][01]:Refresh()
			aRdpTlc[12][01]:Refresh()
		EndIf

		//Se a data limite de desconto estiver em branco utiliza a database
		If !lAuto
			nPLiDesc := aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_LIDESC"})
			If (nPLiDesc > 0) .AND. (Empty(aCols[N][nPLiDesc]) .OR. aCols[N][nPLiDesc] < dDataBase)
				aCols[N][nPLiDesc] := dDataBase
			EndIf
		EndIf

	Endif
	
Else	// Sem Baixa
	If !lAuto
		Help(" ",1,"TK274DESCF")	
	EndIf
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura variaveis existentes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAuto
	If Len(aColsBk) > 0
		aCols := aClone(aColsBk)
	EndIf
	If nNBk <> 0
		N := nNBk
	EndIf
	If aRodape <> NIL
		aRodape := aClone(aRdpTlc)
	EndIf
	If Len(aRdpTlcBk) > 0
		aRdpTlc := aClone(aRdpTlcBk)
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274SelTitºAutor ³ Vendas Clientes    º Data ³  22/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que informa se o Operador pode selecionar os titulos º±±
±±º          ³ou os titulos serao carregados automaticamente.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274SelTit()

Local aArea	:= GetArea()					// Armazena dados do alias posicionado

DbSelectArea("SU7")
DbSetOrder(1)
SU7->(DbSeek(xFilial("SU7") + M->ACF_OPERAD))

DbSelectArea("SU0")
DbSetOrder(1)
SU0->(DbSeek(xFilial("SU0") + SU7->U7_POSTO))

DbSelectArea("SK2")
DbSetOrder(1)
SK2->(DbSeek(xFilial("SK2") + SU0->U0_REGNEG))

RestArea(aArea)

// Verifica se a selecao sera manual
If SK2->K2_SELTIT == "2"		// Selecao manual
	Return(.T.)
Endif

Return(.F.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274StatusºAutor ³ Vendas Clientes    º Data ³  22/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para validar se o valor informado para este campo es-º±±
±±º          ³ta correto.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Status()

Local aArea		:= GetArea()			// Armazena dados do alias posicionado
Local nPTitulo	:= aPosicoes[1][2]		// Numero do Titulo
Local nPPrefix	:= aPosicoes[2][2]		// Prefixo do Titulo
Local nPParcel	:= aPosicoes[3][2]		// Parcela do Titulo
Local nPTipo	:= aPosicoes[4][2]    	// Tipo do Titulo
Local lRet		:= .F.                 	// Retorno da Funcao
Local lPago		:= .F.                	// Controle de Titulo Pago
Local nPFilOrig	:= 0


nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
If nPFilOrig > 0
	cFilOrig:= aCols[n][nPFilOrig]
Else
	cFilOrig:= xFilial("SE1")
Endif
				
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se o titulo esta totalmente baixado. Caso esteja, o      ³
//³status do titulo nao podera ser alterado.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("SE1")
DbSetOrder(1)
If DbSeek(cFilOrig + aCols[n][nPPrefix] + aCols[n][nPTitulo] + aCols[n][nPParcel] + aCols[n][nPTipo])
	If SE1->E1_SALDO == 0
		lPago:=	.T.
	Endif
Endif

Do Case
	Case M->ACG_STATUS == "1" .AND. lPago	// Pago     
		lRet := .T.
	Case M->ACG_STATUS == "2" .AND. !lPago	// Negociado
		lRet := .T.
	Case M->ACG_STATUS == "3" .AND. !lPago	// Cartorio
		lRet := .T.
	Case M->ACG_STATUS == "4"             	// Baixa      
		lRet := .F.
	Case M->ACG_STATUS == "5"             	// Abatimento
		If aCols[n][nPTipo] $ MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM
			lRet := .T.
		Endif
Endcase
	
RestArea(aArea)

Return(lRet)
                                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274ToolsºAutor  ³ Vendas Clientes    º Data ³  25/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para selecao dos Titulos apresentados no browser paraº±±
±±º          ³serem cobrados.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk274Tools(nTipo, oTitulos, lCheck)

Local nI	:= 0		// Variavel de Controle

If nTipo == 1
	If lCheck
		For nI := 1 To Len(oTitulos:aArray)
			oTitulos:aArray[nI][1] := .T.
			oTitulos:Refresh()
		Next nI
	Else
		For nI := 1 To Len(oTitulos:aArray)
			oTitulos:aArray[nI][1] := .F.
			oTitulos:Refresh()
		Next nI
	Endif
Else
	For nI := 1 To Len(oTitulos:aArray)
		If oTitulos:aArray[nI][1]
			oTitulos:aArray[nI][1] := .F.
		Else
			oTitulos:aArray[nI][1] := .T.
		Endif
		oTitulos:Refresh()
	Next nI
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274AcrescºAutor ³ Vendas Clientes    º Data ³  03/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de validacao do campo ACG_ACRESC (Valor Acrescimo)   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELECOBRANCA                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Acresc()

Local nValor	 := &(ReadVar())                       	// Valor do acrescimo ($)digitado pelo usuario na Getdados
Local lRet		 := .F.                                	// Retorno da funcao
Local nPRecebe	 := aPosicoes[11][2]					// Valor a Receber 
Local nPJuros	 := aPosicoes[12][2]					// Total dos Juros aplicado ao titulo
Local nPDescFi	 := aPosicoes[13][2]					// Desconto Financeiro
Local nPDecres	 := aPosicoes[15][2]					// Descrescimo
Local nPValRef	 := aPosicoes[28][2]                    // Valor de Referencia
Local nPBaixa 	 := aPosicoes[29][2]                    // Log de Baixa         
Local nPAcresc	 := aPosicoes[14][2]					// Acrescimo 
Local nPDescJu	 := 0									// Desconto sobre juros
Local cRegNeg    := TkPosto(M->ACF_OPERAD,"U0_REGNEG")  // Codigo da Regra de Negocio
Local nMaxAcre	 := 0 									// Percentual maximo do acrescimo da regra de negocicao
Local nValMaxAcre:= 0 									// Valor maximo permitido para acrescimo
Local nValReceber:= 0                                   // Valor a Receber recalculado
Local nValDesc	 := 0									// Valor do Desconto Financeiro

nPDescJu	 := aPosicoes[32][2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Avalia se houve baixa parcial para o titulo. Quando ha uma baixa     ³
//³parcial para o titulo, o valor de acrescimo nao podera ser alterado, ³
//³deve ser informado no momento da baixa do titulo no Financeiro.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Acols[n][nPBaixa] == "2"  //Sem Baixa

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Avalia se o valor de ACRESCIMO pode ser aplicado de acordo com a regra de negociacao definida ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SK2")
	DbSetOrder(1)
	If DbSeek(xFilial("SK2") + cRegNeg)
		If SK2->K2_ALTTIT == "1"	// SIM - Pode alterar Titulo
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o valor do desconto financeiro³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    nValDesc	:=  (Acols[n][nPValRef] * Acols[n][nPDescFi]) / 100 

	    	If nPDescJu > 0
				nValDesc += (aCols[n][nPDescJu] * aCols[n][nPJuros]) / 100
			Endif
	
			nMaxAcre    := SK2->K2_ACRESC
			nValReceber := Acols[n][nPValRef]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apura o valor maximo permitido para efetuar de acrescimo sobre o valor a receber de acordo com a Regra de Negociacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValMaxAcre := (nValReceber+((nValReceber*nMaxAcre)/100))-nValReceber	

			If nValor > nValMaxAcre
				lRet := .F.
	        Else
	        	lRet := .T. 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o valor informado esta dentro do limite (em %) aplica esse valor no Total a Receber³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        	//Valor a Receber = Valor de Referencia do Titulo + Juros + Acrescimo - Descrescimo - Desconto Financeiro
	        	Acols[n][nPRecebe]:= Acols[n][nPValRef]+ Acols[n][nPJuros]+ nValor - Acols[n][nPDecres] - nValDesc

				//Acrescimo
				aRdpTlc[04][2] := aRdpTlc[04][2] - aCols[n][nPAcresc]
	        	aRdpTlc[04][2] := aRdpTlc[04][2] + nValor

				//Valor a ser Recebido na moeda do titulo
				aRdpTlc[11][02] := aRdpTlc[11][2] - aCols[n][nPAcresc]
				aRdpTlc[11][02] := aRdpTlc[11][2] + nValor
				
				//Valor a ser Recebido na moeda do corrente
				aRdpTlc[12][02] := aRdpTlc[12][2] - aCols[n][nPAcresc]
				aRdpTlc[12][02] := aRdpTlc[12][2] + nValor
				
				//Atualiza objetos
	        	aRdpTlc[04][1]:Refresh() 
				aRdpTlc[11][1]:Refresh()
				aRdpTlc[12][1]:Refresh()

			Endif
		Endif
	Endif

	If !lRet
		Help(" ",1,"TKNPERMITE")
	Endif

Else	// Sem Baixa
	Help(" ",1,"TK274ACRES")	
Endif
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274DecresºAutor ³ Vendas Clientes    º Data ³  03/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de validacao do campo ACG_DECRES                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Decres()

Local nValor	 := &(ReadVar())                  	 	// Valor do decrescimo ($)digitado pelo usuario na Getdados
Local lRet		 := .F.                             	// Retorno da funcao
Local nPRecebe	 := aPosicoes[11][2]					// Valor a Receber 
Local nPJuros	 := aPosicoes[12][2]					// Total dos Juros aplicado ao titulo
Local nPDescFi	 := aPosicoes[13][2]					// Desconto Financeiro
Local nPAcresc	 := aPosicoes[14][2]					// Acrescimo  
Local nPDecres	 := aPosicoes[15][2]					// Decrescimo  
Local nPValRef	 := aPosicoes[28][2]                   // Valor de Referencia
Local nPBaixa    := aPosicoes[29][2]                   // Log de  Baixa       
Local nPDescJu	 := 0									// Desconto sobre juros
Local cRegNeg    := TkPosto(M->ACF_OPERAD,"U0_REGNEG") // Codigo da Regra de Negociacao
Local nMaxDecr	 := 0 									// Percentual maximo do descrescimo na regra de negocicao
Local nValMaxDesc:= 0 									// Valor maximo permitido para desconto
Local nValReceber:= 0                                   // Valor a Receber recalculado
Local nValDesc   := 0									// Valor dos Descontos

nPDescJu	 := aPosicoes[32][2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Avalia se houve baixa parcial para o titulo. Quando ha uma baixa     ³
//³parcial para o titulo, o valor de decrescimo nao podera ser alterado,³
//³deve ser informado no momento da baixa do titulo no Financeiro.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Acols[n][nPBaixa] == "2" //Sem Baixa

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Avalia se o valor de DECRESCIMO pode ser aplicado de acordo com a regra de negociacao definida ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SK2")
	DbSetOrder(1)                                                                
	If DbSeek(xFilial("SK2") + cRegNeg)
		If SK2->K2_ALTTIT == "1"	// SIM - Pode alterar Titulo
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o valor do desconto financeiro³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    nValDesc	:=  (Acols[n][nPValRef] * Acols[n][nPDescFi]) / 100 
		    
	    	If nPDescJu > 0
				nValDesc += (aCols[n][nPDescJu] * aCols[n][nPJuros]) / 100
			Endif
	
			nMaxDecr    := SK2->K2_DECRES
			nValReceber := Acols[n][nPValRef]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apura o valor maximo permitido efetuar de desconto sobre o valor a receber de acordo com a Regra de Negociacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValMaxDesc := (nValReceber+((nValReceber*nMaxDecr)/100))-nValReceber	

			If nValor > nValMaxDesc
				lRet := .F.
	        Else
	        	lRet := .T. 
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o valor informado esta dentro do limite (em %) aplica esse valor no Total a Receber³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        	//Valor a Receber = Valor de referencia do Titulo + Juros + Acrescimo - Descrescimo - Desconto Financeiro
	        	Acols[n][nPRecebe]:= Acols[n][nPValRef]+ Acols[n][nPJuros]+  Acols[n][nPAcresc] - nValor - nValDesc
				
				//Decrescimo
				aRdpTlc[05][2] := aRdpTlc[05][2] - aCols[n][nPDecres]
	        	aRdpTlc[05][2] := aRdpTlc[05][2] + nValor

				//Valor a ser Recebido na moeda do titulo
				aRdpTlc[11][02] := aRdpTlc[11][2] + aCols[n][nPDecres]
				aRdpTlc[11][02] := aRdpTlc[11][2] - nValor
				
				//Valor a ser Recebido na moeda do corrente
				aRdpTlc[12][02] := aRdpTlc[12][2] + aCols[n][nPDecres]
				aRdpTlc[12][02] := aRdpTlc[12][2] - nValor
				
				//Atualiza objetos
	        	aRdpTlc[05][1]:Refresh() 
				aRdpTlc[11][1]:Refresh()
				aRdpTlc[12][1]:Refresh()

			Endif
		Endif
	Endif

	If !lRet
		Help(" ",1,"TKNPERMITE")
	Endif

Else	//Sem Baixa
	Help(" ",1,"TK274DECRE")	
Endif
	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274AtendºAutor  ³ Vendas Clientes    º Data ³  26/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza os dados da tela de atendimento de Telecobranca.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Atend(cEtapa,		aTLC,	aCampACF,	nOpc)

Local aArea		:= GetArea()									// Salva a area anterior
Local nPDtReal	:= Ascan(aHeader, {|x| x[2] == "ACG_DTREAL"} )	// Posicao do campo ACG_DTREAL no aHeader
Local cRegNeg   := ""								 			// Codigo da Regra de Negociacao
Local lSelAuto	:= .T.											// Indica se a Regra de Negociacao esta configurada para selecao automatica de titulos

// Carrega os campos que ficarao habilitados na enchoice
If Len(aTLC) > 0
	
	Do Case
		Case cEtapa == "01"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega os campos necessarios³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			M->ACF_OPERAD	:= SU7->U7_COD
			M->ACF_DESCOP	:= SU7->U7_NOME
			M->ACF_OPERA	:= "2"
			M->ACF_PENDEN	:= dDataBase
			M->ACF_HRPEND	:= Time()                          

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando o preenchimento e feito atraves de uma solicitacao de novo pre-atendimento  ³
			//³o atendimento ainda nao foi gravado, portanto a funcao MSMM nao pode ser executada.³
			//³porque ainda nao existem observacao.                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("ACF")
			DbSetOrder(1)
			If DbSeek(xFilial("ACF") + M->ACF_CODIGO)
				M->ACF_OBS	:= MSMM(ACF->ACF_CODOBS,TamSx3("ACF_OBS")[1])
			Endif
			
			// Se entrou aqui o atendimento sera ATIVO
			Tk274Campos(@aCampACF, .T., nOpc)		// Desabilita os campos se for ATIVO, Pre-atendimento
			
		Case cEtapa == "02"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a regra de negociacao permite que o titulo seja carregado automaticamente³
			//³na tela de atendimento do call center. Esta checagem soh sera feita quando a cobranca³
			//³for feita pela primeira vez para o cliente, ou seja, em uma operacao de inclusao.    ³
			//³Na alteracao carrega sempre o que foi gravado anteriormente, nao checa a regra.      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRegNeg:= TkPosto(M->ACF_OPERAD,"U0_REGNEG")
			If nOpc == 3
				DbSelectArea("SK2")
				DbSetOrder(1)
				If DbSeek(xFilial("SK2") + cRegNeg)
					If SK2->K2_SELTIT == "2"	// 1-Automatico 2-Manual      
						lSelAuto:= .F.
					Endif	
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega os itens da tela de atendimento no caso de ser ATIVO e se a regra de negociacao  ³
			//³estiver configurada para selecao automatica de titulos. Monta os valores do rodape.      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lSelAuto
				Tk274Itens(aTLC)
			Endif	
					
		Case cEtapa == "03"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializa as variaveis do rodape sempre³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLigacao := ""
			cOperador:= ""
			cOperacao:= ""
			cStatus  := ""
			cProximo := ""
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Segundo: Atualiza o rodape da tela com o ultimo atendimento feito para o cliente ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("ACF")
			DbSetOrder(2)
			If DbSeek(xFilial("ACF") + M->ACF_CLIENT + M->ACF_LOJA)
				cLigacao := DTOC(CTOD("01/01/45")-ACF->ACF_DIASDA) + " - " + Substr(ACF->ACF_INICIO,1,5)
				cOperador:= Posicione("SU7",1,xFilial("SU7") + ACF->ACF_OPERAT,"U7_NOME")
			    If Val(ACF->ACF_OPERA) == ATIVO    
				    cOperacao	:= STR0056  
			    ElseIf Val(ACF->ACF_OPERA) == RECEPTIVO
				    cOperacao	:= STR0057  
			    Endif    

				If Val(ACF->ACF_STATUS) == PLANEJADA
					cStatus := STR0121 // "Atendimento" 
				ElseIf Val(ACF->ACF_STATUS) == PENDENTE
					cStatus := STR0122 // "Cobranca"   
				Else
					cStatus := STR0123 // "Encerrado" 
				Endif
			
				DbSelectArea("SU7")
				DbSetOrder(1)
				If DbSeek(xFilial("SU7") + ACF->ACF_OPERAD)
					If !Empty(ACF->ACF_PENDEN)
						cProximo:= DTOC(ACF->ACF_PENDEN) + " - " + ACF->ACF_HRPEND + " - " + cOperador
					Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ativa o cronometro da tela 10 - 10 Segundos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTimeIni := Time()
			oTimerCro:Activate()
			
			oLigacao:Refresh()
			oOperador:Refresh()
			oStatus:Refresh()
			oOperacao:Refresh()
			oProximo:Refresh()
	Endcase
Endif

// Se estiver com o folder de telecobrança ativo.
If Len(aCols) > 0 .AND. nPDtReal > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a data limite para realizar a cobranca e carrega os campos necessarios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Tk274AtuPz(Tk274GtPz(), nPDtReal)
Endif

RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274GtPz ºAutor  ³ Servicos CRM/FAT   º Data ³  07/02/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Prepara variaveis para receber o prazo da cobrança.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274GtPz()
Local nPrazo 		:= 0
Local cFilialSK0	:= ""
DbSelectArea("SU0")
DbSetOrder(1)
If MsSeek(xFilial("SU0") + SU7->U7_POSTO)
	cRegSel	:= SU0->U0_REGSEL
	cFilialSK0	:= xFilial("SK0")
	DbSelectArea("SK0")
	DbSetOrder(2)
	MsSeek(cFilialSK0)
	While !SK0->(Eof()) .AND. SK0->K0_FILIAL == cFilialSK0
		nPrazo += Val(SK0->K0_PRAZO)
		If SK0->K0_REGSEL == cRegSel
			Exit
		EndIf
		SK0->(DbSkip())
	End
EndIf
Return nPrazo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274AtuPz ºAutor ³ Servicos CRM/FAT   º Data ³  07/02/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza prazo de cobranca.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274AtuPz(nPrazo, nPDtReal)
Local dPrazo 		:= CTOD("//")
Local nSizeCol		:= Len(aCols)
Local nI			:= 0
Default nPrazo		:= 0
DEFAULT nPDtReal	:= Ascan(aHeader, {|x| x[2] == "ACG_DTREAL"} )	// Posicao do campo ACG_DTREAL no aHeader
	
If nPDtReal > 0
	For nI := 1 To nSizeCol
		If Empty(dPrazo) .OR. dPrazo > aCols[nI][nPDtReal]
			dPrazo := aCols[nI][nPDtReal]
		Endif
	Next nI
EndIf

If Type("M->ACF_PRAZO") <> "U"
	If !Empty(dPrazo)
		M->ACF_PRAZO := dPrazo + nPrazo	
	Else
		M->ACF_PRAZO := dPrazo
	EndIf
EndIf	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274AtrasoºAutor ³ Vendas Clientes    º Data ³  26/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de calculo dos dias de atraso do titulo que alimenta º±±
±±º          ³o inicializador padrao do campo ACG_ATRASO.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Atraso()

Local nDias := 0		// Dias em atraso

If !Empty(ACG->ACG_DTREAL)
	nDias := dDataBase - ACG->ACG_DTREAL
Endif

Return(nDias)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274EncerraºAutor³ Vendas Clientes    º Data ³  22/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta rotina captura o motivo do encerramento e permite in-  º±±
±±º          ³formar uma observacao em campo memo.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELECOBRANCA                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Encerra(lConsulta,cNumTlc,cEncerra,cMotivo)

Local oEncerra											// Listbox com as opcoes de Encerramento
Local cDesc     := CriaVar("UN_DESC",.F.)				// Descricao da opcao de Encerramento
Local oDlg								   				// Tela do Encerramento
Local oMonoAs	:= TFont():New( "Courier New", 6, 0 )	// Fonte do MEMO
Local oMotivo											// MEMO com o motivo 	
Local lHabil	:= .F.									// Habilita os objetos
Local lRet		:= .F.									// Retorno da funcao
Local cCodEnc 	:= CriaVar("UN_ENCERR",.F.)				// Codigo do encerramento

lHabil := !lConsulta

If !lTk271Auto
	cMotivo := ""
Endif
	
If lConsulta
	DbSelectArea("ACF") 
	DbSetOrder(1)
	If DbSeek(xFilial("ACF") + cNumTlc)
		If !Empty(ACF->ACF_CODENC) .OR. !Empty(ACF->ACF_CODMOT)
			cCodEnc := ACF->ACF_CODENC
			cDesc   := Posicione("SUN",1,xFilial("SUN") + ACF->ACF_CODENC,"UN_DESC")
			cMotivo := MSMM(ACF->ACF_CODMOT,TamSx3("ACF_OBSMOT")[1])
		Else                   
		    If !lTk271Auto
				HELP(" ",1,"NAO ENCERR")
			Endif	
			Return(lRet)
		Endif
	Endif
Endif

If !lTk271Auto
	DEFINE MSDIALOG oDlg FROM 05,10 TO 262,400 TITLE STR0125 PIXEL  STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )	//"Status de Encerramento"
		// Desabilita a tecla ESC
	    oDlg:LESCCLOSE := .F. 
	
		@  2,4 TO 23,190 LABEL STR0119 OF oDlg PIXEL //"Motivo do Encerramento"
	
		@ 10,07 SAY STR0126 SIZE 50,8 OF oDlg PIXEL //"Encerramento"
		@ 09,45 MSGET oEncerra VAR cCodEnc SIZE  40,8  Picture "@!" OF oDlg PIXEL F3 "SUN001" ;
			VALID Tk274ValSUN(cCodEnc,@cDesc) WHEN lHabil
			oEncerra:cSX1Hlp := "UN_ENCERR"			
		
		@ 10,90 SAY cDesc SIZE 100,8 OF oDlg PIXEL
		
		@ 26,4 TO 111,190 LABEL STR0127 OF oDlg PIXEL //"Descrição do Encerramento"
		If lConsulta
			@ 35,8 GET oMotivo VAR cMotivo OF oDlg MEMO SIZE 180,70 PIXEL When lHabil READONLY
		Else
			@ 35,8 GET oMotivo VAR cMotivo OF oDlg MEMO SIZE 180,70 PIXEL When lHabil
		Endif
		oMotivo:oFont := oMonoAs
		
		DEFINE SBUTTON FROM 115,160 TYPE 1 ACTION (lRet:=.T., oDlg:End()) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTER

Else
	If Tk274ValSUN(cEncerra,"")	
		lRet:= .T.
	Endif
Endif

If !lTk271Auto
	cEncerra:= cCodEnc
	oMonoas:End()
Endif	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274ValSUN ºAutor  ³ Vendas Clientes    º Data ³  16/03/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Valida o codigo do encerramento informado de acordo com o   º±±
±±º          ³codigo e o tipo de atendimento:                             º±±
±±º          ³1- Telemarketing, 3 - Telecobranca, 4 - Ambos               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TELECOBRANCA                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk274ValSUN(cCodEnc,cDesc)

Local lRet := .F.       	// Retorno da funcao
Local aArea:= GetArea()		// Salva a area atual

cDesc := ""
DbSelectArea("SUN")
DbSetOrder(1)                                                       	
If DbSeek(xFilial("SUN")+cCodEnc)
	If (SUN->UN_TIPOATE $ "3;4; ")		// Telecobranca e Ambos
		cDesc 	:= SUN->UN_DESC
		lRet 	:= .T.
	Else
	 	If !lTk271Auto
			Help(" ",1,"TMK274ENCE" ) //"Esse código de encerramento nao é usado para a rotina de TeleCobranca"
		Endif	
		lRet 	:= .F.
	Endif		
Else
 	If !lTk271Auto
		Help(" ",1,"TMK274ENCE" ) //"Esse código de encerramento nao é usado para a rotina de TeleCobranca"
	Endif	
	lRet := .F.	
Endif

RestArea(aArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK274DelSU4ºAutor ³ Vendas Clientes    º Data ³  01/22/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Encerra as listas de pendencias se existir alguma           º±±
±±º          ³SOMENTE PARA ESSE ATENDIMENTO ENCERRADO                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Telecobranca                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TK274DelSU4(cCodLig)

Local aArea := GetArea()		//Salva a area atual

DbSelectArea("SU4")
DbSetOrder(4)		// U4_FILIAL+U4_CODLIG
If DbSeek(xFilial("SU4")+cCodLig)
	RecLock("SU4",.F.)	
	SU4->U4_STATUS := "2"			// Lista Encerrada
	SU4->U4_ROTINA := "TK274DELSU4"
	
	MsUnlock()
	DbCommit()
	
	DbSelectArea("SU6")
	DbSetOrder(1)
	If DbSeek(xFilial("SU6")+SU4->U4_LISTA)
		RecLock("SU6",.F.)
		SU6->U6_STATUS := "3"		// Item da Lista enviado (executado)
		SU6->U6_ROTINA := "TK274DELSU4"
	
		MsUnlock()
		DbCommit()
	Endif
Endif

RestArea(aArea)

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274SimulºAutor  ³ Vendas Clientes    º Data ³  05/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela para simular o valor corrigido do titulo com base em   º±±
±±º          ³uma data de pagamento.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cCliente	- Codigo do cliente                               º±±
±±º          ³cLoja   	- Loja do Cliente                                 º±±
±±º          ³cCodOperr	- Codigo do OPerador.                             º±±
±±º          ³dPrazoCobr- Data com o Prazo de Cobranca                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - COBRANCA	                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274Simul(cCliente,cLoja,cCodOper,dPrazoCobr)

Local lRet		:= .T.								// Retorno da funcao
Local aButtons	:= {}                              	// Botoes da Enchoicebar
Local aHeadACG	:= {}								// aHeader do ACG
Local aColsACG	:= {}   							// aCols do ACG    
Local aRdpCgd	:= aClone(aRdpTLC)					// Valores Corrigidos do Rodape
Local nUsado	:= 0                               	// Numero de campos existentes no aHeader
Local nCont		:= 0								// Contador
Local nI		:= 0								// Contador
Local dDataPagto:= dDatabase						// Data de Pagamento onde sera baseado o calculo do valor corrigido
Local lAtuAtend	:= .F.								// Atualiza o atendimento com os dados alterados
Local lAltTit	:= .F.				                // Flag para indicar se pode alterar o titulo
Local nDiasPrg	:= 0                              	// Numero maximo de dias para prorrogacao do titulo
Local cRegNeg	:= ""								// Regra de negociacao do Operador 
Local cNome		:= ""								// Nome do Cliente
Local lSelectAll:= .T.								// Marca/Desmarca todos
Local aFieldsPD := {"A1_NOME","A1_CGC"}

//Objetos
Local oDlgSimul                        				// Tela
Local oGetACG										// NewGetDados do ACG
Local oDataPagto									// Data de Pagamento
Local oAtuAtend                                  	// Atualizacao  do atendimento
Local oFontRdp										// Fonte utilizada no rodape
Local oFontLeg										// Fonte utilizada no rodape
Local oFontTex										// Fonte utilizada no rodape
Local oCheck										// TCheckBox - Marca e desmarca todos

DEFAULT cCliente	:= M->ACF_CLIENTE      			// Codigo do Cliente
DEFAULT cLoja		:= M->ACF_LOJA	           		// Loja do Cliente
DEFAULT cCodOper 	:= M->ACF_OPERAD				// Codigo do operador para coberanca. 
DEFAULT dPrazoCobr	:= M->ACF_PRAZO					// Prazo para Cobranca que o operador possui para cobrar os titulos

DEFINE FONT oFontRdp NAME "Arial" SIZE 12,14 BOLD	// Rodape
DEFINE FONT oFontLeg NAME "Arial" SIZE 00,14 BOLD   // Textos
DEFINE FONT oFontTex NAME "Arial" SIZE 00,14        // Legendas (Titulos)

FATPDLoad(Nil, Nil, aFieldsPD )

If Empty(cCliente).AND. Empty(cLoja)
	MsgStop(STR0154)//"Nenhum cliente foi informado para execução da rotina."
	lRet:= .F.
	Return(lRet)
Endif		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o aHeader do ACG	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("ACG") 
Aadd(aHeadACG,{"","ACG_CHKBOL","@BMP",20,00,,,"C",,"V" } )
nUsado++

While	!SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "ACG"
		
	If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL  
		Aadd(aHeadACG,{  	Trim(X3Titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT } )
		nUsado++
	Endif
	DbSelectArea("SX3")
	SX3->(DbSkip())
End      
ADHeadRec("ACG", aHeadACG)
nUsado+=2


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o ACOLS(ACG) baseado nos Itens carregados no Atendimento (ACOLS - PRIVATE)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCont:= 1 to Len(aCols)
	Aadd(aColsACG,Array(nUsado+1))
	
	For nI := 1 TO nUsado
	    If nI == 1
    		aColsACG[nCont][nI] := "LBOK"
	    Else	
			aColsACG[nCont][nI] := aCols[nCont][nI-1]
		Endif               
		
	Next nI 
	
	aColsACG[nCont][nUsado+1] := .F.
Next nCont
	  
If Len(aColsACG) == 0
	MsgStop(STR0131)//"Não existem titulos para cobrança. Essa operação nãa poderá ser realizada!" 
	lRet:= .F.
	Return(lRet)
Endif


cNome	:= Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NOME")
cCGC	:= Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_CGC")  
cRegNeg	:= TkPosto(cCodOper,"U0_REGNEG")
nDiasPrg:= Posicione("SK2",1,xFilial("SK2")+cRegNeg,"K2_DIAPROR")

cCGC := IIf(FATPDIsObfuscate("A1_CGC"), FATPDObfuscate(cCGC), Transform(cCGC, PesqPict("SA1", "A1_CGC")))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Avalia a regra de negociacao do operador³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SK2") 
DbSetOrder(1)
If DbSeek(xFilial("SK2")+cRegNeg) 
	If K2_ALTTIT == "1" //Altera titulo
    	lAltTit:= .T.
    Endif
Endif
    	
DEFINE MSDIALOG oDlgSimul FROM  0,0 TO 450,700 TITLE STR0132  PIXEL  //"Simulação de Valores"

	AAdd(aButtons,{ "SIMULACAO" , {|| Tk271SituaC()},STR0133 })//"Situação Financeira"     
	
	@ 30,05  TO 75,130 LABEL STR0134 OF oDlgSimul  PIXEL	//"Informações de Cobrança"
   	@ 30,135 TO 75,345 LABEL STR0135 OF oDlgSimul  PIXEL	//"Dados do Cliente"

	@ 40,10  SAY STR0136 FONT oFontLeg COLOR CLR_BLUE SIZE 80,8 OF oDlgSimul PIXEL	//"Prazo de Cobranca "
	@ 40,80  SAY dPrazoCobr SIZE 50,8 Picture "99/99/99" FONT oFontLeg COLOR CLR_HBLUE  OF oDlgSimul PIXEL
	
	@ 50,10  SAY STR0137 FONT oFontLeg COLOR CLR_BLUE SIZE 80,8 OF oDlgSimul PIXEL//"Dias para Prorrogação"
	@ 50,80  SAY nDiasPrg SIZE 40,8 Picture "@!" FONT oFontLeg COLOR CLR_HBLUE  OF oDlgSimul PIXEL

	@ 60,10 SAY STR0138 FONT oFontLeg COLOR CLR_BLUE SIZE 80,8 OF oDlgSimul PIXEL	//"Data de Pagamento"
	@ 60,80 MSGET oDataPagto VAR dDataPagto SIZE 45,8 Picture "99/99/99" FONT oFontTex COLOR CLR_BLUE OF oDlgSimul PIXEL ;
		  	VALID Tk274VlrCgd (	aHeadACG, @aColsACG, dDataPagto, oGetACG,;
		  						@aRdpCgd)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados do cliente³                         
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 40,140 SAY STR0139 FONT oFontLeg COLOR CLR_BLUE SIZE 40,08 OF oDlgSimul PIXEL//"Código/Loja"
	@ 40,180 SAY AllTrim(cCliente) + ' - ' + AllTrim(cLoja) FONT oFontTex COLOR CLR_BLUE PICTURE "!@" SIZE 170,08 OF oDlgSimul PIXEL
	
	@ 50,140 SAY STR0140 FONT oFontLeg COLOR CLR_BLUE SIZE 40,08 OF oDlgSimul PIXEL //"Nome"
	@ 50,180 SAY FATPDObfuscate(cNome,"A1_NOME")FONT oFontTex COLOR CLR_BLUE PICTURE PesqPict("SA1", "A1_NOME") SIZE 170,08 OF oDlgSimul PIXEL

	@ 60,140 SAY STR0141 FONT oFontLeg COLOR CLR_BLUE SIZE 40,08 OF oDlgSimul PIXEL//"CNPJ/CPF"
	@ 60,180 SAY cCGC FONT oFontTex COLOR CLR_BLUE  SIZE 100,08 OF oDlgSimul PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Titulos para Simular ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 75,05 To 150,345 LABEL STR0142 Of oDlgSimul PIXEL//"Títulos"	

	//GetDados
	oGetACG := MsNewGetDados():New(83,10,145,340,0,,,,,,4096,,,,oDlgSimul,aHeadACG,aColsACG)
	oGetACG:oBrowse:bLDblClick := { || Tk274MarkTit	(@oGetACG,oGetACG:nAt,@aColsACG),;
										Tk274VlrCgd	(aHeadACG, @aColsACG, dDataPagto, oGetACG,;
													 @aRdpCgd),;
										oGetACG:Refresh()}
	oGetACG:SetEditLine(.F.)
	
		oCheck := TCheckBox():New(  155, 10, STR0171,;
								{|x| IIf(ValType(x)=='U',lSelectAll,lSelectAll:=x) }, oDlgSimul, 119, 20, NIL,;
								{|| Tk274MarkAll(@oGetACG,@aColsACG,@lSelectAll),;
									Tk274VlrCgd	(aHeadACG, @aColsACG, dDataPagto, oGetACG, @aRdpCgd),;
									oGetACG:Refresh(),oCheck:Refresh() },,,CLR_HBLUE,,,.T.) //"Marca/Desmarca todos os títulos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rodape com totais acumulados   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 165,05 To 220,345 LABEL STR0143 Of oDlgSimul PIXEL //"Valores Corrigidos"	

	@ 175,10 SAY STR0144 FONT oFontLeg COLOR CLR_BLUE OF oDlgSimul PIXEL //"Valor Original"
	@ 175,60 SAY aRdpCgd[7][1]  PROMPT aRdpCgd[7][2] Picture "@E 999,999,999.99" FONT oFontRdp COLOR CLR_HBLUE OF oDlgSimul PIXEL 
                                     
	@ 185,10 SAY STR0145 FONT oFontLeg  COLOR CLR_BLUE OF oDlgSimul PIXEL //"Valor Corrigido"
	@ 185,60 SAY aRdpCgd[11][1] PROMPT aRdpCgd[11][2] Picture "@E 999,999,999.99" FONT oFontRdp COLOR CLR_HBLUE OF oDlgSimul PIXEL

	@ 195,10 SAY STR0146 FONT oFontLeg COLOR CLR_BLUE OF oDlgSimul PIXEL //"Juros"
	@ 195,60 SAY aRdpCgd[3][1]	 PROMPT aRdpCgd[3][2] Picture "@E 999,999,999.99" FONT oFontRdp COLOR CLR_HBLUE OF oDlgSimul PIXEL
	
	@ 175,220 SAY STR0147 FONT oFontLeg COLOR CLR_BLUE OF oDlgSimul PIXEL //"Acréscimos"
	@ 175,260 SAY aRdpCgd[4][1] PROMPT aRdpCgd[4][2] Picture "@E 999,999,999.99" FONT oFontRdp COLOR CLR_HBLUE OF oDlgSimul PIXEL
	
	@ 185,220 SAY STR0148 FONT oFontLeg COLOR CLR_BLUE OF oDlgSimul PIXEL //"Decréscimos"
	@ 185,260 SAY aRdpCgd[5][1] PROMPT aRdpCgd[5][2] Picture "@E 999,999,999.99" FONT oFontRdp COLOR CLR_HBLUE OF oDlgSimul PIXEL
	
	@ 195,220 SAY STR0149 FONT oFontLeg COLOR CLR_BLUE OF oDlgSimul PIXEL //"Descontos"
	@ 195,260 SAY aRdpCgd[6][1] PROMPT aRdpCgd[6][2] Picture "@E 999,999,999.99" FONT oFontRdp COLOR CLR_HBLUE OF oDlgSimul PIXEL
	
	@ 205,20  SAY STR0150 FONT oFontLeg COLOR CLR_HBLUE SIZE 80,8 OF oDlgSimul PIXEL  //"Atualiza o Atendimento"
	@ 205,10  CHECKBOX oAtuAtend VAR lAtuAtend SIZE 8,8 PIXEL OF oDlgSimul When (lAltTit .AND. nDiasPrg > 0)		 

ACTIVATE MSDIALOG oDlgSimul CENTERED ON INIT EnchoiceBar(oDlgSimul, {|| (Tk274AtuACG(aColsACG,lAtuAtend,dDataPagto,nDiasPrg,oDlgSimul)) }, {|| oDlgSimul:End() },,aButtons )             
FATPDLogUser("TK274SIMUL")
FATPDUnload()

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274AtuACGºAutor  ³ Vendas Clientes   º Data ³  05/13/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o atendimento de cobranca. Atualiza apenas os cam- º±±
±±º          ³pos de data de vencimento para prorrogacao do titulo.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA	                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/							
Static Function Tk274AtuACG(aColsACG,lAtuAtend,dDataPagto,nDiasPrg,oDlgSimul)

Local lRet		:= .F.											//Retorno da funcao
Local nI		:= 0											//Indice de posicionamento do aCols
Local nPDtVenc	:= Ascan(aHeader, {|x| x[2] == "ACG_DTVENC"} ) //Data de Vencimento       		
Local nPDtReal	:= Ascan(aHeader, {|x| x[2] == "ACG_DTREAL"} )	//Data de Vencimento Real				
Local nPAtraso	:= Ascan(aHeader, {|x| x[2] == "ACG_ATRASO"} )	//Data de Vencimento Real				

If lAtuAtend .AND. nDiasPrg > 0
	If dDataPagto >= dDataBase + nDiasPrg
		MsgStop(STR0151)//"O numero máximo de dias para prorrogação do titulo foi ultrapassado. A alteração não poderá ser realizada."
		Return(lRet)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizacao apenas data de vencimento do titulo.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TmkOk(STR0152)//"Deseja prorrogar todos os títulos selecionados para a data de pagamento informada?"	
            For nI:= 1 to Len(aColsACG)
            	If aColsACG[nI][1] == "LBOK"
					aCols[nI][nPDtVenc]	:= dDataPagto						//Data de Vencimento 
					aCols[nI][nPDtReal]	:= DataValida(dDataPagto)			//Data de Vencimento Real
					aCols[nI][nPAtraso]	:= dDataPagto - aCols[nI][nPDtReal]//Dias em atraso
					Tk274DtVenc(cOperador,nI,aCols[nI][nPDtReal])			//Recalcula juros
				Endif	
			Next nI
	    Endif
	    
	Endif	
Endif                                                                  

oDlgSimul:End()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274VlrCgd ºAutor  ³ Vendas Clientes   º Data ³  05/11/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula para todos os titulos o valor corrigido com base    º±±
±±º          ³na data de pagamento informada.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk274VlrCgd(aHeadACG, aColsACG, dDataPagto, oGetACG,;
							aRdpCgd)
            
Local lRet		:= .T.            											// Retorno da funcao
Local nI		:= 0                										// Contador
Local nJ		:= 0                						   				// Contador
Local nPFilOrig := 0                 										// Posicao do campo Filial de Origem no ACG
Local cFilOrig	:= ""                 										// Filial de Origem do Titulo
Local aValores	:= {}														// Retorno da funcao FaVlAtuCr() com os valores do titulo
Local nPTitulo	:= Ascan(aHeadACG, {|x| x[2] == "ACG_TITULO"} )			// Numero do Titulo
Local nPPrefix	:= Ascan(aHeadACG, {|x| x[2] == "ACG_PREFIX"} )			// Prefixo do Titulo
Local nPParcel	:= Ascan(aHeadACG, {|x| x[2] == "ACG_PARCEL"} )			// Parcela do Titulo
Local nPTipo	:= Ascan(aHeadACG, {|x| x[2] == "ACG_TIPO  "} )			// Tipo do Titulo
Local nPRecebe	:= Ascan(aHeadACG, {|x| x[2] == "ACG_RECEBE"} )			// Valor a Receber do Titulo
Local nPJuros	:= Ascan(aHeadACG, {|x| x[2] == "ACG_JUROS "} )			// Valor de Juros do Titulo
Local nPValRef	:= Ascan(aHeadACG, {|x| x[2] == "ACG_VALREF"} )			// Valor de Referencia
Local nPBaixa   := Ascan(aHeadACG, {|x| x[2] == "ACG_BAIXA "} )			// Log de Baixa        
Local nPStatus  := Ascan(aHeadACG, {|x| x[2] == "ACG_STATUS"} )			// Status do Atendimento
Local nPDescFi  := Ascan(aHeadACG, {|x| x[2] == "ACG_DESCFI"} )			// Desconto financeiro
Local nPDescJu  := Ascan(aHeadACG, {|x| x[2] == "ACG_DESCJU"} )			// Desconto sobre os juros
Local nPAcresc  := Ascan(aHeadACG, {|x| x[2] == "ACG_ACRESC"} )			// Acrescimo financeiro     
Local nPDecres  := Ascan(aHeadACG, {|x| x[2] == "ACG_DECRES"} )			// Decrescuni financeiro    
Local nDescFi	:= 0														// Armazena o desconto financeiro
Local nDescJu	:= 0														// Armazena o desconto sobre os juros
Local nAcresc	:= 0														// Armazena o acrescimo financeiro
Local nDecres	:= 0														// Armazena o decrescimo financeiro
Local dVencR	:= CtoD("")													// Armazena a data para pagamento(real)
Local dVenc		:= CtoD("")													// Armazena a data para pagamento
Local nPMulta	:= 0														// Posicao do campo ACG_MULTA que armazena o valor de multa nos itens do atendimento de telecobranca  (somente para integracao com sigaloja)
Local cTmkJuros	:= GetNewPar("MV_TMKAJUR","1")								// Define se o calculo de juros sera baseado nos campos do financeiro ou nos parametros do sigaloja.  1-Financeiro, 2- Sigaloja
Local lTK274SV  := ExistBlock("TK274SV")									// Ponto de entrada utilizado para manipulação dos arrays aColsACG aRdpCgd
Local aTK274SV  := {}


nPMulta		:= Ascan(aHeadACG, {|x| x[2] == "ACG_MULTA "} )

If dDataPagto < dDatabase
	MsgStop(STR0153)//"A data para cálculo deve ser maior que a database"
	Return(.F.)
Endif
	
nPFilOrig	:= Ascan(aHeadACG, {|x| x[2] == "ACG_FILORI"} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera o array com os valores de Rodape ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aRdpCgd)
	aRdpCgd[nI][2] := 0
Next nI

For nI:= 1 to Len(aColsACG)

	IF aColsACG[nI][1] == "LBNO"
		Loop
	Endif	
	
	If nPfilOrig > 0
		cFilOrig:= aColsACG[nI][nPFilOrig]	//Filial de origem do titulo
	Else
		cFilOrig:= xFilial("SE1")
	Endif  
			
	DbSelectArea("SE1")
	DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Numero + Parcela + Tipo
	If DbSeek(cFilOrig + M->ACF_CLIENT + M->ACF_LOJA + aColsACG[nI][nPPrefix] + aColsACG[nI][nPTitulo] + aColsACG[nI][nPParcel] + aColsACG[nI][nPTipo])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena os dados de desconto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDescFi	:= aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_DESCFI"})]
		dLiDesc	:= aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_LIDESC"})]  
		nAcresc := aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_ACRESC"})]  
		nDecres	:= aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_DECRES"})] 
		dVenc	:= aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_DTVENC"})] 
		dVencR	:= aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_DTREAL"})] 
		nDescJu	:= aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_DESCJU"})]


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o campos do acols e executa os gatilhos.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Posicione("SX3",2,"ACG_TITULO","")
		RunTrigger(2,nI)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reaplica os dados de desconto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_DESCFI"})] := nDescFi
		aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_LIDESC"})]	:= dLiDesc
		aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_ACRESC"})]	:= nAcresc
		aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_DECRES"})] 	:= nDecres
		aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_DTVENC"})]	:= dVenc
		aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_DTREAL"})] := dVencR
        aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == "ACG_DESCJU"})]	:= nDescJu  		

		//Data de Pagamento para simulacao do valor corrigido
		aValores := FaVlAtuCr(	NIL		, dDataPagto	, NIL	, NIL	,;
								cFilOrig, .T.			)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o calculo dos juros do titulo for baseado nos parametros MV_LJJUROS e MV_LJMULT ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTmkJuros == "2"		// SIGALOJA
			Tk274CalcJuros(	@aValores  		, @aColsACG		, aHeadACG	, nI,;
							M->ACF_CLIENT	, M->ACF_LOJA	, dDataPagto)
		Else	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o Valor de Referencia, Receber, Juros, Baixa e Status na Inclusao        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aColsACG[nI][nPValRef]	:= aValores[6]	//Saldo do Titulo 
			aColsACG[nI][nPJuros]	:= aValores[8] 	//Valor dos Juros
			aColsACG[nI][nPRecebe]	:= aValores[12]	//Valor a Receber
		Endif
			
        Do Case 
        	Case !Empty(SE1->E1_BAIXA) // Se houve uma baixa verifica se foi TOTAL ou PARCIAL
        		 If (SE1->E1_SALDO > 0)
					aColsACG[nI][nPBaixa] := "1" //Baixa Parcial
					aColsACG[nI][nPStatus]:= "4" //Baixa
				 Endif
				 
				 If (SE1->E1_SALDO == 0)
					aColsACG[nI][nPBaixa] := "3" //Baixa Total
					aColsACG[nI][nPStatus]:= "1" //Pago
				 Endif	

	        Case Empty(SE1->E1_BAIXA) // Nao houve nenhuma baixa 
				aColsACG[nI][nPBaixa] := "2" //Sem Baixa            	

	  	EndCase	  	         
		
		aRdpCgd[1][2]	:= aRdpCgd[1][2] + aValores[2]
		aRdpCgd[2][2]	:= aRdpCgd[2][2] + aValores[10]
		aRdpCgd[3][2]	:= aRdpCgd[3][2] + aValores[8]
		aRdpCgd[4][2]	:= aRdpCgd[4][2] + aColsACG[nI][nPAcresc]
		aRdpCgd[5][2]	:= aRdpCgd[5][2] + aColsACG[nI][nPDecres]
		aRdpCgd[6][2]	:= aRdpCgd[6][2]
		aRdpCgd[7][2]	:= aRdpCgd[7][2] + aValores[1]
		aRdpCgd[8][2]	:= aRdpCgd[8][2] + aValores[6]
		aRdpCgd[9][2]	:= aRdpCgd[9][2] + aValores[7]
		aRdpCgd[10][2]	:= aRdpCgd[10][2]+ aValores[3]
		aRdpCgd[11][2]	:= aRdpCgd[11][2]+ aValores[11] + aValores[9] - aColsACG[nI][nPDecres]
		aRdpCgd[12][2]	:= aRdpCgd[12][2]+ aValores[12] + aValores[9]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula a simulacao dos descontos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
		Tk274DescFi(	aColsACG[nI][nPDescFi]	, @aColsACG	, nI   		, M->ACF_OPERAD	,;
						aHeadACG 				, @aRdpCgd	, .T.)
							
		If (nPDescJu <> 0) 
            Tk274DescJu(aColsACG[nI][nPDescJu]	, @aColsACG	, nI		, M->ACF_OPERAD	,;
            			aHeadACG				, @aRdpCgd	, .T.)
        EndIf	
		
	Endif
Next nI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o ponto de entrada lTK274SV chamado para ³////  
//³³manipulação do arrays aColsACG e aRdpCgd        ³////      
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTK274SV
	aTK274SV:= ExecBlock("TK274SV",.F.,.F.,{aColsACG,aRdpCgd,dDataPagto})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida o retorno do ponto de entrada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(aTK274SV) == "A"
	    aColsACG:= aClone(aTK274SV[1])
		aRdpCgd := aClone(aTK274SV[2])
	Endif
EndIf
For nJ:=1 to 12
	aRdpCgd[nJ][1]:Refresh()
Next nJ

oGetACG:aCols := aClone(aColsACG)
oGetACG:oBrowse:Refresh()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274MarkTitºAutor  ³ Vendas Clientes  º Data ³  05/13/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca e desmarca o item da GetDados.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk274MarkTit(oGetACG,nAt,aColsACG)

IF oGetACG:aCols[nAt][1] == "LBOK"
	oGetACG:aCols[nAt][1]:= "LBNO"
Else
	oGetACG:aCols[nAt][1]:= "LBOK"
Endif

aColsACG:=aClone(oGetACG:aCols)
oGetACG:oBrowse:Refresh()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274MarkAllºAutor  ³ Vendas Clientes  º Data ³  08/01/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Marca e desmarca todos os itens da GetDados.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CALL CENTER - TELECOBRANCA                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk274MarkAll(oGetACG,aColsACG,lSelectAll)

Local nX := 0

For nX := 1 To Len(oGetACG:aCols)
	If lSelectAll
		oGetACG:aCols[nX][1]:= "LBOK"	
	Else
		oGetACG:aCols[nX][1]:= "LBNO"
	EndIf
Next nX

aColsACG:=aClone(oGetACG:aCols)
oGetACG:oBrowse:Refresh()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TK274LimpaRdp ºAutor  ³ Vendas Clientesº Data ³  09/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Limpa o rodape do folder de Telecobranca                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274LimpaRdp()

// Limpa os dados do rodape
If aRdpTlc <> NIL
	aEval( aRdpTlc, { |x| x[2] := 0 } )	
Endif

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk274GetOk  ³ Autor ³ Vendas Clientes     ³ Data ³ 17/09/04 ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Valida‡„o Geral da GetDados de Telecobranca                 ³±±
±±³          ³Utilizada apenas em rotina automatica.                      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Uso  	 ³TeleCobranca  								              ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tk274GetOK()

Local nLinha 	:= 1						// Contador das linhas do ACOLS
Local lRet 	 	:= .T.				   		// Retorno da funcao
Local nDel		:= 0                    	// Controle de linhas deletadas
Local cFilorig	:= ""						// Filial de origem do titulo
Local nPFilorig	:= 0						// Posicao do campo Filial de origem do titulo
Local nPTitulo	:= aPosicoes[1][2]			// Posicao do Numero do Titulo
Local nPPrefix	:= aPosicoes[2][2]			// Posicao do Prefixo			
Local nPParcel	:= aPosicoes[3][2]			// Posicao da Parcela
Local nPTipo	:= aPosicoes[4][2]			// Posicao do Tipo

For nLinha := 1 To Len(aCols)
	If !aCols[nLinha][Len(aHeader)+1] //Se a linha nao estiver deletada
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o usu rio nao informou o Titulo nao faz a grava‡ao foi uma liga‡ao sem finalidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
		If nPFilOrig > 0
		   cFilOrig:= aCols[nLinha][nPFilOrig]
		Else
			cFilOrig	:= xFilial("SE1")
		Endif		
		
		DbSelectArea("SE1")
		DbSetOrder(1)
		If !DbSeek(cFilOrig + aCols[nLinha][nPPrefix] + aCols[nLinha][nPTitulo] + aCols[nLinha][NPParcel] + aCols[nLinha][NPTipo])
			If !lTk271Auto
				Help(" ",1,"TK274PESQF")
			Endif
			lRet := .F.
		Endif
		
		If Empty( aCols[nLinha][nPTitulo] )
			If !lTk271Auto
				Help("",1,"FALTA_TIT")
			Endif	
			lRet := .F.
		Endif
	Else
		nDel++
	Endif

Next nLinha

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se todas as linhas do acols estiverem deletadas, nao permite confirmacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(Acols) == nDel
	If !lTk271Auto
		Help("",1,"FALTA_TIT")
	Endif
	lRet:= .F.
Endif
	
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274CalcJuros ºAutor  ³ Vendas Clientes  º Data ³ 20/12/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³1) Funcao componentizada para calcular os juros dos titulos º±±
±±º          ³negociados na telecobranca com base nos parametros do       º±±
±±º          ³sigaloja que sao MV_LJJUROS e MV_LJMULT.                    º±±
±±º          ³2) Chamar essa funcao somente quando o titulo estiver posi- º±±
±±º          ³cionado na tabela SE1.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CALL CENTER - TELECOBRANCA                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aEXP1 - Todos os valores do titulo posicionado              º±±
±±º          ³aEXP2 - aCols que tem os dados do titulo                    º±±
±±º          ³aEXP3 - aHeader com os campos                               º±±
±±º          ³cEXP4 - Linha do Acols que sera atualizada com os valores   º±±
±±º          ³cEXP5 - Codigo do cliente                                   º±±
±±º          ³cEXP6 - Codigo da loja                                      º±±
±±º          ³dEXP7 - Data para o calculo de juros                        º±±
±±º          ³dEXP8 - Codigo do operador logado                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tk274CalcJuros(aValoresSE1	, aColsTlc	, aHeaderTLC, nLinha, ;
						cCliente	, cLoja		, dDataCalc	, cCodOper)

Local lRet		:= .T.																	// Retorno da funcao LJRECLOAD
Local aRet		:= {}																	// Array de retorno da funcao de leitura dos titulso				
Local nPJuros	:= Ascan(aHeaderTLC, {|x| x[2] == "ACG_JUROS "} )						// Posicao do campo Juros
Local nPRecebe	:= Ascan(aHeaderTLC, {|x| x[2] == "ACG_RECEBE"} )						// Posicao do campo Valor a Receber
Local nPValRef	:= Ascan(aHeaderTLC, {|x| x[2] == "ACG_VALREF"} )						// Posicao do campo Valor de Referencia do titulo
Local nPMulta	:= 0            														// Posicao do campo ACG_MULTA
Local cRegNeg	:= ""																 	// Regra de Negociacao configurada para o operador
Local nDescNom  := ""																	// Percentual de desconto maximo sobre o valor nominal do titulo
Local nDescJur	:= ""																	// Percentual de desconto maximo sobre o valor de juros do titulo
Local cTmkJuros	:= GetNewPar("MV_TMKAJUR","1") 											// Define se o calculo de juros sera baseado nos campos do financeiro ou nos parametros do sigaloja.  1-Financeiro, 2- Sigaloja

DEFAULT aValoresSE1	:= {}																// Array com os valores do titulo corrente
DEFAULT nLinha		:= Len(aColsTlc)													// Linha do Acols que deve ser atualizada com os valores calculados
DEFAULT cCliente	:= M->ACF_CLIENT													// Codigo do cliente
DEFAULT cLoja		:= M->ACF_LOJA														// Codigo da loja
DEFAULT dDataCalc	:= dDatabase                                         				// Data que sera utilizada para calculo dos juros
DEFAULT cCodOper	:= M->ACF_OPERAD													// Codigo do operador


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual eh a regra de negociacao do operador logado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRegNeg		:= TkPosto(cCodOper,"U0_REGNEG")
nDescNom  	:= Posicione("SK2",1,xFilial("SK2")+cRegNeg,"K2_DSCNOM")				
nDescJur	:= Posicione("SK2",1,xFilial("SK2")+cRegNeg,"K2_DSCJUR") 				

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o campo ACG_MULTA foi criado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPMulta	:= Ascan(aHeaderTLC, {|x| x[2] == "ACG_MULTA "} )
     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o calculo de juros atraves da funcao do Sigaloja.                             ³
//³Essa funcao possui pontos de entrada se for necessario customizacao pelo cliente.     ³
//³Eh passado a data do atendimento como parametro para ser calculado baseado nessa data.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := LJRecLoad(  "4"		,cCliente			,cLoja			,NIL,;
					NIL		,NIL				,NIL			,NIL,;
			   		NIL		,SE1->(Recno())		,dDataCalc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tem que estar posicionado na tabela SE1 nesse momento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTk271Auto .OR. Len(aValoresSE1) <= 0 
	
	If cTmkJuros == "1"	   		// SIGAFIN 
		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³   Retorno   ³ExpA1: Array com a seguinte estrutura                        ³
		//³             ³       [1] Valor Original do Titulo                          ³
		//³             ³       [2] Abatimentos                                       ³
		//³             ³       [3] Pagto Parcial                                     ³
		//³             ³       [4] Decrescimo                                        ³
		//³             ³       [5] Acrescimo                                         ³
		//³             ³       [6] Saldo do Titulo na Moeda do Titulo                ³
		//³             ³       [7] Saldo do Titulo na Moeda Corrente                 ³
		//³             ³       [8] Juros                                             ³
		//³             ³       [9] Desconto                                          ³
		//³             ³       [10] Correcao Monetaria                               ³
		//³             ³       [11] Valor a ser Recebido na moeda do titulo          ³
		//³             ³       [12] Valor a ser Recebido na moeda corrente           ³
		//³             ³       [13] Multa                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/ 
	
		aValoresSE1 := FaVlAtuCr()
	
	ElseIf cTmkJuros == "2"		// SIGALOJA

		Aadd(aValoresSE1,{0,0,0,0,0,0,0,0,0,0,0,0,0})
		
	Endif
Endif	

If Len(aRet[4]) > 0

	If aValoresSE1[11] <= aValoresSE1[6]    // Se o valor a ser recebido for menor ou igual ao saldo do título, está sem juros e multa; então soma
		aValoresSE1[8] 	:= 	aRet[4][1][7]	// Valor de Juros
		aValoresSE1[11]	+= 	aRet[4][1][9]	// Valor de Juros e Multa acrescentados ao valor a receber: E1_SALDO+E1_MULTA+E1_JUROS-E1_DESCONT
		aValoresSE1[12]	+= 	aRet[4][1][9]	// Valor de Juros e Multa acrescentados ao valor a receber: E1_SALDO+E1_MULTA+E1_JUROS-E1_DESCONT
	EndIf 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o campo ACG_MULTA estiver criado, atualiza com o valor da multa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nPMulta > 0
	    aColsTlc[nLinha][nPMulta]:= aRet[4][1][6] 		//Valor de Multa
    Endif
    aColsTlc[nLinha][nPJuros]	:= aValoresSE1[8] 		//Valor de Juros
	aColsTlc[nLinha][nPRecebe]	:= aValoresSE1[12] 		//Valor a Receber do titulo
	aColsTlc[nLinha][nPValRef]	:= aValoresSE1[6]		//Saldo do Titulo 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se existir valor de desconto, como a funcao do financeiro calculou sem os juros,       ³
	//³calculo novamente baseado nos valores de juros e nominal que a telecobranca atualizou. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// O desconto financeiro soh e valido ate a data limite
	If SE1->E1_LIDESCF >= dDatabase
		If SE1->E1_DESCFIN > 0
			aValoresSE1[9]	:= IIF(nDescNom > 0, (aColsTlc[nLinha][nPValRef] 	* SE1->E1_DESCFIN / 100),0)
		Endif
		aValoresSE1[9]	+= IIF(nDescJur > 0, (aColsTlc[nLinha][nPJuros] 	* SE1->E1_DESCJUR / 100),0)
	EndIf
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk274CriaVar    ³ Autor ³ Vendas Clientes ³ Data ³29/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Adiciona nova coluna no Acols        					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tk274CriaVar(ExpC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campo a ser criado no acols.		  			  	  ³±±
±±³			 ³                              							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka274					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Static Function Tk274CriaVar(cField)
Local cRet		//Retorno do CriaVar
Local nPos		//Variavel utilizada em Loop, armazena a posição do campo no aHeader

If cField <> "CHECKBOL"
	For nPos:=1 To Len(aHeader)-2
		If AllTrim(aHeader[nPos][2]) == AllTrim(cField)
			Exit	
		EndIf
	Next nPos    
	If ( aHeader[nPos][10] <>  "V" )
		cRet := FieldGet(FieldPos(aHeader[nPos][2]))
	Else
		cRet := CriaVar(aHeader[nPos][2],.T.)
	Endif		
Else	
	Do Case
		Case (Empty(ACF->ACF_CCANC) .AND. Val(ACF->ACF_STATUS) == 1)
			cRet := "BR_AZUL"
	   
		Case (Empty(ACF->ACF_CCANC) .AND. Val(ACF->ACF_STATUS) == 2)
			cRet := "BR_VERDE"               
			
		Case (Empty(ACF->ACF_CCANC) .AND. Val(ACF->ACF_STATUS) == 3)
			cRet := "BR_VERMELHO"
			
		Case (!Empty(ACF->ACF_CCANC))
			cRet := "BR_CINZA"
	EndCase	
EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk274BeforeCols ³ Autor ³ Vendas Clientes ³ Data ³29/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se deve adicionar nova coluna no Acols			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tk274BeforeCols()										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                      	  			  	  ³±±
±±³			 ³                              							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka274					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Static Function Tk274BeforeCols()
Local lRet	:= .T.		//Indica se deve exibir o registro


DbSelectArea("ACF") 
If ACF->(EOF())
	lRet	:= .F.	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o intervalo de datas do atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lRet) .AND. (ACF->ACF_DATA < MV_PAR01 .OR. ACF->ACF_DATA > MV_PAR02)		
	lRet	:= .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o intervalo de codigos do operador ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lRet) .AND. (ACF->ACF_OPERAD < MV_PAR03 .OR. ACF->ACF_OPERAD > MV_PAR04)
	lRet	:= .F.
Endif
    		
If (lRet) .AND. (MV_PAR05 <> 1) //Todas (Status)
	If ACF->ACF_STATUS <> STR(MV_PAR05-1,1)
		lRet	:= .F.
	Endif
Endif
			
If (lRet) .AND. (MV_PAR06 <> 1) //Ambas
	If MV_PAR06 == 2 .AND. ACF->ACF_OPERA <> "1" //Receptivo
		lRet	:= .F.
  	ElseIf MV_PAR06 == 3 .AND. ACF->ACF_OPERA <> "2"//Ativo
   		lRet	:= .F.
    Endif           
Endif    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra a ocorrencia informada no parametro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lRet) .AND. (!Empty(MV_PAR07))
   	If ACF->ACF_MOTIVO <> MV_PAR07
		lRet	:= .F.
    Endif
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Tk274AfterCols  ³ Autor ³ Vendas Clientes ³ Data ³29/01/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera valores no Acols.             					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Tk274AfterCols(ExpA1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo o Acols.         			  	  	  ³±±
±±³			 ³                              							  ³±±
±±³			 ³                              							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Tmka274					 						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Static Function Tk274AfterCols(aColsACF)

If Len(aColsACF) > 0
	Do Case
		Case (Empty(ACF->ACF_CCANC) .AND. Val(ACF->ACF_STATUS) == 1)
			aColsACF[Len(aColsACF)][1] := "BR_AZUL"
	   
		Case (Empty(ACF->ACF_CCANC) .AND. Val(ACF->ACF_STATUS) == 2)
			aColsACF[Len(aColsACF)][1] := "BR_VERDE"               
			
		Case (Empty(ACF->ACF_CCANC) .AND. Val(ACF->ACF_STATUS) == 3)
			aColsACF[Len(aColsACF)][1] := "BR_VERMELHO"
			
		Case (!Empty(ACF->ACF_CCANC))
			aColsACF[Len(aColsACF)][1] := "BR_CINZA"
	EndCase
EndIf
Return .T.

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate
