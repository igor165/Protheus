#INCLUDE "PROTHEUS.CH"
#INCLUDE "VTXFUN.ch"
#INCLUDE "apvt100.ch"
#Include "FWMVCDEF.CH"
#INCLUDE "Fwlibversion.ch"

#DEFINE TAMUSR 25
#DEFINE TAMPSW 20

Static __lVTAp5Mnu
Static __cVtModelo
Static __lMenu:= .T.
Static __oUserAcc
Static _cLanguage := FwRetIdiom()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VTMontaMenu³ Autor ³ Sandro              ³ Data ³ 15/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Menu do Siga                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ simulador VT100                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VTMontaMenu(cMenu)
Local ni
Local aMenu:={}
Local nCol1
Local nCol2
Local cTitle
Local cPrgInic := If(VtModelo()="RF","SIGAACD","SIGAACDT")
Local aParte1  :={}
Local aParte2  :={}
Local aParte3  :={}
Local aPrincipal:=	{{1,STR0001},; //"Atualizacoes"
	{2,STR0002},; //"Consulta"
	{3,STR0043},; //"Relatorios"
	{4,STR0003},; //"Micelaneas"
	{5,STR0004}} //"Sair"
Local aGrupo:= {}
Local aOpcoes:={}
Local aTables:={}
Local nIncGrupo:=0

Local nOpcao1:=1
Local nOpcao2:=1
Local nOpcao3:=1
Local aScr:={}

Local cOpcao1:=''
Local cOpcao2:=''
Local nIdTimer:= 0
Local cCodOpe:=''
Local lAcdUser	:= .F.
Local lVTXENDCPL := ExistBlock("VTXENDCPL")
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf


If ExistBlock("VTXINICPL")
	ExecBlock("VTXINICPL",.F.,.F.)
EndIf

If Type("cUsuaFull") <> "C" .Or. Empty(cUsuaFull)
	cUsuaFull:= PADR(Substr(cUsuario,1,6),TAMPSW) + PADR(Substr(cUsuario,7,15),TAMUSR) + Substr(cUsuario,22)
EndIf

SetFunName(Space(8))
/*
aGrupo
1 -> ID pai
2 -> titulo
3 -> ID
4 -> acesso MBROWSE
5 -> modulo

aOpcoes
1 -> ID pai
2 -> titulo
4 -> acesso MBROWSE
5 -> modulo
*/

//Abre a tabela
DbSelectArea("SX6")
lAcdUser := SuperGetMv("MV_ACDUSER",.F.,.F.)

aMenu := XNULoad (cMenu,.F.)
For ni := 1 To Len(aMenu)
	VTBuildMenu(@aGrupo,@aOpcoes,@aTables,ni,aMenu[ni][3],@nIncGrupo)
Next

aadd(aGrupo,{4,STR0007,,'VTChangePass','',''}) //'Senhas'

// Verifica se usuário já está logado
If lAcdUser .And. VTUsrLog(Substr(cUsuario,7,15))
	VTAlert(STR0066,STR0024,.T.,2500)  // Usuario já está logado! // Atencao
	Return
EndIf

// Abertura dos arquivos
VTOpenFile(cNumEmp)
VTCLEAR
cTitle := AllTrim(cVersao)+' - SIGA'+cModulo
cTitle := If(VTSetAp5Menu(),cTitle,Padr(cTitle,VTMaxCol()))
If ! Empty(CBRetOpe())  .and. ! Empty(CB1->CB1_INTER)
	cCodOpe := CB1->CB1_CODOPE
	nIdTimer := VTAddTimer(&("{|| CBChkMsg('"+cCodOpe+"')}"),CB1->CB1_INTER*1000)
End

While .t.
	PtInternal(1,"Emp :"+cEmpAnt+"/"+cFIlAnt+" Logged :"+Padr(Subs(cUsuario,7,15),15)+" RF="+cPrgInic+' Obj :Main Window')
	VTAtuSem(cPrgInic,Space(50))
	VTSay(0,0,cTitle)
	aParte1:={}
	VTReverso(.f.)
	aMenu :=aClone(VTGeraMenu("P",aPrincipal,NIL,aParte1))
	If nCol1 == NIL .And. VTSetAp5Menu()
		nCol1 := 0
		Aeval(aMenu,{|x,y| If(Len(x) > nCol1,nCol1 := Len(x),)})
		nCol1 += 5
	EndIf
	If __cVtModelo=="RF"
		nOpcao1:=VTaChoice(2,0,VTMaxRow(),VTMaxCol(),aMenu,,,nOpcao1)
	ElseIf __cVtModelo=="MT16"
		nOpcao1:=VTaChoice(0,0,VTMaxRow(),VTMaxCol(),aMenu,,,nOpcao1)
	ElseIf __cVtModelo=="MT44"
		nOpcao1:=VTaChoice(0,20,VTMaxRow(),VTMaxCol(),aMenu,,,nOpcao1)
	EndIf
	If nOpcao1 == 0
		If VTSair()
			If lVTXENDCPL
				ExecBlock("VTXENDCPL",.F.,.F.)
			EndIf
			Exit
		EndIf
		nOpcao1 := 1
		Loop
	ElseIf nOpcao1 == 5   // sair
		VTInkey()
		IF VTSair()
			If lVTXENDCPL
				ExecBlock("VTXENDCPL",.F.,.F.)
			EndIf
			Exit
		EndIf
		Loop
	EndIf

	nOpcao2:= 1
	cOpcao1:=Padr(aMenu[nOpcao1],VTMaxCol())
	While .t.
		aParte2:={}
		VTReverso(.f.)
		aMenu :=aClone(VTGeraMenu('G',aGrupo,aParte1[nOpcao1,1],aParte2))
		If nCol2 == NIL .And. VTSetAp5Menu()
			nCol2 := 0
			Aeval(aMenu,{|x,y| If(Len(x) > nCol2,nCol2 := Len(x),)})
			nCol2 := nCol1+nCol2+5
		EndIf
		If len(aMenu) <= 0
			Exit
		EndIf
		If VTSetAp5Menu()
			nOpcao2:=VTaChoice(3,nCol1,VTMaxRow(),VTMaxCol(),aMenu,,,nOpcao2)
		Else
			VTSay(0,0,cOpcao1)
			If __cVtModelo=="RF" .or. lVT100B //lVT100B = terminal 4 linhas por 20 colunas
				nOpcao2:=VTaChoice(2,0,VTMaxRow(),VTMaxCol(),aMenu,,,nOpcao2)
			ElseIf __cVtModelo=="MT16"
				nOpcao2:=VTaChoice(0,0,VTMaxRow(),VTMaxCol(),aMenu,,,nOpcao2)
			ElseIf __cVtModelo=="MT44"
				nOpcao2:=VTaChoice(0,20,VTMaxRow(),VTMaxCol(),aMenu,,,nOpcao2)
			EndIf
		EndIf
		If nOpcao2 == 0
			Exit
		EndIf
		If ! Empty(aParte2[nOpcao2,3])
			aScr:=VTSave()
			vtclear()
			VtInkey()
			__lMenu := .f.
			VTDefKey()
			VTAtuSem(cPrgInic,Left(aParte2[nOpcao2,3],10)+' - ['+aParte2[nOpcao2,2]+']')
			PtInternal(1,"Emp :"+cEmpAnt+"/"+cFIlAnt+" Logged :"+Padr(Subs(cUsuario,7,15),15)+" RF="+cPrgInic+' Obj :'+aParte2[nOpcao2,3])
			__Execute(aParte2[nOpcao2,3]+'()',aParte2[nOpcao2,4],aMenu[nOpcao2],aParte2[nOpcao2,5])
			If InTransact()
				While InTransact()
					FimTran()
				EndDo
				ConOut("Error on function "+aParte2[nOpcao2,3]+" - Call end transaction ")
			EndIf
			VTAtuSem(cPrgInic,Space(50))
			__lMenu := .t.
			VTDefKey()
			VTRestore(,,,,aScr)
			Loop
		EndIf
		nOpcao3:= 1
		cOpcao2:=Padr(aMenu[nOpcao2],VTMaxCol())
		While .t.
			aParte3:={}
			VTReverso(.f.)
			aMenu :=aClone(VTGeraMenu('I',aOpcoes,aParte2[nOpcao2,1],aParte3))
			If len(aMenu) <= 0
				Exit
			EndIf
			If VTSetAp5Menu()
				nOpcao3:=VTaChoice(4,nCol2,VTMaxRow(),VTMaxCol(),aMenu,,,nOpcao3)
			Else
				VTSay(0,0,cOpcao2)
				If __cVtModelo=="RF"
					nOpcao3:=VTaChoice(2,0,VTMaxRow(),VTMaxCol(),aMenu,,,nOpcao3)
				ElseIf __cVtModelo=="MT16"
					nOpcao3:=VTaChoice(0,0,VTMaxRow(),VTMaxCol(),aMenu,,,nOpcao3)
				ElseIf __cVtModelo=="MT44"
					nOpcao3:=VTaChoice(0,20,VTMaxRow(),VTMaxCol(),aMenu,,,nOpcao3)
				EndIf
			EndIf
			If nOpcao3 == 0
				Exit
			EndIf
			aScr:=VTSave()
			vtclear()
			VtInkey()
			__lMenu := .f.
			VTDefKey()
			VTAtuSem(cPrgInic,Left(aParte3[nOpcao3,3],10)+' - ['+aParte3[nOpcao3,2]+']')
			PtInternal(1,"Emp :"+cEmpAnt+"/"+cFIlAnt+" Logged :"+Padr(Subs(cUsuario,7,15),15)+" RF=SIGAACD"+' Obj :'+aParte3[nOpcao3,3])
			__Execute(aParte3[nOpcao3,3]+'()',aParte3[nOpcao3,4],aMenu[nOpcao3],aParte3[nOpcao3,5])
			If InTransact()
				While InTransact()
					FimTran()
				EndDo
				ConOut("Error on function "+aParte3[nOpcao3,3]+" - Call end transaction ")
			EndIf
			VTAtuSem(cPrgInic,Space(50))
			VTRestore(,,,,aScr)
			__lMenu := .t.
			VTDefKey()
		End
	End
End
IF nIdTimer # 0
	VTDelTimer(nIdTimer)
EndIf
VTDisConnect()
Return

Function IsVtMenu()
Return __lMenu

Static Function VTBuildMenu(aGrupo,aOpcoes,aTables,nID,aMenu,nIncGrupo)
Local ni
Local cTitle
Local cStatus
Local aTmp
Local nJ

For ni := 1 To Len(aMenu)
	cStatus := aMenu [nI][2]
	If ( cStatus == 'H' )
		Loop
	EndIf

	If ( _cLanguage == 'es' )
		cTitle := aMenu [nI][1][2]
	ElseIf ( _cLanguage == 'en' .Or. _cLanguage == 'ru' )
		cTitle := aMenu [nI][1][3]
	Else
		cTitle := aMenu [nI][1][1]
	EndIf

	If ( ValType( aMenu [nI][3] ) == 'A' )
		nIncGrupo++
		Aadd(aGrupo,{nID,cTitle,nIncGrupo,Space(10),Replicate("x",10),Space(10)})
		If ( cStatus == 'E' )
			VTBuildMenu(@aGrupo,@aOpcoes,@aTables,nIncGrupo,aMenu [nI][3], @nIncGrupo)
		EndIf
	Else
		If ( cStatus <> 'D' )
			aTmp := aMenu [nI][4]
			For nJ := 1 To Len( aTmp )
				If ( AScan( aTables, aTmp [nJ] ) == 0 )
					Aadd( aTables, aTmp [nJ] )
					If !Empty(cFOpened)
						cFOpened += ';'
					EndIf
					cFOpened += aTables[nJ]
				EndIf
			Next
			Aadd(aOpcoes,{nID,cTitle,aMenu [nI][3],aMenu [nI][5],aMenu [nI][6]})
		EndIf
	EndIf
Next
Return

//Funcao de auxilio para a funcao VTMontaMenu
Static Function VTGeraMenu(cTipo,aVetor,nchave,aParte)
Local aRetorno := {}
Local nX       := 0
aParte:={}
If cTipo =='P'  //principal
	For nX := 1 to len(aVetor)
		aadd(aRetorno,Capital(aVetor[nx,2]))
		aadd(aParte,aVetor[nx])
	Next
ElseIf cTipo =='G' //Grupo
	For nX := 1 to len(aVetor)
		If aVetor[nX,1]== nChave
			aadd(aRetorno,Capital(aVetor[nx,2]))
			aadd(aParte,{aVetor[nx,3],aVetor[nx,2],aVetor[nx,4],aVetor[nx,5],aVetor[nx,6]})
		EndIf
	Next
ElseIf cTipo =='I' //Itens
	For nX := 1 to len(aVetor)
		If aVetor[nX,1]== nChave
			aadd(aRetorno,Capital(aVetor[nx,2]))
			aadd(aParte,{aVetor[nx,1],aVetor[nx,2],aVetor[nx,3],aVetor[nx,4],aVetor[nx,5]})
		EndIf
	Next
EndIf
Return aRetorno


Function VTFinal(cStr,cStr1)
Local cMsg    := ""
Local cNomMod := "SIGA"+cModulo+" "+Trim(cVersao)
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

DEFAULT cStr  := ""
DEFAULT cStr1 := ""

cMsg := cNomMod+Chr(13)+Chr(10)+;
	Chr(13)+Chr(10)+;
	cStr+Chr(13)+Chr(10)+;
	cStr1+Chr(13)+Chr(10)+;
	Chr(13)+Chr(10)

VTCLEAR
VTAlert(cMsg,STR0009,.T.,2500) //"Finalizar"
VTDisConnect()
Return

Function VTOpenFile(cEmpresa)
Local aScr     := {}
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

aScr := VTSave()

//abre empresa e faz validacao da autorizacao
OpenSM0(cEmpresa)
Connect()
CheckAut(cEmpresa)

if lVT100B //lVT100B = terminal 4 linhas por 20 colunas
	VTSay(0,0,Padr(cVersao,17))
	VTSay(1,0,STR0010) //"Empresa:"
	VTSay(1,9,ALLTRIM(SM0->M0_NOME))
	VTSay(2,0,STR0011) //"Filial:"
	VTSay(2,8,ALLTRIM(SM0->M0_FILIAL))
	VTSay(3,0,STR0012) //"Abrindo tabelas..."
ElseIf __cVtModelo<>"RF"
	VTCLEAR()
	VTSay(0,0,STR0012) //"Abrindo tabelas..."
Elseif __cVtModelo == "RF"
	VTSay(0,0,Padr(cVersao,17))
	VTSay(2,0,STR0010) //"Empresa:"
	VTSay(3,0,SM0->M0_NOME)
	VTSay(4,0,STR0011) //"Filial:"
	VTSay(5,0,SM0->M0_FILIAL)
	VTSay(6,0,STR0012) //"Abrindo tabelas..."
EndIf

//abre arquivos SX's do sistema
OpenSxs(,,.F.,.F.)

//inicializa as variaveis publicas
InitPublic()

If "S"$substr(__cLogSiga,1,5)
	__GeraLog("O")
EndIf

//abre as tabelas usadas
OpenData()

VTRestore(,,,,aScr)
Return

/*/{Protheus.doc} VTGetEmpr
	Atualiza o ambiente para a nova empresa filial selecionada.
	Uso no ACD
	@type  Function
	@author materiais
	@since 30/06/2021
	@version 1.0
	@param nenhum
	@return nenhum
	@example
	(examples)
	@see (links_or_references)
	/*/
Function VTGetEmpr(cUserID)
Local aUser 
Local aEmprx
Local aEmp

If !Empty(cUserID)
	pswseek(cUserID)
EndIf 

aUser := PswRet()
aEmprx := aClone(aUser[2][6])

VTClKey()

aEmp := VTNewEmpr(@aEmprx,.T.)
cNumEmp := aEmp[1]+aEmp[2]

If Subs(cEmpAnt,1,2) <> Subs(cNumEmp,1,2) 
	cArqTab := ""
	cEmpAnt := Substr(cNumEmp,1,2)
	cFilAnt := Substr(cNumEmp,3)
	DbCloseAll()
	VTOpenFile(cNumEmp)
Else
	cEmpAnt := Substr(cNumEmp,1,2)
	cFilAnt := Substr(cNumEmp,3)
	CheckAut(cNumEmp)
Endif

DbSelectArea("SM0")
DbSeek(cNumEmp)
VTDefKey()
Return nil

Function VTNewEmpr(aEmprx,lOpen)
Local aRet := Array(2)
Local nPos
Local aChoice := Array(3)
Local aScr
Local aEmprAux := {}
Local aEmpr2	:= {}
Local nI := 0
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

DEFAULT lOpen := .F.

aScr := VTSave()

aChoice[1] := {}
aChoice[2] := {}
aChoice[3] := {}

OpenSM0()
DbSelectArea("SM0")
DbGoTop()

//Monta o Arvore de Empresas
If Empty(aEmprx)
	Final(STR0013,STR0014) //"Usuario nao"###"autorizado"
Else
	If aEmprx[1] == [@@@@]
		aEmprx := {}
		aEmprx := FWLoadSM0()
	Else
   		aEmprAux := FWLoadSM0()
		For nI := 1 To Len(aEmprx)
			nPos := Ascan(aEmprAux,{|x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(aEmprx[nI])})
			If nPos > 0
				aAdd (aEmpr2,aEmprAux[nPos])
			EndIf
		Next
		aEmprx := {}
		aEmprx := aClone(aEmpr2)
	EndIf
Endif

If Empty(aEmprx)
	Final(STR0015,STR0016) //"Arquivo Empresa"###"Corrompido"
EndIf

//caso so acesse uma empresa nao mostra opcoes
If !Empty(aEmprx)
	DbSelectArea("SM0")
	DbGoTop()
	While !Eof()
		If Ascan(aEmprx,{|x| x[1]+x[2] == M0_CODIGO+FWCODFIL()}) > 0
			Aadd(aChoice[1],M0_CODIGO+'-'+FWCODFIL()+' '+Trim(Upper(M0_NOME))+'/'+Trim(Upper(M0_FILIAL)))
			Aadd(aChoice[2],.T.)
			Aadd(aChoice[3],M0_CODIGO+FWCODFIL())
		EndIf
		DbSkip()
	End

	VTCLEAR

	@0,0 VTSAY cVersao
	@1,0 VTSAY STR0017 //"Empresa/Filial"
	If __cVtModelo=="RF" .or. lVT100B //lVT100B = terminal 4 linhas por 20 colunas
		nPos := VTaChoice(03,00,VTMaxRow(),VTMaxCol(),aChoice[1],aChoice[2])
	ElseIf __cVtModelo=="MT16"
		nPos := VTaChoice(00,00,VTMaxRow(),VTMaxCol(),aChoice[1],aChoice[2])
	ElseIf __cVtModelo=="MT44"
		nPos := VTaChoice(00,20,VTMaxRow(),VTMaxCol(),aChoice[1],aChoice[2])
	EndIf

	If ( VTLastKey() == 27 )
		If lOpen
			DbSeek(cNumEmp)
		Else
			Final(STR0018,STR0019) //"Abortado pelo"###"operador"
		EndIf
	Else
		VTInKey()
		DbSeek(aChoice[3][nPos])
	EndIf
Else
	DbSeek(aEmprx[1])
EndIf

aRet[1] := M0_CODIGO
aRet[2] := FWCODFIL()
cNumEmp := SM0->M0_CODIGO+FWCODFIL()
cEmpAnt := SM0->M0_CODIGO
cFilAnt := FWCODFIL()
VTRestore(,,,,aScr)
Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VTGetSenha ³ Autor ³ TOTVS               ³ Data ³ 14/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Solicita Usuario/ID e Senha para efetuar o login           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ dGetData  = DataBase informada pelo Usuario                ³±±
±±³          ³ tRealIni  = Horario do Login                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VT100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VTGetSenha(dGetData,tRealIni)

Local cNome    := Space(TAMUSR)
Local cSenha   := Space(TAMPSW)
Local lOK      := .F.
Local aUsuario := {}
Local nErros   := 0
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

DEFAULT dGetData := CTOD("")

__cVtModelo :=VtModelo()

@0,0 VTSAY cVersao
@1,0 VTSAY STR0020 VTGET dGetData valid ! Empty(dGetData) //"Data Base:"

if lVT100B //lVT100B = terminal 4 linhas por 20 colunas
	VTREAD
	VTClear(0,0,3,19)
	@0,0 VTSAY STR0021 //"Usuario:"
	@2,0 VTSAY STR0022 //"Senha:"
ElseIf __cVTModelo<>"RF"
	VTREAD
	VTClear()
	@0,0 VTSAY STR0021 //"Usuario:"
	@1,0 VTSAY STR0022 //"Senha:"
ElseIf __cVTModelo == "RF"
	@3,0 VTSAY STR0021 //"Usuario:"
	@5,0 VTSAY STR0022 //"Senha:"
EndIf

VTREAD

If ( VTLastKey() == 27 )
	Final(STR0018,STR0019) //"Abortado pelo"###"operador"
EndIf

dDataBase := dGetData

While ( !lOK )
	If .T.
		If lVT100B //lVT100B = terminal 4 linhas por 20 colunas
			@1,0 VTGET cNome VALID VTPosUser(cNome)
		ElseIf __cVTModelo<>"RF"
			@0,09 VTGET cNome VALID VTPosUser(cNome)
		ElseIf __cVTModelo=="RF"
			@4,0 VTGET cNome VALID VTPosUser(cNome)
		EndIf
	EndIf

	cSenha := Space(TAMPSW)
	If lVT100B //lVT100B = terminal 4 linhas por 20 colunas
		@3,0 VTGET cSenha PASSWORD
	ElseIf __cVTModelo<>"RF"
		@1,09 VTGET cSenha PASSWORD
	ElseIf __cVTModelo=="RF"
		@6,0 VTGET cSenha PASSWORD
	EndIf
	VTREAD

	If ( VTLastKey() == 27 )
		Final(STR0018,STR0019) //"Abortado pelo"###"operador"
	Else
		lOK := VTValSenha(cNome,cSenha,@aUsuario,@nErros,dGetData,tRealIni)
	EndIf
End

VTConnect()
Return aUsuario

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VTValSenha ³ Autor ³ TOTVS               ³ Data ³ 14/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o login e acessos do Usuario                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cNome     = Nome ou ID do Usuario                          ³±±
±±³          ³ cSenha    = Senha do Usuario                               ³±±
±±³          ³ aUser     = Array com os dados do Usuario                  ³±±
±±³          ³ nErros    = Numerico Erros                                 ³±±
±±³          ³ dGetData  = DataBase informada pelo Usuario                ³±±
±±³          ³ tRealIni  = Horario do Login                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VT100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VTValSenha(cNome,cSenha,aUser,nErros,dGetData,tRealIni)

Local oUser
Local aEmpresas  := {}
Local dDate      := CToD("  /  /  ")
Local cRegraGrup := ""	// Regra de acesso por grupo (USR_GRPRULE: 1-Priorizar; 2-Desconsiderar; 3-Somar)
Local cID		 := ""
Local cMsgUser   := ""
Local nRetorno   := 0
Local nX         := 0
Local lRet       := .T.
Local lContinua  := .T.
Local lGetPass

Private cAcesso

cNome := IIf( Upper( AllTrim( cNome ) )  == "ADMIN", "ADMINISTRADOR" , cNome )
// ---------------------------------------
// Inicializa a classe de autenticação de usuário
// ---------------------------------------
oUser := GetUserAcc()
// ---------------------------------------
// Verifica se a autenticação pelo SO é válida
// ---------------------------------------
nRetorno := oUser:SignOnAuthentication(.T.)
If nRetorno == 0
	nRetorno :=  oUser:Authentication(cNome,cSenha)
	lRet := nRetorno <> 0
EndIf
If !lRet
	// Captura a mensagem de erro de autenticacao gerada pelo Framework
	cMsgUser := cValToChar(oUser:GetMessage()[2])

	VTAlert(cMsgUser,STR0024,.T.,2500) //"Mensagem retornada pelo Framework"###"Atencao"
Else
	cID := oUser:CUSERID
	__Ap5NoMv(.T.)

	PswOrder( 1 )
	If !PswSeek(cID)
		Final( STR0024, STR0065 )
	Else
		aUser := PswRet()
		cNome := oUser:CUSERLOGIN
	EndIf
	__Ap5NoMv(.F.)

	__cUserID := aUser[1][1] // Seta id do usuario
	__NUSERACS := aUser[1][15] // Valida numero de acessos do usuario.


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

	If !nUserAcs()
		Final(STR0024,STR0055) //"Atenção"###"Limite de conexao do usuario excedido"
	EndIf

	//verifica se usuario esta bloqueado
	If ( aUser[1][17] )
		Final(STR0025) //"Usuario bloqueado"
	EndIf

	// Carrega empresas que o usuario tem acesso
	aEmpresas := FWUsrEmp(aUser[1][1])
	For nX := 1 To Len(aEmpresas)
		If aScan(aUser[2][6], aEmpresas[nX]) == 0
			aAdd(aUser[2][6], aEmpresas[nX])
		EndIf
	Next nX

	cRegraGrup := FWUsrGrpRule(aUser[1][1])
	// Ajusta as regras de acesso do usuario de acordo com os grupos a ele relacionados respeitando o campo Regra de Acesso por Grupo (USR_GRPRULE):
	// 1 - Prioriza regra por grupo     - Esta opcao desconsidera as regras do usuario e considera as regras dos grupos
	// 2 - Desconsidera regra por grupo - Esta opcao desconsidera as regras dos grupos e considera as regras do usuario
	// 3 - Soma regra por grupo         - Esta opcao soma as regras do usuario com as regras dos grupos
	If cRegraGrup == "1" .Or. cRegraGrup == "3"
		aUser := VTValGroup(aUser, cRegraGrup)
	EndIf

	// Verifica data de validade
	dDate := aUser[1][6]
	If dDate < dGetData .And. !Empty(dDate)
		Final(STR0013,STR0014) //"Usuario nao"###"autorizado"
	Endif

	// Verifica se permite alterar DataBase
	// aUser[1][23][1] - Permite alterar database do sistema
	// aUser[1][23][2] - Dias a retroceder
	// aUser[1][23][3] - Dias a avancar
	If dDataBase <> MsDate()
		If aUser[1][1] != "000000"
			If aUser[1][23][1]	// Permite alterar database do sistema
				If (dDatabase < (MsDate() - aUser[1][23][2])) .Or. (dDatabase > (MsDate() + aUser[1][23][3]))
					lContinua := .F.
				EndIf
			Else
				lContinua := .F.
			EndIf
		EndIf
	EndIf

	// Finaliza caso Usuario e o Grupo nao tenha permissao para alterar DataBase
	If !lContinua .And. dDatabase <> MsDate()
		Final(STR0028,STR0029) //"Sem permissao para"###"alterar data base"
	EndIf

	//avisa se a data de validade esta p/ expirar
	If dDate <= dGetData + 2 .And. !Empty(dDate)
		Help("",1,"VLDUSER",,Strzero(dDate - dGetData,2),2,4)
	Endif

	cUsuario  := Padr(cSenha,6)+Padr(aUser[1][2],15)+aUser[2][5]
	cUsuaFull := Padr(cSenha,TAMPSW)+Padr(aUser[1][2],TAMUSR)+aUser[2][5]
	cUserName := Padr(aUser[1][2],25)

	//verifica se a senha expirou
	If aUser[1][7] > 0 .and. !Empty(aUser[1][16])
		If (aUser[1][16]+aUser[1][7]) < dGetData
			VTGetNewPass(cSenha,.F.,.T.,.T.,@aUser[1][3])
			lGetPass := .T.
		Endif
	Endif

	//alterar senha no proximo logon
	If aUser[1][9] .And. !lGetPass
		VTGetNewPass(cSenha,.F.,.F.,.T.,@aUser[1][3])
	EndIf

	//verifica se usa data com 2 ou 4 digitos
	If ( aUser[1][18] == 2 )
		SET CENTURY OFF
	Else
		SET CENTURY ON
	EndIf
Endif
Return lRet

/*/{Protheus.doc} VTValGroup - Retorna as regras de acesso dos grupos relacionados ao usuario
@author  Totvs
@since   20/03/2020
@version 1.0
@param   aRegraUser - Array contendo as regras de acesso do usuario
         cRegraGrup - Regra de acesso por grupo (USR_GRPRULE: 1-Priorizar; 2-Desconsiderar; 3-Somar)
@return  aRegraGrup - Array contendo as regras de acesso considerando os grupos relacionados ao usuario
/*/
Function VTValGroup(aRegraUser, cRegraGrup)
	Local aNovaRegra := {}
	Local aGrupos    := {}
	Local aRegraGrup := {}
	Local cRegraAces := {}
	Local aFil		 := {}
	Local nTamRegra  := 0
	Local nWeek      := 0
	Local nX         := 0
	Local nY         := 0
	Local nCount	 := 0
	Local nCount2	 := 0

	aNovaRegra := aClone(aRegraUser)
	aGrupos := FWSFUsrGrps(__cUserID)	// Retorna os grupos relacionados ao usuario, o primeiro grupo e o prioritario (USR_PRIORIZA = Sim)

	For nX := 1 To Len(aGrupos)
		// Informacoes de restricao de horario do grupo
		// Serao considerados somente os horarios do primeiro grupo, pois nao e possivel somar horarios de grupos diferentes
		If nX == 1
			nWeek := Dow(dDataBase)
			aRegraGrup := {}
			aRegraGrup := FWGrpHor(aGrupos[nX])
			aNovaRegra[2][1][nWeek] := aRegraGrup[6][2]+"|"+aRegraGrup[6][3]
		EndIf

		// Data de bloqueio (validade)
		// aNovaRegra[1][6] se refere ao campo Data de bloqueio(validade) do usuario (USR_MSBLQD)
		// aRegraGrup[1][4] se refere ao campo Data de bloqueio(validade) do grupo   (GR__MSBLQD)
		// Sera considerada somente a data do primeiro grupo, pois nao e possivel somar datas de grupos diferentes
		aRegraGrup := {}
		aRegraGrup := FWGrpParam(aGrupos[nX])
		If nX == 1
			aNovaRegra[1][6] := aRegraGrup[1][4]
		EndIf

		// Permite alterar database
		// Se Regra de acesso por grupo = Priorizar serao consideradas somente as informações do primeiro grupo (o que estiver com Priorizado = Sim ou o primeiro grupo caso todos estiverem com Priorizado = Nao)
		// Se Regra de acesso por grupo = Somar serao consideradas as informações do grupo que estiver configurado para avançar/retroceder a database
		If cRegraGrup == "1"
			If nX == 1
				aNovaRegra[1][23][1] := aRegraGrup[2][1] == "1"	// Permite alterar database do sistema
				aNovaRegra[1][23][2] := Val(aRegraGrup[2][2])	// Dias a retroceder
				aNovaRegra[1][23][3] := Val(aRegraGrup[2][3])	// Dias a avancar
			EndIf
		Else // cRegraGrup == "3"
			If aRegraGrup[2][1] == "1" .And. (Val(aRegraGrup[2][2]) > 0 .Or. Val(aRegraGrup[2][3]) > 0)
				aNovaRegra[1][23][1] := aRegraGrup[2][1] == "1"	// Permite alterar database do sistema
				aNovaRegra[1][23][2] := Val(aRegraGrup[2][2])	// Dias a retroceder
				aNovaRegra[1][23][3] := Val(aRegraGrup[2][3])	// Dias a avancar
			EndIf
		EndIf

		// Troca periodica da senha a cada n dias
		// aNovaRegra[1][7] se refere ao campo Troca periodica da senha a cada n dias do usuario (USR_QTDEXPPSW)
		// aRegraGrup[1][5] se refere ao campo Troca periodica da senha a cada n dias do grupo
		// Sera considerada somente o numero do primeiro grupo, pois nao e possivel somar esta informacao de grupos diferentes
		If nX == 1
			aNovaRegra[1][7] := IIF(ValType(aRegraGrup[1][5])=="N", aRegraGrup[1][5], Val(aRegraGrup[1][5]))
		EndIf

		For nCount := 1 To Len(aRegraUser[2][6])
        	Aadd(aFil, aRegraUser[2][6][nCount])
    	Next

		// Acesso as empresas
		// Se Regra de acesso por grupo = Priorizar, ira considerar somente as filiais do primeiro grupo (o que estiver com Priorizado = Sim ou o primeiro grupo caso todos estiverem com Priorizado = Nao)
		// Se Regra de acesso por grupo = Somar, ira considerar as filiais de ambos os grupos
		aRegraGrup := {}
		aRegraGrup := FWGrpEmp(aGrupos[nX])
		If nX == 1
			aNovaRegra[2][6] := {}
		EndIf
		If cRegraGrup == "1"
			For nY := 1 To Len(aRegraGrup)
				aAdd(aNovaRegra[2][6], aRegraGrup[nY])
			Next nY
		Else // cRegraGrup == "3"
			For nY := 1 To Len(aRegraGrup)
				If aScan(aNovaRegra[2][6], aRegraGrup[nY]) == 0
					aAdd(aNovaRegra[2][6], aRegraGrup[nY])
				EndIf
			Next nY
			If Len(aFil) > 0
				For nCount2 := 1 To Len(aFil)
					If aScan(aNovaRegra[2][6], aFil[nCount2]) == 0
						Aadd(aNovaRegra[2][6], aFil[nCount2])
					EndIf
				Next
			EndIf			
		EndIf

		// Acesso aos modulos
		// Se Regra de acesso por grupo = Priorizar, ira considerar somente os modulos do primeiro grupo (o que estiver com Priorizado = Sim ou o primeiro grupo caso todos estiverem com Priorizado = Nao)
		// Se Regra de acesso por grupo = Somar, ira considerar os modulos de ambos os grupos
		aRegraGrup := FwGrpMenu(aGrupos[nX])
		If nX == 1
			aNovaRegra[3] := aRegraGrup
		EndIf
		If cRegraGrup == "3" .And. nX > 1
			For nY := 1 To Len(aRegraGrup)
				If SubStr(aNovaRegra[3][nY], 3, 1) == "X" .And. SubStr(aRegraGrup[nY], 3, 1) <> "X"
					aNovaRegra[3][nY] := aRegraGrup[nY]
				EndIf
			Next nY
		EndIf

		// Permissoes de acesso de cada menu (excluir produto, alterar produto, etc)
		// Se Regra de acesso por grupo = Priorizar, ira considerar somente os acessos do primeiro grupo (o que estiver com Priorizado = Sim ou o primeiro grupo caso todos estiverem com Priorizado = Nao)
		// Se Regra de acesso por grupo = Somar, ira considerar os acessos de ambos os grupos
		cRegraAces := ""
		cRegraAces := FWGrpAcess(aGrupos[nX])
		If nX == 1
			aNovaRegra[2][5] := cRegraAces
		EndIf
		If cRegraGrup == "3" .And. nX > 1
			nTamRegra := Len(cRegraAces)
			For nY := 1 To nTamRegra
				If Substr(aNovaRegra[2][5], nY, 1) == "N" .And. SubStr(cRegraAces, nY, 1) == "S"
					aNovaRegra[2][5] := Substr(aNovaRegra[2][5], 1, nY-1) + "S" + Substr(aNovaRegra[2][5], nY+1, nTamRegra-nY)
				EndIf
			Next nY
		EndIf

		// Informacoes de impressao do cadastro de grupo
		// Serao consideradas somente as informacoes do primeiro grupo, pois nao e possivel somar estas informacoes de grupos diferentes
		If nX == 1
			aRegraGrup := {}
			aRegraGrup := FWGrpImp(aGrupos[nX])
			// Diretorio
			aNovaRegra[2][3] := aRegraGrup[1]
			// Impressora
			aNovaRegra[2][4] := aRegraGrup[7]
		EndIf
	Next nX

Return aNovaRegra

Function VTChangePass()
Return VTGetNewPass(Substr(cUsuaFull,1,TAMPSW),.T.)

Function VTGetNewPass(cOldSenha,lGetOld,lExp,lLog,cRet)
Local cConfirm := Space(TAMPSW)
Local aScr
Local nRec := 0

aScr := VTSave()
VTCLEAR

lGetOld := .T.
lExp := If(lExp == NIL,.F.,lExp)
lLog := If(lLog == NIL,.F.,lLog)

If __CUSERID == "000000"
	Help("",1,"PSWADM")
	Return .F.
EndIf

// A validacao de autorizacao para alteracao de senha foi removida, pois a versao 11 nao possui mais essa funcionalidade

If VTAltSenha(lGetOld,nRec,@cConfirm,@cOldSenha)
	cUsuario := PADR(cConfirm,6) + Substr(cUsuario,7)
	cUsuaFull:= PADR(cConfirm,TAMPSW) + Substr(cUsuaFull,TAMPSW+1)
	cRet     := Padr(cConfirm,TAMPSW)
Endif

VTRestore(,,,,aScr)

Return .T.

Function VTAltSenha(lGetOld,nRecno,cConfirm,cOldSenha)
Local lOK       := .F.
Local cNewSenha := Space(TAMPSW)
Local oUser    	:= MPUserAccount():New()
Local oUserAuth	:= Nil

@0,0 VTSAY STR0030 //"Alteracao de Senha"
While !lOK
	If VtModelo()=="RF"
		@2,0 VTSAY STR0031 //"Senha Atual:"
		@3,0 VTGET cOldSenha PASSWORD VALID VTVldSenha(cOldSenha,.F.,nRecno)
		@4,0 VTSAY STR0032 //"Nova Senha:"
		@5,0 VTGET cNewSenha PASSWORD VALID VTVldSenha(cNewSenha,.T.,nRecno)
		@6,0 VTSAY STR0033 //"Confirme a senha:"
		@7,0 VTGET cConfirm PASSWORD
		VTREAD
	Else
		Sleep(2000)
		VtClear()
		@0,0 VTSAY STR0031 //"Senha Atual:"
		@1,0 VTGET cOldSenha PASSWORD VALID VTVldSenha(cOldSenha,.F.,nRecno)
		VTREAD
		VTClear
		@0,0 VTSAY STR0032 //"Nova Senha:"
		@1,0 VTGET cNewSenha PASSWORD VALID VTVldSenha(cNewSenha,.T.,nRecno)
		VTREAD
		VTClear
		@0,0 VTSAY STR0033 //"Confirme a senha:"
		@1,0 VTGET cConfirm PASSWORD
		VTREAD
	EndIf
	If ( VTLastKey() == 27 )
		Exit
	Else
		If cNewSenha == cConfirm
			//--Atencao: a funcao abaixo nao deve ser utilizada em outros fontes, pois e de uso restrito da equipe de Framework
			//--Sua utilizacao foi liberada no ACD por questão de legado.
			If ( FWUserAuthentic(@oUserAuth,__CUSERID,cOldSenha)[1] > 0 )
				lOk := oUserAuth:ChangePassword(__CUSERID,cOldSenha,cNewSenha)
				If !lOk
					VTAlert(oUser:GetMessage()[2],STR0024,.T.,3000) //"Nao Confere"###"Atencao"
				EndIf
            EndIf
		Else
			VTAlert(STR0034,STR0024,.T.,3000) //"Nao Confere"###"Atencao"
		EndIf
	EndIf
End

If !lOK
	Final(STR0013,STR0014) //"Usuario nao"###"autorizado"
Endif
Return lOK

Static Function VTVldSenha(cPassword,lNew,nRecno)
Local lRet := .T.

If lNew
	PswOrder(3)
	PswSeek(cPassword)
	If ( Empty(cPassWord) )
		lRet := .F.
	ElseIf ( PswRecno() > 0)
		Help(" ",1,"PSWEXIST")
		lRet := .F.
	Endif
Else
	If cPassWord == Substr(cUsuaFull,1,TAMPSW)
		lRet := .T.
	Else
		VTAlert(STR0023,STR0024,.T.,3000) //"Senha Invalida"###"Atencao"
		lRet := .F.
	Endif
Endif

If !lRet
	VtKeyBoard(chr(20))
EndIf
Return lRet

Function VTSayOpen()
Static __cL := "." ,__nC

DEFAULT __nC := 0

VTSay(VTMaxRow(),__nC,__cL)
__nC++
If __nC > VTMaxCol()
	__nC := 0
	__cL := If(__cL=="."," ",".")
EndIf

Return

Function VTChangeDate()

Local dNewData := dDataBase
Local aScr

If !Versenha(36)
	Help("",1,"SEMPERM")
	Return NIL
Endif
VtClearBuffer()
VTClKey()
aScr := VTSave()
VTCLEAR
@0,0 VTSAY cVersao
@1,0 VTSAY STR0020 VTGET dNewData VALID VTValDate(dNewData)   //"Data Base:"
VTREAD
If ( VTLastKey() <> 27 )
	dDataBase:=dNewData
	//verifica se lotes estao com validade vencida
	If dNewData > dDataBase .And. Select("SB8") > 0 .And. GETMV("MV_LOTVENC") == "N" .And. GETMV("MV_RASTRO") == "S"
		//Processa({|lEnd| BloqData()},OemToAnsi(STR0181),OemToAnsi(STR0182),.F.) //"Verificando Data de Validade dos Lotes"###"Verificando Lotes com data de validade vencida ..."
	EndIf
	If __VLDUSER < dDatabase .And. !Empty(__VLDUSER)
		Final(STR0038) //"Validade do Usuario Vencida"
	Endif
Endif

VTDefKey()
VTRestore(,,,,aScr)
Return NIL

Static Function VTValDate(dData)
If Empty(dData)
	HELP(" ","1","VAZIO")
	Return .F.
EndIf
Return .T.

Function VTGetInfo()
Local aInfo  := {}
Local aSavKey:= VTkeys()
Local aTela  := VTSave()

VTClKey()
VtClearBuffer()
aInfo := {}
aadd(aInfo,{STR0045,"SIGA"+cModulo})		//"Modulo"
aadd(aInfo,{STR0040,Dtoc(dDataBase)})		//"Data Base: "
aadd(aInfo,{STR0021,Subs(cUsuaFull,TAMPSW+1,TAMUSR)}) //"Usuario:"
If ! Empty(CBRetOpe())
	aadd(aInfo,{STR0019,CBRetOpe()})	//"Operador"
EndIf
aadd(aInfo,{STR0010,SM0->M0_NOME})		//"Empresa:"
aadd(aInfo,{STR0011,SM0->M0_FILIAL}	)	//"Filial:"

VTaBrowse(0,0,VTMaxRow(),VtMaxCol(),{STR0041,STR0046},aInfo,{10,VtMaxCol()},,," ") //"Sobre..." //"Conteudo"
VtKeys(aSavKey)
VTRestore(,,,,aTela)
Return

Function VTInfoNome()
Local cTexto := Funname()
If Empty(cTexto)
	cTexto := STR0047 //"Menu"
EndIf
VTAlert(cTexto,STR0048)  //"Programa - <Enter>"
Return

Function VTAjuda()
Local ni
Local aKey:= VTRetKey()
Local aTela:= VtSave()

Local aControle:={}
Local cSkAnt := VTDescKey(1)
Local bSKAnt := VTSetKey(1)
Local lIsGet  := VTIsGet()

Private  aConteudo:={}

If VTModelo()<>"RF" .and. lIsGet
	aadd(aConteudo,STR0059) // "Seta para cima"
	aadd(aControle,{{|| VtWriteVt100(chr(27)+chr(91)+chr(65))},5} )

	aadd(aConteudo,STR0060) //"Seta para baixo"
	aadd(aControle,{{|| VtWriteVt100(chr(27)+chr(91)+chr(66))},24})
EndIf

For ni:= 1 to len(aKey)
	If aKey[ni,1] < 27  //.and. ! Empty(aKey[ni,3])
		aadd(aConteudo,"Ctrl+"+chr(64+aKey[ni,1])+" "+aKey[ni,3])
		aadd(aControle,{aKey[ni,2],aKey[ni,1]})
	EndIf
Next
VTClear()
If VTModelo()=="RF"
	@ 0,0 VtSay STR0049 //"Selecione:"
	nPos := VtAchoice(1,0,VtMaxRow(),VtMaxCol(),aConteudo,     ,'vtctrlajuda')
Else
	nPos := VtAchoice(0,0,VtMaxRow(),VtMaxCol(),aConteudo,     ,'vtctrlajuda')
EndIf
If nPos > 0 .and. aControle[nPos,2] <> 1
	Eval(aControle[nPos,1])
EndIf
VTSetKey(1,bSKAnt,cSkAnt)
VtRestore(,,,,aTela)
Return

Function VtCtrlAjuda(modo,nElem,nElemW)
Local nTecla
Local nPos
If modo == 1
Elseif Modo == 2
Else
	nTecla := VTLastkey()
	If nTecla == 27
		Return 0
	ElseIf nTecla == 13
		return 1
	Else
		nPos:= ascan(aConteudo,{|x| Left(x,6)=="Ctrl+"+Upper(chr(nTecla))})
		If nPos > 0
			If nPos == nElem
				Return 1
			ElseIf nPos > nElem
				VtKeyBoard(repl(chr(24),nPos-nElem)+chr(13))
			Else
				VtKeyBoard(repl(chr(5),nElem-nPos)+chr(13))
			EndIf
			Return 2
		EndIf
	Endif
EndIf
Return 2

Function VTDefKey()

VTClearKeys()
VTSetKey(01,{|| VTAjuda()},		STR0050)	//"Ajuda"
VTSetKey(03,{|| ACDV110()},	    STR0002)	//"Consulta"
If __lMenu
	VTSetKey(04,{|| VTChangeDate()},	STR0051)	//"Data"
	VTSetKey(06,{|| VTGetEmpr(__cUserID)},		STR0052)	//"Empresa" Tecla Ctrl-F
EndIf
VTSetKey(09,{|| VTGetInfo()},	STR0053)	//"Informacoes"
VtSetKey(26,{|| VTInfoNome()},	STR0054)	//"Nome Prog"
VtSetKey(11,{|| VTCallStack()},	STR0056)	//"Pilha de chamadas"

If ExistBlock("VTDFKEY")
	ExecBlock("VTDFKEY",.F.,.F.)
EndIf
Return

Function VtClKey()
VTClearKeys()
Return

Function VtCallStack()
Local nX      := 2
Local aCab    := {STR0061,STR0062} // 'Funcao' ### 'Linha'
Local aSize   := {20,10}
Local aItens  := {}
Local aSave   := VtSave()
Local cFuncao := ""

While ! (ProcName(nX)=="")
	cFuncao := Alltrim(Upper(ProcName(nX)))
	cFuncao := StrTran(cFuncao,"{","")
	cFuncao := StrTran(cFuncao,"}","")
	cFuncao := StrTran(cFuncao,"|","")
	cFuncao := StrTran(cFuncao," ","")
	If cFuncao == "EVAL" .OR. cFuncao =="VTGETBYTE" .OR. Left(cFuncao,7)=="VTMYVAR" .OR. cFuncao =="VTREAD" .OR. cFuncao =="VTALERT".OR. cFuncao =="VTINKEY"
		nX++
		Loop
	EndIf
	aadd(aItens,{cFuncao,Alltrim(str(ProcLine(nx)))})
	nX++
End

VTaBrowse(,,,VtMaxCol(),aCab,aItens,aSize)
VtRestore(,,,,aSave)

Return

Function VTSetAp5Menu(lVar)
Local lRet
DEFAULT __lVTAp5Mnu := .F.
lRet := __lVTAp5Mnu
If lVar != Nil
	__lVTAp5Mnu := lVar
EndIf
Return lRet

Function VtSair()
VTCLEAR
Return CBYesNo(STR0042,AllTrim(cVersao),.T.) //"Tem certeza que deseja sair do programa?"

Function VtPergunte(cPergunta,lAsk)
Local cSavAlias := Alias()
Local aCesso:={}
Local sConteudo:=''
Local aTela:=VTSave()
Local i,xVar
Local lRet:= .t.
Private aPergunta:={}
Private aPerg:={}

lAsk := IF(lAsk=NIL,.t.,lAsk)

If FWLibVersion() >= "20211227"  
	If ! Pergunte(cPergunta,lAsk)
		Return
	EndIf
Else
	DbSelectArea("SX1")
	DbSeek(cPergunta)
	If ( ! Found() ) .And. ( lAsk )
		Help(" ",1,"noanswer")
		DbSelectArea(cSavAlias)
		Return .f.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Array com perguntas                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !Eof() .and. x1_grupo = cPergunta
		aadd(aPerg,X1_PERGUNT)
		aadd(aCesso,".f.")
		If X1_GSC =='G'
			sConteudo := PADR(Alltrim(X1_CNT01),X1_TAMANHO,' ')
		Else
			sConteudo := Alltrim(&('X1_DEF'+strzero(If(X1_PRESEL==0,1,X1_PRESEL),2)))
		EndIf
		aadd(aPerg,sConteudo)
		aadd(aCesso,".t.")
		AADD(aPergunta,{X1Pergunt(),X1_TIPO,X1_TAMANHO,X1_DECIMAL,If(X1_PRESEL==0,1,X1_PRESEL),;
			X1_GSC,X1_VALID,X1_CNT01,AllTrim(X1Def01()),;
			AllTrim(X1DEF02()),AllTrim(X1DEF03()),AllTrim(X1DEF04()),;
			AllTrim(X1DEF05()),X1_VAR01,If(X1_PRESEL==0,1,X1_PRESEL),X1_F3})
		DbSkip()
	End

	For i:= 1 to Len(aPergunta)
		xVar := "MV_PAR"+StrZero(i,2)
		If aPergunta[i,6]=="C"
			&xVar := aPergunta[i,5]
		Else
			IF aPergunta[i,2] =='C'
				&xVar := Left(aPergunta[i,8],aPergunta[i,3])
			ElseIf aPergunta[i,2] =='N'
				&xVar := Val(aPergunta[i,8])
			ElseIf aPergunta[i,2] =='D'
				&xVar := ctod(aPergunta[i,8])
			EndIF
		EndIf
	Next
	If lAsk
		nOpc := 1
		VTSAY(0,0,'')
		VtClearBuffer()
		While .t.
			VtKeyboard(chr(13))
			nOPC :=VTaChoice(0,0,VTMaxRow(),VTMaxCol(),aPerg,aCesso,'vtctrlperg',nOpc,,,VTRow()+1)
			If nOpc == 0 .or. VTlastkey() == 27
				Exit
			EndIf

			nOpc+=2
			IF nOpc > len(aPerg)
				nOpc := 1
				VTSAY(0,0,'')
			EndIf
		End
		lRet := VtYESNO(STR0063,STR0064,.t.) //'Confirma a pergunte?' ### 'Aviso'
	EndIf
	VTRestore(,,,,aTela)
	If lRet
		VTSaveParam(cPergunta,aPergunta)
	EndIf
EndIf

Return lRet



Function VtCtrlPerg(modo,nElem,nElemW)
Local sConteudo
Local cValid := ''
Local cPict := '@!'
Local aop:={}
Local nOpc
Local nX
Private uVar
If modo == 1
Elseif Modo == 2
Else
	If VTLastkey() == 27
		Return 0
	elseIf VTLastkey() == 13
		IF aPergunta[nElem/2,6]=='G' //get
			IF aPergunta[nElem/2,2]=='C'
				cPict := Replicate('!',aPergunta[nElem/2,3])
			ElseIf aPergunta[nElem/2,2]=='N'
				cPict := Replicate('9',aPergunta[nElem/2,3]-aPergunta[nElem/2,4])
				IF ! Empty(aPergunta[nElem/2,4])
					cPict +='.'+Replicate('9',aPergunta[nElem/2,4])
				EndIf
			ElseIF aPergunta[nElem/2,2]=='D'
				cPict :='@D'
			EndIF
			VTClearBuffer()
			cValid := aPergunta[nElem/2,7]
			uVar := &('MV_PAR'+StrZero((nElem/2),2))
			@ nElemW,0 VtSay spac(VtMaxCol())
			While .t.
				If ! Empty(aPergunta[nElem/2,16] )
					@ nElemW,0 VTGET uVar PICT cPict F3 aPergunta[nElem/2,16]
				Else
					@ nElemW,0 VTGET uVar PICT cPict
				EndIF
				VTRead
				If ! Empty(cValid) .and. VtLastkey()<>27
					&('MV_PAR'+StrZero((nElem/2),2)):= uVar
					If  &cValid
						exit
					Else
						loop
					endIf
				EndIf
				exit
			End
			If VTLastkey() # 27
				&('MV_PAR'+StrZero((nElem/2),2)) := uVar
				sConteudo := &('MV_PAR'+StrZero((nElem/2),2))
				IF aPergunta[nElem/2,2]=='C'
					sConteudo :=PADR(Alltrim(sConteudo),aPergunta[nElem/2,3],' ')
				ElseIf aPergunta[nElem/2,2]=='N'
					sConteudo := Str(sConteudo,aPergunta[nElem/2,3])
					sConteudo := PADR(Alltrim(sConteudo),aPergunta[nElem/2,3],' ')
				ElseIF aPergunta[nElem/2,2]=='D'
					sConteudo := DToc(sConteudo)
				EndIf
				aPerg[nElem] := sConteudo
				vtclearbuffer()
			EndIF
			return 1
		Else  //achoice
			For nX:= 1 to 5
				IF ! Empty(aPergunta[nElem/2,8+nX])
					aadd(aop,aPergunta[nElem/2,8+nX])
				EndIf
			Next
			VTClearBuffer()
			nOpc := &('MV_PAR'+StrZero((nElem/2),2))
			nOpc := VTachoice(nElemW,0,nElemW,VtMaxCol(),aop,,,nOpc,.t.)

			IF VtLastKey() == 13
				&('MV_PAR'+StrZero((nElem/2),2)) := nOpc
				aPerg[nElem] := aop[nOpc]
				vtclearbuffer()
				return 1
			EndIF
		EndIF
	Endif
EndIf
Return 2

Static Function VTSaveParam(cPergunta,aPergunta)
Local nEl := 1

DbSelectArea("SX1")
DbSeek(cPergunta)
While !eof() .and. X1_GRUPO = cPergunta
	RecLock("SX1")
	If aPergunta[nEl,6] == "C"
		aPergunta[nEl,5] := &("MV_PAR"+StrZero(nEl,2,0))
		Replace X1_PRESEL with aPergunta[nEl,5]
	Else
		aPergunta[nEl,8] := &("MV_PAR"+StrZero(nEl,2,0))
		If Upper(aPergunta[nEl,2]) == "D"
			Replace X1_CNT01 With "'"+DTOC(aPergunta[nEl,8],"DDMMYY")+"'"
		ElseIf Upper(aPergunta[nEl,2]) == "N"
			Replace X1_CNT01 With Str(aPergunta[nEl,8],aPergunta[nEl,3],aPergunta[nEl,4])
		Else
			Replace X1_CNT01 With aPergunta[nEl,8]
		EndIf
	EndIf
	nEl++
	MSUnlock()
	SX1->(DbSkip())
End
Return nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VTExistCPO  ³ Autor ³ Fernando Alves      ³ Data ³ 12/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica o conteudo no arquivo especificado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Valor Logico de Retorno (.T. ou .F.)               ³±±
±±³          ³ ExpC1 = Alias do arquivo a verificar                       ³±±
±±³          ³ ExpC2 = Chave de pesquisa                                  ³±±
±±³          ³ ExpN3 = Numero da ordem de pesquisa                        ³±±
±±³          ³ ExpC4 = Mensagem a ser acionada                            ³±±
±±³          ³ ExpL5 = Verifica se quer que retorne o registro posicionado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VT100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VTExistCPO(cAlias,cChave,nOrd,cMsg,lRetPos)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaAlias := (cAlias)->(GetArea())
lRetPos := If (lRetPos == NIL,.F.,lRetPos)
dbSelectArea(cAlias)
If nOrd == nil
	dbSetOrder(1)
Else
	dbSetOrder(nOrd)
EndIf
If !dbSeek(xFilial()+cChave)
	VTBeep()
	If cMsg != nil
		VTALERT(cMSG,STR0024,.T.,3000)		//"Atencao"
	EndIf
	VTBeep()
	lRet := .F.
EndIf
If !lRetPos
	RestArea(aAreaAlias)
	RestArea(aArea)
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³VTExistCha  ³ Autor ³ Fernando Alves      ³ Data ³ 12/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se informacao passada NAO exite no arquivo        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Valor Logico de Retorno (.T. ou .F.)               ³±±
±±³          ³ ExpC1 = Alias do arquivo a verificar                       ³±±
±±³          ³ ExpC2 = Chave de pesquisa                                  ³±±
±±³          ³ ExpN3 = Numero da ordem de pesquisa                        ³±±
±±³          ³ ExpC4 = Mensagem a ser acionada                            ³±±
±±³          ³ ExpL5 = Verifica se quer que retorne o registro posicionado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VT100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VTExistCha(cAlias,cChave,nOrd,cMsg,lRetPos)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaAlias := (cAlias)->(GetArea())
lRetPos := If (lRetPos == NIL,.F.,lRetPos)
dbSelectArea(cAlias)
If nOrd == nil
	dbSetOrder(1)
Else
	dbSetOrder(nOrd)
EndIf
If dbSeek(xFilial()+cChave)
	VTBeep()
	If cMsg != nil
		VTALERT(cMSG,STR0024,.T.,3000)	//"Atencao"
	EndIf
	VTBeep()
	lRet := .F.
EndIf
If !lRetPos
	RestArea(aAreaAlias)
	RestArea(aArea)
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VTMSG      ³ Autor ³ Fernando Alves      ³ Data ³ 20/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria Linha de mendagem                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ Exp1C = Mensagem                                           ³±±
±±³          ³ Exp2N = Tipo da mensagem                                   ³±±
±±³          ³         1=Centro                                           ³±±
±±³          ³         2=Rodape                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VT100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VTMSG(cMSG,nTipMen)
Local nLinha := VTMAXROW()/2
Local nColuna:= (VTMAXCOL()/2)-(len(cMSG)/2)
nTipMen := If (nTipMen == nil,1,nTipMen)
If nTipMen == 1
	VTCLEAR()
	@ nLinha,nColuna VTSAY cMSG
Else
	VTSay(VTMAXROW(),0,padr(cMSG,VTMAXCOL()))
EndIf
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VTDispFile ³ Autor ³ Sandro              ³ Data ³ 20/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra arq. texto no display do RF                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cArquivo = nome do arquivo                                 ³±±
±±³          ³ lPosFim  = Posicio no fim do arquivo                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VT100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VTDispFile(cArquivo,lPosIni)
Local cString := MemoRead(cArquivo)
Local cLine   := ""
Local nLen    := 0
Local aCab    := {cArquivo,cArquivo,cArquivo,cArquivo}
Local aSize   := {20,20,20,20}
Local aItens  := {}
Local aScr    := VTSave()
Local lRev    := VtIsReverso()
Local nIniPos := 1
Local bkey24  := VTSetKey(24)
Local i       := 0

nLen := MlCount(cString,80)
For i := 1 To nLen
	cLine := MemoLine(cString,80,i)
	aadd(aItens,{Subst(cLine,1,20),Subst(cLine,20,20),Subst(cLine,39,20),Subst(cLine,58,20)})
Next
VTClearBuffer()
If lPosIni #NIL .and. ! lPosIni
	nIniPos := len(aItens)-VTMaxRow()
	nIniPos := If(nIniPos < 0,1,nIniPos)
	VTKeyBoard(Repl(chr(24),VTMaxRow()))
EndIf
VTaBrowse(0,0,VTMaxRow(),VTMaxCol(),aCab,aItens,aSize,,nIniPos)
VTRestore(,,,,aScr)
FErase(cArquivo)
VTReverso(lRev)
VTSetKey(24,bkey24)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VTValUser  ³ Autor ³ Robson Sales        ³ Data ³ 14/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o Nome ou ID do Usuario                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cNome = Nome ou ID do Usuario                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VT100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VTValUser(cNome)

Local lRet			:= .F.
Local lContinua	:= .F.

// Valida o Login por Nome
PswOrder(2)
If (lRet := PswSeek(Alltrim(cNome)))
	lContinua := .T.
EndIf

// Valida o Login por ID
If !lContinua
	PswOrder(1)
	If (lRet := PswSeek(Alltrim(cNome)))
		lContinua := .T.
	EndIf
EndIf

If !lContinua
	ApMSGSTOP(OemToAnsi(STR0058)) // "Usuário Inválido"
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VTPosUser  ³ Autor ³ TOTVS			    ³ Data ³ 29/05/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posiciona no usuário                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cNome = Nome ou ID do Usuario                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VT100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VTPosUser(cNome)

PswOrder(2)
If !PswSeek(Alltrim(cNome))
	PswOrder(1)
	PswSeek(Alltrim(cNome))
EndIf

Return .T.

Function VtUsrLog(cNomUsua,cRotina)
Local aColetor   := Directory("VT*.SEM")
Local nX         := 0
Local lRet       := .F.
Local cLinha     := ""
Local cNomUAux   := ""
Local nLogUsu    := 0

cNomUsua := AllTrim(cNomUsua)
For nX := 1 to Len(aColetor)
	cLinha  := Memoread(aColetor[nX,1])
	cNomUAux:= AllTrim(Subs(cLinha,4,25))
	If cNomUAux == cNomUsua
		nLogUsu++
		If nLogUsu > 1
			lRet := .T.
			Exit
		EndIf
	EndIf
Next
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetUserAcc()
Funcao responsavel por instanciar em um objeto as caracteristicas de acesso
do usuario ao sistema tais como foram definidas no Configurador (SIGACFG)
O objeto guarda, por exemplo, o numero de tentativas de acesso ao sistema
para controle de bloqueio do usuario. Este tratamento e realizado internamente
pela classe do Framework MPUserAccount, nao sendo necessario realizar validacao
adicional neste programa.

@return  __oUserAcc - Objeto contendo as caracteristicas de acesso do usuario
@author  carlos.capeli
@since   30/06/2020
@version 12.1.17 em diante
/*/
//------------------------------------------------------------------------------
Static Function GetUserAcc()
	If __oUserAcc == Nil
		__oUserAcc := MPUserAccount():New()
		__oUserAcc:Activate()
	EndIf
Return __oUserAcc
