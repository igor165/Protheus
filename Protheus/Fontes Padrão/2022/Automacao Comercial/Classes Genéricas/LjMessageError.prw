#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"

Function LjMessageError ; Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjMessageError
Classe responsável pelo controle de erros

@type    class
@since   11/05/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Class LjMessageError

    Data aMessageError          as Array
    Data aMessageWarning        as Array
    Data lError                 as Logical
    Data lWarning               as Logical

    Method New() 

    Method SetError(cClassName, cError, nMethodStack)
    Method GetStatus()
    Method GetMessage(cType) 
    Method GetStack(cType)
        
    Method ClearError()
    Method ClearWarning()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@type    method
@return  LjMessageError, Objeto instanciado
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method New() Class LjMessageError
    Self:lError          := .F.
    Self:lWarning        := .F.
    Self:aMessageError   := {}
    Self:aMessageWarning := {}
Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
Método que retorna se houve erro

@type    method
@return  Lógico, Define se houve algum erro. (Erro = .F.)
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method GetStatus() Class LjMessageError
Return !Self:lError

//-------------------------------------------------------------------
/*/{Protheus.doc} SetError
Método que atualiza o erro

@type    method
@param   cClassName, Caractere, Define a classe onde ocorreu o erro
@param   cError, Caractere, Descrição do erro
@param   cType, Caractere, Tipo E=Error ou W=Warning
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method SetError(cClassName, cError, nMethodStack) Class LjMessageError

    Default cClassName   := ""
    Default cError       := ""
    Default nMethodStack := 1

    Self:lError    := .T.
    aadd(Self:aMessageError, "[ " + cClassName + " - Called -> " + ProcName(nMethodStack) + "] -> " + cError)
    LjGrvLog("TFC","[ " + cClassName + " - Called -> " + ProcName(nMethodStack) + "] -> " + cError) // -- temporario

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMessage
Método que retorna a mensagem de erro

@type    method
@param   cType, Caractere, Tipo E=Error ou W=Warning
@return  Caractere, Descrição do erro dependendo do tipo informado
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method GetMessage(cType) Class LjMessageError
    Local cResult := ""
    
    Default cType := "E"
    
    DO CASE 
        CASE UPPER(cType) == "E" // ERROR
            If Len(Self:aMessageError) >= 1
                cResult := Self:aMessageError[1]
            EndIf 
        CASE UPPER(cType) == "W" // Warning
            If Len(Self:aMessageWarning) >= 1
                cResult := Self:aMessageWarning[1]
            Endif 
    ENDCASE

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStack
Método que retorna todos os error ou Warning

@type    method
@param   cType, Caractere, Tipo E=Error ou W=Warning
@return  Array, Array com todos os erros dependendo do tipo informado
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method GetStack(cType)  Class LjMessageError
    Local aResult := Nil
    Default cType := "E"

    DO CASE 
        CASE UPPER(cType) == "E" // ERROR
            aResult := Self:aMessageError
        CASE UPPER(cType) == "W" // Warning
            aResult := Self:aMessageWarning
    ENDCASE
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} ClearError
Método que limpa os errors

@type    method
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method ClearError() Class LjMessageError
    Self:lError        := .F.
    Self:aMessageError := {}
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ClearWarning
Método que limpa os Warning

@type    method
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method ClearWarning() Class LjMessageError
    Self:lWarning        := .F.
    Self:aMessageWarning := {}
Return