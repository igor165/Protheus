#include "protheus.ch"
#include "apvt100.ch"
#INCLUDE "SIGAVT.CH"

Function SigaVT()
Local aUser
Local dGetData := MsDate()
Local tRealIni := Time()
Local aEmprx := {}
Local aEmpChoice := Array(2)
Local cTmp

Public __cInterNet   := NIL
Public oMainWnd      := NIL
Public nModulo       := 98
Public cModulo       := "VT"
Public dDataBase     := dGetData
Public cUsuario      := ""
Public __RpcSxNoOpen := .T.

//seta tamanho da tela (linha X coluna)
VTSetSize(23,80)
SetsDefault()
VTSetAp5Menu(.T.)



VTAlert('Video Terminal'+chr(13)+chr(10)+;
        chr(13)+chr(10)+;
		chr(13)+chr(10)+;
		chr(13)+chr(10)+;
		'Pressione <ENTER>','SIGAVT',.T.)

PtInternal(1,"Emp :/ Logged : Obj :Main Window")

//login
aUser := VTGetSenha(@dGetData,tRealIni)
aEmprx := Aclone(aUser[2][6])
cTmp := cUsuario

//lista empresas
aEmpChoice := VTNewEmpr(@aEmprx)

RpcSetEnv(aEmpChoice[1],aEmpChoice[2])

__cInterNet:= NIL
lMsHelpAuto	:= .F.
dDataBase   := dGetData
tInicio     := tRealIni
nModulo     := 98
cModulo     := "VT"
cUsuario    := cTmp
cTmp        := ""

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

cArqMnu := "SIGAVT"+RetExtMnu()
//cNivel  := aUsuario[2]

VTCLEAR
PtInternal(1,"Emp :"+cEmpAnt+"/"+cFIlAnt+" Logged :"+Subs(cUsuario,7,15)+" Obj :Main Window")

//gerenciamento do menu
VTDefKey()
VTMontaMenu(cArqMnu)

Final(STR0003)//"Termino Normal"
Return