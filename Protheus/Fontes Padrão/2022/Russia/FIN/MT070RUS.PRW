#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} ML003CTB
Intern class inherited from FWModelEvent.

@author Flavio Lopes

@since 29/03/2017
@version 12/MA3
/*/
Class MT070RUS FROM FWModelEvent
		
	Method new()
	
	Method ModelPosVld()
	
EndClass

Method new()  Class MT070RUS
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld

Model post validation method.

@author Flavio Lopes

@since 29/03/2017
@version 12/MA3
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class MT070RUS
Local lRet as logic
Local oModelSA6 as object
Local aAreaSA6	as array
aAreaSA6	:= SA6->(GetArea())
lRet := .T.

oModelSA6	:= oModel:GetModel('MATA070_SA6')

If INCLUI .OR. ALTERA
	If oModelSA6:GetValue("A6_TYPEACC") == "1" 
		SA6->(GetArea())
		SA6->(DbSetOrder(4))
		If SA6->(DbSeek(xFilial("SA6")+"1")) .AND. SA6->A6_COD <> oModelSA6:GetValue("A6_COD") 
			Help(" ",1,"MATA070RUS002") //The system has already a Main Account.
			lRet := .F.
		EndIf
		RestArea(aAreaSA6)
		If lRet .And. oModelSA6:GetValue("A6_BLOCKED") == "1"
			Help(" ",1,"MATA070RUS008") //It is not possible to block a Main Account or set as main a blocked account.
			lRet := .F.
		Endif
	Endif
	If lRet
		If oModelSA6:GetValue("A6_FOREIGN") == '2'
			If Empty(oModelSA6:GetValue("A6_AGENCIA"))
				Help(" ",2,"MATA070RUS003")//It is mandatory to fill the field Branch Nmb for Russian Bank.
				lRet := .F.
			Else
				F45->(DbSetOrder(1))
				If !F45->(DbSeek(xFilial("F45")+oModelSA6:GetValue("A6_AGENCIA")))
					Help(" ",1,"MATA070RUS004") //Invalid BIK code.
					lRet := .F.
				Endif
			EndIf
		/*Else
			If Empty(oModelSA6:GetValue("A6_MUN"))
				Help(" ",1,"MATA070RUS005")//It is mandatory to fill the field City for foreign bank.                
				lRet := .F.
			Endif
			If lRet .And. Empty(oModelSA6:GetValue("A6_NOME"))
				Help(" ",1,"MATA070RUS006")//It is mandatory to fill the field Name for foreign bank.
				lRet := .F.
			Endif
			If lRet .And. Empty(oModelSA6:GetValue("A6_SWIFT"))
				Help(" ",2,"MATA070RUS007")//It is mandatory to fill the field SWIFT for foreign bank.
				lRet := .F.
			Endif*/
		Endif
	Endif
Endif
Return lRet

//merge branch 12.1.19
// Russia_R5
