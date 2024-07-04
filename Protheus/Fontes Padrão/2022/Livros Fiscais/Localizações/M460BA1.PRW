//Constantes utilizadas nas localizacoes
#DEFINE _NOMEIMPOS 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _IVAFLETE  12
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º   M100BA1  º Autor º Bruno Sobieski  º Data º   02/12/99  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                 Programa que calcula o IMEBA1                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º m460BA1                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametrosº                                         			           º±±
±±º         1 º cCalculo                                                  º±±
±±º         2 º nItem                                                     º±±
±±º         3 º aInfo                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   º aImposto                                                  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º MATA10x, LOJA010 e LOJA220                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460BA1(cCalculo,nItem,aInfo)

local aImp,aItem,cImp,xRet,nOrdSFC,nRegSFC,nImp
Local nBase:=0, nAliq:=0
Local nDecs
Local aAgreg	:=	{}
Local nX	:=	0
Local nAliqImpAtu	:=	0
Local nIndice	:=	0
Local cAgregBase	:=	""
Local aAreaSFB	:=	{}
Local aAreaSFC	:=	{}
Local aImpTmp	:=	{}
Local nPosIMp	:=	0
lXFis	:=	MafisFound() 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete rateado para este Item ...             ³
³ [1,5] > Valor das Despesas rateado para este Item...          ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de  ³
³        incidência de outros impostos.                         ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

If !lXfis
   aItem	:=	ParamIxb[1]
   aImp	:=	ParamIxb[2]
   cImp	:=	aImp[1]
Else
	cImp	:=	aInfo[1]
Endif           

nVlFicto	:=	SB1->B1_VLFICTO

If cModulo == "FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	cGrp := Alltrim(SBI->BI_GRPEBA)
Else
	cGrp := Alltrim(SB1->B1_GRPEBA)
Endif

DbSelectArea('SFF')
DbSetOrder(9)

If MsSeek(xFilial()+cImp+cGrp)
	nAliqImpAtu := FF_ALIQ
Else
	Return
EndIf

If !lXFis
	If nVlFicto > 0.And.aItem[1] > 0
		nBase	:=	nVlFicto*aItem[1]
	Else	
	   nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	Endif
Else
	If nVlFicto > 0 .And.MaFisRet(nItem,"IT_QUANT") > 0
		nBase	:=	nVlFicto*MaFisRet(nItem,"IT_QUANT")
	Else	
	   nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If GetNewPar('MV_DESCSAI','1')=='1' 
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
	Endif
Endif


If !lXFis
	nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
   aImp[_ALIQUOTA]	:=	nAliqImpAtu
   aImp[_BASECALC]	:=	nBase

   //Tira os descontos se for pelo liquido .Bruno
   If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
	    aImp[_BASECALC]	-=	aImp[18]
	    nBase				:=	aImp[_BASECALC]
   Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar se este imposto pertence a um grupo de impostos, para os quais as bases devem ser ³
	//³calculadas em conjunto, se pertencer, calculo as aliquotas de cada um dos impostos do grupos³
	//³para poder estabelecer a base de cálculo                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea('SFC')
	aAreaSFC	:=	GetArea()
	DbSelectArea('SFB')
	aAreaSFB	:=	GetArea()
	If !Empty(SFC->FC_AGRBASE) .And. nBase > 0
		cAgregBase	:=	SFC->FC_AGRBASE
		nIndAtu		:=	Val(SFC->FC_SEQ)	
		SFC->(DbSeek(xFilial("SFC")+SF4->F4_CODIGO ))
		While !EOF() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO 
			If cAgregBase	==	SFC->FC_AGRBASE
				AAdd(aAgreg,{SFC->FC_SEQ,SFC->FC_IMPOSTO})
			Endif
			SFC->(DbSkip())
		Enddo
		nAliq	:=	0
		For nX:= 1 To Len(aAgreg)
			nIndice	:=	Val(aAgreg[nX][1])
			If nIndice > nIndAtu			
				SFB->(MsSeek(xFilial()+aAgreg[nX][2]))	
				aImpTmp  := {}
				AAdd( aImpTmp , SFB->FB_CODIGO )
				AAdd( aImpTmp , 0.00 )
				AAdd( aImpTmp , 0.00 )
				AAdd( aImpTmp , 0.00 )
				AAdd( aImpTmp, SFC->FC_INCDUPL + SFC->FC_INCNOTA + SFC->FC_CREDITA + If(Type("SFC->FC_LIQUIDO")=="C",SFC->FC_LIQUIDO,"S"))
				AAdd( aImpTmp, "D2_VALIMP"+SFB->FB_CPOLVRO)
				AAdd( aImpTmp, "D2_BASIMP"+SFB->FB_CPOLVRO)
				AAdd( aImpTmp, "F2_VALIMP"+SFB->FB_CPOLVRO)
				AAdd( aImpTmp, "F2_BASIMP"+SFB->FB_CPOLVRO)
				AAdd( aImpTmp, SFC->FC_INCIMP )
				AAdd( aImpTmp, 0.00 )
				AAdd( aImpTmp, 0.00 )
				AAdd( aImpTmp, 0.00 )
				AAdd( aImpTmp, 0.00 )
				AAdd( aImpTmp, SFC->FC_CALCULO )
				AAdd( aImpTmp, aImp[16])
				AAdd( aImpTmp, SFB->FB_CPOLVRO )  // [17]-Campo do Livro Fiscal.
				AAdd( aImpTmp, 0 )
				AADD( aImpTmp, {1,-1,0} )        //[19] Define se imposto vai somar, subtrair ou indiferente
				aImpTmp := ExecBlock( SFB->FB_FORMSAI,.F.,.F., { aClone(aItem), aImpTmp,;
					0, "D2_VALIMP"+SFB->FB_CPOLVRO,0} ,.T. )
				nAliq	+=	aImpTmp[2]
			ElseIf nIndice ==nIndAtu			
				nAliq	+=	aImp[_ALIQUOTA]
			Else
			  	nPosImp	:= Ascan(aItem[6],{|x| x[1]==aAgreg[nX][2]})
			  	If nPosImp > 0
					nAliq	+=	aItem[6][nPosImp][2]
				Endif			  
			Endif               
		Next
	Endif	

	RestArea(aAreaSFC)
	RestArea(aAreaSFB)

   //+---------------------------------------------------------------+
   //¦ Efetua o Calculo do Imposto                                   ¦
   //+---------------------------------------------------------------+
   aImp[_BASECALC] 	:= aImp[_BASECALC] /(1+(nAliq/100))
   aImp[_IMPUESTO]	:= aImp[_BASECALC]*aImp[_ALIQUOTA]/100
   
   xRet	:=	aImp
Else
   //Tira os descontos se for pelo liquido
   nOrdSFC:=(SFC->(IndexOrd()))
   nRegSFC:=(SFC->(Recno()))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar se a base do imposto eh o LIQUIDO ou o BRUTO,³
	//³e a sequencia do imposto atual                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCalculo == "B"
	   SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
	      If SFC->FC_LIQUIDO=="S"
	         nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
	      Endif   
			nIndAtu		:=	Val(SFC->FC_SEQ)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificar se este imposto pertence a um grupo de impostos, para os quais as bases devem ser ³
		//³calculadas em conjunto, se pertencer, calculo as aliquotas de cada um dos impostos do grupos³
		//³para poder estabelecer a base de cálculo                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SFC->FC_AGRBASE) .And. nBase > 0
			cAgregBase	:=	SFC->FC_AGRBASE
			nIndAtu		:=	Val(SFC->FC_SEQ)	
			SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES") ))
			While !EOF() .And. SFC->FC_FILIAL+SFC->FC_TES ==xFilial("SFC")+MaFisRet(nItem,"IT_TES") 
				If cAgregBase	==	SFC->FC_AGRBASE
					AAdd(aAgreg,{SFC->FC_SEQ,Posicione('SFB',1,xFilial('SFB')+SFC->FC_IMPOSTO,'SFB->FB_CPOLVRO')})
				Endif
				SFC->(DbSkip())
			Enddo
			nAliq	:=	0
			For nX:= 1 To Len(aAgreg)
				nIndice	:=	Val(aAgreg[nX][1])
				If nIndice >= nIndAtu			
					MaFisCalAl(nIndice,nItem)
				Endif               
		      nAliq	+=	MaFisRet(nItem,'IT_ALIQIV'+aAgreg[nX][2])
			Next
		Endif	
	Endif			    
   SFC->(DbSetOrder(nOrdSFC))
   SFC->(DbGoto(nRegSFC))
 
   Do Case
      Case cCalculo=="B"
			nBase	:=	nBase /(1+(nAliq/100))
			xRet:=nBase
      Case cCalculo=="A"
         xRet:=nAliqImpAtu
      Case cCalculo=="V"
			nImp	:=	MaFisRet(nItem,'IT_BASEIV'+aInfo[X_NUMIMP]) * MaFisRet(nItem,'IT_ALIQIV'+aInfo[X_NUMIMP])/100
         xRet	:=	nImp
   EndCase    
Endif
	
Return( xRet )
