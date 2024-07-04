#include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#include 'GPEA941.CH'

Static lIntTaf       := SuperGetMv("MV_RHTAF",, .F.) //Integracao com TAF
Static lMiddleware   := If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static lOk           := (lIntTaf .Or. lMiddleware)

/*/{Protheus.doc} GPEA941
Cadastro dos Processos do Funcionário
@author Allyson Mesashi
@since 02/03/2020
@version P12.1.27
@Type     Function
/*/
Function GPEA941()

Local oMBrowse

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("SRA")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //Processos do Funcionário

If !lOk
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0013), 1, 0 )//"Atenção"#"A rotina somente deverá ser utilizada quando a integração do eSocial estiver ativa"
	Return
EndIf

If !ChkFile("RJJ")
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0003), 1, 0 )//"Atenção"#"Tabela RJJ não encontrada. Execute o UPDDISTR - Atualizador de dicionário e base de dados."
	Return
EndIf

If FWModeAccess("RJJ", 1)+FWModeAccess("RJJ", 2)+FWModeAccess("RJJ", 3) != "EEE"
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0012), 1, 0 )//"Atenção"#"O modo de acesso da tabela RJJ deve ser exclusivo"
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
@since 02/03/2020
@version 1.0
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'PesqBrw'           OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA941'   OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA941'   OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0007)  Action 'VIEWDEF.GPEA941'   OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição e detalhamento do Model
@type function
@author Allyson Mesashi
@since 02/03/2020
@version 1.0
/*/
Static Function ModelDef()

Local oMdl
Local bAvalCampo    := {|cCampo| AllTrim(cCampo)+"|" $ "|RA_FILIAL|RA_MAT|RA_NOME|RA_CIC|RA_CODUNIC|"}
Local oStruSRA      := FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRJJ      := FWFormStruct(1, 'RJJ', /*bAvalCampo*/,/*lViewUsado*/)
Local bPosValid 	:= {|oMdlRJJ| Gp941CPosVal(oMdl)}
Local bLinePos 	    := {|oMdlRJJ| GP941LOk(oMdl)}
Local bLinePre 	    := {|oMdlRJJ| GP941LPre(oMdl)}

oMdl := MPFormModel():New('GPEA941', /*bPreValid */, bPosValid, /*bCommit*/, /*bCancel*/)

oMdl:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

oMdl:AddGrid( 'RJJDETAIL', 'SRAMASTER', oStruRJJ, bLinePre, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oMdl:SetRelation('RJJDETAIL', {{'RJJ_FILIAL', 'RA_FILIAL'}, {'RJJ_MAT', 'RA_MAT'}}, RJJ->(IndexKey(1)))

oMdl:GetModel('RJJDETAIL'):SetUniqueLine({'RJJ_FILIAL', 'RJJ_MAT', 'RJJ_COMPET', 'RJJ_TP', 'RJJ_NRPROC', 'RJJ_CSUSP'})
oMdl:GetModel('RJJDETAIL'):SetMaxLine(99)

//Permite grid sem dados
oMdl:GetModel('RJJDETAIL'):SetOptional(.T.)
oMdl:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdl:GetModel('SRAMASTER'):SetOnlyQuery(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oMdl:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0008)) // "Funcionários"

// VALIDA AS VERSÕES DO ESOCIAL.
oMdl:SetVldActivate({|oModel| fVldDifVer(oMdl)})

Return oMdl

/*/{Protheus.doc} ViewDef
Definição da viewdef
@type method
@author Allyson Mesashi
@since 02/03/2020
@version 1.0
/*/
Static Function ViewDef()

Local oView
Local bAvalCampo    := {|cCampo| AllTrim(cCampo)+"|" $ "|RA_FILIAL|RA_MAT|RA_NOME|RA_CIC|"}
Local oModel        := FWLoadModel('GPEA941')
Local oStruSRA      := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRJJ      := FWFormStruct(2, 'RJJ')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')
oStruSRA:SetNoFolder()

oView:AddGrid('VIEW_RJJ', oStruRJJ, 'RJJDETAIL')

oStruSRA:RemoveField("RA_CIC")
oStruRJJ:RemoveField("RJJ_MAT")
oStruRJJ:RemoveField("RJJ_CPF")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 15)
oView:CreateHorizontalBox('INFERIOR', 85)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RJJ', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0008)) // "Funcionário"
oView:EnableTitleView('VIEW_RJJ', OemToAnsi(STR0001)) // "Processos do Funcionário"

oView:SetCloseOnOk({ || .T. })	//Desabilita botão "Salvar e Criar Novo"
oView:SetViewCanActivate({|oView| fVldView(oView)})

Return oView

/*/{Protheus.doc} Gp941CPosVal
Pos-validacao do Cadastro
@type      	Static Function
@author Allyson Mesashi
@since 02/03/2020
@version	1.0
@param		oMdlRJJ, object, Modelo a ser validado
@return		lRet
/*/

Static Function Gp941CPosVal( oMdlRJJ )

Local aAreaRJJ      := RJJ->( GetArea() )
Local cCPF          := oMdlRJJ:GetModel("SRAMASTER"):GetValue("RA_CIC")
Local cFilMat       := oMdlRJJ:GetModel("SRAMASTER"):GetValue("RA_FILIAL") + oMdlRJJ:GetModel("SRAMASTER"):GetValue("RA_MAT")
Local lRet          := .T.
Local nCont         := 0
Local nOperation    := oMdlRJJ:GetOperation()
Local oGrid         := oMdlRJJ:GetModel("RJJDETAIL")

RJJ->( dbSetOrder(2) )
If nOperation == MODEL_OPERATION_UPDATE
    For nCont := 1 To oGrid:Length()
        oGrid:GoLine(nCont)
        If RJJ->( dbSeek( cCPF ) )
            While RJJ->( !EoF() ) .And. RJJ->RJJ_CPF == cCPF
                If RJJ->RJJ_FILIAL+RJJ->RJJ_MAT != cFilMat .And. RJJ->RJJ_TP+RJJ->RJJ_NRPROC+RJJ->RJJ_CSUSP == oGrid:GetValue("RJJ_TP")+oGrid:GetValue("RJJ_NRPROC")+oGrid:GetValue("RJJ_CSUSP")
                    lRet := .F.
                    Help( , , OemtoAnsi(STR0002), , OemtoAnsi(STR0009 + RJJ->RJJ_FILIAL + STR0010 + RJJ->RJJ_MAT), 1, 0)	// "Processo já foi informado na Filial: "#" Matrícula: "
                    Exit
                EndIf
                RJJ->( dbSkip() )
            EnddO
        EndIf
    Next nCont
EndIf

RestArea(aAreaRJJ)

Return lRet

/*/{Protheus.doc} GP941LOk
Linhao Ok
@type      	Static Function
@author Allyson Mesashi
@since 02/03/2020
@version	1.0
@param		oMdlRJJ, 	object, 	Objeto da Grid a ser validada
@return		lRet,		logic
/*/

Static Function GP941LOk(oMdlRJJ)

Local cCompet   := ""
Local cTp       := ""
Local cCSusp    := ""
Local lRet 	    := .T.
Local oGrid     := oMdlRJJ:GetModel("RJJDETAIL")

Begin Sequence
    If !oGrid:IsDeleted()
        cCompet := Alltrim(oGrid:GetValue("RJJ_COMPET"))
        cTp     := Alltrim(oGrid:GetValue("RJJ_TP"))
        cCSusp  := Alltrim(oGrid:GetValue("RJJ_CSUSP"))
        If cTp $ "1/2" .And. Empty(cCSusp)
            lRet := .F.
            Help( , , OemtoAnsi(STR0002), , OemtoAnsi(STR0011), 1, 0)// "O preenchimento do Código Indicativo da Suspensão é obrigatório quando o tipo da contribuição/tributo for 1 ou 2"
            Break
        EndIf
    EndIf
End Sequence

Return lRet

/*/{Protheus.doc} GP941LPre
Linhao Ok
@type      	Static Function
@author Allyson Mesashi
@since 02/03/2020
@version	1.0
@param		oMdlRJJ, 	object, 	Objeto da Grid a ser validada
@return		lRet,		logic
/*/

Static Function GP941LPre(oMdlRJJ)

Local lRet 	    := .T.
Local oGrid     := oMdlRJJ:GetModel("RJJDETAIL")

oGrid:LoadValue("RJJ_FILIAL", oMdlRJJ:GetModel("SRAMASTER"):GetValue("RA_FILIAL"))
oGrid:LoadValue("RJJ_MAT", oMdlRJJ:GetModel("SRAMASTER"):GetValue("RA_MAT"))
oGrid:LoadValue("RJJ_CPF", oMdlRJJ:GetModel("SRAMASTER"):GetValue("RA_CIC"))

Return lRet

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

If !ChkFile("RJJ")
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0003), 1, 0 )//"Atenção"#"Tabela RJJ não encontrada. Execute o UPDDISTR - Atualizador de dicionário e base de dados."
	Return
EndIf

If FWModeAccess("RJJ", 1)+FWModeAccess("RJJ", 2)+FWModeAccess("RJJ", 3) != "EEE"
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0012), 1, 0 )//"Atenção"#"O modo de acesso da tabela RJJ deve ser exclusivo"
	Return
EndIf

oModel:DeActivate()

RestArea(aArea)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} fVldDifVer
Funcao que valida a diferença entre as versões do eSocial X TAF.

@author		Silvio C. Stecca
@since		08/02/2021
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Function fVldDifVer(oModel, lIntTAF)
	
    Local cVersEnvio    := ""
    Local cVersGPE		:= ""
    Local cVerTaf		:= StrTran(StrTran(SuperGetMv("MV_TAFVLES",, "2.4"), "_", "."), "0", "", 1, 2)
    Local lOk           := .T.

    Default lIntTAF     := .T.

    // RECEBE A VERSÃO DO TAF.
    cVerTaf := StrTran(Iif(cVerTaf == "2.4.01", "2.4", cVerTaf), "S.1", "9")

    If lIntTaf .And. !lMiddleware .And. cPaisLoc == 'BRA' .And. FindFunction("fVersEsoc")
        fVersEsoc("S2200", .F.,,, @cVersEnvio, @cVersGPE,,, "")

        If Empty(cVersGPE)
            cVersGPE := cVersEnvio
        EndIf

        //"Atenção! A versão do leiaute GPE é xxx e a do TAF é xxx, sendo assim, estão divergentes. O Evento não será integrado com o TAF, e consequentemente, não será enviado ao RET.
        //Caso prossiga a informação será atualizada somente na base do GPE. Deseja continuar?"
        If cVersGPE >= '9.0' .And. cVerTaf <> cVersGPE 
            If (IsBlind() .Or. MsgNoYes(OemToAnsi(STR0014) + cVersGPE + OemToAnsi(STR0015) + cVersEnvio + OemToAnsi(STR0016 + CRLF + STR0017), OemtoAnsi(STR0002)))
                lIntTaf := .F.
            Else
	            Help("", 1, "DIFVERESOC",, + CRLF + OemToAnsi(STR0018), 1, 0 )//"Atenção"#"O cadastro de processos não será exibido."
                lOk := .F.
            EndIf
        EndIf
    EndIf

Return lOk
