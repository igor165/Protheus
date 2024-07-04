#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA202F.CH"
#INCLUDE "PROTHEUS.CH"
Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA202F
SubView de Alterar Revisor de Pré-Fatura

@author Rafael Telles de Macedo
@since 17/02/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA202F(aRetAuto, lAutomato)
Local oFWMVCWindow := Nil
Local oStructNX0   := FWFormStruct(2, 'NX0')
Local oStructNX1   := FWFormStruct(2, 'NX1', {|cCampo| J202FCpo(cCampo, 2)})
Local oModel       := FWLoadModel('JURA202F')
Local oView        := Nil
Local aRet         := {}

Default aRetAuto   := {}
Default lAutomato  := .F.

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( "JURA202F_NX0", oStructNX0, "NX0MASTER" )
oView:AddGrid(  "JURA202F_NX1", oStructNX1, "NX1DETAIL" )

oView:CreateHorizontalBox( "FORMFIELD" , 0,,,, )
oView:CreateHorizontalBox( "FORMFOLDER", 100,,,, )

oView:CreateFolder('FOLDER_01',"FORMFOLDER")

oView:SetOwnerView( "JURA202F_NX0" , "FORMFIELD" )
oView:SetOwnerView( "JURA202F_NX1" , "FORMFOLDER")

oView:AddUserButton( STR0003 , 'FORMFOLDER', { || J202FMarca(oModel, .T., oView) } ) // 'Inverter Marcação'
oView:AddUserButton( STR0002 , 'FORMFOLDER', { || J202FAltRev(oModel) } ) // 'Revisores'

oView:SetNoInsertLine( 'JURA202F_NX1' )
oView:SetNoDeleteLine( 'JURA202F_NX1' )

oView:SetViewProperty ( '*', "GRIDSEEK" )
oView:SetProgressBar(.T.)
oView:EnableControlBar(.T.)
oView:SetCloseOnOk({||.T.})

oFWMVCWindow := FWMVCWindow():New()
oFWMVCWindow:SetView( oView )
oFWMVCWindow:SetUseControlBar(.T.)
oFWMVCWindow:SetCentered( .T. )
oFWMVCWindow:SetPos( 0, 0 )
oFWMVCWindow:SetSize( 550, 900 )
oFWMVCWindow:SetTitle( STR0001 )
Iif(!lAutomato, oFWMVCWindow:Activate(), Nil)

If lAutomato
	oModel:Activate()
	aRet := J202FMarca(oModel, .T., Nil, lAutomato, aRetAuto)
	J202FRevCas(oModel, Nil , aRet[2], lAutomato, aRetAuto)
	If oModel:VldData()
		FwFormCommit(oModel)
	EndIf
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Alterar Revisor de Pré-Fatura

@author Rafael Telles de Macedo
@since 17/02/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNX0 := FWFormStruct(1, 'NX0' )  // Pré-Fatura
Local oStructNX1 := FWFormStruct(1, 'NX1', {|cCampo| J202FCpo(cCampo, 1)})   // Casos da Pré-Fatura
Local oCommit    := JA202FCOMMIT():New()

oModel := MPFormModel():New('JURA202F', /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)

oStructNX1:SetProperty( '*', MODEL_FIELD_NOUPD, .T. )

oStructNX1:SetProperty( 'NX1_TKRET' , MODEL_FIELD_NOUPD, .F. )
oStructNX1:SetProperty( 'NX1_SIGLA' , MODEL_FIELD_NOUPD, .F. )
oStructNX1:SetProperty( 'NX1_CPART' , MODEL_FIELD_NOUPD, .F. )
oStructNX1:SetProperty( 'NX1_DPART' , MODEL_FIELD_NOUPD, .F. )

oModel:AddFields('NX0MASTER', /*cOwner*/ , oStructNX0)
oModel:AddGrid  ('NX1DETAIL', 'NX0MASTER', oStructNX1)

oModel:SetRelation( 'NX1DETAIL', { { 'NX1_FILIAL', "xFilial('NX1')" }, ;
										{ 'NX1_CPREFT', 'NX0_COD' } }, NX1->(IndexKey(1)))

oModel:SetOperation( 4 ) // Alteração

oModel:InstallEvent("JA202FCOMMIT", /*cOwner*/, oCommit)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} J202FAltRev
Rotina para alterar o revisor da pré-fatura.

@author Rafael Telles de Macedo
@since 17/02/16
/*/
//-------------------------------------------------------------------
Function J202FAltRev(oModel, lAutomato, aRetAuto)
Local lRet      := .T.
Local oDlg      := Nil
Local oMainColl := Nil
Local oCodPart  := Nil
Local oDesCPart := Nil
Local oLayer    := FWLayer():new()
Local aRet      := {}
Local lRevis    := .F.
Local lMarca    := .F.
Local cSigla    := ""
Local aCposLGPD     := {}
Local aNoAccLGPD    := {}
Local aDisabLGPD    := {}

Default lAutomato := .F.
Default aRetAuto  := {}

lMarca := Iif(lAutomato, .T., .F.)
aRet   := J202FMarca(oModel, lMarca, Nil, lAutomato, aRetAuto)
lRet   := aRet[1]
lRevis := aRet[2]
cSigla := Iif(lAutomato, aRetAuto[1][1][2], "")

If !lAutomato .And. lRet

	If _lFwPDCanUse .And. FwPDCanUse(.T.)
		aCposLGPD := {"RD0_NOME"}

		aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
		AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})

	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0002 FROM 0, 0 TO 150, 370 PIXEL Style DS_MODALFRAME

	//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
	oLayer:init(oDlg,.F.)

	//Cria as colunas do Layer
	oLayer:addCollumn("MainColl",100,.F.)
	oMainColl := oLayer:GetColPanel( 'MainColl' )

	oDlg:lEscClose := .F.

	oCodPart  := TJurPnlCampo():New(05,10,50 ,24, oMainColl, STR0004, 'RD0_SIGLA',{|| },{|| },,,,'RD0ATV') //'Sigla Revisor'
	oCodPart:SetChange({|| oDesCPart:SetValue(JurGetDados("RD0",9,xFilial("RD0")+oCodPart:GetValue(),"RD0_NOME")) })

	oDesCPart := TJurPnlCampo():New(05,70,110,24, oMainColl, STR0005, 'RD0_NOME' ,{|| },{|| },,,.F.,,,,,,aScan(aNoAccLGPD,"RD0_NOME") > 0) //'Nome Revisor'

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg, {|| Iif(J202FVldRev(oCodPart:GetValue()),(J202FRevCas(oModel, oCodPart:GetValue(), lRevis), oDlg:End()), .F.) },;
			{||oDlg:End()},/*lMsgDel*/,/*aButtons*/, /*nRecno*/, /*calias*/,  /*lMashups*/,  /*lImpCad*/,.F. /*lPadrao*/, /*lHasOk*/ .T. , /*.F.lWalkThru*/ )
Else
	If J202FMarca(oModel, .F.)[1] .And. J202FVldRev(cSigla)
		J202FRevCas(oModel, cSigla, lRevis, lAutomato, aRetAuto)
	EndIf
EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} J202FVldRev(cSigla)
Rotina para validar o campo de Sigla.

@author Luciano Pereira dos Santos
@since 02/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202FVldRev(cSigla)
Local lRet       := .T.
Local cMsg       := ""
Local aValor     := JurGetDados("RD0",9,xFilial("RD0")+cSigla, {"RD0_MSBLQL","RD0_TPJUR","RD0_DTADEM"})

If !Empty(aValor)
	If aValor[1] == "1"
		lRet := .F.
		cMsg := STR0008 //O participante está inativo.
	EndIf

	If lRet .And. aValor[2] != "1"
		lRet := .F.
		cMsg := STR0007 //O participante não pertence a equipe do Jurídico.
	EndIf

	If lRet .And. !Empty(aValor[3])
		lRet := .F.
		cMsg := STR0017 //O participante está demitido.
	EndIf
Else
	lRet := .F.
	cMsg := STR0010 //O participante não foi localizado.
EndIf

If !lRet
	JurMsgErro(cMsg, ,I18N(STR0020, {AllTrim(cSigla)})) //"Verifique o cadastro do participante '#1' ou informe um participante válido."
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J202FRevCas
Rotina para alterar em lote os revisores dos casos da pré-fatura.

@Param  oModel     Modelo da dados de Casos da Pré-fatura
@Param  cSigla     Silga do novo revisor dos casos
@Param  lRevis     .T. Se existe algum caso (parcialmente) revisado
@Param  lAutomato  .T. Automatização da rotina pelo TestCase

@author Luciano Pereira dos Santos
@since 02/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202FRevCas(oModel, cSigla, lRevis, lAutomato, aRetAuto)
Local lRet      := .T.
Local oModelNX1 := oModel:GetModel('NX1DETAIL')
Local nQtd      := oModelNX1:GetQtdLine()
Local nSavLine  := oModelNX1:GetLine()
Local nI        := 0
Local cCaso     := ''
Local cMsgRev   := ''
Local cSigOld   := ''
Local cSituac   := ''

Default lRevis    := .F.
Default lAutomato := .F.

Iif(lRevis, lRevis := IIf(!lAutomato, ApMsgYesNo(STR0011), lRevis := aRetAuto[2]), Nil) //"Deseja alterar o revisor de casos revisados e parcialmente revisados?"

For nI := 1 To nQtd
	If oModelNX1:GetValue('NX1_TKRET', nI)
		cSigOld := oModelNX1:GetValue('NX1_SIGLA', nI)
		cCaso   := oModelNX1:GetValue('NX1_CCASO', nI)
		cSituac := oModelNX1:GetValue('NX1_SITREV', nI)
		If cSituac == '2' .Or. lRevis //Casos não revisados
			oModelNX1:GoLine(nI)
			cSigla := J202FAuto(lAutomato, oModelNX1, nI, aRetAuto, cSigla, 2)
			If oModelNX1:SetValue("NX1_SIGLA", cSigla)
				oModelNX1:LoadValue('NX1_TKRET', .F.)
			EndIf
		Else
			cMsgRev  += I18N(STR0019, {cCaso, AllTrim(cSigOld), JurInfBox("NX1_SITREV", cSituac,'3')}) + CRLF //"Caso '#1', revisor sigla '#2', situação da revisão: '#3'."
		EndIf
	EndIf
Next

If !Empty(cMsgRev)
	cMsgRev := STR0012 + CRLF+ cMsgRev //#Casos não alterados:
	Iif(!lAutomato, JurErrLog(cMsgRev, STR0001), Nil) //#Alterar Revisor
EndIf

oModelNX1:GoLine(nSavLine)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J202FAuto(lAutomato, oModelNX1, nLine, aRetAuto, cSigla, nTipo)
Rotina Para automatizar a maracação e alteração grid e Casos Revisados

@Param  lAutomato  .T. Automatizado pelo caso de teste
@Param  oModelNX1  Modelo da dados de Casos da Pré-fatura
@Param  nLine       Linha do modelo de Dados do caso
@Param  aRetAuto   array com or parametros de automatização
@Param  cSigla     Sigla do participante (retorno deo desvio da rotina)
@Param  nTipo      1 - retorna a automatização da marcação, 2 - rentorna automatização da alteração de revisor

@Return xRet       Ver ver parametro nTipo

@author Luciano Pereira dos Santos
@since 02/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202FAuto(lAutomato, oModelNX1, nLine, aRetAuto, cSigla, nTipo)
Local cClient  := AllTrim(oModelNX1:GetValue('NX1_CCLIEN', nLine))
Local cLoja    := AllTrim(oModelNX1:GetValue('NX1_CLOJA', nLine))
Local cCaso    := AllTrim(oModelNX1:GetValue('NX1_CCASO', nLine))
Local nPos     := 0
Local aRevisor := {{'',''}}
Local xRet     := Nil

Default aRetAuto  := {}
Default cSigla    := ''
Default nTipo     := 0

If Len(aRetAuto) >= 1
	aRevisor := aRetAuto[1]
EndIf

If nTipo == 1 //Validação para marcação
	xRet := Iif(lAutomato, (aScan(aRevisor, {|x| x[1]=='*'.Or.x[1]==cClient+cLoja+cCaso}) > 0), .T.)

ElseIf nTipo == 2 //Sigla do Revisor referente ao Caso
	xRet := Iif((nPos := aScan(aRevisor, {|x| x[1]=='*'.Or.x[1]==cClient+cLoja+cCaso})) > 0, aRevisor[nPos][2], cSigla)

EndIf

Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J202FMarca(oModel, lMark, oView, lAutomato, aRetAuto)
Rotina verificar os casos marcados do grid de revisão.

@Param  oModel     Modelo da dados de Casos da Pré-fatura
@Param  lMark      .T. Des(marca) todos os casos do grid
@Param  oView      Atualiza a view do modelo se for passada por parametro
@Param  lAutomato  .T. Automatizado pelo caso de teste
@Param  aRetAuto   array com a chave dos casos que serão marcados pelo teste Automatizado

@Return aRet[1] .T. Se algum caso foi marcado no grid
		 aRet[2] .T. Se algum dos casos marcados já foi (parcialmente) revisado

@author Luciano Pereira dos Santos
@since 02/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202FMarca(oModel, lMark, oView, lAutomato, aRetAuto)
Local lRet      := .F.
Local lRevis    := .F.
Local aRet      := {lRet, lRevis}
Local oModelNX1 := oModel:GetModel( 'NX1DETAIL' )
Local nQtd      := oModelNX1:GetQtdLine()
Local nSavLine  := oModelNX1:GetLine()
Local nI        := 0

Default lMark     := .F.
Default oView     := Nil
Default lAutomato := .F.
Default aRetAuto  := {}

For nI := 1 To nQtd
	If !lMark
		If oModelNX1:GetValue('NX1_TKRET', nI)
			lRet := .T.
		EndIf
	ElseIf J202FAuto(lAutomato, oModelNX1, nI, aRetAuto, ,1)
		oModelNX1:GoLine(nI)
		lRet := oModelNX1:LoadValue("NX1_TKRET", !(oModelNX1:GetValue("NX1_TKRET")))
	EndIf

	If oModelNX1:GetValue('NX1_SITREV', nI) $ "1|3" //Verifica se algum caso já foi (parcialmente) revisado
		lRevis  := .T.
	EndIf
Next nI

oModelNX1:GoLine(nSavLine)

If !lRet
	JurMsgErro(STR0021, ,STR0006) //#Nenhum caso foi selecionado. ##Selecione um caso para prosseguir com a alteração do revisor.
EndIf

Iif(oView != Nil, oView:Refresh(), Nil)

aRet := {lRet, lRevis}

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JA202FCM
Executa o commit do modelo e a gravação da pré-fatura na fila de sincronização.

@author Cristina Cintra
@since 19/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202FCM(oModel, aHist)
Local lRet    := .T.
Local cCodPre := oModel:GetValue("NX0MASTER", "NX0_COD")
Local cSitPre := oModel:GetValue("NX0MASTER", "NX0_SITUAC")
Local nI      := 0

If cSitPre == "C" //Em Revisão
	J170GRAVA("JURA202E", xFilial("NX0") + cCodPre, "4") //Grava na fila de sincronização a alteração do revisor
EndIf

For nI := 1 to Len(aHist)
	J202HIST("99", cCodPre, aHist[nI][1], aHist[nI][2], "3" )
Next nI

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J202FGetHis(oModel, aHist)
Rotina para gerar os históricos de alteracão de revisor.

@Param oModel Modelo de dados
@Param aHist  Array com o Histórico da alteração de revisor

@author Luciano Pereira dos Santos
@since 02/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202FGetHis(oModel, aHist)
Local lRet      := .T.
Local oModelNX1 := oModel:GetModel("NX1DETAIL")
Local nQtd      := oModelNX1:GetQtdLine()
Local nSavLine  := oModelNX1:GetLine()
Local nI        := 0
Local NX1Recno  := 0
Local cPart     := ''
Local cSigla    := ''
Local cNome     := ''
Local cMsg      := ''

Default aHist   := {}

For nI := 1 To nQtd
	NX1Recno := oModelNX1:GetDataId(nI)
	cPart    := oModelNX1:GetValue('NX1_CPART' , nI)

	NX1->(DbGoto(NX1Recno))
	If !NX1->(EOF()) .And. NX1->NX1_CPART != cPart
		cSigla  := oModelNX1:GetValue('NX1_SIGLA' , nI)
		cNome   := oModelNX1:GetValue('NX1_DPART' , nI)
		cCaso   := oModelNX1:GetValue('NX1_CCASO' , nI)

		cMsg    := STR0015 + CRLF + Alltrim(cSigla) + " - " + cNome + CRLF + STR0016 + " - " + cCaso //'Revisão Delegada:' 'Caso:'

		Aadd(aHist, {cPart, cMsg})

	EndIf

Next nI

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J202FCpo(cCampo)
Função para selecionar os campos do Model e View da tabela NX1

@param cCampo campo da estrutura.
@param nTipo  1= Campos de modelo; 2= Campos da View

@Return .T. para campos que permanencem na estrutura

@author Luciano Pereira dos Santos
@since 25/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202FCpo(cCampo, nTipo)
Local lRet     := .F.
Local cNomeCpo := AllTrim(cCampo)

lRet := (cNomeCpo $ "NX1_TKRET|NX1_CPREFT|NX1_CCLIEN|NX1_CLOJA|NX1_DCLIEN|NX1_CCASO|NX1_DCASO|NX1_CCONTR|NX1_DCONTR"+;
					"|NX1_SIGLA|"+Iif(nTipo==1,"NX1_CPART|","")+"NX1_DPART|NX1_SITREV|NX1_RETREV|NX1_DRETRV|NX1_INSREV")

Return lRet


//-------------------------------------------------------------------
/*/ { Protheus.doc } JA029COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 18/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA202FCOMMIT FROM FWModelEvent
	Data   aHist

	Method New()
	Method BeforeTTS()
	Method InTTS()
	Method Destroy()

End Class

Method New() Class JA202FCOMMIT
	self:aHist := {}
Return

Method BeforeTTS(oModel, cModelId) Class JA202FCOMMIT
	J202FGetHis(oModel, self:aHist)
Return

Method InTTS(oModel, cModelId) Class JA202FCOMMIT
	JA202FCM(oModel, self:aHist)
Return

Method Destroy() Class JA202FCOMMIT
	self:aHist := {}
Return
