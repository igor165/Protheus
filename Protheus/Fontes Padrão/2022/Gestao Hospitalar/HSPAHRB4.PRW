#INCLUDE "hspahrb4.ch"
#include "rwmake.ch"
#include "TopConn.ch"
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ HSPAHRB4 ∫ Autor ≥ MARCELO JOSE       ∫ Data ≥  03/11/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ PRODUCAO POR MEDICO / CONVENIO.                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GESTAO HOSPITALAR.                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function HSPAHRB4()
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local cPict          := ""
 Local titulo         := STR0003 //"Relatorio de Producao por Prestador/medico/convenio."
 Local Cabec1         := ""          // definido apos as perguntas
 Local Cabec2         := ""
 Local aOrd           := {}
 Local dDatIni        := CTOD("  /  /    ")
 Local dDatFim        := CTOD("  /  /    ")
 
 Private lEnd         := .F.
 Private CbTxt        := ""
 Private limite       := 220
 Private tamanho      := "G"
 Private nomeprog     := "HSPAHRB4"
 Private nTipo        := 15
 Private aReturn      := { STR0004, 1, STR0005, 1, 2, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbcont       := 00
 Private cbText       := ""
 Private m_pag        := 01
 Private wnrel        := "HSPAHRB4"
 Private cString      := "GCZ"
 Private nCtaReg      := 0
 Private cAliasQRY    := "PRMDCV"
 Private nLin         := 80
 Private cPrest       := "Start",;  // totais de quebras
         cMedico      := "Start",;
         cProced      := "Start",;
         cConven      := "Start",;
         cAlias       := "" ,;
         aTotPrest    := {},;
         nSomaCon     := 0,; 
         nSomaPro     := 0,;
         nSomaMed     := 0,;
         nSomaPre     := 0,;
         nRepCon      := 0,; 
         nRepPro      := 0,;
         nRepMed      := 0,;
         nRepPre      := 0,;
         nGloCon      := 0,; 
         nGloPro      := 0,;
         nGloMed      := 0,;
         nGloPre      := 0,; 
         nVPagCon     := 0,; 
         nVPagPro     := 0,;
         nVPagMed     := 0,;
         nVPagPre     := 0,;
         nVRecCon     := 0,; 
         nVRecPro     := 0,;
         nVRecMed     := 0,;
         nVRecPre     := 0,;
         nVPerCon     := 0,; 
         nVPerPro     := 0,;
         nVPerMed     := 0,;
         nVPerPre     := 0,;
         nVPgTCon     := 0,; 
         nVPgTPro     := 0,;
         nVPgTMed     := 0,;
         nVPgTPre     := 0,;
         lStart       := .F.

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
 
 cPerg := "HSPRB4"
 
 If !Pergunte(cPerg, .T.)
  return(Nil)
 EndIf                                                                    
 
 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2
 
 If MV_PAR04 == 1
  titulo += STR0024 //" - Repasse Faturamento"
 ElseIf MV_PAR04 == 2
  titulo += STR0025 //" - Repasses: Direto, Acatamento e Quitacao"
 Else
  titulo += STR0039 //" - Repasses: Direto, Faturamento, Acatamento e Quitacao"
 Endif   
  
 dDatIni  := IIF(MV_PAR04 == 1, MV_PAR10, MV_PAR18)
 dDatFim  := IIF(MV_PAR04 == 1, MV_PAR11, MV_PAR19)
 
 If STRZERO(MV_PAR04,2) $ "01/02"
  Cabec1  := Space(60) + STR0006 + Dtoc(dDatIni) + STR0007 + Dtoc(dDatFim) +  STR0008 + MV_PAR08 + STR0009 + MV_PAR09 //" Periodo de "###" Ate  "###"        Do Lote "###" Ate o Lote "
 Else
  Cabec1  := Space(60) + STR0006 + STR0012 + Dtoc(MV_PAR10) + STR0007 + Dtoc(MV_PAR11) + STR0040 + STR0006 + STR0044 + Dtoc(MV_PAR18) + STR0007 + Dtoc(MV_PAR19)+ ;
              STR0008 + MV_PAR08 + STR0009 + MV_PAR09 //" Periodo de "###" Ate  "###" e "##"        Do Lote "###" Ate o Lote "
 Endif       
 wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 
 If nLastKey == 27
  Return(Nil)
 Endif
 SetDefault(aReturn,cString)
 If nLastKey == 27
  Return(Nil)
 Endif
 nTipo := If(aReturn[4]==1,15,18)

 MsgRun(STR0010,STR0011,{|| PROCQRY() }) //"Aguarde montando consulta"###"Processando"
  
 Processa({|lEnd| RunReport(@lEnd,Cabec1,Cabec2,Titulo) })

Return( NIL )

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥RUNREPORT ∫ Autor ≥ MARCELO JOSE       ∫ Data ≥  03/11/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ∫±±
±±∫          ≥ monta a janela com a regua de processamento.               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GESTAO HOSPITALAR                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

Static Function RunReport(lEnd,Cabec1,Cabec2,Titulo)
 Local cAliasQRY   := "PRMDCV",;
        nContaP    := 1,;
        cTpAten    := "",;
        lQuebra    := .T.,; 
        lInicio    := .F.,; 
        nCtaFor    := 0,;
        cPrettot   := "",;
        cConvtot   := "",;        
        cconvPla   := "",;
        cValPag    := "",;
        cSeqDes    := "",;
        nConvPlaH  := 0,;
        nConvPlaR  := 0,;
        nConvPlaG  := 0,;
        nConvVlPg  := 0,;
        nConvVlRe  := 0,;
								nConvVlPe  := 0,; 
								nConvVlPT  := 0,;
								lSegParte  := .F.,;
        nTotGerHon := 0,;
        nTotGerRep := 0,;
        nTotGerGlo := 0,;
        nTotPreHon := 0,;
        nTotPreRep := 0,;
        nTotPreGlo := 0,;
        nTotSomaH  := 0,;
        nTotSomaR  := 0,;
        nTotSomaG  := 0,;  
        nTotGerPag := 0,;
        nTotGerRec := 0,;
        nTotGerPer := 0,;
        nTotGerPgT := 0,;
        nTotPrePag := 0,;
        nTotPreRec := 0,;
        nTotPrePer := 0,;
        nTotPrePgT := 0,;
        nTotSomaPg := 0,;
        nTotSomaRe := 0,;
        nTotSomaPe := 0,;
        nTotSomaPT := 0,;
        nValPer    := 0,;
        nValRec    := 0,;
        nValRep    := 0,;
        nValDes    := 0,;
        nLinOld    := 0,;
        nPagTudo   := 0
        
       
 ProcRegua(200)

 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 //≥ IMPRESSAO DO RELATORIO                                       ≥
 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
 DbSelectArea(cAliasQRY)
 DbGoTop()
 If Eof()   
  HS_MsgInf(STR0041, STR0042, STR0043)  //"Nenhum dado foi encontrado para a selecao efetuada!"##"AtenÁ„o"##"Producao por Prestador/medico/convenio"######"Funcao aux. chamada pela RPTSTATUS"
  DbCloseArea()
  Return()
 Endif

 While !Eof()
  
  nValPag := 0
  nValRec := 0
  nValPer := 0
  
      
   If MV_PAR04 == 1  .And. (STOD((cAliasQRY)->DTCRI) < MV_PAR10 .Or. STOD((cAliasQRY)->DTCRI) > MV_PAR11)
     cSeqDes := (cAliasQRY)->SEQDES
     DbSkip()
     Loop
   ElseIf STRZERO(MV_PAR04,2) $ "02/03" .And. (cAliasQRY)->PGTMED == "0" .And. ;
          (STOD((cAliasQRY)->DATDES) < MV_PAR18 .Or. STOD((cAliasQRY)->DATDES) > MV_PAR19)
    cSeqDes := (cAliasQRY)->SEQDES
    DbSkip()
    Loop                                                                     
   ElseIf MV_PAR04 == 3 .And.  (cAliasQRY)->PGTMED == "1" .And. (STOD((cAliasQRY)->DTCRI) < MV_PAR10 .Or. STOD((cAliasQRY)->DTCRI) > MV_PAR11)
    cSeqDes := (cAliasQRY)->SEQDES
    DbSkip()
    Loop
   
   ElseIf MV_PAR05 == 1 .And. Empty((cAliasQRY)->CODCPG) 
    cSeqDes := (cAliasQRY)->SEQDES
    DbSkip()
    Loop                                                  
   ElseIf MV_PAR05 == 1 .And. (cAliasQRY)->PGTMED $ "2/3" .And. (STOD((cAliasQRY)->DATLAN) < MV_PAR18 .Or. STOD((cAliasQRY)->DATLAN) > MV_PAR19) 
    cSeqDes := (cAliasQRY)->SEQDES
    DbSkip()
    Loop
   ElseIf MV_PAR05 == 2 .And. (cAliasQRY)->PGTMED $ "2/3" .And. (STOD((cAliasQRY)->DATREC) < MV_PAR18 .Or. STOD((cAliasQRY)->DATREC) > MV_PAR19) 
    cSeqDes := (cAliasQRY)->SEQDES
    DbSkip()
    Loop   
   ElseIf MV_PAR05 == 3 .And. (cAliasQRY)->PGTMED $ "2/3" .And. !Empty((cAliasQRY)->CODCPG) .And. ;
          (STOD((cAliasQRY)->DATLAN) < MV_PAR18 .Or. STOD((cAliasQRY)->DATLAN) > MV_PAR19) 
    cSeqDes := (cAliasQRY)->SEQDES
    DbSkip()
    Loop
   ElseIf MV_PAR05 == 3 .And. (cAliasQRY)->PGTMED $ "2/3" .And. Empty((cAliasQRY)->CODCPG) .And. ;
          (STOD((cAliasQRY)->DATREC) < MV_PAR18 .Or. STOD((cAliasQRY)->DATREC) > MV_PAR19) 
    cSeqDes := (cAliasQRY)->SEQDES
    DbSkip()
    Loop
   ElseIf MV_PAR17 == 1 .And. (cAliasQRY)->STAGE0 <> "3"
    cSeqDes := (cAliasQRY)->SEQDES
    DbSkip()
    Loop
   ElseIf MV_PAR17 == 2 .And. (cAliasQRY)->STAGE0 == "3" 
    cSeqDes := (cAliasQRY)->SEQDES
    DbSkip()
    Loop
   Endif
  
      
  If cSeqDes <> (cAliasQRY)->SEQDES
   lInicio := .T.
   If !Empty((cAliasQRY)->CODCPG) 
    If ((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) == (cAliasQRY)->VALDES 
     nPagTudo := (cAliasQRY)->VALPAG
    Else
     nPagTudo := IIf((cAliasQRY)->SEQMOV == '000001', (cAliasQRY)->VALREP - ((cAliasQRY)->VLRGLO + (cAliasQRY)->GLOFIL), ;
                      (cAliasQRY)->VLRREC)
    Endif
   Else
    nPagTudo := 0
   Endif
   If (cAliasQRY)->PGTMED <> "0"
   
    If MV_PAR05 == 1  //Efetuado
  
     If !Empty((cAliasQRY)->CODCPG) 
      If ((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) == (cAliasQRY)->VALDES
       nValPag := (cAliasQRY)->VALPAG
      Else
       nValPag := IIf((cAliasQRY)->SEQMOV == '000001', (cAliasQRY)->VALREP - ((cAliasQRY)->VLRGLO + (cAliasQRY)->GLOFIL), ;
                       (cAliasQRY)->VLRREC)
      Endif
     
      nValRec := 0
      nValPer := 0
     Else                                                                            
      cSeqDes := (cAliasQRY)->SEQDES
      DbSkip()
      Loop
     Endif   
    ElseIf MV_PAR05 == 2    //Nao efetuado
     If Empty((cAliasQRY)->CODCPG) 
      nValPag := 0
      If ((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) == (cAliasQRY)->VALDES
       nValRec := (cAliasQRY)->VALPAG
      Else
       nValRec := (cAliasQRY)->VALREP - nPagTudo - ((cAliasQRY)->VLRGLO + (cAliasQRY)->GLOFIL)
      Endif
      
      If (cAliasQRY)->STATGF == "4"
       nValPer := ((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL)
      Endif 
     Else
      cSeqDes := (cAliasQRY)->SEQDES
      DbSkip()
      Loop
     Endif
    Else   //Todos
     If !Empty((cAliasQRY)->CODCPG) 
      If ((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) == (cAliasQRY)->VALDES
       nValPag := (cAliasQRY)->VALPAG
      Else
       nValPag := IIf((cAliasQRY)->SEQMOV == '000001', (cAliasQRY)->VALREP - ((cAliasQRY)->VLRGLO + (cAliasQRY)->GLOFIL), ;
                       (cAliasQRY)->VLRREC)
      Endif
     
      nValRec := (cAliasQRY)->VALREP - nPagTudo - ((cAliasQRY)->VLRGLO + (cAliasQRY)->GLOFIL)
     
      If (cAliasQRY)->STATGF == "4"
       nValPer := ((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL)
      Endif 
       
     Else
    
      nValPag := 0
      If ((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) == (cAliasQRY)->VALDES
       nValRec := (cAliasQRY)->VALPAG
      Else
       nValRec := (cAliasQRY)->VALREP - nPagTudo - ((cAliasQRY)->VLRGLO + (cAliasQRY)->GLOFIL)
      Endif
      
      If (cAliasQRY)->STATGF == "4"
       nValPer := ((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL)
      Endif 
     Endif
    Endif
   Else
    nValPag  := 0
    nValPer  := 0
    nValRec  := 0
    nPagTudo := 0
   Endif
   
    
   IncProc( Str(nContaP,7,0) + STR0013 + STR0014 +Alltrim(STR(m_pag, 6, 0)) + STR0015 )  //" de "###" Regs. "###" Pags."
     
   nContaP++
  
   nValRep :=  IIF((cAliasQRY)->PGTMED == "0", 0, (cAliasQRY)->VALREP)
   nValDes :=  IIF((cAliasQRY)->PGTMED == "0", 0, (cAliasQRY)->VALDES)
  
   If nLin > nMaxLin
    MONTACAB(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)  // CABECALHO
    lQuebra := .T. 
	  EndIf 	

   If cPrest <> (cAliasQRY)->CODPRE  // quebra por    P R E S T A D O R
    If cPrest <> "Start"  
     PROTOT(4) // TOTAL CONVENIO/PLANO
     PROTOT(3, cAlias) // TOTAL DESPESA
     PROTOT(2) // TOTAL MEDICO
     PROTOT(1) // TOTAL PRESTADOR
     If MV_PAR03 == 1 // SALTA PAGINA POR PRESTADOR
      If nLin <> 9
        lStart  := .F.
        MONTACAB(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)  // CABECALHO
        lQuebra := .T. 
     	EndIf 
     Else                       
      nLin++
      @nLin,00 Psay replicate("=",215)    
      nLin++
     endIf
    EndIf
 	  @nLin, 000 Psay STR0016 + ALLTRIM((cAliasQRY)->CODPRE) + " - " + (cAliasQRY)->FANPRE  //"Prestador(a):   "
    nLin      := nLin+2
    cPrest    := (cAliasQRY)->CODPRE
    lQuebra   := .T.  // utilizado para imprimir o cabecalho dos detalhes
   EndIf 
   
   If cMedico <> (cAliasQRY)->CODCRM // quebra por    M E D I C O
    If cMedico <> "Start"  
     PROTOT(4) // TOTAL CONVENIO/PLANO
     PROTOT(3, cAlias) // TOTAL DESPESA
     PROTOT(2) // TOTAL MEDICO
     nLin++
     @nLin,00 Psay replicate("-",215)
    EndIf
    nLin++
    @nLin, 000 Psay STR0017 + ALLTRIM((cAliasQRY)->CODCRM) + " - " + HS_IniPadR("SRA", 11, (cAliasQRY)->CODCRM, "RA_NOME",,.F.) //"Medico(a):      "
    nLin++
    cMedico := (cAliasQRY)->CODCRM
    lQuebra := .T.  // utilizado para imprimir o cabecalho dos detalhes
   EndIf                                                     
  
   If cProced <> (cAliasQRY)->CODPRO // quebra por    DESPESA
    If cProced <> "Start"
     PROTOT(4) // TOTAL CONVENIO/PLANO
     PROTOT(3, cAlias) // TOTAL DESPESA
    EndIf
    nLin++
    @nLin, 000 Psay IIF(SUBSTR(ALLTRIM((cAliasQRY)->ALIAS), LEN(ALLTRIM((cAliasQRY)->ALIAS)), 1) == "5", STR0045, IIF(SUBSTR(ALLTRIM((cAliasQRY)->ALIAS), ;
                        LEN(ALLTRIM((cAliasQRY)->ALIAS)), 1) == "6", STR0046, STR0018)) + ALLTRIM((cAliasQRY)->CODPRO) + " - " + ;
                        IIF(Empty((cAliasQRY)->DESPRO), HS_INIPADR("SB1",1, (cAliasQRY)->CODPRO, "B1_DESC",,.F.),(cAliasQRY)->DESPRO)  //"Procedimento:   "
    nLin++
    cProced := (cAliasQRY)->CODPRO
    lQuebra := .T.  // utilizado para imprimir o cabecalho dos detalhes
   EndIf
  
   If cConven <> (cAliasQRY)->CODCON +  (cAliasQRY)->CODPLA // quebra por    C O N V E N I O
    If cConven <> "Start"  
     PROTOT(4) // TOTAL CONVENIO/PLANO
    EndIf
    nLin++    
    @nLin, 000 Psay STR0019 + ALLTRIM((cAliasQRY)->CODCON) + " - " + ALLTRIM((cAliasQRY)->CODPLA) + " - " + (cAliasQRY)->DESPLA // //"Convenio/Plano: "
    nLin := nLin + 2
    cConven := (cAliasQRY)->CODCON + (cAliasQRY)->CODPLA
    lQuebra := .T.  // utilizado para imprimir o cabecalho dos detalhes

    nPos := Ascan(aTotPrest,{|x| x[1]+x[2] == (cAliasQRY)->CODPRE + " - " + (cAliasQRY)->FANPRE + (cAliasQRY)->CODCON + " - " + (cAliasQRY)->CODPLA + " - " + (cAliasQRY)->DESPLA })
   
    IF nPos <= 0
     AADD(aTotPrest, {"","",0,0,0,0,0,0,0} )
     nPos := len(aTotPrest)
     aTotPrest[nPos,1] := (cAliasQRY)->CODPRE + " - " + (cAliasQRY)->FANPRE 
     aTotPrest[nPos,2] := (cAliasQRY)->CODCON + " - " + (cAliasQRY)->CODPLA + " - " + (cAliasQRY)->DESPLA 
    EndIf
   
   EndIf
  
   IIF((cAliasQRY)->ATENDI == "0",cTpAten := STR0020,IIF((cAliasQRY)->ATENDI == "1",cTpAten := STR0021,IIF((cAliasQRY)->ATENDI == "2",cTpAten := STR0022 ,"xxxxx")))  //"Int. "###"Amb. "###"P.A. "

   IF lQuebra
              /*              	    			   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                      		     	 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
    @nLin,000 Psay STR0023  //"DT.ATEND   HORA ATENDIM.  AMB/INT/PA  LOTE    CREDENCIAMENTO  NOME                            ATO MEDICO             QUANTIDADE    VAL.DESP.        GLOSA      REPASSE      PAGO TD.          PAGO  A  RECEBER     GL.ACEITA"
    nLin++
    lQuebra := .F.
   ENDIF
      
   @nLin,000  Psay dtoc(stod((cAliasQRY)->DATDES))
   @nLin,011  Psay (cAliasQRY)->HORDES              
   @nLin,018  Psay (cAliasQRY)->REGATE          
   @nLin,029  Psay cTpAten                           
   @nLin,038  Psay (cAliasQRY)->NRLOTE          
   @nLin,046  Psay FS_RDBRB4((cAliasQRY)->PGTMED, (cAliasQRY)->ALIAS)
   @nLin,062  Psay SUBSTR((cAliasQRY)->NOME,1,30)            
   @nLin,094  Psay PADR(IIF(!Empty((cAliasQRY)->CODATO), HS_IniPadR("GMC", 1, (cAliasQRY)->CODATO, "GMC_DESATO",,.F.), ""),20) 
   @nLin,117  Psay Transform((cAliasQRY)->QTDDES,"@E 999,999.99") 
   @nLin,130  Psay Transform(nValDes,"@E 999,999.99") 
   @nLin,143  Psay Transform((((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) - (cAliasQRY)->VALREC),"@E 999,999.99") 
   @nLin,156  Psay Transform(nValRep,"@E 999,999.99") 
   If Empty((cAliasQRY)->SEQMOV) .Or. (cAliasQRY)->SEQMOV == '000001' 
    @nLin,170  Psay Transform(nPagTudo, "@E 999,999.99") 
    
    nTotGerPgT := nTotGerPgT + nPagTudo
   
    nVPgTPro  := nVPgTPro  + nPagTudo
    nVPgTCon  := nVPgTCon  + nPagTudo
    nVPgTMed  := nVPgTMed  + nPagTudo
    nVPgTPre  := nVPgTPre  + nPagTudo
   
    
    aTotPrest[nPos,9] := aTotPrest[nPos,9] + nPagTudo
   
   Endif
   @nLin,184  Psay Transform(nValPag, "@E 999,999.99")
   If Empty((cAliasQRY)->SEQMOV) .Or. (cAliasQRY)->SEQMOV == '000001' .Or. MV_PAR05 == 1
    @nLin,196  Psay Transform(nValRec, "@E 999,999.99") 
    
    nTotGerRec := nTotGerRec + nValRec
   
    nVRecPro  := nVRecPro  + nValRec
    nVRecCon  := nVRecCon  + nValRec
    nVRecMed  := nVRecMed  + nValRec
    nVRecPre  := nVRecPre  + nValRec
    
    aTotPrest[nPos,7] := aTotPrest[nPos,7] + nValRec
   
   Endif
   @nLin,210  Psay Transform(nValPer, "@E 999,999.99") 

   nLinOld := nLin
  
   nLin++                                                                            
  
   nSomaPro := nSomaPro + nValDes
   nSomaCon := nSomaCon + nValDes
   nSomaMed := nSomaMed + nValDes
   nSomaPre := nSomaPre + nValDes                                        
  
   nTotGerHon := nTotGerHon + nValDes
   nTotGerGlo := nTotGerGlo + (((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) - (cAliasQRY)->VALREC)
   nTotGerRep := nTotGerRep + nValRep 
   nTotGerPag := nTotGerPag + nValPag
   nTotGerPer := nTotGerPer + nValPer
   
  
   nGloPro := nGloPro + (((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) - (cAliasQRY)->VALREC)
   nGloCon := nGloCon + (((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) - (cAliasQRY)->VALREC)
   nGloMed := nGloMed + (((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) - (cAliasQRY)->VALREC)
   nGloPre := nGloPre + (((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) - (cAliasQRY)->VALREC)
                                               
   nRepPro  := nRepPro  + nValRep 
   nRepCon  := nRepCon  + nValRep 
   nRepMed  := nRepMed  + nValRep 
   nRepPre  := nRepPre  + nValRep  
  
   nVPagPro := nVPagPro + nValPag
   nVPagCon := nVPagCon + nValPag
   nVPagMed := nVPagMed + nValPag
   nVPagPre := nVPagPre + nValPag
                                       
                                                
   nVPerPro  := nVPerPro  + nValPer
   nVPerCon  := nVPerCon  + nValPer
   nVPerMed  := nVPerMed  + nValPer
   nVPerPre  := nVPerPre  + nValPer 
   
     
  
   aTotPrest[nPos,3] := aTotPrest[nPos,3] + nValDes
   aTotPrest[nPos,4] := aTotPrest[nPos,4] + (((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) - (cAliasQRY)->VALREC)
   aTotPrest[nPos,5] := aTotPrest[nPos,5] + nValRep 
   aTotPrest[nPos,6] := aTotPrest[nPos,6] + nValPag
   aTotPrest[nPos,8] := aTotPrest[nPos,8] + nValPer
  
  
  Else
   If lInicio
    If !Empty((cAliasQRY)->CODCPG) 
     If ((cAliasQRY)->VALGLO + (cAliasQRY)->GLOFIL) == (cAliasQRY)->VALDES 
      nPagTudo := (cAliasQRY)->VALPAG
     Else
      nPagTudo +=  IIf((cAliasQRY)->SEQMOV == '000001', (cAliasQRY)->VALREP - ((cAliasQRY)->VLRGLO + (cAliasQRY)->GLOFIL), ;
                       (cAliasQRY)->VLRREC)
     Endif
   
     If STRZERO(MV_PAR05,2) $ "02/03" .And. nValPag == 0 
      nValRec -= nPagTudo
      If (cAliasQRY)->SEQMOV == '000001' 
       @nLinOld,197  Psay Transform(nValRec, "@E 999,999.99")
      Endif
      aTotPrest[nPos,7] += nValRec
      nVRecPro  += nValRec
      nVRecCon  += nValRec
      nVRecMed  += nValRec
      nVRecPre  += nValRec

      nTotGerRec += nValRec
     Endif

     If (cAliasQRY)->SEQMOV == '000001' 
      @nLinOld,171  Psay Transform(nPagTudo, "@E 999,999.99") 
     Endif
     If nPagTudo > 0
      nTotGerPgT += nPagTudo

      nVPgTPro  += nPagTudo
      nVPgTCon  += nPagTudo
      nVPgTMed  += nPagTudo
      nVPgTPre  += nPagTudo
      
      aTotPrest[nPos,9] += nPagTudo
     Endif
    Endif 
   Endif
  Endif 
  
   cAlias  := (cAliasQRY)->ALIAS
   cSeqDes := (cAliasQRY)->SEQDES
   
   DbSkip() 	    
  
 End

 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 //≥ FINAL DA IMPRESSAO PRINCIPAL E INICIO DOS TOTALIZADORES..... ≥
 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

 PROTOT(4) 
 PROTOT(3, cAlias)
 PROTOT(2)
 PROTOT(1)

 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 //≥ RESUMO DO TOTAIS POR PRESTADORES                             ≥
 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
 cPrettot := ""
 nLin     := 80
 
 FOR nCtaFor := 1 to Len(aTotPrest)  
  IF cPrettot != aTotPrest[nCtaFor,1] .OR. nLin > nMaxLin
   IF nLin > nMaxLin
    Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
    nLin := 9
   
              /*              	    			   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                      		     	 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
    @nLin,000  Psay STR0026 //"RESUMO DO TOTAIS POR PRESTADORES                       VAL.DESP.        GLOSA      REPASSE      PAGO TD.          PAGO    A  RECEBER     GL.ACEITA"
    nLin++
    @nLin,000  Psay REPLICATE( "-" , 146 )
    nLin++    
   ENDIF
   IF lSegParte
    @nLin, 000 Psay cPrettot
    @nLin, 054 Psay Transform(nTotPreHon,"@E 999,999.99")
    @nLin, 067 Psay Transform(nTotPreGlo,"@E 999,999.99")
    @nLin, 080 Psay Transform(nTotPreRep,"@E 999,999.99")
    @nLin, 094 Psay Transform(nTotPrePgT,"@E 999,999.99")
    @nLin, 108 Psay Transform(nTotPrePag,"@E 999,999.99")
    @nLin, 122 Psay Transform(nTotPreRec,"@E 999,999.99")
    @nLin, 136 Psay Transform(nTotPrePer,"@E 999,999.99")

    nTotPreHon := 0 
    nTotPreGlo := 0
    nTotPreRep := 0   
    nTotPrePag := 0 
    nTotPreRec := 0
    nTotPrePer := 0 
    nTotPrePgT := 0
    nLin++   
   ENDIF
   lSegParte  := .T. 
   cPrettot   := aTotPrest[nCtaFor,1]            
  ENDIF
  nTotPreHon := nTotPreHon + aTotPrest[nCtaFor,3]
  nTotPreGlo := nTotPreGlo + aTotPrest[nCtaFor,4]
  nTotPreRep := nTotPreRep + aTotPrest[nCtaFor,5]
  nTotPrePag := nTotPrePag + aTotPrest[nCtaFor,6]
  nTotPreRec := nTotPreRec + aTotPrest[nCtaFor,7]
  nTotPrePer := nTotPrePer + aTotPrest[nCtaFor,8]
  nTotPrePgT := nTotPrePgT + aTotPrest[nCtaFor,9]

  nTotSomaH   := nTotSomaH  + aTotPrest[nCtaFor,3]
  nTotSomaG   := nTotSomaG  + aTotPrest[nCtaFor,4]
  nTotSomaR   := nTotSomaR  + aTotPrest[nCtaFor,5]
  nTotSomaPg  := nTotSomaPg + aTotPrest[nCtaFor,6]
  nTotSomaRe  := nTotSomaRe + aTotPrest[nCtaFor,7]
  nTotSomaPe  := nTotSomaPe + aTotPrest[nCtaFor,8]
  nTotSomaPT  := nTotSomaPT + aTotPrest[nCtaFor,9]
   
 NEXT
 @nLin, 000 Psay cPrettot
 @nLin, 054 Psay Transform(nTotPreHon,"@E 999,999.99")
 @nLin, 067 Psay Transform(nTotPreGlo,"@E 999,999.99")
 @nLin, 080 Psay Transform(nTotPreRep,"@E 999,999.99")
 @nLin, 094 Psay Transform(nTotPrePgT,"@E 999,999.99")
 @nLin, 108 Psay Transform(nTotPrePag,"@E 999,999.99")
 @nLin, 122 Psay Transform(nTotPreRec,"@E 999,999.99")
 @nLin, 136 Psay Transform(nTotPrePer,"@E 999,999.99")
 nLin++                                                                                                 
 @nLin,000  Psay REPLICATE( "-" , 146 )

 nLin++
 @nLin,000  Psay STR0027 //"TOTAL GERAL POR PRESTADORES"
 @nLin, 054 Psay Transform(nTotSomaH,"@E 999,999.99")  
 @nLin, 067 Psay Transform(nTotSomaG,"@E 999,999.99")
 @nLin, 080 Psay Transform(nTotSomaR,"@E 999,999.99") 
 @nLin, 094 Psay Transform(nTotSomaPT,"@E 999,999.99")  
 @nLin, 108 Psay Transform(nTotSomaPg,"@E 999,999.99")  
 @nLin, 122 Psay Transform(nTotSomaRe,"@E 999,999.99")
 @nLin, 136 Psay Transform(nTotSomaPe,"@E 999,999.99")                                                    
 nLin++                                                                                                 
 @nLin,000  Psay REPLICATE( "-" , 146 )

 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 //≥ RESUMO DO TOTAIS POR CONVENIOS                               ≥
 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
 nTotSomaH  := 0
 nTotSomaR  := 0
 nTotSomaG  := 0    
 nTotSomaPg  := 0
 nTotSomaRe  := 0
 nTotSomaPe  := 0
 nTotSomaPT  := 0
 cConvtot   := ""
 nLin       := 80
 lSegParte  := .F.
 nTotPreHon := 0 
 nTotPreGlo := 0
 nTotPreRep := 0   
 nTotPrePag := 0 
 nTotPreRec := 0
 nTotPrePer := 0 
 nTotPrePgT := 0 
 
 aSort(aTotPrest ,,,{|x,y| x[2] < y[2]})
 
 FOR nCtaFor := 1 to Len(aTotPrest)  
  IF cConvtot != aTotPrest[nCtaFor,2] .OR. nLin > nMaxLin
   IF nLin > nMaxLin
    Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
    nLin := 9
    /*              	    			             1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                      		     	 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
    @nLin,000  Psay STR0028 //"RESUMO DO TOTAIS POR CONVENIOS                         VAL.DESP.        GLOSA      REPASSE      PAGO TD.          PAGO    A  RECEBER     GL.ACEITA"
    nLin++
    @nLin,000  Psay REPLICATE( "-" , 146 )
    nLin++    
   ENDIF
   IF lSegParte
    @nLin, 000 Psay cConvtot
    @nLin, 054 Psay Transform(nTotPreHon,"@E 999,999.99")
    @nLin, 067 Psay Transform(nTotPreGlo,"@E 999,999.99")
    @nLin, 080 Psay Transform(nTotPreRep,"@E 999,999.99")
    @nLin, 094 Psay Transform(nTotPrePgT,"@E 999,999.99")
    @nLin, 108 Psay Transform(nTotPrePag,"@E 999,999.99")
    @nLin, 122 Psay Transform(nTotPreRec,"@E 999,999.99")
    @nLin, 136 Psay Transform(nTotPrePer,"@E 999,999.99")
    nTotPreHon := 0  
    nTotPreGlo := 0
    nTotPreRep := 0 
    nTotPrePag := 0 
    nTotPreRec := 0
    nTotPrePer := 0 
    nTotPrePgT := 0     
    nLin++   
   ENDIF
   lSegParte  := .T. 
   cConvtot   := aTotPrest[nCtaFor,2]            
  ENDIF
  nTotPreHon := nTotPreHon + aTotPrest[nCtaFor,3]
  nTotSomaH  := nTotSomaH  + aTotPrest[nCtaFor,3]
  nTotPreGlo := nTotPreGlo + aTotPrest[nCtaFor,4]
  nTotSomaG  := nTotSomaG  + aTotPrest[nCtaFor,4]
  nTotPreRep := nTotPreRep + aTotPrest[nCtaFor,5]
  nTotSomaR  := nTotSomaR  + aTotPrest[nCtaFor,5]
  nTotPrePag := nTotPrePag + aTotPrest[nCtaFor,6]
  nTotSomaPg := nTotSomaPg + aTotPrest[nCtaFor,6]
  nTotPreRec := nTotPreRec + aTotPrest[nCtaFor,7]
  nTotSomaRe := nTotSomaRe + aTotPrest[nCtaFor,7]
  nTotPrePer := nTotPrePer + aTotPrest[nCtaFor,8]
  nTotSomaPe := nTotSomaPe + aTotPrest[nCtaFor,8]
  nTotPrePgT := nTotPrePgT + aTotPrest[nCtaFor,9]
  nTotSomaPT := nTotSomaPT + aTotPrest[nCtaFor,9]
 
 NEXT
 @nLin, 000 Psay cConvtot
 @nLin, 054 Psay Transform(nTotPreHon,"@E 999,999.99")  
 @nLin, 067 Psay Transform(nTotPreGlo,"@E 999,999.99") 
 @nLin, 080 Psay Transform(nTotPreRep,"@E 999,999.99") 
 @nLin, 094 Psay Transform(nTotPrePgT,"@E 999,999.99")
 @nLin, 108 Psay Transform(nTotPrePag,"@E 999,999.99")
 @nLin, 122 Psay Transform(nTotPreRec,"@E 999,999.99")
 @nLin, 136 Psay Transform(nTotPrePer,"@E 999,999.99")
 nLin++                                                                                                 
 @nLin,000  Psay REPLICATE( "-" , 146 )
 nLin++
 @nLin,000  Psay STR0029 //"TOTAL GERAL POR CONVENIOS"
 @nLin, 054 Psay Transform(nTotSomaH,"@E 999,999.99")  
 @nLin, 067 Psay Transform(nTotSomaG,"@E 999,999.99")                                                  
 @nLin, 080 Psay Transform(nTotSomaR,"@E 999,999.99")                                                  
 @nLin, 094 Psay Transform(nTotSomaPT,"@E 999,999.99")  
 @nLin, 108 Psay Transform(nTotSomaPg,"@E 999,999.99")  
 @nLin, 122 Psay Transform(nTotSomaRe,"@E 999,999.99")
 @nLin, 136 Psay Transform(nTotSomaPe,"@E 999,999.99")  
 nLin++                                                                                                 
 @nLin,000  Psay REPLICATE( "-" , 146 )


 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 //≥ RESUMO DO TOTAIS POR PRESTADORES / CONVENIOS                 ≥
 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
 aSort(aTotPrest ,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
 cPrettot := ""
 nLin     := 80 // forca quebra de pagina para iniciar a segunda etapa de impressao
 FOR nCtaFor := 1 to Len(aTotPrest)
  
  IF nCtaFor > 1
   IF cConvPla != SUBS(aTotPrest[nCtaFor,2],1,3).And. cPrettot == aTotPrest[nCtaFor,1]
     @nLin, 035 Psay STR0030   //"Total Convenio: "
     @nLin, 054 Psay Transform(nConvPlaH,"@E 999,999.99")  
     @nLin, 067 Psay Transform(nConvPlaG,"@E 999,999.99") 
     @nLin, 080 Psay Transform(nConvPlaR,"@E 999,999.99")  
     @nLin, 094 Psay Transform(nConvVlPT,"@E 999,999.99")  
     @nLin, 108 Psay Transform(nConvVlPg,"@E 999,999.99")  
     @nLin, 122 Psay Transform(nConvVlRe,"@E 999,999.99") 
     @nLin, 136 Psay Transform(nConvVlPe,"@E 999,999.99") 
     nLin := nLin + 2
     nConvPlaH := 0
     nConvPlaG := 0
     nConvPlaR := 0
     nConvVlPg := 0
     nConvVlRe := 0
     nConvVlPe := 0
     nConvVlPT := 0
   ENDIF
  ENDIF         
  
  IF cPrettot != aTotPrest[nCtaFor,1] .OR. nLin > nMaxLin
   If !Empty(cPrettot)
    @nLin, 035 Psay STR0030   //"Total Convenio: "
    @nLin, 054 Psay Transform(nConvPlaH,"@E 999,999.99")  
    @nLin, 067 Psay Transform(nConvPlaG,"@E 999,999.99") 
    @nLin, 080 Psay Transform(nConvPlaR,"@E 999,999.99")  
    @nLin, 094 Psay Transform(nConvVlPT,"@E 999,999.99")  
    @nLin, 108 Psay Transform(nConvVlPg,"@E 999,999.99")  
    @nLin, 122 Psay Transform(nConvVlRe,"@E 999,999.99") 
    @nLin, 136 Psay Transform(nConvVlPe,"@E 999,999.99") 
   Endif
   Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
   nLin := 9
   @nLin,000  Psay STR0031 //"RESUMO DO TOTAIS POR PRESTADORES / CONVENIOS           VAL.DESP.        GLOSA      REPASSE      PAGO TD.          PAGO    A  RECEBER     GL.ACEITA"
   nLin++
   @nLin,000  Psay REPLICATE( "-" , 146 )
   nLin++    
   @nLin, 000 Psay STR0032 + aTotPrest[nCtaFor,1]          //"Prestador: "
   nLin++
   cPrettot  := aTotPrest[nCtaFor,1]
   nConvPlaH := 0
   nConvPlaG := 0
   nConvPlaR := 0   
   nConvVlPg := 0
   nConvVlRe := 0
   nConvVlPe := 0
   nConvVlPT := 0
  ENDIF
  nConvPlaH  := nConvPlaH + aTotPrest[nCtaFor,3]
  nConvPlaG  := nConvPlaG + aTotPrest[nCtaFor,4]
  nConvPlaR  := nConvPlaR + aTotPrest[nCtaFor,5]   
  nConvVlPg  := nConvVlPg + aTotPrest[nCtaFor,6]
  nConvVlRe  := nConvVlRe + aTotPrest[nCtaFor,7]
  nConvVlPe  := nConvVlPe + aTotPrest[nCtaFor,8]
  nConvVlPT  := nConvVlPT + aTotPrest[nCtaFor,9]
  @nLin, 003 Psay aTotPrest[nCtaFor,2]
  @nLin, 054 Psay Transform(aTotPrest[nCtaFor,3],"@E 999,999.99")  
  @nLin, 067 Psay Transform(aTotPrest[nCtaFor,4],"@E 999,999.99") 
  @nLin, 080 Psay Transform(aTotPrest[nCtaFor,5],"@E 999,999.99")  
  @nLin, 094 Psay Transform(aTotPrest[nCtaFor,9],"@E 999,999.99")  
  @nLin, 108 Psay Transform(aTotPrest[nCtaFor,6],"@E 999,999.99")  
  @nLin, 122 Psay Transform(aTotPrest[nCtaFor,7],"@E 999,999.99") 
  @nLin, 136 Psay Transform(aTotPrest[nCtaFor,8],"@E 999,999.99") 
  nLin++
  cConvPla  := SUBS(aTotPrest[nCtaFor,2],1,3)
 NEXT
 @nLin, 035 Psay STR0030   //"Total Convenio: "
 @nLin, 054 Psay Transform(nConvPlaH,"@E 999,999.99")  
 @nLin, 067 Psay Transform(nConvPlaG,"@E 999,999.99")  
 @nLin, 080 Psay Transform(nConvPlaR,"@E 999,999.99")  
 @nLin, 094 Psay Transform(nConvVlPT,"@E 999,999.99")  
 @nLin, 108 Psay Transform(nConvVlPg,"@E 999,999.99")  
 @nLin, 122 Psay Transform(nConvVlRe,"@E 999,999.99")  
 @nLin, 136 Psay Transform(nConvVlPe,"@E 999,999.99") 
     
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 9
 /*              	    			             1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                   		     	 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
 @nLin,000  Psay STR0033 //"                                              VAL.DESP.            GLOSA          REPASSE          PAGO TD.              PAGO         A  RECEBER          GL.ACEITA"
 nLin++
 @nLin,000  Psay REPLICATE( "-" , 164 )
 nLin++  
 @nLin,000  Psay STR0034  //"TOTAL GERAL DOS PRESTADORES"
 @nLin,042  Psay Transform(nTotGerHon,"@E 999,999,999.99")  
 @nLin,059  Psay Transform(nTotGerGlo,"@E 999,999,999.99") 
 @nLin,076  Psay Transform(nTotGerRep,"@E 999,999,999.99") 
 @nLin,094  Psay Transform(nTotGerPgT,"@E 999,999,999.99")  
 @nLin,112  Psay Transform(nTotGerPag,"@E 999,999,999.99")  
 @nLin,131  Psay Transform(nTotGerRec,"@E 999,999,999.99") 
 @nLin,150  Psay Transform(nTotGerPer,"@E 999,999,999.99") 
 nLin++
 @nLin,000  Psay REPLICATE( "-" , 164 )

 DBSELECTAREA(cAliasQRY)
 dbCloseArea()
 
 Set Printer To
 SET DEVICE TO SCREEN

 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH() 
 
Return( Nil )
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ PROCQRY  ∫ Autor ≥ MARCELO JOSE       ∫ Data ≥  06/11/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ MONTA QUERY                                                ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GESTAO HOSPITALAR.                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
STATIC FUNCTION PROCQRY()
 Local cQuery   := ""                

 cQuery := "SELECT "
 cQuery += " 'G5' ALIAS, GAZ.GAZ_CODPRE CODPRE, GAZ.GAZ_FANPRE FANPRE, "
 cQuery += "GE5.GE5_CODCRM CODCRM, "
 cQuery += "GE5.GE5_CODDES CODPRO, ' ' DESPRO, GBI.GBI_TIPO TIPO, "    
 cQuery += "GCM.GCM_CODCON CODCON, GCM.GCM_CODPLA CODPLA, GCM.GCM_DESPLA DESPLA, "
 cQuery += "GCZ.GCZ_REGATE REGATE, GCZ.GCZ_ATENDI ATENDI, GCZ.GCZ_NRLOTE NRLOTE, GCZ.GCZ_NOME NOME, GCZ.GCZ_NRFATU NRFATU, "
 cQuery += "' ' CODATO, GAT.GAT_DTCRI DTCRI,"
 cQuery += "(CASE WHEN GE0.GE0_STATUS IS NULL THEN 'N' ELSE GE0.GE0_STATUS END) STAGE0, "
 cQuery += "(CASE WHEN GE0.GE0_DATREC IS NULL THEN ' ' ELSE GE0.GE0_DATREC END) DATREC, " 
 cQuery += "(CASE WHEN GDX.GDX_CODCPG IS NULL THEN ' ' ELSE GDX.GDX_CODCPG END) CODCPG, "
 cQuery += "(CASE WHEN GF5.GF5_VALGLO IS NULL THEN  0  ELSE GF5.GF5_VALGLO END) VALGLO, "
 cQuery += "(CASE WHEN GF5.GF5_VALREC IS NULL THEN  0  ELSE GF5.GF5_VALREC END) VALREC, "   
 cQuery += "(CASE WHEN GF5.GF5_VLRREC IS NULL THEN  0  ELSE GF5.GF5_VLRREC END) VLRREC, "
 cQuery += "(CASE WHEN GF5.GF5_VLRGLO IS NULL THEN  0  ELSE GF5.GF5_VLRGLO END) VLRGLO, " 
 cQuery += "(CASE WHEN GF5.GF5_VALPAG IS NULL THEN  0  ELSE GF5.GF5_VALPAG END) VALPAG, "    
 cQuery += "(CASE WHEN GDX.GDX_DATLAN IS NULL THEN ' ' ELSE GDX.GDX_DATLAN END) DATLAN, "   
 cQuery += "' ' ORIDES, GE5.GE5_SEQDES SEQDES, GE5.GE5_DATDES DATDES, GE5.GE5_HORDES HORDES, "
 cQuery += "GE5.GE5_QTDDES QTDDES, GE5.GE5_PGTMED PGTMED, "
 cQuery += HS_FValDes("GE5") + " VALDES, "  
 cQuery += "GE5.GE5_VALREP VALREP, "
 cQuery += "GF5.GF5_SEQMOV SEQMOV, GF5.GF5_STATUS STATGF, 0 GLOFIL "

 cQuery += " FROM " + RetSqlName("GE5") + " GE5"

 cQuery += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_NRSEQG = GE5.GE5_NRSEQG AND GCZ.D_E_L_E_T_ <> '*'"
 cQuery += " JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.D_E_L_E_T_ <> '*'" 
 cQuery += " AND GCZ.GCZ_ATENDI " + IIf(MV_PAR14 == 5, "<> '3'", IIF(MV_PAR14 == 4, " IN ('1', '2')", " = '" + Str(MV_PAR14-1, 1) + "'"))

 IF !Empty(MV_PAR07) //Filtra o CONVENIO
  cQuery += " AND GCZ_CODCON BETWEEN '" + MV_PAR06  + "' AND '" +  MV_PAR07 + "' " 
 ElseIf !Empty(MV_PAR06) //Filtra o CONVENIO
  cQuery += " AND GCZ.GCZ_CODCON >= '" + MV_PAR06  + "'"
 EndIf    
 
 If !Empty(MV_PAR09) //Filtra o LOTE
  cQuery += " AND GCZ.GCZ_NRLOTE BETWEEN '" + MV_PAR08  + "' AND '" +  MV_PAR09 + "' "
 ElseIf !Empty(MV_PAR08) 
  cQuery += " AND GCZ.GCZ_NRLOTE >= '" + MV_PAR08  + "'"
 EndIf

 cQuery += " JOIN " + RetSqlName("GAT") + " GAT ON GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.D_E_L_E_T_ <> '*'" 
 
 cQuery += " JOIN " + RetSqlName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GE5.GE5_CODPRE AND 	GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*'"
 IF !Empty(MV_PAR13) // FILTRA PRESTADOR
  cQuery += " AND GAZ_CODPRE BETWEEN '" + MV_PAR12  + "' AND '" +  MV_PAR13 + "'" 
 Else  
  cQuery += " AND GAZ_CODPRE >= '" + MV_PAR13 + "'" 
 EndIf

 cQuery += " JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL  = '" + xFilial("GBI") + "' AND GBI.GBI_PRODUT = GE5.GE5_CODDES	AND GBI.D_E_L_E_T_ <> '*'"

 cQuery += " LEFT JOIN " + RetSqlName("GF5") + " GF5 ON GF5.GF5_FILIAL = '" + xFilial("GF5") + "' AND GF5.GF5_SEQDES = GE5.GE5_SEQDES AND GF5.D_E_L_E_T_ <> '*'"
 cQuery += " LEFT JOIN " + RetSqlName("GE0") + " GE0 ON GE0.GE0_FILIAL = '" + xFilial("GE0") + "' AND GE0.GE0_NUMEXT = GF5.GF5_NREXTC AND GE0.D_E_L_E_T_ <> '*'"

 If MV_PAR17 == 1
  cQuery += " AND GE0.GE0_STATUS = '3'"
 ElseIf MV_PAR17 = 2 
  cQuery += " AND (GE0.GE0_STATUS IS NULL OR GE0.GE0_STATUS <> '3')"
 Endif
    
 cQuery += " LEFT JOIN " + RetSqlName("GDX") + " GDX ON GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.GDX_NREXTM = (CASE WHEN GF5.GF5_NREXTM = '" + Space(len(GF5->GF5_NREXTM)) + "' THEN GE5.GE5_NREXTM ELSE GF5.GF5_NREXTM END) AND GDX.D_E_L_E_T_ <> '*'"
 
 cQuery += " WHERE "
 cQuery += " GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' "

 If !Empty(MV_PAR02) //FILTRA MEDICO
  cQuery += " AND GE5.GE5_CODCRM BETWEEN '"  +  MV_PAR01 + "' AND '" +  MV_PAR02 + "'"
 Else   
  cQuery += " AND GE5.GE5_CODCRM >= '" + MV_PAR02 + "'"  
 EndIf
 
 If MV_PAR04 == 1
  cQuery += " AND GE5.GE5_PGTMED = '1'
 ElseIf MV_PAR04 == 2
  cQuery += " AND GE5.GE5_PGTMED IN ('0', '2', '3')
 Endif
  
 cQuery += " UNION ALL "
 cQuery += "SELECT "
 cQuery += " 'G6' ALIAS, GAZ.GAZ_CODPRE CODPRE, GAZ.GAZ_FANPRE FANPRE, "
 cQuery += "GE6.GE6_CODCRM CODCRM, "
 cQuery += "GE6.GE6_CODDES CODPRO, GAA.GAA_DESC DESPRO, GAA.GAA_TIPDES TIPO, "    
 cQuery += "GCM.GCM_CODCON CODCON, GCM.GCM_CODPLA CODPLA, GCM.GCM_DESPLA DESPLA, "
 cQuery += "GCZ.GCZ_REGATE REGATE, GCZ.GCZ_ATENDI ATENDI, GCZ.GCZ_NRLOTE NRLOTE, GCZ.GCZ_NOME NOME, GCZ.GCZ_NRFATU NRFATU, "
 cQuery += "' ' CODATO, GAT.GAT_DTCRI DTCRI,"
 cQuery += "(CASE WHEN GE0.GE0_STATUS IS NULL THEN 'N' ELSE GE0.GE0_STATUS END) STAGE0, "
 cQuery += "(CASE WHEN GE0.GE0_DATREC IS NULL THEN ' ' ELSE GE0.GE0_DATREC END) DATREC, " 
 cQuery += "(CASE WHEN GDX.GDX_CODCPG IS NULL THEN ' ' ELSE GDX.GDX_CODCPG END) CODCPG, "
 cQuery += "(CASE WHEN GF6.GF6_VALGLO IS NULL THEN  0  ELSE GF6.GF6_VALGLO END) VALGLO, "
 cQuery += "(CASE WHEN GF6.GF6_VALREC IS NULL THEN  0  ELSE GF6.GF6_VALREC END) VALREC, "   
 cQuery += "(CASE WHEN GF6.GF6_VLRREC IS NULL THEN  0  ELSE GF6.GF6_VLRREC END) VLRREC, "
 cQuery += "(CASE WHEN GF6.GF6_VLRGLO IS NULL THEN  0  ELSE GF6.GF6_VLRGLO END) VLRGLO, " 
 cQuery += "(CASE WHEN GF6.GF6_VALPAG IS NULL THEN  0  ELSE GF6.GF6_VALPAG END) VALPAG, "    
 cQuery += "(CASE WHEN GDX.GDX_DATLAN IS NULL THEN ' ' ELSE GDX.GDX_DATLAN END) DATLAN, "   
 cQuery += "' ' ORIDES, GE6.GE6_SEQDES SEQDES, GE6.GE6_DATDES DATDES, GE6.GE6_HORDES HORDES, "
 cQuery += "GE6.GE6_QTDDES QTDDES, GE6.GE6_PGTMED PGTMED, "
 cQuery += HS_FValDes("GE6") + " VALDES, "  
 cQuery += "GE6.GE6_VALREP VALREP, "
 cQuery += "GF6.GF6_SEQMOV SEQMOV, GF6.GF6_STATUS STATGF, 0 GLOFIL"

 cQuery += " FROM " + RetSqlName("GE6") + " GE6"

 cQuery += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_NRSEQG = GE6.GE6_NRSEQG AND GCZ.D_E_L_E_T_ <> '*'"
 cQuery += " JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.D_E_L_E_T_ <> '*'" 
 cQuery += " AND GCZ.GCZ_ATENDI " + IIf(MV_PAR14 == 5, "<> '3'", IIF(MV_PAR14 == 4, " IN ('1', '2')", " = '" + Str(MV_PAR14-1, 1) + "'"))

 IF !Empty(MV_PAR07) //Filtra o CONVENIO
  cQuery += " AND GCZ_CODCON BETWEEN '" + MV_PAR06  + "' AND '" +  MV_PAR07 + "' " 
 ElseIf !Empty(MV_PAR06) //Filtra o CONVENIO
  cQuery += " AND GCZ.GCZ_CODCON >= '" + MV_PAR06  + "'"
 EndIf    
 
 If !Empty(MV_PAR09) //Filtra o LOTE
  cQuery += " AND GCZ.GCZ_NRLOTE BETWEEN '" + MV_PAR08  + "' AND '" +  MV_PAR09 + "' "
 ElseIf !Empty(MV_PAR08) 
  cQuery += " AND GCZ.GCZ_NRLOTE >= '" + MV_PAR08  + "'"
 EndIf

 cQuery += " JOIN " + RetSqlName("GAT") + " GAT ON GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.D_E_L_E_T_ <> '*'" 
                                                      

 cQuery += " JOIN " + RetSqlName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GE6.GE6_CODPRE AND 	GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*'"
 IF !Empty(MV_PAR13) // FILTRA PRESTADOR
  cQuery += " AND GAZ_CODPRE BETWEEN '" + MV_PAR12  + "' AND '" +  MV_PAR13 + "'" 
 Else  
  cQuery += " AND GAZ_CODPRE >= '" + MV_PAR13 + "'" 
 EndIf

 cQuery += " JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL  = '" + xFilial("GAA") + "' AND GAA.GAA_CODTXD = GE6.GE6_CODDES	AND GAA.D_E_L_E_T_ <> '*'"

 cQuery += " LEFT JOIN " + RetSqlName("GF6") + " GF6 ON GF6.GF6_FILIAL = '" + xFilial("GF6") + "' AND GF6.GF6_SEQDES = GE6.GE6_SEQDES AND GF6.D_E_L_E_T_ <> '*'"
 cQuery += " LEFT JOIN " + RetSqlName("GE0") + " GE0 ON GE0.GE0_FILIAL = '" + xFilial("GE0") + "' AND GE0.GE0_NUMEXT = GF6.GF6_NREXTC AND GE0.D_E_L_E_T_ <> '*'"

 If MV_PAR17 == 1
  cQuery += " AND GE0.GE0_STATUS = '3'"
 ElseIf MV_PAR17 = 2 
  cQuery += " AND (GE0.GE0_STATUS IS NULL OR GE0.GE0_STATUS <> '3')"
 Endif
    
 cQuery += " LEFT JOIN " + RetSqlName("GDX") + " GDX ON GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.GDX_NREXTM = (CASE WHEN GF6.GF6_NREXTM = '" + Space(len(GF6->GF6_NREXTM)) + "' THEN GE6.GE6_NREXTM ELSE GF6.GF6_NREXTM END) AND GDX.D_E_L_E_T_ <> '*'"
 
 cQuery += " WHERE "
 cQuery += " GE6_FILIAL = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*' "

 If !Empty(MV_PAR02) //FILTRA MEDICO
  cQuery += " AND GE6.GE6_CODCRM BETWEEN '"  +  MV_PAR01 + "' AND '" +  MV_PAR02 + "'"
 Else   
  cQuery += " AND GE6.GE6_CODCRM >= '" + MV_PAR02 + "'"  
 EndIf

 If MV_PAR04 == 1
  cQuery += " AND GE6.GE6_PGTMED = '1'
 ElseIf MV_PAR04 == 2
  cQuery += " AND GE6.GE6_PGTMED IN ('0', '2', '3')
 Endif

 cQuery += "UNION ALL "
 cQuery += "SELECT "
 cQuery += " 'G7' ALIAS, GAZ.GAZ_CODPRE CODPRE, GAZ.GAZ_FANPRE FANPRE, "
 cQuery += "GE7.GE7_CODCRM CODCRM, "
 cQuery += "GE7.GE7_CODDES CODPRO, GA7.GA7_DESC DESPRO, GA7.GA7_TIPPRO TIPO, "    
 cQuery += "GCM.GCM_CODCON CODCON, GCM.GCM_CODPLA CODPLA, GCM.GCM_DESPLA DESPLA, "
 cQuery += "GCZ.GCZ_REGATE REGATE, GCZ.GCZ_ATENDI ATENDI, GCZ.GCZ_NRLOTE NRLOTE, GCZ.GCZ_NOME NOME, GCZ.GCZ_NRFATU NRFATU, "
 cQuery += "GE7.GE7_CODATO CODATO, GAT.GAT_DTCRI DTCRI,"
 cQuery += "(CASE WHEN GE0.GE0_STATUS IS NULL THEN 'N' ELSE GE0.GE0_STATUS END) STAGE0, "
 cQuery += "(CASE WHEN GE0.GE0_DATREC IS NULL THEN ' ' ELSE GE0.GE0_DATREC END) DATREC, " 
 cQuery += "(CASE WHEN GDX.GDX_CODCPG IS NULL THEN ' ' ELSE GDX.GDX_CODCPG END) CODCPG, "
 cQuery += "(CASE WHEN GF7.GF7_VALGLO IS NULL THEN  0  ELSE GF7.GF7_VALGLO END) VALGLO, "
 cQuery += "(CASE WHEN GF7.GF7_VALREC IS NULL THEN  0  ELSE GF7.GF7_VALREC END) VALREC, "   
 cQuery += "(CASE WHEN GF7.GF7_VLRREC IS NULL THEN  0  ELSE GF7.GF7_VLRREC END) VLRREC, "
 cQuery += "(CASE WHEN GF7.GF7_VLRGLO IS NULL THEN  0  ELSE GF7.GF7_VLRGLO END) VLRGLO, " 
 cQuery += "(CASE WHEN GF7.GF7_VALPAG IS NULL THEN  0  ELSE GF7.GF7_VALPAG END) VALPAG, "    
 cQuery += "(CASE WHEN GDX.GDX_DATLAN IS NULL THEN ' ' ELSE GDX.GDX_DATLAN END) DATLAN, "   
 cQuery += "(CASE WHEN GF7.GF7_ORIDES IS NULL THEN ' ' ELSE GF7.GF7_ORIDES END) ORIDES, "   
 cQuery += "GE7.GE7_SEQDES SEQDES, GE7.GE7_DATDES DATDES, GE7.GE7_HORDES HORDES, "
 cQuery += "GE7.GE7_QTDDES QTDDES, GE7.GE7_PGTMED PGTMED, "
 cQuery += HS_FValDes("GE7") + " VALDES, "  
 cQuery += "GE7.GE7_VALREP VALREP, "
 cQuery += "GF7.GF7_SEQMOV SEQMOV, GF7.GF7_STATUS STATGF, GE7.GE7_GLOFIL GLOFIL "

 cQuery += " FROM " + RetSqlName("GE7") + " GE7"

 cQuery += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG AND GCZ.D_E_L_E_T_ <> '*'"
 cQuery += " JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.D_E_L_E_T_ <> '*'" 
 cQuery += " AND GCZ.GCZ_ATENDI " + IIf(MV_PAR14 == 5, "<> '3'", IIF(MV_PAR14 == 4, " IN ('1', '2')", " = '" + Str(MV_PAR14-1, 1) + "'"))

 IF !Empty(MV_PAR07) //Filtra o CONVENIO
  cQuery += " AND GCZ_CODCON BETWEEN '" + MV_PAR06  + "' AND '" +  MV_PAR07 + "' " 
 ElseIf !Empty(MV_PAR06) //Filtra o CONVENIO
  cQuery += " AND GCZ.GCZ_CODCON >= '" + MV_PAR06  + "'"
 EndIf    
 
 If !Empty(MV_PAR09) //Filtra o LOTE
  cQuery += " AND GCZ.GCZ_NRLOTE BETWEEN '" + MV_PAR08  + "' AND '" +  MV_PAR09 + "' "
 ElseIf !Empty(MV_PAR08) 
  cQuery += " AND GCZ.GCZ_NRLOTE >= '" + MV_PAR08  + "'"
 EndIf

 cQuery += " JOIN " + RetSqlName("GAT") + " GAT ON GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.D_E_L_E_T_ <> '*'" 
                                                      

 cQuery += " JOIN " + RetSqlName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GE7.GE7_CODPRE AND 	GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*'"
 IF !Empty(MV_PAR13) // FILTRA PRESTADOR
  cQuery += " AND GAZ_CODPRE BETWEEN '" + MV_PAR12  + "' AND '" +  MV_PAR13 + "'" 
 Else  
  cQuery += " AND GAZ_CODPRE >= '" + MV_PAR13 + "'" 
 EndIf

 cQuery += " JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL  = '" + xFilial("GA7") + "' AND GA7.GA7_CODPRO = GE7.GE7_CODDES	AND GA7.D_E_L_E_T_ <> '*'"

 cQuery += " LEFT JOIN " + RetSqlName("GF7") + " GF7 ON GF7.GF7_FILIAL = '" + xFilial("GF7") + "' AND GF7.GF7_SEQDES = GE7.GE7_SEQDES AND GF7.D_E_L_E_T_ <> '*'"
 cQuery += " LEFT JOIN " + RetSqlName("GE0") + " GE0 ON GE0.GE0_FILIAL = '" + xFilial("GE0") + "' AND GE0.GE0_NUMEXT = GF7.GF7_NREXTC AND GE0.D_E_L_E_T_ <> '*'"

 If MV_PAR17 == 1
  cQuery += " AND GE0.GE0_STATUS = '3'"
 ElseIf MV_PAR17 = 2 
  cQuery += " AND (GE0.GE0_STATUS IS NULL OR GE0.GE0_STATUS <> '3')"
 Endif
    
 cQuery += " LEFT JOIN " + RetSqlName("GDX") + " GDX ON GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.GDX_NREXTM = (CASE WHEN GF7.GF7_NREXTM = '" + Space(len(GF7->GF7_NREXTM)) + "' THEN GE7.GE7_NREXTM ELSE GF7.GF7_NREXTM END) AND GDX.D_E_L_E_T_ <> '*'"
 
 cQuery += " WHERE "
 cQuery += " GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cQuery += " AND (GF7.GF7_ORIDES IS NULL OR GF7.GF7_ORIDES <> '3')  "
 
 If !Empty(MV_PAR02) //FILTRA MEDICO
  cQuery += " AND GE7.GE7_CODCRM BETWEEN '"  +  MV_PAR01 + "' AND '" +  MV_PAR02 + "'"
 Else   
  cQuery += " AND GE7.GE7_CODCRM >= '" + MV_PAR02 + "'"  
 EndIf
 
 If MV_PAR04 == 1
  cQuery += " AND GE7.GE7_PGTMED = '1'
 ElseIf MV_PAR04 == 2
  cQuery += " AND GE7.GE7_PGTMED IN ('0', '2', '3')
 Endif
  
 If !Empty(MV_PAR16) //FILTRA ATO MEDICO
  cQuery += " AND GE7.GE7_CODATO BETWEEN '"  +  MV_PAR15 + "' AND '" +  MV_PAR16 + "'"  
 Else 
  cQuery += " AND GE7.GE7_CODATO >= '" +  MV_PAR16 + "'"  
 EndIf
 
 cQuery += "UNION ALL "
 cQuery += "SELECT "
 cQuery += " 'GG5' ALIAS, GAZ.GAZ_CODPRE CODPRE, GAZ.GAZ_FANPRE FANPRE, "
 cQuery += "GG5.GG5_CODCRM CODCRM, "
 cQuery += "GG5.GG5_CODDES CODPRO, ' ' DESPRO,GBI.GBI_TIPO TIPO, "   
 cQuery += "GCM.GCM_CODCON CODCON, GCM.GCM_CODPLA CODPLA, GCM.GCM_DESPLA DESPLA, "
 cQuery += "GCZ.GCZ_REGATE REGATE, GCZ.GCZ_ATENDI ATENDI, GCZ.GCZ_NRLOTE NRLOTE, GCZ.GCZ_NOME NOME, GCZ.GCZ_NRFATU NRFATU, "
 cQuery += "' ' CODATO, GAT.GAT_DTCRI DTCRI,"
 cQuery += "(CASE WHEN GE0.GE0_STATUS IS NULL THEN 'N' ELSE GE0.GE0_STATUS END) STAGE0, "
 cQuery += "(CASE WHEN GE0.GE0_DATREC IS NULL THEN ' ' ELSE GE0.GE0_DATREC END) DATREC, " 
 cQuery += "(CASE WHEN GDX.GDX_CODCPG IS NULL THEN ' ' ELSE GDX.GDX_CODCPG END) CODCPG, "
 cQuery += "GG5.GG5_VALGLO VALGLO, GG5.GG5_VALREC VALREC, GG5.GG5_VLRREC VLRREC, GG5.GG5_VLRGLO VLRGLO, GG5.GG5_VALPAG VALPAG, "    
 cQuery += "(CASE WHEN GDX.GDX_DATLAN IS NULL THEN ' ' ELSE GDX.GDX_DATLAN END) DATLAN, "   
 cQuery += "(CASE WHEN GF7.GF7_ORIDES IS NULL THEN ' ' ELSE GF7.GF7_ORIDES END) ORIDES, "
 cQuery += " GG5.GG5_SEQDES SEQDES, GG5.GG5_DATDES DATDES, GG5.GG5_HORDES HORDES, "
 cQuery += "GG5.GG5_QTDDES QTDDES, GG5.GG5_PGTMED PGTMED, "
 cQuery += HS_FValDes("GG5") + " VALDES, "  
 cQuery += "GG5.GG5_VALREP VALREP, "
 cQuery += "GF7.GF7_SEQMOV SEQMOV, GF7.GF7_STATUS STATGF, 0 GLOFIL "

 cQuery += " FROM " + RetSqlName("GG5") + " GG5"

 cQuery += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_NRSEQG = GG5.GG5_NRSEQG AND GCZ.D_E_L_E_T_ <> '*'"
 cQuery += " JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.D_E_L_E_T_ <> '*'" 
 cQuery += " AND GCZ.GCZ_ATENDI " + IIf(MV_PAR14 == 5, "<> '3'", IIF(MV_PAR14 == 4, " IN ('1', '2')", " = '" + Str(MV_PAR14-1, 1) + "'"))

 IF !Empty(MV_PAR07) //Filtra o CONVENIO
  cQuery += " AND GCZ_CODCON BETWEEN '" + MV_PAR06  + "' AND '" +  MV_PAR07 + "' " 
 ElseIf !Empty(MV_PAR06) //Filtra o CONVENIO
  cQuery += " AND GCZ.GCZ_CODCON >= '" + MV_PAR06  + "'"
 EndIf    
 
 If !Empty(MV_PAR09) //Filtra o LOTE
  cQuery += " AND GCZ.GCZ_NRLOTE BETWEEN '" + MV_PAR08  + "' AND '" +  MV_PAR09 + "' "
 ElseIf !Empty(MV_PAR08) 
  cQuery += " AND GCZ.GCZ_NRLOTE >= '" + MV_PAR08  + "'"
 EndIf

 cQuery += " JOIN " + RetSqlName("GAT") + " GAT ON GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.D_E_L_E_T_ <> '*'" 
 
 cQuery += " JOIN " + RetSqlName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GG5.GG5_CODPRE AND 	GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*'"
 IF !Empty(MV_PAR13) // FILTRA PRESTADOR
  cQuery += " AND GAZ_CODPRE BETWEEN '" + MV_PAR12  + "' AND '" +  MV_PAR13 + "'" 
 Else  
  cQuery += " AND GAZ_CODPRE >= '" + MV_PAR13 + "'" 
 EndIf

 cQuery += " JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL  = '" + xFilial("GBI") + "' AND GBI.GBI_PRODUT = GG5.GG5_CODDES	AND GBI.D_E_L_E_T_ <> '*'"
 cQuery += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_SEQDES = GG5.GG5_SEQGE7 AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cQuery += " LEFT JOIN " + RetSqlName("GF7") + " GF7 ON GF7.GF7_FILIAL = '" + xFilial("GF7") + "' AND GF7.GF7_SEQDES = GE7.GE7_SEQDES AND GF7.D_E_L_E_T_ <> '*'"
 cQuery += " LEFT JOIN " + RetSqlName("GE0") + " GE0 ON GE0.GE0_FILIAL = '" + xFilial("GE0") + "' AND GE0.GE0_NUMEXT = GF7.GF7_NREXTC AND GE0.D_E_L_E_T_ <> '*'"

 If MV_PAR17 == 1
  cQuery += " AND GE0.GE0_STATUS = '3'"
 ElseIf MV_PAR17 = 2 
  cQuery += " AND (GE0.GE0_STATUS IS NULL OR GE0.GE0_STATUS <> '3')"
 Endif
    
 cQuery += " LEFT JOIN " + RetSqlName("GDX") + " GDX ON GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.GDX_NREXTM = GG5.GG5_NREXTM AND GDX.D_E_L_E_T_ <> '*'"
 
 cQuery += " WHERE "
 cQuery += " GG5_FILIAL = '" + xFilial("GG5") + "' AND GG5.D_E_L_E_T_ <> '*' "
 cQuery += " AND (GF7.GF7_ORIDES IS NULL OR GF7.GF7_ORIDES <> '3')  "
 
 If !Empty(MV_PAR02) //FILTRA MEDICO
  cQuery += " AND GG5.GG5_CODCRM BETWEEN '"  +  MV_PAR01 + "' AND '" +  MV_PAR02 + "'"
 Else   
  cQuery += " AND GG5.GG5_CODCRM >= '" + MV_PAR02 + "'"  
 EndIf
 

 If MV_PAR04 == 1
  cQuery += " AND GG5.GG5_PGTMED = '1'
 ElseIf MV_PAR04 == 2
  cQuery += " AND GG5.GG5_PGTMED IN ('0', '2', '3')
 Endif
  
 cQuery += " UNION ALL "
 cQuery += "SELECT "
 cQuery += " 'GG6' ALIAS, GAZ.GAZ_CODPRE CODPRE, GAZ.GAZ_FANPRE FANPRE, "
 cQuery += "GG6.GG6_CODCRM CODCRM, "
 cQuery += "GG6.GG6_CODDES CODPRO, GAA.GAA_DESC DESPRO, GAA.GAA_TIPDES TIPO, "    
 cQuery += "GCM.GCM_CODCON CODCON, GCM.GCM_CODPLA CODPLA, GCM.GCM_DESPLA DESPLA, "
 cQuery += "GCZ.GCZ_REGATE REGATE, GCZ.GCZ_ATENDI ATENDI, GCZ.GCZ_NRLOTE NRLOTE, GCZ.GCZ_NOME NOME, GCZ.GCZ_NRFATU NRFATU, "
 cQuery += "' ' CODATO, GAT.GAT_DTCRI DTCRI,"
 cQuery += "(CASE WHEN GE0.GE0_STATUS IS NULL THEN 'N' ELSE GE0.GE0_STATUS END) STAGE0, "
 cQuery += "(CASE WHEN GE0.GE0_DATREC IS NULL THEN ' ' ELSE GE0.GE0_DATREC END) DATREC, " 
 cQuery += "(CASE WHEN GDX.GDX_CODCPG IS NULL THEN ' ' ELSE GDX.GDX_CODCPG END) CODCPG, "
 cQuery += "GG6.GG6_VALGLO VALGLO, GG6.GG6_VALREC VALREC, GG6.GG6_VLRREC VLRREC, GG6.GG6_VLRGLO VLRGLO, GG6.GG6_VALPAG VALPAG, "    
 cQuery += "(CASE WHEN GDX.GDX_DATLAN IS NULL THEN ' ' ELSE GDX.GDX_DATLAN END) DATLAN, "   
 cQuery += "(CASE WHEN GF7.GF7_ORIDES IS NULL THEN ' ' ELSE GF7.GF7_ORIDES END) ORIDES, "
 cQuery += "GG6.GG6_SEQDES SEQDES, GG6.GG6_DATDES DATDES, GG6.GG6_HORDES HORDES, "
 cQuery += "GG6.GG6_QTDDES QTDDES, GG6.GG6_PGTMED PGTMED, "
 cQuery += HS_FValDes("GG6") + " VALDES, "  
 cQuery += "GG6.GG6_VALREP VALREP, "
 cQuery += "GF7.GF7_SEQMOV SEQMOV, GF7.GF7_STATUS STATGF, 0 GLOFIL "

 cQuery += " FROM " + RetSqlName("GG6") + " GG6"

 cQuery += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_NRSEQG = GG6.GG6_NRSEQG AND GCZ.D_E_L_E_T_ <> '*'"
 cQuery += " JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.D_E_L_E_T_ <> '*'" 
 cQuery += " AND GCZ.GCZ_ATENDI " + IIf(MV_PAR14 == 5, "<> '3'", IIF(MV_PAR14 == 4, " IN ('1', '2')", " = '" + Str(MV_PAR14-1, 1) + "'"))

 IF !Empty(MV_PAR07) //Filtra o CONVENIO
  cQuery += " AND GCZ_CODCON BETWEEN '" + MV_PAR06  + "' AND '" +  MV_PAR07 + "' " 
 ElseIf !Empty(MV_PAR06) //Filtra o CONVENIO
  cQuery += " AND GCZ.GCZ_CODCON >= '" + MV_PAR06  + "'"
 EndIf    
 
 If !Empty(MV_PAR09) //Filtra o LOTE
  cQuery += " AND GCZ.GCZ_NRLOTE BETWEEN '" + MV_PAR08  + "' AND '" +  MV_PAR09 + "' "
 ElseIf !Empty(MV_PAR08) 
  cQuery += " AND GCZ.GCZ_NRLOTE >= '" + MV_PAR08  + "'"
 EndIf

 cQuery += " JOIN " + RetSqlName("GAT") + " GAT ON GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.D_E_L_E_T_ <> '*'" 
                                                      

 cQuery += " JOIN " + RetSqlName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GG6.GG6_CODPRE AND 	GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*'"
 IF !Empty(MV_PAR13) // FILTRA PRESTADOR
  cQuery += " AND GAZ_CODPRE BETWEEN '" + MV_PAR12  + "' AND '" +  MV_PAR13 + "'" 
 Else  
  cQuery += " AND GAZ_CODPRE >= '" + MV_PAR13 + "'" 
 EndIf

 cQuery += " JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL  = '" + xFilial("GAA") + "' AND GAA.GAA_CODTXD = GG6.GG6_CODDES	AND GAA.D_E_L_E_T_ <> '*'"
 cQuery += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_SEQDES = GG6.GG6_SEQGE7 AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cQuery += " LEFT JOIN " + RetSqlName("GF7") + " GF7 ON GF7.GF7_FILIAL = '" + xFilial("GF7") + "' AND GF7.GF7_SEQDES = GE7.GE7_SEQDES AND GF7.D_E_L_E_T_ <> '*'"
 cQuery += " LEFT JOIN " + RetSqlName("GE0") + " GE0 ON GE0.GE0_FILIAL = '" + xFilial("GE0") + "' AND GE0.GE0_NUMEXT = GF7.GF7_NREXTC AND GE0.D_E_L_E_T_ <> '*'"

 If MV_PAR17 == 1
  cQuery += " AND GE0.GE0_STATUS = '3'"
 ElseIf MV_PAR17 = 2 
  cQuery += " AND (GE0.GE0_STATUS IS NULL OR GE0.GE0_STATUS <> '3')"
 Endif
    
 cQuery += " LEFT JOIN " + RetSqlName("GDX") + " GDX ON GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.GDX_NREXTM =  GG6.GG6_NREXTM AND GDX.D_E_L_E_T_ <> '*'"
 
 cQuery += " WHERE "
 cQuery += " GG6_FILIAL = '" + xFilial("GG6") + "' AND GG6.D_E_L_E_T_ <> '*' "
 cQuery += " AND (GF7.GF7_ORIDES IS NULL OR GF7.GF7_ORIDES <> '3')  "

 If !Empty(MV_PAR02) //FILTRA MEDICO
  cQuery += " AND GG6.GG6_CODCRM BETWEEN '"  +  MV_PAR01 + "' AND '" +  MV_PAR02 + "'"
 Else   
  cQuery += " AND GG6.GG6_CODCRM >= '" + MV_PAR02 + "'"  
 EndIf
 
 If MV_PAR04 == 1
  cQuery += " AND GG6.GG6_PGTMED = '1'
 ElseIf MV_PAR04 == 2
  cQuery += " AND GG6.GG6_PGTMED IN ('0', '2', '3')
 Endif

 cQuery += "UNION ALL "
 cQuery += "SELECT "
 cQuery += " 'GG7' ALIAS, GAZ.GAZ_CODPRE CODPRE, GAZ.GAZ_FANPRE FANPRE, "
 cQuery += "GG7.GG7_CODCRM CODCRM, "
 cQuery += "GG7.GG7_CODDES CODPRO, GA7.GA7_DESC DESPRO, GA7.GA7_TIPPRO TIPO, "    
 cQuery += "GCM.GCM_CODCON CODCON, GCM.GCM_CODPLA CODPLA, GCM.GCM_DESPLA DESPLA, "
 cQuery += "GCZ.GCZ_REGATE REGATE, GCZ.GCZ_ATENDI ATENDI, GCZ.GCZ_NRLOTE NRLOTE, GCZ.GCZ_NOME NOME, GCZ.GCZ_NRFATU NRFATU, "
 cQuery += "GG7.GG7_CODATO CODATO, GAT.GAT_DTCRI DTCRI,"
 cQuery += "(CASE WHEN GE0.GE0_STATUS IS NULL THEN 'N' ELSE GE0.GE0_STATUS END) STAGE0, "
 cQuery += "(CASE WHEN GE0.GE0_DATREC IS NULL THEN ' ' ELSE GE0.GE0_DATREC END) DATREC, " 
 cQuery += "(CASE WHEN GDX.GDX_CODCPG IS NULL THEN ' ' ELSE GDX.GDX_CODCPG END) CODCPG, "
 cQuery += "GG7.GG7_VALGLO VALGLO, GG7.GG7_VALREC VALREC, GG7.GG7_VLRREC VLRREC, GG7.GG7_VLRGLO VLRGLO, GG7.GG7_VALPAG VALPAG, "    
 cQuery += "(CASE WHEN GDX.GDX_DATLAN IS NULL THEN ' ' ELSE GDX.GDX_DATLAN END) DATLAN, "   
 cQuery += "(CASE WHEN GF7.GF7_ORIDES IS NULL THEN ' ' ELSE GF7.GF7_ORIDES END) ORIDES, "
 cQuery += "GG7.GG7_SEQDES SEQDES, GG7.GG7_DATDES DATDES, GG7.GG7_HORDES HORDES, "
 cQuery += "GG7.GG7_QTDDES QTDDES, GG7.GG7_PGTMED PGTMED, "
 cQuery += HS_FValDes("GG7") + " VALDES, "  
 cQuery += "GG7.GG7_VALREP VALREP, "
 cQuery += "GF7.GF7_SEQMOV SEQMOV, GF7.GF7_STATUS STATGF, GG7.GG7_GLOFIL GLOFIL "

 cQuery += " FROM " + RetSqlName("GG7") + " GG7"

 cQuery += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_NRSEQG = GG7.GG7_NRSEQG AND GCZ.D_E_L_E_T_ <> '*'"
 cQuery += " JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.D_E_L_E_T_ <> '*'" 
 cQuery += " AND GCZ.GCZ_ATENDI " + IIf(MV_PAR14 == 5, "<> '3'", IIF(MV_PAR14 == 4, " IN ('1', '2')", " = '" + Str(MV_PAR14-1, 1) + "'"))

 IF !Empty(MV_PAR07) //Filtra o CONVENIO
  cQuery += " AND GCZ_CODCON BETWEEN '" + MV_PAR06  + "' AND '" +  MV_PAR07 + "' " 
 ElseIf !Empty(MV_PAR06) //Filtra o CONVENIO
  cQuery += " AND GCZ.GCZ_CODCON >= '" + MV_PAR06  + "'"
 EndIf    
 
 If !Empty(MV_PAR09) //Filtra o LOTE
  cQuery += " AND GCZ.GCZ_NRLOTE BETWEEN '" + MV_PAR08  + "' AND '" +  MV_PAR09 + "' "
 ElseIf !Empty(MV_PAR08) 
  cQuery += " AND GCZ.GCZ_NRLOTE >= '" + MV_PAR08  + "'"
 EndIf

 cQuery += " JOIN " + RetSqlName("GAT") + " GAT ON GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.D_E_L_E_T_ <> '*'" 
                                                      

 cQuery += " JOIN " + RetSqlName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GG7.GG7_CODPRE AND 	GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*'"
 IF !Empty(MV_PAR13) // FILTRA PRESTADOR
  cQuery += " AND GAZ_CODPRE BETWEEN '" + MV_PAR12  + "' AND '" +  MV_PAR13 + "'" 
 Else  
  cQuery += " AND GAZ_CODPRE >= '" + MV_PAR13 + "'" 
 EndIf

 cQuery += " JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL  = '" + xFilial("GA7") + "' AND GA7.GA7_CODPRO = GG7.GG7_CODDES	AND GA7.D_E_L_E_T_ <> '*'"
 cQuery += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_SEQDES = GG7.GG7_SEQGE7 AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cQuery += " LEFT JOIN " + RetSqlName("GF7") + " GF7 ON GF7.GF7_FILIAL = '" + xFilial("GF7") + "' AND GF7.GF7_SEQDES = GE7.GE7_SEQDES AND GF7.D_E_L_E_T_ <> '*'"
 cQuery += " LEFT JOIN " + RetSqlName("GE0") + " GE0 ON GE0.GE0_FILIAL = '" + xFilial("GE0") + "' AND GE0.GE0_NUMEXT = GF7.GF7_NREXTC AND GE0.D_E_L_E_T_ <> '*'"

 If MV_PAR17 == 1
  cQuery += " AND GE0.GE0_STATUS = '3'"
 ElseIf MV_PAR17 = 2 
  cQuery += " AND (GE0.GE0_STATUS IS NULL OR GE0.GE0_STATUS <> '3')"
 Endif
    
 cQuery += " LEFT JOIN " + RetSqlName("GDX") + " GDX ON GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.GDX_NREXTM = GG7.GG7_NREXTM AND GDX.D_E_L_E_T_ <> '*'"
 
 cQuery += " WHERE "
 cQuery += " GG7_FILIAL = '" + xFilial("GG7") + "' AND GG7.D_E_L_E_T_ <> '*' "
 cQuery += " AND (GF7.GF7_ORIDES IS NULL OR GF7.GF7_ORIDES <> '3') "

 If !Empty(MV_PAR02) //FILTRA MEDICO
  cQuery += " AND GG7.GG7_CODCRM BETWEEN '"  +  MV_PAR01 + "' AND '" +  MV_PAR02 + "'"
 Else   
  cQuery += " AND GG7.GG7_CODCRM >= '" + MV_PAR02 + "'"  
 EndIf

 
 If MV_PAR04 == 1
  cQuery += " AND GG7.GG7_PGTMED = '1'
 ElseIf MV_PAR04 == 2
  cQuery += " AND GG7.GG7_PGTMED IN ('0', '2', '3')
 Endif
  
 If !Empty(MV_PAR16) //FILTRA ATO MEDICO
  cQuery += " AND GG7.GG7_CODATO BETWEEN '"  +  MV_PAR15 + "' AND '" +  MV_PAR16 + "'"  
 Else 
  cQuery += " AND GG7.GG7_CODATO >= '" +  MV_PAR16 + "'"  
 EndIf
  
 
 cQuery += " ORDER BY CODPRE, CODCRM, CODPRO, TIPO, CODCON, CODPLA, DATDES, HORDES, SEQDES, SEQMOV DESC "
  
 
 cQuery := ChangeQuery(cQuery)
 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)
   

RETURN( NIL )                                                               

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ MONTACAB ∫ Autor ≥ MARCELO JOSE       ∫ Data ≥  23/11/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ CABECALHO                                                  ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GESTAO HOSPITALAR.                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
STATIC FUNCTION MONTACAB(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 9                                                    
 If lStart .And. cPrest == (cAliasQRY)->CODPRE .And. cMedico = (cAliasQRY)->CODCRM .And. cProced = (cAliasQRY)->CODPRO .And. cConVen = (cAliasQRY)->CODCON + (cAliasQRY)->CODPLA
  @nLin, 000 Psay STR0016 + ALLTRIM((cAliasQRY)->CODPRE) + " - " + (cAliasQRY)->FANPRE  //"Prestador(a):   "
  nLin := nLin+2		 
  @nLin, 000 Psay STR0017 + ALLTRIM((cAliasQRY)->CODCRM) + " - " + HS_IniPadR("SRA", 11, (cAliasQRY)->CODCRM, "RA_NOME",,.F.) //"Medico(a):      "
  nLin++   
  @nLin, 000 Psay IIF(SUBSTR(ALLTRIM((cAliasQRY)->ALIAS), LEN(ALLTRIM((cAliasQRY)->ALIAS)), 1) == "5", STR0045, IIF(SUBSTR(ALLTRIM((cAliasQRY)->ALIAS), ;
                      LEN(ALLTRIM((cAliasQRY)->ALIAS)), 1) == "6", STR0046, STR0018)) + ALLTRIM((cAliasQRY)->CODPRO) + " - " + ;
                      IIF(Empty((cAliasQRY)->DESPRO), HS_INIPADR("SB1",1, (cAliasQRY)->CODPRO, "B1_DESC",,.F.),(cAliasQRY)->DESPRO) //"Mat./Med.....:   "##"Tax./Diar....:   "##"Procedimento:   "
  nLin++   
  @nLin, 000 Psay STR0019 + ALLTRIM((cAliasQRY)->CODCON) + " - " + ALLTRIM((cAliasQRY)->CODPLA) + " - " + (cAliasQRY)->DESPLA // //"Convenio/Plano: "
  nLin := nLin + 2  
	Endif
 lStart := .T.
RETURN( NIL )

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ PROTOT   ∫ Autor ≥ MARCELO JOSE       ∫ Data ≥  07/11/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ PROCESSA TOTAIS DAS QUEBRAS                                ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GESTAO HOSPITALAR.                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
STATIC FUNCTION PROTOT(nQual, cAlias)
 If nQual == 1
  nLin++   
  @nLin, 101 Psay STR0035 + Transform(nSomaPre,"@E 999,999.99")  //"Total do Prestador --------> "
  @nLin, 143 Psay Transform(nGloPre,"@E 999,999.99")   
  @nLin, 156 Psay Transform(nRepPre,"@E 999,999.99")   
  @nLin, 170 Psay Transform(nVPgTPre,"@E 999,999.99")   
  @nLin, 184 Psay Transform(nVPagPre,"@E 999,999.99")   
  @nLin, 196 Psay Transform(nVRecPre,"@E 999,999.99")   
  @nLin, 210 Psay Transform(nVPerPre,"@E 999,999.99")   
  nSomaPre := 0 
  nGloPre  := 0
  nRepPre  := 0 
  nVPagPre := 0 
  nVRecPre := 0
  nVPerPre := 0   
  nVPgTPre := 0 
  cMedico := "Start"
  cProced := "Start"
  cConven := "Start"
 ElseIf nQual == 2
  nLin++    
  @nLin, 101 Psay STR0036 + Transform(nSomaMed,"@E 999,999.99")   //"Total do Medico -----------> "
  @nLin, 143 Psay Transform(nGloMed,"@E 999,999.99")   
  @nLin, 156 Psay Transform(nRepMed,"@E 999,999.99")     
  @nLin, 170 Psay Transform(nVPgTMed,"@E 999,999.99")   
  @nLin, 184 Psay Transform(nVPagMed,"@E 999,999.99")   
  @nLin, 196 Psay Transform(nVRecMed,"@E 999,999.99")   
  @nLin, 210 Psay Transform(nVPerMed,"@E 999,999.99")   
  nSomaMed := 0                 
  nGloMed  := 0
  nRepMed  := 0     
  nVPagMed := 0                 
  nVRecMed := 0
  nVPerMed := 0
  nVPgTMed := 0
  cProced := "Start"
  cConven := "Start"
 ElseIf nQual == 3
  nLin++ 
  @nLin, 101 Psay IIF(SUBSTR(ALLTRIM(cAlias), LEN(ALLTRIM(cAlias)), 1) == "5", STR0047, IIF(SUBSTR(ALLTRIM(cAlias), LEN(ALLTRIM(cAlias)), 1) == "6", STR0048, STR0037 ))+ Transform(nSomaPro,"@E 999,999.99")  //"Total de Mat./Med. --------> "##"Total de Tax./Diar.--------> "##"Total do Procedimento -----> "
  @nLin, 143 Psay Transform(nGloPro,"@E 999,999.99") 
  @nLin, 156 Psay Transform(nRepPro,"@E 999,999.99") 
  @nLin, 170 Psay Transform(nVPgTPro,"@E 999,999.99")   
  @nLin, 184 Psay Transform(nVPagPro,"@E 999,999.99")   
  @nLin, 196 Psay Transform(nVRecPro,"@E 999,999.99")   
  @nLin, 210 Psay Transform(nVPerPro,"@E 999,999.99")   
  nSomaPro := 0
  nGloPro  := 0                                                                      
  nRepPro  := 0     
  nVPagPro := 0
  nVRecPro := 0                                                                      
  nVPerPro := 0
  nVPgTPro := 0
  cConven := "Start"   
 ElseIf nQual == 4
  nLin++ 
  @nLin, 101 Psay STR0038 + Transform(nSomaCon,"@E 999,999.99")   //"Total do Convenio/Plano ---> "
  @nLin, 143 Psay Transform(nGloCon,"@E 999,999.99") 
  @nLin, 156 Psay Transform(nRepCon,"@E 999,999.99") 
  @nLin, 170 Psay Transform(nVPgTCon,"@E 999,999.99")   
  @nLin, 184 Psay Transform(nVPagCon,"@E 999,999.99")   
  @nLin, 196 Psay Transform(nVRecCon,"@E 999,999.99")   
  @nLin, 210 Psay Transform(nVPerCon,"@E 999,999.99") 
  nSomaCon := 0   
  nGloCon  := 0
  nRepCon  := 0                     
  nVPagCon := 0   
  nVRecCon := 0
  nVPerCon := 0   
  nVPgTCon := 0 
 EndIf
RETURN( NIL ) 

Static Function FS_RDBRB4(cPgtMed, cAlias)
 Local cDescr := ""
 If len(ALLTRIM(cAlias)) < 3
  If !Empty(cPgtMed)
   cDescr := SUBSTR(HS_RDescrB("GE7_PGTMED", cPgtMed),1,14)
  Else
   cDescr := STR0049 //"Sem Credencia."
  Endif
 Else 
  cDescr := STR0050 //"Repasse Pacote"
 Endif                    
Return(cDescr)
