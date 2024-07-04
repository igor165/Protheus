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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M460STX	³ Autor ³ Leonardo Ruben            ³ Data ³ 07.08.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CALCULO DA "SALES TAX" PARA OS ESTADOS UNIDOS                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Localizacoes                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Ronny Ctvrtnik|01/02/01³          ³Reforma para codigo em cada aliq.         ³±±
±±³Luis Enríque  |06/12/18³DMINA-1012³Rep.DMINA-254 Cálculo de Aliquota para EUA³±±
±±³              |        ³          ³Rep.DMINA-379 Cálculo de Aliquota para    ³±±
±±³              |        ³          ³Pedido Venta y Generación Factura	(EUA)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460Stx(cCalculo,nItem,aInfo)
Local lRet := .T.
Local cTipoCli, cAgeRet
Local aImposto,lXFis,cImp,xRet,nOrdSFC,nRegSFC   
Local cAliasRot  := Alias()
Local cOrdemRot  := IndexOrd()
Local aItemINFO  := {}
Local nBase      := 0
Local nAliq      := 0
Local cEst	     := ""
Local nModlo	 := 1 
Local cCodMun    := ""
Local cTpActiv   := ""
local cProvent   := ""
Local cCodMunC   := ""
Local cFrete	 := ""
Local cFunName	 := FunName()

lXFis := (MaFisFound() .and. ProcName(1)  <> "EXECBLOCK")

//indica si el calculo es llamado de Factura de Salida = 1, Pedido de Venta = 2 o de Generación de Factura = 3  
If cFunName == "MATA410"
	nModlo := 2
ElseIf cFunName $ "MATA468N|MATA461"
	nModlo := 3
EndIf

If !lXFis
   aItemINFO := ParamIxb[1]
   aImposto  := aClone(ParamIxb[2])  
   cImp      := aImposto[1]
   xRet		 := aImposto
   If nmodlo == 3
   	   cCodMun   := SC5->C5_CODMUN
   Else
	   If SF2->(ColumnPos( 'F2_CODMUN' )) > 0
	   	  cCodMun := SF2->F2_CODMUN
	   EndIf
   EndIf
Else
   cImp    := aInfo[1]
   xRet    := 0
   If nmodlo == 2
   		cCodMun := M->C5_CODMUN
   Else
   		cCodMun := MAFISRET(,'NF_CODMUN')
   EndIf
Endif

If cModulo == 'FAT' .or. cModulo == 'TMK' .or. cModulo == 'FRT'
	cTipoCli   := SA1->A1_TIPO
    cZonNum    := SA1->A1_CODZON // Codigo ref. FF_NUM                 
    cAgeRet    := SA1->A1_RETIVA
Else
    cTipoForn  := SA2->A2_TIPO
    cZonNum    := SA2->A2_CODZON // Codigo ref. FF_NUM
    cAgeRet    := SA2->A2_RETIVA
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se e agente de retencao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := (cAgeRet=="1")  // sim

If lRet
	//Verifica na SFF se existe ZonFis correspondente para:
	// * Calculo de Imposto;
	// * Obtencao de Aliquota;
	dbSelectArea("SFB")
	SFB->(dbSetOrder(1)) ////FB_FILIAL + FB_CODIGO
	If dbSeek(xFilial("SFB") + cImp)
	    nAliq  := SFB->FB_ALIQ
	    lRet := .T.
		If SA1->A1_CONTRBE == '2' //Si revendedor
		 	nAliq := 0	      	
		Else 
		
			If nModlo == 1 // Factura Salida
				cCodMunC := M->F2_CODMUN
				cTpActiv := M->F2_TPACTIV
				cProvent := M->F2_PROVENT
			ELseIf nModlo == 2 // Pedido Venta
				cCodMunC := M->C5_CODMUN
				cTpActiv := M->C5_TPACTIV
				cProvent := M->C5_PROVENT
			ELseIf nModlo == 3 // Generación Factura	
				cCodMunC := 	SC5->C5_CODMUN
				cTpActiv := SC5->C5_TPACTIV 
				cProvent := SC5->C5_PROVENT			  
			EndIf		                              
			// Si el emisor el lugar de entrega tiene presencia
			CC2->(dbSelectArea("CC2"))
			CC2->(dbSetOrder(3)) //CC2_FILIAL + CC2_CODMUN
			If CC2->(msSeek(xFilial("CC2") + cCodMun))
				SFF->(dbSelectArea("SFF"))
		   		SFF->(dbSetOrder(18))//FF_FILIAL+FF_IMPOSTO+FF_CODMUN+FF_CFO_V
		   			
			 	If SFF->(msSeek(xFilial("SFF" ) + cImp))  //Busca por impuesto		
				   	If CC2->CC2_PRESEN == '1' //  SI
				    	cEst := Substr(cCodMun, 1,2)
				    	While !SFF->(EOF())       	
							If SFF->FF_IMPOSTO == cImp .and. SFF->FF_ZONFIS == cEst .AND. SFF->FF_CODMUN == cCodMunC .AND. SFF->FF_COD_TAB == cTpActiv 
					    		nAliq  := SFF->FF_ALIQ // Alicuota de Zona Fiscal 
				      		Endif
				      		SFF->(DbSkip())
				      	Enddo
				 	Else  //NO
				 		cEst := Substr(cProvent, 1,2)
				   		While !SFF->(EOF())       	
							If SFF->FF_IMPOSTO == cImp .and. SFF->FF_ZONFIS == cEst .AND. SFF->FF_CODMUN == cProvent .AND. SFF->FF_COD_TAB == cTpActiv 
					    		nAliq  := SFF->FF_ALIQ // Alicuota de Zona Fiscal 
				      		Endif
				      		SFF->(DbSkip())
				      	Enddo
				 	EndIf
				EndIf
			EndIf           
	    EndIf             
		If lRet
		 
			If cFunName $ "MATA467N"
				cFrete := IIf(SF2->(ColumnPos( 'F2_TPFRETE' )) > 0, Alltrim(M->F2_TPFRETE), "")
			ElseIf cFunName $ "MATA410"
				cFrete := Alltrim(M->C5_TPFRETE)
			ElseIf cFunName $ "MATA468N|MATA461"
				cFrete := Alltrim(SC5->C5_TPFRETE)
			EndIf
			
	   	  If !lXFis
 		     nBase  := aItemINFO[_VLRTOTAL]  + aItemINFO[_GASTOS] // Base de Cálculo
 		     
 		     If Empty(cFrete) .Or. cFrete == "C"
	         	nBase += aItemINFO[_FLETE]
			 EndIf
			 
	   	     aImposto[_ALIQUOTA] := nAliq
	   	     aImposto[_BASECALC] := nBase 	   	     
             If Subs(aImposto[5],4,1) == "S"  
  		        aImposto[_BASECALC]	-=	aImposto[18]
		        nBase := aImposto[_BASECALC]
	         Endif	   	     

	   	     aImposto[_IMPUESTO]  := Round(nBase * (nAliq/100),2)
             xRet := aImposto
	   	  Else
            nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
            
            If Empty(cFrete) .Or. cFrete == "C"
				nBase += MaFisRet(nItem,"IT_FRETE")
			EndIf
			
			If GetNewPar('MV_DESCSAI','1')=='1'
				nBase	+= MaFisRet(nItem,"IT_DESCONTO")
			Endif
			
	   	     If cCalculo $ "B|V"
                nOrdSFC:=(SFC->(IndexOrd()))
                nRegSFC:=(SFC->(Recno()))
                SFC->(DbSetOrder(2))
                If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
                   If SFC->FC_LIQUIDO=="S"
                      nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
                   Endif   
                Endif   
                SFC->(DbSetOrder(nOrdSFC))
                SFC->(DbGoto(nRegSFC))		                     
             EndIf
    	     Do Case
		        Case cCalculo=="B"
                     xRet:=nBase
       		    Case cCalculo=="A"
		             xRet:=nALiq
		        Case cCalculo=="V"
           		     xRet:=Round(nBase * (nAliq/100),2)
			 EndCase
	   	  Endif
	   	Endif   
	Endif
EndIf
	
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( xRet ) 
