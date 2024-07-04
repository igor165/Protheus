#INCLUDE "Average.ch"
#INCLUDE "EICFI410.ch"
#Include "FWBROWSE.ch"
#Include "TOPCONN.ch"

/*  
Programa        : EICFI410.PRW
Objetivo        : Integração EAI para geração de títulos provisórios
Autor           : Jacomo/ Average Tecnologia S/A
Data/Hora       : 25/06/2014
Revisão         : WFS - dez/2014
Obs.            :
*/

*--------------------------------------------------------------------
Function EICFI410(lEnvio,nOpc,aGrava)
*--------------------------------------------------------------------
LOCAL n
Local lOk:= .T.
Local nRecEW7Atu,i,j
DEFAULT lEnvio := .T.
PRIVATE aRecNo := {}
Private nPosRec := 0

Begin Sequence

If !FI410Valid()
   lOk:= .F.
   Break
EndIf

IF lEnvio 
   FOR n := 1 TO LEN(aGrava)
       EW7->(DBGOTO(aGrava[n]:nRecNo))
       IF (!EMPTY(EW7->EW7_TITERP) .AND. nOpc == 5) .OR. (nOpc == 3 .And. aGrava[n]:nValor >= 0.01) //não gerar títulos provisórios com valor 0
          cPO_DI := IF(ALLTRIM(aGrava[n]:cTipo) == "PR",aGrava[n]:cPoNum, aGrava[n]:cHawb)
          IF (nPos := ASCAN(aRecNo,{|X| x[1] == cPO_DI .And.;
                                        x[4] == aGrava[n]:cTipo}) )  ==  0  

             AADD(aRecNo,{cPO_DI, aGrava[n]:cFornecedor, aGrava[n]:cLoja, aGrava[n]:cTipo,{aGrava[n]:nRecNo} } )
          ELSE
             IF ASCAN(aRecNo[nPos][5],{|Y| Y == aGrava[n]:nRecNo}) == 0   
                AADD(aRecNo[nPos][5],aGrava[n]:nRecNo)
             ENDIF
          ENDIF
       ENDIF
   NEXT
   IF LEN(aRecNo) > 0 
      FOR n:= 1 TO LEN(aRecNo)
         nPosRec := n
         MsAguarde({|| lOk:= EasyEnvEAI("EICFI410",nOpc)}, STR0002) //"Integração EAI - Despesas Provisórias. Aguarde..."
         IF !lOk //!EasyEnvEAI("EICFI410",nOpc)
            MSGALERT(StrTran(STR0001,"###",ALLTRIM(cPO_DI)))//"Realize os ajustes e a regravação do processo ### para a atualização dos títulos provisórios no ERP."
            
            //NCF - 06/12/2016 - Tratamento necessário para que os registros sejam tratados corretamente caso haja falha
            //                   na integração de uma das listas de tipo de títulos a integrar.
            nRecEW7Atu := EW7->(Recno())
            //For i := 1 To Len (aRecno[n])
            If Len(aRecno[n][5]) > 0
               For j := 1 To Len (aRecno[n][5])

                  EW7->(DbGoTo(aRecno[n][5][j]))
                  If EW7->(!Eof())
                     EW7->(RecLock("EW7",.F.)) 
                     If !Empty(EW7->EW7_TITERP) .And. EW7->(DELETED())
                        EW7->(DbRecall())        //Voltar registros que ainda possuam título de referência no ERP Externo
                     ElseIf Empty(EW7->EW7_TITERP) .And. !EW7->(DELETED()) 
                        EW7->(DbDelete())        //Apagar registros que já tiveram o título referente apagado no ERP Externo
                     EndIf
                     EW7->(MsUnlock())
                  EndIf

               Next j
            EndIf
            //Next i
            EW7->(DbGoTo(nRecEW7Atu))
            Break            
         ENDIF
      NEXT
   ENDIF
ENDIF

End Sequence
Return lOk


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

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.000")
	oEasyIntEAI:oMessage:SetMainAlias("EW7")
	oEasyIntEAI:SetModule("EIC",17)

	// Envio 
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "FI410SEND") //ENVIO                               (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "FI410RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
	// Envio 

	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 

/* ====================================================*
* Função: FI410SEND(oMessage)
* Objetivo: Envio das parcelas de Cambio
* Obs: 
* =====================================================*/
*------------------------------------------------*
Function FI410SEND(oMessage) 
*------------------------------------------------* 
Local oXml       := EXml():New()
Local oBusiness  := ENode():New()
Local oBusinEvent:= ENode():New() 
Local oIdent     := ENode():New()  
Local oRec       := ENode():New()
Local aOrd       := {}
Local oListOfAccountPayable
LOCAL nI,nII,xI
LOCAL nTotVal,cFase
Local aRatCC := {} 
Local aValorCC := {}
Local cForn:= ""
Local cFil:= ""

   aOrd := SaveOrd({"EW7","EC6","SW2","SW3","SYB","SYF","SW9"})
   EC6->(DBSETORDER(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC 
   SYB->(DBSETORDER(1))//YB_FILIAL+YB_DESP
   EW7->(DBSETORDER(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
   SYF->(DBSETORDER(1))//YF_FILIAL+YF_MOEDA
   SW9->(DBSetOrder(3))
   EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+"150"))
   
   nTotVal:= 0
   nTotCC := 0

   cPO_Hawb := aRecNo[nPosRec][1]
   If ALLTRIM(aRecNo[nPosRec][4]) == "PR"
      cFase:= "SW3"
      cForn:= aRecNo[nPosRec][2]
      cFil:= SW3->(xFilial("SW3"))
   Else
      If SW9->(DBSeek(xFilial() + cPO_Hawb))      
         cFase:= "SW8"
         cForn:= ""
         cFil:= SW8->(xFilial("SW8"))
      Else
         cFase:= "SW7"
         cForn:= ""
         cFil:= SW7->(xFilial("SW7"))
      EndIf
   EndIf
   aValorCC   := LC500RatCC(cFil, aRecNo[nPosRec][1],cForn,               ,AVSX3('W3_PRECO',4), , , ,cFase)

   FOR nII := 1 TO LEN(aValorCC)
      nTotCC += aValorCC[nII][2]
   NEXT
  //Entity e Event
   oBusinEvent:SetField("Entity", "EICFI410")

   oBusinEvent:SetField("Event" , IF(nEAIEvent <> 5,"upsert","delete"))

  //<Identification>

     oKeyNode:= ENode():New()
     oKeyNode:SetField(EAtt():New("name","Type"))
     oKeyNode:SetField(ETag():New("",aRecNo[nPosRec][4]))
     oIdent:SetField(ETag():New("key",oKeyNode))

     oKeyNode:= ENode():New()
     oKeyNode:SetField(EAtt():New("name","Process"))
     oKeyNode:SetField(ETag():New("",cPO_Hawb))
     oIdent:SetField(ETag():New("key",oKeyNode))

  //<Identification>

  oBusinEvent:SetField("Identification",oIdent)

  //<BusinessEvent>

   //capa
   //<BusinessContent>
   oBusiness:SetField("CompanyId"             ,EICEmpFLogix())
   oBusiness:SetField("CompanyInternalId"     ,EICEmpFLogix())
   oBusiness:SetField("BranchId"              ,EICFilFLogix())
   oBusiness:SetField("batchNumber"           ,"")//Não utilizado
   
   //<ListOfSourceDocument>
      oListSrcDoc := ENode():New()
      //<SourceDocument>
           oSourcDoc := ENode():New()
           oSourcDoc:SetField("SourceDocument",cPO_Hawb)
      //</SourceDocument>
      oListSrcDoc:SetField("SourceDocument",oSourcDoc)
   //</ListOfSourceDocument>
   
   oListOfAccountPayable := ENode():New()

   For xI := 1 TO Len(aRecNo[nPosRec][5])
      EW7->(dbGoTo(aRecNo[nPosRec][5][xI]))
      EC6->(DBSEEK(xFilial("EC6") + "IMPORT" + EW7->EW7_DESPES))
      oAccountPayable := ENode():New()
      oAccountPayable:SetField("InternalId"            ,EW7->(RecNo()))
      oAccountPayable:SetField("DocumentPrefix"        ,EC6->EC6_PREFIX)
      oAccountPayable:SetField("DocumentNumber"        ,EW7->EW7_TITERP)
      oAccountPayable:SetField("DocumentParcel"        ,xI)
      oAccountPayable:SetField("DocumentTypeCode"      ,EC6->EC6_TPTIT)
      oAccountPayable:SetField("BlockAmendmentDocument","B")
      
      oAccountPayable:SetField("ListOfSourceDocument",oListSrcDoc)
	  
      //oAccountPayable:SetField("IssueDate"   ,EasyTimeStamp(dDataBase,.T.,.T.)) //comentado por wfs - 08/08/2017
      oAccountPayable:SetField("IssueDate"   ,EasyTimeStamp(EW7->EW7_DT_EMI,.T.,.T.)) //wfs - 08/08/2017
      oAccountPayable:SetField("DueDate"     ,EasyTimeStamp(EW7->EW7_DT_VEN,.T.,.T.))
      oAccountPayable:SetField("RealDueDate" ,EasyTimeStamp(DataValida(EW7->EW7_DT_VEN),.T.,.T.))
      oAccountPayable:SetField("VendorCode"  ,EW7->EW7_FORN)
      oAccountPayable:SetField("VendorInternalId"  ,EW7->EW7_FORN)
      oAccountPayable:SetField("StoreId"     ,EW7->EW7_LOJA)
      oAccountPayable:SetField("NetValue"    ,EW7->EW7_VALOR)
      oAccountPayable:SetField("GrossValue"  ,EW7->EW7_VALOR)
	  
      IF SYF->(DBSEEK(xFilial("SYF")+EW7->EW7_MOEDA)) .AND. EC6->EC6_TXCV = "2"
         cCodERP := SYF->YF_CODCERP
      ELSE
         cCodERP := SYF->YF_CODVERP
      ENDIF   
      
      IF ALLTRIM(EW7->EW7_MOEDA) == "R$"
         nTaxa := 1
      ELSE
         nTaxa := BuscaTaxa(EW7->EW7_MOEDA,EW7->EW7_DT_VEN,,.F.,,,EC6->EC6_TXCV)
      ENDIF
      oAccountPayable:SetField("CurrencyCode",cCodERP)
      oAccountPayable:SetField("CurrencyInternalId",EW7->EW7_MOEDA)
      oAccountPayable:SetField("CurrencyRate",nTaxa)
      //<ApportionmentDistribution>
         oAppDistri := ENode():New()

         IF LEN(aValorCC) > 0 
            aRatCC := LC500RatCC(cFil,aRecNo[nPosRec][1],aRecNo[nPosRec][2],,AVSX3('W3_PRECO',4),EW7->EW7_VALOR,aValorCC,nTotCC,cFase)
		    FOR nI := 1 TO LEN(aRatCC)
               //<Apportionment>
                  oApportionment:= ENode():New()
                  oApportionment:SetField("CostCenterInternalId",aRatCC[nI][1]) //CostCenterCode
                  oApportionment:SetField("Value"         ,aRatCC[nI][2]) 
                  //</Apportionment>
                  oAppDistri:SetField("Apportionment",oApportionment)
               //</ApportionmentDistribution>
            NEXT
         ENDIF

         oAccountPayable:SetField("ApportionmentDistribution",oAppDistri)
      //<ApportionmentDistribution>
      
      SYB->(DBSEEK(xFilial("SYB")+EW7->EW7_DESPES))      
      cObs := AllTrim(EW7->EW7_DESPES) +"-"+  AllTrim(SYB->YB_DESCR) + ", fase: " + IF(ALLTRIM(aRecNo[nPosRec][4]) == "PR", "Pedido", "Embarque" )
      oAccountPayable:SetField("Observation",IF(!Empty(cObs),cObs,""))
      oAccountPayable:SetField("Origin"     ,"SIGAEIC")
      
      IF EW7->(FIELDPOS("EW7_NATFIN")) <> 0 .AND. !EMPTY(EW7->EW7_NATFIN)
         oAccountPayable:SetField("FinancialNatureInternalId" ,EW7->EW7_NATFIN)
      ELSEIF EC6->(FIELDPOS("EC6_NATFIN")) <> 0 .AND. !EMPTY(EC6->EC6_NATFIN)
         oAccountPayable:SetField("FinancialNatureInternalId" ,EC6->EC6_NATFIN)
      ENDIF      
	  
	  oListOfAccountPayable:SetField("AccountPayableDocument", oAccountPayable)
   Next xI
   
   oBusiness:SetField("ListOfAccountPayableDocument",oListOfAccountPayable)
   
   oRec:SetField("BusinessEvent"  ,oBusinEvent)// OK
   oRec:SetField("BusinessContent",oBusiness) //  OK
   oXml:AddRec(oRec)
   
RestOrd(aOrd,.t.)

Return oXml


/* ====================================================*\
* Função: FI410RESP(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Function FI410RESP(oMessage)
*------------------------------------------------*
Local oRetCont       := oMessage:GetRetContent()
Local oBusinessEvent := oMessage:GetEvtContent()
Local cPO_Hawb:=cForn:=cLoja:=cTipo:=""
Local aOrd := SaveOrd({"EW7"}) 
Local i, nEW7Rec, aArray, oList

cEvent:= EasyGetXMLinfo(,oBusinessEvent, "_Event" )//Evento do XML
If IsCpoInXML(oRetCont, "_ListOfInternalIdDocument") .AND. IsCpoInXML(oRetCont:_ListOfInternalIdDocument, "_InternalIdDocument")
   
   oList:= oRetCont:_ListOfInternalIdDocument:_InternalIdDocument

   If ValType(oList) <> "A"
      aArray := {oList}
   Else
      aArray := oList
   EndIf
   
   For i := 1 To len(aArray)
      nEW7Rec    := val(EasyGetXMLinfo(,aArray[i],"_Origin"))
	  cDocNumber := EasyGetXMLinfo(,aArray[i],"_Destination")
	  
	  EW7->(dbGoTo(nEW7Rec))
	     
		 EW7->(RecLock("EW7",.F.))
         IF UPPER(cEvent) == "UPSERT" // Se for liquidação, grava o numero retornado pelo ERP
            EW7->EW7_TITERP:= cDocNumber
         ELSE // Caso Estorno, apaga o numero gravado.
            EW7->EW7_TITERP:= ""
         ENDIF
         EW7->(MSUNLOCK())
		 
	  //EndIf
	  
   Next i
   
EndIf

oMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})

RestOrd(aOrd,.t.)
Return oMessage

/*
Função   : FI410Valid()
Objetivo : Verificação dos dados obrigatórios dos cadastros relacionados para realização da integração 
Autor    : wfs 
Data     : abr/2015
Revisão  :
Obs.     : 
*/
Function FI410Valid()
Local lRet:= .T.
Local cEvento
Local aOrd:= SaveOrd({"EC6"})

Begin Sequence

   EC6->(DBSetOrder(1)) //EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
   
   //Evento contábil default - assumirá os eventos abaixo se não houver outra informada no cadastro da despesa  
   cEvento:= "150"
   EC6->(DBSeek(xFilial() + AvKey("IMPORT", "EC6_TPMODU") + AvKey(cEvento, "EC6_ID_CAM")))

   If EC6->(FieldPos("EC6_NATFIN")) == 0 .Or. Empty(EC6->EC6_NATFIN)
      MsgStop(StrTran(StrTran(STR0003, "####", AvSx3("EC6_NATFIN", AV_TITULO)), "$$$$", cEvento), STR0004) //"O tipo de despesa do ERP para a geração do título no financeiro não foi informado. Verifique o campo '####' do cadastro de Eventos Contábeis, evento IMPORT $$$$.", "Atenção"
      lRet:= .F.
      Break
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return lRet

/*
Programa   : FI410Prov()
Objetivo   : Exibição dos títulos provisórios que possuem títulos gerados no ERP.             
Parâmetros : cFase - fase P.O. ou Embarque
Retorno    : 
Autor      : WFS
Data       : 
Revisão    : 
*/

Function FI410Prov(cFase)
Local oDlg, oPanel, oBrowse, oMsMget
Local cTitulo:= "Despesas Provisórias da fase: "
Local bOk:= {|| oDlg:End()}
Local bCancel:= bOk
Local aCampos:= {}, aDados:= {}
Local nCont
Local cProcesso, cCampo, cAlias
Local aEnchoice:= {}
Private aTela:= {}, aGets:= {}
Default cFase:= "PR"

   /* Definição de campos que serão exibidos na visualização. */
   aCampos:= {"EW7_DESPES","&DESCDES","EW7_FORN", "A2_NOME", "EW7_MOEDA", "EW7_VALOR", "EW7_DT_VEN", "$VENCREAL", "EW7_TITERP"}
   If cFase == "PR"
      cCampo:= AvSx3("W3_PO_NUM", AV_TITULO)
      cProcesso:= AllTrim(SW3->W3_PO_NUM)
      cTitulo += "Pedido"
      aEnchoice:= {"W2_PO_NUM", "W2_FORN", "W2_FORNDES", "W2_IMPORT", "W2_IMPNOME"}
      cAlias:= "SW2"
   Else
      cCampo:= AvSx3("W6_HAWB", AV_TITULO)
      cProcesso:= AllTrim(SW6->W6_HAWB)
      AAdd(aCampos, "EW7_PO_NUM")
      cTitulo += "Embarque/ Desembaraço"
      aEnchoice:= {"W6_HAWB", "W6_IMPORT", "W6_IMPORVM"}
      cAlias:= "SW6"
   EndIf

   /* Carrega em memória os registros da parte superior. */
   DBSelectArea(cAlias)
   For nCont:= 1 To Len(aEnchoice)
      If AvSx3(aEnchoice[nCont], 16) == "V"
         CriaVar(aEnchoice[nCont])
      Else
         M->&(aEnchoice[nCont]):= &(aEnchoice[nCont])
      EndIf
   Next nCont

   /* Retorna os dados que serão exibidos na parte inferior. */ 
   aDados:= RetDados(aCampos, cFase)
   
   Define MsDialog oDlg Title cTitulo From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM, DLG_COL_FIM Of oMainWnd Pixel

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, (oDlg:nRight-oDlg:nLeft*0.85), (oDlg:nBottom-oDlg:nTop)*0.85)

      /* Parte superior */
      oMsMget:= MsMget():New(cAlias,, 2,,,, aEnchoice, {0, 0, 130, 0}, {},,,,, oDlg,,, .F.,, .T.)

      /* Parte inferior */
      oBrowse:= FWBrowse():New(oPanel)

         oBrowse:SetDataArray()
         oBrowse:SetArray(aDados) 
         oBrowse:DisableSeek()

         For nCont:= 1 To Len(aCampos)
            If Left(aCampos[nCont], 1) == "$"
               Add COLUMN oColumn Data &("{|| aDados[oBrowse:nAt][" + Str(nCont) + "]}") Title "Venc. Real" Of oBrowse
            ElseIf Left(aCampos[nCont], 1) == "&"
               Add COLUMN oColumn Data &("{|| aDados[oBrowse:nAt][" + Str(nCont) + "]}") Title "Descrição" Of oBrowse
            Else
               Add COLUMN oColumn Data &("{|| aDados[oBrowse:nAt][" + Str(nCont) + "]}") Title AvSx3(aCampos[nCont], AV_TITULO) Size AvSx3(aCampos[nCont], AV_TAMANHO) Picture AvSx3(aCampos[nCont], AV_PICTURE) Of oBrowse
            EndIf
         Next nCont

      oBrowse:Activate()

      oMsMget:oBox:Align:= CONTROL_ALIGN_TOP
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      oDlg:lMaximized := .T.
	Activate MsDialog oDlg On Init (EnchoiceBar(oDlg, bOk, bCancel))

Return

/*
Programa   : RetDados()
Objetivo   : Filtro de dados a serem exibidos             
Parâmetros : aCampos - campos a serem considerados no retorno de dados
             cFase - fase P.O. ou Embarque, utilizado para filtro de dados
Retorno    : aDados - array com as despesas provisórias a serem exibidas   
Autor      : WFS
Data       : 
Revisão    : 
*/
Static Function RetDados(aCampos, cFase)
Local cQuery:= "", cQuery2:= "", cJoin:= "", cWhere:= "", cDelete:= "", cDelete2:= ""
Local cCpoVenc,cCpoDesc 
Local nCont
Local aDados:= {}, aReg:= {}

Begin Sequence

   If TcSrvType() <> "AS/400"
      cDelete := " And EW7.D_E_L_E_T_ <> '*'"
      cDelete2:= " And D_E_L_E_T_ <> '*'"
   EndIf

   cQuery:= "Select "
   For nCont:= 1 To Len(aCampos)
      If nCont > 1
         cQuery += ", "
      EndIf
      If Left(aCampos[nCont], 1) == "$"
         cCpoVenc:= SubStr(aCampos[nCont], 2, Len(aCampos[nCont]))
         cQuery += "EW7_DT_VEN " + cCpoVenc
      ElseIf Left(aCampos[nCont], 1) == "&"
         cCpoDesc:= SubStr(aCampos[nCont], 2, Len(aCampos[nCont]))
         cQuery += "EW7_DESPES " + cCpoDesc
      Else
         cQuery += aCampos[nCont]
      EndIf
   Next nCont
   
   cQuery += " From " + RetSqlName("EW7") + " EW7"
   
   cJoin:= " Inner Join " +  RetSqlName("SA2") + " On A2_COD = EW7_FORN And A2_FILIAL = '" + SA2->(xFilial()) + "'"
   
   /* Provisórios da fase Purchase Order.*/
   If cFase == "PR"
      cWhere:= " Where EW7_FILIAL = '" + SW2->(xFilial()) + "' And EW7_PO_NUM = '" + AllTrim(SW2->W2_PO_NUM) + "' And EW7_TPTIT = 'PR' And EW7_TITERP <> '' "     
   EndIf
   
   /* Provisórios da fase Embarque.*/
   If cFase == "PRE"

      /* Pedidos que compõem o embarque/ desembaraço. */
      cQuery2:= "Select W7_PO_NUM from " + RetSqlName("SW7")
      cQuery2+= " Where W7_FILIAL = '" + SW7->(xFilial()) + "' And W7_HAWB = '" + SW6->W6_HAWB + "'"
      cQuery2+= cDelete2
      
      cQuery2:= ChangeQuery(cQuery2)
      TcQuery cQuery2 Alias "PED" New
      
      cWhere := " Where EW7_FILIAL = '" + SW6->(xFilial()) + "' And EW7_TITERP <> ''"
      cWhere += " And (EW7_HAWB = '" + AllTrim(SW6->W6_HAWB) + "' And EW7_TPTIT = 'PRE' Or ("
      
      PED->(DBGoTop())
      nCont:= 1
      While PED->(!Eof())
         If nCont == 1
            cWhere += "EW7_PO_NUM = '" + PED->W7_PO_NUM + "'"
            nCont++
         EndIf
         cWhere += " Or EW7_PO_NUM = '" + PED->W7_PO_NUM + "'" 
         PED->(DBSkip())
      EndDo
      cWhere += ") And EW7_DESPES = '101' And EW7_TPTIT = 'PR')"
      PED->(DBCloseArea())
   EndIf

   /* Montagem da Query com as despesas provisórias.*/
   cQuery += cJoin + cWhere + cDelete
   cQuery:= ChangeQuery(cQuery)
   TcQuery cQuery Alias "PROV" New

   For nCont := 1 To Len(aCampos)
      If Left(aCampos[nCont], 1) == "$"
         TcSetField("PROV", cCpoVenc, "D")
      ElseIf Left(aCampos[nCont], 1) == "&"
         TcSetField("PROV", cCpoDesc, "C")
      ElseIf AvSx3(aCampos[nCont], AV_TIPO) == "N"
         TcSetField("PROV", aCampos[nCont], "N", AvSX3(aCampos[nCont], AV_TAMANHO), AvSX3(aCampos[nCont], AV_DECIMAL))
      ElseIf AvSx3(aCampos[nCont], AV_TIPO) == "D"
         TcSetField("PROV", aCampos[nCont], "D")
      EndIf 
   Next nCont
   
   /* Array com os registros a serem exibidos. */
   PROV->(DBGoTop())
   While PROV->(!Eof()) 
      aReg:= {}
      For nCont:= 1 To PROV->(FCount())
         If PROV->(FieldName(nCont)) == cCpoVenc
            AAdd(aReg, DataValida(PROV->&(FieldName(nCont))))
         ElseIf PROV->(FieldName(nCont)) == cCpoDesc
            aAdd(aReg, if(SYB->(dbSeek(xFilial()+PROV->&(FieldName(nCont)))),SYB->YB_DESCR,"") )
         Else
            AAdd(aReg, PROV->&(FieldName(nCont)))
         EndIf
      Next nCont
      AAdd(aDados, AClone(aReg))
      PROV->(DBSkip())
   EndDo
   
   PROV->(DBCloseArea())
   
End Sequence

Return AClone(aDados)
