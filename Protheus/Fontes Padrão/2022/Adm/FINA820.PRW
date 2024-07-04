#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "FINA820.ch"
#Include "Fileio.ch"

Static __lIsBlind	:= IsBlind()
Static __cArq		:= ""
Static __cDir		:= ""
Static __cCpf		:= ""
Static __cTmpFVV	:= ""
Static __cTmpFVG	:= ""
Static __cTmpCVB	:= ""
Static __cFilOri	:= ""
Static __cFlAntOd	:= ""
Static __cFVUCod	:= ""
Static __nTamFlA6	:= 0
Static __nPropBx	:= 1
Static __nVlFun		:= 0
Static __nVlNota	:= 0
Static __nTxMoeda	:= 0
Static __lF820Qry	:= .F.
Static __lF820Reg	:= .F.
Static __lF820Bco	:= .F.
Static __lImpHist	:= .F.
Static __lFunrural	:= .F.
Static __lPrinted	:= .F.
Static __lNftot		:= .F.
Static __lLibChq
Static __oTmpFil
Static __oTmpFVIG
Static __oTmpBco
Static __oTSlCred
Static __oCredRec
Static __oCredPag
Static __nFilSE5
Static __nFilSE1
Static __nFilSE2
Static __nFilSF1
Static __nFilSF2
Static __nAbtNF
Static __nDecs
Static __nLOEmp
Static __nLOUnN
Static __nLOFil
Static __cTamSE5
Static __cTamSEF
Static __oTmpChCP
Static __oTmpChCR
Static __cDBName
Static __aTpReg
Static __aOtimF1
Static __aOtimF2
Static __cLCDPRPA
Static __cLCDPRRA
Static __lCsv
Static _lCpos1
Static _lCpos2
Static _lMtCpos1
Static _lMtCpos2

#DEFINE DEC   		"LCDPR"
#DEFINE EXT   		"txt"
#DEFINE TPDOCNF		"1"
#DEFINE TPDOCFT		"2"
#DEFINE TPDOCRC		"3"
#DEFINE TPDOCCT		"4"
#DEFINE TPDOCFP		"5"
#DEFINE TPDOCOU		"6"
#DEFINE BL0000		"0000"
#DEFINE BL0010		"0010"
#DEFINE BL0030		"0030"
#DEFINE BL0040		"0040"
#DEFINE BL0045		"0045"
#DEFINE BL0050		"0050"
#DEFINE BLQ100		"Q100"
#DEFINE BLQ200		"Q200"
#DEFINE BL9999		"9999"
#DEFINE Dv			"|"
#DEFINE ENTER		Chr(13) + Chr(10)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} LCDPR

Extrator do Livro Caixa Digital do Produtor Rural

@sample	LCDPR
@return		
@author		Rodrigo Oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Function FINA820(aParamIni As Array, aSelFil As Array, aBancos As Array, aContador As Array, aDtPeriodo As Array, aDevolNF As Array)
	Local lGerado	As Logical
	Local lWzd		As Logical
	Local lDevolNF	As Logical
	Local aRetTela	As Array
	Local cArquivo	As Character

	Default aParamIni	:= {}
	Default aSelFil		:= {}
	Default aBancos		:= {}
	Default aContador	:= {}
	Default aDtPeriodo	:= {}
	Default aDevolNF	:= {'2'}
 	
 	lGerado		:= .F.
	lWzd		:= .F.
	lDevolNF	:= aDevolNF[1] == '1'
	aRetTela	:= {}
	cArquivo 	:= ''
	__cDBName	:= Alltrim(Upper(TCGetDB()))
	__cLCDPRPA	:= SUPERGETMV("MV_LCDPRPA",,"C")
	__cLCDPRRA	:= SUPERGETMV("MV_LCDPRRA",,"C")
	
	/*------------------------------------------|
	|	Estruturas dos aArrays:					|
	|				         					|
	|	a-) aParamIni:         					|
	|	[1] - Cód. da versão do leiaute			|
	|	[2] - Cpf do declarante					|
	|	[3] - Reservado p/ o nome do declarante |
	|	[4] - Indicador do início do período	|
	|		0 - Regular         				|
	|		1 - Abertura         				|
	|		2 - Início da obrigatoriedade		|
	|	[5] - Indicador de Sit. Especial		|
	|		0 - Normal          				|
	|		1 - Falecimento      				|
	|		2 - Espólio                  		|
	|		3 - Sapida definitiva do País		|
	|	[6] - Data da situação especial			|
	|	[7] - Data do início do período			|
	|	[8] - Data Final do período				|
	|	[9] - Forma de apuração    				|
	|		1 - Livro Caixa     				|
	|		2 - Apuração Lucro p/ Lei 8023/90	|
	|	[10] - Diretório de gravação do arquivo	|
	|	[11] - Nome do arquivo					|
	|	[12] - Opção para geração do CSV		|
	|					         				|
	|	b-) aSelFil:           					|
	|	[1] - Cód. da Filial (9901)				|
	|					         				|
	|	c-) aBancos:	  	       				|
	|	[1] - Cód. do Banco                  	|
	|	[2] - Agência                 			|
	|	[3] - Núm. da Conta          			|
	|	[4] - Díg. verificador da conta			|
	|	[5] - Filial                  			|
	|	[6] - País                   			|
	|	[7] - Cód. Banco no BACEN  				|
	|					         				|
	|	d-) aContador:  	       				|
	|	[1] - Cód. da Filial do contador (9901)	|
	|	[2] - Código do contador (CVB)			|
	|					         				|
	|	e-) aDtPeriodo:  	       				|
	|	[1] - 1- Dt da baixa; 2- Dt Credito		|
	|				         					|
	|	f-) lDevolNF:	  	       				|
	|	[1] - 1- Considera; 2- Não Considera	|
	|------------------------------------------*/

	If TemLCDPR()

		If Empty(aParamIni)

			If !GetHlpLGPD({'FVU_NOME','FVU_CNPJ','A6_COD', 'A6_AGENCIA', 'A6_NUMCON'})
				aRetTela := FINA820A()
			EndIf

			If Len(aRetTela[1]) > 0
				If !aRetTela[6]
					aParamIni	:= aRetTela[1]
					aSelFil		:= aRetTela[2]
					aBancos		:= aRetTela[3]
					aContador	:= aRetTela[4]
					aDtPeriodo	:= aRetTela[5]
					__lCsv		:= Iif(Len(aRetTela[1]) > 11 .And. ValType(aRetTela[1][12]) == 'L', aRetTela[1][12], .F.)
					lDevolNF	:= aRetTela[7]
				EndIf
			EndIf
			lWzd	:= .T.

		EndIf
		
		If ( !Empty(aParamIni) .And. !Empty(aSelFil) .And. !Empty(aBancos) .And. !Empty(aContador) .And. !Empty(aDtPeriodo) )
			__cCpf		:= AllTrim(aParamIni[2])
			Processa({|| lGerado := GeraArq(aParamIni, aSelFil, aBancos, aContador, aDtPeriodo[1], lDevolNF)})
			
			If !__lIsBlind .And. lGerado
				MsgInfo( STR0015 + Lower(__cDir + __cArq) + "." + EXT, STR0016 ) // "Arquivo gerado com sucesso: "
			EndIf
			If lGerado
				cArquivo := Lower(__cDir + __cArq) + "." + EXT
			EndIf
		ElseIf !lWzd .Or. ( lWzd .And. Len(aRetTela) > 0 .And. !aRetTela[6] ) 
			Help(' ',1, STR0012,, STR0013 + ENTER + STR0014,2,0,,,,,,) // "LCDPR NÃO GERADO." ## "Verifique os parâmetros selecionados" ## "e repita o processo para a correta geração. "		
		EndIf
	EndIf
	ZeraStatic()
	
Return ({ lGerado , cArquivo }) 

//------------------------------------------------------------------------------
/*/	{Protheus.doc} GeraArq

Gera arquivo TXT com base nos parâmetros passados

@sample	GeraArq

@param aParamIni	= Parâmetros iniciais do wizard da rotina LCDPR
@param aSelFil		= Filiais / Imóveis selecionados
@param aContador	= Filial e código do contador responsável pela declaração

@return	lRet	= retorna .T. caso o arquivo seja gerado corretamente
		
@author		Rodrigo Oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function GeraArq(aParamIni As Array, aSelFil As Array, aBancos As Array, ;
 						aContador As Array, cDtPeriodo As Character, lDevolNF As Logical) As Logical
	Local lRet		As Logical
	Local lRegValid As Logical
	Local lE5Cgc	As Logical
	Local lVlLiqR	As Logical
	Local lVlLiqP	As Logical
	Local lNaoInt	As Logical
	Local lTipoVa	As Logical
	Local lMercosul As Logical
	Local lPJNRural	As Logical
	Local nHdl		As Numeric
	Local nI		As Numeric
	Local nQtdLin	As Numeric
	Local cTipo		As Character
	Local cConta	As Character
	Local cImov		As Character
	Local cFiliais	As Character
	Local cNatSld	As Character
	Local cTpPartic	As Character
	Local cMes		As Character
	Local cOldMes	As Character
	Local cNumDoc	As Character
	Local cPict		As Character
	Local cPictR	As Character
	Local cLinha	As Character
	Local cLinAux	As Character
	Local cLin200	As Character
	Local cUniao	As Character
	Local cMunic	As Character
	Local cSecEst	As Character
	Local cHist		As Character
	Local cCnpj		As Character
	Local cPais		As Character
	Local cMoeda	As Character
	Local cIE		As Character
	Local cMoedAux	As Character
	Local cAntFil	As Character
	Local cBanco	As Character
	Local cCxFin	As Character
	Local cRotOri	As Character
	Local cFilOri	As Character
	Local cHistC	As Character
	Local cHistNF	As Character
	Local cSaldoR   As Character
	Local cSaldoP   As Character
	Local cSld200	As Character
	Local cValor    As Character
	Local cSaldo    As Character
	Local cVlFun    As Character
	Local cCodBco 	As Character
	Local cDecParc	As Character
	Local cDtCheq	As Character
	Local cTpCmp	As Character
	Local cVlAcCmp	As Character
	Local nVlAcCmp	As Numeric	
	Local nValCorr 	As Numeric
	Local nValNF 	As Numeric
	Local nVlNFE1	As Numeric
	Local nVlNFE2	As Numeric
	Local nValor	As Numeric
	Local nTamFil	As Numeric
	Local nSaldo	As Numeric
	Local nSld200	As Numeric
	Local nSaldoR	As Numeric
	Local nSaldoP	As Numeric
	Local nTamSx3	As Numeric
	Local nProp		As Numeric
	Local nCaso		As Numeric
	Local nCount	As Numeric
	Local nAbat		As Numeric
	Local nAbtTotal As Numeric
	Local nTamTitR 	As Numeric
	Local nTamTitP 	As Numeric
	Local nVlCruz	As Numeric
	Local nTamPart  As Numeric
	Local nDecPart	As Numeric
	Local nTxMTit 	As Numeric
	Local aStruFil	As Array
	Local aStruBco	As Array
	Local aTpReg	As Array
	Local aFXV		As Array
	Local aFVVAux	As Array
	Local aAuxSE	As Array
	Local aCli		As Array
	Local aAuxCx	As Array
	Local aCxFin	As Array
	Local aAuxFVG	As Array
	Local aBcoPrt	As Array

	Local lDecPrinc As Logical
	Local lDecPrin  As Logical
	Local lTemBcOfi As Logical
	Local lAchou	As Logical
	Local lTemCompl As Logical
	Local lSldBxCR	As Logical
	Local lDespCmpA	As Logical
	Local lDespCmpD	As Logical
	Local lNDevol	As Logical
	Local aAuxDec   As Array
	Local aAux1 	As Array
	Local aAux2 	As Array
	
	PRIVATE oTRB100
	
	lRet		:= .F.
	lAchou		:= .F.
	lTemBcOfi	:= .F.
	lRegValid	:= .T.
	lNaoInt		:= .F.
	lTipoVa		:= .F.
	lMercosul   := .F.
	lSldBxCR	:= SuperGetMV("MV_SLDBXCR",,'B') == "C"
	lVlLiqR		:= SuperGetMV("MV_BQ10925",.F.,"1") == "2"
	lVlLiqP		:= SuperGetMV("MV_BP10925",.F.,"1") == "2"
	lE5Cgc		:= SE5->(ColumnPos('E5_CGC') ) > 0
	nHdl		:= 0
	nI			:= 0
	nCount		:= 0
	nQtdLin		:= 3
	nTxMTit		:= 1
	nTamTitR	:= TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1
	nTamTitP	:= TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+1
	cTipo		:= ""
	cLinha		:= ""
	cFiliais	:= ""
	cNatSld		:= ""
	cTpPartic	:= ""
	cPais		:= ""
	cMoeda		:= ""
	cIE			:= ""
	cHist		:= ""
	cMoedAux	:= ""
	cAntFil		:= ""
	cBanco		:= ""
	cFilOri		:= ""
	cHistC		:= ""
	cHistNF		:= ""		
	cSaldoR   	:= ""
	cSaldoP   	:= ""
	cSld200		:= ""
	cValor      := ""
	cSaldo      := ""
	cVlFun      := ""
	cCodBco 	:= ""
	cDtCheq		:= ""
	cUniao		:= SuperGetMV("MV_UNIAO",,"UNIAO")
	cMunic		:= SuperGetMV("MV_MUNIC",,"MUNIC")
	cSecEst		:= SuperGetMV("MV_RECEST",,"ESTADO")
	cCxFin		:= SuperGetMV("MV_CXFIN",,"CX1")
	cPrefSen	:= SuperGetMV("MV_PFSENAR",,"SEN")
	aStruFil	:= {}
	aStruBco	:= {}
	aTpReg		:= {}
	aFXV		:= {}
	aFVVAux		:= {}
	aAuxSE		:= {}
	aCli		:= {}
	aAuxCx		:= {}
	aCxFin		:= {}
	aAuxFVG		:= {}
	aBcoPrt		:= {}
	nSaldo		:= 0
	nValor		:= 0
	nSld200		:= 0
	nTamFil		:= TamSX3("A6_FILIAL")[1]
	nTamSx3		:= TamSX3("E5_VALOR")[1]
	nTamPart	:= TamSX3("FVV_PARTIC")[1]
	nDecPart	:= TamSX3("FVV_PARTIC")[2]
	cDecParc	:= ""
	cPict		:= StrTran(Space(nTamSx3), " ", "9") + ".99"
	cPictR		:= "@E 9,999,999,999,999.99"
	cTpCmp		:= ""
	__cDir		:= AllTrim(aParamIni[10]) // Diretório para geração do arquivo
	nVlNFE1		:= 0
	nVlNFE2		:= 0
	nValCorr	:= 0
	nValNF		:= 0
	nAbat		:= 0
	nAbtTotal	:= 0
	nVlCruz		:= 0

	lDecPrinc 	:= .F.
	lDecPrin 	:= .F.
	lNDevol		:= .F.
	aAuxDec     := {}
	aAux1 		:= {}
	aAux2 		:= {}

	If (Right(AllTrim(aParamIni[10]),1) $ "\/" )
		if Empty(aParamIni[11])
			__cArq		:= DEC + "_" + DtoS(Date()) + "_" + StrTran(Time(), ":", "_" )
		Else
			__cArq		:= aParamIni[11] // nome do arquivo via testcase
		EndIf
	EndIf
	
	__lF820Qry	:= ExistBlock("F820Qry")
	__lF820Reg	:= ExistBlock("F820Reg")
	__lF820Bco	:= ExistBlock("F820Bco")

	If ( nHdl := FCreate(__cDir + __cArq  + "." + EXT,,, .T.) ) > 0
		// Imprime os parametros iniciais
		DbSelectArea("FVU")
		FVU->(DbSetOrder(3))
			
		If FVU->(DbSeek(xFilial("FVU") + __cCpf))
			aParamIni[3] 	:= AllTrim(FVU->FVU_NOME)
			__cFVUCod		:= FVU->FVU_CODIGO
			// Abertura e identificação do arquivo (bl. 0000)
				
			cLinha := BL0000 + Dv + DEC + Dv + PadL(StrTran(aParamIni[1],".",""), 4, "0") + Dv + __cCpf + Dv + aParamIni[3] + Dv + aParamIni[4] + Dv ;
				 	+ aParamIni[5] + Dv + If( !Empty(aParamIni[6]), FormatDt(aParamIni[6]), '' ) + Dv + FormatDt(aParamIni[7]) + Dv + FormatDt(aParamIni[8]) + ENTER
	
			// Forma de apuração (bl. 0010)
			cLinha += BL0010 + Dv + aParamIni[9] + ENTER
		
			PrintLn(nHdl, cLinha)
			
			// Imprimir o contribuinte com base no cadastro (FVU)
			// (Bl. 0030)
			cLinha := ""
			
			SX5->(DbSeek(xFilial("SX5") + 'AA' + FVU->FVU_EST) )
						
			cLinha	:= BL0030 + Dv + AllTrim(FVU->FVU_END) + Dv + IIf(FVU->FVU_NUM <> 0 , AllTrim(STR(FVU->FVU_NUM)), "s/n" ) + Dv + AllTrim(FVU->FVU_COMPL) + Dv + AllTrim(FVU->FVU_BAIRRO) + Dv ;
			   		+ FVU->FVU_EST + Dv + SubStr(AllTrim(SX5->X5_DESCRI),2,2) + FVU->FVU_CODMUN + Dv + AllTrim(FVU->FVU_CEP) + Dv + AllTrim(FVU->FVU_FONE) + Dv + AllTrim(FVU->FVU_EMAIL) + ENTER
			PrintLn(nHdl, cLinha)
		EndIf
			
		If !Empty(cLinha)
			If __oTmpFil <> Nil
				__oTmpFil:Delete()
				__oTmpFil := Nil
			EndIf
				
			aAdd(aStruFil, {'FILIAL', 'C', nTamFil, 0})
			aAdd(aStruFil, {'COD', 'C', 3, 0})
			aAdd(aStruFil, {'VER', 'C', 4, 0})
			aAdd(aStruFil, {'NUMIMO', 'C', 3, 0})
			aAdd(aStruFil, {'DTINI', 'C', 8, 0})
			aAdd(aStruFil, {'DTFIM', 'C', 8, 0})

			__oTmpFil := FwTemporaryTable():New( 'TRF' )
			__oTmpFil:SetFields(aStruFil)
			__oTmpFil:AddIndex('1', {'FILIAL'})
			
			__oTmpFil:Create()
			
			For nI := 1 To Len(aSelfil)
				RecLock('TRF', .T.)
				TRF->FILIAL 	:= aSelFil[nI]
				TRF->(MsUnlock())
			Next

			cFiliais := "%FVV_FILIAL " + GetRngFil(aSelFil,"FVV",.T.,) + "%"
			
			// Filiais / Imóveis selecionados
			ArqTmp( '1', aSelFil,, cFiliais, aParamIni )
			
			// Terceiros dos Imóveis selecionados
			ArqTmp( '2',,, cFiliais, aParamIni )
			 	
			cLinha := ""
				
			ProcRegua((__cTmpFVV)->(RecCount()))

			cImov	:= "000"	
			// Imprimir as filiais / imóveis com base no aSelFil (Bl. 0040)
			TRF->(DbGoTop())
			While !TRF->(Eof())
				lDecPrinc := GetAdvFVal("FVV","FVV_CODPES",(__cTmpFVV)->FVV_FILIAL + (__cTmpFVV)->FVV_CODIGO,1) == __cFVUCod

				While !(__cTmpFVV)->(Eof()) .And. TRF->FILIAL == (__cTmpFVV)->(FVV_FILIAL)
					cImov	:= Soma1(cImov)
					If cAntFil != (__cTmpFVV)->(FVV_FILIAL)
						RecLock("TRF", .F.)
							TRF->VER	:= (__cTmpFVV)->(FVV_VERSAO)
							TRF->NUMIMO	:= (__cTmpFVV)->(NUMIMO)
							TRF->DTINI	:= If( !Empty((__cTmpFVV)->(FVV_VIGINI)), (__cTmpFVV)->(FVV_VIGINI), DTOS(aParamIni[7]) )
							TRF->DTFIM	:= If( !Empty((__cTmpFVV)->(FVV_VIGFIM)), (__cTmpFVV)->(FVV_VIGFIM), DTOS(aParamIni[8]) )
							TRF->COD	:= cImov
						TRF->(MsUnLock())
					Else
						aAdd( aFVVAux, { (__cTmpFVV)->(FVV_FILIAL), (__cTmpFVV)->(FVV_VERSAO), (__cTmpFVV)->(NUMIMO), ;
										If( !Empty((__cTmpFVV)->(FVV_VIGINI)), (__cTmpFVV)->(FVV_VIGINI), DTOS(aParamIni[7]) ), ;
										If( !Empty((__cTmpFVV)->(FVV_VIGFIM)), (__cTmpFVV)->(FVV_VIGFIM), DTOS(aParamIni[8]) ), cImov } )
					EndIf
					cAntFil := (__cTmpFVV)->(FVV_FILIAL)
					SX5->(DbSeek(xFilial("SX5") + 'AA' + (__cTmpFVV)->(UF)) )
						
					cTpPartic	:= (__cTmpFVV)->TIPO
					If (__cTmpFVV)->TAB == 'FVGMN' .And. (__cTmpFVV)->TPPES == '1'
						cTpPartic	:= AllTrim(Str( Val((__cTmpFVV)->TIPO) + 1 ) )	
					EndIf
					
					cPartic 	:= Iif("." $ Str((__cTmpFVV)->PERC) ,PadL( Substr(ALLTRIM(Str((__cTmpFVV)->PERC)),1, Rat(".", AllTrim(Str((__cTmpFVV)->PERC)) ) -1 ),3 , "0"),  PADL(ALLTRIM(STR((__cTmpFVV)->PERC)),3,"0") )
					cDecParc	:= Iif("." $ Str((__cTmpFVV)->PERC), Substr(Padr(SubStr(AllTrim(Str(Round((__cTmpFVV)->PERC,2))), Rat(".", AllTrim(Str((__cTmpFVV)->PERC)) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))
		
					cLinha	+= BL0040 + Dv + cImov + Dv + AllTrim((__cTmpFVV)->FVV_PAIS) + Dv + AllTrim((__cTmpFVV)->FVV_MOEDA) + Dv + AllTrim((__cTmpFVV)->FVV_CAFIR) + Dv + AllTrim((__cTmpFVV)->CAEPF) + Dv ;
							+ AllTrim((__cTmpFVV)->IE) + Dv + AllTrim((__cTmpFVV)->FVV_NOME) + Dv + AllTrim((__cTmpFVV)->FVV_END) + Dv + IIf((__cTmpFVV)->FVV_NUM <> 0, AllTrim(Str((__cTmpFVV)->FVV_NUM)), "s/n")  + Dv + AllTrim((__cTmpFVV)->FVV_COMPL) + Dv ;
							+ AllTrim((__cTmpFVV)->FVV_BAIRRO) + Dv + AllTrim((__cTmpFVV)->UF) + Dv + SubStr(AllTrim(SX5->X5_DESCRI),2,2) + AllTrim((__cTmpFVV)->FVV_CODMUN) + Dv + AllTrim((__cTmpFVV)->FVV_CEP);
							+ Dv + cTpPartic + Dv  + cPartic +cDecParc + ENTER
				
					nQtdLin++
						
					// Imprimir terceiros com base no cadastro (FVG) (Bl. 0045)
					(__cTmpFVG)->(DbGoTop() )
					While !(__cTmpFVG)->(Eof())
						If TRF->FILIAL == (__cTmpFVG)->FVV_FILIAL
							If !( AllTrim((__cTmpFVG)->FVU_CNPJ) == __cCpf ) .And. (__cTmpFVV)->(FVV_VERSAO) == (__cTmpFVG)->VER .And. TRF->NUMIMO == (__cTmpFVG)->NUMIMO
								cTpPartic	:= ""
								Do Case
									Case (__cTmpFVG)->TAB $ ('FVV|FXV')
										cTpPartic	:= AllTrim(Str( Val((__cTmpFVG)->TIPO) -1 ) )
									OtherWise
										cTpPartic	:= (__cTmpFVG)->TIPO	
								EndCase
								cDecParc	:= Iif("." $ Str((__cTmpFVG)->PERC), Substr(Padr(SubStr(AllTrim(Str(Round((__cTmpFVG)->PERC,2))), Rat(".", AllTrim(Str((__cTmpFVG)->PERC)) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))								
								cPartic 	:= Iif("." $ Str((__cTmpFVG)->PERC) ,PadL( Substr(ALLTRIM(Str((__cTmpFVG)->PERC)),1, Rat(".", AllTrim(Str((__cTmpFVG)->PERC)) ) -1 ),3 , "0"),  PADL(ALLTRIM(STR((__cTmpFVG)->PERC)),3,"0") )
																		
								cLinha	+= BL0045 + Dv + If(Empty(TRF->COD) .Or. ( TRF->VER != (__cTmpFVG)->VER ), cImov, TRF->COD) + Dv + cTpPartic + Dv + AllTrim((__cTmpFVG)->FVU_CNPJ) + Dv + AllTrim((__cTmpFVG)->FVU_NOME) + Dv + ;
										cPartic + cDecParc + ENTER

								nQtdLin++
								(__cTmpFVG)->(DbSkip())
							Else
								(__cTmpFVG)->(DbSkip())
							EndIf
						Else
							(__cTmpFVG)->(DbSkip())
						EndIf
					EndDo
					cPais	:= (__cTmpFVV)->FVV_PAIS
					cMoeda	:= (__cTmpFVV)->FVV_MOEDA
					cIE		:= (__cTmpFVV)->IE

					If ( aScan( aFXV, { |x| x == (__cTmpFVV)->FVV_FILIAL } ) ) == 0
						aAdd(aFXV, (__cTmpFVV)->FVV_FILIAL )
						nCount	:= FilCompl((__cTmpFVV)->FVV_CODIGO)

						If nCount > 0
					
							FXV->(DbSetOrder(2))
							FXV->(DbGoTop())
							FXV->(DbSeek((__cTmpFVV)->FVV_FILIAL + (__cTmpFVV)->FVV_CODIGO ))

							lTemCompl	:= .T.
							If !lDecPrinc .Or. ( FXV->FXV_CODPES != __cFVUCod )
								lAchou	:= .F.
								FVG->(DbSetOrder(2))
								FVG->(DbGoTop())
								FVG->(DbSeek((__cTmpFVV)->FVV_FILIAL + (__cTmpFVV)->FVV_CODIGO ) )
								While !FVG->(Eof()) .And. !lAchou .And. FXV->FXV_FILIAL == FVG->FVG_FILIAL
									If FXV->FXV_CODIGO == FVG->FVG_CODIMO .And. FXV->FXV_VERSAO == FVG->FVG_VERSAO .AND. FVG->FVG_NUMIMO == FXV->FXV_NUMIMO .And. FVG->FVG_CODPES == __cFVUCod
									
										aAux1 := {}
										aAux2 := {}
										aAdd(aAuxDec, {"DEC", __cFVUCod, FVG->FVG_PERC, FVG->FVG_TIPO} )
										aAux1 := GetAdvFVal("FXV", {"FXV_CODPES","FXV_PARTIC"},(__cTmpFVV)->FVV_FILIAL + (__cTmpFVV)->FVV_CODIGO,2)
										aAux2 := GetAdvFVal("FVU", {"FVU_NOME","FVU_CNPJ"},SPACE(nTamFil) + aAux1[1],1)
										aAdd(aAuxDec, {"TEC", aAux1[1], aAux1[2], aAux2[1], aAux2[2] })
										lAchou	:= .T.
									EndIf
									FVG->(DbSkip())
								EndDo
							EndIf
														
							While !FXV->(Eof())
								If TRF->FILIAL == FXV->FXV_FILIAL .And. TRF->VER == FXV->FXV_VERSAO
									cImov	:= Soma1(cImov)
									SX5->(DbSeek(xFilial("SX5") + 'AA' + FXV->FXV_UF) )
									
									cTpPartic	:= FXV->FXV_TIPOEX

									If lDecPrinc .And. Len(aAuxDec) == 0 
										cPartic 	:= Iif("." $ Str(FXV->FXV_PARTIC) ,PadL( Substr(ALLTRIM(Str(FXV->FXV_PARTIC)),1, Rat(".", AllTrim(Str(FXV->FXV_PARTIC)) ) -1 ),3 , "0"), PADL(ALLTRIM(STR(FXV->FXV_PARTIC)),3,"0") )
										cDecParc	:= Iif("." $ Str(FXV->FXV_PARTIC), Substr(Padr(SubStr(AllTrim(Str(Round(FXV->FXV_PARTIC,2))), Rat(".", AllTrim(Str(FXV->FXV_PARTIC)) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))
									Else
										If lAchou
											cPartic 	:= Iif("." $ Str(aAuxDec[1][3]) ,PadL( Substr(ALLTRIM(Str(aAuxDec[1][3])),1, Rat(".", AllTrim(Str(aAuxDec[1][3])) ) -1 ),3 , "0"), PADL(ALLTRIM(STR(aAuxDec[1][3])),3,"0") )
											cDecParc	:= Iif("." $ Str(aAuxDec[1][3]), Substr(Padr(SubStr(AllTrim(Str(Round(aAuxDec[1][3],2))), Rat(".", AllTrim(Str(aAuxDec[1][3])) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))
											cTpPartic	:= AllTrim(Str(Val(aAuxDec[1][4]) + 1))	
										Else	
											lTemCompl	:= .F.
										EndIf
									EndIf
		
									If lTemCompl
										cLinha	+= BL0040 + Dv + cImov + Dv + AllTrim(cPais) + Dv + AllTrim(cMoeda) + Dv + AllTrim(FXV->FXV_CAFIR) + Dv + AllTrim(FXV->FXV_CAEPF) + Dv ;
												+ AllTrim(cIE) + Dv + AllTrim(FXV->FXV_NOME) + Dv + AllTrim(FXV->FXV_END) + Dv + AllTrim(Str(FXV->FXV_NUM) ) + Dv + AllTrim(FXV->FXV_COMPL) + Dv ;
												+ AllTrim(FXV->FXV_BAIRRO) + Dv + AllTrim(FXV->FXV_UF) + Dv + SubStr(AllTrim(SX5->X5_DESCRI),2,2) + AllTrim(FXV->FXV_CODMUN) + Dv + AllTrim(FXV->FXV_CEP) ;
												+ Dv + cTpPartic + Dv + cPartic +cDecParc+ ENTER
										nQtdLin++
									
										FVG->(DbSetOrder(2))
										FVG->(DbGoTop())
										FVG->(DbSeek((__cTmpFVV)->FVV_FILIAL + (__cTmpFVV)->FVV_CODIGO ) )
										While !FVG->(Eof()) .And. FXV->FXV_FILIAL == FVG->FVG_FILIAL
											If FXV->FXV_CODIGO == FVG->FVG_CODIMO .And. FXV->FXV_VERSAO == FVG->FVG_VERSAO .AND. FVG->FVG_NUMIMO == FXV->FXV_NUMIMO
												
												lDecPrin := GetAdvFVal("FXV","FXV_CODPES",FVG->(FVG_FILIAL + FVG_CODPES),2) == __cFVUCod

												If lDecPrin
													cTpPartic	:= AllTrim(Str( Val(FXV->FXV_TIPOEX)-1 ) )											
												Else
													cTpPartic	:= AllTrim(Str( Val(FVG->FVG_TIPO) ) )											
												EndIf
												
												FVU->(DbSetOrder(1))
												FVU->(DbGoTop())
												FVU->(DbSeek(xFilial("FVU") + FVG->FVG_CODPES))
												
												If Len(aAuxDec) == 0 .Or. ( Len(aAuxDec) > 0 .And. ascan(aAuxdec,{|x| x[2]== FVG->FVG_CODPES}) == 0 )
													cDecParc	:= Iif("." $ Str(FVG->FVG_PERC), Substr(Padr(SubStr(AllTrim(Str(Round(FVG->FVG_PERC,2))), Rat(".", AllTrim(Str(FVG->FVG_PERC)) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))
													cPartic 	:= Iif("." $ Str(FVG->FVG_PERC) ,PadL( Substr(ALLTRIM(Str(FVG->FVG_PERC)),1, Rat(".", AllTrim(Str(FVG->FVG_PERC)) ) -1 ),3 , "0"),  PADL(ALLTRIM(STR(FVG->FVG_PERC)),3,"0") )
													cLinha	+= BL0045 + Dv + cImov + Dv + cTpPartic + Dv + AllTrim(FVU->FVU_CNPJ) + Dv + AllTrim(FVU->FVU_NOME) + Dv + ;
															cPartic +cDecParc+ ENTER												
												Else
													cDecParc	:= Iif("." $ Str(aAuxDec[2,3]), Substr(Padr(SubStr(AllTrim(Str(Round(aAuxDec[2,3],2))), Rat(".", AllTrim(Str(aAuxDec[2,3])) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))
													cPartic 	:= Iif("." $ Str(aAuxDec[2,3]) ,PadL( Substr(ALLTRIM(Str(aAuxDec[2,3])),1, Rat(".", AllTrim(Str(aAuxDec[2,3])) ) -1 ),3 , "0"),  PADL(ALLTRIM(STR(aAuxDec[2,3])),3,"0") )												
													cLinha	+= BL0045 + Dv + cImov + Dv + cTpPartic + Dv + AllTrim(aAuxDec[2,5]) + Dv + AllTrim(aAuxDec[2,4]) + Dv + ;
																cPartic + cDecParc+ENTER
												EndIf
												
												nQtdLin++

												FVG->(DbSkip())
											Else
												FVG->(DbSkip())
											EndIf
										EndDo
									EndIf
								EndIf
								FXV->(DbSkip())
							EndDo
						EndIf
					EndIf
					(__cTmpFVV)->(DbSkip())
				EndDo
					
				TRF->(DbSkip())
			EndDo

			(__cTmpFVV)->(DbCloseArea())
			cLinha := FwNoAccent(Strtran(cLinha,"'"," "))

			PrintLn(nHdl, cLinha)
			
			For nI:= 1 To Len(aFVVAux)
				RecLock("TRF", .T.)
					TRF->FILIAL := aFVVAux[nI][1]
					TRF->VER	:= aFVVAux[nI][2]
					TRF->NUMIMO	:= aFVVAux[nI][3]
					TRF->DTINI	:= aFVVAux[nI][4]
					TRF->DTFIM	:= aFVVAux[nI][5]
					TRF->COD	:= aFVVAux[nI][6]
				TRF->(MsUnLock())
			Next nI

			// Imprimir contas com base no cadastro de Bancos (Bl. 0050)
			cLinha	:= ""
				
			If __oTmpBco <> Nil
				__oTmpBco:Delete()
				__oTmpBco := Nil
			EndIf
				
			aAdd(aStruBco, {'BANCO', 'C', 3, 0})
			aAdd(aStruBco, {'AGENCIA', 'C', 5, 0})
			aAdd(aStruBco, {'CONTA', 'C', 16, 0})
			aAdd(aStruBco, {'COD', 'C', 3, 0})
			aAdd(aStruBco, {'FIL', 'C', nTamFil, 0})
				
			__oTmpBco := FwTemporaryTable():New( 'TRB' )
			__oTmpBco:SetFields(aStruBco)
			__oTmpBco:AddIndex('1', {'BANCO', 'AGENCIA', 'CONTA'})
			
			__oTmpBco:Create()
			
			cConta		:= "000"
			__nTamFlA6	:= Len(AllTrim(aBancos[1][5]))
			lTemBcOfi 	:= Len(aBancos[1]) > 6

			aBcoPrt		:= aClone(aBancos)
			If __lF820Bco
				aBancos		:= ExecBlock('F820Bco', .F., .F., { aBancos } )
			EndIf
				
			For nI := 1 To Len(aBancos)
				If lTemBcOfi .And. !Empty(aBancos[nI][7])
					SX5->(DbSeek(xFilial("SX5") + "0N" + aBancos[nI][7]) )
				Else
					SX5->(DbSeek(xFilial("SX5") + "0N" + aBancos[nI][1]) )
				EndIf
				cConta	:= Soma1(cConta)
				
				cLinha	+= BL0050 + Dv + cConta + Dv + AllTrim(aBancos[nI][6]) + Dv + If(lTemBcOfi .And. !Empty(aBancos[nI][7]), aBancos[nI][7], AllTrim(aBancos[nI][1]) ) + Dv + SubStr( AllTrim(Iif(!Empty(SX5->X5_DESCRI), SX5->X5_DESCRI, STR0011)), 1, 30 ) + Dv + SubStr( AllTrim(aBancos[nI][2]), 1, 4 ) + Dv + PadL(AllTrim(aBancos[nI][3]) + Iif( IsAlpha(aBancos[nI][4]) , "0", AllTrim(aBancos[nI][4]) ), 16, "0" ) + ENTER // Banco LCDPR

				RecLock('TRB', .T.)
				TRB->BANCO		:= AllTrim(aBancos[nI][1])
				TRB->AGENCIA	:= AllTrim(aBcoPrt[nI][2])
				TRB->CONTA		:= AllTrim(aBcoPrt[nI][3])
				TRB->COD		:= cConta
				TRB->FIL		:= AllTrim(aBancos[nI][5])
				TRB->(MsUnLock())
				
				nQtdLin++
			Next
			
			PrintLn(nHdl, cLinha)
			
			cLinha := ""
			// Imprimir movimentos retornado na MontaLCDPR (Bl. Q100)
			ArqTmp( '0',,, cFiliais, aParamIni, cDtPeriodo, lDevolNF )
			
			cLinAux	:= ""
			cLin200	:= ""
			nSaldo	:= 0
			nValor	:= 0
			nSaldoR	:= 0
			nSaldoP	:= 0
			cMes	:= ""
			cOldMes	:= ""
			cNatSld	:= ""
			
			aAuxCx 	:= STRTOKARR(cCxFin, '/')
			For nI	:= 1 To Len(aAuxCx)
				If Len(aAuxCx[nI]) == 3
					aAdd(aCxFin, AllTrim(aAuxCx[nI]))
				EndIf
			Next
					
			TRB100->(DbGoTop())

			While !TRB100->(Eof())	
	
				__nVlNota	:= 0
				__nVlFun	:= 0
				__lFunrural	:= .F.
				__lNftot	:= .F.
				nValCorr	:= 0
				nAbat		:= 0
				nAbtTotal	:= 0
				nVlAcCmp	:= 0
				lTipoVA 	:= TRB100->TPDOC $ "JR|DC|MT"
				cVlAcCmp	:= ""
				cNumDoc		:= ""
				cTpCmp		:= ""				
				cBanco		:= ""
				lRegValid	:= .T.
				lPJNRural	:= .T.
				lDespCmpA	:= .F.
				lDespCmpD	:= .F.
				lNDevol		:= .F.

				If ValType(TRB100->MOEDA) == 'N'
					cMoedAux	:= PadL(TRB100->MOEDA, 2, "0" )
				Else
					cMoedAux	:= AllTrim(TRB100->MOEDA)
				EndIf
				If AllTrim(TRB100->TPDOC) $ 'BA' .And. TRB100->E5_MOTBX $ "FAT"
					lRegValid	:= .F.
				EndIf

				If lRegValid
					// Se for um recebimento de Titulo pago em dinheiro originado pelo SIGALOJA, nao imprime o mov.
					If TRB100->TPDOC == "BA" .and. TRB100->E5_MOTBX == "LOJ" .And. IsMoney(cMoedAux)
						lRegValid := .F.
					EndIf
				EndIf

				cRotOri	:= ""
				cFilOri	:= ""
				aSize(aAuxSE, 0)
				aAuxSE	:= Nil
				aAuxSE	:= {}
				FWFreeArray(aCli)
				aCli	:= {}
				//Tratamento p/ ñ imp tít aglutinador quando o mesmo não estiver sofrido baixa.
				If !Empty(TRB100->REC)
					If !(__lF820Qry) .Or. (__lF820Qry .And. ( Empty(TRB100->CODEMP) .Or. (!Empty(TRB100->CODEMP) .And. cEmpAnt == TRB100->CODEMP ) ) )
						aAuxSE	:= RotOri(TRB100->RECPAG, TRB100->SEFIL, TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, TRB100->E5_TIPO, TRB100->CLIFOR, TRB100->LOJA, lDevolNF, nTamTitR)
						cRotOri		:= aAuxSE[1]
						__cFilOri	:= cFilOri := SE5->E5_FILORIG
						__nTxMoeda	:= SE5->E5_TXMOEDA
	
						DbSelectArea("SE5")
						SE5->( DbGoTo(TRB100->REC) )
						cTpCmp	:= Substr(SE5->E5_DOCUMEN,nTamTitR,3)						

						// Condições do padrão:

						IF (__cLCDPRRA == "D" .AND. TRB100->TPDOC == "CP" .And. cTpCmp $ MVRECANT .AND. !EMPTY(TRB100->E1_VLCRUZ) ) .OR. (__cLCDPRPA == "D" .AND. TRB100->TPDOC == "CP" .And. cTpCmp $ MVPAGANT .AND. !EMPTY(TRB100->E2_VLCRUZ)) 
							TRB100->(DbSkip())
							IF TRB100->(Eof())
								Exit
							ELSE
								Loop
							ENDIF
						ENDIF

						// Considera as Notas de Devol.
						If TRB100->E5_MOTBX == 'CMP'
							If (TRB100->RECPAG == "R" .and. aAuxSE[3]) .or. (TRB100->RECPAG == "P" .and. !( "FIN" $ cRotOri )) //É nota de devolução
								If cTpCmp $ (MV_CRNEG + "|" + MV_CPNEG)
									lRegValid := lDevolNF
								EndIf
							Else //Criado no Financeiro						
								If AllTrim(TRB100->TPDOC) $ 'BA' .OR. ( cTpCmp $ (MV_CRNEG + "|" + MV_CPNEG) ) // RA/PA - Vai apenas o E5_TIPODOC = CP | NCC/NDF - Não vai nem o CP e nem o BA
									lRegValid := .F.
								EndIf
							EndIf
						EndIf
						
						If lRegValid .And. Empty(SE5->(E5_TIPO+E5_DOCUMEN+E5_IDMOVI+E5_FILORIG+E5_MOEDA))
							lRegValid 	:= .F.
						EndIf
						If lRegValid .And. AllTrim(SE5->E5_ORIGEM) != 'FINA100' .And. Empty(SE5->E5_TIPODOC) .And. Empty(SE5->E5_NUMERO)
							lRegValid 	:= .F.
						EndIf
						cBanco	:= SE5->E5_BANCO
					
						If lRegValid .And. TRB100->RECPAG == 'P' .And. !Empty(SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ) ) .And. SE5->E5_TIPODOC == 'BA'
							If !FTemChq(SE5->E5_FILIAL, SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_NUMCHEQ, TRB100->RECPAG)
								lRegValid	:= .F.
							ElseIf cDtPeriodo == '2'
								If TRB100->TPDOC == 'BA'
									lRegValid	:= .F.
								Else
									cDtCheq := GetAdvFVal("SEF","EF_DATA", FwxFilial("SEF", cFilOri) + SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ),1)
												// EF_FILIAL, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_NUM
									If !( aParamIni[7] <= cDtCheq .And. cDtCheq <= aParamIni[8] )
										lRegValid	:= .F.
									EndIf
								EndIf
							EndIf
						ElseIf lRegValid .And. TRB100->RECPAG == 'R'
							If lSldBxCR
								If SE5->E5_TIPODOC == 'BA' 
									If !Empty(SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA) ) .And. !Empty(SE5->E5_NUMCHEQ) .And. (cDtPeriodo == '2' .Or. (cDtPeriodo == '1' .And. !FTemChq(SE5->E5_FILIAL, SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_NUMCHEQ, TRB100->RECPAG)))
										lRegValid := .F.
									EndIf
								ElseIf SE5->E5_TIPODOC == 'CH' .And. (!FTemChq(SE5->E5_FILIAL, SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_NUMCHEQ, TRB100->RECPAG) .Or. cDtPeriodo == '1')
									lRegValid := .F.
								EndIf
							ElseIf SE5->E5_TIPODOC == 'CH'
								lRegValid	:= .F.
							EndIf
						EndIf
						nValCorr 	:= SE5->E5_VLCORRE 
					EndIf
				Else
					aAuxSE	:= RotOri(TRB100->RECPAG, TRB100->SEFIL, TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, TRB100->E5_TIPO, TRB100->CLIFOR, TRB100->LOJA)
					cRotOri	:= aAuxSE[1]
					cFilOri	:= aAuxSE[2]
				EndIf

				If ( !Empty(TRB100->E5_TIPO) .And. TRB100->E5_TIPO $ MVPAGANT ) .And. ( AllTrim(TRB100->TPDOC) = 'BA' .And. TRB100->E5_MOTBX != 'CEC' )
					lRegValid	:= .F.
				EndIf
				
				If ( !Empty(TRB100->E5_TIPO) .And. TRB100->E5_TIPO $ MVPAGANT ) .And. ( ( TRB100->RECPAG == 'R' .And. TRB100->E5_MOTBX != 'CMP' ) )
					lRegValid	:= .F.
				EndIf

				If ( !Empty(TRB100->E5_TIPO) .And. TRB100->E5_TIPO $ MVRECANT ) .And. ( ( TRB100->RECPAG == 'P' .And. TRB100->E5_MOTBX != 'CMP' ) )
					lRegValid	:= .F.
				EndIf

				If __lF820Reg
					If __aTpReg <> Nil
						aTpReg	:= ExecBlock('F820Reg', .F., .F., { TRB100->REC, {}, lRegValid} )						
					Else
						__aTpReg	:= { {""}, {""}, {""}, {""}, {""} }
						aTpReg		:= ExecBlock('F820Reg', .F., .F., { TRB100->REC, __aTpReg, lRegValid } )						
						__aTpReg 	:= aClone(aTpReg[2] )			
					EndIf
					lRegValid	:= aTpReg[1]						
					If Len(aTpReg) > 2 .And. Valtype(aTpReg[3]) == "C"
						cNumDoc := aTpReg[3]
					EndIf
				EndIf

				If !lRegValid
					TRB100->(DbSkip())
					Loop
				EndIf
				
				If lRegValid
					cMes 	:= TRB100->MES_ANO
					nProp	:= If(TRB100->PERC > 0, TRB100->PERC, 100) / 100

					If TRB100->RECPAG == 'P'
						If !lTipoVA .And. ( lVlLiqP .Or. ( !Fn820Abat(TRB100->RECPAG,TRB100->E5_TIPO) .And. TRB100->E2_VLCRUZ <> TRB100->VALOR ) )
							DbSelectArea("SE2")
							DbSetOrder(1)
							DbSeek(xFilial("SE2", cFilOri ) + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + TRB100->E5_TIPO + TRB100->CLIFOR + TRB100->LOJA )
							nAbtTotal	:= SumAbatPag( TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, TRB100->CLIFOR, Val(TRB100->MOEDA), "V", CTOD(TRB100->DDATA), TRB100->LOJA )
							nTxMTit		:= SE2->E2_TXMOEDA
						EndIf
					ElseIf !lTipoVA .And. ( lVlLiqR .Or. ( !Fn820Abat(TRB100->RECPAG,TRB100->E5_TIPO) .And. TRB100->E1_VLCRUZ <> TRB100->VALOR ) )
						DbSelectArea("SE1")
						DbSetOrder(2)
						DbSeek(xFilial("SE1", cFilOri ) + TRB100->CLIFOR + TRB100->LOJA + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + TRB100->E5_TIPO )
						nAbtTotal := SumAbatRec( TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, Val(TRB100->MOEDA), "V", CTOD(TRB100->DDATA),,,,,,, xFilial("SE1", cFilOri ) )
						nTxMTit		:= SE1->E1_TXMOEDA
					EndIf
					If nAbtTotal > 0 .And. Val(TRB100->MOEDA) > 1
						nAbtTotal := xMoeda(nAbtTotal,Val(TRB100->MOEDA),1,TRB100->DDATA,__nDecs + 1,If(__nTxMoeda > 1, __nTxMoeda, If( nTxMTit <> 0, nTxMTit, RecMoeda(TRB100->DDATA,Val(TRB100->MOEDA)))) )
					EndIf
					__nAbtNF	:= 0

					If TRB100->RECPAG == 'R'
						aCli		:= GetAdvFVal("SA1", {"A1_PESSOA", "A1_TIPO"},FwxFilial("SA1", cFilOri) + TRB100->CLIFOR + TRB100->LOJA,1)
					 	lPJNRural	:= ( Len(aCli) == 0 .Or. (Len(aCli) > 0 .And. aCli[1] != 'F' .And. aCli[2] != 'L' ) )
					EndIf

					If !( "FIN" $ cRotOri ) .And. TRB100->RECPAG == 'R' .And. !lTipoVA
						If lDevolNF .And. TRB100->E5_MOTBX == "CMP" .And. TRB100->TPDOC == "CP" .And. cTpCmp $ (MV_CRNEG)
							nValor	:= TRB100->VALOR
							lNDevol	:= .T.
						Else
							nValor := ValBruNf(TRB100->RECPAG, cFilOri, TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, TRB100->E5_TIPO, TRB100->CLIFOR, TRB100->LOJA, TRB100->RECSF12, TRB100->VBRUT12,TRB100->VSENA12,TRB100->VINSS12,TRB100->COSOC12, nAbtTotal, lPJNRural)
						EndIf
						nValor := Val(StrTran(Transform( If( !Empty(cMoedAux) .And. cMoedAux != '01' .And. TRB100->VLMOED2 > 0, If(FMoedTit(cMoedAux, cFilOri, @nVlCruz), nVlCruz, TRB100->VLMOED2) / __nPropBx, nValor) * nProp, cPict), ".", "") )
					Else
						nValor		:= Val(StrTran(Transform( If( !Empty(cMoedAux) .And. cMoedAux != '01' .And. TRB100->VLMOED2 > 0, If(FMoedTit(cMoedAux, cFilOri, @nVlCruz), nVlCruz,TRB100->VLMOED2), TRB100->VALOR) * nProp, cPict), ".", "") )
						If AllTrim(TRB100->TPDOC) == "CH"
							__nPropBx	:= 1
						Else
							__nPropBx	:= If(Val(TRB100->MOEDA) > 1, ( ( nValor / 100 ) / nProp ), TRB100->VALOR ) / If(TRB100->RECPAG == "R", TRB100->E1_VLCRUZ-nAbtTotal, TRB100->E2_VLCRUZ - nAbtTotal)
						EndIf
					EndIf

					nAbtTotal := nAbtTotal - __nAbtNF
					If nAbtTotal < 0
						nAbtTotal := 0
					EndIf
					If !Empty(TRB100->REC)
						If !(__lF820Qry) .Or. (__lF820Qry .And. ( Empty(TRB100->CODEMP) .Or. (!Empty(TRB100->CODEMP) .And. cEmpAnt == TRB100->CODEMP ) ) )
							If nAbtTotal > 0 .And. !__lNftot .And. !lNDevol
								nAbat	+= ( ( nAbtTotal * nProp ) * 100 ) * __nPropBx
								nValor	+= nAbat
								nValor 	:= Val(StrTran(Transform( nValor / 100, cPict), ".", "") )
							EndIf
						EndIf
					EndIf
					
					IF (__cLCDPRRA == "D" .AND. TRB100->E5_TIPO == "RA " ) .AND. !EMPTY(TRB100->E1_VLCRUZ)
						nValor := Round((TRB100->VALOR * nProp),2)*100
					ENDIF

					IF (__cLCDPRPA == "D" .AND. TRB100->E5_TIPO == "PA " ) .AND. !EMPTY(TRB100->E2_VLCRUZ)
						nValor := Round((TRB100->VALOR * nProp),2)*100
					ENDIF

					nSaldo 	+= Iif( ( TRB100->RECPAG == 'R' .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG .And. nValor >= 0, nValor, ( nValor * -1 ) )

					cNatSld	:= Iif( nSaldo < 0, "N", "P")										
					nCaso 	:= 0

					If TRB100->E5_TIPO == "AB-"
						cHist 	:= STR0023 + AllTrim(TRB100->NUMDOC)
					ElseIf TRB100->E5_TIPO == "IN-" .And. Empty( AllTrim(TRB100->HIST) ) 
						cHist 	:= STR0024 + AllTrim(TRB100->NUMDOC)
					ElseIf Empty( AllTrim(TRB100->HIST) ) 
						cHist 	:= Iif( Empty(AllTrim(TRB100->NUMDOC)), STR0019, STR0018 + AllTrim(TRB100->NUMDOC) ) // "S/Num. de documento" # "No. Documento: "
					Else
						cHist	:= AllTrim(TRB100->HIST)
					EndIf
					cHist :=  FwNoAccent(cHist)
					
					If !Empty( TRB100->CNPJCLI ) .AND. ( (TRB100->RECPAG == "R" .And. !TRB100->TPDOC == "DC") .OR. ( TRB100->RECPAG == 'P' .AND. ( '-' $ TRB100->E5_TIPO .Or. TRB100->TPDOC == 'DC' ) ) )
						cCnpj	:= 	TRB100->CNPJCLI
					Else
						If Empty( TRB100->CNPJFOR )
							If lE5Cgc .And. !Empty( TRB100->CGC )
								cCnpj	:= TRB100->CGC
							Else
								cCnpj	:= __cCpf
							EndIf
						Else
							cCnpj	:= TRB100->CNPJFOR
						EndIf	
					EndIf
					Do Case
						Case TRB100->E5_TIPO $ MVNOTAFIS + Iif(__lF820Reg, "|" + __aTpReg[1][1], "") .AND. !lTipoVA
							cTipo	:= TPDOCNF
							nCaso 	:= 1
			
							//Pagina 26 do Anexo ao Ato Declaratório Executivo COPES no 1/2020 – Manual de Preenchimento do LCDPR
							//Caso o país esteja no bloco Mercosul, preencher com número da Nota Fiscal
							//Caso o país não seja parte do bloco Mercosul, preencher com o número da Declaração de Importação/Exportação
							If Empty(cNumDoc)
								DbSelectArea("SYA")
								SYA->(DbSetOrder(1))//YA_FILIAL + YA_CODGI
								If SYA->(DbSeek(FwxFilial("SYA") + TRB100->PAISFOR ))
									lMercosul := IIF(SYA->YA_MERCOSU == "1", .T., .F.)
								EndIf
							
								DbSelectArea("CD5")
								CD5->(DbSetOrder(1))//CD5_FILIAL + CD5_DOC + CD5_SERIE 
								If !lMercosul .AND. CD5->(DbSeek(FwxFilial("CD5") + TRB100->NUMDOC + AllTrim(TRB100->PREFIXO) ))
									cNumDoc := Alltrim(CD5->CD5_DOCIMP)
								Else
									cNumDoc	:= AllTrim(TRB100->NUMDOC) + Iif( !Empty(AllTrim(TRB100->PREFIXO)), "/" + AllTrim(TRB100->PREFIXO), "") 
								EndIf
							EndIf
						Case TRB100->E5_TIPO $ MVFATURA + Iif(__lF820Reg, "|" + __aTpReg[2][1], "") .AND. !lTipoVA
							cTipo 	:= TPDOCFT
							If Empty(cNumDoc)
								cNumDoc	:= Iif( !Empty(AllTrim(TRB100->PREFIXO)), AllTrim(TRB100->PREFIXO) + "/", "" ) + AllTrim(TRB100->NUMDOC)
							EndIf
						Case TRB100->E5_TIPO $ 'RC ' + Iif(__lF820Reg, "|" + __aTpReg[3][1], "") .AND. !lTipoVA
							cTipo := TPDOCRC
							If Empty(cNumDoc)
								cNumDoc	:= Iif(!Empty(AllTrim(TRB100->PREFIXO)), AllTrim(TRB100->PREFIXO) + "/", "" ) + AllTrim(TRB100->NUMDOC)
							EndIf
						Case TRB100->E5_TIPO $ 'C01' + Iif(__lF820Reg, "|" + __aTpReg[4][1], "") .AND. !lTipoVA
							cTipo := TPDOCCT
							If Empty(cNumDoc)
								cNumDoc	:= Iif( !Empty(AllTrim(TRB100->PREFIXO)), AllTrim(TRB100->PREFIXO) + "/", "" ) + AllTrim(TRB100->NUMDOC)
							EndIf
						Case TRB100->E5_TIPO $ 'FOL|FER' + Iif(__lF820Reg, "|" + __aTpReg[5][1], "") .AND. !lTipoVA
							cTipo := TPDOCFP
							If Empty(cNumDoc)
								cNumDoc	:= Iif( !Empty(AllTrim(TRB100->PREFIXO)), AllTrim(TRB100->PREFIXO) + "/", "" ) + AllTrim(TRB100->NUMDOC)
							EndIf
						OtherWise
							cTipo := TPDOCOU
							If Empty(cNumDoc)
								cNumDoc	:= Iif( !Empty(AllTrim(TRB100->PREFIXO)), AllTrim(TRB100->PREFIXO) + "/", "" ) + AllTrim(TRB100->NUMDOC)
							EndIf
					EndCase
					
					nVlNFE1		:= Iif(__lFunrural .Or. __nVlNota > 0,__nVlNota,TRB100->E1_VLCRUZ)
					nVlNFE2		:= Iif(__lFunrural .Or. __nVlNota > 0,__nVlNota,TRB100->E2_VLCRUZ)
					nValNF 		:= Iif(TRB100->VBRUT12 > 0, TRB100->VBRUT12, Iif(nVlNFE2>0,nVlNFE2,If(nVlNFE1 > 0, nVlNFE1, TRB100->VALOR + nAbtTotal)) )

					If nValCorr > 0
						cHistC := STR0021 + Alltrim(Transform(Abs(nValCorr),cPictR)) // " - C/ correc. monet. posit.: " 
					ElseIf nValCorr < 0
						cHistC := STR0022 + Alltrim(Transform(Abs(nValCorr),cPictR)) // " - C/ correc. monet. negat.: "
					Else
						cHistC := ""
					EndIf	

					If lTipoVA
						cHistNF := STR0025+ AllTrim(TRB100->NUMDOC)
					Else
						cHistNF := STR0017 + AllTrim(Transform(nValNF, cPictR))
					EndIf				

					cValor := IIf(Abs(nValor) >= 100 , AllTrim(Str(Abs(nValor))) ,  Padl(AllTrim(Str(Abs(nValor))), nTamSx3 , "0"))
					cSaldo := IIf(Abs(nSaldo) >= 100 , AllTrim(Str(Abs(nSaldo))) ,  Padl(AllTrim(Str(Abs(nSaldo))), nTamSx3 , "0"))
					
					cCodBco := ''
					If Empty(TRB100->BANCO) .And. lTipoVA 		// lTipoVA 	:= TRB100->TPDOC $ "JR|DC|MT"
						cCodBco := '999'
					ElseIf !Empty(TRB100->BANCO)
						cCodBco := TRB100->BANCO
					ElseIf Empty(TRB100->BANCO) .And. TRB100->E5_MOTBX == 'CMP'
						cCodBco := BcoAdto()
					ElseIf TRB100->E5_MOTBX == 'ESP' .OR. TRB100->MOEDA == 'R$' .OR. ( !Empty(cBanco) .And. aScan(aCxFin, { |x| x == cBanco } ) > 0 )
						cCodBco := "000"
					Else
						cCodBco := '999'
					EndIf

					cLinha	+= BLQ100 + Dv + TRB100->DIA + TRB100->MES_ANO + Dv + TRB100->FILCOD + Dv + cCodBco + Dv + cNumDoc + Dv + cTipo + Dv + ;
							Iif( __lImpHist, cHist, Iif(nCaso == 1 .Or. lTipoVA , cHist + " - " + cHistNF + cHistC, cHist ) ) + Dv + ;
							AllTrim(Iif( TRB100->CLIFOR $ cUniao + '|' + cMunic + '|' + cSecEst .And. TRB100->RECPAG == 'P', __cCpf, AllTrim(cCnpj) ) ) + Dv + Iif( TRB100->TPDOC $ MVPAGANT .Or. (( TRB100->E5_MOTBX == "CMP".And. cTpCmp $ MVPAGANT ) .And. TRB100->RECPAG == 'P' .And. !(TRB100->E5_TIPO $  MV_CPNEG) ), '3|0000000000000000|' + cValor, ;
							Iif( TRB100->TPDOC $ MVRECANT .Or. ((TRB100->E5_MOTBX == 'CMP' .And. cTpCmp $ MVRECANT) .And. TRB100->RECPAG == 'R' .And. !(TRB100->E5_TIPO $  MV_CRNEG) ), '3|' + cValor + '|0000000000000000', Iif( ( ( TRB100->RECPAG == 'R' .And. TRB100->TPDOC # MVRECANT ) .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG, ;
							"1|" + cValor + "|0000000000000000", "2|0000000000000000|" + cValor ) ) ) + Dv + cSaldo + Dv + cNatSld + ENTER
					
					nQtdLin++

					If !Empty(TRB100->REC) .And. TRB100->E5_MOTBX == 'CMP' .And. !( TRB100->TPDOC $ 'JR|DC' )
						SE5->(DbGoTo(TRB100->REC))
						If SE5->E5_VLACRES > 0
							lDespCmpA	:= .T.
							nVlAcCmp	:= SE5->E5_VLACRES * 100
							nSaldo 		+= Iif( ( TRB100->RECPAG == 'R' .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG .And. nVlAcCmp > 0, nVlAcCmp, ( nVlAcCmp * -1 ) )
							cNatSld		:= Iif( nSaldo < 0, "N", "P")

							cVlAcCmp 	:= IIf(Abs(nVlAcCmp) >= 100 , AllTrim(Str(Abs(nVlAcCmp))) ,  Padl(AllTrim(Str(Abs(nVlAcCmp))), nTamSx3 , "0"))
							cSaldo 		:= IIf(Abs(nSaldo) >= 100 , AllTrim(Str(Abs(nSaldo))) ,  Padl(AllTrim(Str(Abs(nSaldo))), nTamSx3 , "0"))

							cLinha	+= BLQ100 + Dv + TRB100->DIA + TRB100->MES_ANO + Dv + TRB100->FILCOD + Dv + cCodBco + Dv + cNumDoc + Dv + '6' + Dv + ;
								Iif( __lImpHist, cHist + " - " + Iif( TRB100->RECPAG == 'R', STR0027, STR0029), Iif(nCaso == 1 .Or. lTipoVA , cHist + If(!Empty(cHistC), " - " + cHistC, "") + " - " + Iif( TRB100->RECPAG == 'R', STR0027, STR0029), cHist + " - " + Iif( TRB100->RECPAG == 'R', STR0027, STR0029) ) ) + Dv + ;
								AllTrim(Iif( TRB100->CLIFOR $ cUniao + '|' + cMunic + '|' + cSecEst .And. TRB100->RECPAG == 'P', __cCpf, AllTrim(cCnpj) ) ) + Dv + ;
								Iif( TRB100->TPDOC $ MVPAGANT .Or. (( cTpCmp $ MVPAGANT ) .And. TRB100->RECPAG == 'P' .And. !(TRB100->E5_TIPO $  MV_CPNEG) ), '3|0000000000000000|' + cVlAcCmp, ;
								'3|' + cVlAcCmp + '|0000000000000000') + Dv + cSaldo + Dv + cNatSld + ENTER
						
							nQtdLin++
						EndIf
						If SE5->E5_VLDESCO > 0
							lDespCmpD	:= .T.
							nVlAcCmp	:= SE5->E5_VLDESCO * 100
							nSaldo 		-= Iif( ( TRB100->RECPAG == 'R' .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG .And. nVlAcCmp > 0, nVlAcCmp, ( nVlAcCmp * -1 ) )
							cNatSld		:= Iif( nSaldo < 0, "N", "P")										

							cVlAcCmp 	:= IIf(Abs(nVlAcCmp) >= 100 , AllTrim(Str(Abs(nVlAcCmp))) ,  Padl(AllTrim(Str(Abs(nVlAcCmp))), nTamSx3 , "0"))
							cSaldo 		:= IIf(Abs(nSaldo) >= 100 , AllTrim(Str(Abs(nSaldo))) ,  Padl(AllTrim(Str(Abs(nSaldo))), nTamSx3 , "0"))

							cLinha	+= BLQ100 + Dv + TRB100->DIA + TRB100->MES_ANO + Dv + TRB100->FILCOD + Dv + cCodBco + Dv + cNumDoc + Dv + '6' + Dv + ;
								Iif( __lImpHist, cHist + " - " + Iif( TRB100->RECPAG == 'R', STR0026, STR0028), Iif(nCaso == 1 .Or. lTipoVA , cHist + If( !Empty(cHistC), " - " + cHistC, "" ) + " - " + Iif( TRB100->RECPAG == 'R', STR0026, STR0028), cHist + " - " + Iif( TRB100->RECPAG == 'R', STR0026, STR0028) ) ) + Dv + ;
								AllTrim(Iif( TRB100->CLIFOR $ cUniao + '|' + cMunic + '|' + cSecEst .And. TRB100->RECPAG == 'P', __cCpf, AllTrim(cCnpj) ) ) + Dv + ;
								Iif( TRB100->TPDOC $ MVPAGANT .Or. (( TRB100->E5_MOTBX == "CMP".And. cTpCmp $ MVPAGANT ) .And. TRB100->RECPAG == 'P' .And. !(TRB100->E5_TIPO $  MV_CPNEG) ), '3|' + cVlAcCmp + '|0000000000000000', ;
								'3|0000000000000000|' + cVlAcCmp ) + Dv + cSaldo + Dv + cNatSld + ENTER
						
							nQtdLin++
						EndIf
					EndIf
  
					If __lFunrural .And. !lTipoVA
						If lPJNRural .And. TRB100->RECPAG == 'R'
							__nVlFun 	:= __nVlFun * nProp
							If Abs(Round(__nVlFun, 2) ) > 0 
								nSaldo 		-= Val(StrTran(Transform(ABS(__nVlFun), cPict), ".", "") )
								__nVlFun	:= Val(StrTran(Transform( __nVlFun, cPict), ".", "") )
								cVlFun := IIf(Abs(__nVlFun) >= 100 , AllTrim(Str(Abs(__nVlFun))) ,  Padl(AllTrim(Str(Abs(__nVlFun))), nTamSx3 , "0"))
								cSaldo := IIf(Abs(nSaldo) >= 100 , AllTrim(Str(Abs(nSaldo))) ,  Padl(AllTrim(Str(Abs(nSaldo))), nTamSx3 , "0"))
							
								cLinha	+= BLQ100 + Dv + TRB100->DIA + TRB100->MES_ANO + Dv + TRB100->FILCOD + Dv + "999" + Dv + cNumDoc + Dv + TPDOCOU + Dv + ;
									Iif( __lImpHist, cHist, Iif(nCaso == 1 .And. TRB100->E1_VLCRUZ > 0 .And. ( ( TRB100->E1_VLCRUZ * 100 )/ nProp ) <> nValor, cHist, ;
									Iif( nCaso == 1 .And. TRB100->E2_VLCRUZ > 0 .And. ( ( TRB100->E2_VLCRUZ * 100 )/ nProp ) <> nValor, cHist, cHist ) ) ) + Dv + ;
									AllTrim(Iif( TRB100->CLIFOR $ cUniao + '|' + cMunic + '|' + cSecEst .And. TRB100->RECPAG == 'P', __cCpf, AllTrim(cCnpj) ) ) + Dv + "2|0000000000000000|" + cVlFun + Dv + cSaldo + Dv + Iif( nSaldo - __nVlFun < 0, "N", "P") + ENTER

								nQtdLin++
							EndIf
						Else
							__nVlFun	:= 0
						EndIf
					EndIf
					
					__nVlFun:= Abs(Round(__nVlFun, 2) )
					If !Empty(cOldMes)						
						If cMes != cOldMes
							nSaldoR	:= 0
							nSaldoP	:= 0
							If (( TRB100->RECPAG == 'R' .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG)
								nSaldoR := Abs(nValor)
								nSld200	+= nSaldoR
								If lDespCmpA
									nSaldoR += nVlAcCmp
									nSld200	+= nVlAcCmp
								EndIf
								If lDespCmpD
									nSaldoP += ( nVlAcCmp * -1 )
									nSld200	+= ( nVlAcCmp * -1 )
								EndIf
								If __lFunrural
									nSaldoP += ( __nVlFun * -1 )
									nSld200	+= ( __nVlFun * -1 )
								Else
									nSaldoP	:= 0
								EndIf
							Else
								nSaldoP := ( nValor * -1 )
								nSld200	+= nSaldoP
								If lDespCmpA
									nSaldoP += ( nVlAcCmp * -1 )
									nSld200	+= ( nVlAcCmp * -1 )
								EndIf
								If lDespCmpD
									nSaldoR += nVlAcCmp
									nSld200	+= nVlAcCmp								
								EndIf
								If __lFunrural
									nSaldoP += ( __nVlFun * -1 )
									nSld200	+= ( __nVlFun * -1 )
								EndIf
							EndIf
							
					 		cOldMes := cMes
					 		cLin200	+= cLinAux
							
							cNatSld	:= Iif( nSld200 < 0, "N", "P")
							cSaldoR := IIf(nSaldoR >= 100 .Or. nSaldoR <= -1 , AllTrim(Str(Abs(nSaldoR))) ,  Padl(AllTrim(Str(Abs(nSaldoR))), nTamSx3 , "0"))
							cSaldoP := IIf(Abs(nSaldoP) >= 100 , AllTrim(Str(Abs(nSaldoP))) ,  Padl(AllTrim(Str(Abs(nSaldoP))), nTamSx3 , "0"))
							cSld200 := IIf(Abs(nSld200) >= 100 , AllTrim(Str(Abs(nSld200))) ,  Padl(AllTrim(Str(Abs(nSld200))), nTamSx3 , "0"))
							
							cLinAux	:= BLQ200 + Dv + TRB100->MES_ANO + Dv + cSaldoR + Dv + cSaldoP + Dv + ;
					 					cSld200 + Dv + cNatSld + ENTER
							nQtdLin++
						Else
							If ( TRB100->RECPAG == 'R' .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG
								nSaldoR += Abs(nValor)
								nSld200	+= nValor
								If lDespCmpA
									nSaldoR += nVlAcCmp
									nSld200	+= nVlAcCmp
								EndIf
								If lDespCmpD
									nSaldoP += ( nVlAcCmp * -1 )
									nSld200	+= ( nVlAcCmp * -1 )
								EndIf
								If __lFunrural
									nSaldoP += ( __nVlFun * -1 )
									nSld200	+= ( __nVlFun * -1 )
								EndIf
							Else
								nSaldoP += ( nValor * -1 )
								nSld200	-= nValor
								If lDespCmpA
									nSaldoP += ( nVlAcCmp * -1 )
									nSld200	+= ( nVlAcCmp * -1 )
								EndIf
								If lDespCmpD
									nSaldoR += nVlAcCmp
									nSld200	+= nVlAcCmp								
								EndIf
								If __lFunrural
									nSaldoP += ( __nVlFun * -1 )
									nSld200	+= ( __nVlFun * -1 )
								EndIf
							EndIf
						
							cNatSld	:= Iif( nSld200 < 0, "N", "P")
							cSaldoR := IIf(nSaldoR >= 100 .Or. nSaldoR <= -1 , AllTrim(Str(Abs(nSaldoR))) ,  Padl(AllTrim(Str(Abs(nSaldoR))), nTamSx3 , "0"))
							cSaldoP := IIf(Abs(nSaldoP) >= 100 , AllTrim(Str(Abs(nSaldoP))) ,  Padl(AllTrim(Str(Abs(nSaldoP))), nTamSx3 , "0"))
							cSld200 := IIf(Abs(nSld200) >= 100 , AllTrim(Str(Abs(nSld200))) ,  Padl(AllTrim(Str(Abs(nSld200))), nTamSx3 , "0"))
							
							cLinAux	:= BLQ200 + Dv + TRB100->MES_ANO + Dv + cSaldoR + Dv + cSaldoP + Dv + ;
					 					cSld200 + Dv + cNatSld + ENTER
						
					 	EndIf
					 	
					Else
						cOldMes := cMes
						If ( TRB100->RECPAG == 'R' .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG
							nSaldoR := Abs(nValor)
							nSld200	+= nSaldoR
							If lDespCmpA
								nSaldoR += nVlAcCmp
								nSld200	+= nVlAcCmp
							EndIf
							If lDespCmpD
								nSaldoP += ( nVlAcCmp * -1 )
								nSld200	+= ( nVlAcCmp * -1 )
							EndIf
							If __lFunrural
								nSaldoP += ( __nVlFun * -1 )
								nSld200	+= ( __nVlFun * -1 )
							EndIf	
						Else
							nSaldoP := ( nValor * -1 )
							nSld200	+= nSaldoP
							If lDespCmpA
								nSaldoP += ( nVlAcCmp * -1 )
								nSld200	+= ( nVlAcCmp * -1 )
							EndIf
							If lDespCmpD
								nSaldoR += nVlAcCmp
								nSld200	+= nVlAcCmp
							EndIf
							If __lFunrural
								nSaldoP += ( __nVlFun * -1 )
								nSld200	+= ( __nVlFun * -1 )
							EndIf
						EndIf						
						
						cNatSld	:= Iif( nSld200 < 0, "N", "P")
						cSaldoR := IIf(nSaldoR >= 100 .Or. nSaldoR <= -1 , AllTrim(Str(Abs(nSaldoR))) ,  Padl(AllTrim(Str(Abs(nSaldoR))), nTamSx3 , "0"))
						cSaldoP := IIf(Abs(nSaldoP) >= 100 , AllTrim(Str(Abs(nSaldoP))) ,  Padl(AllTrim(Str(Abs(nSaldoP))), nTamSx3 , "0"))
						cSld200 := IIf(Abs(nSld200) >= 100 , AllTrim(Str(Abs(nSld200))) ,  Padl(AllTrim(Str(Abs(nSld200))), nTamSx3 , "0"))
						
						cLinAux	:= BLQ200 + Dv + TRB100->MES_ANO + Dv + cSaldoR + Dv + cSaldoP + Dv + ;
					 					cSld200 + Dv + cNatSld + ENTER
						
					EndIf
					
					TRB100->(DbSkip())
				Else
					TRB100->(DbSkip())
				EndIf
			EndDo
			
			If !Empty(cMes) .And. cMes == cOldMes
				cLin200	+= cLinAux
				nQtdLin++
			EndIf
			
			TRB100->(DbCloseArea())
			
			PrintLn(nHdl, cLinha)

			PrintLn(nHdl, cLin200)
				
			// Imprimir contador (Bl. 9999 - Encerramento)
			cLinha 		:= ""
							
			If Len(AllTrim(aContador[2])) > 0
				cFiliais	:= ""
				cFiliais	:= "%CVB_FILIAL = '" + aContador[1] + "' %"
					
				ArqTmp( '3',, aContador, cFiliais )
				
				If !(__cTmpCVB)->(Bof()) .And. !(__cTmpCVB)->(Eof())
								
					cLinha	:= BL9999 + Dv + AllTrim((__cTmpCVB)->CVB_NOME) + Dv + AllTrim(Iif(!Empty((__cTmpCVB)->CVB_CPF), (__cTmpCVB)->CVB_CPF, (__cTmpCVB)->CVB_CGC)) + Dv ;
							+ AllTrim((__cTmpCVB)->CVB_CRC) + Dv + SubStr( AllTrim((__cTmpCVB)->CVB_EMAIL), 1, 115 ) + Dv + SubStr( AllTrim((__cTmpCVB)->CVB_TEL), 1, 15 ) + Dv
				Else
					cLinha	:= BL9999 + Dv + Dv + Dv + Dv + Dv + Dv
				EndIf
				nQtdLin++
				
				(__cTmpCVB)->(DbCloseArea())
			Else
				cLinha	:= BL9999 + Dv + Dv + Dv + Dv + Dv + Dv
				nQtdLin++
			EndIf
			cLinha += AllTrim(Str(nQtdLin))
				
			PrintLn(nHdl, cLinha)
				
		EndIf
		
		If FClose(nHdl) .And. __lPrinted
			If __lCsv
				If __CopyFile( Lower(__cDir + __cArq) + "." + EXT, Lower(__cDir + __cArq) + ".csv" )
					FPntVirg(Lower(__cDir + __cArq))
				Else
					MsgAlert("Falha na criação do .CSV: " + Str(Ferror()), "ARQCSV")
				EndIf
			EndIf
			lRet	:= .T.
		EndIf
	Else
		Help(' ',1, STR0007,, STR0008 + ENTER + STR0009 + ENTER + STR0010 + ENTER + __cDir,2,0,,,,,,) // "Falha na geração do arquivo." ## "Verifique se o diretório existe " ## " ou se o arquivo já existe nesse diretório" ## " e / ou se esse usuário tem acesso de gravação no diretório: " 
	EndIf
	
Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} PrintLn

Imprime a linha no arquivo do Extrator do Livro Caixa
	Digital do Produtor Rural

@sample	LCDPR
@return		
@author		Rodrigo Oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function PrintLn(nHdl As Numeric, cLinha As Character)
	FWrite(nHdl, cLinha)
	__lPrinted	:= .T.
Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ArqTmp

Consulta dados para a geração do arquivo LCDPR

@sample	LCDPR
@return		
@author		Rodrigo Oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ArqTmp(cQry As Character, aSelFil As Array, aContador As Array, cFiliais As Character, aParamIni As Array, cDtPeriodo As Character, lDevolNF As Logical)
	Local cCampos	As Character
	Local cQuery	As Character
	Local cQryAux	As Character
	Local cQryFix	As Character
	Local cCond		As Character
	Local cCondAux	As Character
	Local cNatPis	As Character
	Local cNatCof	As Character
	Local cNatCsl	As Character
	Local cNatSes	As Character
	Local cNatIss	As Character
	Local cNatIns	As Character
	Local cNatIrf	As Character
	Local cTamSEV 	As Character
	Local cTamSE5 	As Character
	Local cTamSED 	As Character
	Local cTamSA6 	As Character
	Local cTamSA1 	As Character
	Local cTamSA2 	As Character
	Local cTamSE1 	As Character
	Local cTamSE2	As Character
	Local cTamSF1 	As Character
	Local cTamSF2	As Character
	Local cSelUsr	As Character
	Local cHist		As Character
	Local cPercPE	As Character
	Local aAretPE	As Array
	Local aParPE	As Array
	Local nLOEmp	As Numeric
	Local nLOUnN	As Numeric
	Local nLOFil	As Numeric
	Local nPosFim	As Numeric
	Local nPosIni	As Numeric
	Local nI		As Numeric
	Local lE5Cgc	As Logical
	Local lJoin		As Logical
	Local cTmpFil   as Character 
	Local cTmpBco	as Character
	Local aFldTRB	as Array
	Local nLoop		as Numeric
	Local cFields	as Character
	Local cReplace	as Character
	Local cCampoChq as Character
	Local cJoin		as Character
	Local cCpoPE	As Character
	Local cDtVigIni	As Character
	Local cDtVigFim As Character
	Local cHistPE	As Character
	Local lHistOri	As Logical

	Default aSelFil		:= {}
	Default aContador	:= {}
	Default aParamIni	:= {}
	
	cCampos		:= ""
	cQuery		:= ""
	cQryAux		:= ""
	cQryFix		:= ""
	cCond		:= ""
	cCondAux	:= ""
	cSelUsr		:= ""
	cHist		:= ""
	cPercPE		:= ""
	cJoin		:= ""
	cCpoPE		:= ""
	cTamSEV 	:= "0"
	cTamSE5 	:= "0"
	cTamSED 	:= "0"
	cTamSA6 	:= "0"
	cTamSA1 	:= "0"
	cTamSA2 	:= "0"
	cTamSE1 	:= "0"
	cTamSE2		:= "0"
	cTamSF1		:= "0"
	cTamSF2		:= "0"
	nLOEmp		:= 0
	nLOUnN		:= 0
	nLOFil		:= 0
	nPosFim		:= 0
	nPosIni		:= 0
	aAretPE		:= {}
	aParPE		:= {}
	cTmpFil		:= ""
	cTmpBco		:= ""
	cCampoChq 	:= Padr("", TamSX3("E5_NUMCHEQ")[1])
	cDtVigIni	:= ""
	cDtVigFim	:= ""
	cHistPE		:= ""
	lHistOri	:= .T.

	Do Case
		Case cQry == '1'	 // Imóveis
			If !Empty(cFiliais)
				__cTmpFVV	:= GetNextAlias()
				cDtVigIni	:= "%'" + DTOS(aParamIni[7]) + "'%"
				cDtVigFim	:= "%'" + DTOS(aParamIni[8]) + "'%"
				cOrder		:= '%FVV_FILIAL, FVV_CODIGO, FVV_VERSAO%'
				BeginSql Alias __cTmpFVV
					Select FVV_FILIAL, FVV_PAIS, FVV_MOEDA, FVV_CAFIR, FVV_CAEPF CAEPF, FVV_INSCR IE, FVV_NOME, FVV_END, FVV_NUM, '0000' AS NUMIMO, FVV_VERSAO,
						FVV_COMPL, FVV_BAIRRO, FVV_UF AS UF, FVV_CODMUN, FVV_CEP, FVV_TIPOEX TIPO, FVV_PARTIC PERC, FVV_CODIGO, FVU_CNPJ, 'FVV' AS TAB, ' ' AS TPPES, FVV_VIGINI, FVV_VIGFIM
					 From %Table:FVV% FVV,
					 	%Table:FVU% FVU
					 where %Exp:cFiliais%
					 	And ( FVV_CODPES = FVU_CODIGO 
					 	And FVU_CNPJ = %Exp:__cCpf% )
						And ( ( FVV_VIGFIM = ' ' And FVV_VIGINI <= %Exp:cDtVigFim% )
						Or ( (%Exp:cDtVigIni% BETWEEN FVV_VIGINI AND FVV_VIGFIM )
						Or (%Exp:cDtVigFim% BETWEEN FVV_VIGINI AND FVV_VIGFIM ) ) )
					 	And FVV.%NotDel%
					 	And FVU.%NotDel%
					Union
					Select FVV_FILIAL, FVV_PAIS, FVV_MOEDA, FVV_CAFIR, FVG_CAEPF AS CAEPF, FVV_INSCR IE, FVV_NOME, FVV_END, FVV_NUM, '0000' AS NUMIMO, FVG_VERSAO,
						FVV_COMPL, FVV_BAIRRO, FVV_UF AS UF, FVV_CODMUN, FVV_CEP, FVG_TIPO TIPO, FVG_PERC PERC, FVV_CODIGO, FVU_CNPJ, 'FVGMN' AS TAB, FVG_TPPES AS TPPES, FVV_VIGINI, FVV_VIGFIM
					 From %Table:FVV% FVV,
					 	%Table:FVU% FVU,
					 	%Table:FVG% FVG
					 where %Exp:cFiliais%
					 	And FVG_NUMIMO = '000'
					 	And ( FVG_CODPES = FVU_CODIGO
					 	And FVG_CODIMO = FVV_CODIGO
					 	And FVU_CNPJ = %Exp:__cCpf% )
					 	And FVG_TPPES = '1'
						
						And ( ( FVV_VIGFIM = ' ' And FVV_VIGINI <= %Exp:cDtVigFim% )
						Or ( (%Exp:cDtVigIni% BETWEEN FVV_VIGINI AND FVV_VIGFIM )
						Or (%Exp:cDtVigFim% BETWEEN FVV_VIGINI AND FVV_VIGFIM )) )
					 	
						And FVV_VERSAO = FVG_VERSAO
					 	And FVV.%NotDel%
					 	And FVU.%NotDel%
					 	And FVG.%NotDel%
					 Order By %Exp:cOrder%
				EndSql
			EndIf
		Case cQry == '2'	// Terceiros
			If !Empty(cFiliais)			
				__cTmpFVG := GetNextAlias()
				cDtVigIni	:= "%'" + DTOS(aParamIni[7]) + "'%"
				cDtVigFim	:= "%'" + DTOS(aParamIni[8]) + "'%"
				
				cOrder	:= '%FVV_FILIAL%'
				BeginSql Alias __cTmpFVG
					Select FVV_FILIAL, FVV_TIPOEX TIPO, FVU_CNPJ, FVU_NOME, FVV_PARTIC PERC, 'FVV' AS TAB, ' ' AS TPPES, '000' AS NUMIMO, FVV_VIGINI, FVV_VIGFIM, FVV_VERSAO VER
					 From %Table:FVV% FVV,  
					 	%Table:FVU% FVU,
					 	%Table:FVG% FVG  
					 where  %Exp:cFiliais%
						And FVV_VERSAO = FVG_VERSAO
					 	And FVV_CODIGO = FVG_CODIMO
					    And FVU_CODIGO = FVV_CODPES 
					    And ( FVV_VIGFIM = ' ' Or ( (%Exp:cDtVigIni% BETWEEN FVV_VIGINI AND FVV_VIGFIM )
						Or (FVV_VIGFIM <= %Exp:cDtVigFim% )) )
						And FVV.%NotDel%
					    And FVU.%NotDel%
					    And FVG.%NotDel%
					UNION
					Select FVV_FILIAL, FVG_TIPO TIPO, FVU_CNPJ, FVU_NOME, FVG_PERC PERC, 'FVG' AS TAB, FVG_TPPES AS TPPES, FVG_NUMIMO AS NUMIMO, FVV_VIGINI, FVV_VIGFIM, FVG_VERSAO VER
					 From %Table:FVG% FVG,
					 	%Table:FVV% FVV,
					 	%Table:FVU% FVU
					 where %Exp:cFiliais%
					  	And FVV_CODIGO = FVG_CODIMO
					  	And FVU_CODIGO = FVG_CODPES
						And FVV_VERSAO = FVG_VERSAO
						And ( FVV_VIGFIM = ' ' Or ( (%Exp:cDtVigIni% BETWEEN FVV_VIGINI AND FVV_VIGFIM )
						Or (FVV_VIGFIM <= %Exp:cDtVigFim% )) )
					 	
					 	And FVG.%NotDel%
					 	And FVV.%NotDel%
					 	And FVU.%NotDel%
					 Order By %Exp:cOrder%
				EndSql
			EndIf
						
		Case cQry == '3'	// Dados do contabilista responsável pela declaração
			If !Empty(cFiliais)
				__cTmpCVB := GetNextAlias()
				
				BeginSql Alias __cTmpCVB
					Select CVB_NOME, CVB_CPF, CVB_CGC, CVB_CRC, CVB_EMAIL, CVB_TEL
					 From %Table:CVB% CVB
					 where %Exp:cFiliais%
					  	And CVB_CODCTB = %Exp:aContador[2]%
					 	And CVB.%NotDel%
				EndSql
			EndIf
		OtherWise

			cTmpFil := __oTmpFil:GetRealName()
			cTmpBco := __oTmpBco:GetRealName()
			lE5Cgc	:= SE5->(ColumnPos('E5_CGC') ) > 0
			lJoin	:= .F.

			nLOEmp	:= Len(FWSM0LayOut(,1))
			nLOUnN	:= Len(FWSM0LayOut(,2))
			nLOFil	:= Len(FWSM0LayOut(,3))

			cTamSEV := ModeAccess( "SEV", nLOEmp, nLOUnN, nLOFil )
			cTamSE5 := ModeAccess( "SE5", nLOEmp, nLOUnN, nLOFil )
			cTamSED := ModeAccess( "SED", nLOEmp, nLOUnN, nLOFil )
			cTamSA6 := ModeAccess( "SA6", nLOEmp, nLOUnN, nLOFil )
			cTamSA1 := ModeAccess( "SA1", nLOEmp, nLOUnN, nLOFil )
			cTamSA2 := ModeAccess( "SA2", nLOEmp, nLOUnN, nLOFil )
			cTamSE1 := ModeAccess( "SE1", nLOEmp, nLOUnN, nLOFil )
			cTamSE2 := ModeAccess( "SE2", nLOEmp, nLOUnN, nLOFil )
			cTamSF1 := ModeAccess( "SF1", nLOEmp, nLOUnN, nLOFil )
			cTamSF2 := ModeAccess( "SF2", nLOEmp, nLOUnN, nLOFil )

			If __nFilSE5 == Nil
				__nFilSE5	:= Val(cTamSE5)
			EndIf
			If __nFilSE1 == Nil
				__nFilSE1	:= Val(cTamSE1)
			EndIf
			If __nFilSE2 == Nil
				__nFilSE2	:= Val(cTamSE2)
			EndIf
			If __nFilSF1 == Nil
				__nFilSF1	:= Val(cTamSF1)
			EndIf
			If __nFilSF2 == Nil
				__nFilSF2	:= Val(cTamSF2)
			EndIf

			If __cTamSE5 == Nil
				__cTamSE5	:= cTamSE5
			EndIf
			If __cTamSEF == Nil
				__cTamSEF	:= ModeAccess( "SEF", nLOEmp, nLOUnN, nLOFil )
			EndIf
	
			cNatPis	:= SuperGetMV("MV_PISNAT",,"PIS")
			cNatSes	:= SuperGetMV("MV_SEST",,"SEST")
			cNatIss	:= SuperGetMV("MV_APURISS",,"ISS")
			cNatCof	:= SuperGetMV("MV_COFINS",,"COFINS")
			cNatCsl	:= SuperGetMV("MV_CSLL",,"CSLL")
			cNatIns	:= StrTran(SuperGetMV("MV_INSS",,"INSS"), '"', "")
			cNatIrf	:= StrTran(SuperGetMV("MV_IRF",,"IRF"), '"', "")
			
			aAdd(aParPE, {__cCpf, aParamIni, cDtPeriodo, __oTmpBco, __oTmpFil, cTamSEV, cTamSE5, cTamSED, cTamSA6, ;
			 cTamSA1, cTamSA2, cTamSE1, cTamSE2, cNatPis, cNatSes, cNatIss, cNatCof, cNatCsl, cNatIns, cNatIrf, lE5Cgc} )

			aFldTRB := {}
			AADD(aFldTRB,{"DIA","C",2,0})
			AADD(aFldTRB,{"MES_ANO","C",6,0})
			AADD(aFldTRB,{"DDATA","C",8,0})
			AADD(aFldTRB,{"FILCOD","C",3,0})
			AADD(aFldTRB,{"PERC","N",TAMSX3("FVV_PARTIC")[1],TAMSX3("FVV_PARTIC")[2]})
			AADD(aFldTRB,{"BANCO","C",3,0})
			AADD(aFldTRB,{"PREFIXO","C",TAMSX3("E1_PREFIXO")[1],0})
			AADD(aFldTRB,{"NUMDOC","C",TAMSX3("E5_NUMERO")[1],0})
			AADD(aFldTRB,{"HIST","C",255,0})
			AADD(aFldTRB,{"CNPJCLI","C",TAMSX3("A1_CGC")[1],0})
			AADD(aFldTRB,{"PAISCLI","C",TAMSX3("A1_PAIS")[1],0})
			AADD(aFldTRB,{"CNPJFOR","C",TAMSX3("A2_CGC")[1],0})
			AADD(aFldTRB,{"PAISFOR","C",TAMSX3("A2_PAIS")[1],0})
			AADD(aFldTRB,{"TPDOC","C",TAMSX3("E5_TIPODOC")[1],0})
			AADD(aFldTRB,{"E5_TIPO","C",TAMSX3("E5_TIPO")[1],0})
			AADD(aFldTRB,{"RECPAG","C",1,0})
			AADD(aFldTRB,{"E1_VLCRUZ","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"E2_VLCRUZ","N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]})
			AADD(aFldTRB,{"SLDREC","N",TAMSX3("E2_SALDO")[1],TAMSX3("E2_SALDO")[2]})
			AADD(aFldTRB,{"SLDPAG","N",TAMSX3("E2_SALDO")[1],TAMSX3("E2_SALDO")[2]})
			AADD(aFldTRB,{"E5_MOTBX","C",TAMSX3("E5_MOTBX")[1],0})
			AADD(aFldTRB,{"REC","N",10,0})
			AADD(aFldTRB,{"CLIFOR","C",TAMSX3("E5_CLIFOR")[1],0})
			AADD(aFldTRB,{"VALOR","N",TAMSX3("E5_VALOR")[1],TAMSX3("E5_VALOR")[2]})
			AADD(aFldTRB,{"CGC","C",TAMSX3("E5_CGC")[1],0})
			AADD(aFldTRB,{"VLMOED2","N",TAMSX3("E5_VLMOED2")[1],TAMSX3("E5_VLMOED2")[2]})
			AADD(aFldTRB,{"MOEDA","C",TAMSX3("E5_MOEDA")[1],0})
			AADD(aFldTRB,{"ORI","C",TAMSX3("E5_ORIGEM")[1],0})
			AADD(aFldTRB,{"PARC","C",TAMSX3("E5_PARCELA")[1],0})
			AADD(aFldTRB,{"LOJA","C",TAMSX3("E5_LOJA")[1],0})
			AADD(aFldTRB,{"CODEMP","C",1,0})
			AADD(aFldTRB,{"SEFIL","C",TAMSX3("E5_FILIAL")[1],0})
			AADD(aFldTRB,{"RECSF12","N",10,0})
			AADD(aFldTRB,{"VBRUT12","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"VSENA12","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"VINSS12","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"COSOC12","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"NFTOTAL","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"FUNRURAL","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"VLSENAR","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"VALINS","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"VLFETFAC","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})

			oTRB100 := FWTemporaryTable():New( "TRB100" )
			
			cFields := ""
			
			If cDtPeriodo == '1'
				cCampos	:= "SUBSTRING(E5_DATA,7,2) DIA, SUBSTRING(E5_DATA, 5, 2) || SUBSTRING(E5_DATA, 1, 4) MES_ANO, E5_DATA DDATA, "
			Else
				cCampos	:= "SUBSTRING(E5_DTDISPO,7,2) DIA, SUBSTRING(E5_DTDISPO, 5, 2) || SUBSTRING(E5_DTDISPO, 1, 4) MES_ANO, E5_DTDISPO DDATA, "
			EndIf
			cCampos	+= " TRFIL.COD FILCOD, ISNULL(FVV.FVV_PARTIC, FVG.FVG_PERC) AS PERC, ISNULL(TRBCO.COD,'') BANCO, E5_PREFIXO PREFIXO, E5_NUMERO NUMDOC, E5_HISTOR HIST, "
			cCampos	+= " ISNULL(SA1.A1_CGC,'') CNPJCLI, ISNULL(SA1.A1_PAIS,'') PAISCLI, ISNULL(SA2.A2_CGC,' ') CNPJFOR, ISNULL(SA2.A2_PAIS,' ') PAISFOR, E5_TIPODOC TPDOC, E5_TIPO, CASE WHEN (E5_TIPODOC = 'DC' AND E5_RECPAG = 'R')  THEN 'P' WHEN (E5_TIPODOC = 'DC' AND E5_RECPAG = 'P')  THEN 'R' ELSE E5_RECPAG END RECPAG, "
			cCampos	+= " ISNULL(E1_VLCRUZ,0) E1_VLCRUZ, ISNULL(E2_VLCRUZ,0) E2_VLCRUZ, ISNULL(E1_SALDO,0) SLDREC, ISNULL(E2_SALDO,0) SLDPAG, E5_MOTBX, SE5.R_E_C_N_O_ REC, E5_CLIFOR CLIFOR, "
			If SuperGetMV("MV_MULNATR",,".F.") .Or. SuperGetMV("MV_MULNATP",,".F.")
				cCampos	+= " ( ( E5_VALOR + E5_VRETPIS + E5_VRETCOF + E5_VRETCSL + ( CASE WHEN E5_PRETIRF != '1' THEN E5_VRETIRF ELSE 0 END ) + E5_VRETISS + E5_VRETINS + E5_VLDESCO - E5_VLJUROS - E5_VLMULTA ) * ( Select ISNULL( Sum(EV_PERC), 1 ) From " + RetSqlName("SEV") + " SEV "
				cCampos	+= " Inner Join " + RetSqlName ("SED") + " SED "
				If cTamSEV == cTamSED
					cCampos	+= " ON EV_FILIAL = ED_FILIAL "
				ElseIf Val(cTamSED) == 0
					cCampos	+= " ON ED_FILIAL = ' ' "
				ElseIf Val(cTamSEV) > Val(cTamSED)
					cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(EV_FILIAL,1, " + cTamSED + ") "
				Else
					cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(E5_FILORIG,1, " + cTamSED + ") "
				EndIf
				cCampos	+= " AND EV_NATUREZ = ED_CODIGO AND ED_LCDPR = '1' AND SED.D_E_L_E_T_ = '' " 
				cCampos	+= " WHERE " + CompTab("SEV", "EV_FILIAL", , cTamSEV ) + " AND EV_PREFIXO = E5_PREFIXO AND EV_NUM = E5_NUMERO AND EV_PARCELA = E5_PARCELA "
				cCampos	+= " AND EV_CLIFOR = E5_CLIFOR AND EV_LOJA = E5_LOJA AND EV_TIPO = E5_TIPO AND EV_RECPAG = E5_RECPAG "
				cCampos	+= " AND ( ( EV_IDENT = '2' AND EV_SEQ = E5_SEQ ) OR ( EV_IDENT = '1' AND E5_MOTBX IN ( 'CMP', 'CEC' )) ) "
				cCampos	+= " AND EV_SITUACA = ' ' AND SEV.D_E_L_E_T_ = ' ' ) ) AS VALOR"
			Else
				cCampos	+= " ( E5_VALOR + ( E5_VRETPIS + E5_VRETCOF + E5_VRETCSL + ( CASE WHEN E5_PRETIRF != '1' THEN E5_VRETIRF ELSE 0 END ) + E5_VRETISS + E5_VRETINS + E5_VLDESCO - E5_VLJUROS - E5_VLMULTA ) ) AS VALOR"
			EndIf
			If lE5Cgc
				cCampos	+= " , E5_CGC CGC"
			EndIf

			cCampos	+= " , E5_VLMOED2 VLMOED2, E5_MOEDA MOEDA, E5_ORIGEM ORI , E5_PARCELA PARC , E5_LOJA LOJA, '' CODEMP, E5_FILIAL SEFIL "
			cCampos	+= " , ISNULL(CASE "
			cCampos	+= " WHEN E1_VLCRUZ > 0"
			cCampos	+= " THEN SF2IMP.R_E_C_N_O_"
			cCampos	+= " ELSE SF1IMP.R_E_C_N_O_     "
			cCampos	+= " END,0)									  RECSF12 "
			cCampos	+= " , ISNULL(CASE "
			cCampos	+= " WHEN E1_VLCRUZ > 0"
			cCampos	+= " THEN SF2IMP.F2_VALBRUT"
			cCampos	+= " ELSE SF1IMP.F1_VALBRUT     "
			cCampos	+= " END,0)                                   VBRUT12 "
			cCampos	+= " , ISNULL(CASE "
			cCampos	+= " WHEN E1_VLCRUZ > 0"
			cCampos	+= " THEN SF2IMP.F2_VLSENAR"
			cCampos	+= " ELSE SF1IMP.F1_VLSENAR     "
			cCampos	+= " END,0)                                     VSENA12 "
			cCampos	+= " , ISNULL(CASE "
			cCampos	+= " WHEN E1_VLCRUZ > 0 "
			cCampos	+= " THEN SF2IMP.F2_VALINSS"
			cCampos	+= " ELSE SF1IMP.F1_INSS     "
			cCampos	+= " END,0)                                    VINSS12 "
			cCampos	+= " , ISNULL(CASE "
			cCampos	+= " WHEN E1_VLCRUZ > 0"
			cCampos	+= " THEN SF2IMP.F2_CONTSOC"
			cCampos	+= " ELSE SF1IMP.F1_CONTSOC     "
			cCampos	+= " END,0)                                     COSOC12 " 
			cCampos	+= " , NULL NFTOTAL "
			cCampos	+= " , NULL FUNRURAL "
			cCampos	+= " , NULL VLSENAR "
			cCampos	+= " , NULL VALINS "
			cCampos += " , NULL VLFETFAC "
			
			If cDtPeriodo == '1'
				cCond	:= " E5_DATA BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
			Else
				cCond	:= " ( E5_DTDISPO BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "') "
			EndIf
			cCond	+= " AND E5_DTCANBX = ' ' AND E5_MOVCX <> 'S' AND E5_SITUACA != 'C' "
			cCond	+= " AND ( E5_TIPODOC NOT IN " + FormatIn(MVRECANT + "|" + MVPAGANT + "|ES","|") + " ) AND "

			cCond	+= " ((E5_TIPODOC = 'CD' AND E5_VENCTO <= E5_DATA) OR "
			cCond	+= " (E5_TIPODOC != 'CD')) "
			cCond	+= " AND E5_HISTOR NOT LIKE '%" + STR0020 + "%'" // "Baixa Automatica / Lote"
			cCond	+= " AND E5_TIPODOC NOT IN ('D2','J2','TL','M2','VM','CM','C2','ES','VA','E2','TE','TR', 'CB' )"
			If cDtPeriodo == '1'
				cCond	+= " AND ( E5_TIPODOC != 'CH' OR  ( ( E5_TIPODOC = 'CH' AND E5_ORIGEM LIKE 'GPE%') OR ( E5_TIPODOC = 'CH' AND E5_ORIGEM LIKE 'APT%' ) ) ) "
			EndIf
			cCond	+= " AND SE5.R_E_C_N_O_ NOT IN ( SELECT SE5AINC.R_E_C_N_O_ "
			cCond	+= " FROM " + RetSqlName('SE5') + " SE5AINC "
			cCond	+= " WHERE SE5AINC.E5_TIPODOC = 'BA ' AND ( SE5AINC.E5_TIPO IN " + FormatIn(MVRECANT + "|" + MVPAGANT, "|") + " "
			cCond	+= " AND SE5AINC.E5_MOTBX != 'CEC' ) "
			cCond	+= " AND SE5AINC.E5_DOCUMEN = ' ' AND SE5AINC.D_E_L_E_T_ = ' ' ) "
			cCond	+= " AND E5_MOTBX NOT IN ('LIQ', 'DSD', 'DAC' ) "
			If !lDevolNF
				cCond	+= " AND E5_TIPO NOT IN " + FormatIn(MV_CRNEG + "|" + MV_CPNEG, "|") + " "
			EndIf
			cCond	+= " AND E5_SITUACA NOT IN ('C','E','X') AND NOT EXISTS ( "
			cCond	+= "	SELECT SE5ES.E5_NUMERO " 
			cCond	+= "  		FROM "+ RetSqlName("SE5") + " SE5ES " 
			cCond	+= "     		WHERE SE5ES.E5_FILIAL  = SE5.E5_FILIAL "  
			cCond	+= "      			AND SE5ES.E5_PREFIXO = SE5.E5_PREFIXO "
			cCond	+= "     			AND SE5ES.E5_NUMERO  = SE5.E5_NUMERO " 
			If cDtPeriodo == '1'
				cCond	+= "     			AND SE5ES.E5_NUMCHEQ = ' ' "
			EndIf
			cCond	+= "         		AND SE5ES.E5_PARCELA = SE5.E5_PARCELA " 
			cCond	+= "        		AND SE5ES.E5_TIPO    = SE5.E5_TIPO " 
			cCond	+= "     			AND SE5ES.E5_CLIFOR  = SE5.E5_CLIFOR " 
			cCond	+= "          		AND SE5ES.E5_LOJA    = SE5.E5_LOJA " 
			cCond	+= "     			AND SE5ES.E5_SEQ     = SE5.E5_SEQ " 
			cCond	+= "        		AND SE5ES.E5_BANCO   = SE5.E5_BANCO "
			cCond	+= "           		AND SE5ES.E5_AGENCIA = SE5.E5_AGENCIA "
			cCond	+= "        		AND SE5ES.E5_CONTA   = SE5.E5_CONTA "
			cCond	+= "         		AND SE5ES.E5_TIPODOC = 'ES' "
			cCond	+= "           		AND SE5ES.E5_ORIGEM <> 'FINA550 ' "
			cCond	+= "           		AND SE5ES.E5_ORIGEM <> 'FINA100 ' AND SE5ES.E5_KEY NOT LIKE '%PA%' "
			cCond	+= "           		AND SE5ES.D_E_L_E_T_ = ' ' ) "
			cCond	+= " AND SE5.D_E_L_E_T_ = ' ' "
			
			cQryAux	:= " SELECT "
			If __lF820Qry
				aAretPE	:= ExecBlock( "F820Qry",.F., .F., {cCond, cCampos, aParPE})
				If ValType(aAretPE[2]) == 'C'
					cHist 	:= aAretPE[2]
				EndIf
				If ValType(aAretPE[3]) == 'C'
					cSelUsr	:= aAretPE[3]
				EndIf
				If !Empty(AllTrim(cSelUsr))
					nPosFim	:= Rat(" PERC", UPPER(cSelUsr))
					nPosIni	:= Rat(",", SubStr(cSelUsr, 1, nPosFim) )
					cPercPE := AllTrim(SubStr(cSelUsr, nPosIni, nPosFim - nPosIni))
					If Right(UPPER(cPercPE), 2) == "AS"
						cPercPE	:= AllTrim(SubStr(cPercPE, 2, Len(cPercPE) - 3))
					EndIf
					If !Empty(cHist)
						cQryAux 	+= StrTran( cSelUsr, "E5_HISTOR", "ISNULL(Substring(" + cHist + ",1,255), ' ' ) " )
						__lImpHist	:= .T.
					Else
						cQryAux += cSelUsr
					EndIf
				Else
					If !Empty(cHist)
						cQryAux 	+= StrTran( cCampos, "E5_HISTOR", "ISNULL(Substring(" + cHist + ",1,255), ' ' ) ")
						__lImpHist	:= .T.
					Else
						cQryAux += cCampos
					EndIf
				EndIf
				If Len(aAretPE) > 4
					For nI := 1 to Len(aAretPE[5])
						cCpoPE	+= ", " + Iif(aAretPE[5][nI][2] == "C", "' ' ", "0 ") + "AS " + aAretPE[5][nI][1]  
						AADD(aFldTRB,{aAretPE[5][nI][1], aAretPE[5][nI][2], aAretPE[5][nI][3], aAretPE[5][nI][4]})
					Next
				EndIf
			Else
				cQryAux += cCampos
			EndIf
			cQryFix	:= " FROM " + RetSqlName("SE5") + " SE5 "
			cQryFix	+= " INNER JOIN " + RetSqlName("SED") + " SED "
			If cTamSED == cTamSE5
				cQryFix	+= " ON ED_FILIAL = E5_FILIAL "
			Else
				If Val(cTamSED) == 0
					cQryFix	+= " ON ( ED_FILIAL = ' ' "
				Else
					cQryFix	+= " ON ( SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(E5_FILORIG,1, " + cTamSED + ") "
				EndIf
				cQryFix	+= " OR ( (E5_ORIGEM LIKE 'GPE%' AND " + CompTab("SE5", "E5_FILIAL", , cTamSE5) + ") "
				cQryFix	+= " OR (E5_ORIGEM LIKE 'ADT%' AND " + CompTab("SE5", "E5_FILIAL", , cTamSE5) + " ) ) ) "
			EndIf
			cQryFix	+= " AND ED_CODIGO = E5_NATUREZ AND ( ED_LCDPR = '1' ) "
			cQryFix	+= " AND SED.D_E_L_E_T_ = ' ' "
			cQryFix	+= " INNER JOIN " + cTmpFil + " TRFIL "
			cQryFix	+= " ON ( E5_FILORIG IN ( SELECT TRFIL.FILIAL FROM " + cTmpFil + " ) "
			cQryFix	+= " OR ( (E5_ORIGEM LIKE 'GPE%' AND " + CompTab("SE5", "E5_FILIAL", , cTamSE5) + ") "
			cQryFix	+= " OR (E5_ORIGEM LIKE 'ADT%' AND " + CompTab("SE5", "E5_FILIAL", , cTamSE5) + " ) ) ) "

			If cDtPeriodo == '1'
				cQryFix	+= " AND E5_DATA >= TRFIL.DTINI "
				cQryFix	+= " AND E5_DATA <= TRFIL.DTFIM "
				cQryFix	+= " AND SE5.D_E_L_E_T_ = ' ' "

				cQryFix	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV "
				cQryFix	+= " ON TRFIL.FILIAL = FVV_FILIAL AND TRFIL.VER = FVV_VERSAO AND ( FVV_FILIAL = E5_FILORIG "
				cQryFix	+= " AND E5_DATA BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "') "			
				
				cQryFix	+= " AND FVV_CODPES = '" + __cFVUCod + "' AND SE5.D_E_L_E_T_ = ' ' AND FVV.D_E_L_E_T_ = ' ' "

				cQryFix	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = E5_FILORIG "
				cQryFix	+= " AND E5_DATA BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) "
				cQryFix	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
				cQryFix	+= " AND FVG_TPPES = '1' "
				cQryFix	+= " AND FVG_NUMIMO = '000' "
				cQryFix	+= " AND SE5.D_E_L_E_T_ = ' ' "
				cQryFix	+= " AND FVG.D_E_L_E_T_ = ' ' "
			Else
				cQryFix	+= " AND ( E5_DTDISPO >= TRFIL.DTINI "
				cQryFix	+= " AND E5_DTDISPO <= TRFIL.DTFIM) "

				cQryFix	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV "
				cQryFix	+= " ON TRFIL.FILIAL = FVV_FILIAL AND TRFIL.VER = FVV_VERSAO AND ( FVV_FILIAL = E5_FILORIG "

				cQryFix	+= " AND SE5.E5_DTDISPO BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "') "
				
				cQryFix	+= " AND FVV_CODPES = '" + __cFVUCod + "' AND SE5.D_E_L_E_T_ = ' ' AND FVV.D_E_L_E_T_ = ' ' "

				cQryFix	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = SE5.E5_FILORIG "
				cQryFix	+= " AND ( E5_DTDISPO BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) ) "
				cQryFix	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
				cQryFix	+= " AND FVG_TPPES = '1' "
				cQryFix	+= " AND FVG_NUMIMO = '000' "
				cQryFix	+= " AND SE5.D_E_L_E_T_ = ' ' "
				cQryFix	+= " AND FVG.D_E_L_E_T_ = ' ' "

			EndIf
			
			cQryFix	+= " LEFT JOIN " + cTmpBco + " TRBCO "
			cQryFix	+= " ON " + CompTab("TRBCO", "FIL", , cTamSA6)
			cQryFix	+= " AND E5_BANCO = TRBCO.BANCO AND E5_AGENCIA = TRBCO.AGENCIA AND E5_CONTA = TRBCO.CONTA "
			
			cQryFix	+= " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
			If cTamSA1 == cTamSE5
				cQryFix	+= " ON A1_FILIAL = E5_FILIAL "
			Else
				If Val(cTamSA1) == 0
					cQryFix	+= " ON A1_FILIAL = ' ' "
				Else
					cQryFix	+= " ON SUBSTRING(A1_FILIAL,1, " + cTamSA1 + ") = SUBSTRING(E5_FILORIG,1, " + cTamSA1 + ") "
				EndIf
			EndIf
			cQryFix	+= " AND E5_CLIFOR = A1_COD AND E5_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
			
			cQryFix	+= " LEFT JOIN " + RetSqlName("SA2") + " SA2 "
			If cTamSA2 == cTamSE5
				cQryFix	+= " ON A2_FILIAL = E5_FILIAL "
			Else
				If Val(cTamSA2) == 0
					cQryFix	+= " ON A2_FILIAL = ' ' "
				Else
					cQryFix	+= " ON SUBSTRING(A2_FILIAL,1, " + cTamSA2 + ") = SUBSTRING(E5_FILORIG,1, " + cTamSA2 + ") "
				EndIf
			EndIf
			cQryFix	+= " AND E5_CLIFOR = A2_COD AND E5_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "

			cQryFix	+= " LEFT JOIN " + RetSqlName("SE1") + " SE1 "
			cQryFix	+= " ON " + CompTab("SE1", "E1_FILIAL", , cTamSE1)
			cQryFix	+= " AND ( E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM AND E5_PARCELA = E1_PARCELA AND E5_TIPO = E1_TIPO "
			cQryFix	+= " AND E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND E5_TABORI = 'FK1' AND SE1.D_E_L_E_T_ = ' ' ) "
			cQryFix	+= " LEFT JOIN " + RetSqlName("SE2") + " SE2 "
			cQryFix	+= " ON " + CompTab("SE2", "E2_FILIAL", , cTamSE2)
			cQryFix	+= " AND ( E5_PREFIXO = E2_PREFIXO AND E5_NUMERO = E2_NUM AND E5_PARCELA = E2_PARCELA AND E5_TIPO = E2_TIPO " 
			cQryFix	+= " AND E5_CLIFOR = E2_FORNECE AND E5_LOJA = E2_LOJA AND E5_TABORI = 'FK2' AND SE2.D_E_L_E_T_ = ' ' ) "
			cQryFix	+= "LEFT JOIN " + RetSqlName("SF2") + " SF2IMP "
            cQryFix	+= 		"ON SE1.E1_FILORIG = SF2IMP.F2_FILIAL "
            cQryFix	+= 			"AND SE1.E1_CLIENTE = SF2IMP.F2_CLIENTE "
            cQryFix	+=       	"AND SE1.E1_LOJA = SF2IMP.F2_LOJA "
            cQryFix	+=       	"AND SE1.E1_NUM = SF2IMP.F2_DOC "
            cQryFix	+=       	"AND SE1.E1_PREFIXO = SF2IMP.F2_SERIE "
            cQryFix	+=  	  	"AND SE1.D_E_L_E_T_ = ' ' "
			cQryFix	+=       	"AND SF2IMP.D_E_L_E_T_ = ' ' "
			cQryFix	+= "LEFT JOIN " + RetSqlName("SF1") + " SF1IMP "
			cQryFix	+=  	"ON SE2.E2_FILORIG = SF1IMP.F1_FILIAL "
			cQryFix	+= 			"AND SE2.E2_FORNECE = SF1IMP.F1_FORNECE "
			cQryFix	+=  		"AND SE2.E2_LOJA = SF1IMP.F1_LOJA "
			cQryFix	+=  		"AND SE2.E2_NUM = SF1IMP.F1_DOC "
			cQryFix	+=  		"AND SE2.E2_PREFIXO = SF1IMP.F1_SERIE "
			cQryFix	+=  		"AND SE2.D_E_L_E_T_ = ' ' "
			cQryFix	+=       	"AND SF1IMP.D_E_L_E_T_ = ' ' "

			If __lF820Qry
				If Len(aAretPE) > 3 .And. ValType(aAretPE[4]) == 'C'
					cJoin 	:= aAretPE[4]
					lJoin	:= AllTrim(SubStr(cJoin, 1, At(" ", LTrim(cJoin)))) $ 'LEFT|RIGHT|INNER|JOIN'
				EndIf
				
				cCondAux 	:= If( ValType(aAretPE[1]) == 'C', aAretPE[1], "" )
				If !lJoin
					cQryFix	+= "WHERE "
				Else
					cQryFix += cJoin + " WHERE "
				EndIf
				cQryAux	+= cQryFix
					
				If !Empty(cCondAux)
					cQryAux += cCondAux
				Else
					cQryAux += cCond
				EndIf
			Else
				cQryFix	+= "WHERE "
				cQryAux	+= cQryFix
				cQryAux += cCond
			EndIf
			
			cQuery	:= cQryAux
			
			cQryAux	:= ""
			cQryAux	+= " UNION "
			If cDtPeriodo == '1'
				cQryAux	+= " SELECT SUBSTRING(SE1IMP.E1_BAIXA,7,2) DIA, SUBSTRING(SE1IMP.E1_BAIXA, 5, 2) || SUBSTRING(SE1IMP.E1_BAIXA, 1, 4) MES_ANO, SE1IMP.E1_BAIXA DDATA, "
			Else
				cQryAux	+= " SELECT SUBSTRING(E5_DTDISPO,7,2) DIA, SUBSTRING(E5_DTDISPO, 5, 2) || SUBSTRING(E5_DTDISPO, 1, 4) MES_ANO, E5_DTDISPO DDATA, "
			EndIf
			cQryAux	+= " TRFIL.COD FILCOD, "
			
			If !Empty(cPercPE) .And. ( ValType(Val(cPercPE)) == 'N' .And. Val(cPercPE) > 0 )
				cQryAux	+= cPercPE + " AS PERC, "
			Else
				cQryAux	+= " COALESCE(FVV1I.FVV_PARTIC, FVG_PERC) AS PERC, "
			EndIf
			cQryAux	+= " ISNULL(TRBCO.COD,'') BANCO, SE1IMP.E1_PREFIXO PREFIXO, SE1IMP.E1_NUM NUMDOC, SE1IMP.E1_HIST HIST, ISNULL(SA1.A1_CGC,'') CNPJCLI, ISNULL(SA1.A1_PAIS,'') PAISCLI, ' ' CNPJFOR, ' ' PAISFOR, "
			cQryAux	+= " ' ' TPDOC, SE1IMP.E1_TIPO E5_TIPO, 'P' RECPAG,ISNULL( SE1IMP.E1_VLCRUZ,0) E1_VLCRUZ, 0, 0 SLDREC, ISNULL(SE1IMP.E1_SALDO,0) SLDPAG, ' ', 0 REC, SE1IMP.E1_CLIENTE CLIFOR, SE1IMP.E1_VALOR AS VALOR "
			If lE5Cgc
				cQryAux	+= " , ' ' CGC "
			EndIf
			cQryAux	+= " , SE1IMP.E1_VLCRUZ VLMOED2, '0' || CAST(SE1IMP.E1_MOEDA AS VARCHAR(2) ) MOEDA "
			cQryAux	+= " , SE1IMP.E1_ORIGEM ORI, SE1IMP.E1_PARCELA PARC, SE1IMP.E1_LOJA LOJA, ' ' CODEMP, SE1IMP.E1_FILIAL SEFIL "
			cQryAux	+= " , NULL RECSF12 "
			cQryAux	+= " , NULL VBRUT12 "
	   		cQryAux	+= " , NULL VSENA12 " 
	   		cQryAux	+= " , NULL VINSS12 "
	   		cQryAux	+= " , NULL COSOC12 "
			cQryAux	+= " , NULL NFTOTAL "
			cQryAux	+= " , NULL FUNRURAL "
			cQryAux	+= " , NULL VLSENAR "
			cQryAux	+= " , NULL VALINS "
			cQryAux += " , NULL VLFETFAC "
			
			If __lF820Qry
				cQryAux += cCpoPE
			EndIf

			cQryAux	+= " FROM " + RetSqlName("SE1") + " SE1IMP "
			
			cQryAux	+= " INNER JOIN " + cTmpFil + " TRFIL "
			cQryAux	+= " ON SE1IMP.E1_FILORIG IN ( SELECT TRFIL.FILIAL FROM " + cTmpFil + " ) "
			If cDtPeriodo == '1'
				cQryAux	+= " AND SE1IMP.E1_BAIXA >= TRFIL.DTINI "
			EndIf
			
   			cQryAux	+= " AND SE1IMP.E1_BAIXA <= TRFIL.DTFIM "
   			cQryAux	+= " AND SE1IMP.D_E_L_E_T_ = ' ' "

			cQryAux	+= " LEFT JOIN " + cTmpBco + " TRBCO "
			cQryAux	+= " ON " + StrTran( CompTab("TRBCO", "FIL", "SE1", cTamSA6), "E1_FILIAL", "SE1IMP.E1_FILIAL" )
			cQryAux	+= " AND SE1IMP.E1_PORTADO = TRBCO.BANCO AND SE1IMP.E1_AGEDEP = TRBCO.AGENCIA AND SE1IMP.E1_CONTA = TRBCO.CONTA "
			
			cQryAux	+= " INNER JOIN " + RetSqlName("SE1") + " SE1PAI "
			cQryAux	+= " ON SE1IMP.E1_TITPAI = SE1PAI.E1_PREFIXO || SE1PAI.E1_NUM || SE1PAI.E1_PARCELA || SE1PAI.E1_TIPO || SE1PAI.E1_CLIENTE || SE1PAI.E1_LOJA 
			cQryAux	+= " AND SE1PAI.D_E_L_E_T_ = ' ' "
			cQryAux	+= " INNER JOIN " + RetSqlName("SED") + " SED "
			
			If cTamSED == cTamSE1
				cQryAux	+= " ON ED_FILIAL = SE1PAI.E1_FILIAL "
			Else
				If Val(cTamSED) == 0
					cQryAux	+= " ON ED_FILIAL = ' ' "
				Else
					cQryAux	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(SE1PAI.E1_FILORIG,1, " + cTamSED + ") "
				EndIf
			EndIf

			cQryAux += " AND ED_CODIGO = SE1PAI.E1_NATUREZ AND (ED_LCDPR = '1' ) AND SED.D_E_L_E_T_ = ' ' "
			cQryAux	+= " INNER JOIN " + RetSqlName("SA1") + " SA1 "

			If cTamSA1 == cTamSE1
				cQryAux	+= " ON A1_FILIAL = SE1PAI.E1_FILIAL "
			Else
				If Val(cTamSA1) == 0
					cQryAux	+= " ON A1_FILIAL = ' ' "
				Else
					cQryAux	+= " ON SUBSTRING(A1_FILIAL,1, " + cTamSA1 + ") = SUBSTRING(SE1PAI.E1_FILORIG,1, " + cTamSA1 + ") "
				EndIf
			EndIf

			cQryAux	+= " AND SE1PAI.E1_CLIENTE = A1_COD AND SE1PAI.E1_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' "

			cQryAux	+= " Inner Join " + RetSqlName("SE5") + " SE5IP "
			If cTamSE5 == cTamSE1
				cQryAux	+= " ON E5_FILIAL = SE1IMP.E1_FILIAL "
			Else
				If Val(cTamSE5) == 0
					cQryAux	+= " ON E5_FILIAL = ' ' "
				Else
					cQryAux	+= " ON SUBSTRING(SE1IMP.E1_FILIAL,1, " + cTamSE1 + ") = SUBSTRING(SE5IP.E5_FILORIG,1, " + cTamSE1 + ") "
				EndIf
			EndIf
			cQryAux	+= " And SE1IMP.E1_TITPAI = E5_PREFIXO || E5_NUMERO || E5_PARCELA || E5_TIPO || E5_CLIFOR || E5_LOJA"
			If __cLCDPRRA == "D"
				cQryAux	+= " And SE5IP.E5_MOTBX <> 'CMP' "
			EndIf
			cQryAux	+= " And SE5IP.D_E_L_E_T_ = ' '"	
			
			If cDtPeriodo == '1'
				cQryAux	+= " And E5_DATA BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
			Else
				cQryAux	+= " And E5_DTDISPO BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
			EndIf
			
			cQryAux	+= " And E5_SEQ = (Select Max(E5_SEQ) From " + RetSqlName("SE5") + " E5MX "
			cQryAux	+= " Where E5MX.E5_FILIAL = SE5IP.E5_FILIAL"
			cQryAux	+= " And E5MX.E5_PREFIXO = SE5IP.E5_PREFIXO and E5MX.E5_NUMERO = SE5IP.E5_NUMERO"
			cQryAux	+= " And E5MX.E5_PARCELA = SE5IP.E5_PARCELA and E5MX.E5_TIPO = SE5IP.E5_TIPO"
			cQryAux	+= " And E5MX.E5_CLIFOR = SE5IP.E5_CLIFOR and E5MX.E5_LOJA = SE5IP.E5_LOJA"
			cQryAux	+= " And E5MX.D_E_L_E_T_ = ' ')"

			cQryAux	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV1I "
			cQryAux	+= " ON FVV_FILIAL = SE1IMP.E1_FILORIG "
			cQryAux	+= " AND ( ( ( FVV_VIGINI = ' ' AND SE1IMP.E1_BAIXA = SE5IP.E5_DATA ) OR SE1IMP.E1_BAIXA >= FVV_VIGINI ) AND
			cQryAux	+=       " ( ( FVV_VIGFIM = ' ' AND SE1IMP.E1_BAIXA = SE5IP.E5_DATA ) OR SE1IMP.E1_BAIXA <= FVV_VIGFIM ) ) "
			cQryAux	+= " AND SE1IMP.E1_BAIXA = SE5IP.E5_DATA "
			cQryAux	+= " AND FVV1I.FVV_CODPES = '" + __cFVUCod + "' AND SE1IMP.D_E_L_E_T_ = ' ' AND FVV1I.D_E_L_E_T_ = ' ' "

			cQryAux	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = SE1IMP.E1_FILORIG "
			cQryAux	+= " AND SE1IMP.E1_BAIXA = SE5IP.E5_DATA ) "
			cQryAux	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
			cQryAux	+= " AND FVG_TPPES = '1' "
			cQryAux	+= " AND SE1IMP.D_E_L_E_T_ = ' ' "
			cQryAux	+= " AND FVG.D_E_L_E_T_ = ' ' "

			cQryAux	+= " WHERE SE1IMP.E1_SALDO = 0 AND SE1IMP.E1_TIPO IN ('TX ', 'TXA', '"
			cQryAux	+= cNatPis + "', '" + cNatSes + "', '" + cNatIss + "', '" + cNatCof + "', '" + cNatCsl + "', '" + cNatIns + "', '" + cNatIrf + "', 'FB-', 'FC-', 'FU-', 'FE-', 'IN-' , 'IS-' , 'AB-' ) "
			cQryAux	+= " AND SE1IMP.E1_BAIXA = SE5IP.E5_DATA  "
			cQryAux	+= " AND SE1IMP.E1_NUMLIQ = ' ' AND ( SE1IMP.E1_FATURA = '" + Space(Len(SE1->E1_FATURA)) + "' OR SE1IMP.E1_FATURA = 'NOTFAT' ) AND SE1IMP.D_E_L_E_T_ = ' ' "
			
			//SE2
			cQryAux	+= " UNION "
			cQryAux	+= " SELECT SUBSTRING(SE2IMP.E2_BAIXA,7,2) DIA, SUBSTRING(SE2IMP.E2_BAIXA, 5, 2) || SUBSTRING(SE2IMP.E2_BAIXA, 1, 4) MES_ANO, SE2IMP.E2_BAIXA DDATA, TRFIL.COD FILCOD, "
			If !Empty(cPercPE) .And. ( ValType(Val(cPercPE)) == 'N' .And. Val(cPercPE) > 0 )
				cQryAux	+= cPercPE + " AS PERC, "
			Else
				cQryAux	+= " COALESCE(FVV2I.FVV_PARTIC, FVG_PERC) AS PERC, "
			EndIf
			cQryAux	+= " ' ' BANCO, SE2IMP.E2_PREFIXO PREFIXO, SE2IMP.E2_NUM NUMDOC, SE2IMP.E2_HIST HIST, ' ' CNPJCLI, ' ' PAISCLI, '" + __cCpf + "' CNPJFOR, ' ' PAISFOR,"
			cQryAux	+= " ' ' TPDOC, SE2IMP.E2_TIPO E5_TIPO," 
			cQryAux	+= " CASE WHEN SE2IMP.E2_TIPO = 'AB-' THEN 'R' ELSE 'P' END RECPAG," 
			cQryAux	+= " ISNULL(SE2IMP.E2_VLCRUZ,0) E2_VLCRUZ, 0, 0 SLDREC, ISNULL(SE2IMP.E2_SALDO,0) SLDPAG, ' ', 0 REC, SE2IMP.E2_FORNECE CLIFOR, SE2IMP.E2_VALOR AS VALOR "
			If lE5Cgc
				cQryAux	+= " , ' ' CGC "
			EndIf
			cQryAux	+= " , SE2IMP.E2_VLCRUZ VLMOED2, '0' || CAST(SE2IMP.E2_MOEDA AS VARCHAR(2) ) MOEDA "
			cQryAux	+= " , SE2IMP.E2_ORIGEM ORI, SE2IMP.E2_PARCELA PARC, SE2IMP.E2_LOJA LOJA, ' ' CODEMP, SE2IMP.E2_FILIAL SEFIL "
			cQryAux	+= " , NULL RECSF12 "
			cQryAux	+= " , NULL VBRUT12 "
	   		cQryAux	+= " , NULL VSENA12 " 
	   		cQryAux	+= " , NULL VINSS12 "
	   		cQryAux	+= " , NULL COSOC12 "
			cQryAux	+= " , NULL NFTOTAL "
			cQryAux	+= " , NULL FUNRURAL "
			cQryAux	+= " , NULL VLSENAR "
			cQryAux	+= " , NULL VALINS "
			cQryAux += " , NULL VLFETFAC "	   
			
			If __lF820Qry
				cQryAux += cCpoPE
			EndIf

			cQryAux	+= " FROM " + RetSqlName("SE2") + " SE2IMP "
			
			cQryAux	+= " INNER JOIN " + cTmpFil + " TRFIL "
			cQryAux	+= " ON SE2IMP.E2_FILORIG IN ( SELECT TRFIL.FILIAL FROM " + cTmpFil + " ) "
			cQryAux	+= " AND SE2IMP.E2_BAIXA >= TRFIL.DTINI "
   			cQryAux	+= " AND SE2IMP.E2_BAIXA <= TRFIL.DTFIM "
   			cQryAux	+= " AND SE2IMP.D_E_L_E_T_ = ' ' "

			cQryAux	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV2I "
			cQryAux	+= " ON FVV_FILIAL = SE2IMP.E2_FILORIG "
			
			cQryAux	+= " AND ( ( ( FVV_VIGINI = ' ' AND SE2IMP.E2_BAIXA >= '" + DTOS(aParamIni[7]) + "' ) OR SE2IMP.E2_BAIXA >= FVV_VIGINI ) AND
			cQryAux	+= " ( ( FVV_VIGFIM = ' ' AND SE2IMP.E2_BAIXA <= '" + DTOS(aParamIni[8]) + "' ) OR SE2IMP.E2_BAIXA <= FVV_VIGFIM ) ) "
			cQryAux	+= " AND SE2IMP.E2_BAIXA BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
			cQryAux	+= " AND FVV2I.FVV_CODPES = '" + __cFVUCod + "' AND SE2IMP.D_E_L_E_T_ = ' ' AND FVV2I.D_E_L_E_T_ = ' ' "

			cQryAux	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = SE2IMP.E2_FILORIG "
			cQryAux	+= " AND SE2IMP.E2_BAIXA BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) "
			cQryAux	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
			cQryAux	+= " AND FVG_TPPES = '1' "
			cQryAux	+= " AND SE2IMP.D_E_L_E_T_ = ' ' "
			cQryAux	+= " AND FVG.D_E_L_E_T_ = ' ' "

			cQryAux	+= " INNER JOIN " + RetSqlName("SE2") + " SE2PAI "
			cQryAux	+= " ON SE2IMP.E2_TITPAI = SE2PAI.E2_PREFIXO || SE2PAI.E2_NUM || SE2PAI.E2_PARCELA || SE2PAI.E2_TIPO || SE2PAI.E2_FORNECE || SE2PAI.E2_LOJA 
			cQryAux	+= " AND SE2PAI.D_E_L_E_T_ = ' ' "
			cQryAux	+= " INNER JOIN " + RetSqlName("SED") + " SED "
			
			If cTamSED == cTamSE2
				cQryAux	+= " ON ED_FILIAL = SE2PAI.E2_FILIAL "
			Else
				If Val(cTamSED) == 0
					cQryAux	+= " ON ED_FILIAL = ' ' "
				Else
					cQryAux	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(SE2PAI.E2_FILORIG,1, " + cTamSED + ") "
				EndIf
			EndIf

			cQryAux	+= " AND ED_CODIGO = SE2PAI.E2_NATUREZ AND (ED_LCDPR = '1' ) AND SED.D_E_L_E_T_ = ' ' "

			cQryAux	+= " WHERE SE2IMP.E2_SALDO = 0 AND SE2IMP.E2_TIPO IN ('TX ', 'TXA', '"
			cQryAux	+= cNatPis + "', '" + cNatSes + "', '" + cNatIss + "', '" + cNatCof + "', '" + cNatCsl + "', '" + cNatIns + "', '" + cNatIrf + "' , 'AB-' ) "
			cQryAux	+= " AND SE2IMP.E2_BAIXA BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
			cQryAux	+= " AND SE2IMP.E2_NUMLIQ = ' ' AND ( SE2IMP.E2_FATURA = '" + Space(Len(SE2->E2_FATURA)) + "' OR SE2IMP.E2_FATURA = 'NOTFAT' ) AND SE2IMP.D_E_L_E_T_ = ' ' "  

			IF __cLCDPRRA == "D"

				cQryAux	+= " UNION "
				cQryAux	+= " SELECT SUBSTRING(SE1ADTO.E1_EMISSAO,7,2) DIA, SUBSTRING(SE1ADTO.E1_EMISSAO, 5, 2) || SUBSTRING(SE1ADTO.E1_EMISSAO, 1, 4) MES_ANO, SE1ADTO.E1_EMISSAO DDATA, TRFIL.COD FILCOD, " 
				If !Empty(cPercPE) .And. ( ValType(Val(cPercPE)) == 'N' .And. Val(cPercPE) > 0 )
					cQryAux	+= cPercPE + " AS PERC, "
				Else
					cQryAux	+= " COALESCE(FVV1.FVV_PARTIC, FVG_PERC) AS PERC, "
				EndIf
				cQryAux	+= " ISNULL(TRBCO.COD,'') BANCO, SE1ADTO.E1_PREFIXO PREFIXO, SE1ADTO.E1_NUM NUMDOC, "

				//Histórico SE1 - RA
				lHistOri := .T.
				If __lF820Qry .AND. Len(aAretPE) > 5
					cHistPE := aAretPE[6]
					If !Empty(cHistPE) .And. ( ValType(cHistPE) == 'C' )
						cQryAux	+= cHistPE + " AS HIST, "
						lHistOri := .F.
					EndIf
				Endif

				If lHistOri
					cQryAux	+= "  SE1ADTO.E1_HIST HIST, "	
				Endif

				cQryAux	+= " ISNULL(SA1.A1_CGC,'') CNPJCLI, ' ' PAISCLI, ' ' CNPJFOR, ' ' PAISFOR, "
				cQryAux	+= " ' ' TPDOC, SE1ADTO.E1_TIPO E5_TIPO, 'R' RECPAG, SE1ADTO.E1_VALOR, 0, ISNULL(SE1ADTO.E1_SALDO,0) SLDREC, 0 SLDPAG, ' ', 0 REC, SE1ADTO.E1_CLIENTE CLIFOR "
				If SuperGetMV("MV_MULNATR",,".F.")
					cCampos	:= " , E1_VLCRUZ * ( Select ISNULL( Sum(EV_PERC), 1 ) From " + RetSqlName("SEV") + " SEV "
					cCampos	+= " Inner Join " + RetSqlName ("SED") + " SED "
					If cTamSEV == cTamSED
						cCampos	+= " ON EV_FILIAL = ED_FILIAL "
					ElseIf Val(cTamSED) == 0
						cCampos	+= " ON ED_FILIAL = ' ' "
					ElseIf Val(cTamSEV) > Val(cTamSED)
						cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(EV_FILIAL,1, " + cTamSED + ") "
					Else
						cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(E1_FILORIG,1, " + cTamSED + ") "
					EndIf
					cCampos	+= " AND EV_NATUREZ = ED_CODIGO AND ED_LCDPR = '1' AND SED.D_E_L_E_T_ = '' " 
					cCampos	+= " WHERE " + CompTab("SEV", "EV_FILIAL", "SE1", cTamSEV ) + " AND EV_PREFIXO = E1_PREFIXO AND EV_NUM = E1_NUM AND EV_PARCELA = E1_PARCELA "
					cCampos	+= " AND EV_CLIFOR = E1_CLIENTE AND EV_LOJA = E1_LOJA AND EV_TIPO = E1_TIPO AND EV_RECPAG = 'R' "
					cCampos	+= " AND EV_IDENT = '1' AND EV_SITUACA = ' ' AND SEV.D_E_L_E_T_ = ' ' ) AS VALOR "
				Else
					cCampos	:= " , SE1ADTO.E1_VLCRUZ AS VALOR "
				EndIf

				cQryAux += cCampos	
				If lE5Cgc
					cQryAux	+= " , ' ' CGC "
				EndIf
				cQryAux	+= " , SE1ADTO.E1_VLCRUZ VLMOED2, '0' || CAST(SE1ADTO.E1_MOEDA AS VARCHAR(2) ) MOEDA "
				cQryAux	+= " , SE1ADTO.E1_ORIGEM ORI, SE1ADTO.E1_PARCELA PARC, SE1ADTO.E1_LOJA LOJA, ' ' CODEMP, SE1ADTO.E1_FILIAL SEFIL "
				cQryAux += " , NULL RECSF12 "
				cQryAux	+= " , NULL VBRUT12 "
	   			cQryAux	+= " , NULL VSENA12 " 
	   			cQryAux	+= " , NULL VINSS12 "
	   			cQryAux	+= " , NULL COSOC12 "
				cQryAux	+= " , NULL NFTOTAL "
				cQryAux	+= " , NULL FUNRURAL "
				cQryAux	+= " , NULL VLSENAR "
				cQryAux	+= " , NULL VALINS "
				cQryAux += " , NULL VLFETFAC "
				
				If __lF820Qry
					cQryAux += cCpoPE
				EndIf

				cQryAux	+= " FROM " + RetSqlName("SE1") + " SE1ADTO "
				
				cQryAux	+= " INNER JOIN " + cTmpFil+ " TRFIL "
				cQryAux	+= " ON SE1ADTO.E1_FILORIG IN ( SELECT TRFIL.FILIAL FROM " + cTmpFil+ " ) "
				cQryAux	+= " AND SE1ADTO.E1_EMISSAO >= TRFIL.DTINI "
				cQryAux	+= " AND SE1ADTO.E1_EMISSAO <= TRFIL.DTFIM "
				cQryAux	+= " AND SE1ADTO.D_E_L_E_T_ = ' ' "

				cQryAux	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV1 "
				cQryAux	+= " ON TRFIL.FILIAL = FVV_FILIAL AND TRFIL.VER = FVV_VERSAO AND ( FVV_FILIAL = SE1ADTO.E1_FILORIG "

				cQryAux	+= " AND SE1ADTO.E1_EMISSAO BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "') "
				cQryAux	+= " AND FVV_CODPES = '" + __cFVUCod + "' AND SE1ADTO.D_E_L_E_T_ = ' ' AND FVV1.D_E_L_E_T_ = ' ' "

				cQryAux	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = SE1ADTO.E1_FILORIG "
				cQryAux	+= " AND SE1ADTO.E1_EMISSAO BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) "
				cQryAux	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
				cQryAux	+= " AND FVG_TPPES = '1' "
				cQryAux	+= " AND SE1ADTO.D_E_L_E_T_ = ' ' "
				cQryAux	+= " AND FVG.D_E_L_E_T_ = ' ' "

				cQryAux	+= " LEFT JOIN " + cTmpBco + " TRBCO "
				cQryAux	+= " ON " + StrTran( CompTab("TRBCO", "FIL", "SE1", cTamSA6), "E1_FILIAL", "SE1ADTO.E1_FILIAL" )
				cQryAux	+= " AND SE1ADTO.E1_PORTADO = TRBCO.BANCO AND SE1ADTO.E1_AGEDEP = TRBCO.AGENCIA AND SE1ADTO.E1_CONTA = TRBCO.CONTA "
			
				cQryAux	+= " INNER JOIN " + RetSqlName("SED") + " SED " // ON " + StrTran( CompTab("SED", "ED_FILIAL", "SE1", cTamSED) , "E1_FILIAL", "SE1ADTO.E1_FILIAL" )
	
				If cTamSED == cTamSE1
					cQryAux	+= " ON ED_FILIAL = SE1ADTO.E1_FILIAL "
				Else
					If Val(cTamSED) == 0
						cQryAux	+= " ON ED_FILIAL = ' ' "
					Else
						cQryAux	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(SE1ADTO.E1_FILORIG,1, " + cTamSED + ") "
					EndIf
				EndIf
		
				cQryAux	+= " AND ED_CODIGO = SE1ADTO.E1_NATUREZ AND (ED_LCDPR = '1' ) AND SED.D_E_L_E_T_ = ' ' "
				cQryAux	+= " INNER JOIN " + RetSqlName("SA1") + " SA1 "

				If cTamSA1 == cTamSE1
					cQryAux	+= " ON A1_FILIAL = SE1ADTO.E1_FILIAL "
				Else
					If Val(cTamSA1) == 0
						cQryAux	+= " ON A1_FILIAL = ' ' "
					Else
						cQryAux	+= " ON SUBSTRING(A1_FILIAL,1, " + cTamSA1 + ") = SUBSTRING(SE1ADTO.E1_FILORIG,1, " + cTamSA1 + ") "
					EndIf
				EndIf
				cQryAux	+= " AND SE1ADTO.E1_CLIENTE = A1_COD AND SE1ADTO.E1_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' '
				cQryAux	+= " WHERE SE1ADTO.E1_TIPO IN ('" + MVRECANT + "') AND "
				cQryAux	+= " SE1ADTO.E1_EMISSAO BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
				cQryAux	+= " AND ED_LCDPR = '1' AND SE1ADTO.D_E_L_E_T_ = ' ' "

			ENDIF

			IF __cLCDPRPA == "D"

				cQryAux	+= " UNION "
				cQryAux	+= " SELECT SUBSTRING(SE2ADTO.E2_EMISSAO,7,2) DIA, SUBSTRING(SE2ADTO.E2_EMISSAO, 5, 2) || SUBSTRING(SE2ADTO.E2_EMISSAO, 1, 4) MES_ANO, SE2ADTO.E2_EMISSAO DDATA, TRFIL.COD FILCOD, " 
				If !Empty(cPercPE) .And. ( ValType(Val(cPercPE)) == 'N' .And. Val(cPercPE) > 0 )
					cQryAux	+= cPercPE + " AS PERC, "
				Else
					cQryAux	+= " COALESCE(FVV2.FVV_PARTIC, FVG_PERC) AS PERC, "
				EndIf
				cQryAux	+= " ISNULL(TRBCO.COD,'') BANCO, SE2ADTO.E2_PREFIXO PREFIXO, SE2ADTO.E2_NUM NUMDOC, "

				//Histórico SE2 - PA
				lHistOri := .T.
				If __lF820Qry .AND. Len(aAretPE) > 6
					cHistPE := aAretPE[7]
					If !Empty(cHistPE) .And. ( ValType(cHistPE) == 'C' )
						cQryAux	+= cHistPE + " AS HIST, "
						lHistOri := .F.
					EndIf
				Endif

				If lHistOri
					cQryAux	+= " SE2ADTO.E2_HIST HIST, "
				Endif

				cQryAux	+= " ' ' CNPJCLI, ' ' PAISCLI, SA2.A2_CGC CNPJFOR, SA2.A2_PAIS PAISFOR, "
				cQryAux	+= " ' ' TPDOC, SE2ADTO.E2_TIPO E5_TIPO, 'P' RECPAG, 0, SE2ADTO.E2_VALOR,  0 SLDREC, ISNULL(SE2ADTO.E2_SALDO,0) SLDPAG, ' ', 0 REC, SE2ADTO.E2_FORNECE CLIFOR "
				
				If SuperGetMV("MV_MULNATP",,".F.")
					cCampos	:= " , E2_VLCRUZ * ( Select ISNULL( Sum(EV_PERC), 1 ) From " + RetSqlName("SEV") + " SEV "
					cCampos	+= " Inner Join " + RetSqlName ("SED") + " SED "
					If cTamSEV == cTamSED
						cCampos	+= " ON EV_FILIAL = ED_FILIAL "
					ElseIf Val(cTamSED) == 0
						cCampos	+= " ON ED_FILIAL = ' ' "
					ElseIf Val(cTamSEV) > Val(cTamSED)
						cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(EV_FILIAL,1, " + cTamSED + ") "
					Else
						cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(E2_FILORIG,1, " + cTamSED + ") "
					EndIf
					cCampos	+= " AND EV_NATUREZ = ED_CODIGO AND ED_LCDPR = '1' AND SED.D_E_L_E_T_ = '' " 
					cCampos	+= " WHERE " + CompTab("SEV", "EV_FILIAL", "SE2", cTamSEV ) + " AND EV_PREFIXO = E2_PREFIXO AND EV_NUM = E2_NUM AND EV_PARCELA = E2_PARCELA "
					cCampos	+= " AND EV_CLIFOR = E2_FORNECE AND EV_LOJA = E2_LOJA AND EV_TIPO = E2_TIPO AND EV_RECPAG = 'P' "
					cCampos	+= " AND EV_IDENT = '1' AND EV_SITUACA = ' ' AND SEV.D_E_L_E_T_ = ' ' ) AS VALOR "
				Else
					cCampos	:= " , SE2ADTO.E2_VLCRUZ AS VALOR "
				EndIf

				cQryAux	+= cCampos
				If lE5Cgc
					cQryAux	+= " , ' ' CGC "
				EndIf
				cQryAux	+= " , SE2ADTO.E2_VLCRUZ VLMOED2, '0' || CAST(SE2ADTO.E2_MOEDA AS VARCHAR(2) ) MOEDA "
				cQryAux	+= " , SE2ADTO.E2_ORIGEM ORI, SE2ADTO.E2_PARCELA PARC, SE2ADTO.E2_LOJA LOJA, ' ' CODEMP, SE2ADTO.E2_FILIAL SEFIL "
				cQryAux += " , NULL RECSF12 "
				cQryAux	+= " , NULL VBRUT12 "
	   			cQryAux	+= " , NULL VSENA12 " 
	   			cQryAux	+= " , NULL VINSS12 "
	   			cQryAux	+= " , NULL COSOC12 "
				cQryAux	+= " , NULL NFTOTAL "
				cQryAux	+= " , NULL FUNRURAL "
				cQryAux	+= " , NULL VLSENAR "
				cQryAux	+= " , NULL VALINS "
				cQryAux += " , NULL VLFETFAC "
				
				If __lF820Qry
					cQryAux += cCpoPE
				EndIf

				cQryAux	+= " FROM " + RetSqlName("SE2") + " SE2ADTO "
				
				cQryAux	+= " INNER JOIN " + RetSqlName("SE5") + " SE5 "
				cQryAux	+= " ON " + StrTran( CompTab("SE5", "E5_FILIAL", "SE2", cTamSE5), "E2_FILIAL", "SE2ADTO.E2_FILIAL" )
				cQryAux	+= " AND SE5.E5_PREFIXO = SE2ADTO.E2_PREFIXO AND SE5.E5_NUMERO = SE2ADTO.E2_NUM AND SE5.E5_PARCELA = SE2ADTO.E2_PARCELA AND SE5.E5_TIPO = SE2ADTO.E2_TIPO " 
				cQryAux	+= " AND SE5.E5_CLIFOR = SE2ADTO.E2_FORNECE AND SE5.E5_LOJA = SE2ADTO.E2_LOJA "
				cQryAux += " AND ((SE5.E5_TIPODOC = 'PA' ) OR (SE5.E5_TIPODOC = 'BA' AND SE5.E5_NUMCHEQ <> '" + cCampoChq + "' ) OR "
				cQryAux += "(SE5.E5_TIPODOC = 'CH' AND SE5.E5_NUMCHEQ <> '" + cCampoChq + "')) "
				cQryAux += " AND SE5.D_E_L_E_T_ = ' ' "

				cQryAux	+= " INNER JOIN " + cTmpFil+ " TRFIL "
				cQryAux	+= " ON SE2ADTO.E2_FILORIG IN ( SELECT TRFIL.FILIAL FROM " + cTmpFil+ " ) "
				cQryAux	+= " AND SE2ADTO.E2_EMISSAO >= TRFIL.DTINI "
				cQryAux	+= " AND SE2ADTO.E2_EMISSAO <= TRFIL.DTFIM "
				cQryAux	+= " AND SE2ADTO.D_E_L_E_T_ = ' ' "

				cQryAux	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV2 "
				cQryAux	+= " ON TRFIL.FILIAL = FVV_FILIAL AND TRFIL.VER = FVV_VERSAO AND ( FVV_FILIAL = SE2ADTO.E2_FILORIG "

				cQryAux	+= " AND SE2ADTO.E2_EMISSAO BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "') "
				cQryAux	+= " AND FVV_CODPES = '" + __cFVUCod + "' AND SE2ADTO.D_E_L_E_T_ = ' ' AND FVV2.D_E_L_E_T_ = ' ' "

				cQryAux	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = SE2ADTO.E2_FILORIG "
				cQryAux	+= " AND SE2ADTO.E2_EMISSAO BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) "
				cQryAux	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
				cQryAux	+= " AND FVG_TPPES = '1' "
				cQryAux	+= " AND SE2ADTO.D_E_L_E_T_ = ' ' "
				cQryAux	+= " AND FVG.D_E_L_E_T_ = ' ' "
				
				cQryAux	+= " LEFT JOIN " + cTmpBco + " TRBCO "
				cQryAux	+= " ON " + StrTran( CompTab("TRBCO", "FIL", "SE2", cTamSA6), "E2_FILIAL", "SE2ADTO.E2_FILIAL" )
				cQryAux	+= " AND SE5.E5_BANCO = TRBCO.BANCO "
				cQryAux	+= " AND SE5.E5_AGENCIA = TRBCO.AGENCIA "
				cQryAux	+= " AND SE5.E5_CONTA = TRBCO.CONTA "
				
				cQryAux	+= " INNER JOIN " + RetSqlName("SED") + " SED "
				If cTamSED == cTamSE2
					cQryAux	+= " ON ED_FILIAL = E2_FILIAL "
				Else
					If Val(cTamSED) == 0
						cQryAux	+= " ON  ED_FILIAL = ' ' "
					Else
						cQryAux	+= " ON ( SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(SE2ADTO.E2_FILORIG,1, " + cTamSED + ")) "
					EndIf				
				EndIf				
				cQryAux	+= " AND ED_CODIGO = SE2ADTO.E2_NATUREZ AND (ED_LCDPR = '1' ) AND SED.D_E_L_E_T_ = ' '  "
				cQryAux	+= " INNER JOIN " + RetSqlName("SA2") + " SA2 "
				
				If cTamSA2 == cTamSE2
					cQryAux	+= " ON A2_FILIAL = SE2ADTO.E2_FILIAL "
				Else
					If Val(cTamSA2) == 0
						cQryAux	+= " ON A2_FILIAL = ' ' "
					Else
						cQryAux	+= " ON SUBSTRING(A2_FILIAL,1, " + cTamSA2 + ") = SUBSTRING(SE2ADTO.E2_FILORIG,1, " + cTamSA2 + ") "
					EndIf
				EndIf
				cQryAux	+= " AND SE2ADTO.E2_FORNECE = A2_COD AND SE2ADTO.E2_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' '
				cQryAux	+= " WHERE SE2ADTO.E2_TIPO IN ('" + MVPAGANT + "') AND "
				cQryAux	+= " SE2ADTO.E2_EMISSAO BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
				cQryAux	+= " AND ED_LCDPR = '1' AND SE2ADTO.D_E_L_E_T_ = ' ' "
			
			ENDIF

			cQuery	+= cQryAux
			cQryAux	:= ""
			cQuery	+= " ORDER BY DDATA, FILCOD, BANCO, NUMDOC, PREFIXO, PARC, E5_TIPO, TPDOC"
			
			cQuery	:= ChangeQuery(cQuery)

			//SELECT NA TEMPORARIA
			//Criação do insert into
			oTRB100:SetFields(aFldTRB) 
			oTRB100:AddIndex("1", {"DDATA"},{"FILCOD"}, {"BANCO"}, {"NUMDOC"},{"PREFIXO"},{"PARC"},{"E5_TIPO"},{"TPDOC"})
			oTRB100:Create()

			//Pega todos os campos para efetuar a cópia dos dados
			For nLoop := 1 to Len(aFldTRB)
				cFields += aFldTRB[nLoop][1] + ","//Nome do campo
			Next

			cFields := Left(cFields, Len(cFields) -1) //Remover a ultima vírgula

			cReplace := "INSERT INTO " + oTRB100:GetRealName()
			cReplace += " (" + cFields + ") "
			cReplace += " ( SELECT"

			//COLOCO INSERT INTO NO COMEÇO DA QUERY
			cQuery		:= StrTran( cQuery, "SELECT", cReplace , 1 , 1 )

			//FECHO O PARENTESES PARA AGREGAR O SELECT COM SEUS POSSÍVEIS UNIONS
			cReplace 	:= "ORDER BY  DDATA, FILCOD, BANCO, NUMDOC, PREFIXO, PARC, E5_TIPO, TPDOC"		
			cQuery		:= StrTran( cQuery, cReplace, " ) " + cReplace , 1 , 1 )

			//RETIRO TODOS OS NULL QUE SÃO NUMÉRICOS E COLOCO ZERO NA CRIAÇÃO
			cQuery		:= StrTran( cQuery, "NULL", "0" )

			TCSQLEXEC(cQuery)
			
	EndCase
		
Return				

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TemLCDPR

Verifica configuração do LCDPR

@sample	TemLCDPR(cTipPes)
@return		lRet		 .T. se o LCDPR está configurado corretamente
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Function TemLCDPR() As Logical

	Local lRet As Logical
	
	lRet := .F.

	If AliasInDic('FVU') .AND. AliasInDic('FVV') .AND. AliasInDic('FVG') .AND. AliasInDic('FXV')
		ChkFile("FVV")
		ChkFile("FVU")
		ChkFile("FVG")
		ChkFile("FXV")

		If FWModeAccess("FVV",3) == "E" .AND. FWModeAccess("FVG",3) == "E" .AND. FWModeAccess("FXV",3) == "E"
			lRet := .T.
		ElseIf !__lIsBlind
			Help(' ',1,STR0001 ,,STR0002,2,0,,,,,,STR0003 ) // 'Compartilhamento Tabelas' ; 'As tabelas FVV e FVG devem ser obrigatoriamente exclusivas' ; 'Favor ajustar as tabelas FVV e FVG para modo totalmente exclusivo no módulo SIGACFG- Configurador'
		EndIf

		If lRet
			If !("VERSAO" $ FWX2Unico("FVG") .And. "VERSAO" $ FWX2Unico("FXV") )
				If !__lIsBlind
					Help(" ",1,"DESATUAL",, STR0004, 1, 0,,,,, {STR0005 + CRLF + STR0006}) // Sistema desatualizado para uso do LCDPR. ## Necessária a atualização do sistema ## (dicionário e repositório) para uso dessa rotina.
				EndIf
				lRet := .F.
			EndIf
		EndIf
		
	ElseIf !IsBlind()
		Help(" ",1,"DESATUAL",, STR0004, 1, 0,,,,, {STR0005 + CRLF + STR0006}) // Sistema desatualizado para uso do LCDPR. ## Necessária a atualização do sistema ## (dicionário e repositório) para uso dessa rotina.
	EndIf
	
Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} PicCgc

Ajusta picture do campo FVU_CNPJ de acordo com o tipo de Pessoa (F/J)

@sample	PicPes(cTipPes)

@param		cTipPes = Tipo de Pessoa			 

@return	cPict

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Function PicCgc(cTipPes As Character) As Character
	Local cPict As Character
	
	cPict := ""
	
	If cTipPes == "1"
		cPict := "@R 999.999.999-99"		
	Else
		If Len(AllTrim(M->FVU_CNPJ)) <> 14
			M->FVU_CNPJ := Space(Len(FVU->FVU_CNPJ))	
		EndIf
		cPict := "@R 99.999.999/9999-99"
	EndIf	
	
	cPict := cPict + "%C"

Return cPict

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CompTab

Tratamento de compartilhamento entre as tabelas

@sample	CompTab()

@param		

@return	

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Function CompTab(cAlias As Character, cCampo As Character, cTab As Character, cTamOut As Character) As Character
	Local cCond		As Character
	Local cCpo		As Character
	Local nTamFil	As Numeric
	Local nTam		As Numeric

	Default cTab	:= "SE5"
	Default cTamOut	:= "0"
	
	If cAlias <> "TRBCO"
		nTamFil	:= Val(cTamOut)
	Else
		nTamFil := __nTamFlA6
	EndIf

	If cTab == "SE5"
		cCpo	:= "E5_"
		nTam	:= __nFilSE5
	ElseIf cTab == "SE1"
		cCpo	:= "E1_"
		nTam	:= __nFilSE1
	Else
		cCpo	:= "E2_"
		nTam	:= __nFilSE2
	EndIf

	If nTam	== nTamFil
		cCond	:= cCpo + "FILIAL = " + cCampo
	ElseIf nTam == 0 .Or. nTamFil == 0
		If Val(cTamOut) > 0
			cCond	:= " " + cCampo + " = SUBSTRING(" + cCpo	+ "FILORIG, 1, " + cTamOut + ") "
		Else
			cCond	:= " " + cCampo + " = ' ' "
		EndIf
	ElseIf nTam > nTamFil
		If "MSSQL" $ __cDBName 
			cCond	:= " SUBSTRING(" + cCpo	+ "FILIAL, 1, " + cTamOut + ") = " + cCampo + " "
		Else
			cCond	:= " SUBSTRING(" + cCpo	+ "FILIAL, 1, " + cTamOut + ") = " + cCampo + " "
		EndIf
	ElseIf cTab == "SE5" .And. ( nTam < nTamFil ) .And.  cAlias $ "SE1|SE2" // Caso SE1 e SE2 menos compartilhada que a SE5
		cCond	:= " " + cCampo + " = SUBSTRING(" + cCpo	+ "FILORIG, 1, " + cTamOut + ") "
	Else
		If "MSSQL" $ __cDBName
			cCond	:= " SUBSTRING(" + cCampo + ", 1, " + Str(nTam) + ") = " + cCpo	+ "FILIAL "
		Else
			cCond	:= " SUBSTRING(" + cCampo + ", 1, " + Str(nTam) + ") = " + cCpo + "FILIAL "
		EndIf
	EndIf
	
Return cCond

//------------------------------------------------------------------------------
/*/	{Protheus.doc} GetVerLCD

Define a versão do Leiaute do LCDPR

@sample	GetVerLCD()

@param		

@return	cVersion = versão do leiaute do arquivo LCDPR

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Function GetVerLCD() As Character
	Local cVersion As Character
	
	cVersion	:= "1.3"
	
Return cVersion

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FormatDt
Formata as datas recebidas do Wizard

@sample	FormatDt()

@param		

@return	cRet = data formatada e convertida em caracter

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function FormatDt( dData As Date) As Character
	Local cRet As Character
	
	cRet 	:= DtoS(dData)
	cRet	:= SubStr(cRet, 7, 2) + SubStr(cRet, 5, 2) + SubStr(cRet, 1, 4) 
	
Return cRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ModeAccess
Verifica o modo de acesso da tabela e retorna o um caracter com o tamanho
do campo filial

@sample	ModeAccess()

@param		

@return	cTam = Tamanho do campo filial

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ModeAccess(cTab As Character, nTamEmp As Numeric, nTamUnN As Numeric, nTamFil As Numeric)
	Local cTam As Character

	cTam	:= ""
	
	If FwModeAccess( cTab, 3 ) == "E"
		cTam	:= Str(Len(FwSM0LayOut()))
	ElseIf FwModeAccess( cTab, 1 ) == "C"
		cTam	:= "0"
	ElseIf FwModeAccess( cTab, 2 ) == "E"
		cTam := Str( nTamEmp + nTamUnN )
	Else	
		cTam := Str( nTamEmp )
	EndIf

Return cTam

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ZeraStatic()
Reseta o valor das Variáveis estáticas

@sample	ZeraStatic()

@param		

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ZeraStatic()

	__cArq		:= ""
	__cDir		:= ""
	__lPrinted	:= .F.
	__cCpf		:= ""
	__cTmpFVV	:= ""
	__cTmpFVG	:= ""
	__cTmpCVB	:= ""
	__lF820Qry	:= .F.
	__lF820Reg	:= .F.
	__lF820Bco	:= .F.
	__lImpHist	:= .F.
	__lCsv		:= .F.
		
	If __oTmpFil <> Nil
		__oTmpFil:Delete()
		__oTmpFil := Nil
	EndIf
		
	If __oTmpBco <> Nil
		__oTmpBco:Delete()
		__oTmpBco := Nil
	EndIf

	If __oTSlCred <> Nil
		__oTSlCred:Delete()
		__oTSlCred := Nil
	EndIf
			
	__nFilSE5	:= Nil
	__nFilSE1	:= Nil
	__nFilSE2	:= Nil
	__aTpReg	:= {}
	__aTpReg	:= Nil
	
Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FilCompl()
Verifica se a filial tem complemento

@param cCodigo - código da filial

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function FilCompl(cCodigo As Character) As Numeric
	Local cQuery	As Character
	Local nRet		As Numeric

	Default cCodigo := " "

	cQuery 	:= " Select Count(FXV_FILIAL) AS FIL From " + RetSqlName("FXV") + " FXV "
	cQuery	+= " Where FXV_CODIGO = '" + cCodigo + "' And FXV.D_E_L_E_T_ = ' ' " 
     
    nRet	:= MpSysExecScalar(cQuery,"FIL")

Return nRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FTemChq()
Verifica se há cheque compensado para o registro

@param cBanco - código do banco do cheque
@param cAgencia - código da agencia do banco
@param cConta - código da conta do banco
@param cCheque - número do cheque a ser buscado

@return lRet - se existe cheque compensado (.T.) ou não

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function FTemChq(cFil As Character, cBanco As Character, cAgencia As Character, cConta As Character, cCheque As Character, cCart As Character) As Logical
	Local cQuery	As Character
	Local nRet		As Numeric
	Local aArea		As Array
	Local aAreaSE5	As Array

	Default cBanco 		:= ""
	Default cAgencia	:= ""
	Default cConta 		:= ""
	Default cCheque		:= ""
	Default cFil		:= ""
	Default cCart		:= ""

	If __nLOEmp == Nil
		__nLOEmp	:= Len(FWSM0LayOut(,1))
	EndIf
	If __nLOUnN	== Nil
		__nLOUnN := Len(FWSM0LayOut(,2))
	EndIf
	If __nLOFil == Nil
		__nLOFil	:= Len(FWSM0LayOut(,3))
	EndIf

	If __cTamSE5 == Nil
		__cTamSE5	:= ModeAccess( "SE5", __nLOEmp, __nLOUnN, __nLOFil )
	EndIf
	If __cTamSEF == Nil
		__cTamSEF	:= ModeAccess( "SEF", __nLOEmp, __nLOUnN, __nLOFil )
	EndIf
	If __lLibChq == Nil
		__lLibChq	:= SuperGetMV("MV_LIBCHEQ",,'S') == "N"
	EndIf
	
	If __lLibChq .And. Empty(AllTrim(cCheque))
		nRet := 0
	Else
		aArea		:= GetArea()
		aAreaSE5	:= SE5->(GetArea()) 

		If __oTmpChCP == Nil .And. cCart == "P"
			cQuery 	:= " Select Count(EF_FILIAL) AS FIL "
			cQuery 	+= " From " + RetSqlName("SE5") + " SE5 "
			cQuery 	+= " INNER JOIN " + RetSqlName("SEF") + " SEF "

			If __cTamSE5 == __cTamSEF
				cQuery	+= " ON EF_FILIAL = E5_FILIAL "
			ElseIf Val(__cTamSEF) == 0
				cQuery	+= " ON EF_FILIAL = ' ' "
			ElseIf Val(__cTamSE5) > Val(__cTamSEF)
				cQuery	+= " ON SUBSTRING(EF_FILIAL,1, " + __cTamSEF + ") = SUBSTRING(E5_FILIAL,1, " + __cTamSEF + ") "
			Else
				cQuery	+= " ON SUBSTRING(EF_FILIAL,1, " + __cTamSEF + ") = SUBSTRING(E5_FILORIG,1, " + __cTamSEF + ") "
			EndIf
			
			cQuery 	+= " AND E5_NUMCHEQ = EF_NUM "
			cQuery 	+= " AND E5_BANCO = EF_BANCO "
			cQuery 	+= " AND E5_AGENCIA = EF_AGENCIA "
			cQuery 	+= " AND E5_CONTA = EF_CONTA "
			cQuery	+= " Where E5_FILIAL = ? "
			cQuery	+= " And E5_BANCO = ? "
			cQuery	+= " And E5_AGENCIA = ? "
			cQuery	+= " And E5_CONTA = ? "
			cQuery	+= " And E5_NUMCHEQ = ? "
			If __lLibChq
				cQuery	+= " And EF_LIBER = 'S' "
			EndIf
			cQuery	+= " And SE5.D_E_L_E_T_ = ' ' " 
			cQuery	+= " And SEF.D_E_L_E_T_ = ' ' " 
			
			cQuery	:= ChangeQuery(cQuery)

			__oTmpChCP :=FWPreparedStatement():New(cQuery)
		
		ElseIf __oTmpChCR == NIL .And. cCart == "R"
			cQuery 	:= " Select Count(EF_FILIAL) AS FIL "
			cQuery 	+= " From " + RetSqlName("SE5") + " SE5 "
			cQuery 	+= " INNER JOIN " + RetSqlName("SEF") + " SEF "

			If __cTamSE5 == __cTamSEF
				cQuery	+= " ON EF_FILIAL = E5_FILIAL "
			ElseIf Val(__cTamSEF) == 0
				cQuery	+= " ON EF_FILIAL = ' ' "
			ElseIf Val(__cTamSE5) > Val(__cTamSEF)
				cQuery	+= " ON SUBSTRING(EF_FILIAL,1, " + __cTamSEF + ") = SUBSTRING(E5_FILIAL,1, " + __cTamSEF + ") "
			Else
				cQuery	+= " ON SUBSTRING(EF_FILIAL,1, " + __cTamSEF + ") = SUBSTRING(E5_FILORIG,1, " + __cTamSEF + ") "
			EndIf
			
			cQuery 	+= " AND E5_NUMCHEQ = EF_NUM "
			cQuery 	+= " AND E5_PREFIXO = EF_PREFIXO "
			cQuery 	+= " AND E5_NUMERO = EF_TITULO "
			cQuery 	+= " AND E5_CLIFOR = EF_CLIENTE "
			cQuery 	+= " AND E5_LOJA = EF_LOJACLI "
			cQuery 	+= " AND E5_RECPAG = EF_CART "

			cQuery	+= " Where E5_FILIAL = ? "
			cQuery	+= " And E5_BANCO = ? "
			cQuery	+= " And E5_AGENCIA = ? "
			cQuery	+= " And E5_CONTA = ? "
			cQuery	+= " And E5_NUMCHEQ = ? "
			cQuery	+= " And EF_DTCOMP <> '' "
			cQuery	+= " And SE5.D_E_L_E_T_ = ' ' " 
			cQuery	+= " And SEF.D_E_L_E_T_ = ' ' " 
			
			cQuery	:= ChangeQuery(cQuery)

			__oTmpChCR :=FWPreparedStatement():New(cQuery)
		EndIf

		If cCart == "P"
			__oTmpChCP:SetString(1,cFil)
			__oTmpChCP:SetString(2,cBanco)
			__oTmpChCP:SetString(3,cAgencia)
			__oTmpChCP:SetString(4,cConta)
			__oTmpChCP:SetString(5,cCheque)
			cQuery := __oTmpChCP:GetFixQuery()
		ElseIf cCart == "R"	
			__oTmpChCR:SetString(1,cFil)
			__oTmpChCR:SetString(2,cBanco)
			__oTmpChCR:SetString(3,cAgencia)
			__oTmpChCR:SetString(4,cConta)
			__oTmpChCR:SetString(5,cCheque)
			cQuery := __oTmpChCR:GetFixQuery()
		EndIf

		nRet	:= MpSysExecScalar(cQuery,"FIL")

		RestArea(aAreaSE5)
		RestArea(aArea)
	EndIf

Return ( nRet > 0 )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ValBruNf()
Função para buscar o valor bruto da nota

@param cCart	- Carteira do título
@param cFil		- Filail do título
@param cPref	- Prefixo do título
@param cNumDoc	- Número do documento
@param cParc	- Parcela do título
@param cTipo	- Tipo do título
@param cCliFor	- Cliente / Fornecedor do título
@param cLoja	- Loja do cliente / fornecedor

@return nVlBrut - Valor Bruto da nota

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Function ValBruNf(cCart As Character, cFil As Character, cPref As Character, cNumDoc As Character, cParc As Character, cTipo As Character, cCliFor As Character, cLoja As Character, nRecSF12 As Numeric, nVBRUT12 as Numeric, nVSENA12 as Numeric, nVINSS12 as Numeric, nCOSOC12 as Numeric, nVlAbat As Numeric, lPJNRural As Logical ) As Numeric
		// TRB100->SEFIL, TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, TRB100->E5_TIPO, TRB100->CLIFOR, TRB100->LOJA, Empty(TRB100->REC)

	Local aArea		As Array
	Local nVlBrut 	As Numeric
	Local nPropBx 	As Numeric
	Local nVlFun	As Numeric
	Local nParcs	As Numeric
	Local nVlCtSq	As Numeric
	Local nVlIns	As Numeric
	Local nValDevol	As Numeric
	Local cAlias	As Character
	Local lNota		As Logical
	Local lChgFil	As Logical
	Local lDescSen	As Logical
	Local lFinXFis	As Logical
	
	aArea		:= GetArea()
	cAlias		:= ""
	nVlBrut		:= 0
	nPropBx		:= 1
	nVlFun		:= 0
	nVlCtSq		:= 0
	nVlIns		:= 0
	nMtImp		:= 0
	nValDevol	:= 0
	nParcs		:= 1
	lNota		:= .F.
	lChgFil		:= .F.
	lDescSen	:= .F.
	If _lCpos1 == Nil
		_lCpos1		:= SF1->(ColumnPos('F1_CONTSOC') ) > 0 .And. SF1->(ColumnPos('F1_VLSENAR') ) > 0 .And. SF1->(ColumnPos('F1_INSS' ) ) > 0
	EndIf
	If _lCpos2 == Nil
		_lCpos2		:= SF2->(ColumnPos('F2_CONTSOC') ) > 0 .And. SF2->(ColumnPos('F2_VLSENAR') ) > 0 .And. SF2->(ColumnPos('F2_VALINSS' ) ) > 0
	EndIf
	If _lMtCpos1 == Nil
		_lMtCpos1		:= SF1->(ColumnPos('F1_VALFAC') ) > 0 .And. SF1->(ColumnPos('F1_VALFET') ) > 0 .And. SF1->(ColumnPos('F1_VALFAB' ) ) > 0
	EndIf
	If _lMtCpos2 == Nil				
		_lMtCpos2		:= SF2->(ColumnPos('F2_VALFAC') ) > 0 .And. SF2->(ColumnPos('F2_VALFET') ) > 0 .And. SF2->(ColumnPos('F2_VALFAB' ) ) > 0
	EndIf
	If __aOtimF1	== Nil
		__aOtimF1 	:= {}
		__aOtimF2 	:= {}
	EndIf

	lFinXFis	:= .T.

	If !__lF820Qry  .Or. (__lF820Qry .And. ( Empty(TRB100->CODEMP) .Or. (!Empty(TRB100->CODEMP) .And. cEmpAnt == TRB100->CODEMP ) ) )
		If cCart == 'R'
			cAlias	:= "SF2"
			If !Empty(nRecSF12)
				If ( ( lDescSen := TRB100->E1_VLCRUZ <> nVBRUT12 ) .Or. ( ( nVSENA12 + nVINSS12 + nCOSOC12 ) > 0 ) )
					If cFilAnt <> cFil
						__cFlAntOd	:= cFilAnt
						cFilAnt		:= cFil
						lChgFil		:= .T.
					EndIf

					IF EMPTY(TRB100->NFTOTAL)

						(cAlias)->(DbGoTo(nRecSF12))

						If _lCpos2
							If SF2->( F2_CONTSOC + F2_VLSENAR + F2_VALINSS ) == 0 
								lFinXFis := .F.
							EndIf
							If _lMtCpos2
								nMtImp := SF2->( F2_VALFAC + F2_VALFET + F2_VALFAB )
							EndIf
						EndIf

						If lFinXFis .Or. nMtImp > 0
							MaFisIniNF(2,nRecSF12,@__aOtimF2)
							nVlBrut		:= MaFisRet(, "NF_TOTAL")
							nVlCtSq		:= MaFisRet(, "NF_FUNRURAL")
							nVlFun		:= MaFisRet(, "NF_VLSENAR")
							nVlIns		:= MaFisRet(, "NF_VALINS")

							If nMtImp > 0
								nMtImp		:= MaFisRet(, "NF_VALFAC")
								nMtImp		+= MaFisRet(, "NF_VALFET")
								nMtImp		+= MaFisRet(, "NF_VALFETR")
								nMtImp		+= MaFisRet(, "NF_VALFAB")
							EndIf

							cQuery := "UPDATE " + oTRB100:GetRealName()
							cQuery += " SET NFTOTAL = " + CVALTOCHAR(nVlBrut)
							cQuery += ", FUNRURAL = " + CVALTOCHAR(nVlCtSq)
							cQuery += ", VLSENAR = " + CVALTOCHAR(nVlFun)
							cQuery += ", VALINS = " + CVALTOCHAR(nVlIns)
							cQuery += ", VLFETFAC = " + CVALTOCHAR(nMtImp)
							cQuery += " WHERE RECSF12 = " + CVALTOCHAR(nRecSF12) 

							TCSQLEXEC( cQuery )
						
						Else
							nVlBrut		:= Iif( TRB100->NFTOTAL > 0, TRB100->NFTOTAL, TRB100->VBRUT12 )
						EndIf

					ELSE

						nVlBrut		:= TRB100->NFTOTAL
						nVlCtSq		:= TRB100->FUNRURAL
						nVlFun		:= TRB100->VLSENAR
						nVlIns		:= TRB100->VALINS
						nMtImp		:= TRB100->VLFETFAC

					ENDIF

					__lFunrural := ( nVlFun + nVlCtSq ) > 0
					__nVlFun	:= nVlFun
					lNota		:= .T.
					__lNftot	:= TRB100->SLDREC == 0 .And. NumBaixas() == 1
					If lChgFil
						cFilAnt		:= __cFlAntOd
					EndIf
				Else
					nVlBrut := TRB100->VALOR
				EndIf
			Else
				nVlBrut := TRB100->VALOR
			EndIf	
		Else
			cAlias	:= "SF1"
			If !EMPTY(nRecSF12)
				If ( ( lDescSen := TRB100->E2_VLCRUZ <> nVBRUT12 ) .Or. ( nVSENA12 + nVINSS12 + nCOSOC12 ) > 0 )
					If cFilAnt <> cFil
						__cFlAntOd	:= cFilAnt
						cFilAnt		:= cFil
						lChgFil		:= .T.
					EndIf

					IF EMPTY(TRB100->NFTOTAL)

						(cAlias)->(DbGoTo(nRecSF12))

						If _lCpos1
							If SF1->( F1_CONTSOC + F1_VLSENAR + F1_INSS ) == 0 
								lFinXFis	:= .F.
							EndIf
							If _lMtCpos1
								nMtImp := SF1->( F1_VALFAC + F1_VALFET + F1_VALFAB )
							EndIf
						EndIf

						If lFinXFis .Or. nMtImp > 0
							MaFisIniNF(1,nRecSF12,@__aOtimF1)
							nVlBrut		:= MaFisRet(, "NF_TOTAL")
							nVlCtSq		:= MaFisRet(, "NF_FUNRURAL")
							nVlFun		:= MaFisRet(, "NF_VLSENAR")
							nVlIns		:= MaFisRet(, "NF_VALINS")

							If nMtImp > 0
								nMtImp		:= MaFisRet(, "NF_VALFAC")
								nMtImp		+= MaFisRet(, "NF_VALFET")
								nMtImp		+= MaFisRet(, "NF_VALFETR")
								nMtImp		+= MaFisRet(, "NF_VALFAB")
							EndIf

							cQuery := "UPDATE " + oTRB100:GetRealName()
							cQuery += " SET NFTOTAL = " + CVALTOCHAR(nVlBrut)
							cQuery += ", FUNRURAL = " + CVALTOCHAR(nVlCtSq)
							cQuery += ", VLSENAR = " + CVALTOCHAR(nVlFun)
							cQuery += ", VALINS = " + CVALTOCHAR(nVlIns)
							cQuery += ", VLFETFAC = " + CVALTOCHAR(nMtImp)
							cQuery += " WHERE RECSF12 = " + CVALTOCHAR(nRecSF12) 

							TCSQLEXEC( cQuery )

						Else
							nVlBrut		:= Iif( TRB100->NFTOTAL > 0, TRB100->NFTOTAL, TRB100->VBRUT12 )
						EndIf
						
					ELSE

						nVlBrut		:= TRB100->NFTOTAL
						nVlCtSq		:= TRB100->FUNRURAL
						nVlFun		:= TRB100->VLSENAR
						nVlIns		:= TRB100->VALINS
						nMtImp		:= TRB100->VLFETFAC

					ENDIF

					__lFunrural := ( nVlFun + nVlCtSq ) > 0
					__nVlFun	:= nVlFun
					lNota		:= .T.
					__lNftot	:= TRB100->SLDPAG == 0 .And. NumBaixas() == 1
					If lChgFil
						cFilAnt		:= __cFlAntOd
					EndIf
				Else
					nVlBrut := TRB100->VALOR
				EndIf
			Else
				nVlBrut := TRB100->VALOR
			EndIf
		EndIf
		__nAbtNF := nVlCtSq + Iif(!lDescSen, nVlFun, 0) + nVlIns + nMtImp
	Else
		nVlBrut := TRB100->VALOR
	EndIf
	
	__nVlNota	:= nVlBrut
	If ( nParcs	:= QtdeParc(cCart, cFil) ) > 1 .And. lNota
		nVlBrut 	:= nVlBrut / nParcs
	EndIf
	If lDescSen .Or. ( ( nVlFun + nVlCtSq + nVlIns + nMtImp) > 0 )
		If TRB100->VALOR + nVlAbat == nVlBrut
			nPropBx	:= 1
		Else	
			nPropBx	:= TRB100->VALOR / ( ( nVlBrut - ( nValDevol := SldCred()) ) - ( ( If( lPJNRural, nVlFun + nVlCtSq, nVlFun ) + nVlIns + nMtImp) / nParcs ) )
		EndIf
	Else
		nPropBx		:= TRB100->VALOR / nVlBrut
	EndIf
	nPropBx		:= Iif( nParcs == 1, Min(nPropBx, 1), nPropBx)
	__nPropBx	:= nPropBx
	If nParcs > 1 .Or. lNota
		__nVlFun	:= (nVlFun / nParcs ) * __nPropBx
	EndIf
	If __lFunRural
		If cCart == "R"
			If TRB100->E1_VLCRUZ <> nVBRUT12
				If nParcs > 1 .Or. lNota
					If ( (nVlBrut - __nAbtNf - Iif(lDescSen, nVlFun, 0) ) - nValDevol ) == 0 
						nVlBrut 	:= nValDevol
					Else
						nVlBrut		:= ( nVlBrut - nValDevol ) * nPropBx
					EndIf
				Else
					nVlBrut		:= TRB100->VALOR / nPropBx
				End
			Else
				nVlBrut		:= ( nVlBrut - nValDevol ) * nPropBx
			EndIf
		Else
			If TRB100->E2_VLCRUZ <> nVBRUT12
				If nParcs > 1 .Or. lNota
					nVlBrut		:= ( nVlBrut - nValDevol ) * nPropBx
				Else
					nVlBrut		:= TRB100->VALOR / nPropBx
				EndIf
			Else
				nVlBrut		:= ( nVlBrut - nValDevol ) * nPropBx
			EndIf
		EndIf
	Else
		If nParcs > 1 .Or. lNota
			nVlBrut		:= ( nVlBrut - ( nVlFun + nVlCtSq + nVlIns ) ) * nPropBx
		Else
			nVlBrut		:= TRB100->VALOR / nPropBx
		EndIf
	EndIf
	If __nVlNota > 0 .And. nVlBrut > __nVlNota
		nVlBrut		:= __nVlNota
	EndIf
		
	RestArea(aArea)

Return nVlBrut

//------------------------------------------------------------------------------
/*/	{Protheus.doc} RotOri()
Função para buscar o valor bruto da nota

@param cCart	- Carteira de origem do título
@param cFil		- Filial do título
@param cPref	- Prefixo do título
@param cNumDoc	- Núremo do documento
@param cParc	- Número da parcela
@param cTipo	- Tipo do documento
@param cCliFor	- Cliente / Fornecedor do título
@param cLoja	- Loja do cliente / fornec.

@return array 	- { rotina de origem do título, filial de origem }

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function RotOri(cCart As Character, cFil As Character, cPref As Character, cNumDoc As Character, cParc As Character, cTipo As Character, cCliFor As Character, cLoja As Character, lDevol As Logical, nTamTitR As Numeric) As Character
	Local aArea 	As Array
	Local aAreaSE	As Array
	Local aAreaSE5	As Array
	Local cRotina	As Character
	Local lDevolNF	As Logical
	
	Default lDevol		:= .F.
	Default nTamTitR	:= 0

	aArea		:= GetArea()
	aAreaSE		:= {}
	aAreaSE5	:= {}
	cRotina		:= ""
	lDevolNF	:= .F.

	If !__lF820Qry .Or. (__lF820Qry .And. ( Empty(TRB100->CODEMP) .Or. (!Empty(TRB100->CODEMP) .And. cEmpAnt == TRB100->CODEMP ) ) )
		__cFilOri	:= SubStr(Posicione("SE5", 7, cFil + cPref + cNumDoc + cParc + cTipo + cCliFor + cLoja, "E5_FILORIG") , 1,Len(cFil))
		If cCart == 'R' .Or. '-' $ TRB100->E5_TIPO
			aAreaSE5	:= SE5->(GetArea())
			__cFilOri	:= SubStr(Posicione("SE5", 7, cFil + cPref + cNumDoc + cParc + cTipo, "E5_FILORIG") , 1, Len(cFil))
			__nTxMoeda	:= SE5->E5_TXMOEDA
			RestArea(aAreaSE5)
		
			aAreaSE	:= SE1->(GetArea())
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbGoTop()
			If !( '-' $ TRB100->E5_TIPO ) .And. ( Len(AllTrim(cFil)) == 0 .Or. __nFilSE1 <> __nFilSE5 .Or. Len(AllTrim(cFil)) < __nFilSE1 )
				cFil	:= __cFilOri
			EndIf
			SE1->(DbSeek(PadR(SubStr(cFil,1,__nFilSE1), Len(cFil), " ") + cPref + cNumDoc + cParc + cTipo))
			cRotina		:= SE1->E1_ORIGEM
			lDevolNF	:= !Empty(SE1->E1_SERIE)
			
			RestArea(aAreaSE)
		Else
			aAreaSE5	:= SE5->(GetArea())
			If lDevol .And. nTamTitR > 0
				If Substr(SE5->E5_DOCUMEN,nTamTitR,3) $ MV_CPNEG
					__cFilOri	:= SubStr(GetAdvFVal("SE5","E5_FILORIG",cFil + RTrim(SE5->E5_DOCUMEN),7), 1,Len(cFil))
					lDevolNF	:= .T.
				Else
					__cFilOri	:= SubStr(Posicione("SE5", 7, cFil + cPref + cNumDoc + cParc + cTipo + cCliFor + cLoja, "E5_FILORIG") , 1,Len(cFil))
				EndIf
			Else
				__cFilOri	:= SubStr(Posicione("SE5", 7, cFil + cPref + cNumDoc + cParc + cTipo + cCliFor + cLoja, "E5_FILORIG") , 1,Len(cFil))
			EndIf
			__nTxMoeda	:= SE5->E5_TXMOEDA
			RestArea(aAreaSE5)
		
			aAreaSE	:= SE2->(GetArea())
			DbSelectArea("SE2")
			DbSetOrder(1)
			DbGoTop()
			If Len(AllTrim(cFil)) == 0 .Or. __nFilSE1 <> __nFilSE5 .Or. Len(AllTrim(cFil)) < __nFilSE2
				cFil	:= __cFilOri
			EndIf
			If lDevolNF
				SE2->(DbSeek(PadR(SubStr(cFil,1,__nFilSE2), Len(cFil), " ") + SE5->E5_DOCUMEN))
			Else
				SE2->(DbSeek(PadR(SubStr(cFil,1,__nFilSE2), Len(cFil), " ") + cPref + cNumDoc + cParc + cTipo + cCliFor + cLoja))
			EndIf
			cRotina	:= SE2->E2_ORIGEM
			RestArea(aAreaSE)
		EndIf
	EndIf

	RestArea(aArea)

Return { AllTrim(cRotina), __cFilOri, lDevolNF }

//------------------------------------------------------------------------------
/*/	{Protheus.doc} QtdeParc()
Função para buscar a qtde de parcelas na nota

@param cCart	- Define se carteira a pagar ou receber
@param cFil		- Filial do título

@return nParc - Número de parcelas do título

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function QtdeParc(cCart As Character, cFil As Character) As Numeric
	Local nParc		As Numeric
	Local aArea		As Array
	Local cAlias	As Array
	Local cFilSE	As Character
	
	nParc	:= 1
	aArea	:= {}
	cAlias	:= GetNextAlias()

	If cCart == 'R'
		aArea	:= SE1->(GetArea())
		cFilSE	:= SubStr(cFil,1,__nFilSE1)
		If __nFilSE1 == 0
			cFilSE	:= " "
		EndIf
		BeginSql Alias cAlias
			Select count(E1_NUM) QTDE
			From %Table:SE1% SE1
			Where E1_FILIAL 	= %exp:cFilSE%
				And E1_PREFIXO 	= %exp:TRB100->PREFIXO%
				And E1_NUM 		= %exp:TRB100->NUMDOC%
				And E1_TIPO		= %exp:TRB100->E5_TIPO%
				And SE1.%NotDel%
			Group By E1_NUM
		EndSql
	Else
		aArea	:= SE2->(GetArea())
		cFilSE	:= SubStr(cFil,1,__nFilSE2)
		If __nFilSE2 == 0
			cFilSE	:= " "
		EndIf
		BeginSql Alias cAlias
			Select count(E2_NUM) QTDE
			From %Table:SE2% SE2
			Where E2_FILIAL 	= %exp:cFilSE%
				And E2_PREFIXO 	= %exp:TRB100->PREFIXO%
				And E2_NUM 		= %exp:TRB100->NUMDOC%
				And E2_TIPO		= %exp:TRB100->E5_TIPO%
				And E2_FORNECE	= %exp:TRB100->CLIFOR%
				And E2_LOJA		= %exp:TRB100->LOJA%
				And SE2.%NotDel%
			Group By E2_NUM
		EndSql
	EndIf

	nParc	:= (cAlias)->QTDE
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return If( nParc == 0, 1, nParc )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} BcoAdto()
Função para buscar o banco do adiantamento compensado

@return cBco - Banco do adiantamento

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function BcoAdto() As Character
	Local cBco 		As Character
	Local cQry		As Character
	Local cTrbBcAdt	As Character
	Local cTmpBco	As Character
	
	cTmpBco		:= __oTmpBco:GetRealName()
	
	cBco 		:= '999'
	cQry		:= ""
	cTrbBcAdt	:= "BCOADT"

	If TRB100->RECPAG == 'R'
		cQry	:= " Select BCORA.COD, E5_MOTBX MOTBX, E5_MOEDA MOEDA "
		cQry	+= " From " + RetSqlName("SE5") + " SE5 "
		cQry	+= " Left Join " + cTmpBco + " BCORA "
		cQry	+= " ON E5_BANCO = BCORA.BANCO AND E5_AGENCIA = BCORA.AGENCIA AND E5_CONTA = BCORA.CONTA "
		If TRB100->E5_TIPO $ MVRECANT
			cQry	+= " Where E5_FILIAL = '" + TRB100->SEFIL + "' AND E5_TIPO = '" + TRB100->E5_TIPO + "' "
			cQry	+= " AND E5_PREFIXO = '" + TRB100->PREFIXO + "' AND E5_NUMERO = '" + TRB100->NUMDOC + "' "
			cQry	+= " AND E5_PARCELA = '" + TRB100->PARC + "' AND E5_BANCO != ' ' "
			cQry	+= " AND E5_CLIFOR = '" + TRB100->CLIFOR + "' AND E5_LOJA = '" + TRB100->LOJA + "' "
		Else
			cQry	+= " Where E5_FILIAL = '" + TRB100->SEFIL + "' AND E5_BANCO != ' ' "
			cQry	+= " AND E5_PREFIXO || E5_NUMERO || E5_PARCELA || E5_TIPO || E5_LOJA IN ( "
			cQry	+= " Select SE5A.E5_PREFIXO || SE5A.E5_NUMERO || SE5A.E5_PARCELA || SE5A.E5_TIPO || SE5A.E5_LOJA "
			cQry	+= " From " + RetSqlName("SE5") + " SE5A "
			cQry	+= " Where SE5A.E5_FILIAL = '" + TRB100->SEFIL + "' AND SE5A.E5_DOCUMEN = '" + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + TRB100->E5_TIPO + TRB100->LOJA + "' "
			cQry	+= " AND SE5A.D_E_L_E_T_ = ' ' ) 	"
		EndIf
		cQry	+= " AND SE5.D_E_L_E_T_ = ' ' "
	Else
		cQry	:= " Select BCOPA.COD, E5_MOTBX MOTBX, E5_MOEDA MOEDA "
		cQry	+= " From " + RetSqlName("SE5") + " SE5 "
		cQry	+= " Left Join " + cTmpBco + " BCOPA "
		cQry	+= " ON E5_BANCO = BCOPA.BANCO AND E5_AGENCIA = BCOPA.AGENCIA AND E5_CONTA = BCOPA.CONTA "
		If TRB100->E5_TIPO $ MVPAGANT
			cQry	+= " Where E5_FILIAL = '" + TRB100->SEFIL + "' AND E5_TIPO IN " + FormatIn(MVPAGANT, "|") + " "
			cQry	+= " AND E5_PREFIXO = '" + TRB100->PREFIXO + "' AND E5_NUMERO = '" + TRB100->NUMDOC + "' "
			cQry	+= " AND E5_PARCELA = '" + TRB100->PARC + "' AND E5_BANCO != ' ' "
			cQry	+= " AND E5_CLIFOR = '" + TRB100->CLIFOR + "' AND E5_LOJA = '" + TRB100->LOJA + "' "
		Else
			cQry	+= " Where E5_FILIAL = '" + TRB100->SEFIL + "' AND E5_BANCO != ' ' "
			cQry	+= " AND E5_PREFIXO || E5_NUMERO || E5_PARCELA || E5_TIPO || E5_CLIFOR || E5_LOJA IN ( "
			cQry	+= " Select SE5A.E5_PREFIXO || SE5A.E5_NUMERO || SE5A.E5_PARCELA || SE5A.E5_TIPO || SE5A.E5_CLIFOR || SE5A.E5_LOJA "
			cQry	+= " From " + RetSqlName("SE5") + " SE5A "
			cQry	+= " Where SE5A.E5_FILIAL = '" + TRB100->SEFIL + "' AND SE5A.E5_DOCUMEN = '" + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + TRB100->E5_TIPO + TRB100->CLIFOR + TRB100->LOJA + "' "
			cQry	+= " AND SE5A.D_E_L_E_T_ = ' ' ) "
		EndIf
		cQry	+= " AND SE5.D_E_L_E_T_ = ' ' "
	EndIf

	cQry	:= ChangeQuery(cQry)
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cTrbBcAdt, .F., .T.)

	If !Empty((cTrbBcAdt)->COD)
		cBco 	:= (cTrbBcAdt)->COD
	ElseIf (cTrbBcAdt)->MOTBX == 'ESP' .OR. (cTrbBcAdt)->MOEDA == 'R$'
		cBco	:= "000"
	Else
		cBco	:= "999"
	EndIf
	(cTrbBcAdt)->(DbCloseArea())

Return cBco

//------------------------------------------------------------------------------
/*/	{Protheus.doc} NumBaixas()
Função para buscar a qtde de baixas válidas do título

@return nBaixas - Qtde de baixas válidas do título

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function NumBaixas() As Numeric
	Local nBaixas	As Numeric
	Local cQry		As Character
	Local cTrbBxs	As Character
	
	cQry	:= ""
	cTrbBxs	:= "TRBBXS"
	nBaixas	:= 0
	
	cQry	:= " Select Count(E5_NUMERO) QTDBX "
	cQry	+= " From " + RetSqlName("SE5") + " SE5 "
	cQry	+= " Where E5_FILIAL = '" + TRB100->SEFIL + "' AND E5_TIPO = '" + TRB100->E5_TIPO + "' "
	cQry	+= " AND E5_PREFIXO = '" + TRB100->PREFIXO + "' AND E5_NUMERO = '" + TRB100->NUMDOC + "' "
	cQry	+= " AND E5_CLIFOR = '" + TRB100->CLIFOR + "' AND E5_LOJA = '" + TRB100->LOJA + "' "
	cQry	+= " And E5_SITUACA NOT IN ('C','E','X') AND NOT EXISTS ( "
	cQry	+= " 	SELECT SE5ES.E5_NUMERO "
	cQry	+= " 		FROM " + RetSqlName("SE5") + " SE5ES "
	cQry	+= " 	    	WHERE SE5ES.E5_FILIAL  = SE5.E5_FILIAL "
	cQry	+= " 	    		AND SE5ES.E5_PREFIXO = SE5.E5_PREFIXO "
	cQry	+= " 				AND SE5ES.E5_NUMERO  = SE5.E5_NUMERO "
	cQry	+= " 				AND SE5ES.E5_NUMCHEQ = ' ' "
	cQry	+= " 		   		AND SE5ES.E5_PARCELA = SE5.E5_PARCELA "
	cQry	+= " 		   		AND SE5ES.E5_TIPO    = SE5.E5_TIPO "
	cQry	+= " 				AND SE5ES.E5_CLIFOR  = SE5.E5_CLIFOR " 
	cQry	+= " 		   		AND SE5ES.E5_LOJA    = SE5.E5_LOJA "
	cQry	+= " 				AND SE5ES.E5_SEQ     = SE5.E5_SEQ "
	cQry	+= " 		        AND SE5ES.E5_BANCO   = SE5.E5_BANCO " 
	cQry	+= " 		        AND SE5ES.E5_AGENCIA = SE5.E5_AGENCIA " 
	cQry	+= " 		        AND SE5ES.E5_CONTA   = SE5.E5_CONTA "
	cQry	+= " 		        AND SE5ES.E5_TIPODOC = 'ES' "
	cQry	+= " 		        AND SE5ES.E5_ORIGEM <> 'FINA100 ' AND SE5ES.E5_KEY NOT LIKE '%PA%' "
	cQry	+= "		        AND SE5ES.D_E_L_E_T_ = ' ' ) "
	cQry	+= " 	AND SE5.D_E_L_E_T_ = ' ' "

	cQry	:= ChangeQuery(cQry)
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cTrbBxs, .F., .T.)

	If !Empty((cTrbBxs)->QTDBX)
		nBaixas 	:= (cTrbBxs)->QTDBX
	EndIf
	(cTrbBxs)->(DbCloseArea())

Return nBaixas

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Fn820Abat()
Função para identificar se o título é abatimento.

@param cCart	- Define se carteira a pagar ou receber
@param cFil		- Filial do título

@return lRet - Retorna se é um abatimento

@author	Simone Mie Sato Kakinoana
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function Fn820Abat(cCart As Character, cTipo As Character) As Logic

Local lRet As Logical

If cCart == "P"
	lRet := cTipo $ "|TX |TXA|AB-|IR-|" + MVPAGANT 
Else	
	lRet := cTipo $  "|TX |TXA|AB-|FB-|FC-|FU-|FE-|IN-|IS-|AB-|PIS|COF|CSL|CF-|CS-|INS|IRF|PI- |"+MVRECANT+"|" +MV_CRNEG
EndIf

Return(lRet)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FMoedTit()
Função para verificar se a moeda do título é igual a do banco.

@param cMoeda	- Moeda do banco da movimentação
@param cFilOri	- Filial de origem do título
@param nVlCruz	- Variável com o valor em reais

@return lRet - Retorna se a moeda é igual

@author	Rodrigo.oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function FMoedTit(cMoeda As Character, cFilOri As Character, nVlCruz As Numeric) As Logical

	Local lRet	:= .F.
	Local aArea := {}
	Local nMoed	:= 0
	
	__nDecs := MsDecimais(Val(cMoeda))

	If TRB100->RECPAG == 'R'
		nMoed	:= Val(cMoeda)
		aArea 	:= SE1->(GetArea())
		SE1->(DbSetOrder(1))
		If SE1->(DbSeek(xFilial("SE1", cFilOri) + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + ;
			TRB100->E5_TIPO) )
			If nMoed == SE1->E1_MOEDA
				nVlCruz := xMoeda(TRB100->VALOR,nMoed,1,TRB100->DDATA,__nDecs + 1,If(__nTxMoeda > 1, __nTxMoeda, If( SE1->E1_TXMOEDA <> 0, SE1->E1_TXMOEDA, RecMoeda(TRB100->DDATA,nMoed))) )
				lRet	:= .T.
			EndIf
		EndIf
		RestArea(aArea)
	ElseIf TRB100->RECPAG == 'P'
		nMoed	:= Val(cMoeda)
		aArea 	:= SE2->(GetArea())
		SE2->(DbSetOrder(1))
		If SE2->(DbSeek(xFilial("SE2", cFilOri) + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + ;
			TRB100->E5_TIPO + TRB100->CLIFOR + TRB100->LOJA) )
			If nMoed == SE2->E2_MOEDA
				nVlCruz := xMoeda(TRB100->VALOR,nMoed,1,TRB100->DDATA,__nDecs + 1,If(__nTxMoeda > 1, __nTxMoeda, If( SE2->E2_TXMOEDA <> 0, SE2->E2_TXMOEDA, RecMoeda(TRB100->DDATA,nMoed))) )
				lRet	:= .T.
			EndIf
		EndIf
		RestArea(aArea)
	EndIf 

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} SldCred()
Função para retornar saldo das devoluções / Compensação com NCC e NDF

@return nValRet - Valor devolvido da nota

@author	Rodrigo.oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function SldCred() As Numeric
	Local aStrCrd 	As Array
	Local nValRet	As Numeric
	Local cRepl		As Character
	Local cDocumen 	As Character
	Local cQuery	As Character

	aStrCrd		:= {}
	nValRet		:= 0
	cRepl		:= ""
	cDocumen	:= ""
	cQuery		:= ""

	If __oTSlCred == Nil
		aAdd(aStrCrd, {'DOCUMEN', 'C', TAMSX3("E5_DOCUMEN")[1],0})
		aAdd(aStrCrd, {'SLDCRED', 'N', TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
		
		__oTSlCred := FwTemporaryTable():New( 'TRCRED' )
		__oTSlCred:SetFields(aStrCrd)
		__oTSlCred:AddIndex('1', {'DOCUMEN'})
			
		__oTSlCred:Create()
	EndIf
		
	If TRB100->RECPAG == 'R'
		cDocumen	:= TRB100->(PREFIXO + NUMDOC + PARC + E5_TIPO + LOJA)
	ElseIf TRB100->RECPAG == 'P'
		cDocumen	:= TRB100->(PREFIXO + NUMDOC + PARC + E5_TIPO + CLIFOR + LOJA)
	EndIf

	If TRCRED->(DbSeek(cDocumen))
		nValRet := TRCRED->SLDCRED
	Else
		If TRB100->RECPAG == 'R'
			If __oCredRec == NIL
				cQuery := "SELECT E5_DOCUMEN, SUM(E5_VALOR) SLDCRED"
				cQuery += " FROM " + RetSqlName('SE5') + " SE5"
				cQuery += " WHERE"
				cQuery += " E5_DOCUMEN = ? AND"
				cQuery += " E5_TIPO IN " + FormatIn(MV_CRNEG,'|') + " AND"
				cQuery += " SE5.D_E_L_E_T_ = ' '"
				cQuery += " GROUP BY E5_DOCUMEN"
				
				cQuery := ChangeQuery(cQuery)
				__oCredRec:=FWPreparedStatement():New(cQuery)
			EndIf
			
			__oCredRec:SetString(1,cDocumen)
			cQuery := __oCredRec:GetFixQuery()
		ElseIf TRB100->RECPAG == 'P'
			If __oCredPag == NIL
				cQuery := "SELECT E5_DOCUMEN, SUM(E5_VALOR) SLDCRED"
				cQuery += " FROM " + RetSqlName('SE5') + " SE5"
				cQuery += " WHERE"
				cQuery += " E5_DOCUMEN = ? AND"
				cQuery += " E5_TIPO IN " + FormatIn(MV_CPNEG,'|') + " AND"
				cQuery += " SE5.D_E_L_E_T_ = ' '"
				cQuery += " GROUP BY E5_DOCUMEN"
				
				cQuery := ChangeQuery(cQuery)
				__oCredPag:=FWPreparedStatement():New(cQuery)
			EndIf
			
			__oCredPag:SetString(1,cDocumen)
			cQuery := __oCredPag:GetFixQuery()
			
		EndIf
		
		nValRet := MpSysExecScalar(cQuery,"SLDCRED")
		If !Empty(cQuery)
			cRepl := "INSERT INTO " + __oTSlCred:GetRealName()
			cRepl += " (DOCUMEN, SLDCRED) "
			cRepl += " ( " + cQuery + ") "
			TCSQLEXEC(cRepl)
		EndIf
	EndIf

Return nValRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FPntVirg()
Função para substituição do '|' por ';' no arquivo CSV

@author	Rodrigo.oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function FPntVirg(cFile As Character)
	Local lRet 		As Logical
	Local nHandle	As Numeric
	Local nHndl		As Numeric
	Local nTot		As Numeric
	Local nI		As Numeric
	Local cBuffer	As Character

	lRet	:= .T.
	nHandle	:= 0
	nI		:= 0

	If ( nHndl := FOpen(cFile + ".csv", FO_WRITE) ) > 0 
		If (nHandle := FT_FUse(AllTrim(cFile + ".txt"))) == -1
			Help(" ",1,"NOFILEIMPOR")
			lRet:= .F.
		EndIf
	Else
		Help(" ",1,"NOFILEIMPOR")
		lRet:= .F.
	EndIf

	If lRet
		nTot := FT_FLASTREC()
		FT_FGOTOP()

		For nI := 1 to nTot
			cBuffer	:= FT_FREADLN()
			FWrite(nHndl,StrTran(cBuffer, "|", ";") + ";" + ENTER)
			FT_FSKIP()
		Next
	EndIf

    FT_FUSE(cFile + ".txt")                   // Fecha arquivo

	FClose(cFile + ".csv")

Return
