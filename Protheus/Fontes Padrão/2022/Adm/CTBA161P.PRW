
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBA161P.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA161P
Cadastro de Nota explicativa
@author TOTVS
@since 22/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function CTBA161P()
Local oBrowse
Local aBkpMenu := {}
Local cFilter   := "QLQ_CODPLA = '"+ CVF->CVF_CODIGO +"' .AND. QLQ_CONTAG = '"+ CVF->CVF_CONTAG +"'"

SaveInter()

dbSelectArea("QLQ")
dbSetOrder(1)

//limpa array do
If !Empty(aRotina)
    aBkpMenu := aClone(aRotina)
    aRotina := {}
    ASize(aRotina,0)
    aRotina := MenuDef()
EndIf

oBrowse := FWmBrowse():New()

//Filtro
oBrowse:SetFilterDefault(cFilter)	

oBrowse:SetAlias( 'QLQ' )

oBrowse:SetDescription(STR0001) //"Cadastro de Nota explicativa" 

oBrowse:Activate()

aRotina := aClone(aBkpMenu)

RestInter()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 22/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.CTBA161P' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.CTBA161P' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.CTBA161P' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.CTBA161P' OPERATION 5 ACCESS 0 //'Excluir'

ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.CTBA161P' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.CTBA161P' OPERATION 9 ACCESS 0 //'Copiar'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 22/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruQLQ := FWFormStruct(1,'QLQ')

Local oModel

oModel := MPFormModel():New('CTBA161P',/*bPre*/,{|oModel|C161PTDOK(oModel)})
oModel:SetVldActivate({|oModel|C161PACTIVAT(oModel)})

//Inicializador padrão
oStruQLQ:SetProperty('QLQ_CODPLA',MODEL_FIELD_INIT,{|oModel|CVF->CVF_CODIGO})
oStruQLQ:SetProperty('QLQ_CONTAG',MODEL_FIELD_INIT,{|oModel|CVF->CVF_CONTAG})

//Adiciona valide
oStruQLQ:SetProperty('QLQ_DATA',MODEL_FIELD_VALID ,{|oModel|C161PVLDATA(oModel)})

//When
oStruQLQ:SetProperty('QLQ_CODIGO',MODEL_FIELD_WHEN,{|oModel|INCLUI})
oStruQLQ:SetProperty('QLQ_CALEND',MODEL_FIELD_WHEN,{|oModel|INCLUI})
oStruQLQ:SetProperty('QLQ_DATA',MODEL_FIELD_WHEN,{|oModel|INCLUI})

oModel:AddFields('QLQMASTER',,oStruQLQ)

oModel:SetDescription( STR0001 )  //"Cadastro Nota Explicativa"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruQLQ	:= FWFormStruct(2,'QLQ')
Local oModel	:= FWLoadModel('CTBA161P')
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_QLQ',oStruQLQ,'QLQMASTER')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' 	,  100 )

oView:SetOwnerView('VIEW_QLQ','TELA'		)

oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} C161PTDOK
Validação no VLDPOS para não deixar criar uma nota explicativa
pra mesma visão mesma conta mesmo calendario

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function C161PTDOK(oModel)
Local lRet := .T. 
Local cQry := ""
Local aAliasQLQ := Getnextalias()
Local nOpr := oModel:Getoperation()

If nOpr == 3
    //Validação para existir uma unica nota para o calendario 
    cQry := "SELECT QLQ_CODIGO FROM " +RetSqlName("QLQ") +" QLQ" +CRLF
    cQry += "WHERE QLQ_FILIAL ='"+xFilial("QLQ")+"'" +CRLF
    cQry += "AND QLQ_CODPLA = '"+FWFldGet("QLQ_CODPLA")+"'"+CRLF
    cQry += "AND QLQ_CALEND = '"+FWFldGet("QLQ_CALEND")+"'"+CRLF
    cQry += "AND QLQ_CONTAG = '"+FWFldGet("QLQ_CONTAG")+"'"+CRLF
    cQry += "AND QLQ.D_E_L_E_T_ = ''"


    cQry := ChangeQuery(cQry)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),aAliasQLQ,.T.,.F.)

    If (aAliasQLQ)->(!EOF())
        HELP(,, 'NEJAEXISTEPER',,STR0008, 1, 0) //"A Nota Explicativa já existe para esse periodo"
        lRet := .F.
    EndIf

    (aAliasQLQ)->(dbCloseArea())
EndIF
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C161PVLDATA
Validação no QLQ_DATA para ver se a data estah no calendario

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function C161PVLDATA(oModel)
Local lRet := .T.
Local dDataNE   := oModel:GetValue("QLQ_DATA")
Local cCalend  := oModel:GetValue("QLQ_CALEND")
Local aArea := GetArea()
Local aAreaCTG  := CTG->(GetArea())
Local lPerid    := .F.
dbSelectArea("CTG")
CTG->(dbSetOrder(1))

If CTG->(DBSeek(xFilial("CTG")+cCalend))
    While !lPerid .And. (xFilial("CTG")+cCalend == CTG->CTG_FILIAL + CTG->CTG_CALEND)
        If CTG->CTG_DTINI <= dDataNE .and. dDataNE <= CTG->CTG_DTFIM
            lPerid := .T.
        EndIf
        CTG->(DBSkip())
    End
EndIf

If !lPerid
    HELP(' ',1,'ERRODATA' ,,STR0010,1,0)
    lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C161PACTIVAT
Funçaõ para realizar validação antes de abrir a tela

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function C161PACTIVAT(oModel)
Local nOper     := oModel:getOperation()
Local lRet      := .T.

If (nOper == 3 .And. CVF->CVF_FILIAL <> FwxFilial("QLQ"))
    HELP(' ',1,"ERROFILIAL" ,,STR0009+CVF->CVF_FILIAL,1,0)//"A Filial selecionada para a inclusão é diferente da filial da Visão Gerencial. Filial da Visão: "
    lRet := .F.
EndIf

Return lRet
