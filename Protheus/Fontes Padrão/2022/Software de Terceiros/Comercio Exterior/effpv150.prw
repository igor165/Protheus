#INCLUDE "EFFPV150.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AVERAGE.CH"

#Define EXP "E"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Função    ³ EFFPV150  ³ Autor ³ Alexandre Caetano Sciancalepre Jr³ Data ³ 14/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Descrição ³ Relatório de pré-vinculação                                             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³ Uso      ³ Financiamento                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                                       
FUNCTION EFFPV150()
//---------------------------------------------------------------------------------------
Local lCancel
Local cAlias := Alias()
Private lTop                               
Private cFilSA6  := xFilial("SA6")
Private cFilSX5  := xFilial("SX5")
Private cFilEF1  := xFilial("EF1")
Private cFilEF5  := xFilial("EF5")
Private cFilEF6  := xFilial("EF6")
                                                                         
Private lLin    := 99

//** PLB 18/11/06
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0
Private lCadFin := ChkFile("EF7")  .And.  ChkFile("EF8")
If lEFFTpMod  // Utilizadas na Consulta Padrão 'EFA'
   Private lEvCont      := .F.
   Private cFiltroF3Fin := EXP
EndIf
If lCadFin
   Private cFilEF7 := xFilial("EF7")
EndIf
//**

#IFDEF TOP
  lTop := .T.
#ElSE
  lTop := .F.
#ENDIF               

//PV150AcDic()

DO WHILE .T.         
   DBSelectArea(cAlias)
   Private cFiliais := "'"            
   Private cNomArq  := ""             
   Private aFiliais := AvgSelectFil(.T.,"EF1") 
   Private lVerOut  := Posicione("SX2",1,"EF1","X2_MODO") == "E" .AND. VerSenha(115) // Indica se o usuário pode ver outras filiais.
   aEval( aFiliais,{|x,y| cFiliais += x + iIF(y == Len(aFiliais),"'","','")} )
   If aFiliais[1]=="WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
      Exit
   Else
      IF ! PERGUNTE("EFFPV1",.T.)
         EXIT
      ENDIF    
   
      cContrato := MV_PAR01
      cBanco    := MV_PAR02
      cPraca    := MV_PAR03
      If lEFFTpMod
         cSeqCnt  := MV_PAR04
         cTpFin   := MV_PAR05
         cInvoice := MV_PAR06
         nTipImp  := MV_PAR07
      Else
         cTpFin    := MV_PAR04
         cInvoice  := MV_PAR05
         nTipImp   := MV_PAR06
      EndIf
   
      Processa( {|| Iif(lTop, PV150Query(), PV150Dbf() ) },STR0017) // "Pesquisando dados de Pre-Vinculacao"
   
      If TRAB->(Bof()) .and. TRAB->(Eof())
         MsgStop(STR0018) // "Não existem dados para a impressão"
      Else
         If nTipImp == 1
            //Impressão
            PV150PRINT()
         ElseIf nTipImp == 2
            //Em Arquivo                
            RptStatus({|lCancel| PV150ArqEx(.F.)})
         Else
            //Excel
            RptStatus({|lCancel| PV150ArqEx(.T.)})
         Endif      
      Endif
   
      if Select("ARQ") > 0
         ARQ->(E_EraseArq(cNomArq))  
      Endif
   
      If Select("TRAB") > 0
         if .not. lTop
            TRAB->(E_EraseArq(cNomArq))  
         Else
           TRAB->(DBCloseArea())
         Endif
      Endif           
   ENDIF  
ENDDO

If Select("TRAB") > 0 
   if lTop
      TRAB->(E_EraseArq(cNomArq))  
   Else
     TRAB->(DBCloseArea())
   Endif
Endif
                                              
RETURN .T.                                    

// ******************************************|
// FUNÇÃO PV150DBF                           |
// Gera dados para Codebase                  |
// ------------------------------------------|
// Alexandre Caetano Sciancalepre Jr. (ACSJ) |
// 14 de Fevereiro de 2005                   |
// ------------------------------------------|
FUNCTION PV150DBF()
// ******************************************|
Local i

PV150CrArq("TRAB")

If .not. Empty(cContrato)                                                
   EF6->(DBSeek(cFilEF6+cContrato))
   bWhile := {|| EF6->EF6_FILIAL == aFiliais[i] .and. EF6->CONTRATO == cContrato .and. .not. EF6->(Eof())}
Else
   EF6->(DBSeek(cFilEF6))
   bWhile := {|| EF6->EF6_FILIAL == aFiliais[i] .and. .not. EF6->(Eof())}
Endif

For i:= 1 to Len(aFiliais)

   Do While Eval(bWhile)
   
      If EF6->EF6_BANCO == cBanco .or. Empty(cBanco)
         If EF6->EF6_PRACA == cPraca .or. Empty(cPraca)
            If IIF(lEFFTpMod,EF6->EF6_SEQCNT == cSeqCnt .or. Empty(cSeqCnt),.T.)  // PLB 18/12/06
               If EF6->EF6_TP_FIN == cTpFin .or. Empty(cTpFin)
                  If EF6->EF6_NRINVO == cInvoice .or. Empty(cInvoice)
                 
                     EF1->(DBSetOrder(1)) 
                     If lEFFTpMod  // PLB 18/12/06
                        EF1->(DBSeek( aFiliais[i] + EF6->EF6_CONTRA + EF6->EF6_BANCO + EF6->EF6_PRACA ))
                     Else
                        EF1->(DBSeek( aFiliais[i] + EXP + EF6->EF6_CONTRA + EF6->EF6_BANCO + EF6->EF6_PRACA + EF6->EF6_SEQCNT ))
                     EndIf
               
                     TRAB->(DBAppend())
                     TRAB->EF6_CONTRA := EF6->EF6_CONTRA
                     TRAB->EF6_BANCO  := EF6->EF6_BANCO
                     TRAB->EF6_PRACA  := EF6->EF6_PRACA
                     If lEFFTpMod  // PLB 18/12/06
                        TRAB->EF6_SEQCNT := EF6->EF6_SEQCNT
                     EndIf
                     TRAB->EF6_TP_FIN := EF6->EF6_TP_FIN
                     TRAB->EF1_SLD_PM := EF1->EF1_SLD_PM
                     TRAB->EF6_NRINVO:= EF6->EF6_NRINVO
                     TRAB->EF6_DTEMBA := EF6->EF6_DTEMBA
                     TRAB->EF6_VL_INV := EF6->EF6_VL_VIN
                     TRAB->EF6_MOEDA  := EF6->EF6_MOEDA              
                     TRAB->EF1_MOEDA  := EF1->EF1_MOEDA 
                     TRAB->EF6_FILIAL := EF6->EF6_FILIAL
               
                     If EasyEntryPoint("EFFPV150")
                        ExecBlock("EFFPV150", .F., .F.,"GRAVACODEBASE")
                     Endif   
                                    
                     TRAB->(DBCommit())
               
                  Endif
               Endif
            EndIf
         Endif
      Endif
      EF6->(DBSkip())
   Enddo   
Next

IndRegua("TRAB",cNomArq+TEOrdBagExt(),"EF6_FILIAL+EF6_CONTRA+EF6_BANCO+EF6_PRACA"+IIF(lEFFTpMod,"+EF6_SEQCNT",""))
   
Return .t.
// ******************************************|
// FUNÇÃO PV150QUERY                         |
// Gera dados para Top                       |
// ------------------------------------------|
// Alexandre Caetano Sciancalepre Jr. (ACSJ) |
// 14 de Fevereiro de 2005                   |
// ------------------------------------------|
FUNCTION PV150QUERY
// ******************************************|
Local cDel1 := Iif( TcSrvType() <> "AS/400", "EF6.D_E_L_E_T_ <> '*'", "")
Local cDel2 := Iif( TcSrvType() <> "AS/400", "EF1.D_E_L_E_T_ <> '*'", "")
Local cWhere := ""
Local cFrom  := ""
Private cQuery := ""

cQuery := "Select EF6.EF6_CONTRA, EF6.EF6_BANCO, EF6.EF6_PRACA, "
If lEFFTpMod  // PLB 18/12/06
   cQuery += "EF6.EF6_SEQCNT, "
EndIf
cQuery += "EF6.EF6_TP_FIN, EF1.EF1_SLD_PM, "
cQuery += "EF6.EF6_NRINVO, EF6.EF6_DTEMBA, EF6.EF6_VL_VIN, EF6.EF6_VL_INV, EF6.EF6_MOEDA, EF1.EF1_MOEDA, "
cQuery += "EF6.EF6_FILIAL "

If EasyEntryPoint("EFFPV150")
   ExecBlock("EFFPV150", .F., .F.,"GRAVAQUERY")
Endif   

cFrom  := "From " + RetSqlName("EF6") + " EF6, " + RetSqlName("EF1") + " EF1 "

cWhere := "Where " + cDel1 + " and EF6.EF6_FILIAL IN (" + cFiliais  + ")"
if .not. Empty(cContrato)
   cWhere += "and EF6.EF6_CONTRA = '" + cContrato + "' " 
Endif
if .not. Empty(cBanco)
   cWhere += "and EF6.EF6_BANCO = '" + cBanco + "' "
Endif                                 
if .not. Empty(cPraca)
   cWhere += "and EF6.EF6_PRACA = '" + cPraca + "' "
Endif
If lEFFTpMod  .And.  !Empty(cSeqCnt)  // PLB 18/12/06
   cWhere += "and EF6.EF6_SEQCNT = '" + cSeqCnt + "' "
EndIf
If .not. Empty(cTpFin)
   cWhere += "and EF6.EF6_TP_FIN = '" + cTpFin + "' "
Endif                                    
If .not. Empty(cInvoice)
   cWhere += "and EF6.EF6_NRINVO = '" + cInvoice + "' "
Endif   
cWhere += "and EF1.EF1_CONTRA = EF6.EF6_CONTRA "
cWhere += "and EF1.EF1_BAN_FI = EF6.EF6_BANCO and EF1.EF1_PRACA = EF6.EF6_PRACA "
If lEFFTpMod  //  PLB 18/12/06
   cWhere += "and EF1.EF1_SEQCNT = EF6.EF6_SEQCNT "
EndIf
cWhere += "and " + cDel2 + " and  EF1.EF1_FILIAL IN (" + cFiliais  + ")"

cQuery += cFrom + cWhere + "Order By EF6.EF6_FILIAL,EF6.EF6_CONTRA,EF6.EF6_BANCO,EF6.EF6_PRACA"+IIF(lEFFTpMod,",EF6.EF6_SEQCNT","") // PLB 18/12/06

cQuery := ChangeQuery( cQuery )

TcQuery cQuery ALIAS "TRAB" NEW
TcSetField("TRAB","EF6_DTEMBA","D")

Return .t.
// ******************************************|
// FUNÇÃO PV150PRINT                         |
// Inicia SetPrint                           |
// ------------------------------------------|
// Alexandre Caetano Sciancalepre Jr. (ACSJ) |
// 14 de Fevereiro de 2005                   |
// ------------------------------------------|
FUNCTION PV150PRINT()
// ******************************************|
LOCAL cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
LOCAL cDesc2         := STR0002 //"Pre-Vinculacao"
LOCAL cDesc3         := "", cPict := "", imprime := .T.
PRIVATE titulo       := STR0003 //"Relatorio Pre-Vinculacao"
PRIVATE nLin         := 80, Cabec1 := ""
PRIVATE cString      := "EF6", lEnd := .F.
PRIVATE lAbortPrint  := .F., limite := 220, tamanho := "220"
PRIVATE nomeprog     := "EFFPV150", nTipo := 18
PRIVATE aReturn      := {STR0004 , 1, STR0005, 2, 2, 1, "", 1}  //"Zebrado" ### "Administracao"
PRIVATE nLastKey     := 0, cbtxt := Space(10), cbcont := 00
PRIVATE CONTFL       := 01, m_pag := 01
PRIVATE wnrel        := "EFFPV150" // Coloque aqui o nome do arquivo usado para impressao em disco

wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)
                  
RptStatus({|lEnd| PV150Impr(wnRel,cString)})

Return .t.
// *********************************************|
// FUNÇÃO PV150IMPR                             |
// 1 - Impressao do Relatório                   |
// ---------------------------------------------|
// Alexandre Caetano Sciancalepre Jr. (ACSJ)    |
// 14 de Fevereiro de 2005                      |
// ---------------------------------------------|
FUNCTION PV150IMPR()
// *********************************************|       
                                                                                                                                               
//           1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        220       232
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
// Invoice                     Embarque        Moeda        Valor na moeda            Valor vinculado ao contrato
// Contrato: xxxxxxxxxxxxxxx   Moeda do Contrato: XXX   Banco: xxx-xxxxxxxxxxxxxxx   Praça: xxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   Tipo: xxx-xxxxxxxxxxxxxxxxxxxx   Saldo do Principal sem Pré-vinculação: 999,999,999,999.99
// Xxxxxxxxxxxxxxxxxxxx        xx/xx/xx         XXX         999,999,999,999.99        999,999,999,999.99                 xxxxxxxxxxxxxxxxxxx

Local nTotVinc   := 0
Local nPrincipal := 0
Local cContra    := ""
Local cBanco     := ""
Local cPraca     := ""
Local cSeqCnt    := ""  // PLB 18/12/06
Local cFilQb     := ""
Local lEntra     := .t.
Local nCol       := 00  // PLB 18/12/06

if nLin > 60
   PV150Cabec()
Endif            

TRAB->(DBGoTop())

Do While .not. TRAB->(Eof())
  
   if lEntra
   
      SA6->(DBSetOrder(1))
      SA6->(DBSeek(cFilSA6+TRAB->EF6_BANCO))  
      EF5->(DBSetOrder(1))
      EF5->(DBSeek(cFilEF5+TRAB->EF6_PRACA))
      If lCadFin  // PLB 18/12/06
         EF7->( DBSetOrder(1) )
         EF7->( DBSeek(cFilEF7+TRAB->EF6_TP_FIN) )
      Else
         SX5->(DBSetOrder(1))
         SX5->(DBSeek(cFilSX5+"CG"+TRAB->EF6_TP_Fin))
      EndIf
      
      if lVerOut
         @nLin++, 000 PSay Replicate("*",229)
         @nLin++, 002 PSay STR0006 + AvgFilName({TRAB->EF6_FILIAL},.t.)[1] // "FILIAL "
         @nLin++, 000 PSay Replicate("*",229)
      Endif
 
      nCol := 000
      @nLin,   nCol PSay STR0007 + TRAB->EF6_CONTRA // "Contrato: "
      nCol += 28
      @nLin,   nCol PSay STR0008 + TRAB->EF1_MOEDA // "Moeda do Contrato: "
      nCol += 25
      @nLin,   nCol PSay STR0009 + TRAB->EF6_BANCO + "-" + SA6->A6_NREDUZ // "Banco: "
      nCol += 29
      @nLin,   nCol PSay STR0010 + TRAB->EF6_PRACA + "-" + EF5->EF5_DESCRI // "Praca: "
      nCol += 31
      If lEFFTpMod  // PLB 18/12/06
         @nLin,   nCol PSay STR0019 + TRAB->EF6_SEQCNT  //"Sequencia: "
         nCol += 16
      EndIf
      @nLin,   nCol PSay STR0011 + TRAB->EF6_TP_Fin + "-" + Substr(IIF(lCadFin,EF7->EF7_DESCRI,SX5->X5_DESCRI),1,20) // "Tipo:  "
      nCol += 33
      @nLin,   nCol PSay STR0012 + Transform(TRAB->EF1_SLD_PM, AVSX3("EF1_SLD_PM",6)) // "Saldo do Principal sem Pré-vinculação: "
      
      nLin++
      lEntra     := .f.
      cContra    := TRAB->EF6_CONTRA
      cBanco     := TRAB->EF6_BANCO
      cPraca     := TRAB->EF6_PRACA
      If lEFFTpMod  // PLB 18/12/06
         cSeqCnt := TRAB->EF6_SEQCNT
      EndIf
      nPrincipal := TRAB->EF1_SLD_PM      
            
   Endif
     
   @nLin, 000 PSay TRAB->EF6_NRINVO
   @nLin, 028 PSay TRAB->EF6_DTEMBA
   @nLin, 044 PSay TRAB->EF6_MOEDA
   @nLin, 057 PSay Transform(TRAB->EF6_VL_INV, AVSX3("EF6_VL_INV", 6))
   @nLin, 083 PSay Transform(TRAB->EF6_VL_VINV,AVSX3("EF6_VL_VINV",6))
   
   If EasyEntryPoint("EFFPV150")
      ExecBlock("EFFPV150", .F., .F.,"IMPRESSAODET")
   Endif   
   
   nTotVinc += TRAB->EF6_VL_VINV
   
   nLin++   
   TRAB->(DBSkip())
   if cFilQb <> TRAB->EF6_FILIAL .and. cContra <> TRAB->EF6_CONTRA .or. cBanco <> TRAB->EF6_BANCO .or. cPraca <> TRAB->EF6_Praca  .Or.  IIF(lEFFTpMod,cSeqCnt <> TRAB->EF6_SEQCNT,.F.)
      lEntra := .t.                                                                     
      
      nLin++
      
      @nLin,061 PSay STR0013 + Transform(nTotVinc,"@E 999,999,999,999.99")  // "Total Pre-Vinculacao: "
      @nLin,189 PSay STR0014 + Transform( (nPrincipal-nTotVinc),"@E 999,999,999,999.99" ) // "Saldo Atual: "
      
      nTotVinc    := 0
      nPrincipal  := 0
                                                                                                 
      nLin+=3           
   Endif
   
Enddo

Set Printer To
OurSpool(wnrel)

MS_FLUSH()
 
Return .t.
// *********************************************|
// FUNÇÃO PV150CABEC                            |
// 1 - Impressao do cabeçalho                   |
// ---------------------------------------------|
// Alexandre Caetano Sciancalepre Jr. (ACSJ)    |
// 16 de Fevereiro de 2005                      |
// ---------------------------------------------|
FUNCTION PV150Cabec()                          
// *********************************************|
Cabec("Pre-Vinculacoes","SigaEFF","","EFFPV150","G",18)                                                                                    
 //                    1         2         3         4         5         6         7         8         9         0         1         2         3
//           0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
@08,000 PSay STR0015 // "Invoice                     Embarque        Moeda        Valor na moeda            Valor Vinculado ao Contrato"

If EasyEntryPoint("EFFPV150")
   ExecBlock("EFFPV150", .F., .F.,"IMPRESSAOCABEC")
Endif                                            

@09,000 PSay Replicate("-",229)
nLin := 010

Return .t.

// *********************************************|
// FUNÇÃO PV150ArqEx                            |
// 1 - Importa para arquivo                     |
// 2 - Importa para Excel
// ---------------------------------------------|
// Alexandre Caetano Sciancalepre Jr. (ACSJ)    |
// 16 de Fevereiro de 2005                      |
// ---------------------------------------------|
FUNCTION PV150ArqEx(lExcel)                          
// *********************************************|
Local cPath	:= AllTrim(GetTempPath())
Local oExcelApp
Local cDirDocs := ".\"+Curdir()
Local i
Private cArquivo := ""

If lTop
   PV150CrArq("ARQ")
   TRAB->(DBGoTop())
   Do While .not. TRAB->(Eof())
      ARQ->(DBAppend())
      For i :=1 to TRAB->(FCount())
         Arq->(FieldPut(i,TRAB->(FieldGet(i))))
      Next
      ARQ->(DBCommit())
      TRAB->(DBSkip())
   Enddo
Endif

if lExcel               

   If ARQ->(EasyRecCount()) == 0
      EasyHelp(STR0020,STR0021)  // "Não foram localizados registros que respeitam os filtros informados." ## "Atenção"
      Return .F.
   EndIf
   
   AvExcel(cNomArq,"ARQ", .F.)
   
Else
   //Abre para criacao do arquivo TXT/DBF
   IF lTop                               
      TR350ARQUIVO("ARQ")
      ARQ->(DBCloseArea())
   Else
      TR350ARQUIVO("TRAB")
      TRAB->(DBCloseArea())        
   Endif   
EndIf             

Return .t.
// ******************************************|
// FUNÇÃO PV150CRARQ                         |
// 1-Cria Arquivo para impressao em codebase |
// 2-Cria Arquivo para envio para Excel      |
//   Quando for Top                          |  
// ------------------------------------------|
// Alexandre Caetano Sciancalepre Jr. (ACSJ) |
// 17 de Fevereiro de 2005                   |
// ------------------------------------------|
Function PV150CrArq(PAlias)
// *******************************************
Private aEstru := {}
Private aCampos 

AAdd(aEstru,{"EF6_CONTRA", AVSX3("EF6_CONTRA", 2),AVSX3("EF6_CONTRA", 3),AVSX3("EF6_CONTRA", 4) } )
AAdd(aEstru,{"EF6_BANCO",  AVSX3("EF6_BANCO",  2),AVSX3("EF6_BANCO",  3),AVSX3("EF6_BANCO",  4) } )
AAdd(aEstru,{"EF6_PRACA",  AVSX3("EF6_PRACA",  2),AVSX3("EF6_PRACA",  3),AVSX3("EF6_PRACA",  4) } )
If lEFFTpMod  // PLB 18/12/06
   AAdd(aEstru,{"EF6_SEQCNT", AVSX3("EF6_SEQCNT", 2),AVSX3("EF6_SEQCNT",  3),AVSX3("EF6_SEQCNT",4) } )
EndIf
AAdd(aEstru,{"EF6_TP_FIN", AVSX3("EF6_TP_FIN", 2),AVSX3("EF6_TP_FIN",  3),AVSX3("EF6_TP_FIN",4) } )
AAdd(aEstru,{"EF1_SLD_PM", AVSX3("EF1_SLD_PM", 2),AVSX3("EF1_SLD_PM", 3),AVSX3("EF1_SLD_PM", 4) } )
AAdd(aEstru,{"EF6_NRINVO", AVSX3("EF6_NRINVO", 2),AVSX3("EF6_NRINVO", 3),AVSX3("EF6_NRINVO", 4) } )
AAdd(aEstru,{"EF6_DTEMBA", AVSX3("EF6_DTEMBA" ,2),AVSX3("EF6_DTEMBA" ,3),AVSX3("EF6_DTEMBA" ,4) } )
AAdd(aEstru,{"EF6_VL_VIN", AVSX3("EF6_VL_VIN" ,2),AVSX3("EF6_VL_VIN" ,3),AVSX3("EF6_VL_VIN" ,4) } )
AAdd(aEstru,{"EF6_VL_INV", AVSX3("EF6_VL_INV", 2),AVSX3("EF6_VL_INV", 3),AVSX3("EF6_VL_INV", 4) } )
AAdd(aEstru,{"EF6_MOEDA",  AVSX3("EF6_MOEDA",  2),AVSX3("EF6_MOEDA",  3),AVSX3("EF6_MOEDA",  4) } )
AAdd(aEstru,{"EF1_MOEDA",  AVSX3("EF1_MOEDA",  2),AVSX3("EF1_MOEDA",  3),AVSX3("EF1_MOEDA",  4) } )
AAdd(aEstru,{"EF6_FILIAL", AVSX3("EF6_FILIAL", 2),AVSX3("EF6_FILIAL", 3),AVSX3("EF6_FILIAL", 4) } )
            
If EasyEntryPoint("EFFPV150")
   ExecBlock("EFFPV150", .F., .F.,"CRIAWORK")
Endif               

aCampos:= Array(Len(aEstru))


If Select(PAlias) > 0
   (PAlias)->( DBCloseArea() )       
EndIf
cNomArq:= E_CriaTrab("",aEstru,PAlias)

Return .t.
