#include "Protheus.ch"
#include "GCTMSGEXPROT.CH"

/*/{Protheus.doc} MsgEndRot
	Apresenta tela informando que a rotina será descontinuada
	@type  Function
	@author Jose Renato Silva Dourado de Souza jose.souza2
	@since 08/11/2021
	@version 1.0
	@param cExpirFunc, caracter, nome da rotina que deve ser descontinuada
	@param cDescrFunc, caracter, descrição da rotina e nome da rotina que substitui a rotina descontinuada
	@param cExpiraData, caracter, data de experiração a ser informada deve estar no formato AAAAMMDD
	@param cEndWeb, caracter, endereço http referente a rotina que esta sendo descontinuada
/*/
Function MsgEndRot(cExpirFunc as character, cDescrFunc as character, cEndWeb as character, cExpiraData as character, nPauseDays as numeric)
Local dDate      as date
Local oProfile   as object
Local aLoad      as array
Local cShow      as character
Local lCheck     as logical

// Data de expiração da rotina
DEFAULT cExpiraData := "20220404"

// Número de dias que pode ser desabilitada a mensagem
DEFAULT nPauseDays := 7

dDate := Date()
oProfile := FwProFile():New()
oProfile:SetTask("GCTExpired") //Nome da sesso
oProfile:SetType(cExpirFunc) //Valor
aLoad := oProfile:Load()
If Empty(aLoad)
	cShow := "00000000"
Else
	cShow := aLoad[1]
Endif

// Reseta o controle de nPauseDays dias e volta apresentar a tela de advertencia
If cShow <> "00000000" .And. SToD(cShow) + nPauseDays <= dDate
	cShow := "00000000"
	oProfile:SetProfile({cShow})
	oProfile:Save()
ENDIF

If cShow == "00000000"
	lCheck := DlgEndRot(cExpiraData, nPauseDays, cDescrFunc, cEndWeb)

	If lCheck
		cShow := DToS(Date())
		oProfile:SetProfile({cShow})
		oProfile:Save()
	EndIf

EndIf

oProfile:Destroy()
oProfile := nil
aLoad := aSize(aLoad,0)
aLoad := nil

Return

/*/{Protheus.doc} DlgEndRot
	Apresenta tela informando que a rotina será descontinuada
	@type  Function
	@author Jose Renato Silva Dourado de Souza jose.souza2
	@since 08/11/2021
	@version 1.0
	@param cExpiraData, caracter, data de experiração a ser informada deve estar no formato AAAAMMDD
	@param nPauseDays, numeric, numero de dias que a mensagem pode ser ocultada
	@param cDescrFunc, caracter, descricão da rotina e nome da rotina que substitui a rotina descontinuada
	@param cEndWeb, caracter, endereço http referente a rotina que esta sendo descontinuada
	@return lCheck, logico, Verdadeiro se foi escolhido para desabilitar a mensagem por 07 dias
/*/
Static Function DlgEndRot(cExpiraData as character, nPauseDays as numeric, cDescrFunc as character, cEndWeb as character)
Local oSay1		as object
Local oSay2		as object
Local oSay3		as object
Local oSay4		as object
Local oCheck1	as object
Local oModal	as object
Local cMsg1		as character
Local cMsg2		as character
Local cMsg3		as character
Local cMsg4		as character
Local cSTR1		as character
Local cSTR2		as character
Local lCheck	as logical
Local lRotinExp	as logical

oModal := FWDialogModal():New()
oModal:SetCloseButton( .F. )
oModal:SetEscClose( .F. )
oModal:SetTitle(STR0001) //"Comunicado Ciclo de Vida de Sofware - TOTVS Linha Protheus"

//Define a altura e largura da janela em pixel
oModal:setSize(180, 250)

oModal:createDialog()

oModal:AddButton( STR0002, {||oModal:DeActivate()}, STR0002, , .T., .F., .T., )

oContainer := TPanel():New( ,,, oModal:getPanelMain() )
oContainer:Align := CONTROL_ALIGN_ALLCLIENT

lRotinExp := Date() >= Stod(cExpiraData)

cSTR1:=IIF(lRotinExp,STR0010,STR0003)
cSTR2:=IIF(lRotinExp,STR0011,STR0004)

cMsg1 := i18n(cSTR1,{cValToChar(SToD(cExpiraData))}) //  STR0003 ="Esta rotina será descontinuada em [04/04/2022] STR0010 = "Esta rotina foi descontinuada e teve sua manutenção encerrada em [04/04/2022]
cMsg2 := i18n(cSTR2, {cDescrFunc} ) // STR0004 = "A rotina que a substituirá é a Nova Medição(CNTA121), já disponível em nosso produto." STR0011 = A rotina que a substituiu é a Nova Medição, já disponível em nosso produto
cMsg4 := STR0005 //"Para maiores informações, favor contatar o administrador do sistema ou seu ESN TOTVS.",)

oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

oSay2 := TSay():New( 30,10,{||cMsg2 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

cMsg3 := Alltrim(STR0006)+space(01) // "Para conhecer mais sobre a convergência entre essas rotinas, "
If ! Empty(cEndWeb)
	cMsg3 += "<b><a target='_blank' href='"+cEndWeb+"'> "
	cMsg3 += Alltrim(STR0007) // "clique aqui"
	cMsg3 += " </a></b>."
	cMsg3 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"
	oSay3 := TSay():New(50,10,{||cMsg3},oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
	oSay3:bLClicked := {|| MsgRun( STR0008, "URL",{|| ShellExecute("open",cEndWeb,"","",1) } ) } // "Abrindo o link... Aguarde..."
EndIf
oSay4 := TSay():New( 70,10,{||cMsg4 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

lCheck := .F.
oCheck1 := TCheckBox():New(100,10,i18n(STR0009,{strzero(nPauseDays,2)}) ,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,220,21,,,,,,,,.T.,,,) // "Não apresentar esta mensagem nos proximos [07] dias."

oModal:Activate()

Return lCheck
