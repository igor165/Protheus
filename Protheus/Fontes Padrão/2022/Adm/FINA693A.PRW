#INCLUDE "FINA693A.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'

Static __F693MOED := ExistBlock("F693MOED")


//-------------------------------------------------------------------
/*/{Protheus.doc} FINA693A
Faturamento de Prestcao de contas Avulsa

@author Alexandre Circenis
@since 22/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function FINA693A()
Local oBrowse

Private lEditFL6 := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'FLF' )
oBrowse:SetDescription( 'Faturamento Contra Cliente' )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.FINA693A' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Gerar'      Action 'VIEWDEF.FINA693A' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Estornar'   Action 'VIEWDEF.FINA693' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'   Action 'VIEWDEF.FINA693A' OPERATION 8 ACCESS 0

Return aRotina

Function FN693AFAT(cAlias, nReg, nOpc, lAutomato, oModel)
Private lEditFL6 := .F.

Default lAutomato	:= .F.
Default oModel	:= Nil

If !lAutomato
	FWExecView(STR0001,"FINA693A",MODEL_OPERATION_UPDATE) //"Fatura Cliente"
Else
	FNA693AIND(oModel)
	FN693CM( oModel )
EndIf

return

Function FN693ADEL(cAlias, nReg, nOpc, lAutomato, oModel)
Private lEditFL6 := .F.

Default lAutomato	:= .F.
Default oModel	:= Nil

If !lAutomato
	FWExecView(STR0001,"FINA693A",6) //"Fatura Cliente"
Else
	FNA693AIND(oModel)
	FN693CM( oModel )
EndIf

return
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFLF := FWFormStruct( 1, 'FLF', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruDES := DefStrModel( ) //FWFormStruct( 1, 'DES', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel
oModel := MPFormModel():New( 'FINA693A', /*bPreValidacao*/, /*bPosValidacao*/, {|oObj|FN693CM( oObj )}/*bCommit*/, /*bCancel*/ )

//Cria campo natureza para a estrutura.
FN693ACPO(1,oStruFLF)

//Gatilho para porcentagem.
oStruFLF:AddTrigger('FLF_FATCLI','FLF_FATCLI',{|| .T. }, {|x|FN693PCli(oModel)})

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FLFMASTER', /*cOwner*/, oStruFLF )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'DESDETAIL', 'FLFMASTER', oStruDES, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//Exemplo de com Definicao do bloco de Carga
//oModel:AddGrid( 'DESDETAIL', 'FLQMASTER', oStruDES, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
//oModel:SetRelation( 'DESDETAIL', { { 'DES_FILIAL', 'xFilial( "DES" )' }, { 'DES_VIAGEM' , 'FLF_VIAGEM'  } } , DES->( IndexKey( 1 ) )  )

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'DESDETAIL' ):SetUniqueLine( { 'DES_MUSICA' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0002 ) //'Modelo de Cobrança de Cliente'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FLFMASTER' ):SetDescription( STR0003 ) //'Prestacao Contas'
oModel:GetModel( 'DESDETAIL' ):SetDescription( STR0004  ) //'Despesas da Viagem'

// Nao Permite Incluir, Alterar ou Excluir linhas na formgrid
//oModel:GetModel( 'ZA5DETAIL' ):SetNoInsertLine()
//oModel:GetModel( 'ZA5DETAIL' ):SetNoUpdateLine()
//oModel:GetModel( 'ZA5DETAIL' ):SetNoDeleteLine()

// Adiciona regras de preenchimento
//
// Tipo 1 pre-validacao
// Adiciona uma relação de dependência entre campos do formulário,
// impedindo a atribuição de valor caso os campos de dependëncia
// náo tenham valor atribuido.
//
// Tipo 2 pos-validacao
// Adiciona uma relação de dependência entre a referência de origem e
// destino, provocando uma reavaliação do destino em caso de atualização
// da origem.
//
// Tipo 3 pre e pos-validacao
// oModel:AddRules( 'FLQMASTER', 'FLQ_DATA', 'FLQMASTER', 'FLQ_DESCRI', 1 )


oModel:SetPrimaryKey( {} ) //obrigatorio setar a chave primaria (mesmo que vazia)
oModel:SetVldActive( { | oModel | FN693AVACT( oModel ) } )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruFLF := FWFormStruct( 2, 'FLF', {|u| !AllTrim(u) $ 'FLF_VIAGEM|FLF_CONFER|FLF_DTCONF|FLF_OBCONF|FLF_NOMECF|FLF_TIPO|FLF_MOTIVO'} )
Local oStruDES := DefStrView()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'FINA693A' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Campos desabilitados na view.
oStruFLF:SetProperty('*'		  , MVC_VIEW_CANCHANGE, .F. )
oStruFLF:SetProperty('FLF_FATEMP' , MVC_VIEW_CANCHANGE, .T. )
oStruFLF:SetProperty('FLF_FATCLI' , MVC_VIEW_CANCHANGE, .T. )
oStruFLF:SetProperty('FLF_CLIENT' , MVC_VIEW_CANCHANGE, Empty(FLF->FLF_CLIENT) )
oStruFLF:SetProperty('FLF_LOJA'   , MVC_VIEW_CANCHANGE, Empty(FLF->FLF_LOJA)   )

//Cria campo natureza para a estrutura.
FN693ACPO(2,oStruFLF)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FLF', oStruFLF, 'FLFMASTER' )
oView:SetViewProperty('VIEW_FLF',"SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP ,1})

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_DES', oStruDES, 'DESDETAIL' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' , 50 )
oView:CreateHorizontalBox( 'MEIO'   , 50 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FLF', 'EMCIMA'   )
oView:SetOwnerView( 'VIEW_DES', 'MEIO'     )

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_FLF' )
oView:EnableTitleView( 'VIEW_DES', STR0005, RGB( 224, 30, 43 )  ) //"Pedidos Conferidos"


// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_DES', "ENABLEDGRIDDETAIL", { 60 } )
//oView:SetViewProperty( 'VIEW_ZA5', "ENABLEDGRIDDETAIL", { 60 } )
// Acrescenta um objeto externo ao View do MVC
// AddOtherObject(cFormModelID,bBloco)
// cIDObject - Id
// bBloco    - Bloco chamado evera ser usado para se criaros objetos de tela externos ao MVC.

//oView:AddOtherObject("OTHER_PANEL", {|oPanel| COMP23BUT(oPanel)})
//oView:SetOwnerView("OTHER_PANEL",'EMBAIXODIR')

oView:BAFTERVIEWACTIVATE := {||lCont := FNA693AIND( oModel ) }

Return oView

//-------------------------------------------------------------------
Static Function DefStrModel()
Local oStruct := FWFormModelStruct():New()
Local bValid
oStruct:AddTable('FL6',{'FL6_DESC'},STR0006) //'Despesas com a Viagem'
oStruct:AddField(STR0007,STR0008 , 'FL6_DESC', 'C',60,0,,{||lEditFL6},,,,,.T.,.T. ) //'Descrição'###'Descrição da Despesa'
oStruct:AddField(STR0009,STR0010 , 'FL6_VALOR', 'N',14,2,,{||lEditFL6},,,,,.T. ,.T.) //'Valor'###'Valor da Despesa'
oStruct:AddField(STR0011,STR0012 , 'FL6_PORC', 'N',6,2,,{||lEditFL6},,,,,.T. ,.T. ) //'Porcentagem'###'Porcentagem que será faturada contra o cliente.'
bValid := FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo().and. FNA693AVVCO()")
oStruct:AddField(STR0013,STR0014 , 'FL6_COB', 'N',14,2, bValid,{||.T.},,,,,.T. ,.T. ) //'Valor Cobrado'###'Valor que será cobrado do cliente'
//TES
oStruct:AddField(STR0030,STR0030,'FL6_TES',"C",3,0,/*bValid*/,/*bWhen*/,/*aValues*/,/*lObrigat*/)
//Produto
oStruct:AddField(STR0031,STR0031,"FL6_PROD","C",15,0,/*bValid*/,/*bWhen*/,/*aValues*/,/*lObrigat*/)

return oStruct


static function DefStrView()
Local oStruct := FWFormViewStruct():New()

//Produto
oStruct:AddField( 'FL6_PROD','1','Produto','Produto',,'Get',PesqPict('SC6','C6_PRODUTO'),/**/,'SB1')
//TES
oStruct:AddField( 'FL6_TES','2','TES','TES',,'Get',PesqPict('SC6','C6_TES'),/**/,'SF4')
oStruct:AddField( 'FL6_DESC','3',STR0007,STR0008,, 'Get','@x',,,,,,,,,,,.F. )  //'Descrição'###'Descrição da Despesa'
oStruct:AddField( 'FL6_VALOR','4',STR0009,STR0010,, 'Get','@E 99,999,999,999.99',,,,,,,,,,,.F. )  //'Valor'###'Valor da Despesa'
oStruct:AddField( 'FL6_PORC','5',STR0011,STR0012,, 'Get','@E 999.99%',,,,,,,,,,,.F. )  //'Porcentagem'###'Porcentagem que será faturada contra o cliente.'
oStruct:AddField( 'FL6_COB','6',STR0013,STR0014,, 'Get','@E 99,999,999,999.99',,,,,,,,,,,.F. )  //'Valor Cobrado'###'Valor que será cobrado do cliente'
return oStruct


//-------------------------------------------------------------------
Function FNA693AVVCO()

Local lRet 		    := .T.
Local oModel        := FWModelActive()
Local oModelFLF     := oModel:GetModel("FLFMASTER")
Local oModelDES     := oModel:GetModel("DESDETAIL")
Local aSaveLines	:= FWSaveRows()
Local nX			:= 0
Local oView			:= FWViewActive()
Local nTotal        := 0

if oModelDES:GetValue("FL6_COB") > oModelDES:GetValue("FL6_VALOR")
	lRet := .f.
	Help( ,, 'Help',, STR0015, 1, 0 )	 //'O Valor Cobrado para a Despesa não pode ser maior que o valor da Despesa.'
endif

if lRet
	For nX := 1 To oModelDES:Length()
		oModelDes:GoLine( nX )
		nTotal += oModelDES:GetValue("FL6_COB")
	Next

	oModelFLF:SetValue( "FLF_VALCOB" , nTotal )

endif

FWRestRows(aSaveLines)

If oView != Nil
	oView:Refresh()
EndIf

Return lRet
//
//--------------------------------------------------------------------------------------
//
Function FNA693AIND(oModel)
Local aArea         := GetArea()
Local lRet 		    := .T.
Local oModelDES     := oModel:GetModel("DESDETAIL")
Local oModelFLF     := oModel:GetModel("FLFMASTER")
Local oView			:= FWViewActive()
Local nI            := 1
Local nItErro       := nI
Local cTipo         := oModel:GetValue( 'FLFMASTER','FLF_TIPO')
Local cPresta       := oModel:GetValue( 'FLFMASTER','FLF_PRESTA')
Local nTotal        := 0
Local cProd         := SupergetMv("MV_RESPROD",.T.,"   ")
Local nValMoed		:= 0

lEditFL6 := .T.

dbSelectArea("FLF")
dbSetOrder(1)
dbSeek(xFilial("FLF")+cTipo+cPresta)

while !Eof() .and. FLF->FLF_FILIAL = xFilial("FLF") .and. FLF->FLF_TIPO = cTipo .and. FLF->FLF_PRESTA = cPresta

	If (__F693MOED)
		nValMoed := ExecBlock("F693MOED", .F., .F., {FLF->(FLF_TVLRE1 - FLF_TDESC1)})
		nValMoed := IIf(ValType(nValMoed) == "N", nValMoed, FLF->(FLF_TVLRE1 - FLF_TDESC1))
	Else
		nValMoed := FLF->(FLF_TVLRE1 - FLF_TDESC1)
	EndIf

	If nI > 1

		// Incluimos uma nova linha de item

		If  ( nItErro := oModelDES:AddLine() ) <> nI

			// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
			// ele retorna a quantidade de linhas já
			// existem no grid. Se conseguir retorna a quantidade mais 1
			lRet    := .F.
			Exit
		EndIf

	EndIf

	lRet := oModel:LoadValue( 'DESDETAIL', "FL6_DESC",STR0016+Alltrim(FLF_PRESTA)) //"Prestação de Contas "
	if lRet
		lRet := oModel:LoadValue( 'DESDETAIL', "FL6_VALOR", nValMoed)
	endif
	if lRet
		nPorc := FLF->FLF_FATCLI
		lRet := oModel:LoadValue( 'DESDETAIL', "FL6_PORC",nPorc)
	endif
	if lRet
		lRet := oModel:LoadValue( 'DESDETAIL', "FL6_COB", nValMoed * nPorc / 100)
    endif

    oModel:LoadValue('DESDETAIL','FL6_PROD', AllTrim(cProd) )
    oModel:LoadValue('DESDETAIL','FL6_TES', F693IniTES(FLF->FLF_CLIENT,FLF->FLF_LOJA) )

    if !lRet
    	exit
    endif
    nTotal += nValMoed * nPorc / 100
	nI++
	dbSkip()
enddo
if oModelFLF:GetValue("FLF_VALCOB") = 0
	oModelFLF:LoadValue("FLF_VALCOB",nTotal )
endif
oModelDES:GoLine( 1 )

If !lRet

	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel:GetErrorMessage()

	// A estrutura do vetor com erro é:
	//  [1] Id do formulário de origem
	//  [2] Id do campo de origem
	//  [3] Id do formulário de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solução
	//  [8] Valor atribuido
	//  [9] Valor anterior

	AutoGrLog( STR0017 + ' [' + AllToChar( aErro[1]  ) + ']' ) //"Id do formulário de origem:"
	AutoGrLog( STR0018 + ' [' + AllToChar( aErro[2]  ) + ']' ) //"Id do campo de origem:     "
	AutoGrLog( STR0019 + ' [' + AllToChar( aErro[3]  ) + ']' ) //"Id do formulário de erro:  "
	AutoGrLog( STR0020 + ' [' + AllToChar( aErro[4]  ) + ']' ) //"Id do campo de erro:       "
	AutoGrLog( STR0021 + ' [' + AllToChar( aErro[5]  ) + ']' ) //"Id do erro:                "
	AutoGrLog( STR0022 + ' [' + AllToChar( aErro[6]  ) + ']' ) //"Mensagem do erro:          "
	AutoGrLog( STR0023 + ' [' + AllToChar( aErro[7]  ) + ']' ) //"Mensagem da solução:       "
	AutoGrLog( STR0024 + ' [' + AllToChar( aErro[8]  ) + ']' ) //"Valor atribuido:           "
	AutoGrLog( STR0025 + ' [' + AllToChar( aErro[9]  ) + ']' ) //"Valor anterior:            "

	If nItErro > 0
		AutoGrLog( STR0026 + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' ) //"Erro no Item:              "
	EndIf

	MostraErro()
	oModel:DeActivate()

else
	oModel:GetModel( 'DESDETAIL' ):SetNoInsertLine( .T. )

	If oView != Nil
		oView:Refresh()
	EndIf

EndIf

RestArea(aArea)

lEditFL6 := .F.

Return lRet

//
//-------------------------------------------------------------------
//
Static Function FN693CM( oModel )

Local aArea      := GetArea()
Local nOperation := oModel:GetOperation()
Local aSaveLines := FWSaveRows()
Local oModelFLF := oModel:GetModel( 'FLFMASTER' )
Local oModelDES := oModel:GetModel( 'DESDETAIL' )
Local lRet := .T.

Begin Transaction

If nOperation = MODEL_OPERATION_UPDATE .and. oModelFLF:GetValue("FLF_VALCOB") > 0

    // Gera o pedido de Venda
    If Fn693GPVen( oModelFLF:GetValue("FLF_CLIENT"), oModelFLF:GetValue("FLF_LOJA"), oModelFLF:GetValue("FLF_VALCOB"),;
    			   oModelFLF:GetValue("FLF_PRESTA"),.F., oModelFLF:GetValue("NATUREZ") )
		RecLock("FLF",.F.)
    	FLF->FLF_PEDIDO := SC5->C5_NUM
    	FLF->FLF_STATUS := '9'
		MsUnlock()
    Else
    	DisarmTransaction()
    	lRet := .F.
    	Help("" ,1, 'Help',, STR0033, 1, 0 )
    EndIf

EndIf

If nOperation = 6
    // Estorna o pedido de Venda
    If Fn693EPVen(oModelFLF:GetValue("FLF_PEDIDO"))
		RecLock("FLF",.F.)
    	FLF->FLF_PEDIDO := ""
    	FLF->FLF_STATUS := '8'
		MsUnlock()
    Else
    	DisarmTransaction()
    	lRet := .F.
    	Help("" ,1, 'Help',, STR0034, 1, 0 )
    EndIf

EndIf

End Transaction

RestArea(aArea)

Return lRet

//
//------------------------------------------------------
//
STATIC Function FN693AVACT( oModel )
Local lRet := .T.

if !Empty(FLF->FLF_VIAGEM)
	Help( ,, 'Help',, STR0027, 1, 0 )	 //'Está prestação de contas está ligada a uma viagem. Gerar o Faturamento na Rotina de Viagens'
	lRet := .F.
elseif !Empty(FLF->FLF_PEDIDO) .and. oModel:GetOperation() = MODEL_OPERATION_UPDATE
	Help( ,, 'Help',, STR0028, 1, 0 )	 //'Está prestação de contas já tem um pedido gerado'
	lRet := .F.
elseif Empty(FLF->FLF_PEDIDO) .and. oModel:GetOperation() = 6
	Help( ,, 'Help',, STR0029, 1, 0 )	 //'Está prestação de contas não foi faturada.'
	lRet := .F.
endif

Return lRet

/*/{Protheus.doc}FN693ACPO
Cria campo natureza para a estrutura FLF/FL5.
@author William Matos
@since  06/11/2015
@version 12
/*/
Function FN693ACPO(nTipo,oStruct)

	If nTipo == 1 //Model
		oStruct:AddField(STR0032,STR0032,'NATUREZ',"C",TamSx3('ED_CODIGO')[1],0)
	Else
		oStruct:AddField( 'NATUREZ','99',STR0032,STR0032,,'GET',PesqPict('SED','ED_CODIGO'),/**/,'SED',.T.,'1')
	EndIf

Return

/*/{Protheus.doc}FN693PCli
Gatilho para recalcular os valores cobrados do cliente.
@author William Matos
@since  12/11/2015
/*/
Function FN693PCli(oModel)
Local oAuxFLF		:= Nil
Local nPorc 		:= 0
Local nValor		:= 0
Local nValMoed		:= 0

Default oModel 	:= FWModelActive()

	oAuxFLF := oModel:GetModel('FLFMASTER')
	//
	nPorc  := oAuxFLF:GetValue('FLF_FATCLI')

	If (__F693MOED)
		nValMoed := ExecBlock("F693MOED", .F., .F., {(oAuxFLF:GetValue('FLF_TVLRE1') - oAuxFLF:GetValue('FLF_TDESC1'))})
		nValMoed := IIf(ValType(nValMoed) == "N", nValMoed, (oAuxFLF:GetValue('FLF_TVLRE1') - oAuxFLF:GetValue('FLF_TDESC1')))
	Else
		nValMoed := (oAuxFLF:GetValue('FLF_TVLRE1') - oAuxFLF:GetValue('FLF_TDESC1'))
	EndIf

	nValor := nValMoed * nPorc / 100
	oModel:LoadValue( 'DESDETAIL', "FL6_COB", nValor)
	oModel:LoadValue( 'DESDETAIL', "FL6_PORC", nPorc)

Return