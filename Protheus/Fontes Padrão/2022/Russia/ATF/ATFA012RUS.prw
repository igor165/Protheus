#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "ATFA012.CH"

#define SN3_OPER_IN_OPERATION       "1"
#define SN3_OPER_NOT_IN_OPERATION   "2"
#define SN3_BAIXA_NOT_WRITTEN_OFF   "0"
#define SN3_BAIXA_WRITTEN_OFF       "1"
#define SN1_STATUS_ACTIVE           "1"
#define SN1_STATUS_INACTIVE         "0"
#define SN1_STATUS_WRITTEN_OFF      "8"
#define SN1_STATUS_CONSERVATION		"5"

#DEFINE SOURCEFATHER "ATFA012"

/*/{Protheus.doc} ATFA012RUS
ATFA012RUS

@author Felipe Morais
@since 28/02/2016
@version P12/MA3 - Russia
/*/
Function ATFA012RUS()
Local oBrowse as Object

Private cCadastro as Character
Private aRotina as ARRAY

aRotina		:= {}
cCadastro := STR0175

SetKey( VK_F12, { || Pergunte("AFA012",.T.) } )

oBrowse := BrowseDef()
oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Felipe Morais
@since 28/02/2016
@version P12/MA3 - Russia
/*/
//-------------------------------------------------------------------

Static Function BrowseDef()
Local oBrowse as Object
oBrowse := FWLoadBrw(SOURCEFATHER)
oBrowse:SetDescription(cCadastro)
Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef definition

@author Felipe Morais
@since 28/02/2016
@version P12/MA3 - Russia
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina	AS ARRAY
Local aRotCons	AS ARRAY
aRotina := FWLoadMenuDef(SOURCEFATHER)

ADD OPTION aRotina TITLE STR0149 ACTION 'RU01S01RUS' OPERATION 2 ACCESS 0	//"History"

aRotCons	:= {}
ADD OPTION aRotCons TITLE STR0150 ACTION 'RU01T02I("C")' OPERATION 4 ACCESS 0	//"Conservation"
ADD OPTION aRotCons TITLE STR0151 ACTION 'RU01T02I("D")' OPERATION 4 ACCESS 0	//"Desconservation"
ADD OPTION aRotCons TITLE STR0149 ACTION 'RU01T02I("H")' OPERATION 2 ACCESS 0	//"History"

aAdd(aRotina, {STR0150, aRotCons, 0, 8, 0, Nil, Nil, Nil})	//"Conservation"
//Alexandra Menyashina(27/03/18): View of Com Invoice if we have all need information in fixed asset
ADD OPTION aRotina TITLE STR0160 ACTION 'ATFA012PIN()' OPERATION MODEL_OPERATION_VIEW ACCESS 0	//"Purchace invoice"

Return aRotina

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

MVC Model def

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
Local oModel		AS OBJECT
Local oEventRUS		AS OBJECT

oModel		:= FWLoadModel(SOURCEFATHER)
oModel:SetDescription(STR0170)
oEventRUS	:= EV01A012RU():New()
oModel:InstallEvent("EV01A012RU",,oEventRUS)

Pergunte("AFA012", .F.)
If MV_PAR07 == 2
	oModel:GetModel( 'SN3DETAIL' ):SetLoadFilter( , " N3_DTBAIXA = ' ' " )
EndIf

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

MVC View def

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local nX			AS NUMERIC
Local aFldRemove	AS ARRAY
Local oView			AS OBJECT
Local oStructSN1	AS OBJECT
Local oStructSN3	AS OBJECT

oView		:= FWLoadView(SOURCEFATHER)

oStructSN1	:= oView:GetViewStruct("SN1MASTER")
oStructSN3	:= oView:GetViewStruct("SN3DETAIL")

aFldRemove	:= {}
aAdd(aFldRemove, "N3_UUID")

If ExistBlock("AFA12RUF")
	aFldRemove	:= ExecBlock("AFA12RUF", .F., .F., {oView, aFldRemove})
EndIf

For nX := 1 To Len(aFldRemove)
	If SubStr(aFldRemove[nX], 1, 3) == "N1_"
		oStructSN1:RemoveField(aFldRemove[nX])
	ElseIf SubStr(aFldRemove[nX], 1, 3) == "N3_"
		oStructSN3:RemoveField(aFldRemove[nX])
	EndIf
Next nX

oView:SetViewCanActivate({|oView| AF012VldEd(oView)})

Return oView

/*{Protheus.doc} ATFA012PIN
@author Alexandra Menyashina
@since 29/03/2018
@version P12.1.20
@param None
@return nil
@type function
@description open View of checked Commertial Invoice
*/
Function ATFA012PIN()
Local aArea as Array
Local aAreaSF1 as Array
Local aAreaSD1 as Array
Local cKeySF1 as Character
Local aRotinaTMP as Array
Local cN1NFiscal	AS CHARACTER
Local cN1Seri		AS CHARACTER
Local cN1Fornece	AS CHARACTER
Local cN1Loja		AS CHARACTER
Local cBkCad		AS CHARACTER

aRotinaTMP	:=	aClone(aRotina)
aRotina	:=	{{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil}}
cBkCad := cCadastro
cCadastro := STR0160
aArea := GetArea()
aAreaSF1 := SF1->(GetArea())
aAreaSD1 := SD1->(GetArea())
		DbSelectArea("SF1")
		SF1->(DbSetOrder(1))	//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA

		cN1NFiscal	:= SN1->N1_NFISCAL
		cN1Seri		:= SN1->N1_NSERIE
		cN1Fornece	:= SN1->N1_FORNEC
		cN1Loja		:= SN1->N1_LOJA

		cKeySF1 := xFilial("SN1") + cN1NFiscal + cN1Seri + cN1Fornece + cN1Loja
		If (SF1->(DbSeek(cKeySF1)))
			CtbDocEnt()	//open View of SF1/SD1
		Else
				Help("",1,"ATFA012PIN",,STR0159,1,0)	//"No Comertial Invoice for this Fixed asset"
		Endif
aRotina := aClone(aRotinaTMP)
cCadastro := cBkCad
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
Return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} EV01A012RU

Russian implementation for model events over ATFA012 FA maintenance

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        FWModelEvent
/*/
//-----------------------------------------------------------------------
Class EV01A012RU From FWModelEvent
	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId) Public
	Method BeforeTTS(oModel, cModelId) Public
End Class

//-----------------------------------------------------------------------
/*/{Protheus.doc} EV01A012RU:New()

Constructor method for EV01A012RU

@param		None
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        EV01A012RU
/*/
//-----------------------------------------------------------------------
Method New() Class EV01A012RU
Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} EV01A012RU:BeforeTTS()

Method called before transaction

@param		OBJECT oModel
@param		CHARACTER cModelId
@return		LOGICAL lOk
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        EV01A012RU
/*/
//-----------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class EV01A012RU
Local nX			AS NUMERIC
Local lAtLeast1NWO	AS LOGICAL
Local lOk			AS LOGICAL
Local oModelSN1		AS OBJECT
Local oModelSN3		AS OBJECT
Local oModelLog		AS OBJECT

lOk			:= .T.
oModelSN1	:= oModel:GetModel("SN1MASTER")
oModelSN3	:= oModel:GetModel("SN3DETAIL")
nOper		:= oModel:GetOperation()

If cModelId == "ATFA012"
	lAtLeast1NWO	:= .F.
	For nX := 1 To oModelSN3:Length()
		If ! oModelSN3:IsDeleted(nX)
			lAtLeast1NWO	:= ;
				oModelSN3:GetValue("N3_BAIXA", nX) <> SN3_BAIXA_WRITTEN_OFF
			If lAtLeast1NWO
				Exit
			EndIf
		EndIf
	Next nX

	If lAtLeast1NWO .And. Empty(oModelSN1:GetValue("N1_QUANTD"))
		lOk		:= .F.
		Help("",1,"AFA012RUSNWOFQTY",,STR0162,1,0)	// "Quantity is mandatory for non writen-off fixed assets"
	EndIf

	If nOper == MODEL_OPERATION_DELETE .AND. lOk
		Do Case
		Case oModelSN1:GetValue("N1_STATUS") == '0'
			oModelLog	:= FWLoadModel("RU01S01")
			oModelLog:SetOperation(MODEL_OPERATION_VIEW)
			oModelLog:Activate()
			For nX := 1 to oModelLog:GetModel("SN4DETAIL"):Length()
				oModelLog:GetModel("SN4DETAIL"):GoLine(nX)
				If oModelLog:GetModel("SN4DETAIL"):GetValue("N4_OCORR") <> '05'
					lOk := .F.
					Help(' ',1,"AFA012RUSDEL1" ,,STR0173,1,0)	//"Operations were performed on this fixed asset It is imposible to delete it."
					Exit
				EndIf
			Next nX
		Otherwise
			lOk := .F.
			Help(' ',1,"AFA012RUSDEL2" ,,STR0174,1,0)	//"Delition is posible on status schedule."
		Endcase
	EndIf
EndIf

Return lOk

//-----------------------------------------------------------------------
/*/{Protheus.doc} EV01A012RU:BeforeTTS()

Method called before transaction

@param		OBJECT oModel
@param		CHARACTER cModelId
@return		None
@author 	victor.rezende
@since 		12/04/2018
@version 	1.0
@project	MA3
@see        EV01A012RU
/*/
//-----------------------------------------------------------------------
Method BeforeTTS(oModel, cModelId) Class EV01A012RU
Local nX			AS NUMERIC
Local cN1Base		AS CHARACTER
Local cN1Item		AS CHARACTER
Local cStatus		AS CHARACTER
Local lOperation	AS LOGICAL
Local lAtLeast1Oper	AS LOGICAL
Local lWrittenOf	AS LOGICAL
Local lAllWrtOff	AS LOGICAL
Local lOk			AS LOGICAL
Local bLineInOp		AS BLOCK
Local bLineWrOf		AS BLOCK
Local oModelSN1		AS OBJECT
Local oModelSN3		AS OBJECT

lOk			:= .T.
oModelSN1	:= oModel:GetModel("SN1MASTER")
oModelSN3	:= oModel:GetModel("SN3DETAIL")

bLineInOp	:= {|nLine| ;
	! oModelSN3:IsDeleted(nLine) .And. ;
	oModelSN3:GetValue("N3_OPER", nLine) == SN3_OPER_IN_OPERATION}
bLineWrOf	:= {|nLine| ;
	! oModelSN3:IsDeleted(nLine) .And. ;
	oModelSN3:GetValue("N3_BAIXA", nLine) == SN3_BAIXA_WRITTEN_OFF}

If cModelId == "ATFA012"
	cN1Base			:= oModelSN1:GetValue("N1_CBASE")
	cN1Item			:= oModelSN1:GetValue("N1_ITEM")
	cStatus			:= oModelSN1:GetValue("N1_STATUS")
	lAtLeast1Oper	:= .F.
	lAllWrtOff		:= .T.

	For nX := 1 To oModelSN3:Length()
		lOperation		:= Eval(bLineInOp, nX)
		lWrittenOf		:= Eval(bLineWrOf, nX)
		lAllWrtOff		:= lAllWrtOff .And. lWrittenOf
		
		/* Business rule
		 *	FA balances cannot be written-off and in operation
		 */
		If lOperation .And. lWrittenOf
			oModelSN3:GoLine(nX)
			lOk	:= oModelSN3:LoadValue(;
					"N3_OPER", ;
					SN3_OPER_NOT_IN_OPERATION) .And. lOk
		EndIf

		lOperation		:= Eval(bLineInOp, nX)
		lAtLeast1Oper	:= lAtLeast1Oper .Or. lOperation
	Next nX

	/* Business rule
	 *	FA status should comply with balances in or off operation
	 *	If status is 1-In use, we must have at least one FA line in operation.
	 *	If status is 0-Scheduled, we must have no FA line in operation.
	 *	If all balances are writte-off, status must be 8-Written-off.
	 *	If status is 5-Conservation
	 */
	If lAllWrtOff .And. cStatus <> SN1_STATUS_WRITTEN_OFF
		lOk	:= oModelSN1:LoadValue("N1_STATUS",SN1_STATUS_WRITTEN_OFF) .And. lOk
	ElseIf lAtLeast1Oper .And. cStatus == SN1_STATUS_INACTIVE
		lOk	:= oModelSN1:LoadValue("N1_STATUS", SN1_STATUS_ACTIVE) .And. lOk
	ElseIf ! lAtLeast1Oper .And. cStatus == SN1_STATUS_ACTIVE
		lOk	:= oModelSN1:LoadValue("N1_STATUS", SN1_STATUS_INACTIVE) .And. lOk
	ElseIf ! Empty(RU01T02DDD(dDatabase, cN1Base, cN1Item))
		lOk	:= oModelSN1:LoadValue("N1_STATUS", SN1_STATUS_CONSERVATION) .And. lOk		//(19/06/18):in future it need to be SetValue
	ElseIf  oModelSN1:GetValue("N1_STATUS") == SN1_STATUS_CONSERVATION .And. Empty(RU01T02DDD(dDatabase, cN1Base, cN1Item))
		lOk	:= oModelSN1:LoadValue("N1_STATUS", SN1_STATUS_ACTIVE) .And. lOk		//(19/06/18):in future it need to be SetValue
	ElseIf oModelSN1:GetValue("N1_STATUS") == SN1_STATUS_WRITTEN_OFF .and. cStatus == SN1_STATUS_WRITTEN_OFF .and. FWisincallstack('AT36Cance')
		lOk := oModelSN1:LoadValue("N1_STATUS", SN1_STATUS_ACTIVE) .and. lOk
	EndIf
EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} AF012VldEd

Fields editables validation for user screen

@param		OBJECT oView
@return		None
@author 	victor.rezende
@since 		20/09/2018
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function AF012VldEd(oView)
Local nX			AS NUMERIC
Local oModel 		AS OBJECT
Local oStructSN1	AS OBJECT
Local oStructSN3	AS OBJECT
Local nOper			AS NUMERIC
Local cNoEdField	AS CHARACTER
Local cEdFieldN1	AS CHARACTER
Local cEdFlderN3	AS CHARACTER
Local cEdFld2N3		AS CHARACTER
Local lNoWriteOf	AS LOGICAL
Local lSchadule		AS LOGICAL
Local lPutInOp		AS LOGICAL
Local lEdit			AS LOGICAL

Default lNoWriteOf	:= .T.
Default lSchadule	:= .T.
Default lPutInOp	:= .F.

oModel		:= oView:GetModel()
oStructSN1	:= oView:GetViewStruct("SN1MASTER")
oStructSN3	:= oView:GetViewStruct("SN3DETAIL")

cNoEdField	:= "N1_GRUPO|N1_PATRIM|N1_CBASE|N1_ITEM|N1_STATUS|N1_AQUSIC|N1_NSERIE|N1_NFISCAL|N3_INCOST|N3_OPER"
cEdFieldN1	:= "N1_FORNEC|N1_LOJA|N1_LOCAL|N1_DLOCAL|N1_PROJETO|N1_PROJREV|N1_PROJETP|N1_PROJITE|N1_CADNUMB|N1_LANDCAT|N1_PRODUTO"+;
				"|N1_REGNUMB|N1_VHMODEL|N1_REGDATE|N1_MILEAGE|N1_VHCTYPE|N1_PRDDATE|N1_MANUFAC|N1_SERIAL|N1_FACNUMB|N1_PRPTYPE"

//Fields SN3 folders 1-4, which will able to edit in status 0.
cEdFlderN3	:= "|N3_CBASE|N3_ITEM|N3_TIPO|N3_HISTOR|N3_TPSALDO|N3_FIMDEPR|N3_DINDEPR|N3_DEXAUST|N3_AQUISIC|N3_DTBAIXA|N3_OK|N3_SEQ|N3_SEQREAV|N3_CODBAIX"+;
				"|N3_FILORIG|N3_IDBAIXA|N3_LOCAL|N3_NOVO|N3_QUANTD|N3_PERCBAI|N3_NODIA|N3_DIACTB|N3_DTACELE|N3_CCONTAB|N3_CUSTBEM|N3_CDEPREC|N3_CCUSTO"+;
				"|N3_CCDEPR|N3_CDESP|N3_NLANCTO|N3_CCORREC|N3_DLANCTO|N3_CCDESP|N3_CCCDEP|N3_SUBCTA|N3_SUBCCON|N3_SUBCDEP|N3_CCCDES|N3_CCCORR"+;
				"|N3_SUBCCDE|N3_SUBCDES|N3_SUBCCOR|N3_CLVL|N3_CLVLCON|N3_CLVLDEP|N3_CLVLCDE|N3_CLVLDES|N3_CLVLCOR|N3_VORIG1|N3_VRDMES1|N3_VRDACM1|N3_AMPLIA1"+;
				"|N3_TPDEPR|N3_TXDEPR1|N3_INDICE1|N3_INDICE2|N3_INDICE3|N3_INDICE4|N3_INDICE5|N3_DEPREC|N3_CRIDEPR|N3_PRODACM|N3_CALDEPR|N3_VMXDEPR|N3_PERDEPR"+;
				"|N3_VLSALV1|N3_CALCDEP|N3_PRODANO|N3_PRODMES|N3_PERCDEP|N3_CODPOOL|N3_VLIMPER|N3_CODIND|N3_DESCEST"
//Fields SN3 folder 2, which will able to edit
cEdFld2N3	:= "|N3_CCONTAB|N3_CUSTBEM|N3_CDEPREC|N3_CCUSTO|N3_CCDEPR|N3_CDESP|N3_NLANCTO|N3_CCORREC|N3_DLANCTO|N3_CCDESP|N3_CCCDEP|N3_SUBCTA|N3_SUBCCON|N3_SUBCDEP"+;
				"|N3_CCCDES|N3_CCCORR|N3_SUBCCDE|N3_SUBCDES|N3_SUBCCOR|N3_CLVL|N3_CLVLCON|N3_CLVLDEP|N3_CLVLCDE|N3_CLVLDES|N3_CLVLCOR"

nOper := oView:GetOperation()
If nOper <> MODEL_OPERATION_VIEW
	If nOper <> MODEL_OPERATION_INSERT 
		lNoWriteOf	:= !(SN1->N1_STATUS $ "8")
		lSchadule	:= (SN1->N1_STATUS $ "0")
		lPutInOp	:= (SN1->N1_STATUS $ "1")
	EndIf
	If	nOper == MODEL_OPERATION_UPDATE				
		//Change property Editable of Fields SN1	|| aFields[nX][1] - name of Field	|| aFields[nX][11] - name of Folder of Field
		For nX := 1 To Len(oStructSN1:aFields)
			If !lNoWriteOf
				lEdit	:= .F.
			Elseif lPutInOp
				lEdit 	:= (oStructSN1:aFields[nX][1] $ cEdFieldN1)
			Else
				lEdit	:=!(oStructSN1:aFields[nX][1] $ cNoEdField)
			EndIf
			oStructSN1:SetProperty(oStructSN1:aFields[nX][1], MVC_VIEW_CANCHANGE, lEdit)

			If (oStructSN1:aFields[nX][1] == "N1_CHAPA" ) 
				oStructSN1:SetProperty(oStructSN1:aFields[nX][1], MVC_VIEW_CANCHANGE, (Empty( M->N1_STATUS ) .Or. M->N1_STATUS == "0"))
			EndIf
		Next nX
	EndIf

	//Change property Editable of Fields SN3
	If 	lPutInOp
		oStructSN3:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
	Else
		For nX := 1 To Len(oStructSN3:aFields)
			lEdit	:=	lNoWriteOf .AND. ;
							((lSchadule .AND. ;
									(oStructSN3:aFields[nX][1] $ cEdFlderN3) .AND. ;
									!(oStructSN3:aFields[nX][1] $ cNoEdField));
							.OR.	(lNoWriteOf .AND. ;
									!lSchadule .AND.;
									(oStructSN3:aFields[nX][1] $ cEdFld2N3)))
			oStructSN3:SetProperty(oStructSN3:aFields[nX][1], MVC_VIEW_CANCHANGE, lEdit)
		Next nX
	EndIf
EndIf
Return .T.
