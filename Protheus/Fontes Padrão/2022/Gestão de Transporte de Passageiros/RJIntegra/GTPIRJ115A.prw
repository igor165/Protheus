#Include "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ115A.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ115A

Adapter REST da rotina de BILHETE (Venda2)

@type 		function
@sample 	GTPIRJ115A()
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	jacomo.fernandes
@since 		25/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ115A(lJob)

Local aArea   := GetArea() 
Local lRet    := .T.
Local cEmpRJ  := nil
Local dDtIni  := nil
Local cHrIni  := nil
Local dDtFim  := nil
Local cHrFim  := nil
Local cAgeIni := nil
Local cAgeFim := nil
Default lJob  := .F. 

If Pergunte('GTPIRJ115A',!lJob)
    cEmpRJ  := MV_PAR01
    dDtIni  := MV_PAR02
    cHrIni  := MV_PAR03
    dDtFim  := MV_PAR04
    cHrFim  := MV_PAR05
	cAgeIni := MV_PAR06
	cAgeFim := MV_PAR07
    
    FwMsgRun( , {|oSelf| lRet := GI115AReceb(lJob, oSelf, cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim,cAgeIni,cAgeFim)}, , STR0001)		// "Processando registros de Bilhetes... Aguarde!" 
Endif

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI115AReceb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI115AReceb(cRestResult, oMessage)
@param 		oRJIntegra, objeto - classe que trata da integração
			oMessage, objeto   - trata a mensagem apresentada em tela
@return 	lRet, logical      - resultado do processamento da rotina (.T. / .F.)
@author 	jacomo.fernandes
@since 		29/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI115AReceb(lJob, oMessage, cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, cAgeIni, cAgeFim)

Local oRJIntegra  := GtpRjIntegra():New()
//Local oModel	  := FwLoadModel("GTPA115")
//Local oMdlGIC	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GIC_FILIAL", "GIC_CODIGO"}
Local cIntID	  := ""
Local cIntAux	  := ""
Local cExtID	  := ""
Local cNumBpe     := ""
Local cCode		  := ""
Local cErro		  := ""
Local cTagName    := ""
Local cCampo      := ""
Local cTipoCpo    := ""
Local xValor      := ""
Local nX          := 0
Local nY          := 0
Local nOpc		  := 0
Local nPos        := 0
Local nTotReg     := 0
Local lOk		  := .F.
Local lRet        := .T.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'

Local cHrProc        := Time()

Default cEmpRJ    := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt)
Default dDtIni    := dDataBase-1
Default cHrIni    := '0000'
Default dDtFim    := dDataBase-1
Default cHrFim    := '2359'
Default cAgeIni   := ''
Default cAgeFim   := ''

oRJIntegra:SetPath("/bilhete/venda2")
oRJIntegra:SetServico('BuscaBPE')

oRJIntegra:SetParam('empresa'		 , AllTrim(cEmpRJ))
oRJIntegra:SetParam('dataHoraInicial', SubStr(DtoS(dDtIni), 3) + cHrIni)
oRJIntegra:SetParam('dataHoraFinal'	 , SubStr(DtoS(dDtFim), 3) + cHrFim)


If !Empty(cAgeIni)
	oRJIntegra:SetParam('agenciaInicio', AllTrim(cAgeIni))
Endif
If !Empty(cAgeFim)
	oRJIntegra:SetParam('agenciaFim', AllTrim(cAgeFim))
Endif


aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

oRJIntegra:oGTPLog:SetText("Inicio: "+cHrProc)
If oRJIntegra:Get()
    
    oRJIntegra:oGTPLog:SetText("Tempo de Busca RjIntegra: "+ElapTime(cHrProc, Time()) )

	GIC->(DbSetOrder(1))	// GIC_FILIAL+GIC_CODIGO
	nTotReg := oRJIntegra:GetLenItens()
	For nX := 0 To nTotReg
		lContinua := .T.
		If lMessage .And. !lJob
			oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Bilhetes - #1/#2... Aguarde!" 
			ProcessMessages()
		EndIf
		
		cExtID	:= oRJIntegra:GetJsonValue(nX, 'idTransacao', 'C')
		cNumBpe := oRJIntegra:GetJsonValue(nX, 'numerobpe'	, 'C')
		
		If !Empty(cNumBpe) .And. !Empty(cExtID)
		  	cCode := GTPxRetId("TotalBus", "GIC", "GIC_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
			If lOk .And. GIC->(DbSeek(xFilial('GIC') + cCode))
				nOpc := MODEL_OPERATION_UPDATE
			Else
				lContinua := .F.
				oRJIntegra:oGTPLog:SetText(cErro)
			EndIf

			If lContinua
				//oModel:SetOperation(nOpc)
				//If oModel:Activate()
					//oMdlGIC := oModel:GetModel("GICMASTER")
                    GIC->(RecLock('GIC',.F.))
					For nY := 1 To Len(aFldDePara)
						// recuperando a TAG e o respectivo campo da tabela 
						cTagName    := aFldDePara[nY][1] 
						cCampo      := aFldDePara[nY][2]
						cTipoCpo    := aFldDePara[nY][3]
						lOnlyInsert := aFldDePara[nY][6]
						lOverWrite  := aFldDePara[nY][7]
						
						// recuperando através da TAG o valor a ser inserido no campo 
						If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo)))
							
							// verificando a necessidade de realizar o DePara XXF
							If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
								xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
							EndIf

							If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(GIC->&(cCampo))//Empty(oMdlGIC:GetValue(cCampo)) 
                                //lContinua := oRJIntegra:SetValue(oMdlGIC, cCampo, xValor)
                                GIC->&(cCampo)  := xValor
							ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
                                //lContinua := oRJIntegra:SetValue(oMdlGIC, cCampo, xValor)
                                GIC->&(cCampo)  := xValor
							EndIf
							
							If !lContinua 
								//oRJIntegra:oGTPLog:SetText(I18N(STR0003, {cCampo, GTPXErro(oModel)}))		// "Falha ao gravar o valor do campo #1 (#2)." 
								Exit	
							EndIf
						EndIf
					Next nY
					
					If lContinua
                        //lContinua := oRJIntegra:SetValue(oMdlGIC, "GIC_INTEGR", '1', .T.)
                        GIC->GIC_INTEGR := '1'
					EndIf
					GIC->(MsUnlock())
					If !lContinua 
						//Exit
					Else
                        /* 
                        If (lContinua := oModel:VldData())
							oModel:CommitData()
						Else
							oRJIntegra:oGTPLog:SetText(I18N(STR0004, {GTPXErro(oModel)}))		// "Falha ao gravar os dados (#1)." 
                        EndIf 
                        */
					EndIf
					//oModel:DeActivate()
				//Else
					//oRJIntegra:oGTPLog:SetText(I18N(STR0005, {GTPXErro(oModel)}))		// "Falha ao corregar modelos de dados (#1)." 
					//Exit
				//EndIf
			EndIf
		EndIf
    Next nX
    
Else
	oRJIntegra:oGTPLog:SetText(I18N(STR0006, {oRJIntegra:GetLastError()}))		// "Falha ao processar o retorno do serviço (#1)." 
EndIf

oRJIntegra:oGTPLog:SetText("Tempo de processamento total: "+ElapTime(cHrProc, Time()) )

If !lJob .And. oRJIntegra:oGTPLog:HasInfo() 
	oRJIntegra:oGTPLog:ShowLog()
	lRet := .F.
ElseIf !lJob .And. !oRJIntegra:oGTPLog:HasInfo()
	If lMessage 
		oMessage:SetText(STR0007)		// "Processo finalizado." 
		ProcessMessages()
	Else
		Alert(STR0007)		// "Processo finalizado."
	EndIf	
EndIf

oRJIntegra:Destroy()
//GTPDestroy(oModel)
//GTPDestroy(oMdlGIC)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI115AJob

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI115AJob(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jacomo.fernandes
@since 		28/03/2019
@version 	1.0
/*/
//GI115AJob({'10',STOD('20190326'),'0000',STOD('20190326'),'2359'})
//------------------------------------------------------------------------------------------
Function GI115AJob(aParam)

Local nPosEmp := IF(Len(aParam) > 7, 8, IF(Len(aParam) > 5, 6, 1))
Local nPosFil := IF(Len(aParam) > 7, 9, IF(Len(aParam) > 5, 7, 2))

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[nPosEmp],aParam[nPosFil])
If Len(aParam) == 9
	GI115AReceb(.T., Nil, aParam[1], STOD(aParam[2]), aParam[3], STOD(aParam[4]), aParam[5], aParam[6], aParam[7])
ElseIf Len(aParam) == 7
	GI115AReceb(.T., Nil, aParam[1], STOD(aParam[2]), aParam[3], STOD(aParam[4]), aParam[5])
Else
	GTPIRJ115(.T.)
EndIf

RpcClearEnv()

Return
