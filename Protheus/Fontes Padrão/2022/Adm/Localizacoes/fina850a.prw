#include "protheus.CH"
#include "FINA850.CH"
#include "TOTVS.CH"
#INCLUDE 'FWBROWSE.CH'

//Posicoes do Array ASE2 
#DEFINE _FORNECE		1
#DEFINE _LOJA			2
#DEFINE _VALOR    		3
#DEFINE _MOEDA			4
#DEFINE _SALDO    		5
#DEFINE _SALDO1   	6
#DEFINE _EMISSAO  	7
#DEFINE _VENCTO   	8
#DEFINE _PREFIXO  	9
#DEFINE _NUM     		10
#DEFINE _PARCELA 		11
#DEFINE _TIPO    		12
#DEFINE _RECNO   		13
#DEFINE _RETIVA  		14
#DEFINE _RETIB   		15
#DEFINE _NOME    		16
#DEFINE _JUROS   		17
#DEFINE _DESCONT 		18
#DEFINE _NATUREZ 		19
#DEFINE _ABATIM  		20
#DEFINE _PAGAR   		21
#DEFINE _MULTA   		22
#DEFINE _RETIRIC 		23
#DEFINE _RETSUSS 		24
#DEFINE _RETSLI  		25
#DEFINE _RETIR   		26
#DEFINE _RETIRC  		27 //Portugal
#DEFINE _RETISI  		28
#DEFINE _RETRIE  		29 //Angola
#DEFINE _RETIGV  		30 //PERU
#DEFINE _CBU     		31 //Controle de CBU - Argentina
#DEFINE _NRCHQ   		32 //EQUADOR

#DEFINE _ELEMEN  		32 //indica o tamanho para o array ase2

//Posicoes do ListBox
#DEFINE H_OK			1
#DEFINE H_FORNECE		2
#DEFINE H_LOJA    		3
#DEFINE H_NOME    		4
#DEFINE H_NF      		5
#DEFINE H_NCC_PA  	6
#DEFINE H_TOTAL 		7

//ARG
#DEFINE H_RETGAN		8
#DEFINE H_RETIB 		10
#DEFINE H_RETSUSS		11
#DEFINE H_RETSLI 		12
#DEFINE H_RETISI		13
#DEFINE H_CBU			14
//URU
#DEFINE H_RETIRIC 	8 //Mesma posicao que as Ganancias pq so eh utilizado no Uruguai.
#DEFINE H_RETIR   	11 //Mesma posicao que as SUSS pq so eh utilizado no Uruguai.
// INI Portugal
#DEFINE H_RETIRC  	8 //Mesma posicao que as Ganancias pq so eh utilizado EM portugal.
#DEFINE H_RETIVA		9 //ARG Tambem
#DEFINE H_DESPESAS	10
//FIM PORTUGAL

//ANGOLA
#DEFINE H_RETRIE    	8 //A confirmar - Posicao do imposto RIE de Angola
//Fim Angola
//PERU
#DEFINE H_RETIGV    	8 //A confirmar - Posicao do imposto IGV DO PERU
//Fim PERU

#DEFINE H_TOTALVL 	15
#DEFINE H_PORDESC 	16
#DEFINE H_TOTRET 		17
#DEFINE H_DESCVL 		18
#DEFINE H_EDITPA  	19
#DEFINE H_VALORIG  	20
#DEFINE H_NATUREZA 	21
#DEFINE H_UNICOCHQ 	22
#DEFINE H_MULTICHQ 	23

#DEFINE H_TERC    		24

#DEFINE _PA_VLANT 	01
#DEFINE _PA_MOEANT 	02
#DEFINE _PA_VLATU  	03
#DEFINE _PA_MOEATU 	04

Function F850SldOP(aSE2, aPagos, nLinha, lOPRotAut)
Local aSavArea		:= GetArea()
Local nSE2			:= 0
Local nUsado		:= 0
Local nLenAcol		:= 0
Local nP			:= 0
Local nPorc		:= 0
Local nDig			:= 0
Local nVlrPg		:= 0
Local nValorTit	:= 0

Local nPosPorPg
Local nPosVlrPg
Local nPosVlr3o
Local nPosM3o
/*
Local nPosValor	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(X[2])=="E2_VALOR"}	)
Local nPosSaldo	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(X[2])=="E2_SALDO"}	)
Local nPosMulta	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_MULTA"}	)
Local nPosJuros	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_JUROS"}	)
Local nPosDesco	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_DESCONT"}	)
Local nPosPagar	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_PAGAR"}	)
Local nPosVl		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="NVLMDINF"}	)
Local nPosMoeda	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_MOEDA"}	)
Local nPosForne	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_FORNECE"}	)
Local nPosLoja	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_LOJA"}	)
Local nPosTipo	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_TIPO"}	)
Local nPosPref	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_PREFIXO"}	)
Local nPosNum		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_NUM"}		)
Local nPosParc	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_PARCELA"}	)
Local nPosVenc	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_VENCTO"}	)
*/
Local nPosMPgto

Local aColsSE2		:= {}
Local aColsPg		:= {}
Local aColsGd2  	:= {}
Local lRet			:= .T.
Local nValorPago	:= 0
Local nValorPagar	:= 0
Local nCfgElt		:= 0
Local nSaldoPgOP	:= 0

aColsSE2 := {}

nOlbxAtAnt := nLinha
aColsPg 	:= Aclone(aSE2[nOlbxAtAnt][3,2])
nPorc 		:= 0
nVlrPg 		:= 0

If !lOPRotAut

	nPosPorPg	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "NPORVLRPG"})
	nPosVlrPg	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(X[2]) == "EK_VALOR"}	)
	nPosVlr3o	:= Ascan(oGetDad2:aHeader,{|x| Alltrim(X[2]) == "E1_SALDO"}	)
	nPosM3o	:= Ascan(oGetDad2:aHeader,{|x| Alltrim(x[2]) == "E1_MOEDA"}	)
	nPosMPgto 	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "MOEDAPGTO"})

	If Empty(aColsPg)
		Aadd(aColsPg,Array(Len(oGetDad1:aHeader)+1))
		For nP := 1 To Len(oGetDad1:aHeader)
			If oGetDad1:aHeader[nP,2] == "NPORVLRPG"
				aColsPg[1,nP] := 0
			ElseIf oGetDad1:aHeader[nP,2] == "MOEDAPGTO"
				aColsPg[1,nP] := nMoedaCor
			ElseIf oGetDad1:aHeader[nP,2] == "FRECHQ"
				aColsPg[1,nP] := Space(20)
			Else
				aColsPg[1,nP] := Criavar(AllTrim(oGetDad1:aHeader[nP,2]))
			Endif
		Next
		aColsPg[1,Len(aColsPg[1])] := .F.
	Else
		For nP := 1 To Len(aColsPg)
			nPorc += aColsPg[nP,nPosPorPg]
			aColsPg[nP,nPosVlrPg] := Round(xMoeda(aColsPg[nP,nPosVlrPg],aColsPg[nP,nPosMPgto],nMoedaCor,,,aTxMoedas[aColsPg[nP,nPosMPgto],2],aTxMoedas[nMoedaCor,2]),MsDecimais(nMoedaCor))
			aColsPg[nP,nPosMPgto] := nMoedaCor
			nVlrPg += aColsPg[nP,nPosVlrPg]
		Next
	Endif

	nTotDocProp := nVlrPg

Else

	nPosVlr3o	:= 7
	nPosM3o	:= 8

	For nP := 1 To Len(aColsPg)
		nVlrPg += aColsPg[nP,5]
	Next

	nTotDocProp := nVlrPg

EndIf


/*_*/
aCols3os		:= Aclone(aSE2[nOlbxAtAnt][3,3])
aColsGD2 		:= aCols3os
nSaldoPgOP		:= 0
nTotDocTerc	:= 0
/*_*/
For nP := 1 To Len(aCols3os)
	nTotDocTerc += Round(xMoeda(aColsGD2[nP,nPosVlr3o],aColsGD2[nP,nPosM3o],nMoedaCor,,5,aTxMoedas[aColsGD2[nP,nPosM3o]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
Next

//ajusta as diferencas de centavos em documentos proprios
nSaldoPgOP := aPagos[nLinha,H_TOTALVL] - (nTotDocTerc + nTotDocProp)


RestArea(aSavArea)

Return nSaldoPgOp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850TITRETบAutor  ณWilliam Gundim      บFecha ณ 27/09/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava Impostos no array aTitImp   บ							 ฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850TitRet(aTitImp,nValRet,cOrdPago,dDataBase,nMoedaRet,cTitImp)
Local lTitRet 	  	:= GetNewPar("MV_TITRET",.F.)
Local nPosImp
Default nValRet 	:= 0
Default cOrdPago 	:= ""
Default nMoedaRet	:= 0
Default dDataBase	:= 0

If lTitRet .And. nValRet > 0
	nPosImp := aScan(aTitImp, {|x| x[10] == cTitImp })
	If nPosImp > 0
		aTitImp[nPosImp][7] += nValRet
	Else
		aAdd(aTitImp,{SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, nValRet, cOrdPago, dDataBase, cTitImp, nMoedaRet,,,SE2->E2_CODAPRO })
	EndIf
		nValRet := 0
EndIf

Return aTitImp
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850TITIMPบAutor  ณMicrosiga           บFecha ณ 27/02/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera titulos no contas a pagar referentes aos impostos e   บฑฑ
ฑฑบ          ณ retencoes.                                                 บฑฑ
ฑฑบ          ณ Os titulos gerados tem o mesmo numero da ordem de pago,    บฑฑ
ฑฑบ          ณ com as parcelas em sequencia crescente (1,2,3...)          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850TitImp(aSE2,cOrdPago)
Local aTitulos	:= {}
Local cFornec	:= ""
Local cLojaImp	:= ""
Local cParcela	:= ""
Local nSE2		:= 0
Local nTit		:= 0
Local nValor1	:= 0
Local nValor2	:= 0

Default aSE2	:= {{}}
/*
Verifica os impostos e retencoes praticados
Estrutura do array de titulos: {valor,data de vencimento,moeda,tipo,historico} */
If cPaisLoc == "PER"
	For	nSE2 := 1 To Len(aSE2[1])
		/* cria um titulo por tipo de retencao */
		If !Empty(aSE2[1,nSe2,_RETIGV])		//IGV
			For nTit := 1 To Len(aSE2[1,nSe2,_RETIGV])
				nValor1 += aSE2[1,nSe2,_RETIGV,nTit,4]
			Next
		Endif
		If !Empty(aSE2[1,nSe2,_RETIR])		//IR
			For nTit := 1 To Len(aSE2[1,nSe2,_RETIR])
				nValor2 += aSE2[1,nSe2,_RETIR,nTit,4]
			Next
		Endif
	Next
	If nValor1 > 0
		Aadd(aTitulos,{nValor1,F850GeraVenc("","IG-"),1,"IG-",STR0196})
	Endif
	If nValor2 > 0
		Aadd(aTitulos,{nValor2,F850GeraVenc("","IR-"),1,"IR-",STR0203})
	Endif
Endif
/*
Grava os titulos referentes a impostos e retencoes */
If !Empty(aTitulos)
	cLojaImp := PadR("00",TamSX3("A2_LOJA")[1],"0")
	cParcela := PadR("0",TamSX3("E2_PARCELA")[1],"")
	/*
	Verifica se o fornecedor padrao para impostos existe e em caso negativo, o insere no cadastro */
	cFornec := GetMV("MV_UNIAO",.T.,"FISCO")
	cFornec := Padr(cFornec,TamSX3("A2_COD")[1])
	If !SA2->(MsSeek(xFilial("SA2") + cFornec))
		Reclock("SA2",.T.)
		Replace A2_FILIAL	With xFilial("SA2")
		Replace A2_COD		With cFornec
		Replace A2_NOME	With OemToAnsi(STR0219)  	// "UNIAO"
		Replace A2_NREDUZ	With OemToAnsi(STR0219)  	// "UNIAO"
		Replace A2_LOJA	With cLojaImp
		Replace A2_MUN		With "."
		Replace A2_EST		With "."
		Replace A2_BAIRRO	With "."
		Replace A2_END		With "."
		Replace A2_TIPO	With "J"
		SA2->(MsUnLock())
		SA2->(DbCommit())
	Endif
	/*
	insere os titulos */
	For nTit := 1 To Len(aTitulos)
		cParcela := Soma1(cParcela)
		RecLock("SE2",.T.)
		SE2->E2_FILIAL 	:= xFilial("SE2")
		SE2->E2_NUM		:= cOrdPago
	 	SE2->E2_PARCELA 	:= cParcela
		SE2->E2_EMISSAO	:= dDataBase
		SE2->E2_VENCTO 	:= aTitulos[nTit,2]
		SE2->E2_VENCORI	:= aTitulos[nTit,2]
		SE2->E2_VENCREA	:= DataValida(aTitulos[nTit,2])
		SE2->E2_VALOR		:= aTitulos[nTit,1]
		SE2->E2_SALDO		:= aTitulos[nTit,1]
		SE2->E2_NATUREZ	:= SA2->A2_NATUREZ
		SE2->E2_TIPO		:= aTitulos[nTit,4]
		SE2->E2_NOMFOR  	:= SA2->A2_NREDUZ
		SE2->E2_PREFIXO	:= "  "			//o prefixo sempre e deixado em branco, para facilitar na exclusao da OP (ver fina086)	
		SE2->E2_FORNECE 	:= SA2->A2_COD
		SE2->E2_LOJA		:= SA2->A2_LOJA
		SE2->E2_EMIS1		:= dDataBase
		SE2->E2_VLCRUZ 	:= aTitulos[nTit,1]
		SE2->E2_MOEDA		:= aTitulos[nTit,3]
		SE2->E2_HIST		:= aTitulos[nTit,5]
		SE2->E2_ORIGEM	:= "FINA085A"
		SE2->(MsUnLock())
		SE2->(DbCommit())
	Next
Endif
Return()



//-------------------------------------------------------------------
//{Protheus.doc}  F850ARotAu  -
//Rotina automแtica da Ordem de Pago......
//
//@author Lucas de Oliveira
//@since 21/03/2014
//@version 1.0
//
//-------------------------------------------------------------------

Function F850ARotAu(nOper, aCabOP ,aDocPg, aFormaPg)

Local nBaseRIE			:=	0
Local nAliqRIE			:=	0
Local nRetRIE			:=	0
Local nRetIR 			:=	0
Local aSE2				:=	{}
Local aRateioGan		:=	{}
Local lMsErroAuto		:=	.F.
Local nVlDocTer			:=	0
Local nVlDocProp		:=	0
Local nVlDocPg			:=	0
Local nValDocs			:= 	0
Local nX				:=	0
Local nDate				:=	Date()
Local cMoeda			:= ""
Local aAreaSA2			:=	SA2->( GetArea() )
Local aAreaSE1			:=	SE1->( GetArea() )
Local aAreaSE2			:=	SE2->( GetArea() )
Local aAreaFJK			:=	FJK->( GetArea() )
Local aAreaFJL			:=	FJL->( GetArea() )
Local lRet				:=	.T.
Local cMod				:=	""
Local cFilFJK			:=  ""

Private nTamFormaPg		:= 	Len(aFormaPg)
Private nTamDocPg		:=	Len(aDocPg)
Private aFormasPgto		:=	Fin025Tipo()
Private aTxMoedas		:=	F850ATxMoe()
Private aPagos			:= {}
Private cFornece		:=	aCabOP[1][2]
Private cLoja			:=	aCabOP[2][2]
Private cNatureza		:=	aCabOP[3][2]
Private cBanco			:=	""
Private cAgencia		:=	""
Private cConta			:=	""
Private nValor			:=	aCabOP[6][2]
Private cCF				:=	aCabOP[7][2]
Private cZnGeo 			:=	aCabOP[8][2]
Private nGrpSus 		:=	aCabOP[9][2]
Private cProv			:=	aCabOP[10][2]
Private cNumOp			:=	aCabOP[11][2]
Private nSaldoPgOP		:=	0
Private nUnico			:=	1
Private nMultiplo		:=	1
Private nRetIva			:=	0
Private nRetGan			:=	0
Private nRetISI			:=	0
Private nTotNF			:=	0
Private nRet			:=	0
Private nRetib			:=	0
Private nRetIric		:=	0
Private nRetIRC			:=	0
Private nRetSUSS		:=	0
Private nRetSLI			:=	0
Private nRetIGV			:=	0
Private nRetIR4			:=	0
Private nRetAbt			:=	0
Private nTotNcc			:=	0
Private nTotAnt			:=	0
Private nValBrut		:=	0
Private nValLiq			:=	0
Private nValDesc		:=	0
Private nValDesp		:=	0
Private nLiquido		:=	0
Private nVlrPagar		:=	0
Private nFlagMOD		:=	0
Private nCtrlMOD		:=	0

Private lShowPOrd		:=	.F.
Private lVldNat			:=	.F.
Private lSmlCtb			:=	.F.
Private nPosTipo		:=	1
Private nPosTpDoc		:=	0
Private nPosNum			:=	3
Private nPosPrefix		:=	2
Private nPosMoeda		:=	6
Private nPosMPgto		:=	6
Private nPosBanco		:=	9
Private nPosAgenc		:=	10
Private nPosConta		:=	11
Private nPosTalao		:=	12
Private nPosVlr			:=	5
Private nPosEmi			:=	7
Private nPosVcto		:=	8
Private nPosDeb			:=	0
Private nPosParc		:=	4
Private nPosVlrE1		:=	7
Private nPosMoedaE1		:=	8
Private cSolFun			:=	aCabOP[5][2]
Private nValOrdens		:=	0
Private nNumOrdens		:=	0
Private cOpcElt			:=	Iif( aCabOP[12][2] == "1", .T., .F. )
Private nPosVlr3o		:=	7
Private nPosM3o			:=	8
Private aRecnoSE2			:=	{}


If !cOpcElt
		// Para documentos de terceiros, o valor informado para cada documento deve ser igual ao seu saldo.
	If nTamFormaPg > 1

		For nX:= 1 To Len(aFormaPg[2])

			If 	!Empty( aFormaPg[2][nX] ) .AND. lRet

					//E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
				SE1->( dbSetOrder(2) )
				If SE1->( MsSeek( xFilial( "SE1" ) + PadR( aFormaPg[2][nX][9][2], TAMSX3( 'E1_CLIENTE' )[1] ) + PadR( aFormaPg[2][nX][10][2], TAMSX3( 'E1_LOJA' )[1] ) + PadR( aFormaPg[2][nX][2][2], TAMSX3( 'E1_PREFIXO' )[1] ) + PadR( aFormaPg[2][nX][3][2], TAMSX3( 'E1_NUM' )[1] ) + PadR( aFormaPg[2][nX][4][2], TAMSX3( 'E1_PARCELA' )[1] ) + PadR( aFormaPg[2][nX][1][2], TAMSX3( 'E1_TIPO' )[1] ) ) )
					If aFormaPg[2][nX][7][2] <= 0
						cTxtRotAut += Alltrim(STR0245) + ":  " + SE2->E2_NUM + ":  " + STR0164 + CRLF + CRLF // "Inf.Valor por Pagar "
						lMsErroAuto	:= .T.
						lRet		:= .F.
					Else
						If aFormaPg[2][nX][7][2] == SE1->E1_SALDO
							nMoeda		:= aFormaPg[2][nX][8][2]
							nVlDocTer	+= xMoeda( aFormaPg[2][nX][7][2], nMoeda, 1, nDate)
						Else
							cTxtRotAut		+= STR0391 + CRLF + CRLF  // "O valor informado do documento de terceiro nใo condiz com o valor cadastrado no Contas a Pagar."
							lMsErroAuto	:= .T.
							lRet 			:= .F.
						EndIf
					Endif
				Else
					cTxtRotAut 	+= STR0392 + CRLF + CRLF //  "O documento informado nใo existe."
					lMsErroAuto	:= .T.
					lRet 			:= .F.
				EndIf

				SE1->( RestArea( aAreaSE1 ) )

			EndIf

		Next nX

	EndIf


		// Documentos de terceiro devem ser informados em aFormaPG, somente se o fornecedor para quem a OP serแ gerada aceitar esse tipo de documento.
	If lRet
			//A2_FILIAL+A2_COD + A2_LOJA
		SA2->( dbSetOrder( 1 ) )
		If SA2->( MsSeek( xFilial( "SA2" ) + PadR( cFornece, TAMSX3('A2_COD')[1] ) + PadR( cLoja, TAMSX3('A2_LOJA')[1] ) ) )
			If SA2->A2_ENDOSSO == "2"
				cTxtRotAut		+= STR0393 + CRLF + CRLF // "O fornecedor nใo aceita documentos de terceiros."
				lMsErroAuto	:= .T.
				lRet 			:= .F.
			EndIf
		Else
			cTxtRotAut		+= STR0394 + CRLF + CRLF // "O fornecedor informado nใo existe."
			lMsErroAuto	:= .T.
			lRet 			:= .F.
		EndIf
	Endif

EndIf

//--------------------------------------------------
// Pagamento Automแtico.
//--------------------------------------------------
If nOper == 1
	// O valor a pagar para cada documento deve ser menor ou igual ao saldo do documento
	lRet := .T.
	If aCabOP[4][2] == "1"
		For nX	:= 1 To Len( aDocPg )
			SE2->(DbGoto(aDocPg[1,nX,8,2]))
			If aDocPg[1][nX][9][2] > 0
				If	(aDocPg[1][nX][9][2] > SE2->E2_SALDO)
					cTxtRotAut		+= SE2->E2_NUM + ":  " + STR0390 + CRLF + CRLF // "o valor informado para este documento ้ maior que o seu saldo."
					lMsErroAuto 	:= .T.
					lRet 			:= .F.
				EndIf
			Else
				cTxtRotAut		+= Alltrim(STR0237) + " " + SE2->E2_NUM + ":  " + STR0164 + CRLF + CRLF // "Inf.Valor por Pagar "
				lMsErroAuto 	:= .T.
				lRet 			:= .F.
			Endif
		Next nX
	EndIf

	//-------------------------------------------------
	// Se o tipo de pagamento da OP for Tํtulos
	//-------------------------------------------------
	If aCabOP[4][2] == "1" .AND. lRet

		If nTamFormaPg > 0

			For nX := 1 To Len( aFormaPg[1] )

				If aFormaPg[1][nX][6][2] != Nil .AND. !lMsErroAuto

					cMoeda := aFormaPg[1][nX][6][2]

					If cMoeda == 1
						nVlDocProp += aFormaPg[1][nX][5][2]
					Else
						nVlDocProp += xMoeda( aFormaPg[1][nX][5][2], cMoeda, 1, nDate )
					EndIf

				Else

					cTxtRotAut		+= STR0395 + CRLF + CRLF // "Moeda do tํulo nใo informada."
					lMsErroAuto	:= .T.
					lRet 			:= .F.

				EndIf

			Next nX

		EndIf

		If nTamDocPg > 0

			For nX := 1 To Len( aDocPg[1] )

				If aDocPg[1][nX][10][2] != Nil .AND. lRet

					cMoeda := aDocPg[1][nX][10][2]
					nValor := aDocPg[1][nX][9][2] + aDocPg[1][nX][11][2] + aDocPg[1][nX][12][2] - aDocPg[1][nX][13][2]

					// Se tipo do documento pertencer a MVPAGANT ou MV_CPNEG o valor ้ subtraido.
					If aDocPg[1][nX][7][2] $  MVPAGANT+"/"+MV_CPNEG
						If cMoeda == 1
							nVlDocPg -= nValor
						Else
							nVlDocPg -= xMoeda( nValor, cMoeda, 1, nDate )
						EndIf
					Else
						If cMoeda == 1
							nVlDocPg += nValor
						Else
							nVlDocPg += xMoeda( nValor, cMoeda, 1, nDate )
						EndIf
					EndIf

					aAdd( aRecnoSE2,	{aDocPg[1][nX][1][2],;	// Filial
										 aDocPg[1][nX][2][2],;	// Fornecedor
										 aDocPg[1][nX][3][2],;	// Filial do Fornecedor
										 aDocPg[1][nX][4][2],;	// Prefixo
										 aDocPg[1][nX][5][2],;	// N๚mero
										 aDocPg[1][nX][6][2],;	// Parcela
										 aDocPg[1][nX][7][2],;	// Tipo
										 aDocPg[1][nX][8][2],;	// Registro
										 0,;// Valor da POP
										 "",;
										 "",;
										 "",;
										 "",;
										 "",;
										 "",;
										 "",;
										 ""})	
				Else

					cTxtRotAut		+= STR0396 + CRLF + CRLF // "Nใo foi informado a moeda do documento ser pago."
					lMsErroAuto	:= .T.
					lRet 			:= .F.

				EndIf

			Next nX

		Else

			cTxtRotAut		+= STR0397 + CRLF + CRLF // "Nใo foi informado dado de tํtulo."
			lMsErroAuto	:= .T.
			lRet 			:= .F.

		EndIf

		// Valor total dos documentos proprios e de terceiro.
		nValDocs := nVlDocProp + nVlDocTer
/*
		If nValDocs < nVlDocPg .AND. lRet
			cTxtRotAut		+= STR0398 + CRLF + CRLF // "O valor do documento para pagamento nใo pode ser menor do que o valor do documento a ser pago."
			lMsErroAuto	:= .T.
			lRet 			:= .F.
		EndIf
*/
	//---------------------------------------------------
	// Se for o tipo de pagamento for da OP for Pr้-Ordem
	//---------------------------------------------------
	ElseIf aCabOP[4][2] == "2" .AND. lRet

		If nTamDocPg > 0
			FJK->( DbSetOrder( 1 ) )
			FJL->( DbSetOrder( 2 ) )
			SE2->( DbSetOrder( 1 ) )
			nX := 0
			While nX < Len(aDocPg[1]) .And. lRet
				nX++
				cFilFJK := xFilial("FJK",aDocPg[1][nX][1][2])
				If FJK->( MsSeek(cFilFJK + PadR( aDocPg[1][nX][2][2], TAMSX3( "FJK_FORNEC" )[1] ) + PadR( aDocPg[1][nX][3][2], TAMSX3( "FJK_LOJA" )[1] ) + PadR( aDocPg[1][nX][4][2], TAMSX3( "FJK_PREOP" )[1] ) ) )
					If FJL->( MsSeek( xFilial( "FJL" ) + FJK->FJK_PREOP))
						While !( FJL->( Eof() ) ) .And. (FJL->FJL_FILIAL == xFilial("FJL")) .And. (FJL->FJL_FORNEC == FJK->FJK_FORNEC) .And. (FJL->FJL_LOJA == FJK->FJK_LOJA) .And. (FJL->FJL_PREOP ==  FJK->FJK_PREOP)
							If SE2->( MsSeek( xFilial( "SE2" ) + PadR( FJL->FJL_PREFIX, TAMSX3( "E2_PREFIXO" )[1] ) + PadR( FJL->FJL_NUM, TAMSX3( "E2_NUM" )[1] ) + PadR( FJL->FJL_PARCEL, TAMSX3( "E2_PARCELA" )[1] ) + PadR( FJL->FJL_TIPO, TAMSX3( "E2_TIPO" )[1] ) + PadR( FJL->FJL_FORNEC, TAMSX3( "E2_FORNECE" )[1] ) + PadR( FJL->FJL_LOJA, TAMSX3( "E2_LOJA" )[1] ) ) )
								aAdd( aRecNoSE2,	{SE2->E2_FILIAL,;
													 SE2->E2_FORNECE,;
													 SE2->E2_LOJA,;
													 SE2->E2_PREFIXO,;
													 SE2->E2_NUM,;
													 SE2->E2_PARCELA,;
													 SE2->E2_TIPO,;
													 SE2->(RecNo()),;
													 FJL->FJL_VLRPRE,;
													 FJK->FJK_FORNEC,;
													 FJK->FJK_LOJA,;
													 "",;
													 "",;
													 "",;
													 "",;
													 FJK->FJK_PREOP})
							Endif
							FJL->(DbSkip())

						Enddo
					Else
						cTxtRotAut		+= Alltrim(STR0399) + ": " + aDocPg[1][nX][4][2] + CRLF + CRLF // "Iten da pr้-ordem de pago informada nใo existe."
						lMsErroAuto	:= .T.
						lRet 			:= .F.
					Endif
				Else
					cTxtRotAut		+=  AllTrim(STR0400) + ": " + aDocPg[1][nX][4][2]  + CRLF + CRLF // "Pr้-ordem de pago informada nใo existe."
					lMsErroAuto		:= .T.
					lRet 			:= .F.
				EndIf
			Enddo
		Else
			cTxtRotAut		+= STR0401 + CRLF + CRLF // "Nใo foi informado dado de pr้-ordem de pago."
			lMsErroAuto	:= .T.
			lRet 			:= .F.
		EndIf
	EndIf

	SA2->( RestArea( aAreaSA2 ) )
	SE2->( RestArea( aAreaSE2 ) )
	FJK->( RestArea( aAreaFJK ) )
	FJL->( RestArea( aAreaFJL ) )


	If lRet

		F850SE2(@aSE2, , , aRecNoSE2,.T.) // 5บ parametro define que ้ rotina automแtica.
		
		If aCabOP[4][2] == "1"
			For nX := 1 To Len(aDocPg[1])
				If aDocPg[1][nX][8][2] == aSE2[1][1][nX][_RECNO]
					// Atualizar os valores na aSE2, sendo que: valor a pagar = valor informado + juros + multa – desconto.
					aSE2[1][1][nX][_PAGAR] := aDocPg[1][nX][9][2] + aDocPg[1][nX][11][2] + aDocPg[1][nX][12][2] - aDocPg[1][nX][13][2]
				EndIf
			Next nX
		Endif

		F850Ordens(@aSE2)
		
		RateioCond(@aRateioGan)

		//F850Recal(@aSE2,@aRateioGan , .T.)

		If nTamFormaPg	 > 0
			//adicionar para cada elemeto da aFormaPg[1][n] Dois elementos nElemeto1 := 0 e lElemento2 := .F.
			For nX := 1 To Len( aFormaPg[1] )
					aAdd(aSE2[1][3][2],	{	aFormaPg[1][nX][1][2],;			// Tipo
												aFormaPg[1][nX][2][2],;		// Prefixo
												aFormaPg[1][nX][3][2],;		// N๚mero
												aFormaPg[1][nX][4][2],;		// Parcela
												aFormaPg[1][nX][5][2],;		// Valor
												aFormaPg[1][nX][6][2],;		// Moeda
												aFormaPg[1][nX][7][2],;		// Emissใo
												aFormaPg[1][nX][8][2],;		// Vencimento
												aFormaPg[1][nX][9][2],;		// Banco
												aFormaPg[1][nX][10][2],;	// Ag๊ncia
												aFormaPg[1][nX][11][2],;	// Conta
												aFormaPg[1][nX][12][2],;	// Talใo
												aFormaPg[1][nX][13][2],;	// Tipo do talใo
												0,;
												aFormaPg[1][nX][5][2]})
			Next nX
		EndIf

		If nTamFormaPg	 > 1 .AND. !cOpcElt
			//adicionar para cada elemeto da aFormaPg[2][n] Tres elementos nElemeto1 := 0, nElemeto2 := 0 e lElemento3 := .F.
			For  nX := 1 To Len( aFormaPg[2] )
				aAdd(aSE2[1][3][3],	{	aFormaPg[2][nX][1][2],;			// Tipo
										aFormaPg[2][nX][2][2],;			// Prefixo
										aFormaPg[2][nX][3][2],;			// N๚mero
										aFormaPg[2][nX][4][2],;			// Parcela
										aFormaPg[2][nX][5][2],;			// Emissใo
										aFormaPg[2][nX][6][2],;			// Vencimento
										aFormaPg[2][nX][7][2],;			// Valor
										aFormaPg[2][nX][8][2],;			// Moeda
										aFormaPg[2][nX][9][2],;			// C๓digo
										aFormaPg[2][nX][10][2],;		// Loja
										aFormaPg[2][nX][11][2],;		// Registro
										aFormaPg[2][nX][12][2],;		// Registro (cheque)
										.F.})
											
											
			Next nX
		EndIf

		lRet	:=	F850VldOPs(@aSE2, , .T.)
	EndIf

//--------------------------------------------------
// Pagamento Antecipado.
//--------------------------------------------------
ElseIf nOper == 2

	
	//adicionar para cada elemeto da aFormaPg[1][n] Dois elementos nElemeto1 := 0 e lElemento2 := .F.
	If nTamFormaPg	 > 0
		For nX := 1 To Len( aFormaPg[1] )

			aAdd(aSE2, {{},{},{4,{/*documentos pr๓prios*/},{/*documentos de terceiros*/},0,0,0,1},{},.F.})

			aAdd(aSE2[nX][3][2],	{	aFormaPg[1][nX][1][2],;	// Tipo
										aFormaPg[1][nX][2][2],;	// Prefixo
										aFormaPg[1][nX][3][2],;	// N๚mero
										aFormaPg[1][nX][4][2],;	// Parcela
										aFormaPg[1][nX][5][2],;	// Valor
										aFormaPg[1][nX][6][2],;	// Moeda
										aFormaPg[1][nX][7][2],;	// Emissใo
										aFormaPg[1][nX][8][2],;	// Vencimento
										aFormaPg[1][nX][9][2],;	// Banco
										aFormaPg[1][nX][10][2],;	// Ag๊ncia
										aFormaPg[1][nX][11][2],;	// Conta
										aFormaPg[1][nX][12][2],;	// Talใo
										aFormaPg[1][nX][13][2],;	// Tipo do talใo
										0,;
										aFormaPg[1][nX][5][2]})
		Next nX
	EndIf

	If nTamFormaPg	 > 1 .AND. !cOpcElt
		//adicionar para cada elemeto da aFormaPg[2][n] Tres elementos nElemeto1 := 0, nElemeto2 := 0 e lElemento3 := .F.
		For nX := 1 To Len( aFormaPg[2] )
			aAdd(aSE2[1][3][3],	{	aFormaPg[2][nX][1][2],;	// Tipo
										aFormaPg[2][nX][2][2],;	// Prefixo
										aFormaPg[2][nX][3][2],;	// N๚mero
										aFormaPg[2][nX][4][2],;	// Parcela
										aFormaPg[2][nX][5][2],;	// Emissใo
										aFormaPg[2][nX][6][2],;	// Vencimento
										aFormaPg[2][nX][7][2],;	// Valor
										aFormaPg[2][nX][8][2],;	// Moeda
										aFormaPg[2][nX][9][2],;	// C๓digo
										aFormaPg[2][nX][10][2],;	// Loja
										aFormaPg[2][nX][11][2],;	// Registro
										aFormaPg[2][nX][12][2],;	// Registro (cheque)
										aFormaPg[2][nX][7][2]})
		Next nX

	EndIf

	If lRet
		lRet := F850VldRet(2,cFornece,,,,@nRet,nValor,nLiquido,,aSE2,cLoja,cCF,cProv,,nRetIB,cZnGeo,nGrpSus,nTotAnt,,nRetIVA,,nRetSuss,nBaseRIE,nAliqRIE,/*nAliqIGV*/,,/*nBaseIGV*/,.T.)
	EndIf
	If lRet
		lRet := F850CmplPA(aSE2,cFornece,cLoja,,nValor,nLiquido,@nRet,nRetIb,nRetIva,nRetSuss,nRetIR,nRetRIE,nRetIGV,.T.)
	EndIf
	If lRet
		lRet := F850VldOPs(aSE2, .T., .T.)
	EndIf
	If lRet
		lRet := F850VldMD(1,cNatureza,cMod,,.T.)
	EndIf

EndIf
 
If lRet
	F850Grava(aSE2,(nOper == 2),,,@nFlagMOD,@nCtrlMOD,cSolFun,.T.)
Else
	lMsErroAuto := .T.
EndIf


Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850TxMoed บAutor  ณTotvs              บ Data ณ  27/08/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializar Array com as cotacoes e Nomes de Moedas segundo บฑฑ
ฑฑบ          ณo arquivo SM2                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850ATxMoe()

Local nC := MoedFin()
Local nA := 0
Local aTxMoedas := {}
Local cMoedaTx	:= ""

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณA moeda 1 e tambem inclusa como um dummy, nao vai ter uso,            ณ
//ณmas simplifica todas as chamadas a funcao xMoeda, ja que posso        ณ
//ณpassara a taxa usando a moeda como elemento do Array atxMoedas        ณ
//ณExemplo xMoeda(E1_VALOR,E1_MOEDA,1,dDataBase,,aTxMoedas[E1_MOEDA][2]) ณ
//ณBruno - Paraguay 25/07/2000                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
//Inicializar Array com as cotacoes e Nomes de Moedas segundo o arquivo SM2
Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
For nA	:=	2	To nC
	cMoedaTx	:=	Str(nA,IIf(nA <= 9,1,2))
	If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
		Aadd(aTxMoedas,{GetMv("MV_MOEDA"+cMoedaTx),RecMoeda(dDataBase,nA),PesqPict("SM2","M2_MOEDA"+cMoedaTx) })
	Else
		Exit
	Endif
Next

Return aTxMoedas
