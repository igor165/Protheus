#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "AJSXAPT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma    ณAjSXAPT    บAutor    ณInova็ใo - RH       บ Data ณ  29/06/2015 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.       ณ Fonte responsแvels pelos ajustas na versใo p12.               บฑฑ
ฑฑบ            ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ DATA      ณ Chamado     ณ  MOTIVO DA ALTERACAO                ณฑฑ
ฑฑบGabriel A.  ณ11/07/2016 ณTVKL10       ณAjuste no valid do campo REP_CC.     ณฑฑ
ฑฑณ            ณ           ณ             ณ                                     ณฑฑ
ฑฑณ            ณ           ณ             ณ                                     ณฑฑ
ฑฑณOswaldo L   ณ27-04-17   ณDRHPONTP300  ณEntre os dias 24-04-17 e 26-04-17    ณฑฑ
ฑฑณ            ณ           ณ             ณbaixamos os fontes do TFS das pastas ณฑฑ
ฑฑณ            ณ           ณ             ณMAIN, 12.1.14 e 12.1.16. Conforme    ณฑฑ
ฑฑณ            ณ           ณ             ณsolicitado fizemos merge delas,depoisณฑฑ
ฑฑณ            ณ           ณ             ณremovemos alteracoes em SX           ณฑฑ
ฑฑบIsabel N.   ณ 25/07/2017ณDRHPONTP-360 ณAjuste/Limpeza do fonte para 12.1.17.ณฑฑ
ฑฑณWillian U.  ณ31/07/2017 ณDRHPONTP-1111ณAjustes dos inicializadores padr๕es  ณฑฑ
ฑฑณ            ณ           ณ             ณdo browse das tabelas RE0, REA e RES ณฑฑ
ฑฑณ            ณ           ณ             ณpara nใo gerar erro na tela de       ณฑฑ
ฑฑณ            ณ           ณ             ณconsulta gen้rica.                   ณฑฑ
ฑฑศออออออออออฯอออออออฑฑออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Main function APTLoad()

	Local lRet      := .T.

	AptMsgRH()

	lRet := fChkConv12()
	If !lRet
		Return
	Endif

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} AptMsgRH
Fun็ใo para exibir o comunicado sobre a descontinuidade do modulo SIGAAPT
@author  Philipe Couto
@since   29/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AptMsgRH()

Local oDlg
Local oChk1		:= .F.
Local lChk1		:= .F.
Local cTitulo	:= OemToAnsi(STR0001) //'COMUNICADO'
Local oFont1	:= TFont():New("Tahoma",,-12,.T.,.T.) 
Local cSession	:= GetPrinterSession()

//Verifica se o usuario marcou para nao visualizar a mensagem
lChkMsg := fwGetProfString(cSession,"MSG_RHOK_" + cUserName,'',.T.) == ""

If lChkMsg
	
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 250,760 PIXEL
	
	TSay():New( 010,010,{||OemToAnsi(STR0002)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'Estamos reformulando o acesso aos processos englobados pelo SIGAAPT (Acompanhamento de Processos Trabalhistas)'
	TSay():New( 025,010,{||OemToAnsi(STR0003)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'de maneira a tratแ-lo efetivamente como mais uma opera็ใo de RH.'
	TSay():New( 040,010,{||OemToAnsi(STR0004)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'Nesse contexto, o mesmo serแ descontinuado, sendo que todas as suas funcionalidades serใo migradas para o m๓dulo '
	TSay():New( 055,010,{||OemToAnsi(STR0005)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'SIGAGPE (Gestใo de Pessoal), atrav้s de op็๕es especํficas de menu.'
	TSay():New( 070,010,{||OemToAnsi(STR0008)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'A previsใo inicial para conclusใo desse processo ้ agosto/2019.'		
	TSay():New( 085,010,{||OemToAnsi(STR0009)},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK) // 'Em breve divulgaremos outras informa็๕es atrav้s do TOTVS News.'
	
	@ 110,10 CHECKBOX oChk1 VAR lChk1 PROMPT OemToAnsi(STR0006) SIZE 100,7 PIXEL OF oDlg //'Nใo apresentar novamente'
			
	TButton():New(110,350, OemToAnsi(STR0007), oDlg,{|| oDlg:End() },26,11,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Ok"	
			
	ACTIVATE MSDIALOG oDlg CENTER 
	
	If lChk1
		fwWriteProfString(cSession,"MSG_RHOK_" + cUserName,'CHECKED',.T.)
	EndIf
	
EndIf
	
Return()
