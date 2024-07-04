#Include "TOTVS.CH"
#include "LOJGDP.CH"

//---------------------------------------------------------------------------------------------------------------------------------------
// Este fonte tem como objetivo centralizar as funções genéricas utilizadas para uso da Implementação da Gestão de Dados Pessoais (LGPD)
//---------------------------------------------------------------------------------------------------------------------------------------

Static lLGPD        := LjPDUse() //Indica se a Implementação de Dados Protegidos (LGPD) está sendo utilizada no sistema
Static aCamposSX3   := {}

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjPDUse
Função que verifica se a funcionalidade de Dados Protegidos existe e está sendo utilizada no sistema.

@type  Function
@author Alberto Deviciente
@since 10/01/2020
@version P12
@return Logico, Indica se o sistema está habilitado para trabalhar com Dados Protegidos.
/*/
//---------------------------------------------------------------------------------------------------
Function LjPDUse()

If lLGPD == Nil
    If IsBLind() .Or. Type("cUserName") == "U" //Se for acessado por um JOB/rotina sem interface
        lLGPD := .F. //Desconsidera a tratativa para LGPD, pois a rotina é executada sem interface. Não precisa tratar dados protegidos, pois não tem interface com usuário.
    Else
        lLGPD := ExistFunc("FwPDCanUse") .And. FwPDCanUse(.T.) //Indica se a Implementação de Dados Protegidos (LGPD) está sendo utilizada no sistema
    EndIf
EndIf

Return lLGPD

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjPDCmpPrt
Verifica se o campo faz parte da relação de Dados Protegidos.

@type  Function
@param cCampo, Caracter, Campo a ser verificado se faz parte da relação de Dados Protegidos.
@author Alberto Deviciente
@since 10/01/2020
@version P12
@return Logico, Indica se é considerado um campo protegido.
/*/
//---------------------------------------------------------------------------------------------------
Function LjPDCmpPrt(cCampo)
Local lRet      := .F.
Local aCampos   := {}

If LjPDUse()
    //Verifica se o usuário não possui acesso ao campo de acordo com as configurações de Dados Pessoais e Sensíveis
    aCampos := FwProtectedDataUtil():UsrNoAccessFieldsInList({cCampo})
    lRet := Len(aCampos) > 0
EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjPDOfuscar
Realiza ofuscamento de um campo protegido.

@type  Function
@param oCampo, Objeto, Objeto referente ao campo criado na tela.
@param cCampo, Caracter, Campo de equivalente do dicionário de dados para verificar se é um campo pessoal/sensível.
@author Alberto Deviciente
@since 17/01/2020
@version P12

@return Nil, Nulo
/*/
//---------------------------------------------------------------------------------------------------
Function LjPDOfuscar(oCampo, cCampo)
Local aCampoSX3     := {}
Local nTamanho      := 0
Local nTamDec       := 0
Local cTipo         := ""

If LjPDUse()
    
    aCampoSX3   := LjPDSeekCmp(cCampo)

    If Len(aCampoSX3) > 0
        nTamanho    := aCampoSX3[2]
        nTamDec     := aCampoSX3[3]
        cTipo       := aCampoSX3[4]

        If cTipo == "C"
            If Empty(oCampo:cText) 
                oCampo:cText := Space(nTamanho)
            EndIf
        EndIf
        
        //Seta as propriedades do campo
        oCampo:lObfuscate	:= .T.
        oCampo:bWhen		:= {|| .F. }
    EndIf
EndIf

Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjPDSeekCmp
Realiza ofuscamento de um campo protegido.

@type  Function
@param cCampo, Caracter, Campo de referência do dicionário de dados o qual será buscada as suas propriedades.
@author Alberto Deviciente
@since 17/01/2020
@version P12

@return Array, Array com as propriedades do campo de acordo com o dicionário de dados.
/*/
//---------------------------------------------------------------------------------------------------
Static Function LjPDSeekCmp(cCampo)
Local aRet          := {}
Local aTamSX3       := {}
Local nTamanho      := 0
Local nTamDec       := 0
Local cTipo         := ""
Local nPosic        := 0
Local cAliasCmp     := ""

nPosic := aScan( aCamposSX3, { |x| x[1] == cCampo }  )

If nPosic == 0
    If At("_", cCampo) == 3
        cAliasCmp := "S" + Left(cCampo,2)
    Else
        cAliasCmp := Left(cCampo,3)
    EndIf

    aTamSX3 := TamSX3(cCampo)
    
    If Len(aTamSX3) > 0 //Verifica se o campo existe
        aTamSX3     := TamSX3(cCampo)
        nTamanho    := aTamSX3[1]
        nTamDec     := aTamSX3[2]
        cTipo       := aTamSX3[3]

        aAdd( aCamposSX3, {cCampo, nTamanho, nTamDec, cTipo} )
        nPosic := Len(aCamposSX3)
    EndIf
EndIf

If nPosic > 0
    nTamanho    := aCamposSX3[nPosic][2]
    nTamDec     := aCamposSX3[nPosic][3]
    cTipo       := aCamposSX3[nPosic][4]

    aRet := {cCampo, nTamanho, nTamDec, cTipo}
EndIf

Return aRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjPDAcesso
Verifica se o usuário pode acessar uma determinada rotina devido a regra de proteção de dados.
Caso o(s) campo(s) passado por parâmetro estão na regra de dados protegidos, o usuário não pode acessar a rotina.

@type  Function
@param aCampos, Array, Campos do dicionário de dados que será verificado se é campo Protegido.
@author Alberto Deviciente
@since 17/01/2020
@version P12

@return Lógico, Retorna se o usuário pode ou não acessar uma determinada rotina que possui dados protegidos.
/*/
//---------------------------------------------------------------------------------------------------
Function LjPDAcesso(aCampos)
Local lRet      := .T.
Local nX        := 0
Local cCampos   := ""

If LjPDUse()
    For nX:=1 To Len(aCampos)
        
        //Verifica se o campo faz parte da relação de Dados Protegidos.
        If LjPDCmpPrt(aCampos[nX])
            cCampos += aCampos[nX] + ", "
            lRet := .F.
        EndIf

    Next nX
EndIf

If !lRet
    cCampos := Left(cCampos,Len(cCampos)-2)
    //"Dados Protegidos"###"Acesso Restrito: Este usuário não possui permissão de acesso aos dados desse processo ou rotina, devido a funcionalidade de Dados Protegidos estar ativada."###"Campo(s): "###"Contate o Administrador do sistema."
    Help(,, STR0001,,STR0002 + Chr(13) + Chr(13) + STR0003 + cCampos, 1,1,,,,,,{STR0004})
EndIf

Return lRet