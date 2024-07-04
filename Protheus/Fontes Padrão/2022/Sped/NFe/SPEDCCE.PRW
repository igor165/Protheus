#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "SPEDCCE.CH" //TODO:Criar o arquivo no ATUSX

//-----------------------------------------------------------------------
/*/{Protheus.doc} CCeExpoArq
Função responsavel por gerar os arquivos de XML e PDF de acordo com o
passado por parametro

@author felipe Sale Martinez
@since 07/10/2021
@version 1.0
@param	cOpcExp	    0-XML e PDF, 1-XML, 2-PDF
		cDestino	Diretorio onde sera gravado os arquivos
        cIdEnt      Codigo da entidade para consulta no TSS
        cChvIni     Numero da chave inicial
        cChvFin     Numero da chave final
@return	NIL
/*/
//-----------------------------------------------------------------------
function CCeExpoArq(cOpcExp, cDestino, cIdEnt, cChvIni, cChvFin)
local oWS           := nil
local lShowReg      := FWIsInCallStack("Processa") .and. !isBlind()
local cPDF          := ""
local cXml          := ""
local cIdCCe        := ""
local cNFes         := ""
local cErro         := ""
local cDocOk        := ""
local cDocErro      := ""
local cAviso        := ""
local cURL          := PadR(GetNewPar("MV_SPEDURL","http://"),250)
local nI            := 0
local nTot          := 0
local lPDFCust      := existBlock("CCEPDF")
local xXML          := .F.
local xPDF          := .F.

private oCCe        := nil
private oRetorno    := nil
private oXmlExp     := nil

oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN	:= "TOTVS"
oWS:cID_ENT		:= cIdEnt
oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
oWS:cChvInicial	:= cChvIni
oWS:cChvFinal	:= cChvFin
oWS:cTipo       := iif(lPDFCust,"1", cOpcExp) //para o metodo TSS: 0 - Todos (XML e PDF) / 1 - XML / 2 - PDF

iif(lShowReg,procRegua(1),nil)
iif(lShowReg,IncProc(STR0001),nil) //Realizando consulta da(s) carta(s) de correção...

if oWS:NFeExpEvento()
    
    iif(lShowReg,IncProc(STR0002),nil) //Processando arquivos...

    oRetorno := oWS:oWSNFEEXPEVENTORESULT
    if type("oRetorno:OWSRETEXPEVENTO") <> "U"
        
        nTot := len(oRetorno:OWSRETEXPEVENTO)
        iif(lShowReg,ProcRegua(nTot),nil)

        for nI := 1 to nTot
            oCCe    := oRetorno:OWSRETEXPEVENTO[nI]
            cIdCCe  := oCCe:CID_EVENTO
            cPDF    := oCCe:CPDF
            cXml    := oCCe:CXML
            xXMl    := nil
            xPDF    := nil
            
            iif(lShowReg,IncProc(STR0003 + cValToChar(nI) + "/" + cValToChar(nTot)),nil)//"Processando arquivo "

            //Exportação de XML
            if !(cOpcExp == "2")
                if !empty(cXml)
                    cXml := EncodeUTF8(cXml)
                    oXmlExp := XmlParser(cXml,"_",@cErro,@cAviso)
                    if (ccetype("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE")<>"U") .and. (ccetype("oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE:_INFEVENTO")<>"U")
                        cVerCte := Iif(ccetype("oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE:_VERSAO:TEXT ") <> "U", oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE:_VERSAO:TEXT , '')
                        cCabCTe   := '<procEventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="'+cVerCte+'">'
                        cEventoCTe:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_EVENTO:_EVENTOCTE,.F.)
                        cRetEvento:= XmlSaveStr(oXmlExp:_PROCEVENTONFE:_RETEVENTO:_RETEVENTOCTE,.F.)
                        cRodapCTe := '</procEventoCTe>'
                        cXml := cCabCTe+cEventoCTe+cRetEvento+cRodapCTe
                    endIf

                    xXMl := memoWrite(cDestino+SubStr(cIdCCe,3)+"-cce.xml", cXml)

                else
                    conout(STR0004 + " ["+cIdCCe+"]")// "O arquivo XML da CC-e está em branco
                endIf
            endIf

            //Exportação de PDF
            if !(cOpcExp == "1") 
                if lPDFCust
                    xPDF := execBlock("CCEPDF",.f.,.f.,{cXml})
                else
                    if !empty(cPDF)
                        xPDF := memoWrite(cDestino+SubStr(cIdCCe,3)+"-cce.pdf", deCode64(cPDF))
                    else
                        conout(STR0005 + " ["+cIdCCe+"]")//"O arquivo PDF da CC-e está em branco
                    endIf
                endIf
            endIf

            if valType(xXMl) == "L"
                if xXMl
                    cDocOk += subStr(cIdCCe,31,3) + "/" + subStr(cIdCCe,34,9) + CRLF
                else
                    cDocErro += subStr(cIdCCe,31,3) + "/" + subStr(cIdCCe,34,9) + CRLF
                endIf
            endIf
            if valType(xPDF) == "L"
                if xPDF
                    cDocOk += subStr(cIdCCe,31,3) + "/" + subStr(cIdCCe,34,9) + CRLF
                else
                    cDocErro += subStr(cIdCCe,31,3) + "/" + subStr(cIdCCe,34,9) + CRLF
                endIf
            endIf
            
            freeobj(oCCe)
            oCCe := nil
            freeobj(oXmlExp)
            oXmlExp := nil
        next
        
        if !empty(cDocOk)
            cNFes += STR0006 + CRLF +cDocOk //"Documentos exportados com sucesso: "
        endIf
        if !empty(cDocErro)
            cNFes += iif(empty(cDocOk),"",replic(CRLF, 3))
            cNFes += STR0007 + CRLF +cDocErro //"Documentos não exportados: "
        endIf

        If !empty(cNFes) .and. aviso(STR0008,STR0009 + replic(CRLF,2) + STR0010,{STR0011,STR0012}) == 1// "SPED" - "Solicitação processada." - "Deseja visualizar detalhes do(s) documento(s) exportado(s)?" - "Sim" - "Não"
            Aviso(STR0013, STR0014 + Upper(cDestino) + replic(CRLF,2) + cNFes, {STR0015}, 3)//"Detalhes" - "Diretório destino: " - "OK"
        EndIf
        
        freeobj(oRetorno)
        oRetorno := nil
    endIf

Else
    Aviso(STR0008,IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0015},3) //"SPED" - "OK"
endIf

freeobj(oWS)
oWS := nil

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} CCeExpoPDF
Função responsavel por extrair os dados do registro posicionado e chamar 
a função para exportação dos arquivos

@author felipe Sale Martinez
@since 07/10/2021
@version 1.0
@param	cAlias	    Tabela ativa (SF1 ou SF2)
		nReg    	Numero do registro (RECNO) da tabela
        nOpc        Opção da rotina (Incluir/Alterar/Excluir/Visualizar/etc)
@return	NIL
/*/
//-----------------------------------------------------------------------
function CCeExpoPDF(cAlias, nReg, nOpc)
local cIdEnt    := retIdEnti(UsaColaboracao("1"))
local cCpoTab   := subStr(cAlias,2) + "_CHVNFE"
local cChaveNF  := (cAlias)->&(cCpoTab)
local aParam    := telaParam()

if len(aParam) > 0
    processa({|| CCeExpoArq("2", allTrim(aParam[1]), cIdEnt, cChaveNF, cChaveNF)}, STR0016, STR0017, .F.)//"Aguarde..." - "Exportação de CC-e em PDF em andamento..."
endIf

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} telaParam
Função responsavel apresentar tela para que o usuario informe a pasta de 
destino a ser exportado o arquivo PDF da CCe

@author felipe Sale Martinez
@since 07/10/2021
@version 1.0
@param	NIL
@return	NIL
/*/
//-----------------------------------------------------------------------
static function telaParam()
local aRet  := {}
local aPerg := {}

aadd(aPerg,{6,STR0018,Space(60),"","SpedVldDir(, @mv_par01)","!empty(mv_par01)",80,.T.,"Arquivos XML |*.XML","",GETF_RETDIRECTORY+GETF_LOCALHARD,.T.}) //"Diretório de destino"

paramBox(aPerg,STR0019,@aRet,,,,,,,SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDCCEEXP",.T.,.T.)//"SPED - NFe"

return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ccetype
Função responsavel por retornar o conteudo de uma variavel private. Seu 
uso é exclusivo para nao ser apontado como debito tecnico no SONARQUBE

@author felipe Sale Martinez
@since 07/10/2021
@version 1.0
@param	xTag    TAG do XML a ser avalida
@return	Tipo do dado a ser avaliado
/*/
//-----------------------------------------------------------------------
static function ccetype(xTag)
return type(xTag)
