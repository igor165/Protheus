#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TMSXFUNG.CH"
#INCLUDE "FWMVCDEF.CH"

Static lTmsRdpU  	:= SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Static aErrGFE   	:= {}
Static _lModel		:= .T.
Static aFornece     := {}

//---------------------------------------------------
/* Processa Redespachos para integracao TMS x GFE
@author Katia
@version P11
@since 10/10/2013
//Função removida do fonte OMSM011 em Agosto/2018
/*/
//---------------------------------------------------
Function TMSFUNGRED(cTipoInter,cNumRed,cCodFor,cLojFor,cProTable,cRotiProt,ArqvLog,nOpc,cFilOri,cViagem,cFilRed) 
Local aArea 	:= GetArea()
Local cQuery	:= ""
Local cAliasQry	:= ""
Local cChave    := ""
Local lRet      := .F.
Local lAtuDFV   := .T.
Local lProcessa := .T.
Local lSepRomDes:= .T.   //Considera sempre como T, pois o campo foi criado depois do projeto.
Local cChvGFE   := ""
Local lCmpDFV   := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0
Local cChvGFEAtu:= ""
Local cNumRom   := ""
Local aCalcRom  := {}
Local lCalcAut  := .T.

Default nOpc    := 3
//----- Quando executado pelo apontamento de operacao da viagem de redespacho
Default cFilOri := ""
Default cViagem := ""
Default cFilRed := ""

//lTmsRdpU --- Com o parametro ativo, foi desabilitado o campo dft_seprom

If !lTmsRdpU .And. DFT->DFT_SEPROM == '2'  //Separa Romaneio por Destino = Não
	lSepRomDes:= .F.
EndIf
//--Composicao da aChvExt
//[1] Filial do Romaneio (GWN_FILIAL)
//[2] Numero do Romaneio (GWN_NRROM)

//----- Verifica se sera executado o calculo automatico do romaneio apos a integração
Pergunte("TMSAR05",.F.)
If Type("mv_par01") == "N" .And. mv_par01 == 2  //Executa o Calculo do Romaneio Automatico 1-Sim, 2-Não
	lCalcAut:= .F.
EndIf

//---- ROMANEIO DE CARGA
cAliasQry := GetNextAlias()
cQuery := " SELECT DFV_FILDOC, DFV_DOC, DFV_SERIE, DFV_CDTPOP, DFV_CDCLFR, DFV_UFORI, DFV_CDMUNO, DFV_UFDES, DFV_CDMUND, DFV_CHVEXT, DFV.R_E_C_N_O_ DFVRECNO "
If lCmpDFV
	cQuery += ", DFV_FILORI "
EndIf
cQuery += " FROM " + RetSqlName('DFV') + " DFV "
cQuery += " INNER JOIN " + RetSqlName('SA2') + " SA2 "
cQuery += " ON SA2.A2_FILIAL  = '" + xFilial("SA2") + "'"
cQuery += " AND SA2.A2_COD     ='" + DFT->DFT_CODFOR + "'"
cQuery += " AND SA2.A2_LOJA    ='" + DFT->DFT_LOJFOR + "'"
cQuery += " AND SA2.A2_PAGGFE  = '1' "
cQuery += " AND SA2.D_E_L_E_T_ = ' '"
If !Empty(cFilOri) .And. !Empty(cViagem)
	cQuery += " INNER JOIN " + RetSqlName('DUD') + " DUD "
	cQuery	+= "   ON DUD.DUD_FILIAL	= '" + xFilial("DUD")  + "' "
	cQuery	+= "   AND DUD.DUD_FILDOC 	= DFV.DFV_FILDOC "
	cQuery	+= "   AND DUD.DUD_DOC    	= DFV.DFV_DOC "
	cQuery	+= "   AND DUD.DUD_SERIE   	= DFV.DFV_SERIE "
	cQuery	+= "   AND DUD.DUD_FILORI 	= '" + cFilOri + "' "
	cQuery	+= "   AND DUD.DUD_VIAGEM 	= '" + cViagem + "' "
	cQuery	+= "   AND DUD.DUD_STATUS 	<>'" + StrZero(9,Len(DUD->DUD_STATUS)) + "'"
	cQuery	+= "   AND DUD.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " WHERE DFV_FILIAL ='" + xFilial('DFV') + "' "
If lCmpDFV
	cQuery += "   AND DFV_FILORI ='" + DFT->DFT_FILORI + "' "
EndIf
cQuery += "   AND DFV_NUMRED ='" + DFT->DFT_NUMRED + "' "
cQuery += "   AND DFV_CODFOR ='" + DFT->DFT_CODFOR + "' "
cQuery += "   AND DFV_LOJFOR ='" + DFT->DFT_LOJFOR + "' "
cQuery += "   AND DFV_STATUS ='" + StrZero( 2, Len( DFV->DFV_STATUS ) ) + "'"   //Indicado para Entrega
cQuery += "   AND DFV.D_E_L_E_T_ = ' ' "
cQuery += "   ORDER BY DFV_CDTPOP, DFV_CDCLFR, DFV_UFORI, DFV_CDMUNO, DFV_UFDES, DFV_CDMUND "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
While (cAliasQry)->(!Eof())
	If !lTmsRdpU
		If lSepRomDes
			lProcessa:= (cAliasQry)->DFV_CDTPOP + (cAliasQry)->DFV_CDCLFR + (cAliasQry)->DFV_UFORI + (cAliasQry)->DFV_CDMUNO + (cAliasQry)->DFV_UFDES + (cAliasQry)->DFV_CDMUND <> cChave
		Else
			lProcessa:= (cAliasQry)->DFV_CDTPOP + (cAliasQry)->DFV_CDCLFR + (cAliasQry)->DFV_UFORI + (cAliasQry)->DFV_CDMUNO  <> cChave
		EndIf
		If lProcessa
			cChvGFEAtu:= ""
		EndIf
	EndIF

	If lProcessa
		If Empty((cAliasQry)->DFV_CHVEXT)
			lAtuDFV:= .T.

			//--- Verifica se o Documento já foi integrado ao SIGAGFE. Caso integrado, incluir apenas o Trecho ao Docto de Carga.
			cChvGFE:= TMSDocGFE(Iif(lCmpDFV,(cAliasQry)->DFV_FILORI,''),(cAliasQry)->DFV_FILDOC,(cAliasQry)->DFV_DOC,(cAliasQry)->DFV_SERIE)
			If !Empty(cChvGFE)
				cNumRom:= TmsRomGWN(cChvGFE,'1')
				If lCalcAut .And. aScan(aCalcRom, cNumRom ) == 0
					aAdd(aCalcRom, cNumRom)
				EndIf
			ElseIf Empty(cChvGFE) .And. !Empty(cChvGFEAtu)
				cChvGFE:= cChvGFEAtu
			EndIf

			//---- Parametro MV_TMSRDPU ativo, gera um unico Romaneio para todos os documentos
			//---- Caso contrario gera diversos romaneios conforme a quebra de origem e ou destino.

			If Empty(cChvGFE)
				
				lRet:= TMSFUNGDFT(nOpc,;
				                  @cChvGFE,;
				                  Iif(lTmsRdpU,DFT->DFT_CDTPOP,(cAliasQry)->DFV_CDTPOP),;
				                  Iif(lTmsRdpU,DFT->DFT_CDCLFR,(cAliasQry)->DFV_CDCLFR),;
				                  Iif(lTmsRdpU,DFT->DFT_UFORI,(cAliasQry)->DFV_UFORI),;
				                  Iif(lTmsRdpU,DFT->DFT_CDMUNO,(cAliasQry)->DFV_CDMUNO),;
				                  Iif(lTmsRdpU,DFT->DFT_UFDES,(cAliasQry)->DFV_UFDES),;
				                  Iif(lTmsRdpU,DFT->DFT_CDMUND,(cAliasQry)->DFV_CDMUND),;
				                  0,;
				                  Iif(lTmsRdpU,DFT->DFT_CEPORI,'' ),;
				                  Iif(lTmsRdpU,DFT->DFT_CEPDES,'' ),;
				                  @aCalcRom,;
				                  lCalcAut,;
								  DFT->DFT_TIPVEI)
				If !lRet
					lAtuDFV:= .F.
				Else
					cChvGFEAtu:= cChvGFE
				EndIf
			EndIf
		Else
			lAtuDFV:= .F.
			lRet   := .T.
			If !Empty(ArqvLog)
				ArqvLog:Add("| TMSAR05| " + PadR("Filial: " + AllTrim(DFT->DFT_FILIAL) + ", Redespacho: " + DFT->DFT_NUMRED, 38) + " |           | Redespacho já integrado")
			EndIf
		EndIf
	Else
		lAtuDFV:= .T.
	EndIf

	If lAtuDFV
		If Empty((cAliasQry)->DFV_CHVEXT) .And. !Empty(cChvGFE)
			DFV->(MsGoto( (cAliasQry)->DFVRECNO ))
			Reclock("DFV",.F.)
			DFV->DFV_CHVEXT:= cChvGFE
			DFV->(MsUnlock())
			lRet:= .T.
		EndIf
	EndIf

	If !lTmsRdpU
		If lSepRomDes
			cChave:= (cAliasQry)->DFV_CDTPOP + (cAliasQry)->DFV_CDCLFR + (cAliasQry)->DFV_UFORI + (cAliasQry)->DFV_CDMUNO + (cAliasQry)->DFV_UFDES + (cAliasQry)->DFV_CDMUND
		Else
			cChave:= (cAliasQry)->DFV_CDTPOP + (cAliasQry)->DFV_CDCLFR + (cAliasQry)->DFV_UFORI + (cAliasQry)->DFV_CDMUNO
		EndIf
	EndIf

	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->( dbCloseArea() )
RestArea(aArea)

//--- DOCUMENTOS DE CARGA
If lRet
	aArea:= GetArea()
	cAliasQry := GetNextAlias()
	cQuery := " SELECT DFV_FILDOC, DFV_DOC, DFV_SERIE, DFV_CHVEXT, DFV.R_E_C_N_O_ DFVRECNO "
	cQuery += " FROM " + RetSqlName('DFV')  + " DFV "
	If !Empty(cFilOri) .And. !Empty(cViagem)
		cQuery += " INNER JOIN " + RetSqlName('DUD') + " DUD "
		cQuery	+= "   ON DUD.DUD_FILIAL	= '" + xFilial("DUD")  + "' "
		cQuery	+= "   AND DUD.DUD_FILDOC 	= DFV.DFV_FILDOC "
		cQuery	+= "   AND DUD.DUD_DOC    	= DFV.DFV_DOC "
		cQuery	+= "   AND DUD.DUD_SERIE   	= DFV.DFV_SERIE "
		cQuery	+= "   AND DUD.DUD_FILORI 	= '" + cFilOri + "' "
		cQuery	+= "   AND DUD.DUD_VIAGEM 	= '" + cViagem + "' "
		cQuery	+= "   AND DUD.DUD_STATUS 	<>'" + StrZero(9,Len(DUD->DUD_STATUS)) + "'"
		cQuery	+= "   AND DUD.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += " WHERE DFV_FILIAL ='" + xFilial('DFV') + "' "
	If lCmpDFV
		cQuery += "   AND	DFV_FILORI ='" + DFT->DFT_FILORI + "' "
	EndIf
	cQuery += "   AND	DFV_NUMRED ='" + DFT->DFT_NUMRED + "' "
	cQuery += "   AND	DFV_CODFOR ='" + DFT->DFT_CODFOR + "' "
	cQuery += "   AND	DFV_LOJFOR ='" + DFT->DFT_LOJFOR + "' "
	cQuery += "   AND DFV_STATUS ='" + StrZero( 2, Len( DFV->DFV_STATUS ) ) + "'"   //Indicado para Entrega
	cQuery += "   AND DFV.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	If (cAliasQry)->(!Eof())
		While (cAliasQry)->(!Eof())
			If FindFunction( "GFEM011DFV")
				MsgRun( STR0008, STR0006, {|| CursorWait(),  lRet:= GFEM011DFV((cAliasQry)->DFVRECNO, ArqvLog, ,  )  , CursorArrow()})   //Integrando os Documentos com o SIGAGFE...

			EndIf	
			(cAliasQry)->(dbSkip())
		EndDo
	EndIf
	(cAliasQry)->( dbCloseArea() )
	RestArea( aArea )
EndIf

If Len(aErrGFE) > 0 
	TmsMsgErr(aErrGFE)
	lRet:= .F.   //Temporario apos definicao do calculo do GFE
EndIf

If lRet
//---- Chamada do Calculo do Romaneio que houve alteração com a inclusao do novo trecho
	If Len(aCalcRom) > 0 .And. FindFunction('TMSCALROM')
		MsgRun( STR0006 , STR0007, {|| CursorWait(), lRet:= TMSCALROM(aCalcRom,@aErrGFE,.F.) , CursorArrow()})   //Aguarde... Recalculando o Romaneio

		If Len(aErrGFE) > 0
			TmsMsgErr(aErrGFE)
			lRet:= .T.   //Temporario apos definicao do calculo do GFE
		EndIf
	EndIf
EndIf

aErrGFE := {}
aSize(aErrGFE , 0)
aSize(aCalcRom, 0)  
FwFreeArray(aFornece)
Return lRet

//-----------------------------------------------------
/*/	Integra a tabela DFT(Protheus) com GWN(SIGAGFE)
@author Katia
@version P11
@since 10/10/2013
//Função removida do fonte OMSM011 em Agosto/2018
/*/
//------------------------------------------------------
Function TMSFUNGDFT(nOperation,cChvGFE,cCdtpop,cCdclfr,cUfOri,cCdMunO,cUfDes,cCdMunD,nReqDTQ,cCepOri,cCepDes,aCalcRom,lCalcAut,cTipVei)

Local aAreaGWN 	:= GWN->( GetArea() )
Local lRet 		:=  .T.
Local oModelGWN := FWLoadModel("GFEA050")
Local cMsg
Local cCgcTransp:= ""
Local lNumProp 	:= Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)
Local cTransp   := ""
Local nQtdKm	:= 0
Local lViagem	:= .F.
Local cCdrOri	:= ""
Local cCdrDes	:= ""
Local cCodMot	:= ""
Local cFornec	:= ""
Local cLojFor	:= ""
Local cFilGWN	:= ""

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
Default aCalcRom:= {}
Default lCalcAut:= .T.
Default cTipVei := ""

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

oModelGWN:SetOperation( nOperation )
oModelGWN:Activate()

If !oModelGWN:IsActive()
	cMsg := oModelGWN:GetErrorMessage()[6]
	lRet := .F.
Else
   	oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_FILIAL', cFilGWN )
	oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_ORI'   , "3" )

	If !lViagem   //Redespacho
		aFornece:= TMSGBscFav(,,DFT->DFT_CODFOR,DFT->DFT_LOJFOR)   
	Else   //Viagem
		aFornece:= TMSGBscFav(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM) 

		cCodMot:= TMSGBscMot(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
	EndIf

	If Len(aFornece) > 0			
		cFornec:= aFornece[1]
		cLojFor:= aFornece[2]
		cTransp:= aFornece[3]

		cCgcTransp:= TMSGBscCGC(cTransp,cFornec,cLojFor,lNumProp)
	EndIf
	
	oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_NRCIDO', TMS120CDUF(cUfOri, "1") + cCdMunO )  
	oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_NRCIDD', TMS120CDUF(cUfDes, "1") + cCdMunD )
	
	oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_SIT'   , "1" )   //Digitado
	oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDTPOP' , cCdtpop )
	oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDCLFR' , cCdclfr )
	oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDTPVC' , cTipVei ) 
	oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDTRP'  , cCGCTransp )
	
	oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_DTIMPL' , dDatabase )
	oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_HRIMPL' , SubStr(Time(),1,5) )

	If lViagem
		//---- Campos novos na Integração da Viagem x GFE
		If GWN->(ColumnPos('GWN_CEPO')) > 0
			oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CEPO'   , cCepOri )
			oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CEPD'   , cCepDes )
		EndIf

		If GWN->(ColumnPos('GWN_CDMTR')) > 0
			oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDMTR'  , cCodMot )
		EndIf

		oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDTPVC' , DTQ->DTQ_TIPVEI )
		
		DTR->(dbSetOrder(3))
		If DTR->(dbSeek(xFilial('DTR')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
			oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_PLACAD' , Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_PLACA') )
			oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_PLACAM' , Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODRB1,'DA3_PLACA') )
			oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_PLACAT' , Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODRB2,'DA3_PLACA') )
		EndIf

		//-- Retorna a distancia por cliente / regiao.
		cCdrOri := DA8->DA8_CDRORI   //-- Regiao de Origem
		cCdrDes := TMSRetRegD(DTQ->DTQ_SERTMS,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM) //--Região de Destino

		If DTQ->DTQ_SERTMS <> StrZero(2, Len(DTQ->DTQ_SERTMS))
			nQtdKm := TMSDistRot(,.F.,cCdrOri,cCdrDes)
		Else
			nQtdKm := TMSDistRot(DTQ->DTQ_ROTA,.F.)
		EndIf

		oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_DISTAN' , nQtdKm )
	EndIf

	If lRet
		If oModelGWN:VldData()
			oModelGWN:CommitData()

			cChvGFE:= xFilial("GWN") + ';' + oModelGWN:GetValue(  'GFEA050_GWN','GWN_NRROM' )

			If lCalcAut .And. aScan(aCalcRom, PadR(oModelGWN:GetValue(  'GFEA050_GWN','GWN_FILIAL' ), TamSx3("GWN_FILIAL")[1] ) + oModelGWN:GetValue(  'GFEA050_GWN','GWN_NRROM' ) ) == 0
				aAdd(aCalcRom, PadR(oModelGWN:GetValue(  'GFEA050_GWN','GWN_FILIAL' ), TamSx3("GWN_FILIAL")[1] ) + oModelGWN:GetValue(  'GFEA050_GWN','GWN_NRROM' ) )
			EndIf
		Else
			cMsg := STR0002+CRLF+CRLF+oModelGWN:GetErrorMessage()[6]//"Inconsistência com o Frete Embarcador (SIGAGFE): "##
			lRet := .F.
		EndIf
	EndIf

	oModelGWN:Deactivate()
EndIf

If !lRet .And. !Empty(cMsg)
	Help( ,, 'Atencao',,cMsg, 1, 0 ) //"Atenção"
EndIf

RestArea( aAreaGWN )

Return lRet

//---------------------------------------------------
/*/Intregração TMS - Redespachantes x Documentos
@author Katia
@version P11
@since 04/10/2013
//Função removida do fonte OMSM011 em Agosto/2018
/*/
//---------------------------------------------------
Function TMSFUNGDFV(nRecnoDFV, ArqvLog, lViagem, nRecnoDUD )

Local aArea          := GetArea()
Local nI             := 1
Local oModelNFS      := FWLoadModel("GFEA044")
Local oModelItens    := oModelNFS:GetModel('GFEA044_GW8')
Local oModelTrechos  := oModelNFS:GetModel('GFEA044_GWU')
Local oMdGridGXP     := oModelNFS:GetModel('GFEA044_GXP')
Local cA1_CGC        := ""
Local cEmisDc        := ""
Local nAltura        := 0
Local nVolume        := 0
Local cDsitem        := ""
Local lNumProp   := Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)
Local cTPDCTMS   := SuperGetMV("MV_TPDCTMS",,"")
Local cCdTpDc    := Padr(cTPDCTMS,Len(GW1->GW1_CDTPDC)) //SubStr(Posicione("SX5",1,xFilial("SX5")+"MQ"+cTPDCTMS+"S","X5_DESCRI"),1,TamSx3("GW1_CDTPDC")[1])
Local cAliasDTC  := ""
Local cQuery     := ""
Local cNota      := ""
Local aAreaDTC   := {}
Local lRet	     := .F.
Local cTransp    := ""
Local cNumRom    := ""
Local aChvExt    := {}
Local nOpc		 := 0
Local nTrecho    := 0
Local cSeek      := 0
Local cA1_EstDes := ""
Local cA1_CdMuDes:= ""
Local cTipVei    := ""
Local lReentDev	 := .F.
Local cFilDoc		:= ""
Local cDoc			:= ""
Local cSerie		:= ""
Local cCHVEXT		:= ""
Local cCodFor		:= ""
Local cLojFor		:= ""
Local cA1_CEPDes	:= ""
Local cCliRem		:= ""
Local cLojRem		:= ""
Local lSeqEnd		:= .F.
Local cCodUF		:= ""
Local cMunEnt		:= ""
Local cEmisDes	    := ""
Local aAreaSM0      := {}
Local cCdClFrete    := SuperGetMv("MV_CDCLFR",.F.,"")
Local cColGFE       := SuperGetMV( "MV_COLGFE" ,.F., "0" )  //0-Padrão, 1-Encerramento, 2-Nao Integra Coleta
Local lDadosDUA     := .F.
Local cSit 			:= ""
Local cTpFrete		:= ""
Local cNFeIdAux		:= ""
Local cGW1Dest		:= ""
Local nQtdVol		:= 0 
Local aForRedesp    := {}

Default nRecnoDFV	:= 0
Default ArqvLog 	:= ""
Default lViagem	:= .F.
Default nRecnoDUD	:= 0

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
	aForRedesp:= TMSGBscFav(,,cCodFor,cLojFor)  //Fornecedor do Redespacho
	If Len(aForRedesp) > 0			
		cCodFor:= aForRedesp[1]
		cLojFor:= aForRedesp[2]
		cTransp:= aForRedesp[3]
	EndIf

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
	DT6->(dbSetOrder(1))
	If DT6->(dbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie)) .And. DT6->DT6_SERTMS <> StrZero(1,Len(DT6->DT6_SERTMS))
		//--- Documentos do DTC
		cAliasDTC:= GetNextAlias()
		cQuery := "	SELECT * FROM ( "
		cQuery += "	SELECT DTC_FILIAL, DTC_FILORI, DTC_FILDOC, DTC_DOC, DTC_SERIE, DTC_NUMNFC, DTC_SERNFC, DTC_EMINFC, DTC_CLIREM, DTC_LOJREM, DTC_CLIDES, DTC_LOJDES, DTC_NFEID, DTC_VALICM,DTC_CODPRO,DTC_LOTNFC, DTC_SQEDES, DTC_PRVENT "
		cQuery += "       FROM " + RetSqlName("DTC") + " DTC "
		cQuery += " WHERE DTC.DTC_FILIAL = '" + xFilial('DTC') + "' "
		cQuery += "  AND DTC.DTC_FILDOC   = '" + cFilDoc + "' "
		cQuery += "  AND DTC.DTC_DOC      = '" + cDoc + "' "
		cQuery += "  AND DTC.DTC_SERIE    = '" + cSerie + "' "
		cQuery += "  AND DTC.D_E_L_E_T_   = ' ' "
		cQuery += " UNION "
		cQuery += " SELECT DY4_FILIAL AS DTC_FILIAL, DY4_FILORI AS DTC_FILORI, DY4_FILDOC AS DTC_FILDOC, DY4_DOC AS DTC_DOC, DY4_SERIE AS DTC_SERIE, DY4_NUMNFC AS DTC_NUMNFC, DY4_SERNFC AS DTC_SERNFC, '' AS DTC_EMINFC, "
		cQuery += " DY4_CLIREM AS DTC_CLIREM, DY4_LOJREM AS DTC_LOJREM, '' AS DTC_CLIDES, '' AS DTC_LOJDES, '' AS DTC_NFEID, 0 AS DTC_VALICM,DY4_CODPRO AS DTC_CODPRO,DY4_LOTNFC AS DTC_LOTNFC, '' AS DTC_SQEDES, '' AS DTC_PRVENT "
		cQuery += "       FROM " + RetSqlName("DY4") + " DY4 "
		cQuery += " WHERE DY4.DY4_FILIAL = '" + xFilial('DY4') + "' "
		cQuery += "  AND DY4.DY4_FILDOC   = '" + cFilDoc + "' "
		cQuery += "  AND DY4.DY4_DOC      = '" + cDoc + "' "
		cQuery += "  AND DY4.DY4_SERIE    = '" + cSerie + "' "

		cQuery += "  AND DY4.D_E_L_E_T_   = ' ' "

		cQuery += "	)AliasTmp ORDER BY DTC_FILDOC, DTC_DOC, DTC_SERIE, DTC_NUMNFC, DTC_SERNFC "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)
		TcSetField(cAliasDTC,"DTC_EMINFC", "D", 8, 0)
		TcSetField(cAliasDTC,"DTC_PRVENT", "D", 8, 0)

		While (cAliasDTC)->(!Eof())
			If TmsPsqDY4(cFilDoc,cDoc,cSerie)
				DbSelectArea("DTC")
				DbSetOrder(2) //Filial + Doc.Cliente + Serie Dc.Cli + Remetente + Loja Remet. + Cod. Produto
				If DTC->(MsSeek(xFilial("DTC")+(cAliasDTC)->DTC_NUMNFC+(cAliasDTC)->DTC_SERNFC+(cAliasDTC)->DTC_CLIREM+(cAliasDTC)->DTC_LOJREM+(cAliasDTC)->DTC_CODPRO+(cAliasDTC)->DTC_FILORI+(cAliasDTC)->DTC_LOTNFC))
					lReentDev := .T.
				Endif
			EndIf

			If (cAliasDTC)->DTC_NUMNFC+(cAliasDTC)->DTC_SERNFC <> cNota
				If lNumProp
					If FindFunction( "GFEM011COD")
						cEmisDc:= GFEM011COD((cAliasDTC)->DTC_CLIREM,(cAliasDTC)->DTC_LOJREM,1,,)
					EndIf	
				Else
					cEmisDc:= Posicione("SA1",1,xFilial("SA1")+(cAliasDTC)->DTC_CLIREM+(cAliasDTC)->DTC_LOJREM,"A1_CGC")
				EndIf

				lRet:= .T.
				nOpc:= 3
				//--- Verifica se o Documento ja foi integrado ao SIGAGFE
				GW1->( dbSetOrder(1) )
				If GW1->( dbSeek( Iif(lViagem,DTQ->DTQ_FILORI,xFilial("GW1"))+PadR(cCDTPDC,Len(GW1_CDTPDC))+cEmisDc+PadR((cAliasDTC)->DTC_SERNFC,Len(GW1->GW1_SERDC))+PadR((cAliasDTC)->DTC_NUMNFC,Len(GW1->GW1_NRDC)) ))
					nOpc:= 4
					lRet:= TmsChkGWN(cFilDoc,cDoc,cSerie, PadR(GW1->GW1_FILIAL, TamSx3("GWN_FILIAL")[1] ) + GW1->GW1_NRROM,.T.)

				EndIf
		
			   	If nOpc == 3 

					If _lModel
						oModelNFS:SetOperation( MODEL_OPERATION_INSERT )
						oModelNFS:Activate()

						//Cabeçalho do Documento de Carga
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_FILIAL', Iif(lViagem,DTQ->DTQ_FILORI,xFilial("GW1")) )
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_CDTPDC', cCdTpDc )
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_SERDC' , (cAliasDTC)->DTC_SERNFC )
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_NRDC'  , (cAliasDTC)->DTC_NUMNFC )
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DTPENT', (cAliasDTC)->DTC_PRVENT )
						
						If !lReentDev
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DTEMIS', (cAliasDTC)->DTC_EMINFC )
						Else
							//para casos de reentrega ou devolucao posicionou acima na DTC a partir da DY4
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DTEMIS', DTC->DTC_EMINFC )
						EndIf
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ORIGEM', "3" )
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_CDREM' , cEmisDc )
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_EMISDC', cEmisDc )
					EndIf 

			          //--- Dados cliente destinatario da Nota
					SA1->( dbSetOrder(1) )
					If !lReentDev
						If SA1->( dbSeek(xFilial("SA1")+(cAliasDTC)->DTC_CLIDES+(cAliasDTC)->DTC_LOJDES ) )
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
					Else
						//para casos de reentrega ou devolucao posicionou acima na DTC a partir da DY4
						If SA1->( dbSeek(xFilial("SA1")+DTC->DTC_CLIDES+DTC->DTC_LOJDES ) )
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
					EndIf

					If lNumProp
						If !lReentDev
							If FindFunction( "GFEM011COD")
								cGW1Dest	:= GFEM011COD((cAliasDTC)->DTC_CLIDES,(cAliasDTC)->DTC_LOJDES,1,,)								
							EndIf	
						Else
							//para casos de reentrega ou devolucao posicionou acima na DTC a partir da DY4
							If FindFunction( "GFEM011COD")
								cGW1Dest	:= GFEM011COD(DTC->DTC_CLIDES,DTC->DTC_LOJDES,1,,) 	
							EndIf								
						EndIf
					Else
						cGW1Dest	:= cA1_CGC							
					EndIf

					If _lModel						
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_CDDEST', cGW1Dest )
					EndIf 

					If !Empty(cCHVEXT)
					    aChvExt:= Str2Arr(Upper(cCHVEXT), ";")   //quebra em array por delimitador ";"
					    cNumRom:= Iif(Len(aChvExt[2])>0,aChvExt[2],'')

						dbSelectArea("GWN")
						GWN->( dbSetOrder(1) )
						GWN->( dbSeek(xFilial("GWN")+cNumRom ) )
						If !GWN->( Eof() ) .And. GWN->GWN_FILIAL == xFilial("GWN");
												.And. GWN->GWN_NRROM == cNumRom
							cSit	:= "4"
							If _lModel
								oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_SIT'   , "4" )
								oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_NRROM' , cNumRom)
							EndIf 
						Else
							cSit	:= "3"
							If _lModel
								oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_SIT'   , "3" )
							EndIf 
						EndIf
					Else
						cSit	:= "3"	
						If _lModel
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_SIT'   , "3" )
						EndIf 
					EndIf

					If _lModel
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DTIMPL', DT6->DT6_DATEMI )
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_HRIMPL', DT6->DT6_HOREMI )
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_AUTSEF', "0" )   //Nao Informado
					EndIf 

					dDataMaior := GW1->GW1_DTIMPL
			   		cHoraMaior := GW1->GW1_HRIMPL

					
					If !lReentDev
						cNFeIdAux	:= (cAliasDTC)->DTC_NFEID						
					Else
						//para casos de reentrega ou devolucao posicionou acima na DTC a partir da DY4
						cNFeIdAux	:= DTC->DTC_NFEID						
					Endif

					cTpFrete	:= "1"
					If _lModel
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DANFE' , cNFeIdAux)
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "1" )		  //CIF
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DTLIB' , DATE() )
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_HRLIB' , SubStr(TIME(),1,5) )

						If !lReentDev
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ICMSDC', IIF((cAliasDTC)->DTC_VALICM == 0 , "2" , "1") )
						Else
							//para casos de reentrega ou devolucao posicionou acima na DTC a partir da DY4
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ICMSDC', IIF(DTC->DTC_VALICM == 0 , "2" , "1") )
						EndIf
					EndIf 

					//---- Endereco de Entrega
					If lViagem .Or. lTmsRdpU
						lSeqEnd:= .F.
						If !Empty((cAliasDTC)->DTC_SQEDES)
							DUL->(DbSetOrder(2))
							If DUL->(MsSeek( xFilial('DUL') + (cAliasDTC)->DTC_CLIDES + (cAliasDTC)->DTC_LOJDES + (cAliasDTC)->DTC_SQEDES ))
								lSeqEnd:= .T.
							EndIf
						EndIf
						
						cMunEnt:= Iif(lSeqEnd, DUL->DUL_CODMUN, SA1->A1_CODMUNE )
						If !Empty(cMunEnt)
							cCodUF:= TMS120CdUf(Iif(lSeqEnd, DUL->DUL_EST, SA1->A1_ESTE ), '1')							
						EndIf

						If _lModel
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTEND', Iif(lSeqEnd, DUL->DUL_END, SA1->A1_ENDENT) )
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTCEP', Iif(lSeqEnd, DUL->DUL_CEP, SA1->A1_CEPE ) )
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTBAI', Iif(lSeqEnd, DUL->DUL_BAIRRO, SA1->A1_BAIRROE ) )
							If !Empty(cMunEnt)
								oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTNRC', cCodUF + cMunEnt )
							EndIf 
						EndIf 
					EndIf

					//---- Itens do Documentos DTC
					nItemDTC:= 0
					aAreaDTC:= DTC->(GetArea())
					DTC->( dbSetOrder(2) )
					If !lReentDev
						cSeek:= xFilial("DTC")+(cAliasDTC)->DTC_NUMNFC+(cAliasDTC)->DTC_SERNFC+(cAliasDTC)->DTC_CLIREM+(cAliasDTC)->DTC_LOJREM
						DTC->( dbSeek(cSeek))
					Else
						//para casos de reentrega ou devolucao posicionou acima na DTC a partir da DY4
						cSeek:= xFilial("DTC")+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM
					EndIf

					While !DTC->( Eof() ) .And. DTC->DTC_FILIAL+DTC->DTC_NUMNFC+DTC->DTC_SERNFC+DTC->DTC_CLIREM+DTC->DTC_LOJREM == cSeek
						If	(cAliasDTC)->DTC_FILORI <> 	DTC->DTC_FILORI
							DTC->( dbSkip() )
							Loop
						EndIf

						If nI != 1 
							If _lModel 
								oModelItens:AddLine()
								oModelItens:GoLine( nI )
							EndIf 
						EndIf
						nAltura := Posicione("SB5",1,xFilial("SB5")+ (DTC->DTC_CODPRO),"B5_ALTURA")
						nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR)* (DTC->DTC_QTDVOL)
						cDsitem := SubStr(Posicione("SB1",1,xFilial("SB1")+DTC->DTC_CODPRO,"B1_DESC"),1,50)
						nQtdVol	+= DTC->DTC_QTDVOL

						If _lModel 
							//Itens do Documento de Carga
							If !oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_CDTPDC', cCdTpDc )
								TmsSetErr(FwX3Titulo('GW8_CDTPDC') + " " + cCdTpDc, 'MV_TPDCTMS' ,oModelNFS) 
							EndIf

							If !oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_EMISDC', cEmisDc )
								TmsSetErr(FwX3Titulo('GW8_EMISDC') + " " + cEmisDc, 'DTC_CLIREM/DT_LOJREM' ,oModelNFS) 
							EndIf

							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_SERDC' , DTC->DTC_SERNFC )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_NRDC'  , DTC->DTC_NUMNFC )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_SEQ'   , MsStrZero(nI,2) )

							If !oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_ITEM'  , DTC->DTC_CODPRO )
								TmsSetErr("Lote: "  + (cAliasDTC)->DTC_LOTNFC +  " Nf: " +  AllTrim((cAliasDTC)->DTC_NUMNFC) +  "/" +  (cAliasDTC)->DTC_SERNFC , 'DTC_CODPRO' ,oModelNFS) 
							EndIf

							If !oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_CDCLFR', Iif(Empty(cCDCLFR),cCdClFrete,cCDCLFR)) 
								TmsSetErr("Docto: " + (cAliasDTC)->DTC_FILDOC + ' ' + (cAliasDTC)->DTC_DOC + ' ' + (cAliasDTC)->DTC_SERIE + ' - ' + FwX3Titulo('GW8_CDCLFR')   + " "  + cCDCLFR  , '' ,oModelNFS) 
							EndIf
						
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_DSITEM', cDsitem )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_QTDE'  , DTC->DTC_QTDVOL )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_VALOR' , DTC->DTC_VALOR )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_VOLUME', Iif(nVolume <> 0, nVolume, DTC->DTC_METRO3 ) )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_PESOR' , DTC->DTC_PESO )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_PESOC' , DTC->DTC_PESOM3 )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_CFOP'  , SubStr(DTC->DTC_CF,1,TamSx3("GW8_CFOP")[1]) )
						EndIf 

						nI++
						DTC->( dbSkip() )
					EndDo
					RestArea(aAreaDTC)
				EndIf

				
				If lRet
					cNota:= (cAliasDTC)->DTC_NUMNFC + (cAliasDTC)->DTC_SERNFC

					//----Trecho do Documento de Carga
					If !lViagem
						DVU->(DbSetOrder(1)) //DVU_FILIAL+DVU_FILORI+DVU_NUMNFC+DVU_SERNFC+DVU_CLIREM+DVU_LOJREM+DVU_ITEM
						If DVU->(DbSeek(xFilial("DVU")+(cAliasDTC)->DTC_FILORI+(cAliasDTC)->DTC_NUMNFC+(cAliasDTC)->DTC_SERNFC+(cAliasDTC)->DTC_CLIREM+(cAliasDTC)->DTC_LOJREM ))
							cTipVei:= DVU->DVU_TIPVEI   //Pegar o primeiro
						EndIf
					EndIf

					nTrecho:= 0
					TMSFUNGTRE(nOpc,oModelNFS,oModelTrechos,cCdTpDc,cEmisDc,Iif(lViagem,'',DFV->DFV_UFDES),Iif(lViagem,'',DFV->DFV_CDMUND),(cAliasDTC)->DTC_NUMNFC,;
					           (cAliasDTC)->DTC_SERNFC,cTransp,@nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,lViagem,cA1_CEPDes,cCodFor,cLojFor)

					If _lModel .And. nTrecho > 1 
						cTpFrete	:= "2"
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "2" )		  //CIF COM REDESPACHO
					EndIf

					If _lModel .And. !oModelNFS:VldData() 
						If IsInCallStack("GFEM011")
							CreateLog(ArqvLog, oModelNFS, cProTable,  cRotiProt)
						Else
                            If !Empty(AllTrim(oModelNFS:GetErrorMessage()[5]))
								If Len(aErrGFE) == 0
									Aadd(aErrGFE,{STR0002})  //"Inconsistência com o Frete Embarcador (SIGAGFE): "
								EndIf
								Aadd(aErrGFE,{STR0003 + (cAliasDTC)->DTC_FILDOC + " " + (cAliasDTC)->DTC_DOC + " " + (cAliasDTC)->DTC_SERIE + " - Nf: "  + (cAliasDTC)->DTC_NUMNFC +  " " + (cAliasDTC)->DTC_SERNFC;
									           +  " / " + (cAliasDTC)->DTC_CLIREM +  " " + (cAliasDTC)->DTC_LOJREM + " : " + oModelNFS:GetErrorMessage()[6]+" "+oModelNFS:GetErrorMessage()[4] })
							EndIf
						EndIf
						lRet:= .F.
					Else
						If Len(aErrGFE) ==  0 
							If _lModel 
								oModelNFS:CommitData()
								If !Empty(ArqvLog) .And. !lViagem
									ArqvLog:Add("| TMSAR05| " + PadR("Filial: " + AllTrim(DFT->DFT_FILIAL) + ", Redespacho: " + DFT->DFT_NUMRED, 38) + " |           | Ok")
								EndIf
							EndIf
						Else
							lRet:= .F.
						EndIf	
					EndIf					
                EndIf

				If _lModel 
					oModelNFS:Deactivate()
				EndIf 
			EndIf

			If lRet
				//-- Atualiza Tabela GWE (Relacionamento GW1 e DT6)
				TMSFUNGGWE(Iif(lViagem,DUD->DUD_FILDOC,DFV->DFV_FILDOC),;
				           Iif(lViagem,DUD->DUD_DOC,DFV->DFV_DOC),;
				           Iif(lViagem,DUD->DUD_SERIE,DFV->DFV_SERIE),;
				           Iif(lViagem,DUD->DUD_FILORI,DFV->DFV_FILORI),;
				           Iif(lViagem,DUD->DUD_VIAGEM,''),;
				           Iif(lViagem,,DFV->DFV_NUMRED))
			EndIf

			(cAliasDTC)->(DbSkip())
		EndDo
		(cAliasDTC)->(DbCloseArea())

	Else

		//---- Coleta
		DT5->(DbSetOrder( 4 ))
		If DT5->(MsSeek(xFilial('DT5')+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))

			If cColGFE == '1' 
				nRecDUA:= TMSUltOcor(DUD->DUD_FILORI,DUD->DUD_VIAGEM,DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE)		
				//Considera os dados da DUA (peso, volume, valor) caso encontrar ocorrencia para a Coleta, se Nao, considera a DUM	  
				lDadosDUA:= nRecDUA > 0 
			EndIf

			If DT5->(ColumnPos('DT5_CLIREM')) > 0
				cCliRem:= DT5->DT5_CLIREM
				cLojRem:= DT5->DT5_LOJREM
			EndIf

			If Empty(cCliRem)
				DUE->(DbSetOrder(1))
				If DUE->(dbSeek(xFilial('DUE')+DT5->DT5_CODSOL))
					cCliRem:= DUE->DUE_CODCLI
					cLojRem:= DUE->DUE_LOJCLI
				EndIf
			EndIf

			If Empty(cCliRem)
				If FindFunction( "GFEM011COD")
					cEmisDc := GFEM011COD(,,,.T.,DT5->DT5_FILORI)
				EndIf	
			Else
				If lNumProp
					If FindFunction( "GFEM011COD")
						cEmisDc:= GFEM011COD(cCliRem,cLojRem,1,,)
					EndIf
				Else
					cEmisDc:= Posicione("SA1",1,xFilial("SA1")+cCliRem+cLojRem,"A1_CGC")
				EndIf
			EndIf

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
				If _lModel 
					oModelNFS:SetOperation( MODEL_OPERATION_INSERT )
					oModelNFS:Activate()

					//Cabeçalho do Documento de Carga
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_FILIAL', xFilial("GW1") )
					If !oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_CDTPDC', cCdTpDc )
						TmsSetErr(FwX3Titulo('GW8_CDTPDC') + " " + cCdTpDc, 'GV5_CDTPDC' ,oModelNFS) 
					EndIf	
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_SERDC' , 'COL' )
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_NRDC'  , DT5->DT5_NUMSOL )
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DTEMIS', DT5->DT5_DATSOL )
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ORIGEM', "3" )
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_CDREM' , cEmisDc )
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_EMISDC', cEmisDc )
				EndIf 
				
				cCliDes:= DT5->DT5_CLIDES
				cLojDes:= DT5->DT5_LOJDES

				If Empty(cCliDes)
					If FindFunction( "GFEM011COD")
						cEmisDes := GFEM011COD(,,,.T.,DT5->DT5_FILORI)
					EndIf
					If _lModel 
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_CDDEST', cEmisDes )
					EndIf 

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
				Else
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

					If _lModel 
						If lNumProp
							If FindFunction( "GFEM011COD")
								oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_CDDEST', GFEM011COD(cCliDes,cLojDes,1,,) )
							EndIf	
						Else
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_CDDEST', cA1_CGC )
						EndIf
					EndIF 

				EndIf

				If !Empty(cCHVEXT)
				    aChvExt:= Str2Arr(Upper(cCHVEXT), ";")   //quebra em array por delimitador ";"
				    cNumRom:= Iif(Len(aChvExt[2])>0,aChvExt[2],'')

					dbSelectArea("GWN")
					GWN->( dbSetOrder(1) )
					GWN->( dbSeek(xFilial("GWN")+cNumRom ) )
					If !GWN->( Eof() ) .And. GWN->GWN_FILIAL == xFilial("GWN");
											.And. GWN->GWN_NRROM == cNumRom

						If _lModel 
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_SIT'   , "4" )
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_NRROM' , cNumRom)
						EndIf 

					Else
						If _lModel 
							oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_SIT'   , "3" )
						EndIf 
					EndIf
				Else
					If _lModel 
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_SIT'   , "3" )
					EndIf
				EndIf

				dDataMaior := GW1->GW1_DTIMPL
			   	cHoraMaior := GW1->GW1_HRIMPL

				If _lModel 
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DTIMPL', DT5->DT5_DATSOL )
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_HRIMPL', DT5->DT5_HORSOL )
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_AUTSEF', "0" )   //Nao Informado
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "1" )		  //CIF
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DTLIB' , DATE() )
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_HRLIB' , SubStr(TIME(),1,5) )
				EndIf 

				//--- Endereco de Entrega
				If lViagem
					If !Empty(DT5->DT5_SQEDES)
						DUL->(DbSetOrder(3))
						If DUL->(MsSeek( xFilial('DUL') + DT5->DT5_CODSOL + DT5->DT5_SEQEND ))

							If _lModel
								oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTEND', DUL->DUL_END )
								oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTCEP', DUL->DUL_CEP )
								oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTBAI', DUL->DUL_BAIRRO )

								If !Empty(DUL->DUL_CODMUN)
									cCodUF:= TMS120CdUf(DUL->DUL_CODMUN, '1')
									oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTNRC', cCodUF + DUL->DUL_CODMUN )
								EndIf
							EndIf 
						EndIf
					EndIf
				EndIf

				//---- Itens do Documentos DUM
				nItemDUM:= 0
				DbSelectArea("DUM")
				DbSetOrder(1) //-- DUM_FILIAL+DUM_FILORI+DUM_NUMSOL+DUM_ITEM
				MsSeek(xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL ,.F.)
				While DUM->(!Eof()) .And.  (DUM->(DUM_FILIAL+DUM_FILORI+DUM_NUMSOL) == (xFilial("DUM") + DT5->DT5_FILORI + DT5->DT5_NUMSOL))
					If _lModel .And. nI != 1
						oModelItens:AddLine()
						oModelItens:GoLine( nI )
					EndIf

					nAltura := Posicione("SB5",1,xFilial("SB5")+ (DUM->DUM_CODPRO),"B5_ALTURA")
					nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR)* (DUM->DUM_QTDVOL)
					cDsitem := SubStr(Posicione("SB1",1,xFilial("SB1")+DUM->DUM_CODPRO,"B1_DESC"),1,50)

					If _lModel 
						//Itens do Documento de Carga
						oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_CDTPDC', cCdTpDc )
						oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_EMISDC', cEmisDc )
						oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_SERDC' , 'COL' )
						oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_NRDC'  , DT5->DT5_NUMSOL )
						oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_SEQ'   , MsStrZero(nI,2) )
						If !oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_ITEM'  , DUM->DUM_CODPRO )
							TmsSetErr("Coleta: " +  DT5->DT5_NUMSOL +  "-" +  'COL' , 'DUM_CODPRO' ,oModelNFS) 
						EndIf	

						If !oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_CDCLFR', Iif(Empty(cCDCLFR),cCdClFrete,cCDCLFR) )
							TmsSetErr("Docto: " + DT5->DT5_NUMSOL + ' COL - ' + FwX3Titulo('GW8_CDCLFR')   + " "  + cCDCLFR  , '' ,oModelNFS) 
						EndIf
						oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_DSITEM', cDsitem )
					
						If !lDadosDUA
							//Considera somente o primeiro Produto, pois as quantidades estarao agrupadas nas ocorrencias (DUA)
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_QTDE'  , DUM->DUM_QTDVOL )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_VALOR' , DUM->DUM_VALMER )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_VOLUME', Iif( nVolume <> 0, nVolume, DUM->DUM_METRO3) )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_PESOR' , DUM->DUM_PESO )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_PESOC' , DUM->DUM_PESOM3 )					
						Else	
							DUA->(DbGoTo(nRecDUA))
							nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR)* (DUA->DUA_QTDOCO)
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_QTDE'  , DUA->DUA_QTDOCO )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_VALOR' , DUA->DUA_VLROCO )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_VOLUME', Iif( nVolume <> 0, nVolume, DUA->DUA_MT3OCO) )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_PESOR' , DUA->DUA_PESOCO )
							oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_PESOC' , DUA->DUA_PM3OCO )
							Exit
						EndIf
					EndIf 
				
					nI++
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
				TMSFUNGTRE(nOpc,oModelNFS,oModelTrechos,cCdTpDc,cEmisDc,'','',DT5->DT5_NUMSOL,;
				           'COL',cTransp,@nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,.T.,cA1_CEPDes,cCodFor,cLojFor)

				If nTrecho > 1
					If _lModel 
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "2" )		  //CIF COM REDESPACHO
					EndIf 
				EndIf

				//---- Documentos de Origem GXP
				If AliasIndic('GXP')
					TMSFUNGSOL(DT5->DT5_FILORI, DT5->DT5_NUMSOL,oMdGridGXP , cCdTpDc,DT5->DT5_NUMSOL,"COL",cEmisDc)  
				EndIf

				If _lModel 
					If oModelNFS:VldData()
						oModelNFS:CommitData()
					Else
						If AllTrim(oModelNFS:GetErrorMessage()[5]) == "REGREJEITA" .Or. AllTrim(oModelNFS:GetErrorMessage()[5]) == "EXISTGFE" .Or. !Empty( AllTrim(oModelNFS:GetErrorMessage()[6]))
							If Len(aErrGFE) == 0
								Aadd(aErrGFE,{STR0002}) //"Inconsistência com o Frete Embarcador (SIGAGFE): "
							EndIf
							Aadd(aErrGFE,{STR0003 + DT5->DT5_FILORI + " " + DT5->DT5_NUMSOL  + " COL : " + oModelNFS:GetErrorMessage()[6]+" "+oModelNFS:GetErrorMessage()[4] })
							lRet := .F.
						EndIf
					EndIf
				Endif
			EndIf

			If _lModel 
				oModelNFS:Deactivate()
				oModelNFS:Destroy()
			EndIf 

			If lRet
				//-- Atualiza Tabela GWE (Relacionamento GW1 e DT6)
				TMSFUNGGWE(DUD->DUD_FILDOC,DUD->DUD_DOC,'COL',DUD->DUD_FILORI, DUD->DUD_VIAGEM,'')
			EndIf
		Else
			If Len(aErrGFE) == 0
				Aadd(aErrGFE,{STR0002}) //"Inconsistência com o Frete Embarcador (SIGAGFE): "
			EndIf
			Aadd(aErrGFE,{STR0003 + DT5->DT5_FILORI + " " + DT5->DT5_NUMSOL  + ": " + STR0004 })   //"Solicitação de Coleta não localizado!"
			lRet := .F.
		EndIf

	EndIf
EndIf

//-- Libera o Romaneio
If lRet .And. GWN->GWN_SIT == StrZero( 1, Len( GWN->GWN_SIT ) )  //Digitado
	GFE50LbRom()
EndIf

RestArea( aArea )
Return lRet

//---------------------------------------------------
/*/
Trechos do Documento de Carga
@author Katia
@version P11
@since 14/10/2013
//Função removida do fonte OMSM011 em Agosto/2018
/*/
//---------------------------------------------------
Function TMSFUNGTRE(nOpc,oModelNFS,oModelTrechos,cCdTpDc,cEmisDc,cUfDes,cCdMunDes,cNumNFC,cSerNFC,cTransp,nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,lViagem,cA1_CEPDes,cCodFor,cLojFor)
Local lNumProp   := Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)
Local cSeq       := CriaVar('GWU_SEQ')
Local lRet       := .T.
Local aArea      := GetArea()
Local cCepD      := ""
Local cTranspGWU := ""
Local lUltTrecho := .F.
Local cCepOGWU   := ""
Local cCdMunOGWU := ""
Local cGW1_EntNrc:= ""
Local cGW1_EntCep:= ""
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

		If _lModel 
			oModelNFS:SetOperation(nOpc)
			oModelNFS:Activate()

			oModelTrechos:AddLine()
			oModelTrechos:GoLine(Val(AllTrim(cSeq)))
		EndIf 
	EndIf
EndIf

If lRet
	cCgcTransp:= TMSGBscCGC(cTransp,cCodFor,cLojFor,lNumProp)
	
	If _lModel 
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPDC', cCdTpDc )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_EMISDC', cEmisDc )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_SERDC' , cSerNFC )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRDC'  , cNumNFC )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_SEQ'   , cSeq )
		If !oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTRP' , cCgcTransp )
			TmsSetErr(AllTrim(FwX3Titulo('GWU_CDTRP')) +  ": " + cCgcTransp + ' : ' + 'Fornecedor: ' + cCodFor+ ' / ' + cLojFor, 'A2_TRANSP' ,oModelNFS) 
		EndIf	
	EndIf

	//---- Primeiro Trecho (NAO PAGAR) --Origem do Documento é diferente da Origem informado no Trecho Inicial, gera o primeiro trecho como não pago
	If nOpc == 3 .And. lPrimTrech .And. !lViagem
		DT6->( dbSetOrder( 1 ) )
		If DT6->( DbSeek( xFilial('DT6') + DFV->(DFV_FILDOC+DFV_DOC+DFV_SERIE ) ))
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial('SA1')+DT6->DT6_CLIREM+DT6->DT6_LOJREM)) .And. !Empty(SA1->A1_EST) .And. !Empty(SA1->A1_COD_MUN)
				If rTrim(TMS120CdUf(DFV->DFV_UFORI, "1") + DFV->DFV_CDMUNO ) <> TMS120CDUF(SA1->A1_EST, "1") + SA1->A1_COD_MUN
					If _lModel 
						oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_PAGAR' , "2" )  //Pagar Não
						oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CEPO'  , SA1->A1_CEP )
						oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDO', TMS120CDUF(SA1->A1_EST, "1") + SA1->A1_COD_MUN )
						oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CEPD'  , DFV->DFV_CEPORI )
						oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', rTrim(TMS120CdUf(DFV->DFV_UFORI, "1") + DFV->DFV_CDMUNO ) )
						oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPVC', DFV->DFV_TIPVEI )
						oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPOP', DFV->DFV_CDTPOP )
						oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDCLFR', DFV->DFV_CDCLFR )
						oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CHVEXT', 'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED  )			
						oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "2" )		  //CIF COM REDESPACHO
						
						cSeq:= Soma1(cSeq)
						oModelTrechos:AddLine()
						oModelTrechos:GoLine(Val(AllTrim(cSeq)))
					EndIf 
				EndIf	
			EndIf	
		EndIf
	EndIf


	//----- Redespacho (DFT/DFV)
	If !lViagem .And. !lTmsRdpU
		
		If _lModel 
			//---- Primeiro Trecho 'A pagar'
			oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_PAGAR' , "1" )
			oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', rTrim(TMS120CdUf(DFV->DFV_UFDES, "1") + DFV->DFV_CDMUND ))
			oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPVC', cTipVei )
			If GWU->(ColumnPos('GWU_CHVEXT')) > 0  //Campo criado para a integração da Viagem, porem alterado para incluir chave externa do Redespacho
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CHVEXT', 'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED  )
			EndIf

			oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDO', rTrim(TMS120CdUf(DFV->DFV_UFORI, "1") + DFV->DFV_CDMUNO ) )
		EndIf 

	    //---- Se a regiao de destino do cliente destinatário (dtc_clides) for diferente da regiao de destino do redespacho (DFV_CDMUND),
		//---- deve-se criar um segundo Trecho como 'Nao Pagar'
		If !Empty(cA1_CdMuDes) .And. !Empty(DFV->DFV_CDMUND)
			If DFV->DFV_CDMUND <>  cA1_CdMuDes
		   		cSeq:= Soma1(cSeq)

				cCgcTransp:= TMSGBscCGC(cTransp,cCodFor,cLojFor,lNumProp)
				
				If _lModel 
					oModelTrechos:AddLine()
					oModelTrechos:GoLine(Val(AllTrim(cSeq)))
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDO', rTrim(TMS120CdUf(DFV->DFV_UFDES, "1") + DFV->DFV_CDMUND ) )
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPDC', cCdTpDc )
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_EMISDC', cEmisDc )
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_SERDC' , cSerNFC )
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRDC'  , cNumNFC )
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_SEQ'   , cSeq )
				 
					If !oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTRP' , cCgcTransp )
						TmsSetErr(AllTrim(FwX3Titulo('GWU_CDTRP')) +  ": " + cCgcTransp + ' : Fornecedor: ' + cCodFor + ' / ' + cLojFor, 'A2_TRANSP' ,oModelNFS) 
					EndIf	

					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_PAGAR' , "2" )
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', rTrim(TMS120CdUf(cA1_EstDes, "1") + cA1_CdMuDes))
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPVC', cTipVei )

					If GWU->(ColumnPos('GWU_CHVEXT')) > 0  //Campo criado para a integração da Viagem, porem alterado para incluir chave externa do Redespacho
						oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CHVEXT', 'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED  )
					EndIf
				EndIf 
			EndIf
		EndIf
	Else
		//Quando Redespacho sempre primeiro trecho é Pago
		If lViagem  //----- Viagem (DUD/DJN)
			lPrimTrech:= DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))
		EndIf

		//---- Primeiro Trecho (PAGAR)
		If lPrimTrech
			If !Empty(GW1->GW1_ENTCEP)
				cCepD:= GW1->GW1_ENTCEP
			Else
				cCepD:= DUD->DUD_CEPDES
				If Empty(cCepD)
					cCepD:= cA1_CEPDes
				EndIf
			EndIf

			If _lModel 
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTRP' , cCgcTransp )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_PAGAR' , "1" )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_SEQ'   , cSeq )
				
				If GWU->(ColumnPos('GWU_CEPO')) > 0
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CEPO', Iif(lViagem,DUD->DUD_CEPORI,DFV->DFV_CEPORI) )
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDO', rTrim(TMS120CdUf(Iif(lViagem,DUD->DUD_UFORI,DFV->DFV_UFORI), "1") + Iif(lViagem,DUD->DUD_CDMUNO,DFV->DFV_CDMUNO) ))
				EndIf
				
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CEPD', cCepD )			
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', rTrim(TMS120CdUf(Iif(lViagem,DUD->DUD_UFDES,DFV->DFV_UFDES), "1") + Iif(lViagem,DUD->DUD_CDMUND,DFV->DFV_CDMUND) ))
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPVC', Iif(lViagem,DUD->DUD_TIPVEI,Iif(DFV->(ColumnPos('DFV_TIPVEI')) > 0,DFV->DFV_TIPVEI,'') ))
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPOP', Iif(lViagem,DUD->DUD_CDTPOP,DFV->DFV_CDTPOP) )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDCLFR', Iif(lViagem,DUD->DUD_CDCLFR,DFV->DFV_CDCLFR) )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CHVEXT', Iif(lViagem,'VGMTMS;' + DUD->DUD_FILORI + ';' + DUD->DUD_VIAGEM,;
																			'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED ) )
			EndIf 
			nTrecho:= Val(AllTrim(cSeq))
		EndIf

		//--- Redespachos da Viagem
		If lViagem
			If (DTQ->DTQ_SERTMS $ '1|3')
				TMSFGTRRDA(nOpc,oModelNFS,oModelTrechos,nTrecho,@cSeq,lNumProp,cA1_CEPDes,cCdTpDc,.T. ,cEmisDc , cNumNFC , cSerNFC )
			EndIf
		Else
			TMSFGTRRDA(nOpc,oModelNFS,oModelTrechos,nTrecho,@cSeq,lNumProp,cA1_CEPDes,cCdTpDc,.F. ,cEmisDc , cNumNFC , cSerNFC)
		EndIf

		//--- Quando Destino do Trecho for diferente do Destino do Dcto de Carga e ou Destino de Entrega, incluir um
		//--- trecho Nao Pago para o ultimo transportador do trecho.
		If _lModel
			If !Empty(oModelNFS:GetValue( 'GFEA044_GW1', 'GW1_ENTNRC')) //GW1->GW1_ENTNRC 
				If !Empty(cA1_EstDes) .And. !Empty(cA1_CdMuDes)
					If oModelNFS:GetValue( 'GFEA044_GW1', 'GW1_ENTNRC') <>  TMS120CDUF(cA1_EstDes, "1") + cA1_CdMuDes
						lUltTrecho:= .T.
						cGW1_EntNrc:= oModelNFS:GetValue( 'GFEA044_GW1', 'GW1_ENTNRC')
						cGW1_EntCep:= oModelNFS:GetValue( 'GFEA044_GW1', 'GW1_ENTCEP')
					EndIf
				EndIf
			Else
				If !Empty(cA1_EstDes) .And. !Empty(cA1_CdMuDes)
					lUltTrecho:=  oModelNFS:GetValue( 'GFEA044_GWU', 'GWU_NRCIDD') <>  TMS120CDUF(cA1_EstDes, "1") + cA1_CdMuDes
				EndIF
				If !lUltTrecho .And. !Empty(oModelNFS:GetValue( 'GFEA044_GW1', 'GW1_ENTCEP')) .And. !Empty(cA1_CEPDes)
					lUltTrecho:= oModelNFS:GetValue( 'GFEA044_GW1', 'GW1_ENTCEP') <> cA1_CEPDes
				EndIf
			EndIf
			//--- Dados do ultimo Trecho
			cTranspGWU:= oModelNFS:GetValue( 'GFEA044_GWU', 'GWU_CDTRP')  //Transportador do ultimo trecho
			cCepOGWU  := oModelNFS:GetValue( 'GFEA044_GWU', 'GWU_CEPD' )  //Cep destino do ultimo trecho
			cCdMunOGWU:= oModelNFS:GetValue( 'GFEA044_GWU', 'GWU_NRCIDD') //Municipio do ultimo trecho
			
			If lUltTrecho
				cSeq:= Soma1(cSeq)
				oModelTrechos:AddLine()
				oModelTrechos:GoLine(Val(AllTrim(cSeq)))

				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_SEQ'   , cSeq )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_EMISDC', cEmisDc )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_SERDC' , cSerNFC )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRDC'  , cNumNFC )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTRP' , cTranspGWU )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CEPO'  , cCepOGWU )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDO', cCdMunOGWU)
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', Iif(Empty(cGW1_EntNrc),rTrim(TMS120CdUf(cA1_EstDes, "1") + cA1_CdMuDes),cGW1_EntNrc) )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CEPD', Iif(Empty(cGW1_EntCep),cA1_CEPDes,cGW1_EntCep) )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_PAGAR' , "2" )
				If lViagem
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CHVEXT', 'VGMTMS;' + DUD->DUD_FILORI + ';' + DUD->DUD_VIAGEM )
				Else
					oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CHVEXT', 'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED )
				EndIf
			EndIf
		EndIf 
	EndIf

	nTrecho:= Val(AllTrim(cSeq))
EndIf

RestArea(aArea)
Return lRet

//---------------------------------------------------
/*/Intregração TMS - Redespachantes x Documentos
@author Katia
@version P11
@since 04/10/2013
//Função removida do fonte OMSM011 em Agosto/2018
/*/
//---------------------------------------------------
Function TMSFUNGTMS(cTipoInter,cNumRed,cCodFor,cLojFor,cProTable,cRotiProt,ArqvLog,nOpc)
	Local aAreaAtu	:= GetArea()
	Local aArea		:= {}
	Local cQuery	:= ""
	Local cQueryDFV	:= ""
	Local cAliasSA2	:= ""
	Local cAliasDFV	:= ""
	Local lRet 		:= .T.
	Local lCmpDFV		:= DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0

	Default cTipoInter := "TODOS"
	Default cNumRed := ""
	Default cCodFor := ""
	Default cLojFor := ""

	cAliasSA2 := GetNextAlias()
	cQuery := " SELECT A2_COD, A2_LOJA, A2_PAGGFE, A2_TRANSP "
	cQuery += " FROM " + RetSqlName('SA2') + " SA2 "
	cQuery += " WHERE SA2.A2_FILIAL  = '" + xFilial("SA2") + "'"
	cQuery += " AND SA2.A2_COD     = '" + DFT->DFT_CODFOR + "'"
	cQuery += " AND SA2.A2_LOJA    = '" + DFT->DFT_LOJFOR + "'"
	cQuery += " AND SA2.A2_PAGGFE  = '1' "
	cQuery += " AND SA2.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSA2, .F., .T.)

	If (cAliasSA2)->(!Eof())
	    //--- Verifica se todos os campos estao preenchidos da DFV
		cAliasDFV := GetNextAlias()
		cQueryDFV := " SELECT COUNT(*) QTDREG "
		cQueryDFV += " FROM " + RetSqlName('DFV') + " DFV "
		cQueryDFV += " WHERE DFV_FILIAL ='" + xFilial('DFV') + "' "
		If lCmpDFV
			cQueryDFV += "   AND DFV_FILORI ='" + DFT->DFT_FILORI + "' "
		EndIf
		cQueryDFV += "   AND DFV_NUMRED ='" + DFT->DFT_NUMRED + "' "
		cQueryDFV += "   AND DFV_CODFOR ='" + DFT->DFT_CODFOR + "' "
		cQueryDFV += "   AND DFV_LOJFOR ='" + DFT->DFT_LOJFOR + "' "
		cQueryDFV += "   AND DFV_STATUS ='" + StrZero( 2, Len( DFV->DFV_STATUS ) ) + "'"   //Indicado para Entrega
		cQueryDFV += "   AND (DFV_CDTPOP = '' "
		cQueryDFV += "   OR DFV_CDCLFR = '' "
		cQueryDFV += "   OR DFV_UFORI = '' "
		cQueryDFV += "   OR DFV_CDMUNO = '' "
		cQueryDFV += "   OR DFV_UFDES = '' "
		cQueryDFV += "   OR DFV_CDMUND = '') "
		cQueryDFV += "   AND DFV.D_E_L_E_T_ = ' ' "
		cQueryDFV := ChangeQuery( cQueryDFV )
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryDFV),cAliasDFV, .F., .T.)
		If (cAliasDFV)->QTDREG > 0
			lRet:= .F.
		EndIf
		(cAliasDFV)->( dbCloseArea() )

		If lRet
			aArea:= GetArea()
			If FindFunction( "GFEM011RED")
				lRet:= GFEM011RED(cTipoInter,,,,,,ArqvLog)
			EndIf
			RestArea(aArea)
		EndIf
	EndIf
	(cAliasSA2)->( dbCloseArea() )

	RestArea(aAreaAtu)
Return lRet

//---------------------------------------------------
/* Processa Viagens para integracao TMS x GFE
@author Katia
@version P12
@since 16/11/2016
//Função removida do fonte OMSM011 em Agosto/2018
/*/
//---------------------------------------------------
Function TMSFUNGVGE(cFilOri, cViagem, nOpc, ArqvLog,lRotGFE300)
Local aArea 	:= GetArea()
Local cQuery	:= ""
Local cAliasQry := ""
Local lRet      := .F.
Local cAliasNew := ""
Local cChvGFE   := ""
Local cChvDTQ   := ""
Local lAltVge   := .F.
Local cNewRom   := ""
Local lRetGWN   := .F.
Local cChvExt   := ""
Local cTpOpRom  := ""
Local aCalcRom  := {}
Local cNumRom   := ""
Local lCalcAut  := .T.
Local lTMSA340  := IsInCallStack("TMSA340Grv") .Or. IsInCallStack("TMSA340Mnt")
Local lContinua := .T.
Local cColGFE   := SuperGetMV( "MV_COLGFE" ,.F., "0" )  //0-Padrão, 1-Encerramento, 2-Nao Integra Coleta
Local lTabDM8   := AliasIndic("DM8")
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local lVgeAntiga := (Left(FunName(),7) == "TMSA140" .Or. Left(FunName(),7) == "TMSA141" .Or. ;
					 Left(FunName(),7) == "TMSA143" .Or. Left(FunName(),7) == "TMSA144")

Static aGW1		:= {} 
Static aGW8		:= {} 
Static aGWU		:= {} 
Static _cFilOri	:= ""
Static _cViagem	:= ""

Default nOpc       := 3
Default ArqvLog    := ""
Default lRotGFE300 := .F.

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

If _cFilOri + _cViagem <> cFilOri+cViagem
	_cFilOri	:= cFilOri
	_cViagem	:= cViagem
	aGW1		:= {} 
	aGW8		:= {} 
	aGWU		:= {} 
EndIf 

DTQ->( dbSetOrder(2) )
If DTQ->( dbSeek( xFilial("DTQ")+cFilOri+cViagem ) )
	lRet:= DTQ->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE))  //Sim

	If !lRet
		//Verifica se os Documentos da Viagem tem Redespacho informado
		cAliasNew := GetNextAlias()
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
	EndIf

	cChvGFE:= DTQ->DTQ_CHVEXT
	cChvDTQ:= DTQ->DTQ_CHVEXT

	lAltVge:= Iif(!Empty(cChvDTQ),.T.,.F.)

	If lAltVge
		//---- Uma vez integrado ao GFE, verifica se o Romaneio poderá ser aberto.
		cNumRom:= TmsRomGWN(cChvDTQ,'1')
		lRetGWN:= TmsChkGWN(,,,cNumRom,.T.,@aErrGFE)

	EndIf

EndIf

//--- DOCUMENTOS DE CARGA
If lRet

	cAliasQry := GetNextAlias()
	cQuery := " SELECT DUD.DUD_FILORI, DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DUD.DUD_CHVEXT, "
	cQuery += " DUD.DUD_CDCLFR, DUD.DUD_UFORI, DUD.DUD_CDMUNO, DUD.DUD_UFDES, DUD.DUD_CDMUND, DUD.DUD_CDTPOP, DUD.DUD_STATUS, DUD.R_E_C_N_O_ DUDRECNO "
	cQuery += " FROM " + RetSqlName('DUD') + " DUD "
	cQuery += " INNER JOIN " + RetSqlName('DTQ') + " DTQ "
	cQuery += " ON DTQ_FILIAL = '" + xFilial('DTQ') + "' "
	cQuery += "   AND	DTQ_FILORI = '" + cFilOri + "' "
	cQuery += "   AND	DTQ_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DTQ.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DUD_FILIAL = '" + xFilial('DUD') + "' "
	cQuery += "   AND	DUD_FILORI = '" + cFilOri + "' "
	cQuery += "   AND	DUD_VIAGEM = '" + cViagem + "' "
	If !lTMSA340 .And. cColGFE <> "1"  
		cQuery += "   AND DUD_STATUS <> '" + StrZero( 9, Len( DUD->DUD_STATUS ) ) + "'"   //Cancelado
	EndIf	
	//Se ja executado pela rotina do GFEX300 , busca apenas os que nao foram na primeira vez pois nao foram
    //incluidos via Inclusao no GFEX300, pois precisam ser via alteração para inclusao somente do trecho
    If lRotGFE300 
		cQuery += "   AND	DUD_CHVEXT = ' '  "
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
	cQuery += "   ORDER BY DUD.DUD_FILORI, DUD.DUD_VIAGEM, DUD.DUD_CDTPOP "
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
				If Empty((cAliasQry)->DUD_CHVEXT)
					//--- Verifica se o Documento já foi integrado ao SIGAGFE. Caso integrado, incluir apenas o Trecho ao Docto de Carga.
					cChvGFE:= TMSDocGFE((cAliasQry)->DUD_FILORI,(cAliasQry)->DUD_FILDOC,(cAliasQry)->DUD_DOC,(cAliasQry)->DUD_SERIE)
					If !Empty(cChvGFE)
						//--- Guarda o Romaneio para chamada do calculo do frete
						cNumRom:= TmsRomGWN(cChvGFE,'1')
						If lCalcAut .And. aScan(aCalcRom, cNumRom ) == 0
							aAdd(aCalcRom, cNumRom)
						EndIf
					EndIf

					If Empty(cChvGFE)

						//---- Verifica se existe um Romaneio com o mesmo Tipo de Operacao (DUD_CDTPOP) em aberto na viagem para inclusao dos novos documentos
						If lAltVge .And. !lRetGWN
							If Empty(cNewRom) //.Or. cTpOpRom <> (cAliasQry)->DUD_CDTPOP
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
						If (lAltVge .And. !lRetGWN .And. Empty(cNewRom)) .Or. Empty(cChvDTQ)
							cChvGFE:= ""
							lRet:= TMSFUNGDFT(nOpc,@cChvGFE,Iif(lAltVge,(cAliasQry)->DUD_CDTPOP,DTQ->DTQ_CDTPOP),Iif(lAltVge,'',DTQ->DTQ_CDCLFR),Iif(lAltVge,'',DTQ->DTQ_UFORI),Iif(lAltVge,'',DTQ->DTQ_CDMUNO),Iif(lAltVge,'',DTQ->DTQ_UFDES),;
								Iif(lAltVge,'',DTQ->DTQ_CDMUND), DTQ->(Recno()),Iif(lAltVge,'',DTQ->DTQ_CEPORI),Iif(lAltVge,'',DTQ->DTQ_CEPDES), @aCalcRom, lCalcAut )

							//---- Dados na viagem, so grava na primeira integração
							If lRet
								If !lAltVge
									Reclock("DTQ",.F.)
									DTQ->DTQ_CHVEXT:= cChvGFE
									DTQ->(MsUnlock())

									cChvDTQ:= cChvGFE
								Else
									cNewRom := cChvGFE
									cTpOpRom:= (cAliasQry)->DUD_CDTPOP
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
				Else
					cChvGFE:= (cAliasQry)->DUD_CHVEXT
				EndIf

				If !Empty(cChvGFE)
					DUD->(MsGoto( (cAliasQry)->DUDRECNO ))

					If Empty(DUD->DUD_CHVEXT)

						lRet:= .T.

						Reclock("DUD",.F.)
						DUD->DUD_CHVEXT:= cChvGFE
						If DTQ->DTQ_PAGGFE == StrZero(1, Len(DTQ->DTQ_PAGGFE) ) .And. Empty(DUD->DUD_NUMRED)  .And. DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS))
							//--- Os campos abaixo são atualizados na viagem de Transferencia, porem se ocorrer de estarem em branco, força a atualização
							If Empty(DUD->DUD_UFDES) .Or. Empty(DUD->DUD_CDMUND) .Or. Empty(DUD->DUD_CEPDES)
								Tmsa210DUD()
							EndIf
						EndIf
						DUD->(MsUnlock())

						//----- Viagem Modelo 3
						If lTabDM8
							TMSFUNGDM8(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DUD->DUD_FILORI,DUD->DUD_VIAGEM,cChvGFE)
							TMSFUNGDJN(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE,DUD->DUD_FILORI,DUD->DUD_VIAGEM,cChvGFE)
						EndIf

						//---- Viagem de Redespacho com parametro MV_TMSRDPU atualiza a chave externa
						If DTQ->DTQ_TIPVIA == StrZero(5,Len(DTQ->DTQ_TIPVIA)) .And. lTMSRDPU
							DFV->(DbSetOrder(2)) //DFV_FILIAL+DFV_FILDOC+DFV_DOC+DFV_SERIE+DFV_STATUS
							If DFV->(dBSeek(xFilial('DFV')+ DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE) ))
								Reclock("DFV",.F.)
								DFV->DFV_CHVEXT:= cChvGFE
								DFV->(MsUnlock())
							EndIf
						EndIf

						If DTQ->DTQ_PAGGFE == StrZero(1, Len(DTQ->DTQ_PAGGFE) ) .And. Empty(DUD->DUD_NUMRED)  .And. DUD->DUD_SERTMS == StrZero(2,Len(DUD->DUD_SERTMS))
							If Empty(DUD->DUD_UFDES) .Or. Empty(DUD->DUD_CDMUND)
								If Len(aErrGFE) == 0
									Aadd(aErrGFE,{STR0002})  //"Inconsistência com o Frete Embarcador (SIGAGFE): "
								EndIf
								Aadd(aErrGFE,{STR0003 + DUD->DUD_FILDOC + " " + DUD->DUD_DOC + " " + DUD->DUD_SERIE + " - " + STR0005})  //UF/Municipio de Destino não informado para a Filial de Descarga do Documento. "   })
								lRet:=.F.
							EndIf
						EndIf
						If lRet
							lRet:= TMSFUNGDFV(0, , .T., (cAliasQry)->DUDRECNO)
						EndIf
					EndIf
					//--- Na Alteração de um Viagem em Transito já integrada, se ocorrer erro na integração do novo docto vinculado a viagem,
					//--- será exibido o help informando o documento e continuar a integração dos demais documentos.
					//--- No caso do Fechamento, Apontamento da Operação nao permitir o processo se pelo menos 1 documento nao foi integrado.
					If !lRet .And. lAltVge
						Exit
					EndIf

				EndIf
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
	EndIf
	(cAliasQry)->( dbCloseArea() )

EndIf

If Len(aErrGFE) > 0
	TmsMsgErr(aErrGFE)
	lRet:= .F.
Else
	//---- Chamada do Calculo do Romaneio que houve alteração com a inclusao do novo trecho
	If Len(aCalcRom) > 0 .And. FindFunction('TMSCALROM')
		MsgRun( STR0006 , STR0007, {|| CursorWait(), lRet:= TMSCALROM(aCalcRom, @aErrGFE , .T.) , CursorArrow()})   //Aguarde... Recalculando o Romaneio
		If Len(aErrGFE) > 0
			TmsMsgErr(aErrGFE)
			lRet:= .T.   //Temporario apos definicao do calculo do GFE
		EndIf
	EndIf
EndIf

aSize(aCalcRom, 0)
aSize(aErrGFE,0)
aErrGFE:= {}
FwFreeArray(aFornece)
RestArea( aArea )
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} TMSFGTRRDA
Função que grava os Trechos dos Redespachos Adicionais
da Viagem (DTQ/DUD) e do Redespacho (DFT/DFV)
@author	Katia
@version	1.0
@since		13/12/2016
@sample    Esta função tem por objetivo gravar os trechos
			do Itinerario com base nos Redespachos da Viagem (DJN)
			e Redespachos Adicionais do Redespacho (DJO)
//Função removida do fonte OMSM011 em Agosto/2018			
/*/
//-------------------------------------------------------------------
Function TMSFGTRRDA(nOpc,oModelNFS,oModelTrechos,nTrecho,cSeq,lNumProp,cA1_CEPDes,cCdTpDc,lViagem,cEmisDc , cNumNFC , cSerNFC)
Local cAliasRDA := GetNextAlias()  //Redespacho Adicional
Local cQuery    := ""
Local cCepDes   := ""
Local cCgcTransp:= ""
Local lContinua := .F.
Local aForTrecho:= {}
Local cFornec   := ""
Local cLojFor   := ""
Local cTransp   := ""

Default nOpc          := 3
Default oModelNFS     := Nil
Default oModelTrechos := Nil
Default nTrecho       := 0
Default lNumProp      := .F.
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
		If Empty(cSeq)
			cSeq:= Soma1(cSeq)
		EndIf

		//--- Primeiro Trecho nao pago - Quando a viagem foi realizada por um TAC.
		If _lModel 
			oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPDC', cCdTpDc )
		EndIf 

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
			cCgcTransp:= TMSGBscCGC(cTransp,cFornec,cLojFor,lNumProp)
					
			If _lModel 
				If !oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTRP' , cCgcTransp )
					TmsSetErr(AllTrim(FwX3Titulo('GWU_CDTRP')) +  ": " + cTransp + ' : ' + 'Fornecedor: ' + cFornec + ' / ' + cLojFor, 'A2_TRANSP' ,oModelNFS) 
				EndIf

				//---- Destino do primeiro trecho do TAC considera a Origem do Primeiro Redespacho Adicional
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', TMS120CDUF((cAliasRDA)->UFORI, "1") + (cAliasRDA)->CDMUNO )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_UFD'   , (cAliasRDA)->UFORI )
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CEPD'  , (cAliasRDA)->CEPORI )

				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CHVEXT' , Iif(lViagem,'VGMTMS;'+ DUD->DUD_FILORI + ';' + DUD->DUD_VIAGEM,;
																			'RDPTMS;'+ DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED  ))

				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_PAGAR' , "2" )   //Nao
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_SEQ'   , cSeq )
			EndIf 

		EndIf
	EndIf

	//--- Inclusao do Trecho adicional do Redespacho da Viagem (DJN)
	cSeq:= Soma1(cSeq)
	If _lModel
		oModelTrechos:AddLine()
		oModelTrechos:GoLine(Val(AllTrim(cSeq)))
	EndIf
	nTrecho:= Val(AllTrim(cSeq))

	//--- Favorecido do Redespacho Adicional e não da Viagem
	aForTrecho:= TMSGBscFav(,,(cAliasRDA)->CODFOR,(cAliasRDA)->LOJFOR)
	If Len(aForTrecho) > 0			
		cFornec:= aForTrecho[1]
		cLojFor:= aForTrecho[2]
		cTransp:= aForTrecho[3]

		cCgcTransp:= TMSGBscCGC(cTransp,cFornec,cLojFor,lNumProp)
	EndIf

		
	If !Empty(GW1->GW1_ENTCEP)
		cCepDes:= GW1->GW1_ENTCEP
	Else
		cCepDes:= (cAliasRDA)->CEPDES
		If Empty(cCepDes)
			cCepDes:= cA1_CEPDes
		EndIf
	EndIf

	If _lModel
		If nTrecho > 1    //Mais de um TRecho
			oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "2" )		  //CIF COM REDESPACHO
		EndIf			
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDO', TMS120CDUF((cAliasRDA)->UFORI, "1") + (cAliasRDA)->CDMUNO )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_UFO'   , (cAliasRDA)->UFORI )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CEPO'  , (cAliasRDA)->CEPORI )				
		If !oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTRP' , cCgcTransp  )  
			TmsSetErr(AllTrim(FwX3Titulo('GWU_CDTRP')) +  ": " + cTransp + ' : ' + 'Fornecedor: ' + cFornec + ' / ' + cLojFor, 'A2_TRANSP' ,oModelNFS) 
		EndIf	
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', TMS120CDUF((cAliasRDA)->UFDES, "1") + (cAliasRDA)->CDMUND )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_UFD'   , (cAliasRDA)->UFDES )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CEPD'   , cCepDes )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_PAGAR'    , (cAliasRDA)->TPFRRD )  //1-Pagar, 2=Nao Pagar
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPVC'   , (cAliasRDA)->TIPVEI )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPOP'   , (cAliasRDA)->CDTPOP )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDCLFR'   , (cAliasRDA)->CDCLFR )
		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CHVEXT'   , Iif(lViagem,'VGMTMS;' + DUD->DUD_FILORI + ';' + DUD->DUD_VIAGEM,;
																		'RDPTMS;' + DFV->DFV_FILORI + ';' + DFV->DFV_NUMRED) )

		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_SEQ'   , cSeq )
	EndIf 
	
	(cAliasRDA)->(DbSkip())
EndDo
(cAliasRDA)->( dbCloseArea() )

Return Nil

//---------------------------------------------------
/*/{Protheus.doc} TMSFUNGGWE
Função que atualiza Relacionamento Documento de Carga GFE
e Documento de Transporte TMS
@author	Katia
@version	1.0
@since		14/12/2016
@sample    Esta função tem por objetivo gravar a tabela
			GWE
//Função removida do fonte OMSM011 em Agosto/2018			
/*/
//----------------------------------------------------

Function TMSFUNGGWE(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cNumRed)

Local cSeek		:= ""
Local aArea		:= GetArea()
Local lCmpGWE		:= GWE->(ColumnPos('GWE_CHVEXT')) > 0

Default cFilDoc	:= ""
Default cDoc		:= ""
Default cSerie	:= ""
Default cFilOri	:= ""
Default cViagem	:= ""
Default cNumRed   := ""

GWE->(dbSetOrder(1))
cSeek:= xFilial("GWE")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC+cFilDoc+cDoc+cSerie
If !GWE->(DbSeek(cSeek))
	RecLock("GWE", .T.)
	GWE->GWE_FILIAL:= xFilial("GWE")
	GWE->GWE_CDTPDC:= GW1->GW1_CDTPDC
	GWE->GWE_EMISDC:= GW1->GW1_EMISDC
	GWE->GWE_SERDC := GW1->GW1_SERDC
	GWE->GWE_NRDC  := GW1->GW1_NRDC
	GWE->GWE_FILDT := cFilDoc
	GWE->GWE_NRDT  := cDoc
	GWE->GWE_SERDT := cSerie
	If lCmpGWE
		If !Empty(cViagem)
			GWE->GWE_CHVEXT:= 'VGMTMS;'+cFilOri+';'+cViagem
		Else
			GWE->GWE_CHVEXT:= 'RDPTMS;'+ cFilOri+';'+cNumRed
		EndIf
	EndIf
	GWE->(MsUnlock())
EndIf

RestArea(aArea)
Return Nil
//-------------------------------------------------------------------------
/*/{Protheus.doc} TMSFUNGSOL (GFEM011SOL - OMSMM011.PRW)
Função que carrega as Notas de Cliente vinculada a SC
@author	Katia
@version	1.0
@since		06/03/2017
@sample    Esta função tem por objetivo pesquisar as
			Notas vinculadas a SC para atualizar a tabela no SIGAGFE - GXP
//Função removida do fonte OMSM011 em Agosto/2018
/*/
//-------------------------------------------------------------------------
Function TMSFUNGSOL(cFilOri,cNumSol,oMdGridGXP , cCdTpDc, cNRDoc, cSerDc ,cEmisDc)

Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()
Local cEmisDTC  := ""
Local lNumProp  := Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)

Default cFilOri   	:= ""
Default cNumSol   	:= ""
Default oMdGridGXP	:= Nil
Default cCdTpDc		:= ""
Default cNRDoc		:= ""
Default cSerDc		:= ""
Default cEmisDc		:= ""

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
		If FindFunction( "GFEM011COD")
			cEmisDTC:= GFEM011COD((cAliasQry)->DTC_CLIREM,(cAliasQry)->DTC_LOJREM,1,,)
		EndIf	
	Else
		cEmisDTC:= Posicione("SA1",1,xFilial("SA1")+(cAliasQry)->DTC_CLIREM+(cAliasQry)->DTC_LOJREM,"A1_CGC")
	EndIf
	
	If _lModel .And. oMdGridGXP <> Nil
		TMSFUNGGXP(oMdGridGXP,(cAliasQry)->DTC_NFEID,(cAliasQry)->DTC_FILORI,cEmisDTC,(cAliasQry)->DTC_SERNFC, (cAliasQry)->DTC_NUMNFC  , cCdTpDc, cNRDoc, cSerDc ,cEmisDc)
	EndIf 

	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->( DbCloseArea() )


RestArea(aArea)
Return Nil

//---------------------------------------------------
/*/{Protheus.doc} TMSFUNGGXP
Função que atualiza o Documento de Origem no SIGAGFE
@author	Katia
@version	1.0
@since		06/03/2017
@sample    Esta função tem por objetivo gravar a tabela
			GXP
//Função removida do fonte OMSM011 em Agosto/2018			
/*/
//----------------------------------------------------
Function TMSFUNGGXP(oMdGridGXP,cNfeId,cFilOri,cEmisDTC,cSerNfc,cNumNfc , cCdTpDc, cNRDoc, cSerDc ,cEmisDc)

Local nLinGXP:= 0
Local lRet   := .F.
Local aArea  := GetArea()
Local oModel := Nil

Default oMdGridGXP	:= Nil
Default cCdTpDc		:= ""
Default cNRDoc		:= ""
Default cSerDc		:= ""
Default cEmisDc		:= ""

If _lModel
	If oMdGridGXP == Nil
		oModel     := FWModelActive()
		oMdGridGXP := oModel:GetModel('GFEA044_GXP')
	EndIf

	If oMdGridGXP <> Nil
		nLinGXP:= oMdGridGXP:Length()
									       
		If oMdGridGXP:Length() > 1 	.Or. (oMdGridGXP:Length() == 1 .And. !Empty(oMdGridGXP:GetValue('GXP_DANFE')))
			nLinGXP := oMdGridGXP:AddLine()
		EndIf
		If nLinGXP > 0
			oMdGridGXP:GoLine( nLinGXP )
			oMdGridGXP:SetValue( 'GXP_DANFE' ,  cNfeId )
			oMdGridGXP:SetValue( 'GXP_FILORI', cFilOri )
			oMdGridGXP:SetValue( 'GXP_EMIORI', cEmisDTC )
			oMdGridGXP:SetValue( 'GXP_SERORI', cSerNfc )
			oMdGridGXP:SetValue( 'GXP_DOCORI', cNumNfc )
			lRet:= .T.
		EndIf
	EndIf
EndIf 

RestArea(aArea)
Return lRet

//---------------------------------------------------
/*/{Protheus.doc} TmsSetErr
Função que armazena os erros da aplicação
@author	Katia
@version	1.0
@since		04/08/2018
/*/
//----------------------------------------------------
Static Function TmsSetErr(cDados, cCampo, oModelErr)

Default cCampo   := ""
Default oModelErr:= Nil

If !Empty(oModelErr)
	If Len(aErrGFE) == 0
		Aadd(aErrGFE,{STR0002})  //"Inconsistência com o Frete Embarcador (SIGAGFE): "
	EndIf
	Aadd(aErrGFE, {cDados + " : " + oModelErr:GetErrorMessage()[6]+" "+oModelErr:GetErrorMessage()[4]+" ,  "+ cCampo })
EndIf	

Return Nil
/*/-----------------------------------------------------------
{Protheus.doc} TMSDocOco()
Retorna array do aItens para utilização via msexecauto no TMSA360

Uso: TMSA360

@author Felipe Barbiere
@since 23/10/2018
-----------------------------------------------------------/*/
Function TMSDocOco(cFilOri, cViagem, nAcao)
Local cQuery   := ""
Local cAliasQry:= ""
Local aItens   := {}
Local cOcorAut := SuperGetMV( 'MV_OCORAUT',.F., '' )
Local nSeqOco  := 1

Default cFilOri := ""
Default cViagem := ""
Default nAcao   := 0 //Nao estorna

If !Empty(cOcorAut) .And. !Empty(cFilOri) .And. !Empty(cViagem)
	cAliasQry := GetNextAlias()
	cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE, DT6_QTDVOL, DT6_PESO "
	If nAcao == 6 //-- Estornar
		cQuery += " , DUA_DATOCO, DUA_HOROCO, DUA_SEQOCO, DUA.R_E_C_N_O_ RECDUA "
	EndIf
	cQuery += " FROM " + RetSqlName("DUD") + " DUD "
	cQuery += " INNER JOIN " + RetSqlName("DT6") + " DT6"
	cQuery += "    ON DT6.DT6_FILDOC = DUD.DUD_FILDOC "
	cQuery += "   AND DT6.DT6_DOC = DUD.DUD_DOC "
	cQuery += "   AND DT6.DT6_SERIE = DUD.DUD_SERIE "
	If nAcao == 6 //-- Estornar
		//-- Documentos possuam apontamentos gerados pela ocorrencia automatica (DUA_ORIGEM = "TMSA350")
		cQuery += " JOIN " + RetSqlName("DUA") + " DUA "
		cQuery += "   ON DUA.DUA_FILIAL = '" + xFilial("DUA") + "'"
		cQuery += "  AND DUA.DUA_FILDOC = DUD.DUD_FILDOC "
		cQuery += "  AND DUA.DUA_DOC    = DUD.DUD_DOC "
		cQuery += "  AND DUA.DUA_SERIE  = DUD.DUD_SERIE "
		cQuery += "  AND DUA.DUA_FILORI = '" + cFilOri + "'"
		cQuery += "  AND DUA.DUA_VIAGEM = '" + cViagem + "'"
		cQuery += "  AND DUA.DUA_CODOCO = '" + cOcorAut + "'"
		cQuery += "  AND DUA.DUA_ORIGEM = 'TMSA350'"
		cQuery += "  AND DUA.D_E_L_E_T_ = ' '"
	EndIf
	cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
	cQuery += "   AND DUD.DUD_FILORI = '" + cFilOri + "'"
	cQuery += "   AND DUD.DUD_VIAGEM = '" + cViagem + "'"
	If nAcao == 3 //-- Apontar
		cQuery += "   AND DUD.DUD_STATUS NOT IN ('4','9') " //1-Aberto 2-Transito 3-Carregado 4-Encerrado 9-Cancelado
	EndIf
	cQuery += "   AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "

	If nAcao == 3 //-- Apontar
		//-- Apenas documentos que não possuam apontamentos com o mesmo código de ocorrência da ocorrência automática.
		cQuery += " AND NOT EXISTS( SELECT 1 FROM " + RetSqlName("DUA") + " DUA "
		cQuery += "                 WHERE DUA.DUA_FILIAL = '" + xFilial("DUA") + "'"
		cQuery += "                   AND DUA.DUA_FILDOC = DUD.DUD_FILDOC "
		cQuery += "                   AND DUA.DUA_DOC    = DUD.DUD_DOC "
		cQuery += "                   AND DUA.DUA_SERIE  = DUD.DUD_SERIE "
		cQuery += "                   AND DUA.DUA_FILORI = '" + cFilOri + "'"
		cQuery += "                   AND DUA.DUA_VIAGEM = '" + cViagem + "'"
		cQuery += "                   AND DUA.DUA_CODOCO = '" + cOcorAut + "'"
		cQuery += "                   AND DUA.D_E_L_E_T_ = ' '"
		cQuery += "               ) "
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	TcSetField(cAliasQry,"DUA_DATOCO", "D", 8, 0)

	While (cAliasQry)->(!Eof())
		//--Itens da ocorrencia
		aAdd( aItens, {	;
			 {"DUA_SEQOCO", Iif(nAcao == 6, (cAliasQry)->DUA_SEQOCO, StrZero(nSeqOco,Len(DUA->DUA_SEQOCO))) , NIL},; 
	         {"DUA_DATOCO", Iif(nAcao == 6, (cAliasQry)->DUA_DATOCO, dDataBase)								, NIL},;                  
	         {"DUA_HOROCO", Iif(nAcao == 6, (cAliasQry)->DUA_HOROCO, StrTran(SubStr(Time(),1,5),":",""))	, NIL},;      
	         {"DUA_ESTOCO", Iif(nAcao == 6, "1", "2")            ,NIL},;            
	         {"DUA_CODOCO", cOcorAut,                             NIL},;                  
	         {"DUA_FILDOC", (cAliasQry)->DUD_FILDOC,              NIL},;                  
	         {"DUA_DOC"   , (cAliasQry)->DUD_DOC,                 NIL},;                  
	         {"DUA_SERIE" , (cAliasQry)->DUD_SERIE,               NIL},;                  
	         {"DUA_QTDOCO", (cAliasQry)->DT6_QTDVOL,              NIL},;                          
	         {"DUA_PESOCO", (cAliasQry)->DT6_PESO,                NIL},;			                  
	         {"DUA_ORIGEM", "TMSA350",				              NIL},;			                  
	         {"DUA_FILVTR", ""	,                                 NIL},;                  
	         {"DUA_NUMVTR", ""	,                                 NIL}})	

		//-- Se for estorno, posiciona a tabela DUA no primeiro registro a ser estornado
		If nAcao == 6 .And. nSeqOco == 1
			DUA->(DbGoto((cAliasQry)->RECDUA))
		EndIf
		
	   	(cAliasQry)->(DbSkip())
	   	nSeqOco++
	EndDo
	(cAliasQry)->( dbCloseArea() )
EndIf
	
Return aItens

//--------------------------------------------------------
/*/Ocorrencias TMS - Apontamento automatico de ocorrencia
@author Fabio Marchiori Sampaio
@version P12
@since   24/10/2018
@sample  Esta função tem por objetivo selecionar a última
atividade da viagem, e com status finalizado
/*/
//--------------------------------------------------------

Function TMSOcoAut(cFilOri, cViagem, nOpcx)

Local cAtvChg	:= SuperGetMV('MV_ATIVCHG',,'') //-- Atividade de Chegada de Viagem
Local cAtChCli  := SuperGetMV('MV_ATVCHGC',,'') //-- Atividade de Chegada de Viagem Cliente

Local cOcorAut 	:= SuperGetMV('MV_OCORAUT',.F., '' )
Local cQuery	:= ""
Local aItensOco	:= {}
Local aCabOco   := {}
Local nOpcao   := 0

Default cFilOri  := '' 
Default cViagem  := '' 
Default nOpcx    := 3

nOpcao := nOpcx
//Estorno de Ocorrencia no TMSA360 é opção 4
If nOpcx == 5 
	nOpcao := 6
EndIf

If !Empty(cOcorAut)
	cAliasNew := GetNextAlias()
	cQuery += " SELECT DTW_FILORI, DTW_VIAGEM, DTW_STATUS "
	cQuery += "  FROM " + RetSqlName("DTW")
	cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
	cQuery += "   AND DTW_FILORI = '" + cFilOri + "' "
	cQuery += "   AND DTW_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND (DTW_ATIVID = '" + cAtvChg +"' "
	cQuery += "  OR DTW_ATIVID = '" + cAtChCli +"') "
	If nOpcx == 3
		cQuery += " AND DTW_STATUS = '" + StrZero(2,Len(DTW->DTW_STATUS)) + "' "
	Else
		cQuery += " AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' ' "		
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
	
	If (cAliasNew)->(!Eof())
		Aadd(aCabOco,{"DUA_FILORI",cFilOri,Nil})
		Aadd(aCabOco,{"DUA_VIAGEM",cViagem,Nil})
		Aadd(aCabOco,{"DUA_FILOCO",cFilOri,Nil})
		aItensOco:= TMSDocOco((cAliasNew)->(DTW_FILORI), (cAliasNew)->(DTW_VIAGEM), nOpcao)
		If !Empty(aCabOco) .And. !Empty(aItensOco)
			ProcIteOco(aCabOco, aItensOco, {}, nOpcao, .F.)
		EndIf
	EndIf
	(cAliasNew)->( DbCloseArea() )
EndIf

Return()

//--------------------------------------------------------
/*/Ocorrencias TMS - Apontamento automatico de ocorrencia
@author Fabio Marchiori Sampaio
@version P12
@since   24/10/2018
@sample  Esta função tem por objetivo selecionar a última
atividade da viagem, e com status finalizado
/*/
//--------------------------------------------------------

Function ProcIteOco(aCabOco, aItensOco, aNFPend, nOpcx, lMostra, l360Ajusta)
Local  aArea        := GetArea()
Local  lRet         := .T.

Private lMSErroAuto := .F. 

Default aCabOco     := {}
Default aItensOco   := {}
Default aNFPend     := {}
Default nOpcx       := 3
Default lMostra     := .T.
Default l360Ajusta  := .F.  //Exibe somente o Erro no processo de Estorno na opção AJUSTA

MsAguarde({|| MsExecAuto({|x,y,w,z| TMSA360(x,y,w,z)},aCabOco,aItensOco,aNFPend,nOpcx)}, 'AGUARDE, PROCESSANDO...' )

If lMostra
	If lMSErroAuto    
		lRet:= .F.
		MostraErro()
	Else  
		MsgInfo(STR0009,STR0001)	//-- "Concluído com Sucesso !!!" ### "Atenção"	
	EndIf
Else
	If lMSErroAuto
		lRet:= .F.
		If l360Ajusta
			MostraErro()
		EndIf
	EndIf	
EndIf

RestArea(aArea)
Return lRet

//--------------------------------------------------------
/*/Verifica se o(s) documento(s) possue(m) alguma ocorrencia apontada.
@author Alexandre Yukio Arume
@version P12
@since   22/01/2019
@sample  
/*/
//--------------------------------------------------------
Function TMSDocOcor(aDocsDUA, cFilOri, cViagem)

	Local lRet 			:= .T.
	Local aAreaDUA		:= {}
	Local nI			:= 0
	Local cDocs			:= ""

	Default aDocsDUA	:= {}
	Default cFilOri		:= ""
	Default cViagem		:= ""

	aAreaDUA := DUA->(GetArea())
	DUA->(dbSetOrder(4)) //DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_FILORI+DUA_VIAGEM
	For nI := 1 To Len(aDocsDUA)
		If DUA->(dbSeek(xFilial("DUA") + aDocsDUA[nI][1] + aDocsDUA[nI][2] + aDocsDUA[nI][3] + cFilOri + cViagem))
			cDocs += aDocsDUA[nI][1] + aDocsDUA[nI][2] + " " + aDocsDUA[nI][3] + ", "
		EndIf
	Next
	
	If !Empty(cDocs)
		Help("", 1, "TMSXFUNG01", , Left(cDocs, Len(cDocs)-2) + ".", 2, 1) //Não é possível executar esta operação pois existe uma ocorrencia apontada para o(s) documento(s) .
		lRet := .F.
	EndIf
	RestArea(aAreaDUA)

Return lRet


//--------------------------------------------------------
/*/Retorna a ultima ocorrencia apontada para o Documento
@author Katia
@version P12
@since   22/11/2019
@sample  
/*/
//--------------------------------------------------------
Function TMSUltOcor(cFilOri,cViagem,cFilDoc,cDoc,cSerie,cTipOco)
Local nRecDUA   := 0
Local cQuery    := ""
Local cAliasDUA := ""
Local aArea     := GetArea()

Default cFilOri := ""
Default cViagem := ""
Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""
Default cTipOco := ""

cAliasDUA := GetNextAlias()
cQuery := " SELECT MAX(DUA.R_E_C_N_O_) RECNO " 
cQuery += "  FROM " + RetSqlName("DUA") + " DUA "
cQuery += "    INNER JOIN " + RetSqlName("DT2") + " DT2 "
cQuery += "    ON DT2.DT2_FILIAL = '" + xFilial("DT2") + "' "
cQuery += "    AND DT2.DT2_CODOCO = DUA.DUA_CODOCO "
cQuery += "    AND DT2.D_E_L_E_T_ = ' ' "
cQuery += "    WHERE DUA.DUA_FILIAL = '" + xFilial("DUA") + "' "
If !Empty(cFilOri) .And. !Empty(cViagem)
	cQuery += "  AND DUA.DUA_FILORI = '" + cFilOri + "' "
	cQuery += "  AND DUA.DUA_VIAGEM = '" + cViagem + "' "
EndIf 	
cQuery += "   AND DUA.DUA_FILDOC = '" + cFilDoc + "' "
cQuery += "   AND DUA.DUA_DOC 	= '" + cDoc + "' "
cQuery += "   AND DUA.DUA_SERIE = '" + cSerie + "' "
If !Empty(cTipOco)
	cQuery += "  AND DT2.DT2_TIPOCO = '" + cTipOco + "' " 
Else	
	cQuery += "  AND DT2.DT2_TIPOCO IN ('01','04') " //01-Encerra Processo ou 04-Retorna Documento
EndIf	

cQuery += "   AND DUA.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDUA, .F., .T.)
If (cAliasDUA)->(!Eof()) 
	nRecDUA:= (cAliasDUA)->RECNO
EndIf
(cAliasDUA)->(DbCloseArea())

RestArea( aArea )
Return nRecDUA

//-----------------------------------------------------------------
/*/Atualiza dados da Tabela DM8 - Trecho do Documento Viagem Mod.3
@author Katia
@version 12.1.30
@since   11/08/2020
@sample  
/*/
//-----------------------------------------------------------------
Function TMSFUNGDM8(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cChvGFE)
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

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSVDCGFE()
Visualiza Documento de Carga do GFE
@type Function
@author Katia
@since 11/08/2020
@version 12.1.30
@param cFilDoc, cDoc, cSerie
@return Nil
Função extraída do fonte TMSA144 (TM144DcGFE)
/*/
//-------------------------------------------------------------------
Function TMSVDCGFE(oModel)
Local aAreas    := {DT6->(GetArea()),DT5->(GetArea()),GetArea()}
Local aSaveLine := FWSaveRows()

Default oModel  := FWModelActive()

DT6->(DbSetOrder(1))
If DT6->(dbSeek(xFilial("DT6")+ FwFldGet("DM3_FILDOC") + FwFldGet("DM3_DOC") + FwFldGet("DM3_SERIE") ))
	If	DT6->DT6_SERTMS == StrZero( 1, Len( DT6->DT6_SERTMS ) )
		//-- Posiciona na solicitacao de coleta.
		DT5->( DbSetOrder( 4 ) )
		If	DT5->( MsSeek( xFilial('DT5') + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE, .F. ) )
			TMSViewGFE('DT5')
		EndIf
	Else
		If !Empty(DT6->DT6_DOCDCO)
			TMSDocXNf(DT6->DT6_FILDCO,DT6->DT6_DOCDCO,DT6->DT6_SERDCO,,,.F.)
		Else
			TMSDocXNf(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,,,.F.)
		EndIf
	EndIf
EndIf

FwRestRows( aSaveLine )
AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
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
Function TMSFUNGDJN(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cChvGFE)
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
/*/Busca dados do Fornecedor considerando o Favorecido
@author Katia
@version 12.1.33
@since   12/08/2021
@sample  
/*/
//-----------------------------------------------------------------
Function TMSGBscFav(cFilOri,cViagem,cCodFor,cLojFor)
Local aCodFav := {}
Local cTransp := ""
Local aRet    := {}   //A2_COD,A2_LOJA,A2_TRANSP
Local cFornece:= ""
Local cLoja   := ""
Local cCodVei := ""

Default cFilOri:= ""
Default cViagem:= ""
Default cCodFor:= ""
Default cLojFor:= ""

If Empty(cFilOri) .And. Empty(cViagem)  //Redespacho Adicional, fornecedor do DJA/DJN
	cFornece:= cCodFor
	cLoja   := cLojFor
Else
	DTR->(dbSetOrder(3))
	If DTR->(dbSeek(xFilial('DTR')+cFilOri+cViagem))
		cFornece:= DTR->DTR_CODFOR
		cLoja   := DTR->DTR_LOJFOR
		cCodVei := DTR->DTR_CODVEI
	EndIf
EndIf

aCodFav := T250BscFav(cCodVei,cFornece,cLojFor,cFilOri,cViagem)	// retorna o codigo do Favorecido
If Len(aCodFav) > 0
	cFornece:= aCodFav[1][1]
	cLoja   := aCodFav[1][2]
EndIf

If !Empty(cFornece)
	cTransp:= Posicione("SA2",1,xFilial('SA2')+cFornece+cLoja,"A2_TRANSP")

	Aadd(aRet, cFornece)
	Aadd(aRet, cLoja)
	Aadd(aRet, cTransp)
EndIf
	
FwFreeArray(aCodFav)
Return aRet


//-----------------------------------------------------------------
/*/Busca dados do Motorista
@author Katia
@version 12.1.33
@since   12/08/2021
@sample  
/*/
//-----------------------------------------------------------------
Function TMSGBscMot(cFilOri,cViagem)
Local cCodMot:= ""

DUP->(dbSetOrder(2)) //DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_CODMOT
If DUP->(MsSeek(xFilial('DUP') + cFilOri + cViagem ))
	cCodMot:= DUP->DUP_CODMOT
EndIf

Return cCodMot


//-----------------------------------------------------------------
/*/Busca CGC do Transportador
@author Katia
@version 12.1.33
@since   12/08/2021
@sample  
/*/
//-----------------------------------------------------------------
Function TMSGBscCGC(cTransp,cFornec,cLojFor,lNumProp)
Local cCgcTransp:= ""

Default cTransp:= ""
Default cFornec:= ""
Default cLojFor:= ""
Default lNumProp:= .F.

If Empty(cTransp)
	SA2->( dbSetOrder(1) )
	If SA2->( dbSeek( xFilial("SA2")+cFornec+cLojFor ))
		If !lNumProp
			cCgcTransp := IIF(SA2->A2_TIPO <> 'X',SA2->A2_CGC,AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA) )
		Else
			If FindFunction( "GFEM011COD")
				cCgcTransp := GFEM011COD(SA2->A2_COD,SA2->A2_LOJA,2,,)
			EndIf	
		EndIf
	EndIf
Else
	If lNumProp
		cCgcTransp := Posicione("GU3",13,xFilial("GU3")+cTransp,"GU3_CDEMIT")
	Else
		cCgcTransp := Posicione("SA4",1,xFilial("SA4")+cTransp,"A4_CGC")
	EndIf
EndIf
Return cCgcTransp


/*{Protheus.doc} TMSGBscTra
Funçao que retorna o Transportador da Viagem
@type Static Function
@author Katia
@since 13/08/2021
@version 12.1.33
Utilizado no TMSA360
*/
Function TMSGBscTra(cCodFor,cLojFor,cFilOri,cViagem,lNumProp)
Local cCgcTransp:= ""
Local aFornece  := {}
Local cFornece  := ""
Local cLoja     := ""
Local cTransp   := ""

Default cCodFor:= ""
Default cLojFor:= ""
Default cFilOri:= ""
Default cViagem:= ""
Default lNumProp:= Iif(FindFunction("GFEEMITMP"),GFEEMITMP(),.F.)

	If Empty(cCodFor) .And. Empty(cLojFor)
		aFornece:= TMSGBscFav(cFilOri,cViagem,cCodFor,cLojFor) //Verifica o Fornecedor da Viagem se tem favorecido (DTR)
	Else
		aFornece:= TMSGBscFav(,,cCodFor,cLojFor)   //Verifca se o Fornecedor tem favorecido 
	EndIf
	If Len(aFornece) > 0			
		cFornece:= aFornece[1]
		cLoja   := aFornece[2]
		cTransp := aFornece[3]
	EndIf

	cCgcTransp:= TMSGBscCGC(cTransp,cFornece,cLoja,lNumProp)				

Return cCgcTransp
