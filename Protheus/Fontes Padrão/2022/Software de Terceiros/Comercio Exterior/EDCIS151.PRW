/*
Programa   : EDCIS151
Objetivo   : Impressão do Relatório de Comprovação de Insumos 
Retorno    : xConteudo
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 01/08/12 - 15:33 
Obs.       : 
*/ 
Function EDCIS151() 


Local oEDCIS151
Local lRet := .T. 
Local lShowMsg := .T. //Mostra Mensagem de erro
Local oReport 

Begin Sequence

   IF !AVFLAGS("SEQMI") 
      lRet := .F.
      MsgInfo("Ambiente não possue atualização de Mercado Interno(Drawback integrado) para Geração do Relatório.","Aviso")  
      Break
   ENDIF
   
   If !ED0->(FIELDPOS("ED0_PERCPE")) > 0
      lRet := .F.
      MsgInfo("Ambiente não possue atualização do campo Percentual de Perda(ED0_PERCPE), esse campo esta na chave da quebras dos itens a Importar e é necessario para impressao do Relatório.","Aviso")  
      Break
   ENDIF
   
   If !ED2->(FIELDPOS("ED2_UMANEX")) > 0
      lRet := .F.
      MsgInfo("Ambiente não possue atualização do campo Unidade de Anexo (UMANEX), esse campo esta na chave da quebras dos itens a Importar e é necessario para impressao do Relatório.","Aviso")
      Break
   EndIf

   oEDCIS151:= EasyTReport():New("EDCIS150",lShowMsg)
   lRet := !oEDCIS151:lError
   
   If lRet
      oReport := oEDCIS151:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oEDCIS151:PrintReport()
   EndIf 

End Sequence

Return lRet  


*-------------------------*
Function EDCISFORM(cCampo)
*-------------------------*
Local xConteudo

Begin Sequence

Do Case

   Case cCampo == "QTDCONS"
      
      If Select("ED4") == 0 
         xConteudo := 0
         Break
      EndIf
   
   	  xConteudo := ED4->ED4_QTDCAL - ED4->ED4_QT_DI
      
      
   Case cCampo == "QTDEXP"
   
      If Select("ED4") == 0 
         xConteudo := 0
         Break
      EndIf
   	  
      xConteudo := (ED4->ED4_QTDCAL - ED4->ED4_QT_DI) - ED4_SQTDEX
     
   Case cCampo == "QTDNCMCONS"
   
      If Select("ED4") == 0 
         xConteudo := 0
         Break
      EndIf 

      xConteudo :=  ED4->ED4_QTDNCM - ED4_SNCMDI
      
   Case cCampo == "QTDNCMEXP"
   
      If Select("ED4") == 0 
         xConteudo := 0
         Break
      EndIf  
   
      xConteudo :=  (ED4->ED4_QTDNCM - ED4_SNCMDI) - ED4->ED4_SNCMEX
      
   Case cCampo == "ORIGEM"
       
      If Select("EDD") == 0 
         xConteudo := ""
         Break
      EndIf 
      
      IF !EMPTY(EDD->EDD_PO_NUM) .And. EMPTY(EDD->EDD_HAWB)
         xConteudo := "MERCADO INTERNO"
      ELSEIF EMPTY(EDD->EDD_PO_NUM) .And. !EMPTY(EDD->EDD_HAWB)
         xConteudo := "DI EXTERNA" 
      ELSE
         xConteudo := "EASY IMPORT CONTROL" 
      ENDIF
      
   Case cCampo == "ED2ORI"  
   
      If Select("ED2") == 0 
         xConteudo := ""
         Break
      EndIf 
      
      IF !EMPTY(ED2->ED2_PO_NUM) .And. !EMPTY(ED2->ED2_HAWB)
         xConteudo := "EASY IMPORT CONTROL" 
      ElseIf !EMPTY(ED2->ED2_PO_NUM)  
         xConteudo := "MERCADO INTERNO"
      Else
         xConteudo := "DI EXTERNA" 
      EndIf
      
      
   Case cCampo == "QTDNEC"
   
      xConteudo := ED2->ED2_QTD
      
End Case

End Sequence


Return xConteudo