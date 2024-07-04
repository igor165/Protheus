#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
/*
Programa : EECPF060.PRW
Autor    : Alex Wallauer Ferreira AWF
Data     : 28/04/2014
Revisao  :
Uso      : Manutencao de
*/

//nclude "EEC.CH"
//#INCLUDE "EECAS125.ch"
//#COMMAND E_RESET_AREA => SAH->(DBSETORDER(1))
*--------------------------------------------------------------------

/* ====================================================*
* Função: IntegDefK
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix
* Obs:
* =====================================================*/
*--------------------------------------------------------------------*
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
*--------------------------------------------------------------------*
Local oEasyIntEAI
Local lRet

Private lMsErroAuto  := .F.
Private nManuSJ5     := 0

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)

	oEasyIntEAI:oMessage:SetVersion("2.002|2.003|2.004")
	oEasyIntEAI:oMessage:SetMainAlias("SA5")
    oEasyIntEAI:oMessage:SetBFunction( {|oEasyMessage| IntegA5MT61(oEasyMessage:GetEAutoArray("SA5"),oEasyMessage:GetOperation()) ,IF(!lMSErroAuto .AND. nManuSJ5#0,EICTU100(oEasyMessage:GetEAutoArray("SJ5"),,nManuSJ5),) } )
   
	oEasyIntEAI:SetModule("EIC",17)
	// Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "PF060RECB") //RECEBIMENTO DE BUSINESS MESSAGE     (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "PF060RESB") //RESPOSTA SOBRE O RECEBIMENTO        (<-Response)

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()

/*********
Revisão: fev/2017
         acrescentado o recebimento da tag ItemVendorCode
         tratamento para atualização de todos os cadastros,
         considerando a chave fabricante.
************************************************************/
*------------------------------------------------*
Function PF060RECB(oMessage)
*------------------------------------------------*
Local oBusinessCont := oMessage:GetMsgContent()
Local oBatch        := EBatch():New()
Local oRec          := ERec():New()
Local oExecAuto     := EExecAuto():New()
Local oBusinesEvent := oMessage:GetEvtContent()
Local cEvento       := Upper(EasyGetXMLinfo(,oBusinesEvent,"_Event"))
LOCAL cCod_I        := ""
LOCAL cDE           := ""
LOCAL cPara         := ""
LOCAL cForn         := ""
LOCAL cLoja         := ""
Local cFabricante   := AvKey("", "A5_FABR")
Local cFabrLoja     := AvKey("", "A5_FALOJA")
Local lInclui

   cForn :=EasyGetXMLinfo("A5_FORNECE", oBusinessCont, "_VendorCode" )
   cLoja :=AvKey(".","A5_LOJA"  )
   cCod_I:=EasyGetXMLinfo("A5_PRODUTO", oBusinessCont, "_ItemCode" )

   SA5->(DBSetOrder(1))// A5_FILIAL + A5_FORNECE + A5_LOJA + A5_PRODUTO +A5_FABR + A5_FALOJA
   lInclui:= !SA5->(DBSeek(xFilial() + cForn + cLoja + cCod_I)) .And. cEvento != "DELETE"

   While SA5->(!Eof()) .And. SA5->A5_FILIAL == SA5->(xFilial()) .And.;
         SA5->A5_FORNECE == cForn .And. SA5->A5_LOJA == cLoja .And. SA5->A5_PRODUTO == cCod_I .Or. lInclui

      oRec:= ERec():New()
      oExecAuto:= EExecAuto():New()

      If !lInclui
         cFabricante:= SA5->A5_FABR
         cFabrLoja  := SA5->A5_FALOJA
      EndIf

      oRec:SetField("A5_FORNECE" , cForn ) //Cód. Fornecedor"
      oRec:SetField("A5_LOJA"    , cLoja )
      oRec:SetField("A5_PRODUTO" , cCod_I) //Cód. Produto"
      oRec:SetField("A5_FABR"    , cFabricante)
      oRec:SetField("A5_FALOJA"  , cFabrLoja)

      If IsCpoInXML(oBusinessCont, "_ItemVendorCode")
         oRec:SetField("A5_CODPRF"  , EasyGetXMLinfo("A5_CODPRF", oBusinessCont, "_ItemVendorCode" ) ) //código do produto no fornecedor
      EndIf

      cDE:=EasyGetXMLinfo("AH_CODERP",oBusinessCont,"_FornecUnitOfMeasureCode" )//Na exclusao a TAG FornecUnitOfMeasureCode nem vem

      SAH->(DBSETORDER(2))//AH_FILIAL+AH_CODERP
      IF !EMPTY(cDE) .AND. SAH->(DBSEEK( xFILIAL()+cDE ))//Na exclusao a cDE é branco
         cDESA5:=AVKEY(SAH->AH_UNIMED,"A5_UNID")
         cDE:=AVKEY(SAH->AH_UNIMED,"J5_DE")
      ELSE
         cDESA5:=EasyGetXMLinfo("A5_UNID",oBusinessCont,"_FornecUnitOfMeasureCode" )
         cDE:=EasyGetXMLinfo("J5_DE",oBusinessCont,"_FornecUnitOfMeasureCode" )
      ENDIF
      SAH->(DBSETORDER(1))

      oRec:SetField("A5_UNID" , cDESA5 ) //Un. de Medida Forn."

      oExecAuto:SetField("SA5",oRec,.F.)


      IF cEvento == "DELETE"
         cDE:=AVKEY(SA5->A5_UNID,"J5_DE")
      ENDIF

      SB1->(DBSETORDER(1))
      SB1->(DBSEEK( xFILIAL()+cCod_I ))
      if AVKEY(SB1->B1_UM,"J5_PARA") <> cDE
   	   oRec:= ERec():New()
   	   oRec:SetField("J5_DE"    , cDE ) //Un. de Medida Forn."
   	   oRec:SetField("J5_PARA"  , cParaSJ5:=AVKEY(SB1->B1_UM,"J5_PARA") )
   	   oRec:SetField("J5_COEF"  , EasyGetXMLinfo("J5_COEF" , oBusinessCont, "_ConversionFactor" ) )
   	   oRec:SetField("J5_COD_I" , cCod_I:=EasyGetXMLinfo("J5_COD_I", oBusinessCont, "_ItemCode" ) )
   	   oRec:SetField("J5_FORN"  , cForn :=EasyGetXMLinfo("J5_FORN" , oBusinessCont, "_VendorCode" ) ) //Cód. Fornecedor"
   	   oRec:SetField("J5_FORLOJ", cLoja :=AvKey(".","J5_FORLOJ") )

   	   oExecAuto:SetField("SJ5",oRec)

   	   SJ5->(DBSETORDER(1))//J5_FILIAL+J5_DE+J5_PARA+J5_COD_I+J5_FORN+J5_FORLOJ
   	   IF cEvento == "DELETE"
   	      If SJ5->(dbSeek(xFilial()+cDE+cParaSJ5+cCod_I+cForn+cLoja))
   	//       VARINFO("ACHOU DELETE",cDE+cParaSJ5+cCod_I+cForn+cLoja)
   	         nManuSJ5:=5//Excluir
   	      ENDIF
   	   ELSE
   	      If SJ5->(dbSeek(xFilial()+cDE+cParaSJ5+cCod_I+cForn+cLoja))
   	//       VARINFO("ACHOU",cDE+cParaSJ5+cCod_I+cForn+cLoja)
   	         nManuSJ5:=4
   	      ELSE
   	//       VARINFO("NAO ACHOU",cDE+cParaSJ5+cCod_I+cForn+cLoja)
   	         nManuSJ5:=3//Incluir
   	      ENDIF
   	   ENDIF
      EndIf

      oBatch:AddRec(oExecAuto)

      If lInclui
         Exit
      EndIf

      SA5->(DBSkip())
   EndDo

Return oBatch

*-------------------------------------------------*
Function PF060RESB(oMessage)
*-------------------------------------------------*
Local oRespond     := ENode():New()
Local oBusinessCont:= oMessage:GetMsgContent()

    If !oMessage:HasErrors()
        oRespond:SetField('CustomerVendorInternalId', EasyGetXMLinfo(, oBusinessCont, "_CustomerVendorInternalId"))
        oRespond:SetField('ItemInternalId', EasyGetXMLinfo(, oBusinessCont, "_ItemInternalId"))

    Else
       oRespond := oMessage:GetContentList("RESPONSE")
    EndIf

Return oRespond


Static Function IntegA5MT61(aSA5,nOpc)
Local lRet        := .T.
Local oModel      := Nil
Local oModelGrid  := NIL
Local nI
Local nProd
Local nForn
Local nLoja
Local aErro := {}

oModel := FWLoadModel('MATA061')

If nOpc == 3 //Inclusao
   oModel:SetOperation(MODEL_OPERATION_INSERT)
   oModel:Activate()
   For nI := 1 To Len(aSA5)
      If aSA5[nI][1] == "A5_PRODUTO"   //Cabeçalho
         oModel:SetValue('MdFieldSA5',aSA5[nI][1],aSA5[nI][2])
         oModel:SetValue('MdFieldSA5','A5_NOMPROD',Posicione("SB1",1,xFilial("SB1") + aSA5[nI][2],"B1_DESC"))
      Else //Itens
         oModel:SetValue('MdGridSA5',aSA5[nI][1],aSA5[nI][2])
      EndIf
   Next

   If Len(aSA5) > 0 
      lRet := oModel:VldData()
      If lRet
         lRet := oModel:CommitData()
      EndIf
   Else
      EasyHelp("Não foi possível efetuar a inclusão do Produto x Fornecedor. Sem dados para Inclusão!")
      lRet := .F.
   Endif
Else //Alteracao/Exclusao
   oModel:SetOperation(MODEL_OPERATION_UPDATE)
   oModel:Activate()
   SA5->(dbSetOrder(2)) //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
   If (nProd := aScan(aSA5,{|x| x[1] == "A5_PRODUTO"})) > 0 .And. ;
      (nForn := aScan(aSA5,{|x| x[1] == "A5_FORNECE"})) > 0 .And. ;
      (nLoja := aScan(aSA5,{|x| x[1] == "A5_LOJA"}))    > 0 .And. ;
      SA5->(DbSeek(xFilial("SA5") + AvKey(aSA5[nProd][2],"A5_PRODUTO") + AvKey(aSA5[nForn][2],"A5_FORNECE") + AvKey(aSA5[nLoja][2],"A5_LOJA")))

      oModelGrid := oModel:GetModel('MdGridSA5')
      //oModelGrid:SeekLine({{"A5_PRODUTO",aSA5[nProd][2]},{"A5_FORNECEDOR",aSA5[nForn][2]},{"A5_LOJA",aSA5[nLoja][2]}})
      oModelGrid:SeekLine({{"A5_FORNECE",aSA5[nForn][2]},{"A5_LOJA",aSA5[nLoja][2]},{"A5_PRODUTO",aSA5[nProd][2]}})
      If nOpc == 4 //Alteracao
         For nI := 1 To Len(aSA5)
            If aSA5[nI][1] != "A5_PRODUTO" .And. oModelGrid:CanSetValue(aSA5[nI][1])  //Cabeçalho
               oModel:SetValue('MdGridSA5',aSA5[nI][1],aSA5[nI][2])//oModelGrid:SetValue('MdGridSA5',aSA5[nI][1],aSA5[nI][2])
            EndIf
         Next
      ElseIf nOpc == 5 //Exclusao
         oModelGrid:DeleteLine() 
      EndIf

      lRet := oModel:VldData()
 
      If lRet
         lRet := oModel:CommitData()
      Endif
 
   Else
      EasyHelp("Produto x Fornecedor não encontrado!")
      lRet := .F.
   EndIf
EndIf

If !lRet
   aErro := oModel:GetErrorMessage()
   If Len(aErro) > 0
      //-- Monta o Texto que será mostrado na tela
      AutoGrLog("Id do formulário de origem:" + ' [' + AllToChar(aErro[01]) + ']')
      AutoGrLog("Id do campo de origem: "     + ' [' + AllToChar(aErro[02]) + ']')
      AutoGrLog("Id do formulário de erro: "  + ' [' + AllToChar(aErro[03]) + ']')
      AutoGrLog("Id do campo de erro: "       + ' [' + AllToChar(aErro[04]) + ']')
      AutoGrLog("Id do erro: "                + ' [' + AllToChar(aErro[05]) + ']')
      AutoGrLog("Mensagem do erro: "          + ' [' + AllToChar(aErro[06]) + ']')
      AutoGrLog("Mensagem da solução:"        + ' [' + AllToChar(aErro[07]) + ']')
      AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
      AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')
   EndIf

EndIf

oModel:DeActivate()

oModel:Destroy()

Return lRet