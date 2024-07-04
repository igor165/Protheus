#include "totvs.ch"
#include "fileIO.ch"
#include "protheus.ch"

#define crlf chr( 13 ) + chr( 10 )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CLASS PLSXmlPTU
Classe PLSXmlPTU para geracao de arquivos XML PTU Batch

@author    renan.almeida
@version   1.xx
@since     04/09/2019
/*/
//------------------------------------------------------------------------------------------
CLASS PLSXmlPTU
    
    Data cNameSpace as String //NameSpace do arquivo
    Data cStrHash   as String //String que vai ser utilizada para calculo do hash
    Data cXml       as String //String do Arquivo XML
    Data cHashMD5   as String //Hash MD5 calculado 
    Data cFolder    as String //Pasta onde sera gravado o arquivo XML
    Data cFileName  as String //Nome do arquivo XML gerado  
    Data cErroXML   as String //Mensagem de erro na geracao arquivo XML
    Data cAvisoXML  as String //Mensagem de aviso na geracao arquivo XML
    Data cSchmFolde as String //Pasta com os schemas
    Data cSchema    as String //Arquivo de Schema
    Data cVersao    as String //Versao do Schema
    Data lAuto      as Boolean //Indica se a chamada da rotina e via automacao de testes
    Data lCritTag   as Boolean //Indica se irá criticar tag
    Data aCriticas  as Array   //Array com criticas 
    Data cLayPTU    as String //Indica o PTU que esta sendo gerado (ex: 00500, 00041)

    Method New() CONSTRUCTOR
    Method MontaTag(nSpc,cTag,cVal,lIni,lFin,lPerNul,lRetPto)
    Method IniFile(cTag,cEncod)
    Method CalcHash()
    Method ValidXML()
    Method GeraXML()
    Method AddCritica(cCritica)
    Method exibeCrit()
    Method geraHASHtmp()
    
ENDCLASS

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe PLSXmlPTU

@author    renan.almeida
@version   1.xx
@since     04/09/2019
/*/
//------------------------------------------------------------------------------------------
Method New() CLASS PLSXmlPTU
    self:cNameSpace := "ptu"
    self:cStrHash   := ""
    self:cXml       := ""
    self:cHashMD5   := ""
    self:cFolder    := ""
    self:cFileName  := ""
    self:cErroXML   := ""
    self:cAvisoXML  := ""
    self:cSchmFolde := "\plsptu\schemas\"
    self:cSchema    := ""
    self:cVersao    := "V1_0"
    self:lAuto      := .f.
    self:lCritTag   := .t.
    self:aCriticas  := {}
    self:cLayPTU    := ""

Return self

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaTag
Monta uma tag no objeto PTU

@author    Gabriel Hegler Klok
@version   1.1
@since     06/01/2020
/*/
//------------------------------------------------------------------------------------------
Method MontaTag(nSpc,cTag,cVal,lObrigat,lIni,lFin,lPerNul,lRetPto,lHash,cTxtCrit) CLASS PLSXmlPTU
   	Local cRetTag    := ""
    Local cNameSpace := ""
    Local nLinha     
    Default nSpc     := 0
    Default cTag     := ""
    Default cVal     := ""
    Default lObrigat := .F.
    Default lIni     := .F.
    Default lFin     := .F.
    Default lPerNul  := .F.
    Default lRetPto  := .F.
    Default lHash    := .t.
    Default cTxtCrit := ""
    
    if !Empty(::cNameSpace)
        cNameSpace := ::cNameSpace+":"
    endIf

	if !Empty(cVal) .Or. lPerNul .Or. lIni .Or. lFin
        cVal := iif(lRetPto,Alltrim(PlRetPonto(cVal)),Alltrim(cVal)) 
		
        if lIni // Inicializa a tag ?
			cRetTag += '<' + cNameSpace+ cTag + '>'
			cRetTag += allTrim(cVal)
		
        elseIf lFin // Finaliza a tag ?
			cRetTag += '</' + cNameSpace + cTag + '>'
		
        elseIf !Empty(cVal)
            cRetTag += '<' + cNameSpace+ cTag + '>'+cVal+'</' + cNameSpace + cTag + '>'
        endIf

        if lHash 
            ::cStrHash += cVal
        endIf    
        ::cXml  += Replicate( "	", nSpc ) + cRetTag + crlf

        self:geraXML()
        self:geraHASHtmp()

    endIf

    if empty(cVal) .And. lObrigat .and. ::lCritTag
        nLinha := MLCount(::cXml,250)
        self:AddCritica("<" + cTag + "> - A tag obrigatória não foi preenchida. Linha: "+Alltrim(STR(nLinha)))
        IIF(!Empty(cTxtCrit),self:AddCritica(Space(10)+"Solução: " + left(cTxtCrit,101)),)
        IIF(!Empty(Substr(cTxtCrit,101,101)),self:AddCritica(Substr(cTxtCrit,101,101)),)// Informa o texto da solução da critica quando for passado por parametro 
    endIf
		
return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IniFile
Monta uma tag no objeto PTU

@author    renan.almeida
@version   1.xx
@since     04/09/2019
/*/
//------------------------------------------------------------------------------------------
Method IniFile(cTag,cEncod) CLASS PLSXmlPTU
    
    Local cNameSpace := ""
    DEFAULT cEncod := "UTF-8"
    
    if !Empty(::cNameSpace)
        cNameSpace := ::cNameSpace+":"
    endIf

    ::cXml += '<?xml version="1.0" encoding="' + cEncod + '"?>' + crlf

    ::cXml += '<' + cNameSpace+cTag + ' xsi:schemaLocation="http://ptu.unimed.coop.br/schemas/'  + self:cVersao + ;
            self:cSchema + '" xmlns:' + self:cNameSpace + '="http://ptu.unimed.coop.br/schemas/' + self:cVersao + ;
            '" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> '
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CalcHash
Calcula o Hash MD5 do arquivo

@author    Gabriel Hegler Klok
@version   1.1
@since     06/01/2020
/*/
//------------------------------------------------------------------------------------------
Method CalcHash() CLASS PLSXmlPTU
    local nHdlLog

    self:geraHASHtmp(.t.)

    nHdlLog := ft_fuse(::cFolder + ::cFileName + "_HASHTMP")
    ft_fgotop()
    while ! ft_feof()
        ::cStrHash += ft_freadln()
        ft_fskip()
    enddo
    ft_fuse()

    ferase(::cFolder + ::cFileName + "_HASHTMP",nil, .f.)

    ::cHashMD5 := lower(Upper( MD5(::cStrHash,2) ))
return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidXML
Valida arquivo XML

@author    renan.almeida
@version   1.xx
@since     04/09/2019
/*/
//------------------------------------------------------------------------------------------
Method ValidXML() CLASS PLSXmlPTU
    Local lRet   := .T.
    Local cErro  := ''
    Local cAviso := ''
    
    if !XmlSVldSch( ::cXml, ::cSchmFolde + ::cSchema, @cErro,@cAviso)
        ::cErroXML  := iif( !Empty(cErro),"Erro: " +cErro,"")
        ::cAvisoXML := iif( !Empty(cAviso),"Aviso: "+cAviso,"")
        lRet := .F.
    endIf

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraXML
Calcula o Hash MD5 do arquivo

@author    Gabriel Hegler Klok
@version   1.1
@since     06/01/2020
/*/
//------------------------------------------------------------------------------------------
Method GeraXML(lFim,lForca) CLASS PLSXmlPTU
    local nHdlLog
    default lFim    := .f.
    default lForca  := .f. //Força a criação de um novo arquivo sempre.

    //verificar se a string esta maior que 1mb
    if len(::cXml) > 1000000 .or. lFim

        if !file(::cFolder + ::cFileName) .or. lForca
            if (nHdlLog := fCreate(::cFolder + ::cFileName, FC_NORMAL, nil, .f.)) == -1
                return
            endIf
        else
            if (nHdlLog := fOpen(::cFolder + ::cFileName, FO_READWRITE)) == -1
                return
            endIf
        endIf

        fSeek(nHdlLog,0,2)
        fWrite(nHdlLog,::cXml)
        fClose(nHdlLog)

        ::cXml := ''
    endIf
return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddCritica
Adiciona uma critica de processamento ao objeto

@author    renan.almeida
@version   1.xx
@since     04/09/2019
/*/
//------------------------------------------------------------------------------------------
Method AddCritica(cCritica) CLASS PLSXmlPTU

    aadd(::aCriticas,{cCritica})

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} exibeCrit
Monta tela com as criticas do processo

@author    renan.almeida
@version   1.xx
@since     12/09/2019
/*/
//------------------------------------------------------------------------------------------
Method exibeCrit() CLASS PLSXmlPTU

    PLSCRIGEN(::aCriticas,{ {"Críticas encontradas no processamento:","@C",200} },"Não foi possível gerar o arquivo PTU " + ::cLayPTU)

return


/*/{Protheus.doc} geraHASHTmp
Realiza a gravacao dos dados para montar a HASH em um arquivo temporario.

@author Gabriel Hegler Klok
@version 1.xx
@since 06/01/2020

@param lFim, boolean, Indica se é ultimo dado para a HASH forcando esvaziar o buffer para o arquivo.
/*/
Method geraHASHtmp(lFim) class PLSXmlPTU
    local nHdlLog
    default lFim := .f.

    if len(::cStrHash) > 1000000 .or. lFim

        if ! file(::cFolder + ::cFileName + "_HASHTMP")
            if (nHdlLog := fCreate(::cFolder + ::cFileName + "_HASHTMP", FC_NORMAL, nil, .f.)) == -1
                return
            endIf
        else
            if (nHdlLog := fOpen(::cFolder + ::cFileName + "_HASHTMP", FO_READWRITE)) == -1
                return
            endIf
        endIf

        fSeek(nHdlLog,0,2)
        fWrite(nHdlLog,::cStrHash)
        fClose(nHdlLog)

        ::cStrHash := ''
    endIf
return 
