#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CTBA031.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Model da tela de Aprovador por Centro de Custo

@author Pedro Alencar	
@since 24/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruCTT := FWFormStruct(1, "CTT", {|cCampo| ValidaCpo(cCampo,"CTT")})
	Local oStruFLP := FWFormStruct(1, "FLP", {|cCampo| ValidaCpo(cCampo,"FLP")}) 					    
	Local oModel
	Local aRelation := {{'FLP_FILIAL','xFilial("FLP")'},{'FLP_CCUSTO','CTT_CUSTO'}}
	
	oModel := MPFormModel():New("CTBA031", ,{ |oModel| CTBA031Pos(oModel)})	
	oModel:AddFields("CTTMASTER",,oStruCTT)
	oModel:AddGrid("FLPDETAIL","CTTMASTER",oStruFLP)
	
	oModel:GetModel("FLPDETAIL"):SetUniqueLine({"FLP_CODAPR"})		
	oModel:SetRelation("FLPDETAIL", aRelation, FLP->(IndexKey(1)))
	
	oModel:SetVldActivate({|oModel| ModelValid(oModel)})
	
	oStruCTT:SetProperty("CTT_DESC01",MODEL_FIELD_WHEN,{||.F.})
	oStruCTT:SetProperty("CTT_DESC02",MODEL_FIELD_WHEN,{||.F.})
	oStruCTT:SetProperty("CTT_DESC03",MODEL_FIELD_WHEN,{||.F.})
	oStruCTT:SetProperty("CTT_DESC04",MODEL_FIELD_WHEN,{||.F.})
	oStruCTT:SetProperty("CTT_DESC05",MODEL_FIELD_WHEN,{||.F.})
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do View da tela de Aprovador por Centro de Custo

@author Pedro Alencar	
@since 24/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel("CTBA031")
	Local oStruCTT := FWFormStruct(2,"CTT", {|cCampo| ValidaCpo(cCampo,"CTT")})
	Local oStruFLP := FWFormStruct(2,"FLP", {|cCampo| ValidaCpo(cCampo,"FLP")})
	Local oView
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("ViewField",oStruCTT,"CTTMASTER")
	oView:AddGrid("ViewGrid",oStruFLP,"FLPDETAIL")
	
	oView:CreateHorizontalBox("ViewCTT",30) 
	oView:CreateHorizontalBox("GridFLP",70)
	oView:SetOwnerView("ViewField","ViewCTT")	 
	oView:SetOwnerView("ViewGrid","GridFLP") 
	
	oView:EnableTitleView("ViewField",OemToANSI(STR0001)) //STR0001:"Centro de Custo"
	oView:EnableTitleView("ViewGrid",OemToANSI(STR0002)) //STR0002:"Aprovadores"
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaCpo
Função para selecionar os campos do Model e View

@author Pedro Alencar	
@since 24/10/2013	
@version 11.90 
/*/
//-------------------------------------------------------------------
Static Function ValidaCpo(cCampo, cAlias)
	Local lRet := .F.
	Local cNomeCpo := ""
	
	cNomeCpo := AllTrim(cCampo)
	If cAlias == "CTT"			
		If cNomeCpo == "CTT_FILIAL" .OR. cNomeCpo == "CTT_CUSTO" .OR. "DESC"$cNomeCpo
			lRet := .T.
		Endif
	ElseIf cAlias == "FLP"
		lRet := .T.
		If cNomeCpo == "FLP_CCUSTO"
			lRet := .F.
		Endif
	Endif
Return lRet

//------------------------------------------------------------------------
/*/{Protheus.doc} ModelValid
Função para validar o Modelo MVC - Somente irá validar se o Centro de Custo
Associado for analítico e não estiver bloqueado. 

@author Pedro Alencar	
@since 24/10/2013	
@version 11.90 
@return lRet, Se .T. o Model poderá ser utilizado, se .F. não 
/*/
//------------------------------------------------------------------------
Static Function ModelValid(oModel)
	Local lRet := .T.
	Local cClasse := AllTrim(CTT->CTT_CLASSE)
	Local cBloq := AllTrim(CTT->CTT_BLOQ)
	
	If cClasse <> '2' 
		lRet := .F.
		Help(,,"ModelValid CTBA031",,OemToANSI(STR0005), 1, 0 ) //STR0005:"Somente centros de custos analíticos podem ter Aprovadores associados."
	ElseIF cBloq == '1'
		lRet := .F.
		Help(,,"ModelValid CTBA031",,OemToANSI(STR0006), 1, 0 ) //STR0006:"Não é possível associar um Aprovador à um Centro de Custo bloqueado."
	Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA31Valid
Função para validar o Aprovador ao relacionar o mesmo à um centro de
Custo

@author Pedro Alencar	
@since 24/10/2013	
@version 11.90 
@return lRet, Se .T. o aprovador é válido, se .F. inválido 
/*/
//-------------------------------------------------------------------
Function CTBA31Valid()
	Local lRet := .T.
	Local cAprovador := ""
	Local cAreaAnt := GetArea()
	Local cIDReserve := ""
	
	cAprovador := M->FLP_CODAPR				
	dbSelectArea("RD0")
	dbSetOrder(1)
	//Se o código informado não estiver cadastrado na tabela de Participantes (RD0), não valida
	if !dbSeek(xFilial("RD0")+cAprovador)
		Help(,,"CTBA31Valid",,OemToANSI(STR0003), 1, 0 ) //STR0003:"Pessoa/Participante não cadastrado." 
		lRet := .F.
	Else 
		cIDReserve := AllTrim(RD0->RD0_IDRESE)  
		If cIDReserve == ""
			Help(,,"CTBA31Valid",,OemToANSI(STR0004), 1, 0 ) //STR0004:"Pessoa/Participante não integrado ao sistema Reserve." 
			lRet := .F.
		Endif
	EndiF 
	
	RestArea(cAreaAnt)
Return lRet

/*/{Protheus.doc} CTBA031Pos
Rotina para validação complementar.
Inserida chamada para atualização dos aprovadores por Centro de Custo no Sistema Reserve.

@author Totvs
@since 25/10/2013
@version P11 R9

@param oModel, objeto, Objeto Model da rotina

@return lógico,Indica se o registro foi validado
/*/
Static Function CTBA031Pos(oModel)
Local lRet			:= .T.
Local nOperation	:= oModel:GetOperation()
Local oModelFLP	:= oModel:GetModel('FLPDETAIL')
Local nX			:= 0
Local aAprov		:= {}
Local cIdReserve	:= ""

For nX := 1 To oModelFLP:Length()
	oModelFLP:GoLine(nX)

	If !oModelFLP:IsDeleted()
		cIdReserve := GetAdvFVal("RD0","RD0_IDRESE",XFilial("RD0")+oModelFLP:GetValue("FLP_CODAPR"))
		Aadd(aAprov,cIdReserve)
	EndIf

Next nX

FINA655(nOperation,aAprov)

Return lRet
