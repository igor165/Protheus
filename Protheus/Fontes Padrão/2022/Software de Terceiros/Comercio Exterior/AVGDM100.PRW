#INCLUDE "AVERAGE.CH"
#INCLUDE "AVGDM100.CH"
#INCLUDE "EEC.CH"        

// ****************************************************************//
// Programa....: AVGDM100.PRW
// Programador.: Alessandro Alves Ferreira - AAF
// Data........: 28 de Janeiro de 2005
// Objetivo....: Envio do Demurrage para o Cambio
//*****************************************************************//

#DEFINE TP_EXP "E"
#DEFINE TP_IMP "I"

#DEFINE PESQUISAR  1
#DEFINE VISUALIZAR 2
#DEFINE ENVIAR     3
#DEFINE ESTORNAR   4

//***********************************************//
//Função......: AVGDM100.PRW                     
//Programador.: Alessandro Alves Ferreira - AAF  
//Objetivo....: Envio do Demurrage para o Cambio 
//Data........: 28/01/05 - 17:00
//Revisão.....: 16/11/05 - 17:30 - Envio do Demurrage para o câmbio da importação.
//***********************************************//
Function AVGDM100()
//***********************************************//
nRatDem := EasyGParam("MV_RATDEM",,1)

dbSelectArea("EG0")
EG0->( dbSetOrder(1) )

If ! (   EG0->( FieldPos( "EG0_DEMURR" ) ) > 0 .AND. EG1->( FieldPos( "EG1_DEMURR" ) ) > 0;
   .AND. EG2->( FieldPos( "EG2_DEMURR" ) ) > 0 .AND. EG2->( FieldPos( "EG2_TP_LD"  ) ) > 0;
   .AND. EG0->( FieldPos( "EG0_NEG_VL" ) ) > 0 .AND. EG0->( FieldPos( "EG0_VCT"    ) ) > 0;
   .AND. EG0->( FieldPos( "EG0_CLIENT" ) ) > 0 .AND. EG0->( FieldPos( "EG0_CLILOJ" ) ) > 0;
   .AND. EG0->( FieldPos( "EG0_NEG_TP" ) ) > 0 )

   MsgStop(STR0023,STR0008)//"Os Dicionários estão desatualizados. Necessária atualização no sistema para execução desta rotina."###"Aviso"
   Return .F.
Endif

If nModulo == 29
   //Exportação
   aRotina:= {}
   aAdd(aRotina,{STR0001 ,"AxPesqui"  ,0,1,})//"Pesquisar"
   aAdd(aRotina,{STR0002 ,"DM100EXP"  ,0,2,})//"Visualizar"
   aAdd(aRotina,{STR0003 ,"DM100EXP"  ,0,4,})//"Envio Finan."
   aAdd(aRotina,{STR0019 ,"DM100EXP"  ,0,5,})//"Estorno"
   
ElseIf nModulo == 17
   //AAF 16/11/05 - Importação
   aRotina:= {}
   aAdd(aRotina,{STR0001 ,"AxPesqui"  ,0,1,})//"Pesquisar"
   aAdd(aRotina,{STR0002 ,"DM100IMP"  ,0,2,})//"Visualizar"
   aAdd(aRotina,{STR0003 ,"DM100IMP"  ,0,4,})//"Envio Finan."
   aAdd(aRotina,{STR0019 ,"DM100IMP"  ,0,5,})//"Estorno"
Endif

//Filtro para MBrowse - Importação/Exportação
If nModulo == 17
   EG0->(DBSetFilter( {|| EG0->EG0_MODULO == TP_IMP}, "EG0->EG0_MODULO == 'I'"))
Elseif nModulo == 29
   EG0->(DBSetFilter( {|| EG0->EG0_MODULO == TP_EXP}, "EG0->EG0_MODULO == 'E'"))
Endif

MBrowse(0,0,0,0,"EG0",NIL,NIL,NIL,NIL,3,NIL,NIL,NIL,02)

Return .T.

//**********************************************************//
//Função.....: DM100EXP(cAlias,nRec,nTipo)
//Programador: Alessandro Alves Ferreira - AAF
//Objetivo...: Envio do Demurrage para Cambio da Exportação.
//Data.......: 29/01/05 - 08:50
//**********************************************************//
Function DM100EXP(cAlias,nRec,nTip)
//**********************************************************//

DM100MAN(cAlias,nRec,nTip,TP_EXP)

Return .T.

//**********************************************************//
//Função.....: DM100IMP(cAlias,nRec,nTipo)
//Programador: Alessandro Alves Ferreira - AAF
//Objetivo...: Envio do Demurrage para Cambio da Importação.
//Data.......: 16/11/05 - 17:40
//**********************************************************//
Function DM100IMP(cAlias,nRec,nTip)
//**********************************************************//

DM100MAN(cAlias,nRec,nTip,TP_IMP)

Return .T.

//**********************************************************//
//Função.....: DM100MAN(cAlias,nRec,nTipo,cModulo)
//Programador: Alessandro Alves Ferreira - AAF
//Objetivo...: Envio do Demurrage para Cambio IMP/EXP.
//Data.......: 29/01/05 - 08:50
//Revisão....: 16/11/05 - 17:39
//**********************************************************//
Function DM100MAN(cAlias,nRec,nTip,cModulo)
//**********************************************************//
Local i
Private cFilEG1 := xFilial("EG1")
Private nReg    := nRec
Private nTipo   := nTip
Private aHeader := {}
Private aCols   := {}
Private aFiliais
Private nVlTotal:= 0, nVlNeg := 0, nPesoToT:= 0, nParidade:= 0
Private lFilOri

If cModulo == TP_EXP
   aFiliais := AvgSelectFil(.F.,"EEQ")
   
   Private cFilEEQ := xFilial("EEQ")
   Private cFilEE9 := xFilial("EE9")
   Private cFilEEC := xFilial("EEC")
   
   lFilOri := SX3->( dbSeek("EG1_FILORI") ) .AND. Posicione("SX2",1,"EEC","X2_MODO") == "E"
ElseIf cModulo == TP_IMP
   aFiliais := AvgSelectFil(.F.,"SWB")
   
   Private cFilSW8 := xFilial("SW8")
   Private cFilSW9 := xFilial("SW9")   
   Private cFilSWA := xFilial("SWA")
   Private cFilSWB := xFilial("SWB")
         
   SWA->( dbSetOrder(1) )//WA_FILIAL+WA_HAWB+WA_PO_DI
   
   lFilOri := SX3->( dbSeek("EG1_FILORI") ) .AND. Posicione("SX2",1,"SW6","X2_MODO") == "E"
Endif

SX3->( dbSetOrder(2) )

Begin Sequence
   
   If nTipo == ENVIAR .AND. DM100VCamb(EG0->EG0_DEMURR,.T.,cModulo)//Processo já enviado 
      BREAK
   Endif
   
   If nTipo == ESTORNAR .AND. !DM100VCamb(EG0->EG0_DEMURR,.F.,cModulo)
      MsgStop(STR0020,STR0008)//"Demurrage não foi enviado ao financeiro"###"Aviso"
      BREAK
   Endif
   
   If Empty(EG0->EG0_NEG_VL) .AND. EG0->EG0_NEG_TP $ "1/2"
      MsgInfo(STR0004)//"Demurrage não possui valor negociado"
      BREAK
   Endif
   
   If Empty(EG0->EG0_VCT)
      MsgInfo(STR0018)//"Demurrage não possui data de vencimento"
      BREAK
   Endif
   
   cTitMoe := "("+EG0->EG0_MOEDA+")"
   
   //Campos do GetDados
   If lFilOri
      aAdd(aHeader,{ AVSX3("EG1_FILORI",5), "EG1_FILORI", AVSX3("EG1_FILORI",6), AVSX3("EG1_FILORI",3), AVSX3("EG1_FILORI",4), /*VALIDACAO*/, NIL, AVSX3("EG1_FILORI",2), NIL,NIL } )
   Endif
   aAdd(aHeader,{ AVSX3("EG1_EMBARQ",5), "EG1_EMBARQ", AVSX3("EG1_EMBARQ",6), AVSX3("EG1_EMBARQ",3), AVSX3("EG1_EMBARQ",4), /*VALIDACAO*/, NIL, AVSX3("EG1_EMBARQ",2), NIL,NIL } )
   aAdd(aHeader,{ AVSX3("EG1_NRINVO",5), "EG1_NRINVO", AVSX3("EG1_NRINVO",6), AVSX3("EG1_NRINVO",3), AVSX3("EG1_NRINVO",4), /*VALIDACAO*/, NIL, AVSX3("EG1_NRINVO",2), NIL,NIL } )
   aAdd(aHeader,{ AVSX3("EG1_QTDMT",5) , "EG1_QTDMT" , AVSX3("EG1_QTDMT",6) , AVSX3("EG1_QTDMT" ,3), AVSX3("EG1_QTDMT",4) , /*VALIDACAO*/, NIL, AVSX3("EG1_QTDMT",2) , NIL,NIL } )
   //aAdd(aHeader,{ "Moeda Processo"     , "MOEDAEM"   , AVSX3("EG1_MOEDA",6) , AVSX3("EG1_MOEDA" ,3), AVSX3("EG1_MOEDA",4) , /*VALIDACAO*/, NIL, AVSX3("EG1_MOEDA",2), NIL,NIL } )//"Moeda Processo"
   //aAdd(aHeader,{ "Vl. Moeda Proc."    , "VL_PRECOEM", AVSX3("EG0_NEG_VL",6), AVSX3("EG0_NEG_VL",3), AVSX3("EG0_NEG_VL",4), /*VALIDACAO*/, NIL, AVSX3("EG0_NEG_VL",2), NIL,NIL } )//"Vl. na Moeda Proc."
   aAdd(aHeader,{ STR0005+cTitMoe      , "VL_PRECOEM", AVSX3("EG0_NEG_VL",6), AVSX3("EG0_NEG_VL",3), AVSX3("EG0_NEG_VL",4), /*VALIDACAO*/, NIL, AVSX3("EG0_NEG_VL",2), NIL,NIL } )//"Valor no Demurrage"
   aAdd(aHeader,{ STR0006              , "EG0_NEG_VL", AVSX3("EG0_NEG_VL",6), AVSX3("EG0_NEG_VL",3), AVSX3("EG0_NEG_VL",4),'DM100AltRat()',NIL, AVSX3("EG0_NEG_VL",2), NIL,NIL } )//"Valor Rateado"
   
   //Grava as Linhas
   EG1->( dbSetOrder(1) )
   EG1->( dbSeek(cFilEG1+cModulo+EG0->EG0_DEMURR) )
   Do While !EG1->( EoF() ) .AND. EG1->( EG1_FILIAL+EG1_MODULO+EG1_DEMURR ) == cFilEG1+cModulo+EG0->EG0_DEMURR
      
      If cModulo == TP_EXP
         //Procura o Embarque nas linhas já gravadas.
         cProcura := AvKey(EG1->EG1_EMBARQ,"EE9_PREEMB")
         nPos     := aScan(aCols,{|X| X[GDFieldPos("EG1_EMBARQ")] == cProcura})
         
         //Preço do item no processo
         nValor := Posicione("EE9",2,;
                   iIf(lFilOri,EG1->EG1_FILORI,cFilEE9)+EG1->( AVKey(EG1_EMBARQ,"EE9_PREEMB")+EG1_PEDIDO+EG1_SEQUEN ),;
                   "EE9_PRECO") * EG1->EG1_QTDUC
         
      ElseIf cModulo == TP_IMP
         If !SWA->( dbSeek( if(lFilOri,EG1->EG1_FILORI,cFilSWA)+AVKey(EG1->EG1_EMBARQ,"W8_HAWB")+"D" ) )
            MsgStop(STR0027;//"Não é possível enviar Demurrage, pois existem processos sem controle de câmbio."
            +"("+AllTrim(TransForm(EG1->EG1_EMBARQ,AvSx3("W8_HAWB",6)))+")")
            BREAK
         Endif
         
         //Procura o Embarque+Invoice nas linhas já gravadas.
         cProcura := AvKey(EG1->EG1_EMBARQ,"W8_HAWB")+AvKey(EG1->EG1_NRINVO,"W9_INVOICE")
         nPos     := aScan(aCols,{|X| X[GDFieldPos("EG1_EMBARQ")]+X[GDFieldPos("EG1_NRINVO")] == cProcura})
         
         //Preço do item na Invoice
         nValor := Posicione("SW8",6,;
                   iIf(lFilOri,EG1->EG1_FILORI,cFilSW8)+EG1->( AVKey(EG1_EMBARQ,"W8_HAWB")+AVKey(EG1_NRINVO,"W8_INVOICE")+;
                   AVKey(EG1_PEDIDO,"W8_PO_NUM")+AVKey(EG1_SEQUEN,"W8_POSICAO") ),;
                   "W8_PRECO") * EG1->EG1_QTDUC
         
      Endif
      //**
      
      If nPos > 0
         //Soma para o Mesmo Embarque/Embarque+Invoice
         aCols[nPos][GDFieldPos("EG1_QTDMT")] += EG1->EG1_QTDMT
         
         //If nRatDem == 1
            aCols[nPos][GDFieldPos("VL_PRECOEM")] += nValor * nParidade
         //Endif
      Else
         //Adiciona uma nova linha para este Embarque/Embarque+Invoice
         aAdd( aCols,Array(Len(aHeader)+1) )
         
         If lFilOri
            aCols[Len(aCols)][GDFieldPos("EG1_FILORI")] := EG1->EG1_FILORI
         Endif
         
         aCols[Len(aCols)][GDFieldPos("EG1_EMBARQ")] := AvKey(EG1->EG1_EMBARQ,If(cModulo == TP_EXP,"EE9_PREEMB","W8_HAWB"   ))
         aCols[Len(aCols)][GDFieldPos("EG1_NRINVO")] := AvKey(EG1->EG1_NRINVO,If(cModulo == TP_EXP,"EEQ_NRINVO","W9_INVOICE"))
         aCols[Len(aCols)][GDFieldPos("EG1_QTDMT" )] := EG1->EG1_QTDMT
         aCols[Len(aCols)][GDFieldPos("EG0_NEG_VL")] := 0
         
         If cModulo == TP_EXP
            cMoeda:= Posicione("EEC",1,iIf(lFilOri,EG1->EG1_FILORI,cFilEEC)+AVKey(EG1->EG1_EMBARQ,"EE9_PREEMB"),"EEC_MOEDA")
         ElseIf cModulo == TP_IMP
            SW9->( dbSetOrder(1) )
            SW9->( dbSeek(if(lFilOri,EG1->EG1_FILORI,cFilSW9)+AVKey(EG1->EG1_NRINVO,"W9_INVOICE")) )
            Do While !SW9->( EoF() ) .AND. SW9->( W9_FILIAL+W9_INVOICE ) == if(lFilOri,EG1->EG1_FILORI,cFilSW9)+AVKey(EG1->EG1_NRINVO,"W9_INVOICE")
               
               If SW9->W9_HAWB == AvKey(EG1->EG1_EMBARQ,"W9_HAWB")
                  cMoeda:= SW9->W9_MOE_FOB
                  EXIT
               EndIf
               
               SW9->( dbSkip() )
            EndDo
         Endif
         
         nParidade := BuscaTaxa(cMoeda,dDataBase) / BuscaTaxa(EG0->EG0_MOEDA,dDataBase)
         aCols[Len(aCols)][GDFieldPos("VL_PRECOEM")] := nValor * nParidade
         
         //Marca como não deletado
         aCols[Len(aCols)][Len(aHeader)+1] := .F.
      Endif
      
      nVlTotal+= nValor * nParidade
      EG1->( dbSkip() )
   EndDo
   
   If Len(aCols) == 0
      MsgStop(STR0007,STR0008)//"Não há embarques relacionados a este demurrage."###"Aviso"
   Else
      DM100RAT(cModulo)
   Endif
   
End Sequence

Return .T.

//*********************************************************//
//Função.....: DM100RAT()
//Programador: Alessandro Alves Ferreira - AAF
//Objetivo...: Rateio do Demurrage por Embarques Exportação
//Data.......: 29/01/05 - 13:05
//Revisão....: 17/11/05 - 14:47 - Importação.
//*********************************************************//
Function DM100RAT(cModulo)
//*********************************************************//
Local i
Local nVlRateio := 0
Local lOK := .F.
Local cDemurr

nVlNeg := EG0->EG0_NEG_VL
nPesToT:= EG0->EG0_PARC_C
If nTipo == ENVIAR
   For i:= 1 To Len(aCols)
      If i < Len(aCols)
         If nRatDem == 1 //Rateio Por Valor
            aCols[i][GDFieldPos("EG0_NEG_VL")] := nVlNeg * aCols[i][GDFieldPos("VL_PRECOEM")] / nVlTotal
         ElseIf nRatDem == 2 //Rateio Por Peso
            aCols[i][GDFieldPos("EG0_NEG_VL")] := nVlNeg * aCols[i][GDFieldPos("EG1_QTDMT")] / nPesToT
         Endif
      Else
         aCols[Len(aCols)][GDFieldPos("EG0_NEG_VL")] := nVlNeg - nVlRateio
      Endif
   
      nVlRateio += aCols[i][GDFieldPos("EG0_NEG_VL")]
   Next
Else
   If cModulo == TP_EXP
      EEQ->( dbSetOrder(5) )
   ElseIf cModulo == TP_IMP
      SWB->( dbSetOrder(5) )
   Endif
   
   If cModulo == TP_EXP
      For i:= 1 To Len(aCols)      
         If EEQ->( dbSeek(If(lFilOri,aCols[i][GDFieldPos("EG1_FILORI")],cFilEEQ)+aCols[i][GDFieldPos("EG1_NRINVO")]+'131') ) .OR.;
            EEQ->( dbSeek(If(lFilOri,aCols[i][GDFieldPos("EG1_FILORI")],cFilEEQ)+aCols[i][GDFieldPos("EG1_NRINVO")]+'132') )
         
            aCols[i][GDFieldPos("EG0_NEG_VL")] := EEQ->EEQ_VL
         Endif
      Next
   ElseIf cModulo == TP_IMP
      cDemurr := AvKey(EG0->EG0_DEMURR,"WB_NUMPO")
      For i:= 1 To Len(aFiliais)
         SWB->( dbSetOrder(5) )//WB_FILIAL+WB_NUMPO
         SWB->( dbSeek(aFiliais[i]+cDemurr) )
         Do While !SWB->( EoF() ) .AND. SWB->( WB_FILIAL+WB_NUMPO ) == aFiliais[i]+cDemurr
            nPosA := aScan(aCols,{|X| If(lFilOri,X[GDFieldPos("EG1_FILORI")],cFilSWB)+X[GDFieldPos("EG1_EMBARQ")]+X[GDFieldPos("EG1_NRINVO")] == ;
                                      SWB->( WB_FILIAL+WB_HAWB+WB_INVOICE ) })
            If nPosA > 0
               aCols[nPosA][GDFieldPos("EG0_NEG_VL")] := SWB->WB_FOBMOE
            Endif
            
            SWB->( dbSkip() )
         EndDo
      Next
   Endif
Endif

aAdd(aCols,Array(Len(aHeader)+1))

aCols[Len(aCols)][1] := STR0009//"Total:"
aCols[Len(aCols)][GDFieldPos("EG1_QTDMT")] := nPesToT
aCols[Len(aCols)][GDFieldPos("VL_PRECOEM")]:= nVlTotal
aCols[Len(aCols)][GDFieldPos("EG0_NEG_VL")]:= nVlNeg

DEFINE MSDIALOG oDlg TITLE STR0010 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL//"Envio do Demurrage para Financeiro"

aCampos := {"EG0_DEMURR","EG0_REVER","EG0_NAVIO","EG0_VIAGEM","EG0_DEST","EG0_TIPO","EG0_FORNEC","EG0_FORLOJ","EG0_CLIENT","EG0_CLILOJ","EG0_MOEDA","EG0_NEG_TP","EG0_NEG_VL"}

oEnch     := MsMGet():New("EG0",nReg,2,NIL,NIL,NIL,aCampos,{14,1,100,DLG_COL_FIM/2-2},{}, NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,.T.)
oEnch:oBox:Align := CONTROL_ALIGN_TOP

oGetDados := MsGetDados():New(101, 01, DLG_LIN_FIM/2-47, DLG_COL_FIM/2-2, 3,/*LinOk*/,/*TudoOk*/,/*cIniCpos*/,.F.,If(nTipo==ENVIAR,{"EG0_NEG_VL"},{}),/*reservado*/,/*lEmpty*/,1000,/*fieldok*/,/*superdel*/,/*Reservado*/,/*delok*/, oDlg)
oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oGetDados:oBrowse:bAdd := {||.F.}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| iIf( DM100VALRAT(), ( lOK:= .T., oDlg:End() ), )},{||oDlg:End()},,) CENTERED

If lOK
   If nTipo == ENVIAR
      Processa({||DM100GParc(cModulo)},STR0011) //"Gerando parcelas de cambio no financeiro..."
   ElseIf nTipo == ESTORNAR
      Processa({||DM100EstParc(cModulo)},STR0022) //"Estornando parcelas de cambio no financeiro..."
   Endif
Endif

Return .T.

//**************************************************************//
//Função.....: DM100AltRat()
//Programador: Alessandro Alves Ferreira - AAF
//Objetivo...: Atualizar o valor total rateado
//Data.......: 31/01/05 - 16:50
//**************************************************************//
Function DM100AltRat()
Local nAlterado
Local lRet := .T.

If n < Len(aCols)
   nAlterado := M->EG0_NEG_VL - aCols[n][GDFieldPos("EG0_NEG_VL")]
   aCols[Len(aCols)][GDFieldPos("EG0_NEG_VL")] := aCols[Len(aCols)][GDFieldPos("EG0_NEG_VL")] + nAlterado
Else
   lRet := .F.
Endif

Return lRet

//**************************************************************//
//Função.....: DM100VALRAT()
//Programador: Alessandro Alves Ferreira - AAF
//Objetivo...: Validar a alteração do valor do rateio do Demurrage
//Data.......: 29/01/05 - 13:05
//**************************************************************//
Function DM100VALRAT()
//**************************************************************//
Local lRet     := .T.

If nTipo == ENVIAR
   If aCols[Len(aCols)][GDFieldPos("EG0_NEG_VL")] <> nVlNeg
      If MsgYesNo(STR0012+;//"Valor total do rateio difere do valor negociado, deseja alterar o valor negociado para "
                   EG0->EG0_MOEDA + " " + AllTrim(TransForm(aCols[Len(aCols)][GDFieldPos("EG0_NEG_VL")],AVSX3("EG0_NEG_VL",6))) + " ?",STR0008 )//"Aviso"
         nVlNeg := aCols[Len(aCols)][GDFieldPos("EG0_NEG_VL")]
      Else
         lRet := .F.
      Endif
   Endif
ElseIf nTipo == ESTORNAR
   lRet:= MsgYesNo(STR0021,STR0008)//"Confirma o estorno dos eventos de Demurrage do Financeiro?"###"Aviso"
Endif

Return lRet

//**************************************************************//
//Função.....: DM100GParc()
//Programador: Alessandro Alves Ferreira - AAF
//Objetivo...: Gerar Parcelas de Cambio para o Demurrage.
//Data.......: 29/01/05 - 13:05
//**************************************************************//
Function DM100GParc(cModulo)
//**************************************************************//
Local i
Local cEvento, cTipo
ProcRegua(Len(aCols))
IncProc(STR0011) //"Gerando parcelas de cambio no financeiro..."

Begin Transaction
   
   //Acerta o Valor Negociado caso tenha sido alterado
   If EG0->EG0_NEG_VL <> nVlNeg
      RecLock("EG0",.F.)
      EG0->EG0_NEG_VL := nVlNeg
      EG0->( MsUnLock() )
      EG0->( dbCommit() )
   Endif
   
   If cModulo == TP_EXP
      
      //Gera Evento de Acordo com Resultado Negociado
      If EG0->EG0_NEG_TP == "1"
         //Tipo 1 = Demurrage
         If Empty(EG0->EG0_CLIENT)
            //Cliente Vazio (Demurrage a Pagar)
            cEvento := '131'
            cTipo   := 'P' //Cambio a Pagar
         Else
            //Cliente Preenchido (Demurrage a Receber)
            cEvento := '132'
            cTipo   := 'R' //Cambio a Receber
         Endif
      Else
         //Tipo 2 = Despatch
         If Empty(EG0->EG0_CLIENT)
            //Cliente Vazio (Despatch a Receber)
            cEvento := '132'
            cTipo   := 'R' //Cambio a Receber
         Else
            //Cliente Preenchido (Despatch a Pagar)
            cEvento := '131'
            cTipo   := 'P' //Cambio a Pagar
         Endif
      Endif
   
      //Gera as Parcelas de Demurrage/Despatch no câmbio da Exportação
      For i:= 1 To Len(aCols) - 1
         EEC->( dbSeek(iIf(lFilOri,aCols[i][GDFieldPos("EG1_FILORI")],cFilEEC)+aCols[i][GDFieldPos("EG1_EMBARQ")]) )
         
         nLastParc:= 0
         //Busca a ultima parcela gravada para esse processo
         //Parcela não pode se repetir para o mesmo processo mesmo em evento diferente
         EEQ->( dbSetOrder(1) )
         EEQ->( dbSeek(iIf(lFilOri,aCols[i][GDFieldPos("EG1_FILORI")],cFilEEQ)+aCols[i][GDFieldPos("EG1_EMBARQ")]) )
         Do While !EEQ->( EoF() ) .AND. EEQ->EEQ_FILIAL == iIf(lFilOri,aCols[i][GDFieldPos("EG1_FILORI")],cFilEEQ) .AND. EEQ->EEQ_PREEMB == aCols[i][GDFieldPos("EG1_EMBARQ")]
            nLastParc := Max( Val(EEQ->EEQ_PARC),nLastParc )
            EEQ->( dbSkip() )
         EndDo
         
         lTpCon := EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .AND. EEQ->( FieldPos("EEQ_FASE"  ) ) > 0 .AND. ;
                   EEQ->( FieldPos("EEQ_TIPO"  ) ) > 0 .AND. EC6->( FieldPos("EC6_RECDES") ) > 0
         
         RecLock("EEQ",.T.)
         EEQ->EEQ_FILIAL := If(lFilOri, aCols[i][GDFieldPos("EG1_FILORI")], cFilEEQ)
         EEQ->EEQ_EVENT  := cEvento
         EEQ->EEQ_PREEMB := aCols[i][GDFieldPos("EG1_EMBARQ")]
         EEQ->EEQ_NRINVO := aCols[i][GDFieldPos("EG1_NRINVO")]
         EEQ->EEQ_PARC   := StrZero( nLastParc + 1, 2 )
         EEQ->EEQ_VCT    := EG0->EG0_VCT
         EEQ->EEQ_MOEDA  := EG0->EG0_MOEDA
         EEQ->EEQ_PARI   := BuscaTaxa(EG0->EG0_MOEDA,dDataBase) / BuscaTaxa(EEC->EEC_MOEDA,dDataBase)
         EEQ->EEQ_VL     := aCols[i][GDFieldPos("EG0_NEG_VL")]
         EEQ->EEQ_FAOR   := OC_DEM
         EEQ->EEQ_PROR   := EG0->EG0_DEMURR
         
         If lTpCon
            EC6->( dbSetOrder(1) )
            EC6->( dbSeek(xFilial("EC6")+"EXPORT"+cEvento) )
            
            EEQ->EEQ_TP_CON := If(cTipo == "R", "3", "4")           // 3 - Receber e 4 - Pagar.
            EEQ->EEQ_FASE   := If(cTipo == "R", "3", "4")           // 3 - Receber e 4 - Pagar.
            EEQ->EEQ_TIPO   := If(Empty(EC6->EC6_RECDES),cTipo,If(EC6->EC6_RECDES == "1", "R", "P"))// R - Receber e P - Pagar.
         Else
            EEQ->EEQ_FASE   := OC_EM
            EEQ->EEQ_TIPO   := cTipo
         EndIf
         
         if(EEQ->( FieldPos("EEQ_FORN"  ) ) > 0, EEQ->EEQ_FORN   := EG0->EG0_FORNEC, )
         if(EEQ->( FieldPos("EEQ_FOLOJA") ) > 0, EEQ->EEQ_FOLOJA := EG0->EG0_FORLOJ, )
         if(EEQ->( FieldPos("EEQ_IMPORT") ) > 0, EEQ->EEQ_IMPORT := EG0->EG0_CLIENT, )
         if(EEQ->( FieldPos("EEQ_IMLOJA") ) > 0, EEQ->EEQ_IMLOJA := EG0->EG0_CLILOJ, )
         
         EEQ->( MsUnLock() )
         IncProc()
      Next
      EEQ->( dbCommit() )
      
   ElseIf cModulo == TP_IMP
      
      //Gera Evento de Acordo com Resultado Negociado
      If EG0->EG0_NEG_TP == "1"
         //Tipo 1 = Demurrage
         If Empty(EG0->EG0_CLIENT)
            //Cliente Vazio (Demurrage a Pagar)
            cTipo   := '4' //Cambio a Pagar
         Else
            //Cliente Preenchido (Demurrage a Receber)
            cTipo   := '3' //Cambio a Receber
         Endif
      Else
         //Tipo 2 = Despatch
         If Empty(EG0->EG0_CLIENT)
            //Cliente Vazio (Despatch a Receber)
            cTipo   := '3' //Cambio a Receber
         Else
            //Cliente Preenchido (Despatch a Pagar)
            cTipo   := '4' //Cambio a Pagar
         Endif
      Endif
      
      //Gera as Parcelas de Demurrage/Despatch no câmbio da Importação.
      For i:= 1 To Len(aCols) - 1
         
         nLastLinha:= 0
         //Busca a ultima linha gravada para esse processo
         SWB->( dbSetOrder(1) )
         SWB->( dbSeek(iIf(lFilOri,aCols[i][GDFieldPos("EG1_FILORI")],cFilSWB)+aCols[i][GDFieldPos("EG1_EMBARQ")]) )
         Do While !SWB->( EoF() ) .AND. SWB->WB_FILIAL == iIf(lFilOri,aCols[i][GDFieldPos("EG1_FILORI")],cFilSWB) .AND. SWB->WB_HAWB == aCols[i][GDFieldPos("EG1_EMBARQ")]
            nLastLinha := Max( Val(SWB->WB_LINHA),nLastLinha )
            SWB->( dbSkip() )
         EndDo
         
         RecLock("SWB",.T.)
         SWB->WB_FILIAL  := If(lFilOri, aCols[i][GDFieldPos("EG1_FILORI")], cFilSWB)
         SWB->WB_TIPO    := 'DEMURRAGE'
         SWB->WB_HAWB    := aCols[i][GDFieldPos("EG1_EMBARQ")]
         SWB->WB_INVOICE := aCols[i][GDFieldPos("EG1_NRINVO")]
         SWB->WB_TIPOREG := 'D'
         SWB->WB_DT_VEN  := EG0->EG0_VCT
         SWB->WB_FOBMOE  := aCols[i][GDFieldPos("EG0_NEG_VL")]
         SWB->WB_CA_TX   := BuscaTaxa(EG0->EG0_MOEDA,dDataBase)
         SWB->WB_PO_DI   := "D"
         SWB->WB_LINHA   := StrZero( nLastLinha + 1, AvSX3("WB_LINHA",3) )
         SWB->WB_MOEDA   := EG0->EG0_MOEDA
         SWB->WB_FORN    := EG0->EG0_FORNEC
         SWB->WB_LOJA    := EG0->EG0_FORLOJ
         SWB->WB_TP_CON  := cTipo
         SWB->WB_NUMPO   := EG0->EG0_DEMURR
         
         SWB->( MsUnLock() )
         IncProc()
      Next  
      SWB->( dbCommit() )
   Endif
   
End Transaction

Return .T.

//*************************************************************************//
//Função.....: DM100EstParc()
//Programador: Alessandro Alves Ferreira - AAF
//Objetivo...: Estorna o Demurrage do Cambio da Exportação.
//Data.......: 01/04/05 - 17:15
//Revisão....: 17/11/05 - 15:54
//*************************************************************************//
Function DM100EstParc(cModulo)
Local nInd, cEvento, aRecNo:= {}, aPagas := {}
ProcRegua(Len(aCols))
IncProc(STR0022) //"Estornando parcelas de cambio no financeiro..."

Begin Transaction
   
   If cModulo == TP_EXP
      //Procura Evento de Acordo com Resultado Negociado
      If EG0->EG0_NEG_TP == "1"
         //Tipo 1 = Demurrage
         If Empty(EG0->EG0_CLIENT)
            //Cliente Vazio (Demurrage a Pagar)
            cEvento := '131'
         Else
            //Cliente Preenchido (Demurrage a Receber)
            cEvento := '132'
         Endif
      Else
         //Tipo 2 = Despatch
         If Empty(EG0->EG0_CLIENT)
            //Cliente Vazio (Despatch a Receber)
            cEvento := '132'
         Else
            //Cliente Preenchido (Despatch a Pagar)
            cEvento := '131'
         Endif
      Endif
   
      //Exclui as Parcelas de Demurrage/Despatch do câmbio da exportação.
      For nInd:= 1 To Len(aCols) - 1
         
         cFil    := If(lFilOri, aCols[nInd][GDFieldPos("EG1_FILORI")], cFilEEQ)
      cNrInvo := Avkey(aCols[nInd][GDFieldPos("EG1_NRINVO")],"EEQ_NRINVO")
         
         EEQ->( dbSetOrder(5) )
         EEQ->( dbSeek(cFil+cNrInvo+cEvento) )
         Do While !EEQ->( EoF() ) .AND. EEQ->EEQ_FILIAL == cFil .AND.;
                                        EEQ->EEQ_NRINVO == cNrInvo .AND.;
                                        EEQ->EEQ_EVENT  == cEvento
         
            If Empty(EEQ->EEQ_PGT)
               aAdd(aRecNo,EEQ->( RecNo() ))
            Else
               aAdd(aPagas,STR0025 + EEQ->EEQ_NRINVO + STR0026 + EEQ->EEQ_PARC)//"Invoice: "###" Parcela: "
            Endif
            
            EEQ->( dbSkip() )
         EndDo
      Next
   
      If Len(aPagas) > 0
         cMsg:= STR0024 + Chr(10) + Chr(13) + Chr(10) + Chr(13)//"Demurrage não pode ser estornado pois já possui parcelas pagas."
         For nInd:= 1 To Len(aPagas)
            cMsg+= aPagas[nInd] + Chr(10) + Chr(13)
         Next
         
         MsgStop(cMsg,STR0008)//"Aviso"
         BREAK
      Endif
   
      For nInd := 1 To Len(aRecNo)
         EEQ->( dbGoTo(aRecNo[nInd]) )
         If !EEQ->( EoF() )
            EEQ->( RecLock("EEQ",.F.), dbDelete(), MsUnLock() )
            IncProc()
         Endif
      Next
      
      EEQ->( dbCommit() )

   ElseIf cModulo == TP_IMP

      For nInd:= 1 To Len(aFiliais)
         SWB->( dbSeek(aFiliais[nInd]+AvKey(EG0->EG0_DEMURR,"WB_NUMPO")) )
         Do While !SWB->( EoF() ) .AND. SWB->( WB_FILIAL+WB_NUMPO ) == aFiliais[nInd]+AvKey(EG0->EG0_DEMURR,"WB_NUMPO")
            If Empty(SWB->WB_CA_DT)
               aAdd(aRecNo,SWB->( RecNo() ))
            Else
               aAdd(aPagas,"Processo: "+SWB->WB_HAWB+"Invoice: "+SWB->WB_INVOICE)//"Processo: "###"Invoice: "
            Endif
            
            SWB->( dbSkip() )
         EndDo
      Next
      
      If Len(aPagas) > 0
         cMsg:= STR0024 + Chr(10) + Chr(13) + Chr(10) + Chr(13)//"Demurrage não pode ser estornado pois já possui parcelas pagas."
         For nInd:= 1 To Len(aPagas)
            cMsg+= aPagas[nInd] + Chr(10) + Chr(13)
         Next
         
         MsgStop(cMsg,STR0008)//"Aviso"
         BREAK
      Endif
   
      For nInd := 1 To Len(aRecNo)
         SWB->( dbGoTo(aRecNo[nInd]) )
         If !SWB->( EoF() )
            SWB->( RecLock("SWB",.F.), dbDelete(), MsUnLock() )
            IncProc()
         Endif
      Next
      
      SWB->( dbCommit() )
   EndIf
   
End Transaction

Return .T.

//*************************************************************************//
//Função.....: DM100VCamb(cDemurrage,lMsg)
//Parametros.: cDemurrage: Processo de Demurrage a ser verificado no cambio.
//             lMsg......: Indica se será exibida mensagem de aviso.
//Programador: Alessandro Alves Ferreira - AAF
//Objetivo...: Verifica se o demurrage já foi enviado ao cambio.
//Data.......: 01/02/05 - 15:45
//*************************************************************************//
Function DM100VCamb(cDemurrage,lMsg,cModulo)
//*************************************************************************//
Local i
Local aOrd
Local lRet:= .F.
Default lMsg:= .F.
Default cModulo:= TP_EXP

If cModulo == TP_EXP
   aFiliais := AvgSelectFil(.F.,"EEQ")
   aOrd:= SaveOrd({"EEQ"})
   EEQ->( dbSetOrder(7) )

   For i:= 1 To Len(aFiliais)
      If EEQ->( dbSeek(aFiliais[i]+OC_DEM+AvKey(cDemurrage,"EEQ_PROR")) )
         lRet := .T.
         If lMsg
            MsgInfo(STR0013)//"Demurrage já enviado para o financeiro"
         Endif
         EXIT
      Endif
   Next
ElseIf cModulo == TP_IMP
   aFiliais := AvgSelectFil(.F.,"SWB")
   aOrd:= SaveOrd({"SWB"})
   SWB->( dbSetOrder(5) )//WB_FILIAL+WB_NUMPO
   
   For i:= 1 To Len(aFiliais)
      If SWB->( dbSeek(aFiliais[i]+AvKey(cDemurrage,"WB_NUMPO")) )
         lRet := .T.
         If lMsg
            MsgInfo(STR0013)//"Demurrage já enviado para o financeiro"
         Endif
         EXIT
      Endif
   Next
EndIf

RestOrd(aOrd)
Return lRet

//**************************************************************//
//Função.....: DM100PosDem()
//Programador: Alessandro Alves Ferreira - AAF
//Objetivo...: Posicionar no Demurrage.
//Data.......: 21/11/05 - 15:57
//Obs........: Chamado do AVGDM100 e EICAP100.
//**************************************************************//
Function DM100PosDem(cCodDem,cModulo)
//**************************************************************//
Local aFiliais := AvgSelectFil(.F.,"EG0")
Local lRet     := .F.
Local i

//Busca o Processo de Demurrage.
For i:= 1 To Len(aFiliais)
   If EG0->( dbSeek(aFiliais[i]+cModulo+AvKey(cCodDem,"EG0_DEMURR")) )
      lRet:= .T.
      EXIT
   Endif
Next

Return lRet

//*** SOMENTE EXPORTAÇÃO ***

   //***********************************************************************//
   //Função.....: DM100ValCamb()
   //Programador: Alessandro Alves Ferreira - AAF
   //Objetivo...: Valida alteração no valor da parcela de cambio do demurrage.
   //Data.......: 01/02/05 - 15:45
   //Obs........: Chamado do EECAF200
   //***********************************************************************//
   Function DM100ValCamb()
   //***********************************************************************//
   Local cMsg   := ""
   Local aOrd   := SaveOrd( {"EEQ","EG0"} )
   Local cFilEEQ:= xFilial("EEQ")
   Local i
   Local lRet   := .T.
   Local nVlNeg := 0
   Local lPrim := .T.
   
   Begin Sequence
      
      //Valida apenas ao alterar o campo EEQ_VL
      If ReadVar() <> "M->EEQ_VL"
         BREAK
      Endif
      
      //Procura o Demurrage em Todas as Filiais
      DM100PosDem(M->EEQ_PROR,"E")
      
      EEQ->( dbSetOrder(1) )
      EEQ->( dbSeek(xFilial("EEQ")+M->EEQ_PREEMB+M->EEQ_PARC) )
      
      nVlNeg:= EG0->EG0_NEG_VL + (M->EEQ_VL - EEQ->EEQ_VL)
      
      cMsg  := STR0014+;//"A soma das parcelas do demurrage difere do valor negociado. Deseja alterar o valor negociado do demurrage para "
               AllTrim(M->EEQ_MOEDA +" "+AllTrim(TransForm(nVlNeg,AVSX3("EG0_NEG_VL",6))))+" ?"+Chr(13)+Chr(10)
      
      //Busca Parcelas do Demurrage
      aFiliais := AvgSelectFil(.F.,"EEQ")
      EEQ->( dbSetOrder(7) )
      For i:= 1 To Len(aFiliais)
         EEQ->( dbSeek(aFiliais[i]+OC_DEM+AvKey(EG0->EG0_DEMURR,"EEQ_PROR")) )
         Do While !EEQ->( EoF() ) .AND. EEQ->EEQ_FILIAL == aFiliais[i] .AND. EEQ->EEQ_FAOR == OC_DEM .AND.;
                   EEQ_PROR == AvKey(EG0->EG0_DEMURR,"EEQ_PROR")
            
            If EEQ->EEQ_FILIAL+EEQ->EEQ_PREEMB+EEQ->EEQ_PARC <> cFilEEQ+M->EEQ_PREEMB+M->EEQ_PARC
               If lPrim
                  cMsg+= STR0015+Chr(13)+Chr(10)//"Valor das outras Parcelas deste Demurrage: "
                  lPrim := .F.
               Endif
               cMsg += EEQ->EEQ_PREEMB + EEQ->EEQ_MOEDA +" "+AllTrim(TransForm(EEQ->EEQ_VL,AVSX3("EG0_NEG_VL",6)))+Chr(13)+Chr(10)
            Endif

            EEQ->( dbSkip() )
         EndDo
      Next
      
      lRet := MsgYesNo(cMsg)
   End Sequence
   
   RestOrd(aOrd)
   Return lRet

   //**************************************************************//
   //Função.....: DM100GrvDem()
   //Programador: Alessandro Alves Ferreira - AAF
   //Objetivo...: Gravação do Valor Negociado do Demurrage alterado
   //............ Nas parcelas de Cambio da Exportação.
   //Data.......: 01/02/05 - 15:45
   //Obs........: Chamado do EECAF200
   //**************************************************************//
   Function DM100GrvDem()
   //**************************************************************//
   Local i
   Local cFilEEQ:= xFilial("EEQ")
   
   aFiliais := AvgSelectFil(.F.,"EG0")
   aOrd:= SaveOrd({"EEQ"})
   
   EG0->( dbSetOrder(1) )
   EEQ->( dbSetOrder(7) )
   For i:= 1 To Len(aDemurrage)
      dPrimData := CtoD('  /  /  ')
      nNegVl    := 0
      
      EEQ->( dbSeek(cFilEEQ+OC_DEM+aDemurrage[i]) )
      Do While EEQ->( !EoF() ) .AND. EEQ->( EEQ_FILIAL+EEQ_FAOR+EEQ_PROR ) == cFilEEQ+OC_DEM+aDemurrage[i]
         If !Empty(EEQ->EEQ_PGT)
            dPrimData := iif(Empty(dPrimData),EEQ->EEQ_PGT,Min(EEQ->EEQ_PGT,dPrimData))
         Endif
         
         nNegVl += EEQ->EEQ_VL
         EEQ->( dbSkip() )
      EndDo
      
      DM100PosDem(aDemurrage[i],"E")
      
      RecLock("EG0",.F.)
      EG0->EG0_PGT    := dPrimData
      EG0->EG0_NEG_VL := nNegVl
      EG0->( MsUnLock() )
   Next
   
   RestOrd(aOrd)
   Return .T.

   //**************************************************************//
   //Função.....: DM100EstDem()
   //Programador: Alessandro Alves Ferreira - AAF
   //Objetivo...: Gravação do Valor Negociado do Demurrage alterado
   //............ Nas parcelas de Cambio da Exportação.
   //Data.......: 01/02/05 - 15:45
   //Obs........: Chamado do EECAF200
   //**************************************************************//
   Function DM100EstDem()
   //**************************************************************//
   Local cMsg, i
   
   aFiliais := AvgSelectFil(.F.,"EG0")
   
   //Busca o Processo de Demurrage.
   For i:= 1 To Len(aFiliais)
      If EG0->( dbSeek(aFiliais[i]+"E"+AvKey(TMP->EEQ_PROR,"EG0_DEMURR")) )
         EXIT
      Endif
   Next
   
   cMsg := STR0016+;//"Excluindo está parcela de demurrage, o valor negociado para o processo de demurrage "
           AllTrim(EG0->EG0_DEMURR) + STR0017 + EG0->EG0_MOEDA + " " +Alltrim(TransForm(EG0->EG0_NEG_VL - TMP->EEQ_VL,AVSX3("EG0_NEG_VL",6)))//" será alterado para "
   
   Return MsgYesNo(cMsg,STR0008)//"Aviso"
   
//***

//*** SOMENTE IMPORTAÇÃO ***

   //***********************************************************************//
   //Função.....: DM100ValImp()
   //Programador: Alessandro Alves Ferreira - AAF
   //Objetivo...: Valida alteração no valor da parcela de cambio do demurrage.
   //Data.......: 21/11/05 - 11:40
   //Obs........: Chamado do EICAP100
   //***********************************************************************//
   Function DM100ValImp()
   //***********************************************************************//
   Local cMsg   := ""
   Local aOrd   := SaveOrd( {"SWB","EG0"} )
   Local cFilSWB:= xFilial("SWB")
   Local i
   Local lRet   := .T.
   Local nVlNeg := 0
   Local lPrim  := .T.
   Local nPos
   
   Begin Sequence
      
      //Valida apenas ao alterar o campo WB_FOBMOE
      If ReadVar() <> "M->WB_FOBMOE"
         BREAK
      Endif
      
      //Procura o Demurrage em Todas as Filiais
      DM100PosDem(M->WB_NUMPO,"I")     
      
      SWB->( dbSetOrder(1) )//WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA
      SWB->( dbSeek(xFilial("SWB")+M->WB_HAWB+M->WB_PO_DI+M->WB_INVOICE+M->WB_FORN+M->WB_LOJA) )
      Do While !SWB->( EoF() ) .AND. SWB->( WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA ) ==;
                                       M->( WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA )
         If SWB->WB_LINHA == M->WB_LINHA
            EXIT
         EndIf
         
         SWB->( dbSkip() )
      EndDo
      
      If (nPos:= aScan(aDemurrage,{|X| X[1] == M->WB_NUMPO})) == 0
         nVlNeg:= EG0->EG0_NEG_VL + (M->WB_FOBMOE - TRB->WB_FOBMOE)
      Else
         nVlNeg:= aDemurrage[nPos][2] + (M->WB_FOBMOE - TRB->WB_FOBMOE)
      Endif
      
      cMsg  := STR0014+;//"A soma das parcelas do demurrage difere do valor negociado. Deseja alterar o valor negociado do demurrage para "
               AllTrim(M->WB_MOEDA +" "+AllTrim(TransForm(nVlNeg,AVSX3("EG0_NEG_VL",6))))+" ?"+Chr(13)+Chr(10)
      
      //Busca Parcelas do Demurrage      
      aFiliais   := AvgSelectFil(.F.,"SWB")
      cDemurrage := AvKey(EG0->EG0_DEMURR,"WB_NUMPO")
      
      SWB->( dbSetOrder(5) )//WB_FILIAL+WB_NUMPO
      For i:= 1 To Len(aFiliais)
         
         //Procura todas as parcelas deste demurrage.
         SWB->( dbSeek(aFiliais[i]+AvKey(EG0->EG0_DEMURR,"WB_NUMPO")) )
         Do While !SWB->( EoF() ) .AND. SWB->( WB_FILIAL+WB_NUMPO )  == aFiliais[i]+cDemurrage
            If SWB->( WB_FILIAL+WB_HAWB ) <> cFilSWB+M->WB_HAWB
               If lPrim
                  cMsg+= STR0015+Chr(13)+Chr(10)//"Valor das outras Parcelas deste Demurrage: "
                  lPrim := .F.
               Endif
               cMsg += SWB->WB_HAWB + SWB->WB_MOEDA +" "+AllTrim(TransForm(SWB->WB_FOBMOE,AVSX3("EG0_NEG_VL",6)))+Chr(13)+Chr(10)
            Endif
            
            SWB->( dbSkip() )
         EndDo
         
      Next i
      
      lRet := MsgYesNo(cMsg)
   End Sequence
   
   RestOrd(aOrd)
   Return lRet
   
   //**************************************************************//
   //Função.....: DM100GrvImp()
   //Programador: Alessandro Alves Ferreira - AAF
   //Objetivo...: Gravação do Valor Negociado do Demurrage alterado
   //............ Nas parcelas do Cambio da Importação.
   //Data.......: 21/11/05 - 11:53
   //Obs........: Chamado do EICAP100
   //**************************************************************//
   Function DM100GrvImp()
   //**************************************************************//
   Local i
   Local cFilSWB:= xFilial("SWB")
   
   aFiliais := AvgSelectFil(.F.,"EG0")
   aOrd:= SaveOrd({"SWB"})
   
   EG0->( dbSetOrder(1) )
   SWB->( dbSetOrder(5) )
   For i:= 1 To Len(aDemurrage)
      dPrimData := CtoD('  /  /  ')
      nNegVl    := 0
      
      SWB->( dbSeek(cFilSWB+aDemurrage[i][1]) )
      Do While SWB->( !EoF() ) .AND. SWB->( WB_FILIAL+WB_NUMPO ) == cFilSWB+aDemurrage[i][1]
         If !Empty(SWB->WB_CA_DT)
            dPrimData := iif(Empty(dPrimData),SWB->WB_CA_DT,Min(SWB->WB_CA_DT,dPrimData))
         Endif
         
         nNegVl += SWB->WB_FOBMOE
         SWB->( dbSkip() )
      EndDo
      
      DM100PosDem(aDemurrage[i][1],"I")
            
      RecLock("EG0",.F.)
      EG0->EG0_PGT    := dPrimData
      EG0->EG0_NEG_VL := nNegVl
      EG0->( MsUnLock() )
   Next
   
   RestOrd(aOrd)
   Return .T.

   //**************************************************************//
   //Função.....: DM100EstImp()
   //Programador: Alessandro Alves Ferreira - AAF
   //Objetivo...: Gravação do Valor Negociado do Demurrage alterado
   //............ Nas parcelas de Cambio da Importação.
   //Data.......: 21/11/05 - 11:55
   //Obs........: Chamado do EICAP100
   //**************************************************************//
   Function DM100EstImp()
   //**************************************************************//
   Local cMsg, i, nPos, lRet

   DM100PosDem(TRB->WB_NUMPO,"I")
   
   If (nPos := aScan(aDemurrage,{|X| X[1] == TRB->WB_NUMPO})) == 0
      nVlNeg := EG0->EG0_NEG_VL
   Else
      nVlNeg := aDemurrage[nPos][2]
   Endif
   
   cMsg := STR0016+;//"Excluindo está parcela de demurrage, o valor negociado para o processo de demurrage "
           AllTrim(EG0->EG0_DEMURR) + STR0017 + EG0->EG0_MOEDA + " " +Alltrim(TransForm(nVlNeg - TRB->WB_FOBMOE,AVSX3("EG0_NEG_VL",6)))//" será alterado para "
   
   lRet:= MsgYesNo(cMsg,STR0008)//"Aviso"
   
   If lRet .AND. nPos > 0
      aDemurrage[nPos][2] -= TRB->WB_FOBMOE
   Endif
   
   Return lRet
//***
