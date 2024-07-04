#INCLUDE 'SIGATMS.ch'
#INCLUDE 'PROTHEUS.ch'

#DEFINE cVerAdv  '99'
#DEFINE cResAdv  'ADVB'
#DEFINE TAB   	CHR( 9 )
#DEFINE SRCPAINT	15597702	// 0xEE0086
#DEFINE SRCAND 	8913094

/*                                                   								
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa  บ  SIGATMS   บ Autor บ  Richard Anderson  บ Data บ 01/10/01 บฑฑ
ฑฑฬอออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ          SIGATMS  - Gestao de Transportes - PROTHEUS				  		  บฑฑ
ฑฑฬอออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe   บ SIGATMS( cInternet )                                      บฑฑ
ฑฑฬอออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametrosบ                                        			           บฑฑ
ฑฑบ        01 บ cInternet - Chamada Externa             			           บฑฑ
ฑฑฬอออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno   บ NIL                                                       บฑฑ
ฑฑบอออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso       บ TMS - Gestao de Transportes 		            	           บฑฑ
ฑฑฬอออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ         Atualizacoes efetuadas desde a codificacao inicial            บฑฑ
ฑฑฬอออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramadorบ Data   บ BOPS บ  Motivo da Alteracao                      บฑฑ
ฑฑฬอออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           บxx/xx/01บxxxxxxบ                                           บฑฑ
ฑฑศอออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function SIGATMS(cInternet)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinir variaves de memoria														 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRetMod    := RetModName()
Local cTitle     := ''
Local nTitle     := 0
Local oAni
Local oBar
Local oFont
Local oIco
Local oLogo
Local oUserBar

Public lLeft      := .F.
Public oMainWnd

Public __lPyme := .F.

Private _NomeExec := 'SIGATMS.EXE'
Private oShortList

Private aAmbientes :={}                // Ambientes do Usuario
Private uSigaADV   :=.F.               // Provisoria !!!!
Private nCampos    := 200              // Numero de campos no help

calc       := .F.                      // Calculadora ja/nao ativa
agen       := .F.                      // Agenda ja/ano ativa
help       := .F.                      // Help ja/nao ativo
lInUtil    := .F.
f_ASK      := 'askfor'                 // Nome da rotina de perguntas p/MENUH
dDataBase  := MsDate()                 // Data padrao do sistema
Have_a_Mouse := .F.                    // Se existe um mouse instalado
cArqTel    := 'SIGATMS.SCR'            // Nome do arquivo de telas
cArqHlp    := 'SIGAADV'+RetExtHlp()    // Nome do arquivo de HELP
cArqMnu    := 'SIGATMS'+RetExtMnu()    // Nome do arquivo de Menu
cArqPsw    := 'SIGAMAT.PSW'            // Nome do arquivo de senhas
cArqEmp    := 'SIGAMAT.EMP'            // Nome do arquivo de Empresas/Filiais
cArqRel    := 'SIGATMS.REL'            // Nome do arquivo de Relatorios
cArqAlca   := 'SIGAMAT.ALC'            // Nome do arquivo de Alcadas
cAcesso    := Replicate('S',128)       // Nivel de Acesso (SENHA)
cEmpAut    := ''                       // Empresas Autorizadas
cEmpAnt    := ''
cNumEmp    := ''
cFilAnt    := ''
cArqTab    := ''
cMestra    := ''
cSenha     := ''
cFOPENed   := ''                       // Arquivos Abertos
cFuncao    := 'GetEmpr'
MouseRet   := ''                       //Mudado Retorno do Mouse
aMenus     := {}
aEmpresas  := {}
tInicio    := TIME()                   // Hora de Inicio
D_String   := 'ACRM'                   // Letras para selecao do menu
nOpc0      := 1
cVersao    := GetVersao()
cNomEmp    := Space(15)
cNomFil    := Space(15)
nCodEmp    := 1
nModulo    := 43                       // Codigo do Modulo TMS (Transportation Management System)
nPosMnu    := 0
cModulo    := 'TMS'                    // Prefixo do Modulo
cUsuario   := ''
cNivel     := 9
lTes	     := .T.                      // Para cadastro do TES

Private MV_RELT    := ''
Private MV_CENT    := ''
Private MV_MILHAR  := ''
Private MV_SIMB1   := ''
Private MV_SIMB2   := ''
Private MV_SIMB3   := ''
Private MV_SIMB4   := ''
Private MV_SIMB5   := ''

Private AdvFont
Private AcBrowse
Private a_FILES[0]
Private nOpt01     := 1
Private nOpt02     := 1
Private nOpt03     := 1
Private nOpt04     := 1
Private aTrigger   := {}               // Para controle de Gatilhos
Private __cInterNet:= Nil
Private __cBinder  := Nil
Private __cTerminal:= Nil

Private _lAS400 := ( TcSrvType()="AS/400" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณChamada para Binder																	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Valtype(cInternet) == 'C'
	If Subs(cInternet,1,2)=='*-'
		__cBinder := cInternet
		xc := Subs(__cBinder,17,15)
		xcUsuario := ''
		For xy:=1 to Len( xc )
			xcUsuario += If( Subs(xc,xy,1) == '|' , ' ' , Subs(xc,xy,1) )
		Next xy
		If DiskChange( Subs(AllTrim(Subs(__cBinder, 34)),1,2) )
			nResult := DIRCHANGE( AllTrim(Subs(__cBinder, 34)) )
		EndIf
		__cInternet := Nil
	EndIf
EndIf

If ValType(cInterNet) == 'C'
	If '.TMP'$Upper(cInterNet)
		__cInterNet := cInterNet
		lChDir(GetInternet('WORK'))
	EndIf
EndIf

SetsDefault()

If __cInternet == Nil .and. Empty(__cBinder)
	Splash(STR0001,OemToAnsi(cVersao) ) //'Gestใo de Transporte'
EndIf

#IFDEF DEBUG
	Public nDebug := MSFCREATE('DEBUG.TXT',0)
#ENDIF

DEFINE FONT AdvFont NAME 'MS Sans SerIf' SIZE 0, -9
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEndereca a rotina que faz diagnosticos 										 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aOpt1[0],aOpt2[0],aOpt3[0],aOpt4[0]
Private aOpt1m[0],aOpt2m[0],aOpt3m[0],aOpt4m[0]

//Procura Caption na RetModName
nTitle := Ascan(aRetMod,{|x| x[1] == nModulo})
If nTitle == 0
	cTitle := OemToAnsi(STR0001) //'Gestใo de Transporte'
Else
	cTitle := aRetMod[nTitle][3]
EndIf

DEFINE WINDOW oMainWnd FROM 1, 1 TO 22, 75 TITLE cTitle

oMainWnd:SetMenu( MontaMenu(cArqMnu,.T.) )

oMainWnd:oFont := AdvFont
oMainWnd:nClrText := 0

MainToolBar(@oBar)

SET MESSAGE OF oMainWnd TO oEmToAnsi(cVersao)  NOINSET FONT oFont
DEFINE MSGITEM oMsgItem0 OF oMainWnd:oMsgBar PROMPT '     ' SIZE 50

DEFINE MSGITEM oMsgItem1 OF oMainWnd:oMsgBar PROMPT dDataBase SIZE 100 ACTION ChangeDate()
DEFINE MSGITEM oMsgItem2 OF oMainWnd:oMsgBar PROMPT Substr(cUsuario,1,6) SIZE 100  //ACTION GetNewPass(Substr(cUsuario,1,6),.T.)
DEFINE MSGITEM oMsgItem3 OF oMainWnd:oMsgBar PROMPT 'Microsiga / '+STR0002 SIZE 180  ACTION GetEmpr() //'Matriz'
DEFINE MSGITEM oMsgItem4 OF oMainWnd:oMsgBar PROMPT 'Ambiente' SIZE 180  ACTION GetAmb()

If !lLeft
	oAni := MSAniCreate( 0, 580, 60, 60, cResAdv,, .T., oMainWnd:oBar,{ |nRow,nCol,nKeyFlags| InterNetBrowser() },{ |nRow,nCol,nKeyFlags| oAni:AniPopUp() },,, .F.,, .T.,, .F., 21, 250,9,.F.)
Else
	oAni := MSAniCreate( 0, 0, 180, 60,, 'ADVC', .T., oMainWnd:oBar,,{ |nRow,nCol,nKeyFlags| (If(!oAni:Active,oAni:Activate(),oAni:DeActivate())) },,, .F.,, .T.,, .F., 11, 350,7,.F.)
	MSAniSetColor( oAni,CLR_WHITE,CLR_WHITE )
EndIf
MSAniGotop( oAni )
oMainWnd:SetColor(CLR_BLACK,CLR_WHITE)


oMainWnd:bResized := {|x,nWidth,nHeight| ResizeWnd(oAni,nWidth,nHeight,oShortList),If(oLogo # Nil,WndCenter(oLogo:hWnd),)}
oMainWnd:Cargo := oShortList

ACTIVATE WINDOW oMainWnd MAXIMIZED;
	VALID  IIf(Abandona(),Final(STR0003),.F.); //'Trmino Normal'
	ON INIT (ShowMsLogo(@oLogo),;
	MSAniActivate(oAni),;
	Abertura(oMainWnd),;
	UserToolBar(@oUserBar),;
	MSAniUserDef( oAni,.t. ) ) ;
	ON RIGHT CLICK ShortCut(oShortList,oMainWnd,nRow,nCol)

RELEASE OBJECTS oFont, oShortList

SET RESOURCES TO

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ WriteDbg ณ Autor ณ Ary Medeiros			  ณ Data ณ 05/07/95 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao auxiliar para Depuracao 24 Horas						  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ SIGA24 - Compilar com /dDEBUG 									  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
#IFDEF DEBUG
	Function WriteDbg(cFunction,cValor)
	FWrite(nDebug,cFunction+': '+cValor+CHR(13)+CHR(10))
	Return Nil
#ENDIF
