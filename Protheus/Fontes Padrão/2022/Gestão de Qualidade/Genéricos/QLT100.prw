#INCLUDE "TOTVS.CH"
#INCLUDE 'FWEditPanel.ch'
#INCLUDE 'QLT100.ch'

#DEFINE MB_ICONEXCLAMATION 48

/*/{Protheus.doc} QLT100
Wizard de anonimiza��o de matr�cula
@type  Function
@author guilherme.bertoldi
@since 13/04/2022
@version P12.1.33
/*/
Main Function QLT100()
    Local  oClass := QLT100Class():New()
    oClass:MontaWizard()
Return

/*/{Protheus.doc} QLT100Class
Regras de Negocio - Wizard de anonimiza��o de matr�cula
@Type Class
@author guilherme.bertoldi
@since 13/04/2022
/*/
CLASS QLT100Class FROM LongClassName

    DATA cMatricula as STRING
	
    METHOD new() CONSTRUCTOR
    METHOD Etapa1(oPanel)
    METHOD ExecutaAnonimizacao()
    METHOD MontaWizard()
    METHOD ValidaMatricula()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author guilherme.bertoldi
@since 31/03/2022

@return Self, objeto, instancia da Classe QLT100Class
/*/
METHOD new() CLASS QLT100Class
    Self:cMatricula := Space(GetSx3Cache("QAA_MAT", "X3_TAMANHO"))
Return Self

/*/{Protheus.doc} MontaWizard
Monta Estrutura do Wizard

@type  Function
@author celio.pereira
@since 28/07/2022
@version P12.1.33
/*/

METHOD MontaWizard() CLASS QLT100Class
    Local oNewPag     := Nil
    Static oStepWiz   := Nil

    oStepWiz:= FWWizardControl():New(,{ 530, 720 })
    oStepWiz:ActiveUISteps()

    oStepWiz:SetCancelTitle(STR0001) //"Fechar"
    oStepWiz:SetNextTitle(STR0002) //"Anonimizar"

    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0003) //"Anonimiza��o LGPD"
    oNewPag:SetConstruction({ |oPanel| Self:Etapa1(oPanel) })
    oNewPag:SetNextAction({|oMdl| Self:ExecutaAnonimizacao(oMdl)}, Nil, {}, .F., , .F., .F., .F., , )

	oStepWiz:Activate()
    oStepWiz:Destroy()

Return

/*/{Protheus.doc} Etapa1
Monta Etapa 1 do Wizard

@type  Function
@author guilherme.bertoldi
@since 13/04/2022
@version P12.1.33

@param 01 - oPanel, objeto, painel para exibi��o da etapa
/*/
METHOD Etapa1(oPanel) CLASS QLT100Class

    Local oCHFont   := TFont():New('Arial', , -11, .T., .T.)
	Local oCMFont   := TFont():New('Arial', , -14,.T.)
    Local oTGet1    := Nil
 
    @ 5, 5 GROUP TO 165, 360 PROMPT STR0004 OF oPanel PIXEL //"Digite os dados para anonimiza��o:"
    @ 20, 10 SAY  STR0005 OF oPanel PIXEL FONT oCHFont //"C�digo da Matr�cula:"
    @ 30, 10 MSGET oTGet1 VAR self:cMatricula SIZE 80, 10 F3 "QAA" OF oPanel Font oCMFont PIXEL

    TSay():New(50 , 15, {||  STR0006 }, oPanel, , oCMFont, , , , .T., , , 330, 20) //"Bem vindo(a)!"
    TSay():New(70 , 15, {||  STR0007 }, oPanel, , oCMFont, , , , .T., , , 330, 20) //"Esta rotina permite anonimizar dados de usu�rios/funcion�rios considerados pessoais/sens�veis referente a LGPD (Lei Geral de Prote��o de Dados)."
    TSay():New(90 , 15, {||  STR0008 }, oPanel, , oCMFont, , , , .T., , , 330, 30) //"Caso um usu�rio seja desligado e solicitei a anonimiza��o, os dados pessoais/sens�veis passar�o pelo processo de modifica��o e grava��o em banco de dados, n�o sendo poss�veis de serem reidentificados. "

    oTGet1:SetFocus()

Return

/*/{Protheus.doc} ExecutaAnonimizacao
Chama a anonimiza��o do fonte QLTLGPD.

@type  Function
@author guilherme.bertoldi
@since 13/04/2022
@version P12.1.33

@return .T,, l�gico, Evita que a tela seja fechada ap�s a execu��o da anonimiza��o.
/*/
METHOD ExecutaAnonimizacao() CLASS QLT100Class
    If Self:ValidaMatricula()
        QLTLGPD(Self:cMatricula)
    EndIf
Return .F.

/*/{Protheus.doc} ValidaMatricula
Verifica se o campo matr�cula est� vazio.

@type  Function
@author guilherme.bertoldi
@since 13/04/2022
@version P12.1.33

@return lReturn, l�gico, indica se o campo matricula foi preenchido.
/*/
METHOD ValidaMatricula() CLASS QLT100Class
    Local lReturn := .T.

    If Empty(Self:cMatricula)
        lReturn := .F.
        MessageBox( STR0009, STR0010, MB_ICONEXCLAMATION ) //"Informe a matr�cula para anonimiza��o." //"ATEN��O!"
    EndIf

Return lReturn
