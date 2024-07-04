#Include "Protheus.ch" 
#Include "RwMake.ch"

// Include do SpedFiscal é necessário por conta da constante STR0036
#Include "SpedFiscal.ch"

#Define __CTEXTO__ STR0036

Static oFisaExtSx := FisaExtX02()

/*/{Protheus.doc} RegT013AA
Realiza a geracao do registro T013AA do TAF

@author Rodrigo Aguilar
@since 27/03/2013

@param nHdlTxt, numerico, handle de Gravacao do Registro T013

@return Nulo, não tem retorno.

@obs Nesta Funcao ja estamos posicionados na tabela de complemento da NF, assim podemos utilizar o Alias diretamente.
Função refeita. - Vitor Ribeiro - 07/02/2018
/*/
Function RegT013AA(nHdlTxt,lAchouCDT,lAchouCDC,cEntSai,cSituaDoc,cFormProp,cFormula,cMenNota)
	
	Local cSpdSitInf := ""
	Local cChaveCDT := ""
	Local cTxtCompl := ""
	
	Local aRegT013AA := {}
	Local aSpdSitinf := {}
	
	Local nMVSPDIFC	:= oFisaExtSx:_MV_SPDIFC
	Local nPosicao := 0
	
	Local lCdtDcComp := oFisaExtSx:_CDT_DCCOMP
	
	Default nHdlTxt := 0
	
	Default lAchouCDT := .F.
	Default lAchouCDC := .F.
	
	Default cEntSai := ""
	Default cSituaDoc := ""
	Default cFormProp := ""
	Default cFormula := ""
	Default cMenNota := ""

	Aadd(aSpdSitinf,{"CANNFE",__CTEXTO__})
	
	cSpdSitInf := SPEDSitInf("SFT")
	
	/*
		Gera C110 para registros que conte'm apenas INFORMACAO COMPLEMENTAR 
		Crédito presumido Paraná - Art. 69. Para a apropriação do crédito presumido, de que trata o Anexo III
	*/
	If oFisaExtSx:_MV_ESTADO == "PR" .And. cEntSai == "E" .And. cSituaDoc $ "08" .And. cFormProp == "0" .And. !Empty(cFormula)
		
		aSpdSitinf[1] := "CRP" + Right(AllTrim(CDT->CDT_DOC),3)
		aSpdSitinf[2] := Formula(cFormula)
		
		Aadd(aRegT013AA,{})
		nPosicao := Len(aRegT013AA)
		
		
		Aadd(aRegT013AA[nPosicao],"C110")			// 01 - REGISTRO
		Aadd(aRegT013AA[nPosicao],aSpdSitinf[1])	// 02 - COD_INF
		Aadd(aRegT013AA[nPosicao],aSpdSitinf[2])	// 03 - TXT_COMPL
		
	EndIf
	
	If cSpdSitInf $ "08"
		
		Aadd(aRegT013AA,{})
		nPosicao := Len(aRegT013AA)
		
		Aadd(aRegT013AA[nPosicao],"C110")			// 01 - REGISTRO
		Aadd(aRegT013AA[nPosicao],aSpdSitinf[1])	// 02 - COD_INF
		Aadd(aRegT013AA[nPosicao],aSpdSitinf[2])	// 03 - TXT_COMPL
		   
	ElseIf lAchouCDT
		
		DbSelectArea("CCE")		// INFORMACOES COMPLEMENTARES
		CCE->(DbSetOrder(1))	// CCE_FILIAL+CCE_COD
		
		cChaveCDT := CDT->(CDT_FILIAL+CDT_TPMOV+CDT_DOC+CDT_SERIE+CDT_CLIFOR+CDT_LOJA)
		
		// Busca as Informacoes complementares do Documento Fiscal
		While CDT->(!Eof()) .And. cChaveCDT == CDT->(CDT_FILIAL+CDT_TPMOV+CDT_DOC+CDT_SERIE+CDT_CLIFOR+CDT_LOJA)
			if !empty(CDT->CDT_IFCOMP)
				If nMVSPDIFC == 0
					
					If CCE->(MsSeek(xFilial("CCE")+CDT->CDT_IFCOMP))
						cTxtCompl := CCE->CCE_DESCR
					EndIf
					
				ElseIf nMVSPDIFC == 1 .Or. nMVSPDIFC == 3
					
					If lCdtDcComp .And. !Empty(CDT->CDT_DCCOMP)
						cTxtCompl := CDT->CDT_DCCOMP
					ElseIf lAchouCDC .And. !Empty(CDC->CDC_DCCOMP)
						cTxtCompl := CDC->CDC_DCCOMP
					EndIf
				
				ElseIf nMVSPDIFC == 2 .And. !Empty(cMenNota)
					cTxtCompl := cMenNota
				Else
					cTxtCompl := ""
				EndIf
				
				Aadd(aRegT013AA,{})
				nPosicao := Len(aRegT013AA)
				
				Aadd(aRegT013AA[nPosicao],"T013AA")			// 01 - REGISTRO
				Aadd(aRegT013AA[nPosicao],CDT->CDT_IFCOMP)	// 02 - COD_INF
				Aadd(aRegT013AA[nPosicao],cTxtCompl)		// 03 - TXT_COMPL
			endif	
			
			CDT->(DbSkip())
		EndDo
		
	EndIf
	
	FConcTxt(aRegT013AA,nHdlTxt)
	
Return Nil


/*/{Protheus.doc} RegT013AC
Realiza a geracao do registro T013AC do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt, numerico, Handle de Gravacao do Registro T013
@Param cEspecie, caracter, Especie da NF
@Param aCmpAntSFT, array, Informacoes da NF

@Return Nil, sem retorno.

@author Rodrigo Aguilar
@since  01/04/2013
@version 1.0

@Obs Função refeita e atualização do layout do TAF. Vitor Ribeiro - 29/11/2017
/*/
Function RegT013AC(nHdlTxt,cEspecie,aCmpAntSFT)
	
	Local cReg := "T013AC"
	Local cAcDraw := ""
	Local cDocImp := ""
	Local cChaveCD5 := ""
	
	Local lAcDraw := oFisaExtSx:_CD5_ACDRAW
	Local lDtPPis := oFisaExtSx:_CD5_DTPPIS
	Local lDtPCof := oFisaExtSx:_CD5_DTPCOF
	Local lLocal := oFisaExtSx:_CD5_LOCAL
	
	Local aRegs := {}
	
	Local nPosicao := 0
	
	If CD5->(!Eof())
		CD5->(DbSetOrder(4))	// CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_ITEM
		
		cChaveCD5 := CD5->(CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA)
		
		//Busca as Informacoes complementares do Documento Fiscal
		While CD5->(!Eof()) .And. CD5->(CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA) == cChaveCD5
			
			cDocImp := CD5->CD5_DOCIMP
			cAcDraw := Iif(lAcDraw,CD5->CD5_ACDRAW,"")
			
			nPosicao := aScan(aRegs, {|x| x[3] == cDocImp .And. x[4] == cAcDraw})
			
			// Se não encontrou 
			If Empty(nPosicao)
				// Array principal
				Aadd(aRegs,{})				
				nPosicao := Len(aRegs)
				
				// Campos, do 1 ao 30, conforme o layout do TAF - Vitor Ribeiro - 29/11/2017
				Aadd(aRegs[nPosicao],cReg)									// 01 - REGISTRO
				Aadd(aRegs[nPosicao],CD5->CD5_TPIMP)						// 02 - COD_DOC_IMP
				Aadd(aRegs[nPosicao],cDocImp)								// 03 - NUM_DOC_IMP
				Aadd(aRegs[nPosicao],cAcDraw)								// 04 - NUM_ACDRAW
				Aadd(aRegs[nPosicao],Iif(lDtPPis,DToS(CD5->CD5_DTPPIS),""))	// 05 - DT_PAG_PIS
				Aadd(aRegs[nPosicao],Iif(lDtPCof,DToS(CD5->CD5_DTPCOF),""))	// 06 - DT_PAG_COFINS
				Aadd(aRegs[nPosicao],Iif(lLocal,CD5->CD5_LOCAL,""))			// 07 - LOC_EXE_SERV
				Aadd(aRegs[nPosicao],"0")									// 08 - VL_TOT_SERV
				Aadd(aRegs[nPosicao],"0")									// 09 - VL_BC_PIS
				Aadd(aRegs[nPosicao],"0")									// 10 - VL_PIS_IMP
				Aadd(aRegs[nPosicao],"0")									// 11 - VL_BC_COFINS
				Aadd(aRegs[nPosicao],"0")									// 12 - VL_COFINS_IMP
				Aadd(aRegs[nPosicao],"")									// 13 -	[RESERVADO] - DT_REG
				Aadd(aRegs[nPosicao],"")									// 14 -	[RESERVADO] - LOC_DESEMB
				Aadd(aRegs[nPosicao],"")									// 15 -	[RESERVADO] - UF_DESEMB
				Aadd(aRegs[nPosicao],"")									// 16 -	[RESERVADO] - DT_DESB
				Aadd(aRegs[nPosicao],"")									// 17 -	[RESERVADO] - COD_EXP
				Aadd(aRegs[nPosicao],"")									// 18 -	[RESERVADO] - ADICAO
				Aadd(aRegs[nPosicao],"")									// 19 -	[RESERVADO] - SEQ_ADI
				Aadd(aRegs[nPosicao],"")									// 20 -	[RESERVADO] - FABRIC
				Aadd(aRegs[nPosicao],"")									// 21 -	[RESERVADO] - VLR_DESC
				Aadd(aRegs[nPosicao],"")									// 22 -	[RESERVADO] - NUM_PED
				Aadd(aRegs[nPosicao],"")									// 23 -	[RESERVADO] - IT_PED
				Aadd(aRegs[nPosicao],"")									// 24 -	[RESERVADO] - BASEII
				Aadd(aRegs[nPosicao],"")									// 25 -	[RESERVADO] - VLR_II
				Aadd(aRegs[nPosicao],"")									// 26 -	[RESERVADO] - DESP_ADU
				Aadd(aRegs[nPosicao],"")									// 27 -	[RESERVADO] - VLR_IOF
				Aadd(aRegs[nPosicao],"")									// 28 - MOEDA
				Aadd(aRegs[nPosicao],"")									// 29 - VL_MOEDA_ORIGEM
				Aadd(aRegs[nPosicao],"")									// 30 - VL_MOEDA_DEST
			EndIf
			
			aRegs[nPosicao][08] := Val2Str(Val(StrTran(aRegs[nPosicao][08],",",".")) + Iif(cEspecie $ "  ",aCmpAntSFT[15],0),16,2)	// 08 - VL_TOT_SERV
			aRegs[nPosicao][09] := Val2Str(Val(StrTran(aRegs[nPosicao][09],",",".")) + CD5->CD5_BSPIS,16,2)							// 09 - VL_BC_PIS
			aRegs[nPosicao][10] := Val2Str(Val(StrTran(aRegs[nPosicao][10],",",".")) + CD5->CD5_VLPIS,16,2)							// 10 - VL_PIS_IMP
			aRegs[nPosicao][11] := Val2Str(Val(StrTran(aRegs[nPosicao][11],",",".")) + CD5->CD5_BSCOF,16,2)							// 11 - VL_BC_COFINS
			aRegs[nPosicao][12] := Val2Str(Val(StrTran(aRegs[nPosicao][12],",",".")) + CD5->CD5_VLCOF,16,2)							// 12 - VL_COFINS_IMP
			
			CD5->(DbSkip())			
		EndDo
		
		If !Empty(aRegs)
			FConcTxt(aRegs,nHdlTxt)
		EndIf
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AE

Realiza a geracao do registro T013AE do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

		nHdlTxt    -> Handle de Gravacao do Registro T013

@Return ( Nil )

@author Rodrigo Aguilar
@since  01/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AE(nHdlTxt)
	
Local cChvComp := ""
Local cReg     := "T013AE"
Local cTpImp   := ""

Local aRegs := {}

cChvComp := CDC->( CDC_FILIAL + CDC_TPMOV + CDC_DOC + CDC_SERIE + CDC_CLIFOR + CDC_LOJA )

//Busca as Informacoes complementares do Documento Fiscal
While CDC->( !Eof() ) .And. ( cChvComp == CDC->( CDC_FILIAL + CDC_TPMOV + CDC_DOC + CDC_SERIE + CDC_CLIFOR + CDC_LOJA ) )
	cTpImp := Posicione("SF6",1,xFilial("SF6") + CDC->CDC_UF + CDC->CDC_GUIA,"F6_TIPOIMP") 
	aRegs := {}
	CDC->( Aadd( aRegs, {  cReg,;
		IIF(empty(cTpImp),"",iif(cTpImp == "0","0","1")),;
		CDC_GUIA } ) )
	
	
	FConcTxt( aRegs, nHdlTxt )
	
	CDC->( DbSkip() )
Enddo
	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AF

Realiza a geracao do registro T013AF do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

		nHdlTxt     -> Handle de Gravacao do Registro T013
		cEntSai     -> Informa se o Movimento eh referente a Entrada / Saida
		aCmpAntSFT  -> Informacoes da Nota Fiscal

@Return ( Nil )

@author Rodrigo Aguilar
@since  01/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AF(nHdlTxt,cEntSai,aCmpAntSFT)
	
Local cChvComp := ""

Local cIndEmit := ""
Local cIndOper := ""
Local cCodMod  := ""
Local cDtEmiss := ""
Local cCodPar  := ""

Local cReg  := "T013AF"

Local lRet  := .T.

Local aRegs := {}

cChvComp := CDD->( CDD_FILIAL + CDD_TPMOV + CDD_DOC + CDD_SERIE + CDD_CLIFOR + CDD_LOJA )

//Busca as Informacoes complementares do Documento Fiscal
While CDD->( !Eof() ) .And. ( cChvComp == CDD->( CDD_FILIAL + CDD_TPMOV + CDD_DOC + CDD_SERIE + CDD_CLIFOR + CDD_LOJA )  )
	
	//Inicio as Variaveis com os valores Default
	cIndEmit := ""
	cIndOper := ""
	cCodMod  := ""
	cDtEmiss := ""
	cCodPar  := ""
	lRet     := .T.
	
	//Posiciono o documento original para obter algumas informacoes
	//para montar o registro                                       
	If ( cEntSai == "E" .And. aCmpAntSFT[20] $ "01|05" ) .Or. ( cEntSai == "S" .And.!aCmpAntSFT[20] $ "01|05" ) //01-Devolucao|05-Beneficiamento
		
		//Caso nao encontre a Nota Referenciada o Registro nao sera gerado
		If !SF2->( MsSeek( xFilial( "SF2" ) + CDD->( CDD_DOCREF + CDD_SERREF + CDD_PARREF + CDD_LOJREF ) ) )
			lRet := .F.
		Else
			cIndEmit := Iif( SF2->F2_FORMUL == "N", "1", "0" )
			cIndOper := "1"
			cCodMod  := aModNot( SF2->F2_ESPECIE )
			cDtEmiss := DToS( SF2->F2_EMISSAO )
			
			If !SA1->(MsSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
				lRet := .F.
			Else
				cCodPar := TafPartic( "SA1" )[1]  //Retorna o Codigo do Participante
			EndIf
		Endif
	Else
		If !SF1->( MsSeek( xFilial( "SF1" ) + CDD->( CDD_DOCREF + CDD_SERREF + CDD_PARREF + CDD_LOJREF ) ) )
		
			//Nos casos de nota fiscal de remessa o array aCmpAntSFT[20] esta vazio,             
			//e o manual pede que seja gerado o registro C113, desta forma foi incluido          
			//o tratamento abaixo, onde caso a NF de origem nao seja encontrada na entrada       
			//(SF1) eh realizada uma busca nas saidas (SF2), em seguida busca-se na SA2          
			//as informacaoes do fornecedor, pois a nota de saida eh de remessa, ou seja,        
			//utiliza fornecedor ao inves de cliente.                                            
			If !SF2->( MsSeek( xFilial( "SF2" ) + CDD->( CDD_DOCREF + CDD_SERREF + CDD_PARREF + CDD_LOJREF ) ) )
				lRet := .F.
			Else
				cIndEmit := Iif( SF2->F2_FORMUL == "N", "1", "0" )
				cIndOper := "1"
				cCodMod  := aModNot( SF2->F2_ESPECIE )
				cDtEmiss := DToS( SF2->F2_EMISSAO )
				
				If !SA2->( MsSeek( xFilial( "SA2" ) + SF2->F2_CLIENTE + SF2->F2_LOJA) )
					lRet := .F.
				Else
					//Retorna o Codigo do Participante
					cCodPar := TafPartic( "SA2" )[1]  
				EndIf
			EndIf
		Else
			cIndEmit := Iif( SF1->F1_FORMUL == "S", "0", "1" )
			cIndOper := "0"
			cCodMod  := aModNot( SF1->F1_ESPECIE )
			cDtEmiss := DToS( SF1->F1_EMISSAO )
			
			If !SA2->(MsSeek( xFilial( "SA2" ) + SF1->F1_FORNECE + SF1->F1_LOJA ) )
				lRet := .F.
			Else
				//Retorna o Codigo do Participante
				cCodPar := TafPartic( "SA2" )[1]  
			EndIf
		EndIf
	EndIf
	
	//Tratamento para que caso o numero de Documento Fiscal de referencia                  
	//informado nao exista, ou o codigo do participante nao exista ( Cliente / Fornecedor )
	//nao seja gerado o registro,                                                          
	If lRet
		aRegs := {}
		CDD->( Aadd( aRegs, {  cReg,;
			cIndOper,;
			cCodPar,;
			cIndEmit,;
			"",;
			cCodMod,;
			CDD_SERREF,;
			CDD_DOCREF,;
			cDtEmiss } ) )
		
		FConcTxt( aRegs, nHdlTxt )
	EndIf
	
	CDD->( DbSkip() )
Enddo
	
Return ( Nil )

//-------------------------------------------------------------------

/*/{Protheus.doc} RegT013AH

Realiza a geracao do registro T013AH do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013
		aCmpAntSFT -> Array com as Informacoes da Nota Fiscal

@Return ( Nil )

@author Rodrigo Aguilar
@since  04/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AH( nHdlTxt, aCmpAntSFT, aParticip, lFltRnf013 )
	
Local cChvComp   := ""
Local cChaveCol  := ""
Local cChaveEnt  := ""
Local cCodCol    := ""
Local cCodEnt    := ""

Local cReg  := "T013AH"

Local aRegs := {}

Default aParticip := {}
Default lFltRnf013 := .F.

cChvComp := CDF->( CDF_FILIAL + CDF_TPMOV + CDF_DOC + CDF_SERIE + CDF_CLIFOR + CDF_LOJA )

//Busca as Informacoes complementares do Documento Fiscal
While CDF->( !Eof() ) .And. ( cChvComp == CDF->( CDF_FILIAL + CDF_TPMOV + CDF_DOC + CDF_SERIE + CDF_CLIFOR + CDF_LOJA ) )
	
	//Dados da Coleta  
	cChaveCol := CDF->( CDF_COLETA + CDF_LOJCOL )
	cChaveCol := Iif( Empty( cChaveCol ), aCmpAntSFT[3] + aCmpAntSFT[4], cChaveCol )
	cCodCol   := ""
	
	//Dados da Entrega
	cChaveEnt := CDF->( CDF_ENTREG + CDF_LOJENT )
	cChaveEnt := Iif( Empty( cChaveEnt ), aCmpAntSFT[3] + aCmpAntSFT[4], cChaveEnt )
	cCodEnt   := ""
	
	lRet := .T.
	
   	//Verifico se o Documento Fiscal eh de devolucao  / Beneficiamento
	If aCmpAntSFT[20] $ "DB"
		If SA2->( MsSeek( xFilial( "SA2" ) + cChaveCol ) )
			cCodCol := TafPartic( "SA2" )[1]

			IF lFltRnf013 
	 			RegT003Pos("SA2", @aParticip )
			EndIf	
		Else
			lRet := .F.
		EndIf
		
		If SA2->( MsSeek( xFilial( "SA2" ) + cChaveEnt ) )
			cCodEnt := TafPartic( "SA2" )[1]

			IF lFltRnf013 
	 			RegT003Pos("SA2", @aParticip )
			EndIf	
		Else
			lRet := .F.
		EndIf
	Else
		If SA1->( MsSeek( xFilial( "SA1" ) + cChaveCol ) )
			cCodCol := TafPartic( "SA1" )[1]

		   	IF lFltRnf013 
	 			RegT003Pos("SA1", @aParticip )
			EndIf	
		Else
			lRet := .F.
		EndIf
		
		If SA1->( MsSeek( xFilial( "SA1" ) + cChaveEnt ) )
			cCodEnt := TafPartic( "SA1" )[1]

			IF lFltRnf013 
	 			RegT003Pos("SA1", @aParticip )
			EndIf	
		Else
			lRet := .F.
		EndIf
	EndIf
	
	//Tratamento para que caso os codigos dos participantes de coleta / entrega
	//nao existam o registro nao seja gerado                                   
	If lRet
		aRegs := {}
		CDF-> ( Aadd( aRegs, {  cReg,;
			CDF_TPTRAN,;
			cCodCol,;
			cCodEnt } ) )
		
		FConcTxt( aRegs, nHdlTxt )
	EndIf
	
	CDF->(DbSkip())
Enddo
	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AI

Realiza a geracao do registro T013AI do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013
		aCmpAntSFT -> Array com as Informacoes da Nota Fiscal
		aParcTit   -> Informacoes das parcelas do Documento Fiscal
		cIndPgto   -> Indicador de Pagamento do Documento Fiscal

@Return ( Nil )

@author Rodrigo Aguilar
@since  04/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AI( nHdlTxt, aCmpAntSFT, aParcTit, cIndPgto )
	
Local cIndTit  := ""
Local cDescTit := ""

Local nVlTit := 0

Local cReg  := "T013AI"

Local aRegs := {}
Default cIndPgto := '0'
//Tratamento de verificacao da condicao de pagamento.
//Para pagamento a vista nao pode haver fatura       

//Retirado pois Exrator deve informar todos titulos dos    
//Documentos Fiscais. Tratamento deve ser utilizado no SPED	
nVlTit   := 0
cIndTit  := ""
cDescTit := ""

If cIndPgto <> '0' // só gera o registro se for pagamento a prazo 0 vista, 1=Prazo, 2 ou 9= Sem pagamento. Mesma regra condida na escrituração do C141 do SPEDFiscal
	//Obtendo o valor total dos titulos lancados para o documento, todas as parcelas
	aEval ( aParcTit, {|x| nVlTit += x[6] } )
	
	If( AllTrim( aParcTit[1][1] ) $ "BOL#DP#NF" )
		cIndTit := "00"
		
	ElseIf ( AllTrim( aParcTit[1][1] ) $ "CH" )
		cIndTit	:= "01"
		
	ElseIf ( AllTrim( aParcTit[1][1] ) $ "NP" )
		cIndTit := "02"
		
	ElseIf ( AllTrim( aParcTit[1][1]) $ "RC" )
		cIndTit := "03"
		
	Else
		cIndTit := "99"
		
		//A descricao somente deve existir para Titulos do Tipo 99
		If Empty( aParcTit[1][2] )
			cDescTit := "Titulo de Nota Fiscal"
			
		Else
			cDescTit := aParcTit[1][2]
			
		EndIf
	EndIf
	
	aRegs := {}
	Aadd( aRegs, {  cReg,;
		aCmpAntSFT[26],;
		cIndTit,;
		cDescTit,;
		aParcTit[1][3],;
		Alltrim( Str ( Len( aParcTit ) ) ),;
		Val2Str( nVlTit, 16, 2 ),;
		"00,00",;
		"00,00" } )
	
	FConcTxt( aRegs, nHdlTxt )
EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AJ

Realiza a geracao do registro T013AJ do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013
		aCmpAntSFT -> Array com as Informacoes da Nota Fiscal
		aParcTit   -> Informacoes das parcelas do Documento Fiscal
		cIndPgto   -> Indicador de Pagamento do Documento Fiscal

@Return ( Nil )

@author Rodrigo Aguilar
@since  04/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AJ( nHdlTxt, aParcTit, cIndPgto )
	
Local nX := 0

Local cReg  := "T013AJ"

Local aRegs := {}

//Tratamento de verificacao da condicao de pagamento.
//Para pagamento a vista nao pode haver fatura       

//Retirado pois Exrator deve informar todos titulos dos    
//Documentos Fiscais. Tratamento deve ser utilizado no SPED	
aParcTit :=	aSort ( aParcTit, , , {|x, y| x[4] < y[4] } )

For nX := 1 To Len( aParcTit )
	 
	aRegs := {}
	Aadd( aRegs, {  cReg,; 
		Alltrim( Str( nX ) ),;
		DToS( aParcTit[nX][5] ),;
		Val2Str( aParcTit[nX][6], 16, 2 ) } )
	
	FConcTxt( aRegs, nHdlTxt )
	
Next nX 
	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AM

Realiza a geracao do registro T013AM do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013
		aLanCDA    -> Informacoes de Documentos Fiscais da NF
		cEmissao   -> Data de Emissão do documento fiscal
		aInfoCompl -> Informações complementares da tabela CDA:
						[1] = nPos com o valor de relação com a tabela aLanCDA
						[2] = F4_TRFICM
						[3] = F4_ESTCRED
						[4] = D1_ESTCRED
		_cEntSai   -> Indica se a operação é de entrada ou saída		

@Return ( Nil )

@author Rodrigo Aguilar
@since  10/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AM( nHdlTxt, aLanCDA, cEmissao, aInfoCompl, _cEntSai )
	
Local nX 	  := 0
Local nPos  := 0
Local nPosAm	:= 0

Local cReg  := "T013AM"
Local cSubIt:= ""

Local aRet  := { '', '' }
Local aRegs := {}

For nX := 1 To Len( aLanCDA )
	
	If (nPosAm := aScan(aRegs,{|x| x[2]== aLanCDA[nX][01] .And. x[4]==aLanCDA[nX][13]}))==0
		//----------------------------------------------------------------------
		//Verifico se existe ajuste para o item da nota que está sendo processado
		//----------------------------------------------------------------------
		nPos := aScan( aInfoCompl, { |x| x[1] == nX } )	
		if nPos > 0
		
			//-----------------------------------------------------
			//Busco os códigos complementares do documento fiscal
			//-----------------------------------------------------			
			aRet := FSubItRegras(oFisaExtSx:_MV_ESTADO,aInfoCompl[nPos],_cEntSai)
		endif
		
		if !( empty( aRet[ 1 ] ) )
			cSubIt := aRet[ 1 ]
		elseif len( aLanCDA[ nX ] ) > 20
			cSubIt := aLanCDA[ nX , 21 ]
		endif
		
		//aRegs := {}
		Aadd( aRegs, {  cReg,;
						  aLanCDA[nX][01],;
						  aLanCDA[nX][02],;
						  aLanCDA[nX][13],;
						  Val2Str( aLanCDA[nX][03], 16, 2 ),;
						  Val2Str( aLanCDA[nX][04], 16, 2 ),;
						  Val2Str( aLanCDA[nX][05], 16, 2 ),;
						  Val2Str( aLanCDA[nX][06], 16, 2 ),;
						  cSubIt,;
						  aRet[2],;
						  cEmissao } )
	Else
			aRegs[nPosAm][5]	:= Val2Str(Val(aRegs[nPosAm][5]) + aLanCDA[nX][3],16,2)							
			aRegs[nPosAm][7]	:= Val2Str(Val(aRegs[nPosAm][5]) + aLanCDA[nX][5],16,2)							
			aRegs[nPosAm][8]	:= Val2Str(Val(aRegs[nPosAm][5]) + aLanCDA[nX][6],16,2)							
	EndiF			
Next nX
FConcTxt( aRegs, nHdlTxt )
	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AN

Realiza a geracao do registro T013AN do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013
cEspecie   -> Especie da Nota Fiscal
lAchouCD4  -> Indica se existe complemento de AGUA para o Documento Fiscal
aRegT013AN -> Araay com as informcaoes do complemento de Energia Eletrica / GAS


@Return ( Nil )

@author Rodrigo Aguilar
@since  10/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AN( nHdlTxt, cEspecie, lAchouCD4, aRegT013AN )
	
Local cGrpTens  := ""
Local cCodCons  := ""
Local cTpLiga   := ""

Local nVlTerc  	:= 0
Local nVlFornec	:= 0
Local nConskwh  := 0
Local nVlNTrib  := 0

Local nZ        := 1

Local cReg  := "T013AN"

Local aRegs := {}

CD3->( DbSetOrder( 1 ) )
CD4->( DbSetOrder( 1 ) )

//Tratamento para energia eletrica / Gas
If cEspecie $ "|06|28" .And. Len ( aRegT013AN ) > 0
	
	aRegT013AN :=	aSort ( aRegT013AN, , , { |x, y| ( x[3] < y[3] .And. x[5] < y[5] .And. x[4] < y[4] .And. x[1] < y[1] ) } )
	
	While nZ <= Len( aRegT013AN )
		
		nVlTerc    := 0
		nConskwh   := 0
		nVlNTrib   := 0
		
		cCodCons   := aRegT013AN[nZ][03]
		cGrpTens   := aRegT013AN[nZ][05]
		cTpLiga    := aRegT013AN[nZ][04]
		
		//Como no Protheus o complemento eh por item de nota fiscal e no TAF   
		//este complemento eh por documento fiscal precisamos realizar a soma  
		//dos valores quebrando pelos codigos, o valor de servico nao tributado
		//eh armazenado no array aRegT013AN previamente.                       
		While ( cCodCons + cGrpTens + cTpLiga ) == ( aRegT013AN[nZ][03] + aRegT013AN[nZ][05] + aRegT013AN[nZ][04] )
			
			nVlTerc    += aRegT013AN[nZ][06]
			nConskwh   += aRegT013AN[nZ][07]
			nVlFornec  += aRegT013AN[nZ][08]
			nVlNTrib   += aRegT013AN[nZ][02]
			
			nZ++
			
			If nZ > Len ( aRegT013AN )
				Exit
			EndIf
		EndDo
		
		aRegs := {}
		Aadd( aRegs, {  cReg,;
			cCodCons,;
			cTpLiga,;
			cGrpTens,;
			Val2Str( nVlTerc, 16, 2 ),;
			Val2Str( nConskwh, 16, 2 ),;
			Val2Str( nVlNTrib, 16, 2 ),;
			Val2Str( nVlFornec, 16, 2 ) } )
		
		FConcTxt( aRegs, nHdlTxt )
		
	EndDo
	
	//Tratamento para Agua canalizada
ElseIf cEspecie == "29" .And. lAchouCD4
	
	cChvComp := CD4->( CD4_FILIAL + CD4_TPMOV + CD4_SERIE + CD4_DOC + CD4_CLIFOR + CD4_LOJA )
	
	While CD4->( !Eof() ) .And. ( cChvComp == CD4->( CD4_FILIAL + CD4_TPMOV + CD4_SERIE + CD4_DOC + CD4_CLIFOR + CD4_LOJA ) )
		
		//Informacoes nao existem para Complemento de Gas		
		cTpLiga    := ""
		cGrpTens   := ""
		
		nVlTerc    := 0
		nConskwh   := 0
		nVlNTrib   := 0
		
		cCodCons := CD4->CD4_CLASCO
		
		While CD4->( !Eof() ) .And. ( cChvComp == CD4->( CD4_FILIAL + CD4_TPMOV + CD4_SERIE + CD4_DOC + CD4_CLIFOR + CD4_LOJA ) ) .And. ;
				cCodCons  == CD4->CD4_CLASCO
			
			nVlTerc  += CD4->CD4_VLTERC
			
			//Buscando o Valor Nao Tributado
			For nZ := 1 To Len( aRegT013AN )
				If CD4->CD4_ITEM == aRegT013AN[nZ][01]
					nVlNTrib += aRegT013AN[nZ][02]
					Exit
				EndIf
			Next
			
			CD4->( DbSkip() )
		EndDo
		
		aRegs := {}
		Aadd( aRegs, {  cReg,;
			cCodCons,;
			cTpLiga,;
			cGrpTens,;
			Val2Str( nVlTerc, 16, 2 ),;
			Val2Str( nConskwh, 16, 2 ),;
			Val2Str( nVlNTrib, 16, 2 ),;
			Val2Str( nVlFornec, 16, 2 ) } )
		
		FConcTxt( aRegs, nHdlTxt )
	EndDo
EndIf
	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AO

Realiza a geracao do registro T013AO do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013
		lAchouDA3  -> Indica se existe informacao na Tabela DA3
		lAchouDT8  -> Indica se encontrou informacao na tabela DT8
		aPartREM   -> Dados do Participante Remetente
		aPartDES   -> Dados do Participante destinatario
		aPartCON   -> Dados do Participante Consignatario
		aPartDPC   -> Dados do Participante Despachante

@Return ( Nil )

@author Rodrigo Aguilar
@since  11/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AO( nHdlTxt, lAchouDA3, lAchouDT8, aPartREM, aPartDes, aPartCON, aPartDPC )
	
Local cCdMunOri   := ""
Local cEstOri     := ""
Local cCdMunDes   := ""
Local cEstDes     := ""
Local cCdPartCons := ""
Local cCdParRed   := ""

Local cDT8Chv     := ""

Local nVlFrete    := 0
Local nVlFrtLiq   := 0
Local nVlSecCat   := 0
Local nVlDesp     := 0
Local nVlPed      := 0
Local nVlOutros   := 0
Local nVlGris     := 0

Local cMvCompFrt  := oFisaExtSx:_MV_COMPFRT

Local aMvCompFrt  := Iif( Len( &( cMvCompFrt ) ) <> 4 , {}, &( cMvCompFrt ) )

Local cReg      := "T013AO"

//Quando lAchouDT8 estiver verdadeiro, significa que encontrou  o registro
//para o conhecimento em questao e que a tabela esta posicionada no      
//primeiro registro.                                                     
If lAchouDT8
	
	If Len( aPartREM ) > 0
		cEstOri := aPartREM[ 02 ]
		If Upper( cEstOri ) == "EX"
			 // Preencher desta forma conforme manda o LAYOUT TAF
			cCdMunOri := "99999"
		Else
			//Municipio de origem
			cCdMunOri := aPartREM[3]
		EndIf
	EndIf
	
	If Len( aPartDes ) > 0
		cEstDes := aPartDes[ 02 ]
		If Upper( cEstDes ) == "EX"
			//Preencher desta forma conforme manda o LAYOUT TAF
			cCdMunDes := "99999" 
		Else
			//Municipio de Destino
			cCdMunDes := aPartDES[3]
		EndIf
	EndIf
	
	If Len( aPartCON ) > 0
		cCdPartCons := aPartCON[ 01 ]
	EndIf
	
	If Len( aPartDPC ) > 0
		cCdParRed   := aPartDPC[ 01 ]
	EndIf
	
	cDT8Chv := DT8->( DT8_FILIAL + DT8_FILDOC + DT8_DOC + DT8_SERIE )
	
	Do While DT8->( !Eof () ) .And. ( DT8->( DT8_FILIAL + DT8_FILDOC + DT8_DOC + DT8_SERIE ) == cDT8Chv )
		
		If oFisaExtSx:_MV_DATCIAP .And. Empty( aMvCompFrt[1] ) .And. Empty( aMvCompFrt[2] ) .And. ;
				Empty( aMvCompFrt[3] ) .And. Empty( aMvCompFrt[4] )
			
			//Valor Total do frete
			If DT8->DT8_CODPAS $ "TF"
				nVlFrete	+=	DT8->DT8_VALTOT
				
			ElseIf SpedSeek( "DT3", 1, xFilial( "DT3" ) + DT8->DT8_CODPAS )
				
				//Valor do frete por peso/volume
				If DT3->DT3_TIPCMP == "1"
					nVlFrtLiq	+=	DT8->DT8_VALTOT
					
					//Valores do SEC/CAT
				ElseIf DT3->DT3_TIPCMP == "2"
					nVlSecCat	+=	DT8->DT8_VALTOT
					
					//Valores de despacho
				ElseIf DT3->DT3_TIPCMP == "3"
					nVlDesp	+=	DT8->DT8_VALTOT
					
					//Valores de pedagio
				ElseIf DT3->DT3_TIPCMP == "4"
					nVlPed	+=	DT8->DT8_VALTOT
					
					//Outros valores
				Else
					nVlOutros	+=	DT8->DT8_VALTOT
				EndIf
				
				//Outros valores
			Else
				nVlOutros += DT8->DT8_VALTOT
			EndIf
			
		ElseIf Len( aMvCompFrt ) == 4
			
			//Valor Total do frete
			If DT8->DT8_CODPAS $ "TF"
				nVlFrete	+=	DT8->DT8_VALTOT
				
				//Valor do frete por peso/volume
			ElseIf DT8->DT8_CODPAS $ aMvCompFrt[1]
				nVlFrtLiq	+=	DT8->DT8_VALTOT
				
				//Valores do SEC/CAT
			ElseIf DT8->DT8_CODPAS$aMvCompFrt[2]
				nVlSecCat	+=	DT8->DT8_VALTOT
				
				//Valores de despacho
			ElseIf DT8->DT8_CODPAS$aMvCompFrt[3]
				nVlDesp	+=	DT8->DT8_VALTOT
				
				//Valores de pedagio
			ElseIf DT8->DT8_CODPAS$aMvCompFrt[4]
				nVlPed	+=	DT8->DT8_VALTOT
				
				//Outros valores
			Else
				nVlOutros	+=	DT8->DT8_VALTOT
			EndIf
			
			//Valor Total do Frete
		ElseIf DT8->DT8_CODPAS$"TF"
			nVlFrete	+=	DT8->DT8_VALTOT
			
			//Outros valores
		Else
			nVlOutros	+=	DT8->DT8_VALTOT
		EndIf
		
		DT8->(DbSkip ())
	EndDo
	
	//Buscando o valor do campo Indicador de Tipo de Frete
	cIndFrt := 	DT6->DT6_TIPFRE
	If	nVlFrtLiq == 0
		cIndFrt := "9"
	EndIf
	
EndIf

aRegs := {}
Aadd( aRegs, {  cReg,;
	cEstOri,;
	cCdMunOri,;
	cEstDes,;
	cCdMunDes,;
	Iif( lAchouDA3, SubStr( StrTran( DA3->DA3_COD, "-" , "" ) , 1, 7 ) ,"" ),;
	cCdPartCons,;
	cCdParRed,;
	cIndFrt,;
	nVlFrtLiq,;
	nVlSecCat,;
	nVlDesp,;
	nVlPed,;
	nVlOutros,;
	nVlFrete,;
	nVlGris,;
	"" } )

FConcTxt( aRegs, nHdlTxt )
	
Return ( Nil )

/*/{Protheus.doc} RegT013AQ
Realiza a geracao do registro T013AQ do TAF

@author Rodrigo Aguilar
@since  15/04/2013

@obs Nesta Funcao ja estamos posicionados na tabela de complemento da NF, assim podemos utilizar o Alias diretamente

@param nHdlTxt, numerico, Handle de Gravacao do Registro T013
@param cEspecie, caracter, Especie da Nota Fiscal
@param cPartRem, caracter, Codigo do Participante Remetente
@param cPartDes, caracter, Codigo do Participante destinatario
@param cPartCol, caracter, Codigo do Participante Remetente
@param cPartEnt, caracter, Codigo do Participante destinatario

@return nulo, não tem retorno.
/*/
Function RegT013AQ(nHdlTxt,cEspecie,cPartRem,cPartDes,cPartCol,cPartEnt)
	
	Local cIndCg   := ""
	
	Local aT013AQ := {}
	
	Default nHdlTxt := 0
	
	Default cEspecie := ""
	Default cPartRem := ""
	Default cPartDes := ""
	Default cPartCol := ""
	Default cPartEnt := ""
	
	If !Empty(cPartCol) .Or. !Empty(cPartEnt)
		/*
			Montagem do indicador do tipo de carga.
			0 = Rodoviario;                          
			1 = Ferroviario                          
			2 = Rodo-ferroviario                     
			3 = Aquaviario                           
			4 = Dutoviario                           
			5 = Aereo                                
			9 = Outros
		*/
		If cEspecie == "11"
			cIndCg := "1"
		ElseIf cEspecie == "09"
			cIndCg := "2"
		ElseIf cEspecie == "10"
			cIndCg := "4"
		ElseIf cEspecie == "26"
			cIndCg := "9"
		Else
			cIndCg := "0"
		EndIf
	EndIf
	
	aRegs := {}
	Aadd(aT013AQ,{})
	nPosicao := Len(aT013AQ)
	
	Aadd(aT013AQ[nPosicao],"T013AQ")	// 01 - REGISTRO
	Aadd(aT013AQ[nPosicao],"")			// 02 - DESPACHO
	Aadd(aT013AQ[nPosicao],cPartRem)	// 03 - COD_PART_REM
	Aadd(aT013AQ[nPosicao],cPartDes)	// 04 - COD_PART_DEST
	Aadd(aT013AQ[nPosicao],cIndCg)		// 05 - IND_CARGA
	Aadd(aT013AQ[nPosicao],cPartCol)	// 06 - COD_PART_COL
	Aadd(aT013AQ[nPosicao],cPartEnt)	// 07 - COD_PART_ENTG
	
	
	FConcTxt(aT013AQ,nHdlTxt)
	
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AR

Realiza a geracao do registro T013AR do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013
		aCmpAntSFT -> Array com informacoes da NF

@Return ( Nil )

@author Rodrigo Aguilar
@since  15/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AR( nHdlTxt, aCmpAntSFT  )
	
Local cChvComp := ""

Local cReg  := "T013AR"

Local aRegs := {}

cChvComp := SFX->( FX_FILIAL + FX_TIPOMOV + FX_SERIE + FX_DOC + FX_CLIFOR + FX_LOJA )

While SFX->( !Eof() ) .And. cChvComp == SFX->( FX_FILIAL + FX_TIPOMOV + FX_SERIE + FX_DOC + FX_CLIFOR + FX_LOJA )
	
	aRegs := {}
	Aadd( aRegs, {  cReg,;
		SFX->FX_TIPSERV,;
		DToS( SFX->FX_DTINI ),;
		DToS( SFX->FX_DTFIM ),;
		SFX->FX_PERFIS,;
		SFX->FX_AREATER,;
		SFX->FX_TERMINA,;
		Iif(oFisaExtSx:_FX_TPASSIN,SFX->FX_TPASSIN,""),;
		SFX->FX_TIPOREC,;
		Val2Str( SFX->FX_VALTERC, 16, 2 ),;
		Val2Str( aCmpAntSFT[48], 16, 2 ),;
		Val2Str( 0, 16, 2 ),;
		SFX->FX_CLASCON } )
	
	FConcTxt( aRegs, nHdlTxt )
	
	SFX->(DbSkip())
	
EndDo
	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AT

Realiza a geracao do registro T013AT do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013
		aCmpAntSFT -> Array com informacoes da NF

@Return ( Nil )

@author Rodrigo Aguilar
@since  15/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AT( nHdlTxt, aCmpAntSFT  )
	
Local cReg  := "T013AT"

Local aRegs := {}

aRegs := {}
Aadd( aRegs, {  cReg,;
	aCmpAntSFT[ 01 ] } )

FConcTxt( aRegs, nHdlTxt )
	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AU

Realiza a geracao do registro T013AU do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013
		aPartREM   -> Dados dos Participante de Origem
		aPartDes   -> Dados do Participante de Destino
		aPartCON   -> Dados do Participante Consignatario
		lAchouDA3  -> Indica se encontrou Informacoes na DA3
		lAchouDT8  -> Indica se encontrou Informacoes na DT8
		lAchouDUD  -> Indica se encontrou Informacoes na DUD

@Return ( Nil )

@author Rodrigo Aguilar
@since  15/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AU( nHdlTxt, aPartREM, aPartDes, aPartCON, lAchouDA3, lAchouDT8, lAchouDUD )
	
Local cReg     := "T013AU"
Local cDT8Chv  := ""

Local nVlFrete  := 0
Local nVlOut    := 0

Local aRegs := {}

Default aPartREM := {}
Default aPartDes := {}
Default aPartCON := {}

//Quando lAchouDT8 estiver verdadeiro, significa que encontrou  o registro
//para o conhecimento em questao e que a tabela esta posicionada no      
//primeiro registro.                                                                                                                             
//NAO PRECISO DE TRATAMENTO DE TOP OU DBF PORQUE O TMS EH SOH AMBIENTE TOP
If lAchouDT8
	
	cDT8Chv := DT8->( DT8_FILIAL + DT8_FILDOC + DT8_DOC + DT8_SERIE )
	
	Do While DT8->( !Eof() ) .And. ( DT8->( DT8_FILIAL + DT8_FILDOC + DT8_DOC + DT8_SERIE ) == cDT8Chv )
		
		If DT8->DT8_CODPAS $ "TF"
			nVlFrete +=	DT8->DT8_VALTOT
		Else
			nVlOut += DT8->DT8_VALTOT
		EndIf
		
		DT8->(DbSkip ())
	EndDo
	
EndIf

Aadd( aRegs, {  cReg,;
	Iif( Len( aPartREM ) > 0, aPartREM[ 02 ], "" ),;
	Iif( Len( aPartREM ) > 0, aPartRem[ 03 ], "" ),;
	Iif( Len( aPartDes ) > 0, aPartDes[ 02 ], "" ),;
	Iif( Len( aPartDes ) > 0, aPartDes[ 03 ], "" ),;
	Iif ( lAchouDA3, SubStr( StrTran( DA3->DA3_COD, "-", "" ), 1, 7 ), "" ),;
	Iif( Empty( aPartCON ) , "", aPartCon[ 01 ] ),;
	Val2Str( 0, 16, 2 ),;
	Val2Str( nVlOut, 16, 2 ),;
	Iif ( lAchouDUD, DUD->DUD_VIAGEM, "" ),;
	Val2Str( 0, 16, 2 ),;
	Val2Str( 0, 16, 2 ),;
	Val2Str( nVlFrete, 16, 2 ),;
	Val2Str( 0, 16, 2 ) } )

FConcTxt( aRegs, nHdlTxt )
	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AV

Realiza a geracao do registro T013AV do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013
		aPartREM   -> Dados dos Participante de Origem
		aPartDes   -> Dados do Participante de Destino
		lAchouDA3  -> Indica se encontrou Informacoes na DA3
		lAchouDT8  -> Indica se encontrou Informacoes na DT8
		lAchouDUD  -> Indica se encontrou Informacoes na DUD

@Return ( Nil )

@author Rodrigo Aguilar
@since  15/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AV( nHdlTxt, aPartREM, aPartDes, lAchouDA3, lAchouDT8, lAchouDUD )
	
Local cReg     := "T013AV"
Local cDT8Chv  := ""

Local nVlPeso  := 0
Local nVlOut    := 0

Local aRegs := {}

Default aPartREM := {}
Default aPartDes := {}

//Quando lAchouDT8 estiver verdadeiro, significa que encontrou  o registro
//para o conhecimento em questao e que a tabela esta posicionada no      
//primeiro registro.                                                                                                                             
//NAO PRECISO DE TRATAMENTO DE TOP OU DBF PORQUE O TMS EH SOH AMBIENTE TOP
If lAchouDT8
	
	cDT8Chv := DT8->( DT8_FILIAL + DT8_FILDOC + DT8_DOC + DT8_SERIE )
	
	Do While DT8->( !Eof() ) .And. ( DT8->( DT8_FILIAL + DT8_FILDOC + DT8_DOC + DT8_SERIE ) == cDT8Chv )
		
		If DT8->DT8_CODPAS $ "TF"
			nVlPeso +=	DT8->DT8_VALTOT
		Else
			nVlOut += DT8->DT8_VALTOT
		EndIf
		
		DT8->(DbSkip ())
	EndDo
	
EndIf

Aadd( aRegs, {  cReg,;
	Iif( Len( aPartREM ) > 0, aPartREM[ 02 ], "" ),;
	Iif( Len( aPartREM ) > 0, aPartREM[ 03 ], "" ),;
	Iif( Len( aPartDes ) > 0, aPartDes[ 02 ], "" ),;
	Iif( Len( aPartDes ) > 0, aPartDes[ 03 ], "" ),;
	Iif ( lAchouDA3, SubStr( StrTran( DA3->DA3_COD, "-", "" ), 1, 7 ), "" ),;
	Iif ( lAchouDUD, DUD->DUD_VIAGEM, "" ),;
	"0",;
	Val2Str( nVlPeso, 16, 2 ),;
	Val2Str( 0, 16, 2 ),;
	Val2Str( 0, 16, 2 ),;
	Val2Str( nVlOut, 16, 2 ),;
	Val2Str( 0, 16, 2 ) } )

FConcTxt( aRegs, nHdlTxt )
	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AX

Realiza a geracao do registro T013AX do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013

@Return ( Nil )

@author Henrique Pereira
@since  02/08/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AX( nHdlTxt )
	
Local cChvComp     := ""

Local cReg         := "T013AX"

Local aRegs        := {}

Local aGetCDG		:= CDG->(GetArea())

cChvComp := CDG->( CDG_FILIAL + CDG_TPMOV + CDG_DOC + CDG_SERIE + CDG_CLIFOR + CDG_LOJA )

//Busca as Informacoes complementares do Documento Fiscal
While CDG->( !Eof() ) .And. ( cChvComp == CDG->( CDG_FILIAL + CDG_TPMOV + CDG_DOC + CDG_SERIE + CDG_CLIFOR + CDG_LOJA )  )
	
	aRegs := {}
	CDG->( Aadd( aRegs, {  cReg,;
		CDG_PROCES,;
		CDG_TPPROC } ) )
	
	FConcTxt( aRegs, nHdlTxt )
	
	CDG->(DbSkip())
Enddo

Restarea(aGetCDG)

Return ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} RegT013AV

Realiza a geracao do registro T013AV do TAF

Nesta Funcao ja estamos posicionados na tabela de complemento
da NF, assim podemos utilizar o Alias diretamente

@Param nHdlTxt    -> Handle de Gravacao do Registro T013

@Return ( Nil )

@author Rodrigo Aguilar
@since  15/04/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegT013AW( nHdlTxt )
	
Local cDTCChv  := ""
Local cReg     := "T013AW"

Local nPos  := 0
Local nPos2 := 0

Local aRegs := {}

//Para este registro foi necessario utilizar o aScan, pois a chave de busca    
//dos registros nao respeita o Indice utilizado na busca das informacoes, sendo
//assim a unica eh forma de controlar a soma dos valores por Nota Fiscal eh    
//utilizando array                                                             
cDTCChv := DTC->( DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE )

While DTC->( !Eof() ) .And. ( cDTCChv == DTC->( DTC_FILIAL + DTC_FILDOC + DTC_DOC + DTC_SERIE ) )
	
	If ( nPos := aScan( aRegs,{ |aX| aX[3] == DTC->DTC_SERNFC .And. aX[4] == DTC->DTC_NUMNFC } ) ) == 0
		
		aAdd ( aRegs, {} )
		nPos := Len( aRegs )
		aAdd ( aRegs[ nPos ], {} )
		nPos2 := Len( aRegs[ nPos ] )
		
		aAdd( aRegs[ nPos, nPos2 ], cReg )
		aAdd( aRegs[ nPos, nPos2 ], "01" )
		aAdd( aRegs[ nPos, nPos2 ], DTC->DTC_SERNFC )
		aAdd( aRegs[ nPos, nPos2 ], DTC->DTC_NUMNFC )
		aAdd( aRegs[ nPos, nPos2 ], DToS( DTC->DTC_EMINFC ) )
		aAdd( aRegs[ nPos, nPos2 ], DTC->DTC_VALOR )
		aAdd( aRegs[ nPos, nPos2 ], DTC->DTC_VALOR )
		aAdd( aRegs[ nPos, nPos2 ], DTC->DTC_QTDVOL )
		aAdd( aRegs[ nPos, nPos2 ], DTC->DTC_PESO )
		aAdd( aRegs[ nPos, nPos2 ], DTC->DTC_PESO )
	Else
		aRegs[ nPos, nPos2 , 06 ] += DTC->DTC_VALOR
		aRegs[ nPos, nPos2 , 07 ] += DTC->DTC_VALOR
		aRegs[ nPos, nPos2 , 08 ] += DTC->DTC_QTDVOL
		aRegs[ nPos, nPos2 , 09 ] += DTC->DTC_PESO
		aRegs[ nPos, nPos2 , 10 ] += DTC->DTC_PESO
	EndIf
	
	DTC->( DbSkip() )
EndDo

For nPos := 1 To Len ( aRegs )
	FConcTxt( aRegs[ nPos ], nHdlTxt )
Next
	
Return ( Nil )
