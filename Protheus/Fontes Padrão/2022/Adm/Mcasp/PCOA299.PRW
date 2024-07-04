#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA299.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA299
Cadastro de Inflação
@author TOTVS
@since 22/10/2020 
@version P12
/*/
//-------------------------------------------------------------------
Function PCOA299()
Local oBrowser 
Local aRotina := {}

dbSelectArea("A23")
dbSetOrder(1)

aRotina := MenuDef()

oBrowser := FWmBrowse():New()


oBrowser:SetAlias( 'A23' )

oBrowser:SetDescription(STR0001) //"Cadastro de Inflação - MCASP" 

oBrowser:Activate()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 24/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCOA299' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCOA299' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCOA299' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCOA299' OPERATION 5 ACCESS 0 //'Excluir'

ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCOA299' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.PCOA299' OPERATION 9 ACCESS 0 //'Copiar'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 24/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruA23 := FWFormStruct(1,'A23')

Local oModel

oModel := MPFormModel():New('PCOA299',/*bPre*/,{|oModel|P299TDOK(oModel)})

oModel:AddFields('A23MASTER',,oStruA23)

oModel:SetDescription( STR0001 )  //"Cadastro de Inflação - MCASP"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina

@author TOTVS
@since 24/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruA23	:= FWFormStruct(2,'A23')
Local oModel	:= FWLoadModel('PCOA299')
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_A23',oStruA23,'A23MASTER')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' 	,  100 )

oView:SetOwnerView('VIEW_A23','TELA'		)

oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} P299TDOK
Rotina de Validação tudo ok

@author TOTVS
@since 24/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P299TDOK(oModel)
Local lRet := .T. 
Local cQry := ""
Local aAliasA23 := Getnextalias()
Local nOpr := oModel:Getoperation()
Local cAno := FWFldGet("A23_ANO")

If nOpr == 3
    //Validação para existir uma unica nota para o calendario 
    cQry := "SELECT A23_ANO FROM " +RetSqlName("A23") +" A23" +CRLF
    cQry += "WHERE A23_FILIAL ='"+xFilial("A23")+"'" +CRLF
    cQry += "AND A23_ANO = '"+cAno+"'"+CRLF
    cQry += "AND A23.D_E_L_E_T_ = ' '"+CRLF

    cQry := ChangeQuery(cQry)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),aAliasA23,.T.,.F.)

    If (aAliasA23)->(!EOF())
        HELP(,, 'ANOJACADASTRADO',,STR0008+cAno+STR0009, 1, 0) //"A Nota Explicativa já existe para esse periodo"
        lRet := .F.
    EndIf

    (aAliasA23)->(dbCloseArea())
EndIF
Return lRet
