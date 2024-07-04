#INCLUDE "Protheus.ch"
#DEFINE _DEBUG   .F.   // Flag para Debuggear el codigo
#DEFINE _NOMIMPOST 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Progr0ma  |M100IRAE  ³ Autor ³RENATO NAGIB           ³ Data ³09.08.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao da base, aliquota e calculo do IRAE              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³               VALOR DE CCALCULO                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cCalculo -> Solicitacao da MATXFIS, podendo ser A (aliquota)³±±
±±³          ³ B (base) ou V (valor)                                      ³±±
±±³          ³nItem -> Item do documento fiscal                           ³±±
±±³Alteracao ³  1. Verificacao de minimo e acumulado da funcao RETVALIR() ³±±
±±³Camila    ³  2. Atualizacao de valores em moedas diferentes para gravar³±±
±±³          ³  na SFE 												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function M100IRAE(cCalculo,nItem,aInfo,lXFadminis)

Local lCalcula  := .T. 
Local cGrpIRAE  := ""
Local lRet 		:= .F.
Local nDesconto := 0
Local nBase	    
Local nAliq	    
Local nOrdSFC   := 0
Local nRegSFC   := 0
Local nVRet		:= 0
Local nBaseAtu	
Local nMoeda 	:= 0
Local nTaxaMoed := 0
Local cImpIncid := ""
Local nI		:= 0
Local aImpRef,aImpVal

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,")
SetPrvt("CCLASCLI,CCLASFORN,CMVAGENTE,NPOSFORN,NPOSLOJA,NTOTBASE,LRETCF") 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se pode reter IRAE de acordo com o tipo do fornecedor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MaFisRet(,"NF_CLIFOR") == "C"
	If SA1->A1_RETIRAE <> 'S' .Or. !SA1->A1_TIPO $ "1|2"
		lCalcula := .F.
	EndIf
Else
	If SA2->A2_RETIRAE <> 'S' .Or. !SA2->A2_TIPO $ "1|2"
		lCalcula := .F.
	EndIf
EndIf

If lCalcula
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
		//nBase-=nDesconto
		nAliq:=SFB->FB_ALIQ		
		lRet := .F.
		
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
             
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o grupo IRAE do produto e busca a alíquota na tabela Tasas por Grupo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
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
			nVRet:= nBase
		Case cCalculo=="A"
			nVRet:= nAliq
		Case cCalculo=="V"			
			//nBase := (MaFisRet(nItem,"IT_VALMERC") - MaFisRet(nItem,"IT_DESCONTO"))			
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
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Converte a base para a moeda 1 para que seja feito  o 
			//a somatória com o acumulado da SFE que é moeda 1	   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        nBaseAtu := xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed)        						
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   	   	//³Verifica o valor das retenções e base de IR acumulados ³
	   	   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÙ			
			aValRet := RetValIR("IRA")
			//aValRet[01] = base acumulada
			//aValRet[02] = retencao acumulada 				
			If (nBaseAtu+aValRet[1]) >= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)			
				aValRet[1] := xMoeda(aValRet[1],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				aValRet[2] := xMoeda(aValRet[2],1,nMoeda,Nil,Nil,Nil, nTaxaMoed)
				nVret := ((nBase + aValRet[1])*(nAliq/100))-aValRet[2]
				nVret := IIf(nVret>0,nVret,0) 			   		
			Else
				nVret := 0
			EndIF				
	EndCase
Endif

Return nVRet
