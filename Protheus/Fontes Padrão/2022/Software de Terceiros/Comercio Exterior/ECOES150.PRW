#include "EcoEs150.ch" 
#include "Average.ch"        
#include "AvPrint.ch"                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ ECOES150 ³ Autor ³ EMERSON    		³ Data ³ 13/11/01     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relatorio de Processos Estornados						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Manutenção feita por Thomaz(TAN)                                       ³±±
±±³Descrição ³Trocar a Tela por Pergunte(SX1) e colocar a Barra de Progresso±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ECOES150()

ECOES150R3(.T.)
Return .t.
*-------------------------*
Function ECOES150R3(p_R4)
*-------------------------*
LOCAL cAliasOld := Alias()
Private cFilECE := xFilial('ECE'), cFilECC:=xFilial('ECC'), cFilEC2:=xFiliaL('EC2'), cFilSA2 := xFilial('SA2')
Private dInicial:= AVCTOD("  /  /  "), dFinal  := AVCTOD("  /  /  "), nTotECE:=0
Private nOpcao:= 1, cProc   := SPACE(LEN(EC7->EC7_HAWB)), oProcess, lTop:= .F.
Private cNomArq, oCbx, cTipo:= "1", aTipo:={STR0024,STR0025} //"1-Importação"###"2-Exportação"
Private cCabec
Private cCabec1
Private cCabec2
Private cCabec3
Private cCabec4
Private cCont
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()

#IFDEF TOP
   lTop := .T.
#ENDIF

// Cria Work
CriaWork()


While .T.
   
   cProcAtual := Space(10)

   DBSelectArea("WORK")
   If !Pergunte("ECOES1",.T.)
      Work->(DbCloseArea())
      //MFR 18/12/2018 OSSME-1974
      Erase(cNomArq+TEORDBAGEXT())
      Return .F.
   EndIf
       
   dInicial := mv_par01
   dFinal   := mv_par02
   cTipo    := mv_par03
   cProc    := mv_par04

   If !E_PERIODO_OK(@dInicial,@dFinal)
      Loop
   Endif
If lR4
   //TRP - 18/08/2006 - Relatório Personalizavel - Release 4
   //ReportDef cria os objetos.
   oReport := ReportDef()
EndIf
   If nOpcao == 1
      IF Empty(ALLTRIM(cProc))
         ECE->(DBSEEK(cFilECE))
         IF EC5->(EOF())
            E_Msg(STR0005)  //"Nao Existem registros para estas condições!!!"
            Loop
         Endif
      Else
         If Str(cTipo,1) == "1"
            ECE->(dbSetOrder(1))
         Else
            ECE->(dbSetOrder(4))
         Endif
         ECE->(DBSEEK(cFilECE+cProc))
		 If ECE->(EOF())
            E_Msg(STR0006,1)  //"Nao Existem registros para este processo!!!"
            LOOP
         Endif
      Endif
      oProcess := MsNewProcess():New({|lEnd| GrvWork(@lEnd,If(Str(cTipo,1)=="1","I","E")) },STR0041,STR0040,.T.) //"Contábil"###"Gerando Relatório"
      oProcess:Activate()
   ElseIf nOpcao == 0
      //Work->(DbCloseArea())
      //Erase(cNomArq+TEORDBAGEXT())
      Exit
   EndIf

EndDo

Work->(DbCloseArea())
Erase(cNomArq+TEORDBAGEXT())

DbSelectArea(cAliasOld)

Return .T.

*---------------------------------*
Static Function GrvWork(lEnd,cMod)
*---------------------------------*
DbSelectArea("Work")
AvZap()

If cMod == "I"
   ECE->(dbSetOrder(1))
Else
   ECE->(dbSetOrder(4))
Endif

bWhile:={||ECE->ECE_FILIAL==cFilECE}
cChave:= cFilECE

If !Empty(cProc) .And. cMod == "I"
   bWhile:={||ECE->ECE_FILIAL+ECE->ECE_HAWB==cFilECE+cProc}
   cChave:= cFilECE+cProc
ElseIf !Empty(cProc) .And. cMod == "E"
   bWhile:={||ECE->ECE_FILIAL+ECE->ECE_PREEMB==cFilECE+cProc}
   cChave:= cFilECE+cProc
Endif

ECE->(dbSeek(cChave))

ES150ContaReg(cMod)

oProcess:SetRegua1(1)
oProcess:IncRegua1(STR0042) //"Gravando Work 1 / 2 Processos Estornados"

oProcess:SetRegua2(nTotECE)

Do WHILE !ECE->(EOF()) .AND. Eval(bWhile)
   
   If lEnd
      If lEnd:=MsgYesNo(STR0043, STR0044) //"Tem certeza que deseja cancelar?"###"Atenção"
         MS_FLUSH()
         Return .F.
      EndIf
   EndIf
   
   If cMod == "I" .And. Empty(ECE->ECE_HAWB)
      ECE->(dbSkip())
      Loop
   ElseIf cMod == "E" .And. Empty(ECE->ECE_PREEMB)
      ECE->(dbSkip())
      Loop      
   Endif   
   
   If (Empty(ECE->ECE_HAWB) .And. Empty(ECE->ECE_PREEMB)) .Or. (Empty(ECE->ECE_INVOIC) .And. Empty(ECE->ECE_INVEXP))
      ECE->(dbSkip())
      Loop
   Endif

   If !EMPTY(cProc) .And. cMod == "I"
      IF ECE->ECE_HAWB # cProc
         Exit
      ENDIF
   ElseIf !EMPTY(cProc) .And. cMod == "E"
      IF ECE->ECE_PREEMB # cProc
         Exit
      ENDIF
   Endif

   If !Empty(dInicial)
      If ECE->ECE_DT_EST < dInicial
         ECE->(DbSkip())
         Loop
      Endif
   Endif
   
   If !Empty(dFinal)
      If ECE->ECE_DT_EST > dFinal  
         ECE->(DbSkip())
   	     Loop
      Endif
   Endif

   oProcess:IncRegua2(STR0045+Alltrim(If(cMod == "I",ECE->ECE_HAWB, ECE->ECE_PREEMB))+STR0046+Alltrim(If(cMod == "I", ECE->ECE_INVOIC, ECE->ECE_INVEXP))) //"1 / 1 Processo "###" Inv: "

   // Grava na Work
   Work->(RecLock("Work",.T.))
   Work->WK_HAWB   := If(cMod=="I",ECE->ECE_HAWB,ECE->ECE_PREEMB)
   Work->WK_IDENTC := ECE->ECE_IDENTC
   Work->WK_FORN   := ECE->ECE_FORN
   Work->WK_INVOIC := If(cMod=="I",ECE->ECE_INVOIC, ECE->ECE_INVEXP)
   Work->WK_VALOR  := ECE->ECE_VALOR
   Work->WK_CTA_DB := ECE->ECE_CTA_DB
   Work->WK_CTA_CR := ECE->ECE_CTA_CR
   Work->WK_CDBEST := ECE->ECE_CDBEST
   Work->WK_CCREST := ECE->ECE_CCREST
   Work->WK_DT_LAN := ECE->ECE_DT_LAN
   Work->WK_DT_EST := ECE->ECE_DT_EST
   
   Work->(MsUnlock())
      
   ECE->(DBSKIP())

ENDDO

If(lR4, oReport:PrintDialog(),GeraRel(lEnd))

Return .T.

*--------------------------------*
Static Function GeraRel(lEnd)
*--------------------------------*
Local TB_Campos    := {}
Local aRCampos     := {}                  
Private lInvTrans  := .F.

If !Empty(dInicial) .And. !Empty(dFinal)
   cCont:= STR0027+DTOC(dInicial)+STR0028+DTOC(dFinal) //"Período de "###" até "
ElseIf !Empty(dInicial) .And. Empty(dFinal)
   cCont:= STR0029+DTOC(dInicial) //"Período - desde "
ElseIf Empty(dInicial) .And. !Empty(dFinal)
   cCont:= STR0030+DTOC(dFinal) //"Período - até "
Else
   cCont:= STR0031 //"Período de __/__/__ até __/__/__"
Endif

Private aDados := {"Work",;
                   STR0032,; //"Este programa tem como objetivo imprimir relatorio de acordo com os parametros informados pelo usuario."
                   STR0033,; //"Processos Estornados" 
                   "",;
                   "M",;
                   132,;
                   "",;
                   "",;
                   STR0034+cCont+Space(10)+STR0035+If(Str(cTipo,1)=="1",STR0036,STR0037),; //"Processos Estornados - "###"Tipo- "###"Importação"###"Exportação"
                   { STR0038, 1,STR0039, 1, 1, 1, "",1 },; //"Zebrado"###"Contabil"
                   "ECOES150",;
                   { {||ImpProcessos()} , {||.T. } }  }

AADD(TB_Campos,{{ ||Work->WK_INVOIC  }   								   ,"L" , STR0008    }) //"Invoice"
AADD(TB_Campos,{{ ||TRANSF(Work->WK_VALOR, '@E 999,999,999,999,999.99')}   ,"R" , STR0009    }) //"Valor"
AADD(TB_Campos,{{ ||Work->WK_CTA_DB  }                             	       ,"L" , STR0011    }) //"Cta.Efetuada DB"
AADD(TB_Campos,{{ ||Work->WK_CTA_CR  }                             		   ,"L" , STR0012    }) //"Cta.Efetuada CR"
AADD(TB_Campos,{{ ||Work->WK_CDBEST  }                             		   ,"L" , STR0013    }) //"Cta.Estornada DB"
AADD(TB_Campos,{{ ||Work->WK_CCREST  }                             		   ,"L" , STR0014    }) //"Cta.Estornada CR"
AADD(TB_Campos,{{ ||TRANSF(Work->WK_DT_LAN, "@E")}   	                   ,"L" , STR0015    }) //"Dt.Evento"
                 
aRCampos:= E_CriaRCampos(TB_CAMPOS)
IF Work->(EOF()) .AND. Work->(BOF())
   MsgInfo(STR0016)    //"Nao ha dados p/ serem listados !!!"
ELSE
   oProcess:IncRegua1(STR0047) //"Gerando Relatório 2 / 2 Processos Estornados"
   E_Report(aDados,aRCampos)
ENDIF

Return .T.

*----------------------------*
Static Function ImpProcessos()
*----------------------------*
If WORK->WK_HAWB+WORK->WK_IDENTC # cProcAtual
   PulaLinha()
   PulaLinha()
   @ Linha, 001 PSAY STR0017 + WORK->WK_HAWB  //"Processo.: "
   @ Linha, 030 PSAY STR0018 +  WORK->WK_IDENTC + " " + ; //"Unid.Requisitante.: "
   IF( ECC->(DbSeek(cFilECC+WORK->WK_IDENTC)), LEFT(ECC->ECC_DESCR,15), Space(10))
   @ Linha, 095	PSAY	STR0019 + Transform(WORK->WK_DT_EST,"@E")  //"Data Estorno.: "
   PulaLinha()                                                                     
   PulaLinha()
   @ Linha, 001 PSAY STR0023 + WORK->WK_FORN + " " + ; //"Fornecedor.: "
   IF( SA2->(DbSeek(cFilSA2+WORK->WK_FORN)), SA2->A2_NREDUZ, Space(10))
   PulaLinha()             
      
   cProcAtual := WORK->WK_HAWB+WORK->WK_IDENTC
Endif
                     
RETURN .T.
*--------------------------*                 
Static Function PulaLinha()           
*--------------------------*
IF Linha > 55
   Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))   
   Linha := 10
Else
   Linha++
Endif   

Return .T.

*--------------------------*
Static Function CriaWork()
*--------------------------*
Private aHeader[0],aCampos := {}
PRIVATE aEstru := {}
   
// Cria Work
AADD(aEstru,{ "WK_HAWB"      , "C" , AVSX3("W7_HAWB",AV_TAMANHO), 0  })
AADD(aEstru,{ "WK_IDENTC"    , "C" , 15, 0  })
AADD(aEstru,{ "WK_FORN"      , "C" , 06, 0  })
AADD(aEstru,{ "WK_INVOIC"    , "C" , AVSX3("W7_INVOICE",AV_TAMANHO), 0  })   
AADD(aEstru,{ "WK_VALOR"     , "N" , 15, 2  }) 
AADD(aEstru,{ "WK_CTA_DB"    , "C" , 15, 0  }) 
AADD(aEstru,{ "WK_CTA_CR"    , "C" , 15, 0  }) 
AADD(aEstru,{ "WK_CDBEST"    , "C" , 15, 0  }) 
AADD(aEstru,{ "WK_CCREST"    , "C" , 15, 0  }) 
AADD(aEstru,{ "WK_DT_LAN"    , "D" , 08, 0  }) 
AADD(aEstru,{ "WK_DT_EST"    , "D" , 08, 0  }) 

cNomArq:=E_CriaTrab(,aEstru,"Work")
//MFR 18/12/2018 OSSME-1974
IndRegua("Work",cNomArq+TEORDBAGEXT(),"WK_HAWB+WK_IDENTC+WK_INVOIC")

Return .T.

/*
*--------------------------------*
Function VALESTORNO(cVal)
*--------------------------------*
If cVal == "2"  .And. Str(cTipo) == "2"
   If(lExisInd, ECE->(dbSetOrder(4)),  ) //Para o Processo de Exportação(PREEMB)
   If !EMPTY(mv_par04) .AND. !ECE->(DBSEEK(cFilECE+mv_par04))
      E_Msg(STR0020,1)  //"Processo Nao Estornado !!!"
      Return .F.
   Endif
Endif

If cVal == '2' .And. Str(cTipo) == "1"
   ECE->(dbSetOrder(1)) //Para o Processo de Importação(HAWB)
   IF !EMPTY(mv_par04) .AND. !ECE->(DBSEEK(cFilECE+mv_par04))
      E_Msg(STR0020,1)  //"Processo Nao Estornado !!!"
      Return .F.
   ENDIF
EndIf


If cVal == 'OK'
   IF !Empty(dInicial) .And. !Empty(dFinal)
      If DTOS(dFinal) < DTOS(dInicial)
         E_Msg(STR0021,1)  //"Data final menor que a data inicial."
         Return .F.
      Endif
      If DTOS(dInicial) > DTOS(dFinal)
         E_Msg(STR0022,1)  //"Data Inicial maior que a data final."
         Return .F.
      Endif
   ENDIF  
EndIf
Return .T.
*/

*----------------------------------*
Static Function ES150ContaReg(cMod)
*----------------------------------*
Local cQueryECE, cWhereECE, cAliasECE
Local cCondECE:=" AND ECE.D_E_L_E_T_ <> '*' ",  cCondAsECE:= " AND ECE.@DELETED@ <> '*' "

nTotECE:= 0

IF lTop

  cAliasECE    := "ECETMP"

  // Where ECE
  cWhereECE:= " ECE.ECE_FILIAL='"+ cFilECE +"' AND ECE.ECE_DT_EST <= '"+DTOS(dFinal)+"' AND ECE.ECE_DT_EST >= '"+DTOS(dInicial)+"' "
  If !Empty(cProc)
     If cMod == "I"
        cWhereECE+=" AND ECE.ECE_HAWB = '"+cProc+"' "
     Else
        cWhereECE+=" AND ECE.ECE_PREEMB = '"+cProc+"' "
     Endif
  Endif
  If cMod == "I"
     cWhereECE+=" AND (ECE.ECE_HAWB <> '' OR ECE.ECE_HAWB <> ' ') "
  Else
     cWhereECE+=" AND (ECE.ECE_PREEMB <> '' OR ECE.ECE_PREEMB <> ' ') "
  Endif
  
  cWhereECE+= If(TcSrvType()<>"AS/400",cCondECE,cCondAsECE)

  // Query ECE
  cQueryECE    := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECE")+ " ECE WHERE "+cWhereECE
  
  cQueryECE := ChangeQuery(cQueryECE)
  DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryECE), cAliasECE,.F.,.T.)
  
  If Select(cAliasECE) > 0
     nTotECE := (cAliasECE)->TOTALREG
     (cAliasECE)->(DbCloseArea())
  Else
     nTotECE := 0
  Endif
Else

  // ECE
  ECE->(DbSeek(cFilECE,.T.))
  ECE->(DBEVAL({||nTotECE++, MsProcTxt("Lendo Invoice "+If(cMod=="I",ECE->ECE_INVOIC, ECE->ECE_INVEXP))},,{||ECE->(!EOF()) .And. ECE->ECE_FILIAL == cFilECE .And. ;
               ECE->ECE_DT_EST >= DTOS(dInicial) .And. ECE->ECE_DT_EST <= DTOS(dFinal) .And. If(!Empty(cProc), If(cMod=="I", ECE->ECE_HAWB == cProc, ECE->ECE_PREEMB == cProc), .T. )})) //"Lendo Invoice "

Endif

Return .T. 


//TRP - 18/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
//Local cCont:=""
Local cTit:=""
cCabec1:="Work->WK_HAWB+Space(10)"
cCabec2:="Work->WK_IDENTC+Space(75)"
cCabec3:="Work->WK_DT_EST"
cCabec4:="Work->WK_FORN"

If !Empty(dInicial) .And. !Empty(dFinal)
   cCont:= STR0027+DTOC(dInicial)+STR0028+DTOC(dFinal) //"Período de "###" até "
ElseIf !Empty(dInicial) .And. Empty(dFinal)
   cCont:= STR0029+DTOC(dInicial) //"Período - desde "
ElseIf Empty(dInicial) .And. !Empty(dFinal)
   cCont:= STR0030+DTOC(dFinal) //"Período - até "
Else
   cCont:= STR0031 //"Período de __/__/__ até __/__/__"
Endif

cTit:=STR0034+cCont+Space(10)+STR0035+If(Str(cTipo,1)=="1",STR0036,STR0037)

//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"ECE"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("ECOES150",cTit,"ECOES1",{|oReport| ReportPrint(oReport)},STR0032+ " " +STR0033)

// Define o relatorio como Landscape Nick 20/10/06
oReport:opage:llandscape := .T.
oReport:opage:lportrait := .F.

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Invoices",aTabelas,aOrdem)

//Define o objeto com a seção do relatório
oSecao2 := TRSection():New(oReport,"Quebra",aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"WK_INVOIC"       ,"Work",   STR0008      ,/*Picture*/                   ,15         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_VALOR"        ,"Work",   STR0009      ,'@E 999,999,999,999,999.99'   ,15         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_CTA_DB"       ,"Work",   STR0011      ,/*Picture*/                   ,15         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_CTA_CR"       ,"Work",   STR0012      ,/*Picture*/                   ,15         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_CDBEST"       ,"Work",   STR0013      ,/*Picture*/                   ,15         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_CCREST"       ,"Work",   STR0014      ,/*Picture*/                   ,15         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WK_DT_LAN"       ,"Work",   STR0015      ,"@E"                          ,08         ,/*lPixel*/,/*{|| code-block de impressao }*/) 

oReport:Section("Invoices"):Cell("WK_CTA_DB"    ):SetColSpace(5)
oReport:Section("Invoices"):Cell("WK_CTA_CR"    ):SetColSpace(5)
oReport:Section("Invoices"):Cell("WK_CDBEST"    ):SetColSpace(5)
oReport:Section("Invoices"):Cell("WK_CCREST"    ):SetColSpace(5)

//Definição das colunas de impressão da seção 2
TRCell():New(oSecao2,  "Titulo"          ,"",       ""           ,/*Picture*/                   ,180        ,/*lPixel*/,{||cCabec})
//TRCell():New(oSecao2,"WK_IDENTC"       ,"Work",   STR0018      ,/*Picture*/                   ,15         ,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSecao2,"WK_FORN"         ,"Work",   STR0023      ,/*Picture*/                   ,06         ,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSecao2,"WK_DT_EST"       ,"Work",   STR0019      ,/*Picture*/                   ,08         ,/*lPixel*/,/*{|| code-block de impressao }*/)

//oReport:Section("Seção 2"):Cell("Titulo"):SetCellBreak()

//oReport:Section("Seção 1"):SetPageBreak(.T.)

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.

TRPosition():New(oReport:Section("Invoices"),"ECE",1,{|| xFilial("ECE") + cProc})

//oSection:Print()
oReport:SetMeter(Work->(EasyRecCount()))
Work->( dbGoTop() )

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Invoices"):Init()

//Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Quebra"):Init()

//Para desabilitar a impressão da página de parâmetros do pergunte
//oReport:oParamPage:Disable()

//Laço principal
cProc:=""
Do While Work->(!EoF()) .And. !oReport:Cancel()
   If cProc<>Work->WK_HAWB
      AltCabec()
   Endif
   oReport:Section("Invoices"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   cProc:=Work->WK_HAWB
   Work->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Invoices"):Finish()
//Fim da impressão da seção 2
oReport:Section("Quebra"):Finish() 

Return .T.




//TRP - 23/08/2006
Static Function AltCabec()
//Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
//oReport:Section("Seção 2"):Init()

cCabec:=STR0017+&cCabec1+STR0018+&cCabec2+STR0019+DtoC(&cCabec3)
oReport:Section("Quebra"):PrintLine()
cCabec:=STR0023+&cCabec4
oReport:Section("Quebra"):PrintLine()
oReport:FatLine()

//Fim da impressão da seção 2
//oReport:Section("Seção 2"):Finish() 
Return .t. 
