#Include "Protheus.ch"  
#DEFINE _DEBUG   .F.   // Flag para Debuggear el codigo
#DEFINE _NOMIMPOST 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _TES_CFO   10
#DEFINE _RATEOFRET 11
#DEFINE _IMPFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IMPGASTOS 14                  
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Progr0ma  |M460IRAE  ³ Autor ³RENATO NAGIB           ³ Data ³09.08.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao da base, aliquota e calculo do IRAE              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³               VALOR DE CALCULO                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cCalculo -> Solicitacao da MATXFIS, podendo ser A (aliquota)³±±
±±³          ³ B (base) ou V (valor)                                      ³±±
±±³          ³nItem -> Item do documento fiscal                           ³±±
±±³          ³aInfo -> Array com a seguinte estrutura: {cCodImp,nCpoLVF}  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function M460IRAE(cCalculo,nItem,aInfo)
	
Local lXFis,xRet
	
lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")
If lXfis
	xRet:=M460IRAEN(cCalculo,nItem,aInfo)
Else
	xRet:=M460IRAEA()
Endif

Return (xRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Progr0ma  |M460IRAEN ³ Autor ³RENATO NAGIB           ³ Data ³09.08.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao da base, aliquota e calculo do IRAE              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³               VALOR DE CALCULO                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cCalculo -> Solicitacao da MATXFIS, podendo ser A (aliquota)³±±
±±³          ³ B (base) ou V (valor)                                      ³±±
±±³          ³nItem -> Item do documento fiscal                           ³±±
±±³Alteracao ³ 															  ³±±
±±³Camila    ³ Implementacao do acumulado e verificação do mínimo		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function M460IRAEN(cCalculo,nItem,aInfo)

Local lCalcula:=.T.                     
Local nDesconto,nBase,nAliq,nOrdSFC,nRegSFC,nVRet,nMoeda,nTaxaMoed,nBaseAtu,nI
Local cImpIncid := ""
Local aValRet 
Local aImpRef
Local lRet, cGrpIRAE
Private clTipo	:= "" 

nBase:=0
nAliq:=0
nDesconto:=0
nVRet:=0
cGrpIRAE:=""
lRet:=.F.


SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,")
SetPrvt("CCLASCLI,CCLASFORN,CMVAGENTE,NPOSFORN,NPOSLOJA,NTOTBASE,LRETCF")
	
If FunName() $ "MATA101N|MATA466N|MATA121" 
	If SA2->A2_RETIRAE <> 'S' .Or. !SA2->A2_TIPO $ "1|2"
		lCalcula:=.F.
	EndIf
Else
	If SA1->A1_RETIRAE <> 'S' .Or. !SA1->A1_TIPO $ "1|2"
		lCalcula:=.F.
	EndIf
EndIf 

If lCalcula
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])		
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
				If SFC->FC_LIQUIDO=="S"
					nDesconto:=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif
			Endif
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
			nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			nBase-=nDesconto
			nAliq:=SFB->FB_ALIQ		
			lRet := .F.  
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`¿
			//³Verifica se tem imposto incidente e soma o valor do mesmo na base de cálculo do IRAE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`Ù
			If !Empty(cImpIncid)
			   aImpRef:=MaFisRet(nItem,"IT_DESCIV")
			   aImpVal:=MaFisRet(nItem,"IT_VALIMP")
			   For nI:=1 to Len(aImpRef)
			       If !Empty(aImpRef[nI])
				      IF Trim(aImpRef[nI][1])$cImpIncid
					     nBase+=aImpVal[nI]
				      Endif
				   Endif
			   Next	
			Endif				
			
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())
			If FieldPos("B1_GRPIRAE")>0     
				If DbSeek(xFilial("SB1") + AvKey(MaFisRet(nItem,"IT_PRODUTO"),"B1_COD") )
					cGrpIRAE:=SB1->B1_GRPIRAE
					DbSelectArea("SFF")
					SFF->(DbSetOrder(9))
					SFF->(DbGoTop())
					If DbSeek(xFilial("SFF") + AvKey(aInfo[X_IMPOSTO],"FF_IMPOSTO") + AvKey(cGrpIRAE,"FF_GRUPO"))
						nAliq:=SFF->FF_ALIQ
						lRet := .T.
					Endif		
				Endif
			Endif						
	Endif 
EndIf
If lRet  								
	Do Case
		Case cCalculo=="B"
			nVRet:=nBase
		Case cCalculo=="A"
			nVRet:=nAliq
		Case cCalculo=="V"            		
			//nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			//nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			
			cEspecie:=IIF(Type("M->F1_ESPECIE")<>"U",M->F1_ESPECIE,M->F2_ESPECIE)
			 			
			If Subs(cEspecie,1,2)=="NC"
			   	nTaxaMoed := 0
				nMoeda := 1
			   	If Type("M->F1_MOEDA")<>"U" 			   	
				    nMoeda := M->F1_MOEDA
				    nTaxaMoed := M->F1_TXMOEDA
				ElseIf Type("M->C7_MOEDA")<>"U"
					nMoeda := M->C7_MOEDA
				    nTaxaMoed := M->C7_TXMOEDA				
		        ElseIf Type("M->F2_MOEDA")<>"U"
		        	nMoeda := M->F2_MOEDA
				    nTaxaMoed := M->F2_TXMOEDA				
				ElseIf Type("M->C5_MOEDA")<>"U" 
					nMoeda := M->C5_MOEDA
				    nTaxaMoed := M->C5_TXMOEDA				
		        EndIf	        
		        nBaseAtu := xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed) 
		        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   	   		//³Verifica o valor das retenções e base de IR acumulados ³
	   	   		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÙ			
		   		aValRet := RetValIR("IRA")
				//aValRet[01] = base acumulada
		   		//aValRet[02] = retencao acumulada  								     
				If (aValRet[1]-nBaseAtu) <= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)			
					nVret := xMoeda(aValRet[2],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)		   		
				Else
					nVret := nBase*(nAliq/100)
				EndIF					
			Else 
				nVRet:=nBase * (nAliq/100)
			EndIf 	
		EndCase
Endif  
	
/*If lCalcula 
/*
	If cCalculo == 'B'
		nBase:=MaFisRet(nItem,"IT_VALMERC") - MaFisRet(nItem,"IT_DESCONTO") 
		xRet:=nBase
	Else
		dbSelectArea('SFB')
		dbSetOrder(1)
		If dbSeek(xFilial('SFB')+aInfo[1])
			nAliq:=SFB->FB_ALIQ
		EndIf
			
		dbSelectArea('SFF')
		dbSetOrder(9)
		If dbSeek(xFilial('SFF') + AvKey(aInfo[1],'FF_IMPOSTO') + AvKey(POSICIONE('SB1',1,xFilial('SB1')+AvKey(MaFisRet(nItem,'IT_PRODUTO'),'B1_COD'),'B1_GRPIRAE'),'FF_GRUPO'))
			nAliq:=SFF->FF_ALIQ
		EndIf
			
		If cCalculo == 'V'				
         	nValImp:=(((MaFisRet(nItem,"IT_VALMERC") - MaFisRet(nItem,"IT_DESCONTO") ) * nAliq) / 100)
	    	xRet:=nValImp	
		ElseIf cCalculo == 'A'
			xRet:=nAliq
		EndIf				 	
	EndIf 
EndIf  
	   */
Return (nVRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Progr0ma  |M460IRAEA ³ Autor ³RENATO NAGIB           ³ Data ³09.08.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao da base, aliquota e calculo do IRAE              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³               VALOR DE CALCULO                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cCalculo -> Solicitacao da MATXFIS, podendo ser A (aliquota)³±±
±±³          ³ B (base) ou V (valor)                                      ³±±
±±³          ³nItem -> Item do documento fiscal                           ³±±
±±³          ³aInfo -> Array com a seguinte estrutura: {cCodImp,nCpoLVF}  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function M460IRAEA()

	Local aItem:=ParamIxb[1]
	Local aImp :=ParamIxb[2] 
	Local nBase
	Local nAliq

	dbSelectArea('SFB')
	dbSetOrder(1)
	If dbSeek(xFilial('SFB')+AvKey(aImp[1],'FC_IMPOSTO') )
		nAliq:=SFB->FB_ALIQ
	EndIf
	
	dbSelectArea('SFF')
	dbSetOrder(9)
	If dbSeek(xFilial('SFF') + AvKey(aImp[1],'FF_IMPOSTO') + AvKey(POSICIONE('SB1',1,xFilial('SB1')+AvKey(aImp[16],'B1_COD'),'B1_GRPIRAE'),'FF_GRUPO'))
	//If dbSeek(xFilial('SFF') + aInfo[1] + POSICIONE('SB1',1,xFilial('SB1')+MaFisRet(nItem,'IT_PRODUTO'),'B1_GRPIRAE'))
		nAliq:=SFF->FF_ALIQ
	EndIf

	nBase:=aItem[3]+aItem[4]-aItem[5] //valor total + frete - Descontos
	aImp[02]:=nAliq
	aImp[03]:=nBase
	aImp[04]:=(nAliq * nBase)/100   
	
Return (aImp)
