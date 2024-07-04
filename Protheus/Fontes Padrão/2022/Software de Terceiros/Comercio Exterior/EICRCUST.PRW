#Include "Average.ch"
#Include "EICRCUST.ch"

/*
Programa   : EICRCUST
Objetivo   : Relatório - Custos de Importação
Autor      : Saimon Vinicius Gava 
Data/Hora  : 01/12/2009 10:55:57
*/
/* 
Funcao     : EICRCUST() 
Parametros : Nenhum 
Retorno    : 
Objetivos  : 
Autor      : Saimon Vinicius Gava 
Data/Hora  : 18/11/2009 17:25:07
Revisão    : Guilherme Fernandes Pilan - GFP - 30/03/2012
Comentarios: Foi incluido tratamento antes da chamada do EICRELCUST onde verifica-se se a WorkQry possui registros para a geração do relatorio.
             Desta forma, o relatorio não é gerado em branco.
*/  
Function EICRCUST()
PRIVATE nPos_aRotina := 0  // GFP - 15/08/2013 - Variavel para Ponto de Entrada
EICRELCUST()

Return .T.

Static Function EICRELCUST()
#IFDEF TOP
	If FindFunction("TRepInUse") .And. TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	Else
		Aviso(STR0009,STR0002,{STR0003}) //"Nao disponivel"###"Esta funcionalidade so esta disponivel para os relatorios personalizaveis"###"Fechar"
	Endif
#ELSE
	Aviso(STR0009,STR0004,{STR0003}) //"Nao disponivel"###"Esta funcionalidade so esta disponivel para uso com bancos de dados relacionais"###"Fechar"
#ENDIF

Return .F.
 
/* 
Funcao     : RCUSTGRVWK() 
Parametros : Nenhum 
Retorno    : 
Objetivos  : Gravação dos dados da Work
Autor      : Saimon Vinicius Gava 
Data/Hora  : 01/12/2009 10:56:07
*/
*-----------------------------*                              
Function RCUSTGRVWK()
*-----------------------------*
//Local oReport
Local cImpPre:="" ,cParam:="" ,lWkVazia := .F.
Local dDataIni,dDataFim :=CToD("  /  /    ")
Local cTipoParc
Local i := 0
Local cProcesso := ""          // RRV - 28/08/2012 - Ajuste para que a atribuição do valor de Pis e Cofins funcione corretamente. 
Local lRet:= .T.//TRP - 06/09/12
Local aOrdSF1 := saveOrd("SF1") //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
Local cMsgLogPrc   := ""
Private aSWDProc   := {}
Private aProcEncer := {}
Private lWB_TP_CON := SWB->(FieldPos("WB_TP_CON")) > 0 .and. SW9->(FieldPos("W9_FORNECC")) > 0 .and.;
                      SW9->(FieldPos("W9_LOJAC")) > 0  .and. SW9->(FieldPos("W9_COMPV")) > 0   .and.;
                      SW9->(FieldPos("W9_PERCOM")) > 0 .and. SW9->(FieldPos("W9_VALCOM")) > 0 .and.;
                      SWB->(FieldPos("WB_TIPOCOM")) > 0 .and. SW6->(FieldPos("W6_CONDP_F")) > 0 .and.;
                      SW6->(FieldPos("W6_DIASP_F")) > 0 .and. SW6->(FieldPos("W6_CONDP_S")) > 0 .and.;
                      SW6->(FieldPos("W6_DIASP_S")) > 0 .and. SWB->(FieldPos("WB_TIPOCOM")) > 0
Private lGeraCom      := EasyGParam("MV_CAMBCOM",,.F.)                      
Private lAutomatico := .T.                  
SW6->(dbSetOrder(1))
SW9->(dbSetOrder(3))
SA2->(dbSetOrder(1))
SWB->(dbSetOrder(1))
SY5->(dbSetOrder(1))
SYW->(dbSetOrder(1))
SF1->(dbSetOrder(5))
SWD->(dbSetOrder(1))
SYB->(dbSetOrder(1))
SWN->(dbSetOrder(1))
SYT->(dbSetOrder(1))


If !Empty(MV_PAR01)
   cParam += If(!Empty(cParam)," AND ","")+" SW6.W6_IMPORT = '"+mv_par01+"'"
EndIf
If !Empty(MV_PAR02)
   cParam += If(!Empty(cParam)," AND ","")+" SW6.W6_HAWB ='"+mv_par02+"'"
EndIf
If !Empty(MV_PAR03)
   cParam += If(!Empty(cParam)," AND ","")+" SF1.F1_EMISSAO > '"+dToS(mv_par03)+"'"
EndIf
If !Empty(MV_PAR04)
   cParam += If(!Empty(cParam)," AND ","")+" SF1.F1_EMISSAO < '"+DToS(mv_par04)+"'"
EndIf

If !Empty(cParam)
   cParam := "%WHERE" + cParam + " ORDER BY SW6.W6_IMPORT%"
Else
   cParam := "%ORDER BY SW6.W6_IMPORT%"
EndIf

IF SELECT("Work") > 0
   Work->(DbCloseArea())
ENDIF

// Nopado por GFP - 30/03/2012 - Este bloco nopado está na função EICQUERY() pois a mesma é chamada varias vezes.
/*
IF SELECT("WorkQry") > 0
   WorkQry->(DbCloseArea())
ENDIF

BeginSql Alias "WorkQry"
   SELECT SF1.F1_HAWB,SF1.F1_EMISSAO FROM %table:SF1% SF1 INNER JOIN %table:SW6% SW6 On SF1.F1_HAWB = SW6.W6_HAWB
      AND SF1.%NotDel% AND SF1.F1_FILIAL = %xFilial:SF1% AND SW6.%NotDel% AND SW6.W6_FILIAL = %xFilial:SW6%
      %Exp:cParam%    
EndSql
*/

//EICQUERY()    // GFP - 30/03/2012

//TRP - 06/09/12 - Query para extração dos dados a serem exibidos no relatório
lRet := EICQUERY()
If !lRet
   Help(" ",1,"AVG0005112")//"Não há Dados para Impressão!"
   Return .F.
EndIf

IF SELECT("WorkQry") = 0
   Aviso(STR0009,STR0023,{STR0003})
ENDIF

Processa({|| RCUSTWork()},"Criação do Arquivo de Trabalho")
aTabInv:={}
WorkQry->(dbGoTop())
//Valores Previstos
While WorkQry->(!EOF())
   nVlrPis := 0 //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
   nVlrCof := 0 //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
   If Empty(cProcesso) .Or. cProcesso # WorkQry->F1_HAWB // RRV - 28/08/2012 - Ajuste para que a atribuição do valor de Pis e Cofins por processo funcione corretamente.
      cProcesso := WorkQry->F1_HAWB
      If !Empty(MV_PAR05) .And. Alltrim(Str(MV_PAR05)) $ cSim
         If SW6->(dbSeek(xFilial("SW6")+WorkQry->F1_HAWB)) .And. SW9->(dbSeek(xFilial("SW9")+WorkQry->F1_HAWB))
            aTabInv := {}
            If Empty(SW6->(W6_DT_ENCE))
               While SW9->(!EOF()) .And. SW9->(W9_FILIAL+W9_HAWB) == SW6->(W6_FILIAL+W6_HAWB)
                  If(!Empty(SW6->W6_DT_EMB),dDtEMB := SW6->W6_DT_EMB,dDtEMB := SW6->W6_DT_ETA)
                  dDtaVista:=IF(!EMPTY(SW6->W6_DT_DESEM),SW6->W6_DT_DESEM,dDtEMB)
                  EicCalcPagto(SW9->W9_INVOICE+SW9->W9_FORN+SW9->W9_FORLOJ+SW9->W9_HAWB,DI500RetVal("TOT_INV", "TAB", .T.),;
                  dDtEMB,dDtaVista,(SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3)),aTabInv,,,,,If(lWB_TP_CON .and. lGeraCom,SW9->W9_VALCOM,0)) //OS 0639/01
                  SW9->(dbSkip())
               EndDo
            EndIf
               
            For i:=1 To Len(aTabInv)
               SW9->(dbSetOrder(1))
               SW9->(dbSeek(xFilial("SW9")+aTabInv[i][1]))
               //If !Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"101"+SW9->W9_INVOICE))  //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
                  Work->(dbAppend())
                  Work->WKIMPORT  := SW6->W6_IMPORT
                  SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
                  Work->WKNMIMPORT:= SYT->YT_NOME_RE
                  Work->WKHAWB    := SW6->W6_HAWB
                  Work->WKDESPESA := "101"
                  Work->WKDESCR   := "Parc. Câmbio:" + aTabinv[i][4]
                  Work->WKDOCTO   := SW9->W9_INVOICE
                  Work->WKFORN    := SW9->W9_FORN
                  SA2->(dbSeek(xFilial("SA2")+SW9->W9_FORN))
                  Work->WKFDESC   := SA2->A2_NREDUZ
                  Work->WKDATA    := aTabInv[i][3]
                  Work->WKMOEDA   := SW9->W9_MOE_FOB
                  Work->WKVLPMOE  := aTabInv[i][2]
                  Work->WKVLPREAL := aTabInv[i][2] * BuscaTaxa(SW9->W9_MOE_FOB,If(Empty(EasyGParam("MV_TXCUST",,"")),dDataBase,&(EasyGParam("MV_TXCUST",,""))),,.F.,.T.,,) //RRV - 04/12/2012 - Incluido parametro para busca da taxa da moeda de acordo o campo informado.  // GFP - 18/06/2013
               //endIf
            Next i

            EICTP252({SW6->W6_HAWB,SW6->W6_IMPORT})
            SW9->(dbSetOrder(3))
            If Select("WorkTP") > 0 .and. Empty(SW6->(W6_DT_ENCE))
               WorkTP->(dbGoTop())
               While WorkTP->(!EOF())
                  If WorkTP->WKDESPESA <> "101"
                     If !Work->(dbSeek(SW6->W6_IMPORT+SW6->W6_HAWB+WorkTP->WKDESPESA))   
                        Work->(dbAppend())
                        Work->WKIMPORT := SW6->W6_IMPORT
                        SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
                        Work->WKNMIMPORT:= SYT->YT_NOME_RE
                        Work->WKHAWB   := SW6->W6_HAWB
                        Work->WKDESPESA:= WorkTP->WKDESPESA
                        Work->WKDESCR  := WorkTP->WKDESPDESC
                        Work->WKVLPREAL:= WorkTP->WKVL_PAGTO
                     Else
                        Work->WKVLPREAL+= WorkTP->WKVL_PAGTO
                     EndIf
                  EndIf
                  WorkTP->(dbSkip())
               EndDo
            EndIf
         EndIf
      EndIf   
   EndIf   
   SW6->(dbSeek(xFilial("SW6")+cProcesso))
   If !Empty(SW6->W6_DT_ENCE)
      WorkQry->(dbSkip())
      loop
   EndIf
   //Valores Realizados
   If Work->(EasyRecCount()) =  0 .Or. lWkVazia
      lWkVazia := .T.
      If SW6->(dbSeek(xFilial("SW6")+WorkQry->F1_HAWB)) .And. SW9->(dbSeek(xFilial("SW9")+WorkQry->F1_HAWB))
         If SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB)) 
            If !Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"101"+SW9->W9_INVOICE))
               While SWB->(!EOF()) .And. SWB->(WB_FILIAL+WB_HAWB) == SW6->(W6_FILIAL+W6_HAWB)
                  If SWB->WB_EVENT == "101"  //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
                     If !Empty(SWB->WB_CA_DT) // Data de Liquidação
                        Work->(dbAppend())
                        Work->WKIMPORT := SW6->W6_IMPORT
                        SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
                        Work->WKNMIMPORT:= SYT->YT_NOME_RE
                        Work->WKHAWB   := SW6->W6_HAWB
                        Work->WKDESPESA:= "101"
                        cTipoParc := TipoParc(SWB->WB_TIPOREG)
                        Work->WKDESCR  := IIF(!Empty(cTipoParc),cTipoParc,"Parc. Câmbio: " + SWB->WB_TIPO)
                        Work->WKDOCTO  := SWB->WB_INVOICE
                        Work->WKDATA   := SWB->WB_CA_DT
                        Work->WKFORN   := SWB->WB_FORN
                        SA2->(dbSeek(xFilial("SA2")+SWB->WB_FORN+SWB->WB_LOJA))
                        Work->WKFDESC  := SA2->A2_NREDUZ
                        Work->WKMOEDA  := SWB->WB_MOEDA
                        Work->WKTAXA   := SWB->WB_CA_TX
                        If SWB->WB_TIPOREG == "P" //Pagamento Antecipado
                           Work->WKVLRMOE := SWB->WB_PGTANT
                           Work->WKVLRREAL:= SWB->WB_PGTANT * SWB->WB_CA_TX
                        Else //Parcela Cambio Invoice
                           Work->WKVLRMOE := SWB->WB_FOBMOE
                           Work->WKVLRREAL:= SWB->WB_FOBMOE * SWB->WB_CA_TX
                        EndIf
                     EndIf
                  endIf
                  SWB->(dbSkip())
               EndDo
            EndIf
      EndIf
       //Frete
      If !Empty(SW6->W6_VLFRECC)
	      If !Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"102"+SW6->W6_HOUSE)) //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
	         Work->(dbAppend())
	         Work->WKIMPORT := SW6->W6_IMPORT
	         SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
	         Work->WKNMIMPORT:= SYT->YT_NOME_RE
	         Work->WKHAWB   := SW6->W6_HAWB
	         Work->WKDESPESA:= "102"
	         Work->WKDESCR  := "Frete Internacional"
	         Work->WKDOCTO  := SW6->W6_HOUSE
	         Work->WKDATA   := SW6->W6_VENCFRE
	         //SY5->(dbSeek(xFilial("SY5")+SW6->W6_FORNECF)) //WHRS TE-5259 511736 / MTRADE-767 - Relatorio de Custos
	         Work->WKFORN   := SW6->W6_FORNECF
	         SA2->(dbSeek(xFilial("SA2")+SW6->W6_FORNECF+SW6->W6_LOJAF))
	         Work->WKFDESC  := SA2->A2_NREDUZ   
	         Work->WKMOEDA  := SW6->W6_FREMOED
	         Work->WKTAXA   := SW6->W6_TX_FRET
	         Work->WKVLRMOE := SW6->W6_VLFRECC
	         Work->WKVLRREAL:= SW6->W6_VLFRECC * SW6->W6_TX_FRET
	      EndIf
      EndIf
         
      //Seguro
      If !Empty(SW6->W6_VL_USSE)
	      If !Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"103"+SW6->W6_NF_SEG)) //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
			   Work->(dbAppend())
			   Work->WKIMPORT := SW6->W6_IMPORT
			   SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
			   Work->WKNMIMPORT:= SYT->YT_NOME_RE
			   Work->WKHAWB   := SW6->W6_HAWB
			   Work->WKDESPESA:= "103"
			   Work->WKDESCR  := "Seguro Internacional"
			   Work->WKDOCTO  := SW6->W6_NF_SEG
			   Work->WKDATA   := SW6->W6_VENCSEG
			   SYW->(dbSeek(xFilial("SYW")+SW6->W6_CORRETO))
			   Work->WKFORN   := SYW->YW_FORN
			   SA2->(dbSeek(xFilial("SA2")+SYW->YW_FORN+SYW->YW_LOJA))
			   Work->WKFDESC  := SA2->A2_NREDUZ
			   Work->WKMOEDA  := SW6->W6_SEGMOED
			   Work->WKTAXA   := SW6->W6_TX_SEG
			   Work->WKVLRMOE := SW6->W6_VL_USSE
			   Work->WKVLRREAL:= SW6->W6_VL_USSE * SW6->W6_TX_SEG
      		EndIf
      EndIf
       //Impostos
      lAchouNF:=.F.
      SF1->(dbSetOrder(1)) //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
   	  If !(SF1->(dbSeek(xFilial("SF1")+WorkQry->F1_DOC+ WorkQry->F1_SERIE+WorkQry->F1_FORNECE+ WorkQry->F1_LOJA+WorkQry->F1_TIPO)) .AND. WorkQry->F1_TIPO_NF $ "1,3,5")
      /*If !SF1->(dbSeek(xFilial("SF1")+SW6->W6_HAWB+"1"))
         If !SF1->(dbSeek(xFilial("SF1")+SW6->W6_HAWB+"3"))   
            If !SF1->(dbSeek(xFilial("SF1")+SW6->W6_HAWB+"5"))
               lAchouNF:= .F.
            Else
               lAchouNF:= .T.
            EndIf
         Else
            lAchouNF:= .T.
         EndIf*/
         lAchouNF:= .F.
      Else
         lAchouNF :=.T.
      EndIf
  
      If lAchouNF
	      If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"201"+SF1->F1_DOC))
	         If !Empty(SF1->F1_II)
	            Work->WKDOCTO  := SF1->F1_DOC
	            Work->WKDATA   := SF1->F1_EMISSAO
	            Work->WKFORN   := SF1->F1_FORNECE
	            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
	            Work->WKFDESC  := SA2->A2_NREDUZ 
	            Work->WKVLRREAL+= SF1->F1_II //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
	         EndIf
	      Else
	         Work->(dbAppend())
	         Work->WKIMPORT := SW6->W6_IMPORT
	         SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
	         Work->WKNMIMPORT:= SYT->YT_NOME_RE 
	         Work->WKHAWB   := SW6->W6_HAWB
	         Work->WKDESPESA:= "201"
	         Work->WKDESCR  := "II"
	         Work->WKDOCTO  := SF1->F1_DOC
	         Work->WKDATA   := SF1->F1_EMISSAO
	         Work->WKFORN   := SF1->F1_FORNECE
	         SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
	         Work->WKFDESC  := SA2->A2_NREDUZ
	         Work->WKVLRREAL+= SF1->F1_II
	      EndIf
	      If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"202"+SF1->F1_DOC)) //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
	         If !Empty(SF1->F1_IPI)
	            Work->WKDOCTO  := SF1->F1_DOC
	            Work->WKDATA   := SF1->F1_EMISSAO
	            Work->WKFORN   := SF1->F1_FORNECE
	            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
	            Work->WKFDESC  := SA2->A2_NREDUZ
	            Work->WKVLRREAL+= SF1->F1_IPI
	         EndIf
	      Else
	         Work->(dbAppend())
	         Work->WKIMPORT := SW6->W6_IMPORT
	         SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
	         Work->WKNMIMPORT:= SYT->YT_NOME_RE         
	         Work->WKHAWB   := SW6->W6_HAWB
	         Work->WKDESPESA:= "202"
	         Work->WKDESCR  := "IPI"
	         Work->WKDOCTO  := SF1->F1_DOC
	         Work->WKDATA   := SF1->F1_EMISSAO
	         Work->WKFORN   := SF1->F1_FORNECE
	         SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
	         Work->WKFDESC  := SA2->A2_NREDUZ
	         Work->WKVLRREAL+= SF1->F1_IPI   
	      EndIf 
	      If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"203"+SF1->F1_DOC)) //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
	         If !Empty(SF1->F1_ICMS)
	            Work->WKDOCTO  := SF1->F1_DOC
	            Work->WKDATA   := SF1->F1_EMISSAO
	            Work->WKFORN   := SF1->F1_FORNECE
	            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
	            Work->WKFDESC  := SA2->A2_NREDUZ
	            Work->WKVLRREAL+= SF1->F1_ICMS
	         EndIf
	      Else
	         Work->(dbAppend())
	         Work->WKIMPORT := SW6->W6_IMPORT
	         SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
	         Work->WKNMIMPORT:= SYT->YT_NOME_RE         
	         Work->WKHAWB   := SW6->W6_HAWB
	         Work->WKDESPESA:= "203"
	         Work->WKDESCR  := "ICMS"
	         Work->WKDOCTO  := SF1->F1_DOC
	         Work->WKDATA   := SF1->F1_EMISSAO
	         Work->WKFORN   := SF1->F1_FORNECE
	         SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
	         Work->WKFDESC  := SA2->A2_NREDUZ
	         Work->WKVLRREAL+= SF1->F1_ICMS
	       EndIf
       
         If SWN->(dbSeek(xFilial("SWN")+SF1->(F1_DOC+F1_SERIE)))
            While SWN->(!EOF()) .And. SWN->(WN_FILIAL+WN_DOC+WN_SERIE) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE)
               nVlrPis += SWN->WN_VLRPIS // RRV - 27/08/2012 - Ajuste para imprimir  
               nVlrCof += SWN->WN_VLRCOF // no relatório a soma dos impostos dos itens.
               SWN->(dbSkip())
            EndDo
         EndIf
         If !Empty(nVlrPis)
	         If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"204"+SF1->F1_DOC)) //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
	            Work->WKDOCTO  := SF1->F1_DOC
	            Work->WKDATA   := SF1->F1_EMISSAO
	            Work->WKFORN   := SF1->F1_FORNECE
	            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
	            Work->WKFDESC  := SA2->A2_NREDUZ
	            Work->WKVLRREAL+= nVlrPis
	         Else
	            Work->(dbAppend())
	            Work->WKIMPORT := SW6->W6_IMPORT
	            SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
	            Work->WKNMIMPORT:= SYT->YT_NOME_RE
	            Work->WKHAWB   := SW6->W6_HAWB
	            Work->WKDESPESA:= "204"
	            Work->WKDESCR  := "PIS"
	            Work->WKDOCTO  := SF1->F1_DOC
	            Work->WKDATA   := SF1->F1_EMISSAO
	            Work->WKFORN   := SF1->F1_FORNECE
	            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
	            Work->WKFDESC  := SA2->A2_NREDUZ
	            Work->WKVLRREAL+= nVlrPis
	         EndIf
         EndIf
         If !Empty(nVlrCof)
	         If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"205"+SF1->F1_DOC)) //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
	            Work->WKDOCTO  := SF1->F1_DOC
	            Work->WKDATA   := SF1->F1_EMISSAO
	            Work->WKFORN   := SF1->F1_FORNECE
	            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
	            Work->WKFDESC  := SA2->A2_NREDUZ
	            Work->WKVLRREAL+= nVlrCof
	         Else
	            Work->(dbAppend())
	            Work->WKIMPORT := SW6->W6_IMPORT
	            SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
	            Work->WKNMIMPORT:= SYT->YT_NOME_RE         
	            Work->WKHAWB   := SW6->W6_HAWB
	            Work->WKDESPESA:= "205"
	            Work->WKDESCR  := "COFINS"
	            Work->WKDOCTO  := SF1->F1_DOC
	            Work->WKDATA   := SF1->F1_EMISSAO
	            Work->WKFORN   := SF1->F1_FORNECE
	            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
	            Work->WKFDESC  := SA2->A2_NREDUZ
	            Work->WKVLRREAL+= nVlrCof
	         EndIf
	     EndIf
      
      EndIf
     
      //Demais Despesas  
      If SWD->(dbSeek(xFilial("SWD")+SW6->w6_HAWB))
         While SWD->(!EOF()) .And. SWD->(WD_FILIAL+WD_HAWB) == SW6->(W6_FILIAL+W6_HAWB) 
	        If !SubStr(SWD->WD_DESPESA,1,1) $ "129"
	            //If !Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+SWD->WD_DESPESA)) //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos 
	               If Posicione("SYB",1,xFilial("SYB")+AvKey(SWD->WD_DESPESA,"YB_DESP"),"YB_BASECUS") <> "2" ;// GFP - 01/07/2013 - Apenas deve incluir despesas com Base Custo = "Sim"
                    .And. aScan( aSWDProc,SWD->(Recno()) ) == 0                                             // NCF - 07/02/2019 - Não duplicar Desp. quando tem NF primeira e Complementar
		               Work->(dbAppend())
		               Work->WKIMPORT := SW6->W6_IMPORT
		               SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
		               Work->WKNMIMPORT:= SYT->YT_NOME_RE
		               Work->WKHAWB   := SW6->W6_HAWB
		               Work->WKDESPESA:= SWD->WD_DESPESA
		               SYB->(dbSeek(xFilial("SYB")+SWD->WD_DESPESA))
		               Work->WKDESCR  := SYB->YB_DESCR
		               Work->WKDOCTO  := SWD->WD_DOCTO
		               Work->WKDATA   := SWD->WD_DES_ADI
		               Work->WKFORN   := SWD->WD_FORN
		               SA2->(dbSeek(xFilial("SA2")+SWD->WD_FORN))
		               Work->WKFDESC  := SA2->A2_NREDUZ
		               Work->WKVLRREAL:= SWD->WD_VALOR_R
                   aAdd(aSWDProc,SWD->(Recno()))
		            EndIf
	            //EndIf
            EndIf
            SWD->(dbSkip())         
         EndDo
      EndIf
   EndIf
Else // Caso a Work Possua Dados
   If SWB->(dbSeek(xFilial("SWB")+SW6->W6_HAWB)) 
      While SWB->(!EOF()) .And. SWB->(WB_FILIAL+WB_HAWB) == SW6->(W6_FILIAL+W6_HAWB)
         If !Empty(SWB->WB_CA_DT) // Data de Liquidação
            If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"101"+SWB->WB_INVOICE))
               Work->WKDATA   := SWB->WB_CA_DT
               Work->WKTAXA   := SWB->WB_CA_TX
               Work->WKVLRMOE := SWB->WB_FOBMOE
               Work->WKVLRREAL:= SWB->WB_FOBMOE * SWB->WB_CA_TX        
            EndIf
         Else
           If !Empty(SWB->WB_PGTANT)
              If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"101"+SWB->WB_INVOICE))
                 Work->WKDATA   := SWB->WB_CA_DT
                 Work->WKTAXA   := SWB->WB_CA_TX
                 Work->WKVLRMOE := SWB->WB_PGTANT
                 Work->WKVLRREAL:= SWB->WB_PGTANT * SWB->WB_CA_TX         
              EndIf 
           EndIf
         EndIf
         SWB->(dbSkip())
      EndDo
   EndIf
   //Frete
   If !Empty(SW6->W6_VLFRECC)
      If !Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"102"+SW6->W6_HOUSE)) //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
         Work->(dbAppend())
         Work->WKIMPORT := SW6->W6_IMPORT
         SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
         Work->WKNMIMPORT:= SYT->YT_NOME_RE        
         Work->WKHAWB   := SW6->W6_HAWB
         Work->WKDESPESA:= "102"
         Work->WKDESCR  := "Frete Internacional"
         Work->WKDOCTO  := SW6->W6_HOUSE
         Work->WKDATA   := SW6->W6_VENCFRE
         //SY5->(dbSeek(xFilial("SY5")+SW6->W6_FORNECF)) //WHRS TE-5259 511736 / MTRADE-767 - Relatorio de Custos
         Work->WKFORN   := SW6->W6_FORNECF
         SA2->(dbSeek(xFilial("SA2")+SW6->W6_FORNECF+SW6->W6_LOJAF))
         Work->WKFDESC  := SA2->A2_NREDUZ
         Work->WKMOEDA  := SW6->W6_FREMOED
         Work->WKTAXA   := SW6->W6_TX_FRET
         Work->WKVLRMOE := SW6->W6_VLFRECC
         Work->WKVLRREAL:= SW6->W6_VLFRECC * SW6->W6_TX_FRET
      EndIf
   EndIf

   //Seguro
   If !Empty(SW6->W6_VL_USSE)
      If !Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"103"+SW6->W6_NF_SEG)) //WHRS (x2) TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
         Work->(dbAppend())
         Work->WKIMPORT := SW6->W6_IMPORT
         SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
         Work->WKNMIMPORT:= SYT->YT_NOME_RE            
         Work->WKHAWB   := SW6->W6_HAWB
         Work->WKDESPESA:= "103"
         Work->WKDESCR  := "Seguro Internacional"
         Work->WKDOCTO  := SW6->W6_NF_SEG
         Work->WKDATA   := SW6->W6_VENCSEG
         SYW->(dbSeek(xFilial("SYW")+SW6->W6_CORRETO))
         Work->WKFORN   := SYW->YW_FORN
         SA2->(dbSeek(xFilial("SA2")+SYW->YW_FORN))
         Work->WKFDESC  := SA2->A2_NREDUZ
         Work->WKMOEDA  := SW6->W6_SEGMOED
         Work->WKTAXA   := SW6->W6_TX_SEG
         Work->WKVLRMOE := SW6->W6_VL_USSE
         Work->WKVLRREAL:= SW6->W6_VL_USSE * SW6->W6_TX_SEG
      EndIf
   EndIf
    //Impostos
   lAchouNF:=.F.
   SF1->(dbSetOrder(1)) //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
   If !(SF1->(dbSeek(xFilial("SF1")+WorkQry->F1_DOC+ WorkQry->F1_SERIE+WorkQry->F1_FORNECE+ WorkQry->F1_LOJA+WorkQry->F1_TIPO)) .AND. WorkQry->F1_TIPO_NF $ "1,3,5")
   /*If !SF1->(dbSeek(xFilial("SF1")+SW6->W6_HAWB+"1"))
      If !SF1->(dbSeek(xFilial("SF1")+SW6->W6_HAWB+"3"))   
         If !SF1->(dbSeek(xFilial("SF1")+SW6->W6_HAWB+"5"))
            lAchouNF:= .F.
         Else
            lAchouNF:= .T.
         EndIf
      Else
         lAchouNF:= .T.
      EndIf*/
      lAchouNF:= .F.
   Else
      lAchouNF :=.T.
   EndIf
   If lAchouNF
      If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"201"+SF1->F1_DOC))
         If !Empty(SF1->F1_II)
            Work->WKDOCTO  := SF1->F1_DOC
            Work->WKDATA   := SF1->F1_EMISSAO
            Work->WKFORN   := SF1->F1_FORNECE
            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
            Work->WKFDESC  := SA2->A2_NREDUZ
            Work->WKVLRREAL+= SF1->F1_II //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
         EndIf
      Else
         Work->(dbAppend())
         Work->WKIMPORT := SW6->W6_IMPORT
         SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
         Work->WKNMIMPORT:= SYT->YT_NOME_RE         
         Work->WKHAWB   := SW6->W6_HAWB
         Work->WKDESPESA:= "201"
         Work->WKDESCR  := "II"
         Work->WKDOCTO  := SF1->F1_DOC
         Work->WKDATA   := SF1->F1_EMISSAO
         Work->WKFORN   := SF1->F1_FORNECE
         SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
         Work->WKFDESC  := SA2->A2_NREDUZ
         Work->WKVLRREAL+= SF1->F1_II
      EndIf
      If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"202"+SF1->F1_DOC)) //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
         If !Empty(SF1->F1_IPI)
            Work->WKDOCTO  := SF1->F1_DOC
            Work->WKDATA   := SF1->F1_EMISSAO
            Work->WKFORN   := SF1->F1_FORNECE
            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
            Work->WKFDESC  := SA2->A2_NREDUZ
            Work->WKVLRREAL+= SF1->F1_IPI
         EndIf
      Else
         Work->(dbAppend())
         Work->WKIMPORT := SW6->W6_IMPORT
         SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
         Work->WKNMIMPORT:= SYT->YT_NOME_RE
         Work->WKHAWB   := SW6->W6_HAWB
         Work->WKDESPESA:= "202"
         Work->WKDESCR  := "IPI"
         Work->WKDOCTO  := SF1->F1_DOC
         Work->WKDATA   := SF1->F1_EMISSAO
         Work->WKFORN   := SF1->F1_FORNECE
         SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
         Work->WKFDESC  := SA2->A2_NREDUZ
         Work->WKVLRREAL+= SF1->F1_IPI          
      EndIf 
      If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"203"+SF1->F1_DOC)) //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
         If !Empty(SF1->F1_ICMS)
            Work->WKDOCTO  := SF1->F1_DOC
            Work->WKDATA   := SF1->F1_EMISSAO
            Work->WKFORN   := SF1->F1_FORNECE
            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
            Work->WKFDESC  := SA2->A2_NREDUZ
            Work->WKVLRREAL+= SF1->F1_ICMS
         EndIf
      Else
         Work->(dbAppend())
         Work->WKIMPORT := SW6->W6_IMPORT
         SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
         Work->WKNMIMPORT:= SYT->YT_NOME_RE            
         Work->WKHAWB   := SW6->W6_HAWB
         Work->WKDESPESA:= "203"
         Work->WKDESCR  := "ICMS"
         Work->WKDOCTO  := SF1->F1_DOC
         Work->WKDATA   := SF1->F1_EMISSAO
         Work->WKFORN   := SF1->F1_FORNECE
         SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
         Work->WKFDESC  := SA2->A2_NREDUZ
         Work->WKVLRREAL+= SF1->F1_ICMS         
      EndIf
      
      If SWN->(dbSeek(xFilial("SWN")+SF1->(F1_DOC+F1_SERIE)))
         While SWN->(!EOF()) .And. SWN->(WN_FILIAL+WN_DOC+WN_SERIE) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE)
            nVlrPis += SWN->WN_VLRPIS // RRV - 27/08/2012 - Ajuste para imprimir
            nVlrCof += SWN->WN_VLRCOF // no relatório a soma dos impostos dos itens.
            SWN->(dbSkip())
         EndDo
      EndIf
      If !Empty(nVlrPis)
         If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"204"+SF1->F1_DOC)) //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
            Work->WKDOCTO  := SF1->F1_DOC
            Work->WKDATA   := SF1->F1_EMISSAO
            Work->WKFORN   := SF1->F1_FORNECE
            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
            Work->WKFDESC  := SA2->A2_NREDUZ
            Work->WKVLRREAL+= nVlrPis
         Else
            Work->(dbAppend())
            Work->WKIMPORT := SW6->W6_IMPORT
            SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
            Work->WKNMIMPORT:= SYT->YT_NOME_RE               
            Work->WKHAWB   := SW6->W6_HAWB
            Work->WKDESPESA:= "204"
            Work->WKDESCR  := "PIS"
            Work->WKDOCTO  := SF1->F1_DOC
            Work->WKDATA   := SF1->F1_EMISSAO
            Work->WKFORN   := SF1->F1_FORNECE
            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
            Work->WKFDESC  := SA2->A2_NREDUZ
            Work->WKVLRREAL+= nVlrPis  
         EndIf
      EndIf
      If !Empty(nVlrCof)
         If Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+"205"+SF1->F1_DOC)) //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
            Work->WKDOCTO  := SF1->F1_DOC
            Work->WKDATA   := SF1->F1_EMISSAO
            Work->WKFORN   := SF1->F1_FORNECE
            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
            Work->WKFDESC  := SA2->A2_NREDUZ
            Work->WKVLRREAL+= nVlrCof
         Else
            Work->(dbAppend())
            Work->WKIMPORT := SW6->W6_IMPORT
            SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
            Work->WKNMIMPORT:= SYT->YT_NOME_RE                                                        
            Work->WKHAWB   := SW6->W6_HAWB
            Work->WKDESPESA:= "205"
            Work->WKDESCR  := "COFINS"
            Work->WKDOCTO  := SF1->F1_DOC
            Work->WKDATA   := SF1->F1_EMISSAO
            Work->WKFORN   := SF1->F1_FORNECE
            SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE))
            Work->WKFDESC  := SA2->A2_NREDUZ
            Work->WKVLRREAL+= nVlrCof            
         EndIf
      EndIf 
      //Demais Despesas
      If SWD->(dbSeek(xFilial("SWD")+SW6->W6_HAWB))   
         While SWD->(!EOF()) .And. SWD->(WD_FILIAL+WD_HAWB) == SW6->(W6_FILIAL+W6_HAWB)
            If !SubStr(SWD->WD_DESPESA,1,1) $ "129" 
               //If !Work->(dbSeek(SW6->(W6_IMPORT+W6_HAWB)+SWD->WD_DESPESA))
                  If Posicione("SYB",1,xFilial("SYB")+AvKey(SWD->WD_DESPESA,"YB_DESP"),"YB_BASECUS") <> "2" ;// GFP - 01/07/2013 - Apenas deve incluir despesas com Base Custo = "Sim"
                    .And. aScan( aSWDProc,SWD->(Recno()) ) == 0                                              // NCF - 07/02/2019 - Não duplicar Desp. quando tem NF primeira e Complementar
                     Work->(dbAppend())
                     Work->WKIMPORT := SW6->W6_IMPORT
                     SYT->(dbSeek(xFilial("SYT")+Work->WKIMPORT))
                     Work->WKNMIMPORT:= SYT->YT_NOME_RE               
                     Work->WKHAWB   := SW6->W6_HAWB
                     Work->WKDESPESA:= SWD->WD_DESPESA
                     SYB->(dbSeek(xFilial("SYB")+SWD->WD_DESPESA))
                     Work->WKDESCR  := SYB->YB_DESCR
                     Work->WKDOCTO  := SWD->WD_DOCTO
                     Work->WKDATA   := SWD->WD_DES_ADI
                     Work->WKFORN   := SWD->WD_FORN
                     SA2->(dbSeek(xFilial("SA2")+SWD->WD_FORN))
                     Work->WKFDESC  := SA2->A2_NREDUZ
                     Work->WKVLRREAL:= SWD->WD_VALOR_R
                     aAdd(aSWDProc,SWD->(Recno()))            
                  EndIf
               //EndIf
            EndIf
            SWD->(dbSkip())         
         EndDo
      EndIf
   EndIf
EndIf

WorkQry->(dbSkip()) 
EndDo

lRet := Work->(EasyRecCount()) != 0
If !Empty(aProcEncer) //NCF - 07/02/2019
   cMsgLogPrc := STR0024 + REPLICATE(CHR(13)+CHR(10),2) // "Não foi possível gerar todos os relatórios, pois o(s) seguinte(s) processo(s) esta(ão) encerrado(s):"
   aEval( aProcEncer , {|x| cMsgLogPrc += x[2]  }   )
   EECVIEW(cMsgLogPrc )
ElseIf !lRet
   cMsgLogPrc := STR0025 // "Não foi possível gerar o relatório, pois não foram encontrados dados ou o processo está encerrado."
   EECVIEW(cMsgLogPrc )
EndIf

restOrd(aOrdSF1, .T.) //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos

Return lRet

/* 
Funcao     : ReportDef() 
Parametros : Nenhum 
Retorno    : 
Objetivos  : Definição do Relatório
Autor      : Saimon Vinicius Gava 
Data/Hora  : 18/11/2009 17:25:07
*/  
Static Function ReportDef()

Local oReport  
Local oSection1,  oBreak1

oReport := TReport():New("EICRCUST",STR0001,"EICRCUST",;  //"Relatorio de Custos"
{|oReport| ReportPrint(oReport)},STR0006)                                     

//Inicia o relatório como paisagem.
oReport:oPage:lLandScape := .T.
oReport:oPage:lPortRait := .F.


Pergunte(oReport:uParam,.T.)


oSection1 := TRSection():New(oReport,STR0007,{"SW6","SW7","SW8","SW9","SWN","SF1","SWD"}, )  

//           objeto   ,cName      ,cAlias ,cTitle                   ,cPicture               ,nSize                          ,lPixel     ,bBlock ,cAlign  ,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold
TRCell():New(oSection1,"WKHAWB"   , "Work", STR0008                 ,                       , AVSX3("W7_HAWB"   ,AV_TAMANHO),           ,       ,        ,          ,            ,          ,         , .F.     ,        ,        ,     )
TRCell():New(oSection1,"WKDESPESA", "Work", STR0010                 ,                       , AVSX3("WD_DESPESA",AV_TAMANHO),           ,       ,        ,          ,            ,          ,         , .F.     ,        ,        ,     )
TRCell():New(oSection1,"WKDESCR"  , "Work", STR0011                 ,                       , AVSX3("YB_DESCR"  ,AV_TAMANHO),           ,       ,        ,          ,            ,          ,         , .F.     ,        ,        ,     )
TRCell():New(oSection1,"WKDOCTO"  , "Work", STR0012                 ,                       , AVSX3("F1_DOC"    ,AV_TAMANHO),           ,       ,        ,          ,            ,          ,         , .F.     ,        ,        ,     )
TRCell():New(oSection1,"WKFORN"   , "Work", STR0013                 ,                       , AVSX3("WB_FORN"   ,AV_TAMANHO),           ,       ,        ,          ,            ,          ,         , .F.     ,        ,        ,     )
TRCell():New(oSection1,"WKFDESC"  , "Work", ""                      ,                       , AVSX3("A2_NREDUZ" ,AV_TAMANHO),           ,       ,        ,          ,            ,          ,         , .F.     ,        ,        ,     )
TRCell():New(oSection1,"WKDATA"   , "Work", STR0014                 ,                       , Len(DtoC(MSDate()))           ,           ,       ,        ,          ,            ,          ,         , .F.     ,        ,        ,     )  // GFP - 18/06/2013
TRCell():New(oSection1,"WKMOEDA"  , "Work", STR0015                 ,                       , AVSX3("WB_MOEDA"  ,AV_TAMANHO),           ,       ,        ,          ,            ,          ,         , .F.     ,        ,        ,     )
TRCell():New(oSection1,"WKTAXA"   , "Work", STR0015                 ,"@E 99.9999"           , AVSX3("WB_CA_TX"  ,AV_TAMANHO),           ,       ,"RIGHT" ,          ,"RIGHT"     ,          ,         , .F.     ,        ,        ,     )
TRCell():New(oSection1,"WKVLRMOE" , "Work", STR0017                 ,"@E 999,999,999,999.99", AVSX3("WB_FOBMOE" ,AV_TAMANHO),           ,       ,"RIGHT" ,          ,"RIGHT"     ,          ,         , .F.     ,        ,        ,     )
TRCell():New(oSection1,"WKVLRREAL", "Work", STR0018                 ,"@E 999,999,999,999.99", AVSX3("WD_VALOR_R",AV_TAMANHO),           ,       ,"RIGHT" ,          ,"RIGHT"     ,          ,         , .F.     ,        ,        ,     )
TRCell():New(oSection1,"WKVLPMOE" , "Work", STR0019                 ,"@E 999,999,999,999.99", 15                            ,           ,       ,"RIGHT" ,          ,"RIGHT"     ,          ,         , .F.     ,        ,        ,     )
TRCell():New(oSection1,"WKVLPREAL", "Work", STR0020                 ,"@E 999,999,999,999.99", 15                            ,           ,       ,"RIGHT" ,          ,"RIGHT"     ,          ,         , .F.     ,        ,        ,     )


oSection1:SetTotalInLine(.T.)

Return oReport                                         


/* 
Funcao     : ReportPrint() 
Parametros : Nenhum 
Retorno    : 
Objetivos  : 
Autor      : Saimon Vinicius Gava 
Data/Hora  : 18/11/2009 17:25:07
*/  

Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section(1)
Local lRet:= .T.//TRP - 06/09/12

//TRP - 06/09/12
lRet:= RCUSTGRVWK()

//MCF - 03/06/2015 - Faz o posicionamento das tabelas para campos personalizados no relatório de custo.
TRPosition():New(oReport:Section(1),"SW6",1,{|| xFilial("SW6") + Work->WKHAWB })
TRPosition():New(oReport:Section(1),"SW7",2,{|| xFilial("SW7") + SW6->W6_PO_NUM + SW6->W6_HAWB })
TRPosition():New(oReport:Section(1),"SW8",3,{|| xFilial("SW8") + SW7->(W7_HAWB+W7_PGI_NUM +W7_PO_NUM+W7_SI_NUM) })
TRPosition():New(oReport:Section(1),"SW9",1,{|| xFilial("SW9") + SW8->W8_INVOICE + SW8->W8_FORN })
TRPosition():New(oReport:Section(1),"SF1",5,{|| xFilial("SF1") + SW6->W6_HAWB })
TRPosition():New(oReport:Section(1),"SWN",2,{|| xFilial("SWN") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) })
TRPosition():New(oReport:Section(1),"SWD",5,{|| xFilial("SWD") + SW6->W6_HAWB })

If !lRet
   Return .F.
Endif

Work->(dbGoTop())

oBreak1   := TRBreak():New( oSection1, {|| Work->(WKIMPORT)},,.F.) // "Importador"
oBreak1:bOnBreak:={||oReport:SkipLine(2),oReport:PrintText(if(!Work->(EOF()),STR0021 + Work->WKIMPORT +" " +Work->WKNMIMPORT  ,""),,)}
oBreak1:bOnBreak:={||oReport:SkipLine(1),oReport:PrintText(STR0022,,)}
oBreak1:bOnPrintTotal:={||oReport:SkipLine(1),oReport:PrintText(if(!Work->(EOF()), STR0021 +Work->WKIMPORT+" " +Work->WKNMIMPORT ,""),,),oReport:FatLine()}
 

FilePrint:=E_Create(,.F.)
oReport:PrintText(if(!Work->(EOF()), "  Importador: "+Work->WKIMPORT+" " +Work->WKNMIMPORT ,""),,)
oReport:FatLine()

oTotal:=TRFunction():New(oSection1:Cell("WKVLRREAL"),NIL,"SUM",oBreak1, , ,{|| WORK->WKVLRREAL},.T.,.F.)
oTotal:SkipLine(3)
oTotal:=TRFunction():New(oSection1:Cell("WKVLPREAL"),NIL,"SUM",oBreak1, , ,{|| WORK->WKVLPREAL},.T.,.F.)
oTotal:SkipLine(3)
oSection1:SetTotalText("")

oReport:SetMeter(Work->(LastRec()))

WHILE Work->(!EOF())
	oSection1:Init()
    oReport:IncMeter(Work->(LastRec()))
	oSection1:PRINTLINE() 
    Work->(DBSKIP())	
ENDDO
oBreak1:bOnBreak:={||oReport:SkipLine(1),oReport:PrintText("Total.......: ",,)}
oSection1:Finish()

IF SELECT("Work") > 0
   Work->(DbCloseArea())
ENDIF

IF SELECT("WorkQry") > 0
   WorkQry->(DbCloseArea())
ENDIF
Return lRet



Static Function RCUSTWork()
Local aOrd_Stru:={  {"WKIMPORT"  ,"C",AVSX3("W6_IMPORT" ,AV_TAMANHO) ,0},; //Importador
                    {"WKNMIMPORT","C",AVSX3("YT_NOME_RE",AV_TAMANHO) ,0},; //Importador
                    {"WKHAWB"    ,"C",AVSX3("W7_HAWB"   ,AV_TAMANHO) ,0},; //Hawb
                    {"WKDESPESA" ,"C",AVSX3("WD_DESPESA",AV_TAMANHO) ,0},; //Despesa
                    {"WKDESCR"   ,"C",AVSX3("YB_DESCR"  ,AV_TAMANHO) ,0},; //Descr. Despesa
                    {"WKDOCTO"   ,"C",AVSX3("F1_DOC"    ,AV_TAMANHO) ,0},; //Docto
                    {"WKFORN"    ,"C",AVSX3("WB_FORN"   ,AV_TAMANHO) ,0},; //Fornecedor
                    {"WKFDESC"   ,"C",AVSX3("A2_NREDUZ" ,AV_TAMANHO) ,0},; //Descr. Fornecedor
                    {"WKDATA"    ,"D",AVSX3("F1_EMISSAO",AV_TAMANHO) ,0},; //Data
                    {"WKMOEDA"   ,"C",AVSX3("WB_MOEDA"  ,AV_TAMANHO) ,0},; //Moeda
                    {"WKTAXA"    ,"N",AVSX3("WB_CA_TX"  ,AV_TAMANHO) ,4},; //Taxa
                    {"WKVLRMOE"  ,"N",AVSX3("WB_FOBMOE" ,AV_TAMANHO) ,2},; //Valor Moeda
                    {"WKVLRREAL" ,"N",AVSX3("WD_VALOR_R",AV_TAMANHO) ,2},; //Valor Realiz. R$
                    {"WKVLPMOE"  ,"N",15                             ,2},; //Previs. Moeda
                    {"WKVLPREAL" ,"N",15                             ,2}}
Private cFileTrb                      

Private aCampos := {}, aHeader := {}

If Select("WORK") # 0    // GFP - 18/06/2013
   WORK->(DbCloseArea())
EndIf

cFileTrb := E_CriaTrab(,aOrd_Stru,"WORK")                 
IndRegua("WORK",cFileTrb+TEOrdBagExt(),"WKIMPORT+WKHAWB+WKDESPESA+WKDOCTO")

Return nil

/*
Funcao     : EICQUERY() 
Parametros : Nenhum 
Retorno    : lRet - Flag onde informa se Work está vazia ou não.
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/11/2009 17:25:07
*/
Static Function EICQUERY()
Local lRet := .T.
Local cQuery := ""
Local cTipoNF := "" //LGS - 16/09/2013

IF SELECT("WorkQry") > 0
   WorkQry->(DbCloseArea())
ENDIF 
                                            
//LGS - 02/09/2013 - Pesquisa pelo numero do processo "F1_HAWB" para encontrar o tipo da NF para ser utilizado no select
//isso foi preciso pois notas que de beneficiamento tipo B não gerava relatorio, apenas as tipo N, normal feito pelo EIC.
If !Empty(MV_PAR02) //LGS - 16/09/2013
	If SF1->(DbSeek(xFilial("SF1")+AvKey(mv_par02,"F1_HAWB")))
		DO WHILE SF1->(!Eof()) .And. SF1->F1_HAWB == mv_par02 
			cTipoNF += SF1->F1_Tipo + "','" //WHRS TE-5259 511736 / MTRADE-767 - Relatorio de Custos
		SF1->(DbSkip())
		EndDo
		cTipoNF := If (len(cTipoNF) > 2, SubStr(cTipoNF, 1, len(cTipoNF)-2), cTipoNF) //WHRS TE-5259 511736 / MTRADE-767 - Relatorio de Custos 
	EndIf
EndIf
//cQuery := "Select Distinct SF1.F1_HAWB,SF1.F1_EMISSAO From " + RetSqlName("SF1") + " SF1 " + ;	
//cQuery := "Select Distinct SF1.F1_HAWB From " + RetSqlName("SF1") + " SF1 " + ;
cQuery := "Select Distinct SF1.F1_HAWB, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, F1_TIPO_NF From " + RetSqlName("SF1") + " SF1 " + ; //WHRS TE-5026 - 504170 - MTRADE-460 - Relatório de Custos
          "INNER JOIN " + RetSqlName("SW6") + " SW6 " +;
          "On SF1.F1_HAWB = SW6.W6_HAWB AND SF1.D_E_L_E_T_ <> '*' AND SF1.F1_FILIAL = '" + xFilial("SF1") +"' AND SW6.D_E_L_E_T_ <> '*' AND SW6.W6_FILIAL = '" + xFilial("SW6") + "' "     //TRP - 12/12

cQuery += If(!Empty(MV_PAR02)," WHERE SF1.F1_HAWB = SW6.W6_HAWB AND SW6.W6_HAWB = '" + MV_PAR02 + "'"," ")  // RRV - 27/08/2012 - Ajuste para filtrar pelo processo se o parametro inicial mv_par02 for informado.
          
cQuery += If(!Empty(MV_PAR01)," AND SW6.W6_IMPORT = '"+MV_PAR01+"'"," ")

//TRP - 06/09/2012 - Checar as datas informadas no filtro do relatório.
cQuery += If(!Empty(MV_PAR03)," AND SF1.F1_EMISSAO >= '"+dToS(MV_PAR03)+"'"," ")

cQuery += If(!Empty(MV_PAR04)," AND SF1.F1_EMISSAO <= '"+dToS(MV_PAR04)+"'"," ") 

//RRV - 29/11/2012 - Tratamento para filtrar o tipo da nota.
//cQuery += " AND SF1.F1_TIPO = '"+SF1->F1_Tipo+"'"
//cQuery += " AND SF1.F1_TIPO = '"+cTipoNF+"'"
cQuery += If(!Empty(MV_PAR02) .And. !Empty(cTipoNF)," AND SF1.F1_TIPO in ('" + cTipoNF + ")"," ") //LGS - 16/09/2013 #### THTS - 25/09/2017

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WorkQry", .T., .T.) 

lRet := !(WorkQry->(Eof()) .AND. WorkQry->(Bof()))   // Caso vazio, retorna .F.

Return lRet



Static FUNCTION TipoParc(cTipo)
Local cRet := ""

SX5->( DbSetOrder( 1 ) )
If SX5->( DbSeek( xFilial() + "Y6" + cTipo ))
   cRet := Left(cTipo,1)+'-'+LEFT(X5DESCRI(),15)
EndIf

RETURN cRet
