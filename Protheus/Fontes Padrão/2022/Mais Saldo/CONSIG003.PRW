#INCLUDE "PROTHEUS.CH"
#INCLUDE "CONSIG003.CH"


/*/{Protheus.doc} function ConfigConsignado
Configurador para comunicação com as integrações do Consignado.
@author  Hugo de Oliveira
@since   04/06/2021
@version 1.0
/*/
Main Function ConfigConsignado()
    MsApp():New("SIGAGPE")
    oApp:cInternet  := Nil
    __cInterNet     := NIL
    oApp:bMainInit  := { || ( oApp:lFlat := .F., fOpenConfig(), Final(STR0001, ""))} // "Encerramento Normal"   
    oApp:CreateEnv()
    OpenSM0()
    PtSetTheme("TEMAP10")
    SetFunName("UPDDISTR")
    oApp:lMessageBar := .T.
    oApp:Activate()
Return


/*/{Protheus.doc} function fOpenConfig
Inicia o processamento do configurador.
@author  Hugo de Oliveira
@since   04/06/2021
@version 1.0
/*/
Static Function fOpenConfig()
    Local oWizard       As Object
    Local bConstruction As CodeBlock
    Local bNextAction   As CodeBlock
    Local bPrevWhen     As CodeBlock
    Local bCancelWhen   As CodeBlock
    Local bProcess      As CodeBlock
    Local aParam        As Array
    Local cReqDes       As Character
    Local cReqCont      As Character
    Local bReqVld       As CodeBlock
    Local cReqMsg       As Character

    oWizard := FWCarolWizard():New()
    bConstruction := { | oPanel | aParam := fmakeStep(oPanel)}
    bNextAction   := { || .T.}
    bPrevWhen     := { || .F. }
    bCancelWhen   := { || .T. }
    bProcess      := { | cGrpEmp, cMsg | ProcAnt(cGrpEmp, @cMsg, aParam)}

    cReqDes  := STR0002 // "Release do RPO"
    cReqCont := GetRpoRelease()
    bReqVld  := { || GetRpoRelease() >= "12.1.023" }
    cReqMsg  := STR0003 // "Versão de RPO deve ser no mínimo 12.1.23"

    oWizard:SetWelcomeMessage(STR0004) // "Bem vindo ao instalador!"
    oWizard:AddRequirement(cReqDes, cReqCont, bReqVld, cReqMsg)
    oWizard:AddProcess(bProcess)
    oWizard:UsePlatformAccess(.T.) // Valor .F. não recupera credenciais das Integrações.
    oWizard:Activate()
Return


/*/{Protheus.doc} function ProcAnt(cGrpEmp, cMsg, aParam)
Salva os parâmetros no banco para autenticar integrações do TOTVS Consignado.
@param oPanel, object, painel onde será montada a tela
@since   04/06/2021
@version 1.0
/*/
Static Function ProcAnt(cGrpEmp, cMsg, aParam)
  Local lRet     := .F.
  fUpdSX6("MV_CONSIG ", ".T.", STR0007, "L") // "Chave de ativação TOTVS Consignado."
  lRet := GetMv("MV_CONSIG",  .F., .F.)

  If lRet
    cMsg := STR0005 // "Sucesso na configuração do Connector Protheus!"
  Else
    cMsg := STR0006 // "Parâmetros não puderam ser gravados"
  EndIf
Return lRet


/*/{Protheus.doc} function fmakeStep(oPanel)
Monta o layout para a página de informações da Integração
@param oPanel, object, painel onde será montada a tela
@since   04/06/2021
@version 1.0
/*/
Static Function fmakeStep(oPanel)
    Local aParam  := Array(5)

    aParam[1] := Space(32)
    aParam[2] := Space(32)
    aParam[3] := Space(36)
    aParam[4] := Space(32)
    aParam[5] := Space(32)
 
    @ 010, 045 GROUP TO 55, 360 PROMPT "Dados 1" of oPanel PIXEL
 
    @ 025, 055 SAY "Dados" SIZE 200,20 OF oPanel PIXEL
    @ 032, 055 MSGET aParam[4] SIZE 110, 09 OF oPanel PIXEL
 
    @ 025, 175 SAY "Dados " SIZE 200,20 OF oPanel PIXEL
    @ 032, 175 MSGET aParam[5] SIZE 110, 09 OF oPanel PIXEL
 
    @ 066, 45 GROUP TO 130, 360 PROMPT "Dados 2" of oPanel PIXEL
 
    @ 075, 055 SAY "Dados" SIZE 200,20 OF oPanel PIXEL
    @ 082, 055 MSGET aParam[1] SIZE 110, 09 OF oPanel PIXEL
 
    @ 075, 175 SAY "Dados" SIZE 200,20 OF oPanel PIXEL
    @ 082, 175 MSGET aParam[2] SIZE 110, 09  OF oPanel PIXEL
 
    @ 102, 055 SAY "Dados" SIZE 200,20 OF oPanel PIXEL
    @ 109, 055 MSGET aParam[3] SIZE 110, 09 OF oPanel PIXEL
Return aParam
