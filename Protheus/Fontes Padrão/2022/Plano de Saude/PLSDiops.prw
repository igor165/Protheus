#include 'protheus.ch'
#include 'PLSDIOPS.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SendDiop
Monta dialogo para o usuario informar a senha

@author    plsteam
@version   1.xx
@since     22/08/11
/*/
Function SendDiop()

LOCAL cRoot   := GetPvProfString(GetEnvServer(), "RootPath", "", GetADV97())
LOCAL cSystem := GetPvProfString(GetEnvServer(), "StartPath", "", GetADV97()) 

LOCAL cCaminho   := cRoot + cSystem + "Diops"
LOCAL cNome		 := "TotvsDiopsSender.jar"
LOCAL aParametro := {}
LOCAL cLib		 := "\lib\DIOPSClient.jar"

LOCAL cRecibo := cCaminho + "\recibos"
LOCAL cLog    := cCaminho + "\logs"
LOCAL cPerg	  := "PLDIOPSEND"

LOCAL cRet
LOCAL cPass

MakeDir(cCaminho)
MakeDir(cLog)
MakeDir(cRecibo)

If !Pergunte(cPerg)
	Return
EndIf

cPass := AllTrim(PLSASenha())

AAdd(aParametro,cRecibo)
AAdd(aParametro,AllTrim(mv_par02))
AAdd(aParametro,Iif(mv_par01==1,"Financeiro","Cadastral"))
AAdd(aParametro,cPass)

cLog += "\" + DToS(Date()) + "_" + StrTran(Time(),":","")

AAdd(aParametro,cLog + "_erro.log")
AAdd(aParametro,cLog + "_resp.log")

cRet := PLSJAVA(cCaminho,cNome,aParametro,cLib)

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0001 + cRet , 0, 0, {})

If cRet <> "0"

	If "Erro" $ cRet
		Alert(cRet)
	Else
		Alert(STR0002+Chr(13)+Chr(10)+STR0003)
	EndIf
	
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSASenha
Monta dialogo para o usuario informar a senha

@author    plsteam
@version   1.xx
@since     10/08/11
/*/
Function PLSASenha()
Local oDlgSenha
Local oGetSenha
Local cSen := Space(15)

DEFINE DIALOG oDlgSenha Of GetWndDefault() TITLE STR0007 FROM 12, 30 TO 18,55 //"Senha ANS"

@ .5,1 SAY STR0008	// Senha:
@ 1.1,1 MSGET oGetSenha VAR cSen PASSWORD

DEFINE SBUTTON FROM 32,65 TYPE 1 ACTION oDlgSenha:End() ENABLE OF oDlgSenha

ACTIVATE MSDIALOG oDlgSenha CENTERED

Return PadR( cSen, 15 )