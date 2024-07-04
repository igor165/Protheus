#INCLUDE "RWMAKE.CH"   
#INCLUDE "MATA410.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"       
#INCLUDE "FWADAPTEREAI.CH"     
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "FWLIBVERSION.CH"

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
 
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³MA410Impos³ Autor ³ Eduardo Riera         ³ Data ³06.12.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Ma410Impos( nOpc)                                            ³±±
±±³          ³Funcao de calculo dos impostos contidos no pedido de venda   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc                                                        ³±±
±±³          ³ lRetTotal - Logico - Quando .T. retorna total com impostos  ³±±
±±³          ³ aRefRentab - Array - Retorna por referencia o array da aba   ³±±
±±³          ³ rentabilidade                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Esta funcao efetua os calculos de impostos (ICMS,IPI,ISS,etc)³±±
±±³          ³com base nas funcoes fiscais, a fim de possibilitar ao usua- ³±±
±±³          ³rio o valor de desembolso financeiro.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ma410Impos( nOpc, lRetTotal, aRefRentab )

Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aFisGet	:= {}
Local aFisGetSC5:= {}
Local aTitles   := {STR0044,STR0045,STR0080} //"Nota Fiscal"###"Duplicatas"###"Rentabilidade"
Local aDupl     := {}
Local aVencto   := {}
Local aFlHead   := { STR0046,STR0047,STR0063 } //"Vencimento"###"Valor"
Local aEntr     := {}
Local aDuplTmp  := {}
Local aNfOri    := {}
Local aRFHead   := { RetTitle("C6_PRODUTO"),RetTitle("C6_VALOR"),STR0081,STR0082,STR0083,STR0084} //"C.M.V"###"Vlr.Presente"###"Lucro Bruto"###"Margem de Contribuição(%)"
Local aRentab   := {}
Local nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
Local nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPDtEntr  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENTREG"})
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPCodRet  := Iif(cPaisLoc=="EQU",aScan(aHeader,{|x| AllTrim(x[2])=="C6_CONCEPT"}),"")
Local nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
Local nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
Local nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
Local nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
Local nPProvEnt := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PROVENT"})
Local nPAbatISS := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ABATISS"})
Local nPLote    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
Local nPSubLot	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
Local nPClasFis := aScan(aHeader,{|x| AllTrim(x[2])=="C6_CLASFIS"})
Local nPAliqISS := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ALIQISS"})
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
Local lDtEmi    := SuperGetMv("MV_DPDTEMI",.F.,.T.)
Local dDataCnd  := M->C5_EMISSAO
Local oDlg
Local oDupl
Local oFolder
Local oRentab
Local lCondVenda := .F. // Template GEM
Local aRentabil := {}
Local cProduto  := ""
Local nTotDesc  := 0
Local lSaldo    := MV_PAR04 == 1 .And. !INCLUI
Local nQtdEnt   := 0
Local lM410Ipi	:= ExistBlock("M410IPI")
Local lM410Icm	:= ExistBlock("M410ICM")
Local lM410Soli	:= ExistBlock("M410SOLI")
Local lUsaVenc  := .F.
Local lIVAAju   := .F.
Local lRastro	 := ExistBlock("MAFISRASTRO")
Local lRastroLot := .F.
Local lPParc	:=.F.
Local aSolid	:= {}
Local nLancAp	:=	0
Local aHeadCDA		:=	{}
Local aColsCDA		:=	{}
Local aHeadCIP		:=	{}
Local aColsCIP		:=	{}
Local aTransp	:= {"",""}
Local aSaldos	:= {}
Local aInfLote	:= {}
Local a410Preco := {}  // Retorno da Project Function P_410PRECO com os novos valores das variaveis {nValMerc,nPrcLista}
Local nAcresUnit:= 0	// Valor do acrescimo financeiro do valor unitario
Local nAcresTot := 0	// Somatoria dos Valores dos acrescimos financeiros dos itens
Local dIni		:= Ctod("//") 
Local cEstado	:= SuperGetMv("MV_ESTADO") 
Local cTesVend  :=  SuperGetMv("MV_TESVEND",,"")
Local cCliPed   := "" 
Local lCfo      := .F.
Local nlValor	:= 0
Local nValRetImp:= 0
Local cImpRet 	:= ""
Local cNatureza :="" 
Local lM410FldR := .T.
Local aTotSolid := {}            
Local nValTotal := 0 //Valor total utilizado no retorno quando lRetTotal for .T.
Local nTotal	:= 0
Local aValMerc	:= {}
Local lRent      := AllTrim(FunName()) $ "MATA851|MATA852|MATA853" //Verifica se é executado pelos programas de rentabilidade
Local lContinua  := .F. 
Local nAliqISS  := 0
Local nVMercAux := 0
Local nPrcLsAux := 0
Local nPDesCab	:= 0
Local nTotPeso 	:= 0
Local lM410Vct	:= ExistBlock("M410VCT")
Local nPCodIss := aScan(aHeader,{|x| AllTrim(x[2])=="C6_CODISS"})
Local nPFciCod := aScan(aHeader,{|x| AllTrim(x[2])=="C6_FCICOD"})
Local cCodOrig := ""
Local lMvFisFras := SuperGetMv("MV_FISFRAS",.F.,.F.)
Local lMvFISAUCF := SuperGetMv("MV_FISAUCF",.F.,.F.)
Local nCusto     := 0
Local nMoeda	 := 1
Local nValIpiTrf := 0
Local nPIPITrf	 := Ascan(aHeader,{|x| Trim(x[2]) == "C6_IPITRF"})
Local nPosItem  := 0
Local nPosIt15	:= 0
Local nPosIt20	:= 0
Local nPosIt25	:= 0
Local nLinINS	:= 0
Local nAIS		:= {}
Local aAIS		:= {}
Local nPItSC6	:= 0
Local nACols	:= 0
Local lagrSolid := .F.

Local nISSNDesc := 0
Local nValISS   := 0
Local nTotTit   := 0
Local lDescISS	:= SuperGetMV("MV_DESCISS",,.F.)
Local lTpAbISS	:= SuperGetMV("MV_TPABISS",,"") == "1"
Local nVRetISS	:= SuperGetMV("MV_VRETISS",,0)
Local lRndIss   := SuperGetMv("MV_RNDISS",,.F.)
Local nPTpOper  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_OPER"})
Local lOrigLote := SuperGetMV("MV_ORILOTE",.F.,.F.) .And. FindFunction("OrigemLote")
Local cOrigem	:= ""
Local lAliasCIP	:= AliasInDic("CIP")

Local cDicCampo  := ""
Local cDicArq    := ""
Local cValid     := ""
Local cDicUsado  := ""
Local cDicNivel  := ""
Local cDicTitulo := ""
Local cDicPictur := ""
Local nDicTam    := ""
Local nDicDec    := ""
Local cDicValid  := ""
Local cDicTipo   := ""
Local cDicF3     := ""
Local cDicContex := ""

Local cDocOri	:= ""
Local cSerOri	:= ""
Local lApiTrib  := Type("oApiManager") == "O" .AND. oApiManager:cAdapter == "MATSIMP"
Local aJSon     := {}
Local oImpostos := Nil
Local oImpDet	:= Nil
Local nImpTot   := 0
Local nDetImp	:= 0

Default lRetTotal := .F.
Default aRefRentab := {}

PRIVATE oLancApICMS
PRIVATE _nTotOper_ := 0		//total de operacoes (vendas) realizadas com um cliente - calculo de IB - Argentina
Private _aValItem_ := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca referencias no SC6                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFisGet	:= {}

M410DicIni("SC6")
cDicCampo := M410RetCmp()
cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

While !M410DicEOF() .And. cDicArq == "SC6"

	cValid := Upper(GetSx3Cache(cDicCampo, "X3_VALID") + GetSx3Cache(cDicCampo, "X3_VLDUSER"))
	If 'MAFISGET("'$cValid
		nPosIni 	:= AT('MAFISGET("',cValid)+10
		nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
		cReferencia := Substr(cValid,nPosIni,nLen)
		aAdd(aFisGet,{cReferencia,cDicCampo,MaFisOrdem(cReferencia)})
	EndIf
	If 'MAFISREF("'$cValid
		nPosIni		:= AT('MAFISREF("',cValid) + 10
		cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
		aAdd(aFisGet,{cReferencia,cDicCampo,MaFisOrdem(cReferencia)})
	EndIf
	
	M410PrxDic()
	cDicCampo := M410RetCmp()
	cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

EndDo
aSort(aFisGet,,,{|x,y| x[3]<y[3]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca referencias no SC5                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFisGetSC5	:= {}

M410DicIni("SC5")
cDicCampo := M410RetCmp()
cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

While !M410DicEOF() .And. cDicArq == "SC5"
	
	cValid := Upper(GetSx3Cache(cDicCampo, "X3_VALID") + GetSx3Cache(cDicCampo, "X3_VLDUSER"))
	If 'MAFISGET("'$cValid
		nPosIni 	:= AT('MAFISGET("',cValid)+10
		nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
		cReferencia := Substr(cValid,nPosIni,nLen)
		aAdd(aFisGetSC5,{cReferencia,cDicCampo,MaFisOrdem(cReferencia)})
	EndIf
	If 'MAFISREF("'$cValid
		nPosIni		:= AT('MAFISREF("',cValid) + 10
		cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
		aAdd(aFisGetSC5,{cReferencia,cDicCampo,MaFisOrdem(cReferencia)})
	EndIf

	M410PrxDic()
	cDicCampo := M410RetCmp()
	cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

EndDo

aSort(aFisGetSC5,,,{|x,y| x[3]<y[3]})

SA4->(dbSetOrder(1))
If SA4->(dbSeek(xFilial("SA4")+M->C5_TRANSP)) 
	aTransp[01] := SA4->A4_EST
	If cPaisLoc == "BRA"	
		aTransp[02] := SA4->A4_TPTRANS
	Else
		aTransp[02] := ""
	EndIf
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
If len(aCols) > 0 .AND. cEstado == 'SP' .AND. !Empty(M->C5_CLIENT) .AND. M->C5_CLIENT <> M->C5_CLIENTE
	For nX := 1 To Len(aCols)
   		If Alltrim(aCols[nX][nPTES]) $ Alltrim(cTesVend)
 			lCfo:= .T.
 		EndIf
   	Next		   	
   	If lCfo		
		dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
		dbSetOrder(1)           
		MsSeek(xFilial()+M->C5_CLIENTE+M->C5_LOJAENT)
		cCliPed := If( Iif(M->C5_TIPO$"DB", SA2->A2_EST,SA1->A1_EST) == 'SP',;
		               M->C5_CLIENTE,;
					   M->C5_CLIENT)
	EndIf
EndIf

MaFisSave()
MaFisEnd()
aEval(aCols,{|x| nTotal += a410Arred( If(x[Len(x)],0,x[nPTotal]+(x[nPTotal]*M->C5_ACRSFIN/100)),"D2_TOTAL")})
nTotal+= (M->C5_FRETE+M->C5_DESPESA+M->C5_SEGURO)
MaFisIni(IIf(!Empty(cCliPed),cCliPed,Iif(Empty(M->C5_CLIENT),M->C5_CLIENTE,M->C5_CLIENT)),;// 1-Codigo Cliente/Fornecedor
	M->C5_LOJAENT,;		// 2-Loja do Cliente/Fornecedor
	IIf(M->C5_TIPO$'DB',"F","C"),;				// 3-C:Cliente , F:Fornecedor
	M->C5_TIPO,;				// 4-Tipo da NF
	M->C5_TIPOCLI,;		// 5-Tipo do Cliente/Fornecedor
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
	M->C5_NUM,;
	M->C5_CLIENTE,;
	M->C5_LOJACLI,;
	nTotal,;
	Nil,;
	M->C5_TPFRETE,;
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD2","D2_IDTRIB"), .F.),;
	Len(aCols),;
	.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza alteracoes de referencias do SC5         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aFisGetSC5) > 0
	dbSelectArea("SC5")
	For nY := 1 to Len(aFisGetSC5)
		If !Empty(&("M->"+Alltrim(aFisGetSC5[ny][2])))
			MaFisAlt(aFisGetSC5[ny][1],&("M->"+Alltrim(aFisGetSC5[ny][2])),,.F.)
		EndIf
	Next nY
Endif
IF cPaisLoc == "COL" .AND. SC5->(ColumnPos("C5_TPACTIV")) > 0
	MaFisLoad("NF_TPACTIV",AllTrim(M->C5_TPACTIV))
ENDIF
If SuperGetMV("MV_ISSXMUN",.F.,.F.)
	If !Empty(M->C5_MUNPRES)
		MaFisLoad("NF_CODMUN",AllTrim(M->C5_MUNPRES))
	EndIf
	
	If !Empty(M->C5_ESTPRES)
		MaFisLoad("NF_UFPREISS",AllTrim(M->C5_ESTPRES))
	EndIf
EndIf

//Na argentina o calculo de impostos depende da serie.
If cPaisLoc == 'ARG'
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+M->C5_LOJAENT))
	MaFisAlt('NF_SERIENF',LocXTipSer('SA1',MVNOTAFIS))
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Tratamento de IB para monotributistas - Argentina           ³
	³ AGIP 177/2009                                               ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If SA1->A1_TIPO == "M"
		dIni := (dDatabase + 1) - 365
		_nTotOper_ := RetTotOper(SA1->A1_COD,SA1->A1_LOJA,"C",dIni,dDatabase,1)
	Endif 
ElseIf cPaisLoc=="EQU"   
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+M->C5_LOJAENT))
	cNatureza:=SA1->A1_NATUREZ
	
	lPParc:=Posicione("SED",1,xFilial("SED")+cNatureza,"ED_RATRET")=="1"	
Endif

If cPaisLoc<>"BRA"
	MaFisAlt('NF_MOEDA',M->C5_MOEDA)
Else
	nMoeda := M->C5_MOEDA
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agrega os itens para a funcao fiscal         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPTotal > 0 .And. nPValDesc > 0 .And. nPPrUnit > 0 .And. nPProduto > 0 .And. nPQtdVen > 0 .And. nPTes > 0
	For nX := 1 To Len(aCols)
		nQtdPeso := 0
		cDocOri	 := ""
		cSerOri  := ""
			nItem++
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Tratamento de IB para monotributistas - Argentina           ³
			³ AGIP 177/2009                                               ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If cPaisLoc == "ARG" .AND. SA1->A1_TIPO == "M"
				aAdd(_aValItem_,{nItem,.F.,xmoeda(aCols[nX][nPPrcVen],SC5->C5_MOEDA ,1,)})
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona Registros                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lSaldo .And. nPItem > 0
				dbSelectArea("SC6")
				dbSetOrder(1)
				MsSeek(xFilial("SC6")+M->C5_NUM+aCols[nX][nPItem]+aCols[nX][nPProduto])
				nQtdEnt := IIf(!SubStr(SC6->C6_BLQ,1,1)$"RS" .And. Empty(SC6->C6_BLOQUEI),SC6->C6_QTDENT,SC6->C6_QTDVEN)
			Else
				lSaldo := .F.
			EndIf
			
			cProduto := aCols[nX][nPProduto]
			MatGrdPrRf(@cProduto)
			SB1->(dbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1")+cProduto))
				nQtdPeso := If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*SB1->B1_PESO
			EndIf
        	If nPIdentB6 <> 0 .And. !Empty(aCols[nX][nPIdentB6])
				SD1->(dbSetOrder(4))
				If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPIdentB6]))
					nRecOri := SD1->(Recno())
					cDocOri := SD1->D1_DOC
					cSerOri	:= SD1->D1_SERIE
				EndIf
        	ElseIf nPNfOri > 0 .And. nPSerOri > 0 .And. nPItemOri > 0
				If !Empty(aCols[nX][nPNfOri]) .And. !Empty(aCols[nX][nPItemOri])
					SD1->(dbSetOrder(1))
					If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPNfOri]+aCols[nX][nPSerOri]+M->C5_CLIENTE+M->C5_LOJACLI+aCols[nX][nPProduto]+aCols[nX][nPItemOri]))
						nRecOri := SD1->(Recno())
						cDocOri := SD1->D1_DOC
						cSerOri	:= SD1->D1_SERIE
					EndIf
				EndIf
			EndIf
            SB2->(dbSetOrder(1))
            SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD+aCols[nX][nPLocal]))
            SF4->(dbSetOrder(1))
            SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
            
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a TES Agrega Valor do ICMS ST           ³
			//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->F4_INCSOL<>"N"
			    lagrSolid := .T.
			EndIf
            
            IF SF4->(ColumnPos("F4_INDVF")) > 0 .And. nPNfOri > 0 .And. nPSerOri > 0
                 SD2->(dbSetOrder(3))
                 IF SD2->(MSSeek(xFilial("SD2")+aCols[nX][nPNfOri]+aCols[nX][nPSerOri]+M->C5_CLIENTE+M->C5_LOJACLI+aCols[nX][nPProduto]+aCols[nX][nPItemOri])) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
                     nRecOri := SD2->(Recno())
					 cDocOri := SD2->D2_DOC
					 cSerOri := SD2->D2_SERIE
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
			nAcresUnit:= A410Arred(aCols[nX][nPPrcVen]*M->C5_ACRSFIN/100,"D2_PRCVEN")
			nAcresFin := A410Arred(If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*nAcresUnit,"D2_TOTAL")
			nAcresTot += nAcresFin
			nValMerc  += nAcresFin
			If GetNewPar("MV_NDESCTP",.F.) .And. aCols[nX][nPValDesc] == 0 .And. nPrcLista > 0
				nPrcLista := A410Arred(nValMerc / If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]) ,"D2_TOTAL")
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
			If cPaisLoc == "ARG" .And. GetNewPar('MV_DESCSAI','1') == "2"  
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
				dDataCnd  := M->C5_EMISSAO
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento do IVA Ajustado                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			SB1->(dbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1")+cProduto))
               lIVAAju := IIf(cPaisLoc == "BRA", IIF(SB1->(SB1->B1_IVAAJU) == '1' .And. (IIF(lRastro,lRastroLot := ExecBlock("MAFISRASTRO",.F.,.F.),Rastro(cProduto,"S"))),.T.,.F.), .F.)			   
			EndIf
			dbSelectArea("SC6")
			dbSetOrder(1)
			MsSeek(xFilial("SC6")+M->C5_NUM)
			If lIVAAju
				dbSelectArea("SC9")
				dbSetOrder(1)
				If MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
					If ( SC9->C9_BLCRED $ "  10"  .And. SC9->C9_BLEST $ "  10")
						While ( !Eof() .And. SC9->C9_FILIAL == xFilial("SC9") .And.;
								SC9->C9_PEDIDO == SC6->C6_NUM .And.;
								SC9->C9_ITEM   == SC6->C6_ITEM )
				
							aAdd(aSaldos,{SC9->C9_LOTECTL,SC9->C9_NUMLOTE,,,SC9->C9_QTDLIB})	
		
							dbSelectArea("SC9")
							dbSkip()
						EndDo
					Else
						dbSelectArea("SC6")
						dbSetOrder(1)
						MsSeek(xFilial("SC6")+M->C5_NUM)
						lUsaVenc:= If(!Empty(SC6->C6_LOTECTL+SC6->C6_NUMLOTE),.T.,(SuperGetMv('MV_LOTVENC')=='S'))
						aSaldos := SldPorLote(aCols[nX][nPProduto],aCols[nX][nPLocal],aCols[nX][nPQtdVen]/* nQtdLib*/,0/*nQtdLib2*/,SC6->C6_LOTECTL,SC6->C6_NUMLOTE,SC6->C6_LOCALIZ,SC6->C6_NUMSERI,NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)					
					EndIf
				Else
					dbSelectArea("SC6")
					dbSetOrder(1)
					MsSeek(xFilial("SC6")+M->C5_NUM)
					lUsaVenc:= If(!Empty(SC6->C6_LOTECTL+SC6->C6_NUMLOTE),.T.,(SuperGetMv('MV_LOTVENC')=='S'))
					aSaldos := SldPorLote(aCols[nX][nPProduto],aCols[nX][nPLocal],aCols[nX][nPQtdVen]/* nQtdLib*/,0/*nQtdLib2*/,SC6->C6_LOTECTL,SC6->C6_NUMLOTE,SC6->C6_LOCALIZ,SC6->C6_NUMSERI,NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)									
				EndIf
				For nX1 := 1 to Len(aSaldos)
					nPropLot := aSaldos[nX1][5]
					dbSelectArea("SB8")
					If lRastroLot
						dbSetOrder(5)
						If MsSeek(xFilial("SB8")+cProduto+aSaldos[nX][01])
							aAdd(aInfLote,{SB8->B8_DOC,SB8->B8_SERIE,SB8->B8_CLIFOR,SB8->B8_LOJA,nPropLot})
						EndIf		
					Else				
						dbSetOrder(2)
						If MsSeek(xFilial("SB8")+aSaldos[nX][02]+aSaldos[nX][01])
							aAdd(aInfLote,{SB8->B8_DOC,SB8->B8_SERIE,SB8->B8_CLIFOR,SB8->B8_LOJA,nPropLot})
						EndIf
					EndIf
					dbSelectArea("SF3")
					dbSetOrder(4)
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
			MaFisIniLoad(nItem,{	cProduto,;														//IT_PRODUTO
									aCols[nX][nPTES],; 												//IT_TES
									"",; 															//IT_CODISS
									If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]),;	//IT_QUANT
									cDocOri,; 														//IT_NFORI
									cSerOri,; 														//IT_SERIORI
									SB1->(RecNo()),;												//IT_RECNOSB1
									SF4->(RecNo()),;												//IT_RECNOSF4
									nRecOri ,; 														//IT_RECORI
									aCols[nX,nPLote],;												//IT_LOTE
									aCols[nX,nPSubLot],;   											//IT_SUBLOTE
									"",;                											//IT_PRDFIS
									0,;                 											//IT_RECPRDF
									IIf(nPTpOper>0,aCols[nX,nPTpOper],"")})	    					//IT_TPOPER
						
			MaFisLoad("IT_DESCONTO" , nDesconto, nItem)
			MaFisLoad("IT_ABVLISS"  , IIF(nPAbatISS>0, aCols[nX,nPAbatISS], 0), nItem)
			MaFisLoad("IT_CLASFIS"  , Iif(Len(Alltrim(aCols[nX,nPClasFis])) == 3 , aCols[nX,nPClasFis], ""), nItem)
			
			// Codigo Retencao - Equador
			If (cPaisLoc=="EQU")
				MaFisLoad("IT_CONCEPT" , aCols[nX,nPCodRet], nItem)
			EndIf
			
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
			//³Provincia de entrega - Ingresos Brutos       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "ARG" .AND. nPProvEnt > 0
				MaFisAlt("IT_PROVENT",aCols[nX,nPProVent],nItem)
			Endif


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera peso para calcular frete              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotPeso += nQtdPeso
			MaFisLoad("IT_PESO",nQtdPeso,nItem)
			MaFisLoad("IT_PRCUNI",nPrcLista,nItem)
			MaFisLoad("IT_VALMERC",nValMerc,nItem)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o valor do campo C6_IPITRF			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPIPITrf > 0 .And. Acols[nX][nPIPITrf] > 0
				nValIpiTrf := Acols[nX][nPIPITrf]
			 	MaFisLoad("IT_PRCCF",nValIpiTrf,nItem)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//Calculo de aposentadoria Especial REINF  ³
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			If ChkFile("AIS")
			
				nPItSC6    := aScan(aHeader,{|x|AllTrim(x[2]) == 'C6_ITEM'})
				
				If !Empty(MaFisScan("IT_SECP15",.F.)) .AND.;	//Verifica existencia das Referencias Fiscais de Ap. Especial
				   (TYPE('aHeaderAIS') <> 'U' .and. TYPE('aColsAIS') <> 'U')

					If nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5 .Or. IsInCallStack("A410COPIA") 	
						aSize(aAIS,0) 
							
						AIS->(dbSetOrder(1))
						If AIS->(DbSeek(xFilial("AIS") + M->C5_NUM + aCols[nX][nPItem]))
							While AIS->(!Eof()) .and. AIS->AIS_FILIAL == xFilial("AIS")	;
												.and. AIS->AIS_PEDIDO == M->C5_NUM
					
								nACols := aScan(aCols,{|x   | x[nPItSC6] == AIS->AIS_ITEMPV})	
					
								If !aCols[nACols][Len(aHeader) + 1] //Verifica se o ítem do pedido ao qual se refere a linha da aposentadoria especial não está deletada
									AADD(aAIS,{AIS->AIS_FILIAL, AIS->AIS_PEDIDO, AIS->AIS_ITEMPV})
								EndIf
								nACols := 0
								
								AIS->(DbSkip())
							EndDo
						EndIf	
 
						If Empty(aHeaderAIS) .AND. !Empty(aAIS)
							M410DicIni("AIS")
							cDicCampo := M410RetCmp()
							cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

							While !M410DicEOF() .And. (cDicArq == "AIS")

								cDicUsado   := GetSX3Cache(cDicCampo, "X3_USADO")
								cDicNivel   := GetSX3Cache(cDicCampo, "X3_NIVEL")

								If X3USO(cDicUsado) .AND. cNivel >= cDicNivel 

									cDicTitulo  := M410DicTit(cDicCampo)
									cDicPictur  := X3Picture(cDicCampo)
									nDicTam     := GetSX3Cache(cDicCampo, "X3_TAMANHO")
									nDicDec     := GetSX3Cache(cDicCampo, "X3_DECIMAL")
									cDicValid   := GetSX3Cache(cDicCampo, "X3_VALID")
									cDicTipo    := GetSX3Cache(cDicCampo, "X3_TIPO")
									cDicF3      := GetSX3Cache(cDicCampo, "X3_F3")
									cDicContex  := GetSX3Cache(cDicCampo, "X3_CONTEXT")
											
									aAdd(aHeaderAIS,{ TRIM(cDicTitulo)	,;
														cDicCampo	,;
														cDicPictur 	,;
														nDicTam	,;
														nDicDec	,;
														cDicValid	,;
														cDicUsado	,;
														cDicTipo	,;
														cDicF3		,;
														cDicContex } )

								EndIf

								M410PrxDic()
								cDicCampo := M410RetCmp()
								cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))
							EndDo
  						EndIf
  							 
						AIS->(dbSetOrder(1))
						For nAis := 01 To Len(aAIS)
							If AIS->(DbSeek(xFilial("AIS") + M->C5_NUM + aAIS[nAis][03])) .AND.;
							   aScan(aColsAIS, {|aVal| aVal[1] == StrZero(Val(aAis[nAis][03]),TamSx3('AIS_ITEMPV')[1])}) == 0

								aAdd(aColsAIS,{AIS->AIS_ITEMPV,{Array(Len(aHeaderAIS)+1)}})
								For nLinINS := 1 To Len(aHeaderAIS)
									If aHeaderAIS[nLinINS][10] <> "V"
										aColsAIS[Len(aColsAIS)][2][Len(aColsAIS[01][2])][nLinINS] := AIS->(FieldGet(ColumnPos(aHeaderAIS[nLinINS][2])))
									EndIf
								Next nLinINS
								aColsAIS[Len(aColsAIS)][2][Len(aColsAIS[01][2])][Len(aHeaderAIS)+1] := .F.
							EndIf
						Next nAis	
					
					EndIf
 	  				
					nPosItem := aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_ITEMPV"} )
					nPosIt15 := aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_15ANOS"} )
					nPosIt20 := aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_20ANOS"} )
					nPosIt25 := aScan(aHeaderAIS,{|x| AllTrim(x[2]) == "AIS_25ANOS"} )

					For nLinINS := 01 To Len(aColsAIS)
						nACols := aScan(aCols,{|x|x[nPItSC6] == aColsAIS[nLinINS][nPosItem]})				
						If !aCols[nACols][Len(aHeader) + 1] //Verifica se o ítem do pedido ao qual se refere a linha da aposentadoria especial não está deletada
							MaFisLoad("IT_SECP15", aColsAIS[nLinINS][02][01][nPosIt15], nACols) 
							MaFisLoad("IT_SECP20", aColsAIS[nLinINS][02][01][nPosIt20], nACols)
							MaFisLoad("IT_SECP25", aColsAIS[nLinINS][02][01][nPosIt25], nACols)
 						EndIf
						nACols := 0
					Next nLinINS
				EndIf	
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza alteracoes de referencias do SC6         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aFisGet) > 0 .And. !ExistTemplate("M460ICM")
				If Len(aCols[nX])==nUsado .Or. !aCols[nX][Len(aHeader)+1]
					For nY := 1 to Len(aFisGet)
						nPosCpo := aScan(aHeader,{|x| AllTrim(x[2])==Alltrim(aFisGet[ny][2])})
						If nPosCpo > 0 .AND. !Empty(aCols[nX][nPosCpo])
							MaFisLoad(aFisGet[ny][1],aCols[nX][nPosCpo],nX)
						EndIf
					Next nY
				Endif
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
					If cPaisLoc=="BRA"
						aRentab[nY][2] += (nValMerc - nDesconto)
						If nMoeda == 1
							nCusto := SB2->B2_CM1
						ElseIf nMoeda == 2
							nCusto := SB2->B2_CM2
						ElseIf nMoeda == 3
							nCusto := SB2->B2_CM3
						ElseIf nMoeda == 4
							nCusto := SB2->B2_CM4
						ElseIf nMoeda == 5
							nCusto := SB2->B2_CM5
						EndIf
						aRentab[nY][3] += If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*nCusto
					Else
						aRentab[nY][2] += nValMerc
						aRentab[nY][3] += If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*SB2->B2_CM1
					Endif
				EndIf	
			Else
				If GetNewPar("MV_TPDPIND","1")=="1"
					nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
				EndIf
			EndIf
			
			MaFisRecal("",nItem)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Código do Servico                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				If nPCodIss > 0 .And. !Empty(aCols[nX,nPCodIss]) .And. MaFisRet(nItem,"IT_CODISS") <> aCols[nX,nPCodIss]
					MaFisAlt("IT_CODISS",aCols[nX,nPCodIss],nItem,.T.)
				EndIf
			EndIf
			
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calculo do ISS                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->F4_ISS=="S" .AND.  M->C5_TIPO == "N" .AND. nPAliqISS > 0 .And. !Empty(aCols[nX,nPAliqISS]) .And. MaFisRet(nItem,"IT_ALIQISS") <> aCols[nX,nPAliqISS]
				MaFisAlt("IT_ALIQISS",aCols[nX,nPAliqISS],nItem,.T.)
			EndIf
			If ( M->C5_INCISS == "N" .And. M->C5_TIPO == "N") .AND. ( SF4->F4_ISS=="S" )
				nAliqISS := MaAliqISS(nItem)
				nVMercAux := nValMerc
				nPrcLsAux := nPrcLista
				nPrcLista := a410Arred(nPrcLista/(1-(nAliqISS/100)),"D2_PRCVEN")
				If lRndIss
					//Quando configurado para arredondar ISS é nescessario calcular ISS por item
					//conforme ja realizado na funçao MaPvPrcIt (MATA461)
					nValMerc  := a410Arred(nValMerc / aCols[nX][nPQtdVen]/(1-(nAliqISS/100))) * aCols[nX][nPQtdVen]
					nValMerc  := a410Arred(nValMerc,"D2_PRCVEN")
				Else
					nValMerc  := nValMerc/(1-(nAliqISS/100))
				Endif

				MaFisLoad("IT_PRCUNI",nPrcLista,nItem)
				MaFisLoad("IT_VALMERC",nValMerc,nItem)

				MafisRecal('',nItem)

			EndIf

			//Processar após o MaFisRecal
			//Acumula ISS abaixo do minimo portanto nao descontou do total do titulo.
			If (MaFisRet(,"NF_RECISS")=="1" .And. lDescISS .And. lTpAbISS) .And.;
				!(SF4->F4_FRETISS == "2" .And. SA1->A1_FRETISS == "2")
				nValISS := MaFisRet(nItem,'IT_VALISS')
				If nValISS <= nVRetISS
					nISSNDesc += nValISS
				EndIf
			EndIf
			
			// Tratamento para execução do cálculo de impostos quando houver o tributo TPDP-PB
			If (MaFisRet(nItem,"IT_VALTPDP") > 0)
				MaFisEndLoad(nItem,1)
			Else
				MaFisEndLoad(nItem,2)
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
                VALORIPI    := MaFisRet(nItem,"IT_VALIPI")
                VALORDESP    := MaFisRet(nItem,"IT_DESPESA")
                VALORSEG    := MaFisRet(nItem,"IT_SEGURO")
				aSolidTmp := ExecTemplate("M460SOLI",.F.,.F.,{aCols[nX],aHeader})
				If ValType(aSolidTmp) == "A"
					aSolid := aClone(aSolidTmp)
				EndIf
				If Len(aSolid) >= 5                                  			
					MaFisLoad("IT_BASESOL",NoRound(aSolid[1],2),nItem) 
					MaFisLoad("IT_VALSOL" ,NoRound(aSolid[2],2),nItem)
					MaFisLoad("IT_ALIQSOL" ,NoRound(aSolid[3],2),nItem)
					MaFisLoad("IT_VFECPST" ,NoRound(aSolid[4],2),nItem)
					MaFisLoad("IT_ALFCST" ,NoRound(aSolid[5],2),nItem)
					If Len(aSolid) >= 7
						MaFisLoad("IT_MARGEM" ,NoRound(aSolid[6],2),nItem)
						MaFisLoad("IT_PAUTST" ,NoRound(aSolid[7],2),nItem)
                        If Len(aSolid) >= 8
                            MaFisLoad("IT_BSFCPST" ,NoRound(aSolid[8],2),nItem)
                        EndIf
					EndIF
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
If ( ( cPaisLoc == "PER" .Or. cPaisLoc == "COL" ) .And. M->C5_TPFRETE == "F" ) .Or. ( cPaisLoc != "PER" .And. cPaisLoc != "COL" )
	MaFisAlt("NF_PESO",nTotPeso)
	MaFisAlt("NF_FRETE",M->C5_FRETE)
EndIf
MaFisAlt("NF_VLR_FRT",M->C5_VLR_FRT)
MaFisAlt("NF_SEGURO",M->C5_SEGURO)
MaFisAlt("NF_AUTONOMO",M->C5_FRETAUT)
MaFisAlt("NF_DESPESA",M->C5_DESPESA)                 
If cPaisLoc == "PTG"
	MaFisAlt("NF_DESNTRB",M->C5_DESNTRB)
	MaFisAlt("NF_TARA",M->C5_TARA)	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indenizacao por valor                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->C5_PDESCAB > 0
	MaFisAlt("NF_DESCONTO",nPDesCab:=A410Arred((MaFisRet(,"NF_VALMERC")-nTotDesc)*M->C5_PDESCAB/100,"C6_VALOR")+MaFisRet(,"NF_DESCONTO"))
EndIf

If M->C5_DESCONT > 0
	MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC"),nPDesCab+nTotDesc+M->C5_DESCONT),/*nItem*/,/*lNoCabec*/,/*nItemNao*/,GetNewPar("MV_TPDPIND","1")=="2" )
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
			MaFisLoad("IT_FRETE"  ,BASEIPIFRETE,nItem)
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

//Corrige desconto devido ISS do item ter ficado menor que limite mas total de ISS ficou maior.
If nISSNDesc > 0
	nValISS := MaFisRet(,"NF_VALISS")
	If nValISS > nVRetISS
		nTotTit := MaFisRet(,"NF_BASEDUP")
		MaFisAlt("NF_BASEDUP",nTotTit-nISSNDesc)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza alteracoes de referencias do SC5 Suframa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPSuframa:=aScan(aFisGetSC5,{|x| x[1] == "NF_SUFRAMA"})
If !Empty(nPSuframa)
	dbSelectArea("SC5")
	If !Empty(&("M->"+Alltrim(aFisGetSC5[nPSuframa][2])))
		MaFisAlt(aFisGetSC5[nPSuframa][1],Iif(&("M->"+Alltrim(aFisGetSC5[nPSuframa][2])) == "1",.T.,.F.),nItem,.F.)
	EndIf
Endif

// MV_FISFRAS: Indica se utiliza rastreabilidade para obtencao dos dados que necessitam desta funcionalidade. 
// MV_FISAUCF: Utiliza a origem do documento original (para produtos com rastreabilidade) para efetuar os calculos.
// Mesmo tratamento feito no MATA461 - Soh alterar se nao preencher o cod FCI na SC6.
If (lMvFisFras .And. lMvFISAUCF) .Or. lOrigLote
	For nX := 1 To Len(aCols)
		If (Empty(Iif(nPFciCod > 0, aCols[nX][nPFciCod], "")) .And. Rastro(aCols[nX][nPProduto]) .And. (!Empty(aCols[nX][nPSubLot]) .Or. !Empty(aCols[nX][nPLote])) )
			cCodOrig := ""
			cOrigem  := ""
			If lMvFisFras .And. lMvFISAUCF
				// Carrega origem da NF de entrada (FCI)
				SpedRastro2(aCols[nX][nPSubLot],aCols[nX][nPLote],aCols[nX][nPProduto],,0,.T.,,,,,,@cCodOrig)	
				If !Empty(cCodOrig)
					MaFisAlt("IT_CLASFIS",cCodOrig + Substr(aCols[nX][nPClasFis],2),nX,.T.)
				EndIf
			EndIf
			If lOrigLote 
				cOrigem := OrigemLote(aCols[nX][nPProduto],aCols[nX][nPLote],aCols[nX][nPSubLot])		
				If !Empty(cOrigem) .And. cOrigem <> cCodOrig
					MaFisAlt("IT_CLASFIS",cOrigem + Substr(aCols[nX][nPClasFis],2),nX,.T.)
				EndIf
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
	lCondVenda := ExecTemplate("GMCondPagto",.F.,.F.,{M->C5_CONDPAG,} )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula os venctos conforme a condicao de pagto  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !M->C5_TIPO == "B"
	If lDtEmi
		dbSelectarea("SE4")
		dbSetOrder(1)
		MsSeek(xFilial("SE4")+M->C5_CONDPAG)
		If (Type("INCLUI") <> "U" .AND. Type("ALTERA") <> "U")
			lContinua := !(INCLUI.OR.ALTERA)
		EndIf

		If (SE4->E4_TIPO=="9".AND.(lContinua .OR. lRent)) .OR. SE4->E4_TIPO<>"9"
		
			If cPaisLoc == 'COL' .AND. SFB->FB_JNS == 'J' 
			    dbSelectArea("SFC")
				dbSetOrder(2)
				If dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RV0" )
					nValRetImp 	:= MaFisRet(,"NF_VALIV2")
					Do Case
						Case FC_INCDUPL == '1'
							nlValor := MaFisRet(,"NF_BASEDUP") - nValRetImp
						Case FC_INCDUPL == '2'
							nlValor :=MaFisRet(,"NF_BASEDUP") + nValRetImp
						Otherwise
							nlValor :=MaFisRet(,"NF_BASEDUP")
					EndCase
				Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RF0" )
					nValRetImp 	:= MaFisRet(,"NF_VALIV4")
					Do Case
						Case FC_INCDUPL == '1'
							nlValor := MaFisRet(,"NF_BASEDUP") - nValRetImp
						Case FC_INCDUPL == '2'
							nlValor :=MaFisRet(,"NF_BASEDUP") + nValRetImp
						Otherwise
							nlValor :=MaFisRet(,"NF_BASEDUP")
					EndCase
				Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RC0" )
					nValRetImp 	:= MaFisRet(,"NF_VALIV7")
					Do Case
						Case FC_INCDUPL == '1'
							nlValor := MaFisRet(,"NF_BASEDUP") - nValRetImp
						Case FC_INCDUPL == '2'
							nlValor :=MaFisRet(,"NF_BASEDUP") + nValRetImp
						Otherwise
							nlValor :=MaFisRet(,"NF_BASEDUP")
					EndCase
				Endif
			Else
				nlValor := MaFisRet(,"NF_BASEDUP")
			EndIf				 
		    aDupl := Condicao(nlValor,M->C5_CONDPAG,MaFisRet(,"NF_VALIPI"),dDataCnd,Iif(lagrSolid,MaFisRet(,"NF_VALSOL"),0),,,nAcresTot)
			lagrSolid := .F.
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
			If (Len(aCols[nX])==nUsado .Or. !aCols[nX][nUsado+1]) .AND. nPDtEntr > 0
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
	    Next
		dbSelectarea("SE4")
		dbSetOrder(1)
		MsSeek(xFilial("SE4")+M->C5_CONDPAG)
		If !(SE4->E4_TIPO=="9")
			For nY := 1 to Len(aEntr)
				nAcerto  := 0
				
				If cPaisLoc == 'COL' .AND. SFB->FB_JNS $ 'J/S'
				    
				    dbSelectArea("SFC")
					dbSetOrder(2)
					If dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RV0" )
						nValRetImp 	:= MaFisRet(,"NF_VALIV2")
						Do Case
							Case FC_INCDUPL == '1'
								nlValor := aEntr[nY][2] - nValRetImp
							Case FC_INCDUPL == '2'
								nlValor :=aEntr[nY][2] + nValRetImp
							Otherwise
								nlValor :=aEntr[nY][2]
						EndCase
					Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RF0" )
						nValRetImp 	:= MaFisRet(,"NF_VALIV4")
						Do Case
							Case FC_INCDUPL == '1'
								nlValor := aEntr[nY][2] - nValRetImp
							Case FC_INCDUPL == '2'
								nlValor :=aEntr[nY][2] + nValRetImp
							Otherwise
								nlValor :=aEntr[nY][2]
						EndCase
					Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RC0" )
						nValRetImp 	:= MaFisRet(,"NF_VALIV7")
						Do Case
							Case FC_INCDUPL == '1'
								nlValor := aEntr[nY][2] - nValRetImp
							Case FC_INCDUPL == '2'
								nlValor :=aEntr[nY][2] + nValRetImp
							Otherwise
								nlValor :=aEntr[nY][2]
						EndCase
					Endif
				ElseIf cPaisLoc=="EQU" .And. lPParc
					DbSelectArea("SFC")
					SFC->(dbSetOrder(2))
					If DbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RIR") //Retenção IVA
						cImpRet		:= SFC->FC_IMPOSTO
						DbSelectArea("SFB")
						SFB->(dbSetOrder(1))
						If SFB->(DbSeek(xFilial("SFB")+AvKey(cImpRet,"FB_CODIGO")))
							nValRetImp 	:= MaFisRet(,"NF_VALIV"+SFB->FB_CPOLVRO)
					    Endif       
					    DbSelectArea("SFC")
						If SFC->FC_INCDUPL == '1'
							nlValor	:=aEntr[nY][2] - nValRetImp				
						ElseIf SFC->FC_INCDUPL == '2'
							nlValor :=aEntr[nY][2] + nValRetImp
						EndIf   
				    Endif
				Else
					nlValor := aEntr[nY][2]
				EndIf
				
				aDuplTmp := Condicao(nlValor,M->C5_CONDPAG,aEntr[nY][3],aEntr[nY][1],aEntr[nY][4],,,nAcresTot)
				If Len(aDuplTmp) > 0
					If ! lCondVenda
						If cPaisLoc=="EQU"
							For nX := 1 To Len(aDuplTmp)
								If nX==1                            
									If SFC->FC_INCDUPL == '1'
										aDuplTmp[nX][2]+= nValRetImp
									ElseIf SFC->FC_INCDUPL == '2'
										aDuplTmp[nX][2]-= nValRetImp
									Endif										
								Endif	
							Next nX
						Else
							For nX := 1 To Len(aDuplTmp)
								nAcerto += aDuplTmp[nX][2]
							Next nX
							aDuplTmp[Len(aDuplTmp)][2] += aEntr[nY][2] - nAcerto
						Endif
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
		aVencto := ExecBlock("GMMA410Dupl",.F.,.F.,{M->C5_NUM ,M->C5_CONDPAG,dDataCnd,,MaFisRet(,"NF_BASEDUP") ,aVencto}, .F., .F.) 
	ElseIf ExistTemplate("GMMA410Dupl")
		aVencto := ExecTemplate("GMMA410Dupl",.F.,.F.,{M->C5_NUM ,M->C5_CONDPAG,dDataCnd,,MaFisRet(,"NF_BASEDUP") ,aVencto}) 
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
aRentabil := a410RentPV( aCols ,nUsado ,@aRenTab ,@aVencto ,nPTES,nPProduto,nPLocal,nPQtdVen, M->C5_EMISSAO,nMoeda )

If cPaisLoc=="BRA" 
	aAdd(aTitles,STR0114)	//"Lançamentos da Apuração de ICMS"
	nLancAp	:=	Len(aTitles)
	If lAliasCIP .AND. M->C5_TIPO == 'I'
		aAdd(aTitles,STR0376)	//"Complemento de Tributos"
		nComplem	:=	Len(aTitles)
	EndIf 
EndIf

//lRetTotal quando .T. não exibe a planilha mas retorna o NF_TOTAL de MafisRet
If lApiTrib

    aJSon := MaFisRodape(1,Nil,,,Nil,.T.,,,,,,,,,,,,,,,.T.)
    nDetImp := Len(aJson) //Linhas do detalhamento de impostos

    oImpostos := JsonObject():New()
    oImpostos["valor_contabil"]      			:= MaFisRet(,"NF_TOTAL")
    oImpostos["valor_mercadoria"]    			:= MaFisRet(,"NF_VALMERC")
	oImpostos["total_impostos_embutidos"]		:= MaFisRet(,"NF_VALICM") + MaFisRet(,"NF_VALCOF") + MaFisRet(,"NF_VALCF2") + MaFisRet(,"NF_VALPIS") + MaFisRet(,"NF_VALPS2") + MaFisRet(,"NF_VALCSL") + MaFisRet(,"NF_VALISS")
	oImpostos["total_impostos_sem_incidencia"]  := MaFisRet(,"NF_VALIPI") + MaFisRet(,"NF_VALSOL") 
	oImpostos["total_impostos"]                 := 0
	oImpostos["TaxesDetail"]					:= {}
	oImpostos["itens"]							:= {}
    oImpostos["desconto"]   					:= MaFisRet(,"NF_DESCONTO")
    oImpostos["base_duplicada"] 				:= MaFisRet(,"NF_BASEDUP")
    oImpostos["seguro"]     					:= MaFisRet(,"NF_SEGURO")
    oImpostos["frete"]      					:= MaFisRet(,"NF_FRETE")
    oImpostos["despesas_acessorias"]    		:= MaFisRet(,"NF_DESPESA")

    For nX := 1 To nDetImp
        oImpDet := JsonObject():New()
        oImpDet["imposto"]      := aJson[nX,1]
        oImpDet["descricao"]    := aJson[nX,2]
        oImpDet["base_calculo"] := aJson[nX,3]
        oImpDet["aliquota"]     := aJson[nX,4]
        oImpDet["valor"]        := aJson[nX,5]

		nImpTot += aJson[nX,5]

        aAdd( oImpostos["TaxesDetail"], oImpDet )
    Next nX

	oImpostos["total_impostos"] := nImpTot

    IF (nItens := MaFisRet(,"NF_QTDITENS")) > 0

        For nX := 1 To nItens   
            oItens := JsonObject():New()
            oItens["produto"]   := {}

            oItemDet := JsonObject():New()
            oItemDet["valor_mercadoria"] 	:= MaFisRet(nX,'IT_VALMERC')
            oItemDet["valor_st"]	     	:= MaFisRet(nX,'IT_VALSOL')
            oItemDet["valor_total"]      	:= MaFisRet(nX,'IT_TOTAL')
            oItemDet["seguro"]		     	:= MaFisRet(nX,'IT_SEGURO')
            oItemDet["valor_csll"]       	:= MaFisRet(nX,'IT_VALCSL')
            oItemDet["valor_unitario"]   	:= MaFisRet(nX,'IT_PRCUNI')
            oItemDet["quantidade"]       	:= MaFisRet(nX,'IT_QUANT')
            oItemDet["aliquota_pis"]     	:= MaFisRet(nX,'IT_ALIQPIS')
            oItemDet["aliquota_ipi"]     	:= MaFisRet(nX,'IT_ALIQIPI')
            oItemDet["valor_pis"]        	:= MaFisRet(nX,'IT_VALPIS') 	// Valor do PIS retido
			oItemDet['valor_pis_apur']		:= MaFisRet(nX,'IT_VALPS2') 	// Valor do PIS via apuração
			oItemDet['valor_pis_st']		:= MaFIsRet(nX,'IT_VALPS3')		// Valor do PIS Subst. Tributaria
            oItemDet["aliquota_cofins"]  	:= MaFisRet(nX,'IT_ALIQCOF')
            oItemDet["valor_cofins"]     	:= MaFisRet(nX,'IT_VALCOF')		// Valor da COFINS retida
			oItemDet["valor_cofins_apur"]	:= MaFisRet(nX,'IT_VALCF2')		// Valor da COFINS via apuração
			oItemDet["valor_cofins_st"]		:= MaFisRet(nX,'IT_VALCF3')		// Valor da COFINS Subst. Tributaria
            oItemDet["aliquota_st"]      	:= MaFisRet(nX,'IT_ALIQSOL')
            oItemDet["aliquota_icms"]    	:= MaFisRet(nX,'IT_ALIQICM')
            oItemDet["frete"]	         	:= MaFisRet(nX,'IT_FRETE')
            oItemDet["codigo_produto"]   	:= MaFisRet(nX,'IT_PRODUTO')
            oItemDet["aliquota_csll"]    	:= MaFisRet(nX,'IT_ALIQCSL')
            oItemDet["valor_icms"]       	:= MaFisRet(nX,'IT_VALICM')
            oItemDet["valor_ipi"]        	:= MaFisRet(nX,'IT_VALIPI')
            oItemDet["desconto"]	     	:= MaFisRet(nX,'IT_DESCONTO')
            oItemDet["despesas_acessorias"] := MaFisRet(nX,'IT_DESPESA')
            oItemDet["tes"]		           	:= MaFisRet(nX,'IT_TES')

            oItens["produto"] :=  oItemDet 
            aAdd( oImpostos["itens"], oItens )
        Next nX
    Endif

	oAPIManager:SetJson(.F.,{oImpostos})
	
    //Limpa objetos e array
    FreeObj(oImpostos)
    FreeObj(oItemDet)
    FreeObj(oItens)
    FreeObj(oImpDet)
    FwFreeArray(aJson)
	
ElseIf lRetTotal
	nValTotal := MaFisRet(,"NF_TOTAL")
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a tela de exibicao dos valores fiscais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0043) FROM 09,00 TO 28,80 //"Planilha Financeira"
	oFolder := TFolder():New(001,001,aTitles,{"HEADER"},oDlg,,,, .T., .F.,315,140)
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
		@ 110,005 SAY OemToAnsi(STR0048)   SIZE 40,10 PIXEL OF oFolder:aDialogs[1] //"Total da Nota"
		@ 110,050 MSGET MaFisRet(,"NF_TOTAL")      PICTURE Iif(cPaisLoc $ "CHI|PAR" .And. M->C5_MOEDA == 1,TM(0,16,NIL),PesqPict("SF2","F2_VALBRUT",16,2))                   	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 109,270 BUTTON OemToAnsi(STR0049)			SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[1] PIXEL		//"Sair"
	Else 
		@ 070,005 SAY RetTitle("F2_DESCONT")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 070,105 SAY RetTitle("F2_FRETE")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 070,205 SAY RetTitle("F2_SEGURO")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 085,005 SAY RetTitle("F2_DESPESA")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 085,105 SAY RetTitle("F2_DESNTRB")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 085,205 SAY RetTitle("F2_TARA")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 110,005 SAY RetTitle("F2_VALFAT")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 070,050 MSGET MaFisRet(,"NF_DESCONTO")	PICTURE PesqPict("SF2","F2_DESCONTO",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 070,150 MSGET MaFisRet(,"NF_FRETE")		PICTURE PesqPict("SF2","F2_FRETE",16,2)		SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 070,250 MSGET MaFisRet(,"NF_SEGURO")  	PICTURE PesqPict("SF2","F2_SEGURO",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 085,050 MSGET MaFisRet(,"NF_DESPESA")		PICTURE PesqPict("SF2","F2_DESPESA",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 085,150 MSGET MaFisRet(,"NF_DESNTRB")		PICTURE PesqPict("SF2","F2_DESNTRB",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 085,250 MSGET MaFisRet(,"NF_TARA")		PICTURE PesqPict("SF2","F2_TARA",16,2)		SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 110,050 MSGET MaFisRet(,"NF_BASEDUP")		PICTURE PesqPict("SF2","F2_VALFAT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 105,005 TO 106,310 PIXEL OF oFolder:aDialogs[1]
		@ 110,105 SAY OemToAnsi(STR0048)   SIZE 40,10 PIXEL OF oFolder:aDialogs[1] //"Total da Nota"
		@ 110,150 MSGET MaFisRet(,"NF_TOTAL")      PICTURE Iif(cPaisLoc $ "CHI|PAR" .And. M->C5_MOEDA == 1,TM(0,16,NIL),PesqPict("SF2","F2_VALBRUT",16,2))                   	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 109,270 BUTTON OemToAnsi(STR0049)			SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[1] PIXEL		//"Sair"
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Folder 2                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                                                      
	If lDtEmi
		@ 005,001 LISTBOX oDupl FIELDS TITLE aFlHead[1],aFlHead[2] SIZE 310,095 	OF oFolder:aDialogs[2] PIXEL
	Else	
		@ 005,001 LISTBOX oDupl FIELDS TITLE aFlHead[3],aFlHead[1],aFlHead[2] SIZE 310,095 	OF oFolder:aDialogs[2] PIXEL
	Endif	
	oDupl:SetArray(aDupl)
	oDupl:bLine := {|| aDupl[oDupl:nAt] }
	@ 105,005 TO 106,310 PIXEL OF oFolder:aDialogs[2]
	If cPaisLoc == "BRA"
		@ 110,005 SAY RetTitle("F2_VALFAT")		SIZE 40,10 PIXEL OF oFolder:aDialogs[2]
	Else
		@ 110,005 SAY OemToAnsi(STR0051)	    SIZE 40,10 PIXEL OF oFolder:aDialogs[2]
	Endif	
	@ 110,050 MSGET MaFisRet(,"NF_BASEDUP")		PICTURE PesqPict("SF2","F2_VALFAT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[2]
	
	//
	// Template GEM - Gestao de empreendimentos imobiliarios
	// Manutencao dos itens da condicao de venda 
	//
	If ExistBlock("GMMA410CVND",,.T.)
		If ExistBlock("GMMA410Dupl")
			@ 110,170 BUTTON OemToAnsi("Cond. de Venda") SIZE 050,11 FONT oFolder:aDialogs[1]:oFont ;
			          ACTION ( ExecBlock("GMMA410CVND",.F.,.F.,{nOpc ,M->C5_NUM ,M->C5_CONDPAG ,dDataCnd ,MaFisRet(,"NF_BASEDUP")}) ;
			                  ,aVencto := ExecBlock("GMMA410Dupl",.F.,.F.,{M->C5_NUM ,M->C5_CONDPAG,dDataCnd,,MaFisRet(,"NF_BASEDUP"),aVencto}) ;
			                  ,( aDupl := {} ,aEval(aVencto ,{|aTitulo| aAdd( aDupl ,{transform(aTitulo[1],x3Picture("E1_VENCTO")) ,transform(aTitulo[2],x3Picture("E1_VALOR"))})}) ;
			                  ,aRentabil := a410RentPV( aCols ,nUsado ,@aRenTab ,@aVencto ,nPTES,nPProduto,nPLocal,nPQtdVen, M->C5_EMISSAO ) );
			                  ,(oDupl:SetArray(aDupl),	oDupl:bLine := {|| aDupl[oDupl:nAt] }) ;
			                  ,(oRentab:SetArray(aRentabil) ,oRentab:bLine := {|| aRentabil[oRenTab:nAt] }) ) ;
			          OF oFolder:aDialogs[2] PIXEL
		EndIf
	Else
		If ExistTemplate("GMMA410CVND",,.T.) .AND. HasTemplate("LOT")
			If ExistTemplate("GMMA410Dupl")
				@ 110,170 BUTTON OemToAnsi("Cond. de Venda") SIZE 050,11 FONT oFolder:aDialogs[1]:oFont ;
				          ACTION ( ExecTemplate("GMMA410CVND",.F.,.F.,{nOpc ,M->C5_NUM ,M->C5_CONDPAG ,dDataCnd ,MaFisRet(,"NF_BASEDUP")}) ;
				                  ,aVencto := ExecTemplate("GMMA410Dupl",.F.,.F.,{M->C5_NUM ,M->C5_CONDPAG,dDataCnd,,MaFisRet(,"NF_BASEDUP"),aVencto}) ;
				                  ,( aDupl := {} ,aEval(aVencto ,{|aTitulo| aAdd( aDupl ,{transform(aTitulo[1],x3Picture("E1_VENCTO")) ,transform(aTitulo[2],x3Picture("E1_VALOR"))})}) ;
				                  ,aRentabil := a410RentPV( aCols ,nUsado ,@aRenTab ,@aVencto ,nPTES,nPProduto,nPLocal,nPQtdVen, M->C5_EMISSAO ) );
				                  ,(oDupl:SetArray(aDupl),	oDupl:bLine := {|| aDupl[oDupl:nAt] }) ;
				                  ,(oRentab:SetArray(aRentabil) ,oRentab:bLine := {|| aRentabil[oRenTab:nAt] }) ) ;
				          OF oFolder:aDialogs[2] PIXEL
			EndIf
		EndIf
	Endif
	@ 109,270 BUTTON OemToAnsi(STR0049)			SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[2] PIXEL	//"Sair"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Folder 3                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 005,001 LISTBOX oRentab FIELDS TITLE aRFHead[1],aRFHead[2],aRFHead[3],aRFHead[4],aRFHead[5],aRFHead[6] SIZE 310,095 	OF oFolder:aDialogs[3] PIXEL
	@ 109,270 BUTTON OemToAnsi(STR0049)			SIZE 040,11 FONT oFolder:aDialogs[3]:oFont ACTION oDlg:End() OF oFolder:aDialogs[3] PIXEL		//"Sair"
	If Empty(aRentabil)
		aRentabil   := {{"",0,0,0,0,0}}
	EndIf
	oRentab:SetArray(aRentabil)
	oRentab:bLine := {|| aRentabil[oRentab:nAt] }
	
	If cPaisLoc == "BRA"
		oLancApICMS := A410LAICMS(oFolder:aDialogs[nLancAp],{005,001,310,095},@aHeadCDA,@aColsCDA,.T.,.F.)
		If FindFunction("SHOWCDV")
			@ 109,220 BUTTON STR0361 SIZE 45,11 FONT oFolder:aDialogs[nLancAp]:oFont ACTION SHOWCDV(.T.,.F.) OF oFolder:aDialogs[nLancAp] PIXEL		//"Val. Declaratório"
		EndIf
		@ 109,270 BUTTON OemToAnsi(STR0049)	SIZE 040,11 FONT oFolder:aDialogs[nLancAp]:oFont ACTION oDlg:End() OF oFolder:aDialogs[nLancAp] PIXEL	//"Sair"

		If lAliasCIP .And. M->C5_TIPO == 'I' .And. FindFunction("COMPTRIB")
			oComplTrib := COMPTRIB(oFolder:aDialogs[nComplem],{005,001,310,095},@aHeadCIP,@aColsCIP,.F.,.F.,M->C5_NUM,aCols)
			@ 109,220 BUTTON STR0377 SIZE 45,11 FONT oFolder:aDialogs[nComplem]:oFont ACTION (Iif(!Empty(aCols[1][nPProduto]), FISA303(M->C5_NUM),MsgAlert(STR0378))) OF oFolder:aDialogs[nComplem] PIXEL //"Editar"##"Insira um Item no Pedido"
			@ 109,270 BUTTON OemToAnsi(STR0049)	SIZE 040,11 FONT oFolder:aDialogs[nComplem]:oFont ACTION oDlg:End() OF oFolder:aDialogs[nComplem] PIXEL	//"Sair"
		EndIf
	EndIf
	 
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
EndIf

MaFisEnd()
MaFisRestore()

RestArea(aAreaSA1)
RestArea(aArea)

aRefRentab := aRentabil

If SuperGetMv("MV_RSATIVO",.F.,.F.)
	lPlanRaAtv := .T.
EndIf

If !lRetTotal
	Return(.T.)
Else
	Return(nValTotal)
EndIf     

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
Local 	cMaskOut	:=  ""
Local	nPNUMITE	:=	0
Local	nPSEQ		:=	0
Local	nPCODLAN	:=	0
Local	nPCALPRO	:=	0
Local	nPBASE		:=	0
Local	nPALIQ		:=	0
Local	nPVALOR		:=	0
Local	nPIFCOMP	:=	0
Local	nPVOut		:=  0
Local 	lVlOutr		:= CDA->(ColumnPos("CDA_VLOUTR")) > 0  
Local	lGerAlp		:= .F.

aMHead("CDA","CDA_TPMOVI/CDA_ESPECI/CDA_FORMUL/CDA_NUMERO/CDA_SERIE/CDA_CLIFOR/CDA_LOJA/",@aHeadCDA)
For nI := 1 To Len(aHeadCDA)
	aAdd(aCmps,aHeadCDA[nI,1])
	
	If "CDA_BASE"==AllTrim(aHeadCDA[nI,2])
		cMaskBs		:=	AllTrim(aHeadCDA[nI,3])
		
	ElseIf "CDA_ALIQ"==AllTrim(aHeadCDA[nI,2])
		cMaskAlq	:=	AllTrim(aHeadCDA[nI,3])
		
	ElseIf "CDA_VALOR"==AllTrim(aHeadCDA[nI,2])
		cMaskVlr	:=	AllTrim(aHeadCDA[nI,3])

	ElseIf lVlOutr .And. "CDA_VLOUTR"==AllTrim(aHeadCDA[nI,2])
		cMaskOut	:=	AllTrim(aHeadCDA[nI,3])		
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
	If lVlOutr .And. nPVOut==0
		nPVOut		:=	Iif("CDA_VLOUTR"$aHeadCDA[nI,2],nI,0)
	Endif		
Next nI

If lVlOutr .And. Len(aLAp) > 0 .And. Len(aLAp[1]) > 20 
	lGerAlp := .T.
Endif

If Len(aLAp)==0
	If nPIFCOMP==0
		aLAp	:=	{{"","","",0,0,0,""}}
	Else
		aLAp	:=	{{"","","",0,0,0,"",""}}
	EndIf
EndIf

If lVlOutr .And. nPVOut > 0 .And. lGerAlp
	If nPIFCOMP==0
		aLine	:=	{,,,,,,,}
	Else
		aLine	:=	{,,,,,,,,}
	EndIf
Else
	If nPIFCOMP==0
		aLine	:=	{,,,,,,}
	Else
		aLine	:=	{,,,,,,,}
	EndIf
Endif

aLine[nPNUMITE]	:=	"aLAp[oLancApICMS:nAT,1]"
aLine[nPSEQ]	:=	"aLAp[oLancApICMS:nAT,7]"
aLine[nPCODLAN]	:=	"aLAp[oLancApICMS:nAT,2]"
aLine[nPCALPRO]	:=	'Iif(aLAp[oLancApICMS:nAT,3]=="1","Sim","Não")'
aLine[nPBASE]	:=	"Transform(aLAp[oLancApICMS:nAT,4],cMaskBs)"
aLine[nPALIQ]	:=	"Transform(aLAp[oLancApICMS:nAT,5],cMaskAlq)"
aLine[nPVALOR]	:=	"Transform(aLAp[oLancApICMS:nAT,6],cMaskVlr)"

If lVlOutr .And. nPVOut > 0 .And. lGerAlp
	aLine[8]		:=	"Transform(aLAp[oLancApICMS:nAT,21],cMaskOut)"
	aCmps[8]		:= 	"Vlr ICMS Out"
	If nPIFCOMP > 0
		aLine[9]		:=	"aLAp[oLancApICMS:nAT,8]"
		aCmps[9]		:= 	"Obs.Lanc.Fis"
	Endif
Else
	If nPIFCOMP > 0
		aLine[nPIFCOMP]	:=	"aLAp[oLancApICMS:nAT,8]"
	EndIf
Endif

oLancApICMS	:=	TWBrowse():New( aPos[1],aPos[2],aPos[3],aPos[4],,aCmps,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
oLancApICMS:SetArray(aLAp)

If lVlOutr .And. nPVOut > 0 .And. lGerAlp
	If nPIFCOMP>0
		oLancApICMS:bLine := &("{|| {"+aLine[nPNUMITE]+","+aLine[nPSEQ]+","+aLine[nPCODLAN]+","+aLine[nPCALPRO]+","+aLine[nPBASE]+","+aLine[nPALIQ]+","+aLine[nPVALOR]+","+aLine[nPIFCOMP]+","+aLine[9]+"} }")
	Else
		oLancApICMS:bLine := &("{|| {"+aLine[nPNUMITE]+","+aLine[nPSEQ]+","+aLine[nPCODLAN]+","+aLine[nPCALPRO]+","+aLine[nPBASE]+","+aLine[nPALIQ]+","+aLine[nPVALOR]+","+aLine[8]+"} }")
	EndIf
Else
	If nPIFCOMP>0
		oLancApICMS:bLine := &("{|| {"+aLine[nPNUMITE]+","+aLine[nPSEQ]+","+aLine[nPCODLAN]+","+aLine[nPCALPRO]+","+aLine[nPBASE]+","+aLine[nPALIQ]+","+aLine[nPVALOR]+","+aLine[nPIFCOMP]+"} }")
	Else
		oLancApICMS:bLine := &("{|| {"+aLine[nPNUMITE]+","+aLine[nPSEQ]+","+aLine[nPCODLAN]+","+aLine[nPCALPRO]+","+aLine[nPBASE]+","+aLine[nPALIQ]+","+aLine[nPVALOR]+"} }")
	EndIf   
Endif           

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
Function A410ISSMUN()

Local nPosCpo   := SX1->(ColumnPos("X1_GRUPO"))
Local cCpoSX1   := SX1->(FieldGet(nPosCpo))
Local nTamSX1   := Len(cCpoSX1)
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
Function a410FreteP()

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
	M->C5_VLR_FRT := 0 //-- Var.mem. valor base icms pauta de frete
	If M->C5_KM > 0
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
		nScan := Ascan(aFreteP,{|x| x[1] >= M->C5_KM .And. x[5] == "2"})
		If nScan > 0
			Do Case
				Case aFreteP[nScan][4] == "1"
					M->C5_VLR_FRT := NoRound((M->C5_PBRUTO/1000)*	aFreteP[nScan][3] ,TamSX3("C5_VLR_FRT")[2])
				Case aFreteP[nScan][4] == "2"
					M->C5_VLR_FRT := NoRound((M->C5_PBRUTO      *	aFreteP[nScan][3]),TamSX3("C5_VLR_FRT")[2])
				Case aFreteP[nScan][4] == "3"
					M->C5_VLR_FRT := NoRound(					  	aFreteP[nScan][3] ,TamSX3("C5_VLR_FRT")[2])
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
Function a410FrPIte(cCampo,cConteudo)

Local aArea    := GetArea()
Local nY       := 0
Local nValBase := 0    
Local nPosPro  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPosTES  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local cCargaE  := "2"
Local cProduto := ""
Local cTES	   := ""

Default cCampo := ReadVar()
Default cConteudo := &(cCampo)

If M->C5_KM > 0 .And. !Empty(aFreteP)
	cProduto := IIf ("C6_PRODUTO" $ cCampo ,cConteudo,aCols[n][nPosPro])
	cTES	 := IIf ("C6_TES" $ cCampo,cConteudo,aCols[n][nPosTES])
	cCargaE := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CARGAE")
	
	nValBase := M->C5_VLR_FRT 
	                                               			
	If !Empty(cTES)
	   	dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4")+cTES)             			

		For nY := 1 To Len(aFreteP)
			If aFreteP[nY][1] >= M->C5_KM
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
		 
		 	If nValBase <> M->C5_VLR_FRT
				Do Case
					Case aFreteP[nY][4] == "1"
						M->C5_VLR_FRT := NoRound((M->C5_PBRUTO/1000)*nValBase,TamSX3("C5_VLR_FRT")[2])
						Exit
					Case aFreteP[nY][4] == "2"
						M->C5_VLR_FRT := NoRound((M->C5_PBRUTO*nValBase),TamSX3("C5_VLR_FRT")[2])
					    Exit
					Case aFreteP[nY][4] == "3"
						M->C5_VLR_FRT := NoRound(nValBase,TamSX3("C5_VLR_FRT")[2])
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
Function A410SMLFRT()

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
Local cCdClFr		:= Space(TamSX3("GWN_CDCLFR")[1]) //-- simulacao de frete: considerar todas a negociacoes cadastradas no GFE ou a selecionada pelo campo GWN_CDCLFR.
Local cTpOp			:= Space(TamSX3("GWN_CDTPOP")[1]) //-- simulacao de frete: considerar todas a negociacoes cadastradas no GFE ou a selecionada pelo campo GWN_CDTPOP.
Local cTpVc			:= Space(TamSX3("GWN_CDTPVC")[1]) //-- simulacao de frete: considerar todas a negociacoes cadastradas no GFE ou a selecionada pelo campo GWN_CDTPVC.
Local cTpDoc		:= ''
Local nLenAcols		:= 0
Local nItem			:= 0
Local nPProduto		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPQtdVen		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPValor		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
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
Local cCdEmis		:= ""
Local cCdRem		:= ""
Local cCdDest		:= ""
Local oCdClFr		:= Nil
Local oTpOp			:= Nil
Local oTpVc			:= Nil

If !Empty(M->C5_CLIENT) .And. !Empty(M->C5_LOJAENT) .And. !Empty(aCols[n,nPProduto]) .And. !Empty(aCols[n,nPQtdVen]) .And. !Empty(aCols[n,nPValor])	

	DEFINE MSDIALOG oDlg1 FROM	31,15 TO 240,285 TITLE STR0193 PIXEL OF oMainWnd //  "Simulação de Frete"
	@ 005,005 SAY STR0356 PIXEL SIZE 160,160 Of oDlg1 //"Selecione a operação a ser consederada:"
	@ 020,005 RADIO oRadio VAR nRadio ITEMS STR0357,STR0358 SIZE 150,150 PIXEL OF oDlg1 //"1- Considera Tab.Frete em Negociacao","2- Considera apenas Tab.Frete Aprovadas"

	@ 045,005 TO 100, 100 LABEL STR0383 PIXEL OF oDlg1	//##"Informações do Frete"  
	@ 057,010 SAY RetTitle("GWN_CDCLFR")	SIZE 40,10 PIXEL OF oDlg1
	@ 072,010 SAY RetTitle("GWN_CDTPOP")	SIZE 40,10 PIXEL OF oDlg1
	@ 087,010 SAY RetTitle("GWN_CDTPVC")	SIZE 40,10 PIXEL OF oDlg1
	@ 055,045 MSGET oCdClFr VAR cCdClFr	F3 'GUB' PICTURE PesqPict('GUB','GUB_CDCLFR') SIZE 50,10 PIXEL OF oDlg1 VALID GFEExistC("GUB",,AllTrim(cCdClFr),"GUB->GUB_SIT=='1'")
	@ 070,045 MSGET oTpOp	VAR cTpOp	F3 'GV4' PICTURE PesqPict('GV4','GV4_CDTPOP') SIZE 50,10 PIXEL OF oDlg1 VALID GFEExistC("GV4",,AllTrim(cTpOp),"GV4->GV4_SIT=='1'")
	@ 085,045 MSGET oTpVc	VAR cTpVc	F3 'GV3' PICTURE PesqPict('GV3','GV3_CDTPVC') SIZE 50,10 PIXEL OF oDlg1 VALID GFEExistC("GV3",,AllTrim(cTpVc),"GV3->GV3_SIT=='1'")

	DEFINE SBUTTON FROM 089,106 TYPE 1 ENABLE OF oDlg1 ACTION (oDlg1:End() )
	nRadio := 2
	ACTIVATE MSDIALOG oDlg1 CENTERED 
	ProcRegua(nRegua)      

	SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENT+M->C5_LOJAENT))	   
	
	//Verifica primeiro se existe a chave "NS" cadastrada, se não busca a chave "N". Mesmo tratamento utilizado no OMSM011.
	cTpDoc	:= AllTrim(Posicione("SX5",1,xFilial("SX5")+"MQ"+M->C5_TIPO+"S","X5_DESCRI"))
	If Empty(cTpDoc)
		cTpDoc := Alltrim(Posicione("SX5",1,xFilial("SX5")+"MQ"+M->C5_TIPO,"X5_DESCRI"))
	EndIf
	cCdEmis := OMSM011COD(,,,.T.,xFilial("SF2"))
	If SC5->(ColumnPos("C5_CLIRET")) > 0 .And. SC5->(ColumnPos("C5_LOJARET")) > 0 .And. !Empty(M->C5_CLIRET) .And. !Empty(M->C5_LOJARET)
		cCdRem 	:= OMSM011COD(M->C5_CLIRET,M->C5_LOJARET,1)
		//Valida o remetente que será utilizado no Doc. de Carga, conforme o sentido configurado na rotina de Tipos de Documentos de Carga.
		If Posicione("GV5", 1, xFilial("GV5") + cTpDoc, "GV5_SENTID") == "2" .And. Posicione("GU3", 1, xFilial("GU3") + cCdRem, "GU3_EMFIL") == "2"
			Help(,, "GFECLIRET",,STR0380+Alltrim(cTpDoc)+STR0381,1,0,,,,,,{STR0382})	//##"O sentido (GV5_SENTID) do tipo de Documento: '" ##"', está configurado como saída." ##"Deverá ser informado no campo 'Cli. Retirada' (C5_CLIRET) um remetente do tipo filial (GU3_EMFIL)."
			Return Nil
		EndIf
	Else
		cCdRem 	:= cCdEmis
	EndIf

	cCdDest := IIF(MTA410ChkEmit(SA1->A1_CGC),SA1->A1_CGC, OMSM011COD(M->C5_CLIENT,M->C5_LOJAENT,1,,) )
		
	oModelSim:SetOperation(3) //Seta como inclusão
	oModelSim:Activate() 			
	oModelNeg:LoadValue('CONSNEG' ,AllTrim(Str(nRadio))) // -- 1=Considera Tab.Frete em Negociacao; 2=Considera apenas Tab.Frete Aprovadas
	IncProc()
	//Agrupadores - Não obrigatorio
	oModelAgr:LoadValue('GWN_CDCLFR',AllTrim(cCdClFr))  //classificação de frete                                 
	oModelAgr:LoadValue('GWN_CDTPOP',AllTrim(cTpOp))    //tipo da operação
	oModelAgr:LoadValue('GWN_CDTPVC',AllTrim(cTpVc))  	//Tipo de veiculo
	oModelAgr:LoadValue('GWN_DOC'   ,"ROMANEIO"     )           
	//Documento de Carga
	oModelDC:LoadValue('GW1_EMISDC', cCdEmis) 	//codigo do emitente - chave
	oModelDC:LoadValue('GW1_NRDC'  , M->C5_NUM  ) 	//numero da nota - chave
	oModelDC:LoadValue('GW1_CDTPDC', cTpDoc) 		// tipo do documento - chave
	oModelDC:LoadValue('GW1_CDREM' , cCdRem)  	//remetente
	oModelDC:LoadValue('GW1_CDDEST', cCdDest)   //destinatario

	oModelDC:LoadValue('GW1_TPFRET', "1")
	oModelDC:LoadValue('GW1_ICMSDC', "2")
	oModelDC:LoadValue('GW1_USO'   , "1")
	oModelDC:LoadValue('GW1_QTUNI' , 1)   

	//Trechos
	A410SetTrechos(oModelTr,cTpDoc,cCdEmis,cCdRem,cCdDest,Iif(Empty(SA1->A1_ESTE),SA1->A1_EST,SA1->A1_ESTE),Iif(Empty(SA1->A1_CODMUNE),SA1->A1_COD_MUN,SA1->A1_CODMUNE))

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
			oModelIt:LoadValue('GW8_EMISDC',cCdEmis)	//codigo do emitente - chave
			oModelIt:LoadValue('GW8_NRDC'  ,M->C5_NUM  ) 	//numero da nota - chave
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
			nPrevEnt  		:= Max(0,oModelCal1:GetValue('C1_DTPREN'  ,nCont ) - ddatabase)

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
		 			AADD (aRet, {,cCGCTran,STR0199,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.F.}) //--"Transportadora não cadastrada no Microsiga Protheus!!!"
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
ElseIf (M->C5_TIPO $ "CIP")
	Aviso(STR0014,STR0317,{"OK"})	//"Atencao"##""A simulação de frete não será executada para os pedidos de Complemento de Preço, ICMS e IPI, portanto não haverá integração com o módulo SIGAGFE."
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
Function a410RetSml(aListBox)

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
	
DEFINE MSDIALOG oDlg TITLE STR0193 From aSize[7],0 to aSize[6]*0.68,aSize[5]*0.61 OF oMainWnd PIXEL //--"Simulação de Frete"
	
	oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)
			
	//-- Cabecalho dos campos do Monitor.                                                        
	//@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER "",STR0194,STR0195,STR0196,STR0214,STR0218, STR0219, STR0220, STR0221, STR0222, STR0223, STR0224, STR0225, STR0226, STR0227  SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL //--"Nome Transp.","Valor do Frete","Cod.Transp.","Prazo de Entrega (Dias)"
	@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER "",STR0194,STR0195,STR0196,STR0214,STR0218,STR0219,STR0220,STR0221,STR0222,STR0223,STR0224,STR0225,STR0226,STR0227 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL //--"Nome Transp.","Valor do Frete","Cod.Transp.","Prazo de Entrega (Dias)"
		 		   
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
	//	aAdd (aRet, {,SA4->A4_COD,SA4->A4_NOME,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.T.})			   
 								
	//-- Botoes da tela do monitor.
	@ aPosObj[3,1],001 BUTTON oBtn01	PROMPT STR0198	ACTION (nOpca := 1, oDlg:End()) OF oDlg PIXEL SIZE 035,011	//-- "Confirmar"
	@ aPosObj[3,1],040 BUTTON oBtn02	PROMPT STR0049	ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011	//-- "Sair"																										                                                    		

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	M->C5_TRANSP := cCodTrans 
	If ExistBlock('MA410SML')
		ExecBlock('MA410SML',.F.,.F.,{aListBox})
	EndIf
EndIf
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
		MsgAlert(STR0199)	//--"Transportadora não cadastrada no Microsiga Protheus!"
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
		MsgAlert(STR0199)	//--"Transportadora não cadastrada no Microsiga Protheus!"
	EndIf	
EndIf	
	
oListBox:Refresh()
Return ( Nil )

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
±±³Fun‡ao     ³IntPVSServ| Autor ³TOTVS S.A.               ³ Data ³ 20/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao utilizada para integracao do Pedido de Vendas com     ³±±
±±³           ³ o produto SISCOSERV da TRADE EASY.                        		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPedido = Numero do Pedido de vendas                      		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA410                                                  			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function IntPVSServ(cPedido,nOpcao)

Local aAreaAnt  := GetArea()
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
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
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	
	aAdd(aCab,{"EJW_FILIAL"		,xFilial("SC5")	,Nil})
	aAdd(aCab,{"EJW_PROCES"		,cPedido        ,Nil})
	aAdd(aCab,{"EJW_ORIGEM"		,"SIGAFAT"	    ,Nil})
	
	If dbSeek(cSeek:=xFilial("SC5")+cPedido)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do aCab (Array que contem o cabecalho do pedido de vendas)|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aCab,{"EJW_IMPORT"		,SC5->C5_CLIENTE	,Nil})
		aAdd(aCab,{"EJW_LOJIMP"		,SC5->C5_LOJACLI	,Nil})
		aAdd(aCab,{"EJW_MOEDA"		,SC5->C5_MOEDA	,Nil})		//Numerico de 2
		aAdd(aCab,{"EJW_COMPL"   	,SC5->C5_MENNOTA	,Nil})
        aAdd(aCab,{"EJW_CONDPG"		,SC5->C5_CONDPAG	,Nil})
		// Conforme orientacao do Alessandro (TRADE-EASY) nao
		// sera necessario o envio dos campos abaixo
		//aAdd(aCab,{"EJW_VL_MOED" 	,SC5->C5_			,Nil}) 
		//aAdd(aCab,{"EJW_VL_REA"  	,SC5->C5_			,Nil})
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do Itens (Array que contem os itens do pedido de vendas)  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC6")
		SC6->(dbGoTop())
		SC6->(dbSetOrder(1)) 
		SC6->(dbSeek(cSeek))
		Do While !Eof() .And. cSeek == SC6->C6_FILIAL+SC6->C6_NUM
			aLinha := {}
			aAdd(aLinha,{"EJX_FILIAL"		,SC6->C6_FILIAL	    ,Nil})
			aAdd(aLinha,{"EJX_PROCES"		,SC6->C6_NUM		,Nil})
			aAdd(aLinha,{"EJX_SEQPRC"		,SC6->C6_ITEM		,Nil})
			aAdd(aLinha,{"EJX_ITEM"			,SC6->C6_PRODUTO	,Nil})
			aAdd(aLinha,{"EJX_QTDE"			,SC6->C6_QTDVEN		,Nil})
			aAdd(aLinha,{"EJX_PRCUN"	  	,SC6->C6_PRCVEN		,Nil})
			aAdd(aLinha,{"EJX_VL_MOE"		,SC6->C6_VALOR 		,Nil})
			aAdd(aLinha,{"EJX_TX_MOE"		,SC5->C5_TXMOEDA	,Nil})
			//aAdd(aLinha,{"EJX_VL_COMPL"		,SC6->		,Nil})
			// Conforme orientacao do Alessandro (TRADE-EASY) nao
			// sera necessario o envio dos campos abaixo pois sera
			// desenvolvida a rotina de manutencao pelo parceiro.
			//aAdd(aLinha,{"EJX_NBS"		,""					,Nil})
			//aAdd(aLinha,{"EJX_PAIS"		,""				,Nil})
			//aAdd(aLinha,{"EJX_MODO"		,""				,Nil})
			//aAdd(aLinha,{"EJX_DTPRIN"		,""				,Nil})
			//aAdd(aLinha,{"EJX_DTPRFI"		,""				,Nil})
			//aAdd(aLinha,{"EJX_DTINI"		,""				,Nil})
			//aAdd(aLinha,{"EJX_DTFIM"		,""				,Nil})
			aAdd(aItens,aLinha)
			SC6->(dbSkip())
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
		ConOut(STR0186) //"EECPS400 - Nao foi possivel realizar a integracao com o SISCOSERV entre em contato com a equipe da TRADE-EASY."
		MostraErro()
	EndIf

EndIf

RestArea(aAreaSC5)
RestArea(aAreaSC6)
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
Function F4Veicu(nOpc,cProduto,cChassi,aCols,N)

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
Local nPVeic	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_BASVEIC"})
Local nPNFOri 	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
Local nPSerie	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
Local nPItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})

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
Function A410GrvDPR(aItemDPR)

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

//If (nOpcao == MODEL_OPERATION_UPDATE .Or. (Type("lExAutoDPR") == "L" .And. lExAutoDPR)) .And. ( (aItemDPR[5] <> aItemDPR[6]) .And. !Empty(aItemDPR[6]) ) .And. !(IsInCallStack("MaBxOrc"))
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

//If ( lAchou .And. aItemDPR[nX, 1] == MODEL_OPERATION_INSERT )
If ( lAchou .And. aItemDPR[1] == 3 )
	MsgInfo(STR0235)  // "Já existe uma pendência como esse número de pedido de venda. Favor, digitar outro número."
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
Function Ma410VlDav(cNumPed)

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

	While SL2->(!Eof()) .and. alltrim(SL2->L2_PEDSC5) == cNumPed
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se ja emitiu DOC para este orcamento, entao aborta ³
		//³a busca e retorna .F. para a alteracao do pedido   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If !Empty(SL2->L2_DOC) .and. !Empty(SL2->L2_SERIE) .or. !FR271CVldImp(SL2->L2_NUM)
			If len(aAutoCab) > 0
				Conout(STR0159 + cNumPed + STR0160 ) //' O Pedido de venda: xxxx tem relacionamento com um DAV e o mesmo possui documento fiscal emitido, portanto nao sera alterado'
			Else
				Aviso(STR0161,STR0162,{STR0163}) //'Este pedido de venda tem relacionamento com um DAV e o mesmo possui documento fiscal emitido'
			EndIf
			lRet := .F.
			exit
        Else
	   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona no array de DAV's a cancelar³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       	If aScan(aItenSL2, { |x| Alltrim(x[1]) == SL2->L2_NUM } ) <= 0
        	aAdd(aItenSL2,{SL2->L2_NUM,SL2->L2_ITEM,SL2->L2_PEDSC5,SL2->L2_ITESC6,SL2->L2_SEQUEN})
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
		 	MsgRun(STR0164 + alltrim(aItenSL2[nI,1] + STR0165),STR0166,{||  Mt410DelDv(aItenSL2[nI,1]) }) //"Excluindo DAV nro: "                           
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
Function Mt410DelDv(cNumDAV)

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
			If SC9->(dbSeek(xFilial('SC9') + SL2->L2_PEDSC5 + SL2->L2_ITESC6 + SL2->L2_SEQUEN ))
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
	nItem++
	If Len(aCols[nX])==nUsado .Or. !aCols[nX][nUsado+1]
		nY := aScan(aRentab,{|x| x[1] == aCols[nX][nPProduto]})
		If nY <> 0
			If cPaisLoc <> 'MEX'
				aRentab[nY][4] += Max(Ma410Custo(nItem,aVencto,aCols[nX][nPTES],aCols[nX][nPProduto],aCols[nX][nPLocal],aCols[nX][nPQtdVen],dDtEmissao),0)
				aRentab[nY][5] := aRentab[nY][4]-aRentab[nY][3]
			Else
				If nMoeda <> M->C5_MOEDA
					aRentab[nY][4] += xMoeda(MaFisRet(nX,'IT_VALMERC'),M->C5_MOEDA,nMoeda,dDataBase)
					aRentab[nY][5] := xMoeda(MaFisRet(nX,'IT_VALMERC'),M->C5_MOEDA,nMoeda,dDataBase)-aRentab[nY][3]
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
Local cDicCampo  := ""
Local cDicArq    := ""
Local cDicUsado  := ""
Local cDicNivel  := ""
Local cDicTitulo := ""
Local cDicPictur := ""
Local nDicTam    := ""
Local nDicDec    := ""
Local cDicValid  := ""
Local cDicTipo   := ""
Local cDicF3     := ""
Local cDicContex := ""
Local cDicCBox   := ""
Local cDicRelaca := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

M410DicIni(cAlias)
cDicCampo := M410RetCmp()
cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

While !M410DicEOF() .And. (cDicArq == cAlias)
	
	cDicUsado   := GetSX3Cache(cDicCampo, "X3_USADO")
	cDicNivel   := GetSX3Cache(cDicCampo, "X3_NIVEL")

	IF X3USO(cDicUsado) .And. cNivel >= cDicNivel .and. !(AllTrim(cDicCampo)+"/"$cNCmps)

		cDicTitulo  := M410DicTit(cDicCampo)
		cDicPictur  := X3Picture(cDicCampo)
		nDicTam     := GetSX3Cache(cDicCampo, "X3_TAMANHO")
		nDicDec     := GetSX3Cache(cDicCampo, "X3_DECIMAL")
		cDicValid   := GetSX3Cache(cDicCampo, "X3_VALID")
		cDicTipo    := GetSX3Cache(cDicCampo, "X3_TIPO")
		cDicF3      := GetSX3Cache(cDicCampo, "X3_F3")
		cDicContex  := GetSX3Cache(cDicCampo, "X3_CONTEXT")
		cDicCBox    := Posicione("SX3", 2, cDicCampo, "X3CBox()")
		cDicRelaca  := GetSX3Cache(cDicCampo, "X3_RELACAO")

		aAdd(aH,{ Trim(cDicTitulo), ;
			AllTrim(cDicCampo),;
			cDicPictur,;
			nDicTam,;
			nDicDec,;
			cDicValid,;
			cDicUsado,;
			cDicTipo,;
			cDicF3,;
			cDicContex,;
			cDicCBox,;
			cDicRelaca})
	Endif

	M410PrxDic()
	cDicCampo := M410RetCmp()
	cDicArq   := cValToChar(GetSX3Cache(cDicCampo, "X3_ARQUIVO"))

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
Function A410BxGc(cCliente,cLoja,xC5Num,xC5Nota,xC5Serie)

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
	Aviso(STR0153,STR0188,{STR0189}) //Atenção, "Numero do pedido de venda ou Nota ou Serie não foram informadas",OK
EndIf

//Projeto Chave Unica parte do principio que o xC5Serie passado para
//a funcao A410BxGc eh o ID de Controle vindo do campo VV0_SERNFI 
cSerieId := xC5Serie

If lRet
	DbSelectArea("SC5")
	DbSetOrder(3)
	
	If DbSeek(xFilial('SC5')+PADR(cCliente,TAMSX3("C5_CLIENTE")[1])+PADR(cLoja,TamSx3("C5_LOJACLI")[1])+xC5Num)
		If Empty(SC5->C5_NOTA) .OR. SC5->C5_LIBEROK <> 'E' .And. !Empty(SC5->C5_BLQ)
			DbSelectArea("SC6")
			DbSetOrder(1)
			If DbSeek(xFilial('SC6')+xC5Num)
				While !Eof() .And. xFilial('SC6')+ SC6->C6_NUM == xFilial('SC5') + xC5Num
					cItem := SC6->C6_ITEM
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
							Aviso(STR0153,STR0190,{STR0189})  //Atenção,"Pedido de Venda possui algum bloqueio",OK
							lRet := .F.
						EndIf	
					Else
						lRet := .F.
						Aviso(STR0153,STR0190,{STR0189}) //Atenção,"Pedido de Venda possui algum bloqueio",OK	
					EndIf
					If lRet
						RecLock("SC6", .F.)                                 		
						REPLACE C6_NOTA   	 WITH xC5Nota

						SerieNfId("SC6",1,"C6_SERIE",,,, cSerieId )

						MsUnlock()
					EndIf
					
					SC6->(DbSkip())
				End
			EndIf
			If lRet
				RecLock("SC5", .F.)
				REPLACE C5_NOTA     WITH xC5Nota

				SerieNfId("SC5",1,"C5_SERIE",,,, cSerieId )

				REPLACE C5_LIBEROK  WITH "S" 
				MsUnlock()
			EndIf
		Else
			Aviso(STR0153,STR0191,{STR0189}) //Atenção,"Pedido de Venda já está encerado",OK
			lRet :=.F.		
		EndIf		
	Else
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} M410DicIni()
Funcao para inicializar as variaveis de controle para consulta a
dados do SX3 via API's

@param		cArqCpos	, Char    , Alias a ser utilizado na consulta SX3 dos campos
@author 	Squad CRM & Faturamento
@since 		01/06/2020
@version 	12.1.27
@return 	Nulo
/*/
//-----------------------------------------------------------------------------------
Static Function M410DicIni(cArqCpos)

	Static nNumCpo    := 0  
	Static aCamposDic := {}
	Static cAliasDic  := ""  
	Static lFWSX3Util := Nil
	Static nQtdCampos := 0

	Local aCmpsAux1 := {}
	Local aCmpsAux2 := {}
	Local nCampo    := ""

	Default cArqCpos := ""

	// Inicializar variaveis
	aSize(aCamposDic, 0)
	nNumCpo    := 1
	cAliasDic  := cArqCpos

	// Realizar as verificacoes de que os componentes para tratar os Debitos 
	// tecnicos estao no ambiente do cliente
	If lFWSX3Util == Nil
		M410VrfSQ()
	EndIf

	// Iniciar ou posicionar nas estruturas de dados para buscar o campo do
	// alias do cArqSX3 para utilizacao pelas demais funcoes associadas a esta
	If lFWSX3Util
		aCmpsAux1 := FWSX3Util():GetAllFields(cAliasDic)
		nQtdCampos := Len(aCmpsAux1)

		// Ordenar pelo campo X3_ORDEM
		For nCampo = 1 To nQtdCampos
			aAdd(aCmpsAux2, {aCmpsAux1[nCampo], GetSX3Cache(aCmpsAux1[nCampo], "X3_ORDEM")})
		Next nCampo
		aSort(aCmpsAux2, , , {|campo1, campo2| campo1[2] < campo2[2]})
		For nCampo = 1 To nQtdCampos
			aAdd(aCamposDic, aCmpsAux2[nCampo][1])
		Next nCampo
		FreeObj(aCmpsAux1)
		FreeObj(aCmpsAux2)
	Else
		DbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		SX3->(MsSeek(cAliasDic))
	Endif

Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410VrfSQ()
Funcao para verificar se os componentes indicados pelo Framework para realizar
a leitura dos dicionários SX3 estao no ambiente.

@param		Não há.
@author 	Squad CRM & Faturamento
@since 		01/06/2020
@version 	12.1.27
@return 	Null
/*/
//-------------------------------------------------------------------------------
Static Function M410VrfSQ()
	Local cVersaoLib := ""
	
	cVersaoLib := FWLibVersion()

	If cVersaoLib > "20180823"
		lFWSX3Util := .T.
	Else
		lFWSX3Util := .F.
	EndIf

Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410PrxDic()
Funcao para posicionar na proxima linha do SX3 para ler os seus respectivos dados

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		01/06/2020
@version 	12.1.27
@return 	Nulo
/*/
//-------------------------------------------------------------------------------
Static Function M410PrxDic()

	If lFWSX3Util
		nNumCpo++
	Else
		SX3->(DbSkip())
	EndIf
Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410RetCmp()
Funcao para retornar o campo da posicionada linha no SX3 

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		01/06/2020
@version 	12.1.27
@return 	cCampo , Char , Campo da linha posicionada no SX3
/*/
//-------------------------------------------------------------------------------
Static Function M410RetCmp()
	Local cCampo  := ""
	Local nPosCpo := 0

	If lFWSX3Util
		If nNumCpo <= nQtdCampos
			cCampo := aCamposDic[nNumCpo]	
		EndIf
	Else
		nPosCpo := SX3->(ColumnPos("X3_CAMPO"))
		cCampo  := SX3->(FieldGet(nPosCpo))
	EndIf
Return cCampo

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410DicEOF()
Funcao para retornar se o SX3 esta no final de arquivo ou nao

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		01/06/2020
@version 	12.1.27
@return 	lEhEOF , Boolean , Indica se esta no final do arquivo ou nao
/*/
//-------------------------------------------------------------------------------
Static Function M410DicEOF()

	Local lEhEOF := .F.

	If lFWSX3Util
		If nNumCpo > nQtdCampos
			lEhEOF := .T.
		EndIf
	Else
		lEhEOF := SX3->(EOF())
	EndIf

Return lEhEOF

//-------------------------------------------------------------------------------
/*/{Protheus.doc} M410DicTit()
Funcao para retornar o titulo do campo do SX3

@param		Nao há
@author 	Squad CRM & Faturamento
@since 		15/06/2020
@version 	12.1.27
@return 	cTitulo , Character , Titulo do campo no idioma do ambiente
/*/
//-------------------------------------------------------------------------------
Static Function M410DicTit(cCampo)

	Local cTitulo := ""

	If lFWSX3Util
		cTitulo := FWX3Titulo(cCampo)
	Else
		cTitulo := X3Titulo()
	EndIf

Return cTitulo

//---------------------------------------------------
/*/
Function A410SetTrechos
Seta os Trechos do Documento de Carga para simulação de frete
@author André Anjos
@since 06/06/2020
/*/
//---------------------------------------------------
Static Function A410SetTrechos(oModelTr,cTpDoc,cCdEmis,cCdRem,cCdDest,cEst,cCodMun)
Local nI		:= 1
Local aTrechos	:= {}
Local cValor	:= ""
Local lMRedes	:= ExistBlock("M461LSF2")
Local cCidO		:= Posicione("GU3",1,xFilial("GU3")+cCdRem,"GU3_NRCID")
Local cCepO		:= Posicione("GU3",1,xFilial("GU3")+cCdRem,"GU3_CEP")
Local nPosPg	:= aScan(oModelTr:aHeader,{|x| AllTrim(x[2]) == "GWU_PAGAR"})
Local cTpFrete	:= ""

aAdd(aTrechos, { M->C5_TRANSP , AllTrim(M->C5_TPFRETE), "", "" })

For nI := 1 To 5
	If !lMRedes .And. nI > 1 
		Exit
	EndIf
	If SC5->(ColumnPos('C5_REDESP' +Iif(nI == 1,"",Str(nI,1)))) > 0
		aAdd(aTrechos, { M->&('C5_REDESP' +Iif(nI == 1,"",Str(nI,1))) , AllTrim(M->C5_TPFRETE) , "" , "" } )
		If lMRedes
			If SC5->(ColumnPos('C5_TFRDP' +Str(nI,1))) > 0 .And. !Empty(cValor := M->&('C5_TFRDP' +Str(nI,1)))
				aTail(aTrechos)[2] := cValor
			EndIf
			If SC5->(ColumnPos('C5_ESTRDP' +Str(nI,1))) > 0 .And. !Empty(cValor := M->&('C5_ESTRDP' +Str(nI,1)))
				aTail(aTrechos)[3] := cValor
			EndIf
			If SC5->(ColumnPos('C5_CMURDP' +Str(nI,1))) > 0 .And. !Empty(cValor := M->&('C5_CMURDP' +Str(nI,1)))
				aTail(aTrechos)[4] := cValor
			EndIf
		EndIf
	EndIf
Next nI

aAdd(aTrechos, {Nil,Nil} )

For nI := 1 To Len(aTrechos)
	If nI != 1
		oModelTr:AddLine()
		oModelTr:GoLine( nI )
	EndIf
	
	oModelTr:LoadValue('GWU_SEQ'   , MsStrZero(nI,2) )	// sequencia - chave
	oModelTr:LoadValue('GWU_CDTPDC', cTpDoc )			// tipo do documento - chave
	oModelTr:LoadValue('GWU_EMISDC', cCdEmis)			// codigo do emitente - chave
	oModelTr:LoadValue('GWU_NRDC'  , M->C5_NUM  ) 		// numero da nota - chave
	oModelTr:LoadValue('GWU_NRCIDO', cCidO )			// cidade origem
	oModelTr:LoadValue('GWU_CEPO'  , cCepO )			// cep origem

	If nPosPg > 0
		cTpFrete := Iif(Empty(aTrechos[nI][2]),M->C5_TPFRETE,aTrechos[nI][2])
		oModelTr:LoadValue('GWU_PAGAR',IIf(cTpFrete == "C" .Or. cTpFrete == "R","1","2"))
	EndIf
	
	If !Empty(aTrechos[nI + 1][1])
		SA4->( dbSetOrder(1) )
		SA4->( dbSeek(xFilial("SA4")+aTrechos[nI + 1][1] ) )
		If lMRedes .And. !Empty(aTrechos[nI + 1][3]) .And. !Empty(aTrechos[nI + 1][4])
			oModelTr:LoadValue('GWU_NRCIDD', rTrim(TMS120CDUF(aTrechos[nI + 1][3], "1") + aTrechos[nI + 1][4] ))
		Else
			oModelTr:LoadValue('GWU_NRCIDD', rTrim(TMS120CDUF(SA4->A4_EST, "1") + SA4->A4_COD_MUN ))
		EndIf
		oModelTr:LoadValue('GWU_CEPD', SA4->A4_CEP)
	Else
		oModelTr:LoadValue('GWU_NRCIDD', rTrim(TMS120CdUf(cEst, "1") + cCodMun ))
		oModelTr:LoadValue('GWU_CEPD', POSICIONE("GU3",1,xFilial("GU3")+cCdDest,"GU3_CEP"))

		nI := Len(aTrechos)
	EndIf

	//-- Origem do próximo trecho é o destino do atual
	cCepO := oModelTr:GetValue('GWU_CEPD')
	cCidO := oModelTr:GetValue('GWU_NRCIDD')
Next nI

Return
