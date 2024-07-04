#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static lTMS3GFE := TmsIntGFE('02')
Static lTmsRdpU := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho

/*{Protheus.doc} TMSAF61
Valida when dos campos da viagem modelo 3
@type Static Function
@author Valdemar Roberto Mognon
@since 15/06/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function TMSAF61(cOrigem)
Local lRet := .T.

Default cOrigem := ""

If cOrigem == "DTQ"
	lRet := WhenDTQ()
ElseIf cOrigem == "DM3"
	lRet := WhenDM3()
ElseIf cOrigem == "DTR"
	lRet := WhenDTR()
ElseIf cOrigem == "DUP"
	lRet := WhenDUP()
ElseIf cOrigem == "DVW"
	lRet := WhenDVW()
ElseIf cOrigem == "DM4"
	lRet := WhenDM4()
ElseIf cOrigem == "DM5"
	lRet := WhenDM5()	
EndIf

Return lRet

/*{Protheus.doc} WhenDTQ
Executa o when dos campos da DTQ
@type Static Function
@author Valdemar Roberto Mognon
@since 07/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function WhenDTQ(cOrigem)
Local lRet       := .T.
Local cCampo     := ReadVar()
Local oModel     := FwModelActive()
Local oModelDTQ  := oModel:GetModel("MdFieldDTQ")

Default cOrigem  := "DTQ"

If AllTrim(cCampo) $ "M->DTQ_SERTMS|M->DTQ_TIPTRA"
	lRet := WheSerTMS(oModelDTQ)
ElseIf  cCampo $ 'M->DTQ_PAGGFE|M->DTQ_TIPVEI|M->DTQ_CDTPOP|M->DTQ_CDCLFR|M->DTQ_UFORI|M->DTQ_CDMUNO|M->DTQ_CEPORI|M->DTQ_UFDES|M->DTQ_CDMUND|M->DTQ_CEPDES';
	.And. (lTMS3GFE .Or. lTmsRdpU) 
	lRet := TMSAF61G(cOrigem,oModel)
ElseIf AllTrim(cCampo) $ "M->DTQ_TPOPVG"	
	lRet := WheTpOpVg(oModelDTQ)
EndIf

Return lRet

/*{Protheus.doc} WhenDM3
Executa o when dos campos da DM3
@type Static Function
@author Valdemar Roberto Mognon
@since 07/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WhenDM3()
Local lRet       := .T.
Local cCampo     := ReadVar()
Local oModel     := FwModelActive()
Local oModelDM3  := oModel:GetModel("MdGridDM3")

If AllTrim(cCampo) $ "M->DM3_FILDOC:M->DM3_DOC:M->DM3_SERIE"
	lRet := WheDocto(oModelDM3)
ElseIf AllTrim(cCampo) $ "M->DM3_ORIGEM"
	lRet := WheOrigem(oModelDM3)
EndIf

Return lRet

/*{Protheus.doc} WhenDTR
Executa o when dos campos da DTR
@type Static Function
@author Valdemar Roberto Mognon
@since 07/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WhenDTR()
Local lRet       := .T.
Local cCampo     := ReadVar()
Local aArea      := GetArea()
Local oModel     := FwModelActive()
Local oModelIDTR := oModel:GetModel("MdGridDTR")

If cCampo $'M->DTR_CODRB2'
	lRet := !Empty(oModelIDTR:GetValue('DTR_CODRB1'))
EndIf

If cCampo $'M->DTR_CODRB3'
	lRet := !Empty(oModelIDTR:GetValue('DTR_CODRB2'))
EndIf

//Reboque somente para Veiculo da Categoria 2=Cavalo ou 3=Especial
If lRet .And. cCampo $ 'M->DTR_CODRB1;M->DTR_CODRB2;M->DTR_CODRB3'
	lRet:= TF61VldVei(oModelIDTR:GetValue("DTR_CODVEI"),"C")
EndIf

If lRet .And. cCampo $ "M->DTR_VALRB1"
	lRet:= !TF61VldVei(oModelIDTR:GetValue("DTR_CODRB1"),"F")
EndIf

If lRet .And. cCampo $ "M->DTR_VALRB2"
	lRet:= !TF61VldVei(oModelIDTR:GetValue("DTR_CODRB2"),"F")
EndIf

If lRet .And. cCampo $ "M->DTR_VALRB3"
	lRet:= !TF61VldVei(oModelIDTR:GetValue("DTR_CODRB3"),"F")
EndIf

If lRet .And. cCampo $ "M->DTR_PRCTRA;M->DTR_CIOT"
	lRet := Empty(M->DM5_CODOPE)
EndIf

If lRet .And. (cCampo $ "M->DTR_CNPJOP;M->DTR_CNPJPG") 
	lRet := .F.
EndIf

If lRet .And. (cCampo $ "M->DJA_DTIVSG") 
	lRet := !Empty(FwFldGet("DJA_LIBSEG"))
EndIf

If lRet .And. (cCampo $ "M->DJA_DTFVSG") 
	lRet := !Empty(FwFldGet("DJA_DTIVSG"))
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return lRet

/*{Protheus.doc} WhenDUP
Executa o when dos campos da DUP
@type Static Function
@author Valdemar Roberto Mognon
@since 07/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function WhenDUP()
Local lRet := .T.
Local cCampo    := ReadVar()

//--- Nessa nova versao definido que os Campos serão informados somente na tabela DLD
If M->DM5_CODOPE == '02' 
	If cCampo $ "M->DUP_IDOPE|M->DUP_FORPAG|M->DUP_QTDSAQ|M->DUP_TPSPDG|M->DUP_QTDTRA|M->DUP_FORADT"
		If FwFldGet('DUP_CONDUT') == "1"  //Principal
			lRet:= .F.
		EndIf
	EndIf
EndIf	

Return lRet

/*{Protheus.doc} WheDocto
Executa o when dos campos M->DM3_FILDOC, M->DM3_DOC, M->DM3_SERIE
@type Static Function
@author Valdemar Roberto Mognon
@since 24/06/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function WheDocto(oModelDM3)
Local lRet := .T.

Default oModelDM3 := Nil

lRet := FwFldGet("DM3_STATUS") == StrZero(1,Len(DUD->DUD_STATUS))

Return lRet

/*{Protheus.doc} TF61VldVei
Valida o Tipo do Veiculo Veiculo 
@type Static Function
@author Katia
@since 06/07/2020
@version version
@lRet
*/
Function TF61VldVei(cCodVei,cValid)
Local lRet	   := .T.
Local aAreaDA3 := DA3->(GetArea())
Local aAreaDUT := DUT->(GetArea())

Default cCodVei := ""
Default cValid  := "F"  //Valida "C"ategoria do Veiculo ou "F"rota Veiculo

	DA3->(DbSetOrder(1))
	If DA3->(MsSeek( xFilial('DA3') + cCodVei ))
		If cValid == "C"
			DUT->(dbSetOrder(1))
			If DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
				lRet := (DUT->DUT_CATVEI == '2' .Or. DUT->DUT_CATVEI == '4')
			EndIf					
		Else 
			lRet:= DA3->DA3_FROVEI == StrZero(1, Len(DA3->DA3_FROVEI))
		EndIf
	EndIf	

RestArea(aAreaDA3)
RestArea(aAreaDUT)
FwFreeArray(aAreaDA3)
FwFreeArray(aAreaDUT)
Return lRet

/*{Protheus.doc} WheSerTMS
Executa o when dos campos M->DTQ_SERTMS / M->DTQ_TIPTRA
@type Static Function
@author Valdemar Roberto Mognon
@since 22/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function WheSerTMS(oModelDTQ)
Local lRet := .T.

Default oModelDTQ := Nil

lRet := oModelDTQ:GetOperation() == 3 .And. Empty(FwFldGet("DTQ_ROTA"))

Return lRet


/*{Protheus.doc} WhenDVW
Executa o when dos campos da DVW
@type Static Function
@author Katia	
@since 23/07/2020
@version version
*/
Static Function WhenDVW()
Local lRet := .T.
Return lRet


/*{Protheus.doc} WhenDM4
Executa o when dos campos da DM4
@type Static Function
@author Katia	
@since 29/07/2020
@version version
*/
Static Function WhenDM4()
Local lRet := .T.
Return lRet

/*{Protheus.doc} WhenDM5
Executa o when dos campos da DM5
@type Static Function
@author Katia	
@since 29/07/2020
@version version
*/
Static Function WhenDM5()
Local lRet   := .T.
Local cCampo := ReadVar()

If cCampo $ "M->DM5_PRCTRA"
	lRet := Empty(M->DM5_CODOPE)
EndIf	

Return lRet

/*{Protheus.doc} WheTpOpVg
Executa o when dos campos M->DTQ_TPOPVG
@type Static Function
@author Katia
@since 17/09/2020
@version version
@param Tipo Operacao
@return lRet
*/
Static Function WheTpOpVg(oModelDTQ)
Local lRet := .T.

Default oModelDTQ := Nil

If oModelDTQ:GetOperation() == 4 .And.  oModelDTQ:GetValue("DTQ_STATUS") <> StrZero(1,Len(DTQ->DTQ_STATUS)) 
	lRet:= .F.
EndIf

Return lRet

/*{Protheus.doc} WheOrigem
Executa o when do campo M->DM3_ORIGEM
@type Static Function
@author Valdemar Roberto Mognon
@since 22/06/2021
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function WheOrigem(oModelDM3)
Local lRet      := .T.
Local lCarAut   := .T.
Local aAreas    := {GetArea()}
Local cQuery    := ""
Local cAliasDUD := ""
Local cPerg     := "TMSAF60"

Default oModelDM3 := Nil

//-- Analisa o carregamento automático
Pergunte(cPerg,.F.)
If ExistFunc("TmsAutViag")
	If TmsAutViag(FwFldGet("DTQ_FILORI"),FwFldGet("DTQ_VIAGEM"),FwFldGet("DTQ_CODAUT"),"TMSAF90")
		lCarAut := .T.
	Else
		lCarAut := MV_PAR01 != 1
	EndIf
Else
	lCarAut := MV_PAR01 != 1
EndIf

lRet := lCarAut

//-- Analisa se existe manifesto para a viagem/documento
If lRet
	cAliasDUD := GetNextAlias()
	cQuery := "SELECT DUD.DUD_MANIFE,DUD.DUD_FILDOC,DUD.DUD_DOC,DUD.DUD_SERIE,DTX.DTX_VIAGEM,DTX.DTX_IDIMDF "
	cQuery += "  FROM " + RetSQLName("DUD") + " DUD "

	cQuery += " INNER JOIN " + RetSQLName("DTX") + " DTX "
	cQuery += "    ON DTX.DTX_FILIAL = '" + xFilial("DTX") + "' "
	cQuery += "   AND DTX.DTX_FILORI = DUD.DUD_FILORI "
	cQuery += "   AND DTX.DTX_VIAGEM = DUD.DUD_VIAGEM "
	cQuery += "   AND DTX.DTX_FILMAN = '" + cFilAnt  + "' "
	cQuery += "   AND DTX.DTX_TIPMAN = '2' "
	cQuery += "   AND DTX.DTX_IDIMDF = '100' "
	cQuery += "   AND DTX.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += "   AND DUD.DUD_FILDOC = '" + FwFldGet("DM3_FILDOC") + "' "
	cQuery += "   AND DUD.DUD_DOC    = '" + FwFldGet("DM3_DOC")    + "' "
	cQuery += "   AND DUD.DUD_SERIE  = '" + FwFldGet("DM3_SERIE")  + "' "
	cQuery += "   AND DUD.DUD_FILORI = '" + FwFldGet("DTQ_FILORI") + "' "
	cQuery += "   AND DUD.DUD_VIAGEM = '" + FwFldGet("DTQ_VIAGEM") + "' "
	cQuery += "   AND DUD.DUD_MANIFE <> ' ' "
	cQuery += "   AND DUD.D_E_L_E_T_ =  ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUD,.F.,.T.)		
		
	If (cAliasDUD)->(!Eof())
		lRet := .F.
	EndIf
	(cAliasDUD)->(DbCloseArea())
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet
