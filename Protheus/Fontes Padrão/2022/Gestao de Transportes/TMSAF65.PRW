#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
Static cSeqTo     := ""
Static nLineTo    := 0
Static cSeqFrom   := ""
Static nLineFrom  := 0
Static lTMS3GFE   := TmsIntGFE('02')
Static cTMSOPdg   := SuperGetMV( 'MV_TMSOPDG',, '0' )
Static lTmsRdpU	  := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho

//-------------------------------------------------------------------
/* TMSAF65GAT
//Gatilhos de Campos do Documento da Viagem Modelo 3
@author Katia
@since 19/06/2020
@version 1.0
@return xRet
*/
//-------------------------------------------------------------------
Function TMSAF65GAT(cCampo,cDest)
Local xRet      := Nil

Default cCampo  := ReadVar()

If cCampo $ "M->DM3_FILDOC|M->DM3_DOC|M->DM3_SERIE" 
	xRet:= TF65GatDoc(cCampo,cDest,FwFldGet('DM3_FILDOC'),FwFldGet('DM3_DOC'),FwFldGet('DM3_SERIE'))
	
ElseIf cCampo $ "DTQ_ROTA"	
	xRet:= TF65GatRot(cCampo,cDest,M->DTQ_ROTA)
	
ElseIf cCampo $ "DTR_CODVEI"
	xRet:= TF65GatVei(cCampo,cDest,M->DTR_CODVEI)
		
ElseIf cCampo $ "DTR_CODRB1|DTR_CODRB2|DTR_CODRB3"
	xRet:= TF65GatReb(cCampo,cDest)

ElseIf cCampo $ "DTR_QTDEIX|DTR_QTEIXV"
	xRet:= TF65GatEix(cCampo,cDest) 

ElseIf cCampo $ "DTQ_TPOPVG"	
	xRet:= TF65AltFre(cCampo,cDest,M->DTQ_TPOPVG)	

ElseIf cCampo $ "DUP_CODMOT"
	xRet:= TF65GatMot(cCampo,cDest,FwFldGet("DUP_CODMOT"))

ElseIf cCampo $ "DTQ_SERTMS"
	xRet:= TF65GatSrv(cCampo,cDest,FwFldGet("DTQ_SERTMS"))

ElseIf cCampo $ "M->DM3_SEQUEN"
	xRet:= TF65GatSeq()

ElseIf cCampo $ "DM4_FILVGE|DM4_NUMVGE"
	xRet:= TF65VgeInt(cCampo,cDest)	

ElseIf cCampo $ "DM4_DATINI|DM4_HORINI"
	xRet:= TF65DatIni(cCampo,cDest)

ElseIf cCampo $ "DG_TOTAL"
	xRet	:= TF65ValSDG(cCampo,cDest,FwFldGet("DG_TOTAL"))

ElseIf cCampo $ "DG_VALCOB"
	xRet	:= TF65ValSDG(cCampo,cDest,FwFldGet("DG_VALCOB"))
	
ElseIf cCampo $ "DG_CODDES"
	xRet	:= TF65DesSDG( cCampo , cDest )

ElseIf cCampo $ "DTQ_PAGGFE"
	xRet:= TMSAF65G(cCampo,cDest)

ElseIf cCampo $ "DTQ_TIPVIA"
	xRet:= TF65GatTVg(cCampo,cDest)

ElseIf cCampo $ "M->DTR_FOROPE|M->DTR_LOJOPE" 
	xRet:= TF65GatCGG(FwFldGet("DTR_FOROPE"),FwFldGet("DTR_LOJOPE"))

ElseIf cCampo $ "M->M->DTR_FORPDG|DTR_LOJPDG" 
	xRet:= TF65GatCGG(FwFldGet("DTR_FORPDG"),FwFldGet("DTR_LOJPDG"))

ElseIf cCampo $ "DTQ_CODAUT"
	xRet:= TF65Automa(cCampo,cDest,FwFldGet("DTQ_CODAUT"))

ElseIf cCampo $ "DLD_FORPAG"
	xRet:= TF65PgTag(cCampo,cDest)

ElseIf cCampo $ "DLD_TIPPAR"
	xRet:= TF65TipPar(cCampo,cDest)
EndIf

Return xRet 

//---------------------------------------------------------
/* TF65GatDoc
//Dados do Documento - Grid Documentos
@author Katia
@since 19/06/2020
@version 1.0
@return xRet 
obs: Função utilizado tambem no Inicializador de campo TMSAF66.PRW
//--------------------------------------------------------*/
Function TF65GatDoc(cCampo,cDest,cFilDoc,cDoc,cSerie,lTMSAF66)
Local xRet      := Nil
Local aArea     := GetArea()
Local lColeta	:= .F.
Local aDadosCol := {}
Local lLGPD		:= ExistFunc('FWPDCanUse') .And. FWPDCanUse(.T.)

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default lTMSAF66:= .F. //Executado pela rotina TMSAF66 - Inicializador

If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
	DT6->(DbSetOrder(1))
	If DT6->(dbSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))

		If DT6->DT6_SERTMS == StrZero(1,Len(DT6->DT6_SERTMS)) 
			aDadosCol:= TMSAF65DT5(DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE)  
			lColeta:= .T.
		EndIf

		If "DM3_NOMREM" $ cDest
			If !Empty(DT6->DT6_CLIREM)
				xRet:=  Posicione("SA1",1,xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM,"A1_NREDUZ")
				If lLGPD 
					If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_NREDUZ"} )) == 0
						xRet  := Replicate('*',TamSX3('A1_NREDUZ')[1])
					EndIf
				EndIf	

			ElseIf lColeta
				xRet:= aDadosCol[1]
			EndIf

		ElseIf cDest $ "DM3_NOMDES|DM3_BAIRRO|DM3_MUN|DM3_EST"
			SA1->(DbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))

			If cDest $ "DM3_NOMDES" 
				xRet:= SA1->A1_NREDUZ
				If lLGPD 
					If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_NREDUZ"} )) == 0
						xRet  := Replicate('*',TamSX3('A1_NREDUZ')[1])
					EndIf
				EndIf	

			ElseIf cDest $ "DM3_BAIRRO"
				xRet:= Iif(lColeta, aDadosCol[2], SA1->A1_BAIRRO)
				xRet:= Padr(xRet,TamSX3("DM3_BAIRRO")[1])
				If lLGPD .And. !lColeta
					If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_BAIRRO"} )) == 0
						xRet  := Replicate('*',TamSX3('DM3_BAIRRO')[1])
					EndIf
				EndIf	
				
			ElseIf cDest $ "DM3_MUN"
				xRet:= Iif(lColeta, aDadosCol[3], SA1->A1_MUN)
				xRet:= Padr(xRet,TamSX3("DM3_MUN")[1])				
				If lLGPD .And. !lColeta
					If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_MUN"} )) == 0
						xRet  := Replicate('*',TamSX3('DM3_MUN')[1])
					EndIf
				EndIf	
				
			ElseIf cDest $ "DM3_EST"
				xRet:= Iif(lColeta, aDadosCol[4], SA1->A1_EST)
				If lLGPD .And. !lColeta
					If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_EST"} )) == 0
						xRet  := Replicate('*',TamSX3('A1_EST')[1])
					EndIf
				EndIf
			EndIf
			
		ElseIf "DM3_PRZENT" $ cDest 
			xRet:= Iif(lColeta, aDadosCol[5], DT6->DT6_PRZENT)			
		
		ElseIf "DM3_SERIE" $ cDest 
			xRet:= DT6->DT6_SERIE

		    //----- Chama o gatilho do GFE 
			If !lTMSAF66 .And. (lTMS3GFE  .Or. lTmsRdpU)
				TMSAF65G("DM8_DOC",,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
			EndIf
		
			//--- Agendamento de Entrega
			If DT6->DT6_SERTMS == StrZero(3,Len(DT6->DT6_SERTMS)) .And. !Empty(DT6->DT6_NUMAGD)			
				TF65AgdEnt(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,1)
			EndIf
		EndIf
		
	EndIf
EndIf

RestArea(aArea)	
FwFreeArray(aArea)
Return xRet

//-------------------------------------------------------------------
/* TMSAF65DT5
//Valida a Solicitação de Coleta
@author Katia
@since 19/06/2020
@version 1.0
@return aRet , onde aRet:
1- Nome do Solicitante
2- Bairro
3- Municipio
4- Estado
5- Data Previsão
/*/
//-------------------------------------------------------------------
Function TMSAF65DT5(cFilDoc,cDoc,cSerie)

Local aRet    := {,,,,}
Local aAreas  := {DT5->(GetArea()),GetArea()}
Local cBaiCol := ""
Local cMunCol := ""
Local cEstCol := ""
Local cNome   := ""
Local lLGPD   := ExistFunc('FWPDCanUse') .And. FWPDCanUse(.T.)

Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""

DT5->(DbSetOrder(1))
If DT5->(MsSeek(xFilial('DT5')+ cFilDoc + cDoc + cSerie))
	DUE->(DbSetOrder(1))
	If DUE->(MsSeek(xFilial('DUE')+DT5->DT5_CODSOL))
		If !Empty(DT5->DT5_SEQEND)
			DUL->(DbSetOrder(3))
			If DUL->(MsSeek(xFilial('DUL')+DT5->(DT5_CODSOL+DT5_SEQEND)))
				cBaiCol := DUL->DUL_BAIRRO
				cMunCol := DUL->DUL_MUN
				cEstCol := DUL->DUL_EST
			EndIf
		Else
			cBaiCol := DUE->DUE_BAIRRO
			cMunCol := DUE->DUE_MUN
			cEstCol := DUE->DUE_EST
		EndIf

		cNome:= DUE->DUE_NOME

		If lLGPD 
			If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"DUE_NOME"} )) == 0	
				cNome  := Replicate('*',TamSX3('DUE_NOME')[1])
			EndIf
			If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"DUE_BAIRRO"} )) == 0	
				cBaiCol  := Replicate('*',TamSX3('DUE_BAIRRO')[1])
			EndIf
			If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"DUE_MUN"} )) == 0	
				cMunCol  := Replicate('*',TamSX3('DUE_MUN')[1])
			EndIf
			If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"DUE_EST"} )) == 0	
				cEstCol  := Replicate('*',TamSX3('DUE_EST')[1])
			EndIf
		EndIf

		aRet[1]:= cNome
		aRet[2]:= cBaiCol
		aRet[3]:= cMunCol
		aRet[4]:= cEstCol
		aRet[5]:= DT5->DT5_DATPRV
	EndIf
EndIf
AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return aRet

//--------------------------------------------
/* TF65MotVei
//Gatilha o Motorista do Veiculo na Viagem
@author Katia
@since 09/07/2020
@version 1.0
@return cCodVei
---------------------------------------------*/
Static Function TF65MotVei(cCodVei)
Local oModel     := FwModelActive()
Local oMdGridDUP:= oModel:GetModel("MdGridDUP")
Local oView      := FWViewActive()
Local aSaveLines := FWSaveRows()

Default cCodVei  := ""

If !Empty(cCodVei)
	oMdGridDUP:SetValue("DUP_CODMOT",DA3->DA3_MOTORI)
Else
	oMdGridDUP:SetValue("DUP_CODMOT", Space(TamSx3('DUP_CODMOT')[1]))
EndIf
If oView <> Nil .And. oView:IsActive() .and. !IsBlind()
    oView:Refresh("MdGridDUP")
	oView:Refresh("MdGridDTR")
EndIf

FWRestRows( aSaveLines )
Return cCodVei

//--------------------------------------------
/* TF65EixVei
//Soma quantidade de Eixos para o  gatilho
@author Katia
@since 09/07/2020
@version 1.0
@return cCodVei
---------------------------------------------*/
Function TF65QtdEix(cCampo,aVeiculos)
Local nQtdEixTot:= 0
Local nQtdEixVei:= 0
Local aArea     := GetArea()
Local nRecDA3   := DA3->(Recno())
Local lReboque  := .F.

Default cCampo    := ""
Default aVeiculos := {}

If !Empty(FwFldGet("DTR_CODVEI"))
	nQtdEixVei:= Posicione("DA3",1,xFilial("DA3")+FwFldGet('DTR_CODVEI'),"DA3_QTDEIX")
	nQtdEixTot+= nQtdEixVei
	aAdd( aVeiculos, {  FwFldGet("DTR_CODVEI"), nQtdEixVei, nQtdEixVei}) //verificar eixo volta	
EndIf
If !Empty(FwFldGet('DTR_CODRB1'))
	nQtdEixVei := Posicione("DA3",1,xFilial("DA3")+FwFldGet('DTR_CODRB1'),"DA3_QTDEIX")
	nQtdEixTot += nQtdEixVei
	aAdd( aVeiculos, {  FwFldGet("DTR_CODRB1"), 0, 0}) 
	lReboque:= .T.
EndIf
If !Empty(FwFldGet('DTR_CODRB2'))
	nQtdEixVei := Posicione("DA3",1,xFilial("DA3")+FwFldGet('DTR_CODRB2'),"DA3_QTDEIX")
	nQtdEixTot += nQtdEixVei
	aAdd( aVeiculos, {  FwFldGet("DTR_CODRB2"), 0, 0}) 
	lReboque:= .T.
EndIf
If !Empty(FwFldGet('DTR_CODRB3'))
	nQtdEixVei := Posicione("DA3",1,xFilial("DA3")+FwFldGet('DTR_CODRB3'),"DA3_QTDEIX")
	nQtdEixTot += nQtdEixVei
	aAdd( aVeiculos, {  FwFldGet("DTR_CODRB3"), 0, 0}) 
	lReboque:= .T.
EndIf

If Len(aVeiculos) > 0 
	If cCampo $ "DTR_QTDEIX" 
		aVeiculos[1,2] := M->DTR_QTDEIX
		aVeiculos[1,3] := FwFldGet('DTR_QTEIXV')
	ElseIf  cCampo $ "DTR_QTEIXV"
		aVeiculos[1,2] := FwFldGet('DTR_QTDEIX')
		aVeiculos[1,3] := M->DTR_QTEIXV
	ElseIf lReboque //Total de Eixos Cavalo + Reboque
		aVeiculos[1,2] := nQtdEixTot
		aVeiculos[1,3] := nQtdEixTot	
	EndIf
EndIf

RestArea(aArea)
FwFreeArray(aArea)
DA3->(DbGoTo(nRecDA3))
Return nQtdEixTot

//--------------------------------------------
/* TF65GatVei
//Dados do Veiculo - Grid Recursos
@author Katia
@since 10/07/2020
@version 1.0
@return Data, Hora
---------------------------------------------*/
Static Function TF65GatVei(cCampo,cDest,cCodVei)
Local xRet      := Nil

Default cCodVei := ""

If "DTR_CODVEI" == cDest
	xRet:= TF65MotVei(cCodVei)
ElseIf  "DTR_QTDEIX" == cDest 
	xRet:= TF65QtdEix(cCampo)
ElseIf  "DTR_VALFRE" == cDest 
	xRet:= TF65ValFre(cCampo,cDest) 
ElseIf  "DTR_QTEIXV" == cDest 
	xRet:= TF65QtdEix(cCampo)
ElseIf cDest $ "DTR_LIBRRE|DTR_INIRRE|DTR_FIMRRE"
	xRet:= TF65RREDTR(cCodVei,cDest)
EndIf

Return xRet

//--------------------------------------------
/* TF65GatReb
//Dados do Reboque - Grid Recursos
@author Katia
@since 10/07/2020
@version 1.0
@return Data, Hora
---------------------------------------------*/
Static Function  TF65GatReb(cCampo,cDest)
Local xRet     := Nil

If "DTR_QTDEIX" == cDest
	xRet:= TF65QtdEix(cCampo)
ElseIf "DTR_VALFRE" == cDest
	xRet:= TF65ValFre(cCampo,cDest)
ElseIf "DTR_QTEIXV" == cDest
	xRet:= TF65QtdEix(cCampo)
EndIf

Return xRet

//--------------------------------------------
/* TF65GatRot
//Dados do gatilho da Rota da viagem
@author Katia
@since 13/07/2020
@version 1.0
@return xRet
---------------------------------------------*/
Static Function TF65GatRot(cCampo,cDest,cRotaDA8)
Local xRet    := Nil
Local aAreas  := {DA8->(GetArea()),DC5->(GetArea()),GetArea()}

Default cRotaDA8:= ""

If !Empty(cRotaDA8)
	DA8->(DbSetOrder(1))
	If DA8->(DbSeek(xFilial("DA8") + cRotaDA8))
		DC5->(DbSetOrder(1))
		If DC5->(DbSeek(xFilial("DC5") + DA8->DA8_SERVIC))
			If "DTQ_SERTMS" == cDest
				xRet := DC5->DC5_SERTMS
			ElseIf "DTQ_DESSVT" == cDest
				xRet := TMSValField("DC5->DC5_SERTMS",.F.)
			ElseIf "DTQ_TIPTRA" == cDest
				xRet := "1"
			ElseIf "DTQ_DESTPT" == cDest
				xRet := TMSValField("DTQ_TIPTRA",.F.)
			ElseIf "DTQ_ROTA" == cDest
				xRet:= TF65Rota(cCampo,cDest,cRotaDA8)
			EndIf
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return xRet

//----------------------------------------------------
/* TF65FroVei
//Verifica Frota do Veiculo
@author Katia
@since 13/07/2020
@version 1.0
@return cFroVei
----------------------------------------------------*/
Function TF65FroVei(cCodVei)
Local aAreaDA3  := DA3->(GetArea())
Local cFroVei   := StrZero(0, Len(DA3->DA3_FROVEI))
Default cCodVei := ""

cFroVei:= Posicione("DA3",1,xFilial("DA3")+cCodVei,"DA3_FROVEI")

RestArea(aAreaDA3)
FwFreeArray(aAreaDA3)
Return cFroVei
//--------------------------------------------
/* TF65DtaVge
//Calcula da Data Fim e Hora Fim da Viagem a partir
da digitação da Rota 
@author Katia
@since 09/07/2020
@version 1.0
@return Data, Hora
---------------------------------------------*/
Function TF65DtaVge(cRotaDA8)
Local oModel     := FWModelActive()
Local oMdFldDM4  := oModel:GetModel("MdFieldDM4")
Local oMdFldDTQ  := oModel:GetModel("MdFieldDTQ")
Local dDatIni    := dDataBase 
Local cHorIni    := Left(Time(),5) 
Local dDatFim    := cTod('')
Local cHorFim    := Space(TamSX3("DM4_HORFIM")[1])

Default cRotaDA8 := ""

If !Empty(cRotaDA8)
	If Empty(oMdFldDM4:GetValue('DM4_DATINI')) .Or. Empty(oMdFldDM4:GetValue('DM4_HORINI'))
		oMdFldDM4:Loadvalue('DM4_DATINI', dDatIni)
		oMdFldDM4:Loadvalue('DM4_HORINI', StrTran( cHorIni, ":", "" ))
	Else
		dDatIni:= oMdFldDM4:GetValue('DM4_DATINI')
		cHorIni:= oMdFldDM4:GetValue('DM4_HORINI')
	EndIf
	dDatFim:= dDatIni
	cHorFim:= cHorIni

	lCalcTmp:= CalTmpRota(cRotaDA8, @dDatFim, @cHorFim,oMdFldDTQ:GetValue('DTQ_TIPTRA'))

	//-- Preenche o tempo da Viagem Entrega / Transferencia
	cTmpVge:= TmsTotHora(dDatIni,StrTran(cHorIni, ":", ""),dDatFim,StrTran(cHorFim, ":", ""), PesqPict( "DM4", "DM4_TMPVGE") )
	oMdFldDM4:Loadvalue('DM4_DATFIM', dDatFim)
	oMdFldDM4:Loadvalue('DM4_HORFIM', StrTran( cHorFim, ":", "" ))		
	oMdFldDM4:Loadvalue('DM4_TMPVGE', Iif(Val(cTmpVge)>0,cTmpVge,Space(TamSX3("DM4_TMPVGE")[1])))

Else
	oMdFldDM4:Loadvalue('DM4_DATINI', cTod(''))
	oMdFldDM4:Loadvalue('DM4_HORINI', Space(TamSX3("DM4_HORINI")[1]))
	oMdFldDM4:Loadvalue('DM4_DATFIM', cTod(''))
	oMdFldDM4:Loadvalue('DM4_HORFIM', Space(TamSX3("DM4_HORFIM")[1]))		
	oMdFldDM4:Loadvalue('DM4_TMPVGE', Space(TamSX3("DM4_TMPVGE")[1]))
EndIf

Return cRotaDA8


//----------------------------------------------------
/* TF65DatIni
//Calcula da Data Fim e Hora Fim a partir da digitação
da Data e Hora Inicio do Recurso 
@author Katia
@since 13/07/2020
@version 1.0
@return Data, Hora
----------------------------------------------------*/
Static Function TF65DatIni(cCampo,cDest)
Local oModel     := FWModelActive()
Local oMdFldDM4  := oModel:GetModel("MdFieldDM4")
Local oMdFldDTQ  := oModel:GetModel("MdFieldDTQ")
Local cRotaDA8   := oMdFldDTQ:GetValue('DTQ_ROTA')
Local dDatIni    := oMdFldDM4:GetValue('DM4_DATINI')
Local cHorIni    := oMdFldDM4:GetValue('DM4_HORINI')
Local dDatFim    := dDatIni
Local cHorFim    := Space(TamSX3("DM4_HORFIM")[1])
Local xRet       := Nil
Local cTmpVge    := ""
Local lCalcTmp   := .F.

	If cDest $ "DM4_DATFIM|DM4_HORFIM" 
		If "DM4_HORFIM" $ cDest			
			dDatFim:= oMdFldDM4:GetValue('DM4_DATFIM')
			If !Empty(cHorIni)
				cHorFim:= cHorIni
			EndIf
		EndIf

		//-- Soma o tempo da Viagem, de acordo com as atividades da Viagem.
		If !Empty(cRotaDA8) .And. !Empty(cHorIni)
			lCalcTmp:= CalTmpRota(cRotaDA8, @dDatFim, @cHorFim,oMdFldDTQ:GetValue('DTQ_TIPTRA'))
		EndIf
		
		If !lCalcTmp
			SomaDiaHor( @dDatFim, @cHorFim, TmsHrToInt( oMdFldDM4:GetValue('DM4_TMPVGE')) )
		EndIf
		If "DM4_DATFIM" $ cDest
			xRet:= dDatFim
		ElseIf "DM4_HORFIM" $ cDest
			xRet := StrTran( cHorFim, ":", "" )
		EndIf	
	ElseIf "DM4_TMPVGE" $ cDest
		//-- Preenche o tempo da Viagem Entrega / Transferencia
		cTmpVge:= TmsTotHora(dDatIni,StrTran(cHorIni, ":", ""),oMdFldDM4:GetValue('DM4_DATFIM'),StrTran(oMdFldDM4:GetValue('DM4_HORFIM'), ":", ""), PesqPict( "DM4", "DM4_TMPVGE") )
		If Val( cTmpVge) > 0  .And. !Empty(cRotaDA8)
			xRet:= cTmpVge
		Else
			xRet:= Space(TamSX3("DM4_TMPVGE")[1])
		EndIf
	EndIf

Return xRet

//----------------------------------------------------
/* TF65Rota
//Gatilhos da Rota Data Planejamento e Alteração da Rota
@author Katia
@since 13/07/2020
@version 1.0
@return cRota
----------------------------------------------------*/
Static Function TF65Rota(cCampo,cDest,cRotaDA8)
Local xRet      := ""
Default cRotaDA8:= ""

	If !Empty(cRotaDA8)
		//Data Inicio e Fim do Planejamento 
		xRet:= TF65DtaVge(cRotaDA8)  
		
		//Valor do Frete Carreteiro
		xRet:= TF65AltFre(cCampo,cDest,cRotaDA8)
	EndIf	 

Return cRotaDA8

//----------------------------------------------------
/* aCalFreCar
//Calcula o valor do Frete de Carreteiro do Recurso
@author Katia
@since 13/07/2020
@version 1.0
@return Data, Hora
----------------------------------------------------*/
Static Function aCalFreCar(aVeiculos)
Local aAreaDA3    := DA3->(GetArea())
Local cChave      := ""
Local cVeiRas     := ""  
Local cFrovei     := ""
Local aRet        := {}
Local cFroVeiRb1  := StrZero(0, Len(DA3->DA3_FROVEI))
Local cFroVeiRb2  := StrZero(0, Len(DA3->DA3_FROVEI))
Local cFroVeiRb3  := StrZero(0, Len(DA3->DA3_FROVEI))
Local nX          := 0
Local lCalcPdg    := .T.  //Tratar Repom

Default aVeiculos := {}    

For nX:= 1 To Len(aVeiculos)
	If nX == 1  //Veiculo 
		DA3->(DbSetOrder(1))
		If DA3->(MsSeek(xFilial('DA3')+ aVeiculos[nX][1]))
			cFrovei := DA3->DA3_FROVEI
			cChave 	:= DA3->DA3_TIPVEI
			cCodFor	:= DA3->DA3_CODFOR
			cLojFor := DA3->DA3_LOJFOR
			cVeiRas := DA3->DA3_VEIRAS
		EndIf
	Else  //Reboques 1,2,3
		If nX == 2
			cFroVeiRb1:= TF65FroVei(aVeiculos[nX][1])
		ElseIf nX == 3
			cFroVeiRb2:= TF65FroVei(aVeiculos[nX][1])
		ElseIf nX == 4
			cFroVeiRb3:= TF65FroVei(aVeiculos[nX][1])
		EndIf
	EndIf
Next nX

cChave += cFroVeiRb1
cChave += cFroVeiRb2
cChave += cFroVeiRb3
cChave += cVeiRas
cChave += M->DTQ_TIPVIA

aRet := TMSFretCar(M->DTQ_ROTA, cCodFor, cLojFor, aVeiculos, cChave,;
M->DTQ_SERTMS, M->DTQ_TIPTRA,,, Iif(cTMSOPdg <> '0', M->DM5_CODOPE, ''),lCalcPdg,,;
M->DTQ_TPOPVG,M->DTQ_FILORI,M->DTQ_VIAGEM)

RestArea(aAreaDA3)
FwFreeArray(aAreaDA3)
Return aRet

//----------------------------------------------------
/* TF65FreCar
//Gatilha Valor do Frete/Pedagio
@author Katia
@since 13/07/2020
@version 1.0
@return lRet
----------------------------------------------------*/
Static Function TF65FreCar(aFretCar,oMdGridDTR)
Local lRet      := .F.
Local cFroVei    := ""
Local nValFret   := 0
Local oModel     := Nil

Default aFretCar   := {}
Default oMdGridDTR:= Nil

If ValType(oMdGridDTR) == "U"
	oModel     := FwModelActive()
	oMdGridDTR:= oModel:GetModel("MdGridDTR")
	nLinha     := oMdGridDTR:GetLine()
	oMdGridDTR:Goline(nLinha)
EndIf

If Len(aFretCar) > 0
	If aFretCar[4]   //Falha no Calculo do Pedagio da Operadora de Frotas
		lRet:= .F.
	Else
		lRet:= .T.
	EndIf
EndIf

If lRet
	cFroVei:= TF65FroVei(FwFldGet("DTR_CODVEI"))
	If cFrovei <> "1" //-- Se Frota do Veiculo NAO for "Propria"					 							
		oMdGridDTR:SetValue( 'DTR_VALPDG', aFretCar[1] ) 					
		oMdGridDTR:SetValue( 'DTR_TABCAR', aFretCar[3] ) 
		nValFret:= aFretCar[2] 
	EndIf	
EndIf

If !lRet .Or. cFroVei == "1" //Frota do Veiculo Propria
	oMdGridDTR:SetValue( 'DTR_VALPDG', 0 ) 
	oMdGridDTR:SetValue( 'DTR_TABCAR', Space(TamSx3('DTR_TABCART')[1]) ) 
	oMdGridDTR:SetValue( 'DTR_INSRET', 0) 			
EndIf

Return nValFret

//----------------------------------------------------
/* TF65ValFre
//Gatilha o valor calculado do Frete de Carreteiro
@author Katia
@since 13/07/2020
@version 1.0
@return nValor
----------------------------------------------------*/
Static Function TF65ValFre(cCampo,cDest)
Local xRet       := 0
Local nEixo      := 0
Local aVeiculos  := {}
Local aFretCar   := {}

If "DTR_VALFRE" $ cDest
	//--- aVeiculos com todos os veiculos e eixos
	nEixo:= TF65QtdEix(cCampo,@aVeiculos)

	//---- Calculo do Frete Carreteiro		
	If Len(aVeiculos) > 0
		aFretCar:= aCalFreCar(aVeiculos)					
	EndIf
	xRet:= TF65FreCar(aFretCar)

	FwFreeArray(aFretCar)
	FwFreeArray(aVeiculos)
EndIf

Return xRet

//----------------------------------------------------
/* TF65AltFre
//Atualiza o valor do Frete a partir da Alteração do 
Tipo de Operação ou da Rota 
@author Katia
@since 13/07/2020
@version 1.0
@return nValor
----------------------------------------------------*/
Static Function TF65AltFre(cCampo,cDest,cConteudo,lRecalculo)
Local oModel     := FwModelActive()
Local oMdGridDTR:= oModel:GetModel("MdGridDTR")
Local nLinha     := oMdGridDTR:GetLine()
Local aSaveLines := FWSaveRows()
Local nEixoTot   := 0
Local aVeiculos  := {}
Local aFretCar   := {}
Local xRet       := 0

Default cCampo    := ""
Default cDest     := ""
Default cConteudo := ""
Default lRecalculo:= .F.

If cDest $ "DTQ_TPOPVG|DTQ_ROTA" .Or. lRecalculo
	For nLinha:=1 To oMdGridDTR:Length()
		oMdGridDTR:GoLine(nLinha)
		If !oMdGridDTR:IsEmpty() .And. !oMdGridDTR:IsDeleted() 		
			
			If !Empty(oMdGridDTR:GetValue("DTR_CODVEI",nLinha))				
				//--- Atualiza Qtde de Eixos e Valor do Frete
				aVeiculos:={}
				nEixoTot:= TF65QtdEix(cCampo,@aVeiculos)

				oMdGridDTR:LoadValue("DTR_QTDEIX", nEixoTot)
				oMdGridDTR:LoadValue("DTR_QTEIXV", nEixoTot)
				If Len(aVeiculos) > 0
					aFretCar:= aCalFreCar(aVeiculos)						
				EndIf
				xRet:= TF65FreCar(aFretCar)
				oMdGridDTR:SetValue("DTR_VALFRE", xRet)

			EndIf	
		EndIf
	Next nLinha	
EndIf

FwFreeArray(aFretCar)
FwFreeArray(aVeiculos)
FWRestRows( aSaveLines )
Return cConteudo

//----------------------------------------------------
/* TF65GatEix
//Gatilho do campo Eixo (DTR_QTDEIX)
@author Katia
@since 13/07/2020
@version 1.0
@return nValor
----------------------------------------------------*/
Static Function TF65GatEix(cCampo,cDest)
Local xRet     := Nil
Local nEixo    := 0
Local aVeiculos:= {}
Local aFretCar := {}

If "DTR_QTDEIXV" $ cDest
	xRet:= FwFldGet("DTR_QTDEIX")

ElseIf "DTR_VALFRE" $ cDest
	//--- aVeiculos com todos os veiculos e eixos
	nEixo:= TF65QtdEix(cCampo,@aVeiculos)

	//---- Calculo do Frete Carreteiro		
	If Len(aVeiculos) > 0
		aFretCar:= aCalFreCar(aVeiculos)						
	EndIf
	xRet:= TF65FreCar(aFretCar)
	FwFreeArray(aFretCar)
	FwFreeArray(aVeiculos)
EndIf

Return xRet

/*{Protheus.doc} TF65GatMot
Gatilha do codigo do motorista da DUP
@type Static Function
@author Valdemar Roberto Mognon
@since 14/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TF65GatMot(cCampo,cDest,cCodMot)
Local xRet      := Nil

Default cCampo  := ""
Default cDest   := ""
Default cCodMot := ""

If !EMpty(cCodMot)
	If "DUP_CODMOT" == cDest
		xRet:= TF65AjuMot(cCodMot)
	ElseIf "DUP_IDOPE" == cDest
		xRet:= TF65IdMot(cCodMot,M->DM5_CODOPE)
	ElseIf "DUP_CONDUT" == cDest
		xRet := "1"
	ElseIf cDest $ "DUP_LIBRRE|DUP_INIRRE|DUP_FIMRRE"
		xRet:= TF65RREDUP(cCodMot,cDest)
	EndIf
EndIf

Return xRet

/*{Protheus.doc} TF65AjuMot
Gatilha do codigo do motorista da DUP
@type Static Function
@author Valdemar Roberto Mognon
@since 14/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TF65AjuMot(cCodMot)
Local oModel      := FwModelActive()
Local oMdGridDUQ := oModel:GetModel("MdGridDUQ")
Local aSaveLines  := FWSaveRows()
Local nCntFor1    := 1
Local nQtdLin     := 0
Local lCriaLin    := .T.

Default cCodMot := ""

//-- Primeiramente limpa os ajudantes eventualmente gatilhados do motorista anterior (alteração do CodMot)
For nCntFor1 := 1 To oMdGridDUQ:Length()
	oMdGridDUQ:GoLine(nCntFor1)
	If !oMdGridDUQ:IsDeleted() .And. !Empty(FwFldGet("DUQ_CODAJU"))
		oMdGridDUQ:DeleteLine()
	EndIf
Next nCntFor1
//-- Verifica se deve criar linha na primeira passagem
If oMdGridDUQ:Length() == 1 .And. Empty(FwFldGet("DUQ_CODAJU"))
	lCriaLin := .F.
Else
	nQtdLin := oMdGridDUQ:Length()
EndIf
//-- Gatilha os ajudantes do motorista atual da grid de motoristas
For nCntFor1 := 1 To 3
	If !Empty(&("DA4->DA4_AJUDA" + StrZero(nCntFor1,1)))
		If lCriaLin
			oMdGridDUQ:AddLine()
		EndIf
		nQtdLin ++
		oMdGridDUQ:GoLine(nQtdLin)
		oMdGridDUQ:SetValue("DUQ_CODAJU",&("DA4->DA4_AJUDA" + StrZero(nCntFor1,1)))
		lCriaLin := .T.
	EndIf
Next nCntFor1

FWRestRows(aSaveLines)

Return cCodMot
/* ----------------------------------------------------
{Protheus.doc} TF65VgeInt
Gatilho da Viagem Interligada (Coligada)
@type Static Function
@author Katia
@since 16/07/2020
@version P12 R12.1.29
@return Nro da Viagem Original (DM4_NUMVGE)
-------------------------------------------------------*/
Static Function TF65VgeInt(cCampo,cDest)

Local oModel      := FwModelActive()
Local oMdFldDM4   := oModel:GetModel("MdFieldDM4")
Local oMdGridDTR := oModel:GetModel("MdGridDTR")
Local oMdGridDUP  := oModel:GetModel("MdGridDUP")
Local oMdGridDUQ  := oModel:GetModel("MdGridDUQ")
Local oView       := FWViewActive()
Local aAreas      := {DTQ->(GetArea()),DTR->(GetArea()),DUP->(GetArea()),DUQ->(GetArea()),DM4->(GetArea()),GetArea()}
Local cFilVge     := ""
Local cNumVge     := ""
Local xRet        := Nil
Local aSaveLines  := FWSaveRows()
Local cSeek       := ""
Local nLinha      := 0

cFilVge:= oMdFldDM4:GetValue("DM4_FILVGE")
cNumVge:= oMdFldDM4:GetValue("DM4_NUMVGE")
xRet   := cNumVge

TF65CtrLin(oMdGridDTR,oMdGridDUP,oMdGridDUQ,.F.)

If !Empty(cFilVge) .And. !Empty(cNumVge)		
	DTR->( dbSetOrder(1))
	If  DTR->( MsSeek(cSeek:= xFilial("DTR") + cFilVge +  cNumVge)  )
		//--- Veiculos
		If !oMdGridDTR:IsEmpty()
			oMdGridDTR:DelAllLine()
		EndIf

		//------ Motoristas
		If !oMdGridDUP:IsEmpty()
			oMdGridDUP:DelAllLine()
		EndIf 
				
		Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == cSeek
			If !oMdGridDTR:IsEmpty()
				oMdGridDTR:AddLine()
			EndIf

			nLinha := oMdGridDTR:GetLine()
			oMdGridDTR:Goline(nLinha)

			oMdGridDTR:SetValue("DTR_CODVEI",DTR->DTR_CODVEI)
			If !Empty(DTR->DTR_CODRB1)			
				oMdGridDTR:SetValue("DTR_CODRB1",DTR->DTR_CODRB1)
			EndIf
			If !Empty(DTR->DTR_CODRB2)
				oMdGridDTR:SetValue("DTR_CODRB2",DTR->DTR_CODRB2)
			EndIf
			If !Empty(DTR->DTR_CODRB3)
				oMdGridDTR:SetValue("DTR_CODRB3",DTR->DTR_CODRB3)
			EndIf
			
			
			DUP->( dbSetOrder(1))
			If  DUP->( MsSeek(cSeek:= xFilial("DUP") + DTR->DTR_FILORI + DTR->DTR_VIAGEM + DTR->DTR_ITEM )  )
				While !DUP->(Eof()) .And. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR) == cSeek
					
					nLinha := oMdGridDUP:GetLine()
					oMdGridDUP:Goline(nLinha)

					oMdGridDUP:SetValue("DUP_CODMOT",DUP->DUP_CODMOT)
					DUP->(dbSkip())
				EndDo
			EndIf

			//------ Ajudantes
			If !oMdGridDUQ:IsEmpty()
				oMdGridDUQ:DelAllLine()
			EndIf

			DUQ->( dbSetOrder(1))
			If  DUQ->( MsSeek(cSeek:= xFilial("DUQ") + DTR->DTR_FILORI + DTR->DTR_VIAGEM + DTR->DTR_ITEM )  )
				While !DUQ->(Eof()) .And. DUQ->(DUQ_FILIAL+DUQ_FILORI+DUQ_VIAGEM+DUQ_ITEDTR) == cSeek
					If !oMdGridDUQ:IsEmpty()
						oMdGridDUQ:AddLine()
					EndIf

					nLinha := oMdGridDUQ:GetLine()
					oMdGridDUQ:Goline(nLinha)

					oMdGridDUQ:SetValue("DUQ_CODAJU",DUQ->DUQ_CODAJU)
					DUQ->(dbSkip())
				EndDo
			EndIf
			
			DTR->(dbSkip())
		EndDo
		oView:Refresh("MdGridDTR")
		oView:Refresh("MdGridDUP")
		oView:Refresh("MdGridDUQ")
		TF65CtrLin(oMdGridDTR,oMdGridDUP,oMdGridDUQ,.T.)
	EndIf		

EndIf
FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return xRet

/* ----------------------------------------------------
{Protheus.doc} TF65CtrLin
Controle de Linha do Grid de Recursos para liberação
@type Static Function
@author Katia
@since 16/07/2020
@version P12 R12.1.29
@return Nil
-------------------------------------------------------*/
Function TF65CtrLin(oMdGridDTR,oMdGridDUP,oMdGridDUQ,lAtiva)
Default lAtiva:= .F.

oMdGridDTR:SetNoInsertLine( lAtiva )
oMdGridDTR:SetNoDeleteLine( lAtiva )
oMdGridDUQ:SetNoInsertLine( lAtiva )
oMdGridDUQ:SetNoDeleteLine( lAtiva )
oMdGridDUP:SetNoInsertLine( lAtiva )
oMdGridDUP:SetNoDeleteLine( lAtiva )

Return 

/*{Protheus.doc} TF65GatSrv
Gatilha Descrição do Serviço de Transporte do TMS
@type Static Function
@author Valdemar Roberto Mognon
@since 20/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TF65GatSrv(cCampo,cDest,cSerTMS)
Local xRet      := Nil

Default cCampo  := ""
Default cDest   := ""
Default cSerTMS := ""

If !Empty(cSerTMS)
	If "DTQ_DESSVT" == cDest
		xRet:= TF65SrvTMS(cSerTMS)
	EndIf
EndIf

Return xRet

/*{Protheus.doc} TF65SrvTMS
Busca Descrição do Serviço de Transporte do TMS
@type Static Function
@author Valdemar Roberto Mognon
@since 20/07/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TF65SrvTMS(cSerTMS)
Local xRet := Nil

Default cSerTMS := ""

xRet := TMSValField("DTQ_SERTMS",.F.)

Return xRet

//----------------------------------------------------
/* TF65GatSeq
//Gatilho do Sequencia do Documento
@author Katia
@since 21/07/2020
@version 1.0
@return xRet
----------------------------------------------------*/
Static Function TF65GatSeq()
Local oModel     := FwModelActive()
Local oMdlGridDM3:= oModel:GetModel("MdGridDM3")
Local oView      := FWViewActive()
Local nStep      := 0
Local nLineAtu   := nLineFrom
Local cSeqAtu    := cSeqFrom
Local nDest      := nLineFrom
Local nOri       := 0

If !Empty(cSeqAtu)
	If nLineFrom < nLineTo
		nStep:= 1
	Else
		nStep:= -1
	EndIf		

	For nOri:= nLineFrom To nLineTo Step nStep
		If nOri <> nLineTo
			If nStep < 1
				nDest:=  nDest - 1
			Else
				nDest:=  nDest + 1
			EndIf	
			
			oMdlGridDM3:GoLine(nOri)
			cSeqOri:= oMdlGridDM3:GetValue("DM3_SEQUEN",nOri)

			oMdlGridDM3:GoLine(nDest)
			cSeqDes:= oMdlGridDM3:GetValue("DM3_SEQUEN",nDest)

			oMdlGridDM3:LineShift(nOri, nDest) 

			oMdlGridDM3:GoLine(nOri)
			oMdlGridDM3:LoadValue("DM3_SEQUEN",cSeqOri)

			oMdlGridDM3:GoLine(nDest)
			oMdlGridDM3:LoadValue("DM3_SEQUEN",cSeqDes)
		EndIf
	Next 
	
	oView:Refresh()
	oMdlGridDM3:GoLine(nLineAtu)
Else
	cSeqAtu:= M->DM3_SEQUEN
EndIf

TF65ZeraSt()

Return cSeqAtu

//-----------------------------------------------------------------
/* TF65SetaSt
//Seta as variaveis "Static" para controle da ordem da sequencia 
do documento
@author Katia
@since 21/07/2020
@version 1.0
@return 
-----------------------------------------------------------------*/
Function TF65SetaSt(xValue,nLine,xCurrentValue,nLineDest)

cSeqTo     := xValue
nLineTo    := nLineDest
nLineFrom  := nLine
cSeqFrom   := xCurrentValue

Return Nil

//-----------------------------------------------------------------
/* TF65ZeraSt
//Limpa as variaveis "Static" da sequencia do documento
@author Katia
@since 21/07/2020
@version 1.0
@return 
-----------------------------------------------------------------*/
Function TF65ZeraSt()

cSeqTo     := ""
nLineTo    := 0
nLineFrom  := 0
cSeqFrom   := ""

Return Nil


//-------------------------------------------------
/* CalTmpRota
//Calcula a duração da Rota 
@author Katia
@since 29/07/2020
@version 1.0
@return 
----------------------------------------------------*/
Static Function  CalTmpRota(cRotaDA8, dDatFim, cHorFim,cTipTransp)
Local lRet      := .F.
Local lCont     := .T.
Local cSeekDC5  := ""
Local aAreas    := {DA8->(GetArea()),DT5->(GetArea()),DC6->(GetArea()),GetArea()}
Local cAtivRta  := AllTrim( GetMv( "MV_ATIVRTA",,"" ) ) //-- Atividade de retorno do Aeroporto

Default cTipTransp:= "1"

DA8->(DbSetOrder(1))
If DA8->(DbSeek(xFilial("DA8") + cRotaDA8))
	DC6->( dbSetOrder( 1 ) )
	DC5->( dbSetOrder( 1 ) )
	DC5->( MsSeek( cSeekDC5 := xFilial('DC5') + DA8->DA8_SERVIC ) )
	While DC5->( !Eof() .And. DC5_FILIAL + DC5_SERVIC == cSeekDC5 )
		DC6->( MsSeek( xFilial("DC6") + DC5->DC5_TAREFA ) )
		While DC6->( !Eof() .And. DC6->DC6_TAREFA == DC5->DC5_TAREFA )
			SomaDiaHor( @dDatFim, @cHorFim, HoraToInt( DC6->DC6_DURAC, 3 ) )

			//-- Quando for Aereo soma o tempo até encontrar a atividade de retorno do aeroporto.
			If cTipTransp == StrZero( 2, Len( DC5->DC5_TIPTRA ) ) .And. Alltrim( DC6->DC6_ATIVID ) == cAtivRta
				lCont := .F.
				Exit
			EndIf

			lRet:= .T.
			DC6->( dbSkip() )
		EndDo				
		DC5->( dbSkip() )
		If !lCont
			Exit
		EndIf
	Enddo
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
Return lRet
//-----------------------------------------------------------------
/* TF65ValSDG
//Gatilho do SDG
@author Caio Murakami
@since 29/07/2020
@version 1.0
@return 
-----------------------------------------------------------------*/
Function TF65ValSDG( cCampo , cDest , nTotal )
Local xRet		 := Nil 
Local aCotacao 	 := {1,RecMoeda(dDataBase,2),RecMoeda(dDataBase,3),RecMoeda(dDataBase,4),RecMoeda(dDataBase,5)}
Local aAreas     := {DT7->(GetArea()),GetArea()}
Local oModel     := FwModelActive()
Local oMdGridDTR := oModel:GetModel("MdGridDTR")
Local oMdGridSDG := oModel:GetModel("MdGridSDG")
Local nCntFor1   := 0
Local nCntFor2   := 0

Default cCampo  := ""
Default cDest   := ""
Default nTotal  := 0

If "DG_VALCOB" == cDest
	xRet	:= FwFldGet("DG_TOTAL")
ElseIf "DG_SALDO" == cDest
	If "DG_TOTAL" == cCampo
		xRet	:= FwFldGet("DG_TOTAL")
	ElseIf "DG_VALCOB" == cCampo
		xRet:= FwFldGet('DG_SALDO')

		If DT7->DT7_MOVBCO == "2"  //Despesa não movimenta banco
			xRet:= FwFldGet('DG_VALCOB')
		EndIf
	EndIf
ElseIf "DG_CUSTO1" == cDest
	xRet	:= FwFldGet("DG_TOTAL")
ElseIf "DG_CUSTO2" == cDest
	xRet	:= Iif(aCotacao[2]>0,FwFldGet("DG_TOTAL")/aCotacao[2],0)
ElseIf "DG_CUSTO3" == cDest
	xRet	:= Iif(aCotacao[3]>0,FwFldGet("DG_TOTAL")/aCotacao[3],0)
ElseIf "DG_CUSTO4" == cDest
	xRet	:= Iif(aCotacao[4]>0,FwFldGet("DG_TOTAL")/aCotacao[4],0)
ElseIf "DG_CUSTO5" == cDest
	xRet	:= Iif(aCotacao[5]>0,FwFldGet("DG_TOTAL")/aCotacao[5],0)
ElseIf "DG_VALBAI"== cDest	
	If "DG_TOTAL" == cCampo
		DT7->(dbSetOrder(1))
		If DT7->(MsSeek(xFilial('DT7')+FwFldGet("DG_CODDES")))
			If DT7->DT7_MOVBCO == "1"  //Despesa não movimenta banco
				xRet    := FwFldGet('DG_TOTAL')
			EndIf
		EndIf
	ElseIf "DG_VALCOB" == cCampo
		xRet    := FwFldGet('DG_VALCOB')
	EndIf
ElseIf "DG_TOTAL" == cDest
	xRet := nTotal
	DT7->(DbSetOrder(1))
	For nCntFor1 := 1 To oMdGridDTR:Length()
		oMdGridDTR:GoLine(nCntFor1)
		If !oMdGridDTR:IsDeleted()
			oMdGridDTR:LoadValue("DTR_ADIFRE",0)
			For nCntFor2 := 1 To oMdGridSDG:Length()
				oMdGridSDG:GoLine(nCntFor2)
				If !oMdGridSDG:IsDeleted() .And. !Empty(FwFldGet("DG_CODDES"))
					If oMdGridSDG:GetValue("DG_SALDO") == 0
						If DT7->(MsSeek(xFilial("DT7") + FwFldGet("DG_CODDES"))) .And. DT7->DT7_MOVBCO = StrZero(1,Len(DT7->DT7_MOVBCO))
							oMdGridDTR:LoadValue("DTR_ADIFRE",oMdGridDTR:GetValue("DTR_ADIFRE") + oMdGridSDG:GetValue("DG_VALCOB"))
						EndIf
					EndIf
				EndIf
			Next nCntFor2
		EndIf
	Next nCntFor1
EndIf 

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return xRet
//-----------------------------------------------------------------
/* TF65DesSDG
//Gatilho do SDG
@author Caio Murakami
@since 30/07/2020
@version 1.0
@return 
-----------------------------------------------------------------*/
Function TF65DesSDG(cCampo, cDest)
Local xRet		:= ""
Local cCLVL		:= ""
Local cItemCTA	:= ""
Local cConta	:= ""
Local cCc		:= ""
Local cMovBco   := ""
Local nCusto1   := 0

DT7->(dbSetOrder(1))
If DT7->(MsSeek(xFilial('DT7')+FwFldGet("DG_CODDES")))
	cCLVL		:= DT7->DT7_CLVL
	cItemCTA	:= DT7->DT7_ITEMCT
	cConta		:= DT7->DT7_CONTA
	cCC			:= DT7->DT7_CC
	cMovBco     := DT7->DT7_MOVBCO 
	cConest     := DT7->DT7_CONEST 
	If cConest == "2" .And. cMovBco == "2"
		nCusto1     := DT7->DT7_CUSTO1
	EndIf
EndIf

If "DG_TOTAL" == cDest
	xRet:= nCusto1
ElseIf "DG_VALBAI" == cDest
	xRet:= nCusto1
ElseIf "DG_VALCOB" == cDest
	xRet:= nCusto1
ElseIf "DG_SALDO" == cDest
	xRet:= nCusto1
ElseIf "DG_CLVL" == cDest
	xRet	:= cCLVL
ElseIf "DG_ITEMCTA"== cDest
	xRet	:= cItemCTA
ElseIf "DG_CONTA"== cDest
	xRet:= cConta
ElseIf "DG_CC"== cDest
	xRet	:= cCC
ElseIf "DG_BANCO"== cDest	
	xRet:= TF65Conta(M->DM5_CODOPE,cDest,cMovBco)
ElseIf "DG_AGENCIA"== cDest	
	xRet:= TF65Conta(M->DM5_CODOPE,cDest,cMovBco)
ElseIf "DG_NUMCON"== cDest	
	xRet:= TF65Conta(M->DM5_CODOPE,cDest,cMovBco)
EndIf

Return xRet

/*{Protheus.doc} TF65IdMot
Gatilha o cartão da Operadora do Motorista
@type Static Function
@author Katia
@since 14/08/2020
@version 12.1.30
@param Codigo Motorista
@return cIdOpe
*/
Static Function TF65IdMot(cCodMot,cCodOpe)
Local aArea     := GetArea()
Local cIdOpe    := Space( Len( DEL->DEL_IDOPE ) )

Default cCodMot := ""
Default cCodOpe := ""

If cTMSOPdg <> '0'  .And. !Empty(cCodMot)
	If M->DM5_CODOPE == '02'  //Pamcard, não sera gatilhado (sera selecionado por F3 na DLD)
		cIdOpe:= Space( Len(DEL->DEL_IDOPE) )
	Else
		DEL->( DbSetOrder(2) )
		If DEL->( MsSeek(xFilial('DEL') + cCodMot + M->DM5_CODOPE ))
			cIdOpe := DEL->DEL_IDOPE
		Else
			DDQ->(dbSetOrder(2))
			If DDQ->( MsSeek(xFilial('DDQ') + DA3->DA3_CODFOR+ DA3->DA3_LOJFOR ))
				cIdOpe:= DDQ->DDQ_IDCART
			EndIf
		EndIf
	EndIf
EndIf	

RestArea(aArea)
FwFreeArray(aArea)
Return cIdOpe

/*{Protheus.doc} TF65GatTVg
Gatilhos do campo Tipo de Viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 01/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF65GatTVg(cCampo,cDest)
Local xRet       := Nil
Local nCntFor1   := 0
Local oModel     := FwModelActive()
Local oMdlFldDTQ := oModel:GetModel("MdFieldDTQ")
Local oMdlGrdDM3 := oModel:GetModel("MdGridDM3")

If oMdlFldDTQ:IsFieldUpdate("DTQ_TIPVIA") .And. (FwFldGet("DTQ_TIPVIA") == StrZero(2,Len(DTQ->DTQ_TIPVIA)) .Or. FwFldGet("DTQ_TIPVIA") == StrZero(4,Len(DTQ->DTQ_TIPVIA)))
	For nCntFor1 := 1 To oMdlGrdDM3:Length()
		If !oMdlGrdDM3:IsDeleted(nCntFor1)
			oMdlGrdDM3:GoLine(nCntFor1)
			oMdlGrdDM3:DeleteLine()
		EndIf	
	Next
	oMdlGrdDM3:GoLine(1)
EndIf

Return xRet



/*{Protheus.doc} TF65RecFrt
Recalculo do Frete Carreteiro 
Opção selecionado pelo Botao do TMSAF60
@type Function
@author Katia
@since 18/09/2020
@version version
@param oModel
@return Nil
*/
Function TF65RecFrt(oModel)
Local aArea     := GetArea()
Local xRet      := Nil
Local oMdGridDTR:= Nil

Default oModel  := FwModelActive()

oMdGridDTR:= oModel:GetModel("MdGridDTR")
If oMdGridDTR:Length() >=1 .And. !oMdGridDTR:IsDeleted() .And. !oMdGridDTR:IsEmpty()
	xRet:= TF65AltFre('','','',.T.)
EndIf	

RestArea(aArea)
FwFreeArray(aArea)
Return xRet


/*{Protheus.doc} TF65AgdEnt
Carrega Dados do Agendamento de Entrega
@type Static Function
@author Katia
@since 30/09/2020
@param param, param_type, param_descr
@return return, return_type, return_description
Função utilizado pelo TMSAF60 e TMSAF90
*/
Function TF65AgdEnt(cFilDoc,cDoc,cSerie,nAcao)
Local aArea      := GetArea()
Local oModel     := FwModelActive()
Local nOperation := oModel:GetOperation()
Local oMdlGrid   := Nil
Local oMdGrdDYD  := Nil
Local oView      := Nil
Local nQtdLin    := 1
Local lAddLine   := .F.

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default nAcao   := 0

If nAcao == 1	//-- Viagem
	oMdlGrid:= oModel:GetModel("MdGridDM3")
	nLinAtu:= oMdlGrid:GetLine()
ElseIf nAcao == 2	//-- Carregamento
	oMdlGrid:= oModel:GetModel("MdGridDTA")
	nLinAtu:= oMdlGrid:GetLine()
EndIf

If nOperation == MODEL_OPERATION_INSERT .Or. (nOperation == MODEL_OPERATION_UPDATE .And. oMdlGrid:IsUpdated(nLinAtu))
	oMdGrdDYD  := oModel:GetModel("MdGridDYD")
	oView      := FWViewActive()

	oMdGrdDYD:SetNoInsertLine(.F.)
	oMdGrdDYD:SetNoDeleteLine(.F.)
	oMdGrdDYD:SetNoUpdateLine(.F.)

	oMdGrdDYD:ClearData(.T.,.T.)

	DYD->(DbSetOrder(2))
	DYD->(MsSeek( cSeek := xFilial('DYD') + cFilDoc + cDoc + cSerie ))
	While DYD->(! Eof() .And. DYD_FILIAL+DYD_FILDOC+DYD_DOC+DYD_SERIE == cSeek )
		If lAddLine
			nQtdLin ++
			oMdGrdDYD:Addline()
		EndIf
		oMdGrdDYD:Goline(nQtdLin)
		lAddLine:= .T.

		oMdGrdDYD:LoadValue('DYD_TIPAGD',DYD->DYD_TIPAGD)
		oMdGrdDYD:LoadValue('DYD_DATAGD',DYD->DYD_DATAGD)
		oMdGrdDYD:LoadValue('DYD_PRDAGD',DYD->DYD_PRDAGD)
		oMdGrdDYD:LoadValue('DYD_INIAGD',DYD->DYD_INIAGD)
		oMdGrdDYD:LoadValue('DYD_FIMAGD',DYD->DYD_FIMAGD)
		oMdGrdDYD:LoadValue('DYD_STATUS',DYD->DYD_STATUS)

		DYD->(DbSkip())
	EndDo

	oMdGrdDYD:SetNoInsertLine(.T.)
	oMdGrdDYD:SetNoDeleteLine(.T.)
	oMdGrdDYD:SetNoUpdateLine(.T.)
	If Type('oView') <> 'U'
		oView:Refresh()
	EndIf
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return

/*{Protheus.doc} TF65Conta
Carrega Dados da Conta 
@type Static Function
@author Katia
@since 02/10/2020
@param param, param_type, param_descr
@return return, return_type, return_description
*/
Function TF65Conta(cCodOpe,cDest,cMovBco)
Local xRet:= " "

Default cCodOpe:= ""
Default cDest  := ""
Default cMovBco:= ""

If cMovBco == "1" //-- Se a Despesa tiver Movimento bancario
	If !Empty(cCodOpe)
		If "DG_BANCO" == cDest	
			xRet:=  Posicione('DEG',1,xFilial('DEG')+cCodOpe,'DEG_BANCO')
		ElseIf "DG_AGENCIA" == cDest	
			xRet:=  Posicione('DEG',1,xFilial('DEG')+cCodOpe,'DEG_AGENCI')
		ElseIf "DG_NUMCON" == cDest	
			xRet:=  Posicione('DEG',1,xFilial('DEG')+cCodOpe,'DEG_NUMCON')
		EndIf		
	EndIf
EndIf

Return xRet

/*{Protheus.doc} TF65RREDTR
Gatilha Dados da RRE do Veículo
@type Static Function
@author Valdemar Roberto Mognon
@since 08/10/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF65RREDTR(cCodVei,cDest)
Local xRet := Nil

Default cCodVei := ""
Default cDest   := ""

If cDest == "DTR_LIBRRE"
	xRet := Posicione("DA3",1,xFilial("DA3") + cCodVei,"DA3_LIBSEG")
ElseIf cDest == "DTR_INIRRE"
	xRet := Posicione("DA3",1,xFilial("DA3") + cCodVei,"DA3_DTIVSG")
ElseIf cDest == "DTR_FIMRRE"
	xRet := Posicione("DA3",1,xFilial("DA3") + cCodVei,"DA3_DTFVSG")
EndIf

Return xRet

/*{Protheus.doc} TF65RREDUP
Gatilha Dados da RRE do Motorista
@type Static Function
@author Valdemar Roberto Mognon
@since 08/10/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF65RREDUP(cCodMot,cDest)
Local xRet := Nil

Default cCodMot := ""
Default cDest   := ""

If cDest == "DUP_LIBRRE"
	xRet := Posicione("DA4",1,xFilial("DA4") + cCodMot,"DA4_LIBSEG")
ElseIf cDest == "DUP_INIRRE"
	xRet := Posicione("DA4",1,xFilial("DA4") + cCodMot,"DA4_DTIVSG")
ElseIf cDest == "DUP_FIMRRE"
	xRet := Posicione("DA4",1,xFilial("DA4") + cCodMot,"DA4_DTFVSG")
EndIf

Return xRet

/*{Protheus.doc} TF65GatCGG
Gatilha o CNPJ do Fornecedor da Operadora de Frota e da Operadora de Pedágio
@type Static Function
@author Valdemar Roberto Mognon
@since 15/10/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF65GatCGG(cCodFor,cLojFor)
Local xRet   := Nil
Local aAreas := {SA2->(GetArea()),GetArea()}

Default cCodFor := ""
Default cLojFor := ""

If !Empty(cCodFor) .And. !Empty(cLojFor)
	SA2->(DbSetOrder(1))
	If SA2->(DbSeek(xFilial("SA2") + cCodFor + cLojFor))
		xRet := SA2->A2_CGC
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return xRet

/*{Protheus.doc} TF65Automa
Gatilha a configuração do código da automatização da viagem
@type Static Function
@author Valdemar Roberto Mognon
@since 03/02/2021
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function TF65Automa(cCampo,cDest,cConteudo)
Local xRet       := Nil
Local oModel     := FwModelActive()
Local oMdGrdDMB  := Nil
Local nOperation := oModel:GetOperation()
Local nCntFor1   := 0
Local aAreas     := {}
Local cSeekDMA   := ""
Local lCont      := .T.

Default cCampo    := ""
Default cDest     := ""
Default cConteudo := ""

If !Empty(cCampo) .And. !Empty(cDest) .And. AliasInDic("DMA") .And. AliasInDic("DMB")
	If nOperation == MODEL_OPERATION_INSERT .Or. (nOperation == MODEL_OPERATION_UPDATE .And. FwFldGet("DTQ_STATUS") == StrZero(1,Len(DTQ->DTQ_STATUS)))
		oMdGrdDMB := oModel:GetModel("MdGridDMB")
		aAreas    := {DMA->(GetArea()),GetArea()}

		oModel:GetModel("MdGridDMB"):SetNoDeleteLine(.F.)
		//-- Primeiramente limpa os registros anteriores
		For nCntFor1 := 1 To oMdGrdDMB:Length()
			oMdGrdDMB:GoLine(nCntFor1)
			If !oMdGrdDMB:IsDeleted() .And. !Empty(FwFldGet("DMB_ROTINA"))
				oMdGrdDMB:DeleteLine()
			EndIf
		Next nCntFor1
		oModel:GetModel("MdGridDMB"):SetNoDeleteLine(.T.)
		
		DMA->(DbSetOrder(1))
	
		If DMA->(DbSeek(cSeekDMA := xFilial("DMA") + cConteudo))
	
			oModel:GetModel("MdGridDMB"):SetNoInsertLine(.F.)

			While DMA->(!Eof()) .And. DMA->(DMA_FILIAL + DMA_CODAUT) == cSeekDMA
				If !oMdGrdDMB:IsEmpty()
					oMdGrdDMB:GoLine(oMdGrdDMB:Length())
					If !oMdGrdDMB:AddLine()
						lCont := .F.
						Exit
					EndIf
				EndIf
				If lCont
					M->DMB_ROTINA := DMA->DMA_ROTINA
					oMdGrdDMB:Loadvalue("DMB_FILIAL",xFilial("DMB"))
					oMdGrdDMB:Loadvalue("DMB_SEQUEN",DMA->DMA_SEQUEN)
					oMdGrdDMB:Loadvalue("DMB_ROTINA",DMA->DMA_ROTINA)
					oMdGrdDMB:Loadvalue("DMB_DESROT",TmsValField("M->DMB_ROTINA",.F.,"DMB_DESROT"))
					oMdGrdDMB:Loadvalue("DMB_ROTAUT",DMA->DMA_ROTAUT)
				EndIf
				DMA->(DbSkip())
			EndDo
	
			oModel:GetModel("MdGridDMB"):SetNoInsertLine(.T.)
	
		EndIf
	
		AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
	
	EndIf

EndIf

Return xRet

/*{Protheus.doc} TF65PgTag
Gatilha a DLD
@type Static Function
@author Caio Murakami
@since 01/04/2021
@version version
@param cCampo, char, Campo Origem
@return xRet, char, Retorno do gatilho
@example
(examples)
@see (links_or_references)
@type function
*/
Static Function TF65PgTag( cCampo , cDest )
Local xRet		:= Nil 
Local cCodVei	:= ""
Local cCodOpe	:= ""
Local oModel	:= Nil
Local oModelDM5	:= Nil 
Local oModelDLD := Nil
Local cTpSPDG	:= ""
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

Default cCampo		:= ""
Default cDest		:= ""

If cCampo $ "DLD_FORPAG"

	If cDest $ "DLD_TAGID"

		If lVgeMod3
			cCodVei		:= FwFldGet("DTR_CODVEI")
			cCodOpe		:= FwFldGet("DM5_CODOPE")
			xRet		:= ""
			
			If FwFldGet("DLD_FORPAG") == "3" //-- TAG

				If cCodOpe == "02"
					cTpSPDG	:= "6"
					If FindFunction('PamIDTag')
						xRet:= PamIDTag(cCodOpe,cCodVei)
					EndIf
				EndIf 

				If !Empty(xRet)
					oModel		:= FwModelActive()
					oModelDM5	:= oModel:GetModel("MdFieldDM5")
					oModelDM5:LoadValue("DM5_TPSPDG",cTpSPDG) 
					oModelDLD	:= oModel:GetModel("MdGridDLD")
					oModelDLD:LoadValue("DLD_TIPPAR","3") 
					oModelDLD:LoadValue("DLD_RECEB","1") 		
				EndIf
			EndIf
		Else
			If AllTrim(GdFieldGet("DLD_FORPAG",n)) == '3'  		
				Help( ' ', 1, 'TMSA240A7') // A funcionalidade de pagamento de pedágio via 'TAG' está disponível somente para a Viagem Modelo 3.
				GdFieldPut("DLD_FORPAG", '1', n)
			EndIf
		EndIf	
	EndIf 
EndIf 

Return xRet 

/*{Protheus.doc} TF65TipPar
Gatilha a DLD
@type Static Function
@author Fabio Marchiori Sampaio
@since 09/04/2021
@version version
@param cCampo, char, Campo Origem
@return xRet, char, Retorno do gatilho
@example
(examples)
@see (links_or_references)
@type function
*/
Static Function TF65TipPar( cCampo , cDest )
				
Local xRet      := Nil
Local oModel	:= Nil
Local oModelDLD := Nil
Local lVgeMod2  := FwIsInCallStack("TA240PAGV")

Default cCampo  := ""
Default cDest   := ""

If !lVgeMod2
	If FwFldGet("DLD_FORPAG") == "3" //-- Tag
		oModel		:= FwModelActive()
		oModelDLD	:= oModel:GetModel("MdGridDLD")
		oModelDLD:LoadValue("DLD_TIPPAR","3") 
		oModelDLD:LoadValue("DLD_RECEB","1") 
	EndIf
Else
	xRet := AllTrim(GdFieldGet("DLD_TIPPAR",n)) 
EndIf

Return xRet
