#INCLUDE "HSPAHM22.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM22  บ Autor ณ Rogerio Faro       บ Data ณ Novembro/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescricao ณ Detalhamento de Recebimento de Contas (Atendimentos)         บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHM22()
 Private aRotina
 Private cCadastro, cHspSerie := AllTrim(GetMV("MV_HSPSERIE"))
 Private cFiltro := "E1_SERIE == '" + cHspSerie + "'"
 Private aCores
 
 aCores := {{"SE1->E1_SALDO == SE1->E1_VALOR"                       , 'BR_VERDE'   }, ;
           	{"SE1->E1_SALDO > 0 .And. SE1->E1_SALDO < SE1->E1_VALOR", 'BR_AMARELO' }, ;
          	{"SE1->E1_SALDO == 0"                                   , 'BR_VERMELHO'}}

 aRotina := {{OemtoAnsi(STR0001) 	, "axPesqui"   , 0, 1	}, ; //"Pesquisar"
             {OemToAnsi(STR0002)	, "HS_AHM22(2)", 0, 2	}, ; //"Visualizar"
             {OemToAnsi(STR0003)	, "HS_AHM22(4)", 0, 4, 2}, ; //"Detalhar Baixa"
             {OemtoAnsi(STR0004)	, "HS_LEGM22  ", 0, 1	}}   //"Legenda"
                     
 cCadastro := STR0005 //"Detalhamento do recebimento das contas"

 DbSelectArea("SE1")
 DbSetOrder(1)

 HS_AtvFilt("SE1", cFiltro)
 mBrowse(06, 01, 22, 75, "SE1",,,,,, aCores)
 HS_DtvFilt("SE1")
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ HS_AHM22 บ Autor ณ Rogerio Faro     บ Data ณ Novembro/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para montagem do browse de sele็ใo de contas        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_AHM22(nOpc)
 Local bCampo  := {|nCPO| Field(nCPO)}
 Local nCntFor := 0, nOpcA := 0, nUsado := 0, aAlter := {}

 Private aHeader := {}, aCols := {}
 
 If nOpc == 4 // Alterar
  nOpcG := 3
 ElseIf nOpc == 2 // Visualizar
  nOpcG := 2
 endif

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Cria variaveis M->????? da GetDados                          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 aAlter := {"nValBai"}

 aAdd(aHeader, {STR0006, "cRegAte", "@!"            , 06, 0, ".F.", "", "C", "XXX", "V", "", ""})  //"Reg. Atendimento"
 aAdd(aHeader, {STR0007, "cNomPac", "@!"            , 40, 0, ".F.", "", "C", "XXX", "V", "", ""})  //"Nome Paciente"
 aAdd(aHeader, {STR0008, "nValCnt", "@E 999,999.99" , 09, 2, ".F.", "", "N", "XXX", "V", "", ""})  //"Valor Conta"
 aAdd(aHeader, {STR0009, "nValRec", "@E 999,999.99" , 09, 2, ".F.", "", "N", "XXX", "V", "", ""})  //"Recebido"
 aAdd(aHeader, {STR0010, "nValSal", "@E 999,999.99" , 09, 2, ".F.", "", "N", "XXX", "V", "", ""})  //"A Receber"
 nUsado := 5
 If nOpc # 2
  aAdd(aHeader,{STR0011     , "nValBai", "@E 999,999.99" , 09, 2, "HS_VldM22()", "", "N", "XXX", "R", "", ""}) //"Valor Baixa"
  pValBai := aScan(aHeader, {| aVet | aVet[2] == "nValBai"})
  nUsado++
 Endif
 
 pRegAte := aScan(aHeader, {| aVet | aVet[2] == "cRegAte"})
 pNomPac := aScan(aHeader, {| aVet | aVet[2] == "cNomPac"})
 pValCnt := aScan(aHeader, {| aVet | aVet[2] == "nValCnt"})
 pValSal := aScan(aHeader, {| aVet | aVet[2] == "nValSal"})
 pValRec := aScan(aHeader, {| aVet | aVet[2] == "nValRec"})

 If nOpc # 3 // se nao for inclusao
  For nCntFor := 1 TO FCount()
   M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
  Next
 Endif

 DbSelectArea("GAD")
 DbSetOrder(27)
 DBGotop()
 DbSeek(xFilial("GAD") + SE1->E1_SERIE + SE1->E1_NUM)
 While GAD->GAD_FILIAL == xFilial("GAD") .And. GAD->GAD_SERIE == SE1->E1_SERIE .And. GAD_TITULO == SE1->E1_NUM .And. !Eof()
  aAdd(aCols, Array(nUsado + 1))
  aCols[Len(aCols), pRegAte] := GAD->GAD_REGATE
  aCols[Len(aCols), pNomPac] := GAD->GAD_NOME
  aCols[Len(aCols), pValCnt] := GAD->GAD_VALCNT
  aCols[Len(aCols), pValSal] := (GAD->GAD_VALCNT - GAD->GAD_VLRREC)
  aCols[Len(aCols), pValRec] := GAD->GAD_VLRREC
  If nOpc # 2
   aCols[Len(aCols), pValBai] := 0
  EndIf
  aCols[Len(aCols), nUsado + 1] := .F.
  DbSkip()
 Enddo

 If !len(aCols) > 0
  MsgStop(STR0012, STR0013) //"Nใo existem contas para este tํtulo!!!"###"Aten็ใo"
  Return(Nil)
 EndIf 
 
 cTitulo := OemToAnsi(STR0014 + SE1->E1_NUM + STR0015 + SE1->E1_SERIE + STR0016 + Transform((SE1->E1_VALOR - SE1->E1_SALDO), "@E 9,999,999.99")) //"Detalhamento das contas que pertencem ao titulo: "###"  S้rie: "###" no total de: "

 DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,95 Of oMainWnd 
  oGetDados := MsGetDados():New(015, 001, 143, 375, nOpcG,,,, .F., aAlter)
  oGetDados:oBrowse:bAdd    := {|| }
 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(FS_VldBaixa(), oDlg:End(), .F.)}, {|| nOpcA := 0, oDlg:End()})

 If nOpca == 1
  GrvHSM22()
 EndIf
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrvHSM22()บ Autor ณ Rogerio Faro       บ Data ณ  Mar/2004   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gravacao dos valores digitados                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GrvHSM22()
 Local nCnt := 0
 If nOpcG # 2 // nao for consulta
  For nCnt := 1 to len(aCols)
   DbSelectArea("GAD")
   DbSetOrder(1)
   DbSeek(xFilial("GAD") + aCols[nCnt, pRegAte])
   RecLock("GAD", .F.)
   If aCols[nCnt, pValRec] > 0
    GAD->GAD_VLRREC  := aCols[nCnt, pValRec]
    GAD->GAD_DATREC  := dDataBase

    IF aCols[nCnt, pValRec] < GAD->GAD_VALCNT
     GAD->GAD_STATUS  := "4"
    ElseIF aCols[nCnt, pValRec] >= GAD->GAD_VALCNT
     GAD->GAD_STATUS  := "5"
    Endif

   Endif
   MsUnlock()                  
  Next   
 Endif   
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDGET บ Autor ณ Rogerio Faro       บ Data ณ  Nov/2003   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao de valor digitado                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VldM22()
 Local lRet := .T.

 If M->nValBai > acols[n,pValSal]
  acols[n,pValSal] := acols[n,pValSal] + acols[n,pValBai]
  acols[n,pValRec] := acols[n,pValRec] - acols[n,pValBai]

  MsgStop(STR0017 + Transform(M->nValBai, "@E 9,999,999.99") + STR0018 + Transform(acols[n,pValSal], "@E 9,999,999.99") + ")" ,STR0013) //"Valor digitado ("###") ้ superior ao valor devido ("###"Aten็ใo"
  lRet := .F.  
 Else 
  acols[n,pValSal] := acols[n,pValSal] + acols[n,pValBai]
  acols[n,pValRec] := acols[n,pValRec] - acols[n,pValBai]

  acols[n,pValSal] := acols[n,pValSal] - M->nValBai
  acols[n,pValRec] := acols[n,pValRec] + M->nValBai
 Endif
 
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDbaixaบAutor ณ Rogerio Faro       บ Data ณ  Nov/2003   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao de valor digitado                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldBaixa()
 Local lRet := .T., nCnt, nVal := 0

 For nCnt := 1 to Len(Acols)
  nVal += aCols[nCnt, pValRec]
 Next

 If nVal > (SE1->E1_VALOR - SE1->E1_SALDO)
  MsgStop(STR0019 + Transform(nVal, "@E 9,999,999.99") + STR0020 + Transform((SE1->E1_VALOR - SE1->E1_SALDO), "@E 9,999,999.99") + ")" ,STR0013) //"Valores distribuidos nas contas ("###") ้ superior ao valor pago ("###"Aten็ใo"
  lRet := .F.  
 ElseIF nVal < (SE1->E1_VALOR - SE1->E1_SALDO)
  MsgStop(STR0019 + Transform(nVal, "@E 9,999,999.99") + STR0021 + Transform((SE1->E1_VALOR - SE1->E1_SALDO), "@E 9,999,999.99") + ")" ,STR0013) //"Valores distribuidos nas contas ("###") ้ inferior ao valor pago ("###"Aten็ใo"
  lRet := .F.
 Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_LEGM22 บ Autor ณ Rogerio Faro       บ Data ณ  Nov/2003   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para exibi็ใo das Legendas                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_LEGM22()
 BrwLegenda(cCadastro, STR0004, {	{'BR_VERDE'   , STR0022  }, ;  //"Legenda"###"Tํtulo em Aberto"
	                             	{'BR_AMARELO' , STR0023	}, ;   //"Recebido Parcial"
                                 	{'BR_VERMELHO', STR0024	}})   //"Recebido Total"
Return(.T.)