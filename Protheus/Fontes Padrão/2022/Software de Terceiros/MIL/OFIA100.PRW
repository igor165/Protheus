#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA100.CH"

/*/{Protheus.doc} OFIA100()
Cadastro de Interesses Pecas Balcao

@author Andre Luis Almeida
@since 07/01/2019
@version 1.0
@return NIL
/*/
Function OFIA100(_cCodCli,_cLojCli,_cCdPros,_cLjPros)
Local oBrowse
Default _cCodCli := ""
Default _cLojCli := ""
Default _cCdPros := ""
Default _cLjPros := ""
Private cAutCli := _cCodCli // utilizado no Incluir da Rotina MVC
Private cAutLjC := _cLojCli // utilizado no Incluir da Rotina MVC
Private cAutPro := _cCdPros // utilizado no Incluir da Rotina MVC
Private cAutLjP := _cLjPros // utilizado no Incluir da Rotina MVC
Private oModel
Private lIncVDL := .t.
Private cMotivo := "000021" // Tipo de motivo - utilizado na consulta de Motivos de Cancelamentos
Private aDelVDQ := {}
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("VDL")
oBrowse:SetDescription(STR0001) // Oportunidades/Interesses Peças Balcão
If !Empty( _cCodCli + _cLojCli )
	oBrowse:SetFilterDefault("@ VDL_CODCLI = '"+_cCodCli+"' AND VDL_LOJCLI = '"+_cLojCli+"'")
ElseIf !Empty( _cCdPros + _cLjPros )
	oBrowse:SetFilterDefault("@ VDL_CDPROS = '"+_cCdPros+"' AND VDL_LJPROS = '"+_cLjPros+"'")
EndIf
oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 07/01/2019
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}

If IsInCallStack('OFIA120') // Oportunidades Agrupadas
	ADD OPTION aRotina TITLE STR0002 ACTION 'OA1000011_Executar(2)' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'OA1000011_Executar(3)' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'OA1000011_Executar(4)' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0006 ACTION 'OC0500141_FUNIL' OPERATION 2 ACCESS 0 // Funil Interesses
Else
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OFIA100' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.OFIA100' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.OFIA100' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0006+" <F7>"  ACTION 'OC0500141_FUNIL' OPERATION 2 ACCESS 0 // Funil Interesses <F7>
EndIf
ADD OPTION aRotina TITLE STR0007 ACTION 'OA1000101_CriarPedidoOrcamento' OPERATION 2 ACCESS 0 // Criar Pedido de Orçamento
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.OFIA100' OPERATION 8 ACCESS 0 // Imprimir

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 07/01/2019
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVDL := FWFormStruct(1,"VDL")
Local oStrVDQ := FWFormStruct(1,"VDQ")

oStrVDL:SetProperty("VDL_CODOPO", MODEL_FIELD_INIT,{|| GetSXENum("VDL","VDL_CODOPO") })

oStrVDL:SetProperty("VDL_CODCLI", MODEL_FIELD_VALID, {|oModel,y| OA1000041_ValidVDL(oModel,"VDL_CODCLI") })
oStrVDL:SetProperty("VDL_LOJCLI", MODEL_FIELD_VALID, {|oModel,y| OA1000041_ValidVDL(oModel,"VDL_LOJCLI") })
oStrVDL:SetProperty("VDL_CDPROS", MODEL_FIELD_VALID, {|oModel,y| OA1000041_ValidVDL(oModel,"VDL_CDPROS") })
oStrVDL:SetProperty("VDL_LJPROS", MODEL_FIELD_VALID, {|oModel,y| OA1000041_ValidVDL(oModel,"VDL_LJPROS") })

oModel := MPFormModel():New("OFIA100", /* bPre */, {|oModel| OA1000051_TudoOk(oModel) } /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VDLMASTER",/*cOwner*/ , oStrVDL)
oModel:AddGrid( "VDQFILHO" , "VDLMASTER", oStrVDQ , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VDQFILHO", {{'VDQ_FILIAL','VDL_FILIAL'}, {'VDQ_CODOPO','VDL_CODOPO'}}, VDQ->(IndexKey(1)) )

oModel:GetModel("VDLMASTER"):SetDescription(STR0008) // Oportunidade
oModel:GetModel("VDQFILHO"):SetDescription(STR0009) // Interesses Peças Balcão

oModel:GetModel("VDQFILHO"):SetOptional(.T.)

VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI") + __cUserID))
If VAI->VAI_OPIBAL <> "1" // NAO Permitido Pecas
	oModel:GetModel("VDQFILHO"):SetNoDeleteLine(.t.)
	oModel:GetModel("VDQFILHO"):SetNoUpdateLine(.t.)
	oModel:GetModel("VDQFILHO"):SetNoInsertLine(.t.)
EndIf

oModel:SetDescription(STR0009) // Interesses Peças Balcão
//oModel:InstallEvent("OFIA100LOG", /*cOwner*/, MVCLOGEV():New("OFIA100") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("OFIA100EVDEF", /*cOwner*/, OFIA100EVDEF():New() )

oModel:AddRules( 'VDLMASTER', 'VDL_LOJCLI', 'VDLMASTER', 'VDL_CODCLI', 3)
oModel:AddRules( 'VDLMASTER', 'VDL_LJPROS', 'VDLMASTER', 'VDL_CDPROS', 3)

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 07/01/2019
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVDL:= FWFormStruct(2,"VDL")
Local oStrVDQ:= FWFormStruct(2,"VDQ")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:SetCloseOnOk({||.T.})

oView:AddField( 'VIEW_VDL', oStrVDL, 'VDLMASTER' )
oView:AddGrid( 'VIEW_VDQ' , oStrVDQ, 'VDQFILHO' )

If IsInCallStack('OFIA120') // Oportunidades Agrupadas
	If !lIncVDL // Se não incluir VDL deixar os campos com when .f.
		oStrVDL:SetProperty( "*" ,MVC_VIEW_CANCHANGE, .f. )
	EndIf
EndIf

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' , 36)
oView:CreateHorizontalBox('FILHO' , 64)

oView:SetOwnerView('VIEW_VDL', 'CABEC' )
oView:SetOwnerView('VIEW_VDQ', 'FILHO')

Return oView

/*/{Protheus.doc} OA1000011_Executar
	Opções quando acionadas pelo OFIA120 ( Oportunidades Agrupadas )

	@author Andre Luis Almeida
	@since 21/01/2019
/*/
Function OA1000011_Executar(nTp,lRefresh,cFilOrc,cNumOrc)
Local oView := FWViewExec():New()
Local oAuxView
Default lRefresh := .t.
Default cFilOrc  := ""
Default cNumOrc  := ""
//
lIncVDL := .f.
cMotivo := "000021" // Tipo de motivo - utilizado na consulta de Motivos de Cancelamentos
aDelVDQ := {}
oView:setTitle(STR0009)
DbSelectArea("VDL")
// Posiciona no VDL correspondente - Oportunidade
If !Empty(cNumOrc)
	VDQ->(DbSetOrder(3))
	If VDQ->(DbSeek(xFilial("VDQ")+cFilOrc+cNumOrc)) // Pecas Balcao
		VDL->(DbSeek(xFilial("VDL")+VDQ->VDQ_CODOPO))
	EndIf
	VDQ->(DbSetOrder(1))
EndIf
oAuxView := FWLoadView("OFIA100")
oAuxModQ := oAuxView:GetModel("VDQFILHO")
// Fazer filtro nas GRIDs de Peças
If !Empty(cNumOrc)
	oAuxModQ:SetLoadFilter( { { 'VDQ_FILORC', '"'+cFilOrc+'"' } , { 'VDQ_NUMORC', '"'+cNumOrc+'"' } } )
EndIf
oView:SetView(oAuxView)
oView:setModal(.F.)
If nTp == 3 .or. nTp == 4 // Incluir ou Alterar
	oView:setOperation(MODEL_OPERATION_UPDATE)
Else
	oView:setOperation(MODEL_OPERATION_VIEW)
EndIf
oView:openView(.F.)
lIncVDL := .t.
//
If lRefresh
	OA1200061_RefreshBrowse() // Refresh nos Browse's do OFIA120
EndIf
//
Return

/*/{Protheus.doc} OA1000021_MotivoCancelamento
	Preencher o Motivo do Cancelamento

	@author Andre Luis Almeida
	@since 23/01/2019
/*/
Function OA1000021_MotivoCancelamento( nLine , lDeleta )
Local cMotCan    := ""
Local nPos       := 0
Local aMotCancel := {}
nPos := aScan(aDelVDQ,{|x| x[1] == nLine })
If lDeleta
	If nPos <= 0
		aAdd(aDelVDQ,{nLine,{}})
		nPos := len(aDelVDQ)
	EndIf
	aMotCancel := OFA210MOT("000021","6","","",.f.) // Filtro da consulta do motivo de Cancelamentos ( 000021 = Oportunidade )
	If len(aMotCancel) <= 0
		aDelVDQ[nPos,2] := {}
	Else
		cMotCan := aMotCancel[1]
		aDelVDQ[nPos,2] := aClone(aMotCancel)
	EndIf
Else
	If nPos > 0
		aDelVDQ[nPos,2] := {}
	EndIf
EndIf
Return cMotCan

/*/{Protheus.doc} OA1000031_GravaHistorico
	Grava Historico do Interesse

	@author Andre Luis Almeida
	@since 29/01/2019
/*/
Function OA1000031_GravaHistorico()
Local cTime    := time()
Local nCntFor  := 0
Local aCposVDQ := FWFormStruct(3,"VDQ")
DbSelectArea("VDZ")
RecLock("VDZ",.t.)
VDZ->VDZ_FILIAL := xFilial("VDZ")
VDZ->VDZ_CODIGO := GetSXENum("VDZ","VDZ_CODIGO") // Numeracao do Historico (auto-incremento)
ConfirmSX8()
VDZ->VDZ_DATHIS := dDataBase // Data do Historico
VDZ->VDZ_HORHIS := substr(cTime,1,2)+substr(cTime,4,2) // Hora do Historico
VDZ->VDZ_USUHIS := __cUserID // Usuario do Historico
VDZ->VDZ_CODCLI := VDL->VDL_CODCLI
VDZ->VDZ_LOJCLI := VDL->VDL_LOJCLI
VDZ->VDZ_CDPROS := VDL->VDL_CDPROS
VDZ->VDZ_LJPROS := VDL->VDL_LJPROS
For nCntFor := 1 to len(aCposVDQ[1])
	If !aCposVDQ[1,nCntFor,14] .and. !aCposVDQ[1,nCntFor,3] $ "VDQ_FILIAL/VDQ_CODIGO/"
		&("VDZ->VDZ_"+substr(aCposVDQ[1,nCntFor,3],5)) := &("VDQ->"+aCposVDQ[1,nCntFor,3])
	EndIf
Next
MsUnLock()
DbSelectArea("VDQ") // Volta para o Alias da Grid de Interesses
Return

/*/{Protheus.doc} OA1000041_ValidVDL
	Valid dos campos do VDL

	@author Andre Luis Almeida
	@since 01/02/2019
/*/
Function OA1000041_ValidVDL(oModel,cRVar)
Local nRecNo   := 0
Local nTamNome := TamSX3("VDL_NOMCLI")[1]
Do Case
	Case cRVar == "VDL_CODCLI" .or. cRVar == "VDL_LOJCLI"
		M->VDL_CODCLI := oModel:GetValue("VDL_CODCLI")
		M->VDL_LOJCLI := oModel:GetValue("VDL_LOJCLI")
		If !Empty(M->VDL_CODCLI+M->VDL_LOJCLI)
			oModel:LoadValue("VDL_CDPROS",space(TamSX3("VDL_CDPROS")[1]))
			oModel:LoadValue("VDL_LJPROS",space(TamSX3("VDL_LJPROS")[1]))
			nRecNo := FM_SQL("SELECT R_E_C_N_O_ AS RECSA1 FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+M->VDL_CODCLI+"'"+IIf(!Empty(M->VDL_LOJCLI)," AND A1_LOJA='"+M->VDL_LOJCLI+"' ","")+" AND D_E_L_E_T_=' '")
			If nRecNo > 0 // Existe Cliente
				DbSelectArea("SA1")
				DbGoTo(nRecNo)
				oModel:LoadValue("VDL_LOJCLI",SA1->A1_LOJA)
				oModel:LoadValue("VDL_NOMCLI",left(SA1->A1_NOME,nTamNome))
				oModel:LoadValue("VDL_DDDCLI",SA1->A1_DDD)
				oModel:LoadValue("VDL_TELCLI",SA1->A1_TEL)
				oModel:LoadValue("VDL_EMACLI",SA1->A1_EMAIL)
			EndIf
		EndIf
	Case cRVar == "VDL_CDPROS" .or. cRVar == "VDL_LJPROS"
		M->VDL_CDPROS := oModel:GetValue("VDL_CDPROS")
		M->VDL_LJPROS := oModel:GetValue("VDL_LJPROS")
		If !Empty(M->VDL_CDPROS+M->VDL_LJPROS)
			oModel:LoadValue("VDL_CODCLI",space(TamSX3("VDL_CODCLI")[1]))
			oModel:LoadValue("VDL_LOJCLI",space(TamSX3("VDL_LOJCLI")[1]))
			nRecNo := FM_SQL("SELECT R_E_C_N_O_ AS RECSUS FROM "+RetSQLName("SUS")+" WHERE US_FILIAL='"+xFilial("SUS")+"' AND US_COD='"+M->VDL_CDPROS+"'"+IIf(!Empty(M->VDL_LJPROS)," AND US_LOJA='"+M->VDL_LJPROS+"' ","")+" AND D_E_L_E_T_=' '")
			If nRecNo > 0 // Existe Prospect
				DbSelectArea("SUS")
				DbGoTo(nRecNo)
				oModel:LoadValue("VDL_LJPROS",SUS->US_LOJA)
				oModel:LoadValue("VDL_NOMCLI",left(SUS->US_NOME,nTamNome))
				oModel:LoadValue("VDL_DDDCLI",SUS->US_DDD)
				oModel:LoadValue("VDL_TELCLI",SUS->US_TEL)
				oModel:LoadValue("VDL_EMACLI",SUS->US_EMAIL)
				If !Empty(SUS->US_CODCLI+SUS->US_LOJACLI)
					MsgInfo(STR0010,"OA1000041_ValidVDL") // Este Prospect já foi convertido para Cliente!
					oModel:LoadValue("VDL_CODCLI",SUS->US_CODCLI)
					oModel:LoadValue("VDL_LOJCLI",SUS->US_LOJACLI)
					OA1000041_ValidVDL(oModel,"VDL_CODCLI")
				EndIf
			EndIf
		EndIf
EndCase
Return .t.

/*/{Protheus.doc} OA1000051_TudoOk
	Tudo Ok da VDL

	@author Andre Luis Almeida
	@since 01/02/2019
/*/
Function OA1000051_TudoOk(oModel)
Local lRet := .t.
Local lDig := .f.
Local cCod := ""
Local cLoj := ""
If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	lRet := .f.
	cCod := oModel:GetValue("VDLMASTER","VDL_CODCLI")
	cLoj := oModel:GetValue("VDLMASTER","VDL_LOJCLI")
	If !Empty( cCod + cLoj )
		lDig := .t.
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek( xFilial("SA1") + cCod + cLoj ))
			lRet := .t.
		Else
			Help(NIL, NIL, "OA1000051_TudoOk", NIL, STR0011+" "+cCod+"-"+cLoj , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0012}) // Código/Loja do Cliente inválido! / Informe um Código/Loja de Cliente válido.
		EndIf
	EndIf
	If !lRet
		cCod := oModel:GetValue("VDLMASTER","VDL_CDPROS")
		cLoj := oModel:GetValue("VDLMASTER","VDL_LJPROS")
		If !Empty( cCod + cLoj )
			lDig := .t.
			SUS->(DbSetOrder(1))
			If SUS->(DbSeek( xFilial("SUS") + cCod + cLoj ))
				lRet := .t.
			Else
				Help(NIL, NIL, "OA1000051_TudoOk", NIL, STR0013+" "+cCod+"-"+cLoj, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0014}) // Código/Loja do Prospect inválido! / Informe um Códio/Loja de Prospect válido.
			EndIf
		EndIf
	EndIf
	If !lDig
		Help(NIL, NIL, "OA1000051_TudoOk", NIL, STR0015 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016}) // Código/Loja do Cliente ou Prospect não informados! / Informe um Códio/Loja de Cliente ou Prospect.
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OA1000061_BatizaNumeracaoVDQ
	Batiza a Filial/Numeracao do VDQ ( Interesse Balcao )

	@author Andre Luis Almeida
	@since 04/02/2019
/*/
Function OA1000061_BatizaNumeracaoVDQ()
RecLock("VDQ",.f.)
	VDQ->VDQ_FILIAL := xFilial("VDQ")
	VDQ->VDQ_CODINT := GetSXENum("VDQ","VDQ_CODINT") // Numeracao (auto-incremento)
	ConfirmSX8()
MsUnLock()
Return

/*/{Protheus.doc} OA1000071_GravaMotivoCancelamento
	Grava Motivo do Cancelamento

	@author Andre Luis Almeida
	@since 04/02/2019
/*/
Function OA1000071_GravaMotivoCancelamento(nLinha)
Local nCntFor := 1
For nCntFor := 1 to len(aDelVDQ)
	If aDelVDQ[nCntFor,1] == nLinha // Posicao - Linha na Grid
		OFA210VDT("000021",aDelVDQ[nCntFor,2,1],"6",VDQ->VDQ_FILIAL,VDQ->VDQ_CODOPO+VDQ->VDQ_CODINT,aDelVDQ[nCntFor,2,4])
	EndIf
Next
Return

/*/{Protheus.doc} OA1000081_ValidVDQ
	Validacao dos Campos - Funcao Chamada pelos EVENTOS MVC

	@author Andre Luis Almeida
	@since 06/02/2019
/*/
Function OA1000081_ValidVDQ(oSubModel,cId,xValue,xCurrentValue)
Local cTime := ""
Local lRet  := .t.
Local cAux  := ""
//
Local nPosOld := 0
Local nPosNew := 0
Local aEtapas := {}
//
If cId == "VDQ_CODFAS"
	VDK->(DbSetOrder(1))
	If VDK->(DbSeek(xFilial("VDK")+xValue)) .and. VDK->VDK_TIPFAS == "2" // VERIFICA SE É FASE PECAS BALCAO
		If VDK->VDK_ATIVO == "0" // VERIFICA SE FASE ESTA ATIVA
			Help(NIL, NIL, "OA1000081_ValidVDQ", NIL, STR0017, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0018}) // Fase de Interesse não esta ativa. / Informar uma Fase de Interesse ativa.
			lRet := .f.
		ElseIf VDK->VDK_AUTFAS == "1" // VERIFICA FASE AUTOMATICA
			Help(NIL, NIL, "OA1000081_ValidVDQ", NIL, STR0019, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0020}) // Fase de Interesse é automática. / Informar uma Fase de Interesse que não seja automática.
			lRet := .f.
		ElseIf !Empty(xCurrentValue) // VERIFICA SEQUENCIA DAS FASES
			cAux := VDK->VDK_SEQUEN // Sequencia da Fase Digitada
			If VDK->(DbSeek(xFilial("VDK")+xCurrentValue)) .and. !Empty(VDK->VDK_SEQUEN)
				If cAux < VDK->VDK_SEQUEN // Somente SEQUENCIA maior ou igual a SEQUENCIA da Fase anterior
					Help(NIL, NIL, "OA1000081_ValidVDQ", NIL, STR0021, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0022}) // Fase de Interesse não esta na sequencia. / Informar uma Fase de Interesse obedecendo a sequencia das Fases.
					lRet := .f.
				EndIf
			EndIf
		EndIf
	Else
		Help(NIL, NIL, "OA1000081_ValidVDQ", NIL, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0024}) // Fase de Interesse inválida. / Informar uma Fase de Interesse válida relacionada a Peças Balcão.
		lRet := .f.
	EndIf
	//
	If lRet
		aEtapas := VCM680031_LevantaFasesPorSequenciaEtapa("2") // Levanta as Fases por Sequencia de Etapas - Fases de Peças Balcão
		If !Empty(xCurrentValue)
			nPosOld := aScan(aEtapas, { |x| xCurrentValue $ x[2] }) // Pega a posicao da ETAPA com a Fase gravada no Interesse
		EndIf
		If !Empty(xValue)
			nPosNew := aScan(aEtapas, { |x| xValue        $ x[2] }) // Pega a posicao da ETAPA com a Fase selecionada pela usuario
		EndIf
		If nPosOld == 0 // Nao tinha FASE selecionada
			If nPosNew > 0 // AGORA selecionou Fase - a NOVA Fase necessariamente deve ser da 1ª ETAPA
				If nPosNew <> 1
					Help(NIL, NIL, "OA1000081_ValidVDQ", NIL, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0049}) // Fase de Interesse inválida. / Informar uma Fase do Interesse que deve ser da 1ª Etapa do Funil.
					lRet := .f.
				EndIf
			EndIf
		Else // Ja tinha FASE selecionada
			If nPosNew > 0 // Selecionou Fase - a NOVA Fase necessariamente deve ter a mesma ou a próxima ETAPA
				If ( nPosNew - nPosOld ) > 1 // Verifica se esta pulando mais de uma Etapa
					Help(NIL, NIL, "OA1000081_ValidVDQ", NIL, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0050}) // Fase de Interesse inválida. / Informar uma Fase do Interesse que deve ser da mesma ou da próxima Etapa do Funil.
					lRet := .f.
				EndIf
			Else // AGORA deixou a Fase em Branco ( nao pode mais )
				Help(NIL, NIL, "OA1000081_ValidVDQ", NIL, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0024}) // Fase de Interesse inválida. / Informar uma Fase de Interesse válida relacionada a Peças Balcão.
				lRet := .f.
			EndIf
		EndIf
	EndIf
	//
	If lRet
		cTime := time()
		oSubModel:LoadValue("VDQ_DATFAS",dDataBase)
		oSubModel:LoadValue("VDQ_HORFAS",substr(cTime,1,2)+substr(cTime,4,2))
	EndIf
EndIf
Return lRet


/*/{Protheus.doc} OA1000091_BrowseVDQ
	Cores e Filtros do Browse do VDQ

	@author Andre Luis Almeida
	@since 08/02/2019
/*/
Function OA1000091_BrowseVDQ(oBrwVDQ)
Local cQuery  := ""
Local cQAlias := "SQLVDK"
Local ni      := 0
Local aCores  := {}
//
// Filtros - Ativos / Não Cancelados / Cancelados
oBrwVDQ:AddFilter(STR0025,"DTOS(VDQ_DATLIM)>='"+dtos(dDataBase)+"'",.f.,.f.,)	// Filtro Adicional - deixa marcar/desmarcar // INTERESSES ATIVOS ( DENTRO DA DATA LIMITE )
oBrwVDQ:AddFilter(STR0026,"EMPTY(VDQ_MOTCAN)",.f.,.f.,)							// Filtro Adicional - deixa marcar/desmarcar // INTERESSES NÃO CANCELADOS
oBrwVDQ:AddFilter(STR0027,"!EMPTY(VDQ_MOTCAN)",.f.,.f.,)						// Filtro Adicional - deixa marcar/desmarcar // INTERESSES CANCELADOS
oBrwVDQ:AddFilter(STR0028,"!EMPTY(VDQ_CODVEN)",.f.,.f.,)						// Filtro Adicional - deixa marcar/desmarcar // INTERESSES COM VENDEDOR
oBrwVDQ:AddFilter(STR0029,"EMPTY(VDQ_CODVEN)",.f.,.f.,)							// Filtro Adicional - deixa marcar/desmarcar // INTERESSES SEM VENDEDOR
//
aAdd(aCores,{"BR_AMARELO" ,"",""})	// 1
aAdd(aCores,{"BR_VERDE"   ,"",""})	// 2
aAdd(aCores,{"BR_AZUL"    ,"",""})	// 3
aAdd(aCores,{"BR_LARANJA" ,"",""})	// 4
aAdd(aCores,{"BR_VERMELHO","",""})	// 5
aAdd(aCores,{"BR_PINK"    ,"",""})	// 6
aAdd(aCores,{"BR_PRETO"   ,"",""})	// 7
aAdd(aCores,{"BR_MARROM"  ,"",""})	// 8 - FASES INATIVAS
aAdd(aCores,{"BR_CINZA"   ,"",""})	// 9 - FASES SEM COR
//
cQuery := "SELECT VDK_ATIVO , VDK_CORFAS , VDK_CODFAS , VDK_DESFAS "
cQuery += "  FROM "+RetSQLName("VDK")
cQuery += " WHERE VDK_FILIAL='"+xFilial("VDK")+"'"
cQuery += "   AND VDK_TIPFAS='2'"
cQuery += "   AND D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
While !(cQAlias)->(Eof())
	If (cQAlias)->( VDK_ATIVO ) <> "0"
		If !Empty((cQAlias)->( VDK_CORFAS ))
			aCores[val((cQAlias)->( VDK_CORFAS )),2] += ","+(cQAlias)->( VDK_CODFAS )
			aCores[val((cQAlias)->( VDK_CORFAS )),3] := (cQAlias)->( VDK_DESFAS )
		Else
			aCores[9,2] += ","+(cQAlias)->( VDK_CODFAS )
			aCores[9,3] := (cQAlias)->( VDK_DESFAS )
		EndIf
	Else
		aCores[8,2] += ","+(cQAlias)->( VDK_CODFAS )
		aCores[8,3] := (cQAlias)->( VDK_DESFAS )
	EndIf
	(cQAlias)->(dbSkip())
End
(cQAlias)->(dbCloseArea())
DbSelectArea("VDQ")
//
oBrwVDQ:AddLegend( "EMPTY(VDQ_CODFAS)" , "BR_BRANCO" , STR0030 ) // INTERESSES SEM FASE INFORMADA
For ni := 1 to 7
	If !Empty(aCores[ni,2])
		oBrwVDQ:AddLegend( "VDQ_CODFAS $ '"+aCores[ni,2]+"'" , aCores[ni,1]  , STR0031+" "+substr(aCores[ni,2],2)+" "+IIf(len(aCores[ni,2])<9,aCores[ni,3],"") ) // INTERESSES NA(S) FASE(S):
	EndIf
Next
If !Empty(aCores[8,2])
	oBrwVDQ:AddLegend( "VDQ_CODFAS $ '"+aCores[8,2]+"'" , aCores[8,1]  , STR0032+" "+substr(aCores[8,2],2)+" "+IIf(len(aCores[8,2])<10,aCores[8,3],"") ) // INTERESSES NA(S) FASE(S) INATIVA(S):
EndIf
If !Empty(aCores[9,2])
	oBrwVDQ:AddLegend( "VDQ_CODFAS $ '"+aCores[9,2]+"'" , aCores[9,1]  , STR0033+" "+substr(aCores[9,2],2)+" "+IIf(len(aCores[9,2])<10,aCores[9,3],"") ) // INTERESSES NA(S) FASE(S) SEM COR INFORMADA:
EndIf
Return

/*/{Protheus.doc} OA1000101_CriarPedidoOrcamento
	Criar Pedido de Orcamento

	@author Andre Luis Almeida
	@since 12/02/2019
/*/
Function OA1000101_CriarPedidoOrcamento()
Local cQuery   := ""
Local cQAlias  := "SQLVDQ"
Local nCntFor  := 0
Local aRecNo   := {}
Local cCodVen  := "INICIAL"
Local cPedidos := STR0034+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Pedido(s) de Orçamento gerado(s) com sucesso!
Local lVendVazio := .f. // Existe Interesse com Vendedor EM BRANCO ?
If !Empty(VDL->VDL_CODCLI+VDL->VDL_LOJCLI)
	cQuery := "SELECT VDQ_CODVEN , R_E_C_N_O_ AS RECNO "
	cQuery += "  FROM "+RetSQLName("VDQ")
	cQuery += " WHERE VDQ_FILIAL = '"+xFilial("VDQ")+"'"
	cQuery += "   AND VDQ_CODOPO = '"+VDL->VDL_CODOPO+"'"
	cQuery += "   AND VDQ_NUMORC = ' '"
	cQuery += "   AND VDQ_MOTCAN = ' '"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VDQ_CODVEN"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	While !(cQAlias)->(Eof())
		If !Empty((cQAlias)->( VDQ_CODVEN ))
			aAdd(aRecNo,{ (cQAlias)->( VDQ_CODVEN ) , (cQAlias)->( RECNO ) })
		Else
			lVendVazio := .t. // Existe Interesse com Vendedor EM BRANCO
		EndIf
		(cQAlias)->(dbSkip())
	End
	(cQAlias)->(dbCloseArea())
	DbSelectArea("VDQ")
	If lVendVazio // Existe Interesse com Vendedor EM BRANCO
		If len(aRecNo) == 0
			Help(NIL, NIL, "OA1000101_CriarPedidoOrcamento", NIL, STR0035 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0036}) // Interesses sem Vendedor relacionado! / Informe os Vendedores nos Interesses que ainda não geraram Pedidos de Orçamento.
			Return
		EndIf
		If !MsgYesNo(STR0037,"OA1000101_CriarPedidoOrcamento") // Existem Interesses sem Vendedor relacionado. Deseja gerar Pedido de Orçamento apenas para os Vendedores que estão relacionados?
			Return
		EndIf
	Else
		If len(aRecNo) == 0
			Help(NIL, NIL, "OA1000101_CriarPedidoOrcamento", NIL, STR0038 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0039}) // Nenhum Interesse que possibilite a criação de Pedido de Orçamento! / Informe novos Interesses.
			Return
		EndIf
	EndIf
	For nCntFor := 1 to len(aRecNo)
		If cCodVen <> aRecNo[nCntFor,1]
			cCodVen := aRecNo[nCntFor,1]
			DbSelectArea("VS1")
			RecLock("VS1",.t.)
			VS1->VS1_FILIAL := xFilial("VS1")
			VS1->VS1_NUMORC := GetSXENum("VS1","VS1_NUMORC")
			ConfirmSx8()
			VS1->VS1_TIPORC := "P" // P=Pedido de Orcamento
			VS1->VS1_CLIFAT := VDL->VDL_CODCLI
			VS1->VS1_LOJA   := VDL->VDL_LOJCLI
			VS1->VS1_NCLIFT := POSICIONE("SA1",1,xFilial("SA1")+VDL->VDL_CODCLI+VDL->VDL_LOJCLI,"A1_NOME")
			VS1->VS1_TPATEN := "1" // Externo
			VS1->VS1_PEDSTA := "0" // Aberto
			VS1->VS1_DATORC := CriaVar("VS1_DATORC")
			VS1->VS1_HORORC := CriaVar("VS1_HORORC")
			VS1->VS1_DATVAL := CriaVar("VS1_DATVAL")
			VS1->VS1_CODVEN := cCodVen
			VS1->VS1_STATUS := "0"
			VS1->VS1_RESERV := "0"
			VS1->VS1_STARES := "3"
			VS1->VS1_VLBRNF := CriaVar("VS1_VLBRNF")
			VS1->VS1_RESFRE := CriaVar("VS1_RESFRE")
			VS1->VS1_OPORTU := "1" // 0=Nao / 1=Sim
			MsUnLock()
			If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
				OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0001 ) // Grava Data/Hora na Mudança de Status do Orçamento / Oportunidades/Interesses Peças Balcão
			EndIf
			cPedidos += VS1->VS1_NUMORC+" - "+STR0040+" "+cCodVen+CHR(13)+CHR(10) // Vendedor:
		EndIf
		DbSelectArea("VDQ")
		DbGoto(aRecNo[nCntFor,2])
		RecLock("VDQ",.f.)
			VDQ->VDQ_FILORC := VS1->VS1_FILIAL
			VDQ->VDQ_NUMORC := VS1->VS1_NUMORC
		MsUnLock()
		OA1000031_GravaHistorico()
	Next
	AVISO(STR0041+" "+xFilial("VS1"), cPedidos , { STR0042 }, 3) // Filial: / OK
Else
	Help(NIL, NIL, "OA1000101_CriarPedidoOrcamento", NIL, STR0011 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0012}) // Código/Loja do Cliente inválido! / Informe um Código/Loja de Cliente válido.
EndIf
Return
