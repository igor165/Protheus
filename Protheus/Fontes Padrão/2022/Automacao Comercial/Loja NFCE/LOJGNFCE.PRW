#INCLUDE "TOTVS.CH"
//----------------------------------------------------------------------
/*/{Protheus.doc} LOJGNFCE
Classe responsavel pela comunicação do Protheus com a Classe de comunicação com TSS LOJXNFCE
Classe destinada a metodos genericos.

@author  Lucas Novais (lnovais)
@since   09/04/2019
@version P12
/*/
//----------------------------------------------------------------------

Class LOJGNFCE

Data aResultTSS                                         // -- Array {Logico,Metodo executado,Mensagem de retorno,Codigo de Erro(Caso exista),Descrição do Erro}
Data aResultMetodo                                      // -- Array {Logico,Descrição}
Data aResultConsultaChaveNFCE                           // -- Array {Logico,Codigo de retorno,Descrição do retorno}
Data aResultConsultaProtocoloNFCE                       // -- Array {Logico,Codigo de retorno,Descrição do retorno}
Data aResultRetornaNotasNx                              // -- Array {Logico,XML,Protoco,Data da Nota}
Data aParamTSS                                          // -- Amazena backup dos parametro retornados pelo metodo
Data aFirstEntity                                       // -- Armazena as entidades salvas na propiedade (array) aParamTSS
Data nLimitTent                                         // -- Limite de interações para cancelamento

Method New()    CONSTRUCTOR                             // -- Metodo Construtor
Method LjConsultaChaveNFCE(cChave)                      // -- Metodo que consulta a Chave da NFC-E
Method LjConsProtocoloNFCe(cID)                         // -- Metodo que consulta o Protocolo da NFC-E
Method LjMensagem(cResult,aMensagem)                    // -- Metodo de mensagens internas da Classe
Method LjGetMVTSS(cParametro,aEntidades,nTypeSeek)      // -- Methodo que Retorna parametros do TSS
Method LjGetCodIBGE(cUF,cCodMun)                        // -- Metodo que retorna o codigo do IBGE
Method LjClearInteractSLX(cPdv,cDoc,cSerie)             // -- Limpa interações na tabela SLX
Method LjAddInteractSLX(cPdv,cDoc,cSerie)               // -- Adiciona interações na tabela SLX
Method LjCheckInteractSLX(cPdv,cDoc,cSerie,cL1Situa)    // -- Verifica se é possivel seguir com o cancelamento
Method LjChkCert(cIdEnt)
Method LjRetornaNotas(cIdEnt)

EndClass


//----------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe LOJGNFCE

@author  Lucas Novais (lnovais)
@since   09/04/2019
@version P12

/*/
//----------------------------------------------------------------------

Method New() Class LOJGNFCE

Self:aResultTSS                     := {.F.,"","","","",""}    //Array {Logico,Metodo executado,Mensagem de retorno,Codigo de Erro(Caso exista),Descrição do Erro}
Self:aResultConsultaChaveNFCE       := {.F.,"",""}          //Array {Logico,Codigo de retorno,Descrição do retorno}
Self:aResultConsultaProtocoloNFCE   := {.F.,"",""}          //Array {Logico,Codigo de retorno,Descrição do retorno}
Self:aResultRetornaNotasNx          := {.F.,"","","","",""}      //Array {Logico,XML,Protoco,Data da Nota}
Self:aResultMetodo                  := {.F.,""}             //Array {Logico,Descrição}
Self:nLimitTent                     := 5    

Return Self

//----------------------------------------------------------------------
/*/{Protheus.doc} LjConsultaChaveNFCE
Metodo responsavel Por consultar chave e retornar o situação da NFC-e

@param   cChave - Chave da NFC-e que será consultada.
@author  Lucas Novais (lnovais)
@since   09/04/2019
@version P12

/*/
//----------------------------------------------------------------------

Method LjConsultaChaveNFCE(cChave) Class LOJGNFCE
Local oLOJXNFCE := LOJXNFCE():NEW()
Local cRetOk    := "100"  
Local cCodRet   := ""
Local cDescRet  := ""

If oLOJXNFCE:LojXNfceStart()
    If oLOJXNFCE:LjConsultaChaveNFe(cChave)
        
        cCodRet     := oLOJXNFCE:oWSNFESBRA:OWSCONSULTACHAVENFERESULT:CCODRETNFE
        cDescRet    := oLOJXNFCE:oWSNFESBRA:OWSCONSULTACHAVENFERESULT:CMSGRETNFE

        If oLOJXNFCE:oWSNFESBRA:OWSCONSULTACHAVENFERESULT:CCODRETNFE == cRetOk
            // -- Venda Trnasmitida e autorizada.
            Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)
            Self:LjMensagem("aResultConsultaChaveNFCE",      {.T.,cCodRet,cDescRet})
        ElseIf oLOJXNFCE:oWSNFESBRA:OWSCONSULTACHAVENFERESULT:CCODRETNFE == "999"
            // -- Sem comunicação com SEFAZ
            // -- O metodo da SEFAZ não retorna False indicando que não conseguiu conectar na sefaz, por esse motivo formamos a gravação
            // -- da propriedade aResultTSS como False. 
            Self:LjMensagem("aResultTSS",{.F.,"LjConsultaChaveNFe",cDescRet,cCodRet,""})
        Else 
            // -- Venda Trnasmitida porem rejeitada.
            Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)
            If !Empty(cCodRet) .AND. !Empty(cDescRet)
                Self:LjMensagem("aResultConsultaChaveNFCE",      {.F.,cCodRet,cDescRet})
            Endif 
        Endif     
    Else
        //  -- Sem comunicação com TSS ou SEFAZ 
        Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)   
    EndIf 
Else
    // -- Sem comunicação com TSS
    Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)   
EndIf 

Return 

//----------------------------------------------------------------------
/*/{Protheus.doc} LjMensagem
Metodo responsavel informar ao ERP sobre erro na comunicação/ execução do WebService atravez das propriedades de mensagens.

@param   cResult	    Indica em qual propriedade o metodo precisa ser gravado
@param   aMensagem	    Mensagem de erro ou log
@author  Lucas Novais (lnovais)
@since   09/04/2019
@version P12
/*/
//----------------------------------------------------------------------

Method LjMensagem(cResult,aMensagem) Class LOJGNFCE

Do Case
    Case cResult == "aResultTSS"
        Self:aResultTSS             := aMensagem
        LjGrvLog(cResult + " -> " + ProcName(1),Self:aResultTSS[3],Self:aResultTSS)

    Case cResult == "aResultConsultaChaveNFCE"
        Self:aResultConsultaChaveNFCE    := {aMensagem[1],aMensagem[2],aMensagem[3]}	
        LjGrvLog(cResult + " -> " + ProcName(1),Self:aResultConsultaChaveNFCE[2],Self:aResultConsultaChaveNFCE)

    Case cResult == "aResultConsultaProtocoloNFCE"
        Self:aResultConsultaProtocoloNFCE    := {aMensagem[1],aMensagem[2],aMensagem[3]}	
        LjGrvLog(cResult + " -> " + ProcName(1),Self:aResultConsultaProtocoloNFCE[2],Self:aResultConsultaProtocoloNFCE)

    Case cResult == "aResultMetodo"
        Self:aResultMetodo          := {aMensagem[1],aMensagem[2]}
        LjGrvLog(cResult + " -> " + ProcName(1),Self:aResultMetodo[2],Self:aResultMetodo)

    Case cResult == "aResultRetornaNotasNx"  
        Self:aResultRetornaNotasNx  := {aMensagem[1],aMensagem[2],aMensagem[3],aMensagem[4],aMensagem[5],aMensagem[6]}
        LjGrvLog(cResult + " -> " + ProcName(1),Self:aResultMetodo[2],Self:aResultMetodo) 
End Case

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} LjGetMVTSS
Metodo responsavel Buscar parametros no TSS

@param   cParametro	    Parametro que devera ser localizado no TSS -- [Parametro obrigatorio]
@param   aEntidades	    Entidade que a busca buscará o paramero -- [Parametro opcional] 
@param   nTypeSeek	    Tipo da busca que sera realizada  -- [Parametro opcional] 
(Tipo da Busca, 1 - Range (Ex.: 00001;00002. Id "de" "até"), 2 - Parser (Ex.: 00001;00002;00003. Explicito os Ids) ou 3 - Single (Ex.: 00001. Apenas um Id))
@param   lForceSeek     Parametro que indica se deverá forçar a busca no TSS ignorando o conteudo salvo em memoria -- [Parametro opcional] 
@param   xDefault       Default a ser devolvido caso não encontre o parametro ou não consiga comunicar com TSS, Caso não consiga comunicar a posição da entidade será Nil -- [Parametro opcional] 
@author  Lucas Novais (lnovais)
@since   09/04/2019
@version P12
@return  Array contendo parametro solicitado {{"Entidade","Conteudo do parametro"},{"Entidade","Conteudo do parametro"},{"XXX..","XXX.."}}
/*/
//----------------------------------------------------------------------

Method LjGetMVTSS(cParametro,aEntidades,nTypeSeek,lForceSeek,xDefault) Class LOJGNFCE

Local oLOJXNFCE := LOJXNFCE():New()             // -- Instancia a Class LOJXNFCE
Local lStart    := oLOJXNFCE:LojXNfceStart()    // -- Inicia os metodos principais da Classe
Local aParamTSS := {{Nil,{}}}                   // -- Armazena Retorno com parametros do TSS
Local nI                                        // -- Variavel para For 
Local nPosMV    := 0                            // -- Posição do parametro desejado
Local aRet      := {}                           // -- Retorno do metodo

Default cParametro  := ""                       // -- [Parametro obrigatorio]   -- Parametro que seja consultado
Default aEntidades  := {}                       // -- [Parametro opcional]      -- Caso não seja enviado entidade ele pegara as informações da entidade corrente
Default nTypeSeek   := 3                        // -- [Parametro opcional]      -- Busca apenas dados de uma entidades (Obs: Caso seja enviado 3 a busca será realizada obrigatoriamente na entidade corrente)
Default lForceSeek  := .F.                      // -- [Parametro opcional]      -- Indica se realizara a consulta no TSS mesmo podendo ja ter os dados em memoria
Default xDefault    := ""                       // -- [Parametro opcional]      -- Defoult que será retorado caso não encontre o parametro ou não consiga conexão com TSS

If lStart
    If Empty(aEntidades) .OR. (len(aEntidades) > 1 .AND. nTypeSeek = 3) // -- Se o tamanho do array aEntidades for maior que 1 e nTypeSeek for igual a 3 busco apenas a entidade corrente
        aEntidades := {oLOJXNFCE:oWSSPEDADM:cADMEMPRESASRESULT}    
    EndIf 
EndIf 

If !Empty(cParametro)
    
    If !lForceSeek  
        For nI := 1 To len(aEntidades)
            If  aScan(Self:aFirstEntity,{|X| x == aEntidades[nI]}) == 0
                lForceSeek := .T.
                Exit
            EndIf 
        Next
    EndIf 

    If Empty(Self:aParamTSS) .Or. lForceSeek
        
        Self:aFirstEntity := aClone(aEntidades)

        If lStart   
            If oLOJXNFCE:LjGetAlIMVTSS(aEntidades,nTypeSeek)
            
                aParamTSS := Array(Len(oLOJXNFCE:oWSSPEDCfgNfe:OWSGETALLMVTSSRESULT:OWSRETGETALLMV))
                
                For nI := 1 To len(aParamTSS)
                    aParamTSS[nI] := {oLOJXNFCE:oWSSPEDCfgNfe:OWSGETALLMVTSSRESULT:OWSRETGETALLMV[nI]:CID_ENT,oLOJXNFCE:oWSSPEDCfgNfe:OWSGETALLMVTSSRESULT:OWSRETGETALLMV[nI]:OWSMVSTRUCT:OWSRETMVGETALLMV}
                Next 

                Self:aParamTSS := aClone(aParamTSS)

                Self:LjMensagem("aResultMetodo",{.T.,"metodo LjGetAlIMVTSS executado com sucesso"}) 
            Else
                Self:LjMensagem("aResultMetodo",{.F.,"Não Foi possivel executar metodo LjGetAlIMVTSS"}) 
                Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem) 
            Endif
        Else 
            Self:LjMensagem("aResultMetodo",{.F.,"Não Foi possivel executar metodo LojXNfceStart"}) 
            Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)  
        EndIf
    Else 
        For nI := 1 To len(Self:aParamTSS)
            If  aScan(aEntidades,{|X| x == Self:aParamTSS[nI][1]}) > 0
                AADD(aParamTSS, Self:aParamTSS[nI])
            EndIf 
        Next
    EndIf 

    For nI := 1 to len(aParamTSS)
        nPosMV  := aScan(aParamTSS[nI][2],{|x| x:CMVNAME ==  cParametro })
        If nPosMV > 0
            Aadd(aRet,{aParamTSS[nI][1],aParamTSS[nI][2][nPosMV]:CMVVALUE})
        Else 
            Aadd(aRet, {aParamTSS[nI][1],xDefault})
        EndIf 
    Next
Else 
    Self:LjMensagem("aResultMetodo",{.F.,"O parametro para busca não foi informado"}) 
    aRet := {Nil,Nil} 
EndIf 

Return aRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LjGetCodIBGE
Metodo responsavel Retornar codigo do IBGE

@param   cUF	        Com a UF realizo a busco do Codigo do Estado
@param   cCodMun        Concateno com o codigo do estado formando o codigo completo do IBGE (Estado + Municipio)	    
@author  Lucas Novais (lnovais)
@since   09/04/2019
@version P12
@return  Codigo do IBGE
/*/
//----------------------------------------------------------------------
Method LjGetCodIBGE(cUF,cCodMun) Class LOJGNFCE
Local cCodIBGE	:= ""	//código do município do IBGE
Local nPos		:= 0	//posição de um determinado elemento no array
Local aUF		:= {}	//array com os códigos das UF

Default cUF		:= ""
Default cCodMun := ""

If cUF <> "EX"
    Aadd( aUF, {"RO","11"} )
    Aadd( aUF, {"AC","12"} )
    Aadd( aUF, {"AM","13"} )
    Aadd( aUF, {"RR","14"} )
    Aadd( aUF, {"PA","15"} )
    Aadd( aUF, {"AP","16"} )
    Aadd( aUF, {"TO","17"} )
    Aadd( aUF, {"MA","21"} )
    Aadd( aUF, {"PI","22"} )
    Aadd( aUF, {"CE","23"} )
    Aadd( aUF, {"RN","24"} )
    Aadd( aUF, {"PB","25"} )
    Aadd( aUF, {"PE","26"} )
    Aadd( aUF, {"AL","27"} )
    Aadd( aUF, {"MG","31"} )
    Aadd( aUF, {"ES","32"} )
    Aadd( aUF, {"RJ","33"} )
    Aadd( aUF, {"SP","35"} )
    Aadd( aUF, {"PR","41"} )
    Aadd( aUF, {"SC","42"} )
    Aadd( aUF, {"RS","43"} )
    Aadd( aUF, {"MS","50"} )
    Aadd( aUF, {"MT","51"} )
    Aadd( aUF, {"GO","52"} )
    Aadd( aUF, {"DF","53"} )
    Aadd( aUF, {"SE","28"} )
    Aadd( aUF, {"BA","29"} )

    nPos := aScan( aUF, {|x| x[1] == cUF} )
    If nPos > 0
        cCodIBGE := aUF[nPos][2] + AllTrim(cCodMun)
    EndIf
Else
    cCodIBGE := "99" + "99999"
EndIf

Return cCodIBGE

//----------------------------------------------------------------------
/*/{Protheus.doc} LjClearInteractSLX
Metodo responsavel por limpar as interações na tabela de SLX

@param   cPdv,      Caracter, Codigo do PDV
@param   cDoc,      Caracter, Documento a ser consultado
@param   cSerie,    Caracter, Serie a ser consultada     
@author  Lucas Novais (lnovais)
@since   02/08/2019
@version P12
@return  Logico,  Indica se conseguiu limpar as interações
/*/
//----------------------------------------------------------------------
Method LjClearInteractSLX(cPdv,cDoc,cSerie) Class LOJGNFCE

Local aArea 		:= GetArea()            // -- Guarda Area atual
Local aAreaSLX 		:= SLX->(GetArea())     // -- Guarda Area da SLX
Local lRet          := .T.                  // -- Retoro da função

DbSelectArea("SLX")
SLX->(DbSetOrder(1)) 

If SLX->(DbSeek( xFilial("SLX") + cPdv + cDoc + cSerie))
    RecLock( "SLX", .F. )
        Replace SLX->LX_ITERACA with 0
        Replace SLX->LX_DULTPRC with cToD("  /  /  ")
        Replace SLX->LX_HULTPRC with ""
        Replace SLX->LX_SITUA   with "  "
    SLX->( MsUnlock() )
Else 
    lRet := .F.
    Self:LjMensagem("aResultMetodo",{.F.,"Não foi possivel localizar o registro na tabela SLX chave: {"+ xFilial("SLX") + cPdv + cDoc + cSerie +"}"})  
EndIf 

RestArea(aArea)
RestArea(aAreaSLX)

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LjAddInteractSLX
Metodo responsavel por adicionar interações na tabela de SLX

@param   cPdv,      Caracter, Codigo do PDV
@param   cDoc,      Caracter, Documento a ser consultado
@param   cSerie,    Caracter, Serie a ser consultada   
@param   cL1Situa,  Caracter, L1_SITUA da venda
@author  Lucas Novais (lnovais)
@since   02/08/2019
@version P12
@return  Logico,  Indica se conseguiu adicionar as interações
/*/
//----------------------------------------------------------------------
Method LjAddInteractSLX(cPdv,cDoc,cSerie,cL1Situa) Class LOJGNFCE

Local aArea 		:= GetArea()            // -- Guarda Area atual
Local aAreaSLX 		:= SLX->(GetArea())     // -- Guarda Area da SLX
Local lRet          := .F.                  // -- Retoro da função

DbSelectArea("SLX")
SLX->(DbSetOrder(1)) 

If ( cL1Situa == "X2" .OR. cL1Situa == "X3") .AND. SLX->(DbSeek( xFilial("SLX") + cPdv + cDoc + cSerie))
    nIntera :=  SLX->LX_ITERACA + 1
    RecLock( "SLX", .F. )
        Replace SLX->LX_ITERACA with nIntera
        If nIntera > Self:nLimitTent 
            Replace SLX->LX_SITUA with "ER"
        EndIf 
    SLX->( MsUnlock() )
    lRet := .T.
Else 
    Self:LjMensagem("aResultMetodo",{.F.,"Não foi possivel localizar o registro na tabela SLX chave: {"+ xFilial("SLX") + cPdv + cDoc + cSerie +"}"})  
EndIf 

RestArea(aArea)
RestArea(aAreaSLX)

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LjCheckInteractSLX
Metodo responsavel por checar quantidade de interações na tabela de SLX

@param   cPdv,      Caracter, Codigo do PDV
@param   cDoc,      Caracter, Documento a ser consultado
@param   cSerie,    Caracter, Serie a ser consultada   
@param   cL1Situa,  Caracter, L1_SITUA da venda
@author  Lucas Novais (lnovais)
@since   02/08/2019
@version P12
@return  Logico,  Indica se é possivel continuar com o cancelamento
/*/
//----------------------------------------------------------------------
Method LjCheckInteractSLX(cPdv,cDoc,cSerie,cL1Situa) Class LOJGNFCE

Local aArea 		:= GetArea()            // -- Guarda Area atual
Local aAreaSLX 		:= SLX->(GetArea())     // -- Guarda Area da SLX
Local lRet          := .T.                  // -- Retoro da função

DbSelectArea("SLX")
SLX->(DbSetOrder(1)) 

cChave := xFilial("SLX") + cPdv + cDoc + cSerie

If ( cL1Situa == "X2" .OR. cL1Situa == "X3") .And. SLX->(DbSeek( cChave ))

	If LX_SITUA == "ER" 
		lRet := .F.
		Self:LjMensagem("aResultMetodo",{.F.,"O Cancelamento Chave: {"+  cChave +"} Encontra-se com situação = ER, por esse motivo sera ignorado no fluxo de cancelamento."})  
        If SLX->LX_ITERACA >= Self:nLimitTent
            Self:LjMensagem("aResultMetodo",{.F.,"O Cancelamento Chave: {"+  cChave +"} Exedeu o numero de tentativas, numero de tentativas: " + cValToChar(SLX->LX_ITERACA) + " Maximo de tentativa: " + cValToChar(Self:nLimitTent)})  
	    EndIf 
	EndIf 

EndIf 

RestArea(aArea)
RestArea(aAreaSLX)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjChkCert
Valida o vencimento do Certificado Digital do TSS

@param   cIdEnt - Código da Entidade
@author  eduardo.sales
@since   30/07/2019
@version P12
@return  
/*/
//-------------------------------------------------------------------
Method LjChkCert(cIdEnt) Class LOJGNFCE

Local oNfce     := LOJXNFCE():New()     //Constroi o objeto LOJXNFCE
Local dDataVenc := cToD("")             //Data de Vencimento do Certificado
Local cMsg      := ""

If oNfce:LjGetCert(cIdEnt)
    If Len(oNfce:OWSSPEDCFGNFE:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0

        dDataVenc := oNfce:OWSSPEDCFGNFE:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[1]:DVALIDTO
        
        If Date() >= dDataVenc-30 .And. Date() <= dDataVenc 
            cMsg := "O certificado digital irá vencer em: " + DtoC(dDataVenc)
        ElseIf Date() >= dDataVenc+1
            cMsg := "O certificado digital está vencido desde: " + DtoC(dDataVenc)
        EndIf
    EndIf
EndIf

If !Empty(cMsg)
    LjGrvLog(NIL, cMsg)
    If IsBlind()
        ConOut(cMsg)
    Else
        Aviso("SPED",cMsg,{"Ok"},3)
    EndIf
EndIf

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} LjConsProtocoloNFCE
Metodo responsavel Por fazer a Consulta Protocolo e retornar o situação da NFC-e na SEFAZ.
Este método também atualiza o status da nota no TSS além de consultar na SEFAZ.

@author  Alberto Deviciente
@since   08/06/2022
@version P12

@param   cID, Caractere, Número do ID da nota no TSS (Serie + Documento)

@return  Nil, Nulo
/*/
//----------------------------------------------------------------------
Method LjConsProtocoloNFCE(cID) Class LOJGNFCE
Local oLOJXNFCE := LOJXNFCE():NEW()
Local cRetOk    := "100"  
Local cCodRet   := ""
Local cDescRet  := ""

If oLOJXNFCE:LojXNfceStart()
    If oLOJXNFCE:LjConsProtocoloNFe(cID)
        
        cCodRet     := oLOJXNFCE:oWSNFESBRA:oWSCONSULTAPROTOCOLONFERESULT:CCODRETNFE
        cDescRet    := oLOJXNFCE:oWSNFESBRA:oWSCONSULTAPROTOCOLONFERESULT:CMSGRETNFE

        If oLOJXNFCE:oWSNFESBRA:oWSCONSULTAPROTOCOLONFERESULT:CCODRETNFE == cRetOk
            // -- Venda Trnasmitida e autorizada.
            Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)
            Self:LjMensagem("aResultConsultaProtocoloNFCE",      {.T.,cCodRet,cDescRet})
        ElseIf oLOJXNFCE:oWSNFESBRA:oWSCONSULTAPROTOCOLONFERESULT:CCODRETNFE == "999"
            // -- Sem comunicação com SEFAZ
            // -- O metodo da SEFAZ não retorna False indicando que não conseguiu conectar na sefaz, por esse motivo formamos a gravação
            // -- da propriedade aResultTSS como False. 
            Self:LjMensagem("aResultTSS",{.F.,"LjConsProtocoloNFe",cDescRet,cCodRet,""})
        Else 
            // -- Venda Transmitida porem rejeitada.
            Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)
            If !Empty(cCodRet) .AND. !Empty(cDescRet)
                Self:LjMensagem("aResultConsultaProtocoloNFCE",      {.F.,cCodRet,cDescRet})
            Endif 
        Endif     
    Else
        //  -- Sem comunicação com TSS ou SEFAZ 
        Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)   
    EndIf 
Else
    // -- Sem comunicação com TSS
    Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)   
EndIf 

Return 
//----------------------------------------------------------------------
/*/{Protheus.doc} LjRetornaNotas
Metodo responsavel Por fazer a Consulta e retornar o situação da trasmissao tfs.

@author  TOTVS
@since   04/08/2022
@version P12

@param   cID

@return  Nil, Nulo
/*/
//----------------------------------------------------------------------
Method LjRetornaNotas(cId) Class LOJGNFCE
    Local oLOJXNFCE := LOJXNFCE():NEW()
    Local oNotas := Nil
    Local cXML
    Local cProtocolo
    Local cDHRecbto
    
    If oLOJXNFCE:LojXNfceStart()
        oLOJXNFCE:LjRetornaNotas(cID)
        oNotas := oLOJXNFCE:OWSNFESBRA:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5
        If Len(oNotas) > 0
            cXML       := oNotas[1]:oWSNFE:CXML
            cProtocolo := oNotas[1]:oWSNFE:CPROTOCOLO
            cDHRecbto  := oNotas[1]:oWSNFE:CXMLPROT

            Self:LjMensagem("aResultRetornaNotasNx",   {.T.,cXML,cProtocolo,cDHRecbto,"200","Sucesso"})
        Else
            Self:LjMensagem("aResultRetornaNotasNx",{.F.,"","","","404","Não foi possível encontrar a NF-e do pedido. Verificar os parâmetros de configuração TSS: MV_SPEDURL e MV_NFCEURL"})
        EndIf 

        Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)

    Else
        //Retorno erro de conexão.
        Self:LjMensagem("aResultRetornaNotasNx", {oLOJXNFCE:aMensagem[1],oLOJXNFCE:aMensagem[2],oLOJXNFCE:aMensagem[3],"","404",oLOJXNFCE:aMensagem[5]})
        Self:LjMensagem("aResultTSS",oLOJXNFCE:aMensagem)
    Endif

Return
