//Bibliotecas
#Include "Protheus.CH"
#Include "FWMVCDef.CH"
#Include "FINA890.CH"
#Include "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#Include "FwSchedule.ch"
#Include "Ap5Mail.Ch"

Static __lF71IdBx := Nil
Static __lOpcCanc := .T.
Static __lGravFWI := Nil
Static __ExcluiIm := Nil
Static __lIdProc  := Nil
Static __F71IdPd  := Nil

/*/{Protheus.doc} FINA890
Monitor PIX.

@author Robson Melo
@since  10/10/2020
@version 12.1.019
/*/
Function FINA890()
	Local lRetorno As Logical
	Local oBrowse  As Object
	
	//Inicializa variáveis.
	lRetorno := F890ChaPix()
	
	If lRetorno
		oBrowse := FwMBrowse():New()
		oBrowse:SetAlias("F71")
		oBrowse:SetDescription(STR0001)  //"Monitor PIX"
		oBrowse:SetProfileID("FINA890")
		oBrowse:SetMenuDef('FINA890')
		oBrowse:SetUseFilter(.T.)

		//Legendas
		oBrowse:AddLegend("F71->F71_STATUS = '1' .And. F71->F71_SOLCAN =  '2'",	"BLUE",			STR0002 + STR0068 + STR0069) //"A Gerar CNAB" " / " "Aguardando Integração"
		oBrowse:AddLegend("F71->F71_STATUS = '2' .And. F71->F71_SOLCAN =  '2'",	"WHITE",		STR0003) //"CNAB Gerado"
		oBrowse:AddLegend("F71->F71_STATUS = '2' .And. F71->F71_SOLCAN =  '1'",	"BR_AZUL_CLARO",	STR0073) //"Aguardando retorno bancário da emissão."
		oBrowse:AddLegend("F71->F71_STATUS = '3' .And. F71->F71_SOLCAN =  '2'",	"ORANGE",		STR0004) //"QR Code Gerado"
		oBrowse:AddLegend("F71->F71_STATUS = '4' .And. F71->F71_SOLCAN =  '2'",	"YELLOW",		STR0005) //"Cliente Notificado"
		oBrowse:AddLegend("F71->F71_STATUS = '5'",								"GREEN",		STR0006) //"Recebimento Confirmado"
		oBrowse:AddLegend("F71->F71_STATUS = '3' .And. F71->F71_SOLCAN =  '1' .And. !(Empty(F71->F71_IDPD))",	"BR_VIOLETA",	STR0070) //"Aguardando Cancelamento (Integração)
		oBrowse:AddLegend("!(F71->F71_STATUS $ '6|7') .And. F71->F71_SOLCAN = '1' .And. Empty(F71->F71_IDPD)",	"PINK",			STR0025) //"Cancelamento Solicitado (CNAB)"
		oBrowse:AddLegend("F71->F71_STATUS = '6'",								"RED",			STR0007) //"Cancelamento Enviado ao Banco (CNAB)"
		oBrowse:AddLegend("F71->F71_STATUS = '7'",								"BLACK",		STR0008) //"Cancelado"
		oBrowse:AddLegend("F71->F71_STATUS =  '8'", "GRAY",												STR0074) //"Pagamento Estornado"

		SetKey(VK_F12, {|a,b| AcessaPerg("FINA890", .T.)})
		oBrowse:Activate()
	EndIf
Return Nil

/*/{Protheus.doc} MenuDef()
Criação do menu MVC.

@author		Robson Melo
@since		10/10/2020
@version	12.1.027
/*/
Static Function MenuDef() As Array

	Local aRot As Array

	aRot := {}

	ADD OPTION aRot TITLE STR0009	ACTION "FINA891"			OPERATION MODEL_OPERATION_INSERT 		ACCESS 0 //"Gerar"
	ADD OPTION aRot TITLE STR0011	ACTION "VIEWDEF.FINA890"	OPERATION MODEL_OPERATION_VIEW   		ACCESS 0 //"Visualizar"
	ADD OPTION aRot TITLE STR0010	ACTION "VIEWDEF.FINA890"	OPERATION MODEL_OPERATION_ONLYUPDATE 	ACCESS 0 //"Cancelar"
	ADD OPTION aRot TITLE STR0027	ACTION "F890Cfg"			OPERATION MODEL_OPERATION_INSERT 		ACCESS 0 //"Configurar"
	ADD OPTION aRot TITLE STR0013	ACTION "FinRPIX"			OPERATION MODEL_OPERATION_INSERT 		ACCESS 0 //"Imprimir PIX"
	ADD OPTION aRot TITLE STR0028	ACTION "F890Mail"			OPERATION MODEL_OPERATION_VIEW   		ACCESS 0 //"Enviar E-mail"

Return aRot

/*/{Protheus.doc} ModelDef()
Criação do modelo de dados MVC.

@author		Robson Melo
@since		10/10/2020
@version	12.1.027
/*/
Static Function ModelDef() As Object
	Local oModel As Object
	Local oStF71 As Object
	
	oModel := Nil
	oStF71 := FwFormStruct(1, "F71")
	oModel := MPFormModel():New("FINA890M",,, {|model| F890Commit(model)})
	
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMF71",/*cOwner*/, oStF71)
	oModel:SetPrimaryKey({"F71_FILIAL", "F71_PREFIX", "F71_NUM", "F71_PARCEL", "F71_TIPO"})
	oModel:SetDescription(STR0001) //"Monitor PIX"
	oModel:GetModel("FORMF71"):SetDescription(STR0001) //"Monitor PIX"
	oModel:SetVldActivate({|model| F890VldMod(model)})
	oModel:SetActivate({|model| F890Active(model)})
Return oModel
 
/*/{Protheus.doc} ViewDef()
Criação da visão MVC.

@author		Robson Melo
@since		10/10/2020
@version	12.1.027
/*/
Static Function ViewDef() As Object
	Local oModel  As Object
	Local oStF71  As Object
	Local oView   As Object
	Local lTemDic As Logical
	
	oModel := FwLoadModel("FINA890")
	oStF71 := FwFormStruct(2, "F71")
	
	If (__lF71IdBx == Nil .Or. __lIdProc == Nil .Or. __F71IdPd == Nil)  
		lTemDic    := (cPaisLoc == "BRA" .And. TableInDic("F71"))
		__lF71IdBx := IIf(lTemDic, (F71->(FieldPos("F71_IDFK1")) > 0), lTemDic)
		__lIdProc  := IIf(lTemDic, (F71->(FieldPos("F71_IDPROC")) > 0), lTemDic)
		__F71IdPd  := IIf(lTemDic, (F71->(FieldPos("F71_IDPD")) > 0), lTemDic)
	EndIf	
	
	oStF71:RemoveField("F71_IDDOC")
	oStF71:RemoveField("F71_IDTRAN")
	oStF71:RemoveField("F71_EMVPIX")
	
	If __lIdProc
		oStF71:RemoveField("F71_IDPROC")
	EndIf
	
	If __F71IdPd
		oStF71:RemoveField("F71_IDPD")
	EndIf
	
	If __lF71IdBx
		oStF71:RemoveField("F71_IDFK1")
	EndIf

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FwFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_F71", oStF71, "FORMF71")
	oView:CreateHorizontalBox("TELA", 100)
	oView:EnableTitleView("VIEW_F71", STR0001)  //"Monitor Pix"
	oView:SetCloseOnOk({|| .T.})
	oView:SetOwnerView("VIEW_F71", "TELA")
	oView:SetViewProperty("FORMF71", "ONLYVIEW")
	oView:SetUpdateMessage(STR0010, STR0018) //"Cancelar" //"Pix cancelado com sucesso."

Return oView

/*/{Protheus.doc} F880ChaPix
Cadastro de chaves pix.

@author		R. Melo
@since		10/10/2020
@version	1.0
/*/
Function F890ChaPix() As Logical
	Local aAreaAtual As Array
	Local aAreaSX1   As Array
	Local cTblSE1    As Character
	Local cTblF71    As Character
	Local cCompSE1   As Character
	Local cCompF71   As Character	
	Local lOk        As Logical
	Local nEnt       As Numeric
	
	//Inicializa variáveis
	cTblSE1  := "SE1"
	cTblF71  := "F71"
	cCompSE1 := ""
	cCompF71 := ""
	lOk      := .T.
	nEnt     := 1
	
	For nEnt := 1 To 3
		cCompSE1 := FwModeAccess(cTblSE1, nEnt)
		cCompF71 := FwModeAccess(cTblF71, nEnt)		
		
		If !(lOk := (cCompSE1 == cCompF71))
			Help(" ", 1, STR0014 ,, STR0015  + '"' + AllTrim(FwX2Nome(cTblF71)) + ' ('+ cTblF71 + ')"' + STR0016  + '"' + AllTrim(FwX2Nome(cTblSE1)) + ' (' + cTblSE1 + ')"' , 2, 0,,,,,, { STR0017 }) //"Atenção" //"A tabela " //" está com o compartilhamento diferente da tabela " //"Ajuste o compartilhamento das tabelas."
			Exit
		EndIf
	Next nEnt
	
	If lOk
		aAreaAtual := GetArea()
		aAreaSX1   := SX1->(GetArea())
		SX1->(DbSetOrder(1))
		
		__lGravFWI := IIf(__lGravFWI == Nil, FindFunction("FinAGrvFWI"), __lGravFWI)
		
		If !(lOk := (__lGravFWI .And. SX1->(MsSeek("FINA890")) .And. AliasIndic("FWI")))
			Help(,,"F890DIC",,STR0026,1,0)  //"Inconsistência de dicionário. Verifique a existência do grupo de perguntas FINA890 e da tabela FWI."
		EndIf
		
		RestArea(aAreaSX1)
		RestArea(aAreaAtual)
		FwFreeArray(aAreaSX1)
		FwFreeArray(aAreaAtual)
	EndIf
Return lOk

/*/{Protheus.doc} F890NomCli
Função que retorna nome do cliente (Utilizada no X3_INIBRW do F71_NOMCLI).

@author 	R. Melo
@since 		01/12/2020
@version 	1.0
/*/
Function F890NomCli() As Character

	Local cRet As Character

	cRet := ""

	cRet := Posicione("SA1", 1, FwXFilial("SA1", F71->F71_FILIAL) + F71->(F71_CODCLI + F71_LOJCLI), "A1_NOME")

Return cRet

/*/{Protheus.doc} F890ExeCan
Função que efetua o cancelamento do PIX.

@author		R. Melo
@since 		01/12/2020
@version 	1.0
/*/
Function F890ExeCan(oModel As Object) As Logical
	Local lRet     As Logical
	Local cFilDoc  As Char
	Local cIdDoc   As Char	
	
	Default oModel := FwModelActive()
	
	//Inicializa variáveis
	lRet       := .T.
	cFilDoc	   := oModel:GetValue("FORMF71", "F71_FILIAL")
	cIdDoc	   := oModel:GetValue("FORMF71", "F71_IDDOC")
	__ExcluiIm := IIf(__ExcluiIm == Nil, FindFunction("ExcluiImpo"),__ExcluiIm)
	
	If (lRet := F890RecPIX(oModel:GetValue("FORMF71", "F71_FILIAL"), oModel:GetValue("FORMF71", "F71_IDDOC")))
		oModel:SetValue("FORMF71", "F71_SOLCAN", "1")
		
		If oModel:GetValue("FORMF71", "F71_STATUS") == "1"
			oModel:SetValue("FORMF71", "F71_STATUS", "7") // Status = Cancelado
		ElseIf __ExcluiIm
			ExcluiImpo(F71->F71_FILIAL, F71->F71_PREFIX, F71->F71_NUM, F71->F71_PARCEL, F71->F71_TIPO, F71->F71_CODCLI, F71->F71_LOJCLI, F71->(Recno()))
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} F890RecPIX
Atualiza o campo FKF_RECPIX para informar que o título não tem mais PIX ativo. 

@author		rafael.riego
@since 		03/06/2022
@param		cFilFKF, character, filial do título
@param		cIdDoc, character, idDoc do título
@return		logical, verdadeiro caso tenha atualizado com sucesso a tabela FKF
/*/
Function F890RecPIX(cFilFKF As Character, cIdDoc As Character) As Logical
	Local aArea			As Array
	Local aAreaFKF		As Array
	Local lFKFCancel	As Logical
	Local oModelFKF		As Object
	Local oModelF71		As Object

	Default cFilFKF	:= F71->F71_FILIAL
	Default cIdDoc	:= F71->F71_IDDOC

	//Inicializa variáveis
	aArea		:= GetArea()
	aAreaFKF	:= FKF->(GetArea())
	lFKFCancel	:= .T.
	
	FKF->(DbSetOrder(1))
	If FKF->(DbSeek(cFilFKF + cIdDoc)) .And. FKF->FKF_RECPIX == "1"
		oModelF71 := FwModelActive()
		oModelFKF := FwLoadModel("FINA986")
		
		oModelFKF:SetOperation(MODEL_OPERATION_UPDATE)
		oModelFKF:Activate()
		oModelFKF:SetValue("FKFMASTER", "FKF_RECPIX", "2")
		
		If (lFKFCancel := oModelFKF:VldData())
			oModelFKF:CommitData()
		EndIf
		
		oModelFKF:DeActivate()
		oModelFKF:Destroy()
		oModelFKF:= Nil
		oModelF71:Activate()
	EndIf

	RestArea(aAreaFKF)
	RestArea(aArea)
	FwFreeArray(aAreaFKF)
	FwFreeArray(aArea)

Return lFKFCancel

/*/{Protheus.doc} F890Cfg
Função que efetua o vínculo da carta de cobrança e configura os parâmetros de cálculo do Valor Pix.
@author R. Melo
@since 03/12/2020
@version 1.0
/*/
Function F890Cfg()

	Local aPars			As Array
	Local cMsgIncPix	As Character
	Local cMsgPadrao	As Character
	Local cMsgCanPix	As Character
	Local cF3Carta		As Character
	Local cCodInc		As Character
	Local cCodExc		As Character
	Local lChkSld		As Logical
	Local lChkVlr		As Logical
	Local lChkImp		As Logical
	Local lGrvSx6		As Logical
	Local nEspLarg		As Numeric
	Local nEspLin		As Numeric
	Local nOpc			As Numeric
	Local oDlg			As Object
	Local oPanel		As Object

	aPars	  := {}
	AAdd(aPars, {"MV_FINPIX1", "C", STR0029, ""}) //"Carta de cobrança a ser enviada na Inclusão do PIX"
	AAdd(aPars, {"MV_FINPIX2", "C", STR0030, ""}) // "Carta de cobrança a ser enviada na Exclusão do PIX"
	AAdd(aPars, {"MV_FINPIX3", "C", STR0031, ""}) // "Mensagem Padrão a ser enviada na Inclusão do PIX"
	AAdd(aPars, {"MV_FINPIX4", "C", STR0033, ""}) //"Regra de cálculo do valor PIX"

	oPanel	  := NIL
	oDlg	  := NIL
	nEspLarg  := 2
	nEspLin	  := 2
	lGrvSx6   := F890CriaSx6(aPars)
	cCodInc	  := PadR(GetMV("MV_FINPIX1"), 006, "")
	cCodExc   := PadR(GetMV("MV_FINPIX2"), 006, "")
	cMsgPadrao:= PadR(GetMV("MV_FINPIX3"), 100, "")
	cMsgIncPix:= Posicione("FWP", 1, FwXFilial("FWP") + cCodInc, "FWP_DESCRI")
	cMsgCanPix:= Posicione("FWP", 1, FwXFilial("FWP") + cCodExc, "FWP_DESCRI")
	cF3Carta  := "FWPP" 
	lChkSld	  := IIf(SubStr(PadR(GetMV("MV_FINPIX4"), 3, ""), 1, 1) == "S", .T., .F.)
	lChkVlr	  := IIf(SubStr(PadR(GetMV("MV_FINPIX4"), 3, ""), 2, 1) == "S", .T., .F.)
	lChkImp	  := IIf(SubStr(PadR(GetMV("MV_FINPIX4"), 3, ""), 3, 1) == "S", .T., .F.)

	DEFINE MSDIALOG oDlg FROM  15,6 TO 424,900 TITLE STR0034 PIXEL //"Configuração PIX"

	oDlg:lMaximized := .F.
	oPanel := TPanel():New(0, 0, "", oDlg,, .T., .T.,,, 20, 20)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 000+nEspLin,  nEspLarg TO 089 + nEspLin, 446 + nEspLarg OF oPanel  PIXEL
	@ 093+nEspLin,  nEspLarg TO 121 + nEspLin, 446 + nEspLarg OF oPanel  PIXEL
	@ 124+nEspLin,  nEspLarg TO 182 + nEspLin, 446 + nEspLarg OF oPanel  PIXEL

	nEspLarg := nEspLarg -1

	//Quadro 1
	@ 03+nEspLin, 009+nEspLarg SAY STR0035 	    SIZE 100, 7 COLORS CLR_BLUE OF oPanel PIXEL  //"Carta de Cobrança"
	@ 16+nEspLin, 009+nEspLarg SAY STR0036 	    SIZE 100, 7 OF oPanel PIXEL  //"Código Layout Inclusão"
	@ 16+nEspLin, 090+nEspLarg SAY STR0037      SIZE 100, 7 OF oPanel PIXEL  //"Descrição"
	@ 40+nEspLin, 009+nEspLarg SAY STR0038 		SIZE 100, 7 OF oPanel PIXEL  //"Código Layout Exclusão"
	@ 40+nEspLin, 090+nEspLarg SAY STR0037      SIZE 100, 7 OF oPanel PIXEL  //"Descrição"
	@ 68+nEspLin, 009+nEspLarg SAY STR0039      SIZE 350, 7 COLORS CLR_RED OF oPanel PIXEL  //"Os campos e filtros da configuração da carta de cobrança"
	@ 25+nEspLin, 009+nEspLarg MSGET cCodInc         			SIZE 050, 10 OF oPanel PIXEL HASBUTTON ;
	Valid F890VCart(cCodInc) Picture "@!" F3 cF3Carta ON CHANGE cMsgIncPix := Posicione("FWP", 1, FwXFilial("FWP") + cCodInc, "FWP_DESCRI")
	@ 25+nEspLin, 090+nEspLarg MSGET cMsgIncPix        			SIZE 350, 10 OF oPanel PIXEL When .F.
	@ 49+nEspLin, 009+nEspLarg MSGET cCodExc         			SIZE 050, 10 OF oPanel PIXEL HASBUTTON ;
	Valid F890VCart(cCodExc) Picture "@!" F3 cF3Carta ON CHANGE cMsgCanPix :=  Posicione("FWP", 1, FwXFilial("FWP") + cCodExc, "FWP_DESCRI")
	@ 49+nEspLin, 090+nEspLarg MSGET cMsgCanPix        			SIZE 350, 10 OF oPanel PIXEL When .F.

	//Quadro 2
	@ 096+nEspLin, 009+nEspLarg SAY STR0031		SIZE 100, 7 OF oPanel PIXEL  //"Mensagem Padrão"
	@ 103+nEspLin, 009+nEspLarg MSGET cMsgPadrao				SIZE 350, 10 OF oPanel PIXEL

	//Quadro 3
	@ 127+nEspLin, 009+nEspLarg SAY STR0040  SIZE 100, 7 COLORS CLR_BLUE OF oPanel PIXEL  //"Parâmetros de Valor PIX"
	@ 142+nEspLin, 009+nEspLarg CHECKBOX oCbx VAR lChkSld PROMPT STR0041  SIZE 140,15 OF oDlg PIXEL //"Saldo de Acréscimo/Decréscimo"
	@ 157+nEspLin, 009+nEspLarg CHECKBOX oCbx VAR lChkVlr PROMPT STR0042  SIZE 140,15 OF oDlg PIXEL //"Valor Acessório (Valores Fixos)"
	@ 172+nEspLin, 009+nEspLarg CHECKBOX oCbx VAR lChkImp PROMPT STR0043  SIZE 140,15 OF oDlg PIXEL //"Impostos"

	DEFINE SBUTTON FROM 188, 385 TYPE 1 ENABLE OF oPanel ACTION (IIf(F890ChkOk(cCodInc, cCodExc, cMsgPadrao, lChkSld, lChkVlr, lChkImp), oDlg:End(), nOpc:=0))
	DEFINE SBUTTON FROM 188, 415 TYPE 2 ENABLE OF oPanel ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/*/{Protheus.doc} F890ChkOk
Função que efetua a gravação do vínculo da carta de cobrança e dos parâmetros de valor PIX.

@author R. Melo
@since 03/12/2020
@version 1.0
/*/
Function F890ChkOk(cCodInc As Character, cCodExc As Character, cMsgPadrao As Character, lChkSld As Logical, lChkVlr As Logical, lChkImp As Logical) As Logical
	Local cRegrVlPix  As Character
	Local lRet		  As Logical
	Local cAgenda     As Character
	Local cPeriodo    As Character
	
	Default cCodInc		:= ""
	Default cCodExc		:= ""
	Default cMsgPadrao	:= ""
	Default lChkSld		:= .F.
	Default lChkVlr		:= .F.
	Default lChkImp		:= .F.
	
	lRet		:= .T.
	cRegrVlPix	:= IIf(lChkSld, "S", "N") + IIf(lChkVlr, "S", "N") + IIf(lChkImp, "S", "N")
	cAgenda     := ""
	cPeriodo    := ""
	
	PutMV("MV_FINPIX1", cCodInc)
	PutMV("MV_FINPIX2", cCodExc)
	PutMV("MV_FINPIX3", cMsgPadrao)
	PutMV("MV_FINPIX4", cRegrVlPix)	
	
	//Somente cria o agendamento do schedule caso o mesmo ainda não exista
	If Empty(FwSchdByFunction("F890SchPix"))
		//Executa a cada 30 minutos
		cPeriod := "D(Each(.T.);Day(1);EveryDay(.T.););Execs(0048);Interval(00:30);"
		cAgenda  := FwInsSchedule("F890SchPix", "000000",, cPeriodo, "00:00", Upper(GetEnvServer()), cEmpAnt + "/" + cFilAnt + ";",SCHD_ACTIVE, Date(), 6,)
	EndIf
	
	If !Empty(cAgenda)
		Help(" ", 1, STR0046,, STR0045, 1, 0) //"Dados registrados com sucesso!"
	EndIf
Return lRet

/*/{Protheus.doc} F890VCart
Função que valida status e existência da carta de cobrança.

@author R. Melo
@since 03/12/2020
@version 1.0
/*/
Function F890VCart(cCod As Character) As Logical
	Local cMsg As Character
	Local lRet As Logical
	
	Default cCod	:= ""
	
	cMsg	:= ""
	lRet	:= .T.
	
	DbSelectArea("FWP")
	FWP->(DbSetOrder(1))
	
	If !Empty(AllTrim(cCod))
		If FWP->(DbSeek(FwXFilial("FWP") + cCod))
			If FWP->FWP_STATUS <> "1"
				cMsg:= STR0047 //"Carta de Cobrança Inativa!"
			EndIf
		Else
			cMsg:= STR0048 //"Código Inexistente!"
		EndIf
		
		If !Empty(cMsg)
			lRet := .F.
			Help(" ", 1, STR0046,, cMsg, 1, 0)//"Aviso"
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} F890CriaSx6
Cria Parâmetos utilizados pela rotina de configuração PIX.

@author R. Melo
@since 08/12/2020
@version 1.0
/*/
Static Function F890CriaSx6(aPars As Array)
	Local aArea		As Array
	Local aAreaX6	As Array
	Local nAtual	As Numeric

	Default aPars := {}
	
	nAtual	:= 0
	aArea	:= GetArea()
	aAreaX6	:= SX6->(GetArea())

	DbSelectArea("SX6")
	SX6->(DbGoTop())
		
	For nAtual := 1 To Len(aPars)
		If !(SX6->(DbSeek(xFilial("FWP")+aPars[nAtual][1])))
			FWSX6Util():ReplicateParam( aPars[nAtual][1] , '*' ,  ,  ) 
		EndIf
	Next nAtual
	
	RestArea(aAreaX6)
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} F890Mail
Função responsável pelo envio de e-mail ao cliente com os títulos PIX em seu nome.

@author		R. Melo
@since 		08/12/2020
@version 	1.0
/*/
Function F890Mail(aProcMail As Array) As Logical
	Local aIncPix		As Array
	Local aExcPix		As Array
	Local aAreaF71		As Array
	Local cPerg			As Character
	Local cMsgRet 		As Character
	Local cQuery 		As Character
	Local cCliSX1 		As Character
	Local cLojaSX1 		As Character
	Local cAliasF71		As Character
	Local dEmisIni	    As Date
	Local dEmisFim	    As Date
	Local dVencIni	    As Date
	Local dVencFim	    As Date
	Local lMaileXC		As Logical
	Local lRet			As Logical
	Local lMailInc		As Logical
	Local nPosFil		As Numeric
	Local nPosCli		As Numeric
	Local nPosLoja		As Numeric
	Local nPosDocs		As Numeric
	Local nOpcCrt		As Numeric
	Local nX			As Numeric
	Local nY			As Numeric

	Private lJob		As Logical

	Default aProcMail := {}

	cPerg		:= "FINA8902"
	cAliasF71	:= GetNextAlias()
	cCliSX1		:= ""
	cLojaSX1	:= ""
	dEmisIni	:= SToD("")
	dEmisFim	:= SToD("")
	dVencIni	:= SToD("")
	dVencFim	:= SToD("")
	aAreaF71    := F71->(GetArea())
	nPosFil		:= 1
	nPosCli		:= 2
	nPosLoja	:= 3
	nPosDocs	:= 4
	nOpcCrt		:= 1
	cMsgRet		:= ""
	lMailInc	:= .F.
	lMaileXC	:= .F.
	nX			:= 0
	nY			:= 0
	lJob		:= Upper(FunName()) == "F890SCHPIX"

	If ValType(aProcMail) <> "A" .or. Len(aProcMail) = 0

		aProcMail := {}

		If !(Pergunte(cPerg, .T.))
			Return .F.
		EndIf

		If MV_PAR01 == 1
			If (F71->F71_STATUS $ '3|4' .And. F71->F71_SOLCAN =  '2') .OR. F71->F71_STATUS == '7'

				If F71->F71_STATUS == '7' .And. !Empty(F71->F71_CODRET)
					cMsgRet :=  STR0050 //"QR Code ainda não gerado!"
					Help(' ', 1,STR0046,,cMsgRet,1,0) //"Aviso"
					Return .F.
				EndIf

				AAdd(aProcMail, {F71->F71_FILIAL, F71->F71_CODCLI, F71->F71_LOJCLI, {F71->F71_IDDOC + F71->F71_SEQ}})
			Else
				If !(F71->F71_STATUS $ '6|7') .And. F71->F71_SOLCAN =  '1'
					cMsgRet:= STR0049 //"Cancelamento solicitado, aguarde o processo para notificar o cliente!"
				ElseIf F71->F71_STATUS $ '1|2'
					cMsgRet:= STR0050 //"Qr Code ainda não gerado!"
				ElseIf F71->F71_STATUS == '5'
					cMsgRet:= STR0051//"Título já pago!"
				ElseIf F71->F71_STATUS == "6" .And. Empty(F71->F71_IDPD)
					cMsgRet:= STR0052 //"Cancelamento enviado ao banco, aguarde o retorno!"
				EndIf
				
				Help(" ", 1, STR0046,, cMsgRet, 1, 0) //"Aviso"
				Return .F.
			EndIf
		Else
			dEmisIni	:= MV_PAR02
			dEmisFim	:= MV_PAR03
			dVencIni	:= MV_PAR04
			dVencFim	:= MV_PAR05
			cCliSX1		:= MV_PAR06
			cLojaSX1	:= MV_PAR07

			cQuery := "SELECT F71_IDDOC,F71_SEQ, R_E_C_N_O_ RECF71 FROM " + RetSQLName("F71")
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += "AND F71_FILIAL = '" + FwXFilial("F71") + "' "
			cQuery += "AND F71_STATUS IN ('3', '4', '7') "
			cQuery += "AND F71_EMVPIX IS NOT NULL "
			cQuery += "AND F71_CODCLI = '" + cCliSX1 + "' "
			cQuery += "AND F71_LOJCLI = '" + cLojaSX1 + "' "
			cQuery += "AND F71_EMISSA BETWEEN '" + DToS(dEmisIni) + "' AND '" + DToS(dEmisFim) + "' "
			cQuery += "AND F71_VENCTO BETWEEN '" + DToS(dVencIni) + "' AND '" + DToS(dVencFim) + "' "
			cQuery += " ORDER BY F71_CODCLI "
			cQuery := ChangeQuery(cQuery)

			MPSysOpenQuery(cQuery, cAliasF71)

			If (cAliasF71)->(EoF())
				Help(' ', 1,STR0046,,STR0053 ,1,0) //"AVISO" "Não existe registros a serem apresentados"
				Return
			EndIf

			AAdd(aProcMail, {F71->F71_FILIAL, cCliSX1, cLojaSX1, {}})

			While (cAliasF71)->(!EoF())
				AAdd(aProcMail[1][nPosDocs], (cAliasF71)->F71_IDDOC + (cAliasF71)->F71_SEQ)
				(cAliasF71)->(DbSkip())
			EndDo
			
			(cAliasF71)->(DbCloseArea())
		EndIf
	EndIf

	For nX := 1 To Len(aProcMail)
		aIncPix		:= {}
		aExcPix		:= {}

		For nY := 1 To Len(aProcMail[nX][nPosDocs])

			DbSelectArea("F71")
			F71->(DbSetOrder(1))
			If F71->(DbSeek(FwXFilial("F71", aProcMail[nX][1]) + aProcMail[nX][nPosDocs][nY]))
				If F71->F71_STATUS $ "3|4"
					AAdd(aIncPix, aProcMail[nX][nPosDocs][nY])
				ElseIf F71->F71_STATUS == "7"
					AAdd(aExcPix, aProcMail[nX][nPosDocs][nY])
				EndIf
			EndIf
		Next nY

		//Envia E-mail de Inclusões PIX do Cliente
		If Len(aIncPix) > 0
			lMailInc:= F890SndMail(1,aProcMail[nX][nPosFil],aProcMail[nX][nPosCli],aProcMail[nX][nPosLoja],aIncPix)
		EndIf

		//Envia E-mail de Exclusões PIX do Cliente
		If Len(aExcPix) > 0
			lMailExc:= F890SndMail(2,aProcMail[nX][nPosFil],aProcMail[nX][nPosCli],aProcMail[nX][nPosLoja],aExcPix)
		EndIf
	Next nX

	If !lJob .And. !IsInCallStack("FINA200")
		If lMailInc .Or. lMailExc
			lRet := .T.
			Help(' ', 1,STR0046 ,,STR0054  ,1,0) //"Aviso" //"E-mail enviado com sucesso!"
		EndIf
	EndIf

	RestArea(aAreaF71)

Return lRet

/*/{Protheus.doc} F890SndMail
Função responsável pelo envio de e-mail ao cliente com os títulos PIX em seu nome.
@author 	R. Melo
@since 		08/12/2020
@version	1.0
/*/
Static Function F890SndMail(nOpCrt As Numeric, cFilCli As Character, cCodCli As Character, cLojaCli As Character, aIdDocs As Array) As Logical
	Local cCodInc       As Character
	Local cCodExc       As Character
	Local cMsgPadrao    As Character
	Local cCodCarta     As Character
	Local cServer		As Character
	Local cUser			As Character
	Local cPass			As Character
	Local cFrom			As Character
	Local cError		As Character
	Local cTo			As Character
	Local cRecPix    	As Character
	Local cHtml			As Character
	Local cSaudacao     As Character
	Local cCorpoCrt     As Character
	Local cConcluCrt    As Character
	Local cAttach       As Character
	Local cTpEnvio      As Character
	Local lConexao 		As Logical
	Local lEnvio		As Logical
	Local lAuthOk       As Logical
	Local lAutentica	As Logical
	Local nY			As Numeric

	cServer		:= AllTrim(GetMV("MV_RELSERV", 	.F., ""))
	cUser		:= AllTrim(GetMV("MV_RELACNT", 	.F., ""))
	cPass		:= AllTrim(GetMV("MV_RELPSW", 	.F., ""))
	cFrom		:= AllTrim(GetMV("MV_RELFROM",	.F., ""))
	lAutentica	:= GetMV("MV_RELAUTH", .F., .F.)
	cTo			:= ""
	lConexao	:= .F.
	nY			:= 0
	lEnvio		:= .F.
	lAuthOk		:= .F.
	cHtml		:= ""
	cError		:= ""
	cAttach		:= ""
	cCodInc     := SuperGetMV("MV_FINPIX1", .F., "", FwXFilial("FWP", cFilCli))
	cCodExc     := SuperGetMV("MV_FINPIX2", .F., "", FwXFilial("FWP", cFilCli))
	cMsgPadrao  := SuperGetMV("MV_FINPIX3", .F., "", FwXFilial("FWP", cFilCli))
	cRecPix     := "1"
	cCodCarta   := IIf(nOpCrt == 1, cCodInc, cCodExc)

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))

	If SA1->(DbSeek(FwXFilial("SA1", cFilCli) + cCodCli + cLojaCli))
		cRecPix	:= Posicione("AI0", 1, FwXFilial("AI0", cFilCli) + cCodCli + cLojaCli, "AI0_RECPIX")
		cTo		:= AllTrim(Posicione("AI0", 1, FwXFilial("AI0", cFilCli) + cCodCli + cLojaCli, "AI0_EMAPIX"))
	EndIf

	//Se o cliente não recebe pix por e-mail, encerra a função
	If cRecPix $ "1|3"
		Help(" ", 1, STR0046,, STR0067, 1, 0) //"Aviso" /"E-mail não cadastrado no complemento de cliente."
		Return .F.
	EndIf

	DbSelectArea("FWP")
	FWP->(DbSetOrder(1))

	If FWP->(DbSeek(FwXFilial("FWP", cFilCli) + cCodCarta))
		cSaudacao	:= FWP->FWP_TXTSAU
		cCorpoCrt	:= FWP->FWP_TXTCRT
		cConcluCrt	:= FWP->FWP_TXTCON
		cTpEnvio	:= FWP->FWP_ENVIO
	Else
		Help(" ", 1, STR0046,, STR0055, 1, 0) //"Carta de Cobrança não configurada!"
		Return .F.
	EndIf

	cLogMsg := ""

	cHtml := ""
	cHtml += "<html>"
	cHtml += "<head>"
	cHtml += "<style>"
	cHtml += "table#tabela_titulos {"
	cHtml += "border: 1px solid black;"
	cHtml += "border-collapse: collapse;}"
	cHtml += "caption, td, th {"
	cHtml += "border: 1px solid black;"
	cHtml += "font-family:verdana;}"
	cHtml += "td#bloco {"
	cHtml += "border: 0px;}"
	cHtml += "td#valor {"
	cHtml += "text-align: right;}"
	cHtml += "td#data {"
	cHtml += "text-align: center;}"
	cHtml += "</style>"
	cHtml += "</head>"
	cHtml += "<body>"

	//Saudação
	cHtml += '<table style="width:80%">'
	cHtml += "<tr>"
	cHtml += '<td id="bloco">'
	cHtml += cSaudacao
	cHtml += "</td>"
	cHtml += "</tr>"
	cHtml += "</table><br>"
	cHtml += '<table style="width:80%">'
	cHtml += "<tr>"
	cHtml += '<td id="bloco">'
	cHtml += SA1->A1_NOME
	cHtml += "</td>"
	cHtml += "</tr>"

	If !Empty(SA1->A1_ENDCOB) .And. !Empty(SA1->A1_MUNC) .And. !Empty(SA1->A1_CEPC) .And. !Empty(SA1->A1_ESTC) .And. !Empty(SA1->A1_BAIRROC)
		cEndere1 := Capital(AllTrim(SA1->A1_ENDCOB))
		cEndere2 := Capital(AllTrim(SA1->A1_BAIRROC)) + " - " + Capital(AllTrim(SA1->A1_MUNC)) + " - " + SA1->A1_ESTC + " - " + Transform(SA1->A1_CEPC,"@R 99999-999")
	Else
		cEndere1 := Capital(AllTrim(SA1->A1_END))
		cEndere2 := Capital(AllTrim(SA1->A1_BAIRRO)) + " - " + Capital(AllTrim(SA1->A1_MUN)) + " - " + SA1->A1_EST + " - " + Transform(SA1->A1_CEP,"@R 99999-999")
	EndIf

	cHtml += "<tr>"
	cHtml += '<td id="bloco">'
	cHtml += cEndere1
	cHtml += "</td>"
	cHtml += "</tr>"
	cHtml += "<tr>"
	cHtml += '<td id="bloco">'
	cHtml += cEndere2
	cHtml += "</td>"
	cHtml += "</tr>"
	cHtml += "</table><br><br>"

	cLogMsg += SA1->A1_NOME + CRLF + CRLF

	//Corpo da carta
	cHtml += '<table style="width:80%">'
	cHtml += "<tr>"
	cHtml += '<td id="bloco">'
	cHtml += cCorpoCrt
	cHtml += "</td>"
	cHtml += "</tr>"
	cHtml += "</table><br>"

	//Conclusão
	If !Empty(cConcluCrt)
		cHtml += '<table style="width:80%">'
		cHtml += "<tr>"
		cHtml += '<td id="bloco">'
		cHtml += cConcluCrt
		cHtml += "</td>"
		cHtml += "</tr>"
		cHtml += "</table><br>"
	EndIf

	//Mensagem PAdrão
	If !Empty(cConcluCrt)
		cHtml += '<table style="width:80%">'
		cHtml += "<tr>"
		cHtml += '<td id="bloco">'
		cHtml += cMsgPadrao
		cHtml += "</td>"
		cHtml += "</tr>"
		cHtml += "</table>"
	EndIf

	cHtml += "</body>"
	cHtml += "</html>"

	Connect SMTP Server cServer ACCOUNT cUser PASSWORD cPass RESULT lConexao

	If lAutentica
		lAuthOk:= MailAuth(cUser, cPass)
	Else
		lAuthOk:= .T.
	EndIf

	If lAuthOk

		cAttach := FinRPIX(cFilCli, cCodCli, cLojaCli, aIdDocs)

		If File(cAttach)
			Send Mail From cFrom to cTo SubJect STR0056 BODY cHtml ATTACHMENT cAttach RESULT lEnvio //"TITULOS PIX"
			Ferase(cAttach)
		Else
			cError:= STR0057//"Falha na geração do Anexo!"
		EndIf

	EndIf

	If !lAuthOk .OR. !lConexao .OR. !lEnvio
		GET MAIL ERROR cError
	Else
		For nY:= 1 to Len(aIdDocs)

			DbSelectArea("F71")
			F71->(DbSetOrder(1))
			F71->(DbSeek(FwXFilial("F71",cFilCli) + aIdDocs[nY]))

			If F71->F71_STATUS $ "3|4"

				RecLock("F71",.F.)
				If F71->F71_STATUS == "3"
					F71->F71_STATUS := "4"
				EndIf
				F71->F71_DTMAIL := dDatabase
				F71->F71_HRMAIL := Time()
				MsUnLock()

			ElseIf F71->F71_STATUS == "7"

				RecLock("F71",.F.)
				F71->F71_DTMACA := dDatabase
				F71->F71_HRMACA := Time()
				MsUnLock()

			EndIf
		Next

		cMsgRet:= STR0054  + " - " + AllTrim(SA1->A1_NOME) // "E-mail enviado com sucesso! "

	EndIf

	If !Empty(cError)
		cMsgRet:= cError
	EndIf

	If lJob
		FwLogMsg("INFO",, "PIX", FunName(), "", "01", FwNoAccent(cMsgRet), 0, 0, {})
	EndIf

	Disconnect SMTP Server

Return lEnvio

/*/{Protheus.doc} F890SchPix
Job Responsável por monitorar Cnab dos títulos PIX e enviá-los para o cliente via e-mail.

@author		R. Melo
@since 		16/12/2020
@version	1.0
/*/
Function F890SchPix(aEmpFil As Array)
	Local aEmp		As Array
	Local aProcMail As Array
	Local cQuery    As Character
	Local cAliasF71 As Character
	Local cCodCli	As Character
	Local nEmp		As Numeric

	Default aEmpFil	:= {}

	FwLogMsg("INFO",, "PIX", "F890SchPix", "", "01", FwNoAccent(STR0059), 0, 0, {}) //"Iniciando execução Job Envio de E-mail PIX."

	If Empty(aEmpFil)
		FwLogMsg("INFO",, "PIX", "F890SchPix", "", "01", FwNoAccent(STR0066), 0, 0, {}) //"Não existem registros a serem enviados."
		Return
	EndIf

	RpcSetType(3)
	RpcSetEnv(aEmpFil[1], aEmpFil[2],,, "FIN", FunName(), {"F71", "FKF", "SA1", "SF2"})

	aEmp      := FwLoadSM0()
	aProcMail := {}
	aEmpPos	  := {}
	cEmp	  := ""
	cQuery    := ""
	cCodCli	  := ""
	nEmp      := 0

	For nEmp:= 1 To Len(aEmp)
		If  !aEmp[nEmp][1] $ cEmp
			AAdd(aEmpPos, {aEmp[nEmp][1], aEmp[nEmp][2]})
			cEmp := cEmp + aEmp[nEmp][1] + "|"
		EndIf
	Next nEmp

	For nEmp:= 1 To Len(aEmpPos)
		RpcSetEnv(aEmpPos[nEmp][1], aEmpPos[nEmp][2], /*cUser*/, /*cPass*/, "FIN", FunName(), {"F71", "FKF", "SA1", "SF2"},,,,.T.)
		SetFunName("F890SchPix")
		cAliasF71 := GetNextAlias()

		cQuery := " SELECT F71_FILIAL, F71_IDDOC, F71_SEQ, F71_CODCLI, F71_LOJCLI, R_E_C_N_O_ RECF71 FROM " + RetSQLName("F71")
		cQuery += "  WHERE D_E_L_E_T_ = ' ' "
		cQuery += "    AND F71_STATUS IN ('3','4','7') "
		cQuery += "    AND F71_EMVPIX IS NOT NULL "
		cQuery += "    AND F71_HRMAIL = ' '  "
		cQuery += "    AND F71_HRMACA = ' '  "
		cQuery += "  ORDER BY F71_FILIAL, F71_CODCLI "
		cQuery := ChangeQuery(cQuery)

		MPSysOpenQuery(cQuery, cAliasF71)

		If (cAliasF71)->(EoF())
			FwLogMsg("INFO",, "PIX", FunName(), "", "01", FwNoAccent(STR0066), 0, 0, {}) //"Não existem registros a serem enviados."
			Return
		EndIf

		While (cAliasF71)->(!EoF())

			If cCodCli <> (cAliasF71)->F71_CODCLI
				AAdd(aProcMail, {(cAliasF71)->F71_FILIAL, (cAliasF71)->F71_CODCLI, (cAliasF71)->F71_LOJCLI, {(cAliasF71)->F71_IDDOC + (cAliasF71)->F71_SEQ}})
			Else
				AAdd(aProcMail[Len(aProcMail)][4], (cAliasF71)->F71_IDDOC + (cAliasF71)->F71_SEQ)
			EndIf

			cCodCli := (cAliasF71)->F71_CODCLI

			(cAliasF71)->(DbSkip())
		EndDo

		(cAliasF71)->(DbCloseArea())
		F890Mail(aProcMail)
		RpcClearEnv()

	Next nEmp

	FwLogMsg("INFO",, "PIX", FunName(), "", "01", FwNoAccent(STR0065), 0, 0, {})//"Encerrando execução Job Envio de E-mail PIX."

Return

/*/{Protheus.doc} VldCanPix
Validar se uma solicitação de cancelamento 
de um título do pix pode ser efetivada. 

@author 	Sivaldo Oliveira
@since 		10/08/2021
@version 	P12
@param 		cStatusF71, character, status do título no pix 
@param 		cSolCanF71, character, status da solicitação de cancelamento
@param 		lPixAPI, logical, verdadeiro caso o título já tenha sido integrado via PIX API
@return 	logical, indica se a solicitação de cancelamento pode ser efetivado 
/*/
Function VldCanPix(cStatusF71 As Character, cSolCanF71 As Character, lPixAPI As Logical) As Logical
	Local cMsg		As Character
	Local lRet		As Logical

    Default cStatusF71 	:= ""
    Default cSolCanF71	:= ""
	Default lPixAPI		:= .F.

	cStatusF71 := AllTrim(cStatusF71)
	cSolCanF71 := AllTrim(cSolCanF71)

    lRet := .F.
    cMsg := ""

	If !Empty(cStatusF71) .And. !Empty(cSolCanF71)
		If cStatusF71 $ "1|2|3|4"
			If !(lRet := (cSolCanF71 != "1"))
				If lPixAPI //PIX API
					cMsg := STR0071 //"Cancelamento já solicitado anteriormente. Aguarde a integração do registro."
				Else
					cMsg := STR0019	//"Cancelamento já solicitado anteriormente. Aguardando geração de arquivo CNAB para envio ao banco"	
				EndIf
			EndIf
		ElseIf cStatusF71 $ "5|6|7|8"
			Do Case
				Case cStatusF71 == "5"
					cMsg := STR0021 //"Pagamento já processado."
				Case cStatusF71 == "6"
					cMsg := STR0022//"Cancelamento já está sendo processado."
				Case cStatusF71 == "7"
					cMsg := STR0023 //"Título já cancelado."
				Case cStatusF71 == "8"
					cMsg := STR0076 //"Pagamento estornado."
			EndCase
		EndIf
	EndIf

	If !lRet .And. !(Empty(cMsg))
		Help(" ", 1, STR0046, Nil, cMsg, 1 ,0)
	EndIf

Return lRet

/*/{Protheus.doc} F890VldMod
Função que valida se o registro pode sofrer alteração ou não.

@author		Rafael Riego
@since		24/08/2021
@param		oModel, object, modelo de dados a ser commitado
@return		logical, verdadeiro caso o registro possa sofrer alteração
/*/
Static Function F890VldMod(oModel As Object) As Logical
	Local lValido	As Logical

	lValido 	:= .T.

	If (__lOpcCanc := oModel:GetOperation() == MODEL_OPERATION_ONLYUPDATE)
		oModel:SetOperation(MODEL_OPERATION_UPDATE) //efetua troca da operação atual para alteração

		//Se cancelamento verifica se o registro pode ser cancelado
		lValido := VldCanPix(F71->F71_STATUS, F71->F71_SOLCAN, !(Empty(F71->F71_IDPD)))
	EndIf

Return lValido

/*/{Protheus.doc} F890Active
Função que valida a ativação do modelo.

@author		Rafael Riego
@since		24/08/2021
@param		oModel, object, modelo de dados a ser commitado
@return		logical, verdadeiro caso a ativação do modelo seja permitida
/*/
Static Function F890Active(oModel As Object)
	Local lActive	As Logical

	lActive		:= .T.
	nOperacao	:= oModel:GetOperation()
	oView		:= FwViewActive()

	//Se cancelamento verifica se o registro pode ser cancelado
	If nOperacao == MODEL_OPERATION_UPDATE .And. __lOpcCanc
		oModel:lModify := .T.
		If oView <> Nil
			oView:lModify := .T.
		EndIf
	EndIf

Return lActive

/*/{Protheus.doc} F890Commit
Função que executa o commit do modelo de dados.

@author		Rafael Riego
@since		24/08/2021
@param		oModel, object, modelo de dados a ser commitado
@return		logical, verdadeiro caso o commit tenha sido realizado com sucesso
/*/
Function F890Commit(oModel As Object) As Logical

	Local lCommit	As Logical
	Local nOperacao	As Numeric

	Default oModel := FwModelActive()

	lCommit 	:= .T.
	nOperacao	:= oModel:GetOperation()

	If nOperacao == MODEL_OPERATION_UPDATE .And. __lOpcCanc
		lCommit := F890ExeCan()
	EndIf

	If lCommit
		lCommit := FwFormCommit(oModel)
	EndIf

Return lCommit
