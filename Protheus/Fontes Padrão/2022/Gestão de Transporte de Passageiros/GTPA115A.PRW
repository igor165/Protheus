#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'GTPA115A.CH'

Static __cAliasTmp	:= ""

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelDef 
Model para geração e exclusão em massa de bilhetes
@type Static Function
@author Flavio Martins
@since 18/10/2017
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= FwLoadModel("GTPA115")
Local oStruGIC		:= oModel:GetModel('GICMASTER'):GetStruct()
Local bVldAct		:= {|oModel| VldActivate(oModel) }
Local bActivate		:= {|oModel| MdlActivate(oModel) }
Local bDeActivate	:= {|oModel| MdlDeActiv(oModel) }
Local bCommit		:= {|oModel| GA115Commit(oModel)}

SetModelStruct(oStruGIC)

oModel:SetDescription(STR0008)

oModel:SetVldActivate(bVldAct)

oModel:SetActivate(bActivate)

oModel:SetDeActivate(bDeActivate)

oModel:SetCommit(bCommit)

 
Return(oModel)

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct

@type Static Function
@author jacomo.fernandes
@since 28/02/2020
@version 1.0
@param oStruGIC, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStruGIC)
oStruGIC:DeActivate()

oStruGIC:SetProperty('GIC_TIPDOC'	, MODEL_FIELD_WHEN, {|| .F. } )
oStruGIC:SetProperty('GIC_SERIE'	, MODEL_FIELD_WHEN, {|| .F. } )
oStruGIC:SetProperty('GIC_SUBSER'	, MODEL_FIELD_WHEN, {|| .F. } )
oStruGIC:SetProperty('GIC_NUMCOM'	, MODEL_FIELD_WHEN, {|| .F. } )
oStruGIC:SetProperty('GIC_NUMDOC'	, MODEL_FIELD_WHEN, {|| .F. } )

oStruGIC:Activate()

Return 
//------------------------------------------------------------------------------
/* /{Protheus.doc} VldActivate(oModel) 

@type Static Function
@author jacomo.fernandes
@since 28/02/2020
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldActivate(oModel)
Local lRet			:= .T.
Local cMdlId		:= oModel:GetId()
Local lUtil			:= oModel:GetOperation() <> MODEL_OPERATION_INSERT
Local cMsgErro		:= ""
Local cMsgSol		:= ""
Local cField		:= ""

Local cPerg			:= 'GTPA115A'
Local cAgencia		:= ""
Local cTipoDoc		:= ""
Local cSerie		:= ""
Local cSubserie		:= ""
Local cCompl		:= ""
Local cNumIni		:= ""
Local cNumFim		:= ""

If Pergunte(cPerg, !IsBlind())

	cAgencia	:= MV_PAR01
	cTipoDoc	:= MV_PAR02
	cSerie		:= MV_PAR03
	cSubserie	:= MV_PAR04
	cCompl		:= MV_PAR05
	cNumIni		:= MV_PAR06
	cNumFim		:= MV_PAR07

	If Empty(cAgencia)
		lRet		:= .F.
		cMsgErro	:= STR0011// "O Código da agência deve ser informado"

	ElseIf !ValidUserAg(,"cAgencia",cAgencia)
		lRet := .F.
	
	ElseIf Empty(cTipoDoc)
		lRet		:= .F.
		cMsgErro	:= STR0012// "O tipo de documento deve ser informado"

	ElseIf Empty(cSerie)
		lRet		:= .F.
		cMsgErro	:= STR0013// "A série deve ser informada"   
	
	ElseIf Empty(cSubSerie)
		lRet		:= .F.
		cMsgErro	:= STR0014// "A subsérie deve ser informada"    

	Endif

	If lRet
		__cAliasTmp := RetSeqCtrl(cAgencia, cTipoDoc, cSerie, cSubSerie, cCompl, cNumIni, cNumFim, lUtil)

		If (__cAliasTmp)->(EoF())
			lRet		:= .F.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
			cMsgErro	:= STR0016// "Sequência de documentos não encontrada"

			(__cAliasTmp)->(DbCloseArea())

		ElseIf oModel:GetOperation() <> MODEL_OPERATION_INSERT
			GIC->(DbGoTo((__cAliasTmp)->GICRECNO))
		Endif

	Endif
Else
	lRet		:= .F.
	cMsgErro	:= "Processo Abortado pelo usuário"
Endif


If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"VldActivate",cMsgErro,cMsgSol)
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} MdlActivate(oModel) 

@type Static Function
@author jacomo.fernandes
@since 28/02/2020
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function MdlActivate(oModel)
Local oMdlGIC 		:= oModel:GetModel("GICMASTER")
Local cAgencia	    := MV_PAR01
Local cTipoDoc	    := MV_PAR02
Local cSerie		:= MV_PAR03
Local cSubSer		:= MV_PAR04
Local cCompl		:= MV_PAR05
Local cTipoBil		:= IIF(MV_PAR08 == 1,'E','M')

If oModel:GetOperation() == MODEL_OPERATION_INSERT

	oMdlGIC:SetValue('GIC_AGENCI'	, cAgencia					)
	oMdlGIC:LoadValue('GIC_TIPDOC'	, cTipoDoc					)
	oMdlGIC:LoadValue('GIC_SERIE'	, cSerie					)
	oMdlGIC:LoadValue('GIC_SUBSER'	, cSubSer					)
	oMdlGIC:LoadValue('GIC_NUMCOM'	, cCompl					)
	oMdlGIC:LoadValue('GIC_BILHET'	, (__cAliasTmp)->GII_BILHET	)
	oMdlGIC:LoadValue('GIC_NUMDOC'	, (__cAliasTmp)->GII_BILHET	)
	oMdlGIC:LoadValue('GIC_TIPO'	, cTipoBil					)

Endif

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} MdlDeActiv

@type Static Function
@author jacomo.fernandes
@since 28/02/2020
@version 1.0
@param oModel, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function MdlDeActiv(oModel)

(__cAliasTmp)->(DbCloseArea())

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} GA115Commit
Realiza a validação do modelo de dados.
@type Static Function
@author Flavio Martins
@since 18/10/2017
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function GA115Commit(oModel)
Local lRet			:= .T.
Local oMdlGIC		:= oModel:GetModel("GICMASTER")
Local nOpc			:= oModel:GetOperation()

Local oMdl115		:= FWLoadModel('GTPA115')
Local oMdlCopia		:= nil

Local aFields   	:= oMdlGIC:GetStruct():GetFields()

Local aErro 		:= {}
Local n1			:= 0

oMdl115:SetOperation(nOpc)

Begin Transaction
	(__cAliasTmp)->(DbGoTop())
	While (__cAliasTmp)->(!Eof())

		If nOpc == MODEL_OPERATION_DELETE
			GIC->(DbGoTo((__cAliasTmp)->GICRECNO))
		Endif
		
		If oMdl115:Activate()
			
			If nOpc == MODEL_OPERATION_INSERT
				oMdlCopia	:=  oMdl115:GetModel('GICMASTER') 
					
				For n1 := 1 to Len(aFields)
					If ( !(aFields[n1][3] $ "GIC_CODIGO|GIC_MOTCAN") )
						oMdlCopia:LoadValue(aFields[n1][3], oMdlGIC:GetValue(aFields[n1][3]) )  
					Endif
				Next 

				oMdlCopia:LoadValue('GIC_BILHET' , (__cAliasTmp)->GII_BILHET )
				oMdlCopia:LoadValue('GIC_NUMDOC' , (__cAliasTmp)->GII_BILHET )

			Endif

			If !(oMdl115:VldData() .and. oMdl115:CommitData())
				lRet	:= .F.
				aErro	:= oMdl115:GetErrorMessage()
			EndIf
		Else
			lRet := .F.
			aErro	:= oMdl115:GetErrorMessage()
		Endif

		oMdl115:DeActivate()

		IF !lRet
			Exit
		EndIf
	
		(__cAliasTmp)->(DbSkip())
	End

	IF !lRet
		DisarmTransaction()
		Break
	EndIf
	
End Transaction

oMdl115:Destroy()

GtpDestroy(oMdl115)

Return lRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} ViewDef
View para geração e exclusão em massa de bilhetes
@type Static Function
@author Flavio Martins
@since 18/10/2017
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FwLoadView("GTPA115")
Local oModel	:= FwLoadModel("GTPA115A")
Local oStrGIC	:= oView:GetViewStruct("VIEW_GIC")

oView:SetModel( oModel )

oStrGIC:SetProperty('GIC_BILHET', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty('GIC_CODIGO', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty('GIC_TIPO'	, MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty('GIC_AGENCI', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty('GIC_STATUS', MVC_VIEW_CANCHANGE, .F.)

Return(oView)

//------------------------------------------------------------------------------
/* /{Protheus.doc} RetSeqCtrl
Retorna um alias com todas as sequencias de documentos válidas de acordo com os parâmetros selecionados
@type Static Function
@author Flavio Martins
@since 23/10/2017
@version 1.0
@param cAgencia, character, (Descrição do parâmetro)
@param cTipoDoc, character, (Descrição do parâmetro)
@param cSerie, character, (Descrição do parâmetro)
@param cSubSerie, character, (Descrição do parâmetro)
@param cCompl, character, (Descrição do parâmetro)
@param cNumIni, character, (Descrição do parâmetro)
@param cNumFim, character, (Descrição do parâmetro)
@param lUtil, character, (Descrição do parâmetro)
@return cAliasTmp, return_description
/*/
//------------------------------------------------------------------------------
Static Function RetSeqCtrl(cAgencia, cTipoDoc, cSerie, cSubSerie, cCompl, cNumIni, cNumFim,lUtil)
Local cAliasTmp	:= GetNextAlias() 

If !lUtil

	BeginSQL Alias cAliasTmp    

		SELECT 
			GII.GII_BILHET
		FROM %Table:GII% GII	
		WHERE
			GII.GII_FILIAL		= %xFilial:GII%
			AND GII.GII_AGENCI	= %Exp:cAgencia%
			AND GII.GII_TIPO	= %Exp:cTipoDoc%
			AND GII.GII_SERIE	= %Exp:cSerie%
			AND GII.GII_SUBSER	= %Exp:cSubSerie%
			AND GII.GII_NUMCOM	= %Exp:cCompl%
			AND GII.GII_BILHET	BETWEEN %Exp:cNumIni% AND %Exp:cNumFim%
			AND GII.GII_UTILIZ	= %Exp:.F.%
			AND GII.%NotDel%
		ORDER BY GII.GII_AGENCI, GII.GII_SERIE, GII.GII_SUBSER, GII.GII_NUMCOM, GII.GII_BILHET

	EndSQL

Else
	BeginSQL alias cAliasTmp
	
		SELECT 
            GIC.R_E_C_N_O_ AS GICRECNO
		FROM %Table:GIC% GIC	
		WHERE 
            GIC.GIC_FILIAL		= %xFilial:GIC%
            AND GIC.GIC_AGENCI	= %Exp:cAgencia%
			AND GIC.GIC_TiPDOC	= %Exp:cTipoDoc%
            AND GIC.GIC_SERIE	= %Exp:cSerie%
            AND GIC.GIC_SUBSER	= %Exp:cSubSerie%
            AND GIC.GIC_NUMCOM	= %Exp:cCompl%
            AND GIC.GIC_NUMDOC	BETWEEN %Exp:cNumIni% AND %Exp:cNumFim%
            AND GIC.%NotDel%

	EndSQL
Endif

Return cAliasTmp
