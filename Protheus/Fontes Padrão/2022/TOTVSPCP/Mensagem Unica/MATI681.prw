#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FWMVCDEF.CH'
#Include 'MATI681.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI681
Funcao de integracao com o adapter EAI para envio e recebimento do
apontamento da produção (SH6) utilizando o conceito de mensagem unica.

@param   oXMLEnv       Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Lucas Konrad França
@version P12
@since   24/09/2015
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function MATI681(oXMLEnv, nTypeTrans, cTypeMessage)
   Local cVersao     := ""
   Local lRet        := .T.
   Local cXmlRet     := ""
   Local l681INT     := ExistBlock('MATI681INT')
   Local lExec       := .T.
   Local aRetPE      := {}
   Local aRet        := {}

   Private oXML      := oXMLEnv
   Private lIntegPPI := .F.

   //Verifica se está sendo executado para realizar a integração com o PPI.
   //Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
   If Type("lRunPPI") == "L" .And. lRunPPI
      lIntegPPI := .T.
   EndIf

   //Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      If cTypeMessage == EAI_MESSAGE_BUSINESS

         // Versão da mensagem
         If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
            cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
         Else
            If Type("oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text)
               cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text, ".")[1]
            Else
               lRet    := .F.
               cXmlRet := STR0001 //"Versão da mensagem não informada!"
               Return {lRet, cXmlRet}
            Endif
         EndIf
  
         If cVersao != "1" .And. cVersao != "2"
            lRet    := .F.
            cXmlRet := STR0002 //"A versão da mensagem informada não foi implementada!"
            Return {lRet, cXmlRet}
         Else
            If l681INT                                                                   
               aRetPE:= ExecBlock('MATI681INT',.F.,.F.,oXML)                                    
               lExec := aRetPE[1]                                            
            Endif

            If lExec
               BeginTran()                                                   
                  aRet := runIntegra(oXML, nTypeTrans, cTypeMessage, cVersao)
                  If !aRet[1]                                                
                     DisarmTransaction()                                     
                  EndIf                                                      
               EndTran()                                                     
               MsUnLockAll()                                                 
            ElseIf l681INT                                                   
               aAdd(aRet, aRetPE[2])
               aAdd(aRet, aRetPE[3])
            EndIf                                                            
         EndIf
      Endif
   ElseIf nTypeTrans == TRANS_SEND

   EndIf

   lRet    := aRet[1]
   cXMLRet := aRet[2]
Return {lRet, cXMLRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} runIntegra

Funcao de integracao com o adapter EAI para recebimento do apontamento de produção (SH6)
utilizando o conceito de mensagem unica.

@param	oXMLEnv			Variável com conteúdo XML para envio/recebimento.
@param	nTypeTrans		Tipo de transação. (Envio/Recebimento)
@param	cTypeMessage	Tipo de mensagem. (Business Type, WhoIs, etc)
@param	cVersao			Versão da mensagem que está sendo trafegada.

@author		Lucas Konrad França
@version	P12
@since		24/09/2015
@return		aRet  - (array)   Contém o resultado da execução e a mensagem XML de retorno.
					aRet[1] - (boolean)  Indica o resultado da execução da função
					aRet[2] - (caracter) Mensagem XML para envio

@obs		O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
			o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
			TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
			O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Static Function runIntegra(oXMLEnv, nTypeTrans, cTypeMessage, cVersao)
   Local lRet        := .T.
   Local lMT681QTAP  := ExistBlock("MTI681QTAP")
   Local cXmlRet     := ""
   Local cEvent      := ""
   Local cProduct    := ""
   Local cQuery      := ""
   Local cAlias      := ""
   Local nOperation  := 0
   Local nI          := 0
   Local lProcessa   := .T.
   Local aDados      := {}
   Local aAux        := {}
   Local cAliasCYP   := "GETCYP"

   //Local cNumOp     := "" //Definida no WSPCP.prw
   //Local cProduto   := "" //Definida no WSPCP.prw
   //Local cMaquina   := "" //Definida no WSPCP.prw
   //Local cOperacao  := "" //Definida no WSPCP.prw
   Local cLoteCtl   := ""
   Local dDtValid   := StoD("")
   Local nQtdApr    := 0
   Local nQtdRef    := 0
   //Local dDateIni   := StoD("") //Definida no WSPCP.prw
   //Local cHoraIni   := "0" //Definida no WSPCP.prw
   //Local dDateFim   := StoD("") //Definida no WSPCP.prw
   //Local cHoraFim   := "0" //Definida no WSPCP.prw
   Local dReportDat := StoD("")
   Local cHoraRpt   := ""
   Local cLocal     := ""
   Local cPT        := "P"
   Local lEstorno   := .F.
   Local dDtInSetUp := StoD("")
   Local cHrInSetUp := ""
   Local dDtFmSetUp := StoD("")
   Local cHrFmSetUp := ""
   Local cSetupCode := ""
   Local nTempOper  := 0
   Local cTurno     := ""
   Local cNumTurno  := ""
   Local cDoc       := ""
   Local cDocSerie  := ""
   Local cLocaliz   := ""
   Local dDtEstorno := StoD("")
   Local aRefugos   := {}
   Local cCodRefug  := ""
   Local cDscRefug  := ""
   Local nRefugQtd  := 0
   Local cPrdRefOrg := ""
   Local cLocRefOrg := ""
   Local cPrdRefDst := ""
   Local cLocRefDst := ""
   Local aRecursos  := {}
   Local cOperad    := ""
   Local dDtIniRec  := Stod("")
   Local cHrIniRec  := ""
   Local dDtFimRec  := StoD("")
   Local cHrFimRec  := ""
   Local nMobDir    := 0 
   Local nTmpExtra  := 0
   Local nTmpUtil   := 0
   Local cModTurno  := ""
   Local cNumTurno2 := ""
   Local aSupply    := {}
   Local cOpComp    := ""
   Local cComp      := ""
   Local nQuant     := 0
   Local cLocComp   := ""
   Local cLoclizCmp := ""
   Local cLoteComp  := ""
   Local cOperComp  := ""
   Local cRotComp   := ""
   Local cEndOrig   := ""
   Local cSeriOrig  := ""
   Local cEndDest   := ""
   Local cSeriDest  := ""
   Local cLoteWaste := ""
   Local cSubLoteW  := ""
   Local dVldLoteW  := Nil
   Local cCentroCst := ""
   Local nQtRefOrig := 0
   Local nQtRefDest := 0
   //Local lOnlyEstrn := .F. //Definida no WSPCP.prw
   Local aCabBaixa  := {}
   Local aCabCoProd := {}
   Local aBaixa     := {}
   Local aSH6       := {}
   Local aSH6Aux    := {}
   Local aErroAuto  := {}
   Local aValues    := {}
   Local aRet       := {}
   Local aIdEstorno := {}
   Local aEstRecusa := {}
   Local cLogErro   := ""
   Local nCount     := 0
   Local aDadosBC   := {}
   Local aCabBC     := {}
   Local aIteBC     := {}
   Local aStruH6    := {}
   Local aRetDatas  := {}
      
   Local lRetPE     := .F.
   Local lFimOperac := .F.
   Local lEncerraOP := .F.
   Local lIntgSFC   := Iif(SuperGetMV("MV_INTSFC",.F.,0)==1,.T.,.F.)
   Local lBackFlush := .T.
   Local lAssign    := .T.
   Local cObserva   := ""
   Local cSeqCYV    := ""
   Local nTotRefug  := 0 
   Local cEnderec   := ""
   Local lReproc    := Iif(Type("lReprocess") == "L" .And. lReprocess,.T.,.F.)
   Local lUsaASOG   := Iif(Type("aDadosSOG") == "A",.T.,.F.)
   Local lUsaIdInt  := Iif(Type('cMesIDIntg')=="C",.T.,.F.)
   Local l681EXC    := ExistBlock('MATI681EXC')

   Local oModel, oModelCY0, oModelCZP, oModelCZ0, oReverse
   
   Local lCoProduto := .F.
   
   Private oXml        := oXMLEnv
   Private lMSErroAuto := .F.
   Private lRunPPI     := .T.
   Private lAutoErrNoFile := .T.
   Private nRegSH6     := 0
   Private aXmlWaste   := {}
   Private aXmlRec     := {}
   Private aXmlSupply  := {}
   Private aReverse    := {}
   
   If !lIntegPPI .And. FindFunction("AdpLogEAI")
      AdpLogEAI(1, "MATI681", nTypeTrans, cTypeMessage)
   EndIf

   If nTypeTrans == TRANS_RECEIVE
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
            cEvent := Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
            If AllTrim(cEvent) != "UPSERT"
               lRet := .F.
               cXmlRet := STR0003 //"Event informado é inválido. Apenas 'UPSERT' válido para esta mensagem."
            EndIf
         Else
            lRet   := .F.
            cXmlRet := "Event" + STR0004 // é obrigatório."
            Return {lRet, cXMLRet}
         EndIf
      EndIf

      If Type("oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
         cProduct := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
      Else
         lRet   := .F.
         cXmlRet := "Product:Name" + STR0004 // é obrigatório."
         Return {lRet, cXMLRet}
      EndIf

      If Type("oXml:_TotvsMessage:_MessageInformation:_CompanyId:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_CompanyId:Text)
         cEmpIntg := oXml:_TotvsMessage:_MessageInformation:_CompanyId:Text
      Else
         cEmpIntg := cEmpAnt
      EndIf

      If Type("oXml:_TotvsMessage:_MessageInformation:_BranchId:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_BranchId:Text)
         cFilIntg := oXml:_TotvsMessage:_MessageInformation:_BranchId:Text
      Else
         cFilIntg := cFilAnt
      EndIf

      If AllTrim(UPPER(cProduct)) == "PPI"
         //Verifica se a integração com o PPI está ativa. Se não estiver, não permite prosseguir com a integração.
         If !PCPIntgPPI()
            lRet := .F.
            cXmlRet := STR0005 //"Integração com o PC-Factory desativada. Processamento não permitido."
            Return {lRet, cXMLRet}
         EndIf
         
         SOE->(dbSeek(xFilial("SOE")+"SC2"))
         If AllTrim(SOE->OE_VAR1) == "2" .Or. AllTrim(SOE->OE_VAR1) == "3"
            lBackFlush := .F.
         EndIf
      EndIf
      
      //Ponto de entrada para alterar as informações do XML.
      If ExistBlock("MT681ALXML")
         ExecBlock('MT681ALXML',.F.,.F.,oXml)
      EndIf

      //Estorno?
      If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReversedReport:Text") != "U" .And. ;
         !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReversedReport:Text)
         lEstorno := Iif(Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReversedReport:Text)=="TRUE",.T.,.F.)
      EndIf

      //Quantidade aprovada
      If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ApprovedQuantity:Text") != "U" .And. ;
         !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ApprovedQuantity:Text)
         nQtdApr := Val(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ApprovedQuantity:Text)
      Else
         nQtdApr := 0
      EndIf

      //Quantidade refugada
      If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ScrapQuantity:Text") != "U" .And. ;
         !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ScrapQuantity:Text)
         nQtdRef := Val(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ScrapQuantity:Text)
      Else
         nQtdRef := 0
      EndIf

      If Type('nQtdSOG') == "N"
         nQtdSOG := nQtdRef + nQtdApr
      EndIf

      //Verifica se está somente realizando o estorno do apontamento.
      If lEstorno .And. nQtdApr == 0 .And. nQtdRef == 0
         lOnlyEstrn := .T.
      EndIf

      If lEstorno
         If cVersao == "1"
            //RECNO apontamento SH6
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IntegrationReport:Text") != "U" .And. ;
               !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IntegrationReport:Text)
               If lIntgSFC
                  aAdd(aIdEstorno,oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IntegrationReport:Text)
               Else
                  nRegSH6 := Val(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IntegrationReport:Text)
                  aAdd(aIdEstorno,nRegSH6)
               EndIf
            Else
               lRet := .F.
               cXmlRet := "IntegrationReport" + STR0004 // é obrigatório."
               Return {lRet, cXMLRet}
            EndIf
         ElseIf cVersao == "2"
            oReverse := XmlChildEx(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent,"_LISTOFREVERSALAPPOINTMENTS")
            
            If oReverse != Nil
               oReverse := XmlChildEx(oReverse,"_REVERSALAPPOINTMENT")
               If oReverse == Nil
                  lRet := .F.
                  cXmlRet := "ReversalAppointment" + STR0004 // é obrigatório."
                  Return {lRet, cXMLRet}
               EndIf
               If ValType(oReverse) == "A"
                  aReverse := aClone(oReverse)
               Else
                  aReverse := {oReverse}
               EndIf
               For nI := 1 To Len(aReverse)
                  If XmlChildEx(aReverse[nI],"_REVERSALTYPE") != Nil
                     If AllTrim(aReverse[nI]:_ReversalType:Text) == "1" //Produção
                        If XmlChildEx(aReverse[nI],"_INTEGRATIONREPORT") != Nil .And. ;
                           !Empty(aReverse[nI]:_IntegrationReport:Text)
                           If lIntgSFC
                              aAdd(aIdEstorno,aReverse[nI]:_IntegrationReport:Text)
                           Else
                              aAdd(aIdEstorno,Val(aReverse[nI]:_IntegrationReport:Text))
                           EndIf
                        Else
                           lRet := .F.
                           cXmlRet := "IntegrationReport" + STR0004 // é obrigatório."
                           Return {lRet, cXMLRet}
                        EndIf
                     ElseIf AllTrim(aReverse[nI]:_ReversalType:Text) == "2" //Recusa
                        If XmlChildEx(aReverse[nI],"_INTEGRATIONREPORT") != Nil .And. ;
                           !Empty(aReverse[nI]:_IntegrationReport:Text)
                           aAdd(aEstRecusa,Val(aReverse[nI]:_IntegrationReport:Text))
                        Else
                           lRet := .F.
                           cXmlRet := "IntegrationReport" + STR0004 // é obrigatório."
                           Return {lRet, cXMLRet}
                        EndIf
                     Else //Inválido
                        lRet := .F.
                        cXmlRet := "ReversalType inválido. Informe 1 para produção ou 2 para recusa."// é obrigatório."
                        Return {lRet, cXMLRet}
                     EndIf
                  Else
                     lRet := .F.
                     cXmlRet := "ReversalType" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               Next nI
            Else
               lRet := .F.
               cXmlRet := "ListOfReversalAppointments" + STR0004 // é obrigatório."
               Return {lRet, cXMLRet}
            EndIf
         EndIf
         
         /*
         Estorna os apontamentos de perda (Recusa). Programa MATA685
         */
         For nI := 1 To Len(aEstRecusa)
            
            cAlias := GetNextAlias()
            
            cQuery := " SELECT COUNT(*) TOTAL "
            cQuery +=   " FROM " + RetSqlName("SBC") + " SBC "
            cQuery +=  " WHERE SBC.D_E_L_E_T_ = ' '"
            cQuery +=    " AND SBC.R_E_C_N_O_ = " + cValToChar(aEstRecusa[nI])
            cQuery := ChangeQuery(cQuery)
            
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
            
            If (cAlias)->(TOTAL) < 1
               lRet := .F.
               cXmlRet := "IntegrationReport" + STR0006 // não cadastrado no protheus."
               (cAlias)->(dbCloseArea())
               Return {lRet, cXmlRet}
            EndIf
            (cAlias)->(dbCloseArea())
            
            SBC->(dbGoTo(aEstRecusa[nI]))
            
            aCabBC := {{'BC_OP'     ,SBC->BC_OP      ,Nil},;
                       {'BC_PRODUTO',SBC->BC_PRODUTO ,Nil},;
                       {'BC_NUMSEQ' ,SBC->BC_NUMSEQ  ,Nil},;
                       {'BC_SEQSD3' ,SBC->BC_SEQSD3  ,Nil},;
                       {'BC_RECURSO',SBC->BC_RECURSO ,Nil},;
                       {'BC_OPERAC' ,SBC->BC_OPERAC  ,Nil}}
            aIteBC := {}

            Aadd(aIteBC,{{'BC_PRODUTO',SBC->BC_PRODUTO,Nil},;
                         {'BC_LOCORIG',SBC->BC_LOCORIG,Nil},; 
                         {'BC_TIPO'   ,SBC->BC_TIPO   ,Nil},;
                         {'BC_MOTIVO' ,SBC->BC_MOTIVO ,Nil},;          
                         {'BC_QUANT'  ,SBC->BC_QUANT  ,Nil},;
                         {'BC_DATA'   ,SBC->BC_DATA   ,Nil}})

            //Valida se é necessario infomar os campos de localização Ascan(aItePe,{|x| x[1] = 'BC_LOCALIZ'}) > 0  .and.    
            if  (!Empty(AllTrim(SBC->BC_LOCALIZ) ))
                Aadd(aTail(aIteBC),{'BC_LOCALIZ',SBC->BC_LOCALIZ,Nil})
            endif
            //Valida se é necessario infomar os campos de lote Ascan(aItePe,{|x| x[1] = 'BC_LOTECTL'}) > 0  .and.
            if  (! Empty(AllTrim(SBC->BC_LOTECTL) ))
                Aadd(aTail(aIteBC),{'BC_LOTECTL',SBC->BC_LOTECTL,Nil})
                Aadd(aTail(aIteBC),{'BC_NUMSERI',SBC->BC_NUMSERI,Nil})   
                Aadd(aTail(aIteBC),{'BC_NUMLOTE',SBC->BC_NUMLOTE,Nil})
            endif

            If lOnlyEstrn
               cNumOp    := SBC->BC_OP
               cOperacao := SBC->BC_OPERAC
               cProduto  := SBC->BC_PRODUTO
               cMaquina  := SBC->BC_RECURSO
               nQtdSOG   := SBC->BC_QUANT
               cMotivo   := SBC->BC_MOTIVO
            EndIf

            MSExecAuto({|x,y,z| Mata685(x,y,z)},aCabBC,aIteBC,6)
            If lMsErroAuto
               aErroAuto := GetAutoGRLog()
               cLogErro := getMsgErro(aErroAuto)
               
               lRet    := .F.
               cXMLRet := cLogErro + " ID: " + cValToChar(aEstRecusa[nI])
               Return {lRet,cXmlRet}
            EndIf
            
            aValues := {}
               
            If aScan(aCabBC,{|aX| AllTrim(aX[1]) == "BC_RECURSO"}) > 0
               aAdd(aValues,aCabBC[aScan(aCabBC,{|aX| AllTrim(aX[1]) == "BC_RECURSO"})][2])
            Else
               aAdd(aValues,Nil)
            EndIf
            If aScan(aCabBC,{|aX| AllTrim(aX[1]) == "BC_OP"}) > 0
               aAdd(aValues,aCabBC[aScan(aCabBC,{|aX| AllTrim(aX[1]) == "BC_OP"})][2])
            Else
               aAdd(aValues,Nil)
            EndIf
            If aScan(aCabBC,{|aX| AllTrim(aX[1]) == "BC_PRODUTO"}) > 0
               aAdd(aValues,aCabBC[aScan(aCabBC,{|aX| AllTrim(aX[1]) == "BC_PRODUTO"})][2])
            Else
               aAdd(aValues,Nil)
            EndIf
            If aScan(aIteBC[1],{|aX| AllTrim(aX[1]) == "BC_QUANT"}) > 0
               aAdd(aValues,aIteBC[1][aScan(aIteBC[1],{|aX| AllTrim(aX[1]) == "BC_QUANT"})][2])
            Else
               aAdd(aValues,Nil)
            EndIf
            If aScan(aCabBC,{|aX| AllTrim(aX[1]) == "BC_OPERAC"}) > 0
               aAdd(aValues,aCabBC[aScan(aCabBC,{|aX| AllTrim(aX[1]) == "BC_OPERAC"})][2])
            Else
               aAdd(aValues,Nil)
            EndIf
            If aScan(aIteBC[1],{|aX| AllTrim(aX[1]) == "BC_MOTIVO"}) > 0
               aAdd(aValues,aIteBC[1][aScan(aIteBC[1],{|aX| AllTrim(aX[1]) == "BC_MOTIVO"})][2])
            Else
               aAdd(aValues,Nil)
            EndIf
            
            If lReproc
               cMsg := "Reprocessado. OK" 
            Else
               cMsg := "OK"
            EndIf
            
            If lUsaASOG
               aAdd(aDadosSOG,{"MATI685",;
                               aValues[1],;
                               aValues[2],;
                               aValues[3],;
                               aValues[4],;
                               StoD(""),;
                               "",;
                               StoD(""),;
                               "",;
                               oXml,;
                               "1",;
                               "1",;
                               aValues[5],;
                               cMsg,;
                               aValues[6],;
                               "",;
                               "",;
                               "",;
                               "",;
                               "",;
                               Iif(lUsaIdInt,cMesIDIntg,"")})
            Else
               PCPCriaSOG("MATI685",aValues[1],aValues[2],aValues[3],aValues[4],,,,,oXml,"1","1",aValues[5],cMsg,aValues[6],,,,,,Iif(lUsaIdInt,cMesIDIntg,""))
            EndIf
         Next nI
         
         /*
         Estorna os apontamentos de produção
         */
         For nI := 1 To Len(aIdEstorno)
            If lIntgSFC
               cSeqCYV := aIdEstorno[nI]
               //Data de estorno / ReversalDate 
               If XmlChildEx(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent,"_REVERSALDATE") != Nil .And. ;
                  !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReversalDate:Text)
                  dDtEstorno := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReversalDate:Text))
               Else
                  lRet := .F.
                  cXmlRet := "ReversalDate" + STR0004 // é obrigatório."
                  Return {lRet, cXMLRet}
               EndIf
               
               CYV->(dbSetOrder(1))
               If !CYV->(dbSeek(xFilial("CYV")+cSeqCYV))
                  lRet := .F.
                  cXmlRet := "IntegrationReport" + STR0006 // não cadastrado no protheus."
                  (cAlias)->(dbCloseArea())
                  Return {lRet, cXmlRet}
               EndIf
               
               If lOnlyEstrn
                  cMaquina  := CYV->CYV_CDMQ
                  cNumOp    := CYV->CYV_NRORPO
                  cProduto  := CYV->CYV_CDACRP
                  dDateIni  := CYV->CYV_DTRPBG
                  cHoraIni  := CYV->CYV_HRRPBG
                  dDateFim  := CYV->CYV_DTRPED
                  cHoraFim  := CYV->CYV_HRRPED
                  cOperacao := POSICIONE("CY9",1,XFILIAL("CY9")+CYV->CYV_NRORPO+CYV->CYV_IDAT,"CY9_CDAT")
               EndIf
               
               //Informações do estorno válidas. Efetua o estorno.
               aSH6 := {}
               aAdd(aSH6,{"CYV_NRSQRP",CYV->CYV_NRSQRP,Nil})
               aAdd(aSH6,{"CYV_DTEO",dDtEstorno,Nil})
               If !SFCA313E(aSH6)
                  aErroAuto := GetAutoGRLog()
                  cLogErro := getMsgErro(aErroAuto)
                  lRet    := .F.
                  cXMLRet := cLogErro + " ID: " + cSeqCYV
                  Return {lRet,cXmlRet}
               EndIf
               
               CYV->(dbSeek(xFilial("CYV")+cSeqCYV))
               
               If lReproc
                  cMsg := "Reprocessado. OK" 
               Else
                  cMsg := "OK"
               EndIf
               If lUsaASOG
                  aAdd(aDadosSOG,{"MATI681",;
                                  CYV->CYV_CDMQ,;
                                  CYV->CYV_NRORPO,;
                                  CYV->CYV_CDACRP,;
                                  CYV->CYV_QTATRP,;
                                  CYV->CYV_DTRPBG,;
                                  CYV->CYV_HRRPBG,;
                                  CYV->CYV_DTRPED,;
                                  CYV->CYV_HRRPED,;
                                  oXml,;
                                  "1",;
                                  "1",;
                                  POSICIONE("CY9",1,XFILIAL("CY9")+CYV->CYV_NRORPO+CYV->CYV_IDAT,"CY9_CDAT"),;
                                  cMsg,;
                                  "",;
                                  "",;
                                  "",;
                                  "",;
                                  "",;
                                  "",;
                                  Iif(lUsaIdInt,cMesIDIntg,"")})
               Else
                  PCPCriaSOG("MATI681",CYV->CYV_CDMQ,CYV->CYV_NRORPO,CYV->CYV_CDACRP,CYV->CYV_QTATRP,CYV->CYV_DTRPBG,CYV->CYV_HRRPBG,CYV->CYV_DTRPED,CYV->CYV_HRRPED,oXml,"1","1",POSICIONE("CY9",1,XFILIAL("CY9")+CYV->CYV_NRORPO+CYV->CYV_IDAT,"CY9_CDAT"),cMsg,,,,,,,Iif(lUsaIdInt,cMesIDIntg,""))
               EndIf
            Else
               nRegSH6 := aIdEstorno[nI]
               cAlias := GetNextAlias()
            
               cQuery := " SELECT COUNT(*) TOTAL "
               cQuery +=   " FROM " + RetSqlName("SH6") + " SH6 "
               cQuery +=  " WHERE SH6.D_E_L_E_T_ = ' '"
               cQuery +=    " AND SH6.R_E_C_N_O_ = " + cValToChar(nRegSH6)
               cQuery := ChangeQuery(cQuery)
            
               dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
            
               If (cAlias)->(TOTAL) < 1
                  lRet := .F.
                  cXmlRet := "IntegrationReport" + STR0006 // não cadastrado no protheus."
                  (cAlias)->(dbCloseArea())
                  Return {lRet, cXmlRet}
               EndIf
               (cAlias)->(dbCloseArea())
               //Informações do estorno válidas. Efetua o estorno.
            
               //Operação de estorno
               nOperation := 5
            
               //Posiciona na SH6
               dbSelectArea("SH6")
               SH6->(dbGoTo(nRegSH6))
            
               //Carrega array com todos os campos da SH6
               aSH6 := {}
               aStruH6 := SH6->(DBStruct())
               For nCount := 1 To Len(aStruH6)
                  If AllTrim(aStruH6[nCount,1]) == "H6_TIPO" .Or. X3USO(GetSx3Cache(aStruH6[nCount,1],'X3_USADO'))
                     aAdd(aSH6,{AllTrim(aStruH6[nCount,1]),;
                                &("SH6->"+AllTrim(aStruH6[nCount,1])),;
                                Nil})
                  EndIf
               Next nCount
               
               //Carrega as variáveis para gravar corretamente a tabela SOG com as informações desse estorno caso ocorra algum erro.
               If lOnlyEstrn
                  cMaquina  := SH6->H6_RECURSO
                  cNumOp    := SH6->H6_OP
                  cProduto  := SH6->H6_PRODUTO
                  dDateIni  := SH6->H6_DATAINI
                  cHoraIni  := SH6->H6_HORAINI
                  dDateFim  := SH6->H6_DATAFIN
                  cHoraFim  := SH6->H6_HORAFIN
                  cOperacao := SH6->H6_OPERAC
               EndIf
               
               // PE MATI681EXC
               If (l681EXC)
                  aSH6Aux := aClone(aSH6)
                  aAdd(aSH6Aux,{"IDESTORNO", nRegSH6, NIL})
                  aRet := ExecBlock('MATI681EXC',.F.,.F.,aSH6Aux)
                  If !aRet[1]
                     Return {.F., Iif(Empty(aRet[2]), STR0010, aRet[2] ) } //"Não processado devido ao Ponto de Entrada MATI681EXC."
                  EndIf
                  aSH6Aux := {}
               EndIf
            
               MSExecAuto({|x,y| mata681(x,y)},aSH6,nOperation)
               If lMsErroAuto
                  aErroAuto := GetAutoGRLog()
                  cLogErro := getMsgErro(aErroAuto)
                  lRet    := .F.
                  cXMLRet := cLogErro + " ID: " + cValToChar(nRegSH6)
                  Return {lRet,cXmlRet}
               EndIf
               
               aValues := {}
               
               If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_RECURSO"}) > 0
                  aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_RECURSO"})][2])
               Else
                  aAdd(aValues,Nil)
               EndIf
            
               If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_OP"}) > 0
                  aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_OP"})][2])
               Else
                  aAdd(aValues,Nil)
               EndIf
            
               If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_PRODUTO"}) > 0
                  aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_PRODUTO"})][2])
               Else
                  aAdd(aValues,Nil)
               EndIf
            
               If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_DATAINI"}) > 0
                  aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_DATAINI"})][2])
               Else
                  aAdd(aValues,Nil)
               EndIf
            
               If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_HORAINI"}) > 0
                  aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_HORAINI"})][2])
               Else
                  aAdd(aValues,Nil)
               EndIf
            
               If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_DATAFIN"}) > 0
                  aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_DATAFIN"})][2])
               Else
                  aAdd(aValues,Nil)
               EndIf
            
               If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_HORAFIN"}) > 0
                  aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_HORAFIN"})][2])
               Else
                  aAdd(aValues,Nil)
               EndIf
            
               If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_QTDPROD"}) > 0 .And. aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_QTDPERD"}) > 0
                  aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_QTDPROD"})][2] + aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_QTDPERD"})][2])
               Else
                  aAdd(aValues,Nil)
               EndIf
            
               If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_OPERAC"}) > 0
                  aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_OPERAC"})][2])
               Else
                  aAdd(aValues,Nil)
               EndIf
               If lReproc
                  cMsg := "Reprocessado. OK" 
               Else
                  cMsg := "OK"
               EndIf
               If lUsaASOG
                  aAdd(aDadosSOG,{"MATI681",;
                                  aValues[1],;
                                  aValues[2],;
                                  aValues[3],;
                                  aValues[8],;
                                  aValues[4],;
                                  aValues[5],;
                                  aValues[6],;
                                  aValues[7],;
                                  oXml,;
                                  "1",;
                                  "1",;
                                  aValues[9],;
                                  cMsg,;
                                  "",;
                                  "",;
                                  "",;
                                  "",;
                                  "",;
                                  "",;
                                  Iif(lUsaIdInt,cMesIDIntg,"")})
               Else
                  PCPCriaSOG("MATI681",aValues[1],aValues[2],aValues[3],aValues[8],aValues[4],aValues[5],aValues[6],aValues[7],oXml,"1","1",aValues[9],cMsg,,,,,,,Iif(lUsaIdInt,cMesIDIntg,""))
               EndIf
            EndIf
         Next nI
      EndIf      

      If !lOnlyEstrn
         //Produção Parcial/Total
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_CloseOperation:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_CloseOperation:Text)
            If AllTrim(Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_CloseOperation:Text)) == "TRUE"
               cPT := "T"
            Else
               cPT := "P"
            EndIf
         EndIf

         //Ordem de produção
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text)
            cNumOp := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text
            //Indica que irá processar um apontamento. Necessário este controle pois é possível enviar uma
            //mensagem apenas estornando o registro, e sendo assim não é necessário os campos tratados abaixo.
            lProcessa := .T.
         Else
            If !lEstorno
               lRet := .F.
               cXmlRet := "ProductionOrderNumber" + STR0004 // é obrigatório."
               Return {lRet, cXMLRet}
            Else
               lProcessa := .F.
            EndIf
         EndIf

         //Produto
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text)
            cProduto := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text
         EndIf

         /*
           Ponto de entrada para tratar a quantidade de apontamento.
           Utilizado quando é necessário aplicar fator de conversão.
         */
         If lMT681QTAP
            nQuant := ExecBlock('MTI681QTAP',.F.,.F.,{cNumOp,cProduto,nQtdApr,"A"})
            If ValType(nQuant) == "N"
               nQtdApr := nQuant
            EndIf
            nQuant := ExecBlock('MTI681QTAP',.F.,.F.,{cNumOp,cProduto,nQtdRef,"R"})
            If ValType(nQuant) == "N"
               nQtdRef := nQuant
            EndIf
            If Type('nQtdSOG') == "N"
               nQtdSOG := nQtdRef + nQtdApr
            EndIf
         EndIf

         //Máquina
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineCode:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineCode:Text)
            cMaquina := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineCode:Text
         EndIf

         //Operação
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ActivityCode:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ActivityCode:Text)
            cOperacao := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ActivityCode:Text

            // PE MATI681OPR
            If (ExistBlock('MATI681OPR'))
               cNewOper := ExecBlock('MATI681OPR',.F.,.F.,{cNumOp,cOperacao,cMaquina,cPT})
               If !Empty(cNewOper)
                  cOperacao := cNewOper
               EndIf
            EndIf
         EndIf

         //Data início reporte
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartReportDateTime:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartReportDateTime:Text)
            dDateIni := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartReportDateTime:Text))
            If Empty(dDateIni)
               lRet := .F.
               cXMLRet := "StartReportDateTime"+STR0009 // informado em formato incorreto. Utilize AAAA-MM-DDTHH:MM:SS."
               Return {lRet, cXMLRet}
            EndIf
            cHoraIni := getTime(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartReportDateTime:Text)
         EndIf

         //Data fim reporte EndReportDateTime
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndReportDateTime:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndReportDateTime:Text)
            dDateFim := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndReportDateTime:Text))
            If Empty(dDateFim)
               lRet := .F.
               cXMLRet := "EndReportDateTime" + STR0009 // informado em formato incorreto. Utilize AAAA-MM-DDTHH:MM:SS."
               Return {lRet, cXMLRet}
            EndIf
            cHoraFim := getTime(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndReportDateTime:Text)
         EndIf

         //Data do reporte
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReportDateTime:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReportDateTime:Text)
            dReportDat := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReportDateTime:Text))
            If Empty(dReportDat)
               lRet := .F.
               cXMLRet := "ReportDateTime"+ STR0009 // informado em formato incorreto. Utilize AAAA-MM-DDTHH:MM:SS."
               Return {lRet, cXMLRet}
            EndIf
            cHoraRpt := getTime(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReportDateTime:Text)
         EndIf

         //Código do local
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text)
            cLocal := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text
         Else
            dbSelectArea("SB1")
            SB1->(dbSetOrder(1))
            If SB1->(dbSeek(xFilial("SB1")+AllTrim(cProduto)))
               cLocal := SB1->B1_LOCPAD
            EndIf
         EndIf

         //Lote
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotCode:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotCode:Text)
            cLoteCtl := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotCode:Text
         EndIf

         //Data validade
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotDueDate:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotDueDate:Text)
            dDtValid := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotDueDate:Text))
            If Empty(dDtValid)
               lRet := .F.
               cXMLRet := "LotDueDate"+STR0009 // informado em formato incorreto. Utilize AAAA-MM-DDTHH:MM:SS."
               Return {lRet, cXMLRet}
            EndIf
         EndIf
         
         cSplit := ""
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Split:Text") != "U" .And. ;
            !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Split:Text)
            cSplit := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_Split:Text
         EndIf

         //Busca os campos do chão de fábrica se estiver integrado.
         If lIntgSFC
            
            //Data/hora início preparação / StartSetupDateTime
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartSetupDateTime:Text") != "U" .And. ;
               !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartSetupDateTime:Text)
               dDtInSetUp := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartSetupDateTime:Text))
               cHrInSetUp := getTime(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartSetupDateTime:Text)
            EndIf
            
            //Data/hora fim preparação / EndSetupDateTime
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndSetupDateTime:Text") != "U" .And. ;
               !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndSetupDateTime:Text)
               dDtFmSetUp := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndSetupDateTime:Text))
               cHrFmSetUp := getTime(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndSetupDateTime:Text)
            EndIf
            
            //Código preparação / SetupCode
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_SetupCode:Text") != "U" .And. ;
               !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_SetupCode:Text)
               cSetupCode:= oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_SetupCode:Text
            EndIf
            
            //Tempo de operação / OpTimeInt
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_OpTimeInt:Text") != "U" .And. ;
               !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_OpTimeInt:Text)
               nTempOper := Val(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_OpTimeInt:Text)
            EndIf
            
            //Modelo de turno / ProductionShiftCode
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftCode:Text") != "U" .And. ;
               !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftCode:Text)
               cTurno := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftCode:Text
            EndIf
            
            //Número de turno / ProductionShiftNumber
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftNumber:Text") != "U" .And. ;
               !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftNumber:Text)
               cNumTurno := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftNumber:Text
            EndIf
            
            //Documento / DocumentCode
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_DocumentCode:Text") != "U" .And. ;
               !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_DocumentCode:Text)
               cDoc := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_DocumentCode:Text
            Else
               cDoc := cNumOp
            EndIf
            
            //Série documento / DocumentSeries
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_DocumentSeries:Text") != "U" .And. ;
               !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_DocumentSeries:Text)
               cDocSerie := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_DocumentSeries:Text
            EndIf
            
            //Localização / LocationCode
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LocationCode:Text") != "U" .And. ;
               !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LocationCode:Text)
               cLocaliz := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_LocationCode:Text
            EndIf
            
            //Recursos
            aXmlRec   := {}
            aRecursos := {}
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfResourceAppointments") != "U" .And. ;
               Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfResourceAppointments:_ResourceAppointment") != "U"
               If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfResourceAppointments:_ResourceAppointment") == "A"
                  aXmlRec := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfResourceAppointments:_ResourceAppointment
               ElseIf Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfResourceAppointments:_ResourceAppointment") == "O"
                  aXmlRec := {oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfResourceAppointments:_ResourceAppointment}
               EndIf
            EndIf
            For nI := 1 To Len(aXmlRec)
               cOperad    := ""
               dDtIniRec  := Stod("")
               cHrIniRec  := ""
               dDtFimRec  := StoD("")
               cHrFimRec  := ""
               nMobDir    := 0 
               nTmpExtra  := 0
               nTmpUtil   := 0
               cModTurno  := ""
               cNumTurno2 := ""
               
               //Código do operador / OperatorCode
               //If Type("aXmlRec["+cValToChar(nI)+"]:_OperatorCode:Text") != "U" .And. ;
               If XmlChildEx(aXmlRec[nI],"_OPERATORCODE") != Nil .And. ;
                  !Empty(aXmlRec[nI]:_OperatorCode:Text)
                  cOperad := aXmlRec[nI]:_OperatorCode:Text
               Else
                  If lProcessa
                     lRet := .F.
                     cXmlRet := "OperatorCode" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               EndIf
               
               //Data/hora início / StartDateTime
               //If Type("aXmlRec["+cValToChar(nI)+"]:_StartDateTime:Text") != "U" .And. ;
               If XmlChildEx(aXmlRec[nI],"_STARTDATETIME") != Nil .And. ;
                  !Empty(aXmlRec[nI]:_StartDateTime:Text)
                  dDtIniRec := StoD(getDate(aXmlRec[nI]:_StartDateTime:Text))
                  cHrIniRec := getTime(aXmlRec[nI]:_StartDateTime:Text)
               Else
                  If lProcessa
                     lRet := .F.
                     cXmlRet := "StartDateTime" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               EndIf
               
               //Data/hora fim / EndDateTime
               //If Type("aXmlRec["+cValToChar(nI)+"]:_EndDateTime:Text") != "U" .And. ;
               If XmlChildEx(aXmlRec[nI],"_ENDDATETIME") != Nil .And. ;
                  !Empty(aXmlRec[nI]:_EndDateTime:Text)
                  dDtFimRec := StoD(getDate(aXmlRec[nI]:_EndDateTime:Text))
                  cHrFimRec := getTime(aXmlRec[nI]:_EndDateTime:Text)
               Else
                  If lProcessa
                     lRet := .F.
                     cXmlRet := "EndDateTime" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               EndIf
               
               //Tempo de mão de obra direta / MOBTime
               //If Type("aXmlRec["+cValToChar(nI)+"]:_MOBTime:Text") != "U" .And. ;
               If XmlChildEx(aXmlRec[nI],"_MOBTIME") != Nil .And. ;
                  !Empty(aXmlRec[nI]:_MOBTime:Text)
                  nMobDir := Val(aXmlRec[nI]:_MOBTime:Text)
               EndIf
               
               //Tempo extra / ExtraTime
               //If Type("aXmlRec["+cValToChar(nI)+"]:_ExtraTime:Text") != "U" .And. ;
               If XmlChildEx(aXmlRec[nI],"_EXTRATIME") != Nil .And. ;
                  !Empty(aXmlRec[nI]:_ExtraTime:Text)
                  nTmpExtra := Val(aXmlRec[nI]:_ExtraTime:Text)
               EndIf
               
               //Tempo útil/ UtilTime
               //If Type("aXmlRec["+cValToChar(nI)+"]:_UtilTime:Text") != "U" .And. ;
               If XmlChildEx(aXmlRec[nI],"_UTILTIME") != Nil .And. ;
                  !Empty(aXmlRec[nI]:_UtilTime:Text)
                  nTmpUtil := Val(aXmlRec[nI]:_UtilTime:Text)
               EndIf
               
               //Modelo do turno / ProductionShiftCode
               //If Type("aXmlRec["+cValToChar(nI)+"]:_ProductionShiftCode:Text") != "U" .And. ;
               If XmlChildEx(aXmlRec[nI],"_PRODUCTIONSHIFTCODE") != Nil .And. ;
                  !Empty(aXmlRec[nI]:_ProductionShiftCode:Text)
                  cModTurno := aXmlRec[nI]:_ProductionShiftCode:Text
               EndIf
               
               //Número do turno / ProductionShiftNumber
               //If Type("aXmlRec["+cValToChar(nI)+"]:_ProductionShiftNumber:Text") != "U" .And. ;
               If XmlChildEx(aXmlRec[nI],"_PRODUCTIONSHIFTNUMBER") != Nil .And. ;
                  !Empty(aXmlRec[nI]:_ProductionShiftNumber:Text)
                  cNumTurno2 := aXmlRec[nI]:_ProductionShiftNumber:Text
               EndIf
               
               aAdd(aRecursos,{cOperad,dDtIniRec,cHrIniRec,dDtFimRec,cHrFimRec,nMobDir,nTmpExtra,nTmpUtil,cModTurno,cNumTurno2})
            Next nI
            
            //Ferramentas
            aXmlFerram := {}
            aFerrament := {}
            If XmlChildEx(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent,"_LISTOFREPORTTOOLACTIVITIES") != Nil .And. ;
               XmlChildEx(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfReportToolActivities,"_REPORTTOOLACTIVITY") != Nil
               If ValType(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfReportToolActivities:_ReportToolActivity) == "A"
                  aXmlFerram := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfReportToolActivities:_ReportToolActivity
               ElseIf ValType(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfReportToolActivities:_ReportToolActivity) == "O"
                  aXmlFerram := {oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfReportToolActivities:_ReportToolActivity}
               EndIf
            EndIf
            For nI := 1 To Len(aXmlFerram)
               //Código da ferramenta / ToolCode
               If XmlChildEx(aXmlFerram[nI],"_TOOLCODE") != Nil .And. ;
                  !Empty(aXmlFerram[nI]:_ToolCode:Text)
                  aAdd(aFerrament,aXmlFerram[nI]:_ToolCode:Text)
               Else
                  If lProcessa
                     lRet := .F.
                     cXmlRet := "ToolCode" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               EndIf
            Next nI
         EndIf

         //Refugos
         aXmlWaste := {}
         aRefugos  := {}
         If nQtdRef > 0
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfWasteAppointments") != "U" .And. ;
               Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfWasteAppointments:_WasteAppointment") != "U"
               If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfWasteAppointments:_WasteAppointment") == "A"
                  aXmlWaste := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfWasteAppointments:_WasteAppointment
               ElseIf Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfWasteAppointments:_WasteAppointment") == "O"
                  aXmlWaste := {oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfWasteAppointments:_WasteAppointment}
               EndIf
            EndIf

            //Se o cliente possuir os novos campos da CYO, então ele possui a melhoria que tirou
            //o registro do motivo de refugo da SX5 e transferiu para a CYO (SFCA003)   
            If campoCYO()
               nTamMot := TamSX3("CYO_CDRF")[1]
               If TamSX3("CY0_CDRF")[1] < nTamMot
                  nTamMot := TamSX3("CY0_CDRF")[1] 
               EndIf
                  
               If lIntgSFC               
                  If TamSX3("BC_MOTIVO")[1] < nTamMot
                     nTamMot := TamSX3("BC_MOTIVO")[1] 
                  EndIf  
               EndIf            
            Else
               If lIntgSFC
                  nTamMot := TamSX3("CYO_CDRF")[1]
                  If TamSX3("CY0_CDRF")[1] < nTamMot
                     nTamMot := TamSX3("CY0_CDRF")[1] 
                  EndIf
                  If TamSX3("BC_MOTIVO")[1] < nTamMot
                     nTamMot := TamSX3("BC_MOTIVO")[1] 
                  EndIf  
               Else
                  nTamMot := TamSX3("X5_CHAVE")[1]
                  If TamSX3("BC_MOTIVO")[1] < nTamMot
                     nTamMot := TamSX3("BC_MOTIVO")[1] 
                  EndIf 
               EndIf
            Endif

            For nI := 1 To Len(aXmlWaste)
               cCodRefug  := ""
               cDscRefug  := ""
               nRefugQtd  := 0
               nRefQtdTo  := 0
               cPrdRefOrg := ""
               cLocRefOrg := ""
               cPrdRefDst := ""
               cLocRefDst := ""
               cEndOrig   := ""
               cSeriOrig  := ""
               cEndDest   := ""
               cSeriDest  := ""
               cLoteWaste := ""
               cSubLoteW  := ""
               dVldLoteW  := Nil
               cCentroCst := ""
               
               If XmlChildEx(aXmlWaste[nI],"_SCRAPQUANTITY") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_ScrapQuantity:Text)
                  nRefugQtd := Val(aXmlWaste[nI]:_ScrapQuantity:Text)
               EndIf
                
               If nRefugQtd == 0
                  Loop
               EndIf

               If XmlChildEx(aXmlWaste[nI],"_SCRAPQUANTITYTO") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_ScrapQuantityTo:Text)
                  nRefQtdTo := Val(aXmlWaste[nI]:_ScrapQuantityTo:Text)
               EndIf

               If nRefQtdTo == 0
                  nRefQtdTo := nRefugQtd
               EndIf              

               If XmlChildEx(aXmlWaste[nI],"_WASTECODE") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_WasteCode:Text)
                  cCodRefug := aXmlWaste[nI]:_WasteCode:Text
               Else
                  If lProcessa
                     lRet := .F.
                     cXmlRet := "WasteCode" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               EndIf
               If Len(cCodRefug) > nTamMot .And. lProcessa
                  cXmlRet := "WasteCode com tamanho inválido."
                  lRet := .F.
                  Return {lRet, cXmlRet}
               EndIf
               cDscRefug := ""
               If XmlChildEx(aXmlWaste[nI],"_WASTEDESCRIPTION") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_WasteDescription:Text)
                  cDscRefug := aXmlWaste[nI]:_WasteDescription:Text
               EndIf
               If lProcessa
                  //Verifica se o motivo de refugo está cadastrado.
                  //Se o cliente possui os campos novos da CYO, então ele está na regra
                  //nova que transferiu o o cadastro dos motivos de refugo da SX5 para
                  //SFCA003 independente do cliente ter ou não integração com o chão de fábrica

                  If lIntgSFC .Or. campoCYO()
                     CYO->(dbSetOrder(1))
                     If !CYO->(dbSeek(xFilial("CYO")+AllTrim(cCodRefug)))
                        
                        If Empty(cDscRefug)
                           lRet := .F.
                           cXmlRet := "WasteDescription" + STR0004 // é obrigatório."
                           Return {lRet, cXMLRet}
                        EndIf
                        
                        //Cadastra o motivo de refugo
                        oModel := FWLoadModel("SFCA003")
                        oModel:SetOperation(MODEL_OPERATION_INSERT)
                        oModel:Activate()
                        
                        aDados := {}
                        
                        //Alimenta array com os dados
                        aAdd(aDados,{"CYO_CDRF",cCodRefug})
                        aAdd(aDados,{"CYO_DSRF",cDscRefug})
                        If campoCYO()
                           aAdd(aDados,{"CYO_LGRFMP",.T.})
                        Endif
   
                        // Obtém a estrutura de dados
                        aAux := oModel:GetModel('CYOMASTER'):GetStruct():GetFields()
   
                        For nCount := 1 To Len(aDados)
                           // Verifica se os campos passados existem na estrutura do modelo
                           If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aDados[nCount][1])}) > 0
                              // É feita a atribuição do dado ao campo do Model
                              If !oModel:SetValue('CYOMASTER', aDados[nCount][1], aDados[nCount][2])
                                 lRet := .F.
                                 cXmlRet := "Não foi possível atribuir o valor " + AllToChar(aDados[nCount][2]) + " ao campo " + aDados[nCount][1] + "." // "Não foi possível atribuir o valor " XXX " ao campo " XXX "."
                                 Return {lRet, cXmlRet}
                              EndIf
                           EndIf
                        Next nI
   			             
                        If oModel:VldData()  
                           // Caso nao ocorra erros, efetiva os dados no banco
                           oModel:CommitData()    
                        Else
                           // Cria TAG com o Erro ocorrido para retornar ao EAI
                           cXMLRet := oModel:GetErrorMessage()[6]
                           lRet    := .F.
                           oModel:DeActivate()
                           Return {lRet, cXmlRet}
                        EndIf
                        // Desativa o Model
                        oModel:DeActivate()
                     EndIf
                  EndIf
                  
               EndIf
               
               If XmlChildEx(aXmlWaste[nI],"_SCRAPPRODUCT") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_ScrapProduct:Text)
                  cPrdRefOrg := aXmlWaste[nI]:_ScrapProduct:Text
               EndIf
               If XmlChildEx(aXmlWaste[nI],"_WAREHOUSECODE") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_WarehouseCode:Text)
                  cLocRefOrg := aXmlWaste[nI]:_WarehouseCode:Text
               EndIf
               
               If XmlChildEx(aXmlWaste[nI],"_SCRAPPRODUCTTO") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_ScrapProductTo:Text)
                  cPrdRefDst := aXmlWaste[nI]:_ScrapProductTo:Text
               EndIf
               If XmlChildEx(aXmlWaste[nI],"_WAREHOUSECODETO") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_WarehouseCodeTo:Text)
                  cLocRefDst := aXmlWaste[nI]:_WarehouseCodeTo:Text
               EndIf
               
               If AllTrim(cPrdRefOrg) == AllTrim(cPrdRefDst) .And. !Empty(cPrdRefDst)
                  If Empty(cLocRefOrg)
                     dbSelectArea("SC2")
                     SC2->(dbSetOrder(1))
                     If SC2->(dbSeek(xFilial("SC2")+AllTrim(cNumOP)))
                        cLocRefOrg := SC2->C2_LOCAL
                     EndIf
                  EndIf
                  If Empty(cLocRefDst)
                     dbSelectArea("SOE")
                     If SOE->(dbSeek(xFilial("SOE")+"SC2"))
                        cLocRefDst := AllTrim(SOE->OE_VAR3)
                     EndIf
                  EndIf
               EndIf
               
               If Empty(cPrdRefDst) .And. AllTrim(cPrdRefOrg) == AllTrim(cProduto) .And. Empty(cLocRefOrg)
                  dbSelectArea("SC2")
                  SC2->(dbSetOrder(1))
                  If SC2->(dbSeek(xFilial("SC2")+AllTrim(cNumOP)))
                     cLocRefOrg := SC2->C2_LOCAL
                  EndIf 
               EndIf
               
               If XmlChildEx(aXmlWaste[nI],"_ADDRESSCODE") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_AddressCode:Text)
                  cEndOrig := aXmlWaste[nI]:_AddressCode:Text
               EndIf
               
               If XmlChildEx(aXmlWaste[nI],"_NUMBERSERIES") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_NumberSeries:Text)
                  cSeriOrig := aXmlWaste[nI]:_NumberSeries:Text
               EndIf
               
               If XmlChildEx(aXmlWaste[nI],"_ADDRESSCODETO") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_AddressCodeTo:Text)
                  cEndDest := aXmlWaste[nI]:_AddressCodeTo:Text
               EndIf
               
               If XmlChildEx(aXmlWaste[nI],"_NUMBERSERIESTO") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_NumberSeriesTo:Text)
                  cSeriDest := aXmlWaste[nI]:_NumberSeriesTo:Text
               EndIf
               
               If XmlChildEx(aXmlWaste[nI],"_LOTCODE") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_LotCode:Text)
                  cLoteWaste := aXmlWaste[nI]:_LotCode:Text
               elseif !Empty(cLoteCtl)
                  cLoteWaste := cLoteCtl                  
               EndIf
               
               If XmlChildEx(aXmlWaste[nI],"_SUBLOTCODE") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_SubLotCode:Text)
                  cSubLoteW := aXmlWaste[nI]:_SubLotCode:Text
               EndIf
               
               If XmlChildEx(aXmlWaste[nI],"_LOTDUEDATE") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_LotDueDate:Text)
                  dVldLoteW := StoD(getDate(aXmlWaste[nI]:_LotDueDate:Text))
               EndIf
               
               If XmlChildEx(aXmlWaste[nI],"_COSTCENTERCODE") != Nil .And. ;
                  !Empty(aXmlWaste[nI]:_CostCenterCode:Text)
                  cCentroCst := aXmlWaste[nI]:_CostCenterCode:Text
               EndIf
               
               nQtRefOrig := nRefugQtd
               nQtRefDest := nRefQtdTo
               
               If lMT681QTAP
                  If !Empty(cPrdRefOrg)
                     nQtRefOrig := ExecBlock('MTI681QTAP',.F.,.F.,{cNumOp,cPrdRefOrg,nRefugQtd,"R"})
                     If ValType(nQtRefOrig) != "N"
                        nQtRefOrig := nRefugQtd
                     EndIf
                  EndIf
                  If !Empty(cPrdRefDst)
                     nQtRefDest := ExecBlock('MTI681QTAP',.F.,.F.,{cNumOp,cPrdRefDst,nRefQtdTo,"R"})
                     If ValType(nQtRefDest) != "N"
                        nQtRefDest := nRefQtdTo
                     EndIf
                  EndIf
               EndIf
                              
               aAdd(aRefugos, {cCodRefug, ;
                               cDscRefug, ;
                               nRefugQtd, ;
                               cPrdRefOrg, ;
                               cLocRefOrg, ;
                               cPrdRefDst, ;
                               cLocRefDst, ;
                               cEndOrig, ;
                               cSeriOrig, ;
                               cEndDest, ;
                               cSeriDest, ;
                               cLoteWaste, ;
                               cSubLoteW, ;
                               dVldLoteW, ;
                               cCentroCst,;
                               nQtRefOrig, ;
                               nQtRefDest})
            Next nI
         EndIf

         //Componentes
         If !lBackFlush
            aXmlSupply := {}
            aSupply    := {}
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfSupplyOrders") != "U" .And. ;
               Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfSupplyOrders:_SupplyOrder") != "U"
               If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfSupplyOrders:_SupplyOrder") == "A"
                  aXmlSupply := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfSupplyOrders:_SupplyOrder
               ElseIf Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfSupplyOrders:_SupplyOrder") == "O"
                  aXmlSupply := {oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfSupplyOrders:_SupplyOrder}
               EndIf
            EndIf
            cReqAut := GetMV("MV_REQAUT")
            If Empty(cReqAut)
               cReqAut := "A"
            EndIf
            For nI := 1 To Len(aXmlSupply)
               cOpComp    := ""
               cComp      := ""
               nQuant     := 0
               cLocComp   := ""
               cLoclizCmp := ""
               cLoteComp  := ""
               cOperComp  := ""
               cRotComp   := ""
               
               //Número da ordem de produção / ProductionOrderNumber
               If XmlChildEx(aXmlSupply[nI],"_PRODUCTIONORDERNUMBER") != Nil .And. ;
                  !Empty(aXmlSupply[nI]:_ProductionOrderNumber:Text)
                  cOpComp := aXmlSupply[nI]:_ProductionOrderNumber:Text
               Else
                  If lProcessa
                     lRet := .F.
                     cXmlRet := "ProductionOrderNumber" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               EndIf
               
               //Código do componente / MaterialCode
               If XmlChildEx(aXmlSupply[nI],"_MATERIALCODE") != Nil .And. ;
                  !Empty(aXmlSupply[nI]:_MaterialCode:Text)
                  cComp := aXmlSupply[nI]:_MaterialCode:Text
               Else
                  If lProcessa
                     lRet := .F.
                     cXmlRet := "MaterialCode" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               EndIf
               
               //Quantidade / UsedQuantity
               If XmlChildEx(aXmlSupply[nI],"_USEDQUANTITY") != Nil .And. ;
                  !Empty(aXmlSupply[nI]:_UsedQuantity:Text)
                  nQuant := Val(aXmlSupply[nI]:_UsedQuantity:Text)
               Else
                  If lProcessa
                     lRet := .F.
                     cXmlRet := "UsedQuantity" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               EndIf
               
               //Código do local / WarehouseCode
               If XmlChildEx(aXmlSupply[nI],"_WAREHOUSECODE") != Nil .And. ;
                  !Empty(aXmlSupply[nI]:_WarehouseCode:Text)
                  cLocComp := aXmlSupply[nI]:_WarehouseCode:Text
               Else
                  If lProcessa
                     lRet := .F.
                     cXmlRet := "WarehouseCode" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               EndIf
               
               //Endereço/Localização / LocationCode
               If XmlChildEx(aXmlSupply[nI],"_LOCATIONCODE") != Nil .And. ;
                  !Empty(aXmlSupply[nI]:_LocationCode:Text)
                  cLoclizCmp := aXmlSupply[nI]:_LocationCode:Text
               EndIf
               
               //Lote / LotCode
               If XmlChildEx(aXmlSupply[nI],"_LOTCODE") != Nil .And. ;
                  !Empty(aXmlSupply[nI]:_LotCode:Text)
                  cLoteComp := aXmlSupply[nI]:_LotCode:Text
               EndIf
               
               //Código da operação / ActivityCode
               If XmlChildEx(aXmlSupply[nI],"_ACTIVITYCODE") != Nil .And. ;
                  !Empty(aXmlSupply[nI]:_ActivityCode:Text)
                  cOperComp := aXmlSupply[nI]:_ActivityCode:Text
               EndIf
               
               //Código do roteiro / ScriptCode
               If XmlChildEx(aXmlSupply[nI],"_SCRIPTCODE") != Nil .And. ;
                  !Empty(aXmlSupply[nI]:_ScriptCode:Text)
                  cRotComp := aXmlSupply[nI]:_ScriptCode:Text
               EndIf
               If cReqAut == "D"
                  SB1->(dbSeek(xFilial("SB1")+AllTrim(cComp)))
                  If SB1->B1_APROPRI == "D"
                     Loop
                  EndIf
               EndIf
               aAdd(aSupply, {cOpComp,Padr(cComp,TamSX3("B1_COD")[1]),nQuant,cLocComp,cLoclizCmp,cLoteComp,cOperComp,cRotComp})
            Next nI
         EndIf
         
         If lProcessa
            //Valida os campos obrigatórios.
            //Verifica se é uma mensagem apenas para finalizar a operação.
            If cPT == "T" .And. !Empty(cNumOp) .And. !Empty(cOperacao) .And. !Empty(dReportDat) .And. ;
               nQtdApr+nQtdRef == 0 .And. Empty(dDateIni) .And. Empty(cHoraIni) .And. Empty(dDateFim) .And. ;
               Empty(cHoraFim) .And. Empty(cMaquina) .And. Empty(cProduto) .And. (!lIntgSFC .Or. (lIntgSFC .And. Empty(cSplit)))
               lFimOperac := .T.
            Else
               //Verifica se é uma mensagem para encerrar a OP
               If cPT == "T" .And. !Empty(cNumOp) .And. Empty(cOperacao) .And. Empty(dReportDat) .And. ;
                  nQtdApr+nQtdRef==0 .And. Empty(dDateIni) .And. Empty(cHoraIni) .And. Empty(dDateFim) .And. ;
                  Empty(cHoraFim) .And. Empty(cMaquina) .And. Empty(cProduto) .And. (!lIntgSFC .Or. (lIntgSFC .And. Empty(cSplit)))
                  lEncerraOP := .T.
               EndIf
            EndIf

            If !lFimOperac .And. !lEncerraOP
               If Empty(cProduto)
                  lRet := .F.
                  cXmlRet := "ItemCode" + STR0004 // é obrigatório."
                  Return {lRet, cXMLRet}
               EndIf
               If Empty(cMaquina)
                  lRet := .F.
                  cXmlRet := "MachineCode" + STR0004 // é obrigatório."
                  Return {lRet, cXMLRet}
               EndIf
               
               If Empty(dReportDat)
                  lRet := .F.
                  cXmlRet := "ReportDateTime" + STR0004 // é obrigatório."
                  Return {lRet, cXMLRet}
               EndIf
               
               If !lEncerraOP
                  If Empty(cOperacao)
                     lRet := .F.
                     cXmlRet := "ActivityCode" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               EndIf
               If lIntgSFC
                  If Empty(cSplit)
                     lRet := .F.
                     cXmlRet := "Split" + STR0004 // é obrigatório."
                     Return {lRet, cXMLRet}
                  EndIf
               EndIf
            EndIf
            //Ordem de produção
            dbSelectArea("SC2")
            SC2->(dbSetOrder(1))
            If !SC2->(dbSeek(xFilial("SC2")+AllTrim(cNumOP)))
               lRet := .F.
               cXmlRet := "ProductionOrderNumber" + STR0007 // não cadastrada no protheus."
               Return {lRet, cXmlRet}
            EndIf

            //Produto
            If !lFimOperac .And. !lEncerraOP
               dbSelectArea("SB1")
               SB1->(dbSetOrder(1))
               If !lBackFlush
                  For nI := 1 To Len(aSupply)
                     If !SB1->(dbSeek(xFilial("SB1")+AllTrim(aSupply[nI,2])))
                        lRet := .F.
                        cXmlRet := "MaterialCode " + AllTrim(aSupply[nI,2]) + STR0006 // não cadastrado no protheus."
                        Return {lRet, cXmlRet}
                     EndIf
                  Next nI
               EndIf
               
               If !SB1->(dbSeek(xFilial("SB1")+AllTrim(cProduto)))
                  lRet := .F.
                  cXmlRet := "ItemCode" + STR0006 // não cadastrado no protheus."
                  Return {lRet, cXmlRet}
               EndIf
            EndIf

            //Verifica se o produto é diferente ao produto da OP
            If !lFimOperac .And. !lEncerraOP .And. AllTrim(SB1->B1_COD) != AllTrim(SC2->C2_PRODUTO)
               lRet := .F.
               cXmlRet := STR0008 //"ItemCode diferente do produto da ordem de produção."
               Return {lRet, cXmlRet}
            EndIf

            //Recurso
            If !lFimOperac .And. !lEncerraOP
               dbSelectArea("SH1")
               SH1->(dbSetOrder(1))
               If !SH1->(dbSeek(xFilial("SH1")+AllTrim(cMaquina)))
                  lRet := .F.
                  cXmlRet := "MachineCode" + STR0006 // não cadastrado no protheus."
                  Return {lRet, cXmlRet}
               EndIf
            EndIf

            //Operação
            If !lEncerraOP
               dbSelectArea("SH8")
               SH8->(dbSetOrder(1))
               If !SH8->(dbSeek(xFilial("SH8")+CorValFld(cNumOP,"H8_OP")+cOperacao))
                  //Não encontrou na SH8, busca na SHY
                  dbSelectArea("SHY")
                  SHY->(dbSetOrder(1))
                  If !SHY->(dbSeek(xFilial("SHY")+CorValFld(cNumOP,"HY_OP")+CorValFld(SC2->C2_ROTEIRO,"HY_ROTEIRO")+cOperacao))
                     //Não encontrou na SHY, busca na SG2
                     dbSelectArea("SG2")
                     SG2->(dbSetOrder(1))
                     If !SG2->(dbSeek(xFilial("SG2")+SC2->C2_PRODUTO+SC2->C2_ROTEIRO+cOperacao))
                        lRet := .F.
                        cXmlRet := "ActivityCode" + STR0006 // não cadastrado no protheus."
                        Return {lRet, cXmlRet}
                     EndIf
                  EndIf
               EndIf
            EndIf
            
            //Operação de inclusão de apontamento
            If lEncerraOP
               nOperation := 7
            Else
               nOperation := 3
            EndIf
            aSH6 := {}

            If !lEncerraOP
               // Se existir o PE e não tiver alguma data preenchida 
               If ExistBlock("MTI681DT") .And. (Empty(dDateIni) .or. Empty(dDateFim))
                  aRetDatas := Execblock("MTI681DT",.F.,.F.,{dDateIni,dDateFim})
                  If ValType(aRetDatas) == "A" 
                     // Valida se foi preenchido Data Inicio
                     If !empty(aRetDatas[1]) .and. ValType(aRetDatas[1]) == "D"
                        dDateIni := aRetDatas[1]
                     EndIf 
                     // Valida se foi preenchido Hora Inicio
                     If !empty(aRetDatas[2]) .and. ValType(aRetDatas[2]) == "C"
                        cHoraIni := aRetDatas[2]
                     EndIf 
                     // Valida se foi preenchido Data Final
                     If !empty(aRetDatas[3]) .and. ValType(aRetDatas[3]) == "D"
                        dDateFim := aRetDatas[3]
                     EndIf 
                     // Valida se foi preenchido Hora Final
                     If !empty(aRetDatas[4]) .and. ValType(aRetDatas[4]) == "C"
                        cHoraFim := aRetDatas[4]
                     EndIf   
                  EndIf                                                             
               EndIf

               If Empty(dDateIni)
                  dDateIni := stod("")
                  cHoraIni := ""
               EndIf
               If Empty(dDateFim)
                  dDateFim := stod("")
                  cHoraFim := ""
               EndIf

               If ExistBlock("MATI681DTA")
                  lRetPE := Execblock("MATI681DTA")
                  If Valtype(lRetPE) != "L"
					      lRetPE:= .F.
			         EndIf 
               EndIf

               If (!lRetPE .and. dReportDat < dDataBase) .or. Empty(dReportDat)
                  dReportDat := dDataBase
               EndIf 
               If Empty(cHoraRpt)
                  cHoraRpt := TIME()
               EndIf
               
               cObserva := Iif(AllTrim(UPPER(cProduct))=="PPI","TOTVSMES",cProduct)
            Else
               //Encerramento de OP. Posiciona no registro para finalizar a ordem
               If lIntgSFC
                  dbSelectArea("CYQ")
                  CYQ->(dbSetOrder(1))
                  If !CYQ->(dbSeek(xFilial("CYQ")+cNumOp))
                     lRet := .F.
                     cXmlRet := STR0013 //"Ordem de produção não encontrada no SIGASFC." 
                     Return {lRet, cXmlRet}
                  EndIf
               Else
                  nRecH6 := 0
                  dbSelectArea("SH6")
                  SH6->(dbSetOrder(1))
                  SH6->(dbSeek(xFilial("SH6")+cNumOp))
                  While SH6->(!Eof()) .And. AllTrim(SH6->H6_OP) == AllTrim(cNumOp)
                     If SH6->H6_QTDPROD > 0 .Or. SH6->H6_QTDPERD > 0
                        nRecH6 := SH6->(Recno())
                     EndIf
                     SH6->(dbSkip())
                  End
                  If nRecH6 == 0
                     lRet := .F.
                     cXmlRet := STR0012 //"Não foram encontrados apontamentos de produção para realizar o encerramento da ordem." // 
                     Return {lRet, cXmlRet}
                  EndIf
                  //Posiciona na ultima operação apontada
                  SH6->(dbGoTo(nRecH6))
                  aSH6 := {{"H6_OP"      ,SH6->H6_OP      , NIL },;
                           {"H6_RECURSO" ,SH6->H6_RECURSO , NIL },;
                           {"H6_OPERAC"  ,SH6->H6_OPERAC  , NIL },;
                           {"H6_PRODUTO" ,SH6->H6_PRODUTO , NIL },;
                           {"H6_QTDPROD" ,SH6->H6_QTDPROD , NIL },;
                           {"H6_QTDPERD" ,SH6->H6_QTDPERD , NIL },;
                           {"H6_DATAINI" ,SH6->H6_DATAINI , NIL },;
                           {"H6_DATAFIN" ,SH6->H6_DATAFIN , NIL },;
                           {"H6_DTAPONT" ,SH6->H6_DTAPONT , NIL },;
                           {"H6_LOCAL"   ,SH6->H6_LOCAL   , NIL },;
                           {"H6_LOTECTL" ,SH6->H6_LOTECTL , NIL },;
                           {"H6_DTVALID" ,SH6->H6_DTVALID , NIL },;
                           {"H6_PT"      ,SH6->H6_PT      , NIL },;
                           {"H6_OBSERVA" ,SH6->H6_OBSERVA , NIL },;
                           {"H6_TIPO"    ,SH6->H6_TIPO    , NIL },;
                           {"H6_DESDOBR" ,SH6->H6_DESDOBR , NIL },;
                           {"AUTRECNO"   ,SH6->(Recno())  , Nil }}
               EndIf
            EndIf
            
            If lIntgSFC            
               If lEncerraOP
                  //Encerramento da ordem de produção
                  If SFCA100FIM(.T.)
                     cXMLRet := "OK"
                     lRet    := .T.
                  Else
                     cLogErro := ""
                     aErroAuto := GetAutoGRLog()
                     cLogErro := getMsgErro(aErroAuto)
                     cXmlRet := cLogErro
                     lRet    := .F.
                  EndIf
               Else
                  //Apontamento de produção
                  oModel := FWLoadModel( "SFCA316" )
                  oModel:SetOperation( 3 ) //incluir apontamento
                  If !oModel:Activate()
                     cXmlRet := oModel:GetErrorMessage()[6]
                     lRet := .F.
                     Return {lRet, cXmlRet}
                  EndIf
                  oModelCY0 := oModel:GetModel( "CY0DETAIL" )
                  oModelCYW := oModel:GetModel( "CYWDETAIL" )
                  
                  lAssign := oModel:SetValue("CYVMASTER","CYV_NRORPO",cNumOp)                ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_CDAT"  ,cOperacao)             ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_IDATQO",cSplit)                ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_CDMQ"  ,cMaquina)              ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  If SFCA314EST()
                     lAssign := oModel:SetValue("CYVMASTER","CYV_DTBGSU",dDtInSetUp)         ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                     lAssign := oModel:SetValue("CYVMASTER","CYV_HRBGSU",cHrInSetUp)         ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                     lAssign := oModel:SetValue("CYVMASTER","CYV_DTEDSU",dDtFmSetUp)         ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                     lAssign := oModel:SetValue("CYVMASTER","CYV_HREDSU",cHrFmSetUp)         ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                     lAssign := oModel:SetValue("CYVMASTER","CYV_CDSU"  ,cSetupCode)         ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_DTRPBG",dDateIni)              ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_HRRPBG",cHoraIni)              ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_QTTERP",nTempOper)             ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_CDTN"  ,cTurno)                ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_NRTN"  ,cNumTurno)             ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_NRDO"  ,cDoc)                  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_NRSR"  ,cDocSerie)             ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_DTRP"  ,dReportDat)            ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_HRRP"  ,cHoraRpt)              ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_CDDP"  ,cLocal)                ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_CDLOSR",cLoteCtl)              ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_DTVDLO",dDtValid)              ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_LGEDRP",Iif(cPT=="T",.T.,.F.)) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_CDLC"  ,cLocaliz)              ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  
                  If Len(aRefugos) > 0
                     If oModelCY0:Length() == 1
                        oModelCY0:GoLine( 1 )
                        oModelCY0:DeleteLine()
                     Endif
                     nTotRefug := 0
                     //Adiciona quantidades refugadas e retrabalhadas, e seus respectivos motivos
                     For nI := 1 To Len(aRefugos)
                        oModelCY0:AddLine()
                        lAssign := oModelCY0:SetValue("CY0_CDRF",aRefugos[nI][1]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        If aRefugos[nI][3] > 0
                           lAssign := oModelCY0:SetValue("CY0_QTRF",aRefugos[nI][3]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                           nTotRefug += aRefugos[nI][3]
                        Endif
                     Next
                  EndIf
                  
                  lAssign := oModel:SetValue("CYVMASTER","CYV_QTATRP",nQtdApr+nTotRefug);If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_QTATAP",nQtdApr)                  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_QTATRF",nQtdRef)                  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_DTRPED",dDateFim)                 ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  lAssign := oModel:SetValue("CYVMASTER","CYV_HRRPED",cHoraFim)                 ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  
                  If Len(aRecursos) > 0
                     oModelCYW:SetNoInsertLine(.F.)
                     oModelCYW:SetNoUpdateLine(.F.)
                     For nI := 1 To Len(aRecursos)
                        If nI > 1
                           oModelCYW:AddLine()
                        Else
                           oModelCYW:GoLine(nI)
                        Endif
                        lAssign := oModelCYW:SetValue("CYW_CDOE"  ,aRecursos[nI][1]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCYW:SetValue("CYW_DTBGRP",aRecursos[nI][2]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCYW:SetValue("CYW_HRBGRP",aRecursos[nI][3]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCYW:SetValue("CYW_DTEDRP",aRecursos[nI][4]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCYW:SetValue("CYW_HREDRP",aRecursos[nI][5]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCYW:SetValue("CYW_QTTEOE",aRecursos[nI][6]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCYW:SetValue("CYW_QTTEEX",aRecursos[nI][7]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCYW:SetValue("CYW_QTTEUT",aRecursos[nI][8]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCYW:SetValue("CYW_CDTN"  ,aRecursos[nI][9]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCYW:SetValue("CYW_NRTN"  ,aRecursos[nI][10]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                     Next nI
                  EndIf
                  
                  If !lBackFlush
                     oModelCZP := oModel:GetModel('CZPDETAIL')
                     
                     oModelCZP:SetNoInsertLine(.F.)
                     oModelCZP:SetNoUpdateLine(.F.)
                     
                     //Apaga todos os componentes que foram carregados automaticamente.
                     For nI := 1 To oModelCZP:Length()
                        oModelCZP:GoLine( nI )
                        If !oModelCZP:IsDeleted()
                           oModelCZP:DeleteLine()
                        Endif
                     Next
                  
                     For nI := 1 To Len(aSupply)
                        oModelCZP:AddLine()
                        lAssign := oModelCZP:SetValue('CZP_NRORPO',aSupply[nI,1]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCZP:SetValue('CZP_CDMT'  ,aSupply[nI,2]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCZP:SetValue('CZP_QTRPPO',aSupply[nI,3]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCZP:SetValue('CZP_CDDP'  ,aSupply[nI,4]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCZP:SetValue('CZP_CDLC'  ,aSupply[nI,5]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCZP:SetValue('CZP_CDLO'  ,aSupply[nI,6]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCZP:SetValue('CZP_CDAT'  ,aSupply[nI,7]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCZP:SetValue('CZP_CDRT'  ,aSupply[nI,8]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        lAssign := oModelCZP:SetValue('CZP_CDACPI',cProduto     ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                        cQuery := " SELECT CYP.CYP_IDMTOR, "
                        cQuery +=        " CYP.CYP_QTMT, "
                        cQuery +=        " CYP.CYP_DTMT "
                        cQuery +=   " FROM " + RetSqlName("CYP") + " CYP "
                        cQuery +=  " WHERE CYP.D_E_L_E_T_ = ' ' "
                        cQuery +=    " AND CYP.CYP_FILIAL = '" + xFilial("CYP") + "' "
                        cQuery +=    " AND CYP.CYP_NRORPO = '" + aSupply[nI,1]  + "' "
                        cQuery +=    " AND CYP.CYP_CDMT   = '" + aSupply[nI,2]  + "' "
                        cQuery +=    " AND CYP.CYP_CDACPI = '" + cProduto       + "' "
                        cQuery +=    " AND CYP.CYP_CDRT   = '" + aSupply[nI,8]  + "' "
                        cQuery +=    " AND CYP.CYP_QTRP   < CYP.CYP_QTMT "
                        cQuery := ChangeQuery(cQuery)
                        dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasCYP, .F., .T.)
                        If (cAliasCYP)->(!Eof())
                           lAssign := oModelCZP:SetValue('CZP_IDMTOR',(cAliasCYP)->(CYP_IDMTOR)) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                           lAssign := oModelCZP:SetValue('CZP_QTMT'  ,(cAliasCYP)->(CYP_QTMT))   ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                           lAssign := oModelCZP:SetValue('CZP_DTMT'  ,StoD((cAliasCYP)->(CYP_DTMT)));If !lAssign; Return SFCXMKERR(oModel); EndIf
                        EndIf
                        (cAliasCYP)->(dbCloseArea())
                     Next nI
                  EndIf
                  
                  //Ferramenta
                  oModelCZ0 := oModel:GetModel('CZ0DETAIL')
                  
                  oModelCZ0:SetNoInsertLine(.F.)
                  oModelCZ0:SetNoUpdateLine(.F.)
                  
                  For nI := 1 To oModelCZ0:Length()
                     oModelCZ0:GoLine( nI )
                     If !oModelCZ0:IsDeleted()
                        oModelCZ0:DeleteLine()
                     Endif
                  Next
                  
                  For nI := 1 To Len(aFerrament) 
                     oModelCZ0:AddLine()
                     lAssign := oModelCZ0:SetValue('CZ0_CDFE', aFerrament[nI]) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                  Next
                  
                  If oModel:VldData()  
                     // Caso nao ocorra erros, efetiva os dados no banco
                     If oModel:CommitData()
                        // Retorna OK
                        cXMLRet := oModel:GetValue("CYVMASTER","CYV_NRSQRP")
                        lRet := .T.
                     Else
                        cLogErro := ""
                        aErroAuto := GetAutoGRLog()
                        cLogErro := getMsgErro(aErroAuto)
                        If Empty(cLogErro) .And. Len(aErroAuto) > 0
                           For nCount := 1 To Len(aErroAuto)
                              cLogErro += StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|")
                           Next nCount
                        EndIf
                        // Cria TAG com o Erro ocorrido para retornar ao EAI
                        aErro := oModel:GetErrorMessage()
                        cXMLRet := cLogErro + SFCXXtoS(aErro[6]) + ' (' + SFCXXtoS(aErro[4]) + ' = "' + SFCXXtoS(aErro[9]) + '")'      
                        lRet := .F.
                     EndIf
                  Else
                     aErroAuto := GetAutoGRLog()
                     cLogErro := getMsgErro(aErroAuto)
                     
                     // Cria TAG com o Erro ocorrido para retornar ao EAI
                     aErro := oModel:GetErrorMessage()
                     cXMLRet := cLogErro + SFCXXtoS(aErro[6]) + ' (' + SFCXXtoS(aErro[4]) + ' = "' + SFCXXtoS(aErro[9]) + '")'      
                     lRet := .F.
                  EndIf
                  
                  // Desativa o Model
                  oModel:DeActivate()
               EndIf
            Else
               
               If !lBackFlush .And. !lEncerraOP
                  aBaixa     := {}
                  aCabBaixa  := {}
                  lCoProduto := .F.
                  For nI := 1 To Len(aSupply)
                     If aSupply[nI,3] < 0
                        //Componentes com quantidade negativa são salvos em outra movimentação da SD3.
                        lCoProduto := .T.
                        Loop
                     EndIf
                     //If Localiza(aSupply[nI,2])
                     //   cEnderec := "D3_NUMSERI"
                    // Else
                        cEnderec := "D3_LOTECTL"
                     //EndIf
                     aAdd(aBaixa, {{"D3_COD"    , aSupply[nI,2], Nil},;
                                   {"D3_QUANT"  , aSupply[nI,3], Nil},;
                                   {"D3_LOCAL"  , aSupply[nI,4], Nil},;
                                   {"D3_OP"     , aSupply[nI,1], Nil},;
                                   {cEnderec    , aSupply[nI,6], NIl},;
                                   {"D3_LOCALIZ", aSupply[nI,5], NIl}})
                     If AllTrim(UPPER(cProduct)) == "PPI"
                     	aAdd(aBaixa[Len(aBaixa)],{"D3_OBSERVA","TOTVSMES",Nil})
                     EndIf
                  Next nI
                  SOE->(dbSeek(xFilial("SOE")+"SF5"))
                  aCabBaixa := {{"D3_DOC"    , Substr(cNumOp,1,6)    , Nil},;
                                {"D3_TM"     , AllTrim(SOE->OE_VAR2) , Nil},;
                                {"D3_EMISSAO", dDateIni              , Nil},;
                                {"AUTITEMS"  , aClone(aBaixa)        , Nil}}
                  If lCoProduto
                     //Co-produto (Componentes recebidos com quantidade negativa)
                     aBaixa := {}
                     aCabCoProd := {}
                     For nI := 1 To Len(aSupply)
                        If aSupply[nI,3] >= 0
                           //Somente componentes com quantidade negativa
                           Loop
                        EndIf
                       // If Localiza(aSupply[nI,2])
                       //    cEnderec := "D3_NUMSERI"
                       // Else
                           cEnderec := "D3_LOTECTL"
                       // EndIf
                        aAdd(aBaixa, {{"D3_COD"    , aSupply[nI,2], Nil},;
                                      {"D3_QUANT"  , aSupply[nI,3] * (-1), Nil},;
                                      {"D3_LOCAL"  , aSupply[nI,4], Nil},;
                                      {"D3_OP"     , aSupply[nI,1], Nil},;
                                      {cEnderec    , aSupply[nI,6], NIl},;
                                      {"D3_LOCALIZ", aSupply[nI,5], NIl}})
                        If AllTrim(UPPER(cProduct)) == "PPI"
                        	aAdd(aBaixa[Len(aBaixa)],{"D3_OBSERVA","TOTVSMES",Nil})
                        EndIf
                     Next nI
                     SOE->(dbSeek(xFilial("SOE")+"SF5"))
                     aCabCoProd := {{"D3_DOC"    , Substr(cNumOp,1,6)   , Nil},;
                                    {"D3_TM"     , AllTrim(SOE->OE_VAR3), Nil},;
                                    {"D3_EMISSAO", dDateIni             , Nil},;
                                    {"AUTITEMS"  , aClone(aBaixa)       , Nil}}
                  EndIf
               EndIf

               If Len(aRefugos) > 0 .And. !lEncerraOP
                  For nI := 1 To Len(aRefugos)
                     aAdd(aDadosBC, {{"BC_TIPO"   ,"R"           , Nil},;
                                     {"BC_MOTIVO" ,aRefugos[nI,1], Nil},;
                                     {"BC_QUANT"  ,aRefugos[nI,16], Nil}})
                     If !Empty(aRefugos[nI,4])
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_PRODUTO", aRefugos[nI,4], Nil} )
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_LOCORIG", aRefugos[nI,5], Nil} )
                     Else
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_PRODUTO", cProduto, Nil} )
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_LOCORIG", cLocal, Nil} )
                     EndIf
                     If !Empty(aRefugos[nI,6])
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_CODDEST", aRefugos[nI,6], Nil} )
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_LOCAL"  , aRefugos[nI,7], Nil} )
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_QTDDEST", aRefugos[nI,17], Nil} )
                     Else
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_CODDEST", Nil, Nil} )
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_LOCAL"  , Nil, Nil} )
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_QTDDEST", Nil, Nil} )
                     EndIf
                     aAdd(aDadosBC[Len(aDadosBC)], {"BC_OBSERVA", Iif(AllTrim(UPPER(cProduct))=="PPI","TOTVSMES",cProduct) , Nil} )
                     If !Empty(aRefugos[nI,8])
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_LOCALIZ", AllTrim(aRefugos[nI,8]),Nil})
                     Else
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_LOCALIZ", Nil,Nil})
                     EndIf
                     If !Empty(aRefugos[nI,9])
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_NUMSERI", AllTrim(aRefugos[nI,9]),Nil})
                     Else
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_NUMSERI", Nil,Nil})
                     EndIf
                     If !Empty(aRefugos[nI,10])
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_LOCDEST", AllTrim(aRefugos[nI,10]),Nil})
                     Else
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_LOCDEST", Nil,Nil})
                     EndIf
                     If !Empty(aRefugos[nI,11])
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_NSEDEST", AllTrim(aRefugos[nI,11]),Nil})
                     Else
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_NSEDEST", Nil,Nil})
                     EndIf
                     If !Empty(aRefugos[nI,12])
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_LOTECTL", AllTrim(aRefugos[nI,12]),Nil})
                     Else
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_LOTECTL", Nil,Nil})
                     EndIf
                     If !Empty(aRefugos[nI,13])
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_NUMLOTE", AllTrim(aRefugos[nI,13]),Nil})
                     Else
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_NUMLOTE", Nil,Nil})
                     EndIf
                     If !Empty(aRefugos[nI,14])
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_DTVALID", aRefugos[nI,14],Nil})
                     Else
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_DTVALID", Nil,Nil})
                     EndIf
                     If !Empty(aRefugos[nI,15])
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_CC", AllTrim(aRefugos[nI,15]),Nil})
                     Else
                        aAdd(aDadosBC[Len(aDadosBC)], {"BC_CC", Nil,Nil})
                     EndIf
                  Next nI
               EndIf
               
               If !lEncerraOP
                  //Carrega o array com os valores necessários para o apontamento.
                  If !Empty(cNumOp)
                     aAdd(aSH6,{"H6_OP", cNumOp, NIL})
                  EndIf
                  If !Empty(cMaquina)
                     aAdd(aSH6,{"H6_RECURSO", cMaquina, NIL })
                  EndIf
                  If !Empty(cOperacao)
                     aAdd(aSH6,{"H6_OPERAC", cOperacao, NIL })
                  EndIf
                  If !Empty(cProduto)
                     aAdd(aSH6,{"H6_PRODUTO", cProduto, NIL })
                  EndIf
                  If !Empty(nQtdApr)
                     aAdd(aSH6,{"H6_QTDPROD", nQtdApr, NIL })
                  EndIf
                  If !Empty(nQtdRef)
                     aAdd(aSH6,{"H6_QTDPERD", nQtdRef, NIL })
                  EndIf
                  aAdd(aSH6,{"H6_DATAINI", dDateIni, NIL })               
                  aAdd(aSH6,{"H6_DATAFIN", dDateFim, NIL })                                                 
                  If !Empty(dReportDat)
                     aAdd(aSH6,{"H6_DTAPONT", dReportDat, NIL })
                  EndIf
                  If !Empty(cLocal)
                     aAdd(aSH6,{"H6_LOCAL", cLocal, NIL })
                  EndIf
                  If !Empty(cLoteCtl)
                     aAdd(aSH6,{"H6_LOTECTL", cLoteCtl, NIL })
                  EndIf
                  If !Empty(dDtValid)
                     aAdd(aSH6,{"H6_DTVALID", dDtValid, NIL })
                  EndIf
                  If !Empty(cPT)
                     aAdd(aSH6,{"H6_PT", cPT, NIL })
                  EndIf
                  If !Empty(cObserva)
                     aAdd(aSH6,{"H6_OBSERVA", cObserva, NIL })
                  EndIf
                  If !Empty(cSplit)
                     aAdd(aSH6,{"H6_DESDOBR", cSplit, NIL })
                  EndIf
                  if !(dDateIni == dDateFim .AND. cHoraIni == cHoraFim .AND. nQtdApr == 0 .AND. nQtdRef == 0)
                     If !Empty(cHoraIni)
                        aadd(aSH6, {"H6_HORAINI" ,cHoraIni   , NIL })
                     EndIf
                     If !Empty(cHoraFim)
                        aadd(aSH6, {"H6_HORAFIN" ,cHoraFim   , NIL })
                     EndIf
                  Endif 
                  aAdd(aSH6,{"H6_TIPO", "P", NIL })
                  aAdd(aSH6,{"AUTASKULT", lBackFlush, NIL })
                  /*
                  aSH6 := {{"H6_OP"      ,cNumOp     , NIL },;
                           {"H6_RECURSO" ,cMaquina   , NIL },;
                           {"H6_OPERAC"  ,cOperacao  , NIL },;
                           {"H6_PRODUTO" ,cProduto   , NIL },;
                           {"H6_QTDPROD" ,nQtdApr    , NIL },;
                           {"H6_QTDPERD" ,nQtdRef    , NIL },;
                           {"H6_DATAINI" ,dDateIni   , NIL },;
                           {"H6_DATAFIN" ,dDateFim   , NIL },;
                           {"H6_DTAPONT" ,dReportDat , NIL },;
                           {"H6_LOCAL"   ,cLocal     , NIL },;
                           {"H6_LOTECTL" ,cLoteCtl   , NIL },;
                           {"H6_DTVALID" ,dDtValid   , NIL },;
                           {"H6_PT"      ,cPT        , NIL },;
                           {"H6_OBSERVA" ,cObserva   , NIL },;
                           {"H6_TIPO"    ,"P"        , NIL },;
                           {"AUTASKULT"  ,lBackFlush , NIL },;
                           {"H6_DESDOBR" ,cSplit     , NIL }}
                           
                    */  
                           
                  If !lBackFlush
                     aAdd(aSH6, {"AUTCONSUMO", aCabBaixa, Nil})
                     aAdd(aSH6, {"AUTCOPRODU", aCabCoProd, Nil})
                  EndIf
                  If Len(aDadosBC) > 0
                     aAdd(aSH6, {"AUTREFUGO", aDadosBC, Nil})
                  EndIf
                  // PE MATI681CRG
                  If (ExistBlock('MATI681CRG'))
                     aSH6Aux := ExecBlock('MATI681CRG',.F.,.F.,aSH6)
                     For nCount := 1 To Len(aSH6Aux)
                        //Adiciona no array da SH6 somente os campos que não recebem informações do XML recebido.
                        If aScan(aSH6,{|x| Upper(AllTrim(x[1])) == Upper(AllTrim(aSH6Aux[nCount,1])) }) == 0
                           aAdd(aSH6, {aSH6Aux[nCount,1],aSH6Aux[nCount,2], Nil})
                        EndIf
                     Next nCount
                  EndIf
               EndIf
               
               // PE MATI681EXC
               If (ExistBlock('MATI681EXC'))
                  aRet := ExecBlock('MATI681EXC',.F.,.F.,aSH6)
                  If !aRet[1]
                     Return {.F., Iif(Empty(aRet[2]), STR0010, aRet[2] ) } //"Não processado devido ao Ponto de Entrada MATI681EXC."
                  EndIf
               EndIf
               MSExecAuto({|x,y| mata681(x,y)},aSH6,nOperation)
               
               If lMsErroAuto
                  aErroAuto := GetAutoGRLog()
                  cLogErro := getMsgErro(aErroAuto)
                  lRet    := .F.
                  cXMLRet := cLogErro
                  Return {lRet,cXmlRet}
               Else
                  lRet    := .T.
                  cXmlRet := Iif(lEncerraOP,"OK",cValToChar(SH6->(Recno())))
                  
                  
                  //Se utiliza consumo real, deve verificar se foi realizado o apontamento de quantidade na ultima operação
                  //para executar a rotina de encerramento da OP.
                  If !lBackFlush .And. AllTrim(cPT) == "T" .And. nOperation != 7
                     l680 := .F.
                     l681 := .F.
                     If (SH6->H6_QTDPROD > 0 .Or. SH6->H6_QTDPERD > 0) .And. A680UltOper(.F.)
                        //Posiciona na ultima operação apontada
                        aSH6 := {{"H6_OP"      ,SH6->H6_OP      , NIL },;
                                 {"H6_RECURSO" ,SH6->H6_RECURSO , NIL },;
                                 {"H6_OPERAC"  ,SH6->H6_OPERAC  , NIL },;
                                 {"H6_PRODUTO" ,SH6->H6_PRODUTO , NIL },;
                                 {"H6_QTDPROD" ,SH6->H6_QTDPROD , NIL },;
                                 {"H6_QTDPERD" ,SH6->H6_QTDPERD , NIL },;
                                 {"H6_DATAINI" ,SH6->H6_DATAINI , NIL },;
                                 {"H6_DATAFIN" ,SH6->H6_DATAFIN , NIL },;
                                 {"H6_DTAPONT" ,SH6->H6_DTAPONT , NIL },;
                                 {"H6_LOCAL"   ,SH6->H6_LOCAL   , NIL },;
                                 {"H6_LOTECTL" ,SH6->H6_LOTECTL , NIL },;
                                 {"H6_DTVALID" ,SH6->H6_DTVALID , NIL },;
                                 {"H6_PT"      ,SH6->H6_PT      , NIL },;
                                 {"H6_OBSERVA" ,SH6->H6_OBSERVA , NIL },;
                                 {"H6_TIPO"    ,SH6->H6_TIPO    , NIL },;
                                 {"H6_DESDOBR" ,SH6->H6_DESDOBR , NIL },;
                                 {"AUTRECNO"   ,SH6->(Recno())  , Nil }}
                        
                        nOperation := 7
                        MSExecAuto({|x,y| mata681(x,y)},aSH6,nOperation)
                        If lMsErroAuto
                           aErroAuto := GetAutoGRLog()
                           cLogErro := getMsgErro(aErroAuto)
                           lRet    := .F.
                           cXMLRet := cLogErro
                           Return {lRet,cXmlRet}
                        EndIf
                     EndIf
                  EndIf
               EndIf
            EndIf
         EndIf
      EndIf

   ElseIf nTypeTrans == TRANS_SEND

   EndIf

   If !lIntegPPI
      AdpLogEAI(5, "MATI681", cXMLRet, lRet)
   EndIf

Return {lRet, cXmlRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getDate

Retorna somente a data de uma variável datetime

@param dDateTime - Variável DateTime

@return dDate - Retorna a data.

@author  Lucas Konrad França
@version P12
@since   24/09/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function getDate(dDateTime)
   Local dDate := Nil
   If AT("T",dDateTime) > 0
      dDate := StrTokArr(dDateTime,"T")[1]
   Else
      dDate := StrTokArr(AllTrim(dDateTime)," ")[1]
   EndIf
   dDate := SubStr(dDate,1,4)+SubStr(dDate,6,2)+SubStr(dDate,9,2)
Return dDate

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTime

Retorna somente a hora de uma variável datetime

@param dDateTime - Variável DateTime

@return cTime - Retorna a hora

@author  Lucas Konrad França
@version P12
@since   29/09/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function getTime(dDateTime)
   Local cHora := Nil
   Local aHora := {}
   If AT("T",dDateTime) > 0
      aHora := StrTokArr(dDateTime,"T")
   Else
      aHora := StrTokArr(dDateTime," ")
   EndIf
   If Len(aHora) > 1
      cHora := SubStr(aHora[2],1,8)
   EndIf
Return cHora

Static Function CorValFld(cValue,cField)
Return AllTrim(cValue) + Space(TamSX3(cField)[1] - Len(AllTrim(cValue)))

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getMsgErro

Transforma o array com as informações de um erro em uma string para ser retornada.

@param aErro - Array com a mensagem de erro, obtido através da função GetAutoGRLog

@return cMsg - Mensagem no formato String

@author  Lucas Konrad França
@version P12
@since   07/03/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function getMsgErro(aErro)
	Local cMsg     := ""
	Local cLineMsg := ""
	Local cFullMsg := ""
	Local nCount   := 0
	
	For nCount := 1 To Len(aErro)
		cLineMsg := AllTrim(StrTran( StrTran( StrTran( StrTran( StrTran( aErro[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|"))
		
		If !Empty(cFullMsg)
			cFullMsg += " "
		EndIf

		cFullMsg += cLineMsg
		
		If AT(':=',aErro[nCount]) > 0 .And. AT('< --',aErro[nCount]) < 1
			Loop
		EndIf
		If AT("------", aErro[nCount]) > 0
			Loop
		EndIf
		
		//Retorna somente a mensagem de erro (Help) e o valor que está inválido, sem quebras de linha e sem tags '<>'
		If !Empty(cMsg)
			cMsg += " "
		EndIf
		cMsg += cLineMsg
	Next nCount
	
	//Não conseguiu obter somente a mensagem de erro, então retorna a mensagem completa.
	If Empty(cMsg) .And. Len(aErro) > 0
		cMsg := cFullMsg
	EndIf

	//Emite LOG de erro no console.log.
	LogMsg('MATI681', 14, 4, 1, '', '', cFullMsg)
Return cMsg
