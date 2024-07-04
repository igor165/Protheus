/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M100IRS	� Autor � MARCELLO GABRIEL     � Data � 14.12.1999 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � CALCULO IRS SERVICO                                         ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
��� Percy Horna  �19/10/00�xxxxxx�Fue alterada a base de datos de Excep-   ���
���              �        �      �ciones de SF7->SFF, inicialmente utili-  ���
���              �        �      �zando los Impuestos de IESPS (mejico).   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
FUNCTION M100IRS(cCalculo,nItem,aInfo)
local cDbf:=alias(),nOrd:=IndexOrd(),aItem
local nBase:=0,nAliq:=0,lIsento:=.f.,lALIQ:=.f.,cFil,cAux
local cImp,xRet,lXfis

lXfis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")
/*
���������������������������������������������������������������Ŀ
� A variavel ParamIxb tem como conteudo um Array[2,?]:          �
�                                                               �
� [1,1] > Quantidade Vendida                     		        �
� [1,2] > Preco Unitario                            	        �
� [1,3] > Valor Total do Item, com Descontos etc...             �
� [1,4] > Valor do Frete Rateado para Este Item ...             �
� [1,5] > Array Contendo os Impostos j� calculados, no caso de  �
�         incid�ncia de outros impostos.                        �
� [2,?] > Array xRetosto, Contendo as Informa�oes do Imposto que�
�         ser� calculado.                                       �
�����������������������������������������������������������������
*/
If !lXfis
   aItem:=ParamIxb[1]
   xRet:=ParamIxb[2]
   cImp:=xRet[1]
Else
	cImp:=aInfo[1]
    SB1->(DbGoto(MaFisRet(nItem,"IT_RECNOSB1")))
    xRet:=0
Endif 
if SA2->A2_TIPO$"F2"  //pessoa fisica
   dbselectarea("SFF")     // verificando as excecoes fiscais
   cFil:=xfilial()
   if dbseek(cFil+cImp)
      while FF_IMPOSTO == cImp .and. FF_FILIAL == cFil .and. !lAliq
            cAux:=Alltrim(FF_GRUPO)
            if cAux!=""
               lAliq:=(cAux==alltrim(SB1->B1_GRUPO))
            endif
            cAux:=alltrim(FF_ATIVIDA)
            if cAux!=""
               lAliq:=(cAux==alltrim(SA1->A1_ATIVIDA))
            endif
            if lAliq
               if !((lIsento:=FF_TIPO)=="S")
                  nAliq:=FF_ALIQ
               endif
            endif
            dbskip()
      enddo
   endif

   if !lAliq .And. If(!lXFis,.T.,cCalculo=="A")
      dbselectarea("SFB")    // busca a aliquota padrao
      if dbseek(xfilial()+cImp)
         nAliq:=SFB->FB_ALIQ
      endif
   Endif               

   If !lXfis
      nBase:=aItem[3]+aItem[4]+aItem[5]  //total + frete + outros impostos
      xRet[02]:=nAliq
      xRet[03]:=nBase	
      //Tira os descontos se for pelo liquido .Bruno
      If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
		 xRet[3]	-=	xRet[18]
		 nBase	:=	xRet[3]
	  Endif
      xRet[04]:=(nAliq*nBase)/100
      xRet:=xRet
   Else
       Do Case
          Case cCalculo=="B"
               xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
          Case cCalculo=="A"
               xRet:=nALiq
          Case cCalculo=="V"
               nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
               nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
               xRet:=(nAliq * nBase)/100
       EndCase
   Endif
   dbSelectar(cDbf)
   dbSetOrder(nOrd)
Endif
Return(xRet)
