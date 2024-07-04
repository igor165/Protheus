#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA175.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA175
Cadastro de Tabela de Classificadores de Receita e Despesa
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PCOA175()
Local oBrowse

dbSelectArea("A1J")
dbSetOrder(1)

dbSelectArea("A1I")
dbSetOrder(1)

oBrowse := FWmBrowse():New()

oBrowse:SetAlias( 'A1I' )

oBrowse:SetDescription( STR0001 ) //Cadastro de Aglutinadores de Visão

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCOA175' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCOA175' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCOA175' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCOA175' OPERATION 5 ACCESS 0 //'Excluir'

ADD OPTION aRotina Title STR0011 Action 'VIEWDEF.PCOA175' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.PCOA175' OPERATION 9 ACCESS 0 //'Copiar'


Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruA1I := FWFormStruct(1,'A1I')
Local oStruA1J := FWFormStruct(1,'A1J')

Local oModel

oModel := MPFormModel():New('PCOA175',,{ || A1JLPOS() })

oModel:AddFields('A1IMASTER',,oStruA1I)

oModel:AddGrid('A1JDETAIL','A1IMASTER',oStruA1J, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Define o número máximo de linhas que o model poderá receber
oModel:GetModel("A1JDETAIL"):SetMaxLine(999)

oModel:SetRelation('A1JDETAIL',{{'A1J_FILIAL','XFilial("A1J")'},{'A1J_CODAGL','A1I_CODAGL'}}, A1J->(IndexKey(1)) )

// Liga o controle de não repetição de linha
oModel:GetModel( 'A1JDETAIL' ):SetUniqueLine( { 'A1J_CODVIS' } )

oModel:SetPrimarykey({'A1I_FILIAL','A1I_CODAGL'})

oModel:SetDescription( STR0012 )  //'Aglutinadores de Visao'

oModel:GetModel('A1IMASTER'):SetDescription( STR0007 ) //"Cadastro de Aglutinadores de Visao (CabeÃ§alho) "
oModel:GetModel('A1JDETAIL'):SetDescription( STR0008 ) //"Itens do Cadastro Aglutinadores de Visao"
 
oModel:GetModel( 'A1JDETAIL' ):SetOptional( .T. )


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

Local oStruA1I	:= FWFormStruct(2,'A1I')
Local oStruA1J	:= FWFormStruct(2,'A1J')
Local oModel	:= FWLoadModel('PCOA175')
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_A1I',oStruA1I,'A1IMASTER')

oView:AddGrid('VIEW_A1J',oStruA1J,'A1JDETAIL')

// Cria Folder na view
oView:CreateFolder( 'ITENS' )

// Cria pastas nas folders
oView:AddSheet( 'ITENS', 'XXXX', STR0013 )  //'Itens - Aglutinadores Visão Gerencial'

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' 	,  20,,, 'ITENS', 'XXXX' )
oView:CreateHorizontalBox( 'EMBAIXO'	,  80,,, 'ITENS', 'XXXX' )

oView:CreateHorizontalBox( 'GERAL'  , 100,,, 'ITENS', 'YYYY' )

oView:SetOwnerView('VIEW_A1I','EMCIMA'		)
oView:SetOwnerView('VIEW_A1J','EMBAIXO'		)

oView:EnableTitleView('VIEW_A1I')
oView:EnableTitleView('VIEW_A1J')

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_A1J', 'A1J_ITEAGL' )

oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A1JLPOS
ValidaÃ§Ã£o 

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function A1JLPOS()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oGrid_A1J	:= oModel:GetModel("A1JDETAIL")
Local cCodVis   := ""
Local aSaveRows
Local nX
Local dDataIni
Local dDataFim

//----------------------------------------
// Valida 
//----------------------------------------
If oModel:GetModel( 'A1JDETAIL' ):IsEmpty()
	Help( , ,"A1JLPOS", ,STR0009,1,0,,,,,,{ STR0010 })	//"Cadastro de Aglutinadores de Visão Gerencial nÃ£o preenchido!" ### 
																//"Para solucionar efetue o cadastro dos itens de configuração de visao"                    
	lRet := .F.
EndIf

If lRet

	aSaveRows	:= FWSaveRows()

	//validar data inicio / fim não exceda 1 ano
	For nX := 1 To oGrid_A1J:Length()

		oGrid_A1J:GoLine( nX )

		If ! oGrid_A1J:IsDeleted()

			dDataIni	:= oGrid_A1J:GetValue("A1J_DATINI")
			dDataFim	:= oGrid_A1J:GetValue("A1J_DATFIM")
			cCodVis     := oGrid_A1J:GetValue("A1J_CODVIS")

			If Empty(dDataIni)
				Help( , ,"A1JLPOS_DTINI", ,STR0024,1,0,,,,,,{ STR0025 })	//"Data inicio esta vazia!" ### 
																			//"Para solucionar preencha a data de inicio."                    
				lRet := .F.	
				Exit

			ElseIf Empty(dDataFim)
				Help( , ,"A1JLPOS_DTFIM", ,STR0026,1,0,,,,,,{ STR0027 })	//"Data final esta vazia!" ### 
																			//"Para solucionar preencha a data final."                    
				lRet := .F.	
				Exit

			ElseIf dDataIni > dDataFim  //data inicio maior que data fim
				Help( , ,"A1JLPOS_DTMAIOR", ,STR0028,1,0,,,,,,{ STR0029 })	//"Data inicio Maior que data final!" ### 
																			//"Para solucionar preencha a data de inicio menor que data final."                    
				lRet := .F.	
				Exit

			ElseIf dDataFim - dDataIni > 365  //superior a 1 ano
				Help( , ,"A1JLPOS_DTDIFF", ,STR0030,1,0,,,,,,{ STR0031 })	//"Intervalo entre data inicio e final superior a 1 ano!" ### 
																			//"Para solucionar preencha o intervalo de datas inferior ou igual a 1 ano."                    
				lRet := .F.	
				Exit
			ElseIf !Empty(cCodVis)
				AKP->(dbSetOrder(1)) //AKP_FILIAL+AKP_CODIGO+AKP_CO+AKP_ITEM+AKP_CONFIG+AKP_ITECFG                                                                                                     
				If !AKP->(dbSeek(xFilial("AKP") + cCodVis))
					Help(,,"A1JLPOS_CODVIS", ,STR0032+cCodVis+STR0033,1,0,,,,,,{ STR0034 })	//"Visao Gerencial" "nao possui itens na estrutura (tabela: AKP)" ### 
																							//"Para solucionar adicione pelo menos um item na Visao Gerencial e escolha o Tipo de Saldo"                    
					lRet := .F.
				EndIf
			EndIf
			
		EndIf

	Next

	FWRestRows(aSaveRows)

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Agl_Imp
Rotina auxiliar de Importação com gravação dos dados no modelo

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function Agl_Imp(cMaster, cDetail, aCpoMaster, aCpoDetail )
Local oModel, oAux, oStruct
Local nI := 0
Local nJ := 0
Local nPos := 0
Local lRet := .T.
Local aAux := {}

Local nItErro := 0
Local lAux := .T.

dbSelectArea( cDetail )
dbSetOrder( 1 )

dbSelectArea( cMaster )
dbSetOrder( 1 )

// Aqui ocorre o instânciamento do modelo de dados (Model)
// Neste exemplo instanciamos o modelo de dados do fonte PCOA175
oModel := FWLoadModel( 'PCOA175' )

// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
oModel:SetOperation( 3 )

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
oModel:Activate()

// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
oAux := oModel:GetModel( cMaster + 'MASTER' )
// Obtemos a estrutura de dados do cabeçalho
oStruct := oAux:GetStruct()
aAux := oStruct:GetFields()

If lRet
	For nI := 1 To Len( aCpoMaster )
		// Verifica se os campos passados existem na estrutura do cabeçalho
		If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
		// È feita a atribuição do dado aos campo do Model do cabeçalho
			If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )
				// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
				// o método SetValue retorna .F.
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
EndIf

If lRet
	// Instanciamos apenas a parte do modelo referente aos dados do item
	oAux := oModel:GetModel( cDetail + 'DETAIL' )
	// Obtemos a estrutura de dados do item
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	nItErro := 0
	For nI := 1 To Len( aCpoDetail )
		// Incluímos uma linha nova
		// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
		//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
		If nI > 1
			// Incluímos uma nova linha de item
			If ( nItErro := oAux:AddLine() ) <> nI
			// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
			lRet := .F.
			Exit
			EndIf
		EndIf

		For nJ := 1 To Len( aCpoDetail[nI] )
			// Verifica se os campos passados existem na estrutura de item
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
				If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
				// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
				// o método SetValue retorna .F.
				lRet := .F.
				nItErro := nI
				Exit
				EndIf
			EndIf
		Next
		If !lRet
		Exit
		EndIf
	Next
EndIf

If lRet
	// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
	// neste momento os dados não são gravados, são somente validados.
	If ( lRet := oModel:VldData() )
		// Se o dados foram validados faz-se a gravação efetiva dos
		// dados (commit)
		oModel:CommitData()
	EndIf
EndIf

If !lRet
	// Se os dados não foram validados obtemos a descrição do erro para gerar
	// LOG ou mensagem de aviso
	aErro := oModel:GetErrorMessage()
	// A estrutura do vetor com erro é:
	// [1] identificador (ID) do formulário de origem
	// [2] identificador (ID) do campo de origem
	// [3] identificador (ID) do formulário de erro
	// [4] identificador (ID) do campo de erro
	// [5] identificador (ID) do erro
	// [6] mensagem do erro
	// [7] mensagem da solução
	// [8] Valor atribuído
	// [9] Valor anterior
	
	AutoGrLog( STR0014 + ' [' + AllToChar( aErro[1] ) + ']' ) //"Id do formulário de origem:"
	AutoGrLog( STR0015 + ' [' + AllToChar( aErro[2] ) + ']' ) //"Id do campo de origem: " 
	AutoGrLog( STR0016 + ' [' + AllToChar( aErro[3] ) + ']' ) //"Id do formulário de erro: "
	AutoGrLog( STR0017 + ' [' + AllToChar( aErro[4] ) + ']' ) //"Id do campo de erro: "
	AutoGrLog( STR0018 + ' [' + AllToChar( aErro[5] ) + ']' ) //"Id do erro: "
	AutoGrLog( STR0019 + ' [' + AllToChar( aErro[6] ) + ']' ) //"Mensagem do erro: "
	AutoGrLog( STR0020 + ' [' + AllToChar( aErro[7] ) + ']' ) //"Mensagem da solução: "
	AutoGrLog( STR0021 + ' [' + AllToChar( aErro[8] ) + ']' ) //"Valor atribuído: "
	AutoGrLog( STR0022 + ' [' + AllToChar( aErro[9] ) + ']' ) //"Valor anterior: "
	If nItErro > 0
		AutoGrLog( STR0023 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' ) //"Erro no Item: "
	EndIf

	MostraErro()

EndIf

// Desativamos o Model
oModel:DeActivate()

Return lRet
