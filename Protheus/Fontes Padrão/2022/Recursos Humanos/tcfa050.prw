#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCFA050.CH"

#DEFINE VIEW_RESULT_OK		0
#DEFINE VIEW_RESULT_CANCEL 1

//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA050
Solicitacao de Alteracao cadastral

@author Rogerio Ribeiro da Cruz
@since 02/03/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function TCFA050()
	Local nResult
	Local oModel 
	
	If !PosSRAUser()
		Return 
	EndIf

	Private aHeadRCB:= GetHead()
	Private aColsRCB:= GetCols(aHeadRCB)
	
	FWExecView(STR0001, "TCFA050", MODEL_OPERATION_UPDATE, NIL, {||.T.} )	//"Alteracao cadastral"
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados

@author Rogerio Ribeiro da Cruz
@since 02/03/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local bVisibleFields := GetVisibleFields(aHeadRCB, aColsRCB, .T.)
	Local oStructSRA
	Local oModel	:= MPFormModel():New(	"TCFA050",;
											NIL,;
											NIL,;	 
											{|oMod| CommitData( oMod )})
											
	
	

	oStructSRA := FWFormStruct(1, "SRA", bVisibleFields, .F.)

	oModel:AddFields("TCFA050_SRA", NIL, oStructSRA)
	oModel:AddFields("TCFA050_SRA_BAK", "TCFA050_SRA", oStructSRA)
Return oModel
                                                    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da visualização de dados

@author Rogerio Ribeiro da Cruz
@since 02/03/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local bVisibleFields:= GetVisibleFields(aHeadRCB, aColsRCB, .F.)
	Local oStructSRA := FWFormStruct(2, "SRA", bVisibleFields)
	Local oModel := FWLoadModel("TCFA050")
	Local oView := FWFormView():New()	
	
	SetFields(oStructSRA, aColsRCB)

	oView:SetModel(oModel)
	oView:AddField("TCFA050_SRA", oStructSRA)   
	oView:CreateHorizontalBox("ALL", 100)
	oView:SetOwnerView("TCFA050_SRA", "ALL")
Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} GetCols

@author Rogerio Ribeiro da Cruz
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetCols(aColsRCB)
	Local aRows := {}
	Local nCountRow
	Local nCountCol
	
	Local aHeadRCC:= {}	
	Local aColsRCC:= RCC->( GdMontaCols(@aHeadRCC, NIL, NIL, NIL, NIL, NIL, NIL, "RCC", xFilial("RCC")+"A001") )	
	
	For nCountRow := 1 To Len(aColsRCC)
		Aadd(aRows, {})
		
		For nCountCol := 1 To Len(aColsRCB)
			AAdd(aRows[nCountRow], fTabela("A001", nCountRow, nCountCol+3))			
		Next	
	Next
Return aRows


//-------------------------------------------------------------------
/*/{Protheus.doc} GetHead

@author Rogerio Ribeiro da Cruz
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetHead()
	Local aHeadRCB:= {}
	Local aColsRCB:= RCB->( GdMontaCols(@aHeadRCB, NIL, NIL, NIL, NIL, NIL, NIL, "RCB", xFilial("RCB")+"A001") )
Return aColsRCB



//-------------------------------------------------------------------
/*/{Protheus.doc} GetVisibleFields

@author Rogerio Ribeiro da Cruz
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetVisibleFields(aHeadRCB, aColsRCB, lFilMat)
	Local nCount
	Local bRet
	Local cFields:= ""	
		
	For nCount:= 1 To len(aColsRCB)
		cFields += AllTrim(aColsRCB[nCount, 1]) + "|"
	Next

	If lFilMat	
		If (At("RA_FILIAL", cFields) == 0)
			cFields+= "RA_FILIAL|"
		EndIf 

		If (At("RA_MAT", cFields) == 0)
			cFields+= "RA_MAT|"
		EndIf 		
	EndIf	

	
	bRet:= &("{|cCampo| AllTrim(cCampo)+'|' $ '" + cFields + "'}")
Return bRet



//-------------------------------------------------------------------
/*/{Protheus.doc} SetFields

@author Rogerio Ribeiro da Cruz
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetFields(oStructure, aColsRCB)
	Local nCount
	Local nPos:= 2
	
	For nCount:= 1 To Len(aColsRCB)
		oStructure:SetProperty(AllTrim(aColsRCB[nCount, 1]), MVC_VIEW_CANCHANGE, (aColsRCB[nCount, nPos] == "A") )
	Next		
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CommitData

@author Rogerio Ribeiro da Cruz
@since 02/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CommitData(oMdTCFA050)
	Local nCount
	Local cFieldName	

    Local oModel	 := FWLoadModel("TCFA040")
	Local oModelRH3	 := oModel:GetModel("TCFA040_RH3")
	Local oModelRH4	 := oModel:GetModel("TCFA040_RH4")
	Local oModelSRANew	:= oMdTCFA050:GetModel("TCFA050_SRA")
	Local oModelSRAPrev	:= oMdTCFA050:GetModel("TCFA050_SRA_BAK")	
	Local aFieldsSRA	:= oModelSRANew:GetStruct():GetFields()
		
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()		
	
	oModelRH3:SetValue("RH3_FILIAL", xFilial("RH3", oModelSRANew:GetValue("RA_FILIAL") ) )
	oModelRH3:SetValue("RH3_MAT",    oModelSRANew:GetValue("RA_MAT"))
	oModelRH3:SetValue("RH3_TIPO",   "2")				//1=Simples;2=Alteracao Cadastral
	oModelRH3:SetValue("RH3_STATUS", "4")				//1=Solicitado;2=Atendido;3=Rejeitado;4=Aguardando Efetivacao RH;5=Aguardando Aprovacao RH
	oModelRH3:SetValue("RH3_DTSOLI", dDataBase)	

	oModelRH4:DeleteLine()

	For nCount:= 1 To Len(aFieldsSRA)
		cFieldName:= aFieldsSRA[nCount, MODEL_FIELD_IDFIELD]

		If oModelSRANew:IsFieldUpdated(cFieldName)
			oModelRH4:AddLine()

			oModelRH4:SetValue("RH4_FILIAL", xFilial("RH4", oModelRH3:GetValue("RH3_FILIAL") ) )
			oModelRH4:SetValue("RH4_CODIGO", oModelRH3:GetValue("RH3_CODIGO") )
			oModelRH4:SetValue("RH4_ITEM",   oModelRH4:GetLine())
			oModelRH4:SetValue("RH4_CAMPO",  cFieldName)
			oModelRH4:SetValue("RH4_VALANT", oModelSRAPrev:GetValue(cFieldName) )
			oModelRH4:SetValue("RH4_VALNOV", oModelSRANew:GetValue(cFieldName) )
		EndIf	
	Next	
		
	If oModel:VldData()
		oModel:CommitData()
	Else
		MsgAlert(oModel:GetErrorMessage()[6], STR0002)		//"Atencao!"
	EndIf
Return .T.




//-------------------------------------------------------------------
/*/{Protheus.doc} ViewWebDef
Gera o XML para Web

@author Rogerio Ribeiro da Cruz
@since 29/06/2009
@version 1.0
@protected
/*/
//-------------------------------------------------------------------
Static Function ViewWebDef(nOperation, cPk, cFormMVC)
	Local oView := ViewDef()
Return oView:GetXML2Web(nOperation, cPk, cFormMVC)