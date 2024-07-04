#include "protheus.ch"
#include "fwmvcdef.ch"

#define CRLF chr(13) + chr(10)

#define M_ALFA "@!"
#define M_NUMF "@E 999,999,999.99"

#define ALIGN_LEFT 1

#define FIELD 1
#define TYPE 2
#define SIZE 3
#define DECIMAL 4

#define PCODOBR 1
#define PCODOPE 2
#define PANOCMP 3
#define PCDCOMP 4
#define PMATRIC 5
#define PEVEDES 6
#define PTRIREC 7
#define PTRIOCO 8
#define PUF 9
#define PVALOR 10

static oBrowse := nil

/*/{Protheus.doc} CENEB3QG
Tela mostra os registros temporários presentes na tabela B3Q, gerados
pelo extrador, para o SIP.

@owner TOTVS

@author Gabriel H. Klok
@type function
@since 31/08/2020
@version 1.0

@param lAuto, logical, Indica se a função foi chamada pela rotina de automação.

@return oBrowse, object, Instancia da classe 'FwmBrowse'.
/*/
function CENEB3QG(lAuto)
    local aFields := getFields()
    local oTableTmp := createTableTmp(aFields)
    local cAlias

    default lAuto := .f.

    cAlias := getGuias()
    if ! (cAlias)->(eof())
        insertGuias(cAlias)
    endif 
    
    oBrowse := fwmbrowse():new()
    oBrowse:setalias(oTableTmp:getalias())
    oBrowse:setfields(mountFields(aFields))
    oBrowse:setdescription("Registros temporários gerados pelo extrator (Guias)")
    oBrowse:setprofileID("CENEB3QG")
    oBrowse:setmenudef("CENEB3QG")
    oBrowse:disabledetails()
    oBrowse:setwalkthru(.f.)
	oBrowse:setambiente(.f.)
    oBrowse:setusefilter(.f.)
    oBrowse:forcequitbutton()

    if ! lAuto
        filterScreen()
        oBrowse:activate()
    endif

    oTableTmp:delete()
    (cAlias)->(dbclosearea())
return oBrowse


/*/{Protheus.doc} menudef
Função MVC para montar o menu da rotina.

@author Gabriel H. Klok
@type static function
@since 31/08/2020
@version 1.0

@return aMenu, array, Array contendo as opções do menu.
/*/
static function menudef()
    local aMenu := {}

    ADD OPTION aMenu TITLE "Procedimentos" ACTION "staticcall(CENEB3QG, listProced)" OPERATION 2 ACCESS 0
    ADD OPTION aMenu TITLE "Filtro" ACTION "staticcall(CENEB3QG, filterScreen)" OPERATION 3 ACCESS 0
return aMenu 


/*/{Protheus.doc} listProced
Função realiza a chamada do fonte que monta a tela mostrando os procedimentos.

@author Gabriel H. Klok
@type static function
@since 01/09/2020
@version 1.0
/*/
static function listProced()
    CENEB3QP(.f., GUIB3Q->MATRIC, GUIB3Q->EVEDES, GUIB3Q->CODOPE, GUIB3Q->CODOBR, GUIB3Q->ANOCMP, GUIB3Q->CDCOMP)
return 


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

    oTableTmp := fwtemporarytable():new("GUIB3Q")
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

    aadd(aFields, {"CODOBR", "C", 003, 0})
    aadd(aFields, {"CODOPE", "C", 006, 0})
    aadd(aFields, {"ANOCMP", "C", 004, 0})
    aadd(aFields, {"CDCOMP", "C", 003, 0})
    aadd(aFields, {"MATRIC", "C", 018, 0})
    aadd(aFields, {"EVEDES", "C", 046, 0})
    aadd(aFields, {"TRIREC", "C", 006, 0})
    aadd(aFields, {"TRIOCO", "C", 006, 0})
    aadd(aFields, {"UF", "C", 002, 0})
    aadd(aFields, {"VALOR", "N", 016, 2})
return aFields


/*/{Protheus.doc} getGuias
Função realiza a query no banco de dados para procurar o conteudo das guias que
serão apresentados na tela para o usuário.

@author Gabriel H. Klok
@type static function
@since 01/09/2020
@version 1.0

@return eof(), logical, Retorna se encontrou ou não registros.
/*/
static function getGuias()
    local cAlias := getnextalias()

    beginsql alias cAlias 
        SELECT B3Q_CODOBR, B3Q_CODOPE, B3Q_ANOCMP, B3Q_CDCOMP, B3Q_MATRIC, B3Q_EVEDES, B3Q_TRIREC, B3Q_TRIOCO, B3Q_UF, SUM(B3Q_VLREVE) VALOR
        FROM %table:B3Q% B3Q
        WHERE B3Q_FILIAL = %xfilial:B3Q%
            AND B3Q_CODOBR = '002'
            AND B3Q.%notdel%
        GROUP BY B3Q_FILIAL, B3Q_CODOBR, B3Q_CODOPE, B3Q_ANOCMP, B3Q_CDCOMP, B3Q_MATRIC, B3Q_EVEDES, B3Q_TRIREC, B3Q_TRIOCO, B3Q_UF
    endsql 
return cAlias


/*/{Protheus.doc} insertGuias
Função realiza a inserção dos registros encontrados com a função 'getGuias' na tabela
temporária criada na função 'createTableTmp'.

@author Gabriel H. Klok
@type static function
@since 01/09/2020
@version 1.0
/*/
static function insertGuias(cAlias)
    (cAlias)->(dbgotop())
    while ! (cAlias)->(eof())
        GUIB3Q->(reclock("GUIB3Q", .t.))
        GUIB3Q->CODOBR := (cAlias)->B3Q_CODOBR
        GUIB3Q->CODOPE := (cAlias)->B3Q_CODOPE
        GUIB3Q->ANOCMP := (cAlias)->B3Q_ANOCMP
        GUIB3Q->CDCOMP := (cAlias)->B3Q_CDCOMP
        GUIB3Q->MATRIC := (cAlias)->B3Q_MATRIC
        GUIB3Q->EVEDES := (cAlias)->B3Q_EVEDES
        GUIB3Q->TRIREC := (cAlias)->B3Q_TRIREC
        GUIB3Q->TRIOCO := (cAlias)->B3Q_TRIOCO
        GUIB3Q->UF := (cAlias)->B3Q_UF
        GUIB3Q->VALOR := (cAlias)->VALOR
        GUIB3Q->(msunlock())

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

    aadd(aFields, getCollumn(aCampos[PCODOBR,FIELD], "Obrigação", aCampos[PCODOBR,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PCODOBR,SIZE], aCampos[PCODOBR,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PCODOPE,FIELD], "Operadora", aCampos[PCODOPE,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PCODOPE,SIZE], aCampos[PCODOPE,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PANOCMP,FIELD], "Ano", aCampos[PANOCMP,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PANOCMP,SIZE], aCampos[PANOCMP,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PCDCOMP,FIELD], "Competência", aCampos[PCDCOMP,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PCDCOMP,SIZE], aCampos[PCDCOMP,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PMATRIC,FIELD], "Matricula", aCampos[PMATRIC,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PMATRIC,SIZE], aCampos[PMATRIC,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PEVEDES,FIELD], "Guia", aCampos[PEVEDES,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PEVEDES,SIZE], aCampos[PEVEDES,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PTRIREC,FIELD], "Tri. Recorrencia", aCampos[PTRIREC,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PTRIREC,SIZE], aCampos[PTRIREC,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PTRIOCO,FIELD], "Tri. Ocorrencia", aCampos[PTRIOCO,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PTRIOCO,SIZE], aCampos[PTRIOCO,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PUF,FIELD], "UF", aCampos[PUF,TYPE], M_ALFA, ALIGN_LEFT, aCampos[PUF,SIZE], aCampos[PUF,DECIMAL]))
    aadd(aFields, getCollumn(aCampos[PVALOR,FIELD], "Valor", aCampos[PVALOR,TYPE], M_NUMF, ALIGN_LEFT, aCampos[PVALOR,SIZE], aCampos[PVALOR,DECIMAL]))
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


/*/{Protheus.doc} filterScreen
Função mostra uma modal para realizar o filtro das guias na tela.

@author Gabriel H. Klok
@type static function
@since 11/09/2020
@version 1.0
/*/
static function filterScreen()
    local aPergs := {}
    local cFilter := ""

    aadd(aPergs, {1, "Ano", space(4), "@E 9999",,,, 40, .f.})
    aadd(aPergs, {2, "Trimestre", 1, {"","1=1º Trimestre", "2=2º Trimestre", "3=3º Trimestre", "4=4º Trimestre"}, 60,, .f.})
    
    if parambox(aPergs, "Filtros",,,, .t.,,,,, .f., .f.)
        if ! empty(MV_PAR01)
            cFilter += " ANOCMP == '" + MV_PAR01 + "' "
        endif 

        if valtype(MV_PAR02) == "C"
            cFilter += iif(empty(cFilter), "", ".AND.") + " CDCOMP == '00" + MV_PAR02 + "' "
        endif 

        oBrowse:setfilterdefault(cFilter)
    endif 
return
