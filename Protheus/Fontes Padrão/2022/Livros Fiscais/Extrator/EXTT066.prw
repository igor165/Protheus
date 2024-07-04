#Include 'Protheus.ch'
#Include 'RwMake.ch'

Static oFisaExtSx := FisaExtX02()

Static cBarraUnix := IIf(IsSrvUnix(),"/","\")

/*/{Protheus.doc} ExtInfoExp
	(Realiza a geracao do registro T066 do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 26/12/2016
	
	@param a_Wizard, array, InFormaçoes da Wizard do extrator fiscal 
	@param a_LisFil, array, Array de seleção de filiais no Formato padrão da rotina BlocoG
	@param l_TabComp, logico, tabela complementar da geração do Sped Fiscal        

	@return lGerou, logico, se gerou ou não.
	/*/
Function ExtInfoExp(a_Wizard,a_LisFil,l_TabComp)

	Local cAlias   := ""
	Local cFilDe   := "" 
	Local cFilAte  := "" 
	Local cTxtSys := cDirSystem + cBarraUnix

	Local lSigaEEC := oFisaExtSx:_MV_EECFAT
	Local lEECSPED := oFisaExtSx:_MV_EECSPED
	Local lEnd     := .F. 
	Local lGerou := .F. 

	Local nCount1 := 0
	Local nCount2 := 0
	Local nCount3 := 0
	Local nPosicao := 0      

	Local aReg0200 := {}      
	Local aReg0190 := {} 
	Local aReg0220 := {} 
	Local aReg0150 := {} 
	Local aRegT066 := {} 
	Local aRegT066AA := {} 
	Local aRegT066AB := {}  

	Local bWhileSM0 := Nil

	Local oProcess := Nil

	Private lConcFil := .F.	// Variavel private para sobrepor a mesma variavel no sped.
	
	/*
		se o usuário selecionou as filiais de processamento eu preciso setar de "" a "zz" as filiais de
		processamento, visto que o controle de qual filial será processada ficara a cargo do a_LisFil 
	*/
	If !Empty(a_LisFil)
		cFilDe := PadR('',FWGETTAMFILIAL)
		cFilAte := Repl('Z',FWGETTAMFILIAL)
	// Caso contrário considero apenas a filial corrente para processamento do Bloco G                
	Else
		cFilDe := cFilAnt  
		cFilAte := cFilAnt  
	EndIf            

	// Executo somente para a filial que esta sendo processada dentro do laço, cada filial terá seus dados
	bWhileSM0 := {|| !SM0->(Eof()) .And. (cEmpAnt == SM0->M0_CODIGO .Or. cFilAnt == cFilAte) }

	/*
		Operações de exportação direta e indirata
		Funções Reg100Av e Reg110Spd localizada no SpedFiscal.prw
	*/
	If lSigaEEC .And. lEECSPED
		// Reg1100Av(cAlias,aReg0200,aReg0190,aReg0220,aReg0150,a_Wizard,cFilDe,cFilAte,a_LisFil,oProcess,nCtdFil,lEnd,bWhileSM0,nCountTot,nRegsProc,lExtratTaf,aRegT066,aRegT066AA,aRegT066AB)
		Reg1100Av(cAlias,aReg0200,aReg0190,aReg0220,aReg0150,a_Wizard,cFilDe,cFilAte,a_LisFil,@oProcess,1,lEnd,bWhileSM0,1,1,.T.,@aRegT066,@aRegT066AA,@aRegT066AB)

		// Função para ajustar as datas dos arrays. A função do average retorna 'DDMMAAAA' e o TAF espera 'AAAAMMDD'.
		AverageDt(@aRegT066,@aRegT066AA,@aRegT066AB)
	ElseIf lSigaEEC .Or. l_TabComp 
		// Reg1100Spd(cAlias,aReg0200,aReg0190,aReg0220,aReg0150,a_Wizard,cFilDe,cFilAte,a_LisFil,oProcess,nCtdFil,lEnd,bWhileSM0,nCountTot,nRegsProc,lExtratTaf,aRegT066,aRegT066AA,aRegT066AB)
		Reg1100Spd(cAlias,aReg0200,aReg0190,aReg0220,aReg0150,a_Wizard,cFilDe,cFilAte,a_LisFil,@oProcess,1,lEnd,bWhileSM0,1,1,.T.,@aRegT066,@aRegT066AA,@aRegT066AB)
	EndIf

	// Somente sigo a geração se houver  movimentação do registro T066	    	
	If Len(aRegT066) > 0
		lGerou := .T.

		nHdlTxt := IIf(cTpSaida == '1',MsFCreate(cTxtSys + 'T066.TXT'),0)

		Aadd(aArqGer,(cTxtSys + 'T066.TXT'))
					
		For nCount1 := 1 To Len(aRegT066)
			// Geração do registro T066
			RegT066(nHdlTxt,aRegT066[nCount1]) 

			// Laço para Geração do registro T066AA
			nPosicao := Ascan(aRegT066AA,{|x| x[1] == nCount1 })

			If !Empty(nPosicao)
				For nCount2 := nPosicao To Len(aRegT066AA)
				
					If aRegT066AA[nCount2][1] == nCount1
						// Função para gerar o registro T066AA
						RegT066AA(nHdlTxt,aRegT066AA[nCount2])

						// Laço para Geração do registro T066AB
						nPosicao := aScan( aRegT066AB, {|x| x[1] == nCount2 })

						If !Empty(nPosicao)
							For nCount3 := nPosicao To Len(aRegT066AB)
								If aRegT066AB[nCount3][1] == nCount2
									// Função para gerar o registro T066AB
									RegT066AB(nHdlTxt,aRegT066AB[nCount3])
								Else
									Exit
								EndIf
							Next
						EndIf						
					Else
						Exit
					EndIf					
				Next
			EndIf
			
			// Grava o registro na TABELA TAFST1
			If cTpSaida == "2"
				FConcST1()
			EndIf
		Next
		
		If cTpSaida == "1"
			FClose(nHdlTxt)
		EndIf	
	EndIf
	
Return lGerou

/*/{Protheus.doc} AverageDt
	(Função para ajustar os campos datas vindo do average. Os mesmo retorna como caracter 'DDMMAAAA', porém o TAF recebe)

	@type Static Function
	@author Vitor Ribeiro
	@since 07/05/2018
	
	@param aRegT066, array, Array com informacoes do registro T066
	@param aRegT066AA, array, Array com informacoes do registro T066AA
	@param aRegT066AB, array, Array com informacoes do registro T066AB

	@return Nil, nulo, não tem retorno.
	/*/
Static Function AverageDt(aRegT066,aRegT066AA,aRegT066AB)

	Local nCount := 0

	Default aRegT066 := {}
	Default aRegT066AA := {}
	Default aRegT066AB := {}

	For nCount := 1 To Len(aRegT066)
		aRegT066[nCount][04] := SubStr(aRegT066[nCount][04],5,4) + SubStr(aRegT066[nCount][04],3,2) + SubStr(aRegT066[nCount][04],1,2)
		aRegT066[nCount][07] := SubStr(aRegT066[nCount][07],5,4) + SubStr(aRegT066[nCount][07],3,2) + SubStr(aRegT066[nCount][07],1,2)
		aRegT066[nCount][09] := SubStr(aRegT066[nCount][09],5,4) + SubStr(aRegT066[nCount][09],3,2) + SubStr(aRegT066[nCount][09],1,2)
		aRegT066[nCount][10] := SubStr(aRegT066[nCount][10],5,4) + SubStr(aRegT066[nCount][10],3,2) + SubStr(aRegT066[nCount][10],1,2)
	Next

	For nCount := 1 To Len(aRegT066AA)
		aRegT066AA[nCount][07] := SubStr(aRegT066AA[nCount][07],5,4) + SubStr(aRegT066AA[nCount][07],3,2) + SubStr(aRegT066AA[nCount][07],1,2)
	Next

	For nCount := 1 To Len(aRegT066AB)
		aRegT066AB[nCount][07] := SubStr(aRegT066AB[nCount][07],5,4) + SubStr(aRegT066AB[nCount][07],3,2) + SubStr(aRegT066AB[nCount][07],1,2)
	Next

Return Nil

/*/{Protheus.doc} RegT066
	(Realiza a geracao do registro T066 do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 26/12/2016
	
	@param nHdlTxt, numerico, Handle de geracao do Arquivo
	@param aRegT066, array, Array com informacoes do registro T066

	@return Nil, nulo, não tem retorno.
	/*/
Static Function RegT066(nHdlTxt,aRegT066)

	Local aDados := {}

	Local nPosicao := 0

	Local cDtDecla := ''
	Local cDtExpor := ''
	Local cDtConhe := ''
	Local cDtAverb := ''

	Default nHdlTxt := 0
	Default aRegT066 := {}

	If !Empty(aRegT066) .And. Len(aRegT066) > 11
		cDtDecla := IIf(Valtype(aRegT066[04])=='D',DToS(aRegT066[04]),aRegT066[04])
		cDtExpor := IIf(Valtype(aRegT066[07])=='D',DToS(aRegT066[07]),aRegT066[07])
		cDtConhe := IIf(Valtype(aRegT066[09])=='D',DToS(aRegT066[09]),aRegT066[09])
		cDtAverb := IIf(Valtype(aRegT066[10])=='D',DToS(aRegT066[10]),aRegT066[10])

		Aadd(aDados,{})
		nPosicao := Len(aDados)

		Aadd(aDados[nPosicao],'T066')			// 01 - REGISTRO
		Aadd(aDados[nPosicao],aRegT066[02])		// 02 - IND_DOC
		Aadd(aDados[nPosicao],aRegT066[03])		// 03 - NRO_DE
		Aadd(aDados[nPosicao],cDtDecla)			// 04 - DT_DE
		Aadd(aDados[nPosicao],aRegT066[05])		// 05 - NAT_EXP
		Aadd(aDados[nPosicao],aRegT066[06])		// 06 - NRO_RE
		Aadd(aDados[nPosicao],cDtExpor)			// 07 - DT_RE
		Aadd(aDados[nPosicao],aRegT066[08])		// 08 - CHC_EMB
		Aadd(aDados[nPosicao],cDtConhe)			// 09 - DT_CHC
		Aadd(aDados[nPosicao],cDtAverb)			// 10 - DT_AVB
		Aadd(aDados[nPosicao],aRegT066[11])		// 11 - TP_CHC
		Aadd(aDados[nPosicao],aRegT066[12])		// 12 - PAIS
		Aadd(aDados[nPosicao],'')				// 13 - UF_EMBQ
		Aadd(aDados[nPosicao],'')				// 14 - LOC_EMBQ
	EndIf
									
	FConcTxt(aDados,nHdlTxt)

Return Nil

/*/{Protheus.doc} RegT066AA
	(Realiza a geracao do registro T066AA do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 26/12/2016
	
	@param nHdlTxt, numerico, Handle de geracao do Arquivo
	@param aRegT066AA, array, Array com informacoes do registro T066AA

	@return Nil, nulo, não tem retorno.
	/*/
Static Function RegT066AA(nHdlTxt,aRegT066AA)

	Local cData := ""

	Local aDados := {}

	Local nPosicao := 0

	Default nHdlTxt := 0
	Default aRegT066AA := {}

	If !Empty(aRegT066AA) .And. Len(aRegT066AA) > 7
		If ValType(aRegT066AA[07]) == "D"
			cData := DToS(aRegT066AA[07])
		Else
			cData := aRegT066AA[07]
		EndIf

		Aadd(aDados,{})
		nPosicao := Len(aDados)

		Aadd(aDados[nPosicao],"T066AA")			// 01 - REGISTRO
		Aadd(aDados[nPosicao],aRegT066AA[03])	// 02 - COD_MOD
		Aadd(aDados[nPosicao],aRegT066AA[04])	// 03 - SERIE
		Aadd(aDados[nPosicao],aRegT066AA[05])	// 04 - NUM_DOC
		Aadd(aDados[nPosicao],aRegT066AA[06])	// 05 - CHV_NFE
		Aadd(aDados[nPosicao],cData)			// 06 - DT_DOC
		Aadd(aDados[nPosicao],aRegT066AA[08])	// 07 - COD_ITEM
		Aadd(aDados[nPosicao],"")				// 08 - COD_REL

		FConcTxt(aDados,nHdlTxt)
	EndIf

Return Nil

/*/{Protheus.doc} RegT066AB
	(Realiza a geracao do registro T066AB do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 26/12/2016
	
	@param nHdlTxt, numerico, Handle de geracao do Arquivo
	@param aRegT066AB, array, Array com informacoes do registro T066AB

	@return Nil, nulo, não tem retorno.
	/*/
Static Function RegT066AB(nHdlTxt,aRegT066AB)

	Local cData := ""
	Local cQtde := "" 

	Local aDados := {}

	Local nPosicao := 0

	If !Empty(aRegT066AB) .And. Len(aRegT066AB) > 10
		If ValType(aRegT066AB[07]) == "D"
			cData := DToS(aRegT066AB[07])
		Else
			cData := aRegT066AB[07]
		EndIf

		If ValType(aRegT066AB[10]) == "N"
			cQtde := Val2Str(aRegT066AB[10],16,3)
		ElseIf ValType(aRegT066AB[10]) == "C"
			cQtde := Val2Str(Val(aRegT066AB[10]),16,3)
		Else
			cQtde := Val2Str(0,16,3)
		EndIf

		Aadd(aDados,{})
		nPosicao := Len(aDados)

		Aadd(aDados[nPosicao],"T066AB")			// 01 - REGISTRO
		Aadd(aDados[nPosicao],aRegT066AB[03])		// 02 - COD_PART
		Aadd(aDados[nPosicao],aRegT066AB[04])		// 03 - COD_MOD
		Aadd(aDados[nPosicao],aRegT066AB[05])		// 04 - SER
		Aadd(aDados[nPosicao],aRegT066AB[06])		// 05 - NUM_DOC
		Aadd(aDados[nPosicao],cData)				// 06 - DT_DOC
		Aadd(aDados[nPosicao],aRegT066AB[08])		// 07 - CHV_NFE
		Aadd(aDados[nPosicao],aRegT066AB[09])		// 08 - NR_ MEMO
		Aadd(aDados[nPosicao],cQtde)				// 09 - QTD
		Aadd(aDados[nPosicao],aRegT066AB[11])		// 10 - UNID
		Aadd(aDados[nPosicao],Val2Str(0,16,2))	// 11 - VLR_UNI
		Aadd(aDados[nPosicao],Val2Str(0,16,2))	// 12 - VLR_TOT
		
		FConcTxt(aDados,nHdlTxt)
	EndIf

Return Nil

