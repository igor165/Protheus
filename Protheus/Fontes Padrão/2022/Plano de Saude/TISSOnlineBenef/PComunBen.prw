#INCLUDE "PROTHEUS.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} PComunBen
    Classe para controle de transacoes TISS On de Atendimento/Beneficiarios
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Class PComunBen From PTissOnBen

    Data cMatric    as String
    Data cSeqTran   as String
    Data cRegANSOpe as String
    Data cCodRDA    as String
    Data cCodBAU    as String
    Data cCPFCNPJR	as String
    Data cTipoEve   as String
    Data dDataEve   as Date
    Data cTipoInt   as String
    Data cMotEncerr as String
    Data cStatComun as String
    Data aDadBenef  as Array
    
	Method New()
    Method critEspec()
    Method readCabec()
    Method geraCabec()
    Method geraBody()
    Method gerRecComu()
    Method procGuia()
    Method posicBE4()    
    Method setBenef(lFindBA1,lAteRN)

EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
 Classe Construtora
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method New(cCodOpe) Class PComunBen

    _Super:new()
    self:cTransWS   := "comunicacaoBeneficiarioWS"
    self:cRespWS    := "reciboComunicacaoWS"
    self:lVldLogin  := .T.
    
    self:cMatric    := ""
    self:cSeqTran   := ""
    self:cRegANSOpe := ""
    self:cCodRDA    := ""
    self:cCodBAU    := ""
    self:cCPFCNPJR	:= ""
    self:cTipoEve   := ""
    self:dDataEve   := Stod("")
    self:cTipoInt   := ""
    self:cMotEncerr := ""
    self:cStatComun := ""
    self:aDadBenef  := {}
   
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} critEspec
Carrega criticas especificas

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method critEspec() Class PComunBen

    HMSet(self:oCritMap, "1001", "NUMERO DA CARTEIRA INVALIDO")
	HMSet(self:oCritMap, "1404", "NAO EXISTE GUIA DE AUTORIZACAO RELACIONADA")
	HMSet(self:oCritMap, "3100", "PARA LIBERAR ESTE ACESSO, ENTRE EM CONTATO COM A OPERADORA E SOLICITE O CADASTRAMENTO DO SEU CODIGO DE ORIGEM")
    HMSet(self:oCritMap, "1013", "CADASTRO DO BENEFICIARIO COM PROBLEMAS")
    HMSet(self:oCritMap, "1323", "DATA PREENCHIDA INCORRETAMENTE")
    HMSet(self:oCritMap, "1212", "ATENDIMENTO / REFERENCIA FORA DA VIGENCIA DO CONTRATO DO PRESTADOR")
    HMSet(self:oCritMap, "1615", "INTERNAÇÃO NÃO AUTORIZADA")
    HMSet(self:oCritMap, "1402", "PROCEDIMENTO NÃO AUTORIZADO")
    HMSet(self:oCritMap, "5027", "REGISTRO ANS DA OPERADORA INVALIDO")
    HMSet(self:oCritMap, "1203", "CODIGO PRESTADOR INVALIDO")
    HMSet(self:oCritMap, "1437", "SENHA DE AUTORIZACAO CANCELADA")

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} geraBody
Processa e gera xml geral

@author  sakai
@version P12
@since   23/03/2021
/*/
//------------------------------------------------------------------- 
Method geraBody() Class PComunBen

	//Cabecalho da mensagem
    self:geraCabec()

	//Corpo da Mensagem
	self:gerTag( 1,"ans:reciboComunicacao"	,''	,.T.,.F.,.T., .F. )
    
    if self:aCritARQ[1] 
        self:gerCritArq() //Gera xml com criticas de login
    else
        self:procGuia()   //Realiza o processamento na guia
        self:gerRecComu() //Gera tag de resposta <reciboComunicacao>
    endIf

	self:gerTag( 1,"ans:reciboComunicacao"	,''	,.F.,.T.,.T., .F. )
    self:gerTag( 3,"ans:hash"				,MD5(self:cStrHash,2) ,.T.,.T.,.T., .F. )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} geraCabec
Monta cabecalho de resposta

@author  sakai
@version P12
@since   23/03/2021
/*/
//------------------------------------------------------------------- 
Method geraCabec() Class PComunBen

    Local cDataAtu := DtoS(DatE())

    self:gerTag( 1,"ans:cabecalho"				,''						 ,.T.,.F.,.T., .F. )
	self:gerTag( 2,"ans:identificacaoTransacao" ,''						 ,.T.,.F.,.T., .F. )
	self:gerTag( 3,"ans:tipoTransacao"			,'RECIBO_COMUNICACAO'    ,.T.,.T.,.T., .F. )
	self:gerTag( 3,"ans:sequencialTransacao"	,self:cSeqTran			 ,.T.,.T.,.T., .F. )
	self:gerTag( 3,"ans:dataRegistroTransacao"	,self:maskDate(cDataAtu) ,.T.,.T.,.T., .F. )
	self:gerTag( 3,"ans:horaRegistroTransacao"	,Time()					 ,.T.,.T.,.T., .F. )
	self:gerTag( 2,"ans:identificacaoTransacao"	,''						 ,.F.,.T.,.T., .F. )
	self:gerTag( 2,"ans:origem"					,''						 ,.T.,.F.,.T., .F. )
	self:gerTag( 3,"ans:registroANS"			,self:cRegANSOpe		 ,.T.,.T.,.T., .F. )
	self:gerTag( 2,"ans:origem"					,''						 ,.F.,.T.,.T., .F. )
	self:gerTag( 2,"ans:destino"				,''				 		 ,.T.,.F.,.T., .F. )
	self:gerTag( 3,"ans:identificacaoPrestador"	,''				 		 ,.T.,.F.,.T., .F. )

    Do Case
        Case !Empty(self:cCodRDA)
            self:gerTag( 4,"ans:codigoPrestadorNaOperadora"	, self:cCodRDA  ,.T.,.T.,.T., .F. )
        
        Case Len(self:cCpfCnpjR) == 11 //CPF
            self:gerTag( 4,"ans:CPF"				, self:cCpfCnpjR ,.T.,.T.,.T., .F. )
       
        Case Len(self:cCpfCnpjR) == 14 //CNPJ
            self:gerTag( 4,"ans:CNPJ"				, self:cCpfCnpjR ,.T.,.T.,.T., .F. )
    EndCase

	self:gerTag( 3,"ans:identificacaoPrestador"	,''				 ,.F.,.T.,.T., .F. )
	self:gerTag( 2,"ans:destino"				,''				 ,.F.,.T.,.T., .F. )
	self:gerTag( 2,"ans:Padrao"					,self:cVerArq	 ,.T.,.T.,.T., .F. )
	self:gerTag( 1,"ans:cabecalho"				,''				 ,.F.,.T.,.T., .F. )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} gerRecComu
Gera reciboComunicacao

@author  sakai
@version P12
@since   23/03/2021
/*/
//------------------------------------------------------------------- 
Method gerRecComu() Class PComunBen

    Local cDataEve := self:maskDate(DtoS(self:dDataEve))

	self:gerTag( 2,"ans:reciboComunicacao"	,''	             ,.T.,.F.,.T.,.F.)
	self:gerTag( 3,"ans:statusComunicacao"	,self:cStatComun ,.T.,.T.,.T.,.F.)

    //beneficiarioComunicacao
    self:gerTag( 3,"ans:beneficiarioComunicacao",''				    ,.T.,.F.,.T.,.F.)

    //dadosBeneficiario
    self:gerTag( 4,"ans:dadosBeneficiario"	    ,''				    ,.T.,.F.,.T.,.F.)
    self:gerTag( 5,"ans:numeroCarteira"	        ,self:cMatric       ,.T.,.T.,.T.,.F.)
    self:gerTag( 5,"ans:atendimentoRN"	        ,self:aDadBenef[1]  ,.T.,.T.,.T.,.F.)
    If self:CVERARQ < '4'
        self:gerTag( 5,"ans:nomeBeneficiario"	    ,self:aDadBenef[2]  ,.T.,.T.,.T.,.F.)
        self:gerTag( 5,"ans:numeroCNS"	            ,self:aDadBenef[3]  ,.T.,.T.,.F.,.F.)
    EndIf
    self:gerTag( 4,"ans:dadosBeneficiario"	    ,''				    ,.F.,.T.,.T.,.F.)

    If self:CVERARQ < '4'
        self:gerTag( 4,"ans:dataEvento"	            , cDataEve       ,.T.,.T.,.T.,.F.)
    else //Nome do Beneficiario e Nome Social aparecem fora da tag dadosBeneficiario na versao 4.00.01 do TISS
        self:gerTag( 4,"ans:nomeBeneficiario"	    ,self:aDadBenef[2]  ,.T.,.T.,.T.,.F.)
        self:gerTag( 4,"ans:nomeSocialBeneficiario" ,self:aDadBenef[3]  ,.T.,.T.,.F.,.F.)
    EndIf
    self:gerTag( 4,"ans:tipoEvento"	            , self:cTipoEve  ,.T.,.T.,.T.,.F.)

    //dadosInternacao
    self:gerTag( 4,"ans:dadosInternacao"	    ,''				 ,.T.,.F.,.T.,.F.)
    if self:cTipoEve == "A" //Alta
        self:gerTag( 5,"ans:motivoEncerramento" ,self:cMotEncerr ,.T.,.T.,.T.,.F.)
    else //Internacao
        self:gerTag( 5,"ans:tipoInternacao"	    ,self:cTipoInt   ,.T.,.T.,.T.,.F.)
    endIf
    self:gerTag( 4,"ans:dadosInternacao"	    ,''				 ,.F.,.T.,.T.,.F.)
    
    self:gerTag( 3,"ans:beneficiarioComunicacao",''				 ,.F.,.T.,.T.,.F.)
    
    //mensagemErro
    if self:aCritARQ[1]
        If self:CVERARQ < '4'
            self:gerTag( 3,"ans:mensagemErro"    ,''	            ,.T.,.F.,.T.,.F.)
            self:gerTag( 4,"ans:codigoGlosa"	 , self:aCritARQ[2] ,.T.,.T.,.T.,.F.)
            self:gerTag( 4,"ans:descricaoGlosa"	 , self:aCritARQ[3] ,.T.,.T.,.T.,.F.)
            self:gerTag( 3,"ans:mensagemErro"    ,''                ,.F.,.T.,.T.,.F.)
        else
            self:gerTag( 3,"ans:codigoGlosa"	 , self:aCritARQ[2] ,.T.,.T.,.T.,.F.) //Na versao 4.00.01 do TISS aparece apenas o codigoGlosa
        endIf
    endIf

    //Encerra arquivo
    self:gerTag( 2,"ans:reciboComunicacao"	  ,''	 	   	   ,.F.,.T.,.T.,.F.)

Return	


//-------------------------------------------------------------------
/*/{Protheus.doc} readCabec
Alimenta atributos com os dados do cabecalho

@author  sakai
@version P12
@since   23/03/2021
/*/
//------------------------------------------------------------------- 
Method readCabec() Class PComunBen

    Local nIndBAU  := 0
    Local cPesqBAU := ""

	self:cSeqTran   := self:oXML:XPathGetNodeValue( self:cPathTag + self:addNS("/identificacaoTransacao/sequencialTransacao"))
	self:cRegANSOpe := self:oXML:XPathGetNodeValue( self:cPathTag + self:addNS("/destino/registroANS" ))

    Do Case 

        Case self:oXML:XPathHasNode( self:cPathTag + self:addNS("/origem/identificacaoPrestador/codigoPrestadorNaOperadora" ))
            self:cCodRDA := self:oXML:XPathGetNodeValue( self:cPathTag + self:addNS("/origem/identificacaoPrestador/codigoPrestadorNaOperadora" ))

        Case self:oXML:XPathHasNode( self:cPathTag + self:addNS("/origem/identificacaoPrestador/CNPJ" ))
            self:cCPFCNPJR := self:oXML:XPathGetNodeValue( self:cPathTag + self:addNS("/origem/identificacaoPrestador/CNPJ" ))
        
        Case self:oXML:XPathHasNode( self:cPathTag + self:addNS("/origem/identificacaoPrestador/CPF" ))
            self:cCPFCNPJR := self:oXML:XPathGetNodeValue( self:cPathTag + self:addNS("/origem/identificacaoPrestador/CPF" ))
    
    EndCase
    
    //Valida Susep
    BA0->(DbSetOrder(5)) //BA0_FILIAL+BA0_SUSEP
    if empty(self:cRegANSOpe) .Or. !BA0->(DbSeek(xFilial("BA0")+self:cRegANSOpe))
        self:setCritica("5027") //REGISTRO ANS DA OPERADORA INVALIDO
    endIf

    //Valida RDA
    if !empty(self:cCodRDA)
        nIndBAU  := 1 //BAU_FILIAL+BAU_CODIGO
        cPesqBAU := self:cCodRDA
    else
        nIndBAU  := 4 //BAU_FILIAL+BAU_CPFCGC
        cPesqBAU := self:cCPFCNPJR
    endIf
    BAU->(DbSetOrder(nIndBAU))  
    if !empty(cPesqBAU) .And. BAU->(DbSeek(xFilial("BAU")+cPesqBAU))
        self:cCodBAU := BAU->BAU_CODIGO
    else
        self:setCritica("1203")	//CODIGO PRESTADOR INVÁLIDO        
    endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} procGuia
Processa a solicitacao de internacao/alta na guia

@author  sakai
@version P12
@since   23/03/2021
/*/
//------------------------------------------------------------------- 
Method procGuia() Class PComunBen

    Local aRet     := {}
    Local cBase    := "/comunicacaoBeneficiarioWS/comunicacaoBeneficiario"
    Local cCriTISS := ""

    self:cMatric    := self:retTag(cBase+"/dadosBeneficiario/numeroCarteira")
    self:cTipoEve   := self:retTag(cBase+"/tipoEvento")
    self:dDataEve   := self:retTag(cBase+"/dataEvento","D")
    self:cTipoInt   := self:retTag(cBase+"/dadosInternacao/tipoInternacao")
    self:cMotEncerr := self:retTag(cBase+"/dadosInternacao/motivoEncerramento")
    self:cStatComun := "N" //Padrao: Nao processei
    
    BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
    BTS->(DbsetOrder(1)) //BTS_FILIAL+BTS_MATVID

    if BA1->(DbSeek(xFilial("BA1")+self:cMatric)) .And. BTS->(DbSeek(xFilial("BTS")+BA1->BA1_MATVID))
	
        if self:posicBE4()
            
            self:setBenef(.T.,iif(BE4->BE4_ATERNA=="1",.T.,.F.)) //Array de suporte para tag <dadosBeneficiario>

            //Internacao
            if self:cTipoEve == "I"
                aRet := PLSA92DtIn(.T.,self:dDataEve,StrTran(Time(),":","") )
                //Posicao 4 indica critica de processamento
                if len(aRet) > 3 .And. !Empty(aRet[4]) 
                    self:setCritica(aRet[4])
                else
                    self:cStatComun := "S"
                endIf

            //Alta
            elseIf self:cTipoEve == "A"

                PLSADtAlt(.T.,self:dDataEve,StrTran(Time(),":",""), self:cMotEncerr, @cCriTISS )
                if !empty(cCriTISS)
                    self:setCritica(cCriTISS)
                else
                    self:cStatComun := "S"
                endIf
            endIf
            
        //Nao encontrou guia para realizar internacao/alta    
        else
            self:setCritica("1404") //"NAO EXISTE GUIA DE AUTORIZACAO RELACIONADA"
            self:setBenef(.T.,.F.) //Array de suporte para tag <dadosBeneficiario>
        endIf

    //Nao encontrou o beneficiario   
    else
        self:setCritica("1001") //"NUMERO DA CARTEIRA INVALIDO"
        self:setBenef(.F.,.F.) //Array de suporte para tag <dadosBeneficiario>
    endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} posicBE4
Posiciona no registro BE4 correspondente

@author  sakai
@version P12
@since   23/03/2021
/*/
//------------------------------------------------------------------- 
Method posicBE4() Class PComunBen

    Local cSql := ""
    Local lAux := .F.
    Local lRet := .F.

    cSql += " SELECT BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT, "
    cSql += " BE4_DATPRO, BE4_HORPRO, BE4_DTALTA, BE4_HRALTA "
    cSql += " FROM " + RetSqlName("BE4")
    cSql += " WHERE BE4_FILIAL = '"+xFilial("BE4")+"' "
    cSql += " AND BE4_OPEUSR = '"+Substr(self:cMatric,1,4)+"' " 
    cSql += " AND BE4_CODEMP = '"+Substr(self:cMatric,5,4)+"' "
    cSql += " AND BE4_MATRIC = '"+Substr(self:cMatric,9,6)+"' "
    cSql += " AND BE4_TIPREG = '"+Substr(self:cMatric,15,2)+"' "
    cSql += " AND BE4_CODRDA = '"+self:cCodBAU+"' "
    cSql += " AND D_E_L_E_T_ = ' ' "
    cSql += " ORDER BY BE4_DTDIGI DESC, BE4_HHDIGI DESC "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRB",.F.,.T.)
    if !TRB->(Eof())

        if (self:cTipoEve == "I" .And. Empty(TRB->BE4_DATPRO) .And. Empty(TRB->BE4_HORPRO)) .Or. ;
           (self:cTipoEve == "A" .And. !Empty(TRB->BE4_DATPRO) .And. !Empty(TRB->BE4_HORPRO) .And. Empty(TRB->BE4_DTALTA) .And. Empty(TRB->BE4_HRALTA))

            lAux := .T. //Regra primaria
        endIf

        BE4->(DbsetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
        if lAux .And. BE4->(DbSeek(xFilial("BE4")+TRB->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) ))
            lRet := .T.
        endIf
	endIf
	TRB->(DbCloseArea())

    if ExistBlock("PCOMBE01")
		lRet := ExecBlock("PCOMBE01",.F.,.F.,{lRet, BE4->(Recno()) })
	endIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} setBenef
Seta dados do beneficiarios

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
Method setBenef(lFindBA1,lAteRN) Class PComunBen

    Local cAteRN     := ""
    Local cNomeBen   := ""
    Local cNumCNS    := ""
    Local cNomeSoc   := "" //Nome social Versao 4.00.01 TISS
    
    Default lFindBA1 := .F.
    Default lAteRN   := .F.

    cNomeBen := iif(lFindBA1,Alltrim(BA1->BA1_NOMUSR),"BENEFICIARIO INVALIDO")
    If self:CVERARQ < '4'
        cNumCNS  := iif(lFindBA1,Alltrim(BTS->BTS_NRCRNA),"")
    else
        cNomeSoc  := iif(lFindBA1,Alltrim(BA1->BA1_NOMSOC),"") //Pega o valor do nome social na tabela BA1, se não existir deixa em branco
    EndIf
    cAteRN   := iif(lAteRN,"S","N")

    If self:CVERARQ < '4'
        self:aDadBenef := {cAteRN,;   //atendimentoRN
                        cNomeBen,; //nomeBeneficiario
                        cNumCNS }  //numeroCNS
    else
        self:aDadBenef := {cAteRN,; //atendimentoRN
                        cNomeBen,;  //nomeBeneficiario
                        cNomeSoc }  //NomeSocial
    EndIf

Return