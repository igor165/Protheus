#include "TOTVS.CH"
#include "msobject.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjAuthenticationFidelityCore
Classe que representa a autenticação para o FidelityCore

@type       Class
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.23

@return
/*/
//-------------------------------------------------------------------------------------
Class LjAuthenticationFidelityCore 
    Data cTypedCode            as Character
    Data cSentCode             as Character
    Data cType                 as Character
    Data lValidatedByException as Logical

    Method New(cType,cSentCode,lValidExc)
    Method GetTypedCodeAuthentication()
    Method GetSentCodeAuthentication()
    Method GetTypeAuthentication()
    Method GetValidatedByExceptionAuthentication()

    Method SetTypedCode(cTypedCode)
    Method SetValidatedByExceptionAuthentication(lValidExc)
EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo contrutor

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@param cType, Caracter, Tipo da autenticação
@param cSentCode, Caracter, Codigo recebido
@param lValidExc, Logico,indica se foi uma validação excepcional
@return Objeto, Classe
/*/
//-------------------------------------------------------------------------------------
Method New(cType,cSentCode,lValidExc) Class LjAuthenticationFidelityCore

    Self:cSentCode             := cSentCode
    Self:cType                 := cType
    Self:lValidatedByException := lValidExc

return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTypedCodeAuthentication
Metodo responsavel por retornar o conteudo da propriedade cTypedCode

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cTypedCode
/*/
//-------------------------------------------------------------------------------------
Method GetTypedCodeAuthentication() Class LjAuthenticationFidelityCore
return Alltrim(Self:cTypedCode)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSentCodeAuthentication
Metodo responsavel por retornar o conteudo da propriedade cSentCode

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cSentCode
/*/
//-------------------------------------------------------------------------------------
Method GetSentCodeAuthentication() Class LjAuthenticationFidelityCore
return Alltrim(Self:cSentCode)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTypeAuthentication
Metodo responsavel por retornar o conteudo da propriedade cType

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Caracter, propriedade cType
/*/
//-------------------------------------------------------------------------------------
Method GetTypeAuthentication() Class LjAuthenticationFidelityCore
return Alltrim(Self:cType)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetValidatedByExceptionAuthentication
Metodo responsavel por retornar o conteudo da propriedade lValidatedByException

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33

@return Lógico, propriedade lValidatedByException
/*/
//-------------------------------------------------------------------------------------
Method GetValidatedByExceptionAuthentication() Class LjAuthenticationFidelityCore
return Self:lValidatedByException

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetTypedCode
Metodo responsavel por atualizar o conteudo da propriedade cTypedCode

@type       Method
@param      cTypedCode, Caractere, Código do tipo
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetTypedCode(cTypedCode) Class LjAuthenticationFidelityCore
    Self:cTypedCode := cTypedCode
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetValidatedByExceptionAuthentication
Metodo responsavel por atualizar o conteudo da propriedade lValidatedByException

@type       Method
@param      lValidExc, Lógico, Define se deverá validar a exceção
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetValidatedByExceptionAuthentication(lValidExc) Class LjAuthenticationFidelityCore
    Self:lValidatedByException := lValidExc
Return