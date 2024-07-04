#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} TMSAF65G
Rotina de Gatilhos da Viagem Modelo 3 - Integração TMS x GFE
@type Function
@author Katia
@since 10/08/2020
@version 12.1.30
@param param, param_type, param_descr
@return lRet
*///-------------------------------------------------------------------
Function TMSAF65G(cCampo,cDest,cFilDoc,cDoc,cSerie)
Local xRet      := Nil

Default cCampo  := ReadVar()
Default cDest   := ""
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""


If cCampo $ "M->DTQ_PAGGFE" 
	xRet:= TF65PagGfe(cCampo,cDest)

ElseIf cCampo == "DM8_DOC"  //Executado pelo gatilho do Documento TMSAF65GAT()
	If M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))
		xRet:= TF65GatDM8(cFilDoc,cDoc,cSerie)
	EndIf

ElseIf cCampo $ "M->DTQ_CDTPOP"
	TF65PagGfe(cCampo,cDest,.T.)  //.T. Atualiza somente o campo na grid
	xRet:= Posicione("GV4",1,xFilial("GV4")+M->DTQ_CDTPOP,"GV4_DSTPOP")                                                                        

ElseIf cCampo $ "M->DTQ_CDCLFR"	
	TF65PagGfe(cCampo,cDest,.T.)  //.T. Atualiza somente o campo na grid
	xRet:= Posicione("GUB",1,xFilial("GUB")+M->DTQ_CDCLFR,"GUB_DSCLFR")

ElseIf cCampo $ "M->DTQ_TIPVEI"  
	TF65PagGfe(cCampo,cDest,.T.)  //.T. Atualiza somente o campo na grid
	xRet:= Posicione("DUT",1,xFilial("DUT")+M->DTQ_TIPVEI,'DUT_DESCRI')

EndIf

Return xRet 

//---------------------------------------------------------
/*{Protheus.doc} TF65PagGfe
Gatilhos do campo DTQ_PAGGFE
@type Function
@author Katia
@since 10/08/2020
@version 12.1.30
@param param, param_type, param_descr
@return lRet
*///-------------------------------------------------------------------
Function TF65PagGfe(cCampo,cDest,lOnlyCmp)
Local xRet      := M->DTQ_PAGGFE
Local nLinha    := 0
Local oModel    := FWModelActive()
Local oMdGridDM3:= oModel:GetModel("MdGridDM3")
Local aSaveLines:= FWSaveRows()

Default lOnlyCmp:= .F.   //Indica que atualizara somente um determinado campo na Grid do Docto

	For nLinha:=1 To oMdGridDM3:Length()
		oMdGridDM3:GoLine(nLinha)
		If !oMdGridDM3:IsDeleted() 	
			If !Empty(FwFldGet("DM3_FILDOC")) .And. !Empty(FwFldGet("DM3_DOC")) .And. !Empty(FwFldGet("DM3_SERIE"))
				If FwFldGet("DM3_STATUS") == StrZero(1,Len(DUD->DUD_STATUS)) 
					TF65GatDM8(FwFldGet('DM3_FILDOC'),FwFldGet('DM3_DOC'),FwFldGet('DM3_SERIE'),oModel,lOnlyCmp,cCampo)
				EndIf
			EndIf	
		EndIf
	Next nLinha	

FWRestRows( aSaveLines )
Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TF65GatDM8
Gatilho de campos da DM8
@type Function
@author Katia
@since 10/08/2020
@version 12.1.30
@param param, param_type, param_descr
@return lRet
Função extraída do fonte TMSA210 (Tmsa210GFE)
/*/
//-------------------------------------------------------------------
Function TF65GatDM8(cFilDoc,cDoc,cSerie,oModel,lOnlyCmp,cCampo)
Local cCdrOri	:= ""
Local cCdrDes	:= ""
Local cUfDes	:= Criavar("DUD_UFDES")
Local cCdMunD	:= Criavar("DUD_CDMUND")
Local cCEPDes	:= ""
Local cSeekDTC  := ""
Local oMdGridDM8:= Nil
Local aAreas    := {DT6->(GetArea()),DUY->(GetArea()),DTC->(GetArea()),DUL->(GetArea()),SA1->(GetArea()),GetArea()}

Default oModel  := FWModelActive()
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default lOnlyCmp:= .F.  //Indica que atualizara somente um determinado campo na Grid do Docto
Default cCampo  := ""

oMdGridDM8:= oModel:GetModel("MdGridDM8")

If M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))			
	DT6->(DbSetOrder(1))
	If DT6->(dbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
		oMdGridDM8:SetNoUpdateLine(.F.)
		If !lOnlyCmp		
			//---------- Estado e Municipio de Origem do Documento		
			If M->DTQ_FILORI == DT6->DT6_FILDOC
				cCdrOri:= DT6->DT6_CDRORI
			Else
				cCdrOri:= PadR(SuperGetMv('MV_CDRORI'),Len(DA8->DA8_CDRORI))
			EndIf
					
			DUY->(DbSetOrder(1))
			If DUY->(MsSeek(xFilial("DUY")+cCdrOri))
				oMdGridDM8:SetValue('DM8_UFORI' , DUY->DUY_EST )
				oMdGridDM8:SetValue('DM8_CDMUNO', DUY->DUY_CODMUN)
			EndIf	
				
			//---------- Estado e Municipio de Destino do Documento
			If M->DTQ_SERTMS <> StrZero(2,Len(DUD->DUD_SERTMS))  //Transferencia, UF/Cod.Mun Destino serao preenchidos conforme DUD_FILDCA da viagem. (tmsa140grv)
				cCdrDes	 := DT6->DT6_CDRCAL
				cCEPDes	 := Posicione("SA1",1,xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES,"A1_CEP")

				cSeekDTC := DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE + DT6_SERVIC)
				If DT6->DT6_DOCTMS == StrZero(6,Len(DT6->DT6_DOCTMS)) .And. !Empty(DT6->DT6_DOCDCO)
					cSeekDTC := DT6->(DT6_FILDCO + DT6_DOCDCO + DT6_SERDCO + DT6_SERVIC)
				EndIf

				DTC->(dbSetOrder(3))
				If DTC->(MsSeek(xFilial("DTC") + cSeekDTC ))
					If !Empty(DTC->DTC_SQEDES)
						DUL->(dbSetOrder(2))
						If DUL->(dbSeek(xFilial("DUL") + DT6->DT6_CLIDES + DT6->DT6_LOJDES + DTC->DTC_SQEDES ))
							If !Empty(DUL->DUL_CEP)
								cCEPDes		:= DUL->DUL_CEP
							EndIf
						EndIf
					EndIf
				EndIf

				DUY->(DbSetOrder(1))
				If DUY->(MsSeek(xFilial("DUY")+cCdrDes))
					cUfDes := DUY->DUY_EST
					cCdMunD:= DUY->DUY_CODMUN
				EndIf
					
				oMdGridDM8:SetValue('DM8_UFDES' ,cUfDes )
				oMdGridDM8:SetValue('DM8_CDMUND',cCdMunD)
				If !Empty(cCEPDes)
					oMdGridDM8:SetValue('DM8_CEPDES',cCEPDes)
				EndIf
			EndIf
			oMdGridDM8:SetValue('DM8_CDTPOP' ,M->DTQ_CDTPOP)
			oMdGridDM8:SetValue('DM8_CDCLFR' ,M->DTQ_CDCLFR)
			oMdGridDM8:SetValue('DM8_TIPVEI' ,M->DTQ_TIPVEI)  

		Else					
			If cCampo == "M->DTQ_CDTPOP" .And. !Empty(M->DTQ_CDTPOP)
				oMdGridDM8:SetValue('DM8_CDTPOP' ,M->DTQ_CDTPOP)
			ElseIf cCampo == "M->DTQ_CDCLFR" .And. !Empty(M->DTQ_CDCLFR)
				oMdGridDM8:SetValue('DM8_CDCLFR' ,M->DTQ_CDCLFR)
			ElseIf cCampo == "M->DTQ_TIPVEI" .And. !Empty(M->DTQ_TIPVEI)
				oMdGridDM8:SetValue('DM8_TIPVEI' ,M->DTQ_TIPVEI)  
			EndIf

		EndIf
	EndIf
Else
	oMdGridDM8:ClearField('DM8_UFORI')
	oMdGridDM8:ClearField('DM8_CDMUNO')
	oMdGridDM8:ClearField('DM8_MUNORI')
	oMdGridDM8:ClearField('DM8_CEPORI')
	oMdGridDM8:ClearField('DM8_UFDES')
	oMdGridDM8:ClearField('DM8_CDMUND')
	oMdGridDM8:ClearField('DM8_MUNDES')
	oMdGridDM8:ClearField('DM8_CEPDES')
	oMdGridDM8:ClearField('DM8_TIPVEI')
	oMdGridDM8:ClearField('DM8_CDTPOP')
	oMdGridDM8:ClearField('DM8_CDCLFR')	
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TF65RedAdc
Repete o Redespacho Adicional conforme opcao selecionada na Viagem
@type Function
@author Katia
@since 12/08/2020
@version 12.1.30
@param oModel, nRadio
@return 
Função extraída do fonte TMSA144 (TM144RdVge)
/*/
//-------------------------------------------------------------------
Function TF65RedAdc(nRadio)
Local oModel   := FWModelActive()
Local oMdGrdDM3:= oModel:GetModel("MdGridDM3")
Local oMdGrdDJN:= oModel:GetModel("MdGridDJN")
Local nLinAtuDM3:= oMdGrdDM3:GetLine()
Local n1         := 0
Local nX         := 0
Local nY         := 0
Local aLineDJN   := {}
Local nLinha     := 0
Local aArea      := GetArea()

Default nRadio   := 0

//Copia o Redespacho Adicional (origem)
aLineDJN:= CopyLinDJN()  

//Repete o Redespacho Adicional conforme opcao selecionada
If Len(aLineDJN) > 0
	oMdGrdDJN:DeActivate()
	oMdGrdDJN:Activate()

	For n1:= 1 To oMdGrdDM3:Length()
		nLinha:= 1

		If !oMdGrdDM3:IsDeleted() .And. !oMdGrdDM3:IsEmpty()
			oMdGrdDM3:GoLine(n1)
			//--- Redespacho Adicional somente para Documento de Entrega
			If n1 <> nLinAtuDM3 
				If oMdGrdDM3:GetValue('DM3_SERIE',n1) <> 'COL' 
				
					lAplica:= .T.
					If nRadio == 1  //Aplica para Todos Doctos da viagem 
						oMdGrdDJN:DelAllLine()
					ElseIf nRadio == 2 //Aplica para os documentos da viagem sem Redespacho Adicional
						If !oMdGrdDJN:IsEmpty() .And. !oMdGrdDJN:IsDeleted()
							lAplica:= .F.
						EndIf
					EndIf
					
					If lAplica
						If !oMdGrdDJN:IsEmpty()
							oMdGrdDJN:AddLine()
						EndIf

						For nX := 1 To Len(aLineDJN)
							If nLinha > 1
								oMdGrdDJN:AddLine()
							EndIf

							For nY:= 1 To Len(aLineDJN[nX])
								oMdGrdDJN:LoadValue(aLineDJN[nX][nY][1],aLineDJN[nX][nY][2])
							Next nY

							nLinha++
						Next nX
					EndIf

				EndIf		
			EndIf	
		EndIf
	Next n1
EndIf

RestArea(aArea)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} CopyLinDJN
Copia a linha do Redespacho Adicional DJN
@type Function
@author Katia
@since 12/08/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function CopyLinDJN()
Local oModel   := FwModelActive()
Local oMdGrdDJN:= oModel:GetModel("MdGridDJN")
Local oStruct  := oMdGrdDJN:GetStruct()    
Local aCampos  := oStruct:GetFields()
Local aLineDJN := {}
Local nI       := 0
Local nAux     := 0 
Local nDJN     := 0

For nDJN:= 1 To oMdGrdDJN:Length()
	If !oMdGrdDJN:IsDeleted() .And. !oMdGrdDJN:IsEmpty()
		oMdGrdDJN:GoLine(nDJN)
	
		Aadd(aLineDJN,{})

		For nI:= 1 To Len(aCampos)
			If !(aCampos[nI][MODEL_FIELD_IDFIELD] $ 'DJN_SEQRDP')
				If (nAux := ASCAN(aLineDJN[nDJN], {|x| x[1] == aCampos[nI][MODEL_FIELD_IDFIELD]})) != 0
					aLineDJN[nDJN][nAux][2] := oMdGrdDJN:GetValue(aCampos[nI][MODEL_FIELD_IDFIELD])
				Else
					AADD(aLineDJN[nDJN],{aCampos[nI][MODEL_FIELD_IDFIELD] , oMdGrdDJN:GetValue(aCampos[nI][MODEL_FIELD_IDFIELD]) })
				EndIf
			EndIf
		Next nI

	EndIf
Next nDJN

Return aLineDJN

