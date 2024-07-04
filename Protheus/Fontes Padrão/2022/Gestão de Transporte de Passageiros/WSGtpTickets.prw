#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSGtpTickets
Métodos WS do GTP para integração de bilhetes em massa.


@author SIGAGTP
@since 02/03/2021
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL GTPTICKETS DESCRIPTION "WS de Integração com Bilhetes"

	WSDATA nQtdBil 				AS INTEGER

	// Métodos POST
	WSMETHOD POST	generateTickets DESCRIPTION 'Gera bilhetes em massa'  PATH "generateTickets" PRODUCES APPLICATION_JSON
	WSMETHOD POST   deletTickets DESCRIPTION 'Exclui bilhetes em massa'  PATH "deletTickets" PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} generateTickets
Efetua a geração em massa de bilhetes com a quantidade solicitada

@author SIGAGTP
@since 02/03/2021
@version 1.0

/*/
//-------------------------------------------------------------------

WSMETHOD POST generateTickets WSREST GTPTICKETS
Local oModel     := Nil
Local lRet       := .T.
Local oRequest   := JSonObject():New()
Local cBody      := Self:GetContent()
Local aNumbers   := {}
Local cAgencia	 := ''
Local cTipoDoc	 := ''
Local cSerie	 := ''
Local cSubSerie  := ''
Local cCompl	 := ''
Local cNumIni    := ''
Local cNumFim    := ''
Local nX		 := 0
Local cOpc		 := 'INCLUI'
Local cMsgError	 := ''
Local cFilSelc   := ''
Local cFilOldS   := cfilant

oRequest:fromJson(cBody)

cAgencia	:= oRequest['cAgencia']
cTipoDoc	:= oRequest['tipoDoc']
cSerie  	:= oRequest['serie']
cSubSerie	:= oRequest['subSerie']
cCompl		:= oRequest['complemento']
cNumIni		:= oRequest['numDocIni']
cNumFim		:= oRequest['numDocFim']
cFilSelc	:= oRequest['filial']

cfilant := cFilSelc

aNumbers := RetSeqCtrl(cAgencia, cTipoDoc, cSerie, cSubSerie, cCompl, cNumIni, cNumFim,cOpc)

If aNumbers == {} .Or. Len(aNumbers) == 0 
	SetRestFault(400, EncodeUtf8("Sequencia de controle de documentos invalida"))
	Return .F.
Endif

Begin Transaction

	If Len(aNumbers) > 0

		oModel := FwLoadModel('GTPA115')

		For nX := 1 To Len(aNumbers)

			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()

			oModel:SetValue('GICMASTER', 'GIC_AGENCI'	, cAgencia)
			oModel:SetValue('GICMASTER', 'GIC_SENTID'	, oRequest['sentido'])
			oModel:SetValue('GICMASTER', 'GIC_TIPO'		, oRequest['tipoBil'])
			oModel:SetValue('GICMASTER', 'GIC_ORIGEM'	, oRequest['origem'])
			oModel:SetValue('GICMASTER', 'GIC_STATUS'	, oRequest['statusBil'])
			oModel:SetValue('GICMASTER', 'GIC_COLAB'	, oRequest['codColab'])
			oModel:SetValue('GICMASTER', 'GIC_LINHA'	, oRequest['codLinha'])
			oModel:SetValue('GICMASTER', 'GIC_CODGID'	, oRequest['horario'])
			oModel:SetValue('GICMASTER', 'GIC_DTVEND'	, StoD(STrTran(oRequest['dtVenda'],'-','')))
			oModel:SetValue('GICMASTER', 'GIC_DTVIAG'	, StoD(STrTran(oRequest['dtViagens'],'-','')))
			oModel:SetValue('GICMASTER', 'GIC_HORA'		, oRequest['cHrsaida'])
			oModel:SetValue('GICMASTER', 'GIC_LOCORI'	, oRequest['locOri'])
			oModel:SetValue('GICMASTER', 'GIC_LOCDES'	, oRequest['locDes'])
			oModel:SetValue('GICMASTER', 'GIC_TIPDOC'	, oRequest['tipoDoc'])
			oModel:SetValue('GICMASTER', 'GIC_SERIE'	, oRequest['serie'])
			oModel:SetValue('GICMASTER', 'GIC_SUBSER'	, oRequest['subSerie'])
			oModel:SetValue('GICMASTER', 'GIC_NUMCOM'	, oRequest['complemento'])
			oModel:SetValue('GICMASTER', 'GIC_NUMDOC'	, aNumbers[nX][2])
			oModel:SetValue('GICMASTER', 'GIC_BILHET'	, aNumbers[nX][2])
			oModel:SetValue('GICMASTER', 'GIC_TAR'		, oRequest['tarifa'])
			oModel:SetValue('GICMASTER', 'GIC_PED'		, oRequest['pedagio'])
			oModel:SetValue('GICMASTER', 'GIC_SGFACU'	, oRequest['segFacul'])
			oModel:SetValue('GICMASTER', 'GIC_TAX'		, oRequest['txEmbarq'])
			oModel:SetValue('GICMASTER', 'GIC_OUTTOT'	, oRequest['outrodTot'])

			If oModel:VldData() .And. oModel:CommitData()

				GII->(dbGoto(aNumbers[nX][1]))

				Reclock("GII", .F.)
				GII->GII_UTILIZ := .T.
				GII->GII_ALIAS	:= 'GIC'
				GII->GII_CHVTAB	:=  xFilial('GIC') +  oModel:GetValue('GICMASTER', 'GIC_CODIGO')
				GIC->(MsUnlock())

			Else
				lRet 	  := .F.	
				cMsgError := oModel:GetErrorMessage()[6]
				Exit
			Endif

			oModel:DeActivate()

		Next

	Endif

	If lRet
		Self:SetResponse('{"retorno": "Bilhetes gerados com sucesso"}')
	Else
		DisarmTransaction()
		SetRestFault(400, EncodeUtf8(cMsgError))
	Endif

End Transaction

cfilant := cFilOldS

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} generateTickets
Efetua a geração em massa de bilhetes com a quantidade solicitada

@author Diego Faustino
@since 12/08/2021
@version 1.0

/*/
//-------------------------------------------------------------------

WSMETHOD POST deletTickets WSREST GTPTICKETS

Local oModel     := Nil
Local lRet       := .T.
Local oRequest   := JSonObject():New()
Local cBody      := Self:GetContent()
Local aTickets   := {}
Local cAgencia	 := ''
Local cTipoDoc	 := ''
Local cSerie	 := ''
Local cSubSerie  := ''
Local cCompl	 := ''
Local cNumIni    := ''
Local cNumFim    := ''
Local nX		 := 0
Local cOpc		 := 'DELETA'
Local cMsgError  := ''
Local cFilSelc   := ''
Local cFilOldS   := cfilant

oRequest:fromJson(cBody)

cAgencia	:= oRequest['cAgencia']
cTipoDoc	:= oRequest['tipoDoc']
cSerie  	:= oRequest['serie']
cSubSerie	:= oRequest['subSerie']
cCompl		:= oRequest['complemento']
cNumIni		:= oRequest['numDocIni']
cNumFim		:= oRequest['numDocFim']
cFilSelc	:= oRequest['filial']

cfilant := cFilSelc

aTickets := RetSeqCtrl(cAgencia, cTipoDoc, cSerie, cSubSerie, cCompl, cNumIni, cNumFim,cOpc)

If aTickets == {} .Or. Len(aTickets) == 0 
	SetRestFault(400, EncodeUtf8("Intervalo de bilhetes nao encontrado."))
	Return .F.
Endif

Begin Transaction

	If Len(aTickets) > 0

		oModel := FwLoadModel('GTPA115')
		oModel:SetOperation(MODEL_OPERATION_DELETE)

		For nX := 1 To Len(aTickets)

			GIC->(DbGoTo(aTickets[nX][1]))

			If oModel:Activate()
				If !(oModel:VldData() .and. oModel:CommitData())
					lRet	  := .F.
					cMsgError := oModel:GetErrorMessage()[6]
				EndIf
			Else
				lRet      := .F.
				cMsgError := oModel:GetErrorMessage()[6]
			Endif

			oModel:DeActivate()

			IF !lRet
				Exit
			EndIf

		Next nX

	Endif

	If lRet
		Self:SetResponse('{"retorno": "Bilhetes excluidos com sucesso"}')
	Else
		DisarmTransaction()
		SetRestFault(400, EncodeUtf8(cMsgError))
	Endif

End Transaction

cfilant := cFilOldS

RETURN lRet

/*/{Protheus.doc} RetSeqCtrl
	(long_description)
	@type  Static Function
	@author user
	@since 12/08/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/

Static Function RetSeqCtrl(cAgencia, cTipoDoc, cSerie, cSubSerie, cCompl, cNumIni, cNumFim, cOpc)
	Local cAliasTmp	:= GetNextAlias()
	Local aRet		:= {}

	Default cAgencia  = ''
	Default cTipoDoc  = ''
	Default cSerie    = ''
	Default cSubSerie = ''
	Default cCompl    = ''
	Default cNumIni   = ''
	Default cNumFim   = ''
	Default cOpc      = ''

	if Alltrim(cOpc) == "INCLUI"

		BeginSQL Alias cAliasTmp

		SELECT 
			GII.GII_BILHET,
			GII.R_E_C_N_O_ As Recno
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

		While (cAliasTmp)->(!Eof())
			AADD(aRet, {(cAliasTmp)->Recno, (cAliasTmp)->GII_BILHET})
			(cAliasTmp)->(dbSkip())
		End
	
	Else
		BeginSQL alias cAliasTmp
	
		SELECT 
            GIC.R_E_C_N_O_ AS GICRECNO
		FROM %Table:GIC% GIC	
		WHERE 
            GIC.GIC_FILIAL		= %xFilial:GIC%
            AND GIC.GIC_AGENCI	= %Exp:cAgencia%
			AND GIC.GIC_TIPDOC	= %Exp:cTipoDoc%
            AND GIC.GIC_SERIE	= %Exp:cSerie%
            AND GIC.GIC_SUBSER	= %Exp:cSubSerie%
            AND GIC.GIC_NUMCOM	= %Exp:cCompl%
            AND GIC.GIC_NUMDOC	BETWEEN %Exp:cNumIni% AND %Exp:cNumFim%
            AND GIC.%NotDel%

		EndSQL

		While (cAliasTmp)->(!Eof()) 
			AADD(aRet, {(cAliasTmp)->GICRECNO})
			(cAliasTmp)->(dbSkip())
		End

	Endif
	
	(cAliasTmp)->(dbCloseArea())

Return aRet

