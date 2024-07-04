#INCLUDE "ECOVC156.ch"
#include "AVERAGE.CH"
#include "AvPrint.ch"


#xTranslate :COURIER_10         => \[1\]
#xTranslate :COURIER_10_NEGRITO => \[2\]
#xTranslate :COURIER_12_NEGRITO => \[3\]

/*
Funcao      : ECOVC156
Objetivos   : Ajustar o relatório para a versão 811 - Release 4
Autor       : Juliano Paulino Alves - JPA
Data 	    : 21/08/2006
Obs         :
Revisão     :
*/
*******************
Function ECOVC156
*******************
lRet := ECOVC156R3(.T.)
RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funçao  ³ ECOVC156R3 ³ Autor ³ Luiz Claudio Barbosa ³ Data ³ 28.07.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Saldo dos Fornecedores                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observaçao³ Imprimir mesmo quando valor = zero                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*------------------------*
Function ECOVC156R3(p_R4)
*------------------------*
Local cAlias     := Alias()

Private cTipoMat := Space(AVSX3("EC2_LOTE",3)), lTop, nTotEC2, oProcess
Private cTit     := STR0001 //"Relat¢rio de Saldo dos Fornecedores"
Private cFilEC2 := xFilial("EC2")

//JPA - 21/08/2006 - Relatório Personalizavel - Release 4
Private oReport
Private oBreak
Private cUnid
Private lR4   := If(p_R4 == NIL,.F.,.T.) .AND. FindFunction("TRepInUse") .And. TRepInUse()

#IFDEF TOP
   lTop := .T.
#ENDIF

//Do While .T.
  
   nOpcA := 0
// DEFINE MSDIALOG oDlg TITLE cTit From 9,0 To 18,45 OF GetWndDefault()
      
//****   @ 2.0, 2.0  SAY "Esta rotina ir  emitir relat¢rio com"
//****   @ 3.0, 2.0  SAY "Saldo das mercadorias em transito"

// @ 3.0, 2.0 SAY "Tipo de material"

// @ 3.0, 10.0 MSGET cTipoMat PICTURE "@!" VALID VC156VALID() SIZE 15 ,08 OF oDlg

// DEFINE SBUTTON FROM 23,138 TYPE 6 ACTION (nOpcA := 1, oDlg:End()) ENABLE OF oDlg

// ACTIVATE MSDIALOG oDlg ON INIT ;
//          EnchoiceBar(oDlg,{||nOpcA := 1,oDlg:End()},;
//                           {||nOpcA := 0,oDlg:End()}) CENTERED
// If nOpcA == 1

   ContaReg()
   
   //Processa({||VC156GrvWork()},STR0002) //"Pesquisando Processos..."
   oProcess := MsNewProcess():New({|lEnd| VC156GrvWork(@lEnd) }, STR0026,STR0027,.T.) //"Contábil"###"Gerando Relatório"
   oProcess:Activate()
   
   /*
   If !(Work->(Eof())) .And. !(Work->(Bof()))
      Processa({||VCF156Imprime()},STR0002)//"Pesquisando Processos..."
   Else
      MsgStop(STR0003,STR0004)//"NÆo existem registros a serem impressos!!!"
   EndIf
   */
   // ElseIf nOpcA == 0
//    Exit
// EndIf
//EndDo
If Select("Work") > 0
   Work->(dbCloseArea())
EndIf

dbSelectArea(cAlias)
Return 
/*
*----------------------------*
Static Function VC156VALID()
*----------------------------*
Local lRet := .T., cValid := ""
SX3->(dbSetOrder(2))
If SX3->(dbSeek("EC2_LOTE"))
   If !Empty(SX3->X3_VALID)
      cValid := "("+AllTrim(SX3->X3_VALID)+")"
   EndIf
   If !Empty(SX3->X3_VLDUSER)
      cValid := If(!Empty(cValid), cValid+" .Or. ", "")+;
                        "("+AllTrim(SX3->X3_VLDUSER)+")"
   EndIf

   lRet := If(!Empty(cValid), &cValid, .T.)

EndIf
If !lRet
   Help(" ", 1, "EC2_LOTE") //LRL 22/01/2004 
EndIf
SX3->(dbSetOrder(1))
Return(lRet)
*/
*---------------------------------*
STATIC FUNCTION VC156GrvWork(lEnd)
*---------------------------------*
Local cFilECA := xFilial("ECA")
Local cFilEC2 := xFilial("EC2")
Local cFilEC7 := xFilial("EC7")
Local cFilEC5 := xFilial("EC5")
Local nValor  := 0,  lRet := .T.
LOCAL aWork_Stru := {{"WKCC"      ,"C", 10,0 } ,{"WKHAWB"    ,"C", AVSX3("W7_HAWB",AV_TAMANHO),0 },;
                     {"WKVALOR"   ,"N", 15,2 } ,{"WKLANCTO"  ,"D", 08,0 }}

cNomArq := "SALDO_CC"     // Saldo por unidade requisitante

If Select("Work") > 0
   Work->(dbCloseArea())
EndIf

cNomArq := E_CriaTrab(, aWork_Stru, "Work")

If NetErr()
   E_Msg(STR0005+cNomArq+STR0006,20) //"O arquivo "+cNomArq+".DBF esta em uso por outra esta‡Æo. Aguarde a libera‡Æo!!!"
   RETURN .F.
ENDIF
Work->(avzap())
IndRegua("Work",cNomArq+TEOrdBagExt(),"WKCC+WKHAWB+DTOS(WKLANCTO)", , ,STR0007)//"Processando Arquivo Temporario..."

SET INDEX TO (cNomArq+TEOrdBagExt())

cTit:=(STR0008)//"Saldos de mercadorias por unidade requisitante."

ECA->(dbSetOrder(2))
EC2->(dbSetOrder(2))
EC7->(dbSetOrder(2))
EC5->(dbSetOrder(1))

EC2->(dbSeek(xFilial("EC2")))
Work->(avzap())

oProcess:SetRegua1(2)
oProcess:IncRegua1(STR0028) //"Lendo Arquivos 1 / 2 Contábil"

oProcess:SetRegua2(nTotEC2)

DO WHILE !(EC2->(EOF())) .AND. EC2->EC2_FILIAL==cFilEC2
   
   If lEnd
      If lEnd:=MsgYesNo(STR0029, STR0030) //"Tem certeza que deseja cancelar?"###"Atenção"
         MS_FLUSH()
         Return .F.
      EndIf
   EndIf
   
   If EC2->EC2_TX_DI # 0
      EC2->(dbSkip())
      Loop
   EndIf

//VI   If !Empty(cTipoMat)
//VI      If cTipoMat != EC2->EC2_LOTE
//VI         EC2->(dbSkip())
//VI         Loop
//VI      EndIf
//VI   EndIf
   
   EC7->(DBSEEK(cFilEC7+EC2->EC2_HAWB+EC2->EC2_FORN+EC2->EC2_MOEDA+EC2->EC2_IDENTC))
   
   dLancto := CtoD("")
   nValor  := 0

   While !(EC7->(Eof())) .And. EC7->EC7_FILIAL+EC7->EC7_HAWB+EC7->EC7_FORN+EC7->EC7_MOEDA+EC7->EC7_IDENTC == ;
                               xFilial("EC7") +EC2->EC2_HAWB+EC2->EC2_FORN+EC2->EC2_MOEDA+EC2->EC2_IDENTC 
      // Verifica no EC5 se o ano e mes de encerramento estao preenchidos 
      EC5->(DBSEEK(cFilEC5+EC7->EC7_FORN+EC7->EC7_INVOIC+EC7->EC7_IDENTC))
      IF EC5->EC5_AMOS $ cSim
         EC7->(DBSKIP())
         LOOP
      ENDIF
      If EMPTY(EC5->EC5_VCFMES) .AND. EMPTY(EC5->EC5_VCFANO)                         
         If EC7->EC7_ID_CAM $ "101/501/504" 
            nValor += EC7->EC7_VALOR
            If EC7->EC7_ID_CAM == "101"
               dLancto := EC7->EC7_DT_LAN
            EndIf
         EndIf
      Endif
      EC7->(dbSkip())
   EndDo
   
   ECA->(DBSEEK(cFilECA+"IMPORT"+EC2->EC2_HAWB+EC2->EC2_IDENTC))   

   While !(ECA->(Eof())) .And. ECA->ECA_FILIAL+ECA->ECA_HAWB+ECA->ECA_IDENTC == ;
                               xFilial("ECA") +EC2->EC2_HAWB+EC2->EC2_IDENTC .AND. ;
                               ECA->ECA_TPMODU = "IMPORT"
                               
      IF ECA->ECA_MOEDA # EC2->EC2_MOEDA
         ECA->(DBSKIP())
         LOOP
      ENDIF   
      // Verifica no EC5 se o ano e mes de encerramento estao preenchidos 
      EC5->(DBSEEK(cFilEC5+ECA->ECA_FORN+ECA->ECA_INVOIC+ECA->ECA_IDENTC))
      IF EC5->EC5_AMOS $ cSim
         ECA->(DBSKIP())
         LOOP
      ENDIF
      If EMPTY(EC5->EC5_VCFMES) .AND. EMPTY(EC5->EC5_VCFANO)                                                  
         If ECA->ECA_ID_CAM $ "101/501/504" 
            nValor += ECA->ECA_VALOR
            If ECA->ECA_ID_CAM == "101"
               dLancto := ECA->ECA_DT_CON
            EndIf
         EndIf
      Endif
      ECA->(dbSkip())
   EndDo
   
   If nValor # 0
      Work->(DBAPPEND())
      Work->WKCC      := EC2->EC2_IDENTC 
      Work->WKHAWB    := EC2->EC2_HAWB
      Work->WKVALOR   := nValor
      Work->WKLANCTO  := dLancto
   EndIf
   
   oProcess:IncRegua2(STR0031+Alltrim(EC2->EC2_HAWB)) //"1 / 1 Processo "
   
   EC2->(dbSkip())
   
EndDo

ECA->(dbSetOrder(1))
EC2->(dbSetOrder(1))
EC7->(dbSetOrder(1))
EC5->(dbSetOrder(1))


IF (Work->(EOF()) .AND. Work->(BOF()))
   E_MSG(STR0010,1) // "N„o existe dados neste per¡odo."
   lRet := .F.
EndIf

If !(Work->(Eof())) .And. !(Work->(Bof()))
   //Processa({||VCF156Imprime()},STR0002)//"Pesquisando Processos..."
   VCF156Imprime(lEnd)
Else
   MsgStop(STR0003,STR0004)//"NÆo existem registros a serem impressos!!!"
EndIf
      
Return(lRet)

*-------------------------------*
STATIC Function VCF156Imprime()
*-------------------------------*
Local nTotal    := 0   , nTotGer := 0
Private cCC     := ""  , nLin
Private nColIni:= 00, nCol1 := 10, nCol2 := nCol1+30
Private nCol3:= nCol2+30, nColFim := 132
Private cMv_MesProc := TransForm(AllTrim(EasyGParam("MV_MESPROC")), "@R 99/9999")

Private cDesc1       := STR0036 //"Este programa tem como objetivo imprimir relatório de"
Private cDesc2       := STR0037 //"Saldo de Forncedpor em Transito"
Private cDesc3       := "", cPict := "", imprime := .T.
Private titulo       := STR0038 //"SALDO DE FORNCEDPOR EM TRANSITO"
Private Cabec1 :="",Cabec2 := ""
Private cString      := "EC2", CbTxt := ""
Private lAbortPrint  := .F., tamanho:= "P" , limite:= 132
Private nomeprog     := "ECOVC156", nTipo := 18
Private aReturn      :={ STR0039, 1,STR0040, 1, 1, 1, "",1 } //"Zebrado"###"Importacao"
Private nLastKey     := 0,  cbcont := 00
Private CONTFL       := 01, m_pag := 01, aOrd:={}
Private wnrel        := "ECOVC156" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cMoeda,cCusto,cForn,cNome, aDriver  := {}, nPag  := 0
nLin:= 80
cbtxt := Space(10)

If lR4     // JPA - 21/08/06
   oReport := ReportDef()
   oReport:PrintDialog()
   return .T.
Else
   wnrel :=SetPrint(cString,NomeProg,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.T.,Tamanho)
EndIf

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

Work->(dbGoTop())

oProcess:IncRegua1(STR0032) //"Lendo Arquivos 2 / 2 Gerando Relatório"

oProcess:SetRegua2(Work->(EasyRecCount()))

While !(Work->(Eof()))
   cCC := Work->WKCC
   ECC->(dbSeek(xFilial("ECC")+cCC))

   nTotal := 0
   lFirst := .T.
   While !(Work->(Eof())) .And. cCC == Work->WKCC

      If nLin > 69
         VCF156_CAB()
         lFirst := .T.
      EndIf      

      If lFirst
         @ nLin,nColIni Psay STR0013+AllTrim(cCC)+" - "+ECC->ECC_DESCR  // "Unid.Req.: "
         nLin++
         lFirst := .F.
      EndIf
      
      oProcess:IncRegua2(STR0031+Alltrim(Work->WKHAWB)+STR0033+Alltrim(Work->WKCC)) //"1 / 1 Processo "###" Unidade Requisitnate "
      
      @ nLin,nCol1 Psay Work->WKHAWB
      @ nLin,nCol2 Psay DtoC(Work->WKLANCTO)
      @ nLin,nCol3 Psay Trans(Work->WKVALOR, "@E 9999,999,999.99")

      nLin    ++
      nTotal  += Work->WKVALOR
      nTotGer += Work->WKVALOR

      Work->(dbSkip())
   EndDo

   nLin++
   @ nLin,nColIni Psay STR0014+AllTrim(cCC)+" "+ECC->ECC_DESCR
   @ nLin,nCol3 Psay Trans(nTotal, "@E 9999,999,999.99")
   nLin++
   @ nLin,nColIni PSay __PrtThinLine()
   nLin++


EndDo

If nLin > 59 //= 2900
      VCF156_CAB()
EndIf

nLin++ //=75
@ nLin,nColIni Psay STR0015   //"Total Geral: "
@ nLin,nCol3 Psay Trans(nTotGer, "@E 9999,999,999.99")

Set Printer To
Commit
Ourspool(wnrel)

MS_FLUSH()

Return

*---------------------*
PROCEDURE VCF156_CAB()
*---------------------*
LOCAL cTexto1:=STR0034 //"SALDO DE MERCADORIAS EM TRANSITO"

aDriver := ReadDriver()

@ 0,0 PSay &(aDriver[3])

nLin:= 1
nPag++

@ nLin,nColIni PSay __PrtThinLine()
nLin++

@ nLin,nColIni PSay ALLTRIM(SM0->M0_NOME)+" - "+ALLTRIM(SM0->M0_FILIAL)
@ nLin,nColFim-16 Psay STR0016 + STR(nPag,6)         //"Pagina:   "

nLin++
@ nLin,( (nColFim/2) - Round((Len(cTexto1)/2),0) ) PSay cTexto1
@ nLin,nColFim-16 Psay STR0018+DtoC(dDataBase)  // "Data..: "
nLin++

@ nLin,nColIni Psay STR0035 //'SIGAECO'
@ nLin,nColFim-16 Psay STR0019+Time() // "Hora..: "
nLin++
@ nLin,nColIni Psay __PrtThinLine()
nLin++

cMesProc := STR0020+cMv_MesProc+Space(10)+STR0021+If(Empty(cTipoMat),STR0022,cTipoMat) //"MÒS/ANO DE PROCESSAMENTO: " "TIPO DE MATERIAL: " "TODOS"
@ nLin,nColIni Psay cMesProc
nLin++

@ nLin,nCol1 Psay STR0023  // "PROCESSO"
@ nLin,nCol2 Psay STR0024  //"Dt.Lancto"
@ nLin,nCol3 Psay STR0025  // "SALDO ATUAL (R$)"

nLin++
@ nLin,nColIni PSay __PrtThinLine()
nLin++

Return

*---------------------------*
Static Function ContaReg()
*---------------------------*
Local cQueryEC2, cWhereEC2
Local cCondEC2:=   " AND EC2.D_E_L_E_T_ <> '*'"
Local cCondAsEC2:= " AND EC2.@DELETED@ <> '*'"

nTotEC7  := 0

IF lTop

  cAliasEC2   := "EC2TMP"

  // Where EC2
  cWhereEC2:= " EC2.EC2_FILIAL='"+ cFilEC2 +"' AND EC2.EC2_TX_DI= 0"
  cWhereEC2+= If(TcSrvType()<>"AS/400",cCondEC2,cCondAsEC2)
  cQueryEC2:= "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC2")+ " EC2 Where "+cWhereEC2
  
  // EC2
  cQueryEC2 := ChangeQuery(cQueryEC2)
  DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryEC2), cAliasEC2,.F.,.T.)
  
  If Select(cAliasEC2) > 0
     nTotEC2 := (cAliasEC2)->TOTALREG
     (cAliasEC2)->(DbCloseArea())
  Else
     nTotEC2 := 0
  Endif
Else
  // EC2
  EC2->(DbSeek(cFilEC2,.T.))
  EC2->(DBEVAL({||nTotEC2++, MsProcTxt("Processo "+EC2->EC2_HAWB)},,{||EC2->(!EOF()) .And. EC2->EC2_FILIAL = cFilEC2 .And. ;
               Empty(EC2->EC2_TX_DI) }))

Endif

Return .T.

//JPA - 21/08/2006 - Definições do relatório personalizável
****************************
Static Function ReportDef()
****************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"EC2"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("ECOVC156", STR0034 ,"", {|oReport| ReportPrint(oReport)}, STR0036 + " " + STR0037)

//Define os objetos com as seções do relatório
oSecao1 := TRSection():New(oReport,"Saldo por processo",aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
//TRCell():New(oSecao1,"WKCC"    , "Work", STR0021+If(Empty(cTipoMat),STR0022,cTipoMat), /*Picture*/       , 001 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKHAWB"  , "Work", STR0023                                    , /*Picture*/          , 017 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKLANCTO", "Work", STR0024                                    , /*Picture*/          , 008 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKVALOR" , "Work", STR0025                                    , "@E 9999,999,999.99" , 015 , /*lPixel*/, /*{|| code-block de impressao }*/)

oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText(STR0015)

oTotal:= TRFunction():New(oSecao1:Cell("WKVALOR"),NIL,"SUM",/*oBreak*/,"","@E 999,999,999.99",{|| Work->WKVALOR},.T.,.F.)
oTotal:SetTotalInLine(.F.)

//Imprime o cabeçalho na quebra de seção
oReport:Section("Saldo por processo"):SetHeaderBreak(.T.)

oReport:bOnPageBreak :={||ReportCab()}

oBreak := TRBreak():New(oReport:Section("Saldo por processo"),{||Work->WKCC}, "Total ", .F.)
          TRFunction():New(oReport:Section("Saldo por processo"):Cell("WKVALOR"),NIL,"SUM",oBreak,,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.)
          oBreak:bOnPrintTotal := {|| ReportTotal()}
          oBreak:bOnBreak := {|| Work->(dbSkip(-1)), ECC->(dbSeek(xFilial("ECC")+Work->WKCC)), cUnid:=Work->WKCC, oBreak:bTotalText := {|| "Total " + STR0013+AllTrim(cUnid)+" - "+ECC->ECC_DESCR}, Work->(dbSkip())}

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Saldo por processo")

ECC->(dbSetOrder(1))

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Saldo por processo"),"EC2",2,{|| xFilial("EC2")})

oReport:SetMeter(Work->(EasyRecCount()))
Work->(dbGoTop())

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Saldo por processo"):Init()

ReportTotal()
//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Saldo por processo"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Saldo por processo"):Finish()

Return .T.

****************************
Static Function ReportCab()
****************************
      
cMesProc := STR0020+cMv_MesProc+Space(10)+STR0021+If(Empty(cTipoMat),STR0022,cTipoMat) //"MÒS/ANO DE PROCESSAMENTO: " "TIPO DE MATERIAL: " "TODOS"
oReport:PrintText(cMesProc, /*oReport:nRow - 120, 10*/,)
oReport:FatLine()

return

*****************************
Static Function ReportTotal()
*****************************
Local lLastRec := .F.

Work->(dbSkip())

If Work->(EOF())
   lLastRec := .T.
EndIf

Work->(dbSkip(-1))
 
If !lLastRec
   ECC->(dbSeek(xFilial("ECC")+Work->WKCC))
   oReport:PrintText(STR0013+AllTrim(Work->WKCC)+" - "+ECC->ECC_DESCR,,)
EndIf
      
return