#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ121.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ121

Adapter REST da rotina de IMPRESSORAS

@type 		function
@sample 	GTPIRJ121(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	flavio.martins
@since 		17/04/2020
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ121(lJob, lMonit, lAuto)
Local aArea  := GetArea() 
Local lRet   := .T.

Default lJob  := .F. 
Default lAuto := .F.

FwMsgRun( , {|oSelf| lRet := GI121Receb(lJob, oSelf, @lMonit, lAuto)}, , STR0001) // "Processando registros de Impressoras... Aguarde!" 

RestArea(aArea)
GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI121Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI121Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	flavio.martins
@since 		17/04/2020
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI121Receb(lJob, oMessage, lMonit, lAuto)

Local oRJIntegra  := GtpRjIntegra():New()
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"LG_FILIAL", "LG_CODIGO"}
Local cIntID	  := ""
Local cExtID	  := ""
Local cCode		  := ""
Local cErro		  := ""
Local cTagName    := ""
Local cCampo      := ""
Local cTipoCpo    := ""
Local xValor      := ""
Local nX          := 0
Local nY          := 0
Local nOpc		  := 0
Local nTotReg     := 0
Local lOk		  := .F.
Local lRet        := .T.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'
Local cFilAux     := ""
Local aCab	      := {} 
Local nModulo     := 12 //SIGALOJA
Local cCodEcf     := ""
Local cIdExtAge   := ""
Local cResultAuto := ''
Local cXmlAuto    := ''

Private lMsErroAuto	:= .F.

oRJIntegra:SetPath("/impressora/todas")
oRJIntegra:SetServico("Impressora",.F., nModulo)

If lAuto
	cResultAuto := '{"impressora":[{"impressoraID":62,"numeroIdentificacao":"999","cnpj":"27.486.182/0001-09","empresaid":"15","numeroImpressora":null,"numSerie":"295520","numSerie20":"BE091410100011295500","marca":"BEMATECH","modelo":"MP-4000 TH FI","mfAdicional":" ","usarioID":"2601","numUsuario":null,"tipoECF":"ECF-IF","versionSB":"010002","dataInstalacao":"2014-07-18 08:39:53.0","fecModif":1412792637000,"numSeqECF":"001","estadoLocalID":"15","estadoLacreID":"15","codigoIF":"","numIE":"80444202","numIM":"","indCtrl":"1","indBloqueaECF":"0","indValidaEstado":"0","activo":1,"agencia":"1","iAT":"A","cniee":"14"}]}'
	cXmlAuto    := '<?xml version="1.0" encoding="UTF-8"?><RJIntegra><Impressora tagMainList="impressora"><ListOfFields><Field><tagName>modelo</tagName><fieldProtheus>LG_IMPFISC</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>numSeqECF</tagName><fieldProtheus>LG_PDV</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field><Field><tagName>numSerie</tagName><fieldProtheus>LG_SERPDV</fieldProtheus><onlyInsert>False</onlyInsert><overwrite>True</overwrite></Field></ListOfFields></Impressora></RJIntegra>'
EndIf

If !lAuto
	oRJIntegra:SetServico("Impressora")
Else
	oRJIntegra:SetServico("Impressora",,,cXmlAuto)
EndIf

oRJIntegra:oGTPLog:SetNewLog(,,oRJIntegra:GetUrl(),"GTPIRJ121")

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

If oRJIntegra:Get(cResultAuto)
	SLG->(DbSetOrder(1))
	nTotReg := oRJIntegra:GetLenItens()	

    nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

    If ( nTotReg >= 0 )
	
        For nX := 0 To nTotReg
            lContinua := .T.
            If lMessage .And. !lJob
                oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))	// "Processando registros de Impressoras - #1/#2... Aguarde!" 
                ProcessMessages()
            EndIf

            // para essa integraç?o é preciso localizar a filial. Caso n?o encontrada, pular para próximo item do JSON
            If Empty((cFilAux := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt, oRJIntegra:GetJsonValue(nX, 'empresaid', 'C'), , "2"))) 
                Loop
            Else
                cFilAnt := cFilAux
            EndIf	        
            
            If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'impressoraID' ,'C'))
                cCode := GTPxRetId("TotalBus", "SLG", "LG_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
                
                cIdExtAge := oRJIntegra:GetJsonValue(nX, 'agencia' ,'C')

                If !Empty(cIdExtAge)
                    cDescAge := GetDescAge(cIdExtAge)
                Endif
                
                If Empty(cIntID) 
                    nOpc    := 3 
                    cCodEcf := GetNextCod(cFilAux)
                ElseIf lOk .And. SLG->(DbSeek(xFilial('SLG') + cCode))
                    nOpc    := 4
                    cCodEcf := cCode
                Else
                    lContinua := .F.
                    oRJIntegra:oGTPLog:SetText(cErro)
                EndIf
                
                If lContinua
                    aCab := {}

                    aAdd(aCab, {"LG_CODIGO" , cCodEcf , Nil} )
                    aAdd(aCab, {"LG_NOME"   , cDescAge, Nil} )
                    aAdd(aCab, {"LG_INTCNS"	, .F.    , Nil} )
                    aAdd(aCab, {"LG_GAVSTAT", .F.    , Nil} )


                    For nY := 1 To Len(aFldDePara)

                        cTagName    := aFldDePara[nY][1] 
                        cCampo      := aFldDePara[nY][2]
                        cTipoCpo    := aFldDePara[nY][3]
                        lOnlyInsert := aFldDePara[nY][6]
                        lOverWrite  := aFldDePara[nY][7]

                        If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo)))
                            
                            If (nOpc == 3 .And. lOnlyInsert)  .Or.;
                            (nOpc == 3 .And. !lOnlyInsert) .Or.;
                            (nOpc == 4 .And. lOverWrite) 

                                aAdd(aCab, {cCampo, xValor, Nil})
                            Endif 

                            If cCampo == 'LG_SERPDV'
                                aAdd(aCab, {'LG_SERIE', Right(xValor, 3), Nil})
                            Endif

                        Endif

                    Next

                    Begin Transaction 

                        MsExecAuto({|a,b,c,d| LOJA121(a,b,c,d)}, Nil, Nil, aCab, nOpc)
                                                
                        If lMsErroAuto
                            DisarmTransaction()
                            oRJIntegra:oGTPLog:SetText(I18N(STR0005, /*{GTPXErro()}*/))		// "Falha ao gravar os dados (#1)." 
                            lContinua := .F.	
                        ElseIf nOpc == 3
                            CFGA070MNT("TotalBus", "SLG", "LG_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(cCodEcf)))    
                        Endif

                    End Transaction

                    If !lContinua
                        Exit
                    Endif

                Endif

            EndIf
            
            //DSERGTP-6567: Novo Log Rest RJ
            If ( !lContinua )
                RJLogData(oRJIntegra:oGTPLog,oRJIntegra:cPath,oRJIntegra:oGTPLog:GetText(),/*oRJIntegra:GetResult("")*/)
                oRJIntegra:oGTPLog:ResetText()
            EndIf  	

        Next nX	

    Else
    	lMonit := .f.
		FwAlertHelp("Não há dados a serem processados com a parametrização utilizada.")
    EndIf

Else
	oRJIntegra:oGTPLog:SetText(I18N("Falha ao processar o retorno do serviço #2 (#1).", {oRJIntegra:GetLastError(),oRJIntegra:cUrl}))
EndIf

If !lJob .And. oRJIntegra:oGTPLog:HasInfo() 
	oRJIntegra:oGTPLog:ShowLog()
	lRet := .F.
ElseIf !lJob .And. !oRJIntegra:oGTPLog:HasInfo()
	If lMessage 
		oMessage:SetText(STR0004)	// "Processo finalizado." 
		ProcessMessages()
	Else
		Alert(STR0004)	// "Processo finalizado."
	EndIf	
EndIf

oRJIntegra:Destroy()
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetNextCod

Função utilizada para retornar próximo codigo para a tabela SLG

@type 		function
@sample 	GetNextCod(cFilAux)
@param		cFilAux, character - Filial 	 	
@return 	
@author 	flavio.martins
@since 		20/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GetNextCod(cFilAux)
Local cCod        := ""
Local cAliasSLG   := GetNextAlias()

BeginSql Alias cAliasSLG

    SELECT COALESCE(MAX(LG_CODIGO),'0') CODIGO
    FROM %Table:SLG% SLG
    WHERE
    SLG.LG_FILIAL = %Exp:cFilAux%
    AND SLG.%NotDel%

EndSql

cCod := Soma1((cAliasSLG)->CODIGO)

(cAliasSLG)->(dbCloseArea())

Return cCod

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetDescAge

Função utilizada para retornar o nome da agência vinculada a impressora

@type 		function
@sample 	GetDescAge(cIdExt)
@param		cIdExt, character - Id externo da agencia	 	
@return 	
@author 	flavio.martins
@since 		20/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GetDescAge(cIdExt)
Local cIntID	:= ""
Local cErro		:= ""
Local lOk		:= .F.
Local cDescAge  := ""
Local cCodAge   := ""
Local aCampos	:= {"GI6_FILIAL", "GI6_CODIGO"}

cCodAge := GTPxRetId("TotalBus", "GI6", "GI6_CODIGO", cIdExt, @cIntID, 3, @lOk, @cErro, aCampos, 1)

dbSelectArea("GI6")
GI6->(dbSetOrder(1))

If GI6->(dbSeek(xFilial('GI6')+cCodAge))
    cDescAge := GI6->GI6_DESCRI
Endif

GI6->(dbCloseArea())

Return cDescAge

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI121Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI121Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	flavio.martins
@since 		20/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI121Job(aParam, lAuto)

Default lAuto := .F.
//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[1], aParam[2])

GTPIRJ121(.T.,,lAuto)

RpcClearEnv()

Return

