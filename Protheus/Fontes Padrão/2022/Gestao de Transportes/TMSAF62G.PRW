#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static lTMS3GFE := TmsIntGFE('02')
Static cTMSOPdg := SuperGetMV( 'MV_TMSOPDG',, '0' )

/*{Protheus.doc} TMSAF62G
Valida campos da viagem modelo 3 x Integração TMS x GFE
@type Function
@author Katia
@since 10/08/2020
@param Origem, Campo, Model
@return lRet
*/
Function TMSAF62G(cOrigem,cCampo)
Local lRet       := .T.

Default cOrigem := ""
Default cCampo  := ReadVar()

If cOrigem == "DTQ"
	lRet := VldDTQGFE(cCampo)
ElseIf cOrigem == "DM8"
	lRet := ValidDM8(cCampo)
ElseIf cOrigem == "DJN"
	lRet := ValidDJN(cCampo)
EndIf

Return lRet

/*{Protheus.doc} VldDTQGFE
Valida campos da DTQ referente a Integração TMS x GFE
@type Static Function
@author Katia
@since 10/08/2020
@version version
@param cCampo, Model
@return lRet
*/
Static Function VldDTQGFE(cCampo)
Local lRet       := .T.

Default cCampo     := ReadVar()

If AllTrim(cCampo) $ "M->DTQ_PAGGFE"
	lRet := VldPagGFE()
ElseIf AllTrim(cCampo) $ "M->DTQ_CDMUNO"
	lRet := VldCdMunO()	
EndIf

Return lRet

/*{Protheus.doc} ValidDM8
Valida campos da DM8
@type Static Function
@author Katia
@since 10/08/2020
@version version
@param cCampo, Model
@return lRet
*/
Static Function ValidDM8(cCampo)
Local lRet       := .T.

Default cCampo   := ReadVar()

If "DM8_CDMUNO" $ cCampo 
	lRet:= ExistCpo("CC2",FwFldGet("DM8_UFORI")+M->DM8_CDMUNO) 
ElseIf "DM8_CDMUND" $ cCampo
	lRet:= ExistCpo("CC2",FwFldGet("DM8_UFDES")+M->DM8_CDMUND)
EndIf

Return lRet

/*{Protheus.doc} ValidDJN
Valida campos da DJN
@type Static Function
@author Katia
@since 10/08/2020
@version version
@param cCampo, Model
@return lRet
*/
Static Function ValidDJN(cCampo)
Local lRet       := .T.
Local aAreaSA2   := SA2->(GetArea())

Default cCampo   := ReadVar()

If cCampo $ "M->DJN_CODFOR|M->DJN_LOJFOR" 
	If !Empty(FwFldGet('DJN_CODFOR')) .And. !Empty(FwFldGet('DJN_LOJFOR'))
		SA2->(DbSetOrder(1))								
		If SA2->(MsSeek(xFilial("SA2")+FwFldGet('DJN_CODFOR')+FwFldGet('DJN_LOJFOR')))
			If SA2->A2_PAGGFE <> StrZero(1,Len(SA2->A2_PAGGFE)) //Sim
				Help(' ', 1, 'TMSA14441') //"Permitido informar somente os Fornecedores configurados com Pagamento pelo SIGAGFE.
				lRet:= .F.
			EndIf
		Else
			lRet:= .F.
		EndIf
	EndIf

ElseIf cCampo $ "M->DJN_CDMUNO"
	lRet:= ExistCpo("CC2",FwFldGet("DJN_UFORI")+M->DJN_CDMUNO)

ElseIf cCampo $ "M->DJN_CDMUND"
	lRet:= ExistCpo("CC2",FwFldGet("DJN_UFDES")+M->DJN_CDMUND)

EndIf

RestArea(aAreaSA2)
FwFreeArray(aAreaSA2)
Return lRet

/*{Protheus.doc} VldPagGFE
Valida campo de Pagamento GFE 
@type Static Function
@author Katia
@since 10/08/2020
@version version
@param Nulo
@return lRet
*/
Static Function VldPagGFE()
Local lRet:= .T.

If cTMSOPdg <> '0'
	If M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE)) .And. !Empty(FwFldGet('DM5_CODOPE')) //Sim
		Help(" ",1,"TMSA24091")   //Pagamento da viagem via SIGAGFE. Não é permitido informar a Operadora de Frotas.  
		lRet:= .F.
	EndIf
EndIf

Return lRet

/*{Protheus.doc} VldCdMunO
Valida Municipio de Origem
@type Static Function
@author Katia
@since 10/08/2020
@version version
@param Nulo
@return lRet
*/
Static Function VldCdMunO()
Local lRet:= .T.

lRet:= Vazio() .Or. ExistCpo("CC2",M->DTQ_UFORI+M->DTQ_CDMUNO)  

Return lRet
