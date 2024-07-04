#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#include 'fwlibversion.ch'

#define N_PERM_PESSOAL  192
#define N_PERM_SENSIVEL 193
#define LEN_CAMPO 10

class CENFUNLGP

    data aCamposNaoAuto	 as Object

    data lPermPessoais	 as boolean
    data lPermSensiveis	 as boolean

    data lRemote         as boolean
    data aGrupos         as Object


    method New() Constructor

    method setAlias(aAlias, cUser)
    method RetFlds(aPDFieldRepository)
    method verCamNPR(cCampo, cValor)
    method getFldAlias()
    method isLGPDAt()
    Method getPermPessoais()
    Method getPermSensiveis()
    Method msgNoPermissions()
    method addAllCmp(aFieldsPar)
    method getTcBrw(aCampos)
    method getTGet(cField)
    method useLogUser(cProcName)
    method camposAnoni(aAlias, lRetDetail)
    method anonimizar(aAlias, lRetDetail)
    method fieldsInList(aFields)

endClass

/*/{Protheus.doc} new
Metodo construtor da classe
@author Roberto Vanderlei de Arruda
@since 16/12/2019
@version P12
/*/
method new() class CENFUNLGP
    Private cAcesso := ""

    ::lRemote           := (funName() != "RPC")
    ::aCamposNaoAuto    := nil
    ::lPermPessoais	   :=  .T.
    ::lPermSensiveis   :=  .T.
return self

Method getPermPessoais() class CENFUNLGP
    If ::isLGPDAt() .and. !empty(RetCodUsr())
        ::lPermPessoais	   :=  VerSenha(N_PERM_PESSOAL)
    Else
        ::lPermPessoais	   :=  .T.
    EndIf
Return ::lPermPessoais

Method getPermSensiveis() class CENFUNLGP
    If ::isLGPDAt() .and. !empty(RetCodUsr())
        ::lPermSensiveis   :=  VerSenha(N_PERM_SENSIVEL)
    Else
        ::lPermSensiveis   :=  .T.
    EndIf
Return ::lPermSensiveis

Method msgNoPermissions() class CENFUNLGP
    if !isBlind()
        Help( ,, 'ACESSO',," O usu�rio n�o tem as permiss�es necess�rias para acessar dados pessoais e/ou sens�veis. ", 1, 0,;
            NIL, NIL, NIL, NIL, NIL, {" Contate o administrador do sistema para a libera��o do acesso"})
    EndIf
Return

method setAlias(aAlias, cUser) class CENFUNLGP
    Local   nI
    Local   nJ
    Local   lRetDetail   := .F.
    Local   cAlias       := ""
    Local   aFieldsPerm  := {}
    Default cUser        := RetCodUsr()

    ::getPermPessoais()
    ::getPermSensiveis()
    if ::aCamposNaoAuto	 = nil
        ::aCamposNaoAuto  := tHashMap():New()
    endif
    if !(::lPermPessoais .and. ::lPermSensiveis)
        for nI := 1 to Len(aAlias)
            cAlias := aAlias[nI]
            aObjFields := FwProtectedDataUtil():GetAliasFieldsInList(cAlias, lRetDetail)
            aFields    := ::RetFlds(aObjFields)
            aFieldsPerm := ::fieldsInList(aFields)
            for nJ := 1 to len(aFieldsPerm)
                HMSet(::aCamposNaoAuto, aFieldsPerm[nJ]:CFIELD)
            next
        next
    endif
return

method fieldsInList(aFields) class CENFUNLGP
    Local aRet := {}
    aRet := FwProtectedDataUtil():UsrNoAccessFieldsInList(aFields)
return aRet

method isLGPDAt() class CENFUNLGP
    Local lLGPD := .T.
    Local lCanOfuscate := .T.
    Private cEmpant    := ""

    cVersao := FwLibVersion()
    if cVersao <> NIL .and. cVersao <> ""
        nVersao := val(cVersao)
        if  nVersao < 20200214  //Se a Lib for anterior, ou n�o estiver usando o ofuscamento, o usuario sempre vai ter todos os direitos.
            lLGPD  := .F.
        else
            if !FwPDCanUse( lCanOfuscate )
                lLGPD  := .F.
            endif
        endif
    else
        lLGPD  := .F.
    endif
return lLGPD

method RetFlds(aPDFieldRepository) class CENFUNLGP
    Local nJ
    Local aRet := {}

    for nJ := 1 to len(aPDFieldRepository)
        aAdd(aRet, aPDFieldRepository[nJ]:CFIELD)
    next
return aRet

/*
Retorna o pr�prio valor ou criptografa, dependendo da permiss�o do usu�rio.
*/

method verCamNPR(cCampo, cValor) class CENFUNLGP
    Local cTipo

    ::getPermPessoais()
    ::getPermSensiveis()
    if ::aCamposNaoAuto = nil
        MsgAlert("E Necessario adicionar os alias(Metodo SetAlias), antes de utilizar essa funcao.", "Atencao")
        return
    endif
    if ::lPermPessoais .and. ::lPermSensiveis
        return cValor
    else
        lAchou := HMGet(::aCamposNaoAuto,cCampo,cTipo)
        if !lAchou
            return cValor
        else
            return FwProtectedDataUtil ():ValueAsteriskToAnonymize(cValor)
        endif
    endif
return

/*
M�todo que retorna uma lista com os campos que devem ser ofuscados.
*/
method getFldAlias() class CENFUNLGP
    Local aCampos := {}
    Local aRet := {}
    Local lRet := .F.
    Local nI

    lRet := HMList(::aCamposNaoAuto,aCampos)
    if lRet
        for nI := 1 to len(aCampos)
            aadd(aRet, aCampos[nI][1])
        next
    else
        MsgAlert("Erro ao converter HashMap para Lista", "Atencao")
    endif
return aRet

method getTGet(cField) class CENFUNLGP
    Local aRet := {}
    Local aPar := {}

    aadd(aPar, cField)
    aRet := ::getTcBrw(aPar)
return aRet[1]

/*TCBROWSE - Fun��o que recebe uma lista de campos e retorna um array no formato {.F., .T., .T. } na sequ�ncia que recebeu, onde .F. n�o ofusca, .T. ofusca.*/
method getTcBrw(aCampos) class CENFUNLGP
    Local nI
    Local i
    Local nY
    Local cTipo
    Local aRet := {}
    Local cCampo := ""
    Local aConcat1 := {}
    Local aConcat2 := {}
    Local aConcat3 := {}
    ::getPermPessoais()
    ::getPermSensiveis()
    For i := 1 to len(aCampos)
        If ValType(aCampos[i]) <> 'L'
            aConcat1 := Strtokarr( strtran(aCampos[i]," ",""), "+") //posicao da array com campos concatenados.
            If LEN(aConcat1) > 1
                ::addAllCmp(aConcat1) //Preenche HashMap com campos n�o permitidos.
            Else
                AAdd(aConcat2,aCampos[i])
            EndIf
        EndIf
    Next
    If LEN(aConcat2) > 0
        ::addAllCmp(aConcat2) //Preenche HashMap com campos n�o permitidos.
    EndIf

    if ::aCamposNaoAuto = nil
        MsgAlert("� Necess�rio adicionar o(s) alias(Metodo SetAlias), antes de utilizar essa fun��o.", "Aten��o")
        return
    endif
    if !(::lPermPessoais .and. ::lPermSensiveis)
        for nI := 1 to len(aCampos)
            //campo logico
            If ValType(aCampos[nI]) == 'L'
                aadd(aRet, aCampos[nI])
                //campo concatenado
            elseif  LEN(Strtokarr( aCampos[nI], "+")) > 1
                aConcat3 := Strtokarr( strtran(aCampos[nI]," ",""), "+")
                for nY := 1 to LEN(aConcat3)
                    cCampo := aConcat3[nY]
                    lAchou := HMGet(::aCamposNaoAuto,cCampo,cTipo)
                    if lAchou
                        aadd(aRet, .T.)
                        exit
                    endif
                next
                If !lAchou
                    aadd(aRet, .F.)
                EndIf
                //campo individual
            Else
                cCampo := aCampos[nI]
                lAchou := HMGet(::aCamposNaoAuto,cCampo,cTipo)
                if !lAchou
                    aadd(aRet, .F.)
                else
                    aadd(aRet, .T.)
                endif
            EndIf
        next
    else
        for nI := 1 to len(aCampos)
            aadd(aRet, .F.)
        next
    endif
return aRet

/*M�todo respons�vel por receber um conjunto de campos e que preenche o HASHMAP com os campos n�o permitidos.*/
method addAllCmp(aFieldsPar) class CENFUNLGP
    Local cUser := RetCodUsr()
    Local i
    Local j
    Local aFieldsPerm := {}

    if ::aCamposNaoAuto	 = nil
        ::aCamposNaoAuto  := tHashMap():New()
    endif
    if !(::lPermPessoais .and. ::lPermSensiveis)
        aFieldsPerm := FwProtectedDataUtil():UsrAccessPDField( cUser, aFieldsPar )
        for i := 1 to len(aFieldsPar)
            lAchou := .F.
            for j := 1 to len(aFieldsPerm)
                if(aFieldsPar[i] = aFieldsPerm[j])
                    lAchou := .T.
                endif
            next
            if(!lAchou)
                HMSet(::aCamposNaoAuto, aFieldsPar[i],  "-" )
            endif
        next
    endif
return

/*/{Protheus.doc} useLogUser
    M�todo para obter Log de acesso para auditoria LGPD
    @type  Method
    @author David Juan
    @since 27/02/2020
    @version P12
    @param cProcName - Nome da fun��o anterior (precisa estar descrita no pdaudit.prw com seus respectivos Alias)
    @see https://tdn.totvs.com/display/public/PROT/FwPDLogUser
/*/
method useLogUser(cProcName) class CENFUNLGP
    Default cProcName   := ProcName(1)

    if ::isLGPDAt()
        FwPDLogUser(cProcName)
    endif
Return

/*/{Protheus.doc} camposAnoni
    (Busca os campos de um alias que podem ser anonimizados conforme a configura��o para Protected Data (tabela XAM))
    @type  method
    @author David Juan
	@since 23/03/2020
	@version P12
	@param aAlias -> tabelas passiveis de anonimizacao, lRetDetail -> Indica se a funcao do frame vai retornar detalhes dos campos
	@return aCampos, array
    @see https://tdn.totvs.com/display/public/PROT/FwProtectedDataUtil
/*/
method camposAnoni(aAlias, lRetDetail) class CENFUNLGP
    Local aRet              := {}
    Local nX                := 0
    Local nY                := 0
    Local oHashAnon         := tHashMap():new()
    Default lRetDetail      := .F.

    For nX:= 1 to Len(aAlias)
        oHashAnon := FwProtectedDataUtil():GetAliasAnonymizeFields(aAlias[nX],lRetDetail)
        For nY:= 1 to Len(oHashAnon)
            aadd(aRet,PadR(oHashAnon[nY]:CFIELD,LEN_CAMPO))
        Next
    Next
Return aRet

/*/{Protheus.doc} anonimizar
    (Realiza a anonimiza��o de campos com base em uma lista de Recnos.)
    @type  method
    @author David Juan
	@since 26/03/2020
	@version P12
	@param cAlias -> Tabela passivel de anonimizacap, aRecno -> Registros a serem anonimizados
	@return lRet, logico
    @see https://tdn.totvs.com/display/public/PROT/FwProtectedDataUtil
/*/
method anonimizar(cAlias, aRecno) class CENFUNLGP
    Local lRet      := .F.

    if !Empty(cAlias) .And. !Empty(aRecno)
        lRet := FwProtectedDataUtil():ToAnonymizeByRecno( cAlias, aRecno)
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CENFUNLGP
Somente para compilar a classe
/*/
//-------------------------------------------------------------------
Function CENFUNLGP
Return