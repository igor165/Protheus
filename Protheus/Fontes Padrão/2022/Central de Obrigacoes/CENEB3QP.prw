#include "protheus.ch"
#include "fwmvcdef.ch"

#define M_ALFA "@!"
#define M_DATE
#define M_NUMF "@E 999,999,999.99"

#define ALIGN_LEFT 1

#define FIELD 1
#define TYPE 2
#define SIZE 3
#define DECIMAL 4

#define PANOCMP 1
#define PCDCOMP 2
#define PEVEDES 3
#define PCDTPTB 4
#define PCODEVE 5
#define PDATEVE 6
#define PQTDEVE 7
#define PVLREVE 8
#define PCLAAMB 9
#define PCLAINT 10
#define PGRPINT 11
#define PREGINT 12
#define PDATINT 13
#define PHORINT 14
#define PDATALT 15
#define PHORALT 16
#define PFORCON 17
#define PSEGMEN 18
#define PEVDEIN 19
#define PCLASSH 20

static lB3QCLASSH := .f.

/*/{Protheus.doc} CENEB3QP
Tela mostra os registros temporários presentes na tabela B3Q, gerados
pelo extrador, para o SIP.

@owner TOTVS

@author Gabriel H. Klok
@type function
@since 01/09/2020
@version 1.0

@param lAuto, logical, Indica se a função foi chamada pela rotina de automação.
@param cMatric, caracter, Matricula do beneficiário.
@param cEvedes, caracter, Chave do evento de despesa.
@param cCodOpe, caracter, Codigo da operadora.
@param cCodObr, caracter, Codigo da obrigação.
@param cAnoCmp, caracter, Ano da obrigação.
@param cCdComp, caracter, Codigo da competência.

@return oBrowse, object, Instancia da classe 'FwmBrowse'.
/*/
function CENEB3QP(lAuto, cMatric, cEvedes, cCodOpe, cCodObr, cAnoCmp, cCdComp)
    local oBrowse
    local aFields
    local oTableTmp
    local cAlias

    default lAuto := .f.
    default cMatric := ""
    default cEvedes := ""
    default cCodOpe := ""
    default cCodObr := ""
    default cAnoCmp := ""
    default cCdComp := ""

    dbselectarea("B3Q")
    lB3QCLASSH := B3Q->(fieldpos("B3Q_CLASSH")) > 0

    aFields := getFields()
    oTableTmp := createTableTmp(aFields)

    cAlias := getProced(cMatric, cEvedes, cCodOpe, cCodObr, cAnoCmp, cCdComp)
    if ! (cAlias)->(eof())
        insertProced(cAlias)
    endif

    oBrowse := fwmbrowse():new()
    oBrowse:setalias(oTableTmp:getalias())
    oBrowse:setfields(mountFields(aFields))
    oBrowse:setdescription("Registros temporários gerados pelo extrator (Procedimentos)")
    oBrowse:setprofileID("CENEB3QP")
    oBrowse:setmenudef("CENEB3QP")
    oBrowse:disabledetails()
    oBrowse:setwalkthru(.f.)
    oBrowse:setambiente(.f.)
    oBrowse:setusefilter(.f.)
    oBrowse:forcequitbutton()

    if ! lAuto
        oBrowse:activate()
    endif

    oTableTmp:delete()
    (cAlias)->(dbclosearea())
return oBrowse


/*/{Protheus.doc} menudef
Função MVC para montar o menu da rotina.

@author Gabriel H. Klok
@type static function
@since 01/09/2020
@version 1.0

@return aMenu, array, Array contendo as opções do menu.
/*/
static function menudef()
    local aMenu := {}

    if lB3QCLASSH
        ADD OPTION aMenu TITLE "Detalhes Class. H" ACTION "staticcall(CENEB3QP, descClaH)" OPERATION 2 ACCESS 0
    endif
    ADD OPTION aMenu TITLE "Voltar" ACTION "closebrowse()" OPERATION 2 ACCESS 0
return aMenu


/*/{Protheus.doc} createTableTmp
Função cria uma tabela temporária para mostrar o conteúdo na tela.

@author Gabriel H. Klok
@type static function
@since 01/09/2020
@version 1.0

@param aFields, array, Array contendo os campos da tabela.

@return oTableTmp, object, Instancia da classe 'FwTemporaryTable'.
/*/
static function createTableTmp(aFields)
    local oTableTmp := nil

    oTableTmp := fwtemporarytable():new("PROB3Q")
    oTableTmp:setfields(aFields)
    oTableTmp:addindex("01", {"EVEDES"})
    oTableTmp:create()
return oTableTmp


/*/{Protheus.doc} getFields
Função defini nome, tipo, tamanho e decimal dos campos a serem inseridos na tabela temporária.

@author Gabriel H. Klok
@type static function
@since 01/09/2020
@version 1.0

@return aFields, array, Array contendo os campos com suas definições.
/*/
static function getFields()
    local aFields := {}

    aadd(aFields, {"ANOCMP", "C", 004, 0})
    aadd(aFields, {"CDCOMP", "C", 003, 0})
    aadd(aFields, {"EVEDES", "C", 046, 0})
    aadd(aFields, {"CDTPTB", "C", 002, 0})
    aadd(aFields, {"CODEVE", "C", 016, 0})
    aadd(aFields, {"DATEVE", "D", 008, 0})
    aadd(aFields, {"QTDEVE", "N", 012, 0})
    aadd(aFields, {"VLREVE", "N", 016, 2})
    aadd(aFields, {"CLAAMB", "C", 007, 0})
    aadd(aFields, {"CLAINT", "C", 007, 0})
    aadd(aFields, {"GRPINT", "C", 001, 0})
    aadd(aFields, {"REGINT", "C", 001, 0})
    aadd(aFields, {"DATINT", "D", 008, 0})
    aadd(aFields, {"HORINT", "C", 008, 0})
    aadd(aFields, {"DATALT", "D", 008, 0})
    aadd(aFields, {"HORALT", "C", 006, 0})
    aadd(aFields, {"FORCON", "C", 001, 0})
    aadd(aFields, {"SEGMEN", "C", 001, 0})
    aadd(aFields, {"EVDEIN", "C", 046, 0})
    if lB3QCLASSH
        aadd(aFields, {"CLASSH", "C", 1000, 0})
    endif
return aFields


/*/{Protheus.doc} getProced
Função realiza a query no banco de dados para procurar o conteudo dos procedimentos que
serão apresentados na tela para o usuário.

@author Gabriel H. Klok
@type static function
@since 01/09/2020
@version 1.0

@param cMatric, caracter, Matricula do beneficiário.
@param cEvedes, caracter, Chave do evento de despesa.
@param cCodOpe, caracter, Codigo da operadora.
@param cCodObr, caracter, Codigo da obrigação.
@param cAnoCmp, caracter, Ano da obrigação.
@param cCdComp, caracter, Codigo da competência.

@return eof(), logical, Retorna se encontrou ou não registros.
/*/
static function getProced(cMatric, cEvedes, cCodOpe, cCodObr, cAnoCmp, cCdComp)
    local cAlias := getnextalias()
    local cFieldH := "%%"

    if lB3QCLASSH
        cFieldH := "%, CAST(B3Q_CLASSH AS VARCHAR(1000)) B3Q_CLASSH %"
    endif

    beginsql alias cAlias
        SELECT B3Q_ANOCMP, B3Q_CDCOMP, B3Q_EVEDES, B3Q_CDTPTB, B3Q_CODEVE, B3Q_DATEVE, B3Q_QTDEVE, B3Q_VLREVE, B3Q_CLAAMB, B3Q_CLAINT,
                B3Q_GRPINT, B3Q_REGINT, B3Q_DATINT, B3Q_HORINT, B3Q_DATALT, B3Q_HORALT,
                B3Q_FORCON, B3Q_SEGMEN, B3Q_EVDEIN %exp:cFieldH%
        FROM %table:B3Q% B3Q
        WHERE B3Q_FILIAL = %xfilial:B3Q%
            AND B3Q_MATRIC = %exp:cMatric%
            AND B3Q_EVEDES = %exp:cEvedes%
            AND B3Q_CODOPE = %exp:cCodOpe%
            AND B3Q_CODOBR = %exp:cCodObr%
            AND B3Q_ANOCMP = %exp:cAnoCmp%
            AND B3Q_CDCOMP = %exp:cCdComp%
            AND B3Q.%notdel%
    endsql
return cAlias


/*/{Protheus.doc} insertProced
Função realiza a inserção dos registros encontrados com a função 'getProced' na tabela
temporária criada na função 'createTableTmp'.

@author Gabriel H. Klok
@type static function
@since 01/09/2020
@version 1.0
/*/
static function insertProced(cAlias)
    (cAlias)->(dbgotop())
    while ! (cAlias)->(eof())
        PROB3Q->(reclock("PROB3Q", .t.))

        PROB3Q->ANOCMP := (cAlias)->B3Q_ANOCMP
        PROB3Q->CDCOMP := (cAlias)->B3Q_CDCOMP
        PROB3Q->EVEDES := (cAlias)->B3Q_EVEDES
        PROB3Q->CDTPTB := (cAlias)->B3Q_CDTPTB
        PROB3Q->CODEVE := (cAlias)->B3Q_CODEVE
        PROB3Q->DATEVE := stod((cAlias)->B3Q_DATEVE)
        PROB3Q->QTDEVE := (cAlias)->B3Q_QTDEVE
        PROB3Q->VLREVE := (cAlias)->B3Q_VLREVE
        PROB3Q->CLAAMB := (cAlias)->B3Q_CLAAMB
        PROB3Q->CLAINT := (cAlias)->B3Q_CLAINT
        PROB3Q->GRPINT := (cAlias)->B3Q_GRPINT
        PROB3Q->REGINT := (cAlias)->B3Q_REGINT
        PROB3Q->DATINT := stod((cAlias)->B3Q_DATINT)
        PROB3Q->HORINT := (cAlias)->B3Q_HORINT
        PROB3Q->DATALT := stod((cAlias)->B3Q_DATALT)
        PROB3Q->HORALT := (cAlias)->B3Q_HORALT
        PROB3Q->FORCON := (cAlias)->B3Q_FORCON
        PROB3Q->SEGMEN := (cAlias)->B3Q_SEGMEN
        PROB3Q->EVDEIN := (cAlias)->B3Q_EVDEIN
        if lB3QCLASSH
            PROB3Q->CLASSH := (cAlias)->B3Q_CLASSH
        endif

        PROB3Q->(msunlock())

        (cAlias)->(dbskip())
    enddo
return


/*/{Protheus.doc} mountFields
Função monta um array com a definição dos campos criados na função 'getFields' para
serem inseridos na tabela temporária criada pela função 'createTableTmp'.

@author Gabriel H. Klok
@type static function
@since 01/09/2020
@version 1.0

@param aCampos, array, Array de campos retornado pela função 'getFields'.

@return aFields, array, Array com todos os campos informados por parametros prontos para serem inseridos na tabela temporária.
/*/
static function mountFields(aCampos)
    local aFields := {}

    aadd(aFields, getCollumn(aCampos[PANOCMP,FIELD], "Ano", aCampos[PANOCMP,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PANOCMP,SIZE], aCampos[PANOCMP,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PCDCOMP,FIELD], "Competência", aCampos[PCDCOMP,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PCDCOMP,SIZE], aCampos[PCDCOMP,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PEVEDES,FIELD], "Chv. Eve Des", aCampos[PEVEDES,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PEVEDES,SIZE], aCampos[PEVEDES,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PCDTPTB,FIELD], "Cd.Tp.Tabela", aCampos[PCDTPTB,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PCDTPTB,SIZE], aCampos[PCDTPTB,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PCODEVE,FIELD], "Cod. Evento", aCampos[PCODEVE,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PCODEVE,SIZE], aCampos[PCODEVE,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PDATEVE,FIELD], "Dt Evento", aCampos[PDATEVE,TYPE], M_DATE, ALIGN_LEFT, aCampos[PDATEVE,SIZE], aCampos[PDATEVE,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PQTDEVE,FIELD], "Qtde. Realizada", aCampos[PQTDEVE,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PQTDEVE,SIZE], aCampos[PQTDEVE,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PVLREVE,FIELD], "Valor", aCampos[PVLREVE,TYPE], M_NUMF, ALIGN_LEFT, aCampos[PVLREVE,SIZE], aCampos[PVLREVE,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PCLAAMB,FIELD], "Clas. Ambul.", aCampos[PCLAAMB,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PCLAAMB,SIZE], aCampos[PCLAAMB,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PCLAINT,FIELD], "Clas. Inter.", aCampos[PCLAINT,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PCLAINT,SIZE], aCampos[PCLAINT,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PGRPINT,FIELD], "Grp. Intern.", aCampos[PGRPINT,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PGRPINT,SIZE], aCampos[PGRPINT,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PREGINT,FIELD], "Reg. Intern.", aCampos[PREGINT,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PREGINT,SIZE], aCampos[PREGINT,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PDATINT,FIELD], "Dt. Interma.", aCampos[PDATINT,TYPE], M_DATE, ALIGN_LEFT, aCampos[PDATINT,SIZE], aCampos[PDATINT,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PHORINT,FIELD], "Hr. Interna.", aCampos[PHORINT,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PHORINT,SIZE], aCampos[PHORINT,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PDATALT,FIELD], "Dt. alta", aCampos[PDATALT,TYPE], M_DATE, ALIGN_LEFT, aCampos[PDATALT,SIZE], aCampos[PDATALT,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PHORALT,FIELD], "Hr. alta", aCampos[PHORALT,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PHORALT,SIZE], aCampos[PHORALT,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PFORCON,FIELD], "For. Con.", aCampos[PFORCON,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PFORCON,SIZE], aCampos[PFORCON,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PSEGMEN,FIELD], "Segmentacao", aCampos[PSEGMEN,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PSEGMEN,SIZE], aCampos[PSEGMEN,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PEVDEIN,FIELD], "Chv. Interna", aCampos[PEVDEIN,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PEVDEIN,SIZE], aCampos[PEVDEIN,DECIMAL]))
    if lB3QCLASSH
        aadd(aFields, getCollumn(aCampos[PCLASSH,FIELD], "Descrição H", aCampos[PCLASSH,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PCLASSH,SIZE], aCampos[PCLASSH,DECIMAL]))
    endif
return aFields


/*/{Protheus.doc} getcollumn
Função retorna um array com as definições de determinado campo.

@author Gabriel H. Klok
@type static function
@since 01/09/2020
@version 1.0

@param cField, caracter, Nome do campo.
@param cTitle, caracter, Titulo do campo.
@param cType, caracter, Tipo do campo.
@param cPicture, caracter, Mascara usada no campo.
@param nAlign, numeric, Alinhamento do campo.
@param nSize, numeric, Tamanho do campo.
@param nDecimal, numeric, Quantidade de casas decimais.

@return aCollumn, array, Array com a definição completa do campo.
/*/
static function getCollumn(cField, cTitle, cType, cPicture, nAlign, nSize, nDecimal)
    local aCollumn := {}
    local bData := &("{||" + cField + "}")

    aCollumn := {cTitle, bData, cType, cPicture, nAlign, nSize, nDecimal, .t., {|| .t.}, .f., {|| .t.}, nil, {||.t.}, .f., .f., {}}
return aCollumn


/*/{Protheus.doc} descClaH
Função mostra um modal na tela com a descrição da classificação H.

@author Gabriel H. Klok
@type static function
@since 02/09/2020
@version 1.0
/*/
static function descClaH()
    local cClasH := iif(empty(PROB3Q->EVDEIN), PROB3Q->CLAAMB, PROB3Q->CLAINT)

    if upper(rtrim(cClasH)) == "H"
        msginfo(iif(empty(PROB3Q->CLASSH), "Sem descrição, provavelmente o registro já existia na base de dados.", alltrim(PROB3Q->CLASSH)), "Descrição")
    else
        msginfo("O registro posicionado não possui classificação H.", "Aviso")
    endif
return
