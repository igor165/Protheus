#Include "Ctba500.Ch"
#Include "PROTHEUS.Ch"
#Include "FWEVENTVIEWCONSTS.CH"

// Static __lSmtHTML	:= (GetRemoteType() == 5)
Static __aVerPad    := NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBA500  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 29/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Lan‡amentos Cont beis Off-Line TXT  c          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA500()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA500()

Local aSays 	:= {}
Local aButtons	:= {}
Local dDataSalv := dDataBase
Local nOpca 	:= 0     
Local aFiles	:= {} 
Local cDir 		:= GetMv("MV_CTBTPAT")
Local cOk		:= GetMv("MV_CTBTRES")
Local cErro		:= GetMv("MV_CTBTERR")
Local lRet 		:= .F.
Local nX		:= 0
Local cDtIni	:= ""
Local cDtFim	:= ""
Local cHrIni	:= ""
Local cHrFim	:= ""
Local aRecnos   := {}
Local lInConsist:= .F.
Local lDisarm	:= .F.
Local cArqTXT	:= ""

Private cCadastro 	:= OemToAnsi(OemtoAnsi(STR0001))  //"Contabiliza‡„o de Arquivos TXT"
Private lAtureg		:= .T.        
Private lUsu		:= .T.        

// Inicializa as variaveis staticas da contabilização
ClearCx105()

// Ponto de Entrada executado ao acessar rotina
IF ExistBlock("CTB500USU") 
	lUsu := ExecBlock( "CTB500USU", .F. , .F. ) 
	If !lUsu 
		Return
	EndIf
Endif          

//Ponto de entrada provisorio ate correção do Remote. BOPS 00000138556
If ExistBlock("CT500REG")
	lAtureg:=ExecBlock("CT500REG",.F.,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // Mostra Lan‡amentos Cont beis                     ³
//³ mv_par02 // Aglutina Lan‡amentos Cont beis                   ³
//³ mv_par03 // Arquivo a ser importado                          ³
//³ mv_par04 // Numero do Lote                                   ³
//³ mv_par05 // Quebra Linha em Doc.							 ³
//³ mv_par06 // Tamanho da linha	 							 ³
//³ mv_par07 // Por Filial	 									 ³
//³ mv_par08 // Parâmetro ou Sistema							 ³
//³ mv_par09 // Valida Recno de Origem 1- Sim - 2-Nao	         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("CTB500",.f.)

AADD(aSays,OemToAnsi( STR0002 ) )
AADD(aSays,OemToAnsi( STR0003 ) )

AADD(aButtons, { 5,.T.,{|| Pergunte("CTB500",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If(Ctb500Ok(),FechaBatch(), nOpca:=0 )}} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )
	
IF nOpca == 1

	/* Cria as procedures temporárias, validações do LinhaOk e tabela temporaria.  */
	If FindFunction("CtbIniLan")
		CtbIniLan()
	Endif
	cDtIni := Date()
	cHrIni := Time()
	While !CTBSerialI("CTBPROC","ON")
	EndDo
	
	If MV_PAR08 == 1 // Arquivo ou parametro
		Processa({|lEnd| Ctb500Proc(mv_par03, aFiles , @aRecnos, @lInConsist)})
	Else
 		If !Empty(cDir)
			aFiles := Directory( cDir+"\"+"*.txt" )
			If Empty(aFiles)			
				Help(" ",1,"CTBPROC",,STR0008,1,0) //"Diretorio não contém arquivos .TXT"
				Return
			Endif
		Endif
		
		For nX := 1 to Len(aFiles)
			lInConsist := .F.		
			cArqTXT	   := cDir+"\"+aFiles[nX][1]

			If LockByName(cArqTXT,.F.,.F.)					
				Processa({|lEnd| lRet := Ctb500Proc(cArqTXT, aFiles , @aRecnos, @lInConsist)})
				If lRet .and. !lInConsist //Arquivo processado com exito. e sem inconsistencia
					If !Empty(cOk)					
						lCop := _CopyFile(cDir+"\"+aFiles[nX][1],cOk+"\"+Ctb500Nome(aFiles[nX][1]))
						If lCop //Arquivo copiado
							FErase(cDir+"\"+aFiles[nX][1])
						Endif
					Else
						Help(" ",1,"CTBEMPTY",,STR0009,1,0) //"Parâmetro MV_CTBTRES esta vazio"
						lDisarm := .T.
					Endif
				Else
					If !Empty(cErro)
						lCop := _CopyFile(cDir+"\"+aFiles[nX][1],cErro+"\"+Ctb500Nome(aFiles[nX][1]))
						If lCop //Arquivo copiado
							FErase(cDir+"\"+aFiles[nX][1])
						Endif
					Else
						Help(" ",1,"CTBEMPTY",,STR0010,1,0) //"Parâmetro MV_CTBTERR esta vazio"
						lDisarm := .T. 
					Endif
				EndIf
				UnLockByName(cArqTXT,.T.,.T.)
			EndIf	
			If lDisarm
				EXIT
			EndIf

		Next nX		
	EndIf
	//FINALIZA E APAGA ARQUIVO TMP NO BANCO
	If FindFunction("CtbFinLan")
		CtbFinLan()
	EndIf
/* ----------------------------------------------------
	Relatório de inconsistências qdo Validar Recnos
   ---------------------------------------------------- */
   If !lDisarm
		If /*lInConsist .and.*/ Len(aRecnos) > 0 
			If MsgYesNo("Existem recnos no Txt que não existem nas respectivas tabelas, deseja imprimir o relatorio de erros?")
				Ct500Out(@aRecnos)
			Endif
		Endif

		CTBSerialF("CTBPROC","ON")

		cDtFim := Date()
		cHrFim := Time()
	
		Ctb500EnWf(,,,cDtIni,cDtFim,cHrIni,cHrFim)
	
	Endif
	
	/* Zera o aRecnos e desaloca o espaço em memória*/	
	aRecnos := aSize(aRecnos,0)
	aRecnos := nil

EndIf
	
dDataBase := dDataSalv

// Inicializa as variaveis staticas da contabilização
ClearCx105()

__aVerPad := NIL
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTB500Proc³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 29.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento do lancamento contabil TXT                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB500Proc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb500Proc(cArqTXT, aFiles, aRecnos, lInConsist)

Local cLote		:= CriaVar("CT2_LOTE")
Local cArquivo
Local cPadrao
Local lHead		:= .F.					// Ja montou o cabecalho?
Local lPadrao
Local lAglut
Local nTotal	:=0
Local nHdlPrv	
Local nBytes	:=0
Local nHdlImp
Local nTamArq
Local nTamLinha	:= Iif(Empty(mv_par06),512,mv_par06)
Local cMensagem	:= ""
Local cCRLF		:= CHR(13)+CHR(10)
Local ExCT500Lin := ExistBlock("CT500Lin")
Local lCT500Lin :=.T.
Local cFil		:= ""
Local cFilAtu	:= ""
Local cFilArq 	:= ""
Local lQuebra	:= .F.
Local lFil 		:= .F.
Local lRet 		:= .T.
Local lContinua	:= .T.
Local lCTB500VLD := ExistBlock("CTB500VLD")
Local lVldRecOri := If(Empty(mv_par09), .F., If( mv_par09 == 1, .T., .F.))
Local xBufferOld := Space( nTamLinha )

Local aCT5       := {} 

PRIVATE xBuffer := Space( nTamLinha )
Private aRotina := {	{ "","" , 0 , 1},;
						{ "","" , 0 , 2 },;
						{ "","" , 0 , 3 },;
						{ "","" , 0 , 4 } }
Private Inclui := .T.							

Default cArqTXT    := ""
Default aRecnos    := {}
Default lInConsist := .F.   // inconsitencia

If Empty(cArqTXT)
	cArqTXT := Mv_Par03
EndIf

cMensagem	:= STR0004			// "ERRO DE LEITURA"
cMensagem	+= cCRLF 
cMensagem	+= cCRLF 
cMensagem	+= STR0005 + ": "	// "Verifique"
cMensagem	+= cCRLF 
cmensagem	+= STR0006			// "a estrutura do arquivo TXT"
cMensagem	+= " - " + ALLTRIM( cArqTXT ) + " - "
cMensagem	+= cCRLF 
cMensagem	+= STR0007			// "os parâmetros informados"

If Empty(cArqTXT)
	Help(" ",1,"NOFLEIMPOR")
	Return .F.
End	

If lCTB500VLD
	lContinua := ExecBlock("CTB500VLD",.F.,.F.)
Endif
// ponto de entrada retornou .T. -> continua processamento
If lContinua .and. lVldRecOri
    // SELECIONA LANCAMENTOS COM ESTA CARACTERISTICA DE CT5_RECORI PREENCHIDO 
	//CONOUT("Inicio da gravação array: "+ time())    
	//CT500Recno(@lInConsist)
	//                 Lacto Pad       Tabela Orig              Recno                        Linha txt   Erro -> 1 recno não existe na tabela origem
	//		                                                                                                    -> 2 Lancto padrao Não existe
	//aadd( aRecnos, { cLP_Buffer+" "+ RetSqlName(cTABORI)+" "+ Alltrim(Str(  nTABREC))+" "+ Str(nLinha)+" 1 " })
	CT500RecnA(@lInConsist, @aRecnos, cArqTXT, aFiles )
 	//CONOUT("Final da gravação array: "+ time())
 	If lInConsist
 		lContinua := .F.
 	EndIf
Endif

If lContinua
	nHdlImp:=FOpen(cArqTXT,64)
	
	If nHdlImp == -1
		Help(" ",1,"NOFLEIMPOR")
		Return .F.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o N£mero do Lote                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLote := mv_par04
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ P.E. Manipula numero do Lote                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("CT500LOT")     
		cLote := ExecBlock("CT500LOT",.F.,.F.,cLote)
	Endif
	
	If Empty(cLote)
		Help(" ",1,"NOCT210LOT")
		Return .F.
		
	EndIf
	
	nTamArq:=FSeek(nHdlImp,0,2)
	FSeek(nHdlImp,0,0)
	ProcRegua(nTamArq)
	If ExCT500Lin
		lCT500Lin:=ExecBlock("CT500Lin",.F.,.F.)
	EndIf
	
	cFilAtu := cFilAnt //Filial Atual
	
	While nBytes < nTamArq
	   	If lAtureg
			IncProc()
		endIf	
		
		xBuffer	:= Space(nTamLinha)
		FREAD(nHdlImp,@xBuffer,nTamLinha)
		
		
		If lCT500Lin .and. Len(xBuffer) == nTamLinha .and. !SubStr(xBuffer, Len(xBuffer)-1, 2) $ cCRLF
			MsgStop( cMensagem , OEMTOANSI(STR0001) )	//"Contabiliza‡„o de Arquivos TXT"
			lHead	:= .F.
			lRet	:= .F.
			Exit 	
		EndIf  
		
		If mv_par07 == 2 //Sem ser Por Filial
			cPadrao	:= SubStr(xBuffer,1,3)
			lPadrao	:= Ct500VerPadrao(cPadrao)	
			IF lPadrao	
				IF !lHead
					lHead := .T.
					nHdlPrv:=HeadProva(cLote,"CTBA500",Substr(cUsuario,7,6),@cArquivo)
				End				
			
				nTotal += DetProva(nHdlPrv,cPadrao,"CTBA500",cLote,,,,,,aCT5)
		
				If mv_par05 == 1 // Cada linha contabilizada sera um documento
					
					RodaProva(nHdlPrv,nTotal)
		
					If ExistBlock("CT500PRV")
						ExecBlock("CT500PRV",.F.,.F.,{nTotal})
					Endif						
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Envia para Lan‡amento Contabil                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
					lDigita	:=IIF(mv_par01==1,.T.,.F.)
					lAglut 	:=IIF(mv_par02==1,.T.,.F.)
					cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
					lHead	:= .F.     
		
					If ExistBlock("CT500ARQ")     
						ExecBlock("CT500ARQ",.F.,.F.)
					Endif
		
				Endif
			Else
				lRet := .F.
			Endif		
	
		Else // mv_par07 = 1 ->Por Filial				
			cFil := AllTrim(SubStr(xBuffer,1,12)) //Filial do Arquivo
			lFil := !Empty(GetAdvFval("SM0", "M0_CODFIL", cEmpAnt+cFil, 1, ""))
			If lFil
				cPadrao	:= SubStr(xBuffer,13,3)
			Else
			 	If Empty(cFilArq) //Verifica se existe filial pendente para contabilização
					lRet := .F.
			 		Exit
				Endif
			Endif
	
			If lRet		
				If cFil <> cFilArq .Or. mv_par05== 1 
					cFilArq := cFil
					If cFil <> cFilArq
						aCt5 := {}
					EndIf
					If nHdlPrv > 0
						RodaProva(nHdlPrv,nTotal)
						lDigita	:=IIF(mv_par01==1,.T.,.F.)
						lAglut 	:=IIF(mv_par02==1,.T.,.F.)
						xBufferOld := xBuffer
						cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
						xBuffer := xBufferOld
						lHead	:= .F.     		
					EndIf
					
					If lFil
						cFilAnt := cFil
					Else
						lRet := .F.
						Exit	
					EndIf
					
					lPadrao := Ct500VerPadrao(cPadrao)
					If !lPadrao
						lRet := .F.
						Exit
					Endif
					If !lHead
						lHead := .T.									
						nTotal := 0
						nHdlPrv:=HeadProva(cLote,"CTBA500",Substr(cUsuario,7,6),@cArquivo)
					EndIf
				Endif
	
				nTotal += DetProva(nHdlPrv,cPadrao,"CTBA500",cLote,,,,,,aCT5) //Inclui uma Linha
				
				//Fim de Arquivo
				If (nBytes+nTamLinha) > nTamArq
					RodaProva(nHdlPrv,nTotal)
					lDigita	:=IIF(mv_par01==1,.T.,.F.)
					lAglut 	:=IIF(mv_par02==1,.T.,.F.)
					cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
					lHead	:= .F. 
				EndIf
			Endif
		EndIf
	
		nBytes+=nTamLinha
	
	EndDo
	
	FClose(nHdlImp)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Rodape                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lHead
		RodaProva(nHdlPrv,nTotal)
	
		If ExistBlock("CT500PRV")
			ExecBlock("CT500PRV",.F.,.F.,{nTotal})
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia para Lan‡amento Cont bil                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lDigita := IIF(mv_par01==1,.T.,.F.)
		lAglut  := IIF(mv_par02==1,.T.,.F.)
		cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
	Endif
	
	cFilAnt := cFilAtu
Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb500Nome
Data e Hora.
@author Kaique Schiller
@since 23/04/2015
@version 12
/*/
//-------------------------------------------------------------------

Static Function Ctb500Nome(cArqui)

Local cNome   := ""
Local nCasa	  := 0
Local cTime   := Time()
Local cHora	  := SubStr(cTime, 1, 2)
Local cMin	  := SubStr(cTime, 4, 2)
Local cData	  := dTos(Date())
Local cDtHora := cData+cHora+cMin

Default cArqui := ""

nCasa := Len(cArqui)-4

cNome := Substr(cArqui,1,nCasa)+cDtHora+".txt"

Return cNome

//-------------------------------------------------------------------
/*/{Protheus.doc} '
Envia E-mail.
@author Kaique Schiller
@since 23/04/2015
@version 12
/*/
//-------------------------------------------------------------------

Function Ctb500EnWf(cEventID,cMensagem,cTitulo,cDtIni,cDtFim,cHrIni,cHrFim)
Local cDataIn 	:= cValtoChar(cDtIni)
Local cDataFi	:= cValtoChar(cDtFim)
Local cHoraIn	:= cValtoChar(cHrIni)
Local cHoraFi	:= cValtoChar(cHrFim)
Default cEventID	:= "060"
Default cMensagem 	:=  Ctb500Html(cDataIn,cDataFi,cHoraIn,cHoraFi)
Default cTitulo 	:= STR0011 //"Aviso de Processamento de Contabilização TXT"

EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,cTitulo,cMensagem)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb500SX1
Converte os parametros do SX1 para caractere
@author Kaique Schiller
@since 23/04/2015
@version 12
/*/
//-------------------------------------------------------------------

Static Function Ctb500SX1(cPergunta)
Local aArea       := GetArea()
Local aAreaSX1    := SX1->(GetArea())
Local aRetorno    := {}
Local cMvPar	  := ""
Default cPergunta := "CTB500" 

Pergunte(cPergunta, .F.)

DbSelectArea("SX1")

SX1->(DbSetOrder(1))
SX1->(DbSeek(cPergunta))

While SX1->(!Eof()) .And. SX1->X1_GRUPO == Padr(cPergunta,Len(X1_GRUPO),' ')
      If ValType( &("MV_PAR"+SX1->X1_ORDEM) ) == "C"
		Aadd(aRetorno,{ '<br> '+PadR( SX1->X1_PERGUNT, 30 ) + " : " + &("MV_PAR"+SX1->X1_ORDEM)})
      ElseIf ValType( &("MV_PAR"+SX1->X1_ORDEM) ) == "D"
		Aadd(aRetorno,{ '<br> '+PadR( SX1->X1_PERGUNT, 30 ) + " : " + DToC( &("MV_PAR"+SX1->X1_ORDEM))})
      ElseIf ValType( &("MV_PAR"+SX1->X1_ORDEM) ) == "N"
		If SX1->X1_GSC == "C"
			cMvpar := Alltrim(Str( &("MV_PAR"+SX1->X1_ORDEM)))
			cMvpar := &("SX1->X1_DEF0"+cMvpar)			
			Aadd(aRetorno,{ '<br> '+PadR( SX1->X1_PERGUNT, 30 ) + " : " + cMvpar })
		Else
			Aadd(aRetorno,{ '<br> '+PadR( SX1->X1_PERGUNT, 30 ) + " : " + Str( &("MV_PAR"+SX1->X1_ORDEM) )})
		Endif

      EndIf
SX1->( DbSkip() )

EndDo

RestArea(aAreaSX1)
RestArea(aArea)

Return(aRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb500Html
Gera o Html.
@author Kaique Schiller
@since 23/04/2015
@version 12
/*/
//-------------------------------------------------------------------

Static Function Ctb500Html(cDtIni,cDtFim,cHrIni,cHrFim)

Local cHtml		:= ""
Local nX 		:= 0
Local aParam	:= {}
Local cUser		:= RetCodUsr()

cUser  := If(cUser <> Nil,UsrFullName(cUser),"")
aParam := Ctb500SX1("CTB500")

cHtml := '<html><body><font face="Arial"><br>'
cHtml += '<br> ' + STR0015 +cDtIni //"Data Inicio: " 
cHtml += '<br> ' + STR0016 +cHrIni //"Hora Inicio: "	
cHtml += '<br> ' + STR0017 +cDtFim //"Data Fim: "
cHtml += '<br> ' + STR0018 +cHrFim //"Hora Fim: "
cHtml += '<br><p align=center > ' + STR0019 + ' </p>' //" O Seguinte Processamento Foi Executado no Sitema. "
cHtml += '<hr style="width: 100%; height: 2px; font-family: Arial;">'
cHtml += STR0020 + cUser+'<br>' //" Usuário : "
cHtml += '<br>' + STR0021 //"Parâmetros "  
For nX := 1 To Len(aParam)
	cHtml += aParam[nX][1]
Next
cHtml += '<br><br>'
cHtml += '<table style="text-align: left; width: 100%;" border="0" cellpadding="2" cellspacing="1"><tbody>'
cHtml += '<tr style="font-family: Arial;"><th valign="center" style="background-color: gray; font-weight: bold; color: white;"><small>'
cHtml += '</font></font></body></html>'

Return cHtml
//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb500Ok
Perguntas.
@author Kaique Schiller
@since 23/04/2015
@version 12
/*/
//-------------------------------------------------------------------

Static Function Ctb500Ok()
Local lRet      := .F.
Local cPath     := MV_PAR03
Local cTpnt     :=":"

Pergunte("CTB500",.f.)

//Quando é SmartHtml não será possível acesso ao disco local 
//foi comentado pois após atualização do binário não se faz necessário realizar a validação
// If (__lSmtHTML)
// 	If (FOpen(cPath,64) == 0) .Or. (File(cPath) .And. (cTpnt $ cPath) .And. (FOpen(cPath,64) > 0))
// 		MsgInfo (STR0023)
// 		Return .F.
// 	EndIf
// EndIf

If MV_PAR08 == 1
	If MsgYesNo(STR0012+AllTrim(MV_PAR03)+ STR0013) //STR0012 "Será processado o arquivo " STR0013 ". Confirma? " 
		lRet := .T.						
	Endif
Else
	If MsgYesNo(STR0014) //"Serão processados os arquivos contidos na pasta interna. Confirma?" 
		lRet := .T.
	Endif
Endif

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CT500Recno  ³ Autor ³                   ³ Data ³  09/01/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o recno do alias gravado no Txt existe na tabela ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA500()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Function CT500Recno(lInConsist)
Local nBytes		:=0
Local nHdlImp
Local nTamArq
Local nTamLinha		:= Iif(Empty(mv_par06),512,mv_par06)
Local lContinua		:= .T.
Local lCTB500VLD	:= ExistBlock("CTB500VLD")
Local cQuery		:= ""
Local lVldRecOri	:= .T.   //Criar Parametro SX1
Local cAliasVLD		:= ""
Local aCampos		:= {}
Local cLP_RECORI	:= ""
Local cLP_Buffer	:= ""
Local cFilCT5 		:= xFilial("CT5")
Local cTABORI 		:= ""
Local nTABREC 		:= 0
Local nLinha		:= 0

PRIVATE xBuffer := Space( nTamLinha )
Private aRotina := {	{ "","" , 0 , 1},;
						{ "","" , 0 , 2 },;
						{ "","" , 0 , 3 },;
						{ "","" , 0 , 4 } }
Private Inclui := .T.

Default lInConsist = .F.
//    SELECIONA LANÇAMENTOS COM ESTA CARACTERISTICA DE CT5_RECORI PREENCHIDO

cQuery := "SELECT CT5_LANPAD FROM "+RetSqlName("CT5")
cQuery += " WHERE CT5_FILIAL = '"+xFilial('CT5')+"' AND "
cQuery += " CT5_RECORI != ' ' AND D_E_L_E_T_ = ' ' "

cAliasVLD := Criatrab(,.F.)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVLD,.T.,.F.)

While (cAliasVLD)->(!EOF())
	cLP_RECORI += (cAliasVLD)->(CT5_LANPAD)
	cLP_RECORI += "|"
	(cAliasVLD)->(dbSkip())
EndDo
(cAliasVLD)->(dbCloseArea())

If !Empty(cLP_RECORI)
//    ***************************************
//     TRATAMENTO PARA CHAMADA DE PROCEDURE *
//    ***************************************
	__cArq1 := CriaTrab(, .F. )
	__cArq2 := CriaTrab(, .F. )
	aAdd(aCampos,{"LANPAD", "C", TamSx3("CT5_LANPAD")[1],0 } )
	aAdd(aCampos,{"TABORI", "C", 8,0 } )
	aAdd(aCampos,{"RECORI", "N", 10,0 } )
	aAdd(aCampos,{"LINHA", "N", 5,0 } )
	aAdd(aCampos,{"ERRO", "C", 1,0 } )
	MsCreate( __cArq1, aCampos, "TOPCONN" )

//    ****************************************
//	  // Validação das linhas do arquivo	//
//    ****************************************
	nHdlImp:=FOpen(Mv_Par03,64)
	nTamArq:=FSeek(nHdlImp,0,2)
	FSeek(nHdlImp,0,0)
	dbUseArea(.T., "TOPCONN",__cArq1,__cArq2,.F.,.F.)
	
	While nBytes < nTamArq
		xBuffer	:= Space(nTamLinha)
		FREAD(nHdlImp,@xBuffer,nTamLinha)
		cLP_Buffer := SubStr(xBuffer,1,3)
		nLinha++
		If ( cLP_Buffer $ cLP_RECORI )
			cErro := ' '
			dbSelectArea("CT5")
			dbSetOrder(1)
			MsSeek(cFilCT5+cLP_Buffer)
			cTABORI := &(CT5->CT5_TABORI)
			nTABREC := Val(&(CT5->CT5_RECORI))
			(CTABORI)->(dbGoto(nTABREC))
			If (CTABORI)->(Eof())
				lInConsist := .T.
				cErro := 'S'
			endif
			
//			If cErro := 'S'
				RecLock(__cArq2,.T.)
				LANPAD 	:= cLP_Buffer
				TABORI	:= RetSqlName(cTABORI)
				RECORI	:= nTABREC
				LINHA	   := nLinha
				ERRO     := cErro
				msUnlock()
//			Endif
		Endif
		nBytes+=nTamLinha
	EndDo

	TcDelFile(__cArq1)
//    ****************************************
//    * FIM TRATAMENTO P/ CHAMADA  PROCEDURE *
//    ****************************************
Endif	
Return
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CT500RecnA ³ Autor ³                     ³ Data ³ 09/01/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o recno do alias gravado no Txt existe na tabela ³±±
±±³          ³ Caso nao exista grava em array para imprimir no final      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA500()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CT500RecnA(lInConsist, aRecnos, cFile, aFiles)
Local nBytes		:=0
Local nHdlImp
Local nTamArq
Local nTamLinha		:= Iif(Empty(mv_par06),512,mv_par06)
Local lContinua		:= .T.
Local lCTB500VLD	:= ExistBlock("CTB500VLD")
Local cQuery		:= ""
Local lVldRecOri	:= .T.   //Criar Parametro SX1
Local cAliasVLD		:= ""
Local aCampos		:= {}
Local cLP_RECORI	:= ""
Local cLP_Buffer	:= ""
Local cFilCT5 		:= xFilial("CT5")
Local cTABORI 		:= ""
Local nTABREC 		:= 0
Local nLinha		:= 0
Local nLinhaAux     := 0
Local aArea         := GetArea()
local nPosLP        := If(mv_par07 == 2,1,13)

PRIVATE xBuffer := Space( nTamLinha )
Private aRotina := {	{ "","" , 0 , 1},;
						{ "","" , 0 , 2 },;
						{ "","" , 0 , 3 },;
						{ "","" , 0 , 4 } }
Private Inclui := .T.

Default lInConsist := .F.
Default aRecnos    := {}
Default cFile      := ""
Default aFiles     := {}

//SELECIONA LANÇAMENTOS COM ESTA CARACTERISTICA DE CT5_RECORI PREENCHIDO

cQuery := "SELECT CT5_LANPAD FROM "+RetSqlName("CT5")
cQuery += " WHERE CT5_FILIAL = '"+xFilial('CT5')+"' AND "
cQuery += " CT5_RECORI != ' ' AND D_E_L_E_T_ = ' ' "

cAliasVLD := Criatrab(,.F.)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVLD,.T.,.F.)

While (cAliasVLD)->(!EOF())
	cLP_RECORI += (cAliasVLD)->(CT5_LANPAD)
	cLP_RECORI += "|"
	(cAliasVLD)->(dbSkip())
EndDo
(cAliasVLD)->(dbCloseArea())

If !Empty(cLP_RECORI)
//    ****************************************
//	  * Validação das linhas do arquivo		 *
//    ****************************************
	nHdlImp:=FOpen(cFile,64) //nHdlImp:=FOpen(Mv_Par03,64)
	nTamArq:=FSeek(nHdlImp,0,2)
	FSeek(nHdlImp,0,0)
	
	While nBytes < nTamArq
		cErro := ' '
		xBuffer	:= Space(nTamLinha)
		FREAD(nHdlImp,@xBuffer,nTamLinha)
		cLP_Buffer := SubStr(xBuffer,nPosLp,3)
		nLinha++
		If ( cLP_Buffer $ cLP_RECORI )
			dbSelectArea("CT5")
			dbSetOrder(1)
			If MsSeek(cFilCT5+cLP_Buffer)
				cTABORI := ""
				nTABREC := 0
	
				If !Empty(Alltrim(CT5->CT5_TABORI))
					cTABORI := &(CT5->CT5_TABORI)
				EndIf
				
				If !Empty(Alltrim(CT5->CT5_RECORI))
					nTABREC := Val(&(CT5->CT5_RECORI))
				EndIf
    	
				If nTABREC > 0 .And. !Empty(cTABORI)
					(CTABORI)->(dbGoto(nTABREC))
					If (CTABORI)->(Eof())
						lInConsist := .T.
						cErro := 'S'
					endif
				else
					lInConsist := .T.
					cErro := 'S'
				EndIf
			
				If cErro == 'S'

					nLinhaAux ++

					If nLinhaAux <= 5000
//						                1234^678901234^678901234^678901234^678901234^678901234^678901234^678901234^678901234^678901234^67890
//						                          1         2         3         4         5         6         7         8         9
//						                XXX             XXX                      9999999999                   9999999999  
//						                Lacto Pad       Tabela Orig              Recno                        Linha txt   Erro -> recno não existe na tabela origem
//								                                                                                                  -> Lancto padrao Não existe
                        	

						aadd( aRecnos, { "         "+cLP_Buffer+"  "+ RetSqlName(cTABORI)+" "+ Padl(nTABREC,10)+"  "+ Padl(nLinha,10)+"  Recno não existe na tabela origem "+ cFile})
    	
					else
						If Len(aFiles) = 1
							MsgAlert("Recnos Inconsistentes","Existem mais de 5.000 linhas com erro. Serão impressos no máximo 50.000 linhas")
							Exit					
						EndIf
					EndIf
					
                EndIf
                
			else

				lInConsist := .T.
				cErro := 'S'

				nLinhaAux ++
				If nLinhaAux <= 5000
					aadd( aRecnos, { "         "+cLP_Buffer+"  "+ RetSqlName(cTABORI)+" "+ Padl(nTABREC,10)+"  "+ Padl(nLinha, 10)+"  Não existe lancto padrao: "+cLP_Buffer + " "+cFile})
				else
					If Len(aFiles) = 1
						MsgAlert("Recnos Inconsistentes","Existem mais de 5.000 linhas com erro. Serão impressos no máximo 50.000 linhas")
						Exit
					EndIf					
				EndIf

			Endif       
		Endif
		nBytes+=nTamLinha
	EndDo
	FClose(nHdlImp)	
Endif
RestArea(aArea)	
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ctba500  ºAutor  ³Microsiga           º Data ³       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct500Out(aTxt)
Local cPict          := ""
Local imprime        := .T.

Private cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Private cDesc2       := "com o RECNOS incosistentes no Processamento."
Private cDesc3       := "RECNOS incosistentes Processamento"
Private titulo       := "RECNOS incosistentes do Processamento"
Private nLin         := 80

Private Cabec1       := "Recnos Inconsistentes"
//              Lacto Pad   tabela orig           Recno    linha do txt  com erro
//					aadd( aRecnos, { "Lcto pad: "+cLP_Buffer+" -Tabela: "+ RetSqlName(cTABORI)+" -Recno: "+ Alltrim(Str(  nTABREC))+" -Linha do txt: "+ Str(nLinha) })
Private Cabec2       :=  "Lacto_Padrao  Tabela      Recno   Linha_Txt  Erro e Arquivo Origem" 
Private aOrd         := {}
Private lEnd         := .F.
Private limite       := 220
Private tamanho      := "M"
Private nomeprog     := "CTBA500" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 10
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}///"Administracao"
Private nLastKey     := 0
Private cPerg        := "CONOUTR"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 1
Private wnrel        := "CONOUTR"//+ALLTRIM(cUserName)//Coloque aqui o nome do arquivo usado para impressao em disco
Private nOrdem       := 1
Private cString      := "CT1"

dbSelectArea( "CT1" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

  SetDefault( aReturn , cString ,,,"M" , 2 ) 

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,10,15)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|lEnd| RnCt500Out(lEnd,WnRel,cString,nOrdem,aTxt)},Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RunCtROut º Autor ³ AP6 IDE            º Data ³  17/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RnCt500Out(lEnd,WnRel,cString,nOrdem,aTxt)

Local nTxt

dbSelectArea(cString)
dbSetOrder(1)
SetRegua(RecCount())

//AjSX1Fcont( "CTRFCONT" )
//Pergunte("CTRFCONT", .F.)

For nTxt := 1 to Len(aTxt)

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lEnd
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 59 // Salto de Página. Neste caso o formulario tem 59 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif
	/*               1234^678901234^678901234^678901234^678901234^678901234^678901234^678901234^678901234^678901234^67890
	                          1         2         3         4         5         6         7         8         9
	                 XXX             XXX                      9999999999                   9999999999  1/2
	                 Lacto Pad       Tabela Orig              Recno                        Linha txt   Erro -> 1 recno não existe na tabela origem
			                                                                                                    -> 2 Lancto padrao Não existe*/	
   @nLin,00 PSAY aTxt[nTxt][1]
	nLin := nLin + 1 // Avanca a linha de impressao
Next
              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Ct500VerPadrao
Rotina auxiliar para cachear a funcao VerPadrao

@author TOTVS
@since 29/06/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function Ct500VerPadrao(cPadrao)
Local lPadrao
Local nPosPadrao := 0

If __aVerPad == NIL
	__aVerPad := {}
EndIf

nPosPadrao  := aScan(__aVerPad,{ |x| x[1] == cEmpAnt .And. x[2] == cFilAnt .And. x[3] == cPadrao  })

If nPosPadrao > 0
	lPadrao := __aVerPad[ nPosPadrao, 4 ]
Else
	lPadrao := VerPadrao(cPadrao)
	aAdd( __aVerPad, { cEmpAnt, cFilAnt, cPadrao, lPadrao })
EndIf

Return(lPadrao)