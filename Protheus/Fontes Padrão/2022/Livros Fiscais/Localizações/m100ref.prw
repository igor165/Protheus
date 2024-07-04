#include "SIGAWIN.CH"

//Constantes utilizadas no sistema argentino
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
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������͸��
���Funcao    �                   M100REF                 �Data  20/01/2000   ���
����������������������������������������������������������������������������Ĵ��
���Descricao �Executa a funcao propria a cada pais para o calculo do IVA     ���
����������������������������������������������������������������������������Ĵ��
���Uso       �MATA460                                                        ���
����������������������������������������������������������������������������;��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function M100REF(cCalculo,nItem,aInfo)
Local cFunc,aRet,lXFis
Local aCountry // Array de Paises nesta forma : // { { "BRA" , "Brasil", "BR" } , { "ARG" , "Argentina","AR"} ,

cAliasRot:=Alias()
cOrdemRot:= IndexOrd()

lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
// .T. - metodo de calculo utilizando a matxfis
// .F. - metodo antigo de calculo

aCountry:= GetCountryList()

cFunc:="M100Ref"+aCountry[Ascan( aCountry, { |x| x[1] == cPaisLoc } )][3] // retorna pais com 2 letras
aRet:=&(cFunc)(cCalculo,nItem,aInfo,lXFis)

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( aRet )


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M100REF	� Autor � Lucas				    � Data � 27.07.2000 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo da Retencao sobre o valor do Frete/Paraguay         ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
���              �        �      �                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function M100RefPA(cCalculo,nItem,aInfo,lXFis)
Local nFreteNaFac := 0
//Local nPercFrete := GetNewPar("MV_PFRETE",10)

/*
���������������������������������������������������������������Ŀ
� A variavel ParamIxb tem como conteudo um Array[2,?]:          �
�                                                               �
� [1,1] > Quantidade Vendida                     		          �
� [1,2] > Preco Unitario                            	          �
� [1,3] > Valor Total do Item, com Descontos etc...             �
� [1,4] > Valor do Frete Rateado para Este Item ...             �
� [1,5] > Array Contendo os Impostos j� calculados, no caso de  �
�         incid�ncia de outros impostos.                        �
� [2,?] > Array xret, Contendo as Informa�oes do Imposto que�
�         ser� calculado.                                       �
�����������������������������������������������������������������
*/

If !lXFis
   aItemINFO := ParamIxb[1]
   xRet  := AClone( ParamIxb[2] )
   If SA2->A2_TIPO $ "A" .and. SA2->A2_EST == "EX"
 	  If nValFrete > 0
		 nFreteNaFac := nValFrete
//	ElseIf lGetFrete
//		nFreteNaFac := nTotMerc * (nPercFrete/100)
	  EndIf
  	  If nFreteNaFac > 0
	   //+---------------------------------------------------------------+
   	   //� Efetua o Calculo do Imposto                                   �
   	   //+---------------------------------------------------------------+
		 xRet[3] := nFreteNaFac
		 xRet[4] := ( nFreteNaFac * (xRet[2]/100) )
	  EndIf
   Endif	 
Else
    xRet:=0   
    If SA2->A2_TIPO $ "A" .and. SA2->A2_EST == "EX"
       Do Case
          Case cCalculo=="B"
               xRet:=MaFisRet(nItem,"IT_FRETE")
          Case cCalculo=="A"     
               If (SFB->(DbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])))
                  xRet:=FB_ALIQ
               Endif   
          Case cCalculo=="V"
               xRet:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
               xRet:=xRet*(MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])/100)
       EndCase
    Endif   
Endif

Return( xRet )
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 �M100REFME	� Autor � Marcello             � Data � 22.11.2001 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo da Retencao sobre o valor do Frete/Mexico           ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
���              �        �      �                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
STATIC FUNCTION M100REFME(cCalculo,nItem,aInfo,lXFis)
local aItem,cImp,xRet,nOrdSFC,nRegSFC
local nBase:=0,nAliq:=0,lALIQ:=.f.,lIsento:=.f.,cFil,cAux,cGrp
local cImpIncid,nE,nI

dbSelectArea("SFF")     // verificando as excecoes fiscais
dbSetOrder(3)
cFil:=xfilial()

If !lXfis
	aItem:=ParamIxb[1]
	xRet:=ParamIxb[2]
	cImp:=xRet[1]
	cImpIncid:=xRet[10]
Else
	cImp:=aInfo[1]
	If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
		SBI->(DbSeek(xFilial("SBI")+MaFisRet(nItem,"IT_PRODUTO")))
	Else
		SB1->(DbSeek(xFilial("SB1")+MaFisRet(nItem,"IT_PRODUTO")))
	Endif
	cImpIncid:=""
Endif

If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	cGrp:=Alltrim(SBI->BI_GRUPO)
Else
	cGrp:=Alltrim(SB1->B1_GRUPO)
Endif

if dbseek(cFil+cImp)
	while FF_IMPOSTO == cImp .and. FF_FILIAL == cFil .and. !lAliq
		cAux:=Alltrim(FF_GRUPO)
		if cAux!=""
			lAliq:=(cAux==cGrp)
		endif
		cAux:=alltrim(FF_ATIVIDA)
		if cAux!=""
			lAliq:=(cAux==alltrim(SA1->A1_ATIVIDA))
		endif
		if lAliq
			if !(lIsento:=(FF_TIPO=="S"))
				nAliq:=FF_ALIQ
			endif
		endif
		dbskip()
	enddo
endif
if !lIsento
	if !lAliq .And. If(!lXFis,.T.,cCalculo=="A")
		dbselectar("SFB")    // busca a aliquota padrao
		if dbseek(xfilial()+cImp)
			nAliq:=SFB->FB_ALIQ
		endif
	endif
	If !lXFis
		nBase:=aItem[3]+aItem[5]  //valor total + frete + outros impostos
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
			nBase-=xRet[18]
		Endif
		//+---------------------------------------------------------------+
		//� Soma a Base de C�lculo os Impostos Incidentes                 �
		//+---------------------------------------------------------Lucas-+
		nI:=At(cImpIncid,";" )
		nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
		While nI>1
			nE:=AScan(aItem[6],{|x| x[1]==Left(cImpIncid,nI-1)})
			If nE>0
				nBase+=aItem[6,nE,4]
			End
			cImpIncid:=Stuff(cImpIncid,1,nI,"")
			nI:=At(cImpIncid,";")
			nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
		Enddo
	Else
		If cCalculo=="B"
			nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			//Tira os descontos se for pelo liquido
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
				If SFC->FC_LIQUIDO=="S"
					nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif
			Endif
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
			//+---------------------------------------------------------------+
			//� Soma a Base de C�lculo os Impostos Incidentes                 �
			//+---------------------------------------------------------------+
			If !Empty(cImpIncid)
				aImpRef:=MaFisRet(nItem,"IT_DESCIV")
				aImpVal:=MaFisRet(nItem,"IT_VALIMP")
				For nI:=1 to Len(aImpRef)
					If !Empty(aImpRef[nI])
						If Trim(aImpRef[nI][1])$cImpIncid
							nBase+=aImpVal[nI]
						Endif
					Endif
				Next
			Endif
		Endif
	Endif
endif
If !lXFis
	xRet[02]:=nAliq
	xRet[03]:=nBase
	xRet[04]:=(nAliq * nBase)/100
Else
	Do Case
		Case cCalculo=="B"
			xRet:=nBase
		Case cCalculo=="A"
			xRet:=nALiq
		Case cCalculo=="V"
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			xRet:=(nAliq * nBase)/100
	EndCase
Endif
RETURN(xRet)
