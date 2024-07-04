
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#include "ap5mail.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSTRTPTU ³ Autor ³ Eduardo Motta         ³ Data ³ 12.02.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ RDMAKE para tratamento do PTU online (RECEBIMENTO)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PLSTRTPTU()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC cPathSCS2 :=  "" //GetNewPar("MV_PTUSCS","")  // preencher com local onde esta instalado o SCS2


User Function PlsTrtPtu()
Local aCab := {}
Local aIte := {}
Local aRet := {}
Local cCodUsu  := ""
Local cCodMed  := ""
Local cCodMed2 := ""
Local cData    := ""
Local cHora    := ""
Local dData    := CtoD("")
Local cCidPri  := ""
Local cCodPro  := ""
Local cUniSol  := ""
Local nI := 0
Local nJ := 0
Local nItem := 0
Local nQtd := 0
Local nH := 0
Local cNumImp := ""
Local cMsgErro
Local cNumSeq := ""
Local aDadSeq := {}
Local aReqCab := {}
Local aReqIte := {}
Local cSenha := ""
Local cTimeIni := Time()
Local cTimeOut := "00:01:00"   // 60 segundos ou 01 minuto para timeout
Private cMsgErro01 := ""
Private cMsgErro02 := ""
Private cMsgErro03 := ""
Private cMsgErro04 := ""
Private cMsgErro05 := ""
Private cVarMacro := ""
Private cCodInt  := ""


cDelimit := ""

PlsPtuLog("LOG PTU")
PlsPtuLog(Upper(PlsPtuGet("TP_TRANS",aDados)))
PlsPtuLog("***********************************")
If Upper(PlsPtuGet("TP_TRANS",aDados)) == "80110010"  // CONSULTA
   PlsPtuLog("NR_TRANS  => "+PlsPtuGet("NR_TRANS_R",aDados))
   PlsPtuLog("USUARIO   => "+PlsPtuGet("ID_BENEF",aDados))
   PlsPtuLog("CD_PREREQ => "+PlsPtuGet("CD_PRE_REQ",aDados))
   PlsPtuLog("CD_UNI => "+PlsPtuGet("CD_UNI",aDados))
   PlsPtuLog("CD_UNI_PRE_REQ => "+PlsPtuGet("UNI_PRE_REQ",aDados))
   PlsPtuLog("UNI_PRE => "+PlsPtuGet("CD_UNI_PRE",aDados))
   PlsPtuLog("CID     => "+PlsPtuGet("CD_CID",aDados))
   PlsPtuLog("CD_SERVICO => "+PlsPtuGet("CD_SERVICO",aDados))
   cCodInt  := PlsPtuGet("CD_UNI",aDados)
   cCodUsu  := SubStr(cCodInt,2)+PlsPtuGet("ID_BENEF",aDados)
   cCodMed  := PlsPtuGet("CD_PREST",aDados)   // prestador
   cCodMed2 := PlsPtuGet("CD_PRE_REQ",aDados)   // requisitante
   cData    := SubStr(PlsPtuGet("DT_TRANS",aDados),1,10)
   cHora    := SubStr(PlsPtuGet("DT_TRANS",aDados),11,5)
   dData    := CtoD(SubStr(cData,9,2)+"/"+SubStr(cData,6,2)+"/"+SubStr(cData,1,4))
   cCidPri  := PlsPtuGet("CD_CID",aDados)
   cCodPro  := "01"+PlsPtuGet("CD_SERVICO",aDados)
   cUniSol  := PlsPtuGet("CD_UNISOL",aDados)
   nQtd     := Val(PlsPtuGet("QT_SERVICO",aDados))
   PlsPtuLog("cod.int ["+cCodInt+"]")
   PlsPtuLog("cod.usr ["+cCodUsu+"]")
   aadd(aCab,{"OPEMOV",cCodInt})
   aadd(aCab,{"USUARIO",cCodUsu})
   aadd(aCab,{"DATPRO",dData })
   aadd(aCab,{"HORAPRO",SubStr(StrTran(cHora,":",""),1,4)})
//   aadd(aCab,{"CIDPRI",cCidPri })
//   aadd(aCab,{"CODESP",BAQ->BAQ_CODESP })
   BAW->(DbSetOrder(3))
   If Val(cCodMed2) # 0
      BAW->(DbSeek(xFilial("BAW")+cCodInt+cCodMed2))
      aadd(aCab,{"OPESOL",cUniSol})
      BAU->(DbSetOrder(1))
      BAU->(DbSeek(xFilial("BAU")+BAW->BAW_CODIGO))
      aadd(aCab,{"CDPFSO",BAU->BAU_CODBB0})
   EndIf   
   BAW->(DbSetOrder(3))
   BAW->(DbSeek(xFilial("BAW")+cCodInt+cCodMed))
   BAU->(DbSetOrder(1))
   BAU->(DbSeek(xFilial("BAU")+BAW->BAW_CODIGO))
//   aadd(aCab,{"CODRDA",BAU->BAU_CODIGO})
   aIte := {}
   aadd(aIte,{})
   aadd(aIte[1],{"SEQMOV","001" })
   aadd(aIte[1],{"CODPAD",SubStr(cCodPro,1,2)})
   aadd(aIte[1],{"CODPRO",SubStr(cCodPro,3)})
   aadd(aIte[1],{"QTD",nQtd })

   nH       := PLSAbreSem("PLSTRTPTU.SMF")
      
/*
   cSQL     := "SELECT MAX(BD6_NUMIMP) MAIOR FROM "+RetSQLName("BD6")+" WHERE BD6_FILIAL = '"+xFilial("BD6")+"' AND D_E_L_E_T_ = '' AND BD6_NUMIMP>='0000000000000000' AND BD6_NUMIMP<='0000000999999999' "
   PLSQUERY(cSQL,"PLSTEMP")                
   cNumImp := StrZero(Val(PLSTEMP->MAIOR)+1,16)
   PLSTEMP->(DbCloseArea())
*/
   cSQL     := "SELECT MAX(BD6_NUMIMP) MAIOR FROM "+RetSQLName("BD6")+" WHERE BD6_FILIAL = '"+xFilial("BD6")+"' AND D_E_L_E_T_ = '' AND BD6_NUMIMP>='0000000200000000' AND BD6_NUMIMP<='0000000999999999' "
   PLSQUERY(cSQL,"PLSTEMP")                
   If Val(PLSTEMP->MAIOR) > 0
      cNumImp := StrZero(Val(PLSTEMP->MAIOR)+1,16)
   Else
      cNumImp := StrZero(200000000,16)
   EndIf
   PLSTEMP->(DbCloseArea())
   PlsPtuLog("num.imp. ["+cNumImp+"]")
      
   aadd(aCab,{"NUMIMP",cNumImp})   

   aRet := PLSXAUTP(aCab,aIte)
   PLSFechaSem(nH)
   BA1->(DbSetOrder(2))
   If !BA1->(DbSeek(xFilial("BA1")+cCodUsu))
      BA1->(DbSetOrder(5))
      BA1->(DbSeek(xFilial("BA1")+cCodUsu))
   EndIf   
   PlsPtuPut("NM_BENEF",PadR(BA1->BA1_NOMUSR,25)  ,aDados)
   PlsPtuPut("TP_PESSOA",If(BA3->BA3_TIPOUS=="1","2","1"),aDados)

   If aRet[1]   // autorizou
      PlsPtuPut("NR_AUTORIZ",SubStr(cNumImp,8),aDados)
      BA3->(DbSeek(xFilial()+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
      PlsPtuPut("ID_AUTORIZ","1",aDados)
      PlsPtuPut("QT_AUTORIZ",StrZero(nQtd,4),aDados)
      PlsPtuPut("DT_VAL_AUT",DtoC(dData),aDados)
      PlsPtuPut("ERRO01","0000",aDados)
      PlsPtuPut("ERRO02","0000",aDados)
      PlsPtuPut("ERRO03","0000",aDados)
      PlsPtuPut("ERRO04","0000",aDados)
      PlsPtuPut("ERRO05","0000",aDados)
      PlsPtuLog("*** AUTORIZADO ***")      
   Else  // nao autorizou
      cMsgErro01 := ""
      cMsgErro02 := ""
      cMsgErro03 := ""
      cMsgErro04 := ""
      cMsgErro05 := ""
      PlsPtuPut("NR_AUTORIZ",StrZero(0,9),aDados)
      PlsPtuPut("ID_AUTORIZ","2",aDados)
      PlsPtuPut("QT_AUTORIZ",StrZero(0,4),aDados)
      PlsPtuLog("*** NAO AUTORIZADO ***")      
      For nI := 1 to Len(aRet[4])
         If nI > 5
            Exit
         EndIf
         PlsPtuLog("ERRO ["+aRet[4,nI,2]+"]")
         PlsPtuLog("ERRO PTU ["+MsgErro(aRet[4,nI,2])+"]")
         cVarMacro := "cMsgErro"+StrZero(nI,2)
         &cVarMacro := aRet[4,nI,2]
         PlsPtuLog(AllTrim(aRet[4,nI,3]))
         PlsPtuLog(AllTrim(aRet[4,nI,4]))
      Next
      PlsPtuLog("retorno ["+cMsgErro01+"]")
      PlsPtuLog("retorno ["+MsgErro(cMsgErro01)+"]")
      PlsPtuPut("ERRO01",MsgErro(cMsgErro01),aDados)
      PlsPtuPut("ERRO02",MsgErro(cMsgErro02),aDados)
      PlsPtuPut("ERRO03",MsgErro(cMsgErro03),aDados)
      PlsPtuPut("ERRO04",MsgErro(cMsgErro04),aDados)
      PlsPtuPut("ERRO05",MsgErro(cMsgErro05),aDados)
      PlsPtuLog("*********************")      
   EndIf

ElseIf Upper(PlsPtuGet("TP_TRANS",aDados)) == "80110020"  // EXAMES
   PlsPtuLog("NR_TRANS  => "+PlsPtuGet("NR_TRANS_R",aDados))
   PlsPtuLog("USUARIO   => "+PlsPtuGet("ID_BENEF",aDados))
   PlsPtuLog("CD_PREREQ => "+PlsPtuGet("CD_PRE_REQ",aDados))
   PlsPtuLog("CD_UNI => "+PlsPtuGet("CD_UNI",aDados))
   PlsPtuLog("CD_UNI_PRE_REQ => "+PlsPtuGet("UNI_PRE_REQ",aDados))
   PlsPtuLog("UNI_PRE => "+PlsPtuGet("CD_UNI_PRE",aDados))
   PlsPtuLog("CID     => "+PlsPtuGet("CD_CID",aDados))
   cCodInt  := PlsIntPad()
   cCodUsu  := SubStr(cCodInt,2)+PlsPtuGet("ID_BENEF",aDados)
   cCodMed  := PlsPtuGet("CD_PREST",aDados)   // prestador
   cCodMed2 := PlsPtuGet("CD_PRE_REQ",aDados)   // requisitante
   cData    := SubStr(PlsPtuGet("DT_TRANS",aDados),1,10)
   cHora    := SubStr(PlsPtuGet("DT_TRANS",aDados),11,5)
   dData    := CtoD(SubStr(cData,9,2)+"/"+SubStr(cData,6,2)+"/"+SubStr(cData,1,4))
   cCidPri  := Upper(PlsPtuGet("CD_CID",aDados))
   cUniSol  := PlsPtuGet("CD_UNI",aDados)
   PlsPtuLog("cod.int ["+cCodInt+"]")
   PlsPtuLog("cod.usr ["+cCodUsu+"]")

   aadd(aCab,{"OPEMOV",cCodInt})
   aadd(aCab,{"USUARIO",cCodUsu})
   aadd(aCab,{"DATPRO",dData })
   aadd(aCab,{"HORAPRO",SubStr(StrTran(cHora,":",""),1,4)})
   aadd(aCab,{"CIDPRI",cCidPri })

   aadd(aCab,{"CODRDA","000181"})  // GETNewPar("MV_PLSESPL","000")
   aadd(aCab,{"OPESOL","0024"})  // CODIGO DA UNIMED BOTUCATU
   aadd(aCab,{"CDPFSO","000181"}) // Tulio vai disponibilizar funcao
   aadd(aCab,{"CODESP","0024061"})

   BAW->(DbSetOrder(3))
   If Val(cCodMed2) # 0
      BAW->(DbSeek(xFilial("BAW")+cCodInt+cCodMed2))
      aadd(aCab,{"OPESOL",cUniSol})
      BAU->(DbSetOrder(1))
      BAU->(DbSeek(xFilial("BAU")+BAW->BAW_CODIGO))
      aadd(aCab,{"CDPFSO",BAU->BAU_CODBB0})
   EndIf   
   BAW->(DbSetOrder(3))
   BAW->(DbSeek(xFilial("BAW")+cCodInt+cCodMed))
   BAU->(DbSetOrder(1))
   BAU->(DbSeek(xFilial("BAU")+BAW->BAW_CODIGO))
   If Empty(PlsPtuGet("CD_SERVICO",aItens[Len(aItens)],""))
      aSize(aItens,Len(aItens)-1)
   EndIf
   aIte := {}
   For nI := 1 to Len(aItens)
      cCodPro  := "01"+PlsPtuGet("CD_SERVICO",aItens[nI])
      nQtd     := Val(PlsPtuGet("QT_SERVICO",aItens[nI]))
      aadd(aIte,{})
      aadd(aIte[nI],{"SEQMOV",StrZero(nI,3) })
      aadd(aIte[nI],{"CODPAD",SubStr(cCodPro,1,2)})
      aadd(aIte[nI],{"CODPRO",SubStr(cCodPro,3)})
      aadd(aIte[nI],{"QTD",nQtd })
   Next   

   nH       := PLSAbreSem("PLSTRTPTU.SMF")
      
   cSQL     := "SELECT MAX(BD6_NUMIMP) MAIOR FROM "+RetSQLName("BD6")+" WHERE BD6_FILIAL = '"+xFilial("BD6")+"' AND D_E_L_E_T_ = '' AND SUBSTRING(BD6_NUMIMP,1,3)='000' "
   PLSQUERY(cSQL,"PLSTEMP")                
   cNumImp := StrZero(Val(PLSTEMP->MAIOR)+1,16)
   PLSTEMP->(DbCloseArea())
   PlsPtuLog("num.imp. ["+cNumImp+"]")
      
   aadd(aCab,{"NUMIMP",cNumImp})   
   aRet := PLSXAUTP(aCab,aIte)
   PLSFechaSem(nH)
   BA1->(DbSetOrder(2))
   If !BA1->(DbSeek(xFilial("BA1")+cCodUsu))
      BA1->(DbSetOrder(5))
      BA1->(DbSeek(xFilial("BA1")+cCodUsu))
   EndIf   
   PlsPtuPut("NM_BENEF",PadR(BA1->BA1_NOMUSR,25)  ,aDados)
   PlsPtuPut("TP_PESSOA",If(BA3->BA3_TIPOUS=="1","2","1"),aDados)
   If aRet[1]   // autorizou
      BA3->(DbSeek(xFilial()+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
      PlsPtuPut("NR_AUTORIZ",SubStr(cNumImp,8),aDados)
      PlsPtuPut("ID_AUTORIZ","1",aDados)
      PlsPtuPut("QT_AUTORIZ",StrZero(nQtd,4),aDados)
      PlsPtuPut("DT_VAL_AUT",DtoC(dData),aDados)
      PlsPtuPut("ERRO01","0000",aDados)
      PlsPtuPut("ERRO02","0000",aDados)
      PlsPtuPut("ERRO03","0000",aDados)
      PlsPtuPut("ERRO04","0000",aDados)
      PlsPtuPut("ERRO05","0000",aDados)
      For nI := 1 to Len(aItens)
         PlsPtuPut("ERRO01","0000",aItens[nI])
         PlsPtuPut("ERRO02","0000",aItens[nI])
         PlsPtuPut("ERRO03","0000",aItens[nI])
         PlsPtuPut("ERRO04","0000",aItens[nI])
         PlsPtuPut("ERRO05","0000",aItens[nI])
      Next
      PlsPtuLog("*** AUTORIZADO ***")      
   Else  // nao autorizou
      cMsgErro01 := ""
      cMsgErro02 := ""
      cMsgErro03 := ""
      cMsgErro04 := ""
      cMsgErro05 := ""
      PlsPtuPut("NR_AUTORIZ",StrZero(0,9),aDados)
      PlsPtuPut("ID_AUTORIZ","2",aDados)
      PlsPtuPut("QT_AUTORIZ",StrZero(0,4),aDados)
      PlsPtuLog("*** NAO AUTORIZADO ***")
      For nI := 1 to Len(aRet[4])
         nItem := Val(aRet[4,nI,1])
         cMsgErro := MsgErro(aRet[4,nI,2])
         If Empty(PlsPtuGet("ERRO01",aItens[nItem]))
            PlsPtuPut("ERRO01",cMsgErro,aItens[nItem])
         ElseIf Empty(PlsPtuGet("ERRO02",aItens[nItem]))
            PlsPtuPut("ERRO02",cMsgErro,aItens[nItem])
         ElseIf Empty(PlsPtuGet("ERRO03",aItens[nItem]))
            PlsPtuPut("ERRO03",cMsgErro,aItens[nItem])
         ElseIf Empty(PlsPtuGet("ERRO04",aItens[nItem]))
            PlsPtuPut("ERRO04",cMsgErro,aItens[nItem])
         ElseIf Empty(PlsPtuGet("ERRO05",aItens[nItem]))
            PlsPtuPut("ERRO05",cMsgErro,aItens[nItem])
         EndIf   
         If nI > 5
            Loop
         EndIf   
         cVarMacro := "cMsgErro"+StrZero(nI,2)
         &cVarMacro := aRet[4,nI,2]
         PlsPtuLog(AllTrim(aRet[4,nI,3]))
         PlsPtuLog(AllTrim(aRet[4,nI,4]))
      Next
      For nI := 1 to Len(aItens)
         PlsPtuPut("ID_AUTORIZ","2",aItens[nI])
         PlsPtuPut("QT_AUTORIZ",StrZero(0,4),aItens[nI])
         If Empty(PlsPtuGet("ERRO01",aItens[nI]))
            PlsPtuPut("ERRO01","0000",aItens[nI])
         EndIf   
         If Empty(PlsPtuGet("ERRO02",aItens[nI]))
            PlsPtuPut("ERRO02","0000",aItens[nI])
         EndIf   
         If Empty(PlsPtuGet("ERRO03",aItens[nI]))
            PlsPtuPut("ERRO03","0000",aItens[nI])
         EndIf   
         If Empty(PlsPtuGet("ERRO04",aItens[nI]))
            PlsPtuPut("ERRO04","0000",aItens[nI])
         EndIf   
         If Empty(PlsPtuGet("ERRO05",aItens[nI]))
            PlsPtuPut("ERRO05","0000",aItens[nI])
         EndIf   
      Next
      PlsPtuLog("retorno ["+MsgErro(cMsgErro01)+"]")
      PlsPtuPut("ERRO01",MsgErro(cMsgErro01),aDados)
      PlsPtuPut("ERRO02",MsgErro(cMsgErro02),aDados)
      PlsPtuPut("ERRO03",MsgErro(cMsgErro03),aDados)
      PlsPtuPut("ERRO04",MsgErro(cMsgErro04),aDados)
      PlsPtuPut("ERRO05",MsgErro(cMsgErro05),aDados)
      PlsPtuLog("*********************")      
   EndIf
ElseIf Upper(PlsPtuGet("TP_TRANS",aDados)) == "80110131"  // AUDITORIA - EXAMES
   cNumSeq  := PlsPtuGet("NR_TRANS_R",aDados)
   aDadSeq  := PlsGetBSA(cNumSeq)  // posicao 1 CABECALHO  e posicao 2 ITENS
   aReqCab  := aClone(aDadSeq[1])
   aReqIte  := aClone(aDadSeq[2])
   cSenha   := PlsPtuGet("NR_AUTORIZ",aDados)
   PlsPtuLog("***************************************")
   PlsPtuLog("processando auditoria NUMSEQ "+cNumSeq)
   PlsPtuLog("Senha : "+cSenha)

   cCodInt  := PlsPtuGet("CD_UNI",aReqCab)
   cCodUsu  := AllTrim(cCodInt)+PadR(PlsPtuGet("ID_BENEF",aReqCab),13)
//   BA1->(DbSetOrder(5))
//   If !BA1->(DbSeek(xFilial("BA1")+cCodInt+cCodUsu))
//      BA1->(DbSeek(xFilial("BA1")+SubStr(cCodInt,2)+cCodUsu))
//   EndIf
//   cCodUsu  := BA1->(BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
//   cCodInt  := PlsIntPad()
   cData    := SubStr(PlsPtuGet("DT_TRANS",aDados),1,10)
   dData    := CtoD(Substr(cData,09,2)+"/"+Substr(cData,06,2)+"/"+Substr(cData,01,4))
   cHora    := SubStr(PlsPtuGet("DT_TRANS",aDados),11,5)
   cCidPri  := PlsPtuGet("CD_CID",aReqCab)
   cUniSol  := PlsIntPad()
   
   aadd(aCab,{"OPEMOV",PlsIntPad()})
   aadd(aCab,{"USUARIO",cCodUsu})
   aadd(aCab,{"DATPRO",dData })
   aadd(aCab,{"HORAPRO",SubStr(StrTran(cHora,":",""),1,4)})
   aadd(aCab,{"CIDPRI",cCidPri })
   aadd(aCab,{"OPESOL",PlsIntPad()})
   aadd(aCab,{"SENHA",cSenha})
   aadd(aCab,{"CODRDA",PlsPtuGet("CODRDA",aReqCab)})  // GETNewPar("MV_PLSESPL","000")
   aadd(aCab,{"CDPFSO",PlsPtuGet("CDPFSO",aReqCab)}) // Tulio vai disponibilizar funcao
   aadd(aCab,{"CODESP",PLSDADRDA(PlsIntPad(),PlsPtuGet("CODRDA",aReqCab),'1',dData)[15]})
   
   aIte := {}
   For nI := 1 to Len(aItens)
      If PlsPtuGet("ID_AUTORIZ",aItens[nI]) == "1"
         cCodPro  := "01"+PlsPtuGet("CD_SERVICO",aItens[nI])
         nQtd     := Val(PlsPtuGet("QT_AUTORIZ",aItens[nI]))
         PlsPtuLog("***********************************")
         PlsPtuLog("Item   = "+StrZero(nI,2))
         PlsPtuLog("CodPro = "+cCodPro)
         PlsPtuLog("Qtd    = "+Str(nQtd,12,2))
         PlsPtuLog("***********************************")
         aadd(aIte,{})
         aadd(aIte[nI],{"SEQMOV",StrZero(nI,3) })
         aadd(aIte[nI],{"CODPAD",SubStr(cCodPro,1,2)})
         aadd(aIte[nI],{"CODPRO",SubStr(cCodPro,3)})
         aadd(aIte[nI],{"QTD",nQtd })
      EndIf   
   Next   
   PlsPtuLog("Dados aCab")
   For nI := 1 to len(aCab)
      PlsPtuLog(aCab[nI,1]+"="+cValToChar(aCab[nI,2])+"]")
   Next
   PlsPtuLog("***********************************")

   If !Empty(cSenha) .and. Val(cSenha) > 0
      nH       := PLSAbreSem("PLSTRTPTU.SMF")
      
      cSQL     := "SELECT MAX(BD6_NUMIMP) MAIOR FROM "+RetSQLName("BD6")+" WHERE BD6_FILIAL = '"+xFilial("BD6")+"' AND D_E_L_E_T_ = '' AND SUBSTRING(BD6_NUMIMP,1,3)='000' "
      PLSQUERY(cSQL,"PLSTEMP")                
      cNumImp := StrZero(Val(PLSTEMP->MAIOR)+1,16)
      PLSTEMP->(DbCloseArea())
      PlsPtuLog("num.imp. ["+cNumImp+"]")
      
      aadd(aCab,{"NUMIMP",cNumImp})   
      aadd(aCab,{"CHKREG",.F.})     // NAO CHECA REGRAS, POIS ERA AUDITORIA E FOI AUTORIZADO
      aRet := PLSXAUTP(aCab,aIte)
      PLSFechaSem(nH)
      PlsPtuLog("**********************************************")
      If aRet[1]   // autorizou
         EnviaEmail(aCab,aIte,aRet,.t.)
         PlsPtuPut("ID_CONFIRM","S",aDados)
         PlsPtuLog("*** AUTORIZADO ***")      
      Else  // nao autorizou               
         EnviaEmail(aCab,aIte,aRet,.f.)
         PlsPtuPut("ID_CONFIRM","X",aDados)
         PlsPtuLog("*** NAO AUTORIZADO ***")      
         For nI := 1 to Len(aRet[4])
            If nI > 5
               Exit
            EndIf
            PlsPtuLog("ERRO ["+aRet[4,nI,2]+"]")
         Next   
      EndIf
   Else
      PlsPtuLog("**********************************************")
      EnviaEmail(aCab,aIte,,.f.)
      PlsPtuPut("ID_CONFIRM","X",aDados)
      PlsPtuLog("*** NAO AUTORIZADO ***")      
      PlsPtuLog("Faltando a senha da operadora")      
   EndIf
   PlsPtuLog("**********************************************")

   
EndIf

If ElapTime(cTimeIni,Time()) > cTimeOut // verifica se do momento que entrou ate o atual passou mais que o tempo estipulado para timeout
   PlsPtuLog("*********************")
   PlsPtuLog("TIMEOUT ")
   PlsPtuLog("*********************")
   lTimeOut := .T.   // variavel que define que houve TIMEOUT
EndIf

Return

User Function PlsEndPtu()
Local cDriveProc := ParamIxb[1]
Local cPathOut := ParamIxb[2]
Local cPathIn  := ParamIxb[3]
Local aFilesP
Local nTotFiles
Local nI
Local cExtArq := ""  // usado quando SCS2
Local cUniDom := ""  // usado quando SCS2

aFilesP := Directory(cDriveProc+cPathOut+'*.*')
 
makedir(cPathOut+"\OUT")
For nI := 1 to len(aFilesP)
   fErase(cPathIn+aFilesP[nI][1])
   fErase(cPathOut+"out\"+aFilesP[nI][1])
   PlsPtuLog("copy file de => "+cPathOut+aFilesP[nI][1])
   PlsPtuLog("copy file para => "+cPathOut+"out\"+aFilesP[nI][1])
   __CopyFile(cPathOut+aFilesP[nI][1],cPathOut+"out\"+aFilesP[nI][1])
   If fREname(cDriveProc+cPathOut+aFilesP[nI][1] , cPathIn+aFilesP[nI][1] )#-1
      PlsPtuLog("renomeado para "+cPathIn+aFilesP[nI][1])
   EndIf   

/*
tirar este bloco depoois
   If lSCS2
      cExtArq := StrZero(Val(SubStr(aFilesP[nI][1],Rat(".",aFilesP[nI][1]))),3)
      cUniDom := Upper("UNI"+cExtArq)
      WinExec(cPathSCS2+"\cliente\client2.exe -a "+cUniDom+" -u 0"+cExtArq+" "+aFilesP[nI][1]+" "+aFilesP[nI][1])
      FErase(cPathIn+"PRO_"+aFilesP[nI][1])
      PlsPtuLog("********* Executando client SCS2 ********************")
      PlsPtuLog(cPathSCS2+"\cliente\client2.exe -a "+cUniDom+" -u 0"+cExtArq+" "+aFilesP[nI][1]+" "+aFilesP[nI][1])
      PlsPtuLog("Apagando arquivo = "+cPathIn+"PRO_"+aFilesP[nI][1])
      PlsPtuLog("********* fim comando *******************************")
      
   EndIf
*/
Next

Return

User Function PlsArqPtu()
Local cPathIn := ParamIxb[1]
Local aFiles := {}
Local aFilPro
Local nI
Local cExtensao := ""
aFilPro := Directory(cPathIn+'*.*')
If !Empty(cPathSCS2)
   // no SCS2 o arquivo que esta sendo processado fica na pasta de entrada e para que 
   // ele nao entre em processo novamente e' criado um arquivo com as iniciais PRO_ e o restante
   // Eduardo Motta - 11/08/2004
   For nI := 1 to len(aFilPro)
      cExtensao := SubStr(aFilPro[nI,1],Rat(".",aFilPro[nI,1])+1)
      If cExtensao == SubStr(PlsIntPad(),2)  // se a origem for da propria unimed nao procesa
         Loop
      EndIf   
      aadd(aFiles,aClone(aFilPro[nI]))
   Next
Else
   aFiles := aClone(aFilPro)   
EndIf
Return aFiles

Static Function MsgErro(cCod)
Local aErro := {}
Local nPos
Local cRet
Local cCodOpe := PlsIntPad()

If Empty(cCod)
   Return "0000"
EndIf

BCT->(DbSetOrder(1))
If !BCT->(DbSeek(xFilial()+cCodOpe+cCod)) .or. Empty(BCT->BCT_CODEDI)
   cRet := "3212"
Else
   cRet:= StrZero(Val(BCT->BCT_CODEDI),4)
EndIf
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSPTUENV ³ Autor ³ Eduardo Motta         ³ Data ³ 23.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de entrada executado apos geracao do arquivo de envio³±±
±±³          ³ do PTU ONLINE.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PLS                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PlsPtuEnv()           
Local cUniDom
Local cNameFile := ParamIxb[1]
If PlsSCS2()
   cUniDom := "0"+PlsPtuGet("CD_UNI",aDados)
   WinExec(GetNewPar("MV_PTUSCS","")+"\cliente\client2.exe -a UNI"+SubStr(cUniDom,2)+" -u "+cUniDom+" "+cNameFile)
EndIf   
Return



Static Function EnviaEmail(aCab,aIte,aRet,lAutorizado,lAuditoria)
Local cFrom       := "microsiga@unimedbotucatu.com.br"
Local cServer     := AllTrim(GetNewPar("MV_RELSERV"," "))//servidor de email
Local cAccount    := AllTrim(GetNewPar("MV_RELACNT"," ")) // conta
Local cPassword   := AllTrim(GetNewPar("MV_RELPSW" ," ")) // senha
Local nTimeOut    := GetMv("MV_RELTIME",,120) //Tempo de Espera antes de abortar a Conexão
Local lAutentica  := GetMv("MV_RELAUTH",,.F.) //Determina se o Servidor de Email necessita de Autenticação
Local cUserAut    := Alltrim(GetMv("MV_RELAUSR",,cAccount)) //Usuário para Autenticação no Servidor de Email
Local cPassAut    := Alltrim(GetMv("MV_RELAPSW",,cPassword)) //Senha para Autenticação no Servidor de Email
Local cTo         := "debora@unimedbotucatu.com.br"
Local cCC         := space(200)
Local cSubject    := "PTUONLINE-Auditoria"
Local cBody       := ""
Local lOk         := .t.
Local cCodUsu     := ""
Local cCodRDA     := ""
Local cCodSOL     := ""
Local dData
Local nI
DEFAULT lAuditoria := .f.

PlsPtuLog("Enviando email para "+cTo)

cCodUsu  := AllTrim(cCodInt)+PadR(PlsPtuGet("USUARIO",aCab),13)
cCodRDA  := PadR(PlsPtuGet("CODRDA",aCab),13)
cCodSOL  := PadR(PlsPtuGet("CDPFSO",aCab),13)
dData    := PlsPtuGet("DATPRO",aCab)
BAU->(DbSetOrder(1))
BAU->(DbSeek(xFilial("BAU")+cCodRDA))
BB0->(DbSetOrder(1))
BB0->(DbSeek(xFilial("BB0")+cCodSol))
BA1->(DbSetOrder(5))
If !BA1->(DbSeek(xFilial("BA1")+cCodInt+cCodUsu))
   BA1->(DbSeek(xFilial("BA1")+SubStr(cCodInt,2)+cCodUsu))
EndIf
If lAutorizado
   cBody := Chr(13)+Chr(10)+"Num.da Guia : "+aRet[2]
   cBody += Chr(13)+Chr(10)+"Usuario     : "+cCodUsu+"   ["+BA1->(BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)+"] "+BA1->BA1_NOMUSR
   cBody += Chr(13)+Chr(10)+"Prestador   : "+cCodRDA+" "+BAU->BAU_NOME
   cBody += Chr(13)+Chr(10)+"Solicitante : "+cCodSol+" "+BB0->BB0_NOME
   cBody += Chr(13)+Chr(10)+"CID         : "+PlsPtuGet("CIDPRI",aCab)
   cBody += Chr(13)+Chr(10)+"Data da Solicitacao : "+DtoC(dData)
   For nI := 1 to Len(aIte)
      cBody += Chr(13)+Chr(10)+Chr(13)+Chr(10)+"Procedimento : "+PlsPtuGet("CODPAD",aIte[nI])+"."+PlsPtuGet("CODPRO",aIte[nI])
//      cBody += Chr(13)+Chr(10)+"Quantidade   : "+Str(PlsPtuGet("QTD",aIte[nI]),3)
   Next
Else
   If !lAuditoria
      cBody := "Guia nao autorizada "
   Else
      cBody := "Solicitacao em auditoria "
   EndIf   
   cBody += Chr(13)+Chr(10)+"Usuario     : "+cCodUsu+"   ["+BA1->(BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)+"] "+BA1->BA1_NOMUSR
   cBody += Chr(13)+Chr(10)+"Prestador   : "+cCodRDA+" "+BAU->BAU_NOME
   cBody += Chr(13)+Chr(10)+"Solicitante : "+cCodSol+" "+BB0->BB0_NOME
   cBody += Chr(13)+Chr(10)+"CID         : "+PlsPtuGet("CIDPRI",aCab)
   cBody += Chr(13)+Chr(10)+"Data da Solicitacao : "+DtoC(dData)
   For nI := 1 to Len(aIte)
      cBody += Chr(13)+Chr(10)+Chr(13)+Chr(10)+"Procedimento : "+PlsPtuGet("CODPAD",aIte[nI])+"."+PlsPtuGet("CODPRO",aIte[nI])
//      cBody += Chr(13)+Chr(10)+"Quantidade   : "+Str(PlsPtuGet("QTD",aIte[nI]),3)
   Next
   If !lAuditoria
      cBody += Chr(13)+Chr(10)+"Motivo"
      If aRet # NIL
         For nI := 1 to Len(aRet[4])
            If !Empty(aRet[4,nI,2])
               cBody += Chr(13)+Chr(10)+"Erro : "+aRet[4,nI,2]+" "+MsgErro(aRet[4,nI,2])
            EndIf
         Next
      Else
         cBody += Chr(13)+Chr(10)+"nao foi enviada a senha de autorizacao da operadora"
      EndIf
   EndIf   
EndIf

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword TIMEOUT nTimeOut Result lOk
If lOk
   If lAutentica
      If !MailAuth(cUserAut,cPassAut)
         PlsPtuLog("ERRO: Falha na Autenticação do Usuário")
         DISCONNECT SMTP SERVER RESULT lOk
         IF !lOk
            GET MAIL ERROR cErrorMsg
            PlsPtuLog("ERRO: Erro na Desconexão: "+cErrorMsg)
         ENDIF   
         Return .F.
      EndIf
   EndIf 
   If !Empty(cCC)
      SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody Result lOk
   Else
      SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody Result lOk
   EndIf
   If !lOk                       
      GET MAIL ERROR cErrorMsg
      PlsPtuLog("Erro no envio")
      PlsPtuLog("Server: "+cServer)
      PlsPtuLog("Account: "+cAccount)
      PlsPtuLog("PassWord: "+cPassword)
      PlsPtuLog("From: "+cFrom)
      PlsPtuLog("To: "+cTo)
      PlsPtuLog("CC: "+cCC)
      PlsPtuLog("Subject: "+cSubject)
      PlsPtuLog("Body: "+cBody)
      PlsPtuLog("Mensagem de erro: "+cErrorMsg)
   EndIf
Else
   GET MAIL ERROR cErrorMsg
   PlsPtuLog("Erro na conexao")
   PlsPtuLog("Server: "+cServer)
   PlsPtuLog("Account: "+cAccount)
   PlsPtuLog("PassWord: "+cPassword)
   PlsPtuLog("Mensagem de erro: "+cErrorMsg)
EndIf
DISCONNECT SMTP SERVER RESULT lOk
IF !lOk
   GET MAIL ERROR cErrorMsg
   PlsPtuLog("Erro na Desconexão: "+cErrorMsg)
ENDIF   

Return .T.

Static Function Seg2Time(nSeg)
Local cHora
Local nHor := 0
Local nMin := 0
nHor := Int(nSeg / 3600)
nSeg -= (nHor * 3600)
nMin := Int(nSeg / 60)
nSeg -= (nHor * 60)
cHora := StrZero(nHor,2)+":"+StrZero(nMin,2)+":"+StrZero(nSeg,2)
Return cHora

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS090PT  ³ Autor ³ Eduardo Motta         ³ Data ³ 16.02.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de entrada executado logo apos retorno do PTUONLINE  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³pls090PT()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Pls090PT()
Local aCab := ParamIxb[1]
Local aIte := ParamIxb[2]
Local lOk  := ParamIxb[3]
Local cCodErro := PlsPtuGet("ERRO01",aCab)
PlsPtuLog("*** PONTO DE ENTRADA PLS090PT *********")
PlsPtuLog("Erro "+cCodErro)
If cCodErro == "1095"
   EnviaEmail(aCab,aIte,NIL,lOK,.T.)
EndIf   


Return
