#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA681.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA681
Tela de cadastro de Grupo de Despesas

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Function FINA681()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("FLK")
	oBrowse:SetDescription(OemToANSI(STR0001)) //STR0001:Grupo de Despesas
	
	oBrowse:SetMenuDef("FINA681")
	oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do menu da tela de cadastro de Grupo de Despesas

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE OemToANSI(STR0002) ACTION "VIEWDEF.FINA681" OPERATION 2 ACCESS 0 //STR0002:Visualizar
	ADD OPTION aRotina TITLE OemToANSI(STR0003) ACTION "VIEWDEF.FINA681" OPERATION 3 ACCESS 0 //STR0003:Incluir
	ADD OPTION aRotina TITLE OemToANSI(STR0004) ACTION "VIEWDEF.FINA681" OPERATION 4 ACCESS 0 //STR0004:Alterar
	ADD OPTION aRotina TITLE OemToANSI(STR0005) ACTION "VIEWDEF.FINA681" OPERATION 5 ACCESS 0 //STR0005:Excluir
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Model da tela de cadastro de Grupo de Despesas

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruFLK := FWFormStruct(1,"FLK")
	Local oStruFLT := FWFormStruct(1,"FLT")					    
	Local oModel
	Local aRelation := {{'FLT_FILIAL','xFilial("FLT")'},{'FLT_CODIGO','FLK_GRUPO'}}
	Local bFLTLinPRE := {|oModelGrid, nLine, cAction, cField| FLTLINPRE(oModelGrid,nLine,cAction,cField)}
	Local bFLTLinPOS := {|oModelGrid, nLine|FLTLINPOS(oModelGrid,nLine)}
	
	oModel := MPFormModel():New("FINA681",,{|oModel|FN681POSVL(oModel)})		
	oModel:AddFields("FLKMASTER",,oStruFLK)	
	oModel:AddGrid("FLTDETAIL","FLKMASTER",oStruFLT,bFLTLinPRE,bFLTLinPOS)
	
	oStruFLT:SetProperty("FLT_DTINI",MODEL_FIELD_INIT,{||FLTDTINIC(oModel)})
	oStruFLT:SetProperty("FLT_LIMITS",MODEL_FIELD_INIT,{||FLTLIMINIC(oModel,"FLT_LIMITS")})
	oStruFLT:SetProperty("FLT_LIMITP",MODEL_FIELD_INIT,{||FLTLIMINIC(oModel,"FLT_LIMITP")})
	oStruFLT:SetProperty("FLT_LIMM02",MODEL_FIELD_INIT,{||FLTLIMINIC(oModel,"FLT_LIMM02")})
	oStruFLT:SetProperty("FLT_LIMM03",MODEL_FIELD_INIT,{||FLTLIMINIC(oModel,"FLT_LIMM03")})
	
	oModel:GetModel("FLTDETAIL"):SetUniqueLine({"FLT_DTINI"})
	oModel:GetModel("FLTDETAIL"):SetOptional(.T.)
	oModel:GetModel("FLTDETAIL"):SetNoDeleteLine(.T.)
		
	oModel:SetRelation("FLTDETAIL", aRelation, FLT->(IndexKey(1)))
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do view da tela de cadastro de Grupo de Despesas

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel("FINA681")
	Local oStruFLK := FWFormStruct(2,"FLK")
	Local oStruFLT := FWFormStruct(2,"FLT")		
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oStruFLT:RemoveField("FLT_CODIGO")
	oView:AddField("ViewField",oStruFLK,"FLKMASTER")
	oView:AddGrid("ViewGrid",oStruFLT,"FLTDETAIL")
	
	oView:CreateHorizontalBox("ViewFLK",30) 
	oView:CreateHorizontalBox("GridFLT",70)
	oView:SetOwnerView("ViewField","ViewFLK")	 
	oView:SetOwnerView("ViewGrid","GridFLT") 
	
	oView:EnableTitleView("ViewField",OemToANSI(STR0006)) //STR0006:"Informa��es do Grupo de Despesa"
	oView:EnableTitleView("ViewGrid",OemToANSI(STR0007)) //STR0007:"Vig�ncias do Grupo de Despesa"
Return oView

//------------------------------------------------------------
/*/{Protheus.doc} FN681POSVL
Fun��o para validar se ser� obrigat�ria a defini��o de uma
Vig�ncia, conforme o tipo de limite selecionado  

@author Pedro Alencar	
@since 28/10/2013	
@version 11.90 
@param oModel, Modelo de dados  
@return lRet, Se .T. o registro � adicionado, se .F. n�o 
/*/
//------------------------------------------------------------
Static Function FN681POSVL(oModel) 
	Local lRet := .T. 
	Local cTpLimite := oModel:GetModel("FLKMASTER"):GetValue("FLK_LIMITE")
	Local dDataIni :=  oModel:GetModel("FLTDETAIL"):GetValue("FLT_DTINI")
	Local nLimitS := oModel:GetModel("FLTDETAIL"):GetValue("FLT_LIMITS")
	Local nLimitP := oModel:GetModel("FLTDETAIL"):GetValue("FLT_LIMITP")
	Local nLimM02 := oModel:GetModel("FLTDETAIL"):GetValue("FLT_LIMM02")
	Local nLimM03 := oModel:GetModel("FLTDETAIL"):GetValue("FLT_LIMM03")
	local nLinhas := oModel:GetModel("FLTDETAIL"):Length()
	Local nSomaLimites := 0
	
	If AllTrim(cTpLimite) <> "0"
		nSomaLimites := nLimitS + nLimitP + nLimM02 + nLimM03
		If nLinhas = 1 .AND. (Vazio(dDataIni) .OR. nSomaLimites=0)
			Help(,,"FN681POSVL",,OemToANSI(STR0008), 1, 0 )//STR0008: "Defina a data inicial e informe ao menos um valor de Limite."
			lRet := .F.
		Endif 
	Endif
Return lRet

//------------------------------------------------------------
/*/{Protheus.doc} FLTLINPRE
Fun��o para validar se as linhas da Grid poder�o ser alteradas 

@author Pedro Alencar	
@since 28/10/2013	
@version 11.90 
@param oModelGrid, Grid do Modelo de Dados
@param nLine, Linha posicionada na grid
@param cAction, A��o que est� sendo realizada na linha
@param cField, Campo posicionado
@return lRet, Se .T. a linha poder� ser editada, se .F. n�o 
/*/
//------------------------------------------------------------
Static Function FLTLINPRE (oModelGrid,nLine,cAction,cField)
	Local lRet := .T. 
	
	If cAction=="CANSETVALUE" 
		If oModelGrid:IsInserted()
			If nLine < oModelGrid:Length()
				lRet := .F.			
			Endif
		Else
			lRet := .F.
		Endif
	Endif
Return lRet

//------------------------------------------------------------
/*/{Protheus.doc} FLTLINPOS
Fun��o para redefinir a data final da vig�ncia anterior, com 
base na data inicial da nova linha de vig�ncia (Grid) e para
validar se a Data inicial � v�lida, de acordo com as outras
datas j� adicionadas 

@author Pedro Alencar	
@since 28/10/2013	
@version 11.90 
@param oModelGrid, Grid do Modelo de Dados
@return lRet 
/*/
//------------------------------------------------------------
Static Function FLTLINPOS (oModelGrid,nLine)
	Local lRet := .T.
	Local dDTIni := oModelGrid:GetValue("FLT_DTINI")
	Local dDTFimAnt := DaySub(dDTIni, 1)
	Local nLimitS := oModelGrid:GetValue("FLT_LIMITS")
	Local nLimitP := oModelGrid:GetValue("FLT_LIMITP")
	Local nLimM02 := oModelGrid:GetValue("FLT_LIMM02")
	Local nLimM03 := oModelGrid:GetValue("FLT_LIMM03")
	Local nSomaLimites := 0
	Local dDtAnterior 
	Local aSaveLines := FWSaveRows()
	Local lInserido := .F.

	nSomaLimites := nLimitS + nLimitP + nLimM02 + nLimM03
	If Vazio(dDTIni) .OR. nSomaLimites=0	
		Help(,,"FLTLINPOS",,OemToANSI(STR0008), 1, 0 )//STR0008: "Defina a data inicial e informe ao menos um valor de Limite."
		lRet := .F.
	ElseIf oModelGrid:Length() > 1 .AND. nLine = oModelGrid:Length() 
	 	lInserido := oModelGrid:IsInserted()
	 	oModelGrid:GoLine(oModelGrid:Length()-1)
	 	dDtAnterior := oModelGrid:GetValue("FLT_DTINI")
	 	
	 	If DTOS(dDTIni) <= DTOS(dDtAnterior) .AND. lInserido 	
			Help(,,"FLTLINPOS",,OemToANSI(STR0009), 1, 0 )//STR0009: "Informe uma data inicial maior do que a data da �ltima vig�ncia."
			lRet := .F.		
		Else
			oModelGrid:SetValue("FLT_DTFIM", dDTFimAnt)
		Endif	
	Endif	
	
	FWRestRows(aSaveLines)
Return lRet

//------------------------------------------------------------
/*/{Protheus.doc} FLTLIMINIC
Fun��o para pegar os valores iniciais dos limites das novas
linhas da Grid (sempre que adicionar uma linha, os limites 
ser�o iguais aos da vig�ncia anterior)

@author Pedro Alencar	
@since 28/10/2013	
@version 11.90
@param oModel, Modelo de dados
@param cCampo, Campo do qual ser� obtido o valor 
@return nRet, Valor do limite anterior 
/*/
//------------------------------------------------------------
Static Function FLTLIMINIC (oModel, cCampo)
	Local nRet := 0
	Local oModelGrid := oModel:GetModel("FLTDETAIL") 
	
	If oModelGrid:Length() >= 1
		nRet := oModel:GetValue("FLTDETAIL",cCampo)
	Endif
Return nRet

//------------------------------------------------------------
/*/{Protheus.doc} FLTDTINIC
Fun��o para definir o valor inicial da data inicial, caso n�o
seja a primeira linha

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90 
@param oModel, Modelo de dados
@return dRet, Data inicial 
/*/
//------------------------------------------------------------
Static Function FLTDTINIC (oModel)
	Local dRet
	Local oModelGrid := oModel:GetModel("FLTDETAIL")
	
	If oModelGrid:Length() >= 1
		dRet := dDataBase
	Else
		dRet := CTOD("")
	Endif
Return dRet

//------------------------------------------------------------
/*/{Protheus.doc} FN681LIMVL
Fun��o para validar se o tipo de limite pode ser alterado 
(somente pode, se n�o estiver em uso na presta��o de contas)

@author Pedro Alencar	
@since 12/11/2013	
@version 11.90 
@return lRet 
/*/
//------------------------------------------------------------
Function FN681LIMVL()
	Local lRet := .T.
	Local cQuery := ""
	Local cGrupo := ""
	Local oModel := FWModelActive()
	Local nOperation := 0  
	Local aAreaAnt := GetArea()
	
	nOperation := oModel:GetOperation()
	//Se a opera��o no model for Altera��o, verifica se o Grupo de Despesa j� est� em uso na presta��o de contas
	If nOperation = 4 //4 = Alterar 			
		cGrupo := FLK->FLK_GRUPO 
	
		cQuery += "SELECT FLE_GRUPO"
		cQuery += " FROM " + RetSqlName("FLE")  + " FLE"
		cQuery += " WHERE FLE_FILIAL ='" + xFilial("FLE") + "' AND FLE.D_E_L_E_T_ = '' AND FLE_GRUPO = '" + cGrupo + "'"		
		cQuery := ChangeQuery(cQuery)
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"FLETMP",.T.,.T.)
		dbSelectArea("FLETMP")
	
		//Se o Grupo de Despesa j� estiver em uso na FLE, n�o valida
		If FLETMP->(!EOF())
			Help(,,"FN681LIMVL",,OemToANSI(STR0010), 1, 0 )//STR0010: "N�o � poss�vel alterar o Tipo de Limite deste Grupo de Despesa, pois o mesmo j� est� em uso na Presta��o de Contas." 
			lRet := .F.			
		EndIf		
		
		FLETMP->(dbCloseArea())
	EndIf
	
	RestArea(aAreaAnt)
Return lRet  
