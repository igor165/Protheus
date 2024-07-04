#INCLUDE "sigaacd.ch"
#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"

#DEFINE PDABOTTOM 234
#DEFINE PDARIGHT  234


Function SigaACD()
Local aUser    :={}
Local dGetData := MsDate()
Local tRealIni := Time()
Local aEmprx := {}
Local aEmpChoice := Array(2)
Local nPos
Local cArqMenu
Local nMaxRow := Val(GetPvProfString( "TELNET", "MAXROW" , "8" , GetADV97()))
Local nMaxCol := Val(GetPvProfString( "TELNET", "MAXCOL" , "20", GetADV97()))
Local lPDa    := GetPvProfString( "TELNET", "REMOTE" , "VT100", GetADV97())=="PDA"
Local aGroups := {}
Local nX 	  := 0
Local nY 	  := 0

MsApp():New('SIGAACD',.T.)
oApp:cInternet := NIL
oApp:lIsBlind := .T.
oApp:CreateEnv()

Private lVT100B := GetPvProfString( "TELNET", "REMOTE" , "VT100", GetADV97())=="VT100B"

if lVT100B
	nMaxRow := 04
	nMaxCol := 20
endif

If lPDa
	Private __cInternet:=NIL
	Private oMainWnd
	SetPDA() // seta para remote PDA POCKET
EndIf

If lPDa
	//seta tamanho da tela (linha X coluna)
	//MsgInfo("Automação em Coleta de Dados","SIGAACD")
Else
	//seta tamanho da tela (linha X coluna)
	VTSetSize(nMaxRow,nMaxCol)
	TerProtocolo("VT100")
	SetsDefault()
	VTAlert(STR0001+chr(13)+chr(10)+; //'Automacao de'
	STR0003+chr(13)+chr(10)+; //'Coleta de Dados'
	If(!lVT100B,chr(13)+chr(10),"")+; //lVT100B = terminal 4 linhas por 20 colunas
	STR0004,'SIGAACD',.T.)  //'Pressione <ENTER>'
EndIf


PtInternal(1,STR0008) //"Coletor RF"

If lPDa
	If ! PDAGetSenha(@dGetData,aUser)
		Final(STR0007) //"Termino Normal"
		Return
	EndIf
Else
	//login
	Private cUsuaFull := ''
	aUser := VTGetSenha(@dGetData,tRealIni)
	//Se tiver informações de acesso, grava no aEmprx, senão mantém em branco
	//trecho editado para concentrar as validações de grupo apenas dentro da função VTValGroup
	If !Empty(aUser[2][6])
		aEmprx := Aclone(aUser[2][6]) //lista empresas                  
	Else  
		aEmprx := {}
	EndIf
	aEmpChoice := VTNewEmpr(@aEmprx)
EndIf
dDataBase := dGetData

//acerta variaveis globais com informacoes do usuario
aEmpresas  := Aclone(aUser[2][6])
__RELDIR   := Trim(aUser[2][3])
__DRIVER   := AllTrim(aUser[2][4])
__IDIOMA   := aUser[2][2]
__GRPUSER  := ""
__VLDUSER  := aUser[1][6]
__ALTPSW   := aUser[1][8]
__CUSERID  := aUser[1][1]
__NUSERACS := aUser[1][15]
__AIMPRESS := {aUser[2][8],aUser[2][9],aUser[2][10],aUser[2][12]}
__LDIRACS  := aUser[2][13]
cAcesso    := Subs(cUsuario,22,512)
If __CUSERID #"000000"
	nPos := Ascan(aUser[3],{|x| Left(x,2)=="46"})
	If Empty(nPos)
		Final(STR0009,STR0010)  //"Acesso"###"Modulo nao encontrado"
	EndIf
	If Subs(aUser[3,nPos],3,1) =="X"
		Final(STR0009,STR0011)  //"Acesso"###"Modulo nao autorizado"
	EndIf
	If MPDicInDB()
		cArqMnu := Alltrim(Subs(aUser[3,nPos],4))
	Else
		cArqMenu := Alltrim(Subs(aUser[3,nPos],4))
		cArqMenu := Left(cArqMenu,len(cArqMenu)-4)
		cArqMnu := cArqMenu+RetExtMnu()
	EndIf
Else
	If MPDicInDB()
		nPos := Ascan(aUser[3],{|x| Left(x,2)=="46"})
		cArqMnu := Alltrim(Subs(aUser[3,nPos],4))
	Else
		cArqMnu := "SIGAACD"+RetExtMnu()
	EndIf
Endif
//cNivel  := aUsuario[2]
PtInternal(1,STR0012+cEmpAnt+"/"+cFIlAnt+STR0013+Subs(cUsuario,7,15)+STR0014) //"Emp :"###" Logged :"###" Equip:Coletor RF"
If lPDa
	PDAWindow(cArqMnu)
Else
	VTCLEAR
	//gerenciamento do menu
	VTDefKey()
	VTMontaMenu(cArqMnu)
EndIf
Final(STR0007) //"Termino Normal"
Return

// funcoes para tratamento pda
Static Function PDAWindow(cArqMnu)
Local oMenu
Local cMenuBmp :=GetMenuBmp()
Local aMenu := XNULoad(cArqMnu,.F.)
Local nX
Local cNameObj
Local oMainPanel

PRIVATE oShortList
PRIVATE AdvFont

PUBLIC lLeft := .F.

DEFINE MSDIALOG oMainWnd TITLE "SigaACD"   FROM 0,0 TO PDABOTTOM,PDARIGHT  PIXEL
//DEFINE WINDOW oMainWnd FROM 0,0 TO PDABOTTOM,PDARIGHT PIXEL TITLE "SigaACD" NO MAXIMIZE
@00,00 MSPANEL oMainPanel SIZE 120,25 of oMainWnd
oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

MENU oMenu IMAGE cMenuBmp
	For nX:=1 to len(aMenu)
		If aMenu[nX,2]=="E"
			MENUITEM aMenu[nX,1,1]
			AdMenu(aMenu[nX,3])
		EndIf
	Next
	MENUITEM STR0015 ACTION  (lSai:= .t.,oMainWnd:End()) //"Sair"
ENDMENU

oMenu:align:= CONTROL_ALIGN_LEFT
oMainWnd:SetMenu( oMenu )
oMainWnd:SetColor(CLR_BLACK,CLR_WHITE)
oMainWnd:Cargo := oShortList
oMainWnd:oFont := AdvFont
oMainWnd:nClrText := 0
oMainWnd:lEscClose := .F.
oMainWnd:ReadClientCoors()

SET MESSAGE OF oMainWnd TO  SM0->(STR0016+': '+M0_CODIGO+' '+STR0021+': '+FWCODFIL()) NOINSET //"Empresa"###'Filial'
DEFINE MSGITEM oMsgItem0 OF oMainWnd:oMsgBar PROMPT ' ' SIZE 10
DEFINE MSGITEM oMsgItem1 OF oMainWnd:oMsgBar PROMPT dDataBase SIZE 60

//ACTIVATE WINDOW oMainWnd
ACTIVATE MSDIALOG oMainWnd
Return .t.

Static Function AdMenu(aMenuItem)
Local nX
Local cNameObj
MENU
	For nX:=1 to len(aMenuItem)
		If aMenuItem[nX,2]=="E"
			If ValType(aMenuItem[nX,3])=="A"
				MENUITEM aMenuItem[nX,1,1]
				AdMenu(aMenuItem[nX,3])
			Else
				If aMenuItem[nX,2]=="E"
					cNameObj :=aMenuItem[nX,1,1]
					MenuAddItem( ( cNameObj ),, .F.,, MontaBlock("{|| __Execute('"+aMenuItem[nX,3]+'()'+"','"+aMenuItem[nX,5]+"','"+cNameObj+"','"+aMenuItem[nX,6]+"')}"),,,,,,, .F. )
				EndIf
			EndIf
		EndIf
	Next
ENDMENU
Return

Static Function PDAGetSenha(dGetData,aUser)
Local lRet :=.f.
Local oData
Local oUsuario
Local cUsuario	:= Space(15)
Local opassw
Local cpassw	:= Space(06)
Local oEmp
Local cEmp		:= Space(20)
Local aEmp		:= {""}
Local oMainPanel
Local oDlg

Private nVezes := 1

DEFINE MSDIALOG oDlg TITLE STR0017 FROM 0,0 TO PDABOTTOM,PDARIGHT  PIXEL //"Login de Acesso"
	@00,00 MSPANEL oMainPanel SIZE 120,25 of oDLG
	oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 06 , 10 Say STR0018 PIXEL of oMainPanel //"Data"
	@ 14 , 10 MSGET oData VAR dGetData Picture "@D" SIZE 45,09 VALID ! Empty(dGetData) PIXEL of oMainPanel

	@ 26 , 10 Say STR0019 PIXEL of oMainPanel //"Usuario"
	@ 26 , 70 Say STR0020 PIXEL of oMainPanel //"Senha:"

	@ 34 , 10 MSGET oUsuario	VAR cUsuario	Picture "@!" SIZE 55,09 PIXEL of oMainPanel
	@ 34 , 70 MSGET opassw		VAR cpassw		Picture "@!" SIZE 40,09 PASSWORD VALID VldUser(@cUsuario,@cPassw,oDlg,aUser,oEmp) PIXEL of oMainPanel

	@ 46 , 10 Say STR0016+"/"+STR0021 PIXEL of oMainPanel //"Empresa/Filial"
	@ 54 , 10 MSCOMBOBOX oEmp VAR cEmp ITEMS aEmp SIZE 100,09 PIXEL of oMainPanel


	DEFINE SBUTTON FROM 105,056 TYPE 1 ACTION (lRet := .t.,AbreArq(oEmp,cUsuario,cPassw),oDlg:End()) ENABLE OF oDlg PIXEL	WHEN ! Empty(cEmp)
	DEFINE SBUTTON FROM 105,086 TYPE 2 ACTION (lRet := .f., oDlg:End()) ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg

Return lRet


Static Function AbreArq(oEmp,cUsuario,cPassw)
Local cNumEmp:= Left(oEmp:aItems[oEmp:nAt],2)
Local cFil   := Subs(oEmp:aItems[oEmp:nAt],4,2)

Processa({|| AbreTabelas(cNumEmp,cFil,cUsuario,cPassw)},,STR0022) //"Abrindo tabelas"

Return

Static Function AbreTabelas(cEmp,cFil,cUsuario,cPassw)
	RpcSetEnv (cEmp,cFil,cUsuario,cPassw,'ACD',, )
	SetsDefault()
	PtInternal(1,"Equip:PDA Logged:"+cUserName+" "+STR0012+cEmpAnt+"/"+cFIlAnt) //"Emp:"
	__cInternet:=NIL
Return

Static Function VldUser(cUsuario,cPassw,oDlg,aUser,oEmp)

Local lRet := .t.
Local aAux := {}
Local oUser   := MPUserAccount():New()
Local nRetorno:= 0

// ---------------------------------------
// Inicializa a classe de autenticação de usuário
// ---------------------------------------
oUser:Activate()
// ---------------------------------------
// Verifica se a autenticação pelo SO é válida
// ---------------------------------------
nRetorno := oUser:SignOnAuthentication(.T.)
If nRetorno == 0
	nRetorno :=  oUser:Authentication(cUsuario,cPassw)
	If nRetorno == 0
		MsgAlert(STR0024) //"Usuario nao autorizado"
		lRet := .f.
	EndIf
EndIf
If lRet
	__Ap5NoMv(.T.)
	aUser := PswRet()
	__Ap5NoMv(.F.)
	cUsuario := aUser[1,2]
	aAux:= aClone(aEmpresa(Aclone(aUser[2][6])))
	oEmp:SetItems(aClone(aAux))
	oEmp:Refresh()
	//Proteção para evitar error.log 
	If !valtype(aUser[2][8]) = 'N'
		aUser[2][8] := 0
	EndIf
	If !valtype(aUser[2][9]) = 'N'
		aUser[2][9] := 0
	EndIf
	If !valtype(aUser[2][10]) = 'N'
		aUser[2][10] := 0
	EndIf	
EndIf

If ! lRet
	cUsuario := Space(15)
	cpassw   := Space(06)
EndIf
Return lRet

Static Function aEmpresa(aEmprx)
Local aChoice := {}

OpenSM0()
DbSelectArea("SM0")
DbGoTop()
FWCODFIL()
//Monta o Arvore de Empresas
If Empty(aEmprx)
	Final(STR0024) //"Usuario nao autorizado"
EndIf

If aEmprx[1] == [@@@@]
	aEmprx := {}
	DbEval({|| Aadd(aEmprx,M0_CODIGO+FWCODFIL())})
Endif

If Empty(aEmprx)
	Final(STR0023) //"Arquivo Empresa Corrompido"
EndIf

DbGoTop()
While !Eof()
	If Ascan(aEmprx,M0_CODIGO+FWCODFIL()) <> 0
		Aadd(aChoice,M0_CODIGO+'-'+FWCODFIL()+' '+Trim(Upper(M0_NOME))+' / '+Trim(Upper(M0_FILIAL)))
	EndIf
	DbSkip()
End
Return aClone(aChoice)
