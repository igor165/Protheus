#Include "GTPA318.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Static c300BCodigo 
Static c300BDescri 

/*/{Protheus.doc} GTPA318
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPA318()
Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias('G56')
oBrowse:SetMenuDef('GTPA318')

oBrowse:SetDescription(STR0001) //'Cadastro de Ocorrencia'

oBrowse:AddLegend('G56->G56_STSOCR=="1"',  "GREEN", STR0002) //"Ocorrências Finalizada"
oBrowse:AddLegend('G56->G56_STSOCR=="2"',  "RED",   STR0003) //"Ocorrências Em andamento"
oBrowse:AddLegend('G56->G56_STSOCR=="3"',  "YELLOW",STR0004) //"Ocorrências sem operacional"

oBrowse:Activate()
oBrowse:Destroy()

GTPDestroy(oBrowse)

Return 


/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()
Local aRotina := {} 

ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA318' OPERATION OP_VISUALIZAR	ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPA318' OPERATION OP_INCLUIR		ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.GTPA318' OPERATION OP_ALTERAR		ACCESS 0  //"Alterar"
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.GTPA318' OPERATION OP_EXCLUIR		ACCESS 0  //"Excluir"
ADD OPTION aRotina TITLE STR0009 ACTION 'AltFcOcorn(1)'   OPERATION OP_ALTERAR		ACCESS 0 //"Fechar"
ADD OPTION aRotina TITLE STR0010 ACTION 'AltFcOcorn(2)'   OPERATION OP_ALTERAR		ACCESS 0 //"Reabrir"

Return aRotina


/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
Local oModel	:= nil
Local oStruG56	:= FWFormStruct(1,'G56')
Local bPosValid := {|oModel|PosValidG56(oModel)}
SetModelStruct(oStruG56)

oModel := MPFormModel():New('GTPA318', /*bPreValidacao*/,bPosValid, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('G56MASTER',/*cOwner*/,oStruG56)

oModel:SetDescription(STR0001) //'Cadastro de Ocorrencia'

oModel:GetModel('G56MASTER'):SetDescription(STR0001) //'Cadastro de Ocorrencia'

oModel:SetPrimaryKey({'G56_FILIAL','G56_CODIGO'})

Return oModel

/*/{Protheus.doc} SetModelStruct
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oStruG56, object, descricao
@type function
/*/
Static Function SetModelStruct(oStruG56)

Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}

oStruG56:AddTrigger('G56_VIAGEM'	,'G56_VIAGEM'	,{||.T.}, bTrig)
oStruG56:AddTrigger('G56_TPOCOR'	,'G56_TPOCOR'	,{||.T.}, bTrig)
oStruG56:AddTrigger('G56_LOCORI'	,'G56_LOCORI'	,{||.T.}, bTrig)
oStruG56:AddTrigger('G56_LOCDES'	,'G56_LOCDES'	,{||.T.}, bTrig)

oStruG56:SetProperty('G56_USRPRT', MODEL_FIELD_INIT	, bInit )
oStruG56:SetProperty('G56_NMTPOC', MODEL_FIELD_INIT	, bInit )
oStruG56:SetProperty('G56_NMLOCA', MODEL_FIELD_INIT	, bInit )
oStruG56:SetProperty('G56_NMDEST', MODEL_FIELD_INIT	, bInit )

Return


/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA318')
Local oStruG56	:= FWFormStruct(2, 'G56')

SetViewStruct(oStruG56)

oView:SetModel(oModel)

oView:AddField('VIEW_G56' ,oStruG56,'G56MASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_G56','TELA')

oView:SetDescription(STR0001) //'Cadastro de Ocorrencia'

oView:AddUserButton(STR0009,"",{|| AltFcOcorn(1) } ,,) //"Fechar"
oView:AddUserButton(STR0010,"",{|| AltFcOcorn(2) } ,,) //"Reabrir"

Return oView

/*/{Protheus.doc} SetViewStruct
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oStruG56, object, descricao
@type function
/*/
Static Function SetViewStruct(oStruG56)

oStruG56:RemoveField("G56_USRPRT")
oStruG56:RemoveField("G56_STSOCR")

Return

/*/{Protheus.doc} FieldTrigger
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param uVal, undefined, descricao
@type function
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
	
Local oModel	:= oMdl:GetModel()

Do Case
	Case cField == 'G56_TPOCOR'
		uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + oModel:GetModel("G56MASTER"):GetValue("G56_TPOCOR"),"G6Q_DESCRI")
		oModel:GetModel("G56MASTER"):SetValue('G56_NMTPOC',uRet)
		If POSICIONE("G6Q",1,XFILIAL("G6Q") + oModel:GetModel("G56MASTER"):GetValue("G56_TPOCOR"),"G6Q_OPERAC")
			oModel:GetModel("G56MASTER"):SetValue('G56_STSOCR','2')
		Else
			oModel:GetModel("G56MASTER"):SetValue('G56_STSOCR','3')
		EndIf
	Case cField == 'G56_LOCORI'
		uRet := POSICIONE("GI1",1,XFILIAL("GI1") + oModel:GetModel("G56MASTER"):GetValue("G56_LOCORI"),"GI1_DESCRI")
		oModel:GetModel("G56MASTER"):SetValue('G56_NMLOCA',uRet)
	Case cField == 'G56_LOCDES'
		uRet := POSICIONE("GI1",1,XFILIAL("GI1") + oModel:GetModel("G56MASTER"):GetValue("G56_LOCDES"),"GI1_DESCRI")
		oModel:GetModel("G56MASTER"):SetValue('G56_NMDEST',uRet)
	Case cField == 'G56_VIAGEM'
		uRet := POSICIONE("GYN",1,XFILIAL("GYN") + oModel:GetModel("G56MASTER"):GetValue("G56_VIAGEM"),"GYN_DTINI")
		oModel:GetModel("G56MASTER"):SetValue('G56_DTVIAG',uRet)
		If POSICIONE("GYN",1,XFILIAL("GYN") + oModel:GetModel("G56MASTER"):GetValue("G56_VIAGEM"),"GYN_FINAL") == '1'
			oModel:GetModel("G56MASTER"):SetValue('G56_STSOCR','1')
		EndIf
	
EndCase

Return uVal

/*/{Protheus.doc} FieldInit
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param uVal, undefined, descricao
@param nLine, numeric, descricao
@param uOldValue, undefined, descricao
@type function
/*/
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet		:= uVal

Do Case 
	Case cField == 'G56_USRPRT'
		uRet := LogUserName()
	Case cField == 'G56_NMTPOC'
		If !INCLUI
			uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + G56->G56_TPOCOR,"G6Q_DESCRI")
		Else
			uRet := ""	
		EndIf
	Case cField == 'G56_NMLOCA'
		If !INCLUI	
			uRet := POSICIONE("GI1",1,XFILIAL("GI1") + G56->G56_LOCORI,"GI1_DESCRI")
		Else
			uRet := ""	
		EndIf
	Case cField == 'G56_NMDEST'
		If !INCLUI
			uRet := POSICIONE("GI1",1,XFILIAL("GI1") + G56->G56_LOCDES,"GI1_DESCRI")
		Else
			uRet := ""	
		EndIf
EndCase

Return uRet

/*/{Protheus.doc} PosValidG56
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return lRet, Retorno logico da validação

@type function
/*/
Static Function PosValidG56(oMdl)
Local lRet    := .T.
Local cStatus := ""
Local oModel  := oMdl:GetModel("G56MASTER")
Local nOpc    := oMdl:GetOperation()
Local oMdl300 

oMdl300 := FwLoadModel("GTPA300")

//Realizar a modificação da viagem posicionada para 2 ou 3 
If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE 
	If GYN->(DbSeek(xFilial("GYN") + oModel:GetValue("G56_VIAGEM")))
		If !(GYN->GYN_DTINI >= oModel:GetValue("G56_DTVIAG") .AND. GYN->GYN_DTFIM <= oModel:GetValue("G56_DTVIAG"))
			lRet := .F.
		EndIf
		If lRet
			oMdl300:SetOperation(MODEL_OPERATION_UPDATE)
		
			IF oMdl300:Activate()
				If !(IsInCallstack("GTPC300P")) .AND. !(IsInCallstack("AltFcOcorn"))
					If GYN->GYN_FINAL != "1" 
						
						If POSICIONE("G6Q",1,XFILIAL("G6Q") + oModel:GetValue("G56_TPOCOR"),"G6Q_OPERAC")
							cStatus := '2'
						Else
							cStatus := '3'
						EndIf
					
					Else
						cStatus := '1'
					EndIf
				Else
					cStatus := 	oModel:GetValue("G56_STSOCR")
				EndIf
				
				oMdl300:GetModel("GYNMASTER"):LoadValue("GYN_STSOCR",cStatus)
				
				If oMdl300:VldData()
					oMdl300:CommitData()
				Else
					lRet := .F.
				EndIf
				oMdl300:DeActivate()
			EndIf
		Else
			Help(,,'GTPA318',, "Data cadastrada fora do range de datas da viagem" ,1,0)
		EndIf
	Else
		Help(,,'GTPA318',, "Não existe a viagem cadastrada." ,1,0)
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} AltFcOcorn
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param nAlteraFc, numeric, descricao
@type function
/*/
Function AltFcOcorn(nAlteraFc)
Local oModel  := FwLoadModel("GTPA318")
Local oMdl    := oModel:GetModel("G56MASTER")
Local cStatus := ""
Local lRet := .T.

oModel:SetOperation(MODEL_OPERATION_UPDATE)
IF oModel:Activate()
	If POSICIONE("GYN",1,XFILIAL("GYN") + oMdl:GetValue("G56_VIAGEM"), "GYN_FINAL") != "1"
		If nAlteraFc == 1
			cStatus := "1"
		Else
			If POSICIONE("G6Q",1,XFILIAL("G6Q") + oMdl:GetValue("G56_TPOCOR"),"G6Q_OPERAC")
				cStatus := '2'
			Else
				cStatus := '3'
			EndIf
		EndIf
		
		oMdl:SetValue("G56_STSOCR",cStatus)
					
		If oModel:VldData()
			oModel:CommitData()
		Else
			lRet := .F.
			DisarmTransaction()
		EndIf
	Else
		FwAlertError(STR0012, STR0011) //"Aviso" //"Viagem já finalizada!"
	EndIf
EndIf

oModel:DeActivate()

//If lRet
//	If nAlteraFc == 1
//		Help(,,'GTPA318',, STR0013 ,1,0)//"Ocorrências Fechadas"
//	Else
//		Help(,,'GTPA318',, STR0014 ,1,0)//"Ocorrências Reabertas"
//	EndIf		
//Else
//	Help(,,'GTPA318',, STR0015 ,1,0)//"Inconsistência"
//EndIf

If !lRet
	Help(,,'GTPA318',, STR0015 ,1,0)//"Inconsistência"
EndIf

Return

Function G318BRFil(nRet)
Local cRet :=''
If nRet == 1
	cRet:=	c300BCodigo
Else
	cRet:=	c300BDescri
Endif

Return cRet

Function G318BFil(nLocViag)

Local aRetorno 		:= {}
Local cQuery   		:= "" 
Local cValid        := ""         
Local lRet     		:= .F.
Local oLookUp  		:= Nil
Local oMldMaster	:=  FwModelActive()

Default nLocViag := 1

If FWIsInCallStack("GTPC300P")
	cIdSubMdl 	:= "G56DETAIL"
	cField		:= "G56_VIAGEM"
	cValid		:= "GYN_CODIGO"
ElseIf FWIsInCallStack("GTPA300")
	cIdSubMdl 	:= "GYNMASTER"
	cField		:= "GYN_CODGID"
	cValid		:= "GYN_CODGID"
Else
	cIdSubMdl 	:= "G56MASTER"
	cField		:= "G56_VIAGEM"
	cValid		:= "GYN_CODIGO"
EndIf

If nLocViag == 1
	cQuery := " SELECT GIE_FILIAL,GIE_CODGID,GIE_LINHA,GIE_IDLOCP,GIE_HIST "
	cQuery += " FROM " + RetSqlName("GIE") + " GIE  "
	cQuery += " INNER JOIN " + RetSqlName("GYN") + " GYN "
	cQuery += " ON GYN.D_E_L_E_T_ = ' ' "
	cQuery += " AND GYN.GYN_FILIAL = GIE.GIE_FILIAL "
	cQuery += " AND GYN." + cValid + " = '" + oMldMaster:GetModel(cIdSubMdl):GETVALUE(cField) + "' "
	cQuery += " AND GYN.GYN_CODGID = GIE.GIE_CODGID "
	cQuery += " WHERE GIE.D_E_L_E_T_ = ' ' "
	cQuery += " AND GIE.GIE_FILIAL = '"+xFilial('GIE')+"' "

	oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"GIE_FILIAL","GIE_CODGID","GIE_LINHA","GIE_IDLOCP"})
Else
	cQuery := " SELECT GIE_FILIAL,GIE_CODGID,GIE_LINHA,GIE_IDLOCD,GIE_HIST "
	cQuery += " FROM " + RetSqlName("GIE") + " GIE  "
	cQuery += " INNER JOIN " + RetSqlName("GYN") + " GYN "
	cQuery += " ON GYN.D_E_L_E_T_ = ' ' "
	cQuery += " AND GYN.GYN_FILIAL = GIE.GIE_FILIAL "
	cQuery += " AND GYN." + cValid + " = '" + oMldMaster:GetModel(cIdSubMdl):GETVALUE(cField) + "' "
	cQuery += " AND GYN.GYN_CODGID = GIE.GIE_CODGID "
	cQuery += " WHERE GIE.D_E_L_E_T_ = ' ' "
	cQuery += " AND GIE.GIE_FILIAL = '"+xFilial('GIE')+"' "
	
	oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"GIE_FILIAL","GIE_CODGID","GIE_LINHA","GIE_IDLOCD"})
EndIf

oLookUp:AddIndice("Filial"		, "GIE_FILIAL")
oLookUp:AddIndice("Código"		, "GIE_CODGID")
oLookUp:AddIndice("Hist"		, "GIE_HIST")

If oLookUp:Execute()
	lRet       := .T.
	aRetorno   := oLookUp:GetReturn()
	c300BCodigo := aRetorno[4]
	c300BDescri := aRetorno[2]
EndIf   

FreeObj(oLookUp)

Return lRet
