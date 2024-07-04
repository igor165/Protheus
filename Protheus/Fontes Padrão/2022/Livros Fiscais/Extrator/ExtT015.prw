#Include "Protheus.ch" 
#Include "RwMake.ch"

Static oFisaExtSx := FisaExtX02()

/*/{Protheus.doc} RegT015
Realiza a geracao do registro T015 do TAF

@author Rodrigo Aguilar
@since  19/04/2013

@Param nHdlTxt, numerico, Handle de Geracao do Arquivo
@Param aRegT015, array, Array com as informacoes para geracao do registro T015
@Param aRegT015AB, array, Array com as informacoes para geracao do registro T015AB
@Param aRegT015AC, array, Array com as informacoes para geracao do registro T015AC
@Param aRegT015AD, array, Array com as informacoes para geracao do registro T015AD
@Param aRegT015AF, array, Array com as informacoes para geracao do registro T015AF
@Param aRegT015AG, array, Array com as informacoes para geracao do registro T015AG
@Param aRegT015AH, array, Array com as informacoes para geracao do registro T015AH
@Param aRegT015AI, array, Array com as informacoes para geracao do registro T015AI

@Return Nulo, não tem retorno.

@obs Função refeita. - Vitor Ribeiro - 22/01/2018
/*/
Function RegT015(nHdlTxt,aRegT015,aRegT015AB,aRegT015AC,aRegT015AD,aRegT015AE,aRegT015AF,aRegT015AG,aRegT015AH,aRegT015AI,aRegT015AK)

	Local nCount1 := 0
	Local nCount2 := 0
	Local nPosicao := 0

	Local bAscan := {}

	For nCount1 := 1 To Len(aRegT015)

		FConcTxt(aRegT015[nCount1],nHdlTxt)

		bAscan := {|x| x[1] == nCount1 }

		nPosicao := Ascan(aRegT015AB,bAscan)

		If !Empty(nPosicao)
			FConcTxt(aRegT015AB[nPosicao][2],nHdlTxt)
		EndIf

		nPosicao := Ascan(aRegT015AC,bAscan)

		If !Empty(nPosicao)
			FConcTxt(aRegT015AC[nPosicao][2],nHdlTxt)
		EndIf

		nPosicao := Ascan(aRegT015AD,bAscan)

		If !Empty(nPosicao)
			FConcTxt(aRegT015AD[nPosicao][2],nHdlTxt)
		EndIf

		nPosicao := Ascan(aRegT015AE,bAscan)

		If !Empty(nPosicao)
			For nCount2 := nPosicao To Len(aRegT015AE)
				If aRegT015AE[nCount2][1] == nCount1
					FConcTxt(aRegT015AE[nCount2][2],nHdlTxt)
				EndIf
			Next
		EndIf

		nPosicao := Ascan(aRegT015AF,bAscan)

		If !Empty(nPosicao)
			FConcTxt(aRegT015AF[nPosicao][2],nHdlTxt)
		EndIf

		nPosicao := Ascan(aRegT015AG,bAscan)

		If !Empty(nPosicao)
			FConcTxt(aRegT015AG[nPosicao][2],nHdlTxt)
		EndIf

		nPosicao := Ascan(aRegT015AH,bAscan)

		If !Empty(nPosicao)
			FConcTxt(aRegT015AH[nPosicao][2],nHdlTxt)
		EndIf

		nPosicao := Ascan(aRegT015AI,bAscan)

		If !Empty(nPosicao)
			FConcTxt(aRegT015AI[nPosicao][2],nHdlTxt)
		EndIf

		nPosicao := Ascan(aRegT015AK,bAscan)

		If !Empty(nPosicao)
			For nCount2 := nPosicao To Len(aRegT015AK)
				If aRegT015AK[nCount2][1] == nCount1
					FConcTxt(aRegT015AK[nCount2][2],nHdlTxt)
				EndIf
			Next
		EndIf

	Next

Return Nil

/*/{Protheus.doc} FGrvItemNF
Realiza a gravacao de conteudo do registro T015 do TAF

@author Rodrigo Aguilar
@since  19/04/2013

@Param aPartDoc   -> Dados do Participante da Nota Fiscal
@Param cEntSai    -> Variavel que indica o tipo de movimento ( E/S )
@Param lAchouCD7  -> Indica se existe regitro CD7 para a Nota Fiscal
@Param lAchouCD8  -> Indica se existe regitro CD8 para a Nota Fiscal
@Param lAchouCD9  -> Indica se existe regitro CD9 para a Nota Fiscal
@Param lAchouCDG  -> Indica se existe regitro CCF para a Nota Fiscal
@Param lAchouSFU  -> Indica se existe regitro SFU para a Nota Fiscal
@Param lAchouCD0  -> Indica se existe regitro CD0 para a Nota Fiscal
@Param lAchouCD6  -> Indica se existe regitro CD6 para a Nota Fiscal
@Param lAchouSFX  -> Indica se existe regitro SFX para a Nota Fiscal
@Param lAchouDT6  -> Indica se existe regitro DT6 para a Nota Fiscal
@Param lAchouDA3  -> Indica se existe regitro DA3 para a Nota Fiscal
@Param cEspecie   -> Indica a Especie da NF
@Param aRegT015   -> Array com Informacoes dos Itens da Nota Fiscal
@Param aRegT015AB -> Array com Informacoes dos complementos dos Itens da Nota Fiscal
@Param aRegT015AC -> Array com Informacoes dos complementos dos Itens da Nota Fiscal
@Param aRegT015AD -> Array com Informacoes dos complementos dos Itens da Nota Fiscal
@Param aRegT015AF -> Array com Informacoes dos complementos dos Itens da Nota Fiscal
@Param aRegT015AG -> Array com Informacoes dos complementos dos Itens da Nota Fiscal
@Param aRegT015AH -> Array com Informacoes dos complementos dos Itens da Nota Fiscal
@Param aRegT015AI -> Array com Informacoes dos complementos dos Itens da Nota Fiscal
@Param cTipoDoc   -> Variavel que indica o tipo do documento fiscal

aRegs     -> Array para gravacao do registro T015

@Return Nulo, não tem retorno.
/*/
Function FGrvItemNF(aPartDoc,cEntSai,lAchouCD7,lAchouCD8,lAchouCD9,lAchouCDG,lAchouSFU,lAchouCD0,lAchouCD6,lAchouSFX,lAchouDT6,lAchouDA3,lAchouSB5,cEspecie,;
					aRegT015,aRegT015AB,aRegT015AC,aRegT015AD,aRegT015AF,aRegT015AG,aRegT015AH,aRegT015AI,cTipoDoc,cD2_Re,aRegT015AK,cApurIpi,lINDISEN, oHashTMSM, lHashTMS,aTamQtd)

	Local cCodClas := ""
	Local cIndRec := ""
	Local cCodEstOrg := ""
	Local cCodMunOrg := ""
	Local cCodEstDes := ""
	Local cCodMunDes := ""
	Local cCodSrvMun := ""
	Local cCodVei := ""
	Local cRE := ""
	Local cCfop := ""
	Local cCodIss := ""
	Local cTpServ := ""
	Local cProdCDN := ""
	Local cOrigCred := ""
	Local cCodTrib := ""
	Local cTpRepasse := ""
	Local cDipam := ""
	Local nTamItem   := TamSX3( "D1_ITEM" )[1]
	Local aTamVlrIte  := TamSX3( "FT_PRCUNIT" )


	Local nPauta := 0
	Local nConskwh := 0
	Local nItmT015 := 0
	Local nPosicao := 0

	Local lSpedNat := .F.
	Local lAchouCD1 := .F.

	Local aPartT015AG := {}
	Local aNatOper := {}
	Local aRet:={}
	Local cKey := ""
	

	Default aPartDoc := {}
	Default aRegT015 := {}
	Default aRegT015AB := {}
	Default aRegT015AC := {}
	Default aRegT015AD := {}
	Default aRegT015AF := {}
	Default aRegT015AG := {}
	Default aRegT015AH := {}
	Default aRegT015AI := {}
	Default aRegT015AK := {}

	Default cEntSai  := ""
	Default cEspecie := ""
	Default cTipoDoc := ""
	Default cD2_Re   := ""
	Default cApurIpi := "0"

	Default lAchouCD7 := .F.
	Default lAchouCD8 := .F.
	Default lAchouCD9 := .F.
	Default lAchouCDG := .F.
	Default lAchouSFU := .F.
	Default lAchouCD0 := .F.
	Default lAchouCD6 := .F.
	Default lAchouSFX := .F.
	Default lAchouDT6 := .F.
	Default lAchouDA3 := .F.
	Default lAchouSB5 := .F.
	Default lINDISEN  := .F.
	Default lHashTMS  := .F.


	If cEntSai == "S"
		If !Empty(cD2_Re)
			cRE := SD2->(&(cD2_Re))
		Else
			DbSelectArea("EE9")
			EE9->(DbSetOrder(2))
			If EE9->(DbSeek(xFilial("EE9")+SD2->D2_PREEMB))
				cRE := EE9->EE9_PREEMB
			Endif
		Endif
	EndIf

	// Cadastro dos Itens do Documento Fiscal
	If SubStr(SFT->FT_CFOP,1,1) == "3"
		cOrigCred := "1"
	Else
		cOrigCred := "0"
	EndIf

	If SFT->FT_PAUTIPI > 0
		nPauta := SFT->FT_PAUTIPI
	ElseIf !Empty(SB1->B1_TAB_IPI) .And. SB1->B1_VLR_IPI>0
		nPauta := SB1->B1_VLR_IPI
	EndIf

	cSomaItem := Soma1(cSomaItem)

	DbSelectArea("CD1")
	CD1->(DbSetOrder(1))

	IF oFisaExtSx:_DHR
		DbSelectArea("DHR")    
		DHR->(DbSetOrder(1))
	EndIF

	If cEntSai == "E"
		If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))
			If !Empty(SF4->F4_NATOPER)
				If CD1->(MsSeek(xFilial("CD1")+SF4->F4_NATOPER))
					lAchouCD1 := .T.
				EndIf
			EndIf
		EndIf
	Else
		If SF4->(MsSeek(xFilial("SF4") + SD2->D2_TES))
			If !Empty(SF4->F4_NATOPER)
				If CD1->(MsSeek(xFilial("CD1")+SF4->F4_NATOPER))
					lAchouCD1 := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	//Buscando a natureza da operação
	lSpedNat := GetNewPar("MV_SPEDNAT",.F.)
	aNatOper := SpedNatOper(lAchouCD1,lSpedNat,"SFT","SF4",.T.)

	//Quando utilizar CFOP antigo por ser nota de serviço, converto o CFOP para 5933
	if Len(AllTrim(SFT->FT_CFOP)) <= 3 .And. !Empty(cEntSai)
		If cEntSai == "S"
			cCfop := '5933' //CFOP de Serviço
		Else
			cCfop := '1933' //CFOP de Serviço
		EndIf
	else
		cCfop := SFT->FT_CFOP
	endif

	/*
		Obtendo o codigo do ISS atraves do cadastro da tabela CDN. Este codigo deverah estar conforme LC 116/03
		Tratamento para considerar também mais de um Cod LST por Cod ISS, conforme a legislação existe a possibilidade de ser n / n
	*/
	cCodSrvMun := AllTrim(SFT->FT_CODISS)
	cProdCDN := Alltrim(SB1->B1_COD)
	cCodIss := SFT->FT_CODISS


	//Priorizo o tipo de serviço da reinf que esta no cadastro do produto.
	if F2Q->(MsSeek(xFilial('F2Q')+cProdCDN ))
		cTpServ := iif(oFisaExtSx:_F2Q_TPSERV,F2Q->F2Q_TPSERV,'')
	endif

	If CDN->(MsSeek(xFilial("CDN") + cCodIss + cProdCDN)) .Or. CDN->(MsSeek(xFilial("CDN") + cCodIss))
		cCodIss := AllTrim(CDN->CDN_CODLST)
		if empty(cTpServ)
			cTpServ := IIF(oFisaExtSx:_CDN_TPSERV,CDN->CDN_TPSERV,"")
		endif
	Else
		cCodIss := ""
	EndIf

	// Tiro todos os pontos que estiverem no cadastro.
	cCodIss := StrTran(cCodIss,".","")

	If SFT->FT_TIPOMOV =='E' .And. oFisaExtSx:_D1_TPREPAS
		cTpRepasse := SD1->D1_TPREPAS
	ElseIf SFT->FT_TIPOMOV =='S' .And. oFisaExtSx:_D2_TPREPAS
		cTpRepasse := SD2->D2_TPREPAS
	EndIf

	If !Empty( oFisaExtSx:_MV_ESTADO ) .and. ( oFisaExtSx:_MV_ESTADO $ oFisaExtSx:_MV_UFIPM )
		cDipam := Alltrim( Posicione( "F09", 1, xFilial( "F09" ) + SFT->FT_TES + oFisaExtSx:_MV_ESTADO, "F09_CODIPM" ) )
	EndIf

	// T015-ITENS DOS DOCUMENTOS FISCAIS
	Aadd(aRegT015,{{}})
	nItmT015 := Len(aRegT015)

	if IsBlind() //tratamento job
		If cValToChar(cApurIpi) == "1" //1°opcao 0-Mensal
			cApurIpi := "0" // 0-Mensal
		ElseIf cValToChar(cApurIpi) == "2" //2°opcao N-Decendial
			cApurIpi := "1" // 1-Decendial
		EndIf
	endif

	Aadd(aRegT015[nItmT015][1],"T015")											// 01 - REGISTRO
	Aadd(aRegT015[nItmT015][1],StrZero(Val(cSomaItem),nTamItem))				// 02 - NUM_ITEM
	Aadd(aRegT015[nItmT015][1],SFT->FT_PRODUTO)									// 03 - COD_ITEM
	Aadd(aRegT015[nItmT015][1],IIf(lAchouSB5,SB5->B5_CEME,""))					// 04 - DESCR_COMPL
	Aadd(aRegT015[nItmT015][1],Val2Str(SFT->FT_TOTAL,16,2))						// 05 - VL_TOT_ITEM
	Aadd(aRegT015[nItmT015][1],Val2Str(SFT->FT_DESCONT,16,2))					// 06 - VL_DESC
	Aadd(aRegT015[nItmT015][1],SFT->FT_CODBCC)									// 07 - NAT_BC_CRED
	Aadd(aRegT015[nItmT015][1],cOrigCred)										// 08 - IND_ORIG_CRED
	Aadd(aRegT015[nItmT015][1],SFT->FT_CONTA)									// 09 - COD_CTA
	Aadd(aRegT015[nItmT015][1],IIf(cEntSai == "E",SD1->D1_CC,SD2->D2_CCUSTO))	// 10 - COD_CCUS
	Aadd(aRegT015[nItmT015][1],Val2Str(SFT->FT_QUANT,aTamQtd[1],aTamQtd[2]))	// 11 - QTD
	Aadd(aRegT015[nItmT015][1],SB1->B1_UM)										// 12 - UNID
	Aadd(aRegT015[nItmT015][1],cCfop)											// 13 - CFOP
	Aadd(aRegT015[nItmT015][1],aNatOper[1])										// 14 - COD_NAT
	Aadd(aRegT015[nItmT015][1],cApurIpi)										// 15 - IND_APUR
	Aadd(aRegT015[nItmT015][1],TabIpi(SB1->B1_TAB_IPI))							// 16 - CL_ENQ
	Aadd(aRegT015[nItmT015][1],Val2Str(nPauta,16,2))							// 17 - VL_UNID
	Aadd(aRegT015[nItmT015][1],Val2Str(SFT->FT_QUANT,aTamQtd[1],aTamQtd[2]))	// 18 - QUANT_PAD
	Aadd(aRegT015[nItmT015][1],Val2Str(SFT->FT_DESPESA,16,2))					// 19 - VL_OUT
	Aadd(aRegT015[nItmT015][1],"")												// 20 - IND_NAT_REC
	Aadd(aRegT015[nItmT015][1],SB1->B1_CLASSE)									// 21 - COD_SELO_IPI
	Aadd(aRegT015[nItmT015][1],Val2Str(0,16,2))	                                // 22 - QT_SELO_IPI
	Aadd(aRegT015[nItmT015][1],Val2Str(0,16,2))									// 23 - BC_ST_ORIG_DEST
	Aadd(aRegT015[nItmT015][1],Val2Str(0,16,2))									// 24 - ICMS_ST_REP
	Aadd(aRegT015[nItmT015][1],Val2Str(0,16,2))									// 25 - ICMS_ST_COMPL
	Aadd(aRegT015[nItmT015][1],Val2Str(0,16,2))									// 26 - BC_RET
	Aadd(aRegT015[nItmT015][1],Val2Str(0,16,2))									// 27 - ICMS_RET
	Aadd(aRegT015[nItmT015][1],SubStr(SFT->FT_CLASFIS,1,1))						// 28 - ORIGEM
	Aadd(aRegT015[nItmT015][1],IIf(AllTrim(SF4->F4_MOVFIS) == "S","0","1"))		// 29 - IND_MOV
	Aadd(aRegT015[nItmT015][1],"")												// 30 - ESTOQUE
	Aadd(aRegT015[nItmT015][1],Val2Str(IIf(cTipoDoc $ "02|03|04",SFT->FT_TOTAL,SFT->FT_PRCUNIT),aTamVlrIte[1],aTamVlrIte[2]))	// 31 - VL_ITEM Considerar Valor Total para Notas Complementares
	Aadd(aRegT015[nItmT015][1],cCodIss)											// 32 - COD_LST
	Aadd(aRegT015[nItmT015][1],"")												// 33 - CSOSN
	Aadd(aRegT015[nItmT015][1],"")												// 34 - INF_ADIC
	Aadd(aRegT015[nItmT015][1],Val2Str(SFT->FT_VALCONT,16,2))					// 35 - VALOR CONTABIL
	Aadd(aRegT015[nItmT015][1],cRE)												// 36 - RE
	Aadd(aRegT015[nItmT015][1],Val2Str(0,16,2))									// 37 - VL_ACRE
	Aadd(aRegT015[nItmT015][1],Val2Str(0,16,2))									// 38 - VL_DA
	Aadd(aRegT015[nItmT015][1],IIf(cTipoDoc $ "02|03|04" .Or. AllTrim(SFT->FT_CFOP) $ "5603|6603|1603|2603|1602|1605|5602|5605|5927",SubStr(SFT->FT_CLASFIS,2,2),""))	// 39 - CST_COMP
	Aadd(aRegT015[nItmT015][1],cCodSrvMun)										// 40 - COD_SERV_MUN
	Aadd(aRegT015[nItmT015][1],"")												// 41 - LICIMP
	Aadd(aRegT015[nItmT015][1],cTpRepasse)										// 42 - TPREPASSE
	Aadd(aRegT015[nItmT015][1],If(!Empty(cTpServ),'1' + StrZero(Val(cTpServ),08),''))	// 43 - TIP_SERV
	Aadd(aRegT015[nItmT015][1],cDipam)											// 44 - COD_DIPAM
	Aadd(aRegT015[nItmT015][1],Iif(lINDISEN,SFT->FT_INDISEN,""))				// 45 - IND_ISENCAO_PREVID BRUCE

	//If adicionado para atender o bloco 40.
	IF oFisaExtSx:_DHR
		Aadd(aRegT015[nItmT015][1],Posicione( "DHR", 1, xFilial( "DHR" ) + SFT->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ITEM), "DHR_NATREN" ) )		// 46 - NATUREZA_RENDIMENTO
		Aadd(aRegT015[nItmT015][1],"")	// 47 
		Aadd(aRegT015[nItmT015][1],"")	// 48 
	Endif

	// Complemento Item Fiscal modelo 06 28 e 29
	If lAchouSFU

		cCodClas := Alltrim(SFU->FU_GRPCLAS+SFU->FU_CLASSIF)

		If cEspecie == "06" .And. lAchouSFU
			nConskwh := SFU->FU_CONSTOT
		EndIf

		Aadd(aRegT015AB,{nItmT015,{{}}})
		nPosicao := Len(aRegT015AB)

		Aadd(aRegT015AB[nPosicao][2][1],"T015AB")				// 01 - REGISTRO
		Aadd(aRegT015AB[nPosicao][2][1],cCodClas)				// 02 - COD_CLASS
		Aadd(aRegT015AB[nPosicao][2][1],"0")					// 03 - IND_REC
		Aadd(aRegT015AB[nPosicao][2][1],Val2Str(nConskwh,16,2))	// 04 - CONS
		Aadd(aRegT015AB[nPosicao][2][1],IIf(cEntSai == "E","F","C") + SFT->FT_CLIEFOR)	// 05 - COD_PART
	EndIf

	// Cadastro com Operacao de Arma de Fogo
	If lAchouCD8
		Aadd(aRegT015AC,{nItmT015,{{}}})
		nPosicao := Len(aRegT015AC)

		Aadd(aRegT015AC[nPosicao][2][1],"T015AC")			// 01 - REGISTRO
		Aadd(aRegT015AC[nPosicao][2][1],CD8->CD8_TPARMA)	// 02 - IND_ARM
		Aadd(aRegT015AC[nPosicao][2][1],CD8->CD8_NUMARM)	// 03 - NUM_ARM
		Aadd(aRegT015AC[nPosicao][2][1],CD8->CD8_DESCR)		// 04 - DESCR_COMPL
		Aadd(aRegT015AC[nPosicao][2][1],"")					// 05 - NUM_CANO
	EndIf

	// Cadastro de Operacao com Veiculos Novos
	If lAchouCD9
		Aadd(aRegT015AD,{nItmT015,{{}}})
		nPosicao := Len(aRegT015AD)

		Aadd(aRegT015AD[nPosicao][2][1],"T015AD")			// 01 - REGISTRO
		Aadd(aRegT015AD[nPosicao][2][1],CD9->CD9_TPOPER)	// 02 - IND_VEIC_OPER
		Aadd(aRegT015AD[nPosicao][2][1],aPartDoc[4])		// 03 - CNPJ
		Aadd(aRegT015AD[nPosicao][2][1],aPartDoc[2])		// 04 - UF
		Aadd(aRegT015AD[nPosicao][2][1],CD9->CD9_CHASSI)	// 05 - CHASSI_VEIC
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 06 - COD_COR_MT
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 07 - POTEN_MOT
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 08 - CILIND
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 09 - PESO_LIQ
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 10 - PESO_BRT
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 11 - SERIAL
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 12 - TP_COMB
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 13 - NUM_MOTOR
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 14 - TRACAO
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 15 - DIST_EIXO
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 16 - ANO_FAB
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 17 - ANO_MOD
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 18 - TP_PINT
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 19 - TP_VEIC
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 20 - ESP_VEI
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 21 - COND_VIN
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 22 - COND_VEI
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 23 - COD_MAR_MOD
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 24 - COR_DENAT
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 25 - LOTACAO
		Aadd(aRegT015AD[nPosicao][2][1],"")					// 26 - TP_RESTR
	EndIf

	IF oFisaExtSx:_DHR

		IF DHR->(DBSEEK( xFilial("DHR")+SFT->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ITEM)) )

			While DHR->(!Eof()) .and. DHR->(DHR_DOC+DHR_SERIE+DHR_FORNEC+DHR_LOJA+DHR_ITEM) == SFT->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ITEM)

				cCalcIr := SA2->A2_CALCIRF

				If  DHR->(DHR_BASEIR+DHR_VLRIR+DHR_BASUIR+DHR_VLRSIR+DHR_BANFIR+DHR_VLNFIR) > 0

					iF cCalcIr <> '2' 
						cCodTrib := '12' 

						Aadd(aRegT015AK,{nItmT015,{{}}})
						nPosicao := Len(aRegT015AK)

						Aadd(aRegT015AK[nPosicao][2][1],'T015AK')
						Aadd(aRegT015AK[nPosicao][2][1],'')
						Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_PSIR )
						Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_TSIR ) 
						Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_ISIR )
						Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_VLRSIR)
						Aadd(aRegT015AK[nPosicao][2][1],cCodTrib)
						Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_BASUIR)

					elseif cCalcIr == '2'
						cCodTrib := '28'

						Aadd(aRegT015AK,{nItmT015,{{}}})
						nPosicao := Len(aRegT015AK)

						Aadd(aRegT015AK[nPosicao][2][1],'T015AK')
						Aadd(aRegT015AK[nPosicao][2][1],'')
						Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_PSIR )
						Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_TSIR )
						Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_ISIR )
						Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_VLRSIR)
						Aadd(aRegT015AK[nPosicao][2][1],cCodTrib)
						Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_BASUIR)
					EndIf
				Endif
				
				//PIS
				IF DHR->(DHR_BASPIS+DHR_VLRPIS+DHR_BSUPIS+DHR_VLSPIS+DHR_BNFPIS+DHR_VNFPIS) > 0
					cCodTrib := '10' 

					Aadd(aRegT015AK,{nItmT015,{{}}})
					nPosicao := Len(aRegT015AK)

					Aadd(aRegT015AK[nPosicao][2][1],'T015AK')
					Aadd(aRegT015AK[nPosicao][2][1],'')
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_PSPIS  )
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_TSPIS  )
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_ISPIS  )
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_VLRPIS )
					Aadd(aRegT015AK[nPosicao][2][1],cCodTrib)
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_BSUPIS )
				EndIf
					
				//COFINS
				IF DHR->(DHR_BASCOF+DHR_VLRCOF+DHR_BSUCOF+DHR_VLSCOF+DHR_BNFCOF+DHR_VNFCOF) > 0
					cCodTrib := '11' 

					Aadd(aRegT015AK,{nItmT015,{{}}})
					nPosicao := Len(aRegT015AK)

					Aadd(aRegT015AK[nPosicao][2][1],'T015AK')
					Aadd(aRegT015AK[nPosicao][2][1],'')
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_PSCOF  )
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_TSCOF  )
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_ISCOF  )
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_VLRCOF )
					Aadd(aRegT015AK[nPosicao][2][1],cCodTrib)
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_BSUCOF )
				Endif

				//CSLL
				IF 	DHR->(DHR_BASCSL+DHR_VLRCSL+DHR_BSUCSL+DHR_BSUCSL+DHR_VLSCSL+DHR_BNFCSL+DHR_VNFCSL) > 0  
					cCodTrib := '18' 

					Aadd(aRegT015AK,{nItmT015,{{}}})
					nPosicao := Len(aRegT015AK)

					Aadd(aRegT015AK[nPosicao][2][1],'T015AK')			// 01 - REGISTRO
					Aadd(aRegT015AK[nPosicao][2][1],'')					// 01 - REGISTRO
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_PSCSL  )	// DHR_PSPIS
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_TSCSL  )	// DHR_TSPIS 
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_ISCSL  )   // DHR_ISPIS 
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_VLSCSL  )   // DHR_ISPIS 
					Aadd(aRegT015AK[nPosicao][2][1],cCodTrib)		
					Aadd(aRegT015AK[nPosicao][2][1],DHR->DHR_BSUCSL )	// DHR_VLRSIR 
				Endif
				DHR->(DBSKIP())
			EndDo
		EndIF
		DHR->(DBCLOSEAREA())
	EndIf
	
	// Cadastro de Processos Referenciados
	If lAchouCDG .And. oFisaExtSx:_CCF_IDITEM .And. oFisaExtSx:_CCF_TRIB
		While CDG->(!Eof())	.And. CDG->(CDG_FILIAL+CDG_TPMOV+CDG_DOC+CDG_SERIE+CDG_CLIFOR+CDG_LOJA+CDG_ITEM) == SFT->(FT_FILIAL+FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ITEM)
			CCF->(DbSetOrder(01))
			If CCF->(DbSeek(xFilial('CCF')+CDG->(CDG_PROCES+CDG_TPPROC)))
				While CCF->(!Eof()) .And. CCF->(CCF_FILIAL+CCF_NUMERO) == CDG->(CDG_FILIAL+CDG_PROCES)

					If CCF->CCF_TIPO == CDG->CDG_TPPROC
						If CCF->CCF_IDITEM == CDG->CDG_ITPROC
							If CCF->CCF_TRIB $ "1|2"
								cCodTrib := "13"
							ElseIf CCF->CCF_TRIB = "3"
								cCodTrib := "24"
							ElseIf CCF->CCF_TRIB = "4"
								cCodTrib := "25"
							ElseIf CCF->CCF_TRIB = "5"
								cCodTrib := "23"
							ElseIf CCF->CCF_TRIB == "6"
								cCodTrib := "02"
							ElseIf CCF->CCF_TRIB == "7"
								cCodTrib := "06"
							ElseIf CCF->CCF_TRIB == "8"
								cCodTrib := "07"
							EndIf

							Aadd(aRegT015AK,{nItmT015,{{}}})
							nPosicao := Len(aRegT015AK)

							Aadd(aRegT015AK[nPosicao][2][1],'T015AK')			// 01 - REGISTRO
							Aadd(aRegT015AK[nPosicao][2][1],IIf(CCF->CCF_TRIB$'1|2',CCF->CCF_TRIB,''))		// 02 - TP_PROC
							Aadd(aRegT015AK[nPosicao][2][1],CCF->CCF_NUMERO)	// 03 - NUM_PROC
							Aadd(aRegT015AK[nPosicao][2][1],CCF->CCF_TIPO)		// 04 - IND_PROC
							Aadd(aRegT015AK[nPosicao][2][1],Iif(oFisaExtSx:_CCF_INDSUS,CCF->CCF_INDSUS,''))	// 05 - COD_SUS
							Aadd(aRegT015AK[nPosicao][2][1],CDG->CDG_VALOR)		// 06 - VAL_SUS
							Aadd(aRegT015AK[nPosicao][2][1],cCodTrib)			// 07 - COD_TRIB
							Aadd(aRegT015AK[nPosicao][2][1],"")		
						EndIf
					EndIf

					CCF->(DbSkip())
				EndDo
			EndIf

			CDG->(DbSkip())
		EndDo
	EndIf


	// Cadastro de Armazenamento de Combustivel
	If lAchouCD6 .And. !Empty(CD6->CD6_TANQUE)
		Aadd(aRegT015AF,{nItmT015,{{}}})
		nPosicao := Len(aRegT015AF)

		Aadd(aRegT015AF[nPosicao][2][1],"T015AF")						// 01 - REGISTRO	-
		Aadd(aRegT015AF[nPosicao][2][1],CD6->CD6_TANQUE)				// 02 - NUM_TANQUE	- Num tanque
		Aadd(aRegT015AF[nPosicao][2][1],Val2Str(CD6->CD6_VOLUME,16,3))	// 03 - QTDE		- Quant. armazenada
		Aadd(aRegT015AF[nPosicao][2][1],"")								// 04 - CODIF		- Codigo Autoriz. Registro
		Aadd(aRegT015AF[nPosicao][2][1],"")								// 05 - QT_FAT_AMB	- Qtde Fat. Temp. Amb.
		Aadd(aRegT015AF[nPosicao][2][1],"")								// 06 - UF_CONS		- ID da UF de Consumo
		Aadd(aRegT015AF[nPosicao][2][1],"")								// 07 - BC_CIDE		- BC da CIDE em Quantidade
		Aadd(aRegT015AF[nPosicao][2][1],"")								// 08 - ALIQ_CIDE	- Aliquota da CIDE
		Aadd(aRegT015AF[nPosicao][2][1],"")								// 09 - VAL_CIDE	- Valor CIDE
	EndIf

	// Ressarcimento de ICMS em Operacoes com ST
	If lAchouCD0
		If SA2->(MsSeek(xFilial("SA2") + CD0->(CD0_FORNE+CD0_LOJENT)))
			aPartT015AG := TafPartic("SA2")
		EndIf

		Aadd(aRegT015AG,{nItmT015,{{}}})
		nPosicao := Len(aRegT015AG)

		Aadd(aRegT015AG[nPosicao][2][1],"T015AG")						// 01 - REGISTRO
		Aadd(aRegT015AG[nPosicao][2][1],AModNot(CD0->CD0_ESPECIE))		// 02 - COD_MOD_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],CD0->CD0_DOCENT)				// 03 - NUM_DOC_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],CD0->CD0_SERENT)				// 04 - SER_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],DToS(CD0->CD0_EMISSA))			// 05 - DT_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],IIf(!Empty(aPartT015AG),aPartT015AG[1],""))	// 06 - COD_PART_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],Val2Str(CD0->CD0_QUANT,16,3))	// 07 - QUANT_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],Val2Str(CD0->CD0_VUNIT,16,2))	// 08 - VL_UNIT_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],Val2Str(CD0->CD0_VALBST,16,2))	// 09 - VL_UNIT_BC_ST
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 10 - CHAVE_NFE_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 11 - NUM_ITEM_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 12 - VL_UNIT_BC_ICMS_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 13 - ALIQ_ICMS_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 14 - VL_UNIT_LIMITE_BC_ICMS_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 15 - VL_UNIT_ICMS_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 16 - ALIQ_ST_ULT_E
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 17 - VL_UNIT_RES
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 18 - COD_RESP_RET
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 19 - COD_MOT_RES
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 20 - CHAVE_NFE_RET
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 21 - COD_PART_NFE_RET
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 22 - SER_NFE_RET
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 23 - NUM_NFE_RET
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 24 - ITEM_NFE_RET
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 25 - COD_DA
		Aadd(aRegT015AG[nPosicao][2][1],"")								// 26 - NUM_DA
	EndIf

	//Complemento do Item do Documento Fiscal
	If lAchouSFX

		cIndRec := SFX->FX_TIPOREC
		cCodClas := Alltrim(SFX->FX_GRPCLAS+SFX->FX_CLASSIF)

		Aadd(aRegT015AH,{nItmT015,{{}}})
		nPosicao := Len(aRegT015AH)

		Aadd(aRegT015AH[nPosicao][2][1],"T015AH")		// 01 - REGISTRO
		Aadd(aRegT015AH[nPosicao][2][1],cCodClas)		// 02 - COD_CLASS
		Aadd(aRegT015AH[nPosicao][2][1],cIndRec)		// 03 - IND_REC
		Aadd(aRegT015AH[nPosicao][2][1],aPartDoc[1])	// 04 - COD_PART
	EndIf

	If lAchouDT6
	//Se encontrar o hash criado pelo SPEDXFUN, utilizo ele, se não encontrar uso a função local
		If lHashTMS
			cKey := HMKey({DT6->DT6_CDRORI, 'VALUE_CODMUN'}, 1, 0, 2, 0)
			If Len(FisRetHash(oHashTMSM, cKey, @aRet )) > 0
				cCodEstOrg := aRet[1][2]
			EndIf
		Else
			cCodEstOrg := ExtTmsMun(DT6->DT6_CDRORI)
		Endif
		
		cCodMunOrg := ""
		cCodMunDes := ""
		cCodVei    := "" 

		If Len(cCodEstOrg) > 5 

			If Upper( SubStr( cCodEstOrg, 1, 2 ) ) != "EX"
				cCodMunOrg := SubStr(cCodEstOrg,3,5)
			Else
				cCodMunOrg := "9999999"
			EndIf

			cCodEstOrg := SubStr(cCodEstOrg,1,2)
		EndIf
		If lHashTMS
			cKey := HMKey({DT6->DT6_CDRCAL, 'VALUE_CODMUN'}, 1, 0, 2, 0)
			If Len(FisRetHash(oHashTMSM, cKey, @aRet )) > 0
				cCodEstDes := aRet[1][2]
			EndIf
		Else
			cCodEstDes := ExtTmsMun(DT6->DT6_CDRCAL)
		Endif
		
			

		If Len( cCodEstDes ) > 5

			If Upper( SubStr( cCodEstDes, 1, 2 ) ) != "EX"
				cCodMunDes := SubStr( cCodEstDes, 3, 5 )
			Else
				cCodMunDes := "9999999"	
			EndIf

			cCodEstDes := SubStr( cCodEstDes, 1, 2 )
		EndIf

		

		If lAchouDA3
			cCodVei :=	DA3->DA3_COD
		EndIf

		Aadd(aRegT015AI,{nItmT015,{{}}})
		nPosicao := Len(aRegT015AI)

		Aadd(aRegT015AI[nPosicao][2][1],"T015AI")		// 01 - REGISTRO
		Aadd(aRegT015AI[nPosicao][2][1],cCodEstOrg)		// 02 - UF_MUN_ORIG
		Aadd(aRegT015AI[nPosicao][2][1],cCodMunOrg)		// 03 - COD_MUN_ORIG
		Aadd(aRegT015AI[nPosicao][2][1],cCodEstDes)		// 04 - UF_MUN_DEST
		Aadd(aRegT015AI[nPosicao][2][1],cCodMunDes)		// 05 - COD_MUN_DEST
		Aadd(aRegT015AI[nPosicao][2][1],cCodVei)		// 06 - VEIC_ID
	EndIf


Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TabIpi
Funcao utilizada para fazer o de para da tabela 511 do SPED
EI6 -> C3T

@param  cValor - Valor do campo B1_TAB_IPI

@author Matheus Prada
@since 27/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TabIpi(cValor)

Default cValor := 0

Do Case

	Case IsDigit(cValor)
		cValor:= '99999'

	Case Alltrim(cValor) == 'M' .AND. Alltrim(SB1->B1_POSIPI) = '24022000' 
		cValor:= 'III-M'

	Case Alltrim(cValor) == 'R' .AND. Alltrim(SB1->B1_POSIPI) = '24022000' 
		cValor:= 'III-R'

EndCase

Return cValor 

//-------------------------------------------------------------------
/*/{Protheus.doc} EXTTMSMUN
Funcao utilizada para pegar o código de municipio da operação de transporte do TMS.


@param  cRegiao - Região de cálculo conforme regra do TMS

@author Felipe Guarnieri
@since 26/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function ExtTmsMun(cRegiao)
Local cCodMun:= ""
Local cUF    := ""
Local aAreaDUY := {}


aAreaDUY := DUY->(GetArea())
If DUY->(MsSeek(xFilial('DUY')+cRegiao)) .And. !Empty(DUY->DUY_CODMUN)
	cCodMun := DUY->DUY_CODMUN
	If Len(cCodMun)<=5
		cUF := DUY->DUY_EST
	
		If Empty(cUF) 
			cUf := '99'
		EndIf
		cCodMun := cUF+cCodMun
	
	Elseif Len(cCodMun) > 5
		cCodMun := DUY->DUY_EST+SubStr(cCodMun,3,5)
	EndIf
	
Else
	cCodMun := '9999999'
EndIf
RestArea(aAreaDUY)
	
Return(cCodMun)
