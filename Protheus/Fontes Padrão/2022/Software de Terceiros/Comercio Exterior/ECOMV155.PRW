#INCLUDE "Ecomv155.ch"
#include "AVERAGE.CH"
#include "AvPrint.ch"


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ ECOMV155 ≥ Autor ≥ ALEX WALLAUER         ≥ Data ≥ 22/04/99 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Relatorio de DIARIO AUXILIAR                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

#DEFINE PIC_VALOR "@E 9,999,999,999,999.99"// AVSX3('EC7_VALOR')[6]

*----------------*
Function ECOMV155
*----------------*
LOCAL cOldAlias:=ALIAS(), nLin, nColS1, oDlg, nColS2, nCGet, nOpc

LOCAL cTitulo:=STR0001 //"Relat¢rio de Di†rio Auxiliar"

LOCAL aSemSX3:=  {{"WKDTLANC","D",08,0}   ,{"WKHISTOR","C",20,0}   ,;
                  {"WKFORN"  ,"C",20,0}   ,{"WKNR_DI" ,AVSX3("EC7_DI_NUM",2),AVSX3("EC7_DI_NUM",3),0}   ,;
                  {"WKNR_PO" ,"C",15,0}   ,{"WKVL_DEB","N",16,2}   ,;
                  {"WKVL_CRE","N",16,2}  }

Private aHeader:={},aCampos:={}, cNro_Contr, nTotEC7 //E_CriaTrab utiliza    
Private cFilEC7:=xFilial("EC7")
cNomeArq:=E_CriaTrab(,aSemSX3,"Work")
IF ! USED()
   E_Msg(STR0002,1) //"N∆o foi poss°vel abrir o arquivo tempor†rio"
   RETURN .F.
ENDIF

//MFR 18/12/2018 OSSME-1974
IndRegua("Work",cNomeArq+TeOrdBagExt(),"DTOS(WKDTLANC)+WKNR_PO")

cNome1  := cNome2:= SPACE(40)
cCRC1   := cCRC2 := SPACE(15)
cNirc   := SPACE(14)
cMinF_A := cMinF_E  := SPACE(18)
dData_a := dData_E  := AVCTOD("")
cJunta_A:= cJunta_E := SPACE(12)
cMes_Ano:= SPACE(6)
nPag_Ini:= 1
cTermos := STR0003 //"Sim"

#IFDEF TOP
   lTop := .T.
#ENDIF

EC1->(DBSETORDER(1))
EC2->(DBSETORDER(1))
EC5->(DBSETORDER(1))
EC7->(DBSETORDER(3))
EC8->(DBSETORDER(1))
SA2->(DBSETORDER(1))

While .T.

   nOpca:= 1
   
   If !Pergunte("ECOMV5",.T.)
      Exit
   EndIf

   cMes_Ano  := mv_par01
   nPag_Ini  := mv_par02
   cTermos   := mv_par03
         
   IF nOpca = 0
      EXIT
   ENDIF

   WHILE Str(cTermos,1) = "1"  //STR0003 //"Sim"

      nOpc  := 0
      nLin  := 1.5
      nColS1:= 0.8
      nColS2:= 21.5
      nCGet := 5

      DEFINE MSDIALOG oDlg TITLE cTitulo FROM 7.0,0.5 TO 27,79.5 OF oMainWnd

         @ nLin,nColS1 SAY STR0008;nLin+=1.5 //"N I R C:"
         @ nLin,nColS1 SAY STR0009;nLin++ //"Registro na Junta Comercial para os Termos de:"
         @ nLin,nColS1 SAY STR0010 //"Abertura:"
         @ nLin,nColS2 SAY STR0011;nLin++ //"Encerramento:"
         @ nLin,nColS1 SAY STR0012 //"Dt. Reg. Aber.:"
         @ nLin,nColS2 SAY STR0013;nLin+=1.5 //"Dt. Reg. Enc.:"
         @ nLin,nColS1 SAY STR0014;nLin++ //"Inscriá∆o no Ministerio da Fazenda para os Termos de:"
         @ nLin,nColS1 SAY STR0010 //"Abertura:"
         @ nLin,nColS2 SAY STR0011;nLin+=1.5 //"Encerramento:"
         @ nLin,nColS1 SAY STR0015 //"Respons†vel :"
         @ nLin,nColS2+3 SAY STR0016;nLin++ //"CRC:"
         @ nLin,nColS1 SAY STR0015 //"Respons†vel :"
         @ nLin,nColS2+3 SAY STR0016 //"CRC:"

           nLin:=1.5
         @ nLin,nColS1+nCGet MSGET cNirc    SIZE 085,8;nLin+=2.5
         @ nLin,nColS1+nCGet MSGET cJunta_A SIZE 075,8
         @ nLin,nColS2+nCGet MSGET cJunta_E SIZE 075,8;nLin++
         @ nLin,nColS1+nCGet MSGET dData_A  SIZE 035,8
         @ nLin,nColS2+nCGet MSGET dData_E  SIZE 035,8;nLin+=2.5
         @ nLin,nColS1+nCGet MSGET cMinF_A  SIZE 095,8
         @ nLin,nColS2+nCGet MSGET cMinF_E  SIZE 095,8;nLin+=1.5
         @ nLin,nColS1+nCGet MSGET cNome1   SIZE 145,8
         @ nLin,nColS2+nCGet MSGET cCRC1    SIZE 088,8;nLin++
         @ nLin,nColS1+nCGet MSGET cNome2   SIZE 145,8
         @ nLin,nColS2+nCGet MSGET cCRC2    SIZE 088,8

      ACTIVATE MSDIALOG oDlg ON INIT ;
               EnchoiceBar(oDlg,{||nOpc:=2,oDlg:End()},;
                                {||nOpc:=1,oDlg:End()})

      EXIT
   ENDDO
   
   If nOpc = 2 .OR. Str(cTermos,1) = "2"  //"N„o"  //GFP - 23/11/2011
   
      EC5->(DBSETORDER(1))
      EC9->(DBSETORDER(1))
      ECB->(DBSETORDER(1))
      SA2->(DBSETORDER(1))

      If Work->(EasyRecCount("Work")) == 0
         DBSELECTAREA("Work")
         AvZap()
      Endif

      If nOpca == 1
         ContaReg()
         oProcess := MsNewProcess():New({|lEnd| MV155GrvWork(@lEnd) }, STR0026,STR0027,.T.) //"Cont·bil"###"Gerando RelatÛrio"
         oProcess:Activate()
       
         //MV155Rel(lEnd)
      Endif   
   Else
      Exit
   Endif
EndDo

Work->(E_EraseArq(cNomeArq))
DBSELECTAREA(cOldAlias)
EC7->(DBSETORDER(1))
EC2->(DBSETORDER(1))
EC8->(DBSETORDER(1))

RETURN

*---------------------------*
FUNCTION  MV155GrvWork(lEnd)
*---------------------------*
LOCAL cNro_Di:=SPACE(10)
LOCAL cFilEC2:=xFilial("EC2")
LOCAL cFilEC5:=xFilial("EC5")
LOCAL cFilSA2:=xFilial("SA2")
LOCAL cFilEC8:=xFilial("EC8")

// EC1->(DBSEEK(xFilial()+STR(YEAR(AVCTOD("01/01/"+SUBSTR(cMes_Ano,3,4))),4)+SUBSTR(cMes_Ano,1,2)))
//EC7->(DBSEEK(cFilEC7+EC1->EC1_NR_CON))
EC7->(DBSEEK(cFilEC7+cNro_Contr))

//ProcRegua(nTotal)

oProcess:SetRegua1(2)
oProcess:IncRegua1(STR0028) // "Lendo Arquivos 1 / 2 MovimentaÁ„o de Contas"
oProcess:SetRegua2(nTotEC7)

DO WHILE EC7->(!EOF())              .AND.;
         EC7->EC7_FILIAL == cFilEC7 .AND.;
         EC7->EC7_NR_CON == cNro_Contr
   

   /*
   IF nTotal > 1
      IncProc(STR0018) //"Processando Contabilidade"
      nTotal--
   ELSE

   ENDIF
   */
   
   If lEnd
      If lEnd:=MsgYesNo(STR0029,STR0030) //"Tem certeza que deseja cancelar?"###"AtenÁ„o"
         MS_FLUSH()
         Return .F.
      EndIf
   EndIf

   IF !EMPTY(EC7->EC7_HAWB) // EC7 TEM HOUSE
      EC8->(DBSETORDER(1))
      EC8->(DBSEEK(cFilEC8+EC7->EC7_HAWB))
   ELSEIF !EMPTY(EC7->EC7_INVOIC) // EC7 TEM INVOICE
      EC8->(DBSETORDER(2))
      EC8->(DBSEEK(cFilEC8+EC7->EC7_FORN+EC7->EC7_INVOIC))
   ENDIF

   cNro_Di:=EC7->EC7_DI_NUM

   IF EMPTY(cNro_Di) // EC7 NAO TEM DI
      EC2->(DBSETORDER(1))
      EC2->(DBSEEK(cFilEC2+EC8->EC8_HAWB))
      cNro_Di:= EC2->EC2_DI_NUM
   ELSEIF EMPTY(EC7->EC7_HAWB) .AND. EMPTY(EC7->EC7_INVOIC) // EC7 SO TEM DI
      EC2->(DBSETORDER(2))
      EC2->(DBSEEK(cFilEC2+EC7->EC7_DI_NUM))
      EC8->(DBSETORDER(1))
      EC8->(DBSEEK(cFilEC8+EC2->EC2_HAWB))
   ENDIF

   EC5->(DBSEEK(cFilEC5+EC8->EC8_FORN+EC8->EC8_INVOIC))
   SA2->(DBSEEK(cFilSA2+EC5->EC5_FORN))
   
   oProcess:IncRegua2(STR0031+Alltrim(EC7->EC7_NR_CON)+STR0032+EC7->EC7_INVOIC) //"1 / 1 Nro. da ContabilizaÁ„o "###" Inv. "

   Work->(DBAPPEND())
   Work->WKDTLANC := EC7->EC7_DT_LAN
   Work->WKHISTOR := EC7->EC7_COM_HI
   Work->WKFORN   := SA2->A2_NREDUZ
   Work->WKNR_DI  := cNro_Di
   Work->WKNR_PO  := EC8->EC8_PO_NUM
   Work->WKVL_DEB := IF(!EMPTY(EC7->EC7_CTA_DB),IF(EC7->EC7_VALOR<0,(-1)*EC7->EC7_VALOR,EC7->EC7_VALOR),0)
   Work->WKVL_CRE := IF(!EMPTY(EC7->EC7_CTA_CR),IF(EC7->EC7_VALOR<0,-(1)*EC7->EC7_VALOR,EC7->EC7_VALOR),0)

   EC7->(DBSKIP())

ENDDO

/*
FOR I:= 1 TO nTotal
    IncProc(STR0018) //"Processando Contabilidade"
NEXT
*/

MV155Rel(lEnd)

RETURN .T.

*----------------------*
Function MV155Rel(lEnd)
*----------------------*
LOCAL cAno, cMes, cDias
LOCAL aMes:={'Janeiro','Fevereiro','Marco'   ,'Abril'  ,'Maio'    ,'Junho',;
             'Julho'  ,'Agosto'   ,'Setembro','Outubro','Novembro','Dezembro'}

Private cDesc1       := STR0033 //"Este programa tem como objetivo imprimir relatÛrio de"
Private cDesc2       := STR0034 // "Di·rio Auxiliar"
Private cDesc3       := "", cPict := "", imprime := .T.
Private titulo       := STR0035 //"DI¡RIO AUXILIAR"
Private nLin         := 80, Cabec1 :="",Cabec2 := ""
Private cString      := "EC7", CbTxt := ""
Private lAbortPrint  := .F., tamanho:= "P" , limite:= 132
Private nomeprog     := "ECOVC155", nTipo := 18
Private aReturn      :={ STR0036, 1,STR0037, 1, 1, 1, "",1 } //"Zebrado"###"Contabil"
Private nLastKey     := 0,  cbcont := 00
Private CONTFL       := 01, m_pag := 01, aOrd:={}
Private wnrel        := "ECOVC155" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cMoeda,cCusto,cForn,cNome, aDriver  := {}
cbtxt := Space(10)
wnrel :=SetPrint(cString,NomeProg,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,.F.,.T.,Tamanho)

If Str(cTermos,1) = "1"
   mPag:= 02
Endif

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

l1Vez   := .T.
nPag    := nPag_Ini
nLin    := 9999
nLimPage:= 69

nCol1_1 :=00; nCol1_2:=14; nCol1_3:=36; nCol1_4:=50
nCol1_5 :=66; nCol1_6:=85; nCol1_7:=111; nColFim := 132

nDeb_Dia:= nCre_Dia := 0
MVlr_Cre:= MVlr_Deb := 0
//Ddt_Lanc:= Work->WKDTLANC

Work->(DBGOTOP())        

Ddt_Lanc:= Work->WKDTLANC

oProcess:IncRegua1(STR0038) //"Lendo Arquivos 2 / 2 Gerando RelatÛrio"

oProcess:SetRegua2(Work->(EasyRecCount("Work")))

DO WHILE Work->(!EOF())

   IF nLin > nLimPage
      MV155_Cab()
   ENDIF

   //IncProc(STR0021+DTOC(Work->WKDTLANC)) //"Imprimindo Lancamento: "

   IF Ddt_Lanc # Work->WKDTLANC

      @ nLin,nCol1_6 Psay REPL("-",20)
      @ nLin,nCol1_7 Psay REPL("-",20)
      nLin++

      @ nLin,nCol1_5 Psay STR0022 //"Total do dia: "
      @ nLin,nCol1_6 Psay TRANS(nDeb_dia,PIC_VALOR) 
      @ nLin,nCol1_7 Psay TRANS(nCre_dia,PIC_VALOR)
      nLin+=2

      nDeb_Dia := nCre_Dia := 0
      Ddt_Lanc := Work->WKDTLANC

   ENDIF

   oProcess:IncRegua2(STR0039+DTOC(Work->WKDTLANC)) //"Imprimindo LanÁamento"
   
   If lEnd
      If lEnd:=MsgYesNo(STR0029, STR0030) //"Tem certeza que deseja cancelar?"###"AtenÁ„o"
         MS_FLUSH()
         Return .F.
      EndIf
   EndIf

   @ nLin,nCol1_1 Psay DTOC(Work->WKDTLANC)
   @ nLin,nCol1_2 Psay Left(Work->WKHISTOR, 20)
   @ nLin,nCol1_3 Psay Left(Work->WKFORN, 10)
   @ nLin,nCol1_4 Psay TRANS(Work->WKNR_DI,AVSX3("EC7_DI_NUM",6))
   @ nLin,nCol1_5 Psay Work->WKNR_PO
   @ nLin,nCol1_6 Psay TRANS(Work->WKVL_DEB ,PIC_VALOR)
   @ nLin,nCol1_7 Psay TRANS(Work->WKVL_CRE ,PIC_VALOR)
   nLin++

   nDeb_dia += Work->WKVL_DEB
   nCre_dia += Work->WKVL_CRE
   MVlr_Deb += Work->WKVL_DEB
   MVlr_Cre += Work->WKVL_CRE

   Work->(DBSKIP())

ENDDO

IF nLin > nLimPage
   MV155_Cab()
ENDIF

@ nLin,nCol1_6 Psay REPL("-",20)
@ nLin,nCol1_7 Psay REPL("-",20)
nLin++

@ nLin,nCol1_5 Psay STR0022 //"Total do dia: "
@ nLin,nCol1_6 Psay TRANS(nDeb_dia,PIC_VALOR) 
@ nLin,nCol1_7 Psay TRANS(nCre_dia,PIC_VALOR)
nLin+=2

IF nLin > nLimPage
   MV155_Cab()
ENDIF

@ nLin,nCol1_6 Psay REPL("-",20)
@ nLin,nCol1_7 Psay REPL("-",20)
nLin++

@ nLin,nCol1_5 Psay STR0023  //"TOTAL GERAL: "
@ nLin,nCol1_6 Psay TRANS(MVlr_Deb ,PIC_VALOR)
@ nLin,nCol1_7 Psay TRANS(MVlr_Cre ,PIC_VALOR)

IF Str(cTermos,1) = "1" //STR0003 //"Sim"

  cMes := aMes[ (MONTH(AVCTOD("01/"+SUBSTR(cMes_Ano,1,2)+"/99"))) ]
  cAno := STR(Year(AVCTOD("01/01/"+SUBSTR(cMes_Ano,3,4))),4,0)
  cDias:= QtdDiasMes(cMes,cAno)

  MV155Termo('01' ,cJunta_A,dData_A,cMinF_A,cMes,cAno)//DATA INICIAL

  MV155Termo(cDias,cJunta_E,dData_E,cMinF_E,cMes,cAno)//DATA FINAL

ENDIF

Set Printer To
Commit
Ourspool(wnrel)

MS_FLUSH()

Return

*-------------------*
FUNCTION MV155_Cab()
*-------------------*
LOCAL cTexto1:=STR0035  //"DI¡RIO AUXILIAR"
LOCAL cTexto2:=STR0025 + TRANS(cMes_ano,"@R 99/9999") //"Mes de "

aDriver := ReadDriver()

@ 0,0 PSay &(aDriver[3])

nLin:= 1
nPag++

@ nLin,nCol1_1 PSay __PrtThinLine()
nLin++

@ nLin,nCol1_1 PSay ALLTRIM(SM0->M0_NOME)+" - "+ALLTRIM(SM0->M0_FILIAL)
@ nLin,( (nColFim/2) - Round((Len(cTexto1)/2),0) ) PSay cTexto1
@ nLin,nColFim-19 PSay STR0040+STR(nPag,8) //"Folha...: "
nLin++

@ nLin,nCol1_1 PSay STR0041 //'SIGAECO'
@ nLin,( (nColFim/2) - Round((Len(cTexto2)/2),0) ) PSay cTexto2
@ nLin,nColFim-19 PSay STR0042+DTOC(dDatabase) //"Emissao.: "
nLin++

@ nLin,nCol1_1 PSay __PrtThinLine()

nLin++
@ nLin, nCol1_1 Psay STR0043 //"Dt.Lanc."
@ nLin, nCol1_2 Psay STR0044 //"Historico"
@ nLin, nCol1_3 Psay STR0045 //"Fornecedor"
@ nLin, nCol1_4 Psay STR0046 //"Nro. D.I."
@ nLin, nCol1_5 Psay STR0047 //"Nro. P.O."
@ nLin, nCol1_6 Psay STR0048 //"Valor do Debito"
@ nLin, nCol1_7 Psay STR0049 //"Valor do Credito"
nLin++
@ nLin, nCol1_1 Psay REPL("-",08)
@ nLin, nCol1_2 Psay REPL("-",20)
@ nLin, nCol1_3 Psay REPL("-",10)
@ nLin, nCol1_4 Psay REPL("-",12)
@ nLin, nCol1_5 Psay REPL("-",15)
@ nLin, nCol1_6 Psay REPL("-",20)
@ nLin, nCol1_7 Psay REPL("-",20)
nLin++

RETURN

*----------------------------------------------------------------------------*
FUNCTION  MV155Termo(cFlag,pJunta,pData,pMinFaz,cMes,cAno)
*----------------------------------------------------------------------------*
LOCAL cEst:=ALLTRIM(Tabela("12",SM0->M0_ESTCOB)), nTam:=120, I
LOCAL cTexto:="TERMO DE "+If(cFlag = "01", "ABERTURA", "ENCERRAMENTO")

aDriver := ReadDriver()

@ 0,0 PSay &(aDriver[3])

nLin:= 3

cPagina:= STR(nPag+1,5)

@ nLin,nColFim-19 PSay "Folha...: "+If(cFlag = "01", STR(nPag_Ini,5), cPagina) //"Folha...:

nLin+= 4
@ nLin,nCol1_1 PSay __PrtThinLine()
nLin++
@ nLin,((nColFim/2) - Round((Len(cTexto)/2),0) ) PSay cTexto
nLin++
@ nLin,nCol1_1 PSay __PrtThinLine()
nLin+= 4

cMemo:="        CONTEM ESTE LIVRO "+ALLTRIM(cPagina) + " FOLHAS ELETRONICAMENTE NUMERADAS DE "+ ALLTRIM(STR(nPag_Ini)) + " A " + ALLTRIM(cPagina)
cMemo+=" QUE SERVIRA DE  'DIARIO AUXILIAR ' DA "+ALLTRIM(SM0->M0_NOMECOM)+", COM"
cMemo+=" SEDE NESTA PRACA NA "+ALLTRIM(SM0->M0_ENDCOB)+", "+ALLTRIM(SM0->M0_CIDCOB)+", REGISTRADA"
cMemo+=" NA JUNTA COMERCIAL DO ESTADO DE "+cEst+" SOB No. "+ALLTRIM(pJunta)+ " EM "+ SUBSTR(DTOS(pData),7,2) +"/"+ SUBSTR(DTOS(pData),5,2)+"/"+ SUBSTR(DTOS(pData),1,4)
cMemo+=" E INSCRITA NO CADASTRO GERAL DE CONTRIBUINTES DO MINISTERIO DA FAZENDA SOB"
cMemo+=" No. "+ALLTRIM(pMinFaz)+" (ARTIGO 3.0 DO DECRETO LEI No. 305 DE 28/02/1967)."

FOR I := 1 TO MLCOUNT(cMemo,nTam-1)
   @ nLin,nCol1_1 Psay MEMOLINE(cMemo,nTam,I)
   nLin++
NEXT                                                                           

IF cFlag <> "01"

  @ nLin,nCol1_1 Psay "NIRC : "+cNirc
  nLin++

ENDIF

nLin+=2
@ nLin, nCol1_1+23 Psay "Sao Paulo, "+ cFlag+" de "+ cMes +" de "+ cAno
nLin+=4

@ nLin, nCol1_1+20 Psay REPLICATE("_",LEN(cNome1))
nLin++

@ nLin, nCol1_1+20 Psay ALLTRIM(cNome1)
nLin++

@ nLin, nCol1_1+20 Psay ALLTRIM(cCrc1)
nLin+=4

@ nLin, nCol1_1+20 Psay REPLICATE("_",LEN(cNome2))
nLin++

@ nLin, nCol1_1+20 Psay ALLTRIM(cNome2)
nLin++

@ nLin, nCol1_1+20 Psay ALLTRIM(cCrc2)
nLin+=2

RETURN

*-----------------------------*
FUNCTION QtdDiasMes(pMes,pAno)
*-----------------------------*
LOCAL dData

IF pMes = "02"

   dData:= AVCTOD("29/"+pMes+"/"+pAno)

   IF EMPTY(dData)

      RETURN "28"

   ELSE

      RETURN "29"

   ENDIF

ELSEIF pMes = "04" .OR. pMes= "06" .OR. pMes= "09" .OR. pMes = "11"

   RETURN  "30"

ENDIF

RETURN "31"

*-----------------------*
Function MV155Val(cTipo)
*-----------------------*

If cTipo = '1' .OR. cTipo = 'OK'

   //IF EMPTY(SUBSTR(cMes_Ano,1,2))
   IF EMPTY(SUBSTR(mv_par01,1,2))
      Help(" ",1,"AVG0005329") //E_Msg("Màs n∆o preenchido",1)
      Return .F.
   ENDIF

   IF VAL(SUBSTR(mv_par01,1,2)) < 1 .OR. VAL(SUBSTR(mv_par01,1,2)) > 12 //IF VAL(SUBSTR(cMes_Ano,1,2)) < 1 .OR. VAL(SUBSTR(cMes_Ano,1,2)) > 12
      Help(" ",1,"AVG0005330") //E_Msg("Màs n∆o existe",1)
      Return .F.
   ENDIF

   //IF EMPTY(SUBSTR(cMes_Ano,3,4))
   IF EMPTY(SUBSTR(mv_par01,3,4))
      Help(" ",1,"AVG0005331") //E_Msg("Ano n∆o preenchido",1)
      Return .F.
   ENDIF
      //If(lTemEC1TPM,"IMPORT", "")

   //IF !EC1->(DBSEEK(xFilial()+If(lTemEC1TPM,"IMPORT", "")+STR(YEAR(AVCTOD("01/01/"+SUBSTR(cMes_Ano,3,4))),4)+SUBSTR(cMes_Ano,1,2)))
   IF !EC1->(DBSEEK(xFilial()+"IMPORT"+STR(YEAR(AVCTOD("01/01/"+SUBSTR(mv_par01,3,4))),4)+SUBSTR(mv_par01,1,2)))
      Help(" ",1,"AVG0005332") //E_MSG('Mes/Ano n∆o contabilizado',1)
      Return .F.
   ENDIF

   cNro_Contr := EC1->EC1_NR_CONT
   
   Do While EC1->(!Eof()) .And. EC1->(xFilial()) = EC1->EC1_FILIAL .And. ;
      STR(YEAR(AVCTOD("01/01/"+SUBSTR(mv_par01,3,4))),4) + SUBSTR(mv_par01,1,2) == STR(YEAR(AVCTOD("01/01/"+SUBSTR(EC1->EC1_ANO,3,4))),4)+SUBSTR(EC1->EC1_MES,1,2) .And.;
      EC1->EC1_TPMODU = "IMPORT"

      If EC1->EC1_STATUS # "E" .AND. EC7->(DbSeek(xFilial()+EC1->EC1_NR_CONT))
         cNro_Contr := EC1->EC1_NR_CONT
      Endif
      
      EC1->(DbSkip())
   Enddo
   
   IF !EC7->(DBSEEK(xFilial()+cNro_Contr))
      Help(" ",1,"AVG0005333") //E_MSG('Nao ha†lancamentos para este periodo',1)
      Return .F.
   ENDIF

ENDIF

If cTipo = '2' .OR. cTipo = 'OK'
   IF EMPTY(nPag_Ini)
      Help(" ",1,"AVG0005334") //E_Msg("Pagina nao preenchida",1)
      Return .F.
   ENDIF
EndIf

Return .T.

*--------------------------*
Static Function ContaReg()
*--------------------------*
Local cQueryEC7, cWhereEC7
Local cCondEC7:=   " AND EC7.D_E_L_E_T_ <> '*'"
Local cCondAsEC7:= " AND EC7.@DELETED@ <> '*'"

nTotEC7  := 0

IF lTop

  cAliasEC7   := "EC7TMP"

  // Where EC7
  cWhereEC7:= " EC7.EC7_FILIAL='"+ cFilEC7 +"' AND EC7.EC7_NR_CON='"+cNro_Contr+"' "
  cWhereEC7+= If(TcSrvType()<>"AS/400",cCondEC7,cCondAsEC7)
  cQueryEC7:= "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC7")+ " EC7 Where "+cWhereEC7
  
  // EC7
  cQueryEC7 := ChangeQuery(cQueryEC7)
  DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryEC7), cAliasEC7,.F.,.T.)
  
  If Select(cAliasEC7) > 0
     nTotEC7 := (cAliasEC7)->TOTALREG
     (cAliasEC7)->(DbCloseArea())
  Else
     nTotEC7 := 0
  Endif
Else
  // EC7
  EC7->(DbSeek(cFilEC7,.T.))
  EC7->(DBEVAL({||nTotEC7++, MsProcTxt("Conta "+EC7->EC7_NR_CON)},,{||EC7->(!EOF()) .And. EC7->EC7_FILIAL = cFilEC7 .And. ;
               EC7->EC7_NR_CON == cNro_Contr })) //"Conta "

Endif

Return .T.
*----------------------------------------------------------------------------*
*                     FIM DO PROGRAMA ECIMV155.PRW
*----------------------------------------------------------------------------*

