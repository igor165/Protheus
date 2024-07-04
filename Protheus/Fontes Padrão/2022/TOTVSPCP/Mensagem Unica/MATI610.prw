#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI610.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

Static oModelSFC

Function MATI610MOD(oNewModel)
	oModelSFC := oNewModel
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI610

Funcao de integracao com o adapter EAI para recebimento do  cadastro de
Recurso (SH1) utilizando o conceito de mensagem unica.

@param   cXml        Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans   Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Lucas Konrad França
@version P12
@since   17/08/2015
@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
        o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
        TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
        O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Function MATI610(cXml, nTypeTrans, cTypeMessage) 
   Local lRet        := .T.
   Local cXmlRet     := ""
   Local aRet        := {}
   
   Private lIntegPPI := .F.
   Private oXml      := Nil

   //Verifica se está sendo executado para realizar a integração com o PPI.
   //Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
   //Variável é criada no fonte mata610.prx, na função mata610PPI().
   If Type("lRunPPI") == "L" .And. lRunPPI
      lIntegPPI := .T.
   EndIf

   //Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      /*
         Mensagem desenvolvida para integração com o PCFactory, não possui recebimento.
      */
   ElseIf nTypeTrans == TRANS_SEND
      If lIntegPPI
         aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXml)
         lRet    := aRet[1]
         cXMLRet := aRet[2]
	   EndIf
   EndIf


Return {lRet, cXmlRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000

Funcao de integracao com o adapter EAI para recebimento do  cadastro de
Recurso (SH1) utilizando o conceito de mensagem unica.

@param   cXml        Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans   Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Lucas Konrad França
@version P12
@since   17/08/2015
@return  aRet  - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
       o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
       TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
       O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Static Function v1000(cXml, nTypeTrans, cTypeMessage, oXml)
   Local lRet       := .T.
   Local lLog       := .T. //FindFunction("AdpLogEAI")
   Local lExecSFC   := .F.
   Local cXMLRet    := ""
   Local cEvent     := ""
   Local cEntity    := "Machine"
   Local aAreaAnt   := GetArea()
   Local nI         := 0
   Local aRecursos  := {}
   Local aTurnos    := {}
   
   Local lUnitTime  := ExistBlock("MTI610UTTP")
   Local cUnitTime  := "1"
   
   //Campos SH1
   Local cH1Codigo  := ""
   Local cH1Descri  := ""
   Local cH1CTrab   := ""
   Local nH1MaoObra := 0
   Local cH1CCusto  := ""
   
   //Campos SFC
   Local cCYBTPPC   := ""
   Local cCYBTPMOD  := ""
   Local nCYBQTVMMQ := 0
   Local nCYBQTOEMQ := 0
   Local nCYBQTATSM := 0
   Local lCYBLGSU   := .F.
   Local lCYBLGOVRP := .F.
   Local cCYBCDARPO := ""
   Local dCYBDTBGVD := Nil
   Local dCYBDTEDVD := NIl
   
   //Posições do array aRecursos
   Local nCYCTPRC   := 1  
   Local nCYCCDRC   := 2
   Local nCYCNMRC   := 3
   Local nCYCTPUNTE := 4
   Local nCYCDTBGVD := 5
   Local nCYCDTEDVD := 6
   Local nCYCQTCI   := 7
   Local nCYCLGTEAT := 8
   
   //Posições do array aTurnos
   Local nCYLCDTN   := 1
   Local nCYLDSTN   := 2
   Local nCYLDTVDBG := 3
   Local nCYLDTVDED := 4
   
   Local oModelCYC, oModelCYL

   If !lIntegPPI
      //IIf(lLog, AdpLogEAI(1, "MATI610", nTypeTrans, cTypeMessage, cXML), ConOut(STR0004)) //"Atualize o UPDINT01.prw para utilizar o log"
      If lLog
         AdpLogEAI(1, "MATI610", nTypeTrans, cTypeMessage, cXML)
      EndIf
   EndIf
   
   //Se está com a integração do chão de fábrica ativada, e está executando através do SFCA002, 
   //busca os dados sempre do model do SFCA002
   If (IsInCallStack("AUTO610") .Or. IsInCallStack("PCPA111PPI") ) .And. SuperGetMV("MV_INTSFC",.F.,0)==1
      lExecSFC := .T.
   EndIf

   If nTypeTrans == TRANS_RECEIVE
      /*
         Mensagem desenvolvida para integração com o PCFactory, e nao possui recebimento.
      */
   ElseIf nTypeTrans == TRANS_SEND
      // Verifica se é uma exclusão
      If !Inclui .And. !Altera
         cEvent := 'delete'
      Else
         cEvent := 'upsert'
      EndIf
      
      If !lExecSFC
         cH1Codigo  := M->H1_CODIGO
         cH1Descri  := M->H1_DESCRI
         cH1CTrab   := M->H1_CTRAB
         nH1MaoObra := M->H1_MAOOBRA
         cH1CCusto  := M->H1_CCUSTO
      Else
         cH1Codigo  := oModelSFC:GetValue("CYBMASTER","CYB_CDMQ")
         cH1Descri  := oModelSFC:GetValue("CYBMASTER","CYB_DSMQ")
         cH1CTrab   := oModelSFC:GetValue("CYBMASTER","CYB_CDCETR")
         nH1MaoObra := oModelSFC:GetValue("CYBMASTER","CYB_VLEFMQ")
         cH1CCusto  := oModelSFC:GetValue("CYBMASTER","CYB_CDCECS")
         cCYBTPPC   := oModelSFC:GetValue("CYBMASTER","CYB_TPPC")
         cCYBTPMOD  := oModelSFC:GetValue("CYBMASTER","CYB_TPMOD")
         nCYBQTVMMQ := oModelSFC:GetValue("CYBMASTER","CYB_QTVMMQ")
         nCYBQTOEMQ := oModelSFC:GetValue("CYBMASTER","CYB_QTOEMQ")
         nCYBQTATSM := oModelSFC:GetValue("CYBMASTER","CYB_QTATSM")
         lCYBLGSU   := oModelSFC:GetValue("CYBMASTER","CYB_LGSU")
         lCYBLGOVRP := oModelSFC:GetValue("CYBMASTER","CYB_LGOVRP")
         cCYBCDARPO := oModelSFC:GetValue("CYBMASTER","CYB_CDARPO")
         dCYBDTBGVD := oModelSFC:GetValue("CYBMASTER","CYB_DTBGVD")
         dCYBDTEDVD := oModelSFC:GetValue("CYBMASTER","CYB_DTEDVD")
      EndIf

      If IsInCallStack("MAT610_001")
         cH1Codigo := ""
      EndIf
      // Monta XML de envio de mensagem unica
      cXMLRet := '<BusinessEvent>'
      cXMLRet +=    '<Entity>' + cEntity + '</Entity>'
      cXMLRet +=    '<Event>' + cEvent + '</Event>'
      cXMLRet +=    '<Identification>'
      cXMLRet +=       '<key name="InternalID">' + IntRecExt(/*Empresa*/, /*Filial*/, cH1Codigo, /*Versão*/)[2] + '</key>'
      cXMLRet +=    '</Identification>'
      cXMLRet += '</BusinessEvent>'
      cXMLRet += '<BusinessContent>'
      cXMLRet +=    '<Code>' + AllTrim(cH1Codigo) + '</Code>'
      cXMLRet +=    '<Description>' + _NoTags(AllTrim(cH1Descri)) + '</Description>'
      cXMLRet +=    '<WorkCenterCode>' + AllTrim(cH1CTrab) + '</WorkCenterCode>'
      cXMLRet +=    '<WorkCenterDescription>' + _NoTags(getCTrab(cH1CTrab)) + '</WorkCenterDescription>'
      cXMLRet +=    '<ProcessorType>'+AllTrim(cCYBTPPC)+'</ProcessorType>'
      cXMLRet +=    '<LaborType>'+AllTrim(cCYBTPMOD)+'</LaborType>'
      cXMLRet +=    '<VolumeMachineQuantity>' + cValToChar(nCYBQTVMMQ) + '</VolumeMachineQuantity>'
      cXMLRet +=    '<EfficiencyMachineValue>' + cValToChar(nH1MaoObra) + '</EfficiencyMachineValue>'
      cXMLRet +=    '<OperatorMachineQuantity>' + cValToChar(nCYBQTOEMQ) + '</OperatorMachineQuantity>'
      cXMLRet +=    '<SimultaneousActivityQuantity>' + cValToChar(nCYBQTATSM) + '</SimultaneousActivityQuantity>'
      cXMLRet +=    '<IsSetup>' + Iif(lExecSFC, Iif(lCYBLGSU,"TRUE","FALSE") ," ") + '</IsSetup>'
      cXMLRet +=    '<IsControlPert />'
      cXMLRet +=    '<IsReportEvent />'
      cXMLRet +=    '<IsOverlapReport>' + Iif(lExecSFC, Iif(lCYBLGOVRP,"TRUE","FALSE")," ")  + '</IsOverlapReport>'
      cXMLRet +=    '<CostCenterCode>' + AllTrim(cH1CCusto) + '</CostCenterCode>'
      cXMLRet +=    '<ProductionAreaCode>' + AllTrim(cCYBCDARPO) + '</ProductionAreaCode>'
      cXMLRet +=    '<InitialValidateDate>' + getDate(dCYBDTBGVD) + '</InitialValidateDate>'
      cXMLRet +=    '<FinalValidateDate>' + getDate(dCYBDTEDVD) + '</FinalValidateDate>' 
      If lExecSFC
         oModelCYC := oModelSFC:GetModel("CYCDETAIL")
         If oModelCYC:Length() > 0
            For nI := 1 To oModelCYC:Length()
               oModelCYC:GoLine(nI)
               If oModelCYC:IsDeleted() .Or. Empty(oModelCYC:GetValue("CYC_CDRC"))
                  Loop
               EndIf
               aAdd(aRecursos,{oModelCYC:GetValue("CYC_TPRC"),;
                               oModelCYC:GetValue("CYC_CDRC"),;
                               oModelCYC:GetValue("CYC_NMRC"),;
                               oModelCYC:GetValue("CYC_TPUNTE"),;
                               oModelCYC:GetValue("CYC_DTBGVD"),;
                               oModelCYC:GetValue("CYC_DTEDVD"),;
                               oModelCYC:GetValue("CYC_QTCI"),;
                               oModelCYC:GetValue("CYC_LGTEAT")})
            Next nI
            If Len(aRecursos) < 1
               cXmlRet += '<ListOfResources />'
            Else
               cXmlRet += '<ListOfResources>'
               For nI := 1 To Len(aRecursos)
                  cXmlRet += '<Resource>'
                  cXmlRet +=    '<ResourceType>' + AllTrim(aRecursos[nI,nCYCTPRC]) + '</ResourceType>'
                  cXmlRet +=    '<ResourceCode>' + AllTrim(aRecursos[nI,nCYCCDRC]) + '</ResourceCode>'
                  cXmlRet +=    '<ResourceName>' + AllTrim(aRecursos[nI,nCYCNMRC]) + '</ResourceName>'
                  If lUnitTime
                     cUnitTime := ExecBlock('MTI610UTTP',.F.,.F.,aRecursos[nI,nCYCCDRC])
                     If ValType(cUnitTime) != "C"
                        cUnitTime := "1"
                     EndIf
               
                     cXmlRet +=    '<UnitTimeType>' + cUnitTime + '</UnitTimeType>'
                  Else
                     cXmlRet +=    '<UnitTimeType>' + AllTrim(aRecursos[nI,nCYCTPUNTE]) + '</UnitTimeType>'
                  EndIf
                  cXmlRet +=    '<StartExpirationDate>' + getDate(aRecursos[nI,nCYCDTBGVD]) + '</StartExpirationDate>'
                  cXmlRet +=    '<EndExpirationDate>' + getDate(aRecursos[nI,nCYCDTEDVD]) + '</EndExpirationDate>'
                  cXmlRet +=    '<IsTimeActivity>' + Iif(aRecursos[nI,nCYCLGTEAT],"TRUE","FALSE") + '</IsTimeActivity>'
                  cXmlRet +=    '<CycleQuantity>' + cValToChar(aRecursos[nI,nCYCQTCI]) + '</CycleQuantity>'
                  cXmlRet += '</Resource>'
               Next nI
               cXmlRet += '</ListOfResources>'
            EndIf
         Else
            cXmlRet += '<ListOfResources />'
         EndIf
      Else
         cXmlRet +=    '<ListOfResources />'
      EndIf
      If lExecSFC
         oModelCYL := oModelSFC:GetModel("CYLDETAIL")
         If oModelCYL:Length() > 0
            For nI := 1 To oModelCYL:Length()
               oModelCYL:GoLine(nI)
               If oModelCYL:IsDeleted() .Or. Empty(oModelCYL:GetValue("CYL_CDTN"))
                  Loop
               EndIf
               aAdd(aTurnos, { oModelCYL:GetValue("CYL_CDTN"),;
               	               POSICIONE("CYM",1,XFILIAL("CYM")+oModelCYL:GetValue("CYL_CDTN"),"CYM_DSTN"),;
               	               oModelCYL:GetValue("CYL_DTVDBG"),; 
               	               oModelCYL:GetValue("CYL_DTVDED")})
            Next nI
            If Len(aTurnos) > 0
               cXmlRet += '<ListOfProductionShifts>'
               For nI := 1 To Len(aTurnos)
                  cXmlRet += '<ProductionShift>'
                  cXmlRet +=    '<ProductionShiftCode>' + aTurnos[nI,nCYLCDTN] + '</ProductionShiftCode>'
                  cXmlRet +=    '<ProductionShiftDescription>' + aTurnos[nI,nCYLDSTN] + '</ProductionShiftDescription>'
                  cXmlRet +=    '<BeginDate>' + getDate(aTurnos[nI,nCYLDTVDBG]) + '</BeginDate>'
                  cXmlRet +=    '<EndDate>' + getDate(aTurnos[nI,nCYLDTVDED]) + '</EndDate>'
                  cXmlRet += '</ProductionShift>'
               Next nI
               cXmlRet += '</ListOfProductionShifts>'
            Else
               cXmlRet += '<ListOfProductionShifts />'
            EndIf
         Else
            cXmlRet += '<ListOfProductionShifts />'
         EndIf
      Else
         cXmlRet += '<ListOfProductionShifts />'
      EndIf      
      cXmlRet +=    '<ListOfControlItems />'
      //cXmlRet +=       '<ControlItem>'
      //cXmlRet +=          '<ControlItemCode />'
      //cXmlRet +=          '<ControlItemDescription />'
      //cXmlRet +=          '<MinDate />'
      //cXmlRet +=          '<MaxDate />'
      //cXmlRet +=          '<IsMandatory />'
      //cXmlRet +=          '<MaxChoices />'
      //cXmlRet +=          '<MinValue />'
      //cXmlRet +=          '<MaxValue />'
      //cXmlRet +=       '</ControlItem>'
      //cXmlRet +=    '</ListOfControlItems>'
      cXmlRet += '</BusinessContent>'

      If lIntegPPI
         completXml(@cXMLRet)
      EndIf

   EndIf

   If !lIntegPPI
      //IIf(lLog, AdpLogEAI(5, "MATI610", cXMLRet, lRet), ConOut(STR0004))
      If lLog
         AdpLogEAI(5, "MATI610", cXMLRet, lRet)
      EndIf   
   EndIf
   
   RestArea(aAreaAnt)
Return {lRet, cXmlRet}

// --------------------------------------------------------------------------------------
/*/{Protheus.doc} getCTrab
Busca a descrição do Centro de trabalho

@param   cCTrab código do centro de trabalho

@author  Lucas Konrad França
@version P12
@since   17/08/2015
@return  cResult Variavel com o valor obtido
/*/
// --------------------------------------------------------------------------------------
Static Function getCTrab(cCTrab)
   Local cResult  := ""
   Local aAreaAnt := GetArea()

   dbSelectArea("SHB")
   SHB->(dbSetOrder(1))

   If !Empty(cCTrab) .And. SHB->(dbSeek(xFilial("SHB") + cCTrab))
      cResult := AllTrim(SHB->HB_NOME)
   EndIf

   RestArea(aAreaAnt)
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntRecExt
Monta o InternalID do Recurso de acordo com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cRecurso   Código do Recurso
@param   cVersao    Versão da mensagem única (Default 1.000)

@author  Lucas Konrad França
@version P12
@since   17/08/2015
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntRecExt(,,'01') irá retornar {.T.,'01|01|01'}
/*/
//-------------------------------------------------------------------
Function IntRecExt(cEmpresa, cFil, cRecurso, cVersao)
   Local aResult    := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('SH1')
   Default cVersao  := '1.000'

   If cVersao == '1.000'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cRecurso))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0005 + Chr(10) + STR0006) // "Versão do recurso não suportada." "As versões suportadas são: 1.000"
   EndIf   
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} completXml()
Adiciona o cabeçalho da mensagem quando utilizado integração com o PPI.

@param   cXML  - XML gerado pelo adapter. Parâmetro recebido por referência.

@author  Lucas Konrad França
@version P12
@since   13/08/2015
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function completXml(cXML)
   Local cCabec     := ""
   Local cCloseTags := ""
   Local cGenerated := ""

   cGenerated := SubStr(DTOS(Date()), 1, 4) + '-' + SubStr(DTOS(Date()), 5, 2) + '-' + SubStr(DTOS(Date()), 7, 2) + 'T' + Time()

   cCabec := '<?xml version="1.0" encoding="UTF-8" ?>'
   cCabec += '<TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="xmlschema/general/events/Machine_1_000.xsd">'
   cCabec +=     '<MessageInformation version="1.000">'
   cCabec +=         '<UUID>1</UUID>'
   cCabec +=         '<Type>BusinessMessage</Type>'
   cCabec +=         '<Transaction>Machine</Transaction>'
   cCabec +=         '<StandardVersion>1.0</StandardVersion>'
   cCabec +=         '<SourceApplication>SIGAPCP</SourceApplication>'
   cCabec +=         '<CompanyId>'+cEmpAnt+'</CompanyId>'
   cCabec +=         '<BranchId>'+cFilAnt+'</BranchId>'
   cCabec +=         '<UserId>'+__cUserId+'</UserId>'
   cCabec +=         '<Product name="'+FunName()+'" version="'+GetRPORelease()+'"/>'
   cCabec +=         '<GeneratedOn>' + cGenerated +'</GeneratedOn>'
   cCabec +=         '<ContextName>PROTHEUS</ContextName>'
   cCabec +=         '<DeliveryType>Sync</DeliveryType>'
   cCabec +=     '</MessageInformation>'
   cCabec +=     '<BusinessMessage>'

   cCloseTags := '</BusinessMessage>'
   cCloseTags += '</TOTVSMessage>'
   
   cXML := cCabec + cXML + cCloseTags

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getDate()
Formata uma data para o padrão enviado por XML (YYYY-MM-DD)

@param   dDate  - Data que será transformada para String

@author  Lucas Konrad França
@version P12
@since   04/04/2016
@return  cDate
/*/
//-------------------------------------------------------------------
Static Function getDate(dDate)
   Local cDate     := ""

   If !Empty(dDate)
      cDate := DtoS(dDate)
      cDate := SubStr(cDate, 1, 4) + '-' + SubStr(cDate, 5, 2) + '-' + SubStr(cDate, 7, 2)
   EndIf
Return cDate