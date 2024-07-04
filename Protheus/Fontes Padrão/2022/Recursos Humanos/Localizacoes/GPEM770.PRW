#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "GPEM770.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM770  ³ Autor ³ Rogerio Vaz Melonio   ³ Data ³ 22/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao de Informacoes para o Quadro de Pessoal            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Tiago Malta³07/01/10³00280/³ Alterado o uso da variavel cEmpant para  ³±±
±±³            ³        ³  2010³ a função FwCodEmp("SRD").                ³±±
±±³ Alex       ³22/12/10³29463/³ Atender Nova Interface Totvs 11.5 utili- ³±±
±±³            ³        ³  2010³ zando a funcao MsAdvSize.                ³±±
±±³ Tiago Malta³27/05/11³29463/³ Alterado as posições dos objetos usando a³±±
±±³            ³        ³  2010³ função retcoords.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function GPEM770()
Local nOpca 	:= 0
Local cTabMestra	:= "SRA"				//nome da Tabela Mestra
Local aFilterExp	:=  {} 					//expressao do filtro
Local aRetFiltro							//retorno do filtro
Local bNewFiltro							//bloco para inclusao de novos filtros
Local bAltFilter							//bloco para Alteracao do filtro selecionado
Local bBtnCalcule							//bloco do botão OK
Local bPergunte								//bloco para o pergunte
Local cExpFiltro	:= ""					//variavel com o retorno do filtro
Local cSays			:= OemToAnsi(STR0002)	//"Este programa gera as informações do Quadro de Pessoal"
Local oDlg
Local oBtnNewFil
Local oBtnAltFil
Local oBtnCalcule
Local oBtnEnd
Local oBtnPergunte
Local lShowDlgFilt	:= .T.					//visualizar a dialog de filtros
Local bDialogInit							//bloco de inicializacao da janela
Local nLinha
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aButtons		:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local aRetcoords

Private cTxtFil := ""
Private cAnoMesQP := Space(6)
Private oAnoMes, oTxtFil
Private cPerg := Padr("GPEM770",10)

DEFINE FONT oFont1  NAME "Arial" SIZE 0,-13 BOLD
cBlkGet :=  "{ | u | If( PCount() == 0, cTxtFil,cTxtFil:= u ) }"
cBlKVld :=  "{|| .T. }"
cBlKWhen := "{|| .F. }"

Pergunte(cPerg,.F.)
cAnoMesQP := mv_par01

bDialogInit 	:= { || ;
						Gpem770Arq(	@cTabMestra	,;
									oBtnNewFil	,;
									oBtnAltFil	,;
									oBtnCalcule	,;
									.T.			 ;
								 )								,;	// seta o arquivo Mestre
						Gpem770SetFil(@aFilterExp, cTabMestra)	,;	// Setar as opcoes que filtrara o cadastro de Filtro
						lShowDlgFilt := .F.						,;
						Gpem770Filter( 	aFilterExp	,;
							 			cTabMestra	,;
							 			@cExpFiltro ,;
							 			lShowDlgFil  ;
									),;	// setar o ultimo filtro utilizado
						lShowDlgFilt := .T.;
				   }
Gpem770SetFil(@aFilterExp, cTabMestra)
lShowDlgFilt := .F.
Gpem770Filter(aFilterExp,cTabMestra,@cExpFiltro,lShowDlgFil)
If !Empty(cExpFiltro)
	cTxtFil := Gpem770QbrFil(cExpFiltro)
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()  
aAdvSize[5]	:=	(aAdvSize[5]/100) * 70	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 75	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
//aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*60), (((aObjSize[1,4])/100)*70) }	//1,3 Vertical /1,4 Horizontal
aRetcoords      := RetCoords(3,4,50,15,1,0,,,aAdvSize)

DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0001 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL // "Geração do Quadro de Pessoal"
	/*/    
	
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Descricao da Janela                                                      ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
   	@ aObjSize[1][1]+5 , aObjSize[1][2]+5 TO oDlg:nBottom*0.37,oDlg:nRight*0.49 OF oDlg PIXEL  //@ 11,12 TO 100,245 OF oDlg PIXEL
	@ aRetcoords[1][1] , aRetcoords[1][2] SAY cSays Of oDlg Pixel  FONT oFont1 // "Este programa gera as informações do Quadro de Pessoal" //@ 20,25
	@ aRetcoords[4][1] , aRetcoords[4][2] SAY STR0005 Of oDlg Pixel FONT oFont1 // "Parametros:"  @ 30,25 
	@ aRetcoords[5][1] , aRetcoords[5][2] SAY STR0035 Of oDlg Pixel FONT oFont1 // "Ano/Mes"   @ 30,73 
	@ aRetcoords[6][1] , aRetcoords[6][2] MsGET oAnoMes VAR cAnoMesQP Picture "@R 9999/99" Size 15,08 When .F. Of oDlg Pixel    //@ 29,110 
	@ aRetcoords[7][1] , aRetcoords[7][2] SAY STR0033 Of oDlg Pixel FONT oFont1 // "Filtro de Funcionário:"  @ 40,25 
	oTxtFil := TMultiGet():New(aRetcoords[10][1],aRetcoords[10][2],&cBlKGet,oDlg,200,40,,.F.,,,,.T.,,.F.,&(cBlkWhen),.F.,.F.,.F.,&(cBlkVld),,.F.,.F.,.T.)
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Funcoes em GpFiltro  - Blocos de Execucao dos filtros                    ³
	³ GpFiltro - Chama a janela principal do cadastro de filtros               ³
	³ GpFltAlsGet - Retorna a expressao para elaborar o filtro                 ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	AADD(aButtons, {"LogOcorr" ,{ || GPM770Log() },STR0008,STR0008} )
	AADD(aButtons, {"AltFiltro" ,{ || Gpem770Filter( aFilterExp, cTabMestra, @cExpFiltro, .T. ), Gpem770QbrFil(cExpFiltro),oTxtFil:Refresh() },STR0003,STR0003} )
	AADD(aButtons, {"IncFiltro" ,{ || aRetFiltro := GpFiltro( aFilterExp ) , cExpFiltro := GpFltAlsGet( aRetFiltro , cTabMestra ), Gpem770QbrFil(cExpFiltro),oTxtFil:Refresh() },STR0004,STR0004} )
	AADD(aButtons, {"Parametros" ,{ || Pergunte("GPEM770",.T.), cAnoMesQP := mv_par01, oAnoMes:Refresh() },STR0005,STR0005} )
	
	bSet15		:= { || nOpca := 1, IF( GPM770Ok()( ),oDlg:End(), nOpca:=0 ) }
	bSet24		:= { || oDlg:End() }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Ano/Mes Referencia                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF nOpca == 1
	If Empty(cExpFiltro)
		lRet := MsgYesNo(OemToAnsi(STR0010),OemToAnsi(STR0011)) // "Nenhum filtro foi selecionado! Processar toda a tabela?"###"Aten‡„o"
	Else
		lRet := .T.
	EndIf	
	If lRet
		cAnoMesQP := mv_par01
		ProcGpe({|lEnd| GPM770Grava(cExpFiltro,cTabMestra)})  // Chamada do Processamento
	Endif
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM770Log     ºAutor  ³Rogerio Melonio   º Data ³  07/08/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualizacao do Relatorio de Log de Processamento.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM770Log()
cPathFile := ""
cExtRel := ".##R"
cPathFile := ( __RelDir + "GPEM770" + cExtRel )
If File(cPathFile)
	OurSpool( "GPEM770" )
	Ms_Flush()
Else
	MsgStop(STR0027) // "Não existe Log de Processamento para exibir"
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM770Grava   ºAutor  ³Rogerio Melonio   º Data ³  07/08/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que processa os registros das tabelas SRA e SRD con-  º±±
±±º          ³forme parametros selecionados                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM770Grava(cExpFiltro,cTabMestra)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis LOCAIS DO PROGRAMA                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nX
Local nA
Local aIndex := {}
Local cChave        
Local cFilRCA	:= xFilial( "RCA" )
Local aMnemos	:= {}

Private aInfo 	:= {}
Private aCodFol	:= {}   // Matriz com Codigo da folha
Private aLog	:= {}
Private aTitle	:= {}
Private aTotRegs:= array(17) // Ajustar o tamanho do array aLogSRA na funcao f770LogSRA() caso aparecam novas ocorrencias
Private aVerba	:= {}
Private cAliasSRD := "SRD"
Private cInfOut := ""
Private cDescri := ""
Private cCodRet := ""
Private aFunc 	:= {}     
Private aPerAtual := {}
Private dUltDia
aFill(aTotRegs,0)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpar o arquivo do Quadro de Pessoal                                    ³
//³ Limpar RGP se forem encontradas informacoes dos funcionarios solicitados.³
//³Apenas serao limpos os dados dos funcionario selecionados para geracao.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP          
	cQuery := "DELETE FROM "+RetSqlName("RGP")+" "
   	cQuery += " WHERE RGP_ANOMES	=  	'" 	+ cAnoMesQP 		+ "'"
	cQuery += " AND EXISTS(" 
	cQuery += " SELECT R_E_C_N_O_ FROM " + RetSqlName("SRA") +""
	cQuery += " WHERE "         
	cQuery += " RA_FILIAL = RGP_FILIAL " 
	cQuery += " AND RA_MAT = RGP_MATRIC "                 
	cQuery += " AND D_E_L_E_T_ = ' ')"
	TcSqlExec(cQuery)
	dbSelectArea("RGP")
	dbCloseArea()
	ChkFile("RGP",.F.)
#ELSE    
	// IMPLEMENTAR LOGICA PARA LIMPEZA CASO SEJA DBF
	// CONFORME DEFINICAO DADA EM 22/08/08, A ROTINA SO DEVE SER DESENVOLVIDA PARA TOP.
	dbSelectArea("RGP")
	dbSetOrder(2) // RGP_FILIAL+RGP_MATRIC+RGP_ANOMES
	dbSelectArea("SRA")
	dbSetOrder(1)
	dbGoTop()
	While SRA->( !EOF()) 
		cCodEsta := Posicione("SQB",1,xFilial("SQB")+SRA->RA_DEPTO,"QB_CESTAB") // Caracter ,4
		cChave	:= SRA->RA_FILIAL+cAnoMesQP+cCodEsta+SRA->RA_CODIRCT+SRA->RA_MAT
		dbSelectArea("RGP")
		If dbSeek( cChave )
			RecLock("RGP",.F.)
			dbDelete()
			MsUnlock()
		Endif
		dbSelectArea("RGP")
		SRA->( dbSkip() )
	EndDo
#ENDIF

Gpem770Verba() // Monta o array aVerba com codigo das verbas que serao consideradas na totalizacao de valores do Quadro de Pessoal

dbSelectArea( "SRD" )
dbSetOrder(1)
dbSelectArea( "SRA" )
dbSetOrder(1)
dbGoTop()
ProcRegua(SRA->(RecCount()))
cAxTabMestra := cTabMestra
If !Empty(cExpFiltro)
	cFilter := cExpFiltro
	If aTotRegs[12] == 0
		cLog := STR0009 // "Filtro da Tabela SRA: "
		Aadd(aTitle,cLog)  
		Aadd(aLog,{})
		aTotRegs[12] := len(aLog)
	EndIf	
	Aadd(aLog[aTotRegs[12]], cExpFiltro ) 
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Aplicar o filtro na tabela                                   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	bFiltraBrw 	:= { || FilBrowse( cAxTabMestra, @aIndex , @cFilter ) }
	Eval( bFiltraBrw )
Else
	cFilter := ""
Endif

dDataRef := Stod(cAnoMesQP+"01") // ex.: 2007 10 01
dUltDia	 := LastDate( dDataRef ) // retorna ultimo dia do mes/ano de referencia, ex.: 31/10/2007
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Inicializa os Mneumonicos Para uso em Formulas			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
SetMnemonicos( cFilRCA , @aMnemos , .T. )

dbSelectArea(cAxTabMestra)
dbGoTop()
lProcessou := .F.
While SRA->(!Eof()) // .And. SRA->RA_FILIAL <= cFilAte
	lProcessou := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta cursor para movimentacao da barra                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncProc(SRA->RA_FILIAL+" - "+SRA->RA_MAT+" - "+SRA->RA_NOME)
	// Efetua validacoes no SRA
	If SRA->RA_ADMISSA > dUltDia // se a data de admissao eh maior que o ultimo dia valido ignora funcionario
		SRA->( dbskip() )
		loop             
	EndIf
 	If !Empty(SRA->RA_DEMISSA) .And. (SRA->RA_DEMISSA < dUltDia) // se foi demitido antes do ultimo dia valido ignora funcionario
		SRA->( dbskip() )
		loop             
	Endif
	// Verifica se o cadastro de funcionario esta com campos obrigatorios para o quadro de pessoal preenchidos.
	// os campos a serem validados conforme o dossie de especificaoces tecnicas de 2007 sao:
	// 1 - "Funcionário sem Estabelecimento
	// 2 - "Funcionário sem IRCT
	// 3 - "Funcionário sem Data de Nascimento
	// 4 - "Funcionário sem Data de Admissão
	// 5 - "Funcionário sem Categoria Profissional
	// 6 - "Funcionário sem Profissão
	// 7 - "Funcionário sem Formação Escolar
	// 8 - "Funcionário sem Nacionalidade
	// 9 - "Funcionário sem Situação Profissional
	cCodEsta := Posicione("SQB",1,xFilial("SQB")+SRA->RA_DEPTO,"QB_CESTAB") // Caracter ,4
	If !Empty(cCodEsta) .And. !Empty(SRA->RA_CODIRCT) .And. !Empty(SRA->RA_NASC) .And. !Empty(SRA->RA_ADMISSA) .And. !Empty(SRA->RA_CODCAT) ;
		.And. !Empty(SRA->RA_CDPROF) .And. !Empty(SRA->RA_HABESCO) .And. !Empty(SRA->RA_NACIONA) .And. !Empty(SRA->RA_SITPROF)
		// se nao ha inconsistencias no cadastro do funcionario
		If aTotRegs[10] == 0
			cLog := STR0025 // "Funcionários sem inconsistencias."
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[10] := len(aLog)
		EndIf	
		Aadd(aLog[aTotRegs[10]], SRA->RA_FILIAL+"-"+SRA->RA_MAT+ space(02)+SRA->RA_NOME ) 
    Else
		// se ha inconsistencias no cadastro do funcionario registra no Log de Ocorrencias
    	f770LogSRA()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Buscar Valores no Acumulado "SRD"                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMat := SRA->RA_MAT		
	cFil := SRA->RA_FILIAL
	aFunc   	:= {0,0,0,0,0,0} // Vlr Base, Horas Normais, Vlr. Horas Extras, Horas Extras, Premios Regulares, Prestacoes Irregulares
	dbSelectArea("SRD")
	#IFDEF TOP
		lQuery 		:= .T.
		cAliasSRD 	:= "qPessoalSRD"
		aStru  		:= SRD->(dbStruct())
		cQuery 		:= "SELECT * "		
		cQuery 		+= " FROM "+	RetSqlName("SRD")
		cQuery 		+= " WHERE RD_FILIAL  ='" + cFil + "'"
		cQuery 		+= " AND RD_MAT     = '" + cMat+ "'"
		cQuery 		+= " AND RD_ROTEIR IN('FOL','NAT')"
		cQuery 		+= " AND RD_DATARQ = '"+cAnoMesQP+"'"
		cQuery 		+= " AND D_E_L_E_T_ = ' ' "
		cQuery 		+= "ORDER BY "+SqlOrder(SRD->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRD,.T.,.T.)
		For nX := 1 To len(aStru)
			If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
				TcSetField(cAliasSRD,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSRD)	
	#ELSE
		cAliasSRD 	:= "SRD"
		(cAliasSRD)->(MsSeek(SRA->RA_FILIAL+SRA->RA_MAT+cAnoMesQP,.T.))
	#ENDIF
    aVerbaDupl := {}
	While (cAliasSRD)->(!Eof()) .And. (cAliasSRD)->RD_FILIAL+(cAliasSRD)->RD_MAT == SRA->RA_FILIAL+SRA->RA_MAT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Despreza os lanctos sem correspondencia de valor no quadro de pessoal ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      	If Ascan(aVerba,{|X| X[1] == (cAliasSRD)->RD_PD } ) == 0
			(cAliasSRD)->( dbSkip() )
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Despreza os lanctos de transferencias de outras empresas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      	If (cAliasSRD)->RD_EMPRESA # FwCodEmp("SRD") .And. !Empty((cAliasSRD)->RD_EMPRESA)
			(cAliasSRD)->( dbSkip() )
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Despreza os tipos de roteiros diferentes de FOL/NAT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !( (cAliasSRD)->RD_ROTEIR  $ "FOL/NAT" )
			(cAliasSRD)->( dbSkip() )
			Loop
		EndIf
		If empty((cAliasSRD)->RD_PD)
			If aTotRegs[13] == 0
				cLog := STR0028 // "Lancamento com verba em branco no acumulado.    Filial/Matricula  Competencia            Valor "
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[13] := len(aLog)
			EndIf	      
			Aadd(aLog[aTotRegs[13]],space(49)+(cAliasSRD)->RD_FILIAL+"-"+(cAliasSRD)->RD_MAT+space(08)+substr((cAliasSRD)->RD_DATARQ,5,2)+"/"+substr((cAliasSRD)->RD_DATARQ,1,4) +space(04)+transform((cAliasSRD)->RD_VALOR,"@E 99,999,999,999.99") )
			(cAliasSRD)->( dbSkip() )
			Loop
		EndIf                      
		If empty((cAliasSRD)->RD_DATARQ)
			If aTotRegs[14] == 0
				cLog := STR0029 // "Lancamento com competencia em branco no acumulado.   Filial/Matricula  Verba             Valor"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[14] := len(aLog)
			EndIf	     
			Aadd(aLog[aTotRegs[14]],space(54)+(cAliasSRD)->RD_FILIAL+"-"+(cAliasSRD)->RD_MAT+space(09)+(cAliasSRD)->RD_PD+space(03)+transform((cAliasSRD)->RD_VALOR,"@E 99,999,999,999.99") )
			(cAliasSRD)->( dbSkip() )
			Loop
		EndIf
		If empty((cAliasSRD)->RD_DATPGT)
			If aTotRegs[15] == 0
				cLog := STR0030 // "Lancamento com data de pagamento em branco no acumulado."
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[15] := len(aLog)
			EndIf	             
			Aadd(aLog[aTotRegs[15]],(cAliasSRD)->RD_FILIAL+"-"+(cAliasSRD)->RD_MAT+"-"+(cAliasSRD)->RD_PD+"-" +transform((cAliasSRD)->RD_VALOR,"@E 99,999,999,999.99") )
			(cAliasSRD)->( dbSkip() )
			Loop
		EndIf
		If Ascan( aVerbaDupl,(cAliasSRD)->(RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC+RD_ROTEIR)) == 0
			Aadd(aVerbaDupl,(cAliasSRD)->(RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC+RD_ROTEIR))
		Else 
			If aTotRegs[16] == 0
				cLog := STR0031 // "Verba duplicada nos acumulados.    Filial/Matricula   Verba   Competencia             Valor"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[16] := len(aLog)
			EndIf	             
			Aadd(aLog[aTotRegs[16]],SPACE(35)+(cAliasSRD)->RD_FILIAL+"-"+(cAliasSRD)->RD_MAT+SPACE(10)+(cAliasSRD)->RD_PD+SPACE(05)+substr((cAliasSRD)->RD_DATARQ,5,2)+"/"+substr((cAliasSRD)->RD_DATARQ,1,4)+SPACE(5)+ transform((cAliasSRD)->RD_VALOR,"@E 99,999,999,999.99") )
		EndIf		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Esta função buscará os valores das verbas no acumulado,      ³
		//³e suas incidências, e as guardará no array afun, para gravar ³
		//³posteriormente na tabelas RGP.                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		f770MontaDados((cAliasSRD)->RD_PD,xFilial("SRV"))
		(cAliasSRD)->( dbSkip())
	Enddo
	#IFDEF TOP
		dbSelectArea(cAliasSRD)
		dbCloseArea()
	#ENDIF    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravar Quadro de Pessoal        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FGravaRGP	()
	dbSelectArea("SRA")
	dbSkip()
Enddo
If lProcessou
	If aTotRegs[1] == 0 .and. aTotRegs[2] == 0 .and. aTotRegs[4] == 0 .and. aTotRegs[5]==0 .and. ;
	   aTotRegs[6] == 0 .and. aTotRegs[7] == 0 .and. aTotRegs[8] == 0 
		If aTotRegs[11] == 0
			cLog := STR0012 // "Quadro de Pessoal Gerado com sucesso!"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[11] := len(aLog)
		EndIf	
		Aadd(aLog[aTotRegs[11]], STR0013 ) // "Nao foi encontrada nenhuma inconsistencia durante a geracao."
	EndIf   
Else
	If aTotRegs[17] == 0
		cLog := STR0014 // "Informacoes para gerar o Quadro de Pessoal."
		Aadd(aTitle,cLog)  
		Aadd(aLog,{})
		aTotRegs[17] := len(aLog)
	Endif
	Aadd(aLog[aTotRegs[17]], STR0034 ) // "Não foram encontrados registros para processar com os parâmetros/filtro informados"
Endif
If aTotRegs[3] == 0
	cLog := STR0014 // "Informacoes para gerar o Quadro de Pessoal."
	Aadd(aTitle,cLog)  
	Aadd(aLog,{})
	aTotRegs[3] := len(aLog)
EndIf	
fMakeLog(aLog,aTitle,,,"GPEM770",STR0015,"M","P",,.F.) // "Log de ocorrencias do Quadro de Pessoal"
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FGravaRGP ºAutor  ³Rogerio Vaz Melonio º Data ³  19/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza registro na tabela RGP                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FGravaRGP()            
cCodEsta := Posicione("SQB",1,xFilial("SQB")+SRA->RA_DEPTO,"QB_CESTAB") // Caracter ,4
cChave	:= SRA->RA_FILIAL+cAnoMesQP+cCodEsta+SRA->RA_CODIRCT+SRA->RA_MAT
cTipoContrato := Gpem770Tipoco()
If !Empty(cTipoContrato)
	cTpContrQP := fDescRcc("S011",cTipoContrato,1,2,77,1)
Else
	cTpContrQP := "8"
Endif
dUltPromo := Gpem770DtProm() // Busca data da ultima promocao na tabela SR3
If aFunc[2]-Int(aFunc[2]) <= 0.50
	nHrNormal 	:= Int(aFunc[2])
Else
	nHrNormal 	:= Int(aFunc[2])+1
EndIf			
If aFunc[4]-Int(aFunc[4]) <= 0.50
	nHrSupl 	:= Int(aFunc[4])
Else
	nHrSupl 	:= Int(aFunc[4])+1
EndIf

nPerNormal 	:= SRA->RA_HRSMES * 12 / 52          // Periodo NOrmal de Trabalho 
 

// Configuracao do Controle da Remuneracao Base
If (aFunc[1] > 0 .And. aFunc[2] >= SRA->RA_HRSMES) // remuneração mensal base completa e horas normais correspondentes
	cContrRemu := "0"
ElseIf	(aFunc[2] > 0 .And. aFunc[2] < SRA->RA_HRSMES .And. aFunc[1] > 0) // remuneração mensal base incompleta e horas normais correspondentes
	cContrRemu := "1"
ElseIf	(aFunc[1]+aFunc[5] = 0 .And. aFunc[2] = 0) // sem remuneração mensal base ou qualquer tipo de remuneração e sem horas
	cContrRemu := "2"
ElseIf	(aFunc[1] = 0 .And. aFunc[2] = 0 .And. aFunc[5] > 0) // com remuneração mensal base = 0 e horas normais = 0, mas tendo havido lugar ao pagamento de outro tipo de remunerações. 
	cContrRemu := "3"
Else
	cContrRemu := ""
Endif
dbSelectArea("RGP")
dbSetOrder(1) // RGP_FILIAL + RGP_ANOMES + RGP_CODEST + RGP_IRCT + RGP_MATRIC
If dbSeek( cChave )
	RecLock("RGP",.F.)
Else
	RecLock("RGP",.T.)
Endif
RGP->RGP_FILIAL   := SRA->RA_FILIAL
RGP->RGP_ANOMES	  := cAnoMesQP
RGP->RGP_CODEST	  := cCodEsta
RGP->RGP_IRCT	  := SRA->RA_CODIRCT
RGP->RGP_MATRIC   := SRA->RA_MAT
RGP->RGP_NOME	  := SRA->RA_NOME
RGP->RGP_ULTPRO	  := dUltPromo
RGP->RGP_CATEGO	  := SRA->RA_CODCAT
RGP->RGP_CODPRO	  := SRA->RA_CDPROF
RGP->RGP_CODNAC	  := SRA->RA_NACIONA
RGP->RGP_CODHAB	  := SRA->RA_HABESCO
RGP->RGP_SITPRO	  := Iif(SRA->RA_SITPROF<='4',SRA->RA_SITPROF,'8')
RGP->RGP_TIPOCO	  := cTpContrQP
RGP->RGP_REGIME	  := SRA->RA_RDURTRA
RGP->RGP_REMUBA	  := aFunc[1]
RGP->RGP_HRNORM	  := nHrNormal
RGP->RGP_TRBSUP	  := aFunc[3]
RGP->RGP_HRSUPL	  := nHrSupl
RGP->RGP_PERNOR	  := nPerNormal
RGP->RGP_CONTRO	  := cContrRemu
RGP->RGP_PREMIO	  := aFunc[5]
RGP->RGP_IRREGU	  := aFunc[6]
MsUnlock()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³f770MontaDados ºAutor  ³Rogerio Vaz Melonio º Data ³19/08/08º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function f770MontaDados(cPD,cCodFil)
Local aArea		:= GetArea()                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona a Verba no SRV³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PosSrv(cPd,cCodFil)
If SRV->( eof() ) .and. !empty( cPd )
	If aTotRegs[17] == 0
		cLog := STR0032 // "Verba consta nos acumulados, mas nao consta no cadastro de verbas.   Verba    Competencia             Valor"
		Aadd(aTitle,cLog)  
		Aadd(aLog,{})
		aTotRegs[17] := len(aLog)
	EndIf	     
	Aadd(aLog[aTotRegs[17]],space(70)+cPd+space(06)+substr((cAliasSRD)->RD_DATARQ,5,2)+"/"+substr((cAliasSRD)->RD_DATARQ,1,4) +space(04)+transform((cAliasSRD)->RD_VALOR,"@E 99,999,999,999.99") )
	Return
EndIf
nFator := IIf(SRV->RV_TIPOCOD='1',1,-1)
nVal :=	(cAliasSRD)->RD_VALOR * nFator
If SRA->RA_CATFUNC = 'M' // se eh mensalista converte dias para horas
	nRef := (cAliasSRD)->RD_HORAS * (SRA->RA_HRSMES/30) * nFator
ElseIf SRA->RA_CATFUNC = 'H' // se eh horista 
	nRef := (cAliasSRD)->RD_HORAS * nFator
Else
	nRef := 0
Endif
If SRV->RV_REMUNQP == '01' // Valor Base
	aFunc[1] += nVal // Valor Base 
	aFunc[2] += nRef // Horas Normais ref. ao Valor Base
ElseIf SRV->RV_REMUNQP == '02' // Horas Extras (Trabalho Suplementar)
	aFunc[3] += nVal // Valor de Horas extras
	aFunc[4] += nRef // Horas Extras ref. ao Valor de Horas Extras
ElseIf SRV->RV_REMUNQP == '03' // Premios e Subsidios Regulares
	aFunc[5] += nVal // Valor de Premios e Subsidios Regulares
ElseIf SRV->RV_REMUNQP == '04' // Prestacoes Irregulares
	aFunc[6] += nVal // Valor de Prestacoes Irregulares
Else // Demais verbas que compoem horas do quadro de pessoal
	If SRV->RV_HORASQP == '1' // Se a verba compoe as horas do Quadro de Pessoal
		If SRV->RV_HE = "S"
			aFunc[3] += nVal // Valor de Horas extras
			aFunc[4] += nRef // Horas Extras
		Else
			aFunc[1] += nVal // Valor Base 
			aFunc[2] += nRef // Horas Normais
		Endif
	Endif
Endif
RestArea(aArea)		

Return		


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³f770LogSRA     ºAutor  ³Rogerio Vaz Melonio º Data ³19/08/08º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cria Log de Inconsistencia de Funcionario                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function f770LogSRA()
Local aLogSRA := {}
Local nLog
lCodEsta := Empty(Posicione("SQB",1,xFilial("SQB")+SRA->RA_DEPTO,"QB_CESTAB"))
aAdd(aLogSRA,{lCodEsta				,STR0016}) // 1 - "Funcionário sem Estabelecimento cadastrado."
aAdd(aLogSRA,{Empty(SRA->RA_CODIRCT),STR0017}) // 2 - "Funcionário sem IRCT cadastrado."
aAdd(aLogSRA,{Empty(SRA->RA_NASC)   ,STR0018}) // 3 - "Funcionário sem Data de Nascimento cadastrada."
aAdd(aLogSRA,{Empty(SRA->RA_ADMISSA),STR0019}) // 4 - "Funcionário sem Data de Admissão cadastrada."
aAdd(aLogSRA,{Empty(SRA->RA_CODCAT) ,STR0020}) // 5 - "Funcionário sem Categoria Profissional cadastrada."
aAdd(aLogSRA,{Empty(SRA->RA_CDPROF) ,STR0021}) // 6 - "Funcionário sem Profissão cadastrada."
aAdd(aLogSRA,{Empty(SRA->RA_HABESCO),STR0022}) // 7 - "Funcionário sem Formação Escolar cadastrada."
aAdd(aLogSRA,{Empty(SRA->RA_NACIONA),STR0023}) // 8 - "Funcionário sem Nacionalidade cadastrada."
aAdd(aLogSRA,{Empty(SRA->RA_SITPROF),STR0024}) // 9 - "Funcionário sem Situação Profissional cadastrada."
aAdd(aLogSRA,{.F.					,STR0025}) //10 - "Funcionários sem inconsistencias." (posicao 10 reservada para funcionario OK)
aAdd(aLogSRA,{.F.					,STR0013}) //11 - "Nao foi encontrada nenhuma inconsistencia durante a geracao." (posicao 11 reservada para processamento total OK)
aAdd(aLogSRA,{.F.					,STR0009}) //12 - "Filtro da Tabela SRA: " (posicao 12 reservada para mensagem de filtro)
aAdd(aLogSRA,{.F.					,STR0028}) //13 - "Lancamento com verba em branco no acumulado.    Filial/Matricula  Competencia            Valor "
aAdd(aLogSRA,{.F.					,STR0029}) //14 - "Lancamento com competencia em branco no acumulado.   Filial/Matricula  Verba             Valor"
aAdd(aLogSRA,{.F.					,STR0030}) //15 - "Lancamento com data de pagamento em branco no acumulado."
aAdd(aLogSRA,{.F.					,STR0031}) //16 - "Verba duplicada nos acumulados.    Filial/Matricula   Verba   Competencia             Valor"
aAdd(aLogSRA,{.F.					,STR0034}) //17 - "Não foram encontrados registros para processar com os parâmetros/filtro informados"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A T E N C A O !!!!!!!!!        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// se incluir mais elementos no array aLogSRA, corrigir a inicializacao do aTotRegs no inicio da funcao GPM770Grava
For nLog := 1 To Len(aLogSRA)
	If aLogSRA[nLog][1] // se tem inconsistencia no SRA adiciona funcionario ao array de log de ocorrencia
		If aTotRegs[nLog] == 0
			cLog := aLogSRA[nLog][2]
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[nLog] := len(aLog)
		EndIf	
		Aadd(aLog[aTotRegs[nLog]], SRA->RA_FILIAL+"-"+SRA->RA_MAT+ space(02)+SRA->RA_NOME ) 
	Endif
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPM770Ok  ºAutor  ³Microsiga           º Data ³  22/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe confirmacao do processamento                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPM770Ok()
Return (MsgYesNo(OemToAnsi(STR0026),OemToAnsi(STR0011))) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem770Filter³Autor³ Rogerio Vaz Melonio    ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Botao de alteracao do filtro                 				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Gpem770Filter(	aFilterExp 	,;		// opcoes do filtro  // MUDEI AQUI
								cTabMestra	,;		// alias do filtro
					 			cExpFiltro	,;		// string com o filtro - passado por referencia
								lShowDlg	 ;		// Se visualiza janela de filtros
					  		 )
Local aRetFiltro 	:= {}
Local aHeader 		:= {}
Local cTxtFil 		:= ""
DEFAULT lShowDlg	:= .T.
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Elabora o cabecalho do arquivo Mestre                 	       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
aHeader := GdMontaHeader(NIL,NIL,NIL,cTabMestra,NIL,.T.,.T.,.F.,.F.,.F.,.F.,.F.)
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Retorna os filtros selecionados                       	       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
aRetFiltro := GpFiltro( aFilterExp, .F. )
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Se for na inicializacao da dialog, nao mostrar a janela       ³
³Caso possua mais de 1 filtro selecionado-retornar filtro Vazio³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
If (;
		( Len(aRetFiltro) > 1 );
		.And.;
		( lShowDlg );
	)	
	aRetFiltro := GpFiltro( aFilterExp )
ElseIf (;
			( Len(aRetFiltro) > 1 );
			.And.;
			!( lShowDlg );
		)	
	aRetFiltro := NIL
EndIf
If !Empty(aRetFiltro)
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Retorna a expressao dos filtros                      	       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	cExpFiltro := GpFltAlsGet( aRetFiltro , cTabMestra )

	If lShowDlg
		cTxtFil    := GpFltBldDesc( cExpFiltro, @aHeader, cTabMestra )
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Janela para alteracao dos valores do filtro          	       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		AltValExp( cTabMestra , @cExpFiltro , @cTxtFil , NIL , aHeader )
	EndIf
EndIf
Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem770Arq³Autor³ Rogerio Vaz Melonio       ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³                                             				³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Gpem770Arq(	cTabMestra		,;	// nome do arquivo mestre  // MUDEI AQUI
						oBtnNewFil		,;	// botao de novo filtro
						oBtnAltFil		,;  // botao de alteracao do filtro
						oBtnCalcule		 ;	// botao OK
					  )
Local lBtn		:= .T.
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Ativar / Desativar os botoes conforme arquivo selecionado     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
IF lBtn
	lBtn	:= !Empty( cTabMestra )
EndIF
oBtnNewFil:lActive 	:= lBtn
oBtnAltFil:lActive 	:= lBtn
oBtnCalcule:lActive	:= lBtn
Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem770SetFil³Autor³ Rogerio Vaz Melonio    ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Setar as opcoes do Filtro									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Gpem770SetFil( aFilterExp , cTabMestra )
Local aGrpUsr		:= {}	// Grupo dos Usuarios
Local cGrpUsr		:= ""	// string com o Grupo de usuario
Local nLoop			:= 0	
aAdd( aFilterExp , { "FILTRO_ALS" , cTabMestra 	, NIL , NIL    } )
/*/		
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Localizar os grupos a que o usuario pertence                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
aGrpUsr := UsrRetGrp( SubStr( cUsuario , 7 , 15 ) )
For nLoop := 1 To Len(aGrpUsr)
	cGrpUsr := aGrpUsr[nLoop]
	aAdd( aFilterExp , { "FILTRO_GRP" , cGrpUsr 	, NIL , NIL    } )
Next nLoop
Return( NIL )
 
/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem770Verba ³Autor³ Rogerio Vaz Melonio    ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Inicializa o array de Verbas   								³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Gpem770Verba()
dbSelectArea("SRV")
dbGoTop()
While ! Eof()
	If !SRV->RV_TIPOCOD $ '1/2' // Se nao eh provento nem desconto, desconsidera a verba
		dbSkip()
		Loop
	Endif
	If (Empty(SRV->RV_REMUNQP) .And. Empty(RV_HORASQP)) // Se nao entra em remuneracao ou horas do quadro de pessoal, desconsidera a verba
		dbSkip()
		Loop
	Endif
	aAdd(aVerba,{SRV->RV_COD})
	dbSkip()
EndDo

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem770Tipoco³Autor³ Rogerio Vaz Melonio    ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna o tipo de contrato vigente na data do parametro		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Gpem770Tipoco()
cMat := SRA->RA_MAT		
cFil := SRA->RA_FILIAL
dbSelectArea("RGE")
dbSetOrder(2) // ordem por RGE_FILIAL+RGE_MAT+DTOS(RGE_DATAIN)+RGE_TIPOCO
#IFDEF TOP
	lQuery 		:= .T.
	cAliasRGE 	:= "qPessoalRGE"
	cQuery 		:= "SELECT RGE_TIPOCO,MAX(RGE_DATAIN)"
	cQuery 		+= " FROM "+	RetSqlName("RGE")
	cQuery 		+= " WHERE RGE_FILIAL  ='" + cFil + "'"
	cQuery 		+= " AND RGE_MAT = '" + cMat+ "'"
	cQuery 		+= " AND RGE_DATAIN < '" + Dtos(dUltDia) + "'"
	cQuery 		+= " AND D_E_L_E_T_ = ' ' "
	cQuery 		+= " GROUP BY RGE_MAT,RGE_TIPOCO"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRGE,.T.,.T.)
	dbSelectArea(cAliasRGE)	
#ENDIF
#IFNDEF TOP
	cAliasRGE 	:= "RGE"
	(cAliasRGE)->(MsSeek(SRA->RA_FILIAL+SRA->RA_MAT+cAnoMesQP,.T.))
#ENDIF

If !Eof()                                                                      
	cTipoContrato := (cAliasRGE)->(RGE_TIPOCO)
Else
	cTipoContrato := ""
Endif
#IFDEF TOP
	dbCloseArea()
#ENDIF
Return(cTipoContrato)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem770DtProm³Autor³ Rogerio Vaz Melonio    ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna o tipo de contrato vigente na data do parametro		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Gpem770DtProm()
cMat := SRA->RA_MAT		
cFil := SRA->RA_FILIAL
cTipoProm := "'%"+AllTrim(P_TPPROQP)+"%'"
dbSelectArea("SR3")
dbSetOrder(1) // ordem por R3_FILIAL+R3_MAT+DTOS(R3_DATA)+R3_TIPO+R3_PD
#IFDEF TOP
	lQuery 		:= .T.
	cAliasSR3 	:= "qPessoalSR3"
	cQuery 		:= "SELECT R3_MAT,MAX(R3_DATA) DATAPROM"
	cQuery 		+= " FROM "+RetSqlName("SR3")
	cQuery 		+= " WHERE R3_FILIAL  ='" + cFil + "'"
	cQuery 		+= " AND R3_MAT     = '" + cMat+ "'"
	cQuery 		+= " AND R3_DATA < '" + dTos(dUltDia) + "'"
	cQuery 		+= " AND R3_TIPO LIKE " + cTipoProm
	cQuery 		+= " AND D_E_L_E_T_ = ' ' "
	cQuery 		+= " GROUP BY R3_MAT"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSR3,.T.,.T.)
	dbSelectArea(cAliasSR3)	
#ENDIF
#IFNDEF TOP
	cAliasSR3 	:= "SR3"
	(cAliasSR3)->(MsSeek(SRA->RA_FILIAL+SRA->RA_MAT+cAnoMesQP,.T.))
#ENDIF

If !Eof()
	#IFDEF TOP
		dUltPromo := Stod((cAliasSR3)->(DATAPROM))
	#ELSE
		dUltPromo := (cAliasSR3)->R3_DATA
	#ENDIF
Else
	dUltPromo := cTod("  /  /  ")
Endif
#IFDEF TOP
	dbCloseArea()
#ENDIF
Return(dUltPromo)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Gpem770QbrFil³Autor³ Rogerio Vaz Melonio    ³Data³22/08/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Retorna o texto do filtro qubrado em linhas            		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Gpem770QbrFil(cExpFiltro)
nLinha := 1
nStrFil := 1
cTxtFil := ""
While nStrFil <= Len(cExpFiltro)
	If nLinha > 5
		Exit
	Endif
	cTxtFil += Substr(cExpFiltro,nStrFil,80)+Chr(13)
	nStrFil+=80  
	nLinha++
EndDo
While nLinha <= 5
	cTxtFil += Chr(13)
	nLinha++
EndDo
Return(cTxtFil)