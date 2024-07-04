#Include "Protheus.ch"
#Include "Fwmvcdef.CH"
 
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA084
Ponto de entrada MNTA084
/*/
//---------------------------------------------------------------------
User Function MNTA084() //Função responsável pela chamda dos pontos de entrada da rotina MNTA084 - Veículos.
 
Local aParam   := PARAMIXB // Parâmetros passados pelo ponto de entrada.
Local xRet     := .T.// Retorno da função.
Local oObj     := '' // Objeto que receberá o modelo.
Local cIdPonto := '' // Identificador da chamada do ponto de entrada.
Local cIdModel := '' // Identificador do modelo utilizado.
Local cModel   := '' // Identifica o modelo utilizado e receberá o seu identificador.
 
If aParam <> NIL // Identifica que foram enviado os parâmetros.
    oObj     := aParam[1] // Modelo ativado.
    cIdPonto := aParam[2] // Determina o ponto de chamada.
    cIdModel := aParam[3] // Identificador do modelo.
 
    If cIdPonto == 'MODELPOS' //Novo modelo para chamada do ponto de entrada MNTA0841
 
        oST9 := MntPneu():New // Inicializa classe
        oST9:ModelToClass( oObj ) // Carrega a classe com modelo de dados
        xRet := oST9:Valid() // Executa validação final
        oST9:ShowHelp() // Se houver, apresenta erro
 
    ElseIf cIdPonto == 'MODELCOMMITTTS' //Novo modelo para chamada do ponto de entrada MNTA0842.
 
        If !Empty(oObj:GetValue('T9_CODBEM'))
            MsgInfo("Ponto de entrada 'MNTA084' executado com sucesso! Codigo do bem: " + oObj:GetValue('T9_CODBEM'))
            xRet := .T.
        EndIf
 
    EndIf
EndIf
 
Return xRet //Retorno do ponto de entrada.
