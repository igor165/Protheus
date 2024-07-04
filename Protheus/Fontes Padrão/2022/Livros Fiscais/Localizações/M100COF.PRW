#DEFINE _NOMEIMPOS 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _RATEODESP 13
#DEFINE _IMPGASTOS 14
#DEFINE _IMPFLETE  12
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M100COF  ³ Autor ³ Lucas                  ³ Data ³ 06.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Imposto C.O.F.I.S para o Uruguay...			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP5			                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Lucas        ³06/06/01³      ³Inicio...					                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100COF(cCalculo,nItem,aInfo)
Local aItemINFO
Local xRet,lXFis
Local aDespesas:={}
Local cImpIncid
Local cTec:=	""
Local nE,nI,nOrdSFC,nRegSFC
Local aImpRef,aImpVal
Local aArea		:=	GetArea()
Local aAreaSA1 :=	SA1->(GetArea())
Local lCalcula	:=	.T.

lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
// .T. - metodo de calculo utilizando a matxfis
// .F. - metodo antigo de calculo

If !lXFis
	aItemINFO:=ParamIxb[1]
	xRet:=AClone( ParamIxb[2] )
	cImpIncid:=xRet[10]
	If Len(ParamIxb[1]) >= 8
		cTec:=ParamIxb[1][8]
	Endif
	If Len(ParamIxb[1]) >= 9
		aDespesas	:=	ParamIxb[1][9]
	Endif              
	If cModulo $ "FRT|OMS|LOJ|FAT"
		If Empty(SA1->A1_CGC)
			lCalcula	:=	.F.
		Endif	
	Endif	
Else
	xRet:=0
	cImpIncid:=""
	If MaFisRet(,'NF_CLIFOR')=='C'
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(xFilial()+MaFisRet(,'NF_CODCLIFOR')+MaFisRet(,'NF_LOJA')))
		If Empty(SA1->A1_CGC)
			lCalcula	:=	.F.
		Endif	
	Endif	
Endif    
If lCalcula
If !lXFis
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obter Base de C lculo e Al¡quota dos Impostos.				     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obs: No Uruguay temos uma alicuota de IVA de 14% ou 23% esta ³
	//³ realiconada con base na Classifica‡Æo de Produtos e ser      ³
	//³ inicializada atraves de Gatilhos disparado na GetDados.		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xRet[_RATEOFRET] := aItemINFO[_FLETE]      // Rateio do Frete
	xRet[_RATEODESP] := aItemINFO[_GASTOS]     // Rateio de Despesas
	xRet[_BASECALC]  := aItemINFO[_VLRTOTAL]+aItemINFO[_FLETE]+aItemINFO[_GASTOS] // Base de Cálculo
	
	If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) == 18 .And. ValType(xRet[18])=="N"
		xRet[_BASECALC] -= xRet[18]
	EndIf
	xRet[_ALIQUOTA] := SFB->FB_ALIQ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Soma base dos impostos incidentes...							     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nI := At( ";",cImpIncid )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	While nI > 1
		nE := AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
		If nE > 0
			xRet[3] := xRet[3]+aItemINFO[6,nE,4]
		EndIf
		
		cImpIncid := Stuff( cImpIncid,1,nI,"" )
		nI := At( ";",cImpIncid )
		nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	End
	For nE	:=	1	To Len(aDespesas)
		If At("IVA",aDespesas[nE][3]) > 0
			xRet[_BASECALC] += aDespesas[nE][2]
		Endif
	Next nE
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua o Calculo do imposto...									     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xRet[_IMPUESTO]  := ROUND(xRet[_BASECALC] * xRet[_ALIQUOTA]/100,2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua o Calculo do Imposto sobre Frete                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//xRet[_IMPFLETE]  := ROUND(xRet[_RATEOFRET] * xRet[_ALIQUOTA]/100,2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua o Calculo do Imposto sobre Despesas                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//xRet[_IMPGASTOS] := ROUND(xRet[_RATEODESP] * xRet[_ALIQUOTA]/100,2)
Else
	Do Case
		Case cCalculo=="A"
			SFB->(DbSeek(xFilial("SFB")+aInfo[X_IMPOSTO]))
			xRet:=SFB->FB_ALIQ
		Case cCalculo=="B"
			xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			//Tira os descontos se for pelo liquido
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
				If SFC->FC_LIQUIDO=="S"
					xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif
			Endif
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
            //+---------------------------------------------------------------+
	        //¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
	        //+----------------------------------------------------------Lucas+
	        aImpRef:=MaFisRet(nItem,"IT_DESCIV")
	        aImpVal:=MaFisRet(nItem,"IT_VALIMP")
	        nI := At( cImpIncid,";" )
	        nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	        While nI > 1
		          nE:= AScan( aImpRef,{|x| x[1] == Left(cImpIncid,nI-1) } )
		          If nE> 0
			         xRet+=aImpVal[nE]
			      Endif
		          cImpIncid := Stuff( cImpIncid,1,nI )
		          nI := At( cImpIncid,";" )
 		          nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	        End
		Case cCalculo=="V"
			nE:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			nI:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			xRet:=(nE * nI)/100
	EndCase
Endif
EndIf

RestArea(aAreaSA1)	
RestArea(aArea)

Return( xRet )
