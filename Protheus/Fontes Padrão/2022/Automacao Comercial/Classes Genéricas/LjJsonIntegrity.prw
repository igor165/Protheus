#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"

Function LjJsonIntegrity ; Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjJsonIntegrity
Classe respons�vel pela verifica��o da integridade do objeto json

@type    class
@since   11/05/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Class LjJsonIntegrity

    Data jJson          as JsonObject
    Data oMessageError  as Object

    Method New()
    Method Check(jNewJson, jOldJson)
    Method CheckString(cNewJson, cOldJson)

    Method GetJson(lString)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da Classe

@type    method
@return  LjJsonIntegrity, Objeto instanciado
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method New() Class LjJsonIntegrity
    Self:oMessageError := LjMessageError():New()
Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} Check
M�todo responsavel pela compara��o dos json de componentes

@type    method
@param   jNewJson, JsonObject, Objeto JsonObject a atualizar
@param   jOldJson, JsonObject, Objeto JsonObject atual
@return  L�gico, Define se o primeiro json esta com uma vers�o mais atualizado que o segundo
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Check(jNewJson, jOldJson) Class LjJsonIntegrity
    Local nX         := 1
    Local lIncorrupt := .T.

    If jNewJson["LayoutVersion"] > jOldJson["LayoutVersion"]
        For nX := 1 To Len(jNewJson["Components"])
            If (nPos := aScan(jOldJson["Components"],{|x| x["IdComponent"] == jNewJson["Components"][nX]["IdComponent"] })) > 0
                jNewJson["Components"][nX]["ComponentContent"] := jOldJson["Components"][nPos]["ComponentContent"]
            EndIf 
        Next
        Self:jJson := jNewJson
        lIncorrupt := .F.
    EndIf 
Return lIncorrupt

//-------------------------------------------------------------------
/*/{Protheus.doc} GetJson
Retorna o conte�do da propriedade jJson.

@type    method
@return  JsonObject, Atualizado com novas propriedades
@author  Rafael Tenorio da Costa
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method GetJson(lString) Class LjJsonIntegrity

    Local xJson := self:jJson

    Default lString := .F.

    If lString
        xJson := self:jJson:toJson()
    EndIf

Return xJson

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckString
M�todo responsavel pela compara��o dos json de componentes.
Entrada ser� como string

@type    method
@param   cNewJson, Caractere, String em Json a atualizar
@param   cOldJson, Caractere, String em Json a atualizar
@return  L�gico, Define se o primeiro json esta com uma vers�o mais atualizado que o segundo
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method CheckString(cNewJson, cOldJson) Class LjJsonIntegrity

    Local lIncorrupt := .T.
    Local jNewJson   := JsonObject():New()
    Local jOldJson   := JsonObject():New()

    cRetNew := jNewJson:FromJson(cNewJson)
    cRetOld := jOldJson:FromJson(cOldJson)

    If cRetNew == Nil .And. cRetOld == Nil
        lIncorrupt := self:Check(jNewJson, jOldJson)
    Else
        LjxjMsgErr("N�o foi poss�vel comparar os JSONs: " + cRetNew + " | " + cRetOld, /*cSolucao*/, GetClassName(self))
    EndIf

    jNewJson := Nil
    jOldJson := Nil
    FwFreeObj(jNewJson)
    FwFreeObj(jOldJson)

Return lIncorrupt