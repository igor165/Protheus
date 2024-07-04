#include "SIGAWIN.CH"
#DEFINE _NOMEIMP   01
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M460ARB	³ Autor ³ Leonardo Ruben       ³ Data ³ 08.08.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CALCULO DO IMPOSTO DE ARBITRIO PARA PORTO RICO              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Localizacoes                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M460ARB(cCalculo,nItem,aInfo)

Local lRet := .T.
Local lXFis

Local nOrdSFC
Local nRegSFC

Local cTipo, cEstFis, cCFO, cAgeRet
Local cAliasRot  := Alias()
Local cOrdemRot  := IndexOrd()
Local cImp

Local aItemINFO  := {}

Local xRet

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

If cModulo$'FAT|LOJA|FRT|TMK'
	cTipo      := SA1->A1_TIPO
	cEstFis    := SA1->A1_EST
	cAgeRet    := SA1->A1_RETIVA
Else
	cTipo      := SA2->A2_TIPO
	cEstFis    := SA2->A2_EST
	cAgeRet    := SA2->A2_RETIVA
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca o CFO do Tes Correspondente - SF4³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF4")
cCFO := Alltrim(SF4->F4_CF)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se e EXPORTACAO  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := (cTipo=="3")  // Exportacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se e agente de retencao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := (cAgeRet=="1")  // sim

If lRet
	If !lXFis
		aItemINFO  := ParamIxb[1]
		xRet       := ParamIxb[2]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aliquota por produto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosCol   := ParamIxb[3]
		
		xRet[_ALIQUOTA]  := SB1->B1_IPI
		
		If lRet .And. xRet[_ALIQUOTA] > 0
			xRet[_BASECALC]  := aItemINFO[_VLRTOTAL] + aItemINFO[_FLETE] + aItemINFO[_GASTOS] // Base de Cálculo
            //Tira os descontos se for pelo liquido .Bruno
            If Subs(xRet[5],4,1) == "S" 
	           xRet[_BASECALC]-=xRet[18]
            Endif			
			xRet[_IMPUESTO]  := Round(xRet[_BASECALC] * ( xRet[_ALIQUOTA]/100) ,2)
		Endif
	Else
	    xRet := 0
	    cImp := aInfo[X_IMPOSTO]	    
		Do Case
			Case cCalculo   =="B"
				xRet  := MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
				If GetNewPar('MV_DESCSAI','1')=='1' 
					xRet	+= MaFisRet(nItem,"IT_DESCONTO")
				Endif
                //Tira os descontos se for pelo liquido
                nOrdSFC := (SFC->(IndexOrd()))
                nRegSFC := (SFC->(Recno()))
                SFC->(DbSetOrder(2))
                If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
                   If SFC->FC_LIQUIDO=="S"
                      xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
                   Endif                      
                Endif   
                SFC->(DbSetOrder(nOrdSFC))
                SFC->(DbGoto(nRegSFC))				
			Case cCalculo   =="A"
				xRet  := If(cModulo$'FRT',SBI->BI_IPI,SB1->B1_IPI)
			Case cCalculo   =="V"
				xRet  := MaFisRet(nItem,"IT_BASEIV"+aInfo[2])*MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])/100
		EndCase		
	EndIf	
Else	
   xRet:=If(!lXFis,ParamIxb[2],0)	
EndIf

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return xRet
