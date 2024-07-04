#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"

#Define _SEL_T012_	01
#Define _SEL_T013_	02 
#Define _DATA_DE_	03
#Define _DATA_ATE_	04 
#Define _NOTA_DE_	05
#Define _NOTA_ATE_	06
#Define _SERI_DE_	07
#Define _SERI_ATE_	08
#Define _ESP_S_PR_	09
#Define _ESP_C_PR_	10
#Define _APUR_IPI_	11

//Variavel para guardar as areas já abertas das tabelas que serão utilizadas.
Static __aArea__ := {}

Static oFisaExtSx := FisaExtX02()

/*/{Protheus.doc} RegT013
	( Realiza a geracao do registro T013 do TAF )

	@type Static Function
	@author Rodrigo Aguilar
	@since 19/03/2015

	@param a_ParamMT, array, contem parâmetros para utilizar na função
	@param a_RgT022AB, array, registro T022AB
	@param a_VlrMovST, array, valor de movimento de ST
	@param a_IcmPago, array, informações do icms pago
	@param a_LanCDA2, array, lancamento da CDA

	@return lGerou, logico, se gerou ou não.

	@obs Função refeita - Vitor Ribeiro - 22/01/2018
	O parametro a_ParamMT possui as seguintes informações.
		a_ParamMT[01] - cEntSai
		a_ParamMT[02] - lMultThr
		a_ParamMT[03] - aThread
		a_ParamMT[04] - cQueryMT
		a_ParamMT[05] - cTpSaida
		a_ParamMT[06] - cJobAux
		a_ParamMT[07] - cNumThr
		a_ParamMT[08] - lTAFGST2
		a_ParamMT[09] - cTxtSys
	/*/
Function RegT013(a_Wizard,a_ParamMT,a_RgT022AB,a_VlrMovST,a_IcmPago,a_LanCDA2,aParticip,aProdutos,cTblTemp)
	
	Local cAliasPrin := ""
	Local cEntSai := ""
	Local cQueryMT := ""
	Local cConcat := ""
	Local cJobAux := ""
	Local cNumThr := ""
	Local cMVEstado := ""
	Local cUFRESpd := ""
	Local cMV_StUf := ""
	Local cMV_StUfS := ""
	Local cMVSUBTRIB := ""
	Local cMVCFE210 := ""
	Local cOpSemF := "" 
	Local cApurSep := ""
	Local cDtAteGia := ""
	Local cTipoDoc := ""
	Local cEspecie := ""
	Local cIndEmit := ""
	Local cFrete := ""
	Local cChaveSeek := ""
	Local cPartCol := ""
	Local cPartEnt := ""
	Local cChaveSFT := ""
	Local cChv115 := ""
	Local cVol115 := ""
	Local cDoctms := ""
	Local cFormProp := ""
	Local cTpCTE := ""
	Local cCodTensao := ""
	Local cSituaDoc := ""
	Local cChaveCDC := ""
	Local cAlsTAFST := ""
	Local cCodIss := ""
	Local cTxtSys := ""
	Local cCpoPrefix := ""
	Local cCpoDupl := ""
	Local cCpoNFCpm := ""
	Local cCpoTrans := ""
	Local cCpoPBruto := ""
	Local cCpoPLiqui := ""
	Local cCpoVeic1 := ""
	Local cCpoVeic2 := ""
	Local cCpoVeic3 := ""
	Local cCpoSimpN := ""
	Local cCpoRegPB := ""
	Local cCpoFrete := ""
	Local cIndPgto := ""
	Local cIndFrt := ""
	Local cTipoPart := ""
	Local cMV_RE := ""
	Local cMenNota := ""
	Local cFormula := ""
	Local cCodObra	:= ""
	Local cTpPropObr:= ""
	Local cNFiscal  := ""
	Local cNfisOri  := ""
	Local cESPNFEL 	:= Alltrim( GetNewPar("MV_ESPNFEL","") )
	Local cFrtOrig	:=	""
	Local cFrtDest	:=	""
	Local cNotaUF   := ""
	Local cUFRem    := ""
	Local cUFDes    := ""
	Local cEstDUY   := ""
	Local cAliasGia := ''
	Local lTmsUfPg  := .T. // Default T - Pagador de documentos de transporte
	Local lMultThr := .F.
	Local lTAFGST2 := .F.
	Local lIntTms := .F.
	Local lResF3FT := .F.
	Local lDT5Sol := .F.
	Local lTafKey := .F.
	Local lEmpTafKey := .F.
	Local lAchouCD3 := .F.
	Local lAchouCDT := .F.
	Local lAchouCDG := .F.
	Local lAchouCD5 := .F.
	Local lAchouCDC := .F.
	Local lAchouCDD := .F.
	Local lAchouCDF := .F.
	Local lAchouCD4 := .F.
	Local lAchouSFU := .F.
	Local lAchouCD0 := .F.
	Local lAchouCD6 := .F.
	Local lAchouCD7 := .F.
	Local lAchouCD8 := .F.
	Local lAchouCD9 := .F.
	Local lAchouSFX := .F.
	Local lAchouDT6 := .F.
	Local lAchouDUD := .F.
	Local lAchouDT5 := .F.
	Local lAchouDT8 := .F.
	Local lAchouDTC := .F.
	Local lAchouDTQ := .F.
	Local lAchouDTR := .F.
	Local lAchouDA3 := .F.
	Local lAchouSB5 := .F.
	Local lAchouDUL := .F.
	Local lAchou2DUL := .F.
	Local lGerT013AN := .F.
	Local lFirstItem := .F.
	Local lNewCFrt := .F.
    Local lOpenTAFST := .F.
    Local lInd3CDG := .F.
	Local lGerou := .F.
	Local lServico := .F.
	Local lAdicGuia := .t.
	Local lCdOri := .F.
	Local lExtGia := .f.
	Local aArea := {}
	Local aThread := {}
	Local aLanCDA := {}
	Local aPartDoc := {}
	Local aPartREM := {}
	Local aPartDES := {}
	Local aPartCON := {}
	Local aPartDPC := {}
	Local aInfoCompl := {}
	Local aCmpAntSFT := {}
	Local aRegT013 := {}
	Local aRegT013AN := {}
	Local aRegT013AP := {}
	Local aRegT012 := {}
	Local aRegT012AA := {}
	Local aClasFis := {}
	Local aAreaCDC := {}
	Local aRegT015 := {}
	Local aRegT015AB := {}
	Local aRegT015AC := {}
	Local aRegT015AD := {}
	Local aRegT015AE := {}
	Local aRegT015AF := {}
	Local aRegT015AG := {}
	Local aRegT015AH := {}
	Local aRegT015AI := {}
	Local aRegT015AK := {}
	Local aFilialMT	 := {cEmpAnt,cFilAnt}
	Local aESPNFEL   := { }
	Local aPipes     := { "|", ";", "/", "\" }
	Local aAreaDUY   := {}
	Local lFltRnf013 :=	.F.
	Local cFltInt013 := "3"	
	Local lPipe      := .F.
	Local cMV_DifTr	 :=""

	Local nHdlTxt	:= 0
	Local nCount	:= 0
	Local nValorST	:= 0
	Local nEstcred	:= 0
	Local nValBrut	:= 0
	Local nValMerc	:= 0
	Local nRecnoCD6	:= 0
	Local nRecnoSFX	:= 0
    Local nRecnoCDG := 0
	Local nPosicao	:= 0
	Local nVlrForn	:= 0
	Local nVlrAbatNt:= 0
	Local lINDISEN  := SFT->(FieldPos("FT_INDISEN"))>0
	Local oError := ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr(10)+ Obj:Description + chr(10) + Obj:ErrorStack ) },3,.T.,"EXT" )
	Local nValIss 	:= 0
	Local nPosEspNfe := 0
	Local nI := 0
	Local nTamItem := TamSX3( "D1_ITEM" )[1]
	Local cNew	:= "HMNew()"
	Local lHashTMS	 := FindFunction("HashTMSCM")
	Local aTamQtd    := TamSX3("C30_QUANT")
	
	Private lBuild    	:=	GetBuild() >= "7.00.131227A"
	Private oHashTMSM
	
	Private cInc := "000001"
	Private cSomaItem := replicate("0",nTamItem)
	Private cTpSaida := "3"
	

	Private aDadosST1 := {}
	Private aWizard := {}
	
	Default a_Wizard := {}
	Default a_ParamMT := {}
	Default a_RgT022AB := {}
	Default a_VlrMovST := {}
	Default a_IcmPago := {}
	Default a_LanCDA2 := {}
	Default aParticip := {}
	Default aProdutos := {}
	Default cTblTemp := ''


	//Se o extrator foi chamado na execução da GIA-SP
	lExtGia := !empty(cTblTemp)

	//Crio o hash apenas se existir a função do SPEDXFUN que cria e alimenta oHashTMSM
	If lBuild .And. lHashTMS
    	oHashTMSM := &cNew		
	EndIf

	// Pega as informações da wizard
	aWizard := a_Wizard

	/* 
		Se o parametro MV_ESPNFEL estiver preenchido apenas com uma especie e sem o separador no final,
		insiro o pipe para que a função StrTokArr funcione corretamente.
	*/
	If !Empty( cESPNFEL )

		for nI:= 1 to Len( aPipes )
			If ( aPipes[nI] $ cESPNFEL ) 
				lPipe := .T.
				exit
			EndIf
		Next

		If !lPipe
			cESPNFEL += "|"
		EndIf	

		/* 
			Tratativa necessária, pois pela documentação do parametro MV_ESPNFEL, o cliente pode utilizar como separador
			ponto e vírgula ( ; ), barra ( \ ou / ) ou pipe ( | )
		*/	
		cESPNFEL := StrTran( cESPNFEL, ";","|" )
		cESPNFEL := StrTran( cESPNFEL, "\","|" ) 
		cESPNFEL := StrTran( cESPNFEL, "/","|" ) 

	EndIf

	aESPNFEL := StrTokArr( cESPNFEL, "|" )
	
	// Se a variavel não existir, inicializa a mesma.
	If Type("cTafJobMsg") <> "C"
		Private cTafJobMsg := ""
	EndIf
	
	If Type("cDirSystem") <> "C"
		Private cDirSystem := ""
	EndIf

	If Type("aArqGer") <> "A"
		Private aArqGer := {}
	EndIf
	
	If Type("lBuild") <> "L"
		Private lBuild := GetBuild() >= "7.00.131227A"
	EndIf

	If Type("cExtUser") <> "C"
		Private cExtUser := ''
	EndIf

	// Pega a area atual
	aArea := GetArea()
	
	// Função para abrir as tabelas que serão utilizadas.
	fTables(.T.)
	
	/*
		Tratamento para que caso ocorra Erro durante o processamento não estoure na tela
		é exibida uma mensagem tratada do erro para o usuário final
	*/
	Begin Sequence

		If oFisaExtSx:_CDG
        	// Verifica existência do índice 
        	lInd3CDG := CDG->(DBOrderInfo(9)) >= 3 
		EndIf
		
		//Atribuindo os valores recebidos por parametros para as variaveis de processamento
		cEntSai := a_ParamMT[01]
		lMultThr := a_ParamMT[02]
		aThread := a_ParamMT[03]
		cQueryMT := a_ParamMT[04]
		cTpSaida := a_ParamMT[05]
		cJobAux := a_ParamMT[06]
		cNumThr := IIf(lMultThr,a_ParamMT[7],cEntSai)
		lTAFGST2 := a_ParamMT[08]
		cTxtSys := a_ParamMT[09]
		cDirSystem := a_ParamMT[11]
		aArqGer := a_ParamMT[12]
		If Len(a_ParamMT) >= 14
			aFilialMT := a_ParamMT[13]
			lFltRnf013 := a_ParamMT[14]			
		EndIf
		If Len(a_ParamMT) >= 15
			cFltInt013 := a_ParamMT[15]
		endif

		If Len(a_ParamMT) >= 16
			cExtUser := a_ParamMT[16] 
		endif

		If lMultThr
			If SM0->(MsSeek(aFilialMT[1]+aFilialMT[2],.T.))
				cEmpAnt := FWGrpCompany()
				cFilAnt := FWCodFil()
			EndIf
		EndIf


		//Caso seja processamento em multi thread inicio as variaveis globais 
		If lMultThr
			// Status 1 - Iniciando execucao do Job
			PutGlbValue(cJobAux,"1") 
			GlbUnLock()
		EndIf

		If Month(aWizard[_DATA_ATE_]) == 12
			cDtAteGia := AllTrim(Str(Year(aWizard[_DATA_ATE_])+1)) + "01"
		Else
			cDtAteGia := AllTrim(Str(Year(aWizard[_DATA_ATE_]))) + StrZero(Month(aWizard[_DATA_ATE_])+1,2,0)
		EndIf
		
		cDtAteGia += "09"
	
		if FNewMtoFis()
			If Empty(Select("F2D"))
				DbSelectArea("F2D")
				F2D->(DbSetOrder(2)) //F2D_FILIAL+F2D_IDREL
			endif
		endif

		/*
			Sempre que existir o campo FT_TAFKEY ele deve ser considerado para geração do registro T013, ou seja, caso já esteja preenchido
			a nota já existe no TAF e não precisa mais ser enviada, a única exceção é quando é executada a extração para o final do período 
			( Apuração de ICMS/ ICMS-ST/IPI/DIFAL/etc... ) nesses casos devo considerar todas as notas, mesmo as já enviadas ao TAF
		*/
		// Função para Executar a Query
		cAliasPrin := fQueryPrin(cEntSai,cQueryMT,cDtAteGia,lTafKey,lMultThr,aThread,cJobAux,lFltRnf013, cFltInt013,,,,lExtGia)

		DbSelectArea(cAliasPrin)
		If (cAliasPrin)->(!Eof())
			
			TAFCONOUT(cTafJobMsg + "Thread( " + AllTrim(Str(ThreadID())) + " ) - Emp: " + cEmpAnt + ", Fil: " + cFilAnt + " - Processando movimento T013(" + cEntSai + ")" )
			TcInternal(1,"Thread( " + AllTrim(Str(ThreadID())) + " ) - " + ConType() + " - Processando movimento T013(" + cEntSai + ")" )
			
			//Caso seja processamento em multi thread inicio as variaveis globais 
			If lMultThr
				// Status 2 - Iniciou os parametros e abriu tabela
				PutGlbValue(cJobAux,"2")
				GlbUnLock()
			EndIf
			
			nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys),0)
			
			//Caso seja integração Banco a Banco
			If cTpSaida == "2"
				cAlsTAFST := IIf(lTAFGST2,"TAFST2","TAFST1")
				
				//Abre TAFST1
				If !(SELECT(cAlsTAFST) > 0)
                    lOpenTAFST := .T.
					DbUseArea(.T.,"TOPCONN",cAlsTAFST,cAlsTAFST,.T.,.F.)
				EndIf
			EndIf
			
			// Neste momento Se Seta o ambiente verIficando se a tabela CDT existe na base de dados                                               
			SPEDOpenEnv(.T.,@lAchouCDT,,@lIntTMS,,)
				
			// Iniciando as variaveis com o valor dos parametros  
			cMVEstado := oFisaExtSx:_MV_ESTADO
			cUFRESpd := oFisaExtSx:_MV_UFRESPD
			cMV_StUf := oFisaExtSx:_MV_STUF		// Define os estados a serem utilizados para o artigo 281
			cMV_StUfS := oFisaExtSx:_MV_STUFS	// Define os estados a serem utilizados para o artigo 281 - para as saidas
			cMVSUBTRIB := SpedPrSeq("MV_SUBTRIB")
			cMVCFE210 := SpedPrSeq("MV_CFE210","1410,1411,1414,1415,1660,1661,1662,2410,2411,2414,2415,2660,2661,2662")
			cOpSemF := LeParSeq(oFisaExtSx:_MV_OPSEMF)
			cMV_RE := oFisaExtSx:_MV_RE	// MV_RE
			// Pega IE de DIfal
			cMV_DifTr := IIf(FindFunction("GETSUBTRIB"),GetSubTrib("",.T.),SuperGetMv("MV_SUBTRIB"))
			
			lResF3FT := oFisaExtSx:_MV_RESF3FT			// MV_RESF3FT
			cApurSep := AllTrim(oFisaExtSx:_MV_APUSEP)	// MV_APUSEP
			lTmsUfPg := oFisaExtSx:_MV_TMSUFPG			// MV_TMSUFPG //T - Pagador de documentos de transporte F - Destinatário da Mercadoria

			lDT5Sol := oFisaExtSx:_DT5_CODSOL

			//Grava oHashTMSM para ser utilizado em cada thread
			If lIntTMS .And. lHashTMS
				HashTMSCM("", .T.) 
			Endif

			cCpoPrefix := ""
			cCpoDupl   := ""
			cCpoNFCpm  := ""
			cCpoTrans  := ""
			cCpoPBruto := ""
			cCpoPLiqui := ""
			cCpoVeic1  := ""
			cCpoVeic2  := ""
			cCpoVeic3  := ""
			cCpoFrete  := ""
			If (cAliasPrin)->RECCABEC > 0
				If cEntSai == "E"	// Guarda os campos da tabela SF1
					cCpoPrefix := "SF1->F1_PREFIXO"
					cCpoDupl := "SF1->F1_DUPL"
					cCpoFrete := "F1_FRETE"
				ElseIf cEntSai == "S"	// Guarda os campos da tabela SF2
					cCpoPrefix := "SF2->F2_PREFIXO"
					cCpoDupl   := "SF2->F2_DUPL"
					cCpoNFCpm  := "SF2->F2_NFCUPOM"
					cCpoTrans  := "SF2->F2_TRANSP"
					cCpoPBruto := "SF2->F2_PBRUTO"
					cCpoPLiqui := "SF2->F2_PLIQUI"
					cCpoVeic1  := "SF2->F2_VEICUL1"
					cCpoVeic2  := "SF2->F2_VEICUL2"
					cCpoVeic3  := "SF2->F2_VEICUL3"
					cCpoFrete  := "F2_FRETE"
				EndIf
			EndIf

			If (cAliasPrin)->FOR_CLI == "SA1"
				cCpoSimpN := "SA1->A1_SIMPNAC"
				cCpoRegPB := "SA1->A1_REGPB"
			Else
				cCpoSimpN := "SA2->A2_SIMPNAC"
			EndIf
			
			If lFltRnf013 .And. (cFltInt013 $ "2|3" .Or. empty(cFltInt013))
				// Atualiza a tela de processamento, pois se encontrou algum movimento, os registros serão gerados.
				FisaExtW01(cFilProc,0,"T007",3)
				FisaExtW01(cFilProc,0,"T003",3)
			EndIf

			// Enquanto não for final de arquivo.
			While (cAliasPrin)->(!Eof()) .And. !KillApp()
				
				lFirstItem := .T.
				lEmpTafKey := .F.
				lGerT013AN := .F.
				lNewCFrt := .F.
				lAchouCD3 := .F.
				lAchouCDT := .F.
				lAchouCDG := .F.
				lAchouCD5 := .F.
				lAchouCDC := .F.
				lAchouCDD := .F.
				lAchouCDF := .F.
				lAchouCD4 := .F.
				lAchouSFU := .F.
				lAchouCD0 := .F.
				lAchouCD6 := .F.
				lAchouCD7 := .F.
				lAchouCD8 := .F.
				lAchouCD9 := .F.
				lAchouSFX := .F.
				lAchouDT6 := .F.
				lAchouDUD := .F.
				lAchouDT5 := .F.
				lAchouDT8 := .F.
				lAchouDTC := .F.
				lAchouDTQ := .F.
				lAchouDTR := .F.
				lAchouDA3 := .F.
				lAchouSB5 := .F.
				lAchouDUL := .F.
				lAchou2DUL := .F.
				
				cDoctms := ""
				cTpCTE := ""
				cCodIss := ""
				cIndPgto := ""
				cIndFrt := ""
				cTipoPart := ""
				cMenNota := ""
				cFrtOrig	:=	""
				cFrtDest	:=	""
				
				nRecnoCD6 := 0
				nRecnoSFX := 0
                nRecnoCDG := 0
				nVlrAbatNt := 0
				nValBrut := 0
				nValMerc := 0
				nValIss	 := 0
				nPosEspNfe := 0

				aLanCDA := {}
				aInfoCompl := {}
				aClasFis := {}
				aPartDoc := {}
				aPartREM := {}
				aPartDES := {}
				aPartCON := {}
				aPartDPC := {}
				aRegT013AN := {}
				aRegT013AP := {}
				aRegT015 := {} 
				aRegT015AB := {}
				aRegT015AC := {}
				aRegT015AD := {}
				aRegT015AE := {} 
				aRegT015AF := {}
				aRegT015AG := {}
				aRegT015AH := {}
				aRegT015AI := {}
				aRegT015AK := {}

				// Função para posicionar nas tabelas referente ao cabeçalho
				fPosTabCab((cAliasPrin)->TIPOMOV,(cAliasPrin)->FOR_CLI,(cAliasPrin)->RECCABEC,(cAliasPrin)->RECSA1, (cAliasPrin)->RECSA2)

				// Função para posicionar nas tabelas referente aos itens
				fPosTabItm((cAliasPrin)->TIPOMOV,(cAliasPrin)->RECSFT,(cAliasPrin)->RECITENS,(cAliasPrin)->RECSF4,(cAliasPrin)->RECSB1,(cAliasPrin)->RECSB5)

				cNotaUF := SFT->FT_ESTADO

				//Tratamento para Tipo do Documento Fiscal
				cTipoDoc := FDeParaTAF("SFT_TIPO",{ AllTrim(SFT->FT_TIPO) })
							
				//Buscando o Modelo da NF
				cEspecie :=	AModNot(SFT->FT_ESPECIE)
				
				//Tratamento para servico
				If Empty(cEspecie)
					cEspecie := "01"
				EndIf
				
				cFormula := SFT->FT_FORMULA
				
				// Se for formulario proprio ou nota de saída
				If "S" $ SFT->FT_FORMUL .Or. (Empty(SFT->FT_FORMUL) .And. SFT->FT_TIPOMOV == "S")
					cIndEmit := "0"	// Emissao Propria
				Else
					cIndEmit := "1"	// Emissao de Terceiros
				EndIf 

				If SFT->FT_TIPOMOV == "E" .And. cIndEmit == "1" .And. (cAliasPrin)->RECCABEC == 0
					(cAliasPrin)->(DbSkip())
					Loop
				EndIf
				If SFT->FT_TIPOMOV == "E" .And. lFltRnf013 .And. (cAliasPrin)->RECSA2 == 0
					(cAliasPrin)->(DbSkip())
					Loop
				EndIf

				cNFiscal := SFT->FT_NFISCAL
				cNfisOri := SFT->FT_NFISCAL

				nPosEspNfe := aScan( aESPNFEL, { |x| AllTrim(SFT->FT_ESPECIE) == x  } )

				// Nota fiscal com nro de documento eletronico retornado pela prefeitura, conforme parametro MV_ESPNFEL.
				If nPosEspNfe > 0
					If !Empty(SFT->FT_NFELETR)
						cNFiscal := SFT->FT_NFELETR
					ElseIf SFT->FT_TIPOMOV == "S"
						/*
							Foi decidido pela equipe desenvolvimento padrão que notas de saída que tenham especies preenchidas no parametro MV_ESPNFEL,
							devem ter o campo nota fiscal eletrônica preenchida antes de ir para o TAF.
						
							Para notas fiscais de entrada, não é necessário que o campo nota fiscal eletrônica esteja preenchido.
							Pois o fornecedor nem sempre repassa essa informação para o cliente.
						*/
						(cAliasPrin)->(DbSkip())
						Loop
					EndIf
				EndIf

				// Busca os dados do participante
				aPartDoc := TafPartic((cAliasPrin)->FOR_CLI)
				If lFltRnf013 .And. (cFltInt013 $ "1|3" .Or. empty(cFltInt013))
					RegT003Pos((cAliasPrin)->FOR_CLI, @aParticip )
				EndIf

				// CDT -> INF. COMPLEMENTARES POR NF
				lAchouCDT := SPEDSeek("CDT",1,xFilial("CDT")+SFT->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA))
				
				If lAchouCDT
					cFrete := CDT->CDT_INDFRT
				EndIf
				
				/*
					lNewCFrt - VerIfica se deve adotar a nova regra do codigo Indicador tipo frete
					Conforme publicado no guia pratico Versão 2.0.7
				*/                               
				lNewCFrt := SFT->FT_ENTRADA >= SToD("20120101")
				
				// Busca o Codigo da Situacao do Documento
				cSituaDoc := SPEDSitDoc(,"SFT",(cAliasPrin)->FOR_CLI,cCpoSimpN,,,(cMVEstado $ cUFRESpd),.F.,,,"SF4")
				
				/*
					Neste momento eu realizo o posicionamento na tabela Fisica para os documentos fiscais que contem complementos
				*/
				// CDC -> GUIAS RECOLHIMENTO REFERENC.
				lAchouCDC := SPEDSeek("CDC",1,xFilial("CDC")+SFT->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA))
				
				// CDD -> DOCUMENTOS REFERENCIADOS
				lAchouCDD := SPEDSeek("CDD",1,xFilial("CDD")+SFT->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA))

				If lAchouCD4 .and. cEspecie == '29'
					Aadd(aRegT013AN,{})
					nPosicao := Len(aRegT013AN)
					
					Aadd(aRegT013AN[nPosicao],SFT->FT_ITEM)
					Aadd(aRegT013AN[nPosicao],SFT->(FT_ISENICM+FT_OUTRICM))
					
					lGerT013AN := .T.
				EndIf
				
				// CD5 -> COMPLEMENTO DE IMPORTACAO
				lAchouCD5 := SPEDSeek("CD5",1,xFilial("CD5")+SFT->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA))

				// DT6 -> DOCUMENTOS DE TRANSPORTE
				If !Empty((cAliasPrin)->RECDT6)
					lAchouDT6 := SpedSeek("DT6",,,(cAliasPrin)->RECDT6)
				EndIf

				// DUD -> MOVIMENTO DE VIAGEM
				If !Empty((cAliasPrin)->RECDUD)
					lAchouDUD := SpedSeek("DUD",,,(cAliasPrin)->RECDUD)
				EndIf
				
				/*
					Para as notas fiscais de transportes vindas do TMS sempre deverah  
					haver um DT6 correspondente, caso nao haja, saltar para a proxima  
					nota. Instrucoes passadas pela equipe do TMS.
				*/                      
				If lIntTMS .And. !lAchouDT6 .And. SFT->FT_TIPOMOV == "S" .And. cEspecie $ "|07|08|09|10|11|26|27|57" .And. Empty(SFT->FT_DTCANC)
					(cAliasPrin)->(DbSkip())
					Loop
				EndIf
				
				/*
					Quanto for integracao com o TMS utilizo a regra do modulo TMS para obter alguns dados do transporte 
				*/
				If lAchouDT6
					cDoctms := DT6->DT6_DOCTMS

					//CRIADO "DE PARA" COM O VALOR DO CAMPO DT6_DOCTMS PARA O CAMPO C20_TPCTE
					Do Case
						Case DT6->DT6_DOCTMS $ "1/2/5/6/9/A/B/C/D/F/G/H/I/J/K/N/O"
							cDoctms := "0" //- CT-e Normal
						Case DT6->DT6_DOCTMS $ "7/8/E/L"
							cDoctms := "1" //- CT-e de Complemento
						Case DT6->DT6_DOCTMS $ "M"
							cDoctms := "2" //- CT-e de Anulação 
						Case DT6->DT6_DOCTMS $ "P"
							cDoctms := "3" //- CT-e Substituto
					EndCase

					aPartREM := aPartDoc
					aPartDES := aPartDoc
					
					// Remetente do conhecimento
					If SPEDSeek("SA1",1,xFilial("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM))
						aPartREM := TafPartic("SA1")
						if Valtype( aPartREM ) == "A" .And. Len( aPartREM ) >= 2
							cUFRem := aPartREM[2] //estado
						endif
						If lFltRnf013 .And. (cFltInt013 $ "1|3" .Or. empty(cFltInt013))
							RegT003Pos("SA1", @aParticip )
						EndIf
					EndIf
					
					// Destinatario do conhecimento
					If SPEDSeek("SA1",1,xFilial("SA1")+DT6->(DT6_CLIDES+DT6_LOJDES))
						aPartDES := TafPartic("SA1")
						if Valtype( aPartDES ) == "A" .And. Len( aPartDES ) >= 2
							cUFDes := aPartDES[2] //estado
						endif
						If lFltRnf013 .And. (cFltInt013 $ "1|3" .Or. empty(cFltInt013))
							RegT003Pos("SA1", @aParticip )
						EndIf
					EndIf
					
					// Consignatario do conhecimento
					If SPEDSeek("SA1",1,xFilial("SA1")+DT6->(DT6_CLICON+DT6_LOJCON))
						aPartCON := TafPartic("SA1")
						If lFltRnf013 .And. (cFltInt013 $ "1|3" .Or. empty(cFltInt013))
							RegT003Pos("SA1", @aParticip )
						EndIf
					EndIf
					
					// Despachante da mercadoria
					If SPEDSeek("SA1",1,xFilial("SA1")+DT6->(DT6_CLIDPC+DT6_LOJDPC))
						aPartDPC := TafPartic("SA1")
						If lFltRnf013 .And. (cFltInt013 $ "1|3" .Or. empty(cFltInt013))
							RegT003Pos("SA1", @aParticip )
						EndIf
					EndIf
					
					If DT6->DT6_DOCTMS <> StrZero(8,Len(DT6->DT6_DOCTMS))
						cChaveSeek := DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)
					Else
						cChaveSeek := DT6->(DT6_FILDOC+DT6_DOCDCO+DT6_SERDCO)
					EndIf
					
					// DTC -> DOC CLIENTE PARA TRANSPORTE
					lAchouDTC := SPEDSeek("DTC",3,xFilial("DTC")+cChaveSeek)
					
					// DT8 -> COMPOSICAO DE FRETE
					lAchouDT8 := SPEDSeek("DT8",2,xFilial("DT8")+cChaveSeek)
					
					// DT5 -> SOLICITACAO DE COLETA
					lAchouDT5 := SPEDSeek("DT5",4,xFilial("DT5")+cChaveSeek)
					
					If oFisaExtSx:_DUL_CODCLI
						/*
							Tabela DUL
								-> ENDERECOS DO SOLICITANTE
							Indice DUL
								-> 1 DUL_FILIAL+DUL_SEQEND
								-> 2 DUL_FILIAL+DUL_CODCLI+DUL_LOJCLI+DUL_SEQEND
								-> 3 DUL_FILIAL+DUL_CODSOL+DUL_SEQEND
						*/
						If lAchouDT5
							If lDT5Sol
								lAchouDUL := SPEDSeek("DUL",3,xFilial("DUL")+DT5->(DT5_CODSOL+DT5_SEQEND))
							Else
								lAchouDUL := SPEDSeek("DUL",1,xFilial("DUL")+DT5->DT5_SEQEND)
							EndIf

							If lAchouDUL
								cPartCol := DUL->DUL_CODCLI
							EndIf
						EndIf
						
						If lAchouDTC
							lAchou2DUL := SPEDSeek("DUL",2,xFilial("DUL")+DT6->(DT6_CLIDES+DT6_LOJDES)+DTC->DTC_SQEDES)

							If lAchou2DUL
								cPartEnt := DUL->DUL_CODCLI
							EndIf
						EndIf
					EndIf
					
					// DUD -> MOVIMENTO DE VIAGEM
					If lAchouDUD
						// DTQ -> VIAGEM
						lAchouDTQ := SpedSeek("DTQ",2,(xFilial("DTQ")+DUD->(DUD_FILORI+DUD_VIAGEM)))
						
						If lAchouDTQ
							// DTR -> VEICULOS DA VIAGEM
							lAchouDTR := SpedSeek("DTR",1,(xFilial("DTR")+DTQ->(DTQ_FILORI+DTQ_VIAGEM)))
							
							If lAchouDTR
								// DA3 -> VEICULOS
								lAchouDA3 := SpedSeek("DA3",1,(xFilial("DA3")+DTR->DTR_CODVEI))
								
								// Se nao encontrar com DTR_CODVEI Procura por DTR_CODRB1
								If !lAchouDA3
									lAchouDA3 := SpedSeek("DA3",1,(xFilial("DA3")+DTR->DTR_CODRB1))	   
								EndIf
							EndIf
						EndIf
					EndIf
					
				ElseIf SFT->FT_TIPOMOV == "E"
					/*
						Utilizo o aviso de recebimento do compras para obter 
						alguns dados do transporte na entrada
					*/
					
					// DB2 -> CABECALHO DOC DE RECEBIMENTO
					If SpedSeek("DB2",1,xFilial("DB2")+SFT->(FT_NFISCAL+FT_SERIE))
						// DB1 -> AVISO DE RECEBIMENTO DE CARGA
						If SpedSeek("DB1",1,xFilial("DB1")+DB2->DB2_NRAVRC)
							// DB3 -> ITENS DO DOC DE RECEBIMENTO
							If SpedSeek("DB3",1,xFilial("DB3")+DB2->(DB2_NRAVRC+DB2->DB2_ITEM))
								// DA3 -> VEICULOS
								lAchouDA3 := SpedSeek("DA3",1,xFilial("DA3")+DB1->DB1_IDVEI)
							EndIf
						EndIf
					EndIf
					If Empty(cDoctms)  
						Do Case
							Case SF1->F1_TPCTE == 'N' 
								cDoctms	:=	'0'
							Case SF1->F1_TPCTE == 'C' 
								cDoctms	:=	'1'
							Case SF1->F1_TPCTE == 'A'
								cDoctms	:=	'2' 
							Case SF1->F1_TPCTE == 'S' 
								cDoctms	:=	'3'
						EndCase
					Endif
					cFrtOrig := iif(!empty(SF1->F1_MUORITR),SF1->F1_UFORITR + SF1->F1_MUORITR,'')
					cFrtDest := iif(!empty(SF1->F1_MUDESTR),SF1->F1_UFDESTR + SF1->F1_MUDESTR,'')

				EndIf
				
				/*
					A chamada da funcao abaixo "SPLancCDA" obtem os lancamentos dos dos itens amarrado no   
					proprio documento  fiscal, atraves do TES ou manualmente.                               
					O array retornado por referencia, possui as informacoes dos lancamentos de todo o docu- 
					mento fiscal.
				*/
				// SPLancCDA(cAliasSFT,cFlag,aLanCDA,cMVEstado,lAchouCDT,cAliasCDT,cPartDoc,aLanCDA2,lOldLan,cEspecie,cProd,aInfE313,lDIfal,lExtratTaf,cAliasSF4,aInfE531)
				SPLancCDA("SFT","",@aLanCDA,cMVEstado,,,aPartDoc[1],@a_LanCDA2,,cEspecie,SFT->FT_PRODUTO,,.T.,.T. )

				// SF3 -> LIVROS FISCAIS
                SPEDSeek("SF3",1,xFilial("SF3")+SFT->(DToS(FT_ENTRADA)+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_CFOP+STR(FT_ALIQICM,5,2)))
                
                If SFT->FT_FORMUL == "S" .Or. Empty(SFT->FT_FORMUL)
                    cFormProp := "0"
                Else
                    cFormProp := "1"
                EndIf

                If SFT->FT_TIPO == "S" .And. !Empty(SFT->FT_CODISS)
                    lServico := .T.
                EndIf

				cCodObra   := ""
				cTpPropObr := ""

				If SFT->FT_TIPOMOV == "E"
					If !Empty(SF1->F1_TPCTE)
						cTpCTE := SF1->F1_TPCTE
					EndIf
						nValBrut := SF1->F1_VALBRUT
					If !lServico
						nValMerc := SF1->F1_VALMERC //Notas de serviço devem ter o campo C20_VLSERV preenchido e não o C20_VLMERC
					Else
						nValIss := SF1->F1_VALMERC
					EndIf
					cMenNota := SF1->F1_MENNOTA 
					cCodObra := SD1->D1_CNO
				Else
					nValBrut := SF2->F2_VALBRUT
					If !lServico
						nValMerc := SF2->F2_VALMERC
					Else
						nValIss := SF2->F2_VALMERC
					EndIf
					cMenNota := SF2->F2_MENNOTA
                    cCodObra := SF2->F2_CNO
           
               	EndIf
		
				If !Empty(cCodObra) .And. SON->(DbSeek(xFilial("SON")+cCodObra))
                       cTpPropObr := SON->ON_TPINSCR
                       cCodObra := If(cTpPropObr == '1',SON->ON_CGC,SON->ON_CNO)
                EndIf

				/*
					Se o campo FT_TAFKEY estiver vazio a nota pode ser gerada no arquivo ao usuário,
					caso contrário será somente considerada no processamento mas não será gerada no arquivo final
				*/
				If lTafKey
					lEmpTafKey := Empty(SFT->FT_TAFKEY)
				EndIf
				
				cChaveSFT := (cAliasPrin)->(TIPOMOV+SERIE+NFISCAL+CLIEFOR+LOJA)
				
				While (cAliasPrin)->(!Eof()) .And. cChaveSFT == (cAliasPrin)->(TIPOMOV+SERIE+NFISCAL+CLIEFOR+LOJA)
					// Se não for o primeiro item
					If !lFirstItem
						// Função para posicionar nas tabelas referente aos itens
						fPosTabItm((cAliasPrin)->TIPOMOV,(cAliasPrin)->RECSFT,(cAliasPrin)->RECITENS,(cAliasPrin)->RECSF4,(cAliasPrin)->RECSB1,(cAliasPrin)->RECSB5)
					EndIf

					// Se achou o SB5
					lAchouSB5 := !Empty((cAliasPrin)->RECSB5) .And. SB5->(!Eof())
					
					//Seta as variaveis com os valores iniciais
					nValorSt := 0
					cChv115 := ""
					cVol115 := ""
					
					/*
						Neste momento atualizo o array com o Codigo do Produto que esta sendo processado
					*/                                               
					For nCount := 1 To Len(aLanCDA)
						
						If aLanCDA[nCount][14] == SFT->FT_ITEM
							aLanCDA[nCount][13] := SFT->FT_PRODUTO
							
							If SFT->FT_TIPOMOV == "S"
								nEstcred := SD2->D2_ESTCRED
							Else
								nEstcred := SD1->D1_ESTCRED
							EndIf
							
							// Alimento array com informações complementares além da CDA
							Aadd(aInfoCompl,{nCount,SF4->F4_TRFICM,SF4->F4_ESTCRED,nEstcred})
						EndIf
					Next nCount

					For nCount := 1 To Len(a_LanCDA2)
						If Valtype(a_LanCDA2[nCount][16]) <> "D"
							a_LanCDA2[nCount][16] := StoD(a_LanCDA2[nCount][16])
						EndIf
						
						If a_LanCDA2[nCount][14] == SFT->FT_ITEM
							If SFT->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_ESPECIE+aPartDoc[1]) == a_LanCDA2[nCount][11]+a_LanCDA2[nCount][10]+a_LanCDA2[nCount][9]+a_LanCDA2[nCount][8]+a_LanCDA2[nCount][15]
								a_LanCDA2[nCount][13] := SFT->FT_PRODUTO
							EndIf
						EndIf
					Next nCount
					
					//Busco o Codigo IdentIficador do Tipo de Frete
					If lAchouDT6 .And. lIntTMS .And. SFT->FT_TIPOMOV == "S" .And. cEspecie $ "|07|08|09|10|11|26|27|57" 
						If !Empty(cOpSemF) .And. AllTrim(SFT->FT_CFOP) $ cOpSemF
							cFrete := "9"
						ElseIf DT6->DT6_DEVFRE $ "1"
							cFrete := IIf(lNewCFrt,"0","1")		// Por conta do emitente = CIf = 1
						ElseIf DT6->DT6_DEVFRE $ "2"
							cFrete := IIf(lNewCFrt,"1","2") 	// Por conta do destinatario = FOB = 2
						Else
							cFrete := IIf(lNewCFrt,"2","0")		// Apesar do sistema gravar 2=FOB, o devedor do frete pode ser o consignatario, espachante ou outros.
						EndIf
					Else
						If Empty(cFrete)
							If !Empty(cOpSemF) .And. AllTrim(SFT->FT_CFOP) $ cOpSemF
								cFrete := "9"
							Else
								// Utilizo a informacao configurada nos pedidos de venda/campra
								// SPEDSitFrt(cAliasSFT,cAlsSD,lTop,cAlsSF,cCpoFrete,lAchSFSD,lJOIN,lF1TpFrete)
								cFrete := SPEDSitFrt("SFT",IIf(SFT->FT_TIPOMOV == "S","SD2","SD1"),.T.,IIf(SFT->FT_TIPOMOV == "S","SF2","SF1"),cCpoFrete,,.F.,)		
							EndIf
						EndIf
						
						If lNewCFrt .And. lAchouCDT
							If Alltrim(cFrete) == "1"	// 0 - Por conta do emitente
								cFrete := "0"
							ElseIf Alltrim(cFrete)=="2"	// 1 - Por conta do destinatário/remetente
								cFrete := "1" 
							ElseIf Alltrim(cFrete)=="0"	// 2 - Por conta de terceiros
								cFrete := "2"
							EndIf
						EndIf
					EndIf

					/*
					Regra1) Necessario considerar a UF do cálculo no TMS.
					As regras com os campos de Remetente e Destinatário não definem as UFs que foram pagos o ICMS, 
					causando divergência na operação. O TMS possui um campo para definir esta operação 
					DT6_CDRCAL ( Codigo Regiao Calculo ). Através deste campo, precisamos fazer um seek na DUY
					e pegar o conteúdo do DUY_EST para esta região. Caso o DUY_EST seja igual ao MV_ESTADO, 
					iremos fazer a mesma busca, porém com a região informada no DT6_CDRORI ( Codigo Regiao Origem )

					Regra2) Tratamento de UF na nota referente ao TMS, o cliente possui um lançamento de nota fiscal de transporte,
					onde o transporte eh de responsabilidade do pagador do frete (FOB), mas o tratamento de UF
					nao deve levar em consideracao o Estado do pagador do frete e sim o do destinatario da mercadoria.
					No Protheus a opcao eh configuravel atraves do parametro MV_TMSUFPG com conteúdo F - Destinatário da Mercadoria.
					*/
					If lAchouDT6 .And. lIntTMS .And. SFT->FT_TIPOMOV == "S"
						lCdOri   := .F.
						cEstDUY  := ""
						aAreaDUY := {}

						if !Empty(DT6->DT6_CDRCAL) .Or. !Empty(DT6->DT6_CDRORI) //Regra1
							If Select("DUY") == 0
								DbSelectArea("DUY")
							EndIf
							aAreaDUY := DUY->(GetArea())
							if Upper(Alltrim( DUY->(IndexKey()))) <> "DUY_FILIAL+DUY_GRPVEN"
								DUY->(DbSetOrder(1)) //DUY_FILIAL, DUY_GRPVEN
							endif

							If DUY->(DbSeek(xFilial('DUY') + DT6->DT6_CDRCAL))
								if Upper(Alltrim(DUY->DUY_EST)) == Upper(Alltrim(cMVEstado))
									lCdOri := .T.
								else
									cEstDUY := Upper(Alltrim(DUY->DUY_EST))
								endif
							else
								lCdOri := .T.
							endif

							if lCdOri
								if DUY->(DbSeek(xFilial('DUY') + DT6->DT6_CDRORI))
									if Upper(Alltrim(DUY->DUY_EST)) <> Upper(Alltrim(cMVEstado))
										cEstDUY := Upper(Alltrim(DUY->DUY_EST))
									endif
								endif
							endif
							RestArea(aAreaDUY)

							if !Empty( cEstDUY )
								cNotaUF := cEstDUY
							endif
						endif

						if Empty(cEstDUY) .And. !lTmsUfPg //Regra2
							if SubStr(Alltrim(SFT->FT_CFOP),1,1)=="6"
								if Upper(Alltrim(cUFDes)) <> Upper(Alltrim(cMVEstado))
									cNotaUF := cUFDes //Destinatario
								else
									cNotaUF := cUFRem //Remetente
								endif
							endif
						endif
					endif

					aCmpAntSFT := {}

					Aadd(aCmpAntSFT,SFT->FT_NFISCAL)				// aCmpAntSFT[01] - Doc. Fiscal
					Aadd(aCmpAntSFT,SFT->FT_SERIE)					// aCmpAntSFT[02] - Serie NF
					Aadd(aCmpAntSFT,SFT->FT_CLIEFOR)				// aCmpAntSFT[03] - Cliente/Fornecedor
					Aadd(aCmpAntSFT,SFT->FT_LOJA)					// aCmpAntSFT[04] - Codigo Loja
					Aadd(aCmpAntSFT,SFT->FT_ENTRADA)				// aCmpAntSFT[05] - Data Docto.
					Aadd(aCmpAntSFT,SFT->FT_EMISSAO)				// aCmpAntSFT[06] - Data Emissao
					Aadd(aCmpAntSFT,SFT->FT_DTCANC)					// aCmpAntSFT[07] - Data Canc.
					Aadd(aCmpAntSFT,cFormProp)						// aCmpAntSFT[08] - Formulario Proprio
					Aadd(aCmpAntSFT,SFT->FT_CFOP)					// aCmpAntSFT[09] - CFOP
					Aadd(aCmpAntSFT,"")								// aCmpAntSFT[10] -
					Aadd(aCmpAntSFT,SFT->FT_ALIQICM)				// aCmpAntSFT[11] - Aliq. ICMS
					Aadd(aCmpAntSFT,SFT->FT_PDV)					// aCmpAntSFT[12] - Nro. PDV
					Aadd(aCmpAntSFT,SFT->FT_BASEICM)				// aCmpAntSFT[13] - Base  ICMS
					Aadd(aCmpAntSFT,SFT->FT_ALIQICM)				// aCmpAntSFT[14] - Aliq. ICMS
					Aadd(aCmpAntSFT,SFT->FT_VALICM)					// aCmpAntSFT[15] - Valor ICMS
					Aadd(aCmpAntSFT,SFT->FT_ISENICM)				// aCmpAntSFT[16] - Valor Isento ICMS
					Aadd(aCmpAntSFT,SFT->FT_OUTRICM)				// aCmpAntSFT[17] - Outros ICMS
					Aadd(aCmpAntSFT,SFT->FT_ICMSRET)				// aCmpAntSFT[18] - ICMS Retido ST
					Aadd(aCmpAntSFT,SFT->FT_CONTA)					// aCmpAntSFT[19] - Conta Contabil
					Aadd(aCmpAntSFT,cTipoDoc)						// aCmpAntSFT[20] - Tipo Lancamento
					Aadd(aCmpAntSFT,cFrete)							// aCmpAntSFT[21] - Tipo Frete
					Aadd(aCmpAntSFT,SFT->FT_FILIAL)					// aCmpAntSFT[22] - Filial
					Aadd(aCmpAntSFT,cNotaUF)						// aCmpAntSFT[23] - Estado
					Aadd(aCmpAntSFT,SFT->FT_OBSERV)					// aCmpAntSFT[24] - Observacao
					Aadd(aCmpAntSFT,SFT->FT_CHVNFE)					// aCmpAntSFT[25] - Chave NFE
					Aadd(aCmpAntSFT,cIndEmit)						// aCmpAntSFT[26] - Tipo Emissao
					Aadd(aCmpAntSFT,&(cCpoPrefix))					// aCmpAntSFT[27] - Prefixo
					Aadd(aCmpAntSFT,&(cCpoDupl))					// aCmpAntSFT[28] - Duplicata
					Aadd(aCmpAntSFT,&(cCpoNFCpm))					// aCmpAntSFT[29] - Cupom Fiscal
					Aadd(aCmpAntSFT,&(cCpoTrans))					// aCmpAntSFT[30] - Transportadora
					Aadd(aCmpAntSFT,&(cCpoPBruto))					// aCmpAntSFT[31] - Peso Bruto
					Aadd(aCmpAntSFT,&(cCpoPLiqui))					// aCmpAntSFT[32] - Peso Liquido
					Aadd(aCmpAntSFT,&(cCpoVeic1))					// aCmpAntSFT[33] - Veiculo1
					Aadd(aCmpAntSFT,&(cCpoVeic2))					// aCmpAntSFT[34] - Veiculo2
					Aadd(aCmpAntSFT,&(cCpoVeic3))					// aCmpAntSFT[35] - Veiculo3
					Aadd(aCmpAntSFT,&(cCpoSimpN))					// aCmpAntSFT[36] - Optante Simples Nacional
					Aadd(aCmpAntSFT,&(cCpoRegPB))					// aCmpAntSFT[37] - Regime Paraiba
					Aadd(aCmpAntSFT,SFT->FT_NFORI)					// aCmpAntSFT[38] - Nota Fiscal Original
					Aadd(aCmpAntSFT,SFT->FT_SERORI)					// aCmpAntSFT[39] - Serie da Nota fiscal original
					Aadd(aCmpAntSFT,cTpCTE)							// aCmpAntSFT[40] - Flag de tipo de CTE na entrada
					Aadd(aCmpAntSFT,"")								// aCmpAntSFT[41] -
					Aadd(aCmpAntSFT,SFT->FT_ESPECIE)				// aCmpAntSFT[42] - Especie do Docuemnto
					Aadd(aCmpAntSFT,SFT->FT_TIPOMOV)				// aCmpAntSFT[43] - Tipo Mov.
					Aadd(aCmpAntSFT,SFT->FT_ITEM)					// aCmpAntSFT[44] - Item
					Aadd(aCmpAntSFT,SFT->FT_PRODUTO)				// aCmpAntSFT[45] - Produto
					Aadd(aCmpAntSFT,SFT->FT_VALCONT)				// aCmpAntSFT[46] - Valor Contabil
					Aadd(aCmpAntSFT,SFT->FT_DESCONT)				// aCmpAntSFT[47] - Valor do Desconto
					Aadd(aCmpAntSFT,SFT->FT_TOTAL)					// aCmpAntSFT[48] - Total das Mercadorias
					Aadd(aCmpAntSFT,SFT->FT_DESPESA)				// aCmpAntSFT[49] - Despesas
					Aadd(aCmpAntSFT,SFT->FT_FRETE)					// aCmpAntSFT[50] - Frete
					Aadd(aCmpAntSFT,IIf(lAchouSB5,SB5->B5_CEME,""))	// aCmpAntSFT[51] - Descricao Complemento do Produto
					Aadd(aCmpAntSFT,nValBrut)						// aCmpAntSFT[52] - Valor total da nota;
					Aadd(aCmpAntSFT,nValMerc)						// aCmpAntSFT[53] - Valor total dos produtos
					Aadd(aCmpAntSFT,SF4->F4_MOVFIS)					// aCmpAntSFT[54] - Movimentacao Fisica
					Aadd(aCmpAntSFT,cNotaUF)						// aCmpAntSFT[55] - Estado Referencia

					If SFT->FT_TIPOMOV == "E" .And. (!(SF4->F4_LFIPI $ "T") .Or. SFT->FT_CREDST $ "3|4" ) .And. !SFT->FT_TIPO $ "DB"
						If !SF4->F4_LFIPI $ "T"
							aCmpAntSFT[48] += SD1->D1_VALIPI
						EndIf
						If SFT->FT_CREDST $ "3|4"
							aCmpAntSFT[48] += RetStSpd( lResF3FT , "SFT" )
						EndIf
					EndIf
					/*
						Para utilizar a funcao Padrao do Protheus SpedProSE2/SE1 deve-se passar                  
						o Array aCmpAntSFT na estrutura conforme foi montada, devido a isso este tratamento      
						esta dentro do laco de Item da NF, porem para que o Seek na tabela SE1/SE2 seja realizado
						apenas uma vez por NF, verIfico a variavel lFirstItem
					*/                                        
					If lFirstItem
						cIndPgto := "2"	
					EndIf
					
					// CD6 -> COMPLEMENTO DE COMBUSTIVEIS
					
					If lAchouCD6
						nRecnoCD6 := CD6->(Recno())
					EndIf
					
					// SFX -> COMPLEMENTO DE COMUN/TELECOM
					lAchouSFX := SPEDSeek("SFX",1,xFilial("SFX")+SFT->(FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO))
					
					If lAchouSFX
						nRecnoSFX := SFX->(Recno())
					EndIf
					
					If oFisaExtSx:_CDG
						// CDG -> PROCESSOS REFER. NO DOCUMENTO
						lAchouCDG := lInd3CDG .And. SPEDSeek("CDG",3,xFilial("CDG")+SFT->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ITEM))

						If lAchouCDG
							nRecnoCDG := CDG->(Recno())
						EndIf
					EndIf

					If lFltRnf013 .And. (cFltInt013 $ "1|3" .Or. empty(cFltInt013))
						RegT007Pos(lAchouSB5, lAchouCD6, @aProdutos)
					EndIf

					/*
						Neste momento, caso exista o complemento para o item que esta          
						sendo processado eu realizo a gravao do valor se dervico NT, necessario
						para geracao do registro T013AN
					*/                                        
					If lAchouCD3 .Or. lAchouSFU
						/*
							Para geracao do registro T013AN ( Complemento do Documento Fiscal modelo        
							06, 28 e 29 ), caso existam informacoes em uma das 3 tabela ( CD3 / SFU  )      
							tenho que realizar a emissao do registro, ou seja, se para uma nota de 100 itens
							apenas 1 tiver o complemento mesmo assim deve ser gerado o registro, devido a   
							isso eh realizado o tratamento abaixo, onde a variavel lGerT013AN indica se     
							o REG sera gerado ou nao ao final do processamento da Nota Fiscal
						*/               
						lGerT013AN := .T.
						
						Aadd(aRegT013AN,{})
						nPosicao := Len(aRegT013AN)

						Aadd(aRegT013AN[nPosicao],SFT->FT_ITEM)
						Aadd(aRegT013AN[nPosicao],SFT->(FT_ISENICM+FT_OUTRICM))
							
						If lAchouCD3
							Aadd(aRegT013AN[nPosicao],CD3->CD3_CLASCON)
							Aadd(aRegT013AN[nPosicao],"")
							Aadd(aRegT013AN[nPosicao],"")
							Aadd(aRegT013AN[nPosicao],CD3->CD3_VLTERC)
							Aadd(aRegT013AN[nPosicao],0)
							Aadd(aRegT013AN[nPosicao],0)
						Else
							cCodTensao := FDeParaTAF("SFU_GRUPT",{SFU->FU_GRUPT})
							
							If SFU->FU_VLFORN > 0
								nVlrForn := SFU->FU_VLFORN
							Else
								nVlrForn := aCmpAntSFT[48]
							EndIf
							
							Aadd(aRegT013AN[nPosicao],IIf(oFisaExtSx:_FU_CLASCON,SFU->FU_CLASCON,""))
							Aadd(aRegT013AN[nPosicao],SFU->FU_TIPLIGA)
							Aadd(aRegT013AN[nPosicao],cCodTensao)
							Aadd(aRegT013AN[nPosicao],SFU->FU_VALTERC)
							Aadd(aRegT013AN[nPosicao],SFU->FU_CONSTOT)
							Aadd(aRegT013AN[nPosicao],nVlrForn)
						EndIf
					EndIf
					
					If cEspecie $ "28"	// VerIfica se Eh uma NF de GAS
						If lAchouCD3
							cChv115 := CD3->CD3_CHV115
							cVol115 := CD3->CD3_VOL115
						EndIf
					Else				// VerIfica se Eh uma NF de Energia Eletrica
						If lAchouSFU
							cChv115 := SFU->FU_CHV115
							cVol115 := SFU->FU_VOL115
						EndIf
					EndIf
					
					// Adaptando o código de frete de acordo com o layout do extrator fiscal
					If cSituaDoc $ "02#03"
						cIndFrt := ""
					ElseIf AllTrim(cFrete) == "0"
						cIndFrt := "1"
					ElseIf AllTrim(cFrete) == "1"
						cIndFrt := "2"
					ElseIf AllTrim(cFrete) == "2"
						cIndFrt := "0"
					Else
						cIndFrt := cFrete
					EndIf
					
					//VerIfica se esta no primeiro item da NF, se sim alimento o array com as informacoes da NF 
					If lFirstItem
						lGerou := .T.
						lFirstItem := .F.
						
						// Zera o contador de itens da NF. - Variavel utilizada no ExtT015
						cSomaItem := replicate("0",nTamItem)
						cTipoPart := ""
						cCodIss := SFT->FT_CODISS
						
						/*
							Em caso de devolução ou beneficiamento as notas de entrada são de clientes e não fornecedores
							E nas notas de saída ocorre o processo inverso.
						*/
						
						// Devolução ou beneficiamento
						If SFT->FT_TIPO $ "DB"
							If SFT->FT_TIPOMOV == "E"
								cTipoPart := "C"
							Else
								cTipoPart := "F"
							EndIf
						Else
							If SFT->FT_TIPOMOV == "E"
								cTipoPart := "F"
							Else
								cTipoPart := "C"
							EndIf							
						EndIf
						
						//Se a extração foi chamada da GIA-SP
						if lExtGia 
							cQryIns := " INSERT INTO " + cTblTemp + " (FILIAL, CODMOD, INDOPE, TPDOC, INDEMI, CODPAR, CODSIT, SERIE, SUBSER, NUMDOC, DTDOC, DTES) VALUES "
							cQryIns += "(" 
							cQryIns += 		"'" + cFilAnt  + "',"
							cQryIns +=		"'" + cEspecie + "',"
							cQryIns +=		"'" + iif(SFT->FT_TIPOMOV == "E","0","1") + "',"
							cQryIns +=		"'" + cTipoDoc + "',"
							cQryIns +=		"'" + cIndEmit + "',"
							cQryIns +=		"'" + cTipoPart + SFT->(FT_CLIEFOR+FT_LOJA) + "',"
							cQryIns +=		"'" + cSituaDoc + "',"
							cQryIns +=		"'" + SFT->FT_SERIE + "',"
							cQryIns +=		"'" + "" + "',"
							cQryIns +=		"'" + cNFiscal + "',"
							cQryIns +=		"'" + dtos(SFT->FT_EMISSAO) + "',"
							cQryIns +=		"'" + dtos(SFT->FT_EMISSAO) + "'"
							cQryIns += ")"
							TCSqlExec( cQryIns )
						endif
						
						// T013-CADASTRO DE DOCUMENTOS FISCAIS
						aRegT013 := {}
						Aadd(aRegT013,{})
						nPosicao := Len(aRegT013)

						Aadd(aRegT013[nPosicao],"T013")										// 01 REGISTRO
						Aadd(aRegT013[nPosicao],IIf(SFT->FT_TIPOMOV == "E","0","1"))		// 02 IND_OPER
						Aadd(aRegT013[nPosicao],cTipoDoc)									// 03 TIPODOC
						Aadd(aRegT013[nPosicao],cIndEmit)									// 04 IND_EMIT
						Aadd(aRegT013[nPosicao],cTipoPart + SFT->(FT_CLIEFOR+FT_LOJA))		// 05 COD_PART
						Aadd(aRegT013[nPosicao],cSituaDoc)									// 06 COD_SIT
						Aadd(aRegT013[nPosicao],SFT->FT_SERIE)								// 07 SER
						Aadd(aRegT013[nPosicao],"")											// 08 SUB
						Aadd(aRegT013[nPosicao],cNFiscal)									// 09 NUM_DOC
						Aadd(aRegT013[nPosicao],SFT->FT_EMISSAO)							// 10 DT_DOC
						Aadd(aRegT013[nPosicao],SFT->FT_CHVNFE)								// 11 CHV_DOC_E
						Aadd(aRegT013[nPosicao],Val2Str(nValBrut,16,2))						// 12 VLDOC
						Aadd(aRegT013[nPosicao],cIndPgto)									// 13 IND_PGTO
						Aadd(aRegT013[nPosicao],Val2Str(SFT->FT_DESCONT,16,2))				// 14 VL_DESC
						Aadd(aRegT013[nPosicao],cEspecie)									// 15 COD_MOD
						Aadd(aRegT013[nPosicao],cNFiscal)									// 16 NUM_DOC_FIN
						Aadd(aRegT013[nPosicao],SFT->FT_CONTA)								// 17 COD_CTA
						Aadd(aRegT013[nPosicao],Val2Str(nValMerc,16,2))						// 18 VLMERC
						Aadd(aRegT013[nPosicao],SFT->FT_ENTRADA)							// 19 DT_E_S
						Aadd(aRegT013[nPosicao],Val2Str(SFT->FT_DESPESA,16,2))				// 20 VL_DA
						Aadd(aRegT013[nPosicao],cVol115)									// 21 NOM_EST
						Aadd(aRegT013[nPosicao],cChv115)									// 22 CHV_COD_DIG
						Aadd(aRegT013[nPosicao],cDoctms)									// 23 TP_CT-e
						Aadd(aRegT013[nPosicao],"")											// 24 CHV_DOCE_REF
						Aadd(aRegT013[nPosicao],cIndFrt)									// 25 IND_FRT
						Aadd(aRegT013[nPosicao],Val2Str(0,16,2))							// 26 VL_SEG
						Aadd(aRegT013[nPosicao],Val2Str(0,16,2))							// 27 VL_OUT_DESP
						Aadd(aRegT013[nPosicao],Val2Str(SFT->FT_FRETE,16,2))				// 28 VL_FRT
						Aadd(aRegT013[nPosicao],SFT->FT_INDNTFR)							// 29 IND_NAT_FRT
						Aadd(aRegT013[nPosicao],Val2Str(0,16,2))							// 30 VL_ABAT_INT
						Aadd(aRegT013[nPosicao],"")											// 31 NUM_ABAT
						Aadd(aRegT013[nPosicao],"")											// 32 COD_MOD_RM
						Aadd(aRegT013[nPosicao],"")											// 33 SER_RMD
						Aadd(aRegT013[nPosicao],"")											// 34 SUB_RMD
						Aadd(aRegT013[nPosicao],"")											// 35 NUM_DOC_RMD
						Aadd(aRegT013[nPosicao],"")											// 36 DT_DOC_RMD
						Aadd(aRegT013[nPosicao],"")											// 37 COD_PART_RMD
						Aadd(aRegT013[nPosicao],Val2Str(nValIss,16,2))						// 38 VLSERV
						Aadd(aRegT013[nPosicao],"")											// 39 HR_SAI_ENT
						Aadd(aRegT013[nPosicao],"")											// 40 BASEII
						Aadd(aRegT013[nPosicao],"")											// 41 IMP_IMPOR
						Aadd(aRegT013[nPosicao],"")											// 42 VLR_ADU
						Aadd(aRegT013[nPosicao],"")											// 43 VLR_IOF
						Aadd(aRegT013[nPosicao],"")											// 44 QTD_VOL
						Aadd(aRegT013[nPosicao],"")											// 45 ESP_VOL
						Aadd(aRegT013[nPosicao],"")											// 46 MARCA
						Aadd(aRegT013[nPosicao],"")											// 47 NUM_VOL
						Aadd(aRegT013[nPosicao],"")											// 48 PES_LIQ
						Aadd(aRegT013[nPosicao],"")											// 49 PES_BRT
						Aadd(aRegT013[nPosicao],"")											// 50 LACRES
						Aadd(aRegT013[nPosicao],"")											// 51 NOT_EMP
						Aadd(aRegT013[nPosicao],"")											// 52 PEDIDO
						Aadd(aRegT013[nPosicao],"")											// 53 CONTRA
						Aadd(aRegT013[nPosicao],"")											// 54 INF_ADI_CLI
						Aadd(aRegT013[nPosicao],"")											// 55 INF_ADI_FIS
						Aadd(aRegT013[nPosicao],DToS(SFT->FT_DTCANC))						// 56 DT_CANC
						Aadd(aRegT013[nPosicao],"")											// 57 HR_AUT_NFE
						Aadd(aRegT013[nPosicao],"")											// 58 DT_AUT_NFE
						Aadd(aRegT013[nPosicao],"")											// 59 NOTA_IMP
						Aadd(aRegT013[nPosicao],"")											// 60 PROTOC_NFE
						Aadd(aRegT013[nPosicao],"")											// 61 DT_EXTEMP
						Aadd(aRegT013[nPosicao],"")											// 62 LOC_PRESTACAO
						Aadd(aRegT013[nPosicao],"")											// 63 VL_DED_ISS_MAT
						Aadd(aRegT013[nPosicao],"")											// 64 VL_DED_ISS_SUBEM
						Aadd(aRegT013[nPosicao],cCodObra)									// 65 COD_OBRA
						Aadd(aRegT013[nPosicao],"")											// 66 MODAL_TRANSP
						Aadd(aRegT013[nPosicao],cFrtOrig)									// 67  
						Aadd(aRegT013[nPosicao],cFrtDest)									// 68
						Aadd(aRegT013[nPosicao],cNotaUF)									// 69
						Aadd(aRegT013[nPosicao],cTpPropObr) 								// 70 Tipo Inscrição do estabelecimento da obra 1=Juridico/2=Fisico
						
						//Para documento de saida, pois se trata de AIDF vide Guia Pratico EFD
						If SFT->FT_TIPOMOV == "S" 
							if aWizard[_SEL_T012_]  
								GETGLBVARS( '_aRegT012AA', @aRegT012AA )
								RegT012(aRegT013,@aRegT012,@aRegT012AA,cSituaDoc,cEspecie)
								PUTGLBVARS( '_aRegT012AA', aRegT012AA )								
							endif
							
							If !Empty(aRegT012) .And. !Empty(aRegT012[1][3])
								aRegT013[1][31] := aRegT012[1][3]
							EndIf
						EndIf			
					Else
						
						/*
							Embora sejam campos de cadastro pode ser que existam informacoes        
							dIferentes para cada item da NF, sendo assim, sempre levo para o arquivo
							a informacao no Ultimo Item
						*/                                             
						aRegT013[1][13] := cIndPgto
						aRegT013[1][21] := cVol115
						aRegT013[1][22] := cChv115
						aRegT013[1][23] := cDoctms
						aRegT013[1][25] := cIndFrt
					EndIf
					
					// Soma o valor do abatimento não tributado - VL_ABAT_INT
					nVlrAbatNt += SFT->(FT_DESCICM+FT_DESCZFR)
					If (Empty(SFT->FT_DTCANC) .And. !(SFT->FT_OBSERV$'CANCELAD'))
					//Gerandos os Itens do Documento Fiscal e seus respectivos filhos
						FGrvItemNF(aPartDoc,SFT->FT_TIPOMOV,lAchouCD7,lAchouCD8,lAchouCD9,lAchouCDG,lAchouSFU,lAchouCD0,lAchouCD6,lAchouSFX,lAchouDT6,lAchouDA3,lAchouSB5,cEspecie,;
									@aRegT015,@aRegT015AB,@aRegT015AC,@aRegT015AD,@aRegT015AF,@aRegT015AG,@aRegT015AH,@aRegT015AI,cTipoDoc,cMV_RE,@aRegT015AK,aWizard[_APUR_IPI_],lINDISEN,oHashTMSM, lHashTMS,aTamQtd)
					Endif 
					// Buscando a CST dos tributos
					// SPDRetCCST(cAliasSFT,lAchouSF4,cEspecie,cAliasSF4,cAliasSB1,cPartEst)
					aClasFis := SPDRetCCST("SFT",.T.,cEspecie,"SF4","SB1",aPartDoc[02])
					
					// Tratamento para que seja considerado apenas a ClassIficacao Fiscal sem a Origem do Produto
					If Len(AllTrim(aClasFis[1])) == 3
						aClasFis[1] := SubStr(aClasFis[1],2,2)
						
						// Atualizo o registro T015 com o código de origem do produto de acordo com o retorno da função SPDRetCCST
						If Len(aRegT015)>0
							If Empty(aRegT015[Len(aRegT015)][1][28])  
								aRegT015[Len(aRegT015)][1][28] := SubStr(aClasFis[1],1,1)
							EndIf	
						Endif
					EndIf
					
					/*
						Função para buscar os tributos da nota fiscal
						FBusTribNf(c_Especie,a_PartDoc,a_RgT013AP,a_RgT015AE,n_ItT015,a_RgT078AF,n_ItT078AE,a_RgT080AC,n_ItT080,n_ItT080AA,n_ItT080AB,a_ClasFis,n_RecnoCDG)
					*/
					if FNewMtoFis()
						FBusTribNf(cEspecie,aPartDoc,@aRegT013AP,@aRegT015AE,Len(aRegT015),,,,,,,@aClasFis,nRecnoCDG,(cAliasPrin)->FILIAL,(cAliasPrin)->FT_IDTRIB,cNotaUF,cMVSUBTRIB, cMV_DifTr)
					else
						FBusTribNf(cEspecie,aPartDoc,@aRegT013AP,@aRegT015AE,Len(aRegT015),,,,,,,@aClasFis,nRecnoCDG,/*(cAliasPrin)->FILIAL*/,/*(cAliasPrin)->FT_IDTRIB*/,cNotaUF,cMVSUBTRIB, cMV_DifTr)
					endif

					//Apuracao de ICMS ST
					If SFT->FT_TIPO <> "S"
						
						If (SFT->FT_TIPOMOV == "S" .And. (Empty(cMv_StUfS) .Or. cNotaUF $ cMv_StUfS .Or. Empty(cMv_StUf) .Or. cNotaUF $ cMv_StUf)) .Or.;
							(SFT->FT_TIPOMOV == "E" .And. (Empty(cMv_StUf) .Or. cNotaUF $ cMv_StUf) .And. SFT->FT_TIPO == "D") // Credito por entrada (devolucoes)
							
							If SFT->FT_CREDST <> "4"
								If lResF3FT
									//Na tabela SFT o valor de ICMS Retido pode alternar nas colunas dependendo da escrituracao
									nValorST := SFT->(FT_ICMSRET+FT_OUTRRET+FT_ISENRET)
									nValorST := IIf(nValorST > 0,nValorST,SFT->FT_OBSSOL)
								Else
									//Na tabela SF3 o valor do ICMS Retido sempre eh gravado em ICMSRET, independente da escrituracao
									nValorST := SFT->FT_ICMSRET
									nValorST := IIf(nValorST > 0,nValorST,SFT->FT_OBSSOL)
								EndIf
							EndIf
							
						ElseIf SFT->FT_TIPOMOV == "E" .And. cNotaUF==cMVEstado .And. SFT->FT_CREDST <> "3"
							
							If SFT->FT_SOLTRIB > 0
								nValorST := SFT->FT_SOLTRIB
							Else
								If lResF3FT
									//Na tabela SFT o valor de ICMS Retido pode alternar nas colunas dependendo da escrituracao
									nValorST := SFT->(FT_ICMSRET+FT_OUTRRET+FT_ISENRET)
									nValorST := IIf(nValorST > 0,nValorST,SFT->FT_OBSSOL)
								Else
									//Na tabela SF3 o valor do ICMS Retido sempre eh gravado em ICMSRET, independente da escrituracao
									nValorST := SFT->FT_ICMSRET
									nValorST := IIf(nValorST > 0,nValorST,SFT->FT_OBSSOL)
								EndIf
							EndIf
						EndIf
						
						If SFT->FT_TIPO == "D" .And. !cNotaUF == cMVEstado .And. !cNotaUF $ cMVSUBTRIB
							If SFT->FT_TIPOMOV == "E" .And. AllTrim(SFT->FT_CFOP) $ cMVCFE210 .And. !(cMVEstado+cNotaUF $ AllTrim(oFisaExtSx:_MV_STNIEUF)) .Or. SFT->FT_TIPOMOV == "S"
								nValorST := 0
							EndIf
						EndIf
						
					EndIf
					
					If nValorST > 0 .And. !(cSituaDoc $ "02/04/05/03") .And. !Empty(UfCodIBGE(cNotaUF))
						SpedApDoc(SFT->FT_TIPOMOV,cMv_StUfS,cMv_StUf,lResF3FT,"SFT",.T.,.T.,aCmpAntSFT,cMVEstado,@a_VlrMovST)
					EndIf
					
					If cEspecie$"01#1B#04#55#65" .And. !cSituaDoc$"02#04#05"
						aAreaCDC := CDC->(GetArea())
						
						cChaveCDC := xFilial("CDC")+SFT->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA)
						lAchouCDC := SpedSeek("CDC",1,cChaveCDC)
						
						While CDC->(!Eof()) .And. CDC->(CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA) == cChaveCDC
							
							//Tratamento para quando a Nf tem mais de um item e as guias(GNREs de ICMS/ST) são geradas por produto.
							lAdicGuia := aScan( a_IcmPago, { |x|  x[1]+x[3] == CDC->(CDC_UF+CDC_GUIA) } ) = 0
							
							/*
								Tratamento para adicionar em um array as GNREs de ICMS/ST geradas por         
								documento fiscal para gerar depois as respectivas informacoes no registro E250
							*/
							If SpedSeek("SF6",1,xFilial("SF6")+CDC->(CDC_UF+CDC_GUIA)) .and. lAdicGuia
								Aadd(a_IcmPago,{})
								nPosicao := Len(a_IcmPago)
								
								Aadd(a_IcmPago[nPosicao],CDC->CDC_UF)		// 01
								Aadd(a_IcmPago[nPosicao],SF6->F6_VALOR)		// 02
								Aadd(a_IcmPago[nPosicao],CDC->CDC_GUIA)		// 03
								Aadd(a_IcmPago[nPosicao],SF6->F6_DTVENC)	// 04
								Aadd(a_IcmPago[nPosicao],SF6->F6_CODREC)	// 05
								Aadd(a_IcmPago[nPosicao],SF6->F6_OBSERV)	// 06
								Aadd(a_IcmPago[nPosicao],SF6->F6_MESREF)	// 07
								Aadd(a_IcmPago[nPosicao],SF6->F6_ANOREF)	// 08
								Aadd(a_IcmPago[nPosicao],SF6->F6_NUMPROC)	// 09
								Aadd(a_IcmPago[nPosicao],SF6->F6_INDPROC)	// 10
								Aadd(a_IcmPago[nPosicao],SF6->F6_DESCOMP)	// 11
								Aadd(a_IcmPago[nPosicao],SF6->F6_TIPOIMP)	// 12
							EndIf
							
							CDC->(DbSkip())
						EndDo
						
						RestArea(aAreaCDC)
					EndIf
					
					If !(cSituaDoc $ "02#04#05#03") .And. cEspecie $ "2D#01#1B#04#55" .And. Empty(SFT->FT_CODISS)
						RegE510("SFT",@a_RgT022AB,cSituaDoc,aClasFis,"",cAliasPrin)
					EndIf
					
					(cAliasPrin)->(DbSkip())
				EndDo
				
				// Adiciona o valor do abatimento não tributado - VL_ABAT_INT
				aRegT013[1][30] := Val2Str(nVlrAbatNt,16,2)
				
				/*
					Caso não exista o campo FT_TAFKEY sigo o modelo anterior de integração, caso contrário verIfico se a nota esta com o campo
					FT_TAFKEY em branco e o cliente tenha selecionado o registro T013 na wizard de geração
				*/
				If !lTafKey .Or. (lEmpTafKey .And. aWizard[_SEL_T013_])
					// Neste Momento Realizo a Geracao do Registro no Arquivo Texto e chamo a geracao dos registros filhos
					FConcTxt(aRegT013,nHdlTxt)
					
					// Se tiver a chave da CDC
					If !Empty(cChaveCDC)
						// Posiciona novamente
						lAchouCDC := SpedSeek("CDC",1,cChaveCDC)
					EndIf
					
					If lAchouCDT .And. cEspecie $ "01|1B|04|55"
						// Cadastro de Informações Complementares de Documentos Fiscais(Modelos 01, 1B e 55)
						RegT013AA(nHdlTxt,lAchouCDT,lAchouCDC,cEntSai,cSituaDoc,cFormProp,cFormula,cMenNota)
					EndIf
					
					If lAchouCDG .And. cEspecie $ "08|8B|09|10|11|26|27"
						// Cadastro de Processos Referenciados por Documento Fiscal
						RegT013AX(nHdlTxt)
					EndIf
					 
					If lAchouCD5
						// Cadastro de Operações de Importação
						RegT013AC(nHdlTxt,cEspecie,aCmpAntSFT)
					EndIf
					
					If lAchouCDC .and. !lFltRnf013 //Não extrair o layout T013AE quando Filtra REINF = Sim, pois o T001AE não será mais extraído.
						// Cadastro de Documento de Arrecadação referenciado
						RegT013AE(nHdlTxt)
					EndIf
					
					If lAchouCDD
						// Cadastro de Documento Fiscal Referenciado
						RegT013AF(nHdlTxt,cEntSai,aCmpAntSFT)
					EndIf

					If lAchouCDF .And. cEspecie $ "01|1B|04"
						// Cadastro de Coleta e/ou Entrega( Modelos 01, 1B e 04 )
						RegT013AH(nHdlTxt,aCmpAntSFT,@aParticip,lFltRnf013)
					EndIf
				
					
					If !Empty(aLanCDA) .And. cEspecie $ "01|1B|04|55"
						// Outras obrigacoes tributarias, ajustes e informacoes de valores provenientes dos documentos fiscais.
						RegT013AM(nHdlTxt,aLanCDA,aCmpAntSFT[06],aInfoCompl,cEntSai)
					EndIf
		
					If lGerT013AN
						// Complemento do Documento Fiscal( Modelos 06, 28 e 29 )
						RegT013AN(nHdlTxt,cEspecie,lAchouCD4,aRegT013AN)
					EndIf
					
					If lIntTMS .And. lAchouDT8 .And. cEspecie $ "08|8B|26" .And. cEntSai <> "E"
						// Complemento do Documento Fiscal - Modelos 08, 8B e 26
						RegT013AO(nHdlTxt,lAchouDA3,lAchouDT8,aPartREM,aPartDes,aPartCON,aPartDPC)
					EndIf
					 
					If !Empty(aRegT013AP)
						FConcTxt(aRegT013AP,nHdlTxt)
					EndIf
		
					If lAchouDT6 .And. cEspecie $ "08|8B|09|10|11|26|27"
						// Local de coleta/Entrega - Modelos 08, 8B, 09, 10, 11, 26 e 27
						RegT013AQ(nHdlTxt,aPartREM,aPartDES,lAchouDT5,lAchou2DUL,lAchouDUL,cEspecie)
						
						If lAchouDTC
							// Complemento do Documento Fiscal – Modelos 08, 8B, 09, 10, 11, 26 e 27
							RegT013AW(nHdlTxt)
						EndIf
					EndIf
					
					If !Empty(nRecnoSFX)
						If SpedSeek("SFX",,,nRecnoSFX)
							// Complemento do Documento Fiscal - Modelos 21 e 22
							RegT013AR(nHdlTxt,aCmpAntSFT)
						EndIf
					EndIf
					
					If cEspecie $ "02|13|14|15|16" .And. cSituaDoc == "02"
						// Complemento do Documento Fiscal - Documentos Cancelados (Modelos 02, 13, 14, 15 E 16)
						RegT013AT(nHdlTxt,aCmpAntSFT)
					EndIf
					
					If lIntTMS .And. cEspecie == "09" .And. cEntSai <> "E"
						// Complemento do Documento Fiscal - Modelo 09
						RegT013AU(nHdlTxt,aPartREM,aPartDes,aPartCON,lAchouDA3,lAchouDT8,lAchouDUD)
					EndIf
					
					If lIntTMS .And. cEspecie == "10" .And. cEntSai <> "E"
						// Complemento do Documento Fiscal - Modelo 10
						RegT013AV(nHdlTxt,aPartREM,aPartDes,lAchouDA3,lAchouDT8,lAchouDUD)
					EndIf

					If !Empty(aRegT015)
						// Cadastro dos Itens dos Documentos Fiscais
						RegT015(nHdlTxt,aRegT015,aRegT015AB,aRegT015AC,aRegT015AD,aRegT015AE,aRegT015AF,aRegT015AG,aRegT015AH,aRegT015AI,aRegT015AK)
					EndIf
			
					//Grava o registro na TABELA TAFST1 e limpa o array aDadosST1. 
					If cTpSaida == "2"
						FConcST1(cAlsTAFST,cNFisOri)
					EndIf
				EndIf				
			EndDo
			
			// Fecha o alias da query.
			(cAliasPrin)->(DbCloseArea())
			if lBuild .And. lHashTMS
				FreeObj(oHashTMSM)
				oHashTMSM := NIL
			Endif
			//Gravação dos registros T012 e T012AA
			//Dispositivos AIDF
			If aWizard[_SEL_T012_]
				GetGlbVars('_aRegT012AA',aRegT012AA)
				RegT012R(aRegT012,aRegT012AA)
			EndIf
		
			//Libero Handle do Arquivo T013
			If cTpSaida == "1" 
				FClose(nHdlTxt)
			EndIf 
			
            // Se for saída e a tabela do TAF foi aberta aqui.
			If cTpSaida == "2" .And. lOpenTAFST
				(cAlsTAFST)->(dbCloseArea())
			EndIf
		EndIf
	
		//Caso seja processamento em multi thread inicio as variaveis globais 
		If lMultThr
			//Status 4 - Em processamento
			PutGlbValue(cJobAux,"4")
			GlbUnLock()
		EndIf

	Recover
		
		// Status 9 - Indico Que ocorreu Erro no processamento
		ErrorBlock(oError)

		//Caso seja processamento em multi thread inicio as variaveis globais 
		If lMultThr
			PutGlbValue(cJobAux,"9")
			GlbUnlock()
		EndIf
		
	End Sequence  
	
	//Caso seja processamento em multi thread inicio as variaveis globais 
	If lMultThr
		PutGlbValue(cJobAux + "_GEROU",IIf(lGerou,"1","0"))
		GlbUnlock()
	EndIf

	TAFCONOUT(cTafJobMsg + "Thread( " + AllTrim(Str(ThreadID())) + " ) - Emp: " + cEmpAnt + ", Fil: " + cFilAnt + " - Processamento finalizado, aguardando...")
	TcInternal(1,"Thread( " + AllTrim(Str(ThreadID())) + " ) - " + ConType() + " - Processamento finalizado, aguardando...")
	
	// Função para fechar as tabelas que foram utilizadas.
	fTables(.F.)
	
	// Volta a primeira area
	RestArea(aArea)
	
Return lGerou

/*/{Protheus.doc} fTables
Função para abrir e fechar as tabelas utilizadas pela programa.

@author Vitor Ribeiro
@since 22/01/2018

@param l_Open, logico, .T. Abre as tabelas, .F. Fecha as tabelas.

@return nulo, não tem retorno
/*/
Static Function fTables(l_Open)
	
	Local aTables := {}
	
	Local nCount := 0
	
	Default l_Open := .T.
	
	// CLIENTES
	// A1_FILIAL+A1_COD+A1_LOJA
	Aadd(aTables,{"SA1",1})
	
	// INF. COMPLEMENTARES POR NF
	// CDT_FILIAL+CDT_TPMOV+CDT_DOC+CDT_SERIE+CDT_CLIFOR+CDT_LOJA+CDT_IfCOMP
	Aadd(aTables,{"CDT",1})
	
	If oFisaExtSx:_CDG
		// PROCESSOS REFER. NO DOCUMENTO
		// CDG_FILIAL+CDG_TPMOV+CDG_DOC+CDG_SERIE+CDG_CLIFOR+CDG_LOJA+CDG_ITEM
		Aadd(aTables,{"CDG",3})
	EndIf
	
	// GUIAS RECOLHIMENTO REFERENC.
	// CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF
	Aadd(aTables,{"CDC",1})
	
	// DOCUMENTOS REFERENCIADOS
	// CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF
	Aadd(aTables,{"CDD",1})
	
	// CUPOM FISCAL REFERENCIADO
	// CDE_FILIAL+CDE_TPMOV+CDE_DOC+CDE_SERIE+CDE_CLIFOR+CDE_LOJA+CDE_CPREF+CDE_SERREF+CDE_PARREF+CDE_LOJREF
	Aadd(aTables,{"CDE",1})
	
	// LOCAIS REFERENCIADOS
	// CDF_FILIAL+CDF_TPMOV+CDF_DOC+CDF_SERIE+CDF_CLIFOR+CDF_LOJA+CDF_ENTREG+CDF_LOJENT
	Aadd(aTables,{"CDF",1})
	
	// COMPLEMENTO DE AGUA CANALIZADA
	// CD4_FILIAL+CD4_TPMOV+CD4_SERIE+CD4_DOC+CD4_CLIFOR+CD4_LOJA+CD4_ITEM+CD4_COD
	Aadd(aTables,{"CD4",1})
	
	// COMPLEMENTO DE IMPORTACAO
	// CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+CD5_NADIC
	Aadd(aTables,{"CD5",1})
	
	// LANCAMENTOS APURACAO DO ICMS
	// CC6_FILIAL+CC6_CODLAN
	Aadd(aTables,{"CC6",1})
	
	// DOCUMENTOS DE TRANSPORTE
	// DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
	Aadd(aTables,{"DT6",1})
	
	// MOVIMENTO DE VIAGEM
	// DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
	Aadd(aTables,{"DUD",1})
	
	// DOC CLIENTE PARA TRANSPORTE
	// DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
	Aadd(aTables,{"DTC",3})
	
	// COMPOSICAO DE FRETE
	// DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS
	Aadd(aTables,{"DT8",2})
	
	// SOLICITACAO DE COLETA
	// DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
	Aadd(aTables,{"DT5",4})
	
	// ENDERECOS DO SOLICITANTE
	// DUL_FILIAL+DUL_SEQEND
	Aadd(aTables,{"DUL",1})
	
	// VIAGEM 
	// DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
	Aadd(aTables,{"DTQ",2})
	
	// VEICULOS DA VIAGEM
	// DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
	Aadd(aTables,{"DTR",1})
	
	// VEICULOS
	// DA3_FILIAL+DA3_COD
	Aadd(aTables,{"DA3",1})
	
	// CABECALHO DOC DE RECEBIMENTO
	// DB2_FILIAL+DB2_DOC+DB2_SERIE+DB2_CLIFOR+DB2_LOJA
	Aadd(aTables,{"DB2",1})
	
	// AVISO DE RECEBIMENTO DE CARGA
	// DB1_FILIAL+DB1_NRAVRC
	Aadd(aTables,{"DB1",1})
	
	// ITENS DO DOC DE RECEBIMENTO
	// DB3_FILIAL+DB3_NRAVRC+DB3_ITDOC+DB3_ITEM
	Aadd(aTables,{"DB3",1})
	
	// LIVROS FISCAIS
	// F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)
	Aadd(aTables,{"SF3",1})
	
	// COMPLEMENTO DE COMBUSTIVEIS
	// CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD+CD6_PLACA+CD6_TANQUE
	Aadd(aTables,{"CD6",1})
	
	// COMPLEMENTO DE COMUN/TELECOM
	// FX_FILIAL+FX_TIPOMOV+FX_SERIE+FX_DOC+FX_CLIFOR+FX_LOJA+FX_ITEM+FX_COD
	Aadd(aTables,{"SFX",1})
	
	// COMPLEMENTO DE MEDICAMENTOS
	// CD7_FILIAL+CD7_TPMOV+CD7_SERIE+CD7_DOC+CD7_CLIFOR+CD7_LOJA+CD7_ITEM+CD7_COD
	Aadd(aTables,{"CD7",1})
	
	// COMPLEMENTO ENERGIA ELETRICA
	// FU_FILIAL+FU_TIPOMOV+FU_SERIE+FU_DOC+FU_CLIFOR+FU_LOJA+FU_ITEM+FU_COD
	Aadd(aTables,{"SFU",1})
	
	// COMPLEMENTO DE ARMAS DE FOGO
	// CD8_FILIAL+CD8_TPMOV+CD8_SERIE+CD8_DOC+CD8_CLIFOR+CD8_LOJA+CD8_ITEM+CD8_COD
	Aadd(aTables,{"CD8",1})
	
	// COMPLEMENTO VEICULO AUTOMOTOR
	// CD9_FILIAL+CD9_TPMOV+CD9_SERIE+CD9_DOC+CD9_CLIFOR+CD9_LOJA+CD9_ITEM+CD9_COD
	Aadd(aTables,{"CD9",1})
	
	// COMPL. DA NF DE RESSARCIMENTO
	// CD0_FILIAL+CD0_TPMOV+CD0_SERIE+CD0_DOC+CD0_CLIFOR+CD0_LOJA+CD0_ITEM+CD0_COD+CD0_DOCENT+CD0_SERENT+CD0_ESPECI+CD0_FORNE+CD0_LOJENT+CD0_ID
	Aadd(aTables,{"CD0",1})
	
	// COMPLEMENTO DE GAS CANALIZADO
	// CD3_FILIAL+CD3_TPMOV+CD3_SERIE+CD3_DOC+CD3_CLIFOR+CD3_LOJA+CD3_ITEM+CD3_COD
	Aadd(aTables,{"CD3",1})

	// CADASTRO NACIONAL DE OBRAS
	// ON_FILIAL+ON_CODIGO
	Aadd(aTables,{"SON",1})
	
	// PROCESSOS REFERENCIADOS
	// CCF_FILIAL+CCF_NUMERO+CCF_TIPO+CCF_INDAUT+CCF_IDITEM
	Aadd(aTables,{"CCF",1})

	//Tabelas Novo Motor Fiscal
	if FNewMtoFis()
		Aadd(aTables,{"F2B",1}) //F2B_FILIAL+F2B_REGRA+DTOS(F2B_VIGINI)+DTOS(F2B_VIGFIM)
		Aadd(aTables,{"F2D",2}) //F2D_FILIAL+F2D_IDREL
		Aadd(aTables,{"F2E",2}) //F2E_FILIAL+F2E_TRIB
	endif

	For nCount := 1 To Len(aTables)
		If l_Open
			// Abre as tabelas
			fOpenTab(aTables[nCount][1],aTables[nCount][2])
		Else
			// Fecha as tabelas
			fCloseTab(aTables[nCount][1])
		EndIf
	Next
	
Return Nil

/*/{Protheus.doc} fOpenTab
Função para abrir a tabela. Essa função verifica se a tabela já está aberta.
Se sim, guarda a area no array statico __aArea__.
Se não, abre a tabela.

@author Vitor Ribeiro
@since 22/01/2018

@param c_Table, caracter, codigo da tabela a ser aberto.
@param n_Order, numerico, codigo do indice da tabela.

@return nulo, não tem retorno
/*/
Static Function fOpenTab(c_Table,n_Order)
	
	Default c_Table := ""
	
	Default n_Order := 1
	
	If !Empty(c_Table)
		// Se a tabela não estiver aberta
		If Empty(Select(c_Table))
			// Abre a tabela
			DbSelectArea(c_Table)
		Else
			// Guarda a area atual
			Aadd(__aArea__,{c_Table,(c_Table)->(GetArea())})
			
			// Vai para o primeiro registro
			(c_Table)->(DbGoTop())
		EndIf

		// Se foi passado uma ordem especifica e existe na tabela
		If !Empty(n_Order) .And. (c_Table)->(DbOrderInfo(9)) >= n_Order
			// Posiciona na ordem
			(c_Table)->(DbSetOrder(n_Order))
		EndIf
	EndIf
	
Return Nil

/*/{Protheus.doc} fOpenTab
Função para fechar a tabela. Essa função verifica se a tabela consta no array __aArea__.
Se sim, Restaura a area guardada no array.
Se não, fecha a tabela.

@author Vitor Ribeiro
@since 22/01/2018

@param c_Table, caracter, codigo da tabela a ser aberto.

@return nulo, não tem retorno
/*/
Static Function fCloseTab(c_Table)
	
	Local nPosicao := 0
	
	Default c_Table := ""
	
	If !Empty(c_Table)
		// Verifica se a tabela esta na variavel __aArea__
		nPosicao := Ascan(__aArea__,{|x| x[1] == c_Table })
		
		// Se tiver
		If !Empty(nPosicao)
			// Restaura a area
			RestArea(__aArea__[nPosicao][2])
		Else
			// Fecha a tabela
			(c_Table)->(DbCloseArea())
		EndIf
	EndIf
	
Return Nil

/*/{Protheus.doc} fQueryPrin
Função para montar a query principal

@author Vitor Ribeiro
@since 22/01/2018

@param c_EntSai, caracter, codigo da tabela a ser aberto.
@param c_QueryMT, numerico, codigo do indice da tabela.
@param c_DtAteGia, caracter,
@param l_TafKey, logico, Reservado
@param l_MultThr, logico, se é multi thread's ou não.
@param a_Thread, array, contem as informações das threads
@param c_JobAux, caracter, nome da variavel publica.  
@param lRelConfNT, logico, indica se a query eh utilizada para o relatorio conf. integracao nota
@param dInicial, data inicial do relatorio de conf. integracao nota
@param dFinal, data final do relatorio de conf. integracao nota

@return caracter, Alias da query principal.
/*/
Function fQueryPrin(c_EntSai,c_QueryMT,c_DtAteGia,l_TafKey,l_MultThr,a_Thread,c_JobAux, lFltRnf013, cFltInt013, lRelConfNT, dInicial, dFinal, lExtGia)

	Local cQryPrt1 := ""
	Local cQryPrt2 := ""
	Local cQryPrin := ""
	Local cQryRnf1 := ""
	Local cQryRnf2 := ""
	Local cOrderBy := ""
	Local cAliasQry := ""
	Local cConcat := "" 
	
	Local lTableTMS  := .F.
	Local lCadMovRnf := .F.
	Local lNewMtoFis := FNewMtoFis( )

	Default c_EntSai := ""
	Default c_QueryMT := ""
	Default c_DtAteGia := ""
	Default c_JobAux := ""
	
	Default l_MultThr := .F.
	Default l_TafKey := .F. // parâmetro reservado
	
	Default a_Thread := {}
	Default lFltRnf013 := .F. 
	Default cFltInt013 := "3"

	Default lRelConfNT	:= .F.
	Default dInicial	:= CtoD("  /  /    ")
	Default dFinal	   	:= CtoD("  /  /    ")
	Default lExtGia		:= .f.	

	/*
		Variavel de controle para integração das opções da Wizard:
		Filtra Apenas Reinf -> 1 - Sim ( lFltRnf013 )
		e
		Deseja integrar -> 2 - Somente Movimentos, 3 - Ambos ( cFltInt013 ) ou "" ( Vazio )
	*/
	lCadMovRnf := lFltRnf013 .And. ( cFltInt013 != "1" )

	// VerIfica o tipo de concatenação para o banco.
	If "MSSQL" $ Upper(AllTrim(TcGetDB()))
		cConcat := "+"
	Else
		cConcat := "||"
	EndIf
	
	// Verifica se as tabelas DT6 e DUD existem na base.
	lTableTMS := (!(DT6->(Eof()) .And. DT6->(Bof()))) .Or. (!(DUD->(Eof()) .And. DUD->(Eof())))

	cQryPrt1 := " SELECT "
	cQryPrt1 += "	 SFT.FT_FILIAL FILIAL "

  	if lRelConfNT
		cQryPrt1 += " ,CAST( CASE WHEN SFT.FT_TIPOMOV = 'S' THEN 'Saida' ELSE 'Entrada' END as char(7) ) TIPOMOV "
		cQryPrt1 += " ,CAST( CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('B','D')) THEN 'F' "
		cQryPrt1 += " WHEN (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('B','D')) THEN 'F' ELSE 'C' END as char(1)) FOR_CLI "
		cQryPrt1 += " ,SFT.FT_ENTRADA DTES "
  	elseif !lRelConfNT
		cQryPrt1 += " ,SFT.FT_TIPOMOV TIPOMOV "
	endif

	cQryPrt1 += "	,SFT.FT_SERIE SERIE "
	cQryPrt1 += "	,SFT.FT_NFISCAL NFISCAL "
	cQryPrt1 += "	,SFT.FT_CLIEFOR CLIEFOR "
	cQryPrt1 += "	,SFT.FT_LOJA LOJA "

	if !lRelConfNT
		cQryPrt1 += "	,SFT.FT_ITEM ITEM "
		cQryPrt1 += "   ,SF4.F4_IPI "
		cQryPrt1 += "	,CAST( CASE "
		cQryPrt1 += "		WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('B','D')) THEN 'SA2' "
		cQryPrt1 += "		WHEN (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('B','D')) THEN 'SA2' "
		cQryPrt1 += "		ELSE 'SA1' "
		cQryPrt1 += "	 END as char(3)) FOR_CLI "
		cQryPrt1 += "	,SFT.R_E_C_N_O_ RECSFT "

		cQryPrt1 += " ," + xFunExpSql("COALESCE") + "(SA1.R_E_C_N_O_,0) RECSA1 "
		cQryPrt1 += " ," + xFunExpSql("COALESCE") + "(SA2.R_E_C_N_O_,0) RECSA2 "

		If c_EntSai == "E"	// Movimento de entrada
			cQryPrt1 += " ," + xFunExpSql("COALESCE") + "(SF1.R_E_C_N_O_, 0) RECCABEC "
			cQryPrt1 += " ," + xFunExpSql("COALESCE") + "(SD1.R_E_C_N_O_, 0) RECITENS "
		Else
			cQryPrt1 += " ," + xFunExpSql("COALESCE") + "(SF2.R_E_C_N_O_, 0) RECCABEC "
			cQryPrt1 += " ," + xFunExpSql("COALESCE") + "(SD2.R_E_C_N_O_, 0) RECITENS "
		EndIf

		cQryPrt1 += " ," + xFunExpSql("COALESCE") + "(SF4.R_E_C_N_O_, 0) RECSF4 "
		cQryPrt1 += " ,SB1.R_E_C_N_O_ RECSB1 "
		cQryPrt1 += " ," + xFunExpSql("COALESCE") + "(SB5.R_E_C_N_O_, 0) RECSB5 "

		If lTableTMS
			cQryPrt1 += "	,TMS.RECDT6 "
			cQryPrt1 += "	,TMS.RECDUD "
		Else
			cQryPrt1 += "	,0 RECDT6 "
			cQryPrt1 += "	,0 RECDUD "
		EndIf

		If lNewMtoFis
			cQryPrt1 += "	,SFT.FT_IDTRIB FT_IDTRIB "
		endif
	endif

	cQryPrt1 += "FROM " + RetSqlName("SFT") + " SFT "

	//Quando utilizar Multi Thread incluo o filtro por thread e alimento a variavel global de controle
	If l_MultThr		
		cQryPrt1 += "	INNER JOIN ( "
		cQryPrt1 += "		 SELECT CHAVE.DOCUMENTO "
		cQryPrt1 += "		 FROM ( "
		cQryPrt1 += c_QueryMT
		cQryPrt1 += "		 ) CHAVE "
		cQryPrt1 += "		 WHERE "
		cQryPrt1 += "			CHAVE.LINHA BETWEEN '" + a_Thread[1] + "' AND '" + a_Thread[2] + "' "
		cQryPrt1 += "	) CHAVE ON "
		cQryPrt1 += "		CHAVE.DOCUMENTO = (SFT.FT_NFISCAL " + cConcat + " SFT.FT_SERIE " + cConcat + " SFT.FT_CLIEFOR " + cConcat + " SFT.FT_LOJA) "
		
		// STATUS 3 - Em processamento
		PutGlbValue(c_JobAux,"3")
		GlbUnLock()
	EndIf

	// JOIN em SA1 e SA2
	cQryPrt1 += "LEFT JOIN " + RetSqlName("SA2") + " SA2 ON "

	cQryPrt1 += "((SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ( 'B', 'D' )) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ( 'B', 'D' ))) AND "
	cQryPrt1 += "SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND "
	cQryPrt1 += "SA2.A2_COD = SFT.FT_CLIEFOR AND "
	cQryPrt1 += "SA2.A2_LOJA = SFT.FT_LOJA AND "
	cQryPrt1 += "SA2.D_E_L_E_T_ = ' ' "
	cQryPrt1 += "LEFT JOIN " + RetSqlName("SA1") + " SA1 ON "
	cQryPrt1 += "((SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ( 'B', 'D' )) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ( 'B', 'D' ))) AND "
	cQryPrt1 += "SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
	cQryPrt1 += "SA1.A1_COD = SFT.FT_CLIEFOR AND "
	cQryPrt1 += "SA1.A1_LOJA = SFT.FT_LOJA AND "
	cQryPrt1 += "SA1.D_E_L_E_T_ = ' ' "

	If c_EntSai == "E"	// Movimento de entrada
		cQryPrt1 += "LEFT JOIN " + RetSqlName("SF1") + " SF1 ON "
		cQryPrt1 += "SF1.F1_FILIAL  = '" + xFilial("SF1") + "' AND "
		cQryPrt1 += "SF1.F1_DOC     = SFT.FT_NFISCAL AND "
		cQryPrt1 += "SF1.F1_SERIE   = SFT.FT_SERIE AND "
		cQryPrt1 += "SF1.F1_FORNECE = SFT.FT_CLIEFOR AND "
		cQryPrt1 += "SF1.F1_LOJA    = SFT.FT_LOJA AND "
		cQryPrt1 += "SF1.D_E_L_E_T_ = ' ' "

		If lCadMovRnf .or. lExtGia
			cQryPrt1 += "INNER JOIN " + RetSqlName("SD1") + " SD1 ON "
		Else
			cQryPrt1 += "LEFT JOIN " + RetSqlName("SD1") + " SD1 ON "
		EndIf
		cQryPrt1 += "SD1.D1_FILIAL  = '" + xFilial("SD1") + "' AND "
		cQryPrt1 += "SD1.D1_DOC     = SFT.FT_NFISCAL AND "
		cQryPrt1 += "SD1.D1_SERIE   = SFT.FT_SERIE AND "
		cQryPrt1 += "SD1.D1_FORNECE = SFT.FT_CLIEFOR AND "
		cQryPrt1 += "SD1.D1_LOJA    = SFT.FT_LOJA AND "
		cQryPrt1 += "SD1.D1_COD     = SFT.FT_PRODUTO AND "
		cQryPrt1 += "SD1.D1_ITEM    = SFT.FT_ITEM AND "
		
		//Para GIA-SP não pode ter FunRural
		if lExtGia
			cQryPrt1 += "SD1.D1_BASEFUN = 0 AND " 
		endif	
		
		cQryPrt1 += "SD1.D_E_L_E_T_	= ' ' "

		MntQryRnf( lCadMovRnf, lNewMtoFis, @cQryRnf1, @cQryRnf2, "SD1.D1_BASEFUN", c_EntSai, lFltRnf013 )

	Else
		cQryPrt1 += "LEFT JOIN " + RetSqlName("SF2") + " SF2 ON "
		cQryPrt1 += "SF2.F2_FILIAL  = '" + xFilial("SF2") + "' AND "
		cQryPrt1 += "SF2.F2_DOC     = SFT.FT_NFISCAL AND "
		cQryPrt1 += "SF2.F2_SERIE   = SFT.FT_SERIE AND "
		cQryPrt1 += "SF2.F2_CLIENTE = SFT.FT_CLIEFOR AND "
		cQryPrt1 += "SF2.F2_LOJA    = SFT.FT_LOJA AND "
		cQryPrt1 += "(SF2.D_E_L_E_T_ = ' ' OR SFT.FT_OBSERV = 'NF CANCELADA') " 
		
		If lCadMovRnf .or. lExtGia
			cQryPrt1 += "INNER JOIN " + RetSqlName("SD2") + " SD2 ON "
		Else
			cQryPrt1 += "LEFT JOIN " + RetSqlName("SD2") + " SD2 ON "
		EndIf

		cQryPrt1 += "SD2.D2_FILIAL  = '" + xFilial("SD2") + "' AND "
		cQryPrt1 += "SD2.D2_DOC     = SFT.FT_NFISCAL AND "
		cQryPrt1 += "SD2.D2_SERIE   = SFT.FT_SERIE AND "
		cQryPrt1 += "SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND "
		cQryPrt1 += "SD2.D2_LOJA    = SFT.FT_LOJA AND "
		cQryPrt1 += "SD2.D2_COD     = SFT.FT_PRODUTO AND "
		cQryPrt1 += "SD2.D2_ITEM    = SFT.FT_ITEM AND "

		//Para GIA-SP não pode ter FunRural
		if lExtGia
			cQryPrt1 += "SD2.D2_BASEFUN = 0 AND " 
		endif	

		cQryPrt1 += "SD2.D_E_L_E_T_ = ' ' "
	
		MntQryRnf( lCadMovRnf, lNewMtoFis, @cQryRnf1, @cQryRnf2, "SD2.D2_BASEFUN", c_EntSai, lFltRnf013 )

	EndIf

	cQryPrt2 += "LEFT JOIN " + RetSqlName("SF4") + " SF4 ON "
	cQryPrt2 += "SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND "
	If c_EntSai == "E"	// Movimento de entrada
		cQryPrt2 += "SF4.F4_CODIGO = SD1.D1_TES AND "
	Else
		cQryPrt2 += "SF4.F4_CODIGO = SD2.D2_TES AND "
	EndIf
	cQryPrt2 += "SF4.D_E_L_E_T_ = ' ' "

	cQryPrt2 += "LEFT JOIN " + RetSqlName("SB5") + " SB5 ON "
	cQryPrt2 += "SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND "
	cQryPrt2 += "SB5.B5_COD = SFT.FT_PRODUTO AND "
	cQryPrt2 += "SB5.D_E_L_E_T_ = ' ' "

	If lTableTMS
		cQryPrt2 += " LEFT OUTER JOIN ( "
		cQryPrt2 += " 	SELECT "
		cQryPrt2 += " 		 DT6.DT6_FILDOC FILDOC "
		cQryPrt2 += " 		,DT6.DT6_DOC DOC "
		cQryPrt2 += " 		,DT6.DT6_SERIE SERIE "
		cQryPrt2 += " 		,DT6.R_E_C_N_O_ RECDT6 "
		cQryPrt2 += " 		,DUD.RECDUD "
		cQryPrt2 += " 	FROM " + RetSqlName("DT6") + " DT6 "
		
		cQryPrt2 += " 	LEFT OUTER JOIN ( "
		cQryPrt2 += " 		SELECT "
		cQryPrt2 += " 			 DUD.DUD_FILDOC "
		cQryPrt2 += " 			,DUD.DUD_DOC "
		cQryPrt2 += " 			,DUD.DUD_SERIE "
		cQryPrt2 += " 			,MIN(DUD.R_E_C_N_O_) RECDUD "
		cQryPrt2 += " 		FROM " + RetSqlName("DUD") + " DUD "
		
		cQryPrt2 += " 		WHERE "
		cQryPrt2 += " 			DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQryPrt2 += " 			AND DUD.D_E_L_E_T_ = ' ' "
		
		cQryPrt2 += " 		GROUP BY "
		cQryPrt2 += " 			  DUD.DUD_FILDOC "
		cQryPrt2 += " 			 ,DUD.DUD_DOC "
		cQryPrt2 += " 			 ,DUD.DUD_SERIE "
		cQryPrt2 += " 	) DUD ON "
		cQryPrt2 += " 		DUD.DUD_FILDOC = DT6.DT6_FILDOC "
		cQryPrt2 += " 		AND DUD.DUD_DOC = DT6.DT6_DOC "
		cQryPrt2 += " 		AND DUD.DUD_SERIE = DT6.DT6_SERIE "
		
		cQryPrt2 += " 	WHERE "
		cQryPrt2 += " 		DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
		cQryPrt2 += " 		AND DT6.D_E_L_E_T_ = ' ' "
		cQryPrt2 += " ) TMS ON "
		cQryPrt2 += " 	TMS.FILDOC = SFT.FT_FILIAL "
		cQryPrt2 += " 	AND TMS.DOC = SFT.FT_NFISCAL "
		cQryPrt2 += " 	AND TMS.SERIE = SFT.FT_SERIE "
	EndIf

	cQryPrt2 += ", " + RetSqlName("SB1") + " SB1 "

	cQryPrt2 += "WHERE "
	cQryPrt2 += "	SFT.FT_FILIAL = '" + xFilial("SFT") + "' "
	cQryPrt2 += "	AND SFT.FT_TIPOMOV = '" + c_EntSai + "' "

	if !lRelConfNT
		cQryPrt2 += "	AND SFT.FT_ENTRADA BETWEEN '" + DToS(aWizard[_DATA_DE_]) + "' AND '" + DToS(aWizard[_DATA_ATE_]) + "' "
	else
		cQryPrt2 += "	AND SFT.FT_ENTRADA BETWEEN '" + dInicial + "' AND '" + dFinal + "' "
	endif

	// Criado um filtro para nota De/Até
	If !l_MultThr
		if !lRelConfNT
			cQryPrt2 += "	AND SFT.FT_NFISCAL BETWEEN '" + aWizard[_NOTA_DE_] + "' AND '" + aWizard[_NOTA_ATE_] + "' "	
			if !(Empty(aWizard[_SERI_DE_]) .And. aWizard[_SERI_ATE_]=='ZZZ')
				cQryPrt2 += "	AND SFT.FT_SERIE BETWEEN '" + aWizard[_SERI_DE_] + "' AND '" + aWizard[_SERI_ATE_] + "' "
			Endif
			If !Empty(aWizard[_ESP_S_PR_])
				cQryPrt2 += "	AND SFT.FT_ESPECIE IN (" + aWizard[_ESP_C_PR_] + ") "
			EndIf
		endif
	EndIf  

	if !lRelConfNT
		cQryPrt2 += "	AND ( "
		cQryPrt2 += "		(SFT.FT_ENTRADA <= '" + DToS(aWizard[_DATA_ATE_]) + "' AND SFT.FT_CFOP NOT IN ('1601','1602','1605','5601','5602','5605')) "
		cQryPrt2 += "		OR (SFT.FT_ENTRADA <= '" + c_DtAteGia + "' AND SFT.FT_CFOP IN ('1601','1602','1605','5601','5602','5605')) "
		cQryPrt2 += "	) "
	else
		cQryPrt2 += "	AND ( "
		cQryPrt2 += "		(SFT.FT_ENTRADA <= '" + dFinal + "' AND SFT.FT_CFOP NOT IN ('1601','1602','1605','5601','5602','5605')) "
		cQryPrt2 += "		OR (SFT.FT_ENTRADA <= '" + dFinal + "' AND SFT.FT_CFOP IN ('1601','1602','1605','5601','5602','5605')) "
		cQryPrt2 += "	) "
	endif

	if lExtGia
		cQryPrt2 += "	AND SFT.FT_BASEINS = 0 "
		cQryPrt2 += "	AND SFT.FT_BSSENAR = 0 "
		cQryPrt2 += "	AND	( "
		cQryPrt2 += "		( SFT.FT_CODISS = '' AND ( SFT.FT_BASEICM > 0 OR SFT.FT_VALICM > 0 OR SFT.FT_OUTRICM > 0 OR SFT.FT_ISENICM > 0 ) ) OR "
		cQryPrt2 += "		( SFT.FT_CODISS != '' AND SFT.FT_CFOP IN ('1933','5933'))  "
		cQryPrt2 += "		) "
	endif

	cQryPrt2 += "	AND	SB1.B1_FILIAL	=	'" + xFilial("SB1") + "' "
	cQryPrt2 += "	AND SB1.B1_COD		=	SFT.FT_PRODUTO "
	cQryPrt2 += "	AND SB1.D_E_L_E_T_	=	' ' "
	
	cQryPrt2 += "	AND SFT.D_E_L_E_T_ = ' ' "

	cQryPrin := cQryPrt1 + cQryRnf1 + cQryPrt2
	
	/*
		É possível configurar os tributos do FUNRURAL pelo configurador de Tributos do módulo fiscal ( FISA170 )
		Amarração F2E x F2C -> F2C_CODIGO = '000001','000002' ou '000003'

		As querys para extrair notas de Reinf:
		- Analisando tabela da SFT ( FT_BASEINS, FT_BSSENAR )
		- Analisando notas geradas pelo configurador ( FT_IDTRIB != '' )
		são identicas
		Por isso, foi particionado a query principal em cQryPrt1 e cQryPrt2, adicionando apenas a diferença entre elas
		cQryRnf1 -> analisa SFT
		cQryRnf2 -> analisa FT_IDTRIB != ''
		para ser utilizado pelo UNION
	*/
	If lCadMovRnf .and. lNewMtoFis
		cQryPrin += " UNION " + cQryPrt1 + cQryRnf2 + cQryPrt2
	EndIf

	If lCadMovRnf
		cQryPrin += " UNION  "

		cQryPrin += " SELECT "
		cQryPrin += "	 SFT2.FT_FILIAL FILIAL "
		cQryPrin += "	,SFT2.FT_TIPOMOV TIPOMOV "
		cQryPrin += "	,SFT2.FT_SERIE SERIE "
		cQryPrin += "	,SFT2.FT_NFISCAL NFISCAL "
		cQryPrin += "	,SFT2.FT_CLIEFOR CLIEFOR "
		cQryPrin += "	,SFT2.FT_LOJA LOJA "
		cQryPrin += "	,SFT2.FT_ITEM ITEM "
		cQryPrin += "	,SF4.F4_IPI "
		cQryPrin += "	,CAST (CASE "
		cQryPrin += "		WHEN (SFT2.FT_TIPOMOV = 'E' AND SFT2.FT_TIPO NOT IN ('B','D')) THEN 'SA2' "
		cQryPrin += "		WHEN (SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_TIPO IN ('B','D')) THEN 'SA2' "
		cQryPrin += "		ELSE 'SA1' "
		cQryPrin += "	 END AS CHAR(3)) FOR_CLI "
		cQryPrin += "	,SFT2.R_E_C_N_O_ RECSFT "

		cQryPrin += " ," + xFunExpSql("COALESCE") + "(SA1.R_E_C_N_O_,0) RECSA1 "
		cQryPrin += " ," + xFunExpSql("COALESCE") + "(SA2.R_E_C_N_O_,0) RECSA2 "

		If c_EntSai == "E"	// Movimento de entrada
			cQryPrin += " ," + xFunExpSql("COALESCE") + "(SF1.R_E_C_N_O_, 0) RECCABEC "
			cQryPrin += " ," + xFunExpSql("COALESCE") + "(SD1.R_E_C_N_O_, 0) RECITENS "
		Else
			cQryPrin += " ," + xFunExpSql("COALESCE") + "(SF2.R_E_C_N_O_, 0) RECCABEC "
			cQryPrin += " ," + xFunExpSql("COALESCE") + "(SD2.R_E_C_N_O_, 0) RECITENS "
		EndIf

		cQryPrin += " ," + xFunExpSql("COALESCE") + "(SF4.R_E_C_N_O_, 0) RECSF4 "
		cQryPrin += " ,SB1.R_E_C_N_O_ RECSB1 "
		cQryPrin += " ," + xFunExpSql("COALESCE") + "(SB5.R_E_C_N_O_, 0) RECSB5 "

		If lTableTMS
			cQryPrin += "	,TMS.RECDT6 "
			cQryPrin += "	,TMS.RECDUD "
		Else
			cQryPrin += "	,0 RECDT6 "
			cQryPrin += "	,0 RECDUD "		
		EndIf

		If lNewMtoFis
			cQryPrin += "	,SFT2.FT_IDTRIB FT_IDTRIB "
		endif

		cQryPrin += "FROM " + RetSqlName("SFT") + " SFT2 "

		//Quando utilizar Multi Thread incluo o filtro por thread e alimento a variavel global de controle
		If l_MultThr		
			cQryPrin += "	INNER JOIN ( "
			cQryPrin += "		 SELECT CHAVE.DOCUMENTO "
			cQryPrin += "		 FROM ( "   
			cQryPrin += c_QueryMT
			cQryPrin += "		 ) CHAVE "
			cQryPrin += "		 WHERE "
			cQryPrin += "			CHAVE.LINHA BETWEEN '" + a_Thread[1] + "' AND '" + a_Thread[2] + "' "
			cQryPrin += "	) CHAVE ON "
			cQryPrin += "		CHAVE.DOCUMENTO = (SFT2.FT_NFISCAL " + cConcat + " SFT2.FT_SERIE " + cConcat + " SFT2.FT_CLIEFOR " + cConcat + " SFT2.FT_LOJA) "
			
			// STATUS 3 - Em processamento
			PutGlbValue(c_JobAux,"3") 
			GlbUnLock()
		EndIf

		// JOIN em SA1 e SA2
		cQryPrin += "LEFT JOIN " + RetSqlName("SA2") + " SA2 ON "
		cQryPrin += "((SFT2.FT_TIPOMOV = 'E' AND SFT2.FT_TIPO NOT IN ( 'B', 'D' )) OR (SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_TIPO IN ( 'B', 'D' ))) AND "
		cQryPrin += "SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND "
		cQryPrin += "SA2.A2_COD = SFT2.FT_CLIEFOR AND "
		cQryPrin += "SA2.A2_LOJA = SFT2.FT_LOJA AND "
		cQryPrin += "SA2.D_E_L_E_T_ = ' ' "

		cQryPrin += "LEFT JOIN " + RetSqlName("SA1") + " SA1 ON "
		cQryPrin += "((SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_TIPO NOT IN ( 'B', 'D' )) OR (SFT2.FT_TIPOMOV = 'E' AND SFT2.FT_TIPO IN ( 'B', 'D' ))) AND "
		cQryPrin += "SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
		cQryPrin += "SA1.A1_COD = SFT2.FT_CLIEFOR AND "
		cQryPrin += "SA1.A1_LOJA = SFT2.FT_LOJA AND "
		cQryPrin += "SA1.D_E_L_E_T_ = ' ' "

		If c_EntSai == "E"	// Movimento de entrada
			cQryPrin += "LEFT JOIN " + RetSqlName("SF1") + " SF1 ON "
			cQryPrin += "SF1.F1_FILIAL  = '" + xFilial("SF1") + "' AND "
			cQryPrin += "SF1.F1_DOC     = SFT2.FT_NFISCAL AND "
			cQryPrin += "SF1.F1_SERIE   = SFT2.FT_SERIE AND "
			cQryPrin += "SF1.F1_FORNECE = SFT2.FT_CLIEFOR AND "
			cQryPrin += "SF1.F1_LOJA    = SFT2.FT_LOJA AND "
			cQryPrin += "SF1.D_E_L_E_T_ = ' ' "
		
			cQryPrin += "INNER JOIN " + RetSqlName("SD1") + " SD1 ON "
			cQryPrin += "SD1.D1_FILIAL  = '" + xFilial("SD1") + "' AND "
			cQryPrin += "SD1.D1_DOC     = SFT2.FT_NFISCAL AND "
			cQryPrin += "SD1.D1_SERIE   = SFT2.FT_SERIE AND "
			cQryPrin += "SD1.D1_FORNECE = SFT2.FT_CLIEFOR AND "
			cQryPrin += "SD1.D1_LOJA    = SFT2.FT_LOJA AND "
			cQryPrin += "SD1.D1_COD     = SFT2.FT_PRODUTO AND "
			cQryPrin += "SD1.D1_ITEM    = SFT2.FT_ITEM AND "
			cQryPrin += "SD1.D_E_L_E_T_	= ' ' "
			cQryPrin += " AND SFT2.FT_BASEINS = 0 AND SD1.D1_BASEFUN = 0 AND SFT2.FT_BSSENAR = 0 "
		Else
			cQryPrin += "LEFT JOIN " + RetSqlName("SF2") + " SF2 ON "
			cQryPrin += "SF2.F2_FILIAL  = '" + xFilial("SF2") + "' AND "
			cQryPrin += "SF2.F2_DOC     = SFT2.FT_NFISCAL AND "
			cQryPrin += "SF2.F2_SERIE   = SFT2.FT_SERIE AND "
			cQryPrin += "SF2.F2_CLIENTE = SFT2.FT_CLIEFOR AND "
			cQryPrin += "SF2.F2_LOJA    = SFT2.FT_LOJA AND "
			cQryPrin += "SF2.D_E_L_E_T_ = ' ' "

			cQryPrin += "INNER JOIN " + RetSqlName("SD2") + " SD2 ON "
			cQryPrin += "SD2.D2_FILIAL  = '" + xFilial("SD2") + "' AND "
			cQryPrin += "SD2.D2_DOC     = SFT2.FT_NFISCAL AND "
			cQryPrin += "SD2.D2_SERIE   = SFT2.FT_SERIE AND "
			cQryPrin += "SD2.D2_CLIENTE = SFT2.FT_CLIEFOR AND "
			cQryPrin += "SD2.D2_LOJA    = SFT2.FT_LOJA AND "
			cQryPrin += "SD2.D2_COD     = SFT2.FT_PRODUTO AND "
			cQryPrin += "SD2.D2_ITEM    = SFT2.FT_ITEM AND "
			cQryPrin += "SD2.D_E_L_E_T_ = ' ' "
			cQryPrin += " AND SFT2.FT_BASEINS = 0 AND SD2.D2_BASEFUN = 0 AND SFT2.FT_BSSENAR = 0 "
		EndIf

		cQryPrin += " INNER JOIN " + RetSqlName("CDG") + " CDG ON CDG.CDG_FILIAL = '" + xFilial("CDG") + "' "
		cQryPrin += " AND CDG.CDG_DOC = SFT2.FT_NFISCAL "
		cQryPrin += " AND CDG.CDG_SERIE = SFT2.FT_SERIE "
		cQryPrin += " AND CDG.CDG_CLIFOR = SFT2.FT_CLIEFOR "
		cQryPrin += " AND CDG.CDG_LOJA = SFT2.FT_LOJA "
		cQryPrin += " AND CDG.CDG_ITEM = SFT2.FT_ITEM "
		cQryPrin += " AND CDG.CDG_TPMOV = SFT2.FT_TIPOMOV  "
		cQryPrin += " AND CDG.D_E_L_E_T_ = ' ' "

		cQryPrin += " INNER JOIN " + RetSqlName("CCF") + " CCF ON CCF.CCF_FILIAL = '" + xFilial("CCF") + "' "
		cQryPrin += " AND CCF.CCF_TRIB IN ('1','2','3','4') "
		cQryPrin += " AND CCF.CCF_NUMERO = CDG.CDG_PROCES  "
		cQryPrin += " AND CCF.CCF_IDITEM = CDG.CDG_ITPROC "
		cQryPrin += " AND CCF.CCF_TIPO = CDG.CDG_TPPROC "
		cQryPrin += " AND CCF.D_E_L_E_T_ = ' ' "


		cQryPrin += "LEFT JOIN " + RetSqlName("SF4") + " SF4 ON "
		cQryPrin += "SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND "
		If c_EntSai == "E"	// Movimento de entrada
			cQryPrin += "SF4.F4_CODIGO = SD1.D1_TES AND "
		Else
			cQryPrin += "SF4.F4_CODIGO = SD2.D2_TES AND "
		EndIf
		cQryPrin += "SF4.D_E_L_E_T_ = ' ' "

		cQryPrin += "LEFT JOIN " + RetSqlName("SB5") + " SB5 ON "
		cQryPrin += "SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND "
		cQryPrin += "SB5.B5_COD = SFT2.FT_PRODUTO AND "
		cQryPrin += "SB5.D_E_L_E_T_ = ' ' "

		If lTableTMS
			cQryPrin += " LEFT OUTER JOIN ( "
			cQryPrin += " 	SELECT "
			cQryPrin += " 		 DT6.DT6_FILDOC FILDOC "
			cQryPrin += " 		,DT6.DT6_DOC DOC "
			cQryPrin += " 		,DT6.DT6_SERIE SERIE "
			cQryPrin += " 		,DT6.R_E_C_N_O_ RECDT6 "
			cQryPrin += " 		,DUD.RECDUD "
			cQryPrin += " 	FROM " + RetSqlName("DT6") + " DT6 "
			
			cQryPrin += " 	LEFT OUTER JOIN ( "
			cQryPrin += " 		SELECT "
			cQryPrin += " 			 DUD.DUD_FILDOC "
			cQryPrin += " 			,DUD.DUD_DOC "
			cQryPrin += " 			,DUD.DUD_SERIE "
			cQryPrin += " 			,MIN(DUD.R_E_C_N_O_) RECDUD "
			cQryPrin += " 		FROM " + RetSqlName("DUD") + " DUD "
			
			cQryPrin += " 		WHERE "
			cQryPrin += " 			DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
			cQryPrin += " 			AND DUD.D_E_L_E_T_ = ' ' "
			
			cQryPrin += " 		GROUP BY "
			cQryPrin += " 			  DUD.DUD_FILDOC "
			cQryPrin += " 			 ,DUD.DUD_DOC "
			cQryPrin += " 			 ,DUD.DUD_SERIE "
			cQryPrin += " 	) DUD ON "
			cQryPrin += " 		DUD.DUD_FILDOC = DT6.DT6_FILDOC "
			cQryPrin += " 		AND DUD.DUD_DOC = DT6.DT6_DOC "
			cQryPrin += " 		AND DUD.DUD_SERIE = DT6.DT6_SERIE "
			
			cQryPrin += " 	WHERE "
			cQryPrin += " 		DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
			cQryPrin += " 		AND DT6.D_E_L_E_T_ = ' ' "
			cQryPrin += " ) TMS ON "
			cQryPrin += " 	TMS.FILDOC = SFT2.FT_FILIAL "
			cQryPrin += " 	AND TMS.DOC = SFT2.FT_NFISCAL "
			cQryPrin += " 	AND TMS.SERIE = SFT2.FT_SERIE "
		EndIf

		cQryPrin += ", " + RetSqlName("SB1") + " SB1 "

		cQryPrin += "WHERE "
		cQryPrin += "	SFT2.FT_FILIAL = '" + xFilial("SFT") + "' "
		cQryPrin += "	AND SFT2.FT_TIPOMOV = '" + c_EntSai + "' "
		cQryPrin += "	AND SFT2.FT_ENTRADA BETWEEN '" + DToS(aWizard[_DATA_DE_]) + "' AND '" + DToS(aWizard[_DATA_ATE_]) + "' "

		// Criado um filtro para nota De/Até
		If !l_MultThr
			cQryPrin += "	AND SFT2.FT_NFISCAL BETWEEN '" + aWizard[_NOTA_DE_] + "' AND '" + aWizard[_NOTA_ATE_] + "' "	
			if !(Empty(aWizard[_SERI_DE_]) .And. aWizard[_SERI_ATE_]=='ZZZ')
				cQryPrin += "	AND SFT2.FT_SERIE BETWEEN '" + aWizard[_SERI_DE_] + "' AND '" + aWizard[_SERI_ATE_] + "' "
			Endif
			If !Empty(aWizard[_ESP_S_PR_])
				cQryPrin += "	AND SFT2.FT_ESPECIE IN (" + aWizard[_ESP_C_PR_] + ") "
			EndIf
		EndIf  
		
		cQryPrin += "	AND ( "
		cQryPrin += "		(SFT2.FT_ENTRADA <= '" + DToS(aWizard[_DATA_ATE_]) + "' AND SFT2.FT_CFOP NOT IN ('1601','1602','1605','5601','5602','5605')) "
		cQryPrin += "		OR (SFT2.FT_ENTRADA <= '" + c_DtAteGia + "' AND SFT2.FT_CFOP IN ('1601','1602','1605','5601','5602','5605')) "
		cQryPrin += "	) "

		cQryPrin += "	AND	SB1.B1_FILIAL	=	'" + xFilial("SB1") + "' "
		cQryPrin += "	AND SB1.B1_COD		=	SFT2.FT_PRODUTO "
		cQryPrin += "	AND SB1.D_E_L_E_T_	=	' ' "
		
		cQryPrin += "	AND SFT2.D_E_L_E_T_ = ' ' "
	EndIf

	cOrderBy := "	 DADOS.TIPOMOV "
	cOrderBy += "	,DADOS.SERIE "
	cOrderBy += "	,DADOS.NFISCAL "
	cOrderBy += "	,DADOS.CLIEFOR "
	cOrderBy += "	,DADOS.LOJA "
	if !lRelConfNT
		cOrderBy += "	,DADOS.ITEM "
	endif
	cQryPrin := "%" + cQryPrin + "%"
	cOrderBy := "%" + cOrderBy + "%"

	cAliasQry := GetNextAlias()

		BeginSql Alias cAliasQry
			SELECT *
			FROM (%Exp:cQryPrin%) DADOS
			ORDER BY
				%Exp:cOrderBy%
		EndSql
	
Return cAliasQry

/*/{Protheus.doc} fPosTabCab
Função para realizar o posicionamento das tabelas do cabeçalho.

@author Vitor Ribeiro
@since 22/01/2018

@param c_EntSai, caracter, codigo da tabela a ser aberto.
@param c_ForCli, caracter, se é fornecedor (SA2) ou cliente (SA1).
@param n_RecnoCab, caracter, recno da tabela do cabeçalho. Nota de entrada (SF1). Nota de saída (SF2). 
@param n_RecnoA1A2, caracter, recno do participante. Fornecedor ou cliente. 

@return nulo, não tem retorno
/*/
Function fPosTabCab(c_EntSai,c_ForCli,n_RecnoCab,n_RecnoA1,n_RecnoA2)
	
	Default c_EntSai := ""
	Default c_ForCli := ""
	
	Default n_RecnoCab := 0
	Default n_RecnoA1 := 0
	Default n_RecnoA2 := 0
	
	If !Empty(n_RecnoCab)
		// Posiciona nos registros de cabeçalho e itens da nota
		If c_EntSai == "E"
			SF1->(DbGoTo(n_RecnoCab))
		ElseIf c_EntSai == "S"
			SF2->(DbGoTo(n_RecnoCab))
		EndIf
	EndIf
	
	If c_ForCli == "SA1" .And. !Empty(n_RecnoA1)
		// Posiciona no registro do participante
		SA1->(DbGoTo(n_RecnoA1))
	ElseIf c_ForCli == "SA2" .And. !Empty(n_RecnoA2)
		SA2->(DbGoTo(n_RecnoA2))
	EndIf
	
Return Nil

/*/{Protheus.doc} fPosTabItm
Função para realizar o posicionamento das tabelas do item do cabeçalho.

@author Vitor Ribeiro
@since 22/01/2018

@param c_EntSai, caracter, codigo da tabela a ser aberto.
@param n_RecnoSFT, caracter, recno da SFT. 
@param n_RecnoItm, caracter, recno da tabela do item. Nota de entrada (SD1). Nota de saída (SD2).
@param n_RecnoSF4, caracter, recno da SF4. 
@param n_RecnoSB1, caracter, recno da SB1.
@param n_RecnoSB5, caracter, recno da SB5.

@return nulo, não tem retorno
/*/
Function fPosTabItm(c_EntSai,n_RecnoSFT,n_RecnoItm,n_RecnoSF4,n_RecnoSB1,n_RecnoSB5)
	
	Default c_EntSai := ""
	
	Default n_RecnoSFT := 0
	Default n_RecnoItm := 0
	Default n_RecnoSF4 := 0
	Default n_RecnoSB1 := 0
	
	If !Empty(n_RecnoSFT)
		// Posiciona no registro da SFT
		SFT->(DbGoTo(n_RecnoSFT))
	EndIf
	
	If !Empty(n_RecnoItm)
		// Posiciona nos registros de cabeçalho e itens da nota
		If c_EntSai == "E" 
			SD1->(DbGoTo(n_RecnoItm))
		ElseIf c_EntSai == "S"
			SD2->(DbGoTo(n_RecnoItm))
		EndIf
	EndIf
	
	If !Empty(n_RecnoSF4)
		// Posiciona no registro da SF4
		SF4->(DbGoTo(n_RecnoSF4))
	EndIf
	
	If !Empty(n_RecnoSB1)
		// Posiciona no registro da SB1
		SB1->(DbGoTo(n_RecnoSB1))
	EndIf
				
	If !Empty(n_RecnoSB5)
		// Posiciona no registro da SB5
		SB5->(DbGoTo(n_RecnoSB5))
	EndIf
				
Return Nil

// Posição do array aPisCofP retorno da função VerPPisCof
#Define NPAUTAPIS 	01	// Pauta PIS
#Define NPAUTACOF 	02	// Pauta COFINS

// Posição do array aDIfalFcp retorno da função fDIfalFcp
#Define NDIfALDEST 01
#Define NDIfALORIG 02
#Define NALQDIfALC 03
#Define NDIfALFECP 04
#Define NALQFECPCM 05

/*/{Protheus.doc} FBusTribNf
Esta Funcao realiza a busca dos tributos dos documentos fiscais e dos itens
do documento fiscal, inclusive do movimento ECF

@author Rodrigo Aguilar
@since  30/04/2013

@param c_Especie, caracter, Especie da Nota Fiscal
@param a_PartDoc, array, Dados do Participante da Nota Fiscal
@param a_RgT013AP, array, será utilizado para montar as informações do registro T013AP
@param a_RgT015AE, array, será utilizado para montar as informações do registro T015AE
@param n_ItT015, numerico, item do registro T015
@param a_RgT078AF, array, será utilizado para montar as informações do registro T078AF
@param n_ItT078AE, numerico, item do registro T078AE
@param a_RgT080AC, array, será utilizado para montar as informações do registro T080AC
@param n_ItT080, numerico, item do registro T080
@param n_ItT080AA, numerico, item do registro T080AA
@param n_ItT080AB, numerico, item do registro T080AB
@param a_ClasFis, array, contém a classIficação fiscal.
@param n_RecnoCDG, numerico, recno da CDG.

@return nulo, não tem retorno

@obs Função refeita. Vitor Ribeiro - 11/01/2018
/*/
Function FBusTribNf(c_Especie,a_PartDoc,a_RgT013AP,a_RgT015AE,n_ItT015,a_RgT078AF,n_ItT078AE,a_RgT080AC,n_ItT080,n_ItT080AA,n_ItT080AB,a_ClasFis,n_RecnoCDG, c_FilSFT, c_ChavF2D, c_NotaUF, cMVSUBTRIB, cMV_DifTr)

Local aCodTrib    := {}
Local aPisCofP    := {}
Local aCodTribN   := {}
Local aTribF2D    := {}

Local nCount      := 0
Local nRegraTrb   := 0

Local lAchouCDG   := .F.
Local lCCFIdiTem  := .F.
Local lCCFTrib 	  := .F.
Local cNewFRural  := ""
Local cCodTrib    := ""
Local lTSI		  := FWIsInCallStack("TSI") //Função chamada pelo TSI.

Default c_Especie := ""
Default a_PartDoc := {}

Default a_RgT013AP := Nil
Default a_RgT015AE := Nil
Default a_RgT078AF := Nil // parâmetro reservado  
Default a_RgT080AC := Nil
Default a_ClasFis  := Nil

Default n_ItT015   := 0
Default n_ItT078AE := 0
Default n_ItT080   := 0
Default n_ItT080AA := 0
Default n_ItT080AB := 0
Default n_RecnoCDG := 0

Default c_FilSFT  	:= ""
Default c_ChavF2D 	:= ""
Default c_NotaUF  	:= SFT->FT_ESTADO
Default cMVSUBTRIB 	:= ""
Default cMV_DifTr	:= ""

lCCFIdiTem := oFisaExtSx:_CCF_IDITEM  // CCF_IDITEM
lCCFTrib := oFisaExtSx:_CCF_TRIB    // CCF_TRIB

// Se não foi passado a classIficação fiscal
If a_ClasFis == Nil
	// Buscando a CST dos tributos
	// SPDRetCCST(cAliasSFT,lAchouSF4,cEspecie,cAliasSF4,cAliasSB1,cPartEst)
	a_ClasFis := SPDRetCCST("SFT",.T.,c_Especie,"SF4","SB1",a_PartDoc[02])
	
	// Tratamento para que seja considerado apenas a ClassIficacao Fiscal sem a Origem do Produto
	If Len(AllTrim(a_ClasFis[1])) == 3
		a_ClasFis[1] := SubStr(a_ClasFis[1],2,2)
	EndIf
EndIf

// Função para buscar as informações do dIfal e fcp
aDIfalFcp := fDIfalFcp( c_NotaUF, cMVSUBTRIB, cMV_DifTr  )

// Função para executar as regras de tributos referente a nota.
aCodTrib := fRegrTrbNf()

// Busca as informações da pauta de pis e cofins
aPisCofP := VerPPisCof(aCodTrib)

/*---------------------------------------------------	
|Verifica os tributos gerados pelo novo motor fiscal|
----------------------------------------------------*/
If !Empty(c_FilSFT + c_ChavF2D)
	If lTSI
		DbSelectArea("F2D")
		DbSetOrder(2)
	EndIf
	If F2D->(MsSeek( c_FilSFT + c_ChavF2D ))
		While F2D->(!Eof()) .And. F2D->F2D_FILIAL + F2D->F2D_IDREL == c_FilSFT + c_ChavF2D

			// Serão gerados T013AP e T015AE do configurador de tributos apenas para FUNRURAL
			cCodTrib :=  FDeParaF2D( c_FilSFT , F2D->F2D_TRIB )
			If cCodTrib $ "13|24|25"
				aadd( aTribF2D , { 	F2D->F2D_FILIAL , F2D->F2D_IDREL , F2D->F2D_TRIB, cCodTrib, F2D->F2D_BASE , F2D->F2D_BASQTD , F2D->F2D_ALIQ , F2D->F2D_VALOR })
			EndIf

			F2D->(DbSkip())
		EndDo
	EndIf
	If lTSI
		F2D->(DbCloseArea())
	EndIf
EndIf

// Guarda o CFOP da nota fiscal. 
cCfop := SFT->FT_CFOP

// Inicializa o codigo de iss utilizado somente para o imposto 01=ISSQN
cCodIss := ""

// Quando utilizar CFOP antigo por ser nota de serviço, converto o CFOP para 5933/1933
If Len(AllTrim(cCfop)) <= 3 .And. !Empty(SFT->FT_TIPOMOV)
	// CFOP de serviço
	If SFT->FT_TIPOMOV == "S"
		cCfop := "5933"
	Else
		cCfop := "1933"
	EndIf
EndIf

/*---------------------------------------------------	
|         Prioriza Tributos do Motor Fiscal         |
----------------------------------------------------*/
If ( Len( aTribF2D ) > 0 )
	FPriMtoFis( aTribF2D, @a_RgT013AP, @a_RgT015AE, @cNewFRural, n_ItT015, cCfop, cCodIss  )
EndIf

// Roda todas as tributações
For nCount := 1 To Len(aCodTrib)
	
	// Roda todas as regras da tributação específica.
	For nRegraTrb := 1 To Len(aCodTrib[nCount][2])
		
		// Se houve a tributação
		If aCodTrib[nCount][2][nRegraTrb]
			
			// Se foi passado um array a_RgT013AP por referencia para ser preenchido 
			If a_RgT013AP <> Nil
				if  !(AllTrim(aCodTrib[nCount][1]) $ AllTrim(cNewFRural))
					// Monta o registro T013AP
					fRegT013AP(aCodTrib[nCount][1],nRegraTrb,@a_RgT013AP,a_ClasFis,aPisCofP,aDIfalFcp)
				endif
			EndIf

			/*
				O registro T015AE e o T078AF possui a dIferença na quantidade de campos.
				O registro T078AF e T080AC são identicos.
				T015AE são 41 campos
				T078AF são 17 campos
				Porém, atualmente, os 17 campos do T078AF são identicos aos 17 primeiros campos do registro T015AE.
				Os dois estão separados em funções dIferentes devido ao fato de ser layout's distindos.
				Por isso o ideal é verIficar se todo o ajuste feito no registro T015AE deve ser replicado para o registro T078AF, T080AC e vice e versa.
			*/

			// Se foi passado um array a_RgT015AE por referencia para ser preenchido
			If a_RgT015AE <> Nil
				if  !(Alltrim(aCodTrib[nCount][1]) $ AllTrim(cNewFRural))
					// Monta o registro T015AE
					fRegT015AE(aCodTrib[nCount][1],nRegraTrb,@a_RgT015AE,n_ItT015,a_ClasFis,aPisCofP,aDIfalFcp)
				endif
			EndIf

			// Se foi passado um array a_RgT080AC por referencia para ser preenchido
			If a_RgT080AC <> Nil
				// Monta o registro T080AC
				fRegT080AC(aCodTrib[nCount][1],nRegraTrb,@a_RgT080AC,n_ItT080,n_ItT080AA,n_ItT080AB,a_ClasFis,aPisCofP,aDIfalFcp)
			EndIf
		EndIf
	Next
Next

// Se possui recno da CDG
If !Empty(n_RecnoCDG)
	// Posiciona na tabela.
	lAchouCDG := SpedSeek("CDG",,,n_RecnoCDG)
EndIf

// Se foi para gerar o registro T015AE, os campos CCF_IDITEM e CCF_TRIB existem e tem registro na CDG.
If a_RgT015AE <> Nil .And. lCCFIdiTem .And. lCCFTrib .And. lAchouCDG
	// Função para buscar os tributos não calculados na nota através do processo.
	aCodTribN := fTrbNoCalc()

	// Roda todas as tributações que não foram calculadas.
	For nCount := 1 To Len(aCodTribN)
		
		// Monta o registro T015AE
		fT015AENCl(aCodTribN[nCount],@a_RgT015AE,n_ItT015)
	Next
EndIf

//Ordenacao Apenas Se Utilizar Os Tributos Do Novo Motor Fiscal
If !Empty( cNewFRural )
	aSort(a_RgT013AP,,,{|X, Y| X[2] < Y[2]}) //Niveis Das Obrigacoes Totalizadas
	aSort(a_RgT015AE,,,{|X, Y| cValToChar(X[1])+X[2][1][2] < cValToChar(Y[1])+Y[2][1][2]}) //Níveis Do Item + Nivel Das Obrigacoes
EndIf

Return Nil

/*/{Protheus.doc} fDIfalFcp
Função para retornar as informações do DIfAL e FCP.

@author Vitor Ribeiro
@since  10/01/2018

@return array multidimensional, contem as informações do dIfal e FCP. 
/*/
Static Function fDIfalFcp( c_NotaUF, cMVSUBTRIB, cMV_DifTr )
	
	Local lDIfalFcp := .F.
	Local aDIfalFcp := {0,0,0,0,0}
	
	Default c_NotaUF := SFT->FT_ESTADO
	Default cMVSUBTRIB := ""
	Default cMV_DIfTr	:= ""
	// Se existe o campo FT_DIfAL e o FT_VFCPDIf
	lDIfalFcp := oFisaExtSx:_FT_DIFAL .And. oFisaExtSx:_FT_VFCPDIF
	
	If lDIfalFcp

		// Se tem o campo D1_ALIQCMP
		If oFisaExtSx:_D1_ALIQCMP
			aDIfalFcp[NALQDIfALC] := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_ALIQCMP,SD2->D2_ALIQCMP)
		EndIf
		
		// Se tem o campo D1_ALFCCMP
		If oFisaExtSx:_D1_ALFCCMP
			aDIfalFcp[NALQFECPCM] := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_ALFCCMP,SD2->D2_ALFCCMP)
		EndIf
		
		// Se existir valor de DIfal ou FCP
		If SFT->FT_PDDES > 0 .Or. SFT->FT_VFCPDIf > 0  
		 	
			If SFT->FT_TIPOMOV == "E" .And. SFT->FT_TIPO $ "B/D"
			
				//Para devolução precisa inverter, o destino é o próprio contribuinte.
				aDIfalFcp[NDIfALDEST] := SFT->FT_ICMSCOM
				
				If c_NotaUF $ cMVSUBTRIB .Or. c_NotaUF $ cMV_DIfTr
					aDIfalFcp[NDIfALORIG] := SFT->FT_DIfAL		// Deverá ver se é inscrito
					aDIfalFcp[NDIfALFECP] := SFT->FT_VFCPDIf	// Sempre ve se é inscrito
				EndIf
				
			ElseIf SFT->FT_TIPOMOV == "S"
				
				aDIfalFcp[NDIfALDEST] := SFT->FT_DIfAL			// Deverá ver se é inscrito
				aDIfalFcp[NDIfALORIG] := SFT->FT_ICMSCOM		// 
				aDIfalFcp[NDIfALFECP] := SFT->FT_VFCPDIf		// Sempre ve se é inscrito
				
			EndIf
		EndIf
	EndIf
	
Return aDIfalFcp

/*
	Posição do array aCodTrib retorno da função fRegrTrbNf
*/
#Define N01ISSQN	01	// 01=ISSQN - Imposto Sobre Servico
#Define N02ICMS		02	// 02=ICMS - Imposto sobre circulacao de Servicos e Mercadorias
#Define N03ICMSCMP	03	// 03=ICMS Complementar
#Define N04ICMSST	04	// 04=ICMS/ST
#Define N05IPI		05	// 05=IPI - Imposto Sobre Produto Industrializado
#Define N06PIS		06	// 06=PIS
#Define N07COFINS	07	// 07=Cofins
#Define N08PISST 	08	// 08=PIS/ST
#Define N09COFST 	09	// 09=Cofins/ST
#Define N10PISRETE	10	// 10=Pis Retencao
#Define N11COFRETE	11	// 11=Cofins Retencao
#Define N12IR 		12	// 12=IR EMISSÃO | 28=IR PAGAMENTO
#Define N13PREVIDE	13	// 13=Previdencia
#Define N14PISIMPO	14	// 14=PIS Importacao
#Define N15COFIMPO	15	// 15=Cofins Importacao
#Define N16ISSRETE	16	// 16=ISSQN Retido
#Define N17ICMSANT	17	// 17=ICMS Antecipado
#Define N18CSLL		18	// 18=CSLL
#Define N19IRPJ		19	// 19=IRPJ
#Define N20DIfORIG	20	// 20=DIfal Origem
#Define N21DIfDEST	21	// 21=DIfal Destino
#Define N22FCPDEST	22	// 22=FCP Destino
#Define N23CPRB		23	// 23=CPRB
#Define N24GILRAT	24	// 24=GILRAT
#Define N25SENAR	25	// 25=SENAR
#Define N26ICSTSUB	26	// 26=ICMS/ST - SUBSTITUIDO (IMPOSTO SOBRE CIRCULACAO DE MERCADORIAS E SERVICOS - SUBSTITUIDO )

/*
	Quantidade de tributo para o tamanho do array aCodTrib montado na função fRegrTrbNf
*/
#Define NQTDETRIB	26

/*/{Protheus.doc} fRegrTrbNf
Função para executar as regras de tributos referente a nota

@author Vitor Ribeiro
@since  10/01/2018

@return array multidimensional, contem qual o codigo do tributo conforme o layout do T013AP e T015AE do TAF, referencia no campo 'COD_TRIB', e a segunda posição um array logico com possibilidade . 
/*/
Static Function fRegrTrbNf()
	
	Local cCfop := "1922|2922|5922|6922"   //CFOs especificos de lançamentos futuros que possuem ICMS zerados.  
    Local aCodTrib := {}
	Local lNfEnt := .F.
	Local lNfSai := .F.
	Local lDIfalFcp := .F.

	// Cria um array com o total de tributos definidos
	aCodTrib := Array(NQTDETRIB,2)
	
	/*
		Objetivo do array na segunda posição, é cada linha no mesmo ser uma regra para o tributo.
		Exemplo: Verificar a linha do tributo 17=ICMS Antecipado
	*/
	// Inicializa o array
	AEval(aCodTrib,{|x| x[1] := "", x[2] := {} })
	
	// Nota fiscal de entrada
	lNfEnt := SFT->FT_TIPOMOV == "E"
	
	// Nota Fiscal de saída
	lNfSai := SFT->FT_TIPOMOV == "S"
	
	// Se existe o campo FT_DIfAL e o FT_VFCPDIf
	lDIfalFcp := oFisaExtSx:_FT_DIFAL .And. oFisaExtSx:_FT_VFCPDIF
	
	// 01=ISSQN - Imposto Sobre Servico
	aCodTrib[N01ISSQN][1] := "01"
	Aadd(aCodTrib[N01ISSQN][2],!Empty(SFT->FT_CODISS) .and. SFT->FT_RECISS == '1' )


	// 02=ICMS - Imposto sobre circulacao de Servicos e Mercadorias
	aCodTrib[N02ICMS][1] := "02"
	Aadd(aCodTrib[N02ICMS][2],Empty(SFT->FT_CODISS) .And. ( SFT->FT_BASEICM > 0 .Or. SFT->FT_VALICM > 0 .Or. SFT->FT_OUTRICM > 0 .Or. SFT->FT_ISENICM > 0 .Or. Alltrim(SFT-> FT_CFOP) $ cCfop ))

	// 03=ICMS Complementar
	aCodTrib[N03ICMSCMP][1] := "03"
	Aadd(aCodTrib[N03ICMSCMP][2],SFT->FT_ICMSCOM > 0 .And. (!lDIfalFcp .Or. SFT->FT_DIfAL <= 0))
	
	// 04=ICMS/ST
	aCodTrib[N04ICMSST][1] := "04"
	Aadd(aCodTrib[N04ICMSST][2],SFT->FT_ICMSRET > 0 .And. SFT->FT_CREDST <> "4")
	
	// 05=IPI - Imposto Sobre Produto Industrializado
	aCodTrib[N05IPI][1] := "05"
	Aadd(aCodTrib[N05IPI][2],SFT->FT_ALIQIPI > 0 .Or. SFT->FT_BASEIPI > 0 .Or. SFT->FT_ISENIPI > 0 .Or. SFT->FT_OUTRIPI > 0)
	
	// 06=PIS
	aCodTrib[N06PIS][1] := "06"
	If lNfEnt
		Aadd(aCodTrib[N06PIS][2],SFT->FT_BASEPIS > 0  .Or.  SFT->FT_BASEPS3 > 0 .Or. SFT->FT_CSTPIS $ "70|71|72|74|98|99|")
	ElseIf lNfSai
		Aadd(aCodTrib[N06PIS][2],SFT->FT_BASEPIS > 0  .Or.  SFT->FT_BASEPS3 > 0 .Or. SFT->FT_CSTPIS $ "01|07|08|09|49|")
	EndIf
	
	// 07=Cofins
	aCodTrib[N07COFINS][1] := "07"
	If lNfEnt
		Aadd(aCodTrib[N07COFINS][2],SFT->FT_BASECOF > 0  .Or.  SFT->FT_BASECF3 > 0 .Or. SFT->FT_CSTCOF $ "70|71|72|74|98|99|")
	ElseIf lNfSai
		Aadd(aCodTrib[N07COFINS][2],SFT->FT_BASECOF > 0  .Or.  SFT->FT_BASECF3 > 0 .Or. SFT->FT_CSTCOF $ "01|07|08|09|49|")
	EndIf
	
	// 08=PIS/ST
	aCodTrib[N08PISST][1] := "08"
	Aadd(aCodTrib[N08PISST][2],SFT->FT_ALIQPS3 > 0)
	
	// 09=Cofins/ST
	aCodTrib[N09COFST][1] := "09"
	Aadd(aCodTrib[N09COFST][2],SFT->FT_ALIQCF3 > 0)
	
	// 10=Pis Retencao
	aCodTrib[N10PISRETE][1] := "10"
	Aadd(aCodTrib[N10PISRETE][2],SFT->FT_VRETPIS > 0)
	
	// 11=Cofins Retencao
	aCodTrib[N11COFRETE][1] := "11"
	Aadd(aCodTrib[N11COFRETE][2],SFT->FT_VRETCOF > 0)
	
	// 12=IR EMISSÃO | 28=IR PAGAMENTO
	cCalcIr := SA2->A2_CALCIRF
			
	iF cCalcIr <> '2' 
		aCodTrib[N12IR][1] := '12' 
	elseif cCalcIr == '2' 
		aCodTrib[N12IR][1] := "28"
	EndIf
	Aadd(aCodTrib[N12IR][2],SFT->FT_BASEIRR > 0)
	
	// 13=Previdencia
	aCodTrib[N13PREVIDE][1] := "13"
	Aadd(aCodTrib[N13PREVIDE][2],SFT->FT_BASEINS > 0)
	
	// 14=PIS Importacao
	aCodTrib[N14PISIMPO][1] := "14"
	Aadd(aCodTrib[N14PISIMPO][2],.F.)
	
	// 15=Cofins Importacao
	aCodTrib[N15COFIMPO][1] := "15"
	Aadd(aCodTrib[N15COFIMPO][2],.F.)
	
	// 16=ISSQN Retido
	aCodTrib[N16ISSRETE][1] := "16"
	Aadd(aCodTrib[N16ISSRETE][2],!Empty(SFT->FT_CODISS) .and. SFT->FT_RECISS == '2')
	
	// 17=ICMS Antecipado
	aCodTrib[N17ICMSANT][1] := "17"
	Aadd(aCodTrib[N17ICMSANT][2],(SF4->F4_ANTICMS == "1" .And. SFT->FT_VALANTI > 0 .And. SF4->F4_SITTRIB $ "10/30/60/70"))
	
	// 18=CSLL
	aCodTrib[N18CSLL][1] := "18"
	Aadd(aCodTrib[N18CSLL][2], SFT->FT_BRETCSL > 0 )
	
	// 19=IRPJ
	aCodTrib[N19IRPJ][1] := "19"
	Aadd(aCodTrib[N19IRPJ][2],.F.)
	
	// 20=DIfal Origem
	aCodTrib[N20DIfORIG][1] := "20"
	Aadd(aCodTrib[N20DIfORIG][2],lDIfalFcp .And. SFT->FT_PDDES > 0)
	
	// 21=DIfal Destino
	aCodTrib[N21DIfDEST][1] := "21"
	Aadd(aCodTrib[N21DIfDEST][2],lDIfalFcp .And. SFT->FT_PDDES > 0)
	
	// 22=FCP Destino
	aCodTrib[N22FCPDEST][1] := "22"
	Aadd(aCodTrib[N22FCPDEST][2],lDIfalFcp .And. SFT->FT_VFCPDIf > 0)
	
	// 23=CPRB
	aCodTrib[N23CPRB][1] := "23"
	Aadd(aCodTrib[N23CPRB][2],SFT->FT_BASECPB > 0)
	
	// 24=GILRAT 
	aCodTrib[N24GILRAT][1] := "24"
	Aadd(aCodTrib[N24GILRAT][2],(lNfEnt .And. SD1->D1_BASEFUN > 0) .Or. (lNfSai .And. SD2->D2_BASEFUN > 0))
	
	// 25=SENAR
	aCodTrib[N25SENAR][1] := "25"
	Aadd(aCodTrib[N25SENAR][2],SFT->FT_BSSENAR > 0)
	
	// 26=ICMS/ST - SUBSTITUIDO (IMPOSTO SOBRE CIRCULACAO DE MERCADORIAS E SERVICOS - SUBSTITUIDO ) 
	aCodTrib[N26ICSTSUB][1] := "26"
	Aadd(aCodTrib[N26ICSTSUB][2],(SFT->FT_ICMSRET > 0 .And. SFT->FT_CREDST == "4"))
	
	/*
		Nesse treicho, garanto que sempre existirá uma posição falsa no array da segunda posição.
	*/
	AEval(aCodTrib,{|x| IIf(Empty(x[2]),Aadd(x[2],.F.),) })
	
Return aCodTrib

/*/{Protheus.doc} VerPPisCof
Função para verIficar a pauta referente ao PIS e COFINS.

@author Vitor Ribeiro
@since  10/01/2018

@param a_CodTrib, array, contém quais tributos foram cobrados referente ao registro

@return array multidimensional, contem a pauta e a quantidade do pis e cofins. 
/*/
Static Function VerPPisCof(a_CodTrib)
	
	Local lTribPis := .F.
	Local lTribCof := .F.
	
	Local aPisCofP := {{0,0},{0,0}}
	
	Local oNotaEfd := Nil 
	
	Default a_CodTrib := {}
	
	If !Empty(a_CodTrib)
		
		// Verifica se tem alguma regra de pis na nota
		lTribPis := Ascan(a_CodTrib[N06PIS][2],{|x| x == .T. }) > 0
		
		// Verifica se tem alguma regra de cofins na nota
		lTribCof := Ascan(a_CodTrib[N07COFINS][2],{|x| x == .T. }) > 0
		
		// Se tiver pis
		If lTribPis
			lTribPis := .F.
			
			If SFT->FT_VALPIS > 0 .Or. SFT->FT_BASEPIS > 0 .Or. SFT->FT_ALIQPIS > 0
				If SFT->FT_PAUTPIS > 0 .Or. SB1->B1_VLR_PIS > 0
					lTribPis := .T.
				EndIf
			EndIf
		EndIf
		
		// Se tiver Cofins
		If lTribCof
			lTribCof := .F.
			
			If SFT->FT_VALCOF > 0 .Or. SFT->FT_BASECOF > 0 .Or. SFT->FT_ALIQCOF > 0
				If SFT->FT_PAUTCOF > 0 .Or. SB1->B1_VLR_COF > 0
					lTribCof := .T.
				EndIf
			EndIf
		EndIf
		
		// Se tem pis e cofins
		If lTribPis .Or. lTribCof
		
			// Guarda a pauta e a quantidade referente ao PIS
			aPisCofP[NPAUTAPIS][1] := SFT->FT_PAUTPIS
			aPisCofP[NPAUTAPIS][2] := SFT->FT_QUANT
			
			// Guarda a pauta e a quantidade referente ao COFINS
			aPisCofP[NPAUTACOF][1] := SFT->FT_PAUTCOF
			aPisCofP[NPAUTACOF][2] := SFT->FT_QUANT
			
			// Estancia o objeto
			oNotaEfd := NotaEfd():New()
			
			oNotaEfd:setTNatRec(SFT->FT_TNATREC)
			oNotaEfd:setCNatRec(SFT->FT_CNATREC)
			oNotaEfd:setGNatRec(SFT->FT_GRUPONC)
			oNotaEfd:setDNatRec(SFT->FT_DTFIMNT)
			oNotaEfd:setiQtde(SFT->FT_QUANT)
			
			// Pis
			If lTribPis
				//Faz conversão de valores de pauta de PIS
				oNotaEfd:setVlPauta(SFT->FT_PAUTPIS)
				oNotaEfd:setiBsPaut(SFT->FT_BASEPIS)
				
				If oNotaEfd:OperPauta("1",oFisaExtSx:_MV_PISCOFP)
					aPisCofP[NPAUTAPIS][1] := oNotaEfd:getAlqReal()
					aPisCofP[NPAUTAPIS][2] := oNotaEfd:getBaseQtd()
				EndIf
			EndIf
			
			// Cofins
			If lTribCof
				//Faz conversão de valores de pauta de COFINS
				oNotaEfd:setVlPauta(SFT->FT_PAUTCOF)
				oNotaEfd:setiBsPaut(SFT->FT_BASECOF)
				
				If oNotaEfd:OperPauta("2",oFisaExtSx:_MV_PISCOFP)
					aPisCofP[NPAUTACOF][1] := oNotaEfd:getAlqReal()
					aPisCofP[NPAUTACOF][2] := oNotaEfd:getBaseQtd()
				EndIf
			EndIf
		EndIf
	EndIf
	
Return aPisCofP

/*
	Posição do array a_RgT013AP conforme o layout do TAF do registro T013AP.
*/
#Define NAPREGISTR	01	// REGISTRO
#Define NAPCODTRIB	02	// COD_TRIB
#Define NAPBS		03	// BASE
#Define NAPBSQTD	04	// BASE_QUANT
#Define NAPBSNT		05	// BASE_NT
#Define NAPVLR		06	// VALOR
#Define NAPVLRTRIB	07	// VLR_TRIBUTAVEL
#Define NAPVLRISEN	08	// VLR_ISENTO
#Define NAPVLROUTR	09	// VLR_OUTROS
#Define NAPVLRNT	10	// VALOR_NT
#Define NAPCST		11	// CST
#Define NAPCFOP		12	// CFOP
#Define NAPALIQ		13	// ALIQUOTA
#Define NAPCODLST	14	// COD_LST
#Define NAPVLROPER	15	// VL_OPER
#Define NAPVLRSCRE	16	// VL_SCRED
#Define TRIBICMSST	17	// TRIBICMSST

/*/{Protheus.doc} fRegT013AP
Função para montar o registro T013AP.

@author Vitor Ribeiro
@since  10/01/2018

@param c_CodTrb, caracter, codigo do tributo.
@param n_RegraTrb, numerico, posição da regra do tributo.
@param a_RgT013AP, array, será utilizado para montar as informações do registro T013AP
@param a_ClasFis, array, contém a classIficação fiscal.
@param a_PisCofP, array, contém a pauta e a quantidade do pis e cofins.
@param a_DIfalFcp, array, contém as informações do DIfAL e do FCP.

@return nulo, não tem retorno. 
/*/
Static Function fRegT013AP(c_CodTrb,n_RegraTrb,a_RgT013AP,a_ClasFis,a_PisCofP,a_DIfalFcp)

	Local nPosicao 		:= 0
	Local nValor 		:= 0
	Local nBasGILRAT	:= 0
	Local nAlqGILRAT	:= 0
	Local nValGILRAT	:= 0

	Local cCfop := ""
	Local cCodIss := ""

	Local lSFTVALFUN := IIf(SFT->(FieldPos("FT_VALFUN")) > 0,.T.,.F.)
	Local lSFTBASFUN := IIf(SFT->(FieldPos("FT_BASEFUN")) > 0,.T.,.F.)
	Local lSFTALQFUN := IIf(SFT->(FieldPos("FT_ALIQFUN")) > 0,.T.,.F.)

	Local bAscan := {|| }

	Default c_CodTrb := ""

	Default n_RegraTrb := 0

	Default a_RgT013AP := {}
	Default a_ClasFis := {}
	Default a_PisCofP := {}
	Default a_DIfalFcp := {}
	
	// Guarda o CFOP da nota fiscal. 
	cCfop := SFT->FT_CFOP
	
	// Inicializa o codigo de iss utilizado somente para o imposto 01=ISSQN
	cCodIss := ""
	// Quando utilizar CFOP antigo por ser nota de serviço, converto o CFOP para 5933/1933
		If Len(AllTrim(cCfop)) <= 3 .And. !Empty(SFT->FT_TIPOMOV)
			// CFOP de serviço
			If SFT->FT_TIPOMOV == "S"
				cCfop := "5933"
			Else
				cCfop := "1933"
			EndIf
		EndIf
	/*
		Esse treicho cuida das regras de agrupamento preenchendo a variavel bAscan.
	*/
If c_CodTrb == "01" .And. n_RegraTrb == 1		// 01=ISSQN
	/*
		Obtendo o codigo do ISS atraves do cadastro da tabela CDN. Este codigo deverá estar conforme LC 166/03
		Tratamento para considerar também mais de um Cod LST por Cod ISS, conforme a legislação existe a possibilidade de ser n para n
	*/
	cCodIss := SubStr(SFT->FT_CODISS,1,5)
	
	If CDN->(MsSeek(xFilial("CDN") + PadR(cCodIss,8) + AllTrim(SB1->B1_COD)))
		cCodIss := SubStr(CDN->CDN_CODLST,1,4)
	ElseIf CDN->(MsSeek(xFilial("CDN") + PadR(cCodIss,8)))
		cCodIss := SubStr(CDN->CDN_CODLST,1,4)
	Else
		cCodIss := ""
	EndIf
	
	// Tiro todos os pontos que estiverem no cadastro
	cCodIss := StrTran(cCodIss,".","")
	
	bAscan := {|x| x[NAPCODTRIB] == c_CodTrb .And. x[NAPCFOP] == cCfop .And. x[NAPCODLST] == cCodIss .And. x[NAPALIQ] == SFT->FT_ALIQICM }

ElseIf c_CodTrb == "02" .And. n_RegraTrb == 1	// 02=ICMS
	
	bAscan := {|x| x[NAPCODTRIB] == c_CodTrb .And. x[NAPCST] == a_ClasFis[1] .And. x[NAPCFOP] == cCfop .And. x[NAPALIQ] == SFT->FT_ALIQICM }
	
ElseIf c_CodTrb == "05" .And. n_RegraTrb == 1	// 05=IPI
	
	bAscan := {|x| x[NAPCODTRIB] == c_CodTrb .And. x[NAPCST] == a_ClasFis[2] .And. x[NAPCFOP] == cCfop .And. x[NAPALIQ] == SFT->FT_ALIQIPI }
	
ElseIf c_CodTrb == "06" .And. n_RegraTrb == 1	// 06=PIS
	
	bAscan := {|x| x[NAPCODTRIB] == c_CodTrb .And. x[NAPCST] == a_ClasFis[3] .And. x[NAPCFOP] == cCfop .And. x[NAPALIQ] == IIf(!Empty(a_PisCofP[NPAUTAPIS][1]),a_PisCofP[NPAUTAPIS][1],SFT->FT_ALIQPIS) }
	
ElseIf c_CodTrb == "07" .And. n_RegraTrb == 1	// 07=Cofins
	
	bAscan := {|x| x[NAPCODTRIB] == c_CodTrb .And. x[NAPCST] == a_ClasFis[4] .And. x[NAPCFOP] ==  cCfop .And. x[NAPALIQ] == IIf(!Empty(a_PisCofP[NPAUTACOF][1]),a_PisCofP[NPAUTACOF][1],SFT->FT_ALIQCOF) }
	
ElseIf c_CodTrb == "08" .And. n_RegraTrb == 1	// 08=PIS/ST
	
	bAscan := {|x| x[NAPCODTRIB] == c_CodTrb .And. x[NAPCFOP] == cCfop .And. x[NAPALIQ] == SFT->FT_ALIQPS3 }
	
ElseIf c_CodTrb == "09" .And. n_RegraTrb == 1	// 09=Cofins/ST 
	
	bAscan := {|x| x[NAPCODTRIB] == c_CodTrb .And. x[NAPCFOP] == cCfop .And. x[NAPALIQ] == SFT->FT_ALIQCF3 }
	
ElseIf c_CodTrb == "10" .And. n_RegraTrb == 1	// 10=Pis Retencao
	
	bAscan := {|x| x[NAPCODTRIB] == c_CodTrb .And. x[NAPCST] == a_ClasFis[3] .And. x[NAPCFOP] == cCfop .And. x[NAPALIQ] == SFT->FT_ARETPIS }
	
ElseIf c_CodTrb == "11" .And. n_RegraTrb == 1	// 11=Cofins Retencao
	
	bAscan := {|x| x[NAPCODTRIB] == c_CodTrb .And. x[NAPCST] == a_ClasFis[3] .And. x[NAPCFOP] == cCfop .And. x[NAPALIQ] == SFT->FT_ARETCOF }
	
ElseIf c_CodTrb == "18" .And. n_RegraTrb == 1	// 18=CSLL
	
	bAscan := {|x| x[NAPCODTRIB] == c_CodTrb .And. x[NAPCFOP] == cCfop .And. x[NAPALIQ] == SFT->FT_ARETCSL }

Else	
	/*
		"03" 03=ICMS Complementar 
		"04" 04=ICMS/ST 
		"12" 12=IR 
		"13" 13=Previdencia 
		"17" 17=ICMS Antecipado 
		"20" 20=DIfal Origem 
		"21" 21=DIfal Destino 
		"22" 22=FCP Destino 
		"23" 23=CPRB
		"24" 24=GILRAT
		"25" 25=SENAR
		"26" 26=ICMS/ST - SUBSTITUIDO
	*/
	
	bAscan := {|x| x[NAPCODTRIB] == c_CodTrb .And. x[NAPCFOP] == cCfop }
EndIf

// VerIfique a posição da tributação no array caso o mesmo exista.
nPosicao := Ascan(a_RgT013AP,bAscan)
	
	// Se não existe essa tributação no array.
	If Empty(nPosicao)
		Aadd(a_RgT013AP,{})
		nPosicao := Len(a_RgT013AP)
		
		/*
			Inicializa a linha de impostos
		*/
		Aadd(a_RgT013AP[nPosicao],"")	// 01	->	REGISTRO		->	NAPREGISTR
		Aadd(a_RgT013AP[nPosicao],"")	// 02	->	COD_TRIB		->	NAPCODTRIB
		Aadd(a_RgT013AP[nPosicao],0)	// 03	->	BASE - NAPBS	->	NAPBS
		Aadd(a_RgT013AP[nPosicao],0) 	// 04	->	BASE_QUANT		->	NAPBSQTD
		Aadd(a_RgT013AP[nPosicao],0) 	// 05	->	BASE_NT			->	NAPBSNT
		Aadd(a_RgT013AP[nPosicao],0)	// 06	->	VALOR			->	NAPVLR
		Aadd(a_RgT013AP[nPosicao],0) 	// 07	->	VLR_TRIBUTAVEL	->	NAPVLRTRIB
		Aadd(a_RgT013AP[nPosicao],0)	// 08	->	VLR_ISENTO		->	NAPVLRISEN
		Aadd(a_RgT013AP[nPosicao],0)	// 09	->	VLR_OUTROS		->	NAPVLROUTR
		Aadd(a_RgT013AP[nPosicao],0)	// 10	->	VALOR_NT		->	NAPVLRNT
		Aadd(a_RgT013AP[nPosicao],"")	// 11	->	CST				->	NAPCST
		Aadd(a_RgT013AP[nPosicao],"")	// 12	->	CFOP			->	NAPCFOP
		Aadd(a_RgT013AP[nPosicao],0)	// 13	->	ALIQUOTA		->	NAPALIQ
		Aadd(a_RgT013AP[nPosicao],"") 	// 14	->	COD_LST			->	NAPCODLST
		Aadd(a_RgT013AP[nPosicao],0)	// 15	->	VL_OPER			->	NAPVLROPER
		Aadd(a_RgT013AP[nPosicao],0) 	// 16	->	VL_SCRED 		->	NAPVLRSCRE
		Aadd(a_RgT013AP[nPosicao],0) 	// 17	->	TRIBICMSST		->	TRIBICMSST
		
		a_RgT013AP[nPosicao][NAPREGISTR] := "T013AP"
		a_RgT013AP[nPosicao][NAPCODTRIB] := c_CodTrb
	EndIf

	// Campos com informação igual para todas as tributações.
	a_RgT013AP[nPosicao][NAPCFOP] 	 := cCfop
	a_RgT013AP[nPosicao][NAPCODLST]	 := cCodIss
	a_RgT013AP[nPosicao][NAPVLROPER] += SFT->FT_VALCONT

	// Preenche os campos conforme a tributação
	If c_CodTrb $ "01|02|16" .And. n_RegraTrb == 1		// 01=ISSQN | 02=ICMS | 16=ISSQN Retido 
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASEICM
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VALICM
		a_RgT013AP[nPosicao][NAPVLRISEN] += SFT->FT_ISENICM
		a_RgT013AP[nPosicao][NAPVLROUTR] += SFT->FT_OUTRICM
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ALIQICM
		
		// Diferente dos outros impostos, a função SPDRetCCST() (SPEDXFUN.PRW) responsável por popular o array a_ClasFis 
		// não trata ISS, o campo FT_CSTISS já recebe o consteúdo em acordo com o TAF, não sendo necessário ajustes na função SPDRetCCST()
		If c_CodTrb $ "01|16" // 01=ISSQN | 16=ISSQN Retido 
			a_RgT013AP[nPosicao][NAPCST] := SFT->FT_CSTISS
		Endif
		If c_CodTrb == "02"		// 02=ICMS
			
			a_RgT013AP[nPosicao][NAPCST] := a_ClasFis[1]
			a_RgT013AP[nPosicao][NAPVLRSCRE] += FIcmSemCred()
			
		EndIf
		
	ElseIf c_CodTrb == "03" .And. n_RegraTrb == 1	// 03=ICMS Complementar
		
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_ICMSCOM
		a_RgT013AP[nPosicao][NAPALIQ] := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_ALIQCMP,SD2->D2_ALIQCMP)
		
	ElseIf c_CodTrb == "04" .And. n_RegraTrb == 1	// 04=ICMS/ST | 17=ICMS Antecipado
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASERET
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_ICMSRET
		a_RgT013AP[nPosicao][NAPVLRISEN] += SFT->FT_ISENRET
		a_RgT013AP[nPosicao][NAPVLROUTR] += SFT->FT_OUTRRET
		a_RgT013AP[nPosicao][NAPCST] := a_ClasFis[1]
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ALIQSOL
		Iif( SFT->FT_CLASFIS == '60' .AND. SFT->FT_ICMNDES > 0,  a_RgT013AP[nPosicao][TRIBICMSST] := SFT->FT_ICMNDES, )		//VERIFCAR VALOR E TIPO DO CAMPO --ALLTRIM
		
	ElseIf c_CodTrb == "05" .And. n_RegraTrb == 1	// 05=IPI
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASEIPI
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VALIPI
		a_RgT013AP[nPosicao][NAPVLRISEN] += SFT->FT_ISENIPI
		a_RgT013AP[nPosicao][NAPVLROUTR] += SFT->FT_OUTRIPI
		a_RgT013AP[nPosicao][NAPCST] := a_ClasFis[2]
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ALIQIPI
		
	ElseIf c_CodTrb == "06" .And. n_RegraTrb == 1	// 06=PIS
		
		If SFT->FT_VALPIS > 0 .Or. SFT->FT_BASEPIS > 0 .Or. SFT->FT_ALIQPIS > 0
			If SFT->FT_PAUTPIS > 0 .Or. SB1->B1_VLR_PIS > 0
				nValor := SFT->FT_VALPIS
			EndIf
		EndIf
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASEPIS
		a_RgT013AP[nPosicao][NAPBSQTD] += a_PisCofP[NPAUTAPIS][2]
		a_RgT013AP[nPosicao][NAPVLR] += IIf(SFT->FT_CSTPIS $ "07|08|71|74" .And. Empty(a_PisCofP[NPAUTAPIS][1]),0,SFT->FT_VALPIS)
		a_RgT013AP[nPosicao][NAPVLRTRIB] += IIf(!Empty(nValor),nValor,0)
		a_RgT013AP[nPosicao][NAPVLRISEN] += IIf(SFT->FT_CSTPIS $ "07|71",SFT->FT_VALPIS,0)
		a_RgT013AP[nPosicao][NAPVLRNT] += IIf(SFT->FT_CSTPIS $ "08|74",SFT->FT_VALPIS,0)
		a_RgT013AP[nPosicao][NAPCST] := a_ClasFis[3]
		a_RgT013AP[nPosicao][NAPALIQ] := IIf(!Empty(a_PisCofP[NPAUTAPIS][1]),a_PisCofP[NPAUTAPIS][1],SFT->FT_ALIQPIS)
		
	ElseIf c_CodTrb == "07" .And. n_RegraTrb == 1	// 07=Cofins
		
		If SFT->FT_VALCOF > 0 .Or. SFT->FT_BASECOF > 0 .Or. SFT->FT_ALIQCOF > 0
			If SFT->FT_PAUTCOF > 0 .Or. SB1->B1_VLR_COF > 0
				nValor := SFT->FT_VALCOF
			EndIf
		EndIf
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASECOF
		a_RgT013AP[nPosicao][NAPBSQTD] += a_PisCofP[NPAUTACOF][2]
		a_RgT013AP[nPosicao][NAPVLR] += IIf(SFT->FT_CSTCOF $ "07|08|71|74" .And. Empty(a_PisCofP[NPAUTACOF][1]),0,SFT->FT_VALCOF)
		a_RgT013AP[nPosicao][NAPVLRTRIB] += IIf(!Empty(nValor),nValor,0)
		a_RgT013AP[nPosicao][NAPVLRISEN] += IIf(SFT->FT_CSTCOF $ "07|71",SFT->FT_VALCOF,0)
		a_RgT013AP[nPosicao][NAPVLRNT] += IIf(SFT->FT_CSTCOF $ "08|74",SFT->FT_VALCOF,0)
		a_RgT013AP[nPosicao][NAPCST] := a_ClasFis[4]
		a_RgT013AP[nPosicao][NAPALIQ] := IIf(!Empty(a_PisCofP[NPAUTACOF][1]),a_PisCofP[NPAUTACOF][1],SFT->FT_ALIQCOF)
		
	ElseIf c_CodTrb == "08" .And. n_RegraTrb == 1	// 08=PIS/ST
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASEPS3
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VALPS3
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ALIQPS3
		
	ElseIf c_CodTrb == "09" .And. n_RegraTrb == 1	// 09=Cofins/ST
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASECF3
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VALCF3
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ALIQCF3
		
	ElseIf c_CodTrb == "10" .And. n_RegraTrb == 1	// 10=Pis Retencao
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BRETPIS
		a_RgT013AP[nPosicao][NAPBSQTD] += SFT->FT_QUANT
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VRETPIS
		a_RgT013AP[nPosicao][NAPVLRISEN] += IIf(SFT->FT_CSTPIS $ "07|71",SFT->FT_VRETPIS,0)
		a_RgT013AP[nPosicao][NAPVLRNT] += IIf(SFT->FT_CSTPIS $ "08|74",SFT->FT_VRETPIS,0)
		a_RgT013AP[nPosicao][NAPCST] := a_ClasFis[3]
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ARETPIS
		
	ElseIf c_CodTrb == "11" .And. n_RegraTrb == 1	// 11=Cofins Retencao
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BRETCOF
		a_RgT013AP[nPosicao][NAPBSQTD] += SFT->FT_QUANT
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VRETCOF
		a_RgT013AP[nPosicao][NAPVLRISEN] += IIf(SFT->FT_CSTCOF $ "07|71",SFT->FT_VRETCOF,0)
		a_RgT013AP[nPosicao][NAPVLRNT] += IIf(SFT->FT_CSTCOF $ "08|74",SFT->FT_VRETCOF,0)
		a_RgT013AP[nPosicao][NAPCST] := a_ClasFis[3]
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ARETCOF
		
	ElseIf c_CodTrb == "12" .And. n_RegraTrb == 1	// 12=IR
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASEIRR
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VALIRR
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ALIQIRR
							
	ElseIf c_CodTrb == "13" .And. n_RegraTrb == 1	// 13=Previdencia
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASEINS
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VALINS
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ALIQINS
		
	ElseIf c_CodTrb == "17" .And. n_RegraTrb == 1	// 17=ICMS Antecipado
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASEICM
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VALANTI
		a_RgT013AP[nPosicao][NAPVLRISEN] += SFT->FT_ISENICM
		a_RgT013AP[nPosicao][NAPVLROUTR] += SFT->FT_OUTRICM
		a_RgT013AP[nPosicao][NAPCST] := SF4->F4_SITTRIB
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ALIQICM
		
	ElseIf c_CodTrb == "18" .And. n_RegraTrb == 1	// 18=CSLL
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BRETCSL
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VRETCSL
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ARETCSL

	ElseIf c_CodTrb == "20" .And. n_RegraTrb == 1	// 20=DIfal Origem
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASEDES
		a_RgT013AP[nPosicao][NAPVLR] += a_DIfalFcp[NDIfALORIG]
		a_RgT013AP[nPosicao][NAPALIQ] := a_DIfalFcp[NALQDIfALC]					
		
	ElseIf c_CodTrb == "21" .And. n_RegraTrb == 1	// 21=DIfal Destino
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASEDES
		a_RgT013AP[nPosicao][NAPVLR] += a_DIfalFcp[NDIfALDEST]
		a_RgT013AP[nPosicao][NAPALIQ] := a_DIfalFcp[NALQDIfALC]					
		
	ElseIf c_CodTrb == "22" .And. n_RegraTrb == 1	// 22=FCP Destino
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASEDES
		a_RgT013AP[nPosicao][NAPVLR] += a_DIfalFcp[NDIfALFECP]
		a_RgT013AP[nPosicao][NAPALIQ] := a_DIfalFcp[NALQFECPCM]					
		
	ElseIf c_CodTrb == "23" .And. n_RegraTrb == 1	// 23=CPRB
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASECPB
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VALCPB					
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ALIQCPB
		
	ElseIf c_CodTrb == "24" .And. n_RegraTrb == 1	// 24=GILRAT 

		If lSFTBASFUN .And. lSFTALQFUN .And. lSFTVALFUN .And. SFT->FT_VALFUN > 0
			nBasGILRAT := SFT->FT_BASEFUN
			nAlqGILRAT := SFT->FT_ALIQFUN
			nValGILRAT := SFT->FT_VALFUN
		Else
			nBasGILRAT := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_BASEFUN,SD2->D2_BASEFUN)
			nAlqGILRAT := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_ALIQFUN,SD2->D2_ALIQFUN)
			nValGILRAT := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_VALFUN,SD2->D2_VALFUN)
		EndIf
		
		a_RgT013AP[nPosicao][NAPBS] += nBasGILRAT
		a_RgT013AP[nPosicao][NAPALIQ] := nAlqGILRAT
		a_RgT013AP[nPosicao][NAPVLR] += nValGILRAT
		
	ElseIf c_CodTrb == "25" .And. n_RegraTrb == 1	// 25=SENAR
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BSSENAR
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_VLSENAR
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ALSENAR
		
	ElseIf c_CodTrb == "26" .And. n_RegraTrb == 1	// 26=ICMS/ST - SUBSTITUIDO
		
		a_RgT013AP[nPosicao][NAPBS] += SFT->FT_BASERET
		a_RgT013AP[nPosicao][NAPVLR] += SFT->FT_ICMSRET
		a_RgT013AP[nPosicao][NAPVLRISEN] += SFT->FT_ISENRET
		a_RgT013AP[nPosicao][NAPVLROUTR] += SFT->FT_OUTRRET
		a_RgT013AP[nPosicao][NAPCST] := a_ClasFis[1]
		a_RgT013AP[nPosicao][NAPALIQ] := SFT->FT_ALIQSOL		
	EndIf

Return Nil

/* 
	Posição do array a_RgT015AE conforme o layout do TAF do registro T015AE.
*/
#Define NAEREGISTR	01	// REGISTRO
#Define NAECODTRIB	02	// COD_TRIB
#Define NAECST		03	// CST
#Define NAEMODBC	04	// MODBC
#Define NAEMVA		05	// MVA
#Define NAEPRREDBS	06	// PERC_RED_BC
#Define NAEBS		07	// BASE
#Define NAEBSQTD	08	// BASE_QUANT
#Define NAEBSNT		09	// BASE_NT
#Define NAEALIQ		10	// ALIQUOTA
#Define NAEALIQQTD	11	// ALIQUOTA_QUANT
#Define NAEVLR		12	// VALOR
#Define NAEVLRTRIB	13	// VLR_TRIBUTAVEL
#Define NAECODENQ	14	// COD_ENQ
#Define NAEVLRISEN	15	// VLR_ISENTO
#Define NAEVLROUTR	16	// VLR_OUTROS
#Define NAEVLRNT	17	// VALOR_NT
#Define NAEBSICMUF	18	// VL_BC_ICMS_UF
#Define NAEVLICMUF	19	// VL_ICMS_UF
#Define NAECODANT	20	// COD_ANT
#Define NAEMTDSICM	21	// MT_DES_ICMS
#Define NAEVLRSCRE	22	// VL_SCRED
#Define NAEMTINCID	23	// MOT_INCIDENCIA
#Define NAEVLCONTR	24	// VLSCONTR
#Define NAEVLRADIC	25	// VLRADIC
#Define NAEVLRNPAG	26	// VLRNPAG
#Define NAEVLRCE15	27	// VLRCE15
#Define NAEVLRCE20	28	// VLRCE20
#Define NAEVLRCE25	29	// VLRCE25
#Define NAEVRDICPG	30	// VLRADICNPAG

/*/{Protheus.doc} fRegT015AE
Função para montar o registro T015AE.

@author Vitor Ribeiro
@since  10/01/2018

@param c_CodTrb, caracter, codigo do tributo.
@param n_RegraTrb, numerico, posição da regra do tributo.
@param a_RgT015AE, array, array aonde será montado o registro T015AE
@param n_ItT015, array, linha do item referente ao registro T015
@param a_ClasFis, array, contém a classIficação fiscal.
@param a_PisCofP, array, contém a pauta e a quantidade do pis e cofins.
@param a_DIfalFcp, array, contém as informações do DIfAL e do FCP.

@return nulo, não tem retorno. 
/*/
Static Function fRegT015AE(c_CodTrb,n_RegraTrb,a_RgT015AE,n_ItT015,a_ClasFis,a_PisCofP,a_DIfalFcp)

	Local nCount		:= 0
	Local nPosicao		:= 0
	Local nValor		:= 0
	Local nBasGILRAT	:= 0
	Local nAlqGILRAT	:= 0
	Local nValGILRAT	:= 0

	Local nTotVlCp 		:= 0
	Local nVBscp15 		:= 0
	Local nVBscp20 		:= 0
	Local nVBscp25 		:= 0

	Local lSFTVALFUN := IIf(SFT->(FieldPos("FT_VALFUN")) > 0,.T.,.F.)
	Local lSFTBASFUN := IIf(SFT->(FieldPos("FT_BASEFUN")) > 0,.T.,.F.)
	Local lSFTALQFUN := IIf(SFT->(FieldPos("FT_ALIQFUN")) > 0,.T.,.F.)

	Default c_CodTrb := ""
	
	Default n_RegraTrb := 0
	Default n_ItT015   := 0
	
	Default a_RgT015AE := {}
	Default a_ClasFis  := {}
	Default a_PisCofP  := {}
	Default a_DIfalFcp := {}

    nPosicao := AddT015AE(@a_RgT015AE,n_ItT015)

	// Valores comum para todos os impostos.
	a_RgT015AE[nPosicao][2][1][NAPREGISTR] := "T015AE"
	a_RgT015AE[nPosicao][2][1][NAPCODTRIB] := c_CodTrb

	// Preenche os campos conforme a tributação
	If c_CodTrb $ "01|02|16" .And. n_RegraTrb == 1		// 01=ISSQN | 02=ICMS | 16=ISSQN Retido 
		
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASEICM
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ALIQICM
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_VALICM
		a_RgT015AE[nPosicao][2][1][NAEVLRISEN] := SFT->FT_ISENICM
		a_RgT015AE[nPosicao][2][1][NAEVLROUTR] := SFT->FT_OUTRICM
		// Diferente dos outros impostos, a função SPDRetCCST() (SPEDXFUN.PRW) responsável por popular o array a_ClasFis 
		// não trata ISS, o campo FT_CSTISS já recebe o consteúdo em acordo com o TAF, não sendo necessário ajustes na função SPDRetCCST()
		If c_CodTrb $ "01|16" // 01=ISSQN | 16=ISSQN Retido 
			a_RgT015AE[nPosicao][2][1][NAECST] := SFT->FT_CSTISS
		Endif
		
		If c_CodTrb == "02"		// 02=ICMS
			a_RgT015AE[nPosicao][2][1][NAECST] := a_ClasFis[1]
			a_RgT015AE[nPosicao][2][1][NAEVLRSCRE] := FIcmSemCred()
		EndIf
		
	ElseIf c_CodTrb == "03" .And. n_RegraTrb == 1	// 03=ICMS Complementar
	
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_ALIQCMP,SD2->D2_ALIQCMP)
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_ICMSCOM
		
	ElseIf c_CodTrb == "04" .And. n_RegraTrb == 1	// 04=ICMS/ST
		
		a_RgT015AE[nPosicao][2][1][NAECST] := a_ClasFis[1]
		a_RgT015AE[nPosicao][2][1][NAEMVA] := SFT->FT_MARGEM
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASERET
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ALIQSOL
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_ICMSRET
		a_RgT015AE[nPosicao][2][1][NAEVLRISEN] := SFT->FT_ISENRET
		a_RgT015AE[nPosicao][2][1][NAEVLROUTR] := SFT->FT_OUTRRET
		
	ElseIf c_CodTrb == "05" .And. n_RegraTrb == 1	// 05=IPI
		
		a_RgT015AE[nPosicao][2][1][NAECST] := a_ClasFis[2]
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASEIPI
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ALIQIPI
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_VALIPI
		a_RgT015AE[nPosicao][2][1][NAEVLRISEN] := SFT->FT_ISENIPI
		a_RgT015AE[nPosicao][2][1][NAEVLROUTR] := SFT->FT_OUTRIPI
		
	ElseIf c_CodTrb == "06" .And. n_RegraTrb == 1	// 06=PIS
		
		If SFT->FT_VALPIS > 0 .Or. SFT->FT_BASEPIS > 0 .Or. SFT->FT_ALIQPIS > 0
			If SFT->FT_PAUTPIS > 0 .Or. SB1->B1_VLR_PIS > 0
				nValor := SFT->FT_VALPIS
			EndIf
		EndIf
		
		a_RgT015AE[nPosicao][2][1][NAECST] := a_ClasFis[3]
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASEPIS
		a_RgT015AE[nPosicao][2][1][NAEBSQTD] := a_PisCofP[NPAUTAPIS][2]
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := IIf(!Empty(a_PisCofP[NPAUTAPIS][1]),a_PisCofP[NPAUTAPIS][1],SFT->FT_ALIQPIS)
		a_RgT015AE[nPosicao][2][1][NAEALIQQTD] := a_PisCofP[NPAUTAPIS][1]
		a_RgT015AE[nPosicao][2][1][NAEVLR] := IIf(SFT->FT_CSTPIS $ "07|08|71|74" .And. Empty(a_PisCofP[NPAUTAPIS][1]),0,SFT->FT_VALPIS)
		a_RgT015AE[nPosicao][2][1][NAEVLRTRIB] := nValor
		a_RgT015AE[nPosicao][2][1][NAEVLRISEN] := IIf(SFT->FT_CSTPIS $ "07|71",SFT->FT_VALPIS,0)
		a_RgT015AE[nPosicao][2][1][NAEVLRNT] := IIf(SFT->FT_CSTPIS $ "08|74",SFT->FT_VRETPIS,0)
		
	ElseIf c_CodTrb == "07" .And. n_RegraTrb == 1	// 07=Cofins
		
		If SFT->FT_VALCOF > 0 .Or. SFT->FT_BASECOF > 0 .Or. SFT->FT_ALIQCOF > 0
			If SFT->FT_PAUTCOF > 0 .Or. SB1->B1_VLR_COF > 0
				nValor := SFT->FT_VALCOF
			EndIf
		EndIf
		
		a_RgT015AE[nPosicao][2][1][NAECST] := a_ClasFis[4]
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASECOF
		a_RgT015AE[nPosicao][2][1][NAEBSQTD] := a_PisCofP[NPAUTACOF][2]
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := IIf(!Empty(a_PisCofP[NPAUTACOF][1]),a_PisCofP[NPAUTACOF][1],SFT->FT_ALIQCOF)
		a_RgT015AE[nPosicao][2][1][NAEALIQQTD] := a_PisCofP[NPAUTACOF][1]
		a_RgT015AE[nPosicao][2][1][NAEVLR] := IIf(SFT->FT_CSTCOF $ "07|08|71|74" .And. Empty(a_PisCofP[NPAUTACOF][1]),0,SFT->FT_VALCOF)
		a_RgT015AE[nPosicao][2][1][NAEVLRTRIB] := nValor
		a_RgT015AE[nPosicao][2][1][NAEVLRISEN] := IIf(SFT->FT_CSTCOF $ "07|71",SFT->FT_VALCOF,0)
		a_RgT015AE[nPosicao][2][1][NAEVLRNT] := IIf(SFT->FT_CSTCOF $ "08|74",SFT->FT_VRETCOF,0)
		
	ElseIf c_CodTrb == "08" .And. n_RegraTrb == 1	// 08=PIS/ST
		
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASEPS3
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ALIQPS3
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_VALPS3
							
	ElseIf c_CodTrb == "09" .And. n_RegraTrb == 1	// 09=Cofins/ST
		
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASECF3
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ALIQCF3
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_VALCF3
		
	ElseIf c_CodTrb == "10" .And. n_RegraTrb == 1	// 10=Pis Retencao
		
		a_RgT015AE[nPosicao][2][1][NAECST] := a_ClasFis[3]
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BRETPIS
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ARETPIS
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_VRETPIS
		a_RgT015AE[nPosicao][2][1][NAEVLRISEN] := IIf(SFT->FT_CSTPIS $ "07|71",SFT->FT_VRETPIS,0)
		a_RgT015AE[nPosicao][2][1][NAEVLRNT] := IIf(SFT->FT_CSTPIS $ "08|74",SFT->FT_VRETPIS,0)
		
	ElseIf c_CodTrb == "11" .And. n_RegraTrb == 1	// 11=Cofins Retencao
		
		a_RgT015AE[nPosicao][2][1][NAECST] := a_ClasFis[4]
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BRETCOF
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ARETCOF
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_VRETCOF
		a_RgT015AE[nPosicao][2][1][NAEVLRISEN] := IIf(SFT->FT_CSTCOF $ "07|71",SFT->FT_VRETCOF,0)
		a_RgT015AE[nPosicao][2][1][NAEVLRNT] := IIf(SFT->FT_CSTCOF $ "08|74",SFT->FT_VRETCOF,0)
		
	ElseIf c_CodTrb $ "12|28" .And. n_RegraTrb == 1	// 12=IR EMISSÃO | 28=IR PAGAMENTO

		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASEIRR
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ALIQIRR
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_VALIRR
		
	ElseIf c_CodTrb == "13" .And. n_RegraTrb == 1	// 13=Previdencia
		
		if SFT->(FieldPos("FT_VLCP15")) > 0 .And. SFT->(FieldPos("FT_VLCP20")) > 0 .And. SFT->(FieldPos("FT_VLCP25")) > 0
			nTotVlCp := SFT->FT_VLCP15 + SFT->FT_VLCP20 + SFT->FT_VLCP25
		endif
		if SFT->(FieldPos("FT_BSCP15")) > 0
			nVBscp15 := SFT->FT_BSCP15
		endif
		if SFT->(FieldPos("FT_BSCP20")) > 0
			nVBscp20 := SFT->FT_BSCP20
		endif
		if SFT->(FieldPos("FT_BSCP25")) > 0
			nVBscp25 := SFT->FT_BSCP25
		endif

		a_RgT015AE[nPosicao][2][1][NAEBS]		:= SFT->FT_BASEINS
		a_RgT015AE[nPosicao][2][1][NAEALIQ]		:= SFT->FT_ALIQINS
		a_RgT015AE[nPosicao][2][1][NAEVLCONTR]	:= IIf(SFT->FT_TIPOMOV=="S",SD2->D2_ABSCINS,SD1->D1_AVLINSS)
		a_RgT015AE[nPosicao][2][1][NAEVLR]		:= (SFT->FT_VALINS + a_RgT015AE[nPosicao][2][1][NAEVLCONTR]) - ( nTotVlCp )

		If ( nVBscp15 + nVBscp20 + nVBscp25 ) > 0
			a_RgT015AE[nPosicao][2][1][NAEVLRCE15]	:= nVBscp15
			a_RgT015AE[nPosicao][2][1][NAEVLRCE20]	:= nVBscp20
			a_RgT015AE[nPosicao][2][1][NAEVLRCE25]	:= nVBscp25

		ElseIf !Empty(oFisaExtSx:_MV_TPAPSB1) .AND. (SB1)->(FieldPos(oFisaExtSx:_MV_TPAPSB1)) > 0
			if (SB1)->(&( oFisaExtSx:_MV_TPAPSB1 ) ) > 0
				If SB1->(&(oFisaExtSx:_MV_TPAPSB1)) == '1'
					a_RgT015AE[nPosicao][2][1][NAEVLRCE15]	:= SFT->FT_BASEINS 
				ElseIf SB1->(&(oFisaExtSx:_MV_TPAPSB1)) == '2'
					a_RgT015AE[nPosicao][2][1][NAEVLRCE20]	:= SFT->FT_BASEINS 
				ElseIf SB1->(&(oFisaExtSx:_MV_TPAPSB1)) == '3'
					a_RgT015AE[nPosicao][2][1][NAEVLRCE25]	:= SFT->FT_BASEINS 
				EndIf
			endif
		EndIf
		a_RgT015AE[nPosicao][2][1][NAEVLRADIC]	:= nTotVlCp

	ElseIf c_CodTrb == "17" .And. n_RegraTrb == 1	// 17=ICMS Antecipado
		
		a_RgT015AE[nPosicao][2][1][NAECST] := SF4->F4_SITTRIB
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASEICM
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ALIQICM
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_VALANTI
		a_RgT015AE[nPosicao][2][1][NAEVLRISEN] := SFT->FT_ISENICM
		a_RgT015AE[nPosicao][2][1][NAEVLROUTR] := SFT->FT_OUTRICM	

	ElseIf c_CodTrb == "18" .And. n_RegraTrb == 1	// 18=CSLL	
		
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BRETCSL
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ARETCSL
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_VRETCSL


	ElseIf c_CodTrb == "20" .And. n_RegraTrb == 1	// 20=DIfal Origem
		
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASEDES
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := a_DIfalFcp[NALQDIfALC]
		a_RgT015AE[nPosicao][2][1][NAEVLR] := a_DIfalFcp[NDIfALORIG]
		
	ElseIf c_CodTrb == "21" .And. n_RegraTrb == 1	// 21=DIfal Destino
		
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASEDES
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := a_DIfalFcp[NALQDIfALC]
		a_RgT015AE[nPosicao][2][1][NAEVLR] := a_DIfalFcp[NDIfALDEST]
		
	ElseIf c_CodTrb == "22" .And. n_RegraTrb == 1	// 22=FCP Destino
		
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASEDES
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := a_DIfalFcp[NALQFECPCM]
		a_RgT015AE[nPosicao][2][1][NAEVLR] := a_DIfalFcp[NDIfALFECP]
		
	ElseIf c_CodTrb == "23" .And. n_RegraTrb == 1	// 23=CPRB
		
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASECPB
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ALIQCPB
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_VALCPB
		
	ElseIf c_CodTrb == "24" .And. n_RegraTrb == 1	// 24=GILRAT

		If lSFTBASFUN .And. lSFTALQFUN .And. lSFTVALFUN .And. SFT->FT_VALFUN > 0
			nBasGILRAT := SFT->FT_BASEFUN
			nAlqGILRAT := SFT->FT_ALIQFUN
			nValGILRAT := SFT->FT_VALFUN
		Else
			nBasGILRAT := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_BASEFUN,SD2->D2_BASEFUN)
			nAlqGILRAT := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_ALIQFUN,SD2->D2_ALIQFUN)
			nValGILRAT := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_VALFUN,SD2->D2_VALFUN)
		EndIf
		
		a_RgT015AE[nPosicao][2][1][NAEBS] 	:= nBasGILRAT
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := nAlqGILRAT
		a_RgT015AE[nPosicao][2][1][NAEVLR] 	:= nValGILRAT
		
	ElseIf c_CodTrb == "25" .And. n_RegraTrb == 1	// 25=SENAR
		
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BSSENAR
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ALSENAR
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_VLSENAR
		
	ElseIf c_CodTrb == "26" .And. n_RegraTrb == 1	// 26=ICMS/ST - SUBSTITUIDO
		
		a_RgT015AE[nPosicao][2][1][NAECST] := a_ClasFis[1]
		a_RgT015AE[nPosicao][2][1][NAEMVA] := SFT->FT_MARGEM
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_BASERET
		a_RgT015AE[nPosicao][2][1][NAEALIQ] := SFT->FT_ALIQSOL
		a_RgT015AE[nPosicao][2][1][NAEVLR] := SFT->FT_ICMSRET
		a_RgT015AE[nPosicao][2][1][NAEVLRISEN] := SFT->FT_ISENRET
		a_RgT015AE[nPosicao][2][1][NAEVLROUTR] := SFT->FT_OUTRRET

	EndIf

Return Nil

/*/{Protheus.doc} AddT015AE
    (Função para adicionar uma linha no registro T015AE)

    @type Static Function
    @author Vitor Ribeiro
    @since 09/03/2018
    
    @param a_RgT015AE, array, será utilizado para montar as informações do registro T015AE
    @param n_ItT015, numerico, item do registro T015

    @return nPosicao, numerico, posição do array adicionado.
    /*/
Static Function AddT015AE(a_RgT015AE,n_ItT015)

    Local nPosicao := 0

    Default a_RgT015AE := {}
    
    Default n_ItT015 := 0

	Aadd(a_RgT015AE,{n_ItT015,{{}}})
	nPosicao := Len(a_RgT015AE)

	/*
		Inicializa a linha de impostos
	*/
	Aadd(a_RgT015AE[nPosicao][2][1],"")	// 01	->	REGISTRO		->	NAEREGISTR
	Aadd(a_RgT015AE[nPosicao][2][1],"")	// 02	->	COD_TRIB		->	NAECODTRIB
	Aadd(a_RgT015AE[nPosicao][2][1],"")	// 03	->	CST				->	NAECST
	Aadd(a_RgT015AE[nPosicao][2][1],"")	// 04	->	MODBC			->	NAEMODBC
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 05	->	MVA				->	NAEMVA
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 06	->	PERC_RED_BC		->	NAEPRREDBS
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 07	->	BASE			->	NAEBS
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 08	->	BASE_QUANT		->	NAEBSQTD
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 09	->	BASE_NT			->	NAEBSNT
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 10	->	ALIQUOTA		->	NAEALIQ
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 11	->	ALIQUOTA_QUANT	->	NAEALIQQTD
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 12	->	VALOR			->	NAEVLR
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 13	->	VLR_TRIBUTAVEL	->	NAEVLRTRIB
	Aadd(a_RgT015AE[nPosicao][2][1],"")	// 14	->	COD_ENQ			->	NAECODENQ
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 15	->	VLR_ISENTO		->	NAEVLRISEN
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 16	->	VLR_OUTROS		->	NAEVLROUTR
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 17	->	VALOR_NT		->	NAEVLRNT
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 18	->	VL_BC_ICMS_UF	->	NAEBSICMUF
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 19	->	VL_ICMS_UF		->	NAEVLICMUF
	Aadd(a_RgT015AE[nPosicao][2][1],"")	// 20	->	COD_ANT			->	NAECODANT
	Aadd(a_RgT015AE[nPosicao][2][1],"")	// 21	->	MT_DES_ICMS		->	NAEMTDSICM
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 22	->	VL_SCRED 		->	NAEVLRSCRE
	Aadd(a_RgT015AE[nPosicao][2][1],"")	// 23	->	MOT_INCIDENCIA	->	NAEMTINCID
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 24	->	VLSCONTR		->	NAEVLCONTR
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 25	->	VLRADIC			->	NAEVLRADIC
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 26	->	VLRNPAG			->	NAEVLRNPAG
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 27	->	VLRCE15			->	NAEVLRCE15
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 28	->	VLRCE20			->	NAEVLRCE20
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 29	->	VLRCE25			->	NAEVLRCE25
	Aadd(a_RgT015AE[nPosicao][2][1],0)	// 30	->	VLRADICNPAG		->	NAEVRDICPG
	
Return nPosicao

/* 
	Posição do array a_RgT078AF conforme o layout do TAF do registro T078AF.
*/
#Define NAFREGISTR	01	// REGISTRO
#Define NAFCODTRIB	02	// COD_TRIB
#Define NAFCST		03	// CST
#Define NAFMODBC	04	// MODBC
#Define NAFMVA		05	// MVA
#Define NAFPRREDBS	06	// PERC_RED_BC
#Define NAFBS		07	// BASE
#Define NAFBSQTD	08	// BASE_QUANT
#Define NAFBSNT		09	// BASE_NT
#Define NAFALIQ		10	// ALIQUOTA
#Define NAFALIQQTD	11	// ALIQUOTA_QUANT
#Define NAFVLR		12	// VALOR
#Define NAFVLRTRIB	13	// VLR_TRIBUTAVEL
#Define NAFCODENQ	14	// COD_ENQ
#Define NAFVLRISEN	15	// VLR_ISENTO
#Define NAFVLROUTR	16	// VLR_OUTROS
#Define NAFVLRNT	17	// VALOR_NT

/* 
	Posição do array a_RgT080AC conforme o layout do TAF do registro T080AC.
*/
#Define NACREGISTR	01	// REGISTRO
#Define NACCODTRIB	02	// COD_TRIB
#Define NACCST		03	// CST
#Define NACMODBC	04	// MODBC
#Define NACMVA		05	// MVA
#Define NACPRREDBS	06	// PERC_RED_BC
#Define NACBS		07	// BASE
#Define NACBSQTD	08	// BASE_QUANT
#Define NACBSNT		09	// BASE_NT
#Define NACALIQ		10	// ALIQUOTA
#Define NACALIQQTD	11	// ALIQUOTA_QUANT
#Define NACVLR		12	// VALOR
#Define NACVLRTRIB	13	// VLR_TRIBUTAVEL
#Define NACCODENQ	14	// COD_ENQ
#Define NACVLRISEN	15	// VLR_ISENTO
#Define NACVLROUTR	16	// VLR_OUTROS
#Define NACVLRNT	17	// VALOR_NT

/*/{Protheus.doc} fRegT080AC
Função para montar o registro T080AC.

@author Vitor Ribeiro
@since  10/01/2018

@param c_CodTrb, caracter, codigo do tributo.
@param n_RegraTrb, numerico, posição da regra do tributo.
@param a_RgT080AC, array, array aonde será montado o registro T078AF
@param n_ItT080, numerico, item do registro T080
@param n_ItT080AA, numerico, item do registro T080AA
@param n_ItT080AB, numerico, item do registro T080AB
@param a_ClasFis, array, contém a classIficação fiscal.
@param a_PisCofP, array, contém a pauta e a quantidade do pis e cofins.
@param a_DIfalFcp, array, contém as informações do DIfAL e do FCP.

@return nulo, não tem retorno. 
/*/
Static Function fRegT080AC(c_CodTrb,n_RegraTrb,a_RgT080AC,n_ItT080,n_ItT080AA,n_ItT080AB,a_ClasFis,a_PisCofP,a_DIfalFcp)

	Local nPosicao 		:= 0
	Local nValor 		:= 0
	Local nBasGILRAT	:= 0
	Local nAlqGILRAT	:= 0
	Local nValGILRAT	:= 0

	Local lSFTVALFUN := IIf(SFT->(FieldPos("FT_VALFUN")) > 0,.T.,.F.)
	Local lSFTBASFUN := IIf(SFT->(FieldPos("FT_BASEFUN")) > 0,.T.,.F.)
	Local lSFTALQFUN := IIf(SFT->(FieldPos("FT_ALIQFUN")) > 0,.T.,.F.)
	
	Default c_CodTrb := ""
	
	Default n_RegraTrb := 0
	Default n_ItT080 := 0
	Default n_ItT080AA := 0
	Default n_ItT080AB := 0
	
	Default a_RgT080AC := {}
	Default a_ClasFis := {}
	Default a_PisCofP := {}
	Default a_DIfalFcp := {}
	
	Aadd(a_RgT080AC,{n_ItT080,n_ItT080AA,n_ItT080AB,{{}}})
	nPosicao := Len(a_RgT080AC)
	
	/*
		Inicializa a linha de impostos
	*/
	Aadd(a_RgT080AC[nPosicao][4][1],"")	// 01	->	REGISTRO		->	NACREGISTR
	Aadd(a_RgT080AC[nPosicao][4][1],"")	// 02	->	COD_TRIB		->	NACCODTRIB
	Aadd(a_RgT080AC[nPosicao][4][1],"")	// 03	->	CST				->	NACCST
	Aadd(a_RgT080AC[nPosicao][4][1],"")	// 04	->	MODBC			->	NACMODBC
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 05	->	MVA				->	NACMVA
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 06	->	PERC_RED_BC		->	NACPRREDBS
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 07	->	BASE			->	NACBS
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 08	->	BASE_QUANT		->	NACBSQTD
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 09	->	BASE_NT			->	NACBSNT
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 10	->	ALIQUOTA		->	NACALIQ
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 11	->	ALIQUOTA_QUANT	->	NACALIQQTD
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 12	->	VALOR			->	NACVLR
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 13	->	VLR_TRIBUTAVEL	->	NACVLRTRIB
	Aadd(a_RgT080AC[nPosicao][4][1],"")	// 14	->	COD_ENQ			->	NACCODENQ
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 15	->	VLR_ISENTO		->	NACVLRISEN
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 16	->	VLR_OUTROS		->	NACVLROUTR
	Aadd(a_RgT080AC[nPosicao][4][1],0)	// 17	->	VALOR_NT		->	NACVLRNT
	
	// Valores comum para todos os impostos.
	a_RgT080AC[nPosicao][4][1][NACREGISTR] := "T080AC"
	a_RgT080AC[nPosicao][4][1][NACCODTRIB] := c_CodTrb
	
	// Preenche os campos conforme a tributação
	If c_CodTrb $ "01|02|16" .And. n_RegraTrb == 1		// 01=ISSQN | 02=ICMS | 16=ISSQN Retido 
		
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASEICM
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ALIQICM
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VALICM
		a_RgT080AC[nPosicao][4][1][NACVLRISEN] := SFT->FT_ISENICM
		a_RgT080AC[nPosicao][4][1][NACVLROUTR] := SFT->FT_OUTRICM
		
		// Diferente dos outros impostos, a função SPDRetCCST() (SPEDXFUN.PRW) responsável por popular o array a_ClasFis 
		// não trata ISS, o campo FT_CSTISS já recebe o consteúdo em acordo com o TAF, não sendo necessário ajustes na função SPDRetCCST()
		If c_CodTrb $ "01|16" // 01=ISSQN | 16=ISSQN Retido 
			a_RgT080AC[nPosicao][4][1][NACCST]  := SFT->FT_CSTISS
		Endif

		If c_CodTrb == "02" .And. n_RegraTrb == 1	// 02=ICMS
			a_RgT080AC[nPosicao][4][1][NACCST] := a_ClasFis[1]
		EndIf
		
	ElseIf c_CodTrb == "03" .And. n_RegraTrb == 1	// 03=ICMS Complementar
	
		a_RgT080AC[nPosicao][4][1][NACALIQ] := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_ALIQCMP,SD2->D2_ALIQCMP)
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_ICMSCOM
		
	ElseIf c_CodTrb == "04" .And. n_RegraTrb == 1	// 04=ICMS/ST
		
		a_RgT080AC[nPosicao][4][1][NACCST] := a_ClasFis[1]
		a_RgT080AC[nPosicao][4][1][NACMVA] := SFT->FT_MARGEM
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASERET
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ALIQSOL
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_ICMSRET
		a_RgT080AC[nPosicao][4][1][NACVLRISEN] := SFT->FT_ISENRET
		a_RgT080AC[nPosicao][4][1][NACVLROUTR] := SFT->FT_OUTRRET
		
	ElseIf c_CodTrb == "05" .And. n_RegraTrb == 1	// 05=IPI
		
		a_RgT080AC[nPosicao][4][1][NACCST] := a_ClasFis[2]
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASEIPI
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ALIQIPI
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VALIPI
		a_RgT080AC[nPosicao][4][1][NACVLRISEN] := SFT->FT_ISENIPI
		a_RgT080AC[nPosicao][4][1][NACVLROUTR] := SFT->FT_OUTRIPI
		
	ElseIf c_CodTrb == "06" .And. n_RegraTrb == 1	// 06=PIS
		
		If SFT->FT_VALPIS > 0 .Or. SFT->FT_BASEPIS > 0 .Or. SFT->FT_ALIQPIS > 0
			If SFT->FT_PAUTPIS > 0 .Or. SB1->B1_VLR_PIS > 0
				nValor := SFT->FT_VALPIS
			EndIf
		EndIf
		
		a_RgT080AC[nPosicao][4][1][NACCST] := a_ClasFis[3]
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASEPIS
		a_RgT080AC[nPosicao][4][1][NACBSQTD] := a_PisCofP[NPAUTAPIS][2]
		a_RgT080AC[nPosicao][4][1][NACALIQ] := IIf(!Empty(a_PisCofP[NPAUTAPIS][1]),a_PisCofP[NPAUTAPIS][1],SFT->FT_ALIQPIS)
		a_RgT080AC[nPosicao][4][1][NACALIQQTD] := a_PisCofP[NPAUTAPIS][1]
		a_RgT080AC[nPosicao][4][1][NACVLR] := IIf(SFT->FT_CSTPIS $ "07|08|71|74" .And. Empty(a_PisCofP[NPAUTAPIS][1]),0,SFT->FT_VALPIS)
		a_RgT080AC[nPosicao][4][1][NACVLRTRIB] := nValor
		a_RgT080AC[nPosicao][4][1][NACVLRISEN] := IIf(SFT->FT_CSTPIS $ "07|71",SFT->FT_VALPIS,0)
		a_RgT080AC[nPosicao][4][1][NACVLRNT] := IIf(SFT->FT_CSTPIS $ "08|74",SFT->FT_VRETPIS,0)
		
	ElseIf c_CodTrb == "07" .And. n_RegraTrb == 1	// 07=Cofins
		
		If SFT->FT_VALCOF > 0 .Or. SFT->FT_BASECOF > 0 .Or. SFT->FT_ALIQCOF > 0
			If SFT->FT_PAUTCOF > 0 .Or. SB1->B1_VLR_COF > 0
				nValor := SFT->FT_VALCOF
			EndIf
		EndIf
		
		a_RgT080AC[nPosicao][4][1][NACCST] := a_ClasFis[4]
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASECOF
		a_RgT080AC[nPosicao][4][1][NACBSQTD] := a_PisCofP[NPAUTACOF][2]
		a_RgT080AC[nPosicao][4][1][NACALIQ] := IIf(!Empty(a_PisCofP[NPAUTACOF][1]),a_PisCofP[NPAUTACOF][1],SFT->FT_ALIQCOF)
		a_RgT080AC[nPosicao][4][1][NACALIQQTD] := a_PisCofP[NPAUTACOF][1]
		a_RgT080AC[nPosicao][4][1][NACVLR] := IIf(SFT->FT_CSTCOF $ "07|08|71|74" .And. Empty(a_PisCofP[NPAUTACOF][1]),0,SFT->FT_VALCOF)
		a_RgT080AC[nPosicao][4][1][NACVLRTRIB] := nValor
		a_RgT080AC[nPosicao][4][1][NACVLRISEN] := IIf(SFT->FT_CSTCOF $ "07|71",SFT->FT_VALCOF,0)
		a_RgT080AC[nPosicao][4][1][NACVLRNT] := IIf(SFT->FT_CSTCOF $ "08|74",SFT->FT_VRETCOF,0)
		
	ElseIf c_CodTrb == "08" .And. n_RegraTrb == 1	// 08=PIS/ST
		
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASEPS3
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ALIQPS3
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VALPS3
							
	ElseIf c_CodTrb == "09" .And. n_RegraTrb == 1	// 09=Cofins/ST
		
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASECF3
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ALIQCF3
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VALCF3
		
	ElseIf c_CodTrb == "10" .And. n_RegraTrb == 1	// 10=Pis Retencao
		
		a_RgT080AC[nPosicao][4][1][NACCST] := a_ClasFis[3]
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BRETPIS
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ARETPIS
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VRETPIS
		a_RgT080AC[nPosicao][4][1][NACVLRISEN] := IIf(SFT->FT_CSTPIS $ "07|71",SFT->FT_VRETPIS,0)
		a_RgT080AC[nPosicao][4][1][NACVLRNT] := IIf(SFT->FT_CSTPIS $ "08|74",SFT->FT_VRETPIS,0)
		
	ElseIf c_CodTrb == "11" .And. n_RegraTrb == 1	// 11=Cofins Retencao
		
		a_RgT080AC[nPosicao][4][1][NACCST] := a_ClasFis[4]
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BRETCOF
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ARETCOF
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VRETCOF
		a_RgT080AC[nPosicao][4][1][NACVLRISEN] := IIf(SFT->FT_CSTCOF $ "07|71",SFT->FT_VRETCOF,0)
		a_RgT080AC[nPosicao][4][1][NACVLRNT] := IIf(SFT->FT_CSTCOF $ "08|74",SFT->FT_VRETCOF,0)
		
	ElseIf c_CodTrb == "12" .And. n_RegraTrb == 1	// 12=IR
		
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASEIRR
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ALIQIRR
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VALIRR
		
	ElseIf c_CodTrb == "13" .And. n_RegraTrb == 1	// 13=Previdencia
		
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASEINS
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ALIQINS
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VALINS
		
	ElseIf c_CodTrb == "17" .And. n_RegraTrb == 1	// 17=ICMS Antecipado
		
		a_RgT080AC[nPosicao][4][1][NACCST] := SF4->F4_SITTRIB
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASEICM
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ALIQICM
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VALANTI
		a_RgT080AC[nPosicao][4][1][NACVLRISEN] := SFT->FT_ISENICM
		a_RgT080AC[nPosicao][4][1][NACVLROUTR] := SFT->FT_OUTRICM
		
	ElseIf c_CodTrb == "18" .And. n_RegraTrb == 1	// 18=CSLL
	
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BRETCSL
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ARETCSL
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VRETCSL

	ElseIf c_CodTrb == "20" .And. n_RegraTrb == 1	// 20=DIfal Origem
		
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASEDES
		a_RgT080AC[nPosicao][4][1][NACALIQ] := a_DIfalFcp[NALQDIfALC]
		a_RgT080AC[nPosicao][4][1][NACVLR] := a_DIfalFcp[NDIfALORIG]
		
	ElseIf c_CodTrb == "21" .And. n_RegraTrb == 1	// 21=DIfal Destino
		
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASEDES
		a_RgT080AC[nPosicao][4][1][NACALIQ] := a_DIfalFcp[NALQDIfALC]
		a_RgT080AC[nPosicao][4][1][NACVLR] := a_DIfalFcp[NDIfALDEST]
		
	ElseIf c_CodTrb == "22" .And. n_RegraTrb == 1	// 22=FCP Destino
		
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASEDES
		a_RgT080AC[nPosicao][4][1][NACALIQ] := a_DIfalFcp[NALQFECPCM]
		a_RgT080AC[nPosicao][4][1][NACVLR] := a_DIfalFcp[NDIfALFECP]
		
	ElseIf c_CodTrb == "23" .And. n_RegraTrb == 1	// 23=CPRB
		
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASECPB
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ALIQCPB
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VALCPB
		
	ElseIf c_CodTrb == "24" .And. n_RegraTrb == 1	// 24=GILRAT 

		If lSFTBASFUN .And. lSFTALQFUN .And. lSFTVALFUN .And. SFT->FT_VALFUN > 0
			nBasGILRAT := SFT->FT_BASEFUN
			nAlqGILRAT := SFT->FT_ALIQFUN
			nValGILRAT := SFT->FT_VALFUN
		Else
			nBasGILRAT := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_BASEFUN,SD2->D2_BASEFUN)
			nAlqGILRAT := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_ALIQFUN,SD2->D2_ALIQFUN)
			nValGILRAT := IIf(SFT->FT_TIPOMOV == "E",SD1->D1_VALFUN,SD2->D2_VALFUN)
		EndIf
		
		a_RgT080AC[nPosicao][4][1][NACBS] := nBasGILRAT
		a_RgT080AC[nPosicao][4][1][NACALIQ] := nAlqGILRAT
		a_RgT080AC[nPosicao][4][1][NACVLR] := nValGILRAT
		
	ElseIf c_CodTrb == "25" .And. n_RegraTrb == 1	// 25=SENAR
		
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BSSENAR
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ALSENAR
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_VLSENAR
		
	ElseIf c_CodTrb == "26" .And. n_RegraTrb == 1	// 26=ICMS/ST - SUBSTITUIDO
		
		a_RgT080AC[nPosicao][4][1][NACCST] := a_ClasFis[1]
		a_RgT080AC[nPosicao][4][1][NACMVA] := SFT->FT_MARGEM
		a_RgT080AC[nPosicao][4][1][NACBS] := SFT->FT_BASERET
		a_RgT080AC[nPosicao][4][1][NACALIQ] := SFT->FT_ALIQSOL
		a_RgT080AC[nPosicao][4][1][NACVLR] := SFT->FT_ICMSRET
		a_RgT080AC[nPosicao][4][1][NACVLRISEN] := SFT->FT_ISENRET
		a_RgT080AC[nPosicao][4][1][NACVLROUTR] := SFT->FT_OUTRRET
		
	EndIf

Return Nil

/*/{Protheus.doc} FIcmSemCred
Função responsável por buscar o valor de ICMS sem aproveitamento de crédito

@author Rodrigo Aguilar
@since  29/11/2016

@return Nulo, não tem retorno.

@obs Função refeita. Vitor Ribeiro - 19/01/2018
/*/
Static Function FIcmSemCred()

	Local cMVDAPIC04 := "" 
	
	Local nValSCred := 0 
	
	cMVDAPIC04 := oFisaExtSx:_MV_DAPIC04
	
	// Somente deve buscar o valor sem crédito para documentos de entrada
	If SFT->FT_TIPOMOV == "E"
	
		If AllTrim(SubStr(SD1->D1_CLASFIS,2,2)) == "90"
		
			If "S" $ SF4->F4_ICM .And. "N" $ SF4->F4_CREDICM
			
		  		If AllTrim(SD1->D1_CF) $ cMVDAPIC04 .Or. AllTrim(SD1->D1_CF) $ "1253/1901/1551/1556/2253/2551/2556/1406/2406/1301/1302/1303/1304/1305/1306/1949/2301/2302/2303/2304/2305/2306/2949"
		      		
		      		// Sem aproveitamento do credito coluna outras/isentas
					If  SF4->F4_LFICM == "O" .Or. SF4->F4_LFICM == "I"
						
						// Busco o valor de ICMS sem crédito
						nValSCred := SFT->FT_OBSICM
					
					Else	// Sem aproveitamento do credito
						
						//Busco o valor de ICMS sem crédito
						nValSCred := SFT->FT_VALICM
						
					EndIf
					
				ElseIf "S" $ SF4->F4_CONSUMO .And. AllTrim(SD1->D1_CF) $ "1251/1252/1253/1254/1255/1256/1257/1407/1556/1557/1653/2407/2556/2557/2653/3556/3653"  	            	 				
					
					// Busco o valor de ICMS sem crédito
					nValSCred := SFT->FT_OBSICM
					
				EndIf
			Else
		  		If AllTrim(SD1->D1_CF) $ cMVDAPIC04
		  	   		
		  	   		If SFT->FT_VALANTI <> 0
		  	   			
						// Busco o valor de ICMS sem crédito
						nValSCred := SFT->FT_OUTRICM
					
					Else
						
						// Busco o valor de ICMS sem crédito
						nValSCred := SFT->(FT_OUTRICM+FT_ICMSRET)
											
		  	   		EndIf
		  	   		
		  	   		If AllTrim(SD1->D1_CF) $ "1101/1102/1111/1113/1116/1117/1118/1120/1121/1122/1124/1125/1126/1128/1401/1403/1501/1651/1652/1201/1202/1203/1204/1205/1206/1207/1208/1209/1410/1411/1503/1504/1660/1661/1662" .Or.;
		  	   			(AllTrim(SD1->D1_CF) $ "1653" .And. (SF4->F4_CREDICM <> "N" .Or. SF4->F4_CONSUMO <> "S")) .Or.;
		  	   			(AllTrim(SD1->D1_CF) $ "1414/1415/1451/1452/1901/1902/1903/1904/1905/1906/1907/1908/1909/1910/1911/1912/1913/1914/1915/1916/1917/1918/1919/1920/1921/1922/1923/1924/1925/1926/1933/1663/1664/1949" .And.;
		  	   			SF4->F4_LFICM <> "N" ) .And. SFT->FT_CREDST $ "1/4"
		  	   			
		  	   			nValSCred += SFT->FT_ICMSRET
		  	   		EndIf
		  	   			  	   
		       EndIf    
			EndIf						
		EndIf
	EndIf

Return nValSCred

/*/{Protheus.doc} fTrbNoCalc
    (long_description)

    @type Static Function
    @author Vitor Ribeiro
    @since 19/03/2018

    @return aCodTribN, array, contém as informações de codigo de tributo não calculado
    /*/
Static Function fTrbNoCalc()

    Local aCodTribN := {}
    Local nPosicao  := 0

    // Enquanto for para o mesmo item.
    While CDG->(!Eof()) .And. xFilial("CDG")+SFT->(FT_TIPOMOV+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ITEM) == CDG->(CDG_FILIAL+CDG_TPMOV+CDG_DOC+CDG_SERIE+CDG_CLIFOR+CDG_LOJA+CDG_ITEM)
        // Se encontrou os processo referenciados
        If SPEDSeek("CCF",1,xFilial("CCF")+CDG->(CDG_PROCES+CDG_TPPROC))

            While CCF->(!Eof()) .And. xFilial("CCF")+CDG->(CDG_PROCES+CDG_TPPROC) == CCF->(CCF_FILIAL+CCF_NUMERO+CCF_TIPO)

            	If CCF->CCF_IDITEM == CDG->CDG_ITPROC
	                If CCF->CCF_TRIB == "6"                                 // 02=ICMS

	                    // Verifica se já existe o registro
	                    If Ascan(aCodTribN,{|x| x[1] == "02" }) < 1
	                        Aadd(aCodTribN,{"02",CDG->CDG_VALOR,0})
	                    EndIf
	                    
	                ElseIf CCF->CCF_TRIB == "7"                             // 06=PIS

	                    // Verifica se já existe o registro
	                    If Ascan(aCodTribN,{|x| x[1] == "06" }) < 1
	                        Aadd(aCodTribN,{"06",CDG->CDG_VALOR,0})
	                    EndIf

	                ElseIf CCF->CCF_TRIB == "8"                             // 07=Cofins

	                    // Verifica se já existe o registro
	                    If Ascan(aCodTribN,{|x| x[1] == "07" }) < 1
	                        Aadd(aCodTribN,{"07",CDG->CDG_VALOR,0})
	                    EndIf

	                ElseIf CCF->CCF_TRIB == "1" .Or. CCF->CCF_TRIB == "2"   // 13=Previdencia
	                
	                    nPosicao := Ascan(aCodTribN,{|x| x[1] == "13" })
	                    
	                    // Se existe
	                    If Empty(nPosicao) 
	                        Aadd(aCodTribN,{"13",IIf(CCF->CCF_TRIB=="1",CDG->CDG_VALOR,0),IIf(CCF->CCF_TRIB=="1",0,CDG->CDG_VALOR)})
	                    Else
	                    	aCodTribN[nPosicao][2] += IIf(CCF->CCF_TRIB=="1",CDG->CDG_VALOR,0)
	                    	aCodTribN[nPosicao][3] += IIf(CCF->CCF_TRIB=="1",0,CDG->CDG_VALOR)
	                    EndIf

	                ElseIf CCF->CCF_TRIB == "5"                             // 23=CPRB

	                    // Verifica se já existe o registro
	                    If Ascan(aCodTribN,{|x| x[1] == "23" }) < 1
	                        Aadd(aCodTribN,{"23",CDG->CDG_VALOR,0})
	                    EndIf

	                ElseIf CCF->CCF_TRIB == "3"                             // 24=GILRAT

	                    // Verifica se já existe o registro
	                    If Ascan(aCodTribN,{|x| x[1] == "24" }) < 1
	                        Aadd(aCodTribN,{"24",CDG->CDG_VALOR,0})
	                    EndIf

	                ElseIf CCF->CCF_TRIB == "4"                             // 25=SENAR

	                    // Verifica se já existe o registro
	                    If Ascan(aCodTribN,{|x| x[1] == "25" }) < 1
	                        Aadd(aCodTribN,{"25",CDG->CDG_VALOR,0})
	                    EndIf

	                EndIf
	            EndIf

                CCF->(DbSKip())
            EndDo
        EndIf

        CDG->(DbSkip())
    EndDo

Return aCodTribN

/*/{Protheus.doc} fT015AENCl
    (Função para montar o registro T015AE dos tributos não calculados na nota.)

    @type Static Function
    @author Vitor Ribeiro
    @since 09/03/2018
     
    @param a_CodTribN, array, contem o tributo não calculado.
    @param a_RgT015AE, array, será utilizado para montar as informações do registro T015AE
    @param n_ItT015, numerico, item do registro T015

    @return Nil, nulo, não tem retorno.
    /*/
Static Function fT015AENCl(a_CodTribN,a_RgT015AE,n_ItT015)

    Local nPosicao := 0

    Default a_CodTribN := {}
    Default a_RgT015AE := {}
    
    Default n_ItT015 := 0

	// Procura o tributo no array
	nPosicao := Ascan(a_RgT015AE,{|x| x[1] == n_ItT015 .And. x[2][1][NAPCODTRIB] == a_CodTribN[1] })

	// Se não encontrar
	If Empty(nPosicao)
		// Adiciona mais uma posição no array.
		nPosicao := AddT015AE(@a_RgT015AE,n_ItT015)

		a_RgT015AE[nPosicao][2][1][NAEREGISTR] := "T015AE"
		a_RgT015AE[nPosicao][2][1][NAECODTRIB] := a_CodTribN[1]
		a_RgT015AE[nPosicao][2][1][NAEBS] := SFT->FT_VALCONT
		a_RgT015AE[nPosicao][2][1][NAEVLR] := a_CodTribN[2]
		
		If SFT->(FT_SECP15+FT_SECP20+FT_SECP25) > 0
			a_RgT015AE[nPosicao][2][1][NAEVLRCE15]	:= SFT->FT_SECP15
			a_RgT015AE[nPosicao][2][1][NAEVLRCE20]	:= SFT->FT_SECP20
			a_RgT015AE[nPosicao][2][1][NAEVLRCE25]	:= SFT->FT_SECP25
		ElseIf !Empty(oFisaExtSx:_MV_TPAPSB1)
			If SB1->(&(oFisaExtSx:_MV_TPAPSB1)) == '1'  	
				a_RgT015AE[nPosicao][2][1][NAEVLRCE15]	:= SFT->FT_TOTAL
			ElseIf SB1->(&(oFisaExtSx:_MV_TPAPSB1)) == '2' 			
				a_RgT015AE[nPosicao][2][1][NAEVLRCE20]	:= SFT->FT_TOTAL
			ElseIf SB1->(&(oFisaExtSx:_MV_TPAPSB1)) == '3'
				a_RgT015AE[nPosicao][2][1][NAEVLRCE25]	:= SFT->FT_TOTAL
			EndIf					
		EndIf
		a_RgT015AE[nPosicao][2][1][NAEVLRADIC] := a_CodTribN[3]
	EndIf

	a_RgT015AE[nPosicao][2][1][NAEVLRNPAG] := a_CodTribN[2]
	a_RgT015AE[nPosicao][2][1][NAEVRDICPG] := a_CodTribN[3]


Return


/*/{Protheus.doc} RegT003Pos
    (Função para montar o registro T003 com o registro da tabela posicionada .)

    @type Static Function
    @author Caio Martins
    @since 11/12/2018
     
    @param cAlias, String, contem a Alias do arquivo (SA1/SA2)
	@param nHdlT003, numérico, arquivo para gravar txt
    
    @return Nil, nulo, não tem retorno.
    /*/
Function RegT003Pos(cAlias, aParticip)

	Local cRegT003 := "T003"
	Local cTxtSys := cDirSystem + "\" + cRegT003 + ".TXT"
	Local cChaveAIf := ""
	Local cWhileAIf := ""
	Local cTipoAIf := ""
	Local cCampoAIf := ""
	Local cSequeAIf := ""
	Local cCpf := ""
	Local cCgc := ""
	Local cTpPessoa := ""
	Local cExecPAA := ""
	Local nPosicao := 0
	Local nColuna := 0
	Local aFisGetEnd := {}
	Local cCodPart := ""
	
	//Endereco fornecedor exterior
	Local cPaisEX := ""
	Local cEndEX  := ""
	Local cNumEx  := ""
	Local cComplEX := ""
	Local cBaiEX := ""
	Local cMunEX := ""
	Local cCepEX := ""
	Local aGetEndEX := {}
	Local cRelFont := ""

    Default cAlias := ""
	Default aParticip := {}

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	If Ascan(aArqGer,cTxtSys) == 0
		Aadd(aArqGer,cTxtSys)
	EndIf

	DbSelectArea("AIf")
	AIf->(DbSetOrder(1)) // O setorder Correto deve acontecer abaixo, conforme Tabela da query (SA1/SA2)

	cCpf := ""
	cCgc := ""
	cTpPessoa := ""
	cExecPAA := ""
	
	If cAlias == "SA1"
		cCodPart := "C" + SA1->(A1_COD+A1_LOJA)  // verificar se usa depara
	ElseIf cAlias == "SA2"
		cCodPart := "F" + SA2->(A2_COD+A2_LOJA)
	EndIf

	IF lBuild
		nPosicao := FindHash(oHashT003, cCodPart)
	Else
		nPosicao := aScan(aParticip,{|aX| aX[2]==cCodPart})
	EndIf
	
	If nPosicao == 0

		Aadd(aParticip,{{}})
		nPosicao := Len(aParticip)

		IF lBuild
	   		AddHash(oHashT003, cCodPart, nPosicao)
		EndIf

		Aadd(aParticip[nPosicao][1],"")	// 01 - REGISTRO
		Aadd(aParticip[nPosicao][1],"")	// 02 - COD_PART
		Aadd(aParticip[nPosicao][1],"")	// 03 - NOME
		Aadd(aParticip[nPosicao][1],"")	// 04 - COD_PAIS
		Aadd(aParticip[nPosicao][1],"")	// 05 - CNPJ
		Aadd(aParticip[nPosicao][1],"")	// 06 - CPF
		Aadd(aParticip[nPosicao][1],"")	// 07 - IE
		Aadd(aParticip[nPosicao][1],"")	// 08 - COD_MUN
		Aadd(aParticip[nPosicao][1],"")	// 09 - SUFRAMA
		Aadd(aParticip[nPosicao][1],"")	// 10 - TP_LOGR
		Aadd(aParticip[nPosicao][1],"")	// 11 - End
		Aadd(aParticip[nPosicao][1],"")	// 12 - NUM
		Aadd(aParticip[nPosicao][1],"")	// 13 - COMPL
		Aadd(aParticip[nPosicao][1],"")	// 14 - TP_BAIRRO
		Aadd(aParticip[nPosicao][1],"")	// 15 - BAIRRO
		Aadd(aParticip[nPosicao][1],"")	// 16 - UF
		Aadd(aParticip[nPosicao][1],"")	// 17 - CEP
		Aadd(aParticip[nPosicao][1],"")	// 18 - DDD
		Aadd(aParticip[nPosicao][1],"")	// 19 - FONE
		Aadd(aParticip[nPosicao][1],"")	// 20 - DDD
		Aadd(aParticip[nPosicao][1],"")	// 21 - FAX
		Aadd(aParticip[nPosicao][1],"")	// 22 - EMAIL
		Aadd(aParticip[nPosicao][1],"")	// 23 - DT_INCLUSAO
		Aadd(aParticip[nPosicao][1],"")	// 24 - TP_PESSOA
		Aadd(aParticip[nPosicao][1],"")	// 25 - RAMO_ATV
		Aadd(aParticip[nPosicao][1],"")	// 26 - COD_INST_ANP
		Aadd(aParticip[nPosicao][1],"")	// 27 - COD_ATIV
		Aadd(aParticip[nPosicao][1],"")	// 28 - COD_PAIS_EXT
		Aadd(aParticip[nPosicao][1],"")	// 29 - LOGRAD_EXT
		Aadd(aParticip[nPosicao][1],"")	// 30 - NR_LOGRAD_EXT
		Aadd(aParticip[nPosicao][1],"")	// 31 - COMPLEM_EXT
		Aadd(aParticip[nPosicao][1],"")	// 32 - BAIRRO_EXT
		Aadd(aParticip[nPosicao][1],"")	// 33 - NOME_CIDADE_EXT
		Aadd(aParticip[nPosicao][1],"")	// 34 - COD_POSTAL_EXT
		Aadd(aParticip[nPosicao][1],"")	// 35 - DT_LAUDO_MOLEST_GRAVE
		Aadd(aParticip[nPosicao][1],"")	// 36 - REL_FONTE_PAG_RESID_EXTERIOR
		Aadd(aParticip[nPosicao][1],"")	// 37 - INSCR_MUNICIPAL 
		Aadd(aParticip[nPosicao][1],"")	// 38 - SIMPLES_NACIONAL
		Aadd(aParticip[nPosicao][1],"")	// 39 - ENQUADRAMENTO
		Aadd(aParticip[nPosicao][1],"")	// 40 - OBSOLETO
		Aadd(aParticip[nPosicao][1],"")	// 41 - INDCPRB
		Aadd(aParticip[nPosicao][1],"")	// 42 - CODTRI
		Aadd(aParticip[nPosicao][1],"")	// 43 - EXECPAA
		Aadd(aParticip[nPosicao][1],"")	// 44 - IND_ASSOC_DESPORT
		Aadd(aParticip[nPosicao][1],"")	// 45 - CONTRIBUINTE
		Aadd(aParticip[nPosicao][1],"")	// 46 - INDOPCCP
		Aadd(aParticip[nPosicao][1],"")	// 47 - ISENCAO_IMUNIDADE
		Aadd(aParticip[nPosicao][1],"")	// 48 - ESTADO_EXT
		Aadd(aParticip[nPosicao][1],"")	// 49 - TELEFONE_EXT
		Aadd(aParticip[nPosicao][1],"")	// 50 - INDICATIVO_NIF
		Aadd(aParticip[nPosicao][1],"")	// 51 - NIF
		Aadd(aParticip[nPosicao][1],"")	// 52 - FORMA_TRIBUTACAO

		aParticip[nPosicao][1][01] := cRegT003

		If cAlias == "SA1"
			// Função para retorna a estrutura do Endereco passado
			aFisGetEnd := FisGetEnd(SA1->A1_End,SA1->A1_EST)

			// Chave da busca AIf
			cChaveAIf := cFilAnt+SA1->(A1_FILIAL+"SA1"+A1_COD+A1_LOJA)
			cWhileAIf := "AIf_FILIAL+AIf_FILTAB+AIf_TABELA+AIf_CODIGO+AIf_LOJA"
			cTipoAIf := "SA1_AIf"
			
			AIf->(DbSetOrder(1))

			// VerIficar qual o Tipo de Pessoa e CPF/CGC
			If AllTrim(SA1->A1_TIPO) <> "X"
				If AllTrim(SA1->A1_PESSOA) == "F"
					cCpf := SA1->A1_CGC // CPF
					cTpPessoa := "1"
				ElseIf AllTrim(SA1->A1_PESSOA) == "J"
					cCgc := SA1->A1_CGC // CGC
					cTpPessoa := "2"
				EndIf
			Else
				cTpPessoa := "3"
				
				If Len(AllTrim(SA1->A1_CGC)) == 11
					cCpf := SA1->A1_CGC // CPF
					cTpPessoa := "3"
				ElseIf Len(AllTrim(SA1->A1_CGC)) == 14
					cCgc := SA1->A1_CGC // CGC
					cTpPessoa := "3"
				EndIf
			EndIf
			
			If oFisaExtSx:_AI0
				AI0->(DbSetOrder(01))	// AI0_FILIAL+AI0_CODCLI+AI0_LOJA
				If AI0->(DbSeek(SA1->(A1_FILIAL+A1_COD+A1_LOJA))) .And. AI0->AI0_INDPAA == '1'
					cExecPAA := '1'
				Else
					cExecPAA := '0'
				EndIf
			EndIf

			aParticip[nPosicao][1][02] := cCodPart
			aParticip[nPosicao][1][03] := SA1->A1_NOME
			aParticip[nPosicao][1][04] := SA1->A1_CODPAIS
			aParticip[nPosicao][1][05] := cCgc
			aParticip[nPosicao][1][06] := cCpf
			aParticip[nPosicao][1][07] := SPEDConType(SPEDVldIE(SA1->A1_INSCR))
			aParticip[nPosicao][1][08] := IIf(SA1->A1_EST=="EX","99999",SA1->A1_COD_MUN)
			aParticip[nPosicao][1][09] := SA1->A1_SUFRAMA
			aParticip[nPosicao][1][11] := aFisGetEnd[1]
			aParticip[nPosicao][1][12] := IIf(!Empty(aFisGetEnd[2]),aFisGetEnd[3],"SN")
			aParticip[nPosicao][1][13] := SA1->A1_COMPLEM
			aParticip[nPosicao][1][15] := SA1->A1_BAIRRO
			aParticip[nPosicao][1][16] := SA1->A1_EST
			aParticip[nPosicao][1][17] := SA1->A1_CEP
			aParticip[nPosicao][1][18] := SA1->A1_DDD
			aParticip[nPosicao][1][19] := SA1->A1_TEL
			aParticip[nPosicao][1][20] := IIf(!Empty(SA1->A1_FAX),SA1->A1_DDD,"")
			aParticip[nPosicao][1][21] := SA1->A1_FAX
			aParticip[nPosicao][1][22] := SA1->A1_EMAIL
			aParticip[nPosicao][1][23] := SA1->A1_DTCAD
			aParticip[nPosicao][1][24] := cTpPessoa
			aParticip[nPosicao][1][41] := '0'
			aParticip[nPosicao][1][43] := cExecPAA
			aParticip[nPosicao][1][45] := SA1->A1_CONTRIB

		ElseIf cAlias == "SA2"
			// Função para retorna a estrutura do Endereco passado
			aFisGetEnd := FisGetEnd(SA2->A2_End,SA2->A2_EST)

			// Chave da busca AIf
			cChaveAIf := cFilAnt+SA2->(A2_FILIAL+"SA2"+A2_COD+A2_LOJA)
			cWhileAIf := "AIf_FILIAL+AIf_FILTAB+AIf_TABELA+AIf_CODIGO+AIf_LOJA"
			cTipoAIf := "SA1_AIf"
			
			AIf->(DbSetOrder(1))

			// VerIficar qual o Tipo de Pessoa e CPF/CGC
			If AllTrim(SA2->A2_TIPO) <> "X"
				If AllTrim(SA2->A2_TIPO) == "F"
					cCpf := SA2->A2_CGC // CPF
					cTpPessoa := "1"
					If Alltrim(SA2->A2_INDRUR) != "" .AND.  Alltrim(SA2->A2_INDRUR) != "0" .AND. Alltrim(SA2->A2_EST) $ "SP|MG" 
						If SA2->(DbSeek(SA2->(A2_FILIAL+A2_COD+A2_LOJA)))
							cCpf := Alltrim(SA2->A2_CPFRUR) // CPF
							cCgc := Alltrim(SA2->A2_CGC) // SE O CAMPO A2_INDRUR TIVER VALOR DIFERENTE DE ZERO E VAZIO, O CAMPO A2_CGC VIRA CNPJ MESMO SENDO PESSOA FISICA
						EndIf
					EndIf
				ElseIf AllTrim(SA2->A2_TIPO) == "J"
					cCgc := SA2->A2_CGC // CGC
					cTpPessoa := "2"
				EndIf
			Else
				cTpPessoa := "3"
				
				If Len(AllTrim(SA2->A2_CGC)) == 11
					cCpf := SA2->A2_CGC // CPF
					cTpPessoa := "3"
				ElseIf Len(AllTrim(SA2->A2_CGC)) == 14
					cCgc := SA2->A2_CGC // CGC
					cTpPessoa := "3"
				EndIf

				cPaisEX := SA2->A2_PAISEX
				aGetEndEX := FisGetEnd( SA2->A2_LOGEX, SA2->A2_ESTEX )
				cEndEX  := aGetEndEX[1]
				cNumEx  := Iif( !Empty( aGetEndEX[2]) , aGetEndEX[3], "SN" )
				cComplEX := SA2->A2_COMPLR
				cBaiEX := SA2->A2_BAIEX
				cMunEX := SA2->A2_CIDEX
				cCepEX := SA2->A2_POSEX		
				cRelFont := SA2->A2_BREEX
			EndIf

			aParticip[nPosicao][1][02] := cCodPart
			aParticip[nPosicao][1][03] := SA2->A2_NOME
			aParticip[nPosicao][1][04] := SA2->A2_CODPAIS
			aParticip[nPosicao][1][05] := cCgc
			aParticip[nPosicao][1][06] := cCpf
			aParticip[nPosicao][1][07] := SPEDConType(SPEDVldIE(SA2->A2_INSCR))
			aParticip[nPosicao][1][08] := IIf(SA2->A2_EST=="EX","99999",SA2->A2_COD_MUN)
			aParticip[nPosicao][1][11] := aFisGetEnd[1]
			aParticip[nPosicao][1][12] := IIf(!Empty(aFisGetEnd[2]),aFisGetEnd[3],"SN")
			aParticip[nPosicao][1][13] := SA2->A2_COMPLEM
			aParticip[nPosicao][1][15] := SA2->A2_BAIRRO
			aParticip[nPosicao][1][16] := SA2->A2_EST
			aParticip[nPosicao][1][17] := SA2->A2_CEP
			aParticip[nPosicao][1][18] := SA2->A2_DDD
			aParticip[nPosicao][1][19] := SA2->A2_TEL
			aParticip[nPosicao][1][20] := IIf(!Empty(SA2->A2_FAX),SA2->A2_DDD,"")
			aParticip[nPosicao][1][21] := SA2->A2_FAX
			aParticip[nPosicao][1][22] := SA2->A2_EMAIL
			aParticip[nPosicao][1][23] := ''
			aParticip[nPosicao][1][24] := cTpPessoa
			aParticip[nPosicao][1][25] := IIf(!Empty(SA2->A2_TIPORUR),"4","")

			aParticip[nPosicao][1][28] := cPaisEX
			aParticip[nPosicao][1][29] := cEndEX
			aParticip[nPosicao][1][30] := cNumEx
			aParticip[nPosicao][1][31] := cComplEX
			aParticip[nPosicao][1][32] := cBaiEX
			aParticip[nPosicao][1][33] := cMunEX
			aParticip[nPosicao][1][34] := cCepEX
			aParticip[nPosicao][1][36] := cRelFont

			If oFisaExtSx:_A2_CPRB
				aParticip[nPosicao][1][41] := IIf(!Empty(SA2->A2_CPRB) .And. SA2->A2_CPRB <> '2','1','0')
			EndIf

			If oFisaExtSx:_A2_DESPORT
				aParticip[nPosicao][1][44] := IIf(SA2->A2_DESPORT=="1","1","2")
			EndIf

			aParticip[nPosicao][1][45] := SA2->A2_CONTRIB

			If SA2->(FieldPos("A2_INDCP")) > 0
				aParticip[nPosicao][1][46] := SA2->A2_INDCP // Campo utilizado para o evento S-1250
			EndIf	

			IF oFisaExtSx:_A2_ISEIMUN
				aParticip[nPosicao][1][47] := SA2->A2_ISEIMUN
			EndIf

			IF oFisaExtSx:_A2_ESTEX
				aParticip[nPosicao][1][48] := SA2->A2_ESTEX
			EndIf

			IF  oFisaExtSx:_A2_TELRE
				aParticip[nPosicao][1][49] := SA2->A2_TELRE
			EndIf

			IF  oFisaExtSx:_A2_NIFEX .and. oFisaExtSx:_A2_MOTNIF
				aParticip[nPosicao][1][50] := IIf(!Empty(SA2->A2_NIFEX),"1",IIf(SA2->A2_MOTNIF=='1','2',IIf(SA2->A2_MOTNIF=='2','3',SA2->A2_MOTNIF)))
			EndIf

			IF  oFisaExtSx:_A2_NIFEX
				aParticip[nPosicao][1][51] := SA2->A2_NIFEX
			EndIf

			IF oFisaExtSx:_A2_TRBEX
				aParticip[nPosicao][1][52] := SA2->A2_TRBEX
			EndIf

		EndIf

		// Posiciona no registro da AIf
		If AIf->(MsSeek(cChaveAIf))
			cSequeAIf := "01"
			While AIf->(!Eof()) .And. cChaveAIf == AIf->(&cWhileAIf)
				// Esta funcao realiza o DE/PARA dos codigos do Protheus para o TAF
				cCampoAIf := FDeParaTAF(cTipoAIf,{AllTrim(AIf->AIf_CAMPO),AIf->AIf_CONTEU})

				If !Empty(cCampoAIf)
					cSequeAIf := Soma1(cSequeAIf)

					Aadd(aParticip[nPosicao],{})
					nColuna := Len(aParticip[nPosicao])

					Aadd(aParticip[nPosicao][nColuna],"T003AA")								// 01 - REGISTRO
					Aadd(aParticip[nPosicao][nColuna],DtoS(AIf->AIf_DATA))					// 02 - DT_ALT
					Aadd(aParticip[nPosicao][nColuna],AIf->AIf_HORA + ":" + cSequeAIf)		// 03 - HR_ALT
					Aadd(aParticip[nPosicao][nColuna],cCampoAIf)								// 04 - NR_CAMPO
					Aadd(aParticip[nPosicao][nColuna],AIf->AIf_CONTEU)						// 05 - CONT_ANT
				EndIf

				AIf->(DbSkip())
			EndDo
		EndIf
	EndIf

Return

/*/{Protheus.doc} RegT007Pos
    (Função para montar o registro T007 com o registro da tabela posicionada .)

    @type Static Function
    @author Caio Martins
    @since 11/12/2018
     
	@param nHdlT007, numérico, arquivo para gravar txt
	@param lAchouSB5, lógico, indica se posicionou na tabela SB5
	@param lAchouCD6, lógico, indica se posicionou na tabela CD6

    @return Nil, nulo, não tem retorno.
    /*/
Function RegT007Pos(lAchouSB5, lAchouCD6, aProdutos )
	
	Local aSpedProd := {}
	Local cChave := ""
	Local cCampo := ""
	Local cTipoPrd := ""
	Local cCodGen := ""
	Local cCodANP := ""
	Local cCodISS := ""
	Local cReg := "T007"
	Local cTxtSys := cDirSystem + "\" + cReg + ".TXT"
	Local cCmpIncB1 := ALLTRIM(oFisaExtSx:_MV_DTINCB1)
	Local cTpServ := ""
	
	Local nICMPAD := oFisaExtSx:_MV_ICMPAD
	Local nAlqProd := 0
	Local nPos := 0
	
	Local lSpedProd := ExistBlock("SPEDPROD")
	Local lGeraT007 := .T.
	Local lCmpCdAnp := .F.
	
	
	Default lAchouSB5 := .F.
	Default lAchouCD6 := .F.
	Default aProdutos := {}

	// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
	If Ascan(aArqGer,cTxtSys) == 0
		Aadd(aArqGer,cTxtSys)
	EndIf

	IF lBuild
		nPos := FindHash(oHashT007, SB1->B1_COD)  // entender se usa de para e o que fazer com filial
	Else
		nPos := aScan(aProdutos,{|aX| aX[2]==SB1->B1_COD})
	EndIf

	If nPos == 0

		cCodISS := SB1->B1_CODISS
		If !Empty(SFT->FT_CODISS)
			cCodISS := SFT->FT_CODISS
		EndIf
		
		// Funcao De/Para referente ao titulo do Produto do Protheus para o TAF
		If lSpedProd
			aSpedProd := Execblock("SPEDPROD", .F., .F., {"SB1",""})
			If Len(aSpedProd) > 11
				cTipoPrd := aSpedProd[6]
			EndIf
		Else
			cTipoPrd := FDeParaTAF( "SB1", { SB1->B1_TIPO, cCodISS } )
		EndIf
		
		// Para servico, utilizo sempre "00"
		cCodGen := "00"
		If Empty(cCodISS)
			cCodGen := Left(SB1->B1_POSIPI,2)
		EndIf
		
		//LePrado
		nAlqProd := nICMPAD
		If SB1->B1_PICM > 0
			nAlqProd := SB1->B1_PICM
		EndIf
		
		cDtIncB1 := DToS(dDataBase)
		If !Empty(cCmpIncB1) .And. SB1->(FieldPos(cCmpIncB1))>0 .And. !Empty(SB1->(&cCmpIncB1))
			cDtIncB1 := SB1->(&cCmpIncB1)
		EndIf
		
		cCodANP := ""
		If lAchouCD6 .And. !Empty(CD6->CD6_CODANP)
			cCodANP := CD6->CD6_CODANP
		EndIf
		/*
			ObtEndo o codigo do ISS atraves do cadastro da tabela CDN. Este codigo deve estar conforme LC 116/03
			Tratamento para considerar também mais de um Cod LST por Cod ISS, conforme a legislação existe a possibilidade de ser n / n   
		*/
		cProdCDN := Alltrim(SB1->B1_COD)

		//Priorizo o tipo de serviço da reinf que esta no cadastro do produto.
		if F2Q->(MsSeek(xFilial('F2Q')+cProdCDN )) 
			cTpServ := iif(oFisaExtSx:_F2Q_TPSERV,F2Q->F2Q_TPSERV,'')
		endif	

		If CDN->(MsSeek(xFilial("CDN") + cCodIss + cProdCDN)) .Or. CDN->(MsSeek(xFilial("CDN") + cCodIss))
			cCodIss := AllTrim(CDN->CDN_CODLST)
			if empty(cTpServ)		
				cTpServ := IIf(oFisaExtSx:_CDN_TPSERV,CDN->CDN_TPSERV,"")
			endif	
		Else
			cCodIss := ""
		EndIf
		
		//Tiro todos os pontos que estiverem no cadastro.
		cCodIss := StrTran(cCodIss,".","")
		
		Aadd(aProdutos,{{}})
		nPos := Len(aProdutos)
		
		IF lBuild
	   		AddHash(oHashT007, SB1->B1_COD, nPos)
		EndIf

		Aadd(aProdutos[nPos][1],cReg)									// 01 - REGISTRO
		Aadd(aProdutos[nPos][1],SB1->B1_COD)					// 02 - COD_ITEM
		Aadd(aProdutos[nPos][1],SB1->B1_DESC)					// 03 - DESCR_ITEM
		Aadd(aProdutos[nPos][1],SB1->B1_CODBAR)					// 04 - COD_BARRA
		Aadd(aProdutos[nPos][1],SB1->B1_UM)						// 05 - UNID_INV
		Aadd(aProdutos[nPos][1],cTipoPrd)								// 06 - TIPO_ITEM
		Aadd(aProdutos[nPos][1],SB1->B1_POSIPI)					// 07 - COD_NCM
		Aadd(aProdutos[nPos][1],SB1->B1_EX_NCM)					// 08 - EX_IPI
		Aadd(aProdutos[nPos][1],cCodGen)								// 09 - COD_GEN
		Aadd(aProdutos[nPos][1],cCodIss)								// 10 - COD_LST -> Na posição 10 vai o código de serviço federal.
		Aadd(aProdutos[nPos][1],cCodANP)								// 11 - COD_COMB
		Aadd(aProdutos[nPos][1],IIf(lAchouSB5,SB5->B5_TABINC,""))					// 12 - COD_TAB
		Aadd(aProdutos[nPos][1],IIf(lAchouSB5,SB5->B5_CODGRU,""))					// 13 - COD_GRU
		Aadd(aProdutos[nPos][1],SB1->B1_ORIGEM)					// 14 - ORIGEM
		Aadd(aProdutos[nPos][1],cDtIncB1)								// 15 - DT_INCLUSAO
		Aadd(aProdutos[nPos][1],Val2Str(nAlqProd,6,2))					// 16 - ALIQ_ICMS
		Aadd(aProdutos[nPos][1],"")										// 17 - ESTOQUE
		Aadd(aProdutos[nPos][1],Val2Str(SB1->B1_IPI,5,2))		// 18 - ALIQ_IPI
		Aadd(aProdutos[nPos][1],"")										// 19 - RED_BC_ICMS
		Aadd(aProdutos[nPos][1],"")										// 20 - COD_CFQ
		Aadd(aProdutos[nPos][1],"")										// 21 - COD_CNM
		Aadd(aProdutos[nPos][1],"")										// 22 - COD_GLP
		Aadd(aProdutos[nPos][1],"")										// 23 - COD_AFE
		Aadd(aProdutos[nPos][1],"")										// 24 - COD_UM
		Aadd(aProdutos[nPos][1],"")										// 25 - COD_CERTIf
		Aadd(aProdutos[nPos][1],StrTran(cCodIss,".",""))				// 26 - COD_SERV_MUN -> Na posição 26 vai o código de serviço municipal.
		Aadd(aProdutos[nPos][1],"")										// 27 - TP_PRD
		Aadd(aProdutos[nPos][1],SB1->B1_CEST)					// 28 - CEST
		Aadd(aProdutos[nPos][1],If(!Empty(cTpServ),'1' + StrZero(Val(cTpServ),08),''))	// 29 - TIP_SERV
		
		AIf->(DbSetOrder(2))	// AIf_FILIAL+AIf_FILTAB+AIf_TABELA+AIf_CODPRO+DTOS(AIf_DATA)
		AIf->(dbGoTop())

		If AIf->(MsSeek(cFilAnt+SB1->B1_FILIAL+"SB1"+SB1->B1_COD),.T.)
			
			cChave := cFilAnt+SB1->B1_FILIAL+"SB1"+SB1->B1_COD
			cSec := "01"
			
			While AIf->(!Eof()) .And. cChave == AIf->(AIf_FILIAL+AIf_FILTAB+AIf_TABELA+AIf_CODPRO)
				cSec := Soma1(cSec)	// LePrado
				cCampo := FDeParaTAF("SB1_AIf",{AllTrim(AIf->AIf_CAMPO),AIf->AIf_CONTEU})
				
				Aadd(aProdutos[Len(aProdutos)],{})
				nPos := Len(aProdutos[Len(aProdutos)])
				
				Aadd(aProdutos[Len(aProdutos)][nPos],"T007AA")						// 01 - REGISTRO
				Aadd(aProdutos[Len(aProdutos)][nPos],DtoS(AIf->AIf_DATA))			// 02 - DT_ALT
				Aadd(aProdutos[Len(aProdutos)][nPos],cCampo)						// 03 - NR_CAMPO
				Aadd(aProdutos[Len(aProdutos)][nPos],AIf->AIf_CONTEU)				// 04 - CONT_ANT
				Aadd(aProdutos[Len(aProdutos)][nPos],AIf->AIf_HORA + ":" + cSec)	// 05 - HR_ALT
				
				AIf->(DbSkip())
			EndDo
		EndIf

	EndIf
Return

/*/{Protheus.doc} AddHash
@author Caio Martins
@since 13.12.2018
/*/
//-------------------------------------------------------------------

Static Function AddHash(oHash,cChave,nPos)
Local cSet  := "HMSet"

&cSet.(oHash, cChave, nPos)

Return

//-------------------------------------------------------------------
/*/
{Protheus.doc} AddHash

@author Caio Martins
@since 13.12.2018

/*/
//-------------------------------------------------------------------
Static Function FindHash(oHash, cChave)
Local nPosRet	:= 0
Local cGet    := "HMGet"

&cGet.( oHash , cChave  , @nPosRet )

Return nPosRet

//-------------------------------------------------------------------
/*/
{Protheus.doc} FMtoFiscal
Verifica se existe estrutura do novo motor fiscal
@author Denis Souza
@since 26.02.2019

/*/
//-------------------------------------------------------------------

Static Function FNewMtoFis()

Local lRet		:= .F.
Local alGetArea	:= GetArea()

DbSelectArea("SFT")

If FieldPos("FT_IDTRIB") > 0 .And. TAFColumnPos( "F2D_IDREL" ) .And. TAFColumnPos( "F2E_IDTRIB" )
	lRet := .T.
endif

RestArea( alGetArea )

Return lRet

//-------------------------------------------------------------------
/*/
{Protheus.doc} FDeParaF2D
De / Para - Identificar o ID_TOTVS
F2D_TRIB x F2B_REGRA x F2B_TRIB x F2E_IDTRIB
@author Denis Souza
@since 01.03.2019

/*/
//-------------------------------------------------------------------

Static Function FDeParaF2D( c_Fil, c_IdTrib )

Local   cIdTrib  := ""
Local   cDePara  := ""
Default	c_Fil 	 := ""
Default	c_IdTrib := ""

//Tratamento caso a regra seja gerado na F2D
if !Empty( c_IdTrib )
	If Empty(Select("F2B")) //regra
		DbSelectArea("F2B")
	endif
	F2B->(DbSetOrder(1)) //F2B_FILIAL+F2B_REGRA+DTOS(F2B_VIGINI)+DTOS(F2B_VIGFIM)

	If Empty(Select("F2E")) //tributo
		DbSelectArea("F2E")
	endif
	F2E->(DbSetOrder(2)) //F2E_FILIAL+F2E_TRIB

	If F2B->(MsSeek( xFilial( "F2B" )  + c_IdTrib ))			
		if F2E->(MsSeek( xFilial( "F2E" ) + F2B->F2B_TRIB ))
			cDePara := F2E->F2E_IDTRIB
		endif			
	endif

	if !Empty( cDePara ) 
		if cDePara 	== "000001"
			cIdTrib := "13"
		elseif cDePara == "000002"
			cIdTrib := "24"
		elseif cDePara == "000003"
			cIdTrib := "25"
		endif
	endif
endif

Return cIdTrib

//-------------------------------------------------------------------
/*/
{Protheus.doc} FPriMtoFis
Prioriza Tributos do Motor Fiscal
@author Denis Souza
@since 07.03.2019

/*/
//-------------------------------------------------------------------

Static Function FPriMtoFis( _aTribF2D, _aRgT013AP, _aRgT015AE, _cNewFRural, _nItT015, _cCfop, _cCodIss )

Local c_CodTrb := ""
Local nCntA    := 0
Local nPosicao := 0
Local bAscan   := {||}

Default _aTribF2D   := {}
Default _aRgT013AP  := {}
Default _aRgT015AE  := {}
Default _nItT015    := 0
Default _cNewFRural := ""   
Default _cCfop		:= ""
Default _cCodIss	:= ""

/*----------------------------------------------------------------------
|Para FunRural R-2050, Prioriza Impostos Gerados Pelo Novo Motor Fiscal|
|Ao Ínves do Tradicional ( gerado por TES )							   |
----------------------------------------------------------------------*/
If len(_aTribF2D) > 0
	For nCntA := 1 To Len( _aTribF2D )
		c_CodTrb := _aTribF2D[nCntA][4]
		bAscan 	 := {|x| AllTrim(x[2]) == AllTrim(c_CodTrb) }
		nPosicao := Ascan(_aRgT013AP,bAscan)
		if nPosicao <= 0
			Aadd(_aRgT013AP,{})
			nPosicao := len( _aRgT013AP ) 

			Aadd(_aRgT013AP[nPosicao],"T013AP")				// 01	->	REGISTRO		->	NAPREGISTR
			Aadd(_aRgT013AP[nPosicao],c_CodTrb)				// 02	->	COD_TRIB		->	NAPCODTRIB
			Aadd(_aRgT013AP[nPosicao],_aTribF2D[nCntA][5])	// 03	->	BASE - NAPBS	->	NAPBS
			Aadd(_aRgT013AP[nPosicao],0) 					// 04	->	BASE_QUANT		->	NAPBSQTD
			Aadd(_aRgT013AP[nPosicao],0) 					// 05	->	BASE_NT			->	NAPBSNT
			Aadd(_aRgT013AP[nPosicao],_aTribF2D[nCntA][8])	// 06	->	VALOR			->	NAPVLR
			Aadd(_aRgT013AP[nPosicao],0) 					// 07	->	VLR_TRIBUTAVEL	->	NAPVLRTRIB
			Aadd(_aRgT013AP[nPosicao],0)					// 08	->	VLR_ISENTO		->	NAPVLRISEN
			Aadd(_aRgT013AP[nPosicao],0)					// 09	->	VLR_OUTROS		->	NAPVLROUTR
			Aadd(_aRgT013AP[nPosicao],0)					// 10	->	VALOR_NT		->	NAPVLRNT
			Aadd(_aRgT013AP[nPosicao],"")					// 11	->	CST				->	NAPCST
			Aadd(_aRgT013AP[nPosicao],_cCfop)				// 12	->	CFOP			->	NAPCFOP
			Aadd(_aRgT013AP[nPosicao],_aTribF2D[nCntA][7])	// 13	->	ALIQUOTA		->	NAPALIQ
			Aadd(_aRgT013AP[nPosicao],_cCodIss) 			// 14	->	COD_LST			->	NAPCODLST
			Aadd(_aRgT013AP[nPosicao],SFT->FT_VALCONT )		// 15	->	VL_OPER			->	NAPVLROPER
			Aadd(_aRgT013AP[nPosicao],0) 					// 16	->	VL_SCRED 		->	NAPVLRSCRE
			Aadd(_aRgT013AP[nPosicao],0) 					// 17	->	TRIBICMSST		->	TRIBICMSST
		else
			_aRgT013AP[nPosicao][3]	 += _aTribF2D[nCntA][5]
			_aRgT013AP[nPosicao][6]	 += _aTribF2D[nCntA][8]
			_aRgT013AP[nPosicao][13] := _aTribF2D[nCntA][7]
		endif

		Aadd(_aRgT015AE,{ _nItT015 , {{}} })
		nPosicao := Len( _aRgT015AE )
		Aadd(_aRgT015AE[nPosicao][2][1],"T015AE")			 // 01	->	REGISTRO		->	NAEREGISTR
		Aadd(_aRgT015AE[nPosicao][2][1],c_CodTrb)			 // 02	->	COD_TRIB		->	NAECODTRIB
		Aadd(_aRgT015AE[nPosicao][2][1],"")					 // 03	->	CST				->	NAECST
		Aadd(_aRgT015AE[nPosicao][2][1],"")					 // 04	->	MODBC			->	NAEMODBC
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 05	->	MVA				->	NAEMVA
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 06	->	PERC_RED_BC		->	NAEPRREDBS
		Aadd(_aRgT015AE[nPosicao][2][1],_aTribF2D[nCntA][5]) // 07	->	BASE			->	NAEBS
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 08	->	BASE_QUANT		->	NAEBSQTD
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 09	->	BASE_NT			->	NAEBSNT
		Aadd(_aRgT015AE[nPosicao][2][1],_aTribF2D[nCntA][7]) // 10	->	ALIQUOTA		->	NAEALIQ
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 11	->	ALIQUOTA_QUANT	->	NAEALIQQTD
		Aadd(_aRgT015AE[nPosicao][2][1],_aTribF2D[nCntA][8]) // 12	->	VALOR			->	NAEVLR
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 13	->	VLR_TRIBUTAVEL	->	NAEVLRTRIB
		Aadd(_aRgT015AE[nPosicao][2][1],"")					 // 14	->	COD_ENQ			->	NAECODENQ
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 15	->	VLR_ISENTO		->	NAEVLRISEN
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 16	->	VLR_OUTROS		->	NAEVLROUTR
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 17	->	VALOR_NT		->	NAEVLRNT
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 18	->	VL_BC_ICMS_UF	->	NAEBSICMUF
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 19	->	VL_ICMS_UF		->	NAEVLICMUF
		Aadd(_aRgT015AE[nPosicao][2][1],"")					 // 20	->	COD_ANT			->	NAECODANT
		Aadd(_aRgT015AE[nPosicao][2][1],"")					 // 21	->	MT_DES_ICMS		->	NAEMTDSICM
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 22	->	VL_SCRED 		->	NAEVLRSCRE
		Aadd(_aRgT015AE[nPosicao][2][1],"")					 // 23	->	MOT_INCIDENCIA	->	NAEMTINCID
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 24	->	VLSCONTR		->	NAEVLCONTR
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 25	->	VLRADIC			->	NAEVLRADIC
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 26	->	VLRNPAG			->	NAEVLRNPAG
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 27	->	VLRCE15			->	NAEVLRCE15
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 28	->	VLRCE20			->	NAEVLRCE20
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 29	->	VLRCE25			->	NAEVLRCE25
		Aadd(_aRgT015AE[nPosicao][2][1],0)					 // 30	->	VLRADICNPAG		->	NAEVRDICPG

		_cNewFRural += c_CodTrb + "|"
	Next nCntA
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} NotaEST003
Notas de Entrada e Saída, chamada pelo extrator fiscal para listar de forma distinta todos os fornecedores
e clientes, quando reinf = 'sim' e fitra = 'apenas cadastros', é necessário rodar as movimentações para identificar 
os participantes para o reinf.
@author Denis Souza
@since 16/05/2019
@version P12
/*/
//-------------------------------------------------------------------

Function NotaEST003( a_RegT003, oWizard )

	Local cQryPrt1 := ""
	Local cQryPrt2 := ""
	Local cQryPrin := ""
	Local cQryRnf1 := ""
	Local cQryRnf2 := "" 
	Local cOrderBy := ""
	Local cConcat  := ""

	Local nCont 	 := 0
	Local nRecPart	 := 0
	Local lTableTMS  := .F.
	Local aQtdMov    := {}

	Local dDataPgDe	 := CtoD('  /  /    ')
	Local dDataPgAte := CtoD('  /  /    ')
	Local cNotaDe	 := ""
	Local cNotaAte   := ""
	Local cSerDe     := ""
	Local cSerAte    := ""
	Local cEntSai	 := ""

	Local lNewMtoFis := FNewMtoFis( )

	If Type("oWizard") == "O"
		dDataPgDe	:= oWizard:GetDataDe()
		dDataPgAte 	:= oWizard:GetDataAte()
		cNotaDe	 	:= oWizard:GetNotaDe()
		cNotaAte    := oWizard:GetNotaAte()
		cSerDe      := oWizard:GetSerieDe()
		cSerAte     := oWizard:GetSerieAte()
		cEntSai	 	:= oWizard:GetTipoMovimento()

		if cEntSai == "1" //Ambos
			aadd( aQtdMov , 'E' )
			aadd( aQtdMov , 'S' )
		elseif cEntSai == "2" //Entradas
			aadd( aQtdMov , 'E' )
		elseif cEntSai == "3" //Saidas
			aadd( aQtdMov , 'S' )
		endif

		// Verifica o tipo de concatenação para o banco.
		If "MSSQL" $ Upper(AllTrim(TcGetDB()))
			cConcat := "+"
		Else
			cConcat := "||"
		EndIf

		// Verifica se as tabelas DT6 e DUD existem na base.
		lTableTMS := (!(DT6->(Eof()) .And. DT6->(Bof()))) .Or. (!(DUD->(Eof()) .And. DUD->(Bof())))

		for nCont := 1 to Len(aQtdMov)
			cEntSai := aQtdMov[nCont]

			cQryPrt1 := ""
			cQryPrt2 := ""
			cQryPrin := ""
			cQryRnf1 := ""
			cQryRnf2 := ""

			cQryPrt1 := " SELECT "
			cQryPrt1 += "	CAST( CASE "
			cQryPrt1 += "		WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('B','D')) THEN 'SA2' "
			cQryPrt1 += "		WHEN (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('B','D')) THEN 'SA2' "
			cQryPrt1 += "		ELSE 'SA1' "
			cQryPrt1 += "	 END as char(3)) NMALIAS "
			cQryPrt1 += " ," + xFunExpSql("COALESCE") + "(SA1.R_E_C_N_O_,0) RECSA1 "
			cQryPrt1 += " ," + xFunExpSql("COALESCE") + "(SA2.R_E_C_N_O_,0) RECSA2 "
			cQryPrt1 += "FROM " + RetSqlName("SFT") + " SFT "

			// JOIN em SA1 e SA2
			cQryPrt1 += "LEFT JOIN " + RetSqlName("SA2") + " SA2 ON "
			cQryPrt1 += "((SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ( 'B', 'D' )) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ( 'B', 'D' ))) AND "
			cQryPrt1 += "SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND "
			cQryPrt1 += "SA2.A2_COD = SFT.FT_CLIEFOR AND "
			cQryPrt1 += "SA2.A2_LOJA = SFT.FT_LOJA AND "
			cQryPrt1 += "SA2.D_E_L_E_T_ = ' ' "

			cQryPrt1 += "LEFT JOIN " + RetSqlName("SA1") + " SA1 ON "
			cQryPrt1 += "((SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ( 'B', 'D' )) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ( 'B', 'D' ))) AND "
			cQryPrt1 += "SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
			cQryPrt1 += "SA1.A1_COD = SFT.FT_CLIEFOR AND "
			cQryPrt1 += "SA1.A1_LOJA = SFT.FT_LOJA AND "
			cQryPrt1 += "SA1.D_E_L_E_T_ = ' ' "

			If cEntSai == "E"	// Movimento de entrada
				cQryPrt1 += "LEFT JOIN " + RetSqlName("SF1") + " SF1 ON "
				cQryPrt1 += "SF1.F1_FILIAL  = '" + xFilial("SF1") + "' AND "
				cQryPrt1 += "SF1.F1_DOC     = SFT.FT_NFISCAL AND "
				cQryPrt1 += "SF1.F1_SERIE   = SFT.FT_SERIE AND "
				cQryPrt1 += "SF1.F1_FORNECE = SFT.FT_CLIEFOR AND "
				cQryPrt1 += "SF1.F1_LOJA    = SFT.FT_LOJA AND "
				cQryPrt1 += "SF1.D_E_L_E_T_ = ' ' "

				cQryPrt1 += "INNER JOIN " + RetSqlName("SD1") + " SD1 ON "	
				cQryPrt1 += "SD1.D1_FILIAL  = '" + xFilial("SD1") + "' AND "
				cQryPrt1 += "SD1.D1_DOC     = SFT.FT_NFISCAL AND "
				cQryPrt1 += "SD1.D1_SERIE   = SFT.FT_SERIE AND "
				cQryPrt1 += "SD1.D1_FORNECE = SFT.FT_CLIEFOR AND "
				cQryPrt1 += "SD1.D1_LOJA    = SFT.FT_LOJA AND "
				cQryPrt1 += "SD1.D1_COD     = SFT.FT_PRODUTO AND "
				cQryPrt1 += "SD1.D1_ITEM    = SFT.FT_ITEM AND "
				cQryPrt1 += "SD1.D_E_L_E_T_	= ' ' "

				MntQryRnf( .T., lNewMtoFis, @cQryRnf1, @cQryRnf2, "SD1.D1_BASEFUN", cEntSai, .t. ) //NotaEST003() só é invocada para lReinf = .t.

			Else			// Movimento de Saida
				cQryPrt1 += "LEFT JOIN " + RetSqlName("SF2") + " SF2 ON "
				cQryPrt1 += "SF2.F2_FILIAL  = '" + xFilial("SF2") + "' AND "
				cQryPrt1 += "SF2.F2_DOC     = SFT.FT_NFISCAL AND "
				cQryPrt1 += "SF2.F2_SERIE   = SFT.FT_SERIE AND "
				cQryPrt1 += "SF2.F2_CLIENTE = SFT.FT_CLIEFOR AND "
				cQryPrt1 += "SF2.F2_LOJA    = SFT.FT_LOJA AND "
				cQryPrt1 += "SF2.D_E_L_E_T_ = ' ' "

				cQryPrt1 += "INNER JOIN " + RetSqlName("SD2") + " SD2 ON "
				cQryPrt1 += "SD2.D2_FILIAL  = '" + xFilial("SD2") + "' AND "
				cQryPrt1 += "SD2.D2_DOC     = SFT.FT_NFISCAL AND "
				cQryPrt1 += "SD2.D2_SERIE   = SFT.FT_SERIE AND "
				cQryPrt1 += "SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND "
				cQryPrt1 += "SD2.D2_LOJA    = SFT.FT_LOJA AND "
				cQryPrt1 += "SD2.D2_COD     = SFT.FT_PRODUTO AND "
				cQryPrt1 += "SD2.D2_ITEM    = SFT.FT_ITEM AND "
				cQryPrt1 += "SD2.D_E_L_E_T_ = ' ' "

				MntQryRnf( .T., lNewMtoFis, @cQryRnf1, @cQryRnf2, "SD2.D2_BASEFUN", cEntSai, .t. ) //NotaEST003() só é invocada para lReinf = .t.
			EndIf

			cQryPrt2 += "LEFT JOIN " + RetSqlName("SF4") + " SF4 ON "
			cQryPrt2 += "SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND "

			If cEntSai == "E"	// Movimento de entrada
				cQryPrt2 += "SF4.F4_CODIGO = SD1.D1_TES AND "
			Else 				// Movimento de Saida
				cQryPrt2 += "SF4.F4_CODIGO = SD2.D2_TES AND "
			EndIf
			cQryPrt2 += "SF4.D_E_L_E_T_ = ' ' "

			cQryPrt2 += "LEFT JOIN " + RetSqlName("SB5") + " SB5 ON "
			cQryPrt2 += "SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND "
			cQryPrt2 += "SB5.B5_COD = SFT.FT_PRODUTO AND "
			cQryPrt2 += "SB5.D_E_L_E_T_ = ' ' "

			If lTableTMS
				cQryPrt2 += " LEFT OUTER JOIN ( "
				cQryPrt2 += " 	SELECT "
				cQryPrt2 += " 		 DT6.DT6_FILDOC FILDOC "
				cQryPrt2 += " 		,DT6.DT6_DOC DOC "
				cQryPrt2 += " 		,DT6.DT6_SERIE SERIE "
				cQryPrt2 += " 		,DT6.R_E_C_N_O_ RECDT6 "
				cQryPrt2 += " 		,DUD.RECDUD "
				cQryPrt2 += " 	FROM " + RetSqlName("DT6") + " DT6 "
				
				cQryPrt2 += " 	LEFT OUTER JOIN ( "
				cQryPrt2 += " 		SELECT "
				cQryPrt2 += " 			 DUD.DUD_FILDOC "
				cQryPrt2 += " 			,DUD.DUD_DOC "
				cQryPrt2 += " 			,DUD.DUD_SERIE "
				cQryPrt2 += " 			,MIN(DUD.R_E_C_N_O_) RECDUD "
				cQryPrt2 += " 		FROM " + RetSqlName("DUD") + " DUD "
				
				cQryPrt2 += " 		WHERE "
				cQryPrt2 += " 			DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
				cQryPrt2 += " 			AND DUD.D_E_L_E_T_ = ' ' "
				
				cQryPrt2 += " 		GROUP BY "
				cQryPrt2 += " 			  DUD.DUD_FILDOC "
				cQryPrt2 += " 			 ,DUD.DUD_DOC "
				cQryPrt2 += " 			 ,DUD.DUD_SERIE "
				cQryPrt2 += " 	) DUD ON "
				cQryPrt2 += " 		DUD.DUD_FILDOC = DT6.DT6_FILDOC "
				cQryPrt2 += " 		AND DUD.DUD_DOC = DT6.DT6_DOC "
				cQryPrt2 += " 		AND DUD.DUD_SERIE = DT6.DT6_SERIE "
				
				cQryPrt2 += " 	WHERE "
				cQryPrt2 += " 		DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
				cQryPrt2 += " 		AND DT6.D_E_L_E_T_ = ' ' "
				cQryPrt2 += " ) TMS ON "
				cQryPrt2 += " 	TMS.FILDOC = SFT.FT_FILIAL "
				cQryPrt2 += " 	AND TMS.DOC = SFT.FT_NFISCAL "
				cQryPrt2 += " 	AND TMS.SERIE = SFT.FT_SERIE "
			EndIf

			cQryPrt2 += ", " + RetSqlName("SB1") + " SB1 "

			cQryPrt2 += "WHERE "
			cQryPrt2 += "	SFT.FT_FILIAL = '" + xFilial("SFT") + "' "
			cQryPrt2 += "	AND SFT.FT_TIPOMOV = '" + cEntSai + "' "
			cQryPrt2 += "	AND SFT.FT_ENTRADA BETWEEN '" + DToS(dDataPgDe) + "' AND '" + DToS(dDataPgAte) + "' "
			cQryPrt2 += "	AND SFT.FT_NFISCAL BETWEEN '" + cNotaDe + "' AND '" + cNotaAte + "' "
			if !(Empty(cSerDe) .And. cSerAte=='ZZZ')
				cQryPrt2 += "	AND SFT.FT_SERIE BETWEEN '" + cSerDe + "' AND '" + cSerAte + "' "
			Endif

			If !Empty(oWizard:GetEspecie())
				cQryPrt2 += " AND SFT.FT_ESPECIE IN (" + oWizard:GetEspecie(.T.) +  ") "
			EndIf

			cQryPrt2 += "	AND ( "
			cQryPrt2 += "		(SFT.FT_ENTRADA <= '" + DToS(dDataPgAte) + "' AND SFT.FT_CFOP NOT IN ('1601','1602','1605','5601','5602','5605')) "		
			cQryPrt2 += "	) "

			cQryPrt2 += "	AND	SB1.B1_FILIAL	=	'" + xFilial("SB1") + "' "
			cQryPrt2 += "	AND SB1.B1_COD		=	SFT.FT_PRODUTO "
			cQryPrt2 += "	AND SB1.D_E_L_E_T_	=	' ' "

			cQryPrt2 += "	AND SFT.D_E_L_E_T_ = ' ' "

			cQryPrin := cQryPrt1 + cQryRnf1 + cQryPrt2

				/*
					É possível configurar os tributos do FUNRURAL pelo configurador de Tributos do módulo fiscal ( FISA170 )
					Amarração F2E x F2C -> F2C_CODIGO = '000001','000002' ou '000003'

					As querys para extrair notas de Reinf:
					- Analisando tabela da SFT ( FT_BASEINS, FT_BSSENAR )
					- Analisando notas geradas pelo configurador ( FT_IDTRIB != '' )
					são identicas
					Por isso, foi particionado a query principal em cQryPrt1 e cQryPrt2, adicionando apenas a diferença entre elas
					cQryRnf1 -> analisa SFT
					cQryRnf2 -> analisa FT_IDTRIB != ''
					para ser utilizado pelo UNION
				*/
			If lNewMtoFis
				cQryPrin += " UNION " + cQryPrt1 + cQryRnf2 + cQryPrt2
			EndIf

			cQryPrin += " UNION  "

			cQryPrin += " SELECT "

			cQryPrin += "	CAST (CASE "
			cQryPrin += "		WHEN (SFT2.FT_TIPOMOV = 'E' AND SFT2.FT_TIPO NOT IN ('B','D')) THEN 'SA2' "
			cQryPrin += "		WHEN (SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_TIPO IN ('B','D')) THEN 'SA2' "
			cQryPrin += "		ELSE 'SA1' "
			cQryPrin += "	 END AS CHAR(3)) NMALIAS "
		
			cQryPrin += " ," + xFunExpSql("COALESCE") + "(SA1.R_E_C_N_O_,0) RECSA1 "
			cQryPrin += " ," + xFunExpSql("COALESCE") + "(SA2.R_E_C_N_O_,0) RECSA2 "

			cQryPrin += "FROM " + RetSqlName("SFT") + " SFT2 "

			// JOIN em SA1 e SA2
			cQryPrin += "LEFT JOIN " + RetSqlName("SA2") + " SA2 ON "
			cQryPrin += "((SFT2.FT_TIPOMOV = 'E' AND SFT2.FT_TIPO NOT IN ( 'B', 'D' )) OR (SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_TIPO IN ( 'B', 'D' ))) AND "
			cQryPrin += "SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND "
			cQryPrin += "SA2.A2_COD = SFT2.FT_CLIEFOR AND "
			cQryPrin += "SA2.A2_LOJA = SFT2.FT_LOJA AND "
			cQryPrin += "SA2.D_E_L_E_T_ = ' ' "

			cQryPrin += "LEFT JOIN " + RetSqlName("SA1") + " SA1 ON "
			cQryPrin += "((SFT2.FT_TIPOMOV = 'S' AND SFT2.FT_TIPO NOT IN ( 'B', 'D' )) OR (SFT2.FT_TIPOMOV = 'E' AND SFT2.FT_TIPO IN ( 'B', 'D' ))) AND "
			cQryPrin += "SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
			cQryPrin += "SA1.A1_COD = SFT2.FT_CLIEFOR AND "
			cQryPrin += "SA1.A1_LOJA = SFT2.FT_LOJA AND "
			cQryPrin += "SA1.D_E_L_E_T_ = ' ' "

			If cEntSai == "E"	// Movimento de entrada
				cQryPrin += "LEFT JOIN " + RetSqlName("SF1") + " SF1 ON "
				cQryPrin += "SF1.F1_FILIAL  = '" + xFilial("SF1") + "' AND "
				cQryPrin += "SF1.F1_DOC     = SFT2.FT_NFISCAL AND "
				cQryPrin += "SF1.F1_SERIE   = SFT2.FT_SERIE AND "
				cQryPrin += "SF1.F1_FORNECE = SFT2.FT_CLIEFOR AND "
				cQryPrin += "SF1.F1_LOJA    = SFT2.FT_LOJA AND "
				cQryPrin += "SF1.D_E_L_E_T_ = ' ' "
			
				cQryPrin += "INNER JOIN " + RetSqlName("SD1") + " SD1 ON "
				cQryPrin += "SD1.D1_FILIAL  = '" + xFilial("SD1") + "' AND "
				cQryPrin += "SD1.D1_DOC     = SFT2.FT_NFISCAL AND "
				cQryPrin += "SD1.D1_SERIE   = SFT2.FT_SERIE AND "
				cQryPrin += "SD1.D1_FORNECE = SFT2.FT_CLIEFOR AND "
				cQryPrin += "SD1.D1_LOJA    = SFT2.FT_LOJA AND "
				cQryPrin += "SD1.D1_COD     = SFT2.FT_PRODUTO AND "
				cQryPrin += "SD1.D1_ITEM    = SFT2.FT_ITEM AND "
				cQryPrin += "SD1.D_E_L_E_T_	= ' ' "
				cQryPrin += " AND SFT2.FT_BASEINS = 0 AND SD1.D1_BASEFUN = 0 AND SFT2.FT_BSSENAR = 0 "
			Else			// Movimento de Saida 
				cQryPrin += "LEFT JOIN " + RetSqlName("SF2") + " SF2 ON "
				cQryPrin += "SF2.F2_FILIAL  = '" + xFilial("SF2") + "' AND "
				cQryPrin += "SF2.F2_DOC     = SFT2.FT_NFISCAL AND "
				cQryPrin += "SF2.F2_SERIE   = SFT2.FT_SERIE AND "
				cQryPrin += "SF2.F2_CLIENTE = SFT2.FT_CLIEFOR AND "
				cQryPrin += "SF2.F2_LOJA    = SFT2.FT_LOJA AND "
				cQryPrin += "SF2.D_E_L_E_T_ = ' ' "

				cQryPrin += "INNER JOIN " + RetSqlName("SD2") + " SD2 ON "
				cQryPrin += "SD2.D2_FILIAL  = '" + xFilial("SD2") + "' AND "
				cQryPrin += "SD2.D2_DOC     = SFT2.FT_NFISCAL AND "
				cQryPrin += "SD2.D2_SERIE   = SFT2.FT_SERIE AND "
				cQryPrin += "SD2.D2_CLIENTE = SFT2.FT_CLIEFOR AND "
				cQryPrin += "SD2.D2_LOJA    = SFT2.FT_LOJA AND "
				cQryPrin += "SD2.D2_COD     = SFT2.FT_PRODUTO AND "
				cQryPrin += "SD2.D2_ITEM    = SFT2.FT_ITEM AND "
				cQryPrin += "SD2.D_E_L_E_T_ = ' ' "
				cQryPrin += " AND SFT2.FT_BASEINS = 0 AND SD2.D2_BASEFUN = 0 AND SFT2.FT_BSSENAR = 0 "
			EndIf

			cQryPrin += " INNER JOIN " + RetSqlName("CDG") + " CDG ON CDG.CDG_FILIAL = '" + xFilial("CDG") + "' "
			cQryPrin += " AND CDG.CDG_DOC = SFT2.FT_NFISCAL "
			cQryPrin += " AND CDG.CDG_SERIE = SFT2.FT_SERIE "
			cQryPrin += " AND CDG.CDG_CLIFOR = SFT2.FT_CLIEFOR "
			cQryPrin += " AND CDG.CDG_LOJA = SFT2.FT_LOJA "
			cQryPrin += " AND CDG.CDG_ITEM = SFT2.FT_ITEM "
			cQryPrin += " AND CDG.CDG_TPMOV = SFT2.FT_TIPOMOV  "
			cQryPrin += " AND CDG.D_E_L_E_T_ = ' ' "

			cQryPrin += " INNER JOIN " + RetSqlName("CCF") + " CCF ON CCF.CCF_FILIAL = '" + xFilial("CCF") + "' "
			cQryPrin += " AND CCF.CCF_TRIB IN ('1','2','3','4') "
			cQryPrin += " AND CCF.CCF_NUMERO = CDG.CDG_PROCES  "
			cQryPrin += " AND CCF.CCF_IDITEM = CDG.CDG_ITPROC "
			cQryPrin += " AND CCF.CCF_TIPO = CDG.CDG_TPPROC "
			cQryPrin += " AND CCF.D_E_L_E_T_ = ' ' "

			cQryPrin += "LEFT JOIN " + RetSqlName("SF4") + " SF4 ON "
			cQryPrin += "SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND "
			If cEntSai == "E"	// Movimento de entrada
				cQryPrin += "SF4.F4_CODIGO = SD1.D1_TES AND "
			Else 				// Movimento de Saida
				cQryPrin += "SF4.F4_CODIGO = SD2.D2_TES AND "
			EndIf
			cQryPrin += "SF4.D_E_L_E_T_ = ' ' "

			cQryPrin += "LEFT JOIN " + RetSqlName("SB5") + " SB5 ON "
			cQryPrin += "SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND "
			cQryPrin += "SB5.B5_COD = SFT2.FT_PRODUTO AND "
			cQryPrin += "SB5.D_E_L_E_T_ = ' ' "

			If lTableTMS
				cQryPrin += " LEFT OUTER JOIN ( "
				cQryPrin += " 	SELECT "
				cQryPrin += " 		 DT6.DT6_FILDOC FILDOC "
				cQryPrin += " 		,DT6.DT6_DOC DOC "
				cQryPrin += " 		,DT6.DT6_SERIE SERIE "
				cQryPrin += " 		,DT6.R_E_C_N_O_ RECDT6 "
				cQryPrin += " 		,DUD.RECDUD "
				cQryPrin += " 	FROM " + RetSqlName("DT6") + " DT6 "
				
				cQryPrin += " 	LEFT OUTER JOIN ( "
				cQryPrin += " 		SELECT "
				cQryPrin += " 			 DUD.DUD_FILDOC "
				cQryPrin += " 			,DUD.DUD_DOC "
				cQryPrin += " 			,DUD.DUD_SERIE "
				cQryPrin += " 			,MIN(DUD.R_E_C_N_O_) RECDUD "
				cQryPrin += " 		FROM " + RetSqlName("DUD") + " DUD "
				
				cQryPrin += " 		WHERE "
				cQryPrin += " 			DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
				cQryPrin += " 			AND DUD.D_E_L_E_T_ = ' ' "
				
				cQryPrin += " 		GROUP BY "
				cQryPrin += " 			  DUD.DUD_FILDOC "
				cQryPrin += " 			 ,DUD.DUD_DOC "
				cQryPrin += " 			 ,DUD.DUD_SERIE "
				cQryPrin += " 	) DUD ON "
				cQryPrin += " 		DUD.DUD_FILDOC = DT6.DT6_FILDOC "
				cQryPrin += " 		AND DUD.DUD_DOC = DT6.DT6_DOC "
				cQryPrin += " 		AND DUD.DUD_SERIE = DT6.DT6_SERIE "
				
				cQryPrin += " 	WHERE "
				cQryPrin += " 		DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
				cQryPrin += " 		AND DT6.D_E_L_E_T_ = ' ' "
				cQryPrin += " ) TMS ON "
				cQryPrin += " 	TMS.FILDOC = SFT2.FT_FILIAL "
				cQryPrin += " 	AND TMS.DOC = SFT2.FT_NFISCAL "
				cQryPrin += " 	AND TMS.SERIE = SFT2.FT_SERIE "
			EndIf

			cQryPrin += ", " + RetSqlName("SB1") + " SB1 "

			cQryPrin += "WHERE "
			cQryPrin += "	SFT2.FT_FILIAL = '" + xFilial("SFT") + "' "
			cQryPrin += "	AND SFT2.FT_TIPOMOV = '" + cEntSai + "' "
			cQryPrin += "	AND SFT2.FT_ENTRADA BETWEEN '" + DToS(dDataPgDe) + "' AND '" + DToS(dDataPgAte) + "' "

			cQryPrin += "	AND SFT2.FT_NFISCAL BETWEEN '" + cNotaDe + "' AND '" + cNotaAte + "' "	
			If !(empty(cSerDe) .And. cSerAte=="ZZZ")
				cQryPrin += "	AND SFT2.FT_SERIE BETWEEN '" + cSerDe + "' AND '" + cSerAte + "' "
			Endif
			If !Empty(oWizard:GetEspecie())
				cQryPrin += "	AND SFT2.FT_ESPECIE IN (" + oWizard:GetEspecie(.T.) +  ") " 
			EndIf

			cQryPrin += "	AND ( "
			cQryPrin += "		(SFT2.FT_ENTRADA <= '" + DToS(dDataPgAte) + "' AND SFT2.FT_CFOP NOT IN ('1601','1602','1605','5601','5602','5605')) "
			cQryPrin += "	) "

			cQryPrin += "	AND	SB1.B1_FILIAL	= '" + xFilial("SB1") + "' "
			cQryPrin += "	AND SB1.B1_COD		= SFT2.FT_PRODUTO "
			cQryPrin += "	AND SB1.D_E_L_E_T_	= ' ' "
			
			cQryPrin += "	AND SFT2.D_E_L_E_T_ = ' ' "

			cOrderBy := "	DADOS.NMALIAS, DADOS.RECSA1, DADOS.RECSA2 "

			cQryPrin := "%" + cQryPrin + "%"
			cOrderBy := "%" + cOrderBy + "%"

			cAliasQry := GetNextAlias()

			BeginSql Alias cAliasQry
				SELECT *
				FROM (%Exp:cQryPrin%) DADOS
				ORDER BY
					%Exp:cOrderBy%
			EndSql

			(cAliasQry)->(DbGotop())
			While (cAliasQry)->(!Eof())
				nRecPart := 0
				if (cAliasQry)->RECSA1 > 0
					nRecPart := (cAliasQry)->RECSA1
				elseif (cAliasQry)->RECSA2 > 0
					nRecPart := (cAliasQry)->RECSA2
				endif
				if nRecPart > 0
					( (cAliasQry)->NMALIAS )->( DbGoTo( nRecPart ) )
					RegT003Pos( (cAliasQry)->NMALIAS , @a_RegT003 )
				endif
				(cAliasQry)->(DBSkip())
			EndDo
			If !Empty(cAliasQry)
				(cAliasQry)->(DBCloseArea())
				cAliasQry := nil
			EndIf
		Next nCont
	Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQryRnf
Trecho de query utilizado para extrair notas somente para Reinf, considerando:

	lCadMovRnf -> Cliente selecionou "Filtra Reinf" igual a "1 - Sim"
	lNewMtoFis -> Já possui estrutura de tabelas do configurador de tributos do módulo Fiscal

@author Wesley Pinheiro
@since 12/02/2020

/*/
//-------------------------------------------------------------------
Static Function MntQryRnf( lCadMovRnf, lNewMtoFis, cQryRnf1, cQryRnf2, cBaseFun, cEntSai, lFltRnf )
Default cEntSai := "S"
Default lFltRnf := .f.

	If lCadMovRnf 
		cQryRnf1 := " AND (( SFT.FT_BASEINS > 0 "
		if !lFltRnf .or. cEntSai == "S"
			cQryRnf1 += "OR " + cBaseFun + " > 0 OR SFT.FT_BSSENAR > 0 ) "
		endif
		If lFltRnf .And. cEntSai == "E"
			cQryRnf1 += "OR " + cBaseFun + " > 0 OR SFT.FT_BSSENAR > 0 ) AND SA2.A2_TIPO = 'F' OR (SFT.FT_BASEINS > 0 AND SA2.A2_TIPO <> 'F') "
		endif

		cQryRnf1 += " ) "		
		If lNewMtoFis
			cQryRnf2 += " AND SFT.FT_IDTRIB <> ''	"
			cQryRnf2 += " INNER JOIN " + RetSqlName( "F2D" ) + " F2D "
			cQryRnf2 += "   ON F2D.F2D_FILIAL = SFT.FT_FILIAL "
			cQryRnf2 += "   AND F2D_IDREL = SFT.FT_IDTRIB "
			cQryRnf2 += "   AND F2D.D_E_L_E_T_ = SFT.D_E_L_E_T_ "
			cQryRnf2 += " INNER JOIN " + RetSqlName( "F2B" ) + " F2B "
			cQryRnf2 += "   ON F2B.F2B_FILIAL = '" + xFilial( "F2B" ) + "'  "
			cQryRnf2 += "   AND F2B_REGRA = F2D_TRIB "
			cQryRnf2 += "   AND F2B.D_E_L_E_T_ = F2D.D_E_L_E_T_ "
			cQryRnf2 += " INNER JOIN " + RetSqlName( "F2E" ) + " F2E "
			cQryRnf2 += "   ON F2E.F2E_FILIAL = '" + xFilial( "F2E" ) + "' "
			cQryRnf2 += "   AND F2E.F2E_TRIB = F2B.F2B_TRIB "
			cQryRnf2 += "   AND F2E.D_E_L_E_T_ = F2B.D_E_L_E_T_ "
			cQryRnf2 += "   AND F2E.F2E_IDTRIB IN ( '000001', '000002', '000003' ) "
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetStSpd
Função responsável por retornar o valor do ICMS ST validando o parâmetro MV_RESF3FT
@author Henrique Pereira
@since 27/07/2016
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apesar dos valores de SF3 e SFT serem os mesmos, a gravacao das tabelas nao sao,|
//|e se for considerado os campos correspondentes, os valores apresentados serao   |
//|diferentes, e para resolver isso preciso temos que saber qual tabela esta sendo |
//|considerada na apuracao de ICMS, para isso faco o tratamento abaixo.            |
//|Se o parametro MV_RESF3FT estiver configurado para considerar a tabela SFT,     |
//| tenho que somar os campos de retido+isento+outros, pois nao eh gravado conforme|
//| conforme a SF3, que grava sempre o ICMS retido independente da escrituracao.   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
//-------------------------------------------------------------------
Static Function RetStSpd(lResF3FT, cAliasSFT)

Local nRet := 0

Default lResF3FT  := .F.
Default cAliasSFT := ''

If lResF3FT .And. !Empty(cAliasSFT)
	//Na tabela SFT o valor de ICMS Retido pode alternar nas colunas dependendo da escrituracao
	nRet := (cAliasSFT)->(FT_ICMSRET+FT_OUTRRET+FT_ISENRET)
Else
	//Na tabela SF3 o valor do ICMS Retido sempre eh gravado em ICMSRET, independente da escrituracao
	nRet := (cAliasSFT)->(FT_ICMSRET)
EndIf

Return nRet
