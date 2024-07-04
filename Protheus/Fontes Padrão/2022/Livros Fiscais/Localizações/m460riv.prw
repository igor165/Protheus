/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M460RIV	� Autor � MARCELLO GABRIEL     � Data � 01.11.2000 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � CALCULO IVA  -  RETENCAO      (MEXICO)                      ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Generico 												   ���
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
FUNCTION M460RIV(cCalculo,nItem,aInfo)
local cDbf:=alias(),nOrd:=IndexOrd(),aItem
local nBase:=0,nAliq:=0,lAliq:=.f.,cFil,cAux,lIsento:=.f.
local nOrdSFF,nI
Local cImpIncid:= ""
/*
���������������������������������������������������������������Ŀ
� A variavel ParamIxb tem como conteudo um Array[2,?]:          �
�                                                               �
� [1,1] > Quantidade Vendida                     		        �
� [1,2] > Preco Unitario                             	        �
� [1,3] > Valor Total do Item, com Descontos etc...             �
� [1,4] > Valor do Frete Rateado para Este Item ...             �
� [1,5] > Array Contendo os Impostos j� calculados, no caso de  �
�         incid�ncia de outros impostos.                        �
� [2,?] > Array aImposto, Contendo as Informa��es do Imposto que�
�         ser� calculado.                                       �
�����������������������������������������������������������������
*/
                            
dbselectarea("SFF")     
nOrdSFF:=indexord()
dbsetorder(3)
cFil:=xfilial()
lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")
If !lXfis
   aItem:=ParamIxb[1]
   xRet:=ParamIxb[2]
   cImp:=xRet[1]
   cImpIncid:=xRet[10]
Else
	cImp:=aInfo[1]
    SB1->(DbGoto(MaFisRet(nItem,"IT_RECNOSB1")))
    xRet:=0
Endif    

If dbseek(cFil+cImp)   .and. cPaisLoc <> "URU"
	WHile FF_IMPOSTO==cImp .and. FF_FILIAL==cFil .and. !lAliq
   		cAux:=Alltrim(FF_GRUPO)
        If cAux!=""
            lAliq:=(cAux==alltrim(SB1->B1_GRUPO))
        Endif
        cAux:=alltrim(FF_ATIVIDA)
        If cAux!=""
            lAliq:=(cAux==alltrim(SA1->A1_ATIVIDA))
        endif
        If lAliq
            if !(lIsento:=(FF_TIPO=="S"))
               nAliq:=FF_ALIQ
            endif
        Endif
        dbskip()
   	Enddo
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
	if !lAliq
       	if (SFB->(dbseek(xfilial("SFB")+cImp))) // busca a aliquota padrao
           	nAliq:=SFB->FB_ALIQ
    	endif
   	endif
   	
   	If !lXFis
      
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
          //Tira os descontos se for pelo liquido
          nOrdSFC:=(SFC->(IndexOrd()))
          nRegSFC:=(SFC->(Recno()))
          SFC->(DbSetOrder(2))
          If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
			cImpIncid:=Alltrim(SFC->FC_INCIMP)
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
   	
   	
	If !lXFis
	   xRet[02]:=nAliq
	   xRet[03]:=nBase
	   xRet[04]:=Round( ((nAliq * nBase)/100),2)   
	Else 
	    Do Case
	       Case cCalculo=="B"
	            xRet:=nBase
	       Case cCalculo=="A"
	            xRet:=nALiq
	       Case cCalculo=="V"
	            nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[02])
	            xRet:=Round( (nAliq * MaFisRet(nItem,"IT_BASEIV"+aInfo[02]))/100,2)
	    EndCase
	Endif   	
	   	
   	  
EndIf   

dbSelectarea(cDbf)
dbSetOrder(nOrd)
RETURN(xRet)	
