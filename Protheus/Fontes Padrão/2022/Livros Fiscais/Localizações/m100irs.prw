/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M100IRS	³ Autor ³ MARCELLO GABRIEL     ³ Data ³ 14.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CALCULO IRS SERVICO                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Percy Horna  ³19/10/00³xxxxxx³Fue alterada a base de datos de Excep-   ³±±
±±³              ³        ³      ³ciones de SF7->SFF, inicialmente utili-  ³±±
±±³              ³        ³      ³zando los Impuestos de IESPS (mejico).   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION M100IRS(cCalculo,nItem,aInfo)
local cDbf:=alias(),nOrd:=IndexOrd(),aItem
local nBase:=0,nAliq:=0,lIsento:=.f.,lALIQ:=.f.,cFil,cAux
local cImp,xRet,lXfis

lXfis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ A variavel ParamIxb tem como conteudo um Array[2,?]:          ³
³                                                               ³
³ [1,1] > Quantidade Vendida                     		        ³
³ [1,2] > Preco Unitario                            	        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete Rateado para Este Item ...             ³
³ [1,5] > Array Contendo os Impostos j  calculados, no caso de  ³
³         incidˆncia de outros impostos.                        ³
³ [2,?] > Array xRetosto, Contendo as Informa‡oes do Imposto que³
³         ser  calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
