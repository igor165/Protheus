#Include "Protheus.ch"
#Include "Fwmvcdef.CH"
 
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA084
Ponto de entrada MNTA084
/*/
//---------------------------------------------------------------------
User Function MNTA084() //Fun��o respons�vel pela chamda dos pontos de entrada da rotina MNTA084 - Ve�culos.
 
Local aParam   := PARAMIXB // Par�metros passados pelo ponto de entrada.
Local lRet     := .T.// Retorno da fun��o.
Local oObj     := '' // Objeto que receber� o modelo.
Local cIdPonto := '' // Identificador da chamada do ponto de entrada.
Local cIdModel := '' // Identificador do modelo utilizado.
Local cModel   := '' // Identifica o modelo utilizado e receber� o seu identificador.
Local cCodBem  := ""
Local cPropri  := ""
 
    If aParam <> NIL // Identifica que foram enviado os par�metros.
    
        oObj     := aParam[1] // Modelo ativado.
        cIdPonto := aParam[2] // Determina o ponto de chamada.
        cIdModel := aParam[3] // Identificador do modelo.
 
        If cIdPonto == 'MODELPOS' //Novo modelo para chamada do ponto de entrada MNTA0841
 
            oModel := oObj:GetModel('MNTA084_ST9') // Posiciona no Model
            If oModel:GetOperation() != MODEL_OPERATION_DELETE // Valida apenas se n�o for dele��o
 
                cCodBem := oModel:GetValue('T9_CODBEM')
                cPropri := oModel:GetValue('T9_PROPRIE')
                If "TERCEIRO" $ Upper(cCodBem) .and. cProPri == "1"
                    Help(NIL, NIL, "Aten��o", NIL, "Este ve�culo est� cadastrado com nome TERCEIRO, por�m o Propriet�rio T9_PROPRIE est� com conte�do 1-Pr�prio!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor corrigir o cadastro do ve�culo!"})
					lRet := .f.
                EndIf
 
            EndIf
 
        EndIf

    EndIf
 
Return lRet //Retorno do ponto de entrada.

/*

If aParam <> NIL // Identifica que foram enviado os par�metros.
    oObj     := aParam[1] // Modelo ativado.
    cIdPonto := aParam[2] // Determina o ponto de chamada.
    cIdModel := aParam[3] // Identificador do modelo.
 
    If cIdPonto == 'MODELPOS' //Novo modelo para chamada do ponto de entrada MNTA0841
 
        oST9 := MntPneu():New // Inicializa classe
        oST9:ModelToClass( oObj ) // Carrega a classe com modelo de dados
        xRet := oST9:Valid() // Executa valida��o final
        oST9:ShowHelp() // Se houver, apresenta erro
 
    ElseIf cIdPonto == 'MODELCOMMITTTS' //Novo modelo para chamada do ponto de entrada MNTA0842.
 
        If !Empty(oObj:GetValue('T9_CODBEM'))
            MsgInfo("Ponto de entrada 'MNTA084' executado com sucesso! Codigo do bem: " + oObj:GetValue('T9_CODBEM'))
            xRet := .T.
        EndIf
 
    EndIf
EndIf
 
Return xRet //Retorno do ponto de entrada.

*/
