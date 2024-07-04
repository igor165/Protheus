#include "EEC.CH" 
#include "AVFRM102.CH" 
#include "MSOBJECT.CH"

/* 
Programa   : DetBkEquipment()
Objetivo   : Agrupa containeres com mesmas caracteristicas para 
             impressão do Booking, na integração com o Inttra.
Autor      : Eduardo C. Romanini
Data/Hora  : 29/08/2007 às 15:00
Obs        : 
*/
*------------------------------*
Function DetBkEquipment(cPreemb)
*------------------------------*
Local aEquip := {}
Local aOrd   := SaveOrd({"EX9"})

Local nPos   := 0
Local nQtde  := 0

Begin Sequence

   EX9->(DbSetOrder(1))
   If EX9->(DbSeek(xFilial("EX9")+AvKey(cPreemb,"EX9_PREEMB")))
      While EX9->(!EOF()) .and. EX9->(EX9_FILIAL+EX9_PREEMB) == xFilial("EX9")+AvKey(cPreemb,"EX9_PREEMB")
      
         nPos := aScan(aEquip,{|e| e[1]+e[3]+e[4] == EX9->EX9_TIPO+If(EX9->EX9_ENVTMP == "1", Str(EX9->EX9_TEMP), "")+If(EX9->EX9_ENVTMP == "1", Str(EX9->EX9_VENT), "")})
        
         If nPos > 0
         
            aEquip[nPos][2] += 1
         
         Else

            nQtde := 1
         
            aAdd(aEquip,({EX9->EX9_TIPO     ,;  //Tipo do Container
                          nQtde             ,;  //Quantidade
                          If(EX9->EX9_ENVTMP == "1", Str(EX9->EX9_TEMP), ""),;  //Temperatura
                          If(EX9->EX9_ENVTMP == "1", Str(EX9->EX9_VENT), "")})) //Ventilação
         
         EndIf
      
         EX9->(DbSkip())
      EndDo
   Else
      //Se não tiver sido incluído nenhum container, utiliza a previsão informada no EXL
      If !Empty(EXL->EXL_TIPCON) .And. EXL->EXL_QTDCON > 0
         aAdd(aEquip,({EXL->EXL_TIPCON   ,;  //Tipo do Container
                       EXL->EXL_QTDCON   ,;  //Quantidade
                       ""                ,;  //Temperatura
                       ""                })) //Ventilação
      EndIf
   EndIf

End Sequence

RestOrd(aOrd, .T.)

Return aEquip


/*
Programa   : DetPackages() 
Objetivo   : Agrupa itens com mesma embalagem externa e estufados no mesmo container.
Autor      : Eduardo C. Romanini
Data/Hora  : 29/08/2007 às 15:00
Obs        : 
*/
*--------------------------------------*
Function DetPackages(cPreemb)
*--------------------------------------*
Local aPack    := {}
Local aEmbSup  := {}
Local aOrd     := SaveOrd({"EYH", "EE9"})
Local cProd    := ""
Local cSeqEmb  := ""
Local cEmbSup  := ""
Local cIdCont  := ""

Local nPos     := 0, nInc
Local nQtdeEmb := 0
Local nQtdeIt  := 0

Begin Sequence

   EYH->(DbSetOrder(2))
   If EYH->(DbSeek(xFilial("EYH")+"S"+AvKey(cPreemb,"EYH_PREEMB")))
      While EYH->(!EOF()) .and. EYH->(EYH_FILIAL+EYH_ESTUF+EYH_PREEMB) == xFilial("EYH")+"S"+AvKey(cPreemb,"EYH_PREEMB")
         If !Empty(EYH->EYH_SEQEMB)
            
            //Identificação do item
            cProd   := EYH->EYH_COD_I
            cSeqEmb := EYH->EYH_SEQEMB
            
            //Quantidade de Produdos
            nQtdeIt  := EYH->EYH_QTDEMB
            
            //Busca a embalagem mais externa
            aEmbSup  := BuscaEmbSup(cPreemb,EYH->EYH_IDVINC)
            
            cEmbSup  := aEmbSup[1]
            nQtdeEmb := aEmbSup[2]
            cIdCont  := aEmbSup[3]
         
            nPos := aScan(aPack,{|e| e[1]+e[2]+e[3]+e[5] == cSeqEmb+cProd+cEmbSup+cIdCont}) 

            If nPos > 0
            
               aPack[nPos][4] += nQtdeEmb
               aPack[nPos][6] += nQtdeIt
            
            Else

               aAdd(aPack,({cSeqEmb   ,;  //[1] Sequencia do Embarque
                            cProd     ,;  //[2] Produto
                            cEmbSup   ,;  //[3] Embalagem Superior
                            nQtdeEmb  ,;  //[4] Quantidade de Embalagens
                            cIdCont   ,;  //[5] ID do Container
                            nQtdeIt   })) //[6] Qtde de Produtos
         
            EndIf
         
         EndIf
         EYH->(DbSkip())
      EndDo
   Else
      EE9->(DbSetOrder(3))
      If EE9->(DbSeek(xFilial()+cPreemb))
         aAdd(aPack,({EE9->EE9_SEQEMB  ,;  //[1] Sequencia do Embarque
                      EE9->EE9_COD_I   ,;  //[2] Produto
                      If( EasyGParam("MV_AVG0142",,.F.),Posicione("EE5",1,xFilial("EE5")+AvKey(EE9->EE9_EMBAL1,"EE5_CODEMB"),"EE5_DESC"),"") ,;  //[3] Embalagem Superior   //NCF - 20/08/2012 - Integ. INTTRA                          
                      EE9->EE9_QTDEM1  ,;  //[4] Quantidade de Embalagens
                      ""               ,;  //[5] ID do Container
                      EE9->EE9_SLDINI  })) //[6] Qtde de Produtos
         While EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+cPreemb)
            aPack[1][4] += EE9->EE9_QTDEM1
            aPack[1][6] += EE9->EE9_SLDINI
            EE9->(DbSkip())
         EndDo
      EndIf
   EndIf
   
   For nInc := 2 To Len(aPack)
      aPack[1][4] += aPack[nInc][4]
      aPack[1][6] += aPack[nInc][6]
   Next
   If Len(aPack) > 1
      aPack := {aPack[1]}
   EndIf

End Sequence

RestOrd(aOrd, .T.)

Return aPack

Function AvSiPackages(cPreemb)
Local aPack    := {}, aEmb, aItens
Local aOrd     := SaveOrd({"EYH"})
Local nPos1, nPos2
Local aNewSICont:= {}

If Type("aSICont") == "A"
   aNewSICont:= AClone(aSICont)
EndIf

Begin Sequence


   EX9->(DbSeek(xFilial()+cPreemb))
   While EX9->(!Eof() .And. EX9_FILIAL+EX9_PREEMB == xFilial("EX9")+cPreemb)
   
      If aScan(aNewSICont, EX9->EX9_CONTNR) == 0
         EX9->(DbSkip())
         Loop
      EndIf

      EYH->(DbSetOrder(3))
      EYH->(DbSeek(xFilial()+"S"+AvKey(cPreemb,"EYH_PREEMB")+EX9->EX9_ID))
      While EYH->(!Eof() .And. EYH_FILIAL+EYH_ESTUF+EYH_PREEMB+EYH_IDVINC == xFilial()+"S"+cPreemb+EX9->EX9_ID)

         nPos1 := aScan(aPack, {|x| x[1] == EYH->EYH_CODEMB })
         aItens := GetDescItens()
         If (nPos1 == 0) .Or. (aItens[1] <> aPack[nPos1][2])
            aEmb := GetInfoEmb()
            aItens := GetDescItens()
            aAdd(aPack, {EYH->EYH_CODEMB,;//[01] Código da Embalagem
                         aItens[1]      ,;//[02] Descrição do item embalado
                         aEmb[1]        ,;//[03] Código Inttra da embalagem
                         0              ,;//[04] Volume unitário da embalagem
                         0              ,;//[05] Quantidade
                         0              ,;//[06] Peso Total
                         EX9->EX9_CUBAGE,;//[07] Volume Total
                         {}             ,;//[08] Containers onde a embalagem se encontra
                         aItens[2]      ,;//[09] Referência dos processos
                         aItens[3]      })//[10] Códigos do item para referência

            nPos1 := Len(aPack)
         ElseIf At(aItens[2], aPack[nPos1][09]) == 0
            aPack[nPos1][09] += aItens[2]//[09] Referência dos processos
         EndIf

         If (nPos2 := aScan(aPack[nPos1][8], {|x| x[1] == EX9->EX9_CONTNR })) == 0
            aAdd(aPack[nPos1][8], {EX9->EX9_CONTNR,;//[01] Número do container
                                   0              ,;//[02] Quantidade da embalagem no container
                                   0              ,;//[03] Peso das embalagens no container
                                   0})              //[04] Volume das embalagens no container
            nPos2 := Len(aPack[nPos1][8])
         EndIf

         aPack[nPos1][5]           += EYH->EYH_QTDEMB
         aPack[nPos1][6]           += EYH->EYH_PSBRTO
         aPack[nPos1][7]           += EX9->EX9_CUBAGE//EYH->EYH_QTDEMB * aPack[nPos1][4]

         aPack[nPos1][8][nPos2][2] += EYH->EYH_QTDEMB
         aPack[nPos1][8][nPos2][3] += EYH->EYH_PSBRTO
         aPack[nPos1][8][nPos2][4] += EYH->EYH_QTDEMB * aPack[nPos1][4]

         EYH->(DbSkip())
      EndDo
      EX9->(DbSkip())
   EndDo

End Sequence

Return aPack

Static Function GetInfoEmb()
Local aOrd := SaveOrd("EE5")
Local aRet := {"", 0}

   EE5->(DbSetOrder(1))
   If EE5->(DbSeek(xFilial()+EYH->EYH_CODEMB))
      aRet[1] := EE5->EE5_CODINT
      aRet[2] := EE5->(EE5_CCOM * EE5_LLARG * EE5_HALT)
   EndIf

RestOrd(aOrd, .T.)
Return aRet

Static Function GetDescItens()
Local aOrd := SaveOrd({"EE9"})
Local nRecno := EYH->(Recno())
Local aRet := {"", "", ""}, cDesc := "", aDesc
Local cChave := EYH->(EYH_FILIAL+EYH_ESTUF+EYH_PREEMB+EYH_ID)

   //Busca as embalagens internas da atual, até chegar no item
   If EYH->(DbSeek(cChave))
      While EYH->(!Eof() .And. EYH_FILIAL+EYH_ESTUF+EYH_PREEMB+EYH_IDVINC == cChave)
         If !Empty(EYH->EYH_COD_I)
            EE9->(DbSetOrder(3))
            If EE9->(DbSeek(xFilial()+EYH->(EYH_PREEMB+EYH_SEQEMB)))
               If EE9->(FieldPos("EE9_DINTCD")) == 0
                  cDesc := FRM102RmQuebra(MSMM(EE9->EE9_DESC, TAMSX3("EE9_DINT")[1],,, LERMEMO))
               Else
                  cDesc := FRM102RmQuebra(MSMM(EE9->EE9_DINTCD, TAMSX3("EE9_DINT")[1],,, LERMEMO))
               EndIf
            EndIf
            If !Empty(aRet[1]) .And. !Empty(cDesc)
               aRet[1] += " / " + cDesc
               aRet[2] += " / " + EE9->EE9_PEDIDO
               aRet[3] := EE9->EE9_COD_I
            Else
               aRet[1] := cDesc
               aRet[2] := EE9->EE9_PEDIDO
               aRet[3] := EE9->EE9_COD_I
            EndIf
         Else
            aDesc := GetDescItens()
            If !Empty(aRet[1]) .And. !Empty(aDesc[1])
               aRet[1] += " / " + aDesc[1]
               aRet[2] += " / " + aDesc[2]
               aRet[3] := aDesc[3]
            Else
               aRet[1] := aDesc[1]
               aRet[2] := aDesc[2]
               aRet[3] := aDesc[3]
            EndIf
         EndIf

         EYH->(DbSkip())
      EndDo
   EndIf

   EYH->(DbGoTo(nRecno))
   RestOrd(aOrd, .T.)
   
Return aRet

Function Frm102PesCont(cCont)
Local nPes := 0
Local aOrd := SaveOrd({"EYH"})

   EYH->(DbSetOrder(3))
   EYH->(DbSeek(xFilial()+"S"+EEC->EEC_PREEMB+EX9->EX9_ID))
   While EYH->(!Eof() .And. EYH_FILIAL+EYH_PREEMB+EYH_IDVINC == xFilial()+EEC->EEC_PREEMB+EX9->EX9_ID)
      nPes += EYH->EYH_PSBRTO
      EYH->(DbSkip())
   EndDo
   
RestOrd(aOrd, .T.)
Return nPes

/*
Programa   : BuscaEmbSup(cPreemb,cIdVinc)
Objetivo   : Pesquisa a Embalagem mais externa do Item.
Autor      : Eduardo C. Romanini
Data/Hora  : 29/08/2007 às 15:00
Obs        : 
*/
*-----------------------------------*
Function BuscaEmbSup(cPreemb,cIdVinc)
*-----------------------------------*
Local aEmbSup := {}
Local aOrd    := SaveOrd({"EYH"})

Local cEmbSup := ""

Local nQtde   := 0

Begin Sequence
   
   cEmbSup := EYH->EYH_CODEMB
   nQtde   := EYH->EYH_QTDEMB
   
   EYH->(DbSetOrder(1))
   If EYH->(DbSeek(xFilial("EYH")+"S"+AvKey(cPreemb,"EYH_PREEMB")+AvKey(cIdVinc,"EYH_ID")))
      While EYH->(DbSeek(xFilial("EYH")+"S"+AvKey(cPreemb,"EYH_PREEMB")+AvKey(cIdVinc,"EYH_ID")))

         cEmbSup := EYH->EYH_CODEMB
         nQtde   := EYH->EYH_QTDEMB
         cIdVinc := EYH->EYH_IDVINC
      
         EYH->(DbSkip())
      EndDo
   
      aEmbSup := {cEmbSup,nQtde,cIdVinc}
   EndIf

End Sequence

RestOrd(aOrd, .T.)

Return aEmbSup
                                     
/*
Programa   : DetPedidos(cPreemb)
Objetivo   : Lista todos os Pedidos de um Embarque
Autor      : Eduardo C. Romanini
Data/Hora  : 30/08/2007 às 09:00
Obs        : 
*/
*--------------------------*
Function DetPedidos(cPreemb)
*--------------------------*
Local aPedidos := {}
Local aOrd := SaveOrd("EE9")

Local nPos := 0

Begin Sequence

   EE9->(DbSetOrder(3))
   If EE9->(DbSeek(xFilial("EE9")+AvKey(cPreemb,"EE9_PREEMB")))
      While EE9->(!EOF()) .and. EE9->(EE9_FILIAL+EE9_PREEMB) == xFilial("EE9")+AvKey(cPreemb,"EE9_PREEMB")
     
         nPos := aScan(aPedidos,EE9->EE9_PEDIDO)
         
         If nPos == 0

            aAdd(aPedidos,EE9->EE9_PEDIDO)
         
         EndIf
         
         EE9->(DbSkip())
      EndDo
   EndIf

End Sequence

RestOrd(aOrd, .T.)

Return aPedidos


/*
Programa   : TotEquipment(cPreemb)
Objetivo   : Retorna a quantidade total de containeres do processo.
Autor      : Eduardo C. Romanini
Data/Hora  : 30/08/2007 às 09:00
Obs        : 
*/
*----------------------------*
Function TotEquipment(cPreemb)
*----------------------------*
Local nQtde := 0

Local aOrd := SaveOrd({"EX9"})

Begin Sequence

   EX9->(DbSetOrder(1))
   If EX9->(DbSeek(xFilial("EX9")+AvKey(cPreemb,"EX9_PREEMB")))
      While EX9->(!EOF()) .and. EX9->(EX9_FILIAL+EX9_PREEMB) == xFilial("EX9")+AvKey(cPreemb,"EX9_PREEMB")
         
         nQtde++
      
         EX9->(DbSkip())
      EndDo
   EndIf
End Sequence

RestOrd(aOrd, .T.)

Return nQtde

/*
Programa   : TotPackages() 
Objetivo   : Retorna a quantidade total de embalagens externas do processo.
Autor      : Eduardo C. Romanini
Data/Hora  : 29/08/2007 às 15:00
Obs        : 
*/
*---------------------------*
Function TotPackages(cPreemb)
*---------------------------*
Local aEmbSup  := {}

Local nQtdeEmb := 0

Begin Sequence

   EYH->(DbSetOrder(2))
   If EYH->(DbSeek(xFilial("EYH")+"S"+AvKey(cPreemb,"EYH_PREEMB")))
      While EYH->(!EOF()) .and. EYH->(EYH_FILIAL+EYH_ESTUF+EYH_PREEMB) == xFilial("EYH")+"S"+AvKey(cPreemb,"EYH_PREEMB")
         If !Empty(EYH->EYH_SEQEMB)
            
            //Busca a embalagem mais externa
            aEmbSup  := BuscaEmbSup(cPreemb, EYH->EYH_IDVINC)

            nQtdeEmb += aEmbSup[2]
          
         EndIf
         EYH->(DbSkip())
      EndDo
   EndIf

End Sequence

Return nQtdeEmb
    
/*
Programa   : TotVolume(cPreemb)
Objetivo   : Retorna o volume total de um embarque.
Autor      : Eduardo C. Romanini
Data/Hora  : 29/08/2007 às 15:00
Obs        : 
*/
*---------------------------*
Function TotVolume(cPreemb)
*---------------------------*
Local aEmbSup  := {}
Local aPack    := {}
Local aOrd     := SaveOrd({"EYH","EE5"})

Local cEmbSup  := ""
Local nQtdeEmb := ""

Local nVolume  := 0
Local nVolUn   := 0
Local nPos     := 0 
Local nInc     := 0

Begin Sequence
   
   //Agrupa as embalagens mais externas
   EYH->(DbSetOrder(2))
   If EYH->(DbSeek(xFilial("EYH")+"S"+AvKey(cPreemb,"EYH_PREEMB")))
      While EYH->(!EOF()) .and. EYH->(EYH_FILIAL+EYH_ESTUF+EYH_PREEMB) == xFilial("EYH")+"S"+AvKey(cPreemb,"EYH_PREEMB")
         If !Empty(EYH->EYH_SEQEMB)
            
            //Busca a embalagem mais externa
            aEmbSup  := BuscaEmbSup(cPreemb,EYH->EYH_IDVINC)
            
            cEmbSup  := aEmbSup[1]
            nQtdeEmb := aEmbSup[2]
            
            nPos := aScan(aPack,{|e| e[1] == cEmbSup}) 

            If nPos > 0
            
               aPack[nPos][2] += nQtdeEmb
            
            Else

               aAdd(aPack,({cEmbSup  ,;  //[1] Embalagem
                            nQtdeEmb })) //[2] Qtde de Embalagens
         
            EndIf
         EndIf
         EYH->(DbSkip())
      EndDo
   EndIf
  
   //Calcula o Volume
   For nInc := 1 To Len(aPack)
      EE5->(DbSetOrder(1))
      If EE5->(DbSeek(xFilial("EE5")+AvKey(aPack[nInc][1],"EE5_CODEMB")))

         nVolUn := EE5->EE5_CCOM*EE5->EE5_LLARG*EE5->EE5_HALT

         nVolume += nVolUn * aPack[nInc][2]
   
      EndIf
   Next

End Sequence

Return nVolume

Function Frm102AtuDatas(aTipoDatas, aDatas, cNavio, cViagem)
Local nPos, nInc
Local lOriEE6 := .T., lDestEE6 := .T.
Local bCposTran

   If (nPos := aScan(aTipoDatas, "PlaceOfReceipt")) > 0
      If ValType(aDatas[nPos]) == "C"
         EXL->EXL_ETDORI := SToD(aDatas[nPos])//"EstimatedDeparture"
      ElseIf ValType(aDatas[nPos]) == "D"
         EXL->EXL_ETDORI := aDatas[nPos]//"EstimatedDeparture"
      ElseIf ValType(aDatas[nPos]) == "A"
         For nInc := 1 To Len(aDatas[nPos])
            If ValType(aDatas[nPos][nInc]) == "O"
               If aDatas[nPos][nInc]:_DateType:Text == "EstimatedDeparture"
                  EXL->EXL_ETDORI := SToD(aDatas[nPos][nInc]:Text)
               ElseIf aDatas[nPos][nInc]:_DateType:Text == "EquipmentPickup"
                  EXL->EXL_DTRETI := SToD(Left(aDatas[nPos][nInc]:Text, 8))
                  EXL->EXL_HRRETI := SubStr(aDatas[nPos][nInc]:Text, 9, 2) + ":" + SubStr(aDatas[nPos][nInc]:Text, 11, 2)
               ElseIf aDatas[nPos][nInc]:_DateType:Text == "CutOff"
                  EXL->EXL_DEADLI := SToD(Left(aDatas[nPos][nInc]:Text, 8))
               EndIf                     
            EndIf
         Next
      EndIf
   EndIf
   If (nPos := aScan(aTipoDatas, "PortOfLoading")) > 0 .And. Len(aDatas) >= nPos .And. ValType(aDatas[nPos]) $ "D/C"
      EEC->EEC_ETD := If(ValType(aDatas[nPos]) == "C", SToD(aDatas[nPos]), aDatas[nPos])
   EndIf
   If (nPos := aScan(aTipoDatas, "PortOfDischarge")) > 0 .And. Len(aDatas) >= nPos .And. ValType(aDatas[nPos]) $ "D/C"
      EEC->EEC_ETADES := If(ValType(aDatas[nPos]) == "C", SToD(aDatas[nPos]), aDatas[nPos])
   EndIf
   /*
   If (nPos := aScan(aTipoDatas, "PlaceOfDelivery")) > 0
      EEC->EXL_ := SToD(aDatas[nPos])
   EndIf
   */
   
   //*** Atualização do Navio
   If (EEC->EEC_EMBARC <> cNavio) .Or. (EEC->EEC_VIAGEM <> cViagem)
      cMsgNavio := StrTran("Para o embarque 'XXX', o navio informado pelo Inttra diverge do registrado no processo, conforme abaixo:", "XXX", EEC->EEC_PREEMB) + ENTER
      cMsgNavio += "Navio atual   : '" + EEC->EEC_EMBARC + "' Viagem: '" + EEC->EEC_VIAGEM + "'" + ENTER
      cMsgNavio += "Navio recebido: '" + AvKey(cNavio, "EEC_EMBARC") + "' Viagem: '" + AvKey(cViagem, "EEC_VIAGEM") + "'" + ENTER
      cMsgNavio += "Confirma a alteração do navio no embarque?"
      If MsgYesNo(cMsgNavio, "Aviso")
         EEC->EEC_EMBARC := cNavio
         EEC->EEC_VIAGEM := cViagem
      EndIf
   EndIf
   
   EE6->(DbSetOrder(1))
   If !EE6->(DbSeek(xFilial()+AvKey(Upper(cNavio), "EE6_COD")+AvKey(cViagem, "EE6_VIAGEM")))
      EE6->(RecLock("EE6", .T.))
      EE6->EE6_FILIAL	:= xFilial("EE6")
      EE6->EE6_COD		:= Upper(cNavio)//RMD - 03/01/13 - Inclui o nome do navio em maiúscula, seguindo a picture do campo.
      EE6->EE6_VIAGEM	:= cViagem
      EE6->EE6_NOME		:= cNavio
      EE6->EE6_ORIGEM	:= EEC->EEC_ORIGEM
      EE6->EE6_DEST		:= EEC->EEC_DEST
   Else
      EE6->(RecLock("EE6", .F.))
   EndIf
   
   If !Empty(EE6->EE6_ORIGEM) .And. EE6->EE6_ORIGEM <> EEC->EEC_ORIGEM
      lOriEE6 := .F.
   EndIf
   If !Empty(EE6->EE6_DEST) .And. EE6->EE6_DEST <> EEC->EEC_DEST
      lDestEE6 := .F.
   EndIf
   
   //Grava campo informativo se houve alteração no transporte
   bCposTran := {|cAliEEC, cAliEXL| &(cAliEEC + "->(EEC_EMBARC+EEC_VIAGEM+DToC(EEC_ETD)+DToC(EEC_ETADES))")+&(cAliEXL + "->(DToC(EXL_ETDORI)+DToC(EXL_DTRETI)+EXL_HRRETI+DToC(EXL_DEADLI))") }
   EYM->EYM_ALTTRN := If(Eval(bCposTran, "EEC", "EXL") == Eval(bCposTran, "M", "M"), "1", "2")
   EYM->EYM_NAVIO  := cNavio
   EYM->EYM_VIAGEM := cViagem
   EYM->EYM_ETD    := EEC->EEC_ETD

   //*** Atualiza as datas do navio
   //Origem
   If lOriEE6
      EE6->EE6_ETSORI := EEC->EEC_ETD
   Else
      //Busca a origem nos destinos cadastrados no navio
      EX8->(DbSetOrder(3))
      lFoundEX8 := .F.
      EX8->(DbSeek(xFilial()+EE6->(EE6_COD+EE6_VIAGEM)))
      While EX8->(!Eof() .and. EX8_FILIAL+EX8_NAVIO+EX8_VIAGEM == xFilial()+EE6->(EE6_COD+EE6_VIAGEM))
         If EX8->EX8_DEST == EEC->EEC_ORIGEM
            lFoundEX8 := .T.
            Exit
         EndIf
         EX8->(DbSkip())
      EndDo
      If !lFoundEX8
         EX8->(RecLock("EX8", .T.))
         EX8->EX8_FILIAL	:= xFilial("EX8")
         EX8->EX8_NAVIO		:= EE6->EE6_COD
         EX8->EX8_VIAGEM	:= EE6->EE6_VIAGEM
         EX8->EX8_DEST		:= EEC->EEC_ORIGEM
      Else
         EX8->(RecLock("EX8", .F.))
      EndIf
      EX8->EX8_ETSDES := EEC->EEC_ETD
   EndIf
   //Destino
   If lDestEE6
      EE6->EE6_ETADES := EEC->EEC_ETADES
   Else
      //Busca o destino nos destinos cadastrados no navio
      EX8->(DbSetOrder(3))
      lFoundEX8 := .F.
      EX8->(DbSeek(xFilial()+EE6->(EE6_COD+EE6_VIAGEM)))
      While EX8->(!Eof() .and. EX8_FILIAL+EX8_NAVIO+EX8_VIAGEM == xFilial()+EE6->(EE6_COD+EE6_VIAGEM))
         If EX8->EX8_DEST == EEC->EEC_DEST
            lFoundEX8 := .T.
            Exit
         EndIf
         EX8->(DbSkip())
      EndDo
      If !lFoundEX8
         EX8->(RecLock("EX8", .T.))
         EX8->EX8_FILIAL	:= xFilial("EX8")
         EX8->EX8_NAVIO		:= EE6->EE6_COD
         EX8->EX8_VIAGEM	:= EE6->EE6_VIAGEM
         EX8->EX8_DEST		:= EEC->EEC_DEST
      Else
         EX8->(RecLock("EX8", .F.))
      EndIf
      EX8->EX8_ETADES := EEC->EEC_ETADES
   EndIf
   EX8->(MsUnlock())
   EE6->(MsUnlock())
   //***   

Return

Function FRM102AtuVia(aTIPO_LOC, aTIPO_COD_LOC, aCOD_LOC, cTipoMov)
Local aOrd := SaveOrd("SYR")
Local cALT_ORIGEM, cALT_OR_PAIS, cALT_OR_CIDADE, cALT_DEST, cALT_DEST_PAIS, cALT_DEST_CIDADE
Local nInc, lAltOri := .T., lAltDest := .T.

   SYR->(DbSetOrder(1))
   For nInc := 1 To Len(aTIPO_LOC)
      //Local de Carregamento
      If aTIPO_LOC[nInc] == "PlaceOfReceipt"
         If ValType(aTIPO_COD_LOC) <> "A" .Or. aTIPO_COD_LOC[nInc] == "UN"
            SY9->(DbSetOrder(4))
            SY9->(DbSeek(xFilial("SY9")+aCOD_LOC[nInc]))
            If EXL->EXL_TIPMOV $ "2/4"
               If SY9->(!EOF() .And. Y9_SIGLA != EXL->EXL_LOCREC)
                  EXL->EXL_LOCREC := SY9->Y9_SIGLA
               EndIf
            Else
               If SY9->(!EOF() .And. Y9_SIGLA != EEC->EEC_ORIGEM)
                  cALT_ORIGEM := SY9->Y9_SIGLA
                  cALT_OR_PAIS := SY9->Y9_PAIS
                  cALT_OR_CIDADE := SY9->Y9_CIDADE
               EndIf
               lAltOri := .F.
            EndIf
         EndIf
      EndIf
      //Porto de Origem
      If aTIPO_LOC[nInc] == "PortOfLoading"
         If ValType(aTIPO_COD_LOC) <> "A" .Or. aTIPO_COD_LOC[nInc] == "UN"
            SY9->(DbSetOrder(4))
            SY9->(DbSeek(xFilial("SY9")+aCOD_LOC[nInc]))
            If SY9->(!EOF() .And. Y9_SIGLA != EEC->EEC_ORIGEM) .And. lAltOri
               cALT_ORIGEM := SY9->Y9_SIGLA
               cALT_OR_PAIS := SY9->Y9_PAIS
               cALT_OR_CIDADE := SY9->Y9_CIDADE
            EndIf
         EndIf
      EndIf

      //Porto de Destino
      If aTIPO_LOC[nInc] == "PortOfDischarge"
         If ValType(aTIPO_COD_LOC) <> "A" .Or. aTIPO_COD_LOC[nInc] == "UN"
            SY9->(DbSetOrder(4))
            SY9->(DbSeek(xFilial("SY9")+aCOD_LOC[nInc]))
            If SY9->(!EOF() .And. Y9_SIGLA != EEC->EEC_DEST) .And. lAltDest
               cALT_DEST := SY9->Y9_SIGLA
               cALT_DEST_PAIS := SY9->Y9_PAIS
               cALT_DEST_CIDADE := SY9->Y9_CIDADE
            EndIf
         EndIf
      EndIf

      //Local de Entrega
      If aTIPO_LOC[nInc] == "PlaceOfDelivery"
         If ValType(aTIPO_COD_LOC) <> "A" .Or. aTIPO_COD_LOC[nInc] == "UN"
            SY9->(DbSetOrder(4))
            SY9->(DbSeek(xFilial("SY9")+aCOD_LOC[nInc]))
            If EXL->EXL_TIPMOV $ "3/4"
               If SY9->(!EOF() .and. SY9->Y9_SIGLA != EXL->EXL_LOCENT)
                  EXL->EXL_LOCENT := SY9->Y9_SIGLA
               EndIf
            Else
               If SY9->(!EOF() .And. Y9_SIGLA != EEC->EEC_DEST)
                  cALT_DEST := SY9->Y9_SIGLA
                  cALT_DEST_PAIS := SY9->Y9_PAIS
                  cALT_DEST_CIDADE := SY9->Y9_CIDADE
               EndIf
               lAltDest := .F.
            EndIf
         EndIf
      EndIf
   Next
   
   //Alteração na Origem e Destino
   If ValType(cALT_ORIGEM) == "C" .And. ValType(cALT_DEST) == "C"
      If !SYR->(DbSeek(xFilial("SYR")+EEC->EEC_VIA+cALT_ORIGEM+cALT_DEST))
         //Criação de Via de Transporte
         SYR->(RecLock("SYR",.T.))
         SYR->YR_FILIAL  := xFilial("SYR")
         SYR->YR_VIA     := EEC->EEC_VIA
         SYR->YR_ORIGEM  := cALT_ORIGEM
         SYR->YR_PAIS_OR := cALT_OR_PAIS
         SYR->YR_CID_ORI := cALT_OR_CIDADE
         SYR->YR_DESTINO := cALT_DEST
         SYR->YR_PAIS_DE := cALT_DEST_PAIS
         SYR->YR_CID_DES := cALT_DEST_CIDADE
         SYR->YR_TIPTRAN := "1"
         SYR->(MsUnlock())
      EndIf
   EndIf

   //Alteração na Origem
   If ValType(cALT_ORIGEM) == "C" .And. !ValType(cALT_DEST) == "C"
      If !SYR->(DbSeek(xFilial("SYR")+EEC->EEC_VIA+cALT_ORIGEM+EEC->EEC_DEST))
         //Criação de Via de Transporte
         SYR->(RecLock("SYR",.T.))
         SYR->YR_FILIAL  := xFilial("SYR")
         SYR->YR_VIA     := EEC->EEC_VIA
         SYR->YR_ORIGEM  := cALT_ORIGEM
         SYR->YR_PAIS_OR := cALT_OR_PAIS
         SYR->YR_CID_ORI := cALT_OR_CIDADE
         SY9->(DbSetOrder(2))
         SY9->(DbSeek(xFilial("SY9")+EEC->EEC_DEST))
         SYR->YR_DESTINO := EEC->EEC_DEST
         SYR->YR_PAIS_DE := SY9->Y9_PAIS
         SYR->YR_CID_DES := SY9->Y9_CIDADE
         SYR->YR_TIPTRAN := "1"
         SYR->(MsUnlock())
      EndIf
   EndIf

   //Alteração no Destino
   If !ValType(cALT_ORIGEM) == "C" .And. ValType(cALT_DEST) == "C"
      If !SYR->(DbSeek(xFilial("SYR")+EEC->EEC_VIA+EEC->EEC_ORIGEM+cALT_DEST))
         //Criação de Via de Transporte
         SYR->(RecLock("SYR",.T.))
         SYR->YR_FILIAL  := xFilial("SYR")
         SYR->YR_VIA     := EEC->EEC_VIA
         SYR->YR_DESTINO := cALT_DEST
         SYR->YR_PAIS_DE := cALT_DEST_PAIS
         SYR->YR_CID_DES := cALT_DEST_CIDADE
         SY9->(DbSetOrder(2))
         SY9->(DbSeek(xFilial("SY9")+EEC->EEC_ORIGEM))
         SYR->YR_ORIGEM  := EEC->EEC_ORIGEM
         SYR->YR_PAIS_OR := SY9->Y9_PAIS
         SYR->YR_CID_ORI := SY9->Y9_CIDADE
         SYR->YR_TIPTRAN := "1"
         SYR->(MsUnlock())
      EndIf
   EndIf

   //EEC->EEC_ORIGEM	:= cALT_ORIGEM
   //EEC->EEC_DEST 	:= cALT_DEST

   Do Case
      Case cTipoMov == "PortToPort"
         EXL->EXL_TIPMOV := "1"
      Case cTipoMov == "DoorToPort"
         EXL->EXL_TIPMOV := "2"
      Case cTipoMov == "PortToDoor"
         EXL->EXL_TIPMOV := "3"
      Case cTipoMov == "DoorToDoor"
         EXL->EXL_TIPMOV := "4"
   EndCase

RestOrd(aOrd, .T.)
Return

Function Frm102SICont(cPreemb, cSeqSI, cOpcao)
Local aConts := {}
Local aSemSx3 := {}
Local oDlg
Local lInverte := .F.
Local nInc, nTot
Local cMarca := GetMark()
Local cTitulo := ""
Local aButtons := {}
Local bOk     := {|| oDlg:End()}
Local bCancel := {|| oDlg:End()}
Local aCposBrw := {}
Private aCampos := Array(EX9->(FCount()))
Default cPreemb := ""
Default cSeqSI := ""

   If cOpcao == INCLUIR
      cSeqSI := ""
   EndIf

   If cOpcao == VISUALIZAR
      cTitulo := StrTran("Relação de Containers - SI '###'", "###", AllTrim(cSeqSI))
   Else
      cTitulo := StrTran("Seleção de Container - Embarque '###'", "###", AllTrim(EEC->EEC_PREEMB))
      bOk := {|| If(Len(aConts := GetContainers()) == 0, MsgInfo("Selecione ao menos um container para continuar.", "Aviso"), oDlg:End()) }
   EndIf

   aAdd(aSemSX3, {"WK_MARCA", "C", 2, 0})
   E_CriaTrab("EX9", aSemSx3, "EX9_SEL")
   
   If !(cOpcao == VISUALIZAR)
      aAdd(aCposBrw, {"WK_MARCA","","  "})
   EndIf
   
   aAdd(aCposBrw, ColBrw("EX9_CONTNR","EX9_SEL"))
   aAdd(aCposBrw, ColBrw("EX9_SEQSI" ,"EX9_SEL"))
   aAdd(aCposBrw, ColBrw("EX9_BLNUM" ,"EX9_SEL"))

   If !(cOpcao == VISUALIZAR)   
      aAdd(aButtons, {"LBTIK", {|| EX9Marca(EX9_SEL->WK_MARCA, cMarca, cSeqSI, .T.) }, "Marca/Desmarca Todos", "Marc./Des."})
   EndIf
   
   cPreemb := AvKey(cPreemb, "EEC_PREEMB")
   cSeqSI  := AvKey(cSeqSI , "EX9_SEQSI")
   
   EX9->(DbSetOrder(1))
   EX9->(DbSeek(xFilial()+cPreemb))
   While EX9->(!Eof() .And. EX9_PREEMB == cPreemb)
      If !(cOpcao == VISUALIZAR) .Or. EX9->EX9_SEQSI == cSeqSi
         EX9_SEL->(DbAppend())
         AvReplace("EX9", "EX9_SEL")
         If EX9->EX9_SEQSI == cSeqSI
            EX9_SEL->WK_MARCA := cMarca
         EndIf
      EndIf
      EX9->(DbSkip())
   EndDo
   EX9_SEL->(DbGoTop())
   
   If cOpcao == EXCLUIR
      aConts := GetContainers()
   Else
      DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO DLG_LIN_FIM * 0.7, DLG_COL_FIM * 0.7 OF oMainWnd PIXEL

         oMsSelect := MsSelect():New("EX9_SEL","WK_MARCA",,aCposBrw,@lInverte,@cMarca,PosDLG(oDlg))
         If cOpcao <> VISUALIZAR
            oMsSelect:bAval := {|| EX9Marca(EX9_SEL->WK_MARCA, cMarca, cSeqSI, .F.) }
         EndIf

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel,, aButtons) CENTERED
   EndIf
   
   EX9_SEL->(DbCloseArea())

Return aConts

Static Function GetContainers()
Local aRet := {}

   EX9_SEL->(DbGoTop())
   While EX9_SEL->(!Eof())
      If !Empty(EX9_SEL->WK_MARCA)
         aAdd(aRet, EX9_SEL->EX9_CONTNR)
      EndIf
      EX9_SEL->(DbSkip())
   EndDo
   EX9_SEL->(DbGoTop())

Return aRet

Static Function EX9Marca(cMarcaAtu, cMarca, cSeqSI, lTodos)
Local bMarca := {|| If(Empty(EX9_SEL->EX9_SEQSI) .Or. EX9_SEL->EX9_SEQSI == cSeqSI, (EX9_SEL->WK_MARCA := cMarcaAtu, .T.),  .F.)}

   If Empty(cMarcaAtu)
      cMarcaAtu := cMarca
   Else
      cMarcaAtu := ""
   EndIf
   
   If lTodos
      EX9_SEL->(DbGoTop())
      EX9_SEL->(DbEval(bMarca))
      EX9_SEL->(DbGoTop())
   Else
      If !Eval(bMarca)
         MsgInfo("Este container não pode ser marcado por estar vinculado a outra SI.", "Aviso")
      EndIf
   EndIf

Return Nil

Function Frm102RmQuebra(cStr)
Return StrTran(cStr, ENTER, " ")

Function Frm102AtuNumSi(cRef, cSiNum, cComments)
Local cPreemb, cSeqSI
Default cRef := ""
Default cSiNum := ""

   If At("/", cRef) > 0
      cPreemb := AvKey(SubStr(cRef, 1, At("/", cRef) - 1), "EEC_PREEMB")
      cSeqSI  := AvKey(SubStr(cRef, At("/", cRef) + 1, 3), "EX9_SEQSI")
   EndIf
   
   If !Empty(cPreemb) .And. !Empty(cSeqSi)
      EX9->(DbSetOrder(1))
      EX9->(DbSeek(xFilial()+cPreemb))
      While EX9->(!Eof() .And. EX9_FILIAL+EX9_PREEMB == xFilial()+cPreemb)
         If EX9->EX9_SEQSI == cSeqSI
            EX9->(RecLock("EX9", .F.))
            EX9->EX9_SINUM := cSiNum
            EX9->(MsUnlock())
            //Deleta o Campo Memo
            MSMM(EX9->EX9_CSICOM,,,,2)
            //Inclui novamente (o MSMM já trava o registro)
            MSMM(,AVSX3("EX9_SICOM",3),,cComments,1,,,"EX9","EX9_CSICOM")
         EndIf
         EX9->(DbSkip())
      EndDo
   EndIf

Return Nil

Function Frm102AtuBkCom(cComments)

   If !Empty(cCommAtu := EXL->(MSMM(EXL_CBKCOM, AVSX3("EXL_BKCOM",3),,,3)))
      If At(cComments, cCommAtu) == 0
         cCommAtu += DToC(dDataBase) + " " + Time() + ": " + cComments + ENTER 
      EndIf
      MSMM(EXL->EXL_CBKCOM,,,,EXCMEMO)
      MSMM(,AVSX3("EXL_BKCOM",3),, cCommAtu, 1, , , "EXL", "EXL_CBKCOM")
   EndIf

Return Nil

Function FRM102AtuTT(aLocations, aLocType, aDateTime)
Local nInc

   If Len(aLocations) == Len(aLocType)
      For nInc := 1 To Len(aLocations)
         Do Case
            Case aLocType[nInc] == "PlaceOfReceipt"
               EYO->EYO_LOCREC := aLocations[nInc]
            Case aLocType[nInc] == "PortOfLoading"
               EYO->EYO_ORIGEM := aLocations[nInc]
            Case aLocType[nInc] == "PortOfDischarge"
               EYO->EYO_DEST := aLocations[nInc]
               If aScan(aLocType, "PlaceOfDelivery") == 0 .And. Len(aDateTime) >= nInc
                  EYO->EYO_ETD := aDateTime[nInc]
               EndIf
            Case aLocType[nInc] == "PlaceOfDelivery"
               EYO->EYO_LOCENT := aLocations[nInc]
               If Len(aDateTime) >= nInc
                  EYO->EYO_ETD := aDateTime[nInc]
               EndIf
            Case aLocType[nInc] == "IntermediatePort"
               EYO->EYO_PINTER := aLocations[nInc]
         End Case
      Next
   EndIf

Return

Function Frm102TT2Proc(cProc)
Local aCampos := {{"EEC_ORIGEM", "EYO_ORIGEM"}}
Local nInc
Local lAlterado := .F.
Local cHistorico := ""
   
   If EEC->(DbSeek(xFilial()+cProc))
      EEC->(RecLock("EEC", .F.))
      RegToMemory("EEC", .F.)
      For nInc := 1 To Len(aCampos)
         If M->&(aCampos[nInc][1]) <> EYO->&(aCampos[nInc][2])
            M->&(aCampos[nInc][1]) := EYO->&(aCampos[nInc][2])
            lAlterado := .T.
         EndIf
      Next
      
      If lAlterado
         cHistorico := Ae110MonHistProc("EEC", "EEC", "M")
         If !Empty(Alltrim(cHistorico))
            Ae110CadHistProc(OC_EM, EEC->EEC_PREEMB, "", cHistorico)
         EndIf
         AvReplace("M", "EEC")
      EndIf

      EEC->(MsUnlock())
   EndIf

Return Nil

Class EECLocInttra

	Data cTipo
	Data cLocal
	Data dData
	Data cNavio
	Data cViagem
	Data cTipoNavio
	
	Data aVias
	
	Method New(cTipo) Constructor
	
	Method SetTipo(cTipo)
	Method SetNavio(cNavio, cViagem)
	Method SetLocal(cLocal)
	Method SetData(dData)
	Method AddVia()

	Method InttraAtuVia()
	

End Class

Method New(cTipo) Class EECLocInttra
Default cTipo := ""

	Self:cTipo		:= cTipo
	Self:cLocal		:= ""
	Self:dData		:= Nil
	Self:cNavio		:= ""
	Self:cViagem	:= ""
	Self:cTipoNavio	:= ""
	
	Self:aVias	:= {}

Return Self

Method SetTipo(cTipo) Class EECLocInttra
Default cTipo	:= ""

	Self:cTipo		:= cTipo

Return Nil

Method SetNavio(cNavio, cViagem, cTipo) Class EECLocInttra
Default cNavio	:= ""
Default cViagem	:= ""
Default cTipo	:= ""

	Self:cNavio		:= cNavio
	Self:cViagem	:= cViagem
	Self:cTipoNavio	:= cTipo

Return Nil

Method SetLocal(cLocal) Class EECLocInttra
Default	cLocal		:= ""

	Self:cLocal := cLocal

Return Nil

Method SetData(dData) Class EECLocInttra

	Self:dData := dData

Return Nil

Method AddVia() Class EECLocInttra

	aAdd(Self:aVias, EECLocInttra():New())

Return Self:aVias[Len(Self:aVias)]


Method InttraAtuVia() Class EECLocInttra
Local aTIPO_LOC := {}, aCOD_LOC := {}, aDATA_LOC := {}
Local nPos
Local cNavio, cViagem

	If Len(Self:aVias) > 0

		//Busca a Origem
		oMain := Self:aVias[1]
		
		cNavio := oMain:cNavio
		cViagem := oMain:cViagem

		If (nPos := aScan(oMain:aVias, {|oVia| oVia:cTipo == "PORTOFLOAD"})) > 0

			If Len(oMain:aVias) > 0
				aAdd(aDATA_LOC, If(Len(oMain:aVias[nPos]:aVias) > 0, oMain:aVias[nPos]:aVias[1]:dData, Nil))
				aAdd(aTIPO_LOC, "PortOfLoading")
				aAdd(aCOD_LOC, oMain:cLocal)
			EndIf

		EndIf
		
		//Busca o Destino
		oMain := Self:aVias[Len(Self:aVias)]
		
		If (nPos := aScan(oMain:aVias, {|oVia| oVia:cTipo == "PORTOFDISCHARGE"})) > 0
			If Len(oMain:aVias[nPos]:aVias) > 0
				aAdd(aDATA_LOC, oMain:aVias[nPos]:aVias[Len(oMain:aVias[nPos]:aVias)]:dData)
				aAdd(aTIPO_LOC, "PortOfDischarge")
				aAdd(aCOD_LOC, oMain:cLocal)
			EndIf
		EndIf

	
		FRM102AtuVia(aTIPO_LOC, Nil, aCOD_LOC, Self:cTipo)
	
		Frm102AtuDatas(aTIPO_LOC, aDATA_LOC, cNavio, cViagem)
	
	EndIf

Return Nil
