/*
Programa        : EECPRL04.PRW
Objetivo        : Relatorio de Nacionalizações
Autor           : Ivo Santana Santos
Data/Hora       : 08/07/10 14:00
Obs.            :
*/

#include "AVERAGE.CH"
#include "protheus.ch"


/*
Funcao      : EICDA151
Parametros  : 
Retorno     : .F. - Falso
Objetivos   : Prepara a estrutura para a criação do relatório em TReport
Autor       : Ivo Santana Santos
Data/Hora   : 08/12/09 11:00
Revisao     :
Obs.        :
*/
*=======================*
  Function EICDA151()
*=======================*

Local lRet := .T.
Local aOrd := SaveOrd({"SW2","SW3","SW5","SW7","SB1"})

Local aArqs
Local cNomDbfC, aCamposC, cNomDbfD, aCamposD
Local aRetCrw, lZero := .t.
Local cQryCAP
Local cQryDET

Private dVencDe   := AVCTOD("  /  /  ")
Private dVencAte   := AVCTOD("  /  /  ")
Private cCodDA := Space(17)
Private cArqRpt, cTitRpt
Private oReport
Private lRelPersonal := FindFunction("TRepInUse") .And. TRepInUse()
      

   Begin Sequence
      IF Select("WorkId") > 0
         cArqRpt := WorkId->EEA_ARQUIV
         cTitRpt := AllTrim(WorkId->EEA_TITULO)
      Else 
         cArqRpt := "Rel.Nacionalizações.rpt"
         cTitRpt := "Relatório de Nacionalizações"
      Endif
      
      //Estrutura da work que receberá a tabela de capa(Relatório Saldo de Armazens)
      cNomDbfC:= "WORKCAP"
      aCamposC:= {}
      AADD(aCamposC,{"ARMAZEM" ,AVSX3("W2_ARMAZEM", 2), AVSX3("W2_ARMAZEM", 3), AVSX3("W2_ARMAZEM", 4)})
      AADD(aCamposC,{"PO_NUM"  ,AVSX3("W2_PO_NUM" , 2), AVSX3("W2_PO_NUM" , 3), AVSX3("W2_PO_NUM" , 4)})
      AADD(aCamposC,{"VENCDA"  ,AVSX3("W2_VENCDA" , 2), AVSX3("W2_VENCDA" , 3), AVSX3("W2_VENCDA" , 4)})
      AADD(aCamposC,{"COD_I"   ,AVSX3("W3_COD_I"  , 2), AVSX3("W3_COD_I"  , 3), AVSX3("W3_COD_I"  , 4)})
      AADD(aCamposC,{"HAWB_DA" ,AVSX3("W2_HAWB_DA", 2), AVSX3("W2_HAWB_DA", 3), AVSX3("W2_HAWB_DA", 4)})
      AADD(aCamposC,{"FORN"    ,AVSX3("W3_FORN"   , 2), AVSX3("W3_FORN"   , 3), AVSX3("W3_FORN"   , 4)})
      AADD(aCamposC,{"PART_N"  ,AVSX3("W3_PART_N" , 2), AVSX3("W3_PART_N" , 3), AVSX3("W3_PART_N" , 4)})
      AADD(aCamposC,{"IMPORT"  ,AVSX3("W2_IMPORT" , 2), AVSX3("W2_IMPORT" , 3), AVSX3("W2_IMPORT" , 4)})
      AADD(aCamposC,{"QTDE"    ,AVSX3("W3_QTDE"   , 2), AVSX3("W3_QTDE"   , 3), AVSX3("W3_QTDE"   , 4)})
      AADD(aCamposC,{"PRECO"   ,AVSX3("W3_PRECO"  , 2), AVSX3("W3_PRECO"  , 3), AVSX3("W3_PRECO"  , 4)})
      AADD(aCamposC,{"SALDO_Q" ,AVSX3("W5_SALDO_Q", 2), AVSX3("W5_SALDO_Q", 3), AVSX3("W5_SALDO_Q", 4)})
      AADD(aCamposC,{"PRCxSLD" ,AVSX3("W3_PRECO"  , 2), AVSX3("W3_PRECO"  , 3), AVSX3("W3_PRECO"  , 4)})
      AADD(aCamposC,{"POSICAO" ,AVSX3("W3_POSICAO", 2), AVSX3("W3_POSICAO", 3), AVSX3("W3_POSICAO", 4)})
      AADD(aCamposC,{"CODPROD"     ,"C",15,0})     

      //Estrutura da work que receberá a tabela de detalhes (As DI's relacionadas com as DA's)
      cNomDbfD:= "WORKDET
      aCamposD:= {}
      AADD(aCamposD,{"HAWB"    ,AVSX3("W7_HAWB"   , 2), AVSX3("W7_HAWB"   , 3), AVSX3("W7_HAWB"   , 4)}) 
      AADD(aCamposD,{"QTDE"    ,AVSX3("W7_QTDE"   , 2), AVSX3("W7_QTDE"   , 3), AVSX3("W7_QTDE"   , 4)})
      AADD(aCamposD,{"PRECO"   ,AVSX3("W7_PRECO"  , 2), AVSX3("W7_PRECO"  , 3), AVSX3("W7_PRECO"  , 4)})
      AADD(aCamposD,{"DI_NUM"  ,AVSX3("W6_DI_NUM" , 2), AVSX3("W6_DI_NUM" , 3), AVSX3("W6_DI_NUM" , 4)})
      AADD(aCamposD,{"DTREG_D" ,AVSX3("W6_DTREG_D", 2), AVSX3("W6_DTREG_D", 3), AVSX3("W6_DTREG_D", 4)})
      AADD(aCamposD,{"PO_NUM"  ,AVSX3("W7_PO_NUM" , 2), AVSX3("W7_PO_NUM" , 3), AVSX3("W7_PO_NUM" , 4)})
      AADD(aCamposD,{"POSICAO" ,AVSX3("W7_POSICAO", 2), AVSX3("W7_POSICAO", 3), AVSX3("W7_POSICAO", 4)})
      AADD(aCamposD,{"CODPROD"     ,"C",15,0})
      
      aArqs := {}
      AADD( aArqs, {cNomDbfC,aCamposC,"CAP","CODPROD"})
      AADD( aArqs, {cNomDbfD,aCamposD,"DET","CODPROD"})

      aRetCrw := CrwNewFile(aArqs)

      IF ! TelaGets() //Função que chama a tela de filtro
         lRet := .F.
         BREAK
      Endif 
     
      CONFIRMSX8()

      SysRefresh()
      
      lZero := .t.
      aDTAVERB := {}
      
      //Montagem das querys
      
      cQryCAP := "select W2_ARMAZEM,W3_PO_NUM,W2_VENCDA,W3_COD_I,B1_DESC,W2_HAWB_DA,W3_FORN,W3_PART_N,W2_IMPORT,W3_QTDE,W3_SALDO_Q,W5_SALDO_Q,";
               + "W3_PRECO,W3_POSICAO from"; 
               + " (((" + RETSQLNAME("SW3") + " W3 inner join " + RETSQLNAME("SW2") + " W2 on W3_FILIAL = '" + xFilial("SW3") + "' and W2_FILIAL = '" + xFilial("SW2") + "' and";
               + " W3_PO_NUM = W2_PO_NUM and"; 
               + " W2.D_E_L_E_T_ = ' ' and"; 
               + " W3.D_E_L_E_T_ = ' ' and"
      cQryDET := "select W7_HAWB,W7_PRECO,W7_QTDE,W7_PO_NUM,W7_POSICAO,W6_DI_NUM,W6_DTREG_D from"; 
               + " (((((" + RETSQLNAME("SW3") + " W3 inner join " + RETSQLNAME("SW2") + " W2 on W3_FILIAL = '" + xFilial("SW3") + "' and W2_FILIAL = '" + xFilial("SW2") + "' and";
               + " W3_PO_NUM = W2_PO_NUM and"; 
               + " W2.D_E_L_E_T_ = ' ' and"; 
               + " W3.D_E_L_E_T_ = ' ' and"
      
      If !Empty(cCodDA)
         
         cQryCAP += " W2_HAWB_DA = " + "'"+cCodDA+"'"
         cQryDET += " W2_HAWB_DA = " + "'"+cCodDA+"'"
      
      Else
          
         cQryCAP += " W2_HAWB_DA <> ' '"
         cQryDET += " W2_HAWB_DA <> ' '"
      
      EndIf           
      
      If !Empty(dVencDe)
           
         cQryCAP += " and W2_VENCDA >= '" + DtoS(dVencDe) + "'"
         cQryDET += " and W2_VENCDA >= '" + DtoS(dVencDe) + "'"
        
      EndIf
           
      If !Empty(dVencAte)
           
         cQryCAP += " and W2_VENCDA <= '" + DtoS(dVencAte) + "'"
         cQryDET += " and W2_VENCDA <= '" + DtoS(dVencAte) + "'"         
           
      EndIf
               
      cQryCAP += " and W3.W3_SEQ = 0)";
              + " inner join " + RETSQLNAME ("SB1") + " B1 on '" + xFilial("SB1") + "' = B1_FILIAL and" ;
               + " B1_COD = W3_COD_I";
               + " and B1.D_E_L_E_T_= ' ')";
              + " inner join " + RETSQLNAME("SW5") + " W5 on '" +  xFilial("SW5") + "' = W5_FILIAL and";
               + " W5_PO_NUM = W3_PO_NUM and";
               + " W5_POSICAO = W3_POSICAO and"; 
               + " W5_SEQ = 0 and W5.D_E_L_E_T_ = ' ')"
      cQryDET += " and W3.W3_SEQ = 0)";
              + " inner join " + RETSQLNAME("SB1") + " B1 on '" + xFilial("SB1") + "' = B1_FILIAL and" ;
               + " B1_COD = W3_COD_I";
               + " and B1.D_E_L_E_T_= ' ')";
              + " inner join " + RETSQLNAME("SW5") + " W5 on '" +  xFilial("SW5") + "' = W5_FILIAL and";
               + " W5_PO_NUM = W3_PO_NUM and";
               + " W5_POSICAO = W3_POSICAO and"; 
               + " W5_SEQ = 0 and W5.D_E_L_E_T_ = ' ')";
              + " inner join " + RETSQLNAME("SW7") + " W7 on '" + xFilial("SW7") + "' = W7.W7_FILIAL and";
               + " W7.W7_PO_NUM = W3.W3_PO_NUM and";
               + " W7.W7_POSICAO = W3.W3_POSICAO and";
               + " W7.D_E_L_E_T_ = ' ')";
              + " inner join " + RETSQLNAME("SW6") + " W6 on '" + xFilial("SW6") + "' = W6_FILIAL and" ;
               + " W6_HAWB = W7_HAWB and W6.D_E_L_E_T_ = ' ')"
    
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQryCAP), "QCAP", .F., .T.) 
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQryDET), "QDET", .F., .T.) 
      
      //Conversão do conteudo da colunas de data string para data (20100522 -> 22/05/10)                
      TCSetField("QCAP","W2_VENCDA","D")
      TCSetField("QDET","W6_DTREG_D","D")

      QCAP->(DbGoTop())   
      QDET->(DbGoTop())
            
      //Gravando o conteudo da query para as works de capa e detalhe    
      While QCAP->(!EOF())
                      
         CAP->(DbAppend())
         CAP->ARMAZEM  := QCAP->W2_ARMAZEM
	     CAP->PO_NUM   := QCAP->W3_PO_NUM
  	     CAP->VENCDA   := QCAP->W2_VENCDA
	     CAP->COD_I    := QCAP->W3_COD_I
	     CAP->HAWB_DA  := QCAP->W2_HAWB_DA
	     CAP->FORN     := QCAP->W3_FORN
	     CAP->PART_N   := QCAP->W3_PART_N
	     CAP->IMPORT   := QCAP->W2_IMPORT
	     CAP->QTDE     := QCAP->W3_QTDE
	     CAP->COD_I    := QCAP->W3_COD_I
	     CAP->PRECO    := QCAP->W3_PRECO
	     CAP->SALDO_Q  := QCAP->W5_SALDO_Q
	     CAP->PRECO    := QCAP->W3_PRECO
	     CAP->POSICAO  := QCAP->W3_POSICAO
	     
	     QCAP->(DbSkip())
	 	    
	  EndDo    

      While QDET->(!EOF())
      
         DET->(DbAppend())
         DET->HAWB    := QDET->W7_HAWB
         DET->QTDE    := QDET->W7_QTDE
         DET->PRECO   := QDET->W7_PRECO
         DET->DI_NUM  := QDET->W6_DI_NUM
         DET->DTREG_D := QDET->W6_DTREG_D
         DET->PO_NUM  := QDET->W7_PO_NUM
         DET->POSICAO := QDET->W7_POSICAO
               
         QDET->(DbSkip())
	 	    
	  EndDo 
      
      QCAP->(dbCloseArea())
      QDET->(dbCloseArea())

      //Função para a definição do relatório e impressão do relatório
      oReport := ReportDef()
      oReport:PrintDialog() 

End Sequence

   //retorna a situacao anterior ao processamento
   RestOrd(aOrd)
   
   // Fecha e apaga os arquivos temporarios
   CrwCloseFile(aRetCrw,.T.)

Return .T.                   

*==============================================================================*
* FIM DA FUNÇÃO EECPRL                                                         *
*==============================================================================*                           
  

/*
Funcao      : TelaGets
Parametros  : 
Retorno     :  
Objetivos   : Montagem da tela de filtro para o relatório
Autor       : Ivo Santana Santos
Data/Hora   : 08/12/09 11:00
Revisao     :
Obs.        :
*/    
*=======================*
Static Function TelaGets
*=======================*

Local lRet  := .f.

Local oDlg

Local nOpc := 0
Local bOk  := {|| nOpc:=1, oDlg:End() }
Local bCancel := {|| oDlg:End() }
   
Begin Sequence
   
   DEFINE MSDIALOG oDlg TITLE "Filtro" From 9, 0 To 26, 50 OF oMainWnd
   
      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 22/07/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      //De Vencto. DA
      @ 25,05 SAY "De Vencto. DA" OF oPanel PIXEL 
      @ 25,50 MSGET dVencDe SIZE 40,8 OF oPanel PIXEL Valid DA150Data()
       
      //Até Vencto. DA
      @ 38,05 SAY "Até Vencto. DA" OF oPanel PIXEL 
      @ 38,50 MSGET dVencAte SIZE 40,8 OF oPanel PIXEL Valid DA150Data()
      
      //Codigo da DA
      @ 51,05 SAY "Código DA" OF oPanel PIXEL 
      @ 51,50 MSGET cCodDA   F3 "SW2DA" PICTURE "@!" SIZE 50,8 OF oPanel PIXEL Valid If(Empty(cCodDA),,DA150ValSeek(SW2->W2_PO_NUM,"SW2"))
      
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   IF nOpc == 1
      lRet := .t.
   Endif 
   
End Sequence

Return lRet

*==============================================================================*
* FIM DA FUNÇÃO TelaGets                                                       *
*==============================================================================*                           

/*
Funcao      : ReportDef
Parametros  : 
Retorno     : Objeto com o relatório
Objetivos   : Definição do TReport
Autor       : Ivo Santana Santos
Data/Hora   : 08/07/2010
Revisao     :
Obs.        :
*/
*==========================*
Static Function ReportDef()
*==========================*

//Variaveis
Local cDescr := "Relatório de Nacionalizações" 
Local oQuebra
Local i

   //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
   aTabelas := {"CAP","DET", "SW2","SW3","SW5","SW7","SB1"}

   //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
   aOrdem   := {} 
   
   //Parâmetros:            Relatório , Titulo  ,  Pergunte , Código de Bloco do Botão OK da tela de impressão , Descrição
   oReport := TReport():New("EICDA151", cDescr ,""         , {|oReport| ReportPrint(oReport)}                 , cDescr    )
   
   //Inicia o relatório como paisagem.
   oReport:oPage:lLandScape := .T.
   oReport:oPage:lPortRait := .F.
  
   //Define os objetos com as seções do relatório
   oSecao1 := TRSection():New(oReport,"Itens no armazem",{"SW2","SW3","SW5","CAP"})
   oSecao2 := TRSection():New(oReport,"Nascionalizacoes",{"SW7","SW6","SW5","DET"})
   oSecao2:SetLeftMargin(10)
   
   //Definição das colunas de impressão da seção 1 - Capa
   //           objeto ,cName    ,cAlias,  cTitle            ,       cPicture        ,nSize,  lPixel   ,bBlock                  ,cAlign ,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold
   TRCell():New(oSecao1,"ARMAZEM", "CAP", "ArmazeM"          ,       "9999999"       ,  7  ,           ,                        ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )   
   TRCell():New(oSecao1,"PO_NUM" , "CAP", "No. P.O."         ,         "@!"          , 15  ,           ,                        ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )   
   TRCell():New(oSecao1,"VENCDA" , "CAP", "Dt.Vencto DA"     ,         "@D"          ,  8  ,           ,                        ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )   
   TRCell():New(oSecao1,"COD_I"  , "CAP", "Codigo Item"      ,         "@!"          , 15  ,           ,                        ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )
   TRCell():New(oSecao1,"HAWB_DA", "CAP", "Processo DA"      ,         "@!"          , 17  ,           ,                        ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )   
   TRCell():New(oSecao1,"FORN"   , "CAP", "Fornecedor"       ,         "@!"          ,  6  ,           ,                        ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )   
   TRCell():New(oSecao1,"PART_N" , "CAP", "Part-Number"      ,         "@!"          , 20  ,           ,                        ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )   
   TRCell():New(oSecao1,"IMPORT" , "CAP", "Importador"       ,         "@!"          ,  2  ,           ,                        ,"LEFT" ,          ,            ,          ,         , .T.     ,        ,        ,     )   
   TRCell():New(oSecao1,"QTDE"   , "CAP", "Qtde Pedida"      ,"@E 999,999,999.999"   , 13  ,           ,                        ,"RIGHT",          ,            ,          ,         , .F.     ,        ,        ,     )
   TRCell():New(oSecao1,"PRECO"  , "CAP", "Preco Unit."      ,"@E 999,999,999.99999" , 15  ,           ,                        ,"RIGHT",          ,            ,          ,         , .F.     ,        ,        ,     )   
   TRCell():New(oSecao1,"SALDO_Q", "CAP", "Saldo Qtde"       ,"@E 999,999,999.999"   , 13  ,           ,                        ,"RIGHT",          ,            ,          ,         , .F.     ,        ,        ,     )
   TRCell():New(oSecao1,"PRCxSLD", "CAP", "Preco X Saldo"    ,"@E 999,999,999.99999" , 15  ,           ,{||CAP->QTDE*CAP->PRECO},"RIGHT",          ,            ,          ,         , .F.     ,        ,        ,     )   
    
   //Definição das colunas de impressão da seção 2 - Detalhes
   //           objeto ,cName         ,cAlias,  cTitle            ,     cPicture         ,nSize,  lPixel   ,bBlock ,cAlign ,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold
   TRCell():New(oSecao2,"HAWB"        , "DET", "Processo"         ,         "@!"         , 17,           ,       ,"LEFT" ,          ,            ,          ,         , .F.     ,        ,        ,     )
   TRCell():New(oSecao2,"QTDE"        , "DET", "Qtde"             ,"@E 999,999,999.999"  , 13,           ,       ,"RIGHT",          ,            ,          ,         , .F.     ,        ,        ,     )
   TRCell():New(oSecao2,"PRECO"       , "DET", "Preco"            ,"@E 999,999,999.99999", 15,           ,       ,"RIGHT",          ,            ,          ,         , .F.     ,        ,        ,     )
   TRCell():New(oSecao2,"DI_NUM"      , "DET", "Numero da DI"     ,  "@R 99/9999999-9"   , 10,           ,       ,"LEFT" ,          ,            ,          ,         , .F.     ,        ,        ,     )
   TRCell():New(oSecao2,"DTREG_D"     , "DET", "Dt. da DI"        ,         "@D"         ,  8,           ,       ,"LEFT" ,          ,            ,          ,         , .F.     ,        ,        ,     )  
   
   oReport:bOnPageBreak := {||If(oReport:Page()>1,oReport:Section("Itens no armazem"):PrintHeader(),)}   
   
Return oReport

*==============================================================================*
* FIM DA FUNÇÃO ReportDef                                                      *
*==============================================================================*                           
 
/*
Funcao      : ReportPrint
Parametros  :  oReport - Objeto com a definição do relatório em TReport, seções, quebras, etc.
Retorno     : .T. - Verdadeiro
Objetivos   : Impresão do relatório
Autor       : Ivo Santana Santos
Data/Hora   : 08/07/2010
Revisao     :
Obs.        :
*/

*==================================*
Static Function ReportPrint(oReport)
*==================================*


   //Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
   TRPosition():New(oReport:Section("Itens no armazem"),"SW2", 1,{|| xFilial("SW2") + CAP->PO_NUM  })
   TRPosition():New(oReport:Section("Itens no armazem"),"SW3", 8,{|| xFilial("SW3") + CAP->PO_NUM + CAP->POSICAO  })
   TRPosition():New(oReport:Section("Itens no armazem"),"SW5", 2,{|| xFilial("SW5") + CAP->HAWB_DA })
   TRPosition():New(oReport:Section("Nascionalizacoes"),"SW5", 2,{|| xFilial("SW5") + DET->HAWB    })
   TRPosition():New(oReport:Section("Nascionalizacoes"),"SW6", 1,{|| xFilial("SW6") + DET->HAWB    })
   TRPosition():New(oReport:Section("Nascionalizacoes"),"SW7", 1,{|| xFilial("SW7") + DET->HAWB    })   

   //Inicio da impressão da seção 1.
   oReport:Section("Itens no armazem"):Init()

   
   oReport:SetMeter(CAP->(EasyRecCount()))
   CAP->(dbGoTop())
   DET->(dbGoTop())

   FilePrint:=E_Create(,.F.)
   IndRegua("CAP",FilePrint+TEOrdBagExt(),"ARMAZEM + HAWB_DA")

   //Laço principal
     
   Do While CAP->(!EoF()) .And. !oReport:Cancel()
      oReport:SkipLine(1)
      oReport:Section("Itens no armazem"):PrintLine() //Impressão da linha
      //Inicio da impressão da seção 2.
      oReport:Section("Nascionalizacoes"):Init()    
      Do While DET->(!EoF())

         If(DET->PO_NUM == CAP->PO_NUM .AND. DET->POSICAO == CAP->POSICAO) 

            oReport:Section("Nascionalizacoes"):PrintLine() //Impressão da linha
     
         EndIf
         DET->(DbSkip())
                  
      EndDo
      //Fim da impressão da seção 2
         oReport:Section("Nascionalizacoes"):Finish()
      oReport:IncMeter()                     //Incrementa a barra de progresso
      oReport:SkipLine(1)
      CAP->(DbSkip())
      DET->(dbGoTop())
      
   EndDo

   //Fim da impressão da seção 1
   oReport:Section("Itens no armazem"):Finish()


   FERASE(FilePrint+TEOrdBagExt())

Return .T.

*==============================================================================*
* FIM DA FUNÇÃO ReportPrint                                                    *
*==============================================================================*

