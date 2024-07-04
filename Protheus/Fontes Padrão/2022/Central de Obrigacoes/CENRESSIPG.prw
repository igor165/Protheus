#include "protheus.ch"
#include "fwmvcdef.ch"

#define PB3LGUIA 1
#define PB3LMATRIC 2
#define PB3LBENEF 3
#define PB3LVLRCLA 4
#define PB3LVLRGUI 5
#define CAMPO 1
#define TIPO 2
#define TAMANHO 3
#define DECIMAL 4

static cClasip

/*/{Protheus.doc} cenressipg
Tela responsável por mostrar as guias presentes em determinada classificação do SIP,
acessada pela rotina de 'Resumo XML'.

@author Gabriel H. Klok

@type function
@since 05/06/2020
@version 1.0

@return oBrw, object, Objeto da tela.
/*/
function cenResSipG(lAuto, cCla, cWhere)
    local oBrw := fwmbrowse():new()
    local aFields := getFields()
    local oTableTmp := createTableTemp(aFields)
    local cAliasTbTmp := getnextalias()

    default lAuto := .f.
    default cCla := ""
    default cWhere := "% 1 = 1 %"

    cClasip := cCla

    if getGuias(cAliasTbTmp, B3D->B3D_CODOPE, B3D->B3D_ANO, B3D->B3D_CODIGO, alltrim(cClasip) + "%", B3D->B3D_CDOBRI, cWhere)
        insertGuias(cAliasTbTmp)
    endif

    oBrw:setdescription("Guias classificadas como " + alltrim(cClasip))
    oBrw:setalias( oTableTmp:getalias() )
    oBrw:setfields( mountFields(aFields) )
    oBrw:setprofileID("CENRESSIPG")
    oBrw:setmenudef("CENRESSIPG")
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
@since 05/06/2020
@version 1.0

@return aRotina, array, Array contendo as opções de menu adicionadas.
/*/
static function menuDef()
    local aRotina := {}

    ADD OPTION aRotina TITLE "Procedimentos" ACTION "staticcall(CENRESSIPG, detailProcedimento)" OPERATION 2 ACCESS 0
return aRotina


/*/{Protheus.doc} detailProcedimento
Realiza a chamada da tela dos procedimentos das guias.

@author Gabriel H. Klok

@type static function
@since 05/06/2020
@version 1.0
/*/
static function detailProcedimento()
    cenResSipP(.f., cClasip, B3D->B3D_CODOPE, B3D->B3D_ANO, B3D->B3D_CODIGO, GUIB3L->GUIA, GUIB3L->MATRIC, B3D->B3D_CDOBRI)
return 


/*/{Protheus.doc} createTableTemp
Realiza a criação da tabela temporária que servira de base para mostrar os dados
das guias na tela para o usua?io.

@author Gabriel H. Klok

@type static function
@since 05/06/2020
@version 1.0

@param aFields, array, Array contendo os campos que iram compor a tabela.

@return oTableTmp, object, Instancia da classe 'FwTemporaryTable' criada.
/*/
static function createTableTemp( aFields )
    local oTableTmp := nil
    default aFields := {}

    oTableTmp := fwtemporarytable():new("GUIB3L")
    oTableTmp:setfields(aFields)
    oTableTmp:addindex("01",{"GUIA"})
    oTableTmp:create()

return oTableTmp 


/*/{Protheus.doc} getFields
Definição dos campos da tabela temporária que será criada para exibir os dados.

@author Gabriel H. Klok

@type static function
@since 05/06/2020
@version 1.0

@return aFields, array, Array contendo a configuração dos campos.
/*/
static function getFields()
    local aFields

    aFields := {}
    aadd(aFields, {"GUIA", "C", 046, 0})
    aadd(aFields, {"MATRIC", "C", 018, 0})
    aadd(aFields, {"BENEF", "C", 050, 0})
    aadd(aFields, {"VLRCLA", "N", 016, 2})
    aadd(aFields, {"VLRGUI", "N", 016, 2})

return aFields


/*/{Protheus.doc} getGuias
Função realiza a consulta no banco de dados para obter as guias que
compoem determinada classificação.

@author Gabriel H. Klok

@type static function
@since 05/06/2020
@version 1.0

@param cAliasTbTmp, character, Alias para retorno da consulta.
@param cCodOpe, character, Codigo da operadora.
@param cYear, character, Ano da competência.
@param cCodComp, character, Codigo da obrigação no ano selecionado.
@param cClasip, character, Codigo da classaficação desejada.

@return status, logical, Retorna um logico indicando se houve retorno de dados.
/*/
static function getGuias(cAliasTbTmp, cCodOpe, cYear, cCodComp, cClasip, cCodObr, cWhere)
    beginsql alias cAliasTbTmp
        SELECT GUIA.*, SUM(B3LE.B3L_VLREVE) VLRGUI
        FROM (
            SELECT B3L.B3L_CODOPE,
                B3L.B3L_CODOBR,
                B3L.B3L_ANOCMP,
                B3L.B3L_CDCOMP,
                B3L.B3L_MATRIC,
                B3K.B3K_NOMBEN,
                B3L.B3L_EVEDES,
                SUM(B3L.B3L_VLREVE) VLREVE

            FROM %table:B3L% B3L

                INNER JOIN %table:B3K% B3K
                    ON B3K.B3K_FILIAL = B3L.B3L_FILIAL 
                    AND B3K.B3K_CODOPE = B3L.B3L_CODOPE 
                    AND B3K.B3K_MATRIC = B3L.B3L_MATRIC
                    AND B3K.%notdel%

            WHERE B3L.B3L_FILIAL = %xfilial:B3L%
                AND B3L.B3L_CODOPE = %exp:cCodOpe%
                AND B3L.B3L_CODOBR = %exp:cCodObr%
                AND B3L.B3L_ANOCMP = %exp:cYear%
                AND B3L.B3L_CDCOMP = %exp:cCodComp%
                AND B3L.B3L_MATRIC <> B3L.B3L_EVEDES
                AND B3L.B3L_EVDEIN = ''
                AND B3L.B3L_CLAAMB LIKE %exp:cClasip%
                AND %exp:cWhere%
                AND B3L.%notdel%

            GROUP BY B3L.B3L_CODOPE,
                B3L.B3L_CODOBR,
                B3L.B3L_ANOCMP,
                B3L.B3L_CDCOMP,
                B3L.B3L_MATRIC,
                B3K.B3K_NOMBEN,
                B3L.B3L_EVEDES

            UNION ALL 

            SELECT B3L.B3L_CODOPE,
                B3L.B3L_CODOBR,
                B3L.B3L_ANOCMP,
                B3L.B3L_CDCOMP,
                B3L.B3L_MATRIC,
                B3K.B3K_NOMBEN,
                B3L.B3L_EVEDES,
                SUM(B3L.B3L_VLREVE) VLREVE

            FROM %table:B3L% B3L

                INNER JOIN %table:B3K% B3K
                    ON B3K.B3K_FILIAL = B3L.B3L_FILIAL 
                    AND B3K.B3K_CODOPE = B3L.B3L_CODOPE 
                    AND B3K.B3K_MATRIC = B3L.B3L_MATRIC
                    AND B3K.D_E_L_E_T_ = ' '

            WHERE B3L.B3L_FILIAL = %xfilial:B3L%
                AND B3L.B3L_CODOPE = %exp:cCodOpe%
                AND B3L.B3L_CODOBR = %exp:cCodObr%
                AND B3L.B3L_ANOCMP = %exp:cYear%
                AND B3L.B3L_CDCOMP = %exp:cCodComp%
                AND B3L.B3L_MATRIC <> B3L.B3L_EVEDES
                AND B3L.B3L_EVDEIN <> ''
                AND B3L.B3L_CLAINT LIKE %exp:cClasip%
                AND %exp:cWhere%
                AND B3L.D_E_L_E_T_ = ' '

            GROUP BY B3L.B3L_CODOPE,
                B3L.B3L_CODOBR,
                B3L.B3L_ANOCMP,
                B3L.B3L_CDCOMP,
                B3L.B3L_MATRIC,
                B3K.B3K_NOMBEN,
                B3L.B3L_EVEDES
        ) GUIA

            INNER JOIN %table:B3L% B3LE
                ON B3LE.B3L_FILIAL = %xfilial:B3L%
                AND B3LE.B3L_CODOPE = GUIA.B3L_CODOPE 
                AND B3LE.B3L_CODOBR = GUIA.B3L_CODOBR
                AND B3LE.B3L_ANOCMP = GUIA.B3L_ANOCMP
                AND B3LE.B3L_CDCOMP = GUIA.B3L_CDCOMP
                AND B3LE.B3L_MATRIC = GUIA.B3L_MATRIC
                AND B3LE.B3L_EVEDES = GUIA.B3L_EVEDES
                AND B3LE.%notdel%

        GROUP BY GUIA.B3L_CODOPE,
                GUIA.B3L_CODOBR,
                GUIA.B3L_ANOCMP,
                GUIA.B3L_CDCOMP,
                GUIA.B3L_MATRIC,
                GUIA.B3K_NOMBEN,
                GUIA.B3L_EVEDES,
                GUIA.VLREVE

    endsql
return iif((cAliasTbTmp)->(eof()), .f., .t.)


/*/{Protheus.doc} insertGuias
Realiza a insersão dos dados retornados pela consulta ao banco de dados na
tabela temporária criada.

@author Gabriel H. Klok

@type static function
@since 05/06/2020
@version 1.0

@param cAliasTbTmp, character, Alias para manipular o retorno da consulta realizada ao banco de dados.
/*/
static function insertGuias(cAliasTbTmp)
    (cAliasTbTmp)->(dbgotop())
    while ! (cAliasTbTmp)->(eof())
        reclock("GUIB3L", .t.)

        GUIB3L->GUIA := (cAliasTbTmp)->B3L_EVEDES
        GUIB3L->MATRIC := (cAliasTbTmp)->B3L_MATRIC
        GUIB3L->BENEF := (cAliasTbTmp)->B3K_NOMBEN
        GUIB3L->VLRCLA := (cAliasTbTmp)->VLREVE
        GUIB3L->VLRGUI := (cAliasTbTmp)->VLRGUI

        GUIB3L->(msunlock())

        (cAliasTbTmp)->(dbskip())
    enddo 
    (cAliasTbTmp)->(dbclosearea())
return 


/*/{Protheus.doc} mountFields

Carrega os campos do browse de vencimentos 

@author everton.mateus
@since 15/11/2018
/*/
Static Function mountFields(aCampos)

	Local cPicture := "@!"
	Local nAlign   := 1 
	Local aFields  := {}

	aAdd(aFields,GetColuna(aCampos[PB3LGUIA,CAMPO]		,"Guia"  					,aCampos[PB3LGUIA,TIPO] 	,cPicture,nAlign,aCampos[PB3LGUIA,TAMANHO] 		,aCampos[PB3LGUIA,DECIMAL]		))
	aAdd(aFields,GetColuna(aCampos[PB3LMATRIC,CAMPO]	,"Matricula"    			,aCampos[PB3LMATRIC,TIPO]	,cPicture,nAlign,aCampos[PB3LMATRIC,TAMANHO]	,aCampos[PB3LMATRIC,DECIMAL]	))
	aAdd(aFields,GetColuna(aCampos[PB3LBENEF,CAMPO]	    ,"Beneficiario "			,aCampos[PB3LBENEF,TIPO]	,cPicture,nAlign,aCampos[PB3LBENEF,TAMANHO]	    ,aCampos[PB3LBENEF,DECIMAL]	    ))
	aAdd(aFields,GetColuna(aCampos[PB3LVLRCLA,CAMPO]	,"Vlr. da Classificacao" 	,aCampos[PB3LVLRCLA,TIPO]	,"@E 999,999,999.99",nAlign,aCampos[PB3LVLRCLA,TAMANHO]	,aCampos[PB3LVLRCLA,DECIMAL]	))
	aAdd(aFields,GetColuna(aCampos[PB3LVLRGUI,CAMPO]	,"Vlr total da guia"		,aCampos[PB3LVLRGUI,TIPO]	,"@E 999,999,999.99",nAlign,aCampos[PB3LVLRGUI,TAMANHO]	,aCampos[PB3LVLRGUI,DECIMAL]	))

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
