#INCLUDE "Protheus.ch"
#DEFINE _NOMEIMPOS 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _IVAFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM100ISR   บAutor  ณCamila Januแrio     บ Data ณ  13/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cแlculo do ISR - Impuesto Sobre la Renta                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Rep. Dominicana                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function M100ISR(cCalculo,nItem,aInfo)

Local nBase    := 0
Local nAliq    := 0 
Local nOrdSFC  := 0
Local nRegSFC  := 0
Local cGrupo   := ""
Local cEstado  := ""
Local cProduto := ""
Local aItem    := {}
Local lXfis    := .F.
Local lAliq    := .F.
Local cAgente  := GETMV("MV_AGENTE")
Local nReduc   := 0
Local cTpCliFor := ""
Local lClient:= .F.

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

If !lXFis
	aItem    := ParamIxb[1]
	xRet     := ParamIxb[2]
	cProduto := xRet[16]
	cImp     := xRet[1]
Else
	xRet     := 0
	cProduto := MaFisRet(nItem,"IT_PRODUTO")
	cImp     := aInfo[X_IMPOSTO]
EndIf

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto))	
	cGrupo  := SB1->B1_CONISR
EndIf

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAlํquota padrใo cadastrada na tabela de impostos ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
If !lAliq
	dbSelectArea("SFB")
	SFB->(dbSetOrder(1))
	If SFB->(dbSeek(xFilial("SFB")+cImp))
		nAliq := SFB->FB_ALIQ
		lAliq := .T.
	Endif		
EndIf

If  Substr(cModulo,1,3) $ 'FAT|OMS|LOJ|FRT|TMK"
	lClient:= .T.
EndIf


If lClient
	cTpCliFor := SA1->A1_TIPO
Else
	cTpCliFor := SA2->A2_TIPO
EndIF		

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณCaso exista cadastro do imposto na tabela de conceitosฤฤ 
//	entใo a aliquota serแ da tabela de conceitos CCRณ    ฤฤ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ*/
	
dbSelectArea("CCR")
CCR->(dbSetOrder(2))	
If CCR->(dbSeek(xFilial("CCR")+cImp+cTpCliFor+cGrupo))		
	/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAlํquota pode ser diferenciada se a pessoa ้ domiciliada  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/		
	If cEstado <> "EX"
		nAliq := CCR->CCR_ALIQ
	Else			
	    nAliq := CCR->CCR_ALIREX
	EndIf 
	If CCR->CCR_REDUC > 0
		nReduc := CCR_REDUC
	EndIf	
EndIf

If Substr(cAgente,2,1)=="S"
	If !lXFis
		nBase:=aItem[3]+aItem[4]+aItem[5] //valor total + frete + outros impostos
		xRet[02]:=nAliq
		xRet[03]:=nBase
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
			xRet[3]-=xRet[18]
			nBase:=xRet[3]
		Endif
		nBase:=nBase-((nBase*nReduc)/100) //base reduzida
		xRet[04]:=(nAliq * nBase)/100
	Else
		Do Case
			Case cCalculo=="B"
				xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
				//Tira os descontos se for pelo liquido
				nOrdSFC:=(SFC->(IndexOrd()))
				nRegSFC:=(SFC->(Recno()))
				SFC->(DbSetOrder(2))
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
					If SFC->FC_LIQUIDO=="S"
						xRet-=MaFisRet(nItem,"IT_DESCONTO")
					Endif
				Endif
				xRet:=xRet-((xRet*nReduc)/100) //base reduzida			
				SFC->(DbSetOrder(nOrdSFC))
				SFC->(DbGoto(nRegSFC))
			Case cCalculo=="A"
				xRet:=nALiq
			Case cCalculo=="V"
				nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
				nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				xRet:=(nAliq * nBase)/100
			EndCase
	EndIf
EndIf
Return xRet