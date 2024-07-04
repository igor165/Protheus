#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA992.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA992
Cadastro do valor de dedução de IR para dependentes

@author Karen Honda
@since 14/09/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FINA992()
Local oBrowse

If cPaisLoc != "BRA"
	MsgStop(STR0011,STR0010) // "Rotina somente para o país Brasil." "Atenção"
	Return
EndIf

If AliasInDic("FKI")
	DbSelectArea("FKI")
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('FKI')
	oBrowse:SetDescription(STR0001) //'Cadastro de dedução IR por dependentes'

	oBrowse:Activate()
Else
	MsgStop(STR0009)	//"Tabela FKI não existe. Necessário atualizar a base!"
EndIf
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.FINA992' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.FINA992' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0005 	 ACTION 'VIEWDEF.FINA992' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0006	 ACTION 'VIEWDEF.FINA992' OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFKI := FWFormStruct( 1, 'FKI', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('FINA992', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields('FKIMASTER', /*cOwner*/, oStruFKI , , ,)


oModel:SetPrimaryKey({'FKI_FILIAL','FKI_MES','FKI_ANO'})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0007 )//'Cadastro de valor de dedução de IR para dependentes'


Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'FINA992' )
// Cria a estrutura a ser usada na View
Local oStruFKI := FWFormStruct( 2, 'FKI' )
Local oView


// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FKI', oStruFKI, 'FKIMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELAPAI' , 100 )
//oView:CreateHorizontalBox( 'TELAFIL' , 80 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FKI', 'TELAPAI' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F992RetVal
Retorna o valor da dedução do periodo mes/ano solicitado. Caso nao encontre, utiliza o valor do parametro MV_TMSVDEP
@param cMes, caracter, Mes de referencia para busca
@param cAno, caracter, Ano de referencia para busca

@return nValDed, numérico, retorna o valor da dedução encontrada para o periodo  

@author Karen Honda
@since 07/11/2016
@version P11
/*/
//-------------------------------------------------------------------
Function F992RetVal(cMes, cAno)
Local nValDed := 0
cMes := StrZero(Val(cMes),2)

DbSelectArea("FKI")
FKI->(DBSetOrder(1))
If FKI->(MsSeek(xFilial("FKI") + cMes + cAno ))
	nValDed := FKI->FKI_VALOR
Else	 
	nValDed := GetMV("MV_TMSVDEP",,0)
EndIf

Return nValDed

//-------------------------------------------------------------------
/*/{Protheus.doc} F992ValAno()
Valida o conteudo do campo ano


@return lret, true se conteudo do ano estiver ok  

@author Karen Honda
@since 07/11/2016
@version P11
/*/
//-------------------------------------------------------------------
Function F992ValAno()
Local lRet := .T.
If	Len(Alltrim(M->FKI_ANO)) != 4
	lRet := .F.
	Help( ,,"FKI_ANOVAL",,STR0008, 1, 0 )//"Ano inválido! Informe o ano no formato AAAA."
EndIf

Return lRet