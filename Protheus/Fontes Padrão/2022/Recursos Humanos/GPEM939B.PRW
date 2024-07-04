#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEM939.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEM939B
Exibe os lotes de integração com o P&M (Performance & Metas)
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Function GPEM939B()

Private aLogPeM     := {}
Private aMarkREF	:= {}
Private aTitle      := { OemToAnsi(STR0085) }//"Status do processamento pelo P&M"
Private cPMToken	:= SuperGetMv( 'MV_APIPEM0', Nil, "" )
Private cPMURL		:= SuperGetMv( 'MV_APIPEM1', Nil, "" ) 
Private cPMClient	:= SuperGetMv( 'MV_APIPEM2', Nil, "" )
Private cPMSecret	:= SuperGetMv( 'MV_APIPEM3', Nil, "" )
Private oBrowse

If !ChkFile("REF")
	//"Atenção"###"A tabela REF não existe no dicionário. É necessário atualização do ambiente para acesso à rotina"###"Contate o administrador do sistema para efetuar a atualização do ambiente"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0002), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0003) } )
	Return .F.
EndIf

If Empty(cPMToken) .Or. Empty(cPMURL) .Or. Empty(cPMClient) .Or. Empty(cPMSecret)
	//"Atenção"###"Os parâmetros MV_APIPEM0, MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3 não estão preenchidos."###"Contate o administrador do sistema para revisar a configuração dos parâmetros MV_APIPEM0, MV_APIPEM1, MV_APIPEM2 e/ou MV_APIPEM3 no módulo Configurador"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0013), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0072) } )
	Return .F.
EndIf

oBrowse := FWMarkBrowse():New()

If !FWIsAdmin()
    oBrowse:SetFilterDefault( "REF_USER == '" + RetCodUsr() + "'" )
EndIf

oBrowse:SetAlias( "REF" )
oBrowse:SetFieldMark( "REF_OK" )
oBrowse:SetDescription( STR0136 )//"Lote de integração P&M"
oBrowse:SetMenuDef( "GPEM939B" )
oBrowse:SetValid( { || REF->REF_STATUS $ "0/1" } )
oBrowse:SetAfterMark( { || fMark() } )
oBrowse:SetAllMark( { || fMarkAll() } )

//Legendas
oBrowse:AddLegend( "REF->REF_STATUS == '0'", "BLUE", STR0125 )//"Não iniciado"
oBrowse:AddLegend( "REF->REF_STATUS == '1'", "YELLOW", STR0126 )//"Executando"
oBrowse:AddLegend( "REF->REF_STATUS == '2'", "GREEN", STR0127 )//"Concluído"
oBrowse:AddLegend( "REF->REF_STATUS == '3'", "RED", STR0128 )//"Houve erro de validação"
oBrowse:AddLegend( "REF->REF_STATUS == 'X'", "BLACK", STR0137 )//"Não encontrado"

oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função com a regra do Model
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructREF    := FWFormStruct( 1, "REF" )
Local oModel        := MpFormModel():New( "GPEM939B", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/ )

oModel:AddFields( "REFMASTER", /*cOwner*/, oStructREF, /*Pre-Validacao*/, /*Pos-Validacao*/, /*Carga*/ )
oModel:SetPrimaryKey( {} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função com a regra da View
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel        := FwLoadModel( "GPEM939B" )
Local oStructREF    := FWFormStruct( 2, "REF" )
Local oView         := FWFormView():New()

oStructREF:RemoveField( "REF_OK" )

oView:SetModel( oModel )
oView:AddField( "VIEW_REF", oStructREF, "REFMASTER" )
oView:CreateHorizontalBox( "TELA", 100 )
oView:SetOwnerView( "VIEW_REF", "TELA" )
oView:addUserButton( OemToAnsi(STR0131), "MAGIC_BMP", { || fErrorPeM() }, OemToAnsi(STR0131), Nil, {MODEL_OPERATION_VIEW}, .T. )//"Consultar Inconsistências"
oView:addUserButton( OemToAnsi(STR0146), "MAGIC_BMP", { || ShellExecute( "open", "https://tdn.totvs.com/pages/viewpage.action?pageId=676047532", "", "", 1 ) }, OemToAnsi(STR0146), Nil, {MODEL_OPERATION_VIEW}, .T. )//"TDN Performance e Metas"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função com as opções de menu
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina :=  {}

ADD OPTION aRotina TITLE OemToAnsi( STR0129 ) ACTION "VIEWDEF.GPEM939B" OPERATION 2 ACCESS 0//"Visualizar"
ADD OPTION aRotina TITLE OemToAnsi( STR0130 ) ACTION "f939BGet()" 	    OPERATION 9 ACCESS 0//"Consultar Status"
ADD OPTION aRotina TITLE OemToAnsi( STR0145 ) ACTION "f939BTDN(1)" 	    OPERATION 10 ACCESS 0//"TDN Integração"
ADD OPTION aRotina TITLE OemToAnsi( STR0146 ) ACTION "f939BTDN(2)" 	    OPERATION 10 ACCESS 0//"TDN Performance e Metas"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para realiza a marcação de um registro no browse
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function fMark()

Local nPos      := aScan( aMarkREF, { |x| x == REF->( Recno() ) } )

If oBrowse:IsMark()
    aAdd( aMarkREF, REF->( Recno() ) )
Else
    If nPos > 0
        aDel( aMarkREF, nPos )        
        aSize( aMarkREF, Len( aMarkREF ) - 1 )
    EndIF
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fMarkAll
Função para realiza a marcação de todos os registros do browse
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function fMarkAll()

Local nLast

oBrowse:GoBottom(.F.)
nLast := oBrowse:At()
oBrowse:GoTop()

While .T.
    oBrowse:MarkRec()
    If nLast == oBrowse:At()
        oBrowse:GoTop()
        Exit
    EndIf
    oBrowse:GoDown()
EndDo

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} f939BGet()
Função que efetua a consulta do status do processamento dos lotes no P&M
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Function f939BGet()

Processa( { || fStat939B() }, STR0151)//"Efetuando consulta"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fStat939B()
Função que efetua a consulta do status do processamento dos lotes no P&M
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Function fStat939B( lJob )

Local aAreaREF  := REF->( GetArea() )
Local aHeader	:= {}
Local cErrToken := ""
Local cPath		:= "api/v1/process/"
Local cRetPeM	:= ""
Local cStatJson	:= ""
Local cStatPrc	:= ""
Local cTipoAPI	:= ""
Local cToken	:= ""
Local lErro	    := .F.
Local lTokOk	:= .T.
Local oClient 	:= FwRest():New(cPMUrl)
Local oJson		:= Nil
Local nMsgPeM   := 0
Local nReg	    := 0
Local nTotMark  := Len(aMarkREF)

Default lJob    := .F.

If !lJob .And. Empty(aMarkREF)
    Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0134), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0135) } )//"Atenção"###"Nenhum registro foi selecionado."###"Efetue a seleção de pelo menos um registro."
    Return .F.
EndIf

lTokOk := fTokenPM( @cToken, @cErrToken )

If !lTokOk
	If !lJob
        Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0132 + CRLF + STR0080 + CRLF + cErrToken), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0133) } )//"Atenção"###"Houve falha ao tentar obter o token de acesso"###"Obs.: erro completo retornado:"###"Solicite ao administrador uma revisão dos parâmetros MV_APIPEM0, MV_APIPEM2 e/ou MV_APIPEM3"
    Else
        Conout( FwNoAccent(STR0132 + CRLF + STR0080 + CRLF + cErrToken) )//"Houve falha ao tentar obter o token de acesso"###"Obs.: erro completo retornado:"
    EndIf
    Return .F.
EndIf

aAdd( aHeader, "Authorization: Bearer " + cToken )

If !lJob
    ProcRegua( nTotMark )
EndIf

For nReg := 1 To nTotMark
    If !lJob
        IncProc( OemToAnsi(STR0152) + cValToChar(nReg) + OemToAnsi(STR0153) + cValToChar(nTotMark) )//"Consultando lote "##" de "
    Else
        Conout( OemToAnsi(STR0152) + cValToChar(nReg) + OemToAnsi(STR0153) + cValToChar(nTotMark) )//"Consultando lote "##" de "
    EndIf

    REF->( dbGoTo(aMarkREF[nReg]) )
    oClient:SetPath( cPath+REF->REF_PRCID )
    
    cStatJson   := "X"
    cRetPeM     := ""

    If oClient:Get(aHeader)
        oJson := JsonObject():New()
        oJson:fromJson( oClient:GetResult() )
        fJsPMSt( @oJson, @cStatJson )
        cRetPeM := oClient:GetResult()
    EndIf    

    If REF->( RecLock("REF", .F.) )
        REF->REF_STATUS := cStatJson
        REF->REF_RETORN := oClient:GetResult()
        REF->( MsUnlock() )
    EndIf

    cTipoAPI := Iif( REF->REF_TIPO== "1", STR0015, Iif( REF->REF_TIPO == "2", STR0014, Iif( REF->REF_TIPO == "3", STR0017, Iif( REF->REF_TIPO == "4", STR0016, STR0018 ) ) ) )//"Filiais"##"Grupo de cargos"##"Cargos"##"Departamentos"##"Funcionários"
    cStatPrc := Iif( cStatJson == "0", STR0095, Iif( cStatJson == "1", STR0096, Iif( cStatJson == "2", STR0097, Iif( cStatJson == "3", STR0098, STR0137 ) ) ) )//"Status: "##" - "##"Não iniciado"##"Executando"##"Concluído"##"Houve erro de validação"##//"Não encontrado"

    If !lJob
        aAdd(aLogPeM, STR0093 + REF->REF_PRCID + " | " + STR0099 + REF->REF_TIPO + " - " + cTipoAPI + " | " + STR0094 + cStatJson + " - " + cStatPrc)//"ID do Lote: "##"Tipo: "##"Status: "
        If cStatJson == "3"
            lErro := .T.
            aAdd(aLogPeM, STR0100)//"Obs.: mensagem de validação retornada pelo P&M:"
            For nMsgPeM := 1 To Len(oJson["errorMessages"])
                FiltraLog( aLogPeM, STR0105 + Iif(ValType(oJson["errorMessages"][nMsgPeM]["integrationId"]) != "U", oJson["errorMessages"][nMsgPeM]["integrationId"] , "null" ) + " | " + STR0106 + Iif( ValType(oJson["errorMessages"][nMsgPeM]["code"]) != "U", cValToChar( oJson["errorMessages"][nMsgPeM]["code"] ) , "null" ) + " | " + Iif( ValType(oJson["errorMessages"][nMsgPeM]["message"]) != "U", STR0107 + oJson["errorMessages"][nMsgPeM]["message"], "null" ) )//"ID de integração: "##"Código da validação: "##"Mensagem: "
            Next nMsgPeM
        EndIf
    Else
        Conout( FwNoAccent(STR0093 + REF->REF_PRCID + " | " + STR0099 + REF->REF_TIPO + " - " + cTipoAPI + " | " + STR0094 + cStatJson + " - " + cStatPrc) )//"ID do Lote: "##"Tipo: "##"Status: "
        If cStatJson == "3"
            Conout( FwNoAccent(STR0100) )//"Obs.: mensagem de validação retornada pelo P&M:"
            For nMsgPeM := 1 To Len(oJson["errorMessages"])
                Conout( FwNoAccent(STR0105 + Iif(ValType(oJson["errorMessages"][nMsgPeM]["integrationId"]) != "U", oJson["errorMessages"][nMsgPeM]["integrationId"] , "null" ) + " | " + STR0106 + Iif( ValType(oJson["errorMessages"][nMsgPeM]["code"]) != "U", cValToChar( oJson["errorMessages"][nMsgPeM]["code"] ) , "null" ) + " | " + Iif( ValType(oJson["errorMessages"][nMsgPeM]["message"]) != "U", STR0107 + oJson["errorMessages"][nMsgPeM]["message"], "null" )) )//"ID de integração: "##"Código da validação: "##"Mensagem: "
            Next nMsgPeM
        EndIf
    EndIf

Next nReg

If !lJob .And. !Empty(aLogPeM)
    If lErro
        fMsgErr()
    EndIf
    fMakeLog( { aLogPeM }, aTitle, Nil, Nil, Nil, OemToAnsi(STR0031), "G", "L", Nil, .F.) //"Log de Ocorrências"
EndIf

RestArea(aAreaREF)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fErrorPeM()
Função que mostra os erros de validação do processamento no P&M
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function fErrorPeM()

Local aErroPeM  := {}
Local aLogPeM   := {}
Local aTitle    := { "" }
Local nMsgPeM   := 0
Local oJson     := Nil

If REF->REF_STATUS == "3"
    oJson := JsonObject():New()
    oJson:fromJson( REF->REF_RETORN )
    aErroPeM := oJson["errorMessages"]
    For nMsgPeM := 1 To Len(aErroPeM)
        FiltraLog( aLogPeM, STR0105 + Iif(ValType(aErroPeM[nMsgPeM]["integrationId"]) != "U", aErroPeM[nMsgPeM]["integrationId"] , "null" ) + " | " + STR0106 + Iif( ValType(aErroPeM[nMsgPeM]["code"]) != "U", cValToChar( aErroPeM[nMsgPeM]["code"] ) , "null" ) + " | " + Iif( ValType(aErroPeM[nMsgPeM]["message"]) != "U", STR0107 + aErroPeM[nMsgPeM]["message"], "null" ) )//"ID de integração: "##"Código da validação: "##"Mensagem: "
    Next nMsgPeM

    fMakeLog( { aLogPeM }, aTitle, Nil, Nil, Nil, OemToAnsi(STR0031), "G", "L", Nil, .F.) //"Log de Ocorrências"
Else
    Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0144), 1, 0 )//"Atenção"###"O lote não possui erro retornado pelo P&M."
EndIf

Return

/*/{Protheus.doc} FiltraLog
//Função que quebra o texto para gravação no log
@author paulo.inzonha
@since 25/07/2019
@version 1.0
@return NIL
@param aLogCalc, array, Array que deve ser preenchido com a mensagem do log
@param cTexto, characters, Texto que deve ser apresentado no log
@type function
/*/
Static Function FiltraLog(aLogCalc, cTexto)
Local nPos := 0

If Len(Alltrim(cTexto)) >= 210
	nPos := At(" ",cTexto,200)
	If nPos > 0
		aAdd(aLogCalc, substr(cTexto,1,nPos))
		aAdd(aLogCalc, substr(cTexto,nPos))
	Else
		aAdd(aLogCalc, substr(cTexto,1,209))
		aAdd(aLogCalc, substr(cTexto,210))
	EndIf
Else
	aAdd(aLogCalc, cTexto)
EndIf

Return( NIL )

//-------------------------------------------------------------------
/*/{Protheus.doc} f939BTDN()
Função para abrir página de documentação do TDN
@author  Allyson Luiz Mesashi
@since   12/05/2022
/*/
//-------------------------------------------------------------------
Function f939BTDN( nPag )

If nPag == 1
    ShellExecute( "open", "https://tdn.totvs.com/pages/viewpage.action?pageId=680969647", "", "", 1 )
Else
    ShellExecute( "open", "https://tdn.totvs.com/pages/viewpage.action?pageId=676047532", "", "", 1 )
EndIf

Return
