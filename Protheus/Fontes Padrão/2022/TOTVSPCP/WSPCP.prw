#include 'protheus.ch'
#include 'apwebsrv.ch'
#INCLUDE 'XMLXFUN.CH'
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "WSPCP.CH"

Function __WSPCP()
Return

WSSERVICE WSPCP ;
    DESCRIPTION STR0001 ; //"WebService utilizado pelas rotinas do PCP Protheus."
    NAMESPACE 'http://webservices.totvs.com.br/'

    WSDATA cXml           AS STRING
    WSDATA cResponse      AS STRING

    WSMETHOD receiveMessage   ;
        DESCRIPTION STR0002 //"Recebe uma mensagem XML, no padrão definido pelo XSD Totvs."
ENDWSSERVICE

WSMETHOD receiveMessage WSRECEIVE cXml WSSEND cResponse WSSERVICE WSPCP
   Local aManualJob := StrTokArr(SuperGetMV("MV_TWSPCP",.F.,'10,10,10,1'),',') //tempo, maximo, minimo livre e incriemento
   Local cEmpIntg   := Iif(Type( 'cEmpAnt' )== 'C' ,cEmpAnt, '' )
   Local cFilIntg   := Iif(Type( 'cFilAnt' )== 'C' ,cFilAnt, '' )
   Local cPar       := ''
   Local cSemaforo  := ''
   Local nTent      := 0
  
   Private oXml   
 
   ManualJob("POOL_THREADS_WSPCP"/*Nome do indentificador do job*/,;
      GetEnvServer()/*Ambiente que vc vai abrir este cara*/,;
      "IPC"/*Tipo do job. Mantenha como Ipc*/,;
      "WSPCPCON"/*Função que será chamada quando uma nova thread subir*/,;
      "WSPCPRUN"/*Função que será chamada toda vez que vc mandar um ipcgo para ela*/,;
      "WSPCPFIN"/*Função que será invocada quando a thread cair pelo timeout dela*/,;
      ""/*Não alterar. É o SessionKey*/,;
      val(aManualJob[1])/*Tempo que a thread será reavaliada e irá cair. Vamos manter 5 minutos. Se não receber nada ela morre*/,;
      0/*Minimo de threads inicias. Vamos deixar 0 para que quando cair por timeout ele acabe*/,;
      val(aManualJob[2])/*máximo de threads que ele vai subir*/,;
      val(aManualJob[3])/*mínimo de threads livres*/,;
      val(aManualJob[4])/*incremento de threads livres*/)    
   
   cSemaforo := 'WSPCP_RETORNO'+CValToChar(threadid())

   While !IpcGo('POOL_THREADS_WSPCP',::cXml,cEmpIntg,cFilIntg,cSemaforo)
      nTent ++
      If nTent > 100 //aqui limitei para tentar 100 vezes, em média 4 minutos               
         parseXml(::cXml, @oXml)             
         ::cResponse := getReturn(.F.,STR0013, ::cXml,"","",cEmpIntg,cFilIntg)   
      Else
         Sleep(500)
      Endif
   EndDo
    
   //tratamento para o retorno do xml.
   While !killapp()      
      lRet := IpcWaitEx( cSemaforo, 5000, @cPar )
      //5000, tempo esperando o retorno.
      //cPar é o retorno do wspcprun, com o xml.
      If lRet
         ::cResponse := cPar
         exit
      Endif
   EndDo
  
Return .T.

Function WSPCPCON()

Return .T.

Function WSPCPFIN()

Return .T.

Function WSPCPRUN(cXml,cEmpOri,cFilOri,cSemaforo)

   Local bError       := ErrorBlock({|e| wspcpexecp(e)})
   Local cEmpIntg     := cEmpOri
   Local cFilIntg     := cFilOri
   Local cStatus      := ""
   Local cMsg         := ""
   Local cTransac     := ""
   Local cIdMes       := ""
   Local nI           := 0
   Local cStatusPrc   := ""
   Local cXmlRet      := ""

   Private aRetorno   := {}
   Private oXml
   Private lErro      := .F.
   Private aMsg       := {}
   Private cMaquina   := ""
   Private cNumOp     := ""
   Private cProduto   := ""
   Private cOperacao  := ""
   Private nQtdSOG    := 0
   Private dDateIni   := Nil
   Private cHoraIni   := ""
   Private dDateFim   := Nil
   Private cHoraFim   := ""
   Private lOnlyEstrn := .F.
   Private cMotivo    := ""
   Private cMovimento := ""
   Private cPrdOrigem := ""
   Private cPrdDestin := ""
   Private cLocOrigem := ""
   Private cLocDestin := ""
   Private cMesIDIntg := ""
   Private cRotina    := ""
   Private lReprocess := .F.
   Private lRunPPI    := .F.
   Private aDadosSOG  := {}
   Private lLockWS    := .T. 

   BEGIN SEQUENCE
  
   cXml := EncodeUTF8(cXml)
   //Retira tabulação e quebras de linha.
   cXml := StrTran(cXml, CHR(10), " " )
   cXml := StrTran(cXml, CHR(13), " " )
   cXml := StrTran(cXml, CHR(9), " " )
   cXml := AllTrim(cXml)
   
   //Realiza o Parse do XML recebido.
   aRetorno := parseXml(cXml, @oXml)
   If !aRetorno[1]
      //Erro. Retorna mensagem.     
      cMsg := getReturn(.F.,aRetorno[2], cXml,"","",cEmpIntg,cFilIntg)
      ResReturn(cMsg,cSemaforo)  
      Return nil
   EndIf
   
   If Type("oXml:_TotvsMessage:_MessageInformation:_CompanyId:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_CompanyId:Text)
      cEmpIntg := oXml:_TotvsMessage:_MessageInformation:_CompanyId:Text
   Else
      cEmpIntg := cEmpOri
   EndIf

   If Type("oXml:_TotvsMessage:_MessageInformation:_BranchId:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_BranchId:Text)
      cFilIntg := oXml:_TotvsMessage:_MessageInformation:_BranchId:Text
   Else
      cFilIntg := cFilOri
   EndIf

   If Empty(cEmpIntg) .Or. Empty(cFilIntg)
      cMsg := getReturn(.F.,STR0009, cXml,"","",cEmpIntg,cFilIntg) //"CompanyID/BranchID não informados."
      ResReturn(cMsg,cSemaforo)  
      Return nil
   EndIf

   OpenSm0(,.F.)
   If Select('SM0') > 0
      SM0->(dbSetOrder(1))
      If !SM0->(dbSeek(cEmpIntg))
         cMsg := getReturn(.F.,STR0010, cXml,"","",cEmpIntg,cFilIntg) //"CompanyId|BranchId inválidos."
         ResReturn(cMsg,cSemaforo)  
         Return nil         
      EndIf
   EndIf
   
   If !FWFilExist(cEmpIntg,cFilIntg)
      cMsg := getReturn(.F.,STR0010, cXml,"","",cEmpIntg,cFilIntg) //"CompanyId|BranchId inválidos."
      ResReturn(cMsg,cSemaforo)  
      Return nil       
   EndIf

   changeEmp(cEmpIntg,cFilIntg)   

   If Empty(oXml)
      parseXml(cXml, @oXml)
   EndIf
   
   If Type("oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
      If Upper(AllTrim(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)) == "PPI"
         lRunPPI := .T.
      EndIf
   EndIf
   If Type("oXml:_TotvsMessage:_MessageInformation:_Transaction:Text") != "U"
      cTransac := AllTrim(Upper(oXml:_TotvsMessage:_MessageInformation:_Transaction:Text))
   EndIf

   //Busca o ID de integração do PC-Factory
   If lRunPPI .And. !Empty(cTransac)
      If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key") == "O"
         If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:_Name:Text") != "U"
            If AllTrim(Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:_Name:Text)) == "IDPCFACTORY"
               If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text") != "U"
                  cIdMes := oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text
               EndIf
            EndIf
            If AllTrim(Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:_Name:Text)) == "REPROCESS"
               If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text") != "U"
                  If AllTrim(Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text))=="TRUE"
                     lReprocess := .T.
                  Else
                     lReprocess := .F.
                  EndIf
               EndIf
            EndIf
         EndIf
      ElseIf Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key") == "A"
         For nI := 1 To Len(oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key)
            If XmlChildEx(oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key[nI],"_NAME") != Nil
               If AllTrim(Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key[nI]:_Name:Text)) == "IDPCFACTORY"
                  cIdMes := oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key[nI]:Text
               EndIf
               If AllTrim(Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key[nI]:_Name:Text)) == "REPROCESS"
                  If AllTrim(Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key[nI]:Text))=="TRUE"
                     lReprocess := .T.
                  Else
                     lReprocess := .F.
                  EndIf
               EndIf
            EndIf
         Next nI
      EndIf
      If !Empty(cIdMes)
         If !PCPVldIMes(cIdMes,@cMsg, @cStatusPrc,@lReprocess)
            //Erro. Retorna mensagem.  
            cMsg := getReturn(.F.,cMsg, cXml, cStatusPrc, cIdMes, cEmpIntg, cFilIntg)
            ResReturn(cMsg,cSemaforo)  
            Return nil  
         Else
            PCPAtuSOH(cTransac, cIdMes, "", "0")
         EndIf
      EndIf
   EndIf
   
   cMesIDIntg := cIdMes    

   //Executa a integração, chamando o adapter responsável pela mensagem.
   aRetorno := execInteg(cXml,cTransac)
   If Empty(oXml)
      parseXml(cXml, @oXml)
   EndIf
   
   If aRetorno[1] .And. !lErro .And. Len(aDadosSOG) > 0
   	For nI := 1 To Len(aDadosSOG)
        PCPCriaSOG(aDadosSOG[nI,1], ;
                   aDadosSOG[nI,2], ;
                   aDadosSOG[nI,3], ;
                   aDadosSOG[nI,4], ;
                   aDadosSOG[nI,5], ;
                   aDadosSOG[nI,6], ;
                   aDadosSOG[nI,7], ;
                   aDadosSOG[nI,8], ;
                   aDadosSOG[nI,9], ;
                   aDadosSOG[nI,10], ;
                   aDadosSOG[nI,11], ;
                   aDadosSOG[nI,12], ;
                   aDadosSOG[nI,13], ;
                   Iif(lReprocess .And. AT("Reprocessado. ",aDadosSOG[nI,14]) == 0,"Reprocessado. ","") + aDadosSOG[nI,14], ;
                   aDadosSOG[nI,15], ;
                   aDadosSOG[nI,16], ;
                   aDadosSOG[nI,17], ;
                   aDadosSOG[nI,18], ;
                   aDadosSOG[nI,19], ;
                   aDadosSOG[nI,20], ;
                   aDadosSOG[nI,21])
   	Next nI
   EndIf

   If !((!lErro .And. aRetorno[1]) .And. lOnlyEstrn)
      changeEmp(aRetorno[3],aRetorno[4])
      If lErro
         cStatus := "2"
         cMsg    := aMsg[1]
      Else
         cStatus := Iif(aRetorno[1],"1","2")
         cMsg    := Iif(aRetorno[1],"OK",aRetorno[2])
      EndIf

      PCPCriaSOG(aRetorno[5], ;
                 cMaquina, ;
                 cNumOp, ;
                 cProduto, ;
                 nQtdSOG, ;
                 dDateIni, ;
                 cHoraIni, ;
                 dDateFim, ;
                 cHoraFim, ;
                 oXml, ;
                 cStatus, ;
                 Iif(lOnlyEstrn, "1", "2"), ;
                 cOperacao, ;
                 Iif(lReprocess,"Reprocessado. ","") + cMsg, ;
                 cMotivo, ;
                 cMovimento, ;
                 cPrdDestin, ;
                 cPrdOrigem, ;
                 cLocOrigem, ;
                 cLocDestin, ;
                 cIdMes)
      
      If !Empty(cIdMes)
         If cTransac $ "STOPREPORT|PRODUCTIONAPPOINTMENT" .And. !Empty(aRetorno[2])
            cMsg := aRetorno[2]
         ElseIf cTransac $ "MOVEMENTSINTERNAL" .And. !Empty(aRetorno[2])   
            // Cria a instância do Manager XML 
            oXmlRet := tXMLManager():New()
            // Faz o parser
            if oXmlRet:Parse(aRetorno[2]) 
               cMsg := oXmlRet:XPATHGETNODEVALUE('/ListOfInternalId/MovementsInternal/Destination')
            else
               cMsg := aRetorno[2]
            EndIf
         EndIf

         cMsg := Iif(lReprocess,"Reprocessado. ","")+cMsg
         PCPAtuSOH(cTransac, cIdMes, cMsg, cStatus)
      EndIf
   EndIf

   If lOnlyEstrn .And. cTransac $ "STOPREPORT|PRODUCTIONAPPOINTMENT"
      If !Empty(cIdMes)
         cMsg := Iif(lReprocess,"Reprocessado. ","") + Iif(aRetorno[1],"OK",aRetorno[2])
         cStatus := Iif(aRetorno[1],"1","2")
         PCPAtuSOH(cTransac, cIdMes, cMsg, cStatus)
      EndIf
   EndIf

   If !aRetorno[1]
      //Erro. Retorna mensagem.  
      cMsg := getReturn(.F.,aRetorno[2], cXml,"",cIdMes, cEmpIntg, cFilIntg) 
      ResReturn(cMsg,cSemaforo)  
      Return nil //getReturn(.F.,aRetorno[2], cXml,"",cIdMes, cEmpIntg, cFilIntg)

   EndIf
   
   If lErro
      cMsg := getReturn(.F.,aMsg[1], cXml,"",cIdMes, cEmpIntg, cFilIntg)
      ResReturn(cMsg,cSemaforo)  
   Else      
      cMsg := getReturn(.T.,Iif(Empty(aRetorno[2]),"OK",aRetorno[2]), cXml,"",cIdMes, cEmpIntg, cFilIntg)
      ResReturn(cMsg,cSemaforo)       
   EndIf

   RECOVER
   If !aRetorno[1]      
      cMsg := getReturn(.F.,aRetorno[2], cXml,"",cIdMes, cEmpIntg, cFilIntg)
      ResReturn(cMsg,cSemaforo)   

      If !Empty(cIdMes)
         PCPAtuSOH(cTransac, cIdMes, Iif(lReprocess,"Reprocessado. ","")+aRetorno[2], "2")
      EndIf
      PCPCriaSOG(cRotina, ;
                 cMaquina, ;
                 cNumOp, ;
                 cProduto, ;
                 nQtdSOG, ;
                 dDateIni, ;
                 cHoraIni, ;
                 dDateFim, ;
                 cHoraFim, ;
                 oXml, ;
                 "2", ;
                 Iif(lOnlyEstrn, "1", "2"), ;
                 cOperacao, ;
                 Iif(lReprocess,"Reprocessado. ","")+aRetorno[2], ;
                 cMotivo, ;
                 cMovimento, ;
                 cPrdDestin, ;
                 cPrdOrigem, ;
                 cLocOrigem, ;
                 cLocDestin, ;
                 cIdMes)
      Return cXmlRet
   EndIf
   If lErro     

      cMsg := getReturn(.F.,aRetorno[2], cXml,"",cIdMes, cEmpIntg, cFilIntg)
      ResReturn(cMsg,cSemaforo)   
      
      If !Empty(cIdMes)
         PCPAtuSOH(cTransac, cIdMes, Iif(lReprocess,"Reprocessado. ","")+aMsg[1], "2")
      EndIf
      PCPCriaSOG(cRotina, ;
                 cMaquina, ;
                 cNumOp, ;
                 cProduto, ;
                 nQtdSOG, ;
                 dDateIni, ;
                 cHoraIni, ;
                 dDateFim, ;
                 cHoraFim, ;
                 oXml, ;
                 "2", ;
                 Iif(lOnlyEstrn, "1", "2"), ;
                 cOperacao, ;
                 Iif(lReprocess,"Reprocessado. ","")+aMsg[1], ;
                 cMotivo, ;
                 cMovimento, ;
                 cPrdDestin, ;
                 cPrdOrigem, ;
                 cLocOrigem, ;
                 cLocDestin, ;
                 cIdMes)
   EndIf

   END SEQUENCE

Return nil

Function wspcpexecp(e)
   LogMsg('WSPCPRUN', 0, 0, 1, '', '', Replicate("-",70) + CHR(10) + AllTrim(e:description) + CHR(10) + AllTrim(e:ErrorStack) + CHR(10) + Replicate("-",70))
   lErro := .T.
   If Type('aMsg') == "A"
      aAdd(aMsg,e:description)
   EndIf
   If Type('aStack') == "A"
      aAdd(aStack,e:errorStack)
   EndIf
   disarmTransaction()
BREAK

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} parseXml

Realiza o parse do XML recebido, e o transforma em um objeto.

@param cXml    - String contendo o XML que será transformado em objeto.
@param oNewXml - Objeto que será criado. Deve-se passar este parâmetro por referência. (@oXml)

@return aRet[1] -> Identificador se foi possível ou não realizar o parse do xml.
        aRet[2] -> Mensagem de retorno

@author  Lucas Konrad França
@version P12
@since   22/09/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function parseXml(cXml, oNewXml)
   Local aRet := {.T.,""}
   Local cError   := ""
   Local cWarning := ""
   Local cPath    := CriaTrab(, .F.)
   Local nHandle  := 0

   cPath := "\"+AllTrim(cPath)+".xml"

   //Retira quebras de linha
   cXml := StrTran(cXml, CHAR(10), "")
   cXml := StrTran(cXml, CHAR(13), "")

   //Cria o arquivo XML físicamente para realizar a leitura através da função XmlParserFile.
   nHandle := FCreate(cPath)
   If nHandle > -1
      //Grava o conteúdo do xml recebido por parâmetro no arquivo criado.
      FWrite(nHandle,AllTrim(cXml))
      //Fecha o arquivo.
      FClose(nHandle)
      //Realiza a leitura do arquivo.
      oNewXml := XmlParserFile( cPath, "_", @cError, @cWarning )
      //Exclui o arquivo físico do sistema.
      FErase(cPath)
      If oNewXml == Nil .Or. !Empty(cError) .Or. !Empty(cWarning)
         aRet[2] := STR0003 + AllTrim(cError) + " | " + AllTrim(cWarning) //"Não foi possível interpretar o arquivo XML. " ERRO | WARNING
         aRet[1] := .F.
      EndIf
   Else
      aRet[2] := STR0004 //"Erro ao realizar a leitura do arquivo XML."
      aRet[1] := .F.
   EndIf
Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getReturn

Cria a mensagem de retorno para o PPI.

@param lStatus	- Identifica se o retorno é de erro (.F.) ou de execução OK (.T.).
@param cMsg	- Mensagem que será retornada.
@param cXmlOrg	- XML que foi recebido
@param cStatus	- Status do processamento, quando utilizado o ID-MES, para validar mensagens já processadas.
@param cIdMes	- Id de processamento do Totvs MES.
@param cEmpIntg - Empresa padrão que será considerada na mensagem de retorno, caso a variável cEmpAnt não exista.
@param cFilIntg - Filial padrão que será considerada na mensagem de retorno, caso a variável cEmpAnt não exista.

@author  Lucas Konrad França
@version P12
@since   22/09/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function getReturn(lStatus, cMsg, cXmlOrg, cStatus, cIdMes, cEmpIntg, cFilIntg)
   Local cXmlRet    := ""
   Local cSchemaLoc := ""
   Local cTransac   := ""
   Local cVersion   := "1.000"
   Local cStdVersio := "1.0"
   Local cUUID      := "1"
   Local cGenerated := ""
   Local cProdName  := ""
   Local cCode      := "1"
   Local cEmp       := ""
   Local cFil       := ""
   
   If Type("cEmpAnt") == "U" .Or. Type("cFilAnt") == "U"
      cEmp := cEmpIntg
      cFil := cFilIntg
   Else
      cEmp := cEmpAnt
      cFil := cFilAnt
   EndIf

   cGenerated := SubStr(DTOS(Date()), 1, 4) + '-' + SubStr(DTOS(Date()), 5, 2) + '-' + SubStr(DTOS(Date()), 7, 2) + 'T' + Time()

   If Type("oXml:_TotvsMessage:_MessageInformation:_Transaction:Text") != "U"
      cTransac := AllTrim(Upper(oXml:_TotvsMessage:_MessageInformation:_Transaction:Text))
      Do Case
         Case cTransac == "PRODUCTIONAPPOINTMENT"
            cSchemaLoc := "xmlschema/general/events/ProductionAppointment_1_001.xsd"
         Case cTransac == "STOPREPORT"
            cSchemaLoc := "xmlschema/general/events/StopReport_1_000.xsd"
         Case cTransac == "WASTEREASON"
            cSchemaLoc := "xmlschema/general/events/WasteReason_1_000.xsd"
         Case cTransac == "STOPREASON"
            cSchemaLoc := "xmlschema/general/events/StopReason_1_000.xsd"
         Case cTransac == "STOCKLEVEL"
            cSchemaLoc := "xmlschema/general/requests/StockLevel_2_000.xsd"
         Case cTransac == "MOVEMENTSINTERNAL"
            cSchemaLoc := "xmlschema/general/events/MovementsInternal_1_001.xsd"
         Case cTransac == "REFUSAL"
            cSchemaLoc := "xmlschema/general/events/Refusal_1_000.xsd"
      EndCase
   EndIf

   If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
      cVersion := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
   Else
      If Type("oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text)
         cStdVersio := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text, ".")[1]
      Endif
   EndIf
   
   If Empty(cIdMes)
      If Type("oXml:_TOTVSMessage:_MessageInformation:_UUID:Text") != "U"
         cUUID := oXml:_TOTVSMessage:_MessageInformation:_UUID:Text
      EndIf
	Else
	   cUUID := cIdMes
	EndIf

   If Type("oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U"
      cProdName := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
   EndIf

   /*
   	cCode - código da mensagem de retorno.
   	Se a mensagem já foi processada anteriormente (IDMES já existente na tabela SOH), deve seguir a seguinte regra:
   		Processou a mensagem, mas ocorreu erro durante o processamento: cCode deve ser igual a '2'.
   		Processou a mensagem corretamente: cCode deve ser igual a '3'.
   		Não finalizou o processamento da mensagem: cCode deve ser igual a '4'.
   	Se a mensagem não foi processada anteriormente, cCode deverá ser igual a '1'.
   	
   	A variável cStatus deve possuir o valor do campo OH_STATUS, quando a mensagem já foi processada. Caso contrário, deverá ser branca.
   */
   If !Empty(cStatus)
      If cStatus == "0" //Mensagem ainda está em processamento.
         cCode := "4"
      ElseIf cStatus == "1" //Mensagem processada com sucesso.
         cCode := "3"
      ElseIf cStatus == "2" //Mensagem processada com erro.
         cCode := "2"
      EndIf
   EndIf

   cXmlRet := '<?xml version="1.0" encoding="UTF-8"?>'
   cXmlRet += '<TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="'+cSchemaLoc+'">'
   cXmlRet +=    '<MessageInformation version="'+cVersion+'">'
   cXmlRet +=       '<UUID>'+cUUID+'</UUID>'
   cXmlRet +=       '<Type>Response</Type>'
   cXMlRet +=       '<Transaction>'+cTransac+'</Transaction>'
   cXmlRet +=       '<StandardVersion>'+cStdVersio+'</StandardVersion>'
   cXmlRet +=       '<SourceApplication>SIGAPCP</SourceApplication>'
   cXmlRet +=       '<CompanyId>'+cEmp+'</CompanyId>'
   cXmlRet +=       '<BranchId>'+cFil+'</BranchId>'
   cXmlRet +=       '<Product name="WSPCP" version="'+GetRPORelease()+'" />'
   cXmlRet +=       '<GeneratedOn>'+cGenerated+'</GeneratedOn>'
   cXmlRet +=       '<ContextName>PROTHEUS</ContextName>'
   cXmlRet +=    '</MessageInformation>'
   cXmlRet +=    '<ResponseMessage>'
   cXmlRet +=       '<ReceivedMessage>'
   cXmlRet +=          '<SentBy>'+cProdName+'</SentBy>'
   cXmlRet +=          '<UUID>'+cUUID+'</UUID>'
   cXmlRet +=       '</ReceivedMessage>'
   cXmlRet +=       '<ProcessingInformation>'
   cXmlRet +=          '<ProcessedOn>'+cGenerated+'</ProcessedOn>'
   cXmlRet +=          '<Status>'+Iif(lStatus,"OK","ERROR")+'</Status>'
   If !lStatus
      cXmlRet +=       '<ListOfMessages>'
      cXmlRet +=          '<Message type="ERROR" code="'+cCode+'">'+cMsg+'</Message>'
      cXmlRet +=       '</ListOfMessages>'
   EndIf
   cXmlRet +=       '</ProcessingInformation>'
   If lStatus .And. ;
      (cTransac == "PRODUCTIONAPPOINTMENT" .Or. cTransac == "STOPREPORT" .Or. cTransac == "REFUSAL") .And. ;
      Upper(AllTrim(cMsg)) != "OK"
      cXmlRet +=    '<ReturnContent>'
      cXmlRet +=       '<ListOfInternalId>'
      cXmlRet +=          '<InternalId>'
      cXmlRet +=             '<Name>'+cTransac+'INTERNALID</Name>'
      cXmlRet +=             '<Origin />'
      cXmlRet +=             '<Destination>'+cMsg+'</Destination>'
      cXmlRet +=          '</InternalId>'
      cXmlRet +=       '</ListOfInternalId>'
      cXmlRet +=    '</ReturnContent>'
   EndIf
   If lStatus .And. Upper(AllTrim(cMsg)) != "OK" .And. ;
      (cTransac == "MOVEMENTSINTERNAL" .Or. cTransac == "STOCKLEVEL")
      cXmlRet += '<ReturnContent>'
      cXmlRet += cMsg
      cXmlRet += '</ReturnContent>'
   EndIf
   cXmlRet +=    '</ResponseMessage>'
   cXmlRet += '</TOTVSMessage>'
Return EncodeUTF8(cXmlRet)

/*/{Protheus.doc} ResReturn
   Controle do retorno do xml.
   @type  Static Function
   @author mauricio.joao
   @since 29/07/2021
   @version 1.0
   @param cMsg, char, retorno da função getReturn()
   @param cSemaforo, char, identificador da thread.
/*/
Static Function ResReturn(cMsg,cSemaforo)

While !IpcGo(cSemaforo,cMsg)               
   sleep(500)
Enddo     

Return 

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} execInteg

Identifica qual é o adapter responsável pela mensagem recebida, e executa a integração.

@return aAdapter[1] -> Identificador se a mensagem foi executada com sucesso ou não.
        aAdapter[2] -> Mensagem de retorno
        aAdapter[3] -> Empresa aplicada o processo
        aAdapter[4] -> Filial aplicada o processo
        aAdapter[5] -> Programa Executado

@author  Lucas Konrad França
@version P12
@since   22/09/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function execInteg(cIntXML, cTransac)
   Local aAdapter := {.T.,"OK","","",""}
   Local lExisteOP := .F.
   
   If !Empty(cTransac)

      Do Case
         Case cTransac == "PRODUCTIONAPPOINTMENT" //Apontamento da produção
            cRotina  := "MATI681"
            If WSLock()
               aAdapter := MATI681(oXml, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS)
               WSUnlock()
            Else
               aAdd(aAdapter, .F.)
               aAdd(aAdapter, "Mensagem não processada. Tente novamente")
            EndIf

            aAdd(aAdapter, cEmpAnt)
            aAdd(aAdapter, cFilAnt)
            aAdd(aAdapter, "MATI681")
            
         Case cTransac == "STOPREPORT" //Apontamento de parada
            cRotina  := "MATI682"
            aAdapter := MATI682(oXml, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS)

            aAdd(aAdapter, cEmpAnt)
            aAdd(aAdapter, cFilAnt)
            aAdd(aAdapter, "MATI682")

         Case cTransac == "WASTEREASON" //Motivo de refugo
            cRotina  := "SFCI003"
            aAdapter := SFCI003(oXml, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS)

            aAdd(aAdapter, cEmpAnt)
            aAdd(aAdapter, cFilAnt)
            aAdd(aAdapter, "SFCI003")

        Case cTransac == "STOPREASON" //Motivo de parada
            cRotina  := "SFCI004"
            aAdapter := SFCI004(oXml, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS)

            aAdd(aAdapter, cEmpAnt)
            aAdd(aAdapter, cFilAnt)
            aAdd(aAdapter, "SFCI004")

         Case cTransac == "STOCKLEVEL" //Saldo de estoque
            cRotina  := "MATI225"
            aAdapter := MATI225(cIntXML, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS)

            If Len(aAdapter) > 2
               ADel(aAdapter,3)
               ASize( aAdapter, 2 )
            EndIf

            aAdd(aAdapter, cEmpAnt)
            aAdd(aAdapter, cFilAnt)
            aAdd(aAdapter, "MATI225")
            
         Case cTransac == "MOVEMENTSINTERNAL" // Movimentações internas
            If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text") != "U" .And. ;
               !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text)
               If AllTrim(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "E" //Entrada
                  lExisteOP := .F.
                  If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text") != "U" .And. ;
                     !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text)
                     lExisteOP := .T.
                  EndIf
                  If WSLock()
	                  cMovimento := "E"
	                  If lExisteOP
	                     cRotina  := "MATI250"
	                     aAdapter := MATI250(cIntXML, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS)
	                  Else
	                     cRotina  := "MATI240"
	                     aAdapter := MATI240(cIntXML, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS)
	                  EndIf
	                  WSUnlock()
	              Else
	                 aAdd(aAdapter, .F.)
            	     aAdd(aAdapter, "Mensagem não processada. Tente novamente")
	              EndIf
                  aAdd(aAdapter, cEmpAnt)
                  aAdd(aAdapter, cFilAnt)
                  aAdd(aAdapter, cRotina)
                  
               ElseIf AllTrim(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "S" //Saída
                  cMovimento := "S"
                  cRotina  := "MATI240"
                  If WSLock()
	                 aAdapter := MATI240(cIntXML, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS)
	                 WSUnlock()
	              Else
	                 aAdd(aAdapter, .F.)
            	     aAdd(aAdapter, "Mensagem não processada. Tente novamente")
	              EndIf
                  aAdd(aAdapter, cEmpAnt)
                  aAdd(aAdapter, cFilAnt)
                  aAdd(aAdapter, "MATI240")
                  
               Else
                  aAdapter[1] := .F.
                  aAdapter[2] := STR0011 //"InputOrOutput não é válido. Valores válidos: 'E'=Entrada, 'S'=Saída."
                  aAdapter[3] := cEmpAnt
                  aAdapter[4] := cFilAnt
                  aAdapter[5] := ""
               EndIf
            Else
               aAdapter[1] := .F.
               aAdapter[2] := STR0012 //"Obrigatório informar o InputOrOutput."
               aAdapter[3] := cEmpAnt
               aAdapter[4] := cFilAnt
               aAdapter[5] := ""
            EndIf
         Case cTransac == "TRANSFERWAREHOUSE" // Transferências de estoque
            cRotina  := "MATI261"
            If WSLock()
	            aAdapter := MATI261(cIntXML, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS)
               If Len(aAdapter) > 2
                  aSize(aAdapter,2)
               EndIf
	           WSUnlock()
	        Else
	           aAdd(aAdapter, .F.)
               aAdd(aAdapter, "Mensagem não processada. Tente novamente")
	        EndIf
            aAdd(aAdapter, cEmpAnt)
            aAdd(aAdapter, cFilAnt)
            aAdd(aAdapter, "MATI261")
            
         Case cTransac == "REFUSAL" //Recusas de produção
            cRotina  := "MATI685"
            If WSLock()
               aAdapter := MATI685(oXml, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS)
               WSUnlock()
            Else
               aAdd(aAdapter, .F.)
               aAdd(aAdapter, "Mensagem não processada. Tente novamente")
            EndIf
            aAdd(aAdapter, cEmpAnt)
            aAdd(aAdapter, cFilAnt)
            aAdd(aAdapter, "MATI685")
            
         Otherwise
            aAdapter[1] := .F.
            aAdapter[2] := STR0005 + cTransac + STR0006 //'Transação "' XXX '" não implementada.'
            aAdapter[3] := cEmpAnt
            aAdapter[4] := cFilAnt
            aAdapter[5] := ""
      EndCase

   Else
      aAdapter[1] := .F.
      aAdapter[2] := STR0007 //'Não foi possível identificar a transação da mensagem.'
      aAdapter[3] := cEmpAnt
      aAdapter[4] := cFilAnt
      aAdapter[5] := ""
   EndIf
   
   //Retira tabulação e quebras de linha.
   aAdapter[2] := StrTran(aAdapter[2], CHR(10), " " )
   aAdapter[2] := StrTran(aAdapter[2], CHR(13), " " )
   aAdapter[2] := StrTran(aAdapter[2], CHR(9), " " )
   aAdapter[2] := AllTrim(aAdapter[2])
   
Return aAdapter

Static Function changeEmp(cEmp,cFil)
   Static cUser
   Local cUserAtu := Iif(Type('cUser') != "U",Iif(cUser == NIL,RetCodUsr(),cUser),'')
   
   If Type('cEmpAnt') != 'C' .Or. ;
      Type('cFilAnt') != 'C' .Or. ;
      Upper(AllTrim(cEmp)) != Upper(AllTrim(cEmpAnt)) .Or. ;
      Upper(AllTrim(cFil)) != Upper(AllTrim(cFilAnt))
      //Troca a empresa
      If Type('cEmpAnt') == 'C' .And. ;
         Upper(AllTrim(cEmp)) == Upper(AllTrim(cEmpAnt))
         //Troca somente a filial
         cFilAnt := AllTrim(Upper(cFil))
      Else
         //Troca o grupo de empresas
         DBCloseAll()

         RpcClearEnv()
         RpcSetType(3)
         RpcSetEnv(cEmp, cFil,,,'PCP')
         cUser       := cUserAtu
         __cUserId   := cUserAtu
      EndIf
   EndIf
   SetModulo("SIGAPCP","PCP")
   SetFunName("WSPCP")
Return

Static Function WSLock()
	Local nTry := 0

   //Se Consumo Real, não executa WSLock
   SOE->(dbSeek(xFilial("SOE")+"SC2"))
   If AllTrim(SOE->OE_VAR1) == "2" .Or. AllTrim(SOE->OE_VAR1) == "3"
      lLockWS := .F.
      Return .T.
   EndIf

	While !LockByName("WSPCP"+cEmpAnt+cFilAnt,.T.,.T.)
		nTry++
		If nTry > 10000
			Return .F.
		EndIf
		Sleep(500)
	End
Return .T.

Static Function WSUnlock()
	IF lLockWS
      UnLockByName("WSPCP"+cEmpAnt+cFilAnt,.T.,.T.)
   EndIf
Return
