#include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#include 'GPEA941A.CH'

Static lIntTaf       := SuperGetMv("MV_RHTAF",, .F.) //Integracao com TAF
Static lMiddleware   := If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static lOk           := (lIntTaf .Or. lMiddleware)

/*/{Protheus.doc} GPEA941A
Cadastro dos Processos da Verba
@author Allyson Mesashi
@since 03/03/2020
@version P12.1.27
@Type     Function
/*/
Function GPEA941A()

Local oMBrowse

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("SRV")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //Processos da Verba

If !lOk
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0017), 1, 0 )//"Atenção"#"A rotina somente deverá ser utilizada quando a integração do eSocial estiver ativa"
	Return
EndIf

If !ChkFile("RJG")
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0003), 1, 0 )//"Atenção"#"Tabela RJG não encontrada. Execute o UPDDISTR - Atualizador de dicionário e base de dados."
	Return
EndIf

If FWModeAccess("RJG", 1)+FWModeAccess("RJG", 2)+FWModeAccess("RJG", 3) != FWModeAccess("SRV", 1)+FWModeAccess("SRV", 2)+FWModeAccess("SRV", 3)
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0004), 1, 0 )//"Atenção"#"O modo de acesso da tabela RJG deve ser idêntico ao da tabela SRV"
	Return
EndIf

oMBrowse:SetLocate()
GpLegMVC(@oMBrowse)

oMBrowse:ExecuteFilter(.T.)

oMBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Definição do MenuDef
@type function
@author Allyson Mesashi
@since 03/03/2020
@version 1.0
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'PesqBrw'           OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA941A'   OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0007)  Action 'VIEWDEF.GPEA941A'   OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0008)  Action 'VIEWDEF.GPEA941A'   OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição e detalhamento do Model
@type function
@author Allyson Mesashi
@since 03/03/2020
@version 1.0
/*/
Static Function ModelDef()

Local oMdl
Local oStruSRV      := FWFormStruct(1, 'SRV', /*bAvalCampo*/,/*lViewUsado*/)
Local oStruRJG      := FWFormStruct(1, 'RJG', /*bAvalCampo*/,/*lViewUsado*/)
Local bLinePos 	    := {|oMdlRJG| GP941LOk(oMdl)}
Local bLinePre 	    := {|oMdlRJG| GP941LPre(oMdl)}
Local bPosValid	    := {|oMdlRJG| GP941Pos(oMdl)}

oMdl := MPFormModel():New('GPEA941A', /*bPreValid */, bPosValid, /*bCommit*/, /*bCancel*/)

oMdl:AddFields('SRVMASTER', /*cOwner*/, oStruSRV, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

oMdl:AddGrid( 'RJGDETAIL', 'SRVMASTER', oStruRJG, bLinePre, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oMdl:SetRelation('RJGDETAIL', {{'RJG_FILIAL', 'RV_FILIAL'}, {'RJG_COD', 'RV_COD'}}, RJG->(IndexKey(1)))

oMdl:GetModel('RJGDETAIL'):SetUniqueLine({'RJG_FILIAL', 'RJG_COD', 'RJG_COMPET', 'RJG_TP', 'RJG_TPPROC', 'RJG_NRPROC', 'RJG_EXTDEC', 'RJG_CSUSP'})
oMdl:GetModel('RJGDETAIL'):SetMaxLine(99)

//Permite grid sem dados
oMdl:GetModel('RJGDETAIL'):SetOptional(.T.)
oMdl:GetModel('SRVMASTER'):SetOnlyView(.T.)
oMdl:GetModel('SRVMASTER'):SetOnlyQuery(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oMdl:GetModel('SRVMASTER'):SetDescription(OemToAnsi(STR0009)) // "Verba"

// VALIDA AS VERSÕES DO ESOCIAL.
oMdl:SetVldActivate({|oModel| Iif(FindFunction("fVldDifVer"), fVldDifVer(oMdl, @lIntTAF), .T.)})

Return oMdl

/*/{Protheus.doc} ViewDef
Definição da viewdef
@type method
@author Allyson Mesashi
@since 03/03/2020
@version 1.0
/*/
Static Function ViewDef()

Local oView
Local cCampos       := "RV_FILIAL|RV_COD|RV_DESC"
Local oModel        := FWLoadModel('GPEA941A')
Local oStruSRV      := FWFormStruct(2, 'SRV')
Local oStruRJG      := FWFormStruct(2, 'RJG')
Local aCampos       := aClone(oStruSRV:aFields)
Local nCont         := 0

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SRV', oStruSRV, 'SRVMASTER')
oStruSRV:SetNoFolder()

oView:AddGrid('VIEW_RJG', oStruRJG, 'RJGDETAIL')

For nCont := 1 To Len(aCampos)
    If !(aCampos[nCont, 1] $ cCampos)
        oStruSRV:RemoveField(aCampos[nCont, 1])
    EndIf
Next nCont
oStruRJG:RemoveField("RJG_COD")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 15)
oView:CreateHorizontalBox('INFERIOR', 85)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRV', 'SUPERIOR')
oView:SetOwnerView('VIEW_RJG', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRV', OemToAnsi(STR0009)) // "Verba"
oView:EnableTitleView('VIEW_RJG', OemToAnsi(STR0001)) // "Processos da Verba"

oView:SetCloseOnOk({ || .T. })	//Desabilita botão "Salvar e Criar Novo"
oView:SetViewCanActivate({|oView| fVldView(oView)})

Return oView

/*/{Protheus.doc} GP941LOk
Linhao Ok
@type      	Static Function
@author Allyson Mesashi
@since 03/03/2020
@version	1.0
@param		oMdlRJG, 	object, 	Objeto da Grid a ser validada
@return		lRet,		logic
/*/

Static Function GP941LOk(oMdlRJG)

Local cCSusp    := ""
Local cExtDec   := ""
Local cTp       := ""
Local cTpProc   := ""
Local lRet 	    := .T.
Local oGrid     := oMdlRJG:GetModel("RJGDETAIL")
Local oModel    := oMdlRJG:GetModel("SRVMASTER")
Local cVersGPE	:= ""

If( FindFunction("fVersEsoc"),fVersEsoc( "S1010", .F.,,,, @cVersGPE),)
Begin Sequence
    If !oGrid:IsDeleted()
        cCSusp  := Alltrim(oGrid:GetValue("RJG_CSUSP"))
        cExtDec := Alltrim(oGrid:GetValue("RJG_EXTDEC"))
        cTp     := Alltrim(oGrid:GetValue("RJG_TP"))
        cTpProc := Alltrim(oGrid:GetValue("RJG_TPPROC"))
        If cTp == "1" .And. !(oModel:GetValue("RV_INCCP") $ "91/92/93/94/95/96/97/98")
            lRet := .F.
            Help( , , OemtoAnsi(STR0002), , OemtoAnsi(STR0010), 1, 0)// "Dados de processo devem ser vinculados a verbas cujo a incidência esteja suspensa em decorrência de decisão judicial. Para o tipo de contribuição/tributo 1, o campo 'Cd.Inc.CP' da verba deve estar preenchido com um valor entre 91 a 98"
            Break
        EndIf
        If cTp == "2" .And. !(Left(oModel:GetValue("RV_INCIRF"),1) == "9")
            lRet := .F.
            Help( , , OemtoAnsi(STR0002), , OemtoAnsi(STR0011), 1, 0)// "Dados de processo devem ser vinculados a verbas cujo a incidência esteja suspensa em decorrência de decisão judicial. Para o tipo de contribuição/tributo 2, o campo 'Cd.Inc.IRRF' da verba deve estar preenchido com um valor iniciado por '9'"
            Break
        EndIf
        If cTp == "3" .And. !(oModel:GetValue("RV_INCFGTS") $ "91|92|93")
            lRet := .F.
            Help( , , OemtoAnsi(STR0002), , OemToAnsi(If(cVersGPE < '9.0', STR0012, STR0022)), 1, 0)// "Dados de processo devem ser vinculados a verbas cujo a incidência esteja suspensa em decorrência de decisão judicial. Para o tipo de contribuição/tributo 3, o campo 'Cd.Inc.FGTS' da verba deve estar preenchido com o valor 91" ou "com um valor entre 91 a 93"
            Break
        EndIf
        If cTp == "4" .And. cVersGPE < '9.0' .And. oModel:GetValue("RV_INCSIND") != "91"
            lRet := .F.
            Help( , , OemtoAnsi(STR0002), , OemtoAnsi(STR0013), 1, 0)// "Dados de processo devem ser vinculados a verbas cujo a incidência esteja suspensa em decorrência de decisão judicial. Para o tipo de contribuição/tributo 4, o campo 'Cd.Inc.Sind.' da verba deve estar preenchido com o valor 91"
            Break
        EndIf
        If cTp == "1" .And. Empty(cTpProc)
            lRet := .F.
            Help( , , OemtoAnsi(STR0002), , OemtoAnsi(STR0014), 1, 0)// "O preenchimento do Tipo de Processo é obrigatório quando o tipo da contribuição/tributo for 1"
            Break
        EndIf
        If cTp == "1" .And. Empty(cExtDec)
            lRet := .F.
            Help( , , OemtoAnsi(STR0002), , OemtoAnsi(STR0015), 1, 0)// "O preenchimento da Extensão da Decisão/Sentença é obrigatória quando o tipo da contribuição/tributo for 1"
            Break
        EndIf
        If cTp $ "1/2" .And. Empty(cCSusp)
            lRet := .F.
            Help( , , OemtoAnsi(STR0002), , OemtoAnsi(STR0016), 1, 0)// "O preenchimento do Código Indicativo da Suspensão é obrigatório quando o tipo da contribuição/tributo for 1 ou 2"
            Break
        EndIf
        If cTp != "1" .And. !Empty(cTpProc)
            lRet := .F.
            Help( , , OemtoAnsi(STR0002), , OemtoAnsi(STR0018), 1, 0)// "O preenchimento do Tipo de Processo somente é permitido quando o tipo da contribuição/tributo for 1"
            Break
        EndIf
        If cTp != "1" .And. !Empty(cExtDec)
            lRet := .F.
            Help( , , OemtoAnsi(STR0002), , OemtoAnsi(STR0019), 1, 0)// "O preenchimento da Extensão da Decisão/Sentença somente é permitido quando o tipo da contribuição/tributo for 1"
            Break
        EndIf
        If !(cTp $ "1/2") .And. !Empty(cCSusp)
            lRet := .F.
            Help( , , OemtoAnsi(STR0002), , OemtoAnsi(STR0020), 1, 0)// "O preenchimento do Código Indicativo da Suspensão somente é permitido quando o tipo da contribuição/tributo for 1 ou 2"
            Break
        EndIf
    EndIf
End Sequence

Return lRet

/*/{Protheus.doc} GP941LPre
Linha Ok
@type      	Static Function
@author Allyson Mesashi
@since 03/03/2020
@version	1.0
@param		oMdlRJG, 	object, 	Objeto da Grid a ser validada
@return		lRet,		logic
/*/
Static Function GP941LPre(oMdlRJG)

Local lRet 	    := .T.
Local oGrid     := oMdlRJG:GetModel("RJGDETAIL")

oGrid:LoadValue("RJG_FILIAL", oMdlRJG:GetModel("SRVMASTER"):GetValue("RV_FILIAL"))
oGrid:LoadValue("RJG_COD", oMdlRJG:GetModel("SRVMASTER"):GetValue("RV_COD"))

Return lRet

/*/{Protheus.doc} gp941AVerEdit
Verifica se habilita edição do campo
@type      	Static Function
@author Allyson Mesashi
@since 03/03/2020
@version	1.0
@return		lEdit,		logic
/*/
Function gp941AVerEdit()

Local lEdit 		:= .F.
Local cVar			:= ReadVar()
Local oModel		:= FWModelActivate()
Local oGrid 		:= oModel:GetModel("RJGDETAIL")

If cVar == "M->RJG_TPPROC" .And. oGrid:GetValue("RJG_TP") == "1"
	lEdit := .T.
ElseIf cVar == "M->RJG_EXTDEC" .And. oGrid:GetValue("RJG_TP") == "1"
    lEdit := .T.
ElseIf cVar == "M->RJG_CSUSP" .And. oGrid:GetValue("RJG_TP") $ "1/2"
    lEdit := .T.
EndIf

Return lEdit

/*/{Protheus.doc} fVldView
Valida abertura da view
@type      	Static Function
@author Allyson Mesashi
@since 03/03/2020
@version	1.0
@return		lEdit,		logic
/*/
Static Function fVldView(oView)

Local lRet := .T.
Local aArea  := GetArea()
Local oModel := oView:GetModel()

oModel:Activate()

If !ChkFile("RJG")
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0003), 1, 0 )//"Atenção"#"Tabela RJG não encontrada. Execute o UPDDISTR - Atualizador de dicionário e base de dados."
	Return
EndIf

If FWModeAccess("RJG", 1)+FWModeAccess("RJG", 2)+FWModeAccess("RJG", 3) != FWModeAccess("SRV", 1)+FWModeAccess("SRV", 2)+FWModeAccess("SRV", 3)
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0004), 1, 0 )//"Atenção"#"O modo de acesso da tabela RJG deve ser idêntico ao da tabela SRV"
	Return
EndIf

oModel:DeActivate()

RestArea(aArea)

Return lRet

/*/{Protheus.doc} GP941Pos
PosValid da rotina GPEA941A
@type      	Static Function
@author Allyson Mesashi
@since 05/03/2020
@version	1.0
@return		lEdit,		logic
/*/
Static Function GP941Pos(oModel)

Local lRet := .T.

lRet := Gpea040TudOk(oModel, .T.)

Return lRet
