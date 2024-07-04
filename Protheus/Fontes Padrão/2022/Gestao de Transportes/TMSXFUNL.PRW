#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TMSXFUNG.CH"
#INCLUDE "FWMVCDEF.CH"

Static lTmsRdpU   := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Static cTPDCTMS   := SuperGetMV("MV_TPDCTMS",,"")
Static cCdClFrete := SuperGetMv("MV_CDCLFR",.F.,"")
Static cColGFE    := SuperGetMV( "MV_COLGFE" ,.F., "0" )  //0-Padrão, 1-Encerramento, 2-Nao Integra Coleta
Static aErrGFE   := {}
Static lNumProp  := Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)
Static aDoctos   := {}
Static oModel    := Nil
Static oMdFldGWN := Nil
Static oMdGrdGW1 := Nil
Static oMdGrdGW8 := Nil
Static oMdGrdGWU := Nil
Static oMdGrdGWE := Nil
Static oMdGridGXP:= Nil
Static aCalcRom  := {}
Static lTabDM8   := AliasIndic("DM8")
Static aFornece  := {}

//---------------------------------------------------
/* Processa Viagens para integracao TMS x GFE
@author Katia
@version P12
@since 16/11/2016
//Função removida do fonte TMSFUNGVGE
/*/
//---------------------------------------------------  
Function TMSFUNLVGE(cFilOri, cViagem, nOpc, lAltDocto)
Local aArea 	:= GetArea()
Local lRet      := .F.
Local cChvGFE   := ""
Local cChvDTQ   := ""
Local lAltVge   := .F.
Local cChvRom   := ""
Local cNumRom   := ""
Local lCalcAut  := .T.
Local cMsg      := ""
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local lVgeAntiga := (Left(FunName(),7) == "TMSA140" .Or. Left(FunName(),7) == "TMSA141" .Or. ;
					 Left(FunName(),7) == "TMSA143" .Or. Left(FunName(),7) == "TMSA144")

Default nOpc     := 3
Default lAltDocto:= .F.

LimpaVar()

If lVgeAntiga .Or. !lTabDM8
	//----- Verifica se sera executado o calculo automatico do romaneio apos a integração
	Pergunte("TMB144",.F.)
	If GetRpoRelease() >= "12.1.023"
		If Type("mv_par08") == "N" .And. mv_par08 == 2  //Executa o Calculo do Romaneio Automatico 1-Sim, 2-Não
			lCalcAut:= .F.
		EndIf
	Else
		If Type("mv_par09") == "N" .And. mv_par09 == 2  //Executa o Calculo do Romaneio Automatico 1-Sim, 2-Não
			lCalcAut:= .F.
		EndIf
	EndIf
ElseIf lVgeMod3
	Pergunte("TMSAF60",.F.)
	If Type("mv_par02") == "N" .And. mv_par02 == 2  //Executa o Calculo do Romaneio Automatico 1-Sim, 2-Não
		lCalcAut:= .F.
	EndIf
EndIf

DTQ->( dbSetOrder(2) )
If DTQ->( dbSeek( xFilial("DTQ")+cFilOri+cViagem ) )
	lRet:= DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Sim

	If !lRet
		//Verifica se os Documentos da Viagem tem Redespacho informado (DJN)
		lRet:= VldRedDJN(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
	EndIf

	cChvGFE:= DTQ->DTQ_CHVEXT
	cChvDTQ:= DTQ->DTQ_CHVEXT

	lAltVge:= Iif(!Empty(cChvDTQ),.T.,.F.)

	If lAltVge
		//---- Uma vez integrado ao GFE, verifica se o Romaneio poderá ser aberto.
		cNumRom:= TmsRomGWN(cChvDTQ,'1')
	EndIf

EndIf

//--- DOCUMENTOS DE CARGA
If lRet

	//--- Inicio do Processamento
	TMSFUNLPRC(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,lAltVge,cNumRom,cChvGFE,cChvDTQ,lCalcAut,nOpc,lAltDocto)

	If Valtype(oModel) == "O" 
		If oModel:VldData()
			lRet := oModel:CommitData()
			If lRet
				cChvRom:= GWN->GWN_FILIAL + ';' + GWN->GWN_NRROM 

				If lCalcAut .And. aScan(aCalcRom, GWN->GWN_FILIAL + GWN->GWN_NRROM ) == 0
					aAdd(aCalcRom, GWN->GWN_FILIAL + GWN->GWN_NRROM )
				EndIf
			EndIf
		Else
			cMsg := STR0002+CRLF+CRLF+oModel:GetErrorMessage()[6] //"Inconsistência com o Frete Embarcador (SIGAGFE): "##
			lRet := .F.
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
	EndIf

	//--- Atualiza Tabelas TMS
	If lRet .And. !Empty(cChvRom)
		//Grava o Romaneio na chave externa nas tabelas 
		TMSLChvDTQ(cChvRom)

		TMSLChvDOC(cChvRom,lTabDM8)

		If GWN->GWN_SIT == StrZero( 1, Len( GWN->GWN_SIT ) )  //Digitado
			GFE50LbRom()
		EndIf
				
		//---- Chamada do Calculo do Romaneio (Automatico ou que houve alteração com a inclusao do novo trecho)
		If Len(aCalcRom) > 0 .And. FindFunction('TMSCALROM')
			MsgRun( STR0006 , STR0007, {|| CursorWait(), lRet:= TMSCALROM(aCalcRom,@aErrGFE,.F.) , CursorArrow()})   //Aguarde... Recalculando o Romaneio

			If Len(aErrGFE) > 0
				TmsMsgErr(aErrGFE)
				lRet:= .T.   //Temporario apos definicao do calculo do GFE
			EndIf
		EndIf
	EndIf

EndIf

If !lRet .And. !Empty(cMsg)
	Help( ,, 'Atencao',,cMsg, 1, 0 ) //"Atenção"
EndIf

//---- Limpa Variaveis
LimpaVar()

RestArea( aArea )
Return lRet

//-----------------------------------------------------
/*/	Monta os dados para a geração do Romaneio (GWN)
@author Katia
@version P12.1.33
@since 11/07/2021
@Função removida do fonte TMSFUNGDFT
/*/
//------------------------------------------------------
Function TMSFUNLROM(nOpc,cChvGFE,cCdtpop,cCdclfr,cUfOri,cCdMunO,cUfDes,cCdMunD,nReqDTQ,cCepOri,cCepDes,lCalcAut)
Local cCgcTransp:= ""
Local cTransp   := ""
Local nQtdKm	:= 0
Local lViagem	:= .F.
Local cCodMot	:= ""
Local cFornec	:= ""
Local cLojFor	:= ""
Local cFilGWN	:= ""
Local lRet      := .T.

Default cChvGFE := ""
Default cCdtpop	:= ""
Default cCdclfr	:= ""
Default cUfOri  := ""
Default cCdMunO := ""
Default cUfDes  := ""
Default cCdMunD := ""
Default nReqDTQ	:= 0   //---- Integracao Viagem TMSA144
Default cCepOri	:= ""
Default cCepDes	:= ""
Default lCalcAut	:= .T.

	If nReqDTQ > 0
		lViagem:= .T.
		DTQ->(DbGoTo(nReqDTQ))
		cFilGWN:= DTQ->DTQ_FILORI
	Else
		cFilGWN:= xFilial("DFV")
		If lTmsRdpU
			cFilGWN:= DFT->DFT_FILORI
		EndIf
	EndIf

	//--- Inicio do Modelo GFEX300
	oModel := FWLoadModel( "GFEX300" )
    oModel:SetOperation( nOpc )
    oModel:Activate()

	oMdFldGWN:= oModel:GetModel("MdFieldGWN")
	oMdGrdGW1:= oModel:GetModel("MdGridGW1")
	oMdGrdGW8:= oModel:GetModel("MdGridGW8")
	oMdGrdGWU:= oModel:GetModel("MdGridGWU")
	oMdGrdGWE:= oModel:GetModel("MdGridGWE")

	If !lViagem
		aFornece:= TMSGBscFav(,,DFT->DFT_CODFOR,DFT->DFT_LOJFOR)  
	Else
		aFornece:= TMSGBscFav(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM) 
		cCodMot := TMSGBscMot(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
	EndIf
	If Len(aFornece) > 0			
		cFornec:= aFornece[1]
		cLojFor:= aFornece[2]
		cTransp:= aFornece[3]

		cCgcTransp:= TMSGBscCGC(cTransp,cFornec,cLojFor,lNumProp)
	EndIf

	nQtdKm:= PesqKMVge()

	//--- Carrega dados para o MdlFldGWN (Romaneio GWN)
	oMdFldGWN:LoadValue('GWN_FILIAL', cFilGWN )
	oMdFldGWN:LoadValue('GWN_ORI'   , "3")
	If !Empty(cUfOri) .And. !Empty(cCdMunO)
		oMdFldGWN:LoadValue('GWN_NRCIDO', TMS120CDUF(cUfOri, "1") + cCdMunO )
	EndIf
	If !Empty(cUfDes) .And. !Empty(cCdMunD)
		oMdFldGWN:LoadValue('GWN_NRCIDD', TMS120CDUF(cUfDes, "1") + cCdMunD)
	EndIf
	oMdFldGWN:LoadValue('GWN_SIT'   , "1")  //Digitado
	oMdFldGWN:LoadValue('GWN_CDTPOP', cCdtpop)
	oMdFldGWN:LoadValue('GWN_CDCLFR', cCdclfr )
	oMdFldGWN:SetValue('GWN_CDTRP' , cCGCTransp)
	oMdFldGWN:LoadValue('GWN_DTIMPL', dDatabase)
	oMdFldGWN:LoadValue('GWN_HRIMPL', SubStr(Time(),1,5))

	If lViagem
		oMdFldGWN:LoadValue('GWN_CEPO'   , cCepOri )
		oMdFldGWN:LoadValue('GWN_CEPD'   , cCepDes)
		oMdFldGWN:LoadValue('GWN_CDMTR'  , cCodMot )
		oMdFldGWN:LoadValue('GWN_CDTPVC' , DTQ->DTQ_TIPVEI  )
		DTR->(dbSetOrder(3))
		If DTR->(dbSeek(xFilial('DTR')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
			oMdFldGWN:LoadValue('GWN_PLACAD' , Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_PLACA'))
			oMdFldGWN:LoadValue('GWN_PLACAM' , Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODRB1,'DA3_PLACA'))
			oMdFldGWN:LoadValue('GWN_PLACAT' , Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODRB2,'DA3_PLACA'))
		EndIf
		oMdFldGWN:LoadValue('GWN_DISTAN' , nQtdKm )
	EndIf

	lRet:= oModel:VldData()
	If !lRet
		cMsg := STR0002+CRLF+CRLF+oModel:GetErrorMessage()[6]//"Inconsistência com o Frete Embarcador (SIGAGFE): "##
		Help( ,, 'Atencao',,cMsg, 1, 0 ) //"Atenção"
	EndIf

Return lRet

//---------------------------------------------------
/*/Intregração TMS - Redespachantes x Documentos
@author Katia
@version P11
@since 04/10/2013
//Função removida do fonte TMSFUNGDFV
/*/
//---------------------------------------------------
Function TMSFUNLDOC(nRecnoDFV, lViagem, nRecnoDUD , nRecnoDT6, nRecnoDTC )

Local aArea      := GetArea()
Local nI         := 0
Local cEmisDc    := ""
Local nAltura    := 0
Local nVolume    := 0
Local cDsitem    := ""
Local cCdTpDc    := Padr(cTPDCTMS,Len(GW1->GW1_CDTPDC)) 
Local lRet	     := .F.
Local cTransp    := ""
Local nOpc		 := 0
Local nTrecho    := 0
Local cA1_EstDes := ""
Local cA1_CdMuDes:= ""
Local cTipVei    := ""
Local cFilDoc		:= ""
Local cDoc			:= ""
Local cSerie		:= ""
Local cCHVEXT		:= ""
Local cCodFor		:= ""
Local cLojFor		:= ""
Local cA1_CEPDes	:= ""
Local lSeqEnd		:= .F.
Local cCodUF		:= ""
Local cMunEnt		:= ""
Local lDadosDUA     := .F.
Local lSeekGW1      := .F.
Local cCdDest       := ""
Local nQtdVol       := 0

Default nRecnoDFV	:= 0
Default lViagem	:= .F.
Default nRecnoDUD	:= 0
Default nRecnoDT6	:= 0
Default nRecnoDTC	:= 0

If nRecnoDFV > 0
	DFV->(MsGoto( nRecnoDFV ))
	lRet:= .T.
	cFilDoc:= DFV->DFV_FILDOC
	cDoc   := DFV->DFV_DOC
	cSerie := DFV->DFV_SERIE
	cCHVEXT:= DFV->DFV_CHVEXT
	cCDCLFR:= DFV->DFV_CDCLFR
	cCodFor:= DFV->DFV_CODFOR
	cLojFor:= DFV->DFV_LOJFOR

ElseIf nRecnoDUD > 0 .And. lViagem
	DUD->(MsGoto( nRecnoDUD ))
	lRet:= .T.
	cFilDoc:= DUD->DUD_FILDOC
	cDoc   := DUD->DUD_DOC
	cSerie := DUD->DUD_SERIE
	cCHVEXT:= DUD->DUD_CHVEXT
	cCDCLFR:= DUD->DUD_CDCLFR
	cTipVei:= DUD->DUD_TIPVEI

	If Len(aFornece) > 0	//Fornecedor da Viagem		
		cCodFor:= aFornece[1]
		cLojFor:= aFornece[2]
		cTransp:= aFornece[3]
	EndIf
EndIf

If lRet
	DT6->(DbGoTo(nRecnoDT6))
	If DT6->DT6_SERTMS <> StrZero(1,Len(DT6->DT6_SERTMS))
		DTC->(DbGoTo(nRecnoDTC))			
			
		If lNumProp
			cEmisDc:= OMSM011COD(DTC->DTC_CLIREM,DTC->DTC_LOJREM,1,,)
		Else
			cEmisDc:= Posicione("SA1",1,xFilial("SA1")+DTC->DTC_CLIREM+DTC->DTC_LOJREM,"A1_CGC")
		EndIf

		If !oMdGrdGW1:IsEmpty()
			lSeekGW1:= oMdGrdGW1:SeekLine({ {'GW1_EMISDC', cEmisDc }, {'GW1_CDTPDC', cCDTPDC}, {'GW1_SERDC',DTC->DTC_SERNFC}, {'GW1_NRDC',DTC->DTC_NUMNFC} })
			If lSeekGW1
				nQtdVol:= oMdGrdGW1:GetValue('GW1_QTVOL') + DTC->DTC_QTDVOL
				oMdGrdGW1:LoadValue('GW1_QTVOL', nQtdVol  )
			EndIf
		EndIf

		//--- Dados cliente destinatario da Nota
		PsqCliDest(DTC->DTC_CLIDES,DTC->DTC_LOJDES,@cCdDest,@cA1_EstDes,@cA1_CdMuDes,@cA1_CEPDes)  //GW1_CDDEST
			
		nOpc:= 3  
		If !lSeekGW1 
			//--- Verifica se o Documento ja foi integrado ao SIGAGFE
			GW1->( dbSetOrder(1) )
			cSeekGW1:= Iif(lViagem,DTQ->DTQ_FILORI,xFilial("GW1"))+PadR(cCDTPDC,Len(GW1->GW1_CDTPDC))+cEmisDc+PadR(DTC->DTC_SERNFC,Len(GW1->GW1_SERDC))+PadR(DTC->DTC_NUMNFC,Len(GW1->GW1_NRDC))
			If GW1->( dbSeek(cSeekGW1  ))
				nOpc:= 4
			EndIf
			//---
			
		   	If nOpc == 3   
			    //Documento de Carga GW1
			    aAdd(aDoctos, nRecnoDUD)
	
				If !oMdGrdGW1:IsEmpty()
					oMdGrdGW1:AddLine() 
				EndIf

				oMdGrdGW1:LoadValue('GW1_FILIAL', Iif(lViagem,DTQ->DTQ_FILORI,xFilial("GW1"))  )
				oMdGrdGW1:LoadValue('GW1_CDTPDC', cCdTpDc   )
				oMdGrdGW1:LoadValue('GW1_SERDC' , DTC->DTC_SERNFC )
				oMdGrdGW1:LoadValue('GW1_NRDC'  , DTC->DTC_NUMNFC )
				oMdGrdGW1:LoadValue('GW1_DTPENT', DTC->DTC_PRVENT )
				oMdGrdGW1:LoadValue('GW1_DTEMIS', DTC->DTC_EMINFC )					
				oMdGrdGW1:LoadValue('GW1_ORIGEM', "3"  )
				oMdGrdGW1:LoadValue('GW1_CDREM' , cEmisDc )
				oMdGrdGW1:SetValue('GW1_EMISDC', cEmisDc  )
				oMdGrdGW1:LoadValue('GW1_CDDEST', cCdDest )
				oMdGrdGW1:LoadValue('GW1_USUIMP', cUserName )
				oMdGrdGW1:LoadValue('GW1_SIT'  , '4' )   //4-Embarcado, não valida se tem romaneio, pois o romaneio sera incluido com o docto de carga automaticamente
				oMdGrdGW1:LoadValue('GW1_DTIMPL', DT6->DT6_DATEMI )
				oMdGrdGW1:LoadValue('GW1_HRIMPL', DT6->DT6_HOREMI )
				oMdGrdGW1:LoadValue('GW1_AUTSEF', "0") //Nao Informado
				oMdGrdGW1:LoadValue('GW1_TPFRET', "1")   //CIF
				oMdGrdGW1:LoadValue('GW1_DTLIB' , DATE())
				oMdGrdGW1:LoadValue('GW1_HRLIB' , SubStr(TIME(),1,5) )
				oMdGrdGW1:LoadValue('GW1_DANFE' , DTC->DTC_NFEID)
				oMdGrdGW1:LoadValue('GW1_ICMSDC', IIF(DTC->DTC_VALICM == 0 , "2" , "1") )
				oMdGrdGW1:LoadValue('GW1_QTVOL' , DTC->DTC_QTDVOL  )	

				//---- Endereco de Entrega
				If lViagem .Or. lTmsRdpU
					lSeqEnd:= .F.
					If !Empty(DTC->DTC_SQEDES)
						DUL->(DbSetOrder(2))
						If DUL->(MsSeek( xFilial('DUL') + DTC->DTC_CLIDES + DTC->DTC_LOJDES + DTC->DTC_SQEDES ))
							lSeqEnd:= .T.
						EndIf
					EndIf
					oMdGrdGW1:LoadValue('GW1_ENTEND', Iif(lSeqEnd, DUL->DUL_END, SA1->A1_ENDENT)  )
					oMdGrdGW1:LoadValue('GW1_ENTCEP', Iif(lSeqEnd, DUL->DUL_CEP, SA1->A1_CEPE ) )
					oMdGrdGW1:LoadValue('GW1_ENTBAI', Iif(lSeqEnd, DUL->DUL_BAIRRO, SA1->A1_BAIRROE ))
			
					cMunEnt:= Iif(lSeqEnd, DUL->DUL_CODMUN, SA1->A1_CODMUNE )
					If !Empty(cMunEnt)
						cCodUF:= TMS120CdUf(Iif(lSeqEnd, DUL->DUL_EST, SA1->A1_ESTE ), '1')
						oMdGrdGW1:LoadValue('GW1_ENTNRC', cCodUF + cMunEnt )
					EndIf
					
				EndIf
				
				If lRet
					//-- Atualiza Tabela GWE (Relacionamento GW1 e DT6)
					TMSFUNLGWE(Iif(lViagem,DUD->DUD_FILDOC,DFV->DFV_FILDOC),;
							Iif(lViagem,DUD->DUD_DOC,DFV->DFV_DOC),;
							Iif(lViagem,DUD->DUD_SERIE,DFV->DFV_SERIE),;
							Iif(lViagem,DUD->DUD_FILORI,DFV->DFV_FILORI),;
							Iif(lViagem,DUD->DUD_VIAGEM,''),;
							Iif(lViagem,,DFV->DFV_NUMRED),;
							cCdTpDc,;
							cEmisDc,;
							DTC->DTC_SERNFC,;
							DTC->DTC_NUMNFC )
				EndIf
			EndIf
		EndIf

		If nOpc == 3
			//---- Itens do Documentos DTC x Documento de Carga (GW8)
			nAltura := Posicione("SB5",1,xFilial("SB5")+ (DTC->DTC_CODPRO),"B5_ALTURA")
			nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR)* (DTC->DTC_QTDVOL)
			cDsitem := SubStr(Posicione("SB1",1,xFilial("SB1")+DTC->DTC_CODPRO,"B1_DESC"),1,50)
			nI:= 1		
				
			If !oMdGrdGW8:IsEmpty()
				oMdGrdGW8:AddLine()
				nI:= oMdGrdGW8:GetLine()
			EndIf

			oMdGrdGW8:LoadValue('GW8_CDTPDC', cCdTpDc )
			oMdGrdGW8:LoadValue('GW8_EMISDC', cEmisDc )
			oMdGrdGW8:LoadValue('GW8_SERDC' , DTC->DTC_SERNFC  )
			oMdGrdGW8:LoadValue('GW8_NRDC'  , DTC->DTC_NUMNFC )
			oMdGrdGW8:LoadValue('GW8_SEQ'   , MsStrZero(nI,2))
			oMdGrdGW8:LoadValue('GW8_ITEM'  , DTC->DTC_CODPRO )
			oMdGrdGW8:LoadValue('GW8_CDCLFR', Iif(Empty(cCDCLFR),cCdClFrete,cCDCLFR) )
			oMdGrdGW8:LoadValue('GW8_DSITEM', cDsitem )
			oMdGrdGW8:LoadValue('GW8_QTDE'  , DTC->DTC_QTDVOL,)
			oMdGrdGW8:LoadValue('GW8_VALOR' , DTC->DTC_VALOR ,)
			oMdGrdGW8:LoadValue('GW8_VOLUME', Iif(nVolume <> 0, nVolume, DTC->DTC_METRO3 ),)
			oMdGrdGW8:LoadValue('GW8_PESOR' , DTC->DTC_PESO  )
			oMdGrdGW8:LoadValue('GW8_PESOC' , DTC->DTC_PESOM3 )
			oMdGrdGW8:LoadValue('GW8_CFOP'  , SubStr(DTC->DTC_CF,1,TamSx3("GW8_CFOP")[1]) )


			//----Trecho do Documento de Carga
			If !lViagem
				DVU->(DbSetOrder(1)) //DVU_FILIAL+DVU_FILORI+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM+DVU_ITEM
				If DVU->(DbSeek(xFilial("DVU")+DTC->DTC_FILORI+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM ))
					cTipVei:= DVU->DVU_TIPVEI   //Pegar o primeiro
				EndIf
			EndIf

			nTrecho:= 0
			TMSFUNLTRE(nOpc,cCdTpDc,cEmisDc,Iif(lViagem,'',DFV->DFV_UFDES),Iif(lViagem,'',DFV->DFV_CDMUND),DTC->DTC_NUMNFC,;
			           DTC->DTC_SERNFC,cTransp,@nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,lViagem,cA1_CEPDes,cCodFor,cLojFor)

			If nTrecho > 1
				oMdGrdGW1:LoadValue('GW1_TPFRET', "2" ) //CIF COM REDESPACHO
			EndIf
		EndIf
		
	Else

		//---- Coleta
		DT5->(DbSetOrder( 4 ))
		If DT5->(MsSeek(xFilial('DT5')+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))

			If cColGFE == '1' 
				nRecDUA:= TMSUltOcor(DUD->DUD_FILORI,DUD->DUD_VIAGEM,DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE)		
				//Considera os dados da DUA (peso, volume, valor) caso encontrar ocorrencia para a Coleta, se Nao, considera a DUM	  
				lDadosDUA:= nRecDUA > 0 
			EndIf

			cEmisDc:= PesqEmisDC()
			
			lRet:= .T.
			nOpc:= 3
			//--- Verifica se o Documento ja foi integrado ao SIGAGFE
			cCDTPDC:= 'COL' //- Para coleta será fixo.

			GW1->( dbSetOrder(1) )
			If GW1->( dbSeek( Iif(lViagem,DTQ->DTQ_FILORI,xFilial("GW1"))+PadR(cCDTPDC,Len(GW1_CDTPDC))+cEmisDc+PadR('COL',Len(GW1->GW1_SERDC))+PadR(DT5->DT5_NUMSOL,Len(GW1->GW1_NRDC)) ))
				nOpc:= 4
				//--- Verifica se o Documento ja foi integrado ao SIGAGFE
				lRet:= TmsChkGWN(DT5->DT5_FILORI,DT5->DT5_NUMSOL,'COL',PadR(GW1->GW1_FILIAL, TamSx3("GWN_FILIAL")[1] ) + GW1->GW1_NRROM,.T.)
				//---
			EndIf

		   	If nOpc == 3
			   	aAdd(aDoctos, nRecnoDUD)

				If !oMdGrdGW1:IsEmpty()
					oMdGrdGW1:AddLine() 
				EndIf
								   
				//Cabeçalho do Documento de Carga
				oMdGrdGW1:LoadValue('GW1_FILIAL' , xFilial("GW1") )
				oMdGrdGW1:LoadValue('GW1_CDTPDC' , cCdTpDc )
				oMdGrdGW1:LoadValue('GW1_SERDC'  , 'COL' )
				oMdGrdGW1:LoadValue('GW1_NRDC'   , DT5->DT5_NUMSOL )
				oMdGrdGW1:LoadValue('GW1_DTEMIS' , DT5->DT5_DATSOL )
				oMdGrdGW1:LoadValue('GW1_ORIGEM', "3" )
				oMdGrdGW1:LoadValue('GW1_CDREM'  , cEmisDc )
				oMdGrdGW1:SetValue('GW1_EMISDC' , cEmisDc )
				
				If Empty(DT5->DT5_CLIDES)
					PesqDest(@cCdDest,@cA1_EstDes,@cA1_CdMuDes,@cA1_CEPDes)  //GW1_CDDEST
				Else
					PsqCliDest(DT5->DT5_CLIDES,DT5->DT5_LOJDES,@cCdDest,@cA1_EstDes,@cA1_CdMuDes,@cA1_CEPDes)  //GW1_CDDEST
				EndIf

				oMdGrdGW1:LoadValue('GW1_CDDEST', cCdDest)
				oMdGrdGW1:LoadValue('GW1_USUIMP', cUserName )			
				oMdGrdGW1:LoadValue('GW1_SIT'  , '4' )   //4-Embarcado, não valida se tem romaneio, pois o romaneio sera incluido com o docto de carga automaticamente
				oMdGrdGW1:LoadValue('GW1_DTIMPL', DT5->DT5_DATSOL )
				oMdGrdGW1:LoadValue('GW1_HRIMPL', DT5->DT5_HORSOL)
				oMdGrdGW1:LoadValue('GW1_AUTSEF', "0" ) //Nao Informado
				oMdGrdGW1:LoadValue('GW1_TPFRET', "1" ) //CIF
				oMdGrdGW1:LoadValue('GW1_DTLIB' , DATE() )
				oMdGrdGW1:LoadValue('GW1_HRLIB' , SubStr(TIME(),1,5))
	
				//--- Endereco de Entrega
				If lViagem
					If !Empty(DT5->DT5_SQEDES)
						DUL->(DbSetOrder(3))
						If DUL->(MsSeek( xFilial('DUL') + DT5->DT5_CODSOL + DT5->DT5_SEQEND ))
							oMdGrdGW1:LoadValue('GW1_ENTEND', DUL->DUL_END )
							oMdGrdGW1:LoadValue('GW1_ENTCEP', DUL->DUL_CEP )
							oMdGrdGW1:LoadValue('GW1_ENTBAI', DUL->DUL_BAIRRO)

							If !Empty(DUL->DUL_CODMUN)
								cCodUF:= TMS120CdUf(DUL->DUL_CODMUN, '1')
								oMdGrdGW1:LoadValue('GW1_ENTNRC', cCodUF + DUL->DUL_CODMUN)
							EndIf
						EndIf
					EndIf
				EndIf

				//---- Itens do Documentos DUM 
				nI:= 1
				DbSelectArea("DUM")
				DbSetOrder(1) //-- DUM_FILIAL+DUM_FILORI+DUM_NUMSOL+DUM_ITEM
				MsSeek(xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL ,.F.)
				While DUM->(!Eof()) .And.  (DUM->(DUM_FILIAL+DUM_FILORI+DUM_NUMSOL) == (xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL))
					If !oMdGrdGW8:IsEmpty()
						oMdGrdGW8:AddLine()
						nI:= oMdGrdGW8:GetLine()
					EndIf

					//Itens do Documento de Carga
					nQtdVol:= 0
					oMdGrdGW8:LoadValue('GW8_CDTPDC', cCdTpDc)
					oMdGrdGW8:LoadValue('GW8_EMISDC', cEmisDc )
					oMdGrdGW8:LoadValue('GW8_SERDC' , 'COL')
					oMdGrdGW8:LoadValue('GW8_NRDC'  , DT5->DT5_NUMSOL)
					oMdGrdGW8:LoadValue('GW8_SEQ'   , MsStrZero(nI,2))
					oMdGrdGW8:LoadValue('GW8_ITEM'  , DUM->DUM_CODPRO)
					oMdGrdGW8:LoadValue('GW8_CDCLFR', Iif(Empty(cCDCLFR),cCdClFrete,cCDCLFR))
				
					nAltura := Posicione("SB5",1,xFilial("SB5")+ (DUM->DUM_CODPRO),"B5_ALTURA")
					nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR)* (DUM->DUM_QTDVOL)
					cDsitem := SubStr(Posicione("SB1",1,xFilial("SB1")+DUM->DUM_CODPRO,"B1_DESC"),1,50)
					oMdGrdGW8:LoadValue( 'GW8_DSITEM', cDsitem )
					
					If !lDadosDUA
						//Considera somente o primeiro Produto, pois as quantidades estarao agrupadas nas ocorrencias (DUA)
						oMdGrdGW8:LoadValue('GW8_QTDE'  , DUM->DUM_QTDVOL)
						oMdGrdGW8:LoadValue('GW8_VALOR' , DUM->DUM_VALMER)
						oMdGrdGW8:LoadValue('GW8_VOLUME', Iif( nVolume <> 0, nVolume, DUM->DUM_METRO3))
						oMdGrdGW8:LoadValue('GW8_PESOR' , DUM->DUM_PESO )
						oMdGrdGW8:LoadValue('GW8_PESOC' , DUM->DUM_PESOM3)
					Else	
						DUA->(DbGoTo(nRecDUA))
						nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR)* (DUA->DUA_QTDOCO)
						oMdGrdGW8:LoadValue('GW8_QTDE'  , DUA->DUA_QTDOCO,)
						oMdGrdGW8:LoadValue('GW8_VALOR' , DUA->DUA_VLROCO)
						oMdGrdGW8:LoadValue('GW8_VOLUME', Iif( nVolume <> 0, nVolume, DUA->DUA_MT3OCO))
						oMdGrdGW8:LoadValue('GW8_PESOR' , DUA->DUA_PESOCO)
						oMdGrdGW8:LoadValue('GW8_PESOC' , DUA->DUA_PM3OCO )
						Exit
					EndIf
					nQtdVol:= oMdGrdGW8:GetValue('GW8_VOLUME') + oMdGrdGW1:GetValue('GW1_QTVOL') 
					oMdGrdGW1:LoadValue('GW1_QTVOL',nQtdVol) 

					DUM->(DbSkip())
				EndDo

				If Len(aErrGFE) > 0
					lRet:= .F.  
				EndIf
			EndIf

			If lRet
				//----Trecho do Documento de Carga
				DUD->(DbSetOrder(1)) //DVU_FILIAL+DVU_FILORI+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM+DVU_ITEM
				If DUD->(DbSeek(xFilial("DUD")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))
					cTipVei:= DUD->DUD_TIPVEI
				EndIf

				nTrecho:= 0
				TMSFUNLTRE(nOpc,cCdTpDc,cEmisDc,'','',DT5->DT5_NUMSOL,;
				           'COL',cTransp,@nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,.T.,cA1_CEPDes,cCodFor,cLojFor)

				If nTrecho > 1
					oMdGrdGW1:LoadValue('GW1_TPFRET', "2" ) //CIF COM REDESPACHO					
				EndIf

				//---- Documentos de Origem GXP
				If AliasIndic('GXP')
					TMSFUNLSOL(DT5->DT5_FILORI, DT5->DT5_NUMSOL)  
				EndIf

			EndIf

			If lRet
				//-- Atualiza Tabela GWE (Relacionamento GW1 e DT6)
				TMSFUNLGWE(DUD->DUD_FILDOC,DUD->DUD_DOC,'COL',DUD->DUD_FILORI, DUD->DUD_VIAGEM,'',;
								cCdTpDc,cEmisDc,'COL',DT5->DT5_NUMSOL )
			EndIf
		EndIf

	EndIf
EndIf

RestArea( aArea )
Return lRet

//---------------------------------------------------
/*/
Trechos do Documento de Carga
@author Katia
@version P11
@since 14/10/2013
//Função removida do fonte TMSFUNGTRE
/*/
//---------------------------------------------------
Function TMSFUNLTRE(nOpc,cCdTpDc,cEmisDc,cUfDes,cCdMunDes,cNumNFC,cSerNFC,cTransp,nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,lViagem,;
                    cA1_CEPDes,cCodFor,cLojFor)
Local cSeq       := CriaVar('GWU_SEQ')
Local lRet       := .T.
Local aArea      := GetArea()
Local cCepD      := ""
Local cTranspGWU := ""
Local lUltTrecho := .F.
Local cCepOGWU   := ""
Local cCdMunOGWU := ""
Local cEntNrc    := ""
Local cEntCep    := ""
Local cCgcTransp := ""
Local lPrimTrech := .T.

Default cCdTpDc     := ""
Default cEmisDc     := ""
Default cUfDes      := ""
Default cCdMunDes   :=""
Default cNumNFC     := ""
Default cSerNFC     := ""
Default cTransp     := ""
Default nTrecho     := 1
Default cA1_EstDes  := ""
Default cA1_CdMuDes := ""
Default cTipVei     := ""
Default lViagem     := .F.
Default cA1_CEPDes  := ""
Default cCodFor     := ""
Default cLojFor     := ""

cSeq:= Soma1(cSeq)
If nOpc == 4
	GWN->( dbSetOrder(1) )
	If GWN->( dbSeek(xFilial("GWN") + GW1->GW1_NRROM) ) .And. GWN->GWN_SIT $ "3|4"  //Liberado e ou Encerrado
		If !lViagem .And. !lTmsRdpU
			If GWN->GWN_SIT $ "3"
				lRet:= GFEA050REA(.T.)   //Reabre o Romaneio
				If ValType(lRet) <> 'L'
					lRet:= .F.
				EndIf
			ElseIf GWN->GWN_SIT $ "4"
				lRet:= .F.
			EndIf
		EndIf
	EndIf
	If lRet
		GWU->( dbSetOrder(1) )
		GWU->( dbSeek(xFilial("GWU") + cCdTpDc+ cEmisDc + PADR(cSerNFC,LEN(GWU->GWU_SERDC))+ PADR(cNumNFC,LEN(GWU->GWU_NRDC))+ 'z', .T. ) )
		GWU->(dbSkip( -1 ))
		If GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC) == xFilial("GWU") + cCdTpDc+ cEmisDc + PADR(cSerNFC,LEN(GWU->GWU_SERDC))+ PADR(cNumNFC,LEN(GWU->GWU_NRDC))
	   		cSeq:= GWU->GWU_SEQ
	   		cSeq:= Soma1(cSeq)
	   	EndIf
	EndIf
EndIf

If lRet

 	oMdGrdGWU:LoadValue( 'GWU_CDTPDC', cCdTpDc )
	oMdGrdGWU:LoadValue( 'GWU_EMISDC', cEmisDc )
	oMdGrdGWU:LoadValue( 'GWU_SERDC' , cSerNFC )
	oMdGrdGWU:LoadValue( 'GWU_NRDC'  , cNumNFC )
	oMdGrdGWU:LoadValue( 'GWU_SEQ'   , cSeq )

	//--- CGC Fornecedor
	cCgcTransp:= TMSGBscCGC(cTransp,cCodFor,cLojFor,lNumProp)

	oMdGrdGWU:SetValue( 'GWU_CDTRP' , cCgcTransp)
	
	//---- Primeiro Trecho (NAO PAGAR) --Origem do Documento é diferente da Origem informado no Trecho Inicial, gera o primeiro trecho como não pago
	If nOpc == 3 .And. lPrimTrech .And. !lViagem
		DT6->( dbSetOrder( 1 ) )
		If DT6->( DbSeek( xFilial('DT6') + DFV->(DFV_FILDOC+DFV_DOC+DFV_SERIE ) ))
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial('SA1')+DT6->DT6_CLIREM+DT6->DT6_LOJREM)) .And. !Empty(SA1->A1_EST) .And. !Empty(SA1->A1_COD_MUN)
				If rTrim(TMS120CdUf(DFV->DFV_UFORI, "1") + DFV->DFV_CDMUNO ) <> TMS120CDUF(SA1->A1_EST, "1") + SA1->A1_COD_MUN
					oMdGrdGWU:LoadValue('GWU_PAGAR' , "2"  )   //Pagar NAO
					oMdGrdGWU:LoadValue('GWU_CEPO'  , SA1->A1_CEP)
					oMdGrdGWU:LoadValue('GWU_NRCIDO', TMS120CDUF(SA1->A1_EST, "1") + SA1->A1_COD_MUN )
					oMdGrdGWU:LoadValue('GWU_CEPD'  , DFV->DFV_CEPORI )
					oMdGrdGWU:LoadValue('GWU_NRCIDD', rTrim(TMS120CdUf(DFV->DFV_UFORI, "1") + DFV->DFV_CDMUNO ))
					oMdGrdGWU:LoadValue('GWU_CDTPVC', DFV->DFV_TIPVEI)
					oMdGrdGWU:LoadValue('GWU_CDTPOP', DFV->DFV_CDTPOP)
					oMdGrdGWU:LoadValue('GWU_CDCLFR', DFV->DFV_CDCLFR )
					oMdGrdGWU:LoadValue('GWU_CHVEXT', 'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED  )
					oMdGrdGW1:LoadValue('GW1_TPFRET', "2" )  //CIF COM Redespacho

					cSeq:= Soma1(cSeq)
					oMdGrdGWU:AddLine()
					oMdGrdGWU:GoLine(Val(AllTrim(cSeq)))
				EndIf	
			EndIf	
		EndIf
	EndIf


	//----- Redespacho (DFT/DFV)
	If !lViagem .And. !lTmsRdpU
		//---- Primeiro Trecho 'A pagar'
		oMdGrdGWU:LoadValue( 'GWU_PAGAR' , "1" )
		oMdGrdGWU:LoadValue('GWU_NRCIDD', rTrim(TMS120CdUf(DFV->DFV_UFDES, "1") + DFV->DFV_CDMUND ) )
		oMdGrdGWU:LoadValue( 'GWU_CDTPVC', cTipVei )
		oMdGrdGWU:LoadValue( 'GWU_CHVEXT', 'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED )
		oMdGrdGWU:LoadValue('GWU_NRCIDO', rTrim(TMS120CdUf(DFV->DFV_UFORI, "1") + DFV->DFV_CDMUNO )  )
	
	    //---- Se a regiao de destino do cliente destinatário (dtc_clides) for diferente da regiao de destino do redespacho (DFV_CDMUND),
		//---- deve-se criar um segundo Trecho como 'Nao Pagar'
		If !Empty(cA1_CdMuDes) .And. !Empty(DFV->DFV_CDMUND)
			If DFV->DFV_CDMUND <>  cA1_CdMuDes
		   		cSeq:= Soma1(cSeq)
				
				oMdGrdGWU:AddLine()
				oMdGrdGWU:GoLine(Val(AllTrim(cSeq)))
				
				oMdGrdGWU:LoadValue('GWU_NRCIDO', rTrim(TMS120CdUf(DFV->DFV_UFDES, "1") + DFV->DFV_CDMUND )  )  
				oMdGrdGWU:LoadValue('GWU_CDTPDC', cCdTpDc )  
				oMdGrdGWU:LoadValue('GWU_EMISDC', cEmisDc )  
				oMdGrdGWU:LoadValue('GWU_SERDC' , cSerNFC, )  
				oMdGrdGWU:LoadValue('GWU_NRDC'  , cNumNFC )  
				oMdGrdGWU:LoadValue('GWU_SEQ'   , cSeq )  

				//-- CGC do Fornecedor			
				cCgcTransp:= TMSGBscCGC(cTransp,cCodFor,cLojFor,lNumProp)

				oMdGrdGWU:SetValue('GWU_CDTRP' , cCgcTransp  )  
				oMdGrdGWU:LoadValue('GWU_PAGAR' , "2"  )  
				oMdGrdGWU:LoadValue('GWU_NRCIDD', rTrim(TMS120CdUf(cA1_EstDes, "1") + cA1_CdMuDes))  
				oMdGrdGWU:LoadValue('GWU_CDTPVC', cTipVei  )  
				oMdGrdGWU:LoadValue('GWU_CHVEXT', 'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED )  

			EndIf
		EndIf
	Else
		//Quando Redespacho sempre primeiro trecho é Pago
		If lViagem  //----- Viagem (DUD/DJN)
			lPrimTrech:= DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))
		EndIf

		//---- Primeiro Trecho (PAGAR)
		If lPrimTrech
			oMdGrdGWU:SetValue('GWU_CDTRP' , cCgcTransp )
			oMdGrdGWU:LoadValue('GWU_PAGAR' , "1" )
			oMdGrdGWU:LoadValue('GWU_SEQ'   , cSeq )
				
			oMdGrdGWU:LoadValue('GWU_CEPO', Iif(lViagem,DUD->DUD_CEPORI,DFV->DFV_CEPORI) )  
			oMdGrdGWU:LoadValue('GWU_NRCIDO', rTrim(TMS120CdUf(Iif(lViagem,DUD->DUD_UFORI,DFV->DFV_UFORI), "1") + Iif(lViagem,DUD->DUD_CDMUNO,DFV->DFV_CDMUNO) ) )  

			If !Empty(oMdGrdGW1:GetValue( 'GW1_ENTCEP'))  
				cCepD:= oMdGrdGW1:GetValue( 'GW1_ENTCEP')		
			Else
				cCepD:= DUD->DUD_CEPDES
				If Empty(cCepD)
					cCepD:= cA1_CEPDes
				EndIf
			EndIf
			
			oMdGrdGWU:LoadValue('GWU_CEPD', cCepD  )  
			oMdGrdGWU:LoadValue('GWU_NRCIDD', rTrim(TMS120CdUf(Iif(lViagem,DUD->DUD_UFDES,DFV->DFV_UFDES), "1") + Iif(lViagem,DUD->DUD_CDMUND,DFV->DFV_CDMUND) ))  
			oMdGrdGWU:LoadValue('GWU_CDTPVC', Iif(lViagem,DUD->DUD_TIPVEI,Iif(DFV->(ColumnPos('DFV_TIPVEI')) > 0,DFV->DFV_TIPVEI,'') ))  
			oMdGrdGWU:LoadValue('GWU_CDTPOP', Iif(lViagem,DUD->DUD_CDTPOP,DFV->DFV_CDTPOP))  
			oMdGrdGWU:LoadValue('GWU_CDCLFR', Iif(lViagem,DUD->DUD_CDCLFR,DFV->DFV_CDCLFR))  
			oMdGrdGWU:LoadValue('GWU_CHVEXT', Iif(lViagem,'VGMTMS;' + DUD->DUD_FILORI + ';' + DUD->DUD_VIAGEM,;
			                                              'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED ) )  
			nTrecho:= Val(AllTrim(cSeq))
		EndIf

		//--- Redespachos da Viagem
		If lViagem
			If (DTQ->DTQ_SERTMS $ '1|3')
				TMSFLTRRDA(nOpc,nTrecho,@cSeq,cA1_CEPDes,cCdTpDc,.T.)
			EndIf
		Else
			TMSFLTRRDA(nOpc,nTrecho,@cSeq,cA1_CEPDes,cCdTpDc,.F.)
		EndIf

		//--- Quando Destino do Trecho for diferente do Destino do Dcto de Carga e ou Destino de Entrega, incluir um
		//--- trecho Nao Pago para o ultimo transportador do trecho.

		If !Empty(oMdGrdGW1:GetValue( 'GW1_ENTNRC'))
			If !Empty(cA1_EstDes) .And. !Empty(cA1_CdMuDes)
				If oMdGrdGW1:GetValue( 'GW1_ENTNRC') <>  TMS120CDUF(cA1_EstDes, "1") + cA1_CdMuDes
					lUltTrecho:= .T.
				EndIf
			EndIf
		Else
			If !Empty(cA1_EstDes) .And. !Empty(cA1_CdMuDes)
				lUltTrecho:=  oMdGrdGWU:GetValue( 'GWU_NRCIDD') <>  TMS120CDUF(cA1_EstDes, "1") + cA1_CdMuDes
			EndIF
			If !lUltTrecho .And. !Empty(oMdGrdGW1:GetValue( 'GW1_ENTCEP')) .And. !Empty(cA1_CEPDes)
				lUltTrecho:= oMdGrdGW1:GetValue( 'GW1_ENTCEP') <> cA1_CEPDes
			EndIf
		EndIf

		//--- Dados do ultimo Trecho
		cTranspGWU:= oMdGrdGWU:GetValue( 'GWU_CDTRP')  //Transportador do ultimo trecho
		cCepOGWU  := oMdGrdGWU:GetValue( 'GWU_CEPD' )  //Cep destino do ultimo trecho
		cCdMunOGWU:= oMdGrdGWU:GetValue( 'GWU_NRCIDD') //Municipio do ultimo trecho


		If lUltTrecho
			cSeq:= Soma1(cSeq)
			oMdGrdGWU:AddLine()
			oMdGrdGWU:GoLine(Val(AllTrim(cSeq)))

			oMdGrdGWU:LoadValue('GWU_SEQ'   , cSeq) 
			oMdGrdGWU:LoadValue('GWU_EMISDC', cEmisDc ) 
			oMdGrdGWU:LoadValue('GWU_SERDC' , cSerNFC ) 
			oMdGrdGWU:LoadValue('GWU_NRDC'  , cNumNFC) 
			oMdGrdGWU:SetValue('GWU_CDTRP' , cTranspGWU) 
			oMdGrdGWU:LoadValue('GWU_CEPO'  , cCepOGWU  ) 
			oMdGrdGWU:LoadValue('GWU_NRCIDO', cCdMunOGWU) 
			oMdGrdGWU:LoadValue('GWU_NRCIDD', Iif(Empty(cEntNrc),rTrim(TMS120CdUf(cA1_EstDes, "1") + cA1_CdMuDes),cEntNrc) ) 
			oMdGrdGWU:LoadValue('GWU_CEPD', Iif(Empty(cEntCep),cA1_CEPDes,cEntCep)) 
			oMdGrdGWU:LoadValue('GWU_PAGAR' , "2" ) 
			
			If lViagem
				oMdGrdGWU:LoadValue('GWU_CHVEXT', 'VGMTMS;' + DUD->DUD_FILORI + ';' + DUD->DUD_VIAGEM) 
			Else
				oMdGrdGWU:LoadValue('GWU_CHVEXT', 'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED ) 
			EndIf

		EndIf

	EndIf

	nTrecho:= Val(AllTrim(cSeq))
EndIf

RestArea(aArea)
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} 
Função que grava os Trechos dos Redespachos Adicionais
da Viagem (DTQ/DUD) e do Redespacho (DFT/DFV)
@author	Katia
@version	1.0
@since		13/12/2016
@sample    Esta função tem por objetivo gravar os trechos
			do Itinerario com base nos Redespachos da Viagem (DJN)
			e Redespachos Adicionais do Redespacho (DJO)
//Função removida do fonte TMSFGTRRDA			
/*/
//-------------------------------------------------------------------
Function TMSFLTRRDA(nOpc,nTrecho,cSeq,cA1_CEPDes,cCdTpDc,lViagem)
Local cAliasRDA := GetNextAlias()  //Redespacho Adicional
Local cQuery    := ""
Local cCepDes   := ""
Local cCgcTransp:= ""
Local aArea     := GetArea()
Local lContinua := .F.
Local aForTrecho:= {}
Local cFornec   := ""
Local cLojFor   := ""
Local cTransp   := ""

Default nOpc          := 3
Default nTrecho       := 0
Default cSeq          := CriaVar('GWU_SEQ')
Default lViagem       := .F.

//Redespacho Adicional DJN - Viagem,  DJO - Redespacho
If lViagem
	cQuery := " SELECT DJN_FILORI FILORI, DJN_VIAGEM VIAGEM, '' AS NUMRED, DJN_FILDOC FILDOC, DJN_DOC DOC, DJN_SERIE SERIE, DJN_SEQRDP SEQRDP, DJN_CODFOR CODFOR, DJN_LOJFOR LOJFOR,"
	cQuery += "        DJN_UFORI UFORI, DJN_CDMUNO CDMUNO, DJN_CEPORI CEPORI, DJN_UFDES UFDES, DJN_CDMUND CDMUND, DJN_CEPDES CEPDES, DJN_TPFRRD TPFRRD, DJN_TIPVEI TIPVEI, "
	cQuery += "        DJN_CDTPOP CDTPOP, DJN_CDCLFR CDCLFR"
	cQuery += "  FROM " + RetSqlName("DJN") + " DJN "
	cQuery += "  WHERE DJN_FILIAL  = '"+ xFilial("DJN")+"' "
	cQuery += "    AND DJN_FILORI  = '" + DUD->DUD_FILORI + "' "
	cQuery += "    AND DJN_VIAGEM  = '" + DUD->DUD_VIAGEM + "' "
	cQuery += "    AND DJN_FILDOC  = '" + DUD->DUD_FILDOC + "' "
	cQuery += "    AND DJN_DOC = '" + DUD->DUD_DOC + "' "
	cQuery += "    AND DJN_SERIE = '" + DUD->DUD_SERIE + "' "
	cQuery += "    AND DJN.D_E_L_E_T_ = ' ' "
	cQuery += "   ORDER BY DJN_FILORI, DJN_VIAGEM, DJN_FILDOC, DJN_DOC, DJN_SERIE, DJN_SEQRDP "
Else
	cQuery := " SELECT DJO_FILORI FILORI, '' VIAGEM, DJO_NUMRED NUMRED, DJO_FILDOC FILDOC, DJO_DOC DOC, DJO_SERIE SERIE, DJO_SEQRDP SEQRDP, DJO_CODFOR CODFOR, DJO_LOJFOR LOJFOR,"
	cQuery += "        DJO_UFORI UFORI, DJO_CDMUNO CDMUNO, DJO_CEPORI CEPORI, DJO_UFDES UFDES, DJO_CDMUND CDMUND, DJO_CEPDES CEPDES, DJO_TPFRRD TPFRRD, DJO_TIPVEI TIPVEI, "
	cQuery += "        DJO_CDTPOP CDTPOP, DJO_CDCLFR CDCLFR"
	cQuery += "  FROM " + RetSqlName("DJO") + " DJO "
	cQuery += "  WHERE DJO_FILIAL  = '"+ xFilial("DJO")+"' "
	cQuery += "    AND DJO_FILORI  = '" + DFV->DFV_FILORI + "' "
	cQuery += "    AND DJO_NUMRED  = '" + DFV->DFV_NUMRED + "' "
	cQuery += "    AND DJO_FILDOC  = '" + DFV->DFV_FILDOC + "' "
	cQuery += "    AND DJO_DOC = '" + DFV->DFV_DOC + "' "
	cQuery += "    AND DJO_SERIE = '" + DFV->DFV_SERIE + "' "
	cQuery += "    AND DJO.D_E_L_E_T_ = ' ' "
	cQuery += "   ORDER BY DJO_FILORI, DJO_NUMRED, DJO_FILDOC, DJO_DOC, DJO_SERIE, DJO_SEQRDP "
EndIf
cQuery    := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasRDA,.T.,.T.)

While (cAliasRDA)->(!Eof())

	If nTrecho == 0
		If lViagem
			If Len(aFornece) > 0			
				cFornec:= aFornece[1]
				cLojFor:= aFornece[2]
				cTransp:= aFornece[3]
			EndIf
		Else
			aForRedesp:= TMSGBscFav(,,DFT->DFT_CODFOR,DFT->DFT_LOJFOR)  //Fornecedor do Redespacho
			If Len(aForRedesp) > 0			
				cFornec:= aForRedesp[1]
				cLojFor:= aForRedesp[2]
				cTransp:= aForRedesp[3]
			EndIf
		EndIf

		lContinua:= !Empty(cFornec) .And. !Empty(cLojFor)

		If lContinua
			If Empty(cSeq)
				cSeq:= Soma1(cSeq)
			EndIf
			//--- Primeiro Trecho nao pago - Quando a viagem foi realizada por um TAC.
			cCgcTransp:= TMSGBscCGC(cTransp,cFornec,cLojFor,lNumProp)

			oMdGrdGWU:LoadValue('GWU_CDTPDC', cCdTpDc)	
			oMdGrdGWU:SetValue('GWU_CDTRP' , cCgcTransp)

			//---- Destino do primeiro trecho do TAC considera a Origem do Primeiro Redespacho Adicional
			oMdGrdGWU:LoadValue( 'GWU_NRCIDD', TMS120CDUF((cAliasRDA)->UFORI, "1") + (cAliasRDA)->CDMUNO )
			oMdGrdGWU:LoadValue( 'GWU_UFD'   , (cAliasRDA)->UFORI )
			oMdGrdGWU:LoadValue( 'GWU_CEPD'  , (cAliasRDA)->CEPORI )
			oMdGrdGWU:LoadValue( 'GWU_CHVEXT' , Iif(lViagem,'VGMTMS;'+ DUD->DUD_FILORI + ';' + DUD->DUD_VIAGEM,;
															'RDPTMS;'+ DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED  ))
			oMdGrdGWU:LoadValue( 'GWU_PAGAR' , "2" )   //Nao
			oMdGrdGWU:LoadValue( 'GWU_SEQ'   , cSeq )

		EndIf
	EndIf

	//--- Inclusao do Trecho adicional do Redespacho da Viagem (DJN)
	cSeq:= Soma1(cSeq)
	oMdGrdGWU:AddLine()
	oMdGrdGWU:GoLine(Val(AllTrim(cSeq)))
	nTrecho:= Val(AllTrim(cSeq))

	//--- Favorecido do Redespacho Adicional e não da Viagem
	aForTrecho:= TMSGBscFav(,,(cAliasRDA)->CODFOR,(cAliasRDA)->LOJFOR)
	If Len(aForTrecho) > 0			
		cFornec:= aForTrecho[1]
		cLojFor:= aForTrecho[2]
		cTransp:= aForTrecho[3]

		cCgcTransp:= TMSGBscCGC(cTransp,cFornec,cLojFor,lNumProp)
	EndIf

	If nTrecho > 1    //Mais de um TRecho
		oMdGrdGW1:LoadValue( 'GW1_TPFRET', "2" )		  //CIF COM REDESPACHO
	EndIf

	oMdGrdGWU:LoadValue( 'GWU_NRCIDO', TMS120CDUF((cAliasRDA)->UFORI, "1") + (cAliasRDA)->CDMUNO )
	oMdGrdGWU:LoadValue( 'GWU_UFO'   , (cAliasRDA)->UFORI )
	oMdGrdGWU:LoadValue( 'GWU_CEPO'  , (cAliasRDA)->CEPORI )
	oMdGrdGWU:SetValue( 'GWU_CDTRP' , cCgcTransp  )  
	oMdGrdGWU:LoadValue( 'GWU_NRCIDD', TMS120CDUF((cAliasRDA)->UFDES, "1") + (cAliasRDA)->CDMUND )
	oMdGrdGWU:LoadValue( 'GWU_UFD'   , (cAliasRDA)->UFDES )

	If !Empty(oMdGrdGW1:GetValue('GW1_ENTCEP'))  
		cCepDes:= oMdGrdGW1:GetValue('GW1_ENTCEP')
	Else
		cCepDes:= (cAliasRDA)->CEPDES
		If Empty(cCepDes)
			cCepDes:= cA1_CEPDes
		EndIf
	EndIf
	oMdGrdGWU:LoadValue( 'GWU_CEPD'   , cCepDes )
	oMdGrdGWU:LoadValue( 'GWU_PAGAR'  , (cAliasRDA)->TPFRRD )  //1-Pagar, 2=Nao Pagar
	oMdGrdGWU:LoadValue( 'GWU_CDTPVC' , (cAliasRDA)->TIPVEI )
	oMdGrdGWU:LoadValue( 'GWU_CDTPOP' , (cAliasRDA)->CDTPOP )
	oMdGrdGWU:LoadValue( 'GWU_CDCLFR' , (cAliasRDA)->CDCLFR )
	oMdGrdGWU:LoadValue( 'GWU_CHVEXT' , Iif(lViagem,'VGMTMS;' + DUD->DUD_FILORI + ';' + DUD->DUD_VIAGEM,;
		                                                                'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED) )
	oMdGrdGWU:LoadValue( 'GWU_SEQ'   , cSeq )

	(cAliasRDA)->(DbSkip())
EndDo
(cAliasRDA)->( dbCloseArea() )

RestArea(aArea)
Return Nil


//---------------------------------------------------
/*/{Protheus.doc} TMSFUNLGWE
Função que atualiza Relacionamento Documento de Carga GFE
e Documento de Transporte TMS
@author	Katia
@version	1.0
@since		14/12/2016
@sample    Esta função tem por objetivo gravar a tabela
			GWE
//Função removida do fonte OMSM011GWE		
/*/
//----------------------------------------------------

Function TMSFUNLGWE(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cNumRed,cGW1_CDTPDC,cGW1_EMISDC,cGW1_SERDC,cGW1_NRDC)

Local cSeek		:= ""
Local aArea		:= GetArea()

Default cFilDoc	   := ""
Default cDoc	   := ""
Default cSerie	   := ""
Default cFilOri	   := ""
Default cViagem	   := ""
Default cNumRed    := ""
Default cGW1_CDTPDC:= ""
Default cGW1_EMISDC:= ""
Default cGW1_SERDC := ""
Default cGW1_NRDC  := ""

GWE->(dbSetOrder(1))
cSeek:= xFilial("GWE")+cGW1_CDTPDC+cGW1_EMISDC+cGW1_SERDC+cGW1_NRDC+cFilDoc+cDoc+cSerie
If !GWE->(DbSeek(cSeek))	
	oMdGrdGWE:LoadValue('GWE_FILIAL', xFilial("GWE") )
	oMdGrdGWE:LoadValue('GWE_CDTPDC', cGW1_CDTPDC  )
	oMdGrdGWE:LoadValue('GWE_EMISDC', cGW1_EMISDC  )
	oMdGrdGWE:LoadValue('GWE_SERDC' , cGW1_SERDC   )
	oMdGrdGWE:LoadValue('GWE_NRDC'  , cGW1_NRDC   )
	oMdGrdGWE:LoadValue('GWE_FILDT' , cFilDoc )
	oMdGrdGWE:LoadValue('GWE_NRDT'  , cDoc )
	oMdGrdGWE:LoadValue('GWE_SERDT' , cSerie  )

	If !Empty(cViagem)
		oMdGrdGWE:LoadValue('GWE_CHVEXT','VGMTMS;'+cFilOri+';'+cViagem )
	Else
		oMdGrdGWE:LoadValue('GWE_CHVEXT','RDPTMS;'+ cFilOri+';'+cNumRed )
	EndIf
EndIf

RestArea(aArea)
Return Nil
//-------------------------------------------------------------------------
/*/{Protheus.doc} TMSFUNLSOL
Função que carrega as Notas de Cliente vinculada a SC
@author	Katia
@version	1.0
@since		06/03/2017
@sample    Esta função tem por objetivo pesquisar as
			Notas vinculadas a SC para atualizar a tabela no SIGAGFE - GXP
//Função removida do fonte TMSFUNGSOL
/*/
//-------------------------------------------------------------------------
Function TMSFUNLSOL(cFilOri,cNumSol)

Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()
Local cEmisDTC  := ""

Default cFilOri   := ""
Default cNumSol   := ""

	cQuery := " SELECT DISTINCT DTC_CLIREM, DTC_LOJREM, DTC_NUMNFC, DTC_SERNFC, DTC_FILORI, DTC_NFEID "
	cQuery += "   FROM " + RetSqlName("DTC")
	cQuery += "   WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
	cQuery += "     AND DTC_FILORI = '" + cFilOri + "' "
	cQuery += "     AND DTC_NUMSOL = '" + cNumSol + "' "
	cQuery += "     AND DTC_NFEID  <> ' ' "
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasQry, .T., .T.)
	Do While (cAliasQry)->( !Eof() )
		If lNumProp
			cEmisDTC:= OMSM011COD((cAliasQry)->DTC_CLIREM,(cAliasQry)->DTC_LOJREM,1,,)
		Else
			cEmisDTC:= Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->DTC_CLIREM+(cAliasQry)->DTC_LOJREM,"A1_CGC")
		EndIf

		TMSFUNLGXP((cAliasQry)->DTC_NFEID,(cAliasQry)->DTC_FILORI,cEmisDTC,(cAliasQry)->DTC_SERNFC, (cAliasQry)->DTC_NUMNFC  )

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->( DbCloseArea() )

RestArea(aArea)
Return Nil

//---------------------------------------------------
/*/{Protheus.doc}TMSFUNLGXP
Função que atualiza o Documento de Origem no SIGAGFE
@author	Katia
@version	1.0
@since		06/03/2017
@sample    Esta função tem por objetivo gravar a tabela
			GXP
//Função removida do fonte TMSFUNGGXP			
/*/
//----------------------------------------------------
Function TMSFUNLGXP(cNfeId,cFilOri,cEmisDTC,cSerNfc,cNumNfc )

Local nLinGXP:= 0
Local lRet   := .F.
Local aArea  := GetArea()

	nLinGXP:= oMdGridGXP:Length()
								       
	If oMdGridGXP:Length() > 1 	.Or. (oMdGridGXP:Length() == 1 .And. !Empty(oMdGridGXP:GetValue('GXP_DANFE')))
		nLinGXP := oMdGridGXP:AddLine()
	EndIf
	If nLinGXP > 0
		oMdGridGXP:GoLine( nLinGXP )
		oMdGridGXP:LoadValue( 'GXP_DANFE' ,  cNfeId )
		oMdGridGXP:LoadValue( 'GXP_FILORI', cFilOri )
		oMdGridGXP:LoadValue( 'GXP_EMIORI', cEmisDTC )
		oMdGridGXP:LoadValue( 'GXP_SERORI', cSerNfc )
		oMdGridGXP:LoadValue( 'GXP_DOCORI', cNumNfc )
		lRet:= .T.
	EndIf

RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/Atualiza dados da Tabela DM8 - Trecho do Documento Viagem Mod.3
@author Katia
@version 12.1.30
@since   11/08/2020
@sample  
/*/
//-----------------------------------------------------------------
Function TMSFUNLDM8(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cChvGFE)
Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
Default cFilOri:= ""
Default cViagem:= ""

DM8->(DbSetOrder(1))
If DM8->(dBSeek(xFilial('DM8')+ cFilDoc + cDoc + cSerie + cFilOri + cViagem ))
	Reclock("DM8",.F.)
	DM8->DM8_CHVEXT:= cChvGFE
	DM8->(MsUnlock())
EndIf
Return Nil

//-----------------------------------------------------------------
/*/Atualiza dados do Campo DJN_CHVEXT
Criado campo para que, quando existir apenas o registro de DJN, 
para ser visualizado a chave na viagem Modelo 3.
@author Katia
@version 12.1.30
@since   28/08/2020
@sample  
/*/
//-----------------------------------------------------------------
Function TMSFUNLDJN(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cChvGFE)
Local aAreaDJN := DJN->(GetArea())
Local cSeekDJN := ""

Default cFilDoc:= ""
Default cDoc   := ""
Default cSerie := ""
Default cFilOri:= ""
Default cViagem:= ""

cSeekDJN := xFilial("DJN")+cFilOri+cViagem+cFilDoc+cDoc+cSerie
DJN->(dbSetOrder(1))
If DJN->(MsSeek(cSeekDJN))
	Do While !DJN->(Eof()) .And. DJN->(DJN_FILIAL+DJN_FILORI+DJN_VIAGEM+DJN_FILDOC+DJN_DOC+DJN_SERIE) == cSeekDJN
		Reclock("DJN",.F.)
		DJN->DJN_CHVEXT:= cChvGFE
		DJN->(MsUnlock())
		DJN->(dbSkip())
	EndDo
EndIf	

RestArea(aAreaDJN)
FwFreeArray(aAreaDJN)
Return Nil

//-----------------------------------------------------------------
/*/Retorna a distancia por cliente / regiao.
@author Katia
@version 12.1.33
@since   12/07/2021
@sample  
/*/
//-----------------------------------------------------------------
Static Function PesqKMVge()
Local nQtdKm  := 0
Local cCdrOri := DA8->DA8_CDRORI   //-- Regiao de Origem
Local cCdrDes := ""

cCdrDes:= TMSRetRegD(DTQ->DTQ_SERTMS,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM) //--Região de Destino

If DTQ->DTQ_SERTMS <> StrZero(2, Len(DTQ->DTQ_SERTMS))
	nQtdKm := TMSDistRot(,.F.,cCdrOri,cCdrDes)
Else
	nQtdKm := TMSDistRot(DTQ->DTQ_ROTA,.F.)
EndIf
Return nQtdKm

//-----------------------------------------------------------------
/*/DOCUMENTOS DA VIAGEM
@author Katia
@version 12.1.33
@since   12/07/2021
@sample  
/*///Extraido do fonte TMSFUNLVGE 
//-----------------------------------------------------------------
Function TMSFUNLPRC(cFilOri,cViagem,lAltVge,cNumRom,cChvGFE,cChvDTQ,lCalcAut,nOpc,lAltDocto)
Local cAliasQry:= ""
Local cQuery   := ""
Local lContinua:= .F.
Local lTMSA340  := IsInCallStack("TMSA340Grv") .Or. IsInCallStack("TMSA340Mnt")
Local cNewRom   := ""
Local cChvExt   := ""
Local lRet      := .T.

Default cFilOri := ""
Default cViagem := ""
Default lAltVge := .F.
Default cNumRom := ""
Default cChvGFE := ""
Default cChvDTQ := ""
Default lCalcAut := .F.
Default lAltDocto:= .F.

	cAliasQry := GetNextAlias()
	cQuery := " SELECT DUD.DUD_FILORI, DUD.DUD_VIAGEM, DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DUD.DUD_CHVEXT, "
	cQuery += " DUD.DUD_CDCLFR, DUD.DUD_UFORI, DUD.DUD_CDMUNO, DUD.DUD_UFDES, DUD.DUD_CDMUND, DUD.DUD_CDTPOP, DUD.DUD_STATUS, "
	cQuery += " DUD.R_E_C_N_O_ DUDRECNO, DTC.DTC_NUMNFC, DTC.DTC_SERNFC , DTC.R_E_C_N_O_ DTCRECNO , DT6.R_E_C_N_O_ DT6RECNO "
	cQuery += " FROM " + RetSqlName('DUD') + " DUD "

	cQuery += " INNER JOIN " + RetSqlName('DTQ') + " DTQ "
	cQuery += " ON DTQ_FILIAL = '" + xFilial('DTQ') + "' "
	cQuery += "   AND	DTQ_FILORI = '" + cFilOri + "' "
	cQuery += "   AND	DTQ_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DTQ.D_E_L_E_T_ = ' ' "

	cQuery += "   INNER JOIN " + RetSqlName('DT6') + " DT6 "
	cQuery += "   ON (DT6.DT6_FILIAL = '" + xFilial('DT6') + "' "
	cQuery += "   AND DT6.DT6_FILDOC = DUD.DUD_FILDOC 
	cQuery += "   AND DT6.DT6_DOC = DUD.DUD_DOC  
	cQuery += "   AND DT6.DT6_SERIE  = DUD.DUD_SERIE 
	cQuery += "   AND DT6.D_E_L_E_T_ = ' ')

	cQuery += "   LEFT JOIN " + RetSqlName('DTC') + " DTC "
	cQuery += "   ON (DTC.DTC_FILIAL = '" + xFilial('DTC') + "' "
	cQuery += "   AND DTC.DTC_FILDOC = DT6.DT6_FILDOC " 
	cQuery += "   AND DTC.DTC_DOC = DT6.DT6_DOC " 
	cQuery += "   AND DTC.DTC_SERIE = DT6.DT6_SERIE " 
	cQuery += "   AND DTC.D_E_L_E_T_ = ' ')

	cQuery += " WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
	cQuery += "   AND	DUD_FILORI = '" + cFilOri + "' "
	cQuery += "   AND	DUD_VIAGEM = '" + cViagem + "' "
	If !lTMSA340 .And. cColGFE <> "1"  
		cQuery += "   AND DUD_STATUS <> '" + StrZero( 9, Len( DUD->DUD_STATUS ) ) + "'"   //Cancelado
	EndIf	
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += "   AND ( (EXISTS(SELECT 1 FROM " + RetSqlName('DJN') + " DJN "
	cQuery += " 					WHERE DJN.DJN_FILIAL = '" + xFilial('DJN') + "' "
	cQuery += "   				AND	DJN.DJN_FILORI = '" + cFilOri + "' "
	cQuery += "   				AND	DJN.DJN_VIAGEM = '" + cViagem + "' "
	cQuery += "   				AND	DJN.DJN_FILDOC = DUD.DUD_FILDOC "
	cQuery += "   				AND	DJN.DJN_DOC = DUD.DUD_DOC "
	cQuery += "   				AND	DJN.DJN_SERIE = DUD.DUD_SERIE "
	cQuery += "   				AND DJN.D_E_L_E_T_ = ' ' )) "
	cQuery += "   				OR DTQ.DTQ_PAGGFE = '1' )    "
	cQuery += " UNION "

	cQuery += " SELECT DUD.DUD_FILORI, DUD.DUD_VIAGEM, DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DUD.DUD_CHVEXT, "
	cQuery += " DUD.DUD_CDCLFR, DUD.DUD_UFORI, DUD.DUD_CDMUNO, DUD.DUD_UFDES, DUD.DUD_CDMUND, DUD.DUD_CDTPOP, DUD.DUD_STATUS, "
	cQuery += " DUD.R_E_C_N_O_ DUDRECNO, DTC.DTC_NUMNFC, DTC.DTC_SERNFC , DTC.R_E_C_N_O_ DTCRECNO , DT6.R_E_C_N_O_ DT6RECNO "
	cQuery += " FROM " + RetSqlName('DUD') + " DUD "

	cQuery += " INNER JOIN " + RetSqlName('DTQ') + " DTQ "
	cQuery += " ON DTQ_FILIAL = '" + xFilial('DTQ') + "' "
	cQuery += "   AND	DTQ_FILORI = '" + cFilOri + "' "
	cQuery += "   AND	DTQ_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DTQ.D_E_L_E_T_ = ' ' "

	cQuery += "  INNER JOIN " + RetSqlName("DY4") + " DY4 " 		
	cQuery += "  ON DY4.DY4_FILIAL  = '" + xFilial("DY4") + "'" 
	cQuery += "	 AND DY4.DY4_FILDOC  = DUD.DUD_FILDOC "             
	cQuery += "	 AND DY4.DY4_DOC = DUD.DUD_DOC "             
	cQuery += "  AND DY4.DY4_SERIE	= DUD.DUD_SERIE "               
	cQuery += "	 AND DY4.D_E_L_E_T_  = ' '"                     

	cQuery += "  INNER JOIN " + RetSqlName('DT6') + " DT6 "
	cQuery += "  ON (DT6.DT6_FILIAL = '" + xFilial('DT6') + "' "
	cQuery += "  AND DT6.DT6_FILDOC = DY4.DY4_FILDOC 
	cQuery += "  AND DT6.DT6_DOC = DY4.DY4_DOC  
	cQuery += "  AND DT6.DT6_SERIE  = DY4.DY4_SERIE 
	cQuery += "  AND DT6.D_E_L_E_T_ = ' ')
	
	cQuery += "  LEFT JOIN " + RetSqlName("DTC") + " DTC "
	cQuery += "  ON DTC_FILIAL = '" + xFilial("DTC") + "' "
	cQuery += "	 AND DTC_FILORI = DY4.DY4_FILORI "
	cQuery += "	 AND DTC_LOTNFC = DY4.DY4_LOTNFC "
	cQuery += "	 AND DTC_NUMNFC = DY4.DY4_NUMNFC "
	cQuery += "	 AND DTC_SERNFC = DY4.DY4_SERNFC "
	cQuery += "	 AND DTC_CLIREM = DY4.DY4_CLIREM "
	cQuery += "	 AND DTC_LOJREM = DY4.DY4_LOJREM "
	cQuery += "	 AND DTC_CODPRO = DY4.DY4_CODPRO "
	cQuery += "	 AND DTC.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
	cQuery += "   AND	DUD_FILORI = '" + cFilOri + "' "
	cQuery += "   AND	DUD_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND	DUD_CHVEXT = ' '  "
	If !lTMSA340 .And. cColGFE <> "1"  
		cQuery += "   AND DUD_STATUS <> '" + StrZero( 9, Len( DUD->DUD_STATUS ) ) + "'"   //Cancelado
	EndIf	
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += "   AND ( (EXISTS(SELECT 1 FROM " + RetSqlName('DJN') + " DJN "
	cQuery += " 					WHERE DJN.DJN_FILIAL = '" + xFilial('DJN') + "' "
	cQuery += "   				AND	DJN.DJN_FILORI = '" + cFilOri + "' "
	cQuery += "   				AND	DJN.DJN_VIAGEM = '" + cViagem + "' "
	cQuery += "   				AND	DJN.DJN_FILDOC = DUD.DUD_FILDOC "
	cQuery += "   				AND	DJN.DJN_DOC = DUD.DUD_DOC "
	cQuery += "   				AND	DJN.DJN_SERIE = DUD.DUD_SERIE "
	cQuery += "   				AND DJN.D_E_L_E_T_ = ' ' )) "
	cQuery += "   				OR DTQ.DTQ_PAGGFE = '1' )    "
	cQuery += "   ORDER BY DUD.DUD_FILORI, DUD.DUD_VIAGEM, DUD.DUD_CDTPOP, DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DTC.DTC_NUMNFC, DTC.DTC_SERNFC " 
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If (cAliasQry)->(!Eof())
		While (cAliasQry)->(!Eof())
			If lTMSA340
				//MV_COLGFE == 1, As Solicitações de coletas serão integradas no Encerramento da Viagem
				lContinua:= (cAliasQry)->DUD_SERIE == 'COL' .And. cColGFE == "1"
				//Cancelado com Ocorrencia Retorna do Docto, deverá ser integrado
				If lContinua 
					If (cAliasQry)->DUD_STATUS == StrZero( 9, Len( DUD->DUD_STATUS ) )   
						If TMSUltOcor(cFilOri,cViagem,(cAliasQry)->DUD_FILDOC,(cAliasQry)->DUD_DOC,(cAliasQry)->DUD_SERIE,'04') == 0
							lContinua:= .F.
						EndIf
					EndIf	
				EndIf
			Else
				lContinua:= .T.
				If (cAliasQry)->DUD_SERIE == 'COL' .And. (cColGFE $ "1|2")
					lContinua:= .F.  
				EndIf
			EndIf

			If lContinua
				//--- Verifica se o Documento já foi integrado ao SIGAGFE. Caso integrado, incluir apenas o Trecho ao Docto de Carga.
				cChvGFE:= TMSDocGFE((cAliasQry)->DUD_FILORI,(cAliasQry)->DUD_FILDOC,(cAliasQry)->DUD_DOC,(cAliasQry)->DUD_SERIE)
				If !Empty(cChvGFE)
					lContinua:= .F.  //Devera ser executado separado via TMSXFUNG
					lAltDocto:= .T.  //Retorna variavel para TMSXFUND
				EndIf

				If lContinua
					If Empty(cChvGFE)
						//---- Verifica se existe um Romaneio com o mesmo Tipo de Operacao (DUD_CDTPOP) em aberto na viagem para inclusao dos novos documentos
						If lAltVge 
							If Empty(cNewRom)
								lRet:= TmsGFEDUD(M->DTQ_FILORI,M->DTQ_VIAGEM,,,,.T.,@cChvExt,(cAliasQry)->DUD_CDTPOP)
							EndIf

							//---- Se não existir um Romaneio, cria-se um novo romaneio
							If lRet .And. !Empty(cChvExt)
								cNewRom:= cChvExt
							Else
								cNewRom:= ""
							EndIf
							aErrGFE:= {}
						EndIf

							//---- Criar o Romaneio (por Viagem) somente se houver Documentos que nao foram integrados na Filial. (GW1_FILIAL)
						If (lAltVge .And. Empty(cNewRom)) .Or. Empty(cChvDTQ)
							cChvGFE:= ""
							lRet:= TMSFUNLROM(nOpc,@cChvGFE,Iif(lAltVge,(cAliasQry)->DUD_CDTPOP,DTQ->DTQ_CDTPOP),Iif(lAltVge,'',DTQ->DTQ_CDCLFR),Iif(lAltVge,'',DTQ->DTQ_UFORI),Iif(lAltVge,'',DTQ->DTQ_CDMUNO),Iif(lAltVge,'',DTQ->DTQ_UFDES),;
								Iif(lAltVge,'',DTQ->DTQ_CDMUND), DTQ->(Recno()),Iif(lAltVge,'',DTQ->DTQ_CEPORI),Iif(lAltVge,'',DTQ->DTQ_CEPDES), lCalcAut )

							//---- Dados na viagem, so grava na primeira integração
							If lRet
								If !lAltVge
									cChvGFE:= DTQ->DTQ_VIAGEM  //Temporário, marca que foi gerado um Romaneio
									cChvDTQ:= cChvGFE
								Else
									cNewRom := cChvGFE
								EndIf
							EndIf
						Else
							If lAltVge .And. !Empty(cNewRom)
								cChvGFE:= cNewRom
							Else
								cChvGFE:= cChvDTQ
							EndIf
						EndIf
					EndIf

					If !Empty(cChvGFE)
						DUD->(MsGoto( (cAliasQry)->DUDRECNO ))
						lRet:= .T.

						If DTQ->DTQ_PAGGFE == StrZero(1, Len(DTQ->DTQ_PAGGFE) ) .And. Empty(DUD->DUD_NUMRED)  .And. DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS))
							GrvMunDes()
							lRet:= VldMunDes()
						EndIf
							
						If lRet
							lRet:= TMSFUNLDOC(0, .T., (cAliasQry)->DUDRECNO,(cAliasQry)->DT6RECNO,(cAliasQry)->DTCRECNO)
						EndIf

						//--- Na Alteração de um Viagem em Transito já integrada, se ocorrer erro na integração do novo docto vinculado a viagem,
						//--- será exibido o help informando o documento e continuar a integração dos demais documentos.
						//--- No caso do Fechamento, Apontamento da Operação nao permitir o processo se pelo menos 1 documento nao foi integrado.
						If !lRet .And. lAltVge
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
	EndIf
	(cAliasQry)->( dbCloseArea() )

If Len(aErrGFE) > 0
	TmsMsgErr(aErrGFE)
	lRet:= .F.
EndIf

Return lRet
//-----------------------------------------------------------------
/*/Pesquisa Emissor do Documento de Carga da Solicitação de Coleta
@author Katia
@version 12.1.33
@since   12/07/2021
@sample  
/*///extraido do TMSFUNLDOC
//-----------------------------------------------------------------
Static Function PesqEmisDC()
Local cEmisDc:= ""
Local cCliRem:= ""
Local cLojRem:= ""

cCliRem:= DT5->DT5_CLIREM
cLojRem:= DT5->DT5_LOJREM

If Empty(cCliRem)
	DUE->(DbSetOrder(1))
	If DUE->(dbSeek(xFilial('DUE')+DT5->DT5_CODSOL))
		cCliRem:= DUE->DUE_CODCLI
		cLojRem:= DUE->DUE_LOJCLI
	EndIf
EndIf

If Empty(cCliRem)
	cEmisDc := OMSM011COD(,,,.T.,DT5->DT5_FILORI)
Else
	If lNumProp
		cEmisDc:= OMSM011COD(cCliRem,cLojRem,1,,)
	Else
		cEmisDc:= Posicione("SA1",1,xFilial("SA1")+cCliRem+cLojRem,"A1_CGC")
	EndIf
EndIf

Return cEmisDc

//-----------------------------------------------------------------
/*/Pesquisa dados do Destinatario da Coleta
@author Katia
@version 12.1.33
@since   12/07/2021
@sample  
/*///extraido do TMSFUNLDOC   PesqCdDest
//-----------------------------------------------------------------
Static Function PesqDest(cCdDest,cA1_EstDes,cA1_CdMuDes,cA1_CEPDes)  

cCdDest := OMSM011COD(,,,.T.,DT5->DT5_FILORI)

If !Empty(DT6->DT6_CDRCAL)
	DUY->(DbSetOrder(1))
	If DUY->(MsSeek(xFilial("DUY")+DT6->DT6_CDRCAL))
		cA1_EstDes := DUY->DUY_EST
		cA1_CdMuDes:= DUY->DUY_CODMUN
	EndIf
Else
	aAreaSM0 := SM0->(GetArea())
	cA1_CdMuDes:= NoAcentoCte(Posicione("SM0",1,cEmpAnt+DT5->DT5_FILORI,"M0_ESTENT"))
	cA1_EstDes := Substr(NoAcentoCte(Posicione("SM0",1,cEmpAnt+DT5->DT5_FILORI,"M0_CODMUN")),3)
	cA1_CEPDes := NoAcentoCte(Posicione("SM0",1,cEmpAnt+DT5->DT5_FILORI,"M0_CEPENT"))
	RestArea(aAreaSM0)
EndIf

Return


//-----------------------------------------------------------------
/*/Pesquisa dados do Cliente de Destino
@author Katia
@version 12.1.33
@since   12/07/2021
@sample  
/*///extraido do TMSFUNLDOC   PesqCdDest
//-----------------------------------------------------------------
Static Function PsqCliDest(cCliDes,cLojDes,cCdDest,cA1_EstDes,cA1_CdMuDes,cA1_CEPDes)  
Local cA1_CGC:= ""

Default cCliDes:= ""
Default cLojDes:= ""

   	If SA1->( dbSeek(xFilial("SA1")+cCliDes+cLojDes ) )
		If SA1->A1_TIPO == "X"
			cA1_CGC := AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA)
			cA1_CGC := PadR( cA1_CGC, TamSx3("GW1_CDDEST")[1] )
		Else
			cA1_CGC := SA1->A1_CGC
		EndIf
		cA1_CdMuDes := SA1->A1_COD_MUN
		cA1_EstDes  := SA1->A1_EST
		cA1_CEPDes  := SA1->A1_CEP
	EndIf

	If lNumProp
		cCdDest:= OMSM011COD(cCliDes,cLojDes,1,,) 
	Else
		cCdDest:=  cA1_CGC 
	EndIf

Return

//-----------------------------------------------------------------
/*/Valida se a viagem tem Redespacho Adicional
@author Katia
@version 12.1.33
@since   12/07/2021
@sample  
/*///extraido do TMSFUNLDOC
//-----------------------------------------------------------------	
Static Function VldRedDJN()
Local cQuery    := ""
Local cAliasNew := GetNextAlias()
Local lRet      := .F.

	cQuery := " SELECT COUNT(*) NREGDJN  "
	cQuery += "   FROM " + RetSqlName("DJN") + " DJN "
	cQuery += "  WHERE DJN_FILIAL  = '"+ xFilial("DJN")+"' "
	cQuery += "    AND DJN_FILORI  = '"+DTQ->DTQ_FILORI+"' "
	cQuery += "    AND DJN_VIAGEM  = '"+DTQ->DTQ_VIAGEM+"' "
	cQuery += "    AND DJN.D_E_L_E_T_ = ' ' "
	cQuery    := ChangeQuery(cQuery)
	cAliasNew := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
	If (cAliasNew)->(!Eof()) .And. (cAliasNew)->NREGDJN > 0
		lRet:= .T.
	EndIf
	(cAliasNew)->( dbCloseArea() )

Return lRet

//-----------------------------------------------------------------
/*/Grava o Nro do Romaneio na Chave Externa da Tabela DTQ
@author Katia
@version 12.1.33
@since   14/07/2021
@sample  
/*/
//-----------------------------------------------------------------
Static Function TMSLChvDTQ(cChvExt)
Default cChvExt:= ""

Reclock("DTQ",.F.)
DTQ->DTQ_CHVEXT:= cChvExt
DTQ->(MsUnlock())

Return

//-----------------------------------------------------------------
/*/Grava o Nro do Romaneio na Chave Externa da Tabela DUD
@author Katia
@version 12.1.33
@since   14/07/2021
@sample  
/*/
//-----------------------------------------------------------------
Static Function TMSLChvDOC(cChvExt,LTABDM8)
Local nX       := 0

Default cChvExt:= ""
Default LTABDM8:= .F.

For nX:= 1 to Len(aDoctos)
	DUD->(DbGoTo(aDoctos[nX]))

	If Empty(DUD->DUD_CHVEXT)
		Reclock("DUD",.F.)
		DUD->DUD_CHVEXT:= cChvExt
		DUD->(MsUnlock())
	EndIf	

	//----- Viagem Modelo 3
	If lTabDM8
		TMSFUNLDM8(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DUD->DUD_FILORI,DUD->DUD_VIAGEM,cChvExt)
		TMSFUNLDJN(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DUD->DUD_FILORI,DUD->DUD_VIAGEM,cChvExt)
	EndIf

	//---- Viagem de Redespacho com parametro MV_TMSRDPU atualiza a chave externa
	If DTQ->DTQ_TIPVIA == StrZero(5,Len(DTQ->DTQ_TIPVIA)) .And. lTMSRDPU
		DFV->(DbSetOrder(2)) //DFV_FILIAL+DFV_FILDOC+DFV_DOC+DFV_SERIE+DFV_STATUS
		If DFV->(dBSeek(xFilial('DFV')+ DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE) ))
			Reclock("DFV",.F.)
			DFV->DFV_CHVEXT:= cChvExt
			DFV->(MsUnlock())
		EndIf
	EndIf
Next

Return

//-----------------------------------------------------------------
/*/Limpa variaveis Static
@author Katia
@version 12.1.33
@since   15/07/2021
@sample  
/*/
//-----------------------------------------------------------------
Static Function LimpaVar()
	aDoctos   := {}
	aCalcRom  := {}
	aErrGFE   := {}
	aFornece  := {}
	FwFreeObj(oModel)
	FwFreeObj(oMdFldGWN)
	FwFreeObj(oMdGrdGW1)
	FwFreeObj(oMdGrdGW8)
	FwFreeObj(oMdGrdGWU)
	FwFreeObj(oMdGrdGWE)	
Return

//-----------------------------------------------------------------
/*/Grava Municipio de Destino
@author Katia
@version 12.1.33
@since   15/07/2021
@sample  
/*/
//-----------------------------------------------------------------
Static Function GrvMunDes()

Reclock("DUD",.F.)
//--- Os campos abaixo são atualizados na viagem de Transferencia, porem se ocorrer de estarem em branco, força a atualização
If Empty(DUD->DUD_UFDES) .Or. Empty(DUD->DUD_CDMUND) .Or. Empty(DUD->DUD_CEPDES)
	Tmsa210DUD()
EndIf
DUD->(MsUnlock())

Return

//-----------------------------------------------------------------
/*/Valida Municipio de Destino
@author Katia
@version 12.1.33
@since   15/07/2021
@sample  
/*/
//-----------------------------------------------------------------
Static Function VldMunDes()
Local lRet:= .T.

If Empty(DUD->DUD_UFDES) .Or. Empty(DUD->DUD_CDMUND)
	If Len(aErrGFE) == 0
		Aadd(aErrGFE,{STR0002})  //"Inconsistência com o Frete Embarcador (SIGAGFE): "
	EndIf
	Aadd(aErrGFE,{STR0003 + DUD->DUD_FILDOC + " " + DUD->DUD_DOC + " " + DUD->DUD_SERIE + " - " + STR0005})  //UF/Municipio de Destino não informado para a Filial de Descarga do Documento. "   })
	lRet:=.F.
EndIf

Return lRet


