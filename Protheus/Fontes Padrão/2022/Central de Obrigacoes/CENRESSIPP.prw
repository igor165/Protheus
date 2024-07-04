#include "protheus.ch"
#include "fwmvcdef.ch"

#define PB3LPMATRIC 1
#define PB3LPBENEF 2
#define PB3LPCODTAB 3
#define PB3LPCODPRO 4
#define PB3LPQTDPRO 5
#define PB3LPDATEVE 6
#define PB3LPVLRPRO 7
#define PB3LPCLASSH 8
#define CAMPO 1
#define TIPO 2
#define TAMANHO 3
#define DECIMAL 4

static lB3L_CLASSH := .f.
static lClassh

/*/{Protheus.doc} cenResSipP
Tela responsável por mostrar os procedimentos de uma guia, em determinada classficação do SIP.

@author Gabriel H. Klok

@type function
@since 07/06/2020
@version 1.0

@param cCodCla, character, Codigo da classaficação desejada.
@param cCodOpe, character, Codigo da operadora.
@param cYear, character, Ano da competência.
@param cCodObr, character, Codigo da obrigação no ano selecionado.
@param cGuia, character, Numero da guia.
@param cMatric, character, Matricula do beneficiario.

@return oBrw, object, Instancia da classe 'FwMBrowse'.
/*/
function cenResSipP(lAuto, cCodCla, cCodOpe, cYear, cCodComp, cGuia, cMatric, cCdObri)
    local oBrw
    local aFields
    local oTableTmp
    local cAliasTbTmp

    default lAuto := .f.
    default cCodCla := ""
    default cCodOpe := ""
    default cYear := ""
    default cCodComp := ""
    default cGuia := ""
    default cMatric := ""
    default cCdObri := ""
    default lInter := .f.

    lClassh := upper(alltrim(cCodCla)) == "H"
    lB3L_CLASSH := B3L->(fieldpos("B3L_CLASSH")) > 0

    oBrw := fwmbrowse():new()
    aFields := getFields(cCodCla)
    oTableTmp := createTableTemp(aFields)
    cAliasTbTmp := getnextalias()

    if getProcedimentos(cAliasTbTmp, cCodCla, cCodOpe, cYear, cCodComp, cGuia, cMatric, cCdObri)
        insertProcedimentos(cAliasTbTmp, cCodCla)
    endif

    oBrw:setdescription("Procedimentos classificados como " + alltrim(cCodCla) + " na guia " + alltrim(cGuia) )
    oBrw:setalias( oTableTmp:getalias() )
    oBrw:setfields( mountFields(aFields, cCodCla) )
    oBrw:setprofileID("CENRESSIPP")
    oBrw:setmenudef("CENRESSIPP")
    oBrw:disabledetails()
    oBrw:setwalkthru(.f.)
	oBrw:setambiente(.f.)
    oBrw:forcequitbutton()

    if ! lAuto
        oBrw:activate()
    endif

    oTableTmp:delete()
return oBrw


/*/{Protheus.doc} menudef
Menu personalizado da tela de guias.

@author Gabriel H. Klok

@type static function
@since 15/06/2020
@version 1.0

@return aRotina, array, Array contendo as opções de menu adicionadas.
/*/
static function menuDef()
    local aRotina := {}

    ADD OPTION aRotina TITLE "Voltar" ACTION "closebrowse()" OPERATION 2 ACCESS 0
    if lB3L_CLASSH .and. lClassh
        ADD OPTION aRotina TITLE "Origem classificação" ACTION "staticcall(CENRESSIPP, oriClaH)" OPERATION 2 ACCESS 0
    endif
return aRotina


/*/{Protheus.doc} createTableTemp
Realiza a criação da tabela temporária que servira de base para mostrar os dados
dos procedimentos na tela para o usua?io.

@author Gabriel H. Klok

@type static function
@since 07/06/2020
@version 1.0

@param aFields, array, Array contendo os campos que iram compor a tabela.

@return oTableTmp, object, Instancia da classe 'FwTemporaryTable' criada.
/*/
static function createTableTemp( aFields )
    local oTableTmp := nil 
    default aFields := {}

    oTableTmp := fwtemporarytable():new("PROB3L")
    oTableTmp:setfields(aFields)
    oTableTmp:addindex("01",{"MATRIC","BENEF","CODTAB","CODPRO"})
    oTableTmp:create()

return oTableTmp 


/*/{Protheus.doc} getFields
Definição dos campos da tabela temporária que será criada para exibir os dados.

@author Gabriel H. Klok

@type static function
@since 07/06/2020
@version 1.0

@return aFields, array, Array contendo a configuração dos campos.
/*/
static function getFields(cClaSip)
    local aFields 

    aFields := {}
    aadd(aFields, {"MATRIC", "C", 016, 0})
    aadd(aFields, {"BENEF", "C", 050, 0})
    aadd(aFields, {"CODTAB", "C", 002, 0})
    aadd(aFields, {"CODPRO", "C", 016, 0})
    aadd(aFields, {"QTDPRO", "N", 010, 0})
    aadd(aFields, {"DATEVE", "D", 8, 0})
    aadd(aFields, {"VLRPRO", "N", 016, 2})
    if rtrim(cClaSip) == "H" .and. lB3L_CLASSH
        aadd(aFields, {"CLASSH", "C", 1000, 0})
    endif 

return aFields


/*/{Protheus.doc} getProcedimentos
Função realiza a consulta no banco de dados para obter os procedimentos de
determinada guia em uma classificação desejada.

@author Gabriel H. Klok

@type static function
@since 07/06/2020
@version 1.0

@param cAliasTbTmp, character, Alias para retorno da consulta.
@param cCodCla, character, Codigo da classaficação desejada.
@param cCodOpe, character, Codigo da operadora.
@param cYear, character, Ano da competência.
@param cCodComp, character, Codigo da obrigação no ano selecionado.
@param cGuia, character, Numero da guia.
@param cMatric, character, Matricula do beneficiario.

@return status, logical, Retorna um logico indicando se houve retorno de dados.
/*/
static function getProcedimentos(cAliasTbTmp, cCodCla, cCodOpe, cYear, cCodComp, cGuia, cMatric, cCdObri)
    local cClassH := "% %"

    cCodCla := alltrim(cCodCla) + "%"
    cGuia := alltrim(cGuia)
    cMatric := alltrim(cMatric)
    
    if lB3L_CLASSH
        cClassH := "%, CAST(B3L_CLASSH AS VARCHAR(1000)) B3L_CLASSH %"
    endif 

    beginsql alias cAliasTbTmp
        SELECT B3L_MATRIC, B3K_NOMBEN, B3L_CDTPTB, B3L_CODEVE, B3L_QTDEVE, B3L_DATEVE, B3L_VLREVE %exp:cClassH%
        FROM %table:B3L% B3L

            INNER JOIN %table:B3K% B3K
                ON B3K.B3K_FILIAL = B3L.B3L_FILIAL 
                AND B3K.B3K_CODOPE = B3L.B3L_CODOPE 
                AND B3K.B3K_MATRIC = B3L.B3L_MATRIC 
                AND B3K.%notdel%

        WHERE  B3L.B3L_FILIAL = %xfilial:B3L% 
            AND B3L.B3L_CODOPE = %exp:cCodOpe% 
            AND B3L.B3L_CODOBR = %exp:cCdObri% 
            AND B3L.B3L_ANOCMP = %exp:cYear% 
            AND B3L.B3L_CDCOMP = %exp:cCodComp% 
            AND B3L.B3L_MATRIC = %exp:cMatric%
            AND B3L.B3L_EVEDES = %exp:cGuia%
            AND B3L.B3L_EVDEIN = ''
            AND B3L.B3L_CLAAMB LIKE %exp:cCodCla% 
            AND B3L.%notdel%

        UNION ALL 

        SELECT B3L_MATRIC, B3K_NOMBEN, B3L_CDTPTB, B3L_CODEVE, B3L_QTDEVE, B3L_DATEVE, B3L_VLREVE %exp:cClassH%
        FROM %table:B3L% B3L

            INNER JOIN %table:B3K% B3K
                ON B3K.B3K_FILIAL = B3L.B3L_FILIAL 
                AND B3K.B3K_CODOPE = B3L.B3L_CODOPE 
                AND B3K.B3K_MATRIC = B3L.B3L_MATRIC 
                AND B3K.%notdel%

        WHERE  B3L.B3L_FILIAL = %xfilial:B3L% 
            AND B3L.B3L_CODOPE = %exp:cCodOpe% 
            AND B3L.B3L_CODOBR = %exp:cCdObri% 
            AND B3L.B3L_ANOCMP = %exp:cYear% 
            AND B3L.B3L_CDCOMP = %exp:cCodComp% 
            AND B3L.B3L_MATRIC = %exp:cMatric%
            AND B3L.B3L_EVEDES = %exp:cGuia%
            AND B3L.B3L_EVDEIN <> ''
            AND B3L.B3L_CLAINT LIKE %exp:cCodCla% 
            AND B3L.%notdel%
    endsql
return iif((cAliasTbTmp)->(eof()), .f., .t.) 


/*/{Protheus.doc} insertProcedimentos
Realiza a insersão dos dados retornados pela consulta ao banco de dados na
tabela temporária criada.

@author Gabriel H. Klok

@type static function
@since 07/06/2020
@version 1.0

@param cAliasTbTmp, character, Alias para manipular o retorno da consulta realizada ao banco de dados.
/*/
static function insertProcedimentos(cAliasTbTmp, cClaSip)
    (cAliasTbTmp)->(dbgotop())
    while ! (cAliasTbTmp)->(eof())
        reclock("PROB3L", .t.)

        PROB3L->MATRIC := (cAliasTbTmp)->B3L_MATRIC
        PROB3L->BENEF := (cAliasTbTmp)->B3K_NOMBEN
        PROB3L->CODTAB := (cAliasTbTmp)->B3L_CDTPTB
        PROB3L->CODPRO := (cAliasTbTmp)->B3L_CODEVE
        PROB3L->QTDPRO := (cAliasTbTmp)->B3L_QTDEVE
        PROB3L->DATEVE := stod((cAliasTbTmp)->B3L_DATEVE)
        PROB3L->VLRPRO := (cAliasTbTmp)->B3L_VLREVE
        if rtrim(cClaSip) == "H" .and. lB3L_CLASSH
            PROB3L->CLASSH := (cAliasTbTmp)->B3L_CLASSH
        endif 

        PROB3L->(msunlock())

        (cAliasTbTmp)->(dbskip())
    enddo 
    (cAliasTbTmp)->(dbclosearea())
return 


/*/{Protheus.doc} mountFields

Carrega os campos do browse de vencimentos 

@author everton.mateus
@since 15/11/2018
/*/
Static Function mountFields(aCampos, cClaSip)

	Local cPicture := "@!"
	Local nAlign   := 1 
	Local aFields  := {}

	aAdd(aFields,GetColuna(aCampos[PB3LPMATRIC,CAMPO]	,"Matricula"    		,aCampos[PB3LPMATRIC,TIPO]	,cPicture           ,nAlign,aCampos[PB3LPMATRIC,TAMANHO],aCampos[PB3LPMATRIC,DECIMAL] ))
	aAdd(aFields,GetColuna(aCampos[PB3LPBENEF,CAMPO]	,"Beneficiario "	    ,aCampos[PB3LPBENEF,TIPO]	,cPicture           ,nAlign,aCampos[PB3LPBENEF,TAMANHO] ,aCampos[PB3LPBENEF,DECIMAL]	))
    aAdd(aFields,GetColuna(aCampos[PB3LPCODTAB,CAMPO]	,"Tabela "			    ,aCampos[PB3LPCODTAB,TIPO]	,cPicture           ,nAlign,aCampos[PB3LPCODTAB,TAMANHO],aCampos[PB3LPCODTAB,DECIMAL]	))
    aAdd(aFields,GetColuna(aCampos[PB3LPCODPRO,CAMPO]	,"Cod. Procedimento "	,aCampos[PB3LPCODPRO,TIPO]	,cPicture           ,nAlign,aCampos[PB3LPCODPRO,TAMANHO],aCampos[PB3LPCODPRO,DECIMAL]	))
    aAdd(aFields,GetColuna(aCampos[PB3LPQTDPRO,CAMPO]	,"Quantidade "			,aCampos[PB3LPQTDPRO,TIPO]	,"@E 99999"         ,nAlign,aCampos[PB3LPQTDPRO,TAMANHO],aCampos[PB3LPQTDPRO,DECIMAL]	))
    aAdd(aFields,GetColuna(aCampos[PB3LPDATEVE,CAMPO]	,"Data Procedimento "   ,aCampos[PB3LPDATEVE,TIPO]	,"@D"               ,nAlign,aCampos[PB3LPDATEVE,TAMANHO],aCampos[PB3LPDATEVE,DECIMAL]	))
	aAdd(aFields,GetColuna(aCampos[PB3LPVLRPRO,CAMPO]	,"Vlr Procedimento"		,aCampos[PB3LPVLRPRO,TIPO]	,"@E 999,999,999.99",nAlign,aCampos[PB3LPVLRPRO,TAMANHO],aCampos[PB3LPVLRPRO,DECIMAL]	))
    if rtrim(cClaSip) == "H" .and. lB3L_CLASSH 
        aAdd(aFields,GetColuna(aCampos[PB3LPCLASSH,CAMPO]	,"Origem classificação"		,aCampos[PB3LPCLASSH,TIPO]	,cPicture,nAlign,aCampos[PB3LPCLASSH,TAMANHO],aCampos[PB3LPCLASSH,DECIMAL]	))
    endif 

Return aFields 


/*/{Protheus.doc} GetColuna

Retorna uma coluna para o markbrowse 

@author everton.mateus
@since 15/11/2018
/*/
Static Function GetColuna(cCampo,cTitulo,cTipo,cPicture,nAlign,nSize,nDecimal)

	Local   aColuna  := {}
	Local   bData    := &("{||" + cCampo +"}") 
	Default nAlign   := 1
	Default nSize    := 20
	Default nDecimal := 0
	Default cTipo    := "C"
	
	aColuna := {cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.T.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return aColuna


/*/{Protheus.doc} oriClaH
Mostra a origem da classificação em uma modal, pois na tela a descrição pode cortar.

@author Gabriel H Klok

@type static function
@since 30/07/2020
@version 1.0
/*/
static function oriClaH()
    msginfo( iif(empty(PROB3L->CLASSH), "Sem descrição, provavelmente o registro já existia na base de dados.", PROB3L->CLASSH), "Descrição")
return 
