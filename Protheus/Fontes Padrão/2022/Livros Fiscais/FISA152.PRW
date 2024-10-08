#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA152

@author Erick G. Dias
@since 05/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FISA152(cDescr, cFiltro)
Local   oBrowse := Nil
Default cFiltro := ""
oBrowse := FWMBrowse():New()
oBrowse:SetAlias(FSA200ALIAS())
oBrowse:SetDescription(cDescr) // Descri��o

IF !EmptY(cFiltro)
    oBrowse:SetFilterDefault( cFiltro )
EndIF

oBrowse:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Erick G. Dias
@since 05/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

If FSA200ALIAS() $ 'F19/F1B/SE2'
    ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.FISA152' OPERATION 2 ACCESS 0 //"Visualizar"
Else
    ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.FISA152' OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE "Incluir" ACTION 'VIEWDEF.FISA152' OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE "Alterar" ACTION 'VIEWDEF.FISA152' OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE "Excluir" ACTION 'VIEWDEF.FISA152' OPERATION 5 ACCESS 0 //"Excluir"
EndIF

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Erick G. Dias
@since 05/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruGener      :=	FWFormStruct( 1, FSA200ALIAS(), {|cCampo| FSA152STRU(cCampo)}) // Campo criado indevidamente, deletado no ATUSX, mas o UPDDISTR cria mesmo assim.
Local oModel
Local aAux := {}
Local cCmpoPK	:= Iif(SubStr(FSA200ALIAS(),1,1) == 'S',SubStr(FSA200ALIAS(),2,2),FSA200ALIAS())+ '_FILIAL'

oModel	:=	MPFormModel():New('FISA152',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })

IF FSA200ALIAS() == "F14"
    oStruGener:SetProperty('F14_UF'        , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
    oStruGener:SetProperty('F14_INIVIG'    , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
ElseIF FSA200ALIAS() == "F15"
    oStruGener:SetProperty('F15_MES'       , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
    oStruGener:SetProperty('F15_ANO'       , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
    oStruGener:SetProperty('F15_TPREC'     , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
ElseIF FSA200ALIAS() == "F1C"
    oStruGener:SetProperty('F1C_MES'       , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
    oStruGener:SetProperty('F1C_ANO'       , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
ElseIf FSA200ALIAS() == "F1D"
    oStruGener:SetProperty('F1D_MES'       , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
    oStruGener:SetProperty('F1D_ANO'       , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
    oStruGener:SetProperty('F1D_MESUTI'    , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
    oStruGener:SetProperty('F1D_ANOUTI'    , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
    oStruGener:SetProperty('F1D_CODATV'    , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
    oStruGener:SetProperty('F1D_SUBATV'    , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
    oStruGener:SetProperty('F1D_ANEXO'     , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
    oStruGener:SetProperty('F1D_TPREC'     , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
EndIF

oModel:AddFields( 'MODEL_GEN' ,, oStruGener )
//A passagem de chave prim�ria para o modelo se deve ao fato de existirem tabelas do legado do sistema que n�o possuem
//chave prim�ria definida X2_UNICO, para estas tabelas exibe erro.
//Por este motivo passo de forma gen�rica a filial para o modelo para n�o ficar sem nenhuma chave prim�ria
//e exibir tanto as tabelas que est� corretas quanto as tabelas de legado.

oModel:SetPrimaryKey( { cCmpoPK } )

If TYPE("cFsa200DESC") <> "U" .AND. !Empty(cFsa200DESC)
    oModel:SetDescription( cFsa200DESC )
EndIF

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Erick G. Dias
@since 05/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local	oModel 			:= 	FWLoadModel( 'FISA152' )
Local	oStruGener 	    := 	Nil
Local	oView 			:= 	FWFormView():New()
Local   cDescri			:= 'Visualiza��o'
Local   cAlias          := FSA200ALIAS()

oView:SetModel( oModel )
oStruGener	:= 	FWFormStruct( 2, cAlias,  {|cCampo| FSA152STRU(cCampo)})
oView:AddField( 'VIEW_GEN', oStruGener, 'MODEL_GEN' )

If cAlias == "F14"
    oStruGener:RemoveField( 'F14_ID' )
ElseIf cAlias == "F15"
    oStruGener:RemoveField( 'F15_ID' )
ElseIf cAlias == "F1B"
    oStruGener:RemoveField( 'F1B_FILIAL' )
ElseIf cAlias == "F1C"
    oStruGener:RemoveField( 'F1C_ID' )
ElseIf cAlias == "F1D"
    oStruGener:RemoveField( 'F1D_ID' )
    oStruGener:RemoveField( 'F1D_IDAPUR' )
EndIF

oView:EnableTitleView( 'VIEW_GEN', cDescri )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Fun��o para selecionar os campos que dever�o fazer parte do modelo.

@author joao.pellegrini
@since 10/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function FSA152STRU(cCampo)

Local cAlias := FSA200ALIAS()
Local lRet := .T.

If cAlias == "F14" .And. AllTrim(cCampo) == "F14_ANEXO"
    lRet := .F.
EndIf

Return lRet

Static Function VALIDACAO( oModel )

Local nOperation 	:= oModel:GetOperation()

Local cUf 	    := ''
Local dDtIni
Local cTpRec	:= ''
Local cMes      := ''
Local cAno      := ''
Local cAnexo    := ''
Local lRet      := .T.
Local cMesUti   := ''
Local cAnoUti   := ''
Local cAtiv     := ''
Local cSubAtiv  := ''
Local cTpRec    := ''
Local nIndex    := 0

// Obtenho o �ndice atual da tabela para restaurar posteriormente.
nIndex := (FSA200ALIAS())->(IndexOrd())

//Cadastro de Limites do Simples
IF cAlias := FSA200ALIAS() == "F14"

    //N�o pode permitir gravar mesma UF para mesma dada de vig�ncia
    cUf 		:= oModel:GetValue ('MODEL_GEN',"F14_UF")
    dDtIni	    := oModel:GetValue ('MODEL_GEN',"F14_INIVIG")

     F14->(dbSetOrder(1))

    IF nOperation == MODEL_OPERATION_INSERT

        If	F14->( MsSeek ( xFilial('F14') + cUf + dTos(dDtIni) ) )
            //J� existe Limite para UF e mesma data de in�cio de vig�ncia
            lRet:= .F.
            Help( ,, 'Help',, "J� existe Limite para esta UF e esta data de vig�ncia inicial", 1, 0 ) //"Anexo j� cadastrado para este in�cio de vig�ncia."
        EndIF

    EndIF

ElseIF cAlias := FSA200ALIAS() == "F15"

    //N�o pode gravar para mesmo per�odo e mesmo tipo de receita
    cMes 		:= oModel:GetValue ('MODEL_GEN',"F15_MES")
    cAno 		:= oModel:GetValue ('MODEL_GEN',"F15_ANO")
    cTpRec 		:= oModel:GetValue ('MODEL_GEN',"F15_TPREC")

    F15->(dbSetOrder(1))

    IF nOperation == MODEL_OPERATION_INSERT

        If	F15->( MsSeek ( xFilial('F15') +  cAno + cMes  + cTpRec ) )
            //J� existe Limite para UF e mesma data de in�cio de vig�ncia
            lRet:= .F.
            Help( ,, 'Help',, "J� existe Valor gravado para este per�odo e tipo de receita", 1, 0 ) //"Anexo j� cadastrado para este in�cio de vig�ncia."
        EndIF

    EndIf

ElseIF cAlias := FSA200ALIAS() == "F1C"

    cMes 		:= oModel:GetValue ('MODEL_GEN',"F1C_MES")
    cAno 		:= oModel:GetValue ('MODEL_GEN',"F1C_ANO")

    F1C->(dbSetOrder(1))

    IF nOperation == MODEL_OPERATION_INSERT

        If	F1C->( MsSeek ( xFilial('F1C') +  cAno + cMes ) )
            //J� existe encargo para o per�odo.
            lRet:= .F.
            Help( ,, 'Help',, "J� existe Valor gravado para este per�odo", 1, 0 ) //"Anexo j� cadastrado para este in�cio de vig�ncia."
        EndIF

    EndIf

ElseIf cAlias := FSA200ALIAS() == "F1D"

    cMes 		:= oModel:GetValue ('MODEL_GEN',"F1D_MES")
    cAno 		:= oModel:GetValue ('MODEL_GEN',"F1D_ANO")
    cMesUti     := oModel:GetValue ('MODEL_GEN',"F1D_MESUTI")
    cAnoUti     := oModel:GetValue ('MODEL_GEN',"F1D_ANOUTI")
    cAtiv       := oModel:GetValue ('MODEL_GEN',"F1D_CODATV")
    cSubAtiv    := oModel:GetValue ('MODEL_GEN',"F1D_SUBATV")
    cAnexo      := oModel:GetValue ('MODEL_GEN',"F1D_ANEXO")
    cTpRec      := oModel:GetValue ('MODEL_GEN',"F1D_TPREC")

     F1D->(dbSetOrder(1))

    IF nOperation == MODEL_OPERATION_INSERT

        If	F1D->( MsSeek ( xFilial('F1D') + cAnoUti + cMesUti + cAno + cMes + cAtiv + cSubAtiv + cAnexo + cTpRec ) )
            //J� existe encargo para o per�odo.
            lRet:= .F.
            Help( ,, 'Help',, "J� existe saldo cadastrado para a combina��o: M�s Ref. + Ano Ref. + M�s Util. + Ano Util. + Atividade + Subatividade + Anexo ", 1, 0 )
        EndIF

    EndIf

EndiF

// Retorno a tabela para o �ndice original...
(FSA200ALIAS())->(dbSetOrder(nIndex))

Return lRet

Static Function IniPad( xRet )
Return xRet