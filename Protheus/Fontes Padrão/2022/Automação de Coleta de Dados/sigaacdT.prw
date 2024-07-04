#INCLUDE "sigaacdT.ch" 
//#INCLUDE "sigaacd.ch"
#include "protheus.ch"
#include "apvt100.ch"
                          
                          
Function SigaACDM(nTeclas)                              
Local cOpcao

Private lVT100B := GetPvProfString( "TELNET", "REMOTE" , "VT100", GetADV97())=="VT100B"

VTSetSize(2,20)  

cOpcao:= "1"
VTClear() 
@ 0,0 VTSAY STR0001 //"1.RF  2.MT44  3.MT16"
@ 1,0 VTSAY STR0002 VTGET cOpcao pict "9" //"Selecione: "
VTRead                           
If cOpcao =="1"
   SigaACD()
ElseIf cOpcao =="2"
   SigaACDT(44)
ElseIf cOpcao =="3"
   SigaACDT(16)
Else
   Vtclear()
   @ 0,0 VtSay STR0003 //"Opcao invalida          "
   Sleep(3000)
EndIf
Return

Function SigaACDT(nTeclas)
Local aUser
Local dGetData := MsDate()
Local tRealIni := Time()
Local aEmprx := {}
Local aEmpChoice := Array(2)
Local cTmp
Local nPos
Local cArqMenu     
Local aGroups := {}  
Local nX 	  := 0
Local nY 	  := 0
DEFAULT nTeclas:=44

lVT100B := If(Type("lVT100B") == "L",lVT100B,GetPvProfString("TELNET","REMOTE","VT100",GetADV97())=="VT100B")

MsApp():New('SIGAACD',.T.)
oApp:cInternet := NIL
oApp:lIsBlind := .T.
oApp:CreateEnv()

//seta tamanho da tela (linha X coluna)
VTSetSize(2,If(nTeclas == 44,40,20))  
//configuracoes para microterminais
TerProtocolo("VT100") 
VTFillGet("_")       
TerModelo(VTModelo())             
//
SetsDefault()        
VTAlert(STR0004,STR0005,.T.)   //'Automacao de Coleta de Dados - Pressione <ENTER>'###'SIGAACD'

PtInternal(1,STR0006) //"Equip. Microterminal"

//login
Private cUsuaFull := ''
aUser := VTGetSenha(@dGetData,tRealIni)

If !Empty(aUser[2][6])
		aEmprx := Aclone(aUser[2][6]) //lista empresas                  
Else  
	aGroups := FWSFUsrGrps(aUser[1][1])
	If !aUser[2][11]	
		For nX := 1 To Len (aGroups)
			aEmprAux 	:= FWGrpEmp(aGroups[nX])
			For nY := 1 to Len (aEmprAux)
				If Ascan (aEmprx, {|x| x == aEmprAux [nY]}) == 0
					aAdd (aEmprx, aEmprAux [nY])
				EndIf 
			Next nY
		Next nX
	Else
		aEmprAux 	:= FWGrpEmp(aGroups[1])
		For nY := 1 to Len (aEmprAux)
			If Ascan (aEmprx, {|x| x == aEmprAux [nY]}) == 0
				aAdd (aEmprx, aEmprAux [nY])
			EndIf 
		Next nY
	EndIf			
EndIf

//lista empresas
aEmpChoice := VTNewEmpr(@aEmprx)

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
		Final(STR0007,STR0008)  //"Acesso"###"Modulo nao encontrado"
   EndIf	
   If Subs(aUser[3,nPos],3,1) =="X"
	   Final(STR0007,STR0009)  //"Acesso"###"Modulo nao autorizado"
   EndIf              
   cArqMenu := Alltrim(Subs(aUser[3,nPos],4))
   cArqMenu := Left(cArqMenu,len(cArqMenu)-4)
//   cArqMnu := cArqMenu+RetExtMnu()
Else 
   cArqMnu := "SIGAACDT"+RetExtMnu()
Endif   
cArqMnu := "SIGAACDT"+RetExtMnu()
//cNivel  := aUsuario[2]

VTCLEAR
PtInternal(1,STR0010+cEmpAnt+"/"+cFIlAnt+STR0011+Subs(cUsuario,7,15)+STR0012) //"Emp :"###" Logged :"###" Equip:Microterminal"

//gerenciamento do menu
VTDefKey()
VTMontaMenu(cArqMnu)

Final(STR0007) //"Termino Normal"
Return


