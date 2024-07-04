#Include "SpedFiscal.ch"
#Include "Protheus.ch"
#Include "FWCommand.ch"
#Include "SpedXdef.ch"

// Chamada das funcoes de cache do dicionario na inicializacao do SPEDXFUN
Static aSPDSX2 := SpedLoadX2()
Static aSPDSX3 := SpedLoadX3()
Static aSPDSX6 := SpedLoadX6()
Static aExistBloc := SPDFRetPEs()

Static cBarraUnix := IIf(IsSrvUnix(),"/","\")

Static lJob := IsBlind()

/*/{Protheus.doc} ExtGeraCIAP
Função responsável pela geração dos registros de Movimentação CIAP do Extrator Fiscal

@type Function
@Author Rodrigo Aguilar
@since 13/12/2016

@param a_Wizard, array, InFormaçoes da Wizard do extrator fiscal 
@param a_LisFil, array, Array de seleção de filiais no Formato padrão da rotina BlocoG

@Return aGerou, array, se gerou ou não.
/*/
Function ExtGeraCIAP(a_Wizard,a_LisFil)

	Local cAlias	:= ''
	Local cFilDe   	:= ''
	Local cFilAte   := ''
	Local cTxtSys := cDirSystem + cBarraUnix

	Local lTop		:= .T.
	Local lEnd 		:= .F.

	Local nCtdFil   := 1 
	Local nRegsProc := 0 
	Local nI		:= 0
	Local nIniReg	:= 0
	Local nY		:= 0
	Local nZ		:= 0

	Local aReg0190  := {}
	Local aReg0200  := {}
	Local aReg0220  := {}  
	Local aReg0150  := {}

	Local aRegT050	:= {}
	Local aRegT050AA:= {}
	Local aRegT050AB:= {}
	Local aRegT050AC:= {}
	Local aRegT050AD:= {}
	Local aRegT008	:= {}
	Local aRegT008Aux:= {}
	
	Local aGerou := {}

	Local oProcess := Nil

	//Executo somente para a filial que esta sendo processada dentro do laço, cada filial terá seus dados
	//de movimentação CIAP individualizado
	Local bWhileSM0 := {|| !SM0->(Eof()) .And. (cEmpAnt == SM0->M0_CODIGO .Or. cFilAnt == cFilAte) }

	Aadd(aGerou,{"T008",.F.})
	Aadd(aGerou,{"T050",.F.})
	
	//se o usuário selecionou as filiais de processamento eu preciso setar de "" a "zz" as filiais de
	//processamento, visto que o controle de qual filial será processada ficara a cargo do a_LisFil 
	If !Empty(a_LisFil)
		cFilDe := PadR("",FWGETTAMFILIAL)
		cFilAte := Repl("Z",FWGETTAMFILIAL)
	Else	// Caso contrário considero apenas a filial corrente para processamento do Bloco G                
		cFilDe := cFilAnt  
		cFilAte := cFilAnt  
	EndIf

	BlocoG( cAlias, lTop, a_Wizard, @aReg0200, @aReg0190, @aReg0220, @aReg0150, cFilDe,;
			cFilAte, a_LisFil, bWhileSM0, @lEnd, nCtdFil, 1, @nRegsProc, @oProcess, .T.,;
			@aRegT050, @aRegT050AA, @aRegT050AB, @aRegT050AC, @aRegT050AD, @aRegT008, @aRegT008Aux )

	// Inico da geração das inFormações referentes a cadastro de bens ou componentes do ativo imobilizado ( T008 )
	If oWizard:LayoutSel("T008")
		If lJob
			MsgJobExt("Gerando Registro T008 - Bens e Ativos...")
		ElseIf Type("oProcess") == "O"
			oProcess:Inc1Progress()
			oProcess:Inc2Progress("Gerando Registro T008 - Bens e Ativos...")
		EndIf
		
		If !Empty(aRegT008)
			aGerou[1][2] := .T.

			nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys + "T008.TXT"),0)     
			Aadd(aArqGer,(cTxtSys + "T008.TXT"))
			
			RegT008(nHdlTxt,aRegT008,aRegT008Aux)
			
			If cTpSaida == "1" 
				FClose( nHdlTxt )
			EndIf
		EndIf
	EndIf

	// Inico da geração das inFormações referentes a movimentação CIAP ( T050 )

	// Realizar a emissão dos registros T050 ( Movimentação CIAP ) e seus respectivos filhos 
	If oWizard:LayoutSel("T050")
		If lJob
			MsgJobExt("Gerando Registro T050 - Movimentação CIAP...")
		ElseIf Type("oProcess") == "O"
			oProcess:Inc1Progress()
			oProcess:Inc2Progress("Gerando Registro T050 - Movimentação CIAP...")
		EndIf
		
		If !Empty(aRegT050)
			aGerou[2][2] := .T.

			nHdlTxt := IIf(cTpSaida == "1",MsFCreate(cTxtSys + "T050.TXT"),0)     
			Aadd(aArqGer,(cTxtSys+"T050.TXT"))
			
			RegT050(nHdlTxt,aRegT050)

			For nI := 1 To Len(aRegT050AA)
				//Geração do registro T050AA
				RegT050AA( nHdlTxt, aRegT050AA[nI] )

				//Laço para Geração do registro T050AB
				nIniReg := Ascan(aRegT050AB,{|x| x[1] == nI })		
				If nIniReg > 0
					For nY := nIniReg To Len(aRegT050AB)
						If aRegT050AB[ny][1] == nI
							RegT050AB(nHdlTxt,aRegT050AB[nY])
						Else
							Exit
						EndIf					
					Next
				EndIf
				
				//Laço para Geração do registro T050AC
				nIniReg := Ascan(aRegT050AC,{|x| x[1] == nI })
				If nIniReg > 0
					For nY := nIniReg to Len(aRegT050AC)
						If aRegT050AC[ny][1] == nI
							RegT050AC(nHdlTxt,aRegT050AC[nY])
							
							//Laço para Geração do registro T050AD
							nIniReg := Ascan(aRegT050AD,{|x| x[1] == nY })

							If nIniReg > 0
								For nZ := nIniReg To Len(aRegT050AD)
									If aRegT050AD[nZ][1] == nY
										RegT050AD(nHdlTxt,aRegT050AD[nZ])
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
			Next

			//Grava o registro na TABELA TAFST1 
			If cTpSaida == "2"
				FConcST1()
			EndIf	 
			
			If cTpSaida == "1" 
				FClose( nHdlTxt )
			EndIf
			
		EndIf
	EndIf

Return aGerou

/*/{Protheus.doc} RegT008
	(Realiza a geracao do registro T008 do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 13/12/2016

	@param nHdlTxt, numerico, Handle de geracao do Arquivo
	@param aRegT008, array, com inFormacoes do registro T008
	@param aRegT008Aux, array, com inFormacoes do registro T008Aux
			
	@Return Nil, nulo, não tem retorno
	/*/
Static Function RegT008(nHdlTxt,aRegT008,aRegT008Aux)
	
	Local aRegs := {}

	Local nZ := 0
	Local nK := 0

	Default nHdlTxt := 0
		
	Default aRegT008 := {}
	Default aRegT008Aux := {}

	For nZ := 1 To Len(aRegT008)
		aRegs := {}

		Aadd( aRegs, {  'T008',;
						aRegT008[ nZ, 2],;	
						aRegT008[ nZ, 3],;
						aRegT008[ nZ, 4],;
						aRegT008[ nZ, 5],;
						aRegT008[ nZ, 6],;
						aRegT008[ nZ, 7],;
						'',;
						'',;
						'' } )

		If (nPos:= aScan( aRegT008Aux, { |x| x[1] == nZ } )) > 0				  
			For nK := nPos to len( aRegT008Aux )		 
				If aRegT008Aux[ nK, 1 ] == nPos
					aRegs[ len(aRegs), 8 ] := aRegT008Aux[ nK, 3 ]
					aRegs[ len(aRegs), 9 ] := aRegT008Aux[ nK, 4 ]
					aRegs[ len(aRegs), 10] := aRegT008Aux[ nK, 5 ]
				Else
					Exit	
				EndIf
			Next
		EndIf
		
		FConcTxt(aRegs,nHdlTxt)

		//Grava o registro na TABELA TAFST1 
		If cTpSaida == "2"
			FConcST1()
		EndIf
	Next
		
Return

/*/{Protheus.doc} RegT050
	(Realiza a geracao do registro T050 do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 12/12/2016

	@param nHdlTxt, numerico, Handle de geracao do Arquivo
	@param aRegT050, array, com inFormacoes do registro T050

	@Return Nil, nulo, não tem retorno
	/*/
Static Function RegT050(nHdlTxt,aRegT050)
	
	Local aRegs := {}

	Default nHdlTxt := 0
		
	Default aRegT050 := {}

	Aadd( aRegs, {  'T050',;
					dTos( aRegT050[1,2] ),;
					dToS( aRegT050[1,3] ),;
					Val2Str( aRegT050[1,4], 16, 2  ),;
					Val2Str( aRegT050[1,5], 16, 2  ),;
					Val2Str( aRegT050[1,6], 16, 2  ),;
					Val2Str( aRegT050[1,7], 16, 2  ),;
					aRegT050[1,8],;
					Val2Str( aRegT050[1,9], 16, 2  ),;
					Val2Str( aRegT050[1,10], 16, 2  ) } )
		
	FConcTxt(aRegs,nHdlTxt)
	
Return Nil

/*/{Protheus.doc} RegT050AA
	(Realiza a geracao do registro T050AA do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 12/12/2016

	@param nHdlTxt, numerico, Handle de geracao do Arquivo
	@param aRegT050AA, array, com inFormacoes do registro T050AA

	@Return Nil, nulo, não tem retorno
	/*/
Static Function RegT050AA(nHdlTxt,aRegT050AA)
	
	Local aRegs := {}

	Default nHdlTxt := 0
		
	Default aRegT050AA := {}

	Aadd( aRegs, {  'T050AA',;
					aRegT050AA[02],;
					dToS(aRegT050AA[03]),;						
					aRegT050AA[04],;
					Val2Str( aRegT050AA[05], 16, 2  ),;					  
					Val2Str( aRegT050AA[06], 16, 2  ),;
					Val2Str( aRegT050AA[07], 16, 2  ),;
					Val2Str( aRegT050AA[08], 16, 2  ),;
					aRegT050AA[09],;
					Val2Str( aRegT050AA[10], 16, 2  ) } )
			
	FConcTxt(aRegs,nHdlTxt)
	
Return Nil

/*/{Protheus.doc} RegT050AB
	(Realiza a geracao do registro T050AB do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 12/12/2016

	@param nHdlTxt, numerico, Handle de geracao do Arquivo
	@param aRegT020AB, array, com inFormacoes do registro T050AB

	@Return Nil, nulo, não tem retorno
	/*/
Static Function RegT050AB(nHdlTxt,aRegT050AB)
	
	Local cDataIni := iIf( valtype( aRegT050AB[3] ) == 'D', dTos( aRegT050AB[3] ), aRegT050AB[3] ) 
	Local cDataFin := iIf( valtype( aRegT050AB[4] ) == 'D', dTos( aRegT050AB[4] ), aRegT050AB[4] )
	Local cIndPart := iIf( valtype( aRegT050AB[9] ) == 'N', Val2Str( aRegT050AB[09], 16, 8 ), aRegT050AB[9] )
	Local aRegs := {}

	Default nHdlTxt := 0
		
	Default aRegT050AC := {}

	Aadd( aRegs, {  'T050AB',;
					cDataIni,;
					cDataFin,;				  
					aRegT050AB[5],;
					Val2Str( aRegT050AB[06], 16, 2  ),;
					Val2Str( aRegT050AB[07], 16, 2  ),;
					Val2Str( aRegT050AB[08], 16, 2  ),;			  
					cIndPart,;
					Val2Str( aRegT050AB[10], 16, 2  ) } )

	FConcTxt(aRegs,nHdlTxt)
		
Return Nil

/*/{Protheus.doc} RegT050AC
	(Realiza a geracao do registro T050AC do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 12/12/2016

	@param nHdlTxt, numerico, Handle de geracao do Arquivo
	@param aRegT020AC, array, com inFormacoes do registro T050AC

	@Return Nil, nulo, não tem retorno
	/*/
Static Function RegT050AC(nHdlTxt,aRegT050AC)
	
	Local aRegs := {}

	Default nHdlTxt := 0
	
	Default aRegT050AC := {}

	Aadd( aRegs, {  'T050AC',;
					aRegT050AC[3],;		  
					aRegT050AC[4],;
					aRegT050AC[5],;
					aRegT050AC[6],;
					aRegT050AC[7],;
					aRegT050AC[8],;
					DToS(aRegT050AC[9])})

	FConcTxt(aRegs,nHdlTxt)
		
Return Nil

/*/{Protheus.doc} RegT050AD
	(Realiza a geracao do registro T050AD do TAF)

	@type Static Function
	@author Rodrigo Aguilar
	@since 12/12/2016

	@param nHdlTxt, numerico, Handle de geracao do Arquivo
	@param aRegT050AD, array, com inFormacoes do registro T050AD

	@Return Nil, nulo, não tem retorno
	/*/
Static Function RegT050AD(nHdlTxt,aRegT050AD)
	
	Local aRegs := {}

	Default nHdlTxt := 0
	
	Default aRegT050AD := {}

	Aadd(aRegs,{'T050AD',aRegT050AD[3],aRegT050AD[4]})
									
	FConcTxt(aRegs,nHdlTxt)
		
Return Nil

/*/{Protheus.doc} AddHash
	(Função para adicionar o hash)

	@type Static Function
	@author Simone Oliveira	
	@since 31/07/2017

	@param oHash, objeto, contém o hash
	@param cChave, caracter, contém a chave

	@return Nil, nulo, não tem retorno
	/*/
Static Function AddHash(oHash,cChave,nPos)

	Local cSet := "HMSet"

	Default oHash := NIL
	
	Default cChave := ""
	
	Default nPos := 0

	&cSet.(oHash,cChave,nPos)

Return Nil

/*/{Protheus.doc} FindHash
	(Função para encontrar o hash)

	@type Static Function
	@author Simone Oliveira	
	@since 31/07/2017

	@param oHash, objeto, contém o hash
	@param cChave, caracter, contém a chave

	@return nPosRet, numerico, posição contido no hash
	/*/
Static Function FindHash(oHash,cChave)

	Local nPosRet := 0

	Local cGet := "HMGet"

	Default oHash := Nil
	
	Default cChave := ""

	&cGet.(oHash,cChave,@nPosRet)

Return nPosRet