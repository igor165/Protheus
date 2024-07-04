#Include "PROTHEUS.CH"
#Include "FISX003.CH"

Static lFWPDCanUse 	:= FindFunction("FWPDCanUse") .And. FWPDCanUse() //Fun��o que verifica se a melhoria de Dados Protegidos est� sendo utilizada no sistema
Static lPessoal		:= VerSenha(192) //usu�rio est� desmarcado para ver dados pessoais
Static lSensivel	:= VerSenha(193) //usu�rio est� desmarcado para ver dados sens�veis
Static lIsBlind     := IsBlind()

/*/{Protheus.doc} Verpesssen
    Fun��o que retorna a permiss�o de execu��o
    das rotinas que contenham dados pessoais e 
    Sensiveis
    @type  Function
    @author Erich Buttner
    @since 08/12/2109
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function Verpesssen ()
Local lRet      := .T.

If !lIsBlind .And. lFWPDCanUse .And. !lPessoal//(!lPessoal .Or. !lSensivel)

    Help(NIL, NIL, "Acesso", NIL,STR0001,; // Usu�rio sem acesso a dados Pessoais e/ou Sens�vel
    1, 0, NIL,NIL, NIL, NIL, NIL, {STR0002}) //Contate o administrador do sistema para a libera��o de acesso
    lRet := .F.

EndIf

Return lRet

/*/{Protheus.doc} NExibeLGPD()
N�o exibe o campo 

@param	oGet		- Objeto do tipo TGet
@param	cCampo		- Campo associado ao campo TGet

@author matheus.massarotto
@since 22/01/20
@version 12
/*/

Function AnonimoLGPD(oGet,cCampo)
Local lRet := .F.

if GroupAnoLGPD(cCampo) //Verifico se o campo � de dados sens�veis ou pessoais
    lRet:= ObjAnoLGPD(oGet) //Altero a propriedade do objeto para ofuscar
endif

Return(lRet)


/*/{Protheus.doc} GroupAnoLGPD()
Verifico se o campo pertence a algum grupo de dados pessoais e / ou sens�veis

@param	cCampo		- Campo
@param	lVerPess    - Ver se o grupo � pessoal
@param	lVerSen		- Ver se o grupo � sens�vel

@author matheus.massarotto
@since 28/01/20
@version 12
/*/

Function GroupAnoLGPD(cCampo,lVerPess,lVerSens)
Local lRet       := .F.
Local nX         := 0
Local aGrupos    := {}

Default lVerPess := .F.
Default lVerPess := .F.

//Verifica se a melhoria de Dados Protegidos est� sendo utilizada no sistema e se o campo est� na lista de protected data e a build https://tdn.totvs.com/display/tec/Ofuscamento+de+dados+nos+componentes+do+SmartClient
if lFWPDCanUse .and. FwProtectedDataUtil():IsFieldInList(cCampo) .and. getbuild() >= "7.00.191205" 
    aGrupos := FwProtectedDataUtil():GetFieldGroups( cCampo ) //Busca a lista de grupo Protected Data que um determinado campo faz parte
    if ValType(aGrupos)=="A" //Array
        
        for nX := 1 to Len(aGrupos) //Percorro todos os grupos retornados
            
            //Verifico se � um grupo do tipo pessoal e o usu�rio est� desmarcado para ver dados pessoais E � um grupo do tipo sensivel e o usu�rio est� desmarcado para ver dados sens�veis
            if (lVerPess .and. lVerPess) .and. (aGrupos[nX]:IsPersonal() .and. !lPessoal) .and. (aGrupos[nX]:IsSensible() .and. !lSensivel)
                lRet:=.T.
            elseif (lVerPess .and. !lVerPess) .and. (aGrupos[nX]:IsPersonal() .and. !lPessoal)  //Verifico se � um grupo do tipo pessoal e o usu�rio est� desmarcado para ver dados pessoais
                lRet:=.T.
            elseif (!lVerPess .and. lVerPess) .and. (aGrupos[nX]:IsSensible() .and. !lSensivel) //Verifico se � um grupo do tipo sensivel e o usu�rio est� desmarcado para ver dados sens�veis
                lRet:=.T.
            else
                if (aGrupos[nX]:IsPersonal() .and. !lPessoal) .or. (aGrupos[nX]:IsSensible() .and. !lSensivel) // Verifico se � um grupo do tipo pessoal e o usu�rio est� desmarcado para ver dados pessoais OU � um grupo do tipo sensivel e o usu�rio est� desmarcado para ver dados sens�veis
                    lRet:=.T.
                endif
            endif

            if lRet
                exit
            endif

        next nX

    endif
endif

Return(lRet)


/*/{Protheus.doc} ObjAnoLGPD()
Altera a propriedade do objeto para Ofuscar

@param	oObjeto		- Objeto
@param	lOfusca     - .T. para Ofuscar e .F. para n�o ofuscar

@author matheus.massarotto
@since 28/01/20
@version 12
/*/

Function ObjAnoLGPD(oObjeto,lOfusca)
Local lRet      := .F.
Local cClass    := ""
Local oError    := ErrorBlock({|e| Conout("FISX003: " +e:Description +"- Filial " + FWGETCODFILIAL + " " + Time()+ "ERRORSTACK:"	+ Chr(10)+Chr(13) + e:ErrorStack)})

Default lOfusca := .T.

Begin Sequence //Tratado para n�o dar erro caso o objeto n�o exista.
    if oObjeto <> NIL  //lObfuscate dison�vel para builds iguais ou superiores a 19.3.0.1
        
        cClass:= ALLTRIM(UPPER(GETCLASSNAME(oObjeto))) //Retorna o nome da classe
        
        if cClass $ "TGET/TMULTIGET/TCOMBOBOX/TSIMPLEEDITOR"
            oObjeto:lObfuscate := lOfusca //A propriedade lObfuscate para indicar que a coluna tenha seu conte�do ofuscado
            oObjeto:bWhen 		:= { || .F. }
            lRet := .T.
        endif

    endif
End Sequence

ErrorBlock(oError)

Return(lRet)



/*/{Protheus.doc} FISLGPD()
Verifica se as fun��es est�o ativas para LGPD

@param

@author matheus.massarotto
@since 22/01/20
@version 12
/*/
Function FISLGPD()
Local lRet := .F.

lRet := FindFunction("Verpesssen") .And. ;
		FindFunction("AnonimoLGPD") .And. ;
		FindFunction("FWPDCanUse") .And. FWPDCanUse()

Return(lRet)
