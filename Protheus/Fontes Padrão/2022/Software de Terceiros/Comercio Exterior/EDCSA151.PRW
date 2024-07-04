/*============================================================* 
Classe    : EDCSA151
Parametro : -
Retorno   : -
Objetivo  : Imprimir Relatório de Saldos (Drawback Integrado)
By        : Allan Oliveira Monteiro
Data      : 08/03/2012
Revisão   :
Obs       : -
*=============================================================*/

*------------------*
Function EDCSA151()
*------------------*
Local oEDCSA151
Local lRet := .T. 
Local lShowMsg := .T. //Mostra Mensagem de erro
Local oReport 

Begin Sequence

   IF !AVFLAGS("SEQMI")
      lRet := .F.
      MsgInfo("Ambiente não possui atualização de Mercado Interno (Drawback Integrado) para a geração do relatório.","Aviso")  
      Break
   ENDIF
   Pergunte("EDCSA1", .F.)
   oEDCSA151:= EasyTReport():New("EDCSA151",lShowMsg)
   lRet := !oEDCSA151:lError
   
   If lRet
      oReport := oEDCSA151:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oEDCSA151:PrintReport()
   EndIf 

End Sequence

Return lRet


*-------------------------*
Function EDCSAFORM(cCampo)
*-------------------------*
Local xConteudo
Local oRefObj 
Local aOrd := SaveOrd("ED4")

Begin Sequence

Do Case

   Case cCampo == "VALCOBUS$"
      
      If Select("EEC") == 0 .Or. Select("EE9") == 0
         xConteudo := 0
         Break
      EndIf
   
   	  If EEC->EEC_COBCAM == "1"
         //xConteudo := Transf(EE9->EE9_VL_AC, AVSX3("EE9_VL_AC",6))
         xConteudo := EE9->EE9_VL_AC
      Else
         //xConteudo := Transf(0, AVSX3("EE9_VL_AC",6)) 
         xConteudo := 0
      EndIf
      
   Case cCampo == "VALSEMCOB"
   
      If Select("EEC") == 0 .Or. Select("EE9") == 0
         xConteudo := 0
         Break
      EndIf
   	  
      If EE9->(FieldPos("EE9_VLSCOB")) > 0
         If EEC->EEC_COBCAM == "1"
            //xConteudo := Transf(EE9->EE9_VLSCOB, AVSX3("EE9_VL_AC",6))
            xConteudo := EE9->EE9_VLSCOB
         Else
            //xConteudo := Transf(EE9->EE9_VL_AC+EE9->EE9_VLSCOB, AVSX3("EE9_VL_AC",6))
            xConteudo := EE9->EE9_VL_AC+EE9->EE9_VLSCOB
         EndIf
      Else
   	     If EEC->EEC_COBCAM == "1"
   	        //xConteudo := Transf(0, AVSX3("EE9_VL_AC",6))
   	        xConteudo := 0
         Else
            //xConteudo := Transf(EE9->EE9_VL_AC, AVSX3("EE9_VL_AC",6))
            xConteudo := EE9->EE9_VL_AC
         EndIf
	  EndIf
	  
   Case cCampo == "QTDNCM"
   
      If Select("ED3") == 0 .Or. Select("EE9") == 0
         xConteudo := 0
         Break
      EndIf 

      xConteudo := EasyConvQt(EE9->EE9_COD_I,{{ED3->ED3_UMPROD,EE9->EE9_QT_AC}},ED3->ED3_UMNCM,.F.,@oRefObj)
      
      If Valtype(xConteudo) <> "N"
         xConteudo := 0
      EndIf
      
   Case cCampo == "TIPOAC"
   
      If Select("ED0") == 0 
         xConteudo := ""
         Break
      EndIf  
   
      Do Case
         Case ED0->ED0_TIPOAC == "01"
            xConteudo := "Comum"
         Case ED0->ED0_TIPOAC == "02"
            xConteudo := "Intermediário"
         Case ED0->ED0_TIPOAC == "03"
            xConteudo := "Solidário"
         Case ED0->ED0_TIPOAC == "04"
            xConteudo := "Embarcação"
         Case ED0->ED0_TIPOAC == "05"
            xConteudo := "Fornecimento no Mercado Interno "
         Case ED0->ED0_TIPOAC == "06"
            xConteudo := "Genérico"
         Case ED0->ED0_TIPOAC == "08"
            xConteudo := "Genérico/Embarcação"
         OtherWise
            xConteudo := "Genérico/Fornec. Mercado Interno"
      EndCase
      
   Case cCampo == "DIASREST"
       
      If Select("ED4") == 0 .And. Select("ED0") == 0
         xConteudo := ""
         Break
      EndIf 
      
      ED4->(dbSetOrder(2))
      If ED4->(DbSeek(xFilial("ED4") + ED0->ED0_AC))
         xConteudo := If(!Empty(ED4->ED4_DT_VAL), Str((ED4->ED4_DT_VAL - dDataBase),5),"00")
      Else
         xConteudo := ""
      EndIf
      
      RestOrd(aOrd)   
      
End Case

End Sequence


Return xConteudo