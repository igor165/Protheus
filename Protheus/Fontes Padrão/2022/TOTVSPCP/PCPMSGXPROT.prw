#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPMSGXPROT.CH"

/*/{Protheus.doc} PCPMsgExp
Função responsavel pela mensagem de descontinuação das rotinas.
@type  Function
@author Lucas Fagundes
@since 25/02/2022
@version P12
@param 01 cRotDesc, Caracter, Rotina que será descontinuada.
@param 02 cRotNew, Caracter, Rotina que irá subtistuir a rotina descontinuada.
@param 03 cEndWeb, Caracter, Documentação da rotina que será descontinuada.
@param 04 cEndNewRot, Caracter, Documentação da rotina que irá substituir.
@param 05 cExpiraData, Caracter, Data que a rotina irá ser descontinuada.
@param 06 nPauseDays, Numerico, Numero de dias que a mensagem será ocultada.
@return Nil
/*/
Function PCPMsgExp(cRotDesc, cRotNew, cEndWeb, cEndNewRot, cExpiraData, nPauseDays)
    
    Local aLoad    := {}
    Local cShow    := ""
    Local dDate    := Date()
    Local lCheck   := .F.
    Local oProfile := Nil

    Default cExpiraData := "20220831"
    Default nPauseDays  := 10

    If !isBlind()
        oProfile := FwProFile():New()
        oProfile:SetTask("PCPExpired")
        oProfile:SetType(cRotDesc)
        aLoad := oProfile:Load()

        If Empty(aLoad)
            cShow := "00000000"
        Else
            cShow := aLoad[1]
        EndIf

        If cShow <> "00000000" .and. SToD(cShow) + nPauseDays <= dDate
            cShow := "00000000"
            oProfile:SetProfile({cShow})
            oProfile:Save()
        EndIf

        If cShow == "00000000"
            lCheck := MostraTela(cExpiraData, nPauseDays, cRotNew, cEndWeb, cEndNewRot)

            If lCheck
                cShow := DToS(Date())
                oProfile:SetProfile({cShow})
                oProfile:Save()
            EndIf
        EndIf
    EndIf

Return

/*/{Protheus.doc} MostraTela
Exibe a tela de descontinuação da rotina.
@type  Static Function
@author Lucas Fagundes
@since 25/02/2022
@version P12
@param 01 cExpiraData, Caracter, Data que a rotina irá ser descontinuada.
@param 02 nPauseDays, Numerico, Numero de dias que a mensagem será ocultada.
@param 03 cRotNew, Caracter, Rotina que irá subtistuir a rotina descontinuada.
@param 04 cEndWeb, Caracter, Documentação da rotina que será descontinuada.
@param 05 cEndNewRot, Caracter, Documentação da rotina que irá substituir.
@return lCheck, Logic, Verdadeiro se for escolhido para desabilitar a mensagem por 30 dias.
/*/
Static Function MostraTela(cExpiraData, nPauseDays, cRotNew, cEndWeb, cEndNewRot)
    
    Local cMsg1    := ""
    Local cMsg2    := ""
    Local cMsg3    := ""
    Local cMsg4    := ""
    Local lCheck   := .F.
    Local lExpired := .F.
    Local oCheck1  := Nil
    Local oModal   := Nil
    Local oSay1    := Nil
    Local oSay2    := Nil
    Local oSay3    := Nil
    Local oSay4    := Nil

    lExpired := Date() > StoD(cExpiraData)

    oModal := FWDialogModal():New()
    oModal:SetCloseButton(.F.)
    oModal:SetEscClose(.F.)
    oModal:SetTitle(STR0001) // "Comunicado Ciclo de Vida de Sofware - TOTVS Linha Protheus"

    //define a altura e largura da janela em pixel
	oModal:setSize(180, 250)

    oModal:createDialog()
    oModal:AddButton(STR0002, {||oModal:DeActivate()}, STR0002, , .T., .F., .T., ) // "Confirmar"
    
    oContainer := TPanel():New( ,,, oModal:getPanelMain() )
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

    If lExpired
        cMsg1 := i18n(STR0010, {cValToChar(stod(cExpiraData))}) // "Esta rotina foi descontinuada em #1[31/08/2022]# e não sofrerá mais manutenção."
        cMsg2 := i18n(STR0011, {cEndNewRot, cRotNew} ) // "A rotina que a substituiu é a <b><a target='_blank' href='#1[cEndNewRot]'>#2[MRP Memória (PCPA712)]#</a></b>."
    Else
        cMsg1 := i18n(STR0003,{cValToChar(stod(cExpiraData))}) // "Esta rotina deixará de ter manutenção em #1[31/08/2022]#"
        cMsg2 := i18n(STR0004, {cEndNewRot, cRotNew} ) // "A rotina que a substituirá é a <b><a target='_blank' href='#1[cEndNewRot]'>#2[MRP Memória (PCPA712)]#</a></b>, já disponivel em nosso produto."
    EndIf
    
	cMsg4 := STR0005 // "Para maiores informações, favor contatar o administrador do sistema ou seu ESN TOTVS."

	oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
	oSay2 := TSay():New( 30,10,{||cMsg2 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
    oSay2:bLClicked := {|| MsgRun(STR0008, "URL",{|| ShellExecute("open",cEndNewRot,"","",1) } ) } // "Abrindo o link... Aguarde..."

    cMsg3 := Alltrim(STR0006)+space(01) // "Para conhecer mais sobre a convergência entre essas rotinas, "
	If !Empty(cEndWeb)
		cMsg3 += "<b><a target='_blank' href='"+cEndWeb+"'> "
		cMsg3 += Alltrim(STR0007) // "clique aqui"
		cMsg3 += " </a></b>."
		cMsg3 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"
		oSay3 := TSay():New(50,10,{||cMsg3},oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
		oSay3:bLClicked := {|| MsgRun(STR0008, "URL",{|| ShellExecute("open",cEndWeb,"","",1) } ) } // "Abrindo o link... Aguarde..."
	EndIf
	oSay4 := TSay():New( 70,10,{||cMsg4 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

	lCheck := .F.
	oCheck1 := TCheckBox():New(100,10,i18n(STR0009,{strzero(nPauseDays,2)}) ,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,220,21,,,,,,,,.T.,,,) // "Não apresentar esta mensagem nos proximos #1[30]# dias."

	oModal:Activate()

Return lCheck

