#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA110.CH"

/*/{Protheus.doc} OFIA110()
Cadastro de Interesses Pecas/Servicos Oficina

@author Andre Luis Almeida
@since 07/01/2019
@version 1.0
@return NIL
/*/
Function OFIA110(_cCodCli,_cLojCli,_cCdPros,_cLjPros)
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
Private cMotivo := "000022" // Tipo de motivo - utilizado na consulta de Motivos de Cancelamentos
Private aDelVDI := {}
Private aDelVDJ := {}
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("VDL")
oBrowse:SetDescription(STR0001) // Oportunidades/Interesses Peças/Serviços Oficina
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
	ADD OPTION aRotina TITLE STR0002 ACTION 'OA1100011_Executar(2)' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'OA1100011_Executar(3)' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'OA1100011_Executar(4)' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0007 ACTION 'OC0600141_FUNIL' OPERATION 2 ACCESS 0 // Funil Interesses
Else
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OFIA110' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.OFIA110' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.OFIA110' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0007+" <F7>"  ACTION 'OC0600141_FUNIL' OPERATION 2 ACCESS 0 // Funil Interesses <F7>
EndIf
ADD OPTION aRotina TITLE STR0006 ACTION 'OA1100101_CriarOrcamento' OPERATION 2 ACCESS 0 // Criar Orçamento
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.OFIA110' OPERATION 8 ACCESS 0 // Imprimir

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
Local oStrVDI := FWFormStruct(1,"VDI")
Local oStrVDJ := FWFormStruct(1,"VDJ")

oStrVDL:SetProperty("VDL_CODOPO", MODEL_FIELD_INIT,{|| GetSXENum("VDL","VDL_CODOPO") })

oStrVDL:SetProperty("VDL_CODCLI", MODEL_FIELD_VALID, {|oModel,y| OA1100041_ValidVDL(oModel,"VDL_CODCLI") })
oStrVDL:SetProperty("VDL_LOJCLI", MODEL_FIELD_VALID, {|oModel,y| OA1100041_ValidVDL(oModel,"VDL_LOJCLI") })
oStrVDL:SetProperty("VDL_CDPROS", MODEL_FIELD_VALID, {|oModel,y| OA1100041_ValidVDL(oModel,"VDL_CDPROS") })
oStrVDL:SetProperty("VDL_LJPROS", MODEL_FIELD_VALID, {|oModel,y| OA1100041_ValidVDL(oModel,"VDL_LJPROS") })

oModel := MPFormModel():New("OFIA110", /* bPre */, {|oModel| OA1100051_TudoOk(oModel) } /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VDLMASTER",/*cOwner*/ , oStrVDL)
oModel:AddGrid( "VDIFILHO" , "VDLMASTER", oStrVDI , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VDIFILHO", {{'VDI_FILIAL','VDL_FILIAL'}, {'VDI_CODOPO','VDL_CODOPO'}}, VDI->(IndexKey(1)) )
oModel:AddGrid( "VDJFILHO" , "VDLMASTER", oStrVDJ , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VDJFILHO", {{'VDJ_FILIAL','VDL_FILIAL'}, {'VDJ_CODOPO','VDL_CODOPO'}}, VDJ->(IndexKey(1)) )

oModel:GetModel("VDLMASTER"):SetDescription(STR0008) // Oportunidade
oModel:GetModel("VDIFILHO"):SetDescription(STR0009) // Interesses Peças Oficina
oModel:GetModel("VDJFILHO"):SetDescription(STR0010) // Interesses Serviços Oficina

oModel:GetModel("VDIFILHO"):SetOptional(.T.)
oModel:GetModel("VDJFILHO"):SetOptional(.T.)

VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI") + __cUserID))
If VAI->VAI_OPIOFP <> "1" // NAO Permitido Pecas
	oModel:GetModel("VDIFILHO"):SetNoDeleteLine(.t.)
	oModel:GetModel("VDIFILHO"):SetNoUpdateLine(.t.)
	oModel:GetModel("VDIFILHO"):SetNoInsertLine(.t.)
EndIf
If VAI->VAI_OPIOFS <> "1" // NAO Permitido Servicos
	oModel:GetModel("VDJFILHO"):SetNoDeleteLine(.t.)
	oModel:GetModel("VDJFILHO"):SetNoUpdateLine(.t.)
	oModel:GetModel("VDJFILHO"):SetNoInsertLine(.t.)
EndIf

oModel:SetDescription(STR0011) // Interesses Peças/Serviços Oficina
//oModel:InstallEvent("OFIA110LOG", /*cOwner*/, MVCLOGEV():New("OFIA110") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("OFIA110EVDEF", /*cOwner*/, OFIA110EVDEF():New() )

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
Local oStrVDI:= FWFormStruct(2,"VDI")
Local oStrVDJ:= FWFormStruct(2,"VDJ")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:SetCloseOnOk({||.T.})

oView:AddField( 'VIEW_VDL', oStrVDL, 'VDLMASTER' )
oView:AddGrid( 'VIEW_VDI' , oStrVDI, 'VDIFILHO' )
oView:AddGrid( 'VIEW_VDJ' , oStrVDJ, 'VDJFILHO' )

If IsInCallStack('OFIA120') // Oportunidades Agrupadas
	If !lIncVDL // Se não incluir VDL deixar os campos com when .f.
		oStrVDL:SetProperty( "*" ,MVC_VIEW_CANCHANGE, .f. )
	EndIf
EndIf

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' , 36)
oView:CreateHorizontalBox('FILHOVDI' , 32)
oView:CreateHorizontalBox('FILHOVDJ' , 32)

oView:SetOwnerView('VIEW_VDL', 'CABEC' )
oView:SetOwnerView('VIEW_VDI', 'FILHOVDI')
oView:SetOwnerView('VIEW_VDJ', 'FILHOVDJ')

Return oView

/*/{Protheus.doc} OA1100011_Executar
	Opções quando acionadas pelo OFIA120 ( Oportunidades Agrupadas )

	@author Andre Luis Almeida
	@since 21/01/2019
/*/
Function OA1100011_Executar(nTp,lRefresh,cFilOrc,cNumOrc)
Local oView := FWViewExec():New()
Local oAuxView
Default lRefresh := .t.
Default cFilOrc  := ""
Default cNumOrc  := ""
//
lIncVDL := .f.
cMotivo := "000022" // Tipo de motivo - utilizado na consulta de Motivos de Cancelamentos
aDelVDI := {}
aDelVDJ := {}
oView:setTitle(STR0011) // Interesses Peças/Serviços Oficina
DbSelectArea("VDL")
// Posiciona no VDL correspondente - Oportunidade
If !Empty(cNumOrc)
	VDI->(DbSetOrder(3))
	If VDI->(DbSeek(xFilial("VDI")+cFilOrc+cNumOrc)) // Pecas Oficina
		VDL->(DbSeek(xFilial("VDL")+VDI->VDI_CODOPO))
	Else
		VDJ->(DbSetOrder(3))
		If VDJ->(DbSeek(xFilial("VDJ")+cFilOrc+cNumOrc)) // Servicos Oficina
			VDL->(DbSeek(xFilial("VDL")+VDJ->VDJ_CODOPO))
		EndIf
		VDJ->(DbSetOrder(1))
	EndIf
	VDI->(DbSetOrder(1))
EndIf
oAuxView := FWLoadView("OFIA110")
oAuxModI := oAuxView:GetModel("VDIFILHO")
oAuxModJ := oAuxView:GetModel("VDJFILHO")
// Fazer filtro nas GRIDs de Peças e Serviços
If !Empty(cNumOrc)
	oAuxModI:SetLoadFilter( { { 'VDI_FILORC', '"'+cFilOrc+'"' } , { 'VDI_NUMORC', '"'+cNumOrc+'"' } } )
	oAuxModJ:SetLoadFilter( { { 'VDJ_FILORC', '"'+cFilOrc+'"' } , { 'VDJ_NUMORC', '"'+cNumOrc+'"' } } )
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

/*/{Protheus.doc} OA1100021_MotivoCancelamento
	Preencher o Motivo do Cancelamento

	@author Andre Luis Almeida
	@since 23/01/2019
/*/
Function OA1100021_MotivoCancelamento( nLine , lDeleta , cTab )
Local cMotCan    := ""
Local nPos       := 0
Local aMotCancel := {}
nPos := aScan(&("aDel"+cTab),{|x| x[1] == nLine })
If lDeleta
	If nPos <= 0
		aAdd(&("aDel"+cTab),{nLine,{}})
		nPos := len(&("aDel"+cTab))
	EndIf
	aMotCancel := OFA210MOT("000022","6","","",.f.) // Filtro da consulta do motivo de Cancelamentos ( 000022 = Oportunidade Peças/Serviços )
	If len(aMotCancel) <= 0
		&("aDel"+cTab)[nPos,2] := {}
	Else
		cMotCan := aMotCancel[1]
		&("aDel"+cTab)[nPos,2] := aClone(aMotCancel)
	EndIf
Else
	If nPos > 0
		&("aDel"+cTab)[nPos,2] := {}
	EndIf
EndIf
Return cMotCan

/*/{Protheus.doc} OA1100031_GravaHistorico
	Grava Historico do Interesse

	@author Andre Luis Almeida
	@since 29/01/2019
/*/
Function OA1100031_GravaHistorico( cTab )
Local cTime    := time()
Local nCntFor  := 0
Local aCpos    := FWFormStruct(3,cTab)
Local cTabHist := IIf(cTab=="VDI","VED","VEE") // Tabela de Historico
DbSelectArea(cTabHist)
RecLock(cTabHist,.t.)
&(cTabHist+"->"+cTabHist+"_FILIAL") := xFilial(cTabHist)
&(cTabHist+"->"+cTabHist+"_CODIGO") := GetSXENum(cTabHist,+cTabHist+"_CODIGO") // Numeracao do Historico (auto-incremento)
ConfirmSX8()
&(cTabHist+"->"+cTabHist+"_DATHIS") := dDataBase // Data do Historico
&(cTabHist+"->"+cTabHist+"_HORHIS") := substr(cTime,1,2)+substr(cTime,4,2) // Hora do Historico
&(cTabHist+"->"+cTabHist+"_USUHIS") := __cUserID // Usuario do Historico
&(cTabHist+"->"+cTabHist+"_CODCLI") := VDL->VDL_CODCLI
&(cTabHist+"->"+cTabHist+"_LOJCLI") := VDL->VDL_LOJCLI
&(cTabHist+"->"+cTabHist+"_CDPROS") := VDL->VDL_CDPROS
&(cTabHist+"->"+cTabHist+"_LJPROS") := VDL->VDL_LJPROS
For nCntFor := 1 to len(aCpos[1])
	If !aCpos[1,nCntFor,14] .and. !aCpos[1,nCntFor,3] $ cTab+"_FILIAL/"+cTab+"_CODIGO/"
		&(cTabHist+"->"+cTabHist+"_"+substr(aCpos[1,nCntFor,3],5)) := &(cTab+"->"+cTab+"_"+substr(aCpos[1,nCntFor,3],5))
	EndIf
Next
MsUnLock()
DbSelectArea(cTab) // Volta para o Alias da Grid de Interesses
Return

/*/{Protheus.doc} OA1100041_ValidVDL
	Valid dos campos do VDL

	@author Andre Luis Almeida
	@since 01/02/2019
/*/
Function OA1100041_ValidVDL(oModel,cRVar)
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
					MsgInfo(STR0012,"OA1100041_ValidVDL") // Este Prospect já foi convertido para Cliente!
					oModel:LoadValue("VDL_CODCLI",SUS->US_CODCLI)
					oModel:LoadValue("VDL_LOJCLI",SUS->US_LOJACLI)
					OA1100041_ValidVDL(oModel,"VDL_CODCLI")
				EndIf
			EndIf
		EndIf
EndCase
Return .t.

/*/{Protheus.doc} OA1100051_TudoOk
	Tudo Ok da VDL

	@author Andre Luis Almeida
	@since 01/02/2019
/*/
Function OA1100051_TudoOk(oModel)
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
			Help(NIL, NIL, "OA1100051_TudoOk", NIL, STR0013+" "+cCod+"-"+cLoj , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0014}) // Código/Loja do Cliente inválido! / Informe um Código/Loja de Cliente válido.
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
				Help(NIL, NIL, "OA1100051_TudoOk", NIL, STR0015+" "+cCod+"-"+cLoj, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016}) // Código/Loja do Prospect inválido! / Informe um Códio/Loja de Prospect válido.
			EndIf
		EndIf
	EndIf
	If !lDig
		Help(NIL, NIL, "OA1100051_TudoOk", NIL, STR0017 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0018}) // Código/Loja do Cliente ou Prospect não informados! / Informe um Códio/Loja de Cliente ou Prospect.
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OA1100061_BatizaNumeracao
	Batiza a Filial/Numeracao do VDI/VDJ ( Interesse Oficina )

	@author Andre Luis Almeida
	@since 04/02/2019
/*/
Function OA1100061_BatizaNumeracao( cTab )
Local cNro := GetSXENum("VDI","VDI_CODINT") // MESMA Numeracao do VDI e VDJ (auto-incremento)
RecLock(cTab,.f.)
	&(cTab+"->"+cTab+"_FILIAL") := xFilial(cTab)
	&(cTab+"->"+cTab+"_CODINT") := cNro
	ConfirmSX8()
MsUnLock()
Return

/*/{Protheus.doc} OA1100071_GravaMotivoCancelamento
	Grava Motivo do Cancelamento

	@author Andre Luis Almeida
	@since 04/02/2019
/*/
Function OA1100071_GravaMotivoCancelamento( nLinha , cTab )
Local nCntFor := 1
Local aAux    := aClone(&("aDel"+cTab))
For nCntFor := 1 to len(aAux)
	If aAux[nCntFor,1] == nLinha // Posicao - Linha na Grid
		OFA210VDT("000022",aAux[nCntFor,2,1],"6",&(cTab+"->"+cTab+"_FILIAL"),&(cTab+"->"+cTab+"_CODOPO")+&(cTab+"->"+cTab+"_CODINT"),aAux[nCntFor,2,4])
	EndIf
Next
Return

/*/{Protheus.doc} OA1100081_ValidFilho
	Validacao dos Campos - Funcao Chamada pelos EVENTOS MVC

	@author Andre Luis Almeida
	@since 06/02/2019
/*/
Function OA1100081_ValidFilho(oSubModel,cId,xValue,xCurrentValue,cTab)
Local cTime := ""
Local lRet  := .t.
Local cAux  := ""
//
Local nPosOld := 0
Local nPosNew := 0
Local aEtapas := {}
//
If cId == cTab+"_CODFAS"
	VDK->(DbSetOrder(1))
	If VDK->(DbSeek(xFilial("VDK")+xValue)) .and. VDK->VDK_TIPFAS == "3" // VERIFICA SE É FASE PECAS/SERVICOS OFICINA
		If VDK->VDK_ATIVO == "0" // VERIFICA SE FASE ESTA ATIVA
			Help(NIL, NIL, "OA1100081_ValidFilho("+cTab+")", NIL, STR0019, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0020}) // Fase de Interesse não esta ativa. / Informar uma Fase de Interesse ativa.
			lRet := .f.
		ElseIf VDK->VDK_AUTFAS == "1" // VERIFICA FASE AUTOMATICA
			Help(NIL, NIL, "OA1100081_ValidFilho("+cTab+")", NIL, STR0021, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0022}) // Fase de Interesse é automática. / Informar uma Fase de Interesse que não seja automática.
			lRet := .f.
		ElseIf !Empty(xCurrentValue) // VERIFICA SEQUENCIA DAS FASES
			cAux := VDK->VDK_SEQUEN // Sequencia da Fase Digitada
			If VDK->(DbSeek(xFilial("VDK")+xCurrentValue)) .and. !Empty(VDK->VDK_SEQUEN)
				If cAux < VDK->VDK_SEQUEN // Somente SEQUENCIA maior ou igual a SEQUENCIA da Fase anterior
					Help(NIL, NIL, "OA1100081_ValidFilho("+cTab+")", NIL, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0024}) // Fase de Interesse não esta na sequencia. / Informar uma Fase de Interesse obedecendo a sequencia das Fases.
					lRet := .f.
				EndIf
			EndIf
		EndIf
	Else
		Help(NIL, NIL, "OA1100081_ValidFilho("+cTab+")", NIL, STR0025, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0026}) // Fase de Interesse inválida. / Informar uma Fase de Interesse válida relacionada a Peças/Serviços Oficina.
		lRet := .f.
	EndIf
	//
	If lRet
		aEtapas := VCM680031_LevantaFasesPorSequenciaEtapa("3") // Levanta as Fases por Sequencia de Etapas - Fases de Peças/Serviços de Oficina
		If !Empty(xCurrentValue)
			nPosOld := aScan(aEtapas, { |x| xCurrentValue $ x[2] }) // Pega a posicao da ETAPA com a Fase gravada no Interesse
		EndIf
		If !Empty(xValue)
			nPosNew := aScan(aEtapas, { |x| xValue        $ x[2] }) // Pega a posicao da ETAPA com a Fase selecionada pela usuario
		EndIf
		If nPosOld == 0 // Nao tinha FASE selecionada
			If nPosNew > 0 // AGORA selecionou Fase - a NOVA Fase necessariamente deve ser da 1ª ETAPA
				If nPosNew <> 1
					Help(NIL, NIL, "OA1100081_ValidFilho("+cTab+")", NIL, STR0025, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0051}) // Fase de Interesse inválida. / Informar uma Fase do Interesse que deve ser da 1ª Etapa do Funil.
					lRet := .f.
				EndIf
			EndIf
		Else // Ja tinha FASE selecionada
			If nPosNew > 0 // Selecionou Fase - a NOVA Fase necessariamente deve ter a mesma ou a próxima ETAPA
				If ( nPosNew - nPosOld ) > 1 // Verifica se esta pulando mais de uma Etapa
					Help(NIL, NIL, "OA1100081_ValidFilho("+cTab+")", NIL, STR0025, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0052}) // Fase de Interesse inválida. / Informar uma Fase do Interesse que deve ser da mesma ou da próxima Etapa do Funil.
					lRet := .f.
				EndIf
			Else // AGORA deixou a Fase em Branco ( nao pode mais )
				Help(NIL, NIL, "OA1100081_ValidFilho("+cTab+")", NIL, STR0025, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0026}) // Fase de Interesse inválida. / Informar uma Fase de Interesse válida relacionada a Peças/Serviços Oficina.
				lRet := .f.
			EndIf
		EndIf
	EndIf
	//
	If lRet
		cTime := time()
		oSubModel:LoadValue(cTab+"_DATFAS",dDataBase)
		oSubModel:LoadValue(cTab+"_HORFAS",substr(cTime,1,2)+substr(cTime,4,2))
	EndIf
EndIf
Return lRet


/*/{Protheus.doc} OA1100091_Browse
	Cores e Filtros do Browse do VDI/VDJ

	@author Andre Luis Almeida
	@since 08/02/2019
/*/
Function OA1100091_Browse(cBrw,cTab)
Local cQuery  := ""
Local cQAlias := "SQLVDK"
Local ni      := 0
Local aCores  := {}
//
// Filtros - Ativos / Não Cancelados / Cancelados
&(cBrw):AddFilter(STR0027,"DTOS("+cTab+"_DATLIM)>='"+dtos(dDataBase)+"'",.f.,.f.,)	// Filtro Adicional - deixa marcar/desmarcar // INTERESSES ATIVOS ( DENTRO DA DATA LIMITE )
&(cBrw):AddFilter(STR0028,"EMPTY("+cTab+"_MOTCAN)",.f.,.f.,)						// Filtro Adicional - deixa marcar/desmarcar // INTERESSES NÃO CANCELADOS
&(cBrw):AddFilter(STR0029,"!EMPTY("+cTab+"_MOTCAN)",.f.,.f.,)						// Filtro Adicional - deixa marcar/desmarcar // INTERESSES CANCELADOS
&(cBrw):AddFilter(STR0030,"!EMPTY("+cTab+"_CODVEN)",.f.,.f.,)						// Filtro Adicional - deixa marcar/desmarcar // INTERESSES COM VENDEDOR
&(cBrw):AddFilter(STR0031,"EMPTY("+cTab+"_CODVEN)",.f.,.f.,)						// Filtro Adicional - deixa marcar/desmarcar // INTERESSES SEM VENDEDOR
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
cQuery += "   AND VDK_TIPFAS='3'"
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
DbSelectArea(cTab)
//
&(cBrw):AddLegend( "EMPTY("+cTab+"_CODFAS)" , "BR_BRANCO" , STR0032 ) // INTERESSES SEM FASE INFORMADA
For ni := 1 to 7
	If !Empty(aCores[ni,2])
		&(cBrw):AddLegend( cTab+"_CODFAS $ '"+aCores[ni,2]+"'" , aCores[ni,1]  , STR0033+" "+substr(aCores[ni,2],2)+" "+IIf(len(aCores[ni,2])<9,aCores[ni,3],"") ) // INTERESSES NA(S) FASE(S):
	EndIf
Next
If !Empty(aCores[8,2])
	&(cBrw):AddLegend( cTab+"_CODFAS $ '"+aCores[8,2]+"'" , aCores[8,1]  , STR0034+" "+substr(aCores[8,2],2)+" "+IIf(len(aCores[8,2])<10,aCores[8,3],"") ) // INTERESSES NA(S) FASE(S) INATIVA(S):
EndIf
If !Empty(aCores[9,2])
	&(cBrw):AddLegend( cTab+"_CODFAS $ '"+aCores[9,2]+"'" , aCores[9,1]  , STR0035+" "+substr(aCores[9,2],2)+" "+IIf(len(aCores[9,2])<10,aCores[9,3],"") ) // INTERESSES NA(S) FASE(S) SEM COR INFORMADA:
EndIf
Return

/*/{Protheus.doc} OA1100101_CriarOrcamento
	Criar Orcamento Oficina Pecas/Servicos

	@author Andre Luis Almeida
	@since 12/02/2019
/*/
Function OA1100101_CriarOrcamento()
Local cQuery   := ""
Local cQAlias  := "SQLVDIVDJ"
Local cTab     := ""
Local nCntFor  := 0
Local aRecNo   := {}
Local cCodVen  := "INICIAL"
Local cOrctos  := STR0036+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Orçamento(s) de Oficina gerado(s) com sucesso!
Local lVendVazio := .f. // Existe Interesse com Vendedor EM BRANCO ?
If !Empty(VDL->VDL_CODCLI+VDL->VDL_LOJCLI)
	For nCntFor := 1 to 2
		If nCntFor == 1
			cTab := "VDI"
		Else
			cTab := "VDJ"
		EndIf
		cQuery := "SELECT "+cTab+"_CODVEN AS CODVEN , R_E_C_N_O_ AS RECNO "
		cQuery += "  FROM "+RetSQLName(cTab)
		cQuery += " WHERE "+cTab+"_FILIAL = '"+xFilial(cTab)+"'"
		cQuery += "   AND "+cTab+"_CODOPO = '"+VDL->VDL_CODOPO+"'"
		cQuery += "   AND "+cTab+"_NUMORC = ' '"
		cQuery += "   AND "+cTab+"_MOTCAN = ' '"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
		While !(cQAlias)->(Eof())
			If !Empty((cQAlias)->( CODVEN ))
				aAdd(aRecNo,{ (cQAlias)->( CODVEN ) , (cQAlias)->( RECNO ) , cTab })
			Else
				lVendVazio := .t. // Existe Interesse com Vendedor EM BRANCO
			EndIf
			(cQAlias)->(dbSkip())
		End
		(cQAlias)->(dbCloseArea())
		DbSelectArea(cTab)
	Next
	If lVendVazio // Existe Interesse com Vendedor EM BRANCO
		If len(aRecNo) == 0
			Help(NIL, NIL, "OA1100101_CriarOrcamento", NIL, STR0037 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0038}) // Interesses sem Vendedor relacionado! / Informe os Vendedores nos Interesses que ainda não geraram Orçamentos.
			Return
		EndIf
		If !MsgYesNo(STR0039,"OA1100101_CriarOrcamento") // Existem Interesses sem Vendedor relacionado. Deseja gerar Orçamento de Oficina apenas para os Vendedores que estão relacionados?
			Return
		EndIf
	Else
		If len(aRecNo) == 0
			Help(NIL, NIL, "OA1100101_CriarOrcamento", NIL, STR0040 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0041}) // Nenhum Interesse que possibilite a criação de Orçamento Oficina! / Informe novos Interesses.
			Return
		EndIf
	EndIf
	aSort(aRecNo,1,,{|x,y| x[1] < y[1] }) // Ordem: Codigo do Vendedor
	For nCntFor := 1 to len(aRecNo)
		If cCodVen <> aRecNo[nCntFor,1]
			cCodVen := aRecNo[nCntFor,1]
			DbSelectArea("VS1")
			RecLock("VS1",.t.)
			VS1->VS1_FILIAL := xFilial("VS1")
			VS1->VS1_NUMORC := GetSXENum("VS1","VS1_NUMORC")
			ConfirmSx8()
			VS1->VS1_TIPORC := "2" // 2=Oficina
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
				OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0001 ) // Grava Data/Hora na Mudança de Status do Orçamento / Oportunidades/Interesses Peças/Serviços Oficina
			EndIf
			cOrctos += VS1->VS1_NUMORC+" - "+STR0042+" "+cCodVen+CHR(13)+CHR(10) // Vendedor:
		EndIf
		cTab := aRecNo[nCntFor,3]
		DbSelectArea(cTab)
		DbGoto(aRecNo[nCntFor,2])
		RecLock(cTab,.f.)
			&(cTab+"->"+cTab+"_FILORC") := VS1->VS1_FILIAL
			&(cTab+"->"+cTab+"_NUMORC") := VS1->VS1_NUMORC
		MsUnLock()
		OA1100031_GravaHistorico( cTab )
	Next
	AVISO(STR0043+" "+xFilial("VS1"), cOrctos , { STR0044 }, 3) // Filial: / OK
Else
	Help(NIL, NIL, "OA1100101_CriarOrcamento", NIL, STR0013 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0014}) // Código/Loja do Cliente inválido! / Informe um Código/Loja de Cliente válido.
EndIf
Return