#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'OFIA411.CH'

/*/{Protheus.doc} OFIA411
    Rotina scheduler que vai rodar infinitamente e gerar conforme especificações(SCHEDULER)

    @author Jose Silveira
    @since  10/09/2021
/*/
Function OFIA411(aParam)

Private lSchedule := FWGetRunSchedule()
Private oUtil           := DMS_Util():New()
Private oSqlHlp         := DMS_SqlHelper():New()
Private oArHlp          := DMS_ArrayHelper():New()

Private oDTFConfig      := OFJDDTFConfig():New()
Private oRetAPiG := OFJDDTF():New("GET")
Private oRetAPiP := OFJDDTF():New("PUT")

	if !lSchedule
		Processa( {|lAbort| OA411001A_CallAPIDTF() } )
	Else
		BatchProcess(STR0024,STR0025,,{ || OA411002A_CallDTFAPI() }) //Geração de dados VMI / Este processo funciona via agendador, é um processo infinito que gera os dados de inicialização do VMI.
	EndIf

Return .T.

/*/{Protheus.doc} SchedDef
	Função padrão scheduler

	@author Vinicius Gati
	@since 28/06/2017
	@type function
/*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"",;
	"",;
	"",;
	"" ;
	}
Return aParam
/*/{Protheus.doc} OA411001A_CallAPIDTF
	Chamnada Pontual das APIs DTF

	@author       Jose Luis
	@since        20/09/2021
	@description  Tela para executar a chamada das APIs

/*/
Static Function OA411001A_CallAPIDTF()

	Local oOK := LoadBitmap(GetResources(),'br_verde')
	Local oNO := LoadBitmap(GetResources(),'br_vermelho')

	Private oDlg,oBtnALL,oBtnSts
	Private oSBtn01,oSBtn02,oSBtn03,oSBtn04,oSBtn05,oSBtn06,oSBtn07,oSBtn08
	Private oSBtn09,oSBtn10,oSBtn11,oSBtn12,oSBtn13,oSBtn14,oSBtn15,oSBtn16

	oDTFConfig:GetConfig()

	oDlg := MSDIALOG():Create()
	oDlg:cName     := "oDlg"
	oDlg:cCaption  := STR0001//"DTF API"
	oDlg:nLeft     := 0
	oDlg:nTop      := 0
	oDlg:nWidth    := 650
	oDlg:nHeight   := 350
	oDlg:lShowHint := .F.
	oDlg:lCentered := .F.

	oSBtn01                := TButton():Create(oDlg)
	oSBtn01:cName          := "oSBtn01"
	oSBtn01:cCaption       := STR0002//"Cotação Maquina"
	oSBtn01:nLeft          := 16
	oSBtn01:nTop           := 10
	oSBtn01:nWidth         := 200
	oSBtn01:nHeight        := 22
	oSBtn01:lShowHint      := .F.
	oSBtn01:lReadOnly      := .F.
	oSBtn01:Align          := 0
	oSBtn01:lVisibleControl:= .T.
	oSBtn01:bAction        := { || oRetAPiP:getDTFPut_Service(oDTFConfig:getCotacao_Maquina()), MSGINFO(STR0026) }//"Envio finalizado"

	oSBtn02                := TButton():Create(oDlg)
	oSBtn02:cName          := "oSBtn02"
	oSBtn02:cCaption       := STR0003//"ELIPS"
	oSBtn02:nLeft          := 16
	oSBtn02:nTop           := 40
	oSBtn02:nWidth         := 200
	oSBtn02:nHeight        := 22
	oSBtn02:lShowHint      := .F.
	oSBtn02:lReadOnly      := .F.
	oSBtn02:Align          := 0
	oSBtn02:lVisibleControl:= .T.
	oSBtn02:bAction        := { || oRetAPiP:getDTFPut_Service(oDTFConfig:getELIPS()), MSGINFO(STR0026) }//"Envio finalizado"

	oSBtn03                := TButton():Create(oDlg)
	oSBtn03:cName          := "oSBtn03"
	oSBtn03:cCaption       := STR0004//"PMMANAGE"
	oSBtn03:nLeft          := 16
	oSBtn03:nTop           := 70
	oSBtn03:nWidth         := 200
	oSBtn03:nHeight        := 22
	oSBtn03:lShowHint      := .F.
	oSBtn03:lReadOnly      := .F.
	oSBtn03:Align          := 0
	oSBtn03:lVisibleControl:= .T.
	oSBtn03:bAction        := { || oRetAPiP:getDTFPut_Service(oDTFConfig:getPMMANAGE()), MSGINFO(STR0026) }//"Envio finalizado"

	oSBtn04                := TButton():Create(oDlg)
	oSBtn04:cName          := "oSBtn04"
	oSBtn04:cCaption       := STR0005//"DPMEXT"
	oSBtn04:nLeft          := 16
	oSBtn04:nTop           := 100
	oSBtn04:nWidth         := 200
	oSBtn04:nHeight        := 22
	oSBtn04:lShowHint      := .F.
	oSBtn04:lReadOnly      := .F.
	oSBtn04:Align          := 0
	oSBtn04:lVisibleControl:= .T.
	oSBtn04:bAction        := { || oRetAPiP:getDTFPut_Service(oDTFConfig:getDPMEXT()), MSGINFO(STR0026) }//"Envio finalizado"

	oSBtn05                := TButton():Create(oDlg)
	oSBtn05:cName          := "oSBtn05"
	oSBtn05:cCaption       := STR0006//"Parts_Locator"
	oSBtn05:nLeft          := 16
	oSBtn05:nTop           := 130
	oSBtn05:nWidth         := 200
	oSBtn05:nHeight        := 22
	oSBtn05:lShowHint      := .F.
	oSBtn05:lReadOnly      := .F.
	oSBtn05:Align          := 0
	oSBtn05:lVisibleControl:= .T.
	oSBtn05:bAction        := { || oRetAPiP:getDTFPut_Service(oDTFConfig:getParts_Locator()), MSGINFO(STR0026) }//"Envio finalizado"

	oSBtn06                := TButton():Create(oDlg)
	oSBtn06:cName          := "oSBtn06"
	oSBtn06:cCaption       := STR0007//"Parts_Surplus_Returns"
	oSBtn06:nLeft          := 16
	oSBtn06:nTop           := 160
	oSBtn06:nWidth         := 200
	oSBtn06:nHeight        := 22
	oSBtn06:lShowHint      := .F.
	oSBtn06:lReadOnly      := .F.
	oSBtn06:Align          := 0
	oSBtn06:lVisibleControl:= .T.
	oSBtn06:bAction        := { || oRetAPiP:getDTFPut_Service(oDTFConfig:getParts_Surplus_Returns()), MSGINFO(STR0026) }//"Envio Finalizado"

	oSBtn07                := TButton():Create(oDlg)
	oSBtn07:cName          := "oSBtn07"
	oSBtn07:cCaption       := STR0008//"SMManage"
	oSBtn07:nLeft          := 16
	oSBtn07:nTop           := 190
	oSBtn07:nWidth         := 200
	oSBtn07:nHeight        := 22
	oSBtn07:lShowHint      := .F.
	oSBtn07:lReadOnly      := .F.
	oSBtn07:Align          := 0
	oSBtn07:lVisibleControl:= .T.
	oSBtn07:bAction        := { || oRetAPiP:getDTFPut_Service(oDTFConfig:getSMManage()), MSGINFO(STR0026) }//"Envio Finalizado"

	oSBtn08                := TButton():Create(oDlg)
	oSBtn08:cName          := "oSBtn08"
	oSBtn08:cCaption       := STR0009// "DFA"
	oSBtn08:nLeft          := 16
	oSBtn08:nTop           := 220
	oSBtn08:nWidth         := 200
	oSBtn08:nHeight        := 22
	oSBtn08:lShowHint      := .F.
	oSBtn08:lReadOnly      := .F.
	oSBtn08:Align          := 0
	oSBtn08:lVisibleControl:= .T.
	oSBtn08:bAction        := { || oRetAPiP:getDTFPut_Service(oDTFConfig:getDFA()), MSGINFO(STR0026) } // "Envio Finalizado"

	oSBtn17                := TButton():Create(oDlg)
	oSBtn17:cName          := "oSBtn17"
	oSBtn17:cCaption       := STR0028// "UP_Incentivo_Maquina"
	oSBtn17:nLeft          := 16
	oSBtn17:nTop           := 250
	oSBtn17:nWidth         := 200
	oSBtn17:nHeight        := 22
	oSBtn17:lShowHint      := .F.
	oSBtn17:lReadOnly      := .F.
	oSBtn17:Align          := 0
	oSBtn17:lVisibleControl:= .T.
	oSBtn17:bAction        := { || oRetAPiP:getDTFPut_Service(oDTFConfig:get_UP_Incentivo_Maquina()), MSGINFO(STR0026) } // "Envio Finalizado"

	oSBtn09                := TButton():Create(oDlg)
	oSBtn09:cName          := "oSBtn09"
	oSBtn09:cCaption       := STR0010//"CGPoll"
	oSBtn09:nLeft          := 236
	oSBtn09:nTop           := 10
	oSBtn09:nWidth         := 200
	oSBtn09:nHeight        := 22
	oSBtn09:lShowHint      := .F.
	oSBtn09:lReadOnly      := .F.
	oSBtn09:Align          := 0
	oSBtn09:lVisibleControl:= .T.
	oSBtn09:bAction        := { || OA411002A_CallDTFAPI(oDTFConfig:getCGPoll()), MSGINFO(STR0027) }// "Recebimento finalizado"

	oSBtn10                := TButton():Create(oDlg)
	oSBtn10:cName          := "oSBtn10"
	oSBtn10:cCaption       := STR0011//"Warranty"
	oSBtn10:nLeft          := 236
	oSBtn10:nTop           := 40
	oSBtn10:nWidth         := 200
	oSBtn10:nHeight        := 22
	oSBtn10:lShowHint      := .F.
	oSBtn10:lReadOnly      := .F.
	oSBtn10:Align          := 0
	oSBtn10:lVisibleControl:= .T.
	oSBtn10:bAction        := { || OA411002A_CallDTFAPI(oDTFConfig:getWarranty()), MSGINFO(STR0027) }//"Recebimento finalizado"

	oSBtn11                := TButton():Create(oDlg)
	oSBtn11:cName          := "oSBtn11"
	oSBtn11:cCaption       := STR0012//"Incentivo_Maquina"
	oSBtn11:nLeft          := 236
	oSBtn11:nTop           := 70
	oSBtn11:nWidth         := 200
	oSBtn11:nHeight        := 22
	oSBtn11:lShowHint      := .F.
	oSBtn11:lReadOnly      := .F.
	oSBtn11:Align          := 0
	oSBtn11:lVisibleControl:= .T.
	oSBtn11:bAction        := { || OA411002A_CallDTFAPI(oDTFConfig:getIncentivo_Maquina()), MSGINFO(STR0027) }//"Recebimento finalizado"

	oSBtn12                := TButton():Create(oDlg)
	oSBtn12:cName          := "oSBtn12"
	oSBtn12:cCaption       := STR0013//"JDPRISM"
	oSBtn12:nLeft          := 236
	oSBtn12:nTop           := 100
	oSBtn12:nWidth         := 200
	oSBtn12:nHeight        := 22
	oSBtn12:lShowHint      := .F.
	oSBtn12:lReadOnly      := .F.
	oSBtn12:Align          := 0
	oSBtn12:lVisibleControl:= .T.
	oSBtn12:bAction        := { || OA411002A_CallDTFAPI(oDTFConfig:getJDPRISM()), MSGINFO(STR0027) }//"Recebimento finalizado"

	oSBtn13                := TButton():Create(oDlg)
	oSBtn13:cName          := "oSBtn13"
	oSBtn13:cCaption       := STR0014//"Parts_Info"
	oSBtn13:nLeft          := 236
	oSBtn13:nTop           := 130
	oSBtn13:nWidth         := 200
	oSBtn13:nHeight        := 22
	oSBtn13:lShowHint      := .F.
	oSBtn13:lReadOnly      := .F.
	oSBtn13:Align          := 0
	oSBtn13:lVisibleControl:= .T.
	oSBtn13:bAction        := { || OA411002A_CallDTFAPI(oDTFConfig:getParts_Info()), MSGINFO(STR0027) }//"Recebimento finalizado"

	oSBtn14                := TButton():Create(oDlg)
	oSBtn14:cName          := "oSBtn14"
	oSBtn14:cCaption       := STR0015//"Parts_Returns"
	oSBtn14:nLeft          := 236
	oSBtn14:nTop           := 160
	oSBtn14:nWidth         := 200
	oSBtn14:nHeight        := 22
	oSBtn14:lShowHint      := .F.
	oSBtn14:lReadOnly      := .F.
	oSBtn14:Align          := 0
	oSBtn14:lVisibleControl:= .T.
	oSBtn14:bAction        := { || OA411002A_CallDTFAPI(oDTFConfig:getAuthorized_Parts_Returns()), MSGINFO(STR0027) }//"Recebimento finalizado"

	oSBtn15                := TButton():Create(oDlg)
	oSBtn15:cName          := "oSBtn15"
	oSBtn15:cCaption       := STR0016//"Parts_Subs"
	oSBtn15:nLeft          := 236
	oSBtn15:nTop           := 190
	oSBtn15:nWidth         := 200
	oSBtn15:nHeight        := 22
	oSBtn15:lShowHint      := .F.
	oSBtn15:lReadOnly      := .F.
	oSBtn15:Align          := 0
	oSBtn15:lVisibleControl:= .T.
	oSBtn15:bAction        := { || OA411002A_CallDTFAPI(oDTFConfig:getParts_Subs()), MSGINFO(STR0027) }//"Recebimento finalizado"

	oSBtn16                := TButton():Create(oDlg)
	oSBtn16:cName          := "oSBtn16"
	oSBtn16:cCaption       := STR0017//"Não Classificados"
	oSBtn16:nLeft          := 236
	oSBtn16:nTop           := 220
	oSBtn16:nWidth         := 200
	oSBtn16:nHeight        := 22
	oSBtn16:lShowHint      := .F.
	oSBtn16:lReadOnly      := .F.
	oSBtn16:Align          := 0
	oSBtn16:lVisibleControl:= .T.
	oSBtn16:bAction        := { || oRetAPiG:getDTFList_Service("NAO_CLASSIFICADOS",oDTFConfig:getNAO_CLASSIFICADOS(),.t.), MSGINFO(STR0027) }//"Recebimento finalizado"


	oBtnALL := TButton():Create(oDlg)
	oBtnALL:cName := "oBtnALL"
	oBtnALL:cCaption := STR0018 // TODOS
	oBtnALL:nLeft := 470
	oBtnALL:nTop := 220
	oBtnALL:nWidth := 100
	oBtnALL:nHeight := 22
	oBtnALL:lShowHint := .F.
	oBtnALL:lReadOnly := .F.
	oBtnALL:Align := 0
	oBtnALL:lVisibleControl := .T.
	oBtnALL:bAction := {|| OA411002A_CallDTFAPI() }

	oBrowse := TWBrowse():New( 10, 226, 80, 75,,{'','METHODO'},{20,30},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	aBrowse   := {  {oRetAPiG:chekDTFListService(),     STR0019}     ,;//"File List"
					{oRetAPiG:chekDTFDownloadService(), STR0020} ,;//"File Download"
					{oRetAPiP:chekDTFPutService(),      STR0021}   ,;//"File Upload"
					{oRetAPiG:setAuthentication(),      STR0022}     ,;//"Okta Read"
					{oRetAPiP:setAuthentication(),      STR0023}     }//"Okta Write"

	oBrowse:SetArray(aBrowse)

	oBrowse:bLine := {||{If(aBrowse[oBrowse:nAt,01],oOK,oNO),aBrowse[oBrowse:nAt,02]} }

	oDlg:Activate()
Return

/*/{Protheus.doc} OA411002A_CallDTFAPI
	Chamada em bath dos APIs DTF
	@author       Jose Silveira
	@since        10/09/2021
	@description  Chanda para Schedule

/*/

Function OA411002A_CallDTFAPI(cDirArq)

Local nIdx := 1
Local aMethod := {}
Local oRetAPi
Local oRecAPi
Default cDirArq := nil

	oDTFConfig:GetConfig()

	AADD(aMethod, {""                       , oDTFConfig:getCotacao_Maquina()          ,"U"})
	AADD(aMethod, {""                       , oDTFConfig:getELIPS()                    ,"U"})
	AADD(aMethod, {""                       , oDTFConfig:getPMMANAGE()                 ,"U"})
	AADD(aMethod, {""                       , oDTFConfig:getDPMEXT()                   ,"U"})
	AADD(aMethod, {""                       , oDTFConfig:getParts_Locator()            ,"U"})
	AADD(aMethod, {""                       , oDTFConfig:getParts_Surplus_Returns()    ,"U"})
	AADD(aMethod, {""                       , oDTFConfig:getSMManage()                 ,"U"})
	AADD(aMethod, {""                       , oDTFConfig:getDFA()                      ,"U"})
	AADD(aMethod, {""                       , oDTFConfig:get_UP_Incentivo_Maquina()    ,"U"})
	AADD(aMethod, {"RECEIPTS"               , oDTFConfig:getCGPoll()                   ,"D"})
	AADD(aMethod, {"WARRMEMO"               , oDTFConfig:getWarranty()                 ,"D"})
	AADD(aMethod, {".BRCMAMT"               , oDTFConfig:getIncentivo_Maquina()        ,"D"})
	AADD(aMethod, {".BRSLERR"               , oDTFConfig:getIncentivo_Maquina()        ,"D"})
	AADD(aMethod, {"DPMORD"                 , oDTFConfig:getJDPRISM()                  ,"D"})
	AADD(aMethod, {"DPMSCHED"               , oDTFConfig:getJDPRISM()                  ,"D"})
	AADD(aMethod, {"DPMXFER"                , oDTFConfig:getJDPRISM()                  ,"D"})
	AADD(aMethod, {"PARTINFO_BR_ALL_FULL_V2", oDTFConfig:getParts_Info()               ,"D"})
	AADD(aMethod, {"RETATH"                 , oDTFConfig:getAuthorized_Parts_Returns() ,"D"})
	AADD(aMethod, {"PARTSUBS"               , oDTFConfig:getParts_Subs()               ,"D"})
	AADD(aMethod, {"NAO_CLASSIFICADOS"      , oDTFConfig:getNAO_CLASSIFICADOS()        ,"D"}) // sempre a ultima chamada


	if ValType(cDirArq) == "C"
		for nIdx := 1 to len(aMethod)

			if aMethod[nIdx][2] == cDirArq
				oRecAPi := oRetAPiG:getDTFList_Service(aMethod[nIdx][1],aMethod[nIdx][2],.t.)
			endif

		Next
	Else
		for nIdx := 1 to len(aMethod)

			if aMethod[nIdx][3] == "U"
				oRecAPi := oRetAPiP:getDTFPut_Service(aMethod[nIdx][2])
			else
				oRecAPi := oRetAPiG:getDTFList_Service(aMethod[nIdx][1],aMethod[nIdx][2],.t.)
			endif

		Next

	Endif

Return

