#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"       
#INCLUDE "FWADAPTEREAI.CH"     
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "MATA476.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define para tratamento do IVA Ajustado³       
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE __UFORI  01
#DEFINE __ALQORI 02
#DEFINE __PROPOR 03

#DEFINE SMMARCA	   1
#DEFINE SMCODTRAN  2
#DEFINE SMNOMETRAN 3
#DEFINE SMVALOR    4
#DEFINE SMPRAZO    5

#DEFINE SMNUMCALC	6	
#DEFINE SMCLASSFRE 	7
#DEFINE SMTIPOPER  	8
#DEFINE SMTRECHO   	9
#DEFINE SMTABELA  	10
#DEFINE SMNUMNEGOC 	11
#DEFINE SMROTA     	12
#DEFINE SMDATVALID 	13
#DEFINE SMFAIXA    	14
#DEFINE SMTIPOVEI	15       
#DEFINE SMEXISTMP	16                        

Static aFreteP	:= {}          

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA475
	Funciones genéricas utilizadas por Monitor de Remitos (MATA475)

	@type Function
	@author Thiago Berna
	@since 11/01/2019
	@version 1.0
	@example
	MATA476(nOpc, lRetTotal, aRefRentab, aCols)
	@return Nil
	@see (links_or_references)
	/*/
//-------------------------------------------------------------------
Function MATA476( nOpc, lRetTotal, aRefRentab,aCols)

	Local aArea		:= GetArea()
	Local aAreaSA1	:= SA1->(GetArea())
	Local aFisGet	:= {}
	Local aFisGetSF2:= {}
	Local aTitles   := {STR0001,STR0002,STR0003} //"Invoice" - "Trade Notes" -  "Profitability"
	Local aDupl		:= {}
	Local aVencto   := {}
	Local aEntr     := {}
	Local aNfOri    := {}
	Local aRFHead   := { RetTitle("D2_COD"),RetTitle("D2_PRCVEN"),STR0004,STR0005,STR0006,STR0007} //"C.G.S" - "Val.Present" - "Gros.Profit" - "Contribution Margin(%)"
	Local aRentab   := {}
	Local nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_LOCAL"})
	Local nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_TOTAL"})
	Local nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="D2_DESCON"})
	Local nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_PRUNIT"})
	Local nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_PRCVEN"})
	Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_QUANT"})
	Local nPDtEntr  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_ENTREG"})
	Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="D2_COD"})
	Local nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="D2_TES"})
	Local nPCodRet  := ''
	Local nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_NFORI"})
	Local nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_SERIORI"})
	Local nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="D2_ITEMORI"})
	Local nPIdentB6 := 0//aScan(aHeader,{|x| AllTrim(x[2])=="D2_IDENTB6"})
	Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="D2_ITEM"})
	Local nPosCfo	:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_CF"})
	Local nPAbatISS := 0//aScan(aHeader,{|x| AllTrim(x[2])=="D2_ABATISS"})
	Local nPLote    := aScan(aHeader,{|x| AllTrim(x[2])=="D2_LOTECTL"})
	Local nPSubLot	:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_NUMLOTE"})
	Local nPClasFis := aScan(aHeader,{|x| AllTrim(x[2])=="D2_CLASFIS"})
	Local nPSuframa := 0      
	Local nUsado    := Len(aHeader)
	Local nX        := 0
	Local nX1       := 0
	Local nAcerto   := 0
	Local nPrcLista := 0
	Local nValMerc  := 0
	Local nDesconto := 0
	Local nAcresFin := 0	// Valor do acrescimo financeiro do total do item
	Local nQtdPeso  := 0
	Local nRecOri   := 0
	Local nPosEntr  := 0
	Local nItem     := 0
	Local nY        := 0 
	Local nPosCpo   := 0
	Local nPropLot  := 0
	Local lDtEmi    := .T.//SuperGetMv("MV_DPDTEMI",.F.,.T.)
	Local dDataCnd  := M->F2_EMISSAO
	Local oDlg

	Local oFolder
	Local oRentab
	Local lCondVenda := .F. // Template GEM
	Local aRentabil := {}
	Local cProduto  := ""
	Local nTotDesc  := 0
	Local lSaldo    := .T.//MV_PAR04 == 1 .And. !INCLUI
	Local nQtdEnt   := 0
	Local lM410Ipi	:= .F.//ExistBlock("M410IPI")
	Local lM410Icm	:= .F.//ExistBlock("M410ICM")
	Local lM410Soli	:= .F.//ExistBlock("M410SOLI")
	Local lUsaVenc  := .F.
	Local lIVAAju   := .F.
	Local lRastro	 := .F.//ExistBlock("MAFISRASTRO")
	Local lRastroLot := .F.
	Local aSolid	:= {}
	Local nLancAp	:=	0
	Local aTransp	:= {"",""}
	Local aSaldos	:= {}
	Local aInfLote	:= {}
	Local a410Preco := {}  // Retorno da Project Function P_410PRECO com os novos valores das variaveis {nValMerc,nPrcLista}
	Local nAcresUnit:= 0	// Valor do acrescimo financeiro do valor unitario
	Local nAcresTot := 0	// Somatoria dos Valores dos acrescimos financeiros dos itens
	Local cEstado	:= SuperGetMv("MV_ESTADO") 
	Local cTesVend  :=  SuperGetMv("MV_TESVEND",,"")
	Local cCliPed   := "" 
	Local lCfo      := .F.
	Local nlValor	:= 0
	Local lM410FldR := .T.
	Local aTotSolid := {}            
	Local nValTotal := 0 //Valor total utilizado no retorno quando lRetTotal for .T.
	Local nTotal	:= 0
	Local aValMerc	:= {}
	Local lRent      := .F.//AllTrim(FunName()) $ "MATA851|MATA852|MATA853" //Verifica se é executado pelos programas de rentabilidade
	Local lContinua  := .F. 
	Local nAliqISS  := 0
	Local nVMercAux := 0
	Local nPrcLsAux := 0
	Local nPDesCab	:= 0
	Local nTotPeso 	:= 0
	Local lM410Vct	:= ExistBlock("M410VCT")
	Local nPFciCod := 0//aScan(aHeader,{|x| AllTrim(x[2])=="D2_FCICOD"})
	Local cCodOrig := ""
	Local lMvFisFras := SuperGetMv("MV_FISFRAS",.F.,.F.)
	Local lMvFISAUCF := SuperGetMv("MV_FISAUCF",.F.,.F.)
	Local nMoeda	 := 1
	Local nValIpiTrf := 0
	Local nPIPITrf	 := 0//Ascan(aHeader,{|x| Trim(x[2]) == "D2_IPITRF"})
	Local nPosItem  := 0
	Local nPosIt15	:= 0
	Local nPosIt20	:= 0
	Local nPosIt25	:= 0
	Local nLinINS	:= 0
	Local nAIS		:= {}
	Local aAIS		:= {}
	Local nPItSD2	:= 0
	Local nACols	:= 0

	Local nISSNDesc := 0
	Local nValISS   := 0
	Local nTotTit   := 0
	Local lDescISS	:= SuperGetMV("MV_DESCISS",,.F.)
	Local lTpAbISS	:= SuperGetMV("MV_TPABISS",,"") == "1"
	Local nVRetISS	:= SuperGetMV("MV_VRETISS",,0)
	Local nPTpOper  := 0//aScan(aHeader,{|x| AllTrim(x[2])=="D2_OPER"})

	Local aColsFin	:= {}
	Local aColsOri	:= {}
	Local oDupl

	Local aHFin		:= {}
	Local aFields	:= {}
	Local nCount	:= 0
	Local cTesAnt	:= ''
	Local aCposSD2	:= FwSX3Util():GetListFieldsStruct("SD2", .T. )
	Local aCposSF2	:= FwSX3Util():GetListFieldsStruct("SF2", .T. )
	Local aCposAIS	:= FwSX3Util():GetListFieldsStruct("AIS", .T. )
	Local cCpoVal	:= ""
	Local nPosnX	:= 0

	Default lRetTotal 	:= .F.
	Default aRefRentab 	:= {}

	PRIVATE oLancApICMS
	PRIVATE _nTotOper_ := 0		//total de operacoes (vendas) realizadas com um cliente - calculo de IB - Argentina
	Private _aValItem_ := {}

	aPe 		:= Nil
	cEspecie	:= Nil

	If FunName() == 'MATA462N' //.Or. FunName() == 'MATA462AN'
		cTesAnt 	:= aCols[OGETDADOS:OBROWSE:NAT,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TES"} )]
		M->D2_TES 	:= '***'
		RunTrigger(2,OGETDADOS:OBROWSE:NAT,nil,,'D2_TES')
		MaFisAlt('IT_TES','***',OGETDADOS:OBROWSE:NAT)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca referencias no SD2                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFisGet	:= {}
	For nX := 1 To Len(aCposSD2)
		cCpoVal := AllTrim(aCposSD2[nX,1])
		cValid := UPPER(GetSX3Cache(cCpoVal,"X3_VALID") + GetSX3Cache(cCpoVal,"X3_VLDUSER"))
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGet,{cReferencia,cCpoVal,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT100",',cValid)-nPosIni)
			aAdd(aFisGet,{cReferencia,cCpoVal,MaFisOrdem(cReferencia)})
		EndIf
	Next nX
	aSort(aFisGet,,,{|x,y| x[3]<y[3]})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca referencias no SF2                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFisGetSF2	:= {}
	For nX := 1 To Len(aCposSF2)
		cCpoVal := AllTrim(aCposSF2[nX,1])
		cValid := UPPER(GetSX3Cache(cCpoVal,"X3_VALID") + GetSX3Cache(cCpoVal,"X3_VLDUSER"))
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGetSF2,{cReferencia,cCpoVal,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT100",',cValid)-nPosIni)
			aAdd(aFisGetSF2,{cReferencia,cCpoVal,MaFisOrdem(cReferencia)})
		EndIf
	Next nX
	aSort(aFisGetSF2,,,{|x,y| x[3]<y[3]})

	SA4->(dbSetOrder(1))
	If SA4->(dbSeek(xFilial("SA4")+M->F2_TRANSP)) 
		aTransp[01] := SA4->A4_EST
		aTransp[02] := ""
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a funcao fiscal                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A Consultoria Tributária, por meio da Resposta à Consulta nº 268/2004, determinou a aplicação das seguintes alíquotas nas Notas Fiscais de venda emitidas pelo vendedor remetente:                                                                         ³
	//³1) no caso previsto na letra "a" (venda para SP e entrega no PR) - aplicação da alíquota interna do Estado de São Paulo, visto que a operação entre o vendedor remetente e o adquirente originário é interna;                                              ³
	//³2) no caso previsto na letra "b" (venda para o DF e entrega no PR) - aplicação da alíquota interestadual prevista para as operações com o Paraná, ou seja, 12%, visto que a circulação da mercadoria se dá entre os Estado de São Paulo e do Paraná.       ³
	//³3) no caso previsto na letra "c" (venda para o RS e entrega no SP) - aplicação da alíquota interna do Estado de São Paulo, uma vez que se considera interna a operação, quando não se comprovar a saída da mercadoria do território do Estado de São Paulo,³
	//³ conforme previsto no art. 36, § 4º do RICMS/SP                                                                                                                                                                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If len(aCols) > 0
		If cEstado == 'SP'
			If !Empty(M->F2_CLIENTE) .And. M->F2_CLIENTE <> M->F2_CLIENTE
				For nX := 1 To Len(aCols)
					If Alltrim(aCols[nX][nPTES])$ Alltrim(cTesVend)
						lCfo:= .T.
					EndIf
				Next		   	
				If lCfo		
					dbSelectArea(IIF(M->F2_TIPO$"DB","SA2","SA1"))
					dbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA o A2_FILIAL+A2_COD+A2_LOJA
					MsSeek(xFilial()+M->F2_CLIENTE+M->F2_LOJA)
					If Iif(M->F2_TIPO$"DB", SA2->A2_EST,SA1->A1_EST) == 'SP'
						cCliPed := M->F2_CLIENTE
					Else
						cCliPed := M->F2_CLIENTE
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	MaFisSave()
	MaFisEnd()
	aEval(aCols,{|x| nTotal += a410Arred( If(x[Len(x)],0,x[nPTotal]+(x[nPTotal]*0/100)),"D2_TOTAL")})
	nTotal+= (M->F2_FRETE+M->F2_DESPESA+M->F2_SEGURO)

	MaFisIni(	M->F2_CLIENTE,;// 1-Codigo Cliente/Fornecedor
				M->F2_LOJA,;		// 2-Loja do Cliente/Fornecedor
				IIF(ValType(M->F2_TIPO) == 'U','C',IIf(M->F2_TIPO$'DB',"F","C")),;				// 3-C:Cliente , F:Fornecedor 
				IIF(ValType(M->F2_TIPO) == 'U','N',M->F2_TIPO),;				// 4-Tipo da NF
				SA1->A1_TIPO,;		// 5-Tipo do Cliente/Fornecedor
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				"MATA461",;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				aTransp,;
				Nil,;
				Nil,;
				Nil,;
				M->F2_CLIENTE,;
				M->F2_LOJA,;
				nTotal,;
				Nil,;
				IIF(ValType(M->F2_TPFRETE) == 'U','',M->F2_TPFRETE),;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD2","D2_IDTRIB"), .F.),;
				Len(aCols))
	
	If SuperGetMV("MV_ISSXMUN",.F.,.F.)
		If !Empty(M->F2_MUNPRES)
			MaFisLoad("NF_CODMUN",AllTrim(M->F2_MUNPRES))
		EndIf

		If !Empty(M->F2_ESTPRES)
			MaFisLoad("NF_UFPREISS",AllTrim(M->F2_ESTPRES))
		EndIf
	EndIf

	If cPaisLoc<>"BRA"
		MaFisAlt('NF_MOEDA',M->F2_MOEDA)
	Else
		nMoeda := M->F2_MOEDA
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrega os itens para a funcao fiscal         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPTotal > 0 .And. nPValDesc > 0 .And. nPPrUnit > 0 .And. nPProduto > 0 .And. nPQtdVen > 0 .And. nPTes > 0
		For nX := 1 To Len(aCols)
			nQtdPeso := 0

			nItem++

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona Registros                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lSaldo .And. nPItem > 0
				nQtdEnt := aCols[nX][aScan(aHeader,{|x| AllTrim(x[2])=="D2_QTDEDEV"})]//SD2->D2_QUANT
			Else
				lSaldo := .F.
			EndIf

			cProduto := aCols[nX][nPProduto]
			MatGrdPrRf(@cProduto)
			SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
			If SB1->(MsSeek(xFilial("SB1")+cProduto))
				nQtdPeso := If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*SB1->B1_PESO
			EndIf
			If nPIdentB6 <> 0 .And. !Empty(aCols[nX][nPIdentB6])
				SD1->(dbSetOrder(4)) //D1_FILIAL+D1_NUMSEQ
				If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPIdentB6]))
					nRecOri := SD1->(Recno())
				EndIf
			ElseIf nPNfOri > 0 .And. nPSerOri > 0 .And. nPItemOri > 0
				If !Empty(aCols[nX][nPNfOri]) .And. !Empty(aCols[nX][nPItemOri])
					SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPNfOri]+aCols[nX][nPSerOri]+M->F2_CLIENTE+M->F2_LOJA+aCols[nX][nPProduto]+aCols[nX][nPItemOri]))
						nRecOri := SD1->(Recno())
					EndIf
				EndIf
			EndIf
			SB2->(dbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
			SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD+aCols[nX][nPLocal]))
			SF4->(dbSetOrder(1)) //F4_FILIAL+F4_CODIGO
			SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))

			IF nRecOri == 0 .And. SF4->(ColumnPos("F4_INDVF")) > 0 .And. nPNfOri > 0 .And. nPSerOri > 0
				SD2->(dbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				IF SD2->(MSSeek(xFilial("SD2")+aCols[nX][nPNfOri]+aCols[nX][nPSerOri]))
					nRecOri := SD2->(Recno())
				Endif 
			EndIf   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o preco de lista                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValMerc  := If(aCols[nX][nPQtdVen]==0,aCols[nX][nPTotal],If(lSaldo,(aCols[nX][nPQtdVen]-nQtdEnt)*aCols[nX][nPPrcVen],aCols[nX][nPTotal]))
			nPrcLista := aCols[nX][nPPrUnit]
			If ( nPrcLista == 0 )
				nValMerc  := If(aCols[nX][nPQtdVen]==0,aCols[nX][nPTotal],If(lSaldo,(aCols[nX][nPQtdVen]-nQtdEnt)*aCols[nX][nPPrcVen],aCols[nX][nPTotal]))
			EndIf
			nAcresUnit:= 0//A410Arred(aCols[nX][nPPrcVen]*0/100,"D2_PRCVEN")
			nAcresFin := A410Arred(If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*nAcresUnit,"D2_TOTAL")
			nAcresTot += nAcresFin
			nValMerc  += nAcresFin
			If GetNewPar("MV_NDESCTP",.F.) .And. aCols[nX][nPValDesc] == 0 .And. nPrcLista > 0
				nPrcLista := A410Arred(nValMerc / If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]) ,"D2_TOTAL")
				nDesconto := a410Arred(aCols[nX][nPPrUnit]*If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]),"D2_DESCON")-nValMerc
			Else
				nDesconto := a410Arred(nPrcLista*If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]),"D2_DESCON")-nValMerc
			EndIf
			nDesconto := IIf(nDesconto<=0,aCols[nX][nPValDesc],nDesconto)
			nDesconto := Max(0,nDesconto)
			nPrcLista += nAcresUnit
			//Para os outros paises, este tratamento e feito no programas que calculam os impostos.
			If cPaisLoc=="BRA" .or. (GetNewPar('MV_DESCSAI','1') == "2" .And. cPaisLoc <> "ARG")
				nValMerc  += nDesconto
			Endif
			If cPaisLoc == "ARG" .And. GetNewPar('MV_DESCSAI','1') == "2" .And. nopc == 3   
				nValMerc  += nDesconto	
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica a data de entrega para as duplicatas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( nPDtEntr > 0 )
				If ( dDataCnd > aCols[nX][nPDtEntr] .And. !Empty(aCols[nX][nPDtEntr]) )
					dDataCnd := aCols[nX][nPDtEntr]
				EndIf
			Else
				dDataCnd  := M->F2_EMISSAO
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento do IVA Ajustado                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
			If SB1->(MsSeek(xFilial("SB1")+cProduto))
				lIVAAju := IIf(cPaisLoc == "BRA", IIF(SB1->(SB1->B1_IVAAJU) == '1' .And. (IIF(lRastro,lRastroLot := ExecBlock("MAFISRASTRO",.F.,.F.),Rastro(cProduto,"S"))),.T.,.F.), .F.)			   
			EndIf
			dbSelectArea("SD2")
			SD2->(dbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ
			MsSeek(xFilial("SD2")+M->F2_DOC)
			If lIVAAju
				dbSelectArea("SC9")
				SC9->(dbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
				If MsSeek(xFilial("SC9")+SD2->D2_DOC+SD2->D2_ITEM)
					If ( SC9->C9_BLCRED $ "  10"  .And. SC9->C9_BLEST $ "  10")
						While ( !Eof() .And. SC9->C9_FILIAL == xFilial("SC9") .And.;
						SC9->C9_PEDIDO == SD2->D2_DOC .And.;
						SC9->C9_ITEM   == SD2->D2_ITEM )

							aAdd(aSaldos,{SC9->C9_LOTECTL,SC9->C9_NUMLOTE,,,SC9->C9_QTDLIB})	

							dbSelectArea("SC9")
							dbSkip()
						EndDo
					Else
						dbSelectArea("SD2")
						SD2->(dbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ
						MsSeek(xFilial("SD2")+M->F2_DOC)
						lUsaVenc:= If(!Empty(SD2->D2_LOTECTL+SD2->D2_DOCLOTE),.T.,(SuperGetMv('MV_LOTVENC')=='S'))
						aSaldos := SldPorLote(aCols[nX][nPProduto],aCols[nX][nPLocal],aCols[nX][nPQtdVen]/* nQtdLib*/,0/*nQtdLib2*/,SD2->D2_LOTECTL,SD2->D2_DOCLOTE,SD2->D2_LOCALIZ,SD2->D2_DOCSERI,NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)					
					EndIf
				Else
					dbSelectArea("SD2")
					SD2->(dbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ
					MsSeek(xFilial("SD2")+M->F2_DOC)
					lUsaVenc:= If(!Empty(SD2->D2_LOTECTL+SD2->D2_DOCLOTE),.T.,(SuperGetMv('MV_LOTVENC')=='S'))
					aSaldos := SldPorLote(aCols[nX][nPProduto],aCols[nX][nPLocal],aCols[nX][nPQtdVen]/* nQtdLib*/,0/*nQtdLib2*/,SD2->D2_LOTECTL,SD2->D2_DOCLOTE,SD2->D2_LOCALIZ,SD2->D2_DOCSERI,NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)									
				EndIf
				For nX1 := 1 to Len(aSaldos)
					nPropLot := aSaldos[nX1][5]
					If lRastroLot
						dbSelectArea("SB8")
						SB8->(dbSetOrder(5)) //B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
						If MsSeek(xFilial("SB8")+cProduto+aSaldos[nX][01])
							aAdd(aInfLote,{SB8->B8_DOC,SB8->B8_SERIE,SB8->B8_CLIFOR,SB8->B8_LOJA,nPropLot})
						EndIf		
					Else				
						dbSelectArea("SB8")
						SB8->(dbSetOrder(2)) //B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)
						If MsSeek(xFilial("SB8")+aSaldos[nX][02]+aSaldos[nX][01])
							aAdd(aInfLote,{SB8->B8_DOC,SB8->B8_SERIE,SB8->B8_CLIFOR,SB8->B8_LOJA,nPropLot})
						EndIf
					EndIf
					dbSelectArea("SF3")
					SF3->(dbSetOrder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
					If !Empty(aInfLote)
						If MsSeek(xFilial("SF3")+aInfLote[nX1][03]+aInfLote[nX1][04]+aInfLote[nX1][01]+aInfLote[nX1][02])
							aAdd(aNfOri,{SF3->F3_ESTADO,SF3->F3_ALIQICM,aInfLote[nX1][05],0})
						EndIf
					EndIf
				Next nX1
			EndIf						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Agrega os itens para a funcao fiscal         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisAdd(	cProduto,;   	// 1-Codigo do Produto ( Obrigatorio )
						aCols[nX][nPTES],;	   	// 2-Codigo do TES ( Opcional )
						If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]),;  	// 3-Quantidade ( Obrigatorio )
						IIF(nPrcLista>0,nPrcLista,nValMerc),;		  	// 4-Preco Unitario ( Obrigatorio )
						nDesconto,; 	// 5-Valor do Desconto ( Opcional )
						"",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
						"",;				// 7-Serie da NF Original ( Devolucao/Benef )
						nRecOri,;					// 8-RecNo da NF Original no arq SD1/SD2
						0,;					// 9-Valor do Frete do Item ( Opcional )
						0,;					// 10-Valor da Despesa do item ( Opcional )
						0,;					// 11-Valor do Seguro do item ( Opcional )
						0,;					// 12-Valor do Frete Autonomo ( Opcional )
						nValMerc,;			// 13-Valor da Mercadoria ( Obrigatorio )
						0,;					// 14-Valor da Embalagem ( Opiconal )	
						,;					// 15
						,;					// 16
						Iif(nPItem>0,aCols[nX,nPItem],""),; //17
						0,;					// 18-Despesas nao tributadas - Portugal
						0,;					// 19-Tara - Portugal
						aCols[nX,nPosCfo],; // 20-CFO
						aNfOri,;            // 21-Array para o calculo do IVA Ajustado (opcional)	
						Iif(cPaisLoc=="EQU",aCols[nX,nPCodRet],""),;// 22-Codigo Retencao - Equador
						IIF(nPAbatISS>0,aCols[nX,nPAbatISS],0),; //23-Valor Abatimento ISS
						aCols[nX,nPLote],; // 24-Lote Produto
						aCols[nX,nPSubLot],;	// 25-Sub-Lote Produto
						,;
						,;
						iif(nPClasFis > 0,Iif(Len(Alltrim(aCols[nX,nPClasFis]))==3,aCols[nX,nPClasFis],""),""),; // 28-Classificação fiscal
						,; //29
						,; //30
						,; //31
						,; //32
						IIf(nPTpOper>0,aCols[nX,nPTpOper],"")) // 33 - Tipo de Operação.
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chamada de funcao via Project Function para manipulacao das variaveis nValMerc e nPrcLista       ³
			//³ exclusivamente para o projeto MOTOROLA, nao deve ser utilizado por clientes.                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If FindFunction("P_410PRECO")
				a410Preco := P_410PRECO( nX , nValMerc , nPrcLista )
				If Valtype(a410Preco) == "A"
					nValMerc  := a410Preco[1]
					nPrcLista := a410Preco[2]
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento do IVA Ajustado                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIVAAju
				MaFisLoad("IT_ANFORI2", aNfOri, nItem)			
				aSaldos :={}
				aNfOri  :={}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo do ISS                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(dbSetOrder(1)) //F4_FILIAL+F4_CODIGO
			SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
			If ( M->F2_INCISS == "N" .And. M->F2_TIPO == "N")
				If ( SF4->F4_ISS=="S" )
					nAliqISS := MaAliqISS(nItem)
					nVMercAux := nValMerc
					nPrcLsAux := nPrcLista
					nPrcLista := a410Arred(nPrcLista/(1-(nAliqISS/100)),"D2_PRCVEN")
					nValMerc  := a410Arred(nValMerc/(1-(nAliqISS/100)),"D2_PRCVEN")
					MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
					MaFisAlt("IT_VALMERC",nValMerc,nItem)
				EndIf
			EndIf

			//Acumula ISS abaixo do minimo portanto nao descontou do total do titulo.
			If (MaFisRet(,"NF_RECISS")=="1" .And. lDescISS .And. lTpAbISS) .And.;
			!(SF4->F4_FRETISS == "2" .And. SA1->A1_FRETISS == "2")
				nValISS := MaFisRet(nItem,'IT_VALISS')
				If nValISS <= nVRetISS
					nISSNDesc += nValISS
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera peso para calcular frete              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotPeso += nQtdPeso
			MaFisAlt("IT_PESO",nQtdPeso,nItem)
			MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
			MaFisAlt("IT_VALMERC",nValMerc,nItem)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o valor do campo D2_IPITRF			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPIPITrf > 0 .And. Acols[nX][nPIPITrf] > 0
				nValIpiTrf := Acols[nX][nPIPITrf]
				MaFisAlt("IT_PRCCF",nValIpiTrf,nItem)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Calculo de aposentadoria Especial REINF  ³
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿

			If ChkFile("AIS")

				nPItSD2    := aScan(aHeader,{|x|AllTrim(x[2]) == 'D2_ITEM'})

				If !Empty(MaFisScan("IT_SECP15",.F.))	//Verifica existencia das Referencias Fiscais de Ap. Especial

					If TYPE('aHeaderAIS') <> 'U' .and. TYPE('aColsAIS') <> 'U'

						If nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5 .Or. IsInCallStack("A410COPIA") 	
							aSize(aAIS,0) 

							AIS->(dbSetOrder(1))
							If AIS->(DbSeek(xFilial("AIS") + M->F2_DOC + aCols[nX][nPItem]))
								While AIS->(!Eof()) .and. AIS->AIS_FILIAL == xFilial("AIS")	;
								.and. AIS->AIS_PEDIDO == M->F2_DOC

									nACols := aScan(aCols,{|x   | x[nPItSD2] == AIS->AIS_ITEMPV})	

									If !aCols[nACols][Len(aHeader) + 1] //Verifica se o ítem do pedido ao qual se refere a linha da aposentadoria especial não está deletada

										AADD(aAIS,{AIS->AIS_FILIAL, AIS->AIS_PEDIDO, AIS->AIS_ITEMPV})

									EndIf
									nACols := 0

									AIS->(DbSkip())
								EndDo
							EndIf	

							If Empty(aHeaderAIS)

								If !Empty(aAIS)
									
									For nPosnX := 1 to Len(aCposAIS)
										cCpoVal := AllTrim(aCposAIS[nX,1])
										If X3USO(GetSX3Cache(cCpoVal, "X3_USADO")) .AND. cNivel >= GetSX3Cache(cCpoVal, "X3_NIVEL") 
											aAdd(aHeaderAIS,{ TRIM(FWX3Titulo(cCpoVal))	,;
											GetSX3Cache(cCpoVal, "X3_CAMPO"),;
											GetSX3Cache(cCpoVal, "X3_PICTURE"),;
											GetSX3Cache(cCpoVal, "X3_TAMANHO"),;
											GetSX3Cache(cCpoVal, "X3_DECIMAL"),;
											GetSX3Cache(cCpoVal, "X3_VALID"),;
											GetSX3Cache(cCpoVal, "X3_USADO"),;
											GetSX3Cache(cCpoVal, "X3_TIPO"),;
											GetSX3Cache(cCpoVal, "X3_F3"),;
											GetSX3Cache(cCpoVal, "X3_CONTEXT") } )
										EndIf
									Next nPosnX
								EndIf
							EndIf

							AIS->(dbSetOrder(1))
							For nAis := 01 To Len(aAIS)
								If AIS->(DbSeek(xFilial("AIS") + M->F2_DOC + aAIS[nAis][03]))

									If aScan(aColsAIS, {|aVal| aVal[1] == StrZero(Val(aAis[nAis][03]),TamSx3('AIS_ITEMPV')[1])}) == 0

										aAdd(aColsAIS,{AIS->AIS_ITEMPV,{Array(Len(aHeaderAIS)+1)}})
										For nLinINS := 1 To Len(aHeaderAIS)
											If aHeaderAIS[nLinINS][10] <> "V"
												aColsAIS[Len(aColsAIS)][2][Len(aColsAIS[01][2])][nLinINS] := AIS->(FieldGet(FieldPos(aHeaderAIS[nLinINS][2])))
											EndIf
										Next nLinINS
										aColsAIS[Len(aColsAIS)][2][Len(aColsAIS[01][2])][Len(aHeaderAIS)+1] := .F.
									EndIf

								EndIf
							Next nAis	

						EndIf

						nPosItem := aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_ITEMPV"} )
						nPosIt15 := aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_15ANOS"} )
						nPosIt20 := aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_20ANOS"} )
						nPosIt25 := aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_25ANOS"} )


						For nLinINS := 01 To Len(aColsAIS)

							nACols := aScan(aCols,{|x|x[nPItSD2] == aColsAIS[nLinINS][nPosItem]})				

							If !aCols[nACols][Len(aHeader) + 1] //Verifica se o ítem do pedido ao qual se refere a linha da aposentadoria especial não está deletada

								MaFisAlt("IT_SECP15", aColsAIS[nLinINS][02][01][nPosIt15], nACols) 
								MaFisAlt("IT_SECP20", aColsAIS[nLinINS][02][01][nPosIt20], nACols)
								MaFisAlt("IT_SECP25", aColsAIS[nLinINS][02][01][nPosIt25], nACols)

							EndIf
							nACols := 0
						Next nLinINS
					EndIf
				EndIf	
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Analise da Rentabilidade                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->F4_DUPLIC=="S"
				nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
				If !aCols[nX][nUsado+1]
					nY := aScan(aRentab,{|x| x[1] == aCols[nX][nPProduto]})
					If nY == 0
						aAdd(aRenTab,{aCols[nX][nPProduto],0,0,0,0,0})
						nY := Len(aRenTab)
					EndIf
					aRentab[nY][2] += nValMerc
					aRentab[nY][3] += If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*SB2->B2_CM1
				EndIf	
			Else
				If GetNewPar("MV_TPDPIND","1")=="1"
					nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
				EndIf
			EndIf

			// DCL FISCAl   
			If ExistTemplate("M460ICM")  
				_lPedDCL 	:= .T.
				_BASEICM    := MaFisRet(nItem,"IT_BASEICM")
				_ALIQICM    := MaFisRet(nItem,"IT_ALIQICM")
				_QUANTIDADE := MaFisRet(nItem,"IT_QUANT")
				_VALICM     := MaFisRet(nItem,"IT_VALICM")
				_FRETE      := MaFisRet(nItem,"IT_FRETE")
				_VALICMFRETE:= MaFisRet(nItem,"IT_ICMFRETE")
				_DESCONTO   := MaFisRet(nItem,"IT_DESCONTO")		   
				aIcmTmp 	:= ExecTemplate("M460ICM",.F.,.F., {aCols[nX],aHeader})
				If ValType(aIcmTmp) == "A"
					aIcms := aClone(aIcmTmp)
				EndIf
				If Len(aIcms) == 2                                   			
					MaFisLoad("IT_VALFECP",NoRound(aIcms[1],2),nItem) 
					MaFisLoad("IT_ALIQFECP" ,NoRound(aIcms[2],2),nItem)    					
				EndIf
				MaFisLoad("IT_BASEICM",_BASEICM,nItem)
				MaFisLoad("IT_ALIQICM",_ALIQICM,nItem)
				MaFisLoad("IT_VALICM",_VALICM,nItem)
				MaFisLoad("IT_FRETE",_FRETE,nItem)
				MaFisLoad("IT_ICMFRETE",_VALICMFRETE,nItem)
				MaFisLoad("IT_DESCONTO",_DESCONTO,nItem)
				MaFisEndLoad(nX,1) 		
			Endif

			If ExistTemplate("M460SOLI")  
				_lPedDCL	:= .T.
				ICMSITEM    := MaFisRet(nItem,"IT_VALICM")		// variavel para ponto de entrada		
				QUANTITEM   := MaFisRet(nItem,"IT_QUANT")		// variavel para ponto de entrada
				BASEICMRET  := MaFisRet(nItem,"IT_BASESOL")	// criado apenas para o ponto de entrada
				MARGEMLUCR  := MaFisRet(nItem,"IT_MARGEM")		// criado apenas para o ponto de entrada
				aSolidTmp := ExecTemplate("M460SOLI",.F.,.F.,{aCols[nX],aHeader})
				If ValType(aSolidTmp) == "A"
					aSolid := aClone(aSolidTmp)
				EndIf
				If Len(aSolid) == 5                                   			
					MaFisLoad("IT_BASESOL",NoRound(aSolid[1],2),nItem) 
					MaFisLoad("IT_VALSOL" ,NoRound(aSolid[2],2),nItem)
					MaFisLoad("IT_ALIQSOL" ,NoRound(aSolid[3],2),nItem)
					MaFisLoad("IT_VFECPST" ,NoRound(aSolid[4],2),nItem)
					MaFisLoad("IT_ALFCST" ,NoRound(aSolid[5],2),nItem)
					MaFisEndLoad(nX,1)      					
				EndIf
			EndIf

			If aCols[nX][nUsado+1]
				MaFisDel(nItem,aCols[nX][nUsado+1])	
			EndIf
			Aadd(aValMerc,nValMerc)
		Next nX
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indica os valores do cabecalho               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ]
	If ( ( cPaisLoc == "PER" .Or. cPaisLoc == "COL" ) .And. M->F2_TPFRETE == "F" ) .Or. ( cPaisLoc != "PER" .And. cPaisLoc != "COL" )
		MaFisAlt("NF_PESO",nTotPeso)
		MaFisAlt("NF_FRETE",M->F2_FRETE)
	EndIf
	MaFisAlt("NF_VLR_FRT",M->F2_VLR_FRT)
	MaFisAlt("NF_SEGURO",M->F2_SEGURO)
	MaFisAlt("NF_AUTONOMO",M->F2_FRETAUT)
	MaFisAlt("NF_DESPESA",M->F2_DESPESA)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indenizacao por valor                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->F2_DESCCAB > 0
		MaFisAlt("NF_DESCONTO",nPDesCab:=A410Arred((MaFisRet(,"NF_VALMERC")-nTotDesc)*M->F2_PDESCAB/100,"D2_VALOR")+MaFisRet(,"NF_DESCONTO"))
	EndIf

	If M->F2_DESCONT > 0
		MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,nPDesCab+nTotDesc+M->F2_DESCONT),/*nItem*/,/*lNoCabec*/,/*nItemNao*/,GetNewPar("MV_TPDPIND","1")=="2" )
	EndIf

	If lM410Ipi .Or. lM410Icm .Or. lM410Soli
		nItem := 0
		aTotSolid := {}
		For nX := 1 To Len(aCols)
			nItem++
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada M410IPI para alterar os valores do IPI referente a palnilha financeira           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lM410Ipi 
				VALORIPI    := MaFisRet(nItem,"IT_VALIPI")
				BASEIPI     := MaFisRet(nItem,"IT_BASEIPI")
				QUANTIDADE  := MaFisRet(nItem,"IT_QUANT")
				ALIQIPI     := MaFisRet(nItem,"IT_ALIQIPI")
				BASEIPIFRETE:= MaFisRet(nItem,"IT_FRETE")
				MaFisAlt("IT_VALIPI",ExecBlock("M410IPI",.F.,.F.,{ nItem }),nItem,.T.)
				MaFisLoad("IT_BASEIPI",BASEIPI ,nItem)
				MaFisLoad("IT_ALIQIPI",ALIQIPI ,nItem)
				MaFisLoad("IT_FRETE"  ,BASEIPIFRETE,nItem,"11")
				MaFisEndLoad(nItem,1)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada M410ICM para alterar os valores do ICM referente a palnilha financeira           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lM410Icm
				_BASEICM    := MaFisRet(nItem,"IT_BASEICM")
				_ALIQICM    := MaFisRet(nItem,"IT_ALIQICM")
				_QUANTIDADE := MaFisRet(nItem,"IT_QUANT")
				_VALICM     := MaFisRet(nItem,"IT_VALICM")
				_FRETE      := MaFisRet(nItem,"IT_FRETE")
				_VALICMFRETE:= MaFisRet(nItem,"IT_ICMFRETE")
				_DESCONTO   := MaFisRet(nItem,"IT_DESCONTO")
				ExecBlock("M410ICM",.F.,.F., { nItem } )
				MaFisLoad("IT_BASEICM" ,_BASEICM    ,nItem)
				MaFisLoad("IT_ALIQICM" ,_ALIQICM    ,nItem)
				MaFisLoad("IT_VALICM"  ,_VALICM     ,nItem)
				MaFisLoad("IT_FRETE"   ,_FRETE      ,nItem)
				MaFisLoad("IT_ICMFRETE",_VALICMFRETE,nItem)
				MaFisLoad("IT_DESCONTO",_DESCONTO   ,nItem)
				MaFisEndLoad(nItem,1)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada M410SOLI para alterar os valores do ICM Solidario referente a palnilha financeira³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lM410Soli
				ICMSITEM    := MaFisRet(nItem,"IT_VALICM")		// variavel para ponto de entrada
				QUANTITEM   := MaFisRet(nItem,"IT_QUANT")		// variavel para ponto de entrada
				BASEICMRET  := MaFisRet(nItem,"IT_BASESOL")	    // criado apenas para o ponto de entrada
				MARGEMLUCR  := MaFisRet(nItem,"IT_MARGEM")		// criado apenas para o ponto de entrada
				aSolid := ExecBlock("M410SOLI",.f.,.f.,{nItem}) 
				aSolid := IIF(ValType(aSolid) == "A" .And. Len(aSolid) >= 2, aSolid,{})
				If !Empty(aSolid)
					If Len(aSolid) == 2
						MaFisLoad("IT_BASESOL",NoRound(aSolid[1],2),nItem)
						MaFisLoad("IT_VALSOL" ,NoRound(aSolid[2],2),nItem)
						aAdd(aTotSolid, {nItem, NoRound(aSolid[1], 2), NoRound(aSolid[2], 2)})
					ElseIf Len(aSolid) == 7
						MaFisLoad("IT_BASESOL", NoRound(aSolid[1], 2), nItem)
						MaFisLoad("IT_VALSOL" , NoRound(aSolid[2], 2), nItem)
						MaFisLoad("IT_MARGEM"  ,NoRound(aSolid[3], 2), nItem)
						MaFisLoad("IT_ALIQSOL" ,NoRound(aSolid[4], 2), nItem)
						MaFisLoad("IT_BSFCPST", NoRound(aSolid[5], 2), nItem)
						MaFisLoad("IT_ALFCST" , NoRound(aSolid[6], 2), nItem)
						MaFisLoad("IT_VFECPST", NoRound(aSolid[7], 2), nItem)
						aAdd(aTotSolid, {nItem, NoRound(aSolid[1], 2), NoRound(aSolid[2], 2), NoRound(aSolid[3], 2), NoRound(aSolid[4], 2), NoRound(aSolid[5], 2), NoRound(aSolid[6], 2), NoRound(aSolid[7], 2)})
					EndIf
					MaFisEndLoad(nItem,1)
				Endif
			EndIf
		Next
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza alteracoes de referencias do SD2         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD2")
	If Len(aFisGet) > 0 .And. !ExistTemplate("M460ICM")
		For nX := 1 to Len(aCols)
			If Len(aCols[nX])==nUsado .Or. !aCols[nX][Len(aHeader)+1]
				For nY := 1 to Len(aFisGet)
					nPosCpo := aScan(aHeader,{|x| AllTrim(x[2])==Alltrim(aFisGet[ny][2])})
					If nPosCpo > 0
						If !Empty(aCols[nX][nPosCpo])

							MaFisAlt(aFisGet[ny][1],aCols[nX][nPosCpo],nX,.F.)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Quando o ponto de Entrada M410SOLI retornar valores forcar o recalculo pois o MaFisAlt acima      ³
							//³recalculava os valores retornados pelo ponto anulando a sua acao.                                 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lM410Soli .And. !Empty(aTotSolid) 
								nPosSolid := Ascan(aTotSolid,{|x| x[1] == nX })
								If nPosSolid > 0
									If Len(aTotSolid[nPosSolid]) == 3
										MaFisLoad("IT_BASESOL", aTotSolid[nPosSolid,02] ,nX )
										MaFisLoad("IT_VALSOL" , aTotSolid[nPosSolid,03] ,nX )
									ElseIf Len(aTotSolid[nPosSolid]) == 8
										MaFisLoad("IT_BASESOL", aTotSolid[nPosSolid,02] , nX )
										MaFisLoad("IT_VALSOL" , aTotSolid[nPosSolid,03] , nX )
										MaFisLoad("IT_MARGEM" , aTotSolid[nPosSolid,04] , nX )
										MaFisLoad("IT_ALIQSOL", aTotSolid[nPosSolid,05] , nX )
										MaFisLoad("IT_BSFCPST", aTotSolid[nPosSolid,06] , nX )
										MaFisLoad("IT_ALFCST" , aTotSolid[nPosSolid,07] , nX )
										MaFisLoad("IT_VFECPST", aTotSolid[nPosSolid,08] , nX )
									EndIf
									MaFisEndLoad(nX,1)
								EndIf
							Endif
						Endif
					EndIf
				Next nY
			Endif
			If !(lM410Soli .And. !Empty(aTotSolid)) 
				MaFisAlt("IT_VALMERC",aValMerc[nX],nX)
			EndIF
		Next nX
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se foi modicado a aliquota para recalcular o valor de mercadoria ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nAliqISS <> MaAliqISS(nItem) .And. nVMercAux > 0
		nAliqISS  := MaAliqISS(nItem)
		nPrcLista := a410Arred(nPrcLsAux/(1-(nAliqISS/100)),"D2_PRCVEN")
		nValMerc  := a410Arred(nVMercAux/(1-(nAliqISS/100)),"D2_PRCVEN")
		MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
		MaFisAlt("IT_VALMERC",nValMerc,nItem)
		MafisRecal(,nItem)
	EndIf

	//Corrige desconto devido ISS do item ter ficado menor que limite mas total de ISS ficou maior.
	If nISSNDesc > 0
		nValISS := MaFisRet(,"NF_VALISS")
		If nValISS > nVRetISS
			nTotTit := MaFisRet(,"NF_BASEDUP")
			MaFisAlt("NF_BASEDUP",nTotTit-nISSNDesc)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza alteracoes de referencias do SF2 Suframa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPSuframa:=aScan(aFisGetSF2,{|x| x[1] == "NF_SUFRAMA"})
	If !Empty(nPSuframa)
		dbSelectArea("SF2")
		If !Empty(&("M->"+Alltrim(aFisGetSF2[nPSuframa][2])))
			MaFisAlt(aFisGetSF2[nPSuframa][1],Iif(&("M->"+Alltrim(aFisGetSF2[nPSuframa][2])) == "1",.T.,.F.),nItem,.F.)
		EndIf
	Endif

	// MV_FISFRAS: Indica se utiliza rastreabilidade para obtencao dos dados que necessitam desta funcionalidade. 
	// MV_FISAUCF: Utiliza a origem do documento original (para produtos com rastreabilidade) para efetuar os calculos.
	// Mesmo tratamento feito no MATA461 - Soh alterar se nao preencher o cod FCI na SD2.
	If lMvFisFras .And. lMvFISAUCF
		For nX := 1 To Len(aCols)
			If (Empty(Iif(nPFciCod > 0, aCols[nX][nPFciCod], "")) .And. (!Empty(aCols[nX][nPSubLot]) .Or. !Empty(aCols[nX][nPLote])))
				// Carrega origem da NF de entrada (FCI)
				If Rastro( aCols[nX][nPProduto] )
					SpedRastro2(aCols[nX][nPSubLot],aCols[nX][nPLote],aCols[nX][nPProduto],,0,.T.,,,,,,@cCodOrig )
				Endif

				If !Empty( cCodOrig )
					MaFisAlt("IT_CLASFIS",cCodOrig + Substr(aCols[nX][nPClasFis],2),nX,.F.)
				EndIf				
			EndIf
		Next nX
	EndIf

	If ExistBlock("M410PLNF")
		ExecBlock("M410PLNF",.F.,.F.)
	EndIf
	MaFisWrite(1)
	//
	// Template GEM - Gestao de Empreendimentos Imobiliarios
	//
	// Verifica se a condicao de pagamento tem vinculacao com uma condicao de venda
	//
	If ExistTemplate("GMCondPagto")
		lCondVenda := .F.
		lCondVenda := ExecTemplate("GMCondPagto",.F.,.F.,{M->F2_COND,} )
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula os venctos conforme a condicao de pagto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !M->F2_TIPO == "B"
		If lDtEmi
			dbSelectarea("SE4")
			dbSetOrder(1)
			MsSeek(xFilial("SE4")+M->F2_COND)
			If (Type("INCLUI") <> "U" .AND. Type("ALTERA") <> "U")
				lContinua := !(INCLUI.OR.ALTERA)
			EndIf

			If (SE4->E4_TIPO=="9".AND.(lContinua .OR. lRent)) .OR. SE4->E4_TIPO<>"9"

				nlValor := MaFisRet(,"NF_BASEDUP")				

				aDupl := Condicao(nlValor,M->F2_COND,MaFisRet(,"NF_VALIPI"),dDataCnd,Iif(SF4->F4_INCSOL<>"N",MaFisRet(,"NF_VALSOL"),0),,,nAcresTot)
				If Len(aDupl) > 0
					If ! lCondVenda
						For nX := 1 To Len(aDupl)
							nAcerto += aDupl[nX][2]
						Next nX
						aDupl[Len(aDupl)][2] += MaFisRet(,"NF_BASEDUP") - nAcerto
					EndIf

					aVencto := aClone(aDupl)
					For nX := 1 To Len(aDupl)
						aDupl[nX][2] := TransForm(aDupl[nX][2],PesqPict("SE1","E1_VALOR"))
					Next nX
				Endif
			Else
				aDupl := {{Ctod(""),TransForm(MaFisRet(,"NF_BASEDUP"),PesqPict("SE1","E1_VALOR"))}}
				aVencto := {{dDataBase,MaFisRet(,"NF_BASEDUP")}}
			EndIf
		Else
			nItem := 0	
			For nX := 1 to Len(aCols)
				If Len(aCols[nX])==nUsado .Or. !aCols[nX][nUsado+1]
					If nPDtEntr > 0
						nItem++
						nPosEntr := Ascan(aEntr,{|x| x[1] == aCols[nX][nPDtEntr]})
						If nPosEntr == 0
							aAdd(aEntr,{aCols[nX][nPDtEntr],MaFisRet(nItem,"IT_BASEDUP"),MaFisRet(nItem,"IT_VALIPI"),MaFisRet(nItem,"IT_VALSOL")})
						Else    
							aEntr[nPosEntr][2]+= MaFisRet(nItem,"IT_BASEDUP")
							aEntr[nPosEntr][3]+= MaFisRet(nItem,"IT_VALIPI")
							aEntr[nPosEntr][4]+= MaFisRet(nItem,"IT_VALSOL")
						EndIf
					Endif
				Endif
			Next
			dbSelectarea("SE4")
			dbSetOrder(1)
			MsSeek(xFilial("SE4")+M->F2_COND)
			If !(SE4->E4_TIPO=="9")
				For nY := 1 to Len(aEntr)
					nAcerto  := 0
					nlValor := aEntr[nY][2]

					aDuplTmp := Condicao(nlValor,M->F2_COND,aEntr[nY][3],aEntr[nY][1],aEntr[nY][4],,,nAcresTot)
					If Len(aDuplTmp) > 0
						If ! lCondVenda
							For nX := 1 To Len(aDuplTmp)
								nAcerto += aDuplTmp[nX][2]
							Next nX
							aDuplTmp[Len(aDuplTmp)][2] += aEntr[nY][2] - nAcerto
						EndIf

						aVencto := aClone(aDuplTmp)
						For nX := 1 To Len(aDuplTmp)
							aDuplTmp[nX][2] := TransForm(aDuplTmp[nX][2],PesqPict("SE1","E1_VALOR"))
						Next nX
						aEval(aDuplTmp,{|x| aAdd(aDupl,{aEntr[nY][1],x[1],x[2]})})
					EndIf
				Next
			Else
				aDupl := {{Ctod(""),TransForm(MaFisRet(,"NF_BASEDUP"),PesqPict("SE1","E1_VALOR"))}}
				aVencto := {{dDataBase,MaFisRet(,"NF_BASEDUP")}}
			EndIf
		EndIf
	Else
		aDupl := {{Ctod(""),TransForm(0,PesqPict("SE1","E1_VALOR"))}}
		aVencto := {{dDataBase,0}}
	EndIf
	//
	// Template GEM - Gestao de empreendimentos Imobiliarios
	// Gera os vencimentos e valores das parcelas conforme a condicao de venda
	//
	If lCondVenda 
		If ExistBlock("GMMA410Dupl")
			aVencto := ExecBlock("GMMA410Dupl",.F.,.F.,{M->F2_DOC ,M->F2_COND,dDataCnd,,MaFisRet(,"NF_BASEDUP") ,aVencto}, .F., .F.) 
		ElseIf ExistTemplate("GMMA410Dupl")
			aVencto := ExecTemplate("GMMA410Dupl",.F.,.F.,{M->F2_DOC ,M->F2_COND,dDataCnd,,MaFisRet(,"NF_BASEDUP") ,aVencto}) 
		Endif	
		aDupl := {}
		aEval(aVencto ,{|aTitulo| aAdd( aDupl ,{transform(aTitulo[1],x3Picture("E1_VENCTO")) ,transform(aTitulo[2],x3Picture("E1_VALOR"))}) })
	EndIf
	If lM410Vct
		aDupl := ExecBlock("M410VCT",.F.,.F.,{aDupl,MaFisRet(,"NF_BASEDUP")})
	EndIf
	If Len(aDupl) == 0
		aDupl := {{Ctod(""),TransForm(MaFisRet(,"NF_BASEDUP"),PesqPict("SE1","E1_VALOR"))}}
		aVencto := {{dDataBase,MaFisRet(,"NF_BASEDUP")}}
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Analise da Rentabilidade - Valor Presente    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRentabil := a410RentPV( aCols ,nUsado ,@aRenTab ,@aVencto ,nPTES,nPProduto,nPLocal,nPQtdVen, M->F2_EMISSAO,nMoeda )

	If cPaisLoc=="BRA" 
		aAdd(aTitles, STR0008) //"Calculation Entries"
		nLancAp	:=	Len(aTitles)
	EndIf

	//lRetTotal quando .T. não exibe a planilha mas retorna o NF_TOTAL de MafisRet
	If !lRetTotal

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a tela de exibicao dos valores fiscais ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0009) FROM 09,00 TO 28,80 //"Financial Worksheet"
		oFolder := TFolder():New(001,001,aTitles,{"HEADER"},oDlg,2,,, .T., .F.,315,140)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Folder 1                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisRodape(1,oFolder:aDialogs[1],,{005,001,310,60},Nil,.T.)
		If cPaisLoc <> "PTG"
			@ 070,005 SAY RetTitle("F2_FRETE")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
			@ 070,105 SAY RetTitle("F2_SEGURO")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
			@ 070,205 SAY RetTitle("F2_DESCONT")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
			@ 085,005 SAY RetTitle("F2_FRETAUT")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
			@ 085,105 SAY RetTitle("F2_DESPESA")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
			@ 085,205 SAY RetTitle("F2_VALFAT")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
			@ 070,050 MSGET MaFisRet(,"NF_FRETE")		PICTURE PesqPict("SF2","F2_FRETE",16,2)		SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
			@ 070,150 MSGET MaFisRet(,"NF_SEGURO")  	PICTURE PesqPict("SF2","F2_SEGURO",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
			@ 070,250 MSGET MaFisRet(,"NF_DESCONTO")	PICTURE PesqPict("SF2","F2_DESCONT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
			@ 085,050 MSGET MaFisRet(,"NF_AUTONOMO")	PICTURE PesqPict("SF2","F2_FRETAUT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
			@ 085,150 MSGET MaFisRet(,"NF_DESPESA")		PICTURE PesqPict("SF2","F2_DESPESA",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
			@ 085,250 MSGET MaFisRet(,"NF_BASEDUP")		PICTURE PesqPict("SF2","F2_VALFAT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
			@ 105,005 TO 106,310 PIXEL OF oFolder:aDialogs[1]
			@ 110,005 SAY OemToAnsi(STR0010)   SIZE 40,10 PIXEL OF oFolder:aDialogs[1] //"Invoice´s Total"
			@ 110,050 MSGET MaFisRet(,"NF_TOTAL")      PICTURE Iif(cPaisLoc $ "CHI|PAR" .And. M->F2_MOEDA == 1,TM(0,16,NIL),PesqPict("SF2","F2_VALBRUT",16,2))                   	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
			If nOpc == 4
				@ 109,270 BUTTON OemToAnsi(STR0011) SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION (MATA476FL(oDupl,@aDupl,aColsOri,oDlg)) OF oFolder:aDialogs[1] PIXEL //"Confirm"
			Else
				@ 109,270 BUTTON OemToAnsi(STR0012) SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[1] PIXEL //"Quit"
			EndIf
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Folder 2                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                                                      
		aadd(aFields,{"E1_VENCTO" ,"C",TamSx3("E1_VENCTO")[1]  ,TamSx3("E1_VENCTO")[2]} )
		aadd(aFields,{"E1_VALOR"  ,"C",TamSx3("E1_VALOR")[1]   ,TamSx3("E1_VALOR")[2]}  )

		DbSelectArea("SX3")
		SX3->(dbSetOrder(2))

		For nCount := 1 to Len(aFields) 
			If SX3->(dbSeek(aFields[nCount,1])) 
				Aadd(aHFin,{	AllTrim(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT,;
				SX3->X3_CBOX,;
				,;
				SX3->X3_WHEN,;
				SX3->X3_VISUAL,;
				,;
				SX3->X3_PICTVAR,;
				SX3->X3_OBRIGAT})
			Endif

		Next nCount

		For nCount := 1 to Len(aDupl)
			Aadd(aColsFin,Array(Len(aHFin)+1))

			aColsFin[Len(aColsFin)][1]	:=  aDupl[nCount,1]
			aColsFin[Len(aColsFin)][2]	:=  Val(StrTran(StrTran(aDupl[nCount,2],'.',''),',',''))/100
			aColsFin[Len(aColsFin)][Len(aHFin)+1] := .F.

		Next nCount

		aColsOri := aClone(aColsFin)

		oDupl := MsNewGetDados():New(0,0,95,310,IIF(nOpc == 4,GD_DELETE+GD_INSERT+GD_UPDATE,),,,,,,9999,/*cFieldOk*/,,,oFolder:aDialogs[2],@aHFin,@aColsFin)

		@ 105,005 TO 106,310 PIXEL OF oFolder:aDialogs[2]
		@ 110,005 SAY OemToAnsi(STR0013) SIZE 40,10 PIXEL OF oFolder:aDialogs[2] //"Trade Notes Value"

		@ 110,050 MSGET MaFisRet(,"NF_BASEDUP")		PICTURE PesqPict("SF2","F2_VALFAT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[2]

		// Template GEM - Gestao de empreendimentos imobiliarios
		// Manutencao dos itens da condicao de venda 
		If nOpc == 4
			@ 109,270 BUTTON OemToAnsi(STR0011) SIZE 040,11 FONT oFolder:aDialogs[3]:oFont ACTION (MATA476FL(oDupl,@aDupl,aColsOri,oDlg)) OF oFolder:aDialogs[2] PIXEL //"Confirm"
		Else
			@ 109,270 BUTTON OemToAnsi(STR0012) SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[2] PIXEL	//"Quit"
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Folder 3                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 005,001 LISTBOX oRentab FIELDS TITLE aRFHead[1],aRFHead[2],aRFHead[3],aRFHead[4],aRFHead[5],aRFHead[6] SIZE 310,095 	OF oFolder:aDialogs[3] PIXEL
		If nOpc == 4
			@ 109,270 BUTTON OemToAnsi(STR0011) SIZE 040,11 FONT oFolder:aDialogs[3]:oFont ACTION (MATA476FL(oDupl,@aDupl,aColsOri,oDlg)) OF oFolder:aDialogs[3] PIXEL //"Confirm"
		Else
			@ 109,270 BUTTON OemToAnsi(STR0012) SIZE 040,11 FONT oFolder:aDialogs[3]:oFont ACTION oDlg:End() OF oFolder:aDialogs[3] PIXEL //"Quit"
		EndIf
		If Empty(aRentabil)
			aRentabil   := {{"",0,0,0,0,0}}
		EndIf
		oRentab:SetArray(aRentabil)
		oRentab:bLine := {|| aRentabil[oRentab:nAt] }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para inibir o Folder Rentabilidade ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("M410FLDR") 
			lM410FldR := ExecBlock("M410FLDR",.F.,.F.)
			If ValType(lM410FldR) == "L" 
				oFolder:aDialogs[3]:lActive:= lM410FldR  
			EndIf
		EndIf

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT CursorArrow()
	Else
		nValTotal := MaFisRet(,"NF_TOTAL")
	EndIf

	MaFisEnd()
	MaFisRestore()

	RestArea(aAreaSA1)
	RestArea(aArea)

	aRefRentab := aRentabil

	If SuperGetMv("MV_RSATIVO",.F.,.F.)
		lPlanRaAtv := .T.
	EndIf

	If FunName() == 'MATA462N' //.Or. FunName() == 'MATA462AN'
		MaFisAlt('IT_TES',cTesAnt,OGETDADOS:OBROWSE:NAT)
		M->D2_TES 	:= cTesAnt
		RunTrigger(2,OGETDADOS:OBROWSE:NAT,nil,,'D2_TES')
	EndIf

Return(aDupl)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A410LAICMS³ Autor ³ Gustavo G. Rueda      ³ Data ³05/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para montagem do GETDADOS do folder de lancamentos   ³±±
±±³          ³ fiscais.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³oLancApICMS -> Objeto criado pelo MSNEWGETDADOS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oDlg -> Objeto pai onde o GETDADOS serah criado.            ³±±
±±³          ³aPos -> posicoes de criacao do objeto.                      ³±±
±±³          ³aHeadCDA -> array com o HEADER da tabela CDA                ³±±
±±³          ³aColsCDA -> array com o ACOLS da tabela CDA                 ³±±
±±³          ³lVisual -> Flag de visualizacao                             ³±±
±±³          ³lInclui -> Flag de inclusao                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A410LAICMS(oDlg,aPos,aHeadCDA,aColsCDA,lVisual,lInclui)

	Local	oLancApICMS
	Local	aCmps		:=	{}
	Local	nI			:=	0
	Local	aLAp		:=	A410LancAp()
	Local	cMaskBs		:=	""
	Local	cMaskAlq	:=	""
	Local	cMaskVlr	:=	""
	Local	nPNUMITE	:=	0
	Local	nPSEQ		:=	0
	Local	nPCODLAN	:=	0
	Local	nPCALPRO	:=	0
	Local	nPBASE		:=	0
	Local	nPALIQ		:=	0
	Local	nPVALOR		:=	0
	Local	nPIFCOMP	:=	0

	aMHead("CDA","CDA_TPMOVI/CDA_ESPECI/CDA_FORMUL/CDA_NUMERO/CDA_SERIE/CDA_CLIFOR/CDA_LOJA/",@aHeadCDA)
	For nI := 1 To Len(aHeadCDA)
		aAdd(aCmps,aHeadCDA[nI,1])

		If "CDA_BASE"==AllTrim(aHeadCDA[nI,2])
			cMaskBs		:=	AllTrim(aHeadCDA[nI,3])

		ElseIf "CDA_ALIQ"==AllTrim(aHeadCDA[nI,2])
			cMaskAlq	:=	AllTrim(aHeadCDA[nI,3])

		ElseIf "CDA_VALOR"==AllTrim(aHeadCDA[nI,2])
			cMaskVlr	:=	AllTrim(aHeadCDA[nI,3])
		EndIf

		If nPNUMITE==0
			nPNUMITE	:=	Iif("CDA_NUMITE"$aHeadCDA[nI,2],nI,0)
		EndIf
		If nPSEQ==0
			nPSEQ		:=	Iif("CDA_SEQ"$aHeadCDA[nI,2],nI,0)
		EndIf
		If nPCODLAN==0
			nPCODLAN	:=	Iif("CDA_CODLAN"$aHeadCDA[nI,2],nI,0)
		EndIf
		If nPCALPRO==0
			nPCALPRO	:=	Iif("CDA_CALPRO"$aHeadCDA[nI,2],nI,0)
		EndIf
		If nPBASE==0
			nPBASE		:=	Iif("CDA_BASE"$aHeadCDA[nI,2],nI,0)
		EndIf
		If nPALIQ==0
			nPALIQ		:=	Iif("CDA_ALIQ"$aHeadCDA[nI,2],nI,0)
		EndIf
		If nPVALOR==0
			nPVALOR		:=	Iif("CDA_VALOR"$aHeadCDA[nI,2],nI,0)
		EndIf
		If nPIFCOMP==0
			nPIFCOMP	:=	Iif("CDA_IFCOMP"$aHeadCDA[nI,2],nI,0)
		EndIf	
	Next nI

	If Len(aLAp)==0
		If nPIFCOMP==0
			aLAp	:=	{{"","","",0,0,0,""}}
		Else
			aLAp	:=	{{"","","",0,0,0,"",""}}
		EndIf
	EndIf

	If nPIFCOMP==0
		aLine	:=	{,,,,,,}
	Else
		aLine	:=	{,,,,,,,}
	EndIf
	aLine[nPNUMITE]	:=	"aLAp[oLancApICMS:nAT,1]"
	aLine[nPSEQ]	:=	"aLAp[oLancApICMS:nAT,7]"
	aLine[nPCODLAN]	:=	"aLAp[oLancApICMS:nAT,2]"
	aLine[nPCALPRO]	:=	'Iif(aLAp[oLancApICMS:nAT,3]=="1","Sim","Não")'
	aLine[nPBASE]	:=	"Transform(aLAp[oLancApICMS:nAT,4],cMaskBs)"
	aLine[nPALIQ]	:=	"Transform(aLAp[oLancApICMS:nAT,5],cMaskAlq)"
	aLine[nPVALOR]	:=	"Transform(aLAp[oLancApICMS:nAT,6],cMaskVlr)"
	If nPIFCOMP>0
		aLine[nPIFCOMP]	:=	"aLAp[oLancApICMS:nAT,8]"
	EndIf

	oLancApICMS	:=	TWBrowse():New( aPos[1],aPos[2],aPos[3],aPos[4],,aCmps,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
	oLancApICMS:SetArray(aLAp)
	If nPIFCOMP>0
		oLancApICMS:bLine := &("{|| {"+aLine[nPNUMITE]+","+aLine[nPSEQ]+","+aLine[nPCODLAN]+","+aLine[nPCALPRO]+","+aLine[nPBASE]+","+aLine[nPALIQ]+","+aLine[nPVALOR]+","+aLine[nPIFCOMP]+"} }")
	Else
		oLancApICMS:bLine := &("{|| {"+aLine[nPNUMITE]+","+aLine[nPSEQ]+","+aLine[nPCODLAN]+","+aLine[nPCALPRO]+","+aLine[nPBASE]+","+aLine[nPALIQ]+","+aLine[nPVALOR]+"} }")
	EndIf             

Return oLancApICMS   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A410LancAp³ Autor ³ Gustavo G. Rueda      ³ Data ³05/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para montar os lancamento fiscais para exibicao     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aLancAp -> Lancamentos montados em cima da MATXFIS          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A410LancAp()

	Local aRetMaFisAjIt := MaFisAjIt(,2)
	Local aLancAp := {}
	Local nJ := 0

	If !Empty(aRetMaFisAjIt)
		For nJ := 1 To Len(aRetMaFisAjIt)
			If Len(aRetMaFisAjIt[nJ]) >= 14 .And. aRetMaFisAjIt[nJ,14] == "4"
				Loop
			EndIf
			aAdd(aLancAp, aRetMaFisAjIt[nJ])				
		Next nJ
	EndIf

Return aLancAp     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a410ISSMunºAutor  ³ Vitor Felipe       º Data ³ 29/06/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle dos Abatimentos para o calculo do ISS (Processa). º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A410ISSMUN()
	Local nTamSX1   := Len(SX1->X1_GRUPO)
	Local cPerg		:= PadR("ISSXMUN",nTamSX1)
	Local cPerg2	:= PadR("MTA410",nTamSX1)
	Local lEnd		:=	.F.

	CrIISSX1(cPerg)
	If Pergunte(cPerg,.T.)
		Processa({|lEnd| a410INCISS(@lEnd)},,,.T.)		
		GETDREFRESH()
		SetFocus(oGetDad:oBrowse:hWnd) 
	Else
		Pergunte(cPerg2,.F.)
	EndIf

Return  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³a410FreteP³ Autor ³ Kleber Dias Gomes     ³ Data ³25/07/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Funcao de Calculo da Frete Pauta.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta funcao efetua o calculo do frete pauta.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a410FreteP()
	Local aArea    := GetArea()
	Local cAliasDV9:= "DV9"
	Local lRetorno := .T.
	Local lQuery   := .F.
	Local nScan    := 0
	#IFDEF TOP
	Local aStruDV9 := {}
	Local cQuery   := ""
	Local nY       := 0
	#ENDIF

	If ValType(aFreteP) == "A"
		M->F2_VLR_FRT := 0 //-- Var.mem. valor base icms pauta de frete
		If M->F2_KM > 0
			If Empty(aFreteP)
				dbSelectArea("DV9")
				DV9->(dbSetOrder(1)) //DV9_FILIAL+DV9_TARIFA
				#IFDEF TOP
				lQuery  := .T.
				aStruDV9:= DV9->(dbStruct())
				cAliasDV9:= GetNextAlias()
				cQuery := "SELECT DV9.*,DV9.R_E_C_N_O_ DV9RECNO "
				cQuery += "FROM "+RetSqlName("DV9")+" DV9 "
				cQuery += "WHERE DV9.DV9_FILIAL='"+xFilial("DV9")+"' AND "
				cQuery += "DV9.D_E_L_E_T_=' ' "
				cQuery += "ORDER BY "+SqlOrder(DV9->(IndexKey()))
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDV9,.T.,.T.)
				For nY := 1 To Len(aStruDV9)
					If aStruDV9[nY][2] <> "C"
						TcSetField(cAliasDV9,aStruDV9[nY][1],aStruDV9[nY][2],aStruDV9[nY][3],aStruDV9[nY][4])
					EndIf
				Next nY
				#ELSE
				DV9->(dbGoTop())
				#ENDIF
				While !Eof() .And. (cAliasDV9)->DV9_FILIAL == xFilial("DV9")
					aAdd(aFreteP,{	(cAliasDV9)->DV9_KM		, ;
					If(lQuery,(cAliasDV9)->DV9RECNO,(cAliasDV9)->(Recno())), ;
					(cAliasDV9)->DV9_VALOR	, ;
					(cAliasDV9)->DV9_TIPVAL	, ;
					(cAliasDV9)->DV9_ICBASE , ;
					(cAliasDV9)->DV9_PERCEN , ;
					(cAliasDV9)->DV9_CARGAE })
					(cAliasDV9)->(dbSkip())
				EndDo
				aSort(aFreteP,,,{|x,y| x[1] < y[1] })
				If lQuery
					dbSelectArea(cAliasDV9)
					dbCloseArea()
					dbSelectArea("DV9")
				EndIf
			EndIf
			nScan := Ascan(aFreteP,{|x| x[1] >= M->F2_KM .And. x[5] == "2"})
			If nScan > 0
				Do Case
					Case aFreteP[nScan][4] == "1"
					M->F2_VLR_FRT := NoRound((M->F2_PBRUTO/1000)*	aFreteP[nScan][3] ,TamSX3("F2_VLR_FRT")[2])
					Case aFreteP[nScan][4] == "2"
					M->F2_VLR_FRT := NoRound((M->F2_PBRUTO      *	aFreteP[nScan][3]),TamSX3("F2_VLR_FRT")[2])
					Case aFreteP[nScan][4] == "3"
					M->F2_VLR_FRT := NoRound(					  	aFreteP[nScan][3] ,TamSX3("F2_VLR_FRT")[2])
				EndCase
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRetorno  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³a410FrPIte³ Autor ³ Vendas e eCRM         ³ Data ³10/01/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Funcao de Calculo da Frete Pauta no item de acordo com TES.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Campo posicionado                                     ³±±
±±³          ³ExpC2: Valor informado no campo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta funcao efetua o calculo do frete pauta.                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAFAT                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a410FrPIte(cCampo,cConteudo)

	Local aArea    := GetArea()
	Local nY       := 0
	Local nValBase := 0    
	Local nPosPro  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_PRODUTO"})
	Local nPosTES  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_TES"})
	Local cCargaE  := "2"
	Local cProduto := ""
	Local cTES	   := ""

	Default cCampo := ReadVar()
	Default cConteudo := &(cCampo)

	If M->F2_KM > 0 .And. !Empty(aFreteP)
		cProduto := IIf ("D2_PRODUTO" $ cCampo ,cConteudo,aCols[n][nPosPro])
		cTES	 := IIf ("D2_TES" $ cCampo,cConteudo,aCols[n][nPosTES])
		cCargaE := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CARGAE")

		nValBase := M->F2_VLR_FRT 

		If !Empty(cTES)
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4")+cTES)             			

			For nY := 1 To Len(aFreteP)
				If aFreteP[nY][1] >= M->F2_KM
					Do Case
						Case (SF4->F4_CRDPRES > 0 .And. aFreteP[nY][5] == "1" .And. aFreteP[nY][7] <> "1" .And. cCargaE <> "1")
						nValBase := aFreteP[nY][3]
						Case (SF4->F4_CRDPRES > 0 .And. aFreteP[nY][5] == "1" .And. aFreteP[nY][7] == "1" .And. cCargaE == "1")
						nValBase := aFreteP[nY][3]
						Case (SF4->F4_BASEICM > 0 .And. aFreteP[nY][5] == "1" .And. aFreteP[nY][6] == SF4->F4_BASEICM )
						nValBase := aFreteP[nY][3]
						Case (aFreteP[nY][5] <> "1" .And. SF4->F4_CRDPRES==0 .And. SF4->F4_BASEICM==0)
						nValBase := aFreteP[nY][3]			   		
					EndCase
				Endif	

				If nValBase <> M->F2_VLR_FRT
					Do Case
						Case aFreteP[nY][4] == "1"
						M->F2_VLR_FRT := NoRound((M->F2_PBRUTO/1000)*nValBase,TamSX3("F2_VLR_FRT")[2])
						Exit
						Case aFreteP[nY][4] == "2"
						M->F2_VLR_FRT := NoRound((M->F2_PBRUTO*nValBase),TamSX3("F2_VLR_FRT")[2])
						Exit
						Case aFreteP[nY][4] == "3"
						M->F2_VLR_FRT := NoRound(nValBase,TamSX3("F2_VLR_FRT")[2])
						Exit
					EndCase       
				EndIf 				
			Next nY		
		Endif    

		If oGetPV <> Nil
			oGetPV:Refresh()
		Endif	
	EndIf  

	RestArea(aArea)

Return    

//--------------------------------------------------------------
/*/{Protheus.doc} A410SMLFRT
Simulação basica de Calculo de frete

@return xRet Return Description
@author  -                                               
@since 22/02/2012                                                   
/*/
//--------------------------------------------------------------
Static Function A410SMLFRT()
	Local aArea 		:= GetArea()
	Local oModelSim  	:= FWLoadModel("GFEX010")
	Local oModelNeg  	:= oModelSim:GetModel("GFEX010_01")
	Local oModelAgr  	:= oModelSim:GetModel("DETAIL_01")  // oModel do grid "Agrupadores"
	Local oModelDC   	:= oModelSim:GetModel("DETAIL_02")  // oModel do grid "Doc Carga"
	Local oModelIt   	:= oModelSim:GetModel("DETAIL_03")  // oModel do grid "Item Carga"
	Local oModelTr   	:= oModelSim:GetModel("DETAIL_04")  // oModel do grid "Trechos"
	Local oModelInt  	:= oModelSim:GetModel("SIMULA")     // oModel do field que dispara a simulação
	Local oModelCal1 	:= oModelSim:GetModel("DETAIL_05")  // oModel do calculo do frete
	Local oModelCal2 	:= oModelSim:GetModel("DETAIL_06")  // oModel das informações complemetares do calculo
	Local nCont      	:= 0
	Local nRegua 		:= 0                   
	Local cCdClFr		:= "" //-- simulacao de frete: considerar todas a negociacoes cadastradas no GFE.
	Local cTpOp			:= "" //-- simulacao de frete: considerar todas a negociacoes cadastradas no GFE.
	Local cTpDoc		:= ''
	Local nLenAcols		:= 0
	Local nItem			:= 0
	Local nPProduto		:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_PRODUTO"})
	Local nPQtdVen		:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_QUANT"})
	Local nPValor		:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_VALOR"})
	Local nX			:= 0
	Local cCGCTran		:= ''                                        
	Local nVlrFrt		:= 0
	Local nPrevEnt		:= 0
	Local aRet			:= {}
	Local nNumCalc		:= 0
	Local nClassFret	:= 0
	Local nTipOper		:= 0
	Local cTrecho		:= ""
	Local cTabela		:= ""
	Local cNumNegoc		:= ""
	Local cRota			:= ""
	Local dDatValid		:= ""
	Local cFaixa		:= ""
	Local cTipoVei		:= ""
	Local cCgc := ''
	Local nAltura		:= 0
	Local nVolume		:= 0
	Local nRadio		:= 0
	Local oRadio		:= Nil	
	Local oDlg1			:= Nil	

	If !Empty(M->F2_CLIENTE) .And. !Empty(M->F2_LOJA) .And. !Empty(aCols[n,nPProduto]) .And. !Empty(aCols[n,nPQtdVen]) .And. !Empty(aCols[n,nPValor])	

		DEFINE MSDIALOG oDlg1 FROM	31,15 TO 180,350 TITLE STR0014 PIXEL OF oMainWnd //"Simulation of Freight"
		@ 005,005 SAY STR0015 PIXEL SIZE 160,160 Of oDlg1 //"Select the simulation rule to consider:"
		@ 25,005 RADIO oRadio VAR nRadio ITEMS STR0016,STR0017 SIZE 150,150 PIXEL OF oDlg1 //"1- Considers Freight Negotiation Table" - "2 - Consider only Approved Freight Table"
		DEFINE SBUTTON FROM 047,120 TYPE 1 ENABLE OF oDlg1 ACTION (oDlg1:End() )
		nRadio := 2
		ACTIVATE MSDIALOG oDlg1 CENTERED
		ProcRegua(nRegua)      

		SA1->(dbSeek(xFilial("SA1")+M->F2_CLIENTE+M->F2_LOJA))	   

		cTpDoc := AllTrim(Posicione("SX5",1,xFilial("SX5")+"MQ"+M->F2_TIPO,"X5_DESCRI"))	

		oModelSim:SetOperation(3) //Seta como inclusão
		oModelSim:Activate() 			
		oModelNeg:LoadValue('CONSNEG' ,AllTrim(Str(nRadio))) // -- 1=Considera Tab.Frete em Negociacao; 2=Considera apenas Tab.Frete Aprovadas
		IncProc()
		//Agrupadores - Não obrigatorio
		oModelAgr:LoadValue('GWN_CDCLFR',cCdClFr)  //classificação de frete                                 
		oModelAgr:LoadValue('GWN_CDTPOP',cTpOp)    //tipo da operação
		oModelAgr:LoadValue('GWN_DOC'   ,"ROMANEIO"     )           
		//Documento de Carga
		oModelDC:LoadValue('GW1_EMISDC', SM0->M0_CGC) 	//codigo do emitente - chave
		oModelDC:LoadValue('GW1_NRDC'  , M->F2_DOC  ) 	//numero da nota - chave
		oModelDC:LoadValue('GW1_CDTPDC', cTpDoc) 		// tipo do documento - chave
		oModelDC:LoadValue('GW1_CDREM' , IIF(MTA410ChkEmit(SM0->M0_CGC),SM0->M0_CGC, MTA410RetEmit(xFilial("SF2")) ) )  	//remetente
		oModelDC:LoadValue('GW1_CDDEST', IIF(MTA410ChkEmit(SA1->A1_CGC),SA1->A1_CGC, OMSM011COD(M->F2_CLIENTE,M->F2_LOJA,1,,) ) )   //destinatario

		oModelDC:LoadValue('GW1_TPFRET', "1")
		oModelDC:LoadValue('GW1_ICMSDC', "2")
		oModelDC:LoadValue('GW1_USO'   , "1")
		oModelDC:LoadValue('GW1_QTUNI' , 1)   
		//Trechos
		oModelTr:LoadValue('GWU_EMISDC' ,SM0->M0_CGC)												//codigo do emitente - chave
		oModelTr:LoadValue('GWU_NRDC'   ,M->F2_DOC  ) 												//numero da nota - chave
		oModelTr:LoadValue('GWU_CDTPDC' ,cTpDoc)													// tipo do documento - chave
		oModelTr:LoadValue('GWU_SEQ'    ,"01"   )    												//sequencia - chave
		oModelTr:LoadValue('GWU_NRCIDD' ,AllTrim(TMS120CdUf(SA1->A1_EST, "1") + SA1->A1_COD_MUN))   // codigo da cidade para o calculo

		nLenAcols := Len(aCols)
		//Itens								
		For nX:= 1 To nLenACols			
			If !GdDeleted(nX)
				nItem += 1
				nAltura := Posicione("SB5",1,xFilial("SB5")+aCols[nX,nPProduto],"B5_ALTURA")
				nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR) * aCols[nX,nPQtdVen]			
				SB1->(DbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+aCols[nX,nPProduto ]))
				//--VERIFICAR QUESTÃO DOS PRODUTOS
				oModelIt:LoadValue('GW8_EMISDC',SM0->M0_CGC)	//codigo do emitente - chave
				oModelIt:LoadValue('GW8_NRDC'  ,M->F2_DOC  ) 	//numero da nota - chave
				oModelIt:LoadValue('GW8_CDTPDC',cTpDoc) 		// tipo do documento - chave
				oModelIt:LoadValue('GW8_ITEM'  , "ITEM"+ PADL((nItem),3,"0")  )        		//codigo do item    -
				oModelIt:LoadValue('GW8_DSITEM', "ITEM GENERICO  "	+ PADL((nItem),3,"0"))  	//descrição do item -
				oModelIt:LoadValue('GW8_CDCLFR',cCdClFr)    										//classificação de frete
				oModelIt:LoadValue('GW8_VOLUME',nVolume) 											//Volume
				oModelIt:LoadValue('GW8_PESOR' ,aCols[nX,nPQtdVen] * SB1->B1_PESBRU ) 		//peso real
				oModelIt:LoadValue('GW8_VALOR' ,aCols[nX,nPValor ] )     						//valor do item
				oModelIt:LoadValue('GW8_QTDE'  ,aCols[nX,nPQtdVen ] )     						//valor do item
				oModelIt:LoadValue('GW8_TRIBP' ,"1" )
				oModelIt:AddLine(.T.)
			EndIf	
		Next nX   

		// Dispara a simulação
		oModelInt:SetValue("INTEGRA" ,"A") 	 
		IncProc()

		//Verifica se há linhas no model do calculo, se não há linhas significa que a simulação falhou
		If oModelCal1:GetQtdLine() > 1 .Or. !Empty( oModelCal1:GetValue('C1_NRCALC'  ,1) )
			//Percorre o grid, cada linha corresponde a um calculo diferente
			For nCont := 1 to oModelCal1:GetQtdLine()
				oModelCal1:GoLine( nCont )                                 			

				nVlrFrt	 		:= oModelCal1:GetValue('C1_VALFRT'  ,nCont )       
				nPrevEnt  		:= oModelCal1:GetValue('C1_DTPREN'  ,nCont ) - ddatabase

				nNumCalc		:= oModelCal2:GetValue	("C2_NRCALC" ,1 )  //"Número Cálculo"
				nClassFret		:= oModelCal2:GetValue	("C2_CDCLFR" ,1 )  //"Class Frete"
				nTipOper		:= oModelCal2:GetValue	("C2_CDTPOP" ,1 )  //"Tipo Operação"
				cTrecho			:= oModelCal2:GetValue	("C2_SEQ" ,1 )     //"Trecho"
				cCGCTran		:= oModelCal2:GetValue	("C2_CDEMIT" ,1 )  //"Emit Tabela"
				cTabela			:= oModelCal2:GetValue	("C2_NRTAB" ,1 )   //"Nr tabela "
				cNumNegoc		:= oModelCal2:GetValue	("C2_NRNEG" ,1 )   //"Nr Negoc"
				cRota			:= oModelCal2:GetValue	("C2_NRROTA" ,1 )  //"Rota"
				dDatValid		:= oModelCal2:GetValue	("C2_DTVAL" ,1 )   //"Data Validade"
				cFaixa			:= oModelCal2:GetValue	("C2_CDFXTV" ,1 )  //"Faixa"
				cTipoVei		:= oModelCal2:GetValue	("C2_CDTPVC" ,1 )  //"Tipo Veículo"

				SA4->(dbSetOrder(3))
				If SA4->(dbSeek(xFilial("SA4")+cCGCTran))
					aAdd (aRet, {,SA4->A4_COD,SA4->A4_NOME,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.T.})			   
				Else
					cCGC := MTA410RetCGC(cCGCTran)
					If SA4->(dbSeek(xFilial("SA4")+cCGC))
						AADD (aRet, {,SA4->A4_COD,SA4->A4_NOME,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.T.})
					Else
						AADD (aRet, {,cCGCTran,STR0018,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.F.}) //--"Transportadora não cadastrada no Microsiga Protheus!!!"
					EndIf
				EndIf	
			Next nCont    

			// SIGAGFE - Ponto de Entrada para não mostrar a Tela do Resultado da Simulação de Frete
			If ExistBlock('MA410FRT')
				ExecBlock('MA410FRT',.F.,.F.,{aRet})
			Else
				a410RetSml(aRet)
			EndIf

		EndIf
	ElseIf (M->F2_TIPO $ "CIP")
		Aviso(STR0019,STR0020,{STR0021}) //"Attention" - "Simulation of freight is not executed for Price Complement, ICMS and IPI orders, therefore there is no integration with SIGAGFE module." - "OK"
	Else
		Help(" ",1,"A410SMLFRT")	//"Para a simulação de frete é necessário preencher os campos: Cli.Entrega, Loja Entrega, Produto, Quantidade e Valor."	  		
	EndIf

	RestArea(aArea)

Return ( Nil ) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a410RetSml  ºAutor  ³Leandro Paulino     º Data ³  04/11/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela Resultado da Simulação do Frete                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integração  OMS X TOTVSGFE		                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function a410RetSml(aListBox)

	Local aSize     := {}
	Local aObjects  := {}
	Local aInfo     := {}
	Local aPosObj   := {}  
	Local oOk       := LoadBitMap(GetResources(),"LBOK")
	Local oNo       := LoadBitMap(GetResources(),"LBNO")
	Local oBtn01
	Local oBtn02
	Local cCodTrans := ""
	Local nItemMrk	:= 0
	Local nOpca		:= 0

	Default aListBox:= {}

	Private oListBox:= Nil
	Private oDlg	 := Nil

	//-- Rotinas Marcadas
	Private aRotMark:= {}                                                         

	aSize    	:= MsAdvSize(.F. )
	aObjects 	:= {}

	aAdd( aObjects, { 100, 000, .T., .F., .T.  } )
	aAdd( aObjects, { 100, 100, .T., .T. } )
	aAdd( aObjects, { 100, 005, .T., .T. } )

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ]*0.60, aSize[ 4 ]*0.68, 3, 3, .T.  }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlg TITLE STR0014 From aSize[7],0 to aSize[6]*0.68,aSize[5]*0.61 OF oMainWnd PIXEL //"Simulation of Freight"

	oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)

	//-- Cabecalho dos campos do Monitor.
	@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER "", STR0022, STR0023, STR0024, STR0025, STR0026, STR0027, STR0028, STR0029, STR0030, STR0031, STR0032, STR0033, STR0034, STR0035 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL //"Transp. Cod." - "Carrier Name" - "Freight value" - "Delivery Deadline (days)" - "Calculation Number" - "Freight Classification" - "Operation Type" - "Distance" - "Table" - "Negotiation" - "Route" - "Expiration Date" - "Range" - "Vehicle"

	oListBox:SetArray( aListBox )
	oListBox:bLDblClick := { || a410MrkSml(aListBox,@nItemMrk,@cCodTrans) }                              
	oListBox:bLine      := { || {	Iif(aListBox[ oListBox:nAT,SMMARCA 	] == '1',oOk,oNo),;	
	aListBox[ oListBox:nAT,SMCODTRAN	],;				
	aListBox[ oListBox:nAT,SMNOMETRAN	],;
	aListBox[ oListBox:nAT,SMVALOR	   	],;
	aListBox[ oListBox:nAT,SMPRAZO	   	],; 
	aListBox[ oListBox:nAT,SMNUMCALC	],;
	aListBox[ oListBox:nAT,SMCLASSFRE 	],;
	aListBox[ oListBox:nAT,SMTIPOPER  	],;
	aListBox[ oListBox:nAT,SMTRECHO   	],;
	aListBox[ oListBox:nAT,SMTABELA  	],;
	aListBox[ oListBox:nAT,SMNUMNEGOC 	],;
	aListBox[ oListBox:nAT,SMROTA     	],;
	aListBox[ oListBox:nAT,SMDATVALID 	],;
	aListBox[ oListBox:nAT,SMFAIXA    	],;
	aListBox[ oListBox:nAT,SMTIPOVEI	]}}
	
	//-- Botoes da tela do monitor.
	@ aPosObj[3,1],001 BUTTON oBtn01	PROMPT STR0011	ACTION (nOpca := 1, oDlg:End()) OF oDlg PIXEL SIZE 035,011 //"Confirm"
	@ aPosObj[3,1],040 BUTTON oBtn02	PROMPT STR0012	ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 // "Quit"

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1
		M->F2_TRANSP := cCodTrans 
		If ExistBlock('MA410SML')
			ExecBlock('MA410SML',.F.,.F.,{aListBox})
		EndIf
	End If

Return ( Nil )	 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ a410MrkSml³  Autor ³ Leandro Paulino     ³ Data ³07.11.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Escolhe a Transportadora para o Pedido de Venda            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ a410MrkSml()  		                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integração  OMS X TOTVSGFE                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function a410MrkSml(aListBox,nItemMrk,cCodTrans)

	Local nItem   := oListBox:nAt

	Default aListBox	:= {}
	Default nItemMrk	:= 0 	//Item já marcado        
	Default cCodTrans	:= "" 

	If nItemMrk == 0  //Nenhum Item Marcado em Memória
		If aListBox[nItem,SMEXISTMP]
			cCodTrans 	:=  aListBox[nItem,SMCODTRAN]
			aListBox[nItem,SMMARCA] := '1'	
			nItemMrk 	:= nItem                         		
		Else
			MsgAlert(STR0036)	//"Carrier not registered in Microsiga Protheus!"
		EndIf
	ElseIf nItemMrk == nItem //Item Já Marcado
		aListBox[nItem,SMMARCA] := '2'                
		nItemMrk := 0
		cCodTrans 	:=  ""
	Else //Marca o Item selecionado e desmarca o Item já marcado anteriormente.
		If aListBox[nItem,SMEXISTMP]
			aListBox[nItem,SMMARCA] 	:= '1'			
			aListBox[nItemMrk,SMMARCA] := '2'				
			nItemMrk 						:= nItem                         		
			cCodTrans 						:=  aListBox[nItem,SMCODTRAN]		
		Else
			MsgAlert(STR0036)	//"Carrier not registered in Microsiga Protheus!"
		EndIf	
	EndIf	

	oListBox:Refresh()

Return ( Nil )                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA410RetEmit ºAutor  ³VENDAS/CRM      º Data ³  19/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para retornar o codigo do emitente a partir da      º±±
±±º          ³ filial.                                                    º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³ Parämetro: cFil - Codigo da filial                         º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTA410RetEmit(cFil)

	Local aAreaGW0
	Local aArea := GetArea()
	Local cCodGFE := ""

	aAreaGW0 := GW0->( GetArea() )
	dbSelectArea("GW0")
	GW0->( dbSetOrder(1) )
	GW0->( DbSeek( Space( TamSx3("F2_FILIAL")[1] )+PadR( "FILIALEMIT",TamSx3("GW0_TABELA")[1] )+PadR( cFil,TamSx3("GW0_CHAVE")[1] ) ) )
	If !GW0->( EOF() ) .And. GW0->GW0_FILIAL == Space( TamSx3("F2_FILIAL")[1] );
	.And. GW0->GW0_TABELA == PadR( "FILIALEMIT",TamSx3("GW0_TABELA")[1] );
	.And. GW0->GW0_CHAVE == PadR( cFil,TamSx3("GW0_CHAVE")[1] )

		cCodGFE := PadR( GW0->GW0_CHAR01,TamSx3("GW1_EMISDC")[1] )
	EndIf
	RestArea( aAreaGW0 )

	RestArea( aArea )

Return cCodGFE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA410RetCGC ºAutor  ³VENDAS/CRM       º Data ³  19/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funçao para retornar o CGC de um determinado emitente na   º±±
±±º          ³ simulaçao de frete. Pois, nem sempre o codigo do emitente  º±±
±±º          ³ será o cnpj.                                               º±±
±±º          ³                                                            º±±
±±º          ³ Parämetro: cCodEmit - Codigo do emitente                   º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTA410RetCGC(cCodEmit)

	Local cCGC  := ""
	Local aArea := GetArea()

	dbSelectArea("GU3")
	dbSetOrder(1)

	If DBSeek(xFilial("GU3") + cCodEmit)
		cCGC := GU3->GU3_IDFED
	EndIf

	RestArea( aArea )

Return cCGC      

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³IntPVSServ| Autor ³TOTVS S.A.              Data ³ 20/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao utilizada para integracao do Pedido de Vendas com   ³±±
±±³           ³ o produto SISCOSERV da TRADE EASY.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPedido = Numero do Pedido de vendas                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function IntPVSServ(cPedido,nOpcao)
	Local aAreaAnt  := GetArea()
	Local aAreaSF2  := SF2->(GetArea())
	Local aAreaSD2  := SD2->(GetArea())
	Local lIntSServ := AvFlags("CONTROLE_SERVICOS_VENDA")
	Local lVENSEIC  := SuperGetMV("MV_FATSEEC",.F.,.F.) // Parametro utilizado para Integracao
	Local cSeek     := ""
	Local aCab      := {}
	Local aItens    := {}
	Local aLinha    := {} 
	Local aPE		:= {}

	Private lMsErroAuto := .F.

	Default cPedido := ""
	Default nOpcao  := 3 //Inclusao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³As funcoes AvFlags e EECPS400 sao de responsabilidade da equipe da ³
	//³TRADE-EASY qualquer ocorrencia nestas funcoes favor acionar a      |
	//³equipe de parceiros.                                               |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIntSServ .And. lVENSEIC .And. !Empty(cPedido) 
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))

		aAdd(aCab,{"EJW_FILIAL"		,xFilial("SF2")	,Nil})
		aAdd(aCab,{"EJW_PROCES"		,cPedido        ,Nil})
		aAdd(aCab,{"EJW_ORIGEM"		,"SIGAFAT"	    ,Nil})

		If dbSeek(cSeek:=xFilial("SF2")+cPedido)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Montagem do aCab (Array que contem o cabecalho do pedido de vendas)|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(aCab,{"EJW_IMPORT"		,SF2->F2_CLIENTE	,Nil})
			aAdd(aCab,{"EJW_LOJIMP"		,SF2->F2_LOJA	,Nil})
			aAdd(aCab,{"EJW_MOEDA"		,SF2->F2_MOEDA	,Nil})		//Numerico de 2
			aAdd(aCab,{"EJW_COMPL"   	,SF2->F2_MENNOTA	,Nil})
			aAdd(aCab,{"EJW_CONDPG"		,SF2->F2_CONDPAG	,Nil})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Montagem do Itens (Array que contem os itens do pedido de vendas)  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SD2")
			SD2->(dbGoTop())
			SD2->(dbSetOrder(1)) 
			SD2->(dbSeek(cSeek))
			Do While !Eof() .And. cSeek == SD2->D2_FILIAL+SD2->D2_DOC
				aLinha := {}
				aAdd(aLinha,{"EJX_FILIAL"		,SD2->D2_FILIAL	    ,Nil})
				aAdd(aLinha,{"EJX_PROCES"		,SD2->D2_DOC		,Nil})
				aAdd(aLinha,{"EJX_SEQPRC"		,SD2->D2_ITEM		,Nil})
				aAdd(aLinha,{"EJX_ITEM"			,SD2->D2_PRODUTO	,Nil})
				aAdd(aLinha,{"EJX_QTDE"			,SD2->D2_QUANT		,Nil})
				aAdd(aLinha,{"EJX_PRCUN"	  	,SD2->D2_PRCVEN		,Nil})
				aAdd(aLinha,{"EJX_VL_MOE"		,SD2->D2_VALOR 		,Nil})
				aAdd(aLinha,{"EJX_TX_MOE"		,SF2->F2_TXMOEDA	,Nil})
				aAdd(aItens,aLinha)
				SD2->(dbSkip())
			EndDo
		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Execucao da Rotina Automatica EECPS400                              |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		If ExistBlock("M410SSERV")
			aPE    := ExecBlock("M410SSERV",.F.,.F.,{aCab,aItens,nOpcao })
			aCab   := aPE[1]
			aItens := aPE[2]
		EndIf
		//If Len(aCab) > 0 .And. Len(aItens) > 0
		MsExecAuto({|a,b,c,d|EECPS400(a,b,c,d)},aCab,aItens,,nOpcao)
		//EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento de Seguranca                                             |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMsErroAuto
			ConOut(STR0037) //" - TES: "
			MostraErro()
		EndIf

	EndIf	

	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaAnt)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F4Veicu	³ Autor ³ Vitor Felipe			³ Data ³ 24/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pesquisa de notas Originais Veiculos Usados.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Parametros: 												  ³±±
±±³          ³ nOPc = Numerico - Opcao Focus.							  ³±±
±±³			 ³ cProduto = String - Codigo do Produto.					  ³±±
±±³			 ³ cChassi= String - Chassis do Veiculo.					  ³±±
±±³			 ³ Retorno: Base para impostos da nota de entrada			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Pedido de Venda para veiculos Usados.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F4Veicu(nOpc,cProduto,cChassi,aCols,N)

	Local cAliasSD1	:= GetNextAlias()   
	Local aArrayF4[0] 
	Local lQuery	:= .F.
	Local aObjects	:= {}
	Local aInfo   	:= {}
	Local aPosObj 	:= {}
	Local aSize     := MsAdvSize( .F. )
	Local cTexto1   := ""
	Local cTexto2   := ""
	Local cCadastro := ""
	Local nOAT      := 0
	Local nOpca     := 0
	Local oDlg
	Local oQual
	Local nPVeic	:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_BASVEIC"})
	Local nPNFOri 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_NFORI"})
	Local nPSerie	:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_SERIORI"})
	Local nPItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_ITEMORI"})


	Default cProduto:= ""
	Default cChassi := ""
	Default aCols	:= {}
	Default N		:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao do arquivo temporario com base nos itens do SD1         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	DbSelectArea("SIX")
	DbSetOrder(1)
	If !DbSeek("SD1" + "12")
		Return
	EndIf

	dbSelectArea("SD1")
	dbSetOrder(12)

	#IFDEF TOP
	lQuery := .T.

	BeginSql Alias cAliasSD1
		SELECT 
		SD1.D1_FILIAL,SD1.D1_COD,SD1.D1_ITEM,SD1.D1_CHASSI,SD1.D1_VUNIT,SD1.D1_TOTAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,SD1.D1_CUSTO,;
		SD1.D1_EMISSAO
		FROM
		%table:SD1% SD1
		WHERE 
		SD1.D1_FILIAL=%xFilial:SD1% AND 
		SD1.D1_COD=%Exp:cProduto% AND 
		SD1.D1_CHASSI=%Exp:cChassi% AND 			
		SD1.%NotDel%
		ORDER BY 
		SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SD1.D1_ITEM
	EndSql    	

	#ELSE
	MsSeek(xFilial("SD1")+cProduto+cChassi,.F.)
	#ENDIF

	While (cAliasSD1)->(!Eof())
		aAdd(aArrayF4,{(cAliasSD1)->D1_FILIAL,;
		(cAliasSD1)->D1_DOC,;
		(cAliasSD1)->D1_SERIE,;
		(cAliasSD1)->D1_FORNECE,;
		(cAliasSD1)->D1_LOJA,;
		(cAliasSD1)->D1_COD,;
		(cAliasSD1)->D1_ITEM,;
		(cAliasSD1)->D1_VUNIT,;
		(cAliasSD1)->D1_TOTAL,;
		STOD((cAliasSD1)->D1_EMISSAO),;
		(cAliasSD1)->D1_CUSTO})
		(cAliasSD1)->(dbSkip())
	EndDo

	If lQuery
		dbSelectArea(cAliasSD1)
		dbCloseArea()
		dbSelectArea("SD1")
	EndIf			

	If Len(aArrayF4) > 0

		aSize[1] /= 1.5
		aSize[2] /= 1.5
		aSize[3] /= 1.5
		aSize[4] /= 1.3
		aSize[5] /= 1.5
		aSize[6] /= 1.3
		aSize[7] /= 1.5

		aAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
		aAdd( aObjects, { 100, 060,.T.,.T.,.T.} )
		aAdd( aObjects, { 100, 020,.T.,.F.} )
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects,.T.)


		cCadastro:= OemToAnsi("Notas Fiscais de Origem")+"-"+OemToAnsi("Veiculos") 	//"Notas Fiscais de Origem"
		nOpca := 0

		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],000 To aSize[6],aSize[5] OF oMainWnd PIXEL 

		@ aPosObj[1,1],aPosObj[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg CENTERED LOWERED

		cTexto1 := AllTrim(RetTitle("F1_FORNECE"))+"/"+AllTrim(RetTitle("F1_LOJA"))+": "+SA2->A2_COD+"/"+SA2->A2_LOJA+"  -  "+RetTitle("A2_NOME")+": "+SA2->A2_NOME

		@ 002,005 SAY cTexto1 SIZE aPosObj[1,3],008 OF oPanel PIXEL
		cTexto2 := AllTrim(RetTitle("B1_COD"))+": "+SB1->B1_COD+"/"+SB1->B1_DESC
		@ 012,005 SAY cTexto2 SIZE aPosObj[1,3],008 OF oPanel PIXEL	

		@ aPosObj[2,1],aPosObj[2,2] LISTBOX oQual VAR cVar Fields HEADER OemToAnsi("Filial"),OemToAnsi("Nota Fiscal"),OemToAnsi("Id Controle"),OemToAnsi("Fornecedor"),OemToAnsi("Loja"),OemToAnsi("Cod. Produto"),OemToAnsi("Valor Original"),OemToAnsi("Data Emissao") SIZE aPosObj[2,3],aPosObj[2,4] ON DBLCLICK (nOpca := 1,oDlg:End()) PIXEL	//"Nota"###"S‚rie"###"Item"###"Valor Item"###"Valor IPI"
		oQual:SetArray(aArrayF4)
		oQual:bLine := { || {aArrayF4[oQual:nAT][1],aArrayF4[oQual:nAT][2],aArrayF4[oQual:nAT][3],aArrayF4[oQual:nAT][4],aArrayF4[oQual:nAT][5],aArrayF4[oQual:nAT][6],aArrayF4[oQual:nAT][11],DTOC(aArrayF4[oQual:nAT][10])}}

		DEFINE SBUTTON FROM aPosObj[3,1]+000,aPosObj[3,4]-030  TYPE 1 ACTION (nOpca := 1,oDlg:End()) 	ENABLE OF oDlg PIXEL
		DEFINE SBUTTON FROM aPosObj[3,1]+012,aPosObj[3,4]-030 TYPE 2 ACTION oDlg:End() 					ENABLE OF oDlg PIXEL

		ACTIVATE MSDIALOG oDlg VALID (nOAT := oQual:nAT, .t.) CENTERED

		If nOpca == 1
			aCols[N][nPVeic] :=  IIf(nPVeic > 0 , aArrayF4[nOAT][11] , 0 )  
			aCols[N][nPNFOri]:= aArrayF4[nOAT][2]
			aCols[N][nPSerie]:= aArrayF4[nOAT][3] // Observacao: Manter, deve trazer o Id da Serie Exemplo: "UNI072015ESPEC" e no acols apresentara somente "UNI" - Projeto Chave Unica
			aCols[N][nPItem] := aArrayF4[nOAT][7]
		Else
			Return(0)
		Endif

	Else
		HELP(" ",1,"F4NAONOTA")
	Endif

Return 


//------------------------------------------------------------------------------
/*/{Protheus.doc} A415GrvDPR

Rotina de manipulação das pendência de desenvolvimento no SIGADPR

@sample	A415GrvDPR(aItens)

@param		ExpA1 Item ou Itens a serem manipulados

@return	ExpL  Processamento realizado - Verdadeiro/Falso

@author	Thiago Tavares
@since		17/10/2013
@version	11.90 
/*/
//------------------------------------------------------------------------------
Static Function A410GrvDPR(aItemDPR)

	Local lRet 		:= .T.
	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaDGC	:= DGC->(GetArea())
	Local nIndex		:= 2
	Local lAchou	 	:= .F.
	Local nOpcao 		:= aItemDPR[1]
	Local cChaveP		:= "DGC_FILIAL+DGC_NRPD+DGC_NRSQPD+DGC_CDACPD"
	Local cCodProd 	:= aItemDPR[5] 

	// Se FOR Efetivação de Orçamento mudar o index a chave primaria do model de 2 para 3
	// 2 = DGC_FILIAL+DGC_NRPD+DGC_NRSQPD+DGC_CDACPD
	// 3 = DGC_FILIAL+DGC_NRBU+DGC_NRSQBU+DGC_CDACBU
	If IsInCallStack("MaBxOrc") 
		nIndex := 3
		cChaveP := "DGC_FILIAL+DGC_NRBU+DGC_NRSQBU+DGC_CDACBU"
	EndIf

	// aItemDPR[1] -> nOpc 3 = Inclusão 4 = Alteração 5 = Exclusão 
	// aItemDPR[2] -> CK_FILIAL->DGC_FILIAL 
	// aItemDPR[3] -> DGC_NRPD
	// aItemDPR[4] -> DGC_NRSQPD
	// aItemDPR[5] -> DGC_CDACPD

	DbSelectArea( "DGC" )	  // Pendencia de Desenvolvimento
	DGC->(DbSetOrder( nIndex ))   

	If ( aItemDPR[1] == 7 )
		nOpcao = 4
	EndIf 

	If (nOpcao == 4 .Or. (Type("lExAutoDPR") == "L" .And. lExAutoDPR)) .And. ( (aItemDPR[5] <> aItemDPR[6]) .And. !Empty(aItemDPR[6]) ) .And. !(IsInCallStack("MaBxOrc"))
		cCodProd := aItemDPR[6]
	EndIf		

	If IsInCallStack("MaBxOrc") 
		lAchou := DGC->(DbSeek(	PADR(aItemDPR[2], TAMSX3("DGC_FILIAL")[1],	" ") + ;
		PADR(aItemDPR[3], TAMSX3("DGC_NRBU")[1],		" ") + ;
		PADR(aItemDPR[4], TAMSX3("DGC_NRSQBU")[1],	" ") + ;
		PADR(cCodProd,	TAMSX3("DGC_CDACBU")[1],	" ")))
	Else
		lAchou := DGC->(DbSeek(	PADR(aItemDPR[2], TAMSX3("DGC_FILIAL")[1],	" ") + ;
		PADR(aItemDPR[3], TAMSX3("DGC_NRPD")[1],		" ") + ;
		PADR(aItemDPR[4], TAMSX3("DGC_NRSQPD")[1],	" ") + ;
		PADR(cCodProd,	 TAMSX3("DGC_CDACPD")[1],	" ")))
	EndIf
	
	If ( lAchou .And. aItemDPR[1] == 3 )
		MsgInfo(STR0038) //"There already is a pendency as this sales order number. Please, enter another number."
		Return(.F.)
	EndIf

	If lAchou .OR. nOpcao == 3

		oModel := FWLoadModel( 'DPRA350' )
		oModel:SetOperation( nOpcao )
		oModel:SetPrimaryKey( {cChaveP} )
		oModel:Activate()

		// Efetivando
		If aItemDPR[1] == 7	

			// Caso seja efetivação e não achou a dependencia, insere
			If !(lAchou) .And. IsInCallStack("MaBxOrc")
				oModel:DeActivate()
				oModel:SetOperation( 3 )
				oModel:SetPrimaryKey( {cChaveP} )
				oModel:Activate()
				oModel:SetValue( "DGCMASTER", "DGC_NRBU",	  "" )
				oModel:SetValue( "DGCMASTER", "DGC_NRSQBU", "" )
				oModel:SetValue( "DGCMASTER", "DGC_CDACBU", "" )
			EndIf

			oModel:SetValue( "DGCMASTER", "DGC_FILIAL", aItemDPR[2] )
			oModel:SetValue( "DGCMASTER", "DGC_NRPD",   aItemDPR[6] )
			oModel:SetValue( "DGCMASTER", "DGC_NRSQPD", aItemDPR[7] )
			oModel:SetValue( "DGCMASTER", "DGC_CDACPD", aItemDPR[8] )
			oModel:SetValue( "DGCMASTER", "DGC_LGFTEV", "0" )		

			// Inclusao
			//ElseIf nOpcao == MODEL_OPERATION_INSERT
		ElseIf nOpcao == 3  

			oModel:SetValue( "DGCMASTER", "DGC_FILIAL", aItemDPR[2] )
			oModel:SetValue( "DGCMASTER", "DGC_NRBU",	  "" )
			oModel:SetValue( "DGCMASTER", "DGC_NRSQBU", "" )
			oModel:SetValue( "DGCMASTER", "DGC_CDACBU", "" )
			oModel:SetValue( "DGCMASTER", "DGC_NRPD",   aItemDPR[3] )
			oModel:SetValue( "DGCMASTER", "DGC_NRSQPD", aItemDPR[4] )
			oModel:SetValue( "DGCMASTER", "DGC_CDACPD", aItemDPR[5] )

			// Alteracao
			//ElseIf nOpcao == MODEL_OPERATION_UPDATE
		ElseIf nOpcao == 4
			oModel:SetValue( "DGCMASTER", "DGC_NRPD",   aItemDPR[3] )
			oModel:SetValue( "DGCMASTER", "DGC_NRSQPD", aItemDPR[4] )
			oModel:SetValue( "DGCMASTER", "DGC_CDACPD", aItemDPR[5] )
		EndIf

		If oModel:VldData()
			oModel:CommitData()
		Else
			aErro := oModel:GetErrorMessage()
			DPRXError( "DPRA350", aErro[6])    	
			lRet  := .F.
		EndIf

		oModel:DeActivate() 
		oModel:Destroy()

	EndIf 

	RestArea(aAreaDGC) 
	RestArea(aAreaSB1)
	RestArea(aArea)

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ma410VlDavºAutor  ³Cesar A. Bianchi    º Data ³  18/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o pedido de venda possui relacionamento com algum º±±
±±º          ³DAV no SIGALOJA. Se sim, permite alteracao somente se o DAV º±±
±±º          ³encontra-se com status de "Orçamento em Aberto" e chama a   º±±
±±º          ³funcao de exclusao de DAV									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10 - SIGAPAF/SIGALOJA                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ma410VlDav(cNumPed)
	Local aArea 	:= getArea()                                   
	Local lRet 		:= .T.
	Local aItenSL2	:= {}
	Local nI		:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Varre a SL2 em busca de itens que utilizem este nro de pedido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SL2')
	SL2->(dbSetOrder(6))
	if SL2->(dbSeek(xFilial('SL2')+cNumPed))

		While SL2->(!Eof()) .and. alltrim(SL2->L2_PEDSF2) == cNumPed
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se ja emitiu DOC para este orcamento, entao aborta ³
			//³a busca e retorna .F. para a alteracao do pedido   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SL2->L2_DOC) .and. !Empty(SL2->L2_SERIE) .or. !FR271CVldImp(SL2->L2_NUM)
				If len(aAutoCab) > 0
					Conout(STR0039 + cNumPed + STR0040 ) //" The Sales order: " - " has a relationship with a DAV and it has a tax document issued, or it has already been imported by a POS, therefore it will not be changed"
				Else
					Aviso(STR0041,STR0042,{STR0043}) //"Edition blocked" - "This sales order has a relationship with a DAV and it has a tax document issued, or it has already been imported by a POS" - "Back"
				EndIf
				lRet := .F.
				exit
			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Adiciona no array de DAV's a cancelar³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aScan(aItenSL2, { |x| Alltrim(x[1]) == SL2->L2_NUM } ) <= 0
					aAdd(aItenSL2,{SL2->L2_NUM,SL2->L2_ITEM,SL2->L2_PEDSF2,SL2->L2_ITESD2,SL2->L2_SEQUEN})
					lRet := .T.	
				EndIf
			EndIf
			SL2->(dbSkip())
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cancela os DAVs que possuem relacao a este pedido de venda³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			For nI := 1 to len(aItenSL2)
				MsgRun(STR0044 + alltrim(aItenSL2[nI,1] + STR0045),STR0046,{||  Mt410DelDv(aItenSL2[nI,1]) }) //"Deleting DAV no.: " - " (pending)" - "Please, wait..."
			Next nI
		EndIf
	EndIf

	RestArea(aArea)
Return lRet 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT410DelDvºAutor  ³Cesar A. Bianchi    º Data ³  18/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclui DAV (SIGAPAF) passado como parametro                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10 - SIGAPAF/SIGALOJA                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Mt410DelDv(cNumDAV)
	Local aArea 	:= getArea()
	Default cNumDAV := ""

	If !Empty(cNumDAV)
		//Abre areas
		dbSelectArea('SL1')
		SL1->(dbSetOrder(1))
		dbSelectArea('SL2')
		SL2->(dbSetOrder(1))
		dbSelectArea('SL4')
		SL4->(dbSetOrder(1))
		dbSelectArea('SC9')
		SC9->(dbSetOrder(1))

		//Exclui SL1
		If SL1->(dbSeek(xFilial('SL1')+cNumDAV))
			RecLock('SL1',.F.)
			SL1->(dbDelete())	//Confirmar se eh dbDelete ou alteracao de campo
			SL1->(msUnlock())
		EndIf

		//Exclui a SL2
		If SL2->(dbSeek(xFilial('SL2')+cNumDAV))
			While SL2->(!Eof()) .and. SL2->(L2_NUM) == cNumDAV

				//Limpa o C9_DAV deste item como DAV nao emitido
				If SC9->(dbSeek(xFilial('SC9') + SL2->L2_PEDSF2 + SL2->L2_ITESD2 + SL2->L2_SEQUEN ))
					RecLock('SC9',.F.)
					SC9->C9_DAV := ""
					SC9->(msUnlock())
				EndIf

				RecLock('SL2',.F.)
				SL2->(dbDelete())	//Confirmar se eh dbDelete ou alteracao de campo
				SL2->(msUnlock())
				SL2->(dbSkip())
			EndDo
		EndIf

		//Exlui a SL4
		If SL4->(dbSeek(xFilial('SL4')+cNumDAV))
			RecLock('SL4',.F.)
			SL4->(dbDelete())	//Confirmar se eh dbDelete ou alteracao de campo
			SL4->(msUnlock())			
		EndIf
	EndIf

	RestArea(aArea)

Return 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³A410rentPV³ Autor ³ Eduardo Riera         ³ Data ³16.11.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Funcao de calculo da rentabilidade do pedido de venda        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc                                                        ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta funcao efetua o calculo da rentabilidade de um pedido de³±±
±±³          ³venda.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a410RentPV( aCols ,nUsado ,aRenTab ,aVencto ,nPTES,nPProduto,nPLocal,nPQtdVen, dDtEmissao,nMoeda )
	Local nItem    := 0
	Local nX       := 0
	Local nY       := 0

	Default nMoeda := 1

	If len(aRenTab) > 0 .AND. (aRentab[Len(aRentab)][1] == "")
		aSize( aRentab ,Len(aRentab)-1)
		For nX := 1 To Len(aRentab)
			aRentab[nX][2] := val(StrTran(StrTran(aRentab[nX][2],".",""),",","."))
			aRentab[nX][3] := val(StrTran(StrTran(aRentab[nX][3],".",""),",","."))
			aRentab[nX][4] := 0
			aRentab[nX][5] := 0
			aRentab[nX][6] := 0
		Next nX
	EndIf

	For nX := 1 To Len(aCols)
		If Len(aCols[nX])==nUsado .Or. !aCols[nX][nUsado+1]
			nItem++
			nY := aScan(aRentab,{|x| x[1] == aCols[nX][nPProduto]})
			If nY <> 0
				If cPaisLoc <> 'MEX'
					aRentab[nY][4] += Max(Ma410Custo(nItem,aVencto,aCols[nX][nPTES],aCols[nX][nPProduto],aCols[nX][nPLocal],aCols[nX][nPQtdVen],dDtEmissao),0)
					aRentab[nY][5] := aRentab[nY][4]-aRentab[nY][3] //Max(aRentab[nY][4]-aRentab[nY][3],0)
				Else
					If nMoeda <> M->F2_MOEDA
						aRentab[nY][4] += xMoeda(MaFisRet(nX,'IT_VALMERC'),M->F2_MOEDA,nMoeda,dDataBase)
						aRentab[nY][5] := xMoeda(MaFisRet(nX,'IT_VALMERC'),M->F2_MOEDA,nMoeda,dDataBase)-aRentab[nY][3]
					Else
						aRentab[nY][4] += MaFisRet(nX,'IT_VALMERC')
						aRentab[nY][5] := MaFisRet(nX,'IT_VALMERC')-aRentab[nY][3]
					EndIf
				EndIf			
				aRentab[nY][6] := aRentab[nY][5]/aRentab[nY][4]*100
			EndIf
		EndIf
	Next nX
	aAdd(aRentab,{"",0,0,0,0,0})
	For nX := 1 To Len(aRentab)
		If nX <> Len(aRentab)
			aRentab[Len(aRentab)][2] += aRentab[nX][2]
			aRentab[Len(aRentab)][3] += aRentab[nX][3]
			aRentab[Len(aRentab)][4] += aRentab[nX][4]
			aRentab[Len(aRentab)][5] += aRentab[nX][5]
			aRentab[Len(aRentab)][6] := aRentab[Len(aRentab)][5]/aRentab[Len(aRentab)][4]*100
		EndIf
		If !(AllTrim(FunName()) $ "MATA851|MATA852|MATA853")	//Rotinas de Análise de Rentabilidade
			aRentab[nX][2] := TransForm(aRentab[nX][2],"@e 999,999,999.999999")
			aRentab[nX][3] := TransForm(aRentab[nX][3],"@e 999,999,999.999999")
			aRentab[nX][4] := TransForm(aRentab[nX][4],"@e 999,999,999.999999")
			aRentab[nX][5] := TransForm(aRentab[nX][5],"@e 999,999,999.999999")
			aRentab[nX][6] := TransForm(aRentab[nX][6],"@e 999,999,999.999999")
		EndIf
	Next nX
	If Existblock("MA410RPV")
		aRentab := ExecBlock("MA410RPV",.F.,.F.,aRentab)
	EndIf    

Return( aRentab )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³aMHead    ³ Autor ³ Gustavo G. Rueda      ³ Data ³05/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para montagem do HEADER do GETDADOS                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias da tabela base para montagem do HEADER      ³±±
±±³          ³cNCmps -> Campos que nao serao considerados no HEADER       ³±±
±±³          ³aH -> array no qual o HEADER serah montado                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function aMHead(cAlias,cNCmps,aH)
	Local	lRet	:=	.T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a Integridade dos campos de Bancos de Dados            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !Eof() .And. (X3_ARQUIVO==cAlias)
		IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .and. !(AllTrim(X3_CAMPO)+"/"$cNCmps)
			aAdd(aH,{ Trim(X3Titulo()), ;
			AllTrim(X3_CAMPO),;
			X3_PICTURE,;
			X3_TAMANHO,;
			X3_DECIMAL,;
			X3_VALID,;
			X3_USADO,;
			X3_TIPO,;
			X3_F3,;
			X3_CONTEXT,;
			X3_CBOX,;
			X3_RELACAO})
		Endif
		dbSkip()
	Enddo    

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a410BXCG	³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza a baixa do pedido de venda faturado pela 	          ³±±
³	gestão de concessionarias                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1: cCliente //cliente do pedido                         ³±±
±±³          ³ Exp2: cLoja    //Loja do pedido                            ³±±
±±³          ³ Exp3: cC5Num   // Numero do pedido	                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A410BxGc(cCliente,cLoja,xC5Num,xC5Nota,xC5Serie)
	Local aArea  := GetArea()
	Local lRet   := .T.
	Local cItem  := ""
	Local cSerieId := ""

	Default cCliente 	:= IF(ValType(cCliente)=="C",cCliente,"")
	Default cLoja	 	:= IF(ValType(cLoja)=="C",cLoja,"")
	Default xC5Num	 	:= IF(ValType(xC5Num)=="C",xC5Num,"")
	Default xC5Nota	 	:= IF(ValType(xC5Num)=="C",xC5Nota,"")
	Default xC5Serie	:= IF(ValType(xC5Num)=="C",xC5Serie,"")

	//Verifica se o cC5Num esta preenchido
	If Empty(xC5Num) .OR. Empty(xC5Nota) .OR. Empty(xC5Serie)
		lRet := .F.
		Aviso(STR0019,STR0047,{STR0021}) //"Attention" - "Number of sales order or Invoice or Series not entered" - "OK"
	EndIf

	//Projeto Chave Unica parte do principio que o xC5Serie passado para
	//a funcao A410BxGc eh o ID de Controle vindo do campo VV0_SERNFI 
	cSerieId := xC5Serie

	If lRet
		DbSelectArea("SF2")
		DbSetOrder(3)

		If DbSeek(xFilial('SF2')+PADR(cCliente,TAMSX3("F2_CLIENTE")[1])+PADR(cLoja,TamSx3("F2_LOJA")[1])+xC5Num)
			If Empty(SF2->F2_NOTA) .OR. SF2->F2_LIBEROK <> 'E' .And. !Empty(SF2->F2_BLQ)
				DbSelectArea("SD2")
				DbSetOrder(1)
				If DbSeek(xFilial('SD2')+xC5Num)
					While !Eof() .And. xFilial('SD2')+ SD2->D2_DOC == xFilial('SF2') + xC5Num
						cItem := SD2->D2_ITEM
						DbSelectArea("SC9")
						DbSetOrder(2)
						If DbSeek(xFilial('SC9')+PADR(cCliente,TAMSX3("C9_CLIENTE")[1])+PADR(cLoja,TamSx3("C9_LOJA")[1])+xC5Num+cItem)
							If Empty(SC9->C9_BLEST) .AND. Empty(SC9->C9_BLCRED) .AND. Empty(SC9->C9_BLOQUEI)	
								RecLock("SC9", .F.)
								REPLACE C9_NFISCAL   WITH xC5Nota

								SerieNfId("SC9",1,"C9_SERIENF",,,, cSerieId )

								REPLACE C9_BLCRED    WITH '10'
								REPLACE C9_BLEST     WITH '10' 							
								MsUnlock()
							Else  
								Aviso(STR0019,STR0048,{STR0021}) //"Attention" - "Sales Order has some obstruction" - "OK"
								lRet := .F.
							EndIf	
						Else
							lRet := .F.
							Aviso(STR0019,STR0048,{STR0021}) //"Attention" - "Sales Order has some obstruction" - "OK"
						EndIf
						If lRet
							RecLock("SD2", .F.)                                 		
							REPLACE D2_NOTA WITH xC5Nota

							SerieNfId("SD2",1,"D2_SERIE",,,, cSerieId )

							MsUnlock()
						EndIf

						SD2->(DbSkip())
					End
				EndIf
				If lRet
					RecLock("SF2", .F.)
					REPLACE F2_NOTA     WITH xC5Nota

					SerieNfId("SF2",1,"F2_SERIE",,,, cSerieId )

					REPLACE F2_LIBEROK  WITH "S" 
					MsUnlock()
				EndIf
			Else
				Aviso(STR0019,STR0049,{STR0021}) //"Attention" - "Sales Order already closed" - "OK"
				lRet :=.F.
			EndIf		
		Else
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} MATA476FL
	Función utilizada para validar datos para inclusión de Financiero.

	@type Function
	@author marco.rivera
	@since 23/09/2021
	@version 1.0
	@param oDupl, Objeto, Contiene información de Objeto Duplicados.
	@param aDupl, Arreglo, Contiene información de Array Duplicados.
	@param aColsOri, Arreglo, Contiene campos de Duplicados.
	@param oDlg, Objeto, Ventana de Planilla Financiera.
	@example
	MATA476FL(oDupl,aDupl,aColsOri,oDlg)
	@see (links_or_references)
	/*/
Function MATA476FL(oDupl,aDupl,aColsOri,oDlg)

	Local lRet 			:= .T.
	Local nCount		:= 0
	Local nSomaOri		:= 0
	Local nSomaFin		:= 0

	For nCount := 1 to Len(aColsOri)
		nSomaOri += aColsOri[nCount,2]
	Next nCount

	For nCount := 1 to Len(oDupl:aCols)
		If oDupl:aCols[nCount,3] == .F.
			If oDupl:aCols[nCount,1] < dDataBase
				Help(" ",1,"E1_VENCTO",,STR0050,1,0) //"Check the due date."
				lRet := .F.
			EndIf
			If oDupl:aCols[nCount,2] <= 0
				Help(" ",1,"E1_VALOR",,STR0051,1,0) //"Value smaller than or equal to 0."
				lRet := .F.
			EndIf
			nSomaFin += oDupl:aCols[nCount,2]
		EndIf
	Next nCount

	If nSomaOri <> nSomaFin
		Help(" ",1,"E1_VALOR",,STR0052,1,0) //"Check the sum of amounts."
		lRet := .F.
	EndIf

	If lRet
		aDupl := {}
		For nCount := 1 to Len(oDupl:aCols)
			AaDD(aDupl,{oDupl:aCols[nCount,1],TransForm(oDupl:aCols[nCount,2],PesqPict("SE1","E1_VALOR"))})
		Next nCount
		oDlg:End()
	EndIf

Return

/*/{Protheus.doc} MATA476FIN
	Función utilizada para inclusión de Movimientos en Financiero de forma automática
	al incluir un Remito de forma manual.

	@type Function
	@author marco.rivera
	@since 23/09/2021
	@version 1.0
	@example
	MATA476FIN(aHdNew,aColsNew,cRotina,cDocRem,cSerRem,cCliRem,cLojRem)
	@see (links_or_references)
	/*/
Function MATA476FIN(aHdNew,aColsNew,cRotina,cDocRem,cSerRem,cCliRem,cLojRem)

	Local aFields	:= {}
	Local aSF2		:= {}
	Local aDupl2	:= {}
	Local aTitulo	:= {}
	Local nCount	:= 0
	Local nI		:= 0
	Local cQuery 	:= ''
	Local cAliasED 	:= GetNextAlias()
	Local aArea		:= GetArea()
	Local aListFld		:= {}
	Local cFieldBox		:= "X3_CBOX"

	Private aHeader	:= {}
	Private aCols	:= {}

	Default aHdNew	:= {}
	Default aColsNew:= {}
	Default cRotina	:= ''
	Default cDocRem	:= ''
	Default cSerRem := ''
	Default cCliRem	:= ''
	Default cLojRem := ''
	
	If !Empty(cDocRem) .And. !Empty(cSerRem)
		DbSelectArea('SF2')
		SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		SF2->(MSSeek(xFilial('SF2')+cDocRem+cSerRem+cCliRem+cLojRem))
	EndIf

		AAdd(aSF2,"F2_EMISSAO")
		AAdd(aSF2,"F2_DOC")
		AAdd(aSF2,"F2_SERIE")
		AAdd(aSF2,"F2_CLIENTE")
		AAdd(aSF2,"F2_LOJA")
		AAdd(aSF2,"F2_COND")
		AAdd(aSF2,"F2_FRETE")
		AAdd(aSF2,"F2_DESPESA")
		AAdd(aSF2,"F2_SEGURO")
		Aadd(aSF2, "NOUSER")

		aListFld := {"D2_ITEM", ;
					"D2_COD", ;
					"D2_QUANT", ;
					"D2_QTDAFAT", ;
					"D2_QTDEFAT", ;
					"D2_QTDEDEV", ;
					"D1_TES", ;
					"D2_PRCVEN", ;
					"D2_DESCON", ;
					"D2_TOTAL", ;
					"D2_TES", ;
					"D2_LOCAL", ;
					"D2_CLASFIS", ;
					"D2_NUMLOTE", ;
					"D2_LOTECTL", ;
					"D2_PRUNIT", ;
					"D2_CF", ;
					"D2_FILIAL"}

		For nI := 1 to Len(aListFld)
			If !Empty(FWSX3Util():GetFieldType(aListFld[nI]))
				AAdd(aFields, {aListFld[nI], GetSx3Cache(aListFld[nI], "X3_TIPO"), GetSx3Cache(aListFld[nI], "X3_TAMANHO"), GetSx3Cache(aListFld[nI], "X3_DECIMAL")})
			EndIf
		Next nI

		cQuery := " SELECT SD2.D2_FILIAL, SD2.D2_LOCAL, SD2.D2_PRCVEN AS D2_PRUNIT, SD2.D2_CLASFIS, SD2.D2_NUMLOTE, "
		cQuery += " SD2.D2_LOTECTL, SD2.D2_CF, SD2.D2_ITEM, SD2.D2_COD, SD2.D2_QUANT, SD2.D2_QTDEDEV, SD2.D2_PRCVEN, "
		cQuery += " SD2.D2_TOTAL, SD2.D2_DESCON, SD2.D2_TES, '   ' as D1_TES, SD2.D2_QTDAFAT, SD2.D2_QTDEFAT "
		cQuery += " FROM " + RetSqlTab("SD2") + " (NOLOCK)"
		cQuery += " WHERE SD2.D2_FILIAL = '" + SF2->F2_FILIAL + "' "
		cQuery += " AND SD2.D2_DOC = '" + SF2->F2_DOC + "' "
		cQuery += " AND SD2.D2_SERIE = '" + SF2->F2_SERIE + "' "
		cQuery += " AND SD2.D2_CLIENTE = '" + SF2->F2_CLIENTE + "' "
		cQuery += " AND SD2.D2_LOJA = '" + SF2->F2_LOJA + "' "
		cQuery += " AND SD2.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)

		If Select(cAliasED) > 0
			DbSelectArea(cAliasED)
			(cAliasED)->(DbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasED, .F., .T.)


		If Upper(FwRetIdiom()) == "ES"
			cFieldBox := "X3_CBOXSPA"
		ElseIf Upper(FwRetIdiom()) == "EN"
			cFieldBox := "X3_CBOXENG"
		EndIf

		For nCount := 1 to Len(aFields)
			If !Empty(FWSX3Util():GetFieldType(aFields[nCount][1])) //Valida que exista el campo
				
				AAdd(aHeader,{	AllTrim(FWX3Titulo(aFields[nCount][1])),; //Título del campo
								aFields[nCount][1],; //Nombre del Campo
								GetSx3Cache(aFields[nCount][1], "X3_PICTURE"),;
								GetSx3Cache(aFields[nCount][1], "X3_TAMANHO"),;
								GetSx3Cache(aFields[nCount][1], "X3_DECIMAL"),;
								GetSx3Cache(aFields[nCount][1], "X3_VALID"),;
								GetSx3Cache(aFields[nCount][1], "X3_USADO"),;
								GetSx3Cache(aFields[nCount][1], "X3_TIPO"),;
								GetSx3Cache(aFields[nCount][1], "X3_F3"),;
								GetSx3Cache(aFields[nCount][1], "X3_CONTEXT"),;
								GetSx3Cache(aFields[nCount][1], cFieldBox),;
								GetSx3Cache(aFields[nCount][1], "X3_RELACAO"),;
								GetSx3Cache(aFields[nCount][1], "X3_WHEN"),;
								GetSx3Cache(aFields[nCount][1], "X3_VISUAL"),;
								GetSx3Cache(aFields[nCount][1], "X3_VLDUSER"),;
								GetSx3Cache(aFields[nCount][1], "X3_PICTVAR"),;
								GetSx3Cache(aFields[nCount][1], "X3_OBRIGAT")})
			Endif

		Next nCount

		DbSelectArea(cAliasED)
		(cAliasED)->(DbGoTop())

		While !EOF()
			AAdd(aCols,Array(Len(aHeader)+1))
			For nI := 1 To Len(aHeader)
				If AllTrim(aHeader[nI,10]) <> "V"
					If AllTrim(aHeader[nI][2]) == 'D1_TES'
						aCols[Len(aCols)][nI] := Posicione('SB1',1,xFIlial('SB1')+(cAliasED)->(D2_COD),'B1_TE')
					Else
						aCols[Len(aCols)][nI]	:= (cAliasED)->&(aHeader[nI][2])
					EndIf
				Else
					aCols[Len(aCols)][nI]	:= Criavar(aHeader[nI][2])
				EndIf
			Next nI
			aCols[Len(aCols)][Len(aHeader)+1] := .F.

			//Tratamento devolucao
			If FunName() == 'MATA462DN'

				If !Empty(aColsNew)
					If cRotina == 'LocxDelNF'
						If aScan(aHdNew,{|x| AllTrim(x[2]) == "D1_QUANT"}) > 0
							If aColsNew[Len(aCols),aScan(aHdNew,{|x| AllTrim(x[2]) == "D1_QUANT"})] == aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]
								aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 
								aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]	:= 0
								aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})]		:= (aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] - aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]) * aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})]
							Else
								aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDAFAT"})]
								//aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] - (aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] - aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]) 
								aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})] - aColsNew[Len(aCols),aScan(aHdNew,{|x| AllTrim(x[2]) == "D1_QUANT"})]
								aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})]		:= (aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] - aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]) * aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})]
							EndIf
						Else
							aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 
							aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})] + aColsNew[Len(aCols),aScan(aHdNew,{|x| AllTrim(x[2]) == "D1_QUANT"})]
							aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})]		:= (aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] - aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]) * aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})]
						EndIf	
					Else 
						If cRotina == 'GravaNfGeral'
								aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDAFAT"})]
								aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})] 
								aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})]		:= (aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDAFAT"})] - aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]) * aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})]							
						Else 
							aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDAFAT"})]
							aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})] + aColsNew[Len(aCols),aScan(aHdNew,{|x| AllTrim(x[2]) == "D1_QUANT"})]
							aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})]		:= (aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] - aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]) * aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})]
						EndIf
					EndIf
				Else
					aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})] + aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDAFAT"})]
					aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]	:= 0
					aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})]		:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] * aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})]
				EndIf

			ElseIf FunName() == 'MATA468N'
			
				aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})]  - aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEFAT"})]
				aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]	:= 0
				aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})]		:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] * aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})]
			
			ElseIf FunName() == 'MATA467N'
			
				aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 	:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDAFAT"})]  + aColsNew[Len(aCols),aScan(aHdNew,{|x| AllTrim(x[2]) == "D2_QUANT"})]
				aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]	:= 0
				aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})]		:= aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] * aCols[Len(aCols)][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})]
			
			EndIf

			DbSelectArea(cAliasED)
			(cAliasED)->(DbSkip())
		Enddo

	RegToMemory("SF2",.F.)
	aDupl2 := MATA476(2,.T.,,aCols)

	If Len(aDupl2) > 0

		For nCount := 1 to Len(aDupl2)

			aTitulo := { { "E1_PREFIXO"  , SF2->F2_SERIE													, NIL },;
			{ "E1_NUM"      , SF2->F2_DOC																	, NIL },;
			{ "E1_TIPO"     , 'PRE'       	       															, NIL },;
			{ "E1_NATUREZ"  , Posicione('SA1',1,xFilial('SA1')+SF2->F2_CLIENTE+SF2->F2_LOJA,'A1_NATUREZ')	, NIL },;
			{ "E1_CLIENTE"  , SF2->F2_CLIENTE          														, NIL },;
			{ "E1_LOJA" 	, SF2->F2_LOJA          														, NIL },;
			{ "E1_EMISSAO"  , SF2->F2_EMISSAO																, NIL },;
			{ "E1_VENCTO"   , aDupl2[nCount,1]																, NIL },;
			{ "E1_VENCREA"  , aDupl2[nCount,1]																, NIL },;
			{ "E1_VALOR"    , Val(StrTran(aDupl2[nCount,2],',',''))											, NIL },;
			{ "E1_ORIGEM"   , 'MATA462N'																	, NIL } }

			MsExecAuto( { |x,y| FINA040(x,y)} , aTitulo,3 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

		Next nCount

	EndIf
	RestArea(aArea)

Return
