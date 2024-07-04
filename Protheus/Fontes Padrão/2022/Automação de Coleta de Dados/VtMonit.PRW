#INCLUDE "VtMonit.ch" 
#INCLUDE "TBICONN.CH"
#include "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH"  

STATIC __lIsP12 := GetVersao(.F.) == "12"
//-------------------------------------------------------------------
/*/{Protheus.doc} VTMONITOR()
Main Function VtMonitor

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/ 
//-------------------------------------------------------------------                       
MAIN FUNCTION VTMONITOR()
//Abrir o SM0 para poder efetuar as funçõs do protheus
OpenSm0()
dbSelectArea("SM0")
SM0->(DbGotop())
RpcSetType(3)
RpcSetEnv (SM0->M0_CODIGO,FWGETCODFILIAL, , , , , , , , .F., .F. )

VtAcdMonit()

Return nil
//-------------------------------------------------------------------
/*/{Protheus.doc} VtAcdMonit()
Funão responsavel pela aberta da tela

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Function VtAcdMonit()
Local oDlg  
Local oAni, oLogo,oUserBar
Local aCores		:= {	LoadBitmap( GetResources(), "LBOK" ), ; 
						LoadBitmap( GetResources(), "LBNO" )}
Local aCoors		:= FWGetDialogSize()                  
Local cMenuBmp	:= GetMenuBmp() 
Local aRetItens	:= {}

PRIVATE lLoginVT	:= IsInCallStack('VTMONITOR')
PRIVATE oMonitor
PRIVATE lSai		:= .T.
PRIVATE aItens		:= {}
PRIVATE afile 		:= {}
PRIVATE __cInterNet := Nil                              

PRIVATE __CRDD		:= RDDSetDefault() 
PRIVATE oTimer  
PRIVATE aSize		:= {}
PRIVATE aObjects		:= {}     


If !lloginVT 
	DEFINE MSDIALOG oDlg TITLE "" FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL	
Else
	DEFINE WINDOW oDlg TITLE "" FROM 000,000 TO 600,800 PIXEL
EndIf

aRetItens	:= CarregaItens()
aItens		:= aRetItens[1]
afile 		:= aRetItens[2]
aObjects 	:= {}

oMonitor := TCBrowse():New(50,50,200,200,,,,oDlg,,,,,,,,,,,,.t.,,.t.,)
oMonitor:align := CONTROL_ALIGN_ALLCLIENT
oMonitor:nClrBackFocus := GetSysColor( 13 )
oMonitor:nClrForeFocus := GetSysColor( 14 )
oMonitor:SetArray( aItens )

oMonitor:AddColumn( TCColumn():New( ""	,{ || If(aItens[oMonitor:nAt,01],aCores[1],aCores[2])}	,,,,"RIGHT", 10, .T., .F.,,,, .T., ))

ADD COLUMN TO oMonitor HEADER STR0006 				OEM DATA {|| aItens[oMonitor:nAt,2] } ALIGN LEFT SIZE 25	PIXELS /* Coletor*/
ADD COLUMN TO oMonitor HEADER STR0007 				OEM DATA {|| aItens[oMonitor:nAt,3] } ALIGN LEFT SIZE 40	PIXELS /*"Usuario"*/
ADD COLUMN TO oMonitor HEADER STR0008					OEM DATA {|| aItens[oMonitor:nAt,4] } ALIGN LEFT SIZE 40	PIXELS /* "Data"*/
ADD COLUMN TO oMonitor HEADER STR0009					OEM DATA {|| aItens[oMonitor:nAt,5] } ALIGN LEFT SIZE 40	PIXELS /* "Hora"*/
ADD COLUMN TO oMonitor HEADER STR0010  				OEM DATA {|| aItens[oMonitor:nAt,6] } ALIGN LEFT SIZE 40	PIXELS /*"Tamanho"*/
ADD COLUMN TO oMonitor HEADER STR0018					OEM DATA {|| aItens[oMonitor:nAt,7] } ALIGN LEFT SIZE 50	PIXELS /* "Programa Inicial"*/
ADD COLUMN TO oMonitor HEADER STR0019  				OEM DATA {|| aItens[oMonitor:nAt,8] } ALIGN LEFT SIZE 40	PIXELS /* "Rotina"*/

oMonitor:bLDblClick := {|| MarkMom(oMonitor:nAt),AtuTela()}
DEFINE TIMER oTimer INTERVAL 1000 ACTION AtuTela() OF oDlg

If !lloginVT 
	ACTIVATE MSDIALOG oDlg ON INIT (VtMontTela(oDlg),oTimer:Activate())
Else
	ACTIVATE WINDOW oDlg MAXIMIZED ON INIT (VtMontTela(oDlg),oTimer:Activate())
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VtMontTela()
Funão responsavel pela aberta da tela

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Function VtMontTela(oDlg)
Local oBar
Local oTitle
Local aButtons := { {STR0005			, {||oDlg:End()} , CSS_BUTTON}, ; //SAIR
						{STR0002		, {||Monitora()} , CSS_BUTTON},; // Monitorar
						{STR0003		, {||Mensagem()} , CSS_BUTTON},; //Mensagem
						{STR0004	, {||Desconect()}, CSS_BUTTON},;    //Desconectar 
						{STR0017	, {||MarkAll()}, CSS_BUTTON_FOCAL}} //Marcar/Desm	
				
Local cCSS 			:= ""
Local nButtonWidth	:= 45
Local nButtonHeight	:= 15
Local nSpace			:= 10
Local nX				:= 0

If __lIsP12
	cCSS := ColorPalette()[3]
Else
	cCSS := "#0B9BBF"
EndIf 
		
cCSS := "TSay { margin: 4px; margin-top: 6px; color: "+cCSS+"; font: 20px Arial; qproperty-alignment: 'AlignVCenter' }"

//--------------------------------------------------------------------
// Cria barra onde o titulo e os botões serão ancorados
//--------------------------------------------------------------------
@ 000,000 MSPANEL oBar SIZE 000,25 OF oDlg
oBar:SetCSS(FwGetCss(getClassName(oBar)))
oBar:Align := CONTROL_ALIGN_TOP
oBar:ReadClientCoors(.T.,.T.)
//--------------------------------------------------------------------
// Título da barra de mensagem
//--------------------------------------------------------------------
@ 000,000 SAY oTitle PROMPT "TOTVS | VTMonitor" SIZE 000,000 OF oBar
oTitle:Align := CONTROL_ALIGN_LEFT
oTitle:SetCSS( cCSS )
//--------------------------------------------------------------------
// Cria botões
//--------------------------------------------------------------------
For nX := Len(aButtons) To 1 Step -1
	@ (oBar:nHeight/2-nButtonHeight)/2,oBar:nWidth/2-nButtonWidth*nX-nSpace/2*nX BUTTON oButton PROMPT aButtons[nX][1] SIZE nButtonWidth,nButtonHeight OF oBar PIXEL
	oButton:bAction := aButtons[nX][2]
	oButton:SetCSS( FWGetCSS( GetClassName(oButton), aButtons[nX][3] ) )
Next nX	
		
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MarkMom()

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Static Function MarkMom(nAt)

If Empty(aItens[nAt,2])
	Return
EndIf

aItens[nAt,1] := !aItens[nAt,1]
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll()

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Static Function MarkAll()
Local nX

For nX:=1 To Len(aItens)
	MarkMom(nX)
Next
AtuTela()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTela()

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Static Function AtuTela()
Local cMsg := ""
Local aRet := {}

oTimer:Deactivate()
aRet  := CarregaItens()
aItens:= aRet[1]
afile := aRet[2]
oMonitor:SetArray(aItens)
oMonitor:bLine := { || {aItens[oMonitor:nAt,1],aItens[oMonitor:nAt,2],aItens[oMonitor:nAt,3],;
								aItens[oMonitor:nAt,4],aItens[oMonitor:nAt,5],aItens[oMonitor:nAt,6],;
								aItens[oMonitor:nAt,7],aItens[oMonitor:nAt,8]} }
oMonitor:Refresh()

If Len(aItens)> 1
	cMsg := StrZero(Len(aItens),3)+ " Usuarios Conectados"
Else
	If Empty(aItens[1,2])
		cMsg := STR0023   /*Nenhum Usuario Conectado*/
	Else
		cMsg := STR0024  /*001 Usuario Conectado*/
	EndIf
EndIf

// Efeutar essa validação somente quando for acessado pelo SMARTCLIENT
If lLoginVT
		// Verificar se possui o parametro
	dbSelectArea("SX6")
	SX6->(DbSetOrder(1))
	SX6->(dbGoTop())
	
	If SX6->( dbSeek(xFilial("SX6")+"MV_VTLOGIN"))
		If GETMV("MV_VTLOGIN") 
			Final(STR0033,STR0034)/*"ATENCAO: O acesso a este recurso foi reestruturado." " E estará disponivel no menu do sistema conforme parametro MV_VTLOGIN. Caso a funcionalidade não esteja no menu contato o administrador do sistema"*/
		EndIf	
	EndIf 
EndIf

oTimer:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaItens()

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Static Function CarregaItens()
Local nX,nPos
Local nH
Local cLinha		:= Space(70)
Local cNumCol		:= ''
Local cUsuario	:= ''
Local cData   	:= ''
Local cHora   	:= ''
Local cProgIni	:= ''
Local cRotina 	:= ''
Local nHTemp		:= 0 
Local aCabec		:= {}
Local aColetor	:= Directory("VT*.SEM")
Local oFile		:= Nil

For nX := 1 to Len(aColetor)
	oFile := FwFileReader():New( aColetor[nX,1] )
	nHTemp := oFile:nHandLen
	oFile:Close()
	If nHTemp > 0
		FErase( aColetor[nX,1] )
	EndIf
Next

aColetor := Directory("VT*.SEM")
For nX := 1 to Len(aColetor)
	cLinha  := Memoread(aColetor[nX,1])
	cNumCol := Left(cLinha,3)
	cUsuario:= Subs(cLinha,4,25)
	cData   := stod(Subs(cLinha,29,8))
	cHora   := Subs(cLinha,37,8)
	cSize   := Str(Val(Subs(cLinha,45,03))+1,3)+" X "+Str(Val(Subs(cLinha,48,03))+1,3)
	cProgIni:= Subs(cLinha,51,8)
	cRotina := Subs(cLinha,59,30)
	nPos    := AsCan(aItens,{|x|x[2]==cNumCol})
	If Empty(nPos)
		aadd(aCabec,{.F.,cNumcol,cUsuario,cData,cHora,cSize,cProgIni,cRotina})
	Else
		aadd(aCabec,{aItens[nPos,1],cNumcol,cUsuario,cData,cHora,cSize,cProgIni,cRotina})
	EndIf
Next
If Empty(aCabec)
	aadd(aCabec, { .F.,'','','','','','',''})
EndIF
Return {aCabec,aColetor}


//-------------------------------------------------------------------
/*/{Protheus.doc} Desconect()

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Static Function Desconect()
Local cFile
Local nX
If Empty(aItens[oMonitor:nAt,2]) .AND. Len(aItens)==1 
	Return
EndIf

If !  MsgYesNo(STR0025)/*Confirma a desconexao do(s) coletor(es) selecionado(s)?*/
	Return
EndIf   

For nX:=1 To Len(aItens)
	If aItens[nX,1]
		cFile := 'VT'+aItens[nX,2]+'.FIM'
		MemoWrite(cFile,'fim')
	EndIf
Next
AtuTela()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Mensagem()

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Static Function Mensagem()
Local nX
Local nCountMsg	:= 0
Local nPos     	:= oMonitor:nAt
Local cTitulo  	:= ""
Local oMemo
Local cMemo
Local oFont
Local oWndMsg

DEFINE FONT oFont NAME "Mono AS" SIZE 8,20

If Len(aItens)==1 .AND. Empty(aItens[oMonitor:nAt,2])
	Return
EndIf

For nX:=1 To Len(aItens)
	If aItens[nX,1]
		nPos := nX
		nCountMsg++
	EndIf
Next

If Empty(nCountMsg)
	MsgAlert(STR0026)/*Favor selecionar pelo menos um coletor para envio da mensagem!*/
	Return
EndIf

If nCountMsg > 1
	cTitulo := STR0026 /*Mensagem para o coletores selecionados*/
Else
	oMonitor:nAt := nPos
	cTitulo := STR0026+aItens[oMonitor:nAt,2] /*Mensagem para o coletor */
EndIf

DEFINE MSDIALOG oWndMsg FROM 0,0 TO 100,300  Pixel TITLE OemToAnsi(cTitulo)
	@ 0,0 GET oMemo  VAR cMemo MEMO SIZE 150,30 OF oWndMsg PIXEL
	TButton():New( 035,001, STR0013, oWndMsg, {|| envia(cMemo),oWndMsg:End()}, 38, 11,,, .F., .t., .F.,, .F.,,, .F. )/*Enviar*/
	TButton():New( 035,111, STR0005, oWndMsg, {|| oWndMsg:End()}, 38, 11,,, .F., .t., .F.,, .F.,,, .F. )/*Sair*/
	oMemo:oFont:=oFont
ACTIVATE MSDIALOG oWndMsg CENTERED

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Envia()

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Static Function Envia(cTexto)
Local cFile
Local nX

For nX := 1 to len(aItens)
	If aItens[nX,1]
		cFile := 'VT'+aItens[nX,2]+'.MSG'
		MemoWrite(cFile,cTexto)
	EndIf
Next
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Monitora()

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Static Function Monitora()
Local oTimer
Local cFile   := 'VT'+aItens[oMonitor:nAt,2]+'.MON'
Local nMaxRow := Val(SubStr(aItens[oMonitor:nAt,6],1,3))
Local nMaxCol := Val(SubStr(aItens[oMonitor:nAt,6],7,3))
Local nBottom := 294
Local nRight  := 400
Local nI,nJ
Local nPos    := oMonitor:nAt
Local nCount  := 0
Local nLin    := 3
Local nCol    := 3
Local bBlock


oFont  := TFont():New( "Mono AS", 16, 24, .F.,.T.,,,,,,,,,,, )
DEFINE FONT oFont2 NAME "Mono AS" SIZE 16,24 UNDERLINE BOLD

If Len(aItens)==1 .AND. Empty(aItens[oMonitor:nAt,2])
	Return
EndIf

For nI:=1 To Len(aItens)
	If aItens[nI,1]
		nPos := nI
		nCount++
	EndIf
Next

//Restaura a possicao
oMonitor:nAt := nPos
If Empty(nCount)
	MsgAlert(STR0028) /*Favor marcar o coletor que se deseja monitorar.*/
	Return
EndIf

If nCount > 1
	MsgAlert(STR0029)/*"ATENCAO: So eh permitido monitorar um RF. Selecione somente 1(um).*/
	Return
EndIf

If nMaxRow== 8 .and. nMaxCol==20
	nBottom := 294
	nRight  := 400
ElseIf nMaxRow== 2 .and. nMaxCol==20
	nBottom := 105
	nRight  := 400
ElseIf nMaxRow== 2 .and. nMaxCol==40
	nBottom := 105
	nRight  := 790
EndIf

VTScrToFile(cFile,{{},{}})
DEFINE MSDIALOG oWnd TITLE OemToAnsi(STR0035+aItens[oMonitor:nAt,2]) FROM 00,00 TO nBottom,nRight PIXEL /* Monitorando Coletor*/
TButton():New(if(nMaxrow==8,134,38),005, STR0005, oWnd, {|| lSai := .t.}, 38, 11,,, .F., .t., .F.,, .F.,,, .F. )/*Sair*/
aSayVt := Array(nMaxRow,nMaxCol,2)
For nI := 1 to nMaxRow 
	nCol := 3
	For nJ := 1 to nMaxCol 
		aSayVt[nI,nJ,2] := " "
		bBlock := &("{||aSayVt["+Str(nI,4)+","+Str(nJ,4)+",2]   }")
		aSayVt[nI,nJ,1] := TSay():New( nLin, nCol, bBlock,,,oFont, .F., .F., .F., .T.,,, 15, 17, .F., .F., .F., .F., .F. )
		nCol+=10
	Next
	nLin+=16
Next
ACTIVATE MSDIALOG oWnd CENTERED ON INIT Gerencia(cFile,aItens[oMonitor:nAt,2],oWnd)

While FErase(cFile) == -1 .and. file(cFile)
	Sleep(10)
End
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Gerencia()

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Static Function Gerencia(cFile,cNumTer,oWnd)
Local nI := 0
nI := 0
If lSai
	lSai := .F.
	While !lSai
		ProcessMessage()
		AtuMon(cFile,cNumTer,oWnd)
		sleep(1000)
	EndDo
	oWnd:End()
Else
	lSai := .T.
EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuMon()

@author Totvs
@since  18/08/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------    
Static Function AtuMon(cFile,cNumTer,oWnd)
Local nI,nJ := 0
Local aOldSay := {,,}
Local aLoad
Local __aScreen
Local __aReverso
Local nHTemp
Local oFile	:= Nil
Local cFileVt := 'VT'+cNumTer+'.SEM'

If ! File( cFileVt )
   lSai := .T.
   Return
Else
	oFile := FwFileReader():New( cFileVt )
	nHTemp := oFile:nHandLen
	oFile:Close()
	If nHTemp > 0
	   FErase( cFileVt )
	   lSai := .t.
	   Return
	EndIf

	aLoad := VTFileToScr( cFile )
	IF Len(aLoad) < 2
	   Return
	ENDIF
	__aScreen  := aLoad[1]
	__aReverso := aLoad[2]
	For nI:= 1 to Len(__aScreen)
	  If nI > Len(aSayVt) .or. lSai
	     Exit
	  EndIf
	  For nJ := 1 to Len(__aScreen[nI])
	     If nJ > Len(aSayVt[nI]) .or. lSai
	        Exit
	     EndIf

	     aOldSay[1] := aSayVt[nI,nJ,2]
	     aOldSay[2] := aSayVt[nI,nJ,1]:NCLRTEXT
	     aSayVt[nI,nJ,2] := SubStr(__aScreen[nI],nJ,1)

	     If SubStr(__aReverso[nI],nJ,1) == "0"
	        aSayVt[nI,nJ,1]:NCLRTEXT := CLR_BLACK
	        aSayVt[nI,nJ,1]:OFONT    := oFont
	     Else
	        aSayVt[nI,nJ,1]:NCLRTEXT := CLR_HRED //WHITE
	        aSayVt[nI,nJ,1]:OFONT    := oFont2
	     EndIf
	     If aSayVt[nI,nJ,2] # aOldSay[1] .or. aOldSay[2] # aSayVt[nI,nJ,1]:NCLRTEXT  // somente faz o refresh quando necessario
	        aSayVt[nI,nJ,1]:Refresh()
	     EndIf
	  Next nJ
	Next nI

	sleep(10)
	PROCESSMESSAGE()
EndIf
Return .t.
