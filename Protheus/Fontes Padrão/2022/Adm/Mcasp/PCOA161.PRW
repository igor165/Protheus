#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA161.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA161P
Cadastro de Nota explicativa
@author TOTVS
@since 22/10/2020 
@version P12
/*/
//-------------------------------------------------------------------
Function PCOA161()
Local oBrwA20
Local oBrwBkp
Local cFilter   := "A20_FILIAL = '"+ AK5->AK5_FILIAL +"' .AND. A20_CONTA = '"+ AK5->AK5_CODIGO +"'"

Private aRotina := {}
SaveInter()

dbSelectArea("A20")
dbSetOrder(1)

aRotina := MenuDef()

oBrwA20 := FWmBrowse():New()

//Filtro
oBrwA20:SetFilterDefault(cFilter)	

oBrwA20:SetAlias( 'A20' )

oBrwA20:SetDescription(STR0001) //"Cadastro de Nota explicativa" 

If !Empty(oBrowse)
    oBrwbkp := oBrowse
    oBrowse := oBrwA20
    oBrowse:Activate()
    oBrowse := oBrwbkp
Else 
    oBrwA20:Activate()
EndIf

aRotina := {}

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

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCOA161' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCOA161' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCOA161' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCOA161' OPERATION 5 ACCESS 0 //'Excluir'

ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCOA161' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.PCOA161' OPERATION 9 ACCESS 0 //'Copiar'

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
Local oStruA20 := FWFormStruct(1,'A20')

Local oModel

oModel := MPFormModel():New('PCOA161',/*bPre*/,{|oModel|P161TDOK(oModel)})
oModel:SetVldActivate({|oModel|P161ACTIVAT(oModel)})

//Inicializador padrão
oStruA20:SetProperty('A20_CONTA',MODEL_FIELD_INIT,{|oModel|AK5->AK5_CODIGO})

//When
oStruA20:SetProperty('A20_CONTA',MODEL_FIELD_WHEN,{|oModel|.F.})
oStruA20:SetProperty('A20_CODIGO',MODEL_FIELD_WHEN,{|oModel|INCLUI})
oStruA20:SetProperty('A20_DATA',MODEL_FIELD_WHEN,{|oModel|INCLUI})

oModel:AddFields('A20MASTER',,oStruA20)

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

Local oStruA20	:= FWFormStruct(2,'A20')
Local oModel	:= FWLoadModel('PCOA161')
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_A20',oStruA20,'A20MASTER')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' 	,  100 )

oView:SetOwnerView('VIEW_A20','TELA'		)

oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} P161TDOK
Validação no VLDPOS para não deixar criar uma nota explicativa
pra mesma visão mesma conta mesmo calendario

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P161TDOK(oModel)
Local lRet := .T. 
Local cQry := ""
Local aAliasA20 := Getnextalias()
Local nOpr := oModel:Getoperation()
Local cAno := cValtochar(Year(FWFldGet("A20_DATA")))

If nOpr == 3
    //Validação para existir uma unica nota para o calendario 
    cQry := "SELECT A20_CODIGO FROM " +RetSqlName("A20") +" A20" +CRLF
    cQry += "WHERE A20_FILIAL ='"+xFilial("A20")+"'" +CRLF
    cQry += "AND A20_CONTA = '"+FWFldGet("A20_CONTA")+"'"+CRLF
    cQry += "AND SUBSTRING(A20_DATA,1,4) = '"+cAno+"'"+CRLF
    cQry += "AND A20.D_E_L_E_T_ = ' '"+CRLF

    cQry := ChangeQuery(cQry)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),aAliasA20,.T.,.F.)

    If (aAliasA20)->(!EOF())
        HELP(,, 'NEJAEXISTEPER',,STR0008, 1, 0) //"A Nota Explicativa já existe para esse periodo"
        lRet := .F.
    EndIf

    (aAliasA20)->(dbCloseArea())
EndIF
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P161ACTIVAT
Funçaõ para realizar validação antes de abrir a tela

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P161ACTIVAT(oModel)
Local nOper     := oModel:getOperation()
Local lRet      := .T.
Local lCompart  := .F.
Local nI        := 0
Local aGestEmp  := {}


If nOper == 3 

    //aGestEmp = Array que guarda o compartilhamento da tabela CT2
	//Posição 1 = Compartilhamento | Posição 2 = Nível
	//Nivel 1 = Empresa, Nivel 2 = Unidade de Negócio e Nivel 3 = Filial)
	For nI := 1 to 3
		AAdd(aGestEmp, {FWModeAccess("AK5", nI), nI})
	Next nI

	// Verificar se é totalmente exclusiva
	For nI := 1 to 3
		If aGestEmp[nI,1] == "E"
			lCompart := .T.
			Exit
        EndIf
	Next nI

    If lCompart .And. (AK5->AK5_FILIAL <> FwxFilial("A20"))
        HELP(' ',1,"ERROFILIAL" ,,STR0009+AK5->AK5_FILIAL,1,0)//"A Filial selecionada para a inclusão é diferente da filial da Visão Gerencial. Filial da Visão: "
        lRet := .F.
    EndIf
EndIf

Return lRet
