#INCLUDE "PROTHEUS.CH"
#include "OMSATPR7.CH"

/*/{Protheus.doc} OMSATPR7
** Programa responsavel pelo processamento do callback para atualizacao da Carga
@author Equipe OMS
@since 02/05/2022
/*/
Function OMSATPR7(oIdentifier, cJsonUpd)
	Local cEmpLog 		:= ""
	Local cFilLog 		:= ""
	Local cIdent 		:= ""
	Local cJsonCampo 	:= ""
	Local cErr1 		:= ""
	Local cErr2 		:= ""
	Local cCarga 		:= ""
	Local lRet 			:= .T.
	Local nX 			:= 1
	Local nY 			:= 1
	Local nTotDur 		:= 0
	Local nTotDist 		:= 0
	Local nVlRotPdg 	:= 0
	Local oTpr 			:= Nil
	Local llogTPR		:= Nil
	Local oJsonBco 		:= Nil
	Local oJsonUpd 		:= Nil
	Local oViagemUpd 	:= Nil
	Local oViagem 		:= Nil
	Local oViagemBco 	:= Nil
	Local oSummay 		:= Nil

	OMSTPRCLOG(llogTPR, "OMSATPR7",  STR0001 + STR0006 + cJsonUpd) //"TOTVS Planejamento de Rotas(TPR) - Processo de atualizacao de carga no json iniciado: "

	cEmpLog := AllTrim( oIdentifier["empresa"])
	cFilLog := AllTrim( oIdentifier["filial"])
	cIdent := oIdentifier["identifier"]

	llogTPR := SuperGetMV("MV_TPRCLOG",.F.,.T.)

	DLU->(DbSetOrder(2))
	If DLU->(DbSeek(FwXFilial("DLU")+FwXFilial("DMR")+"DMR"+cIdent))
		cJsonCampo := DLU->DLU_RETORN
	Else
		lRet := .F.
		OMSTPRCLOG(llogTPR, "OMSATPR7",  STR0001 + STR0002 + cValToChar(cIdent)) //"TOTVS Planejamento de Rotas(TPR) - "Roteirizacao nao encontrada com o id: "
	EndIf

	If lRet
		oJsonBco := JSonObject():New()
		cErr1  := oJsonBco:fromJson(cJsonCampo)
		IIf(!Empty(cErr1), lRet := .F., lRet := .T.)
		OMSTPRCLOG(llogTPR, "OMSATPR7",  STR0001 + STR0003 + cValToChar(cErr1)) //"OMSATPR7 - Existe erro ao converter o json obtido do banco de dados? Variável com os erros igual a: "    

		oJsonUpd := JSonObject():New()
		cErr2  := oJsonUpd:fromJson(cJsonUpd)
		IIf(!Empty(cErr2), lRet := .F., lRet := .T.)
		OMSTPRCLOG(llogTPR, "OMSATPR7",  STR0001 + STR0004 + cValToChar(cErr2)) //"OMSATPR7 - Existe erro ao converter o json obtido na integracao de atualizacao? Variavel os erros igual a : "  
	
		oSummay    := oJsonBco:GetJSonObject("summary")
		nTotDur    := oSummay:GetJSonObject("totalDuration")
		nTotDist   := oSummay:GetJSonObject("totalDistance")
		aTripUpd   := oJsonUpd:GetJSonObject("tripResults")
		aTripResBc := oJsonBco:GetJSonObject("tripsResults")

		If !Empty(aTripUpd)
			For nX := 1 to Len(aTripUpd)
				oViagemUpd := aTripUpd[nX]
				oViagem := oViagemUpd["trip"]
				For nY := 1 to Len(aTripResBc)
					oViagemBco := aTripResBc[nY]
					If oViagem["sequential"] == oViagemBco["sequential"]
						nTotDur  := nTotDur - oViagemBco["duration"] + oViagem["duration"]
						nTotDist := nTotDist - oViagemBco["distance"] + oViagem["distance"]
						nVlRotPdg := oViagem["tollValue"]
						aTripResBc[nY] := oViagemUpd["trip"]
					Exit
					EndIf
				Next nY

				DMS->(DbSetOrder(1))
				If DMS->(DbSeek(FwXFilial("DMS")+cIdent))
					While DMS->(!Eof()) .And. DMS->DMS_FILIAL ==  FwXFilial("DMS") .And.;
						  (DMS->DMS_FILROT + DMS->DMS_IDROT) == cIdent
						If oViagem["sequential"] == DMS->DMS_SEQROT
							cCarga := RTrim(SubStr( DMS->DMS_CHVEXT , TamSX3('DMS_FILIAL')[1]+1 ))
							exit
						EndIf
						DMS->(DbSkip())
					EndDo
				EndIf

				cDurRot := OMSMiliseg( oViagem["duration"], 1)

				DAK->(DbSetOrder(1))
				If DAK->(DbSeek(xFilial("DAK") + RTrim(cCarga)))
					Reclock("DAK",.F.)
					DAK->DAK_DISROT := Round( oViagem["distance"], TamSX3("DAK_DISROT")[2] )
					DAK->DAK_TIMROT := cDurRot
					DAK->DAK_VALROT := nVlRotPdg
					DAK->(MsUnlock())
				EndIf

				OMSUpdDAI(oViagem:GetJSonObject("stops"),cCarga)

			Next nX
			oSummay["totalDuration"] := nTotDur
			oSummay["totalDistance"] := nTotDist
			oJsonBco["summary"] 	 := oSummay
		EndIf

		OMSTPRCLOG(llogTPR, "OMSATPR7",  STR0001 + STR0005 + cIdent) //"TOTVS Planejamento de Rotas(TPR) - "Atualizando DLU com a chave DMR: "
		oTpr := TMSBCATPRNeolog():New()	
		oTpr:UpdateDLU( FwXFilial("DMR") , "DMR" , cIdent , "Routing", , "OMSATPR7", oJsonBco:toJson() )
		OMSTPRCLOG(llogTPR, "OMSATPR7",  STR0001 + STR0007 + oJsonBco:toJson()) //"TOTVS Planejamento de Rotas(TPR) - "Processo de atualizacao de carga no json finalizado: "

	EndIf

Return lRet





