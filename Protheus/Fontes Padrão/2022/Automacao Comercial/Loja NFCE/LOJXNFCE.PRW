#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJXNFCE()
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} LOJXNFCE
Classe responsavel pela comunicação do Protheus com o TSS para NFC-e

@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
/*/
//----------------------------------------------------------------------

Class LOJXNFCE

    Data oWSSPEDADM
    Data oWSNFESBRA
    Data oWSSPEDCfgNFe
    Data aMensagem
    Data lError

    Method New() CONSTRUCTOR                //Metodo Construtor
    Method LojXNfceStart()                  //Metodo Que inicia o objeto do WS WSSPEDADM e WSNFESBRA

    /* Metodos internos da Clasee */
    Method LjWSSPEDADMIniciar()             //Iniciar WSSPEDADM
    Method LjWSNFESBRAIniciar()             //Iniciar WSNFESBRA
    Method LjWSSPEDCfgNFeIniciar()          //Iniciar WSSPEDCfgNFe
    Method LjaMensagemError(cMetodo)        //Metodo de mensagens internas da Classe
    Method LjGetAdmEmpresas()               //Metodo GetAdmEmpresas. Retorna os dados da empresa no TSS
    Method LjAdmEmpresas()                  //Metodo AdmEmpresas. Retorna a entidade da empresa selecionada
    /* Metodos internos da Classe*/

    Method LjCancelaEvento(cId,cMotivo)         //Metodo CancelaEvento. Cancelamento Sincrono de NFCE
    Method LjMonitorFaixa(cIdIni,cIdFin)        //Metodo MonitorFaixa. Monitora notas no TSS 
    Method LjGetDadosNfeId(cId)                 //Metodo GetDadosNfeId. Retorna os dados da Nota.
    Method LjConsultaChaveNFe(cChave)           //Metodo ConsultaChaveNFe . Consulta notas na SEFAZ 
    Method LjConsProtocoloNFe(cID)              //Metodo ConsultaProtocoloNFe . Consulta notas na SEFAZ e Atualiza statua da nota nas tabelas do TSS
    Method LjCancelaNotas(cId,cXml)             //Metodo CancelaNotas.  Cancela/Inutiliza notas.
	Method LjGetAlIMVTSS(nTypeSeek,aEntidades)  //Metodo GetAlIMVTSS. Retorna os parametros da tabela SPED000
    Method LjGetCert(cIdEnt)					//Metodo CFGStatusCertificate. Realiza a consulta do certificado no TSS
    Method LjRetornaNotas(cId)

EndClass

//----------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe LOJXNFCE

@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
/*/
//----------------------------------------------------------------------

Method New() Class LOJXNFCE
    Self:lError     := .F.
    Self:aMensagem  := {.T.,"","","",""}
Return Self

//----------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo de Inicio para a classe, deverá sempre ser execuado antes de executar qual quer metodo (exeto medoto NEW())

@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
/*/
//----------------------------------------------------------------------

Method LojXNfceStart() Class LOJXNFCE
    Local lRet := .F.

    If lRet := Self:LjWSSPEDADMIniciar()            //Iniciar SpedADM
        If lRet := Self:LjAdmEmpresas()             //Busca dados referente a empresa no TSS
            lRet := Self:LjWSNFESBRAIniciar()       //Iniciar NFEBRA
        Endif
    Endif

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LjWSSPEDADMIniciar
Metodo responsavel por iniciar WSSPEDADM

@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
@return  Lógico, Indica se conseguiu iniciar WSSPEDADM
/*/
//----------------------------------------------------------------------

Method LjWSSPEDADMIniciar() Class LOJXNFCE

    Local cURL                  := PadR(GetNewPar("MV_NFCEURL","http://"),250)      //URL de comunicação com o TSS   			
    
    If Empty(cURL)
        cURL                  := PadR(GetNewPar("MV_SPEDURL","http://"),250) 
    EndIf 

    Self:oWSSPEDADM             := WSSPEDADM():New()                                

    Self:oWSSPEDADM:_URL        := AllTrim(cURL)+"/SPEDADM.apw"
    Self:oWSSPEDADM:cUSERTOKEN	:= "TOTVS" 


Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} LjWSNFESBRAIniciar
Metodo responsavel por iniciar WSNFESBRA

@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
@return  Lógico, Indica se conseguiu iniciar WSNFESBRA
/*/
//----------------------------------------------------------------------

Method LjWSNFESBRAIniciar() Class LOJXNFCE

    Local cURL                  := PadR(GetNewPar("MV_NFCEURL","http://"),250)   //URL de comunicação com o TSS   
    
    If Empty(cURL)
        cURL                  := PadR(GetNewPar("MV_SPEDURL","http://"),250) 
    EndIf 

    Self:oWSNFESBRA             := WSNFESBRA():new()                                
    Self:oWSNFESBRA:_URL        := AllTrim(cURL)+"/NFESBRA.apw"
    Self:oWSNFESBRA:cUSERTOKEN	:= "TOTVS"
    Self:oWSNFESBRA:cID_ENT		:= Self:oWSSPEDADM:cADMEMPRESASRESULT    

Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} LjWSNFESBRAIniciar
Metodo responsavel por iniciar WSNFESBRA

@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
@return  Lógico, Indica se conseguiu iniciar WSNFESBRA
/*/
//----------------------------------------------------------------------

Method LjWSSPEDCfgNFeIniciar() Class LOJXNFCE

    Local cURL                      := PadR(GetNewPar("MV_NFCEURL","http://"),250)   //URL de comunicação com o TSS

    Self:oWSSPEDCfgNFe              := WSSPEDCfgNFe():New()
    Self:oWSSPEDCfgNFe:_URL         := AllTrim(cURL)+"/SPEDCFGNFe.apw"
    Self:oWSSPEDCfgNFe:cUSERTOKEN	:= "TOTVS"

Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} LjGetAdmEmpresas
Metodo responsavel por buscar os dados da empresa no TSS
Metodo TSS:GETADMEMPRESAS

@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
@return  Lógico, Indica se conseguiu executar o metodo GETADMEMPRESAS
/*/
//----------------------------------------------------------------------

Method LjGetAdmEmpresas() Class LOJXNFCE
    
    Local lRetWS := .F.      //Variavel para controle de retorno do metodo  

    Self:oWSSPEDADM:cCNPJ    :=  IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
    Self:oWSSPEDADM:cCPF     :=  IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
    Self:oWSSPEDADM:cIE      :=  SM0->M0_INSC
    Self:oWSSPEDADM:cUF      :=  SM0->M0_ESTENT

    //Tratar retorno
    lRetWS :=  Self:oWSSPEDADM:GETADMEMPRESAS()

    If ValType(lRetWS) == "U"
        lRetWS := .F.
    EndIf

    If lRetWS
        Self:aMensagem  := {lRetWS,"LjGetAdmEmpresas","LjGetAdmEmpresas executado com sucesso.","",""}
    Else
        Self:LjaMensagemError("LjGetAdmEmpresas")
    EndIf

Return lRetWS

//----------------------------------------------------------------------
/*/{Protheus.doc} LjAdmEmpresas
Metodo responsavel por buscar a entidade da empresa solicitada.
Metodo TSS:ADMEMPRESAS

@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
@return  Lógico, Indica se conseguiu executar o metodo ADMEMPRESAS
/*/
//----------------------------------------------------------------------

Method LjAdmEmpresas() Class LOJXNFCE
    Local lRetWS := .F.     //Variavel para controle de retorno do metodo

    //Busca os dados da empresa
    lRetWS := Self:LjGetAdmEmpresas()
    
    If lRetWS
        Self:oWSSPEDADM:oWSEMPRESA:cCNPJ        := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cCNPJ
        Self:oWSSPEDADM:oWSEMPRESA:cCPF         := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cCPF
        Self:oWSSPEDADM:oWSEMPRESA:cIE          := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cIE
        Self:oWSSPEDADM:oWSEMPRESA:cIM          := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:CIM
        Self:oWSSPEDADM:oWSEMPRESA:cNOME        := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cNOME
        Self:oWSSPEDADM:oWSEMPRESA:cFANTASIA    := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cFANTASIA
        Self:oWSSPEDADM:oWSEMPRESA:cENDERECO    := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cENDERECO
        Self:oWSSPEDADM:oWSEMPRESA:cNUM         := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cNUM
        Self:oWSSPEDADM:oWSEMPRESA:cCOMPL       := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cCOMPL
        Self:oWSSPEDADM:oWSEMPRESA:cUF          := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cUF
        Self:oWSSPEDADM:oWSEMPRESA:cCEP         := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cCEP
        Self:oWSSPEDADM:oWSEMPRESA:cCOD_MUN     := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cCOD_MUN
        Self:oWSSPEDADM:oWSEMPRESA:cCOD_PAIS    := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cCOD_PAIS
        Self:oWSSPEDADM:oWSEMPRESA:cBAIRRO      := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cBAIRRO
        Self:oWSSPEDADM:oWSEMPRESA:cMUN         := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cMUN
        Self:oWSSPEDADM:oWSEMPRESA:cCEP_CP      := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cCEP_CP
        Self:oWSSPEDADM:oWSEMPRESA:cCP          := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cCP
        Self:oWSSPEDADM:oWSEMPRESA:cDDD         := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cDDD
        Self:oWSSPEDADM:oWSEMPRESA:cFONE        := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cFONE
        Self:oWSSPEDADM:oWSEMPRESA:cFAX         := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cFAX
        Self:oWSSPEDADM:oWSEMPRESA:cEMAIL       := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cEMAIL
        Self:oWSSPEDADM:oWSEMPRESA:cNIRE        := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cNIRE
        Self:oWSSPEDADM:oWSEMPRESA:dDTRE        := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:dDTRE
        Self:oWSSPEDADM:oWSEMPRESA:cNIT         := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cNIT
        Self:oWSSPEDADM:oWSEMPRESA:cINDSITESP   := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cINDSITESP
        Self:oWSSPEDADM:oWSEMPRESA:cID_MATRIZ   := Self:OWSSPEDADM:OWSGETADMEMPRESASRESULT:OWSSPED_ENTIDADE[1]:cID_MATRIZ

        lRetWS := Self:oWSSPEDADM:ADMEMPRESAS()

        If ValType(lRetWS) == "U"
            lRetWS := .F.
        EndIf
        
        If lRetWS
            Self:aMensagem  := {lRetWS,"LjAdmEmpresas","LjAdmEmpresas executado com sucesso","",""}
        Else
            Self:LjaMensagemError("LjAdmEmpresas")
        EndIf

    EndIf 

Return lRetWS

//----------------------------------------------------------------------
/*/{Protheus.doc} LjCancelaEvento
Metodo responsavel por buscar realizar o cancelamento sincrono
Metodo TSS:CANCELAEVENTO

@param   cId	    Numero do Id da nota no TSS (Serie + Documento)
@param   cMotivo    Motivo do cancelamento
@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
@return  Lógico, Indica se conseguiu executar o metodo CANCELAEVENTO
/*/
//----------------------------------------------------------------------

Method LjCancelaEvento(cId, cMotivo, cXML) Class LOJXNFCE

Local lRetWS        := .F.                          //Variavel para controle de retorno do metodo

Default cMotivo     := "Cancelamento de NFC-e."     //Motivo padrão de cancelamento
Default cXML        := ""

Self:oWSNFESBRA:CDOC_ID     := cId
Self:oWSNFESBRA:CMOTIVO     := cMotivo
Self:oWSNFESBRA:cXML_LOTE   := cXML

lRetWS := Self:oWSNFESBRA:CANCELAEVENTO()

If ValType(lRetWS) == "U"
    lRetWS := .F.
EndIf

If lRetWS
    Self:aMensagem  := {lRetWS,"LjCancelaEvento","LjCancelaEvento executado com sucesso.","",""}
Else
    Self:LjaMensagemError("LjCancelaEvento")
EndIf

Return lRetWS

//----------------------------------------------------------------------
/*/{Protheus.doc} LjaMensagemError
Metodo responsavel informar ao ERP sobre erro na comunicação/ execução do WebService atravez da propriedade aMensagem

@param   cMetodo	    Metodo que originou o Erro
@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
/*/
//----------------------------------------------------------------------

Method LjaMensagemError(cMetodo) Class LOJXNFCE

    Local lRetWS := .F.                 //Variavel para controle de retorno do metodo
    Local cSvcError   := GetWSCError()  //Resumo do erro
    Local cSoapFCode  := GetWSCError(2) //Soap Fault Code
    Local cSoapFDescr := GetWSCError(3) //Soap Fault Description

    Self:lError := .T.

    If !Empty(cSoapFCode)
        // Caso a ocorrência de erro esteja com o fault_code preenchido ,
        // a mesma teve relação com a chamada do serviço .
        Self:aMensagem  := {lRetWS,cMetodo,"Falha na execução do metodo " + cMetodo + ". Retorno: Codigo: " + cSoapFCode + " Descrição: " + cSoapFDescr,cSoapFCode,cSoapFDescr} //{Metodo,Retorno,Descrição,Codigo do erro WS , Descrição do ERRO WS}
    Else
        // Caso a ocorrência não tenha o soap_code preenchido
        // Ela está relacionada a uma outra falha ,
        // provavelmente local ou interna.
        Self:aMensagem  := {lRetWS,cMetodo,"Falha na execução do metodo " + cMetodo + ", Falha interna de execução do serviço. Error: " + cSvcError,"",cSvcError} //{Metodo,Retorno,Descrição,Codigo do erro WS , Descrição do ERRO WS}
    Endif

Return 

//----------------------------------------------------------------------
/*/{Protheus.doc} LjMonitorFaixa
Faz a consulta/monitoramento do documento no TSS e atualiza o STATUS do documento nas tabelas do TSS.
Metodo TSS:CANCELAEVENTO

@param   cIdIni	    Numero Inicial do Id da nota no TSS (Serie + Documento)
@param   cIdFin	    Numero Final do Id da nota no TSS (Serie + Documento)
@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
@return  Lógico, Indica se conseguiu executar o metodo MonitorFaixa      
/*/
//----------------------------------------------------------------------

Method LjMonitorFaixa(cIdIni,cIdFin) Class LOJXNFCE
    Local cMetodo  := "LjMonitorFaixa"  //Metodo que esta sendo executado
    Local lRetWS :=  .F.                //Variavel para controle de retorno do metodo

    DEFAULT cIdFin := cIdIni

    Self:oWSNFESBRA:cIdInicial 	:= cIdIni
    Self:oWSNFESBRA:cIdFinal 	:= cIdFin
    Self:oWSNFESBRA:cModelo 	:= "65"

    lRetWS := Self:oWSNFESBRA:MonitorFaixa()

    If ValType(lRetWS) == "U"
        lRetWS := .F.
    EndIf

    If lRetWS
        Self:aMensagem  := {lRetWS,cMetodo,cMetodo + " executado com sucesso.","",""}
    Else
        Self:LjaMensagemError(cMetodo)
    EndIf

Return lRetWS

//----------------------------------------------------------------------
/*/{Protheus.doc} LjGetDadosNfeId
Faz a consultano TSS e atualiza o STATUS do documento nas tabelas do TSS.
Metodo TSS:GETDADOSNFEID

@param   cId	    Numero  do Id da nota no TSS (Serie + Documento)
@author  Lucas Novais (lnovais)
@since   25/02/2019
@version P12
@return  Lógico, Indica se conseguiu executar o metodo LjGetDadosNfeId      
/*/
//----------------------------------------------------------------------

Method LjGetDadosNfeId(cId) Class LOJXNFCE
    Local lRetWS    := .F.                  //Variavel para controle de retorno do metodo
    Local cMetodo   := "LjGetDadosNfeId"    //Metodo que esta sendo executado

    Self:oWSNFESBRA:oWSNFEIDENTRADA:CID			:= cId
    Self:oWSNFESBRA:oWSNFEIDENTRADA:CMODELO 	:= "NFE"	
    Self:oWSNFESBRA:oWSNFEIDENTRADA:CSEPARATOR	:= ";"		
    Self:oWSNFESBRA:oWSNFEIDENTRADA:NTYPESEP 	:= 2

    lRetWS := Self:oWSNFESBRA:GETDADOSNFEID()

    If ValType(lRetWS) == "U"
        lRetWS := .F.
    EndIf

    If lRetWS
        Self:aMensagem  := {lRetWS,cMetodo,cMetodo + " executado com sucesso.","",""}
    Else
        Self:LjaMensagemError(cMetodo)
    EndIf

Return lRetWS


//----------------------------------------------------------------------
/*/{Protheus.doc} LjConsultaChaveNFe
Consulta a situação atual da NF-e na base de dados da SEFAZ de origem
Metodo TSS:ConsultaChaveNFe

@param   cChave	    Numero  da chave
@author  Lucas Novais (lnovais)
@since   18/06/2019
@version P12
@return  Lógico, Indica se conseguiu executar o metodo LjConsultaChaveNFe      
/*/
//----------------------------------------------------------------------
Method LjConsultaChaveNFe(cChave) Class LOJXNFCE
    Local lRetWS    := .F.                  //Variavel para controle de retorno do metodo
    Local cMetodo   := "ConsultaChaveNFe"    //Metodo que esta sendo executado

    Self:oWSNFESBRA:CCHVNFE :=  cChave 

    lRetWS := Self:oWSNFESBRA:ConsultaChaveNFe()

    If ValType(lRetWS) == "U"
        lRetWS := .F.
    EndIf

    If lRetWS
        Self:aMensagem  := {lRetWS,cMetodo,cMetodo + " executado com sucesso.","",""}
    Else
        Self:LjaMensagemError(cMetodo)
    EndIf

Return lRetWS

//----------------------------------------------------------------------
/*/{Protheus.doc} LjCancelaNotas
Realiza o cancelamento/inutilização de uma determinada nota.
Metodo ASSINCRONO
Metodo TSS:CancelaNotas

@param   cId	    Numero  do Id da nota no TSS (Serie + Documento)
@author  Lucas Novais (lnovais)
@since   12/06/2019
@version P12
@return  Lógico, Indica se conseguiu executar o metodo LjCancelaNotas
/*/
//----------------------------------------------------------------------

Method LjCancelaNotas(cId,cXml) Class LOJXNFCE
    Local lRetWS    := .F.                  // -- Variavel para controle de retorno do metodo
    Local cMetodo   := "LjCancelaNotas"     // -- Metodo que esta sendo executado

    Default cId     := ""                   // -- [Obrigatorio] -- Id composto Serie(Ate 3) + Documento(Ate 9)
    Default cXML    := ""                   // -- [Obrigatorio] -- XML com dados para cancelamento

    Self:oWSNFESBRA:oWsNFe:oWsNotas	:= NFESBRA_ARRAYOFNFES():New()

    //alimenta o atributo oWsNFe:oWsNotas:oWSNFES com uma instancia do NFESBRA_NFES
    Aadd( Self:oWSNFESBRA:oWsNFe:oWsNotas:oWSNFES, NFESBRA_NFES():New() )

    //alimenta o atributo cID
    Atail(Self:oWSNFESBRA:oWsNFe:oWsNotas:oWSNFES):cID := cId

    //alimenta o atributo XML
    Atail(Self:oWSNFESBRA:oWsNFe:oWsNotas:oWSNFES):cXML := cXML 

    lRetWS := Self:oWSNFESBRA:CancelaNotas()

    If ValType(lRetWS) == "U"
        lRetWS := .F.
    EndIf

    If lRetWS
        Self:aMensagem  := {lRetWS,cMetodo,cMetodo + " executado com sucesso.","",""}
    Else
        Self:LjaMensagemError(cMetodo)
    EndIf

Return lRetWS

//----------------------------------------------------------------------
/*/{Protheus.doc} LjGetAlIMVTSS
Realiza o cancelamento/inutilização de uma determinada nota.
Metodo SINCRONO
Metodo TSS:GetAlIMVTSS

@param   aEntidades     Array contendo as entidades que serão pesquisadas.     
@param   nTypeSeek	    Tipo da Busca, 1 - Range (Ex.: 00001;00002. Id "de" "até"), 2 - Parser (Ex.: 00001;00002;00003. Explicito os Ids) ou 3 - Single (Ex.: 00001. Apenas um Id)
@author  Lucas Novais (lnovais)
@since   12/06/2019
@version P12
@return  Lógico, Indica se conseguiu executar o metodo LjCancelaNotas
/*/
//----------------------------------------------------------------------

Method LjGetAlIMVTSS(aEntidades,nTypeSeek) Class LOJXNFCE
    Local lRetWS        := .F.                      // -- Variavel para controle de retorno do metodo
    Local cMetodo       := "LjGetAlIMVTSS"          // -- Metodo que esta sendo executado
    Local nI            := 0                        // -- Sequencial para For
    Local nLenEntidade  := 0                        // -- Tamanho do array aEntidades
    Local cEntidades    := Self:oWSNFESBRA:cID_ENT  // -- Por padrão é armazena com entidade atual

    Default nTypeSeek   := 3                        // -- Por padrão busco apenas a entidade atual
    Default aEntidades  := {}                       // -- Array contendo as entidades que serão pesquisadas.

    // -- Iniciar WS SPEDCfgNFe
    Self:LjWSSPEDCfgNFeIniciar()

    nLenEntidade := Len(aEntidades)

    If nTypeSeek <> 3 .And. nLenEntidade > 0

        cEntidades := ""

        For nI := 1 To nLenEntidade
            If nI == nLenEntidade
                cEntidades += aEntidades[ni]
            Else
                cEntidades += aEntidades[ni] + ";"
            EndIf
        Next nI
    EndIf

    Self:oWSSPEDCfgNFe:oWSENTSGETALLMV:cID		    := cEntidades
    Self:oWSSPEDCfgNFe:oWSENTSGETALLMV:cSEPARATOR   := ";"
    Self:oWSSPEDCfgNFe:oWSENTSGETALLMV:nTYPESEP     := nTypeSeek

    lRetWS := Self:oWSSPEDCfgNFe:GetAllMVTSS()


    If ValType(lRetWS) == "U"
        lRetWS := .F.
    EndIf

    If lRetWS
        Self:aMensagem  := {lRetWS,cMetodo,cMetodo + " executado com sucesso.","",""}
    Else
        Self:LjaMensagemError(cMetodo)
    EndIf

Return lRetWS

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGetCert
Realiza a consulta do certificado no TSS

@param      cIdEnt - Código da Entidade
@author     eduardo.sales
@since      30/07/2019
@version    P12
@return     lRetWS - Indica se conseguiu executar o metodo CFGSTATUSCERTIFICATE
/*/
//-------------------------------------------------------------------
Method LjGetCert(cIdEnt) Class LOJXNFCE

Local lRetWS    := .F.

Self:LjWSSPEDCfgNFeIniciar()
Self:oWSSPEDCfgNFe:cID_ENT := cIdEnt

lRetWS := Self:oWSSPEDCfgNFe:CFGSTATUSCERTIFICATE()

If ValType(lRetWS) == "U"
    lRetWS := .F.
EndIf

If lRetWS
    Self:aMensagem := {lRetWS,"LjGetCert","LjGetCert executado com sucesso.","",""}
Else
    Self:LjaMensagemError("LjGetCert")
EndIf

Return lRetWS

//----------------------------------------------------------------------
/*/{Protheus.doc} LjConsProtocoloNFe
Consulta a situação atual da NF-e na base de dados da SEFAZ de origem
Metodo TSS:ConsultaProtocoloNfe

@author  Alberto Deviciente
@since   08/06/2022
@version P12

@param   cID, Caractere, Número do ID da nota no TSS (Serie + Documento)

@return  Lógico, Indica se conseguiu executar o metodo ConsultaProtocoloNfe      
/*/
//----------------------------------------------------------------------
Method LjConsProtocoloNFe(cID) Class LOJXNFCE
    Local lRetWS    := .F.                      //Variavel para controle de retorno do metodo
    Local cMetodo   := "ConsultaProtocoloNfe"   //Metodo do TSS que esta sendo executado

    Self:oWSNFESBRA:cNFECONSULTAPROTOCOLOID := cID

    lRetWS := Self:oWSNFESBRA:ConsultaProtocoloNfe()

    lRetWS := IIf( ValType(lRetWS)=="U", .F., lRetWS )

    If lRetWS
        Self:aMensagem  := {lRetWS,cMetodo,cMetodo + " executado com sucesso.","",""}
    Else
        Self:LjaMensagemError(cMetodo)
    EndIf

Return lRetWS
//----------------------------------------------------------------------
/*/{Protheus.doc} LjRetornaNotas
Consulta a situação atual da NF-e na base de dados da SEFAZ de origem
Metodo TSS:ConsultaProtocoloNfe

@author  Alberto Deviciente
@since   08/06/2022
@version P12

@param   cID, Caractere, Número do ID da nota no TSS (Serie + Documento)

@return  Lógico, Indica se conseguiu executar o metodo ConsultaProtocoloNfe      
/*/
//----------------------------------------------------------------------
Method LjRetornaNotas(cID) Class LOJXNFCE

    Local lRetWS    := .F.              //Variavel para controle de retorno do metodo
    Local cMetodo   := "RetornaNotasNx" //Metodo do TSS que esta sendo executado

    Self:oWSNFESBRA:oWSNFEID          := NFESBRA_NFES2():New()
    Self:oWSNFESBRA:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
    aadd(Self:oWSNFESBRA:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
    
    Atail(Self:oWSNFESBRA:oWSNFEID:oWSNotas:oWSNFESID2):cID := cID
    Self:oWSNFESBRA:nDIASPARAEXCLUSAO := 0

    lRetWS := Self:oWSNFESBRA:RetornaNotasNx()

    lRetWS := IIf( ValType(lRetWS)=="U", .F., lRetWS )

    
    If lRetWS
        Self:aMensagem  := {lRetWS,cMetodo,cMetodo + " executado com sucesso.","",""}
    Else
        Self:LjaMensagemError(cMetodo)
    EndIf


Return lRetWS
