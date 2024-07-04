#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSAF64.CH'

#DEFINE CODIGO_REPOM	"01"
#DEFINE CODIGO_PAMCARD	"02"

Static lRestRepom := SuperGetMV('MV_VSREPOM',,"1") == "2.2"

//-------------------------------------------------------------------
/*{Protheus.doc} TF64Repom
Validação Repom
@type Function
@author Katia
@since 15/10/2020
@version 12.1.31
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Function TF64Repom( oModel , cCodOpe  )
Local lRet		:= .T. 
Local nOpc		:= 0

Default oModel  := FwModelActive()  
Default cCodOpe	:= ""     

If lRestRepom

	lRet    := VldRepDTR(oModel,cCodOpe)

	nOpc	:= oModel:GetOperation()

	If lRet .And. nOpc == 4 
		lRet	:= TMSC15ARep( 7 , FwFldGet("DTQ_FILORI"), FwFldGet("DTQ_VIAGEM"), .T. )
	EndIf 

EndIf 

Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} VldRepDTR
Validação Repom - Recursos 
@type Static Function
@author Katia
@since 14/08/2020
@version 12.130
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldRepDTR( oModel, cCodOpe )
Local lRet      := .T. 
Local aArea     := GetArea()
Local aAreaDTR  := DTR->(GetArea())
Local aSaveLine	:= FWSaveRows()
Local oMdlDTR   := Nil
Local nCount    := 0 
Local cCodVei   := ""
Local nPerAdi	:= 0
Local cCodRBQ1	:= ""
Local cCodRBQ2	:= ""
Local cCodRBQ3	:= ""
Local cTipCrg	:= ""
Local nVlrPdg	:= 0 
Local cTpSpdg	:= ""
Local nOpc      := 0
Local nQtdEixo  := 0
Local nValFret  := 0

Local nAdtoAux  := 0

Default oModel      := FWModelActive()
Default cCodOpe		:= ""

oMdlDTR := oModel:GetModel("MdGridDTR")
nOpc    := oMdlDTR:GetOperation()

If nOpc == 3 .Or. nOpc == 4
	cTpSpdg		:= FwFldGet("DM5_TPSPDG")

	For nCount := 1 To oMdlDTR:Length()
		oMdlDTR:GoLine(nCount)
		If !oMdlDTR:IsDeleted()
		
			cCodVei     := oMdlDTR:GetValue("DTR_CODVEI")
			nPerAdi		:= oMdlDTR:GetValue("DTR_PERADI")
			cCodRbq1	:= oMdlDTR:GetValue("DTR_CODRB1")
			cCodRbq2	:= oMdlDTR:GetValue("DTR_CODRB2")
			cCodRbq3	:= oMdlDTR:GetValue("DTR_CODRB3")
			nVlrPdg		:= oMdlDTR:GetValue("DTR_VALPDG")
			cTipCrg		:= oMdlDTR:GetValue("DTR_TIPCRG")
			nQtdEixo    := oMdlDTR:GetValue('DTR_QTDEIX')
			nValFret    := oMdlDTR:GetValue('DTR_VALFRE')

			lRet:= VldShipRep(cCodVei,cCodRbq1,cCodRbq2,cCodRbq3)

			If lRet			
				nAdtoAux    := nValFret * nPerAdi
				Iif(nAdtoAux > 0, nAdtoAux := nAdtoAux / 100, nAdtoAux := 0 )

				lRet		:= TF64VlQtd( oMdlDTR:Length(.T.) )
			EndIf

			If lRet
				lRet	:= TF64PerAdi( cCodVei, nPerAdi )
			EndIf

			If lRet
				lRet    := TF64PamSDG(oModel, cCodOpe )  
			EndIf

			
			If lRet
				lRet	:= VldRepDUP(oModel,cCodVei,cCodRbq1, cCodRbq2, cCodRbq3)
			EndIf 

			If !lRet
				Exit
			EndIf 
		EndIf
	Next nCount 
EndIf


FwRestRows(aSaveLine)
RestArea( aAreaDTR )
RestArea( aArea )
Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} VldRepDUP
Valida DUP
@type Static Function
@author Katia
@since 19/08/2020
@version 12.1.30
@param oModel
@return lRet
*/
//-------------------------------------------------------------------
Static Function VldRepDUP(oModel,cCodVei,cCodRbq1, cCodRbq2, cCodRbq3)
Local lRet		:= .T. 
Local aArea		:= GetARea()
Local oMdlDUP	:= Nil
Local nOpc      := 0
Local aAreaDA3  := DA3->(GetArea())

Default oModel	 := FWModelActive()
Default cCodVei	 := ""

oMdlDUP:= oModel:GetModel("MdGridDUP")
nOpc   := oMdlDUP:GetOperation()

cCodMot:= TF64PMotor(oModel)

If !Empty(cCodMot)	

	//--- Atualiza os Cadastros na Repom
	/*If lRet
		RepRetCod(cCodVei, cCodRbq1, cCodRbq2, cCodRbq3, cCodMot, @aCodigos)
		If Len(aCodigos) > 0
			CursorWait()
			MsgRun( "Aguarde comunicação com a Operadora...", "Atualizando dados da Operadora. Por favor Aguarde...", {||  lRet := TMSAtualOp( M->DTR_CODOPE, '5', aCodigos )}) //-- "Aguarde comunicação com a Operadora..."##"Atualizando dados da Operadora. Por favor Aguarde..."
			CursorArrow()
		EndIf
	EndIf*/

Else
	Help('', 1, "TMSAF6408") //Necessário informar um Condutor Principal para a viagem.
	lRet:= .F.
EndIf

RestArea(aAreaDA3)
RestArea(aArea)
Return lRet

//--------------------------------
/*{Protheus.doc} VldShipRep
Validações do Shipping Repom 2.2
@type Static Function
@author Katia
@since 19/11/2020
@version 12.1.31
@return lRet
*/
//----------------------------------
Static Function VldShipRep(cCodVei,cCodRbq1,cCodRbq2,cCodRbq3)
Local lRet    := .T.
Local aForDA3 := {}
Local aMsgErr := {}

Default cCodVei:= ""
Default cCodRbq1:= ""
Default cCodRbq2:= ""
Default cCodRbq3:= ""

If lRestRepom .And. !Empty(cCodVei)
	lRet:= TM15VldVei(cCodVei,@aMsgErr)

	If lRet
		aForDA3:= RetCodForn(cCodVei)
		If Len(aForDA3) > 0 .And. !Empty(aForDA3[1]) .And. !Empty(aForDA3[2])
			lRet:= TM15VldHir(aForDA3[1],aForDA3[2],@aMsgErr)			
		EndIf
	EndIf

	If lRet .And. !Empty(cCodRbq1)
		lRet:= TM15VldVei(cCodRbq1,@aMsgErr)

		If lRet .And. !Empty(cCodRbq2)
			lRet:= TM15VldVei(cCodRbq2,@aMsgErr)
					
			If lRet .And. !Empty(cCodRbq3,@aMsgErr)
				lRet:= TM15VldVei(cCodRbq3)
			EndIf
		EndIf
	EndIf

EndIf

If !lRet
	Help(' ', 1, 'TMSXFUNC18') // "Ocorreram erros ou validações do processo pela Operadora de Frotas e o processo não foi realizado com sucesso."

	If Len(aMsgErr)> 0
		TmsMsgErr( aMsgErr )
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} RetCodForn
Retorna código/loja do proprietario do veiculo
@type Static Function
@author Caio Murakami
@since 14/08/2020
@version 12.1.30
@param cCampo
@return lRet
*/
//------------------------------------------------------------------
Static Function RetCodForn(cCodVei)
Local aAreaDA3	:= DA3->( GetArea() )
Local cCodForn	:= ""
Local cLojForn	:= ""

Default cCodVei	:= ""

DA3->( dbSetOrder(1) )
If DA3->( MsSeek( xFilial("DA3") + cCodVei ))
	cCodForn	:= DA3->DA3_CODFOR
	cLojForn	:= DA3->DA3_LOJFOR
EndIf 

RestArea( aAreaDA3 )
Return { cCodForn , cLojForn } 
