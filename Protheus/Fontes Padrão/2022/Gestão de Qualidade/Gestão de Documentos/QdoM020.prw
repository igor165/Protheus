
#INCLUDE "PROTHEUS.CH"
#INCLUDE "QDOM020.CH"
#INCLUDE "COLORS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QDOM020    ³ Autor ³ Eduardo de Souza ³ Data ³ 21/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ View de Consistencia / Status Parametros                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDOM020()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ SIGAQDO - Controle de Documentos                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³Programador ³                Alteracao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³10/04/02³ META ³ Eduardo S. ³ Alteracao na utilizacao dos arquivos de  ³±±
±±³        ³      ³            ³ Usuarios conforme novo conceito do Qualit³±±
±±³13/08/02³ ---- ³ Eduardo S. ³ Inclusao da Filial do Usuario no teste de³±±
±±³        ³      ³            ³ envio do email.                          ³±±
±±³22/08/02³ ---- ³ Eduardo S. ³ Acerto para apresentar somente usuarios  ³±±
±±³        ³      ³            ³ referente a filial selecionada no email. ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOM020()

Local oDlg        
Local oScroll01
Local oPanel01
Local oBtnEmail
Local oBtnDet
Local oBtnImp
Local oDetalhe
Local oBtn
Local cOK     := "CHECKED"
Local cErro   := "NOCHECKED"
Local cDetalhe:= ""
Local lTudoOk := .t.
Local aQPath   	:= QDOPATH()
Local cQPathTrm	:= aQPath[3]

Private lDotPadr := .f.
Private lWordView:= .f.
Private lPath    := .f.
Private lMSWord  := .f.
Private lSolic   := .f.
Private lDoctoCel:= .f.
Private lTpDocto := .f.
Private lUsrLog  := .f.
Private lEmail   := .f.
Private lMigraQDO:= .f.
Private lBseInt	 := .T.
Private aDetalhes:= {}
Private aUsrMat  := QA_USUARIO()
Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]
Private cFilMat  := xFilial("QAA")
Private nQaConpad:= 1
Private LI := 0

MsgRun( OemToAnsi( STR0016 ), OemToAnsi( STR0015 ), { || QDM020Proc(@lTudoOk) } ) //"Verificando Consistencia de Dados" ### "Aguarde..."

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 000,000 TO 425,623 OF oMainWnd PIXEL // "Status Gerais"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Panel                                                  ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
oPanel:= tSay():New(,,,oDlg)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

oScroll01:= TScrollBox():new(oPanel,003,003, 112,308,.T.,.T.,.T.)

@ 000,000 MSPANEL oPanel01 PROMPT "" COLOR CLR_WHITE,RGB( 200,230,247 ) SIZE 306,010 OF oScroll01
@ 001,002 SAY OemToAnsi(STR0006) SIZE 145,010 COLOR CLR_BLACK 	OF oPanel01 PIXEL	// "WordView"
@ 000,280 BITMAP oBtn RESOURCE If(lWordView,cOk,cErro) NOBORDER SIZE 015,014  OF oPanel01 PIXEL

@ 010,000 MSPANEL oPanel01 PROMPT "" COLOR CLR_WHITE,CLR_WHITE SIZE 306,010 OF oScroll01
@ 001,002 SAY OemToAnsi(STR0007) SIZE 145,010 COLOR CLR_BLACK 	OF oPanel01 PIXEL	// "Diretorios"
@ 000,280 BITMAP oBtn RESOURCE If(lPath,cOk,cErro) NOBORDER SIZE 015,014  OF oPanel01 PIXEL

@ 020,000 MSPANEL oPanel01 PROMPT "" COLOR CLR_WHITE,RGB( 200,230,247 ) SIZE 306,010 OF oScroll01
@ 001,002 SAY OemToAnsi(STR0005) SIZE 145,010 COLOR CLR_BLACK OF oPanel01 PIXEL //"Modelo de Documento Padrao"
@ 000,280 BITMAP oBtn RESOURCE If(lDotPadr,cOk,cErro) NOBORDER SIZE 015,014  OF oPanel01 PIXEL

@ 030,000 MSPANEL oPanel01 PROMPT "" COLOR CLR_WHITE,CLR_WHITE SIZE 306,010 OF oScroll01
@ 001,002 SAY OemToAnsi(STR0009) SIZE 145,010 COLOR CLR_BLACK 	OF oPanel01 PIXEL	// "Solicitacao de Documentos"
@ 000,280 BITMAP oBtn RESOURCE If(lSolic,cOk,cErro) NOBORDER SIZE 015,014  OF oPanel01 PIXEL

@ 040,000 MSPANEL oPanel01 PROMPT "" COLOR CLR_WHITE,RGB( 200,230,247 ) SIZE 306,010 OF oScroll01
@ 001,002 SAY OemToAnsi(STR0010) SIZE 145,010 COLOR CLR_BLACK 	OF oPanel01 PIXEL	// "Documentos"
@ 000,280 BITMAP oBtn RESOURCE If(lDoctoCel,cOk,cErro) NOBORDER SIZE 015,014  OF oPanel01 PIXEL

@ 050,000 MSPANEL oPanel01 PROMPT "" COLOR CLR_WHITE,CLR_WHITE SIZE 306,010 OF oScroll01
@ 001,002 SAY OemToAnsi(STR0011) SIZE 145,010 COLOR CLR_BLACK 	OF oPanel01 PIXEL	// "Tipo de Documento"
@ 000,280 BITMAP oBtn RESOURCE If(lTpDocto,cOk,cErro) NOBORDER SIZE 015,014  OF oPanel01 PIXEL

@ 060,000 MSPANEL oPanel01 PROMPT "" COLOR CLR_WHITE,RGB( 200,230,247 ) SIZE 306,010 OF oScroll01
@ 001,002 SAY OemToAnsi(STR0012) SIZE 145,010 COLOR CLR_BLACK 	OF oPanel01 PIXEL	// "Usuario Logado"
@ 000,280 BITMAP oBtn RESOURCE If(lUsrLog,cOk,cErro) NOBORDER SIZE 015,014  OF oPanel01 PIXEL

@ 070,000 MSPANEL oPanel01 PROMPT "" COLOR CLR_WHITE,CLR_WHITE SIZE 306,010 OF oScroll01
@ 001,002 SAY OemToAnsi(STR0013) SIZE 145,010 COLOR CLR_BLACK 	OF oPanel01 PIXEL	// "Teste e-mail"
@ 000,280 BITMAP oBtn RESOURCE If(lEmail,cOk,cErro) NOBORDER SIZE 015,014  OF oPanel01 PIXEL
@ 001,050 BUTTON oBtnEmail PROMPT OemToAnsi(STR0083) SIZE 040, 009 OF oPanel01 PIXEL;  // "E-mail"
				ACTION QDM020Email(oDlg)

@ 080,000 MSPANEL oPanel01 PROMPT "" COLOR CLR_WHITE,RGB( 200,230,247 ) SIZE 306,010 OF oScroll01
@ 001,002 SAY OemToAnsi(STR0014) SIZE 145,010 COLOR CLR_BLACK 	OF oPanel01 PIXEL	// "Configuracao de Conversao"
@ 000,280 BITMAP oBtn RESOURCE If(lMigraQDO,cOk,cErro) NOBORDER SIZE 015,014  OF oPanel01 PIXEL

@ 090,000 MSPANEL oPanel01 PROMPT "" COLOR CLR_WHITE,CLR_WHITE SIZE 306,010 OF oScroll01
@ 001,002 SAY OemToAnsi(STR0008) SIZE 145,010 COLOR CLR_BLACK 	OF oPanel01 PIXEL	// "Microsoft Word"
@ 000,280 BITMAP oBtn RESOURCE If(lMSWord,cOk,cErro) NOBORDER SIZE 015,014  OF oPanel01 PIXEL
				
@ 100,000 MSPANEL oPanel01 PROMPT "" COLOR CLR_WHITE,RGB( 200,230,247 ) SIZE 306,010 OF oScroll01
@ 001,002 SAY STR0091 SIZE 145,010 COLOR CLR_BLACK 	OF oPanel01 PIXEL //"Integridade Base"
@ 000,280 BITMAP oBtn RESOURCE If(lBseInt,cOk,cErro) NOBORDER SIZE 015,014  OF oPanel01 PIXEL
If ! lBseInt
	@ 001,050 	BUTTON oBtnInt PROMPT STR0092 SIZE 040, 009 OF oPanel01 PIXEL; //"Mostra Log"
				ACTION WinExec("NOTEPAD "+cQPathTrm+"LOGQLY.TXT")
Endif				
				
@ 117,226 BUTTON oBtnImp PROMPT OemToAnsi(STR0077) SIZE 040, 010 OF oPanel PIXEL;  // "Imprimir Det."
				ACTION QDM020ImpDet()
If lTudoOk
	oBtnImp:Disable()
EndIf								

@ 117,271 BUTTON oBtnDet PROMPT OemToAnsi(STR0004) SIZE 040, 010 OF oPanel PIXEL; // "Detalhes"
			ACTION QDM020DET(@cDetalhe)
If lTudoOk
	oBtnDet:Disable()
EndIf				

@ 128, 003 GET oDetalhe VAR cDetalhe MEMO NO VSCROLL SIZE 308, 050 OF oPanel PIXEL
oDetalhe:lReadOnly:= .t.

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End()},{|| oDlg:End()})
													   
If File(cQPathTrm+"LOGQLY.TXT")
	Ferase(cQPathTrm+"LOGQLY.TXT")
Endif
				
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QDM020Proc ³ Autor ³ Eduardo de Souza ³ Data ³ 23/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Verfica consistencias                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDM020Proc(ExpL1)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpL1 - .T. para todos os itens OK                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOM020.PRW                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDM020Proc(lTudoOk)

Local nHandle   := 0
Local aQPath    := QDOPATH()
Local cQPath    := aQPath[1]
Local cQPathD   := aQPath[2]
Local cQPathTrm := aQPath[3]
Local cQPathHtm := aQPath[5]
Local cDotPadr  := aQPath[4]
Local cPathView := aQPath[6]
Local cUsaView  := aQPath[7]
Local lQPath    := .f.
Local lQPathD   := .f.
Local lQPathTrm := .f.
Local lQPathHtm := .f.
Local cStartPath:= ""
Local cChkWord  := "0" // Word nao verificado
Local nPosQAA   := QAA->(RecNo())
Local nOrdQAA   := QAA->(IndexOrd())
Local nPosQDH   := QDH->(RecNo())
Local nOrdQDH   := QDH->(IndexOrd())
Local nPosQD2   := QD2->(RecNo())
Local nOrdQD2   := QD2->(IndexOrd())
Local cUser     := ""
Local aRet      := {}
Local aDocsCel	 := {}
Local aDocsDot  := {}
Local cApelido  := ""
Local cEmail    := ""
Local lDistSN   := .f.
Local lNew      := .t.
Local aDistSN   := {}
Local nCnt		 := 0
Local nErro     := 0
Local nTotErro  := 0
Local lError    := .f.
Local cPulaLinha:= Chr(13)+Chr(10)
Local cRecMail  := ""
Local cSubject  := ""
Local cMsg      := ""
Local cAttach   := ""
Local aMsg      := {}
Local aUsrMail  := {}
Local nHdl 		:= 0
Local nTamId 	:= 0
Local cFilQad	:= ""
Local aLog		:= {}
Local cId		:= ""
Local lChkQdr	:= .F.
Local cAliasQry	:= ""
Local nLog
Local aArea		:= GetArea()
Local cPerm     := "N"

DbSelectArea("QDH")
DbSetOrder(1)
DbSelectArea("QD2")
DbSetOrder(1)

cStartPath := GetPvProfString( GetEnvServer(), "StartPath", "ERROR", GetADV97() )
cStartPath += IIF( RIGHT(cStartPath,1) != "\", "\", "" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³WordView							            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lError:= .f.
nErro:= 0
If Empty(cUsaView)
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0006)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0026)+" "+OemToAnsi(STR0020)+" "+OemToAnsi(STR0027)+cPulaLinha}) // "Descricao" ### "O conteudo do Parametro" ### "MV_QDVIEW" ### "nao esta preenchido"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0022)	+cPulaLinha}) // "Solucao" ### "Para utilizar o WordView para consultar os Documentos gerados pelo Sistema, preencha o conteudo do parametro com (S)"	
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0049)+cPulaLinha}) //"parametro com (S)"	
	lError:= .t.
ElseIf cUsaView == "S"
	If Empty(cPathView)
		nErro++
		nTotErro++
		Aadd(aDetalhes,{OemToAnsi(STR0006)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0026)+" "+OemToAnsi(STR0033)+" "+OemToAnsi(STR0027)+cPulaLinha}) // "Descricao" ### "O conteudo do Parametro" ### "MV_QDPVIEW" ### "nao esta preenchido"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0037)+" "+OemToAnsi(STR0028)	+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do Parametro com o Diretorio(Caminho) onde foi instalado o WordView na Estacao Local"
		lError:= .t.
	Else
		cPathView:= If(RIGHT(cPathView,1)<>"\",cPathView+"\",cPathView)
		If At(" ",Alltrim(cPathView)) != 0 
			nErro++
			nTotErro++
			Aadd(aDetalhes,{OemToAnsi(STR0006)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
			Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0029)+" "+cPathView+" "+OemToAnsi(STR0030)+" "+OemToAnsi(STR0033)+cPulaLinha}) // "Descricao" ### "O Diretorio" ### "preenchido no conteudo do Parametro" ### "MV_QDPVIEW" ### "nao e um diretorio valido"
			Aadd(aDetalhes,{"  "+OemToAnsi(STR0031)+cPulaLinha}) // "nao e um diretorio valido"
			Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0105)+cPulaLinha})  //"Solucao" //"Instale o WordView um diretorio/pasta sem 'espacos' no Nome Exemplo C:\WordView"
			lError:= .t.		
		Endif
		nHandle := fCreate(cPathView+"TESTE")	// Tenta Criar arquivo teste para ver se diretorio existe
		If nHandle == -1  // Nao Consegui criar arquivo no diretorio
			nErro++
			nTotErro++
			Aadd(aDetalhes,{OemToAnsi(STR0006)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
			Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0029)+" "+cPathView+" "+OemToAnsi(STR0030)+" "+OemToAnsi(STR0033)+cPulaLinha}) // "Descricao" ### "O Diretorio" ### "preenchido no conteudo do Parametro" ### "MV_QDPVIEW" ### "nao e um diretorio valido"
			Aadd(aDetalhes,{"  "+OemToAnsi(STR0031)+cPulaLinha}) // "nao e um diretorio valido"
			Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0037)+" "+OemToAnsi(STR0028)	+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do Parametro com o Diretorio(Caminho) onde foi instalado o WordView na Estacao Local"
			lError:= .t.		
		Else
			fClose(nHandle)
			fErase(cPathView+"TESTE")
			If !File(cPathView+"WORDVIEW.EXE")
				nErro++
				nTotErro++
				Aadd(aDetalhes,{OemToAnsi(STR0006)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
				Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0029)+" "+cPathView+" "+OemToAnsi(STR0030)+" "+OemToAnsi(STR0033)+" "+OemToAnsi(STR0032)+cPulaLinha}) // "Descricao" ### "O Diretorio" ### "preenchido no conteudo do Parametro" ### "MV_QDPVIEW" ### "nao e o diretorio correto"
				Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0037)+" "+OemToAnsi(STR0028)	+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do Parametro com o Diretorio(Caminho) onde foi instalado o WordView na Estacao Local"
				lError:= .t.				
			EndIf
	   	EndIf	   		   	
	EndIf
Else
	Aadd(aDetalhes,{OemToAnsi(STR0006)+": "+cPulaLinha}) // "WordView"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0021)	+cPulaLinha}) // "Descricao" ### "O conteudo do Parametro MV_QDVIEW esta preenchido com (N) - WordView nao sera usado para consultar os documentos gerados pelo sistema)"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0048)+cPulaLinha}) // "os documentos gerados pelo sistema)"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0022)	+cPulaLinha})  //"Solucao" ### "Para utilizar o WordView para consultar os Documentos gerados pelo Sistema, preencha o conteudo do parametro com (S)"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0049)+cPulaLinha}) //"parametro com (S)"	
	lTudoOk:= .f.
EndIf

If	!lError
	lWordView:= .t.	
	If cUsaView == "N"
		Aadd(aDetalhes,{Replicate( "-", 132 )+cPulaLinha}) // ----------
	EndIf
Else 
	Aadd(aDetalhes,{OemToAnsi(STR0002)+" "+Alltrim(Str(nErro))+cPulaLinha}) // "Total de Erro(s):"
	Aadd(aDetalhes,{Replicate( "-", 132 )+cPulaLinha}) // ----------
	lTudoOk:= .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Diretorios						            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lError:= .f.
nErro:= 0
If Empty(cQPath) // Diretorio dos Documentos .CEL 
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0007)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0026)+" "+OemToAnsi(STR0034)+" "+OemToAnsi(STR0027)+cPulaLinha}) // "Descricao" ### "O conteudo do Parametro" ### "MV_QPATHW" ### "nao esta preenchido"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0037)+" "+OemToAnsi(STR0038)+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do Parametro com o diretorio" ### ### "dos Documentos .CEL"
	lError:= .t.
Else
	cQPath:= If(RIGHT(cQPath,1)<>"\",cQPath+"\",cQPath)
	nHandle := fCreate(cQPath+"TESTE")	// Tenta Criar arquivo teste para ver se diretorio existe
	If nHandle == -1  // Nao Consegui criar
		nErro++
		nTotErro++
		Aadd(aDetalhes,{OemToAnsi(STR0007)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0029)+" "+cQPath+" "+OemToAnsi(STR0030)+" "+OemToAnsi(STR0034)+cPulaLinha}) // "Descricao" ### "O Diretorio" ### "preenchido no conteudo do Parametro" ### "MV_QPATHW" ### "nao e um diretorio valido"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0031)+cPulaLinha}) // "nao e um diretorio valido"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0037)+" "+OemToAnsi(STR0038)+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do Parametro com o diretorio" ### ### "dos Documentos .CEL"
		lError:= .t.		
   Else
		fClose(nHandle)
		fErase(cQPath+"TESTE")
   EndIf
EndIf

If !lError
 	lQPath:= .t.
EndIf

lError:= .f.
If Empty(cQPathD) // Diretorio dos Documentos Modelos
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0007)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0026)+" "+OemToAnsi(STR0035)+" "+OemToAnsi(STR0027)+cPulaLinha}) // "Descricao" ### "O conteudo do Parametro" ### "MV_QPATHWD" ### "nao esta preenchido"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0037)+" "+OemToAnsi(STR0039)+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do Parametro com o diretorio" ### "dos Modelos de Documentos .DOT"
	lError:= .t.
Else
	cQPathD:= If(RIGHT(cQPathD,1)<>"\",cQPathD+"\",cQPathD)
	nHandle := fCreate(cQPathD+"TESTE")	// Tenta Criar arquivo teste para ver se diretorio existe
	If nHandle == -1  // Consegui criar e vou fechar e apagar novamente...
		nErro++
		nTotErro++
		Aadd(aDetalhes,{OemToAnsi(STR0007)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0029)+" "+cQPathD+" "+OemToAnsi(STR0030)+" "+OemToAnsi(STR0035)+cPulaLinha}) // "Descricao" ### "O Diretorio" ### "preenchido no conteudo do Parametro" ### "MV_QPATHWD" ### "nao e um diretorio valido"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0031)+cPulaLinha}) // "nao e um diretorio valido"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0037)+" "+OemToAnsi(STR0039)+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do Parametro com o diretorio" ### "dos Modelos de Documentos .DOT"
		lError:= .t.		 
   Else
		fClose(nHandle)
		fErase(cQPathD+"TESTE")  				   
	EndIf
EndIf

If !lError
	lQPathD:= .t.
EndIf

lError:= .f.
If Empty(cQPathTrm) // Diretorio de Arquivos Temporarios
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0007)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0026)+" "+OemToAnsi(STR0036)+" "+OemToAnsi(STR0027)+cPulaLinha}) // "Descricao" ### "O conteudo do Parametro" ### "MV_QPATHT" ### "nao esta preenchido"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0037)+" "+OemToAnsi(STR0040)+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do Parametro com o diretorio ### "de Arquivos Temporarios"
	lError:= .t.
Else
	cQPathTrm:= If(RIGHT(cQPathTrm,1)<>"\",cQPathTrm+"\",cQPathTrm)
	nHandle := fCreate(cQPathTrm+"TESTE")	// Tenta Criar arquivo teste para ver se diretorio existe
	If nHandle == -1  // Consegui criar e vou fechar e apagar novamente...
		nErro++
		nTotErro++
		Aadd(aDetalhes,{OemToAnsi(STR0007)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0029)+" "+cQPathTrm+" "+OemToAnsi(STR0030)+" "+OemToAnsi(STR0036)+cPulaLinha}) // "Descricao" ### "O Diretorio" ### "preenchido no conteudo do Parametro" ### "MV_QPATHWT" ### "nao e um diretorio valido"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0031)+cPulaLinha}) // "nao e um diretorio valido"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0037)+" "+OemToAnsi(STR0040)+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do Parametro com o diretorio ### "de Arquivos Temporarios"
		lError:= .t.		
	Else
		fClose(nHandle)
		fErase(cQPathTrm+"TESTE")
   EndIf
EndIf
      
If !lError
	lQPathTrm:= .t.
EndIf

lError:= .f.
If Empty(cQPathHtm) // Diretorio de Arquivos Temporarios - HTML
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0007)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0026)+" "+OemToAnsi(STR0090)+" "+OemToAnsi(STR0027)+cPulaLinha}) // "Descricao" ### "O conteudo do Parametro" ### "MV_QPATHH" ### "nao esta preenchido"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0037)+" "+OemToAnsi(STR0040)+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do Parametro com o diretorio ### "de Arquivos Temporarios"
	lError:= .t.
Else
	cQPathHtm:= If(RIGHT(cQPathHtm,1)<>"\",cQPathHtm+"\",cQPathHtm)
	nHandle := fCreate(cQPathHtm+"TESTE")	// Tenta Criar arquivo teste para ver se diretorio existe
	If nHandle == -1  // Consegui criar e vou fechar e apagar novamente...
		nErro++
		nTotErro++
		Aadd(aDetalhes,{OemToAnsi(STR0007)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0029)+" "+cQPathHtm+" "+OemToAnsi(STR0030)+" "+OemToAnsi(STR0090)+cPulaLinha}) // "Descricao" ### "O Diretorio" ### "preenchido no conteudo do Parametro" ### "MV_QPATHWH" ### "nao e um diretorio valido"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0031)+cPulaLinha}) // "nao e um diretorio valido"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0037)+" "+OemToAnsi(STR0040)+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do Parametro com o diretorio ### "de Arquivos Temporarios"
		lError:= .t.
	Else
		fClose(nHandle)
		fErase(cQPathHtm+"TESTE")
   EndIf
EndIf
      
If !lError
	lQPathHtm:= .t.
EndIf

If lQPath .And. lQPathD .And. lQPathTrm .And. lQPathHtm
	lPath:= .t.
Else 
	Aadd(aDetalhes,{OemToAnsi(STR0002)+" "+Alltrim(Str(nErro))+cPulaLinha}) // "Total de Erro(s):"
	Aadd(aDetalhes,{Replicate( "-", 132 )+cPulaLinha}) // ----------
	lTudoOk:= .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Modelo de Documentos Padrao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lError:= .f.
nErro:= 0
If !lQPathD
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0005)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0041) +cPulaLinha}) // "Descricao" ### "Diretorio nao existe ou esta em Branco."
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0042) +cPulaLinha})  //"Solucao" ### "Veja detalhes da opcao (Diretorio)."
	lError:= .t.
EndIf

If Empty(cDotPadr)
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0005)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0026)+" "+OemToAnsi(STR0043)+" "+OemToAnsi(STR0027)+cPulaLinha}) // "Descricao" ### "O conteudo do Parametro" ### "MV_QDDOTPD" ### "nao esta preenchido"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0044)+cPulaLinha})  //"Solucao" ### "Preencha o conteudo do parametro com o nome do arquivo Modelo Padrao Ex.: ADVSIGA8.DOT"
	lError:= .t.
Else
	If !File(cQPathD+cDotPadr) .And. lQPathD
		nErro++
		nTotErro++
		Aadd(aDetalhes,{OemToAnsi(STR0005)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0045)+" "+cDotPadr+" "+OemToAnsi(STR0074)+" "+cQPathD+cPulaLinha}) // "Descricao" ### "O arquivo" ### "nao se encontra no diretorio"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0046)+" "+OemToAnsi(STR0047)+cPulaLinha})  //"Solucao" ### "Verifique se o diretorio definido no parametro MV_QPATHWD esta correto ou se o arquivo" ### "existe no diretorio"
		lError:= .t.				
 	EndIf
EndIf

If !lError
	lDotPadr:= .t.
Else 
	Aadd(aDetalhes,{OemToAnsi(STR0002)+" "+Alltrim(Str(nErro))+cPulaLinha}) // "Total de Erro(s):"
	Aadd(aDetalhes,{Replicate( "-", 132 )+cPulaLinha}) // ----------
	lTudoOk:= .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Solicitacao de Alteracao de Documentos  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lError:= .f.
nErro:= 0
PswUpper( .t. )
PswOrder( 2 )
If QAA->(DbSeek(xFilial("QAA")))
	While QAA->(!Eof()) .And. xFilial("QAA") == QAA->QAA_FILIAL
		cUser := QAA->QAA_LOGIN
		If !Empty(cUser) .And. QA_SitFolh()
			If PswSeek( cUser )
				aRet:= PswRet(2)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se usuario tem acesso para baixar Solicitacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF LEN(aRet) == 1
					cPerm := SubStr(aRet[1,5],92,1)
				ELSE
					cPerm := SubStr(aRet[2,5],92,1)
				ENDIF
				If cPerm == "S"
					lSolic:= .t.
					Exit
				EndIf		
			EndIf   
	   EndIf
		QAA->(DbSkip())
	EndDo
EndIf

If !lSolic
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0009)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0050)+cPulaLinha}) // "Descricao" ### "Nao foi encontrado nenhum responsavel com acesso a BAIXA SOLICITACOES"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0051)+cPulaLinha})  //"Solucao" ### "Para baixar solicitacoes e obrigatorio que pelo menos um usuario tenha acesso a Baixa Solicitacoes no Configurador."
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0052)+cPulaLinha})  //"cadastro de usuarios do Configurador."
	lError:= .t.
EndIf

If !lError
	lSolic:= .t.
Else 
	Aadd(aDetalhes,{OemToAnsi(STR0002)+" "+Alltrim(Str(nErro))+cPulaLinha}) // "Total de Erro(s):"
	Aadd(aDetalhes,{Replicate( "-", 132 )+cPulaLinha}) // ----------
	lTudoOk:= .f.
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Documentos                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lError:= .f.
nErro:= 0
If !lQPath
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0010)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0041) +cPulaLinha}) // "Descricao" ### "Diretorio nao existe ou esta em Branco."
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0042) +cPulaLinha})  //"Solucao" ### "Veja detalhes da opcao (Diretorio)."
	lError:= .t.
Else
	If QDH->(DbSeek(xFilial("QDH")))
		While QDH->(!Eof()) .And. xFilial("QDH") == QDH->QDH_FILIAL
			If !File(cQPath+QDH->QDH_NOMDOC) .And. QDH->QDH_STATUS <> "D  " .And. QDH->QDH_DTOIE <> "E"
				Aadd(aDocsCel,{QDH->QDH_DOCTO,QDH->QDH_RV,QDH->QDH_NOMDOC})
	      EndIf
	      QDH->(DbSkip())
	   EndDo
		QDH->(dbGoTo(nPosQDH))
		QDH->(dbSetOrder(nOrdQDH))
	
	   If Len(aDocsCel) > 0
			For nCnt:= 1 to Len(aDocsCel)
				nErro++
				nTotErro++
				Aadd(aDetalhes,{OemToAnsi(STR0010)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
				Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0053)+" "+Alltrim(aDocsCel[nCnt][3])+" "+OemToAnsi(STR0054)+" "+Alltrim(aDocsCel[nCnt][1])+cPulaLinha}) // "Descricao" ### "Nao foi encontrado o arquivo" ### "referente a Documento"
				Aadd(aDetalhes,{"  "+(STR0055)+" "+Alltrim(aDocsCel[nCnt][2])+" "+(STR0056)+" "+Alltrim(cQPath)+cPulaLinha}) // "Revisao" ### "no Diretorio"
				Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0057)+cPulaLinha})  //"Verifique se esta correto o diretorio ou se o arquivo existe"
				lError:= .t.		
			Next nCnt
	   EndIf
	EndIf		
EndIf

If !lError
  	lDoctoCel:= .t.
Else 
	Aadd(aDetalhes,{OemToAnsi(STR0002)+" "+Alltrim(Str(nErro))+cPulaLinha}) // "Total de Erro(s):"
	Aadd(aDetalhes,{Replicate( "-", 132 )+cPulaLinha}) // ----------
	lTudoOk:= .f.
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tipo de Documentos                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lError:= .f.
nErro:= 0
If !lQPathD
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0011)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0041) +cPulaLinha}) // "Descricao" ### "Diretorio nao existe ou esta em Branco."
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0042) +cPulaLinha})  //"Solucao" ### "Veja detalhes da opcao (Diretorio)."
	lError:= .t.
Else
	QAA->(DbSetOrder(2))
	If QD2->(DbSeek(xFilial("QDH")))
		While QD2->(!Eof()) .And. xFilial("QD2") == QD2->QD2_FILIAL
		  	If QAA->(DbSeek(QD2->QD2_FILDEP+QD2->QD2_DEPTO))
				While QAA->(!Eof()) .And. QD2->QD2_FILDEP+QD2->QD2_DEPTO == QAA->QAA_FILIAL+QAA->QAA_CC
		      	If QAA->QAA_DISTSN == "1"
		      		lDistSN:= .t.
		      		Exit
		      	EndIf
					QAA->(DbSkip())
				Enddo		
			EndIf     
			If !lDistSN
				If Len(aDistSN) > 0
					For nCnt:= 1 to Len(aDistSN)
						If aDistSN[nCnt] == QD2->QD2_DEPTO	
							lNew:= .f.
							Exit
						EndIf
					Next ncnt
				EndIf
				If lNew
					Aadd(aDistSN, QD2->QD2_DEPTO)
			   EndIf
			EndIf
			If (!Empty(QD2->QD2_MODELO) .and. !File(cQPathD+QD2->QD2_MODELO)) 
				Aadd(aDocsDot,{QD2->QD2_CODTP,QD2->QD2_MODELO })
		  	Elseif !Empty(QD2->QD2_MODELO).and. !File(cQPathD+QD2->QD2_MODELO) .and. !File(cQPathD+QD2->QD2_MODELO+"X") 
			  	Aadd(aDocsDot,{QD2->QD2_CODTP,QD2->QD2_MODELO})
			EndIf
	      QD2->(DbSkip())
	   EndDo
		QD2->(dbGoTo(nPosQD2))
		QD2->(dbSetOrder(nOrdQD2))
	
	   If Len(aDocsDot) > 0
			For nCnt:= 1 to Len(aDocsDot)
				nErro++
				nTotErro++
				Aadd(aDetalhes,{OemToAnsi(STR0011)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
				Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0053)+" "+Alltrim(aDocsDot[nCnt][2])+" "+OemToAnsi(STR0058)+" "+Alltrim(aDocsDot[nCnt][1])+cPulaLinha}) // "Descricao" ### "Nao foi encontrado o arquivo" ### "referente a Tipo de Documento"
				Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0057)+cPulaLinha})  //"Verifique se esta correto o diretorio ou se o arquivo existe"
				lError:= .t.		
			Next nCnt
	   EndIf
	
		If Len(aDistSN) > 0
			For nCnt:= 1 to Len(aDistSN)
				nErro++
				nTotErro++
				Aadd(aDetalhes,{OemToAnsi(STR0011)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
				Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0059)+" "+Alltrim(aDistSN[nCnt])+cPulaLinha}) // "Descricao" ### "Nao exite nenhum Distribuidor no cento de custo"
				Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0060) +cPulaLinha})  //"Solucao" ### "Preencha o campo DISTSN para o responsavel pela distribuicao no cadastro de responsaveis com (S)"
				lError:= .t.		
			Next nCnt
	  	EndIf
	EndIf
EndIf
QAA->(dbSetOrder(nOrdQAA))

If !lError
	lTpDocto:= .t.
Else 
	Aadd(aDetalhes,{OemToAnsi(STR0002)+" "+Alltrim(Str(nErro))+cPulaLinha}) // "Total de Erro(s):"
	Aadd(aDetalhes,{Replicate( "-", 132 )+cPulaLinha}) // ----------
	lTudoOk:= .f.
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Usuario Logado             				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lError:= .f.
nErro:= 0
If !aUsrMat[1] // Se nao possui apelido no cadastro de Responsaveis
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0012)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0061)+" "+OemToAnsi(STR0067)+cPulaLinha})  // "Descricao" ### "Apelido" ### "do Usuario nao esta preenchido no Cadastro de responsaveis"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0062)+cPulaLinha})  //"Solucao" ### "Preencha o Apelido do Usuario no Cadastro de Responsaveis"
	lError:= .t.		
Else	
	DbSelectArea("QAA")
	DbSetOrder(1)
	If QAA->(DbSeek(cMatFil+cMatCod))
		cEmail  := QAA->QAA_EMAIL
		cApelido:= QAA->QAA_APELID
		cRecMail:= If(QAA->QAA_RECMAI == "1","S","N")
		If Empty(cMatDep)
			nErro++
			nTotErro++
			Aadd(aDetalhes,{OemToAnsi(STR0012)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
			Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0063)+" "+OemToAnsi(STR0067)+cPulaLinha})  // "Descricao" ### "Departamento" ### "do Usuario nao esta preenchido no Cadastro de responsaveis"
			Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0064)+cPulaLinha})  //"Solucao" ### "Preencha o Departamento do Usuario no Cadastro de Responsaveis"
			lError:= .t.		
		EndIf
		If Empty(cEmail)
			nErro++
			nTotErro++
			Aadd(aDetalhes,{OemToAnsi(STR0012)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
			Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0065)+" "+OemToAnsi(STR0067)+cPulaLinha}) // "Descricao" ### "Email" ### "do Usuario nao esta preenchido no Cadastro de responsaveis"
			Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0066)+cPulaLinha})  //"Solucao" ### "Preencha o campo DISTSN para o responsavel pela distribuicao no cadastro de responsaveis com (S)"
			lError:= .t.		
		EndIf
	EndIf
EndIf

QAA->(dbGoTo(nPosQAA))
QAA->(dbSetOrder(nOrdQAA))

If !lError
	lUsrLog:= .t.
Else 
	Aadd(aDetalhes,{OemToAnsi(STR0002)+" "+Alltrim(Str(nErro))+cPulaLinha}) // "Total de Erro(s):"
	Aadd(aDetalhes,{Replicate( "-", 132 )+cPulaLinha}) // ----------
	lTudoOk:= .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envio de email			            		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lError:= .f.
nErro:= 0
If Empty(cApelido)   
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0013)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0061)+" "+OemToAnsi(STR0067)+cPulaLinha})  // "Descricao" ### "Apelido" ### "do Usuario nao esta preenchido no Cadastro de responsaveis"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0062)+cPulaLinha})  //"Solucao" ### "Preencha o Apelido do Usuario no Cadastro de Responsaveis"
	lError:= .t.		
Else
	If Empty(cEmail)
		nErro++
		nTotErro++
		Aadd(aDetalhes,{OemToAnsi(STR0013)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0065)+" "+OemToAnsi(STR0067)+cPulaLinha}) // "Descricao" ### "Email" ### "do Usuario nao esta preenchido no Cadastro de responsaveis"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0066)+cPulaLinha})  //"Solucao" ### "Preencha o campo DISTSN para o responsavel pela distribuicao no cadastro de responsaveis com (S)"
		lError:= .t.		
	EndIf      
	
	If Empty(cRecmail) .Or. cRecmail == "N"
		nErro++
		nTotErro++
		Aadd(aDetalhes,{OemToAnsi(STR0013)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0068)+cPulaLinha}) // "Descricao" ### "O Usuario esta definido para nao receber e-mail"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0069)+cPulaLinha})  //"Solucao" ### "Preencha o campo RECMAIL no cadastro de responsaveis como (S)."
		lError:= .t.		
	EndIf      
EndIf

If !lError
	cSubject :=	OemToAnsi(STR0017) // "Teste"
	cMsg :=	OemToAnsi(STR0018)+CHR(13)+CHR(10)+CHR(13)+CHR(10)  // "Teste de Envio de e-mail concluido com sucesso"
	cMsg += OemToAnsi(STR0019) // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO  - Controle de Documentos"
	aMsg := { {cSubject,cMsg,cAttach} }
	aadd(aUsrMail,{ AllTrim(cApelido),Trim(cEmail),aMsg })
	If !(QaEnvMail(aUsrMail,,,,aUsrMat[5]))
		nErro++
		nTotErro++
		Aadd(aDetalhes,{OemToAnsi(STR0013)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0070)+cPulaLinha}) // "Descricao" ### "Nao foi possivel enviar o e-mail teste."
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0071)+cPulaLinha})  //"Solucao" ### "Verifique se o parametro MV_RELACNT, MV_RELSERV e MV_RELPSW esta preenchido corretamente."
		Aadd(aDetalhes,{"  "+OemToAnsi(STR0075)+cPulaLinha})  //Verifique se o Servidor de e-mail esta ativo."
		lError:= .t.		
	EndIf
EndIf

If !lError
	lEmail:= .t.
Else 
	Aadd(aDetalhes,{OemToAnsi(STR0002)+" "+Alltrim(Str(nErro))+cPulaLinha}) // "Total de Erro(s):"
	Aadd(aDetalhes,{Replicate( "-", 132 )+cPulaLinha}) // ----------
	lTudoOk:= .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracao de Conversao  				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lError:= .f.
nErro:= 0
/* Comentado por estar obsoleto <<<<<<<<<<<<<<<<<<<<<<<<<<
If !File( cStartPath + "MIGRAQDO.EXE" )
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0014)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0053)+" "+"MIGRAQDO.EXE"+" "+OemToAnsi(STR0056)+" "+cStartPath+cPulaLinha}) // "Descricao" ### "Nao foi encontrado o arquivo" ### "no Diretorio"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0057)+cPulaLinha})  //"Solucao" ### "Verifique se esta correto o diretorio ou se o arquivo existe"
	lError:= .t.		
EndIf

If !File( cStartPath + "CELERINA.UDL" )
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0014)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0053)+" "+"CELERINA.UDL"+" "+OemToAnsi(STR0056)+" "+cStartPath+cPulaLinha}) // "Descricao" ### "Nao foi encontrado o arquivo" ### "no Diretorio"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0057)+cPulaLinha})  //"Solucao" ### "Verifique se esta correto o diretorio ou se o arquivo existe"
	lError:= .t.		
EndIf
*/
If !lError
	lMigraQdo:= .t.
Else 
	Aadd(aDetalhes,{OemToAnsi(STR0002)+" "+Alltrim(Str(nErro))+cPulaLinha}) // "Total de Erro(s):"
	Aadd(aDetalhes,{Replicate( "-", 132 )+cPulaLinha}) // ----------
	lTudoOk:= .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Microsoft Word             				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lError:= .f.
nErro:= 0
cChkWord:= QDOWord()
If cChkWord <> "1" // 1 - Existe Word
	nErro++
	nTotErro++
	Aadd(aDetalhes,{OemToAnsi(STR0008)+": "+OemToAnsi(STR0025)+" "+AllTrim(STR(nErro))+cPulaLinha}) // "Erro"
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0023)+" "+OemToAnsi(STR0072)+cPulaLinha}) // "Descricao" ### "Nao existe Microsoft Word instalado neste computador."
	Aadd(aDetalhes,{"  "+OemToAnsi(STR0024)+" "+OemToAnsi(STR0073)+cPulaLinha})  //"Solucao" ### "Para utilizacao do Microsoft Word e necessario sua instalacao."
	lError:= .t.		
EndIf 

If !lError
	lMSWord:= .t.
Else 
	Aadd(aDetalhes,{OemToAnsi(STR0002)+" "+Alltrim(Str(nErro))+cPulaLinha}) // "Total de Erro(s):"
	Aadd(aDetalhes,{Replicate( "-", 132 )+cPulaLinha+cPulaLinha}) // ----------
	lTudoOk:= .f.
EndIf

If (nHdl := MsFCreate(cQPathTrm+"LOGQLY.TXT")) > 0
	DbSelectArea("QD0")		// RESPONSAVEIS PELO DOCUMENTO
	DbSetOrder(1)

	DbSelectArea("QD1")		// DISTRIBUICAO POR USUARIO
	DbSetOrder(1)

	DbSelectArea("QAA")		// USUARIOS
	DbSetOrder(1)
                                              
	DbSelectArea("QAC")		// CARGOS
	DbSetOrder(1)
	
	DbSelectArea("QAD")		// Centro de Custo	
	DbSetOrder(1)

	DbSelectArea("QDC")		// Cadastro de Pastas
	DbSetOrder(1)
	
	DbSelectArea("QDE")		// Copias emitidas / Inativacao
	DbSetOrder(1)
	
	DbSelectArea("QDH")		// Cadastro de Documentos
	DbSetOrder(1)

	DbSelectArea("QDJ")		// DESTINOS
	DbSetOrder(1)

	DbSelectArea("QDG")		// Destinatarios
	DbSetOrder(1)

	DbSelectArea("QDR")		// Log de Transferencias
	DbSetOrder(1)

	cAliasQry := "QD0"

    
	cAliasQry := "QRYQD0"

	cFiltro := "SELECT * FROM " + RetSqlName("QD0") + " " +;
	"WHERE ((NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QAD") + " QAD WHERE QD0_FILMAT = QAD.QAD_FILIAL AND QD0_DEPTO = QAD.QAD_CUSTO AND QAD.D_E_L_E_T_ <> '*')) OR " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QAA") + " QAA WHERE QD0_FILMAT = QAA.QAA_FILIAL AND QD0_MAT = QAA.QAA_MAT AND QAA.D_E_L_E_T_ <> '*'))) AND D_E_L_E_T_ <> '*' " +;
	"OR " +;
	"((EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDH") + " QDH WHERE QD0_FILIAL = QDH.QDH_FILIAL AND QD0_DOCTO = QDH.QDH_DOCTO AND QD0_RV = QDH.QDH_RV AND QDH.QDH_OBSOL <> 'S' AND QDH.QDH_CANCEL <> 'S' AND QDH.QDH_STATUS = 'L  ' AND QDH.D_E_L_E_T_ <> '*') OR " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDH") + " QDH WHERE QD0_FILIAL = QDH.QDH_FILIAL AND QD0_DOCTO = QDH.QDH_DOCTO AND QD0_RV = QDH.QDH_RV AND QDH.D_E_L_E_T_ <> '*'))) AND " +;
	"((QD0_FLAG = 'I') AND " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDE") + " QDE WHERE QD0_FILIAL = QDE.QDE_FILIAL AND QD0_DOCTO = QDE.QDE_DOCTO AND QD0_RV = QDE.QDE_RV AND QD0_FILMAT = QDE.QDE_FILDES AND QD0_MAT = QDE.QDE_MATDES AND QDE.D_E_L_E_T_ <> '*')) AND " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDR") + " QDR WHERE QD0_FILIAL = QDR.QDR_FILIAL AND QD0_DOCTO = QDR.QDR_DOCTO AND QD0_RV = QDR.QDR_RV AND QDR.D_E_L_E_T_ <> '*'))) OR " +;
	"((QD0_FLAG = 'T') AND " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDR") + " QDR WHERE QD0_FILIAL = QDR.QDR_FILIAL AND QD0_DOCTO = QDR.QDR_DOCTO AND QD0_RV = QDR.QDR_RV AND QDR.D_E_L_E_T_ <> '*')))) AND " +;
	"D_E_L_E_T_ <> '*' "                                        	

	If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
		cFiltro += " ORDER BY " + OraOrder({"QD0_FILIAL","QD0_DOCTO","QD0_RV"})
	Else
		cFiltro += " ORDER BY " + SqlOrder("QD0_FILIAL+QD0_DOCTO+QD0_RV")
	Endif
	
	cFiltro := ChangeQuery(cFiltro)
			
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), cAliasQry, .F., .T.)

	While ! Eof() .And. (cAliasQry)->QD0_FILIAL = xFilial()
		cFilQad := If(FWModeAccess("QAD")=="C", xFilial("QAD"), (cAliasQry)->QD0_FILMAT)
		If ! QAD->(MsSeek(cFilQad + (cAliasQry)->QD0_DEPTO))
			Aadd(aLog, M020Ident(cAliasQry, "CC " + (cAliasQry)->QD0_DEPTO + STR0093) ) //" Invalido"
		Endif
		
		If ! QAA->(MsSeek((cAliasQry)->QD0_FILMAT + (cAliasQry)->QD0_MAT))
			Aadd(aLog, M020Ident(cAliasQry, STR0094 + (cAliasQry)->QD0_MAT + STR0095) ) //"Matricula "###" Invalida"
		Endif

		If 	! QA_SITFOLH() .And. Empty((cAliasQry)->QD0_FLAG) .And.;
			QDH->(MsSeek(xFilial() + (cAliasQry)->QD0_DOCTO + (cAliasQry)->QD0_RV)) .And.;
			QDH->QDH_OBSOL <> "S" .And. QDH->QDH_CANCEL <> "S" .And.;
			QDH->QDH_STATUS = "L  "
			Aadd(aLog, M020Ident(cAliasQry, STR0094 + (cAliasQry)->QD0_MAT + STR0096) ) //"Matricula "###" Demitido"
		Endif

		If ! QDH->(MsSeek(xFilial() + (cAliasQry)->QD0_DOCTO + (cAliasQry)->QD0_RV))
			Aadd(aLog, M020Ident(cAliasQry, STR0097) ) //"Falta QDH correspondente"
		Endif

		If (cAliasQry)->QD0_FLAG = "I"	// Inativo para o Documento
			DbSelectArea("QDE")
			DbSeek(xFilial() + (cAliasQry)->QD0_DOCTO + (cAliasQry)->QD0_RV)
			lChkQdr := .T.
			While 	! Eof() .And. QDE_FILIAL = xFilial() .And.;
					QDE_DOCTO = (cAliasQry)->QD0_DOCTO .And. QDE_RV = (cAliasQry)->QD0_RV
				If QDE->QDE_FILDES + QDE->QDE_MATDES = (cAliasQry)->QD0_FILMAT + (cAliasQry)->QD0_MAT
					lChkQdr := .F.
				Endif
				DbSkip()
			EndDo

            If lChkQdr
				DbSelectArea("QDR")
				DbSetOrder(2)
				If ! DbSeek(xFilial() + (cAliasQry)->QD0_DOCTO + (cAliasQry)->QD0_RV +;
							(cAliasQry)->QD0_FILMAT + (cAliasQry)->QD0_MAT + (cAliasQry)->QD0_DEPTO)
					Aadd(aLog, M020Ident(cAliasQry, STR0098) ) //"Falta QDE ou QDR de correspondencia"
				Endif
			Endif
			DbSelectArea(cAliasQry)
		ElseIf (cAliasQry)->QD0_FLAG = "T"
			DbSelectArea("QDR")
			DbSetOrder(3)
			If ! DbSeek(xFilial() + (cAliasQry)->QD0_DOCTO + (cAliasQry)->QD0_RV +;
						(cAliasQry)->QD0_FILMAT + (cAliasQry)->QD0_MAT + (cAliasQry)->QD0_DEPTO)
				Aadd(aLog, M020Ident(cAliasQry, STR0099) ) //"Falta QDR para correspondente"
			Endif

			DbSelectArea(cAliasQry)
		Endif
		
		DbSkip()
	EndDo
	
	If cAliasQry <> "QD0"
		DbCloseArea()
	Endif

	cAliasQry := "QD1"
	
	cAliasQry := "QRYQD1"
	cFiltro := "SELECT * FROM " + RetSqlName("QD1") + " " +;
	"WHERE NOT ((EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QAD") + " QAD WHERE QD1_FILMAT = QAD.QAD_FILIAL AND QD1_DEPTO = QAD.QAD_CUSTO AND QAD.D_E_L_E_T_ <> '*')) OR " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QAA") + " QAA WHERE QD1_FILMAT = QAA.QAA_FILIAL AND QD1_MAT = QAA.QAA_MAT AND QAA.D_E_L_E_T_ <> '*'))) AND D_E_L_E_T_ <> '*' " +;
	"OR " +;
	"(((QD1_PENDEN = 'P' AND QD1_SIT = 'I') OR " +;
	"(QD1_PENDEN = 'P' AND EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDH") + " QDH WHERE QD1_FILIAL = QDH.QDH_FILIAL AND QD1_DOCTO = QDH.QDH_DOCTO AND QD1_RV = QDH.QDH_RV AND QDH.QDH_OBSOL <> 'S' AND QDH.QDH_CANCEL <> 'S' AND QDH.D_E_L_E_T_ <> '*')) OR " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDH") + " QDH WHERE QD1_FILIAL = QDH.QDH_FILIAL AND QD1_DOCTO = QDH.QDH_DOCTO AND QD1_RV = QDH.QDH_RV AND QDH.D_E_L_E_T_ <> '*'))) AND " +;
	"((QD1_SIT = 'I') AND " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDE") + " QDE WHERE QD1_FILIAL = QDE.QDE_FILIAL AND QD1_DOCTO = QDE.QDE_DOCTO AND QD1_RV = QDE.QDE_RV AND QD1_FILMAT = QDE.QDE_FILDES AND QD1_MAT = QDE.QDE_MATDES AND QDE.D_E_L_E_T_ <> '*')) AND " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDR") + " QDR WHERE QD1_FILIAL = QDR.QDR_FILIAL AND QD1_DOCTO = QDR.QDR_DOCTO AND QD1_RV = QDR.QDR_RV AND QDR.D_E_L_E_T_ <> '*'))) OR " +;
	"((QD1_SIT = 'T') AND " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDR") + " QDR WHERE QD1_FILIAL = QDR.QDR_FILIAL AND QD1_DOCTO = QDR.QDR_DOCTO AND QD1_RV = QDR.QDR_RV AND QDR.D_E_L_E_T_ <> '*'))) OR " +;
	"((QD1_SIT = 'I'))) AND D_E_L_E_T_ <> '*' "

	If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
		cFiltro += " ORDER BY " + OraOrder({"QD1_FILIAL","QD1_DOCTO","QD1_RV"})
	Else
		cFiltro += " ORDER BY " + SqlOrder("QD1_FILIAL+QD1_DOCTO+QD1_RV")	
	Endif

	cFiltro := ChangeQuery(cFiltro)
			
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), cAliasQry, .F., .T.)

	While ! Eof() .And. (cAliasQry)->QD1_FILIAL = xFilial()
		cFilQAD := If(FWModeAccess("QAD")=="C", xFilial("QAD"), (cAliasQry)->QD1_FILMAT)
		If ! QAD->(MsSeek(cFilQAD + (cAliasQry)->QD1_DEPTO))
			Aadd(aLog, M020Ident(cAliasQry, "CC " + (cAliasQry)->QD1_DEPTO + STR0093) ) //" Invalido"
		Endif

		If ! QAA->(MsSeek((cAliasQry)->QD1_FILMAT + (cAliasQry)->QD1_MAT))
			Aadd(aLog, M020Ident(cAliasQry, STR0094 + (cAliasQry)->QD1_MAT + STR0095) ) //"Matricula "###" Invalida"
		Endif

		If ! QDH->(MsSeek(xFilial() + (cAliasQry)->QD1_DOCTO + (cAliasQry)->QD1_RV))
			Aadd(aLog, M020Ident(cAliasQry, STR0097) ) //"Falta QDH correspondente"
		Endif
		
		If 	(cAliasQry)->QD1_PENDEN = "P" .And. ! QA_SITFOLH() .And. Empty((cAliasQry)->QD1_SIT) .And.;
			QDH->(Found()) .And. QDH->QDH_OBSOL <> "S" .And.;
			QDH->QDH_CANCEL <> "S"
			Aadd(aLog, M020Ident(cAliasQry, STR0094 + (cAliasQry)->QD1_MAT + STR0100 + Left( AllTrim(Qa_nSit( (cAliasQry)->QD1_TPPEND )),20 ) + STR0101) ) //"Matricula "###" Demitido com pendencia de "###" pendente"
		Endif

		If (cAliasQry)->QD1_SIT = "I" .And. (cAliasQry)->QD1_PENDEN = "P"
			Aadd(aLog, M020Ident(cAliasQry, STR0094 + (cAliasQry)->QD1_MAT + STR0102) ) //"Matricula "###" Pendencia inativa porem pendente"
		Endif

		If (cAliasQry)->QD1_SIT = "I"	// Inativo para o Documento
			DbSelectArea("QDE")
			DbSeek(xFilial() + (cAliasQry)->QD1_DOCTO + (cAliasQry)->QD1_RV)
			lChkQdr := .T.
			While 	! Eof() .And. QDE_FILIAL = xFilial() .And.;
					QDE_DOCTO = (cAliasQry)->QD1_DOCTO .And. QDE_RV = (cAliasQry)->QD1_RV
				If QDE->QDE_FILDES + QDE->QDE_MATDES = (cAliasQry)->QD1_FILMAT + (cAliasQry)->QD1_MAT
					lChkQdr := .F.
				Endif
				DbSkip()
			EndDo

            If lChkQdr
				DbSelectArea("QDR")
				DbSetOrder(2)
				If ! DbSeek(xFilial() + (cAliasQry)->QD1_DOCTO + (cAliasQry)->QD1_RV +;
							(cAliasQry)->QD1_FILMAT + (cAliasQry)->QD1_MAT + (cAliasQry)->QD1_DEPTO)
					Aadd(aLog, M020Ident(cAliasQry, STR0098) ) //"Falta QDE ou QDR de correspondencia"
				Endif
			Endif
			DbSelectArea(cAliasQry)
		ElseIf (cAliasQry)->QD1_SIT = "T"
			DbSelectArea("QDR")
			DbSetOrder(3)
			If ! DbSeek(xFilial() + (cAliasQry)->QD1_DOCTO + (cAliasQry)->QD1_RV +;
						(cAliasQry)->QD1_FILMAT + (cAliasQry)->QD1_MAT + (cAliasQry)->QD1_DEPTO)
				Aadd(aLog, M020Ident(cAliasQry, STR0099) ) //"Falta QDR para correspondente"
			Endif

			DbSelectArea(cAliasQry)
		Endif
		
		DbSkip()
	EndDo

	If cAliasQry <> "QD1"
		DbCloseArea()
	Endif

	cAliasQry := "QDJ"
	
	cAliasQry := "QRYQDJ"
	cFiltro := "SELECT * FROM " + RetSqlName("QDJ") + " " +;
	"WHERE ((NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QAD") + " QAD WHERE QDJ_FILMAT = QAD.QAD_FILIAL AND QDJ_DEPTO = QAD.QAD_CUSTO AND QAD.D_E_L_E_T_ <> '*') AND D_E_L_E_T_ <> '*') OR " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDH") + " QDH WHERE QDJ_FILIAL = QDH.QDH_FILIAL AND QDJ_DOCTO = QDH.QDH_DOCTO AND QDJ_RV = QDH.QDH_RV AND QDH.D_E_L_E_T_ <> '*')) OR " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDG") + " QDG WHERE QDJ_FILIAL = QDG.QDG_FILIAL AND QDJ_DOCTO = QDG.QDG_DOCTO AND QDJ_RV = QDG.QDG_RV AND QDG.D_E_L_E_T_ <> '*'))) AND " +;
	"D_E_L_E_T_ <> '*' "

	cFiltro += " ORDER BY " + SqlOrder(QDJ->(IndexKey()))	

	cFiltro := ChangeQuery(cFiltro)
			
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), cAliasQry, .F., .T.)

	While ! Eof() .And. (cAliasQry)->QDJ_FILIAL = xFilial()
		cFilQAD := If(FWModeAccess("QAD")=="C", xFilial("QAD"), (cAliasQry)->QDJ_FILMAT)
		If ! QAD->(MsSeek(cFilQAD + (cAliasQry)->QDJ_DEPTO))
			Aadd(aLog, M020Ident(cAliasQry, "CC " + (cAliasQry)->QDJ_DEPTO + STR0093) ) //" Invalido"
		Endif

		If ! QDG->(MsSeek(xFilial() + (cAliasQry)->QDJ_DOCTO + (cAliasQry)->QDJ_RV +;
			 (cAliasQry)->QDJ_TIPO))
			Aadd(aLog, M020Ident(cAliasQry, STR0103) ) //"Falta QDG correspondente"
		Endif

		If ! QDH->(MsSeek(xFilial() + (cAliasQry)->QDJ_DOCTO + (cAliasQry)->QDJ_RV))
			Aadd(aLog, M020Ident(cAliasQry, STR0097) ) //"Falta QDH correspondente"
		Endif
		DbSkip()
	EndDo

	If cAliasQry <> "QDJ"
		DbCloseArea()
	Endif

	cAliasQry := "QDG"

	cAliasQry := "QRYQDG"

	cFiltro := "SELECT * FROM " + RetSqlName("QDG") + " " +;
	"WHERE ((NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QAD") + " QAD WHERE QDG_FILMAT = QAD.QAD_FILIAL AND QDG_DEPTO = QAD.QAD_CUSTO AND QAD.D_E_L_E_T_ <> '*')) OR " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QAA") + " QAA WHERE QDG_FILMAT = QAA.QAA_FILIAL AND QDG_MAT = QAA.QAA_MAT AND QAA.D_E_L_E_T_ <> '*'))) AND D_E_L_E_T_ <> '*' " +;
	"OR " +;
	"((EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDH") + " QDH WHERE QDG_FILIAL = QDH.QDH_FILIAL AND QDG_DOCTO = QDH.QDH_DOCTO AND QDG_RV = QDH.QDH_RV AND QDH.QDH_OBSOL <> 'S' AND QDH.QDH_CANCEL <> 'S' AND QDH.QDH_STATUS = 'L' AND QDH.D_E_L_E_T_ <> '*')) OR " +;
	"(QDG_CODMAN <> '" + Space(Len(QDG->QDG_CODMAN)) + "' AND NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDC") + " QDC WHERE QDG_FILMAT = QDC.QDC_FILIAL AND QDG_CODMAN = QDC.QDC_CODMAN AND QDC.D_E_L_E_T_ <> '*')) AND " +;
	"((QDG_SIT = 'T') AND " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDR") + " QDR WHERE QDG_FILIAL = QDR.QDR_FILIAL AND QDG_DOCTO = QDR.QDR_DOCTO AND QDG_RV = QDR.QDR_RV AND QDR.D_E_L_E_T_ <> '*'))) OR " +;
	"((QDG_SIT = 'I') AND " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDE") + " QDE WHERE QDG_FILIAL = QDE.QDE_FILIAL AND QDG_DOCTO = QDE.QDE_DOCTO AND QDG_RV = QDE.QDE_RV AND QDG_FILMAT = QDE.QDE_FILDES AND QDG_MAT = QDE.QDE_MATDES AND QDE.D_E_L_E_T_ <> '*')) AND " +;
	"(NOT EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QDR") + " QDR WHERE QDG_FILIAL = QDR.QDR_FILIAL AND QDG_DOCTO = QDR.QDR_DOCTO AND QDG_RV = QDR.QDR_RV AND QDR.D_E_L_E_T_ <> '*')))) AND " +;
	"D_E_L_E_T_ <> '*' "

	If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
		cFiltro += " ORDER BY " + OraOrder({"QDG_FILIAL","QDG_DOCTO","QDG_RV"})
	Else
		cFiltro += " ORDER BY " + SqlOrder("QDG_FILIAL+QDG_DOCTO+QDG_RV")	
	Endif

	cFiltro := ChangeQuery(cFiltro)
			
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), cAliasQry, .F., .T.)

	While ! Eof() .And. (cAliasQry)->QDG_FILIAL = xFilial()
		cFilQAD := If(FWModeAccess("QAD")=="C", xFilial("QAD"), (cAliasQry)->QDG_FILMAT)
		If ! QAD->(MsSeek(cFilQAD + (cAliasQry)->QDG_DEPTO))
			Aadd(aLog, M020Ident(cAliasQry, "CC " + (cAliasQry)->QDG_DEPTO + STR0093) ) //" Invalido"
		Endif
		If ! QAA->(MsSeek((cAliasQry)->QDG_FILMAT + (cAliasQry)->QDG_MAT))
			Aadd(aLog, M020Ident(cAliasQry, STR0094 + (cAliasQry)->QDG_MAT + STR0095) ) //"Matricula "###" Invalida"
		Endif
		
		If 	! QA_SITFOLH() .And. Empty((cAliasQry)->QDG_SIT) .And.;
			QDH->(MsSeek(xFilial() + (cAliasQry)->QDG_DOCTO + (cAliasQry)->QDG_RV)) .And.;
			QDH->QDH_OBSOL <> "S" .And. QDH->QDH_CANCEL <> "S" .And.;
			QDH->QDH_STATUS = "L  "
			Aadd(aLog, M020Ident(cAliasQry, STR0094 + (cAliasQry)->QDG_MAT + STR0096) ) //"Matricula "###" Demitido"
		Endif

		If ! Empty((cAliasQry)->QDG_CODMAN) .And. ! QDC->(MsSeek(xFilial() + (cAliasQry)->QDG_CODMAN))
			Aadd(aLog, M020Ident(cAliasQry, STR0104) ) //"Falta QDC correspondente"
		Endif

		If ! QDH->(MsSeek(xFilial() + (cAliasQry)->QDG_DOCTO + (cAliasQry)->QDG_RV))
			Aadd(aLog, M020Ident(cAliasQry, STR0097) ) //"Falta QDH correspondente"
		Endif
		
		If (cAliasQry)->QDG_SIT = "I"	// Inativo para o Documento
			DbSelectArea("QDE")
			DbSeek(xFilial() + (cAliasQry)->QDG_DOCTO + (cAliasQry)->QDG_RV)
			lChkQdr := .T.
			While 	! Eof() .And. QDE_FILIAL = xFilial() .And.;
					QDE_DOCTO = (cAliasQry)->QDG_DOCTO .And. QDE_RV = (cAliasQry)->QDG_RV
				If QDE->QDE_FILDES + QDE->QDE_MATDES = (cAliasQry)->QDG_FILMAT + (cAliasQry)->QDG_MAT
					lChkQdr := .F.
				Endif
				DbSkip()
			EndDo

            If lChkQdr
				DbSelectArea("QDR")
				DbSetOrder(2)
				If ! DbSeek(xFilial() + (cAliasQry)->QDG_DOCTO + (cAliasQry)->QDG_RV +;
							(cAliasQry)->QDG_FILMAT + (cAliasQry)->QDG_MAT + (cAliasQry)->QDG_DEPTO)
					Aadd(aLog, M020Ident(cAliasQry, STR0098) ) //"Falta QDE ou QDR de correspondencia"
				Endif
			Endif
			DbSelectArea(cAliasQry)
		ElseIf (cAliasQry)->QDG_SIT = "T"	// Transferido para a proxima revisao Documento
			DbSelectArea("QDR")
			DbSetOrder(3)
			If ! DbSeek(xFilial() + (cAliasQry)->QDG_DOCTO + (cAliasQry)->QDG_RV +;
						(cAliasQry)->QDG_FILMAT + (cAliasQry)->QDG_MAT + (cAliasQry)->QDG_DEPTO)
				Aadd(aLog, M020Ident(cAliasQry, STR0099) ) //"Falta QDR para correspondente"
			Endif

			DbSelectArea(cAliasQry)
		Endif
		DbSkip()
	EndDo

	If cAliasQry <> "QDG"
		DbCloseArea()
	Endif

// Ordeno o array por codigo do documento/revisao e adiciono no arquivo branco
// nas ocorrencias abaixo que se repetem do mesmo documento/revisao

    nTamId 	:= Len(QDH->QDH_DOCTO + "/" + QDH->QDH_RV)
    aLog 	:= aSort(aLog,,, { |x,y| Left(x, nTamId) < Left(y, nTamId) })
	cId  	:= ""
    
	For nLog := 1 To Len(aLog)
		If cId <> Left(aLog[nLog], nTamId)
			FWrite(nHdl, aLog[nLog] + Chr(13) + Chr(10))
		Else
			FWrite(nHdl, Space(nTamId) + Subs(aLog[nLog], nTamId + 1,;
						   	Len(aLog[nLog]) - nTamId) + Chr(13) + Chr(10))
		Endif
		cId := Left(aLog[nLog], nTamId)
	Next
	lBseInt := Len(aLog) = 0
	FClose(nHdl)
Endif

Aadd(aDetalhes,{OemToAnsi(STR0076)+" "+Alltrim(Str(nTotErro))}) // "Total Geral de Erro(s):"

RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QDM020Det  ³ Autor ³ Eduardo de Souza ³ Data ³ 26/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Carrega a variavel com os detalhes                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDM020Det(ExpC1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpC1 - Detalhes do Status                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOM020.PRW                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDM020Det(cDetalhe)

Local nCnt:= 0

cDetalhe:= ""
For nCnt:= 1 to Len(aDetalhes)
	If Empty(cDetalhe)
		cDetalhe:= aDetalhes[nCnt][1]
	Else
		cDetalhe+= aDetalhes[nCnt][1]
	EndIf
Next nCnt

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QDM020MTela³ Autor ³ Eduardo de Souza ³ Data ³ 23/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Aumenta\Diminui Tela para apresentar Detalhes           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDM020MTela(ExpO1,ExpC1,ExpO2)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpO1 - Objeto da Tela                                  ³±±
±±³             ³ ExpC1 - Detalhes do Erro                                ³±±
±±³             ³ ExpO2 - Objeto Botao Detalhes                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QdoM020.Prw                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/* Função descontinuada na DMANQUALI-2525

Function QDM020MTela(oDlg,cDetalhe,oBtnDet)

oDlg:CoorsUpdate()
If oDlg:nHeight >= 412
	oDlg:nHeight:= 300
	oDlg:nWidth  := 633
	oDlg:nTop    := 150
	oDlg:nBottom := 456
	oBtnDet:cCaption:= OemToAnsi(STR0004)
Else
	oDlg:nHeight:= 412
	oDlg:nWidth  := 633
	oDlg:nTop    := 150
	oDlg:nBottom := 562
	oBtnDet:cCaption:= OemToAnsi(STR0003)
EndIf

QDM020DET(@cDetalhe)

Return
*/
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³QDM020ImpDet³ Autor ³ Eduardo de Souza ³ Data ³ 02/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Imprime Detalhes                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDM020ImpDet()                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOM020.PRW                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDM020ImpDet()

Local cTitulo	:= STR0001 // "Status Gerais"
Local cDesc1	:= STR0079 // "Este programa ira imprimir todos erros encontrados"
Local cDesc2	:= STR0080 // "de inconsistencias no SIGAQDO."
Local cString	:= "QDH"
Local wnrel		:= "QDOM020"
Local Tamanho	:= "M"
Local lFiltro  := .f. // Nao aparece a opcao filtro na tela de impressao

Private cPerg	 := " "
Private aReturn := { STR0081,1,STR0082, 1, 2, 1, "",1 } // "Zebrado" ### "Administracao"
Private nLastKey:= 0
Private Inclui	 := .F.	
Private Li		 := 0

wnrel :=SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,,.F.,,,Tamanho,,lFiltro)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| QDOM020Imp(@lEnd,ctitulo,wnRel,tamanho)},ctitulo)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDOM020Imp³ Autor ³Eduardo de Souza       ³ Data ³ 02/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que faz a impressao do relatorio.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ QDM020Imp()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOM020.PRW                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QDOM020Imp(lEnd,ctitulo,wnRel,tamanho)

Local nCnt     := 0
Local nCntLinha:= 0
Private aDriver:= ReadDriver()

CabecM020(@Li)
nCntLinha := Li
For nCnt:= 1 to Len(aDetalhes)
	nCntLinha++
	@ Li,00 PSay aDetalhes[nCnt][1]
	If nCntLinha == 40
		CabecM020(@Li)	
		nCntLinha:= Li
	EndIf
	LI++
Next nCnt

Set Device To Screen

If aReturn[5] == 1
	Set Printer TO 
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()

Return (.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CabecM020 ³ Autor ³ Eduardo de Souza      ³ Data ³ 02/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime dados pertinentes ao cabecalho do programa.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ CabecM020()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOM020.PRW                               				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CabecM020(Li)

@ 0,0 PSAY &(aDriver[3]) // Comprimi impressao
Li:=0
@ Li,00 PSay __PrtLogo()
Li+=3
@ Li,00 PSay __PrtCenter(STR0078) //"RELATORIO DE INCONSISTENCIAS DO SIGAQDO"
Li++
@ Li,00 PSay __PrtFatLine()  
Li++

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDM020Email³ Autor ³ Eduardo de Souza     ³ Data ³ 03/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Teste de email                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ QDM020Email()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOM020.PRW                               				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDM020Email(oDlg)

Local oDlgMail
Local oFil
Local oMat
Local oBtnOk
Local oBtnCancel
Local cMat    	:= Space(TamSx3("QAA_MAT"   )[1])
Local cApel   	:= Space(TamSx3("QAA_APELID")[1])
Local cRecMail	:= Space(TamSx3("QAA_RECMAI")[1])
Local cEmail  	:= Space(TamSx3("QAA_EMAIL" )[1])
Local lRet		:= .f.  
Local nFil      := QDM020CTam(FWSizeFilial())         //Calcula tamanho do campo Filial para ser usado no Size
Local nMat      := QDM020CTam(TamSx3("QAA_MAT")[1])   //Calcula tamanho do campo Matricula para ser usado no Size
Local nApel		:= QDM020CTam(TamSx3("QAA_APELID")[1])//Calcula tamanho do campo Apelido para ser usado no Size

Private oApel
Private oRecMail
Private oEmail
Private cFil020	:= Space(FWSizeFilial()) //Space(2)

DEFINE MSDIALOG oDlgMail TITLE OemToAnsi(STR0083) FROM 000,000 TO 105,700 OF oDlg PIXEL // "Teste e-mail"

@ 006,003 SAY OemToAnsi(STR0089) SIZE 040,010 OF oDlgMail PIXEL //"Filial"
@ 005,038 MSGET oFil VAR cFil020 F3 "SM0" SIZE nFil,005 OF oDlgMail PIXEL;
				VALID QA_CHKFIL(cFil020,@cFilMat)

@ 006,085 SAY OemToAnsi(STR0084) SIZE 040,010 OF oDlgMail PIXEL //"Matricula"
@ 005,110 MSGET oMat VAR cMat F3 "QDE" SIZE nMat,005 OF oDlgMail PIXEL;
				VALID QM020AtuVar(cFil020,cMat,@cApel,@cRecMail,@cEmail)

@ 006,180 SAY OemToAnsi(STR0061)	SIZE 045,010 OF oDlgMail PIXEL //"Apelido"
@ 005,225 MSGET oApel VAR cApel   	SIZE nApel,005 OF oDlgMail PIXEL
oApel:lReadOnly:= .T.

@ 026,003 SAY OemToAnsi(STR0085) SIZE 040,010 OF oDlgMail PIXEL //"Recebe email"
@ 025,038 MSGET oRecMail VAR cRecMail SIZE 010,005 OF oDlgMail PIXEL
oRecMail:lReadOnly:= .T.

@ 026,085 SAY OemToAnsi(STR0065) SIZE 040,010 OF oDlgMail PIXEL //"Email"
@ 025,110 MSGET oEmail VAR cEmail SIZE 100,005 OF oDlgMail PIXEL
oEmail:lReadOnly:= .T.

DEFINE SBUTTON oBtnOk FROM 038,260 TYPE 1 ENABLE OF oDlgMail;
       ACTION  QDM020TMail(cApel,cEmail,cRecMail)

DEFINE SBUTTON oBtnCancel FROM 038,300 TYPE 2 ENABLE OF oDlgMail;
       ACTION  oDlgMail:End() 

ACTIVATE MSDIALOG oDlgMail CENTERED

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³QM020AtuVar³ Autor ³ Eduardo de Souza    ³ Data ³ 03/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Atualiza Variaveis da tela                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ QM020AtuVar(ExpC1,ExpC2,ExpC3,ExpC4)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ ExpC1 - Matricula do Usuario                              ³±±
±±³           ³ ExpC2 - Apelido do Usuario                                ³±±
±±³           ³ ExpC3 - Recebe Email S/N                                  ³±±
±±³           ³ ExpC4 - Email do Usuario                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOM020.PRW                              				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QM020AtuVar(cFil,cMat,cApel,cRecMail,cEmail)

Local nOrdQAA:= QAA->(IndexOrd())
Local nPosQAA:= QAA->(RecNo())
Local lRet   := .T.

QAA->(DbSetOrder(1))

If QAA->(DbSeek(cFil+cMat)) .And. !Empty(cMat)
	cRecMail:= If(QAA->QAA_RECMAI == "1","S","N")
	cApel   := QAA->QAA_APELID
	cEmail  := QAA->QAA_EMAIL
Else
	If !Empty(cMat)
		Help(" ",1,"QD050FNE") // "Funcionario nao existe."
		lRet:= .F.
	EndIf
	cRecMail:= " "
	cApel   := " "
	cEmail  := " "
EndIf
oApel:Refresh()
oRecMail:Refresh()
oEmail:Refresh()

QAA->(DbSetOrder(nOrdQAA))
QAA->(DbGoto(nPosQAA))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³QDM020TMail³ Autor ³ Eduardo de Souza    ³ Data ³ 03/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Verifica o envio do email                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ QDM020TMail(ExpC1,ExpC2,ExpC3)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ ExpC1 - Apelido do Usuario                                ³±±
±±³           ³ ExpC2 - Email do Usuario                                  ³±±
±±³           ³ ExpC3 - Recebe Email S/N                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOM020.PRW                              				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDM020TMail(cApelido,cEmail,cRecMail)  

Local cSubject:= ""
Local cMsg    := ""
Local cAttach := ""
Local aMsg    := {}
Local aUsrMail:= {}

If !Empty(cApelido) .And. !Empty(cEmail) .And. cRecMail == "S"
	cSubject := OemToAnsi(STR0017) // "Teste"
	cMsg:= OemToAnsi(STR0018) // "Teste de Envio de e-mail concluido com sucesso"
	cMsg+= CHR(13)+CHR(10)
	cMsg+= CHR(13)+CHR(10)
	cMsg+= OemToAnsi(STR0019) // "Mensagem gerada Automaticamente pelo Modulo SIGAQDO  - Controle de Documentos"
	aMsg:= {{cSubject,cMsg,cAttach}}
	aadd(aUsrMail,{ AllTrim(cApelido),Trim(cEmail),aMsg })
	If QaEnvMail(aUsrMail,,,,aUsrMat[5])
		MsgInfo(STR0086,STR0083) //"Envio de email concluido com sucesso" ### "Teste email"
	Else
		MsgStop(STR0087,STR0088) // "Nao foi possivel o envio do email verifique se os parametros MV_RELACNT, MV_RELSERV e MV_RELPSW estao preenchidos corretamente ou se o Servidor de email esta ativo."	 ### "Atencao"
	EndIf
Else
	Help(" ",1,"QDM020MAIL") // "Para o envio de email e necessario que o usuario tenha APELIDO, EMAIL e o campo RECMAIL igual a 'S' Preenchido no Cadastro de Responsaveis"
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³ M020Ident ³ Autor ³ Wagner Mobile Costa 	      ³ Data ³ 29/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Monta identificacao da linha de inconsistencia            		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ M020Ident(ExpC1,ExpC2,ExpC3)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ ExpC1 - Alias de origem da inconsistencia                           ³±±
±±³           ³ ExpC2 - Mensagem de identificacao da inconsistencia                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOM020.PRW                              				            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M020Ident(cAlias,cMensagem) 

Local cMsg := ""

If "QRY" $ cAlias
	cMsg := &(cAlias + "->" + Right(cAlias, 3) + "_DOCTO") + "/" +;
			&(cAlias + "->" + Right(cAlias, 3) + "_RV") + " - " +;
			Right(cAlias, 3) + " - Recno = " + StrZero(&(cAlias + "->R_E_C_N_O_"), 8) +;
			" - " + cMensagem
Else
	cMsg := &(cAlias + "->" + cAlias + "_DOCTO") + "/" +;
			&(cAlias + "->" + cAlias + "_RV") + " - " + cAlias + " - Recno = " +;
			StrZero(&(cAlias + "->(Recno())"), 8) + " - " + cMensagem
Endif

Return cMsg


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OraOrder  ºAutor  ³Telso Carneiro      º Data ³  01/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Para retorno de posicao dos campo do array para ordem de   º±±
±±º          ³ Top Oracle                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOM020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OraOrder(aCampos)
Local cOrdem:=""
Local i     :=0

For i:=1 To Len(aCampos)
	cOrdem+=Str(SuperVal(GetSx3Cache(aCampos[i],"X3_ORDEM")),2,0)+IF(i<>Len(aCampos),",","")
Next
SX3->(DbSetOrder(1))

Return(cOrdem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDM020CTamºAutor  ³Leonardo Quintania  º Data ³  02/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Para retorno de tamanho correto em pixel para construção   º±±
±±º          ³de campos.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOM020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Static Function QDM020CTam(nTam)
Local nPixels

nPixels:=GetTextWidth(0,Replicate("-",nTam))
 
Return nPixels
