#Include "GTPC300P.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} GTPC300P
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPC300P()
Local lMonitor	:= GC300GetMVC('IsActive')

If lMonitor

	nOpc := Aviso( STR0002, STR0001, { STR0003, STR0005,STR0004},1)	 //"Deseja incluir ocorrência posicionada ou todas?" //"Ocorrências" //"Posicionada" //"Cancelar" //"Todas"

	If nOpc == 1 .Or. nOpc == 2
		FWExecView( STR0002, 'VIEWDEF.GTPC300P', MODEL_OPERATION_UPDATE, , { || .T. } ) //"Ocorrências"
	EndIf
Else
	FwAlertHelp(STR0002,STR0006) //"Esta rotina só funciona com monitor ativo" //"Ocorrências"
Endif
	
return

/*/{Protheus.doc} Modeldef
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function Modeldef()

Local oStrCab  := FWFormModelStruct():New()
Local oStrGrd  := FWFormStruct(1,"G56")
Local bPosValid := {|oModel|PosValid(oModel)}
Local oModel   := Nil

StructModel(oStrCab,oStrGrd)

oModel := MPFormModel():New('GTPC300P',/*bPreValid*/, bPosValid, , /*bCancel*/)

oModel:AddFields("G56MASTER", , oStrCab,,,{||})
oModel:AddGrid("G56DETAIL", "G56MASTER", oStrGrd, , , , , )

oModel:SetRelation( 'G56DETAIL', { { 'G56_FILIAL', 'xFilial( "GYN" )' }, { 'G56_VIAGEM', 'CODVIAG' } }, G56->(IndexKey(3)))

oModel:GetModel("G56MASTER"):SetDescription(STR0007) //"Viagem"
oModel:GetModel("G56DETAIL"):SetDescription(STR0002) //"Ocorrências"

oModel:SetDescription(STR0008) //"Ocorrências de viagem"
oModel:SetPrimaryKey({})

Return(oModel)

/*/{Protheus.doc} PosValid
(long_description)
@type  Static Function
@author henrique.toyada
@since 20/08/2019
@version 1.0
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PosValid(oModel)
Local oMdl300 
Local oMdl	      := oModel:GetModel()
Local oMdlGrd	  := oMdl:GetModel('G56DETAIL')
Local oMldMonitor := GC300GetMVC('M')
Local oViewMonitor:= GC300GetMVC('V')
Local oMdlGYN	  := oMldMonitor:GetModel( 'GYNDETAIL' )
Local nI		  := 0
Local nOpc        := oMdl:GetOperation()
Local lRet        := .T.
Local cStatus     := ""
Local lUpdGYN	  := !oMdlGYN:CanUpdateLine()

For nI := 1 To oMdlGrd:Length()
	oMdlGrd:GoLine(nI)
	If oMdlGrd:IsDeleted()
		oMdlGrd:DeleteLine()
	EndIf
Next

oMdl300 := FwLoadModel("GTPA300")

//Realizar a modificação da viagem posicionada para 2 ou 3 
If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE 
	If GYN->(DbSeek(xFilial("GYN") + oMdlGrd:GetValue("G56_VIAGEM")))
		
		If lRet
			oMdl300:SetOperation(MODEL_OPERATION_UPDATE)
		
			IF oMdl300:Activate()
				If !(IsInCallstack("GTPC300P")) .AND. !(IsInCallstack("AltFcOcorn"))
					If GYN->GYN_FINAL != "1" 
						
						If POSICIONE("G6Q",1,XFILIAL("G6Q") + oMdlGrd:GetValue("G56_TPOCOR"),"G6Q_OPERAC")
							cStatus := '2'
						Else
							cStatus := '3'
						EndIf
					
					Else
						cStatus := '1'
					EndIf
				Else
					cStatus := 	oMdlGrd:GetValue("G56_STSOCR")
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
			Help(,,'GTPA300P',, "Data cadastrada fora do range de datas da viagem" ,1,0)
		EndIf
	Else
		Help(,,'GTPA300P',, "Não existe a viagem cadastrada." ,1,0)
	EndIf
EndIf
If lRet
	oMdlGYN:SetNoUpdateLine(.F.)

	cStatus := IIF(cStatus == '1', "BR_VERDE",IIF(cStatus == '2', "BR_VERMELHO","BR_AMARELO"))

	If oMdlGYN:SeekLine({{'GYN_CODIGO',oMdlGrd:GetValue("G56_VIAGEM")}})
		lRet := oMdlGYN:SetValue("GYN_STSLEG",cStatus)
	EndIf
	oMdlGYN:SetNoUpdateLine(lUpdGYN)
	oViewMonitor:Refresh("GYNDETAIL")
EndIf
	
Return lRet

/*/{Protheus.doc} StructModel
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oStrCab, object, descricao
@param oStrGrd, object, descricao
@type function
/*/
Static Function StructModel(oStrCab,oStrGrd)
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}

oStrCab:AddField(STR0011,;				// 	[01]  C   Titulo do campo //"Cod. Viaj"
					STR0012,;			// 	[02]  C   ToolTip do campo //"Codigo Viagem"
					"CODVIAG",;				// 	[03]  C   Id do Field
					"C",;						// 	[04]  C   Tipo do campo
					TamSx3('GYN_CODIGO')[1],;	// 	[05]  N   Tamanho do campo
					0,;						// 	[06]  N   Decimal do campo
					Nil,;						// 	[07]  B   Code-block de validação do campo
					Nil,;						// 	[08]  B   Code-block de validação When do campo
					Nil,;						//	[09]  A   Lista de valores permitido do campo
					.F.,;						//	[10]  L   Indica se o campo tem preenchimento obrigatório
					Nil,;						//	[11]  B   Code-block de inicializacao do campo
					.F.,;						//	[12]  L   Indica se trata-se de um campo chave
					.F.,;						//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)						// 	[14]  L   Indica se o campo é virtual
					
oStrCab:SetProperty('CODVIAG', MODEL_FIELD_INIT	, bInit )

oStrGrd:AddTrigger('G56_VIAGEM'	,'G56_VIAGEM'	,{||.T.}, bTrig)
oStrGrd:AddTrigger('G56_TPOCOR'	,'G56_TPOCOR'	,{||.T.}, bTrig)
oStrGrd:AddTrigger('G56_LOCORI'	,'G56_LOCORI'	,{||.T.}, bTrig)
oStrGrd:AddTrigger('G56_LOCDES'	,'G56_LOCDES'	,{||.T.}, bTrig)

oStrGrd:SetProperty('G56_USRPRT', MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('G56_NMTPOC', MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('G56_NMLOCA', MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('G56_NMDEST', MODEL_FIELD_INIT	, bInit )


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
		uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + uVal,"G6Q_DESCRI")
		oModel:GetModel("G56DETAIL"):SetValue('G56_NMTPOC',uRet)
		If POSICIONE("G6Q",1,XFILIAL("G6Q") + uVal,"G6Q_OPERAC")
			oModel:GetModel("G56DETAIL"):SetValue('G56_STSOCR','2')
		Else
			oModel:GetModel("G56DETAIL"):SetValue('G56_STSOCR','3')
		EndIf
	Case cField == 'G56_LOCORI'
		uRet := POSICIONE("GI1",1,XFILIAL("GI1") + uVal,"GI1_DESCRI")
		oModel:GetModel("G56DETAIL"):SetValue('G56_NMLOCA',uRet)
	Case cField == 'G56_LOCDES'
		uRet := POSICIONE("GI1",1,XFILIAL("GI1") + uVal,"GI1_DESCRI")
		oModel:GetModel("G56DETAIL"):SetValue('G56_NMDEST',uRet)
		
EndCase

Return uVal

/*/{Protheus.doc} FieldInit
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 15/08/2019
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
Local uRet		  := uVal
Local oMldMonitor := GC300GetMVC('M')
Local oMdlGYN	  := oMldMonitor:GetModel( 'GYNDETAIL' )

Do Case 
	Case cField == 'G56_USRPRT'
		uRet := LogUserName()
	Case cField == 'G56_NMTPOC'
		uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + G56->G56_TPOCOR,"G6Q_DESCRI")
	Case cField == 'G56_NMLOCA'
		uRet := POSICIONE("GI1",1,XFILIAL("GI1") + G56->G56_LOCORI,"GI1_DESCRI")
	Case cField == 'G56_NMDEST'
		uRet := POSICIONE("GI1",1,XFILIAL("GI1") + G56->G56_LOCDES,"GI1_DESCRI")
	Case cField == 'G56_VIAGEM'
		uRet := oMdlGYN:GetValue("GYN_CODIGO")
	Case cField == 'CODVIAG'
		uRet := oMdlGYN:GetValue("GYN_CODIGO")
EndCase

Return uRet

/*/{Protheus.doc} Viewdef
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}

@type static function
/*/
Static Function Viewdef()

Local oStrCab  := FWFormViewStruct():New()
Local oStrGrd  := FWFormStruct(2,"G56")
Local oModel   := ModelDef()
Local oView    := Nil

StructView(oStrCab,oStrGrd)

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VW_G56MASTER', oStrCab, 'G56MASTER')
oView:AddGrid('VW_G56DETAIL', oStrGrd, 'G56DETAIL')

oView:CreateHorizontalBox('CABEC', 30)
oView:CreateHorizontalBox('CORPO', 70)

oView:SetOwnerView('VW_G56MASTER', 'CABEC')
oView:SetOwnerView('VW_G56DETAIL', 'CORPO')

oView:SetViewProperty("G56DETAIL", "GRIDSEEK"	, {.T.})
oView:SetViewProperty("G56DETAIL", "GRIDFILTER"	, {.T.})

oView:EnableTitleView('VW_G56MASTER')
oView:EnableTitleView('VW_G56DETAIL')

oView:AddUserButton(STR0013,"",{|oView| AlterOcorn(2,oView) } ,,VK_F6) //"Reabrir"
oView:AddUserButton(STR0014,"",{|oView| AlterOcorn(1,oView) } ,,VK_F8) //"Fechar"

Return(oView)

/*/{Protheus.doc} StructView
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 14/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oStrCab, object, descricao
@param oStrGrd, object, descricao
@type function
/*/
Static Function StructView(oStrCab,oStrGrd)

Local aFields := {}
Local cFields := ""
Local nI      := 0

oStrCab:AddField("CODVIAG",;			// [01]  C   Nome do Campo
			"01",;						// [02]  C   Ordem
			STR0011,;				// [03]  C   Titulo do campo //"Cod. Viaj"
			STR0012,;			// [04]  C   Descricao do campo //"Codigo Viagem"
			Nil,;						// [05]  A   Array com Help // "Selecionar"
			"GET",;						// [06]  C   Tipo do campo
			"@C",;						// [07]  C   Picture
			NIL,;						// [08]  B   Bloco de Picture Var
			"",;						// [09]  C   Consulta F3
			.T.,;						// [10]  L   Indica se o campo é alteravel
			NIL,;						// [11]  C   Pasta do campo
			"",;						// [12]  C   Agrupamento do campo
			NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
			NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
			NIL,;						// [15]  C   Inicializador de Browse
			.T.,;						// [16]  L   Indica se o campo é virtual
			NIL,;						// [17]  C   Picture Variavel
			.F.)						// [18]  L   Indica pulo de linha após o campo


aFields := aClone(oStrGrd:GetFields())
	
cFields := "G56_FILIAL|G56_CODIGO|G56_USRPRT|G56_STSOCR"

For nI := 1 to Len(aFields)
	
	If ( (aFields[nI,1] $ cFields) )
	
		If ( oStrGrd:HasField(aFields[nI,1]) )
			oStrGrd:RemoveField(aFields[nI,1])
		EndIf
			
	EndIf	
	
Next nI
Return

/*/{Protheus.doc} AlterOcorn
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 16/08/2019
@version 1.0
@return ${return}, ${return_description}
@param nAlteraFc, numeric, descricao
@type function
/*/
Function AlterOcorn(nAlteraFc, oView)

Local oMldMonitor := GC300GetMVC('M')
Local oViewMonitor:= GC300GetMVC('V')
Local oMdlCab	  := oView:GetModel('G56MASTER')
Local oMdlGrd	  := oView:GetModel('G56DETAIL')
Local oModelG6    := FwLoadModel("GTPA318")
Local oMdlG56     := oModelG6:GetModel("G56MASTER")
Local cStatus     := ""
Local cStatusLeg  := ""
Local cViagem     := ""
Local nI          := 0
Local lRet        := .T.
Local oMdlGYN	  := oMldMonitor:GetModel( 'GYNDETAIL' )
Local lUpdGYN	  := !oMdlGYN:CanUpdateLine()

For nI := 1 To oMdlGrd:Length()
	oMdlGrd:GoLine(nI)
	
	G56->(DbSetOrder(1))
	If G56->(DbSeek(oMdlGrd:GetValue("G56_FILIAL") + oMdlGrd:GetValue("G56_CODIGO")))
		cViagem := oMdlGrd:GetValue("G56_VIAGEM")
		If POSICIONE("GYN",1,XFILIAL("GYN") + cViagem, "GYN_FINAL") != "1"
			oModelG6:SetOperation(MODEL_OPERATION_UPDATE)
			IF oModelG6:Activate()
				If nAlteraFc == 1
					cStatus := "1"
				Else
					If POSICIONE("G6Q",1,XFILIAL("G6Q") + oMdlGrd:GetValue("G56_LOCORI"),"G6Q_OPERAC")
						cStatus := '2'
					Else
						cStatus := '3'
					EndIf
				EndIf
				
				oMdlG56:SetValue("G56_STSOCR",cStatus)
				
				If oModelG6:VldData()
					oModelG6:CommitData()
				Else
					lRet := .F.
					DisarmTransaction()
				EndIf
			EndIf
			oModelG6:DeActivate()
		EndIf
	EndIf
Next

If lRet
	oMdlGYN:SetNoUpdateLine(.F.)

	cStatusLeg := IIF(cStatus == '1', "BR_VERDE",IIF(cStatus == '2', "BR_VERMELHO","BR_AMARELO"))

	If oMdlGYN:SeekLine({{'GYN_CODIGO',cViagem}})
		lRet := oMdlGYN:SetValue("GYN_STSLEG",cStatusLeg) .AND. oMdlGYN:SetValue("GYN_STSOCR",cStatus)
	EndIf
	oMdlGYN:SetNoUpdateLine(lUpdGYN)
EndIf

If lRet
	oViewMonitor:Refresh("GYNDETAIL")
	If nAlteraFc == 1
		MSGINFO( STR0017, 'GTPA300P' )
	Else
		MSGINFO( STR0018, 'GTPA300P' )
	EndIf
Else
	MSGINFO( STR0019, 'GTPA300P' )
EndIf
Return
