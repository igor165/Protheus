/*
Funcao     : EECAT171()
Parametros : Nenhum
Retorno    : .T
Objetivos  : -
Autor      : Allan Oliveira Monteiro
Data/Hora  : 10/01/2012
*/

Function EECAT171()
   Private cCadastro := AVTITCAD("EE5")//"Embalagens"
   Private aRotina   := MenuDef()

Return .T.


Static Function MenuDef()

   Local aRotina :=  {  { "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                        { "Visualizar","AT171MAN" , 0 , 2},; //"Visualizar"
                        { "Incluir",   "AT171MAN" , 0 , 3},; //"Incluir"
                        { "Alterar",   "AT171MAN" , 0 , 4},; //"Alterar"
                        { "Excluir",   "AT171MAN" , 0 , 5,3} } //"Excluir"

Return aRotina

Function AT171MAN(cAlias,nReg,nOpc)
   //
Return Nil


Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
   Local oEasyIntEAI

   oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)

   oEasyIntEAI:oMessage:SetVersion("1.0")
   //oEasyIntEAI:oMessage:SetMainAlias("EE5")
   //oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| EECAT170(oEasyMessage:GetEAutoArray("EE5"),,oEasyMessage:GetOperation(), oEasyMessage:GetEAutoArray("EEK"))} )
   oEasyIntEAI:SetModule("EEC",29)

   // Recebimento
   oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "AT171ARECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
   oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AT171ARESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)
   //

   oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()


Function AT171ARECB(oMessage)
   Local oBusinessCont := oMessage:GetMsgContent()
   Local oBatch    := EBatch():New()
   Local oRecEE5   := ERec():New()
   Local oRecEEK , oRecSB1
   Local oRecItEEK := ETab():New()
   Local oExecAuto := EExecAuto():New()
   Local oExecSB1  := EExecAuto():New()
   Local oParams
   Local cSeq := ""
   Local cCodProd := ""
   Local cCodEmb := ""
   Local i
   Local nOrdSB1 := SB1->(IndexOrd())
   Local nRecSB1 := SB1->(Recno())
   Local nOrdEE5 := EE5->(IndexOrd())
   Local nRecEE5 := EE5->(Recno())
   Local aRelations:= {}
   Local nPosEmb, nPosSeq, nPosQtde


   Begin Sequence

      cCodProd := EasyGetXMLinfo(, oBusinessCont, "_ItemCode")
      SB1->(DbSetOrder(1))
      If !SB1->(DbSeek(xFilial("SB1")+AvKey(cCodProd,"B1_COD")))
         oMessage:Warning('Produto ' + AllTrim(cCodProd) + ' não integrado.')
         Break
      EndIf

      If AvFlags("CODEMB_LOGIX")

         EE5->(DbSetOrder(3)) // EE5_FILIAL+EE5_PRODUT
         If EE5->(DbSeek(xFilial("EE5")+AvKey( cCodProd,"EE5_PRODUT")))
            oRecEE5:SetField("EE5_CODEMB"  , EE5->EE5_CODEMB )
            cCodEmb := EE5->EE5_CODEMB
         Else
            cCodEmb := AT171GerCod()
            oRecEE5:SetField("EE5_CODEMB"  , cCodEmb)
            cDesc := "Embalagem para o produto " + cCodProd
            oRecEE5:SetField("EE5_DESC"  , cDesc )       	// DESCRIÇÃO DA EMBALAGEM
         EndIf
         oRecEE5:SetField("EE5_PRODUT"  , cCodProd)

      Else
         AddArrayXML(oRecEE5, "EE5_CODEMB" , oBusinessCont,"_ItemCode"         , .T.)    // CODIGO
         cCodEmb := cCodProd
         cDesc := "Embalagem para o produto " + EasyGetXMLInfo(, oBusinessCont,"_ItemCode"   )
         oRecEE5:SetField("EE5_DESC"  , cDesc )       	// DESCRIÇÃO DA EMBALAGEM
      EndIf

      /* Tratamento Grupo de Embalagens  */
      If IsCpoInXML(oBusinessCont, "_Packaging") .AND. AllTrim(Upper(oMessage:GetBsnEvent())) == "UPSERT"
         If ValType(oBusinessCont:_Packaging) <> "A"
            XmlNode2Arr(oBusinessCont:_Packaging ,"_Packaging")
         EndIf

         nPosEmb:= 1
         nPosSeq:= 2
         nPosQtde:= 3
         For i:= 1 to Len(oBusinessCont:_Packaging)
            cSeq := StrZero(Val(EasyGetXMLinfo("EEK_SEQ", oBusinessCont:_Packaging[i], "_PackagingLevel")),AvSx3("EEK_SEQ",3))
            AAdd(aRelations, {EasyGetXMLinfo("EEK_EMB", oBusinessCont:_Packaging[i], "_PackagingCode"),; //nPosEmb
               cSeq,; //nPosSeq
               EasyGetXMLinfo("EEK_QTDE", oBusinessCont:_Packaging[i], "_StandardAmount")}) //nPosQtde
         Next i

         //Ordenar pelo level
         ASort(aRelations,,,{|x,y| x[2] < y[2]})

         cCodEmb:= AVKEY(cCodEmb ,"EEK_CODIGO")
         For i:= 1 to Len(aRelations)

            oRecEEK   := ERec():New()

            oRecEEK:SetField("EEK_TIPO"  , AVKEY("E","EEK_TIPO"  ) )          // TIPO
            oRecEEK:SetField("EEK_PEDIDO", AVKEY("" ,"EEK_PEDIDO") )          // PEDIDO
            oRecEEK:SetField("EEK_SEQUEN", AVKEY("" ,"EEK_SEQUEN") )          // SEQUEN
            oRecEEK:SetField("EEK_CODIGO", cCodEmb)                           // CODIGO EMB MASTER
            oRecEEK:SetField("EEK_EMB"   , aRelations[i][nPosEmb])            // CODIGO EMBALAGEM
            oRecEEK:SetField("EEK_SEQ"   , aRelations[i][nPosSeq] )           // SEQUEN

            if i == 1
               nQtde:= aRelations[i][nPosQtde]
            else
               nQtde    := aRelations[i][nPosQtde]/aRelations[i-1][nPosQtde]
            endif
            oRecEEK:SetField("EEK_QTDE", nQtde)                                // QUANTIDADE

            oRecItEEK:AddRec(oRecEEK)

         Next i
      EndIf

      oExecAuto:SetField("EE5",oRecEE5)
      oExecAuto:SetField("EEK",oRecItEEK)

      oParams := ERec():New()
      oParams:SetField("cMainAlias","EE5")
      If AllTrim(Upper(oMessage:GetBsnEvent())) == "UPSERT"
         oParams:SetField("bFunction",{|oEasyMessage| EECAT170(oEasyMessage:GetEAutoArray("EE5"),,oEasyMessage:GetOperation(), EasyEAutItens("EE5","EEK",oEasyMessage:GetEAutoArray("EE5"),oEasyMessage:GetEAutoArray("EEK"),"EE5_FILIAL+'E'+EE5_CODEMB"))})
      Else
         oParams:SetField("bFunction",{|oEasyMessage| EECAT170(oEasyMessage:GetEAutoArray("EE5"),,oEasyMessage:GetOperation())})
      EndIf
      oExecAuto:SetField("PARAMS",oParams)


      //ExecAuto do Produtos
      oRecSB1 := ERec():New()
      AddArrayXML(oRecSB1, "B1_COD" , oBusinessCont,"_ItemCode"         , .T.)//CODIGO DO PRODUTO
      If AllTrim(Upper(oMessage:GetBsnEvent())) == "DELETE"
         oRecSB1:SetField("B1_CODEMB"  , "" )
      Else
         If AvFlags("CODEMB_LOGIX")
            oRecSB1:SetField("B1_CODEMB"  , cCodEmb )
         Else
            AddArrayXML(oRecSB1, "B1_CODEMB" , oBusinessCont,"_ItemCode"         , .F.)//EMBALAGEM
         EndIf
      EndIf

      oExecSB1:SetField("SB1",oRecSB1)

      oParams := ERec():New()
      oParams:SetField("cMainAlias","SB1")
      oParams:SetField("bFunction",{|oEasyMessage| EECAC120(oEasyMessage:GetEAutoArray("SB1"),,4)})
      oExecSB1:SetField("PARAMS",oParams)

      If AllTrim(Upper(oMessage:GetBsnEvent())) == "DELETE"
         oBatch:AddRec(oExecSB1)
         oBatch:AddRec(oExecAuto)
      Else
         oBatch:AddRec(oExecAuto)
         oBatch:AddRec(oExecSB1)
      EndIf

   End Sequence

   SB1->(DbSetOrder(nOrdSB1))
   SB1->(DbGoTo(nRecSB1))
   EE5->(DbSetOrder(nOrdEE5))
   EE5->(DbGoTo(nRecEE5))

Return oBatch

*-------------------------------------------------*
Function AT171ARESB(oMessage)

   Local oXml      := EXml():New()

   If oMessage:HasErrors()
      oXMl := oMessage:GetContentList("RESPONSE")
   EndIf

Return oXml

Static Function AT171GerCod()
   Local cCodigo := ""

   cCodigo := EasyGParam("MV_AVG0220",,"") + SubStr(GetSxeNum("EE5","EE5_CODEMB"),Len(EasyGParam("MV_AVG0220",,""))+1,AvSx3("EE5_CODEMB",3))

Return cCodigo
