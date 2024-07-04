#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#INCLUDE "M100RIVA.CH"
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100RIVA  ºAutor  ³Julio Cesar         º Data ³  19/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retencao de IVA                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador³ Data   ³ BOPS ³  Motivo da Alteracao                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºARodriguez ³31/07/19³DMINA-³M100RIVAFCO() toma CFO de MaFisRet() COL	  º±±
±±º           ³        ³  6748³											  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M100RIVA(cCalc,nIt,aInf)

LOCAL cFunct
LOCAL aRet,lXFis
LOCAL aCountry // Array de Paises nesta forma : // { { "BRA" , "Brasil", "BR" } , { "ARG" , "Argentina","AR"} ,
LOCAL aArea := GetArea()

lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")

aCountry := GetCountryList()
cFunct	:= "M100RIVA" + aCountry[Ascan( aCountry, { |x| x[1] == cPaisLoc } )][3] // retorna pais com 2 letras
aRet    := &(cFunct)(cCalc,nIt,aInf,lXFis)

RestArea( aArea )

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100RIVACOºAutor  ³Denis Martins       º Data ³  02/17/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao de IVA - Esse imposto e calculado sobre º±±
±±º          ³o Imposto de Valor Agregado                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M100RIVACO(cCalculo,nItem,aInfo,lXFis)
Local nC := 0
Local nBaseTot := 0
Local llRetIVA	:= .T. 
Local lRetMin   := .F.
Local clAgen	:= GetMV("MV_AGENTE")
Local nPosCFO

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,CMODULO,CTIPOFORN,CCFO")
SetPrvt("NC,NVLIMPOSTOIVA,LRET,CZONFIS,CTIPOCONTR,CRETIVA,CTIPOEMPR,NBASE,LRETCF")

If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif

lRetCF := .T.                               
lRet := .F.
cZonFis := ""
nVlImpostoIVA := 0
nBase := 0

If cModulo $ 'COM|EIC'
	cTipoCliFor:= IIf(cPaisLoc == "COL" , SA2->A2_PESSOA, ' ')
	cTipoContr := SA2->A2_CONTRBE
	cRetIVA	   := UPPER(SubStr(clAgen,1,1))
Else
	cTipoCliFor:= SA1->A1_PESSOA
	cTipoContr := SA1->A1_CONTRBE
	cRetIVA	   := SA1->A1_RETIVA
Endif

cTipoEmpr := GetMV("MV_CLASSIF") // Tipo de Classificacao da Empresa
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se e Persona Tipo Natural                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//3. Se o proveedor é "Gran Contribuyente" somente pode reter fuente, não pode reter IVA.
/*
If cModulo $ 'COM|EIC'
	//If cTipoCliFor == "F" .OR. cTipoContr == "1"   //P.Fisica ou Gran Contrib
	If cTipoContr == "1"   // Gran Contrib
		lRetCF := .F.
	EndIf
EndIf

*/
If cRetIVA == "S"
	lRet := .T.
EndIf

If lRet .And. lRetCF
	If lXFis
		xRet:=M100RIVAFCO(cCalculo,nItem,aInfo)
	Else
	
		If cModulo$'COM'
			If SubStr(clAgen,1,1) != "S"
				llRetIVA	:= .F.
			EndIf
		ElseIf cModulo$'FAT'
			If SA1->A1_AGENRET != '1'
				llRetIVA	:= .F.
			EndIf
		EndIf
		
		If llRetIVA
			dbSelectArea("SF4")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³           Busca o CFO correspondente do documento                   ³
			//³                                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Ha 1 problema com deleção de linha, a matriz fiscal está realterando todas as linhas 
			//com o CFO origem da TES para as linhas com a mesma TES da linha digitada. 
			//Este procedimento TEMPORARIO / PALIATIVO forca a alimentacao da matriz fiscal com o conteudo correto do acols.
			If (!ReadVar()$"M->D1_TES|M->D1_CF") .And. Type("ACOLS")=="A" .And. aScan(aHeader,{|x| AllTrim(x[2])+" " == "D1_CF "}) > 0
				nPosCFO := aScan(aHeader,{|x| AllTrim(x[2])+" " == "D1_CF " })
				cCFO	:= aCols[nItem][nPosCFO]
				If MaFisRet(nItem,"IT_CF") <> cCFO
					MaFisAlt("IT_CF",cCFO,nItem)
				EndIf
			Else
				cCFO := MaFisRet(nItem,"IT_CF")
			EndIf	
			//	cCFO := SC6->C6_CF 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Localiza o valor do imposto do IVA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nC:=1 To Len(aItemInfo[6])
				If Substr(aItemInfo[6][nC][1],1,2) == "IV"
					nVlImpostoIVA += aItemInfo[6][nC][4]
				Endif
			Next nC			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se tem retenção de IVA na classificado na TES ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "COL" .And. SF4->F4_PRETIVA > 0
				aImposto[_ALIQUOTA] := SF4->F4_PRETIVA
			Else
				dbSelectArea("SFB")
				dbSetOrder(1)
				If dbSeek(xFilial("SFB")+aImposto[1])
					If FB_FLAG != "1"
						RecLock("SFB",.F.)
						Replace FB_FLAG With "1"
					Endif
					aImposto[_ALIQUOTA] := SFB->FB_ALIQ
				Endif
			EndIf
			
			nBaseTot := aItemINFO[3]+aItemINFO[4]+aItemInfo[5]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se tem retenção com classificação específica por CFOP  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SFF")
			dbGoTop()
			dbSetOrder(5)
			If dbSeek(xFilial("SFF") + aImposto[1] + cCFO)								
				If xMoeda(nBaseTot,nMoeda,1)>= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)					
					aImposto[_ALIQUOTA] := nAliq
					lRet 	:= .T.
					lRetMin := .T.
				Else
					lRet := .F.
				Endif 
			Endif			
			
			aImposto[_BASECALC] := nVlImpostoIVA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente calcula valor de imposto de a base de cálculo for maior que o mínimo FF_IMPORTE - lRetMIn³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet .And. lRetMin
				aImposto[_IMPUESTO]  := round(aImposto[_BASECALC] *  aImposto[_ALIQUOTA]/100,2)
			Endif			
		Endif
		xRet:=aImposto
	Endif
Endif
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100RIVAFCOºAutor  ³Denis Martins       º Data ³ 17/02/2000  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao do Imposto X Tes - Entrada               º±±
±±º          ³Alterado para o uso da funcao MATXFIS (Marcello)             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA460,MATA100                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M100RIVAFCO(cCalculo,nItem,aInfo)
	Local nVlImpostoIVA,nBase,nAliq,nAux,nOrdSFC,nRegSFC,nVal,nTotBase,nVRet
	Local nPos,cTes,cFil,nPosCFO
	Local nMoeda    := 1  
	Local nImporte  := 0 
	Local nMoedSFF  := 1 
	Local nTaxaMoed := 0
	Local nTxMoed   := 0 
	Local nMoedaPed := 1
	Local nBaseTot  := 0
	Local aRefImp
	Local llRetIVA	:= .T.
	Local clAgen	:= GetMV("MV_AGENTE")	
	nBase:=0
	nAliq:=0
	nVRet:=0
	nVlImpostoIVA:=0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a verificacao da taxa de moeda independente se for por³
	//³pedido, nota                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If Type("M->F1_MOEDA")<>"U" 
		nMoeda:= M->F1_MOEDA      
		nTaxaMoed := M->F1_TXMOEDA	
	ElseIf Type("M->C7_MOEDA")<>"U"
		nMoeda:= M->C7_MOEDA    
    	nTaxaMoed := M->C7_TXMOEDA	
	ElseIf Type("M->F2_MOEDA")<>"U" 
		nMoeda:= M->F2_MOEDA    
    	nTaxaMoed := M->F2_TXMOEDA	
	ElseIf Type("M->C5_MOEDA")<>"U"
		nMoeda:= M->C5_MOEDA      
	    nTaxaMoed := M->C5_TXMOEDA	
	ElseIf Type("nMoedaPed")<>"U" .And. Type("nTxMoeda")<>"U"
		nMoeda:= nMoedaPed         
    	nTaxaMoed := nTxMoeda
	EndIf		
	If nTaxaMoed==0
   		nTaxaMoed:= RecMoeda(nMoeda)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca o CFO informado no PC - pode ter sido alt. devido o concepto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCFO := MaFisRet(nItem,"IT_CF")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a verificacao se é agente de retencao, quando compras³
	//³ou faturamento                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cModulo$'COM'
		If SubStr(clAgen,1,1) != "S"
			llRetIVA	:= .F.
		EndIf
	ElseIf cModulo$'FAT'
		If SA1->A1_AGENRET != '1'
			llRetIVA	:= .F.
		EndIf
	EndIf
	
	If llRetIVA
		dbSelectArea("SFB")
		dbSetOrder(1)
		If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
			DbSelectArea("SFF")
			SFF->(DbSetOrder(5))
			SFF->(DbGoTop())
			If cCalculo$"BA"
				If cCalculo=="B"				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Localiza o valor do imposto do IVA³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SFB")
					DbSetOrder(1)
					DbSelectArea("SFC")
					nRegSFC:=Recno()
					nRegSFB:=SFB->(Recno())
					nOrdSFC:=IndexOrd()
					DbSetOrder(2)
					cTes:=MaFisRet(nItem,"IT_TES")
					aRefImp:=MaFisRelImp("MT100",{"SD1"})
					cFil:=xFilial("SFC")
					DbSeek(cFil+cTes+"IV")
					cAux:=Substr(FC_IMPOSTO,1,2) 					

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Faz o tratamento do imposto calculado no item ou por total da nota³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					While FC_FILIAL==cFil .And. FC_TES==cTes .And. cAux=="IV"
						If SFC->FC_CALCULO=="T"
							If MaFisRet(,'NF_BASEIV'+aInfo[2])+ MaFisRet(nItem,'IT_BASEIV'+ aInfo[2]) > MaFisRet(,"NF_MINIV"+aInfo[2])
			  		     		 nVlImpostoIVA :=MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2])) 
			  		   		Endif
						Else						
							If FC_IMPOSTO<>aInfo[X_IMPOSTO]
								If (SFB->(DbSeek(xFilial("SFB")+SFC->FC_IMPOSTO)))
									nPos:=Ascan(aRefImp,{|x| x[2]=="D1_VALIMP"+SFB->FB_CPOLVRO})
									If nPos>0
										nVlImpostoIVA += MaFisRet(nItem,aRefImp[nPos,3])
									Endif
								Endif
							Endif
						Endif	
						DbSkip()
						cAux:=Substr(FC_IMPOSTO,1,2)
					Enddo
					DbSetOrder(nOrdSFC)
					DbGoto(nRegSFC)
					SFB->(DbGoto(nRegSFB))
					nBase:=nVlImpostoIVA 					

				Else                
					If cPaisLoc == "COL"  .And. SF4->F4_PRETIVA > 0
						nAliq := SF4->F4_PRETIVA
					Else
						dbSelectArea("SFB")
						dbSetOrder(1)
						If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
							If SFB->FB_TABELA=="N"
								If FB_FLAG != "1"
						 			RecLock("SFB",.F.)
									Replace FB_FLAG With "1"
								Endif
								nAliq:=SFB->FB_ALIQ
							EndIf
						Endif							
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se tem alíquota por região na SFF³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SFF")
					SFF->(DbSetOrder(5))
					SFF->(DbGoTop())
					If DbSeek(xFilial("SFF")+AvKey(aInfo[X_IMPOSTO],"FF_IMPOSTO")+cCFO)
						nAliq := IIF(SFF->FF_ALIQ>0,SFF->FF_ALIQ,nAliq)
					Endif								
				Endif					
			Else
			
				//Tira os descontos se for pelo liquido
   				nOrdSFC:=(SFC->(IndexOrd()))
   				nRegSFC:=(SFC->(Recno()))
   				SFC->(DbSetOrder(2))
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))       
					If SFC->FC_LIQUIDO=="S"
						nDesconto:=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif
				Endif
				SFC->(DbSetOrder(2))
				SFC->(DbGoto(nRegSFC)) 
				
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
					If SFC->FC_CALCULO=="T"
				      If MaFisRet(,'NF_BASEIV'+aInfo[2])+ MaFisRet(nItem,'IT_BASEIV'+ aInfo[2]) > MaFisRet(,"NF_MINIV"+aInfo[2])
			  		      nVlImpostoIVA		:=MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2])) 
			  			Endif
			         ELSE
				        If MaFisRet(nItem,'IT_BASEIV'+aInfo[2]) >   MaFisRet(,"NF_MINIV"+aInfo[2])
			  		      	nVlImpostoIVA	:=	MaFisRet(nItem,'IT_BASEIV'+aInfo[2])   
			  			Endif
					Endif
				Endif 
				nBase := nVlImpostoIVA

				If DbSeek(xFilial("SFF")+AvKey(aInfo[X_IMPOSTO],"FF_IMPOSTO")+cCFO)
					nImporte := SFF->FF_IMPORTE
					nMoedSFF := SFF->FF_MOEDA		
				Endif	
				lRet:=.T.
			Endif
		Endif
	EndIf	
	If lRet .And. llRetIVA	
			Do Case
				Case cCalculo=="A"
					nVRet:=nAliq 
				Case cCalculo=="B"
					nVRet:=nBase 
				Case cCalculo=="V"			
					nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
					If SFC->FC_CALCULO == "I"					
						nBaseTot := (MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_SEGURO")+MaFisRet(nItem,"IT_DESPESA")) 
					Else
						nBaseTot := MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2]),.T.)-nVlImpostoIVA
					Endif						
					If xMoeda(nBaseTot,nMoeda,1,Nil,Nil,nTaxaMoed) > xMoeda(nImporte,nMoedSFF,1)		
						nVRet:=round(nBase * (nAliq/100),2)
					Else
						nVRet:=0
					Endif		
			EndCase

	Endif                               

Return(nVRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100RIVAPAºAutor  ³Julio Cesar         º Data ³  19/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao de IVA - Esse imposto e calculado sobre º±±
±±º          ³o Imposto de Valor Agregado                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Paraguay                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                    

Function M100RIVAPA(cCalculo,nItem,aInfo,lXFis)

Local  nIVAItem := 0  
Local  nMoeda 
Local  nE := 0

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,CMODULO,CTIPOFORN,CCFO")
SetPrvt("NC,NVLIMPOSTOIVA,CZONFIS,CTIPOCONTR,CRETIVA,CTIPOEMPR,NBASE,LRETCF")

cAliasRot   := Alias()
cOrdemRot   := IndexOrd()
cTipoCliFor := SA2->A2_TIPO
cRetIVA	    := SA2->A2_RETIVA
nMoeda  	:=	IIf(Type("nMoedaCor")=="U",1,nMoedaCor)  
If lxFis
	xRet := 0
Else
    xRet := ParamIxb[2]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se e Agente de Retencao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cRetIVA == "S"
	If lXFis
		xRet := M100RIVAFPA(cCalculo,nItem,aInfo,nMoeda)
	Else
		aItemINFO   := ParamIxb[1]
		aImposto    := ParamIxb[2]
		aTodosImp	:=	aClone(If(Type("aImps")=="U",aImpSD2,aImps))
		dbSelectArea("SFF")
		dbSetOrder(5)
		If dbSeek(xFilial("SFF")+aImposto[1])
			For nE := 1 To Len(aImpVarSD1[6])
				If (Substr(aImpVarSD1[6][nE][6],3,8) == "_VALIMP1")
					nIVAItem += aImpVarSD1[6][nE][4]
				Endif
			Next
			If nIvaItem > 0
				aImposto[_BASECALC] := (aItemINFO[3]+aItemINFO[4]+aItemInfo[5]) * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)
	         	//Tira os descontos se for pelo liquido .Bruno
	         	If Subs(aImposto[5],4,1) == "S"  
	            	aImposto[_BASECALC] := (aItemINFO[3]+aItemINFO[4]+aItemInfo[5]-aImposto[18]) * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)	
	         	Endif 
	         	aImposto[_ALIQUOTA] := SFB->FB_ALIQ
				If  aItemINFO[3]+aItemINFO[4]+aItemInfo[5] > SFF->FF_IMPORTE
					aImposto[_IMPUESTO] := Round(aImposto[_BASECALC] * aImposto[_ALIQUOTA]/100,MsDecimais(nMoeda))
				Endif
			Endif
			xRet := aImposto
		EndIf
	EndIf
Endif
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100RIVAFPAºAutor  ³Julio Cesar         º Data ³ 19/11/2001  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao do Imposto X Tes - Entrada               º±±
±±º          ³Para o uso da funcao MATXFIS                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA460,MATA100                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function M100RIVAFPA(cCalculo,nItem,aInfo,nMoeda)
Local nIVAItem,nBase,nAliq,nOrdSFC,nRegSFC,nOrdSFF,nRegSFF,nVRet,nDesconto
Local nPos,cTes,cFil,nRegSFB
Local aRefImp 
Local lRet     

nBase     := 0
nAliq     := 0
nVRet     := 0
nDesconto := 0
nIVAItem  := 0
lRet      := .T.

dbSelectArea("SFB")
dbSetOrder(1)
If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
	If cCalculo$"BA"
		If cCalculo=="B"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Localiza o valor do imposto do IVA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SFC")
			nRegSFC:=Recno()
			nRegSFB:=SFB->(Recno())
			nOrdSFC:=IndexOrd()
			DbSetOrder(2)
			cTes   :=MaFisRet(nItem,"IT_TES")
			aRefImp:=MaFisRelImp("MT100",{"SD1"})
			cFil   :=xFilial("SFC")
			If DbSeek(cFil+cTes+"IVA")
				If (SFB->(DbSeek(xFilial("SFB")+SFC->FC_IMPOSTO)))
					IF (nPos := Ascan(aRefImp,{|x| x[2]=="D1_VALIMP"+SFB->FB_CPOLVRO})) > 0
						nIVAItem += MaFisRet(nItem,aRefImp[nPos,3])
					Endif
				Endif
			Endif
			If nIVAItem > 0
				If DbSeek(cFil+cTes+aInfo[X_IMPOSTO])			
					nBase := (MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_SEGURO") +;
				    	     MaFisRet(nItem,"IT_DESPESA")) * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)
				    //Tira os descontos se for pelo liquido 	     
					If SFC->FC_LIQUIDO=="S"
						nDesconto := MaFisRet(nItem,"IT_DESCONTO") 
						nBase := (MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_SEGURO")+;
				    	          MaFisRet(nItem,"IT_DESPESA")-nDesconto) * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)    
					EndIf
				EndIf				            
			Endif
			DbSetOrder(nOrdSFC)
			DbGoto(nRegSFC)
			SFB->(DbGoto(nRegSFB))
		Else
			If Empty(SFB->FB_ALIQ)	
				MsgStop(OemToAnsi(STR0002))  //"Verifique a integridade do Arquivo de Impostos" 
				lRet := .F.
			Else
				nAliq := SFB->FB_ALIQ
			EndIf
		Endif
	Endif
Endif
If lRet
	Do Case
		Case cCalculo=="A"
			nVRet:=nAliq
		Case cCalculo=="B"
			nVRet:=nBase
		Case cCalculo=="V"
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			DbSelectArea("SFF")
			nRegSFF:=Recno()
			nOrdSFF:=IndexOrd()
			DbSetOrder(5)          
			cFil := xFilial("SFF")                
			If DbSeek(cFil+aInfo[X_IMPOSTO]) .and. (MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_SEGURO") +;
			   MaFisRet(nItem,"IT_DESPESA") > SFF->FF_IMPORTE)
				nVRet:= Round(nBase * nAliq/100,MsDecimais(nMoeda))
			EndIf
			DbSetOrder(nOrdSFF)
			DbGoto(nRegSFF)
	EndCase
Endif

Return(nVRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100RIVAEQ ºAutor  ³ Nilton (Onsten)   º Data ³  24/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao de IVA - Equador						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M100RIVAEQ (cCalculo,nItem,aInfo,lXFis)
Local nC := 0
Local llRetIVA	:= .T.
Local clAgen	:= GetMV("MV_AGENTE")

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,CMODULO,CTIPOFORN,CCFO")
SetPrvt("NC,NVLIMPOSTOIVA,LRET,CZONFIS,CTIPOCONTR,CRETIVA,CTIPOEMPR,NBASE,LRETCF")

If !lXFis
	aItemINFO  := ParamIxb[1]
	aImposto   := ParamIxb[2]
	xRet:=aImposto
Else
	xRet:=0
Endif

lRetCF := .T.                               
lRet := .F.
cZonFis := ""
nVlImpostoIVA := 0
nBase := 0

If lXFis
	xRet:=M100RIVAFEQ(cCalculo,nItem,aInfo)
Else
	If cModulo$'COM'
		If SubStr(clAgen,1,1) != "S"
			llRetIVA	:= .F.
		EndIf
	ElseIf cModulo$'FAT'
		If SA1->A1_AGENRET != '1'
			llRetIVA	:= .F.
		EndIf
	EndIf
		
	If llRetIVA
		dbSelectArea("SF4")
		cCFO := Alltrim(SF4->F4_CF)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Localiza o valor do imposto do IVA³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nC:=1 To Len(aItemInfo[6])
			If Substr(aItemInfo[6][nC][1],1,2) == "IV"
				nVlImpostoIVA += aItemInfo[6][nC][4]
			Endif
		Next nC
			
		dbSelectArea("SFB")
		dbSetOrder(1)
		If dbSeek(xFilial("SFB")+aImposto[1])
			aImposto[_ALIQUOTA] := SFB->FB_ALIQ
			aImposto[_BASECALC] := nVlImpostoIVA
			aImposto[_IMPUESTO]  := round(aImposto[_BASECALC] *  aImposto[_ALIQUOTA]/100,2)
		Endif			
		xRet:=aImposto
	Endif
Endif
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( xRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100RIVAFEQ ºAutor  ³Nilton (Onsten)     º Data ³ 22/06/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao do Imposto X Tes - Entrada               º±±
±±º          ³															   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA460,MATA100                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M100RIVAFEQ (cCalculo,nItem,aInfo)
	Local nVlImpostoIVA,nBase,nAliq,nAux,nOrdSFC,nRegSFC,nVal,nTotBase,nVRet
	Local nPos,cTes,cFil
	Local aRefImp
	Local llRetIVA	:= .T.
	Local clAgen	:= GetMV("MV_AGENTE")

	
	nBase:=0
	nAliq:=0
	nVRet:=0
	nVlImpostoIVA:=0
	lRet      := .T.

	If cModulo$'COM'
		If SubStr(clAgen,1,1) != "S"
			llRetIVA	:= .F.
		EndIf
	ElseIf cModulo$'FAT'
		If SA1->A1_AGENRET != '1'
			llRetIVA	:= .F.
		EndIf
	EndIf
	
	If llRetIVA

		dbSelectArea("SFB")
		dbSetOrder(1)
		If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
			If cCalculo$"BA"
				If cCalculo=="B"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Localiza o valor do imposto do IVA³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SFC")
					nRegSFC:=Recno()
					nRegSFB:=SFB->(Recno())
					nOrdSFC:=IndexOrd()
					DbSetOrder(2)
					cTes:=MaFisRet(nItem,"IT_TES")
					aRefImp:=MaFisRelImp("MT100",{"SD1"})
					cFil:=xFilial("SFC")
					DbSeek(cFil+cTes+"IV")
					cAux:=Substr(FC_IMPOSTO,1,2)
					While FC_FILIAL==cFil .And. FC_TES==cTes .And. cAux=="IV"
						If FC_IMPOSTO<>aInfo[X_IMPOSTO]
							If (SFB->(DbSeek(xFilial("SFB")+SFC->FC_IMPOSTO)))
								nPos:=Ascan(aRefImp,{|x| x[2]=="D1_VALIMP"+SFB->FB_CPOLVRO})
								If nPos>0
									nVlImpostoIVA += MaFisRet(nItem,aRefImp[nPos,3])
								Endif
							Endif
						Endif
						DbSkip()
						cAux:=Substr(FC_IMPOSTO,1,2)
					Enddo
					DbSetOrder(nOrdSFC)
					DbGoto(nRegSFC)
					SFB->(DbGoto(nRegSFB))
				Endif
				
				dbSelectArea("SFB")
				dbSetOrder(1)
				If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
					nAliq:=SFB->FB_ALIQ
					nBase:=nVlImpostoIVA
				Endif
			Else
				lRet:=.T.
			Endif
		Endif
	EndIf

	If lRet .And. llRetIVA                                                                                  
		Do Case
			Case cCalculo=="A"
				nVRet:=nAliq // nVlImpostoIVA 
			Case cCalculo=="B"
				nVRet:=nBase // nBase 
			Case cCalculo=="V"
				nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
				nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				nVRet:=round(nBase * (nAliq/100),2)
		EndCase
	Endif

Return(nVRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100RIVAVE ºAutor  ³ Ivan Hacponzuk    º Data ³  15/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao de IVA - Venezuela     				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M100RIVAVE (clCalculo,nlItem,alInfo,llXFis)
	Local nlC		:= 0
	Local llRetIVA	:= .T.
	Local clAgen	:= GetMV("MV_AGENTE")

	SetPrvt("cpAliasRot,cpOrdemRot,apItemInfo,apImposto,cpCFO,npVlImpIVA,lpRet")

	If !llXFis
		apItemInfo	:= ParamIxb[1]
		apImposto	:= ParamIxb[2]
		xRet		:= apImposto
	Else
		xRet := 0
	EndIf

	lpRet		:= .F.
	npVlImpIVA	:= 0

	If llXFis
		xRet := M100RIVAFVE(clCalculo,nlItem,alInfo)
	Else
		If cModulo $ 'COM'
			If SubStr(clAgen,1,1) != "S" 
				llRetIVA := .F.
			EndIf
		ElseIf cModulo $ 'FAT'
			If SA1->A1_AGENRET != '1'
				llRetIVA := .F.
			EndIf
		EndIf
		If llRetIVA
			DBSelectArea("SF4")
			cpCFO := Alltrim(SF4->F4_CF)
			For nlC:=1 to Len(apItemInfo[6])
				If SubStr(apItemInfo[6][nlC][1],1,2) == "IV"
					npVlImpIVA += apItemInfo[6][nlC][4]
				EndIf
			Next nlC
			DBSelectArea("SFB")
			DBSetOrder(1)
			If DBSeek(xFilial("SFB") + apImposto[1])
				apImposto[_ALIQUOTA] := SFB->FB_ALIQ
				apImposto[_BASECALC] := npVlImpIVA
				nValImp:= Round(apImposto[_BASECALC] *  apImposto[_ALIQUOTA] / 100,2)
				If nValImp >= SFB->FB_MINRET
					apImposto[_IMPUESTO] := Round(apImposto[_BASECALC] *  apImposto[_ALIQUOTA] / 100,2)
				Else
					apImposto[_IMPUESTO] := 0
				EndIf	
			EndIf
			xRet := apImposto
		EndIf
	EndIf
	DBSelectArea(cpAliasRot)
	DBSetOrder(cpOrdemRot)
Return(xRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100RIVAFVE ºAutor  ³ Ivan Hacponzuk     º Data ³ 15/07/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao do Imposto X Tes - Entrada               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA460,MATA100                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M100RIVAFVE(clCalculo,nlItem,alInfo)
	Local nlVlImpIVA,nlBase,nAliq,nlOrdSFC,nlRegSFC,nlVRet,nlPos,cTes,clFil,alRefImp,clAux
	Local llRetIVA	:= .T.
	Local clAgen	:= GetMV("MV_AGENTE")

	nlBase		:= 0
	nlAliq		:= 0
	nlVRet		:= 0
	nlVlImpIVA	:= 0
	lpRet		:= .T.

	If cModulo $ 'COM'
		If SubStr(clAgen,1,1) != "S" .AND. SA2->A2_PERCCON>0
			llRetIVA := .F.
		EndIf
	ElseIf cModulo $ 'FAT'
		If SA1->A1_AGENRET != '1'
			llRetIVA := .F.
		EndIf
	EndIf

	If llRetIVA
		DBSelectArea("SFB")
		DBSetOrder(1)
		If DBSeek(xFilial("SFB") + alInfo[X_IMPOSTO])
			If clCalculo $ "BA"
				If clCalculo == "B"
					DBSelectArea("SFC")
					nlRegSFC := Recno()
					nRegSFB := SFB->(Recno())
					nlOrdSFC := IndexOrd()
					SFC->(DBSetOrder(2))
					clTes := MaFisRet(nlItem,"IT_TES")
					alRefImp := MaFisRelImp("MT100",{"SD1"})
					clFil := xFilial("SFC")
					DBSeek(clFil + clTes + "IV")
					clAux := SubStr(FC_IMPOSTO,1,2)
					
					While SFC->FC_FILIAL == clFil .and. SFC->FC_TES == clTes .and. clAux == "IV"
	
						If SFC->FC_IMPOSTO <> alInfo[X_IMPOSTO]
							If (SFB->(DBSeek(xFilial("SFB") + SFC->FC_IMPOSTO)))
								nlPos := Ascan(alRefImp,{|x| x[2] == "D1_VALIMP" + SFB->FB_CPOLVRO})
								If nlPos > 0
								    
								    nlVlImpIVA +=SFB->FB_ALIQ/100*MaFisRet(nlItem,"IT_VALMERC")
									//nlVlImpIVA += MaFisRet(nlItem,alRefImp[nlPos,3])
									
								EndIf
							EndIf
						EndIf
						SFC->(DBSkip())
						clAux := SubStr(FC_IMPOSTO,1,2)
					EndDo
					DBSetOrder(nlOrdSFC)
					DBGoTo(nlRegSFC)
					SFB->(DBGoTo(nRegSFB))
					nlBase := nlVlImpIVA
				
				EndIf
				
				nlAliq := SA2->A2_PERCCON  //% de retencion en base al proveedor
				
				
			Else
				lpRet := .T.
			EndIf
		EndIf
	EndIf

	If lpRet .and. llRetIVA
		Do Case
			Case clCalculo == "A"
				nlVRet := nlAliq
			Case clCalculo == "B"
				nlVRet := nlBase
			Case clCalculo == "V"
			
					
				nlAliq := MaFisRet(nlItem,"IT_ALIQIV" + alInfo[X_NUMIMP])
				nlBase := MaFisRet(nlItem,"IT_BASEIV" + alInfo[X_NUMIMP])
				nlVRet := Round(nlBase * (nlAliq / 100),2)

		EndCase
	EndIf
Return(nlVRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100RIVAURºAutor  ³Marcos Kato         º Data ³  13/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao de IVA - Esse imposto e calculado sobre º±±
±±º          ³o Imposto de Valor Agregado                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Paraguay                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                    

Function M100RIVAUR(cCalculo,nItem,aInfo,lXFis)

Local  nIVAItem := 0  
Local  nMoeda 
Local  nE := 0
Local   nBaseAtu, nTaxaMoed
Local aValRet
Local cGrpIVA := ""
Local nBaseTot := 0

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,CMODULO,CTIPOFORN,CCFO")
SetPrvt("NC,NVLIMPOSTOIVA,CZONFIS,CTIPOCONTR,CRETIVA,CTIPOEMPR,NBASE,LRETCF")

cAliasRot   := Alias()
cOrdemRot   := IndexOrd()
cTipoCliFor := SA2->A2_TIPO
nMoeda  	:=	IIf(Type("nMoedaCor")=="U",1,nMoedaCor)  
If lxFis
	xRet := 0
Else
    xRet := ParamIxb[2]
Endif                 

If lXFis
	xRet := M100RIVAFUR(cCalculo,nItem,aInfo,nMoeda)
Else
	aItemINFO   := ParamIxb[1]
	aImposto    := ParamIxb[2]
	aTodosImp	:=	aClone(If(Type("aImps")=="U",aImpSD2,aImps))
	dbSelectArea("SFF")
	dbSetOrder(5)
	If dbSeek(xFilial("SFF")+aImposto[1])
		For nE := 1 To Len(aImpVarSD1[6])
			If (Substr(aImpVarSD1[6][nE][6],3,8) == "_VALIMP1")
				nIVAItem += aImpVarSD1[6][nE][4]
			Endif
		Next
		If nIvaItem > 0    
		
			aImposto[_BASECALC] := (aItemINFO[3]+aItemINFO[4]+aItemInfo[5]) * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)  
			If Subs(aImposto[5],4,1) == "S"  
            	aImposto[_BASECALC] := (aItemINFO[3]+aItemINFO[4]+aItemInfo[5]-aImposto[18]) * IIf(SFC->FC_BASE>0,SFC->FC_BASE / 100,1)	
         	Endif 
         	
         	aImposto[_ALIQUOTA] := SFB->FB_ALIQ         	
         	DbSelectArea("SB5")
			SB5->(DbSetOrder(1))
			SB5->(DbGoTop())
			If DbSeek(xFilial("SB5") + AvKey(MaFisRet(nItem,"IT_PRODUTO"),"B1_COD") )
				cGrpIVA:=SB5->B5_GRPIVA
				DbSelectArea("SFF")
				SFF->(DbSetOrder(9))
				SFF->(DbGoTop())
				If DbSeek(xFilial("SFF") + AvKey(aImposto[1],"FF_IMPOSTO") + AvKey(cGrpIVA,"FF_GRUPO"))
					aImposto[_ALIQUOTA]:=SFF->FF_ALIQ
					lRet := .T.
				Endif		
			Endif         	
         	
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
         
         	nBaseAtu := xMoeda(aImposto[_BASECALC],nMoeda,1,Nil,Nil,nTaxaMoed)        						
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   	   	//³Verifica o valor das retenções e base de RI2 acumulados³
   		   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÙ			
			aValRet := RetValIR("RI2")
			//aValRet[01] = base acumulada
			//aValRet[02] = retencao acumulada				          		         	      	
			If  (nBaseAtu+aValRet[1]  >= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)) 
				aValRet[1] := xMoeda(aValRet[1],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				aValRet[2] := xMoeda(aValRet[2],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)			   
				aImposto[_IMPUESTO] := Round((nBaseTot+aValRet[1])  * aImposto[_ALIQUOTA]/100,MsDecimais(nMoeda))-aValRet[2]
				aImposto[_IMPUESTO] := IIf(aImposto[_IMPUESTO]>0,aImposto[_IMPUESTO],0)				
			Else
				aImposto[_IMPUESTO] := 0
			Endif
		Endif
	xRet := aImposto
	EndIf
EndIf


dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100RIVAFURºAutor  ³Marcos Kato        º Data ³  13/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao do Imposto X Tes - Entrada               º±±
±±º          ³Para o uso da funcao MATXFIS                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA460,MATA100                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function M100RIVAFUR(cCalculo,nItem,aInfo,nMoeda)
Local cCFO		 := ""
Local cMvAgente	 := Alltrim(SuperGetMv("MV_AGENTE",.F.,"NNNNNNNNNN"))
Local cAliasRot  := Alias()
Local cOrdemRot  := IndexOrd()
Local cImpIncid	 :=""
Local nDesconto,nBase,nAliq,nOrdSFC,nRegSFC,nVal,nVRet, nI,nAliqI, nBaseAtu, nTaxaMoed
Local nAliqAux 
Local aValRet
Local cGrpIVA := "" 
Private clTipo	:= ""  


If Valtype(aInfo)=="U"
	aInfo   := ParamIxb[2]
Endif

nI:=0
nBase:=0
nAliq:=0
nAliqI:=0
nDesconto:=0
nVRet:=0
nAliqAux:=0


DbSelectArea("SFB")
SFB->(DbSetOrder(1))
If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
	//If cCalculo$"AB"
		cCFO := MaFisRet(nItem,"IT_CF")
		//Tira os descontos se for pelo liquido
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
			If SFC->FC_LIQUIDO=="S"
				nDesconto:=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif
			cImpIncid:=SFC->FC_INCIMP
		Endif
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
		nVal:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If GetNewPar('MV_DESCSAI','1')=='2'
			nVal-=nDesconto
		Endif 
		
		If SubStr(cMvAgente,4,1) == "N" .And. Alltrim(aInfo[X_IMPOSTO])=="RI2"
			nAliq:=0
		Else		
			DbSelectArea("SB5")
			SB5->(DbSetOrder(1))
			SB5->(DbGoTop())
			If DbSeek(xFilial("SB5") + AvKey(MaFisRet(nItem,"IT_PRODUTO"),"B1_COD") )
				cGrpIVA:=SB5->B5_GRPIVA
				DbSelectArea("SFF")
				SFF->(DbSetOrder(9))
				SFF->(DbGoTop())
				If DbSeek(xFilial("SFF") + AvKey(aInfo[X_IMPOSTO],"FF_IMPOSTO") + AvKey(cGrpIVA,"FF_GRUPO"))
					nAliq:=SFF->FF_ALIQ
					lRet := .T.
				Endif		
			Endif		
		
			If !Empty(cImpIncid)		
				nI:=At(";",cImpIncid)
				nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
				nAliqI:=0
				Do While nI>1
					If (SFB->(DbSeek(xFilial("SFB")+Substr(cImpIncid,1,nI-1))))
						nAliqI+=SFB->FB_ALIQ						
					Endif
					nAliqAux+=nAliqI
					cImpIncid:=Stuff(cImpIncid,1,nI,"")
					nI := At( ";",cImpIncid)
					nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
				End				
			Endif		
		EndIf	 			
	//Endif
Endif

Do Case
	Case cCalculo=="B"
		nVRet:=nVal
		//If nAliqI>0
		//	nVRet:=Round(nVal * (nAliqI/100),MsDecimais(nMoeda))
		//Endif
	Case cCalculo=="A"
		nVRet:=nAliq
	Case cCalculo=="V"
		//If nAliqAux > 0
	   	//	nBase:=(MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])/(nAliqAux/100))
	   	//Else
	   		nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
	   	//Endif			
		nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP]) 		
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
   	   	//³Verifica o valor das retenções e base de RIV acumulados³
   	   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÙ			
		aValRet := RetValIR("RI2",MaFisRet(nItem,"IT_TES"))
		//aValRet[01] = base acumulada
		//aValRet[02] = retencao acumulada 				
		If (nBaseAtu+aValRet[1]) >= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)			
			aValRet[1] := xMoeda(aValRet[1],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
			aValRet[2] := xMoeda(aValRet[2],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
			nVret := ( ((nBase+aValRet[1])*(nAliqAux/100))*(nAliq/100))-aValRet[2]
			nVret := IIf(nVret>0,nVret,0)
			nVret := Round(nVRet,MsDecimais(nMoeda))
		Else
			nVret := 0
		EndIF							
EndCase
DbSelectArea( cAliasRot )
DbSetOrder( cOrdemRot )
Return(nVRet)
