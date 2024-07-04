#include "Protheus.ch"
#include "FWMvcDef.ch"
#include "FINA679.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA679
Tela de cadastro de Tipos de Despesas

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Function FINA679()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("FLG")
	oBrowse:SetDescription(OemToAnsi(STR0005)) //STR0005:"Tipos de Despesas"
	
	oBrowse:SetMenuDef("FINA679")
	oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do menu da tela de cadastro de Tipos de Despesas

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE OemToAnsi(STR0001) ACTION "VIEWDEF.FINA679" OPERATION 2 ACCESS 0 //STR0001:Visualizar
	ADD OPTION aRotina TITLE OemToAnsi(STR0002) ACTION "VIEWDEF.FINA679" OPERATION 3 ACCESS 0 //STR0002:Incluir
	ADD OPTION aRotina TITLE OemToAnsi(STR0003) ACTION "VIEWDEF.FINA679" OPERATION 4 ACCESS 0 //STR0003:Alterar
	ADD OPTION aRotina TITLE OemToAnsi(STR0004) ACTION "VIEWDEF.FINA679" OPERATION 5 ACCESS 0 //STR0004:Excluir	 
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Model da tela de cadastro de Tipos de Despesas

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------	
Static Function ModelDef()
	Local oStruFLG := FWFormStruct(1,"FLG")
	Local oStruFLS := FWFormStruct(1,"FLS")	
	Local oModel
	Local aRelation := {{'FLS_FILIAL','xFilial("FLS")'},{'FLS_CODIGO','FLG_CODIGO'}}
	Local bFLSLinPRE := {|oModelGrid, nLine, cAction, cField| FLSLINPRE(oModelGrid,nLine,cAction,cField)}
	Local bFLSLinPOS := {|oModelGrid, nLine|FLSLINPOS(oModelGrid,nLine)}
	
	oModel := MPFormModel():New("FINA679",,{|oModel|FN679POSVL(oModel)})	
	oModel:AddFields("FLGMASTER",,oStruFLG)
	oModel:AddGrid("FLSDETAIL","FLGMASTER",oStruFLS,bFLSLinPRE,bFLSLinPOS)
	
	oStruFLS:SetProperty("FLS_DTINI",MODEL_FIELD_INIT,{||FLSDTINIC(oModel)}) 
	oStruFLS:SetProperty("FLS_VALUNI",MODEL_FIELD_INIT,{||FLSLIMINIC(oModel,"FLS_VALUNI")})
	oStruFLS:SetProperty("FLS_LIMITS",MODEL_FIELD_INIT,{||FLSLIMINIC(oModel,"FLS_LIMITS")})
	oStruFLS:SetProperty("FLS_LIMITP",MODEL_FIELD_INIT,{||FLSLIMINIC(oModel,"FLS_LIMITP")})
	oStruFLS:SetProperty("FLS_LIMM02",MODEL_FIELD_INIT,{||FLSLIMINIC(oModel,"FLS_LIMM02")})
	oStruFLS:SetProperty("FLS_LIMM03",MODEL_FIELD_INIT,{||FLSLIMINIC(oModel,"FLS_LIMM03")})
	
	oModel:GetModel("FLSDETAIL"):SetUniqueLine({"FLS_DTINI"})
	oModel:GetModel("FLSDETAIL"):SetOptional(.T.)
	oModel:GetModel("FLSDETAIL"):SetNoDeleteLine(.T.)
		
	oModel:SetRelation("FLSDETAIL", aRelation, FLS->(IndexKey(1)))	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do view da tela de cadastro de Tipos de Despesas

@author Pedro Alencar	
@since 21/10/2013	
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel("FINA679")
	Local oStruFLG := FWFormStruct(2,"FLG")
	Local oStruFLS := FWFormStruct(2,"FLS")		
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oStruFLS:RemoveField("FLS_CODIGO")
	oView:AddField("ViewField",oStruFLG,"FLGMASTER")
	oView:AddGrid("ViewGrid",oStruFLS,"FLSDETAIL")
	
	oView:CreateHorizontalBox("ViewFLG",30) 
	oView:CreateHorizontalBox("GridFLS",70)
	oView:SetOwnerView("ViewField","ViewFLG")	 
	oView:SetOwnerView("ViewGrid","GridFLS") 
	
	oView:EnableTitleView("ViewField",OemToANSI(STR0006)) //STR0006:"Informa��es do Tipo de Despesa"
	oView:EnableTitleView("ViewGrid",OemToANSI(STR0007)) //STR0007:"Vig�ncias do Tipo de Despesa"

	// Criar novo botao na barra de botoes
	oView:AddUserButton( STR0012, STR0013, { |oView| FINA679BUT() } )

Return oView

//------------------------------------------------------------
/*/{Protheus.doc} FN679POSVL
Fun��o para validar se ser� obrigat�ria a defini��o de uma
Vig�ncia, conforme o tipo de limite selecionado  

@author Pedro Alencar	
@since 28/10/2013	
@version 11.90 
@param oModel, Modelo de dados
@return lRet, Se .T. o registro � adicionado, se .F. n�o 
/*/
//------------------------------------------------------------
Static Function FN679POSVL(oModel) 
	Local lRet := .T. 
	Local cTpLimite := oModel:GetModel("FLGMASTER"):GetValue("FLG_LIMITE")
	Local dDataIni :=  oModel:GetModel("FLSDETAIL"):GetValue("FLS_DTINI")
	Local nValUni := oModel:GetModel("FLSDETAIL"):GetValue("FLS_VALUNI")
	Local nLimitS := oModel:GetModel("FLSDETAIL"):GetValue("FLS_LIMITS")
	Local nLimitP := oModel:GetModel("FLSDETAIL"):GetValue("FLS_LIMITP")
	Local nLimM02 := oModel:GetModel("FLSDETAIL"):GetValue("FLS_LIMM02")
	Local nLimM03 := oModel:GetModel("FLSDETAIL"):GetValue("FLS_LIMM03")
	local nLinhas := oModel:GetModel("FLSDETAIL"):Length()
	Local nSomaLimites := 0
	
	If AllTrim(cTpLimite) <> "0"
		nSomaLimites := nValUni + nLimitS + nLimitP + nLimM02 + nLimM03
		If nLinhas = 1 .AND. (Vazio(dDataIni) .OR. nSomaLimites=0)
			Help(,,"FN679POSVL",,OemToANSI(STR0008), 1, 0 )//STR0008: "Defina a data inicial e informe ao menos um valor de Limite."
			lRet := .F.
		Endif 
	Endif
Return lRet

//------------------------------------------------------------
/*/{Protheus.doc} FLSLINPRE
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
Static Function FLSLINPRE (oModelGrid,nLine,cAction,cField)
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
/*/{Protheus.doc} FLSLINPOS
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
Static Function FLSLINPOS (oModelGrid,nLine)
	Local lRet := .T.
	Local dDTIni := oModelGrid:GetValue("FLS_DTINI")
	Local dDTFimAnt := DaySub(dDTIni, 1)
	Local nValUni := oModelGrid:GetValue("FLS_VALUNI")
	Local nLimitS := oModelGrid:GetValue("FLS_LIMITS")
	Local nLimitP := oModelGrid:GetValue("FLS_LIMITP")
	Local nLimM02 := oModelGrid:GetValue("FLS_LIMM02")
	Local nLimM03 := oModelGrid:GetValue("FLS_LIMM03")
	Local nSomaLimites := 0
	Local dDtAnterior 
	Local aSaveLines := FWSaveRows()
	Local lInserido := .F.
	
	nSomaLimites := nValUni + nLimitS + nLimitP + nLimM02 + nLimM03
	If Vazio(dDTIni) .OR. nSomaLimites=0	
		Help(,,"FLSLINPOS",,OemToANSI(STR0008), 1, 0 )//STR0008: "Defina a data inicial e informe ao menos um valor de Limite."
		lRet := .F.
	ElseIf oModelGrid:Length() > 1 .AND. nLine = oModelGrid:Length()
	 	lInserido := oModelGrid:IsInserted()
	 	oModelGrid:GoLine(oModelGrid:Length()-1)
	 	dDtAnterior := oModelGrid:GetValue("FLS_DTINI")
	 	
	 	If DTOS(dDTIni) <= DTOS(dDtAnterior) .AND. lInserido	 	
			Help(,,"FLSLINPOS",,OemToANSI(STR0009), 1, 0 )//STR0009: "Informe uma data inicial maior do que a data da �ltima vig�ncia."
			lRet := .F.		
		Else
			oModelGrid:SetValue("FLS_DTFIM", dDTFimAnt)
		Endif	
	Endif	
	
	FWRestRows(aSaveLines)
Return lRet

//------------------------------------------------------------
/*/{Protheus.doc} FLSLIMINIC
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
Static Function FLSLIMINIC (oModel, cCampo)
	Local nRet := 0
	Local oModelGrid := oModel:GetModel("FLSDETAIL") 
	
	If oModelGrid:Length() >= 1
		nRet := oModel:GetValue("FLSDETAIL",cCampo)
	Endif
Return nRet

//------------------------------------------------------------
/*/{Protheus.doc} FLSDTINIC
Fun��o para definir o valor inicial da data inicial, caso n�o
seja a primeira linha

@author Pedro Alencar	
@since 01/11/2013	
@version 11.90 
@param oModel, Modelo de dados
@return dRet, Data inicial 
/*/
//------------------------------------------------------------
Static Function FLSDTINIC (oModel)
	Local dRet
	Local oModelGrid := oModel:GetModel("FLSDETAIL")
	
	If oModelGrid:Length() >= 1
		dRet := dDataBase
	Else
		dRet := CTOD("")
	Endif
Return dRet

//------------------------------------------------------------
/*/{Protheus.doc} FN679LIMVL
Fun��o para validar se o tipo de limite pode ser alterado 
(somente pode, se n�o estiver em uso na presta��o de contas)

@author Pedro Alencar	
@since 12/11/2013	
@version 11.90 
@return lRet 
/*/
//------------------------------------------------------------
Function FN679LIMVL()
	Local lRet := .T.
	Local cQuery := ""
	Local cDespes := ""
	Local oModel := FWModelActive()
	Local nOperation := 0  
	Local aAreaAnt := GetArea()
	
	nOperation := oModel:GetOperation()
	//Se a opera��o no model for Altera��o, verifica se o Tipo de Despesa j� est� em uso na presta��o de contas
	If nOperation = 4 //4 = Alterar 			
		cDespes := FLG->FLG_CODIGO 
	
		cQuery += "SELECT FLE_DESPES"
		cQuery += " FROM " + RetSqlName("FLE")  + " FLE"
		cQuery += " WHERE FLE_FILIAL ='" + xFilial("FLE") + "' AND FLE.D_E_L_E_T_ = '' AND FLE_DESPES = '" + cDespes + "'"		
		cQuery := ChangeQuery(cQuery)
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"FLETMP",.T.,.T.)
		dbSelectArea("FLETMP")
	
		//Se o Tipo de Despesa j� estiver em uso na FLE, n�o valida
		If FLETMP->(!EOF())
			Help(,,"FN679LIMVL",,OemToANSI(STR0010), 1, 0 )//STR0010: "N�o � poss�vel alterar o Tipo de Limite deste Tipo de Despesa, pois o mesmo j� est� em uso na Presta��o de Contas."
			lRet := .F.			
		EndIf		
		
		FLETMP->(dbCloseArea())
	EndIf
	
	RestArea(aAreaAnt)
Return lRet  

//-------------------------------------------------------------------
Static Function FINA679BUT()
Local oModel     := FWModelActive()
Local nOperation := oModel:GetOperation()
Local aArea      := GetArea()
Local aAreaFLG   := FLG->( GetArea() )
Local lOk        := .F.
Local cPerg      := "FINA687"

If nOperation == MODEL_OPERATION_INSERT // Inclusao
	Help( ,, 'DpNaoSalva',, STR0011, 1, 0 )
	lOk := .F.
ElseIf nOperation == MODEL_OPERATION_UPDATE
	//Valida se grupo de despesas relacionado a despesa selecionada possui defini��es de localiza��o, a rotina n�o dever� ser carregada.
	dbSelectArea("FWC")
	dbSetOrder(2)
	dbSeek(xFilial("FWC")+FLG->FLG_CODIGO)

	If Found()
		Pergunte(cPerg,.F.)
		mv_par01 := Val(FWC_CLASS)
		nOperation := 4
		lOk := ( FWExecView(STR0003,'FINA687', nOperation, , { || .T. } ) == 0 )
		lOk := .F.
	Else
		If Pergunte( cPerg , .T. )
			nOperation := 3
			lOk := ( FWExecView(STR0002,'FINA687', nOperation, , { || .T. } ) == 0 )
		EndIf
	EndIf
EndIf

RestArea( aAreaFLG )
RestArea( aArea )

Return lOk